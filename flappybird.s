#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Basil Kanaan, 1005530294
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4					     
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10040000 (heap)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Fancier Graphics: added a floor, more detailed bird, and shading
#
# Any additional information that the TA needs to know:
# - been swarmed with assignments all week, and like the idiot i am i procrastinated.
# still, i decided to try my best for this assignment and please note i just started from scratch today.
# yes it took me 9 straight hours of coding, but I'm happy with this program and I had fun making it.
# I hope you enjoy.
#
#####################################################################


.data
	displayAddress:	.word	0x10040000
	
	maxWidth: .word 64
	maxHeight: .word 128
	
	unit_pixel: .word 4
	
	groundHeight: .word 20
	grassHeight: .word 4
	undergroundHeight: .word 16
	
	skyColour: .word 0x04c4c4
	grassColour: .word 0x10e02c 
	groundColour: .word 0xf0ee95
	bodyColour: .word 0xffff00 
	beakColour: .word 0xffa500
	pipeColour: .word 0x02b00a
	
	# make bird 25 pixels with birdBody = top left of the bird
	birdBody: .word 15, 60
	birdSize: .word 7
	
	# pipe hole height
	pipeHoleHeight: .word 30
	pipeTop: .word -1, -1
	pipeWidth: .word 12
	
		

.text
	jal DRAW_SKY
	jal DRAW_GRASS
	jal DRAW_GROUND
	jal DRAW_BIRD
	jal GENERATE_PIPE
	jal DRAW_PIPE
	
	li $v0, 0	
	
	WHILE_GAME_NOT_STARTED:
		li $t1, 0xffff0000
		lw $t1, 0($t1)
		
		beqz $t1, WHILE_GAME_NOT_STARTED
		
		li $t1, 0xffff0004
		lw $t1, 0($t1)
		bne $t1, 102, WHILE_GAME_NOT_STARTED
		
		la $t0, birdBody
		lw $s4, 4($t0)
		
		jal DELETE_BIRD
		jal FLAP
		jal DRAW_BIRD
		
	MAIN_WHILE:	
		jal DELETE_BIRD
		jal DELETE_PIPE
		
		jal FLAP_IF_F
		jal FALL
		
		jal MOVE_PIPE
		jal GENERATE_PIPE
		
		jal DRAW_BIRD
		jal DRAW_PIPE
		
		jal CHECK_COLLISION
		
		
		li $a0, 250
		li $v0, 32
		syscall
		
		li $v0, 0
		
		beqz $v0, MAIN_WHILE
		
		
		
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	
	
DRAW_SKY:
	# t0 = colour
	lw $t0, skyColour 
	
	# t1 = x1
	li $t1, 0
	
	# t2 = y1
	li $t2, 0
	
	# t3 = x2
	lw $t3, maxWidth
	
	# t4 = y2
	lw $s0, maxHeight
	lw $s1, groundHeight
	sub $t4, $s0, $s1
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw sky block
	jal DRAW_BLOCK
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	

DRAW_GRASS:
	# t0 = colour
	li $t0, 0x0cb022 
	
	# t1 = x1
	li $t1, 0
	
	# t2 = y1
	lw $s0, maxHeight
	lw $s1, groundHeight
	sub $t2, $s0, $s1
	
	# t3 = x2
	lw $t3, maxWidth
	
	# t4 = y2
	lw $t4, grassHeight
	add $t4, $t4, $t2
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw sky block
	jal DRAW_BLOCK
	
	# t0 = colour
	lw $t0, grassColour
	
	# t1 = x1
	li $t1, 0
	
	# t2 = y1
	lw $s0, maxHeight
	lw $s1, groundHeight
	sub $t2, $s0, $s1
	
	# t3 = x2
	lw $t3, maxWidth
	
	# t4 = y2
	lw $t4, grassHeight
	add $t4, $t4, $t2
	addi $t4, $t4, -1
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)

	# draw sky block
	jal DRAW_BLOCK
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra


DRAW_GROUND:
	# t0 = colour
	lw $t0, groundColour 
	
	# t1 = x1
	li $t1, 0
	
	# t2 = y1
	lw $s0, maxHeight
	lw $s1, undergroundHeight
	sub $t2, $s0, $s1
	
	# t3 = x2
	lw $t3, maxWidth
	
	# t4 = y2
	lw $t4, maxHeight
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw sky block
	jal DRAW_BLOCK
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	

