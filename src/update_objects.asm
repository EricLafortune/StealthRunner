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

* One-time macro: initialize the objects lying around in the untouched world.
* IN r0: a pointer to the initial values.
* OUT stone_count
* OUT emp_count
* OUT grenade_count
* OUT stone_x
* OUT stone_y
* OUT stone_fx
* OUT stone_fy
* OUT stone_direction
* OUT stone_counter
* OUT emp_x
* OUT emp_y
* OUT emp_fx
* OUT emp_fy
* OUT emp_direction
* OUT grenade_x
* OUT grenade_y
* OUT grenade_fx
* OUT grenade_fy
* OUT grenade_direction
* OUT grenade_counter
* OUT targets
* OUT stones
* OUT batteries
* OUT mines
* OUT drones
* OUT launchers
* OUT turrets
* OUT collectibles
* OUT messages
* OUT background_objects
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

* Initialize the mine positions and states.
    li   r2, mines
    a    r1, r2

initialize_mine_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_mine_loop_end ; Is it the last mine?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    clr  *r2+                  ; Initialize the explosion state.
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
    clr  *r2+                  ; Initialize the explosion state.
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

* Initialize the collectible positions.
    li   r2, collectibles
    a    r1, r2

initialize_collectible_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_collectible_loop_end ; Is it the last collectible?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    mov  *r0+, *r2+            ; Copy the type.
    jmp  initialize_collectible_loop
initialize_collectible_loop_end

* Initialize the message positions and sprites.
    li   r2, messages
    a    r1, r2

initialize_message_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_message_loop_end ; Is it the last message?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    mov  *r0+, *r2+            ; Copy the supersprite number.
    jmp  initialize_message_loop
initialize_message_loop_end

* Initialize the background object positions and sprites.
    li   r2, background_objects
    a    r1, r2

initialize_background_object_loop
    mov  *r0+, *r2+            ; Copy the x ordinate.
    jlt  initialize_background_object_loop_end ; Is it the last object?
    mov  *r0+, *r2+            ; Copy the y ordinate.
    mov  *r0+, *r2+            ; Copy the supersprite number.
    jmp  initialize_background_object_loop
initialize_background_object_loop_end

* Repeat for the next strip, if any.
    ai   r1, object_strip_size
    ci   r1, object_strip_count * object_strip_size
    jl   initialize_object_strip_loop

    .endm


* Macro: save the states of the objects lying around in the world.
* IN  stone_count
* IN  emp_count
* IN  grenade_count
* IN  stone_x
* IN  stone_y
* IN  stone_fx
* IN  stone_fy
* IN  stone_direction
* IN  stone_counter
* IN  emp_x
* IN  emp_y
* IN  emp_fx
* IN  emp_fy
* IN  emp_direction
* IN  grenade_x
* IN  grenade_y
* IN  grenade_fx
* IN  grenade_fy
* IN  grenade_direction
* IN  grenade_counter
* IN  targets
* IN  stones
* IN  batteries
* IN  mines
* IN  drones
* IN  launchers
* IN  turrets
* IN  bullet_x
* IN  bullet_y
* IN  bullet_direction
* IN  grenade_x
* IN  grenade_y
* IN  grenade_fx
* IN  grenade_fy
* IN  grenade_counter
* OUT saved_object_states
* LOCAL r0
* LOCAL r1
    .defm save_object_states
    .copy_memory object_states, object_states_end, saved_object_states
    .endm


* Macro: restore the states of the objects lying around in the world.
* IN  saved_object_states
* OUT stone_count
* OUT emp_count
* OUT grenade_count
* OUT stone_x
* OUT stone_y
* OUT stone_fx
* OUT stone_fy
* OUT stone_direction
* OUT stone_counter
* OUT emp_x
* OUT emp_y
* OUT emp_fx
* OUT emp_fy
* OUT emp_direction
* OUT grenade_x
* OUT grenade_y
* OUT grenade_fx
* OUT grenade_fy
* OUT grenade_direction
* OUT grenade_counter
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
    .defm restore_object_states
    .copy_memory saved_object_states, saved_object_states+object_states_size, object_states
    .endm


