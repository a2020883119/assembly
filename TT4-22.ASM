;TT4-22.ASM
;从键盘输入一个字符串，然后下一行显示字符串中的非字母字符，下下一行显示字母字符，顺序颠倒
STRLENGTH = 128
DSEG        SEGMENT
BUFFER1     DB STRLENGTH                     ;缓冲区大小
BUFFER2     DB ?                             ;存放接收到的字符数
BUFFER3     DB STRLENGTH DUP (?)             ;存放接收到的字符串
MESS1       DB 'PLEASE INPUT STRING:', '$'   ;存放提示语：输入
MESS2       DB '   LTETTER OVERTURN:', '$'   ;存放提示语：输出
MESS3       DB '          NO LETTER:', '$'   ;存放提示语：输出
DSEG        ENDS
;
CSEG        SEGMENT 
            ASSUME DS:DSEG, CS:CSEG
START:     
            MOV     AX, DSEG                 ;初始化
            MOV     DS, AX

            MOV     DX, OFFSET MESS1         ;显示提示
            CALL    DISPMESS
   
            MOV     DX, OFFSET BUFFER1       ;接收字符串
            CALL    GETSTR

            CALL    NEWLINE                  ;换行，显示提示
            MOV     DX, OFFSET MESS2
            CALL    DISPMESS

            MOV     SI, OFFSET BUFFER3       ;SI指向字符串开头
            XOR     CX, CX                   ;得到循环次数即字符串长度
            MOV     CL, BUFFER2
;去字母显示字符串
NOLETTER:   MOV     AL, [SI]                 ;取值
            CALL    ISLETTER                  ;判断
            JNC     NOTSHOW                   ;CF=0不显示
            CALL    PUTCH                     ;显示一个字符
NOTSHOW:    
            INC     SI                        ;指针更新，指向下一个
            LOOP    NOLETTER                  ;循环

            CALL    NEWLINE                   ;换行
            MOV     DX, OFFSET MESS3          ;显示提示字符串
            CALL    DISPMESS
            
            MOV     SI, OFFSET BUFFER3        ;SI指向字符串开头
            XOR     CX, CX                    ;循环次数即字符串长度
            MOV     CL, BUFFER2               ;
            ADD     SI, CX                    ;SI指向字符串末尾
            DEC     SI
;只显示字母并反转
OVLETTER:   MOV     AL, [SI]                  ;取值
            CALL    ISLETTER                   ;判断
            JC     NOSHOW                      ;CF=1,跳走
            CALL    PUTCH                      ;显示
NOSHOW:    
            DEC     SI                         ;更新指针，指向前一个
            LOOP    OVLETTER                   ;循环

            CALL    NEWLINE                    ;换行
            JMP     START
            

            
;功能：判断是不是字母公
;入口参数：AL存放要检验的字符
;出口参数：CF = 0, TRUE, CF=1, FALSE
;
ISLETTER    PROC
            PUSH        AX
            AND         AL, 11011111B        ;小写变大写
            CMP         AL, 'A'
            JC          NEXT
            CMP         AL, 'Z' + 1
            CMC
NEXT:
            POP         AX
            RET
ISLETTER    ENDP 
;接收一串字符
;DS:DX指向第三缓冲区
;接收到的字符数量保存在第二缓冲区
GETSTR      PROC
            PUSH    AX
            MOV     AH, 0AH                   ;获取字符串
            INT     21H
            POP     AX
            RET
GETSTR      ENDP
;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH       PROC 
            PUSH    DX                      ;保存DX
            PUSH    AX
            MOV     DL, AL                  ;要显示的字符就位
            MOV     AH, 2                   ;显示
            INT     21H
            POP     DX                      ;恢复DX
            POP     AX
            RET 
PUTCH       ENDP
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE     PROC
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
NEWLINE     ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS    PROC
            PUSH     AX
            MOV      AH, 9                    ;调用显示字符串中断
            INT      21H
            POP      AX
            RET
DISPMESS    ENDP
;
CSEG        ENDS
            END     START