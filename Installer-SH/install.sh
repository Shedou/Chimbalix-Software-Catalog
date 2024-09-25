#!/usr/bin/env bash
# Script version 1.6
# LICENSE for this script is at the end of this file
# FreeSpace=$(df -m "$Out_InstallDir" | grep "/" | awk '{print $4}')
# Font styles: "${Bold} BLACK TEXT ${rBD} normal text."
Bold="\e[1m"; Dim="\e[2m"; rBD="\e[22m";
F='\033[39m'; BG='\033[49m'; # Reset colors
F_Black='\033[30m'; F_DarkGray='\033[90m'; F_Gray='\033[37m'; F_White='\033[97m';
F_DarkRed='\033[31m'; F_DarkGreen='\033[32m'; F_DarkYellow='\033[33m'; F_DarkBlue='\033[34m'; F_DarkMagenta='\033[35m'; F_DarkCyan='\033[36m';
F_Red='\033[91m'; F_Green='\033[92m'; F_Yellow='\033[93m'; F_Blue='\033[94m'; F_Magenta='\033[95m'; F_Cyan='\033[96m';
BG_Black='\033[40m'; BG_DarkGray='\033[100m'; BG_Gray='\033[47m'; BG_White='\033[107m';
BG_DarkRed='\033[41m'; BG_DarkGreen='\033[42m'; BG_DarkYellow='\033[43m'; BG_DarkBlue='\033[44m'; BG_DarkMagenta='\033[45m'; BG_DarkCyan='\033[46m';
BG_Red='\033[101m'; BG_Green='\033[102m'; BG_Yellow='\033[103m'; BG_Blue='\033[104m'; BG_Magenta='\033[105m'; BG_Cyan='\033[106m';
######### --------- #########
######### Base vars #########
Arguments=("$@"); Path_To_Script="$( dirname "$(readlink -f "$0")")"
User_Home=~; User_Name=$USER; DEBUG_MODE=false; Silent_Mode=false; Use_Default_Locale=false
Installer_Data_Path="$Path_To_Script/installer-data"; Szip_bin="$Installer_Data_Path/tools/7zip/7zzs"
all_ok=true

# Main function, don't change!
function _MAIN() {
	if [ ${Arguments[$1]} == "-silent" ]; then Silent_Mode=true; Lang_Display="-silent"; fi
	_CHECK_OS # Distro_Full_Name - Distro_Name - Distro_Version_ID
	_SET_LOCALE
	_PACKAGE_SETTINGS
	
	_PRINT_PACKAGE_INFO
	_CHECK_MD5
	_PRINT_INSTALL_SETTINGS
	
	_CREATE_TEMP
	_PREPARE_INPUT_FILES
	_CHECK_OUTPUTS
	
	_INSTALL_APP
	_PREPARE_UNINSTALLER
}

######### ---- -------- ---- #########
######### ---- SETTINGS ---- #########
######### ---- -------- ---- #########

