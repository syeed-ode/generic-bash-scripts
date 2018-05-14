#!/bin/bash

# 			fileTagger
# Backsup critical files with and adds time of file creation
# to the backup file.
# 


ORIGINAL_DIRECTORY=
BASE_DIRECTORY=
BACKUP_DIRECTORY=${BASE_DIRECTORY}/directoryOfImportance
# Used to determine the next file to back up
HISTORY_TRACKER=${BASE_DIRECTORY}/lastFile.txt
LOGGER=${BASE_DIRECTORY}/logger.log
# Used to assure all files are grabbed, even if there are no 
# files in the directory
TEMINATOR=${ORIGINAL_DIRECTORY}/endLoop.txt

pullFilesAfter=$(cat $HISTORY_TRACKER)
echo "Starting with $pullFilesAfter"
cd "$ORIGINAL_DIRECTORY"


function partition_filename_segments() {
	# fileTime=$(echo $i | sed -e 's/\([^:]*\):\([^|]*\).*/\1\2/')
	# This line is broken out for readability it could have been written as
	#		fileTime=${i%|?*/:/}
	fileTimeWithColon=${i%|?*} # 12:52
	fileTime=${fileTimeWithColon/:/}
	#	echo $fileTime
	# 1252


	# originalFileName=$(echo $i | sed -e 's/\([^:]*\):\([^|]*\)|\(.*\)/\3/')
	originalFileName=${i#?*|}
	#	echo "This is the originalFileName: $originalFileName"
	# 20180505_fileName.m4a


	# originalFileNameDate=$(echo $originalFileName | sed -e 's/\([^_]*\)_\(.*\)/\1/')
	originalFileNameDate=${originalFileName%_?*}
	echo $originalFileNameDate
	# 20180505


	# newFileName=$(echo $originalFileName | sed -e 's/\([^_]*\)_\(.*\)/\2/')
	newFileName=${originalFileName#?*_}
	#	echo $newFileName
	# fileName.m4a
}

function copy_file_if_required() {
	existingFilesFromPreviousCopy=$(ls -l ${BACKUP_DIRECTORY} | grep ${newFileName} | grep ${originalFileNameDate})
	bypassCopyFileAlreadyExits="$?"
	if [ $bypassCopyFileAlreadyExits == "0" ] 
	then
		# the -e option interprets the LINEFEED and tab
		echo -e "### Some variant of ${originalFileName} exists will not execute copy: \n###\t ${existingFilesFromPreviousCopy}"
	else
		permenantFileName=${BACKUP_DIRECTORY}/${originalFileNameDate}"_"${fileTime}"_"${newFileName}
		cp -p ${originalFileName} ${permenantFileName}
	fi
}

function log_execution_status() {
	if [ $bypassCopyFileAlreadyExits == "0" ] 
	then
		echo "These files already existed: $existingFilesFromPreviousCopy"
		echo "Did not copy ${originalFileName}"
		echo "These files already existed: $existingFilesFromPreviousCopy" >> $LOGGER
		echo "Did not copy ${originalFileName}" >> $LOGGER
	elif [ -f ${permenantFileName} ] 
	then
		echo "Copied file ${originalFileName} to ${permenantFileName}"
		echo "Copied file ${originalFileName} to ${permenantFileName}" >> $LOGGER
		echo ${originalFileName} > $HISTORY_TRACKER
		echo "Dumping $originalFileName into $HISTORY_TRACKER"
		echo "Dumping $originalFileName into $HISTORY_TRACKER" >> $LOGGER 
	else
		echo "Had a problem with file ${permenantFileName}"
		echo "Had a problem with file ${permenantFileName}" >> $LOGGER
	fi
}



for i in $(ls -lsarth $(find . -type f -mnewer $pullFilesAfter)  2>/dev/null | grep -vi "endLoop" | sed -e 's/\.\///' | grep -v " \." | awk '{print $9"|"$10}')
do
	echo "${i}"
	# 12:52|20180505_conversationFromTheVaults.m4a
	
	partition_filename_segments

	copy_file_if_required
	
	log_execution_status
done

touch "$TEMINATOR"
echo "Ended up with this file ${permenantFileName}"


