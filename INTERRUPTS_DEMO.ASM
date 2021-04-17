TITLE	Program #7 - IEEE Floating Point Number Converter
;****************************************************************************
;* Title:	Program #7 - IEEE Floating Point Number Converter				*
;* Author:	Nathan Woodruff													*
;* Date:	11/14/2018														*
;* Purpose:	Accepts an 8 digit hexadecimal string representing an IEEE 		*
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
; set video mode to text 80 x 25
		mov		ah, 00h
		mov 	al, 03h
		int		10h
		
;set cursor to column 40 row 10
		mov		ah, 02h
		mov		bh, 00h
		mov		dh, 10
		mov		dl, 40
		int		10h
		
; write smiley faces
		mov		ah, 09h
		mov		al, 01h
		mov		cx, 11
		mov		bh, 0
		mov		bl, 09h
		int		10h

; set video mode
		mov		ah, 00h
		mov		al, 13h
		int		10h
		
; write to a pixel
		mov		ah, 0Ch
		mov		bh, 0
		mov		dx, 50
		mov		cx, 100
		mov		al, 6
		int		10h

		
		
		
Done:
		mov 	ah, 04Ch				; DOS Function: Exit program
		mov 	al, exCode				; Return exit code value
		int		21h						; Call DOS, Terminate Program
				
		END		MainEntry				; End of program / Entry point