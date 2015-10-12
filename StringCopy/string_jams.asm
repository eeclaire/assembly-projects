.data	# Shove stuff into subsequent 

namestr: .asciiz "Claire"	# create a variable for my name (.asciiz adds the null terminator)
space: .space 1
rcvrstr: .space 6		# allocate space for the receiver array

.text

la $a1, namestr		# load the address of the string in $a1
la $a0, rcvrstr		# load the address of the receiver array in $a2
add $s0, $zero, $zero	# i = 0


#strcpy:
#	addi $sp, $sp, -4	# adjust stack for 1 item (go down 4 bytes to go down one word)
#	sw $s0, 0($sp)		# store sp word (no offset) into $s0
#	jal L2
#	
#	add $s0, $zero, $zero	# i = 0
	
L1:
	add $t1, $s0, $a1	# save the address of y[i] in $t1 ($s0 is index i), $t1 contains address of word to copy (with current index)
	lbu $t2, 0($t1)		# $t2 = y[i] (place content of address that $t1 points to into $t2), $t2 contains a copy of the word to copy
	add $t3, $s0, $a0	# address of x[i] in $t3, $a0 is the destination of the string start, $t3 will increment through it (need to initialize that array)
	sb $t2, 0($t3)		# x[i] = y[i], stores value of $t2 into value that $t3 points to
	
	# $t2 is incrementing through the original string
	# $t3 is incrementing through the receiver array
	
	beq $t2, '\0', L2	# exit loop if y[i] is null (end of string)
	addi $s0, $s0, 1	# increment $s0 as index i
	j L1			# otherwise, loop again
	
L2: 
#	lw $s0, 0($sp)		# restore old stack pointer
#	addi $sp, $sp, 4	# pop 1 item from stack
#	jr $ra			#return
	
	