#!/bin/bash
#
# This script adds titles to the Blender intro shot using ImageMagick, and
# composes the resulting video using our own VideoTools.

OUTPUT_DIR=out
ANIMATION_DIR=out/animations/bw/Intro

# Draw the main title.
convert \
  $ANIMATION_DIR/037.png \
  +antialias \
  -font Impact \
  -pointsize 25 \
  -kerning 5 \
  -gravity Center \
  -fill white \
  -draw 'text 0,-60 "Stealth Runner"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/038.png

# Draw the subtitles.
convert \
  $ANIMATION_DIR/038.png \
  +antialias \
  -font Arial \
  -pointsize 12 \
  -gravity Center \
  -fill green \
  -draw 'text 0,-35 "Version 0.1"' \
  -draw 'text 0,80 "Copyright © 2024 Eric Lafortune"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/039.png

# Draw the game keys.
convert \
  $ANIMATION_DIR/039.png \
  +antialias \
  -font Arial \
  -pointsize 10 \
  -gravity Center \
  -stroke grey \
  -fill none \
  -strokewidth 15 \
  -draw 'arc 20,90 80,150 220,240' \
  -draw 'line 50,100 50,90' \
  -draw 'arc 20,90 80,150 300,320' \
  -draw 'line 30,120 20,120' \
  -draw 'line 50,125 50,135' \
  -draw 'line 70,120 80,120' \
  -draw 'stroke-linecap round arc 20,90 80,150 220,225' \
  -draw 'stroke-linecap round line 50,94 50,90' \
  -draw 'stroke-linecap round arc 20,90 80,150 315,320' \
  -draw 'stroke-linecap round line 24,120 20,120' \
  -draw 'stroke-linecap round line 50,131 50,135' \
  -draw 'stroke-linecap round line 76,120 80,120' \
  -strokewidth 1 \
  -stroke grey \
  -fill grey \
  -draw 'roundrectangle 13,140 38,155 4,4' \
  -draw 'roundrectangle 62,140 87,155 4,4' \
  -stroke black \
  -fill black \
  -draw 'text -99,4   "Q"' \
  -draw 'text -77,-3  "W"' \
  -draw 'text -55,4   "E"' \
  -draw 'text -104,24 "A"' \
  -draw 'text -77,36  "S"' \
  -draw 'text -50,24  "D"' \
  -draw 'text -103,52 "Shift"' \
  -draw 'text -53,52  "Enter"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/040.png

# Draw the mouse.
convert \
  $ANIMATION_DIR/040.png \
  +antialias \
  -font Arial \
  -pointsize 10 \
  -gravity Center \
  -stroke grey \
  -fill grey \
  -draw 'roundrectangle 190,90 230,150 15,30' \
  -stroke black \
  -fill black \
  -draw 'line 190,106 230,106' \
  -draw 'text 83,2  "fire"' \
  -draw 'text 83,26 "turn"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/041.png

mkdir -p $OUTPUT_DIR

# Zip up the animation frames.
rm -f "$OUTPUT_DIR/intro.zip"
zip \
  --quiet \
  --junk-paths \
  $OUTPUT_DIR/intro.zip \
  $ANIMATION_DIR/*.png

# Create the video.
java ComposeVideo \
  -ntsc \
  $OUTPUT_DIR/intro.zip \
  $OUTPUT_DIR/footsteps.snd \
  $OUTPUT_DIR/hum.lpc \
  $OUTPUT_DIR/intro.tms
