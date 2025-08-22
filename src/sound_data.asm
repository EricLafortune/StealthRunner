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
                               ; 16 frames.
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

* Medium explosion.
sound_medium_explosion
    .noise_frequency white_noise, 1
                               ; 8 frames.
    .noise_attenuation 0       ; Frame 0.
    .noise_attenuation 2       ; Frame 1.
    .noise_attenuation 4       ; Frame 2.
    .noise_attenuation 6       ; Frame 3.
    .noise_attenuation 8       ; Frame 4.
    .noise_attenuation 10      ; Frame 5.
    .noise_attenuation 12      ; Frame 6.
    byte 0                     ; Frame 7.

* Short explosion.
sound_short_explosion
    .noise_frequency white_noise, 2
                               ; 4 frames.
    .noise_attenuation 0       ; Frame 0.
    .noise_attenuation 6       ; Frame 1.
    .noise_attenuation 12      ; Frame 2.
    byte 0                     ; Frame 3.

* Click.
sound_click
    .noise_frequency white_noise, 2
    .noise_attenuation 0
    byte 0

* A bullet approaching from the distance.
sound_bullet_flying
    .noise_frequency white_noise, 0
                               ; 32 frames.
    .noise_attenuation 0       ; Frame 0.
    .noise_attenuation 0       ; Frame 1.
    .noise_attenuation 1       ; Frame 2.
    .noise_attenuation 1       ; Frame 3.
    .noise_attenuation 2       ; Frame 4.
    .noise_attenuation 2       ; Frame 5.
    .noise_attenuation 3       ; Frame 6.
    .noise_attenuation 3       ; Frame 7.
    .noise_attenuation 4       ; Frame 8.
    .noise_attenuation 4       ; Frame 9.
    .noise_attenuation 5       ; Frame 10.
    .noise_attenuation 5       ; Frame 11.
    .noise_attenuation 6       ; Frame 12.
    .noise_attenuation 6       ; Frame 13.
    .noise_attenuation 7       ; Frame 14.
    .noise_attenuation 7       ; Frame 15.
    .noise_attenuation 8       ; Frame 16.
    .noise_attenuation 8       ; Frame 17.
    .noise_attenuation 9       ; Frame 18.
    .noise_attenuation 9       ; Frame 19.
    .noise_attenuation 10      ; Frame 20.
    .noise_attenuation 10      ; Frame 21.
    .noise_attenuation 11      ; Frame 22.
    .noise_attenuation 11      ; Frame 23.
    .noise_attenuation 12      ; Frame 24.
    .noise_attenuation 12      ; Frame 25.
    .noise_attenuation 13      ; Frame 26.
    .noise_attenuation 13      ; Frame 27.
    .noise_attenuation 14      ; Frame 28.
    .noise_attenuation 14      ; Frame 29.
    .noise_attenuation 14      ; Frame 30.
    byte 0                     ; Frame 31.

* A shell being launched.
sound_shell_flying
    .tone_frequency 2, 1023
                               ; 32 frames.
    .tone_attenuation 2, 11    ; Frame 0.
    .tone_attenuation 2, 7     ; Frame 1.
    .tone_attenuation 2, 3     ; Frame 2.
    .tone_attenuation 2, 0     ; Frame 3.
    .tone_attenuation 2, 2     ; Frame 4.
    .tone_attenuation 2, 4     ; Frame 5.
    .tone_attenuation 2, 6     ; Frame 6.
    .tone_attenuation 2, 8     ; Frame 7.
    .tone_attenuation 2, 10    ; Frame 8.
    .tone_attenuation 2, 11    ; Frame 9.
    .tone_attenuation 2, 12    ; Frame 10.
    .tone_attenuation 2, 13    ; Frame 11.
    .tone_attenuation 2, 14    ; Frame 12.
    .tone_attenuation 2, 14    ; Frame 13.
    .tone_attenuation 2, 14    ; Frame 14.
    byte 0                     ; Frame 15.
                               ; Frame 16.
                               ; Frame 17.
                               ; Frame 18.
                               ; Frame 19.
                               ; Frame 20.
                               ; Frame 21.
                               ; Frame 22.
                               ; Frame 23.
                               ; Frame 24.
                               ; Frame 25.
                               ; Frame 26.
                               ; Frame 27.
                               ; Frame 28.
                               ; Frame 29.
                               ; Frame 30.
                               ; Frame 31.

