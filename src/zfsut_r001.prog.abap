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
REPORT zfsut_r001 NO STANDARD PAGE HEADING
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
INCLUDE zfsut_r001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs       LIKE bseg-bukrs MODIF ID buk DEFAULT '8070'.
*SELECT-OPTIONS so_gsber   FOR bseg-gsberMODIF ID gsb.
SELECT-OPTIONS so_gsber   FOR bseg-werks MODIF ID gsb.
SELECT-OPTIONS so_hkont   FOR bseg-hkont MODIF ID hko.
PARAMETERS pa_monat       LIKE bsis-monat MODIF ID mon DEFAULT sy-datum+4(2).
PARAMETERS pa_gjahr       LIKE bseg-gjahr MODIF ID gja DEFAULT sy-datum(4).
SELECT-OPTIONS so_lifnr   FOR bseg-lifnr MODIF ID lif.
SELECT-OPTIONS so_matnr   FOR bseg-matnr MODIF ID mat.
SELECTION-SCREEN SKIP 1.
PARAMETER pa_histo AS CHECKBOX.
PARAMETER pa_sum AS CHECKBOX.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER pa_c  AS CHECKBOX.
SELECTION-SCREEN : COMMENT 5(35) text-003 FOR FIELD pa_c.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER pa_e  AS CHECKBOX.
SELECTION-SCREEN : COMMENT 5(45) text-004 FOR FIELD pa_e.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK data1.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA: lv_parva(40).

  so_hkont-low    = '0731110000'.
  so_hkont-high   = '0731110090'.
  so_hkont-sign   = 'I'.
  so_hkont-option = 'BT'.
  APPEND so_hkont.

  CLEAR so_gsber[].
*  SELECT SINGLE parva
*    FROM usr05
*    INTO lv_parva
*    WHERE bname EQ sy-uname AND
*          parid EQ 'GSB'.
  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'WRK'.

  IF sy-subrc EQ 0.
    so_gsber-low  = lv_parva.
    APPEND so_gsber.
  ENDIF.

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
  INCLUDE zfsut_r001f01.

*------------------common includes for the program---------------------*
