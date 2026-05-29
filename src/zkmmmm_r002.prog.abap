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
REPORT zkmmmm_r002 NO STANDARD PAGE HEADING
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
INCLUDE zkmmmm_r002top.
DATA: BEGIN OF i_werks OCCURS 0,
        werks LIKE t001w-werks,
      END OF i_werks.

DATA : BEGIN OF gt_marc OCCURS 0,
         werks  TYPE werks_d,
         matnr  TYPE matnr,
         beskz  TYPE beskz.
DATA : END OF gt_marc.



*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS : so_pmnux   FOR s076-pmnux.
SELECT-OPTIONS : so_wenux   FOR s076-wenux OBLIGATORY.
PARAMETERS : pa_spmon   LIKE s076-spmon DEFAULT sy-datum(6) OBLIGATORY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK output WITH FRAME TITLE text-002.
PARAMETERS: butt1 RADIOBUTTON GROUP rb1 USER-COMMAND us1 DEFAULT 'X',
            butt2 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK output.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_get_parameters USING ''
*                           CHANGING pa_value.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*
*at selection-screen on value-request for so_pmnux-low.
*call function 'F4IF_FIELD_VALUE_REQUEST'
*    EXPORTING
*    tabname    = 'S076'
*    fieldname  = 'SO_PMNUX-LOW'
*    DYNPPROG   = sy-cprog
*    DYNPNR     = sy-dynnr
*    DYNPROFIELD = 'SO_PMNUX-LOW'
*    SEARCHHELP  =  'MAT2'.
*
*at selection-screen on value-request for so_pmnux-high.
*call function 'F4IF_FIELD_VALUE_REQUEST'
*    EXPORTING
*    tabname    = 'S076'
*    fieldname  = 'SO_PMNUX-HIGH'
*    DYNPPROG   = sy-cprog
*    DYNPNR     = sy-dynnr
*    DYNPROFIELD = 'SO_PMNUX-HIGH'
*    SEARCHHELP  =  'MAT2'.

* Search help for period
  INCLUDE rmcs0f0m.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_spmon.
  PERFORM monat_f4.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  SELECT werks FROM t001w
  INTO CORRESPONDING FIELDS OF TABLE i_werks
  WHERE werks IN so_wenux.

  LOOP AT i_werks.
    AUTHORITY-CHECK OBJECT 'M_BEST_WRK'
        ID 'ACTVT' FIELD '03'
        ID 'WERKS' FIELD i_werks-werks.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Plant'
       i_werks-werks.
    ENDIF.
  ENDLOOP.

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
  INCLUDE zkmmmm_r002f01.

*------------------common includes for the program---------------------*
