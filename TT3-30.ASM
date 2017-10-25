;TT3-30
;某个字变量的值转换为对应二进制数ASCII码串
DSEG     SEGMENT
VALUE    DW 1110101010101011B
DOT      DB 'GO!'
BUFFER   DB 20 DUP (0)
DSEG     ENDS

CSEG     SEGMENT
         ASSUME DS:DSEG, CS:CSEG
START:   MOV     AX, DSEG            ;初始化
         MOV     DS, AX
         MOV     SI, VALUE
         MOV     DI, OFFSET BUFFER
         MOV     CX, 16              ;循环次数
         MOV     AH, 30H             ;0->ASCII码
AG:
         MOV     AL, AH              ;最低位进入CF
         SHR     SI, 1
         ADC     AL, 0               ;取出CF
         MOV     [DI], AL            ;存放
         INC     DI
         LOOP    AG

         MOV     AH, 4CH
         INT     21H

CSEG    ENDS
        END      START
         