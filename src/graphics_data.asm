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

* Data for the game graphics.

* The hard-coded colors.
landscape_color equ light_green
player_color    equ blue

* The complete color table.
colors
    byte landscape_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black

    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black

    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black

    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black
    byte player_color * 16 + black

* The landscape patterns.

* A row corresponds to a given x ordinate.
* An offest in a row corresponds to a given y ordinate.
landscape_patterns_2dots
    text >0000001000000001, >0000001000000001
    text >0000002000000002, >0000002000000002
    text >0000004000000004, >0000004000000004
    text >0000008000000008, >0000008000000008
    text >0000000100000010, >0000000100000010
    text >0000000200000020, >0000000200000020
    text >0000000400000040, >0000000400000040
    text >0000000800000080, >0000000800000080

* A row corresponds to a given x ordinate.
* An offest in a row corresponds to a given y ordinate.
landscape_patterns_1dot
    text >0000001000000000, >0000001000000000
    text >0000002000000000, >0000002000000000
    text >0000004000000000, >0000004000000000
    text >0000008000000000, >0000008000000000
    text >0000000100000000, >0000000100000000
    text >0000000200000000, >0000000200000000
    text >0000000400000000, >0000000400000000
    text >0000000800000000, >0000000800000000

landscape_patterns_empty
    text >0000000000000000
