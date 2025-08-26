#!/bin/bash
#
# This script assembles the source code and creates an RPK cartridge image with
# the resulting binary.
#
# We're packaging the output as an RPK for Mame,
# using the ROM naming convention for FinalGROM 99.
#
# Useful xas99 options for debugging:
#   --listing-file out/romc.lst --symbol-table
# Also:
#   -D pan immortal initial_medkits=50 initial_stones=50 initial_emps=50 initial_grenades=50

INPUT=src/game.asm
OUTPUT_DIR=out
OUTPUT_ROM=$OUTPUT_DIR/romc.bin
OUTPUT_RPK=$OUTPUT_DIR/StealthRunner.rpk

mkdir -p $OUTPUT_DIR \
&& xas99.py \
     $INPUT \
     --register-symbols \
     --binary \
     --output $OUTPUT_ROM \
     "$@" \
&& rm -f "$OUTPUT_RPK" \
&& zip \
     --quiet \
     --junk-paths \
     $OUTPUT_RPK \
     layout.xml $OUTPUT_ROM
