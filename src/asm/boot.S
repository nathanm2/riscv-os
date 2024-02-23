# bootloader for nvros
# Nathan Miller
# Feb 17, 2024

# Largely copied from Stephen Marz's "Adventures in OS"
# https://github.com/sgmarz/osblog

# Disable riscv instruction compression.
.option norvc
.section .data
.ascii "Hello World"

.section .bss
.zero 128

.section .text.init
.global _start
_start:
	# Any hardware threads (hart) that are not bootstrapping
	# need to wait for an IPI
	csrr	t0, mhartid
	bnez	t0, 3f

	# Make sure virtual address translation is currently disabled.
	csrw	satp, zero

	# Set the gp register.
	#
	# This register is used for relative addressing.
	#
	# We need to disable linker relaxation here so that gp is set to an absolute address.
.option push
.option norelax
	la		gp, _global_pointer
.option pop

	# Zero out the BSS section.
	la 		a0, _bss_start
	la		a1, _bss_end
	bgeu	a0, a1, 2f
1:
	sd		zero, (a0)
	addi	a0, a0, 8
	bltu	a0, a1, 1b
2:

	# Set the stack register (sp)
	la	sp, _stack

	# We use mret here so that the mstatus register
	# is properly updated.
	li	t0, (0b11 << 11) | (1 << 7)
	csrw	mstatus, t0
	la	t1, kmain
	csrw	mepc, t1
	la	t2, asm_trap_vector
	csrw	mtvec, t2
	li	t3, (1 << 3) | (1 << 7) | (1 << 11)
	csrw	mie, t3
	la		ra, 3f

	# "Return" to kmain
	mret
3:
	wfi
	j	3b
