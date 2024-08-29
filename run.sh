#!/bin/bash
#
# This script launches Mame with the TI-99/4A, peripherals, and game cartridge
# mounted.

RPK=out/StealthRunner.rpk

if [ ! -f $RPK ]
then
  echo "Can't find the cartridge image $RPK"
  echo "Please build it with the build.sh script or download it from"
  echo "  https://github.com/EricLafortune/StealthRunner/releases/latest"
  exit 1
fi

mame ti99_4a \
  -nomouse \
  -window \
  -resolution 1024x768 \
  -nounevenstretch \
  -ui_active \
  -ioport peb \
  -ioport:peb:slot2 32kmem \
  -ioport:peb:slot3 speech \
  -joyport mecmouse \
  -cart1 $RPK
