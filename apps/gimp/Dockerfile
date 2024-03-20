FROM alpine:3.19 as rootfs

ARG REPO

# Install packages
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    bash \
    gimp \
    font-noto && \
  echo "**** customize desktop file ****" && \
  sed -i \
    -e "/^Exec=/c Exec=/bin/sh -c \"\$HOME\/.local\/bin\/proot-apps run ghcr.io/${REPO}:gimp\"" \
    -e "s/Name=GNU Image Manipulation Program/Name=GIMP PA/g" \
    /usr/share/applications/gimp.desktop && \
  mv \
    /usr/share/applications/gimp.desktop \
    /usr/share/applications/gimp-pa.desktop && \
  echo "**** set bin name ****" && \
  echo "gimp-pa" > /bin-name && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

COPY ./entrypoint /entrypoint
COPY ./install /install
COPY ./remove /remove

FROM scratch
COPY --from=rootfs / /
