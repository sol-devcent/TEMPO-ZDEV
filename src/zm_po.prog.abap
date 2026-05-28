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
REPORT zm_po NO STANDARD PAGE HEADING
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
INCLUDE zm_potop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_lgort LIKE ekpo-lgort DEFAULT '2004' MODIF ID lgo.
PARAMETERS pa_reslo LIKE ekpo-reslo DEFAULT '3002' MODIF ID res.
PARAMETERS pa_bukrs LIKE ekko-bukrs MODIF ID buk.
PARAMETERS pa_ekorg LIKE ekko-ekorg MODIF ID eko.
PARAMETERS pa_bsart LIKE ekko-bsart MODIF ID bsa DEFAULT 'ZB'." OBLIGATORY.
SELECT-OPTIONS so_werks FOR ekpo-werks MODIF ID wer.
SELECT-OPTIONS so_ebeln FOR ekko-ebeln MODIF ID ebe.
SELECT-OPTIONS so_bedat FOR ekko-bedat MODIF ID bed NO-EXTENSION.
SELECT-OPTIONS so_pon1 FOR ekko-ebeln MODIF ID po1 NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS so_pon2 FOR ekko-ebeln MODIF ID po2.
SELECT-OPTIONS so_vstel FOR vetvg-vstel MODIF ID svs.
SELECT-OPTIONS so_eindt FOR eket-eindt MODIF ID sei.
"PARAMETERS Pa_bsart type T161-BSART DEFAULT 'ZB' OBLIGATORY modif id eko.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_displ  AS CHECKBOX MODIF ID chk.
PARAMETERS pa_delco  AS CHECKBOX MODIF ID pde.
PARAMETERS pa_reqty  AS CHECKBOX MODIF ID req.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP rad.
PARAMETERS radio3 RADIOBUTTON GROUP rad.
PARAMETERS radio4 RADIOBUTTON GROUP rad.
PARAMETERS radio5 RADIOBUTTON GROUP rad.
PARAMETERS radio6 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
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

  IF radio3 IS NOT INITIAL.
    IF pa_displ IS NOT INITIAL.
      PERFORM f_background_process.
    ELSE.
      PERFORM f_print_data.
    ENDIF.
  ELSE.
    PERFORM f_print_data.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_pof01.

*------------------common includes for the program---------------------*
