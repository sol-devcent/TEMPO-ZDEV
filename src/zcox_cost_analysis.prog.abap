*&---------------------------------------------------------------------*
*& Report  ZCOX_COST_ANALYSIS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zcox_cost_analysis NO STANDARD PAGE HEADING.

INCLUDE zcox_cost_analysistop.

INCLUDE zcox_cost_analysiscl1.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   LIKE caufv-bukrs MODIF ID buk.
PARAMETERS pa_werks   LIKE caufv-werks MODIF ID wer.
SELECT-OPTIONS so_matnr   FOR caufv-plnbez MODIF ID mat.
SELECT-OPTIONS so_aufnr   FOR caufv-aufnr.
SELECT-OPTIONS so_gstrp   FOR caufv-gstrp.
SELECT-OPTIONS so_gltrp   FOR caufv-gltrp.
SELECT-OPTIONS so_gltri   FOR caufv-gltri.
SELECT-OPTIONS so_txt04   FOR tj02t-txt04 NO INTERVALS.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_txt04-low.
  PERFORM f_value_request USING 'SO_TXT04-LOW'.

START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zcox_cost_analysisf01.
