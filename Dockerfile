FROM jlesage/baseimage-gui:ubuntu-18.04

RUN set -x && \
    apt-get update -y && \
    echo "========== Japanese font support (github issue #2) ==========" && \
    apt-get install -y fonts-takao && \
    echo "=============================================================" && \
    apt-get install -y locales software-properties-common && \
    add-apt-repository -y ppa:musicbrainz-developers/stable && \
    apt-get install -y picard && \
    echo "#!/bin/sh" >> /startapp.sh && \
    echo "export HOME=/config" >> /startapp.sh && \
    echo "/usr/bin/picard -N" >> /startapp.sh && \
    chmod a+x /startapp.sh && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /tmp/run/user/app && \
    chmod 0700 /tmp/run/user/app && \
    echo "========== Clean-up ==========" && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV APP_NAME="MusicBrainz Picard" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"
    
