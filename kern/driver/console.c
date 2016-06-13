#include <defs.h>
#include <x86.h>
#include <stdio.h>


#define MONO_BASE       0x3B4
#define MONO_BUF        0xB0000
#define CGA_BASE        0x3D4
#define CGA_BUF         0xB8000
#define CRT_ROWS        25
#define CRT_COLS        80
#define CRT_SIZE        (CRT_ROWS * CRT_COLS)


static uint16_t *crt_buf;
static uint16_t crt_pos;
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;
    uint16_t was = *cp;
    *cp = (uint16_t) 0xA55A;
    if (*cp != 0xA55A) {
        cp = (uint16_t*)MONO_BUF;
        addr_6845 = MONO_BASE;
    } else {
        *cp = was;
        addr_6845 = CGA_BASE;
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
    pos = inb(addr_6845 + 1) << 8;
    outb(addr_6845, 15);
    pos |= inb(addr_6845 + 1);

    crt_buf = (uint16_t*) cp;
    crt_pos = pos;
}


/* cga_putc - print character to console */
static void
cga_putc(int c) {
    // set black on white
    if (!(c & ~0xFF)) {
        c |= 0x0700;
    }

    switch (c & 0xff) {
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
    case '\n':
        crt_pos += CRT_COLS;
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
        break;
    default:
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
    }

    // move that little blinky thing
    outb(addr_6845, 14);
    outb(addr_6845 + 1, crt_pos >> 8);
    outb(addr_6845, 15);
    outb(addr_6845 + 1, crt_pos);
}

/* cons_init - initializes the console devices */
void
cons_init(void) {
    cga_init();
}

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
    cga_putc(c);
}

