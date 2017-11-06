;TT4-24.ASM
;递归An = An_1 + 3 * An_2   A1 = 0, A2 = 1,
;A3 = 1, A4 = 4, A5 = 7,
CSEG        SEGMENT
            ASSUME CS:CSEG
START:     
            
            MOV     AX, 5                 ;低十六位要求的数
            XOR     DX, DX                ;高十六位
            CALL    RECURSION
            
            MOV     AH, 4CH
            INT     21H
;功能：递归An = An_1 + 3 * An_2   A1 = 0, A2 = 1,
;入口参数：AX放要求的数
;出口参数：DX:AX放结果
;递归诀窍，搞好函数本身即可，递归只是一个用法而已
RECURSION   PROC
            PUSH    CX
            PUSH    BX
            MOV     CX, 3
            CMP     DX, 0                  ;高十六位
            JNZ     THREE                   ;高十六位不为零肯定大于3
            CMP     AX, 1                  ;等于1？
            JZ      ZERO                    ;等于就跳
            CMP     AX, 2                  ;等于2？
            JZ      ONE                     ;等于就跳
            CMP     AX, 3                  ;大于等于三
            JGE     THREE                  ;大于等于三就跳
;A1
ZERO:       
            MOV     AX, 0                  ;A1 = 0
            XOR     DX, DX
            JMP     OVER
            RET
;A2
ONE:        
            MOV     AX, 1                  ;A2 = 1
            XOR     DX, DX
            JMP     OVER
            RET     
;An    n>=3
THREE:      DEC     AX                     ;An_1
            MOV     BX, AX                 ;备份AX
            CALL    RECURSION              ;递归
            PUSH    DX                     ;保存求出的值
            PUSH    AX
            MOV     AX, BX                 ;恢复AX
            DEC     AX                     ;An_2
            CALL    RECURSION
            MUL     CX
            POP     CX                     ;恢复上一个值AX
            ADD     AX, CX                 ;低十六位相加
            POP     CX                     ;恢复上一个值DX
            ADC     DX, CX                 ;高十六位带进位加法
OVER:
            POP     BX
            POP     CX
            RET
RECURSION   ENDP
CSEG        ENDS
            END     START