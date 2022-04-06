#![no_std]
#![no_main]

use core::panic::PanicInfo;
use riscv_rt::entry;

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    loop {}
}

#[entry]
fn main() -> ! {
    panic!();
}

