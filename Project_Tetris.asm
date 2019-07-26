#Author: Violette Allahham
#Project: Tetris

#-----------------------------------------------------
#		Bitmap Display Settings:
#	Unit Width:	16
#	Unit Height:	16
#	Display Width:	256
#	Display Height:	512
#	Base Address:	0x10008000 ($gp)
#-----------------------------------------------------

.data
frameBuffer:	.space	0x80000


lightBlue:	.word	0x5dc8e2
blue:		.word	0x2c58db
red:		.word	0xff3434
yellow:		.word 	0xfff435
green:		.word	0x86e25d
orange:		.word	0xff9933
purple:		.word	0xb95de2
black:		.word	0x000000

screenWidth:	.word	16
screenHeight:	.word	30


blockStartX:	.word	8	#Zero position of X is left of screen
blockStartY:	.word	0	#Zero position of Y is top of screen

block:		.word	0
#---------------------Macros----------------------------

.macro stackPush(%n)
sub $sp, $sp, 4
sw $ra, %n($sp)
.end_macro

.macro stackPop(%n)
lw $ra, %n($sp)
addi $sp, $sp, 4
.end_macro

#Fills bitmap pixel with color
.macro pixelPlacement (%x , %y , %color)
lw $a0, blockStartX	#Loads block position X-axis of bitmap
lw $a1, blockStartY	#loads block position Y-axis of bitmap
addi $a0, $a0, %x	#increments X position of pixel
addi $a1, $a1, %y	#increments Y position of pixel
jal coordinateToAdress
lw $a2, %color		#Loads color
jal drawPixel		#draw color at pixel
.end_macro

#Clears entire row
.macro clearLine
lw $s0, screenWidth
clear:
li $a0, 0		#X-axis of bitmap
add $a0, $a0, $t0	#increments X position of pixel with counter
jal coordinateToAdress
lw $a2, black		#Loads background color
jal drawPixel		#draw pixel

addi $t0, $t0, 1	#counter
beq $t0, $s0, endLoop	#end when looped through width of bitmap
j clear
endLoop:
li $t0, 0		#clear registers
li $s0, 0
.end_macro

.text
main:

#------------------------------Reset-----------------------

#Reset Black screen
#lw $a0, screenWidth
#lw $a1, screenHeight
#lw $a2, black		#background color
#mul $a3, $a0, $a1 	#total number of pixels on screen
#mul $a3, $a3, 4	#align addresses 
#add $a3, $a3, $gp 	#add base of gp  
#add $a0, $gp, $zero 	#loop counter

#reset:
#beq $a0, $a3, clearReg  #when counter is equivalent to number of pixels on screen, initialize game
#sw $a2, 0($a0)		#store black in pixel
#addiu $a0, $a0, 4	#increment counter
#j reset

#Clearing Registers
clearReg:
li $v0, 0
li $a0, 0
li $a1, 0
li $a2, 0
li $a3, 0
li $t0, 0
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0
li $t8, 0
li $t9, 0
li $s0, 0
li $s1, 0
li $s2, 0
li $s3, 0
li $s4, 0

start:

#Random block chosen
nextBlock:
#li, $a0, id
li $a1, 7		#Random number generator within range 0-6
li $v0, 42
syscall
sw $a0, block
sw $zero, blockStartY

#Goes to current Block being used
currentBlock:
stackPush(4)
lw $s0, block

beq $s0, 0, Straight_Block	
beq $s0, 1, Square_Block	
beq $s0, 2, L_Block		
beq $s0, 3, ReverseL_Block	
beq $s0, 4, T_Block		
beq $s0, 5, Z_Block		
beq $s0, 6, ReverseZ_Block		

#-------------------Blocks---------------------------------

Straight_Block:				#Draw Straight block	
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(0, 0, lightBlue)
pixelPlacement(1, 0, lightBlue)
pixelPlacement(-1, 0, lightBlue)
pixelPlacement(-2, 0, lightBlue)
j collisionCheck

clearStraight_Block:			#Clear Stright block
pixelPlacement(0, 0, black)
pixelPlacement(1, 0, black)
pixelPlacement(-1, 0, black)
pixelPlacement(-2, 0, black)
stackPop(0)
jr $ra

