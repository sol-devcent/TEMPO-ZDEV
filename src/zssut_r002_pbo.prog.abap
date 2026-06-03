*&---------------------------------------------------------------------*
*&  Include           ZSSUT_I010_PBO
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE t_control_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_itab LINES t_control-lines.
ENDMODULE.                    "T_CONTROL_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE t_control_get_lines OUTPUT.
  g_t_control_lines = sy-loopc.
ENDMODULE.                    "T_CONTROL_GET_LINES OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_100 OUTPUT.
  SET TITLEBAR 'TITLE01'.
  IF gv_edit = 'X'.
    SET PF-STATUS 'STANDARD'.
  ELSE.
    DATA fcode TYPE TABLE OF sy-ucomm.
    APPEND '&SAV' TO fcode.
    SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  ENDIF.
*  if gv_first_call = 'X'.
*    gv_edit = 'X'.
*    clear gv_first_call.
*  endif.
ENDMODULE.                 " PBO_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_101  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_101 OUTPUT.
  DATA: ls_cols LIKE LINE OF t_control-cols.
  IF gv_edit = 'X'.
    LOOP AT t_control-cols INTO ls_cols.
      IF ls_cols-screen-name = 'GS_ITAB-NAME1' OR ls_cols-screen-name = 'GS_ITAB-ADDRS'
        OR ls_cols-screen-name = 'GS_ITAB-KUNN2'.
        ls_cols-screen-input = 0.
        MODIFY t_control-cols FROM ls_cols.
      ELSEIF ls_cols-screen-name = 'GS_ITAB-COUNTER' OR ls_cols-screen-name = 'GS_ITAB-KUNNR'.
        ls_cols-screen-input = 1.
        MODIFY t_control-cols FROM ls_cols.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT t_control-cols INTO ls_cols.
      IF ls_cols-screen-name = 'GS_ITAB-COUNTER' OR ls_cols-screen-name = 'GS_ITAB-NAME1' OR ls_cols-screen-name = 'GS_ITAB-ADDRS'
        OR ls_cols-screen-name = 'GS_ITAB-KUNNR' OR ls_cols-screen-name = 'GS_ITAB-KUNN2'.
        ls_cols-screen-input = 0.
        MODIFY t_control-cols FROM ls_cols.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " PBO_101  OUTPUT
