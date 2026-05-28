REPORT ztdnfi_i003  NO STANDARD PAGE HEADING.
"LINE-SIZE  250
"LINE-COUNT 65(4).

INCLUDE zghfi_e002_top.
*INCLUDE ztdnfi_i003_top.
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS p_bukrs TYPE vbrk-vkorg MODIF ID req DEFAULT '8020'.
SELECT-OPTIONS s_vkbur FOR vbrp-vkbur MODIF ID req NO INTERVALS.
SELECT-OPTIONS s_kunnr FOR bsad-kunnr MODIF ID re1 NO INTERVALS.
SELECT-OPTIONS s_belnr FOR bsad-belnr.
SELECT-OPTIONS s_budat FOR bsad-budat MODIF ID req OBLIGATORY NO-EXTENSION. " DEFAULT sy-datum.
SELECT-OPTIONS s_zfbdt FOR bsad-zfbdt NO-DISPLAY. " DEFAULT sy-datum.


**PARAMETERS: p_kunnr LIKE ztdnfidt007h-kunnr  DEFAULT 'TS002' AS LISTBOX VISIBLE LENGTH 45. "  OBLIGATORY. " LIKE numchar10.
**SELECT-OPTIONS: p_notran FOR ztdnfidt007h-notrans NO INTERVALS. " AS LISTBOX VISIBLE LENGTH 20. "  OBLIGATORY..
**SELECT-OPTIONS: s_erdat FOR ztdnfidt007h-erdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: rb_1 RADIOBUTTON GROUP rad, " NO-DISPLAY,
            "            rb_2 RADIOBUTTON GROUP rad, "NO-DISPLAY.
            rb_3 DEFAULT 'X' RADIOBUTTON GROUP rad.
PARAMETERS: rb_2 NO-DISPLAY.
"PARAMETERS:rb_3 NO-DISPLAY
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_back AS CHECKBOX DEFAULT ' ' MODIF ID bck  .
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.
  gv_repid    = sy-repid.
**  s_zfbdt-high = sy-datum.
**  s_zfbdt-low = sy-datum - 30.
**  s_zfbdt-sign   = 'I'.
**  s_zfbdt-option = 'BT'.
**  APPEND s_zfbdt.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with company code '
     p_bukrs.
  ENDIF.

AT SELECTION-SCREEN ON s_vkbur.
  SELECT * INTO TABLE gt_tvbur FROM tvbur
    WHERE vkbur IN s_vkbur.
  LOOP AT gt_tvbur.
    AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
        ID 'VKBUR' FIELD gt_tvbur-vkbur.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
       gt_tvbur-vkbur.
    ENDIF.
  ENDLOOP.

***********************************************************************
*s t a r t - o f - s e l e c t i o n                             *
***********************************************************************
START-OF-SELECTION.
  IF s_budat[] IS INITIAL.
    CONCATENATE sy-datum(6) '01' INTO s_budat-low.
    PERFORM f_last_day USING s_budat-low
                       CHANGING s_budat-high.
    s_budat-sign   = 'I'.
    s_budat-option = 'BT'.
    APPEND s_budat.
  ENDIF.
  s_zfbdt-high = sy-datum.
  s_zfbdt-low = s_budat-low - 30.
  s_zfbdt-sign   = 'I'.
  s_zfbdt-option = 'BT'.
  APPEND s_zfbdt.


  PERFORM f_get_data. " TABLES gt_itab.
  IF gt_header[] IS INITIAL.
    WRITE: / 'Tidak ada data'.
    MESSAGE e002(zz) WITH 'Tidak ada Data'.
    STOP.
  ENDIF.
  PERFORM f_proses_data.
  CASE 'X'.
    WHEN rb_1.
      IF p_back = 'X'.
        PERFORM f_posting_data.
      ELSE.
        PERFORM f_print_data.
      ENDIF.
    WHEN rb_2.
      PERFORM f_print_data.
    WHEN rb_3.
      PERFORM f_print_data.
    WHEN OTHERS.
  ENDCASE.
  INCLUDE zghfi_e002_f01.
