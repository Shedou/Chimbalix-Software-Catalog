#!/usr/bin/env bash
# Script version 1.2
# LICENSE for this script is at the end of this file
#
# FOR DEVELOPERS:
#  1) Please check the "installer-data" directory, it contains the files necessary to create
#     items in the Start menu and the uninstaller template.
#
#  2) Do not use standard Linux categories to place menu shortcuts, they may change
#     with OS updates, their use is only valid for embedded software and compatibility reasons,
#     for new regular software use only the "apps" section, thanks.
#
#
#FreeSpace=$(df -m "$Out_InstallDir" | grep "/" | awk '{print $4}')
#if (( FreeSpace < InfoReqFreeDiskSpace )); then
#
### $(for file in "${!Files_Bin_Dir[@]}"; do echo "   > ${Files_Bin_Dir[$file]}"; done)
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
Path_To_Script="$( dirname "$(readlink -f "$0")")" # Current installer script directory.
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
#### ---- -------- ---- ####
#### ---- SETTINGS ---- ####
#### ---- -------- ---- ####

Install_Mode="User" # "System" wide / Current "User" only
User_Dir=~ # Current User home directory.

### - ------------------- - ###
### - Package Information - ###

Header="${BG_Black}${F_Red}${Bold} -=: Software Installer Script for Chimbalix :=-${rBD}${F}\n"

Archive_File="$Path_To_Script/installer_data.7z"
MD5_Hash_Of_Archive="c1b04004eba3552a0c9bdcc55082a7df" # Basic archive integrity check.

Info_Name="Example Application"
Info_Version="v1.2"
Info_Category="Image Editor (Example)"
Info_Platform="Linux - Chimbalix 24.2 - 24.x"
Info_Installed_Size="~1 MiB"
Info_Licensing="\
Freeware - Open Source (MIT)
   Other Licensing Examples:
    Freeware - Proprietary (EULA)
    Trialware - 30 days free, Proprietary (Other License Name)
    AdWare - Proprietary (New License Name)"
Info_Developer="Chimbal"
Info_URL="\n   https://github.com/Shedou/Chimbalix-Software-Catalog\n   https://github.com/Shedou/Chimbalix"
Info_Description="\
  1) This installer allows you to:
     - Storing program installation files in a 7-zip archive (good compression).
     - Install the application in the standard \"portsoft\" directory.
     - Two installation modes:
       . System - you need root rights to install.
       . User - install only for the current User ($USER), does not require root rights.
     - Set owner and rights to the application directory (only in \"System\" mode).
  2) Check the current \"install.sh\" file to configure the installation package."

### - ---------------- - ###
### - Install Settings - ###

Output_App_Folder_Name="example_application_v12"
Output_App_Folder_Owner=root:root	# username:group, only for "System" mode.
Output_App_Folder_Permissions=777	# Only for "System" mode.
Output_System_Install_Dir="/portsoft/x86_64/$Output_App_Folder_Name"
Output_User_Install_Dir="$User_Dir/.local/portsoft/x86_64/$Output_App_Folder_Name"
Output_User_Home="$User_Dir"

Installer_Archive_Mount_Dir="/tmp/$Output_App_Folder_Name""_MOUNT"
Temp_Dir="/tmp/$Output_App_Folder_Name""_TEMP"

 # WARNING! Don't edit if you don't understand what you're doing:
Input_App_Dir="$Installer_Archive_Mount_Dir/application"
Input_Bin_Dir="$Installer_Archive_Mount_Dir/installer-data/bin" # Used only in "System" install mode...

User_Data_Copy_Confirm=false
Input_User_Data="$Installer_Archive_Mount_Dir/USER_HOME" # The content will be copied to the user's home directory. Better not to use this... DO NOT USE UNLESS VERY NECESSARY!

Input_Menu_Files_Dir="$Installer_Archive_Mount_Dir/installer-data/menu/applications-merged"
Input_Menu_Desktop_Dir="$Installer_Archive_Mount_Dir/installer-data/menu/desktop-directories/apps"
Input_Menu_Apps_Dir="$Installer_Archive_Mount_Dir/installer-data/menu/apps"

