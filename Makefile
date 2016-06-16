#!Makefile
#
#

BOOT_SOURCES = $(shell find boot -name "*.[S|c]")
BOOT_OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(BOOT_SOURCES)))
KERNEL_SOURCES = $(shell find kern -name "*.[S|c]")
KERNEL_OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(KERNEL_SOURCES)))
LIB_SOURCES = $(shell find libs -name "*.c")
LIB_OBJECTS = $(patsubst %.c, %.o, $(LIB_SOURCES))

HOSTCC		:= gcc
HOSTCFLAGS	:= -g -Wall -O2 -D_FILE_OFFSET_BITS=64
CC = gcc
LD = ld

CFLAGS := -c -Wall -MD -m32 -ggdb -gstabs -nostdinc -fno-builtin -fno-stack-protector -Os
INCLUDE	+= boot libs kern/debug kern/driver kern/mm kern/trap
CFLAGS	+= $(addprefix -I,$(INCLUDE))

LDFLAGS	= -m elf_i386 -nostdlib


all: $(BOOT_OBJECTS) $(LIB_OBJECTS) $(KERNEL_OBJECTS) link update_image

%.o: %.S
	$(CC) $(CFLAGS) $< -c -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -c -o $@

obj/bootblock.o: obj/boot/bootasm.o obj/boot/bootmain.o

link:
	@mkdir -p bin
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 boot/bootasm.o boot/bootmain.o -o bin/bootblock.o
	objdump -t bin/bootblock.o | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > bin/bootblock.sym
	objdump -S bin/bootblock.o > bin/bootblock.asm
	readelf -a bin/bootblock.o > bin/bootblock_elf.txt
	$(LD) $(LDFLAGS) -T tools/kernel.ld $(KERNEL_OBJECTS) $(LIB_OBJECTS) -o bin/kernel
	objdump -S bin/kernel > bin/kernel.asm
	readelf -a bin/kernel > bin/kernel_elf.txt



.PHONY:update_image
update_image:
	@mkdir -p bin
	objcopy -S -R .note -R .comment -R .eh_frame -O binary bin/bootblock.o bin/bootblock.out
	$(HOSTCC) $(HOSTCFLAGS) tools/sign.c -o tools/sign
	$(HOSTCC) $(HOSTCFLAGS) tools/vector.c -o tools/vector
	tools/sign bin/bootblock.out bin/bootblock
	dd if=/dev/zero of=bin/liunix.img count=10000
	dd if=bin/bootblock of=bin/liunix.img conv=notrunc
	dd if=bin/kernel of=bin/liunix.img seek=1 conv=notrunc
.PHONY:clean
clean:
	rm -Rf bin
	rm -f tools/sign tools/vector
	@#rm -f $(shell find . -name *.asm -or -name *.o -or -name *.d -or -name *.sym -or -name *.out -or -name *.img)
	rm -f $(shell find . -name *.o -or -name *.d)


.PHONY:qemu
qemu: bin/liunix.img
	qemu-system-i386 -parallel stdio -hda $< -serial null


.PHONY:debug
debug: bin/liunix.img
	qemu-system-i386 -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	gnome-terminal -e "gdb -q -tui -x tools/gdbinit_kernel"

.PHONY:debug_boot
debug_boot: bin/liunix.img
	qemu-system-i386 -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	gnome-terminal -e "gdb -q -x tools/gdbinit_boot"

.PHONY:debug_mon
debug_mon: bin/liunix.img
	gnome-terminal -e "qemu-system-i386 -S -s -d in_asm -D bin/q.log -monitor stdio -hda $< -serial null"
	sleep 2
	gnome-terminal -e "gdb -q -tui -x tools/gdbinit_kernel"






