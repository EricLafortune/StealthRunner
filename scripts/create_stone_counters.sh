#!/bin/bash
#
# This script creates an animation of stone counters using ImageMagick
# scripts.

OUTPUT_DIR=out/animations/bw/StoneCounters

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for COUNT in {1..6}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $COUNT)
  echo "Creating $FRAME ..."

  (
    for BAR in $(seq 1 2 $COUNT)
    do
      echo -draw "'circle 60,$[72-4*BAR] 63,$[72-4*BAR]'"
    done
    for BAR in $(seq 2 2 $COUNT)
    do
      echo -draw "'circle 67,$[72-4*BAR] 70,$[72-4*BAR]'"
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
