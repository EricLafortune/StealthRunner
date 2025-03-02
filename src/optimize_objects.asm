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

* Macros to optimize the objects in the world.
* We have a set of object data per horizontal strip of 128 pixels high.
* All coordinates in the lists are those of the top-left corner of a
* virtual screen in the world, compatible with the player coordinates.

* Macro: compute the offset of the first relevant (nearby, visible) horizontal
* strip with object data.
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset
*               (>0000, >0100,...), relative to the base address with object data.
    .defm first_object_strip

    mov  @player_y, #1
    ai   #1, -supersprite_center_y-(supersprite_height/2)
    srl  #1, object_strip_pixel_height_shift
    sla  #1, object_strip_size_shift

    .endm

* Macro: compute the offset of the last relevant (nearby, visible) horizontal
* strip with object data.
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset
*               (>0000, >0100,...), relative to the base address with object data.
    .defm last_object_strip

    mov  @player_y, #1
    ai   #1, display_pixel_height-supersprite_center_y+(supersprite_height/2)
    srl  #1, object_strip_pixel_height_shift
    sla  #1, object_strip_size_shift

    .endm

* Macro: advance to the next horizontal strip with object data, and check
* whether it is the last one.
* IN OUT #1:       the register containing the current strip offset.
* IN     #2:       the register containing last strip offset.
    .defm next_object_strip

    ai   #1, object_strip_size
    c    #1, #2

    .endm