* A drone in the distance.
sound_drone_flying
    .noise_frequency periodic_noise, 2
                               ; 32 frames.
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

    even

* Picking up an object.
pickup_sounds
    data sound_medkit_pickup
    data sound_stone_pickup
    data sound_emp_pickup
    data sound_grenade_pickup

sound_medkit_pickup
    .tone_frequency 2, note_A3

    .tone_attenuation 2, 0
    .tone_attenuation 2, 1
    .tone_attenuation 2, 2
    .tone_attenuation 2, 3
    .tone_attenuation 2, 4
    .tone_attenuation 2, 5
    .tone_attenuation 2, 6
    .tone_attenuation 2, 7
    .tone_attenuation 2, 8
    .tone_attenuation 2, 9
    .tone_attenuation 2, 10
    .tone_attenuation 2, 11
    .tone_attenuation 2, 12
    .tone_attenuation 2, 13
    .tone_attenuation 2, 14
    byte 0

sound_stone_pickup
    .tone_frequency 2, note_A0

    .tone_attenuation 2, 0
    .tone_attenuation 2, 2
    .tone_attenuation 2, 4
    .tone_attenuation 2, 6
    .tone_attenuation 2, 8
    .tone_attenuation 2, 10
    .tone_attenuation 2, 12
    byte 0

sound_emp_pickup
    .tone_frequency 2, note_A2

    .tone_attenuation 2, 0
    .tone_attenuation 2, 1
    .tone_attenuation 2, 2
    .tone_attenuation 2, 3
    .tone_attenuation 2, 4
    .tone_attenuation 2, 5
    .tone_attenuation 2, 6
    .tone_attenuation 2, 7
    .tone_attenuation 2, 8
    .tone_attenuation 2, 9
    .tone_attenuation 2, 10
    .tone_attenuation 2, 11
    .tone_attenuation 2, 12
    .tone_attenuation 2, 13
    .tone_attenuation 2, 14
    byte 0

sound_grenade_pickup
    .tone_frequency 2, note_A1

    .tone_attenuation 2, 0
    .tone_attenuation 2, 1
    .tone_attenuation 2, 2
    .tone_attenuation 2, 3
    .tone_attenuation 2, 4
    .tone_attenuation 2, 5
    .tone_attenuation 2, 6
    .tone_attenuation 2, 7
    .tone_attenuation 2, 8
    .tone_attenuation 2, 9
    .tone_attenuation 2, 10
    .tone_attenuation 2, 11
    .tone_attenuation 2, 12
    .tone_attenuation 2, 13
    .tone_attenuation 2, 14
    byte 0

    even

* Launching weapons.
launch_sounds
    data sound_stone_flying
    data sound_emp_flying
    data sound_grenade_flying

* A thrown stone disappearing in the distance.
sound_stone_flying
    .tone_frequency 2, 500
                               ; 32 frames.
    .tone_attenuation 2, 11    ; Frame 0.
    .tone_attenuation 2, 7     ; Frame 1.
    .tone_attenuation 2, 3     ; Frame 2.
    .tone_attenuation 2, 0     ; Frame 3.
    .tone_attenuation 2, 2     ; Frame 4.
    .tone_attenuation 2, 4     ; Frame 5.
    .tone_attenuation 2, 6     ; Frame 6.
    .tone_attenuation 2, 8     ; Frame 7.
    .tone_attenuation 2, 10    ; Frame 8.
    .tone_attenuation 2, 11    ; Frame 9.
    .tone_attenuation 2, 12    ; Frame 10.
    .tone_attenuation 2, 13    ; Frame 11.
    .tone_attenuation 2, 14    ; Frame 12.
    .tone_attenuation 2, 14    ; Frame 13.
    .tone_attenuation 2, 14    ; Frame 14.
    byte 0                     ; Frame 15.
                               ; Frame 16.
                               ; Frame 17.
                               ; Frame 18.
                               ; Frame 19.
                               ; Frame 20.
                               ; Frame 21.
                               ; Frame 22.
                               ; Frame 23.
                               ; Frame 24.
                               ; Frame 25.
                               ; Frame 26.
                               ; Frame 27.
                               ; Frame 28.
                               ; Frame 29.
                               ; Frame 30.
                               ; Frame 31.

