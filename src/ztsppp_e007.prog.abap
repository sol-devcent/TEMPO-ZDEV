*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e007 NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e007top.

START-OF-SELECTION.
  PERFORM f_init_data.

  CALL SCREEN 701.

  INCLUDE ztsppp_e007m01.

  INCLUDE ztsppp_e007f01.
