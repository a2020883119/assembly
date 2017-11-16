;TT4-33.ASM
;进制转换
;0-65535范围内正数加减乘除运算
CR = 0DH
LF = 0AH
BACKSPACE = 08H
BELLCH = 07H
ADDSIGN = '+'
SUBSIGN = '-'
DIVSIGN = '/'
SUBSIGN = '*'
DSEG           SEGMENT
MESS           DB 'INPUT :$'
MESS2          DB 'RESULT:$'
RESULT         DB 20 DUP ('$')
VALUE1         DB 3  DUP ('$')
VALUE2         DB 3  DUP ('$')
DSEG           ENDS

CSEG           SEGMENT
               ASSUME DS:DSEG, CS:CSEG
START:
               MOV       AX, DSEG
               MOV       DS, AX 

               MOV       DX, OFFSET MESS
               CALL      DISPMESS
               CALL      GETEQUATION
               CALL      NEWLINE
               MOV       DX, OFFSET MESS2
               CALL      DISPMESS

               MOV       AH, 4CH
               INT       21H
;
;
;
GETEQUATION    PROC
                         
          PUSH     DX
GETADR1:  CALL     GETSTR                   ;调用获取有效十六进制ASCII码的地址字符串功能
          CMP      BUFFER, CR               ;是否到头
          JNZ      GETADR2                  ;不到头进行十六进制ASCII码向二进制数转换
          CALL     BELL                     ;空字符串，异常处理，
          JMP      GETADR1                  ;重新获取有效字符串
GETADR2:  MOV      DX, OFFSET BUFFER        ;取值
          CALL     HTOBIN                   ;调用十六进制ASCII码向二进制数转换功能函数
          CALL     NEWLINE                  ;调用换行功能函数
          POP      DX
               
               RET
GETEQUATION    ENDP

;获取地址字符串，并判断输入的字符是否是有效十六进制ASCII码，长度为四位十六进制ASCII码，可使用BACKSPACE修改已经输入的十六进制ASCII码，并保存在缓冲区
;入口参数：无
;出口参数：无
GETSTR    PROC
          PUSH     AX
          PUSH     BX
          PUSH     DI

          MOV      DI, OFFSET RESULT        ;存放获取输入字符的缓冲区
          MOV      BX, 0                    ;BX清零，统计输入的字符个数
GETSTR1:  CALL     GETCH                    ;获取一个字符，不带回显
          CMP      AL, CR                   ;是否是回车，回车代表输入结束
          JZ       GETSTR5                  ;跳转到结束，保存值
          CMP      AL, BACKSPACE            ;是否是退格键
          JNZ      GETSTR4                  ;不是退格键，正常处理
          CMP      BX, 0                    ;获取输入的字符数量是否大于0
          JZ       GETSTR2                  ;没有可消除的已经被输入的字符，缓冲区为空，没有字符可消除，异常处理
          DEC      BX                       ;有可消字符时，输入的字符总数减去1
          CALL     PUTCH                    ;输出退格符，使光标向后退一位
          MOV      AL, 20H                  ;20H代表空格，
          CALL     PUTCH                    ;输出空格，替换已经输入的字符，此时光标前进一位
          MOV      AL, BACKSPACE            ;输出退格符，光标向后退一位，抵消输出空格时的光标移动
          CALL     PUTCH
          JMP      GETSTR1
GETSTR2:  CALL     BELL                     ;异常处理，响铃提示
          JMP      GETSTR1
GETSTR4:  CMP      BX, 4                    ;是否够数
          JZ       GETSTR2                  ;异常处理，已经够了
          CALL     ISHEX                    ;判断是否是有效的十六进制ASCII码
          JC       GETSTR2                  ;无效字符，异常处理
          MOV      [BX][DI], AL            ;有效字符，保存在缓冲区
          INC      BX                       ;更新缓冲区指针
          CALL     PUTCH                    ;将有效字符显示到屏幕
          JMP      GETSTR1                  ;继续获取字符
