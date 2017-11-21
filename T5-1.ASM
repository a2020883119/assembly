;T5-1.ASM
;检测到按下shif键,推出程序
L_SHIFT = 00000010B          ;左shift
R_SHIFT = 00000001B          ;右shift
CSEG    SEGMENT
        ASSUME CS:CSEG
START:
        MOV    AH, 2         ;取变换键状态字节
        INT    16H
        TEST   AL, L_SHIFT + R_SHIFT ;
        JNZ    OVER          ;不为零时确定shift键被按下
        MOV    AH, 1         ;判断缓冲区中是否有按键可取
        INT    16H           ;
        JZ     START         ;缓冲区没有按键可取
        MOV    AH, 0         ;取出缓冲区中的按键
        INT    16H          
        MOV    DL, AL        ;显示
        MOV    AH, 6
        INT    21H
        JMP    START
;
OVER:
        MOV    AH, 4CH       ;结束
        INT    21H
;
CSEG    ENDS
        END    START