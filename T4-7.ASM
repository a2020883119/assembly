;T4-7.ASM
;功能：将键盘上输入的字符全部存入文件TEST.TXT
;常量定义
EOF = 1AH
;数据段
DSEG         SEGMENT
FNAME        DB 'TEST.TXT', 0                     ;文件路径加文件名
ERRMESS1     DB 'CAN NOT CREATE FILE', '07H', '$' ;错误提示，无法创建文件
ERRMESS2     DB 'WRITING ERROR', '07H', '$'       ;错误提示，无法写入
BUFFER       DB ?                                 ;读取输入字符缓冲区
DSEG         ENDS
;代码段
CSEG         SEGMENT
             ASSUME CS:CSEG, DS:DSEG
START:       MOV     AX, DSEG                     ;DS初始化
             MOV     DS, AX
;
             MOV     DX, OFFSET FNAME             ;DS:DX指向文件路径
             MOV     CX, 0                        ;文件格式：普通文件
             MOV     AH, 3CH                      ;创建文件
             INT     21H
             JNC     CREA_OK                      ;创建成功，进行跳转   即CF=0,代表创建成功
;
             MOV     DX, OFFSET ERRMESS1          ;创建失败，DS:DX指向错误提示信息，用于显示错误信息
             CALL    DISPMESS                     ;显示错误信息字符串，以'$'结尾
             JMP     OVER                         ;结束
;
CREA_OK:     MOV     BX, AX                       ;保存文件创建成功返回的文件柄
CONT:        CALL    GETCHAR                      ;获取一个输入的字符
             PUSH    AX                           ;保存AX
             CALL    WRITECH                      ;将接收的被输入的字符写入文件
             POP     AX                           ;恢复AX
             JC      WERROR                       ;异常处理，写入异常     CF=1代表写入异常
             CMP     AL, EOF                      ;判断是否结束输入
             JNZ     CONT                         ;没有继续接收下一个字符
             JMP     CLOSEF                       ;接收到文件结束符，跳转到保存文件处理
;
WERROR:      MOV     DX, OFFSET ERRMESS2          ;写入异常处理，写入错误信息显示到屏幕上
             CALL    DISPMESS                     ;调用显示字符串功能，以$结尾
;
CLOSEF:      MOV     AH, 3EH                      ;关闭文件
             INT     21H
OVER:        MOV     AX, 4CH                      ;结束
             INT     21H
;功能：向文件写入一个字符
;入口参数：AL存放字符
;出口参数：无
WRITECH      PROC                                  ;
             MOV     BUFFER, AL                   ;AL存放一个字符，放入写入缓冲区
             MOV     DX, OFFSET BUFFER            ;DS:DX指向写入缓冲区
             MOV     CX, 1                        ;写入的字节数
             MOV     AH, 40H                      ;调用写入中断
             INT     21H
             RET
WRITECH      ENDP
;功能：接收一个被输入的字符
;入口参数：无
;出口参数：AL存放接收到的字符
GETCHAR      PROC
             MOV     AH, 1                        ;调用接收字符中断
             INT     21H
             RET
GETCHAR      ENDP
;
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS     PROC
             MOV      AH, 9                     ;调用显示字符串中断
             INT      21H
             RET
DISPMESS     ENDP

CSEG         ENDS
             END      START