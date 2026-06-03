*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E006
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e006 NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e006top.

START-OF-SELECTION.
  PERFORM f_init_data.

  CALL SCREEN 601.

  INCLUDE ztsppp_e006m01.

  INCLUDE ztsppp_e006f01.
