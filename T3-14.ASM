;T3-14.ASM
;找到五个正数，五个负数，不够补零
MAX_COUNT   = 5
DSEG        SEGMENT
DATA        DB 3, -4, 5, 6, -7, 8, -9, -10, -1, -32, -123, 27, 58, 44, -12, 0
PDATA       DB MAX_COUNT DUP (?)    ;放正数
MDATA       DB MAX_COUNT DUP (?)    ;放负数
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG

START:      MOV    AX, DSEG         ;初始化
            MOV    DS, AX

            MOV    CX, MAX_COUNT    ;清零初始化
            MOV    SI, OFFSET PDATA
            MOV    DI, OFFSET MDATA
            MOV    AL, 0

NEXT1:      MOV    [SI], AL         ;清零循环
            MOV    [DI], AL
            INC    SI
            INC    DI
            LOOP   NEXT1

            MOV    BX, OFFSET DATA  ;查找初始化
            XOR    SI, SI
            XOR    DI, DI

NEXT2:      MOV    AL, [BX]         ;取值
            INC    BX

            CMP    AL, 0             ;判断大小
            JZ     OVER              ;到头了

            JG     PLUS              ;正数处理
            
            CMP    DI, MAX_COUNT     ;负数处理
            JAE    CONT              ;数量够直接跳过处理
			
            MOV    MDATA[DI], AL    ;数量不够正常处理
            INC    DI
            JMP    SHORT CONT        ;检测数量

PLUS:       CMP    SI, MAX_COUNT     ;正数处理
            JAE    CONT              ;数量够直接跳过处理
            
            MOV    PDATA[SI], AL    ;正数正常处理
            INC    SI                

CONT:       MOV    AX, SI           ;核对数量是否满足
            ADD    AX, DI
            CMP    AX, MAX_COUNT + MAX_COUNT
            JB     NEXT2             ;不满足继续找

OVER:       MOV    AH,4CH
            INT    21H

CSEG        ENDS
            END    START