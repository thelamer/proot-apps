# PRoot Apps

PRoot Apps is a simple platform to install and use applications without any privileges in Linux userspace using [PRoot](https://proot-me.github.io/). Applications are bundled with their entire toolchain much like [snap](https://snapcraft.io/) or [Flatpak](https://flatpak.org/), unlike these platforms:

* No system requirements outside of curl and bash
* Can be run in very restrictive environments even inside userspace in a Docker container
* Performs no space saving optimizations, every PRoot app lives in its own individual file folder without a base or any overlay style filesystem
* Are ingested from [Docker](https://www.docker.com/) registries and can be published by anyone while being consumed by anyone

# For Users

## Install or update

```
rm -f $HOME/.local/bin/{ncat,proot-apps,proot,jq}
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
rm -f $HOME/.local/bin/{ncat,proot-apps,proot,jq}
rm -Rf $HOME/proot-apps/
```

## Hello World

To install your first app [Firefox](https://www.mozilla.org/firefox/) simply execute:

```
proot-apps install firefox
```

The files for Firefox will be installed to a folder in `$HOME/proot-apps/`, Desktop and start menu shortcuts will also be created these names should not conflict with system installed packages.

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

| Name | Full Endpoint | Arch | Description |
| :----: | :----: | :----: |--- |
| brave | ghcr.io/thelamer/proot-apps:brave | amd64,arm64 | Brave is a free and open-source web browser developed by Brave Software, Inc. based on the Chromium web browser. Brave is a privacy-focused browser, which automatically blocks most advertisements and website trackers in its default settings.|
| chromium | ghcr.io/thelamer/proot-apps:chromium | amd64,arm64 | Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all users to experience the web. |
| firefox | ghcr.io/thelamer/proot-apps:firefox | amd64,arm64 | Firefox Browser, also known as Mozilla Firefox or simply Firefox, is a free and open-source web browser developed by the Mozilla Foundation and its subsidiary, the Mozilla Corporation. Firefox uses the Gecko layout engine to render web pages, which implements current and anticipated web standards.|
| firefox-dev | ghcr.io/thelamer/proot-apps:firefox-dev | amd64,arm64 | The browser made for developers, all the latest developer tools in beta in addition to features like the Multi-line Console Editor and WebSocket Inspector. A separate profile and path so you can easily run it alongside Release or Beta Firefox. Preferences tailored for web developers: Browser and remote debugging are enabled by default, as are the dark theme and developer toolbar button.|
| gimp | ghcr.io/thelamer/proot-apps:gimp | amd64,arm64 | GIMP is a free and open-source raster graphics editor used for image manipulation (retouching) and image editing, free-form drawing, transcoding between different image file formats, and more specialized tasks. It is extensible by means of plugins, and scriptable.|
| opera | ghcr.io/thelamer/proot-apps:opera | amd64 | Opera is a multi-platform web browser developed by its namesake company Opera. The browser is based on Chromium, but distinguishes itself from other Chromium-based browsers (Chrome, Edge, etc.) through its user interface and other features.|

# For Developers

This repository was made to be cloned and forked with all of the build logic being templated to the repository owner and name. Simply forking this repository and enabling GitHub actions should be enough to get building using GitHub's builders. Also included in this repository is a nightly package check action, in order to use that you will need to set a [GitHub Secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) for `PAT` for that bot to work as it needs basic write access to the repo to trigger downstream build actions. The build logic is currently configured to detect changes to the specific folders in `apps` to determine if they need to be built. To build a backlog of the images in this repo when forked removing the package_versions.txt from the apps you want to build and commiting that is likely the easiest approach.

## Building local apps

Prerequisites:

* [Docker](https://www.docker.com/) installed
* PRoot apps installed as your user

In this repository is a helper script `build-install-local` that can be used to generate a PRoot app from the build logic in this repo. To build and extract the firefox image simply: 

```
./build-install-local firefox
```

Then follow the instructions to install and test it out.

## Basic application structure

We are using Docker to do the heavy lifting here, leveraging it for building and it's registry system for hosting the applications. In the end what makes up a PRoot app is the entire operating system needed for the application to run. There are 4 files required for an application:

* Dockerfile - This contains all of the build logic for the application, installation and customization for the application should be performed here including:
  - Desktop file launching proot-apps instead of the default command from OS install
  - Setting a bin name for the application so it can be launched from the users CLI
  - Modifying the Name of the application in it's desktop entry as to not conflict with the users OS level applications
* entrypoint - This file is executed every time the application is launched it should contain any logic for the application to run properly, this might include custom flags to drop sandboxing requirements as they will not work in PRoot
* install - This file will be called when the user installs the application with proot-apps it should:
  - Add a desktop shortcut if applicable
  - Add a start menu entry if applicable
  - Add an icon for the application if applicable
* remove - This file will be called when the user uninstalls the application with proot-apps it should:
  - Remove a desktop shortcut if applicable
  - Remove a start menu entry if applicable
  - Remove an icon for the application if applicable

It is important to understand that nothing about this platform is security focused PRoot in general is running in userspace and can easily be escaped by the application by simply killing its Tracer PID. The point of this platform is not application isolation it is easing the burden of installation to not require any form of sudo access or unconventional platform binaries. To that end on init PRoot Apps will also start a system socket for sending commands to the underlying host to escape it's jail. This leverages a UNIX socket with ncat to relay commands to the host. This is required to open things like file explorers on the host that would otherwise not be available. PRoot already mounts in the system dbus socket and many applications will leverage this to call external programs in Desktop userspace, for applications that do not use this they will conventionally pass URLs and file paths to `xdg-open`. The `xdg-open` binary in the PRoot jail can be replaced with a simple wrapper: 

```
#!/bin/bash
echo "xdg-open "$@"" | nc -N -U /system.socket
```

This same wrapper concept can be used to wrap any other binary inside the jail that you would want to open up on the host and not inside of the PRoot runspace itself.

One other concept to keep in mind is if you want it to work in the application you will need to install it in the build logic. The only storage space PRoot really has access to at runtime is the user's home directory. If the program needs GPU acceleration, you will need to install the drivers (amdgpu, dri gallium, etc). If the program needs language packs or fonts again you will need to install them. In general this approach is incredibly wasteful when it comes to disk space but without using more complex systems like OverlayFS or bubblewrap (user namespacing) it is necessary.
