*&---------------------------------------------------------------------*
*& Report zihqm_r004
*&---------------------------------------------------------------------*
*& Copy from ZQM_QE51N
*&---------------------------------------------------------------------*
REPORT zihqm_r004.

TABLES: sscrfields,qals,qasr.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
  PARAMETERS : pa_werks TYPE werks_d MODIF ID wer.
  PARAMETERS : pa_matnr TYPE matnr MODIF ID mat.
  SELECT-OPTIONS : so_charg FOR qals-charg.
  SELECT-OPTIONS : so_erste FOR qasr-erstelldat MODIF ID ers NO-EXTENSION.
  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN: COMMENT 1(32) TEXT-003 FOR FIELD pa_verwm MODIF ID ver.
    SELECTION-SCREEN: POSITION 33.
    PARAMETERS : pa_verwm LIKE qpmk-mkmnr MODIF ID ver.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION & SELECTION SCREEN EVENTS
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI' OR space.
      zihqm_cl004=>validate_screen(
        EXPORTING
          iv_werks = pa_werks
          iv_matnr = pa_matnr
          iv_verwm = pa_verwm
        CHANGING
          ct_erste = so_erste[]
      ).
  ENDCASE.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  " Eksekusi logika utama program menggunakan class
  zihqm_cl004=>execute( ip_werks   = pa_werks
                        ip_matnr   = pa_matnr
                        ip_verwm   = pa_verwm
                        it_charg   = so_charg[]
                        it_erste   = so_erste[]
                        ).
