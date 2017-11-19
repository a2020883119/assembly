;TT4-37.ASM
;将内存区域最低端的1k字节作为256个双字,依次把
;每个双字转换为对应的8字节十六进制ascii码串,
;顺序存放在文件MEM.TXT中,每存放一个8字节ascii码串
;再存放回车和换行符
DSEG     SEGMENT
BUFFER   DB 2560 DUP (0)                    ;转换ascii码加回车换行的缓冲区
TABLE    DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
FNAME    DB 'MEM1.DAT', 0                   ;文件名
FMESS1   DB 'CREATE FILE FAILED!$'          ;创建失败
FMESS2   DB 'WRITE FILE FAILED!$'           ;写入失败
DSEG     ENDS
;
CSEG     SEGMENT
         ASSUME CS:CSEG, DS:DSEG           ;
START:  
;设置目标段地址和指针
         MOV    AX, DSEG                   ;初始化
         MOV    DS, AX
;
         MOV    AX, 0                      ;设置源段地址 es=0
         MOV    ES, AX
;                                           设置目标和源的指针
         MOV    SI, 0                      ;源指针->内存最低端开头为零
         MOV    DI, OFFSET BUFFER          ;目标指针->转换ascii码加回车换行的缓冲区
;读->转换ascii->加回车换行
         MOV    CX, 1024                   ;读1024个字节
AG:
         MOV    AL, BYTE PTR ES : [SI]    ;从内存中取值
         XOR    AH, AH                     ;清零,不影响后面的操作
         MOV    BX, OFFSET TABLE           ;ds:bx指向ascii转换表
         CALL   ALTOASCII                  ;将al中的八位二进制数转换成两个十六进制ascii码
         MOV    BYTE PTR [DI], AH         ;保存转换后的值到缓冲区
         INC    DI                         ;指向下一个空位置
         MOV    BYTE PTR [DI], AL         ;保存转换后的值到缓冲区
         INC    DI                         ;指向下一个空位置
         CALL   ISNEWLINE                  ;判断一行是否满八个字节
         JNZ    NEXT                       ;jz=0 这行每到头
         MOV    AL, 0AH                    ;加回车和换行
         MOV    BYTE PTR [DI], AL
         INC    DI
         MOV    AL, 0DH                    ;加回车和换行
         MOV    BYTE PTR [DI], AL
         INC    DI
NEXT:
         INC    SI                         ;内存指针指向下个要取的值
         LOOP   AG                         ;循环
;创建文件
         MOV    DX, OFFSET FNAME           ;ds:dx指向文件名
         MOV    CX, 00H                    ;cx=00 普通文件
         MOV    AH, 3CH                    ;创建文件
         INT    21H                          
         JNC    CREOK                        
;创建文件异常                                
         MOV    DX, OFFSET FMESS1          ;'CREATE FILE FAILED!$'
         CALL   DISPMESS                     
         JMP    OVER                       ;结束 
;写入文件                                    
CREOK:                                       
         PUSH   AX                         ;句柄保存备用
         MOV    BX, AX                     ;bx=句柄
         MOV    CX, 2560                   ;写入的字节数
         MOV    DX, OFFSET BUFFER          ;ds:dx指向写入缓冲区
         MOV    AX, 4000H                  ;设置ds为0
         INT    21H                        ;写入   
         JNC    WRIOK                      ;cf=1写入失败   
;写入文件异常                               
         MOV    AX, DSEG                   
         MOV    DS, AX                     ;ds重新指向dseg
         MOV    DX, OFFSET FMESS2            
         CALL   DISPMESS                   ;'WRITE FILE FAILED!$'
;关闭文件                                       
WRIOK:                                         
         POP    BX                         ;bx=文件句柄
         MOV    AH, 3EH                    ;关闭文件  
         INT    21H                        
;结束                                      
OVER:    MOV    AH, 4CH
         INT    21H
;功能:判断Si的值是否是7的整数倍
;入口参数:di
;出口参数:zf = 1 真, zf=0 假
ISNEWLINE    PROC
         PUSH   AX
         PUSH   BX
         PUSH   DX       
;
         MOV    AX, SI                     ;si为读取的字符个数
         INC    AX                         ;+1使从0开始变成从1开始,方便计算换行
         MOV    BX, 8                      ;每行字节数
         XOR    DX, DX                     ;被除数高位清零,防止溢出
         DIV    BX                         ;除
         OR     DX, DX                     ;判断dx是否为0, or用来影响标志位zf
         JZ     BYEBYE                     ;zf=1,为真
;
BYE:
         INC    AX                         ;使zf=0
BYEBYE:     
         POP    DX
         POP    BX
         POP    AX
;
         RET
ISNEWLINE    ENDP
;将al中的八位二进制数转换成两个十六进制ascii码
;入口参数:al=八位二进制数, ds:bx指向兑换表
;出口参数:ah=高四字节ascii码, al=低四字节ascii码
ALTOASCII    PROC
         PUSH   CX                         
         PUSH   DX
         PUSH   SI  
;
         MOV    CL, 4                      ;移位的位数   0000 0000-1111 1111
         SHL    AX, CL                     ;ax左移四位   0000 1111-1111 0000
         SHR    AL, CL                     ;al右移四位   0000 1111-0000 1111
         MOV    DX, 0                      ;将ah的值送到si中
         MOV    DL, AH
         MOV    SI, DX
         MOV    AH, [BX][SI]              ;在表中取值  ds:bx 指向ascii转换表
         MOV    DX, 0                      ;将al的值送到si中
         MOV    DL, AL
         MOV    SI, DX
         MOV    AL, [BX][SI]              ;在表中取值  ds:bx 指向ascii转换表
;
         POP    SI
         POP    DX
         POP    CX 
         RET
ALTOASCII    ENDP
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS     PROC
         PUSH   AX
         MOV    AH, 9                      ;调用显示字符串中断
         INT    21H
         POP    AX
         RET
DISPMESS     ENDP
CSEG     ENDS
         END    START