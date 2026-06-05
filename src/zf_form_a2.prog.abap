*----------------------------------------------------------------------*
*   INCLUDE ZF_FORM_A2                                                 *
*----------------------------------------------------------------------*
************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZFF_FORM_A2                                        *
*  PROGRAM DESC  :  A2  FORM                                           *
*  CREATED BY    :  DIDIK IMAWAN                                       *
*  CREATED ON    :                                                     *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER       CORRECTION  DESCRIPTION                *
*  ----------  ---------------  ----------  -------------------------  *
*  DD/MM/YYYY  XXXXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXX  *
*                                                                      *
************************************************************************
FORM F_CETAK_A2.
    NOU = 0.
    CNTR = 0.
    CNTR1 = 0.
    PAGE = 1.
    PERFORM GET_DATAA2.
    PERFORM HITUNGA2.
    IF CNTR1 > 0.
       PERFORM CETAKA2.
    ELSE.
      PERFORM GET_HEADER_A2.
      PERFORM CETAKA2_1.
    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CETAKA2_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CETAKA2_1.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZF_A2_FORM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER4'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LINE1'
      WINDOW = 'LINE'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'NIHIL'
      WINDOW = 'MAIN'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'FOOTER1'
      WINDOW = 'FOOTER1'
    EXCEPTIONS
     OTHERS = 1.

 CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " CETAKA2_1

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_A2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_HEADER_A2.

  DATA: L_BUTXT     LIKE T001-BUTXT,
        L_NPWP      LIKE ZFTAX-NPWP,
        L_NPPKP     LIKE ZFTAX-NPPKP,
        L_PKDAT     LIKE ZFTAX-PKDAT.

    SELECT SINGLE NPWP NPPKP PKDAT
      FROM ZFTAX
      INTO (L_NPWP, L_NPPKP, L_PKDAT)
      WHERE BUKRS EQ PA_BUKRS AND
            GSBER EQ PA_GSBER.

    SELECT SINGLE BUTXT
      FROM T001
      INTO L_BUTXT
      WHERE BUKRS EQ PA_BUKRS.

    MOVE L_BUTXT  TO BUTXT.
    MOVE L_NPWP   TO NPWP.
    MOVE L_NPPKP  TO NPPKP.
    MOVE L_PKDAT  TO PKDAT.
ENDFORM.                    " GET_HEADER_A2

