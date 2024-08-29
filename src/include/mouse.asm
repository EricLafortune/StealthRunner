* Useful assembly definitions for the TI-99/4A home computer.
*
* Copyright (c) 2023-2024 Eric Lafortune
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

******************************************************************************
* Macros for accessing the Mechatronic mouse, attached to the joystick port
* (or emulated in Mame).
*
* The Mechatronic mouse is documented in
*     https://github.com/mamedev/mame/blob/master/src/devices/bus/ti99/joyport/mecmouse.cpp
*     https://atariage.com/forums/topic/300687-tipi-xb-mouse-driver-like-mechatronics-driver/?do=findComment&comment=4433510
******************************************************************************

* Macro: update the mouse coordinates.
* IN OUT #1: the x ordinate.
* IN OUT #2: the y ordinate.
* LOCAL r0
* LOCAL r1
* LOCAL r2
* LOCAL r12
    .defm read_mouse

!   .toggle_mouse_axis         ; Add a 3-bit delta to the x ordinate.
    .read_mouse_3bits r1
    .decode_mouse_3bits r1
    a    r1, #1

    .toggle_mouse_axis         ; Add a 3-bit delta to the y ordinate.
    .read_mouse_3bits r2
    .decode_mouse_3bits r2
    a    r2, #2

    soc  r1, r2                ; Until all deltas are 0.
    jne  -!
    .endm

* Local macro: toggle the mouse axis to read between the x axis and the y axis.
* LOCAL r0
* LOCAL r12
    .defm toggle_mouse_axis
                               ; Perform the magical selection sequence.
    li   r12, cru_write_keyboard_column

    li   r0, cru_keyboard_column6 ; Select joystick 1.
    ldcr r0, cru_keyboard_column_bit_count

    ; We should probably add a delay here.

    li   r0, cru_keyboard_column7 ; Select joystick 2.
    ldcr r0, cru_keyboard_column_bit_count

    ; We should probably add a delay here.

    .endm

* Local macro: read 3 motion bits on the current mouse axis.
* OUT #1: the register in which the encoded bits are read (MSB).
* LOCAL r12
    .defm read_mouse_3bits
                               ; Read the bits from joystick left/right/down.
    li   r12, cru_read_keyboard_row1
    stcr #1, 3
    .endm

* Local macro: decode 3 motion bits.
* IN OUT #1: the register with the bits (input: MSB, output: signed word).
    .defm decode_mouse_3bits
    sla  #1, 5
    ai   #1, >2000
    sra  #1, 13
    .endm
