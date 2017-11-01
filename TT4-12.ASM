;TT4-12.ASM
;子程序名：ONEHEXTOASCII
;功能：查表法，实现把一个十六进制数转换为对应的ASCII码
;入口参数:AL存放一个十六进制数,SI指向ASCII码表头
;出口参数:AL存放一个十六位进制数的ASCII码
;
ASCII DB '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

ONEHEXTOASCII    PROC
        DEC      AL           ;AL减一
        ADD      SI, AL       ;指向表中准确位置
        MOV     AL, [SI]      ;从表中取值
ONEHEXTOASCII    ENDP 
       
