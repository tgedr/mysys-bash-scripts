# mysys-bash-scripts
handy bash scripts

* set of scripts to be downloaded and placed in the user bin folder, normally `~/.local/bin`
* assumes user bin folder is included in system `PATH`
* some scripts try to include variables and secrets through the files `.variables.inc` and `.secrets.inc` placed in the user folder `~`:
```
export USER_BIN_DIR=~/.local/bin
export INCLUDES_DIR=~

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
``` 
## usage
* first time - download and run `./mysys_update.sh` 
* after - just run `mysys_update.sh` to update the set of scripts in your bin folder
* run `mysys_help.sh` for info on the existent scripts
