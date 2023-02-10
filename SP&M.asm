TITLE String Primitives & Macros

; Author: Behrad Noorani
; Last Modified: 6.5.2022

INCLUDE Irvine32.inc

;macros
; --------------------------------------------------------------------------------- 
; Name: mGetString 
; Gets the users input as a string
; Preconditions: addresses are defined 
; Receives: 
; prompt = address for prompt to be displayed
; string = user input addresss
; max_length = max length of input
; length = address for input lenght
; returns: length =  input lenght, string = user input string
; --------------------------------------------------------------------------------- 
mGetString	MACRO	 prompt, string, max_length, length
; ...
	PUSH	ecx
	PUSH	edx
	PUSH	eax
	MOV		edx, prompt
	CALL	WriteString
	MOV		edx, string
	MOV		ecx, max_length
	CALL	ReadString
	MOV		length, eax
	POP		eax
	POP		edx
	POP		ecx
ENDM
; --------------------------------------------------------------------------------- 
; Name: mDisplayString 
; Dispalys the string passed on 
; Preconditions: addresses are defined 
; Receives: 
; string = address for string to be displayed
; --------------------------------------------------------------------------------- 
mDisplayString	MACRO	string
; ...
	PUSH	edx
	MOV		edx, string
	CALL	WriteString
	POP		edx
ENDM

.data
;constants 
ARRAYSIZE = 10
MAXNUMSIZE = 12


;variables 
introStr	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0
introStr2	BYTE	"Written by: Behrad Noorani",0
askNum		BYTE	"Please provide 10 signed decimal integers. This program does not handle overflow.",0
askNum2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting ",0
askNum3		BYTE	"the raw numbers I will display a list of the integers, their sum, and their average value.",0
enterNum	BYTE	"Please enter an signed number: ",0
errorNum	BYTE	"ERROR: You did not enter a signed number.",0
againNum	BYTE	"Please try again: ",0
resultStr	BYTE	"You entered the following numbers: ",0
sumStr		BYTE	"The sum of these numbers is: ",0
avgStr		BYTE	"The truncated average is: ",0
farewellStr	BYTE	"Thanks for playing!",0
spacer		BYTE	"  ",0

numArray	SDWORD	ARRAYSIZE DUP(0)		;array of numbers
inputStr	BYTE	MAXNUMSIZE DUP(?)		;user input
inputStrLen	DWORD	?						;user input len
outputStr	BYTE	MAXNUMSIZE DUP(?)		;string to be shown
sum			SDWORD	0						;sum of nums 
numCounter	DWORD	0						;counter for array filling loop
negFlag		DWORD	0						;value to track negative numbers in array filling loop 



.code
main PROC
	PUSH	OFFSET	introStr		;24
	PUSH	OFFSET	introStr2		;20
	PUSH	OFFSET	askNum			;16
	PUSH	OFFSET	askNum2			;12
	PUSH	OFFSET	askNum3			;8
	CALL	introduction
	MOV		ecx, ARRAYSIZE			;sets up array filling loop counter
_varLoop:
;;loop for # of numbers needed
	PUSH	OFFSET	againNum		;36
	PUSH	numCounter				;32
	PUSH	OFFSET	numArray		;28
	PUSH	OFFSET	negFlag			;24
	PUSH	OFFSET	errorNum		;20
	PUSH	OFFSET	enterNum		;16
	PUSH	OFFSET	inputStr		;12
	PUSH	OFFSET	inputStrLen		;8
	CALL	readVal			
	ADD		numCounter, 4			;for array slot 
	LOOP	_varLoop				;loop for # of numbers needed
	CALL	Crlf
	PUSH	OFFSET	resultStr		;20
	PUSH	OFFSET	spacer			;16
	PUSH	OFFSET	outputStr		;12
	PUSH	OFFSET	numArray		;8
	CALL	printArray
	CALL	Crlf
	CALL	Crlf
	PUSH	OFFSET	sumStr			;20
	PUSH	OFFSET	sum				;16
	PUSH	OFFSET	outputStr		;12
	PUSH	OFFSET	numArray		;8
	CALL	calcSum
	CALL	Crlf
	CALL	Crlf
	PUSH	OFFSET	avgStr			;16
	PUSH	sum						;12
	PUSH	OFFSET	outputStr		;8
	CALL	calcAvg
	CALL	Crlf
	PUSH	OFFSET	farewellStr
	CALL	farewell	
	Invoke ExitProcess,0	;exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
; Outputs the name of the program and the author and prompts the user to 
; enter signed numbers
; Receives: Addresses of introStr1-2, askNum1-3
; ---------------------------------------------------------------------------------
introduction	PROC
	PUSH	ebp
	MOV		ebp, esp
	mDisplayString [ebp + 24]	;introStr
	CALL	Crlf
	mDisplayString [ebp + 20]	;introStr2
	CALL	Crlf
	CALL	Crlf
	mDisplayString [ebp + 16]	;askNum3
	CALL	Crlf
	mDisplayString [ebp + 12]	;askNum2
	CALL	Crlf
	mDisplayString [ebp + 8]	;askNum
	CALL	Crlf
	CALL	Crlf
	POP		EBP
	RET		20
