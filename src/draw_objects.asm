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

* Macros to draw the objects in the world.

* One-time macro: draw the objects in the world as supersprites.
* IN drones
* IN turrets
* IN bullet_x
* IN bullet_y
* IN bullet_direction
* IN mines
* IN target_x
* IN target_y
* IN batteries
* IN emp_x
* IN emp_y
* IN emp_direction
* IN charge_count
* IN charge_frame
* IN player_x
* IN player_y
* LOCAL r0-r15
    .defm draw_objects

* Start writing the entries of the sprite attribute table.
    .vdpwa game_sprite_attribute_table | vdp_write_bit

    li   r0, sprite_cache_queue

;    li   r1, parachute_sprite
;    clr  r2
;    clr  r3
;    bl   @draw_supersprite     ; Draw the parachute.

* Draw the launcher shell, if any (supersprite, high priority).
draw_shell
    mov  @shell_x, r2
    jlt  draw_shell_end        ; Is it inactive?
    mov  @shell_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  @shell_counter, r1    ; Is it exploding?
    ai   r1, -32
    jlt  !
    ai   r1, explosion_sprites ; Then compute the explosion sprite number.

    bl   @draw_supersprite     ; And draw the exploding shell.
    jmp  draw_shell_end

!   li   r1, shell_sprite      ; Otherwise draw the flying shell.
    bl   @draw_small_supersprite

draw_shell_end

* Draw the turret bullet, if any (supersprite, high priority).
draw_bullet
    mov  @bullet_x, r2
    jlt  draw_bullet_end       ; Is it inactive?
    mov  @bullet_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    li   r1, bullet_sprite     ; Draw the bullet.
    bl   @draw_small_supersprite

draw_bullet_end


* Draw the object lists of all surrounding horizontal strips.
    .first_object_strip r9
    .last_object_strip r10

draw_object_strip_loop

* Draw the drones (supersprites, high priority).
    li   r8, drones
    a    r9, r8

draw_drone_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_drone_loop_end   ; Is it the last drone?
    mov  *r8+, r3              ; Get the y ordinate.
    ai   r8, 4                 ; Skip the fractional ordinates.
    mov  *r8+, r1              ; Get the direction.
    jlt  draw_drone_loop       ; Is it inactive?

    ab   r1, r1                ; Compute the drone sprite number:
    src  r1, 12                ;   >780f -> >f00f -> >00ff -> number.
    ai   r1, drone_sprites

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite     ; Draw the drone.

    jmp  draw_drone_loop

draw_drone_loop_end

* Draw the turrets (supersprites, high priority).
    li   r8, turrets
    a    r9, r8

draw_turret_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_turret_loop_end  ; Is it the last turret?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the direction.
    jlt  draw_turret_loop      ; Is it inactive?

    ab   r1, r1                ; Compute the turret sprite number:
    src  r1, 12                ;   >780f -> >f00f -> >00ff -> number.
    ai   r1, turret_sprites

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite

    jmp  draw_turret_loop

draw_turret_loop_end

* Draw the launchers (supersprites, high priority).
    li   r8, launchers
    a    r9, r8

draw_launcher_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_launcher_loop_end ; Is it the last launcher?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the explosion state.
    jlt  draw_launcher_loop    ; Is it inactive?

    srl  r1, 11                ; Compute the launcher sprite number:
    ai   r1, launcher_sprites  ;   >7800 -> >000f -> number.
!
    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite

    jmp  draw_launcher_loop

draw_launcher_loop_end

* Draw the mines (supersprites, low priority).
    li   r8, mines
    a    r9, r8

draw_mine_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_mine_loop_end    ; Is it the last mine?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the explosion state.
    jlt  draw_mine_loop        ; Is it inactive?

    jeq  !                     ; Is it exploding?
    srl  r1, 11                ; Compute the explosion sprite number.
    ai   r1, explosion_sprites ;   >7800 -> >000f -> number.

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite     ; Draw the exploding mine.

    jmp  draw_mine_loop
!
    li   r1, mine_sprites      ; Compute the mine sprite number.

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  r2, r4                ; Is it close to the player?
    abs  r4
    ci   r4, 80
    jhe  !
    mov  r3, r4
    abs  r4
    ci   r4, 80
    jhe  !
    inc  r1                    ; Then fold out the mine's antennae.
!
    bl   @draw_small_supersprite ; Draw the unexploded mine.

    jmp  draw_mine_loop
draw_mine_loop_end

* Draw the targets (supersprites, low priority).
    li   r8, targets
    a    r9, r8

