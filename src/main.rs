#![no_std]
#![no_main]

use core::arch::{asm, global_asm};

global_asm!(include_str!("asm/boot.S"));
global_asm!(include_str!("asm/trap.S"));

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn kmain() {
    loop {
        unsafe {
            asm!("wfi");
        }
    }
}
