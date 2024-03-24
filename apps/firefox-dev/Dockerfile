FROM alpine:edge as rootfs

ARG REPO

# Install packages
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    bash \
    font-noto \
    netcat-openbsd \
    pulseaudio && \
  apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    firefox-developer-edition && \
  echo "**** customize desktop file ****" && \
  sed -i \
    -e "/^Exec=/c Exec=/bin/sh -c \"\$HOME\/.local\/bin\/proot-apps run ghcr.io/${REPO}:firefox-dev\"" \
    -e "s/Name=Name=Firefox Developer Edition/Name=Firefox Dev PA/g" \
    -e '/^TryExec=/d' \
    /usr/share/applications/firefox-developer-edition.desktop && \
  mv \
    /usr/share/applications/firefox-developer-edition.desktop \
    /usr/share/applications/firefox-developer-edition-pa.desktop && \
  echo "**** set bin name ****" && \
  echo "firefox-dev-pa" > /bin-name && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

COPY ./entrypoint /entrypoint
COPY ./install /install
COPY ./remove /remove
COPY /root /

FROM scratch
COPY --from=rootfs / /
