;TT3-16.AMS
;没有数据段
CSEG     SEGMENT
         MESS DB 'HELLO WORLD!', '$'
         ASSUME CS:CSEG
START:   MOV    AX, CSEG             ;段值从ds换成了cs照样怼
         MOV    DS, AX
         
         MOV    DX, OFFSET MESS      ;中断调用
         MOV    AH, 9
         INT    21H
 
         MOV    AH,4CH               ;结束
         INT    21H
CSEG     ENDS
         END    START