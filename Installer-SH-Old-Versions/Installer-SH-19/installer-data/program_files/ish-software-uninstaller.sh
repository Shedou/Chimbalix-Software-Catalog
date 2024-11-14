#!/usr/bin/env bash
# Script version 1.6
# LICENSE for this script is at the end of this file
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
Path_To_Script="$( dirname "$(readlink -f "$0")")" # Current installer script directory.
User_Dir=~ # Current User home directory.
arg1="$1"
# Font styles: "${Bold} BLACK TEXT ${rBD} normal text."
Bold="\e[1m"; Dim="\e[2m"; rBD="\e[22m";
# Font Colors:
F='\033[39m'; BG='\033[49m'; # Reset colors
F_Black='\033[30m'; F_DarkGray='\033[90m'; F_Gray='\033[37m'; F_White='\033[97m';
F_DarkRed='\033[31m'; F_DarkGreen='\033[32m'; F_DarkYellow='\033[33m'; F_DarkBlue='\033[34m'; F_DarkMagenta='\033[35m'; F_DarkCyan='\033[36m';
F_Red='\033[91m'; F_Green='\033[92m'; F_Yellow='\033[93m'; F_Blue='\033[94m'; F_Magenta='\033[95m'; F_Cyan='\033[96m';
BG_Black='\033[40m'; BG_DarkGray='\033[100m'; BG_Gray='\033[47m'; BG_White='\033[107m';
BG_DarkRed='\033[41m'; BG_DarkGreen='\033[42m'; BG_DarkYellow='\033[43m'; BG_DarkBlue='\033[44m'; BG_DarkMagenta='\033[45m'; BG_DarkCyan='\033[46m';
BG_Red='\033[101m'; BG_Green='\033[102m'; BG_Yellow='\033[103m'; BG_Blue='\033[104m'; BG_Magenta='\033[105m'; BG_Cyan='\033[106m';
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##

Current_DE="$XDG_SESSION_DESKTOP"
Header="${F_Red}${Bold} -=: Software Uninstaller Script (Installer-SH v1.8) :=-${rBD}${F}\n"
printf '\033[8;30;110t' # Resize terminal Window

# Welcome message
clear
echo -e "$Header"

if_sudo=false

function _remove {
	local file="$1"
	if [ -e "$file" ]; then
		echo -ne "Removing: $file"
		if [ $if_sudo == false ]; then
			if rm -rf "$file"; then
				echo -ne " - ok.\n"
			else
				echo -ne "\n ${F_Yellow}${Bold}Need root rights... Try with sudo.${rBD}${F}\n"
				if sudo rm -rf "$file"; then if_sudo=true; fi
			fi
		else 
			if sudo rm -rf "$file"; then echo -ne " - ok.\n"
			else echo -e " Something went wrong..."; fi
		fi
	else
		echo -e "Object not found, skip:\n $file"
	fi
}

FilesToDelete=(
)

# Display info and wait confirmation
echo -e "\
 ${Bold}${F_Yellow}Attention!${F}${rBD} Make sure that you do not have any important data in the program directory!
 
 ${Bold}The listed files and directories will be deleted if they are present in the system!${rBD}"

echo -e "${Bold} - Files to be deleted:${rBD}"
for i in "${!FilesToDelete[@]}"; do echo "   ${FilesToDelete[$i]}"; done

echo -e "\n Enter \"${Bold}y${rBD}\" or \"${Bold}yes${rBD}\" to begin uninstallation."
Confirm=""
read Confirm

# Run if confirm
if [ "$Confirm" == "y" ] || [ "$Confirm" == "yes" ]; then
	for i in "${!FilesToDelete[@]}"; do _remove "${FilesToDelete[$i]}"; done
	if [ "$Current_DE" == "xfce" ]; then xfce4-panel -r &> /dev/null; fi
	echo -e "\n ${Bold}${F_Green}Uninstallation completed.${F}${rBD}\n"
fi

echo " Press Enter to exit or close this window."
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
