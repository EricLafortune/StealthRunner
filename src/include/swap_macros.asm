* Useful assembly definitions for the TI-99/4A home computer.
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

* Macros to swap bytes of a word.

* Macro: data instruction with a swapped word.
* IN #1: the data.
    .defm data_swapped
    data (#1 % 256 * 256) + (#1 / 256)
    .endm

* Macro: li instruction with a swapped word.
* IN #1: the register number.
* IN #2: the data.
    .defm li_swapped
    li   #1, (#2 % 256 * 256) + (#2 / 256)
    .endm
