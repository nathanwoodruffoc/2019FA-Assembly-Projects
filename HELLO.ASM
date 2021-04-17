TITLE "Hello World"
;****************************************************************************
;* Title:   Hello World                                                     *
;* Author:  Don Leftwich                                                    *
;* Date:    9/15/2010                                                       *
;* Purpose: This program prints a welcome message.                          *
;****************************************************************************
;* Grading: Correctness   ______                                            *
;*          Style         ______                                            *
;*          Documentation ______    Total ______                            *
;****************************************************************************

        .MODEL  small
        STACK   256

;****************************************************************************
;* Equates Section                                                          *
;****************************************************************************

EOS     EQU     0                       ; End of string
maxLen  EQU     40                      ; Maximum entry string length

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0                                       ; DOS error code
hello    db     'Hello World!',EOS                      ; Prompt for 1st num
buffer   db     maxLen dup (?)                          ; Input/Output buffer

;****************************************************************************
;* Code Section                                                             *
;****************************************************************************
        .CODE

;****************************************************************************
;* External procedures from STRINGS.OBJ & STRIO.OBJ                         *
;****************************************************************************

        EXTRN   StrLength:proc, StrRead:proc
        EXTRN   StrWrite:proc, NewLine:proc

;****************************************************************************
;* External procedures from BINASC.OBJ                                      *
;****************************************************************************

        EXTRN   BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
        EXTRN   BinToAscBin:proc, AscToBin:proc

;****************************************************************************
;* Main entry point of program.                                             *
;****************************************************************************
Start:  
        mov     ax, @data               ; Initialize DS to address
        mov     ds, ax                  ;  of data segment
        mov     es, ax                  ; Make es = ds

;****************************************************************************
;* Start of Program                                                         *
;****************************************************************************

        call    NewLine                 ; Start new display line
        mov     di, OFFSET hello        ; Display hello world         
        call    StrWrite                ;   message     
        call    NewLine

        mov     di, OFFSET buffer       ; Buffer will get user's entry
        mov     cx, maxLen              ; Maximum string length
        call    StrRead                 ; Get entry from keyboard

        call    NewLine
        call    StrWrite
       
;****************************************************************************
;* End of Program.                                                          *
;****************************************************************************
Done:
        call    NewLine

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point
