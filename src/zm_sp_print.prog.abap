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
REPORT zm_sp_print NO STANDARD PAGE HEADING
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
INCLUDE zm_sp_printtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS : pa_vkorg   LIKE likp-vkorg MODIF ID vko.
PARAMETERS : pa_vstel   LIKE likp-vstel MODIF ID vst.
PARAMETERS : pa_kunnr   LIKE likp-kunnr MODIF ID kun.
SELECT-OPTIONS : so_vbeln   FOR likp-vbeln.
SELECT-OPTIONS : so_wadat   FOR likp-wadat_ist MODIF ID wad
                                               NO-EXTENSION.
SELECT-OPTIONS : so_erdat   FOR likp-erdat MODIF ID erd.
SELECT-OPTIONS : so_tpgrp   FOR likp-tpgrp MODIF ID abs.
SELECTION-SCREEN SKIP 1.
PARAMETER : pa_pdest  LIKE pri_params-pdest MODIF ID pde.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK process WITH FRAME TITLE text-002.
PARAMETERS : radio1 RADIOBUTTON GROUP grp2
                    USER-COMMAND rad
                    DEFAULT 'X' MODIF ID ra1.
PARAMETERS : radio2 RADIOBUTTON GROUP grp2 MODIF ID ra2.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2 MODIF ID ra3.
SELECTION-SCREEN END OF BLOCK process.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  SELECT SINGLE spld
    FROM usr01
    INTO pa_pdest
    WHERE bname = sy-uname.

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
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_sp_printf01.

*------------------common includes for the program---------------------*