introduction	ENDP
; ---------------------------------------------------------------------------------
; Name: readVal
; Uses the mGetString macro to read a user input string and converts it to a
; SDWORD number and stores it into the array in the appropiate place 
; Receives: Address of againNum, numArray, negFlag, errorNum, enterNum, inputStr,
;			inputStrLen and ARRAYSIZE, MAXNUMSIZE and numCounter
; Preconditions: ARRAYSIZE, MAXNUMSIZE, numCounter and numArray must be defined
; ---------------------------------------------------------------------------------	
readVal	PROC
	PUSH	ebp
	MOV		ebp, esp
	PUSH	ecx					;preserve readval loop counter
_prompterGetter:				
;prompts user and gets string
	mGetString [ebp + 16], [ebp + 12], MAXNUMSIZE , [ebp + 8]
	MOV		esi, [ebp + 12]		;string into esi
	MOV		ecx, [ebp + 8]		;string len to ecx to loop
	CMP		ecx, 0				;if string is blank
	JE		_emptyError
	MOV		edi, [ebp + 28]		;edi to array
	MOV		ebx, [ebp + 32]		;counter for array slot
	ADD		edi, ebx			;move array slot being filled to the appropiate spot
	PUSH	eax					;reset negative flag
	MOV		eax, 0
	MOV		[ebp + 24], eax		;reset negative flag
	POP		eax
	CLD
	JMP		_checkSign
_prompterGetterAgain:			
;in case of error prompts user and gets string
	mGetString [ebp + 36], [ebp + 12], MAXNUMSIZE , [ebp + 8]
	MOV		esi, [ebp + 12]
	MOV		ecx, [ebp + 8]
	CMP		ecx, 0
	JE		_emptyError
	MOV		edi, [ebp + 28]
	MOV		ebx, [ebp + 32]
	ADD		edi, ebx
	PUSH	eax
	MOV		eax, 0
	MOV		[ebp + 24], eax
	POP		eax
	CLD
_checkSign:						
;checks signs
	LODSB
	CMP		al, 45
	JE		_negCase			;if 1st string is a -
	CMP		al, 43
	JE		_posCase			;if 1st string is a +
	JMP		_validate
_negCase:
;if 1st string is a -
	PUSH	eax					
	MOV		eax, 1
	MOV		[ebp + 24], eax		;set neg flag to 1
	POP		eax
	DEC		ecx					;dec 1 for loop since 1 digit was a sign
	JMP		_restNum
_posCase:
;if 1st string is a +
	DEC		ecx					;dec 1 for loop since 1 digit was a sign
	JMP		_restNum
_restNum:
;loads the next val
	CLD
	LODSB						;next in esi loaded into al
	JMP		_validate
_validate:
;validates the value in al to be a num
	CMP		al, 48				;0 in ascii
	JL		_errorCase
	CMP		al, 57				;9 in ascii
	JG		_errorCase
_numAcc:
;accumulates number
	MOV		ebx, [edi]			;put current val into ebx
	PUSH	eax					
	PUSH	ebx
	MOV		eax, ebx			;put current val into eax
	MOV		ebx, 10				
	MUL		ebx					;mul current val by 10
	;JO		_errorCase			doesn't work
	MOV		[edi], eax			;mov mul'd val into current val
	POP		ebx
	POP		eax
	SUB		al, 48				;make ascii into num
	ADD		[edi], al			;add num to current val
	;JO		_errorCase			doesn't work
	LOOP	_restNum			;loop until ecx = strlen is 0
	JMP		_endCase
_emptyError:
;error in case user enters nothing
	mDisplayString	[ebp + 20]	;invalid entry errorStr
	CALL	Crlf
	JMP		_prompterGetterAgain	
_errorCase:
;error in case user enters invalid stuff
	mDisplayString	[ebp + 20]	;invalid entry errorStr
	MOV		ebx, 0
	MOV		[edi], ebx			;resets array slot 
	CALL	Crlf
	JMP		_prompterGetterAgain
_negativer:
;makes the current number in array negative if neg flag is 1 
	MOV		ecx, [edi]
	NEG		ecx
	JO		_errorCase
	MOV		[edi], ecx
	JMP		_ender
_endCase:
;at the end of the string, checks if neg flag is set and takes appropiate jmp 
	PUSH	ebx
	MOV		ebx, [ebp + 24]			;checks neg flag
	CMP		ebx, 1
	POP		ebx
	JE		_negativer
_ender:
;proc ret
	POP		ecx
	POP		ebp
	RET		32
