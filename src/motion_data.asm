* Game with motion-captured animation for the TI-99/4A home computer.
*
* Copyright (c) 2024-2025 Eric Lafortune
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

* Deltas on the x axis and the y axis for moving the player and objects in
* one of the discrete directions at one of the discrete speeds, in an angled
* perspecive (x to y ratio of sqrt(2)).
*
* Signed fixed point repesentation with an integer component and a fractional
* component (16.16 bits).
*
* Data entries: delta_x, fraction_delta_x, delta_y, fraction_delta_y

* Player motion.
delta_still
    data >0000, >0000, >0000, >0000 ;   0.0 degrees.
    data >0000, >0000, >0000, >0000 ;  22.5 degrees.
    data >0000, >0000, >0000, >0000 ;  45.0 degrees.
    data >0000, >0000, >0000, >0000 ;  67.5 degrees.
    data >0000, >0000, >0000, >0000 ;  90.0 degrees.
    data >0000, >0000, >0000, >0000 ; 112.5 degrees.
    data >0000, >0000, >0000, >0000 ; 135.0 degrees.
    data >0000, >0000, >0000, >0000 ; 157.5 degrees.
    data >0000, >0000, >0000, >0000 ; 180.0 degrees.
    data >0000, >0000, >0000, >0000 ; 202.5 degrees.
    data >0000, >0000, >0000, >0000 ; 225.0 degrees.
    data >0000, >0000, >0000, >0000 ; 247.5 degrees.
    data >0000, >0000, >0000, >0000 ; 270.0 degrees.
    data >0000, >0000, >0000, >0000 ; 292.5 degrees.
    data >0000, >0000, >0000, >0000 ; 315.0 degrees.
    data >0000, >0000, >0000, >0000 ; 337.5 degrees.

delta_forward_slow
    data >0000, >0000, >0000, >b505 ;   0.0 degrees.
    data >0000, >61f8, >0000, >a73d ;  22.5 degrees.
    data >0000, >b505, >0000, >8000 ;  45.0 degrees.
    data >0000, >ec83, >0000, >4546 ;  67.5 degrees.
    data >0001, >0000, >0000, >0000 ;  90.0 degrees.
    data >0000, >ec83, >ffff, >baba ; 112.5 degrees.
    data >0000, >b505, >ffff, >8000 ; 135.0 degrees.
    data >0000, >61f8, >ffff, >58c3 ; 157.5 degrees.
    data >0000, >0000, >ffff, >4afb ; 180.0 degrees.
    data >ffff, >9e08, >ffff, >58c3 ; 202.5 degrees.
    data >ffff, >4afb, >ffff, >8000 ; 225.0 degrees.
    data >ffff, >137d, >ffff, >baba ; 247.5 degrees.
    data >ffff, >0000, >0000, >0000 ; 270.0 degrees.
    data >ffff, >137d, >0000, >4546 ; 292.5 degrees.
    data >ffff, >4afb, >0000, >8000 ; 315.0 degrees.
    data >ffff, >9e08, >0000, >a73d ; 337.5 degrees.
delta_forward
    data >0000, >0000, >0001, >c48c ;   0.0 degrees.
    data >0000, >f4eb, >0001, >a21a ;  22.5 degrees.
    data >0001, >c48c, >0001, >4000 ;  45.0 degrees.
    data >0002, >4f48, >0000, >ad2f ;  67.5 degrees.
    data >0002, >8000, >0000, >0000 ;  90.0 degrees.
    data >0002, >4f48, >ffff, >52d1 ; 112.5 degrees.
    data >0001, >c48c, >fffe, >c000 ; 135.0 degrees.
    data >0000, >f4eb, >fffe, >5de6 ; 157.5 degrees.
    data >0000, >0000, >fffe, >3b74 ; 180.0 degrees.
    data >ffff, >0b15, >fffe, >5de6 ; 202.5 degrees.
    data >fffe, >3b74, >fffe, >c000 ; 225.0 degrees.
    data >fffd, >b0b8, >ffff, >52d1 ; 247.5 degrees.
    data >fffd, >8000, >0000, >0000 ; 270.0 degrees.
    data >fffd, >b0b8, >0000, >ad2f ; 292.5 degrees.
    data >fffe, >3b74, >0001, >4000 ; 315.0 degrees.
    data >ffff, >0b15, >0001, >a21a ; 337.5 degrees.

