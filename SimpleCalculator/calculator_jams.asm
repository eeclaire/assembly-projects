.data
prompt: .asciiz "\n>>>"	# create user prompt to print out
space: .space 3
input: .space 40	# create some space for the user input
nospace: .space 40	# space for the user input minus white space
output_q: .space 40	# create  space for the shunting yard output queue
operator_stack: .space 40	# create space for the shunting yard operator stack
variables: .space 52	# create space for the values of every variable

success: .asciiz "Exiting now!!!\n"
invparens: .asciiz "Error: invalid parentheses!\n"
invcomb: .asciiz "Error: invalid combination!\n"
invvar: .asciiz "Error: undefined variable\n"
invsym: .asciiz " is not a valid symbol!\n"
nulldiv: .asciiz "Error: cannot divide by 0!\n"
answer: .asciiz "Ans: "



.text

main:
	li $v0, 4	# syscall code to print null-terminated string
	la $a0, prompt	# place address of string to print in syscall argument pointer $a0
	syscall		# system call to print null terminated string addressed with $a0

	li $v0, 8	# syscall code to read in string
	la $a0, input	# load address of where to save the user input 
	li $a1, 16	# load man number of charaters to read
	syscall		# system call to read in string
	
	jal rmvwhite	# jumps to a remove_whitespace subroutine (and link = place current spot in return address register)

	# Check for exit demand
	lw $t9, nospace		# place string without white space in register
	beq $t9, 0x00657962, END	# compare to hex /neyb ("bye" in memory)
	beq $t9, 0x00657942, END	# compare to hex /neyB ("Bye" in memory)	
			
	jal val_parens	# jump and link return to function to validate parenthesis balance	
	
	jal val_sym	# jump and link return to function to validate symbols in the string
	
	jal var_declaration	# jump and link return to function to save user-defined variables
	
	jal val_comb	# jump and link return to function to validate combinations of operators/operands
	
	jal replace_variables	# jump and link to function to replace variables in a string with their user-defined value
	
	jal shunting_yard	# jump and link return to function to reformat intput into RPN
	
	# Print out the result of the operation
	li $v0, 4	# syscall code to print null-terminated string
	la $a0, answer	# place address of string to print in syscall argument pointer $a0
	syscall		# system call to print null terminated string addressed with $a0
	
	li $v0, 1		# syscall code to print integer
	lw $a0, output_q	# place address of string to print in syscall argument pointer $a0
	syscall		# system call to print null terminated string addressed with $a0

	j main
	

rmvwhite:	
	la $a1, input		# load address of input string to copy into $a1
	la $a0, nospace		# load address of receiver string into $a0
	
	L1:
		lbu $t2, 0($a1)		# $t2 = y[i] (place content of address that $t1 points to into $t2), $t2 contains a copy of the word to copy
		addi $a1, $a1, 1	# increment address in word to copy
		
		beq $t2, ' ', L1	# go straight back to L1 if current byte to copy is a space	
		beq $t2, 0x0a, L1	# go straight back to L1 if current byte to copy is a new line
		
		sb $t2, 0($a0)		# x[i] = y[i], stores value of $t2 into value that $a0 points to (receiver array)
		addi $a0, $a0, 1	# increment $a0 
		
		beq $t2, '\0', L2	# exit loop if y[i] is null (end of string)
		addi $s0, $s0, 1	# increment $s0 as index i
		j L1			# otherwise, loop again
		
	L2: 	# do nothing and just head down to relative address
	
	jr $ra 	# return to main
	
