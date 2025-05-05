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

* Definitions to draw the player in the center of the screen.

player_screen_offset_x equ 8   ; Top-left position of the 16x16 character
player_screen_offset_y equ 6   ; player graphics on the screen, expresssed
                               ; in characters.

player_base_x equ player_screen_offset_x * 8 + 64 ; Player base on the screen,
player_base_y equ player_screen_offset_y * 8 + 64 ; expressed in pixels.


* One-time macro: draw the character and pattern deltas of a player animation
* frame.
* IN player_animation_bank
* IN player_frame
* IN previous_player_frame
* IN player_speed
* IN player_direction
* LOCAL r0-r15
    .defm draw_player

    mov  @player_animation_bank, r0
    mov  @player_frame, r1

    c    r0, @previous_player_animation_bank ; Same animation bank?
    jeq  dont_draw_player_full ; Then only draw the player delta.

draw_player_full               ; Otherwise draw the player fully.
    mov  r0, @previous_player_animation_bank ; Remember the new bank.
    mov  r1, @previous_player_frame          ; Remember the new frame.

    .switch_bank *r0           ; Switch to the bank with the current animation.

    mov  r1, r0                ; Compute the address of the pattern blob.
    sla  r0, 1
    ai   r0, module_memory + 2
                               ; Write the patterns.
    .blit_opaque_blob game_pattern_descriptor_table + 64

    li   r0, module_memory     ; Set the address of the character blob.
                               ; Write the characters.
    .blit_blob game_screen_image_table + (player_screen_offset_y * 32) + player_screen_offset_x

    jmp  draw_player_update_frame

dont_draw_player_full
    c    r1, @previous_player_frame ; Same animation frame?
    jeq  draw_player_update_frame   ; Then don't redraw the player at all.

draw_player_delta                   ; We're in the same animation bank.
    mov  r1, @previous_player_frame ; Remember the new frame.

    .switch_bank *r0           ; Switch to the bank with the current animation.

    mov  r1, r0                ; Compute the address of the pattern blob.
    sla  r0, 1
    ai   r0, module_memory + 2
                               ; Write the patterns.
    .blit_blob game_pattern_descriptor_table + 64

* Increment the player animation frame.
draw_player_update_frame
    .switch_bank @data_bank    ; The frame counts and sounds are in the data bank.

    mov  @player_frame, r0     ; Increment the player animation frame number.
    inc  r0

    mov  @player_speed, r1     ; Check the animation frame based on the speed.
    jeq  draw_player_footsteps ; Skip all updates if just standing.

    sla  r1, 1
    c    r0, @frame_counts(r1) ; After the last frame?
    jl   draw_player_save_frame

    clr  r0                    ; Then wrap the frame around.

    ci   r1, crouch << 1       ; End of crouching?
    jeq  draw_player_crouching_end
    jgt  draw_player_save_frame ; End of a regular walking cycle?

    mov  @medkit_count, r0     ; End of dying. Show the medkit counter.
    ci   r0, 7
    jle  !
    li   r0, 7
!   ai   r0, medkit_counter_sprites
    mov  r0, @hud_sprite
    li   r0, 16
    mov  r0, @hud_counter

    jmp  draw_player_end       ; But don't save the frame or play any more
                               ; sound.

draw_player_crouching_end
    clr  @player_speed         ; End of crouching. Switch to standing.
    mov  @player_direction, r1
    .update_player_animation_bank standing_player_animation_banks, r1

draw_player_save_frame
    mov  r0, @player_frame

* Play footstep sound effects.
draw_player_footsteps
    .play_noise_type_frame sound_walking, sound_walking_frames, player_speed, r0

draw_player_end

    .endm


* Macro: scale the player animation frame index, adapting it from the given old
* speed to the given new speed (=motion). The animation should then be more
* continuous.
* IN #1: the register containing the old speed.
* IN #2: the register containing the new speed.
* OUT player_frame
* LOCAL r0
* LOCAL r1
    .defm update_player_frame_for_speed

    mov  @player_frame, r0     ; Get the old frame index.

    sla  #2, 1
    mpy  @frame_counts(#2), r0 ; Multiply by the new frame count (to r0 & r1).

    sla  #1, 1
    div  @frame_counts(#1), r0 ; Divide by the old frame count (from r0 & r1).

    mov  r0, @player_frame     ; Save the adjusted frame index.

    sra  #2, 1                 ; Restore the new speed.

    .endm


* Macro: cache the address of the player animation bank, so the player gets
* drawn properly after his speed or direction changes.
* IN #1: the base animation bank (standing_player_animation_banks,...).
* IN #2: the optional register containing the player speed (-2..8).
* IN #3: the register containing the player direction (0..15).
* OUT player_animation_bank
* LOCAL #2
    .defm update_player_animation_bank

    .ifdef #3
    sla  #2, player_direction_shift
    a    #3, #2
    .endif
    sla  #2, 1
    ai   #2, #1
    mov  #2, @player_animation_bank

    .endm
