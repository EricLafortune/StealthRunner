#!/bin/bash
#
# This script builds the entire project.
#
# We're packaging the output as an RPK for Mame (out/StealthRunner.rpk),
# using the ROM naming convention for FinalGROM 99.

if ! type -t convert > /dev/null; then
  echo 'You still need to install ImageMagick:'
  echo '  sudo apt install imagemagick'
  EXIT=1
fi

if ! type -t ffmpeg > /dev/null; then
  echo 'You still need to install ffmpeg:'
  echo '  sudo apt install ffmpeg'
  EXIT=1
fi

if ! type -t xxd > /dev/null; then
  echo 'You still need to install ffmpeg:'
  echo '  sudo apt install xxd'
  EXIT=1
fi

if ! type -t java > /dev/null; then
  echo 'You still need to install java:'
  echo '  sudo apt install openjdk-17-jdk'
  EXIT=1
fi

if [[ ! -f videotools.jar ]]; then
  echo 'You still need to download the video tools jar:'
  echo '  https://github.com/EricLafortune/VideoTools/releases/latest'
  echo 'as videotools.jar'
  EXIT=1
fi

if ! type -t python3 > /dev/null; then
  echo 'You still need to install python3:'
  echo '  sudo apt install python3'
  EXIT=1
fi

if ! type -t xas99.py > /dev/null; then
  echo 'You still need to set up xdt99:'
  echo '  https://github.com/endlos99/xdt99'
  EXIT=1
fi

if [[ -v EXIT ]]; then
  exit 1
fi

export CLASSPATH=videotools.jar:out

scripts/compile_tools.sh

scripts/render_intro.sh
scripts/render_objects.sh
scripts/render_player.sh

scripts/dither_intro.sh
scripts/dither_objects.sh
scripts/dither_player.sh

scripts/convert_sound.sh
scripts/convert_speech.sh

scripts/create_intro.sh
scripts/create_emp.sh
scripts/create_charge.sh

scripts/compress_sprites.sh
scripts/compress_player.sh
scripts/compress_levels.sh

scripts/assemble.sh
