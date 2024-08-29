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

* Macros to work with 16-bits and 32-bits ordinates.

* Macro: compare the distance between two 16-bits integer ordinates against a
* given value.
* IN          #1: the first ordinate.
* IN OPTIONAL #2: the second ordinate (default: #3).
* IN          #3: a temporary register.
* IN          #4: the constant distance to compare to.
* OUT         status register: the result of the comparison.
    .defm dist
    .ifdef #3
      mov  #2, #3
      s    #1, #3
      abs  #3
      ci   #3, #4
    .else
      s    #1, #2
      abs  #2
      ci   #2, #3
    .endif
    .endm

* Macro: adjust the 16.16-bits fixed point ordinate with a given delta.
* IN OUT #1: the register with the base address of the delta and the
*            fractional delta.
* IN OUT #2: the integer part of the ordinate.
* IN OUT #3: the fractional part of the ordinate.
    .defm update_ordinate
    a    *#1+, #2              ; Update the integer part.
    a    *#1+, #3              ; Update the fractional part.
    jnc  !
    inc  #2                    ; Take care of the carry bit.
!
    .endm
