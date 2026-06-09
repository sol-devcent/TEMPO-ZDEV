*&---------------------------------------------------------------------*
*& Program Name     : ZGDMM_F0001                                      *
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
REPORT zgdmm_f0001
               NO STANDARD PAGE HEADING
               LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* other common functions
INCLUDE zabp_frm.

* Smartforms
*INCLUDE zabp_pparameter.
INCLUDE z_pparameter.
INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zgdmmf0001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-dat.
* coding here for your selection data
PARAMETER: p_ebeln LIKE ekko-ebeln OBLIGATORY.
PARAMETER: p_ld AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  SELECT SINGLE spld
    FROM usr01
    INTO p_dest
    WHERE bname EQ sy-uname.

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

  xscreen    = p_disp.   "kalau disp - counter enggak naik
  nast-objky = p_ebeln.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = xscreen
    IMPORTING
      ex_retco       = d_retcode
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.

  CHECK d_retcode EQ 0.

  IF l_doc-xekko-bsart EQ 'ZIMP'.
    CASE l_doc-xekko-bukrs.
      WHEN '8010'.
        p_tdform = 'ZGDMMF0001_01'.
      WHEN '8050' OR '8230'.
        p_tdform = 'ZGDMMF0001_04N'.
      WHEN OTHERS.
        p_tdform = 'ZGDMMF0001_01'.
    ENDCASE.
  ELSE.
    CASE l_doc-xekko-bukrs.
      WHEN '8010'.
        p_tdform = 'ZGDMMF0001_02'.
      WHEN '8050' OR '8230'.
        p_tdform = 'ZGDMMF0001_05N'.
      WHEN OTHERS.
        p_tdform = 'ZGDMMF0001_02'.
    ENDCASE.
  ENDIF.

  PERFORM f_authority_cek.
  PERFORM f_process_report.

*$*$--------------------------------------------------------------------
*    Form          : ENTRY_L
*    Parameter     : RETURN_CODE
*                    US_SCREEN
*$*$
*$*$ Description   : Entry subroutine for output type determination.
*$*$                 Fill P_{key} from NAST-OBJKY.
*$*$                 <Generated code>
*$*$--------------------------------------------------------------------
FORM entry_l USING return_code us_screen.
  wa_hd-ld = 'X'.
  PERFORM entry USING return_code us_screen.
ENDFORM.                    "entry_l

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
  CLEAR return_code.
* Cek apakah changes PO
*  IF nast-aende EQ space.
* New Po
  l_druvo = '1'.
*  ELSE.
* Change PO
*    l_druvo = '2'.
*  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = us_screen
    IMPORTING
      ex_retco       = return_code
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK return_code EQ 0.

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
ENDFORM.                    "entry

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdmmf0001f01.
*  include zibmformtempf01.
*------------------common includes for the program---------------------*
