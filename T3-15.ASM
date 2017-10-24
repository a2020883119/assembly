;T3-15
;二重循环 从小到大 冒泡排序
DSEG     SEGMENT
BUFFER   DB 23, 12, 32, 45, 127, 3, 9, 58, 81, 72
N        EQU 10
DSEG     ENDS
;
CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG

START:   MOV   AX, DSEG                  ;初始化
         MOV   DS, AX

         MOV   BX, OFFSET BUFFER - 1     ;外层循环子赋值 i=1
         MOV   SI, 1

FORI:    MOV   DI, SI                    ;外循环
         INC   DI

FORJ:    MOV   AL, [BX + SI]             ;内循环
         CMP   AL, [BX + DI]             
         JBE   NEXTJ

         XCHG  AL, [BX + DI]             ;换位置
         MOV   [BX + SI], AL

NEXTJ:   INC   DI                         ;j++
         CMP   DI, N
         JBE   FORJ

NEXTI:   INC   SI                         ;i++
         CMP   SI, N - 1
         JBE   FORI
;
         MOV   AH, 4CH
         INT   21H
CSEG     ENDS
         END   START