*&---------------------------------------------------------------------*
*& Report  ZFI_DEPR_KOSTL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_depr_kostl NO STANDARD PAGE HEADING LINE-SIZE 650.

INCLUDE zfi_depr_kostltop.

INCLUDE zfi_depr_kostlcl1.

INCLUDE zabp_header.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   TYPE anlp-bukrs MODIF ID pbu.
PARAMETERS pa_gsber   TYPE anlp-gsber MODIF ID pgs.
PARAMETERS pa_gjahr   TYPE anlp-gjahr DEFAULT sy-datum(4) MODIF ID pgj.
PARAMETERS pa_peraf   TYPE anlp-peraf DEFAULT sy-datum+4(2) MODIF ID ppe.
SELECT-OPTIONS so_kostl   FOR anlp-kostl.
SELECT-OPTIONS so_saknr   FOR t095b-ktnafg.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS pa_drill AS CHECKBOX DEFAULT 'X' MODIF ID pdr.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection-screen_output.

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

START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*TOP-OF-PAGE.
*  CASE 'X'.
*    WHEN radio3.
*      WRITE: /(568) sy-uline.
*      WRITE: / '|' NO-GAP,
*        (55) 'Cost Center' CENTERED NO-GAP, '|' NO-GAP,
*        (40) 'G/L Group' CENTERED NO-GAP, '|' NO-GAP,
*        (55) ' Exp.ord.deprec.' CENTERED NO-GAP, '|' NO-GAP,
*        (12) 'Asset' CENTERED NO-GAP, '|' NO-GAP,
*         (4) 'SNo'CENTERED NO-GAP, '|' NO-GAP,
*        (10) 'Capitalized on' NO-GAP, '|' NO-GAP,
*        (50) 'Asset Description' CENTERED NO-GAP, '|' NO-GAP,
*         (4) 'Year' NO-GAP, '|' NO-GAP,
*         (5) 'Crcy' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Januari' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Februari' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Maret'CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Quarter 1' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'April'CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Mei'CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Juni'CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Quarter 2' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Semester 1' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Juli' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Agustus' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'September'CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Quarter 3' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Oktober' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'November' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Desember' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Quarter 4' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Semester 2' CENTERED NO-GAP, '|' NO-GAP,
*        (16) 'Total' CENTERED NO-GAP, '|' NO-GAP.
*      WRITE: /(568) sy-uline.
*
*    WHEN radio4.
*  ENDCASE.

  INCLUDE zfi_depr_kostlm01.

  INCLUDE zfi_depr_kostlf01.
