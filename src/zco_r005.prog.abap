*&---------------------------------------------------------------------*
*& Report  ZCORETAX_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_r005 NO STANDARD PAGE HEADING.
"INCLUDE zsfa_interface_incl.
INCLUDE ZCO_R005TOP.
*INCLUDE zdgfi_r029top.
*INCLUDE zcoretax_e007top.
*INCLUDE zcoretax_e006top.

INCLUDE ZCO_R005CL1.
*INCLUDE zdgfi_r029cl1.
*INCLUDE zcoretax_e007cl1.
*INCLUDE zcoretax_e006cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS p_bukrs TYPE ce18010-bukrs MODIF ID dpn DEFAULT '8180' OBLIGATORY.
*PARAMETERS p_gsber TYPE ce18010-gsber MODIF ID dpn DEFAULT '1800' OBLIGATORY.
*PARAMETERS p_perio TYPE ce18010-perio OBLIGATORY. " DEFAULT sy-datum(6).
PARAMETERS p_gjahr TYPE ce18010-gjahr DEFAULT sy-datum(4).
SELECT-OPTIONS s_perio FOR ce18010-perio NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS s_wwsec FOR ce18010-wwsec MODIF ID ggn.
SELECT-OPTIONS s_wwtrz FOR ce18010-wwtrz MODIF ID ggn.
SELECTION-SCREEN END OF BLOCK data.
SELECTION-SCREEN SKIP 1.


SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE TEXT-005.
PARAMETERS pa_vari  TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.
*  CONCATENATE  sy-datum(4) '0' sy-datum+4(2) INTO p_perio.
  PERFORM f_init_perio.


*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with company code '
     p_bukrs.
  ENDIF.

AT SELECTION-SCREEN ON s_perio.
  DATA(lv_yearl) = VALUE #( s_perio[ 1 ]-low(4) OPTIONAL ).
  DATA(lv_yearh) = VALUE #( s_perio[ 1 ]-high(4) OPTIONAL ).
  IF lv_yearl IS NOT INITIAL AND lv_yearl NE p_gjahr.
    MESSAGE e002(zz) WITH 'Period NE ' p_gjahr.
  ENDIF.
  IF lv_yearh IS NOT INITIAL AND lv_yearh NE p_gjahr.
    MESSAGE e002(zz) WITH 'Period NE ' p_gjahr.
  ENDIF.


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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_alv_variant_f4 CHANGING pa_vari.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  IF gt_out[] IS INITIAL.
    WRITE: / 'No data'.
  ELSE.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ENDIF.


INCLUDE ZCO_R005M01.
*  INCLUDE zdgfi_r029m01.
*  INCLUDE zcoretax_e007m01.

INCLUDE ZCO_R005F01.
*  INCLUDE zdgfi_r029f01.
*  INCLUDE zcoretax_e007f01.
