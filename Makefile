#####
## BUILD
#####
AS=riscv64-unknown-elf-as
AS_FLAGS=-march=rv64gc -mabi=lp64

CC=riscv64-unknown-elf-gcc
C_FLAGS=-march=rv64gc -mabi=lp64 -nostdlib

LD=riscv64-unknown-elf-ld
LD_FLAGS=
LD_SCRIPT=src/lds/virt.lds

C_SOURCES=kmain.c
C_OBJS=$(patsubst %.c,%.o,$(C_SOURCES))

ASM_SOURCES=boot.S trap.S
ASM_OBJS=$(patsubst %.S,%.o,$(ASM_SOURCES))

OS_FILE=os.elf

vpath %.S src/asm
vpath %.c src/c

.PHONY: all run clean

#####
## QEMU
#####
QEMU=qemu-system-riscv64
MACH=virt
CPU=rv64
CPUS=4
MEM=128M
DRIVE=hdd.dsk


%.o: %.c
	$(CC) $(C_FLAGS) -c -o $@ $<

%.o: %.S
	$(AS) $(AS_FLAGS) -o $@ $<

$(OS_FILE):  $(ASM_OBJS) $(C_OBJS) $(LD_SCRIPT)
	$(LD) $(LD_FLAGS) -T $(LD_SCRIPT) -o $@ $(ASM_OBJS) $(C_OBJS)

all: os.elf
	# cargo build

run: all
	$(QEMU) -machine $(MACH) -cpu $(CPU) -smp $(CPUS) -m $(MEM)  -nographic -serial mon:stdio -bios none -kernel $(OS_FILE) -drive if=none,format=raw,file=$(DRIVE),id=foo -device virtio-blk-device,scsi=off,drive=foo


clean:
	rm -f $(OS_FILE) $(ASM_OBJS) $(C_OBJS)
