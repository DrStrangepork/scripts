#!/usr/bin/env bash

##### COLORS
BLUE()  { tput bold; tput setaf 4; echo -e -n "$@"; tput sgr0; }
WHITE() { tput bold; tput setaf 7; echo -e -n "$@"; tput sgr0; }
##### END COLORS


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Upgrade all brew packages and casks
Options:
  -g            \`brew upgrade --cask --greedy\`
  -h            help"
}


[[ "$*" =~ "--help" ]] && { usage | less; exit; }
while getopts ":gh" opt; do
  case $opt in
    g)  GREEDY=--greedy
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done


## MAIN
brew cleanup
brew update
brew upgrade

packages="$(brew outdated --cask $GREEDY)"
[ -z "$packages" ] && { echo "No casks to upgrade"; exit 0; }
BLUE "\n==> "; WHITE "Upgrading $(echo $packages | wc -w) outdated Casks, with result:\\n"
echo $packages
brew upgrade --cask $GREEDY
