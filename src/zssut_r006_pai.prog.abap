*&---------------------------------------------------------------------*
*&  Include           ZSSUT_R006_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE t_control_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'T_CONTROL'
                              'GT_ITAB'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "T_CONTROL_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_100  INPUT
*&---------------------------------------------------------------------*
MODULE pai_100 INPUT.
  IF sy-ucomm = '&F03'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " PAI_100  INPUT
