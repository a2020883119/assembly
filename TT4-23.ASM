;TT4-23.ASM
;输出一个长字符串一个短字符串，查找长字符串是否包含短字符串
BFLENGTH = 128
DSEG      SEGMENT                            ;
LENGTH1   DB BFLENGTH                        ;存放长字符串
SIZE1     DB ?
STR1      DB BFLENGTH DUP (?)

LENGTH2   DB BFLENGTH                        ;存放短字符串
SIZE2     DB ?
STR2      DB BFLENGTH DUP (?)

MESS1     DB 'LONG  STRING:', '$'            ;提示输入
MESS2     DB 'SHORT STRING:', '$'
YES       DB 'YES!', '$'                     ;结果输出
NO        DB 'NO!', '$'
DSEG      ENDS

;
CODE      SEGMENT
          ASSUME CS:CODE, DS:DSEG

START:    MOV    AX, DSEG                    ;初始化
          MOV    DS, AX
;
          MOV    DX, OFFSET MESS1            ;输出提示，并接收字符串
          CALL   DISPMESS
          MOV    DX, OFFSET LENGTH1
          CALL   GETSTR
          CALL   NEWLINE
;
          MOV    DX, OFFSET MESS2            ;输出提示，并接收字符串
          CALL   DISPMESS
          MOV    DX, OFFSET LENGTH2
          CALL   GETSTR
          CALL   NEWLINE

          MOV    SI, OFFSET STR1             ;SI为长字符串的指针
          MOV    DI, OFFSET STR2             ;DI为短字符串的指针
          XOR    CH, CH
          MOV    CL, SIZE1                   ;设定J循环的次数

;
FORJ:     MOV    AL, [DI]                   ;拿短字符串第一个字符去和长字符串第一个字符比对
          CMP    [SI], AL                    ;
          JNZ    NEXTI                       ;不相等，跳转  继续首字母比对 不进入I循环

          PUSH   CX                          ;进入I循环备份寄存器，对比失败时可以恢复
          PUSH   DI
          PUSH   SI
          XOR    CH, CH                    
          MOV    CL, SIZE2                   ;设置I循环次数
NEXTJ:    INC    DI                          ;首字母比对相同之后进行确认
          INC    SI                          ;俩字符串指针都向后面移动一位， cx中为循环次数
          MOV    AL, [DI]                    ;比对
          CMP    [SI], AL
          JNZ    INTOOUT
          LOOP   NEXTJ                       ;I循环
          MOV    DX, OFFSET YES              ;显示结果
          CALL   DISPMESS
          JMP    OVER                         ;结束
INTOOUT:  POP    SI
          POP    DI
          POP    CX
          MOV    DI, OFFSET STR2
;
NEXTI:    
          INC    SI                          ;每到头继续找，BP是SI的备份
          LOOP   FORJ                        ;继续找

          MOV    DX, OFFSET NO               ;J循环结束代表没有找到，输出结果
          CALL   DISPMESS
;
OVER:     MOV    AH, 4CH                     ;结束
          INT    21H
;接收一串字符
;DS:DX指向第三缓冲区
;接收到的字符数量保存在第二缓冲区
GETSTR    PROC
          PUSH   AX
          MOV    AH, 0AH                   ;获取字符串
          INT    21H
          POP    AX
          RET
GETSTR    ENDP
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE   PROC
          PUSH   AX                        ;AX压入栈中，为了保护AX的值
          PUSH   DX                        ;DX压入栈中，为了保护DX的值
          MOV    DL, 0DH                   ;   \r
          MOV    AH, 2                     ;调用显示中断
          INT    21H 
          MOV    DL, 0AH                   ;   \n
          MOV    AH, 2                     ;调用显示中断
          INT    21H                 
          POP    DX                        ;恢复进入子程序前的值
          POP    AX
          RET 
NEWLINE   ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS  PROC
          PUSH   AX
          MOV    AH, 9                    ;调用显示字符串中断
          INT    21H
          POP    AX
          RET
DISPMESS  ENDP

CODE      ENDS
          END START