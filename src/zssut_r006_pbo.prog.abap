*&---------------------------------------------------------------------*
*&  Include           ZSSUT_R006_PBO
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
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'TITLE01'.

  loop at screen.
    if s_date-high is initial and ( screen-name = 'TEXT002' or screen-name = 'S_DATE-HIGH' ).
      screen-invisible = '1'.
      modify screen.
    else.
      screen-invisible = '0'.
      modify screen.
    endif.
  endloop.
ENDMODULE.                 " PBO_100  OUTPUT
