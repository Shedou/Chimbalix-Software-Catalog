#!/usr/bin/env bash
# Script version 1.0
# This can help avoid application version conflicts, but requires special preparation.
# WARNING! This is not intended for applications that are installed in system mode.
# WARNING! This is an experimental feature.
#

Path_To_Script="$( dirname "$(readlink -f "$0")")"

thunar "$Path_To_Script/userdata"
