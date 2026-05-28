*&---------------------------------------------------------------------*
*& Program Name     : ZTNPQM_F002                                      *
*& Module Name      : QM                                               *
*& Author           : Budi Pramono                                     *
*& Functional       :                                                  *
*& Create Date      : 03/03/2005                                       *
*& Program Type     : Forms                                            *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : UD Label                                         *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&         05/02/05      Budi HS        Revise Layout Print Out        *
*&---------------------------------------------------------------------*
REPORT ztnpqm_f002
               NO STANDARD PAGE HEADING
               LINE-SIZE 255
               MESSAGE-ID zqm.
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

DATA : p_tdform    LIKE ssfscreen-fname,
       p_dest      LIKE tsp03-padest,
       p_disp      LIKE ssfctrlop-preview.

INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zgdqm_f0002top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
* coding here for your selection data
PARAMETERS:
  pa_werk  LIKE qals-werk OBLIGATORY.
SELECT-OPTIONS:
  so_pruef FOR qals-prueflos OBLIGATORY NO-EXTENSION NO INTERVALS,
  so_matnr FOR qals-matnr,
  so_charg FOR qals-charg.
PARAMETERS:
  pa_wadah TYPE numc2.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK vbewertung WITH FRAME TITLE text-002.
PARAMETERS: p_mblnr LIKE mseg-mblnr,
            p_mjahr LIKE mseg-mjahr.
PARAMETERS: p_a RADIOBUTTON GROUP radi DEFAULT 'X',
            p_r RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF BLOCK vbewertung.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_tdform = 'ZTNPQM_SF003'.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_werk.
*-Authorization
  macro_atz_single_werks pa_werk c_atz_display.

*  IF pa_werk NE '0101' AND
*    pa_werk NE '0102' AND
*    pa_werk NE '0901'.
*    MESSAGE e000(zqm) WITH 'Plant must be entry 0101 or 0102 or 0901'.
*  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_get_qprs USING so_pruef-low
                     CHANGING pa_wadah.

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
  INCLUDE zgdqm_f0002f01.
*------------------common includes for the program---------------------*
