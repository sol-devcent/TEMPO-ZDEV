**INCLUDE ZFF_VAT_RETURN_PRINT_KG .

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_BSAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header_bsas.
  DATA: l_lifnr LIKE bsik-lifnr,
        l_gsber LIKE bsik-gsber,
        l_augbl(2),
        l_anred LIKE lfa1-anred,
        l_name1 LIKE lfa1-name1,
        l_name2 LIKE lfa1-name2,
        l_adrnr LIKE lfa1-adrnr,
        l_stras LIKE lfa1-stras,
        l_ort01 LIKE lfa1-ort01,
        l_stcd1 LIKE lfa1-stcd1,
        l_stceg LIKE lfa1-stceg,
        l_zuonr LIKE rbkp-zuonr,
        l_bktxt LIKE rbkp-bktxt,
        l_street LIKE adrc-street,
        l_house_num1 LIKE adrc-house_num1.

  CLEAR: va_bukrs, va_belnr, va_gjahr.

  SELECT bukrs hkont gjahr belnr augbl budat bldat
         waers xblnr blart monat shkzg bschl mwskz
         dmbtr zfbdt sgtxt
    FROM bsas
    INTO CORRESPONDING FIELDS OF TABLE i_itab1
    WHERE bukrs = p_bukrs      AND
          hkont = '0142200200' AND
          belnr = p_belnr      AND
          gjahr = p_gjahr      AND
          shkzg = 'H'          AND
          blart = 'KG' .

  IF sy-subrc = 0.
    CLEAR wa_itab1.
    LOOP AT i_itab1 INTO wa_itab1.
      MOVE wa_itab1-augbl+1(2) TO l_augbl.
      IF l_augbl <> '91'.
        DELETE i_itab1.
      ENDIF.
      CLEAR wa_itab1.
    ENDLOOP.

    CLEAR wa_itab1.
    LOOP AT i_itab1 INTO wa_itab1.

* GET AWKEY FROM BKPF MOVE TO WA_ITAB1-RBELN
      SELECT SINGLE awkey FROM bkpf
        INTO wa_itab1-awkey
        WHERE belnr = wa_itab1-belnr AND
              blart = wa_itab1-blart AND
              bukrs = p_bukrs        AND
              gjahr = p_gjahr.
      MOVE wa_itab1-awkey+0(10) TO wa_itab1-rbeln.

* GET LIFNR, GSBER FROM BSIK OR BSAK
      CLEAR: l_lifnr, l_gsber.
      SELECT SINGLE lifnr gsber zuonr
        FROM bsik
        INTO (l_lifnr, l_gsber, l_zuonr)
        WHERE belnr = wa_itab1-belnr AND
              bukrs = wa_itab1-bukrs AND
              gjahr = p_gjahr        AND
              blart = 'KG'.
      IF l_gsber = '0' OR
         l_gsber = space.
        SELECT SINGLE lifnr gsber zuonr
          FROM bsak
          INTO (l_lifnr, l_gsber, l_zuonr)
          WHERE belnr = wa_itab1-belnr AND
                bukrs = wa_itab1-bukrs AND
                gjahr = p_gjahr        AND
                blart = 'KG'.
        MOVE l_lifnr TO wa_itab1-lifnr.
        MOVE l_gsber TO wa_itab1-gsber.
        MOVE l_zuonr TO wa_itab1-zuonr1.
      ELSE.
        MOVE l_lifnr TO wa_itab1-lifnr.
        MOVE l_gsber TO wa_itab1-gsber.
        MOVE l_zuonr TO wa_itab1-zuonr1.
      ENDIF.

* GET ANRED, NAME1, NAME2, STRAS, ORT01, STCEG STCD1
****** Ganti kode vendor khusus untuk tsp supaya alamat
****** pake alamat sesuai tax.
      IF wa_itab1-lifnr = 'TSB0102' OR wa_itab1-lifnr = 'TSB0101'.
        l_lifnr = wa_itab1-lifnr.
        wa_itab1-lifnr = 'TSB8010'.
      ENDIF.
****** Endiing ganti .....

      CLEAR: l_anred, l_name1, l_name2, l_adrnr, l_ort01, l_stceg,
             l_stcd1.
      SELECT SINGLE anred name1 name2 adrnr ort01 stceg stcd1 FROM lfa1
        INTO (l_anred, l_name1, l_name2, l_adrnr, l_ort01, l_stceg,
              l_stcd1)
        WHERE lifnr = wa_itab1-lifnr.

      MOVE l_name1 TO wa_itab1-name1.
      MOVE l_name2 TO wa_itab1-name2.
*        MOVE L_STRAS TO WA_ITAB1-STRAS.
      MOVE l_ort01 TO wa_itab1-ort01.
      MOVE l_stcd1 TO wa_itab1-stcd1.
      MOVE l_stceg TO wa_itab1-stceg.

      SELECT SINGLE street house_num1
        FROM adrc
        INTO (l_street, l_house_num1)
        WHERE addrnumber EQ l_adrnr.

      CONCATENATE l_street l_house_num1 INTO wa_itab1-stras
        SEPARATED BY space.

      CONCATENATE l_anred l_name1 l_name2 INTO wa_itab1-sgtxt
        SEPARATED BY space.

* GET BKTXT
      SELECT SINGLE bktxt FROM bkpf
        INTO l_bktxt
        WHERE bukrs = p_bukrs AND
              belnr EQ p_belnr AND
              gjahr EQ p_gjahr.
