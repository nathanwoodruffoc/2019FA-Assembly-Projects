TITLE	Program #4 - Frequency Count
;****************************************************************************
;* Title:	Program #4 - Frequency Count									*
;* Author:	Nathan Woodruff													*
;* Date:	10/26/2018														*
;* Purpose:	This program determines the number of times that each letter of *
;*			the alphabet appears in a string of characters.					*
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
maxLen	EQU		255							; Maximum entry string length
bell	EQU		7							; Bell character - <ctrl> G

cLeft	EQU		0							; Left column type
cRight	EQU		1							; Right column type

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA

ExCode		db		0													; DOS Error Code

;variables
outbuffer	db		4 	dup (?)											; Character output buffer
inputStr	db		256 dup (?)											; User input buffer
ftable		db		26 	dup (?)											; Character frequency table

;loop vars
letterIndex	db		0
column		db		0

;strings
labelEnter	db		'Please enter a string of characters:',EOS			;
labelEcho	db		'The entered string is:',EOS						;
labelTable	db		'Frequency Table',EOS								;
labelAgain	db		'Do you wish to process another string (Y/N)? ',EOS	;

;formatting components
emptyValue	db		' - ',EOS											;
spaces3		db		'   ',EOS											;
spaces4		db		'    ',EOS											;
spaces6		db		'      ',EOS										;
spaces12	db		'            ',EOS									;
headerChar	db		'Character',EOS										;
headerFreq	db		'Frequency',EOS										;
headerDash	db		'---------',EOS										;


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
MainEntry:
		mov		ax,	@data				; Initialize DS to address
		mov		ds,	ax					;  of data segment
		mov		es, ax					; Make es = ds


;****************************************************************************
;* Zero the table
;****************************************************************************
Start:
		mov		di, 0					; Initialize table index
Zloop:
		mov		ftable[di], 0			; Set the indexed value in the table to 0
		inc		di						; Increment the table index
		cmp		di, 26					; Check if table index is over the length of the table
		jne		zloop					; If it is then break out of the loop

;****************************************************************************
;* Enter the string to be processed
;****************************************************************************
		mov		di, offset labelEnter	; Prompt the user to enter a string
		call	StrWrite				; 
		call	NewLine					; 
		
		mov		di, offset inputStr		; Read the user's input into inputStr
		mov		cx, maxLen 				; Take up to 255 characters for input
		call	StrRead					; Read the user's input
		
;****************************************************************************
;* Print the string
;****************************************************************************
		call	NewLine					; 
		call	NewLine					; 	
		
		mov		di, offset labelEcho	; Print the label for the echoed string
		call	StrWrite				; 
		call	NewLine					; 
		
		mov		di, offset inputStr		; Echo the user's input back to the user
		call	StrWrite				; 
		call	NewLine					; 
		call	NewLine					; 

		
;****************************************************************************
;* Generate the table
;****************************************************************************
		mov 	si, offset inputStr		; si points to the first character
Genloop:
		mov 	al, [si]				; al now has character that si points to
		cmp 	al, EOS					; check for end of string
		je		Gendone					; Break loop if end of sting
		
		and 	al, 11011111b			; Ensure char in al is uppercase
		sub		al, 'A'					; A = 0, B = 1, etc
		cmp		al, 25					; check if al is not a letter
		ja		Genskipchar				; skip if char is not a letter
		
		mov		ah, 0					; make ax the same as al in high bits
		mov		di, ax					; make table index from ax
		inc		ftable[di]				; increment the table index di
Genskipchar:
		inc 	si						; si now points to the next character
		jmp		Genloop					; Go again
Gendone:

