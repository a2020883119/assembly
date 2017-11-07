;TT4-27.ASM
;从F000:0000H开始个200个字节作为无符号整数，求他们的和，并用十进制在屏幕显示出来
;此程序无法直接运行但是可以调试运行，第二个了。。。
;
DSEG        SEGMENT
DSEG        ENDS

CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            
            MOV       AX, 0F000H
            MOV       DS, AX

            MOV       CX, 200

            XOR       AX, AX
            MOV       SI, 0
AG:
            ADD       AX, [SI]
            INC       SI
            LOOP      AG

            CALL      AXTODA

            MOV       AH, 4CH
            INT       21H

;十六位二进制数用十进制ASCII码显示出来
;入口参数：AX存放十六进制数
;出口参数：无
AXTODA     PROC
           PUSH       DX                       ;存放余数
           PUSH       CX                       ;计数
           PUSH       AX                       ;存值
           PUSH       BX                       ;除数

           MOV        BX, 10                   ;除数
           MOV        CX, 0                    ;计数器清零
           XOR        DX, DX
DECLOOP: 
           DIV        BX                       ;除
           PUSH       DX                       ;保存余数到堆栈
           XOR        DX, DX
           INC        CX                       ;计数器加一
           CMP        AX, 0                    ;被除数为零异常处理，循环出口
           JZ         DECEND                   ;跳出处理循环，进入显示循环
           JMP        DECLOOP                   ;继续处理循环
         

DECEND:  
           POP        AX                       ;从堆栈中取出余数
           ADD        AX, 30H
           CALL       PUTCH                     ;显示
           LOOP       DECEND                    ;循环继续
           
           POP        BX
           POP        AX
           POP        CX
           POP        DX
           RET
AXTODA     ENDP

;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH      PROC 
           PUSH    AX
           PUSH    DX                         ;保存DX
           MOV     DL, AL                     ;要显示的字符就位
           MOV     AH, 2                      ;显示
           INT     21H
           POP     DX                         ;恢复DX
           POP     AX
           RET  
PUTCH      ENDP

CSEG        ENDS
            END       START