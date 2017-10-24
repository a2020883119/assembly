;T3-13
;计数和条件双重控制的循环  找到第一个'A'，并把偏移地址保存在指定位置，找不到把-1保存在指定位置

;定义常量
SEGADDR		= 40H		;开始段地址
OFFADDR		= 0			;开始地址偏移
COUNT		= 2048		;长度
KEYCHAR		= 'A'			;关键字
SEGRESU		= 0			;结果保存单元段值
OFFRESU		= 3FEH		;结果保存单元偏移
;代码段
CSEG		SEGMENT
			ASSUME	CS:CSEG

START:		MOV	AX, SEGADDR		;初始化
			MOV	DS, AX			;
			
			MOV	SI, OFFADDR		;开始偏移位置
			MOV	CX, COUNT		;计数器
			MOV	AL, KEYCHAR		;关键字
			
NEXT:		CMP		AL,[SI]			;是否是要找到
			JZ		OK				;是 跳转到结束处理
			INC		SI				;不是
			LOOP	NEXT			;下一个
			MOV	SI, 0FFFFH		;找完了 没找到，结束

OK:			MOV	AX, SEGRESU		;拿保存偏移地址位置的段地址
			MOV	DS, AX			;
			MOV	BX, OFFRESU		;拿保存偏移地址位置的偏移地址
			MOV	[BX], SI			;保存
			
			MOV	AH, 4CH
			INT		21H
CSEG		ENDS
			END		START