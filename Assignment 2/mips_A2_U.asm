#
#	mips_A2_S.asm
#	MIPS Assignment 2
#
#
#	Created by Kerogen on 10/9/18.
#	copyright ©	Kerogen.	All rights reserved.

.include "mips_A2_Macro_U.asm"
 

.text
##------Input Reading Function------##
inputReading:
	printString(firstPromptString)
	
	la	$a0,	userInput		#Load Input Address
	li	$a1,	61			#Assign Input Length
	li	$v0,	8			#System Call for reading string
	syscall
	stringCleanUp(userInput, '\n')		#Remove '\n' from Input String
	j	verificationPreparation
	
##------Exit Program------##
resultNo:
	printString(invalidString)		#Print Invalid String
	
exitFunction:	
	printString(newLine)			#Not Necessary but Recommanded
	printString(deividerString)		#Not Necessary but Recommanded
	printString(newLine)			#Not Necessary but Recommanded
	resetMemory(userInput)
	resetMemory(organizedString)
	j	inputReading

##------Verification Sub Function------##
verificationPreparation:
	la	$s0,	userInput		#Load Input address
	resetRegister($s1)			#Character Count
	resetRegister($s2)			#Digit Count
	resetRegister($s3)			#Number Count
	resetRegister($s4)			#Parenthesis Count
	resetRegister($s5)			#Operator Count
	 
preVerificationSubFunction:
	while($t0, '\0', while_SpaceCheck)	#While Function for Space Check
	stringCleanUp(userInput, ' ')		#Remove ' ' from Input String
	
	la 	$s0,	userInput		#Check for sign for the First Character
	lb	$t0,	($s0)			#Load First Character
	beq	$t0,	'+',	resultNo	#Exit when the First Character is an Operator
	beq	$t0,	'-',	resultNo	#Exit when the First Character is an Operator
	beq	$t0,	'*',	resultNo	#Exit when the First Character is an Operator
	beq	$t0,	'/',	resultNo	#Exit when the First Character is an Operator
	la	$s0,	userInput		#Load userInput Address
	
verificationSubFunction:
	lb	$t0,	($s0)			#Load Current Character
	beq	$t0,	$zero,	organizationPreparation
	bgt	$t0,	'z',	resultNo	
	addi	$s1,	$s1,	1		#Increase Character Count
	bge	$t0,	'a',	verificationSubFunction_LoadNextInputCharacter
	subi	$s1,	$s1,	1		#Decrease Character Count
	bgt	$t0,	'Z',	resultNo
	addi	$s1,	$s1,	1		#Increase Character Count
	bge	$t0,	'A',	verificationSubFunction_LoadNextInputCharacter
	subi	$s1,	$s1,	1		#Decrease Character Count
	bgt	$t0,	'9',	resultNo
	bge	$t0,	'0',	verificationSubFunction_NumberLengthCheck
	beq	$t0,	'/',	verificationSubFunction_DualOperatorCheck
	beq	$t0,	'-',	verificationSubFunction_DualOperatorCheckSub
	beq	$t0,	'+',	verificationSubFunction_DualOperatorCheckAdd
	beq	$t0,	'*',	verificationSubFunction_DualOperatorCheck
	beq	$t0,	')',	verificationSubFunction_BackParenthesisCheck
	beq	$t0,	'(',	verificationSubFunction_FrontParenthesisCheck
	j	resultNo			#Exit when No Match
	
