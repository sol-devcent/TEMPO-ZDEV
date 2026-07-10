*&---------------------------------------------------------------------*
*& Report  ZCO_NOTALLO_COSTCOMPONEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_notallo_costcomponen NO STANDARD PAGE HEADING.

INCLUDE zco_nacctop.

INCLUDE zco_nacccl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_bwkey   LIKE mbew-bwkey MODIF ID pbw OBLIGATORY.
SELECT-OPTIONS so_matnr   FOR mbew-matnr MODIF ID sma.
SELECT-OPTIONS so_poper   FOR ckmlkeph-poper
                          MODIF ID spo
                          NO-EXTENSION
                          NO INTERVALS
                          OBLIGATORY.
PARAMETERS pa_bdatj   LIKE ckmlkeph-bdatj MODIF ID pbd OBLIGATORY.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp DEFAULT 'X' MODIF ID rpt.
PARAMETERS radio2 RADIOBUTTON GROUP grp MODIF ID rpt.
PARAMETERS radio3 RADIOBUTTON GROUP grp MODIF ID rpt.
SELECTION-SCREEN END OF BLOCK data1.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen USING : 'RPT' '0' '' '' ''.

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

  INCLUDE zco_naccf01.
