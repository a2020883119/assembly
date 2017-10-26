;TT3-33.ASM
;十六进制数ASCII码转换为对应二进制数
DSEG     SEGMENT
ASCII    DB '123456789ABCDEF', 0
BUFFER   DB 20 DUP (?)
DSEG     ENDS

CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG
START:   MOV    AX, DSEG
         MOV    DS, AX

         MOV    SI, OFFSET ASCII      ;初始化指针
         MOV    DI, OFFSET BUFFER
         MOV    AH, 0
         DEC    SI
         DEC    DI

AG:      INC    SI
         INC    DI
         CMP    AH, [SI]              ;到头了
         JZ     OVER
         MOV    AL, [SI]
         CMP    AL, 'a'               ;根据标志位判断正负，范围a-z
         JS     AZ 
         SUB    AL, 'a' - 10
         JMP    OK
AZ:      CMP    AL, 'A'               ;范围A-Z
         JS     AZ2
         SUB    AL, 'A' - 10
         JMP    OK
AZ2:     SUB    AL, '0'               ;范围1-10
OK:      MOV    [DI], AL
         LOOP   AG

OVER:    MOV    AH, 4CH
         INT    21H
CSEG     ENDS
         END    START
         
