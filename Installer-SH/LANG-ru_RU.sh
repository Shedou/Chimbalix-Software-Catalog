#!/usr/bin/env bash

Path_To_Script="$( dirname "$(readlink -f "$0")")"

Exe_File_Name="$Path_To_Script/install.sh"

if ! [[ -x "$Exe_File_Name" ]]; then
	if ! chmod +x "$Exe_File_Name"; then echo " chmod error."; fi
fi

env LANG=ru_RU.UTF-8 "$Path_To_Script/install.sh"
