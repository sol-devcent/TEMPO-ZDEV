*&---------------------------------------------------------------------*
*& Report  ZCO_NOTDISTR_COSTCOMPONEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_notdistr_costcomponen NO STANDARD PAGE HEADING.

INCLUDE zco_ndcctop.

INCLUDE zco_ndcccl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_bwkey   LIKE mbew-bwkey MODIF ID pbw.
SELECT-OPTIONS so_matnr   FOR mbew-matnr MODIF ID sma.
SELECT-OPTIONS so_poper   FOR ckmlkeph-poper MODIF ID spo.
PARAMETERS pa_bdatj   LIKE ckmlkeph-bdatj MODIF ID pbd.
SELECTION-SCREEN END OF BLOCK general.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
    WHEN space.
      PERFORM f_validate_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zco_ndccf01.
