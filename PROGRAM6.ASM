TITLE	Program #6 - Postfix Evaluator
;****************************************************************************
;* Title:	Program #6 - Postfix Evaluator									*
;* Author:	Nathan Woodruff													*
;* Date:	11/14/2018														*
;* Purpose:	Evaluate a postfix expression given by the user					*
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

exCode		EQU		0							; Dos Error Code
EOS 		EQU		0							; End of string
maxLen		EQU		254							; Maximum entry string length
bell		EQU		7							; Bell character - <ctrl> G

;****************************************************************************
;* Data Section
;****************************************************************************
		.DATA

;Labels
labelInput	db		'Enter an expression to evaluate: ',EOS
labelResult db		'The value of the expression is: ',EOS
labelAgain	db		'Do you want to evaluate another expression? (Y or N): ',EOS

labelNum1	db		'Enter a value for ',EOS
labelNum2	db		': ',EOS

labelError1	db		'Error - Invalid character.',EOS
labelError2 db		'Error - Not enough operators.',EOS
labelError3	db		'Error - Not enough operands.',EOS


;Variables
inputStr	db		maxLen dup (?)										; Input string for the expression
inputNumStr	db		maxLen dup (?)										; Input string for the operand values
currentOp	db		2 dup (?)											; Output string for the current operand the program is asking for
result		db		maxLen dup (?)										; Output string for the result of the expression

valueTable	dw		26 dup (?)											; Table of values assigned to each operand
neededTable db		26 dup (?)											; Table of statuses for each operand, 1 indicates that the operand's value needs to be asked for

stackAmount db		0													; When testing the expression, keeps track of how many items are on the stack
userAnswer	db		2 dup (?)											; 

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
;* Get an expression from the user
;****************************************************************************
		mov		di, offset labelInput		; Prompt the user for input
		call	StrWrite					;
		mov 	di, offset inputStr			; Get user input
		mov		cx, maxLen					; 
		call 	StrRead						; 

;****************************************************************************
;* Make the operands uppercase
;****************************************************************************
		mov	si, 0
UpperLoop:
		cmp		inputStr[si], EOS			; End the loop at the end of the string
		je		UpperLoopDone				;
		
		cmp		inputStr[si], 'a'			; Skip this char if it is not a lowercase letter
		jb		UpperSkip					;	
		cmp		inputStr[si], 'z'			; 
		ja		UpperSkip					;
		
		and 	inputStr[si], 11011111b		; Make char uppercase
		
UpperSkip:
		inc		si							; Increment the character index
		jmp		UpperLoop					; Repeat the loop
UpperLoopDone:

;****************************************************************************
;* Reset the neededTable
;****************************************************************************
		mov		di, offset neededTable
		mov		ax, 0
		mov		cx, 26
		cld
		rep		stosb


;****************************************************************************
;* Test the expression
;****************************************************************************
TestExpression:		
		mov		si, 0						; Initialize the string index
		mov		stackAmount, 0				; Keeps track of the number of values pushed onto the stack
TestLoop:
		cmp		inputStr[si], EOS			; End the loop at the end of the string
		je		TestExpressionDone			; 

TestOperand:
		cmp		inputStr[si], 'A'			; Test that the character is an operand
		jb		TestOperator				; If not an operand, test if the character is an operator
		cmp		inputStr[si], 'Z'			;
		ja		TestOperator				;
IsOperand:
		inc 	stackAmount					; If the character is an operand simulate pushing a value onto the stack
		mov		bl, inputStr[si]			; Put current char in bx
		mov		bh, 0						; 
		sub		bx, 'A'						; transform ASCII character into an offset
		mov		neededTable[bx], 1			; set the operator status to needed
		jmp		TestLoopDone				; Repeat the loop
TestOperator:
		cmp		inputStr[si], '+'			; If the character is not an operand, test that the character is an operator
		je		IsOperator					; 
		cmp		inputStr[si], '-'			; 
		je		IsOperator					;
		cmp		inputStr[si], '*'			;
		je		IsOperator					;
		cmp		inputStr[si], '/'			;
		je		IsOperator					;
		jmp		InvalidError				; If the char is not an operand or an operator it is invalid
IsOperator:
		add		stackAmount, -2				; If the character is an operator then simulate popping two values off the stack
		cmp		stackAmount, 0				; Check the amount of items left on the stack
		jl		OperandError				; If the stack amount is negative then there are not enough operands for the operator to use
		inc		stackAmount					; If the stack amount is 0 or greater then simulate pushing the result of the operand onto the stack
		jmp		TestLoopDone				; Repeat the loop


