;TT5-31.ASM
;将屏幕上所有的大写字母变成小写字母

CSEG        SEGMENT
            ASSUME CS:CSEG
START:
            MOV    AX, 0B800H       ;屏幕缓冲区段地址
            MOV    DS, AX
;
            MOV    SI, 0            ;屏幕缓冲区指针
            MOV    CX, 43 * 80      ;循环次数=字符个数
;
AG:
            MOV    BL, [SI]         ;取值
            CMP    BL, 'a'          ;判断
            JB     NEXT             ;小于跳
            CMP    BL, 'z'          ;判断
            JA     NEXT             ;大于跳
            AND    BL, 11011111B    ;小写变大写
            MOV    [SI], BL        ;替换
;
NEXT:
            INC    SI              ;下一个
            INC    SI
            LOOP   AG

            MOV    AH, 4CH
            INT    21H
            

CSEG        ENDS
            END    START