#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/mysys_common.inc"

# parameter check
usage()
{
        cat <<EOM
        usage:
        $(basename $0) { msg }
            encodes (base64) and encrypts a message using keybase
            requirements: keybase
EOM
        exit 1
}

[ -z "$1" ] && { usage; }

verify_prereqs keybase
if [ ! "$?" -eq "0" ] ; then err "please install keybase" && exit 1; fi

#echo "$msg" | base64 | keybase pgp encrypt | keybase pgp decrypt | base64 --decode

__out=$(echo "$@" | base64 | keybase pgp encrypt)
if [ ! "$?" -eq "0" ] ; then err "no luck" && exit 1; fi

echo "$__out"