* Macro: initialize the weapons that the player is carrying.
* OUT hud_counter
* OUT weapon
* OUT stone_count
* OUT emp_count
* OUT grenade_count
* LOCAL r1
    .defm initialize_player_weapons

    seto @hud_counter

    .ifdef initial_medkits
    li   r1, initial_medkits
    mov  r1, @medkit_count
    .else
    clr  @medkit_count
    .endif

    .ifdef initial_stones
    li   r1, initial_stones
    mov  r1, @stone_count
    .else
    clr  @stone_count
    .endif

    .ifdef initial_emps
    li   r1, initial_emps
    mov  r1, @emp_count
    .else
    clr  @emp_count
    .endif

    .ifdef initial_grenades
    li   r1, initial_grenades
    mov  r1, @grenade_count
    .else
    clr  @grenade_count
    .endif

    clr  @weapon

    .endm


* Macro: save the weapons that the player is carrying.
* OUT hud_counter
* OUT weapon
* OUT stone_count
* OUT emp_count
* OUT grenade_count
* OUT saved_player_weapon_states
* LOCAL r0
* LOCAL r1
    .defm save_player_weapon_states
    .copy_memory collectible_counts, collectible_counts_end, saved_collectible_counts
    .endm


* Macro: restore the weapons that the player is carrying.
* IN  saved_player_weapon_states
* OUT hud_counter
* OUT weapon
* OUT stone_count
* OUT emp_count
* OUT grenade_count
* LOCAL r0
* LOCAL r1
    .defm restore_player_weapon_states
    .copy_memory saved_collectible_counts, saved_collectible_counts+collectible_counts_size, collectible_counts
    .endm


* Macro: reset any player/enemy weapons that have been launched.
* OUT stone_x
* OUT stone_y
* OUT stone_fx
* OUT stone_fy
* OUT stone_direction
* OUT stone_counter
* OUT emp_x
* OUT emp_y
* OUT emp_fx
* OUT emp_fy
* OUT emp_direction
* OUT grenade_x
* OUT grenade_y
* OUT grenade_fx
* OUT grenade_fy
* OUT grenade_direction
* OUT grenade_counter
* OUT bullet_x
* OUT bullet_y
* OUT bullet_fx
* OUT bullet_fy
* OUT bullet_direction
* OUT bullet_counter
* OUT shell_x
* OUT shell_y
* OUT shell_fx
* OUT shell_fy
* OUT shell_dx
* OUT shell_dy
* OUT shell_dfx
* OUT shell_dfy
* OUT shell_counter
    .defm reset_launched_weapons

    seto @stone_state
    seto @emp_state
    seto @grenade_state

    seto @bullet_state
    seto @shell_state

    .endm


* One-time macro: update the objects in the world.
* IN OUT stone_x
* IN OUT stone_y
* IN OUT stone_fx
* IN OUT stone_fy
* IN OUT stone_direction
* IN OUT stone_counter
* IN OUT emp_x
* IN OUT emp_y
* IN OUT emp_fx
* IN OUT emp_fy
* IN OUT emp_direction
* IN OUT weapon
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

* Update the object lists of all visible horizontal strips.
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

    seto @-2(r8)               ; Disable the target.

    .save_player_state         ; Remember the current state.
    .save_player_weapon_states
    .save_object_states

    .start_music target_reached ; Play a jingle.

    jmp  update_target_loop

update_target_loop_end

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

    .damage_player >0280       ; Then damage the player.
    .start_speech speech_ah
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
    jhe  update_drone_explosion0

check_drone_stone
    .dist @stone_x, r0, r4, 128+16 ; Is it close to the thrown stone?
    jgt  check_drone_player
    .dist @stone_y, r1, r5, 96+16
    jgt  check_drone_player

update_drone_stone_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @stone_x, r0          ; Target the stone.
    mov  @stone_y, r1

    jmp  update_drone_direction ; We're ignoring the player entirely.

check_drone_player
    .dist @player_x, r0, r4, 128+16 ; Is it far away?
    jgt  update_drone_loop     ; Then continue with the next drone.
    .dist @player_y, r1, r5, 96+16
    jgt  update_drone_loop

check_drone_player_hit
    ci   r4, 40                ; Is the drone very near the player?
    jgt  update_drone_player_direction
    ci   r5, 20
    jgt  update_drone_player_direction

    .damage_player >0280       ; Then damage the player.
    .start_speech speech_ah

update_drone_explosion0
    jmp  update_drone_explosion ; And let the drone explode.

update_drone_loop_end0         ; Bridging a long jump.
    jmp  update_drone_loop_end

update_drone_player_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @player_x, r0         ; Target the player.
    mov  @player_y, r1

