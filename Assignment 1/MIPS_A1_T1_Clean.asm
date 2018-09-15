.data 0x10010000
	firstPromptString:	.asciiz 	"Input Here (Less than 60 characters): "
	programEndString:	.asciiz 	"Program Has Ended"

.data 0x10010080
	eraseString:		.asciiz 	"***************************************************************\n"	
	
.data 0x100100c0	
	separaterString1:	.asciiz		"--------------------------------"
.data 0x100100e0
	inputString: 		.space		63
.data 0x10010120	
	separaterString2:	.asciiz		"--------------------------------"
.data 0x10010140
	storageArea:		.space		63

.text 

main:
	#Prompt To Input
	la 	$a0,	firstPromptString
	li	$v0,	4			# 4 is system call for printing string
	syscall 
	
	#Input Reading
	la	$a0,	inputString
	li	$a1,	61			# 61 is for the length of the input
	li	$v0,	8			# 8 is system call for reading string
	syscall

	#Address Setup
	la  	$a0,	storageArea 		#address of desired Storage Area
	la	$a1,	inputString 		#address of Input String	
	#String Copy
	jal	strcpy

cleanUp:
	la	$a0,	inputString		#Put a break point in front of this line to see the result
	la	$a1,	eraseString
	jal	strcpy
	la	$a0,	storageArea
	la	$a1,	inputString
	jal	strcpy
	
loop:	j	main				

#String Copy Subfunction
strcpy:
	addi 	$sp, 	$sp, 	-4
	sw 	$s0, 	0($sp)
	add 	$s0, 	$zero, 	$zero
	
L1:	add	$t1, 	$s0, 	$a1
	lbu	$t2, 	0($t1)
	add 	$t3, 	$s0, 	$a0
	sb	$t2, 	0($t3)
	beq	$t2, 	$zero, 	L2
	addi 	$s0, 	$s0, 	1
	j	L1

L2:	lw	$s0,	0($sp)
	addi	$sp, 	$sp, 	4
	jr	$ra
	

	

	
