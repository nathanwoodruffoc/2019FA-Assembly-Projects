TITLE	Example Program #1
;****************************************************************************
;* Title:	Example Program #1												*
;* Author:	Nathan Woodruff													*
;* Date:	9/19/2018														*
;* Purpose:	This program gets two numbers and prints out the sum.			*
;****************************************************************************
;* Grading:	Correctness		______
;* 			Style			______
;* 			Documentation	______	Total ______
;****************************************************************************

		.MODEL small
		STACK 256
		
;****************************************************************************
;* Equates Section
;****************************************************************************

EOS 	EQU		0							; End of string
maxLen	EQU		40							; Maximum entry string length
bell	EQU		7							; Bell character - <ctrl> G

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA
		
ExCode		db		0										; DOS Error Code

enter1		db		'Enter first number: ',EOS				; Prompt for 1st num
enter2		db		'Enter second number: ',EOS				; Prompt for 2nd num
sumout		db		'The sum is: ',EOS						; Sum output label
number1		dw		0										; First number
number2		dw		0										; Second Number
sum			dw		0										; Sum
buffer		db		maxLen dup (?)							; Input/Output Buffer
inperror	db		bell,'Invalid number; Reenter.',EOS		; Input error message
sumerror	db		bell,'The sum is too large.',EOS		; Sum error message

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
;* Main Entry Point of the program
;****************************************************************************
Start:
		mov		ax,	@data					; Initialize DS to address
		mov		ds,	ax						;  of data segment
		mov		es, ax						; Make es = ds
		
;****************************************************************************
;* Get the first number
;****************************************************************************
First:
		call	NewLine						; Start new display line
		mov		di, OFFSET enter1			; Display message to enter
		call	StrWrite					;  first number
		
		mov 	di, OFFSET buffer			; Buffer will get the user's entry
		mov		cx, maxLen					; Maximum string length
		call	StrRead						; Get entry from keyboard
		
		call	AscToBin					; Convert string to binary --> ax
		mov 	number1, ax					; Save value into number1
		jnc		Second						; Jump if cf is 0 (no error)
		call	NewLine						; Else:
		mov 	di, OFFSET inperror			; Display error message
		call	StrWrite					
		jmp		First						; Lets the user try again
		
;****************************************************************************
;* Get the second number
;****************************************************************************
Second:
		call	NewLine						; Start new display line
		mov		di, OFFSET enter2			; Display message to enter
		call	StrWrite					;  second number
		
		mov 	di, OFFSET buffer			; Buffer will get the user's entry
		mov		cx, maxLen					; Maximum string length
		call	StrRead						; Get entry from keyboard
		
		call	AscToBin					; Convert string to binary --> ax
		mov 	number2, ax					; Save value into number2
		jnc		GetSum						; Jump if cf is 0 (no error)
		call	NewLine						; Else:
		mov 	di, OFFSET inperror			; Display error message
		call	StrWrite					
		jmp		Second						; Lets the user try again
		
;****************************************************************************
;* Calculate the sum and print it out
;****************************************************************************
GetSum:
		call 	NewLine
		mov		ax, number1					; Put first number into ax
		add		ax, number2					; Add second number to ax
		jc		TooBig						; Carry flag means answer is too big
		mov		sum, ax						; Save ax into variable
		mov		di, OFFSET sumout			; Point to sum output label
		call	StrWrite					; Print sum output label
		mov 	di, OFFSET buffer			; Point to buffer string
		mov		ax, sum						; Number argument for BinToAscDec
		mov		cx, 1						; Length argument for BinToAscDec
		call	BinToAscDec					; Convert sum to string or printing
		call	StrWrite					; Print the sum
		jmp		Done
		
;****************************************************************************
;* Print an error if the sum is too big
;****************************************************************************
TooBig:
		mov 	di, OFFSET sumerror			; Point at "Sum too big"
		call	StrWrite					; Print error message
		
;****************************************************************************
;* End of program
;****************************************************************************
Done:
		call 	NewLine
		call 	NewLine
;****************************************************************************
;* Program termination code
;****************************************************************************
		mov 	ah, 04Ch					; DOS Function: Exit program
		mov 	al, exCode					; Return exit code value
		int		21h							; Call DOS, Terminate Program
		
		END		Start						; End of program / Entry point