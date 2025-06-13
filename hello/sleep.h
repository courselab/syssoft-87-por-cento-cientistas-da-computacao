/*
 *    SPDX-FileCopyrightText: 2025 Arthur Vergaças <vergacas.arthur@bcg.com>
 *
 *    SPDX-License-Identifier: GPL-3.0-or-later
 *
 *  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
 *  and includes modifications made by the following author(s):
 *
 *  Arthur Vergaças <arthurvdm@gmail.com>
 *  Laura Scotelari <laura.scotelari@usp.br>
 *  Murillo Moraes Martins <murillomartins19@usp.br>
 */

#ifndef SLEEP_H
#define SLEEP_H

void __attribute__((fastcall, naked)) sleep(int seconds);

#endif
