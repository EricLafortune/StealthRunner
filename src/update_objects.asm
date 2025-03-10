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
* OUT emp_x
* OUT emp_y
* OUT emp_direction
* OUT targets
* OUT stones
* OUT batteries
* OUT mines
* OUT drones
* OUT launchers
* OUT turrets
* OUT bullet_x
* OUT bullet_y
* OUT bullet_direction
* OUT grenade_x
* OUT grenade_y
* OUT grenade_fx
* OUT grenade_fy
* OUT grenade_counter
* LOCAL r0
* LOCAL r1
* LOCAL r2
    .defm initialize_objects

    clr  @stone_count
    clr  @emp_count
    seto @emp_x
    seto @bullet_x
    seto @grenade_x
    seto @hud_counter

* Initialize the object lists of all horizontal strips.
    clr  r1

initialize_object_strip_loop

* Initialize the target positions.
    li   r2, targets
    a    r1, r2

initialize_target_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_target_loop_end ; Is it the last target?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    jmp  initialize_target_loop
initialize_target_loop_end

* Initialize the bush positions.
    li   r2, bushes
    a    r1, r2

initialize_bush_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_bush_loop_end ; Is it the last bush?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    jmp  initialize_bush_loop
initialize_bush_loop_end

* Initialize the tree positions.
    li   r2, trees
    a    r1, r2

initialize_tree_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_tree_loop_end ; Is it the last tree?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    jmp  initialize_tree_loop
initialize_tree_loop_end

* Initialize the stone positions.
    li   r2, stones
    a    r1, r2

initialize_stone_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_stone_loop_end ; Is it the last stone?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    jmp  initialize_stone_loop
initialize_stone_loop_end

* Initialize the battery positions.
    li   r2, batteries
    a    r1, r2

initialize_battery_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_battery_loop_end ; Is it the last battery?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    jmp  initialize_battery_loop
initialize_battery_loop_end

* Initialize the mine positions and states.
    li   r2, mines
    a    r1, r2

initialize_mine_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_mine_loop_end ; Is it the last mine?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    clr  *r2+                  ; Initialize the explosion.
    jmp  initialize_mine_loop
initialize_mine_loop_end

* Initialize the drone positions and directions.
    li   r2, drones
    a    r1, r2

initialize_drone_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_drone_loop_end ; Is it the last drone?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    clr  *r2+                  ; Clear the fractional x ordinate.
    clr  *r2+                  ; Clear the fractional y ordinate.
    clr  *r2+                  ; Initialize the direction.
    jmp  initialize_drone_loop
initialize_drone_loop_end

* Initialize the grenade launcher positions.
    li   r2, launchers
    a    r1, r2

initialize_launcher_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_launcher_loop_end ; Is it the last launcher?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    clr  *r2+                  ; Initialize the explosion.
    jmp  initialize_launcher_loop
initialize_launcher_loop_end

* Initialize the turret positions and directions.
    li   r2, turrets
    a    r1, r2

initialize_turret_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_turret_loop_end ; Is it the last turret?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    clr  *r2+                  ; Initialize the direction.
    jmp  initialize_turret_loop
initialize_turret_loop_end

* Repeat for the next strip, if any.
    ai   r1, object_strip_size
    ci   r1, object_strip_count * object_strip_size
    jl   initialize_object_strip_loop

    .endm


* One-time macro: update the objects in the world.
* IN OUT emp_x
* IN OUT emp_y
* IN OUT emp_direction
* IN OUT stones
* IN OUT batteries
* IN OUT mines
* IN OUT drones
* IN OUT launchers
* IN OUT turrets
* IN OUT bullet_x
* IN OUT bullet_y
* IN OUT bullet_direction
* IN OUT grenade_x
* IN OUT grenade_y
* IN OUT grenade_fx
* IN OUT grenade_fy
* IN OUT grenade_counter
* IN     player_x
* IN     player_y
* LOCAL r0-r15
    .defm update_objects

    .switch_bank @data_bank    ; The motion deltas and sounds are in the data
                               ; bank.

* Update the EMP state and position.
update_emp
    mov  @emp_x, r0
    jlt  update_emp_end        ; Is it inactive?
    mov  @emp_y, r1

    mov  @emp_counter, r2      ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jl   update_emp_position

disable_emp
    seto @emp_x                ; Then disable it.

    .stop_tone0 sound_emp      ; Stop the EMP sound.
    jmp  update_emp_end

update_emp_position
    mov  @emp_direction, r4    ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @emp_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @emp_fy

    mov  r0, @emp_x            ; Save them.
    mov  r1, @emp_y

update_emp_sound
    .play_tone0_frame sound_emp, sound_emp_frames, r2

update_emp_counter
    inc  @emp_counter

update_emp_end


* Update the object lists of all surrounding horizontal strips.
    .first_object_strip r9
    .last_object_strip r10

