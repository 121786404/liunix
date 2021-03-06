#!Makefile
#
#

BIN_DIR:= ../bin


SOURCES = $(shell find . -name "*.[S|c]")
OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(SOURCES)))
CC = gcc
LD = ld
CFLAGS := -c -Wall -MD -m32 -ggdb -gstabs -nostdinc -fno-builtin -fno-stack-protector -Os
INCLUDE	+= . ../inc
CFLAGS	+= $(addprefix -I,$(INCLUDE))
LDFLAGS	= -m elf_i386 -nostdlib -N -Map bootblock.map -Tboot.ld




all: $(OBJECTS) link

%.o: %.S
	$(CC) $(CFLAGS) $< -c -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -c -o $@

link:
	@mkdir -p $(BIN_DIR)
	$(LD) $(OBJECTS) $(LDFLAGS) -o bootblock.o
	objdump -t bootblock.o | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BIN_DIR)/bootblock.sym
	objdump -S bootblock.o > $(BIN_DIR)/bootblock.asm
	readelf -a bootblock.o > $(BIN_DIR)/bootblock.txt
	objcopy -j.text -j.data -O binary bootblock.o $(BIN_DIR)/bootblock.out

.PHONY:clean
clean:
	rm -f *.out *.sym *.asm *.map
	find . -name "*.o" -o -name "*.d" -o -name "*.expand" | xargs rm -f