# THis is where most of the outputs happen. It displays the game board, 
# question numbers, binary/decimal numbers displayed, completion messages, etc.
# This file also utilizes the stack to easily handle question number and level
# throughout the program lifetime.

.text
.globl display_board, display_question_number, display_binary_to_decimal, display_decimal_to_binary
.globl display_question_sep, display_result_sep, display_level_complete

display_board:
	addi $sp, $sp, -12 # Make space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save level number
	sw $a1, 8($sp)# Save points
    
	li $v0, 4 # Syscall 4 to display the top border
	la $a0, board
	syscall
	
	li $v0, 4 # Syscall 4 to display the game title
	la $a0, game_title
	syscall
	
	li $v0, 4 # Syscall4 to display the middle border
	la $a0, board_mid
	syscall

	li $v0, 4 # Syscall 4 to display the level label
	la $a0, level_label
	syscall
	
	li $v0, 1 # Syscall 1 to display the level from stack
	lw $a0, 4($sp)
	syscall
	
	li $v0, 4 # Syscall 4 to display the points label
	la $a0, points_label
	syscall
	
	li $v0, 1 # Syscall 1 to display the points from stack
	lw $a0, 8($sp)
	syscall
	
	li $v0, 4 # Systcall 4 to display newline character
	la $a0, newline
	syscall
    
	li $v0, 4 # Syscall 4 to display the border middle
	la $a0, board_mid
	syscall
    
	lw $ra, 0($sp) # Restore return addres
	addi $sp, $sp, 12 # Clean stack
	jr $ra # Return to caller

display_question_sep:
	li $v0, 4 # Syscall 4 to display the question separator
	la $a0, board
	syscall
	jr $ra # Return to caller

display_result_sep:
	li $v0, 4 # Syscall 4 to display the results separatore
	la $a0, result_sep
	syscall
	jr $ra # Return to caller

display_question_number:
	addi $sp, $sp, -8 # Make space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp)  # Save question number
    
	li $v0, 4 # Syscall 4 to display question separator
	la $a0, board
	syscall
    
	li $v0, 4 # Syscall 4 to display question label
	la $a0, question_msg
	syscall
	
	li $v0, 1 # Syscall 1 to display question number from stack
	lw $a0, 4($sp)
	addi $a0, $a0, 1 # Conver 0 based to 1 based
	syscall
	
	li $v0, 4 # Syscall 4 to display newline character
	la $a0, newline
	syscall
    
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller

display_binary_to_decimal:
	addi $sp, $sp, -8 # Make space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save binary value
    
	lw $a0, 4($sp) # Load binary value from stack
	jal display_binary_boxes # Jump to diplsay the binary boxes with values
    
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller

display_decimal_to_binary:
	addi $sp, $sp, -8 # Make space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save decimal value
    
	lw $a0, 4($sp) # Load decimal value from stack
	jal display_empty_binary_boxes # Jump to display the empty boxes
	
    
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller

display_binary_boxes:
	addi $sp, $sp, -8 # Make space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save binary value argument on stack
	
	li $v0, 4 # Syscall to print the bit positions
	la $a0, bit_positions
	syscall
	
	li $v0, 4 # Syscall to print the box border
	la $a0, box_border
	syscall
	
	li $v0, 4 # Syscall 4 to print the box bit |
	la $a0, box_bits_start
	syscall
	
	lw $t0, 4($sp) # Load the binary value from stack into t0
	li $t1, 128 # Initialize bit mask with 128
	li $t2, 0 # Initialize bit counter to 0
	
display_bit_boxes_loop:
	li $v0, 11 # Syscall 11 to print a single charcater
	move $t3, $t0 # Copy binary valur into t3
	and $t3, $t3, $t1 # Mask current bit
	beq $t3, $zero, print_zero_char # If result is 0, jump to print 0
	li $a0, 49  # ASCII '1'
	j print_bit_char # Jump to print syscall
print_zero_char:
	li $a0, 48  # ASCII '0'
print_bit_char:
	syscall # Print current bit
	
	li $t4, 7 # Print separator for all but the last bit
	beq $t2, $t4, skip_separator # Skip if last bit
	
	li $v0, 4 # Syscall 4 to print separator |
	la $a0, box_separator
	syscall
	
skip_separator:
	srl $t1, $t1, 1 # Shift mask right by 1 for next bit
	addi $t2, $t2, 1 # Increment bit counter
	li $t4, 8
	blt $t2, $t4, display_bit_boxes_loop # Loop through 8 bits
	
	li $v0, 4 # Syscall 4 to print the box bit end
	la $a0, box_bits_end
	syscall
	
	li $v0, 4 # Syscall 4 to print the box border
	la $a0, box_border
	syscall
	
	li $v0, 4 # Syscall 4 to print newline
	la $a0, newline
	syscall
	
	lw $ra, 0($sp) # Restore return addres from stack
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller
	
	
print_last_zero:
	li $a0, 48 # ASCII '0'
print_last_bit:
	syscall # Print last zero bit
	
	li $v0, 4 # Syscall 4 to print box bits end
	la $a0, box_bits_end
	syscall
	
	li $v0, 4 # Syscall 4 to print box border
	la $a0, box_border
	syscall
	
	li $v0, 4 # Syscall 4 to print newline
	la $a0, newline
	syscall
	
	lw $ra, 0($sp) # Restore return address from stack
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller
display_empty_binary_boxes:
	addi $sp, $sp, -8 # Create space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save deciaml value on stack
	
	li $v0, 4 # Syscall 4 to print bit positions
	la $a0, bit_positions
	syscall

	li $v0, 4 # Syscall 4 to print box border
	la $a0, box_border
	syscall
	
	li $v0, 4 # Syscall 4 to print empty box rows
	la $a0, empty_boxes_row
	syscall
	
	li $v0, 4 # Syscall 4 to print the box border
	la $a0, box_border
	syscall
	
	li $v0, 4 # Syscall 4 to print equals sign
	la $a0, equals_label
	syscall
	
	li $v0, 1 # Syscall 1 to print integer
	lw $a0, 4($sp)
	syscall
	
	li $v0, 4 # Syscall 4 to print newline
	la $a0, newline
	syscall
	
	lw $ra, 0($sp) # Restore return address from stack
	addi $sp, $sp, 8 # Clean stack
	jr $ra # Return to caller

display_level_complete:
	addi $sp, $sp, -12 # Create space on stack
	sw $ra, 0($sp) # Save return address
	sw $a0, 4($sp) # Save points value in a0
	sw $a1, 8($sp) # Save number of questions
    
	li $v0, 4 # Syscall 4 to print level complete message
	la $a0, level_complete
	syscall
    
	li $v0, 1 # Syscall 1 to print points integer
	lw $a0, 4($sp)
	syscall
    
	li $v0, 4 # Syscall 4 to print the level stats
	la $a0, level_stats
	syscall
    
	li $v0, 1 # Syscall 1 to print integer of questions
	lw $a0, 8($sp)
	syscall
    
	li $v0, 4 # Syscall 4 to print the level questions
	la $a0, level_questions
	syscall
    
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 12 # Clean stack
	jr $ra # Return caller
