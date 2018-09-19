.data 0x10010000
	firstPromptString:	.asciiz 	">>> "
	invalidString:		.asciiz 	"Invalid Input \n"
	validString:		.asciiz		"Valid Input \n"
	newLine:		.asciiz		"\n"
	deividerString:		.asciiz 	"--------------------"
	matchString:		.asciiz		"1234567890()+-*/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz \n"

.data 0x10010100
	userInput:		.space		63
	
.text 	

##!!!Read This!!!
##There are way too many combinations that consists only A-Z, a-z, 0-9, +-*/= will return error in MATLAB
##In this, we are only looking at some simple examples that assuming the error is coming from "mis-type", to some extent.
##By that, I mean, you DON'T randomly type in any random string on purpose.

main:	
	#Prompt To Input
	la 	$a0,	firstPromptString	#Prompt the first string 
	li	$v0,	4			#4 is the System Call for Printing
	syscall 
	
	#Input Reading
	la	$a0,	userInput		#Load Input Address
	li	$a1,	61			#Assign Input Length
	li	$v0,	8			#8 is the System Call for reading string
	syscall
	
	#Initialize String Location
	la	$s2,	userInput		#Load Input Address
	move	$t2,	$s2			#Save Address to t2
	la	$s3,	matchString		#Load Match Address
	move	$t3,	$s3			#Save Match Address
	move	$t4,	$s3			#Store Initial Location
	li	$t5,	70			#Number of total Character
	
	li 	$t6,	0			#Clean up Memory
	li	$t7,	0			#Clean up Memory
	li	$s4,	0			#Clean up Memory
	
	j	findMatch			#Intilize Match Sequence
	
resultNo:
	la	$a0,	invalidString		#Print invalid Result
	li	$v0,	4			#4 is the System Call for Printing
	syscall
	j	Exit
	
resultYes:
	bne	$t7,	$t6,	resultNo	#Mismatch in '(' & ')'
	la	$a0,	validString		#Print Valid Result
	li	$v0,	4			#4 is the System Call for Printing
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
	lb	$t2,	($s2)			#Load User Input
	lb	$t3,	($s3)			#Load Match Location

	beq	$t2,	$zero,	resultYes	#Exit Loop when Input reaches 0
	beq	$t3,	$zero,	resultNo	#Exit Loop when Match reaches 0
	
	bne 	$t2,	$t3,	nextComparison
	beq	$t2,	$t3,	twoSameOperators
	
nextComparison:
	addi	$s3,	$s3,	1		#Increase the Match Location Count Only
	sub	$t5,	$t5,	1		#Decrease number count
	j	findMatch
	
twoSameOperators:
	addi	$s1,	$s2,	1		#Load Next Location
	lb	$t1,	($s1)			#Load Next Character
	bne	$t1,	$t2,	multiEqualSign	#Check Similarity of Adjacent Character
	beq	$t2,	'+',	resultNo	#Exit loop if ++ occures
	beq	$t2,	'-',	resultNo	#Exit loop if -- occures
	beq	$t2,	'*',	resultNo	#Exit loop if ** occures
	beq	$t2,	'/',	resultNo	#Exit loop if // occures
	
multiEqualSign:					#Find and Count the Number of Equal Sign
	bne	$t2,	'=',	frontParenthesis
	addi	$s4,	$s4,	1
	beq	$s4,	2,	resultNo	#Exit Loop when there is more than one =
	
frontParenthesis:				#Find and Mark Apparence of (
	bne	$t2,	'(',	backParenthesis
	addi	$t6,	$t6,	1		#Add ( Count
	
backParenthesis:
	bne	$t2,	')',	restartLoop	#Find and Mark Apparence of )
	addi	$t7,	$t7,	1		#Add ) Count
	addi	$s1,	$s2,	1
	lb	$t1,	($s1)
	beq	$t1,	'+',	restartLoop	#Check if ) is Followed by operators
	beq	$t1,	'-',	restartLoop
	beq	$t1,	'*',	restartLoop
	beq	$t1,	'/',	restartLoop
	beq	$t1,	'\n',	restartLoop
	j	resultNo

#Loop Back to Restart
restartLoop:
	addi	$s2,	$s2,	1		#Increase the Input Location Count Only
	li	$t5,	70			#Reset number Count
	move	$s3,	$t4			#Reset Location
	j	findMatch
	

	

	
