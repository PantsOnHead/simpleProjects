#!/bin/bash

function PRESS_ENTER {
    echo -en "\nPress Enter to continue"
    read
    clear
}

function DATE_TIME_SEARCH {
    echo "*************************"
    echo "** File search by date **"
    echo "*************************"

    echo -n "Enter a folder to scan: "
    read folder
    while [ ! -d "${folder}" ]; do
        echo -e "ERROR. Invalid directory.\n"
        echo -n "Enter a folder to scan: "
        read folder
    done

    echo -n "Enter start date (Format YYYY-MM-DD): "
    read startDate
    while [[ ! "${startDate}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! "${startDate}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo -e "ERROR. Invalid date format.\n"
        echo -n "Enter start date (Format YYYY-MM-DD): "
        read startDate
    done

    echo -n "Enter end date (Format YYYY-MM-DD) [Default: $(date +%Y-%m-%d)]: "
    read endDate

    while [ "${endDate}" != "" ] && [[ ! "${startDate}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! "${startDate}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; do
        echo -e "ERROR. Invalid date format.\n"
        echo -n "Enter end date (Format YYYY-MM-DD) [Default: $(date +%Y-%m-%d)]: "
        read endDate
    done
    # If no input then grab current system time. 
    if [ "${endDate}" = "" ]; then
        endDate=$(date +%Y-%m-%d)
    fi       

    while read -r file; do
        #echo $file
        # Run stat on each file returned then format the results.
        # stat format translaton: Permissions, User ID, Group ID, Size (bytes), Time Modified, Name
        # then calculate md5 hash for each file returned

        if [ ${is_GNU} ]; then
            stat -c "%A %U %G %s %y %n" "${file}"
            echo -e "MD5: $(md5sum "${file}"| cut -f 2- -d ' ')\n"
        else
            stat -f "%Sp %Su %Sg %z %t%Sm %N" "$file"
            echo -e "MD5: $(md5 "$file"| cut -f 2- -d '=')\n"
        fi
    done < <(find ${folder} -type f -newermt $startDate ! -newermt $endDate 2>/dev/null)

}

function SHA1_SEARCH {
    echo "***********************"
    echo "*** Search For sha1 ***"
    echo -e "***********************\n\n"
    echo -n "Enter Hash:"
    read shaHash
    echo -n "Speed up search? - [Y/n]"
    read answer
    if [ "$answer" = "n" ]; then
        echo -e "Searching...\n\n"
        find / -type f -exec /usr/bin/openssl sha1 {} \; 2>/dev/null | grep ${shaHash}
    else 
        echo -n "Enter Seach Folder: "
        read shaFolder

        while [ ! -d "$shaFolder" ]; do
            echo -e "ERROR. Invalid directory.\n"
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
        find $shaFolder -type f $shaSize -exec /usr/bin/openssl sha1 {} \; 2>/dev/null | grep ${shaHash}
    fi





}

# Detect whether we are running GNU or BSD coreutils.
# credit: http://unix.stackexchange.com/questions/104098/in-shell-config-scripts-how-can-i-account-for-differences-between-coreutils-on
if stat --version 2>/dev/null | grep -q 'coreutils'; then
    is_GNU=true
else
    is_GNU=false
fi


selection=
until [ "$selection" = "0" ]; do
    clear
    echo "*****************"
    echo "** File Finder **"
    echo -e "*****************\n"
	echo "This program will search a given folder for files created within a specific date."
	echo "The date format is YYYY-MM-DD. Optionally time can be specifed by YYYY-MM-DD 00-00-00\n\n"
    echo "MAIN MENU"
    echo "1 - Search by Date / Time"
    echo -e "2 - Search by sha1 hash\n"
    echo -e "0 - exit program\n"
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
    	1 ) clear; DATE_TIME_SEARCH ; PRESS_ENTER ;;
        2 ) clear; SHA1_SEARCH ; PRESS_ENTER ;;
        0 ) exit ;;
        * ) echo "Please enter 1, 2, or 0"; PRESS_ENTER
    esac
done
