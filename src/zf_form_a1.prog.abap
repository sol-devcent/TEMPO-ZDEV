*----------------------------------------------------------------------*
*   INCLUDE ZF_FORM_A1                                                 *
*----------------------------------------------------------------------*
************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZFF_FORM_A1                                        *
*  PROGRAM DESC  :  A1  FORM                                           *
*  CREATED BY    :  DIDIK IMAWAN                                       *
*  CREATED ON    :  22/07/2002 (DD/MM/YY)                              *
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
*REPORT ZFF_FORM_A1  NO STANDARD PAGE HEADING
*                    LINE-COUNT 63(7).

FORM f_cetak_a1.
  nou = 0.
  cntr = 0.
  cntr1 = 0.
  page = 1.
  PERFORM get_data.
  PERFORM hitung.
  IF cntr1 > 0.
    PERFORM cetak.
  ELSE.
*       message i000(zf) with 'Data Not Found'.
    PERFORM get_header_a1.
    PERFORM cetak1.
  ENDIF.

ENDFORM.                                                    "F_CETAK_A1
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  DATA: l_butxt     LIKE t001-butxt,
        l_npwp      LIKE zftax-npwp,
        l_nppkp     LIKE zftax-nppkp,
        l_pkdat     LIKE zftax-pkdat.
  CLEAR i_itaba1.
  SELECT *
    FROM zfvata1
    INTO CORRESPONDING FIELDS OF TABLE i_itaba1
     WHERE bukrs EQ pa_bukrs AND
           gsber EQ pa_gsber AND
           gjahr EQ pa_gjahr AND
           monat EQ pa_monat.

  CLEAR: wa_itaba1.
  LOOP AT i_itaba1 INTO wa_itaba1.

    SELECT SINGLE npwp nppkp pkdat
      FROM zftax
      INTO (l_npwp, l_nppkp, l_pkdat)
      WHERE bukrs EQ pa_bukrs AND
            gsber EQ pa_gsber.

    SELECT SINGLE butxt
      FROM t001
      INTO l_butxt
      WHERE bukrs EQ wa_itaba1-bukrs.

    MOVE l_butxt  TO wa_itaba1-butxt.
    MOVE l_npwp   TO wa_itaba1-npwp.
    MOVE l_nppkp  TO wa_itaba1-nppkp.
    MOVE l_pkdat  TO wa_itaba1-pkdat.

    MOVE l_npwp   TO npwp.
    MOVE l_nppkp  TO nppkp.
    MOVE l_pkdat  TO pkdat.
    MOVE l_butxt  TO butxt.
    MODIFY i_itaba1 FROM wa_itaba1.

    CLEAR: wa_itaba1, l_butxt.
  ENDLOOP.

  IF pa_bukrs EQ '8020' OR pa_bukrs = '8380'.
    SELECT *
      FROM zfvata3
      INTO CORRESPONDING FIELDS OF TABLE i_itaba3
       WHERE bukrs EQ pa_bukrs AND
             gsber EQ pa_gsber AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat.

    CLEAR: wa_itaba3.
    LOOP AT i_itaba3 INTO wa_itaba3.

      SELECT SINGLE npwp nppkp pkdat
        FROM zftax
        INTO (l_npwp, l_nppkp, l_pkdat)
        WHERE bukrs EQ pa_bukrs AND
              gsber EQ pa_gsber.

      SELECT SINGLE butxt
        FROM t001
        INTO l_butxt
        WHERE bukrs EQ wa_itaba3-bukrs.

      MOVE l_butxt  TO wa_itaba3-butxt.
      MOVE l_npwp   TO wa_itaba3-npwp.
      MOVE l_nppkp  TO wa_itaba3-nppkp.
      MOVE l_pkdat  TO wa_itaba3-pkdat.

      MOVE l_npwp   TO npwp.
      MOVE l_nppkp  TO nppkp.
      MOVE l_pkdat  TO pkdat.
      MOVE l_butxt  TO butxt.
      MODIFY i_itaba3 FROM wa_itaba3.
      CLEAR: wa_itaba3, l_butxt.
    ENDLOOP.

    CLEAR: wa_itaba3, wa_itaba1.
    LOOP AT i_itaba3 INTO wa_itaba3.
      IF wa_itaba3-zstatus NE space.
        MOVE-CORRESPONDING wa_itaba3 TO wa_itaba1.
        APPEND wa_itaba1 TO i_itaba1.
      ENDIF.
      CLEAR: wa_itaba3, wa_itaba1.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  HITUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung.
  CLEAR: faktur2, jumlah.
  SELECT *
    FROM zfvata3
    INTO CORRESPONDING FIELDS OF TABLE i_itaba3
       WHERE bukrs EQ pa_bukrs AND
           gsber EQ pa_gsber AND
           gjahr EQ pa_gjahr AND
           monat EQ pa_monat.

  CLEAR: wa_itaba3.
  LOOP AT i_itaba3 INTO wa_itaba3.
    IF wa_itaba3-shkzg EQ 'H'.
      ADD wa_itaba3-dmbtr TO faktur2.
    ELSE.
      faktur2 = faktur2 - wa_itaba3-dmbtr.
    ENDIF.
    CLEAR: wa_itaba3.
  ENDLOOP.

