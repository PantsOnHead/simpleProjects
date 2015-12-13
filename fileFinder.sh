#!/bin/bash

function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

function OS_X {
    echo "**********************"
    echo "** File Search OS X **"
    echo "**********************"
    # Ask for user input on where to start the search
    echo -n "Enter a folder to scan: "
    read folder
    # Check to see if the folder is a real directory the program can see loop until input is valid
    while [ ! -d "$folder" ]; do
        echo "ERROR. Invalid directory."
        echo ""
        echo -n "Enter a folder to scan: "
        read folder
    done

    # The idea here is to look for files modified within a specific time period. 
    echo -n "Enter start date (Format YYYY-MM-DD): "
    read startDate
    # This is rough validaion, as it wont actually check to see if the date is valid, just the format.
    # It also validates the optional time setting to the correct format.
    while [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo "ERROR. Invalid date format."
        echo ""
        echo -n "Enter start date (Format YYYY-MM-DD): "
        read startDate
    done
    
    echo -n "Enter end date (`date +%Y-%m-%d`): "
    read endDate
    # If no input then grab current system time. 
    if ["$endDate" = ""]; then
        endDate=`date +%Y-%m-%d`
    fi        

    while [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo "ERROR. Invalid date format."
        echo ""
        echo -n "Enter end date (Format YYYY-MM-DD): "
        read startDate
    done

    #gfind $folder -type f -newermt $startDate ! -newermt $endDate -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort | cut -f 2- -d ' '

    #find . -type f -newermt 2015-10-01 ! -newermt 2015-12-09 -exec stat -f "%Sp %Su %Sg %z %t%Sm %N %t MD5: " {} \; md5 {} \; | cut -f 2- -d '='

    # Run find with the users input. While loop reads in the returned files while handling if we run into spaces in the file name 
    find $folder -type f -newermt $startDate ! -newermt $endDate -print0 | while read -d $'\0' file; do
        #echo $file
        # Run stat on each file returned then format the results.
        # stat format translaton: Permissions, User ID, Group ID, Size (bytes), Time Modified, Name
        stat -f "%Sp %Su %Sg %z %t%Sm %N" "$file"
        # Calculate MD5 hash of retuned files.
        echo "MD5: $(md5 "$file"| cut -f 2- -d '=')"
        echo ""
    done
}





function LINUX {
    echo "***********************"
    echo "** File Search Linux **"
    echo "***********************"

    echo -n "Enter a folder to scan: "
    read folder
    while [ ! -d "$folder" ]; do
        echo "ERROR. Invalid directory."
        echo ""
        echo -n "Enter a folder to scan: "
        read folder
    done

    echo -n "Enter start date (Format YYYY-MM-DD): "
    read startDate
    while [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo "ERROR. Invalid date format."
        echo ""
        echo -n "Enter start date (Format YYYY-MM-DD): "
        read startDate
    done

    echo -n "Enter end date (Format YYYY-MM-DD): "
    read endDate
    while [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo "ERROR. Invalid date format."
        echo ""
        echo -n "Enter end date (Format YYYY-MM-DD): "
        read startDate
    done

    while read -r file; do
        #echo $file
        # Run stat on each file returned then format the results.
        # stat format translaton: Permissions, User ID, Group ID, Size (bytes), Time Modified, Name
        stat -c "%A %U %G %s %y %n" "$file"
        # Calculate MD5 hash of retuned files.
        echo "MD5: $(md5sum "$file"| cut -f 2- -d ' ')"
        echo ""
    done < <(find $folder -type f -newermt $startDate ! -newermt $endDate)

}

function sha1Search {
    echo "***********************"
    echo "*** Search For sha1 ***"
    echo "***********************"
    echo "" 
    echo ""
    echo -n "Enter Hash:"
    read shaHash
    echo -n "Speed up search? - [Y/n]"
    read answer
    if [ "$answer" = "n" ]; then
        echo "Searching..."
        echo ""
        echo ""
        find / -type f -exec /usr/bin/openssl sha1 {} \; | grep ${shaHash}
    else 
        echo -n "Enter Seach Folder: "
        read shaFolder

        while [ ! -d "$shaFolder" ]; do
            echo "ERROR. Invalid directory."
            echo ""
            echo -n "Enter Seach Folder: "
            read shaFolder
        done


        echo -n "Know file size? (bytes) - [y/N]"
        read shaSizeAnswer

        if [ "$shaSizeAnswer" = "y" ]; then
            echo -n "Enter file size: "
            read shaSize
            shaSize="-size ${shaSize}c"
            #echo $shaSize
        fi

        echo "Searching..."
        find $shaFolder -type f $shaSize -exec /usr/bin/openssl sha1 {} \; | grep ${shaHash}
    fi





}

selection=
until [ "$selection" = "0" ]; do
    clear
    echo "*****************"
    echo "** File Finder **"
    echo "*****************"
	echo ""
	echo "This program will search a given folder for files created within a specific date."
	echo "The date format is YYYY-MM-DD. Optionally time can be specifed by YYYY-MM-DD 00-00-00"
	echo ""
    echo ""
    echo "MAIN MENU"
    echo "1 - Search on OS X"
    echo "2 - Search on Linux"
    echo "3 - Search for sha1 hash"
    echo ""
    echo "0 - exit program"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
    	1 ) clear; OS_X ; press_enter ;;
        2 ) clear; LINUX ; press_enter ;;
        3 ) clear; sha1Search ; press_enter ;;
        0 ) exit ;;
        * ) echo "Please enter 1, 2, or 0"; press_enter
    esac
done
