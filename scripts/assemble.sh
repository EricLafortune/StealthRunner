#!/bin/bash
#
# This script assembles the source code and creates an RPK cartridge image with
# the resulting binary.
#
# We're packaging the output as an RPK for Mame,
# using the ROM naming convention for FinalGROM 99.
#
# Useful xas99 option for debugging:
#   --listing-file out/romc.lst --symbol-table

INPUT=src/game.asm
OUTPUT_DIR=out
OUTPUT_ROM=$OUTPUT_DIR/romc.bin
OUTPUT_RPK=$OUTPUT_DIR/StealthRunner.rpk

mkdir -p $OUTPUT_DIR \
&& xas99.py \
     --register-symbols \
     --binary \
     --output $OUTPUT_ROM \
     $INPUT \
&& rm -f "$OUTPUT_RPK" \
&& zip \
     --quiet \
     --junk-paths \
     $OUTPUT_RPK \
     layout.xml $OUTPUT_ROM
