#![no_std]
#![no_main]

use core::arch::{asm, global_asm};
use core::fmt::Write;

mod uart;

global_asm!(include_str!("asm/boot.S"));
global_asm!(include_str!("asm/trap.S"));

#[macro_export]
macro_rules! print {
    ($($args:tt)+) => {{}};
}

#[macro_export]
macro_rules! println
{
	() => ({
		print!("\r\n")
	});
	($fmt:expr) => ({
		print!(concat!($fmt, "\r\n"))
	});
	($fmt:expr, $($args:tt)+) => ({
		print!(concat!($fmt, "\r\n"), $($args)+)
	});
}

#[unsafe(no_mangle)]
extern "C" fn abort() -> ! {
    loop {
        unsafe {
            asm!("wfi");
        }
    }
}
#[unsafe(no_mangle)]
extern "C" fn eh_personality() {}

#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    print!("Aborting: ");
    if let Some(_p) = info.location() {
        println!(
            "line {}, file {}: {}",
            p.line(),
            p.file(),
            info.message().unwrap()
        );
    } else {
        println!("no information available.");
    }
    abort();
}

#[unsafe(no_mangle)]
pub extern "C" fn kmain() {
    let mut my_uart = uart::Uart::new(0x1000_0000);
    my_uart.init();

    let _ = my_uart.write_str("Hello World\n");
    return ();
}
