*&---------------------------------------------------------------------*
*& Program Name     : ZGDSD_F0001                                      *
*& Module Name      : SD                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : 23/12/2004                                       *
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
REPORT zgdsd_f0001
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
INCLUDE zgdsdf0001top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-dat.
* coding here for your selection data
PARAMETER: p_vbeln LIKE likp-vbeln.
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
  t_nast_key-vbeln = p_vbeln.
  CASE nast-kschl.
    WHEN 'ZD01'.
      tnapr-fonam      = 'ZGDSDF0001_01'.
    WHEN 'ZD02'.
      tnapr-fonam      = 'ZGDSDF0001_02'.
    WHEN 'ZP01'.
      tnapr-fonam      = 'ZGDSDF0001_03'.
    WHEN 'ZRX1'.
      tnapr-fonam      = 'ZGDSDF0001_01RXF'.
    WHEN 'ZRX2'.
      tnapr-fonam      = 'ZGDSDF0001_02RXF'.
  ENDCASE.
  IF tnapr-fonam IS NOT INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.
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
  p_vbeln = nast-objky.
*  CASE nast-kschl.
*    WHEN 'ZD01'.
*      tnapr-fonam      = 'ZGDSDF0001_01'.
*    WHEN 'ZD02'.
*      tnapr-fonam      = 'ZGDSDF0001_02'.
*    WHEN 'ZP01'.
*      tnapr-fonam      = 'ZGDSDF0001_03'.
*  ENDCASE.
  IF NOT tnapr-sform IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSEIF NOT tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.
*  p_tdform = tnapr-fonam.
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
  INCLUDE zgdsdf0001f01.
*------------------common includes for the program---------------------*
