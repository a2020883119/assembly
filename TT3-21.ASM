;TT3-21.ASM
;统计ax中1的个数
CSEG    SEGMENT
        ASSUME CS:CSEG
START:  MOV   AX, 11111110B
        XOR   BX, BX
 
        MOV   CX, 8
BACK:   SHR   AX, 1
        ADC   BX, 0
        LOOP  BACK

        MOV   AH, 4CH
        INT   21H
CSEG    ENDS
        END   START