GETSTR5:  MOV      [BX][DI], AL            ;接收到回车键，输入结束，将有效字符，保存在缓冲区
          POP      DI
          POP      BX
          POP      AX
          RET
GETSTR    ENDP

;功能：将四位十六进制ASCII码转换成二进制数
;入口参数：DX存放四位十六进制ASCII码串的首地址
;出口参数：AX存放转换后的二进制数
HTOBIN    PROC               
          PUSH     CX                       ;保存CX
          PUSH     DX                       ;保存DX
          PUSH     SI                       ;保存SI
          MOV      SI, DX                   ;将四位十六进制ASCII码串的首地址放在SI中
          XOR      DX, DX                   ;清空DX
          MOV      CH, 4                    ;循环次数
          MOV      CL, 4                    ;移位次数
HTOBIN1:  MOV      AL, [SI]                 ;取值
          INC      SI                       ;指针更新
          CMP      AL, CR                   ;是否到头
          JZ       HTOBIN2                  ;到头保存结果到AX结束
          CALL     ATOBIN                   ;调用一个十六进制ASCII码转换为有效二进制数函数功能
          SHL      DX, CL                   ;移出空位，准备存放数据
          OR       DL, AL                   ;存放数据
          DEC      CH                       ;循环次数减一
          JNZ      HTOBIN1                  ;CH不为零，继续循环
HTOBIN2:  MOV      AX, DX                   ;将结果放在AX中
          POP      SI                       ;恢复SI
          POP      DX                       ;恢复DX
          POP      CX                       ;恢复CX
          RET
HTOBIN    ENDP

;显示一个字符
;入口参数：AL存放要被显示的字符
;出口参数：无
PUTCH       PROC 
            PUSH    AX
            PUSH    DX                         ;保存DX
            MOV     DL, AL                     ;要显示的字符就位
            MOV     AH, 2                      ;显示
            INT     21H
            POP     DX                         ;恢复DX
            POP     AX
            RET  
PUTCH       ENDP

;功能：判断是不是有效十六进制ASCII码
;入口参数：AL存放要检验的字符
;出口参数：CF中存放判断结果，CF是1表示无效，CF是0表示有效
ISHEX    PROC
         CMP       AL, '0'                  ;是否大于'0'
         JB        ISHEX2                   ;有效,小于'0'结束，此时CF=1
         CMP       AL, '9'+ 1               ;是否小于十
         JB        ISHEX1                   ;小于十，结束，CF=1
         CMP       AL, 'A'                  ;是否大于十
         JB        ISHEX2                   ;无效字符，CF=1
         CMP       AL, 'F' + 1              ;是否超范围
         JB        ISHEX1                   ;有效，且大于10，CF=1
         CMP       AL, 'a'                  ;是否大于十
         JB        ISHEX2                   ;无效，非法字符，CF=1
         CMP       AL, 'f' + 1              ;是否超范围，超范围CF=0,不超范围CF=1
ISHEX1:  CMC                                ;CF取反
ISHEX2:  RET
ISHEX    ENDP

;功能：发出警报声音
;入口参数：无
;出口参数：无
BELL     PROC
         MOV       AL, BELLCH               ;07H响铃
         CALL      PUTCH                    ;调用显示字符功能
         RET       
BELL     ENDP

;功能：接收一个字符，不带回显
;入口参数：无
;出口参数：DL存放获取的字符
GETCH    PROC
         MOV       AH, 8                    ;不带回显接收字符
         INT       21H
         RET
GETCH    ENDP

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

;功能:将五位十进制数ASCII码,转换为相应的二进制数
;入口参数:
;出口参数:

;功能：发出警报声音
;入口参数：无
;出口参数：无
BELL     PROC
         MOV       AL, BELLCH               ;07H响铃
         CALL      PUTCH                    ;调用显示字符功能
         RET       
BELL     ENDP




CSEG           ENDS
               END       START