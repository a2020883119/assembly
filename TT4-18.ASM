;TT4-18.ASM
;循环接收字符，显示在屏幕上，小写字母字符变大写，其他不变，回车结束程序
;
CSEG     SEGMENT
         ASSUME CS:CSEG
START:   
AG: 
         CALL      GETCH                   ;获取字符
         CALL      ISEXIT                  ;是否接收到退出键
         CALL      ISLOW                   ;是否是小写字母
         JC        SHOW                    ;不是小写直接显示
         CALL      LOWTOUP                 ;大写变小写
SHOW:     
         CALL      PUTCH                   ;显示
         JMP       AG     

;功能：接收一个字符，不带回显
;入口参数：无
;出口参数：AL存放获取的字符
GETCH    PROC
         MOV       AH, 8                    ;不带回显接收字符
         INT       21H
         RET
GETCH    ENDP

;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH    PROC 
         PUSH      DX                       ;保存DX
         MOV       DL, AL                   ;要显示的字符就位
         MOV       AH, 2                    ;显示
         INT       21H
         POP       DX                       ;恢复DX
         RET 
PUTCH    ENDP

;功能：判断是不是小写字母
;入口参数：AL存放要检验的字符
;出口参数：CF中存放判断结果，CF是1表示无效，CF是0表示有效
ISLOW    PROC
         CMP       AL, 'a'                  ;是否大于'a'
         JB        ISLOW2                   ;无效,小于'0'结束，此时CF=1
         CMP       AL, 'z'+ 1               ;是否小于z后面一个字符
         JNB       ISLOW2
         CMC                                ;CF取反
ISLOW2:  RET
ISLOW    ENDP

;功能：判断是不是小写字母
;入口参数：AL存放要检验的字符
;出口参数：CF中存放判断结果，CF是1表示无效，CF是0表示有效
ISEXIT   PROC
         CMP       AL, 0DH                  ;是否是回车
         JNZ       ISEXIT1                  ;不是就返回主程序继续执行
         MOV       AH, 4CH                  ;是就退出程序
         INT       21H
ISEXIT1: RET
ISEXIT   ENDP

;功能：小写字母ASCII码变大写字母ASCII码
;入口参数：AL小写字母ASCII码
;出口参数：AL大写字母ASCII码
LOWTOUP  PROC
         AND       AL, 11011111B           ;第三位为零是大写字母ASCII码
         RET
LOWTOUP  ENDP


CSEG     ENDS
         END       START
