*&---------------------------------------------------------------------*
*& Program Name     : ZGDxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Forms                                            *
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
REPORT zgdmm_f0005n NO STANDARD PAGE HEADING
                    LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* BDC Include
INCLUDE zabp_bdc.

* Smartforms
*INCLUDE zabp_pparameter.
SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-dat.
PARAMETERS: p_tdform    LIKE ssfscreen-fname DEFAULT 'ZGDMMF0005_01NX'
                        OBLIGATORY MODIF ID frm,
            p_dest      LIKE tsp03-padest NO-DISPLAY,
            p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zgdmm_f0005nx2top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
* coding here for your selection data
SELECT-OPTIONS: so_zalno    FOR zgdmmt004a-zalno NO INTERVALS
                                                 NO-EXTENSION
                                                 MODIF ID r03
                                                 OBLIGATORY.
*                so_zaldt    FOR zgdmmt004a-zaldt MODIF ID r03.

PARAMETERS: pa_matnr LIKE mara-matnr OBLIGATORY MODIF ID pma,
            pa_ean11 LIKE mean-ean11 MODIF ID pea,
            pa_werks LIKE eban-werks OBLIGATORY MODIF ID pwe,
            pa_ekgrp LIKE t024-ekgrp OBLIGATORY MODIF ID pek.
PARAMETERS: pa_sdate LIKE sy-datum OBLIGATORY DEFAULT sy-datum MODIF ID sco.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS: so_lfdat FOR eban-lfdat MODIF ID slf.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS: so_ebeln FOR ekko-ebeln MODIF ID seb NO INTERVALS.
SELECTION-SCREEN BEGIN OF BLOCK year WITH FRAME TITLE text-005.
PARAMETERS: pa_mjahr  LIKE mkpf-mjahr OBLIGATORY DEFAULT sy-datum(4) MODIF ID pmj.
SELECTION-SCREEN BEGIN OF BLOCK quarter WITH FRAME TITLE text-004.
PARAMETER: p_q1 RADIOBUTTON GROUP grp2 DEFAULT 'X' USER-COMMAND sem MODIF ID rad,
           p_q2 RADIOBUTTON GROUP grp2 MODIF ID rad,
           p_q3 RADIOBUTTON GROUP grp2 MODIF ID rad,
           p_q4 RADIOBUTTON GROUP grp2 MODIF ID rad.
SELECTION-SCREEN END OF BLOCK quarter.
PARAMETERS: p_get6 AS CHECKBOX DEFAULT 'X' MODIF ID pge.
SELECTION-SCREEN END OF BLOCK year.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK button WITH FRAME TITLE text-002.
PARAMETER: p_old RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND usr,
           p_new RADIOBUTTON GROUP grp1,
           p_reprt RADIOBUTTON GROUP grp1 MODIF ID pre.
SELECTION-SCREEN END OF BLOCK button.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_dest = 'BM3W'.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_werks.
  AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
   ID 'ACTVT' FIELD '03'
   ID 'WERKS' FIELD pa_werks.
  IF sy-subrc <> 0.
    MESSAGE e003(zz) WITH
    'You are not authorized with Plant ' pa_werks.
  ENDIF.

AT SELECTION-SCREEN ON pa_ekgrp.
  AUTHORITY-CHECK OBJECT 'M_BANF_EKG'
   ID 'ACTVT' FIELD '03'
   ID 'EKGRP' FIELD pa_ekgrp.
  IF sy-subrc <> 0.
    MESSAGE e003(zz) WITH
    'You are not authorized with Purch Group ' pa_ekgrp.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_zalno-low.
  PERFORM f_value_zalno USING 'SO_ZALNO-LOW'.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'FRM'.
      screen-input  = 0.
    ENDIF.
    IF screen-group1 = 'SCO'.
      screen-active  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  PERFORM f_selection_screen_output.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  CASE 'X'.
    WHEN p_old.
      p_tdform = 'ZGDMMF0005_01NX'.
    WHEN p_new.
      p_tdform = 'ZGDMMF0005_03NX'.  "'ZGDMMF0005_02NX'.
    WHEN p_reprt.
      p_tdform = 'ZGDMMF0005_03NX'.  "'ZGDMMF0005_02NX'.
  ENDCASE.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  CASE 'X'.
    WHEN p_old.
      tnapr-fonam = 'ZGDMMF0005_01NX'.
    WHEN p_new.
      tnapr-fonam = 'ZGDMMF0005_03NX'.  "'ZGDMMF0005_02NX'.
    WHEN p_reprt.
      tnapr-fonam = 'ZGDMMF0005_03NX'.  "'ZGDMMF0005_02NX'.
  ENDCASE.

  xscreen = p_disp.   "kalau disp - counter enggak naik
  t_nast_key-matnr = pa_matnr.
  p_tdform   = tnapr-fonam.
  PERFORM f_process_report.

*$*$--------------------------------------------------------------------
*    Form          : ENTRY
*    Parameter     : RETURN_CODE
*                    US_SCREEN
*$*$
*$*$ Description   : Entry subroutine for output type determination.
*$*$                 Fill P_{key} from NAST-OBJKY.
*$*$                 <Generated code>
*$*$--------------------------------------------------------------------
FORM entry USING return_code us_screen.
  t_nast_key = nast-objky.
  p_tdform   = tnapr-fonam.
  CLEAR: return_code, d_frm_subrc.
  p_disp = xscreen = us_screen.
  p_dest = 'BM2TNTMM_EP01'.
  PERFORM f_process_report.
  return_code = d_frm_subrc.
ENDFORM.                    "entry

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdmm_f0005nx2f01.
*------------------common includes for the program---------------------*
