;TT3-34.ASM
;数据块移动
DSEG     SEGMENT
AAAA     DB 1024 DUP ('A')
DSEG     ENDS

ESEG     SEGMENT
BBBB     DB 1024 DUP (?)
ESEG     ENDS

CSEG     SEGMENT
         ASSUME DS:DSEG, ES:ESEG, CS:CSEG
START:   MOV    AX, DSEG
         MOV    DS, AX
         
         MOV    AX, ESEG
         MOV    ES, AX
 
         MOV    CX, 512
         MOV    SI, OFFSET AAAA
         MOV    DI, OFFSET BBBB
AG:      MOV    AX, [SI]
         MOV    ES : [DI], AX
         INC    DI
         INC    SI
         LOOP   AG

         MOV    AH, 4CH
         INT    21H
CSEG     ENDS
         END    START    