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

* Subroutines to compute directions and direction vectors.

* Local macro: compare a point against the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side (swapped).
    .defm cmp_0
    ;   cos(0) * x - sin(0) * y = x

    mov  r0, r0
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 22.5 degrees counter-clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side (swapped).
* LOCAL r3
    .defm cmp_22
    ; We simplify the computation:
    ;   cos(22.5) * x - sin(22.5) * y ~=
    ;   cos(22.6) * x - sin(22.6) * y ~  0x0c * x - 0x05 * y

    mov  r0, r3
    sla  r3, 1
    a    r0, r3
    s    r1, r3
    sla  r3, 2
    s    r1, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 45 degrees counter-clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_45

    c    r1, r0
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 67.5 degrees counter-clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_67
    ; We simplify the computation:
    ;   sin(67.5) * y - cos(67.5) * x ~=
    ;   sin(67.4) * y - cos(67.4) * x ~  0x0c * y - 0x05 * x

    mov  r1, r3
    sla  r3, 1
    a    r1, r3
    s    r0, r3
    sla  r3, 2
    s    r0, r3
    .endm

* Local macro: compare a point against the x axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
    .defm cmp_90
    ;   sin(90) * y - cos(90) * x = y

    mov  r1, r1
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 112.5 degrees counter-clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_112
    ; We simplify the computation:
    ;   sin(112.5) * y - cos(112.5) * x ~=
    ;   sin(112.6) * y - cos(112.6) * x ~  0x0c * y + 0x05 * x

    mov  r1, r3
    sla  r3, 1
    a    r1, r3
    a    r0, r3
    sla  r3, 2
    a    r0, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 135 degrees counter-clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_135

    mov  r0, r3
    a    r1, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 157.5 degrees counter+clockwise from the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_157
    ; We simplify the computation:
    ;   -cos(157.5) * x + sin(157.5) * y ~=
    ;   -cos(157.4) * x + sin(157.4) * y ~  0x0c * x + 0x05 * y

    mov  r0, r3
    sla  r3, 1
    a    r0, r3
    a    r1, r3
    sla  r3, 2
    a    r1, r3
    .endm


* Subroutine: return a possibly decremented or incremented direction to track
* the given direction vector.
* IN     r0: the x component of the direction vector (x axis pointing right).
* IN     r1: the y component of the direction vector (y axis pointing down).
* IN OUT r2: the direction (0..15, counter-clockwise from the y axis).
* LOCAL  r3
adjust_direction
    mov  r2, r3                ; Switch based on the direction.
    sla  r3, 1
    mov  @direction_cases(r3), r3
    b    *r3

direction_cases
    data direction_case0
    data direction_case1
    data direction_case2
    data direction_case3
    data direction_case4
    data direction_case5
    data direction_case6
    data direction_case7
    data direction_case8
    data direction_case9
    data direction_case10
    data direction_case11
    data direction_case12
    data direction_case13
    data direction_case14
    data direction_case15

direction_case0                ; At 0 degrees (x~0, y pos).
    .cmp_157
    jlt  decrement_direction
    .cmp_22
    jgt  increment_direction
    rt

direction_case1                ; At 22.5 degrees (x pos, y pos).
    .cmp_0
    jlt  decrement_direction
    .cmp_45
    jlt  increment_direction
    rt

direction_case2                ; At 45 degrees (x pos, y pos).
    .cmp_22
    jlt  decrement_direction
    .cmp_67
    jlt  increment_direction
    rt

direction_case3                ; At 67.5 degrees (x pos, y pos).
    .cmp_45
    jgt  decrement_direction
    .cmp_90
    jlt  increment_direction
    rt

direction_case4                ; At 90 degrees (x pos, y~0).
    .cmp_67
    jgt  decrement_direction
    .cmp_112
    jlt  increment_direction
    rt

direction_case5                ; At 112.5 degrees (x pos, y neg).
    .cmp_90
    jgt  decrement_direction
    .cmp_135
    jlt  increment_direction
    rt

direction_case6                ; At 135 degrees (x pos, y neg).
    .cmp_112
    jgt  decrement_direction
    .cmp_157
    jlt  increment_direction
    rt

direction_case7                ; At 157.5 degrees (x pos, y neg).
    .cmp_135
    jgt  decrement_direction
    .cmp_0
    jlt  increment_direction
    rt

* We have to put these exit points in the middle, so the code can reach them
* with short jumps instead of long branches.
increment_direction
    inc  r2
    andi r2, >000f
    rt
