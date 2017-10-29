;T4-2.ASM
;删除字符串中的数字
;
DSEG     SEGMENT
STRING   DB 'AB=C95=ASD', 0 
DSEG     ENDS

CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG
;函数
;ISDECM
;判断一个字符是否为数字符
;AL放字符
;CF为零是字符，否则 不是字符
ISDECM   PROC
         CMP    AL, '0'
         JB     ISDECM1
         CMP    AL, '9'+1
         CMC
ISDECM1: RET
ISDECM   ENDP
;
START:   MOV    AX, DSEG               ;初始化
         MOV    DS, AX

         MOV    SI, OFFSET STRING      ;初始化指针   取
         MOV    DI, SI                 ;存

NEXT:    MOV    AL, [SI]               ;取值
         INC    SI                     ;校正指针
         OR     AL, AL                 ;判断是否到头，是否为零，or影响标志寄存器
         JZ     OK                     ;到头结束循环
         CALL   ISDECM                 ;调用子程序，判断是否为零
         JNC    NEXT                   ;是数字 下一次循环
         MOV    [DI], AL               ;不是数字，进行字符串拼凑
         INC    DI
         JMP    NEXT
OK:      MOV    [DI], AL              ;结束时候把拼凑的字符串零补上
         MOV    AH, 4CH
         INT    21H
CSEG     ENDS
         END    START