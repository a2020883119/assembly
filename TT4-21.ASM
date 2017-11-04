;TT4-21.ASM
;接收一串字符，统计出其中非数字字符的个数
;
STRLENGTH = 128
DSEG        SEGMENT
BUFFER1     DB STRLENGTH                     ;缓冲区大小
BUFFER2     DB ?                             ;存放接收到的字符数
BUFFER3     DB STRLENGTH DUP (?)             ;存放接收到的字符串
MESS1       DB 'PLEASE INPUT STRING :', '$'  ;存放提示语：输入
MESS2       DB 'NUMBER OF NOT NUMBER:', '$'  ;存放提示语：输出
DSEG        ENDS
;
;
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            MOV      AX, DSEG                ;初始化
            MOV      DS, AX

            MOV      DX, OFFSET MESS1        ;输出提示语1，DS:DX指向提示字符串缓冲区
            CALL     DISPMESS
 
            MOV      DX, OFFSET BUFFER1      ;获取输入字符串，DS:DX指向接收缓冲区
            CALL     GETSTR

            XOR      CX, CX                  ;计数器清空
            MOV      CL, BUFFER2             ;取接收到的字符串数量
            MOV      SI, OFFSET BUFFER3      ;SI指向接收的字符串开头
            DEC      SI                      ;
            XOR      BX, BX                  ;清空BX
            MOV      BL, BUFFER2             ;取接收到的字符串数量
            ADD      SI, BX                  ;SI指向接收到的字符串末尾
            XOR      BX, BX                  ;清空BX

            CALL     NEWLINE                 ;换行
            MOV      DX, OFFSET MESS2        ;DS:DX指向提示语2
            CALL     DISPMESS                ;显示提示语2
AG:
            MOV      AL, [SI]                ;取值
            CALL     ISNUMBER                ;是否是数字
            JC       NEXT                     ;不是跳
            INC      BL                      ;是，计数器加一
NEXT:       
            DEC      SI                       ;校准指针
            LOOP     AG                       ;循环

            MOV      AL, BUFFER2              ;取取接收到的字符串数量
            SUB      AL, BL                   ;减去数字字符的数量
            CALL     BTDTSHOW                 ;显示非字符数量
            CALL     NEWLINE                  ;换行
            JMP      START                    ;再来一次
            
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
;功能：检测是否是数字
;入口参数：AL
;出口参数:CF=1 FALSE, CF=0 TRUE
ISNUMBER   PROC
           CMP     AL, '0'                  ;<'0' CF = TRUE ,>'0' CF = FALSE
           JB      ISNUMBER1
           CMP     AL, '9'                  ;<'9' CF = TRUE ,>'9' CF = FALSE
           CMC                              ;CF取反
ISNUMBER1:
           RET
ISNUMBER   ENDP
;功能：八位二进制数转换为十进制数字ASCII表示，并显示，
;入口参数：AL存放数值
;出口参数：无
;需要PUTCH子程序支持
BTDTSHOW   PROC
         PUSH       DX
         PUSH       CX
         PUSH       AX
         MOV        DL, 10                  ;除数设置
         MOV        CX, 0                   ;计数器清零
         XOR        AH, AH
DECLOOP: 
         DIV        DL                      ;除
         PUSH       AX                      ;保存余数到堆栈
         INC        CX                      ;计数器加一
         XOR        AH, AH                  ;清空余数，不影响下次操作
         CMP        AL, 0                   ;被除数为零异常处理，循环出口
         JZ         DECEND                  ;跳出处理循环，进入显示循环
         JMP        DECLOOP                 ;继续处理循环
DECEND:  
         POP        AX                      ;从堆栈中取出余数
         MOV        AL, AH                  ;设置下标
         ADD        AL, '0'                 ;取值
         CALL       PUTCH                   ;显示
         LOOP       DECEND                  ;循环继续
         POP        AX
         POP        CX
         POP        DX
RET
BTDTSHOW   ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS   PROC
           PUSH     AX
           MOV      AH, 9                    ;调用显示字符串中断
           INT      21H
           POP      AX
           RET
DISPMESS   ENDP
CSEG        ENDS
            END      START