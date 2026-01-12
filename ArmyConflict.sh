#!/bin/sh
printf '\033c\033]0;%s\a' ArmyConflict
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ArmyConflict.x86_64" "$@"
