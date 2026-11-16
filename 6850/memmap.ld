OUTPUT_FORMAT("elf32-i386")
ENTRY(_start)

SECTIONS
{
    /* Executable code and read-only constants: VMA = 0x0000..0xFFEF, LMA = 0xF0000+ */
    .text 0x0000 : AT(0xF0000)
    {
        *(.text.boot)
        *(.text*)
        *(.rodata*)
    }

    /* Record size of .text/.rodata in ROM */
    _etext = .;

    /* Initialized variables: VMA in RAM (0x0500+), LMA in ROM right after .text */
    .data 0x0500 : AT(0xF0000 + _etext)
    {
        _sdata = .;
        *(.data*)
        _edata = .;
    }

    /* Uninitialized variables: VMA in RAM only (no ROM load space) */
    .bss (NOLOAD) :
    {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    }

    /* 8088 Reset Vector fixed at offset 0xFFF0 (physical 0xFFFF0) */
    .reset 0xFFF0 : AT(0xFFFF0)
    {
        FILL(0xFF);
        *(.reset)
        . = 0x0F;
        BYTE(0xFF);
    }

    /* Guard against firmware overflowing the 64 KB ROM window */
    ASSERT((_etext + (_edata - _sdata)) <= 0xFFF0, "Error: ROM image exceeds 64 KB")
}

