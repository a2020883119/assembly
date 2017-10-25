;TT3-31.ASM
;把一个十进制数ASCII码串转换为对应非压缩BCD码和压缩BCD码
DSEG     SEGMENT
VALUE    DB '123456789', 0
BCD      DB 10 DUP (?)
ZIPBCD   DB 10 DUP (?)
DSEG     ENDS

CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG
START:   MOV AX, DSEG             ;初始化段值
         MOV DS, AX          
 
         MOV SI, OFFSET VALUE     ;初始化偏移
         MOV DI, OFFSET BCD
         
AG:      MOV   AL, [SI]           ;非压缩BCD
         MOV   AH, 0
         SUB   AL, 30H
         MOV   [DI], AL
         INC   SI
         INC   DI
         CMP   [SI], AH           ;AH = 0， 检测是否到头
         JZ    ZIP
         LOOP  AG

ZIP:     MOV   SI, OFFSET VALUE   ;压缩BCD 初始化偏移
         MOV   DI, OFFSET ZIPBCD  
AG2:     MOV   AL, [SI]           ;低位获取
         SUB   AL, 30H
         MOV   BL, AL
         INC   SI
         CMP   AH, [SI]           ;到头检测，到头了直接保存结束
         JZ    MOVE
         MOV   AL, [SI]           
         SUB   AL, 30H
         MOV   CL, 4              ;高位采用or方式赋值
         SHL   AL, CL
         OR    BL, AL         
         MOV   [DI], BL
         INC   DI
         INC   SI
         CMP   [SI], AH
         JZ    OVER
         LOOP  AG2

MOVE:    MOV   [DI], BL

OVER:    MOV   AH, 4CH
         INT   21H
CSEG     ENDS
         END   START
