#!/bin/bash
# needs a Windows installation of 7-zip
# set -x
test -e /mnt/c/Program\ Files/7-Zip/7z.exe || {
	echo >&2  "This script requires the 7-zip program for Windows"
	echo
	while true; do
		read -p "Do you wish to download the program installer?" yn
		case $yn in
			[Yy]* ) wget -O 7z1900.exe https://sourceforge.net/projects/sevenzip/files/latest/download
			echo "Install 7-zip and re-run the script"
			break;;
			[Nn]* ) echo "Install 7-zip and re-run the script"
			exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
	exit 1;
	}

if [ $(ls  -1 *.fwbackup 2>/dev/null |wc -l) != 1 ] ; then
	echo >&2  $(basename $0) "requires exactly one fwbackup file in this directory"
	echo >&2 "It found:"
	ls  -1 *.fwbackup 2>/dev/null
	exit
fi

backupfile=$(ls  -1 *.fwbackup)
echo "Processing '$backupfile'"
fwdatafile=$(/mnt/c/Program\ Files/7-Zip/7z.exe l "$backupfile" 2>/dev/null | dos2unix | cut -c54- | grep fwdata)
echo "found '$fwdatafile'"
/mnt/c/Program\ Files/7-Zip/7z.exe x -y -bso2 -bsp2 -bse2 "$backupfile" "$fwdatafile" 2>/dev/null 
echo "Found & extracted '$fwdatafile' "
barefname=${fwdatafile%.fwdata}

# echo "barefname $barefname fwdatafile $fwdatafile"
mv "$fwdatafile" "$barefname-before.fwdata"
mv PromoteSubentries.ini  PromoteSubentries.bak
perl -pE "s/FwdataIn.*/FwdataIn=$barefname-before.fwdata/; s/FwdataOut.*/FwdataOut=$fwdatafile/" PromoteSubentries.bak > PromoteSubentries.ini
./Var2Compform.pl
/mnt/c/Program\ Files/7-Zip/7z.exe u "$backupfile" "$fwdatafile"  2>/dev/null 
exit
