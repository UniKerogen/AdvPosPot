.data 0x10010000
	firstPromptString:	.asciiz 	"Enter a number to find factorial: "
	answerString:		.asciiz 	"Ans: "
	newLine:		.asciiz		"\n"
	deividerString:		.asciiz 	"--------------------"
	

.text 	

main:
	#Prompt To Input
	la 	$a0,	firstPromptString	
	li	$v0,	4			# 4 is the system call for print
	syscall 
	
	#Input Reading
	li	$v0,	5			# 5 is the system call for reading integer
	syscall
	move	$a0,	$v0			#Input is stored in a0
	
	jal	fact
	move	$t1,	$v0			#Output is stored in t1
	
	#Print the Result
	la	$a0,	answerString
	li	$v0,	4
	syscall
	
	move	$a0,	$t1
	li	$v0,	1
	syscall
	
	#Formatting
	la	$a0,	newLine
	li	$v0,	4
	syscall
	la	$a0,	deividerString
	li	$v0,	4
	syscall
	la	$a0,	newLine
	li	$v0,	4
	syscall

Loop:	j	main

fact:
	addi	$sp,	$sp,	-8
	sw	$ra,	4($sp)
	sw	$a0,	0($sp)
	slti	$t0,	$a0, 	1
	beq	$t0,	$zero,	L1
	addi	$v0,	$zero,	1
	addi	$sp,	$sp,	8
	jr	$ra
L1:	addi	$a0,	$a0,	-1
	jal	fact
	lw	$a0,	0($sp)
	lw	$ra,	4($sp)
	addi	$sp,	$sp,	8
	mul	$v0,	$a0,	$v0
	jr	$ra

	

	

	
