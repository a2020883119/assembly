;T5-2.ASM
;按下按键输出一个hello,但是颜色不同,按下esc退出程序
;常量定义
ROW         = 5                        ;5行
COLUM       = 10                       ;10列
ESCKEY      = 1BH                      ;esc键的ascii码值
;数据段
DSEG        SEGMENT
MESS        DB 'HELLO'                 ;要显示的信息
MESS_LEN    = $ - OFFSET MESS          ;显示信息长度
COLORB      DB 07H, 17H, 0FH, 70H, 74H ;颜色
COLORE      LABEL BYTE                 ;颜色结束判断
DSEG        ENDS
;代码段
CSEG        SEGMENT  
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV    AX, DSEG            ;数据段值
            MOV    DS, AX
;
            MOV    DI, OFFSET COLORB - 1
;                                      ;di指向颜色,-1抵消后面的inc
NEXTC:
            INC    DI                  ;指向下个颜色
            CMP    DI, OFFSET COLORE   ;颜色表是否到头
            JNZ    NEXTE               ;没有, 跳
            MOV    DI, OFFSET COLORB   ;到头,重新指向开头
;
NEXTE:                                 ;设置参数
            MOV    BL, [DI]            ;取颜色
            MOV    SI, OFFSET MESS     ;si指向要输出的字符串信息
            MOV    CX, MESS_LEN        ;字符串长度
            MOV    DH, ROW             ;行号
            MOV    DL, COLUM           ;列号
            CALL   ECHO                ;显示字符串
            MOV    AH, 0               ;从键盘上取一个按下的值
            INT    16H
            CMP    AL, ESCKEY          ;是否键入esc
            JNZ    NEXTC               ;不是,跳
            MOV    AX, 4C00H           ;是,结束程序
            INT    21H
;
;功能:直接写屏显示字符串
;入口参数:ds:si指向字符串首地址
;         cx = 字符串长度, bl = 属性
;         dh = 显示开始符号, dl显示开始列号
;出口参数:无
;
ECHO        PROC
            MOV    AX, 0B800H          ;es:bx指向屏幕缓冲区
            MOV    ES, AX
            MOV    AL, 80              ;计算行号   偏移 = (行号 * 80 + 列号) * 2
            MUL    DH                  ;行号
            XOR    DH, DH              ;清空行号
            ADD    AX, DX              ;具体缓冲区行号加上列值
            ADD    AX, AX              ;* 2
            XCHG   AX, BX              ;换位置
            MOV    AH, AL              ;属性值保存到ah中
            JCXZ   ECHO2               ;cx = 0 ?
;
ECHO1:
            MOV    AL, [SI]            ;取要显示的字符
            INC    SI                  ;指向下一个
            MOV    ES:[BX], AX          ;显示
            INC    BX                  ;指向屏幕缓冲区下一个位置
            INC    BX
            LOOP   ECHO1               ;
ECHO2:
            RET                        ;返回
ECHO        ENDP
CSEG        ENDS
            END    START  