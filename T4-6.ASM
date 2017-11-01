;T4-6.ASM
;显示当前目录下TEST.TXT文件内容的程序
;
EOF = 1AH                                     ;文件结束符ASCII码
;
DSEG        SEGMENT
FNAME       DB 'TEST.TXT', 0                   ;文件名，不指定路径即为当前路径
ERROR1      DB 'FILE NOT FOUND!', 07H, 0       ;报错信息：文件没有找到
ERROR2      DB 'READING ERROR!', 07H, 0        ;报错信息：文件读取错误
BUFFER      DB ?                               ;一字节缓冲区
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:      MOV     AX, DSEG                   ;初始化DS
            MOV     DS, AX
;
            MOV     DX, OFFSET FNAME           ;DS:DX 指向文件名
            MOV     AX, 3D00H                  ;打开文件
            INT     21H
            JNC     OPEN_OK                    ;打开成功进行跳转
;
            MOV     SI, OFFSET ERROR1          ;打开失败，SI指向错误提示信息字符串首地址
            CALL    DMESS                      ;调用显示功能函数，显示错误信息到屏幕上
            JMP     OVER                       ;程序结束
;
OPEN_OK:    MOV     BX, AX                     ;打开成功，AX存放文件号，文件号放在BX中
COUNT:      CALL    READCH                     ;调用读取文件内容函数功能
            JC      READERR                    ;读取结束，读取报错，跳转到读取错误处理
            CMP     AL, EOF                    ;文件是否到头
            JZ      TYPE_OK                    ;到头跳转到关闭文件
            CALL    PUTCH                      ;没有到头的话，显示AL中的字符
            JMP     COUNT                      ;循环
;
READERR:    MOV     SI, OFFSET ERROR2          ;读取中报错处理，SI指向读取错误报错信息字符串首字母地址
            CALL    DMESS                      ;显示报错信息
;
TYPE_OK:    MOV     AH, 3EH                    ;关闭文件
            INT     21H
;
OVER:       MOV     AH, 4CH                    ;结束
            INT     21H
;
;
;
;
READCH      PROC                                
            MOV     CX, 1                      ;设置读入字节数为1
            MOV     DX, OFFSET BUFFER          ;DS:DX指向缓冲区地址，BUFFER存放读到的字符
            MOV     AH, 3FH                    ;读取一个字符
            INT     21H         
            JC      READCH2                    ;CF=1读取失败，CF=0读取成功   成功时AX存放读取到的字节数，失败时AX存放错误代码
            CMP     AX, CX                     ;检测是否结束
            MOV     AL, EOF                    ;设文件已经结束，置文件结束符
            JB      READCH1                    ;文件确认结束，跳
            MOV     AL, BUFFER                 ;文件未结束，取值
READCH1:    CLC
READCH2:    RET
READCH      ENDP
;子程序名：DMESS
;功能：能显示一个以0为结束符的字符串
;入口参数：SI=字符串首地址
;出口参数：无
DMESS       PROC
DMESS1:     MOV     DL, [SI]                  ;SI=字符串首地址，取值
            INC     SI                        ;更新指针
            OR      DL, DL                    ;判断是否到头，OR操作如果DL为零影响CF的值
            JZ      DMESS2                    ;确认到头，进行跳转
            MOV     AH, 2                     ;调用显示字符中断
            INT     21H
            JMP     DMESS1                    ;循环
DMESS2:     RET
DMESS       ENDP
;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH       PROC 
            PUSH      DX                       ;保存DX
            MOV       DL, AL                   ;要显示的字符就位
            MOV       AH, 2                    ;显示
            INT       21H
            POP       DX                       ;恢复DX
            RET 
PUTCH       ENDP
CSEG        ENDS
            END       START

            
            