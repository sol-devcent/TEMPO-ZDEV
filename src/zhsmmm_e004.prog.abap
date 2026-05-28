*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e004 NO STANDARD PAGE HEADING.

INCLUDE zabp_frm.

SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-dat.
PARAMETERS : p_tdform    LIKE ssfscreen-fname NO-DISPLAY,
             p_dest      LIKE tsp03-padest NO-DISPLAY,
             p_disp      LIKE ssfctrlop-preview NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blxx.

INCLUDE zabp_smartform.

INCLUDE zhsmmm_e004top.

INCLUDE zhsmmm_e004cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_ekgrp       TYPE t024-ekgrp
                          MODIF ID pek.
PARAMETERS pa_submi       TYPE ekko-submi
                          MODIF ID psu.
SELECT-OPTIONS so_werks   FOR ekpo-werks NO INTERVALS NO-EXTENSION
                          MODIF ID swe.
SELECT-OPTIONS so_matnr   FOR ekpo-matnr NO INTERVALS NO-EXTENSION
                          MODIF ID sma.
PARAMETERS pa_ean11       LIKE mean-ean11 MODIF ID pea.

PARAMETERS pa_mjahr       TYPE mkpf-mjahr DEFAULT sy-datum(4)
                                          NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS so_lfdat   FOR eban-lfdat.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'
                                         MODIF ID rad.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID rad.
SELECTION-SCREEN COMMENT 5(27) text-003 FOR FIELD radio2 MODIF ID rad.
PARAMETERS pa_prgrp       TYPE pgmi-prgrp
                          MODIF ID ppr.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 1001 AS WINDOW TITLE text-005.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(32) text-004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_zalno     TYPE zgdmmt004z-zalno.
SELECTION-SCREEN END OF SCREEN 1001.
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

AT SELECTION-SCREEN ON so_werks.
  AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
   ID 'ACTVT' FIELD '03'
   ID 'WERKS' FIELD so_werks-low.
  IF sy-subrc <> 0.
    MESSAGE e003(zz) WITH
    'You are not authorized with Plant ' so_werks-low.
  ENDIF.

AT SELECTION-SCREEN ON pa_ekgrp.
  AUTHORITY-CHECK OBJECT 'M_BANF_EKG'
   ID 'ACTVT' FIELD '03'
   ID 'EKGRP' FIELD pa_ekgrp.
  IF sy-subrc <> 0.
    MESSAGE e003(zz) WITH
    'You are not authorized with Purch Group ' pa_ekgrp.
  ENDIF.

**&---------------------------------------------------------------------*
**& SELECTION-SCREEN ON VALUE-REQUEST FOR
**&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
*  PERFORM f_f4_filename CHANGING pa_fname.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_prgrp.
  PERFORM f_f4_prgrp CHANGING pa_prgrp.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zalno.
  PERFORM f_f4_zalno CHANGING pa_zalno.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_lock_data USING 'X'.
  IF gv_subrc = 0.
    PERFORM f_get_data.
  ENDIF.
  IF gv_subrc = 0.
    PERFORM f_create_dyn_int_table.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
    WHEN 2.
      MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
    WHEN 3.
      MESSAGE s000(zab) WITH 'Collective No. already approved' DISPLAY LIKE 'E'.
    WHEN 4.
      MESSAGE s000(zab) WITH 'Allocation No. not found' DISPLAY LIKE 'E'.
    WHEN 5.
      MESSAGE s000(zab) WITH 'Cannot create new Allocation No.' DISPLAY LIKE 'E'.
    WHEN 6.
      MESSAGE s000(zab) WITH 'Transaction Lock by' gv_guname DISPLAY LIKE 'E'.
      CLEAR gv_subrc.
    WHEN 7.
      MESSAGE s000(zab) WITH 'Vendor' gv_lifnr 'without PIR' DISPLAY LIKE 'E'.
      CLEAR : gv_subrc, gv_lifnr.
  ENDCASE.

  INCLUDE zhsmmm_e004m01.

  INCLUDE zhsmmm_e004f01.

  INCLUDE zhsmmm_e004f02.
