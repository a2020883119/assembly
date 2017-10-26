;TT3-37.ASM
;从地址F000:0000H开始的内存区域存放了1024个16位有符号数，求其中正数，负数，和零的个数，并转换为十进制数ASCII串
DSEG     SEGMENT
BUFFER   DW 500 DUP (1), 500 DUP (-1), 24 DUP (0)
BUFFER2  DD 0, 0, 0                                                                         ;
DSEG     ENDS

CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG
START:   MOV    AX, DSEG                   ;初始化
         MOV    DS, AX
         MOV    CX, 1024                   ;循环次数
         MOV    SI, OFFSET BUFFER          ;指向要被检测的数据的开头

         XOR    DX, DX                     ;清空用来计数 < 0
         XOR    BX, BX                     ;清空用来计数 = 0
         XOR    DI, DI                     ;清空用来计数 > 0

AG:      MOV    AX, [SI]
         CMP    AX, 0                      ;判断零
         JNZ    NEXT
         INC    BX
         JMP    OK
NEXT:    CMP    AX, 0                      ;判断正负
         JG     NEXT2
         INC    DX
         JMP    OK
NEXT2:   INC    DI
OK:      INC    SI                         ;准备下一次
         INC    SI
         LOOP   AG
         
         PUSH   DX                         ;保存结果
         PUSH   BX
         PUSH   DI

         MOV    DI, OFFSET BUFFER2 + 11    ;从后往前放，可以直观看到正确结果
         MOV    CX, 3                      ;循环三次
         MOV    BX, 10                     ;除数
         
AG2:     XOR    DX, DX                     ;被除数清零，不清0会溢出，发生异常
         POP    AX                         ;取保存的值
         PUSH   CX                         ;保存外层循环数，进入内层循环计数
         MOV    CX,4
AG3:     DIV    BX                         ;内循环，变成ASCII码
         ADD    DX, 30H
         MOV    [DI], DL
         DEC    DI                         ;从后往前放
         CMP    AX, 0                      ;异常处理，被除数不能为零
         JNZ    NEXT3
         DEC    CX
AG4:     MOV    [DI], BYTE PTR '0'        ;异常处理循环
         DEC    DI                        ;一次循环中移动了两次，故cx人为减一
         LOOP   AG4                        
         POP    CX                        ;外层循环数恢复准备回到外层循环
         JMP    NEXT4
NEXT3:   XOR    DX, DX
         LOOP   AG3                       ;内循环
NEXT4:   LOOP   AG2                       ;外循环
         

         MOV     AH, 4CH
         INT     21H

CSEG     ENDS
         END     START
         
         

         
         