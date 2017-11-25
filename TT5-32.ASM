;TT5-32.ASM
;统计屏幕上字母的个数

CSEG        SEGMENT
            ASSUME CS:CSEG
START:
            MOV    AX, 0B800H       ;屏幕缓冲区段地址
            MOV    DS, AX
;
            MOV    SI, 0            ;屏幕缓冲区指针
            MOV    CX, 43 * 80      ;循环次数=字符个数
            XOR    DX, DX
;
AG:
            MOV    BX, WORD PTR [SI]         ;取值
            CMP    BL, 'A'          ;判断
            JB     NEXT2             ;小于跳
            CMP    BL, 'Z'          ;判断
            JA     NEXT             ;大于跳
            INC    DX
            JMP    NEXT2

NEXT:
            CMP    BL, 'a'          ;判断
            JB     NEXT2             ;小于跳
            CMP    BL, 'z'          ;判断
            JA     NEXT2             ;大于跳
            INC    DX
NEXT2:
            INC    SI               ;下一个
            INC    SI
            LOOP   AG
;
            MOV    AX, DX           ;输出数量
            XOR    CX, CX           ;计数器
NEXT4:
            XOR    DX, DX           ;被除数高位清零
            MOV    BX, 10           ;除数
            DIV    BX               ;除
            PUSH   DX               ;具体值压入栈中
            INC    CX               ;计数器加一
            CMP    AX, 0            ;是否除尽
            JZ     NEXT3            ;是,跳
            JMP    NEXT4            ;循环

NEXT3:      
            POP    DX               ;从栈中取出要用的值
            ADD    DX, 30H          ;转换ascii码
            MOV    AH, 2            ;输出
            INT    21H
            LOOP   NEXT3

            
;
            MOV    AH, 4CH          ;结束
            INT    21H
            

CSEG        ENDS
            END    START