draw_target_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_target_loop_end  ; Is it the last target?
    mov  *r8+, r3              ; Get the y ordinate.
    jlt  draw_target_loop      ; Is it inactive?

    li   r1, target_sprite

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_small_supersprite

    jmp  draw_target_loop

draw_target_loop_end

* Draw the collectibles: stones, batteries, grenades (supersprites, low priority).
    li   r8, collectibles
    a    r9, r8

draw_collectible_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_collectible_loop_end ; Is it the last collectible?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the type.
    jlt  draw_collectible_loop ; Is it inactive?

    ai   r1, collectible_sprites ; Compute the supersprite number.

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_small_supersprite

    jmp  draw_collectible_loop

draw_collectible_loop_end

* Draw the background objects: grass, bushes,... (supersprites, low priority).
    li   r8, background_objects
    a    r9, r8

draw_background_object_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_background_object_loop_end ; Is it the last object?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the type.

    ;ai   r1, background_object_sprites ; Compute the supersprite number.
                               ; The offset is currently 0.

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite

    jmp  draw_background_object_loop

draw_background_object_loop_end

* Repeat for the next strip, if any.
    .next_object_strip r9, r10
    jh   !
    b    @draw_object_strip_loop
!


* Draw the message lists of all surrounding horizontal strips.
* We're drawing them in a separate loop, for tighter bounds,
* and so we can stop after the first message.
    .object_strip @player_y, -32, r9
    .object_strip @player_y, 32, r10

draw_message_strip_loop

* Draw the messages (supersprites, low priority).
    li   r8, messages
    a    r9, r8

draw_message_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_message_loop_end ; Is it the last object?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the number.

    .dist @player_x, r2, 32    ; Is it close to the player?
    jgt  draw_message_loop
    .dist @player_y, r3, 32
    jgt  draw_message_loop

    c    r1, @message_spoken   ; Has the message been spoken yet?
    jhe  draw_message
    .switch_bank @speech_data_bank ; The speech addresses are in the speech bank.
    mov  r1, r2                ; Play the spoken message.
    sla  r2, 1
    .start_speech @message_speech(r2), r3
    mov  r1, @message_spoken   ; Remember that the message has been spoken.

draw_message
    ai   r1, message_sprites   ; Compute the supersprite number.

    clr  r2                    ; Set the coordinates in screen space.
    clr  r3

    bl   @draw_supersprite_unchecked ; Draw this one message.
    jmp  draw_message_strip_loop_end

draw_message_loop_end

* Repeat for the next strip, if any.
    .next_object_strip r9, r10
    jle  draw_message_strip_loop

draw_message_strip_loop_end


* Draw the thrown stone, if any (supersprite, low priority).
draw_stone
    mov  @stone_x, r2
    jlt  draw_stone_end        ; Is it inactive?
    mov  @stone_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    li   r1, stone_sprite      ; Draw the flying or lying stone.
    bl   @draw_small_supersprite

draw_stone_end

* Draw the fired EMP, if any (supersprite, low priority).
draw_emp
    mov  @emp_x, r2
    jlt  draw_emp_end          ; Is it inactive?
    mov  @emp_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  @emp_direction, r1    ; Draw the EMP.
    andi r1, >000f
    ai   r1, emp_sprites

    bl   @draw_small_supersprite

draw_emp_end

* Draw the thrown grenade, if any (supersprite, low priority).
draw_grenade
    mov  @grenade_x, r2
    jlt  draw_grenade_end      ; Is it inactive?
    mov  @grenade_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  @grenade_counter, r1  ; Is it exploding?
    ai   r1, -32
    jlt  !
    ai   r1, explosion_sprites ; Then compute the explosion sprite number.

    bl   @draw_supersprite     ; And draw the exploding grenade.
    jmp  draw_grenade_end
!
    li   r1, grenade_sprite    ; Otherwise draw the flying grenade.
    bl   @draw_small_supersprite

draw_grenade_end

* Draw the HUD, if any (supersprite, low priority).
draw_hud
    mov  @hud_counter, r8
    jlt  draw_hud_end          ; Is it inactive?

    mov  @hud_sprite, r1       ; Draw the HUD sprite.
    clr  r2
    clr  r3

    bl   @draw_small_supersprite_unchecked

    inc  r8                    ; Update the HUD lifetime counter.
    ci   r8, 16
    jl   !
    seto r8
!   mov  r8, @hud_counter

draw_hud_end

* End the list of sprites.
draw_objects_sentinel
    li   r1, sprite_attribute_table_terminator * 256
    .vdpwd r1

* Write any quadsprites that the supersprite drawing code has queued.
draw_objects_quadsprites
    bl   @write_quadsprites

    .endm