decrement_direction
    dec  r2
    andi r2, >000f
    rt

direction_case8                ; At 180 degrees (x~0, y neg).
    .cmp_157
    jgt  decrement_direction
    .cmp_22
    jlt  increment_direction
    rt

direction_case9                ; At 202.5 degrees (x neg, y neg).
    .cmp_0
    jgt  decrement_direction
    .cmp_45
    jgt  increment_direction
    rt

direction_case10               ; At 225 degrees (x neg, y neg).
    .cmp_22
    jgt  decrement_direction
    .cmp_67
    jgt  increment_direction
    rt

direction_case11               ; At 247.5 degrees (x neg, y neg).
    .cmp_45
    jlt  decrement_direction
    .cmp_90
    jgt  increment_direction
    rt

direction_case12               ; At 270 degrees (x neg, y~0).
    .cmp_67
    jlt  decrement_direction
    .cmp_112
    jgt  increment_direction
    rt

direction_case13               ; At 292.5 degrees (x neg, y pos).
    .cmp_90
    jlt  decrement_direction
    .cmp_135
    jgt  increment_direction
    rt

direction_case14               ; At 315 degrees (x neg, y pos).
    .cmp_112
    jlt  decrement_direction
    .cmp_157
    jgt  increment_direction
    rt

direction_case15               ; At 337.5 degrees (x neg, y pos).
    .cmp_135
    jlt  decrement_direction
    .cmp_0
    jgt  increment_direction
    rt