val_parens :
	la $a0, nospace		# load address of spaceless string into $a0	
	add $t1, $zero, $zero	# reset counter $t1
	
	vpL1:
		lbu $t0, 0($a0)		# load first byte of spaceless string into $t0
		beq $t0, '(', plus	# increment subroutine	
		beq $t0, ')', minus	# decrement subroutine
		j vp_nextbyte		# performs some checks before moving on to the next byte
	
	plus:
		# Check for 0(
		lbu $t2, -1($a0)	# load previous byte into $t2
		beq $t2, '0', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '1', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '2', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '3', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '4', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '5', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '6', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '7', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '8', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '9', vp_error	# return error if you have an operand before an opening parenthesis
		
		# Check for (*
		lbu $t2, 1($a0)		# load next byte into $t2
		beq $t2, '*', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '/', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, ')', vp_error	# return error if you have an operand before an opening parenthesis
		
		addi $t1, $t1, 1	# increment parentheses balance counter t1
		j vp_nextbyte		# sequence to finish checking & move on to next byte
		
	minus:
		# Check for )0
		lbu $t2, 1($a0)		# load next byte into $t2
		beq $t2, '0', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '1', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '2', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '3', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '4', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '5', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '6', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '7', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '8', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '9', vp_error	# return error if you have an operand before an opening parenthesis
		
		
		# Check for +)
		lbu $t2, -1($a0)	# load previous byte into $t2
		beq $t2, '*', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '/', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '+', vp_error	# return error if you have an operand before an opening parenthesis
		beq $t2, '-', vp_error	# return error if you have an operand before an opening parenthesis
				
		addi $t1, $t1, -1	# decrement t1
		bltz $t1, vp_error		# if counter is less than zero ever, your parentheses are fucked
		j vp_nextbyte
		
	
	# subroutine for checking and going to the next byte	
	vp_nextbyte:
		beq $t0, '\0', vp_return	# if you reach end of string, check counter	
		addi $a0, $a0, 1	# increment byte 
		j vpL1			# go back to L1
		
	# subroutine for invalid parentheses
	vp_error:
		la $a0, invparens	# load address of parenthesis error message
		li $v0, 4	
		syscall			# print out the error message
		j main
	
	# subroutine to return to main program
	vp_return:
		bgtz $t1, vp_error		# check if counter is bigger than zero
		bltz $t1, vp_error		# redundant, but can't hurt
		jr $ra			# if counter == 0, 
# End of val_parens ---------------------------------------------------------------------------------------------------------

val_sym:
	la $a1, nospace		# load address of spaceless string into $a1	
	add $t1, $zero, $zero	# reset counter $t1
	lbu $t0, 0($a1)		# load first byte of spaceless string into $t0
	
	vsL1:	
		# testing stuff hurrrr
		beq $t0, '\n', vs_valid		# allow the CR
		#beq $t0, 
		blt $t0, '(', vs_invalid	# invalid entry if less than ascii '(' / less than ascii 40
		ble $t0, '+', vs_valid		# between "(, ), *, +" / less than or equal to ascii 43
		beq $t0, ',', vs_invalid	# invalid if ascii dec 44
		beq $t0, '-', vs_valid		# valid if '-' / equal to ascii dec 45
		beq $t0, '.', vs_invalid	# invalid if ascii dec 46
		ble $t0, '9', vs_valid		# valid if between ascii 47 and ascii 57 (included)
		beq $t0, '=', vs_valid		# valid if '=' / equal to ascii dec 61
		blt $t0, 'A', vs_invalid	# invalid if between ascii dec 57 and 65 (not including '=')
		ble $t0, 'Z', vs_valid		# valid if between 'A-Z' / ascii dec 65 - 90
		blt $t0, 'a', vs_invalid	# invalid if between ascii dec 91 and 96 (included)
		ble $t0, 'z', vs_valid		# valid if between 'a-z' / ascii dec 97 - 122
		bgt $t0, 'z', vs_valid		# invalid if bigger than 'z' / ascii dec 122
		
		
	vs_valid:
		addi $a1, $a1, 1	# increment byte 
		lbu $t0, 0($a1)		# load first byte of spaceless string into $t0
		beq $t0, '\0', vs_return	# if you reach end of string, check counter	
		j vsL1			# go back to L1
						
	vs_invalid:
		#add $a0, $zero, $zero	# clear $a0
		add $a0, $t0, $zero	# place contents of $t0 into $a0
		li $v0, 11
		syscall		# syscall to print char
		
		la $a0, invsym
		li $v0, 4
		syscall		# syscall to pring invalid symbol string
		
		j main		# return to main for user to enter something new
		
	vs_return:
		jr $ra		# return to main

# End of val_sym -------------------------------------------------------------------------------------------------------------------

var_declaration:
	la $a1, nospace		# load address of spaceless string into $a1
	lb $t0, 1($a1) 		# check the second element the user inputted
	beq $t0, '=', var_initialization
	
	jr $ra

var_initialization:
	la $a0, variables	# load address of variables string
	lb $t7, 0($a0)
	lb $t0 0($a1) 		# load the name of the variable in $t0
	lb $t1, 2($a1)		# load the value of the variable in $t1
	
	try_storing:
	 	bne $t7, 0, shift	# shift by 2 bytes if space already occupied
		sb $t0, 0($a0)
		sb $t1, 1($a0)
		j main
				
shift:
	addi $a0, $a0, 2	# shift by two bytes
	lb $t7, 0($a0)
	j try_storing	