*  LOOP AT ITAB_VAT3 INTO WATAB_VAT3.
*    ADD WATAB_VAT3-DMBTR TO FAKTUR2.
*  ENDLOOP.
*  FAKTUR2 = FAKTUR2 * 100.

  SORT i_itaba1 BY tbeln.
  CLEAR: faktur1, faktur3, wa_itaba1.
  LOOP AT i_itaba1 INTO wa_itaba1.
    IF wa_itaba1-shkzg NE space.
      ADD 1 TO cntr1.

      IF wa_itaba1-shkzg = 'S'.
        wa_itaba1-dmbtr = wa_itaba1-dmbtr * -1.
      ENDIF.

      CASE wa_itaba1-zstatus.
        WHEN '11'.
          faktur1 = faktur1 + wa_itaba1-dmbtr.
*        WHEN '13'.
*            FAKTUR3 = FAKTUR3 + WA_ITABA1-DMBTR.
      ENDCASE.
    ENDIF.
    CLEAR: wa_itaba1.
  ENDLOOP.

  WRITE faktur1 TO faktur1x  DECIMALS 0 CURRENCY 'IDR'.
  WRITE faktur2 TO faktur2x  DECIMALS 0 CURRENCY 'IDR'.
*  write faktur3 to faktur3x  decimals 0 currency 'IDR'.
ENDFORM.                    " HITUNG

*&---------------------------------------------------------------------*
*&      Form  CETAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak.
  DATA: jml_debet LIKE zfvata1-dmbtr,
        jml_credit LIKE zfvata1-dmbtr.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form   = 'ZF_A1_FORM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER4'
      window  = 'HEADER4'
    EXCEPTIONS
      OTHERS  = 1.

  IF cntr1 > 35.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'LINE'
        window  = 'LINE'
      EXCEPTIONS
        OTHERS  = 1.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'LINE1'
        window  = 'LINE'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  CLEAR: wa_itaba1, tdmbtr, tdmbtr1, tdmbtr2, jumlah1, jumlah2, jumlah,
         jml_debet, jml_credit.

* SHKZG DESCENDING, TBELN & TXDAT ASCENDING
  SORT i_itaba1 BY zstatus DESCENDING tbeln txdat.
*SHKZG DESCENDING
*TBELN.
  tdmbtr2 = faktur2 + faktur1.
  LOOP AT i_itaba1 INTO wa_itaba1.
    IF wa_itaba1-shkzg NE space.
      MOVE wa_itaba1-name1  TO name1.
      MOVE wa_itaba1-stceg  TO stceg.
      MOVE wa_itaba1-tbeln  TO tbeln.
      MOVE wa_itaba1-txdat  TO txdat.

      CASE wa_itaba1-zstatus.
        WHEN '11'.
