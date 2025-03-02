#!/bin/bash
#
# This script converts animation frames to supersprites in an optimized custom
# format. The 4 output files contain names, an index, positions, and patterns.

INPUT_DIR=out/animations/bw
OUTPUT_DIR=out

# Shift the 128x128 pixel supersprites so offset (0,0) puts their bases
# (3D origins), (64,64) in the images, at the base of the player, (128,112)
# on the screen.
INPUT_FRAMES=${1:-
  -shiftx 64
  -shifty 48

  -name target_sprite
  -color 11
  $INPUT_DIR/Target/*.png

  -name stone_sprite
  -color 14
  $INPUT_DIR/Sphere/*.png

  -name bullet_sprite
  -color 11
  -shifty 19
  $INPUT_DIR/Sphere/*.png
  -shifty 48

  -name grenade_sprite
  -color 9
  -shifty 44
  $INPUT_DIR/Sphere/*.png
  -shifty 48

  -name bush_sprite
  -color 12
  $INPUT_DIR/Explosion/06.png

  -name tree_sprite
  -color 9
  -shifty 58
  -append $INPUT_DIR/Trunk/*.png
  -color 12
  -shifty 4
  $INPUT_DIR/Explosion/08.png
  -shifty 48

  -name emp_sprites
  -color 3
  -shifty 16
  $INPUT_DIR/Emp/*.png
  -shifty 48

  -name battery_sprite
  -color 2
  $INPUT_DIR/Battery/*.png

  -name mine_sprites
  -color 9
  $INPUT_DIR/Mine/*.png

  -name launcher_sprites
  -explosioncount 15
  -explosionspeed 2
  -explosiongravity -50
  -color 14
  $INPUT_DIR/Launcher/*.png
  -explosioncount 0

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
  -explosioncount 0

  -name explosion_sprites
  -color 14
  $INPUT_DIR/Explosion/02.png
  $INPUT_DIR/Explosion/04.png
  $INPUT_DIR/Explosion/06.png
  -explosioncount 12
  -explosionspeed 2
  -explosiongravity 0
  $INPUT_DIR/Explosion/08.png
  -explosioncount 0

  -shifty 25

  -name stone_counter_sprites
  -color 14
  $INPUT_DIR/StoneCounters/*.png

  -name charge_sprites
  -color 2
  $INPUT_DIR/Charge/*.png
}
OUTPUT_NAMES=${2:-$OUTPUT_DIR/sprite_names.asm}
OUTPUT_BOUNDS=${3:-$OUTPUT_DIR/sprite_bounds.dat}
OUTPUT_INDEX=${4:-$OUTPUT_DIR/sprite_index.dat}
OUTPUT_POSITIONS=${5:-$OUTPUT_DIR/sprite_positions.dat}
OUTPUT_PATTERNS=$OUTPUT_DIR/${6:-sprite_patterns.dat}

java -cp out CompressSprites \
  $INPUT_FRAMES \
  $OUTPUT_NAMES \
  $OUTPUT_BOUNDS \
  $OUTPUT_INDEX \
  $OUTPUT_POSITIONS \
  $OUTPUT_PATTERNS
