#!/usr/bin/env sh
#shellcheck shell=sh

set -xe

HOME=/config
export HOME

# Unlock Chromium profile
rm -rf /config/xdg/config/chromium/Singleton*

/usr/bin/picard