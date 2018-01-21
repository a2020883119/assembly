;STRCAT.ASM
DSEG        SEGMENT
;STRR        DB '0'
STR1        DB 'LEARN TO SAY NO!', 0
STR2        DB 'TODAY,I WILL ', 20 DUP (0)
STR3        DB '$'
DSEG        ENDS

CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            MOV        AX, DSEG               ;初始化段值  
            MOV        DS, AX
;
            MOV        SI, OFFSET STR2        ;函数入口参数设置
            MOV        DI, OFFSET STR1
;
            CALL       STRCAT                 ;拼接函数
;
            MOV        DX, OFFSET STR2        ;函数入口参数设置
            CALL       DISPMESS               ;显示字符串中断函数
;
            MOV        AH, 4CH
            INT        21H

;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS    PROC
            PUSH       AX
            MOV        AH, 9                  ;调用显示字符串中断
            INT        21H
            POP        AX
            RET
DISPMESS    ENDP
;子程序名:STRCAT
;功    能:在字符串1末尾追加字符串2
;入口参数:DS:SI=字符串1起始地址的段值:偏移
;         DS:DI=字符串2起始地址的段值:偏移
;出口参数:无
;说    明:不考虑字符串1后面是否有足够的空间
STRCAT      PROC
            PUSH       ES                     ;寄存器保护
            PUSH       AX
            PUSH       CX
            PUSH       SI
            PUSH       DI
;
            CLD                                ;设置方向为增
            PUSH       DS                      ;复制DS到ES
            POP        ES
            PUSH       DI                      ;保存字符串2偏移
            MOV        DI, SI                  ;DI指向字符串1的开头
            XOR        AL, AL                  ;设置要找的字符,要找的字符为0
            MOV        CX, 0FFFFH              ;计数
            REPNZ      SCASB                   ;查找字符串1的末尾偏移,结束循环
            LEA        SI, [DI - 1]            ;SI指向字符串1的末尾
            POP        DI                      ;恢复DI,DI指向字符串2的开头
            MOV        CX, 0FFFFH              ;计数
            REPNZ      SCASB                   ;查找字符串2的末尾偏移,结束循环,目的统计字符串2的长度
            NOT        CX                      ;字符串2的长度
            SUB        DI, CX                  ;DI重新指向字符串2的开头
            XCHG       SI, DI                  ;SI指向字符串1的末尾,DI指向字符串2的开头
;            TEST       SI, 1                   ;写书都不严谨,怎样严谨呢?奇偶是PF
            JZ         STRCAT1                  ;判断地址是否奇偶
            MOVSB                               ;奇数处理,先移一字节
            DEC        CX                       ;数量减一
STRCAT1:    
            SHR        CX, 1                    ;字符串长度除2
            REPZ       MOVSW                    ;开始移字符串
            JNC        STRCAT2                  ;我看不懂,屎一样的的代码
            MOVSB
STRCAT2:
            POP        DI                       ;恢复寄存器
            POP        SI
            POP        CX
            POP        AX
            POP        ES
            RET
STRCAT      ENDP

CSEG        ENDS
            END        START
