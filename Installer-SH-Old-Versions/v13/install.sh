#!/usr/bin/env bash
# Script version 1.3
# LICENSE for this script is at the end of this file
#
#FreeSpace=$(df -m "$Out_InstallDir" | grep "/" | awk '{print $4}')
#if (( FreeSpace < InfoReqFreeDiskSpace )); then
#
### $(for file in "${!Files_Bin_Dir[@]}"; do echo "   > ${Files_Bin_Dir[$file]}"; done)
######### ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
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
######### ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##

######### Base vars #########

Argument_1="$1"; shift
Path_To_Script="$( dirname "$(readlink -f "$0")")" # Current installer script directory.
User_Home=~ # Current User home directory.
User_Name=$USER

Installer_Data_Path="$Path_To_Script/installer-data"
Szip_bin="$Installer_Data_Path/tools/7zip/7zzs"

######### ========= #########

######### ---- -------- ---- #########
######### ---- SETTINGS ---- #########
######### ---- -------- ---- #########

Install_Mode="User" # "System" / "User"

 # Copy other data to the user's home directory (do not use this function unless necessary):
User_Data_Copy_Confirm=true

######### - ------------------- - #########
######### - Package Information - #########

Header="${BG_Black}${F_Red}${Bold} -=: Software Installer Script for Chimbalix :=-${rBD}${F}\n"

Info_Name="Example Application"
Info_Version="v1.3"
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
     - Two installation modes:
       . System - you need root rights to install.
       . User - install only for the current User ($User_Name), does not require root rights.
     - Set owner and rights to the application directory (only in \"System\" mode).
  2) Check the current \"install.sh\" file to configure the installation package."

######### - -------------- - #########
######### - Archives paths - #########

Archive_Program_Files="$Installer_Data_Path/program_files.7z"
Archive_Program_Files_MD5="bd7674b4658dfc37d545256ee1557d0e"

Archive_System_Files="$Installer_Data_Path/system_files.7z"
Archive_System_Files_MD5="f2bc88aee77eeae3dde7008432cd5b4a"

 # Not used if "User_Data_Copy_Confirm=false"
Archive_User_Files="$Installer_Data_Path/user_files.7z"
Archive_User_Files_MD5="f6a1f4cebddce4f59459a83c7591f82e"
if [ ! -e "$Archive_User_Files" ] && [ $User_Data_Copy_Confirm == true ]; then User_Data_Copy_Confirm=false; fi # Extra check

######### - ------------ - #########
######### - Output paths - #########

Out_App_Folder_Name="example_application_v13"
Out_App_Folder_Owner=root:root	# Only for "System" mode, username:group
Out_App_Folder_Permissions=755	# Only for "System" mode.

Out_Install_Dir_System="/portsoft/x86_64/$Out_App_Folder_Name"
Out_Install_Dir_User="$User_Home/.local/portsoft/x86_64/$Out_App_Folder_Name"

Temp_Dir="/tmp/$Out_App_Folder_Name""_$RANDOM""_$RANDOM" # TEMP Directory

Out_User_Bin_Dir="$User_Home/.local/bin" # Works starting from Chimbalix 24.4
Out_User_Menu_files="$User_Home/.config/menus/applications-merged"
Out_User_Menu_DDir="$User_Home/.local/share/desktop-directories/apps"
Out_User_Menu_Apps="$User_Home/.local/share/applications/apps"

Out_System_Bin_Dir="/usr/bin"
Out_System_Menu_Files="/etc/xdg/menus/applications-merged"
Out_System_Menu_DDir="/usr/share/desktop-directories/apps"
Out_System_Menu_Apps="/usr/share/applications/apps"

Output_Install_Dir="DONtCHANGE"
Output_Bin_Dir="DONtCHANGE"
Output_Menu_Files="DONtCHANGE"
Output_Menu_DDir="DONtCHANGE"
Output_Menu_Apps="DONtCHANGE"
Output_User_Home="$User_Home"

if [ "$Install_Mode" == "System" ]; then
	Output_Install_Dir="$Out_Install_Dir_System"
	Output_Bin_Dir="$Out_System_Bin_Dir"
	Output_Menu_Files="$Out_System_Menu_Files"
	Output_Menu_DDir="$Out_System_Menu_DDir"
	Output_Menu_Apps="$Out_System_Menu_Apps"
