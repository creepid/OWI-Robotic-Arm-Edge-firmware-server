;ZH:ZL - адрес, temp1 - записываемый байт

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
;ZH:ZL - адрес, temp1 - прочтённый байт

ReadEEP:
   sbic EECR, EEWE
   rjmp ReadEEP
   out EEARH, ZH
   out EEARL, ZL
   sbi EECR, EERE
   in temp1, EEDR
ret

;------------------------------------------------------

	