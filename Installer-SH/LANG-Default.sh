#!/usr/bin/env bash

Path_To_Script="$( dirname "$(readlink -f "$0")")"
env LANG=C.UTF-8 "$Path_To_Script/install.sh"
