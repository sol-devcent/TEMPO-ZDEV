*&---------------------------------------------------------------------*
*& Report  ZFI_E006
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_e006 NO STANDARD PAGE HEADING.

INCLUDE zfi_e006top.

INCLUDE zfi_e006cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs   TYPE bseg-bukrs DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS: so_budat FOR bkpf-budat DEFAULT sy-datum
                                        MODIF ID bud OBLIGATORY,
                so_matnr FOR bseg-matnr NO INTERVALS MODIF ID nds.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK proses WITH FRAME TITLE TEXT-002.
PARAMETERS: butt1  RADIOBUTTON GROUP gb1 DEFAULT 'X' USER-COMMAND us1,
            butt11 RADIOBUTTON GROUP gb1,
            butt2  RADIOBUTTON GROUP gb1,
            butt3  RADIOBUTTON GROUP gb1.
SELECTION-SCREEN END OF BLOCK proses.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

START-OF-SELECTION.

  CASE 'X'.
    WHEN butt1 OR butt11.
      PERFORM f_init_data.
      PERFORM f_create_dyn_int_table.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
      PERFORM f_free_memory.
    WHEN butt2.
      SUBMIT zfidt007 WITH p_bukrs = pa_bukrs
                      AND RETURN.
    WHEN butt3.
      SUBMIT zfidt009 WITH p_bukrs = pa_bukrs
                      AND RETURN.
  ENDCASE.

end-of-selection.

  INCLUDE zfi_e006m01.

  INCLUDE zfi_e006f01.
