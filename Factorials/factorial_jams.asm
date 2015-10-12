.data
prompt: .asciiz "Enter a number to find factorial: "
ans: .asciiz "\nAns: "
num: .word 0	# create a variable for the input number

.text
li $v0, 4	# syscall code to print null-terminated string
la $a0, prompt	# place address of string to print in syscall argument pointer $a0
syscall		# system call to print null terminated string addressed with $a0

li $v0, 5	# syscall code to read in integer
syscall		# system call to read in integer and store it in $v0

sw $v0, num	# place entered number into num variable (variable is basically already a pointer)

lw $t0, num	# for the factorial result (as it develops)
lw $t1, num	# for the decreasing component (from n to 1)

#fact:
#	addi $sp, $sp, -8	# adjust stack pointer for 2 words (2 items: instruction pointer and argument)
#	sw $ra, 4($sp)		# save return address (save instruction pointer in $ra)
#	sw $a0, 0($sp)		# save argument while you do stuff
	
	#slti $t0, $a0, 1	# test for n<1 (good luck finding the factorial of THAT) if arg $a0<1, $t0 is set to 0 (else to 1)
	
bgt $t0, 1, L1		# branch on greater than one
	
L1:
	addi $t1, $t1, -1	# decrement the decreasing component (down from n to 1)
	mul $t0, $t0, $t1	# multiply factorial item by decreasing component
	bgt $t1, 1, L1		# branch on greater than one
	
print:
	li $v0, 4	# syscall code to print null-terminated string
	la $a0, ans	# place address of string to print in syscall argument pointer $a0
	syscall		# system call to print null terminated string addressed with $a0
	
	li $v0, 1		# syscall code to print an integer
	add $a0, $t0, $zero	# load factorial result into $a0 for printing
	syscall
	
li $t1, 14

