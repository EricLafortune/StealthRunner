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

* Subroutines to display supersprites, which are collages of quadsprites.

* Subroutine: initialize the quadsprite cache.
* LOCAL r0
* LOCAL r1
* LOCAL r2
initialize_quadsprites
    clr  @vdp_quadsprite_counter

    li   r0, vdp_quadsprite_numbers
    li   r1, 1024
!
    seto *r0+
    dec  r1
    jne  -!

    li   r0, vdp_quadsprite_timestamps
    li   r1, 64
!
    seto *r0+
    dec  r1
    jne  -!

    li   r0, cpu_quadsprite_numbers
    li   r1, 64
!
    seto *r0+
    dec  r1
    jne  -!
    rt


* Subroutine: add the quadsprites of a specified supersprite to the sprite
* attribute table, starting at the current VDP address.
* Adds quadsprites whose patterns still need to be written to VDP memory to
* a cache queue.
* IN OUT r0:    the current address in the cache queue.
* IN     r1:    the supersprite number.
* IN     r2:    the supersprite x ordinate on the screen.
* IN     r3:    the supersprite y ordinate on the screen.
* IN     vdpwa: the destination address in the VDP sprite descriptor table.
* LOCAL  r4:    the current quadsprite number in the position list.
* LOCAL  r5:    the last quadsprite number in the position list.
* LOCAL  r6:    the quadsprite x ordinate.
* LOCAL  r7:    the quadsprite y ordinate, color.
* LOCAL  r11:   the subroutine return address.
draw_supersprite
    ci    r2, -128             ; Is the supersprite off-screen horizontally?
    jlt   draw_supersprite_end
    ci    r2, 255
    jgt   draw_supersprite_end

    ci    r3, -128             ; Is the supersprite off-screen vertically?
    jlt   draw_supersprite_end
    ci    r3, 191
    jgt   draw_supersprite_end

draw_small_supersprite         ; Alternative entry point without early clipping.
    .switch_bank @sprite_index_bank

    sla  r1, 1                 ; Compute the address in the supersprite index.
    ai   r1, >6000

    mov  *r1+, r4              ; Get the position number of the first quadsprite.
    mov  *r1+, r5              ; Get the position number after the last quadsprite.

    mov  r4, r1                ; Compute the CPU source memory bank of the
    andi r1, >fc00             ; quadsprite entry (position, color, pattern index;
    srl  r1, 9                 ; 8 bytes each, 1024 per memory bank).
    ai   r1, sprite_positions_banks
    .switch_bank *r1           ; Switch to that memory bamk.

sprite_loop
    mov  r4, r1                ; Compute the CPU source memory address of the
    andi r1, >03ff             ; quadsprite entry (position, color, pattern index;
    sla  r1, 3                 ; 8 bytes each, 1024 per memory bank).
    ai   r1, >6000

    mov  *r1+, r6              ; Compute the quadsprite x ordinate.
    a    r2, r6

    ci    r6, -15              ; Is the quadsprite off-screen horizontally?
    jlt   sprite_skip
    ci    r6, 255
    jgt   sprite_skip

    mov  *r1+, r7              ; Compute the quadsprite y ordinate.
    a    r3, r7

    ci    r7, -15              ; Is the quadsprite off-screen vertically?
    jlt   sprite_skip
    ci    r7, 191
    jgt   sprite_skip

draw_quadsprite
* Write the y ordinate.
    dec  r7                    ; Adjust the y ordinate to start at >ff.
    swpb r7                    ; Write the y ordinate.
    .vdpwd r7

    mov  *r1+, r7              ; Get the quadsprite color.

;  mov  *r1, r7                 ; Randomize the colors of the quadsprites.
;  andi r7, >f
;  ci   r7, 1
;  jh   !
;  ori  r7, >8
;!

* Write the x ordinate.
    mov  r6, r6                ; Adjust the x ordinate if necessary, to fade in
    jgt  !                     ; gradually on the left edge of the screen.
    ai   r6, sprite_early_clock_shift
    ori  r7, sprite_early_clock_flag
!
    swpb r6                    ; Write the x ordinate.
    .vdpwd r6

* Get a suitable VDP quadsprite number (character).
    mov  *r1+, r6              ; Get the CPU quadsprite pattern number.

    sla  r6, 1                 ; Is the CPU quadsprite cached in VDP memory?
    mov  @vdp_quadsprite_numbers(r6), r1 ; (0..63 = 6 bits, shifted left 1 bit).
    c    r6, @cpu_quadsprite_numbers(r1)
    jeq  quadsprite_cached

    mov  @vdp_quadsprite_counter, r1 ; Otherwise get the next free quadsprite
                                     ; (LRU cache).

!   inct r1                    ; Find a quadsprite that is not used in this frame
    andi r1, >007e             ; (0..63 = 6 bits, shifted left 1 bit).
    c    @frame_timestamp, @vdp_quadsprite_timestamps(r1)
    jeq  -!

    mov  r1, @vdp_quadsprite_counter

    mov  r1, @vdp_quadsprite_numbers(r6) ; Remember in which VDP quadsprite
                                         ; this source quadsprite is cached.
    mov  r6, @cpu_quadsprite_numbers(r1) ; Remember which source quadsprite is
                                         ; cached in this VDP quadsprite.

    mov  r6, *r0+              ; Add the source quadsprite to the cache queue.

quadsprite_cached
                               ; Remember that this quadsprite is used in this frame.
    mov  @frame_timestamp, @vdp_quadsprite_timestamps(r1)

* Write the character and the color.
    sla  r1, 9
    .vdpwd r1                  ; Write the character.

    swpb r7
    .vdpwd r7                  ; Write the color and early clock flag.

sprite_skip
    inc  r4                    ; Continue with the next quadsprite.
    c    r4, r5                ; Are there any more quadsprites?
    jl   sprite_loop

draw_supersprite_end
    rt


* Subroutine: write the patterns of any quadsprites in the cache queue to VDP
* memory.
* IN    r0: the end of the cache queue.
* LOCAL r1
* LOCAL r2
* LOCAL r3
* LOCAL r4
* LOCAL r10
write_quadsprites
    mov  r11, r10              ; Save the return address.

    li   r3, sprite_cache_queue ; The start of the cache queue.
    mov  r0, r4                ; The end of the cache queue.

sprite_cache_loop
    c    r3, r4                ; Does the queue have any more entries?
    jhe  sprite_cache_end

    mov  *r3+, r2              ; Get the quadsprite source number.

    mov  r2, r0                ; Compute the CPU source memory bank of the
    andi r0, >fe00             ; quadsprite pattern (32 bytes each,
    srl  r0, 8                 ; 256 per memory bank).
    ai   r0, sprite_patterns_banks

    .switch_bank *r0           ; Switch to that memory bamk.

    mov  r2, r0                ; Compute the CPU source address of the
    andi r0, >01fe             ; quadsprite pattern (32 bytes each,
    sla  r0, 4                 ; 256 per memory bank).
    ai   r0, >6000

    mov  @vdp_quadsprite_numbers(r2), r1 ; Get the quadsprite destination number.
    sla  r1, 4                 ; Compute the VDP destination address of the
    ai   r1, game_sprite_descriptor_table | vdp_write_bit ; quadsprite pattern.

    .vdpwa r1                  ; Write the quadsprite pattern.
    .blit_more_bytes 32

    jmp  sprite_cache_loop

sprite_cache_end
    b    *r10
