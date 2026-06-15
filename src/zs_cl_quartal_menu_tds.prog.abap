*&---------------------------------------------------------------------*
*& Report  ZS_CL_SEMESTER_MENU_TDS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zs_cl_quartal_menu_tds.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK block1.

START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      SUBMIT zs_cl_quartal_hitung VIA SELECTION-SCREEN AND RETURN.
    WHEN radio2.
      SUBMIT zs_cl_quartal_upload VIA SELECTION-SCREEN AND RETURN.
    WHEN radio3.
      SUBMIT zs_cl_quartal_update VIA SELECTION-SCREEN AND RETURN.
    WHEN radio4.
      SUBMIT zs_cl_quartal_download VIA SELECTION-SCREEN AND RETURN.
    WHEN radio5.
      SUBMIT zs_cl_quartal_report VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

END-OF-SELECTION.
