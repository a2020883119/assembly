;TT3-39.ASM
;写一个从地址F000:0000H开始的1k字节内存中寻找所有'ok’字符串的开始地址并保存

DSEG       SEGMENT
BUFFER     DW 512 DUP ('KO')          ;寻找区域
BUFFER2    DW 512 DUP (0)             ;存储区域
KEYWORD    DW 'KO'                    ;字符串
DSEG       ENDS

CSEG       SEGMENT
           ASSUME CS:CSEG, DS:DSEG
START:     MOV     AX, DSEG
           MOV     DS, AX

           MOV     SI, OFFSET BUFFER     ;校准指针
           MOV     DI, OFFSET BUFFER2

           MOV     AX, KEYWORD           ;取关键字
           MOV     CX, 1024              ;循环次数
AG:     
           CMP     AX, [SI]              ;比较
           JZ      FIND
           INC     SI
           JMP     NOFIND
FIND:      LEA     BX, [SI]              ;找到
           MOV     [DI], BX
           INC     DI
           INC     DI
           INC     SI
           INC     SI
           DEC     CX                    ;更正cx误差
NOFIND:    LOOP     AG

           
OVER:      MOV     AH, 4CH
           INT     21H

CSEG       ENDS
           END     START