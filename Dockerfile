ARG BASE_IMAGE="ubuntu"
ARG OS_TAG="jammy"
ARG WINE_BRANCH="staging"

FROM ${BASE_IMAGE}:${OS_TAG}

LABEL project="Packhaus"\
      version="1.1.0 wine staging" \
      mantainer="bileyg"\
      company="Ascon"
      
ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64
ENV LANG en_US.UTF-8

# Add i386 architecture
RUN dpkg --add-architecture i386 \
    && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && DEBIAN_FRONTEND="noninteractive"
    
# Add winetricks & scripts
#COPY Fonts /root/.wine/drive_c/windows/Fonts
COPY scripts /pilot/scripts/
COPY winetricks /usr/bin/
RUN chmod +x /usr/bin/winetricks && chmod +x /pilot/scripts/myadmin_setup.sh && chmod +x /pilot/scripts/myadmin_start.sh

# Update and upgrade
RUN apt-get update && apt-get upgrade

# Install prerequisites
RUN apt-get install -qfy --install-recommends \
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
       unzip \
       libcanberra-gtk-module \
       libcanberra-gtk3-module \
       mc
       
# Add WineHQ repository
RUN wget -nv https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ ${OS_TAG} main' \
    # Additional Cybermax-dexter repository for pipe support
    && add-apt-repository ppa:cybermax-dexter/sdl2-backport \
    #Install Wine itself
    && apt-get install -qfy --install-recommends \
        winehq-${WINE_BRANCH} \
        winbind

# Add dotnet & ingridients 
RUN winetricks --force -q dotnet472 \
    d3dcompiler_47 \
    corefonts \
    vcrun2019

# Clearing & prelaunch
RUN apt-get -y clean \
    && rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo \
    && wineboot -u && xvfb-run \
    && locale-gen en_US.UTF-8

