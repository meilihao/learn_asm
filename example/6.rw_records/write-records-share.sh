#!/usr/bin/env bash
set -x
as write-record.s -o write-record.o
as read-record.s -o read-record.o
ld -shared write-record.o read-record.o -o librecord.so
as write-records.s -o write-records.o
ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -L . -lrecord write-records.o -o write-records.out # -L : 告诉ld在指定目录下查找so, 也可指定LD_LIBRARY_PATH来解决.