*            AND   TCODE EQ 'MIRO'. MODIFY 14/10/2002
      MOVE l_bktxt TO wa_itab1-bktxt.

***** Ganti kode vendor kembali.
      IF wa_itab1-lifnr = 'TSB8010'.
        wa_itab1-lifnr = l_lifnr.
      ENDIF.
******

** GET ZUONR
*    SELECT SINGLE ZUONR FROM BSIK
*      INTO L_ZUONR
*      WHERE BUKRS = P_BUKRS AND
**            HKONT in ('0312500100','0312100100',
*            GJAHR = P_GJAHR AND
*            BELNR = P_BELNR AND
*            BLART = 'KG'.
*    MOVE L_ZUONR TO WA_ITAB1-ZUONR1.

      MODIFY i_itab1 FROM wa_itab1.
      MOVE wa_itab1-lifnr TO va_lifnr.
      MOVE wa_itab1-blart TO va_blart.
      MOVE wa_itab1-budat TO va_date.
      CLEAR wa_itab1.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " GET_HEADER_BSAS

*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_BSAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_detail_bsas.

  counter = 0.
  counter1 = 0.
*{   REPLACE        P01K910178                                        1
*\  SELECT belnr gjahr ebelp buzei matnr menge wrbtr rbwwr rbmng "BPRBM
*\    FROM rseg
*\    INTO CORRESPONDING FIELDS OF TABLE i_itab2
*\    WHERE belnr = wa_itab1-rbeln AND
*\          gjahr = wa_itab1-gjahr AND
*\          bukrs = p_bukrs        AND
*\          ( rbmng <> '0' OR rbmng <> space ).
  "Start SOH: Shell SCI Adjustment 20240221 KRS
  SELECT belnr gjahr ebelp buzei matnr menge wrbtr rbwwr rbmng "BPRBM
    FROM rseg
    INTO CORRESPONDING FIELDS OF TABLE i_itab2
    WHERE belnr = wa_itab1-rbeln AND
          gjahr = wa_itab1-gjahr AND
          bukrs = p_bukrs        AND
          ( rbmng <> '0' OR rbmng <> space ) ORDER BY PRIMARY KEY.
   "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
  IF sy-subrc = 0.
    CLEAR: wa_itab2, va_amnt, va_ppn.
    LOOP AT i_itab2 INTO wa_itab2.
      SELECT SINGLE maktx FROM makt
        INTO wa_itab2-maktx
        WHERE matnr = wa_itab2-matnr.
*            WA_ITAB2-AMNT = WA_ITAB2-WRBTR * -1.
*            WA_ITAB2-QUANT = WA_ITAB2-BPRBM - WA_ITAB2-MENGE.

      wa_itab2-amnt  = wa_itab2-rbwwr - wa_itab2-wrbtr.
      MODIFY i_itab2 FROM wa_itab2.
      ADD wa_itab2-amnt TO va_amnt.
      ADD wa_itab2-amnt TO va_amnt1.
      ADD wa_itab2-amnt TO va_amnt2.

      WRITE wa_itab2-maktx TO maktx.

*---------- B001 ----------
*          ADD 1 TO COUNTER.
*          ADD 1 TO COUNTER1.
*--------------------------
      AT END OF matnr.
*---------- B001 ----------
        ADD 1 TO counter.
        ADD 1 TO counter1.
*--------------------------
        ADD 1 TO ebelp.
        PERFORM cetak_detail USING '' ''.
        CLEAR va_amnt2.
      ENDAT.

      AT END OF belnr.
        va_amnt = va_amnt * 100.
        va_dpp = va_amnt.

        PERFORM f_tax_calc USING va_date va_amnt 'E'
                           CHANGING va_ppn.

*        va_ppn = ( 10 / 100 ) * va_amnt.

        WRITE va_amnt TO amnt1 DECIMALS 0.
        WRITE va_dpp  TO dpp DECIMALS 0.
        WRITE va_ppn  TO ppn DECIMALS 0.

        CLEAR wa_itab1.
        READ TABLE i_itab1 INTO wa_itab1 INDEX 1.
        IF sy-subrc = 0.
          WRITE wa_itab1-dmbtr TO ppn CURRENCY wa_itab1-waers.
        ENDIF.
      ENDAT.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL'
          window  = 'TOTAL'
        EXCEPTIONS
          OTHERS  = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL1'
          window  = 'TOTAL1'
        EXCEPTIONS
          OTHERS  = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL2'
          window  = 'TOTAL2'
        EXCEPTIONS
          OTHERS  = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL3'
          window  = 'TOTAL3'
        EXCEPTIONS
          OTHERS  = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL4'
          window  = 'TOTAL4'
        EXCEPTIONS
          OTHERS  = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL5'
          window  = 'TOTAL5'
        EXCEPTIONS
          OTHERS  = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'FOOTER1'
        EXCEPTIONS
          OTHERS = 1.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'FOOTER2'
        EXCEPTIONS
          OTHERS = 1.

      IF cntr1 LT cntr.
        ADD 1 TO page1.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'SKIP'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
        CLEAR: va_amnt, va_ppn, va_amnt1,
               amnt2, amnt1, amnt3,ppn.
      ENDIF.
*          ENDAT.

      CLEAR wa_itab2.
    ENDLOOP.
  ENDIF.
  CLEAR counter.
*      ADD 1 TO PAGE1.
*      CALL FUNCTION 'CLOSE_FORM'.
ENDFORM.                    " GET_DETAIL_BSAS
