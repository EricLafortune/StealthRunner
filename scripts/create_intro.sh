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
  \( \
    -size 256x192 \
    xc:white \
    -fill white           -draw 'line 0,26 255,26' \
    -fill white           -draw 'line 0,27 255,27' \
    -fill grey80          -draw 'line 0,28 255,28' \
    -fill grey80          -draw 'line 0,29 255,29' \
    -fill turquoise       -draw 'line 0,30 255,30' \
    -fill turquoise       -draw 'line 0,31 255,31' \
    -fill turquoise       -draw 'line 0,32 255,32' \
    -fill LightSlateBlue  -draw 'line 0,33 255,33' \
    -fill RoyalBlue       -draw 'line 0,34 255,34' \
    -fill LightSlateBlue  -draw 'line 0,35 255,35' \
    -fill RoyalBlue       -draw 'line 0,36 255,36' \
    -fill green3          -draw 'line 0,37 255,37' \
    -fill LimeGreen       -draw 'line 0,38 255,38' \
    -fill green3          -draw 'line 0,39 255,39' \
    -fill LimeGreen       -draw 'line 0,40 255,40' \
    -fill LimeGreen       -draw 'line 0,41 255,41' \
    -fill SeaGreen3       -draw 'line 0,42 255,42' \
    -fill LimeGreen       -draw 'line 0,43 255,43' \
    -fill SeaGreen3       -draw 'line 0,44 255,44' \
    -fill LightGoldenrod3 -draw 'line 0,45 255,45' \
  \) \
  -compose multiply \
  -composite \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/title.png

# Draw the subtitles.
convert \
  $ANIMATION_DIR/title.png \
  +antialias \
  -font Arial \
  -pointsize 12 \
  -gravity Center \
  -fill green \
  -draw 'text 0,-35 "Version 1.0"' \
  -draw 'text 0,80 "Copyright © 2024-2025 Eric Lafortune"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/subtitles.png

# Draw the game keys.
convert \
  $ANIMATION_DIR/subtitles.png \
  +antialias \
  -font Arial \
  -pointsize 10 \
  -gravity Center \
  -stroke grey \
  -fill none \
  -strokewidth 15 \
  -draw 'arc 20,80 80,140 220,240' \
  -draw 'line 50,90 50,80' \
  -draw 'arc 20,80 80,140 300,320' \
  -draw 'line 30,110 20,110' \
  -draw 'line 50,115 50,125' \
  -draw 'line 70,110 80,110' \
  -draw 'stroke-linecap round arc 20,80 80,140 220,225' \
  -draw 'stroke-linecap round line 50,84 50,80' \
  -draw 'stroke-linecap round arc 20,80 80,140 315,320' \
  -draw 'stroke-linecap round line 24,110 20,110' \
  -draw 'stroke-linecap round line 50,120 50,124' \
  -draw 'stroke-linecap round line 76,110 80,110' \
  -strokewidth 1 \
  -stroke grey \
  -fill grey \
  -draw 'roundrectangle 13,124 38,139 4,4' \
  -draw 'roundrectangle 13,146 38,161 4,4' \
  -draw 'roundrectangle 43,146 57,161 4,4' \
  -draw 'roundrectangle 62,146 87,161 4,4' \
  -stroke black \
  -fill black \
  -draw 'text -99,-6  "Q"' \
  -draw 'text -77,-13 "W"' \
  -draw 'text -55,-6  "E"' \
  -draw 'text -104,15 "A"' \
  -draw 'text -77,25  "S"' \
  -draw 'text -50,15  "D"' \
  -draw 'text -103,37 "Shift"' \
  -draw 'text -103,59 "Ctrl"' \
  -draw 'text -77,59  "X"' \
  -draw 'text -53,59  "Enter"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/keys.png

# Draw the mouse.
convert \
  $ANIMATION_DIR/keys.png \
  +antialias \
  -font Arial \
  -pointsize 10 \
  -gravity Center \
  -stroke grey \
  -fill grey \
  -draw 'roundrectangle 185,85 235,155 15,40' \
  -stroke black \
  -fill black \
  -draw 'line 185,106 235,106' \
  -draw 'line 210,85  210,106' \
  -draw 'text 73,2  "fire"' \
  -draw 'text 95,2  "swp"' \
  -draw 'text 83,26 "turn"' \
  +dither \
  -remap images/palette.gif \
  $ANIMATION_DIR/mouse.png

mkdir -p $OUTPUT_DIR

# Zip up the animation frames.
rm -f "$OUTPUT_DIR/intro.zip"
zip \
  --quiet \
  --junk-paths \
  $OUTPUT_DIR/intro.zip \
  $ANIMATION_DIR/0??.png

# Create the video.
java ComposeVideo \
  -ntsc \
  $OUTPUT_DIR/intro.zip \
  $OUTPUT_DIR/footsteps.snd \
  100:$ANIMATION_DIR/title.png \
  102:$OUTPUT_DIR/StealthRunner.lpc \
  200:$ANIMATION_DIR/subtitles.png \
  202:$ANIMATION_DIR/keys.png \
  204:$ANIMATION_DIR/mouse.png \
  206:$OUTPUT_DIR/PianoConcerto20_1.snd \
  $OUTPUT_DIR/intro.tms
