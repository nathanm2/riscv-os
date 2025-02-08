// uart.rs
// UART routines and driver

use core::fmt::{Error, Write};

pub struct Uart {
    ptr: *mut u8,
}

impl Uart {
    pub fn new(base_address: usize) -> Self {
        Uart {
            ptr: base_address as *mut u8,
        }
    }

    pub fn init(&mut self) {
        unsafe {
            // First, set the word length, which
            // are bits 0 and 1 of the line control register (LCR)
            // which is at base_address + 3
            // We can easily write the value 3 here or 0b11, but I'm
            // extending it so that it is clear we're setting two individual
            // fields
            //                         Word 0     Word 1
            //                         ~~~~~~     ~~~~~~
            self.ptr.add(3).write_volatile((1 << 0) | (1 << 1));

            // Now, enable the FIFO, which is bit index 0 of the FIFO control register (FCR at
            // offset 2).
            // Again, we can just write 1 here, but when we use left shift, it's easier to see that
            // we're trying to write bit index #0.
            self.ptr.add(2).write_volatile(1 << 0);

            // Enable receiver buffer interrupts, which is at bit index 0 of the interrupt enables
            // register (IER at offset 1).
            self.ptr.add(1).write_volatile(1 << 0);
        }
    }

    pub fn put(&mut self, c: u8) {
        unsafe {
            self.ptr.add(0).write_volatile(c);
        }
    }
}

impl Write for Uart {
    fn write_str(&mut self, s: &str) -> Result<(), Error> {
        for c in s.bytes() {
            self.put(c);
        }
        Ok(())
    }
}
