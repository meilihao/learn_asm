#!/usr/bin/env bash
set -x
as write-record.s -o write-record.o
as read-record.s -o read-record.o
as add-year.s -o add-year.o
as error-exit.s -o error-exit.o
as count-chars.s -o count-chars.o
as write-newline.s -o write-newline.o
ld error-exit.o count-chars.o write-newline.o write-record.o read-record.o add-year.o -o add-year.out