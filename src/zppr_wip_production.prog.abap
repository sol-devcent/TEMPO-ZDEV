*&---------------------------------------------------------------------*
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : Budi                                             *
*& Functional       : RMA                                              *
*& Create Date      : 01/13/2015 (MDY)                                 *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : ECC6                                             *
*& Description      : WIP Production Report                            *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zppr_wip_production NO STANDARD PAGE HEADING
                           LINE-SIZE 180.
*                          ZFU.                 "Message class for Finish Unit
*                          ZSP.                 "Spare Parts
*                          ZPE.                 "Production and Engineering
*                          ZFA.                 "Finance
*                          ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
*INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
*INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
*INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zppr_wip_productiontop.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS    : p_spmon TYPE spmon,
                p_werks TYPE werks_d.
SELECT-OPTIONS: s_matnr FOR afpo-matnr.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE text-002.
PARAMETERS    : r_prev RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND usr,
                r_curr RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data2.

PARAMETERS: p_vari  LIKE disvariant-variant NO-DISPLAY. " ALV Variant


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_spmon.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
  PERFORM f_validate_werks.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GRY'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

    PERFORM f_init_spmon.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
*  PERFORM f_f4_for_variant_alv USING p_vari.
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

TOP-OF-PAGE.
  PERFORM f_top_of_page.
  PERFORM f_sub_header.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zppr_wip_productionf01.
*------------------common includes for the program---------------------*
