FUNCTION zf_faktur.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(FAKDAT) TYPE  ZGDTXDE_FAKDAT
*"     REFERENCE(MASATX) TYPE  ABPER_RF
*"     REFERENCE(FAKTURIN) TYPE  ZGDTXDE_FAKNO
*"     VALUE(TCODE) TYPE  SY-TCODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(FAKTUROUT) TYPE  CHAR21
*"----------------------------------------------------------------------
  CONSTANTS : lc_mask(20)  VALUE '___.___-__.________',
              lc_mask1(21) VALUE '__.__.__-___.________'.

  DATA : lv_faktur(20).
  DATA : lt_vat   LIKE zfvatnr_dtl OCCURS 0 WITH HEADER LINE.

  CLEAR : lt_vat, lt_vat[], lv_faktur.
  SELECT SINGLE fakturno
    FROM zfvatfp
    INTO lv_faktur
    WHERE bukrs EQ bukrs
      AND datab LE fakdat
      AND datbi GE fakdat.
  IF sy-subrc EQ 0.
    SELECT *
      FROM zfvatnr_dtl
      INTO CORRESPONDING FIELDS OF TABLE lt_vat
      WHERE vkorg EQ bukrs
        AND gjahr EQ masatx(4).
    LOOP AT lt_vat.
      IF fakturin+8(8) BETWEEN lt_vat-vatfr
                           AND lt_vat-vatto.
        IF lt_vat-vatpr IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lt_vat-vatpr IS INITIAL.
      WRITE fakturin TO fakturout
      USING EDIT MASK lv_faktur.
    ELSE.
      WRITE fakturin TO fakturout
      USING EDIT MASK lc_mask.
    ENDIF.
  ELSE.
    IF tcode = 'ZGDTXE0002_02'.
      WRITE fakturin TO fakturout
      USING EDIT MASK lc_mask1.
    ELSE.
      WRITE fakturin TO fakturout
      USING EDIT MASK lc_mask.
    ENDIF.
  ENDIF.
ENDFUNCTION.
