*----------------------------------------------------------------------*
*   INCLUDE ZF_FORM_A3                                                 *
*----------------------------------------------------------------------*
FORM F_CETAK_A3.
    NOU = 0.
    CNTR = 0.
    CNTR1 = 0.
    PAGE = 1.
    PERFORM GET_DATAA3.
    PERFORM HITUNGA3.
    if CNTR1 > 0.
       PERFORM CETAKA3.
    Else.
       PERFORM GET_HEADER_A3.
       PERFORM CETAKA3_1.
*       message i000(zf) with 'Data Not Found'.
    endif.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATAA3.

  DATA: L_BUTXT     LIKE T001-BUTXT,
        L_NPWP      LIKE ZFTAX-NPWP,
        L_NPPKP     LIKE ZFTAX-NPPKP,
        L_PKDAT     LIKE ZFTAX-PKDAT.

  clear I_ITABA3.
  SELECT *
    FROM ZFVATA3
    INTO CORRESPONDING FIELDS OF TABLE I_ITABA3
     WHERE BUKRS EQ PA_BUKRS AND
           GSBER EQ PA_GSBER AND
           GJAHR EQ PA_GJAHR AND
           MONAT EQ PA_MONAT.

  CLEAR: WA_ITABA3.
  LOOP AT I_ITABA3 INTO WA_ITABA3.

    SELECT SINGLE NPWP NPPKP PKDAT
      FROM ZFTAX
      INTO (L_NPWP, L_NPPKP, L_PKDAT)
      WHERE BUKRS EQ PA_BUKRS AND
            GSBER EQ PA_GSBER.

    SELECT SINGLE BUTXT
      FROM T001
      INTO L_BUTXT
      WHERE BUKRS EQ WA_ITABA3-BUKRS.

    MOVE L_BUTXT  TO WA_ITABA3-BUTXT.
    MOVE L_NPWP   TO WA_ITABA3-NPWP.
    MOVE L_NPPKP  TO WA_ITABA3-NPPKP.
    MOVE L_PKDAT  TO WA_ITABA3-PKDAT.

    MOVE L_BUTXT  TO BUTXT.
    MOVE L_NPWP   TO NPWP.
    MOVE L_NPPKP  TO NPPKP.
    MOVE L_PKDAT  TO PKDAT.
    MODIFY I_ITABA3 FROM WA_ITABA3.

    CLEAR: WA_ITABA3, L_BUTXT.
  ENDLOOP.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  HITUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HITUNGA3.

  CLEAR: WA_ITABA3, FAKTUR1, FAKTUR2, CNTR1.
  LOOP AT I_ITABA3 INTO WA_ITABA3.
    ADD 1 TO CNTR1.
    IF WA_ITABA3-SHKZG EQ 'H'.
      ADD WA_ITABA3-DMBTR TO TOTAL.
    ELSE.
      TOTAL = TOTAL - WA_ITABA3-DMBTR.
    ENDIF.

    CASE WA_ITABA3-ZSTATUS..
      WHEN '31'.
      IF WA_ITABA3-SHKZG EQ 'H'.
        ADD WA_ITABA3-DMBTR TO FAKTUR1.
      ELSE.
        FAKTUR1 = FAKTUR1 - WA_ITABA3-DMBTR.
      ENDIF.

      WHEN '32'.
      IF WA_ITABA3-SHKZG EQ 'H'.
        ADD WA_ITABA3-DMBTR TO FAKTUR2.
      ELSE.
        FAKTUR2 = FAKTUR2 - WA_ITABA3-DMBTR.
      ENDIF.

      WHEN OTHERS.
      IF WA_ITABA3-SHKZG EQ 'H'.
        ADD WA_ITABA3-DMBTR TO FAKTUR2.
      ELSE.
        FAKTUR2 = FAKTUR2 - WA_ITABA3-DMBTR.
      ENDIF.

    ENDCASE.

    JUMLAH = FAKTUR1 + FAKTUR2.
    CLEAR: WA_ITABA3.
  ENDLOOP.
  WRITE TOTAL TO TOTAL1 DECIMALS 0 CURRENCY 'IDR'.
  WRITE JUMLAH TO JUMLAH1 DECIMALS 0 CURRENCY 'IDR'.

ENDFORM.                    " HITUNG

*&---------------------------------------------------------------------*
*&      Form  CETAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CETAKA3.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZF_A3_FORM'
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
      ELEMENT = 'GARIS'
        WINDOW = 'MAIN'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LINE'
      WINDOW = 'LINE'
    EXCEPTIONS
      OTHERS = 1.

  CLEAR: WA_ITABA3.
  SORT I_ITABA3 BY NAME1 TBELN TXDAT STCEG.
  LOOP AT I_ITABA3 INTO WA_ITABA3.
    MOVE WA_ITABA3-NAME1 TO NAME1.
    MOVE WA_ITABA3-STCEG TO STCEG.
    MOVE WA_ITABA3-TBELN TO TBELN.
    MOVE WA_ITABA3-TXDAT TO TXDAT.
