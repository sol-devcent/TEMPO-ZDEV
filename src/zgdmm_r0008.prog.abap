*&---------------------------------------------------------------------*
*& Program Name     : ZGDMM_R0008                                      *
*& Module Name      : MM                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report                                           *
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
REPORT zgdmm_r0008 NO STANDARD PAGE HEADING
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
INCLUDE zgdmmr0008top.
*------------------common TOP includes for the program----------------*


*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-011.
PARAMETER: p_werks LIKE mseg-werks OBLIGATORY,
           p_matnr LIKE mara-matnr OBLIGATORY,
*           p_lgort LIKE mard-lgort DEFAULT '1000' NO-DISPLAY,
*           p_period TYPE abper_rf DEFAULT sy-datum(6) OBLIGATORY.
           p_period LIKE s933-spmon DEFAULT sy-datum(6) OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETER: p_nom(100) DEFAULT 'Kep-078/BC.4/2005',
           p_tgl LIKE sy-datum.
SELECTION-SCREEN END OF BLOCK data1.

*SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK sign WITH FRAME TITLE text-999.
PARAMETERS: p_sign1(20),
            p_sign2(20).
*            p_docno(20),
*            p_qty(20),
*            p_tgl LIKE sy-datum DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK sign.
*SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW
                                     TITLE text-031.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  (20) text-032.
SELECTION-SCREEN COMMENT 28(8) text-033.
SELECTION-SCREEN COMMENT 46(5) text-034.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_docno1(20),
            p_qty1(15),
*            p_qty1 LIKE s933-menge,
            p_tgl1 LIKE sy-datum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_docno2(20),
            p_qty2(15),
*            p_qty2 LIKE s933-menge,
            p_tgl2 LIKE sy-datum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_docno3(20),
            p_qty3(15),
*            p_qty3 LIKE s933-menge,
            p_tgl3 LIKE sy-datum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_docno4(20),
            p_qty4(15),
*            p_qty4 LIKE s933-menge,
            p_tgl4 LIKE sy-datum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_docno5(20),
            p_qty5(15),
*            p_qty5 LIKE s933-menge,
            p_tgl5 LIKE sy-datum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 500.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
*-Authorization check on Plant
  macro_atz_single_werks p_werks c_atz_display.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*

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

  CALL SELECTION-SCREEN 500 STARTING AT 25 5.
  CHECK sy-subrc = 0.

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
  INCLUDE zgdmmr0008f01.
  INCLUDE zgdmmr0008f011.
*------------------common includes for the program---------------------*