DRAW_BIRD:	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	li $t0, 0xd4d400
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw dark body
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, bodyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	addi $t1, $t1, 1
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	addi $t3, $t3, -1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	addi $t4, $t4, -1

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw light body
	jal DRAW_BLOCK
			
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	li $t0, 0xFFFFFF
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 

	# t4 = y2
	add $t4, $t2, $s1 

	add $t1, $t3, -2
	# add $t2, $t2, 1
	add $t4, $t2, 4

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw eye
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	li $t0, 0
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 

	# t4 = y2
	add $t4, $t2, $s1 

	add $t1, $t3, -1
	add $t2, $t2, 2
	add $t4, $t2, 1

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw pupil
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, beakColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	
	addi $t1, $t3, -1
	addi $t3, $t3, 3  
	add $t2, $t2, 3
	add $t4, $t2, 2

	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw beak
	jal DRAW_BLOCK
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	
	
DRAW_BLOCK: # takes in 3 paramaters, = (colour, x1, y1, x2, y2) from stack
	
	lw $t0, displayAddress	# $t0 stores the base address for display
	move $t1, $a0 # colour loaded into t1
	
	# pop all arguments from stack in this order: (colour, x1, y1, x2, y2)
	lw $t1, 0($sp) 
	lw $t2, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	add $sp, $sp, 20
	
	# s0 = x1  AND s1 = y1
	add $s0, $zero, $t2
	add $s1, $zero, $t3
	
	# t6 = (max width - x2 + x1) * 4
	lw $t6, maxWidth
	sub $t6, $t6, $t4
	add $t6, $t6, $t2
	li $s2, 4
	mult $t6, $s2
	mflo $t6
	
	# t0 += (y1 * (max_width)) + x1) * 4
	lw $s2, maxWidth
	mult $t3, $s2
	mflo $s2
	add $s2, $s2, $t2
	li $s3, 4
	mult $s2, $s3
	mflo $s2
	add $t0, $t0, $s2
		
	DBLOCK_FOR_Y:
		add $s0, $zero, $t2
		DBLOCK_FOR_X:
			sw $t1, 0($t0)	 # paint the pixel at t0 to colour
			
			addi $t0, $t0, 4
			addi $s0, $s0, 1
			
			bne $s0, $t4, DBLOCK_FOR_X
		
		add $t0, $t0, $t6
		addi $s1, $s1, 1
		bne $s1, $t5, DBLOCK_FOR_Y			
		
	jr $ra
	

FLAP_IF_F:
	li $t1, 0xffff0000
	lw $t1, 0($t1)
		
	beqz $t1, QUIT
	
	li $t1, 0xffff0004
	lw $t1, 0($t1)
	bne $t1, 102, QUIT
	
	
	
	add $sp, $sp, -4
	sw $ra, 0($sp)
		
	jal FLAP	
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	QUIT:
	jr $ra
	
	
FLAP:
	la $t0, birdBody
	lw $t1, 4($t0)
	addi $t1, $t1, -12
	sw $t1, 4($t0)
	
	jr $ra
	

FALL: 
	la $t0, birdBody
	lw $t1, 4($t0)
	addi $t1, $t1, 6
	sw $t1, 4($t0)
	
	jr $ra


DELETE_BIRD:
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw dark body
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	addi $t1, $t1, 1
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	addi $t3, $t3, -1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	addi $t4, $t4, -1

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw light body
	jal DRAW_BLOCK
			
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 

	# t4 = y2
	add $t4, $t2, $s1 

	add $t1, $t3, -2
	# add $t2, $t2, 1
	add $t4, $t2, 4

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw eye
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 

	# t4 = y2
	add $t4, $t2, $s1 

	add $t1, $t3, -1
	add $t2, $t2, 2
	add $t4, $t2, 1

	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw pupil
	jal DRAW_BLOCK
	
	la $s0, birdBody
	lw $s1, birdSize
	
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	
	# t3 = x2
	add $t3, $t1, $s1 
	
	# t4 = y2
	add $t4, $t2, $s1 
	
	addi $t1, $t3, -1
	addi $t3, $t3, 3  
	add $t2, $t2, 3
	add $t4, $t2, 2

	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw beak
	jal DRAW_BLOCK
	
	# pop original return address on the stack
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	
	
GENERATE_PIPE:
	la $t0, pipeTop
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	
	bne $t1, -1, QUIT_GENERATE
	
	# t2 = y1
	lw $s0, maxHeight
	lw $s1, groundHeight
	sub $s2, $s0, $s1
	addi $s2, $s2, -50
	
	li $a0, 1
	move $a1, $s2
	li $v0, 42
	syscall
	
	move $t2, $a0
	addi $t2, $t2, 10
	sw $t2, 4($t0)
	
	lw $t1, maxWidth
	addi $t1, $t1, -20
	sw $t1, 0($t0)
	
	
	QUIT_GENERATE:
	jr $ra
	
