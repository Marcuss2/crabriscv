# Crabriscv

## Goal

This was a school project where the main goal was an implementation of RISC-V compliant processor, in the end, I have managed
to implement a processor resembling the RV32I standard, albeit debug, and traps are missing.

## Compilation

The project compiles and runs on Altera Cyclone V. In order to adapt it to other FPGA boards, you will need to rewrite the memory wrapper
if the RAM template is unable to use that board's memory and rewire the LCD numbers.  The clock speed was tested at 50 MHz.

In order to compile the sample program, you will to have Rustup and RV32I compatible toolchain installed to perform the following steps:
1. Add the RV32I toolchain to Rust using `rustup target add riscv32i-unknown-none-elf`
2. After that just regular `cargo build --release` will compile the program
3. `riscv64-elf-objcopy -O verilog --verilog-data-width 4 target/riscv32i-unknown-none-elf/release/src output.hex` (replace riscv64 with riscv32 if you have that installed)
4. Copy the output.hex program to the base folder, so it can be loaded during compilation or simulation

