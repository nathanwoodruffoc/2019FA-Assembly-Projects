TITLE	Program #7 - IEEE Floating Point Number Converter
;****************************************************************************
;* Title:	Program #7 - IEEE Floating Point Number Converter				*
;* Author:	Nathan Woodruff													*
;* Date:	12/05/2018														*
;* Purpose:	Accepts an 32 bit hexadecimal number representing an IEEE 		*
;*          single precision floating point number and prints it as a 		*
;*          normalized binary number with a decimal exponent.				*
;****************************************************************************
;* Grading:	Correctness		______											*
;* 			Style			______											*
;* 			Documentation	______	Total ______							*
;****************************************************************************

		.286
		.MODEL small
		STACK 256
		
;****************************************************************************
;* Equates Section
;****************************************************************************

exCode		EQU		0							; Dos Error Code
EOS 		EQU		0							; End of string
maxLen		EQU		9							; Maximum entry string length
bell		EQU		7							; Bell character - <ctrl> G

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA

inputStr	db		maxLen dup (?)				; User input string
tempInput	db		maxLen dup (?)				; Used in converting string to bit array

bitArray	db		32 dup (?)					; Array of bits corresponding to the user input

expStr		db		maxLen dup (?)				; string used for displaying the exponent
tempDisp	db		2 dup (0)					; String used for displaying single numbers

;****************************************************************************
;* Code Section
;****************************************************************************
		.CODE

;****************************************************************************
;* External Procedures from MTA subroutine library
;****************************************************************************
		EXTRN	StrLength:proc, StrRead:proc
		EXTRN	StrWrite:proc, NewLine:proc
		EXTRN	BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
		EXTRN	BinToAscBin:proc, AscToBin:proc

;****************************************************************************
;* Macro PrintI - Prints an immediate string value
PrintI MACRO inputstr
Local @@string
		.DATA
		@@string db inputstr,EOS
		.CODE
		push	di
		
		mov		di, offset @@string
		call	StrWrite
		
		pop		di
ENDM PrintI

;****************************************************************************
;* Macro PrintV - Prints a string contained in a variable
PrintV MACRO inputstr
		push	di
		
		mov		di, offset inputstr
		call	StrWrite
		
		pop		di
ENDM PrintV

;****************************************************************************
;* Subroutine PrintArray - (Debug) - Prints each value in the bit array
PrintArray:
		push	si							;
		push	di							;
		push	ax							;
		
		mov		si, offset bitArray			; 
		
		REPT	32							; Print all 32 bits
		mov		al, byte ptr [si]			; mov current value into al
		add		al, '0'						; make current value a character
		mov		tempDisp, al				; move value into tempDisp and print it
		PrintV	tempDisp					;
		PrintI	' '							;
		inc 	si							; Go to next value
		ENDM								;
		
		call	NewLine						;
		pop		ax							;
		pop		di							;
		pop		si							;
		ret									;

;****************************************************************************
;* Subroutine ToUpper - converts the string at di to uppercase
ToUpper:
		push 	di							; Preserve di
UpperLoop:
		cmp		byte ptr [di], EOS			; End the loop at the end of the string
		je		UpperLoopDone				;
		
		cmp		byte ptr [di], 'a'			; Skip this char if it is not a lowercase letter
		jb		UpperSkip					;	
		cmp		byte ptr [di], 'z'			; 
		ja		UpperSkip					;
		
		and 	byte ptr [di], 11011111b	; Make char uppercase
		
UpperSkip:
		inc		di							; Increment the character index
		jmp		UpperLoop					; Repeat the loop
UpperLoopDone:
		pop 	di
		ret

	
;****************************************************************************
;* Subroutine IsNumZero - Checks if the entire number is all zeros	
IsNumZero:
		push	ax					; Preserve ax and si registers
		push 	si					;	
		mov		al, 0				; Counts the number of ones in the array
		mov		si, 0				; Starting position in the array
		
		REPT	32					; Checks all bytes in the array
		add		al, bitArray[si]	; Adds the current array value to al
		inc 	si					; Goes to the next value
		ENDM
		
		cmp		al, 0				; If all bits are zero then zf is set
		pop		si					; 
		pop		ax					; 
		ret							;

	