update_object_strip_loop

* Check if the player has reached a target.
    li   r8, targets
    a    r9, r8

update_target_loop
    mov  *r8+, r0             ; Get the x ordinate.
    jlt  update_target_loop_end ; Is it the last target?
    mov  *r8+, r1             ; Get the y ordinate.
    jlt  update_target_loop   ; Is it inactive?

check_target_player
    .dist @player_x, r0, r2, 20 ; Is it close to the player?
    jgt  update_target_loop
    .dist @player_y, r1, r3, 40
    jgt  update_target_loop

    mov  r0, @latest_target_x  ; Remember the target position.
    mov  r1, @latest_target_y

    seto @-2(r8)               ; Disable the target.

    .start_speech speech_ahohe ; Start singing.

    jmp  update_target_loop

update_target_loop_end

* Update the stone states.
    li   r8, stones
    a    r9, r8

update_stone_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_stone_loop_end ; Is it the last stone?
    mov  *r8+, r1              ; Get the y ordinate.
    jlt  update_stone_loop     ; Is it inactive?

check_stone_player
    .dist @player_x, r0, 20    ; Is it close to the player?
    jgt  update_stone_loop
    .dist @player_y, r1, 40
    jgt  update_stone_loop

    mov  @stone_count, r1      ; Then increment the number of available stones.
    inc  r1
    mov  r1, @stone_count

    ci   r1, 6                 ; Set the supersprite.
    jle  !
    li   r1, 6
!   ai   r1, stone_counter_sprites-1
    mov  r1, @hud_sprite
    clr  @hud_counter

    seto @-2(r8)               ; Disable the stone.
    jmp  update_stone_loop

update_stone_loop_end

* Update the battery states.
    li   r8, batteries
    a    r9, r8

update_battery_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_battery_loop_end ; Is it the last battery?
    mov  *r8+, r1              ; Get the y ordinate.
    jlt  update_battery_loop   ; Is it inactive?

check_battery_player
    .dist @player_x, r0, 20    ; Is it close to the player?
    jgt  update_battery_loop
    .dist @player_y, r1, 40
    jgt  update_battery_loop

    mov  @emp_count, r1        ; Then increment the number of available EMPs.
    inc  r1
    mov  r1, @emp_count

    ci   r1, 6                 ; Set the supersprite.
    jle  !
    li   r1, 6
!   ai   r1, charge_sprites
    mov  r1, @hud_sprite
    clr  @hud_counter

    seto @-2(r8)               ; Disable the battery.
    jmp  update_battery_loop

update_battery_loop_end

* Update the mine states.
    li   r8, mines
    a    r9, r8

update_mine_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_mine_loop_end  ; Is it the last mine?
    mov  *r8+, r1              ; Get the y ordinate.
    mov  *r8+, r2              ; Get the sprite.
    jlt  update_mine_loop      ; Is it inactive?

    jh   update_mine_explosion ; Is the mine already exploding?

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
    jmp  update_mine_explosion ; And let the mine explode.

check_mine_emp
    .dist @emp_x, r0, 16       ; Is it close to the EMP?
    jgt  update_mine_loop
    .dist @emp_y, r1, 16
    jgt  update_mine_loop

update_mine_explosion
    mov  r2, r3                ; Compute the sound frame of the explosion.
    srl  r3, 11
    .play_noise_frame sound_explosion, sound_explosion_frames, r3

    ai   r2, exploding         ; Let the mine explode, automatically
    mov  r2,@-2(r8)            ; disabling it at the end.
    jmp  update_mine_loop

update_mine_loop_end

* Update the drone states, positions, and directions.
    li   r8, drones
    a    r9, r8

update_drone_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_drone_loop_end0 ; Is it the last drone?
    mov  *r8+, r1              ; Get the y ordinate.
    ai   r8, 4                 ; Skip the fractional ordinates.
    mov  *r8+, r2              ; Get the direction.
    jlt  update_drone_loop     ; Is it inactive?

    ci   r2, exploding         ; Is the drone already exploding?
    jhe  update_drone_explosion

check_drone_player
    .dist @player_x, r0, r4, 128+16 ; Is it far away?
    jgt  update_drone_loop     ; Then continue with the next drone.
    .dist @player_y, r1, r5, 96+16
    jgt  update_drone_loop

check_drone_player_hit
    ci   r4, 40                ; Is the drone very near the player?
    jgt  update_drone_direction
    ci   r5, 20
    jgt  update_drone_direction

    bl   @kill_player          ; Then kill the player.
    jmp  update_drone_explosion ; And let the drone explode.

update_drone_loop_end0         ; Bridging a long jump.
    jmp  update_drone_loop_end

