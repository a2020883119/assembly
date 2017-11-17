;TT4-33.ASM
;进制转换
;0-65535范围内正数加减乘除运算
CR = 0DH                                  ;回车换行
LF = 0AH
ADDSIGN = 43                              ;运算符加减乘除
SUBSIGN = 45
DIVSIGN = 47
MULSIGN = 42
DSEG           SEGMENT
MESS1          DB 'VALUE1 :$'             ;提示语
MESS2          DB 'OPERATE:$'
MESS3          DB 'VALUE2 :$'
MESS4          DB 'RESULT :$'
;VALUE1                               
BUFFER1        DB 6                       ;接收字符串缓冲区
SIZE1          DB 0
VALUE1         DB 6  DUP ('$')
;OPERAT
OPERATESIGN    DB 0                       ;接收操作符
;VALUE2
BUFFER2        DB 6                       ;接收字符串缓冲区
SIZE2          DB 0
VALUE2         DB 6  DUP ('$')
;
TVALUE1        DD 0                       ;ascii值转换为的真实值保存处  值1
TVALUE2        DD 0                       ;ascii值转换为的真实值保存处  值2
TRESULT        DD 0, 0                    ;ascii值转换为的真实值保存处  结果
RESULT         DB 20 DUP ('$'), '$'       ;将真实结果转换为ascii码串保存在这里
TABLE          DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'     ;取值映射表
DSEG           ENDS

CSEG           SEGMENT
               ASSUME DS:DSEG, CS:CSEG                 
START:
               MOV       AX, DSEG                   ;初始化
               MOV       DS, AX 
;获取第一个值
AG1:
               MOV       DX, OFFSET MESS1           ;提示语输出
               CALL      DISPMESS
               MOV       DX, OFFSET BUFFER1         ;指向接收字符串的缓冲区
               CALL      GETNUM                     ;接收字符串
               MOV       CL, SIZE1                  ;字符串长度
               XOR       CH, CH                    
               MOV       SI, OFFSET VALUE1          ;si指向获取到的字符串
               CALL      NEWLINE 
               CALL      NUMCHECK                   ;检查是否合理输入
               JC        AG1                        ;非法输入重新获取
               
;操作符
AG2:
               MOV       DX, OFFSET MESS2           ;提示与输出
               CALL      DISPMESS
               CALL      GETOPERATESIGN             ;获取运算符
               CALL      NEWLINE
               CALL      ISOPERATESIGN              ;是否合法输入
               JNZ       AG2                        ;不是重新获取
               MOV       OPERATESIGN, AL            ;保存运算符
;获取第二个值
AG3:
               MOV       DX, OFFSET MESS3           ;提示语输出
               CALL      DISPMESS                     
               MOV       DX, OFFSET BUFFER2         ;指向接收字符串的缓冲区
               CALL      GETNUM                      ;接收字符串 
               MOV       CL, SIZE2                  ;字符串长度
               XOR       CH, CH                     
               MOV       SI, OFFSET VALUE2          ;si指向获取到的字符串
               CALL      NEWLINE                      
               CALL      NUMCHECK                    ;检查是否合理输入 
               JC        AG3                         ;非法输入重新获取 
               
;ascii码转真实值
               MOV       SI, OFFSET VALUE1           ;si指向value1的字符串
               MOV       CX, 0                       ;清零
               MOV       CL, SIZE1                   ;value1字符串的长度
               CALL      FAR PTR TOVALUE             ;得到ascii表示的真实值
               MOV       WORD PTR TVALUE1, AX        ;保存

               MOV       SI, OFFSET VALUE2           ;si指向value2的字符串
               MOV       CX, 0                       ;清零
               MOV       CL, SIZE2                   ;value2字符串的长度
               CALL      FAR PTR TOVALUE             ;得到ascii表示的真实值
               MOV       WORD PTR TVALUE2, AX        ;保存