delta_backward_slow
    data >0000, >0000, >ffff, >783c ;   0.0 degrees.
    data >ffff, >b686, >ffff, >8292 ;  22.5 degrees.
    data >ffff, >783c, >ffff, >a000 ;  45.0 degrees.
    data >ffff, >4e9d, >ffff, >cc0c ;  67.5 degrees.
    data >ffff, >4000, >0000, >0000 ;  90.0 degrees.
    data >ffff, >4e9d, >0000, >33f4 ; 112.5 degrees.
    data >ffff, >783c, >0000, >6000 ; 135.0 degrees.
    data >ffff, >b686, >0000, >7d6e ; 157.5 degrees.
    data >0000, >0000, >0000, >87c4 ; 180.0 degrees.
    data >0000, >497a, >0000, >7d6e ; 202.5 degrees.
    data >0000, >87c4, >0000, >6000 ; 225.0 degrees.
    data >0000, >b163, >0000, >33f4 ; 247.5 degrees.
    data >0000, >c000, >0000, >0000 ; 270.0 degrees.
    data >0000, >b163, >ffff, >cc0c ; 292.5 degrees.
    data >0000, >87c4, >ffff, >a000 ; 315.0 degrees.
    data >0000, >497a, >ffff, >8292 ; 337.5 degrees.
delta_backward
    data >0000, >0000, >fffe, >f079 ;   0.0 degrees.
    data >ffff, >6d0d, >ffff, >0524 ;  22.5 degrees.
    data >fffe, >f079, >ffff, >4000 ;  45.0 degrees.
    data >fffe, >9d3b, >ffff, >9817 ;  67.5 degrees.
    data >fffe, >8000, >0000, >0000 ;  90.0 degrees.
    data >fffe, >9d3b, >0000, >67e9 ; 112.5 degrees.
    data >fffe, >f079, >0000, >c000 ; 135.0 degrees.
    data >ffff, >6d0d, >0000, >fadc ; 157.5 degrees.
    data >0000, >0000, >0001, >0f87 ; 180.0 degrees.
    data >0000, >92f3, >0000, >fadc ; 202.5 degrees.
    data >0001, >0f87, >0000, >c000 ; 225.0 degrees.
    data >0001, >62c5, >0000, >67e9 ; 247.5 degrees.
    data >0001, >8000, >0000, >0000 ; 270.0 degrees.
    data >0001, >62c5, >ffff, >9817 ; 292.5 degrees.
    data >0001, >0f87, >ffff, >4000 ; 315.0 degrees.
    data >0000, >92f3, >ffff, >0524 ; 337.5 degrees.

delta_strafe_left_slow
    data >0000, >e000, >0000, >0000 ;   0.0 degrees.
    data >0000, >cef3, >ffff, >c363 ;  22.5 degrees.
    data >0000, >9e64, >ffff, >9000 ;  45.0 degrees.
    data >0000, >55b9, >ffff, >6daa ;  67.5 degrees.
    data >0000, >0000, >ffff, >619c ;  90.0 degrees.
    data >ffff, >aa47, >ffff, >6daa ; 112.5 degrees.
    data >ffff, >619c, >ffff, >9000 ; 135.0 degrees.
    data >ffff, >310d, >ffff, >c363 ; 157.5 degrees.
    data >ffff, >2000, >0000, >0000 ; 180.0 degrees.
    data >ffff, >310d, >0000, >3c9d ; 202.5 degrees.
    data >ffff, >619c, >0000, >7000 ; 225.0 degrees.
    data >ffff, >aa47, >0000, >9256 ; 247.5 degrees.
    data >0000, >0000, >0000, >9e64 ; 270.0 degrees.
    data >0000, >55b9, >0000, >9256 ; 292.5 degrees.
    data >0000, >9e64, >0000, >7000 ; 315.0 degrees.
    data >0000, >cef3, >0000, >3c9d ; 337.5 degrees.
