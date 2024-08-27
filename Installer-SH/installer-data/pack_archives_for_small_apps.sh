#!/usr/bin/env bash
# This Script part of "Installer-SH"

Path_To_Script="$( dirname "$(readlink -f "$0")")"
Spacer="\n ===========================================\n ===========================================\n ==========================================="

Folders_to_Archive=(
"program_files"
"system_files"
"user_files"
)

for foldername in "${!Folders_to_Archive[@]}"; do
	Current="${Folders_to_Archive[$foldername]}"
	if [ -e "$Current" ]; then
		echo -e "$Spacer"
		"$Path_To_Script/tools/7zip/7zzs" a -snl -mx9 -m0=LZMA:d32m "$Current.7z" "$Path_To_Script/$Current/."
		MD5_DATA=`md5sum "$Path_To_Script/$Current.7z" | awk '{print $1}'`
		echo "$MD5_DATA" > "$Path_To_Script/$Current-md5.txt"
	fi
done

echo -e "$Spacer"
echo -e "\n Pause..."
read pause

# MIT License
#
# Copyright (c) 2024 Chimbal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
