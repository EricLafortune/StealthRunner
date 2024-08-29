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
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_tone0_type_frame
    .play_sound_type_frame current_tone0, 2, >9f00, #1, #2, #3, #4
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
* LOCAL r1
    .defm play_tone0_frame
    .play_sound_frame current_tone0, 2, >9f00, #1, #2, #3
    .endm

* Macro: stop a playing tone0.
* The sound command is only sent if its source address is equal to the
* currently playing tone0 source address.
* IN #1: the constant address of the tone0 setup command.
* LOCAL r0
    .defm stop_tone0
    .stop_sound current_tone0, #1, >9f00
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
* LOCAL r1
* LOCAL #3
* LOCAL #4
    .defm play_noise_type_frame
    .play_sound_type_frame current_noise, 1, >ff00, #1, #2, #3, #4
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
* LOCAL r1
    .defm play_noise_frame
    .play_sound_frame current_noise, 1, >ff00, #1, #2, #3
    .endm

* Macro: stop a playing noise.
* The sound command is only sent if its source address is equal to the
* currently playing noise source address.
* IN #1: the constant address of the noise setup command.
* LOCAL r0
    .defm stop_noise
    .stop_sound current_noise, #1, >ff00
    .endm


* Local macro: send a sound setup command (e.g. for the frequency) and a sound
* frame command (e.g. for the changing volume) to the sound processor.
* The commands are only sent if they have a higher priority than the currently
* playing sound, i.e. if their source address is smaller.
* The setup command is only sent if the sound isn't playing yet, i.e. if its
* source address is different.
* The setup command and the frame command both are 1 byte.
* IN #1: the address that stores the current sound.
* IN #2: the number of bytes in the sound setup command (1 or 2).
* IN #3: the constant sound stop command (in the MSB).
* IN #4: the constant address of the sound setup command.
* IN #5: the constant address of the addresses of sound frame commands.
* IN #6: the register or address with the sound type number (0, 1,...)
* IN #7: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_sound_type_frame
    .ifdef #6                  ; Is parameter #6 a register?

    sla  #6, 1
    mov  @#5(#6), #6
    .ifdef #7                  ; Is parameter #7 a register?
    a    #7, #6
    .else
    a    @#7, #6
    .endif
    clr  r1
    movb *#6, r1               ; Get the sound frame command.

    .else

    mov  @#6, r1
    sla  r1, 1
    .ifdef #7                  ; Is parameter #7 a register?
    a    @#5(r1), #7
    clr  r1
    movb *#7, r1               ; Get the sound frame command.
    .else
    mov  @#5(r1), r0
    a    @#7, r0
    clr  r1
    movb *r0, r1               ; Get the sound frame command.
    .endif
    .endif

    li   r0, #4               ; Can we play our sound?
    c    r0, @#1
    jeq  !                    ; Are we already playing it?
    jh   !!!                  ; Can we play it?

    mov  r1, r1               ; Is the frame byte 0?
    jeq  !!!                  ; Then don't start playing it yet.

    mov  r0, @#1              ; Remember that we're playing it.

    .ifeq #2, 2
    .sound *r0+               ; Send the first byte of the sound setup command.
    .endif
    .sound *r0                ; Send the second byte of the sound setup command.
!
    mov  r1, r1               ; Is the frame byte 0?
    jne  !
    seto @#1                  ; Then stop playing it.
    li   r1, #3
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
* The setup command and the frame command both are 1 byte.
* IN #1: the address that stores the current sound.
* IN #2: the number of bytes in the sound setup command (1 or 2).
* IN #3: the constant sound stop command (in the MSB).
* IN #4: the constant address of the sound setup command.
* IN #5: the constant address of the sound frame commands.
* IN #6: the register or address with the frame number (0, 1,...)
* LOCAL r0
* LOCAL r1
    .defm play_sound_frame
    clr  r1                   ; Get the sound frame command...
    .ifdef #6
    movb @#5(#6), r1          ; ... from a register
    .else
    mov  @#6, r1              ; ... or from an address.
    .endif

    li   r0, #4               ; Can we play our sound?
    c    r0, @#1
    jeq  !                    ; Are we already playing it?
    jh   !!!                  ; Can we play it?

    mov  r1, r1               ; Is the frame byte 0?
    jeq  !!!                  ; Then don't start playing it yet.

    mov  r0, @#1              ; Remember that we're playing it.

    .ifeq #2, 2
    .sound *r0+               ; Send the first byte of the sound setup command.
    .endif
    .sound *r0                ; Send the second byte of the sound setup command.
!
    mov  r1, r1               ; Is the frame byte 0?
    jne  !
    seto @#1                  ; Then stop playing it.
    li   r1, #3
!
    .sound r1                 ; Send the sound frame command.
!
    .endm

* Local macro: stop a playing sound.
* The sound command is only sent if its source address is equal to the
* currently playing sound source address.
* IN #1: the address that stores the current sound.
* IN #2: the constant address of the sound setup command.
* IN #3: the constant sound stop command (in the MSB).
* LOCAL r0
    .defm stop_sound
    li   r0, #2                ; Are we still playing this sound?
    c    r0, @#1
    jne  !
    seto @#1
    li   r0, #3
    .sound r0                  ; Send the stop sound command.
!
    .endm
