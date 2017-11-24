;TT5-23.ASM
;显示打印接口的当前状态
;
CSEG        SEGMENT
            ASSUME CS:CSEG
START:
            MOV    AH, 2      ;获取打印机状态
            INT    17H

            MOV    CX, 8      ;循环次数
AG:
            XOR    AL, AL     ;清空
            ROL    AX, 1      ;ah存放打印机状态,取最高位
            ADD    AL, 30H    ;转换为ascii码
            
            PUSH   AX         ;备份ax
            MOV    DL, AL     ;显示到屏幕
            MOV    AH, 2
            INT    21H
            POP    AX         ;恢复ax
            LOOP   AG

            MOV    AH,4CH
            INT    21H

CSEG        ENDS
            END    START            