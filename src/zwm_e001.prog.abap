*&---------------------------------------------------------------------*
*& Report  ZWM_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zwm_e001 NO STANDARD PAGE HEADING LINE-SIZE  294.

INCLUDE zwm_e001top.

INCLUDE zwm_e001cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
PARAMETERS pa_lgnum    TYPE lagp-lgnum OBLIGATORY.
PARAMETERS pa_lgtyp    TYPE lagp-lgtyp OBLIGATORY DEFAULT 'CPH'.
SELECT-OPTIONS so_matnr   FOR mlgt-matnr.
SELECTION-SCREEN END OF BLOCK general.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid = sy-repid.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
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

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_build_fieldcat USING 'MAIN'.
  IF pa_lgnum = 'C40'.
    PERFORM f_process_data_c40.
  ELSE.
    PERFORM f_process_data.
  ENDIF.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

  INCLUDE zwm_e001f01.