update_drone_direction
    s    r6, r0                ; Compute the direction vector, pointing from
    s    r7, r1                ; the turret to the player or the stone.

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
    jgt  update_drone_loop0    ; Then let the drone explode.
    .dist @emp_y, r7, 32
    jgt  update_drone_loop0

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
    jlt  update_turret_loop_end0 ; Is it the last turret?
    mov  *r8+, r1              ; Get the y ordinate.
    mov  *r8+, r2              ; Get the direction.
    jlt  update_turret_loop    ; Is it inactive?

    ci   r2, exploding         ; Is the turret already exploding?
    jhe  update_turret_explosion

check_turret_stone
    .dist @stone_x, r0, r4, 128+16 ; Is it close to the thrown stone?
    jgt  check_turret_player
    .dist @stone_y, r1, r5, 96+16
    jgt  check_turret_player

update_turret_stone_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @stone_x, r0          ; Target the stone.
    mov  @stone_y, r1

    jmp  update_turret_direction ; We're ignoring the player entirely.

update_turret_loop_end0
    jmp  update_turret_loop_end

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
    jgt  update_turret_player_direction
    ci   r5, 20
    jlt  update_turret_explosion ; Then let the turret explode.

update_turret_player_direction
    mov  r0, r6                ; Save a copy of the absolute position.
    mov  r1, r7

    mov  @player_x, r0         ; Target the player.
    mov  @player_y, r1

update_turret_direction
    s    r6, r0                ; Compute the direction vector, pointing from
    s    r7, r1                ; the turret to the player or the stone.

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
    b    @update_turret_loop

update_turret_loop_end

* Update the shell launcher states.
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

check_launcher_stone
    .dist @stone_x, r0, r4, 128+16 ; Is it close to the thrown stone?
    jgt  check_launcher_player
    .dist @stone_y, r1, r5, 96+16
    jgt  check_launcher_player

fire_launcher_stone_shell
    mov  @stone_x, r3          ; Target the stone.
    mov  @stone_y, r4

    jmp  fire_launcher_shell   ; We're ignoring the player entirely.

check_launcher_player
    .dist @player_x, r0, r3, 128+20 ; Is it very far?
    jgt  update_launcher_loop  ; Then continue with the next launcher.
    .dist @player_y, r1, r4, 96+20
    jgt  update_launcher_loop

check_launcher_player_hit
    ci   r3, 40                ; Is it very near?
    jgt  fire_launcher_player_shell
    ci   r4, 20
    jlt  update_launcher_explosion ; Then let the launcher explode.

fire_launcher_player_shell
    mov  @player_x, r3         ; Otherwise target the player.
    mov  @player_y, r4

fire_launcher_shell
    mov  @shell_x, r2          ; Don't we have a shell flying?
    jgt  check_launcher_emp

    mov  r0, @shell_x          ; Then fire a new shell.
    mov  r1, @shell_y
    clr  @shell_fx
    clr  @shell_fy

    s    r0, r3                ; Compute the direction vector, pointing from
    s    r1, r4                ; the turret to the player or the stone.

    mov  r3, r5                ; Save a copy of the direction vector.
    mov  r4, r6

    sra  r3, 5                 ; The speed is 1/32th the direction vector.
    sra  r4, 5
    sla  r5, 11                ; Also compute the fractional part, by shifting
    sla  r6, 11                ; the computed bits in the other direction.

    mov  r3, @shell_dx         ; Save the resulting fixed-point speed.
    mov  r4, @shell_dy
    movb r5, @shell_dfx
    movb r6, @shell_dfy

    clr  @shell_counter

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

* Update the collectible states.
    li   r8, collectibles
    a    r9, r8

update_collectible_loop
    mov  *r8+, r0              ; Get the x ordinate.
    jlt  update_collectible_loop_end ; Is it the last collectible?
    mov  *r8+, r1              ; Get the y ordinate.
    mov  *r8+, r2              ; Get the type.
    jlt  update_collectible_loop     ; Is it inactive?

check_collectible_player
    .dist @player_x, r0, 20    ; Is it close to the player?
    jgt  update_collectible_loop
    .dist @player_y, r1, 40
    jgt  update_collectible_loop

    sla  r2, 1
    mov  @collectible_counts(r2), r1 ; Then increment the number of available
    inc  r1                     ; collectibles.
    mov  r1, @collectible_counts(r2)

    ci   r1, 7                 ; Compute and set the supersprite.
    jle  !                     ; based on the (clamped) count...
    li   r1, 7
