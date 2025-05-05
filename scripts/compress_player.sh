#!/bin/bash
#
# This script compresses the animations of the player avatar in a single data
# file in a custom format.

TYPES=${1:-
  -landscapemask false
  -fromdirections -1,0,1
  -fromtypes 0,2,3,4,5,6,7,8,9,10
  Die_backward

  -fromdirections 0
  -fromtypes -1
  Crouch_to_stand

  -landscapemask true
  -fromdirections -1,0,1
  -fromtypes -1,0,1,3,5,7
  Stand

  -landscapemask true
  -fromtypes -1,0,1,4,6
  Walk
  -landscapemask false
  -fromtypes -1,0,4,6
  Run

  -landscapemask true
  -fromtypes -2,0,1
  Walk_backward
  -landscapemask false
  -fromtypes -1,0
  Run_backward

  -landscapemask false
  -fromtypes -5,0,1,-4
  Walk_strafe_left
  -landscapemask false
  -fromtypes -1,0,-4
  Run_strafe_left

  -landscapemask false
  -fromtypes -7,0,1,-6
  Walk_strafe_right
  -landscapemask false
  -fromtypes -1,0,-6
  Run_strafe_right

}

java -cp out CompressPlayer \
  -inputdirectory out/animations/bw/Player \
  -charoffset 8 \
  -outputmaskfile out/player_mask.png \
  $TYPES \
  out/player.dat
