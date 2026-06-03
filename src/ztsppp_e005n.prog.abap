*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E005N
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e005n NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e005ntop.

START-OF-SELECTION.
  PERFORM f_init_data.

  CALL SCREEN 501.

  INCLUDE ztsppp_e005nm01.

  INCLUDE ztsppp_e005nf01.
