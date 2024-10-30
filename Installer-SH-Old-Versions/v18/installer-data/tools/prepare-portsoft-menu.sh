#!/usr/bin/env bash
# This Script part of "Installer-SH"
######### --------- #########
all_ok=true
Base_Header="${BG_Black}${F_Red}${Bold} -=: Prepare PortSoft and Menu (Installer-SH v1.8) :=-${rBD}${F}\n"
Base_Temp_Dir="/tmp/chimbalix-portsoft-menu-prepare""_$RANDOM""_$RANDOM" # TEMP Directory

######### - Archive path - #########
Archive_Base_Data="$Installer_Data_Path/tools/base_data.7z"
Archive_Base_Data_MD5="ce6a991ac1fcc596308e943c58369c11"

function _BASE_MAIN() {
	_BASE_PRINT_INFO
	_BASE_CHECK_MD5
	_BASE_CREATE_TEMP
	_BASE_PREPARE_FILES
	if [ "$Install_Mode" == "System" ]; then _BASE_INSTALL_SYSTEM; else _BASE_INSTALL_USER; fi;
	_BASE_DELETE_TEMP
	_BASE_INSTALL_COMPLETE
}

function _BASE_PRINT_INFO() {
if [ $Silent_Mode == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		echo -e "${BG_Black}"; clear;
		echo -e "\
$Base_Header
 ${Bold}${F_Cyan}$Str_BASEINFO_Head${F}${rBD}

  $Str_BASEINFO_Warning

 -${Bold}${F_DarkYellow}$Str_BASEINFO_PortSoft${F}${rBD}
   $Str_BASEINFO_PortSoft_Full
     $Output_PortSoft
  
 -${Bold}${F_DarkYellow}$Str_BASEINFO_MenuApps${F}${rBD}
   $Str_BASEINFO_MenuApps_Full
     $Output_Menu_Files/apps.menu
     $Output_Menu_DDir/apps.directory
     $Output_Menu_DDir/apps.png
  
  $Str_BASEINFO_Attention

 -${Bold}${F_DarkGreen}$Str_PACKAGEINFO_CurrentOS${F} $Distro_Full_Name ($Current_DE)${rBD}
 -${Bold}${F_DarkGreen}$Str_PACKAGEINFO_InstallMode${F} $Install_Mode${rBD}"
		echo -e "\n $Str_BASEINFO_Confirm"
		read base_info_confirm
		if [ "$base_info_confirm" == "y" ] || [ "$base_info_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Bold}${F_Green}$Str_Interrupted_By_User${F}${rBD}"; fi
		
		if [ $DEBUG_MODE == true ]; then echo "_PRINT_PACKAGE_INFO - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Bold}${F_Yellow}$Str_Error_All_Ok _PRINT_PACKAGE_INFO ${F}${rBD}"; fi
fi
}

######### --------------------------------
######### Check and compare MD5 of archive

function _BASE_CHECK_MD5() {
if [ $all_ok == true ]; then all_ok=false
	Base_Data_MD5=`md5sum "$Archive_Base_Data" | awk '{print $1}'`
	if [ "$Base_Data_MD5" != "$Archive_Base_Data_MD5" ]; then
		clear
		echo -e "\
$Base_Header
 ${Bold}${F_Cyan}$Str_CHECKMD5PRINT_Head${F}${rBD}

  $Str_ATTENTION ${Bold}${F_DarkRed}$Str_BASECHECKMD5PRINT_Hash_Not_Match${F}
  ${F_Red}$Str_BASECHECKMD5PRINT_Hash_Not_Match2${F}${rBD}
  
   ${Bold}$Str_BASECHECKMD5PRINT_Expected_bHash${rBD} \"$Archive_Base_Data_MD5\"
   ${Bold}$Str_BASECHECKMD5PRINT_Real_bHash${rBD}     \"$Base_Data_MD5\""

		echo -e "\n  $Str_CHECKMD5PRINT_yes_To_Continue"
		read base_errors_confirm
		if [ "$base_errors_confirm" == "y" ] || [ "$base_errors_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Bold}${F_Green}$Str_Interrupted_By_User${F}${rBD}"; fi
	else all_ok=true; fi
	if [ $DEBUG_MODE == true ]; then echo "_BASE_CHECK_MD5 - all_ok = $all_ok"; read pause; fi
else _ABORT "$Str_ERROR! ${Bold}${F_Yellow}$Str_Error_All_Ok _BASE_CHECK_MD5 ${F}${rBD}"; fi
}


function _BASE_CREATE_TEMP() {
if [ $all_ok == true ]; then all_ok=false
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
	mkdir "$Base_Temp_Dir"
	all_ok=true
	if [ $DEBUG_MODE == true ]; then echo "_BASE_CREATE_TEMP - all_ok = $all_ok"; read pause; fi
else _ABORT "$Str_ERROR! ${Bold}${F_Yellow}$Str_Error_All_Ok _BASE_CREATE_TEMP ${F}${rBD}"; fi
}
function _BASE_DELETE_TEMP() {
if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
}


function _BASE_PREPARE_INPUT_FILES_GREP() {
	local p_text="$1"; local p_path="$2"
	grep -rl "$p_text" "$Base_Temp_Dir" | xargs sed -i "s~$p_text~$p_path~g" &> /dev/null
}

function _BASE_PREPARE_FILES() {
	if ! [[ -x "$Szip_bin" ]]; then chmod +x "$Szip_bin"; fi
	
	if ! "$Szip_bin" x "$Archive_Base_Data" -o"$Base_Temp_Dir/" &> /dev/null; then
		_ABORT "$Str_PREPAREINPUTFILES_Err_Unpack (_PREPARE_INPUT_FILES). $Str_PREPAREINPUTFILES_Err_Unpack2"
	fi
	
	_BASE_PREPARE_INPUT_FILES_GREP "BASE_PATH_TO_SHARE_DDIR" "$Output_Menu_DDir"
}

function _BASE_INSTALL_SYSTEM() {
	if [ ! -e "$Output_Menu_Apps" ]; then sudo mkdir -p "$Output_Menu_Apps"; fi
	if [ ! -e "$Output_Menu_DDir" ]; then sudo mkdir -p "$Output_Menu_DDir"; fi
	if [ ! -e "$Output_Menu_Files" ]; then sudo mkdir -p "$Output_Menu_Files"; fi
	
	sudo cp -rf "$Base_Temp_Dir/desktop-directories/apps/". "$Output_Menu_DDir"
	sudo cp -rf "$Base_Temp_Dir/menus/applications-merged/". "$Output_Menu_Files"
	
	if [ ! -e "$Out_PortSoft_System" ]; then sudo mkdir -p "$Out_PortSoft_System"; fi
	sudo cp -rf "$Base_Temp_Dir/portsoft/". "$Out_PortSoft_System"
}

function _BASE_INSTALL_USER() {
	if [ ! -e "$Output_Menu_Apps" ]; then mkdir -p "$Output_Menu_Apps"; fi
	if [ ! -e "$Output_Menu_DDir" ]; then mkdir -p "$Output_Menu_DDir"; fi
	if [ ! -e "$Output_Menu_Files" ]; then mkdir -p "$Output_Menu_Files"; fi
	
	cp -rf "$Base_Temp_Dir/desktop-directories/apps/". "$Output_Menu_DDir"
	cp -rf "$Base_Temp_Dir/menus/applications-merged/". "$Output_Menu_Files"
	
	if [ ! -e "$Out_PortSoft_User" ]; then mkdir -p "$Out_PortSoft_User"; fi
	cp -rf "$Base_Temp_Dir/portsoft/". "$Out_PortSoft_User"
}

function _BASE_INSTALL_COMPLETE() {
	if [ "$Current_DE" == "xfce" ]; then xfce4-panel -r &> /dev/null; fi
	echo -e " $Str_BASE_COMPLETE"
	read pause
}

_BASE_MAIN
