*&---------------------------------------------------------------------*
*& Report  ZTTACPP_E001S
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zttacpp_e001p NO STANDARD PAGE HEADING
                      LINE-SIZE 255.

INCLUDE zttacpp_e001pxtop.

PARAMETERS pa_werks   TYPE t001w-werks.

START-OF-SELECTION.
  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_get_data USING 'PRO' ''.
    IF gv_subrc = 0.
      PERFORM f_ttac_login.
      PERFORM f_registerparent_process.
    ENDIF.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      WRITE : / 'User & Email not yet maintain'.
    WHEN 2.
      WRITE : / 'No Data processed'.
    WHEN 3.
      WRITE : / 'Token not found'.
    WHEN OTHERS.
      PERFORM f_write_report.
  ENDCASE.

  INCLUDE zttacpp_e001pxf01.
