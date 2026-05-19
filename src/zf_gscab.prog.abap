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
REPORT zf_gscab NO STANDARD PAGE HEADING
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
INCLUDE zf_gscabtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs  LIKE bsis-bukrs MODIF ID buk.
PARAMETERS pa_gsber  LIKE bsis-gsber MODIF ID gsb.
PARAMETERS pa_ztype  LIKE zfgstype-ztype MODIF ID zty.
PARAMETERS pa_subty  LIKE zfgstype-zsubtype MODIF ID su1.
SELECT-OPTIONS so_subty  FOR zfgstype-zsubtype MODIF ID su2.
PARAMETERS pa_spmon  LIKE zfgsnomor-spmon MODIF ID spm.
SELECT-OPTIONS so_belnr  FOR bsis-belnr MODIF ID bel.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP rad.
PARAMETERS radio7 RADIOBUTTON GROUP rad.
PARAMETERS radio3 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 9000.
PARAMETERS pa_ztyp1  LIKE zfgstype-ztype NO-DISPLAY.
PARAMETERS pa_vbund  LIKE bsis-vbund NO-DISPLAY.
PARAMETERS pa_subt1  LIKE zfgstype-zsubtype MODIF ID sub.
PARAMETERS pa_text1  TYPE zfgscab-txt1 MODIF ID pt1.
PARAMETERS pa_text2  TYPE zfgscab-txt2 MODIF ID pt2.
SELECTION-SCREEN COMMENT /35(72) TEXT-003 MODIF ID com.
PARAMETERS pa_text3  TYPE zfgscab-txt3 MODIF ID pt3.
SELECTION-SCREEN COMMENT /35(72) TEXT-004 MODIF ID com.
SELECTION-SCREEN COMMENT /35(72) TEXT-005 MODIF ID com.
SELECTION-SCREEN COMMENT /35(72) TEXT-006 MODIF ID com.
PARAMETERS pa_text4  TYPE zfgscab-txt4 MODIF ID pt4.
PARAMETERS pa_promo  LIKE zfgscab_add-promonr MODIF ID pro.
PARAMETERS pa_actde  LIKE zfgscab_add-actdesc MODIF ID act.
PARAMETERS pa_cust   LIKE zfgscab_add-kunnr MODIF ID kun.
PARAMETERS pa_vat    LIKE zfgscab_add-vat MODIF ID vat.
PARAMETERS pa_pph    LIKE zfgscab_add-pph MODIF ID pph.
PARAMETERS pa_fpnr   LIKE zfgscab_add-fpnr MODIF ID fpn.
PARAMETERS pa_fpdat  LIKE zfgscab_add-fpdat MODIF ID fpd.
PARAMETERS pa_filec  LIKE zfgscab_add-filecabang MODIF ID flc.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(33) TEXT-014 FOR FIELD pa_kunnr.
PARAMETERS pa_kunnr  LIKE kna1-kunnr MODIF ID ktm.
SELECTION-SCREEN : COMMENT 50(50) gv_name1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(33) TEXT-012.
PARAMETERS pa_prd1 LIKE zfgscab-budat MODIF ID pr1.
SELECTION-SCREEN POSITION 45.
SELECTION-SCREEN : COMMENT 47(4) TEXT-013.
PARAMETERS pa_prd2 LIKE zfgscab-budat MODIF ID pr2.
SELECTION-SCREEN END OF LINE.
PARAMETERS pa_kdgrp LIKE zclnumber-kdgrp MODIF ID kdg.
SELECTION-SCREEN END OF SCREEN 9000.

SELECTION-SCREEN BEGIN OF SCREEN 9001 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 3(20) p_jabat1 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 3(20) p_jabat2 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio6 RADIOBUTTON GROUP grp1.
PARAMETERS: p_custom  LIKE zgdtxdt0005-petugas.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 9001.

SELECTION-SCREEN BEGIN OF SCREEN 9002.
PARAMETERS pa_budat  LIKE bkpf-budat DEFAULT sy-datum OBLIGATORY.
PARAMETERS pa_bldat  LIKE bkpf-bldat DEFAULT sy-datum OBLIGATORY.
PARAMETERS pa_xblnr  LIKE bkpf-xblnr NO-DISPLAY.
PARAMETERS pa_bktxt  LIKE bkpf-bktxt NO-DISPLAY.
SELECTION-SCREEN END OF SCREEN 9002.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  IF pa_kunnr IS INITIAL.
    CLEAR gv_name1.
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
    WHEN 'CRET' OR 'NONE'.
      IF sy-dynnr = '9000'.
        PERFORM f_validate_screen_9000.
      ENDIF.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filec.
  PERFORM f_get_filename.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_kunnr.
  PERFORM f_get_tmmt_kunnr USING 'PA_KUNNR'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_kdgrp.
  PERFORM f_get_kdgrp USING 'PA_KDGRP'.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  IF radio7 EQ 'X'.
    PERFORM f_authority_check CHANGING gv_error.
  ENDIF.

  IF gv_error IS INITIAL.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_validate_data.
    PERFORM f_print_data.
    PERFORM f_free_memory.
  ELSE.
    MESSAGE s000(zab) WITH 'You are not authorized'.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_gscabf01.

*------------------common includes for the program---------------------*
