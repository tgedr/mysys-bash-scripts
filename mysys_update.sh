#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

# ===> COMMON SECTION START  ===>

if [ -z "$parent_folder" ]; then
  parent_folder=$(dirname "$this_folder")
fi

# http://bash.cumulonim.biz/NullGlob.html
shopt -s nullglob

# ---------- CONSTANTS ----------
export USER_BIN_DIR=~/.local/bin
export INCLUDES_DIR=~
# -------------------------------

debug(){
    local __msg="$@"
    echo " [DEBUG] `date` ... $__msg "
}

info(){
    local __msg="$@"
    echo " [INFO]  `date` ->>> $__msg "
}

warn(){
    local __msg="$@"
    echo " [WARN]  `date` *** $__msg "
}

err(){
    local __msg="$@"
    echo " [ERR]   `date` !!! $__msg "
}

verify_prereqs(){
  info "[verify_prereqs] ..."
  for arg in "$@"
  do
      debug "[verify_prereqs] ... checking $arg"
      which "$arg" 1>/dev/null
      if [ ! "$?" -eq "0" ] ; then err "[verify_prereqs] please install $arg" && return 1; fi
  done
  info "[verify_prereqs] ...done."
}

if [ ! -f "$INCLUDES_DIR/.variables.inc" ]; then
  debug "we DON'T have a '$INCLUDES_DIR/.variables.inc' file"
else
  . "$INCLUDES_DIR/.variables.inc"
fi

if [ ! -f "$INCLUDES_DIR/.secrets.inc" ]; then
  debug "we DON'T have a '$INCLUDES_DIR/.secrets.inc' file"
else
  . "$INCLUDES_DIR/.secrets.inc"
fi

# <=== COMMON SECTION END  <===

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