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

* Macros to play sounds (tones and noises), with priorities per channel.

* Macro: send a tone0 setup command (e.g. for the frequency) and a tone0 frame
* command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone0, i.e. if their source address is smaller.
* The setup command is only sent if the tone0 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone0 setup command.
* IN #2: the constant address of the addresses of tone0 frame commands.
* IN #3: the register or address with the sound type number (0, 1,...)
* IN #4: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_tone0_type_frame
    .play_sound_type_frame 0, 2, #1, #2, #3, #4
    .endm

* Macro: send a tone0 setup command (e.g. for the frequency) and a tone0 frame
* command (e.g. for the changing volume) to the tone0 processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone0, i.e. if their source address is smaller.
* The setup command is only sent if the tone0 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone0 setup command.
* IN #2: the constant address of the tone0 frame commands.
* IN #3: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_tone0_frame
    .play_sound_frame 0, 2, #1, #2, #3
    .endm

* Macro: stop a playing tone0.
* The sound command is only sent if its source address is equal to the
* currently playing tone0 source address.
* IN #1: the constant address of the tone0 setup command.
* LOCAL r0
    .defm stop_tone0
    .stop_sound 0, #1
    .endm


* Macro: send a tone1 setup command (e.g. for the frequency) and a tone1 frame
* command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone1, i.e. if their source address is smaller.
* The setup command is only sent if the tone1 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone1 setup command.
* IN #2: the constant address of the addresses of tone1 frame commands.
* IN #3: the register or address with the sound type number (0, 1,...)
* IN #4: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_tone1_type_frame
    .play_sound_type_frame 1, 2, #1, #2, #3, #4
    .endm

* Macro: send a tone1 setup command (e.g. for the frequency) and a tone1 frame
* command (e.g. for the changing volume) to the tone1 processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone1, i.e. if their source address is smaller.
* The setup command is only sent if the tone1 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone1 setup command.
* IN #2: the constant address of the tone1 frame commands.
* IN #3: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_tone1_frame
    .play_sound_frame 1, 2, #1, #2, #3
    .endm

* Macro: stop a playing tone1.
* The sound command is only sent if its source address is equal to the
* currently playing tone1 source address.
* IN #1: the constant address of the tone1 setup command.
* LOCAL r0
    .defm stop_tone1
    .stop_sound 1, #1
    .endm


* Macro: send a tone2 setup command (e.g. for the frequency) and a tone2 frame
* command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone2, i.e. if their source address is smaller.
* The setup command is only sent if the tone2 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone2 setup command.
* IN #2: the constant address of the addresses of tone2 frame commands.
* IN #3: the register or address with the sound type number (0, 1,...)
* IN #4: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_tone2_type_frame
    .play_sound_type_frame 1, 2, #1, #2, #3, #4
    .endm

* Macro: send a tone2 setup command (e.g. for the frequency) and a tone2 frame
* command (e.g. for the changing volume) to the tone2 processor.
* The commands are only sent if they have a higher priority than the currently
* playing tone2, i.e. if their source address is smaller.
* The setup command is only sent if the tone2 isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the tone2 setup command.
* IN #2: the constant address of the tone2 frame commands.
* IN #3: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_tone2_frame
    .play_sound_frame 1, 2, #1, #2, #3
    .endm

* Macro: stop a playing tone2.
* The sound command is only sent if its source address is equal to the
* currently playing tone2 source address.
* IN #1: the constant address of the tone2 setup command.
* LOCAL r0
    .defm stop_tone2
    .stop_sound 1, #1
    .endm


* Macro: send a noise setup command (e.g. for the frequency) and a noise frame
* command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing noise, i.e. if their source address is smaller.
* The setup command is only sent if the noise isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the noise setup command.
* IN #2: the constant address of the addresses of noise frame commands.
* IN #3: the register or address with the sound type number (0, 1,...)
* IN #4: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_noise_type_frame
    .play_sound_type_frame 3, 1, #1, #2, #3, #4
    .endm

* Macro: send a noise setup command (e.g. for the frequency) and a noise frame
* command (e.g. for the changing volume) to the noise processor.
* The commands are only sent if they have a higher priority than the currently
* playing noise, i.e. if their source address is smaller.
* The setup command is only sent if the noise isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the constant address of the noise setup command.
* IN #2: the constant address of the noise frame commands.
* IN #3: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_noise_frame
    .play_sound_frame 3, 1, #1, #2, #3
    .endm

* Macro: stop a playing noise.
* The sound command is only sent if its source address is equal to the
* currently playing noise source address.
* IN #1: the constant address of the noise setup command.
* LOCAL r0
    .defm stop_noise
    .stop_sound 3, #1
    .endm


