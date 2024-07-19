#!/bin/bash
# set -x
# ignore the initial backup file
ignore="${ignore:-Initial}"
if [ $(ls  -1 *.{fwbackup,zip} 2>/dev/null |grep -v $ignore |wc -l) != 1 ] ; then
	echo >&2 "This script requires exactly one fwbackup/zip file in this directory"
	echo >&2 "It ignores all files with \"$ignore\" in the file name"
	echo >&2 "It found:"
	ls  -1 *.{fwbackup,zip} 2>/dev/null | grep -v $ignore | sed -e 's/^/     /'
	if [ "$0" != "$BASH_SOURCE" ]; then # if the file is sourced, don't just exit
		echo "Ctrl-C to break, Enter to leave WSL"; read
		fi
	exit
fi

backupfile=$(ls  -1 *.{fwbackup,zip} 2>/dev/null  |grep -v $ignore)
echo "Processing '$backupfile'"
fwdatafile=$(unzip -l  "$backupfile" 2>/dev/null | dos2unix | cut -c31- | grep fwdata)
echo "found '$fwdatafile'"
unzip -o "$backupfile" "$fwdatafile"
echo "Found & extracted '$fwdatafile' "
barefname=${fwdatafile%.fwdata}
# echo "barefname $barefname fwdatafile $fwdatafile"
mv "$fwdatafile" "$barefname-before.fwdata"

mv Var2Compform.ini  PromoteSubentries.bak
perl -pE "s/FwdataIn.*/FwdataIn=$barefname-before.fwdata/; s/FwdataOut.*/FwdataOut=$fwdatafile/" PromoteSubentries.bak > Var2Compform.ini
./Var2Compform.pl >Var2Compform-log.txt
echo A log of the changes made is available in Var2Compform-log.txt
zip "$backupfile" "$fwdatafile"  # 2>/dev/null
echo
rm "$fwdatafile" "$barefname-before.fwdata"
echo "Work files \"$fwdatafile\" & \"$barefname-before.fwdata\" have been deleted"
mv PromoteSubentries.bak Var2Compform.ini
echo
echo "The file \"$fwdatafile\" inside \"$backupfile\" has been corrected."
