#!/usr/bin/env bash

echo Executing \'brew cleanup\; brew cask cleanup\; brew update\'
brew cleanup; brew cask cleanup; brew update
for pkg in $(brew cask list); do
    pkg_latest=$(brew cask info $pkg | grep $pkg: | awk '{print $2}')
    [ "$pkg_latest" == "latest" ] && continue
    if [ ! -d /usr/local/Caskroom/$pkg/$pkg_latest ]; then
        echo $pkg
        brew cask fetch $pkg
        brew cask install $pkg --force
        echo
    fi
done