;****************************************************************************
;* Subroutine IsExpOnes - Checks if the exponent is all ones
IsExpOnes:
		push	ax					; Preserve ax and si registers
		push 	si					;		
		mov		al, 0				; Counts the number of ones in the array
		mov		si, 1				; Starting position in the array
		
		REPT	8					; Checks 8 bytes from the array
		add		al, bitArray[si]	; Adds the current array value to al
		inc 	si					; Goes to the next value
		ENDM
		
		cmp		al, 8				; If all bits are active then zf is set
		pop		si					; 
		pop		ax					; 
		ret							;
		
;****************************************************************************
;* Subroutine IsExpZero - Checks if the exponent is all zeros		
IsExpZero:
		push	ax					; Preserve ax and si registers
		push 	si					;
		mov		al, 0				; Counts the number of ones in the array
		mov		si, 1				; Starting position in the array
		
		REPT	8					; Checks 8 bytes from the array
		add		al, bitArray[si]	; Adds the current array value to al
		inc 	si					; Goes to the next value
		ENDM
		
		cmp		al, 0				; If there are zero bits active then zf is set
		pop		si					; 
		pop		ax					; 
		ret							;

;****************************************************************************
;* Subroutine IsMagZero - Checks if the magnitude is all zeros	
IsMagZero:
		push	ax					; Preserve ax and si registers
		push 	si					;
		mov		al, 0				; Counts the number of ones in the array
		mov		si, 9				; Starting position in the array
		
		REPT	23					; Checks 23 bytes
		add		al, bitArray[si]	; Adds the current array value to al
		inc 	si					; Goes to the next value
		ENDM
		
		cmp		al, 0				; If there are zero bits active then zf is set
		pop		si					; 
		pop		ax					; 
		ret							;
		
		
		
		
;****************************************************************************
;*
;* Main Entry Point of the program
;*
;****************************************************************************
MainEntry:
		mov		ax,	@data					; Initialize DS to address
		mov		ds,	ax						;  of data segment
		mov		es, ax						; Make es = ds

Start:
;****************************************************************************
;* Zero the bitArray
;****************************************************************************
		mov		di, offset bitArray
		mov		cx, 32
		mov		ax, 0
		cld
		rep		stosb

;****************************************************************************
;* Get user input
;****************************************************************************
		PrintI	'Please enter an 8 digit hexadecimal string: '
		mov		di, offset inputStr			; 
		call	StrRead						; 
		call	NewLine						;

		
;****************************************************************************
;* Copy the user input to tempInput 
;****************************************************************************
		mov		si, offset inputStr			; Copy the user input to tempInput
		mov		di, offset tempInput		;   to preserve the original input
		mov		cx, maxLen					;   so that inputStr can later be displayed
		cld									; 
		rep 	movsb						;

;****************************************************************************
;* Convert hex string into binary and store in bitArray
;****************************************************************************
		mov		di, offset tempInput
		call	ToUpper
		mov		si, 0
		mov		bx, 0
CharLoop:
		cmp		tempInput[si], EOS			; End the loop at the end of the string
		je		CharLoopDone				;

CheckNum:		
		cmp		tempInput[si], '0'			; Check if the character is a number
		jb		CheckLetter					; 
		cmp		tempInput[si], '9'			; 
		ja		CheckLetter					;
		jmp		CharIsNumber				;
CheckLetter:
		cmp		tempInput[si], 'A'			; Check if character is a letter
		jb		InvalidInputError			; 
		cmp		tempInput[si], 'F'			; 
		ja		InvalidInputError			; 
		jmp		CharIsLetter				; 
		
CharIsNumber:
		sub		tempInput[si],'0'			; Turn ASCII numbers into integers 0-9
		jmp		CharAdd
CharIsLetter:
		sub		tempInput[si],'A'			; Turn ASCII letters A-F into integers 10-15
		add		tempInput[si],10			; 
		jmp		CharAdd
CharAdd:
		shl		tempInput[si], 4			; Removes the highest 4 bits which aren't used
		
		REPT 4								; Add the 4 bits from the hex character to the array
		shl		tempInput[si], 1			; Shift the highest bit into cf
		adc		bitArray[bx], 0			; Add cf to the current array slot
		inc 	bx							; Next array slot
		ENDM								; 
		
		inc		si							; Next character
		jmp		CharLoop					; 
InvalidInputError:
		PrintI 	'Invalid Input'				; Invalid Input Error - when user enters invalid characters or does not enter enough characters
		call	NewLine						; 
		jmp		AskAgain					;
