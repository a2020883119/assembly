;STRSTR.ASM
DSEG        SEGMENT
STR1        DB '12345678910', 0
STR2        DB '345', 0
STR3        DB 0, 0, 0, 0, '$'
DSEG        ENDS

CSEG        SEGMENT
            ASSUME DS:DSEG, CS:CSEG
START:
            MOV        AX, DSEG               ;设置段值
            MOV        DS, AX
            MOV        ES, AX
;
            PUSH       DS                     ;入栈,字符串二地址
            MOV        AX, OFFSET STR2
            PUSH       AX
            PUSH       DS                     ;入栈,字符串一地址
            MOV        AX, OFFSET STR1
            PUSH       AX
            CALL       FAR PTR STRSTR         ;查找是否是子串函数
;
            MOV        BX, OFFSET STR3        ;显示子串在母串中的地址
            MOV        [BX], DX
            MOV        [BX + 2], AX
            MOV        DX, BX
            CALL       DISPMESS
;
            MOV        AH,4CH                 ;结束
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
;子程序名:STRSTR
;功    能:判断字符串2是否为字符串1的子串
;入口参数:指向字符串的远指针
;出口参数:DX:AX返回指向字符串2在字符串1中首次出现处的指针
;说    明:调用方法如下
;         (1)压入字符串2的远指针
;         (2)压入字符串1的远指针
;         (3)CALL FAR PTR STRSTR
STRSTR      PROC       FAR           
            PUSH       BP
            MOV        BP, SP                 ;备份sp
            PUSH       DS
            PUSH       ES
            PUSH       BX
            PUSH       CX
            PUSH       SI
            PUSH       DI
;
            LES        BX, [BP + 10]         ;取得字符串2的段值和偏移
            CMP        BYTE PTR ES : [BX], 0 ;字符串2是否为空
            JNZ        STRSTR1                ;不为空跳
            MOV        DX, [BP + 8]          ;为空时指向字符串1地址
            MOV        AX, [BP + 6]
            JMP        SHORT STRSTR6          ;结束
;
STRSTR1:    
            CLD                               ;设置方向,增加
            LES        DI, [BP + 6]          ;指向字符串1的地址
            PUSH       ES                     ;备份es
            MOV        BX, DI                ;di为字符串1偏移
            XOR        AX, AX                ;清空
            MOV        CX, 0FFFFH            ;计数器赋值
            REPNZ      SCASB                 ;计算字符串1长度
            NOT        CX                    ;得到具体长度
            MOV        DX, CX                ;cx为字符串1的长度
;
            LES        DI, [BP + 10]         ;字符串2的地址
            PUSH       ES                    ;备份es
            MOV        BP, DI                ;di指向字符串2的地址
            XOR        AX, AX                ;清空
            MOV        CX, 0FFFFH            ;计数器设置
            REPNZ      SCASB                 ;计算字符串2的长度  
            NOT        CX                    ;得到字符串2的具体长度
            DEC        CX                    ;去掉结束符0
            POP        DS                    ;恢复es到ds
            POP        ES                    ;恢复es到es
;
STRSTR2:
            MOV        SI, BP                ;bp指向字符串2
            LODSB                            ;加载字符串2的字符
            MOV        DI, BX               ;bx指向字符串1
            XCHG       CX, DX               ;cx是字符串2的长度,dx是字符串1的长度
            REPNZ      SCASB                ;从字符串1中找从字符串2保存在ax中的字符
            MOV        BX, DI               ;di指向在字符串1找到相同字符的位置
            JNZ        STRSTR3              ;没有找到相同字符
            CMP        CX, DX               ;找到,字符串1剩余的字符数是否大于字符串2的长度
            JNB        STRSTR4               ;大于时,表示字符串1有包含字符串2的可能
STRSTR3:
            XOR        BX, BX               ;没找到的处理
            MOV        ES, BX               ;
            MOV        BX, 1
            JMP        SHORT STRSTR5        ;结束
;
STRSTR4:
            XCHG       CX, DX               ;dx为字符串2的长度,cx为字符串1的剩余长度
            MOV        AX, CX               ;cx为字符串2的长度
            DEC        CX                   ;字符串2长度减一
            REPZ       CMPSB                ;开始仔细找
            MOV        CX, AX               ;ax字符串2的长度
            JNZ        STRSTR2               ;没找到,回去继续粗略找
;
STRSTR5:
            MOV        AX, BX               ;找到后或者结束后,设置返回值
            DEC        AX
            MOV        DX, ES
;
STRSTR6:
            POP        DI                   ;恢复寄存器
            POP        SI
            POP        CX
            POP        BX
            POP        ES
            POP        DS
            POP        BP
            RET
            
STRSTR      ENDP
CSEG        ENDS
            END        START