* Useful assembly definitions for the TI-99/4A home computer.
*
* Copyright (c) 2021-2024 Eric Lafortune
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

******************************************************************************
* Definitions and macros for accessing the speech synthesizer.
*
* Programming it is documented in
*     http://www.unige.ch/medecine/nouspikel/ti99/speech.htm
******************************************************************************

* Speech addresses.
spchrd equ  >9000
spchwt equ  >9400

* Speech commands.
speech_load_frame_rate equ >00 ; Only on the TMS5520C.
speech_read_byte       equ >10
speech_read_and_branch equ >30
speech_load_addres     equ >40 ; With the address nibbles in the lower nibble.
speech_speak           equ >50
speech_speak_external  equ >60
speech_reset           equ >70

* Status bits.
speech_status_talking      equ >80
speech_status_buffer_low   equ >40
speech_status_buffer_empty equ >20

* Macro: cache the spchrd constant in the given register, to automatically get
*        more compact spchrd macro calls later on.
* IN #1:  the register number.
* OUT #1: the spchrd constant.
    .defm spchrd_in_register
r_spchrd equ #1
    li   r_spchrd, spchrd
    .endm

* Macro: cache the spchwt constant in the given register, to automatically get
*        more compact spchwt macro calls later on.
* IN #1:  the register number.
* OUT #1: the spchwt constant.
    .defm spchwt_in_register
r_spchwt equ #1
    li   r_spchwt, spchwt
    .endm

* Macro: read the speech status byte. The macro must be executed from 16-bits
*        scratchpad RAM. It includes the necessary delay.
* OUT #1: the destination (not r0).
* LOCAL r0
    .defm speech_read_status_byte
    .spchrd #1                 ; Read the status byte.
    .delay_12
    .endm

* Macro: read the speech data byte at the given address. The macro must be
*        executed from 16-bits scratchpad RAM. It includes the necessary
*        delays.
* IN  #1: the address in the speech ROM.
* OUT #2: the destination.
* LOCAL r0
* LOCAL r1
* LOCAL r2
    .defm speech_read_data_byte
    .speech_write_address #1   ; Write the address commands.
    .delay_42
    li   r0, speech_read_byte * 256
    .spchwt r0                 ; Write the read byte command.
    .spchrd #2                 ; Read the data byte.
    .delay_12
    .endm

* Macro: write the given address to the speech synthesizer. The macro must be
*        executed from 16-bits scratchpad RAM. It does not include the 42
*        microseconds delay after having written an address.
* IN #1: the source.
* LOCAL r0
* LOCAL r1
* LOCAL r2
    .defm speech_write_address
    mov  #1, r0                ; Copy the source.
    li   r2, 5                 ; We'll write 5 nibbles.
!   mov  r0, r1                ; Get the least significant nibble.
    swpb r1
    andi r1, >0f00
    ori  r1, speech_load_addres * 256
    .spchwt r1                 ; Write the load address nibble command.
    srl  r0, 4                 ; Shift to the next nibble.
    dec  r2                    ; Loop.
    jne  -!
    .endm

* Macro: write the given value to the speech synthesizer.
* IN #1: the source.
    .defm spchwt
    .ifdef r_spchwt
    movb #1, *r_spchwt
    .else
    movb #1, @spchwt
    .endif
    .endm

* Macro: read a value from the speech synthesizer. The macro must be executed
*        from 16-bits scratchpad RAM. It does not include the 42 microseconds
*        delay after having written an address, or the 12 microseconds delay
*        after having read the data from the peripheral bus.
* OUT #1: the destination.
    .defm spchrd
    .ifdef r_spchrd
    movb *r_spchrd, #1
    .else
    movb @spchrd, #1
    .endif
    .endm

* Local macro: add a delay of 12 microseconds.
* LOCAL r0
    .defm delay_12
    ;nop                       ; Long version.
    ;nop
    ;nop
    src  r0, 12                ; Shorter version: waste 12 microseconds.
    .endm

* Local macro: add a delay of 42 microseconds.
* LOCAL r0
    .defm delay_42
    ;li   r0, 11               ; Long version.
    ;! dec  r0
    ;jne  -!
    src  r0, 13                ; Shorter version: waste 14 microseconds per instruction.
    src  r0, 13
    src  r0, 13
    .endm