*    WRITE WA_ITABA3-DMBTR TO DMBTR DECIMALS 0 CURRENCY 'IDR'.
    MOVE WA_ITABA3-NPWP  TO NPWP.
    MOVE WA_ITABA3-NPPKP TO NPPKP.

    IF WA_ITABA3-SHKZG EQ 'S'.
      WRITE WA_ITABA3-DMBTR currency 'IDR' TO DMBTRA DECIMALS 0.
      SHIFT DMBTRA LEFT DELETING LEADING SPACE.
      CONCATENATE '(' DMBTRA ')' INTO DMBTR3.
      write dmbtr3 to dmbtr3 right-justified.
    ELSE.
        WRITE WA_ITABA3-DMBTR currency 'IDR' TO DMBTR3 DECIMALS 0.
    ENDIF.

    CASE WA_ITABA3-ZSTATUS..
      WHEN '31'.
      WRITE 'TERIMA' TO STATUS.

      WHEN '32'.
      WRITE 'BELUM' TO STATUS.

      WHEN OTHERS.
      WRITE ' ' TO STATUS.
    ENDCASE.

    IF PAGE GT 1 AND
      CNTR EQ 0.
      PAGE1 = PAGE - 1.
      TDMBTR1 = TDMBTR2.
      WRITE TDMBTR1 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.
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
          ELEMENT = 'KOSONG1'
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

    IF WA_ITABA3-SHKZG EQ 'H'.
      ADD WA_ITABA3-DMBTR TO TDMBTR.
    ELSE.
      TDMBTR = TDMBTR - WA_ITABA3-DMBTR.
    ENDIF.

*    IF CNTR GE 33 AND
*       CNTR LE 50.
*      CALL FUNCTION 'WRITE_FORM'
*        EXPORTING
*          ELEMENT = 'LINE'
*          WINDOW = 'MAIN'
*        EXCEPTIONS
*          OTHERS = 1.
*    ENDIF.

    IF CNTR EQ 51 AND
       CNTR2 NE CNTR1.
      ADD 1 TO PAGE.
      PAGE2 = PAGE.
      PAGE3 = PAGE - 1.

      IF PAGE3 EQ 1.
        MOVE TDMBTR TO TDMBTR2.
      ELSE.
        TDMBTR2 = TDMBTR + TDMBTR2.
      ENDIF.

      WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.
      CLEAR: TDMBTR, CNTR.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'KOSONG'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'PINDAH'
          WINDOW = 'MAIN'
        EXCEPTIONS
          OTHERS = 1.
    ENDIF.
    CLEAR: WA_ITABA3.
  ENDLOOP.

  WRITE FAKTUR1 TO FKTR1 DECIMALS 0 CURRENCY 'IDR'.
  WRITE FAKTUR2 TO FKTR2 DECIMALS 0 CURRENCY 'IDR'.
  WRITE FAKTUR3 TO FKTR3 DECIMALS 0 CURRENCY 'IDR'.

  IF CNTR GE 35.
    CLEAR: FKTR1, FKTR2, FKTR3.
    NEW-PAGE.
    PAGE2 = PAGE2 + 1.
    TDMBTR2 = TDMBTR + TDMBTR2.
    WRITE TDMBTR2 TO TDMBTR2X DECIMALS 0 CURRENCY 'IDR'.

    IF CNTR LT 51.
      SPASI = 50 - CNTR.
      DO SPASI TIMES.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            ELEMENT = 'KOSONG'
            WINDOW = 'MAIN'
          EXCEPTIONS
            OTHERS = 1.
      ENDDO.
    ENDIF.

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

    WRITE FAKTUR1 TO FKTR1 DECIMALS 0 CURRENCY 'IDR'.
    WRITE FAKTUR2 TO FKTR2 DECIMALS 0 CURRENCY 'IDR'.
    WRITE FAKTUR3 TO FKTR3 DECIMALS 0 CURRENCY 'IDR'.

    PAGE1 = PAGE1 + 1.
    TDMBTR1 = TDMBTR + TDMBTR1.
    WRITE TDMBTR1 TO TDMBTR1X DECIMALS 0 CURRENCY 'IDR'.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'PINDAHAN'
        WINDOW = 'MAIN'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'FOOTER'
      WINDOW = 'FOOTER'
    EXCEPTIONS
     OTHERS = 1.

 CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " CETAK

*&---------------------------------------------------------------------*
*&      Form  CETAKA3_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CETAKA3_1.
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZF_A3_FORM'
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

ENDFORM.                    " CETAKA3_1

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_A3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_HEADER_A3.
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
ENDFORM.                    " GET_HEADER_A3
