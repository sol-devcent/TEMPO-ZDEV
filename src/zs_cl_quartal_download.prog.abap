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
REPORT zs_cl_quartal_download NO STANDARD PAGE HEADING
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
INCLUDE zs_cl_quartal_downloadtop.

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
SELECT-OPTIONS: so_vkbur FOR s603-vkbur OBLIGATORY, "MEMORY ID vkb,
*                so_spmon FOR s603-spmon,
                so_kdgrp FOR knvv-kdgrp,
                so_kvgr3 FOR knvv-kvgr3,
                so_knkli FOR knkk-knkli.
SELECTION-SCREEN SKIP.
PARAMETERS: work_di1 LIKE rlgrap-filename DEFAULT 'C:\CLSEM\'.
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
*AT SELECTION-SCREEN ON so_vkbur.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR work_di1.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'C:\CLSEM\'
*      def_path         = 'C:\    .xls'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = text-011
    IMPORTING
      filename         = work_di1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_download.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_cl_quartal_downloadf01.

*------------------common includes for the program---------------------*
