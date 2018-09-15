.data 0x10010000
	firstPromptString:	.asciiz 	">>> "
	invalidString:		.asciiz 	"Invalid Input \n"
	validString:		.asciiz		"Valid Input \n"
	newLine:		.asciiz		"\n"
	deividerString:		.asciiz 	"--------------------"
	matchString:		.asciiz		"1234567890()+-*/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n"

.data 0x10010100
	userInput:		.space		63
	

.text 	

main:
	#Prompt To Input
	la 	$a0,	firstPromptString
	li	$v0,	4
	syscall 
	
	#Input Reading
	la	$a0,	userInput
	li	$a1,	61
	li	$v0,	8
	syscall
	
	#Initialize String Location
	la	$s2,	userInput		#Load Input Address
	move	$t2,	$s2			#Save Address to t2
	la	$s3,	matchString		#Load Match Address
	move	$t3,	$s3			#Save Match Address
	move	$t4,	$s3			#Store Initial Location
	li	$t5,	70			#Number of total Character
	
	j	findMatch
	
resultNo:
	la	$a0,	invalidString		#Print invalid Result
	li	$v0,	4
	syscall
	j	Exit
	
resultYes:
	la	$a0,	validString		#Print Valid Result
	li	$v0,	4
	syscall
	j	Exit
	
Exit:	la 	$a0,	deividerString		#Loop Back
	li	$v0,	4
	syscall
	la	$a0,	newLine
	li	$v0,	4
	syscall
	
	j	main

#------Sub Function-------#

findMatch:
	lb	$t2,	($s2)			#User Input
	lb	$t3,	($s3)			#Match Location
	
	beq	$t2,	$zero,	resultYes	#Exit loop when Input reaches 0
	beq	$t3,	$zero,	resultNo	#Exit loop when Match reaches 0
	
	bne 	$t2,	$t3,	nextStep
	beq	$t2,	$t3,	nextCharacter
	
nextStep:
	addi	$s3,	$s3,	1		#Increase the Match Location Count Only
	sub	$t5,	$t5,	1		#Decrease number count
	j	findMatch
	
nextCharacter:
	addi	$s2,	$s2,	1		#Increase the Input Location Count Only
	li	$t5,	70			#Reset number Count
	move	$s3,	$t4
	j	findMatch
	

	

	
