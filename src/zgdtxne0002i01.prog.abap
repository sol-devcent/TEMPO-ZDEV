*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE00002I01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1300 INPUT.

  PERFORM f_user_command.

ENDMODULE.                 " USER_COMMAND_1300  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_BILLING  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_billing INPUT.

  MODIFY t_vbrkscr INDEX ctrl_1300-current_line.
  d_line_count = sy-loopc.

ENDMODULE.                 " CHECK_BILLING  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_screen INPUT.

  PERFORM f_exit_screen USING sy-dynnr.

ENDMODULE.                 " EXIT_SCREEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_HELP_REQUEST_TAX  INPUT
*&---------------------------------------------------------------------*
MODULE m_help_request_tax INPUT.

  PERFORM f_on_help_request USING 'Include Tax'
                                  c_on_help_request_tax.

ENDMODULE.                 " M_HELP_REQUEST_TAX  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_custom_field  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_custom_field INPUT.

  CHECK NOT r_act5 IS INITIAL.
  IF d_petugas_e IS INITIAL OR
     d_jabat_e IS INITIAL.
    MESSAGE e000(zab)
            WITH 'Please fill Name and Position'.
  ENDIF.

ENDMODULE.                 " m_check_custom_field  INPUT

*&---------------------------------------------------------------------*
*&      Module  display_detail  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_detail INPUT.

  PERFORM f_display_billing.

ENDMODULE.                 " display_detail  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_fakdat  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_fakdat INPUT.

  IF t_vbrkscr-fakdat IS INITIAL.
    MESSAGE e000(zab) WITH 'Please enter faktur pajak date'.
  ELSE.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
         EXPORTING
              date                      = t_vbrkscr-fakdat
         EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
  t_vbrkscr-fakdat = t_vbrkscr-fakdat.
** masa tax 17012006
  t_vbrkscr-masatx = t_vbrkscr-fakdat(6).


ENDMODULE.                 " m_check_fakdat  INPUT
