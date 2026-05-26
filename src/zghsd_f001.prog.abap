*&---------------------------------------------------------------------*
*& Form Surat Jalan
*&
*&---------------------------------------------------------------------*
*&
*& Module Name      : SD
*& Author           : Budi
*& Functional       : IAN
*& Creation Date    : 15.05.2023
*&
*&---------------------------------------------------------------------*
REPORT  ztspfi_f001 NO STANDARD PAGE HEADING
                    LINE-SIZE 255.

* Smartforms
INCLUDE zabp_frm.
INCLUDE zabp_pparameter.
INCLUDE zabp_smartform.

*------------------common TOP includes for the program----------------*
INCLUDE zghsd_f001top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
* coding here for your selection data
PARAMETER: p_vbeln LIKE likp-vbeln OBLIGATORY.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_tdform = 'ZGHSD_F001'.

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
  p_vbeln    = nast-objky.
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
  INCLUDE zghsd_f001f01.
*------------------common includes for the program---------------------*
