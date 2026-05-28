*&---------------------------------------------------------------------*
*& Report  ZTSPMM_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztspmm_e002 NO STANDARD PAGE HEADING.

INCLUDE ztspmm_e002top.

SELECTION-SCREEN BEGIN OF BLOCK blok1 WITH FRAME TITLE text-001.
PARAMETERS: butt1 RADIOBUTTON GROUP grp1 DEFAULT 'X'
                                         USER-COMMAND us1
                                         MODIF ID bu1,
            butt2 RADIOBUTTON GROUP grp1 MODIF ID bu2.
SELECTION-SCREEN END OF BLOCK blok1.

SELECTION-SCREEN BEGIN OF SCREEN 0500 TITLE text-002.
PARAMETERS: p_rsnum LIKE resb-rsnum MODIF ID rsn.
SELECTION-SCREEN END OF SCREEN 0500.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_rsnum.
  PERFORM f_check_resb.

*&---------------------------------------------------------------------*

START-OF-SELECTION.

  CASE 'X'.
    WHEN butt1.
      PERFORM f_init_data.
      CALL SCREEN 100.

    WHEN butt2.
      CALL SELECTION-SCREEN 0500.
      IF sy-subrc IS INITIAL.
        PERFORM f_cancel_bstb.
      ENDIF.
  ENDCASE.

END-OF-SELECTION.

*&---------------------------------------------------------------------*

  INCLUDE ztspmm_e002m01.

  INCLUDE ztspmm_e002f01.
