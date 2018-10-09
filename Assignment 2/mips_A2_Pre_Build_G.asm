#
#	mips_A2.asm
#	MIPS Assignment 2
#
#
#	Created by uniKerogen on 10/4/18.
#	copyright ©	uniKerogen.	All rights reserved.

.data 0x10010000
	firstPromptString:	.asciiz 	">>> "
	invalidString:		.asciiz 	"Invalid Input \n"
	validString:		.asciiz		"Valid Input \n"
	newLine:		.asciiz		"\n"
	deividerString:		.asciiz 	"--------------------"
	matchString:		.asciiz		"1234567890()+-*/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz \n"

.data 0x100100a0
	userInput:		.space		63
	
.data 0x10010100
	organizedString:	.space		63
	
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
	
verificationPrep:
	la	$s0,	matchString		
	la	$s1,	userInput		
	addi	$s2,	$s1,	1		
	addi	$s3,	$s2,	1		
	addi	$s4,	$s4,	1		
	addi	$s5,	$s5,	1		
	
	#Reserve for Clean Up
	li	$s6,	2			
	li	$t6,	0			
	li	$s7,	70			
	li	$t7,	0			
	li	$t8,	0			
	li	$t9,	0			
	
	j	verification
	
resultNo:
	la	$a0,	invalidString		
	li	$v0,	4			
	syscall
	j	exit
	
exit:	la 	$a0,	deividerString		#Not Necessary But Recommanded
	li	$v0,	4			#Not Necessary but Recommanded
	syscall					#Not Necessary but Recommanded
	la	$a0,	newLine			#Not Necessary but Recommanded
	li	$v0,	4			#Not Necessary but Recommanded
	syscall					#Not Necessary but Recommanded
	
	li	$v0,	10
	syscall

##-------VERIFICATION SUB FUNCTION-------##	
	
	##REDO THIS PART##
	
verification:					
	lb	$t0,	($s0)			
	lb	$t1,	($s1)			
	lb	$t2,	($s2)			
	lb	$t3,	($s3)			
	lb	$t4,	($s4)
	lb	$t5,	($s5)

	beq	$t0,	$zero,	resultNo	
	beq	$t1,	$zero,	calculationPrep	
	
	bne 	$t0,	$t1,	nextComparison
	beq	$t0,	$t1,	variableNumber
	
nextComparison:
	addi	$s0,	$s0,	1		
	j	verification
	
variableNumber:
	bge	$t1,	'a',	variableLower	#Limit Character a - z
	bge	$t1,	'A',	variableCapital	#Limit Character A - Z
	bge	$t1,	'0',	numberCount	#Limit Number 0 - 9
	j	twoOperators			#Leftover Operators

numberCount:					#Count Number
	bgt	$t1,	'9',	twoOperators	#Continue If t1 is Not a Number
	bge	$t2,	'0',	numberCount2	#Coutinue Count If t2 is a Number
	j	twoOperators			#Continue If t2 is Not a Number

numberCount2:
	bgt	$t2,	'9',	resultNo	#Exit If t2 is a Character
	bge	$t3,	'0',	numberCount3	#Continue Count If t3 is a Number
	j	twoOperators			#Continue If t3 is Not a Number

numberCount3:
	bgt	$t3,	'9', 	resultNo	#Exit If t3 is a Character
	bge	$t4,	'0',	numberCount4	#Continue Count If t4 is a Number
	j	twoOperators			#Continue If t4 is Not a Number
	
numberCount4:
	bgt	$t4,	'9',	resultNo	#Exit If t4 is a Character
	bge	$t5,	'0',	resultNo	#Exit If t5 is Not an Operator
	j	twoOperators			#Continue If t5 is an Operator

variableLower:
	bgt	$t1,	'z',	twoOperators	#Continue if ASCII of t1 is greater than 'z'
	addi	$t6,	$t6,	1		#Increase the Variable Count
	beq	$t6,	2,	resultNo	#Exit When There are Two Variable
	j	twoOperators
	
variableCapital:
	bgt	$t1,	'Z',	variableCapital	#Continue if ASCII of t1 is greater than 'Z'
	addi	$t6,	$t6,	1		#Increase the Variable Count
	beq	$t6,	2,	resultNo	#Exit When There are Two Variable
	j	twoOperators
	
twoOperators:					#Looking for Two Continous Operator Input
	beq	$t1,	'+',	secondOperator	#Check the First Operator
	beq	$t1,	'-',	secondOperator	#Jump to Check the Second Operator
	beq	$t1,	'*',	secondOperator	#If this Character is an Operator
	beq	$t1,	'/',	secondOperator	
	j	frontParenthesis
	
secondOperator:					#Check the Second Operator
	beq	$t2,	'+',	resultNo	#Exit Loop
	beq	$t2,	'-',	resultNo	#If the Second Character is also an Operator
	beq	$t2,	'*',	resultNo	
	beq	$t2,	'/',	resultNo	
	j	frontParenthesis
	
