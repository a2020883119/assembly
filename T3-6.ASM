;T3-6.ASM
;实现三个无符号数的由大到小排列
DATAS	SEGMENT
BUFFER	DB 87, 234, 123
DATAS	ENDS
CODES	SEGMENT
		ASSUME	CS:CODES, DS:DATAS
						
START:	MOV	AX, DATAS			;段值
		MOV	DS, AX
		
		; MOV	SI, OFFSET BUFFER	;设置取值指针
		; MOV	AL, [SI]				;取值
		; MOV	BL, [SI + 1]
		; MOV	CL, [SI + 2]
		
		; CMP		AL, BL				;比较A和B，大的放在A
		; JAE		NEXT
		; XCHG	AL, BL
		
; NEXT:	CMP		AL, CL				;比较A和C，大的放在A
		; JAE		NEXT2
		; XCHG	AL, CL
		
; NEXT2:	CMP		BL, CL				;比较C和B，大的放在B
		; JAE		NEXT3
		; XCHG	BL, CL
		
; NEXT3:	MOV	[SI], AL				;比较结束，存值
		; MOV	[SI + 1], BL
		; MOV	[SI + 2], CL
		
		MOV	SI, OFFSET BUFFER	
		MOV	AL, [SI]
		CMP		AL, [SI + 1]			;比较A和B，大的放在A
		JAE		NEXT
		XCHG	AL, [SI + 1]
		
NEXT:	CMP		AL, [SI + 2]			;比较A和C，大的放在A
		JAE		NEXT2
		XCHG	AL, [SI + 2]
		
NEXT2:	MOV	AL, [SI + 1]			;比较C和B，大的放在B
		CMP		AL, [SI + 2]
		JAE		NEXT3
		XCHG	AL, [SI + 2]

NEXT3:	
		
		MOV	AH, 4CH
		INT		21H
		
CODES	ENDS 
		END START