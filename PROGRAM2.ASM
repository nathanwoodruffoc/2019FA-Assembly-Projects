TITLE	Program #2 - Base Converter	
;****************************************************************************
;* Title:	Program #2 - Base Converter										*
;* Author:	Nathan Woodruff													*
;* Date:	10/5/2018														*
;* Purpose:	This program prints the binary and hexadecimal equivalents 		*
;* 			for an entered decimal number.									*
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

startLabel	db		'Welcome to the Super Duper Number Converter!',EOS
namePrompt	db		'Please enter your super duper name: ',EOS
numPrompt1	db		'Hi ',EOS
numPrompt2	db		'. Please enter a decimal number from 0 to 65535: ',EOS
resLabel1	db		' decimal = ',EOS
resLabelBin	db		' binary',EOS
resLabelHex	db		' hex',EOS
morePrompt	db		', would you like to do another conversion (Y or N) ?',EOS

buffer		db		maxLen dup (?)							;IO buffer
enteredHex	db		maxLen dup (?)							;hex result string
enteredBin	db		maxLen dup (?)							;bin result string
userName	db		maxLen dup (?)							;The user's name
enteredNum	dw		0


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
;* Ask for the user's name
;****************************************************************************
		mov		di, offset startLabel		; Print welcome string
		call 	StrWrite					; 
		call	NewLine						; 
		
		mov		di, offset namePrompt		; Print name prompt
		call	StrWrite					; 
		
		mov 	cx, maxLen					; Set the max length of the input string
		mov		di, offset userName			; Read the user's name into userName
		call	StrRead						; 

;****************************************************************************
;* Ask the user for a number
;****************************************************************************
NumPrompt:									; Print the number input prompt
		call	NewLine						;
		call	NewLine						;
		mov		di, offset numPrompt1		; Print the first part of the number prompt
		call 	StrWrite					;
		
		mov		di, offset userName			; Print the userName
		call 	StrWrite					;
		
		mov		di, offset numPrompt2		; Print the last part of the number prompt
		call 	StrWrite					;

;****************************************************************************
;* Read the user's input and convert it to binary
;****************************************************************************
		mov		di, offset buffer			; Read user input into buffer
		mov 	cx, maxLen					; Maximum string length
		call	StrRead						;
		call	NewLine						;
		
		mov		di, offset buffer			; convert buffer to binary and store in ax
		call	AscToBin					;
		mov 	enteredNum, ax				; move the result into enteredNum


		
;****************************************************************************
;* Convert the number to ASCII Binary and display
;****************************************************************************
		mov		ax, enteredNum				; Input number
		mov		di, offset enteredBin		; Output string
		mov		cx, maxLen					; Maximum string length
		call BinToAscBin					; 

		mov		di, offset buffer			; Print entered number
		call	StrWrite					;
		mov		di, offset resLabel1		; Print first part of label
		call	StrWrite					;
		mov		di, offset enteredBin		; Print binary ASCII result
		call	StrWrite					;
		mov		di, offset resLabelBin		; Print second part of label
		call	StrWrite					;
		call	NewLine						;

;****************************************************************************
;* Convert the number to ASCII Hex and display
;****************************************************************************
		mov		ax, enteredNum				; Input number
		mov		di, offset enteredHex		; Output string
		mov		cx, maxLen					; Maximum string length
		call BinToAscHex					; convert enteredNum to ASCII hex

		mov		di, offset buffer			; Print entered number
		call	StrWrite					;
		mov		di, offset resLabel1		; Print first part of label
		call	StrWrite					;
		mov		di, offset enteredHex		; Print binary ASCII result
		call	StrWrite					;
		mov		di, offset resLabelHex		; Print second part of label 
		call	StrWrite					;
		call	NewLine						;

;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
		mov		di, offset userName			; print userName
		call	StrWrite					;
		mov		di, offset morePrompt		; print more prompt
		call	StrWrite					;

		mov		di, offset buffer			; Read answer from buffer
		mov 	cx, maxLen					; Maximum string length
		call	StrRead						; Read answer

		cmp		buffer,'n'					; if the answer is 'n' then exit
		je		Done						; 
		cmp		buffer,'N'					; if the answer is 'N' then exit
		je		Done						;
		jmp		NumPrompt					; Ask the user for another number if answer is not 'n' or 'N'




;****************************************************************************
;* Program termination code
;****************************************************************************
Done:
		mov 	ah, 04Ch					; DOS Function: Exit program
		mov 	al, exCode					; Return exit code value
		int		21h							; Call DOS, Terminate Program
		
		END		Start						; End of program / Entry point