Input_Uninstaller="$Installer_Archive_Mount_Dir/installer-data/uninstall.sh" # Uninstaller template file.


 # Other outputs:
User_Bin_Dir="$User_Dir/.local/bin" # Works starting from Chimbalix 24.4
User_Menu="$User_Dir/.config/menus/applications-merged"
User_Menu_Dir="$User_Dir/.local/share/desktop-directories"
User_Menu_AppsDir="$User_Dir/.local/share/applications/apps"

System_Bin_Dir="/usr/bin"
System_Menu="/etc/xdg/menus/applications-merged"
System_Menu_Dir="/usr/share/desktop-directories"
System_Menu_AppsDir="/usr/share/applications/apps"


Output_Install_Dir="DON'T CHANGE!"
Output_Bin_Dir="DON'T CHANGE!"
Output_Menu="DON'T CHANGE!"
Output_Menu_Dir="DON'T CHANGE!"
Output_Menu_AppsDir="DON'T CHANGE!"

if [ "$Install_Mode" == "System" ]; then
	Output_Install_Dir="$Output_System_Install_Dir"
	Output_Bin_Dir="$System_Bin_Dir"
	Output_Menu="$System_Menu"
	Output_Menu_Dir="$System_Menu_Dir"
	Output_Menu_AppsDir="$System_Menu_AppsDir"
else
	Output_Install_Dir="$Output_User_Install_Dir"
	Output_Bin_Dir="$User_Bin_Dir"
	Output_Menu="$User_Menu"
	Output_Menu_Dir="$User_Menu_Dir"
	Output_Menu_AppsDir="$User_Menu_AppsDir"
	Output_System_Bin_Dir="NOT USED IN User INSTALLATION MODE"
fi


###  Make sure the following files are properly prepared according to the application.
#  All files listed here will be modified according to the installation path of the application,
#  you must take care to correctly use the "PATH_TO_FOLDER" variable inside the files.
# The "PATH_TO_FOLDER" variable points to the application installation directory without the trailing slash, for example "/portsoft/x86_64/example-application".


 # Desktop shortcut files:
 ## Copy files from "Template_Menu_Files_Dir" to "/etc/xdg/menus/applications-merged/" or "/home/USER_NAME/.config/menus/applications-merged/"
 ## Copy files from "Template_Menu_Desktop_Dir" to "/usr/share/desktop-directories/apps/" or "/home/USER_NAME/.local/share/desktop-directories/apps/"

all_ok=true

#### -- ------------ -- ####
#### -- END SETTINGS -- ####
#### -- ------------ -- ####

#### ---- --------- ---- ####
#### ---- FUNCTIONS ---- ####
#### ---- --------- ---- ####

### Abort function ###
function _ABORT() {
	clear
	echo -e "\
$Header
  The installation was interrupted, press Enter or close the window to exit.
  Abort message: $1"
	_UNMOUNT_ARCHIVE
	read pause; clear; exit 1 # Double clear resets styles before going to the system terminal window.
}

###
###
### Main functions
###
###

### -------------------------
### Print package information
function _PRINT_PACKAGE_INFO() {
if [ all_ok == true ]; then
	all_ok=false
	echo -e "${BG_Black}"; clear; # A crutch to fill the background completely...
	echo -e "\
$Header
 ${Bold}${F_Cyan}Software Info:${F}${rBD}
 -${Bold}${F_DarkYellow}Name:${F} $Info_Name${rBD} ($Info_Version)
 -${Bold}${F_DarkYellow}Category:${rBD}${F} $Info_Category
 -${Bold}${F_DarkYellow}Platform:${rBD}${F} $Info_Platform
 -${Bold}${F_DarkYellow}Installed Size:${rBD}${F} $Info_Installed_Size
 -${Bold}${F_DarkYellow}Licensing:${rBD}${F} $Info_Licensing
 -${Bold}${F_DarkYellow}Developer:${rBD}${F} $Info_Developer
 -${Bold}${F_DarkYellow}URL:${rBD}${F} $Info_URL
 -${Bold}${F_DarkYellow}Description:${F}${rBD}
$Info_Description"
	echo -e "\n Start the application installation process? Enter \"y\" or \"yes\" to confirm."
	read package_info_confirm
	if [ "$package_info_confirm" == "y" ] || [ "$package_info_confirm" == "yes" ]; then all_ok=true
	else _ABORT "Interrupted by user"; fi
else _ABORT "STAGE Print Package Info"; fi
}

