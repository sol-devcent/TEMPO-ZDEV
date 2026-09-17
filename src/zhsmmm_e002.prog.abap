*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e002 NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE zhsmmm_e002top.

DATA: gv_nama(15).
DATA: gv_norfq(15).
DATA: gv_erdat LIKE  sy-datum.
*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
PARAMETERS: p_proses(15) DEFAULT 'HSM_QOUT' MODIF ID rea .  "TDN_LAZADA
SELECTION-SCREEN  SKIP 1.
PARAMETERS: p_tender TYPE char10. " DEFAULT '3000000106'.
SELECTION-SCREEN  SKIP 2.
PARAMETERS: p_back AS CHECKBOX DEFAULT ' ' MODIF ID rea,
            p_demo  AS CHECKBOX DEFAULT ' ' MODIF ID rea, "NO-DISPLAY, "
            p_path TYPE eseftappl DEFAULT '/inbound/tnt/test/3000000241.json' MODIF ID rea. "NO-DISPLAY. "
"OBLIGATORY . "NO-DISPLAY. "1000000001

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  LOOP AT SCREEN.
    IF screen-group1 = 'REA'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST FOR
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  IF p_tender IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zhsmmmdt003 FROM zhsmmmdt003 WHERE zproses = 'HSM_QOUT' AND status NE 'D'
      ORDER BY PRIMARY KEY.
    IF sy-subrc EQ 0.
      LOOP AT gt_zhsmmmdt003 INTO gs_zhsmmmdt003.
        PERFORM f_clear_data.
        p_tender = gs_zhsmmmdt003-zdata.
        CONDENSE p_tender.
        WRITE: / 'Proses Tender no. : ', p_tender.
        PERFORM f_get_data CHANGING sy-subrc gv_str.
        IF gv_str IS NOT INITIAL.
          PERFORM f_proses_data.
        ENDIF.
      ENDLOOP.
    ELSE.
      WRITE: / 'No Data'.
    ENDIF.
    gv_erdat = sy-datum - 7.
    DELETE FROM zhsmmmdt003 WHERE erdat < gv_erdat AND status = 'D'.
  ELSE.
    WRITE: / 'Proses Tender no. : ', p_tender.
    PERFORM f_get_data CHANGING sy-subrc gv_str.
    IF gv_str IS NOT INITIAL.
      PERFORM f_proses_data.
    ENDIF.
  ENDIF.
  IF p_back = 'X'.
    PERFORM f_get_data CHANGING sy-subrc gv_str.
    IF gv_str IS NOT INITIAL.
      PERFORM f_proses_data.
    ENDIF.
  ENDIF.
  INCLUDE zhsmmm_e002f01.
