#!/usr/bin/env bash
# Script version 2.0
# LICENSE for this script is at the end of this file
# FreeSpace=$(df -m "$Out_InstallDir" | grep "/" | awk '{print $4}')
Arguments=("$@")

# Main function, don't change!
function _MAIN() {
	_INIT_GLOBAL_VARIABLES
	_INSTALLER_SETTINGS
	_CHECK_SYSTEM
	_SET_LOCALE
	_CHECK_SYSTEM_DE
	_INIT_FONT_STYLES
	_CLEAR_BACKGROUND # Double Clear Crutch for Old GNOME...
	_PACKAGE_SETTINGS
	_INIT_GLOBAL_PATHS
	_CECK_EXECUTE_RIGHTS
	printf '\033[8;32;110t' # Resize terminal Window (110x32)
	_CHECK_PORTSOFT
	_CHECK_ERRORS
	_PRINT_PACKAGE_INFO
	_CHECK_MD5
	_PRINT_INSTALL_SETTINGS # Last confirm stage
	_CREATE_TEMP
	_PREPARE_INPUT_FILES
	_CHECK_OUTPUTS
	_INSTALL_APPLICATION
	_PREPARE_UNINSTALLER
	_POST_INSTALL
}

function _INSTALLER_SETTINGS() {
	Tools_Architecture="x86_64"   # x86_64, x86
	Program_Architecture="script" # x86_64, x86, script, other
	
	Install_Mode="User"           # "System" / "User", In "User" mode, root rights are not required.
	Install_Desktop_Icons=true    # Place icons on the desktop (only for current user).
	Install_Helpers=false         # XFCE Only! Adds "Default Applications" associations, please prepare files in "installer-data/system_files/helpers/" before using.
	
	# Copy data to the "userdata" directory.
	#  For example:
	#   Install path:  /home/USER/.local/portsoft/script/example-application-20
	#   UserData path: /home/USER/.local/portsoft/script/example-application-20/userdata
	#
	# This can help avoid application version conflicts, but requires special preparation.
	# Do not use for applications installed in "System" mode!
	# Please see the example before using this function - "installer-data/program_files/run-force-userdata.sh", and configure the system files accordingly.
	Install_User_Data=true
	
	Debug_Test_Colors=false       # Test colors (for debugging purposes)
	Font_Styles_RGB=false         # Disabled for compatibility with older distributions, can be enabled manually.
}

function _PACKAGE_SETTINGS() {
######### ---- -------- ---- #########
######### ---- SETTINGS ---- #########
######### ---- -------- ---- #########

Unique_App_Folder_Name="example-application-20" #=> UNIQUE_APP_FOLDER_NAME

 # Unique name of the output directory.
 # WARNING! Do not use capital letters in this place!
 # WARNING! This name is also used as a template for "bin" files in the "/usr/bin" directory.
 # good: ex-app-16, exapp-16.
 # BAD: Ex-app-16, ExApp-16.

######### - ------------------- - #########
######### - Package Information - #########
######### - ------------------- - #########

Info_Name="Example Application"
Info_Version="2.0"
Info_Release_Date="2024-12-xx"
Info_Category="Other"
Info_Platform="Linux"
Info_Installed_Size="~1 MiB"
Info_Licensing="Freeware - Open Source (MIT)
   Other Licensing Examples:
    Freeware - Proprietary (EULA, Please read \"EULA-example.txt\")
    Trialware - 30 days free, Proprietary (Other License Name)"
Info_Developer="Chimbal"
Info_URL="https://github.com/Shedou/Chimbalix-Software-Catalog"
if [ $Locale_Use_Default == true ]; then # Use this description if there is no suitable localization file:
Info_Description="\
  1) This universal installer (short description):
     - Suitable for installation on stand-alone PCs without Internet access.
     - Stores installation files in a 7-zip archive (good compression and fast unpacking).
  2) Check the current \"installer.sh\" file to configure the installation package."
fi

 ### ------------------------ ###
 ### Basic Menu File Settings ###
 ### ------------------------ ###
 # Please manually prepare the menu files in the "installer-data/system_files/" directory before packaging the application,
 # this functionality does not allow you to fully customize the menu files.
 # Use the variable names given in the comments to simplify the preparation of menu files.
Menu_Directory_Name="Example Application 2.0"   #=> MENU_DIRECTORY_NAME
Menu_Directory_Icon="icon.png"                  #=> MENU_DIRECTORY_ICON

Program_Executable_File="example-application"           #=> PROGRAM_EXECUTABLE_FILE
Program_Name_In_Menu="Example Application 2.0"          #=> PROGRAM_NAME_IN_MENU
Program_Icon_In_Menu="icon.png"                         #=> PROGRAM_ICON_IN_MENU
Program_Exe_Run_In_Terminal="true"                      #=> PROGRAM_EXE_RUN_IN_TERMINAL
Program_Install_Mode="$Install_Mode"                    #=> PROGRAM_INSTALL_MODE

Program_Uninstaller_File="ish-software-uninstaller.sh"          #=> PROGRAM_UNINSTALLER_FILE
Program_Uninstaller_Icon="ish-software-uninstaller-icon.png"    #=> PROGRAM_UNINSTALLER_ICON

 # Additional menu categories that will include the main application shortcuts.
 # Please do not use this variable in the uninstaller shortcut file.
Additional_Categories="chi-other;Utility;Education;" #=> ADDITIONAL_CATEGORIES
 # -=== Chimbalix 24.4+ main categories:
 # chi-ai  chi-accessories  chi-accessories-fm  chi-view  chi-admin  chi-info  chi-info-bench  chi-info-help
 # chi-dev  chi-dev-other  chi-dev-ide  chi-edit  chi-edit-audiovideo  chi-edit-image  chi-edit-text  chi-games
 # chi-network  chi-multimedia  chi-multimedia-players  chi-office  chi-other  chi-tools  chi-tools-archivers
 # -=== XDG / Linux Categories Version 1.1 (20 August 2016):
 # AudioVideo  Audio  Video  Development  Education  Game  Graphics  Network  Office  Science  Settings  System  Utility
 # URL: https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
 # URL: https://specifications.freedesktop.org/menu-spec/latest/additional-category-registry.html

 # Archives MD5 Hash
Archive_MD5_Program_Files_Hash=""
Archive_MD5_System_Files_Hash=""
Archive_MD5_User_Data_Hash="" # Not used if "Install_User_Data=false"

 # Header
Header="${Font_DarkYellow}${Font_Bold} -=: Universal Software Installer Script for Chimbalix (Installer-SH v2.0) - Lang: $Locale_Display :=-${Font_Reset}${Font_Reset_Color}\n"

######### -- ------------ -- #########
######### -- END SETTINGS -- #########
######### -- ------------ -- #########
}

function _TEST_COLORS() {
	echo -e "\n${Font_Bold} -= TEST COLORS =-"
	if [ "$Font_Styles_RGB" == true ]; then echo -e " RGB Mode"
	else echo -e " 8-bit table Mode"; fi
	echo -e "
 ${Font_Black}Font_Black ${Font_DarkGray}Font_DarkGray ${Font_Gray}Font_Gray ${Font_White}Font_White ${Font_Reset_Color}

 ${Font_DarkRed}DarkRed ${Font_DarkGreen}DarkGreen ${Font_DarkYellow}DarkYellow ${Font_DarkBlue}DarkBlue ${Font_DarkMagenta}DarkMagenta ${Font_DarkCyan}DarkCyan
 ${Font_Red}Red     ${Font_Green}Green     ${Font_Yellow}Yellow     ${Font_Blue}Blue     ${Font_Magenta}Magenta     ${Font_Cyan}Cyan
 ${Font_Reset_Color}
 ${Font_Black_BG} Black_BG ${Font_DarkGray_BG} DarkGray_BG ${Font_Black}${Font_Gray_BG} Gray_BG ${Font_White_BG} White_BG ${Font_Reset_BG} ${Font_Reset_Color}
 ${Font_DarkRed_BG} DRed_BG ${Font_DarkGreen_BG} DGreen_BG ${Font_DarkYellow_BG} DYellow_BG ${Font_DarkBlue_BG} DBlue_BG ${Font_DarkMagenta_BG} DMagenta_BG ${Font_DarkCyan_BG} DCyan_BG ${Font_Reset_BG}
 ${Font_Black}${Font_Red_BG} Red_BG  ${Font_Green_BG} Green_BG  ${Font_Yellow_BG} Yellow_BG  ${Font_Blue_BG} Blue_BG  ${Font_Magenta_BG} Magenta_BG  ${Font_Cyan_BG} Cyan_BG  ${Font_Reset_BG}${Font_Reset_Color}"
}