readVal ENDP
; ---------------------------------------------------------------------------------
; Name: printArray
; Prints out the array previously generated
; Has a loop that calls writeVal to write each number passed on from the array
; Receives: Address of outputStr, numArray, spacer, resultStr
; Preconditions: numArray must have numbers, ARRAYSIZE must be defined
; ---------------------------------------------------------------------------------	
printArray PROC
	PUSH	ebp
	MOV		ebp, esp
	mDisplayString	[ebp + 20]	;resultStr
	CALL	Crlf
	MOV		esi, [ebp + 8]		;array
	MOV		ecx, ARRAYSIZE		;set up looper
	MOV		edi, [ebp + 12]
_printLoop:
;loop to print each num in array
	PUSH	edi					;output string 
	PUSH	[ESI]				;current num being passed
	CALL	writeVal
	mDisplayString [ebp + 16]	;space between each number diplayed
	ADD		esi, 4				;next num
	LOOP	_printLoop
	POP		ebp
	RET		16
printArray ENDP
; ---------------------------------------------------------------------------------
; Name: writeVal
; displays each number in the array as a string by converting each digit into ascii 
; Receives: number being converted [ebp + 8], outputstring [ebp + 12]
; Preconditions: passed number, outputstring
; ---------------------------------------------------------------------------------	
writeVal PROC
	PUSH	ebp
	MOV		ebp, esp
	PUSH	ecx					;preserve loop
	PUSH	edi
	MOV		edi, [ebp + 12]		;outputStr
	MOV		eax, [ebp + 8]		;puts the number into eax
_signCheck:
;check if the num passed is negative
	CMP		eax, 0				;checks if the value in eax is negative 
	JL		_negaCase
	JMP		_noSign
	CLD
_negaCase:
;if num is negative stores - 
	PUSH	eax
	MOV		al, 45
	STOSB						;stores - into outstring
	POP		eax				
	NEG		eax
_noSign:
;pushes 0 for the stop sign 
	PUSH	0					;stop sign for _store loop
_toString:
;converts each digit of num to ascii and pushes to stack 
	MOV		edx, 0				;prep for div
	MOV		ebx, 10				
	DIV		ebx					;divide num by 10		
	ADD		edx, 48				;add ascii 0 to remainder to convert it to ascii
	PUSH	edx					;push ascii num to stack
	CMP		eax, 0				;continues until the qutient is 0
	JE		_store
	JMP		_toString
_store:
;stores each ascii string pushed in _tostring to the output string
	POP		eax					;puts num in al
	STOSB						;stores num into outputstr
	CMP		eax, 0				;stops when encountering previously pushed "0"
	JE		_endstr
	JMP		_store
_endstr:
	mDisplayString	[ebp + 12]	;displays outputstr
	POP		edi
	POP		ecx					;loop restored
	POP		ebp
	RET		8
writeVal ENDP
; ---------------------------------------------------------------------------------
; Name: calcSum
; calculates the sum of SDWORDs in the array and outputs using writeVal
; Receives: ARRAYSIZE, addresses of numArray, outputStr, sum and sumStr 
; Preconditions: ARRAYSIZE & numArray must be filled and defined
; Returns: sum
; ---------------------------------------------------------------------------------	
calcSum PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		edi, [ebp + 8]		;array
	MOV		eax, 0
	MOV		ecx, ARRAYSIZE		;loop counter init
_sumLoop:
;loop to add each num to sum
	ADD		eax, [edi]			;adds current value at edi to eax
	ADD		edi, 4				;moves to next entry in array
	LOOP	_sumLoop
	MOV		ebx, [ebp + 16]		;address of sum in ebx 
	MOV		[ebx], eax			;puts sum into the sum variable 
	MOV		edi, [ebp + 12]		;outputstr
	PUSH	edi					
	PUSH	eax					;passes the sum to writeval
	mDisplayString [ebp + 20]	;displays sumStr
	CALL	writeVal
	POP		ebp
	RET		16
calcSum ENDP
; ---------------------------------------------------------------------------------
; Name: calcSum
; calculates the avg of SDWORDs in the array and outputs using writeVal
; Receives: ARRAYSIZE, sum, address of avgStr
; Preconditions: ARRAYSIZE & sum must be defined
; ---------------------------------------------------------------------------------	
calcAvg PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		eax, [ebp + 12]		;sum
	MOV		ebx, ARRAYSIZE		;number of numbers in array
	CDQ							
	IDIV	ebx					;div sum by number of numbers
	MOV		edi, [ebp + 8]		;outputstr
	PUSH	edi					
	PUSH	eax					;avg	
	mDisplayString [ebp + 16]	;avgStr
	CALL	writeVal			;outputs avg as string
	POP		ebp
	RET		12
calcAvg ENDP
; ---------------------------------------------------------------------------------
; Name: farewell
; Bids the user farewell
; Receives: farewell addresss
; ---------------------------------------------------------------------------------
farewell PROC
	PUSH	ebp
	MOV		ebp, esp
	CALL	Crlf
	mDisplayString [ebp + 8]	;farewellStr
	CALL	Crlf
	CALL	Crlf
	POP		ebp
	RET		8
farewell ENDP
END MAIN
