#!/bin/bash
#
# This script dithers the intro video from color to black & white.

DITHER=$(dirname $0)/dither.sh

$DITHER -sigma 5 -scale 256 -black 80% -white 0.1% Intro
