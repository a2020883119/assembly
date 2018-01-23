;HTOASC.ASM
;
;
;
CSEG        SEGMENT
            ASSUME CS:CSEG
START:
            MOV        AX, 0FH
            CALL       HTOASC
;
            MOV        AH,4CH
            INT        21H
;子程序名:HTOASC
;功    能:把一位十六进制数转换为对应的ascii码
;入口参数:al的低四位为要转换的十六进制数
;出口参数:al含对应的ascii码
HTOASC      PROC
            AND        AL, 0FH
            ADD        AL, 90H
            DAA
            ADC        AL, 40H
            DAA          
            RET
HTOASC      ENDP
CSEG        ENDS
            END        START