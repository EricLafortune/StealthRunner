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

* Macros to update the direction and speed of the player.

* Macro: initialize the input, checking whether a mouse is present.
* OUT: mouse_present
* LOCAL r0-r15
    .defm initialize_input

    clr r3                     ; Check whether the mouse buffer contains any
    .read_mouse r3, r3         ; deltas.
    mov r3, @mouse_present

    .endm

* One-time macro: update the direction and speed of the player, and launch
* EMPs, based on the keyboard/mouse input.
* IN OUT player_direction
* IN OUT player_speed
* IN OUT player_frame
* IN OUT stone_count
* IN OUT stone_x
* IN OUT stone_y
* IN OUT stone_fx
* IN OUT stone_fy
* IN OUT stone_direction
* IN OUT stone_counter
* IN OUT emp_count
* IN OUT emp_x
* IN OUT emp_y
* IN OUT emp_fx
* IN OUT emp_fy
* IN OUT emp_direction
* IN OUT grenade_count
* IN OUT grenade_x
* IN OUT grenade_y
* IN OUT grenade_fx
* IN OUT grenade_fy
* IN OUT grenade_direction
* IN OUT grenade_counter
* IN OUT weapon
* IN OUT hud_sprite
* IN OUT hud_counter
* IN OUT mouse_x
* IN OUT mouse_y
* IN     mouse_present
* IN     player_x
* IN     player_y
* IN     player_fx
* IN     player_fy
* LOCAL r0-r15
    .defm check_input

    .switch_bank @data_bank    ; The player deltas and frame counts are in the
                               ; data bank.

* LOCAL r6: Player speed (-2 for dying, -1 for crouching, 0 for standing,...)
* LOCAL r7: Player direction (0..15).
    mov  @player_direction, r7

    mov  @player_speed, r6     ; Is the player dead or crouching?
    jlt  check_apply_medkit    ; Then check applying a medkit.

    seto r8                    ; No mouse buttons pressed.
    seto r9

