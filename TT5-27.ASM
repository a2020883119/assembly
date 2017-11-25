;TT5-27.ASM
;用十六进制数的形式显示所按键的扫描码及对应的ascii码,连续按两次回车终止程序
;功能:将ax中的值转换成十六进制表示的ascii码串并存放在指定位置
;入口参数:ax存放要转换的值,si指向ascii码转换表,di指向存放位置
;出口参数:无
DSEG        SEGMENT
TABLE       DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
SAVESEG     DB 0, 0, '-', 0, 0             ;存放段值字符串
THEEND      DB 0DH, 0AH,'$'                ;回车换行字符串结束符
DSEG        ENDS
;
CSEG        SEGMENT
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV    AX, DSEG                ;设置段值
            MOV    DS, AX
;
            MOV    AH, 0                   ;取按键
            INT    16H                      ;al存放ascii码,ah存放扫描码
;
PUT:
            MOV    SI, OFFSET TABLE        ;转换ax用ascii码串表示
            MOV    DI, OFFSET SAVESEG
            CALL   AXTOHEXSAVE
;
            MOV    DX, OFFSET SAVESEG      ;显示ascii码串
            CALL   DISPMESSNEWLINE
;
            CMP    AL, 0DH                 ;判断是否输入回车
            JNZ    NEXT                    ;不是跳
;
            MOV    AH, 0                   ;接收到回车后在接受一个字符进行判断
            INT    16H
;
            CMP    AL, 0DH                 ;判断
            JNZ    PUT                     ;不是正常输出
            JMP    OVER                    ;是,结束
NEXT: 
            JMP    START                   ;循环
        
OVER:
            MOV    AH, 4CH                 ;结束
            INT    21H
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESSNEWLINE    PROC
            PUSH   AX
            MOV    AH, 9            ;调用显示字符串中断
            INT    21H
            POP    AX
            RET  
DISPMESSNEWLINE    ENDP
;功能:将ax中的值转换成十六进制表示的ascii码串并存放在指定位置
;入口参数:ax存放要转换的值,si指向ascii码转换表,di指向存放位置
;出口参数:无
AXTOHEXSAVE PROC
;12-15
            PUSH   AX
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
;
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
            POP    AX
            RET
AXTOHEXSAVE ENDP

CSEG        ENDS
            END    START