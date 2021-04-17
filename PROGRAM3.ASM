TITLE	Program #3 - Calculator
;****************************************************************************
;* Title:	Program #3 - Calculator 										*
;* Author:	Nathan Woodruff													*
;* Date:	10/12/2018														*
;* Purpose:	This program adds, subtracts, or compares two numbers 			*
;*			the user enters.												*
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

EOS 	EQU		0							; End of string
maxLen	EQU		9							; Maximum entry string length
bell	EQU		7							; Bell character - <ctrl> G

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA
		
ExCode		db		0										; DOS Error Code

result		db		maxLen dup (?)							; Result String
buffer		db		maxLen dup (?)							; IO buffer
value1		dw		0										; First Number
value2		dw		0										; Second Number

labelTitle	db		'My calculator.',EOS					; Title label
labelValue1	db		'Enter first value          : ',EOS		; First value label
labelValue2	db		'Enter second value         : ',EOS		; Second value label
labelOp		db		'Enter operation (+, -, C)  : ',EOS		; Operation label
labelResult	db		'The result is              : ',EOS		; Result Label

labelComp1	db		'The second number is ',EOS				; Comparison Result label 1
labelComp2	db		' the first number.',EOS				; Comparison Result label 2
labelCompGT	db		'greater than',EOS						; Greater than comparison result
labelCompLT	db		'less than',EOS							; Less than comparison result
labelCompEQ	db		'equal to',EOS							; Equal to comparison result

labelInvalid db		'Invalid Input.',EOS					; Invalid input label
labelOverflow db	'Error - Overflow',EOS					; Overflow Error label

labelDoAnother db	'Do another calculation (Y or N)? ',EOS ; Ask the user if they would like to go again
labelExit	db		'Exiting the program.',EOS				; Displays on exit


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
;* CheckEntered
;* 		Converts buffer to binary and checks for errors.  If there are errors 
;* 		then an error message is displayed carry flag is set.
;* Parameters:
;* 		ax		The result of the conversion is stored here
;* 		cx		The max length of the input string
;****************************************************************************
CheckEntered:						
		push	di							; save di to stack
		
		mov		di, offset buffer			; Read string into buffer
		call	StrRead						; Read string into buffer
		
		mov		di, offset buffer			; convert buffer to binary
		call	AscToBin					; convert buffer to binary
		
		jnc		CheckEnteredEnd				; If the number is invalid display an error message and return
		call	NewLine						;
		mov		di, offset labelInvalid		; Display the invalid input message
		call	StrWrite					; Display the invalid input message
		stc									; Sets carry flag to indicate an error has occurred

CheckEnteredEnd:
		pop		di							; restore di from the stack
		ret									; Return from the subroutine
		
		
;****************************************************************************
;* Main Entry Point of the program
;****************************************************************************
Start:
		mov		ax,	@data					; Initialize DS to address
		mov		ds,	ax						;  of data segment
		mov		es, ax						; Make es = ds
		
		mov		di, offset labelTitle		; Display the startup message
		call	StrWrite					;
		call	NewLine						;

		
;****************************************************************************
;* Enter the first value
;****************************************************************************
First:
		call	NewLine						;
		mov		di, offset labelValue1		; Display input prompt
		call	StrWrite					; 
		
		mov 	cx, maxLen					; Set the max length of the input string
		call 	CheckEntered				; Calls a subroutine which lets the user enter a number and checks it for errors.  If there are errors a message is displayed and cf is set to 1
		jc		First						; If the input is invalid, let the user enter another number
		mov		value1, ax					; Stores result in value1

;****************************************************************************
;* Enter the second value
;****************************************************************************
Second:
		call	NewLine						;
		mov		di, offset labelValue2		; Display input prompt
		call	StrWrite					; 
		
		mov 	cx, maxLen					; Set the max length of the input string
		call 	CheckEntered				; Calls a subroutine which lets the user enter a number and checks it for errors.  If there are errors a message is displayed and cf is set to 1
		jc		Second						; If the input is invalid, let the user enter another number
		mov		value2, ax					; Stores result in value1

