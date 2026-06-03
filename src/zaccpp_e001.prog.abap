*&---------------------------------------------------------------------*
*& Report  ZACCPP_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e001 NO STANDARD PAGE HEADING.

INCLUDE zaccpp_e001top.

INCLUDE zaccpp_e001cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_dwerk         TYPE afpo-dwerk MODIF ID pdw.
PARAMETERS pa_aufnr         TYPE afpo-aufnr MODIF ID pau.
PARAMETERS pa_matnr         TYPE afpo-matnr MODIF ID pma.
PARAMETERS pa_charg         TYPE afpo-charg MODIF ID pch.
SELECT-OPTIONS so_aufnr     FOR afpo-aufnr MODIF ID sau.
SELECT-OPTIONS so_matnr     FOR afpo-matnr MODIF ID sma.
SELECT-OPTIONS so_charg     FOR afpo-charg MODIF ID sch.
SELECT-OPTIONS so_gstrp     FOR afko-gstrp MODIF ID sgs.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_backg AS CHECKBOX MODIF ID pba.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(9) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(6) text-004 FOR FIELD radio2.
SELECTION-SCREEN POSITION 33.
PARAMETERS pa_add    TYPE sy-tabix MODIF ID pad.
SELECTION-SCREEN COMMENT 46(16) text-006 FOR FIELD pa_add MODIF ID pad.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(7) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_selection.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN space.
      PERFORM f_validate_screen.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_crt_dyn_int_table USING 'T'.
*  PERFORM f_crt_dyn_int_table USING 'B'.

  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zaccpp_e001f01.
