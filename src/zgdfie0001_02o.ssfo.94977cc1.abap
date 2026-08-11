DATA: ld_datab  LIKE zproject-datab,
      lv_faktur(20),
      masatx    TYPE abper_rf.

masatx = header-budat(6).
IF header-budat(4) GT 2006.
  CALL FUNCTION 'ZF_FAKTUR'
    EXPORTING
      bukrs     = header-bukrs
      fakdat    = header-budat
      masatx    = masatx
      fakturin  = header-fakno
    IMPORTING
      fakturout = va_fakno.
  IF va_fakno IS INITIAL.
    CONCATENATE header-fakno(3) '.'
                header-fakno+3(3) '-'
                header-fakno+6(2) '.'
                header-fakno+8(8)
    INTO va_fakno.
  ENDIF.
ELSE.
  va_fakno = header-fakno.
ENDIF.

SELECT SINGLE datab
FROM zproject
INTO ld_datab
WHERE name EQ 'ZGDTAX'.

IF header-budat GE ld_datab.
  va_materai  = 'X'.
ELSE.
  CLEAR: va_materai.
ENDIF.


















