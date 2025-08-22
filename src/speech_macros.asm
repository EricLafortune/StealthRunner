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

* Macros to send speech data to the speech synthesizer.

* Macro: reset the speech pointers.
    .defm reset_speech
    clr  @current_speech
    clr  @current_speech_length
    seto @message_spoken
    .endm

* Macro: queue the speech data at the given address, if nothing else is being
* sent. We're not yet sending any speech data here, in order to keep it fast.
* IN #1: the constant address of the speech data (length + LPC data bytes).
* Alternatively, with two arguments:
* IN #1: the source containing the address of the speech data.
* IN #2: a temporary register.
* IN OUT current_speech
* IN OUT current_speech_length
* LOCAL r0
    .defm start_speech
    .ifndef #2                 ; Constant speech data address?
    mov  @current_speech_length, r0 ; Is any speech playing?
    jne  !
    li   r0, #1                ; Queue the length and data.
    mov  r0, @current_speech
    .else                      ; Variable speech data address.
    mov  @current_speech_length, #2 ; Is any speech playing?
    jne  !
    mov  #1, @current_speech   ; Queue the length and data.
    .endif

    seto @current_speech_length ; With an unknown length for now.
!
    .endm

* One-time macro: send a chunk of the currently queued speech data (if any)
* to the speech synthesizer, so its speech buffer remains filled.
* IN OUT current_speech
* IN OUT current_speech_length
* LOCAL r0
* LOCAL r1
* LOCAL r2
    .defm play_speech
    mov  @current_speech_length, r1 ; Do we have any speech queued?
    jeq  play_speech_end
    jgt  check_additional_speech

check_initial_speech
    bl   @speech_read_status_byte ; Isn't any other speech playing?
    andi r2, speech_status_talking << 8
    jne  play_speech_end

send_initial_speech
    .switch_bank @speech_data_bank ; The speech is in the speech bank.

    li   r0, speech_speak_external << 8
    .spchwt r0                 ; Send the speak external command.

    mov  @current_speech, r0   ; Get the speech pointer.
    mov  *r0+, r1              ; Get the actual initial speech length.

    li   r2, 16                ; We'll start with 16 data bytes.
    jmp  cap_speech_chunk_size

check_additional_speech
    clr  r2
    bl   @speech_read_status_byte

    ci   r2, speech_status_talking << 8 ; Is it still talking,
    jeq  play_speech_end                ; with the buffer not low?

    ci   r2, (speech_status_talking | speech_status_buffer_low) << 8
    jeq  send_additional_speech         ; Is it still talking,
                                        ; with the buffer low?

    clr  r0                    ; In all other cases, the buffer must have run
    clr  r1                    ; empty before we could send additional bytes.
    jmp  update_speech_address ; Abort the speech.

send_additional_speech
    .switch_bank @speech_data_bank ; The speech is in the speech bank.

    mov  @current_speech, r0   ; Get the speech pointer.

    li   r2, 8                 ; We'll send 8 more data bytes.

cap_speech_chunk_size
    c    r2, r1                ; Cap the chunk length to the available
    jle  !                     ; number of bytes.
    mov  r1, r2
!   s    r2, r1                ; Adjust the remaining number of bytes.

send_speech_loop
    .spchwt *r0+               ; Write the chunk of speech data.
    dec  r2
    jne  send_speech_loop

update_speech_address
    mov  r0, @current_speech   ; Update the queued speech pointer and length.
    mov  r1, @current_speech_length
play_speech_end
    .endm

* One-time macro with subroutine: read the speech data/status register and
* wait the required 12 microseconds. The subroutine must be executed from
* 16-bits scratchpad RAM.
* OUT r2: the destination.
* LOCAL r0
    .defm speech_read_status_byte_subroutine
speech_read_status_byte
    .speech_read_status_byte r2
    rt
    .endm
