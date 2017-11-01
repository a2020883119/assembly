;TT4-11.ASM
;子程序名：TOCOMPLEMENT
;功能：求32位二进制数补码
;入口参数：AX:BX   32位二进制数
;出口参数：AX:BX   32位二进制数的补码

TOCOMPLEMENT    PROC
      NOT       AX          ;取反
      NOT       BX
      ADD       BX, 1       ;加一
      ADC       AX, 0       ;进位
TOCOMPLEMENT    ENDP