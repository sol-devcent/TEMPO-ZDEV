*----------------------------------------------------------------------*
*   INCLUDE ZSHEADER                                                   *
*----------------------------------------------------------------------*
*include zsheader.
************************************************************************
*----------------------------------------------------------------------*
*  Desription:                                                         *
*    This is a subroutine to print a standard report header for any    *
*    report size.                                                      *
************************************************************************
*  Modification Log:                                                   *
*    1) Changed on    :                                                *
*       Changed by    :                                                *
*       Change-No     :                                                *
*       Description   :                                                *
************************************************************************

DATA: V_TITLE1(95),                            "title line 1
      V_TITLE2(95),                            "title line 2
      V_TITLE3(95),                            "title line 3
      V_TITLE4(95),                            "extranous title line
      V_TITLE5(95),                            "extranous title line
      V_CURRENT_PAGE(10),                      "current page

      V_LEFT_HEADER_LEN    TYPE I VALUE 18,   "space for report id
      V_RIGHT_HEADER_LEN   TYPE I VALUE 17,   "space for date stamp
      V_BETWEEN_HEADER_LEN TYPE I,            "space in between
      V_REPID(30)          TYPE C,            "report id
      V_RIGHT              TYPE I.            "position for date field

CONSTANTS:
      C_REPORT(9)   TYPE C VALUE 'Report  :',
      C_CLISYS(9)   TYPE C VALUE 'Cli/Sys :',
      C_USERID(9)   TYPE C VALUE 'UserID  :',
      C_DATE(6)     TYPE C VALUE 'Date :',
      C_TIME(6)     TYPE C VALUE 'Time :',
      C_PAGE(6)     TYPE C VALUE 'Page :'.

***** Form WRITE_HEADER *****
FORM F_WRITE_HEADER.

  WRITE SY-PAGNO TO V_CURRENT_PAGE.
  SHIFT V_CURRENT_PAGE LEFT DELETING LEADING SPACE.
  IF V_TITLE1 EQ SPACE.
    V_TITLE1 = SY-TITLE.
  ENDIF.

  V_BETWEEN_HEADER_LEN =
    SY-LINSZ - V_LEFT_HEADER_LEN - V_RIGHT_HEADER_LEN - 4.
  V_RIGHT = SY-LINSZ - V_RIGHT_HEADER_LEN + 1.

  FORMAT COLOR OFF INTENSIFIED ON.
  WRITE AT: /30(V_BETWEEN_HEADER_LEN) V_TITLE1 CENTERED.
  WRITE: 1 C_REPORT INTENSIFIED OFF, V_REPID.

  POSITION V_RIGHT.
  WRITE:  C_DATE   INTENSIFIED OFF,
          SY-DATUM DD/MM/YYYY LEFT-JUSTIFIED.
  WRITE:/ C_CLISYS INTENSIFIED OFF.
  WRITE:   SY-MANDT NO-GAP, '/' NO-GAP, SY-SYSID.
  WRITE AT: 30(V_BETWEEN_HEADER_LEN) V_TITLE2 CENTERED.

  POSITION V_RIGHT.
  WRITE:  C_TIME      INTENSIFIED OFF,
          SY-UZEIT LEFT-JUSTIFIED.
  WRITE:/ C_USERID    INTENSIFIED OFF,  SY-UNAME, '/', sy-tcode.
  WRITE AT: 30(V_BETWEEN_HEADER_LEN) V_TITLE3 CENTERED.

  POSITION V_RIGHT.
  WRITE:  C_PAGE  INTENSIFIED OFF,
          V_CURRENT_PAGE LEFT-JUSTIFIED.
  IF NOT V_TITLE4 IS INITIAL.
     WRITE AT: (SY-LINSZ) V_TITLE4 CENTERED.
  ENDIF.

  IF NOT V_TITLE5 IS INITIAL.
     WRITE AT: (SY-LINSZ) V_TITLE5 CENTERED.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER

***** Form WRITE_FOOTER *****
FORM F_WRITE_FOOTER USING P_FOOTER_TXT.
  FORMAT COLOR OFF INTENSIFIED ON.
  SKIP. ULINE.
  WRITE:/ P_FOOTER_TXT.
ENDFORM.                    " F_WRITE_FOOTER

*&---------------------------------------------------------------------*
*&      Form  BLANK_PAGE
*&---------------------------------------------------------------------*
*       Check the page number. If the page number is an odd number,
*       add another blank page with text '***** THIS PAGE IS INTENTION-
*       ALLY LEFT BLANK *****'
*----------------------------------------------------------------------*
FORM BLANK_PAGE.

DATA: L_PAGE TYPE I,
      L_SKIP TYPE I.

  l_page = sy-pagno mod 2.
  if l_page > 0.
     new-page.
     L_SKIP = ( SY-LINCT - SY-LINNO ) DIV 2.
     SKIP L_SKIP.
     WRITE AT (SY-LINSZ)
              '***** THIS PAGE IS INTENTIONALLY LEFT BLANK *****'
              CENTERED.
  endif.

ENDFORM.                    " BLANK_PAGE
