#!/usr/bin/env sh
#shellcheck shell=sh

set -xe

# Set homedir to /config to capture all configuration
HOME=/config
export HOME

# Unlock Chromium profile
rm -rf /config/xdg/config/chromium/Singleton*

# Launch picard
/usr/local/bin/picard