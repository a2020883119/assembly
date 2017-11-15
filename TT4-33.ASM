;TT4-33.ASM
;进制转换
;0-65535范围内正数加减乘除运算
CR = 0DH
LF = 0AH
BACKSPACE = 08H
BELLCH = 07H
ADDSIGN = '+'
SUBSIGN = '-'
DIVSIGN = '/'
SUBSIGN = '*'
DSEG           SEGMENT
MESS           DB 'INPUT :$'
MESS2          DB 'RESULT:$'
RESULT         DB 20 DUP ('$')
BUFFER         DB 5  DUP ('$')
DSEG           ENDS

CSEG           SEGMENT
               ASSUME DS:DSEG, CS:CSEG
START:
               MOV       AX, DSEG
               MOV       DS, AX 

               MOV       DX, OFFSET MESS
               CALL      DISPMESS
               CALL      GETEQUATION
               CALL      NEWLINE
               MOV       DX, OFFSET MESS2
               CALL      DISPMESS

               MOV       AH, 4CH
               INT       21H
;
;
;
GETEQUATION    PROC

GETEQUATION    ENDP

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

NEWLINE   PROC
          PUSH      AX                       ;AX压入栈中，为了保护AX的值
          PUSH      DX                       ;DX压入栈中，为了保护DX的值
          MOV       DL, 0DH                  ;   \r
          MOV       AH, 2                    ;调用显示中断
          INT       21H
          MOV       DL, 0AH                  ;   \n
          MOV       AH, 2                    ;调用显示中断
          INT       21H                
          POP       DX                       ;恢复进入子程序前的值
          POP       AX
          RET 
NEWLINE   ENDP

;功能:将五位十进制数ASCII码,转换为相应的二进制数
;入口参数:
;出口参数:

;功能：发出警报声音
;入口参数：无
;出口参数：无
BELL     PROC
         MOV       AL, BELLCH               ;07H响铃
         CALL      PUTCH                    ;调用显示字符功能
         RET       
BELL     ENDP




CSEG           ENDS
               END       START