;TT4-31.ASM
;在底部640k内存中寻找指定的字符串
;找到输出1
DSEG1     SEGMENT
STRS      DB 'WINDOWS', 0
FLAG      DB ?
DSEG1     ENDS
;
;
CODE      SEGMENT
          ASSUME CS:CODE, DS:DSEG1

START:    MOV    AX, DSEG1                   ;初始化
          MOV    DS, AX
          MOV    AX, 0
          MOV    ES, AX
;
          MOV    DI, OFFSET STRS             ;DI为要超找字符串指针
          MOV    BX, DI                      ;BX备份DI
          XOR    CX, CX                      ;CX清零
          DEC    DI                          ;消除第一次多加的1
;得到要找的那个字符串的长度
WHILE1:   INC    DI                          ;字符串2的指针 
          INC    CX                          ;计数器
          CMP    BYTE PTR DS : [DI], 0      ;是否结束
          JNZ    WHILE1 
          DEC    CX                          ;消除比对0时多加的1
          MOV    DX, CX                      ;DX保存查找字符串的长度
;                                             开始两个字符串比对
          MOV    SI, 1ca0h                       ;SI为640k的指针
          MOV    BP, SI                      ;保存640k的指针
;
FORI:     MOV    CX, DX                      ;设定确认循环的次数
          MOV    DI, BX                      ;恢复DI，DI为字符串2的指针    BX备份， DI实战
;
FORJ:     MOV    AL, DS : [DI]              ;拿字符串2第一个值去和字符串一比对
          CMP    ES : [SI], AL                    ;
          JNZ    NEXTI                       ;不相等，跳转   ，本次查找失败，di si cx全部从备份的数据中恢复，继续首字母比对

NEXTJ:    INC    DI                          ;首字母比对相同之后进行确认
          INC    SI                          ;俩字符串指针都向后面移动一位， cx中为循环次数
          LOOP   FORJ                        ;跳到确认循环中
          MOV    FLAG, 1                     ;确认循环执行结束确认无误，设置标志位为1
          JMP    OVER                        ;结束
;
NEXTI:    CMP    SI, 0FFFFH                  ;比对之后，检测字符串一是否到头了
          JZ     NOTF                        ;到头说明没找到，直接跳到设置标志位为没找到

          INC    BP                          ;每到头继续找，BP是SI的备份
          MOV    SI, BP                      ;BP备份，SI实战
          JMP    FORI                        ;继续找
;
NOTF:     MOV    FLAG, 0                     ;没有相同字符串，设置标志位为0，结束
;


OVER:     
          MOV    AL, FLAG
          ADD    AL, 30H
          CALL   PUTCH
          MOV    AH, 4CH                     ;结束
          INT    21H

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

CODE      ENDS
          END START
