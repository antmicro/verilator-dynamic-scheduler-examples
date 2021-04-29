#!/usr/bin/env bash

$VERILATOR_ROOT/bin/verilator --output-split-cfuncs 1 --cc testbench.sv verilog-uart/rtl/uart* --prefix Vtop --exe -o vmain cpp.cpp -Wno-WIDTH
make -C obj_dir -f Vtop.mk
./obj_dir/vmain
