#!/bin/bash
#
# This script converts sounds from a readable hexadecimal format to our custom
# SND format.

INPUT_DIR=${1:-sounds}
OUTPUT_DIR=${2:-out}

mkdir -p $OUTPUT_DIR

for INPUT in $INPUT_DIR/*.txt
do
  OUTPUT=$OUTPUT_DIR/$(basename $INPUT .txt).snd
  xxd -r -p \
    $INPUT \
    $OUTPUT
done