* A thrown stone hitting the ground.
sound_stone_landing
    .noise_frequency white_noise, 0

    .noise_attenuation 6
    .noise_attenuation 10
    .noise_attenuation 14
    byte 0

* A fired EMP disappearing in the distance.
sound_emp_flying
    .tone_frequency 2, 100
                               ; 31 frames.
    .tone_attenuation 2, 0     ; Frame 0.
    .tone_attenuation 2, 1     ; Frame 1.
    .tone_attenuation 2, 1     ; Frame 2.
    .tone_attenuation 2, 0     ; Frame 3.
    .tone_attenuation 2, 2     ; Frame 4.
    .tone_attenuation 2, 3     ; Frame 5.
    .tone_attenuation 2, 3     ; Frame 6.
    .tone_attenuation 2, 2     ; Frame 7.
    .tone_attenuation 2, 4     ; Frame 8.
    .tone_attenuation 2, 5     ; Frame 9.
    .tone_attenuation 2, 5     ; Frame 10.
    .tone_attenuation 2, 4     ; Frame 11.
    .tone_attenuation 2, 6     ; Frame 12.
    .tone_attenuation 2, 7     ; Frame 13.
    .tone_attenuation 2, 7     ; Frame 14.
    .tone_attenuation 2, 6     ; Frame 15.
    .tone_attenuation 2, 8     ; Frame 16.
    .tone_attenuation 2, 9     ; Frame 17.
    .tone_attenuation 2, 9     ; Frame 18.
    .tone_attenuation 2, 8     ; Frame 19.
    .tone_attenuation 2, 10    ; Frame 20.
    .tone_attenuation 2, 11    ; Frame 21.
    .tone_attenuation 2, 11    ; Frame 22.
    .tone_attenuation 2, 10    ; Frame 23.
    .tone_attenuation 2, 12    ; Frame 24.
    .tone_attenuation 2, 13    ; Frame 25.
    .tone_attenuation 2, 13    ; Frame 26.
    .tone_attenuation 2, 12    ; Frame 27.
    .tone_attenuation 2, 14    ; Frame 28.
    .tone_attenuation 2, 14    ; Frame 29.
    .tone_attenuation 2, 14    ; Frame 30.
    byte 0                     ; Frame 31.

* A thrown grenade disappearing in the distance.
sound_grenade_flying
    .tone_frequency 2, 400
                               ; 32 frames.
    .tone_attenuation 2, 11    ; Frame 0.
    .tone_attenuation 2, 7     ; Frame 1.
    .tone_attenuation 2, 3     ; Frame 2.
    .tone_attenuation 2, 0     ; Frame 3.
    .tone_attenuation 2, 2     ; Frame 4.
    .tone_attenuation 2, 4     ; Frame 5.
    .tone_attenuation 2, 6     ; Frame 6.
    .tone_attenuation 2, 8     ; Frame 7.
    .tone_attenuation 2, 10    ; Frame 8.
    .tone_attenuation 2, 11    ; Frame 9.
    .tone_attenuation 2, 12    ; Frame 10.
    .tone_attenuation 2, 13    ; Frame 11.
    .tone_attenuation 2, 14    ; Frame 12.
    .tone_attenuation 2, 14    ; Frame 13.
    .tone_attenuation 2, 14    ; Frame 14.
    byte 0                     ; Frame 15.
                               ; Frame 16.
                               ; Frame 17.
                               ; Frame 18.
                               ; Frame 19.
                               ; Frame 20.
                               ; Frame 21.
                               ; Frame 22.
                               ; Frame 23.
                               ; Frame 24.
                               ; Frame 25.
                               ; Frame 26.
                               ; Frame 27.
                               ; Frame 28.
                               ; Frame 29.
                               ; Frame 30.
                               ; Frame 31.

