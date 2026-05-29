*&---------------------------------------------------------------------*
*& Program Name     : ZTSPMM_R001                                      *
*& Module Name      : MM (FI,CO,MM,SD,PM,QM,PP)                        *
*& Author           : Budi                                             *
*& Functional       : Guritno                                          *
*& Create Date      : 04.01.2019                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Laporan BPOM dan KEMENKES                        *
*&                    LAPORAN REALISASI PRODUKSI DAN DISTRIBUSI        *
*&                    OBAT JADI                                        *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zmr_bpom_kemenkes NO STANDARD PAGE HEADING
                         LINE-SIZE 520.                     "490.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
*INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* common Excel Output
INCLUDE zmm_ewasc01.

* other common functions
*INCLUDE zabp_frm.

* ALV common functions
*INCLUDE zabp_alv_common.

* BDC Include
*INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zmr_bpom_kemenkestop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS    : p_bukrs LIKE mseg-bukrs OBLIGATORY DEFAULT '8020',
                p_werks LIKE mardh-werks OBLIGATORY. "DEFAULT '0101'.

SELECT-OPTIONS: s_lgort FOR mardh-lgort.
SELECT-OPTIONS: s_matnr FOR mseg-matnr. "OBLIGATORY. "NO INTERVALS.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-010 FOR FIELD p_gjahr.
PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY DEFAULT sy-datum(4).
SELECTION-SCREEN COMMENT 41(7) text-011 FOR FIELD p_quart.
PARAMETERS: p_quart TYPE alquart.
SELECTION-SCREEN COMMENT 53(30) p_month.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.

SELECT-OPTIONS: s_budat FOR mkpf-budat MODIF ID gry,
                s_bwart FOR mseg-bwart NO INTERVALS MODIF ID gry.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-003.
PARAMETERS: p_bpom RADIOBUTTON GROUP grp1 USER-COMMAND usr,
            p_depkes RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data1.

SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE text-002.
PARAMETERS    : p_sign TYPE char30 MEMORY ID sig MODIF ID nds,
                p_sik  TYPE char30 MEMORY ID sik MODIF ID nds.
SELECTION-SCREEN END OF BLOCK data2.

PARAMETERS: pa_grid AS CHECKBOX MODIF ID nds.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_bwart.
  PERFORM f_init_quarter USING '1'.
  PERFORM f_init_period.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_quart.
  PERFORM f_init_quarter USING '2'.
  PERFORM f_init_period.

AT SELECTION-SCREEN ON p_gjahr.
  PERFORM f_init_quarter USING '2'.
  PERFORM f_init_period.

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
*  PERFORM f_top_of_page.
*  PERFORM f_sub_header.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zmr_bpom_kemenkesf01.

*------------------common includes for the program---------------------*
