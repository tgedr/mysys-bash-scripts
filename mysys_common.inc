# ===> COMMON SECTION START  ===>

if [ -z "$parent_folder" ]; then
  parent_folder=$(dirname "$this_folder")
fi

# http://bash.cumulonim.biz/NullGlob.html
shopt -s nullglob

# ---------- CONSTANTS ----------
export VARIABLES_FILE=${COMMON_VARIABLES_FILE:-".variables"}
export SECRETS_FILE=${COMMON_SECRETS_FILE:-".secrets"}
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

if [ ! -f "$INCLUDES_DIR/$VARIABLES_FILE" ]; then
  debug "we DON'T have a '$INCLUDES_DIR/$VARIABLES_FILE' file"
else
  . "$INCLUDES_DIR/$VARIABLES_FILE"
fi

if [ ! -f "$INCLUDES_DIR/$SECRETS_FILE" ]; then
  debug "we DON'T have a '$INCLUDES_DIR/$SECRETS_FILE' file"
else
  . "$INCLUDES_DIR/$SECRETS_FILE"
fi

# <=== COMMON SECTION END  <===