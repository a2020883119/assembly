;程序名称：T3-2.ASM
;功能：计算16X+Y
;
DSEG	SEGMENT
XXX		DW		1234H
YYY		DW		5678H
ZZZ		DD		?
DSEG	ENDS
;
CSEG	SEGMENT
		ASSUME  CS:CSEG, DS:DSEG
START:	MOV	AX, DSEG
		MOV 	DS, AX
		MOV	AX, XXX
		XOR		DX, DX
		;------------------------------------------------------
		;相加
		; ;X2
		; ADD		AX, AX
		; ADC		DX, DX
		; ;X4
		; ADD		AX, AX
		; ADC		DX, DX
		; ;X6
		; ADD		AX, AX
		; ADC		DX, DX
		; ;X8
		; ADD		AX, AX
		; ADC		DX, DX
		; ;X16
		; ADD		AX, AX
		; ADC		DX, DX
		; ;+YYY
		; ADD		AX, YYY
		; ADC		DX, 0
		;------------------------------------------------------
		;
		; ;------------------------------------------------------
		; ;移位
		; MOV		AX, XXX
		; MOV		DX, AX
		; MOV		CL, 4
		; SHL			AX, CL
		; MOV		CL, 12
		; SHR			DX, CL
		; ;------------------------------------------------------
		;
		; ;------------------------------------------------------
		; ;乘法
		; MOV	AX, XXX
		; MOV 	DX, 16
		; MUL	 DX
		; ;------------------------------------------------------
		;SAVE
		MOV	WORD PTR ZZZ, AX
		MOV	WORD PTR ZZZ + 2, DX
		;END
		MOV 	AH, 4CH
		INT		21H
CSEG	ENDS
		END START