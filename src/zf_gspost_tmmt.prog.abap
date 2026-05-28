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
REPORT zf_gspost_tmmt NO STANDARD PAGE HEADING
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
INCLUDE zf_gspost_tmmttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs  LIKE bsis-bukrs MODIF ID buk.
PARAMETERS pa_ztype  LIKE zfgstype-ztype MODIF ID zty.
PARAMETERS pa_subty  LIKE zfgstype-zsubtype MODIF ID su2.
SELECT-OPTIONS so_buda1  FOR zfgsdntmmt-budat MODIF ID bu1.
SELECT-OPTIONS so_buda2  FOR zfgsdntmmt-budat MODIF ID bu2.
SELECT-OPTIONS so_zgsno  FOR zfgscab-zgsno MODIF ID zgs.
SELECT-OPTIONS so_nodn   FOR zfgsdntmmt-nomordn MODIF ID ndn.
SELECT-OPTIONS so_belnr  FOR bkpf-belnr MODIF ID bel.
PARAMETERS pa_gjahr  LIKE bkpf-gjahr MODIF ID gja.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_datum LIKE sy-datum OBLIGATORY DEFAULT sy-datum MODIF ID dat.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_prev AS CHECKBOX MODIF ID pre.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio4 RADIOBUTTON GROUP rad.
PARAMETERS radio2 RADIOBUTTON GROUP rad.
PARAMETERS radio3 RADIOBUTTON GROUP rad.
PARAMETERS radio5 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 9000.
PARAMETERS pa_ztyp1  LIKE zfgstype-ztype NO-DISPLAY.
PARAMETERS pa_subt1  LIKE zfgstype-zsubtype.
SELECTION-SCREEN END OF SCREEN 9000.

SELECTION-SCREEN BEGIN OF SCREEN 9001.
PARAMETERS pa_budat  LIKE bkpf-budat DEFAULT pa_datum OBLIGATORY.
PARAMETERS pa_bktxt  LIKE bkpf-bktxt OBLIGATORY.
PARAMETERS pa_xblnr  LIKE bkpf-xblnr OBLIGATORY.
PARAMETERS pa_xref2  LIKE bapiacar09-ref_key_2.
PARAMETERS pa_xref3  LIKE bapiacar09-ref_key_3 OBLIGATORY.
PARAMETERS pa_nopaf  TYPE znopaaf.
PARAMETERS pa_maktx  TYPE zmaktx1.
SELECTION-SCREEN END OF SCREEN 9001.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

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

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_budat.
  PERFORM f_modify_xref2 USING pa_bukrs pa_budat
                         CHANGING pa_xref2.

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
  INCLUDE zf_gspost_tmmtf01.

*------------------common includes for the program---------------------*
