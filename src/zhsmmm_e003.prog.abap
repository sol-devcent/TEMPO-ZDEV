*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e003 NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE zhsmmm_e003top.

INCLUDE zhsmmm_e003cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_frgco LIKE t16fc-frgco MODIF ID pfr.
SELECT-OPTIONS so_frggr FOR ekko-frggr MODIF ID sfr DEFAULT '40'.
PARAMETERS  pa_listu LIKE t160o-listu MODIF ID pli DEFAULT 'ANFR' NO-DISPLAY.
SELECT-OPTIONS so_bstyp FOR ekko-bstyp MODIF ID sbs DEFAULT 'A' NO-DISPLAY.
SELECT-OPTIONS so_ekorg FOR ekko-ekorg MODIF ID sek.
SELECT-OPTIONS so_submi FOR ekko-submi MODIF ID ssu.
SELECT-OPTIONS so_ebeln FOR ekko-ebeln MODIF ID seb.
SELECT-OPTIONS so_bsart FOR ekko-bsart MODIF ID sbs.
SELECT-OPTIONS so_ekgrp FOR ekko-ekgrp MODIF ID sek.
SELECT-OPTIONS so_lifnr FOR ekko-lifnr MODIF ID sli.
SELECT-OPTIONS so_reswk FOR ekko-reswk MODIF ID sre.
SELECT-OPTIONS so_bedat FOR ekko-bedat MODIF ID sbe.
SELECT-OPTIONS so_procs FOR ekko-procstat NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 102 AS WINDOW TITLE text-003.
PARAMETERS pa_aedat   LIKE ekko-aedat OBLIGATORY
                                      MODIF ID pae.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_bwbdt   LIKE ekko-bwbdt OBLIGATORY.
PARAMETERS pa_angdt   LIKE ekko-angdt OBLIGATORY.
PARAMETERS pa_kdatb   LIKE ekko-kdatb OBLIGATORY.
PARAMETERS pa_kdate   LIKE ekko-kdate OBLIGATORY.
PARAMETERS pa_bnddt   LIKE ekko-bnddt OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 102.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid          = sy-repid.

  so_procs-sign    = 'E'.
  so_procs-option  = 'EQ'.
  so_procs-low     = '01'.
  APPEND so_procs.
  so_procs-low     = '04'.
  APPEND so_procs.
  so_procs-low     = '08'.
  APPEND so_procs.

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

  CLEAR : so_frggr[].

  so_frggr-low    = '40'.
  so_frggr-sign   = 'I'.
  so_frggr-option = 'EQ'.
  APPEND so_frggr.

  CALL FUNCTION 'ME_REL_CHECK_MANY'
    EXPORTING
      i_frgot = '2'
      i_frgco = pa_frgco
    TABLES
      t_frggr = so_frggr
      t_t16fv = zus.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_frgco.
  CALL FUNCTION 'HELP_VALUES_FRGAB'
    EXPORTING
      i_frgot = '2'
    IMPORTING
      e_frgab = pa_frgco
    EXCEPTIONS
      OTHERS  = 1.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zhsmmm_e003m01.

  INCLUDE zhsmmm_e003f01.
