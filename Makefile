#####
## BUILD
#####
LD=riscv64-unknown-elf-ld
LD_FLAGS=
LD_SCRIPT=src/lds/virt.lds

BUILD_TYPE=debug
RUST_TARGET=./target/riscv64imac-unknown-none-elf/$(BUILD_TYPE)
RUST_LIB=$(RUST_TARGET)/libros.a

OS_FILE=os.elf

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

$(RUST_LIB):
	cargo build

$(OS_FILE): $(RUST_LIB) $(LD_SCRIPT)
	$(LD) $(LD_FLAGS) -T $(LD_SCRIPT) -o $@ -L$(RUST_TARGET) -lros

run: all
	$(QEMU) -machine $(MACH) -cpu $(CPU) -smp $(CPUS) -m $(MEM)  -nographic -serial mon:stdio -bios none -kernel $(OS_FILE) -drive if=none,format=raw,file=$(DRIVE),id=foo -device virtio-blk-device,scsi=off,drive=foo


clean:
	rm -rf target $(OS_FILE)
