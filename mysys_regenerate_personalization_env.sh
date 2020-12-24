#!/usr/bin/env bash

# ===> COMMON SECTION START  ===>
# http://bash.cumulonim.biz/NullGlob.html
shopt -s nullglob

# ---------- CONSTANTS ----------
export USER_BIN_DIR=~/.local/bin
export INCLUDES_DIR=~
# -------------------------------

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi
if [ -z "$parent_folder" ]; then
  parent_folder=$(dirname "$this_folder")
fi

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
runFolder="personalization"

_pwd=$(pwd)
folder=$(basename "$_pwd")
# "mysys-bash-scripts"

if [ "$folder" != "$runFolder" ]; then
  err "not in $runFolder folder"
  exit 1
fi

rm -rf .env
python3 -m venv .env && source ./.env/bin/activate
python -m pip install -r requirements.txt
python -m pip uninstall pyspark
python -m pip install databricks-connect==7.1.0
python -m pip install yappi
python -m pip install vmprof==0.4.9
python -m pip install databricks-cli
python -m pip install pytest pytest-mock

_pwd=$(pwd)
cd ""



cd "$_pwd"