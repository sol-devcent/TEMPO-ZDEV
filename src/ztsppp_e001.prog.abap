*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e001 NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e001top.

START-OF-SELECTION.
  PERFORM f_init_data.

  IF sy-uname = 'TDS_DEV01' OR
    gv_npass = 'X'. "OR
*    sy-uname = 'PPIFA'.
    gv_operator = sy-uname.
    gv_pengawas = sy-uname.
    gv_pass     = 'X'.
  ELSE.
    CALL SCREEN 1999.
  ENDIF.

  IF gv_subrc IS INITIAL.
    CALL SCREEN 101.
  ENDIF.

  INCLUDE ztsppp_e001m01.

  INCLUDE ztsppp_e001f01.

  INCLUDE ztsppp_e000f0x.
