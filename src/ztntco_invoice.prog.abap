*&----------------------------------------------------------------------
*&  TNT Invoice System
*&  28.02.2024
*&---------------------------------------------------------------------*
REPORT  ztntco_invoice NO STANDARD PAGE HEADING.

* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.

*------------------common TOP includes for the program----------------*
INCLUDE ztntco_invoicetop.
*INCLUDE ztrco_invoicetop.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS     p_bukrs  TYPE bukrs MODIF ID gry.
PARAMETERS     p_gjahr  TYPE gjahr MODIF ID gja.
SELECT-OPTIONS s_linno  FOR  zrevtr001-linno MODIF ID lin.
SELECT-OPTIONS s_invno  FOR  zaloktr02-invno MODIF ID inv.
SELECT-OPTIONS s_fakno  FOR  zrevtr001-fakturno MODIF ID in3.
SELECT-OPTIONS s_postdt FOR zrevtr001-postdate MODIF ID dat.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETER : r1 RADIOBUTTON GROUP gr1 USER-COMMAND uc1 DEFAULT 'X',
            r5 RADIOBUTTON GROUP gr1 MODIF ID ra5,
            r2 RADIOBUTTON GROUP gr1,
            r3 RADIOBUTTON GROUP gr1, "MODIF ID nds,
            r4 RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF SCREEN 212.
PARAMETERS: p_tdform LIKE ssfscreen-fname DEFAULT 'ZTNTSDF0001_WOFP' MODIF ID gry,
            p_dest   LIKE tsp03-padest OBLIGATORY,
            p_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X' MODIF ID nds.
SELECTION-SCREEN END OF SCREEN 212.

* Smartforms
INCLUDE zabp_frm.
INCLUDE zabp_smartform.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_bukrs = '8160'.
  p_gjahr = sy-datum(4).
  PERFORM f_get_printer CHANGING p_dest.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF sscrfields-ucomm IS INITIAL OR
     sscrfields-ucomm EQ 'ONLI'.
    PERFORM f_validate_screen_1000.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE ztntco_invoicef01.
*  INCLUDE ztrco_invoicef01.
