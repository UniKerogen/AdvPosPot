#
#	mips_A2_Macro_S.asm
#	MIPS Assignment 2
#
#
#	Created by Kerogen on 10/9/18.
#	copyright ©	Kerogen.	All rights reserved.
 


##------Data Storage------##
#Allocate Different Area of the Data Segment with Labels for Preparation
.data 0x10010000
	firstPromptString:	.asciiz 	">>> "
	invalidString:		.asciiz 	"Invalid Expression "
	newLine:		.asciiz		"\n"
	exitLine:		.asciiz		"Exit "
	locationLine:		.asciiz		"Here "
	deividerString:		.asciiz 	"--------------------"
	resultString:		.asciiz		"Result: "
	promptCharacterValue:	.asciiz		"Enter Value for Character >> "
	
.data 0x10010080
	userInput:		.space		64
	
.data 0x100100c0
	organizedString:	.space		64
	
#Allocate Number Storage Area
.data 0x10010100
	firstNumberLow:		.space		4
	firstNumberHigh:	.space		4
	secondNumberLow:	.space		4
	secondNumberHigh:	.space		4
	thirdNumberLow:		.space		4
	thirdNumberHigh:	.space		4
	fourthNumberLow:	.space		4
	fourthNumberHigh:	.space		4
	fifthNumberLow:		.space		4
	fifthNumberHigh:	.space		4
	resultNumberLow:	.space		4
	resultNumberHigh:	.space		4
	resultCharacterLow:	.space		4
	resultCharacterHigh:	.space		4
	characterValueLow:	.space		4
	characterValueHigh:	.space		4






##------Pre Set Value------##
#Index of Identifier
.eqv	INDEXONE	224
.eqv	INDEXTWO	225
.eqv	INDEXTHREE	226
.eqv	INDEXFOUR	227
.eqv	INDEXFIVE	228






##------General Macro Implementation------##

#--Reset Register Function--#
#Input: A Register
#Result: Set it to 0
.macro	resetRegister(%registerNumber)
	li	%registerNumber,	0
.end_macro 

#--Print String Function--#
#Input: String Address
#Result: Print out the deisred string in I/O Window
.macro printString (%stringLocation)
	la 	$a0,	%stringLocation		#Prompt the first string 
	li	$v0,	4			#System Call for Printing
	syscall
.end_macro 


#--Exit Program Function--#
#Used to exit function during debug when expected
#Input: A Value
#Result: Print out "Exit " + Value in I/O Window and Exit the program
.macro	exitProgram (%value)
	la	$a0,	invalidString	
	li	$v0,	4	
	syscall
	li	$a0,	%value		
	li	$v0,	1	
	syscall
	li	$v0,	10	
	syscall
.end_macro 


#-Print Here Function-#
#Used to keep track of the progress of function
#Input:	A Value
#Result: Print out "Here" + Value in I/O Window
.macro	printHere (%value)
	la	$a0,	locationLine
	li	$v0,	4
	syscall
	li	$a0,	%value
	li	$v0,	1
	syscall
	la	$a0,	newLine			
	li	$v0,	4			
	syscall
.end_macro 

#-For Function-#
#Used to establish a for loop
.macro	for (%regIterator, %from, %to, %for_code)
	add	%regIterator,	$zero,		%from
	forLoop:
	%for_code ()
	add	%regIterator,	%regIterator,	1
	ble	%regIterator,	%to,		forLoop
.end_macro 

#-If Function-#
#Used for IF condition
.macro if (%regIterator, %value, %if_code)
	bne	%regIterator,	%value,		ifEnd
	%if_code ()
	ifEnd:
.end_macro 

#-If Compare Function-#
#Used to compare if a vlaue is in between of two value
.macro ifCompare(%valueLowerBound, %value, %valueUpperBound, %if_compareCode)
	blt	%value,	%valueLowerBound,	ifCompareEnd
	bgt 	%value,	%valueUpperBound,	ifCompareEnd
	%if_compareCode ()
	ifCompareEnd:
.end_macro 

#-While Function-#
#Used for While condition
.macro while (%regIterator, %to, %while_code)
	whileLoop:
	%while_code ()
	bne	%regIterator,	%to,	whileLoop
.end_macro 

