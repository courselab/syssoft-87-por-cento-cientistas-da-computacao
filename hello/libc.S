#    SPDX-FileCopyrightText: 2025 Arthur Vergaças <vergacas.arthur@bcg.com>
#
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#
#  Arthur Vergaças <arthurvdm@gmail.com>
#  Laura Scotelari <laura.scotelari@usp.br>
#  Murillo Moraes Martins <murillomartins19@usp.br>

	/* Suppose we receive the argument in %cx. */

	.code16gcc
	.global printf
        .global sleep

	.section .text

printf:

	mov   %cx, %bx

        mov   $0x0e,%ah
        mov   $0x0, %si
loop:
        mov   (%bx, %si), %al
        cmp   $0x0, %al
        je    end
        int   $0x10
        add   $0x1, %si
        jmp   loop
end:
        mov %si, %ax
        ret

sleep:
	mov   %cx, %bx # store seconds in %bx

        # mul multiplies %ax by %bx, result in %dx:%ax
        # while INT 15H 86H: Wait expects %cx:dx to contain the
        # time in microseconds

        # We can't simply multiply %bx by 1_000_000 because
        # it won't fit in 16 bits. So we convert seconds to milliseconds,
        # then milliseconds to microseconds.

        mov   $1000, %ax
        mul   %bx # %ax (1000) * %bx (seconds) -> convert seconds to milliseconds

        # %ax now contains the milliseconds to sleep

        mov $1000, %bx
        mul %bx # %ax (milliseconds) * %bx (1000) -> convert milliseconds to microseconds

        # move %dx:ax to %cx:dx to conform with int 15h 86h
        mov %dx, %cx
        mov %ax, %dx

        mov   $0x86, %ah # function 0x86: Wait
        int   $0x15      # issue interrupt

        ret
