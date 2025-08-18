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

    mov  @saved_player_y, r2   ; Compute animated sprite coordinates,
    s    @player_y, r2         ; converging to 0 (the center of the screen).
    neg  r2
    mov  r2, r3
    sra  r2, 2
    sra  r3, 1

    bl   @draw_supersprite     ; Draw the parachute.

    li   r1, sprite_attribute_table_terminator << 8
    .vdpwd r1                  ; Terminate the quadsprites.

    bl   @write_quadsprites    ; Load the quadsprites into VDP memory.

    .endm

* Macro: initialize the world coordinates of the parachuting player.
* OUT player_x
* OUT player_y
* LOCAL r0-r15
    .defm initalize_parachute

    clr  @player_x                  ; Initialize the screen ordinates.
    mov  @saved_player_y, r0
    ai   r0, -300
    mov  r0, @player_y

    .endm

* Macro: fade in the landscape colors as the player parachutes into view.
* IN parachute_counter
* OUT r0: the counter that counts down to the starting point.
* LOCAL r0-r15
    .defm fade_in_landscape_colors

    .vdpwa game_color_table | vdp_write_bit ; Start writing the first entry
                                            ; in the color table.

                               ; The landscape color goes from black...
    mov  @saved_player_y, r0
    s    @player_y, r0
    ci   r0, 300               ; ...to blue
    jne  !
    .li_color r1, blue, black
    .vdpwd    r1
!
    ci   r0, 250               ; ...to dark green
    jne  !
    .li_color r1, dark_green, black
    .vdpwd    r1
!
    ci   r0, 200               ; ...to green
    jne  !
    .li_color r1, green, black
    .vdpwd    r1
!
    ci   r0, 150               ; ...to light green.
    jne  !
    .li_color r1, landscape_color, black
    .vdpwd    r1
!
    .endm


