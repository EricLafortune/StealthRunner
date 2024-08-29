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

player_screen_offset_x equ 8   ; Player graphics top-left position on the
player_screen_offset_y equ 6   ; screen, expresssed in characters.

player_center_x        equ 128 ; Player center on the screen, expressed
player_center_y        equ  96 ; in pixels.


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
    sla  r1, 1                 ; Compute the address of the pattern blob.
    ai   r1, module_memory + 2
                               ; Write the patterns.
    .blit_opaque_blob game_pattern_descriptor_table + 64

    mov  @player_animation_bank, r0
    li   r1, module_memory     ; Set the address of the character blob.
                               ; Write the characters.
    .blit_blob game_screen_image_table + (player_screen_offset_y * 32) + player_screen_offset_x

    jmp  draw_player_save_frame

dont_draw_player_full
    c    r1, @previous_player_frame ; Same animation frame?
    jeq  draw_player_update_frame   ; Then don't redraw the player at all.

draw_player_delta
    sla  r1, 1                 ; Compute the address of the pattern blob.
    ai   r1, >6002
                               ; Write the patterns.
    .blit_blob game_pattern_descriptor_table + 64

draw_player_save_frame         ; Remember the animation frame that we've drawn.
    mov  @player_animation_bank, @previous_player_animation_bank
    mov  @player_frame, @previous_player_frame

* Increment the player animation frame.
draw_player_update_frame
    .switch_bank @code_bank    ; The player frame counts are in the code bank.

    mov  @player_frame, r0     ; Increment the player animation frame number.
    inc  r0

    mov  @player_speed, r1     ; Check the animation frame based on the speed.
    sla  r1, 1
    c    r0, @frame_counts(r1) ; After the last frame?
    jl   !
    mov  r1, r1                ; And not dying?
    jlt  draw_player_end
    clr  r0                    ; Then wrap it around.
!   mov  r0, @player_frame

* Play footstep sound effects.
draw_player_footsteps
    .switch_bank @code_bank    ; The sounds are in the code bank.

    .play_noise_type_frame sound_walking, sound_walking_frames, player_speed, r0

draw_player_end

    .endm
