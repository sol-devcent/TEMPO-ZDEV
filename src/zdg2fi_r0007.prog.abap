*&---------------------------------------------------------------------*
*& Report ZDG2FI_R0007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdg2fi_r0007 NO STANDARD PAGE HEADING.

INCLUDE zdg2fi_r0007top.

INCLUDE zdg2fi_r0007cl1.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs       TYPE anla-bukrs MODIF ID pbu.
SELECT-OPTIONS so_gsber   FOR anlp-gsber MODIF ID sgs.
SELECT-OPTIONS so_anlkl   FOR anla-anlkl MODIF ID pan.
SELECT-OPTIONS so_anln1   FOR anla-anln1 MODIF ID sa1.
SELECT-OPTIONS so_anln2   FOR anla-anln2 MODIF ID sa2.
PARAMETERS pa_bdatu       TYPE rbada-brdatu MODIF ID pbd.
PARAMETERS pa_afabe       TYPE anlp-afaber MODIF ID paf
                                           DEFAULT '01'.
SELECTION-SCREEN END OF BLOCK data.

INITIALIZATION.
  pa_bdatu = |{ sy-datum(4) }{ '1231' }|.
  gv_repid    = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anlkl-low.
  PERFORM f_f4_help USING 'SO_ANLKL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anlkl-high.
  PERFORM f_f4_help USING 'SO_ANLKL-HIGH'.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anln1-low.
*  PERFORM f_f4_help USING 'SO_ANLN1-LOW'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anln1-high.
*  PERFORM f_f4_help USING 'SO_ANLN1-HIGH'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anln2-low.
*  PERFORM f_f4_help USING 'SO_ANLN2-LOW'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_anln2-high.
*  PERFORM f_f4_help USING 'SO_ANLN2-HIGH'.

START-OF-SELECTION.
  PERFORM f_parameter_id USING 'BUK' pa_bukrs.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zdg2fi_r0007f01.
