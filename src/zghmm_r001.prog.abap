*&---------------------------------------------------------------------*
*& Report  ZMM_R001
*&
*&---------------------------------------------------------------------*
*&
*&  Faktur Pembelian vs Nota Retur Report Monitoring
*&
*&---------------------------------------------------------------------*

REPORT  zghmm_r001 NO STANDARD PAGE HEADING.

INCLUDE zghmm_r001top.

INCLUDE zghmm_r001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs     LIKE rbkp-bukrs OBLIGATORY DEFAULT '8020',
            p_gjahr     LIKE rbkp-gjahr OBLIGATORY DEFAULT sy-datum(4).
*            p_lifnr     LIKE rbkp-lifnr.
SELECT-OPTIONS: s_lifnr FOR rbkp-lifnr,
                s_matnr FOR rseg-matnr,
                s_zuonr FOR rbkp-zuonr.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

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

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST FOR
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
*  PERFORM f_f4_filename CHANGING pa_fname.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.


  INCLUDE zghmm_r001m01.

  INCLUDE zghmm_r001f01.
