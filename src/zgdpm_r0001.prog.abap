*&---------------------------------------------------------------------*
*& Program Name     : ZGDPM_R0001                                      *
*& Module Name      : PM                                               *
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
REPORT zgdpm_r0001
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
INCLUDE zgdpmr0001top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.

PARAMETERS: p_werks LIKE viaufks-iwerk OBLIGATORY.
SELECT-OPTIONS:  s_auart FOR viaufks-auart,
                 s_tplnr FOR viaufks-tplnr,
                 s_mtart FOR mara-mtart,
                 s_plnbez FOR viaufks-plnbez,
                 s_gstrp FOR viaufks-gstrp OBLIGATORY.



*SELECT-OPTIONS: s_werks FOR pbim-werks,
*                s_matnr FOR mara-matnr.
*
*PARAMETERS: p_date LIKE sy-datum OBLIGATORY.
*
SELECTION-SCREEN END OF BLOCK data.
*
*
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
*
*PARAMETERS: p_chk1 AS CHECKBOX DEFAULT 'X',
*            p_chk2 AS CHECKBOX DEFAULT 'X',
*            p_chk3 AS CHECKBOX DEFAULT 'X',
*            p_chk4 AS CHECKBOX DEFAULT 'X',
*            p_chk5 AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK data1.

PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant



*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
*-Authorization
  macro_atz_single_werks p_werks c_atz_display.

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
  INCLUDE zgdpmr0001f01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