CharLoopDone:
		cmp		si, 7						; If the user entered less than 8 characters then display an error
		jb		InvalidInputError			; 

		
		
		PrintV	inputStr					; Print the first half of the result string
		PrintI	' = '						; 

;****************************************************************************
;* Check for edge cases
;****************************************************************************
		; if (the whole number is all zeros)
			; 0.0
		; if (exponent = 1111 1111)
			; if (magnitude = 0)
				; +-infinity
			; else
				; NaN
		; if (exponent = 0000 0000)
			; Denormalized number

		call	IsNumZero				; If number is all zeros then the number is zero
		je 		EdgeZero				; 
			
		call	IsExpOnes				; If exponent is all ones then the number is NAN or +-infinity
		je 		EdgeNANorInfinity		; 
		
		call	IsExpZero				; If exponent is zero then the number is a denormalized number
		je		EdgeDenormalized		; 
		
		jmp		EdgeDone				; 
EdgeNANorInfinity:
		call	IsMagZero				; If the magnitude is zero then the number is +-infinity
		je		EdgeInfinity			; 
		jmp		EdgeNAN					; If the magnitude is not zero then the number is NAN
EdgeNAN:
		PrintI 	'NaN'					; NaN
		call	NewLine					; 
		jmp		AskAgain				; 
EdgeInfinity:
		cmp		bitArray, 1			; If -infinity put a negative sign
		jne		EdgeSkipNegative		;
		PrintI	'-'						;
EdgeSkipNegative:						;
		PrintI	'Infinity'				;
		call	NewLine					; 
		jmp		AskAgain				;
EdgeDenormalized:
		PrintI 	'Denormalized Number'	; Denormalized Number
		call	NewLine					; 
		jmp		AskAgain				;
EdgeZero:
		PrintI	'0.0'					; Zero
		call	NewLine					; 
		jmp		AskAgain				;
EdgeDone:

;****************************************************************************
;* Put exponent value in al
;****************************************************************************
		mov		al, 0				; 
		mov		si, 1				; Start after the sign bit
		
		REPT	8					; move the bits from the array into al
		shl		al, 1				; shift al left
		add		al, bitArray[si]	; add the current bit to al
		inc 	si					; 
		ENDM						; 
		
;****************************************************************************
;* Unbias the exponent and convert it to a string
;****************************************************************************
		sub		al, 7Fh				; Unbias exponent
		cbw							;
		
		mov		di, offset expStr	; 
		mov		cx, 1				; String length
		call	SBinToAscDec		;


		
		
;****************************************************************************
;* Print the result
;****************************************************************************
		
		cmp		bitArray, 1				; If negative print a negative sign
		jne		SkipNegative			;
		PrintI	'-'						;

SkipNegative:							
		PrintI	'1.'					;	 
		
		mov		si, offset bitArray + 9	; Start at the magnitude
		
		REPT	23						; Print the magnitude
		mov		al, byte ptr [si]		; Move current value into al
		add		al, '0'					; Make value a character
		mov		tempDisp, al			; Move result into tempDisp
		PrintV	tempDisp				; Print the value
		inc 	si						; Next value
		ENDM							;
		
		PrintI	' x 2^'					; Print the exponent
		PrintV	expStr					; 
		call	NewLine					; 	

		
;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
AskAgain:
		.DATA
labelAgain 	db 	'Would you like to convert another number (Y/N) ? ',EOS
userAnswer 	db 	2 dup (?)
		.CODE
		call	NewLine					;
		
		mov		di, offset labelAgain	; Ask the user to go again
		call	StrWrite				; 

		mov		di, offset userAnswer	; Save answer to userAnswer
		mov 	cx, 2					; Maximum string length 2
		call	StrRead					; Read answer
		call	NewLine					;
		call	NewLine					;

		mov		al, userAnswer			; move the answer into al for processing
		and 	al, 11011111b			; Make answer uppercase
		cmp		al,'N'					; See if answer is no
		je		Done					; If the answer is 'N' then exit
		jmp		Start					;

Done:
		mov 	ah, 04Ch				; DOS Function: Exit program
		mov 	al, exCode				; Return exit code value
		int		21h						; Call DOS, Terminate Program
				
		END		MainEntry				; End of program / Entry point