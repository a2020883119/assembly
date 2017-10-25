;T3-16
;查找一个字符串是否包含另一个字符串
DSEG1     SEGMENT
STRM      DB 'THIS IS STRING!', 0
DSEG1     ENDS
;
DSEG2     SEGMENT
STRS      DB 'STRING', 0
FLAG      DB ?
DSEG2     ENDS
;
CODE      SEGMENT
          ASSUME CS:CODE, DS:DSEG1, ES:DSEG2

START:    MOV    AX, DSEG1                   ;初始化
          MOV    DS, AX
          MOV    AX, DSEG2
          MOV    ES, AX
;
          MOV    DI, OFFSET STRS             ;DI为要超找字符串指针
          MOV    BX, DI                      ;BX备份DI
          XOR    CX, CX                      ;CX清零
          DEC    DI                          ;消除第一次多加的1
                                             ;得到要找的那个字符串的长度
WHILE1:   INC    DI                          ;字符串2的指针 
          INC    CX                          ;计数器
          CMP    BYTE PTR ES : [DI], 0      ;是否结束
          JNZ    WHILE1 
          DEC    CX                          ;消除比对0时多加的1
          MOV    DX, CX                      ;DX保存字符串2的长度
;                                             开始两个字符串比对
          MOV    SI, OFFSET STRM             ;SI为字符串1的指针
          MOV    BP, SI                      ;保存字符串1的指针
;
FORI:     MOV    CX, DX                      ;设定确认循环的次数
          MOV    DI, BX                      ;恢复DI，DI为字符串2的指针    BX备份， DI实战
;
FORJ:     MOV    AL, ES : [DI]              ;拿字符串2第一个值去和字符串一比对
          CMP    [SI], AL                    ;
          JNZ    NEXTI                       ;不相等，跳转   ，本次查找失败，di si cx全部从备份的数据中恢复，继续首字母比对

NEXTJ:    INC    DI                          ;首字母比对相同之后进行确认
          INC    SI                          ;俩字符串指针都向后面移动一位， cx中为循环次数
          LOOP   FORJ                        ;跳到确认循环中
          MOV    FLAG, 1                     ;确认循环执行结束确认无误，设置标志位为1
          JMP    OVER                        ;结束
;
NEXTI:    CMP    BYTE PTR [SI], 0           ;比对之后，检测字符串一是否到头了
          JZ     NOTF                        ;到头说明没找到，直接跳到设置标志位为没找到

          INC    BP                          ;每到头继续找，BP是SI的备份
          MOV    SI, BP                      ;BP备份，SI实战
          JMP    FORI                        ;继续找
;
NOTF:     MOV    FLAG, 0                     ;没有相同字符串，设置标志位为0，结束
;
OVER:     MOV    AH, 4CH                     ;结束
          INT    21H
CODE      ENDS
          END START