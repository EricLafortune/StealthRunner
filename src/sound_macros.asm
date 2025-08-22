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

* Macros to play simple sounds (tones and noises), with priorities per channel.

* Macro: reset the sound pointers.
    .defm reset_sound
    seto @current_tone
    seto @current_noise
    .endm

* Macro: queue the tone data at the given address, if it has a higher
* priority than currently playing tone. Already send the frequency data to
* the sound chip.
* IN #1: the constant address, or a register containing the address, of the
*        tone data (frequency bytes followed by a sequence of volume bytes).
* IN OUT current_tone
* LOCAL r0
    .defm start_tone
    .ifdef #1
    c    #1, @current_tone     ; Does the currently playing tone have a lower
    jhe  !                     ; priority?

    .sound *#1+                ; Set up the tone frequency.
    .sound *#1+

    mov  #1, @current_tone     ; Queue the rest of the tone data.
!
    .else
    li   r0, #1
    c    r0, @current_tone     ; Does the currently playing tone have a lower
    jhe  !                     ; priority?

    .sound *r0+                ; Set up the tone frequency.
    .sound *r0+

    mov  r0, @current_tone     ; Queue the rest of the tone data.
!
    .endif
    .endm

* Macro: send currently queued tone volume data (if any) to the sound chip.
* IN OUT current_tone
* LOCAL r0
* LOCAL r1
    .defm play_tone
    mov  @current_tone, r0     ; Do we have any tone queued?
    jlt  !!!

    .switch_bank @data_bank    ; The sound is in the data bank.

    movb *r0+, r1              ; Get the tone data.
    jne  !                     ; Are we out of data?

    .silence_sound_generator 2 ; Then stop the tone.
    seto r0                    ; Clear the queue.
    jmp  !!
!
    .sound r1                  ; Otherwise send the tone data.
!
    mov  r0, @current_tone     ; Save the tone pointer.
!
    .endm

* Macro: queue the noise data at the given address, if it has a higher
* priority than currently playing noise. Already send the frequency data to
* the sound chip.
* IN #1: the constant address, or a register containing the address, of the
*        noise data (frequency bytes followed by a sequence of volume bytes).
* IN OUT current_noise
* LOCAL r0
    .defm start_noise
    .ifdef #1
    c    #1, @current_noise    ; Does the currently playing noise have a lower
    jhe  !                     ; priority?

    .sound *#1+                ; Set up the noise frequency.

    mov  #1, @current_noise    ; Queue the rest of the noise data.
!
    .else
    li   r0, #1
    c    r0, @current_noise    ; Does the currently playing noise have a lower
    jhe  !                     ; priority?

    .sound *r0+                ; Set up the noise frequency.
    .sound *r0+

    mov  r0, @current_noise    ; Queue the rest of the noise data.
!
    .endif
    .endm

* Macro: send currently queued noise volume data (if any) to the sound chip.
* IN OUT current_noise
* LOCAL r0
* LOCAL r1
    .defm play_noise
    mov  @current_noise, r0    ; Do we have any noise queued?
    jlt  !!!

    .switch_bank @data_bank    ; The sound is in the data bank.

    movb *r0+, r1              ; Get the noise data.
    jne  !                     ; Are we out of data?

    .silence_sound_generator 3 ; Then stop the noise.
    seto r0                    ; Clear the queue.
    jmp  !!
!
    .sound r1                  ; Otherwise send the noise data.
!
    mov  r0, @current_noise    ; Save the noise pointer.
!
    .endm

* Local macro: silence the specified sound generator.
* IN #1: the generator (0..2 for tones, 3 for noise).
* LOCAL r0
    .defm silence_sound_generator
    li   r0, >9f00|(#1<<13)
    .sound r0                  ; Send the stop sound command.
    .endm
