;TT3-36.ASM
;F000:0000H开始的内存区域安排了100个字节的无符号8位二进制数，求它们的和，并转换为对应十进制数的ASCII串
DSEG    SEGMENT
BUFFER  DB 20 DUP (1), 20 DUP (2), 20 DUP (3), 20 DUP (4), 20 DUP (5)
ASCII   DB 5 DUP (?)                                                    ;十六二进制位数最大值是五位十进制数65356    八位二进制最大值127
DSEG    ENDS

CSEG    SEGMENT 
        ASSUME CS:CSEG  
START:  MOV    AX, DSEG              ;初始化
        MOV    DS, AX
        MOV    ES, AX
        
        MOV    SI, OFFSET BUFFER     ;初始化指针
        MOV    DI, OFFSET ASCII + 4  ;直接指向尾部，从后往前放

        MOV    CX, 100               ;求和运算循环
        XOR    AX, AX
AG:     XOR    BX, BX
        MOV    BL, [SI]
        ADD    AX, BX
        INC    SI
        LOOP   AG


        MOV    CX, 5H                ;求和结果转换ACSII码循环
        MOV    BX, 10                ;除数
AG2:    DIV    BX
        ADD    DX, 30H               ;余数转换成数字ASCII码
        MOV    [DI], DL              ;保存正确值
        CMP    AX, 0                 ;被除数不能为零
        JZ     OVER
        DEC    DI
        XOR    DX, DX                ;被除数高位清空   DX中高位，AX中低位     AX商，DX余数         AL商，AH余数
        LOOP   AG2

OVER:   MOV    AH, 4CH
        INT    21H

CSEG    ENDS
        END    START   
        

        