function _INIT_FONT_STYLES() {
	### Font styles: "${Font_Bold} BLACK TEXT ${Font_Reset} normal text."
	# '\e[38;2;128;128;255m'
	#     fg m  R   G   B
	# \e - escape code, [38 - foreground, [48 - background
	#
	### Old distributions do not support the RGB method, you need to make crutches...
	# '\033[38;5;165m'
	# 165m - 8 bit color number
	
	Font_Bold="\e[1m"
	Font_Dim="\e[2m"
	Font_Reset="\e[22m"
	Font_Reset_Color='\e[38;5;255m'
	Font_Reset_BG='\e[48;5;16m'
	
	Font_Black='\e[38;5;233m'; Font_Black_BG='\e[48;5;233m'
	Font_DarkGray='\e[38;5;240m'; Font_DarkGray_BG='\e[48;5;240m'
	Font_Gray='\e[38;5;248m'; Font_Gray_BG='\e[48;5;248m'
	Font_White='\e[38;5;255m'; Font_White_BG='\e[48;5;255m'
	
	if [ "$Font_Styles_RGB" == true ]; then
		Font_DarkRed='\e[38;2;200;0;0m'; Font_DarkRed_BG='\e[48;2;200;0;0m'
		Font_DarkGreen='\e[38;2;0;180;0m'; Font_DarkGreen_BG='\e[48;2;0;180;0m'
		Font_DarkYellow='\e[38;2;180;146;0m'; Font_DarkYellow_BG='\e[48;2;180;146;0m'
		Font_DarkBlue='\e[38;2;72;72;230m'; Font_DarkBlue_BG='\e[48;2;72;72;230m'
		Font_DarkMagenta='\e[38;2;200;0;200m'; Font_DarkMagenta_BG='\e[48;2;200;0;200m'
		Font_DarkCyan='\e[38;2;40;180;160m'; Font_DarkCyan_BG='\e[48;2;40;180;160m'
		
		Font_Red='\e[38;2;255;96;96m'; Font_Red_BG='\e[48;2;255;96;96m'
		Font_Green='\e[38;2;128;255;128m'; Font_Green_BG='\e[48;2;128;255;128m'
		Font_Yellow='\e[38;2;245;245;64m'; Font_Yellow_BG='\e[48;2;245;245;64m'
		Font_Blue='\e[38;2;160;160;255m'; Font_Blue_BG='\e[48;2;160;160;255m'
		Font_Magenta='\e[38;2;255;96;255m'; Font_Magenta_BG='\e[48;2;255;96;255m'
		Font_Cyan='\e[38;2;90;255;240m'; Font_Cyan_BG='\e[48;2;90;255;240m'
	else # For compatibility with older distributions...
		Font_DarkRed='\e[38;5;160m'; Font_DarkRed_BG='\e[48;5;160m'
		Font_DarkGreen='\e[38;5;34m'; Font_DarkGreen_BG='\e[48;5;34m'
		Font_DarkYellow='\e[38;5;178m'; Font_DarkYellow_BG='\e[48;5;178m'
		Font_DarkBlue='\e[38;5;63m'; Font_DarkBlue_BG='\e[48;5;63m'
		Font_DarkMagenta='\e[38;5;164m'; Font_DarkMagenta_BG='\e[48;5;164m'
		Font_DarkCyan='\e[38;5;37m'; Font_DarkCyan_BG='\e[48;5;37m'
		
		Font_Red='\e[38;5;210m'; Font_Red_BG='\e[48;5;210m'
		Font_Green='\e[38;5;82m'; Font_Green_BG='\e[48;5;82m'
		Font_Yellow='\e[38;5;226m'; Font_Yellow_BG='\e[48;5;226m'
		Font_Blue='\e[38;5;111m'; Font_Blue_BG='\e[48;5;111m'
		Font_Magenta='\e[38;5;213m'; Font_Magenta_BG='\e[48;5;213m'
		Font_Cyan='\e[38;5;51m'; Font_Cyan_BG='\e[48;5;51m'
	fi
}

######### ---------------- #########
######### ---------------- #########
######### ---------------- #########
######### ---------------- #########
######### Global variables #########

function _INIT_GLOBAL_VARIABLES() {
	### --------------------------- ###
	### Do not edit variables here! ###
	### --------------------------- ###
	
	Font_Bold=""; Font_Dim=""; Font_Reset=""; Font_Reset_Color=''; Font_Reset_BG=''
	Font_Black=''; Font_Black_BG=''; Font_DarkGray=''; Font_DarkGray_BG=''; Font_Gray=''; Font_Gray_BG=''; Font_White=''; Font_White_BG=''
	Font_DarkRed=''; Font_DarkRed_BG=''; Font_DarkGreen=''; Font_DarkGreen_BG=''; Font_DarkYellow=''; Font_DarkYellow_BG=''; Font_DarkBlue=''; Font_DarkBlue_BG=''
	Font_DarkMagenta=''; Font_DarkMagenta_BG=''; Font_DarkCyan=''; Font_DarkCyan_BG=''
	Font_Red=''; Font_Red_BG=''; Font_Green=''; Font_Green_BG=''; Font_Yellow=''; Font_Yellow_BG=''; Font_Blue=''; Font_Blue_BG=''
	Font_Magenta=''; Font_Magenta_BG=''; Font_Cyan=''; Font_Cyan_BG=''
	
	all_ok=true
	Locale_Use_Default=true # don't change!
	Locale_Display="Default"
	Current_Architecture="Unknown"
	
	User_Name="$USER"
	User_Home="$HOME"
	User_Desktop_Dir="$User_Home/Desktop"
	if [ -e "$User_Home/.config/user-dirs.dirs" ]; then
		source "$User_Home/.config/user-dirs.dirs"; User_Desktop_Dir="$XDG_DESKTOP_DIR"; fi
	
	MODE_DEBUG=false
	MODE_SILENT=false; if [ "${Arguments[$1]}" == "-silent" ]; then MODE_SILENT=true; fi
	
	Path_To_Script="$( dirname "$(readlink -f "$0")")"
	Path_Installer_Data="$Path_To_Script/installer-data"
	
	List_Errors=""    # _ERROR "Title" "Message."
	List_Warnings=""  # _WARNING "Title" "Message."
	
	Current_DE="UnknownDE"
	                                # os-release (main)    example (Chimbalix 24.5+)  lsb-release
	Current_OS_Name_Full="Unknown"  # PRETTY_NAME         "Chimbalix 24.5 Alphachi"   DISTRIB_DESCRIPTION
	Current_OS_Name="Unknown"       # NAME                "Chimbalix"                 DISTRIB_ID
	Current_OS_Name_ID="Unknown"    # ID                  "chimbalix"                 DISTRIB_ID
	Current_OS_Version="Unknown"    # VERSION_ID          "24.5"                      DISTRIB_RELEASE
	Current_OS_Codename="Unknown"   # VERSION_CODENAME    "alphachi"                  DISTRIB_CODENAME
}