#-Store Register Value Function-#
#Used for storing register value to address
#Input: A Register; Address 1; Address 2
.macro storeRegisterValue (%regIterator, %addressLow, %addressHigh)
	la	$t8,	%addressHigh
	la	$t9,	%addressLow
	swl	%regIterator,	($t8)
	swr	%regIterator,	($t9)
.end_macro 

#-Store Floating Register Function-#
#Used for storing floating register to address
#Input: A Floating-Register; Address 1
.macro storeFRegisterValue (%regIterator, %addressHigh)
	la	$t8,	%addressHigh
	sdc1  	%regIterator,	($t8)
.end_macro 

#-Read Floating Register Value Function-#
#Used for reading a value from address to floating register
#Input: A Floating Register; Address 1
.macro readFRegisterValue (%regIterator, %addressHigh)
	la	$t8,	%addressHigh
	ldc1 	%regIterator,	($t8)
	div.d	%regIterator, %regIterator, $f30
.end_macro 

#-Read Register Value Function-#
#Used to read value from register to address
#Input: A Register; Address 1
.macro readRegisterValue (%register, %address)
	la	$t8,	%address
	lw	%register,	($t8)
.end_macro 

#-String Clean Up Function-#
#Used to erase specific character of a string
#Input: Address 1; Erase Character
.macro stringCleanUp (%initialAddress, %cleanUpValue)
	la	$t9,	%initialAddress
	stringCleanUpStart:
	lb	$t8,	($t9)
	beq	$t8,	$zero,	stringCleanUpFinal
	bne	$t8,	%cleanUpValue,	stringCleanUpNext
	stringCleanUpShift:
	lb	$t8,	1($t9)
	sb	$t8,	($t9)
	addi	$t9,	$t9,	1
	bne	$t8,	$zero,	stringCleanUpShift
	la	$t9,	%initialAddress
	j	stringCleanUpStart
	stringCleanUpNext:
	addi	$t9,	$t9,	1
	j	stringCleanUpStart
	stringCleanUpFinal:
.end_macro 

#-String Copy Function-#
#Used for copying function to a differnt address
#Input: Address 1; Address 2
.macro stringCopy (%initialAddress, %destinationAddress)
	la	$t9,	%initialAddress
	la	$t7,	%destinationAddress
	stringCopyStart:
	lb	$t8,	($t9)
	beq	$t8,	$zero,	stringCopyEnd
	sb	$t8,	($t7)
	addi	$t9,	$t9,	1
	addi	$t7,	$t7,	1
	j	stringCopyStart
	stringCopyEnd:
.end_macro

#-Number Recognization Function-#
#Used to recognized numbers in the string and save to address
#Input: Address 1; Address 2; Address 3; Number Identifier
.macro numberRecognization (%initialAddressRegister, %saveAddressLow, %saveAddressHigh, %numberIndex)
	move	$t7,	%initialAddressRegister
	li	$t6,	%numberIndex
	lb	$t8,	($t7)
	sub	$t8,	$t8,	'0'
	sb	$t6,	($t7)
	li	$t6,	' '
	numberRecognizationStart:
	lb	$t9,	1($t7)
	blt	$t9,	'0',	numberRecognizationEnd
	bgt	$t9,	'9',	numberRecognizationEnd
	mul	$t8,	$t8,	10
	sub	$t9,	$t9,	'0'
	add	$t8,	$t8,	$t9
	sb	$t6,	1($t7)
	addi	$t7,	$t7,	1
	j	numberRecognizationStart
	numberRecognizationEnd:
	move 	$s7,	$t8
	storeRegisterValue($s7,	%saveAddressLow, %saveAddressHigh)
.end_macro 

#-Operation Addition & Substraction-#
#Used to perform addition and substraction
#Input: Register 1; Register 2; Register 3; Address
.macro operationAddSub (%resultFRegister, %numberLeftF, %numberRightF, %operatorAddress)
	move	$t8,	%operatorAddress
	lb	$t9,	($t8)
	beq	$t9,	'+',	operationAddition
	beq	$t9,	'-',	operationSubstraction
	j	operationAddSubEnd
	operationAddition:
	add.d  	%resultFRegister,%numberLeftF,	%numberRightF
	j	operationAddSubEnd
	operationSubstraction:
	sub.d  	%resultFRegister,%numberLeftF,	%numberRightF
	operationAddSubEnd:
.end_macro

#-Operation Mulitplication & Division-#
#Used to perform multiplication and division opeation
#Input: Register 1; Register 2; Register 3; Address

