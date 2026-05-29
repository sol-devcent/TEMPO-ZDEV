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
REPORT zm_oos_product NO STANDARD PAGE HEADING
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
INCLUDE zm_oos_producttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs  LIKE ekko-bukrs MODIF ID buk.
PARAMETERS pa_ekorg  LIKE ekko-ekorg MODIF ID eko.
SELECT-OPTIONS so_lifnr FOR ekko-lifnr.
SELECT-OPTIONS so_bsart FOR ekko-bsart MODIF ID bsa NO INTERVALS.
SELECT-OPTIONS so_bedat FOR ekko-bedat DEFAULT sy-datum.
SELECT-OPTIONS so_matnr FOR ekpo-matnr.
SELECT-OPTIONS so_werks FOR ekpo-werks.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 5(10) text-003 FOR FIELD radio1.
SELECTION-SCREEN : COMMENT 17(16) text-004 FOR FIELD radio1 MODIF ID cal.
PARAMETERS pa_calid   LIKE tkevs-fcalid MODIF ID cal DEFAULT 'T1'.
SELECTION-SCREEN END OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF BLOCK level WITH FRAME TITLE text-005.
PARAMETERS rb_det RADIOBUTTON GROUP lvl DEFAULT 'X' USER-COMMAND lvl MODIF ID det.
PARAMETERS rb_sum RADIOBUTTON GROUP lvl MODIF ID sum.
SELECTION-SCREEN END OF BLOCK level.

SELECTION-SCREEN BEGIN OF BLOCK summary WITH FRAME TITLE text-006.
PARAMETERS rb_brc  RADIOBUTTON GROUP sum DEFAULT 'X' USER-COMMAND sum MODIF ID brc.
PARAMETERS rb_brcp RADIOBUTTON GROUP sum MODIF ID brp.
PARAMETERS rb_prc  RADIOBUTTON GROUP sum MODIF ID prc.
SELECTION-SCREEN END OF BLOCK summary.

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
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_oos_productf01.

*------------------common includes for the program---------------------*