function _INIT_GLOBAL_PATHS() {
	### --------------------------- ###
	### Do not edit variables here! ###
	### --------------------------- ###
	
	if [ "$Tools_Architecture" == "x86" ]; then
		Tool_SevenZip_bin="$Path_Installer_Data/tools/7zip/7zzs-x86"
	else
		Tool_SevenZip_bin="$Path_Installer_Data/tools/7zip/7zzs"
	fi
	
	Tool_Gio_Trust_Xfce="$Path_Installer_Data/tools/gio-trust-xfce.sh"
	Tool_Prepare_Base="$Path_Installer_Data/tools/prepare-portsoft-menu.sh"
	
	Archive_Program_Files="$Path_Installer_Data/program_files.7z"
	Archive_System_Files="$Path_Installer_Data/system_files.7z"
	Archive_User_Data="$Path_Installer_Data/user_files.7z"
	if [ ! -e "$Archive_User_Data" ] && [ $Install_User_Data == true ]; then
		Install_User_Data=false; _WARNING "_INIT_GLOBAL_PATHS" "Archive_User_Data not found, Install_User_Data is disabled.\n   Please correct the settings according to the application."; fi # Extra check
	
	# Application installation directory.
	Out_PortSoft_System="/portsoft"
	Out_PortSoft_User="$User_Home/.local/portsoft"
	
	Out_Install_Dir_System="$Out_PortSoft_System/$Program_Architecture/$Unique_App_Folder_Name"
	Out_Install_Dir_User="$Out_PortSoft_User/$Program_Architecture/$Unique_App_Folder_Name"
	
	Out_App_Folder_Owner=root:root  # Only for "System" mode, username:group
	Out_App_Folder_Permissions=755  # Only for "System" mode.
	
	Temp_Dir="/tmp/installer-sh/$Unique_App_Folder_Name""_$RANDOM""_$RANDOM" # TEMP Directory
	
	Input_Bin_Dir="$Temp_Dir/bin"
	Input_Helpers_Dir="$Temp_Dir/xfce4/helpers"
	Input_Desktop_Dir="$Temp_Dir/desktop"
	Input_Menu_Files_Dir="$Temp_Dir/menu/applications-merged"
	Input_Menu_Desktop_Dir="$Temp_Dir/menu/desktop-directories/apps"
	Input_Menu_Apps_Dir="$Temp_Dir/menu/apps"
	
	Out_User_Bin_Dir="$User_Home/.local/bin" # Works starting from Chimbalix 24.4
	Out_User_Helpers_Dir="$User_Home/.local/share/xfce4/helpers"
	Out_User_Desktop_Dir="$User_Desktop_Dir"
	Out_User_Menu_Files="$User_Home/.config/menus/applications-merged"
	Out_User_Menu_DDir="$User_Home/.local/share/desktop-directories/apps"
	Out_User_Menu_Apps="$User_Home/.local/share/applications/apps"
	
	Out_System_Bin_Dir="/usr/bin"
	Out_System_Helpers_Dir="/usr/share/xfce4/helpers"
	Out_System_Menu_Files="/etc/xdg/menus/applications-merged"
	Out_System_Menu_DDir="/usr/share/desktop-directories/apps"
	Out_System_Menu_Apps="/usr/share/applications/apps"
	
	Temp_Test="/tmp/installer-sh"
	
	# The "PATH_TO_FOLDER" variable points to the application installation directory without the trailing slash (Output_Install_Dir), for example "/portsoft/x86_64/example_application".
	Output_Install_Dir="/tmp/ish"; Output_Bin_Dir="/tmp/ish"; Output_Helpers_Dir="/tmp/ish"; Output_Desktop_Dir="$Out_User_Desktop_Dir"
	Output_Menu_Files="/tmp/ish"; Output_Menu_DDir="/tmp/ish"; Output_Menu_Apps="/tmp/ish"; Output_User_Data="$Out_Install_Dir_User/userdata"
	Output_PortSoft="/tmp/ish"
	
	if [ "$Install_Mode" == "System" ]; then
		Output_Install_Dir="$Out_Install_Dir_System"; Output_Bin_Dir="$Out_System_Bin_Dir"; Output_Helpers_Dir="$Out_System_Helpers_Dir"
		Output_Menu_Files="$Out_System_Menu_Files"; Output_Menu_DDir="$Out_System_Menu_DDir"; Output_Menu_Apps="$Out_System_Menu_Apps"
		Output_PortSoft="$Out_PortSoft_System"
	else
		Output_Install_Dir="$Out_Install_Dir_User"; Output_Bin_Dir="$Out_User_Bin_Dir"; Output_Helpers_Dir="$Out_User_Helpers_Dir"
		Output_Menu_Files="$Out_User_Menu_Files"; Output_Menu_DDir="$Out_User_Menu_DDir"; Output_Menu_Apps="$Out_User_Menu_Apps"
		Output_PortSoft="$Out_PortSoft_User"
	fi
	
	Output_Files_All=("/tmp/ish") # Files list for Uninstaller
	Output_Uninstaller="$Output_Install_Dir/$Program_Uninstaller_File" # Uninstaller template file.
}

######### Global variables #########
######### ---------------- #########
######### ---------------- #########
######### ---------------- #########
######### ---------------- #########

######### -------------- #########
######### Base functions #########

function _CLEAR_BACKGROUND() {
	#setterm -background black -clear
	#setterm -foreground white -clear
	clear
	clear
	echo -ne '\e]11;black\e\\'
	echo -ne '\e[48;5;232m' # Crutch for GNOME...
	echo -ne '\e]10;white\e\\'
	echo -ne '\e[38;5;255m' # Crutch for GNOME...
}

function _CLEAR_TEMP() {
	if [ ! -z "$Temp_Dir" ]; then
		if [ -e "$Temp_Dir" ]; then
			local clear_temp_test="$(echo "$Temp_Dir" | cut -d/ -f 1-3)"
			if [ "$clear_temp_test" == "$Temp_Test" ]; then
				if ! rm -rf "$Temp_Dir"; then _ABORT "Error clearinG temporary directory...\n   ($Temp_Dir)"; fi
			else _ABORT "$clear_temp_test != $Temp_Test"; fi
		fi
	fi
}

function _CREATE_TEMP() {
	if [ ! -z "$Temp_Dir" ]; then
		_CLEAR_TEMP
		local create_temp_test="$(echo "$Temp_Dir" | cut -d/ -f 1-3)"
		if [ "$create_temp_test" == "$Temp_Test" ]; then
			if ! mkdir -p "$Temp_Dir"; then _ABORT "Error Creating temporary directory...\n   ($Temp_Dir)"; fi
		else _ABORT "$create_temp_test != $Temp_Test"; fi
	fi
}

function _ABORT() {
	_CLEAR_BACKGROUND
	
	if [ -z "$Header" ];             then local Header=" -= OPERATING SYSTEM NOT SUPPORTED? =-\n"; fi
	if [ -z "$Str_ABORT_Msg" ];      then local Str_ABORT_Msg="Exit code -"; fi
	if [ -z "$Str_ABORT_Exit" ];     then local Str_ABORT_Exit="Press Enter or close the window to exit."; fi
	if [ -z "$Str_ABORT_Errors" ];   then local Str_ABORT_Errors="Errors:"; fi
	if [ -z "$Str_ABORT_Warnings" ]; then local Str_ABORT_Warnings="Warnings:"; fi
	
	local abort_message="${Font_Red}message not set...${Font_Reset_Color}"
	if [ ! -z "$1" ]; then local abort_message="$1"; fi
	
	echo -e "\
$Header
  $Str_ABORT_Msg $abort_message"
	
	if [ "$List_Errors" != "" ]; then echo -e "
  ${Font_Bold}${Font_Red}- $Str_ABORT_Errors${Font_Reset_Color}${Font_Reset} $List_Errors"; fi
	
	if [ "$List_Warnings" != "" ]; then echo -e "
  ${Font_Bold}${Font_Yellow}- $Str_ABORT_Warnings${Font_Reset_Color}${Font_Reset} $List_Warnings"; fi
	
	echo -e "
  $Str_ABORT_Exit
  $Temp_Dirt"
	
	_CLEAR_TEMP
	
	read pause; clear; exit 1 # Double clear resets styles before going to the system terminal window.
}

function _ERROR() {
	local err_first="Empty error title"
	local err_second="empty error description."
	if [ ! -z "$1" ]; then local err_first="$1"; fi
	if [ ! -z "$2" ]; then local err_second="$2"; fi
	
	List_Errors="${List_Errors}\n    $err_first - $err_second"
}

function _WARNING() {
	local warn_first="Empty warning title"
	local warn_second="empty warning description."
	if [ ! -z "$1" ]; then local warn_first="$1"; fi
	if [ ! -z "$2" ]; then local warn_second="$2"; fi
	
	List_Warnings="${List_Warnings}\n    $warn_first - $warn_second"
}

######### Base functions #########
######### -------------- #########

######### ------------ #########
######### Check System #########

function _CHECK_SYSTEM_VERSION() {
	if [ -f "/etc/os-release" ]; then source "/etc/os-release"
		Current_OS_Name_Full="$PRETTY_NAME"
		Current_OS_Name="$NAME"
		Current_OS_Name_ID="$ID"
		Current_OS_Version="$VERSION_ID"
		Current_OS_Codename="$VERSION_CODENAME"
	elif [ -f "/etc/lsb-release" ]; then source "/etc/lsb-release"
		Current_OS_Name_Full="$DISTRIB_DESCRIPTION"
		Current_OS_Name="$DISTRIB_ID"
		Current_OS_Name_ID="$DISTRIB_ID"
		Current_OS_Version="$DISTRIB_RELEASE"
		Current_OS_Codename="$DISTRIB_CODENAME"
	else
		if type uname &>/dev/null; then DistroVersion="$(uname -sr)"
		else _ABORT "The name of the operating system / kernel is not defined!"; fi
	fi
}

