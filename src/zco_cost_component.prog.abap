*&---------------------------------------------------------------------*
*& Report  ZCO_COST_COMPONENT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_cost_component NO STANDARD PAGE HEADING.

INCLUDE zco_cocotop.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS : pa_bwkey   LIKE mbew-bwkey OBLIGATORY.
SELECT-OPTIONS : so_matnr   FOR mbew-matnr.
PARAMETERS : pa_poper   LIKE ckmlprkeph-poper OBLIGATORY.
PARAMETERS : pa_bdatj   LIKE ckmlprkeph-bdatj OBLIGATORY.
SELECTION-SCREEN END OF BLOCK general.

INCLUDE zco_cococl1.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zco_cocof01.
