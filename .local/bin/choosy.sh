#!/bin/sh

# https://stackoverflow.com/a/8811800
#
# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

profile=Default

if
   contains "$1" "a91117417w135038751p139142069" ||
   contains "$1" "backlog"                       ||
   contains "$1" "codetakt"                      ||
   contains "$1" "jobcan"                        ||
   contains "$1" "manabipocket"                  ||
   contains "$1" "manapoke"                      ||
   contains "$1" "ms-teams-mp-redesign"          ||
   contains "$1" "offers.jp"                     ||
   contains "$1" "percy.io"                      ||      
   contains "$1" "realtime-lms"                  ||
   contains "$1" "talentio"                      ||
   contains "$1" "zoom"; then
  profile=codeTakt
fi

brave --profile-directory="${profile}" "$1"
