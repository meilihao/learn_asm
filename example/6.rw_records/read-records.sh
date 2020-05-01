#!/usr/bin/env bash
set -x
as count-chars.s -o count-chars.o
as write-newline.s -o write-newline.o
as read-record.s -o record-record.o
as read-records.s -o record-records.o
ld count-chars.o write-newline.o record-record.o record-records.o -o read-records.out