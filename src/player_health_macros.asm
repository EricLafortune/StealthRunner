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

* Macros to change the player health (heal and damage).

* The start values of the player health intervals.
player_dead       equ >ffff
player_wounded    equ >0000
player_exhausted  equ >0100
player_tired      equ >0200
player_healthy    equ >0300
player_max_health equ >03ff


* Macro: heal the player.
* IN #1: the change to be added to the health.
* LOCAL r0
* LOCAL r1
* LOCAL r11
    .defm heal_player

    mov  @player_health, r1    ; Compute the new health.
    ai   r1, #1
    ci   r1, player_max_health ; Clip to the maximum health.
    jlt  !
    li   r1, player_max_health
!
    bl   @set_player_health

    .endm

* Macro: damage the player.
* IN #1: the damage to be subtracted from the health.
* LOCAL r0
* LOCAL r1
* LOCAL r3 (not r2)
* LOCAL r4
* LOCAL r11
    .defm damage_player

    mov  @player_health, r1    ; Compute the new health.
    ai   r1, -#1
    jgt  !                     ; Clip to the minimum health.
    jeq  !
    seto r1
!
    bl   @set_player_health

    .endm