InvalidError:
		mov 	di, offset labelError1		; Invalid character error
		jmp 	PrintError					;
OperatorError:
		mov 	di, offset labelError2		; Not enough operators error
		jmp 	PrintError					;
OperandError:
		mov 	di, offset labelError3		; Not enough operands error

PrintError:
		call	NewLine						; Print the error message
		call	StrWrite					;
		jmp 	AskAgain					; Ask the user for another expression
		

TestLoopDone:
		inc 	si							; Increment the string index
		jmp		TestLoop					; Repeat the loop
		
TestExpressionDone:
		cmp 	stackAmount, 1				; Check the final amount of items on the stack
		jg		OperatorError				; If there is more than one value on the stack then there are not enough operators


;****************************************************************************
;* Get the operand values
;****************************************************************************
		mov		si, 0						; Initialize the table index
		call	NewLine						; 
GetLoop:
		cmp		neededTable[si], 1			; Check that the current value needs to be asked for
		jne		SkipGet						; Skip if not needed
		
		
		mov		ax, si						; move the table offset into al
		add		ax, 'A'						; Transform the offset into an ASCII character
		mov		currentOp, al				; Move the character into the output string
		mov		currentOp[1], EOS			; Append the EOS
		

		mov		di, offset labelNum1		; Print input prompt
		call	StrWrite					; 
		mov		di, offset currentOp		; Print the current character
		call	StrWrite					; 
		mov 	di, offset labelNum2		; 
		call	StrWrite					; 
		
		mov		di, offset inputNumStr		; Get the value for the operand
		mov		cx, maxLen					; 
		call	StrRead						; 
		call	AscToBin					; The value entered is now in ax
		jc		GetLoop						; check cf for invalid input
		mov		neededTable[si], 0			; Set the needed status for this operand to false
		
		mov		bx, si						; Move offset into bx
		add		bx, bx						; Double bx because valueTable uses words
		mov		valueTable[bx], ax			; move entered value into the value table
		
		call	NewLine						; 
SkipGet:
		inc		si							; Increment the table index
		cmp		si, 26
		jne		GetLoop						; Repeat the loop until the table has been completely gone through
		
;****************************************************************************
;* Evaluate the expression
;****************************************************************************
		mov		si, 0
EvalLoop:
		cmp		inputStr[si], EOS			; End the loop at the end of the string
		je		EvalLoopDone				;
		cmp		inputStr[si], 'A'			; Test that the character is an operand
		jb		DoOperator					;
		cmp		inputStr[si], 'Z'			;
		ja		DoOperator					;
	
DoOperand:
		mov 	bl, inputStr[si]			; move letter value into bx
		mov		bh, 0						; 
		sub		bx, 'A'						; Transform bx into an offset
		add		bx, bx						; Double bx because valueTable uses words
		push	valueTable[bx]				; Push the value associated with the operator	
		jmp		EvalDone					; Go to next character
	
DoOperator:
		pop		bx							; Pop second operand
		pop		ax							; Pop first operand
		cmp		inputStr[si], '+'			; 
		je		DoAdd						; 
		cmp		inputStr[si], '-'			; 
		je		DoSub						;
		cmp		inputStr[si], '*'			;
		je		DoMult						;
		cmp		inputStr[si], '/'			;
		je		DoDiv						;

DoAdd:
		add		ax, bx						; ax = ax + bx
		push	ax							; Push the result
		jmp		EvalDone					; Go to next character
DoSub:
		sub		ax, bx						; ax = ax - bx
		push	ax							; Push the result
		jmp		EvalDone					; Go to next character
DoMult:
		imul	bx							; ax = ax * bx (signed multiply, truncating at 16 bits)
		push	ax							; Push the result
		jmp		EvalDone					; Go to next character
DoDiv:
		cwd									; convert ax to a double and store it in dx:ax
		idiv	bx							; ax = dx:ax / bx (signed divide, ignoring remainder)
		push	ax							; Push the result
		jmp		EvalDone					; Go to next character
EvalDone:
		inc 	si							; Go to the next token in the expression
		jmp		EvalLoop					; Restart the loop

EvalLoopDone:
		pop		ax							; Pop the result to ax
		
;****************************************************************************
;* Display the result
;****************************************************************************
		mov 	di, offset labelResult		; Print result label
		call	StrWrite					; 
		
		mov 	di, offset result			; convert the result to ASCII
		mov		cx, 1						; Use a variable length string
		call	SBinToAscDec				;
		call	StrWrite					; Print the result
		call 	NewLine						; 

;****************************************************************************
;* Ask the user if the program should restart
;****************************************************************************
AskAgain:
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


