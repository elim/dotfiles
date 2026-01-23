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

  # shellcheck disable=SC2295
  if test "${string#*$substring}" != "$string"; then
    return 0 # $substring is in $string
  else
    return 1 # $substring is not in $string
  fi
}

GOOGLE_ANALYTICS=a91117417w135038751p139142069
NEWRELIC=3717231
FIGMA_MP_MOBILE=vNkMNZjMqBvJ2rd0rUCmND

profile=Default

if
    contains "$1" "${FIGMA_MP_MOBILE}"          ||
    contains "$1" "${GOOGLE_ANALYTICS}"         ||
    contains "$1" "${NEWRELIC}"                 ||
    contains "$1" "amazonaws.com"               ||
    contains "$1" "backlog"                     ||
    contains "$1" "accounts.google.com/o/oauth2/" ||
    contains "$1" "biz.moneyforward.com"        ||
    contains "$1" "codetakt"                    ||
    contains "$1" "email-quarantine.google.com" ||
    contains "$1" "jobcan"                      ||
    contains "$1" "login.microsoftonline.com"   ||
    contains "$1" "lstep.jp"                    ||
    contains "$1" "manabipocket"                ||
    contains "$1" "manapoke"                    ||
    contains "$1" "microsoft.com/devicelogin"   ||
    contains "$1" "miro.com"                    ||
    contains "$1" "ms-teams-mp-redesign"        ||
    contains "$1" "newrelic"                    ||
    contains "$1" "notion.so"                   ||
    contains "$1" "offers.jp"                   ||
    contains "$1" "percy.io"                    ||
    contains "$1" "realtime-lms"                ||
    contains "$1" "report.stg-ed-cl.com"        ||
    contains "$1" "talentio"                    ||
    contains "$1" "teams.microsoft.com"         ||
    contains "$1" "zoom"

then
  profile=codeTakt
fi

brave --profile-directory="${profile}" "$1"
