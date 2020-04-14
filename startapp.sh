#!/usr/bin/env sh
#shellcheck shell=sh

set -xe

export HOME=/config

# Set default browser
#firefox -setDefaultBrowser
#
#PROFILEDIR=$(cat /config/.mozilla/firefox/profiles.ini | grep Path= | grep .default-release | cut -d "=" -f 2)
#PROFILEPATH="/config/.mozilla/firefox/${PROFILEDIR}"

/usr/bin/picard -N