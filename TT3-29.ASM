;TT3-29
;两个字符串合并
DSEG      SEGMENT
STRING1   DB '1234567899', 0         ;S1
STRING2   DB '9987654321', 0         ;S2
STRINGB   DB 20 DUP (0)              ;缓冲区
DSEG      ENDS

CSEG      SEGMENT
          ASSUME DS:DSEG, CS:CSEG
START:    MOV    AX, DSEG           ;初始化
          MOV    DS, AX
          MOV    SI, OFFSET STRING1
          MOV    DI, OFFSET STRING2
          MOV    BX, OFFSET STRINGB
          MOV    AH, 0H             ;0
;
          
GOO:      MOV    AL, [SI]           ;字符串1
          MOV    [BX], AL
          INC    SI
          CMP    AH, [SI]
          JZ     GOT
          INC    BX
          LOOP   GOO

GOT:      MOV    AL, [DI]           ;字符串2
          MOV    [BX], AL
          INC    DI
          CMP    AH, [DI]
          JZ     OVER
          INC    BX
          LOOP   GOT
OVER:
          MOV    AH, 4CH
          INT    21H
CSEG      ENDS
          END    START




;优化版----------------------------------------------
;TT3-29
;两个字符串合并
DSEG      SEGMENT
STRING1   DB '1234567899', 0         ;S1
STRING2   DB '9987654321', 0         ;S2
STRINGB   DB 20 DUP (0)              ;缓冲区
DSEG      ENDS

CSEG      SEGMENT
          ASSUME DS:DSEG, CS:CSEG
START:    MOV    AX, DSEG           ;初始化
          MOV    DS, AX
          MOV    SI, OFFSET STRING1
          MOV    DI, OFFSET STRING2
          MOV    BX, OFFSET STRINGB
          MOV    AH, 0H             ;0
   
          JMP    GOO
GOT:      MOV    DI, SI             ;字符串2循环设置
          CMP    DI, 0
          JZ     OVER
          XOR    DI, DI  
  
GOO:      MOV    AL, [SI]           ;字符串1
          MOV    [BX], AL
          INC    SI
          CMP    AH, [SI]
          JZ     GOT
          INC    BX
          LOOP   GOO

OVER:
          MOV    AH, 4CH
          INT    21H
CSEG      ENDS
          END    START