### ---------------------------
### Print installation settings
function _PRINT_INSTALL_SETTINGS() {
if [ all_ok == true ]; then
	all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Installation settings:${F}${rBD}
 -${Bold}${F_DarkGreen}Current OS:${F} $Distro_Full_Name${rBD}
 -${Bold}${F_DarkGreen}Installation Mode:${F} $Install_Mode${rBD}

 -${Bold}${F_DarkGreen}Mount Directory:${F}${rBD} $Installer_Archive_Mount_Dir
 -${Bold}${F_DarkGreen}Temp Directory:${F}${rBD} $Temp_Dir
 
 -${Bold}${F_DarkGreen}Application install Directory:${F}${rBD} $Output_Install_Dir
 
 -${Bold}${F_DarkGreen}The \"Start\" menu files will be installed to:${F}${rBD}
   $Output_Menu
   $Output_Menu_AppsDir
   $Output_Menu_Dir
 -${Bold}${F_DarkGreen}Install Bin shortcuts to:${F}${rBD} $Output_System_Bin_Dir
 -${Bold}${F_DarkGreen}Set user data (if present) to:${F}${rBD} $Output_User_Home

 Please close all important applications before installation.
"
	if [ "$Distro_Name" != "Chimbalix" ]; then
		echo -e "${Bold}${F_Red} WARNING! DO NOT INSTALL THE APPLICATION ON OTHER LINUX DISTRIBUTIONS!\n THIS MAY CAUSE ERRORS OR HARM TO THE SYSTEM!${F}${rBD}"
	fi
	
	echo -e "\n Start installation? Enter \"y\" or \"yes\" to confirm."
	read install_settings_confirm
	if [ "$install_settings_confirm" == "y" ] || [ "$install_settings_confirm" == "yes" ]; then all_ok=true
	else _ABORT "Interrupted by user"; fi
else _ABORT "STAGE Print Install Settings"; fi
}