* Local macro: send a sound setup command (e.g. for the frequency) and a sound
* frame command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing sound, i.e. if their source address is smaller.
* The setup command is only sent if the sound isn't playing yet, i.e. if its
* source address is different.
* The setup command is 1 or 2 bytes. The frame command is always 1 byte.
* IN #1: the generator (0..2 for tones, 3 for noise).
* IN #2: the number of bytes in the sound setup command (1 or 2).
* IN #3: the constant address of the sound setup command.
* IN #4: the constant address of the addresses of sound frame commands.
* IN #5: the register or address with the sound type number (0, 1,...)
* IN #6: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_sound_type_frame
    .ifdef #5                  ; Is parameter #5 a register?

    sla  #5, 1
    mov  @#4(#5), #5
    .ifdef #6                  ; Is parameter #6 a register?
    a    #6, #5
    .else
    a    @#6, #5
    .endif
    clr  r1
    movb *#5, r1               ; Get the sound frame command.

    .else

    mov  @#5, r1
    sla  r1, 1
    .ifdef #6                  ; Is parameter #6 a register?
    a    @#4(r1), #6
    clr  r1
    movb *#6, r1               ; Get the sound frame command.
    .else
    mov  @#4(r1), r0
    a    @#6, r0
    clr  r1
    movb *r0, r1               ; Get the sound frame command.
    .endif
    .endif

    li   r0, #3               ; Can we play our sound?
    c    r0, @current_tones+(#1*2)
    jeq  !                    ; Are we already playing it?
    jh   !!!                  ; Can we play it?

    mov  r1, r1               ; Is the frame byte 0?
    jeq  !!!                  ; Then don't start playing it yet.

    mov  r0, @current_tones+(#1*2) ; Remember that we're playing it.

    .ifeq #2, 2
    .sound *r0+               ; Send the first byte of the sound setup command.
    .endif
    .sound *r0                ; Send the second byte of the sound setup command.
!
    mov  r1, r1               ; Is the frame byte 0?
    jne  !
    seto @current_tones+(#1*2) ; Then stop playing it.
    li   r1, >9f00|(#1<<13)
!
    .sound r1                 ; Send the sound frame command.
!
    .endm

* Local macro: send a sound setup command (e.g. for the frequency) and a sound
* frame command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing sound, i.e. if their source address is smaller.
* The setup command is only sent if the sound isn't playing yet, i.e. if its
* source address is different.
* The setup command is 1 or 2 bytes. The frame command is always 1 byte.
* IN #1: the generator (0..2 for tones, 3 for noise).
* IN #2: the number of bytes in the sound setup command (1 or 2).
* IN #3: the constant address of the sound setup command.
* IN #4: the constant address of the sound frame commands.
* IN #5: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_sound_frame
    clr  r1                   ; Get the sound frame command...
    .ifdef #5
    movb @#4(#5), r1          ; ... from a register
    .else
    mov  @#5, r1              ; ... or from an address.
    .endif

    li   r0, #3               ; Can we play our sound?
    c    r0, @current_tones+(#1*2)
    jeq  !                    ; Are we already playing it?
    jh   !!!                  ; Can we play it?

    mov  r1, r1               ; Is the frame byte 0?
    jeq  !!!                  ; Then don't start playing it yet.

    mov  r0, @current_tones+(#1*2) ; Remember that we're playing it.

    .ifeq #2, 2
    .sound *r0+               ; Send the first byte of the sound setup command.
    .endif
    .sound *r0                ; Send the second byte of the sound setup command.
!
    mov  r1, r1               ; Is the frame byte 0?
    jne  !
    seto @current_tones+(#1*2) ; Then stop playing it.
    li   r1, >9f00|(#1<<13)
!
    .sound r1                 ; Send the sound frame command.
!
    .endm

* Local macro: stop a playing sound.
* The sound command is only sent if its source address is equal to the
* currently playing sound source address.
* IN #1: the generator (0..2 for tones, 3 for noise).
* IN #2: the constant address of the sound setup command.
* LOCAL r0
    .defm stop_sound
    li   r0, #2                ; Are we still playing this sound?
    c    r0, @current_tones+(#1*2)
    jne  !
    seto @current_tones+(#1*2)
    .silence_sound_generator #1 ; Send the stop sound command.
!
    .endm

* Local macro: silence the specified sound generator.
* IN #1: the generator (0..2 for tones, 3 for noise).
* LOCAL r0
    .defm silence_sound_generator
    li   r0, >9f00|(#1<<13)
    .sound r0                  ; Send the stop sound command.
    .endm
