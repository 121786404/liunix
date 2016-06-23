OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)

SECTIONS {
    . = 0x7C00;

    .text : {
        *bootasm.o(.text)
	*(.text)
    }
    .data : { *(.data .rodata) }
    
    /DISCARD/ : { *(.eh_*) }
}