## This is not working. Probably a good idea to load everything back to regular register and compute then load back to floating
## It could also be related to the number is not loaded correctly

.macro operationMulDiv (%resultFRegister, %numberLeftF, %numberRightF, %operatorAddress)
	move	$t8,	%operatorAddress
	lb	$t9,	($t8)
	beq	$t9,	'*',	operationMultiply
	beq	$t9,	'/',	operationDivision
	j	operationMulDivEnd
	operationMultiply:
	mul.d	%resultFRegister,%numberLeftF,	%numberRightF
	j	operationMulDivEnd
	operationDivision:
	div.d	%resultFRegister,%numberLeftF,	%numberRightF
	operationMulDivEnd:
.end_macro 

#-Operation Load Floating Register with Identifier-#
#Used to load Floadting Point Register indetified by Identifier
#Input: Identifier; Floating Register;
.macro	loadIdentifiertoTempRegisterF(%identifier, %tempFRegister)
	subiu	%identifier,	%identifier,	4294967040
	beq	%identifier,	INDEXONE,	loadIdentifiertoTempRegisterF_Load1
	beq	%identifier,	INDEXTWO,	loadIdentifiertoTempRegisterF_Load2
	beq	%identifier,	INDEXTHREE,	loadIdentifiertoTempRegisterF_Load3
	beq	%identifier,	INDEXFOUR,	loadIdentifiertoTempRegisterF_Load4
	beq	%identifier,	INDEXFIVE,	loadIdentifiertoTempRegisterF_Load5
	exitProgram(5)
	loadIdentifiertoTempRegisterF_Load1:
	mov.d	%tempFRegister,	$f0
	j	loadIdentifiertoTempRegisterF_End
	loadIdentifiertoTempRegisterF_Load2:
	mov.d	%tempFRegister,	$f2
	j	loadIdentifiertoTempRegisterF_End	
	loadIdentifiertoTempRegisterF_Load3:
	mov.d	%tempFRegister,	$f4
	j	loadIdentifiertoTempRegisterF_End
	loadIdentifiertoTempRegisterF_Load4:
	mov.d	%tempFRegister,	$f6
	j	loadIdentifiertoTempRegisterF_End
	loadIdentifiertoTempRegisterF_Load5:
	mov.d	%tempFRegister,	$f8
	j	loadIdentifiertoTempRegisterF_End
	loadIdentifiertoTempRegisterF_End:
.end_macro 

#-Save Indentifier Function-#
#Used when a Identifier needs to be replaced
#Input: Identifier; Floating Register
.macro	saveIndentifiertoStorage(%identifier, %tempFRegister)
	beq	%identifier,	INDEXONE,	saveIndentifiertoStorage_Save1
	beq	%identifier,	INDEXTWO,	saveIndentifiertoStorage_Save2
	beq	%identifier,	INDEXTHREE,	saveIndentifiertoStorage_Save3
	beq	%identifier,	INDEXFOUR,	saveIndentifiertoStorage_Save4
	beq	%identifier,	INDEXFIVE,	saveIndentifiertoStorage_Save5
	exitProgram(6)
	saveIndentifiertoStorage_Save1:
	mov.d	$f0,	%tempFRegister
	j	saveIndentifiertoStorage_End
	saveIndentifiertoStorage_Save2:
	mov.d	$f2,	%tempFRegister
	j	saveIndentifiertoStorage_End
	saveIndentifiertoStorage_Save3:
	mov.d	$f4,	%tempFRegister
	j	saveIndentifiertoStorage_End
	saveIndentifiertoStorage_Save4:
	mov.d	$f6,	%tempFRegister
	j	saveIndentifiertoStorage_End
	saveIndentifiertoStorage_Save5:
	mov.d	$f8,	%tempFRegister
	j	saveIndentifiertoStorage_End
	saveIndentifiertoStorage_End:
.end_macro 

##-Reset Memory Loop-##
#Used to reset blocks after execution
.macro resetMemory(%dataAddress)
	la 	$s0, 	%dataAddress
	li	$t0,	64
	resetMemoryLoop:
	sb	$zero, 	($s0)
	subi	$t0,	$t0,	1
	beq	$t0,	0,	resetMemoryEnd
	addi	$s0,	$s0,	1
	j	resetMemoryLoop
	resetMemoryEnd:
.end_macro 





##------Specific Macro Definition------##
##------Burn Function------##
##------AKA Single Use Function------##