function _CHECK_SYSTEM_DE() {
	local check_de_raw=""
	local check_de_err="0"
	
	if   [ $XDG_CURRENT_DESKTOP ]; then local check_de_raw="$(echo "$XDG_CURRENT_DESKTOP" | cut -d: -f 1)"
	elif [ $XDG_SESSION_DESKTOP ]; then _WARNING "XDG_CURRENT_DESKTOP" "$Str_CHECKSYSDE_NotFound"; local check_de_raw="$XDG_SESSION_DESKTOP"
	elif [ $DESKTOP_SESSION ];     then _WARNING "XDG_SESSION_DESKTOP" "$Str_CHECKSYSDE_NotFound"; local check_de_raw="$DESKTOP_SESSION"
	else _WARNING "DESKTOP_SESSION" "$Str_CHECKSYSDE_NotFound"; fi
	
	# Normalize
	### COSMIC - GNOME - KDE - LXDE - LXQT - MATE - RAZOR - ROX - TDE - UNITY - XFCE - EDE - CINNAMON - PANTHEON - DDE - ENDLESS - LEGACY - BUDGIE - OPENBOX - SWAY
	if [ "$check_de_raw" == "COSMIC" ];            then local check_de_raw="COSMIC" # COSMIC Desktop
	elif [ "$check_de_raw" == "GNOME" ];           then local check_de_raw="GNOME"  # GNOME Desktop
	elif [ "$check_de_raw" == "GNOME-Classic" ];   then local check_de_raw="GNOME"  # GNOME Classic Desktop
	elif [ "$check_de_raw" == "GNOME-Flashback" ]; then local check_de_raw="GNOME"  # GNOME Flashback Desktop
	elif [ "$check_de_raw" == "KDE" ];      then local check_de_raw="KDE"      # KDE Desktop
	elif [ "$check_de_raw" == "LXDE" ];     then local check_de_raw="LXDE"     # LXDE Desktop
	elif [ "$check_de_raw" == "LXQt" ];     then local check_de_raw="LXQT"     # LXQt Desktop
	elif [ "$check_de_raw" == "MATE" ];     then local check_de_raw="MATE"     # MATE Desktop
	elif [ "$check_de_raw" == "Razor" ];    then local check_de_raw="RAZOR"    # Razor-qt Desktop
	elif [ "$check_de_raw" == "ROX" ];      then local check_de_raw="ROX"      # ROX Desktop
	elif [ "$check_de_raw" == "TDE" ];      then local check_de_raw="TDE"      # Trinity Desktop
	elif [ "$check_de_raw" == "Unity" ];    then local check_de_raw="UNITY"    # Unity Shell
	elif [ "$check_de_raw" == "XFCE" ];     then local check_de_raw="XFCE"     # XFCE Desktop
	elif [ "$check_de_raw" == "EDE" ];      then local check_de_raw="EDE"      # EDE Desktop
	elif [ "$check_de_raw" == "Cinnamon" ]; then local check_de_raw="CINNAMON" # Cinnamon Desktop
	elif [ "$check_de_raw" == "Pantheon" ]; then local check_de_raw="PANTHEON" # Pantheon Desktop
	elif [ "$check_de_raw" == "DDE" ];      then local check_de_raw="DDE"      # Deepin Desktop
	elif [ "$check_de_raw" == "Endless" ];  then local check_de_raw="ENDLESS"  # Endless OS desktop
	elif [ "$check_de_raw" == "Old" ];      then local check_de_raw="LEGACY"   # Legacy menu systems
	elif [ "$check_de_raw" == "plasma" ];   then local check_de_raw="KDE" ### Extra names
	elif [ "$check_de_raw" == "xfce" ];     then local check_de_raw="XFCE"
	elif [ "$check_de_raw" == "xubuntu" ];  then local check_de_raw="XFCE"
	elif [ "$check_de_raw" == "lxde" ];     then local check_de_raw="LXDE"
	elif [ "$check_de_raw" == "mate" ];     then local check_de_raw="MATE"
	elif [ "$check_de_raw" == "ubuntu" ];   then local check_de_raw="GNOME"
	elif [ "$check_de_raw" == "lxqt" ];     then local check_de_raw="LXQT"
	elif [ "$check_de_raw" == "Lubuntu" ];  then local check_de_raw="LXQT"
	elif [ "$check_de_raw" == "cinnamon" ];       then local check_de_raw="CINNAMON"
	elif [ "$check_de_raw" == "X-Cinnamon" ];     then local check_de_raw="CINNAMON"
	elif [ "$check_de_raw" == "budgie-desktop" ]; then local check_de_raw="BUDGIE"
	elif [ "$check_de_raw" == "Budgie" ];         then local check_de_raw="BUDGIE"
	elif [ "$check_de_raw" == "openbox" ];        then local check_de_raw="OPENBOX"
	elif [ "$check_de_raw" == "sway" ];           then local check_de_raw="SWAY"
	else local check_de_err="1"; fi
	
	if [ "$check_de_err" == "1" ]; then
		_WARNING "$Str_CHECKSYSDE_DE_CHECK" "$Str_CHECKSYSDE_XDG_INFO_INCORRECT"
		
		if xfce4-session --version &>/dev/null;    then local check_de_raw="XFCE"
		elif plasmashell --version &>/dev/null;    then local check_de_raw="KDE"
		elif plasma-desktop --version &>/dev/null; then local check_de_raw="KDE"
		elif gnome-shell --version &>/dev/null;    then local check_de_raw="GNOME"
		fi
fi
	
	# Extra checks
	if [ "$check_de_raw" == "OPENBOX" ]; then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Openbox)" "$Str_CHECKSYSDE_DE_WEIRD_OPENBOX"; fi
	if [ "$check_de_raw" == "SWAY" ];    then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Sway)" "$Str_CHECKSYSDE_DE_WEIRD_SWAY"; fi
	if [ "$check_de_raw" == "LXQT" ];    then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (LXQt)" "$Str_CHECKSYSDE_DE_WEIRD_LXQT"; fi
	if [ "$check_de_raw" == "BUDGIE" ];  then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Budgie)" "$Str_CHECKSYSDE_DE_WEIRD_BUDGIE"; fi
	if [ "$check_de_raw" == "GNOME" ];   then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (GNOME)" "$Str_CHECKSYSDE_DE_WEIRD_GNOME"; fi
	
	
	Current_DE="$check_de_raw"
}

function _CHECK_SYSTEM() {
	# Check System Version
	_CHECK_SYSTEM_VERSION
	
	Current_Architecture="$(uname -m)"
	
	# Normalize Arch
	if [ "$Current_Architecture" == "i686" ]; then Current_Architecture="x86"; fi
	
	if [ "$Tools_Architecture" != "$Current_Architecture" ]; then
		if [ "$Current_OS_Name" == "Chimbalix" ]; then : # Chimbalix has 32-bit libraries, so it is possible to work within this distribution.
		else _ABORT "The system architecture ($Current_Architecture) does not match the selected tools architecture ($Tools_Architecture)!"; fi
	fi
	
	#if [ "$Current_OS_Name" == "Chimbalix" ]; then Font_Styles_RGB=true; fi
}

######### Check PortSoft #########
######### -------------- #########

function _CHECK_PORTSOFT() {
	# Check PortSoft
	if [ "$Current_OS_Name" != "Chimbalix" ]; then
		if [ ! -e "$Output_PortSoft" ] || [ ! -e "$Output_Menu_DDir" ]; then
			if ! [[ -x "$Tool_Prepare_Base" ]]; then chmod +x "$Tool_Prepare_Base"; fi
			source "$Tool_Prepare_Base"
			_CLEAR_BACKGROUND
		fi
	fi
}

######### Check PortSoft #########
######### -------------- #########

######### ------------ #########
######### Check Errors #########

function _CHECK_ERRORS() {
	if [ "$Tools_Architecture" != "$Current_Architecture" ]; then _WARNING "$Str_CHECK_ERRORS_ARCH" "$Str_CHECK_ERRORS_ARCH_WARN"; fi
}

######### Check Errors #########
######### ------------ #########

######### ------------------------- #########
######### Print package information #########

