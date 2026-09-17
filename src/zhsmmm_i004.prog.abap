*&---------------------------------------------------------------------*
*& Report  ZTWSMM_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_i004 NO STANDARD PAGE HEADING.

INCLUDE ZHSMMM_I004TOP.
*INCLUDE ZTWSMM_E006TOP.

PARAMETERS p_ebeln  LIKE ekpo-ebeln.


PERFORM send_po USING p_ebeln sy-subrc sy-subrc.

INCLUDE ZHSMMM_I004F01.
*INCLUDE ZTWSMM_E006F01.