#-If SpaceCheck Sub IF Function-#
#Used as a label for IF Function
.macro if_SpaceCheck
	lb	$t1,	1($s0)	
	lb	$t2,	-1($s0)	
	bge	$t1,	'0',	SpaceCheckSecond
	j	SpaceCheckSecondNo
	SpaceCheckSecond:
	bge	$t2,	'0',	resultNo
	SpaceCheckSecondNo:
.end_macro 

#-While SpaceCheck Sub While Function-#
#Used as a label for While Function
.macro while_SpaceCheck
	lb	$t0,	($s0)
	if($t0, ' ', if_SpaceCheck)
	addi	$s0,	$s0,	1
.end_macro 


.macro ifCompare_NumberRecognization
	#Do Nothing
.end_macro 

#-IfCompare CharacterIdentify Sub If Function-#
#Used as a label for IfCompare Function
.macro	ifCompare_CharacterIdentify
	addi	$s4,	$s4,	1		#Increase Character Count
.end_macro 

#-While Character Identify Sub While Function-#
#Used as a label for While Function
.macro	while_CharacterIdentify
	lb	$t0,	($s0)
	ifCompare('@', $t0, '[', ifCompare_CharacterIdentify)
	ifCompare('`', $t0, '{', ifCompare_CharacterIdentify)
	addi	$s0,	$s0,	1
.end_macro 

#-IfCompare Character Replace Sub If Function-#
#Used as a label for IfCompare Function
.macro	ifCompare_CharacterReplace
	li	$t9,	INDEXFIVE
	sb	$t9,	($s0)
.end_macro 

#-While Character Replace Sub While Function-#
#Used as a label for While Function
.macro	while_CharacterReplace
	lb	$t0,	($s0)
	ifCompare('@', $t0, '[', ifCompare_CharacterReplace)
	ifCompare('`', $t0, '{', ifCompare_CharacterReplace)
	addi	$s0,	$s0,	1
.end_macro 

#-Operation Most Inner Function-#
#Used for calculating function of the most inner ()
.macro operation_MostInner
	addi	$s7,	$s0,	1		#Advance Location
	li	$s6,	' '			#Load Erase Character	
	operation_MostInnerStartFind1:
	lb	$t7,	($s7)			#Load Nex Character
	beq	$t7,	')', 	operation_MostInnerStartFind1End
	beq	$t7,	'*',	operation_MostInnerOperateMulDiv
	beq	$t7,	'/',	operation_MostInnerOperateMulDiv
	addi	$s7,	$s7,	1		#Advance Location
	j	operation_MostInnerStartFind1
	operation_MostInnerStartFind1End:
	addi	$s7,	$s0,	1		#Reset Match Location
	operation_MostInnerStartFind2:
	lb	$t7,	($s7)
	beq	$t7,	')',	operation_MostInnerErrorErase
	beq	$t7,	'+',	operation_MostInnerOperateAddSub
	beq	$t7,	'-',	operation_MostInnerOperateAddSub
	addi	$s7,	$s7,	1		#Advance Location
	j	operation_MostInnerStartFind2
	operation_MostInnerOperateAddSub:
	lb	$t5,	-1($s7)			#Load Identifier for Front Number
	lb	$t6,	1($s7)			#Load Identifier for Back Number
	loadIdentifiertoTempRegisterF($t5, $f10)
	loadIdentifiertoTempRegisterF($t6, $f12)
	operationAddSub($f10, $f10, $f12, $s7)
	j	operation_MostInnerAssignNewIdentifier
	operation_MostInnerOperateMulDiv:
	lb	$t5,	-1($s7)			#Load Identifier for Front Number
	lb	$t6,	1($s7)			#Load Identifier for Back Number
	loadIdentifiertoTempRegisterF($t5, $f10)
	loadIdentifiertoTempRegisterF($t6, $f12)
	operationMulDiv($f10, $f10, $f12, $s7)
	j	operation_MostInnerAssignNewIdentifier
	operation_MostInnerAssignNewIdentifier:
	saveIndentifiertoStorage($t5, $f10)
	operation_MostInnerErase:
	sb	$s6,	($s7)			#Erase Operator
	sb	$s6,	1($s7)			#Erase Identifier for Back Number
	operation_MostInnerDuplicatedParenthesis:
	lb	$t7,	4($s0)
	bne	$t7,	')',	operation_MostInnerCleanup
	sb	$s6,	($s0)			#Erase Leftover Parenthesis
	sb	$s6,	4($s0)			#Erase Leftover Parenthesis
	operation_MostInnerCleanup:
	stringCleanUp(organizedString, ' ')	#Clean Up Empty Space
	j	operation_MostInnerExit
	operation_MostInnerErrorErase:
	sb	$s6,	($s0)
	sb	$s6,	2($s0)
	j	operation_MostInnerCleanup
	exitProgram(53)
	operation_MostInnerExit:
	la	$s0,	organizedString