;****************************************************************************
;* Display the table header
;****************************************************************************
		mov		di, offset labelTable	; Displays Table Title
		;mov		cx, 9					; 
		call	StrWrite				; 
		call	NewLine					; 
		
		mov		di, offset headerChar	; Displays the first line of the header
		call	StrWrite				; 
		mov		di, offset spaces6		; 
		call	StrWrite				; 
		mov		di, offset headerFreq	; 
		call	StrWrite				; 
		mov		di, offset spaces12		; 
		call	StrWrite				; 
		mov		di, offset headerChar	; 
		call	StrWrite				; 
		mov		di, offset spaces6		; 
		call	StrWrite				; 
		mov		di, offset headerFreq	; 
		call	StrWrite				; 
		call	NewLine					; 
		
		mov		di, offset headerDash	; Displays the second line of the header
		call	StrWrite				; 
		mov		di, offset spaces6		; 
		call	StrWrite				; 
		mov		di, offset headerDash	; 
		call	StrWrite				; 
		mov		di, offset spaces12		; 
		call	StrWrite				; 
		mov		di, offset headerDash	; 
		call	StrWrite				; 
		mov		di, offset spaces6		; 
		call	StrWrite				; 
		mov		di, offset headerDash	; 
		call	StrWrite				; 
		call	NewLine					; 
		
		
;****************************************************************************
;* Display the table
;****************************************************************************		
		mov		column, cLeft			; Set the column type to left
		mov		letterIndex, 0			; Zero the letter index
OLoop:
; ***** Print first spaces *****

		mov		di, offset spaces4		; Print spaces before the letter
		call	StrWrite				;
		

; ***** Print the letter *****

		mov		al, letterIndex			; move the index into al for processing
		add 	al, 'A'					; offset the index in al by 'A', so that the value (0 - 25) of the index is now an ASCII code for the corresponding letter of the alphabet
		mov		outbuffer, al			; Move the character to outbuffer
		mov		outbuffer+1, EOS		; Add an end of string character to outbuffer
		mov		di, offset outbuffer	; Print the character
		call	StrWrite				; 
		

; ***** Print spacing *****

		mov		di, offset spaces4		; Print the spaces after the letter
		call	StrWrite				; 
		mov		di, offset spaces6		; Print the spaces between columns
		call	StrWrite				; 
		mov		di, offset spaces3		; Print the spaces before the number
		call	StrWrite 				; 
		

; ***** Print the number *****

		mov		al, letterIndex			; move index to al
		mov		ah, 0					; make ax equivalent to al
		mov		si, ax					; move index at ax into si
		mov 	al, ftable[si]			; Moves frequency value for the character into al
		
		cmp		al, 0					; See if the frequency value is zero
		jne		PrintNum				; If the value is zero, print spaces instead of zeros
		
PrintZero:
		mov		di, offset emptyValue	; Print the zero value placeholder
		call	StrWrite
		jmp		PrintDone				; Skip printing the frequency value

PrintNum:		
		mov		di, offset outbuffer	; Sets outbuffer as the destination for the acsii conversion
		mov		cx,	3					; Sets the string length to 3
		call	BinToAscDec				; Converts the frequency value to ascii
		call	StrWrite				; Writes the result to the screen

PrintDone:

		mov		di, offset spaces3		; Print spaces after the number
		call	StrWrite				; 

		cmp		column, cRight			; See if the program is currently processing a right column
		je		ORightColumn			; If it is then jump to ORightColumn
		
OLeftColumn:							; Left column specific actions
		mov		di, offset spaces12		; Print spaces before the right column
		call	StrWrite				;
		mov		column, cRight			; Set the column type to right
		add		letterIndex, 13			; Offset the index by 13 so the right column displays the correct letters
		jmp 	OLoop					; Restart the loop

ORightColumn:							; Right column specific actions
		cmp		letterIndex, 25			; See if this is the last letter
		je		ODone					; End the loop
		
		call	NewLine					; Add newline for the next row
		mov		column, cLeft			; Set column type to left
		add		letterIndex, -12		; Remove the offset of 13 from the index and increment the index so the left column is correct
		jmp		OLoop					; Restart the loop
Odone:


;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
AskAgain:
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


