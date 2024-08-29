* Game with motion-captured animation for the TI-99/4A home computer.
*
* Copyright (c) 2024 Eric Lafortune
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation; either version 2 of the License, or (at your option)
* any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

* Definitions and macros for the game graphics.

* Locations of the various graphics tables in VDP memory.
game_pattern_descriptor_table  equ >0000 ; Size >0800.
game_screen_image_table        equ >1000 ; Size >0300.
game_color_table               equ >1380 ; Size >0020.
game_sprite_descriptor_table   equ >0800 ; Size >0800.
game_sprite_attribute_table    equ >1300 ; Size >0080.


* One-time macro: initialize the VDP registers and memory for the game.
* LOCAL r0
* LOCAL r1
* LOCAL r2
    .defm initialize_game_graphics

* Set up the VDP registers.
    .vdpwa_in_register r14     ; Cache the vdpwa address.
    .vdpwd_in_register r15     ; Cache the vdpwd address.

    .vdpwr_mode                     0
    .vdpwr_flags                    vdp16k | display_enable | interrupt_enable | double_sprites
    .vdpwr_screen_image_table       game_screen_image_table
    .vdpwr_color_table              game_color_table
    .vdpwr_pattern_descriptor_table game_pattern_descriptor_table
    .vdpwr_sprite_attribute_table   game_sprite_attribute_table
    .vdpwr_sprite_descriptor_table  game_sprite_descriptor_table
    .vdpwr_background_color         black

* Initialize the screen image table.
    .vdpwa game_screen_image_table | vdp_write_bit

    clr  r0
    li   r1, >0300
    clr  r2
screen_loop
    .vdpwd r2
    dec  r1
    jne  screen_loop

* Initialize the pattern descriptor table.
    .blit_fixed_bytes landscape_patterns_empty, game_pattern_descriptor_table, 8

* Initialize the color table.
    .blit_fixed_bytes colors, game_color_table, 32

* Initialize the sprite attribute table.
    .vdpwa game_sprite_attribute_table | vdp_write_bit

    li     r0, sprite_attribute_table_terminator * 256
    .vdpwd r0

    .endm
