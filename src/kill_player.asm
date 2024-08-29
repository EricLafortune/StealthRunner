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

* Subroutine to kill the player, so the avatar falls and dies.

* Subroutine: kill the player.
* LOCAL r0
kill_player
    mov  @player_speed, r0     ; Is he already dead?
    jlt  !

    seto @player_speed         ; Kill the player.

    mov  @player_direction, r0 ; Update the cached player animation bank
    sla  r0, 1                 ; address.
    ai   r0, dying_player_animation_banks
    mov  r0, @player_animation_bank

    clr  @player_frame         ; Reset the player animation frame.

    .start_speech speech_argh
!
    rt


