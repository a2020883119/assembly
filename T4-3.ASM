;T4-3.ASM
;接收并一个字符，并显示出来
;
CSEG        SEGMENT
            ASSUME CS:CSEG

START:      MOV    AH, 1          ;读字符功能调用
            INT    21H

            CALL   NEWLINE        ;换行 回车  输出
            MOV    BL, AL
            MOV    CX, 8          ;循环次数

NEXT:       SHL    BL, 1          ;左移，最高位移到CF中
            MOV    DL, 30H        ;‘0’
            ADC    DL, 0          ;加上CF值

            MOV    AH, 2          ;调用显示功能
            INT    21H

            LOOP   NEXT           ;循环
            MOV    DL, 'B'        ;最后输出‘B’

            MOV    AH, 2          ;调用显示功能
            INT    21H            ;

            MOV    AH, 4CH        ;结束
            INT    21H


NEWLINE     PROC                  ;输出换行和回车
            PUSH   AX             ;保存
            PUSH   DX

            MOV    DL, 0DH       ;回车 \r

            MOV    AH, 2         ;调用显示功能
            INT    21H

            MOV    DL, 0AH       ;换行 \n

            MOV    AH, 2         ;调用显示功能
            INT    21H

            POP    DX
            POP    AX
            RET

NEWLINE     ENDP
;
CSEG        ENDS
            END    START