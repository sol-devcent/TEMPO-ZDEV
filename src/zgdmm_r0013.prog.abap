*&---------------------------------------------------------------------*
*& Program Name     : ZGDMM_R0013                                      *
*& Module Name      : MM                                               *
*& Author           :                                                  *
*& Functional       :                                                  *
*& Create Date      :                                                  *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdmm_r0013
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
INCLUDE zgdmmr0013top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: p_werks LIKE t001w-werks OBLIGATORY.
SELECT-OPTIONS:
                s_matnr FOR mara-matnr,
                s_spmon FOR s933-spmon OBLIGATORY NO-EXTENSION,
                s_bwart FOR s933-bwart NO-DISPLAY.
PARAMETERS: p_lgort LIKE s933-lgort DEFAULT '3000' NO-DISPLAY,
            p_mtart LIKE mara-mtart DEFAULT 'ZPHA' NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.

SELECTION-SCREEN END OF BLOCK data1.

PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON p_date.


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
  PERFORM f_reformat_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdmmr0013f01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
