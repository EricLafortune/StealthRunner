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

* Deltas on the x axis and the y axis for moving the player and objects in
* one of the discrete directions at one of the discrete speeds, in an angled
* perspecive (x to y ratio of sqrt(2)).
*
* Signed fixed point repesentation with an integer component and a fractional
* component (16.16 bits).
*
* Data entries: delta_x, fraction_delta_x, delta_y, fraction_delta_y

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
    data >0000, >0000, >0001, >6a0a ;   0.0 degrees.
    data >0000, >c3ef, >0001, >4e7b ;  22.5 degrees.
    data >0001, >6a0a, >0001, >0000 ;  45.0 degrees.
    data >0001, >d907, >0000, >8a8c ;  67.5 degrees.
    data >0002, >0000, >0000, >0000 ;  90.0 degrees.
    data >0001, >d907, >ffff, >7574 ; 112.5 degrees.
    data >0001, >6a0a, >ffff, >0000 ; 135.0 degrees.
    data >0000, >c3ef, >fffe, >b185 ; 157.5 degrees.
    data >0000, >0000, >fffe, >95f6 ; 180.0 degrees.
    data >ffff, >3c11, >fffe, >b185 ; 202.5 degrees.
    data >fffe, >95f6, >ffff, >0000 ; 225.0 degrees.
    data >fffe, >26f9, >ffff, >7574 ; 247.5 degrees.
    data >fffe, >0000, >0000, >0000 ; 270.0 degrees.
    data >fffe, >26f9, >0000, >8a8c ; 292.5 degrees.
    data >fffe, >95f6, >0001, >0000 ; 315.0 degrees.
    data >ffff, >3c11, >0001, >4e7b ; 337.5 degrees.

delta_backward_slow
    data >0000, >0000, >ffff, >a57e ;   0.0 degrees.
    data >ffff, >cf04, >ffff, >ac61 ;  22.5 degrees.
    data >ffff, >a57e, >ffff, >c000 ;  45.0 degrees.
    data >ffff, >89be, >ffff, >dd5d ;  67.5 degrees.
    data >ffff, >8000, >0000, >0000 ;  90.0 degrees.
    data >ffff, >89be, >0000, >22a3 ; 112.5 degrees.
    data >ffff, >a57e, >0000, >4000 ; 135.0 degrees.
    data >ffff, >cf04, >0000, >539f ; 157.5 degrees.
    data >0000, >0000, >0000, >5a82 ; 180.0 degrees.
    data >0000, >30fc, >0000, >539f ; 202.5 degrees.
    data >0000, >5a82, >0000, >4000 ; 225.0 degrees.
    data >0000, >7642, >0000, >22a3 ; 247.5 degrees.
    data >0000, >8000, >0000, >0000 ; 270.0 degrees.
    data >0000, >7642, >ffff, >dd5d ; 292.5 degrees.
    data >0000, >5a82, >ffff, >c000 ; 315.0 degrees.
    data >0000, >30fc, >ffff, >ac61 ; 337.5 degrees.
delta_backward
    data >0000, >0000, >ffff, >4afb ;   0.0 degrees.
    data >ffff, >9e08, >ffff, >58c3 ;  22.5 degrees.
    data >ffff, >4afb, >ffff, >8000 ;  45.0 degrees.
    data >ffff, >137d, >ffff, >baba ;  67.5 degrees.
    data >ffff, >0000, >0000, >0000 ;  90.0 degrees.
    data >ffff, >137d, >0000, >4546 ; 112.5 degrees.
    data >ffff, >4afb, >0000, >8000 ; 135.0 degrees.
    data >ffff, >9e08, >0000, >a73d ; 157.5 degrees.
    data >0000, >0000, >0000, >b505 ; 180.0 degrees.
    data >0000, >61f8, >0000, >a73d ; 202.5 degrees.
    data >0000, >b505, >0000, >8000 ; 225.0 degrees.
    data >0000, >ec83, >0000, >4546 ; 247.5 degrees.
    data >0001, >0000, >0000, >0000 ; 270.0 degrees.
    data >0000, >ec83, >ffff, >baba ; 292.5 degrees.
    data >0000, >b505, >ffff, >8000 ; 315.0 degrees.
    data >0000, >61f8, >ffff, >58c3 ; 337.5 degrees.

