*&---------------------------------------------------------------------*
*& Program Name     : ZSFAFI_MENU                                      *
*& Module Name      : FI-SFA                                           *
*& Author           : Suk                                              *
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*&                                                                     *
*&---------------------------------------------------------------------*


REPORT  zhsm_menu.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME. " TITLE text-001.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.

PARAMETERS: r01 RADIOBUTTON GROUP r1,
            r02 RADIOBUTTON GROUP r1,
            r03 RADIOBUTTON GROUP r1,
            r04 RADIOBUTTON GROUP r1,
            r05 RADIOBUTTON GROUP r1,
            r06 RADIOBUTTON GROUP r1,
            r07 RADIOBUTTON GROUP r1,
            r08 RADIOBUTTON GROUP r1,
            r09 RADIOBUTTON GROUP r1. ",
            "r10 RADIOBUTTON GROUP r1,
            "r11 RADIOBUTTON GROUP r1.
"r10 RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.



START-OF-SELECTION.
  CASE 'X'.
    WHEN r01.
      SUBMIT zhsmmm_e001 VIA SELECTION-SCREEN AND RETURN.
    WHEN r02.
      SUBMIT zhsmmm_e003 VIA SELECTION-SCREEN AND RETURN.
    WHEN r03.
      SUBMIT zhsmmm_i002 VIA SELECTION-SCREEN AND RETURN.
    WHEN r04.
      SUBMIT zhsmmm_i005 VIA SELECTION-SCREEN AND RETURN.
    WHEN r05.
      SUBMIT zhsmmm_e002 VIA SELECTION-SCREEN AND RETURN.
    WHEN r08.
      SUBMIT zhsmmm_i004 VIA SELECTION-SCREEN AND RETURN.
    WHEN r09.
      SUBMIT zhsmpp_i001 VIA SELECTION-SCREEN AND RETURN.
    WHEN R06.
      SUBMIT zhsmmm_e004 VIA SELECTION-SCREEN AND RETURN.
    WHEN R07.
      SUBMIT zhsmmm_e007 VIA SELECTION-SCREEN AND RETURN.

  ENDCASE.
