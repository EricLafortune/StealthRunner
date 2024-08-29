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

* Macros to send speech data to the speech synthesizer.

* Macro: queue the speech data at the given address, if nothing
* else is being sent.
* IN #1: the constant address of the speech data (length + LPC data bytes).
* OUT current_speech
* LOCAL r0
    .defm start_speech
    mov  @current_speech_length, r0 ; Is any speech playing?
    jne  !
    li   r0, #1                ; Queue our data.
    mov  r0, @current_speech
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
    jgt  send_additional_data

send_initial_data
    bl   @speech_read_status_byte ; Isn't any other speech playing?
    andi r2, speech_status_talking * 256
    jne  play_speech_end

    .switch_bank @speech_data_bank ; The speech is in the speech bank.

    li   r0, speech_speak_external * 256
    .spchwt r0                 ; Send the speak external command.

    mov  @current_speech, r0   ; Get the speech pointer.
    mov  *r0+, r1              ; Get the actual initial speech length.

    li   r2, 16                ; We'll start with 16 data bytes.
    jmp  cap_speech_chunk_size

send_additional_data
    bl   @speech_read_status_byte ; Is the buffer sufficiently low?
    andi r2, speech_status_buffer_low * 256
    jeq  play_speech_end

    .switch_bank @speech_data_bank ; The speech is in the speech bank.

    mov  @current_speech, r0   ; Get the speech pointer.

    li   r2, 9                 ; We'll send 9 more data bytes.

cap_speech_chunk_size
    c    r2, r1                ; Cap the chunk length to the available
    jle  !                     ; number of bytes.
    mov  r1, r2
!   s    r2, r1                ; Adjust the remaining number of bytes.

send_speech_loop
    .spchwt *r0+               ; Write the chunk of speech data.
    dec  r2
    jne  send_speech_loop

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
