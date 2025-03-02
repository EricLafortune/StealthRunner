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

* A supersprite can in principle cover any area.
* For performance, we're culling by assuming approximate visual bounds of
* 100x100 pixels, * centered around the player base (128,112).
supersprite_center_x equ player_base_x
supersprite_center_y equ player_base_y
supersprite_width    equ 100
supersprite_height   equ 100

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
* LOCAL  r4:    the supersprite position/color/pattern offset.
* LOCAL  r5:    the quadsprite x ordinate.
* LOCAL  r6:    the quadsprite y ordinate, color.
* LOCAL  r7:    the number of quadsprites in this supersprite.
* LOCAL  r11:   the quadsprite subroutine return address.
* LOCAL  r12:   the subroutine return address.
* LOCAL  r13:   the memory bank address.
* IN     vdpwa: the destination address in the VDP sprite descriptor table.
draw_supersprite
    mov   r11, r12             ; Save the return address.

    .switch_bank @sprite_bounds_bank

    mov  r1, r4                ; Compute the address of the supersprite bounds
    sla  r4, 3                 ; (8 bytes per bounds, max 1024 entries).
    ai   r4, >6000

    c    r2, *r4+              ; Is the supersprite off-screen horizontally?
    jlt  draw_supersprite_end
    c    r2, *r4+
    jgt  draw_supersprite_end

    c    r3, *r4+              ; Is the supersprite off-screen vertically?
    jlt  draw_supersprite_end
    c    r3, *r4
    jgt  draw_supersprite_end

    .switch_bank @sprite_index_bank

    sla  r1, 1                 ; Compute the address in the supersprite index
    ai   r1, >6000             ; (2 bytes per index, max 4096 entries).

    mov  *r1+, r4              ; Get the position number of the first quadsprite.
    mov  *r1, r7               ; Get the position number after the last quadsprite.

    s    r4, r7                ; Compute the number of quadsprites.

    mov  r4, r13               ; Compute the CPU source memory bank of the
    andi r13, >fc00            ; quadsprite entry (position, color, pattern index;
    srl  r13, 9                ; 8 bytes each, 1024 per memory bank).
    ai   r13, sprite_positions_banks
    .switch_bank *r13          ; Switch to that memory bamk.

    andi r4, >03ff             ; Compute the CPU source memory address of the
    sla  r4, 3                 ; quadsprite entry in this memory bank.
    ai   r4, >6000

quadsprite_loop
    mov  *r4+, r5              ; Compute the quadsprite x ordinate.
    a    r2, r5

    ci    r5, -15              ; Is the quadsprite off-screen horizontally?
    jlt   skip_quadsprite      ; (rarely)
    ci    r5, 255
    jgt   skip_quadsprite

    mov  *r4+, r6              ; Compute the quadsprite y ordinate.
    a    r3, r6

    ci    r6, -15              ; Is the quadsprite off-screen vertically?
    jlt   skip_quadsprite      ; (rarely)
    ci    r6, 191
    jgt   skip_quadsprite

    bl    @draw_quadsprite     ; Draw the quadsprite.

    dec  r7                    ; Are there any more quadsprites?
    jeq  draw_supersprite_end

    inct r4                    ; Continue with the next quadsprite.
    jgt  quadsprite_loop       ; Is it starting in the next memory bank?
    jmp  next_memory_bank      ; (rarely)

skip_quadsprite
    dec  r7                    ; Are there any more quadsprites?
    jeq  draw_supersprite_end

    andi r4, >fff8             ; Continue with the next quadsprite.
    ai   r4, 8
    jgt  quadsprite_loop       ; Is it starting in the next memory bank?
                               ; (rarely)
next_memory_bank
    inct r13
    .switch_bank *r13          ; Switch to the next memory bamk.

    jmp  quadsprite_loop

draw_supersprite_end
    b    *r12

