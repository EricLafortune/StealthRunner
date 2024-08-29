#!/bin/bash
#
# This script creates an animation of battery charge bars using ImageMagick
# scripts.

OUTPUT_DIR=out/animations/bw/Charge

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for COUNT in {0..6}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $COUNT)
  echo "Creating $FRAME ..."

  (
    echo -draw "'line 61,57 66,57'"
    echo -draw "'rectangle 58,58 69,72'"
    for BAR in $(seq 1 $COUNT)
    do
      echo -draw "'line 60,$[72-2*BAR] 67,$[72-2*BAR]'"
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
    -fill black \
    -virtual-pixel black
done
