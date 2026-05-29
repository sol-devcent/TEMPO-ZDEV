*&---------------------------------------------------------------------*
*& Report  ZTDS_RTMP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e010 NO STANDARD PAGE HEADING.

INCLUDE ztsppp_e010top.

INCLUDE ztsppp_e010cl1.

INCLUDE zabp_bdc.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_werks   TYPE resb-werks MODIF ID pwe.
PARAMETERS pa_aufnr   TYPE resb-aufnr MODIF ID pau.
SELECT-OPTIONS so_posnr   FOR resb-posnr MODIF ID spo
                                         NO-EXTENSION
                                         NO INTERVALS.
SELECTION-SCREEN END OF BLOCK data.

*SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
*PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
*PARAMETERS radio2 RADIOBUTTON GROUP grp1.
*PARAMETERS radio3 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN END OF BLOCK option.

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

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE ztsppp_e010m01.

  INCLUDE ztsppp_e010f01.
