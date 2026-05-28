*&---------------------------------------------------------------------*
*& Program Name     : ZGDQM_F0001                                      *
*& Module Name      : QM                                               *
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
REPORT zgdqm_f0001
               NO STANDARD PAGE HEADING
               LINE-SIZE 255 MESSAGE-ID zqm.
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
INCLUDE zgdqmf0001top.
*include zibmformtemptop.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
  pa_werk  LIKE qals-werk OBLIGATORY.
SELECT-OPTIONS:
  so_pruef FOR qals-prueflos OBLIGATORY.
PARAMETERS:
  pa_herku LIKE qals-herkunft OBLIGATORY,
  pa_matnr LIKE qals-matnr OBLIGATORY,
  pa_mtart LIKE mara-mtart.
SELECTION-SCREEN END OF BLOCK data.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_tdform = 'ZGDQMF0001_01'.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_werk.
*-Authorization
  macro_atz_single_werks pa_werk c_atz_display.

*  IF pa_werk NE '0101' AND
*    pa_werk NE '0102' AND
*    pa_werk NE '0901'.
*    MESSAGE e000(zab) WITH 'Plant must be entry 0101 or 0102 or 0901'.
*  ENDIF.

AT SELECTION-SCREEN ON pa_herku.
  IF pa_herku NE '01' AND
    pa_herku NE '04' AND
    pa_herku NE '05' AND
    pa_herku NE '08' AND
    pa_herku NE '09'.
    MESSAGE e000(zab)
      WITH 'Inspection lot origin must be entry 01 or 04 or 05 or 09'.
  ENDIF.

AT SELECTION-SCREEN ON pa_mtart.
* check Material Type from MARA
  IF pa_mtart NE space.
    SELECT SINGLE mtart
      FROM mara
      INTO va_mtart
      WHERE matnr EQ pa_matnr AND
            mtart EQ pa_mtart.
    IF sy-subrc NE 0.
      MESSAGE e000(zab)
        WITH 'Wrong Material type'.
    ENDIF.
  ELSE.
    SELECT SINGLE mtart
      FROM mara
      INTO va_mtart
      WHERE matnr EQ pa_matnr.
  ENDIF.

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
  tnapr-fonam      = p_tdform.
  PERFORM f_process_report.

**$*$-------------------------------------------------------------------
**    Form          : ENTRY
**    Parameter     : RETURN_CODE
**                    US_SCREEN
**$*$
**$*$ Description   : Entry subroutine for output type determination.
**$*$                 Fill P_{key} from NAST-OBJKY.
**$*$                 <Generated code>
**$*$-------------------------------------------------------------------
*FORM entry USING return_code us_screen.
*  t_nast_key = nast-objky.
*  p_tdform   = tnapr-fonam.
*  CLEAR: return_code, d_frm_subrc.
*  p_disp = xscreen = us_screen.
*  p_dest = nast-ldest.
*  PERFORM f_process_report.
*  return_code = d_frm_subrc.
*ENDFORM.


*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdqmf0001f01.
*  include zibmformtempf01.
*------------------common includes for the program---------------------*
