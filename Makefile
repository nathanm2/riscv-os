#####
## BUILD
#####
AS=clang
AS_FLAGS=--target=riscv64 -march=rv64i2p1_m2p0_a2p1_c2p0 -mabi=lp64 -nostdlib

LD=riscv64-unknown-elf-ld
LD_FLAGS=
LD_SCRIPT=src/lds/virt.lds

ASM_SOURCES=boot.S trap.S
ASM_OBJS=$(patsubst %.S,%.o,$(ASM_SOURCES))

BUILD_TYPE=debug
RUST_TARGET=./target/riscv64imac-unknown-none-elf/$(BUILD_TYPE)
RUST_LIB=$(RUST_TARGET)/libros.a

OS_FILE=os.elf

vpath %.S src/asm

.PHONY: all run clean $(RUST_LIB)

#####
## QEMU
#####
QEMU=qemu-system-riscv64
MACH=virt
CPU=rv64
CPUS=4
MEM=128M
DRIVE=hdd.dsk

all: os.elf

%.o: %.S
	$(AS) $(AS_FLAGS) -c -o $@ $<

$(RUST_LIB):
	cargo build

$(OS_FILE):  $(ASM_OBJS) $(RUST_LIB) $(LD_SCRIPT) $(RUST_LIB)
	$(LD) $(LD_FLAGS) -T $(LD_SCRIPT) -o $@ $(ASM_OBJS) -L$(RUST_TARGET) -lros


run: all
	$(QEMU) -machine $(MACH) -cpu $(CPU) -smp $(CPUS) -m $(MEM)  -nographic -serial mon:stdio -bios none -kernel $(OS_FILE) -drive if=none,format=raw,file=$(DRIVE),id=foo -device virtio-blk-device,scsi=off,drive=foo


clean:
	rm -rf target
	rm -f $(OS_FILE) $(ASM_OBJS) $(C_OBJS)
