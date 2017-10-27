;TT3-38
;从地址F000:0000H开始的内存缓冲区中存放了一组单字节的
;正数或者负数，以零结尾，找出其中最大的正数和负数
DSEG     SEGMENT
BUFFER   DB -1, 20, 55, 8, -28, 1, -7, 3, -1, 9, 55, 6, 77, 0
DSEG     ENDS

CSEG     SEGMENT
         ASSUME DS:DSEG, CS:CSEG
START:   MOV     AX, DSEG         ;初始化
         MOV     DS, AX
         XOR     AX, AX
         XOR     BX, BX
         MOV     SI, OFFSET BUFFER         

         MOV     AL, 0             ;放正数
         MOV     BL, 0             ;放负数
AG:      CMP     AL, [SI]         ;小于al的不要
         JGE     NEXT
         MOV    AL, [SI]
         JMP     OK
NEXT:    CMP     BL, [SI]         ;大于bl的不要
         JLE     OK      
         MOV    BL, [SI]
OK:      INC     SI
         CMP     [SI], BYTE PTR 0 ;结束检测
         JNZ     AG

         MOV     AH,4CH
         INT     21H

CSEG     ENDS
         END     START