;计算结果     
               MOV       AL, OPERATESIGN              ;取运算符
               CALL      GETRESULT                    ;获取计算结果
               MOV       AX, WORD PTR TRESULT + 2     ;取高位值
               MOV       SI, OFFSET RESULT            ;si指向生成计算结果字符串的缓冲区
               MOV       DI, OFFSET TABLE             ;di指向转换表
               CALL      AXTOHEXASCII                 ;处理高位   生成等值ascii码串
               MOV       AX, WORD PTR TRESULT         ;取低位
               CALL      AXTOHEXASCII                 ;处理高位   生成等值ascii码串

               MOV       DX, OFFSET MESS4             ;显示结果提示语和结果字符串
               CALL      DISPMESS
               MOV       DX, OFFSET RESULT
               CALL      DISPMESS

               MOV       AH, 4CH                      ;结束
               INT       21H

;将十六位二进制数转换为十进制数ASCII码
;入口参数:ax值, si指向存放字符串的缓冲区
;出口参数:指定缓冲区
;十进制处理
AXTOHEXASCII        PROC
;十六进制处理
         PUSH       CX
         PUSH       AX       
         PUSH       BX
         MOV        CX, 4                   ;循环次数
AG:
         ROL        AX, 1                   ;移位，向左循环移位  不带cf
         ROL        AX, 1                   ;移位，
         ROL        AX, 1                   ;移位，
         ROL        AX, 1                   ;移位，
         XOR        BX, BX                   ;清空BX
         PUSH       AX                       ;保存ax
         AND        AL, 00001111B            ;得到低四位
         MOV        BL, AL                   ;获取下标
         MOV        AL, [BX + DI]            ;取值
         MOV        [SI], AL                 ;保存值
         INC        SI                       ;指针指向下一个空位置
         POP        AX                        ;恢复ax
         LOOP       AG                        ;循环

         POP        BX
         POP        AX
         POP        CX
         RET
AXTOHEXASCII        ENDP
;功能:拿到两个操作数和运算符求结果值
;入口参数:TVALUE1第一个数  TVALUE2第二个数  OPERATESIGN操作符   
;出口参数:指定缓冲区计算结果
;
GETRESULT      PROC
                              

               MOV       BL, OPERATESIGN              ;得到运算符

               CMP       BL, ADDSIGN                  ;根据运算符选择计算方式
               JZ        ADDSIGNPROC
               CMP       BL, SUBSIGN
               JZ        SUBSIGNPROC
               CMP       BL, DIVSIGN
               JZ        DIVSIGNPROC
               CMP       BL, MULSIGN
               JZ        MULSIGNPROC
;+
ADDSIGNPROC:
               XOR       DX, DX
               MOV       AX, WORD PTR TVALUE1
               ADD       AX, WORD PTR TVALUE2
               ADC       DX, 0
               MOV       WORD PTR TRESULT, AX
               MOV       WORD PTR TRESULT + 2, DX
               JMP       GETROVER
;-
SUBSIGNPROC:   
               XOR       DX, DX
               MOV       AX, WORD PTR TVALUE1
               SUB       AX, WORD PTR TVALUE2
               MOV       WORD PTR TRESULT, AX
               MOV       WORD PTR TRESULT + 2, DX
               JMP       GETROVER
               
;/
DIVSIGNPROC:   XOR       DX, DX
               MOV       AX, WORD PTR TVALUE1
               MOV       BX, WORD PTR TVALUE2
               DIV       BX
               MOV       WORD PTR TRESULT, DX
               MOV       WORD PTR TRESULT + 2, AX
               JMP       GETROVER
               
;*
MULSIGNPROC:
               XOR       DX, DX
               MOV       AX, WORD PTR TVALUE1
               MOV       BX, WORD PTR TVALUE2
               MUL       BX
               MOV       WORD PTR TRESULT, AX
               MOV       WORD PTR TRESULT + 2, DX
               JMP       GETROVER
GETROVER:
               RET

GETRESULT      ENDP

;功能:将指定的一串十进制表示的ascii码串转换为实际值
;入口参数:si指向字符串开头,CX为字符串长度
;出口参数:AX保存值
TOVALUE        PROC
               PUSH      DX                            ;
               PUSH      BX             
               XOR       AX, AX                        ;
               XOR       DX, DX
TOAG:
               MOV       BX, 10                        ;除数
               MUL       BX                            ;
               MOV       DL, [SI]                      ;从前往后取ascii字符
               INC       SI                            ;指向后一个
               SUB       DL, 30H                       ;得到ascii码表示的值
               ADD       AL, DL                        ;低位相加
               ADC       AH, 0                         ;高位相加
               LOOP      TOAG
               
               POP       BX
               POP       DX
               RET
