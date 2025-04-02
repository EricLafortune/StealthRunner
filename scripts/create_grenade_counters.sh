#!/bin/bash
#
# This script creates a series of grenade counter HUDs using ImageMagick
# scripts.

OUTPUT_DIR=out/animations/bw/GrenadeCounters

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for COUNT in {0..7}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $COUNT)
  echo "Creating $FRAME ..."

  (
    if [[ $COUNT == 0 ]]
    then
      echo -draw "'line 60,67 67,60'"
      echo -draw "'line 60,60 67,67'"
    fi
    for I in $(seq $[COUNT-1] -1 0)
    do
      COL=$[2-(I+2)%3*2%3]
      ROW=$[I/3*2 + (I%3==0 ? 0 : 1)]
      X=$[58+COL*5]
      Y=$[63-ROW*2]
echo $I ": " $COL $ROW $X $Y > /dev/tty
      echo -stroke black
      echo -draw "'ellipse $X,$Y.5 3,4.4 0,360'"
      echo -draw "'line    $X,$[Y-4] $[X-3],$[Y-4]'"
      echo -draw "'line    $X,$[Y-3] $[X-3],$[Y-3]'"
      echo -stroke white
      echo -draw "'line    $X,$[Y-3] $[X-2],$[Y-3]'"
    done
    echo +dither -threshold 50% -monochrome
    echo $FRAME
  ) \
  | xargs -n 99 convert \
    -size 128x128 \
    -depth 1 \
    -monochrome \
    xc:black \
    -fill white \
    -virtual-pixel black
done
