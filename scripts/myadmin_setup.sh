#!/bin/bash
mkdir /pilot/installers
cd /pilot/installers
wget --no-check-certificate https://pilot.ascon.ru/beta/Pilot-myAdmin-setup.zip
unzip Pilot-myAdmin-setup.zip
LIBGL_ALWAYS_SOFTWARE=1 wine /pilot/installers/Pilot-myAdmin-setup.exe
