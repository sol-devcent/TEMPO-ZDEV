REPORT ztdnsd_i012  NO STANDARD PAGE HEADING
                        LINE-SIZE  184
                        LINE-COUNT 65(4).

INCLUDE ZTDNSD_I018_TOP.
*INCLUDE ZTDNSD_I012_TOP.

PARAMETERS: p_proses(15) DEFAULT 'TDN_PAYMENT' MODIF ID rea .  "TDN_LAZADA
SELECTION-SCREEN SKIP 2.
PARAMETERS: p_demo NO-DISPLAY, "AS CHECKBOX DEFAULT ' ', "
            p_path TYPE eseftappl DEFAULT '/inbound/TDN/buktibayar.json'  NO-DISPLAY. "OBLIGATORY . "

INITIALIZATION.
  LOOP AT SCREEN.
    IF screen-group1 = 'REA'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

***********************************************************************
*s t a r t - o f - s e l e c t i o n                             *
***********************************************************************
START-OF-SELECTION.
  PERFORM f_get_data CHANGING sy-subrc gv_str.
  IF gv_str IS NOT INITIAL.
    FIND 'no_order' IN gv_str.
    IF sy-subrc EQ 0.
      PERFORM f_convert_json USING gv_str.
    ENDIF.
  ENDIF.
INCLUDE ZTDNSD_I018_F01.
*INCLUDE ZTDNSD_I012_F01.
