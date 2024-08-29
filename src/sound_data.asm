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

* Sounds (tones and noises), ordered from high to low priority.

* Explosion.
sound_explosion
    .noise_frequency white_noise, 0

sound_explosion_frames         ; 16 frames.
    .noise_attenuation 0       ; Frame 0.
    .noise_attenuation 1       ; Frame 1.
    .noise_attenuation 2       ; Frame 2.
    .noise_attenuation 3       ; Frame 3.
    .noise_attenuation 4       ; Frame 4.
    .noise_attenuation 5       ; Frame 5.
    .noise_attenuation 6       ; Frame 6.
    .noise_attenuation 7       ; Frame 7.
    .noise_attenuation 8       ; Frame 8.
    .noise_attenuation 9       ; Frame 9.
    .noise_attenuation 10      ; Frame 10.
    .noise_attenuation 11      ; Frame 11.
    .noise_attenuation 12      ; Frame 12.
    .noise_attenuation 13      ; Frame 13.
    .noise_attenuation 14      ; Frame 14.
    byte 0                     ; Frame 15.

* The EMP disappearing in the distance.
sound_emp
    .tone_frequency 0, 100

sound_emp_frames               ; 16 frames.
    .tone_attenuation 0, 0     ; Frame 0.
    .tone_attenuation 0, 1     ; Frame 1.
    .tone_attenuation 0, 4     ; Frame 2.
    .tone_attenuation 0, 3     ; Frame 3.
    .tone_attenuation 0, 6     ; Frame 4.
    .tone_attenuation 0, 5     ; Frame 5.
    .tone_attenuation 0, 8     ; Frame 6.
    .tone_attenuation 0, 7     ; Frame 7.
    .tone_attenuation 0, 10    ; Frame 8.
    .tone_attenuation 0, 9     ; Frame 9.
    .tone_attenuation 0, 12    ; Frame 10.
    .tone_attenuation 0, 11    ; Frame 11.
    .tone_attenuation 0, 14    ; Frame 12.
    .tone_attenuation 0, 13    ; Frame 13.
    .tone_attenuation 0, 14    ; Frame 14.
    byte 0                     ; Frame 15.

* The bullet approaching from the distance.
sound_bullet
    .noise_frequency white_noise, 0

sound_bullet_frames               ; 16 frames.
    .noise_attenuation 0          ; Frame 0.
    .noise_attenuation 1          ; Frame 1.
    .noise_attenuation 2          ; Frame 2.
    .noise_attenuation 3          ; Frame 3.
    .noise_attenuation 4          ; Frame 4.
    .noise_attenuation 5          ; Frame 5.
    .noise_attenuation 6          ; Frame 6.
    .noise_attenuation 7          ; Frame 7.
    .noise_attenuation 8          ; Frame 8.
    .noise_attenuation 9          ; Frame 9.
    .noise_attenuation 10         ; Frame 10.
    .noise_attenuation 11         ; Frame 11.
    .noise_attenuation 12         ; Frame 12.
    .noise_attenuation 13         ; Frame 13.
    .noise_attenuation 14         ; Frame 14.
    byte 0                        ; Frame 15.

* The drone in the distance.
sound_drone
    .noise_frequency periodic_noise, 2

sound_drone_frames             ; 32 frames.
    .noise_attenuation 0       ; Frame 0.
    .noise_attenuation 2       ; Frame 1.
    .noise_attenuation 1       ; Frame 2.
    .noise_attenuation 3       ; Frame 3.
    .noise_attenuation 2       ; Frame 4.
    .noise_attenuation 4       ; Frame 5.
    .noise_attenuation 3       ; Frame 6.
    .noise_attenuation 5       ; Frame 7.
    .noise_attenuation 4       ; Frame 8.
    .noise_attenuation 6       ; Frame 9.
    .noise_attenuation 5       ; Frame 10.
    .noise_attenuation 7       ; Frame 11.
    .noise_attenuation 6       ; Frame 12.
    .noise_attenuation 8       ; Frame 13.
    .noise_attenuation 7       ; Frame 14.
    .noise_attenuation 9       ; Frame 15.
    .noise_attenuation 8       ; Frame 16.
    .noise_attenuation 10      ; Frame 17.
    .noise_attenuation 9       ; Frame 18.
    .noise_attenuation 11      ; Frame 19.
    .noise_attenuation 10      ; Frame 20.
    .noise_attenuation 12      ; Frame 21.
    .noise_attenuation 11      ; Frame 22.
    .noise_attenuation 13      ; Frame 23.
    .noise_attenuation 12      ; Frame 24.
    .noise_attenuation 14      ; Frame 25.
    .noise_attenuation 12      ; Frame 26.
    .noise_attenuation 14      ; Frame 27.
    .noise_attenuation 12      ; Frame 28.
    .noise_attenuation 14      ; Frame 29.
    .noise_attenuation 13      ; Frame 30.
    byte 0                     ; Frame 31.