* Local macro: compare a point against the y axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side (swapped).
    .defm cmp_projected_0
    ;   cos(0) * x - sin(0) * y = x

    mov  r0, r0
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 30.4 degrees counter-clockwise from the y axis (22.5 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side (swapped).
* LOCAL r3
    .defm cmp_projected_22
    ; We simplify the computation:
    ;   cos(30.4) * x - sin(30.4) * y ~=
    ;   cos(33.7) * x - sin(33.7) * y ~  3 * x - 2 * y

    mov  r0, r3
    s    r1, r3
    sla  r3, 1
    a    r0, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 54.7 degrees counter-clockwise from the y axis (45 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_projected_45
    ; We simplify the computation:
    ;   sin(54.7) * y - cos(54.7) * x ~=
    ;   sin(56.3) * y - cos(56.3) * x ~  3 * y - 2 * x

    mov  r1, r3
    s    r0, r3
    sla  r3, 1
    a    r1, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 73.6 degrees counter-clockwise from the y axis (67.5 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_projected_67
    ; We simplify the computation:
    ;   sin(73.6) * y - cos(73.6) * x ~=
    ;   sin(71.6) * y - cos(71.6) * x ~  3 * y - 1 * x

    mov  r1, r3
    sla  r3, 1
    a    r1, r3
    s    r0, r3
    .endm

* Local macro: compare a point against the x axis.
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
    .defm cmp_projected_90
    ;   sin(90) * y - cos(90) * x = y

    mov  r1, r1
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 106.3 degrees counter-clockwise from the y axis (112.5 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_projected_112
    ; We simplify the computation:
    ;   sin(106.3) * y - cos(106.3) * x ~=
    ;   sin(108.4) * y - cos(108.4) * x ~  3 * y + 1 * x

    mov  r1, r3
    sla  r3, 1
    a    r1, r3
    a    r0, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 125.3 degrees counter-clockwise from the y axis (135 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_projected_135
    ; We simplify the computation:
    ;   -cos(125.3) * x + sin(125.3) * y ~=
    ;   -cos(123.7) * x + sin(123.7) * y ~  2 * x + 3 * y

    mov  r0, r3
    a    r1, r3
    sla  r3, 1
    a    r1, r3
    .endm

* Local macro: compare a point against a line through the origin and at an
* angle of 149.6 degrees counter+clockwise from the y axis (157.5 degrees
* projected).
* IN    r0: the x ordinate (x axis pointing right).
* IN    r1: the y ordinate (y axis pointing down).
* OUT   status: the sign indicating the side.
* LOCAL r3
    .defm cmp_projected_157
    ; We simplify the computation:
    ;   -cos(149.6) * x + sin(149.6) * y ~=
    ;   -cos(146.3) * x + sin(146.3) * y ~  3 * x + 2 * y

    mov  r0, r3
    a    r1, r3
    sla  r3, 1
    a    r0, r3
    .endm


* Subroutine: return a possibly decremented or incremented direction to track
* the given projected direction vector.
* IN     r0: the x component of the direction vector (x axis pointing right).
* IN     r1: the y component of the direction vector (y axis pointing down).
* IN OUT r2: the direction (0..15, counter-clockwise from the y axis).
* LOCAL  r3
adjust_projected_direction
    mov  r2, r3                ; Switch based on the direction.
    sla  r3, 1
    mov  @projected_direction_cases(r3), r3
    b    *r3

projected_direction_cases
    data projected_direction_case0
    data projected_direction_case1
    data projected_direction_case2
    data projected_direction_case3
    data projected_direction_case4
    data projected_direction_case5
    data projected_direction_case6
    data projected_direction_case7
    data projected_direction_case8
    data projected_direction_case9
    data projected_direction_case10
    data projected_direction_case11
    data projected_direction_case12
    data projected_direction_case13
    data projected_direction_case14
    data projected_direction_case15

projected_direction_case0                ; At 0 degrees (x~0, y pos).
    .cmp_projected_157
    jlt  decrement_projected_direction
    .cmp_projected_22
    jgt  increment_projected_direction
    rt

projected_direction_case1                ; At 22.5 degrees (x pos, y pos).
    .cmp_projected_0
    jlt  decrement_projected_direction
    .cmp_projected_45
    jlt  increment_projected_direction
    rt

projected_direction_case2                ; At 45 degrees (x pos, y pos).
    .cmp_projected_22
    jlt  decrement_projected_direction
    .cmp_projected_67
    jlt  increment_projected_direction
    rt

projected_direction_case3                ; At 67.5 degrees (x pos, y pos).
    .cmp_projected_45
    jgt  decrement_projected_direction
    .cmp_projected_90
    jlt  increment_projected_direction
    rt

projected_direction_case4                ; At 90 degrees (x pos, y~0).
    .cmp_projected_67
    jgt  decrement_projected_direction
    .cmp_projected_112
    jlt  increment_projected_direction
    rt

projected_direction_case5                ; At 112.5 degrees (x pos, y neg).
    .cmp_projected_90
    jgt  decrement_projected_direction
    .cmp_projected_135
    jlt  increment_projected_direction
    rt

projected_direction_case6                ; At 135 degrees (x pos, y neg).
    .cmp_projected_112
    jgt  decrement_projected_direction
    .cmp_projected_157
    jlt  increment_projected_direction
    rt

projected_direction_case7                ; At 157.5 degrees (x pos, y neg).
    .cmp_projected_135
    jgt  decrement_projected_direction
    .cmp_projected_0
    jlt  increment_projected_direction
    rt

* We have to put these exit points in the middle, so the code can reach them
* with short jumps instead of long branches.
increment_projected_direction
    inc  r2
    andi r2, >000f
    rt
decrement_projected_direction
    dec  r2
    andi r2, >000f
    rt

projected_direction_case8                ; At 180 degrees (x~0, y neg).
    .cmp_projected_157
    jgt  decrement_projected_direction
    .cmp_projected_22
    jlt  increment_projected_direction
    rt

projected_direction_case9                ; At 202.5 degrees (x neg, y neg).
    .cmp_projected_0
    jgt  decrement_projected_direction
    .cmp_projected_45
    jgt  increment_projected_direction
    rt

projected_direction_case10               ; At 225 degrees (x neg, y neg).
    .cmp_projected_22
    jgt  decrement_projected_direction
    .cmp_projected_67
    jgt  increment_projected_direction
    rt

projected_direction_case11               ; At 247.5 degrees (x neg, y neg).
    .cmp_projected_45
    jlt  decrement_projected_direction
    .cmp_projected_90
    jgt  increment_projected_direction
    rt

projected_direction_case12               ; At 270 degrees (x neg, y~0).
    .cmp_projected_67
    jlt  decrement_projected_direction
    .cmp_projected_112
    jgt  increment_projected_direction
    rt

projected_direction_case13               ; At 292.5 degrees (x neg, y pos).
    .cmp_projected_90
    jlt  decrement_projected_direction
    .cmp_projected_135
    jgt  increment_projected_direction
    rt

projected_direction_case14               ; At 315 degrees (x neg, y pos).
    .cmp_projected_112
    jlt  decrement_projected_direction
    .cmp_projected_157
    jgt  increment_projected_direction
    rt

projected_direction_case15               ; At 337.5 degrees (x neg, y pos).
    .cmp_projected_135
    jlt  decrement_projected_direction
    .cmp_projected_0
    jgt  increment_projected_direction
    rt
