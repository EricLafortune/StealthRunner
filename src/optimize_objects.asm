* Game with motion-captured animation for the TI-99/4A home computer.
*
* Copyright (c) 2024-2025 Eric Lafortune
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
* We partion the world of 4096x4096 pixels in 32 horizontal strips of
* 128 pixels high.
* We have a block of strips with static (stateless) data and a block of strips
* with dynamic (stateful) data.
* Each strip can contain any data (currently lists of objects).
world_character_height    equ 512 ; Number of characters vertically in the world.
world_pixel_height        equ world_character_height * 8 ; Number of pixels vertically in the world.

object_strip_pixel_height       equ 128 ; Number of pixels vertically per strip.
object_strip_pixel_height_shift equ 7   ; The corresponding bit shift.

object_strip_count              equ world_pixel_height / object_strip_pixel_height ; Number of strips.

static_object_strip_size        equ 64  ; Bytes of data per strip with static objects.
static_object_strip_size_shift  equ 6   ; The corresponding bit shift.
static_objects_size             equ object_strip_count * static_object_strip_size ; Total size of all strips.

dynamic_object_strip_size       equ 256 ; Bytes of data per strip with dynamic objects.
dynamic_object_strip_size_shift equ 8   ; The corresponding bit shift.
dynamic_objects_size            equ object_strip_count * dynamic_object_strip_size ; Total size of all strips.

* Macro: compute the offset of the first relevant (nearby, visible) horizontal
* strip with static object data.
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset (>0000,
*               >0020,...), relative to the base address with object data.
    .defm first_static_object_strip

    ; Lower bound:
    ;   y_min =  player_y - supersprite_center_y - supersprite_height/2
    ; therefore:
    ;   strip = (player_y - supersprite_center_y - supersprite_height/2)  /
    ;           object_strip_pixel_height
    ; and multiply by the strip size.
    .static_object_strip @player_y, -(display_pixel_height+supersprite_height)/2, #1

    .endm

* Macro: compute the offset of the last relevant (nearby, visible) horizontal
* strip with static object data (inclusive).
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset (>0000,
*               >0020,...), relative to the base address with object data.
    .defm last_static_object_strip

    ; Upper bound:
    ;   y_max =  player_y + display_pixel_height - supersprite_center_y + supersprite_height/2
    ; therefore:
    ;   strip = (player_y + display_pixel_height - supersprite_center_y + supersprite_height/2)  /
    ;           object_strip_pixel_height
    ; and multiply by the strip size.
    .static_object_strip @player_y, (display_pixel_height+supersprite_height)/2, #1

    .endm

* Macro: compute the offset of the specified horizontal strip with static
* object data.
* IN  #1: the source address or register containing a y ordinate in the strip.
* IN  #2: a constant delta to be added to the y ordinate.
* OUT #3: the destination register for the strip offset (>0000, >0020,...)
    .defm static_object_strip

    .object_strip_number #1, #2, #3

    sla  #3, static_object_strip_size_shift ; Multiply by the strip size.

    .endm

* Macro: check whether a static object is inside the given strip.
* IN #1: the register containing the y ordinate of the object.
* IN #2: the register containing strip offset.
    .defm check_static_object_strip

    ; Computation:
    ;   strip = y_ordinate  /
    ;           object_strip_pixel_height_shift
    ; and multiply by the strip size.
    srl  #1, object_strip_pixel_height_shift
    sla  #1, static_object_strip_size_shift
    c    #1, #2

    .endm

* Macro: advance to the next horizontal strip with static object data, and
* check whether it is the last one.
* IN OUT #1:       the register containing the current strip offset.
* IN     #2:       the register containing last strip offset.
    .defm next_static_object_strip

    ai   #1, static_object_strip_size
    c    #1, #2

    .endm

* Macro: compute the offset of the first relevant (nearby, visible) horizontal
* strip with dynamic object data.
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset (>0000,
*               >0100,...), relative to the base address with object data.
    .defm first_dynamic_object_strip

    ; Lower bound:
    ;   y_min =  player_y - supersprite_center_y - supersprite_height/2
    ; therefore:
    ;   strip = (player_y - supersprite_center_y - supersprite_height/2)  /
    ;           object_strip_pixel_height
    ; and multiply by the strip size.
    .dynamic_object_strip @player_y, -(display_pixel_height+supersprite_height)/2, #1

    .endm

* Macro: compute the offset of the last relevant (nearby, visible) horizontal
* strip with dynamic object data (inclusive).
* IN  player_y: the current y ordinate of the player.
* OUT #1:       the destination register for the strip offset (>0000,
*               >0100,...), relative to the base address with object data.
    .defm last_dynamic_object_strip

    ; Upper bound:
    ;   y_max =  player_y + display_pixel_height - supersprite_center_y + supersprite_height/2
    ; therefore:
    ;   strip = (player_y + display_pixel_height - supersprite_center_y + supersprite_height/2)  /
    ;           object_strip_pixel_height
    ; and multiply by the strip size.
    .dynamic_object_strip @player_y, (display_pixel_height+supersprite_height)/2, #1

    .endm

* Macro: compute the offset of the specified horizontal strip with dynamic
* object data.
* IN  #1: the source address or register containing a y ordinate in the strip.
* IN  #2: a constant delta to be added to the y ordinate.
* OUT #3: the destination register for the strip offset (>0000, >0100,...)
    .defm dynamic_object_strip

    .object_strip_number #1, #2, #3

    sla  #3, dynamic_object_strip_size_shift ; Multiply by the strip size.

    .endm

* Macro: check whether a dynamic object is inside the given strip.
* IN #1: the register containing the y ordinate of the object.
* IN #2: the register containing strip offset.
    .defm check_dynamic_object_strip

    ; Computation:
    ;   strip = y_ordinate  /
    ;           object_strip_pixel_height_shift
    ; and multiply by the strip size.
    srl  #1, object_strip_pixel_height_shift
    sla  #1, dynamic_object_strip_size_shift
    c    #1, #2

    .endm

* Macro: advance to the next horizontal strip with dynamic object data, and
* check whether it is the last one.
* IN OUT #1:       the register containing the current strip offset.
* IN     #2:       the register containing last strip offset.
    .defm next_dynamic_object_strip

    ai   #1, dynamic_object_strip_size
    c    #1, #2

    .endm

* Macro: compute the number of the specified horizontal strip with object data.
* IN  #1: the source address or register containing a y ordinate in the strip.
* IN  #2: a constant delta to be added to the y ordinate.
* OUT #3: the destination register for the strip number (0, 1,...)
    .defm object_strip_number

    mov  #1, #3
    ai   #3, #2
    srl  #3, object_strip_pixel_height_shift

    .endm
