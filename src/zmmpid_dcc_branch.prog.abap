*&---------------------------------------------------------------------*
*& Report  ZMMPID_DCC_BRANCH
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zmmpid_dcc_branch NO STANDARD PAGE HEADING.

INCLUDE zmmpiddccbranchtop.

INCLUDE zmmpiddccbranchcl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
SELECT-OPTIONS so_matnr   FOR mara-matnr.
SELECT-OPTIONS so_charg   FOR mchb-charg.
SELECT-OPTIONS so_werks   FOR mard-werks MODIF ID swe.
SELECT-OPTIONS so_lgort   FOR mard-lgort.
SELECT-OPTIONS so_mtart   FOR mara-mtart.
SELECT-OPTIONS so_matkl   FOR mara-matkl.
*PARAMETERS pa_spmon   TYPE zstarget-spmon MODIF ID psp.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_lvorm AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK control WITH FRAME TITLE text-002.
PARAMETERS pa_sessi       TYPE zmdcc_branch-zsessi DEFAULT 'DCC'.
PARAMETERS pa_zeili       TYPE iseg-zeili DEFAULT 50.
SELECTION-SCREEN END OF BLOCK control.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid = sy-repid.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_crt_dyn_int_table.

  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zmmpiddccbranchf01.
