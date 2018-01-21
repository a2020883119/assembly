;T6-1.ASM
;接收一个字符串,然后抽去其中的空格,最后按相反顺序显示它
MAXLEN      = 64                                   ;字符串接收区大小
SPACE       = ' '                                  ;空格
CR          = 0DH                                  ;回车
LF          = 0AH                                  ;换行
;
DSEG        SEGMENT
BUFFER      DB MAXLEN + 1, 0, MAXLEN + 1 DUP (0)   ;缓冲区设置
STRING      DB MAXLEN + 3 DUP (0)                  ;保存处理后的字符串
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG, ES:DSEG
START:
            MOV    AX, DSEG                        ;段值初始化
            MOV    DS, AX
            MOV    ES, AX
;
            MOV    DX, OFFSET BUFFER               ;接收字符串
            MOV    AH, 10
            INT    21H
;
            XOR    CH, CH                          ;字符串长度判断,没输入直接结束
            MOV    CL, BUFFER + 1
            JCXZ   OK
;
            CLD                                     ;设置方向,增
            MOV    SI, OFFSET BUFFER + 2            ;指向字符串接收缓冲区
            MOV    DI, OFFSET STRING                ;指向存放字符串的缓冲区
            XOR    AL, AL                           ;结尾
            STOSB                                   ;存入结束符
            MOV    AL, SPACE                        ;空格
PP1:
            XCHG   SI, DI                           ;SI指向接收到的字符串,DI指向修改后的字符串的缓冲区
            REPZ   SCASB                            ;找到非空格字符,找到停
            XCHG   SI, DI                           ;
            JCXZ   PP3                               ;结束
            DEC    SI                                ;指向非空格处
            INC    CX                                ;循环次数加一
PP2:
            CMP    BYTE PTR [SI], SPACE             ;是否为空格
            JZ     PP1                               ;是,跳
            MOVSB                                    ;不是,移动
            LOOP   PP2                               ;循环
PP3:
            MOV    AL, CR                            ;回车
            STOSB  
            MOV    AL, LF                            ;换行
            MOV    [DI], AL
            STD                                      ;方向递减
            MOV    SI, DI
PP4:
            LODSB                                   ;反方向加载一个字节
            OR     AL, AL                           ;是否为零
            JZ     OK                                ;为零结束
            MOV    DL, AL                           ;显示
            MOV    AH, 2
            INT    21H
            JMP    PP4                               ;循环
OK:
            MOV    AH, 4CH
            INT    21H

CSEG        ENDS
            END    START
 