check_strafe_left
    .test_keyboard 5, 5        ; Strafing forward left with 'A'?
    jeq  check_strafe_right

    mov  r6, r1                ; Strafe forward left.
    sla  r1, 1
    mov  @strafe_left(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    b    @change_speed

check_strafe_right
    .test_keyboard 2, 5        ; Strafing forward right with 'D'?
    jeq  check_forward

    mov  r6, r1                ; Strafe forward right.
    sla  r1, 1
    mov  @strafe_right(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    b    @change_speed

check_forward
    .test_keyboard 1, 6        ; Walking forward with 'W'?
    jeq  check_backward

    mov  r6, r1                ; Go forward.
    sla  r1, 1
    mov  @go_forward(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    b   @change_speed

check_backward
    .test_keyboard_row 5       ; Walking backward with 'S'?
    jeq  check_slow_down

    mov  r6, r1                ; Go backward.
    sla  r1, 1
    mov  @go_backward(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    b    @change_speed

check_slow_down
    mov  r6, r1                ; Slow down if no speed key.
    sla  r1, 1
    mov  @slow_down(r1), r1
    jlt  check_mouse
    mov  r1, r6
    b    @change_speed

check_speed_up
    .test_keyboard 0, 5        ; Speeding up with 'Shift'?
    jeq  check_mouse

    mov  r6, r1                ; Speed up.
    sla  r1, 1
    mov  @speed_up(r1), r1
    jlt  check_mouse
    mov  r1, r6
    b    @change_speed

check_apply_medkit
    ci   r6, die               ; Is the player dead or already crouching?
    jne  check_crouching_to_standing

    .test_keyboard 0, 6        ; Applying a medkit with 'Ctrl'?
    jeq  check_input_end0

    mov  @medkit_count, r0     ; Does he have any medkits?
    dec  r0
    jlt  check_input_end0

    mov  r0, @medkit_count     ; Save the new number of medkits.

    li   r6, crouch            ; Start crouching to standing.
    clr  @player_frame
    jmp  set_speed

check_crouching_to_standing
    mov  @player_frame, r0     ; After the last crouching frame?
    jne  check_input_end0

    li   r6, stand             ; Start standing.
    clr  @player_frame
    jmp  set_speed

check_input_end0
    b    @check_input_end

check_mouse
    mov  @mouse_present, r0    ; Is a mouse present at all?
    jeq  check_turn_left       ; Then skip the mouse code, which seems to break
                               ; the (immediately?) following keyboard checks.

    mov  @mouse_x, r4          ; Get the current mouse coodinates.
    mov  @mouse_y, r5
    .read_mouse r4, r5

    .test_mouse_button1        ; Test and remember mouse button 1.
    stst r8

    .test_mouse_button2        ; Test and remember mouse button 2.
    stst r9

    mov  r4, r0                ; Are the coordinates not (0,0)?
    jne  !
    mov  r5, r5
    jeq  check_turn_left
!
    mov  r5, r1                ; Then update the direction.
    mov  r7, r2
    bl   @adjust_projected_direction

    c    r7, r2                ; Has the direction remained unchanged?
    jne  !
    mov  r4, @mouse_x          ; Then just update the moved mouse
    mov  r5, @mouse_y          ; coordinates for now.
    jmp  check_change_weapon
!
    mov  r2, r7                ; Otherwise update the direction and reset the
    sla  r2, 3                 ; mouse coordinates to the new direction on a
    mov  @delta_forward_far+0(r2), @mouse_x ; circle.
    mov  @delta_forward_far+4(r2), @mouse_y
    jmp  change_direction

check_turn_left
    .test_keyboard 5, 6        ; Pushing left with 'Q'?
    jeq  check_turn_right

    inc  r7                    ; Then turn left.
    andi r7, player_direction_count-1
    jmp  change_direction

check_turn_right
    .test_keyboard 2, 6        ; Pushing right with 'E'?
    jeq  check_change_weapon

    dec  r7                    ; Then turn right.
    andi r7, player_direction_count-1

change_direction
    mov  r7, @player_direction
    jmp  update_player_animation_bank

change_speed
    mov  @player_speed, r2     ; Get the old speed.

    .update_player_frame_for_speed r2, r6

set_speed
    mov  r6, @player_speed     ; Save the new speed.

update_player_animation_bank
    .update_player_animation_bank standing_player_animation_banks, r6, r7

check_change_weapon
    sla  r9, 3                 ; Changing weapons with mouse button 2?
    jnc  change_weapon
    .test_keyboard 1, 7        ; Changing weapons with 'X'?
    jeq  check_launch_weapon

change_weapon
    mov  @hud_counter, r0      ; Have we already changed it last time?
    ci   r0, 15
    jeq  dont_change_weapon

    mov  @weapon, r1           ; Switch to the next weapon.
    inc  r1
    ci   r1, grenade           ; Wrap around?
    jle  !
    clr  r1
!   mov  r1, @weapon           ; Remember the new weapon.

    sla  r1, 1                 ; Get the number of available weapons.
    mov  @weapon_counts(r1), r0

    ci   r0, 7                 ; Compute and set the HUD supersprite,
    jle  !                     ; based on the (clamped) count...
    li   r0, 7
!   sla  r1, 2                 ; ...and the type.
    a    r1, r0
    ai   r0, weapon_counter_sprites
    mov  r0, @hud_sprite

dont_change_weapon
    li   r0, 14                ; Reset the (short) HUD lifetime.
    mov  r0, @hud_counter

check_launch_weapon
    sla  r8, 3                 ; Launching a weapon with mouse button 1?
    jnc  launch_weapon
    .test_keyboard 0, 2        ; Launching a weapon with 'Enter'?
    jeq  check_input_end

launch_weapon
    mov  @weapon, r1

    sla  r1, 1                 ; Is the weapon available?
    mov  @weapon_counts(r1), r0
    jeq  check_input_end

    mov  r1, r2
    sla  r2, 3                 ; Isn't the weapon active?
    ai   r2, weapon_states
    mov  *r2, r3
    jgt  check_input_end

    dec  r0                    ; Update the weapon count.
    mov  r0, @weapon_counts(r1)

    mov  @player_x, *r2+       ; Copy the player position.
    mov  @player_y, *r2+
    mov  @player_fx, *r2+
    mov  @player_fy, *r2+

    mov  @player_speed, r6     ; Copy the player direction.
    ci   r6, run               ; Should the launch speed be fast?
    jne  !                     ; We'll incorporate the delta in the direction.
    ai   r7, 1 << player_direction_shift
!   mov  r7, *r2+

    clr  *r2                   ; Reset the weapon lifetime counter.

check_input_end

    .endm
