#!/bin/bash
#
# This script dithers all player animations from color to black & white.

DITHER=$(dirname $0)/dither.sh

TYPES=${1:-
Die_backward
Crouch_to_stand
Stand
Walk
Run
Walk_backward
Run_backward
Walk_strafe_left
Run_strafe_left
Walk_strafe_right
Run_strafe_right
}

for TYPE in $TYPES
do
  $DITHER -sigma 4 -black 60% -white 0.5% Player/$TYPE
done
