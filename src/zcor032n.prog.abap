*&---------------------------------------------------------------------*
*& Report ZCOR032
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcor032n.
INCLUDE zabp_alv_common.
INCLUDE zcor032n_top.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs TYPE ce18010-bukrs MODIF ID pbu,
            p_file  LIKE rlgrap-filename MODIF ID pfi.

SELECT-OPTIONS: s_perio FOR ce18010-perio MODIF ID spe NO-EXTENSION, "OBLIGATORY,
                s_kndnr FOR ce18010-kndnr MODIF ID skn,
                s_artnr FOR ce18010-artnr MODIF ID art.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: r1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X',
            r2 RADIOBUTTON GROUP grp1,
            r3 RADIOBUTTON GROUP grp1.

SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.
  PERFORM f_init_period.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: lv_repid LIKE sy-repid.
  lv_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = lv_repid
      dynpro_number = sy-dynnr
      field_name    = 'P_FILE'
    IMPORTING
      file_name     = p_file
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    CLEAR p_file.
  ENDIF.

START-OF-SELECTION.
  DATA: lv_answer.

  IF r1 = 'X'.
    PERFORM f_get_data_cds.
    PERFORM f_print_data.

  ELSEIF r2 = 'X'.
    PERFORM f_table_maintenance.

  ELSEIF r3 = 'X'.
    PERFORM f_upload_data.
  ENDIF.

  INCLUDE zcor032n_f01.
