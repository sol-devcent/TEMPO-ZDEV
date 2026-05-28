*&---------------------------------------------------------------------*
*& Report  ZTDS_FTMP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zqm_coa NO STANDARD PAGE HEADING.

INCLUDE zabp_frm.

INCLUDE zqm_coatop.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS so_pruef     FOR qals-prueflos MODIF ID ppr.
PARAMETERS pa_vorln     TYPE qcvk-vorlnr MODIF ID pvo.
PARAMETERS pa_ctyp      TYPE qcvk-ctyp MODIF ID pct.
PARAMETERS pa_vers      TYPE qcvk-version MODIF ID pve.
PARAMETERS pa_langu     TYPE vskt-sprache DEFAULT sy-langu.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_disp       LIKE ssfctrlop-preview  AS CHECKBOX
                                                MODIF ID pds.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK process WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad MODIF ID r01.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID r02.
SELECTION-SCREEN END OF BLOCK process.

SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-003.
PARAMETERS: p_tdform    LIKE ssfscreen-fname DEFAULT 'ZQMCOAF' NO-DISPLAY,
            p_dest      LIKE tsp03-padest NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blxx.

SELECTION-SCREEN BEGIN OF SCREEN 110 TITLE TEXT-110.
PARAMETERS: pa_qam TYPE ad_namtext,
            pa_pm  TYPE ad_namtext.
SELECTION-SCREEN END OF SCREEN 110.

INCLUDE zabp_smartform.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen USING : 'PDS' '0' '' '' ''.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection-screen.
    WHEN space.
      PERFORM f_selection-screen.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_qam.
  PERFORM f_get_sign USING '02' CHANGING pa_qam.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_pm.
  PERFORM f_get_sign USING '03' CHANGING pa_pm.

START-OF-SELECTION.
  PERFORM f_output_type.

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  DATA : ls_key   LIKE LINE OF t_nast_key.

  gv_kschl      = nast-kschl.
  ls_key-ebeln  = nast-objky.
  APPEND ls_key TO t_nast_key.
*  pa_pruef      = nast-objky.
  IF tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSE.
    p_tdform   = tnapr-fonam.
  ENDIF.
  CLEAR: return_code, d_frm_subrc.
  p_disp = xscreen = us_screen.
  p_dest = nast-ldest.
  PERFORM f_output_type.
  return_code = d_frm_subrc.
ENDFORM.                    "entry

INCLUDE zqm_coaf01.
