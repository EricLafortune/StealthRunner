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

* Definitions to draw the player parachuting into view.

* Macro: draw the supersprite of the player parachuting into view.
* IN parachute_counter
* LOCAL r0-r15
    .defm draw_parachute
                               ; Start drawing the parachuting player sprite.
    .vdpwa game_sprite_attribute_table | vdp_write_bit

    li   r0, sprite_cache_queue

    li   r1, parachute_sprite  ; Pick the parachuting sprite.
    clr  r2

    mov  @parachute_counter, r2 ; Compute the sprite x ordinate, converging
    sra  r2, 2                  ; to 0 (the center of the screen).
    neg  r2

    mov  @parachute_counter, r3 ; Compute the sprite y ordinate, converging
    sra  r3, 1                  ; to 0 (the center of the screen).
    neg  r3

    bl   @draw_supersprite     ; Draw the parachute.

    li   r1, sprite_attribute_table_terminator << 8
    .vdpwd r1                  ; Terminate the quadsprites.

    bl   @write_quadsprites    ; Load the quadsprites into VDP memory.

    .endm

* Macro: update the world coordinates of the parachuting player.
* IN OUT player_start_x
* IN OUT player_start_y
* IN     parachute_counter
* LOCAL r0-r15
    .defm update_parachute

    mov  @player_start_y, r0    ; Compute the screen y ordinate, converging
    s    @parachute_counter, r0 ; to the start position.
    mov  r0, @player_y

    .endm

* Macro: fade in the landscape colors as the player parachutes into view.
* IN parachute_counter
* LOCAL r0-r15
    .defm fade_in_landscape_colors

    .vdpwa game_color_table | vdp_write_bit ; Start writing the first entry
                                            ; in the color table.

                               ; The landscape color goes from black...
    mov  @parachute_counter, r0 ; ...to blue
    ci   r0, 400 - display_pixel_height
    jh   dont_wait_for_vsync   ; Skip the Vsync for the initial incomplete
    jne  !                     ; (black) frames, to fast-forward through them.
    .li_color r1, blue, black
    .vdpwd    r1
!
    ci   r0, 180               ; ...to dark green
    jne  !
    .li_color r1, dark_green, black
    .vdpwd    r1
!
    ci   r0, 160               ; ...to green
    jne  !
    .li_color r1, green, black
    .vdpwd    r1
!
    ci   r0, 140               ; ...to light green.
    jne  !
    .li_color r1, landscape_color, black
    .vdpwd    r1
!
    .endm


