*&---------------------------------------------------------------------*
*& Report  ZTTACPP_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zttacpp_e002 NO STANDARD PAGE HEADING
                     LINE-SIZE 255.

INCLUDE zttacpp_e002xtop.

PARAMETERS pa_werks   TYPE t001w-werks.

START-OF-SELECTION.
  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_get_data USING 'PRO' '1'.
    IF gv_subrc = 0.
      PERFORM f_ttac_login.
      PERFORM f_register_process USING 'ESTO'
                                 CHANGING gv_subrc1.
      PERFORM f_register_process USING 'RTS'
                                 CHANGING gv_subrc2.
      PERFORM f_register_process USING 'RJCT'
                                 CHANGING gv_subrc3.
    ENDIF.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      WRITE : / 'User & Email not yet maintain'.
    WHEN 2.
      WRITE : / 'User Token mismatch'.
    WHEN OTHERS.
      PERFORM f_write_report.
  ENDCASE.

  INCLUDE zttacpp_e002xf01.
