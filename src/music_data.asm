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

* Music (or complex sounds), stored in our SND format.

mute_all
    byte 4
    .tone_off 0
    .tone_off 1
    .tone_off 2
    .noise_off
    byte -1

parachuting_sound
    byte 11
    .tone_frequency 0, 900
    .tone_frequency 1, 1023
    .tone_frequency 2, 1
    .noise_frequency white_noise, 3
    .tone_attenuation 0, 14
    .tone_attenuation 1, 14
    .tone_attenuation 2, 14
    .noise_attenuation 14
    byte 1
    .noise_attenuation 13
    byte 4
    .tone_attenuation 0, 13
    .tone_attenuation 1, 13
    .tone_attenuation 2, 13
    .noise_attenuation 12
    byte 1
    .noise_attenuation 11
    byte 4
    .tone_attenuation 0, 12
    .tone_attenuation 1, 13
    .tone_attenuation 2, 14
    .noise_attenuation 10
    byte 4
    .tone_attenuation 0, 13
    .tone_attenuation 1, 14
    .tone_attenuation 2, 13
    .noise_attenuation 9
    byte 4
    .tone_attenuation 0, 14
    .tone_attenuation 1, 13
    .tone_attenuation 2, 12
    .noise_attenuation 8
    byte 4
    .tone_attenuation 0, 13
    .tone_attenuation 1, 12
    .tone_attenuation 2, 13
    .noise_attenuation 7
    byte 4
    .tone_attenuation 0, 12
    .tone_attenuation 1, 13
    .tone_attenuation 2, 14
    .noise_attenuation 8
    byte 4
    .tone_attenuation 0, 13
    .tone_attenuation 1, 14
    .tone_attenuation 2, 13
    .noise_attenuation 9
    byte 4
    .tone_attenuation 0, 14
    .tone_attenuation 1, 14
    .tone_attenuation 2, 14
    .noise_attenuation 10
    byte -1

target_reached_with_rest
    bcopy "../out/TargetReached.snd"
    byte -1

* Skip the initial rest for our jingle.
target_reached equ target_reached_with_rest + 14

    even