delta_strafe_left
    data >0002, >0000, >0000, >0000 ;   0.0 degrees.
    data >0001, >d907, >ffff, >7574 ;  22.5 degrees.
    data >0001, >6a0a, >ffff, >0000 ;  45.0 degrees.
    data >0000, >c3ef, >fffe, >b185 ;  67.5 degrees.
    data >0000, >0000, >fffe, >95f6 ;  90.0 degrees.
    data >ffff, >3c11, >fffe, >b185 ; 112.5 degrees.
    data >fffe, >95f6, >ffff, >0000 ; 135.0 degrees.
    data >fffe, >26f9, >ffff, >7574 ; 157.5 degrees.
    data >fffe, >0000, >0000, >0000 ; 180.0 degrees.
    data >fffe, >26f9, >0000, >8a8c ; 202.5 degrees.
    data >fffe, >95f6, >0001, >0000 ; 225.0 degrees.
    data >ffff, >3c11, >0001, >4e7b ; 247.5 degrees.
    data >0000, >0000, >0001, >6a0a ; 270.0 degrees.
    data >0000, >c3ef, >0001, >4e7b ; 292.5 degrees.
    data >0001, >6a0a, >0001, >0000 ; 315.0 degrees.
    data >0001, >d907, >0000, >8a8c ; 337.5 degrees.

delta_strafe_right_slow
    data >ffff, >2000, >0000, >0000 ;   0.0 degrees.
    data >ffff, >310d, >0000, >3c9d ;  22.5 degrees.
    data >ffff, >619c, >0000, >7000 ;  45.0 degrees.
    data >ffff, >aa47, >0000, >9256 ;  67.5 degrees.
    data >0000, >0000, >0000, >9e64 ;  90.0 degrees.
    data >0000, >55b9, >0000, >9256 ; 112.5 degrees.
    data >0000, >9e64, >0000, >7000 ; 135.0 degrees.
    data >0000, >cef3, >0000, >3c9d ; 157.5 degrees.
    data >0000, >e000, >0000, >0000 ; 180.0 degrees.
    data >0000, >cef3, >ffff, >c363 ; 202.5 degrees.
    data >0000, >9e64, >ffff, >9000 ; 225.0 degrees.
    data >0000, >55b9, >ffff, >6daa ; 247.5 degrees.
    data >0000, >0000, >ffff, >619c ; 270.0 degrees.
    data >ffff, >aa47, >ffff, >6daa ; 292.5 degrees.
    data >ffff, >619c, >ffff, >9000 ; 315.0 degrees.
    data >ffff, >310d, >ffff, >c363 ; 337.5 degrees.
delta_strafe_right
    data >fffe, >0000, >0000, >0000 ;   0.0 degrees.
    data >fffe, >26f9, >0000, >8a8c ;  22.5 degrees.
    data >fffe, >95f6, >0001, >0000 ;  45.0 degrees.
    data >ffff, >3c11, >0001, >4e7b ;  67.5 degrees.
    data >0000, >0000, >0001, >6a0a ;  90.0 degrees.
    data >0000, >c3ef, >0001, >4e7b ; 112.5 degrees.
    data >0001, >6a0a, >0001, >0000 ; 135.0 degrees.
    data >0001, >d907, >0000, >8a8c ; 157.5 degrees.
    data >0002, >0000, >0000, >0000 ; 180.0 degrees.
    data >0001, >d907, >ffff, >7574 ; 202.5 degrees.
    data >0001, >6a0a, >ffff, >0000 ; 225.0 degrees.
    data >0000, >c3ef, >fffe, >b185 ; 247.5 degrees.
    data >0000, >0000, >fffe, >95f6 ; 270.0 degrees.
    data >ffff, >3c11, >fffe, >b185 ; 292.5 degrees.
    data >fffe, >95f6, >ffff, >0000 ; 315.0 degrees.
    data >fffe, >26f9, >ffff, >7574 ; 337.5 degrees.

* Launched object motion.
delta_forward_fast
    data >0000, >0000, >0002, >d414 ;   0.0 degrees.
    data >0001, >87de, >0002, >9cf6 ;  22.5 degrees.
    data >0002, >d414, >0002, >0000 ;  45.0 degrees.
    data >0003, >b20d, >0001, >1518 ;  67.5 degrees.
    data >0004, >0000, >0000, >0000 ;  90.0 degrees.
    data >0003, >b20d, >fffe, >eae8 ; 112.5 degrees.
    data >0002, >d414, >fffe, >0000 ; 135.0 degrees.
    data >0001, >87de, >fffd, >630a ; 157.5 degrees.
    data >0000, >0000, >fffd, >2bec ; 180.0 degrees.
    data >fffe, >7822, >fffd, >630a ; 202.5 degrees.
    data >fffd, >2bec, >fffe, >0000 ; 225.0 degrees.
    data >fffc, >4df3, >fffe, >eae8 ; 247.5 degrees.
    data >fffc, >0000, >0000, >0000 ; 270.0 degrees.
    data >fffc, >4df3, >0001, >1518 ; 292.5 degrees.
    data >fffd, >2bec, >0002, >0000 ; 315.0 degrees.
    data >fffe, >7822, >0002, >9cf6 ; 337.5 degrees.