### -------------------
### Install application
function _INSTALL_APP() {
if [ all_ok == true ]; then
	all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Installing...${F}${rBD}"
	
### System MODE ###
	if [ "$Install_Mode" == "System" ]; then
		# Copy Application files
		echo " Copy application files..."
		echo "  from: $Input_App_Dir"
		echo "  to: $Output_Install_Dir"
		sudo mkdir -p "$Output_Install_Dir"
		sudo cp -rf "$Input_App_Dir/." "$Output_Install_Dir"
		echo " Set rights and owner..."
		chmod -R $Output_App_Folder_Permissions "$Output_Install_Dir"
		chown -R $Output_App_Folder_Owner "$Output_Install_Dir"
		
		# Prepare and copy Bin files
		echo " Prepare and copy Bin files..."
		echo "  from: $Input_Bin_Dir"
		echo "  to: $Output_Bin_Dir"
		mkdir "$Temp_Dir"
		cp -rf "$Input_Bin_Dir/." "$Temp_Dir"
		for file in "$Temp_Dir"/*; do sed -i -e "s~PATH_TO_FOLDER~$Output_Install_Dir~g" "$file"; done
		sudo cp -rf "$Temp_Dir/." "$Output_Bin_Dir"
		rm -rf "$Temp_Dir"
		
		# Prepare and copy Menu files
		echo " Prepare and copy Menu Apps files..."
		echo "  from: $Input_Menu_Apps_Dir"
		echo "  to: $Output_Menu_AppsDir"
		mkdir "$Temp_Dir"
		cp -rf "$Input_Menu_Apps_Dir/." "$Temp_Dir"
		for file in "$Temp_Dir"/*; do grep -rl "PATH_TO_FOLDER" "$Temp_Dir" | xargs sed -i 's/PATH_TO_FOLDER/$Output_Install_Dir/g'; done
		sudo cp -rf "$Temp_Dir/." "$Output_Menu_AppsDir"
		rm -r "$Temp_Dir"
		echo " Copy Menu files..."
		echo "  from: $Input_Menu_Files_Dir"
		echo "  to: $Output_Menu"
		sudo cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu"
		echo " Copy Menu Dir files..."
		echo "  from: $Input_Menu_Desktop_Dir"
		echo "  to: $Output_Menu_Dir"
		sudo cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_Dir"
		
		# Copy user data
		if [ $User_Data_Copy_Confirm == true ]; then
			echo " Copy User files..."
			echo "  from: $Input_User_Data"
			echo "  to: $Output_User_Home"
			cp -rf "$Input_User_Data/." "$Output_User_Home"
		fi
		
		# Restart taskbar
		echo "Restart taskbar..."
		xfce4-panel -r
		echo -e "\nThe installation process has ended!"
	fi


### User MODE ###
	if [ "$Install_Mode" == "User" ]; then
		# Copy Application files
		echo " Copy application files..."
		echo "  from: $Input_App_Dir"
		echo "  to: $Output_Install_Dir"
		mkdir -p "$Output_Install_Dir"
		cp -rf "$Input_App_Dir/." "$Output_Install_Dir"
		echo " Set rights and owner..."
		
		# Prepare and copy Bin files
		echo " Prepare and copy Bin files..."
		echo "  from: $Input_Bin_Dir"
		echo "  to: $Output_Bin_Dir"
		mkdir "$Temp_Dir"
		cp -rf "$Input_Bin_Dir/." "$Temp_Dir"
		for file in "$Temp_Dir"/*; do sed -i -e "s~PATH_TO_FOLDER~$Output_Install_Dir~g" "$file"; done
		cp -rf "$Temp_Dir/." "$Output_Bin_Dir"
		rm -rf "$Temp_Dir"
		
		# Prepare and copy Menu files
		echo " Prepare and copy Menu Apps files..."
		echo "  from: $Input_Menu_Apps_Dir"
		echo "  to: $Output_Menu_AppsDir"
		mkdir "$Temp_Dir"
		cp -rf "$Input_Menu_Apps_Dir/." "$Temp_Dir"
		for file in "$Temp_Dir"/*; do grep -rl "PATH_TO_FOLDER" "$Temp_Dir" | xargs sed -i 's/PATH_TO_FOLDER/$Output_Install_Dir/g'; done
		cp -rf "$Temp_Dir/." "$Output_Menu_AppsDir"
		rm -r "$Temp_Dir"
		echo " Copy Menu files..."
		echo "  from: $Input_Menu_Files_Dir"
		echo "  to: $Output_Menu"
		cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu"
		echo " Copy Menu Dir files..."
		echo "  from: $Input_Menu_Desktop_Dir"
		echo "  to: $Output_Menu_Dir"
		cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_Dir"
		
		# Copy user data
		if [ $User_Data_Copy_Confirm == true ]; then
			echo " Copy User files..."
			echo "  from: $Input_User_Data"
			echo "  to: $Output_User_Home"
			cp -rf "$Input_User_Data/." "$Output_User_Home"
		fi
		
		# Restart taskbar
		echo "Restart taskbar..."
		xfce4-panel -r
		echo -e "\nThe installation process has ended!"
	fi
	read pause;
else _ABORT "STAGE Install Application"; fi
}

function _CHECK_OUTPUTS() {
if [ all_ok == true ]; then
	all_ok=false
	read pause
	local error=false
	local arr_files_sorted=()
	
	for file in "${!All_Files[@]}"; do if [ -e "${All_Files[$file]}" ]; then arr_files_sorted[$file]="${All_Files[$file]}"; error=true; fi; done
	for file in "${!Filled_User_Files[@]}"; do if [ -e "${Filled_User_Files[$file]}" ]; then arr_files_sorted[$file]="${Filled_User_Files[$file]}"; error=true; fi; done
	
	if [ $error == true ]; then
		clear
		echo -e "\
$Header
 ${Bold}${F_Cyan}WARNING!${F}${rBD}"
		if [ $User_Data_Copy_Confirm == true ]; then
			echo "WARNING! Copying data to the user directory is enabled!"
		fi
		echo -e "\
  Folders|Files already present:
$(for file in "${!arr_files_sorted[@]}"; do echo "   ${arr_files_sorted[$file]}"; done)"
		echo -e "\

  Continue installation and overwrite directories/files?
  Please make a backup copy of your data, if any, in the above directories.

  Enter \"y\" or \"yes\" to continue."
		read install_confirm
		if [ "$install_confirm" == "y" ] || [ "$install_confirm" == "yes" ]; then all_ok=true
		else _ABORT "Interrupted by user"; fi
	fi
else _ABORT "STAGE Check Outputs"; fi
}

### ------------------------
### Prepare uninstaller file
function _PREPARE_UNINSTALLER() {
if [ all_ok == true ]; then
	if [ "$Install_Mode" == "System" ]; then
		if sudo cp -r "$Input_Uninstaller" "$Output_Install_Dir/"; then
			sudo chmod 755 "$Output_Install_Dir/uninstall.sh"
			sudo chown root:root "$Output_Install_Dir/uninstall.sh"
			for filename in "${!All_Files[@]}"; do
				CurrentFile="${All_Files[$filename]}"
				sudo awk -i inplace '{if($0=="FilesToDelete=(") $0=$0"\n\"'"$CurrentFile"'\"";print}' "$Output_Install_Dir/uninstall.sh"
			done
		fi
	fi
	
	if [ "$Install_Mode" == "User" ]; then
		if cp -r "$Input_Uninstaller" "$Output_Install_Dir/"; then
			chmod 744 "$Output_Install_Dir/uninstall.sh"
			for filename in "${!All_Files[@]}"; do
				CurrentFile="${All_Files[$filename]}"
				awk -i inplace '{if($0=="FilesToDelete=(") $0=$0"\n\"'"$CurrentFile"'\"";print}' "$Output_Install_Dir/uninstall.sh"
			done
		fi
	fi
else _ABORT "STAGE Prepare Uninstaller"; fi
}


###
###
### Secondary functions
###
###

function _FILL_INPUT_FILES() {
if [ all_ok == true ]; then
	Files_User_Data=( $(ls "$Input_User_Data") )
	Files_Bin_Dir=( $(ls "$Input_Bin_Dir") )
	Files_Menu=( $(ls "$Input_Menu_Files_Dir") )
	Files_Menu_Dir=( $(ls "$Input_Menu_Desktop_Dir") )
	Files_Menu_Apps=( $(ls "$Input_Menu_Apps_Dir") )
	
	local arr_0=(); local arr_1=(); local arr_2=(); local arr_3=()
	local user_files_test=()
	
	for file in "${!Files_Bin_Dir[@]}"; do arr_0[$file]="$Output_Bin_Dir/${Files_Bin_Dir[$file]}"; done
	for file in "${!Files_Menu[@]}"; do arr_1[$file]="$Output_Menu/${Files_Menu[$file]}"; done
	for file in "${!Files_Menu_Dir[@]}"; do arr_2[$file]="$Output_Menu_Dir/${Files_Menu_Dir[$file]}"; done
	for file in "${!Files_Menu_Apps[@]}"; do arr_3[$file]="$Output_Menu_AppsDir/${Files_Menu_Apps[$file]}"; done
	
	Filled_User_Files=()
	
	if [ $User_Data_Copy_Confirm == true ]; then
		for file in "${!Files_User_Data[@]}"; do user_files_test[$file]="$Output_User_Home/${Files_User_Data[$file]}"; done
		Filled_User_Files=("${user_files_test[@]}")
	fi
	
	All_Files=("$Output_Install_Dir" "${arr_0[@]}" "${arr_1[@]}" "${arr_2[@]}" "${arr_3[@]}")
else _ABORT "STAGE Fill Input Files"; fi
}

### Check and compare MD5 of archive
function _CHECK_MD5() {
if [ all_ok == true ]; then
	all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Integrity check:${F}${rBD}
  Do you want to check the integrity of the installation package?
 
  Enter \"y\" or \"yes\" to verify (this may take some time if the application is large)."
	read check_md5_confirm
	if [ "$check_md5_confirm" == "y" ] || [ "$check_md5_confirm" == "yes" ]; then
		clear
		echo -e "\
$Header
 ${Bold}${F_Cyan}Integrity check:${F}${rBD}
  Checking the integrity of the installation archive, please wait..."
		MD5_DATA=`md5sum "$Archive_File" | awk '{print $1}'`
		if [ "$MD5_DATA" != "$MD5_Hash_Of_Archive" ]; then
			echo -e "\

  ${Bold}${F_DarkRed}Attention! The archive hash sum does not match the value specified in the settings!${F}
  ${F_Red}The file may have been copied with errors or modified! Be careful!${F}${rBD}
  ${Bold}Expected MD5 hash:${rBD} \"$MD5_Hash_Of_Archive\"
  ${Bold}Real MD5 hash:${rBD}     \"$MD5_DATA\"

  Enter \"y\" or \"yes\" to continue installation (not recommended):"
			read errors_confirm
    		if [ "$errors_confirm" == "y" ] || [ "$errors_confirm" == "yes" ]; then all_ok=true
			else _ABORT "Interrupted by user"; fi
		else
			all_ok=true
			echo -e "\n  ${F_Green}The integrity of the installation archive has been successfully verified, press ${Bold}Enter${rBD} to continue.${F}"
			read pause
		fi
	fi
else _ABORT "STAGE Check MD5"; fi
}

### Check Distro version and installed Service Packs
function _CHECK_OS() {
	Distro_Full_Name="Unknown"; Distro_Name="Unknown"; Distro_Version_ID="Unknown"; #SpInstalled=0
	if [ -f /etc/os-release ]; then . /etc/os-release; Distro_Full_Name=$PRETTY_NAME; Distro_Name=$NAME; Distro_Version_ID=$VERSION_ID
		#if [ -f "/etc/chimbalix/sp"*"-installed" ]; then for SpVer in "/etc/chimbalix/sp"*"-installed"; do SpInstalled=$(($SpInstalled+1)); done; fi
	else
		if uname &>/dev/null; then DistroVersion="$(uname -sr)"
		else _ABORT "Unexpected error in function _CHECK_OS"; fi
	fi
}

### ------------------------------------------------
function _MOUNT_ARCHIVE() {
if [ all_ok == true ]; then
	all_ok=false
	if [ ! -d "$Installer_Archive_Mount_Dir" ]; then
		if ! mkdir -p "$Installer_Archive_Mount_Dir"; then _ABORT "Error creating archive mount dir."; fi; fi
	if ! archivemount -o nosave "$Path_To_Script/installer_data.7z" "$Installer_Archive_Mount_Dir"; then _ABORT "Error mounting archive."
	else all_ok=true; fi
else _ABORT "STAGE Mount Archive"; fi
}

### ------------------------------------------------
function _UNMOUNT_ARCHIVE() {
	if [ -d "$Installer_Archive_Mount_Dir" ]; then
		umount "$Installer_Archive_Mount_Dir"
		rm -r "$Installer_Archive_Mount_Dir"
	fi
	if [ -d "$Temp_Dir" ]; then rm -r "$Temp_Dir"; fi
}

#### ---- --------- ---- ####
#### -- END FUNCTIONS -- ####
#### ---- --------- ---- ####

## START ##

_CHECK_OS # Check: Distro_Full_Name - Distro_Name - Distro_Version_ID

_UNMOUNT_ARCHIVE
_PRINT_PACKAGE_INFO
_CHECK_MD5

_MOUNT_ARCHIVE
_FILL_INPUT_FILES
_PRINT_INSTALL_SETTINGS

_CHECK_OUTPUTS

_INSTALL_APP
_PREPARE_UNINSTALLER

read pause

_ABORT


if [ "$arg1" != "--silent" ]; then
	echo "Press Enter to exit or close this window."
	read pause
fi

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
