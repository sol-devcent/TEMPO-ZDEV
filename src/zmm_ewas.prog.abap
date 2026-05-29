*&---------------------------------------------------------------------*
*& Report  ZMM_EWAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmm_ewas NO STANDARD PAGE HEADING.

INCLUDE zabp_atz.

INCLUDE zmm_ewastop.

INCLUDE zmm_ewasc01.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   LIKE t001-bukrs OBLIGATORY DEFAULT '8010' MODIF ID xxx.
PARAMETERS pa_werks   LIKE t001w-werks OBLIGATORY DEFAULT '0101'. " MODIF ID xxx.
SELECT-OPTIONS so_matnr   FOR marc-matnr MODIF ID xxx.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-010 FOR FIELD pa_gjahr MODIF ID xxx.
PARAMETERS pa_gjahr TYPE mseg-gjahr OBLIGATORY DEFAULT sy-datum(4) MODIF ID xxx.
SELECTION-SCREEN COMMENT 41(7) text-011 FOR FIELD pa_quart MODIF ID xxx.
PARAMETERS pa_quart TYPE alquart MODIF ID xxx.
SELECTION-SCREEN COMMENT 53(30) pa_month MODIF ID xxx.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP.
PARAMETERS pa_lgort LIKE mardh-lgort NO-DISPLAY DEFAULT '1000' MODIF ID xxx.

SELECT-OPTIONS so_budat FOR mkpf-budat NO-EXTENSION MODIF ID gry.
SELECT-OPTIONS so_lgort FOR mseg-lgort NO INTERVALS MODIF ID gry.
SELECT-OPTIONS so_bwart FOR mseg-bwart NO INTERVALS MODIF ID gry.
PARAMETERS pa_max   TYPE sytabix NO-DISPLAY DEFAULT '100'.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(31) text-003 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  CLEAR : gt_zmmewas[], gt_zmmewas.
  SELECT *
    FROM zmmewas
    INTO CORRESPONDING FIELDS OF TABLE gt_zmmewas
    WHERE werks = pa_werks.

  PERFORM f_init_quarter.
  PERFORM f_init_lgort.
  PERFORM f_init_bwart.

  PERFORM f_modify_screen_1000.

AT SELECTION-SCREEN ON pa_quart.
  PERFORM f_init_quarter.

*AT SELECTION-SCREEN ON pa_bukrs.
*  macro_atz_single_bukrs pa_bukrs c_atz_display.

AT SELECTION-SCREEN ON pa_werks.
*  macro_atz_single_werks pa_werks c_atz_display.
  AUTHORITY-CHECK OBJECT 'ZMM_PLANT'
           ID 'WERKS' FIELD pa_werks
           ID 'ACTVT' FIELD '03'.
  macro_atz_error_message 'Plant' pa_werks '03'.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zmm_ewasf01.
