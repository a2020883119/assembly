;T4-4.ASM
;接受一串字符串然后，然后显示其中数字符，英文字母，和字符串长度
MLENGTH = 128
;
DSEG      SEGMENT
BUFF      DB MLENGTH                   ;接收字符串的缓冲区长度
          DB ?                         ;接收到字符串的真实长度
          DB MLENGTH DUP (0)           ;存放接收到字符串的缓冲区
MESS0     DB 'PLEASE INPUT:$'          ;输入提示字符串
MESS1     DB 'LENGTH = $'              ;提示字符串长度的字符串
MESS2     DB 'X = $'                   ;提示数字字符数量的字符串
MESS3     DB 'Y = $'                   ;提示字母字符数量的字符串
DSEG      ENDS
;
CSEG      SEGMENT
          ASSUME CS:CSEG, DS:DSEG
;
START:    MOV      AX, DSEG           ;数据段初始化
          MOV      DS, AX

          MOV      DX, OFFSET MESS0   ;显示输入提示字符串
          CALL     DISPMESS
          
          MOV      DX, OFFSET BUFF    ;调用接收字符串中断
          MOV      AH, 10
          INT      21H

          CALL     NEWLINE            ;换行
          
          MOV      BH, 0              ;数字符数量计数器
          MOV      BL, 0              ;字母符数量计数器
          MOV      CL, BUFF + 1       ;字符串长度
          MOV      CH, 0              ;清空循环计数器高位
          JCXZ     COK                ;CX=0,没有接收到字符串，跳过统计直接显示0 0 0
          
          MOV      SI, OFFSET BUFF + 2;指针指向字符串开始
AGAIN:    MOV      AL, [SI]           ;取字符
          INC      SI                 ;指针指向下一个字符
          CMP      AL, '0'            ;是否是数字
          JB       NEXT                ;不是数字
          CMP      AL, '9'            ;是否是数字
          JA       NODEC              ;不是数字
          INC      BH                 ;是数字，计数器加一
          JMP      SHORT NEXT         ;下一个
NODEC:    OR       AL, 20H            ;大写字母变小写
          CMP      AL, 'a'            ;是否是字母
          JB       NEXT               ;不是，下一个
          CMP      AL, 'z'            ;是否是字母
          JA       NEXT               ;不是，下一个
          INC      BL                 ;是字母，计数器加一
NEXT:     LOOP     AGAIN              ;循环
;
COK:      MOV      DX, OFFSET MESS1   ;传递要显示字符串的偏移地址
          CALL     DISPMESS           ;调用显示字符串中断
          MOV      AL, BUFF + 1       ;取字符串长度的偏移地址
          XOR      AH, AH             ;清空AH
          CALL     DISPAL             ;显示长度 调用将八位二进制数转换成十进制数ASCII码并显示的子程序
          CALL     NEWLINE            ;换行
;
          MOV      DX, OFFSET MESS2   ;传递要显示字符串的偏移地址
          CALL     DISPMESS           ;调用显示字符串中断
          MOV      AL, BH             ;将数字的数量送到AL中
          XOR      AH, AH             ;清空AH
          CALL     DISPAL             ;显示数字个数  调用将八位二进制数转换成十进制数ASCII码并显示的子程序
          CALL     NEWLINE            ;换行
;
          MOV      DX, OFFSET MESS3   ;传递要显示字符串的偏移地址
          CALL     DISPMESS           ;调用显示字符串中断
          MOV      AL, BL             ;将字母的数量送到AL中
          XOR      AH, AH             ;清空AH
          CALL     DISPAL             ;显示字母个数  调用将八位二进制数转换成十进制数ASCII码并显示的子程序
          CALL     NEWLINE            ;换行
;
          MOV      AX, 4C00H          ;结束
          INT      21H

;功能：用十进制数的形式显示八位二进制数
;入口参数：AL=8位二进制数
;出口参数：无
DISPAL    PROC
          MOV      CX, 3              ;八位二进制数最大值为三位数，故需要除三次十
          MOV      DL, 10             ;除数
DISP1:    DIV      DL                 ;除操作
          XCHG     AH, AL             ;余数和商换位置，AL存放商， AH存放余数
          ADD      AL, '0'            ;余数转换为ASCII码
          PUSH     AX                 ;AX压入堆栈
          XCHG     AH, AL             ;交换余数和商的位置
          MOV      AH, 0              ;AH清零，不影响除法操作
          LOOP     DISP1              ;求下一位
          MOV      CX, 3              ;循环三次
DISP2:    POP      DX                 ;出栈 赋值给DX
          CALL     ECHOCH             ;调用显示字符中断
          LOOP     DISP2              ;下一次
          RET
DISPAL    ENDP
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS  PROC
          MOV      AH, 9              ;调用显示字符串中断
          INT      21H
          RET
DISPMESS  ENDP
;
;功能：显示DL中的字符
;入口参数：DL存放要显示的字符
;出口参数：无
ECHOCH    PROC
          MOV      AH, 2              ;调用显示字符中断
          INT      21H
          RET
ECHOCH    ENDP
;
;功能：换下一行
;入口参数：无
;出口参数：无
NEWLINE   PROC
          PUSH      AX                ;AX压入栈中，为了保护AX的值
          PUSH      DX                ;DX压入栈中，为了保护DX的值
          MOV       DL, 0DH           ;   \r
          MOV       AH, 2             ;调用显示中断
          INT       21H
          MOV       DL, 0AH           ;   \n
          MOV       AH, 2             ;调用显示中断
          INT       21H                
          POP       DX                ;恢复进入子程序前的值
          POP       AX
          RET 
NEWLINE   ENDP

CSEG      ENDS
          END       START