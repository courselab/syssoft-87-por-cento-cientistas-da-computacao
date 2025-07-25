/*
 *    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
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

#include <stdio.h>
#include <sleep.h>

int main(void) {
  printf("Sleeping for 5 seconds!\r\n");

  sleep(5);

  printf("Awaken!\n\r");

  return 0;
}
