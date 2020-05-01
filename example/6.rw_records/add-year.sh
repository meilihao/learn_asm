#!/usr/bin/env bash
set -x
as write-record.s -o write-record.o
as read-record.s -o read-record.o
as add-year.s -o add-year.o
ld write-record.o read-record.o add-year.o -o add-year.out