TOVALUE        ENDP


;功能:检测al中的字符是否是'+', '-', '*', '/'
;入口参数:al中存放待检测字符
;出口参数:zf=1是真, zf=0是假
ISOPERATESIGN  PROC
               CMP       AL, ADDSIGN
               JZ        ISOVER
               CMP       AL, SUBSIGN
               JZ        ISOVER
               CMP       AL, DIVSIGN
               JZ        ISOVER
               CMP       AL, MULSIGN
               JZ        ISOVER
ISOVER:
               RET
ISOPERATESIGN  ENDP
;功能:
;入口参数:si指向字符串开头,cx保存字符串长度
;出口参数:cf=0为真, cf=1,为假
NUMCHECK  PROC
          PUSH    SI
          PUSH    AX
NUMCHECK1:
          MOV     AL, [SI]
          CALL    ISDEC 
          JC      OVER
          LOOP    NUMCHECK1
OVER:
          POP     AX
          POP     SI
          RET
NUMCHECK  ENDP


;功能:获取输入的一串字符串
;入口参数:ds:dx指向设置好的缓冲区
;出口参数:接收到的字符串长度和字符串内容保存在缓冲区的第二第三部分
GETNUM    PROC
          PUSH     AX
          MOV      AH, 0AH
          INT      21H
          POP      AX
          RET
GETNUM    ENDP



;功能：判断是不是有效十六进制ASCII码
;入口参数：AL存放要检验的字符
;出口参数：CF中存放判断结果，CF是1表示无效，CF是0表示有效
ISDEC    PROC
         CMP       AL, '0'                  ;是否大于'0'
         JB        ISDEC2                   ;有效,小于'0'结束，此时CF=1
         CMP       AL, '9'+ 1               ;是否小于十
         CMC                                ;CF取反
ISDEC2:  
         RET
ISDEC    ENDP

;功能：接收一个字符，带回显
;入口参数：无
;出口参数：DL存放获取的字符
GETOPERATESIGN      PROC 
		            MOV       AH, 1                    ;不带回显接收字符
                    INT       21H
                    RET

GETOPERATESIGN      ENDP
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS   PROC
           PUSH     AX
           MOV      AH, 9                      ;调用显示字符串中断
           INT      21H
           POP      AX
           RET
DISPMESS   ENDP

NEWLINE   PROC
          PUSH      AX                       ;AX压入栈中，为了保护AX的值
          PUSH      DX                       ;DX压入栈中，为了保护DX的值
          MOV       DL, 0DH                  ;   \r
          MOV       AH, 2                    ;调用显示中断
          INT       21H
          MOV       DL, 0AH                  ;   \n
          MOV       AH, 2                    ;调用显示中断
          INT       21H                
          POP       DX                       ;恢复进入子程序前的值
          POP       AX
          RET 
NEWLINE   ENDP



CSEG           ENDS
               END       START


; ;将十六位二进制数转换为十进制数ASCII码
; ;入口参数:ax值, si指向存放字符串的缓冲区
; ;出口参数:指定缓冲区
; ;十进制处理
; AXTODECASCII        PROC
         ; PUSH       AX
         ; PUSH       DX
         ; PUSH       CX
         ; PUSH       BX
         ; MOV        BX, 10                   ;乘数
         ; MOV        DX, 0
         ; MOV        CX, 0                    ;计数器清零
; DECLOOP: 
         ; DIV        BX                       ;除
         ; PUSH       DX                       ;保存余数到堆栈
         ; INC        CX                       ;计数器加一
         ; XOR        DX, DX                   ;清空余数，不影响下次操作
         ; CMP        AX, 0                    ;被除数为零异常处理，循环出口
         ; JZ         DECEND                   ;跳出处理循环，进入显示循环
         ; JMP        DECLOOP                   ;继续处理循环
         

; DECEND:  
         ; POP        AX                       ;从堆栈中取出余数
         ; ADD        AX, 30H
         ; MOV        [SI], AL
         ; INC        SI
         ; LOOP       DECEND                    ;循环继续
         ; POP        BX
         ; POP        CX
         ; POP        DX
         ; POP        AX

         ; RET
; AXTODECASCII        ENDP