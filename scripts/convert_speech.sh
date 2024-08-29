#!/bin/bash
#
# This script converts speech from our custom text LPC format to our binary
# LPC format.

INPUT_DIR=${1:-speech}
OUTPUT_DIR=${2:-out}

mkdir -p $OUTPUT_DIR

for INPUT in $INPUT_DIR/*.txt
do
  OUTPUT=$OUTPUT_DIR/$(basename $INPUT .txt).lpc
  java ConvertTextToLpc \
    $INPUT \
    $OUTPUT
done
