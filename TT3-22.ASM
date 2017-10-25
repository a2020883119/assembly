;TT3-22.ASM
;求32位有符号数补码   在DX:AX中
CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG
START:   MOV    BX, DX
         AND    BX, 8000H         ;取符号位
         CMP    BX, 0             ;判断正负
         JZ     PSTV              ;正处理
         NOT    DX                ;取反处理
		 NOT    AX
         ADD    AX, 1
         ADC    DX, 0

PSTV:    MOV    AH, 4CH
         INT    21H

CSEG     ENDS
         END    START