delta_strafe_left_slow
    data >0000, >c000, >0000, >0000 ;   0.0 degrees.
    data >0000, >b163, >ffff, >cc0c ;  22.5 degrees.
    data >0000, >87c4, >ffff, >a000 ;  45.0 degrees.
    data >0000, >497a, >ffff, >8292 ;  67.5 degrees.
    data >0000, >0000, >ffff, >783c ;  90.0 degrees.
    data >ffff, >b686, >ffff, >8292 ; 112.5 degrees.
    data >ffff, >783c, >ffff, >a000 ; 135.0 degrees.
    data >ffff, >4e9d, >ffff, >cc0c ; 157.5 degrees.
    data >ffff, >4000, >0000, >0000 ; 180.0 degrees.
    data >ffff, >4e9d, >0000, >33f4 ; 202.5 degrees.
    data >ffff, >783c, >0000, >6000 ; 225.0 degrees.
    data >ffff, >b686, >0000, >7d6e ; 247.5 degrees.
    data >0000, >0000, >0000, >87c4 ; 270.0 degrees.
    data >0000, >497a, >0000, >7d6e ; 292.5 degrees.
    data >0000, >87c4, >0000, >6000 ; 315.0 degrees.
    data >0000, >b163, >0000, >33f4 ; 337.5 degrees.
delta_strafe_left
    data >0001, >8000, >0000, >0000 ;   0.0 degrees.
    data >0001, >62c5, >ffff, >9817 ;  22.5 degrees.
    data >0001, >0f87, >ffff, >4000 ;  45.0 degrees.
    data >0000, >92f3, >ffff, >0524 ;  67.5 degrees.
    data >0000, >0000, >fffe, >f079 ;  90.0 degrees.
    data >ffff, >6d0d, >ffff, >0524 ; 112.5 degrees.
    data >fffe, >f079, >ffff, >4000 ; 135.0 degrees.
    data >fffe, >9d3b, >ffff, >9817 ; 157.5 degrees.
    data >fffe, >8000, >0000, >0000 ; 180.0 degrees.
    data >fffe, >9d3b, >0000, >67e9 ; 202.5 degrees.
    data >fffe, >f079, >0000, >c000 ; 225.0 degrees.
    data >ffff, >6d0d, >0000, >fadc ; 247.5 degrees.
    data >0000, >0000, >0001, >0f87 ; 270.0 degrees.
    data >0000, >92f3, >0000, >fadc ; 292.5 degrees.
    data >0001, >0f87, >0000, >c000 ; 315.0 degrees.
    data >0001, >62c5, >0000, >67e9 ; 337.5 degrees.

delta_strafe_right_slow
    data >ffff, >4000, >0000, >0000 ;   0.0 degrees.
    data >ffff, >4e9d, >0000, >33f4 ;  22.5 degrees.
    data >ffff, >783c, >0000, >6000 ;  45.0 degrees.
    data >ffff, >b686, >0000, >7d6e ;  67.5 degrees.
    data >0000, >0000, >0000, >87c4 ;  90.0 degrees.
    data >0000, >497a, >0000, >7d6e ; 112.5 degrees.
    data >0000, >87c4, >0000, >6000 ; 135.0 degrees.
    data >0000, >b163, >0000, >33f4 ; 157.5 degrees.
    data >0000, >c000, >0000, >0000 ; 180.0 degrees.
    data >0000, >b163, >ffff, >cc0c ; 202.5 degrees.
    data >0000, >87c4, >ffff, >a000 ; 225.0 degrees.
    data >0000, >497a, >ffff, >8292 ; 247.5 degrees.
    data >0000, >0000, >ffff, >783c ; 270.0 degrees.
    data >ffff, >b686, >ffff, >8292 ; 292.5 degrees.
    data >ffff, >783c, >ffff, >a000 ; 315.0 degrees.
    data >ffff, >4e9d, >ffff, >cc0c ; 337.5 degrees.
delta_strafe_right
    data >ffff, >0000, >0000, >0000 ;   0.0 degrees.
    data >ffff, >137d, >0000, >4546 ;  22.5 degrees.
    data >ffff, >4afb, >0000, >8000 ;  45.0 degrees.
    data >ffff, >9e08, >0000, >a73d ;  67.5 degrees.
    data >0000, >0000, >0000, >b505 ;  90.0 degrees.
    data >0000, >61f8, >0000, >a73d ; 112.5 degrees.
    data >0000, >b505, >0000, >8000 ; 135.0 degrees.
    data >0000, >ec83, >0000, >4546 ; 157.5 degrees.
    data >0001, >0000, >0000, >0000 ; 180.0 degrees.
    data >0000, >ec83, >ffff, >baba ; 202.5 degrees.
    data >0000, >b505, >ffff, >8000 ; 225.0 degrees.
    data >0000, >61f8, >ffff, >58c3 ; 247.5 degrees.
    data >0000, >0000, >ffff, >4afb ; 270.0 degrees.
    data >ffff, >9e08, >ffff, >58c3 ; 292.5 degrees.
    data >ffff, >4afb, >ffff, >8000 ; 315.0 degrees.
    data >ffff, >137d, >ffff, >baba ; 337.5 degrees.

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
