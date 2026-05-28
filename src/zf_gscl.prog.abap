*&---------------------------------------------------------------------*
*& Report  ZF_GSCL
*&
*&---------------------------------------------------------------------*
*& Upload CL number
*&
*&---------------------------------------------------------------------*

REPORT  zf_gscl NO STANDARD PAGE HEADING.

INCLUDE zf_gscl_top.

INCLUDE zf_gscl_cl1.

*INCLUDE zabp_bdc.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
* coding here for your selection data
SELECT-OPTIONS: s_kdgrp FOR zclnumber-kdgrp MODIF ID kun,
                s_matkl FOR zclnumber-matkl MODIF ID mkl.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-021 FOR FIELD p_datab
                                        MODIF ID per.
PARAMETERS p_datab TYPE datab OBLIGATORY MODIF ID per.
SELECTION-SCREEN COMMENT 52(5) TEXT-022 FOR FIELD p_datbi
                                         MODIF ID per.
PARAMETERS p_datbi TYPE datbi OBLIGATORY MODIF ID per.
SELECTION-SCREEN END OF LINE.

*SELECTION-SCREEN SKIP.
PARAMETERS: pa_fname LIKE rlgrap-filename MODIF ID fln.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-011 MODIF ID hid.
SELECTION-SCREEN COMMENT 27(5) TEXT-012 FOR FIELD p_rbegin
                                        MODIF ID hid.
PARAMETERS p_rbegin TYPE i DEFAULT 4 MODIF ID hid.
SELECTION-SCREEN COMMENT 60(5) TEXT-013 FOR FIELD p_rend
                                        MODIF ID hid.
PARAMETERS p_rend TYPE i DEFAULT 60000 MODIF ID hid.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-014 MODIF ID hid.
SELECTION-SCREEN COMMENT 27(5) TEXT-012 FOR FIELD p_cbegin
                                        MODIF ID hid.
PARAMETERS p_cbegin TYPE i DEFAULT 1 MODIF ID hid.
SELECTION-SCREEN COMMENT 60(5) TEXT-013 FOR FIELD p_cend
                                        MODIF ID hid.
PARAMETERS p_cend TYPE i DEFAULT 6 MODIF ID hid.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK proses WITH FRAME TITLE TEXT-002.
PARAMETERS: p_upld RADIOBUTTON GROUP rad1 DEFAULT 'X' USER-COMMAND usr1,
            p_chng RADIOBUTTON GROUP rad1,
            p_down RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF BLOCK proses.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE TEXT-003.
PARAMETERS: pa_vari  LIKE disvariant-variant MODIF ID hid.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_datab = |{ sy-datum(6) }01|.
  p_datbi = sy-datum.

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

**&---------------------------------------------------------------------*
**& SELECTION-SCREEN ON VALUE-REQUEST FOR
**&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
  PERFORM f_f4_filename CHANGING pa_fname.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  CASE 'X'.
    WHEN p_upld OR p_chng.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_create_dyn_int_table.
      PERFORM f_print_data.
    WHEN p_down.
      PERFORM f_get_data_download.
  ENDCASE.

  INCLUDE zf_gscl_m01.

  INCLUDE zf_gscl_f01.
