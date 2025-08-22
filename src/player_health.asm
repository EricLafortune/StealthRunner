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

* Subroutine to set the player health, updating color and the animation of
* the avatar if necessary.

* Subroutine: set the player health.
* IN r1: the new health.
* LOCAL r0
* LOCAL r1
* LOCAL r3 (not r2)
* LOCAL r4
set_player_health
    cb   r1, @player_health    ; Is it a fundamental change in health?
    jeq  update_player_health

                               ; Then update the color table.
    .vdpwa game_color_table + 1 | vdp_write_bit

    .switch_bank @data_bank    ; The colors are in the data bank.

    mov  r1, r0                ; Compute the new player color address.
    sra  r0, 8
    ai   r0, player_colors

    .vdpwd *r0                 ; Write the colors for 10x8 player characters.
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0
    .vdpwd *r0

    cb   r1, @player_health    ; Is it a decrease in health?
    jgt  update_player_health

    mov  r1, @player_health    ; Update the player health.
    jlt  kill_player           ; Has he died now?

    ci   r1, player_tired      ; Is he very tired now?
    jlt  slow_down_player      ; Then slow him down.
    rt

slow_down_player
    mov  @player_speed, r3     ; Get the old speed.
    jeq  set_player_health_end ; Compute the new, slower speed.
    mov  r3, r4
    srl  r4, 1
    joc  set_player_health_end
    mov  r3, r4
    dec  r4

    .update_player_frame_for_speed r3, r4

    mov  r4, @player_speed     ; Save the new speed.
    mov  @player_direction, r3

    .update_player_animation_bank standing_player_animation_banks, r4, r3

    .start_speech speech_huh
    rt

kill_player
    .ifndef immortal
    li   r0, die               ; Start the dying animation.
    mov  r0, @player_speed

    mov  @player_direction, r0
    .update_player_animation_bank dying_player_animation_banks, r0

    clr  @player_frame         ; Reset the player animation frame.
    .endif

    .start_speech speech_aah
    rt

update_player_health
    mov  r1, @player_health    ; Update the player health.

set_player_health_end
    rt
