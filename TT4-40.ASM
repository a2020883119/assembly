;TT4-40.ASM
;比较文件   源文件 目标文件 键盘输入   cr lf
BUFFERLENGTH = 1024
DSEG         SEGMENT
;接收文件名的缓冲区
BUFFER1      DB 50                             ;文件1名称缓冲区
SIZE1        DB 0
FILENAME1    DB 50 DUP (0)
; FILENAME1    DB 'TEST.TXT', 0
;
BUFFER2      DB 50                             ;文件2名称缓冲区
SIZE2        DB 0
FILENAME2    DB 50 DUP (0)
; FILENAME2    DB 'COPY.TXT', 0
;文件句柄
HANDLE1      DW 0                              ;文件1句柄
HANDLE2      DW 0                              ;文件2句柄
;提示信息
MESS1        DB 'SOURCE     : $'               ;输入提示
MESS2        DB 'DESTINATION: $'
;结束信息 
RESULTMESS1  DB 'FINISHED!$'                   ;结果提示
;异常信息
ERRMESS1     DB '1CAN NOT OPEN FILE!', 07H, '$';无法打开文件报错信息字符串
ERRMESS2     DB 'READING ERROR!', 07H, '$'     ;无法读取文件报错信息字符串
ERRMESS3     DB 'WRITING ERROR!', 07H, '$'     ;无法写入文件报错信息字符串
ERRMESS4     DB '2CAN NOT OPEN FILE!', 07H, '$';无法打开文件报错信息字符串
;文件长度
BFASIZE      DW 0                              ;文件1的长度
BFBSIZE      DW 0                              ;文件2的长度
;行号
LINENUM      DB 6 DUP ('$')                    ;行号
;读文件缓冲区
BUFFERA      DB BUFFERLENGTH DUP (0)           ;读取文件时候用到的缓冲区
BUFFERB      DB BUFFERLENGTH DUP (0)           ;读取文件时候用到的缓冲区
;
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
;打开源文件失败
ERR1:
             MOV        DX, OFFSET ERRMESS1    ;'CAN NOT OPEN FILE!'
             CALL       DISPMESS
             JMP        OVER
;打开目标文件
OPENOK1:
             MOV        HANDLE1, AX            ;保存源文件句柄
             MOV        DX, OFFSET FILENAME2   ;ds:dx指向目标文件名称
             MOV        AX, 3D00H                 
             INT        21H
             JNC        OPENOK2                ;cf=0 表示创建成功
;关闭源文件
             MOV        BX, HANDLE1            ;目标文件创建失败,关闭源文件  
             MOV        AH, 3EH
             INT        21H
;打开目标文件失败
ERR2:
             MOV        DX, OFFSET ERRMESS4    ;'2CAN NOT OPEN FILE!'
             CALL       DISPMESS
             JMP        OVER                   ;结束程序
;
OPENOK2:
             MOV        HANDLE2, AX            ;保存目标文件句柄 
;读源文件
COUNT:
             MOV        DX, OFFSET BUFFERA     ;ds:dx指向读取文件缓冲区
             MOV        CX, BUFFERLENGTH       ;要读取的字符数量
             MOV        BX, HANDLE1            ;bx = 文件句柄
             MOV        AH, 3FH
             INT        21H
;保存源文件长度  
             JC         RERR                   ;cf=1,失败
             DEC        AX                     ;从零开始,减去多余的1
             ADD        AX, OFFSET BUFFERA     ;si不是从零开始,所以校准结束位置
             MOV        WORD PTR BFASIZE, AX   ;保存
;读目标文件
             MOV        DX, OFFSET BUFFERB     ;ds:dx指向读取文件缓冲区
             MOV        CX, BUFFERLENGTH       ;要读取的字符数量
             MOV        BX, HANDLE2            ;bx = 文件句柄
             MOV        AH, 3FH
             INT        21H
;保存目标文件长度
             JC         RERR                   ;cf=1,失败
             DEC        AX                     ;从零开始,减去多余的1
             ADD        AX, OFFSET BUFFERB     ;di不是从零开始,所以校准结束位置
             MOV        WORD PTR BFBSIZE, AX   ;保存
             JC         RERR                   ;cf=1,失败
;对比
             MOV        SI, OFFSET BUFFERA     ;文件一读取缓冲区
             MOV        DI, OFFSET BUFFERB     ;文件二读取缓冲区
             MOV        DX, 1                  ;行号
             CALL       FINDNOTSAME            ;找不同
             JMP        COPYOK                 ;找完了


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
             
;结束
OVER:
             CALL       NEWLINE                 
             MOV        DX, OFFSET RESULTMESS1 ;'FINISHED!$'
             CALL       DISPMESS            
 
             MOV        AH, 4CH                ;结束
             INT        21H
;功能:找出不同行并将不同行的行号即两个不同行的行内容输出
;入口参数:di指向文件开头, si指向文件开头, dx存放行号
;出口参数:无
FINDNOTSAME    PROC
NEX1:
               PUSH   SI                       ;保存指向行首位的指针,用于输出不同行
               PUSH   DI
