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

* Subroutines to blit to VDP memory.
* You can should run them from scratchpad RAM for maximum performance.

* Subroutine: blit a sequence of bytes from CPU memory to VDP memory.
* IN r0:   Source address in CPU memory.
* IN r1:   Destination address in VDP memory (including write bit).
* IN r2:   Number of bytes.
* LOCAL r11
blit_bytes
    .vdpwa r1                   ; Write the VDP address.
;    a    r2, r1                 ; Update the VDP address as a return value.

* Subroutine: blit a sequence of bytes from CPU memory to VDP memory,
* starting at the current VDP address.
* IN r0:    Source address in CPU memory.
* IN vdpwa: Destination address in the VDP.
* IN r2:    Number of bytes.
* LOCAL r1
* LOCAL r11
blit_more_bytes
    dec  r2                    ; Adjust the byte count from [1...] to [0...].

    mov  r2, r1                ; Compute the branch offset into the unrolled loop.
    andi r1, >0007             ; Mask to [0..7].
    inv  r1                    ; Invert to [-1..-8].
    sla  r1, 1                 ; Scale to [-2..-16] (words).

    srl  r2, 3                 ; Adjust the number of byte sequences [0...].

    b @unrolled_blit_end(r1)

unrolled_blit_loop
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
    .vdpwd *r0+
unrolled_blit_end
    dec  r2
    joc  unrolled_blit_loop     ; Stop when the counter goes negative.
    rt

* Subroutine: blit a graphics blob (a sequence of spans, where a span is a
* list of bytes) from CPU memory to VDP memory.
* IN r0:   Source memory bank address: >6000, >6002,..., >7ffe.
* IN r1:   Source address in CPU memory.
* IN data: Destination address in VDP memory (including write bit).
* LOCAL r2
* LOCAL r3
* LOCAL r10
* LOCAL r11
blit_blob
    mov  *r11+, r3              ; Get the VDP destination address.
    mov  r11, r10               ; Save the return address.

    movb *r0, *r0               ; Switch to the specified bank.

    mov  *r1, r0                ; Get the pointer to the span.
    ai   r0, >6000              ; Add the base memory offset.

    li   r11, blob_span_loop    ; Shortcut return address for the subroutine.

* Write all spans of the blob.
blob_span_loop
    movb *r0+, r2               ; Get the span destination delta.
    srl  r2, 8
    a    r2, r3                 ; Update the VDP address for the span.

    movb *r0+, r2               ; Get the span length.
    srl  r2, 8                  ; Do we still have a span?
    jeq  end_blit

    mov  r3, r1                 ; Set the VDP address.

    a    r2, r3                 ; Update the VDP address for the next span.

    jmp  blit_bytes             ; Shortcut jump to the subroutine,
                                ; which will return to our loop.


* Subroutine: blit an opaque graphics blob (a sequence of spans, where a
* span is a list of bytes) from CPU memory to VDP memory.
* IN  r1:   Source memory bank address: >6000, >6002,..., >7ffe.
* IN  r0:   Source address in CPU memory.
* IN: data: Destination address in VDP memory (including write bit).
* LOCAL r2
* LOCAL r10
* LOCAL r11
blit_opaque_blob
    mov  *r11+, r2              ; Get the VDP destination address.
    mov  r11, r10               ; Save the return address.

    movb *r0, *r0               ; Switch to the specified bank.

    mov  *r1, r0                ; Get the pointer to the span.
    ai   r0, >6000              ; Add the base memory offset.

    .vdpwa r2                   ; Write the VDP address.

    li   r11, opaque_blob_span_loop ; Shortcut return address for the subroutine.

* Write all spans of the blob.
opaque_blob_span_loop

start_background_span
    movb *r0+, r2               ; Get the span start delta.
    srl  r2, 8
    jeq  start_foreground_span

* Write all bytes of the background span.
background_span_byte_loop
    .vdpwd r2                   ; Write a 0-byte of the background span.
    dec  r2
    jne  background_span_byte_loop

start_foreground_span
    movb *r0+, r2               ; Get the span length.
    srl  r2, 8                  ; Do we still have a span?
    jeq  end_blit

* Write all bytes of the foreground span.
    jmp  blit_more_bytes        ; Shortcut jump to the subroutine,
                                ; which will return to our loop.


* Subroutine: blit a list of clipped graphics blobs (a sequence of spans,
* where a span is a list of bytes) from CPU memory to VDP memory.
* IN r0:   Source memory bank address: >6000, >6002,...,>7ffe.
* IN r3:   Source address of the first span pointer in CPU memory.
* IN r4:   Destination clip start.
* IN r5:   Destination clip length.
* IN r6:   Span sequence count.
* IN data: Destination address in VDP memory (including write bit).
* LOCAL r1
* LOCAL r2
* LOCAL r7
* LOCAL r8
* LOCAL r9
* LOCAL r10
* LOCAL r11
blit_clipped_blobs
    mov  *r11+, r7              ; Get the VDP destination address.
    mov  r11, r10               ; Save the return address.

    movb *r0, *r0               ; Switch to the specified bank.

    a    r4, r5                 ; Convert the clip length to the clip end.

* Write all blobs.
* LOCAL r0: The current span source address (destination, length, data).
* LOCAL r7: The current clip destination address in VDP memory.
* LOCAL r8: The current span source address (start, length, data).
clipped_blobs_loop
    mov  *r3+, r8              ; Get the pointer to the span.
    ai   r8, >6000             ; Add the base memory offset.

    li   r11, clipped_blob_span_loop ; Shortcut return address for the subroutine.

* Write all spans of the blob.
* LOCAL r0: The clipped span source address (data).
* LOCAL r1: The clipped destination address in VDP memory.
* LOCAL r2: The clipped span length.
* LOCAL r9: The clipped span start.
clipped_blob_span_loop
    movb *r8+, r9               ; Get the unclipped span start.
    swpb r9
    movb *r8+, r9

    c    r9, r5                 ; Does the span start after the clip ends?
    jhe  end_clipped_span_sequence ; Then end the sequence.

    movb *r8+, r2               ; Get the span length.
    srl  r2, 8

    mov  r8, r0                 ; Get a copy of the current span address.
    a    r2, r8                 ; Update the current span address with the
                                ; span's unclipped length.

    a    r9, r2                 ; Convert the span length to the span end.

    c    r2, r4                 ; Does the span end before the clip starts?
    jle  clipped_blob_span_loop ; Then continue with the next span.

    c    r9, r4                 ; Clip the start of the span?
    jhe  !
    a    r4, r0                 ; Adjust the source address.
    s    r9, r0
    mov  r4, r9                 ; Clip the span start.
!

    c    r2, r5                 ; Clip the end of the span?
    jle  !
    mov  r5, r2                 ; Clip the span end.
!

    mov  r7, r1                 ; Compute the VDP address for the span.
    s    r4, r1
    a    r9, r1

    s    r9, r2                 ; Revert the span end to the span length.
                                ; The length is larger than 0 at this point.

    jmp  blit_bytes             ; Shortcut conditional jump to the subroutine,
                                ; which will return to our loop.

end_clipped_span_sequence
    s    r4, r7                 ; Update the destination start.
    a    r5, r7

    dec  r6
    jne  clipped_blobs_loop

end_blit
    movb @code_bank, @code_bank ; Switch back to the main bank and return.
    b    *r10
