;T4-8.ASM
;功能：把文件TEST2.TXT拼接到文件TEST1.TXT之后
;符号常量定义
BUFFLEN = 512
;数据段
DSEG      SEGMENT
FNAME1    DB 'TEST1.TXT', 0                ;文件1
FNAME2    DB 'TEST2.TXT', 0                ;文件2
HANDLE1   DW 0                             ;保存文件1的文件柄
HANDLE2   DW 0                             ;保存文件2的文件柄
ERRMESS1  DB 'CAN NOT OPEN FILE', 07H, '$' ;无法打开文件报错信息字符串
ERRMESS2  DB 'READING ERROR', 07H, '$'     ;无法读取文件报错信息字符串
ERRMESS3  DB 'WRITING ERROR', 07H, '$'     ;无法写入文件报错信息字符串
BUFFER    DB BUFFLEN DUP (0)               ;读取文件时候用到的缓冲区
DSEG      ENDS
;代码段
CSEG      SEGMENT
          ASSUME CS:CSEG, DS:DSEG
START:    MOV      AX, DSEG                ;初始化DS
          MOV      DS, AX
;
          MOV      DX, OFFSET FNAME1       ;DS:DX指向文件路径和名称
          MOV      AX, 3D01H               ;打开文件
          INT      21H
          JNC      OPENOK1                 ;CF=0，表示打开成功，跳转
;
ERR1:     MOV      DX, OFFSET ERRMESS1     ;文件打开不成功时候，DX指向无法打开报错字符串
          CALL     DISPMESS                ;显示报错信息字符串
          JMP      OVER                    ;跳转到结束
;
OPENOK1:  MOV      HANDLE1, AX             ;打开成功，保存文件柄
          MOV      DX, OFFSET FNAME2       ;DS:DX指向文件路径和名称
          MOV      AX, 3D00H               ;打开文件
          INT      21H
          JNC      OPENOK2                 ;CF=0，表示打开成功，跳转
;
          MOV      BX, HANDLE1             ;文件打开不成功时候，把文件1的文件柄放入BX中
          MOV      AH, 3EH                 ;关闭文件1
          INT      21H
          JMP      ERR1                    ;显示报错信息，结束程序
;
OPENOK2:  MOV      HANDLE2, AX             ;打开成功，保存文件2的文件柄
;
          MOV      BX, HANDLE1             ;把文件1的文件柄放在BX中
          XOR      CX, CX                  ;CX:DX表示移动文件指针的大小
          XOR      DX, DX
          MOV      AX, 4202H               ;将指针移到最后，02代表指针在最后并加上CX:DX的值
          INT      21H
;
CONT:     MOV      DX, OFFSET BUFFER       ;DS:DX指向读取缓冲区
          MOV      CX, BUFFLEN             ;读取的字节数等于缓冲区大小
          MOV      BX, HANDLE2             ;将文件2的文件柄放入BX中
          MOV      AH, 3FH                 ;读文件
          INT      21H
          JC       RERR                    ;CF=1表示读取异常，跳转到读取异常处理
          OR       AX, AX                  ;OR AX本身，影响CF符号，AX中存放读取到的字符数量
          JZ       COPYOK                  ;ZF=0表示无字符可读
          MOV      CX, AX                  ;将读到的字节数量放在CX中，CX表示写入字符的数量
          MOV      BX, HANDLE1             ;将文件1的句柄放在BX中
          MOV      AH, 40H                 ;开始向文件1中写入缓冲区中的字符，DS:DX指向缓冲区开始位置
          INT      21H                     ;
          JNC      CONT                    ;循环
;
WERR:     MOV      DX, OFFSET ERRMESS3     ;DX指向错误提示信息3
          CALL     DISPMESS                ;显示错误信息
          JMP      SHORT COPYOK            ;赋值粘贴结束，跳转到结尾文件关闭处理
;
RERR:     MOV      DX, OFFSET ERRMESS2     ;DX指向错误提示信息3
          CALL     DISPMESS                ;显示错误信息
;
COPYOK:   MOV      BX, HANDLE1             ;关闭文件1
          MOV      AH, 3EH
          INT      21H
          MOV      BX, HANDLE2             ;关闭文件2
          MOV      AH, 3EH
          INT      21H
;
OVER:     MOV      AH, 4CH                 ;程序结束
          INT      21H
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS  PROC
          MOV      AH, 9                   ;调用显示字符串中断
          INT      21H
          RET
DISPMESS  ENDP

CSEG      ENDS
          END      START