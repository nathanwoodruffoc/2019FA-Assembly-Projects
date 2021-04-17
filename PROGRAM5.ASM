TITLE	Program #4 - Frequency Count
;****************************************************************************
;* Title:	Program #5 - Sieve of Eratosthenes								*
;* Author:	Nathan Woodruff													*
;* Date:	10/26/2018														*
;* Purpose:						*
;****************************************************************************
;* Grading:	Correctness		______											*
;* 			Style			______											*
;* 			Documentation	______	Total ______							*
;****************************************************************************

		.MODEL small
		STACK 256
		
;****************************************************************************
;* Equates Section
;****************************************************************************

EOS 		EQU		0							; End of string
maxLen		EQU		6							; Maximum entry string length
maxTable	EQU		10000						; Maximum number value
maxNumLen	EQU		4							; Length of printed numbers
bell		EQU		7							; Bell character - <ctrl> G

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA

ExCode		db		0													; DOS Error Code

;variables
outbuffer	db		5 	dup (?)											; Character output buffer
inputStr	db		256 dup (?)											; User input buffer
ptable		db		10000 dup (?)										; Prime number table

;labels
labelPrompt	db		'Enter the stopping value (2 to 10000): ',EOS
labelCount1	db		'Here are all of the prime numbers from 2 to ',EOS
labelCount2	db		':',EOS
labelAst	db		'*',EOS
labelSpace	db		' ',EOS
labelStats1	db		'Found ',EOS
labelStats2	db		' prime numbers.',EOS
labelStats3	db		' twin prime pairs.',EOS

userMaxNum	dw		0													; The amount of numbers to check for primes specified by the user

;****************************************************************************
;* Code Section
;****************************************************************************
		.CODE

;****************************************************************************
;* External Procedures from STRINGS.OBJ and STRIO.OBJ
;****************************************************************************
		EXTRN	StrLength:proc, StrRead:proc
		EXTRN	StrWrite:proc, NewLine:proc
		
;****************************************************************************
;* External Procedures from BINASC.OBJ
;****************************************************************************
		EXTRN	BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
		EXTRN	BinToAscBin:proc, AscToBin:proc

;****************************************************************************
;* Subroutine - CrossOffMultiples: Cross off multiples of a value in the table
;****************************************************************************
; Register parameters:
; 	si - Multiples of this index will be crossed off
; 	di - Address of the table
; 	cx - Maximum index
; 
; Register usage in subroutine:
; 	si - Table index to start at and multiple
; 	di - Current table index address
CrossOffMultiples:
		push 	cx						;
		push 	di						; 
		add 	cx, di					; Make cx the address of the last table item by adding the table address to cx
		
CLoop:
		cmp 	di, cx					; Check if the current address is outside the table
		ja 		CEnd						; If so then break
		
		mov		byte ptr [di], 0		; Zero the value at the current address
		add 	di, si					; Skip to the next multiple by adding the table index to di
		jmp 	CLoop					; Repeat the loop		
CEnd:
		pop 	di						; 
		pop 	cx						; 
		ret							; 
		
;****************************************************************************
;* Subroutine - PrintNum: Print a number
;****************************************************************************
; Register parameters:
; 	ax - number to print
; 	cx - length of the string
PrintNum:
		.DATA
output 		db 	5 dup (?)
strLen		dw	0
		
		.CODE
		push 	di
		push 	bx
		mov 	bx, 0					; Init the loop counter
		mov 	di, offset output		; Put the string in output
		mov 	strLen, cx				; Set the minimum string length
		call 	BinToAscDec				; Convert the number to ASCII
PLoop:
		cmp 	bx, strLen				; Check if we're at the end of the string
		je 		PEnd					; If so then break
		
		cmp 	output[bx], '0'			; Check if the char is 0
		jne 	PEnd					; If nonzero char is encountered then stop replacing chars
		
		mov 	output[bx], ' '			; If zero then replace with a space
		
		inc 	bx						; Go to the next character
		jmp 	PLoop					; 
		
PEnd:
		call 	StrWrite				; Print the string
		pop 	bx
		pop 	di
		ret


		
;****************************************************************************
;****************************************************************************
;* Main Entry Point of the program
;****************************************************************************
;****************************************************************************
MainEntry:
		mov		ax,	@data				; Initialize DS to address
		mov		ds,	ax					;  of data segment
		mov		es, ax					; Make es = ds

Start:
		mov 	di, offset labelPrompt 	; Print user prompt
		call 	StrWrite				; 
		
		mov 	cx, maxLen				; Get user input and store it in inputStr
		mov 	di, offset inputStr		; 
		call 	StrRead					; 
		call 	AscToBin				; 
		mov 	userMaxNum, ax			; 
		
		mov 	di, offset labelCount1	; Print table header first half
		call 	StrWrite				; 
		mov 	di, offset inputStr		; Print user input
		call 	StrWrite				; 
		mov 	di, offset labelCount2	; Print table header second half
		call 	StrWrite				; 
		call 	NewLine					;