function _PACKAGE_SETTINGS() {

 # Copy other data to the user's home directory: "true" / "false". Do not use this function unless necessary!
User_Data_Copy_Confirm=false

 # Installation mode: "System" / "User"
Install_Mode="User" # In "User" mode, root rights are not required.

 # x86_64, x86, script, other
Architecture="script"

 # Unique name of the output directory. Template for automatic replacement in menu files: UNIQUE_APP_FOLDER_NAME
Unique_App_Folder_Name="example_application_16"

######### - ------------------- - #########
######### - Package Information - #########
######### - ------------------- - #########
Header="${BG_Black}${F_Red}${Bold} -=: Software Installer Script for Chimbalix (Installer-SH v1.6) - Lang: ${Bold}$Lang_Display${rBD} :=-${rBD}${F}\n"

Info_Name="Example Application"
Info_Version="1.6"
Info_Release_Date="2024-09-22"
Info_Category="Other"
Info_Platform="Linux - Chimbalix 24.2 - 24.x"
Info_Installed_Size="~1 MiB"
Info_Licensing="Freeware - Open Source (MIT)
   Other Licensing Examples:
    Freeware - Proprietary (EULA, Please read \"install-EULA-example.txt\")
    Trialware - 30 days free, Proprietary (Other License Name)"
Info_Developer="Chimbal"
Info_URL="https://github.com/Shedou/Chimbalix-Software-Catalog"
Info_Description="\
  1) This installer allows you to:
     - Suitable for installation on stand-alone PCs without Internet access.
     - Storing installation files in a 7-zip archive (good compression and fast decompression).
     - Two installation modes:
       . User - install only for the current User ($User_Name), does not require root rights.
       . System - For all users, root rights are required.
     - Set owner and rights to the application directory (only in \"System\" mode).
  2) Check the current \"install.sh\" file to configure the installation package."

### ------------------------ ###
 ### Basic Menu File Settings ###
 ### ------------------------ ###
 # Please manually prepare the menu files in the "installer-data/system_files/" directory before packaging the application,
 # this functionality does not allow you to fully customize the menu files.
 # Use the variable names given in the comments to simplify the preparation of menu files.
Program_Executable_File="example-application" # PROGRAM_EXECUTABLE_FILE
Program_Name_In_Menu="Example Application 1.6" # PROGRAM_NAME_IN_MENU
Program_Icon_In_Menu="icon.png" # PROGRAM_ICON_IN_MENU
Program_Exe_Run_In_Terminal="true" # PROGRAM_EXE_RUN_IN_TERMINAL
Program_Uninstaller_File="uninstall.sh"  # PROGRAM_UNINSTALLER_FILE
Program_Uninstaller_Icon="icon-uninstall.png"  # PROGRAM_UNINSTALLER_ICON
Menu_Directory_Name="Example Application (v1.6)" # MENU_DIRECTORY_NAME
Menu_Directory_Icon="icon.png" # MENU_DIRECTORY_ICON

 # Additional menu categories that will include the main application shortcuts.
 # Please do not use this variable in the uninstaller shortcut file.
Additional_Categories="chi-other;" #ADDITIONAL_CATEGORIES
 # -=== Chimbalix 24.4 main categories:
 # chi-ai  chi-accessories  chi-accessories-fm  chi-view  chi-admin  chi-info  chi-info-bench  chi-info-help
 # chi-dev  chi-dev-other  chi-dev-ide  chi-edit  chi-edit-audiovideo  chi-edit-image  chi-edit-text  chi-games
 # chi-network  chi-multimedia  chi-multimedia-players  chi-office  chi-other  chi-tools  chi-tools-archivers
 # -=== XDG / Linux Categories Version 1.1 (20 August 2016):
 # URL: https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
 # URL: https://specifications.freedesktop.org/menu-spec/latest/additional-category-registry.html

######### - -------------- - #########
######### - Archives paths - #########
######### - -------------- - #########

Archive_Program_Files="$Installer_Data_Path/program_files.7z"
Archive_Program_Files_MD5="b0140093e2c9e72698b7d4f8ad9af83d"

Archive_System_Files="$Installer_Data_Path/system_files.7z"
Archive_System_Files_MD5="0b02ea89b3899def0ea3fd67f6737fdd"

 # Not used if "User_Data_Copy_Confirm=false"
Archive_User_Files="$Installer_Data_Path/user_files.7z"
Archive_User_Files_MD5="983ed40a5041a142b3c96859978f9f2a"

 # Extra check
if [ ! -e "$Archive_User_Files" ] && [ $User_Data_Copy_Confirm == true ]; then User_Data_Copy_Confirm=false; fi

######### - ------------ - #########
######### - Output paths - #########
######### - ------------ - #########

 # Application installation directory.
Out_Install_Dir_System="/portsoft/$Architecture/$Unique_App_Folder_Name"
Out_Install_Dir_User="$User_Home/.local/portsoft/$Architecture/$Unique_App_Folder_Name"

Out_App_Folder_Owner=root:root	# Only for "System" mode, username:group
Out_App_Folder_Permissions=755	# Only for "System" mode.

Temp_Dir="/tmp/$Unique_App_Folder_Name""_$RANDOM""_$RANDOM" # TEMP Directory

Out_User_Bin_Dir="$User_Home/.local/bin" # Works starting from Chimbalix 24.4
Out_User_Menu_files="$User_Home/.config/menus/applications-merged"
Out_User_Menu_DDir="$User_Home/.local/share/desktop-directories/apps"
Out_User_Menu_Apps="$User_Home/.local/share/applications/apps"

Out_System_Bin_Dir="/usr/bin"
Out_System_Menu_Files="/etc/xdg/menus/applications-merged"
Out_System_Menu_DDir="/usr/share/desktop-directories/apps"
Out_System_Menu_Apps="/usr/share/applications/apps"

# The "PATH_TO_FOLDER" variable points to the application installation directory without the trailing slash (Output_Install_Dir), for example "/portsoft/x86_64/example_application".
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

Output_Uninstaller="$Output_Install_Dir/$Program_Uninstaller_File" # Uninstaller template file.
}

######### -- ------------ -- #########
######### -- END SETTINGS -- #########
######### -- ------------ -- #########

######### Strings! #########
###### Default Locale ######

function _SET_LOCALE() {
	Language="${LANG%%.*}"
	if [ $Silent_Mode == false ]; then Lang_Display="$Language"; fi
	Locale_File="$Path_To_Script/locales/$Language"
	if [ -e "$Locale_File" ]; then
		if [ $(grep Locale_Version "$Locale_File") == 'Locale_Version="1.6"' ]; then source "$Locale_File";
		else Use_Default_Locale=true; fi
	else Use_Default_Locale=true; fi
	
	if [ $Use_Default_Locale == true ]; then
		if [ $Silent_Mode == false ]; then Lang_Display="Default"; fi
		Str_ERROR="${Bold}${F_Red}ERROR${F}${rBD}" # ОШИБКА
		Str_ATTENTION="${Bold}${F_Yellow}ATTENTION${F}${rBD}" # ВНИМАНИЕ
		Str_WARNING="${Bold}${F_Yellow}WARNING${F}${rBD}" # ПРЕДУПРЕЖДЕНИЕ
		
		Str_Interrupted_By_User="${Bold}${F_Green}Interrupted by user${F}${rBD}" # Прервано пользователем
		Str_Complete_Install="${Bold}${F_Green}The installation process has been completed successfully.${F}${rBD}" # Процесс установки успешно завершен.
		
		Str_Error_All_Ok="$Str_ERROR! ${Bold}${F_Yellow} The \"all_ok\" condition was not passed in the function:${F}${rBD}" # Условие "all_ok" не пройдено в функции:
		
		Str_ABORT_Msg="Exit code -" # Код выхода -
		Str_ABORT_Exit="Press Enter or close the window to exit." # Нажмите Enter или закройте окно, чтобы выйти.
		
		Str_CHECKOS_No_Distro_Name="$Str_ATTENTION! ${Bold}${F_Yellow}The name of the operating system / kernel is not defined!${F}${rBD}" # Название операционной системы / ядра не определено!
		
		Str_PACKAGEINFO_SoftwareInfo="Software Info:"
		Str_PACKAGEINFO_Name="Name:"
		Str_PACKAGEINFO_ReleaseDate="Release Date:"
		Str_PACKAGEINFO_Category="Category:"
		Str_PACKAGEINFO_Platform="Platform:"
		Str_PACKAGEINFO_InstalledSize="Installed Size:"
		Str_PACKAGEINFO_Licensing="Licensing:"
		Str_PACKAGEINFO_Developer="Developer:"
		Str_PACKAGEINFO_URL="URL:"
		Str_PACKAGEINFO_Description="Description:"
		Str_PACKAGEINFO_CurrentOS="Current OS:"
		Str_PACKAGEINFO_InstallMode="Installation Mode:"
		
		Str_INSTALLAPP_Error_Unpack_ProgramFiles="$Str_ERROR! ${Bold}${F_Yellow}At the stage of unpacking program files.${F}${rBD}" # На этапе распаковки файлов программы.
		
	fi
	
}

######### ------------------------------------------------

function _CLEAR_TEMP() { if [ -e "$Temp_Dir" ]; then rm -rf "$Temp_Dir"; fi; }
function _CREATE_TEMP() { _CLEAR_TEMP; mkdir "$Temp_Dir"; }

######### ------------------------------------------------
function _ABORT() {
	clear
	echo -e "\
$Header
  $Str_ABORT_Msg $1

  $Str_ABORT_Exit"
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
		else _ABORT "$Str_CHECKOS_No_Distro_Name"; fi
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
if [ $Silent_Mode == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		echo -e "${BG_Black}"; clear; # A crutch to fill the background completely...
		echo -e "\
$Header
 ${Bold}${F_Cyan}$Str_PACKAGEINFO_SoftwareInfo${F}${rBD}
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Name${F} $Info_Name${rBD} ($Info_Version,  $Architecture)
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_ReleaseDate${rBD}${F} $Info_Release_Date
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Category${rBD}${F} $Info_Category
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Platform${rBD}${F} $Info_Platform
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_InstalledSize${rBD}${F} $Info_Installed_Size
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Licensing${rBD}${F} $Info_Licensing
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Developer${rBD}${F} $Info_Developer
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_URL${rBD}${F} $Info_URL
 -${Bold}${F_DarkYellow}$Str_PACKAGEINFO_Description${F}${rBD}
$Info_Description

 -${Bold}${F_DarkGreen}$Str_PACKAGEINFO_CurrentOS${F} $Distro_Full_Name${rBD}
 -${Bold}${F_DarkGreen}$Str_PACKAGEINFO_InstallMode${F} $Install_Mode${rBD}"
		echo -e "\n Start the application installation process? Enter \"y\" or \"yes\" to confirm."
		read package_info_confirm
		if [ "$package_info_confirm" == "y" ] || [ "$package_info_confirm" == "yes" ]; then all_ok=true
		else _ABORT "$Str_Interrupted_By_User"; fi
		
		if [ $DEBUG_MODE == true ]; then echo "_PRINT_PACKAGE_INFO - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_PRINT_PACKAGE_INFO\""; fi
fi
}

######### --------------------------------
######### Check and compare MD5 of archive

function _CHECK_MD5_COMPARE() {
	md5_pfiles_error=false; md5_sfiles_error=false; md5_ufiles_error=false
	md5_warning=false;
	
	Program_Files_MD5=`md5sum "$Archive_Program_Files" | awk '{print $1}'`
	System_Files_MD5=`md5sum "$Archive_System_Files" | awk '{print $1}'`
	
	if [ "$Program_Files_MD5" != "$Archive_Program_Files_MD5" ]; then md5_pfiles_error=true; fi
	if [ "$System_Files_MD5" != "$Archive_System_Files_MD5" ]; then md5_sfiles_error=true; fi
	
	if [ $User_Data_Copy_Confirm == true ]; then
		local User_Files_MD5=`md5sum "$Archive_User_Files" | awk '{print $1}'`
		if [ "$User_Files_MD5" != "$Archive_User_Files_MD5" ]; then md5_ufiles_error=false; fi
	fi
	
	if [ $md5_pfiles_error == true ] || [ $md5_sfiles_error == true ] || [ $md5_ufiles_error == true ]; then
		md5_warning=true
	fi
}

function _CHECK_MD5_PRINT() {
	clear
	echo -e "\
$Header
 ${Bold}${F_Cyan}Integrity check:${F}${rBD}
  Checking the integrity of the installation archives, please wait..."
	
	if [ $md5_warning == true ]; then
		echo -e "\

  ${Bold}${F_DarkRed}Attention! The archives hash sum does not match the value specified in the settings!${F}
  ${F_Red}The files may have been copied with errors or modified! Be careful!${F}${rBD}"
		if [ $md5_pfiles_error == true ]; then
			echo -e "\

   ${Bold}Expected Program Files MD5 hash:${rBD} \"$Archive_Program_Files_MD5\"
   ${Bold}Real Program Files MD5 hash:${rBD}     \"$Program_Files_MD5\""; fi
		if [ $md5_sfiles_error == true ]; then
			echo -e "\

   ${Bold}Expected System Files MD5 hash:${rBD} \"$Archive_System_Files_MD5\"
   ${Bold}Real System Files MD5 hash:${rBD}     \"$System_Files_MD5\""; fi
		if [ $md5_ufiles_error == true ]; then
			echo -e "\

   ${Bold}Expected User Files MD5 hash:${rBD} \"$Archive_User_Files_MD5\"
   ${Bold}Real User Files MD5 hash:${rBD}     \"$User_Files_MD5\""; fi
		echo -e "\n  Enter \"y\" or \"yes\" to continue installation (not recommended):"
		read errors_confirm
    	if [ "$errors_confirm" == "y" ] || [ "$errors_confirm" == "yes" ]; then all_ok=true
		else _ABORT "$Str_Interrupted_By_User"; fi
	else
		all_ok=true
		echo -e "
  ${F_Green}The integrity of the installation archive has been successfully verified
   ${Bold}Program Files MD5 hash:${rBD}  \"$Program_Files_MD5\"
   ${Bold}System Files MD5 hash:${rBD}   \"$System_Files_MD5\""
		if [ $User_Data_Copy_Confirm == true ]; then echo -e "\
   ${Bold}User Files MD5 hash:${rBD}     \"$User_Files_MD5\""
		fi
		echo -e "
  press ${Bold}Enter${rBD} to continue.${F}"
		read pause
	fi
}

function _CHECK_MD5() {
if [ $Silent_Mode == false ]; then
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
			_CHECK_MD5_COMPARE
			_CHECK_MD5_PRINT
		else all_ok=true; fi
	
	if [ $DEBUG_MODE == true ]; then echo "_CHECK_MD5 - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_CHECK_MD5\""; fi
else
	_CHECK_MD5_COMPARE
	if [ $md5_warning == true ]; then _CHECK_MD5_PRINT; fi
fi
}


######### ---------------------------
######### Print installation settings
function _PRINT_INSTALL_SETTINGS() {
if [ $Silent_Mode == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		clear
		echo -e "\
$Header
 ${Bold}${F_Cyan}Installation paths (${F_DarkYellow}$Install_Mode${F_Cyan} mode):${F}${rBD}

 -${Bold}${F_DarkGreen}Temporary Directory:${F}${rBD} $Temp_Dir
 
 -${Bold}${F_DarkGreen}Application install Directory:
   ${F}${rBD}$Output_Install_Dir

 -${Bold}${F_DarkGreen}Menu files will be installed to:${F}${rBD}
   $Output_Menu_Files
   $Output_Menu_DDir
   $Output_Menu_Apps

 -${Bold}${F_DarkGreen}Bin files will be installed in:${F}${rBD}
   $Output_Bin_Dir"

		if [ $User_Data_Copy_Confirm == true ]; then
			echo -e "\n -${Bold}${F_Yellow}Attention!${F}${F_DarkGreen} Copy user data to:${F}${rBD} $Output_User_Home
   Change the variable \"User_Data_Copy_Confirm=false\" in the script if you do not want
   to install any data to the home directory (the application may not work correctly)."
		fi
	
		if [ "$Install_Mode" == "System" ]; then
			echo -e "\n -${Bold}${F_Yellow}Attention!
   Installation mode \"System\", root rights are required!
   During the installation process, the root password will be requested.${F}${rBD}"
		fi
		
		echo -e "\n Please close all important applications before installation."
		echo -e "\n Start installation? Enter \"y\" or \"yes\" to confirm."
		read install_settings_confirm
	
		if [ "$install_settings_confirm" == "y" ] || [ "$install_settings_confirm" == "yes" ]; then all_ok=true
		else _ABORT "$Str_Interrupted_By_User"; fi
	
		if [ $DEBUG_MODE == true ]; then echo "_PRINT_INSTALL_SETTINGS - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_PRINT_INSTALL_SETTINGS\""; fi
fi
}

######### -------------------
######### Prepare Input Files

function _PREPARE_INPUT_FILES_GREP() {
	local p_text="$1"; local p_path="$2"
	grep -rl "$p_text" "$Temp_Dir" | xargs sed -i "s~$p_text~$p_path~g" &> /dev/null
}

function _PREPARE_INPUT_FILES() {
	if [ $all_ok == true ]; then all_ok=false
		
		if ! [[ -x "$Szip_bin" ]]; then chmod +x "$Szip_bin"; fi
		
		if ! "$Szip_bin" x "$Archive_System_Files" -o"$Temp_Dir/" &> /dev/null; then
			_ABORT "Error unpacking temp files (_PREPARE_INPUT_FILES), try copying the installation files to another disk before running."
		fi
		
		for file in "$Temp_Dir"/*; do
			_PREPARE_INPUT_FILES_GREP "PATH_TO_FOLDER" "$Output_Install_Dir"
			_PREPARE_INPUT_FILES_GREP "UNIQUE_APP_FOLDER_NAME" "$Unique_App_Folder_Name"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_NAME_IN_MENU" "$Program_Name_In_Menu"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_EXECUTABLE_FILE" "$Program_Executable_File"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_EXE_RUN_IN_TERMINAL" "$Program_Exe_Run_In_Terminal"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_ICON_IN_MENU" "$Program_Icon_In_Menu"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_FILE" "$Program_Uninstaller_File"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_ICON" "$Program_Uninstaller_Icon"
			_PREPARE_INPUT_FILES_GREP "ADDITIONAL_CATEGORIES" "$Additional_Categories"
			_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_NAME" "$Menu_Directory_Name"
			_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_ICON" "$Menu_Directory_Icon"
		done
	
		local All_Renamed=false
		while [ $All_Renamed == false ]; do
			if find "$Temp_Dir/" -name "UNIQUE_APP_FOLDER_NAME*" | sed -e "p;s~UNIQUE_APP_FOLDER_NAME~$Unique_App_Folder_Name~" | xargs -n2 mv &> /dev/null; then
				All_Renamed=true
			fi
		done
		
		#for file in `find "$Temp_Dir/" -type d -name 'UNIQUE_APP_FOLDER_NAME*'`; do
		#	mv $file `echo $file | sed "s~UNIQUE_APP_FOLDER_NAME~$Unique_App_Folder_Name~"`
		#done
		
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
		
		if [ $DEBUG_MODE == true ]; then echo "_PREPARE_INPUT_FILES - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_PREPARE_INPUT_FILES\""; fi
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
	
			echo -e "\
  Folders|Files already present:
$(for file in "${!arr_files_sorted[@]}"; do echo "   ${arr_files_sorted[$file]}"; done)"
			echo -e "\
  
  Continue installation and overwrite directories/files?
  Please make a backup copy of your data, if any, in the above directories.
  
  Enter \"y\" or \"yes\" to continue."
			read install_confirm
			if [ "$install_confirm" == "y" ] || [ "$install_confirm" == "yes" ]; then all_ok=true
			else _ABORT "$Str_Interrupted_By_User"; fi
		else
			all_ok=true
		fi
		
		if [ $DEBUG_MODE == true ]; then echo "_CHECK_OUTPUTS - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_CHECK_OUTPUTS\""; fi
}


######### -------------------
######### Install application
function _INSTALL_APP() {
	if [ $all_ok == true ]; then all_ok=false
		if [ $Silent_Mode == false ]; then
			clear
			echo -e "\
$Header
 ${Bold}${F_Cyan}Installing...${F}${rBD}"
		fi
		
		# Copy Application files
		
		if [ $Silent_Mode == false ]; then
			echo " Create output folder if it does not exist..."
		fi
		
		if [ ! -e "$Output_Install_Dir" ]; then
			if [ "$Install_Mode" == "System" ]; then if ! sudo mkdir -p "$Output_Install_Dir"; then _ABORT "No rights to continue installation?"; fi; fi
			if [ "$Install_Mode" == "User" ]; then if ! mkdir -p "$Output_Install_Dir"; then _ABORT "No rights to continue installation?"; fi; fi
		else
			if [ "$Install_Mode" == "System" ]; then if ! sudo touch "$Output_Install_Dir"; then _ABORT "No rights to continue installation?"; fi; fi
			if [ "$Install_Mode" == "User" ]; then if ! touch "$Output_Install_Dir"; then _ABORT "No rights to continue installation?"; fi; fi
		fi
		
		if [ $Silent_Mode == false ]; then
			echo " Unpack application files..."
		fi
		
		if [ "$Install_Mode" == "System" ]; then
			if ! sudo "$Szip_bin" x -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
				echo -e "\n ATTENTION!!! Error unpacking program files..."
				echo " Broken archive? Or symbolic links with absolute paths as part of an application?"
				echo -e "\n $Str_y_or_yes_continue"
				read confirm_error_unpacking
				if [ "$confirm_error_unpacking" == "y" ] || [ "$confirm_error_unpacking" == "yes" ]; then
					echo "  Continue..."
				else _ABORT "$Str_INSTALLAPP_Error_Unpack_ProgramFiles"; fi
			fi
		fi
		
		if [ "$Install_Mode" == "User" ]; then
			if ! "$Szip_bin" x -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
				echo -e "\n ATTENTION!!! Error unpacking program files..."
				echo " Broken archive? Or symbolic links with absolute paths as part of an application?"
				echo -e "\n $Str_y_or_yes_continue"
				read confirm_error_unpacking
				if [ "$confirm_error_unpacking" == "y" ] || [ "$confirm_error_unpacking" == "yes" ]; then
					echo "  Continue..."
				else _ABORT "$Str_INSTALLAPP_Error_Unpack_ProgramFiles"; fi
			fi
		fi
		
		if [ $Silent_Mode == false ]; then
			echo " Install Bin files and copy menu files..." 
		fi
		
		######### System MODE #########
		if [ "$Install_Mode" == "System" ]; then
			echo " Set rights and owner..."
			sudo chmod -R $Out_App_Folder_Permissions "$Output_Install_Dir"
			sudo chown -R $Out_App_Folder_Owner "$Output_Install_Dir"
			
			# Copy Bin files
			sudo cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
			
			# Сopy Menu files
			sudo cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
			sudo cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
			sudo cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
		fi
	
		######### User MODE #########
		if [ "$Install_Mode" == "User" ]; then
			
			if [ ! -e "$Output_Bin_Dir" ]; then mkdir "$Output_Bin_Dir"; fi
			
			# Copy Bin files
			cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
			
			# Сopy Menu files
			cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
			cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
			cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
		fi
		
		# Copy user data
		if [ $User_Data_Copy_Confirm == true ]; then
			if [ $Silent_Mode == false ]; then
				echo " Copy User files..."
			fi
			
			if ! "$Szip_bin" x -aoa "$Archive_User_Files" -o"$Output_User_Home/" &> /dev/null; then
				echo "Error unpacking user files..."
				read pause
			fi
		fi
		
		all_ok=true
		
		if [ $DEBUG_MODE == true ]; then echo "_INSTALL_APP - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_INSTALL_APP\""; fi
}


######### ------------------------
######### Prepare uninstaller file
function _PREPARE_UNINSTALLER() {
	if [ $all_ok == true ]; then
		if [ "$Install_Mode" == "System" ]; then
			sudo chmod 755 "$Output_Uninstaller"
			sudo chown $Out_App_Folder_Owner "$Output_Uninstaller"
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
		
		if [ $Silent_Mode == false ]; then
			_ABORT "$Str_Complete_Install"
		fi
		
		if [ $DEBUG_MODE == true ]; then echo "_PREPARE_UNINSTALLER - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_Error_All_Ok \"_PREPARE_UNINSTALLER\""; fi
}

######### ---- --------- ---- #########
######### -- END FUNCTIONS -- #########
######### ---- --------- ---- #########

## START ##

_MAIN

## End ##

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