update_drone_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @player_x, r0         ; Compute the direction vector, pointing from
    mov  @player_y, r1         ; the drone to the player.

    s    r6, r0
    s    r7, r1

    bl   @adjust_projected_direction ; Update the direction (clobbers r3).
    mov  r2, @-2(r8)           ; Save it.

update_drone_position
    mov  r2, r3                ; Compute the delta entry adress.
    sla  r3, 3
    ai   r3, delta_forward_slow

    .update_ordinate r3, r6, @-6(r8) ; Adjust the coordinates.
    .update_ordinate r3, r7, @-4(r8)

    mov  r6, @-10(r8)          ; Save them.
    mov  r7, r3                ; However, check that the y ordinate is still
    .check_object_strip r3, r9 ; in the same strip.
    jne  update_drone_sound
    mov  r7, @-8(r8)

update_drone_sound
    a    r4, r5                ; Distance range roughly 0..255.
    srl  r5, 3                 ; Sound frame range roughly 0..31.
    .play_noise_frame sound_drone, sound_drone_frames, r5 ; (clobbers r0, r1)
    ci   r5, 16                ; Don't lock the noise channel if the drone is
    jl   check_drone_emp       ; far away.
    seto @current_noise

check_drone_emp
    .dist @emp_x, r6, 20       ; Is it close to the EMP?
    jgt  update_drone_loop     ; Then let the drone explode.
    .dist @emp_y, r7, 32
    jgt  update_drone_loop

update_drone_explosion
    mov  r2, r3                ; Compute the sound frame of the explosion.
    srl  r3, 11
    .play_noise_frame sound_explosion, sound_explosion_frames, r3

    ai   r2, exploding         ; Let the drone explode, automatically
    mov  r2, @-2(r8)           ; disabling it at the end.

update_drone_loop0
    b    @update_drone_loop

update_drone_loop_end

* Update the turret states and directions.
    li   r8, turrets
    a    r9, r8

update_turret_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_turret_loop_end ; Is it the last turret?
    mov  *r8+, r1              ; Get the y ordinate.
    mov  *r8+, r2              ; Get the direction.
    jlt  update_turret_loop    ; Is it inactive?

    ci   r2, exploding         ; Is the turret already exploding?
    jhe  update_turret_explosion

check_turret_player
    .dist @player_x, r0, r4, 128+16 ; Is it far away?
    jgt  update_turret_loop    ; Then continue with the next turret.
    .dist @player_y, r1, r5, 96+16
    jgt  update_turret_loop

    mov  @player_speed, r3     ; What is the player doing?
    jlt  check_turret_emp      ; Is the player dead?
    jeq  check_turret_player_near ; Is the player standing?
    srl  r3, 1                 ; Is the player running?
    jnc  check_turret_player_hit ; Then let the turret track the player.

check_turret_player_near
    ci   r4, 96                ; Is the turret somewhat near?
    jgt  check_turret_emp      ; Otherwise leave it unchanged.
    ci   r5, 64
    jgt  check_turret_emp

check_turret_player_hit
    ci   r4, 40                ; Is the turret very near?
    jgt  update_turret_direction ; Then let the turret explode.
    ci   r5, 20
    jlt  update_turret_explosion

update_turret_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @player_x, r0         ; Compute the direction vector, pointing from
    mov  @player_y, r1         ; the turret to the player.

    s    r6, r0
    s    r7, r1

    bl   @adjust_projected_direction ; Update the direction (clobbers r3).
    mov  r2, @-2(r8)           ; Save it.

    mov  r6, r0                ; Restore the absolute position.
    mov  r7, r1

fire_turret_bullet
    mov  @bullet_x, r3         ; Don't we have a bullet flying?
    jgt  check_turret_emp

    mov  r0, @bullet_x         ; Then fire a new bullet.
    mov  r1, @bullet_y
    clr  @bullet_fx
    clr  @bullet_fy
    mov  r2, @bullet_direction
    clr  @bullet_counter

check_turret_emp
    .dist @emp_x, r0, 20       ; Is it close to the EMP?
    jgt  update_turret_loop    ; Then let the turret explode.
    .dist @emp_y, r1, 32
    jgt  update_turret_loop

update_turret_explosion
    mov  r2, r3                ; Compute the sound frame of the explosion.
    srl  r3, 11
    .play_noise_frame sound_explosion, sound_explosion_frames, r3

    ai   r2, exploding         ; Let the turret explode, automatically
    mov  r2, @-2(r8)           ; disabling it at the end.
    jmp  update_turret_loop

update_turret_loop_end

* Update the grenade launcher states.
    li   r8, launchers
    a    r9, r8

update_launcher_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_launcher_loop_end ; Is it the last launcher?
    mov  *r8+, r1              ; Get the y ordinate.
    mov  *r8+, r2              ; Get the state.
    jlt  update_launcher_loop  ; Is it inactive?

    ci   r2, exploding         ; Is the launcher already exploding?
    jhe  update_launcher_explosion