delta_forward_very_fast
    data >0000, >0000, >0004, >3e1e ;   0.0 degrees.
    data >0002, >4bcd, >0003, >eb71 ;  22.5 degrees.
    data >0004, >3e1e, >0003, >0000 ;  45.0 degrees.
    data >0005, >8b14, >0001, >9fa3 ;  67.5 degrees.
    data >0006, >0000, >0000, >0000 ;  90.0 degrees.
    data >0005, >8b14, >fffe, >605d ; 112.5 degrees.
    data >0004, >3e1e, >fffd, >0000 ; 135.0 degrees.
    data >0002, >4bcd, >fffc, >148f ; 157.5 degrees.
    data >0000, >0000, >fffb, >c1e2 ; 180.0 degrees.
    data >fffd, >b433, >fffc, >148f ; 202.5 degrees.
    data >fffb, >c1e2, >fffd, >0000 ; 225.0 degrees.
    data >fffa, >74ec, >fffe, >605d ; 247.5 degrees.
    data >fffa, >0000, >0000, >0000 ; 270.0 degrees.
    data >fffa, >74ec, >0001, >9fa3 ; 292.5 degrees.
    data >fffb, >c1e2, >0003, >0000 ; 315.0 degrees.
    data >fffd, >b433, >0003, >eb71 ; 337.5 degrees.

* Mouse circle deltas.
delta_forward_far
    data >0000, >0000, >0016, >a09e ;   0.0 degrees.
    data >000c, >3ef1, >0014, >e7af ;  22.5 degrees.
    data >0016, >a09e, >0010, >0000 ;  45.0 degrees.
    data >001d, >906c, >0008, >a8bd ;  67.5 degrees.
    data >0020, >0000, >0000, >0000 ;  90.0 degrees.
    data >001d, >906c, >fff7, >5743 ; 112.5 degrees.
    data >0016, >a09e, >fff0, >0000 ; 135.0 degrees.
    data >000c, >3ef1, >ffeb, >1851 ; 157.5 degrees.
    data >0000, >0000, >ffe9, >5f62 ; 180.0 degrees.
    data >fff3, >c10f, >ffeb, >1851 ; 202.5 degrees.
    data >ffe9, >5f62, >fff0, >0000 ; 225.0 degrees.
    data >ffe2, >6f94, >fff7, >5743 ; 247.5 degrees.
    data >ffe0, >0000, >0000, >0000 ; 270.0 degrees.
    data >ffe2, >6f94, >0008, >a8bd ; 292.5 degrees.
    data >ffe9, >5f62, >0010, >0000 ; 315.0 degrees.
    data >fff3, >c10f, >0014, >e7af ; 337.5 degrees.

delta_backward_fast
    data >0000, >0000, >fffe, >95f6 ;   0.0 degrees.
    data >ffff, >3c11, >fffe, >b185 ;  22.5 degrees.
    data >fffe, >95f6, >ffff, >0000 ;  45.0 degrees.
    data >fffe, >26f9, >ffff, >7574 ;  67.5 degrees.
    data >fffe, >0000, >0000, >0000 ;  90.0 degrees.
    data >fffe, >26f9, >0000, >8a8c ; 112.5 degrees.
    data >fffe, >95f6, >0001, >0000 ; 135.0 degrees.
    data >ffff, >3c11, >0001, >4e7b ; 157.5 degrees.
    data >0000, >0000, >0001, >6a0a ; 180.0 degrees.
    data >0000, >c3ef, >0001, >4e7b ; 202.5 degrees.
    data >0001, >6a0a, >0001, >0000 ; 225.0 degrees.
    data >0001, >d907, >0000, >8a8c ; 247.5 degrees.
    data >0002, >0000, >0000, >0000 ; 270.0 degrees.
    data >0001, >d907, >ffff, >7574 ; 292.5 degrees.
    data >0001, >6a0a, >ffff, >0000 ; 315.0 degrees.
    data >0000, >c3ef, >fffe, >b185 ; 337.5 degrees.
