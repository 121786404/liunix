#!Makefile
#
#

CC		  := gcc
CFLAGS	:= -g -Wall -O2 -D_FILE_OFFSET_BITS=64

all:
	$(CC) $(CFLAGS) sign.c -o sign
	$(CC) $(CFLAGS) vector.c -o vector
	./vector > ../kern/trap/vectors.S

clean:
	rm -f vector sign ../kern/trap/vectors.S











