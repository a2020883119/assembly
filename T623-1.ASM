;T623-1.ASM
;P218
;说明:计算十二个组合的bcd码,求和,结果保存在sum中
DSEG        SEGMENT
NUM1        DB 23H, 45H, 67H, 89H, 93H, 36H,12H, 66H, 78H, 43H, 99H
RESULT      DB 2 DUP (0)
DSEG        ENDS

CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            MOV       AX, DSEG              ;初始化
            MOV       DS, AX
;
            MOV       BX, OFFSET NUM1       ;bx指向bcd码串头
            MOV       CX, 11                ;循环次数
            XOR       AL, AL                ;清空
            XOR       AH, AH                ;累加器
NEXT:
            ADD       AL, [BX]              ;开始加
            DAA                              ;纠正低四位值
            ADC       AH, 0                  ;计算百位,千位
            XCHG      AH, AL                ;高四位,低四位交换
            DAA                              ;纠正高四位值
            XCHG      AH, AL                ;归位
            INC       BX                    ;准备加下一个数
            LOOP      NEXT                   ;循环
            XCHG      AH, AL                ;换位,为了保存时正确显示
            MOV       WORD PTR RESULT, AX
;
            MOV      AH, 4CH
            INT      21H       
CSEG        ENDS
            END       START