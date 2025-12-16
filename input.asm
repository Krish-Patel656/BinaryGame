# This file maintains all inputs that the user might give. It includes
# binary and decimal inputs including validation. Time outs are processed here
# along with other inputs the user might give.

.text
.globl get_binary_input, get_decimal_input, wait_for_enter, prompt_continue

get_binary_input:
	addi $sp, $sp, -4 # Make space on stack
	sw $ra, 0($sp) # Save return address

binary_input_loop:
	li $v0, 4 # Syscall 4 to print string on entering binary value
	la $a0, enterBin
	syscall
	
	li $v0, 8 # Syscall 8 to input string which is the biniar input
	la $a0, input_buf
	li $a1, 12
	syscall
	

	la $a0, input_buf # Checks for timeout
	jal check_timeout_binary # Jump to see
	beq $v0, 1, binary_input_valid # If timeout, skip validation
	
	
	la $a0, input_buf # Load address of input_buf into a0
	jal validate_binary_input # Jump to validation section to assure binary input is correct
	beq $v0, 1, binary_input_valid # If valid, continue
	
	# If invalid, show error and loop back
	li $v0, 4 # Use syscall 4 to print invalid binary message
	la $a0, invalid_binary_msg
	syscall
	j binary_input_loop # Jump back to let user input a valid binary

binary_input_valid:
	la $v0, input_buf # return address of iput buffer in v0
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 4 # Clean stack
	jr $ra # Return to caller

get_decimal_input:
	addi $sp, $sp, -4 # Make space on stack
	sw $ra, 0($sp) # Save return address

decimal_input_loop:
	li $v0, 4 # Use syscall 4 to print enter decimal string
	la $a0, enterDec
	syscall
	

	li $v0, 8 # Use syscall 8 to input string to verify it is valid decmial 
	la $a0, input_buf
	li $a1, 12
	syscall
	
	la $a0, input_buf # Load address of input_buf
	jal check_timeout_binary_string # Checks to see if timeout was called
	beq $v0, 1, decimal_timeout_valid # If timeout, then go through proper process
	
	la $a0, input_buf # Load address of input_buf
	jal string_to_integer # Jump to convert input string into integer
	move $t0, $v0 # Store converted number in t0
	move $t1, $v1 # Store conversion success flag in t1
	
	beq $t1, 1, check_decimal_range # If conversion successful, check range
	
	li $v0, 4 # Syscall 4 to print invalid decimal message if conversion failed
	la $a0, invalid_decimal_msg
	syscall
	j decimal_input_loop

check_decimal_range:

	move $a0, $t0 # Move t0 to a0
	jal validate_decimal_input # Jump to validate if decimal value input is valid
	beq $v0, 1, decimal_input_valid # If valid, continue
	
	li $v0, 4 # Syscall 4 to print invalid decimal message
	la $a0, invalid_decimal_msg
	syscall
	
	j decimal_input_loop # Jump back to allow user to input proper value

decimal_timeout_valid:
	li $v0, -1 # Return -1 for timeout
	j decimal_input_done

decimal_input_valid:
	move $v0, $t0 # Move validated input to return register

decimal_input_done:
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 4 # Clean stack
	jr $ra # Return to caller

wait_for_enter:
	li $v0, 8 # Prompts user to enter a string (Enter)
	la $a0, input_buf
	li $a1, 12
	syscall
	
	jr $ra # Return to caller

prompt_continue:
	li $v0, 4 # Syscall 4 for printing contnite message after each level
	la $a0, continue_prompt
	syscall
	
	li $v0, 5 # Syscall 5 for inputting integer 
	syscall
	
	jr $ra # Return to caller


validate_binary_input:
	move $t0, $a0 # Copy input string address to t0
	li $t1, 0 # Initialize character counter
	
binary_validation_loop:
	lb $t2, 0($t0) # Load current character
	beq $t2, 10, check_binary_length # Checks to see if value is newline
	beq $t2, 0, check_binary_length # Checks to see if value is null terminator
	
	li $t3, 48 # Loads ascii '0'
	li $t4, 49 # Loads ascii '1'
	beq $t2, $t3, valid_binary_char # Character is '0' jumps to proper sectin if input is 0 or 1
	beq $t2, $t4, valid_binary_char # Character is '1'
	
	li $v0, 0
	jr $ra # Invalid character found then return when called
	
