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
REPORT zs_cl_quartal_update NO STANDARD PAGE HEADING
                             LINE-SIZE 255
                             LINE-COUNT 60.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                  "Spare Parts
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
INCLUDE zs_cl_quartal_updatetop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_kkber FOR knkk-kkber OBLIGATORY NO INTERVALS NO-EXTENSION.
PARAMETERS    : pa_gjahr LIKE zscl_sm-gjahr OBLIGATORY DEFAULT sy-datum(4),
                pa_zsmst LIKE zscl_sm-zsmst OBLIGATORY,
                pa_vkorg LIKE vbak-vkorg OBLIGATORY.
*                pa_vtweg LIKE knvv-vtweg DEFAULT '10' NO-DISPLAY,
*                pa_spart LIKE knvv-spart DEFAULT '00' NO-DISPLAY.
SELECT-OPTIONS: so_vkbur FOR s603-vkbur OBLIGATORY,
*                so_spmon FOR s603-spmon,
                so_kdgrp FOR knvv-kdgrp,
                so_kvgr3 FOR knvv-kvgr3,
                so_knkli FOR knkk-knkli.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: p_entry AS CHECKBOX DEFAULT 'X',
            p_downl AS CHECKBOX DEFAULT 'X',
            p_uplod AS CHECKBOX DEFAULT 'X',
            p_usula AS CHECKBOX DEFAULT 'X',
            p_relec AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK data1.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_screen.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON so_vkbur.
*  macro_atz_single_vkbur so_vkbur c_atz_display.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON so_spmon.

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
  INCLUDE zs_cl_quartal_updatef01.

*------------------common includes for the program---------------------*