* Subroutine: add the single quadsprite of a specified small supersprite to
* the sprite attribute table, starting at the current VDP address.
* Adds quadsprites whose patterns still need to be written to VDP memory to
* a cache queue.
* IN OUT r0:    the current address in the cache queue.
* IN     r1:    the supersprite number.
* IN     r2:    the supersprite x ordinate on the screen.
* IN     r3:    the supersprite y ordinate on the screen.
* LOCAL  r4:    the supersprite position/color/pattern offset.
* LOCAL  r5:    the quadsprite x ordinate.
* LOCAL  r6:    the quadsprite y ordinate.
* LOCAL  r11:   the subroutine return address.
* IN     vdpwa: the destination address in the VDP sprite descriptor table.
draw_small_supersprite
    .switch_bank @sprite_bounds_bank

    mov  r1, r4                ; Compute the address of the supersprite bounds
    sla  r4, 3                 ; (8 bytes per bounds, max 1024 entries).
    ai   r4, >6000

    c    r2, *r4+              ; Is the supersprite off-screen horizontally?
    jlt  draw_quadsprite_end
    c    r2, *r4+
    jgt  draw_quadsprite_end

    c    r3, *r4+              ; Is the supersprite off-screen vertically?
    jlt  draw_quadsprite_end
    c    r3, *r4
    jgt  draw_quadsprite_end

    .switch_bank @sprite_index_bank

    sla  r1, 1                 ; Compute the address in the supersprite index
    ai   r1, >6000             ; (2 bytes per index, max 4096 entries).

    mov  *r1, r4               ; Get the position number of the only quadsprite.

    mov  r4, r1                ; Compute the CPU source memory bank of the
    andi r1, >fc00             ; quadsprite entry (position, color, pattern index;
    srl  r1, 9                 ; 8 bytes each, 1024 per memory bank).
    ai   r1, sprite_positions_banks
    .switch_bank *r1           ; Switch to that memory bamk.

    andi r4, >03ff             ; Compute the CPU source memory address of the
    sla  r4, 3                 ; quadsprite entry in this memory bank.
    ai   r4, >6000

    mov  *r4+, r5              ; Compute the quadsprite x ordinate.
    a    r2, r5

    mov  *r4+, r6              ; Compute the quadsprite y ordinate.
    a    r3, r6
                               ; Continue drawing the single quadsprite...

* Subroutine: add the specified quadsprite the sprite attribute table,
* starting at the current VDP address.
* Adds quadsprites whose patterns still need to be written to VDP memory to
* a cache queue.
* IN OUT r0:    the current address in the cache queue.
* LOCAL  r1
* IN OUT r4:    the supersprite color/pattern offset.
* IN     r5:    the quadsprite x ordinate.
* IN     r6:    the quadsprite y ordinate.
* LOCAL  r11:   the subroutine return address.
* IN     vdpwa: the destination address in the VDP sprite descriptor table.
draw_quadsprite
* Write the y ordinate.
    dec  r6                    ; Adjust the y ordinate to start at >ff.
    swpb r6                    ; Write the y ordinate.
    .vdpwd r6

    mov  *r4+, r6              ; Get the quadsprite color.

* Write the x ordinate.
    mov  r5, r5                ; Adjust the x ordinate if necessary, to fade in
    jgt  !                     ; gradually on the left edge of the screen.
    ai   r5, sprite_early_clock_shift
    ori  r6, sprite_early_clock_flag
!
    swpb r5                    ; Write the x ordinate.
    .vdpwd r5

* Get a suitable VDP quadsprite number (character).
    mov  *r4, r5               ; Get the CPU quadsprite pattern number.

    sla  r5, 1                 ; Is the CPU quadsprite cached in VDP memory?
    mov  @vdp_quadsprite_numbers(r5), r1 ; (0..63 = 6 bits, shifted left 1 bit).
    c    r5, @cpu_quadsprite_numbers(r1)
    jeq  quadsprite_cached

    mov  @vdp_quadsprite_counter, r1 ; Otherwise get the next free quadsprite
                                     ; (LRU cache).

!   inct r1                    ; Find a quadsprite that is not used in this frame
    andi r1, >007e             ; (0..63 = 6 bits, shifted left 1 bit).
    c    @frame_timestamp, @vdp_quadsprite_timestamps(r1)
    jeq  -!

    mov  r1, @vdp_quadsprite_counter

    mov  r1, @vdp_quadsprite_numbers(r5) ; Remember in which VDP quadsprite
                                         ; this source quadsprite is cached.
    mov  r5, @cpu_quadsprite_numbers(r1) ; Remember which source quadsprite is
                                         ; cached in this VDP quadsprite.

    mov  r5, *r0+              ; Add the source quadsprite to the cache queue.

quadsprite_cached
                               ; Remember that this quadsprite is used in this frame.
    mov  @frame_timestamp, @vdp_quadsprite_timestamps(r1)

* Write the character and the color.
    sla  r1, 9
    .vdpwd r1                  ; Write the character.

    swpb r6
    .vdpwd r6                  ; Write the color and the early clock flag.

draw_quadsprite_end
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
