;TT5-28.ASM
;清屏程序
CSEG        SEGMENT
            ASSUME CS:CSEG
START:
;            
            MOV    BH, 0      ;置光标到开头
            MOV    DH, 0      ;左上角
            MOV    DL, 0
            MOV    AH, 2
            INT    10H
;
            MOV    AL, 0      ;清屏
            MOV    BH, 07H    ;颜色
            MOV    CH, 0      ;左上角
            MOV    CL, 0
            MOV    DH, 43     ;右下角
            MOV    DL, 80
            MOV    AH, 6
            INT    10H

            MOV    AH, 4CH    ;结束
            INT    21H
           
CSEG        ENDS
            END    START