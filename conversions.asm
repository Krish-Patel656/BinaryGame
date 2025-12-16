# This file maintains the logic of the game including converting from binary to decimal
# and decimal tp binary. This is also where random numbers are genearted for
# random problems.

.text
.globl binary_to_decimal, generate_random_number

binary_to_decimal:
	move $t0, $a0 # Copy input string into t0
	li $v0, 0 # Initialize the result in decimal to 0
	li $t2, 0 # Initialze loop counter to 0
convert_bin_loop:
	li $t3, 8 # t3 = 8 for max bits
	beq $t2, $t3, convert_done # if counter reaches 8 bits then exit
	lb $t4, 0($t0) # Load byte from string
	beq $t4, 10, convert_done # If newlnie charcter then exit
	beq $t4, 0, convert_done # If null terminatior then exit
	li $t5, 48 # Set t5 = 0 ascii charcter
	sub $t4, $t4, $t5 # subtract 
	sll $v0, $v0, 1 # bit shift by 1 (Equivilant of multiply 2)
	or $v0, $v0, $t4 # Sets LSB to t4
	addi $t0, $t0, 1 # Move to next value in string
	addi $t2, $t2, 1 # Incremebt loop counter
	j convert_bin_loop # repeat until 8 bits are done
convert_done:
	jr $ra # Return from whenevr called

generate_random_number:
	li $v0, 42 # Syscall for random number in range 
	li $a0, 0 # Set min value to 0
	li $a1, 256 # Set max value to 255
	syscall
	move $v0, $a0 # Move genrated value to v0
	jr $ra # Return from whenevr called
