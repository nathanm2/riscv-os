#![no_std]

use core::arch::{asm, global_asm};

global_asm!(include_str!("asm/boot.S"));
global_asm!(include_str!("asm/trap.S"));

fn abort() -> ! {
    loop {
        unsafe {
            asm!("wfi");
        }
    }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    abort();
}

#[no_mangle]
extern "C" fn kmain() {
    abort();
}
