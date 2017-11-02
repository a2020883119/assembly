;TT4-16.ASM
;循环显示0-9，到十三个换行
;
DSEG       SEGMENT
DSEG       ENDS
CSEG       SEGMENT
           ASSUME CS:CSEG, DS:DSEG
START:     MOV    AL, '0'                  ;AL存放输出字符
           MOV    CL, 0                    ;CL存放每行个数
;
AG:        CALL   PUTCH                    ;输出字符

;
           INC    AL                       ;输出的数字加一
           CMP    AL, '9'                  ;是否超出范围
           JNG    OK                       ;没有超出范围，跳过异常处理
           MOV    AL, '0'                  ;值超出范围，重新设置
OK:
           INC    CL                       ;增加此行的数字数量
           CMP    CL, 13                   ;是否超出范围
           JNG    NEXT                     ;没有超出范围，跳过异常处理
           MOV    CL, 0                    ;值超出范围，重新设置
           CALL   NEWLINE                  ;换行
           JMP    AG
NEXT:      
           CALL   PUTBLANK                 ;输出空格
           JMP    AG

           MOV    AH, 4CH
           INT    21H

;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH      PROC 
           PUSH   AX
           PUSH   DX                       ;保存DX
           MOV    DL, AL                   ;要显示的字符就位
           MOV    AH, 2                    ;显示
           INT    21H
           POP    DX                       ;恢复DX
           POP    AX
           RET 
PUTCH      ENDP
;显示一个空格
;入口参数：无
;出口参数：无
PUTBLANK   PROC 
           PUSH   AX
           PUSH   DX                       ;保存DX
           MOV    DL, ' '                  ;要显示的字符就位
           MOV    AH, 2                    ;显示
           INT    21H
           POP    DX                       ;恢复DX
           POP    AX
           RET 
PUTBLANK   ENDP
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE    PROC
           PUSH   AX                       ;AX压入栈中，为了保护AX的值
           PUSH   DX                       ;DX压入栈中，为了保护DX的值
           MOV    DL, 0DH                  ;   \r
           MOV    AH, 2                    ;调用显示中断
           INT    21H
           MOV    DL, 0AH                  ;   \n
           MOV    AH, 2                    ;调用显示中断
           INT    21H                
           POP    DX                       ;恢复进入子程序前的值
           POP    AX
           RET 
NEWLINE    ENDP

CSEG       ENDS
           END    START