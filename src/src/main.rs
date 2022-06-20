#![no_std]
#![no_main]

use core::panic::PanicInfo;
use riscv_rt::entry;
use core::arch::asm;

struct HexOut {
    hex_ptr: *mut u32,
}

impl HexOut {
    unsafe fn new(ptr: *mut u32) -> HexOut {
        HexOut { hex_ptr: ptr }
    }

    fn write(&mut self, value: u32) {
        unsafe { self.hex_ptr.write_volatile(value); }
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    loop {}
}

fn nops(amount: usize) {
    for _ in 0..amount {
        unsafe { asm!("nop") }
    }
}

#[entry]
fn main() -> ! {
    let mut hex_out = unsafe { HexOut::new(0xfffffffcusize as *mut u32 )};
    let mut i: f32 = 2.0;
    loop {
        hex_out.write(i as u32);
        i = i * i;
        while i > (16_777_216.0f32) {
            i = i / 16.0f32;
        }
        nops(10_000_000);
    }
}

