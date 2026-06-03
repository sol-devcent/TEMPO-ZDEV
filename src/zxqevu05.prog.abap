*&---------------------------------------------------------------------*
*&  Include           ZXQEVU05
*&---------------------------------------------------------------------*
DATA : lv_actvt(2).

break tds_dev01.
*break qmadk.

FIELD-SYMBOLS: <f1> LIKE rqeva.

IF i_qals-lagortchrg EQ '2004'.
  ASSIGN ('(SAPMQEVA)RQEVA') TO <f1>.
*  <f1>-vbewertung = 'A'.
*  <f1>-vcode      = '010'.
*  <f1>-vcodegrp   = '16'.
*  <f1>-qkennzahl  = '100'.
*  <f1>-vfolgeakti = 'MANUAL'.
  <f1>-qlgo_vm01  = '3004'.
ENDIF.

IF i_qals-lagortchrg EQ '2020'.
  IF i_qals-werk EQ '0101' OR
    i_qals-werk EQ '0102'.
    ASSIGN ('(SAPMQEVA)RQEVA') TO <f1>.
*  <f1>-vbewertung = 'A'.
*  <f1>-vcode      = '010'.
*  <f1>-vcodegrp   = '17'.
*  <f1>-qkennzahl  = '100'.
*  <f1>-vfolgeakti = 'MANUAL'.
    <f1>-qlgo_vm01  = '3020'.
    <f1>-qlgo_vm04  = '3020'.
  ENDIF.
ENDIF.

IF i_qals-werk = '3600'.
  CASE sy-tcode.
    WHEN 'QA12'.
      AUTHORITY-CHECK OBJECT 'ZQMLGOBWA'
          ID 'ACTVT' FIELD '02'
          ID 'LGORT' FIELD i_qals-lagortchrg.
      IF sy-subrc <> 0.
        MESSAGE e002(zz) WITH 'You have no authorization'.
      ENDIF.
    WHEN 'QA11'.
      AUTHORITY-CHECK OBJECT 'ZQMLGOBWA'
          ID 'ACTVT' FIELD '01'
          ID 'LGORT' FIELD i_qals-lagortchrg.
      IF sy-subrc <> 0.
        MESSAGE e002(zz) WITH 'You have no authorization'.
      ENDIF.
  ENDCASE.

ENDIF.

IF i_qals-werk = '3603'.
  IF <f1> IS ASSIGNED.
  ELSE.
    ASSIGN ('(SAPMQEVA)RQEVA') TO <f1>.
  ENDIF.

  CASE i_qals-matnr.
    WHEN 'I1093' OR 'I1094'.
      <f1>-neu_mat    = 'I7001'.
      <f1>-neu_charge = i_qals-charg.
    WHEN 'I1098' OR 'I1099'.
      <f1>-neu_mat    = 'I7002'.
      <f1>-neu_charge = i_qals-charg.
    WHEN OTHERS.
  ENDCASE.
ENDIF.
