;TT4-17.ASM
;循环显示0-9，到十三个换行，收到回车停止
;
DSEG       SEGMENT
DSEG       ENDS
CSEG       SEGMENT
           ASSUME CS:CSEG, DS:DSEG
START:     MOV    AL, '0'                  ;AL存放输出字符      
           MOV    CL, 0                    ;CL存放每行个数
;
AG:        
           PUSH   AX                       ;保存AX的值不被破坏   
           MOV    AH, 01H                  ;检测是否有按键被按下
           INT    16H                      ;ZF＝1——无字符输入，否则，AH＝键盘的扫描码，AL＝ASCII码。

           JZ     GO                       ;
           XOR    AH, AH                   ;从键盘读入字符
           INT    16H                      ;AH＝键盘的扫描码，AL＝字符的ASCII码
           CMP    AL, 0DH                  ;是否是回车键
           JNZ    GO                       ;不是继续循环
           MOV    AH, 4CH                  ;是，结束程序
           INT    21H                      ;
GO:         
           POP    AX                       ;对应12行获取键盘输入的处理时对AX的保护于恢复
           CALL   PUTCH                    ;把字符显示到屏幕

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
           JMP    AG                       ;
NEXT:      
           CALL   PUTBLANK                 ;输出空格
           JMP    AG                       ;
           

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

