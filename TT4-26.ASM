;TT4-26.ASM
;把小于65535的素数打印在屏幕上
;调试可以，运行死活不行，我不知道为什么。。。。。
DSEG       SEGMENT
DSEG       ENDS
CSEG       SEGMENT
           ASSUME CS:CSEG
START:
           MOV       AX, DSEG
           MOV       DS, AX

           XOR       AX, AX
NEXT:
   
           CMP       AX, 1024            ;范围设置
           JZ        OVER
           INC       AX                ;下一个数
           CALL      IFPRIME           ;是否是素数
           JC        NEXT              ;不是素数
           CALL      AXTODA            ;是素数并显示
           CALL      PUTBLANK          ;空格
           JMP       NEXT              ;下一个
           

                      
OVER:
           MOV       AH, 4CH
           INT       21H
;
;是否是素数
;入口参数：AX存放要判断的数
;出口参数：CF = 1 不是素数，CF = 0 是素数
IFPRIME    PROC
           PUSH      DX
           PUSH      AX

           MOV       BX, AX           ;设置AX
AG:
           PUSH      AX               ;保存AX
           DEC       BX               ;准备除数
           CMP       BX, 1            ;有效退出指令
           JZ        OVE
		   CMP       BX, 0            ;有效退出指令
           JZ        OVE
           XOR       DX, DX           ;清空除数的高十六位
           DIV       BX
           POP       AX               ;恢复AX
           CMP       DX, 0            ;判断是否被整除，
           JZ        CMCF             ;不是素数
           JMP       AG

CMCF:      
           CMC                         ;不是素数设置CF = 1
           PUSH      AX                ;抵消下面的POP AX
OVE:        
           POP       AX                
           POP       AX
           POP       DX
           RET
IFPRIME    ENDP
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
;显示一个KONGGE
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTBLANK   PROC 
           PUSH    AX
           PUSH    DX                         ;保存DX
           MOV     DL, 20H                    ;要显示的字符就位
           MOV     AH, 2                      ;显示
           INT     21H
           POP     DX                         ;恢复DX
           POP     AX
           RET  
PUTBLANK   ENDP

CSEG       ENDS
           END       START