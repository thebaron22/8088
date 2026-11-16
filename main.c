#include <stdint.h>

/* Sample initialized variable (stored in ROM, copied to RAM by crt0.s) */
static uint16_t boot_count = 1;

/* Sample uninitialized variable (zeroed in RAM by crt0.s) */
static uint8_t status_flag;

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("out %1, %0" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("in %0, %1" : "=a"(ret) : "Nd"(port));
    return ret;
}

void main(void) {
    /* Example: Write 'OK' directly to CGA/MDA text video memory at B800:0000 */
    volatile uint16_t __far *vram = (volatile uint16_t __far *)0xB8000000UL;

    outb(0x80, 0xAA);
    status_flag = (uint8_t)(boot_count & 0xFF);

    /* Read back from port 0x80 */
    uint8_t val = inb(0x80);

    vram[0] = (0x07 << 8) | 'O';
    vram[1] = (0x07 << 8) | 'K';
	vram[2] = (0x07 << 8) | val;
	vram[3] = (0x07 << 8) | (uint8_t)boot_count;
	vram[4] = (0x07 << 8) | status_flag;


    /* Main firmware loop */
    while (1) {
        __asm__ volatile ("hlt");
    }
}