function _PRINT_PACKAGE_INFO() {
if [ $MODE_SILENT == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_PACKAGEINFO_Head${Font_Reset_Color}${Font_Reset}
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Name${Font_Reset_Color} $Info_Name${Font_Reset} ($Info_Version, $Program_Architecture)
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_ReleaseDate${Font_Reset}${Font_Reset_Color} $Info_Release_Date
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Category${Font_Reset}${Font_Reset_Color} $Info_Category
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Platform${Font_Reset}${Font_Reset_Color} $Info_Platform
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_InstalledSize${Font_Reset}${Font_Reset_Color} $Info_Installed_Size
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Licensing${Font_Reset}${Font_Reset_Color} $Info_Licensing
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Developer${Font_Reset}${Font_Reset_Color} $Info_Developer
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_URL${Font_Reset}${Font_Reset_Color} $Info_URL
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Description${Font_Reset_Color}${Font_Reset}
$Info_Description

 -${Font_Bold}${Font_Green}$Str_PACKAGEINFO_CurrentOS${Font_Reset_Color} $Current_OS_Name_Full ($Current_DE)${Font_Reset}
 -${Font_Bold}${Font_Green}$Str_PACKAGEINFO_InstallMode${Font_Reset_Color} $Install_Mode${Font_Reset}"
	
	if [ "$List_Errors" != "" ]; then echo -e "
  ${Font_Bold}${Font_Red}- $Str_ABORT_Errors${Font_Reset_Color}${Font_Reset} $List_Errors"; fi
	
	if [ "$List_Warnings" != "" ]; then echo -e "
  ${Font_Bold}${Font_Yellow}- $Str_ABORT_Warnings${Font_Reset_Color}${Font_Reset} $List_Warnings"; fi
	
	if [ "$Debug_Test_Colors" == true ]; then _TEST_COLORS; fi
	
		echo -e "\n $Str_PACKAGEINFO_Confirm"
		read package_info_confirm
		if [ "$package_info_confirm" == "y" ] || [ "$package_info_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
		
		if [ $MODE_DEBUG == true ]; then echo "_PRINT_PACKAGE_INFO - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _PRINT_PACKAGE_INFO ${Font_Reset_Color}${Font_Reset}"; fi
fi
}

######### Print package information #########
######### ------------------------- #########

######### -------------------------------- #########
######### Check and compare MD5 of archive #########

function _CHECK_MD5_COMPARE() {
	MD5_ProgramFiles_Error=false; MD5_SystemFiles_Error=false; MD5_UserFiles_Error=false
	MD5_Warning=false;
	
	MD5_Program_Files_Hash=`md5sum "$Archive_Program_Files" | awk '{print $1}'`
	MD5_System_Files_Hash=`md5sum "$Archive_System_Files" | awk '{print $1}'`
	
	if [ "$MD5_Program_Files_Hash" != "$Archive_MD5_Program_Files_Hash" ]; then MD5_ProgramFiles_Error=true; fi
	if [ "$MD5_System_Files_Hash" != "$Archive_MD5_System_Files_Hash" ]; then MD5_SystemFiles_Error=true; fi
	
	if [ $Install_User_Data == true ]; then
		MD5_User_Data_Hash=`md5sum "$Archive_User_Data" | awk '{print $1}'`
		if [ "$MD5_User_Data_Hash" != "$Archive_MD5_User_Data_Hash" ]; then MD5_UserFiles_Error=true; fi
	fi
	
	if [ $MD5_ProgramFiles_Error == true ] || [ $MD5_SystemFiles_Error == true ] || [ $MD5_UserFiles_Error == true ]; then MD5_Warning=true; fi
}

function _CHECK_MD5_PRINT() {
	_CLEAR_BACKGROUND
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5PRINT_Head${Font_Reset_Color}${Font_Reset}"
	
	if [ $MD5_Warning == true ]; then
		echo -e "\

  $Str_ATTENTION ${Font_Bold}${Font_DarkRed}$Str_CHECKMD5PRINT_Hash_Not_Match${Font_Reset_Color}
  ${Font_Red}$Str_CHECKMD5PRINT_Hash_Not_Match2${Font_Reset_Color}${Font_Reset}"
		if [ $MD5_ProgramFiles_Error == true ]; then
			echo -e "\

   ${Font_Bold}$Str_CHECKMD5PRINT_Expected_pHash${Font_Reset} \"$Archive_MD5_Program_Files_Hash\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_pHash${Font_Reset}     \"$MD5_Program_Files_Hash\""; fi
		if [ $MD5_SystemFiles_Error == true ]; then
			echo -e "\

   ${Font_Bold}$Str_CHECKMD5PRINT_Expected_sHash${Font_Reset} \"$Archive_MD5_System_Files_Hash\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_sHash${Font_Reset}     \"$MD5_System_Files_Hash\""; fi
		if [ $MD5_UserFiles_Error == true ]; then
			echo -e "\

   ${Font_Bold}$Str_CHECKMD5PRINT_Expected_uHash${Font_Reset} \"$Archive_MD5_User_Data_Hash\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_uHash${Font_Reset}     \"$MD5_User_Data_Hash\""; fi
		echo -e "\n  $Str_CHECKMD5PRINT_yes_To_Continue"
		read errors_confirm
    	if [ "$errors_confirm" == "y" ] || [ "$errors_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	else
		all_ok=true
		echo -e "
  ${Font_Green}The integrity of the installation archive has been successfully verified
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_pHash${Font_Reset}  \"$MD5_Program_Files_Hash\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_sHash${Font_Reset}   \"$MD5_System_Files_Hash\""
		if [ $Install_User_Data == true ]; then echo -e "\
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_uHash${Font_Reset}     \"$MD5_User_Data_Hash\""; fi
		echo -e "${Font_Reset_Color}
  ${Font_Bold}$Str_CHECKMD5PRINT_Enter_To_Continue${Font_Reset}"
		read pause
	fi
}

function _CHECK_MD5() {
if [ $MODE_SILENT == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5_Head${Font_Reset_Color}${Font_Reset}
  $Str_CHECKMD5_Sub_Head
   $Str_CHECKMD5_Sub_Head2"
		
		_CHECK_MD5_COMPARE
		_CHECK_MD5_PRINT
		
		all_ok=true
		
	if [ $MODE_DEBUG == true ]; then echo "_CHECK_MD5 - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _CHECK_MD5 ${Font_Reset_Color}${Font_Reset}"; fi
else
	_CHECK_MD5_COMPARE
	if [ $MD5_Warning == true ]; then _CHECK_MD5_PRINT; fi
fi
}

######### Check and compare MD5 of archive #########
######### -------------------------------- #########

######### --------------------------- #########
######### Print installation settings #########

function _PRINT_INSTALL_SETTINGS() {
if [ $MODE_SILENT == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_PRINTINSTALLSETTINGS_Head (${Font_Yellow}$Install_Mode${Font_Cyan}):${Font_Reset_Color}${Font_Reset}

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Temp_Dir${Font_Reset_Color}${Font_Reset} $Temp_Dir
 
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_App_Inst_Dir
   ${Font_Reset_Color}${Font_Reset}$Output_Install_Dir

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Menu_Dirs${Font_Reset_Color}${Font_Reset}
   $Output_Menu_Files
   $Output_Menu_DDir
   $Output_Menu_Apps

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Bin_Dir${Font_Reset_Color}${Font_Reset}
   $Output_Bin_Dir"
		
		if [ $Install_Helpers == true ]; then
			if [ $Current_DE == "XFCE" ]; then
				echo -e "
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Helpers_Dir${Font_Reset_Color}${Font_Reset}
   $Output_Helpers_Dir"; fi; fi

		if [ $Install_Desktop_Icons == true ]; then
			echo -e "
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Desktop_Dir${Font_Reset_Color}${Font_Reset}
   $Output_Desktop_Dir"; fi

		if [ $Install_User_Data == true ]; then
			echo -e "
 -$Str_ATTENTION! ${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Copy_uData_To${Font_Reset_Color}${Font_Reset}
   $Output_User_Data
    $Str_PRINTINSTALLSETTINGS_Copy_uData_To2
    $Str_PRINTINSTALLSETTINGS_Copy_uData_To3
    $Str_PRINTINSTALLSETTINGS_Copy_uData_To4"; fi
	
		if [ "$Install_Mode" == "System" ]; then
			echo -e "
 -$Str_ATTENTION! ${Font_Bold}${Font_Yellow}$Str_PRINTINSTALLSETTINGS_System_Mode
   $Str_PRINTINSTALLSETTINGS_System_Mode2${Font_Reset_Color}${Font_Reset}"; fi
		
		echo -e "
 $Str_PRINTINSTALLSETTINGS_Before_Install

 $Str_PRINTINSTALLSETTINGS_Confirm"
		read install_settings_confirm
	
		if [ "$install_settings_confirm" == "y" ] || [ "$install_settings_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	
		if [ $MODE_DEBUG == true ]; then echo "_PRINT_INSTALL_SETTINGS - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _PRINT_INSTALL_SETTINGS ${Font_Reset_Color}${Font_Reset}"; fi
fi
}

######### Print installation settings #########
######### --------------------------- #########

######### -------------------- #########
######### Check execute rights #########

_CECK_EXECUTE_RIGHTS() {
	if ! [[ -x "$Tool_SevenZip_bin" ]]; then
		if ! chmod +x "$Tool_SevenZip_bin"; then _ABORT "chmod Tool_SevenZip_bin error."; fi
	fi
	
	#if [ $Current_DE == "XFCE" ]; then
	#	if ! [[ -x "$Tool_Gio_Trust_Xfce" ]]; then
	#		if ! chmod +x "$Tool_Gio_Trust_Xfce"; then _ABORT "chmod Tool_Gio_Trust_Xfce error."; fi
	#	fi
	#fi
}

######### Check execute rights #########
######### -------------------- #########


######### ------------------- #########
######### Prepare Input Files #########

function _PREPARE_INPUT_FILES_GREP() {
	local prepare_text="/tmp/ish"; local prepare_path="/tmp/ish"; local prepare_error=false
	
	if [ ! -z "$1" ] && [ ! -z "$2" ]; then local prepare_text="$1"; local prepare_path="$2"
	else local prepare_error=true; _WARNING "PREPARE_INPUT_FILES_GREP" "not enough arguments for the function to work."; fi
	
	if [ $prepare_error == false ]; then 
		grep -rl "$prepare_text" "$Temp_Dir" | xargs sed -i "s~$prepare_text~$prepare_path~g" &> /dev/null
	fi
}

function _PREPARE_INPUT_FILES() {
	if [ $all_ok == true ]; then all_ok=false
		if ! "$Tool_SevenZip_bin" x "$Archive_System_Files" -o"$Temp_Dir/" &> /dev/null; then
			_ABORT "$Str_PREPAREINPUTFILES_Err_Unpack (_PREPARE_INPUT_FILES). $Str_PREPAREINPUTFILES_Err_Unpack2"
		fi
		
		for file in "$Temp_Dir"/*; do
			_PREPARE_INPUT_FILES_GREP "PATH_TO_FOLDER" "$Output_Install_Dir"
			_PREPARE_INPUT_FILES_GREP "UNIQUE_APP_FOLDER_NAME" "$Unique_App_Folder_Name"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_NAME_IN_MENU" "$Program_Name_In_Menu"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_EXECUTABLE_FILE" "$Program_Executable_File"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_EXE_RUN_IN_TERMINAL" "$Program_Exe_Run_In_Terminal"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_ICON_IN_MENU" "$Program_Icon_In_Menu"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_INSTALL_MODE" "$Program_Install_Mode"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_FILE" "$Program_Uninstaller_File"
			_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_ICON" "$Program_Uninstaller_Icon"
			_PREPARE_INPUT_FILES_GREP "ADDITIONAL_CATEGORIES" "$Additional_Categories"
			_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_NAME" "$Menu_Directory_Name"
			_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_ICON" "$Menu_Directory_Icon"
		done
	
		local All_Renamed=false
		while [ $All_Renamed == false ]; do
			if find "$Temp_Dir/" -name "UNIQUE_APP_FOLDER_NAME*" | sed -e "p;s~UNIQUE_APP_FOLDER_NAME~$Unique_App_Folder_Name~" | xargs -n2 mv &> /dev/null; then
				local All_Renamed=true
			fi
		done
		
		local Files_Bin_Dir=( $(ls "$Input_Bin_Dir") )
		local Files_Menu=( $(ls "$Input_Menu_Files_Dir") )
		local Files_Menu_Dir=( $(ls "$Input_Menu_Desktop_Dir") )
		local Files_Menu_Apps=( $(ls "$Input_Menu_Apps_Dir") )
		
		local arr_0=(); local arr_1=(); local arr_2=(); local arr_3=(); local arr_4=(); local arr_5=()
		
		for file in "${!Files_Bin_Dir[@]}"; do local arr_0[$file]="$Output_Bin_Dir/${Files_Bin_Dir[$file]}"; done
		
		if [ $Install_Helpers == true ]; then 
			if [ $Current_DE == "XFCE" ]; then
				local Files_Helpers_Dir=( $(ls "$Input_Helpers_Dir") )
				for file in "${!Files_Helpers_Dir[@]}"; do local arr_1[$file]="$Output_Helpers_Dir/${Files_Helpers_Dir[$file]}"; done
			fi
		fi
		
		if [ $Install_Desktop_Icons == true ]; then 
			local Files_Desktop_Dir=( $(ls "$Input_Desktop_Dir") )
			for file in "${!Files_Desktop_Dir[@]}"; do local arr_2[$file]="$Output_Desktop_Dir/${Files_Desktop_Dir[$file]}"; done
		fi
		
		for file in "${!Files_Menu[@]}"; do local arr_3[$file]="$Output_Menu_Files/${Files_Menu[$file]}"; done
		for file in "${!Files_Menu_Dir[@]}"; do local arr_4[$file]="$Output_Menu_DDir/${Files_Menu_Dir[$file]}"; done
		for file in "${!Files_Menu_Apps[@]}"; do local arr_5[$file]="$Output_Menu_Apps/${Files_Menu_Apps[$file]}"; done
		
		Output_Files_All=("$Output_Install_Dir" "${arr_0[@]}" "${arr_1[@]}" "${arr_2[@]}" "${arr_3[@]}" "${arr_4[@]}" "${arr_5[@]}")
		all_ok=true
		
		if [ $MODE_DEBUG == true ]; then echo "_PREPARE_INPUT_FILES - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _PREPARE_INPUT_FILES ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Prepare Input Files #########
######### ------------------- #########

######### ------------- #########
######### Check outputs #########

function _CHECK_OUTPUTS() {
	if [ $all_ok == true ]; then all_ok=false
		local check_outputs_error=false
		local arr_files_sorted=()
		
		for file in "${!Output_Files_All[@]}"; do
			if [ -e "${Output_Files_All[$file]}" ]; then arr_files_sorted[$file]="${Output_Files_All[$file]}"; local check_outputs_error=true; fi
		done
		
		if [ $check_outputs_error == true ]; then
			clear
			echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKOUTPUTS_Head${Font_Reset_Color}${Font_Reset}"
			echo -e "
  $Str_ATTENTION! $Str_CHECKOUTPUTS_Already_Present
$(for file in "${!arr_files_sorted[@]}"; do echo "   ${arr_files_sorted[$file]}"; done)"
			echo -e "
   $Str_CHECKOUTPUTS_Attention
   ${Font_Yellow}$Str_CHECKOUTPUTS_Attention2${Font_Reset_Color}

 $Str_CHECKOUTPUTS_Confirm"
			read install_confirm
			if [ "$install_confirm" == "y" ] || [ "$install_confirm" == "yes" ]; then all_ok=true
			else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
		else
			all_ok=true
		fi
		
		if [ $MODE_DEBUG == true ]; then echo "_CHECK_OUTPUTS - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _CHECK_OUTPUTS ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Check outputs #########
######### ------------- #########

######### ----------------- #########
######### Install USER DATA #########

function _INSTALL_USER_DATA() {
	# Copy user data
	if [ $Install_User_Data == true ]; then
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALLAPP_Copy_uFiles"; fi
		
		if [ ! -e "$Output_User_Data" ]; then mkdir -p "$Output_User_Data"; fi
		
		if ! "$Tool_SevenZip_bin" x -aoa "$Archive_User_Data" -o"$Output_User_Data/" &> /dev/null; then
			_ERROR "_INSTALL_USER_DATA" "$Str_INSTALLAPP_Copy_uFiles_Err"; fi
	fi
	if [ $MODE_DEBUG == true ]; then echo "_INSTALL_APP - all_ok = $all_ok"; read pause; fi
}

######### Install USER DATA #########
######### ----------------- #########

######### --------------- #########
######### Install Helpers #########

### -------------- ###
### Helpers (XFCE) ###
# Default paths:
#  /usr/share/xfce4/helpers/
#  ~/.local/share/xfce4/helpers/

function _INSTALL_HELPERS_XFCE_SYSTEM() {
	if [ ! -e "$Output_Helpers_Dir" ]; then sudo mkdir -p "$Output_Helpers_Dir"; fi
	sudo cp -rf "$Input_Helpers_Dir/." "$Output_Helpers_Dir"
}

function _INSTALL_HELPERS_XFCE_USER() {
	if [ ! -e "$Output_Helpers_Dir" ]; then mkdir -p "$Output_Helpers_Dir"; fi
	cp -rf "$Input_Helpers_Dir/." "$Output_Helpers_Dir"
}

### Helpers (XFCE) ###
### -------------- ###

function _INSTALL_HELPERS() {
	if [ -e "$Input_Helpers_Dir" ]; then
		if [ $Current_DE == "XFCE" ]; then
			if [ "$Install_Mode" == "System" ]; then _INSTALL_HELPERS_XFCE_SYSTEM; else _INSTALL_HELPERS_XFCE_USER; fi; fi
	else _ERROR "_INSTALL_HELPERS" "Input_Helpers_Dir not found."; fi
}

######### Install Helpers #########
######### --------------- #########

######### --------------------- #########
######### Install Desktop Icons #########

function _INSTALL_DESKTOP_ICONS_TRUST_XFCE() {
	for file in "${!Files_Desktop_Dir[@]}"; do
		"$Tool_Gio_Trust_Xfce" -trust --silent "$Output_Desktop_Dir/${Files_Desktop_Dir[$file]}"
	done
}

function _INSTALL_DESKTOP_ICONS() {
	# Check input folder
	if [ -e "$Input_Desktop_Dir" ]; then
		# Copy Desktop files
		cp -rf "$Input_Desktop_Dir/." "$Output_Desktop_Dir"
		
		# Trust Desktop files
		#if [ "$Current_DE" == "XFCE" ]; then
		#	_INSTALL_DESKTOP_ICONS_TRUST_XFCE; fi
		
	else _ERROR "_INSTALL_DESKTOP_ICONS" "Input_Desktop_Dir not found."; fi
}

######### Install Desktop Icons #########
######### --------------------- #########

######### ------------------------------- #########
######### Install application (USER MODE) #########

function _INSTALL_APP_USER() {
	if [ $all_ok == true ]; then all_ok=false
		if [ $MODE_SILENT == false ]; then
			_CLEAR_BACKGROUND
			echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_INSTALL_APP_Head${Font_Reset_Color}${Font_Reset}"; fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALL_APP_Create_Out"; fi
		
		# Check Output Folder
		if [ ! -e "$Output_Install_Dir" ]; then if ! mkdir -p "$Output_Install_Dir"; then _ABORT "$Str_INSTALL_APP_No_Rights"; fi
		else if ! touch "$Output_Install_Dir"; then _ABORT "$Str_INSTALL_APP_No_Rights"; fi; fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALLAPP_Unpack_App"; fi
		
		if ! "$Tool_SevenZip_bin" x -snld -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
			echo -e "\n $Str_ATTENTION $Str_INSTALLAPP_Unpack_Err"
			echo " $Str_INSTALLAPP_Unpack_Err2"
			echo -e "\n $Str_INSTALLAPP_Unpack_Err_Continue"
			read confirm_unpack
			if [ "$confirm_unpack" == "y" ] || [ "$confirm_unpack" == "yes" ]; then echo "  $Str_INSTALLAPP_Unpack_Continue"
			else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_INSTALLAPP_Unpack_Err_Abort${Font_Reset_Color}${Font_Reset}"; fi
		fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALLAPP_Install_Bin_Menu"; fi
		
		# Check Bin folder
		if [ ! -e "$Output_Bin_Dir" ]; then mkdir "$Output_Bin_Dir"; fi
		
		# Copy Bin files
		cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
		
		# Сopy Menu files
		cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
		cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
		cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
		
		# Install Helpers
		if [ $Install_Helpers == true ]; then
			_INSTALL_HELPERS; fi
		
		# Install Desktop files
		if [ $Install_Desktop_Icons == true ]; then
			_INSTALL_DESKTOP_ICONS; fi
		
		# Copy user data
		if [ $Install_User_Data == true ]; then
			_INSTALL_USER_DATA; fi
		
		all_ok=true
		
		if [ $MODE_DEBUG == true ]; then echo "_INSTALL_APP - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _INSTALL_APP ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Install application (USER MODE) #########
######### ------------------------------- #########

######### --------------------------------- #########
######### Install application (SYSTEM MODE) #########

function _INSTALL_APP_SYSTEM() {
	if [ $all_ok == true ]; then all_ok=false
		if [ $MODE_SILENT == false ]; then
			_CLEAR_BACKGROUND
			echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_INSTALL_APP_Head${Font_Reset_Color}${Font_Reset}"; fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALL_APP_Create_Out"; fi
		
		# Check Output Folder
		if [ ! -e "$Output_Install_Dir" ]; then if ! sudo mkdir -p "$Output_Install_Dir"; then _ABORT "$Str_INSTALL_APP_No_Rights"; fi
		else if ! sudo touch "$Output_Install_Dir"; then _ABORT "$Str_INSTALL_APP_No_Rights"; fi; fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALLAPP_Unpack_App"; fi
		
		if ! sudo "$Tool_SevenZip_bin" x -snld -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
			echo -e "\n $Str_ATTENTION $Str_INSTALLAPP_Unpack_Err"
			echo " $Str_INSTALLAPP_Unpack_Err2"
			echo -e "\n $Str_INSTALLAPP_Unpack_Err_Continue"
			read confirm_error_unpacking
			if [ "$confirm_error_unpacking" == "y" ] || [ "$confirm_error_unpacking" == "yes" ]; then echo "  $Str_INSTALLAPP_Unpack_Continue"
			else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_INSTALLAPP_Unpack_Err_Abort${Font_Reset_Color}${Font_Reset}"; fi
		fi
		
		if [ $MODE_SILENT == false ]; then echo " $Str_INSTALLAPP_Install_Bin_Menu"; fi
		
		echo " $Str_INSTALLAPP_Set_Rights"
		sudo chmod -R $Out_App_Folder_Permissions "$Output_Install_Dir"
		sudo chown -R $Out_App_Folder_Owner "$Output_Install_Dir"
		
		# Copy Bin files
		sudo cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
		
		# Сopy Menu files
		sudo cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
		sudo cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
		sudo cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
		
		# Install Helpers
		_INSTALL_HELPERS
		
		# Install Desktop files
		if [ $Install_Desktop_Icons == true ]; then
			_INSTALL_DESKTOP_ICONS; fi
		
		# Copy user data
		if [ $Install_User_Data == true ]; then
			_WARNING "Install_User_Data" "In \"System\" mode this does not work!"
			#_INSTALL_USER_DATA
		fi
		
		all_ok=true
		
		if [ $MODE_DEBUG == true ]; then echo "_INSTALL_APP - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _INSTALL_APP ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Install application (SYSTEM MODE) #########
######### --------------------------------- #########

function _INSTALL_APPLICATION() {
	if [ "$Install_Mode" == "System" ]; then _INSTALL_APP_SYSTEM; else _INSTALL_APP_USER; fi
}


######### ------------------------ #########
######### Prepare uninstaller file #########

function _PREPARE_UNINSTALLER_SYSTEM() {
	if [ -e "$Output_Uninstaller" ]; then
		sudo chmod 755 "$Output_Uninstaller"
		sudo chown $Out_App_Folder_Owner "$Output_Uninstaller"
	
		for filename in "${!Output_Files_All[@]}"; do
			local CurrentFile="${Output_Files_All[$filename]}"
			sudo sed -i "s~FilesToDelete=(~&\n$CurrentFile~" "$Output_Uninstaller"
		done
	else _ERROR "_PREPARE_UNINSTALLER_SYSTEM" "Output_Uninstaller not found."; fi
}

function _PREPARE_UNINSTALLER_USER() {
	if [ -e "$Output_Uninstaller" ]; then
		chmod 744 "$Output_Uninstaller"
	
		for filename in "${!Output_Files_All[@]}"; do
			local CurrentFile="${Output_Files_All[$filename]}"
			sed -i "s~FilesToDelete=(~&\n$CurrentFile~" "$Output_Uninstaller"
		done
	else _ERROR "_PREPARE_UNINSTALLER_USER" "Output_Uninstaller not found."; fi
}

function _PREPARE_UNINSTALLER() {
	if [ $all_ok == true ]; then
		if [ "$Install_Mode" == "System" ]; then _PREPARE_UNINSTALLER_SYSTEM; fi
		if [ "$Install_Mode" == "User" ]; then _PREPARE_UNINSTALLER_USER; fi
		
		if [ $MODE_DEBUG == true ]; then echo "_PREPARE_UNINSTALLER - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _PREPARE_UNINSTALLER ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Prepare uninstaller file #########
######### ------------------------ #########

######### ------------ #########
######### Post Install #########

function _POST_INSTALL_UPDATE_MENU_LXQT() { ### WARNING! This function has been abandoned! ###
	local panel_restarted=false
	
	while [ $panel_restarted == false ]; do
		if killall lxqt-panel &> /dev/null; then
			for ((post_install_update_menu_lxqt=0; post_install_update_menu_lxqt<10; post_install_update_menu_lxqt++)); do
				if [ $MODE_SILENT == false ]; then
					echo " Restarting LXQt Panel..."; fi
				
				sleep 1s
				
				if ! pidof lxqt-panel; then
					if setsid lxqt-panel & disown &> /dev/null; then
						local panel_restarted=true
						post_install_update_menu_lxqt=10
					fi
				fi
			done
		else
			if ! pidof lxqt-panel; then
				setsid lxqt-panel & disown &> /dev/null
			fi
		fi
	done
}

function _POST_INSTALL_UPDATE_MENU_LXDE() {
	lxpanelctl restart &> /dev/null
}

function _POST_INSTALL_UPDATE_MENU_XFCE() {
	xfce4-panel -r &> /dev/null
}

function _POST_INSTALL_UPDATE_MENU_KDE() {
	if type "kbuildsycoca7" &> /dev/null; then kbuildsycoca7 &> /dev/null
	elif type "kbuildsycoca6" &> /dev/null; then kbuildsycoca6 &> /dev/null
	elif type "kbuildsycoca5" &> /dev/null; then kbuildsycoca5 &> /dev/null
	elif type "kbuildsycoca4" &> /dev/null; then kbuildsycoca4 &> /dev/null
	fi
}

function _POST_INSTALL_UPDATE_MENU_OPENBOX() {
	openbox --restart &> /dev/null
}

function _POST_INSTALL() {
	if [ $all_ok == true ]; then
		# Restart taskbar

		### WARNING! This can lead to a desktop crash, because the LXQt developers did not provide the ability to restart their panel normally...
		#if [ "$Current_DE" == "LXQT" ]; then _POST_INSTALL_UPDATE_MENU_LXQT; fi
		
		# The installer is not designed to work with the specific structure of the OpenBox menu.
		#if [ "$Current_DE" == "OPENBOX" ]; then _POST_INSTALL_UPDATE_MENU_OPENBOX; fi
		
		if [ "$Current_DE" == "LXDE" ];    then _POST_INSTALL_UPDATE_MENU_LXDE; fi
		if [ "$Current_DE" == "XFCE" ];    then _POST_INSTALL_UPDATE_MENU_XFCE; fi
		if [ "$Current_DE" == "KDE" ];     then _POST_INSTALL_UPDATE_MENU_KDE; fi
		
		# Exit
		if [ $MODE_SILENT == false ]; then _ABORT "${Font_Bold}${Font_Green}$Str_Complete_Install${Font_Reset_Color}${Font_Reset}"; fi
		
		if [ $MODE_DEBUG == true ]; then echo "_POST_INSTALL - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _POST_INSTALL ${Font_Reset_Color}${Font_Reset}"; fi
}

######### Post Install #########
######### ------------ #########

######### ---- #########
####### Strings! #######
###### Set Locale ######

function _SET_LOCALE_DEFAULT() {
	Info_Description="  Not used in this place... The translation is located in the \"locales/\" directory."
	
	Str_ERROR="${Font_Bold}${Font_Red}ERROR${Font_Reset_Color}${Font_Reset}"
	Str_ATTENTION="${Font_Bold}${Font_Yellow}ATTENTION${Font_Reset_Color}${Font_Reset}"
	Str_WARNING="${Font_Bold}${Font_Yellow}WARNING${Font_Reset_Color}${Font_Reset}"
	
	Str_Interrupted_By_User="Interrupted by user"
	Str_Complete_Install="The installation process has been completed successfully."
	
	Str_Error_All_Ok="The \"all_ok\" condition was not passed in the function:"
	
	Str_ABORT_Msg="Exit code -"
	Str_ABORT_Exit="Press Enter or close the window to exit."
	Str_ABORT_Errors="Errors:"
	Str_ABORT_Warnings="Warnings:"
	
	Str_BASEINFO_Head="Installing basic components:"
	Str_BASEINFO_Warning="Warning! If you are here - you are not using Chimbalix,\n  other Linux distributions require some preparation, the following components must be installed:"
	Str_BASEINFO_PortSoft="PortSoft directory:"
	Str_BASEINFO_PortSoft_Full="Base directory for placing program files, the main application directory in the Chimbalix distribution."
	Str_BASEINFO_MenuApps="Stable \"Applications\" menu category:"
	Str_BASEINFO_MenuApps_Full="Stable \"Applications\" category in the menu for placing shortcuts to installed programs."
	Str_BASEINFO_Attention="Attention! The above components will be installed according to the current installation mode.\n  AFTER CONFIRMATION, THIS ACTION CANNOT BE CANCELLED!\n  For proper operation, your distribution must support the XDG standard!\n  The menu must also support subcategories!\n  You may also need to Log Out to refresh the menu after installation."
	Str_BASEINFO_Confirm="Start the installation process? Enter \"y\" or \"yes\" to confirm."
	Str_BASE_COMPLETE="Done, depending on the distribution the menu may not appear until you log in again.\n Press \"Enter\" to continue."
	
	Str_BASECHECKMD5PRINT_Hash_Not_Match="The Base Data archive hash sum does not match the value specified in the settings!"
	Str_BASECHECKMD5PRINT_Hash_Not_Match2="The files may have been copied with errors or modified! Be careful!"
	Str_BASECHECKMD5PRINT_Expected_bHash="Expected MD5 hash of \"Base Data\":"
	Str_BASECHECKMD5PRINT_Real_bHash="Real MD5 hash of \"Base Data\":"
	
	Str_PACKAGEINFO_Head="Software Info:"
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
	Str_PACKAGEINFO_Confirm="Start the application installation process? Enter \"y\" or \"yes\" to confirm."
	
	Str_CHECKMD5PRINT_Head="Integrity check:"
	Str_CHECKMD5PRINT_Hash_Not_Match="The archives hash sum does not match the value specified in the settings!"
	Str_CHECKMD5PRINT_Hash_Not_Match2="The files may have been copied with errors or modified! Be careful!"
	Str_CHECKMD5PRINT_Expected_pHash="Expected MD5 hash of \"Program Files\":"
	Str_CHECKMD5PRINT_Expected_sHash="Expected MD5 hash of \"System Files\":"
	Str_CHECKMD5PRINT_Expected_uHash="Expected MD5 hash of \"User Files\":"
	Str_CHECKMD5PRINT_Real_pHash="Real MD5 hash of \"Program Files\":"
	Str_CHECKMD5PRINT_Real_sHash="Real MD5 hash of \"System Files\":"
	Str_CHECKMD5PRINT_Real_uHash="Real MD5 hash of \"User Files\":"
	Str_CHECKMD5PRINT_yes_To_Continue="Enter \"y\" or \"yes\" to continue installation (not recommended):"
	Str_CHECKMD5PRINT_Enter_To_Continue="Press Enter to continue."
	
	Str_CHECKMD5_Head="Checking archives integrity:"
	Str_CHECKMD5_Sub_Head="Checking the integrity of the installation archives, please wait..."
	Str_CHECKMD5_Sub_Head2="(this may take some time if the application is large)"
	Str_CHECKMD5_y_To_Check="Enter \"y\" or \"yes\" to check the integrity of the archives (recommended)."
	
	Str_PRINTINSTALLSETTINGS_Head="Installation settings"
	Str_PRINTINSTALLSETTINGS_Temp_Dir="Temporary Directory:"
	Str_PRINTINSTALLSETTINGS_App_Inst_Dir="Application install Directory:"
	Str_PRINTINSTALLSETTINGS_Menu_Dirs="Menu files will be installed to:"
	Str_PRINTINSTALLSETTINGS_Bin_Dir="Bin files will be installed to:"
	Str_PRINTINSTALLSETTINGS_Copy_uData_To="User data will be installed in:"
	Str_PRINTINSTALLSETTINGS_Copy_uData_To2="This is an experimental feature."
	Str_PRINTINSTALLSETTINGS_Copy_uData_To3="This avoids conflicts between different versions of the application."
	Str_PRINTINSTALLSETTINGS_Copy_uData_To4="This is not intended for applications that are installed in system mode."
	Str_PRINTINSTALLSETTINGS_System_Mode="Use \"System\" mode only when installing software for all users!"
	Str_PRINTINSTALLSETTINGS_System_Mode2="Root rights are required to perform the installation!"
	Str_PRINTINSTALLSETTINGS_Before_Install="Please close all important applications before installation."
	Str_PRINTINSTALLSETTINGS_Confirm="Enter \"y\" or \"yes\" to begin the installation."
	Str_PRINTINSTALLSETTINGS_Helpers_Dir="Helper files will be installed to:"
	Str_PRINTINSTALLSETTINGS_Desktop_Dir="Desktop shortcuts will be installed to:"
	
	Str_PREPAREINPUTFILES_Err_Unpack="Error unpacking temp files:"
	Str_PREPAREINPUTFILES_Err_Unpack2="Try copying the installation files to another disk before running."
	
	Str_CHECKOUTPUTS_Head="Checking output directories:"
	Str_CHECKOUTPUTS_Already_Present="Folders|Files already present"
	Str_CHECKOUTPUTS_Attention="Continue installation and overwrite directories/files?"
	Str_CHECKOUTPUTS_Attention2="Please make a backup copy of your data, if any, in the above directories."
	Str_CHECKOUTPUTS_Confirm="Enter \"y\" or \"yes\" to continue."
	
	Str_INSTALLAPP_Head="Installing..."
	Str_INSTALLAPP_No_Rights="No rights to the application installation directory?"
	Str_INSTALLAPP_Create_Out="Creating output folder if it does not exist..."
	Str_INSTALLAPP_Unpack_App="Unpacking application files..."
	Str_INSTALLAPP_Unpack_Err="Error unpacking program files..."
	Str_INSTALLAPP_Unpack_Err2="Broken archive? Or symbolic links with absolute paths as part of an application?"
	Str_INSTALLAPP_Unpack_Err_Continue="Enter \"y\" or \"yes\" to continue the installation process..."
	Str_INSTALLAPP_Unpack_Err_Abort="At the stage of unpacking program files."
	Str_INSTALLAPP_Unpack_Continue="The installation continues..."
	Str_INSTALLAPP_Set_Rights="Setting rights and owner..."
	Str_INSTALLAPP_Install_Bin_Menu="Installing Bin files and copy menu files..."
	Str_INSTALLAPP_Copy_uFiles="Copying user files...."
	Str_INSTALLAPP_Copy_uFiles_Err="Error unpacking user files..."
	
	Str_CHECKSYSDE_NotFound="Not found..."
	Str_CHECKSYSDE_XDG_INFO_INCORRECT="The distribution did not provide correct information via the \"XDG\" variables..."
	Str_CHECKSYSDE_DE_CHECK="DE Check"
	Str_CHECKSYSDE_DE_WEIRD="Weird DE"
	Str_CHECKSYSDE_DE_WEIRD_OPENBOX="This DE may not follow XDG specifications!\n    The installer is not designed to work with the specific structure of the OpenBox menu."
	Str_CHECKSYSDE_DE_WEIRD_SWAY="What the hell..."
	Str_CHECKSYSDE_DE_WEIRD_LXQT="Re-login to the system if new shortcuts do not appear in the menu!"
	Str_CHECKSYSDE_DE_WEIRD_BUDGIE="New shortcuts may not appear in the menu..."
	Str_CHECKSYSDE_DE_WEIRD_GNOME="The menu doesn't match XDG specifications very well...\n    Re-login to the system if new shortcuts do not appear in the menu!"
	
	Str_CHECK_ERRORS_ARCH="Attention!"
	Str_CHECK_ERRORS_ARCH_WARN="The system architecture ($Current_Architecture) does not match the selected tools architecture ($Tools_Architecture)!"
}

function _SET_LOCALE() {
	local Language="${LANG%%.*}"
	local Locale_File="$Path_To_Script/locales/$Language"
	
	_SET_LOCALE_DEFAULT
	
	if [ $MODE_SILENT == true ]; then Locale_Display="-silent"
	else
		if [ -e "$Locale_File" ]; then
			if [ $(grep Locale_Version "$Locale_File") == 'Locale_Version="2.0"' ]; then
				Locale_Use_Default=false
				Locale_Display="$Language"
				source "$Locale_File"
			fi
		fi
	fi
}

###### Set Locale ######
####### Strings! #######
######### ---- #########

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