NEX2:
               MOV    AL, [SI]                 ;取同一行,同一位置的值比较
               MOV    AH, [DI]
               CMP    DI, BFBSIZE              ;是否到文件最后
               JZ     NEXT5                    ;结束
               CMP    SI, BFASIZE              ;是否到文件最后
               JZ     NEXT5                    ;结束
               CMP    AL, AH                   ;比较
               JZ     NEXT                     ;相同换下一个
               POP    DI                       ;不相同,取指向行首位的指针
               POP    SI                       ;不相同,取指向行首位的指针
               CALL   SHOWNOSAME               ;显示行号以及不同的行
               CMP    DI, BFBSIZE              ;是否到文件最后
               JZ     NEXT5                     ;结束 
               CMP    SI, BFASIZE              ;是否到文件最后
               JZ     NEXT5                     ;结束 

               INC    SI                       ;没有结束,换下一行
               INC    DI                       ;没有结束,换下一行
               INC    DX                       ;行数加一
               JMP    NEX1                     ;
               
NEXT: 
               CMP    AL, 0AH                  ;是否到行尾
               JNZ    NEXT2                    ;
               INC    DX                       ;到行尾,此行相同,行数加一
               POP    AX                       ;保存的每行首地址指针作废
               POP    AX                       ;保存的每行首地址指针作废
               INC    SI                       ;指向下一行首位
               INC    DI                       ;指向下一行首位
               JMP    NEX1
NEXT2:
               CMP    SI, BFASIZE              ;没有到行尾,比较是否到达文件尾部
               JNZ    NEXT4
               POP    AX                       ;保存的每行首地址指针作废
               POP    AX                       ;保存的每行首地址指针作废
               JMP    NEXT5                    ;结束
NEXT4:
               CMP    DI, BFBSIZE              ;没有到行尾,比较是否到达文件尾部
               JNZ    NEXT3
               POP    AX                       ;保存的每行首地址指针作废
               POP    AX                       ;保存的每行首地址指针作废
               JMP    NEXT5                    ;结束 
NEXT3:
               INC    SI                       ;没到行尾,没到文件尾,指向下一个
               INC    DI                       ;没到行尾,没到文件尾,指向下一个
               JMP    NEX2                
NEXT5:
               POP    AX                       ;恢复堆栈,准备回去
               POP    AX
               RET
FINDNOTSAME    ENDP
;功能:将不同行的行号即两个不同行的行内容输出
;入口参数:di指向行头, si指向行头, dx存放行号
;出口参数:si指向行尾或文件尾, di指向行尾或文件尾
SHOWNOSAME    PROC
;              
              MOV    AX, DX                    ;将行号放在ax中
              PUSH   SI                        ;用到si,先压入栈中
              MOV    SI, OFFSET LINENUM        ;si指向存放行号ascii码串的内存区域
              CALL   AXTODECASCII              ;转换
              POP    SI                        ;恢复si
              PUSH   DX                        ;用到dx,先压入栈中
              MOV    DX, OFFSET LINENUM        ;ds:dx指向存放行号ascii码串的内存区域
              CALL   DISPMESS                  ;显示行号ascii码串
              POP    DX                        ;恢复dx
              CALL   NEWLINE                   ;换行
AG1:
              MOV    AL, [SI]                  ;输出文件1的不同行
              CALL   PUTCH
              CMP    AL, 0AH                   ;是否到行尾
              JZ     AG2                       ;到行尾,文件1的不同行输出结束,开始输出文件2的不同行
              CMP    SI, BFASIZE               ;是否到文件尾部
              JZ     AG2                       ;到文件尾,文件1的不同行输出结束,开始输出文件2的不同行
              INC    SI                        ;指向下一个要输出的字符
              JMP    AG1                       ;循环
;
AG2:          MOV    AL, [DI]                ;输出文件2的不同行
              CALL   PUTCH                    ;
              CMP    AL, 0AH                  ;是否到行尾
              JZ     NEXTLINE                  ;到行尾,文件2的不同行输出结束,返回主程序
              CMP    DI, BFBSIZE              ;是否到文件尾部
              JZ     NEXTLINE                  ;到文件尾,文件2的不同行输出结束,返回主程序 
              INC    DI                        ;指向下一个要输出的字符 
              JMP    AG2                       ;循环 
NEXTLINE:   
              RET
SHOWNOSAME    ENDP
;将十六位二进制数转换为十进制数ASCII码
;入口参数:ax值, si指向存放字符串的缓冲区
;出口参数:指定缓冲区
;十进制处理
AXTODECASCII        PROC
         PUSH       AX
         PUSH       DX
         PUSH       CX
         PUSH       BX
         MOV        BX, 10                   ;乘数
         MOV        DX, 0
         MOV        CX, 0                    ;计数器清零
DECLOOP: 
         DIV        BX                       ;除
         PUSH       DX                       ;保存余数到堆栈
         INC        CX                       ;计数器加一
         XOR        DX, DX                   ;清空余数，不影响下次操作
         CMP        AX, 0                    ;被除数为零异常处理，循环出口
         JZ         DECEND                   ;跳出处理循环，进入显示循环
         JMP        DECLOOP                   ;继续处理循环
         

DECEND:  
         POP        AX                       ;从堆栈中取出余数
         ADD        AX, 30H
         MOV        [SI], AL
         INC        SI
         LOOP       DECEND                    ;循环继续
;
         POP        BX
         POP        CX
         POP        DX
         POP        AX

         RET
AXTODECASCII        ENDP
;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH    PROC 
         PUSH      AX
         PUSH      DX                       ;保存DX
         MOV       DL, AL                   ;要显示的字符就位
         MOV       AH, 2                    ;显示
         INT       21H
         POP       DX                       ;恢复DX
         POP       AX
         RET 
PUTCH    ENDP
;功能:
;入口参数:
;出口参数:
ISNEWLINE    PROC
             RET
ISNEWLINE    ENDP
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