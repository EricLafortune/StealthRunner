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

* Macro: initialize the landscape.
* OUT previous_landscape_patterns_offset
* OUT previous_quadrant_x
* OUT previous_quadrant_y
* LOCAL r0
    .defm initialize_landscape
    clr  @previous_landscape_patterns_offset

    mov  @player_x, r0         ; Initialize the previous quadrant x ordinate.
    srl  r0, 2
    mov  r0, @previous_quadrant_x

    mov  @player_y, r0         ; Initialize the previous quadrant y ordinate.
    srl  r0, 2
    mov  r0, @previous_quadrant_y
    .endm

* Macro: draw the characted and pattern deltas of the landscape.
* IN player_x
* IN player_y
* IN previous_landscape_patterns_offset
* LOCAL r0-r15
    .defm draw_landscape_delta
    .draw_landscape_patterns
    .draw_landscape_characters
    .endm

* Macro: write the landscape patterns.
    .defm draw_landscape_patterns

    .switch_bank @data_bank    ; The patterns are in the data bank.

    .vdpwa game_pattern_descriptor_table + 8 | vdp_write_bit

    mov  @player_x, r3         ; Compute the landscape pattern coordinates (modulo 8).
    andi r3, >0007
    sla  r3, 4

    mov  @player_y, r4
    andi r4, >0007

    mov  r3, r0                ; Compute the source address of the first 1-dot pattern.
    a    r4, r0
    c    r0, @previous_landscape_patterns_offset ; Same dots as last time?
    jeq  !! ;draw_landscape_characters_end       ; Then don't redraw the landscape at all.
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

    .endm

* Macro: write the landscape character deltas.
* IN player_x
* IN player_y
* IN previous_quadrant_x
* IN previous_quadrant_y
* LOCAL r0-r15
    .defm draw_landscape_characters

    mov  @player_x, r0         ; Compute the current quadrant ordinates,
    srl  r0, 2                 ; expressed as multiples of 4 pixels.

    mov  @player_y, r1
    srl  r1, 2

    mov  r0, r2                ; Compute the deltas from the previous quadrant
    mov  r1, r3                ; ordinates to the current quadrant ordinates.

    s    @previous_quadrant_x, r2
    s    @previous_quadrant_y, r3

    a    r3, r2                ; Compute the delta as an index:
    sla  r3, 1                 ; index = 3 * dy + dx + 4, but leaving out
    a    r3, r2                ; an index for (0, 0).
    jeq  !! ;draw_landscape_characters_end ; Skip if the combined delta is 0.
    jgt  !                     ;   0 1 2 (with "0" moving left/up, etc)
    inc  r2                    ;   3   4
!   ai   r2, 3                 ;   5 6 7

    mov  r0, @previous_quadrant_x ; Save the current quadrant ordinates.
    mov  r1, @previous_quadrant_y

    mov  r1, r3                ; Save the ordinates for computing the character
    mov  r0, r4                ; row and column later on.

    andi r0, >0001             ; Compute the current quadrant ordinates inside
    andi r1, >0001             ; the character.

    sla  r0, 3                 ; Combine the quadrant ordinates with the
    sla  r1, 4                 ; index.
    soc  r1, r0
    soc  r2, r0                ; The index is now 0..31.

    sla  r0, 1                 ; Switch to the right landscape delta memory
    ai   r0, landscape_characters_banks ; bank.
    .switch_bank *r0, *r0

    ai   r3, -player_base_y/4  ; Compute the address of the first visible row
    andi r3, >03fe             ; index (a list of words).
    ai   r3, module_memory

    ai   r4, -player_base_x/4  ; Compute the character offset in the rows.
    srl  r4, 1
    andi r4, >03ff

    li   r5, 32
    li   r6, 24
    .blit_clipped_blobs game_screen_image_table ; Write the characters.
!
;draw_landscape_characters_end

    .endm
