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

* Definitions for the graphics for videos in the .tms format of the Video
* Tools.

* Locations of the various graphics tables in VDP memory for the intro video.
video_pattern_descriptor_table equ >0000 ; Size >1800.
video_color_table              equ >2000 ; Size >1800.
video_screen_image_table       equ >1800 ; Size >0300.
video_sprite_attribute_table   equ >3800 ; Size >0080.
video_sprite_descriptor_table  equ >0000 ; Size >0800.


* One-time macro: initialize the VDP registers and memory for the video.
* LOCAL r0
* LOCAL r1
    .defm initialize_video_graphics

* Set up the VDP registers.
    .vdpwr_mode                     bitmap_mode
    .vdpwr_flags                    vdp16k | display_enable | interrupt_enable
    .vdpwr_pattern_descriptor_table video_pattern_descriptor_table, bitmap_mode
    .vdpwr_color_table              video_color_table, bitmap_mode
    .vdpwr_screen_image_table       video_screen_image_table
    .vdpwr_sprite_attribute_table   video_sprite_attribute_table
    .vdpwr_sprite_descriptor_table  video_sprite_descriptor_table
    .vdpwr_background_color         black

* Initialize the pattern descriptor table and screen image table.
    .vdpwa video_pattern_descriptor_table | vdp_write_bit
    clr  r0
    li   r1, bitmap_pattern_descriptor_table_size + screen_image_table_size
pattern_loop
    .vdpwd r0
    dec  r1
    jne  pattern_loop

* Initialize the color table.
    .vdpwa    video_color_table | vdp_write_bit
    .li_color r0, white, black
    li        r1, bitmap_color_table_size
color_loop
    .vdpwd r0
    dec  r1
    jne  color_loop

* Initialize the sprite attribute table.
    .vdpwa video_sprite_attribute_table | vdp_write_bit
    li     r0, sprite_attribute_table_terminator * 256
    .vdpwd r0

    .endm
