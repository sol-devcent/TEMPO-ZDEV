*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : MM                                               *
*& Author           : Budi.P                                           *
*& Functional       :                                                  *
*& Create Date      : 12/10/2013 (dd/mm/yyyy)                          *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zmmgh_principal_sl NO STANDARD PAGE HEADING
                          LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zmmgh_principal_sltop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:     p_bukrs LIKE ekko-bukrs OBLIGATORY.
SELECT-OPTIONS: s_ekorg FOR ekko-ekorg OBLIGATORY,
                s_bedat FOR ekko-bedat OBLIGATORY MODIF ID bed,
                s_ekgrp FOR ekko-ekgrp,   "OBLIGATORY,
                s_lifnr FOR ekko-lifnr,   "OBLIGATORY,
                s_bsart FOR ekko-bsart,
                s_matnr FOR ekpo-matnr,
                s_extwg FOR mara-extwg MODIF ID sex,
                s_werks FOR ekpo-werks.
SELECTION-SCREEN SKIP.
PARAMETERS:     p_factid LIKE tkevs-fcalid OBLIGATORY DEFAULT 'T1'.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS so_dat01  FOR bkpf-monat NO-EXTENSION MODIF ID sd1.
SELECT-OPTIONS so_dat02  FOR bkpf-monat NO-EXTENSION MODIF ID sd2.
SELECT-OPTIONS so_dat03  FOR bkpf-monat NO-EXTENSION MODIF ID sd3.
SELECT-OPTIONS so_dat04  FOR bkpf-monat NO-EXTENSION MODIF ID sd4.
SELECTION-SCREEN END OF BLOCK data.
PARAMETERS: pa_grid AS CHECKBOX MODIF ID grd.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA : lv_datum   TYPE sy-datum.

  CONCATENATE sy-datum(6) '01' INTO lv_datum.
  so_dat01-low  = lv_datum+6(2).
  lv_datum = lv_datum + 6.
  so_dat01-high  = lv_datum+6(2).
  APPEND so_dat01.

  lv_datum  = lv_datum + 1.
  so_dat02-low  = lv_datum+6(2).
  lv_datum = lv_datum + 7.
  so_dat02-high  = lv_datum+6(2).
  APPEND so_dat02.

  lv_datum  = lv_datum + 1.
  so_dat03-low  = lv_datum+6(2).
  lv_datum = lv_datum + 7.
  so_dat03-high  = lv_datum+6(2).
  APPEND so_dat03.

  lv_datum  = lv_datum + 1.
  so_dat04-low  = lv_datum+6(2).
  so_dat04-high = '31'.
  APPEND so_dat04.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'GRD'.
      screen-active  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

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
  PERFORM f_factory_commitment_weekly USING '' ''
                                      CHANGING gs_out.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zmmgh_principal_slf01.

*------------------common includes for the program---------------------*
