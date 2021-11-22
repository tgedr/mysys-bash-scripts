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
        $(basename $0) <output folder> <key name>
            creates keys both in pub and pem format
EOM
        exit 1
}

[ -z "$1" ] && { usage; }
[ -z "$2" ] && { usage; }

folder="$1"
name="$2"
path="${folder}/${name}"
pem_pub="${path}_pub.pem"

ssh-keygen -t rsa -b 4096 -f "$path" -m pem
openssl rsa -in "$path" -pubout -outform pem > "$pem_pub"
