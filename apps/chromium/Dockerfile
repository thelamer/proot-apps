FROM debian:bookworm-slim as rootfs

ARG REPO

# Install packages
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    chromium \
    fonts-noto \
    pulseaudio && \
  echo "**** customize desktop file ****" && \
  sed -i \
    -e "/Exec=/c Exec=/bin/sh -c \"\$HOME\/.local\/bin\/proot-apps run ghcr.io/${REPO}:chromium\"" \
    -e "s/Name=Chromium Web Browser/Name=Chromium PA/g" \
    /usr/share/applications/chromium.desktop && \
  mv \
    /usr/share/applications/chromium.desktop \
    /usr/share/applications/chromium-pa.desktop && \
  echo "**** set bin name ****" && \
  echo "chromium-pa" > /bin-name && \
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

FROM scratch
COPY --from=rootfs / /
