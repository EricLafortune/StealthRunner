#!/bin/bash
#
# This script creates an animation of an electromagnetic pulse (EMP) using
# ImageMagick scripts.

OUTPUT_DIR=${1:-out/animations/bw/Emp}

EMP_PY=${0%.sh}.py

mkdir -p $OUTPUT_DIR

rm -f "$OUTPUT_DIR"/??.png

for ANGLE in {0..15}
do
  FRAME=$(printf "$OUTPUT_DIR/%02.0f.png" $ANGLE)
  echo "Creating $FRAME ..."

  convert \
    -size 128x128 \
    -monochrome \
    xc:black \
    -fill white \
    -virtual-pixel black \
    -draw "$($EMP_PY $ANGLE 16 5 32 20)" \
    +dither \
    -monochrome \
    $FRAME
done
