;ZH:ZL - �����, temp1 - ������������ ����

WriteEEP:
   sbic EECR, EEWE
   rjmp WriteEEP
   out EEARH, ZH
   out EEARL, ZL
  out EEDR, temp1
   sbi EECR, EEMWE
   sbi EECR, EEWE
ret

;------------------------------------------------------
;ZH:ZL - �����, temp1 - ��������� ����

ReadEEP:
   sbic EECR, EEWE
   rjmp ReadEEP
   out EEARH, ZH
   out EEARL, ZL
   sbi EECR, EERE
   in temp1, EEDR
ret

;------------------------------------------------------

	