*            FAKTUR1 = FAKTUR1 + WA_ITABA1-DMBTR.
          CONTINUE.
        WHEN '13'.
          IF wa_itaba1-shkzg = 'S'.
            jml_credit = jml_credit + wa_itaba1-dmbtr.
            WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr DECIMALS 0.
            SHIFT dmbtr LEFT DELETING LEADING space.
            CONCATENATE '(' dmbtr ')' INTO dmbtr1.
*                        SEPARATED BY SPACE.
            wa_itaba1-dmbtr = wa_itaba1-dmbtr * -1.
          ELSE.
            jml_debet = jml_debet + wa_itaba1-dmbtr.
            WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr1 DECIMALS 0.
          ENDIF.

        WHEN '17'.
          IF wa_itaba1-shkzg = 'S'.
            jml_credit = jml_credit + wa_itaba1-dmbtr.
            WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr DECIMALS 0.
            SHIFT dmbtr LEFT DELETING LEADING space.
            CONCATENATE '(' dmbtr ')' INTO dmbtr1.
*                        SEPARATED BY SPACE.
            wa_itaba1-dmbtr = wa_itaba1-dmbtr * -1.
          ELSE.
            jml_debet = jml_debet + wa_itaba1-dmbtr.
            WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr1 DECIMALS 0.
          ENDIF.

        WHEN '30'.
          WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr DECIMALS 0.
          SHIFT dmbtr LEFT DELETING LEADING space.
          CONCATENATE '(' dmbtr ')' INTO dmbtr1.
*                     SEPARATED BY SPACE.
        WHEN '31'.
          WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr DECIMALS 0.
          SHIFT dmbtr LEFT DELETING LEADING space.
          CONCATENATE '(' dmbtr ')' INTO dmbtr1.
*                     SEPARATED BY SPACE.
        WHEN '32'.
          WRITE wa_itaba1-dmbtr CURRENCY 'IDR' TO dmbtr DECIMALS 0.
          SHIFT dmbtr LEFT DELETING LEADING space.
          CONCATENATE '(' dmbtr ')' INTO dmbtr1.
*                     SEPARATED BY SPACE.
      ENDCASE.

*      Jumlah = Jumlah + WA_ITABA1-DMBTR.
*      write WA_ITABA1-DMBTR currency 'IDR' TO DMBTR decimals 0.
      MOVE wa_itaba1-npwp   TO npwp.
      MOVE wa_itaba1-nppkp  TO nppkp.

      IF page GT 1 AND
        cntr EQ 0.
        page1 = page - 1.
        tdmbtr1 = tdmbtr2.
        WRITE tdmbtr1 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
        IF tdmbtr1 < 0.
          tdmbtr1 = tdmbtr1 * -1.
          WRITE tdmbtr1 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
          SHIFT tdmbtr1x LEFT DELETING LEADING space.
          CONCATENATE '(' tdmbtr1x ')' INTO tdmbtr1x.
*              SEPARATED BY SPACE.
          tdmbtr1 = tdmbtr1 * -1.
        ELSE.
          WRITE tdmbtr1 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
        ENDIF.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'PINDAHAN'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
        ADD 1 TO cntr.
      ENDIF.

      IF page EQ 1 AND
        nou = 0.
* 14/07/2004
*          TDMBTR = TDMBTR + FAKTUR1.
        tdmbtr = tdmbtr.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'KOSONG'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
        ADD 1 TO cntr.
      ENDIF.

      ADD 1 TO nou.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'DETAIL'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.

      ADD 1 TO cntr.
      ADD 1 TO cntr2.

      IF wa_itaba1-zstatus = '11' OR
         wa_itaba1-zstatus = '12' OR
         wa_itaba1-zstatus = '13' OR
         wa_itaba1-zstatus = '17'.
        tdmbtr = tdmbtr + wa_itaba1-dmbtr.
      ELSE.
        tdmbtr = tdmbtr + 0.
      ENDIF.
