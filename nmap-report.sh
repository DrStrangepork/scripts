#!/bin/bash


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Performs a port scan on a given target and saves an HTML report
        to ./nmap-report.html
Example:  $(basename ${BASH_SOURCE[0]}) -t 192.168.1.0/24
Required: -t TARGET
Options:
  -t TARGET   name of TARGET
  -h            help"
}


prereq="Prerequisites are missing and must be installed before continuing:\n"
missing_req=false
if ! nmap --version >/dev/null 2>&1; then
  prereq+="\tnmap\n"
  missing_req=true
fi
if ! xsltproc --version >/dev/null 2>&1; then
  prereq+="\tlibxslt\n"
  missing_req=true
fi
if $missing_req; then
  echo -e "Error: $prereq" >&2
  exit 1
fi


[[ "$*" =~ "--help" ]] && { usage | less; exit; }
while getopts ":p:r:s:t:h" opt; do
  case $opt in
    t)  TARGET=$OPTARG
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[[ -n "$TARGET" ]] || { usage; exit 1; }


## MAIN
nmap -sT --open -oX nmap-report.xml $TARGET
echo;echo
xsltproc nmap-report.xml -o nmap-report.html
sed -ne '/.*href="#host.* class="up">/ s/^.*>//p' nmap-report.html | sed '/^$/d'
