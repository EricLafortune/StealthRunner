#!/bin/bash
#
# This script compresses the animations of the player avatar in a single data
# file in a custom format.

TYPES=${1:-
  -landscapemask false
  -adjacentdirections -1,0,1
  -adjacenttypes 0,1,2,3,4,5,6,7,8,9
  Die_backward

  -landscapemask true
  -adjacentdirections -1,0,1
  -adjacenttypes 0,1,3,5,7
  Stand

  -landscapemask true
  -adjacenttypes -1,0,1,4,6
  Walk
  -landscapemask false
  -adjacenttypes -1,0,4,6
  Run

  -landscapemask true
  -adjacenttypes -2,0,1
  Walk_backward
  -landscapemask false
  -adjacenttypes -1,0
  Run_backward

  -landscapemask false
  -adjacenttypes -5,0,1,-4
  Walk_strafe_left
  -landscapemask false
  -adjacenttypes -1,0,-4
  Run_strafe_left

  -landscapemask false
  -adjacenttypes -7,0,1,-6
  Walk_strafe_right
  -landscapemask false
  -adjacenttypes -1,0,-6
  Run_strafe_right

}

java -cp out CompressPlayer \
  -inputdirectory out/animations/bw/Player \
  -charoffset 8 \
  -outputmaskfile out/player_mask.png \
  $TYPES \
  out/player.dat
