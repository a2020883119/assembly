;TT4-36.ASM
;把内存区域0-1k字节存放到文件mem.dat中
DSEG     SEGMENT
FNAME    DB 'MEM.DAT', 0             ;文件名
FMESS1   DB 'CREATE FILE FAILED!$'   ;创建文件失败
FMESS2   DB 'WRITE FILE FAILED!$'    ;写入文件失败
DSEG     ENDS

CSEG     SEGMENT
         ASSUME DS:DSEG, CS:CSEG
START:
         MOV    AX, DSEG             ;初始化
         MOV    DS, AX
;创建文件         
         MOV    DX, OFFSET FNAME     ;ds:dx指向文件名
         MOV    CX, 00H              ;cx=00 普通文件
         MOV    AH, 3CH              ;创建文件
         INT    21H
         JNC    CREOK
;         
         MOV    DX, OFFSET FMESS1    ;'CREATE FILE FAILED!$'
         CALL   DISPMESS
         JMP    OVER                 ;结束
;写入文件         
CREOK:
         PUSH   AX                   ;句柄保存备用
         MOV    BX, AX               ;bx=句柄
         MOV    CX, 1024             ;写入的字节数
         MOV    DX, 0                ;ds:dx指向写入缓冲区
         MOV    AX, 0                ;设置ds为0
         MOV    DS, AX
         MOV    AX, 4000H            ;写入
         INT    21H
         JNC    WRIOK                ;cf=1写入失败

         MOV    AX, DSEG             ;ds重新指向dseg
         MOV    DS, AX
         MOV    DX, OFFSET FMESS2    ;'WRITE FILE FAILED!$'
         CALL   DISPMESS
;关闭文件         
WRIOK:
         POP    BX                   ;bx=文件句柄
         MOV    AH, 3EH              ;关闭文件
         INT    21H
;结束
OVER:
         MOV    AH, 4CH              ;结束
         INT    21H
;
;功能：显示DX所指向的提示信息
;入口参数：dx字符串开始偏移地址
;出口参数：无
DISPMESS     PROC
         PUSH   AX
         MOV    AH, 9                ;调用显示字符串中断
         INT    21H
         POP    AX
         RET
DISPMESS     ENDP
;
CSEG     ENDS
         END    START