Square_Block:				#Draw Square block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(0, 0, yellow)
pixelPlacement(0, 1, yellow)
pixelPlacement(-1, 0, yellow)
pixelPlacement(-1, 1, yellow)
j collisionCheck

clearSquare_Block:			#Clear Square block
pixelPlacement(0, 0, black)
pixelPlacement(0, 1, black)
pixelPlacement(-1, 0, black)
pixelPlacement(-1, 1, black)
stackPop(0)
jr $ra

L_Block:				#Draw L block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(0, 1, orange)
pixelPlacement(1, 1, orange)
pixelPlacement(-1, 1, orange)
pixelPlacement(1, 0, orange)
j collisionCheck

clearL_Block:				#Clear L block
pixelPlacement(0, 1, black)
pixelPlacement(1, 1, black)
pixelPlacement(-1, 1, black)
pixelPlacement(1, 0, black)
stackPop(0)
jr $ra

ReverseL_Block:				#Draw Reverse L block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(0, 1, blue)
pixelPlacement(1, 1, blue)
pixelPlacement(-1, 1, blue)
pixelPlacement(-1, 0, blue)
j collisionCheck

clearReverseL_Block:			#Clear Reverse L block
pixelPlacement(0, 1, black)
pixelPlacement(1, 1, black)
pixelPlacement(-1, 1, black)
pixelPlacement(-1, 0, black)
stackPop(0)
jr $ra

T_Block:				#Draw T block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(0, 0, purple)
pixelPlacement(-1, 1, purple)
pixelPlacement(0, 1, purple)
pixelPlacement(1, 1, purple)
j collisionCheck

clearT_Block:				#Clear T block
pixelPlacement(0, 0, black)
pixelPlacement(-1, 1, black)
pixelPlacement(0, 1, black)
pixelPlacement(1, 1, black)
stackPop(0)
jr $ra

Z_Block:				#Draw Z block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(-1, 0, red)
pixelPlacement(0, 0, red)
pixelPlacement(0, 1, red)
pixelPlacement(1, 1, red)
j collisionCheck

clearZ_Block:				#Clear Z block
pixelPlacement(-1, 0, black)
pixelPlacement(0, 0, black)
pixelPlacement(0, 1, black)
pixelPlacement(1, 1, black)
stackPop(0)
jr $ra

ReverseZ_Block:				#Draw Reverse Z block
beq $t0, 1, clearStraight_Block		#Branches to corresponding clear block
pixelPlacement(1, 0, green)
pixelPlacement(0, 0, green)
pixelPlacement(0, 1, green)
pixelPlacement(-1, 1, green)
j collisionCheck

clearReverseZ_Block:			#ClearReverse Z block
pixelPlacement(1, 0, black)
pixelPlacement(0, 0, black)
pixelPlacement(0, 1, black)
pixelPlacement(-1, 1, black)
stackPop(0)
jr $ra

#------------------------Functions------------------------

#Block fall
fall:
li $a0, 1000		#Pause delay for 1 second
li $v0, 32
syscall 

clearBlock:
li $t0, 1
lw $a1, blockStartY	
j currentBlock #beq $s0, 1 currentBlock	#Branch to currentBlock for clearing
stackPush (0)
addi $t1, $t1, 1	#counter
add $a1, $a1, $t1	#Incriment Y position with counter
sw $a1, blockStartY
li $t0, 0		
j currentBlock

#Fill location of pixel with color
drawPixel:
sw $a2, ($a0)		#store color into $a0
jr $ra

#Update Pixel location
coordinateToAdress:
lw $v0, screenWidth
mul $v0, $v0, $a1	#Multiply screen width by block position Y
add $v0, $v0, $a0	#add block position X
mul $v0, $v0, 4		
add $v0, $v0, $gp	#add global position of bitmap
move $a0, $v0
jr $ra

#Checks for collision of block with bottom of screen or another block
collisionCheck:
lw $v0, screenHeight
lw $t0, blockStartY
#sub $t1, $t1, 1
beq $t0, $v0, nextBlock	#Keeps falling until hits bottom of screen

#collision with another color

j fall

exit:
li $v0 10
syscall


#Fix stack ra because ra in fall is being overwritten once it gets to block








Action:

down:

left:

right:

rotate:		#using up
