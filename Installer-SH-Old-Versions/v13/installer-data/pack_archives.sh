#!/usr/bin/env bash
# Script version 1.0

Path_To_Script="$( dirname "$(readlink -f "$0")")"
Spacer="\n ===========================================\n ===========================================\n ==========================================="

Folders_to_Archive=(
"program_files"
"system_files"
"user_files"
)

for foldername in "${!Folders_to_Archive[@]}"; do
	echo -e "$Spacer"
	Current="${Folders_to_Archive[$foldername]}"
	"$Path_To_Script/tools/7zip/7zzs" a -snl "$Current.7z" "$Path_To_Script/$Current/."
	MD5_DATA=`md5sum "$Path_To_Script/$Current.7z" | awk '{print $1}'`
	echo "$MD5_DATA" > "$Path_To_Script/$Current-md5.txt"
done

echo -e "$Spacer"
echo -e "\n Pause..."
read pause
