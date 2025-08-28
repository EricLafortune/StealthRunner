#!/bin/bash
#
# This script creates an image of an empty level with a legend, suitable for
# editing in an image editor.
#
# The available colors are listed at
#   https://imagemagick.org/script/color.php#color_names

COLORS=(\
000000
000000
21c842
5edc78
5455ed
7d76fc
d4524d
42ebf5
fc5554
ff7978
d4c154
e6ce80
21b03b
c95bba
cccccc
ffffff
)

function color {
  DELTA=${2:-0}
  printf '%06x' $[0x${COLORS[$1]}+0x$DELTA & 0xffffff]
}

LEGEND_OPTIONS=()
Y=10

function legend {
  if [[ "$1" == 000000 ]]
  then
    LEGEND_OPTIONS+=(-stroke white)
  fi
  LEGEND_OPTIONS+=(-fill \#$1)
  LEGEND_OPTIONS+=(-draw "rectangle 10,$Y 20,$[Y+10]")
  if [[ "$1" == 000000 ]]
  then
    LEGEND_OPTIONS+=(-stroke none)
  fi
  LEGEND_OPTIONS+=(-fill white)
  LEGEND_OPTIONS+=(-draw "text 25,$[Y+10] \"$2\"")
  Y=$[Y+20]
}

legend $(color  0)   Open
legend $(color  3)   Landscape

Y=$[Y+10]

legend $(color  2 fefeff) Grass
legend $(color 12 fefeff) Bush
legend $(color  9 fefeff) Tree
legend $(color 14 fefeff) Rock
legend $(color  7 fefeff) Puddle
legend $(color  6 fefeff) Wood
legend $(color 10 fefeff) Fence
legend $(color  6 fef0ff) Tripod
legend $(color 13 fefeff) Barrel
legend $(color  9 fef0ff) Bricks
legend $(color  8 fefeff) Manhole
legend $(color  4 fefeff) Pylon

Y=$[Y+10]

legend $(color  4) Player
legend $(color  5) Message
legend $(color 11) Target

Y=$[Y+10]

legend $(color 12) Medkit
legend $(color  6) Stone
legend $(color  2) Battery
legend $(color 14) Grenade

Y=$[Y+10]

legend $(color  8) Mine
legend $(color  7) Drone
legend $(color  9) Launcher
legend $(color 15) Turret

convert \
  +antialias \
  -size 100x550 \
  xc:black \
  -font Arial \
  -pointsize 12 \
  -stroke none \
\
  -fill \#$(color 0) \
  -draw 'rectangle 0,0 100,600' \
\
  "${LEGEND_OPTIONS[@]}" \
\
  levels/legend.png