verificationSubFunction_NumberLengthCheck:
	lb	$t1,	1($s0)			#Load Next Input String Character
	lb	$t2,	2($s0)			#Load Next Next Input String Character
	lb	$t3,	3($s0)			#Load Next Next Next Input String Character
	lb	$t4,	4($s0)			#Load Next Next Next Next Input String Character
	addi	$s3,	$s3,	1		#Increase Number Count
	beq	$s3,	6,	resultNo	#Exit when Entered Sixth Time
	bgt	$t1,	'9',	verificationSubFunction_LoadNextInputCharacter
	blt	$t1,	'0',	verificationSubFunction_LoadNextInputCharacter
	addi	$s0,	$s0,	1		#Advance Input Location
	bgt	$t2,	'9',	verificationSubFunction_LoadNextInputCharacter
	blt	$t2,	'0',	verificationSubFunction_LoadNextInputCharacter
	addi	$s0,	$s0,	1		#Advance Input Location
	bgt	$t3,	'9',	verificationSubFunction_LoadNextInputCharacter
	blt	$t3,	'0',	verificationSubFunction_LoadNextInputCharacter
	addi	$s0	$s0,	1		#Advance Input Location
	bgt	$t4,	'9',	verificationSubFunction_LoadNextInputCharacter
	blt	$t4,	'0',	verificationSubFunction_LoadNextInputCharacter
	j	resultNo			#Exit Due to Number-OverLength
	
verificationSubFunction_DualOperatorCheck:
	addi	$t5,	$t5,	1		#Increase Operator Count
	lb	$t1,	1($s0)			#Load Next Input String Character
	beq	$t1,	'/',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'-',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'+',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'*',	resultNo	#Exit when There are Two Operater Together
	j	verificationSubFunction_LoadNextInputCharacter
	
verificationSubFunction_DualOperatorCheckAdd:
	addi	$t5,	$t5,	1		#Increase Operator Count
	lb	$t1,	1($s0)			#Load Next Input String Character
	beq	$t1,	'/',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'-',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'+',	verificationSubFunction_DualOperatorCheckClear
	beq	$t1,	'*',	resultNo	#Exit when There are Two Operater Together
	j	verificationSubFunction_LoadNextInputCharacter
	
verificationSubFunction_DualOperatorCheckSub:
	addi	$t5,	$t5,	1		#Increase Operator Count
	lb	$t1,	1($s0)			#Load Next Input String Character
	beq	$t1,	'/',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'-',	verificationSubFunction_DualOperatorCheckClear
	beq	$t1,	'+',	resultNo	#Exit when There are Two Operater Together
	beq	$t1,	'*',	resultNo	#Exit when There are Two Operater Together
	j	verificationSubFunction_LoadNextInputCharacter

verificationSubFunction_DualOperatorCheckClear:
	li	$t2,	' '			#Load with Space
	sb	$t2,	1($s0)			#Clear Duplicated Sign
	j	verificationSubFunction

verificationSubFunction_FrontParenthesisCheck:
	addi	$s4,	$s4,	1		#Increase Parenthesis Count
	lb	$t1,	1($s0)			#Load Next Input String Character
	beq	$t1,	'/',	resultNo	#Exit when '(' is Followed by Operator
	beq	$t1,	'-',	resultNo	#Exit when '(' is Followed by Operator
	beq	$t1,	'+',	resultNo	#Exit when '(' is Followed by Operator
	beq	$t1,	'*',	resultNo	#Exit when '(' is Followed by Operator
	beq	$t1,	$zero,	resultNo	#Exit when '(' is Followed by NULL
	j	verificationSubFunction_LoadNextInputCharacter

verificationSubFunction_BackParenthesisCheck:
	subi	$s4,	$s4,	1		#Decrease Parenthesis Count
	lb	$t1,	1($s0)			#Load Next Input String Character
	beq	$t1,	'/',	verificationSubFunction_LoadNextInputCharacter
	beq	$t1,	'-',	verificationSubFunction_LoadNextInputCharacter
	beq	$t1,	'+',	verificationSubFunction_LoadNextInputCharacter
	beq	$t1,	'*',	verificationSubFunction_LoadNextInputCharacter
	beq	$t1,	')',	verificationSubFunction_LoadNextInputCharacter
	beq	$t1,	$zero,	verificationSubFunction_LoadNextInputCharacter
	j	resultNo			#Exit when ')' is Followed by Anything Else
	
