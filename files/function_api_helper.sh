#!/usr/bin/env bash

# http://bash.cumulonim.biz/NullGlob.html
shopt -s nullglob

# ---------- CONSTANTS ----------
export VARIABLES_FILE=${BASHUTILS_VARIABLES:-".variables"}
export SECRETS_FILE=${BASHUTILS_SECRETS:-".secrets"}
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

if [ ! -f "$this_folder/$VARIABLES_FILE" ]; then
  warn "we DON'T have a $VARIABLES_FILE variables file"
else
  . "$this_folder/$VARIABLES_FILE"
fi

if [ ! -f "$this_folder/$SECRETS_FILE" ]; then
  warn "we DON'T have a $SECRETS_FILE secrets file"
else
  . "$this_folder/$SECRETS_FILE"
fi


# contains <list> <item>
# echo $? # 0： match, 1: failed
contains() {
    [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 0 || return 1
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

verify_env(){
  info "[verify_env] ..."
  for arg in "$@"
  do
      debug "[verify_env] ... checking $arg"
      if [ -z "$arg" ]; then err "[verify_env] please define env var: $arg" && return 1; fi
  done
  info "[verify_env] ...done."
}

usage() {
  cat <<EOM
  usage:
  $(basename $0) { option }
    options:
      - prereqs
          checks pre-requirements to develop and run the solution:
          python 3.8.*, azure-cli, azure-functions-core-tools@4
      - install_prereqs <python 3.8.* binary path>
          installs pre-requirements to develop and run the solution:
            python 3.8 virtual environment and pre-requirements, using homebrew

EOM
  exit 1
}

prereqs() {
  info "[prereqs|in]"
  verify_prereqs az python func
  if [ $? -ne "0" ]; then
        info "please check system requirements in:"
        info "https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-python"
  fi
  python -V | grep  "Python 3.8."
  if [ $? -ne "0" ]; then
    info "please be sure to create a virtual environment with python 3.8.*"
  fi
  info "[prereqs|out]"
}

install_prereqs() {
  info "[install_prereqs|in]"

  local python_bin=""
  if [ -z "$1" ]; then
    err "[install_prereqs] please provide python bin location"
    return 1
  fi
  python_bin="$1"

  setup_venv "$python_bin"
  [ $? -ne "0" ] && return 1

  source ./.venv/bin/activate
  brew update
  brew install azure-cli
  az upgrade
  az config set auto-upgrade.enable=yes
  brew tap azure/functions
  brew install azure-functions-core-tools@4

  pip install azure-functions requests pytest

  if [ ! -f "$this_folder/$VARIABLES_FILE" ]; then
    info "creating $VARIABLES_FILE variables file"
    touch "$this_folder/$VARIABLES_FILE"
  fi

  if [ ! -f "$this_folder/$SECRETS_FILE" ]; then
    info "creating $SECRETS_FILE secrets file"
    touch "$this_folder/$SECRETS_FILE"
  fi

  info "[install_prereqs|out]"
}

setup_venv() {
  info "[setup_venv|in]"

  if [ -d "$this_folder/.venv" ]; then
    err "[setup_venv] you have a '.venv' folder in the project root! please remove the virtual environment before proceeding"
    return 1
  fi

  local python_bin=""
  if [ -z "$1" ]; then
    err "[setup_venv] please provide python bin location"
    return 1
  fi

  python_bin="$1"
  $python_bin -V | grep  "Python 3.8."
  if [ $? -ne "0" ]; then
    err "[setup_venv] python bin is not version 3.8.*"
    return 1
  fi

  $python_bin -m venv .venv
  info "[setup_venv|out]"
}


tests() {
  info "[tests|in]"
  func start &
  sleep 6

  python -m pytest -vv --durations=0 --junitxml=test-results.xml tests
  return_value="$?"

  pid=$(ps | grep "func start" | head -n1 | awk '{print $1}')
  kill -9 $pid
  pid=$(ps | grep "worker.py --host 127" | head -n1 | awk '{print $1}')
  kill -9 $pid


  info "[tests|out] => ${return_value}"
  [[ ! "$return_value" -eq "0" ]] && exit 1
}
debug "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6 7: $7 8: $8 9: $9"


case "$1" in
  prereqs)
    prereqs
    ;;
  install_prereqs)
    install_prereqs "$2"
    ;;
  tests)
    tests
    ;;
  *)
    usage
    ;;
esac