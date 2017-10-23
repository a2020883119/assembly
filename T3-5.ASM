;T3-5.ASM
;求一到十的对数值
DSEG		SEGMENT
VALUE		DB 4
ANSWER		DW ?
TAB			DW 0, 3010, 4771, 6021, 6990, 7782, 8451, 9031, 9542, 10000
DSEG		ENDS
;
CSEG		SEGMENT
			ASSUME	CS:CSEG, DS:DSEG
			
START:		MOV	AX, DSEG		;段值
			MOV	DS, AX
			
			XOR		AX, AX			;清零
			MOV	AL, VALUE		;拿操作数
			DEC		AX				;操作数减一
			ADC		AX, AX			;操作数翻倍
			MOV	BX, AX			;传递数组下标
			MOV	AX, TAB[BX]		;取数组值
			MOV	ANSWER, AX		;保存答案
			
			MOV	AH, 4CH
			INT		21H
CSEG		ENDS
			END		START
			
			
			