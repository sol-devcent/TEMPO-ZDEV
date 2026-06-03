*&---------------------------------------------------------------------*
*& Report  ZWM_E003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zwm_e003 NO STANDARD PAGE HEADING.

INCLUDE zwm_e003top.

INCLUDE zwm_e003cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_werks   TYPE t001w-werks MODIF ID pwe.
SELECT-OPTIONS so_tknum   FOR vttk-tknum MODIF ID s01.
SELECT-OPTIONS so_ebeln   FOR ekko-ebeln MODIF ID s02.
SELECT-OPTIONS so_vbeln   FOR gv_vbeln MODIF ID s02.
SELECT-OPTIONS so_zdtsu   FOR zwmdt004-zdtsul MODIF ID szd.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 200.
SELECTION-SCREEN BEGIN OF BLOCK 200 WITH FRAME.
PARAMETERS pa_budat   TYPE mkpf-budat DEFAULT sy-datum.
PARAMETERS pa_bktxt   TYPE mkpf-bktxt.
SELECTION-SCREEN END OF BLOCK 200.
SELECTION-SCREEN END OF SCREEN 200.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection-screen_output.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection-screen.
    WHEN space.
      PERFORM f_selection-screen.
  ENDCASE.




START-OF-SELECTION.
  PERFORM f_init_data.
**  IF radio4 = 'X'.
**    PERFORM f_view_data.
**  ELSE.
    PERFORM f_create_dyn_int_table.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_print_data.
"  ENDIF.
  INCLUDE zwm_e003m01.

  INCLUDE zwm_e003f01.