else
	Output_Install_Dir="$Out_Install_Dir_User"
	Output_Bin_Dir="$Out_User_Bin_Dir"
	Output_Menu_Files="$Out_User_Menu_files"
	Output_Menu_DDir="$Out_User_Menu_DDir"
	Output_Menu_Apps="$Out_User_Menu_Apps"
fi

Output_Uninstaller="$Output_Install_Dir/uninstall.sh" # Uninstaller template file.

###  Make sure the following files are properly prepared according to the application.
#  All files listed here will be modified according to the installation path of the application,
#  you must take care to correctly use the "PATH_TO_FOLDER" variable inside the files.
# The "PATH_TO_FOLDER" variable points to the application installation directory without the trailing slash, for example "/portsoft/x86_64/example-application".


 # Desktop shortcut files:
 ## Copy files from "Template_Menu_Files_Dir" to "/etc/xdg/menus/applications-merged/" or "/home/USER_NAME/.config/menus/applications-merged/"
 ## Copy files from "Template_Menu_Desktop_Dir" to "/usr/share/desktop-directories/apps/" or "/home/USER_NAME/.local/share/desktop-directories/apps/"

all_ok=true

######### -- ------------ -- #########
######### -- END SETTINGS -- #########
######### -- ------------ -- #########

######### Strings
Str_InterruptedByUser="${Bold}${F_Green}Interrupted by user${F}${rBD}"
Str_ERROR_BeforeStage="${Bold}${F_Red}ERROR${F_Yellow} at the stage before:${F}${rBD}"

######### ---- --------- ---- #########
######### ---- FUNCTIONS ---- #########
######### ---- --------- ---- #########

######### ------------------------------------------------
function _CLEAR_TEMP() {
if [ -e "$Temp_Dir" ]; then
	if [ "$Install_Mode" == "System" ]; then rm -rf "$Temp_Dir"; fi
	if [ "$Install_Mode" == "User" ]; then rm -rf "$Temp_Dir"; fi
fi
}

######### ------------------------------------------------
function _CREATE_TEMP() {
if [ -e "$Temp_Dir" ]; then _CLEAR_TEMP; fi
if [ "$Install_Mode" == "System" ]; then mkdir "$Temp_Dir"; fi
if [ "$Install_Mode" == "User" ]; then mkdir "$Temp_Dir"; fi
}

######### ------------------------------------------------
function _ABORT() {
	clear
	echo -e "\
$Header
  Exit message - $1

  Press Enter or close the window to exit."
	_CLEAR_TEMP
	read pause; clear; exit 1 # Double clear resets styles before going to the system terminal window.
}

######### ------------------------------------------------
######### Check Distro version and installed Service Packs
function _CHECK_OS() {
	Distro_Full_Name="Unknown"; Distro_Name="Unknown"; Distro_Version_ID="Unknown"; #SpInstalled=0
	if [ -f /etc/os-release ]; then . /etc/os-release; Distro_Full_Name=$PRETTY_NAME; Distro_Name=$NAME; Distro_Version_ID=$VERSION_ID
		#if [ -f "/etc/chimbalix/sp"*"-installed" ]; then for SpVer in "/etc/chimbalix/sp"*"-installed"; do SpInstalled=$(($SpInstalled+1)); done; fi
	else
		if uname &>/dev/null; then DistroVersion="$(uname -sr)"
		else _ABORT "Unexpected error in function _CHECK_OS"; fi
	fi
}

#########
#########
#########
#########
#########

######### -------------------------
######### Print package information
function _PRINT_PACKAGE_INFO() {
if [ $all_ok == true ]; then all_ok=false
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
$Info_Description

 -${Bold}${F_DarkGreen}Current OS:${F} $Distro_Full_Name${rBD}
 -${Bold}${F_DarkGreen}Installation Mode:${F} $Install_Mode${rBD}"
	echo -e "\n Start the application installation process? Enter \"y\" or \"yes\" to confirm."
	read package_info_confirm
	if [ "$package_info_confirm" == "y" ] || [ "$package_info_confirm" == "yes" ]; then all_ok=true
	else _ABORT "$Str_InterruptedByUser"; fi
else _ABORT "$Str_ERROR_BeforeStage \"Print Package Info\""; fi
}

