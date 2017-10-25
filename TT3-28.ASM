;TT3-28.ASM
;去除字符串中的空格

       MOV   AX, DSEG
       MOV   DS, AX

       MOV   SI, OFFSET STRING
       MOV   DI, SI

       MOV   AL, 20H          ;空格
       MOV   AH, 0H           ;零
AG:    CMP   AL, [SI]         ;检测空格
       JZ    SKIP
       MOV   BX, [SI]
       MOV   [DI], BX
       INC   DI
SKIP:  INC   SI
       CMP   AH, [SI]         ;检测是否到头
       JZ    OVER
       LOOP  AG

OVER:  MOV   AH, 4CH
       INT   21H