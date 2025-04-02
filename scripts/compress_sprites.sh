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

  -minpixelcount 10

  -name grass_sprite
  -color 2
  $INPUT_DIR/Grass/00.png

  -name bush_sprite
  -color 12
  $INPUT_DIR/Explosion/06.png

  -name tree_sprite
  -color 6
  -shifty 58
  -append $INPUT_DIR/Trunk/*.png
  -color 3
  -shifty 4
  $INPUT_DIR/Explosion/08.png
  -shifty 48

  -name rock_sprite
  -color 14
  $INPUT_DIR/Rock/00.png

  -name puddle_sprite
  -color 7
  $INPUT_DIR/Puddle/00.png

  -name wood_sprite
  -color 6
  $INPUT_DIR/Wood/00.png

  -name fence_sprite
  -color 10
  $INPUT_DIR/Fence/00.png

  -name tripod_sprite
  -color 6
  $INPUT_DIR/Tripod/00.png

  -name barrel_sprite
  -color 13
  $INPUT_DIR/Barrel/00.png

  -name bricks_sprite
  -color 9
  $INPUT_DIR/Bricks/00.png

  -name manhole_sprite
  -color 8
  $INPUT_DIR/Manhole/00.png

  -name pylon_sprite
  -color 11
  $INPUT_DIR/Pylon/00.png

  -name target_sprite
  -color 11
  $INPUT_DIR/Target/*.png

  -minpixelcount 5

  -name collectible_sprites
  -name stone_sprite
  -color 6
  $INPUT_DIR/StoneCounters/01.png

  -name battery_sprite
  -color 2
  $INPUT_DIR/Battery/*.png

  -name grenade_sprite
  -color 14
  $INPUT_DIR/GrenadeCounters/01.png

  -name collectible_counter_sprites
  -shifty 25
  -name stone_counter_sprites
  -color 6
  $INPUT_DIR/StoneCounters/*.png

  -name charge_sprites
  -color 2
  $INPUT_DIR/ChargeCounters/*.png
  $INPUT_DIR/ChargeCounters/06.png

  -name grenade_counter_sprites
  -color 14
  $INPUT_DIR/StoneCounters/00.png
  $INPUT_DIR/GrenadeCounters/0[1-7].png
  -shifty 48

  -name emp_sprites
  -color 3
  -shifty 16
  $INPUT_DIR/Emp/*.png
  -shifty 48

  -name mine_sprites
  -color 9
  $INPUT_DIR/Mine/*.png

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

  -name launcher_sprites
  -explosioncount 15
  -explosionspeed 2
  -explosiongravity -50
  -color 14
  $INPUT_DIR/Launcher/*.png
  -explosioncount 0

  -name shell_sprite
  -color 9
  -shiftx 67
  -shifty 44
  $INPUT_DIR/Shell/00.png
  -shiftx 64
  -shifty 48

  -name bullet_sprite
  -color 11
  -shiftx 67
  -shifty 44
  $INPUT_DIR/StoneCounters/01.png
  -shiftx 64
  -shifty 48

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