frontParenthesis:				#Find and Mark Apparence of (
	bne	$t1,	'(',	backParenthesis
	addi	$t8,	$t8,	1		#Add ( Count
	beq	$t2, 	')',	resultNo	#Exit Loop if the next Character is )
	beq	$t2,	'+',	resultNo	#Check if ( is Followed by operators
	beq	$t2,	'-',	resultNo
	beq	$t2,	'*',	resultNo
	beq	$t2,	'/',	resultNo
	
backParenthesis:
	bne	$t1,	')',	restartLoop	#Find and Mark Apparence of )
	addi	$t9,	$t9,	1		#Add ) Count
	beq	$t2,	'+',	restartLoop	#Check if ) is Followed by operators
	beq	$t2,	'-',	restartLoop
	beq	$t2,	'*',	restartLoop
	beq	$t2,	'/',	restartLoop
	beq	$t2,	'\n',	restartLoop
	j	resultNo
	
restartLoop:
	addi	$s1,	$s1,	1		#Increase the Input Location Count Only
	li	$s7,	70			#Reset number Count
	la	$s0,	matchString		#Reset Location
	j	verification
	


##------Calculation Sub Function------##

calculationPrep:
	bne	$t8,	$t9,	resultNo	#Exit when Mismatch in '(' & ')'

	la	$s0,	userInput		#Load Input Address
	la	$s1,	organizedString		#Set Save Location
	
	#Reserve for Clean Up
	li	$s7,	0			#Special Character Address
	
	#Special Reserved Registor
	li	$t1,	0			#Varying Registor - DO NOT CHANGE
	li	$t2,	0			#Varying Registor - DO NOT CHANGE
	li	$t3,	0			#Varying Registor - DO NOT CHANGE
	li	$t4,	0			#Varying Registor - DO NOT CHANGE
	li	$t8,	0			#Varying Registor - DO NOT CHANGE
	li	$t9,	0			#Varying Registor - DO NOT CHANGE
	
organizeString:					#Organize String for Calculation
	lw	$t0,	($s0)			#Load Input Character
	beq	$t0,	$zero,	parenthesisCalculation
	bgt	$t0,	'9',	organizeStringMark
	blt	$t0,	'0',	storeCharacter
	jal	numberRecognize
	move	$t0,	$t8			
	add	$s0,	$s0,	$t9		
	j	storeCharacter
organizeStringMark:
	move	$s7,	$s0			
	j	storeCharacter
storeCharacter:
	sw	$t0,	($s1)			
	bne	$t9,	0,	organizeStringNext
	addi	$s0,	$s0,	4		
organizeStringNext:
	addi	$s1,	$s1,	4		
	j	organizeString
	
parenthesisCalculation:
	#CONTENT BLOCKED
	
printResult:					
	
	j	exit
	
	
	
##-------General Function-------##
	
#Loading Example for numberRecognize Function
	#la	$s0,	inputLocation		#Input to the Function
	#jal	numberRecognize
	#move	$s7,	$t8			#Move Output to $s7
	#add	$s0,	$s0,	$t9		#Advance Address by $t9
	
numberRecognize:				#numberRecognize Function
	#CONTENT BLOCKED
	
#Loading Example for parenthsisRecognization
	#CONTENT BLOCKED
	
parenthesisRecognize:
	#CONTENT BLOCKED
	
#Loading Example for calculateEquation
	#li	$s0,	inputLocation		#Load inputLocation
	#jal	calculateEquation		#Jump and Link to Function
	#move	$t0,	$t0			#Result is stored in $t0
	#add	$s0,	$s0,	16		#Advance $s0 by 4 Address WHEN DONE with Calculation
	
#THis Calculation is limited to 256 as max result
calculateEquation:				#Start Calculation
	beq	$s0,	$s7,	calculateequationNoValue
	lw	$t0,	($s0)			#Load First Value & Result Storage
	lw	$t1,	4($s0)			#Load Operator
	addi 	$t2,	$s0,	8		#Check Value for Specail Character
	beq	$t2,	$s7,	calculateequationNoValue
	lw	$t2,	8($s0)			#Load Second Value
	beq	$t2,	$zero,	calculateequationNoValue
	beq	$t1,	'+',	calculateequationAddition
	beq	$t1,	'-',	calculateequationSubstraction
	beq	$t1,	'*',	calculateequationMutiplication
	beq	$t1,	'/',	calculateequationDivision
	j	calculateequationEnd		#Exit When No Match
calculateequationAddition:
	add 	$t0,	$t0,	$t1		#Additional Operation
	j	calculateequationEnd
calculateequationSubstraction:
	sub	$t0,	$t0,	$t1		#Substraction Operation
	j	calculateequationEnd
calculateequationMutiplication:
	mul	$t0,	$t0,	$t1		#Multiply Operation
	j	calculateequationEnd		
calculateequationDivision:
	div	$t0,	$t0,	$t1		#Division Operation
	j	calculateequationEnd		#Division Operation ONLY return Integers
calculateequationNoValue:
	subi	$s0,	$s0,	12		#Set Back Location by 12
calculateequationEnd:
	li	$t1,	0			#Reset Registers
	li	$t2,	0
	jr	$ra

	
