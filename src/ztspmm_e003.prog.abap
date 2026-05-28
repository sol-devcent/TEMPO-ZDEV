*&---------------------------------------------------------------------*
*& Report  ZTSPMM_E003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztspmm_e003 NO STANDARD PAGE HEADING.

INCLUDE ztspmm_e003top.

START-OF-SELECTION.

  PERFORM f_init_data.

  CALL SCREEN 101.

  INCLUDE ztspmm_e003m01.

  INCLUDE ztspmm_e003f01.
