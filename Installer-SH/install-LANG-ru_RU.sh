#!/usr/bin/env bash

Path_To_Script="$( dirname "$(readlink -f "$0")")"
env LANG=ru_RU.UTF-8 "$Path_To_Script/install.sh"
