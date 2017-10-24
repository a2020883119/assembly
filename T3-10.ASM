;T3-10.ASM
;加法和循环实现乘法
DSEG	SEGMENT
XXX		DB	234
YYY		DB	125
ZZZ		DW	?
DSEG	ENDS

CSEG	SEGMENT
		ASSUME	DS:DSEG, CS:CSEG
START:	MOV	AX, DSEG
		MOV	DS, AX
		
		;第一种方法
		; MOV	AL, XXX			;乘数
		; XOR		AH, AH
		; MOV	CL,	YYY			;乘数
		; XOR		CH, CH
		; XOR		DX, DX
		
		; JCXZ	OK
		
; MULTL:	ADD		DX, AX			;循环+
		
		; LOOP	MULTL
		
; OK:		MOV	ZZZ, DX			;保存结果


		;第二种方法
		MOV	AL, XXX
		XOR		AH, AH
		MOV	BL, YYY
		XOR		DX, DX
		MOV	CX, 8
MULTL:	SHR		BL, 1			;最低位移入CF中
		JNC		NEXT			;是一就加 是零就乘
		ADD		DX, AX
NEXT:	ADD		AX, AX
		LOOP	MULTL
		;
		MOV	ZZZ, DX
		
		MOV	AH, 4CH
		INT		21H
		
CSEG	ENDS
		END		START