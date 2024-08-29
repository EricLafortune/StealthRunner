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

* Macros to update the positions, directions, state,... of the objects in the
* world.

* Special supersprite flags.
exploding equ >0800

* One-time macro: initialize the objects in the world.
* IN r0: a pointer to the initial values.
* OUT target_x
* OUT target_y
* OUT charge_count
* OUT charge_frame
* OUT emp_x
* OUT emp_y
* OUT emp_direction
* OUT batteries
* OUT drones
* OUT turrets
* OUT bullet_x
* OUT bullet_y
* OUT bullet_direction
* OUT mines
* OUT player_x
* OUT player_y
* LOCAL r0
* LOCAL r1
    .defm initialize_objects

    clr  @charge_count
    seto @charge_frame
    seto @emp_x
    seto @bullet_x

* Initialize the target position.
    mov  *r0+, @target_x
    mov  *r0+, @target_y
    inct r0

* Initialize the battery positions and directions.
    li   r1, batteries

initialize_battery_loop
    mov  *r0+, *r1+            ; Copy the x ordinate.
    jlt  initialize_battery_loop_end ; Is it the last battery?
    mov  *r0+, *r1+            ; Copy the y ordinate.
    jmp  initialize_battery_loop
initialize_battery_loop_end

* Initialize the mine positions and directions.
    li   r1, mines

initialize_mine_loop
    mov  *r0+, *r1+            ; Copy the x ordinate.
    jlt  initialize_mine_loop_end ; Is it the last mine?
    mov  *r0+, *r1+            ; Copy the y ordinate.
    clr  *r1+                  ; Initialize the explosion.
    jmp  initialize_mine_loop
initialize_mine_loop_end

* Initialize the drone positions and directions.
    li   r1, drones

initialize_drone_loop
    mov  *r0+, *r1+            ; Copy the x ordinate.
    jlt  initialize_drone_loop_end ; Is it the last drone?
    mov  *r0+, *r1+            ; Copy the y ordinate.
    clr  *r1+                  ; Clear the fractional x ordinate.
    clr  *r1+                  ; Clear the fractional y ordinate.
    clr  *r1+                  ; Initialize the direction.
    jmp  initialize_drone_loop
initialize_drone_loop_end

* Initialize the turret positions and directions.
    li   r1, turrets

initialize_turret_loop
    mov  *r0+, *r1+            ; Copy the x ordinate.
    jlt  initialize_turret_loop_end ; Is it the last turret?
    mov  *r0+, *r1+            ; Copy the y ordinate.
    clr  *r1+                  ; Initialize the direction.
    jmp  initialize_turret_loop
initialize_turret_loop_end

    .endm


* One-time macro: update the objects in the world.
* IN OUT charge_frame
* IN OUT emp_x
* IN OUT emp_y
* IN OUT emp_direction
* IN OUT batteries
* IN OUT drones
* IN OUT turrets
* IN OUT bullet_x
* IN OUT bullet_y
* IN OUT bullet_direction
* IN OUT mines
* IN     player_x
* IN     player_y
* LOCAL r0-r15
    .defm update_objects

    .switch_bank @code_bank    ; The motion deltas are in the code bank.

* Update the battery charge meter.
update_charge
    mov  @charge_frame, r3
    jlt  update_charge_end     ; Is it inactive?

    ai   r3, >0800
    mov  r3, @charge_frame

    srl  r3, 11
    .play_tone0_frame sound_emp, sound_emp_frames, r3
update_charge_end

* Update the EMP state and position.
update_emp
    mov  @emp_x, r0
    jlt  update_emp_end        ; Is it inactive?
    mov  @emp_y, r1

    .dist @player_x, r0, r2, 128+10 ; Is the EMP far from the player?
    jgt  disable_emp

    .dist @player_y, r1, r3, 96+20
    jlt  update_emp_position

disable_emp                    ; Then disable it.
    seto @emp_x

    .stop_tone0 sound_emp      ; Stop the EMP sound.
    jmp  update_emp_end

update_emp_position
    .switch_bank @code_bank    ; The motion deltas are in the code bank.

    mov  @emp_direction, r4    ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @emp_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @emp_fy

    mov  r0, @emp_x            ; Save them.
    mov  r1, @emp_y

    a    r2, r3                ; Distance range roughly 0..255.
    srl  r3, 4                 ; Sound frame range roughly 0..15.
    .play_tone0_frame sound_emp, sound_emp_frames, r3

