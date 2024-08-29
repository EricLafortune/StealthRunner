#!/bin/bash
#
# This script dithers all player animations from color to black & white.

DITHER=$(dirname $0)/dither.sh

$DITHER -sigma 4 -black 60% -white 0.5% Player/Run_backward
$DITHER -sigma 4 -black 60% -white 0.5% Player/Walk_backward
$DITHER -sigma 4 -black 60% -white 0.5% Player/Stand
$DITHER -sigma 4 -black 60% -white 0.5% Player/Walk
$DITHER -sigma 4 -black 60% -white 0.5% Player/Run
$DITHER -sigma 4 -black 60% -white 0.5% Player/Run_strafe_left
$DITHER -sigma 4 -black 60% -white 0.5% Player/Walk_strafe_left
$DITHER -sigma 4 -black 60% -white 0.5% Player/Walk_strafe_right
$DITHER -sigma 4 -black 60% -white 0.5% Player/Run_strafe_right
$DITHER -sigma 4 -black 60% -white 0.5% Player/Die_backward