!   sla  r2, 2                 ; ...and the type.
    a    r2, r1
    ai   r1, collectible_counter_sprites
    mov  r1, @hud_sprite
    clr  @hud_counter

    seto @-2(r8)               ; Disable the collectible.
    jmp  update_collectible_loop

update_collectible_loop_end

* Repeat for the next strip, if any.
    .next_object_strip r9, r10
    jh   !
    b    @update_object_strip_loop
!


* Update the thrown stone state and position, if any.
update_stone
    mov  @stone_x, r0
    jlt  update_stone_end      ; Is it inactive?
    mov  @stone_y, r1

    mov  @stone_counter, r2    ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jl   update_stone_position
    ci   r2, 36                ; Is it landing?
    jl   update_stone_landing
    ci   r2, 100               ; Is it still lying there?
    jl   update_stone_counter

disable_stone
    seto @stone_x              ; Disable the stone.
    jmp  update_stone_end

update_stone_position
    mov  @stone_direction, r4  ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @stone_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @stone_fy

    mov  r2, r3
    sla  r3, 1                 ; Add a parabolic curve to the y ordinate.
    s    @low_parabolic_delta(r3), r1

    mov  r0, @stone_x          ; Save them.
    mov  r1, @stone_y

    .play_tone2_frame sound_stone, sound_stone_frames, r2

    jmp  update_stone_counter

update_stone_landing
    ai   r2, -32               ; Compute the sound frame of the landing.
    .play_noise_frame sound_stone_landing, sound_stone_landing_frames, r2

update_stone_counter
    inc  @stone_counter

update_stone_end

* Update the fired EMP state and position, if any.
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
    .play_tone2_frame sound_emp, sound_emp_frames, r2

update_emp_counter
    inc  @emp_counter

update_emp_end

* Update the thrown grenade state and position, if any.
    mov  @grenade_x, r0
    jlt  update_grenade_end0   ; Is it inactive?
    mov  @grenade_y, r1

    mov  @grenade_counter, r2  ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jl   update_grenade_position
    jeq  check_grenade_objects ; Is it landing and exploding?
    ci   r2, 40                ; Is it exploding?
    jhe  disable_grenade
    b    @update_grenade_explosion

disable_grenade
    seto @grenade_x            ; Disable the grenade.
update_grenade_end0
    b    @update_grenade_end

update_grenade_position
    mov  @grenade_direction, r4 ; Compute the delta entry adress.
    sla  r4, 3
    ai   r4, delta_forward_fast

    .update_ordinate r4, r0, @grenade_fx ; Adjust the coordinates.
    .update_ordinate r4, r1, @grenade_fy

    mov  r2, r3
    sla  r3, 1                 ; Add a parabolic curve to the y ordinate.
    s    @low_parabolic_delta(r3), r1

    mov  r0, @grenade_x        ; Save them.
    mov  r1, @grenade_y

    .play_tone2_frame sound_grenade, sound_grenade_frames, r2

    b    @update_grenade_counter

check_grenade_objects

    .object_strip r1, -32, r9  ; Check the object lists of all horizontal
    .object_strip r1, 32, r10  ; strips surrounding the exploding grenade.

check_grenade_objects_strip_loop

    li   r8, mines             ; Check all nearby mines.
    a    r9, r8

check_grenade_mine_loop
    mov  *r8+, r3              ; Get the x ordinate.
    jlt  check_grenade_mine_loop_end ; Is it the last mine?
    mov  *r8+, r4              ; Get the y ordinate.
    mov  *r8+, r5              ; Get the explosion state.
    jne  check_grenade_mine_loop ; Is it inactive?

    .dist r0, r3, 24           ; Is it close to the landing grenade?
    jgt  check_grenade_mine_loop
    .dist r1, r4, 24
    jgt  check_grenade_mine_loop

    ai   r5, exploding         ; Let the mine explode.
    mov  r5, @-2(r8)
    jmp  check_grenade_mine_loop

check_grenade_mine_loop_end

    li   r8, drones            ; Check all nearby drones.
    a    r9, r8

check_grenade_drone_loop
    mov  *r8+, r3              ; Get the x ordinate.
    jlt  check_grenade_drone_loop_end ; Is it the last drone?
    mov  *r8+, r4              ; Get the y ordinate.
    ai   r8, 4                 ; Skip the fractional coordinates.
    mov  *r8+, r5              ; Get the direction.
    jlt  check_grenade_drone_loop ; Is it inactive?

    .dist r0, r3, 32           ; Is it close to the landing grenade?
    jgt  check_grenade_drone_loop
    .dist r1, r4, 32
    jgt  check_grenade_drone_loop

    ai   r5, exploding         ; Let the drone explode.
    mov  r5, @-2(r8)
    jmp  check_grenade_drone_loop

