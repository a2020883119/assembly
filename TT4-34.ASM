;TT4-34.ASM
;复制文件   源文件 目标文件 键盘输入
BUFFERLENGTH = 1024
DSEG         SEGMENT
BUFFER1      DB 50                             ;文件1
SIZE1        DB 0
FILENAME1    DB 50 DUP (0)
; FILENAME1    DB 'TEST.TXT', 0
;
BUFFER2      DB 50                             ;文件2
SIZE2        DB 0
FILENAME2    DB 50 DUP (0)
; FILENAME2    DB 'COPY.TXT', 0
;
HANDLE1      DW 0                              ;文件1句柄
HANDLE2      DW 0                              ;文件2句柄
;
MESS1        DB 'SOURCE     : $'               ;输入提示
MESS2        DB 'DESTINATION: $'
; 
RESULTMESS1  DB 'OK!$'                         ;结果提示
RESULTMESS2  DB 'FAILED!$'
;
ERRMESS1     DB 'CAN NOT OPEN FILE!', 07H, '$' ;无法打开文件报错信息字符串
ERRMESS2     DB 'READING ERROR!', 07H, '$'     ;无法读取文件报错信息字符串
ERRMESS3     DB 'WRITING ERROR!', 07H, '$'     ;无法写入文件报错信息字符串
ERRMESS4     DB 'CAN NOT CREATE FILE!', 07H, '$';无法打开文件报错信息字符串
BUFFER       DB  BUFFERLENGTH DUP (0)          ;读取文件时候用到的缓冲区
DSEG         ENDS

CSEG         SEGMENT
             ASSUME CS:CSEG, DS:DSEG
START:
             MOV        AX, DSEG               ;初始化
             MOV        DS, AX
;获取源文件,目标文件名称字符串
             MOV        DX, OFFSET MESS1       ;'SOURCE     :' 
             CALL       DISPMESS
;             
             MOV        DX, OFFSET BUFFER1     ;获取源文件名称 
             CALL       GETFILENAME
;
             XOR        AX, AX                 ;处理多余的空格字符 0DH
             MOV        AL, BYTE PTR SIZE1
             MOV        SI, AX
             MOV        BX, OFFSET FILENAME1
             MOV        [SI][BX], BYTE PTR 0H
;
             CALL       NEWLINE
;
             MOV        DX, OFFSET MESS2       ;'DESTINATION:'
             CALL       DISPMESS
;
             MOV        DX, OFFSET BUFFER2     ;获取目标文件名称
             CALL       GETFILENAME
             XOR        AX, AX
;
             MOV        AL, BYTE PTR SIZE2     ;处理多余的空格字符 0DH
             MOV        SI, AX
             MOV        BX, OFFSET FILENAME2
             MOV        [SI][BX], BYTE PTR 0H
;
             CALL       NEWLINE
;打开源文件
             MOV        DX, OFFSET FILENAME1   ;ds:dx指向源文件名称
             MOV        AX, 3D00H              ;打开源文件  打开方式:al=00 只读
             INT        21H
             JNC        OPENOK1                ;cf=1发生异常,结束程序
;打开失败
ERR1:
             MOV        DX, OFFSET ERRMESS1    ;'CAN NOT OPEN FILE!'
             CALL       DISPMESS
             JMP        OVER
;创建目标文件
OPENOK1:
             MOV        HANDLE1, AX            ;保存源文件句柄
             MOV        DX, OFFSET FILENAME2   ;ds:dx指向目标文件名称
             MOV        CX, 00H                ;cx=00 普通文件
             MOV        AH, 3CH                 
             INT        21H
             JNC        OPENOK2                ;cf=0 表示创建成功
;创建失败
             MOV        BX, HANDLE1            ;目标文件创建失败,关闭源文件  
             MOV        AH, 3EH
             INT        21H
;
ERR2:
             MOV        DX, OFFSET ERRMESS4    ;'CAN NOT CREATE FILE!'
             CALL       DISPMESS
             JMP        OVER                   ;结束程序
;更正源文件指针
OPENOK2:
             MOV        HANDLE2, AX            ;保存目标文件句柄 
;
             MOV        BX, HANDLE1            ;bx = 文件句柄
             XOR        CX, CX                 ;cx:dx为文件指针
             XOR        DX, DX
             MOV        AX, 4200H              ;al=00 表示指针位置为0+cx:dx
             INT        21H
;源文件->目标文件
COUNT:
             MOV        DX, OFFSET BUFFER      ;ds:dx指向读取文件缓冲区
             MOV        CX, BUFFERLENGTH       ;要读取的字符数量
             MOV        BX, HANDLE1            ;bx = 文件句柄
             MOV        AH, 3FH
             INT        21H
  
             JC         RERR                   ;cf=1,失败
             OR         AX, AX                 ;ax存放实际读到的字符个数
             JZ         COPYOK                 ;为0时表示读取完毕
             MOV        CX, AX                 ;cx=要写入的字符个数
             MOV        BX, HANDLE2            ;bx=文件句柄
             MOV        AH, 40H                ;ds:dx指向读取文件缓冲区
             INT        21H
             JNC        COUNT                  ;没有完继续读
;写入错误
WERR:
             MOV        DX, OFFSET ERRMESS3    ;'WRITING ERROR!'
             CALL       DISPMESS
             JMP        SHORT COPYOK           ;写入异常,关闭文件,退出程序
;读取错误
RERR:
             MOV        DX, OFFSET ERRMESS2    ;'READING ERROR!'
             CALL       DISPMESS
;关闭源文件,目标文件
COPYOK:     
             MOV        BX, HANDLE1            ;关闭源文件
             MOV        AH, 3EH
             INT        21H

             MOV        BX, HANDLE2            ;关闭目标文件
             MOV        AH, 3EH
             INT        21H
;
             CALL       NEWLINE                 
             MOV        DX, OFFSET RESULTMESS1 ;'OK!$'
             CALL       DISPMESS
;结束
OVER:
             MOV        AH, 4CH                ;结束
             INT        21H
;
;功能:换一行,输出换行回车
;入口参数:无
;出口参数:无
NEWLINE      PROC
             PUSH       AX                     ;AX压入栈中，为了保护AX的值
             PUSH       DX                     ;DX压入栈中，为了保护DX的值
             MOV        DL, 0DH                ;   \r
             MOV        AH, 2                  ;调用显示中断
             INT        21H
             MOV        DL, 0AH                ;   \n
             MOV        AH, 2                  ;调用显示中断
             INT        21H                
             POP        DX                     ;恢复进入子程序前的值
             POP        AX
             RET 
NEWLINE      ENDP
;
;
;功能:获取输入的一串字符串
;入口参数:ds:dx指向设置好的缓冲区
;出口参数:接收到的字符串长度和字符串内容保存在缓冲区的第二第三部分
GETFILENAME     PROC

             PUSH       AX
             MOV        AH, 0AH
             INT        21H
             POP        AX
             RET

GETFILENAME     ENDP
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS     PROC
             PUSH       AX
             MOV        AH, 9                  ;调用显示字符串中断
             INT        21H
             POP        AX
             RET
DISPMESS     ENDP
;
CSEG         ENDS
             END        START































