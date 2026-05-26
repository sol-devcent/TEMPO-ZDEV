*&---------------------------------------------------------------------*
*& Program Name     : ZGDMM_F0002                                      *
*& Module Name      : MM                                               *
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
REPORT zgdmm_f0002
               NO STANDARD PAGE HEADING
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
INCLUDE zgdmmf0002top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-dat.
* coding here for your selection data
PARAMETER: p_mblnr LIKE mseg-mblnr,
           p_mjahr LIKE mseg-mjahr.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

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
  t_nast_key-mblnr = p_mblnr.
  t_nast_key-mjahr = p_mjahr.
  CASE nast-kschl.
* Goods Receipt Slip
    WHEN 'ZWE1'.
      tnapr-fonam      = 'ZGDMMF0002_01'.
* Karantina
    WHEN 'ZWE2'.
      tnapr-fonam      = 'ZGDMMF0002_05'.
* GI Slip
    WHEN 'ZWA1'.
      tnapr-fonam      = 'ZGDMMF0002_04'.
* Transfer Stock
    WHEN 'ZWA2'.
      tnapr-fonam      = 'ZGDMMF0002_02'.
  ENDCASE.
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
  p_mblnr = nast-objky(10).
  p_mjahr = nast-objky+10(4).
*  CASE nast-kschl.
** Goods Receipt Slip
*    WHEN 'ZWE1'.
*      tnapr-fonam      = 'ZGDMMF0002_01'.
** Karantina
*    WHEN 'ZWE2'.
*      tnapr-fonam      = 'ZGDMMF0002_05'.
** GI Slip
*    WHEN 'ZWA1'.
*      tnapr-fonam      = 'ZGDMMF0002_04'.
** Transfer Stock
*    WHEN 'ZWA2'.
*      tnapr-fonam      = 'ZGDMMF0002_02'.
*  ENDCASE.
*  p_tdform   = tnapr-fonam.
  IF NOT tnapr-sform IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSEIF NOT tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.
  CLEAR: return_code, d_frm_subrc.
  p_disp = xscreen = us_screen.
  p_dest = nast-ldest.
  PERFORM f_process_report.
  return_code = d_frm_subrc.
ENDFORM.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdmmf0002f01.
*------------------common includes for the program---------------------*