DRAW_PIPE:

	la $s0, pipeTop
		
	# t0 = colour
	lw $t0, pipeColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	li $t2, 0
	
	# t3 = x2
	lw $s1, pipeWidth
	add $t3, $t1, $s1
	
	# t4 = y2
  	lw $t4, 4($s0)
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw dark body
	jal DRAW_BLOCK

	la $s0, pipeTop
		
	# t0 = colour
	lw $t0, pipeColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	lw $s1, pipeHoleHeight
	add $t2, $t2, $s1
	
	# t3 = x2
	lw $s1, pipeWidth
	add $t3, $t1, $s1
	
	# t4 = y2
	lw $s3, maxHeight
	lw $s1, groundHeight
	sub $s2, $s3, $s1

  	move $t4, $s2
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)

	
	# draw dark body
	jal DRAW_BLOCK
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	
	
MOVE_PIPE:
	
	la $t0, pipeTop
	lw $t1, 0($t0)
	addi $t1, $t1, -4

	
	bgt $t1, -12 quit_MP
		li $t1 -1
	quit_MP:
	sw $t1, 0($t0)
	jr $ra
	
DELETE_PIPE:
	
	la $s0, pipeTop
		
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	li $t2, 0
	
	# t3 = x2
	lw $s1, pipeWidth
	add $t3, $t1, $s1
	
	# t4 = y2
  	lw $t4, 4($s0)
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 20($sp)
	
	# draw dark body
	jal DRAW_BLOCK

	la $s0, pipeTop
		
	# t0 = colour
	lw $t0, skyColour
	
	# t1 = x1
	lw $t1, 0($s0)
	
	# t2 = y1
	lw $t2, 4($s0)
	lw $s1, pipeHoleHeight
	add $t2, $t2, $s1
	
	# t3 = x2
	lw $s1, pipeWidth
	add $t3, $t1, $s1
	
	# t4 = y2
	lw $s3, maxHeight
	lw $s1, groundHeight
	sub $s2, $s3, $s1

  	move $t4, $s2
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)

	
	# draw dark body
	jal DRAW_BLOCK
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	
	jr $ra
	
	

CHECK_COLLISION:
	la $t0, birdBody
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	
	lw $t5, birdSize
	add $t2, $t2, $t5
	
	# t2 = y1
	lw $s0, maxHeight
	lw $s1, groundHeight
	sub $s2, $s0, $s1
	
	bge $t2, $s2, GAMEOVER_SCREEN
	
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	
	la $t3, pipeTop
	lw $t4, 0($t3)
	lw $t5, 4($t3)
	
	XG_PIPEL:
		lw $s0, birdSize
		add $t1, $t1, $s0
		blt $t1, $t4, DONE
	XL_PIPER:
		lw $t1, 0($t0)
		
		lw $s0, pipeWidth
		add $t4, $t4, $s0
		
		bgt $t1, $t4, DONE
		
	BIRD_IN_PIPE:
	YG_PIPET:
		lw $t1, 0($t0)
		lw $t2, 4($t0)
		
		lw $t4, 0($t3)
		lw $t5, 4($t3)
		
		ble $t2, $t5, GAMEOVER_SCREEN
		
	YL_PIPEB:
		lw $s0, birdSize
		add $t2, $t2, $s0
		
		lw $s0, pipeHoleHeight
		add $t5, $t5, $s0
		
		bge $t2, $t5, GAMEOVER_SCREEN
	
	DONE:
	
	jr $ra
	

GAMEOVER_SCREEN:
	# t0 = colour
	li $t0, 0
	
	# t1 = x1
	li $t1, 0
	
	# t2 = y1
	li $t2, 0
	
	# t3 = x2
	lw $t3, maxWidth

	
	# t4 = y2
  	lw $t4, maxHeight
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw dark body
	jal DRAW_BLOCK
	
	# t0 = colour
	li $t0, 0xFFFFFF
	
	# t1 = x1
	li $t1, 15
	
	# t2 = y1
	li $t2, 30
	
	# t3 = x2
	li $t3, 25

	# t4 = y2
  	li $t4, 100
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw dark body
	jal DRAW_BLOCK
	
	# t0 = colour
	li $t0, 0xFFFFFF
	
	# t1 = x1
	li $t1, 15
	
	# t2 = y1
	li $t2, 90
	
	# t3 = x2
	li $t3, 48

	# t4 = y2
  	li $t4, 100
	
	# prepare arguments for DRAW_BLOCK by
	# pushing onto stack in this order: colour, x1, y1, x2, y2, return address
	add $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	# draw dark body
	jal DRAW_BLOCK
	
	li $v0, 10
	syscall
