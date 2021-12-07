#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/mysys_common.inc"

usage()
{
        cat <<EOM
        usage:
        $(basename $0) {project_dir} {username} {email}
          sets git local config user and email in provided project directory, assuming git project there

EOM
        exit 1
}

[ -z "$1" ] && { usage; }
[ -z "$2" ] && { usage; }
[ -z "$3" ] && { usage; }

folder="$1"
username="$2"
email="$3"

verify_prereqs git
if [ ! "$?" -eq "0" ] ; then err "no git ???" && exit 1; fi
if [ ! -d "${folder}/.git" ]; then err "no git config folder in there ???" && exit 1; fi

_pwd=`pwd`
cd "$folder"
git config --local user.name "$username"
git config --local user.email "$email"

cd "$_pwd"