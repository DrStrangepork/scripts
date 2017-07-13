#!/usr/bin/env bash

##### COLORS
BLUE()  { tput bold; tput setaf 4; echo -e -n "$@"; tput sgr0; }
WHITE() { tput bold; tput setaf 7; echo -e -n "$@"; tput sgr0; }
##### END COLORS

brew cleanup; brew cask cleanup
brew update
brew upgrade
for pkg in $(brew cask list); do
    pkg_latest=$(brew cask info $pkg | grep $pkg: | awk '{print $2}')
    [ "$pkg_latest" == "latest" ] && continue
    [ ! -d /usr/local/Caskroom/$pkg/$pkg_latest ] && pkgs="$pkgs $pkg"
done
[ -n "$pkgs" ] && echo || exit 0

BLUE "==> "; WHITE "Upgrading $(echo $pkgs | wc -w) outdated Casks, with result:\\n"
echo $pkgs
for pkg in $pkgs; do
    brew cask fetch $pkg
    brew cask install $pkg --force
done
