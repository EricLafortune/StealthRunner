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

* Macros to call the subroutines to blit to VDP memory (see blit.asm).

* Macro: blit a sequence of bytes from CPU memory to VDP memory.
* IN #1:    the constant source address in CPU memory.
* IN #2:    the constant destination address in VDP memory.
* IN #3:    the constant number of bytes.
* LOCAL r0
* LOCAL r1
* LOCAL r2
* LOCAL r11
    .defm blit_fixed_bytes
    li   r0, #1
    .blit_variable_bytes #2, #3
    .endm

* Macro: blit a sequence of bytes from CPU memory to VDP memory.
* IN r0:    the source address in CPU memory.
* IN #1:    the constant destination address in VDP memory.
* IN #2:    the constant number of bytes.
* LOCAL r1
* LOCAL r2
* LOCAL r11
    .defm blit_variable_bytes
    .li_swapped      r1, #1 | vdp_write_bit
    .vdpwa_swapped   r1
    .blit_more_bytes #2
    .endm

* Macro: blit a sequence of bytes from CPU memory to VDP memory,
* starting at the current VDP address.
* IN r0:    the source address in CPU memory.
* IN vdpwa: the destination address in the VDP.
* IN #1:    the constant number of bytes.
* LOCAL r0
* LOCAL r1
* LOCAL r2
* LOCAL r11
    .defm blit_more_bytes
    li r2, (#1 - 1) / 8
    .ifeq #1 & 7, 1
    bl @unrolled_blit_loop + 14
    .else
    .ifeq #1 & 7, 2
    bl @unrolled_blit_loop + 12
    .else
    .ifeq #1 & 7, 3
    bl @unrolled_blit_loop + 10
    .else
    .ifeq #1 & 7, 4
    bl @unrolled_blit_loop + 8
    .else
    .ifeq #1 & 7, 5
    bl @unrolled_blit_loop + 6
    .else
    .ifeq #1 & 7, 6
    bl @unrolled_blit_loop + 4
    .else
    .ifeq #1 & 7, 7
    bl @unrolled_blit_loop + 2
    .else
    .ifeq #1 & 7, 0
    bl @unrolled_blit_loop + 0
    .else
    .endif
    .endif
    .endif
    .endif
    .endif
    .endif
    .endif
    .endif
    .endm

* Macro: blit an opaque graphics blob (a sequence of spans, where a span
* is a delta, a length, and a list of bytes) from CPU memory to VDP memory.
* IN r0:   the source address of a pointer to the first span in CPU memory.
* IN #1:   the destination address in VDP memory.
* LOCAL r2
* LOCAL r3
* LOCAL r11
* LOCAL r12
    .defm blit_blob
    li   r3, #1 | vdp_write_bit ; Set the VDP destination address.

    mov  *r0, r0                ; Get the pointer to the first span.
    ai   r0, module_memory      ; Add the base memory offset.

    bl   @blit_blob             ; Blit the blob as a sequence of spans
                                ; with gaps inbetween.
    .endm

* Macro: blit an opaque graphics blob (a sequence of spans, where a span
* is a delta, a length, and a list of bytes) from CPU memory to VDP memory.
* IN r0:   the source address of a pointer to the first span in CPU memory.
* IN #1:   the destination address in VDP memory.
* LOCAL r1
* LOCAL r2
* LOCAL r11
* LOCAL r12
    .defm blit_opaque_blob
    .li_swapped r1, #1 | vdp_write_bit ; Write the VDP destination address.
    .vdpwa r1

    mov  *r0, r0                ; Get the pointer to the first span.
    ai   r0, module_memory      ; Add the base memory offset.

    bl   @blit_opaque_blob      ; Blit the blob as an uninterrupted stream
                                ; of bytes.
    .endm

* Macro: blit a list of clipped graphics blobs (a list of addresses, each
* pointing to a sequence of spans, where a span is a world span start word,
* a length byte, and an offset byte in the shared list of 256 data bytes at
* >7f00) from CPU memory to VDP memory.
* IN r3:   the source address of the first span row in CPU memory.
* IN r4:   the world clip start.
* IN r5:   the world clip length.
* IN r6:   the row count.
* IN #1:   the destination base address in VDP memory.
* LOCAL r0
* LOCAL r1
* LOCAL r2
* LOCAL r7
* LOCAL r8
* LOCAL r9
* LOCAL r11
* LOCAL r12
    .defm blit_clipped_blobs
    li   r7, #1 | vdp_write_bit ; Set the VDP destination base address.

    bl   @blit_clipped_blobs
    .endm
