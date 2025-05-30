#!/bin/bash
#
# This script compresses the image file of a level to custom data files with
# the landscape graphics and the landscape collision mask, and the objects in
# the level.

LEVEL=${1:-00}

INPUT=levels/$LEVEL.png
OUTPUT_DIR=out/levels
OUTPUT_PREFIX=$OUTPUT_DIR/$LEVEL

mkdir -p $OUTPUT_DIR

java -cp out CompressLandscape \
  -baseaddress $[0x6000] \
  $INPUT \
  ${OUTPUT_PREFIX}_landscape.dat

java -cp out CompressLandscapeMask \
  -shiftx 8 \
  -shifty 6 \
  $INPUT \
  out/player_mask.png \
  ${OUTPUT_PREFIX}_mask.dat

java -cp out CompressLandscapeObjects \
  -shiftx 0 \
  -shifty 0 \
  $INPUT \
  ${OUTPUT_PREFIX}_objects.dat
