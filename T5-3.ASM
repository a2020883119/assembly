;T5-3.ASM
;在屏幕中间区域,最下面一行显示用户输入的按键,
;这行满时,窗口内容就向上滚动一行,ctrl+c结束
;                                       ;
;                                       ;
;常量定义                               ;
WINWIDTH    = 40                        ;宽度
WINTOP      = 8                         ;上边框位置
WINLEFT     = 20                        ;左边框位置
WINBOTTOM   = 17                        ;下边框位置
WINRIGHT    = WINLEFT + WINWIDTH - 1    ;右边框位置
COLOR       = 74H                       ;颜色
PAGEN       = 0                         ;屏幕缓冲页首页
CTRL_C      = 03H                       ;ctrl+c的ascii码,结束码
;代码段                                 ;
CSEG        SEGMENT                     ;
            ASSUME CS:CSEG              ;
START:                                  ;
            MOV    AL, PAGEN            ;选择当前显示页
            MOV    AH, 5                ;al存放页号
            INT    10H                  ;
;清空划定显示区域                                    
            MOV    CH, WINTOP           ;左上角坐标-----↓  
            MOV    CL, WINLEFT          ;                --->圈出的位置为缓冲区大小
            MOV    DH, WINBOTTOM        ;右下角坐标-----↑
            MOV    DL, WINRIGHT         ;
            MOV    BH, 0F4H             ;此处修复原文bug,运行时,最开始的一行,按下按键,不显示任何内容,只见光标移动,这行满了,滚屏,然后可以正常显示,缺少了这个参数
            MOV    AL, 0                ;al=0表示清空
            MOV    AH, 6                ;
            INT    10H                  ;
;置光标位置                                      
            MOV    BH, PAGEN            ;bx=要操作的页号
            MOV    DH, WINBOTTOM        ;具体行
            MOV    DL, WINLEFT          ;具体列
            MOV    AH, 2                ;
            INT    10H                  ;
;                                       ;
NEXT:                                   
;从键盘读一个字符
            MOV    AH, 0                ;
            INT    16H                  ;
            CMP    AL, CTRL_C           ;是否为结束标志
            JZ     EXIT                 ;是,跳
;将字符写到光标位置                                       
            MOV    BH, PAGEN            ;bx=选择要用到的页
            MOV    CX, 1                ;cx=重复次数1次
            MOV    AH, 0AH              ;
            INT    10H                  ;
;                                       ;
            INC    DL                   ;光标指向下一位置
            CMP    DL, WINRIGHT + 1     ;判断是否到行位
            JNZ    SETCUR               ;不是,跳
;向上滚屏
            MOV    CH, WINTOP           ;上边的行号    
            MOV    CL, WINLEFT          ;左边的列号
            MOV    DH, WINBOTTOM        ;下边的行号
            MOV    DL, WINRIGHT         ;右边的列号
            MOV    BH, COLOR            ;设置字符属性(颜色)
            MOV    AL, 1                ;滚动一行
            MOV    AH, 6                ;
            INT    10H                  ;
            MOV    DL, WINLEFT          ;光标回到行头
SETCUR:                                 
;设置光标位置
            MOV    BH, PAGEN            ;要操作的页
            MOV    AH, 2                ;
            INT    10H                  ;
            JMP    NEXT                 ;
EXIT:                                   ;
            MOV    AX, 4C00H            ;结束
            INT    21H                  ;
CSEG        ENDS                        ;
            END    START                ;
            INT    10H                  ;