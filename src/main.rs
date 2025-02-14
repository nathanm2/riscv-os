#![no_std]
#![no_main]

use core::arch::{asm, global_asm};
use core::fmt::Write;

mod uart;

global_asm!(include_str!("asm/boot.S"));
global_asm!(include_str!("asm/trap.S"));

#[macro_export]
macro_rules! kprint {
    ($($args:tt)+) => {
        let _ = write!(uart::Uart::new(0x1000_0000), $($args)+);
    };
}

#[macro_export]
macro_rules! kprintln
{
	() => ({
		kprint!("\r\n");
	});
	($fmt:expr) => ({
		kprint!(concat!($fmt, "\r\n"));
	});
	($fmt:expr, $($args:tt)+) => ({
		kprint!(concat!($fmt, "\r\n"), $($args)+);
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
    kprint!("Aborting: ");
    if let Some(p) = info.location() {
        kprintln!("line {}, file {}: {}", p.line(), p.file(), info.message());
    } else {
        kprintln!("no information available.");
    }
    abort();
}

#[unsafe(no_mangle)]
pub extern "C" fn kmain() {
    let mut my_uart = uart::Uart::new(0x1000_0000);
    my_uart.init();

    let _ = kprintln!("Hello World: {}", 42);
    return ();
}