*&---------------------------------------------------------------------*
*&      Form  CETAKA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form CETAKA2.
DATA: JML_DEBET LIKE ZFVATA1-DMBTR,
      JML_CREDIT LIKE ZFVATA1-DMBTR.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZF_A2_FORM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'HEADER4'
      WINDOW = 'HEADER4'
    EXCEPTIONS
      OTHERS = 1.

  IF CNTR1 > 35.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'LINE'
        WINDOW = 'LINE'
      EXCEPTIONS
        OTHERS = 1.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'LINE1'
        WINDOW = 'LINE'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  CLEAR: WA_ITABA2, TDMBTR, TDMBTR1, TDMBTR2, JUMLAH1, JUMLAH2, JUMLAH,
         JML_DEBET, JML_CREDIT.

  SORT I_ITABA2 BY ZSTATUS DESCENDING TBELN TXDAT.
  LOOP AT I_ITABA2 INTO WA_ITABA2.
    IF WA_ITABA2-SHKZG NE SPACE.
      MOVE WA_ITABA2-NAME1  TO NAME1.
      MOVE WA_ITABA2-STCEG  TO STCEG.
      MOVE WA_ITABA2-TBELN  TO TBELN.
      MOVE WA_ITABA2-TXDAT  TO TXDAT.
      MOVE WA_ITABA2-NPWP   TO NPWP.
      MOVE WA_ITABA2-NPPKP  TO NPPKP.

      CASE WA_ITABA2-ZSTATUS.
        WHEN '23'.
          IF WA_ITABA2-SHKZG = 'S'.
             WRITE WA_ITABA2-DMBTR CURRENCY 'IDR' TO DMBTR DECIMALS 0.
             SHIFT DMBTR LEFT DELETING LEADING SPACE.
             CONCATENATE '(' DMBTR ')' INTO DMBTR1.
             WRITE DMBTR1 TO DMBTR1 RIGHT-JUSTIFIED.
             WA_ITABA2-DMBTR = WA_ITABA2-DMBTR * -1.
          ELSE.
             WRITE WA_ITABA2-DMBTR CURRENCY 'IDR' TO DMBTR1 DECIMALS 0.
          ENDIF.
      ENDCASE.

      IF PAGE GT 1 AND
        CNTR EQ 0.
        PAGE1 = PAGE - 1.
        TDMBTR1 = TDMBTR2.
        WRITE TDMBTR1 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
        IF TDMBTR1 < 0.
          TDMBTR1 = TDMBTR1 * -1.
          WRITE TDMBTR1 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
          SHIFT TDMBTR1X LEFT DELETING LEADING SPACE.
          CONCATENATE '(' TDMBTR1X ')' INTO TDMBTR1X.
          TDMBTR1 = TDMBTR1 * -1.
        ELSE.
          WRITE TDMBTR1 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
        ENDIF.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'PINDAHAN'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.
        ADD 1 TO CNTR.
      ENDIF.

      IF PAGE EQ 1 AND
        NOU = 0.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'KOSONG'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.
        ADD 1 TO CNTR.
      ENDIF.

      ADD 1 TO NOU.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'DETAIL'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.

      ADD 1 TO CNTR.
      ADD 1 TO CNTR2.

      IF WA_ITABA2-SHKZG EQ 'H'.
        ADD WA_ITABA2-DMBTR TO FAKTUR1.
      ELSE.
        ADD WA_ITABA2-DMBTR TO FAKTUR2.
      ENDIF.

      ADD WA_ITABA2-DMBTR TO TDMBTR.

      IF CNTR  EQ 54 AND
         CNTR2 NE CNTR1.
        ADD 1 TO PAGE.
        PAGE2 = PAGE.
        PAGE3 = PAGE - 1.

        IF PAGE3 EQ 1.
          MOVE TDMBTR TO TDMBTR2.
        ELSE.
          TDMBTR2 = TDMBTR + TDMBTR2.
        ENDIF.

        IF TDMBTR2 < 0.
           TDMBTR2 = TDMBTR2 * -1.
           WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.
           SHIFT TDMBTR2X LEFT DELETING LEADING SPACE.
           CONCATENATE '(' TDMBTR2X ')' INTO TDMBTR2X.
           TDMBTR2 = TDMBTR2 * -1.
        ELSE.
           WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.
        ENDIF.

        CLEAR: TDMBTR, CNTR.
        CNTR = 0.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'PINDAH'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'KOSONG'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.
      ENDIF.

      CLEAR: WA_ITABA2.
    ENDIF.
  ENDLOOP.

  IF CNTR EQ 0 AND
     CNTR2 NE 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'NEWPAGE'
        WINDOW = 'MAIN'
      EXCEPTIONS
        OTHERS = 1.

    IF TDMBTR2 < 0.
       TDMBTR2 = TDMBTR2 * -1.
       WRITE TDMBTR2 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
       SHIFT TDMBTR1X LEFT DELETING LEADING SPACE.
       CONCATENATE '(' TDMBTR1X ')' INTO TDMBTR1X.
       TDMBTR2 = TDMBTR2 * -1.
    ELSE.
       WRITE TDMBTR2 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
    ENDIF.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'PINDAHAN'
        WINDOW = 'MAIN'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  IF CNTR GE 32.
    NEW-PAGE.
    PAGE2 = PAGE2 + 1.
    TDMBTR2 = TDMBTR + TDMBTR2.
    IF TDMBTR2 < 0.
       TDMBTR2 = TDMBTR2 * -1.
       WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.
       WRITE TDMBTR2 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
       SHIFT TDMBTR1X LEFT DELETING LEADING SPACE.
       CONCATENATE '(' TDMBTR1X ')' INTO TDMBTR1X.
       SHIFT TDMBTR2X LEFT DELETING LEADING SPACE.
       CONCATENATE '(' TDMBTR2X ')' INTO TDMBTR2X.
       TDMBTR2 = TDMBTR2 * -1.
    ELSE.
       WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.
       WRITE TDMBTR2 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
    ENDIF.

    PAGE1 = PAGE1 + 1.
      TDMBTR1 = TDMBTR + TDMBTR1.

    IF CNTR GE 32.
      SPASI = 54 - CNTR.
