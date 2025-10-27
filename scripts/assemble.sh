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

# We'll make sure the ROM size is padded to 2MB.
ROM_SIZE=$[2*1024*1024]
BANK_SIZE=$[8*1024]

INPUT=src/game.asm
OUTPUT_DIR=out
OUTPUT_ROM=$OUTPUT_DIR/romc.bin
OUTPUT_RPK=$OUTPUT_DIR/StealthRunner.rpk
HEADER=$OUTPUT_DIR/header.bin

# Assemble the code.
mkdir -p $OUTPUT_DIR
xas99.py \
  $INPUT \
  --register-symbols \
  --binary \
  --output $OUTPUT_ROM \
  "$@" \
|| exit 1

# Pad the ROM with copies of the first memory bank.
SIZE=$(stat -c '%s' $OUTPUT_ROM)
if [ $[SIZE%BANK_SIZE] -ne 0 ]
then
  echo "Compiled ROM size ($SIZE) is not a multiple of 8K"
  exit 1
fi

head -c $BANK_SIZE $OUTPUT_ROM > $HEADER
seq $SIZE $BANK_SIZE $[ROM_SIZE-1] \
| while read N
do
  cat $HEADER >> $OUTPUT_ROM
done

# Package the ROM in an RPK file.
rm -f "$OUTPUT_RPK"
zip \
  --quiet \
  --junk-paths \
  $OUTPUT_RPK \
  layout.xml $OUTPUT_ROM
