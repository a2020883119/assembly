;TT4-24.ASM
;递归An = An_1 + 3 * An_2   A1 = 0, A2 = 1,
;A3 = 1, A4 = 4, A5 = 7,
CSEG        SEGMENT
            ASSUME CS:CSEG
START:     
            
            MOV     AX, 5
            XOR     DX, DX
            CALL    RECURSION
            
            MOV     AH, 4CH
            INT     21H
;功能：递归An = An_1 + 3 * An_2
;入口参数：AX放要求的数
;出口参数：DX:AX放结果
;
RECURSION   PROC
            PUSH    CX
            PUSH    BX
            MOV     CX, 3
            CMP     DX, 0                  ;高十六位
            JNZ     THREE
            CMP     AX, 1
            JZ      ZERO
            CMP     AX, 2
            JZ      ONE
            CMP     AX, 3
            JGE     THREE
ZERO:       
            MOV     AX, 0
            XOR     DX, DX
            JMP     OVER
            RET
ONE:        
            MOV     AX, 1
            XOR     DX, DX
            JMP     OVER
            RET     
THREE:      DEC     AX
            MOV     BX, AX
            CALL    RECURSION
            PUSH    DX
            PUSH    AX
            MOV     AX, BX
            DEC     AX
            CALL    RECURSION
            MUL     CX
            POP     CX
            ADD     AX, CX
            POP     CX
            ADC     DX, CX
OVER:
            POP     BX
            POP     CX
            RET
RECURSION   ENDP
CSEG        ENDS
            END     START