FROM jlesage/baseimage-gui:ubuntu-18.04

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        chromium-browser \
        desktop-file-utils \
        fonts-takao \
        fonts-takao-mincho \
        locales \
        software-properties-common \
        && \
    sed 's/\<Exec=chromium-browser\>/& --no-sandbox/' /usr/share/applications/chromium-browser.desktop > /usr/share/applications/chromium-browser-no-sandbox.desktop && \
    xdg-settings set default-web-browser chromium-browser-no-sandbox.desktop && /
    add-apt-repository -y ppa:musicbrainz-developers/stable && \
    apt-get update && \
    apt-get install -y \
        picard \
        && \
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
    BROWSER="chromium-browser" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"
    