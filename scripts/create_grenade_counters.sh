#!/bin/bash
#
# This script creates a series of grenade counter HUDs using ImageMagick
# scripts.

OUTPUT_DIR=out/animations/bw/GrenadeCounters

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for COUNT in {0..6}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $COUNT)
  echo "Creating $FRAME ..."

  (
    if [[ $COUNT == 0 ]]
    then
      echo -draw "'line 60,67 67,60'"
      echo -draw "'line 60,60 67,67'"
    fi
    for ROW in $(seq 1 2 $COUNT)
    do
      echo -draw "'ellipse 60,$[72-4*ROW].5 2,2.5 0,360'"
      echo -draw "'line    60,$[69-4*ROW] 57,$[69-4*ROW]'"
    done
    for ROW in $(seq 2 2 $COUNT)
    do
      echo -draw "'ellipse 67,$[72-4*ROW].5 2,2.5 0,360'"
      echo -draw "'line    67,$[69-4*ROW] 64,$[69-4*ROW]'"
    done
    echo +dither -monochrome
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
