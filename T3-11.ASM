;T3-11.ASM
;用除法将16位二进制数转化为五位bcd十进制码
DSEG	SEGMENT
DATA	DW	23456
BUFFER	DB	5 DUP (0)
JM		DW	10000, 1000, 100, 10, 1
DSEG	ENDS
;
CSEG	SEGMENT
		ASSUME	CS:CSEG, DS:DSEG
START:	MOV	AX, SEG DATA			;初始化
		MOV	DS, AX
		
		MOV	DI, OFFSET JM			;设置保存和取值指针
		MOV	SI, OFFSET BUFFER
		
		MOV	CX, 5					;循环次数
		MOV	AX, DATA				;拿被除数
		XOR		DX, DX					;dx存余数
		
NEXT:	MOV	BX, [DI]					;拿除数
		ADD		DI, 2					
		DIV		BX						
		MOV	[SI], AL					;取商
		INC		SI
		
		MOV	AX, DX					;取余数准备下次除法
		XOR		DX, DX
		LOOP	NEXT					
									
		MOV	AX, 4C00H
		INT		21H
CSEG	ENDS
		END		START