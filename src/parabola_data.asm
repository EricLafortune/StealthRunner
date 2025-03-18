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

* The deltas of a parabolic curve with a maximum of 96, shifted to start at 5
* and end at 0, in 32 frames.
high_parabolic_delta
    data >0005 ; Frame 0, height 5.
    data >000b ; Frame 1, height 16.
    data >000a ; Frame 2, height 26.
    data >000a ; Frame 3, height 36.
    data >0009 ; Frame 4, height 45.
    data >0008 ; Frame 5, height 53.
    data >0007 ; Frame 6, height 60.
    data >0007 ; Frame 7, height 67.
    data >0006 ; Frame 8, height 73.
    data >0005 ; Frame 9, height 78.
    data >0004 ; Frame 10, height 82.
    data >0004 ; Frame 11, height 86.
    data >0003 ; Frame 12, height 89.
    data >0002 ; Frame 13, height 91.
    data >0001 ; Frame 14, height 92.
    data >0001 ; Frame 15, height 93.
    data >ffff ; Frame 16, height 92.
    data >0000 ; Frame 17, height 92.
    data >fffe ; Frame 18, height 90.
    data >fffd ; Frame 19, height 87.
    data >fffd ; Frame 20, height 84.
    data >fffc ; Frame 21, height 80.
    data >fffc ; Frame 22, height 76.
    data >fffa ; Frame 23, height 70.
    data >fffa ; Frame 24, height 64.
    data >fff9 ; Frame 25, height 57.
    data >fff9 ; Frame 26, height 50.
    data >fff7 ; Frame 27, height 41.
    data >fff7 ; Frame 28, height 32.
    data >fff6 ; Frame 29, height 22.
    data >fff5 ; Frame 30, height 11.
    data >fff5 ; Frame 31, height 0.

* The deltas of a parabolic curve with a maximum of 40, shifted to start at 25
* and end at 0, in 32 frames.
low_parabolic_delta
    data >0020 ; Frame 0, height 32.
    data >0004 ; Frame 1, height 36.
    data >0003 ; Frame 2, height 39.
    data >0003 ; Frame 3, height 42.
    data >0003 ; Frame 4, height 45.
    data >0002 ; Frame 5, height 47.
    data >0002 ; Frame 6, height 49.
    data >0002 ; Frame 7, height 51.
    data >0001 ; Frame 8, height 52.
    data >0002 ; Frame 9, height 54.
    data >0000 ; Frame 10, height 54.
    data >0001 ; Frame 11, height 55.
    data >0000 ; Frame 12, height 55.
    data >0000 ; Frame 13, height 55.
    data >0000 ; Frame 14, height 55.
    data >ffff ; Frame 15, height 54.
    data >ffff ; Frame 16, height 53.
    data >ffff ; Frame 17, height 52.
    data >fffe ; Frame 18, height 50.
    data >fffe ; Frame 19, height 48.
    data >fffe ; Frame 20, height 46.
    data >fffd ; Frame 21, height 43.
    data >fffd ; Frame 22, height 40.
    data >fffd ; Frame 23, height 37.
    data >fffc ; Frame 24, height 33.
    data >fffd ; Frame 25, height 30.
    data >fffb ; Frame 26, height 25.
    data >fffc ; Frame 27, height 21.
    data >fffb ; Frame 28, height 16.
    data >fffb ; Frame 29, height 11.
    data >fffb ; Frame 30, height 6.
    data >fffa ; Frame 31, height 0.
