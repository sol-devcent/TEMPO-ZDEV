*&---------------------------------------------------------------------*
*& Program Name     : ZTNTSD_F0001                                     *
*& Module Name      : SD                                               *
*& Author           : Budi.P                                           *
*& Functional       : Gunawan                                          *
*& Create Date      : 03/06/2015                                       *
*& Program Type     : Forms                                            *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Faktur pajak TNT                                 *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#       DATE        AUTHOR       DESCRIPTION                    *
*& ----        ----        ------       -----------                    *
*& DEVK943409  03/05/2015  Budi.P       Initial                        *                                                 *
*&---------------------------------------------------------------------*
REPORT ztntsd_f0001 NO STANDARD PAGE HEADING
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
INCLUDE zabp_pparameter.
INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE ztntsd_f0001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-dat.
PARAMETERS pa_vbeln   LIKE vbrk-vbeln.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_tdform = 'ZTNTSDF0001'.
  p_tdform2 = 'ZTNTSDF0003'.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*at SELECTION-SCREEN ON p_date.


*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  xscreen = p_disp.   "kalau disp - counter enggak naik
  t_nast_key-vbeln = pa_vbeln.
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
  pa_vbeln       = nast-objky.

  CLEAR: return_code, d_frm_subrc.

  p_disp = xscreen = us_screen.
  p_dest = nast-ldest.

  IF NOT tnapr-sform IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSEIF NOT tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.

  p_tdform2 = 'ZTNTSDF0003'.

  PERFORM f_process_report.

  return_code = d_frm_subrc.
ENDFORM.                    "entry

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE ztntsd_f0001f01.
*------------------common includes for the program---------------------*
