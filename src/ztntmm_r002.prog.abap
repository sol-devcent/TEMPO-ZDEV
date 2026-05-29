*&---------------------------------------------------------------------*
*& Program Name     : ZTNTMM_R002                                      *
*& Module Name      : MM (FI,CO,MM,SD,PM,QM,PP)                        *
*& Author           : Budi                                             *
*& Functional       : IRG                                              *
*& Create Date      : 28.02.2017                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Kartu Stock                                      *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT ztntmm_r002 NO STANDARD PAGE HEADING
                   LINE-SIZE 214.
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
INCLUDE ztntmm_r002top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS    : p_matnr LIKE mardh-matnr OBLIGATORY,
                p_werks LIKE mardh-werks OBLIGATORY,
                p_lgort LIKE mardh-lgort NO-DISPLAY DEFAULT '1000'.
SELECT-OPTIONS: s_budat FOR mkpf-budat,
                s_bwart FOR mseg-bwart NO INTERVALS MODIF ID gry.
SELECTION-SCREEN SKIP.
PARAMETERS:     p_max   TYPE sytabix NO-DISPLAY DEFAULT '100'.
SELECTION-SCREEN END OF BLOCK data.

PARAMETERS: pa_grid AS CHECKBOX MODIF ID nds.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_period.
  PERFORM f_init_bwart.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON s_budat.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GRY'.
      screen-input = 0.
    ENDIF.
    IF screen-group1 = 'NDS'.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

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

*----------------------------------------------------------------------*
* TOP-OF-PAGE.
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  PERFORM f_top_of_page.
  PERFORM f_sub_header.
  PERFORM f_hdr_uline.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE ztntmm_r002f01.

*------------------common includes for the program---------------------*
