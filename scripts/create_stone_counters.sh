#!/bin/bash
#
# This script creates a series of stone counter HUDs using ImageMagick
# scripts.

OUTPUT_DIR=out/animations/bw/StoneCounters

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for COUNT in {0..6}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $COUNT)
  echo "Creating $FRAME ..."

  (
    # Case statement with partial fall-through.
    case $COUNT in
    0) echo -draw "'line 60,67 67,60'"
       echo -draw "'line 60,60 67,67'"
       ;;
    6) echo -draw "'rectangle 67,57 68,58'" ;&
    5) echo -draw "'rectangle 59,57 60,58'" ;&
    4) echo -draw "'rectangle 67,61 68,62'" ;&
    3) echo -draw "'rectangle 59,61 60,62'" ;&
    2) echo -draw "'rectangle 63,59 64,60'" ;&
    1) echo -draw "'rectangle 63,63 64,64'" ;;
    esac
    # ImageMagick 6.9.11-60 needs an additional threshold to avoid artifacts
    # in 02.png.
    echo +dither -threshold  50% -monochrome
    echo $FRAME
  ) \
  | xargs -n 99 convert \
    -size 128x128 \
    -depth 1 \
    -monochrome \
    xc:black \
    -stroke white \
    -fill white \
    -virtual-pixel black
done
