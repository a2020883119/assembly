;T4-1.ASM
;按十六进制显示地址为F000:0000H的字单元内容
;子程序调用
DSEG       SEGMENT
BUFF       DB 4 DUP (0)
           DB 'H', 0DH, 0AH, '$'
DSEG       ENDS
;
CSEG       SEGMENT
           ASSUME CS:CSEG, DS:DSEG
START:     MOV    AX, DSEG            ;初始化
           MOV    DS, AX              ;

           MOV    AX, 0F000H          ;取指定值
           MOV    ES, AX
           MOV    DX, ES : [0]
           MOV    BX, OFFSET BUFF     ;指向缓冲区
           CALL   HTASCS              ;调用函数，指定16位二进制数，转换为十六进制ASCII码串
;
           MOV    DX, OFFSET BUFF
           MOV    AH, 9
           INT    21H
;
           MOV    AH, 4CH
           INT    21H

;指定16位二进制数，转换为十六进制ASCII码串
HTASCS     PROC
           MOV    CX, 4            ;循环4次
HTASCS1:   ROL    DX, 1            ;向左移动四位
           ROL    DX, 1
           ROL    DX, 1
           ROL    DX, 1
           MOV    AL, DL           ;取一个4位二进制数， 四位二进制数是一个十六进制数
           CALL   HTOASC            ;调用子程序，将四位二进制数转换为一个十六进制数ASCII码
           MOV    [BX], AL         ;保存在设置好的缓冲区
           INC    BX               ;指针移向下个空位置
           LOOP   HTASCS1          ;循环
           RET                     ;返回被调用的地方
HTASCS     ENDP
;
HTOASC     PROC
           AND    AL, 0FH          ;取四位有效值
           CMP    AL, 9            ;是否大于十
           JBE    HTOASC1          ;小于十处理
           ADD    AL, 37H          ;大于十进行字母处理
HTOASC2:   RET                     ;返回
HTOASC1:   ADD    AL, 30H          ;小于十，数字处理
           JMP    HTOASC2          ;返回
HTOASC     ENDP

CSEG       ENDS   
           END    START


