*&---------------------------------------------------------------------*
*& Program Name     : ZGDSD_R0004                                      *
*& Module Name      : SD                                               *
*& Author           : Shalahuddin Ahmad                                *
*& Functional       :                                                  *
*& Create Date      : 14/03/2005                                       *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Realisasi Export Obat Jadi                       *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdsd_r0004
               NO STANDARD PAGE HEADING
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
INCLUDE zgdsdr0004top.
*INCLUDE zibm_report_temptop.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
*SELECT-OPTIONS: s_vkorg FOR vbrk-vkorg.
PARAMETERS: p_vkorg LIKE vbrk-vkorg OBLIGATORY.
SELECT-OPTIONS: s_auart FOR vbak-auart,
                s_matnr FOR mara-matnr.
*                s_period FOR sy-datum.
SELECTION-SCREEN END OF BLOCK data.

* Begin subscreen 1
SELECTION-SCREEN BEGIN OF BLOCK peri WITH FRAME TITLE text-011.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(10) text-012.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1
USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-101 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-102 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-103 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-104 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.

PARAMETERS: p_year(4) DEFAULT sy-datum(4) OBLIGATORY.
SELECTION-SCREEN END OF BLOCK peri.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK data1.



*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_vkorg.
  macro_atz_single_vkorg p_vkorg c_atz_display.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdsdr0004f01.
*  INCLUDE zibm_report_tempf01.
*------------------common includes for the program---------------------*
