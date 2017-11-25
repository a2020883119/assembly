;TT5-26.ASM
;输出指定中断向量
; RANGE       EQU 256                        ;中断向量表个数
; LITTERANGE  EQU 4 * 20                     ;每次显示20个
DSEG        SEGMENT                        ;ASCII码对应表
BUFFER      DB 3
SSIZE       DB ?
INTNUM      DB 0, 0, 0                     ;存放中断号字符串 
TABLE       DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
COUNT       DB 0, 0, 0, ' '                ;存放序号字符串
SAVESEG     DB 0, 0, 0, 0                  ;存放段值字符串
COLON       DB ':'                         ;冒号
SAVEOFFSET  DB 0, 0, 0, 0                  ;存放偏移字符串
THEEND      DB '$'                         ;回车换行字符串结束符
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            MOV    AX, DSEG                ;DS指向数据段
            MOV    DS, AX
;
            XOR    AX, AX                  ;ES指向中断向量表数据段
            MOV    ES, AX
;
            MOV    DX, OFFSET BUFFER       ;取中断号
            MOV    AH, 0AH
            INT    21H
;
            MOV    SI, OFFSET TABLE        ;si指向表
            MOV    AX, WORD PTR INTNUM     ;取中断号字符串
;
FIND:
            CMP    AL, [SI]                ;转换
            JZ     FIND2
            INC    SI
            JMP    FIND
;
FIND2:
            XOR    BX, BX                  ;bx存放转换后的结果
            SUB    SI, OFFSET TABLE
            ADD    BX, SI
            SHL    BX, 1
            SHL    BX, 1
            SHL    BX, 1
            SHL    BX, 1
;
            MOV    SI, OFFSET TABLE
;
FIND3:
            CMP    AH, [SI]                 ;转换
            JZ     FIND4
            INC    SI
            JMP    FIND3
;
FIND4:
            SUB    SI, OFFSET TABLE         ;bx存放转换后的结果
            ADD    BX, SI
            SHL    BX, 1
            SHL    BX, 1
            ; MOV    CX, RANGE               ;循环次数
            ; XOR    BX, BX                  ;偏移从零开始
; AG:
            MOV    SI, OFFSET COUNT        ;生成序号字符串,并存放在指定位置
            CALL   GETCOUNT
;
            MOV    AX, ES : [BX]          ;取偏移
;
            MOV    SI, OFFSET TABLE        ;生成偏移字符串,并存放在指定位置
            MOV    DI, OFFSET SAVEOFFSET
            CALL   AXTOHEXSAVE
;
            INC    BX                      ;指向下一个
            INC    BX
;
            MOV    AX, ES : [BX]          ;取段值
; 
            MOV    DI, OFFSET SAVESEG      ;生成段值字符串,并存放在指定位置
            CALL   AXTOHEXSAVE
;
            MOV    DX, OFFSET COUNT        ;显示生成的字符串 格式为xxx xxxx:xxxx
            CALL   DISPMESSNEWLINE
;
            ; INC    BX                      ;指向下一个
            ; INC    BX
; ;
            ; MOV    SI, LITTERANGE          ;计算是否够20个
            ; XOR    DX, DX
            ; MOV    AX, BX
            ; DIV    SI
; ;
            ; CMP    DX, 0                   ;暂停,接收按键
            ; JNZ    NEXT
; ;
            ; MOV    AH,  8                  ;结束
            ; INT    21H           
;
; NEXT:
            ; LOOP   AG
 
            MOV    AH, 4CH
            INT    21H
;功能:将序号转换成ascii码形式并存放在指定位置
;入口参数:bx存放序号, si指向存放处
;出口参数:无
GETCOUNT    PROC
            PUSH    BX
            PUSH    DX
            PUSH    AX
            PUSH    CX
;
            SHR     BX, 1         ;除4
            SHR     BX, 1
            XOR     CX, CX        ;计数器
            MOV     AX, BX        ;取被除数
            MOV     BX, 10        ;除数
            
;
NEXT2:            
            XOR     DX, DX        ;清空被除数高位
            DIV     BX            ;除
            INC     CX            ;计数器加一
            PUSH    DX            ;余数压入栈中
            CMP     AX, 0         ;被除数为零,结束循环
            JZ      NEXT1         ;
            JMP     NEXT2         ;不为零,继续
;
NEXT1:
            POP     AX            ;余数出栈
            ADD     AL, 30H       ;变成ascii码
            MOV     [SI], AL      ;存放制定处
            INC     SI            ;指向下一个
            LOOP    NEXT1         ;循环
;
            POP     CX
            POP     AX
            POP     DX
            POP     BX 
            RET
GETCOUNT    ENDP 
;功能:将ax中的值转换成十六进制表示的ascii码串并存放在指定位置
;入口参数:ax存放要转换的值,si指向ascii码转换表,di指向存放位置
;出口参数:无
AXTOHEXSAVE PROC
;12-15
            PUSH   AX
            MOV    AL, AH
            SHR    AL, 1
            SHR    AL, 1
            SHR    AL, 1
            SHR    AL, 1
            AND    AX, 000FH
            PUSH   SI
            ADD    SI, AX
            MOV    AL, [SI]
            POP    SI
            MOV    [DI], AL
            INC    DI
;8-11
            POP    AX
            PUSH   AX
            MOV    AL, AH
            
            AND    AX, 000FH
            PUSH   SI
            ADD    SI, AX
            MOV    AL, [SI]
            POP    SI
            MOV    [DI], AL
            INC    DI
;4-7           
            POP    AX
            PUSH   AX
            SHR    AL, 1
            SHR    AL, 1
            SHR    AL, 1
            SHR    AL, 1
            AND    AX, 000FH
            PUSH   SI
            ADD    SI, AX
            MOV    AL, [SI]
            POP    SI
            MOV    [DI], AL
            INC    DI
;0-3
            POP    AX
            AND    AX, 000FH
            PUSH   SI
            ADD    SI, AX
            MOV    AL, [SI]
            POP    SI
            MOV    [DI], AL
;
            RET
AXTOHEXSAVE ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESSNEWLINE    PROC
            MOV    AH, 9            ;调用显示字符串中断
            INT    21H
            RET  
DISPMESSNEWLINE    ENDP
CSEG        ENDS
            END    START