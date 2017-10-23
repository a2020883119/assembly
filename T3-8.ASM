;T3-8.ASM
;ASCII码转换为十六进制数
DATA	SEGMENT
XX		DB ?		;存放十六进制数
ASCII	DB 'a'		;待转换数
DATA	ENDS

CODE	SEGMENT
		ASSUME	CS:CODE, DS:DATA
		
START:	MOV	AX, DATA	;设置段值
		MOV	DS, AX
		
		MOV	AL, ASCII		
		CMP		AL, '0'
		
		; ;第一种--------------------------------
; LAB:		JB		LAB5			;小于零，非法-1处理
		; MOV	AH, AL		;大于零，下一步操作
		; SUB		AH, '0'		;AH保存最后结果，目前可以确定大于零
		; CMP		AL, '9'		;检验是否大于'9'
		; JBE		LAB6			;小于'9'，AH中保存的数即为结果，结束
		; CMP		AL, 'A'		;检验是否大于'A'
		; JB		LAB5			;小于'A'，即为无效数-1处理
		; MOV	AH, AL		;大于'A'，更正AH中保存的正确结果
		; SUB		AH, 'A' - 10	;
		; CMP		AL, 'F'		;检验是否大于'F'
		; JBE		LAB6			;小于'F'，AH中保存的即为正确结果
		; CMP		AL, 'a'		;检验是否大于'a'
		; JB		LAB5			;小于'a'，为非法数-1处理
		; MOV	AH, AL		;大于'a'，更正AH中保存的正确结果
		; SUB		AH, 'a' - 10	;
		; CMP		AL, 'f'		;检验是否大于' f '
		; JB		LAB6			;小于'f'，AH中保存的就是正确结果，结束
		; ;------------------------------------------
		
		; ;第二种------------------------------------
; LAB:		JB		LAB5			;小于0非法-1处理
		; MOV	AH, AL		;更新AH中的正确结果
		; SUB		AH, '0'		;
		; CMP		AL, '9'		;小于'9'，判断结束，AH中即为正确结果
		; JBE		LAB6			;
		; AND		AL, 11011111B	;小写变大写
		; CMP		AL, 'A'		;小于'A'，非法-1处理
		; JB		LAB5			;
		; MOV	AH, AL		;更新AH中的正确结果
		; SUB		AH, 'A' - 10	;
		; CMP		AL, 'F'		;小于'F'，AH中即为正确结果
		; JBE		LAB6			;
		; ;----------------------------------------------
		
		;不存在非法的情况----------------
		OR		AL, 20H			;20H -> 0010 0000   '0'->0011 0000   '9'->0011 1001	对数字没有影响
		SUB		AL, '0'			;判断是否为数字
		CMP		AL, 9			;
		JB		LAB4				;是数字
		SUB		AL, 'a' - '0' - 10	;是字母
		
LAB4:	MOV	XX,AL
		;---------------------------------------------
LAB5:	MOV	AH, -1		;非法处理

LAB6:	MOV	XX, AH		;正常结束处理
		MOV	AH, 4CH
		INT		21H
		
CODE	ENDS
		END	START
		