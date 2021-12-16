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
        $(basename $0) <PROJECT_NAME> <PYTHON 3.8 BIN PATH>
            creates a python 3.8 azure functions project
EOM
        exit 1
}

[ -z "$2" ] && { usage; }
[ -z "$1" ] && { usage; }

PROJECT_NAME="$1"
python_bin="$2"

$python_bin -V | grep  "Python 3.8."
if [ $? -ne "0" ]; then err "not python 3.8.* binary" && exit 1; fi

_pwd=$(pwd)

if [ ! -d "./$PROJECT_NAME" ]; then
  mkdir "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

if [ -d "./.venv" ]; then
  err "[setup_venv] you have a '.venv' folder in the project root! please remove the virtual environment before proceeding"
  cd "$_pwd"
  return 1
fi

$python_bin -m venv .venv && source ./.venv/bin/activate

export VARIABLES_FILE=${USER_VARIABLES_FILE:-".variables"}
export SECRETS_FILE=${USER_SECRETS_FILE:-".secrets"}

if [ ! -f "./$VARIABLES_FILE" ]; then
  info "creating $VARIABLES_FILE variables file"
  touch "./$VARIABLES_FILE"
fi

if [ ! -f "./$SECRETS_FILE" ]; then
  info "creating $SECRETS_FILE secrets file"
  touch "./$SECRETS_FILE"
fi

brew update
brew install azure-cli
az upgrade
az config set auto-upgrade.enable=yes
brew tap azure/functions
brew install azure-functions-core-tools@4

# create function project
func init --force --worker-runtime python

echo "\n" >> requirements.txt
echo "requests" >> requirements.txt
echo "pytest" >> requirements.txt
pip install -r requirements.txt

wget https://raw.githubusercontent.com/tgedr/mysys-bash-scripts/master/files/function_api_helper.sh -O helper.sh
chmod +x helper.sh

mkdir tests
wget https://raw.githubusercontent.com/tgedr/mysys-bash-scripts/master/files/conftest.py -P tests
wget https://raw.githubusercontent.com/tgedr/mysys-bash-scripts/master/files/test_hello_function_api.py -O tests/test_hello.py

echo ".venv/" >> .funcignore
echo "local.settings.json" >> .funcignore
echo "tests" >> .funcignore
echo ".variables" >> .funcignore
echo ".secrets" >> .funcignore
echo ".vscode/" >> .funcignore
echo "test-results.xml" >> .funcignore

echo ".secrets" >> .gitignore
echo ".vscode/" >> .gitignore
echo "test-results.xml" >> .gitignore

# create dummy function
func new --name hello --template "HTTP trigger" --authlevel "anonymous"


cd "$_pwd"

