;T3-12.ASM
;大写字符串转换为小写字符串
DSEG	SEGMENT
STRING	DB 'HOW   are  YoU   ! ', 0
DSEG	ENDS

CSEG	SEGMENT
		ASSUME	CS:CSEG, DS:DSEG
		
START:	MOV	AX, DSEG			;初始化
		MOV	DS, AX
		MOV	SI, OFFSET STRING
		
AGAIN:	MOV	AL, [SI]				;拿字符
		OR		AL, AL				;影响标志寄存器 zf
		JZ		OK					;到达结尾
		
		CMP		AL, 'A'				;判断是否为字母
		JL		NEXT				;不是跳过下一个
		
		CMP		AL, 'Z'				;判断是否为大写字母
		JA		NEXT				;不是，处理下个一个
		OR		AL, 20H				;是大写，转换为小写
		MOV	[SI], AL				;放回原处
		
NEXT:	INC		SI					;更正指针
		JMP		AGAIN				;AGAIN
		
OK:		MOV	AX, 4C00H
		INT		21H
CSEG	ENDS
		END		START