*&---------------------------------------------------------------------*
*& Report  ZS_CL_SEMESTER_MENU_CAB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zs_cl_quartal_menu_cab.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK block1.

START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      SUBMIT zs_cl_quartal_usulan VIA SELECTION-SCREEN AND RETURN.
    WHEN radio2.
      SUBMIT zs_cl_quartal_report VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

END-OF-SELECTION.
