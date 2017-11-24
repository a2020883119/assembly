;T5-5.ASM
;显示时钟
;常量定义
COUNT_VAL   = 18                         ;间隔数
DPAGE       = 0                          ;显示页号
ROW         = 0                          ;显示时钟行号
COLUMN      = 80 - BUFF_LEN              ;显示时钟开始列号
COLOR       = 07H                        ;黑底白字
;代码
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:CSEG
;
COUNT       DW COUNT_VAL                 ;计数值存放处
HHHH        DB ?, ?, ':'                 ;时
MMMM        DB ?, ?, ':'                 ;分
SSSS        DB ?, ?                      ;秒
BUFF_LEN    = $ - OFFSET HHHH            ;时间字符串长度长度
CURSOR      DW ?                         ;原光标位置
;
NEW1CH:
            CMP    CS:COUNT, 0          ;计数器是否为零,为零时显示
            JZ     NEXT                 ;是,跳
            DEC    COUNT                ;不是,计数器减一
            IRET                        ;返回
;
NEXT:
            MOV    CS:COUNT, COUNT_VAL  ;重新设置计数器
            STI                         ;开中断
            PUSH   DS                   ;现场备份
            PUSH   ES
            PUSH   AX
            PUSH   BX
            PUSH   CX
            PUSH   DX
            PUSH   SI
            PUSH   BP
;
            PUSH   CS                   ;设置段寄存器
            POP    DS
            PUSH   DS
            POP    ES
            CALL   GET_T                ;获取时间字符串
            MOV    BH, DPAGE            ;获取光标位置
            MOV    AH, 3 
            INT    10H
            MOV    CURSOR, DX           ;保存光标位置, dh=行号,dl=列号
            MOV    BP, OFFSET HHHH      ;指向时间字符串开头
            MOV    BH, DPAGE            ;显示页号
            MOV    DH, ROW              ;行号
            MOV    DL, COLUMN           ;列号
            MOV    BL, COLOR            ;字体颜色
            MOV    CX, BUFF_LEN         ;原文错误,时间字符串长度
            MOV    AL, 0                ;写模式
            MOV    AH, 13H              ;显示字符串
            INT    10H
            MOV    BH, DPAGE            ;选择输出页
            MOV    DX, CURSOR           ;光标具体位置
            MOV    AH, 2                ;恢复光标
            INT    10H
            POP    BP                   ;恢复现场
            POP    SI
            POP    DX
            POP    CX
            POP    BX
            POP    AX
            POP    ES
            POP    DS
            IRET
;
;
;
GET_T       PROC
            MOV    AH, 2               ;取时间
            INT    1AH                 ;出口参数, ch=bcd码格式的小时, cl=bcd码格式的分钟, dh=bcd码格式的秒 ,dl=00h表示标准时间,否则夏令时, cf=0时钟再走,否则时钟停止
            MOV    AL, CH             ;小时转换为ascii码表示
            CALL   TTASC               ;把两位压缩的bcd码转换为对应的ascii码
            XCHG   AH, AL              ;抵消下一句指令的位置误差
            MOV    WORD PTR HHHH, AX   ;保存
            MOV    AL, CL              ;分转换ascii码
            CALL   TTASC
            XCHG   AH, AL              ;同上
            MOV    WORD PTR MMMM, AX
            MOV    AL, DH              ;秒转换ascii码
            CALL   TTASC
            XCHG   AH, AL              ;同上
            MOV    WORD PTR SSSS, AX
            RET
GET_T       ENDP
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
;===========================================================================
;初始化部分代码和变量
;
OLD1CH      DD ?                              ;保存原中断向量
START:
            PUSH   CS                         ;设置段地址
            POP    DS
            MOV    AX, 351CH                  ;取1ch号中断向量
            INT    21H
            MOV    WORD PTR OLD1CH, BX       ;保存偏移
            MOV    WORD PTR OLD1CH + 2, ES   ;保存段地址
            MOV    DX, OFFSET NEW1CH         ;重置新的1ch号中断向量
            MOV    AX, 251CH
            INT    21H
; 
; 
            MOV    AH, 0                      ;等待输入按键
            INT    16H

            LDS    DX, OLD1CH                 ;取保存的原1ch号中断向量
            MOV    AX, 251CH
            INT    21H
               
            MOV    AH, 4CH                    ;结束
            INT    21H
CSEG        ENDS
            END    START


