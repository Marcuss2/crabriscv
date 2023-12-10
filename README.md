# Crabriscv

### Goal

This was a school project where the "ideal goal: was an implementation of RISC-V compliant processor.

### Result

I have managed to implement a processor resembling the RV32I standard, albeit debug, and traps are missing. Compiled code for RV32I where
the compiler added floating point operations runs correctly, which serves as a resonable correctness test, code is provided. I have also
provided a linker file for the Rust programming language.

### Compilation

The project compiles and runs on Altera Cyclone V. In order to adapt it to other FPGA boards, you will need to rewrite the memory wrapper
if the RAM template is unable to use that board's memory and rewire the LCD numbers.  The clock speed was tested at 50 MHz.

In order to compile the sample program, you will have to have Rustup and RV32I compatible toolchain installed to perform the following steps:
1. Add the RV32I toolchain to Rust using `rustup target add riscv32i-unknown-none-elf`
2. After that just regular `cargo build --release` will compile the program
3. `riscv64-elf-objcopy -O verilog --verilog-data-width 4 target/riscv32i-unknown-none-elf/release/src output.hex` (replace riscv64 with riscv32 if you have that installed) will convert from the .elf file to verilog compatible hex file aligned to 4 bytes.
4. Copy the output.hex program to the base folder, so it can be loaded during compilation or simulation

### Implementation

This project implements custom bus and custom processor core resembling RV32I instruction set, it is compliant enough to run code without traps
or debug instructions. The custom bus basically just routes the RAM and one LCD register to the processor. Main part of the implementation was
the processor.

The processor itself has its states described with constants, effectively, each instruction group has its own state, which gets set after
the fetch state, which effectively is the "loading new instruction state"

The implementation seperates the Arithmetic Logical Unit, Load Unit (Processes the loaded data by discarding superfluous bits and bit extends), and
a branch unit, which just determines if a branch should happen.

The RAM itself uses Quartus template to fit it to onboard RAM, I effectively wrap the memory in a module and provide an interface to an outside bus.

### Implementation problems

Properly implementing signed immediate operations turned out to be somewhat problematic, the deviations from the standard were effectively found via
trial and error. Earlier iterations mixed asynchronous and synchronous assignments, which are bit of a no no. In the end, I just replaced them with
synchronous ones if I used synchronous assignments at all. I also had to replace negedge and posedge modifications with posedge only with a state
register, this combined them into one posedge block with alternating execution.

The biggest issue were probably differences between simulation and actual execution on an FPGA, often I had to intentionally slow the core down so that
the bus can catch up, these issues were often very difficult to debug as I had to route out the state registers and output them to FPGA LEDs.

### What should be done differently next time

Do not mix synchronous and asynchronous assignments

FPGAs cannot assign to the same variable on posedge and negedge at the same time, don't do it.

Debugging custom processor and bus at the same time is very difficult, only design one at a time.

### How it could be extended

Implementing more instructions according to the multiplication standard should not be a huge issue, adding floating point operations would be
more difficult but still possible, the processor can easily take multiple cycles per instructions.

Adding interrupts would be more difficult.
