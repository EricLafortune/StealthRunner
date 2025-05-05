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

* Macro: initialize the position, direction,... of the player.
* IN  r0: a pointer to the initial values.
* OUT player_x
* OUT player_y
* OUT player_fx
* OUT player_fy
* OUT player_speed
* OUT player_direction
* OUT player_direction_delta
* OUT player_animation_bank
* OUT previous_player_animation_bank
* OUT player_frame
* OUT previous_player_frame
* LOCAL r0
* LOCAL r1
    .defm initialize_player

    mov  *r0+, @player_start_x
    mov  *r0+, @player_start_y
    inct r0

    clr  @player_x
    clr  @player_y
    clr  @player_fx
    clr  @player_fy
    clr  @player_speed

    li   r1, 8                 ; Start with the player facing away from us.
    mov  r1, @player_direction
    seto @player_direction_delta

    .update_player_animation_bank standing_player_animation_banks, r1
    clr  @previous_player_animation_bank
    clr  @player_frame
    clr  @previous_player_frame

    .endm


* Macro: save the position, direction,... of the player.
* IN  player_x
* IN  player_y
* IN  player_fx
* IN  player_fy
* IN  player_speed
* IN  player_direction
* IN  player_direction_delta
* IN  player_animation_bank
* IN  previous_player_animation_bank
* IN  player_frame
* IN  previous_player_frame
* OUT saved_player_state
* LOCAL r0
* LOCAL r1
    .defm save_player_state
    .copy_memory player_state, player_state_end, saved_player_state
    .endm


* Macro: restore the position, direction,... of the player.
* IN  saved_player_state
* OUT player_x
* OUT player_y
* OUT player_fx
* OUT player_fy
* OUT player_speed
* OUT player_direction
* OUT player_direction_delta
* OUT player_animation_bank
* OUT previous_player_animation_bank
* OUT player_frame
* OUT previous_player_frame
* LOCAL r0
* LOCAL r1
    .defm restore_player_state
    .copy_memory saved_player_state, saved_player_state+player_state_end-player_state, player_state
    .endm


* One-time macro: update the position of the player, based on his speed
* (motion) and direction (orientation).
* IN OUT player_x
* IN OUT player_y
* IN OUT player_fx
* IN OUT player_fy
* IN     player_speed
* IN     player_direction
* IN     player_direction_delta
* LOCAL r0-r15
    .defm update_player

    mov  @player_speed, r6
    jlt  dont_update_player_position ; Is the player dead or crouching?
    jeq  dont_update_player_position ; Is the player standing still?
                               ; Then we don't need to update the position.

    mov  @player_direction, r7
    mov  @player_direction_delta, r8

update_player_position_loop
    mov  @player_x, r2         ; Get the coordinates.
    mov  @player_fx, r3

    mov  @player_y, r4
    mov  @player_fy, r5

    mov  r6, r0
    sla  r0, player_direction_shift ; Compute the delta entry adress,
    a    r7, r0                     ; based on direction and speed.
    sla  r0, 3
    ai   r0, delta_still

    .switch_bank @data_bank    ; The motion deltas are in the data bank.

    .update_ordinate r0, r2, r3 ; Adjust the coordinates.
    .update_ordinate r0, r4, r5

    .switch_bank @landscape_mask_bank ; Check the new position.

    mov  r2, r0                ; Scale the x ordinate to a char ordinate.
    ai   r0, -player_base_x
    srl  r0, 3
    mov  r4, r1                ; Scale the y ordinate to a char ordinate.
    ai   r1, -player_base_y
    andi r1, >fff8             ; Compute the y offset of the mask span.
    ai   r1, module_memory
    c    r0, *r1+              ; Is the x ordinate smaller than the first mask span start?
    jl   try_other_player_direction
    c    r0, *r1+              ; Is the x ordinate larger than the first mask span end?
    jl   update_player_position
    c    r0, *r1+              ; Is the x ordinate smaller than the second mask span start?
    jl   try_other_player_direction
    c    r0, *r1               ; Is the x ordinate larger than the second mask span end?
    jl   update_player_position

try_other_player_direction
    a    r8, r7                ; Try another player direction.
    andi r7, player_direction_count - 1

    neg  r8                    ; Update the player direction delta:
    jlt  !                     ;   -1, 2, -3, 4, -5, 6,...
    inct r8                    ; or
!   dec  r8                    ;   1, -2, 3, -4, 5, -6,...

    jmp  update_player_position_loop

update_player_position
    mov  r2, @player_x         ; Update the x ordinate.
    mov  r3, @player_fx

    mov  r4, @player_y         ; Update the y ordinate.
    mov  r5, @player_fy

    srl  r8, 1                       ; Swap the preferential initial player
    jnc  dont_update_player_position ; direction delta (-1 or 1) if the
    neg  @player_direction_delta     ; current delta is even. This is mostly
                                     ; to keep the accumulated delta -4 or +4
                                     ; preferential if they are successful.
dont_update_player_position

    .endm
