;TT5-33.ASM
;判断屏幕上是否显示有'AB'字符串,
;在屏幕最底下显示提示信息
DSEG        SEGMENT
STRING      DB 'AB'
MESS1       DB 'YES'
MESS2       DB 'NO'
DSEG        ENDS

CSEG        SEGMENT
            ASSUME CS:CSEG
START:
            MOV    AX, 0B800H       ;屏幕缓冲区段地址
            MOV    ES, AX

            MOV    AX, DSEG
            MOV    DS, AX
;
            MOV    SI, 0            ;屏幕缓冲区指针
            MOV    DI, OFFSET STRING
            MOV    CX, 43 * 80       ;循环次数=字符个数
            XOR    DX, DX
;
AG:
            MOV    BX, ES : [SI]         ;取值
            CMP    BL, DS : [DI]          ;判断
            JNZ    NEXT
            MOV    BX, ES : [SI + 2]
            CMP    BL, DS : [DI + 1]
            JZ     OK

NEXT:
            INC    SI                       ;下一个
            INC    SI
            LOOP   AG
;
NOTOK:
            MOV    AX, 0B800H               ;输出n
            MOV    DS, AX
            MOV    AH, 0F4H
            MOV    AL, 'N'
            MOV    SI, 0 + 160 * 42
            MOV    [SI], AX
            JMP    OVER

OK:         
            MOV    AX, 0B800H              ;输出y
            MOV    DS, AX
            MOV    AH, 0F4H
            MOV    AL, 'Y'
            MOV    SI, 0 + 160 * 42
            MOV    [SI], AX     
;
OVER:
            MOV    AH, 4CH          ;结束
            INT    21H
;
;功能:在屏幕指定位置显示一个字符
;入口参数:bh=字符颜色, bl=字符, dh=行号, dl=列号
;出口参数:无            
ECHOCH      PROC
            PUSH   AX
            PUSH   ES
            PUSH   BX      
            PUSH   DX    
;    
            MOV    AX, 0B800H              ;段地址
            MOV    ES, AX
            MOV    AL, 80                  ;根据行号列号计算显示地址 (行号 * 80 + 列号) * 2
            MUL    DH
            XOR    DH, DH
            ADD    AX, DX
            ADD    AX, AX
            XCHG   AX, BX
            MOV    ES:[BX],  AX
;
            POP    DX
            POP    BX
            POP    ES
            POP    AX
            RET
ECHOCH      ENDP

CSEG        ENDS
            END    START