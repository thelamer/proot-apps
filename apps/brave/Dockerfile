FROM debian:bookworm-slim as rootfs

ARG REPO

# Install packages
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fonts-noto \
    netcat-openbsd \
    pulseaudio && \
  ARCH=$(uname -m| sed 's/x86_64/amd64/g'| sed 's/aarch64/arm64/') && \
  BRAVE_DEB=$(curl -sL https://brave-browser-apt-release.s3.brave.com/dists/stable/main/binary-${ARCH}/Packages \
    | awk -F ': ' '/brave-browser*.*'${ARCH}'/ {print $2;exit}') && \
  BRAVE_KEY_DEB=$(curl -sL https://brave-browser-apt-release.s3.brave.com/dists/stable/main/binary-${ARCH}/Packages \
    | awk -F ': ' '/brave-keyring*.*deb/ {print $2;exit}') && \
  curl -o \
    /tmp/brave_key.deb -L \
    "https://brave-browser-apt-release.s3.brave.com/${BRAVE_KEY_DEB}" && \
  curl -o \
    /tmp/brave.deb \
    -L "https://brave-browser-apt-release.s3.brave.com/${BRAVE_DEB}" && \
  apt install -y --no-install-recommends \
    /tmp/brave_key.deb && \
  apt install -y --no-install-recommends \
    /tmp/brave.deb && \
  echo "**** customize desktop file ****" && \
  sed -i \
    -e "/^Exec=/c Exec=/bin/sh -c \"\$HOME\/.local\/bin\/proot-apps run ghcr.io/${REPO}:brave\"" \
    -e "s/Name=Brave Web Browser/Name=Brave PA/g" \
    -e '/^TryExec=/d' \
    /usr/share/applications/brave-browser.desktop && \
  mv \
    /usr/share/applications/brave-browser.desktop \
    /usr/share/applications/brave-browser-pa.desktop && \
  echo "**** set bin name ****" && \
  echo "brave-pa" > /bin-name && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

COPY ./entrypoint /entrypoint
COPY ./install /install
COPY ./remove /remove
COPY /root /

FROM scratch
COPY --from=rootfs / /
