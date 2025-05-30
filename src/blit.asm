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
* You should run them from scratchpad RAM for maximum performance.

* Subroutine: blit a graphics blob (a sequence of spans, where a span is a
* a delta byte, a length byte, and a list of data bytes) from CPU memory to
* VDP memory.
* IN r0: the source address of the first span in CPU memory.
* IN r3: the destination address in VDP memory (including write bit).
* LOCAL r1
* LOCAL r2
* LOCAL r11
* LOCAL r12
blit_blob
    mov  r11, r12              ; Save the return address.

    li   r11, blob_span_loop   ; Shortcut return address for the subroutine.

* Write all spans of the blob.
blob_span_loop
    movb *r0+, r2              ; Get the span destination delta.
    srl  r2, 8
    a    r2, r3                ; Update the VDP address for the span.

    movb *r0+, r2              ; Get the span length.
    srl  r2, 8                 ; Do we still have a span?
    jeq  end_blit

    mov  r3, r1                ; Set the VDP address.

    a    r2, r3                ; Update the VDP address for the next span.

                               ; Fall-through to the blitting subroutine,
                               ; which will return to our loop.

* Subroutine: blit a sequence of bytes from CPU memory to VDP memory.
* IN r0:   the source address in CPU memory.
* IN r1:   the destination address in VDP memory (including write bit).
* IN r2:   the number of bytes.
* LOCAL r11
blit_bytes
    .vdpwa r1                  ; Write the VDP address.

* Subroutine: blit a sequence of bytes from CPU memory to VDP memory,
* starting at the current VDP address.
* IN r0:    the source address in CPU memory.
* IN vdpwa: the destination address in the VDP.
* IN r2:    the number of bytes.
* LOCAL r1
* LOCAL r11
blit_more_bytes
    dec  r2                    ; Adjust the byte count from [1...] to [0...].

    mov  r2, r1                ; Compute the branch offset into the unrolled loop.
    andi r1, >0007             ; Mask to [0..7].
    inv  r1                    ; Invert to [-1..-8].
    sla  r1, 1                 ; Scale to [-2..-16] (words).

    srl  r2, 3                 ; Adjust the number of byte sequences [0...].

    b @unrolled_blit_end(r1)   ; Branch into the instruction sequence, counting
                               ; back from the end, one word per instruction.
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
    joc  unrolled_blit_loop    ; Stop when the counter goes negative.
    rt


* Subroutine: blit an opaque graphics blob (a sequence of spans, where a span
* is a delta, a length, and a list of bytes) from CPU memory to VDP memory.
* IN r0:    the source address of the first span in CPU memory.
* IN vdpwa: the destination address in the VDP.
* LOCAL r1
* LOCAL r2
* LOCAL r11
* LOCAL r12
blit_opaque_blob
    mov  r11, r12              ; Save the return address.

    li   r11, opaque_blob_span_loop ; Shortcut return address for the subroutine.

* Write all spans of the blob.
opaque_blob_span_loop

start_background_span
    movb *r0+, r2              ; Get the span start delta.
    srl  r2, 8
    jeq  start_foreground_span

* Write all bytes of the background span.
background_span_byte_loop
    .vdpwd r2                  ; Write a 0-byte of the background span.
    dec  r2
    jne  background_span_byte_loop

start_foreground_span
    movb *r0+, r2              ; Get the span length.
    srl  r2, 8                 ; Do we still have a span?
    jeq  end_blit

* Write all bytes of the foreground span.
    jmp  blit_more_bytes       ; Shortcut jump to the subroutine,
                               ; which will return to our loop.


* Subroutine: blit a list of clipped graphics blobs (a list of addresses, each
* pointing to a sequence of spans, where a span is a world span start word,
* a length byte, and an offset byte in the shared list of 256 data bytes at
* >7f00) from CPU memory to VDP memory.
* IN r3:   the first address in the source row table in CPU memory.
* IN r4:   the world clip start (x ordinate).
* IN r5:   the world clip length (width).
* IN r6:   the row count (height).
* IN r7:   the destination base address in VDP memory (including write bit).
* LOCAL r0
* LOCAL r1
* LOCAL r2
* LOCAL r8:  the destination clip end.
* LOCAL r9
* LOCAL r10
* LOCAL r11: return address for the blit subroutine.
* LOCAL r12
blit_clipped_blobs
    mov  r11, r12              ; Save the return address.

    mov  r4, r8                ; Compute the clip end.
    a    r5, r8

    li   r11, clipped_blob_span_loop ; Shortcut return address for the
                                     ; blit subroutine.

* Write all rows of the blob.
* LOCAL r10: the current address in the span table.
clipped_blob_row_loop
    mov  *r3+, r10              ; Get the address of the first span.

* Write all spans of the row.
* LOCAL r0: the clipped span source address (data).
* LOCAL r1: the clipped destination address in VDP memory.
* LOCAL r2: the clipped span length.
* LOCAL r9: the clipped span start.
clipped_blob_span_loop
    c    r10, *r3              ; Have we checked all spans of this row?
    jhe  end_clipped_span_sequence ; Then end the sequence.

    mov  *r10+, r9             ; Get the unclipped span start.

    c    r9, r8                ; Does the span start after the clip ends?
    jhe  end_clipped_span_sequence ; Then end the sequence.

    movb *r10+, r2             ; Get the span length.
    srl  r2, 8

    movb *r10+, r0             ; Get the span data offset.

    a    r9, r2                ; Convert the span length to the span end,
                               ; so we can clip it.

    c    r2, r4                ; Does the span end before the clip starts?
    jle  clipped_blob_span_loop ; Then continue with the next span.

    srl  r0, 8                 ; Compute the span data source address.
    ai   r0, module_memory + >1f00

    c    r9, r4                ; Clip the start of the span?
    jhe  !
    a    r4, r0                ; Adjust the source address.
    s    r9, r0
    mov  r4, r9                ; Clip the span start.
!

    c    r2, r8                ; Clip the end of the span?
    jle  !
    mov  r8, r2                ; Clip the span end.
!
    mov  r7, r1                ; Compute the VDP address for the span.
    s    r4, r1
    a    r9, r1

    s    r9, r2                ; Revert the span end to the span length.
                               ; The length is larger than 0 at this point.

    jmp  blit_bytes            ; Shortcut to the subroutine, which will
                               ; return to our loop.

end_clipped_span_sequence
    a    r5, r7                ; Update the VDP base address.

    dec  r6                    ; Continue with the next row.
    jne  clipped_blob_row_loop

end_blit
    b    *r12                  ; Return to the caller.
