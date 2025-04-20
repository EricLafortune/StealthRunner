#!/bin/bash
#
# This script dithers all object supersprites from color to black & white.

DITHER=$(dirname $0)/dither.sh

$DITHER -sigma 1 -black 98%   -white 0.1%  Grass
$DITHER -sigma 2 -black 98%   -white 0.1%  Trunk
$DITHER -sigma 3 -black 99.1% -white 0.02% Stump
$DITHER -sigma 1 -black 98%   -white 0.1%  Rock
$DITHER -sigma 1 -black 94%   -white 2.0%  Puddle
$DITHER -sigma 2 -black 96%   -white 0.5%  Wood
$DITHER -sigma 2 -black 98.5% -white 0.1%  Fence
$DITHER -sigma 1 -black 99%   -white 0.1%  Tripod
$DITHER -sigma 3 -black 96%   -white 0.4%  Barrel
$DITHER -sigma 1 -black 95%   -white 0.2%  Manhole
$DITHER -sigma 1 -black 96.5% -white 0.2%  Bricks
$DITHER -sigma 2 -black 97%   -white 0.4%  Pylon
$DITHER -sigma 2                           Target
$DITHER -sigma 2                           Battery
$DITHER -sigma 3                           Mine
$DITHER -sigma 2 -black 96%   -white 0.4%  Drone
$DITHER -sigma 3 -black 96%   -white 0.5%  Cannon
$DITHER -sigma 3 -black 99%   -white 0.6%  Base
$DITHER -sigma 3 -black 97%   -white 0.2%  Launcher
$DITHER -sigma 2                           Shell
$DITHER -sigma 4 -black 97%   -white 1%    Explosion
$DITHER -sigma 4 -black 50%   -white 2%    Player/01.png
