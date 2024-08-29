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

* Data to work with player speeds and player directions.

* Table sizes for player speeds and player directions.
player_speed_count     equ 9
player_direction_count equ 16
player_direction_shift equ 4

* Player speed values.
dying             equ -1
stand             equ 0
walk              equ 1
run               equ 2
walk_backward     equ 3
run_backward      equ 4
walk_strafe_left  equ 5
run_strafe_left   equ 6
walk_strafe_right equ 7
run_strafe_right  equ 8

* Transitions from one walking state to another.
go_forward
    data walk              ; Stand.
    data -1                ; Walk.
    data -1                ; Run.
    data stand             ; Walk backward.
    data walk_backward     ; Run backward.
    data walk              ; Walk strafe left.
    data run               ; Run strafe left.
    data walk              ; Walk strafe right.
    data run               ; Run strafe right.

go_backward
    data walk_backward     ; Stand.
    data stand             ; Walk.
    data walk              ; Run.
    data -1                ; Walk backward.
    data -1                ; Run backward.
    data stand             ; Walk strafe left.
    data walk_strafe_left  ; Run strafe left.
    data stand             ; Walk strafe right.
    data walk_strafe_right ; Run strafe right.

strafe_forward_left
    data walk_strafe_left  ; Stand.
    data walk_strafe_left  ; Walk.
    data run_strafe_left   ; Run.
    data stand             ; Walk backward.
    data walk_backward     ; Run backward.
    data -1                ; Walk strafe left.
    data -1                ; Run strafe left.
    data walk              ; Walk strafe right.
    data run               ; Run strafe right.

strafe_forward_right
    data walk_strafe_right ; Stand.
    data walk_strafe_right ; Walk.
    data run_strafe_right  ; Run.
    data stand             ; Walk backward.
    data walk_backward     ; Run backward.
    data walk              ; Walk strafe left.
    data run               ; Run strafe left.
    data -1                ; Walk strafe right.
    data -1                ; Run strafe right.

speed_up
    data -1                ; Stand.
    data run               ; Walk.
    data -1                ; Run.
    data run_backward      ; Walk backward.
    data -1                ; Run backward.
    data run_strafe_left   ; Walk strafe left.
    data -1                ; Run strafe left.
    data run_strafe_right  ; Walk strafe right.
    data -1                ; Run strafe right.

slow_down
    data -1                ; Stand.
    data stand             ; Walk.
    data walk              ; Run.
    data stand             ; Walk backward.
    data walk_backward     ; Run backward.
    data stand             ; Walk strafe left.
    data walk_strafe_left  ; Run strafe left.
    data stand             ; Walk strafe right.
    data walk_strafe_right ; Run strafe right.

* Number of animation frames for walking states.
frame_counts_die
    data 17 ; Die.
frame_counts
    data  1 ; Stand.
    data 31 ; Walk.
    data 22 ; Run.
    data 36 ; Walk backward.
    data 19 ; Run backward.
    data 31 ; Walk strafe left.
    data 20 ; Run strafe left.
    data 31 ; Walk strafe right.
    data 20 ; Run strafe right.
