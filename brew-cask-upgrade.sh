#!/usr/bin/env bash

##### COLORS
BLUE()  { tput bold; tput setaf 4; echo -e -n "$@"; tput sgr0; }
WHITE() { tput bold; tput setaf 7; echo -e -n "$@"; tput sgr0; }
##### END COLORS

packages="$(brew cask outdated --greedy --quiet)"
[ -n "$packages" ] && echo || exit 0

BLUE "==> "; WHITE "Upgrading $(echo $packages | wc -w) outdated Casks, with result:\\n"
echo $packages
for pkg in $packages; do
    brew cask fetch $pkg
    brew cask install $pkg --force
    cask-retire.sh
    echo
done
