/*
 * +----------------------------------------------------------------------------+
 * |                          Jeffrey M. Hunter                                 |
 * |                      jhunter@idevelopment.info                             |
 * |                         www.idevelopment.info                              |
 * |----------------------------------------------------------------------------|
 * |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
 * |----------------------------------------------------------------------------|
 * | DATABASE   : Oracle                                                        |
 * | FILE       : shell.c                                                       |
 * | CLASS      : External Procedures                                           |
 * | PURPOSE    : Example program used to demonstrate how to call O/S commands  |
 * |              from PL/SQL using external procedures.                        |
 * | NOTE       : As with any code, ensure to test this script in a development |
 * |              environment before attempting to run it in production.        |
 * +----------------------------------------------------------------------------+
 */

#include<stdio.h>
#include<stdlib.h>
#include<string.h>


void mailx(char *to, char *subject, char *message) {

  int num;
  char command[50000];

  strcpy(command, "echo \"");
  strcat(command, message);
  strcat(command, "\" | mailx -s \"");
  strcat(command, subject);
  strcat(command, "\" ");
  strcat(command, to);

  num = system(command);

}

void sh(char *command) {

  int num;

  num = system(command);

}
