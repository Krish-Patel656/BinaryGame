# Krish Patel CS 2340.003

# This is the main file that maintains teh entire flow of the game.
# It handles the game looping, level progression, creating the questions, and 
# directing to other files when needed.

.include "messages.asm"

.text
.globl main


# Initialze game start
main:
	li $v0, 4 # Syscall 4 to print welcome message
	la $a0, welcome 
	syscall

	li $v0, 4 # Syscall 4 to print welcome separator/formatter
	la $a0, formatWelcome 
	syscall

	li $s0, 0
	li $s1, 0 # Initialze total points
	li $s2, 1 # Initialze the current level number

	li $v0, 30 # Syscall 30 for getting ststem ime
	syscall
	move $a1, $a0 # Move system time to a1
	li $v0, 40 # Syscall 40 to set random seed
	li $a0, 0
	syscall

# loops through each level
level_loop:
	li $t7, 0 # Initialze correct answers to 0
	
	move $a0, $s2 # Move current level number to a0
	move $a1, $s1 # Move total points to a1
	jal display_board # Jump to display the current board

	li $s6, 0 # Initialze the question counter
	move $t8, $s2 # Set total questions for this level = current level number

# Manages individual questions in each level
question_loop:
	beq $s3, 1, skip_random # If timeout flag $s3 is 1, skip random generation
	jal generate_random_number # Jump to generate random number
	move $s4, $v0 # Move generated random number in $s4
	
	li $v0, 42 # Syscall 42 to generate random int in range
	li $a0, 0
	li $a1, 100  # Generate 0-99
	syscall
	
	li $t0, 50 # Set t0 to 50
	slt $s7, $a0, $t0  # $s7 = 1 if random < 50, else 0

# Resume previous question from timeout
skip_random:
	li $s3, 0  # Reset timeout flag $s3 to 0

	move $a0, $s6 # Move current question number to argument $a0
	jal display_question_number # Jump to display question number

	beq $s7, 1, binary_to_decimal_question # If $s7 = 1, do binary to decimal question
	j decimal_to_binary_question # Otherwise jump to decimal to binary question

# Binary to decimal converstion
binary_to_decimal_question:
	move $a0, $s4 # Move random number to argument $a0
	jal display_binary_to_decimal # Jump to display binary to decimal question
    
	jal get_decimal_input # Jump to get decimal input from user
	move $t4, $v0 # Store user's decimal answer in $t4
	move $a0, $t4 # Move user's answer to $a0 for timeout check
	jal check_timeout_decimal # Jump to check for timeout
	beq $v0, 1, timeout_pause # If timeout detected, jump to timeout handling
	
	beq $t4, $s4, correct_answer # If answer matches expected value, jump to correct
	li $v0, 4 # Syscall 4 to print incorrect message
	la $a0, incorrectMsg
	syscall
	jal play_incorrect_sound # Jump to play incorrect sound
	j after_question # Jump to after question processing

# Decimal to binary converstion
decimal_to_binary_question:
	move $a0, $s4 # Move random number to argument $a0
	jal display_decimal_to_binary # Jump to display decimal to binary question
    
	jal get_binary_input # Jump to get binary input from user

	move $a0, $v0 # Store user's binary string address in $a0
	jal check_timeout_binary # Jump to check for timeout
	beq $v0, 1, timeout_pause # If timeout detected, jump to timeout handling
    
	jal binary_to_decimal # Jump to convert users binary string to decimal
	move $t4, $v0 # Store converted decimal value in $t4
    
	beq $t4, $s4, correct_answer # If answer matches expected value, jump to correct
	li $v0, 4 # Syscall4 to print incorect message
	la $a0, incorrectMsg
	syscall
	
	jal play_incorrect_sound # Jump to play incorrect sound
	j after_question # Jump to next question

# Shows correct Answer
correct_answer:
	li $v0, 4 # If answer is correct then use syscall 4 to display correct mesasge
	la $a0, correctMsg
	syscall
	jal play_correct_sound # Play the correct sound
	addi $s1, $s1, 1 # Add 1 to the score1
	addi $t7, $t7, 1 # Add 1 to the level counter

# Cleans and continues progression
after_question:
	jal display_result_sep # Jump to display result separator
	addi $s6, $s6, 1 # Increment question counter by 1
	blt $s6, $t8, question_loop # If more questions in level, loop back

	move $a0, $t7 # Move correct count to argument $a0
	move $a1, $t8 # Move total questions to argument $a1
	jal display_level_complete # Jump to display level completion message

	li $v0, 4 # Syscall 4 ti display the board
	la $a0, board
	syscall

	li $t9, 10 # Load maximum level value 10 into $t9
	bge $s2, $t9, end_game # If current level >= max level, end game
	
	jal prompt_continue # Jump to prompt user to continue
	beq $v0, 0, end_game # If user chose to exit, end game
	addi $s2, $s2, 1  # Increment current level number by 1
	j level_loop # Jump back to level loop for next level
# Check for -1 timeout
check_timeout_binary:
	lb $t0, 0($a0) # Load first byte of input in t0
	li $t1, 45 # Load t1 with ascii character for - (Since -1 is called for timeout)
	bne $t0, $t1, no_timeout_bin # If no - detected then not a timeout and jump down
	lb $t0, 1($a0) # Otherwise load byte 2 into t0
	li $t1, 49 # Load t1 with ascii chacrter for 1 since -1 is needed for timeout
	bne $t0, $t1, no_timeout_bin # If no -1 detected then not timeout
	li $v0, 1 # Set return value 1 = timeout
	jr $ra # Return to caller

# Reset timeout value	
no_timeout_bin:
	li $v0, 0 # Set return value = 0 meaning no timeout
	jr $ra # Return to caller

# Check for -1 timeout
check_timeout_decimal:
	li $t1, -1 # Load -1 into t1 since that is needed for timeout
	beq $a0, $t1, is_timeout_dec # If input = -1 then timeout
	li $v0, 0 # Otherwise return 0
	jr $ra # Return to caller

# Reset timeout value
is_timeout_dec:
	li $v0, 1 # return 1 means timeout
	jr $ra # return to caller

# Waits for user enter to exit timeout
timeout_pause:
	li $v0, 4 # syscall 4 for displayings timeout message
	la $a0, timeoutMsg
	syscall
	jal wait_for_enter # Wait for enter key to resume question/level
	li $s3, 1 # Set timeout flag to 1
	j question_loop # Resume the question_loop

# Display info of end
end_game:
	li $v0, 4
	la $a0, scoreMsg # Use syscall 4 to display Score message
	syscall
	li $v0, 1
	move $a0, $s1 # Use syscall 1 to display actual score counter
	syscall
	li $v0, 4
 	la $a0, newline # Print newline
	syscall
	jal wait_for_enter # Wait for enter key to complely exit program
	li $v0, 10 # Exit program
	syscall

.include "display.asm"
.include "input.asm"
.include "conversions.asm"
.include "sounds.asm"
