;TT3-24
;依次重复四次AL中的内容
CSEG     SEGMENT
         ASSUME CS:CSEG
START:   MOV    AH, AL
         MOV    DX, AX
 
         MOV    AH, 4CH
         INT    21H
CSEG     ENDS
         END    START