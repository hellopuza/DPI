#!/usr/bin/env bash

verilator -Wno-lint --binary --vpi \
    src/test.sv \
    src/lib.c \
    fpu/multiplier/multiplier.v \
    -o test_bin
