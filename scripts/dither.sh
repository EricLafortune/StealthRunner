#!/bin/bash
#
# This script converts color images to dithered black & white images.
#
# For example:
#   dither.sh -sigma 4 -black 97% -white 0.1% Images

INPUT_DIR=out/animations/color

# Parse the options.
while [[ $1 == -* ]]
do
  case $1 in
    # Unsharp options to increase the local contrast.
    -radius)    RADIUS=$2;    shift 2;;
    -sigma)     SIGMA=$2;     shift 2;;
    -gain)      GAIN=$2;      shift 2;;
    -threshold) THRESHOLD=$2; shift 2;;
    # IMage scaling options.
    -scale)     SCALE=$2;     shift 2;;
    # Contrast stretch options for the final contrast.
    -black)     BLACK=$2;     shift 2;;
    -white)     WHITE=$2;     shift 2;;
    *)          echo "Unknnown option $1"; exit 1;;
   esac
done

if [[ -v RADIUS || -v SIGMA || -v GAIN || -v THRESHOLD ]]; then
  UNSHARP_OPTIONS="-unsharp ${RADIUS:-0}x${SIGMA:-1.0}+${GAIN:-1.0}+${THRESHOLD:-0.05}"
else
  UNSHARP_OPTIONS=
fi

SCALE_OPTIONS="-scale ${SCALE:-128}"

if [[ -v BLACK || -v WHITE ]]
then
  CONTRAST_OPTIONS="-contrast-stretch ${BLACK:-97%}x${WHITE:-1%}"
else
  CONTRAST_OPTIONS='-contrast'
fi

ANIMATION=${1:-Run}

ANIMATION_DIR="$INPUT_DIR/$ANIMATION"

find "$ANIMATION_DIR" -name \*.png \
| while read INPUT_IMAGE
do
  OUTPUT_IMAGE=${INPUT_IMAGE/color/bw}

  mkdir -p $(dirname "$OUTPUT_IMAGE")

  convert \
    "$INPUT_IMAGE" \
    $UNSHARP_OPTIONS \
    $SCALE_OPTIONS \
    $CONTRAST_OPTIONS \
    -monochrome \
    "$OUTPUT_IMAGE"

done
