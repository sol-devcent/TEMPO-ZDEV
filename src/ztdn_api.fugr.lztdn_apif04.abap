*----------------------------------------------------------------------*
***INCLUDE LZTDN_APIF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_VOUCHER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_ORDER  text
*----------------------------------------------------------------------*
FORM f_proses_voucher  USING    p_order TYPE bstkd CHANGING p_return.
  DATA: lt_ztdnsddt010 TYPE STANDARD TABLE OF ztdnsddt010.
  DATA: lt1_ztdnsddt010 TYPE STANDARD TABLE OF ztdnsddt010.
  DATA: lt2_ztdnsddt010 TYPE STANDARD TABLE OF ztdnsddt010.
  DATA: ls_ztdnsddt010 TYPE ztdnsddt010.
  "  DATA: p_return(1).
  CLEAR p_return.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ztdnsddt010 FROM ztdnsddt010 WHERE order_id = p_order.
  lt1_ztdnsddt010[] = lt_ztdnsddt010[].
  DELETE lt1_ztdnsddt010[] WHERE belnr IS INITIAL.
  IF lt1_ztdnsddt010[] IS NOT INITIAL.
    CLEAR: gt_out[], gt_out.
    LOOP AT lt1_ztdnsddt010 INTO ls_ztdnsddt010.
      APPEND ls_ztdnsddt010 TO gt_out.
    ENDLOOP.
  ELSE.
  ENDIF.
  IF gt_out[] IS NOT INITIAL.
    PERFORM f_posting_document_fi CHANGING p_return gv_belnr.
  ENDIF.
ENDFORM.                    " F_PROSES_VOUCHER
