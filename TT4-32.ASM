;TT4-32.ASM
;进制转换
DSEG     SEGMENT
TABLE    DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
            'A', 'B', 'C', 'D', 'E', 'F'     ;取值映射表
MESS1    DB 'INPUT:', '$'                    ;提示输入字符串
MESS2    DB '  HEX:', '$'                    ;提示十六进制字符串
MESS3    DB '  DEC:', '$'                    ;提示十进制字符串
MESS4    DB '  OCT:', '$'                    ;提示八进制字符串
MESS5    DB '  BIN:', '$'                    ;提示二进制字符串
DSEG     ENDS
;
CSEG     SEGMENT
         ASSUME DS:DSEG, CS:CSEG
START:   
         MOV        AX, DSEG                 ;初始化
         MOV        DS, AX
         
         MOV        DX, OFFSET MESS1         ;DS:DX指向输出提示语
         CALL       DISPMESS                 ;显示提示
         CALL       GETCH                    ;获取输入字符
         CALL       NEWLINE                  ;换行

;
         MOV        SI, OFFSET TABLE         ;SI指向映射表
;
         XOR        AH, AH                   ;AH清空，不影响后面的操作
         PUSH       AX                       ;保存输入值
;十六进制处理
         MOV        DX, OFFSET MESS2         ;DS:DX指向输出提示语
         CALL       DISPMESS                 ;显示提示
         MOV        CL, 4                    ;移位位数
         PUSH       AX                       ;保存AX,开始处理高四位，
         SHR        AL, CL                   ;移位，得到高四位
         XOR        BX, BX                   ;清空BX
         MOV        BL, AL                   ;得到数组下标
         MOV        AL, [BX + SI]            ;取值
         CALL       PUTCH                     ;显示
         
         POP        AX                       ;恢复输入值，开始处理第四位
         AND        AL, 00001111B            ;得到低四位
         MOV        BL, AL                   ;获取下标
         MOV        AL, [BX + SI]            ;取值
         CALL       PUTCH                     ;显示
         POP        AX                        ;恢复输入值
         CALL       NEWLINE                   ;换行
;十进制处理
         PUSH       AX                       ;保存输入值，为了以后的处理
         MOV        DX, OFFSET MESS3         ;DS:DX指向输出提示语
         CALL       DISPMESS                 ;显示提示
         MOV        DL, 10                   ;显示提示
         MOV        CX, 0                    ;计数器清零
DECLOOP: 
         DIV        DL                       ;除
         PUSH       AX                       ;保存余数到堆栈
         INC        CX                       ;计数器加一
         XOR        AH, AH                   ;清空余数，不影响下次操作
         CMP        AL, 0                    ;被除数为零异常处理，循环出口
         JZ         DECEND                   ;跳出处理循环，进入显示循环
         JMP        DECLOOP                   ;继续处理循环
         

DECEND:  
         POP        AX                       ;从堆栈中取出余数
         XOR        BX, BX                   ;清空
         MOV        BL, AH                   ;设置下标
         MOV        AL, [BX + SI]            ;取值
         CALL       PUTCH                     ;显示
         LOOP       DECEND                    ;循环继续

;八进制处理
         POP        AX                        ;恢复输入值
         CALL       NEWLINE                   ;换行
         PUSH       AX                        ;保存输入值，为了以后的处理
         MOV        DX, OFFSET MESS4          ;DS:DX指向输出提示语
         CALL       DISPMESS                  ;显示提示
         MOV        DL, 8                     ;显示提示
         MOV        CX, 0                     ;计数器清零
OCTLOOP:
         DIV        DL                        ;除
         PUSH       AX                        ;保存余数到堆栈
         INC        CX                        ;计数器加一
         XOR        AH, AH                    ;清空余数，不影响下次操作
         CMP        AL, 0                     ;被除数为零异常处理，循环出口
         JZ         OCTEND                     ;跳出处理循环，进入显示循环
         JMP        OCTLOOP                    ;继续处理循环
        
OCTEND:  POP        AX                        ;从堆栈中取出余数
         XOR        BX, BX                    ;清空
         MOV        BL, AH                    ;设置下标
         MOV        AL, [BX + SI]             ;取值
         CALL       PUTCH                      ;显示
         LOOP       OCTEND                     ;循环继续



         POP        AX                         ;恢复输入值
         CALL       NEWLINE                    ;换行
         MOV        DX, OFFSET MESS5           ;DS:DX指向输出提示语
         CALL       DISPMESS                   ;显示提示
         MOV        CX, 8                      ;设置循环次数
;二进制处理          
BINLOOP:
         XOR        BX, BX                     ;清空
         SHL        AL, 1                      ;最高位到CF中
         ADC        BX, 0                      ;取CF的值，也就是下标值
         PUSH       AX                         ;保存AX
         MOV        AL, [BX + SI]              ;取值
         CALL       PUTCH                      ;显示
         POP        AX                         ;恢复AX
         LOOP       BINLOOP                    ;循环

         CALL       NEWLINE                    ;换行

         JMP        START


;功能：接收一个字符，带回显
;入口参数：无
;出口参数：AL存放获取的字符
GETCH    PROC
         MOV        AH, 1                      ;带回显接收字符
         INT        21H
         RET
GETCH    ENDP
;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH       PROC 
            PUSH    DX                         ;保存DX
            MOV     DL, AL                     ;要显示的字符就位
            MOV     AH, 2                      ;显示
            INT     21H
            POP     DX                         ;恢复DX
            RET  
PUTCH       ENDP
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE    PROC
           PUSH     AX                         ;AX压入栈中，为了保护AX的值
           PUSH     DX                         ;DX压入栈中，为了保护DX的值
           MOV      DL, 0DH                    ;   \r
           MOV      AH, 2                      ;调用显示中断
           INT      21H 
           MOV      DL, 0AH                    ;   \n
           MOV      AH, 2                      ;调用显示中断
           INT      21H                 
           POP      DX                         ;恢复进入子程序前的值
           POP      AX
           RET 
NEWLINE    ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS   PROC
           PUSH     AX
           MOV      AH, 9                      ;调用显示字符串中断
           INT      21H
           POP      AX
           RET
DISPMESS   ENDP


CSEG       ENDS
           END      START