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

# parameter check
usage()
{
        cat <<EOM
        usage:
        $(basename $0) <proj_name>
            creates a python 3 proj
EOM
        exit 1
}

[ -z "$1" ] && { usage; }

proj_name="$1"

if [ -d "$proj_name" ]; then err "project already created in folder" && exit 1; fi

python3 -V
if [ ! "$?" -eq "0" ] ; then err "please install python 3.7.9 to use black with azure devops" && exit 1; fi

_pwd=$(pwd)
mkdir "$proj_name"
cd "$proj_name"
git init
echo ".env" >> .gitignore
mkdir "$proj_name"
mkdir tests
echo "\"\"\"package: $proj_name\"\"\"" > "$proj_name/__init__.py"
echo "__version__ = '0.0.0'" >> "$proj_name/__init__.py"
python3 -m venv .env && source ./.env/bin/activate

python -m pip install -U pip wheel setuptools
python -m pip install flit
flit init


cd "$_pwd"