;TT4-39.ASM
;输入文件名称,计算文件中的数字和英文字母的个数输出到屏幕上
;
BUFFERLENGTH = 1024
;
DSEG         SEGMENT
;
BUFFER1      DB 50                             ;文件1
SIZE1        DB 0
FILENAME1    DB 50 DUP (0)
;
MESS1        DB 'FILE NAME  : $'               ;输入提示
MESS2        DB 'FILE LENGTH: $'
;
ERRMESS1     DB 'CAN NOT OPEN FILE!', 07H, '$' ;无法打开文件报错信息字符串
ERRMESS2     DB 'READING ERROR!', 07H, '$'     ;无法读取文件报错信息字符串
;
BUFFER       DB BUFFERLENGTH DUP (0)           ;读取文件时候用到的缓冲区
FILELENGTH   DD 0
FILELENGTH1  DB 9 DUP (0)
FILELENGTH2  DB 0
FILELENGTHED DB '$'
;
FFFFNUM      DB 6, 5, 5, 3, 5
;
DSEG         ENDS
;
CSEG         SEGMENT
             ASSUME CS:CSEG, DS:DSEG
START:
             MOV        AX, DSEG               ;初始化
             MOV        DS, AX
;获取源文件,目标文件名称字符串
             MOV        DX, OFFSET MESS1       ;'FILE NAME  : $' 
             CALL       DISPMESS
;             
             MOV        DX, OFFSET BUFFER1     ;获取源文件名称 
             CALL       GETFILENAME
;
             XOR        AX, AX
             MOV        AL, BYTE PTR SIZE1     ;处理多余的空格字符 0DH
             MOV        SI, AX
             MOV        BX, OFFSET FILENAME1
             MOV        [SI][BX], BYTE PTR 0H
;
             CALL       NEWLINE
;
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
;计数
OPENOK1:
             PUSH       AX
             XOR        SI, SI
             XOR        DI, DI
             MOV        DX, OFFSET BUFFER      ;ds:dx指向读取文件缓冲区
             MOV        CX, BUFFERLENGTH       ;要读取的字符数量
             MOV        BX, AX                 ;bx = 文件句柄
COUNT:
             MOV        AH, 3FH
             INT        21H
  
             JC         RERR                   ;cf=1,失败
             OR         AX, AX                 ;ax存放实际读到的字符个数
             JZ         COUNTOK                 ;为0时表示读取完毕
             ; ADD        SI, AX                 ;cx=要写入的字符个数
             ; ADC        DI, 0
             PUSH       CX
             PUSH       BX
             MOV        BX, DX
             MOV        CX, AX
             CALL       COUNTABC123
             POP        BX
             POP        CX
             JMP        COUNT                  ;没有完继续读

;读取错误
RERR:
             MOV        DX, OFFSET ERRMESS2    ;'READING ERROR!'
             CALL       DISPMESS
             JMP        OVER
;关闭源文件
COUNTOK:            
             MOV        WORD PTR FILELENGTH, SI       ;保存低十六位
             MOV        WORD PTR FILELENGTH + 2, DI   ;保存高十六位
;
             MOV        AX, SI                        ;传参数, si为字母数量
             MOV        SI, OFFSET FILELENGTH2        ;指向存放地址末尾
             CALL       AXTODECASCII
;
             MOV        AX, DI                        ;传参数, di为数字数量
             MOV        SI, OFFSET FILELENGTH2 - 5    ;指向存放地址末尾 
             CALL       AXTODECASCII
;
             MOV        DX, OFFSET MESS2              ;'FILE LENGTH: $'
             CALL       DISPMESS
             MOV        DX, OFFSET FILELENGTH1        ;长度字符串
             CALL       DISPMESS
             CALL       NEWLINE
;
OVER:      
             POP        BX                     ;关闭源文件
             MOV        AH, 3EH
             INT        21H
;
             MOV        AH, 4CH
             INT        21H
;
;功能:统计一片区域内字母和数字的个数
;入口参数:CX字符总数,循环数; bx指向目标缓冲区
;出口参数:di存放字母个数, si存放数字个数
COUNTABC123    PROC
               PUSH   AX
AG:              
               MOV    AL, [BX]                  ;取值
               CALL   ISHEX                     ;字母判断
               JC    NUMCHECK                   ;cf=1不是字母
               INC    SI                        ;字母数量加一
               JMP    NEXT                      ;下一个
NUMCHECK:     
               CALL   ISDECM                    ;数字判断
               JC     NEXT                      ;cf=1不是数字
               INC    DI                        ;数字数量加一
NEXT:
               INC    BX                        ;下一个
               LOOP   AG
               POP    AX
               RET
COUNTABC123    ENDP

;功能：判断是不是有效十六进制ASCII码
;入口参数：AL存放要检验的字符
;出口参数：CF中存放判断结果，CF是1表示无效，CF是0表示有效
ISHEX    PROC
         CMP       AL, 'A'                  ;是否大于十
         JB        ISHEX2                   ;无效字符，CF=1
         CMP       AL, 'F' + 1              ;是否超范围
         JB        ISHEX1                   ;有效，且大于10，CF=1
         CMP       AL, 'a'                  ;是否大于十
         JB        ISHEX2                   ;无效，非法字符，CF=1
         CMP       AL, 'f' + 1              ;是否超范围，超范围CF=0,不超范围CF=1
ISHEX1:  CMC                                ;CF取反
ISHEX2:  RET
ISHEX    ENDP
;功能:判断一个字符是否为数字符
;入口参数:AL放字符
;出口参数:CF为零是字符，否则 不是字符
ISDECM   PROC
         CMP    AL, '0'
         JB     ISDECM1
         CMP    AL, '9'+1
         CMC
ISDECM1: RET
ISDECM   ENDP
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
;开始 SI指向末尾处修改 
         PUSH       SI
         INC        SI
         SUB        SI, CX
         MOV        [SI], AL
         POP        SI
;结束 SI指向末尾处修改 
         ; MOV        [SI], AL
         ; INC        SI
         LOOP       DECEND                    ;循环继续
;
         POP        BX
         POP        CX
         POP        DX
         POP        AX

         RET
AXTODECASCII        ENDP
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


CSEG         ENDS
             END        START