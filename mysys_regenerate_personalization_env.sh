#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/mysys_common.inc"

runFolder="personalization"

_pwd=$(pwd)
folder=$(basename "$_pwd")

if [ "$folder" != "$runFolder" ]; then
  err "not in $runFolder folder"
  exit 1
fi

rm -rf .env
/usr/local/bin/python3.7 -m venv .env && source ./.env/bin/activate
python -m pip install -r requirements.txt
python -m pip uninstall pyspark
python -m pip install databricks-connect==7.3.27
python -m pip install yappi
python -m pip install vmprof==0.4.9
python -m pip install databricks-cli
#python -m pip install pytest pytest-mock

_pwd=$(pwd)
cd ""



cd "$_pwd"