#!/usr/bin/env bash
# This Script part of "Installer-SH"
######### --------- #########
all_ok=true
Base_Header="${BG_Black}${F_Red}${Bold} -=: Prepare PortSoft-Menu for Chimbalix Installer Script (Installer-SH v1.8) :=-${rBD}${F}\n"

######### - Archive path - #########
Archive_Base_Data="$Installer_Data_Path/base_data.7z"
Archive_Base_Data_MD5="681403d911cda4449e116fdf1a7c0517"

function _BASE_MAIN() {
	_BASE_PRINT_INFO
	_BASE_CHECK_MD5
	_BASE_PRINT_CONFIRM
	_BASE_CREATE_TEMP
	_BASE_PREPARE_FILES
	_BASE_CHECK_OUTPUTS
	if [ "$Install_Mode" == "System" ]; then _BASE_INSTALL_SYSTEM; else _BASE_INSTALL_USER; fi;
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
  
 -${Bold}${F_DarkYellow}$Str_BASEINFO_MenuApps${F}${rBD}
   $Str_BASEINFO_MenuApps_Full
  
  $Str_BASEINFO_Attention

 -${Bold}${F_DarkGreen}$Str_PACKAGEINFO_CurrentOS${F} $Distro_Full_Name${rBD}
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

function _BASE_PRINT_CONFIRM() {
	echo ""
}

function _BASE_PREPARE_FILES() {
	echo ""
}

function _BASE_CHECK_OUTPUTS() {
	echo ""
}

function _BASE_INSTALL_SYSTEM() {
	echo ""
}

function _BASE_INSTALL_USER() {
	echo ""
}


_BASE_MAIN