* The player walking and running.
sound_walking
    .noise_frequency white_noise, 2
    even

sound_dying_frames
    data sound_die             ; 11 frames.
sound_walking_frames
    data sound_stand           ;  1 frame.
    data sound_walk            ; 31 frames.
    data sound_run             ; 22 frames.
    data sound_walk_backward   ; 36 frames.
    data sound_run_backward    ; 19 frames.
    data sound_walk            ; 31 frames.
    data sound_run             ; 20 frames.
    data sound_walk            ; 31 frames.
    data sound_run             ; 20 frames.

sound_die                      ; 17 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    .noise_attenuation 10      ; Frame 7.
    .noise_attenuation 6       ; Frame 8.
    .noise_attenuation 0       ; Frame 9.
    .noise_attenuation 2       ; Frame 10.
    .noise_attenuation 2       ; Frame 11.
    .noise_attenuation 2       ; Frame 12.
    .noise_attenuation 2       ; Frame 13.
    .noise_attenuation 2       ; Frame 14.
    .noise_attenuation 2       ; Frame 15.
    .noise_attenuation 2       ; Frame 16.
    byte 0                     ; Frame 17.

sound_stand                    ; 1 frame.
    byte 0                     ; Frame 1.

sound_walk                     ; 31 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    .noise_attenuation 4       ; Frame 8.
    byte 0                     ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.
    byte 0                     ; Frame 18.
    byte 0                     ; Frame 19.
    byte 0                     ; Frame 20.
    byte 0                     ; Frame 21.
    byte 0                     ; Frame 22.
    byte 0                     ; Frame 23.
    .noise_attenuation 4       ; Frame 24.
    byte 0                     ; Frame 25.
    byte 0                     ; Frame 26.
    byte 0                     ; Frame 27.
    byte 0                     ; Frame 28.
    byte 0                     ; Frame 29.
    byte 0                     ; Frame 30.
    byte 0                     ; Frame 31.

sound_run                      ; 22 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    .noise_attenuation 4       ; Frame 8.
    byte 0                     ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.
    byte 0                     ; Frame 18.
    .noise_attenuation 4       ; Frame 19.
    byte 0                     ; Frame 20.
    byte 0                     ; Frame 21.
    byte 0                     ; Frame 22.

sound_walk_backward            ; 36 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    .noise_attenuation 4       ; Frame 8.
    byte 0                     ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.
    byte 0                     ; Frame 18.
    byte 0                     ; Frame 19.
    byte 0                     ; Frame 20.
    byte 0                     ; Frame 21.
    byte 0                     ; Frame 22.
    byte 0                     ; Frame 23.
    byte 0                     ; Frame 24.
    byte 0                     ; Frame 25.
    .noise_attenuation 4       ; Frame 26.
    byte 0                     ; Frame 27.
    byte 0                     ; Frame 28.
    byte 0                     ; Frame 29.
    byte 0                     ; Frame 30.
    byte 0                     ; Frame 31.
    byte 0                     ; Frame 32.
    byte 0                     ; Frame 33.
    byte 0                     ; Frame 34.
    byte 0                     ; Frame 35.
    byte 0                     ; Frame 36.

sound_run_backward             ; 19 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 0                     ; Frame 8.
    .noise_attenuation 4       ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.
    byte 0                     ; Frame 18.
    .noise_attenuation 4       ; Frame 19.

    even
