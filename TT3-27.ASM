;TT3-27
;统计字符串长度以 0 结尾！

      MOV   AX, DSEG
      MOV   DS, AX
      MOV   AX, 0
      MOV   SI, OFFSET STRING

AG:   CMP   AL, [SI]			
      JZ    END
      INC   SI
      LOOP  AG