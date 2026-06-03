*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e002 NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e002top.

START-OF-SELECTION.
  PERFORM f_init_data.

  IF sy-uname = 'TDS_DEV01' OR sy-uname = 'ABSUK'. "OR
*    sy-uname = 'PPIFA'.
    gv_operator = sy-uname.
    gv_pengawas = sy-uname.
    gv_pass     = 'X'.
  ELSE.
    CALL SCREEN 2999.
  ENDIF.

  IF gv_subrc IS INITIAL.
    CALL SCREEN 201.
  ENDIF.

  INCLUDE ztsppp_e002m01.

  INCLUDE ztsppp_e002f01.

  INCLUDE ztsppp_e000f0x.