# End of var_declaration -------------------------------------------------------------------------------------------------------------------

val_comb:
	# loads word into $a1 and increments through it
	la $a1, nospace		# load address of spaceless string into $a1
	lb $t0, 0($a1)		# load first byte of spaceless string into $t0	
	
	# Check first byte (error if * or /
	beq $t0, '*', vc_error
	beq $t0, '/', vc_error
	j vc_nextbyte
	
	vcL1:
		lb $t0, 0($a1)		# load first byte of spaceless string into $t0
		beq $t0, '*', vc_adj_op_mul_div
		beq $t0, '/', vc_adj_op_mul_div
		beq $t0, '+', vc_adj_op_plus_min
		beq $t0, '-', vc_adj_op_plus_min
				
		j vc_nextbyte
	
	vc_adj_op_mul_div:
	
		# Check the previous char not an operator
		lbu $t2, -1($a1)
		#beq $t2, '+', vc_error
		#beq $t2, '-', vc_error
		beq $t2, '*', vc_error
		beq $t2, '/', vc_error
		
		# Check the next char is not * or /
		lbu $t2, 1($a1)
		beq $t2, '*', vc_error
		beq $t2, '/', vc_error		
		
		j vc_nextbyte
		
	vc_adj_op_plus_min:
	
		# Check the next char not an operator
		lbu $t2, 1($a1)		
		#beq $t2, '+', vc_error
		#beq $t2, '-', vc_error
		beq $t2, '*', vc_error
		beq $t2, '/', vc_error
		
		# Check the previous char is not * or /
		#lbu $t2, -1($a1)
		#beq $t2, '-', vc_error
		#beq $t2, '+', vc_error		
		
		j vc_nextbyte		
	
	
	# subroutine for invalid combination
	vc_error:
		la $a0, invcomb		# load address of combination error message
		li $v0, 4	
		syscall			# print out the error message
		j main																	
		
	# subroutine for checking and going to the next byte	
	vc_nextbyte:
		beq $t0, '\0', vc_return	# if you reach end of string, check counter	
		addi $a1, $a1, 1	# increment byte 
		j vcL1			# go back to L1
		
	vc_return:
		jr $ra		# return to main

# End of val_comb ------------------------------------------------------------------------------------------------------------------

replace_variables:
	la $a1, nospace		# load address of spaceless string into $a1
	
	rv_L1:	
		lb $t0, 0($a1)		# load first byte of spaceless string into $t0
		
		beq $t0, 'a', var
		beq $t0, 'b', var
		beq $t0, 'c', var
		beq $t0, 'd', var
		beq $t0, 'e', var
		beq $t0, 'f', var
		beq $t0, 'g', var
		beq $t0, 'h', var
		beq $t0, 'i', var
		beq $t0, 'j', var
		beq $t0, 'k', var
		beq $t0, 'l', var
		beq $t0, 'm', var
		beq $t0, 'n', var
		beq $t0, 'o', var
		beq $t0, 'p', var
		beq $t0, 'q', var
		beq $t0, 'r', var
		beq $t0, 's', var
		beq $t0, 't', var
		beq $t0, 'u', var
		beq $t0, 'v', var
		beq $t0, 'w', var
		beq $t0, 'x', var
		beq $t0, 'y', var
		beq $t0, 'z', var
				
		beq $t0, 'A', var
		beq $t0, 'B', var
		beq $t0, 'C', var
		beq $t0, 'D', var
		beq $t0, 'E', var
		beq $t0, 'F', var
		beq $t0, 'G', var
		beq $t0, 'H', var
		beq $t0, 'I', var
		beq $t0, 'J', var
		beq $t0, 'K', var
		beq $t0, 'L', var
		beq $t0, 'M', var
		beq $t0, 'N', var
		beq $t0, 'O', var
		beq $t0, 'P', var
		beq $t0, 'Q', var
		beq $t0, 'R', var
		beq $t0, 'S', var
		beq $t0, 'T', var
		beq $t0, 'U', var
		beq $t0, 'V', var
		beq $t0, 'W', var
		beq $t0, 'X', var
		beq $t0, 'Y', var
		beq $t0, 'Z', var
		
	beq $t0, '\0', rv_return
	
	addi $a1, $a1, 1
	j rv_L1
		
var:
	la $a2, variables
	
	# loop through the saved variables
	rv_vL:
		lb $t1, 0($a2)
	
		beq $t0, $t1, replace
		beq $t0, '\0', rv_error
		
		addi $a2, $a2, 2	# increment by 2 to skip over number
		j rv_vL
	
