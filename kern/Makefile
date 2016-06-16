#!Makefile
#
#


BIN_DIR:= ../bin


SOURCES = $(shell find . -name "*.[S|c]")
OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(SOURCES)))


CC = gcc
LD = ld

CFLAGS := -c -Wall -MD -m32 -ggdb -gstabs -nostdinc -fno-builtin -fno-stack-protector -Os
INCLUDE	+= . ../inc libs debug driver mm trap
CFLAGS	+= $(addprefix -I,$(INCLUDE))
LDFLAGS	= -m elf_i386 -nostdlib


all: $(OBJECTS) link

%.o: %.S
	$(CC) $(CFLAGS) $< -c -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -c -o $@

link:
	@mkdir -p $(BIN_DIR)
	$(LD) $(LDFLAGS) -T kernel.ld $(OBJECTS) -o $(BIN_DIR)/kernel.elf
	objdump -t $(BIN_DIR)/kernel.elf | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BIN_DIR)/kernel.sym
	objdump -S $(BIN_DIR)/kernel.elf > $(BIN_DIR)/kernel.asm
	readelf -a $(BIN_DIR)/kernel.elf > $(BIN_DIR)/kernel.txt


.PHONY:clean
clean:
	rm -f $(shell find . -name "*.[d|o]")