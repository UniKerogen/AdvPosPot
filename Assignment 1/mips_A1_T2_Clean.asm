.data 0x10010000
	firstPromptString:	.asciiz 	"Enter a number to find factorial: "
	answerString:		.asciiz 	"Ans: "
	newLine:		.asciiz		"\n"
	deividerString:		.asciiz 	"--------------------"
	

.text 	

## !!!Read This!!!
## deividerString is not necessary.
## Formatting part is not necessary. Refer below for details.

main:
	#Prompt To Input
	la 	$a0,	firstPromptString	
	li	$v0,	4			# 4 is the system call for print
	syscall 
	
	#Input Reading
	li	$v0,	5			# 5 is the system call for reading integer
	syscall
	move	$a0,	$v0			#Input is stored in a0
	
	jal	fact				#Initialize Factorial Sequence
	move	$t1,	$v0			#Output is stored in t1
	
	#Print the Result
	la	$a0,	answerString		#Print the first part of the answer
	li	$v0,	4
	syscall
	
	move	$a0,	$t1			#Print the number of the answer
	li	$v0,	1
	syscall
	
	#Formatting
	la	$a0,	newLine			#Not Necessary but Recommanded
	li	$v0,	4			#Not Necessary but Recommanded
	syscall					#Not Necessary but Recommanded
	la	$a0,	deividerString		#Not Necessary
	li	$v0,	4			#Not Necessary
	syscall					#Not Necessary
	la	$a0,	newLine			#Not Necessary
	li	$v0,	4			#Not Necessary
	syscall					#Not Necessary

Loop:	j	main				#Loop back for second run

fact:
	addi	$sp,	$sp,	-8		#Set $sp
	sw	$ra,	4($sp)
	sw	$a0,	0($sp)
	slti	$t0,	$a0, 	1
	beq	$t0,	$zero,	L1
	addi	$v0,	$zero,	1
	addi	$sp,	$sp,	8
	jr	$ra
L1:	addi	$a0,	$a0,	-1		#The input is used in $a0
	jal	fact
	lw	$a0,	0($sp)
	lw	$ra,	4($sp)
	addi	$sp,	$sp,	8		#Reset $sp
	mul	$v0,	$a0,	$v0		#The result will be output in $v0
	jr	$ra

	

	

	
