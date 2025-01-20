# bootloader for nvros
# Nathan Miller
# Feb 17, 2024

# Largely copied from Stephen Marz's "Adventures in OS"
# https://github.com/sgmarz/osblog

.option push

# Disable riscv instruction compression.
.option norvc

.pushsection .text.init
.global _start
_start:

# Any hardware threads (harts) that are not bootstrapping
# need to wait for an IPI
csrr	t0, mhartid
bnez	t0, 3f

# Ensure virtual address translation is currently disabled.

# M-mode typically clears this register, and S-mode will set it after it has
# configured the page tables.
csrw	satp, zero

# Set the gp register.
#
# By abi convention global values are 'relaxed' and accessed relative to the
# gp register.
#
# We need to temporarily disable linker relaxation here so that gp is
# set to an absolute address.
.option push
.option norelax
la	gp, _global_pointer
.option pop

# Zero out the BSS section.
la	a0, _bss_start
la	a1, _bss_end
bgeu	a0, a1, 2f
1:
sd	zero, (a0)
addi	a0, a0, 8
bltu	a0, a1, 1b
2:

# Set the stack register (sp)
la	sp, _stack

# The next few instructions are going to set several CSRs in preperation for
# a faux "exception return" via the `mret` instruction.

# Set mstatus.mpp is set to M-mode (0x3), the priviledge mode we want to be in
# following the exception return.
#
# Note that mstatus.mpie is still zero, meaning interrupts will not be globally
# enabled following the `mret`.
li	t0, (0b11 << 11)
csrw	mstatus, t0

# Jump to kmain following the exception return.
la	t1, kmain
csrw	mepc, t1

# Set our exception trap vector.
la	t2, asm_trap_vector
csrw	mtvec, t2

# Enable external, timer and software interrupts for M-mode.  Note, however
# these won't take effect until the interrupts are globally enabled in the
# mstatus CSR.
li	t3, (1 << 3) | (1 << 7) | (1 << 11)
csrw	mie, t3

# In the event that we return from 'kmain', this is what we will return to.
la	ra, 3f

# Perform the exception return and jump to 'kmain':
mret

# Loop forever:
3:
wfi
j	3b

.popsection
.option pop