######### Check and compare MD5 of archive
function _CHECK_MD5() {
if [ $all_ok == true ]; then all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Checking archives integrity:${F}${rBD}
  Do you want to check the integrity of the installation package?
   (this may take some time if the application is large)
  
  Enter \"y\" or \"yes\" to check the integrity of the archives (recommended)."
	
	read check_md5_confirm
	if [ "$check_md5_confirm" == "y" ] || [ "$check_md5_confirm" == "yes" ]; then
		clear
		echo -e "\
$Header
 ${Bold}${F_Cyan}Integrity check:${F}${rBD}
  Checking the integrity of the installation archives, please wait..."
		local pfiles=true; local sfiles=true; local ufiles=true; local warning=false;
		local Program_Files_MD5=`md5sum "$Archive_Program_Files" | awk '{print $1}'`
		local System_Files_MD5=`md5sum "$Archive_System_Files" | awk '{print $1}'`
		
		if [ "$Program_Files_MD5" != "$Archive_Program_Files_MD5" ]; then pfiles=false; fi
		if [ "$System_Files_MD5" != "$Archive_System_Files_MD5" ]; then sfiles=false; fi
		
		if [ $User_Data_Copy_Confirm == true ]; then
			local User_Files_MD5=`md5sum "$Archive_User_Files" | awk '{print $1}'`
			if [ "$User_Files_MD5" != "$Archive_User_Files_MD5" ]; then ufiles=false; fi
		fi
		if [ $pfiles == false ] || [ $sfiles == false ] || [ $ufiles == false ]; then warning=true; fi
		
		if [ $warning == true ]; then
			echo -e "\

  ${Bold}${F_DarkRed}Attention! The archives hash sum does not match the value specified in the settings!${F}
  ${F_Red}The files may have been copied with errors or modified! Be careful!${F}${rBD}"
if [ $pfiles == false ]; then echo -e "\

   ${Bold}Expected Program Files MD5 hash:${rBD} \"$Archive_Program_Files_MD5\"
   ${Bold}Real Program Files MD5 hash:${rBD}     \"$Program_Files_MD5\""; fi
if [ $sfiles == false ]; then echo -e "\

   ${Bold}Expected System Files MD5 hash:${rBD} \"$Archive_System_Files_MD5\"
   ${Bold}Real System Files MD5 hash:${rBD}     \"$System_Files_MD5\""; fi
if [ $ufiles == false ]; then echo -e "\

   ${Bold}Expected User Files MD5 hash:${rBD} \"$Archive_User_Files_MD5\"
   ${Bold}Real User Files MD5 hash:${rBD}     \"$User_Files_MD5\""; fi
echo -e "\n  Enter \"y\" or \"yes\" to continue installation (not recommended):"
			read errors_confirm
    		if [ "$errors_confirm" == "y" ] || [ "$errors_confirm" == "yes" ]; then all_ok=true
			else _ABORT "$Str_InterruptedByUser"; fi
		else
			all_ok=true
			echo -e "\n  ${F_Green}The integrity of the installation archive has been successfully verified, press ${Bold}Enter${rBD} to continue.${F}"
			read pause
		fi
	else all_ok=true; fi
else _ABORT "$Str_ERROR_BeforeStage \"MD5 Check\""; fi
}


######### ---------------------------
######### Print installation settings
function _PRINT_INSTALL_SETTINGS() {
if [ $all_ok == true ]; then all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Installation paths (${F_DarkYellow}$Install_Mode${F_Cyan} mode):${F}${rBD}

 -${Bold}${F_DarkGreen}Temp Directory:${F}${rBD} $Temp_Dir
 
 -${Bold}${F_DarkGreen}Application install Directory:
   ${F}${rBD}$Output_Install_Dir

 -${Bold}${F_DarkGreen}Menu files will be installed to:${F}${rBD}
   $Output_Menu_Files
   $Output_Menu_DDir
   $Output_Menu_Apps

 -${Bold}${F_DarkGreen}Install Bin shortcuts to:${F}${rBD} $Output_Bin_Dir"
if [ $User_Data_Copy_Confirm == true ]; then
	echo -e "\n -${Bold}${F_Yellow}Attention!${F}${F_DarkGreen} Copy user data to:${F}${rBD} $Output_User_Home"
fi
	echo -e "\n Please close all important applications before installation."
	echo -e "\n Start installation? Enter \"y\" or \"yes\" to confirm."
	read install_settings_confirm
	if [ "$install_settings_confirm" == "y" ] || [ "$install_settings_confirm" == "yes" ]; then all_ok=true
	else _ABORT "$Str_InterruptedByUser"; fi
else _ABORT "$Str_ERROR_BeforeStage \"Print Install Settings\""; fi
}

