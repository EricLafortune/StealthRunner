#!/bin/bash
#
# This script converts animation frames to supersprites in an optimized custom
# format. The 4 output files contain names, an index, positions, and patterns.

INPUT_DIR=out/animations/bw
OUTPUT_DIR=out

# Shift the supersprites so they are centered on the screen (together with
# the player graphics) when they are drawn at (0,0).
INPUT_FRAMES=${1:-
  -shiftx 64
  -shifty 24

  -name target_sprite
  -color 11
  $INPUT_DIR/Target/*.png

  -name bush_sprite
  -color 9
  -append $INPUT_DIR/Base/*.png
  -color 12
  -shifty 0
  $INPUT_DIR/Explosion/06.png
  -shifty 24

  -name emp_sprites
  -color 3
  $INPUT_DIR/Emp/*.png

  -name battery_sprite
  -color 2
  $INPUT_DIR/Battery/*.png

  -name mine_sprites
  -color 9
  $INPUT_DIR/Mine/*.png
  -color 15

  -name drone_sprites
  -explosioncount 15
  -explosionspeed 2
  -explosiongravity 50
  -color 7
  $INPUT_DIR/Drone/*.png
  -explosioncount 0

  -name turret_sprites
  -explosioncount 15
  -explosionspeed 2
  -explosiongravity 50
  -color 14
  -append $INPUT_DIR/Base/*.png
  $INPUT_DIR/Cannon/*.png

  -name bullet_sprites
  -explosioncount 0
  -color 11
  $INPUT_DIR/Bullets/*.png

  -name explosion_sprite
  -color 14
  $INPUT_DIR/Explosion/02.png
  $INPUT_DIR/Explosion/04.png
  $INPUT_DIR/Explosion/06.png
  -explosioncount 12
  -explosionspeed 2
  -explosiongravity 0
  $INPUT_DIR/Explosion/08.png
  -explosioncount 0

  -name charge_sprites
  -color 2
  $INPUT_DIR/Charge/*.png
}
OUTPUT_NAMES=${2:-$OUTPUT_DIR/sprite_names.asm}
OUTPUT_INDEX=${3:-$OUTPUT_DIR/sprite_index.dat}
OUTPUT_POSITIONS=${4:-$OUTPUT_DIR/sprite_positions.dat}
OUTPUT_PATTERNS=$OUTPUT_DIR/${5:-sprite_patterns.dat}

java -cp out CompressSprites \
  $INPUT_FRAMES \
  $OUTPUT_NAMES \
  $OUTPUT_INDEX \
  $OUTPUT_POSITIONS \
  $OUTPUT_PATTERNS