;****************************************************************************
; Reset the table
;****************************************************************************
		mov 	si, 0					; Init table index
RLoop:
		cmp 	si, maxTable			; See if the index is outside the table
		je 		RDone					; If so then break out of the loop
		
		mov 	ptable[si], 1			; Set the current table value to 1
		inc 	si						; Increment the table index
		jmp 	RLoop					; Jump to beginning of the loop
RDone:


;****************************************************************************
; Print the primes
;****************************************************************************

		.DATA
lastPrime	dw	2						; The last prime value found
numPrimes	dw	0						; Number of primes found
numTwins	dw	0						; Number of twin prime pairs found
		
		.CODE
		mov 	numPrimes, 0			; Init number of primes
		mov 	numTwins, 0				; Init number of twins
		mov 	si, 2					; Skip index 0 and 1
PrintLoop:
		cmp 	si, maxTable			; Skip if end of table is reached
		ja 		PrintDone				; 
		cmp 	si, userMaxNum			; Skip if end of user specified numbers is reached
		ja 		PrintDone				; 

		cmp 	ptable[si], 1			; Check if current value is a prime
		jne 	SkipNum					; Skip number if it is not prime
		inc 	numPrimes				; If number is prime then increment the counter for primes found
		
;****************************************************************************
; Check for twins
;****************************************************************************
		add 	lastPrime, 2			; Check if the current index is a twin prime with the previous index
		cmp 	lastPrime, si			; 
		jne 	NormalPrime				; Jump if number isn't a twin prime

TwinPrime:								; If number is a twin prime
		mov 	di, offset labelAst		; Print a star
		call 	StrWrite				; 
		inc 	numTwins				; Increment the twin prime counter
		jmp 	PrintNumber				; Print the number

NormalPrime:							; If number isn't a twin prime
		mov 	di, offset labelSpace	; Print a space
		call 	StrWrite				; 
;****************************************************************************
; Print the number
;****************************************************************************
PrintNumber:
		mov 	cx, maxNumLen			; Set the max length of printed numbers
		mov 	ax, si					; Print the current table index
		call 	PrintNum				; 
;****************************************************************************
; Cross off multiples
;****************************************************************************	
		mov 	lastPrime, si			; Set lastPrime to the current prime
		mov 	di, offset ptable		; 
		mov 	cx, maxTable			; 
		call 	CrossOffMultiples		; Cross off the current value and all multiples
		
SkipNum:
		inc 	si						; Increment the table index
		jmp 	PrintLoop				; Jump to the beginning of the loop
PrintDone:


;****************************************************************************
; Print number of primes found
;****************************************************************************
		call 	NewLine					; 
		
		mov 	di, offset labelStats1	; Print 'Found '
		call 	StrWrite				; 
		
		mov 	ax, numPrimes			; convert numPrimes
		mov 	di, offset outbuffer	; Put string in outbuffer
		mov 	cx, 1					; Set variable string length
		call 	BinToAscDec				; 
		call 	StrWrite				; Print numPrimes
		
		mov 	di, offset labelStats2	; Print ' prime numbers.'
		call 	StrWrite				; 
		call 	NewLine					; 
		
;****************************************************************************
; Print number of twin prime pairs found
;****************************************************************************
		mov 	di, offset labelStats1	; Print 'Found '
		call 	StrWrite				; 
		
		mov 	ax, numTwins			; convert numTwins
		mov 	di, offset outbuffer	; Put string in outbuffer
		mov 	cx, 1					; Set variable string length
		call 	BinToAscDec				; 
		call 	StrWrite				; Print numTwins
		
		mov 	di, offset labelStats3	; Print ' twin prime pairs.'
		call 	StrWrite				; 
		call 	NewLine					; 

;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
		.DATA
labelAgain	db		'Do you want to create another list? (Y or N): ',EOS
		.CODE
		call	NewLine					;
		
		mov		di, offset labelAgain	; Ask the user to go again
		call	StrWrite				;  

		mov		di, offset inputStr		; Save answer to inputStr
		mov 	cx, 2					; Maximum string length 2
		call	StrRead					; Read answer
		call	NewLine					;
		call	NewLine					;

		mov		al, inputStr			; move the answer into al for processing
		and 	al, 11011111b			; Make answer uppercase
		cmp		al,'N'					; See if answer is no
		je		Done					; If the answer is 'N' then exit
		jmp		Start					;

Done:
		mov 	ah, 04Ch				; DOS Function: Exit program
		mov 	al, exCode				; Return exit code value
		int		21h						; Call DOS, Terminate Program
		
		END		MainEntry				; End of program / Entry point


