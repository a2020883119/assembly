;TT4-28.ASM
;从F000:0000H开始，1024字节统计正数，负数，零的个数并显示出来
;27 26 中的除法溢出问题找到了  首次除法高位均未清空
;输出顺序,负数,正数,零
;本次遇到的问题:
;1.loop叠加
;2.除法被除数高位首次除法未清零
DSEG          SEGMENT
DSEG          ENDS
CSEG          SEGMENT
              ASSUME CS:CSEG, DS:DSEG
START: 
              MOV       AX, DSEG
              MOV       DS, AX
 
              MOV       AX, 0F000H
              MOV       ES, AX
;统计数量
              MOV       SI, 0
              MOV       CX, 1024
              XOR       AX, AX              ;BX负数， DX正数，   DI 零
              XOR       BX, BX
              XOR       DX, DX
              XOR       DI, DI
AG:
              MOV       AL, ES : [SI]
              INC       SI
              CMP       AL, 0
              JZ        ZERO
              SHL       AL, 1
              JC        POSITIVE
              INC       BX
              JMP       NEXT
POSITIVE:
              INC       DX
              JMP       NEXT
ZERO:
              INC       SI
NEXT:
              LOOP      AG

              MOV       AX, BX
              CALL      ALTDA
              CALL      NEWLINE

              MOV       AX, DX
              CALL      ALTDA
              CALL      NEWLINE

              MOV       AX, DI
              CALL      ALTDA
              CALL      NEWLINE

              MOV       AH, 4CH
              INT       21H


;显示输出
;用十进制数显示AL中的值
;入口参数:al
;出口参数:无
;不会修改任何寄存器
ALTDA         PROC

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
ALTDA         ENDP
;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH         PROC 
              PUSH    AX
              PUSH    DX                         ;保存DX
              MOV     DL, AL                     ;要显示的字符就位
              MOV     AH, 2                      ;显示
              INT     21H
              POP     DX                         ;恢复DX
              POP     AX
              RET  
PUTCH         ENDP              
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
CSEG          ENDS
              END       START