verificationSubFunction_LoadNextInputCharacter:
	beq	$s1,	2,	resultNo	#Exit if Dual Letter
	beq	$s5,	5,	resultNo	#Exit if Operator Overload
	addi	$s0,	$s0,	1		#Advance the Input Address
	j	verificationSubFunction


##------Organization Sub Function------##
organizationPreparation:
	bne	$s4,	0,	resultNo	#Exit if '(' & ')' Mismatch
	stringCleanUp(userInput, ' ')		#Remove ' ' from Input String
	stringCopy(userInput, organizedString)	#Copy Cleaned String to New Location	
	
	
	la	$t8,	firstNumberLow		#Set up Comp Register
	li	$t9,	1
	sb	$t9,	($t8)
	ldc1 	$f30,	($t8)
	
organizationSubFunction:
	la	$s0,	organizedString		#Reload Address
	resetRegister($s1)			#Number Counter
	
organizationSubFunction_NumberRecognizationStart:
	lb	$t0,	($s0)
	beq	$t0,	$zero,	organizationSubFunction_NumberRecognizationEnd
	bgt	$t0,	'9',	organizationSubFunction_NumberRecognizationLoadNext
	blt	$t0,	'0',	organizationSubFunction_NumberRecognizationLoadNext
	addi	$s1,	$s1,	1
	beq	$s1,	1,	organizationSubFunction_NumberRecognizationStoreNumber1
	beq	$s1,	2,	organizationSubFunction_NumberRecognizationStoreNumber2
	beq	$s1,	3,	organizationSubFunction_NumberRecognizationStoreNumber3
	beq	$s1,	4,	organizationSubFunction_NumberRecognizationStoreNumber4
	beq	$s1,	5,	organizationSubFunction_NumberRecognizationStoreNumber5
	exitProgram(2)
	
organizationSubFunction_NumberRecognizationStoreNumber1:
	numberRecognization($s0, firstNumberLow, firstNumberHigh, INDEXONE)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber2:
	numberRecognization($s0, secondNumberLow, secondNumberHigh, INDEXTWO)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber3:
	numberRecognization($s0, thirdNumberLow, thirdNumberHigh, INDEXTHREE)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber4:
	numberRecognization($s0, fourthNumberLow, fourthNumberHigh, INDEXFOUR)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber5:
	numberRecognization($s0, fifthNumberLow, fifthNumberHigh, INDEXFIVE)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationLoadNext:
	addi	$s0,	$s0,	1		#Advance Input Address
	j	organizationSubFunction_NumberRecognizationStart
	
organizationSubFunction_NumberRecognizationEnd:
	stringCleanUp(organizedString, ' ')	#Remove ' ' from Input String
	
organizationSubFunction_DuplicateParenthsis:
	la	$s0,	organizedString		#Reload String Location
	
organizationSubFunction_DuplicateParenthsisStart:
	lb	$t0,	($s0)			#Load Current String Character
	beq	$t0,	$zero,	organizationSubFunction_DuplicateParenthsisEnd
	beq	$t0,	'(',	organizationSubFunction_DuplicateParenthsisIdentify
	j	organizationSubFunction_DuplicateParenthsisNext
	
organizationSubFunction_DuplicateParenthsisIdentify:
	lb	$t1,	2($s0)			#Load the Next String Character
	bne	$t1,	')',	organizationSubFunction_DuplicateParenthsisNext
	li	$t2,	' '			#Load Erase Register
	sb	$t2,	($s0)			#Clean Location
	sb	$t2,	2($s0)			#Clean Location
	j	organizationSubFunction_DuplicateParenthsisReset
	
organizationSubFunction_DuplicateParenthsisNext:
	addi	$s0,	$s0,	1		#Advance String Address
	j	organizationSubFunction_DuplicateParenthsisStart
	