valid_binary_char:
	addi $t1, $t1, 1 # Increment character counter
	addi $t0, $t0, 1 # Move to next character

	li $t5, 8
	bgt $t1, $t5, binary_wrong # Checks to see if characters is greater than 8
	
	j binary_validation_loop # Jump to validation loop

check_binary_length:

	li $t5, 8
	beq $t1, $t5, binary_valid # Checks for exaclty 8 bit characters
	blt $t1, $t5, binary_wrong # If not then jump to too short loop
	

binary_wrong:
	li $v0, 0
	jr $ra # Returns to when called 

binary_valid:
	li $v0, 1
	jr $ra # Returns to when called

validate_decimal_input:

	move $t0, $a0 # Copy input number to t0

	blt $t0, 0, decimal_invalid # Checks to see if number is between 0 or 255 otherwise jumps to decimal_invalid
	bgt $t0, 255, decimal_invalid
	
	li $v0, 1 # Otherwise number is valid
	jr $ra

decimal_invalid:

	li $v0, 0 # Number invalid return to when called
	jr $ra

string_to_integer:

	move $t0, $a0 # Copy input string address to t0
	li $v0, 0 # Initialize result to 0
	li $v1, 0 # Initialize success flag to 0 (failure)
	li $t3, 0 # Initialize digit counter
	
string_convert_loop:

	lb $t1, 0($t0) # Load current character
	beq $t1, 10, string_convert_success # Success if current character is newline
	beq $t1, 0, string_convert_success # Success if current character is null terminator
	
	blt $t1, 48, string_convert_fail # Checks if less than '0' in ascii character
	bgt $t1, 57, string_convert_fail # Checks if greater than '9' in ascii character

	sub $t2, $t1, 48 # Set t2 = digit value
	
	sll $t5, $v0, 3   # Bitshift 3 (Equivilant to multiply 8 
	sll $t6, $v0, 1   # Bitshift 1 (Equivilant to multiplt 2
	add $v0, $t5, $t6 # Add the previous bitshifts to simulate multiplying 10
	add $v0, $v0, $t2 # Add the new digit
	
	addi $t0, $t0, 1 # Move to next character
	addi $t3, $t3, 1 # Increment digit counter
	j string_convert_loop # Jump to convert loop

string_convert_success:
	bgt $t3, 0, string_convert_valid # Checks for a single digit to assure valid input
	j string_convert_fail # Otherwise go to fail

string_convert_valid:
	li $v1, 1 # Set success flag to 1 meaning valid string conversino
	jr $ra # Return to caller

string_convert_fail:
	li $v0, 0 # Set result to 0
	li $v1, 0 # Set success flag to 0
	jr $ra # Return to caller


check_timeout_binary_string:

	lb $t0, 0($a0) # Load first byte of input in t0
	li $t1, 45 # Load t1 with ascii character for - (-1 from timeout)
	bne $t0, $t1, no_timeout_bin_str # If no - detected then not a timeout and jump down
	
	lb $t0, 1($a0) # Otherwise load byte 2 into t0
	li $t1, 49 # Load t1 with ascii character for 1 since -1 is needed for timeout
	bne $t0, $t1, no_timeout_bin_str # If no -1 detected then not timeout
	
	lb $t0, 2($a0) # Check next character for newline or null
	beq $t0, 10, is_timeout_bin_str # Check for newline then jump to is timeout
	beq $t0, 0, is_timeout_bin_str # Check for null terminator then jump to is timeout
	
	j no_timeout_bin_str # Jump to no timeout if -1 not input
	
is_timeout_bin_str:
	li $v0, 1 # Set return value 1 = timeout
	jr $ra # Return to caller
	
no_timeout_bin_str:
	li $v0, 0 # Set return value = 0 meaning no timeout
	jr $ra # Return to caller
