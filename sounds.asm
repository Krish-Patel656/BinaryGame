# This file contains the incorrect and correct sounds that are utilized
# in the program. It uses syscalls to output an audio.

.text
.globl play_correct_sound, play_incorrect_sound

# Sound MIDI tones from Syscall word Document

play_correct_sound:
	li $v0, 33 # Load syscall 33 that will play MIDI sound
	li $a0, 72 # Pitch of sound
	li $a1, 200 # Duration of sound
	li $a2, 0 # Type of sound
	li $a3, 127 # Set volume
	syscall # execute sound
	jr $ra # Return 

play_incorrect_sound:
	li $v0, 33 # Load syscall 33 that will play MIDI sound
	li $a0, 48 # Pitch of sound
	li $a1, 200 # Duration of sound
	li $a2, 0 # Type of sound
	li $a3, 127 # Set volume
	syscall # execute sound
	jr $ra # Return 
