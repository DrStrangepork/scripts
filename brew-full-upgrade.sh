#!/usr/bin/env bash

##### COLORS
BLUE()  { tput bold; tput setaf 4; echo -e -n "$@"; tput sgr0; }
WHITE() { tput bold; tput setaf 7; echo -e -n "$@"; tput sgr0; }
##### END COLORS

brew cleanup
brew update
brew upgrade

packages="$(brew cask outdated --greedy --verbose | awk '$NF !~ /latest/ {print $1}')"
[ -n "$packages" ] && brew cask reinstall $packages
