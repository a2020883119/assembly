;TT4-25.ASM
;选择法排序，有可重入性的子程序
;
DSEG        SEGMENT
DATA        DB '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '$'    
DSEG        ENDS                         ;要排序的数据
         
CSEG        SEGMENT
            ASSUME CS:CSEG, DS:DSEG
START:
            MOV     AX, DSEG             ;初始化
            MOV     DS, AX

            MOV     BX, OFFSET DATA      ;传递首地址
            CALL    SELSORT
        
            MOV     AH, 4CH
            INT     21H
;功能，从大到小排序,选择法排序
;入口参数：BX指向要排序的字母串开头,以$符号结尾
;出口参数：无
;CX存放字符串长度， BX为字符串指针, SI为可变指针, DX暂时用来存放要对比的数
SELSORT     PROC
            PUSH    CX                   ;备份
            PUSH    DX
            PUSH    SI
            PUSH    BX
            XOR     CX, CX               ;准备计数
;计数
COUNT:
            MOV     DL, [BX]             ;取值
            CMP     DL, '$'               ;是否到头
            JZ      COUNTOV               ;到头，跳，结束   DL = '$'
            INC     BX                    ;指向下一个
            INC     CX                    ;计数加一
            JMP     COUNT                 ;计数循环
COUNTOV:            
            POP     BX                    ;恢复字符串指针，指向开头
            XOR     SI, SI                ;清空，准备使用
;外循环
OUTLOOP:
            MOV     DL, [BX][SI]          ;取值
            PUSH    SI                     ;保存外循环可变指针
;内循环
INLOOP:
            INC     SI                     ;内循环指针更新
            CMP     SI, CX                 ;是否到头
            JZ      GOOUTLOOP              ;到头本次内循环结束
            CMP     DL, [BX][SI]          ;比大小
            JNC     INLOOP                 ;比DL小不换，直接开始下一次
            MOV     DH, DL                 ;比DL大，换位置
            MOV     DL, [BX][SI]
            MOV     [BX][SI], DH
            JMP     INLOOP
GOOUTLOOP:  
            POP     SI                     ;恢复外循环指针
            MOV     [BX][SI], DL          ;把最值归位
            INC     SI                     ;更新指针，指向下一个
            CMP     SI, CX                 ;是否到头
            JNZ     OUTLOOP          
;结束
            POP     SI
            POP     DX
            POP     CX
RET
SELSORT     ENDP
CSEG        ENDS
            END     START