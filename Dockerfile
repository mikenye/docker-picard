FROM jlesage/baseimage-gui:ubuntu-18.04

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        chromium-browser \
        fonts-takao \
        fonts-takao-mincho \
        locales \
        software-properties-common \
        wget \
        ca-certificates \
        xdg-utils \
        && \
    echo "========== Install Picard ==========" && \
    add-apt-repository -y ppa:musicbrainz-developers/stable && \
    apt-get update && \
    apt-get install -y \
        picard \
        && \
    echo "========== Install Picard plugin dependencies ==========" && \
    apt-get install -y \
        python3-aubio \
        python-aubio \
        aubio-tools \
        flac \
        && \
    echo "========== Update OpenBox Config ==========" && \
    sed -i 's/<application type="normal">/<application type="normal" title="MusicBrainz Picard">/' /etc/xdg/openbox/rc.xml && \
    sed -i '/<decor>no<\/decor>/d' /etc/xdg/openbox/rc.xml && \
    echo "========== Final Config ==========" && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /tmp/run/user/app && \
    chmod 0700 /tmp/run/user/app && \
    sed -i 's/Exec=chromium-browser/Exec=chromium-browser --no-sandbox/g' /usr/share/applications/chromium-browser.desktop && \
    echo "========== Clean-up ==========" && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY startapp.sh /startapp.sh

ENV APP_NAME="MusicBrainz Picard" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"
    
