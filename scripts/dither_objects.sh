#!/bin/bash
#
# This script dithers all object supersprites from color to black & white.

DITHER=$(dirname $0)/dither.sh

$DITHER -sigma 2 Target
$DITHER -sigma 2 Battery
$DITHER -sigma 3 Mine
$DITHER -sigma 2 -black 96% -white 0.4% Drone
$DITHER -sigma 3 -black 96% -white 0.5% Cannon
$DITHER -sigma 4 -black 98% -white 0.7% Base
$DITHER -sigma 4 -black 98.5% -white 0.1% Bullets
$DITHER -sigma 4 -black 97% -white 1% Explosion