update_emp_end

* Check if the player has reached the target.
check_target
    .dist @player_x, @target_x, r0, 20 ; Is it close to the player?
    jgt  check_target_end
    .dist @player_y, @target_y, r1, 40
    jgt  check_target_end

    seto @target_x             ; Move the target out of the way.
    seto @target_y
    seto @mines                ; Disable all mines.
    seto @drones               ; Disable all drones.
    seto @turrets              ; Disable all turrets.
    seto @bullet_x             ; Disable the bullet.

    li   r0, >9f00             ; Stop all sound.
    .sound r0
    li   r0, >ff00
    .sound r0

    .start_speech speech_ahohe ; Start singing.
check_target_end

* Update the battery states.
    li   r5, batteries

update_battery_loop
    mov  *r5+, r0              ; Get the x ordinate.
    jlt  update_battery_loop_end ; Is it the last battery?
    mov  *r5+, r1              ; Get the y ordinate.
    jlt  update_battery_loop   ; Is it inactive?

check_battery_player
    .dist @player_x, r0, 20    ; Is it close to the player?
    jgt  update_battery_loop
    .dist @player_y, r1, 40
    jgt  update_battery_loop

    inc  @charge_count         ; Then increment the number of available EMPs.
    clr  @charge_frame
    seto @-2(r5)               ; Disable the battery.
    jmp  update_battery_loop
update_battery_loop_end

* Update the mine states.
    li   r5, mines

update_mine_loop
    mov  *r5+, r0              ; Get the x ordinate.
    jlt  update_mine_loop_end  ; Is it the last mine?
    mov  *r5+, r1              ; Get the y ordinate.
    mov  *r5+, r2              ; Get the sprite.
    jlt  update_mine_loop      ; Is it inactive?

    jh   explode_mine          ; Is the mine already exploding?

check_mine_player
    .dist @player_x, r0, r3, 128+10 ; Is it very far from the player?
    jgt  update_mine_loop     ; Then continue with the next mine.
    .dist @player_y, r1, r4, 96+20
    jgt  update_mine_loop

    ci   r3, 20                ; Is it very near?
    jgt  check_mine_emp
    ci   r4, 40
    jgt  check_mine_emp

    bl   @kill_player          ; Then kill the player.
    jmp  explode_mine          ; And let the mine explode.

check_mine_emp
    .dist @emp_x, r0, 16       ; Is it close to the EMP?
    jgt  update_mine_loop
    .dist @emp_y, r1, 16
    jgt  update_mine_loop

explode_mine
    ai   r2, exploding         ; Let the mine explode, automatically
    mov  r2,@-2(r5)            ; disabling it at the end.
    jlt  update_mine_loop

    srl  r2, 11                ; Compute the sound frame of the explosion.
    .play_noise_frame sound_explosion, sound_explosion_frames, r2
    jmp  update_mine_loop
update_mine_loop_end

* Update the drone states, positions, and directions.
    li   r8, drones

update_drone_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_drone_loop_end0 ; Is it the last drone?
    mov  *r8+, r1              ; Get the y ordinate.
    ai   r8, 4                 ; Skip the fractional ordinates.
    mov  *r8+, r2              ; Get the direction.
    jlt  update_drone_loop     ; Is it inactive?

    ci   r2, exploding         ; Is the drone already exploding?
    jhe  explode_drone

check_drone_player
    .dist @player_x, r0, r4, 128+10 ; Is it very far from the player?
    jgt  update_drone_loop     ; Then continue with the next drone.
    .dist @player_y, r1, r5, 96+20
    jgt  update_drone_loop

    ci   r4, 40                ; Is it very near?
    jgt  check_drone_emp
    ci   r5, 20
    jgt  check_drone_emp

    bl   @kill_player          ; Then kill the player.
    jmp  explode_drone         ; And let the drone explode.

check_drone_emp
    .dist @emp_x, r0, r3, 16   ; Is it close to the EMP?
    jgt  update_drone_direction
    .dist @emp_y, r1, r3, 16
    jgt  update_drone_direction

explode_drone
    ai   r2, exploding         ; Let the drone explode, automatically
    mov  r2,@-2(r8)            ; disabling it at the end.
    jlt  update_drone_loop

    srl  r2, 11                ; Compute the sound frame of the explosion.
    .play_noise_frame sound_explosion, sound_explosion_frames, r2
    jmp  update_drone_loop