*        Jumlah = Jumlah + WA_ITABA1-DMBTR.

      IF cntr  EQ 51 AND
         cntr2 NE cntr1.
        ADD 1 TO page.
        page2 = page.
        page3 = page - 1.

        IF page3 EQ 1.
*            MOVE TDMBTR TO TDMBTR2.
          tdmbtr2 = faktur2 + faktur1 + tdmbtr.
        ELSE.
          tdmbtr2 = tdmbtr + tdmbtr2.
        ENDIF.

        IF pa_bukrs = '8020' OR pa_bukrs = '8380'.
          IF tdmbtr2 < 0.
            tdmbtr2 = tdmbtr2 * -1.
            WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
            SHIFT tdmbtr2x LEFT DELETING LEADING space.
            CONCATENATE '(' tdmbtr2x ')' INTO tdmbtr2x.
*               SEPARATED BY SPACE.
            tdmbtr2 = tdmbtr2 * -1.
          ELSE.
            WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
          ENDIF.
        ELSE.
*            TDMBTR2 = TDMBTR2 + FAKTUR2 + FAKTUR1.
          IF tdmbtr2 < 0.
            tdmbtr2 = tdmbtr2 * -1.
            WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
            SHIFT tdmbtr2x LEFT DELETING LEADING space.
            CONCATENATE '(' tdmbtr2x ')' INTO tdmbtr2x.
*                 SEPARATED BY SPACE.
            tdmbtr2 = tdmbtr2 * -1.
          ELSE.
            WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
          ENDIF.
        ENDIF.

        CLEAR: tdmbtr.
        cntr = 0.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'KOSONG'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'PINDAH'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      ENDIF.

      CLEAR: wa_itaba1.
    ENDIF.
  ENDLOOP.

  IF cntr EQ 0 AND
     cntr2 NE 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'NEWPAGE'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

    IF tdmbtr2 < 0.
      tdmbtr2 = tdmbtr2 * -1.
      WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
      SHIFT tdmbtr1x LEFT DELETING LEADING space.
      CONCATENATE '(' tdmbtr1x ')' INTO tdmbtr1x.
*       SEPARATED BY SPACE.
      tdmbtr2 = tdmbtr2 * -1.
    ELSE.
      WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
    ENDIF.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'PINDAHAN'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  IF cntr GE 32.
    NEW-PAGE.
    page2 = page2 + 1.
    tdmbtr2 = tdmbtr + tdmbtr2.
    IF pa_bukrs = '8020' OR pa_bukrs = '8380'.
      IF tdmbtr2 < 0.
        tdmbtr2 = tdmbtr2 * -1.
        WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
        WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
        SHIFT tdmbtr1x LEFT DELETING LEADING space.
        CONCATENATE '(' tdmbtr1x ')' INTO tdmbtr1x.
*           SEPARATED BY SPACE.
        tdmbtr2 = tdmbtr2 * -1.
        SHIFT tdmbtr2x LEFT DELETING LEADING space.
        CONCATENATE '(' tdmbtr2x ')' INTO tdmbtr2x.
*           SEPARATED BY SPACE.
        tdmbtr2 = tdmbtr2 * -1.
      ELSE.
        WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
        WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
      ENDIF.
    ELSE.
      tdmbtr2 = tdmbtr2 + faktur2 + faktur1.
      IF tdmbtr2 < 0.
        tdmbtr2 = tdmbtr2 * -1.
        WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
        WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
        SHIFT tdmbtr1x LEFT DELETING LEADING space.
        CONCATENATE '(' tdmbtr1x ')' INTO tdmbtr1x.
*           SEPARATED BY SPACE.
        SHIFT tdmbtr2x LEFT DELETING LEADING space.
        CONCATENATE '(' tdmbtr2x ')' INTO tdmbtr2x.
