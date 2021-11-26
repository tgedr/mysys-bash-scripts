#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/mysys_common.inc"


setup_databricks_spark()
{
  info "[setup_databricks_spark|in]"
  python -m pip uninstall pyspark
  python -m pip install databricks-connect==7.3.27
  python -m pip install databricks-cli
  info "[setup_databricks_spark|out]"
}

set_regular_spark()
{
  info "[set_regular_spark|in]"
  python -m pip uninstall databricks-connect databricks-cli
  python -m pip install pyspark==3.2.0
  info "[set_regular_spark|out]"
}

usage()
{
  cat <<EOM
  usages:
  $(basename $0) {on|off}
                          on
                            sets up databricks connect
                          off
                            sets up local spark
EOM
  exit 1
}

info "starting [ $0 $1 $2 ] ..."
_pwd=$(pwd)

case "$1" in
      on)
        setup_databricks_spark
        ;;
      off)
        set_regular_spark
        ;;
      *)
        usage
        ;;
esac

info "...[ $0 $1 $2 ] done."

cd "$_pwd"