.code16
.intel_syntax noprefix

.section .text.boot, "ax"
.global _start

_start:
    cli                     /* Disable interrupts during hardware init */
    cld                     /* Clear direction flag for string ops */

    xor  ax, ax             /* AX = 0x0000 (value to write) */
    mov  es, ax             /* Start at segment 0x0000 (physical 0x00000) */
    mov  bx, 8              /* 8 segments * 64 KB = 512 KB */

.clear_segment:
    xor  di, di             /* Offset 0x0000 within current segment */
    mov  cx, 0x8000         /* 32,768 words = 65,536 bytes (64 KB) */
    rep  stosw              /* Write 0x0000 across the entire 64 KB segment */

    mov  dx, es             /* Load current segment */
    add  dx, 0x1000         /* Advance base address by 64 KB (0x10000) */
    mov  es, dx             /* Update ES */

    dec  bx                 /* Decrement segment counter */
    jnz  .clear_segment     /* Repeat for segments 0x0000..0x7000 */

    /* Set up Stack Segment (SS:SP) in RAM (0000:7C00) */
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    /* Set Data Segment (DS) and Extra Segment (ES) to 0x0000 */
    mov ds, ax
    mov es, ax

    /* Zero out BIOS Data Area / reserved firmware variables (_sbss .. _ebss) */
    mov di, offset _sbss
    mov cx, offset _ebss
    sub cx, di
    jz .call_main
    xor al, al
    rep stosb

.call_main:
    call main

.halt:
    hlt
    jmp .halt

/* 8088 Reset Vector placed at physical address 0xFFFF0 */
.section .reset, "ax"
    .byte 0xEA              /* Far JMP opcode (JMP FAR ptr16:16) */
    .word _start            /* Target offset */
    .word 0xF000            /* Target segment (for a 64 KB ROM at F0000-FFFFF) */

