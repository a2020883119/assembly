;TT5-34.ASM
;调整bios中的中断程序,使按下的大写字母全部转变为对应小写字母
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:CSEG

UPTOLOW:
;
            ; PUSH   CS
            ; POP    DS
            ; MOV    BX, ADDRESS + 2
            ; MOV    ES, BX
            ; MOV    BX, ADDRESS
            ; MOV    AX, OLD16H
            ; MOV    WORD PTR ES : [BX], AX
            ; MOV    AX, OLD16H + 2
            ; MOV    WORD PTR ES : [BX + 2], AX
; ;
            
            ; CMP    AH, 0
            ; JZ     NEXT2
            ; INT    21H
            ; JMP    NEXT
; ;
; NEXT2:
; ;
            ; INT    21H
; ;
            ; CMP    AL, 'A'
            ; JB     NEXT
            ; CMP    AL, 'Z'
            ; JA     NEXT
            ; AND    AL, 11011111B
; ;
; NEXT:
; ;
            ; PUSH   AX
            ; PUSHF
; ;
            ; MOV    AX, OFFSET UPTOLOW
            ; MOV    WORD PTR ES : [BX], AX
            ; MOV    AX, DS
            ; MOV    WORD PTR ES : [BX + 2], AX
            ; POPF
            ; POP    AX
;
            MOV    AL, 'A'
            IRET



;----------------------------------------------------------

ADDRESS     DW 4 * 22, 0
OLD16H      DW ?, ?

START:
            PUSH   CS
            POP    DS
            MOV    BX, ADDRESS + 2
            MOV    ES, BX
            MOV    BX, ADDRESS
;
            MOV    AX, ES : [BX]
            MOV    WORD PTR OLD16H, AX
            MOV    AX, ES : [BX + 2]
            xchg    WORD PTR OLD16H + 2, AX
;
            MOV    AX, OFFSET UPTOLOW
            xchg    WORD PTR ES : [BX], AX
            MOV    ES : [BX + 2], DS
;
            MOV    AH, 0
            INT    16H
;
            MOV    DL, AL
            MOV    AH, 2
            INT    21H
;
            MOV    BX, ADDRESS + 2
            MOV    ES, BX
            MOV    BX, ADDRESS
            MOV    AX, OLD16H    
            MOV    ES : [BX], AX
            MOV    AX, OLD16H + 2
            MOV    ES : [BX + 2], AX
;
            MOV    AH, 4CH
            INT    21H

CSEG        ENDS
            END    START
