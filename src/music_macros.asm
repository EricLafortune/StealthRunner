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

* Macros to play music or complex sounds stored in our custom SND format.

* Macro: queue the music data at the given address, if nothing else is being
* sent. We're not yet sending any music data here, in order to keep it fast.
* IN #1: the constant address of the music data (chunks of length + data
*        bytes).
* IN OUT current_music
* LOCAL r0
    .defm start_music
    mov  @current_music, r0    ; Is any music playing?
    jne  !
    li   r0, #1                ; Queue the sound data.
    mov  r0, @current_music
!
    .endm

* One-time macro: send a chunk of the currently queued music data (if any)
* to the sound chip.
* IN OUT current_music
* LOCAL r0
* LOCAL r1
    .defm play_music
    mov  @current_music, r0    ; Do we have any music queued?
    jeq  !!!! ; play_music_end

    .switch_bank @data_bank    ; The music is in the data bank.

    movb *r0+, r1              ; Get the chunk length.
    sra  r1, 8
    jgt  ! ; send_music_chunk      ; Does the chunk contain any bytes?
    jeq  !!! ; update_current_music  ; Is there any music left?

    clr  r0                    ; Otherwise just clear the queue.
    jmp  !!! ; update_current_music

! ; send_music_chunk

! ; send_music_loop
    .sound *r0+                ; Send the sound bytes.
    dec  r1
    jne  -! ; send_music_loop

! ; update_current_music
    mov  r0, @current_music    ; Save the queued music pointer.

! ; play_music_end
    .endm
