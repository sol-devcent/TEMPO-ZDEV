*&---------------------------------------------------------------------*
*& Report  ZMM_COO_DC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmm_coo_dc NO STANDARD PAGE HEADING.

INCLUDE zmmcoodctop.

INCLUDE zmmcoodccl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_lgnum   LIKE lqua-lgnum MODIF ID plg OBLIGATORY.
PARAMETERS pa_vstel   LIKE tvst-vstel MODIF ID pvs OBLIGATORY.
SELECT-OPTIONS so_matnr   FOR ekpo-matnr MODIF ID sma.
SELECT-OPTIONS so_ebeln   FOR ekko-ebeln MODIF ID seb.
SELECT-OPTIONS so_bedat   FOR ekko-bedat MODIF ID sbe
                                         OBLIGATORY
                                         NO-EXTENSION.
SELECT-OPTIONS so_coono   FOR zbdcdt02-coono MODIF ID sco.
SELECT-OPTIONS so_coodt   FOR zbdcdt02-coodt MODIF ID scd.
SELECT-OPTIONS so_lgtyp   FOR lqua-lgtyp MODIF ID slp.
SELECT-OPTIONS so_lgpla   FOR lqua-lgpla MODIF ID sla.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
PARAMETERS radio6 RADIOBUTTON GROUP grp1 MODIF ID del.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

  IF so_bedat[] IS INITIAL.
    CONCATENATE sy-datum(6) '01' INTO so_bedat-low.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = so_bedat-low
      IMPORTING
        last_day_of_month = so_bedat-high
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    so_bedat-sign     = 'I'.
    so_bedat-option   = 'BT'.
    APPEND so_bedat.
    CLEAR so_bedat.
  ENDIF.

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
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_display_data.

  INCLUDE zmmcoodcf01.
