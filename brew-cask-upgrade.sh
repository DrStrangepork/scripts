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
    # read n
done

# brew cask fetch $(brew cask list)

# $ brew cask info go-server
# go-server: 16.9.0-4001
# https://www.go.cd/
# /usr/local/Caskroom/go-server/16.2.1-3027 (68B)


# for pkg in $(brew cask list); do
#     pkg_latest=$(brew cask info $pkg | grep $pkg: | awk '{print $2}')
#     pkg_current=$(brew cask info $pkg | grep Caskroom | awk -F'/| ' '{print $6}')
#     if [ "$pkg_latest" != "$pkg_current" ]; then
#         brew cask fetch $pkg
#         brew cask install $pkg --force
#     fi
#     read n
# done

# for pkg in $(brew cask list); do brew cask cat $pkg | grep '  version '; done
#  version '1.12.1'
#  version '16.9.0-4001'
#  version '16.9.0-4001'
#  version :latest
#  version '3.0.9'
#  version '1.8.0_102-b14'
#  version :latest
#  version '2.3.4'
#  version '3.16.0-r1,osx-9'
#  version '2.0.3'
#  version '3114'
#  version '1.8.5'