;* The player falling and dying.
;sound_dying
;    .noise_frequency white_noise, 2
;                               ; 17 frames.
;    .noise_attenuation 14      ; Frame 1.
;    .noise_attenuation 13      ; Frame 2.
;    .noise_attenuation 12      ; Frame 3.
;    .noise_attenuation 11      ; Frame 4.
;    .noise_attenuation 10      ; Frame 5.
;    .noise_attenuation 10      ; Frame 6.
;    .noise_attenuation 10      ; Frame 7.
;    .noise_attenuation 6       ; Frame 8.
;    .noise_attenuation 0       ; Frame 9.
;    .noise_attenuation 2       ; Frame 10.
;    .noise_attenuation 2       ; Frame 11.
;    .noise_attenuation 2       ; Frame 12.
;    .noise_attenuation 2       ; Frame 13.
;    .noise_attenuation 2       ; Frame 14.
;    .noise_attenuation 2       ; Frame 15.
;    .noise_attenuation 2       ; Frame 16.
;    byte 0                     ; Frame 17.

* The player walking and running.
sound_walking
    .noise_frequency white_noise, 2
    .noise_attenuation 8
    byte 0

sound_running
    .noise_frequency white_noise, 2
    .noise_attenuation 4
    byte 0

    even

* Addresses of arrays with flags for the above walking/running sounds.
dying_sounds
    data sound_flags_die           ; 17 frames.
    data sound_flags_crouch        ; 17 frames.
walking_sounds
    data sound_flags_stand         ;  1 frame.
    data sound_flags_walk          ; 31 frames.
    data sound_flags_run           ; 22 frames.
    data sound_flags_walk_backward ; 36 frames.
    data sound_flags_run_backward  ; 19 frames.
    data sound_flags_walk          ; 31 frames.
    data sound_flags_run           ; 20 frames.
    data sound_flags_walk          ; 31 frames.
    data sound_flags_run           ; 20 frames.

sound_flags_die                ; 17 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 0                     ; Frame 8.
    byte 0                     ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.

sound_flags_crouch             ; 16 frames.
    byte 1                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 0                     ; Frame 8.
    byte 0                     ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.

sound_flags_stand              ; 1 frame.
    byte 0                     ; Frame 1.

sound_flags_walk               ; 31 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 1                     ; Frame 8.
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
    byte 1                     ; Frame 24.
    byte 0                     ; Frame 25.
    byte 0                     ; Frame 26.
    byte 0                     ; Frame 27.
    byte 0                     ; Frame 28.
    byte 0                     ; Frame 29.
    byte 0                     ; Frame 30.
    byte 0                     ; Frame 31.

sound_flags_run                ; 22 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte -1                    ; Frame 8.
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
    byte -1                    ; Frame 19.
    byte 0                     ; Frame 20.
    byte 0                     ; Frame 21.
    byte 0                     ; Frame 22.

sound_flags_walk_backward      ; 36 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 1                     ; Frame 8.
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
    byte 1                     ; Frame 26.
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

sound_flags_run_backward       ; 19 frames.
    byte 0                     ; Frame 1.
    byte 0                     ; Frame 2.
    byte 0                     ; Frame 3.
    byte 0                     ; Frame 4.
    byte 0                     ; Frame 5.
    byte 0                     ; Frame 6.
    byte 0                     ; Frame 7.
    byte 0                     ; Frame 8.
    byte -1                    ; Frame 9.
    byte 0                     ; Frame 10.
    byte 0                     ; Frame 11.
    byte 0                     ; Frame 12.
    byte 0                     ; Frame 13.
    byte 0                     ; Frame 14.
    byte 0                     ; Frame 15.
    byte 0                     ; Frame 16.
    byte 0                     ; Frame 17.
    byte 0                     ; Frame 18.
    byte -1                    ; Frame 19.

    even
