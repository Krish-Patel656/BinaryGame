# This file contains all messgaes that might be printed for the user to see.
# This includes welcome messages, error messages, formatting, promts, etc.


.data

	welcome: .asciiz "                   WELCOME TO BINARY GAME!                    \n"
	formatWelcome: .asciiz "==============================================================\n\n"
    
	choose: .asciiz "" 
    
	enterBin: .asciiz "Enter your 8-bit binary string answer (or -1 for timeout): "
	enterDec: .asciiz "Enter your integer answer in the range [0, 255] (or -1 for timeout): "
    
	correctMsg: .asciiz ">>> Correct! +1 point\n"
	incorrectMsg: .asciiz ">>> Incorrect! "
    
	scoreMsg: .asciiz "\n=== GAME COMPLETE! Final Score: "
	timeoutMsg: .asciiz "\n*** Timeout! Press Enter to resume the same question...\n"
    
	newline: .asciiz "\n"
	question_msg: .asciiz "Question "
    
	continue_prompt: .asciiz "\nPress 1 to continue to next level, 0 to exit: "

    # ASCII Board
	board: .asciiz "+-------------------------------+\n"
	game_title: .asciiz "|        BINARY GAME            |\n"
	board_mid: .asciiz "+-------------------------------+\n"
	level_label: .asciiz "| Level: "
	points_label: .asciiz "  Points: "
	dec_label: .asciiz "| Decimal: "
	bin_label: .asciiz "| Binary : "

	# Box-style display elements
	bit_positions: .asciiz "   7   6   5   4   3   2   1   0   \n"
	box_border: .asciiz "  +---+---+---+---+---+---+---+---+\n"
	box_bits_start: .asciiz "  | "
	box_separator: .asciiz " | "
	box_bits_end: .asciiz " |\n"
	empty_boxes_row: .asciiz "  |   |   |   |   |   |   |   |   |\n"
	equals_label: .asciiz "  = "

	# Validation error messages
	invalid_binary_msg: .asciiz ">>> ERROR: Binary must be exactly 8 bits (0s and 1s only)\n"
	invalid_decimal_msg: .asciiz ">>> ERROR: Decimal must be between 0-255\n"
    
    # Clear separators
	result_sep: .asciiz "|-------------------------------|\n"

	level_complete: .asciiz "\n*** LEVEL COMPLETE! "
	level_stats: .asciiz " correct out of "
	level_questions: .asciiz " questions\n"
    
    # Input buffer
	input_buf: .space 12
