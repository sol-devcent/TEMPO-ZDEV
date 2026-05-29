*&---------------------------------------------------------------------*
*& Program Name     : ZGDQM_R0001                                      *
*& Module Name      : QM                                               *
*& Author           : Budi Pramono                                     *
*& Functional       : Kishore SV                                       *
*& Create Date      : 12/04/2005                                       *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Reinspection Report                              *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdqm_r0001
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
INCLUDE zgdqmr0001top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: p_werks LIKE koth700-werks MODIF ID pwe,
            p_mtart LIKE koth700-mtart MODIF ID pmt DEFAULT 'ZRM'.
SELECT-OPTIONS: s_matnr FOR mara-matnr MODIF ID sma.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS rad01 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(24) text-002 FOR FIELD rad01.
SELECT-OPTIONS: s_date FOR koth700-datab NO-EXTENSION MODIF ID sd0.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS rad02 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(24) text-003 FOR FIELD rad02.
SELECT-OPTIONS: s_date1 FOR koth700-datab NO-EXTENSION MODIF ID sd1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
*  if not p_werks = '0101' or
*         p_werks = '0102' or
*         p_werks = '0901'.
*  endif.
  IF p_werks IS NOT INITIAL.
    SELECT SINGLE * FROM t001w
                    WHERE werks = p_werks.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'Invalid plant'.
    ENDIF.
  ENDIF.

*-Authorization
  macro_atz_single_werks p_werks c_atz_display.

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
  INCLUDE zgdqmr0001f01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
