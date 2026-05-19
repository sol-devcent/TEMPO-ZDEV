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
REPORT zf_gspost NO STANDARD PAGE HEADING
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

* PDF View
INCLUDE pdf_demo_event_receiver.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zf_gsposttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs  LIKE bsis-bukrs MODIF ID buk.
SELECT-OPTIONS so_gsber FOR bsis-gsber MODIF ID gs2.
PARAMETERS pa_gsber  LIKE bsis-gsber MODIF ID gs1.
PARAMETERS pa_ztype  LIKE zfgstype-ztype MODIF ID zty.
*PARAMETERS pa_subty  LIKE zfgstype-zsubtype MODIF ID su1.
SELECT-OPTIONS so_subty FOR zfgstype-zsubtype MODIF ID su2.
PARAMETERS pa_spmon  LIKE zfgsnomor-spmon MODIF ID spm.
SELECT-OPTIONS so_spmon   FOR zfgsnomor-spmon MODIF ID ssp NO-EXTENSION.
PARAMETERS pa_gjahr  LIKE bsis-gjahr MODIF ID gja.
SELECT-OPTIONS so_kunnr  FOR zfgskunnr-kunnr NO INTERVALS NO-EXTENSION MODIF ID kun.
SELECT-OPTIONS so_zgsno  FOR zfgscab-zgsno MODIF ID zgs.
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
PARAMETERS radio6 RADIOBUTTON GROUP rad.
PARAMETERS radio9 RADIOBUTTON GROUP rad.
PARAMETERS radio7 RADIOBUTTON GROUP rad.
PARAMETERS radio8 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 9000.
PARAMETERS pa_ztyp1  LIKE zfgstype-ztype NO-DISPLAY.
PARAMETERS pa_subt1  LIKE zfgstype-zsubtype MODIF ID psu.
PARAMETERS pa_actde  LIKE zfgscab_add-actdesc MODIF ID pac OBLIGATORY.
PARAMETERS pa_kunnr  LIKE zfgskunnr-kunnr MODIF ID pku OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 9000.

SELECTION-SCREEN BEGIN OF SCREEN 9001.
PARAMETERS pa_budat  LIKE bkpf-budat DEFAULT sy-datum OBLIGATORY.
PARAMETERS pa_bldat  LIKE bkpf-bldat DEFAULT sy-datum OBLIGATORY.
PARAMETERS pa_xblnr  LIKE bkpf-xblnr OBLIGATORY MODIF ID gry.
PARAMETERS pa_bktxt  LIKE bkpf-bktxt OBLIGATORY.
PARAMETERS pa_xref2  LIKE bapiacar09-ref_key_2 NO-DISPLAY.  "MODIF ID gry.
PARAMETERS pa_xref3  LIKE bapiacar09-ref_key_3 OBLIGATORY MODIF ID xr3.
PARAMETERS pa_filep  LIKE zfgscab_add-filepusat MODIF ID flp.
SELECTION-SCREEN END OF SCREEN 9001.

SELECTION-SCREEN BEGIN OF SCREEN 9007.
PARAMETERS pa_filps  LIKE zfgscab_add-filepusat MODIF ID fps.
SELECTION-SCREEN END OF SCREEN 9007.

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
    WHEN 'CRET'.
      IF sy-dynnr = '9007'.
        PERFORM f_validate_screen_9007.
      ENDIF.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_budat.
  PERFORM f_modify_xref2 USING gt_out-vbund gt_out-vbundx pa_budat
                         CHANGING pa_xref2.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filep.
  PERFORM f_get_filename USING pa_filep 'PA_FILEP'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_kunnr.
  PERFORM f_get_f4 USING 'PA_KUNNR'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filps.
  IF gv_filepusat IS INITIAL.
    PERFORM f_get_filename USING pa_filps 'PA_FILPS'.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN radio9.
      SUBMIT zf_gscust_tmmt VIA SELECTION-SCREEN AND RETURN.
    WHEN OTHERS.
      PERFORM f_init_data.
      IF gv_subrc IS INITIAL.
        PERFORM f_get_data.
        PERFORM f_process_data.
        PERFORM f_print_data.
        PERFORM f_free_memory.
      ENDIF.
  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_gspostf01.

*------------------common includes for the program---------------------*