.end_macro 

#-Operation Plain Function-#
#Used for calculate operation without ()
.macro operation_Plain
	#stringCleanUp(organizedString, ')')
	#stringCleanUp(organizedString, '(')
	addi	$s7,	$s0,	1		#Advance Location
	li	$s6,	' '			#Load Erase Character
	operation_PlainStartFind1:
	lb	$t7,	($s7)			#Load Nex Character
	beq	$t7,	$zero, 	operation_PlainStartFind1End
	beq	$t7,	'*',	operation_PlainOperateMulDiv
	beq	$t7,	'/',	operation_PlainOperateMulDiv
	addi	$s7,	$s7,	1		#Advance Location
	j	operation_PlainStartFind1
	operation_PlainStartFind1End:
	addi	$s7,	$s0,	1		#Reset Match Location
	operation_PlainStartFind2:
	lb	$t7,	($s7)
	beq	$t7,	$zero,	operation_PlainExit
	beq	$t7,	'+',	operation_PlainOperateAddSub
	beq	$t7,	'-',	operation_PlainOperateAddSub
	addi	$s7,	$s7,	1		#Advance Location
	j	operation_PlainStartFind2
	operation_PlainOperateAddSub:
	lb	$t5,	-1($s7)			#Load Identifier for Front Number
	lb	$t6,	1($s7)			#Load Identifier for Back Number
	
	loadIdentifiertoTempRegisterF($t5, $f10)
	loadIdentifiertoTempRegisterF($t6, $f12)
	operationAddSub($f10, $f10, $f12, $s7)
	
	j	operation_PlainAssignNewIdentifier
	
	
	operation_PlainOperateMulDiv:
	lb	$t5,	-1($s7)			#Load Identifier for Front Number
	lb	$t6,	1($s7)			#Load Identifier for Back Number
	
	
	loadIdentifiertoTempRegisterF($t5, $f10)
	loadIdentifiertoTempRegisterF($t6, $f12)
	operationMulDiv($f10, $f10, $f12, $s7)
	
	
	j	operation_PlainAssignNewIdentifier
	
	
	operation_PlainAssignNewIdentifier:
	saveIndentifiertoStorage($t5, $f10)
	operation_PlainErase:
	sb	$s6,	($s7)			#Erase Operator
	sb	$s6,	1($s7)			#Erase Identifier for Back Number
	
	
	operation_PlainCleanup:
	stringCleanUp(organizedString, ' ')	#Clean Up Empty Space
	j	operation_PlainExit
	operation_PlainError:
	exitProgram(55)
	operation_PlainExit:
.end_macro 

#-Characer Input Function-#
#Used for prompting input and replace Character in the existing string
.macro	characterInput
	la	$a0,	promptCharacterValue
	li	$v0,	4
	syscall
	li	$v0,	5
	syscall
	move	$s5,	$v0
	
	storeRegisterValue($s5,	characterValueLow, characterValueHigh)
	storeFRegisterValue($f8, characterValueLow)
	
	la	$s0,	organizedString
	while($t0, '\0', while_CharacterReplace)
.end_macro 


.macro organizeOrganizedString
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
	#numberRecognization($s0, firstNumberLow, firstNumberHigh, INDEXONE)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber2:
	#numberRecognization($s0, secondNumberLow, secondNumberHigh, INDEXTWO)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber3:
	#numberRecognization($s0, thirdNumberLow, thirdNumberHigh, INDEXTHREE)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber4:
	#numberRecognization($s0, fourthNumberLow, fourthNumberHigh, INDEXFOUR)
	j	organizationSubFunction_NumberRecognizationLoadNext
	
organizationSubFunction_NumberRecognizationStoreNumber5:
	#numberRecognization($s0, fifthNumberLow, fifthNumberHigh, INDEXFIVE)
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

.end_macro 

	