######### -------------------
######### Prepare Input Files
function _PREPARE_INPUT_FILES() {
if [ $all_ok == true ]; then all_ok=false
	if ! "$Szip_bin" x "$Archive_System_Files" -o"$Temp_Dir/" &> /dev/null; then
		chmod +x "$Szip_bin"
		if ! "$Szip_bin" x "$Archive_System_Files" -o"$Temp_Dir/" &> /dev/null; then
			_ABORT "Error unpacking temp files (_PREPARE_INPUT_FILES), try copying the installation files to another disk before running."
		fi
	fi
	
	for file in "$Temp_Dir"/*; do
		grep -rl "PATH_TO_FOLDER" "$Temp_Dir" | xargs sed -i "s~PATH_TO_FOLDER~$Output_Install_Dir~g"
	done
	
	Input_Bin_Dir="$Temp_Dir/bin"
	Input_Menu_Files_Dir="$Temp_Dir/menu/applications-merged"
	Input_Menu_Desktop_Dir="$Temp_Dir/menu/desktop-directories/apps"
	Input_Menu_Apps_Dir="$Temp_Dir/menu/apps"
	
	Files_Bin_Dir=( $(ls "$Input_Bin_Dir") )
	Files_Menu=( $(ls "$Input_Menu_Files_Dir") )
	Files_Menu_Dir=( $(ls "$Input_Menu_Desktop_Dir") )
	Files_Menu_Apps=( $(ls "$Input_Menu_Apps_Dir") )
	
	local arr_0=(); local arr_1=(); local arr_2=(); local arr_3=()
	All_Files=()
	
	for file in "${!Files_Bin_Dir[@]}"; do arr_0[$file]="$Output_Bin_Dir/${Files_Bin_Dir[$file]}"; done
	for file in "${!Files_Menu[@]}"; do arr_1[$file]="$Output_Menu_Files/${Files_Menu[$file]}"; done
	for file in "${!Files_Menu_Dir[@]}"; do arr_2[$file]="$Output_Menu_DDir/${Files_Menu_Dir[$file]}"; done
	for file in "${!Files_Menu_Apps[@]}"; do arr_3[$file]="$Output_Menu_Apps/${Files_Menu_Apps[$file]}"; done
	
	All_Files=("$Output_Install_Dir" "${arr_0[@]}" "${arr_1[@]}" "${arr_2[@]}" "${arr_3[@]}")
	
	all_ok=true
else _ABORT "$Str_ERROR_BeforeStage \"Fill Input Files\""; fi
}


######### -------------
######### Check outputs
function _CHECK_OUTPUTS() {
if [ $all_ok == true ]; then all_ok=false
	local error=false
	local arr_files_sorted=()
	
	for file in "${!All_Files[@]}"; do if [ -e "${All_Files[$file]}" ]; then arr_files_sorted[$file]="${All_Files[$file]}"; error=true; fi; done
	
	if [ $error == true ]; then
		clear
		echo -e "\
$Header
 ${Bold}${F_Cyan}WARNING!${F}${rBD}"
		if [ $User_Data_Copy_Confirm == true ]; then
			echo " WARNING! Copying data to the user directory is enabled!"
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
		else _ABORT "$Str_InterruptedByUser"; fi
	else
		all_ok=true
	fi
else _ABORT "$Str_ERROR_BeforeStage \"Check Outputs\""; fi
}


######### -------------------
######### Install application
function _INSTALL_APP() {
if [ $all_ok == true ]; then all_ok=false
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Installing...${F}${rBD}"
	
	# Copy Application files
	echo " Unpack application files..."
	echo "  from: $Archive_Program_Files"
	echo "  to: $Output_Install_Dir"
	mkdir -p "$Output_Install_Dir"
	if ! "$Szip_bin" x -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
		echo -e "\n ATTENTION!!! Error unpacking program files..."
		echo " Broken archive? Or symbolic links with absolute paths as part of an application?"
		echo -e "\n Enter \"y\" or \"yes\" to continue installation."
		read confirm_error_unpacking
		if [ "$confirm_error_unpacking" == "y" ] || [ "$confirm_error_unpacking" == "yes" ]; then
			echo "  Continue..."
		else _ABORT "Error unpacking program files..."; fi
	fi
	
	######### System MODE #########
	if [ "$Install_Mode" == "System" ]; then
		echo " Set rights and owner..."
		sudo chmod -R $Output_App_Folder_Permissions "$Output_Install_Dir"
		sudo chown -R $Output_App_Folder_Owner "$Output_Install_Dir"
		
		# Copy Bin files
		echo " Install Bin files..."
		echo -e "  from: $Input_Bin_Dir\n  to: $Output_Bin_Dir"
		sudo cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
		
		# Сopy Menu files
		echo " Copy Menu files..."
		echo -e "  from: $Input_Menu_Files_Dir"
		echo "  to: $Output_Menu_Files"
		sudo cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
		echo " Copy Menu Dir files..."
		echo "  from: $Input_Menu_Desktop_Dir\n  to: $Output_Menu_DDir"
		sudo cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
		echo " Сopy Menu Apps..."
		echo -e "  from: $Input_Menu_Apps_Dir\n  to: $Output_Menu_App"
		sudo cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
	fi

	######### User MODE #########
	if [ "$Install_Mode" == "User" ]; then
		
		if [ ! -e "$Output_Bin_Dir" ]; then mkdir "$Output_Bin_Dir"; fi
		
		# Copy Bin files
		echo " Install Bin files..."
		echo "  from: $Input_Bin_Dir"
		echo "  to: $Output_Bin_Dir"
		cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
		
		# Сopy Menu files
		echo " Copy Menu files..."
		echo -e "  from: $Input_Menu_Files_Dir"
		echo "  to: $Output_Menu_Files"
		cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
		echo " Copy Menu Dir files..."
		echo "  from: $Input_Menu_Desktop_Dir\n  to: $Output_Menu_DDir"
		cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
		echo " Сopy Menu Apps..."
		echo -e "  from: $Input_Menu_Apps_Dir\n  to: $Output_Menu_App"
		cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
	fi
	
	# Copy user data
	if [ $User_Data_Copy_Confirm == true ]; then
		echo " Copy User files..."
		echo "  from: $Archive_User_Files"
		echo "  to: $Output_User_Home"
		if ! "$Szip_bin" x -aoa "$Archive_User_Files" -o"$Output_User_Home/" &> /dev/null; then
			echo "Error unpacking user files..."
			read pause
		fi
	fi
	
	all_ok=true
else _ABORT "$Str_ERROR_BeforeStage \"Install Application\""; fi
}


######### ------------------------
######### Prepare uninstaller file
function _PREPARE_UNINSTALLER() {
if [ $all_ok == true ]; then
	if [ "$Install_Mode" == "System" ]; then
		sudo chmod 755 "$Output_Uninstaller"
		sudo chown root:root "$Output_Uninstaller"
		for filename in "${!All_Files[@]}"; do
			CurrentFile="${All_Files[$filename]}"
			sudo awk -i inplace '{if($0=="FilesToDelete=(") $0=$0"\n\"'"$CurrentFile"'\"";print}' "$Output_Uninstaller"
		done
	fi
	if [ "$Install_Mode" == "User" ]; then
		chmod 744 "$Output_Uninstaller"
		for filename in "${!All_Files[@]}"; do
			CurrentFile="${All_Files[$filename]}"
			awk -i inplace '{if($0=="FilesToDelete=(") $0=$0"\n\"'"$CurrentFile"'\"";print}' "$Output_Uninstaller"
		done
	fi
	# Restart taskbar
	xfce4-panel -r
else _ABORT "$Str_ERROR_BeforeStage \"Prepare Uninstaller\""; fi
}



######### ---- --------- ---- #########
######### -- END FUNCTIONS -- #########
######### ---- --------- ---- #########

## START ##

_CHECK_OS # Check: Distro_Full_Name - Distro_Name - Distro_Version_ID

_PRINT_PACKAGE_INFO
_CHECK_MD5
_PRINT_INSTALL_SETTINGS

_CREATE_TEMP
_PREPARE_INPUT_FILES
_CHECK_OUTPUTS

_INSTALL_APP
_PREPARE_UNINSTALLER

_ABORT "Complete install"


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
