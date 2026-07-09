*&---------------------------------------------------------------------*
*& Report  ZSD_BPJS_ALLOCATION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_wip NO STANDARD PAGE HEADING.

INCLUDE zabp_alv_common.

INCLUDE zco_wiptop.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_werks   LIKE aufk-werks MODIF ID pwe.
PARAMETERS pa_monat   LIKE bkpf-monat MODIF ID pmo DEFAULT sy-datum+4(2).
PARAMETERS pa_gjahr   LIKE cosb-gjahr MODIF ID pgj DEFAULT sy-datum(4).
SELECT-OPTIONS so_matnr FOR afpo-matnr MODIF ID sma.
SELECT-OPTIONS so_aufnr FOR aufk-aufnr MODIF ID sau.
SELECTION-SCREEN END OF BLOCK general.

INCLUDE zco_wipcl1.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.

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

  INCLUDE zco_wipf01.
