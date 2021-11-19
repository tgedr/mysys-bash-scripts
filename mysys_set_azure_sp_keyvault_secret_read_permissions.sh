#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/common.inc"

# parameter check
usage()
{
        cat <<EOM
        usage:
        $(basename $0) <keyvault_name> <service_principal_appid>
            assigns keyvault read permissions to a service principal
EOM
        exit 1
}

[ -z "$1" ] && { usage; }
[ -z "$2" ] && { usage; }

keyvault_name="$1"
service_principal_appid="$2"

az keyvault set-policy --name "$keyvault_name" --spn "$service_principal_appid" --secret-permissions get list
