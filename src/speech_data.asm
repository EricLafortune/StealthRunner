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

* Speech data: LPC coefficients for exclamations, grunts,...
* Each phrase consists of the length (expressed in bytes) followed by the LPC
* data.

speech_letsgo
    data 189
    bcopy "../out/letsgo.lpc"
    even

speech_argh
    data 90
    bcopy "../out/argh.lpc"
    even

speech_ahohe
    data 1382
    bcopy "../out/ahohe.lpc"
    even
