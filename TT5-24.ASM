;TT5-24.ASM
;从rt/coms ram中获得系统当前时间并显示
CMOS_PORT   EQU 70H                   ;CMOS端口地址
CMOS_REGA   EQU 0AH                   ;状态寄存器A地址
UPDATE_F    EQU 80H                   ;更新标志位
CMOS_SEC    EQU 00H                   ;秒
CMOS_MIN    EQU 02H                   ;分
CMOS_HOUR   EQU 04H                   ;时
CMOS_WEEK   EQU 06H                   ;星期几
CMOS_DAY    EQU 07H                   ;天
CMOS_MONTH  EQU 08H                   ;月
CMOS_YEAR   EQU 09H                   ;年

DSEG        SEGMENT
YEAR        DB ?, ?, '-'              ;年ASCII码串
MONTH       DB ?, ?, '-'              ;月ASCII码串
DAY         DB ?, ?, ' '              ;天ASCII码串
WEEK        DB ?, ?, ' '              ;星期几ASCII码串
HOUR        DB ?, ?, ':'              ;时ASCII码串
MINUTE      DB ?, ?, ':'              ;分ASCII码串
SECOND      DB ?, ?, '$'              ;秒ASCII码串
DSEG        ENDS

CSEG        SEGMENT
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV    AX, SEG SECOND     ;初始化段寄存器
            MOV    DS, AX
;
UIP:
            MOV    AL, CMOS_REGA      ;时钟是否可读
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            TEST   AL, UPDATE_F       ;对比
            JNZ    UIP                ;不能,跳
;S
            MOV    AL, CMOS_SEC       ;读秒
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR SECOND, AX
;M
            MOV    AL, CMOS_MIN       ;读分
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR MINUTE, AX
;H
            MOV    AL, CMOS_HOUR      ;读时
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR HOUR, AX
;WEEK
            MOV    AL, CMOS_WEEK      ;读星期几
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR WEEK, AX
;DAY
            MOV    AL, CMOS_DAY       ;读天
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR DAY, AX
;MONTH
            MOV    AL, CMOS_MONTH     ;读月
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR MONTH, AX
;YEAR
            MOV    AL, CMOS_YEAR      ;读年
            OUT    CMOS_PORT, AL
            JMP    $ + 2
            IN     AL, CMOS_PORT + 1
            CALL   TTASC
            XCHG   AH, AL
            MOV    WORD PTR YEAR, AX
;
            MOV    DX, OFFSET YEAR    ;显示日期
            CALL   DISPMESS

            MOV    AH, 4CH
            INT    21H
;子程序名称:TTASC
;功能:把两位压缩的bcd码转换为对应的ascii码
;入口参数:al=压缩bcd码
;出口参数:ah=高位bcd码对应ascii码,al低位bcd码对应ascii码
;
TTASC       PROC
            MOV    AH, AL          ;复制
            AND    AL, 0FH         ;只要低四位
            SHR    AH, 1           ;只要高四位
            SHR    AH, 1
            SHR    AH, 1
            SHR    AH, 1
            ADD    AX, 3030H       ;转换ascii码
            RET
TTASC       ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS    PROC
            MOV    AH, 9            ;调用显示字符串中断
            INT    21H
            RET  
DISPMESS    ENDP
;
CSEG        ENDS
            END    START