;****************************************************************************
;* Enter the operation
;****************************************************************************
Operation:
		call 	NewLine
		mov		di, offset labelOp			; Display input prompt
		call	StrWrite					; 
		
		mov		di, offset buffer			; Save answer to buffer
		mov 	cx, maxLen					; Maximum string length
		call	StrRead						; Read answer

		cmp		buffer, '+'					; If the answer is '+' then add the two numbers
		je		AddNum						;
		
		cmp		buffer, '-'					; If the answer is '-' then add the two numbers
		je		SubNum						;		
			
		cmp		buffer, 'c'					; If the answer is 'C' then compare the two numbers
		je		CmpNum						;
		
		cmp		buffer, 'C'					; If the answer is 'c' then compare the two numbers
		je		CmpNum						;
		
		jmp 	Operation					; If the user's input is invalid then have them choose again

		
;****************************************************************************
;* Operation - Add
;****************************************************************************	
AddNum:
		call	NewLine
		mov		di, offset labelResult		; Display result label
		call	StrWrite					;
		
		mov		ax, value2					;
		add		value1, ax					; result stored in value1
		jo		AddNumError					; If there is an error then display an error
		
		mov		ax, value1					; convert value1 to ascii
		mov		di, offset result			; store result in result
		mov 	cx, maxLen					; Set the max length of the input string
		call	SBinToAscDec				; convert value1 to ascii
		
		mov		di, offset result			; Display result
		call	StrWrite					;
		jmp 	AskAgain					; Ask the user if they want to go again
		
AddNumError:
		mov		di, offset labelOverflow	; Display overflow error
		call	StrWrite					;
		jmp 	AskAgain					; Jump to ask user to go again

		
;****************************************************************************
;* Operation - Subtract
;****************************************************************************	
SubNum:
		call	NewLine
		mov		di, offset labelResult		; Display result label
		call	StrWrite					;
		
		mov		ax, value2					;
		sub		value1, ax					; result stored in value1
		jo		SubNumError					; If there is an error then display an error
		
		mov		ax, value1					; convert value1 to ascii
		mov		di, offset result			; store result in result
		mov 	cx, maxLen					; Set the max length of the input string
		call	SBinToAscDec				; convert value1 to ascii
		
		mov		di, offset result			; Display result
		call	StrWrite					;
		jmp 	AskAgain					; Ask the user if they want to go again
		
SubNumError:
		mov		di, offset labelOverflow	; Display overflow error
		call	StrWrite					;
		jmp 	AskAgain					; Jump to ask user to go again

		
;****************************************************************************
;* Operation - Compare
;****************************************************************************	
CmpNum:
		call	NewLine						;
		mov		di, offset labelComp1		; Display first part of result message
		call	StrWrite					;

		mov		ax, value2					; move value2 into ax for the comparison
		cmp		ax, value1					; Compare value1 and value2
		jg		CmpNumGtr					; Jump if value2 is greater than value1
		jl		CmpNumLes					; Jump if value2 is less than value1
		je		CmpNumEqu					; Jump if value2 is equal to value1
		

CmpNumGtr:
		mov		di, offset labelCompGT		; Display greater than label
		call	StrWrite					;
		jmp 	CmpNumFinal					; Jump to final section of CmpNum
		
CmpNumLes:
		mov		di, offset labelCompLT		; Display less than label
		call	StrWrite					;
		jmp 	CmpNumFinal					; Jump to final section of CmpNum
		
CmpNumEqu:
		mov		di, offset labelCompEQ		; Display equal to label
		call	StrWrite					;
		jmp 	CmpNumFinal					; Jump to final section of CmpNum
		
CmpNumFinal:
		mov		di, offset labelComp2		; Display second part of result message
		call	StrWrite					;
		jmp		AskAgain					; Jump to ask user to go again

		
;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
AskAgain:
		call	NewLine
		mov		di, offset labelDoAnother	; Ask the user to go again
		call	StrWrite					; 

		mov		di, offset buffer			; Save answer to buffer
		mov 	cx, maxLen					; Maximum string length
		call	StrRead						; Read answer

		cmp		buffer,'n'					; if the answer is 'n' then exit
		je		Done						; 
		cmp		buffer,'N'					; if the answer is 'N' then exit
		je		Done						;
		
		call	NewLine
		call 	NewLine
		jmp		First						; Restart program if answer is not 'n' or 'N'

Done:
		mov		di, offset labelExit		; Displays exit message
		call	NewLine						;
		call	StrWrite					; Displays exit message
		call 	NewLine						;
		
		mov 	ah, 04Ch					; DOS Function: Exit program
		mov 	al, exCode					; Return exit code value
		int		21h							; Call DOS, Terminate Program
		
		END		Start						; End of program / Entry point