update_drone_loop_end0
    jmp  update_drone_loop_end

update_drone_direction
    mov  r0, r6                ; Keep a copy of the coordinates.
    mov  r1, r7

    s    @player_x, r0         ; Compute the direction vector.
    s    @player_y, r1

    neg  r0                    ; Pointing from the drone to the player.
    neg  r1

    bl   @adjust_projected_direction ; Update the direction.
    mov  r2, @-2(r8)           ; Save it.

    sla  r2, 3                 ; Compute the delta entry adress.
    ai   r2, delta_forward_slow

    .update_ordinate r2, r6, @-6(r8) ; Adjust the coordinates.
    .update_ordinate r2, r7, @-4(r8)

    mov  r6, @-10(r8)          ; Save them.
    mov  r7, @-8(r8)

    a    r4, r5                ; Distance range roughly 0..255.
    srl  r5, 3                 ; Sound frame range roughly 0..31.
    .play_noise_frame sound_drone, sound_drone_frames, r5
    ci   r5, 16                ; Don't lock the noise channel if the drone is
    jl   !                     ; far away.
    seto @current_noise
!
    b    @update_drone_loop
update_drone_loop_end

* Update the turret states and directions.
    li   r6, turrets

update_turret_loop
    mov  *r6+, r0              ; Get the x ordinate.
    jlt  update_turret_loop_end ; Is it the last turret?
    mov  *r6+, r1              ; Get the y ordinate.
    mov  *r6+, r2              ; Get the direction.
    jlt  update_turret_loop    ; Is it inactive?

    ci   r2, exploding         ; Is the turret already exploding?
    jhe  explode_turret

check_turret_player
    .dist @player_x, r0, r4, 128+20 ; Is it very far?
    jgt  update_turret_loop    ; Then continue with the next turret.
    .dist @player_y, r1, r5, 96+20
    jgt  update_turret_loop

    ci   r4, 40                ; Is it very near?
    jgt  check_turret_emp      ; Then let the turret explode.
    ci   r5, 20
    jlt  explode_turret

check_turret_emp
    .dist @emp_x, r0, r4, 20   ; Is it close to the EMP?
    jgt  update_turret_direction
    .dist @emp_y, r1, r5, 32
    jgt  update_turret_direction

explode_turret
    ai   r2, exploding         ; Let the turret explode, automatically
    mov  r2,@-2(r6)            ; disabling it at the end.
    jlt  update_turret_loop

    srl  r2, 11                ; Compute the sound frame of the explosion.
    .play_noise_frame sound_explosion, sound_explosion_frames, r2
    jmp  update_turret_loop

update_turret_direction
    s    @player_x, r0         ; Compute the direction vector.
    s    @player_y, r1

    neg  r0                    ; Pointing from the turret to the player.
    neg  r1

    bl   @adjust_projected_direction ; Update the direction.
    mov  r2, @-2(r6)           ; Save it.

    mov  @bullet_x, r0         ; Don't we have a bullet flying?
    jgt  update_turret_loop

    mov  @-6(r6), @bullet_x    ; Then fire a new bullet.
    mov  @-4(r6), @bullet_y
    clr  @bullet_fx
    clr  @bullet_fy
    mov  r2, @bullet_direction

    jmp  update_turret_loop
update_turret_loop_end

* Update the bullet state and position.
    mov  @bullet_x, r0
    jlt  update_bullet_end     ; Is it inactive?
    mov  @bullet_y, r1

    .dist @player_x, r0, r2, 128+10 ; Is the bullet far from the player?
    jgt  disable_bullet        ; Then disable the bullet.
    .dist @player_y, r1, r3, 96+10
    jgt  disable_bullet

    ci   r2, 40                ; Is it very near?
    jgt  update_bullet_position
    ci   r3, 20
    jgt  update_bullet_position

    bl   @kill_player           ; Then kill the player.

disable_bullet                 ; Disable the bullet.
    seto @bullet_x

    .stop_noise sound_bullet   ; Stop the bullet noise.
    jmp  update_bullet_end

update_bullet_position
    mov  @bullet_direction, r4 ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @bullet_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @bullet_fy

    mov  r0, @bullet_x         ; Save them.
    mov  r1, @bullet_y

    a    r2, r3                ; Distance range roughly 0..255.
    srl  r3, 4                 ; Sound frame range roughly 0..15.
    .play_noise_frame sound_bullet, sound_bullet_frames, r3

update_bullet_end

    .endm
