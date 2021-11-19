#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/common.inc"

if [ ! -d "$USER_BIN_DIR" ]; then
  err "can't find local bin folder: $USER_BIN_DIR"
  exit 1
fi

_pwd=$(pwd)

cd "$USER_BIN_DIR"
rm mysys_*
curl -s https://api.github.com/repos/tgedr/mysys-bash-scripts/releases/latest \
| grep "browser_download_url.*mysys\.tar\.bz2" \
| cut -d '"' -f 4 | wget -qi -
tar xjpvf mysys.tar.bz2
rm mysys.tar.bz2

cd "$_pwd"