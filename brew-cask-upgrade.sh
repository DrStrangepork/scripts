#!/bin/bash

for pkg in $(brew cask list); do
    pkg_latest=$(brew cask info $pkg | grep $pkg: | awk '{print $2}')
    [ "$pkg_latest" == "latest" ] && continue
    pkg_current=$(brew cask cat $pkg | grep '  version ' | awk '{print $2}')
    if [[ "$pkg_latest" != "$pkg_current" && "'$pkg_latest'" != "$pkg_current" ]]; then
        echo $pkg
        brew cask fetch $pkg
        brew cask install $pkg --force
        echo
    fi
done
