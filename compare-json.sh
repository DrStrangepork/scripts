#!/bin/bash
CLEAN=false
DIFF=false


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Compares the contents of two JSON files, and the results are displayed in
        vimdiff (or diff if vimdiff not available).
Example:  $(basename ${BASH_SOURCE[0]}) -s SOURCE -t TARGET [-c] [-d] [-u]
Required: -s SOURCE -t TARGET
Options:
  -s SOURCE     first JSON file
  -t TARGET     second JSON file
  -c            cleanup /tmp/ files
  -d            run diff, not vimdiff
  -u            if updates were made to either file, save the original to
                  <filename>.sav and copy the updated version to <filename>
  -h            help"
}


prereq="Prerequisites are missing and must be installed before continuing:\n"
missing_req=false
if ! jq --version >/dev/null; then
  prereq+="\t'jq' from 'http://stedolan.github.com/jq'\n"
  missing_req=true
fi
if $missing_req; then
  echo -e "Error: $prereq" >&2
  exit 1
fi


[[ "$@" =~ "--help" ]] && { usage | less; exit; }
while getopts ":cds:t:uh" opt; do
  case $opt in
    c)  CLEAN=true
        ;;
    d)  DIFF=true
        ;;
    s)  SRCtmp=/tmp/src--$(basename $OPTARG)
        SOURCE=$OPTARG
        if [[ ! -s $SOURCE ]]; then
          echo "Error: Missing file $SOURCE" >&2
          exit 1
        elif ! cat $SOURCE | jq -S '' > $SRCtmp; then
          echo "Error: $SOURCE failed json validation" >&2
          exit 1
        fi
        ;;
    t)  TARGET=$OPTARG
        TRGtmp=/tmp/trg--$(basename $TARGET)
        if [[ ! -s $TARGET ]]; then
          echo "Error: Missing file $TARGET" >&2
          exit 1
        elif ! cat $TARGET | jq -S '' > $TRGtmp; then
          echo "Error: $TARGET failed json validation" >&2
          exit 1
        fi
        ;;
    u)  UPDATE=true
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[[ -s "$SRCtmp" && -s "$TRGtmp" ]] || { usage; exit 1; }


## MAIN
if ! diff $SRCtmp $TRGtmp >/dev/null; then
  if $DIFF -o [[ ! -x /usr/bin/vimdiff ]]; then
    diff $SRCtmp $TRGtmp
  else
    vimdiff $SRCtmp $TRGtmp
    if [ $UPDATE ]; then
      if ! cat $SRCtmp | jq -S '' >/dev/null; then
        echo "Error: $SRCtmp failed json validation" >&2
        exit 1
      elif ! diff $SRCtmp $SOURCE >/dev/null; then
        echo "Changes made to $SRCtmp"
        echo "Backing up $SOURCE to $SOURCE.sav"
        mv $SOURCE $SOURCE.sav
        echo "Copying $SRCtmp to $SOURCE"
        cp $SRCtmp $SOURCE
      else
        echo "No updates made to $SRCtmp"
      fi
      if ! cat $TRGtmp | jq -S '' >/dev/null; then
        echo "Error: $TRGtmp failed json validation" >&2
        exit 1
      elif ! diff $TRGtmp $TARGET >/dev/null; then
        echo "Changes made to $TRGtmp"
        echo "Backing up $TARGET to $TARGET.sav"
        mv $TARGET $TARGET.sav
        echo "Copying $TRGtmp to $TARGET"
        cp $TRGtmp $TARGET
      else
        echo "No updates made to $TRGtmp"
      fi
    fi
  fi
else
  echo Templates are identical
fi
$CLEAN && rm -f $SRCtmp $TRGtmp
