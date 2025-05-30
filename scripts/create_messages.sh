#!/bin/bash
#
# This script creates images of messages with directions and tips.

OUTPUT_DIR=out/animations/bw/Messages

mkdir -p $OUTPUT_DIR

COUNTER=0

# The messages are listed below. Note:
# - An underscore for a newline.
# - An extra space at the start of a line to balance a period at the end.

while read MESSAGE; do
  OUTPUT_FILE=$OUTPUT_DIR/$(printf '%02d' $COUNTER).png

  convert \
    -size 64x32 \
    -depth 1 \
    -monochrome \
    -background black \
    +antialias \
    -font Arial \
    -pointsize 9 \
    -gravity Center \
    -interline-spacing -2 \
    -fill white \
    label:"${MESSAGE//_/\\n}" \
    $OUTPUT_FILE

    COUNTER=$[COUNTER+1]
done <<EOF
Collect_ grenades.
Press X to_ swap weapons.
Collect EMP_ batteries.
Distract_the drone_ with stones.
Press Enter_to throw_ a stone.
Collect_ stones.
Walk quietly_to avoid_ attention.
Run to escape_ the drone.
Press Shift_ to speed up.
Press 7_ to restart_ here.
Go to the_ save point.
Press Ctrl_ to heal.
Collect_ medkits.
Move with_Q W E_ A  S  D
EOF