*      PAGE2 = PAGE2 + 1.
      DO SPASI TIMES.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'KOSONG'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.
      ENDDO.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'LINE'
          WINDOW = 'LINE'
        EXCEPTIONS
          OTHERS = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'PINDAH'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'NEWPAGE'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'PINDAHAN'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.
    ENDIF.
  ENDIF.

  IF TOTAL < 0.
    TOTAL = TOTAL * -1.
    WRITE TOTAL TO TOTAL1  DECIMALS 0 CURRENCY 'IDR'.
    SHIFT TOTAL1 LEFT DELETING LEADING SPACE.
    CONCATENATE '(' TOTAL1 ')' INTO TOTAL1.
  ELSE.
     WRITE TOTAL TO TOTAL1  DECIMALS 0 CURRENCY 'IDR'.
  ENDIF.

  IF FAKTUR1 < 0.
    WRITE FAKTUR1 TO FAKTUR1X  DECIMALS 0 CURRENCY 'IDR' NO-SIGN.
    SHIFT FAKTUR1X LEFT DELETING LEADING SPACE.
    CONCATENATE '(' FAKTUR1X ')' INTO FAKTUR1X.
  ELSE.
     WRITE FAKTUR1 TO FAKTUR1X  DECIMALS 0 CURRENCY 'IDR'.
  ENDIF.

  IF FAKTUR2 < 0.
    WRITE FAKTUR2 TO FAKTUR2X  DECIMALS 0 CURRENCY 'IDR' NO-SIGN.
    SHIFT FAKTUR2X LEFT DELETING LEADING SPACE.
    CONCATENATE '(' FAKTUR2X ')' INTO FAKTUR2X.
  ELSE.
     WRITE FAKTUR2 TO FAKTUR2X  DECIMALS 0 CURRENCY 'IDR'.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'FOOTER'
      WINDOW = 'FOOTER'
    EXCEPTIONS
     OTHERS = 1.

 CALL FUNCTION 'CLOSE_FORM'.
endform.                    " CETAKA2

*&---------------------------------------------------------------------*
*&      Form  GET_DATAA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_DATAA2.
  DATA: L_BUTXT     LIKE T001-BUTXT,
        L_NPWP      LIKE ZFTAX-NPWP,
        L_NPPKP     LIKE ZFTAX-NPPKP,
        L_PKDAT     LIKE ZFTAX-PKDAT.

  clear I_ITABA2.
  SELECT *
    FROM ZFVATA2
    INTO CORRESPONDING FIELDS OF TABLE I_ITABA2
     WHERE BUKRS EQ PA_BUKRS AND
           GSBER EQ PA_GSBER AND
           GJAHR EQ PA_GJAHR AND
           MONAT EQ PA_MONAT.

  CLEAR: WA_ITABA2.
  LOOP AT I_ITABA2 INTO WA_ITABA2.

    SELECT SINGLE NPWP NPPKP PKDAT
      FROM ZFTAX
      INTO (L_NPWP, L_NPPKP, L_PKDAT)
      WHERE BUKRS EQ PA_BUKRS AND
            GSBER EQ PA_GSBER.

    SELECT SINGLE BUTXT
      FROM T001
      INTO L_BUTXT
      WHERE BUKRS EQ WA_ITABA2-BUKRS.

    MOVE L_BUTXT  TO WA_ITABA2-BUTXT.
    MOVE L_NPWP   TO WA_ITABA2-NPWP.
    MOVE L_NPPKP  TO WA_ITABA2-NPPKP.
    MOVE L_PKDAT  TO WA_ITABA2-PKDAT.

    MOVE L_BUTXT  TO BUTXT.
    MOVE L_NPWP   TO NPWP.
    MOVE L_NPPKP  TO NPPKP.
    MOVE L_PKDAT  TO PKDAT.
    MODIFY I_ITABA2 FROM WA_ITABA2.

    CLEAR: WA_ITABA2, L_BUTXT.
  ENDLOOP.
endform.                    " GET_DATAA2

*&---------------------------------------------------------------------*
*&      Form  HITUNGA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form HITUNGA2.
  SORT I_ITABA2 BY TBELN.
  CLEAR: FAKTUR1, FAKTUR3, WA_ITABA2.
  LOOP AT I_ITABA2 INTO WA_ITABA2.
    IF WA_ITABA2-SHKZG NE SPACE.
      ADD 1 TO CNTR1.

      IF WA_ITABA2-SHKZG = 'S'.
        TOTAL = TOTAL - WA_ITABA2-DMBTR.
      ELSE.
        ADD WA_ITABA2-DMBTR TO TOTAL.
      ENDIF.
    ENDIF.
    CLEAR: WA_ITABA2.
  ENDLOOP.

  JUMLAH = FAKTUR1.
  WRITE TOTAL  TO TOTAL1 DECIMALS 0 CURRENCY 'IDR'.
  WRITE JUMLAH TO JUMLAH1 DECIMALS 0 CURRENCY 'IDR'.
endform.                    " HITUNGA2
