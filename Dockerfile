ARG BASE_IMAGE="ubuntu"
ARG TAG="latest"
ARG WINE_BRANCH="staging"

ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64
ENV LANG en_US.UTF-8

FROM ${BASE_IMAGE}:${TAG}

LABEL project="Packhaus"\
      version="1.0 wine 8.5.0" \
      mantainer="bileyg"\
      company="Ascon"

# Add i386 architecture
RUN dpkg --add-architecture i386 \
    && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && DEBIAN_FRONTEND="noninteractive"
    && locale-gen en_US.UTF-8
    
# Add wine repository & winetricks    
COPY keys /usr/share/keyrings/
COPY source /etc/apt/sources.list.d/
COPY winetricks /usr/bin/
RUN chmod +x /usr/bin/winetricks
RUN add-apt-repository ppa:cybermax-dexter/sdl2-backport

# Install prerequisites
RUN apt-get update \
    && apt-get install -qfy --install-recommends \
       software-properties-common \
       apt-transport-https \
       ca-certificates \
       cabextract \
       dbus-x11 \
       gnupg2 \
       gpg-agent \
       locales \
       tzdata \
       wget \
       x11-xserver-utils \
       xvfb \
       zenity \
       winehq-${WINE_BRANCH} \
       winbind

# Add dotnet & ingridients 
RUN winetricks --force -q dotnet472 \
    d3dcompiler_47 \
    corefonts \
    vcrun2015

# Clearing & prelaunch
RUN apt-get -y clean \
    && rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo \
    && wineboot -u && xvfb-run

# Set some fonts
COPY Fonts /root/.wine/drive_c/windows/Fonts
