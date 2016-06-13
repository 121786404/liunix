#!Makefile
#
#

BOOT_SOURCES = $(shell find boot -name "*.[S|c]")
BOOT_OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(BOOT_SOURCES)))
KERNEL_SOURCES = $(shell find kern -name "*.[S|c]")
KERNEL_OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(KERNEL_SOURCES)))
LIB_SOURCES = $(shell find libs -name "*.c")
LIB_OBJECTS = $(patsubst %.c, %.o, $(LIB_SOURCES))

CC = gcc
LD = ld

CFLAGS := -c -Wall -m32 -ggdb -gstabs -nostdinc -fno-builtin -fno-stack-protector -Os
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
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 boot/bootasm.o boot/bootmain.o -o boot/bootblock.o
	objdump -t boot/bootblock.o | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > boot/bootblock.sym
	objdump -S boot/bootblock.o > boot/bootblock.asm
	$(LD) $(LDFLAGS) -T tools/kernel.ld $(KERNEL_OBJECTS) $(LIB_OBJECTS) -o bin/kernel


.PHONY:clean
clean:
	rm -Rf bin $(shell find . -name *.asm -or -name *.o -or -name *.sym -or -name *.out -or -name *.img)


.PHONY:update_image
update_image:
	@mkdir -p bin
	objcopy -S -R .note -R .comment -R .eh_frame -O binary boot/bootblock.o boot/bootblock.out
	tools/sign boot/bootblock.out bin/bootblock
	dd if=/dev/zero of=bin/LiuOS.img count=10000
	dd if=bin/bootblock of=bin/LiuOS.img conv=notrunc
	dd if=bin/kernel of=bin/LiuOS.img seek=1 conv=notrunc


.PHONY:qemu
qemu: bin/LiuOS.img
	qemu-system-i386 -parallel stdio -hda $< -serial null


.PHONY:debug
debug: bin/LiuOS.img
	qemu-system-i386 -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	gnome-terminal -e "gdb -q -tui -x tools/gdbinit_kernel"

.PHONY:debug_boot
debug_boot: bin/LiuOS.img
	qemu-system-i386 -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	gnome-terminal -e "gdb -q -x tools/gdbinit_boot"

.PHONY:debug_mon
debug_mon: bin/LiuOS.img
	gnome-terminal -e "qemu-system-i386 -S -s -d in_asm -D bin/q.log -monitor stdio -hda $< -serial null"
	sleep 2
	gnome-terminal -e "gdb -q -tui -x tools/gdbinit_kernel"






