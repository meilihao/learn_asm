#!/usr/bin/env bash
set -x
as write-record.s -o write-record.o
as read-record.s -o read-record.o
ld -shared write-record.o read-record.o -o librecord.so
as write-records.s -o write-records.o
ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -L . -lrecord write-records.o -o write-records.out 