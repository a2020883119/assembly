;TT4-19.ASM
;接收一串字符，然后逆向输出在屏幕上
;
BUFFERLENGTH = 128
DSEG        SEGMENT
BUFFER1     DB BUFFERLENGTH                 ;第一缓冲区 存放第三缓冲区的大小
BUFFER2     DB ?                            ;第二缓冲区 存放接收到的字节数
BUFFER3     DB BUFFERLENGTH DUP (?)         ;第三缓冲区 存放接收到的字节
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV     AX, DSEG                ;初始化段值
            MOV     DS, AX

            MOV     DX, OFFSET BUFFER1      ;设置DS:DX为获取字符串做准备，指明缓冲区域
            CALL    GETSTR                  ;获取输入的字符串
            CALL    NEWLINE                 ;换行
            
            MOV     CL, BUFFER2             ;获得输入的字节数
            XOR     CH, CH                  ;清空高位，做循环计数器
            
            MOV     BX, OFFSET BUFFER3      ;DS:BX指向字符串存放地址
            ADD     BX, CX                  ;指向字符串最后一个字符的后一个字符
            DEC     BX                      ;指向字符串最后一个字符
AG:
            MOV     AL, [BX]                ;从后往前依次取字符，放在AL为PUTCH子程序准备入口参数
            CALL    PUTCH                   ;调用输出到屏幕
            DEC     BX                      ;指针前移
            LOOP    AG                      ;循环
            CALL    NEWLINE                 ;换行
            JMP     START
            

;接收一串字符
;DS:DX指向第三缓冲区
;接收到的字符数量保存在第二缓冲区
GETSTR      PROC
            PUSH    AX
            MOV     AH, 0AH
            INT     21H
            POP     AX
            RET
GETSTR      ENDP


;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH       PROC 
            PUSH    DX                      ;保存DX
            MOV     DL, AL                  ;要显示的字符就位
            MOV     AH, 2                   ;显示
            INT     21H
            POP     DX                      ;恢复DX
            RET 
PUTCH       ENDP
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE    PROC
           PUSH   AX                        ;AX压入栈中，为了保护AX的值
           PUSH   DX                        ;DX压入栈中，为了保护DX的值
           MOV    DL, 0DH                   ;   \r
           MOV    AH, 2                     ;调用显示中断
           INT    21H 
           MOV    DL, 0AH                   ;   \n
           MOV    AH, 2                     ;调用显示中断
           INT    21H                 
           POP    DX                        ;恢复进入子程序前的值
           POP    AX
           RET 
NEWLINE    ENDP

CSEG        ENDS
            END     START
 





