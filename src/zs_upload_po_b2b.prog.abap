*&---------------------------------------------------------------------*
*& Report  ZS_UPLOAD_PO_B2B
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZS_UPLOAD_PO_B2B.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK block1.

START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      SUBMIT ZS_UPLOAD_PO_B2B_alfamart VIA SELECTION-SCREEN AND RETURN.
    WHEN radio2.
      SUBMIT ZS_UPLOAD_PO_B2B_indomart via SELECTION-SCREEN AND RETURN.
    WHEN radio3.
      SUBMIT ZS_UPLOAD_PO_B2B_lion via SELECTION-SCREEN AND RETURN.
  ENDCASE.

END-OF-SELECTION.