check_launcher_player
    .dist @player_x, r0, r3, 128+20 ; Is it very far?
    jgt  update_launcher_loop  ; Then continue with the next launcher.
    .dist @player_y, r1, r4, 96+20
    jgt  update_launcher_loop

check_launcher_player_hit
    ci   r3, 40                ; Is it very near?
    jgt  fire_launcher_grenade ; Then let the launcher explode.
    ci   r4, 20
    jlt  update_launcher_explosion

fire_launcher_grenade
    mov  @grenade_x, r2        ; Don't we have a grenade flying?
    jgt  check_launcher_emp

    mov  r0, @grenade_x        ; Then fire a new grenade.
    mov  r1, @grenade_y
    clr  @grenade_fx
    clr  @grenade_fy

    mov  @player_x, r3         ; Compute the direction vector, pointing from
    mov  @player_y, r4         ; the launcher to the player.

    s    r0, r3
    s    r1, r4

    mov  r3, r5                ; Save a copy of the direction vector.
    mov  r4, r6

    sra  r3, 5                 ; The speed is 1/32th the direction vector.
    sra  r4, 5
    sla  r5, 11                ; Also compute the fractional part, by shifting
    sla  r6, 11                ; the computed bits in the other direction.

    mov  r3, @grenade_dx       ; Save the resulting fixed-point speed.
    mov  r4, @grenade_dy
    movb r5, @grenade_dfx
    movb r6, @grenade_dfy

    clr  @grenade_counter

check_launcher_emp
    .dist @emp_x, r0, 20       ; Is it close to the EMP?
    jgt  update_launcher_loop
    .dist @emp_y, r1, 32
    jgt  update_launcher_loop

update_launcher_explosion
    mov  r2, r3                ; Compute the sound frame of the explosion.
    srl  r3, 11
    .play_noise_frame sound_explosion, sound_explosion_frames, r3

    ai   r2, exploding         ; Let the launcher explode, automatically
    mov  r2,@-2(r8)            ; disabling it at the end.
    jmp  update_launcher_loop

update_launcher_loop_end

* Repeat for the next strip, if any.
    .next_object_strip r9, r10
    jh   !
    b    @update_object_strip_loop
!

* Update the bullet state and position.
    mov  @bullet_x, r0
    jlt  update_bullet_end     ; Is it inactive?
    mov  @bullet_y, r1

    mov  @bullet_counter, r2   ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jhe  disable_bullet

update_bullet_position
    mov  @bullet_direction, r4 ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @bullet_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @bullet_fy

    mov  r0, @bullet_x         ; Save them.
    mov  r1, @bullet_y

check_bullet_player
    .dist @player_x, r0, 40    ; Is the bullet near the player?
    jgt  update_bullet_sound
    .dist @player_y, r1, 20
    jgt  update_bullet_sound

    bl   @kill_player          ; Then kill the player.

disable_bullet
    seto @bullet_x             ; Disable the bullet.

    .stop_noise sound_bullet   ; Stop the bullet noise.
    jmp  update_bullet_end

update_bullet_sound
    .play_noise_frame sound_bullet, sound_bullet_frames, r2 ; (clobbers r0, r1)

update_bullet_counter
    inc  @bullet_counter

update_bullet_end

* Update the grenade state and position.
    mov  @grenade_x, r0
    jlt  update_grenade_end    ; Is it inactive?
    mov  @grenade_y, r1

    mov  @grenade_counter, r2  ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jl   update_grenade_position
    ci   r2, 36                ; Is it exploding?
    jl   check_grenade_player

disable_grenade
    seto @grenade_x            ; Disable the grenade.
    jmp  update_grenade_end

update_grenade_position
    a    @grenade_dx, r0       ; Adjust the coordinates.
    a    @grenade_dy, r1

    a    @grenade_dfx, @grenade_fx
    jnc  !
    inc  r0
!   a    @grenade_dfy, @grenade_fy
    jnc  !
    inc  r1
!
    mov  r2, r3
    sla  r3, 1                 ; Add a parabolic curve to the y ordinate.
    s    @parabolic_delta(r3), r1

    mov  r0, @grenade_x        ; Save them.
    mov  r1, @grenade_y

    .play_tone0_frame sound_grenade, sound_grenade_frames, r2
    jmp  update_grenade_counter

check_grenade_player
    .dist @player_x, r0, 40    ; Is the grenade near the player?
    jgt  update_grenade_explosion
    .dist @player_y, r1, 20
    jgt  update_grenade_explosion

    bl   @kill_player          ; Then kill the player.

update_grenade_explosion
    ai   r2, -32               ; Compute the sound frame of the explosion.
    .play_noise_frame sound_short_explosion, sound_short_explosion_frames, r2

update_grenade_counter
    inc  @grenade_counter

update_grenade_end

    .endm
