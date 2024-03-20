# PRoot Apps

PRoot Apps is a simple platform to install and use applications without any privileges in Linux userspace using [PRoot](https://proot-me.github.io/). Applications are bundled with their entire toolchain much like [snap](https://snapcraft.io/) or [Flatpak](https://flatpak.org/), unlike these platforms:

* No system requirements outside of curl and bash
* Can be run in very restrictive environments even inside userspace in a Docker container
* Performs no space saving optimizations, every PRoot app lives in its own individual file folder without a base or any overlay style filesystem
* Are ingested from [Docker](https://www.docker.com/) registries and can be published by anyone while being consumed by anyone

# For Users

## Install or update

```
rm -f $HOME/.local/bin/{proot-apps,proot,jq}
mkdir -p $HOME/.local/bin
curl -L https://github.com/thelamer/proot-apps/releases/download/$(curl -sX GET "https://api.github.com/repos/thelamer/proot-apps/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')/proot-apps-$(uname -m).tar.gz | tar -xzf - -C $HOME/.local/bin/
export PATH="$HOME/.local/bin:$PATH"
```

**Optional add path to env**

```
echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
```

**PRoot Apps is currently only supported on amd64 and arm64 systems**

## Uninstall

```
rm -f $HOME/.local/bin/{proot-apps,proot,jq}
rm -Rf $HOME/proot-apps/
```

## Hello World

To install your first app [Firefox](https://www.mozilla.org/firefox/) simply execute:

```
proot-apps install firefox
```

The files for Firefox will be install to a folder in `$HOME/proot-apps/`, Desktop and start menu shortcuts will also be created these names will not conflict with system installed packages.

These short named apps are available from the supported list below, but any app can be consumed from a Docker endpoint IE:

```
proot-apps install ghcr.io/thelamer/proot-apps:firefox
```

To remove the application:

```
proot-apps remove firefox
```

To update the application:

```
proot-apps update firefox
```

## Supported Apps

| Name | Full Endpoint | Description |
| :----: | :----: |--- |
| chromium | ghcr.io/thelamer/proot-apps:chromium | Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all users to experience the web. |
| firefox | ghcr.io/thelamer/proot-apps:firefox | Firefox Browser, also known as Mozilla Firefox or simply Firefox, is a free and open-source web browser developed by the Mozilla Foundation and its subsidiary, the Mozilla Corporation. Firefox uses the Gecko layout engine to render web pages, which implements current and anticipated web standards.|

# For Developers
