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

* Macros to update the player.

* One-time macro: initialize the position, direction,... of the player.
* IN r0: a pointer to the initial values.
* OUT player_x
* OUT player_y
* OUT player_fx
* OUT player_fy
*     player_speed
*     player_direction
* LOCAL r0
* LOCAL r1
    .defm initialize_player

    mov  *r0+, @player_x
    mov  *r0+, @player_y
    inct r0

    clr  @player_fx
    clr  @player_fy
    clr  @player_speed
    clr  @player_direction

    li   r1, standing_player_animation_banks
    mov  r1, @player_animation_bank
    clr  @previous_player_animation_bank
    clr  @player_frame
    clr  @previous_player_frame

    .endm


* One-time macro: update the position of the player, based in his direction
* and speed.
* IN OUT player_x
* IN OUT player_y
* IN OUT player_fx
* IN OUT player_fy
* IN     player_speed
* IN     player_direction
* LOCAL r0-r15
    .defm update_player

    mov  @player_speed, r6
    jeq  dont_update_player_position ; Is the player standing still?
                               ; Then we don't need to update the position.

    jgt  !                     ; Is the player dead?
    b    @check_quit           ; Then don't update the position or check keys.
!
    mov  @player_x, r2         ; Get the coordinates.
    mov  @player_fx, r3

    mov  @player_y, r4
    mov  @player_fy, r5

    sla  r6, player_direction_shift ; Compute the delta entry adress,
    a    @player_direction, r6      ; based on direction and speed.
    sla  r6, 3
    ai   r6, delta_still

    .switch_bank @code_bank    ; The motion deltas are in the code bank.

    .update_ordinate r6, r2, r3 ; Adjust the coordinates.
    .update_ordinate r6, r4, r5

    .switch_bank @landscape_mask_bank ; Check the new position.

    mov  r2, r0                ; Scale the x ordinate to a char ordinate.
    ai   r0, -player_center_x
    srl  r0, 3
    mov  r4, r6                ; Scale the y ordinate to a char ordinate.
    ai   r6, -player_center_y
    srl  r6, 3
    sla  r6, 3                 ; Compute the y offset of the mask span.
    ai   r6, module_memory
    c    r0, *r6+              ; Is the x ordinate smaller than the first mask span start?
    jl   dont_update_player_position
    c    r0, *r6+              ; Is the x ordinate larger than the first mask span end?
    jl   update_player_position
    c    r0, *r6+              ; Is the x ordinate smaller than the second mask span start?
    jl   dont_update_player_position
    c    r0, *r6+              ; Is the x ordinate larger than the second mask span end?
    jhe  dont_update_player_position

update_player_position
    mov  r2, @player_x         ; Update the x ordinate.
    mov  r3, @player_fx

    mov  r4, @player_y         ; Update the y ordinate.
    mov  r5, @player_fy

dont_update_player_position

    .endm
