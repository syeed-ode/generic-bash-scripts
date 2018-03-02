#!/bin/bash

ORIGINAL_DIRECTORY=
BACKUP_DIRECTORY=
HISTORY_TRACKER=
LOGGER=
TEMINATOR=${ORIGINAL_DIRECTORY}/endLoop.txt

pullFilesAfter=$(cat $HISTORY_TRACKER)
echo "Starting with $pullFilesAfter"
cd "$ORIGINAL_DIRECTORY"


for i in $(ls -lsarth $(find . -type f -mnewer $pullFilesAfter)  2>/dev/null | grep -vi "endLoop" | sed -e 's/\.\///' | grep -v " \." | awk '{print $9"|"$10}')
do
	echo "${i}"
	fileTime=$(echo $i | sed -e 's/\([^:]*\):\([^|]*\).*/\1\2/')
	originalFileName=$(echo $i | sed -e 's/\([^:]*\):\([^|]*\)|\(.*\)/\3/')
	originalFileNameDate=$(echo $originalFileName | sed -e 's/\([^_]*\)_\(.*\)/\1/')
	newFileName=$(echo $originalFileName | sed -e 's/\([^_]*\)_\(.*\)/\2/')
	permenantFileName=${BACKUP_DIRECTORY}/${originalFileNameDate}"_"${fileTime}"_"${newFileName}
	cp -p ${originalFileName} ${permenantFileName}
	
	if [ -f ${permenantFileName} ] 
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
done

touch "$TEMINATOR"
echo "Ended up with this file ${permenantFileName}"

