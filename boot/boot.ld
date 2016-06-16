/* Simple linker script for the JOS kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(start)

SECTIONS {
	  . = 0x7c00;
	  .text : {
		  ./bootasm.o (.text)
			*(.text .rodata)
		}
		.rodata : {
		*(.rodata .rodata.* .gnu.linkonce.r.*)
		}
		.data : {
			*(.data)
		}
		.bss : {
			*(.bss)
		}
}
