;TT3-25
;AL和BL每位依次交叉形成16位结果存放到DX中
CSEG     SEGMENT
         ASSUME CS:CSEG
START:   MOV    CX, 4
AG:      SHR    AL, 1
         ADC    DX, DX
         SHR    BL, 1
         ADC    DX, DX
         LOOP   AG
            
 
         MOV    AH, 4CH
         INT    21H
CSEG     ENDS
         END    START