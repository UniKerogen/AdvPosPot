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
	li 	$t6,	0			#Clena up Memory
	li	$t7,	0			#Clean up Memory
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
	add	$t7,	$t6,	$t7
	beq	$t7,	1,	resultNo	#Mismatch in ( & )
	la	$a0,	validString		#Print Valid Result
	li	$v0,	4
	syscall
	j	Exit
	
Exit:	la 	$a0,	deividerString		#Not Necessary But Recommanded
	li	$v0,	4			#Not Necessary but Recommanded
	syscall					#Not Necessary but Recommanded
	la	$a0,	newLine			#Not Necessary but Recommanded
	li	$v0,	4			#Not Necessary but Recommanded
	syscall					#Not Necessary but Recommanded
	
	j	main				#Loop back for second run

#------Sub Function-------#

findMatch:
	lb	$t2,	($s2)			#User Input
	lb	$t3,	($s3)			#Match Location
	
	bne	$t2,	'(',	subStep1	#Match the first (
	li	$t6,	1
	
subStep1:
	bne	$t2,	')',	subStep2	#Clear Flag if there is )
	li	$t7,	1
	
subStep2:
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
	

	

	