organizationSubFunction_DuplicateParenthsisReset:
	stringCleanUp(organizedString, ' ')	#Remove ' ' from Input String
	la	$s0,	organizedString		#Reload String Location
	j	organizationSubFunction_DuplicateParenthsisStart
	
organizationSubFunction_DuplicateParenthsisEnd:
	
##------Calculation Sub Function------##
calculationPreparation:
	la	$s0,	organizedString
	resetRegister($s1)			#Secondary Location
	resetRegister($s2)			#Operation Order Location
	resetRegister($s3)			#Set Operator Counter
	resetRegister($s4)			#Character Count
	
calculationPreparation_CharacterCheck:
	lb	$t0,	($s0)			#Load Current Character
	while($t0, '\0', while_CharacterIdentify)
	bne	$s4,	0,	calculationPreparation_CharacterInput
	j	calculationSubFunction_LoadFloatingPoint
	
calculationPreparation_CharacterInput:
	#characterInput

calculationSubFunction_LoadFloatingPoint:
	readFRegisterValue($f0,	firstNumberLow)	#Store First Number in $f0
	readFRegisterValue($f2,	secondNumberLow)#Store Second Number in $f2
	readFRegisterValue($f4,	thirdNumberLow)	#Store Third Number in $f4
	readFRegisterValue($f6,	fourthNumberLow)#Store Fourth Number in $f6
	readFRegisterValue($f8,	fifthNumberLow)	#Store Fifth Number in $f8
	
calculationSubFunction_Start:
	la	$s0,	organizedString		#Reload Address
	
calculationSubFunction_ParenthesisStart:
	lb	$t0,	($s0)			#Load Current Character
	beq	$t0,	$zero,	calculationSubFunction_ParenthesisEnd
	beq	$t0,	'(',	calculationSubFunction_LookForBackParenthesis
	addi	$s0,	$s0,	1		#Advance Address
	j	calculationSubFunction_ParenthesisStart
	
calculationSubFunction_LookForBackParenthesis:
	addi	$s1,	$s0,	1		#Set Secondary Location

calculationSubFunction_LookForBackParenthesisLoop:
	lb	$t1,	($s1)			#Load Next Character
	beq	$t1,	')',	calculationSubFunction_BackParenthesisFound
	beq	$t1,	$zero,	calculationSubFunction_LookForBackParenthesisError
	addi	$s1,	$s1,	1		#Advance Location
	j	calculationSubFunction_LookForBackParenthesisLoop
	
calculationSubFunction_LookForBackParenthesisError:
	exitProgram(56)
	
calculationSubFunction_BackParenthesisFound:	#Found Most Inner Operation
	operation_MostInner
	organizeOrganizedString
	j	calculationSubFunction_Start
	
calculationSubFunction_ParenthesisEnd:
	stringCleanUp(organizedString, ' ')	#Clean up String
	la	$s0,	organizedString		#Reload Address
	
calculationSubFunction_ParenthesisEndDoubleCheck:
	lb	$t0,	($s0)
	beq	$t0,	$zero,	calculationSubFunction_PlainPreparation
	beq	$t0,	'(',	calculationSubFunction_Start
	addi	$s0,	$s0,	1
	j	calculationSubFunction_ParenthesisEndDoubleCheck
	
calculationSubFunction_PlainPreparation:
	la	$s0,	organizedString		#Reload Address
	
calculationSubFunction_Plain:
	operation_Plain
	stringCleanUp(organizedString, ' ')
	
calculation_Extra_Plain:
	stringCleanUp(organizedString, ')')
	operation_Plain
	stringCleanUp(organizedString, ' ')

##------Print Result------##
printResulttoIO:
	la	$s0,	organizedString		
	lb	$t1,	($s0)
	loadIdentifiertoTempRegisterF($t1, $f12)
	printString(resultString)
	li	$v0,	3
	syscall
	
	j exitFunction






