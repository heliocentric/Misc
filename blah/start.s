# boot.s (GNU ASM)
# Kernel multiboot bootloader
 
# Declare some constants
.set ALIGN,    1<<0               # Align loaded modules on page boundaries
.set MEMINFO,  1<<1               # Provide memory map
.set FLAGS,    ALIGN | MEMINFO    # Multiboot 'flag' field
.set MAGIC,  0x1BADB002           # Magic number that lets bootloader find header
.set CHECKSUM, -(MAGIC + FLAGS)   # Checksum of above, prove we are in multiboot
 
# Declare header as per Multiboot Standard
# Just magic values for setting up the multiboot
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM
 
# Create a stack
.section .bootstrap_stack
stack_bottom:
.skip 16384 # 16 KiB
stack_top:
 
# Jump to kernel mode
.section .text
.global _start # The linker script specifies _start as entry point
.type _start, @function
_start:
	# That is, we are in kernel mode
	# Set up the stack by pointing esp(Stack pointer) to the point of our stack
	movl $stack_top, %esp
	
	# Call the C code
	call kmain
	
	# We have to put the PC in an infinte loop
	cli # Clear interrupts
	hlt # Stop CPU
.Lhang:
	jmp .Lhang
	
# Set size of _start to current location (.) minus its start
# Useful for debugging or implemeting call tracing
.size _start, . - _start
