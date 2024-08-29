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

* A subroutine to play video in the .tms format of the Video Tools.
* You can should run it from scratchpad RAM for maximum performance.

* Subroutine: play a video.
* IN    r0:  Current adress to set the module memory bank: >6000, >6002,...,>7ffe.
* LOCAL r1:  Data pointer in the current memory bank, starting at >6000.
* LOCAL r2:  Command and count.
* LOCAL r3:  Temporary variable
* IN    r10: Optionally, the SPCHWT constant.
* IN    r11: Return address.
* IN    r13: Optionally, the SOUND constant.
* IN    r14: Optionally, the VDPWD constant.
* IN    r15: Optionally, the VDPWA constant.
play_video
    li   r0, module_bank_selection + module_bank_increment ; Set the first animation bank.

* Switch to the current bank and update the number.
bank_loop
    .switch_bank *r0           ; Switch to the current bank.
    inct r0                    ; Increment the bank index.

    li   r1, module_memory     ; Set the first frame.

* Stream a chunk (video, sound, or speech).
frame_loop
    movb *r1+, r2              ; Get the pre-swapped command/count.
    swpb r2
    movb *r1+, r2
    jlt  check_sound_chunk

* Stream a chunk of video data.

; Simple version without loop unrolling.
;                               ; Write the pre-swapped VDP address.
;    movb *r1+, *r_vdpwa        ;: d-
;    nop
;    movb *r1+, *r_vdpwa        ;: d-
;    nop
;
;video_loop                     ; Copy the data to VDP RAM.
;    movb *r1+, *r_vdpwd        ;: d-
;    dec  r2
;    jne  video_loop
;    jmp  frame_loop

; Faster version with loop unrolling.
                               ; Write the pre-swapped VDP address.
    movb *r1+, *r_vdpwa        ;: d-

    dec  r2                    ; Adjust the byte count from [1...] to [0...].

    mov  r2, r3                ; Compute the branch offset into the unrolled loop.
    andi r3, >0007             ; Mask to [0..7].
    inv  r3                    ; Invert to [-1..-8].
    sla  r3, 1                 ; Scale to [-2..-16] (words).

    srl  r2, 3                 ; Scale the loop count [0...].

    movb *r1+, *r_vdpwa        ;: d-

    b @unrolled_video_loop_end(r3)

unrolled_video_loop            ; Copy the data to VDP RAM.
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
    .vdpwd *r1+                ;: d-
unrolled_video_loop_end
    dec  r2
    joc  unrolled_video_loop   ; Stop when the counter goes negative.
    jmp  frame_loop

check_sound_chunk
    ai   r2, >0020             ; Did we get a sound chunk?
    jlt  check_speech_chunk

* Stream a chunk of sound data.
sound_loop                     ; Copy the data to the sound processor.
    .sound *r1+                ;: d-
    dec  r2
    jne  sound_loop
    jmp  frame_loop            ; Continue with the rest of the frame.

check_speech_chunk
    ai   r2, >0010             ; Did we get a speech chunk?
    jlt  check_vsync_marker

* Stream a chunk of speech data.
speech_loop                    ; Copy the data to the speech synthesizer.
    .spchwt *r1+               ;: d-
    dec  r2
    jne  speech_loop
    jmp  frame_loop            ; Continue with the rest of the frame.

check_vsync_marker
    inc  r2                    ; Did we get a VSYNC marker?
    jne  check_next_bank_marker

* Wait for VSYNC.
    .wait_for_vsync
    jmp  frame_loop            ; Continue with the rest of the frame.

check_next_bank_marker
    inc  r2                    ; Did we get a NEXT_BANK marker?
    jeq  bank_loop             ; Then continue with the next bank.

                               ; Otherwise we got an EOF marker.
    .switch_bank @module_bank_selection ; Reset to the first bank.

    rt
