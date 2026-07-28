*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
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
REPORT zm_lead_time NO STANDARD PAGE HEADING
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
INCLUDE zm_lead_timetop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  so_bukrs  FOR ekko-bukrs OBLIGATORY.
PARAMETERS:
*  pa_bukrs  LIKE ekko-bukrs OBLIGATORY,
  pa_ekorg  LIKE ekko-ekorg OBLIGATORY.
SELECT-OPTIONS:
  so_ekgrp  FOR ekko-ekgrp OBLIGATORY,
  so_werks  FOR ekpo-werks,
  so_bsart  FOR ekko-bsart,
  so_matnr  FOR ekpo-matnr,
  so_ebeln  FOR ekko-ebeln,
  so_bedat  FOR ekko-bedat,
  so_budat  FOR ekbe-budat,
  so_lifnr  FOR ekko-lifnr,
  so_mtart  FOR ekpo-mtart,
  so_matkl  FOR ekpo-matkl,
  so_loekz  FOR ekpo-loekz NO INTERVALS NO-EXTENSION.
PARAMETERS:
  pa_inter  TYPE char3 OBLIGATORY DEFAULT 5 MODIF ID int.
SELECT-OPTIONS:
  so_ebelp  FOR ekbe-ebelp NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 200 AS WINDOW TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(27) text-004.
SELECTION-SCREEN : COMMENT 29(3) text-010.
PARAMETERS:
pa_int01  TYPE char3 OBLIGATORY MODIF ID in1 DEFAULT 0.
SELECTION-SCREEN : COMMENT 38(8) text-009.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(27) text-006 MODIF ID in2.
SELECTION-SCREEN : COMMENT 29(3) text-011 MODIF ID ge1.
PARAMETERS:
pa_int02  TYPE char3 OBLIGATORY MODIF ID in2 DEFAULT 1.
SELECTION-SCREEN : COMMENT 38(8) text-009 MODIF ID in2.
SELECTION-SCREEN : COMMENT 52(5) text-005 FOR FIELD pa_int03 MODIF ID in3.
PARAMETERS:
pa_int03  TYPE char3 OBLIGATORY MODIF ID in3 DEFAULT 7.
SELECTION-SCREEN : COMMENT 63(8) text-009 MODIF ID in3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(27) text-007 MODIF ID in4.
SELECTION-SCREEN : COMMENT 29(3) text-011 MODIF ID ge2.
PARAMETERS:
pa_int04  TYPE char3 OBLIGATORY MODIF ID in4 DEFAULT 8.
SELECTION-SCREEN : COMMENT 38(8) text-009 MODIF ID in4.
SELECTION-SCREEN : COMMENT 52(5) text-005 FOR FIELD pa_int05 MODIF ID in5.
PARAMETERS:
pa_int05  TYPE char3 OBLIGATORY MODIF ID in5 DEFAULT 14.
SELECTION-SCREEN : COMMENT 63(8) text-009 MODIF ID in5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(27) text-008 MODIF ID in6.
SELECTION-SCREEN : COMMENT 29(3) text-011 MODIF ID ge3.
PARAMETERS:
pa_int06  TYPE char3 OBLIGATORY MODIF ID in6 DEFAULT 15.
SELECTION-SCREEN : COMMENT 38(8) text-009 MODIF ID in6.
SELECTION-SCREEN : COMMENT 52(5) text-005 FOR FIELD pa_int07 MODIF ID in7.
PARAMETERS:
pa_int07  TYPE char3 OBLIGATORY MODIF ID in7 DEFAULT 21.
SELECTION-SCREEN : COMMENT 63(8) text-009 MODIF ID in7.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(27) text-012 MODIF ID in8.
SELECTION-SCREEN : COMMENT 29(3) text-011 MODIF ID ge4.
PARAMETERS:
pa_int08  TYPE char3 OBLIGATORY MODIF ID in8 DEFAULT 22.
SELECTION-SCREEN : COMMENT 38(8) text-009 MODIF ID in8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 200.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  LOOP AT so_werks.
    AUTHORITY-CHECK OBJECT 'M_BEST_WRK'
             ID 'ACTVT' FIELD '03'
             ID 'WERKS' FIELD so_werks-low.
    IF sy-subrc = 4.
      MESSAGE e000(zab) WITH 'No authorization for Plant' so_werks-low.
    ELSEIF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'Internal problem in authorization check'.
    ENDIF.
  ENDLOOP.

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
  CALL SELECTION-SCREEN 200 STARTING AT 10 10.
  IF sy-subrc EQ 0.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_interval.
    PERFORM f_free_memory.
    PERFORM f_print_data.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_lead_timef01.

*------------------common includes for the program---------------------*
