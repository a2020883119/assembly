;TT5-29.ASM
;直接写屏法,在屏幕上循环显示26个大写字母,按下任意键终止程序
;
MAXROW      EQU 43                         ;屏幕高度
MAXCOLUM    EQU 80                         ;屏幕宽度
A           EQU 41H                        ;'A'
Z           EQU 5AH                        ;'B'
;
DSEG        SEGMENT

DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV    AX, DSEG                ;数据段
            MOV    DS, AX
;
            MOV    BL, A                   ;设置初值,'A'
            MOV    BH, 0EH                 ;
            MOV    DH, 0                   ;开始行
            MOV    DL, 0                   ;开始列
;

NEXT3:
            CALL   ECHOCH                  ;将指定字符输出到屏幕指定位置
            INC    BL                      ;下一个字母
            CMP    BL, Z + 1               ;是否到头
            JNZ    NEXT2                   ;没有,跳
            MOV    BL, A                   ;字母重置
NEXT2:
            INC    DL                      ;列+1
            CMP    DL, MAXCOLUM            ;列是否到头
            JNZ    NEXT                    ;没有,跳
            MOV    DL, 0                   ;列重置
            INC    DH                      ;到头行数加一
            CMP    DH, MAXROW              ;是否到最低一行
            JNZ    NEXT                    ;不是,跳
            DEC    DH                      ;到底了,减去多加的1
            CALL   ROLLUP                  ;滚屏,腾出最下面一行
            
NEXT:
            
            MOV    AH,1                    ;缓冲区是否有字符可读
            INT    16H
            JNZ     OVER                   ;有,跳
;
            JMP    NEXT3                   ;循环
            
;
OVER:
            MOV    AH, 4CH                 ;结束
            INT    21H


;功能:屏幕向上滚动一行
;入口参数:无
;出口参数:无  
ROLLUP      PROC
            
            PUSH   AX
            PUSH   ES
            PUSH   BX      
            PUSH   DX
            PUSH   SI
            PUSH   DI
            PUSH   CX    
;    
            MOV    AX, 0B800H         ;设置段值
            MOV    ES, AX
; 
            MOV    SI, 80             ;指向要上移的行
            SHL    SI, 1
            MOV    DI, 0              ;指向要移动的位置
            MOV    CX, 80 * 42        ;循环次数, 80 * 42 个字符
AG:
            MOV    AX, ES : [SI]      ;上移循环
            MOV    ES:[DI],  AX
            INC    SI
            INC    SI
            INC    DI
            INC    DI
            LOOP   AG
;
            MOV    CX, 80
            MOV    AL, 0
;
AG2:
            MOV    ES:[DI],  AX       ;最后一行清空
            INC    DI
            INC    DI
            LOOP   AG2           
;
            POP    CX
            POP    DI
            POP    SI
            POP    DX
            POP    BX
            POP    ES
            POP    AX

            RET
ROLLUP      ENDP





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