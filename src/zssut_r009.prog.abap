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
REPORT zssut_r009 NO STANDARD PAGE HEADING
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

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zssut_r009top.

* Smartforms
INCLUDE zabp_smartform.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:     p_vkorg TYPE vkorg OBLIGATORY,
                p_vkbur TYPE vkbur OBLIGATORY MATCHCODE OBJECT h_tvbur.
SELECT-OPTIONS: s_pernr FOR zssutdt025-pernr,
                s_daily FOR zssutdt025-daily_call_num,
                s_datum FOR zssutdt025-sdate OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*at SELECTION-SCREEN ON p_date.
***AT SELECTION-SCREEN ON   p_vkbur.
***data: lv_value(10).
***  select single field_value into lv_value from zscust_control
***     where field_value = p_vkbur and
***           cek = 'SFA' and
***           vkorg = p_vkorg.
***  if sy-subrc eq 0.
***    MESSAGE e000(zs) WITH 'Sales Office SFA, Proses ulang dan pilih Tick Life SFA'.
***  endif.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

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
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
***  select * into CORRESPONDING FIELDS OF TABLE gt_ZSCUST_CONTROL
***       from zscust_control
***       where vkorg = p_vkorg
***         and field_name = 'VKBUR'
***         and field_value = p_vkbur
***         AND datab <= sy-datum.
***  if sy-subrc eq 0.
***    MESSAGE e000(zb) WITH 'Cabang SFA - Gagal Proses'.
***    exit.
***  endif.
  xscreen = p_disp.   "kalau disp - counter enggak naik
*  t_nast_key-matnr = pa_matnr.
  tnapr-fonam      = p_tdform.
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
  p_dest = nast-ldest.
  PERFORM f_process_report.
  return_code = d_frm_subrc.
ENDFORM.                    "entry

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zssut_r009f01.
*------------------common includes for the program---------------------*
