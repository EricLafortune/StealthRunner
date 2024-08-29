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

* One-time macro: update the direction and speed of the player, and launch
* EMPs, based on the keyboard/mouse input.
* IN OUT player_direction
* IN OUT player_speed
* IN OUT player_frame
* IN OUT emp_x
* IN OUT emp_y
* IN OUT emp_fx
* IN OUT emp_fy
* IN     player_x
* IN     player_y
* IN     player_fx
* IN     player_fy
* LOCAL r0-r15
    .defm check_input

    .switch_bank @code_bank    ; The player deltas and frame counts are in the
                               ; code bank.

* LOCAL r6: Player speed (-1 for dying, 0 for standing,...)
* LOCAL r7: Player direction (0..15).
    mov  @player_speed, r6     ; Get the current speed and direction.
    mov  @player_direction, r7

check_strafe_left
    .test_keyboard 5, 5        ; Strafing forward left with 'A'?
    jeq  check_strafe_right

    mov  r6, r1                ; Strafe forward left.
    sla  r1, 1
    mov  @strafe_forward_left(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    b    @change_speed

check_strafe_right
    .test_keyboard 2, 5        ; Strafing forward right with 'D'?
    jeq  check_forward

    mov  r6, r1                ; Strafe forward right.
    sla  r1, 1
    mov  @strafe_forward_right(r1), r1
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
    jmp  change_speed

check_backward
    .test_keyboard_row 5       ; Walking backward with 'S'?
    jeq  check_slow_down

    mov  r6, r1                ; Go backward.
    sla  r1, 1
    mov  @go_backward(r1), r1
    jlt  check_speed_up
    mov  r1, r6
    jmp  change_speed

check_slow_down
    mov  r6, r1                ; Slow down if no speed key.
    sla  r1, 1
    mov  @slow_down(r1), r1
    jlt  check_mouse
    mov  r1, r6
    jmp  change_speed

check_speed_up
    .test_keyboard 0, 5        ; Speeding up with 'Shift'?
    jeq  check_mouse

    mov  r6, r1                ; Speed up.
    sla  r1, 1
    mov  @speed_up(r1), r1
    jlt  check_mouse
    mov  r1, r6
    jmp  change_speed

check_mouse
    mov  @mouse_x, r4          ; Get the current mouse coodinates.
    mov  @mouse_y, r5
    .read_mouse r4, r5
    mov  r4, r0                ; Are they not (0,0)?
    jne  !
    mov  r5, r5
    jeq  check_launch_emp
!
    mov  r5, r1                ; Then update the direction.
    mov  r7, r2
    bl   @adjust_projected_direction

    c    r7, r2                ; Has the direction reamined unchanged?
    jne  !
    mov  r4, @mouse_x          ; Then just update the moved mouse
    mov  r5, @mouse_y          ; coordinates for now.
    jmp  check_launch_emp
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
    jeq  check_launch_emp

    dec  r7                    ; Then turn right.
    andi r7, player_direction_count-1

change_direction
    mov  r7, @player_direction
    jmp  update_player_animation_bank

change_speed
    mov  @player_frame, r3     ; Scale the animation frame to the new animation.
    sla  r6, 1
    mpy  @frame_counts(r6), r3 ; Multiply by the new frame count (to r3 & r4).
    sra  r6, 1

    mov  @player_speed, r5
    sla  r5, 1
    div  @frame_counts(r5), r3 ; Divide by the old frame count (from r3 & r4).

    mov  r6, @player_speed     ; Set the new speed.
    mov  r3, @player_frame     ; Set the adjusted frame.

update_player_animation_bank
    sla  r6, player_direction_shift ; Update the cached player animation bank
    a    r7, r6                     ; address.
    sla  r6, 1
    ai   r6, standing_player_animation_banks
    mov  r6, @player_animation_bank

check_launch_emp
    mov  @charge_count, r0     ; Is an EMP available?
    jeq  check_input_end
    mov  @emp_x, r0            ; Is the EMP inactive?
    jgt  check_input_end
    clr   r12                  ; Works if joystick column is still set.
    .test_keyboard_row 0       ; Launching an EMP with 'Fire1'?
    jne  !
    .test_keyboard 0, 2        ; Launching an EMP with 'Enter'?
    jeq  check_input_end
!
    dec  @charge_count
    mov  @player_x, @emp_x     ; Fire the EMP from the player.
    mov  @player_y, @emp_y
    mov  @player_fx, @emp_fx
    mov  @player_fy, @emp_fy
    mov  r7, @emp_direction

check_input_end

    .endm