replace:
	lb $t1, 1($a2)	# load up the number that corresponds to that letter
	sb $t1, 0($a1)	
	
	addi $a1, $a1, 1
	j rv_L1

rv_error:
	la $a0, invvar		# load address of combination error message
	li $v0, 4	
	syscall			# print out the error message
	j main

rv_return:
	jr $ra
# Include parentheses and also negative numbers

shunting_yard:
	
	# Save the return address in $t8
	add $t8, $ra, $zero
	
	# load spaceless input string
	# also load output queue and operator stack
	la $a0, nospace		# load address of spaceless string into $a0
	la $a1, output_q	# load address of shunting yard output queue into $a1
	#la $a2, operator_stack	# load address of shunting yard operator stack into $a2
	
	syL1:
		# load addresses of spaceless string, output queue, and operator stack
		lb $t0, 0($a0)		# load first byte of spaceless string into $t0
		lw $t1, 0($a1)		# load first byte of shunting yard output queue into $t1
	
		beq $t0, '0', cpy_to_output_q
		beq $t0, '1', cpy_to_output_q
		beq $t0, '2', cpy_to_output_q
		beq $t0, '3', cpy_to_output_q
		beq $t0, '4', cpy_to_output_q
		beq $t0, '5', cpy_to_output_q
		beq $t0, '6', cpy_to_output_q
		beq $t0, '7', cpy_to_output_q
		beq $t0, '8', cpy_to_output_q
		beq $t0, '9', cpy_to_output_q
		
		beq $t0, '*', check_stack_mul_div
		beq $t0, '/', check_stack_mul_div
		
		beq $t0, '(', push_to_op_stack
		beq $t0, ')', pop_all_in_parens
		
		beq $t0, '+', check_stack_plus_min
		beq $t0, '-', check_stack_plus_min
		
		j final_check

	pop_all_in_parens:
		lb $t2, 0($sp)
		beq $t2, '(', remove_parens
		beq $t2, '*', multiply_parens
		beq $t2, '/', divide_parens
		beq $t2, '+', add_parens
		beq $t2, '-', subtract_parens
				
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j pop_all_in_parens
		
	remove_parens:
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j sy_nextbyte
		
	multiply_parens:
		# load the two previous operands and multiply them (result in lo, overflow in hi)
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		mult $t3, $t4
		
		# move result of operation into $t3, then push that to the output queue, clear the old next word, 
		# and adjust output queue pointer
		mflo $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j pop_all_in_parens 
		
	divide_parens:	
		# load the two previous operands, divide the oldest by the newest, store the result in $t3
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		beq $t3, 0, div_by_null_error
		div $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j pop_all_in_parens
	
	add_parens:
		# load the two previous operands, add the two, store the result in $t3, push it to
		# to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		add $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j pop_all_in_parens
		
	subtract_parens:
		# load the two previous operands, subtract the newest from the oldest, store the result in $t3,
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		sub $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j pop_all_in_parens
		
	
		
	check_stack_mul_div:
		# If there's another * or / on stack, pop it to queue because pushing this (loop)
		lb $t2, 0($sp)
		beq $t2, '*', pop_to_output_queue_mul_div
		beq $t2, '/', pop_to_output_queue_mul_div
		j push_to_op_stack
	
		
	check_stack_plus_min:
		# If there's another operator on stack, pop it to queue because pushing this (loop)
		lb $t2, 0($sp)
		beq $t2, '*', pop_to_output_queue_plus_min
		beq $t2, '/', pop_to_output_queue_plus_min
		beq $t2, '+', pop_to_output_queue_plus_min
		beq $t2, '-', pop_to_output_queue_plus_min
		j push_to_op_stack
	
	cpy_to_output_q:
		# Convert to actual numbers
		
		# do some beq to another function that handles conversion if next byte is a number
		# do some math into $s2 (multiple digits!!!!)
		
		# If the next byte is not a number, convert this byte to a number, place it in $s1, then add it 
		# to the contents of $s2 (which contains any potential tens, hundreds, etc) and save it into $0
		# and push $s0 to the output queue. Make sure to clear $s2
		addi $s1, $t0, -48	# place the numeric value of $t0 into $s1
		lb $s7, 1($a0)		# load next byte into $s7 to check if number
		beq $s7, '0', do_multiple_digits
		beq $s7, '1', do_multiple_digits
		beq $s7, '2', do_multiple_digits
		beq $s7, '3', do_multiple_digits
		beq $s7, '4', do_multiple_digits
		beq $s7, '5', do_multiple_digits
		beq $s7, '6', do_multiple_digits
		beq $s7, '7', do_multiple_digits
		beq $s7, '8', do_multiple_digits
		beq $s7, '9', do_multiple_digits
		
		# if no following digit, engage send_to_q routine
		
	send_to_q:	
		mul $s2, $s2, 10
		add $s0, $s1, $s2	# add the potential contents of $s2 to $s1 and save in $s0
		sw $s0, 0($a1)		# copy byte from input string into output queue (sw, NOT sb)
		addi $a1, $a1, 4	# increment pointer to output queue
		add $s2, $zero, $zero
		j sy_nextbyte
	
	do_multiple_digits:
		# Multiply thing by 10, get next byte 
		mul $s2, $s2, 10
		add $s2, $s1, $s2

		j sy_nextbyte
						
	push_to_op_stack:
		# copy to operator stack using sp
		# increment stack pointer
		addi $sp, $sp, -1	# increment stack pointer by 1 byte
		sb $t0, 0($sp)		# stores the byte of the receiver string into address sp points to
		
		# COME BACk
		# catch if the next input byte is +/-
		lb $t3, 1($a0)		# load next byte 
		beq $t3, '-', condense_min	# there's a - after the *, /, +, -, or -
		beq $t3, '+', condense_max	# there's a + after the *, /, +, -, or -
		
		j sy_nextbyte	
	
	# deals with condensing things that start with a -		
	condense_min:
		addi $a0, $a0, 1	
		lb $t4, 1($a0)		# load following byte
		
		# there should be a looping case here. Ignore for now
		# if there's another operator here, engage loop to condense
		
		# otherwise, if this negative sign is followed by a number, obtain number 
		addi $t4, $t4, -48	# convert to numbers
		
		# deal with multiple digit numbers:
		lb $s6, 2($a0)		# load byte after that
		
		beq $s6, '0', multidigit_condense_min
		beq $s6, '1', multidigit_condense_min
		beq $s6, '3', multidigit_condense_min
		beq $s6, '4', multidigit_condense_min
		beq $s6, '5', multidigit_condense_min
		beq $s6, '6', multidigit_condense_min
		beq $s6, '7', multidigit_condense_min
		beq $s6, '8', multidigit_condense_min
		beq $s6, '9', multidigit_condense_min
		
		
		add $t4, $t4, $t5	# bring back numbers above the units place
		add $t5, $zero, $zero
		sub $t0, $zero, $t4	# Change this to deal with multiple digit numbers
		
		# PUSH TO QUEUE 
		sw $t0, 0($a1)		# copy byte from input string into output queue (sw, NOT sb)
		addi $a1, $a1, 4	# increment pointer to output queue
		
		# reset $t0 
		addi $a0, $a0, 1
		lb $t0, 0($a0)		
		
		j sy_nextbyte
		
	multidigit_condense_min:
		add $t5, $t5, $t4
		mul $t5, $t5, 10 
		j condense_min
		
	condense_max:
		addi $a0, $a0, 1	
		lb $t4, 1($a0)		# load following byte
		
		# there should be a looping case here. Ignore for now
		# if there's another operator here, engage loop to condense
		
		# otherwise, if this negative sign is followed by a number, obtain number 
		addi $t4, $t4, -48	# convert to numbers
		
		# deal with multiple digit numbers:
		lb $s6, 2($a0)		# load byte after that
		
		beq $s6, '0', multidigit_condense_max
		beq $s6, '1', multidigit_condense_max
		beq $s6, '3', multidigit_condense_max
		beq $s6, '4', multidigit_condense_max
		beq $s6, '5', multidigit_condense_max
		beq $s6, '6', multidigit_condense_max
		beq $s6, '7', multidigit_condense_max
		beq $s6, '8', multidigit_condense_max
		beq $s6, '9', multidigit_condense_max
		
		
		add $t4, $t4, $t5	# bring back numbers above the units place
		add $t5, $zero, $zero
		add $t0, $zero, $t4	# Change this to deal with multiple digit numbers
		
		# PUSH TO QUEUE 
		sw $t0, 0($a1)		# copy byte from input string into output queue (sw, NOT sb)
		addi $a1, $a1, 4	# increment pointer to output queue
		
		# reset $t0 
		addi $a0, $a0, 1
		lb $t0, 0($a0)		
		
		j sy_nextbyte
		
	multidigit_condense_max:
		add $t5, $t5, $t4
		mul $t5, $t5, 10 
		j condense_max
		
	pop_to_output_queue_mul_div:
		# do something here
		beq $t2, '*', multiply_mul_div
		beq $t2, '/', divide_mul_div
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_mul_div
		
	multiply_mul_div:
		# load the two previous operands and multiply them (result in lo, overflow in hi)
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		mult $t3, $t4
		
		# move result of operation into $t3, then push that to the output queue, clear the old next word, 
		# and adjust output queue pointer
		mflo $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_mul_div 
	
	divide_mul_div:	
		# load the two previous operands, divide the oldest by the newest, store the result in $t3
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		beq $t3, 0, div_by_null_error
		div $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_mul_div 
		
	pop_to_output_queue_plus_min:
		# do something here		
		beq $t2, '*', multiply_plus_min
		beq $t2, '/', divide_plus_min
		beq $t2, '+', add_plus_min
		beq $t2, '-', subtract_plus_min
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_plus_min
		
	multiply_plus_min:
		# load the two previous operands and multiply them (result in lo, overflow in hi)
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		mult $t3, $t4
		
		# move result of operation into $t3, then push that to the output queue, clear the old next word, 
		# and adjust output queue pointer
		mflo $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_plus_min 
	
	divide_plus_min:	
		# load the two previous operands, divide the oldest by the newest, store the result in $t3
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		beq $t3, 0, div_by_null_error
		div $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_plus_min
	
	add_plus_min:
		# load the two previous operands, add the two, store the result in $t3, push it to
		# to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		add $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_plus_min
		
	subtract_plus_min:
		# load the two previous operands, subtract the newest from the oldest, store the result in $t3,
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		sub $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j check_stack_plus_min
								
	sy_nextbyte:
		beq $t0, '\0', final_check	# if you reach end of string, check counter	
		addi $a0, $a0, 1	# increment byte 
		j syL1			# go back to L1
	
	final_check:	
		lb $t2, 0($sp)
		
		beq $t2, '*', final_pop
		beq $t2, '/', final_pop
		beq $t2, '+', final_pop
		beq $t2, '-', final_pop
		j sy_return
				
	final_pop:
		#sb $t2, 0($a1)		# store top of stack into output queue
		#addi $a1, $a1, 4	# increment pointer to output queue
		#beq $t0, ')', pop_all_in_parens
		beq $t2, '*', multiply_final
		beq $t2, '/', divide_final
		beq $t2, '+', add_final
		beq $t2, '-', subtract_final
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j final_check

				
	multiply_final:
		# load the two previous operands and multiply them (result in lo, overflow in hi)
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		mult $t3, $t4
		
		# move result of operation into $t3, then push that to the output queue, clear the old next word, 
		# and adjust output queue pointer
		mflo $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j final_check
		
	divide_final:	
		# load the two previous operands, divide the oldest by the newest, store the result in $t3
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		beq $t3, 0, div_by_null_error
		div $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j final_check
		
						
	add_final:
		# load the two previous operands, add the two, store the result in $t3, push it to
		# to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		add $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j final_check
		
	subtract_final:
		# load the two previous operands, subtract the newest from the oldest, store the result in $t3,
		# push that to the output stack and clear the most recent spot, and adjust the output queue pointer
		lw $t3, -4($a1)
		lw $t4, -8($a1)
		sub $t3, $t4, $t3
		sw $t3, -8($a1)
		sw $zero, -4($a1)
		addi $a1, $a1, -4	
		
		addi $sp, $sp, 1	# decrement stack pointer by 1 byte (move down)
		j final_check			

	
	sy_return:
		jr $t8		# return to main
		
		# subroutine for invalid combination
	div_by_null_error:
		la $a0, nulldiv		# load address of combination error message
		li $v0, 4	
		syscall			# print out the error message
		j main
		
# End of shunting_yard ------------------------------------------------------------------------------------------------------------										
						
									
#	vs_nextbyte:
#		beq $t0, '\0', return	# if you reach end of string, check counter	
#		addi $a0, $a0, 1	# increment byte 
#		j vsL1			# go back to L1
					
									
	
		
	
END:	# user-called end
	li $v0, 4	# syscall code to print null-terminated string
	la $a0, success	# place address of string to print in syscall argument pointer $a0
	syscall		# system call to print null terminated string addressed with $a0
	
	
quit:	# user dun goofed
	


	

