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

* Macros to draw the landscape of dots.

* One-time macro: draw the characted and pattern deltas of the landscape.
* IN player_x
* IN player_y
* IN previous_landscape_patterns_offset
* IN previous_landscape_character_quadrant
* LOCAL r0-r15
    .defm draw_landscape_delta

* Write the landscape patterns.
draw_landscape_patterns
    .switch_bank @code_bank    ; The patterns are in the code bank.

    .vdpwa game_pattern_descriptor_table + 8 | vdp_write_bit

    mov  @player_x, r3         ; Compute the landscape pattern coordinates (modulo 8).
    andi r3, >0007
    sla  r3, 4

    mov  @player_y, r4
    andi r4, >0007

    mov  r3, r0                ; Compute the source address of the first 1-dot pattern.
    a    r4, r0
    c    r0, @previous_landscape_patterns_offset ; Same dots as last time?
    jeq  draw_landscape_characters_end           ; Then don't redraw the landscape at all.
    mov  r0, @previous_landscape_patterns_offset

    ai   r0, landscape_patterns_1dot

    .blit_more_bytes 8

    mov  r4, r0                ; Compute the source address of the second 1-dot pattern.
    ai   r0, 4
    andi r0, >0007
    a    r3, r0
    ai   r0, 4 * 16
    andi r0, 8 * 16 - 1
    ai   r0, landscape_patterns_1dot

    .blit_more_bytes 8

    mov  r3, r0                ; Compute the source address of the 2-dots pattern.
    a    r4, r0
    ai   r0, landscape_patterns_2dots

    .blit_more_bytes 8
draw_landscape_patterns_end

draw_landscape_characters
    mov  @player_y, r0         ; Pick the memory bank of the shifted landscape.
    srl  r0, 2
    andi r0, >0001             ; First or second character quadrant on the y axis?
    sla  r0, 1

    mov  @player_x, r1
    srl  r1, 2
    andi r1, >0001             ; First or second character quadrant on the x axis?

    a    r1, r0                ; Compute the character quadrant 0..3.
    c    r0, @previous_landscape_character_quadrant ; Same quadrant as last time?
    jeq  draw_landscape_characters_end ; Then don't redraw the characters.
    mov  r0, @previous_landscape_character_quadrant

    sla  r0, 1
    ai   r0, landscape_characters_banks ; The landscape characters memory banks.

    mov  @player_y, r3         ; Compute the address of the first visible row.
    ai   r3, -player_center_y
    srl  r3, 3
    andi r3, >01ff
    sla  r3, 1
    ai   r3, >6000

    mov  @player_x, r4         ; Compute the character offset in the rows.
    ai   r4, -player_center_x
    srl  r4, 3
    andi r4, >03ff

    li   r5, 32
    li   r6, 24
    .blit_clipped_blobs game_screen_image_table ; Write the characters.
draw_landscape_characters_end

    .endm