check_grenade_drone_loop_end

    li   r8, turrets           ; Check all nearby turrets.
    a    r9, r8

check_grenade_turret_loop
    mov  *r8+, r3              ; Get the x ordinate.
    jlt  check_grenade_turret_loop_end ; Is it the last turret?
    mov  *r8+, r4              ; Get the y ordinate.
    mov  *r8+, r5              ; Get the direction.
    jlt  check_grenade_turret_loop ; Is it inactive?

    .dist r0, r3, 32           ; Is it close to the landing grenade?
    jgt  check_grenade_turret_loop
    .dist r1, r4, 32
    jgt  check_grenade_turret_loop

    ai   r5, exploding         ; Let the turret explode.
    mov  r5, @-2(r8)
    jmp  check_grenade_turret_loop

check_grenade_turret_loop_end

    li   r8, launchers         ; Check all nearby launchers.
    a    r9, r8

check_grenade_launcher_loop
    mov  *r8+, r3              ; Get the x ordinate.
    jlt  check_grenade_launcher_loop_end ; Is it the last launcher?
    mov  *r8+, r4              ; Get the y ordinate.
    mov  *r8+, r5              ; Get the explosion state.
    jne  check_grenade_launcher_loop ; Is it inactive?

    .dist r0, r3, 32           ; Is it close to the landing grenade?
    jgt  check_grenade_launcher_loop
    .dist r1, r4, 32
    jgt  check_grenade_launcher_loop

    ai   r5, exploding         ; Let the launcher explode.
    mov  r5, @-2(r8)
    jmp  check_grenade_launcher_loop

check_grenade_launcher_loop_end

    .next_object_strip r9, r10 ; Repeat for the next strip, if any.
    jle  check_grenade_objects_strip_loop

                               ; Continue after having checked the landed
                               ; grenade against all nearby objects.
update_grenade_explosion
    ai   r2, -32               ; Compute the sound frame of the explosion.
    .play_noise_frame sound_medium_explosion, sound_medium_explosion_frames, r2

update_grenade_counter
    inc  @grenade_counter

update_grenade_end


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

    .damage_player >0200       ; Then damage the player.
    .start_speech speech_ah

disable_bullet
    seto @bullet_x             ; Disable the bullet.

    .stop_noise sound_bullet   ; Stop the bullet noise.
    jmp  update_bullet_end

update_bullet_sound
    .play_noise_frame sound_bullet, sound_bullet_frames, r2 ; (clobbers r0, r1)

update_bullet_counter
    inc  @bullet_counter

update_bullet_end

* Update the shell state and position.
    mov  @shell_x, r0
    jlt  update_shell_end      ; Is it inactive?
    mov  @shell_y, r1

    mov  @shell_counter, r2    ; In which phase is it?
    ci   r2, 32                ; Is it flying?
    jl   update_shell_position
    ci   r2, 36                ; Is it exploding?
    jl   check_shell_player

disable_shell
    seto @shell_x              ; Disable the shell.
    jmp  update_shell_end

update_shell_position
    a    @shell_dx, r0         ; Adjust the coordinates.
    a    @shell_dy, r1

    a    @shell_dfx, @shell_fx
    jnc  !
    inc  r0
!   a    @shell_dfy, @shell_fy
    jnc  !
    inc  r1
!
    mov  r2, r3
    sla  r3, 1                 ; Add a parabolic curve to the y ordinate.
    s    @high_parabolic_delta(r3), r1

    mov  r0, @shell_x          ; Save them.
    mov  r1, @shell_y

    .play_tone2_frame sound_shell, sound_shell_frames, r2
    jmp  update_shell_counter

check_shell_player
    .dist @player_x, r0, 40    ; Is the shell near the player?
    jgt  update_shell_explosion
    .dist @player_y, r1, 20
    jgt  update_shell_explosion

    .damage_player >0200       ; Then damage the player.
    .start_speech speech_ah

update_shell_explosion
    ai   r2, -32               ; Compute the sound frame of the explosion.
    .play_noise_frame sound_short_explosion, sound_short_explosion_frames, r2

update_shell_counter
    inc  @shell_counter

update_shell_end

    .endm
