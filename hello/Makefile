CC=gcc
MAKE=/Library/Developer/CommandLineTools/usr/bin/make

this: hello.bin

this: hello.bin

main.o : main.c
	gcc -m16 -O1 -Wall -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -nostdinc -I. -o $@

libc.o : libc.S
	gcc -m16 -O1 -Wall -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -o $@

crt0.o : crt0.S
	gcc -m16 -O1 -Wall -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -o $@

hello.bin : main.o libc.o | crt0.o hello.ld
	gcc -m16 $^ -fno-stack-protector -nostartfiles -nostdlib -T hello.ld -orphan-handling=discard -o $@


#
# Housekeeping
#

clean:
	rm -f  *.bin *.elf *.o *.s *.iso *.img *.i kh
	make clean-extra


# SYSeg's  convenience rules (not related to the example itself)
include bintools.mk
