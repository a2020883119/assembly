;TT3-35.ASM
;从地址 F000:0000H开始的64K字节字校验和，并转换为十六进制数的ASCII码串
DSEG     SEGMENT
ASCII    DB 5 DUP (0)
DSEG     ENDS

CSEG     SEGMENT
         ASSUME CS:CSEG 
START:   MOV    AX, 0F000H
         MOV    DS, AX
         MOV    BX, 0000H

         MOV    CX, 32 * 1024        ;64KB   初始化字校验循环
         XOR    AX, AX

AG:      ADD    AX, [BX]             ;字校验循环
         INC    BX
         INC    BX
         LOOP   AG

         ASSUME DS:DSEG               ;转ASCII码循环初始化
         MOV    BX, AX
         MOV    AX, DSEG
         MOV    DS, AX
         MOV    SI, OFFSET ASCII
         MOV    AX,BX
         MOV    CX, 4
AG2:     MOV    BX, AX                   ;AX备份正确字校验结果
         AND    BX, 0000000000001111B    ;清空影响位
         CMP    BX, 10
         JS     LESSTEN
         ADD    BX, 'A'
         JMP    OK
LESSTEN: ADD    BX, '0'                  ;
OK:      MOV    [SI], BX
         INC    SI
         MOV    DI, CX                   ;准备下一个处理的数据
         MOV    CL, 4
         SHR    AX, CL
         MOV    CX, DI
         LOOP   OK

         MOV    AH, 4CH
         INT    21H
CSEG     ENDS 
         END    START