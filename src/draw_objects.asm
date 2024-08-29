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

* Draw the drones (supersprites, high priority).
    li   r8, drones

draw_drone_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_drone_loop_end   ; Is it the last drone?
    mov  *r8+, r3              ; Get the y ordinate.
    ai   r8, 4                 ; Skip the fractional ordinates.
    mov  *r8+, r1              ; Get the direction.
    jlt  draw_drone_loop       ; Is it inactive?

    ab   r1, r1                ; Compute the drone sprite number.
    src  r1, 12
    ai   r1, drone_sprites

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite

    jmp  draw_drone_loop
draw_drone_loop_end

* Draw the turrets (supersprites, high priority).
    li   r8, turrets

draw_turret_loop
    mov  *r8+, r12             ; Get the x ordinate.
    jlt  draw_turret_loop_end  ; Is it the last turret?
    mov  *r8+, r13             ; Get the y ordinate.

    mov  *r8+, r1              ; Get the direction.
    jlt  draw_turret_loop      ; Is it inactive?

    ab   r1, r1                ; Compute the turret sprite number.
    src  r1, 12
    ai   r1, turret_sprites

    mov  r12, r2               ; Draw the turret.
    mov  r13, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_supersprite

    jmp  draw_turret_loop
draw_turret_loop_end

* Draw the bullet, if any (supersprites, medium priority).
draw_bullet
    mov  @bullet_x, r2
    jlt  draw_bullet_end       ; Is it inactive?
    mov  @bullet_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  @bullet_direction, r1 ; Compute the bullet sprite number.
    ai   r1, bullet_sprites

    bl   @draw_supersprite
draw_bullet_end

* Draw the mines (supersprites, low priority).
    li   r8, mines

draw_mine_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_mine_loop_end    ; Is it the last mine?
    mov  *r8+, r3              ; Get the y ordinate.
    mov  *r8+, r1              ; Get the explosion state.
    jlt  draw_mine_loop        ; Is it inactive?

    jeq  !                     ; Is it exploding?
    srl  r1, 11                ; Compute the explosion sprite number.
    ai   r1, explosion_sprite

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3
    jmp  !!
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
    bl   @draw_supersprite

    jmp  draw_mine_loop
draw_mine_loop_end

* Draw the target (supersprite, low priority).
    mov  @target_x, r2
    mov  @target_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    li   r1, target_sprite

    bl   @draw_small_supersprite

* Draw the batteries (supersprites, low priority).
    li   r8, batteries

draw_battery_loop
    mov  *r8+, r2              ; Get the x ordinate.
    jlt  draw_battery_loop_end ; Is it the last battery?
    mov  *r8+, r3              ; Get the y ordinate.
    jlt  draw_battery_loop     ; Is it inactive?

    li   r1, battery_sprite

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    bl   @draw_small_supersprite

    jmp  draw_battery_loop
draw_battery_loop_end

* Draw the Electro-Magnetic Pulse, if any (supersprite, low priority).
draw_emp
    mov  @emp_x, r2
    jlt  draw_emp_end          ; Is it inactive?
    mov  @emp_y, r3

    s    @player_x, r2         ; Get the coordinates in screen space.
    s    @player_y, r3

    mov  @emp_direction, r1
    ai   r1, emp_sprites

    bl   @draw_small_supersprite
draw_emp_end

* Draw the battery charge meter, if any (supersprite, low priority).
draw_charge
    mov  @charge_frame, r1
    jlt  draw_charge_end       ; Is it inactive?

    mov  @charge_count, r1     ; Set the supersprite.
    ci   r1, 6
    jl   !
    li   r1, 6
!   ai   r1, charge_sprites

    clr  r2                    ; Set the coordinates in screen space.
    clr  r3

    bl   @draw_small_supersprite
draw_charge_end

* End the list of sprites.
    li   r1, sprite_attribute_table_terminator * 256
    .vdpwd r1

* Write any quadsprites that the supersprite drawing code has queued.
    bl @write_quadsprites

    .endm
