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
REPORT zqm_qe51n NO STANDARD PAGE HEADING
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
INCLUDE zqm_qe51ntop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS : pa_werks   TYPE werks_d MODIF ID wer.
PARAMETERS : pa_matnr   TYPE matnr MODIF ID mat.
SELECT-OPTIONS : so_charg   FOR qals-charg.
SELECT-OPTIONS : so_erste   FOR qasr-erstelldat MODIF ID ers NO-EXTENSION.
SELECTION-SCREEN SKIP 1.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS : ra_kurzt RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'
*                      MODIF ID kur.
*SELECTION-SCREEN: COMMENT 4(24) text-002 FOR FIELD ra_kurzt
*                  MODIF ID kur.
*SELECTION-SCREEN: POSITION 33.
*PARAMETERS : pa_kurzt   TYPE qmkkurztxt MODIF ID kur.
*SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS : ra_verwm RADIOBUTTON GROUP rad
*                      MODIF ID ver.
SELECTION-SCREEN: COMMENT 1(32) text-003 FOR FIELD pa_verwm
                  MODIF ID ver.
SELECTION-SCREEN: POSITION 33.
PARAMETERS : pa_verwm   LIKE qpmk-mkmnr MODIF ID ver.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_get_parameters USING ''
*                           CHANGING pa_value.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

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
  PERFORM f_crt_dyn_int_table.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zqm_qe51nf01.

*------------------common includes for the program---------------------*
