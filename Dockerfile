FROM docker.io/golang:1.21.3 AS trivy_builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    git clone --depth=1 https://github.com/aquasecurity/trivy /src/trivy && \
    pushd /src/trivy/cmd/trivy && \
    go build

FROM docker.io/jlesage/baseimage-gui:ubuntu-22.04-v4

ENV CHROMIUM_FLAGS="--no-sandbox" \
    URL_PICARD_REPO="https://github.com/metabrainz/picard.git" \
    URL_CHROMAPRINT_REPO="https://github.com/acoustid/chromaprint.git" \
    URL_GOOGLETEST_REPO="https://github.com/google/googletest.git"
    
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /
COPY --from=trivy_builder /src/trivy/cmd/trivy/trivy /src/trivy

RUN set -x && \
    # Define package arrays
    # TEMP_PACKAGES are packages that will only be present in the image during container build
    # KEPT_PACKAGES will remain in the image
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Install software-properties-common so we can use add-apt-repository
    TEMP_PACKAGES+=(software-properties-common) && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ${KEPT_PACKAGES[@]} \
      ${TEMP_PACKAGES[@]} \
      && \
    TEMP_PACKAGES+=(gnupg) && \
    # Install pip to allow install of Picard dependencies
    TEMP_PACKAGES+=(python3-pip) && \
    TEMP_PACKAGES+=(python3-setuptools) && \
    TEMP_PACKAGES+=(python3-wheel) && \
    # SSL Libs
    TEMP_PACKAGES+=(libssl-dev) && \
    KEPT_PACKAGES+=(libssl3) && \
    # Install git to allow clones of git repos
    TEMP_PACKAGES+=(git) && \
    # Install build tools to allow building
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(cmake) && \
    TEMP_PACKAGES+=(pkg-config) && \
    # Install Chromaprint dependencies
    KEPT_PACKAGES+=(ffmpeg) && \
    TEMP_PACKAGES+=(libswresample-dev) && \
    KEPT_PACKAGES+=(libswresample3) && \
    TEMP_PACKAGES+=(libfftw3-dev) && \
    KEPT_PACKAGES+=(libfftw3-3) && \
    TEMP_PACKAGES+=(libavcodec-dev) && \
    KEPT_PACKAGES+=(libavcodec58) && \
    TEMP_PACKAGES+=(libavformat-dev) && \
    KEPT_PACKAGES+=(libavformat58) && \
    # Install Picard dependencies
    TEMP_PACKAGES+=(python3-dev) && \
    KEPT_PACKAGES+=(python3-six) && \
    TEMP_PACKAGES+=(libdiscid-dev) && \
    KEPT_PACKAGES+=(libdiscid0) && \
    KEPT_PACKAGES+=(libxcb-icccm4) && \
    KEPT_PACKAGES+=(libxcb-keysyms1) && \
    KEPT_PACKAGES+=(libxcb-randr0) && \
    KEPT_PACKAGES+=(libxcb-render-util0) && \
    KEPT_PACKAGES+=(libxcb-xinerama0) && \
    KEPT_PACKAGES+=(libxcb-image0) && \
    KEPT_PACKAGES+=(libxcb-xkb1) && \
    KEPT_PACKAGES+=(libxkbcommon-x11-0) && \
    KEPT_PACKAGES+=(gettext) && \
    KEPT_PACKAGES+=(locales) && \
    # Package below fixes: issue #77
    KEPT_PACKAGES+=(libhangul1) && \
    # Package below fixes: issue #42
    KEPT_PACKAGES+=(libgtk-3-0) && \
    KEPT_PACKAGES+=(fonts-takao) && \
    KEPT_PACKAGES+=(fonts-takao-mincho) && \
    KEPT_PACKAGES+=(wget) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    # Install Picard optical drive dependencies
    KEPT_PACKAGES+=(lsscsi) && \
    # Install Picard Media Player dependencies
    KEPT_PACKAGES+=(gstreamer1.0-plugins-good) && \
    KEPT_PACKAGES+=(gstreamer1.0-libav) && \
    KEPT_PACKAGES+=(libpulse-mainloop-glib0) && \
    KEPT_PACKAGES+=(libqt5multimedia5-plugins) && \
    KEPT_PACKATES+=(libavcodec57) && \
    # Install Chrome dependencies
    KEPT_PACKAGES+=(dbus-x11) && \
    KEPT_PACKAGES+=(uuid-runtime) && \
    # Install Picard plugin dependencies
    KEPT_PACKAGES+=(python3-aubio) && \
    KEPT_PACKAGES+=(aubio-tools) && \
    KEPT_PACKAGES+=(flac) && \
    KEPT_PACKAGES+=(vorbisgain) && \
    KEPT_PACKAGES+=(wavpack) && \
    KEPT_PACKAGES+=(mp3gain) && \
    # Install window compositor
    KEPT_PACKAGES+=(openbox) && \
    # Security updates / fix for issue #37 (https://github.com/mikenye/docker-picard/issues/37)
    TEMP_PACKAGES+=(jq) && \
    # Install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ${KEPT_PACKAGES[@]} \
      ${TEMP_PACKAGES[@]} \
      && \
    # Update ca certs
    update-ca-certificates -f && \
    # Build & install OpenSSL v1.1.1
    wget \
      -O /tmp/openssl-1.1.1w.tar.gz \
      --progress=dot:giga \
      https://www.openssl.org/source/openssl-1.1.1w.tar.gz \
      && \
    mkdir -p /src/openssl && \
    tar \
      xzvf \
      /tmp/openssl-1.1.1w.tar.gz \
      -C /src/openssl \
      && \
    pushd /src/openssl/openssl-* && \
    ./config && \
    make test && \
    make && \
    make install && \
    popd && \
    ldconfig && \
    # Prevent annoying detached head warnings
    git config --global advice.detachedHead false && \
    # Clone googletest (required for build of Chromaprint)
    git clone "$URL_GOOGLETEST_REPO" /src/googletest && \
    pushd /src/googletest && \
    BRANCH_GOOGLETEST=$(git tag --sort="-creatordate" | grep 'release-' | head -1) && \
    git checkout "tags/${BRANCH_GOOGLETEST}" && \
    echo "googletest $BRANCH_GOOGLETEST" >> /VERSIONS && \
    popd && \
    # Clone Chromaprint repo & checkout latest version
    git clone "$URL_CHROMAPRINT_REPO" /src/chromaprint && \
    pushd /src/chromaprint && \
    # Pin chromaprint version to v1.4.3 due to https://github.com/acoustid/chromaprint/issues/107
    # BRANCH_CHROMAPRINT=$(git tag --sort="-creatordate" | head -1) && \
    BRANCH_CHROMAPRINT="v1.4.3" && \
    git checkout "tags/${BRANCH_CHROMAPRINT}" && \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TOOLS=ON \
      -DBUILD_TESTS=ON \
      -DGTEST_SOURCE_DIR=/src/googletest/googletest \
      -DGTEST_INCLUDE_DIR=/src/googletest/googletest/include . \
      && \
    make && \
    make check && \
    make install && \
    echo "chromaprint $BRANCH_CHROMAPRINT" >> /VERSIONS && \
    popd && \
    ldconfig && \
    # Install chromium browser - https://askubuntu.com/questions/1204571/how-to-install-chromium-without-snap
    bash -c " echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/debian-buster.gpg] http://deb.debian.org/debian buster main' > /etc/apt/sources.list.d/debian.list" && \
    bash -c " echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/debian-buster-updates.gpg] http://deb.debian.org/debian buster-updates main' >> /etc/apt/sources.list.d/debian.list" && \
    bash -c " echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/debian-security-buster.gpg] http://deb.debian.org/debian-security buster/updates main' >> /etc/apt/sources.list.d/debian.list" && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DCC9EFBF77E11517 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 112695A0E562B32A && \
    bash -c "apt-key export 77E11517 | gpg --dearmour -o /usr/share/keyrings/debian-buster.gpg" && \
    bash -c "apt-key export 22F3D138 | gpg --dearmour -o /usr/share/keyrings/debian-buster-updates.gpg" && \
    bash -c "apt-key export E562B32A | gpg --dearmour -o /usr/share/keyrings/debian-security-buster.gpg" && \
    apt-get update && \
    apt-get install --no-install-recommends -y chromium && \
    # Clone Picard repo & checkout latest version
    git clone "$URL_PICARD_REPO" /src/picard && \
    pushd /src/picard && \
    BRANCH_PICARD=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "tags/${BRANCH_PICARD}" && \
    # Install Picard requirements
    python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir discid python-libdiscid && \
    python3 -m pip install --no-cache-dir -r requirements.txt && \
    locale-gen en_US.UTF-8 && \
    export LC_ALL=C.UTF-8 && \
    # Build & install Picard
    python3 setup.py test && \
    python3 setup.py install && \
    mkdir -p /tmp/run/user/app && \
    chmod 0700 /tmp/run/user/app && \
    bash -c "if picard -v 2>&1 | grep -c error; then exit 1; fi" && \
    bash -c "picard -v | cut -d ' ' -f 2- >> /VERSIONS" && \
    popd && \
    # Symlink for fpcalc (issue #32)
    ln -s /usr/local/bin/fpcalc /usr/bin/fpcalc && \
    # Add optical drive script from jlesage/docker-handbrake
    wget \
      --progress=dot:giga \
      https://raw.githubusercontent.com/jlesage/docker-handbrake/6eb5567bcc29c2441507cb8cbd276293ec1790c8/rootfs/etc/cont-init.d/54-check-optical-drive.sh \
      -O /etc/cont-init.d/54-check-optical-drive.sh \
      && \
    chmod +x /etc/cont-init.d/54-check-optical-drive.sh && \
    # Security updates / fix for issue #37 (https://github.com/mikenye/docker-picard/issues/37)    
    /src/trivy --cache-dir /tmp/trivy fs --vuln-type os -f json --ignore-unfixed --no-progress -o /tmp/trivy.out / && \
    apt-get install -y --no-install-recommends $(jq .[].Vulnerabilities < /tmp/trivy.out | grep '"PkgName":' | tr -s ' ' | cut -d ':' -f 2 | tr -d ' ",' | uniq) && \
    # Install streaming_extractor_music
    wget \
      -O /tmp/essentia-extractor-linux-x86_64.tar.gz \
      --progress=dot:giga \
      'https://data.metabrainz.org/pub/musicbrainz/acousticbrainz/extractors/essentia-extractor-v2.1_beta2-linux-x86_64.tar.gz' \
      && \
    tar \
      xzvf \
      /tmp/essentia-extractor-linux-x86_64.tar.gz \
      -C /usr/local/sbin \
      && \
    # Clean-up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -exec truncate --size=0 {} \; && \
    # Install Chinese Fonts
    wget \
      --progress=dot:giga \
      -O /usr/share/fonts/SimSun.ttf \
      "https://github.com/micmro/Stylify-Me/blob/main/.fonts/SimSun.ttf?raw=true" && \
    fc-cache && \
    # Capture picard version
    mkdir -p /tmp/run/user/app && \
    bash -c "picard -V | grep Picard | cut -d ',' -f 1 | cut -d ' ' -f 2 | tr -d ' ' > /CONTAINER_VERSION"

ENV APP_NAME="MusicBrainz Picard" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"
