;T3-7.ASM
;十六进制数到ASCII码的转换
DATA	SEGMENT
XX		DB	4
ASCII	DB	?
DATA	ENDS

CODE	SEGMENT
		ASSUME	CS:CODE, DS:DATA
START:	MOV	AX, DATA
		MOV	DS, AX
		;方法一-------------
		; MOV	AL, XX			;取值
		; CMP		AL, 9		;比较
		; JA		NEXT			;大于9跳转
		; ADD		AL, 30H		;小于9加30H
		; JMP		OVER		;结束
		;----------------------
; NEXT:	ADD		AL, 37H			;大于9加37H
			
		;方法二-----------------------	
		MOV	AL, DB
		ADD		AL, 30H
		CMP		AL, 39H
		JA		OVER
		ADD		AL, 7
		;---------------------------------
		
OVER:	MOV	ASCII, AL				;结果保存
		MOV	AH, 4CH
		INT		21H
		
CODE	ENDS 
		END START