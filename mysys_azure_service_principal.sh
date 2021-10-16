#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/common.inc"

on_no_assign()
{
  info "[on_no_assign|in]"
  sp_name="$1"
  az ad sp create-for-rbac -n "$sp_name" --skip-assignment
  info "[on_no_assign|out]"
}

az_sp_on()
{
  info "[az_sp_on|in]"
  az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}" -o table
  info "[az_sp_on] please add the following output to '.secrets' file:     password(ARM_CLIENT_SECRET) "
  info "[az_sp_on] please add the following output to '.variables' file:   app_id(ARM_CLIENT_ID), tenant(ARM_TENANT_ID)"
  info "[az_sp_on|out]"
}

az_sp_off()
{
  info "[az_sp_off|in]"
  az ad sp delete --id "${ARM_CLIENT_ID}"
  info "[az_sp_off|out]"
}

az_sp_login()
{
  info "[az_sp_login|in]"
  az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
  info "[az_sp_login|out]"
}

az_sp_check()
{
  info "[az_sp_check|in]"
  az vm list-sizes --location westus
  info "[az_sp_check|out]"
}

usage()
{
  cat <<EOM
  usages:
  $(basename $0) {on|off|login|check|on_no_assign}
                          on
                            creates azure service principal with contributor role and the current account subscription
                          off
                            deletes the service principal with id defined in env var ARM_CLIENT_ID
                          login
                            logs in using the service principal credentials defined in environment
                          check
                            checks if logged in correctly listing VM's sizes
                          on_no_assign  <sp name>
                            creates azure service principal with no assignment
EOM
  exit 1
}

info "starting [ $0 $1 $2 ] ..."
_pwd=$(pwd)

case "$1" in
      on)
        az_sp_on
        ;;
      off)
        az_sp_off
        ;;
      login)
        az_sp_login
        ;;
      check)
        az_sp_check
        ;;
      on_no_assign)
        [ -z "$2" ] && err "[on_no_assign] <sp name> param is missing" && usage
        on_no_assign "$2"
        ;;
      *)
        usage
        ;;
esac

info "...[ $0 $1 $2 ] done."
