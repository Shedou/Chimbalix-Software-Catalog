#!/usr/bin/env bash
# This Script part of "Installer-SH"
# LICENSE for this script is at the end of this file

######### --------- #########
all_ok=true
Base_Header="${Font_Red}${Font_Bold} -=: Preparing PortSoft and Menu (Installer-SH part) :=-${Font_Reset}${Font_Color_Reset}\n"
Base_Temp_Dir="/tmp/chimbalix-portsoft-menu-prepare""_$RANDOM""_$RANDOM" # TEMP Directory

######### - Archive path - #########
Archive_Base_Data="$Path_Installer_Data/tools/base_data.7z"
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
if [ $MODE_SILENT == false ]; then
	if [ $all_ok == true ]; then all_ok=false
		clear
		echo -e "\
$Base_Header
 ${Font_Bold}${Font_Cyan}$Str_BASEINFO_Head${Font_Color_Reset}${Font_Reset}

  $Str_BASEINFO_Warning

 -${Font_Bold}${Font_DarkYellow}$Str_BASEINFO_PortSoft${Font_Color_Reset}${Font_Reset}
   $Str_BASEINFO_PortSoft_Full
     $Output_PortSoft
  
 -${Font_Bold}${Font_DarkYellow}$Str_BASEINFO_MenuApps${Font_Color_Reset}${Font_Reset}
   $Str_BASEINFO_MenuApps_Full
     $Output_Menu_Files/apps.menu
     $Output_Menu_DDir/apps.directory
     $Output_Menu_DDir/apps.png
  
  $Str_BASEINFO_Attention

 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_CurrentOS${Font_Color_Reset} $Current_OS_Name_Full ($Current_DE)${Font_Reset}
 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_InstallMode${Font_Color_Reset} $Install_Mode${Font_Reset}"
		echo -e "\n $Str_BASEINFO_Confirm"
		read base_info_confirm
		if [ "$base_info_confirm" == "y" ] || [ "$base_info_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Color_Reset}${Font_Reset}"; fi
		
		if [ $MODE_DEBUG == true ]; then echo "_PRINT_PACKAGE_INFO - all_ok = $all_ok"; read pause; fi
	else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _PRINT_PACKAGE_INFO ${Font_Color_Reset}${Font_Reset}"; fi
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
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5PRINT_Head${Font_Color_Reset}${Font_Reset}

  $Str_ATTENTION ${Font_Bold}${Font_DarkRed}$Str_BASECHECKMD5PRINT_Hash_Not_Match${Font_Color_Reset}
  ${Font_Red}$Str_BASECHECKMD5PRINT_Hash_Not_Match2${Font_Color_Reset}${Font_Reset}
  
   ${Font_Bold}$Str_BASECHECKMD5PRINT_Expected_bHash${Font_Reset} \"$Archive_Base_Data_MD5\"
   ${Font_Bold}$Str_BASECHECKMD5PRINT_Real_bHash${Font_Reset}     \"$Base_Data_MD5\""

		echo -e "\n  $Str_CHECKMD5PRINT_yes_To_Continue"
		read base_errors_confirm
		if [ "$base_errors_confirm" == "y" ] || [ "$base_errors_confirm" == "yes" ]; then all_ok=true
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Color_Reset}${Font_Reset}"; fi
	else all_ok=true; fi
	if [ $MODE_DEBUG == true ]; then echo "_BASE_CHECK_MD5 - all_ok = $all_ok"; read pause; fi
else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _BASE_CHECK_MD5 ${Font_Color_Reset}${Font_Reset}"; fi
}


function _BASE_CREATE_TEMP() {
if [ $all_ok == true ]; then all_ok=false
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
	mkdir "$Base_Temp_Dir"
	all_ok=true
	if [ $MODE_DEBUG == true ]; then echo "_BASE_CREATE_TEMP - all_ok = $all_ok"; read pause; fi
else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_Error_All_Ok _BASE_CREATE_TEMP ${Font_Color_Reset}${Font_Reset}"; fi
}
function _BASE_DELETE_TEMP() {
if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
}


function _BASE_PREPARE_INPUT_FILES_GREP() {
	local p_text="$1"; local p_path="$2"
	grep -rl "$p_text" "$Base_Temp_Dir" | xargs sed -i "s~$p_text~$p_path~g" &> /dev/null
}

function _BASE_PREPARE_FILES() {
	if ! [[ -x "$Tool_SevenZip_bin" ]]; then chmod +x "$Tool_SevenZip_bin"; fi
	
	if ! "$Tool_SevenZip_bin" x "$Archive_Base_Data" -o"$Base_Temp_Dir/" &> /dev/null; then
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