*           SEPARATED BY SPACE.
        tdmbtr2 = tdmbtr2 * -1.
      ELSE.
        WRITE tdmbtr2 TO tdmbtr2x DECIMALS 0 CURRENCY 'IDR'.
        WRITE tdmbtr2 TO tdmbtr1x DECIMALS 0 CURRENCY 'IDR'.
      ENDIF.
    ENDIF.

    page1 = page1 + 1.
    tdmbtr1 = tdmbtr + tdmbtr1.

    IF cntr GE 33.
      spasi = 52 - cntr.
      page3 = page3 + 1.
      DO spasi TIMES.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'KOSONG'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      ENDDO.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'LINE'
          window  = 'LINE'
        EXCEPTIONS
          OTHERS  = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'PINDAH'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'NEWPAGE'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'PINDAHAN'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
    ENDIF.
  ENDIF.

  IF pa_bukrs = '8020' OR pa_bukrs = '8380'.
    faktur3 = jml_debet - faktur2.
    faktur5 = jml_credit.

    faktur4 = faktur1 + faktur2 + faktur3.
    faktur6 = faktur4 - faktur5.
  ELSE.
    faktur3 = jml_debet.
    faktur5 = jml_credit.

    faktur4 = faktur1 + faktur2 + faktur3.
    faktur6 = faktur4 - faktur5.
  ENDIF.

  WRITE faktur1 TO faktur1x  DECIMALS 0 CURRENCY 'IDR'.
  WRITE faktur2 TO faktur2x  DECIMALS 0 CURRENCY 'IDR'.
  WRITE faktur3 TO faktur3x  DECIMALS 0 CURRENCY 'IDR'.
  WRITE faktur4 TO faktur4x  DECIMALS 0 CURRENCY 'IDR'.

  IF faktur6 < 0.
    faktur6 = faktur6 * -1.
    WRITE faktur6 TO faktur6x  DECIMALS 0 CURRENCY 'IDR'.
    SHIFT faktur6x LEFT DELETING LEADING space.
    CONCATENATE '(' faktur6x ')' INTO faktur6x.
*      SEPARATED BY SPACE.
    faktur6 = faktur6 * -1.
  ELSE.
    WRITE faktur6 TO faktur6x  DECIMALS 0 CURRENCY 'IDR'.
  ENDIF.

  IF faktur5 IS INITIAL.
    faktur5x = '0'.
  ELSE.
    WRITE faktur5 TO faktur5x  DECIMALS 0 CURRENCY 'IDR'.
    SHIFT faktur5x LEFT DELETING LEADING space.
    CONCATENATE '(' faktur5x ')' INTO faktur5x.
*       SEPARATED BY SPACE.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'FOOTER'
      window  = 'FOOTER'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " CETAK

*&---------------------------------------------------------------------*
*&      Form  CETAK1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak1.
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form   = 'ZF_A1_FORM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER4'
      window  = 'HEADER4'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'LINE1'
      window  = 'LINE'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NIHIL'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'FOOTER1'
      window  = 'FOOTER1'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                                                    " CETAK1

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_A1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header_a1.
  DATA: l_butxt     LIKE t001-butxt,
        l_npwp      LIKE zftax-npwp,
        l_nppkp     LIKE zftax-nppkp,
        l_pkdat     LIKE zftax-pkdat.

  SELECT SINGLE npwp nppkp pkdat
    FROM zftax
    INTO (l_npwp, l_nppkp, l_pkdat)
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber.

  SELECT SINGLE butxt
    FROM t001
    INTO l_butxt
    WHERE bukrs EQ pa_bukrs.

  MOVE l_butxt  TO butxt.
  MOVE l_npwp   TO npwp.
  MOVE l_nppkp  TO nppkp.
  MOVE l_pkdat  TO pkdat.
ENDFORM.                    " GET_HEADER_A1
