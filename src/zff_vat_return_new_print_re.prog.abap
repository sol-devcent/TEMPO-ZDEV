***INCLUDE ZFF_VAT_RETURN_PRINT_RE .

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_BSAS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header_bsas1.
  DATA: l_lifnr      LIKE bsik-lifnr,
        l_gsber      LIKE bsik-gsber,
        l_augbl(2),
        l_anred      LIKE lfa1-anred,
        l_name1      LIKE lfa1-name1,
        l_name2      LIKE lfa1-name2,
        l_adrnr      LIKE lfa1-adrnr,
        l_stras      LIKE lfa1-stras,
        l_ort01      LIKE lfa1-ort01,
        l_stcd1      LIKE lfa1-stcd1,
        l_zuonr      LIKE rbkp-zuonr,
        l_bktxt      LIKE rbkp-bktxt,
        l_bktxt1     LIKE rbkp-bktxt,
        l_stceg      LIKE lfa1-stceg,
        l_stenr      LIKE lfa1-stenr,
        l_street     LIKE adrc-street,
        l_house_num1 LIKE adrc-house_num1,
        l_city1      LIKE adrc-city1.

  DATA : lt_znr TYPE STANDARD TABLE OF zfvatin_nr,
         ls_znr LIKE LINE OF lt_znr.

  IF p_type4 IS NOT INITIAL.
    IF gt_nr[] IS NOT INITIAL.
      SELECT bukrs hkont gjahr belnr augbl budat bldat
             waers xblnr blart monat shkzg bschl mwskz
             dmbtr zfbdt sgtxt
        FROM bsas
        INTO CORRESPONDING FIELDS OF TABLE i_itab1
        FOR ALL ENTRIES IN gt_nr
        WHERE bukrs = gt_nr-bukrs
          AND hkont = '0142200200'
          AND belnr = gt_nr-belnr
          AND gjahr = gt_nr-gjahr
          AND budat IN s_budat
          AND shkzg = 'H'
          AND blart = 'RE'.
    ENDIF.
  ELSE.
    SELECT bukrs hkont gjahr belnr augbl budat bldat
           waers xblnr blart monat shkzg bschl mwskz
           dmbtr zfbdt sgtxt
      FROM bsas
      INTO CORRESPONDING FIELDS OF TABLE i_itab1
      WHERE bukrs = p_bukrs      AND
            hkont = '0142200200' AND
*          BELNR = P_BELNR      AND
            belnr IN s_belnr      AND
            gjahr = p_gjahr      AND
            budat IN s_budat     AND
            shkzg = 'H'          AND
*          GSBER = P_GSBER      AND
            blart = 'RE'.
  ENDIF.

  IF sy-subrc = 0.
    IF p_type3 IS NOT INITIAL.
      SELECT *
        FROM zfvatin_nr
        INTO CORRESPONDING FIELDS OF TABLE lt_znr
        FOR ALL ENTRIES IN i_itab1
        WHERE bukrs = i_itab1-bukrs
          AND gsber = p_gsber
          AND belnr = i_itab1-belnr
          AND gjahr = i_itab1-gjahr.
    ENDIF.

    CLEAR wa_itab1.
    LOOP AT i_itab1 INTO wa_itab1.
      IF p_gjahr > '2019'.
        READ TABLE lt_znr INTO ls_znr
                          WITH KEY bukrs = wa_itab1-bukrs
                                   gsber = p_gsber
                                   belnr = wa_itab1-belnr
                                   gjahr = wa_itab1-gjahr.
        IF sy-subrc = 0.
          DELETE i_itab1.
        ENDIF.
      ELSE.
        CASE 'X'.
          WHEN p_type3.
            DELETE i_itab1.
        ENDCASE.
      ENDIF.

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
      SELECT SINGLE lifnr gsber
        FROM bsik
        INTO (l_lifnr, l_gsber)
        WHERE belnr = wa_itab1-belnr AND
              bukrs = wa_itab1-bukrs AND
              blart = 'RE'.
      IF l_gsber = '0' OR
         l_gsber = space.
        SELECT SINGLE lifnr gsber
          FROM bsak
          INTO (l_lifnr, l_gsber)
          WHERE belnr = wa_itab1-belnr AND
                blart = 'RE'.
        MOVE l_lifnr TO wa_itab1-lifnr.
        MOVE l_gsber TO wa_itab1-gsber.
      ELSE.
        MOVE l_lifnr TO wa_itab1-lifnr.
        MOVE l_gsber TO wa_itab1-gsber.
      ENDIF.

** GET ANRED, NAME1, NAME2, STRAS, ORT01, STCEG, STCD1
*      CLEAR: L_ANRED, L_NAME1, L_NAME2, L_STRAS, L_ORT01, L_STCEG,
*             L_STCD1.
*      SELECT SINGLE ANRED NAME1 NAME2 STRAS ORT01 STCEG STCD1 FROM LFA1
*        INTO (L_ANRED, L_NAME1, L_NAME2, L_STRAS, L_ORT01, L_STCEG,
*              L_STCD1)
*        WHERE LIFNR = WA_ITAB1-LIFNR.
*
*        MOVE L_NAME1 TO WA_ITAB1-NAME1.
*        MOVE L_NAME2 TO WA_ITAB1-NAME2.
*        MOVE L_STRAS TO WA_ITAB1-STRAS.
*        MOVE L_ORT01 TO WA_ITAB1-ORT01.
*        MOVE L_STCEG TO WA_ITAB1-STCEG.
*        MOVE L_STCD1 TO WA_ITAB1-STCD1.
*
*        CONCATENATE L_ANRED L_NAME1 L_NAME2 INTO WA_ITAB1-SGTXT
*          SEPARATED BY SPACE.

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
      SELECT SINGLE anred name1 name2 adrnr ort01 stceg stcd1 stenr
        FROM lfa1
        INTO (l_anred, l_name1, l_name2, l_adrnr, l_ort01, l_stceg,
              l_stcd1, l_stenr)
        WHERE lifnr = wa_itab1-lifnr.

      MOVE l_name1 TO wa_itab1-name1.
      MOVE l_name2 TO wa_itab1-name2.
*        MOVE L_STRAS TO WA_ITAB1-STRAS.
      MOVE l_ort01 TO wa_itab1-ort01.
      MOVE l_stcd1 TO wa_itab1-stcd1.
      MOVE l_stceg TO wa_itab1-stceg.
      MOVE l_stenr TO wa_itab1-stenr.

      SELECT SINGLE street house_num1 city1
        FROM adrc
        INTO (l_street, l_house_num1, l_city1)
        WHERE addrnumber EQ l_adrnr.

      MOVE l_city1 TO wa_itab1-city1.

      CONCATENATE l_street l_house_num1 INTO wa_itab1-stras
        SEPARATED BY space.

      CONCATENATE l_anred l_name1 l_name2 INTO wa_itab1-sgtxt
        SEPARATED BY space.

* GET ZUONR & BKTXT
      SELECT SINGLE zuonr bktxt FROM rbkp
        INTO (l_zuonr, l_bktxt)
        WHERE belnr EQ wa_itab1-rbeln AND
              gjahr EQ p_gjahr.
*            ( TCODE EQ 'MIRO' or TCODE EQ 'MIR7' ). Remark by skd

      SELECT SINGLE bktxt FROM bkpf
        INTO l_bktxt1
        WHERE belnr EQ wa_itab1-rbeln AND
              gjahr EQ p_gjahr.

      MOVE l_zuonr TO wa_itab1-zuonr1.
      IF l_bktxt1 IS NOT INITIAL AND
        l_bktxt1 <> l_bktxt.
        MOVE l_bktxt1 TO wa_itab1-bktxt.
      ELSE.
        MOVE l_bktxt TO wa_itab1-bktxt.
      ENDIF.

***** Ganti kode vendor kembali.
      IF wa_itab1-lifnr = 'TSB8010'.
        wa_itab1-lifnr = l_lifnr.
      ENDIF.
******
      MODIFY i_itab1 FROM wa_itab1.
*      MOVE wa_itab1-lifnr TO va_lifnr.
*      MOVE wa_itab1-blart TO va_blart.
*      MOVE wa_itab1-budat TO va_date.
      CLEAR wa_itab1.
    ENDLOOP.

* GET BSIS-SGTXT
    IF i_itab1[] IS NOT INITIAL.
      SELECT bukrs hkont gjahr belnr sgtxt
             FROM bsis
             INTO CORRESPONDING FIELDS OF TABLE i_hdr3
             FOR ALL ENTRIES IN i_itab1
             WHERE bukrs = p_bukrs AND
                   hkont = '0312600300' AND
                   gjahr = p_gjahr AND
                   belnr = i_itab1-belnr.

      IF sy-subrc NE 0.
        SELECT bukrs hkont gjahr belnr sgtxt
               FROM bsas
               INTO CORRESPONDING FIELDS OF TABLE i_hdr3
               FOR ALL ENTRIES IN i_itab1
               WHERE bukrs = p_bukrs AND
                     hkont = '0312600300' AND
                     gjahr = p_gjahr AND
                     belnr = i_itab1-belnr.
      ENDIF.

* GET DISCOUNT
      SELECT bukrs hkont gjahr belnr buzei sgtxt shkzg dmbtr
             FROM bsis
             INTO CORRESPONDING FIELDS OF TABLE i_hdr4
             FOR ALL ENTRIES IN i_itab1
             WHERE bukrs = p_bukrs AND
                   hkont LIKE '031825%' AND
                   gjahr = p_gjahr AND
                   belnr = i_itab1-belnr.

      IF sy-subrc NE 0.
        SELECT bukrs hkont gjahr belnr buzei sgtxt shkzg dmbtr
               FROM bsas
               INTO CORRESPONDING FIELDS OF TABLE i_hdr4
               FOR ALL ENTRIES IN i_itab1
               WHERE bukrs = p_bukrs AND
                     hkont LIKE '031825%' AND
                     gjahr = p_gjahr AND
                     belnr = i_itab1-belnr.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_HEADER_BSAS1

*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_BSAS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_detail_bsas1.
  DATA: l_amnt      LIKE rseg-wrbtr,
        l_tmeng     LIKE rseg-menge,
        l_menge(20),
        l_bstme     LIKE rseg-bstme,
        l_wrbtr     LIKE rseg-wrbtr,
        l_hasat(20).

  counter = 0.
  counter1 = 0.
  ebelp = 0.

*{   REPLACE        P01K910184                                        1
*\  SELECT belnr gjahr buzei ebelp matnr menge bstme wrbtr rbwwr rbmng shkzg
*\    FROM rseg
*\    INTO CORRESPONDING FIELDS OF TABLE i_itab2
*\    WHERE belnr = wa_itab1-rbeln AND
*\          gjahr = wa_itab1-gjahr AND
*\          bukrs = p_bukrs.
  "Start SOH: Shell SCI Adjustment 20240221 KRS
  SELECT belnr gjahr buzei ebelp matnr menge bstme wrbtr rbwwr rbmng shkzg
    FROM rseg
    INTO CORRESPONDING FIELDS OF TABLE i_itab2
    WHERE belnr = wa_itab1-rbeln AND
          gjahr = wa_itab1-gjahr AND
          bukrs = p_bukrs ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE

  IF sy-subrc <> 0.
*{   REPLACE        P01K910184                                        2
*\    SELECT belnr gjahr buzei matnr menge wrbtr shkzg "RBMNG RBWWR
*\      FROM rbma
*\      INTO CORRESPONDING FIELDS OF TABLE i_itab2
*\      WHERE belnr = wa_itab1-rbeln AND
*\            gjahr = wa_itab1-gjahr.
    "Start SOH: Shell SCI Adjustment 20240221 KRS
    SELECT belnr gjahr buzei matnr menge wrbtr shkzg "RBMNG RBWWR
      FROM rbma
      INTO CORRESPONDING FIELDS OF TABLE i_itab2
      WHERE belnr = wa_itab1-rbeln AND
            gjahr = wa_itab1-gjahr ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
  ENDIF.

  i_itab2tmp[] = i_itab2[].
  SORT i_itab2tmp BY belnr matnr.
  DELETE ADJACENT DUPLICATES FROM i_itab2tmp COMPARING belnr matnr.
  DESCRIBE TABLE i_itab2tmp LINES ln_itab2tmp.

  CLEAR: wa_itab2, va_amnt, va_ppn.
  LOOP AT i_itab2 INTO wa_itab2.
    SELECT SINGLE maktx FROM makt
      INTO wa_itab2-maktx
      WHERE matnr = wa_itab2-matnr.

    CLEAR: va_amtrbma, va_shkzg.
    SELECT SINGLE wrbtr shkzg
      INTO (va_amtrbma, va_shkzg)
      FROM rbma
      WHERE belnr = wa_itab2-belnr AND
            gjahr = wa_itab2-gjahr AND
            buzei = wa_itab2-buzei AND
            matnr = wa_itab2-matnr.
    IF va_shkzg = 'H'.
      va_amtrbma = va_amtrbma * -1.
    ENDIF.
    wa_itab2-amnt  = wa_itab2-rbwwr - wa_itab2-wrbtr + va_amtrbma.
    IF wa_itab2-amnt < 0.
      wa_itab2-amnt = wa_itab2-amnt * -1.
    ENDIF.

*            WA_ITAB2-AMNT = WA_ITAB2-WRBTR. "* -1.
*            WA_ITAB2-QUANT = ( WA_ITAB2-BPRBM - WA_ITAB2-MENGE ) * -1.
*            WA_ITAB2-AMNT  = ( WA_ITAB2-RBWWR - WA_ITAB2-WRBTR ) * -1.
    MODIFY i_itab2 FROM wa_itab2.
    ADD wa_itab2-amnt TO va_amnt.
    ADD wa_itab2-amnt TO va_amnt1.
    ADD wa_itab2-amnt TO va_amnt2.

*            WRITE WA_ITAB2-EBELP TO EBELP.
*            IF EBELP = 0.
*              WRITE WA_ITAB2-BUZEI TO EBELP.
*            ENDIF.
    WRITE wa_itab2-maktx TO maktx.
    WRITE wa_itab2-quant TO quant DECIMALS 2.

    ADD wa_itab2-menge TO l_tmeng.
    l_bstme = wa_itab2-bstme.

*---------- B001 ----------
*            ADD 1 TO COUNTER.
*            ADD 1 TO COUNTER1.
*--------------------------
    AT END OF matnr.
*---------- B001 ----------
      ADD 1 TO counter.
      ADD 1 TO counter1.
*--------------------------
      ADD 1 TO ebelp.

      WRITE l_tmeng TO l_menge UNIT l_bstme.
      CONDENSE l_menge NO-GAPS.
      l_wrbtr = va_amnt / l_tmeng.
      WRITE l_wrbtr TO l_hasat CURRENCY 'IDR'.
      CONDENSE l_hasat NO-GAPS.

      PERFORM cetak_detail USING l_menge l_hasat.
      CLEAR : va_amnt2, l_tmeng.
    ENDAT.

    AT END OF belnr.
      va_amnt = va_amnt * 100.
*              VA_PPN = ( 10 / 100 ) * VA_AMNT.
      WRITE va_amnt TO amnt1 DECIMALS 0.
*              WRITE VA_PPN  TO PPN DECIMALS 0.

      LOOP AT i_hdr4 WHERE belnr = wa_itab1-belnr.
        IF i_hdr4-shkzg = 'H'.
          i_hdr4-dmbtr = i_hdr4-dmbtr * -1.
        ENDIF.
        ADD i_hdr4-dmbtr TO va_disc.
      ENDLOOP.
      va_disc = va_disc * 100.
      va_dpp = va_amnt - va_disc.

      PERFORM f_tax_calc USING va_date va_dpp 'E'
                         CHANGING va_ppn.

*      va_ppn = ( 10 / 100 ) * va_dpp.

      WRITE va_disc TO disc DECIMALS 0.
      WRITE va_dpp  TO dpp DECIMALS 0.
      WRITE va_ppn  TO ppn DECIMALS 0.

      CLEAR wa_itab1.
      READ TABLE i_itab1 INTO wa_itab1 WITH KEY belnr = wa_itab2-belnr.
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
             amnt2, amnt1, amnt3, ppn.
    ENDIF.
*            ENDAT.

    CLEAR wa_itab2.
  ENDLOOP.
  CLEAR counter.
*      ADD 1 TO PAGE1.
*      CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " GET_DETAIL_BSAS1

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_next_number  USING    fu_object fu_subobject fu_year fu_view
                    CHANGING fc_nonr.
  DATA : ls_nriv    TYPE nriv.

  IF fu_view IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = fu_object
        subobject               = fu_subobject
        toyear                  = fu_year
      IMPORTING
        number                  = fc_nonr
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
  ELSE.
    ls_nriv-object    = fu_object.
    ls_nriv-subobject = fu_subobject.
    ls_nriv-nrrangenr = '01'.
    ls_nriv-toyear    = fu_year.

    SELECT SINGLE nrlevel
      FROM nriv
      INTO ls_nriv-nrlevel
      WHERE object    = ls_nriv-object
        AND subobject = ls_nriv-subobject
        AND nrrangenr = ls_nriv-nrrangenr
        AND toyear    = ls_nriv-toyear.

    ls_nriv-nrlevel = ls_nriv-nrlevel + 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_nriv-nrlevel
      IMPORTING
        output = fc_nonr.
  ENDIF.
ENDFORM.                    " F_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_insert_to_table .
  DATA : ls_nonr   TYPE zfvatin_nr,
         lv_stceg  TYPE lfa1-stceg,
         lv_street TYPE adrc-street,
         lv_city1  TYPE adrc-city1.

  SELECT SINGLE stceg street city1
    FROM lfa1 JOIN adrc ON lfa1~adrnr = adrc~addrnumber
    INTO (lv_stceg, lv_street, lv_city1)
    WHERE lifnr = va_lifnr.

  ls_nonr-bukrs     = p_bukrs.
  ls_nonr-gsber     = p_gsber.
  ls_nonr-belnr     = va_belnr.
  ls_nonr-gjahr     = p_gjahr.
  ls_nonr-lifnr     = va_lifnr.
  ls_nonr-street    = lv_street.
  ls_nonr-city1     = lv_city1.
  ls_nonr-stceg     = lv_stceg.
  ls_nonr-nonr      = va_nonr.
  ls_nonr-vatpr1    = va_zuonr1.
  ls_nonr-vatdt1    = va_bktxt.
  ls_nonr-usna1     = sy-uname.
  ls_nonr-erdt1     = sy-datum.
  ls_nonr-erzet     = sy-uzeit.
  MODIFY zfvatin_nr FROM ls_nonr.
ENDFORM.                    " F_INSERT_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_NR
*&---------------------------------------------------------------------*
FORM f_get_data_nr .
  DATA : lt_rbkp TYPE STANDARD TABLE OF rbkp,
         lt_nr   TYPE STANDARD TABLE OF ty_nr,
         lt_lfa1 TYPE STANDARD TABLE OF lfa1,
         ls_lfa1 LIKE LINE OF lt_lfa1,
         ls_nr   LIKE LINE OF gt_nr,
         ls_rbkp LIKE LINE OF lt_rbkp.

  IF p_gjahr > '2019'.
    IF pa_new IS INITIAL.
      SELECT *
        FROM rbkp
        INTO CORRESPONDING FIELDS OF TABLE lt_rbkp
        WHERE belnr IN s_belnr
          AND gjahr = p_gjahr
          AND budat IN s_budat.
      IF sy-subrc = 0.
        LOOP AT lt_rbkp INTO ls_rbkp.
          ls_nr-bukrs = p_bukrs.
          ls_nr-gsber = p_gsber.
          ls_nr-gjahr = p_gjahr.
          ls_nr-belnr = ls_rbkp-belnr.
          ls_nr-lifnr = ls_rbkp-lifnr.
          APPEND ls_nr TO gt_nr.
          CLEAR ls_nr.
        ENDLOOP.
      ENDIF.
    ELSE.
      SELECT *
        FROM zfvatin_nr
        INTO CORRESPONDING FIELDS OF TABLE gt_nr
        WHERE bukrs = p_bukrs
          AND gsber = p_gsber
          AND belnr IN s_belnr
          AND gjahr = p_gjahr.
    ENDIF.
  ELSE.
    SELECT *
      FROM rbkp
      INTO CORRESPONDING FIELDS OF TABLE lt_rbkp
      WHERE belnr IN s_belnr
        AND gjahr = p_gjahr
        AND budat IN s_budat.
    IF sy-subrc = 0.
      LOOP AT lt_rbkp INTO ls_rbkp.
        ls_nr-bukrs = p_bukrs.
        ls_nr-gsber = p_gsber.
        ls_nr-gjahr = p_gjahr.
        ls_nr-belnr = ls_rbkp-belnr.
        ls_nr-lifnr = ls_rbkp-lifnr.
        APPEND ls_nr TO gt_nr.
        CLEAR ls_nr.
      ENDLOOP.
    ENDIF.
  ENDIF.

  lt_nr[] = gt_nr[].
  SORT lt_nr BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_nr COMPARING lifnr.
  IF lt_nr[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
      FOR ALL ENTRIES IN lt_nr
      WHERE lifnr = lt_nr-lifnr.
  ENDIF.

  IF pa_new IS NOT INITIAL.
    IF gt_nr[] IS NOT INITIAL.
      SELECT *
        FROM rbkp
        INTO CORRESPONDING FIELDS OF TABLE lt_rbkp
        FOR ALL ENTRIES IN gt_nr
        WHERE belnr = gt_nr-belnr
          AND gjahr = gt_nr-gjahr
          AND budat IN s_budat.
    ENDIF.
  ENDIF.

  LOOP AT gt_nr INTO ls_nr.
    CLEAR ls_lfa1.
    READ TABLE lt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = ls_nr-lifnr.
    CLEAR ls_rbkp.
    READ TABLE lt_rbkp INTO ls_rbkp
                       WITH KEY belnr = ls_nr-belnr
                                gjahr = ls_nr-gjahr.
    IF sy-subrc = 0.
      ls_nr-budat  = ls_rbkp-budat.
      ls_nr-bldat  = ls_rbkp-bldat.
      ls_nr-name1  = ls_lfa1-name1.
      ls_nr-total  = ls_rbkp-rmwwr.
      ls_nr-dpp    = ls_rbkp-rmwwr - ls_rbkp-wmwst1.
      ls_nr-ppn    = ls_rbkp-wmwst1.
      MODIFY gt_nr FROM ls_nr TRANSPORTING budat bldat name1 total dpp ppn.
    ELSE.
      DELETE TABLE gt_nr FROM ls_nr.
    ENDIF.
    CLEAR ls_nr.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_NR

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM_NEW
*&---------------------------------------------------------------------*
FORM f_cetak_form_new USING fu_ucomm.
  DATA : lv_formname        TYPE tdsfname,
         lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop.

  DATA : lt_itab   TYPE ta_itab1 OCCURS 0,
         lt_itab2  TYPE ta_itab2 OCCURS 0,
         ls_itab   LIKE LINE OF lt_itab,
         ls_itab2  LIKE LINE OF lt_itab2,
         lv_count  TYPE i,
         lv_lines  TYPE i,
         lv_ebelp  TYPE i,
         lv_wrbtr  TYPE rseg-wrbtr,
         lv_dmbtr  TYPE bsid-dmbtr,
         lv_dpp    TYPE bsid-dmbtr,
         lv_ppn    TYPE bsid-dmbtr,
         lv_menge2 TYPE menge_d,
         lv_dmbtr2 TYPE dmbtr.

  lv_formname = 'ZFF_VAT_RETURN'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  lt_itab[] = i_itab1[].
  DELETE lt_itab WHERE check IS INITIAL.
  SORT lt_itab BY rbeln DESCENDING gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING rbeln gjahr.
  DESCRIBE TABLE lt_itab LINES lv_lines.

  IF lt_itab[] IS NOT INITIAL.
    CLEAR gt_bseg[].
    SELECT bukrs belnr gjahr buzei shkzg gsber dmbtr hkont
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM bseg FOR ALL ENTRIES IN lt_itab
      WHERE bukrs = p_bukrs
        AND belnr = lt_itab-rbeln
        AND gjahr = lt_itab-gjahr
        AND ( hkont = '0911900000' OR hkont = '911900000' ).

    SELECT belnr gjahr buzei ebelp matnr menge bstme wrbtr rbwwr rbmng shkzg
      FROM rseg
      INTO CORRESPONDING FIELDS OF TABLE i_itab2
      FOR ALL ENTRIES IN lt_itab
      WHERE belnr = lt_itab-rbeln
        AND gjahr = lt_itab-gjahr
        AND bukrs = p_bukrs.

    IF sy-subrc <> 0.
      SELECT belnr gjahr buzei matnr menge wrbtr shkzg "RBMNG RBWWR
        FROM rbma
        INTO CORRESPONDING FIELDS OF TABLE i_itab2
        FOR ALL ENTRIES IN lt_itab
        WHERE belnr = lt_itab-rbeln
          AND gjahr = lt_itab-gjahr.
    ENDIF.
  ENDIF.

  lt_itab2[]  = i_itab2[].
  SORT lt_itab2 BY belnr gjahr matnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING belnr gjahr matnr.

  CASE fu_ucomm.
    WHEN '&POS'.
      lwa_output_option-tdnoprev = 'X'.
    WHEN '&PREV'.
      lwa_output_option-tdnoprint = 'X'.
  ENDCASE.

  CLEAR ls_itab.
  LOOP AT lt_itab INTO ls_itab.
    ADD 1 TO lv_count.

    IF lv_count = 1.
      lwa_output_option-tdnewid     = 'X'.
    ENDIF.

    IF lv_count = lv_lines.
      lwa_control_option-no_close  = space.
    ELSE.
      lwa_control_option-no_close  = 'X'.
    ENDIF.

    PERFORM f_header_sf USING ls_itab fu_ucomm.
    CLEAR : gt_detail[], gt_detail, lv_wrbtr, lv_ebelp.
    CLEAR : lv_menge2,lv_dmbtr2.

    LOOP AT lt_itab2 INTO ls_itab2
                     WHERE belnr = ls_itab-rbeln
                       AND gjahr = ls_itab-gjahr.
      ADD 1 TO lv_ebelp.
      PERFORM f_detail_sf USING ls_itab2-belnr ls_itab2-gjahr
                                ls_itab2-matnr ls_itab2-bstme
                          CHANGING lv_ebelp lv_wrbtr lv_menge2
                                   lv_dmbtr2.
    ENDLOOP.

    PERFORM f_modify_detail USING p_bukrs ls_itab-rbeln ls_itab-gjahr
                                  lv_menge2
                            CHANGING lv_wrbtr.

    WRITE lv_wrbtr TO gs_header-amnt1 CURRENCY 'IDR'.

    CLEAR lv_dmbtr.
    LOOP AT i_hdr4 WHERE belnr = ls_itab2-belnr
                     AND gjahr = ls_itab2-gjahr.
      IF i_hdr4-shkzg = 'H'.
        i_hdr4-dmbtr = i_hdr4-dmbtr * -1.
      ENDIF.
      ADD i_hdr4-dmbtr TO lv_dmbtr.
    ENDLOOP.

    WRITE lv_dmbtr TO gs_header-amnt2 CURRENCY 'IDR'.

    lv_dpp = lv_wrbtr - lv_dmbtr.
    WRITE lv_dpp TO gs_header-amnt4 CURRENCY 'IDR'.

*    lv_ppn = ( 10 / 100 ) * lv_dpp.
    lv_ppn  = ls_itab-dmbtr.
    WRITE lv_ppn TO gs_header-amnt5 CURRENCY 'IDR'.

    CALL FUNCTION lv_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gs_header          = gs_header
      TABLES
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    lwa_control_option-no_open  = 'X'.

    IF fu_ucomm = '&POS'.
      IF p_type3 IS NOT INITIAL.
        PERFORM f_insert_to_table.
        PERFORM f_change_fi_document USING ls_itab-belnr.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CETAK_FORM_NEW

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_SF
*&---------------------------------------------------------------------*
FORM f_header_sf USING fs_itab  TYPE ta_itab1 fu_ucomm.
  PERFORM f_nomor_nota_retur USING fs_itab fu_ucomm.
  PERFORM f_nomor_faktur USING fs_itab.
  PERFORM f_pembeli USING fs_itab.
  PERFORM f_penjual USING fs_itab.

  va_zuonr1 = fs_itab-zuonr1.
  va_bktxt  = fs_itab-bktxt.
  va_lifnr  = fs_itab-lifnr.
  va_belnr  = fs_itab-belnr.
  va_stenr  = fs_itab-stenr.

  gs_header-stenr = fs_itab-stenr.
  WRITE fs_itab-budat TO gs_header-date DD/MM/YYYY.
  gs_header-sign = sign.

  gs_header-new  = pa_new.
ENDFORM.                    " F_HEADER_SF

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_SF
*&---------------------------------------------------------------------*
FORM f_detail_sf  USING    fu_rbeln fu_gjahr fu_matnr fu_bstme
                  CHANGING fc_ebelp fc_wrbtr fc_menge2 fc_dmbtr2.
  DATA : ls_detail LIKE LINE OF gt_detail,
         lv_hasat  TYPE rseg-wrbtr,
         lv_menge  TYPE rseg-menge,
         lv_wrbtr  TYPE rseg-wrbtr.

  ls_detail-ebelp  = fc_ebelp.
  SELECT SINGLE maktx
    FROM makt
    INTO ls_detail-maktx
    WHERE matnr = fu_matnr
      AND spras = sy-langu.

  LOOP AT i_itab2 INTO wa_itab2 WHERE belnr = fu_rbeln
                                  AND gjahr = fu_gjahr
                                  AND matnr = fu_matnr.
    ADD wa_itab2-menge TO lv_menge.
    ADD wa_itab2-wrbtr TO lv_wrbtr.
  ENDLOOP.

  WRITE lv_menge TO ls_detail-menge UNIT fu_bstme.
  WRITE lv_wrbtr TO ls_detail-amnt CURRENCY 'IDR' .
  lv_hasat = lv_wrbtr / lv_menge.
  WRITE lv_hasat TO ls_detail-hasat CURRENCY 'IDR'.

  ls_detail-wrbtr   = lv_wrbtr.
  ls_detail-matnr   = fu_matnr.
  ls_detail-menge2  = lv_menge.
  ls_detail-dmbtr2  = lv_wrbtr.

  APPEND ls_detail TO gt_detail.
  CLEAR ls_detail.

  ADD lv_wrbtr TO fc_wrbtr.
  ADD lv_menge TO fc_menge2.
  ADD lv_wrbtr TO fc_dmbtr2.
ENDFORM.                    " F_DETAIL_SF

*&---------------------------------------------------------------------*
*&      Form  F_NOMOR_NOTA_RETUR
*&---------------------------------------------------------------------*
FORM f_nomor_nota_retur  USING    fs_itab  TYPE ta_itab1 fu_ucomm.
  DATA : lv_nonr(8),
         l_noret(20),
         ls_nr       LIKE LINE OF gt_nr,
         lv_view,
         lv_gsber    TYPE bsis-gsber.

  CASE 'X'.
    WHEN p_type3.
      CASE fu_ucomm.
        WHEN '&PREV'.
          lv_view   = 'X'.
        WHEN '&POS'.
          CLEAR lv_view.
      ENDCASE.
      PERFORM f_next_number USING 'ZNONR' p_bukrs p_gjahr lv_view
                            CHANGING lv_nonr.

      CASE p_bukrs.
        WHEN '8020'.
          IF p_gjahr < 2020.
            CONCATENATE fs_itab-blart fs_itab-belnr INTO l_noret
              SEPARATED BY space.
          ELSE.
            CONCATENATE 'PTT/' p_gjahr '/' lv_nonr INTO l_noret.
          ENDIF.
        WHEN '8070'.
          IF p_gjahr < 2020.
            CONCATENATE fs_itab-blart fs_itab-belnr INTO l_noret
              SEPARATED BY space.
          ELSE.
            CONCATENATE 'SUT/' p_gjahr '/' lv_nonr INTO l_noret.
          ENDIF.
      ENDCASE.
    WHEN p_type4.
      IF p_gjahr < 2020.
        CONCATENATE fs_itab-blart fs_itab-belnr INTO l_noret
          SEPARATED BY space.
      ELSE.
        CLEAR lv_gsber.
        CASE fs_itab-bukrs.
          WHEN '8070'.
            lv_gsber  = '0700'.
          WHEN OTHERS.
            lv_gsber = fs_itab-gsber.
        ENDCASE.

        READ TABLE gt_nr INTO ls_nr
                         WITH KEY bukrs = fs_itab-bukrs
                                  gsber = lv_gsber
                                  belnr = fs_itab-belnr
                                  gjahr = fs_itab-gjahr.
        IF sy-subrc = 0.
          l_noret = ls_nr-nonr.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      CONCATENATE fs_itab-blart fs_itab-belnr INTO l_noret
        SEPARATED BY space.
  ENDCASE.

  va_nonr  = l_noret.
  gs_header-noret  = l_noret.
ENDFORM.                    " F_NOMOR_NOTA_RETUR

*&---------------------------------------------------------------------*
*&      Form  F_NOMOR_FAKTUR
*&---------------------------------------------------------------------*
FORM f_nomor_faktur USING fs_itab   TYPE ta_itab1.
  DATA : l_norut TYPE i,
         ld_len  TYPE i.

  IF fs_itab-bktxt+6(4) GT 2006.
    IF p_type2 EQ 'X'.
      CONCATENATE fs_itab-zuonr1(3) '.' fs_itab-zuonr1+3(3) '-' fs_itab-zuonr1+6(2) '.'
                  fs_itab-zuonr1+8(8)
        INTO faktur1.
      CONCATENATE gs_header-faktur1 '/' fs_itab-bktxt INTO gs_header-faktur1
        SEPARATED BY space.
    ENDIF.
  ELSE.
    IF p_type2 EQ 'X'.
      CONCATENATE fs_itab-stcd1 fs_itab-zuonr1 INTO gs_header-faktur1.
      CONCATENATE gs_header-faktur1 '/' fs_itab-bktxt INTO gs_header-faktur1
        SEPARATED BY space.
    ENDIF.
  ENDIF.

  IF p_type3 EQ 'X' OR
    p_type4 EQ 'X'.
    CLEAR: wa_hdr3, gs_header-faktur1, gs_header-faktur2, gs_header-faktur3,
           gs_header-faktur4, gs_header-faktur5.
    CLEAR: l_norut.

    IF pa_new IS NOT INITIAL.
      READ TABLE i_hdr3 INTO wa_hdr3 WITH KEY belnr = fs_itab-belnr.
      IF sy-subrc = 0.
        IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
          gs_header-faktur1 = wa_hdr3-sgtxt.
        ELSE.
          gs_header-faktur1 = wa_hdr3-sgtxt.
*          CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur1.
        ENDIF.
      ENDIF.
    ELSE.
      SORT i_hdr3 BY sgtxt.
      LOOP AT i_hdr3 INTO wa_hdr3.
        AT NEW sgtxt.
          ld_len = strlen( wa_hdr3-sgtxt ).
          ld_len = ld_len - 4.
          IF ld_len < 0.
            ld_len = 0.
          ENDIF.

          ADD 1 TO l_norut.
          CASE l_norut.
            WHEN 1.
              IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
                gs_header-faktur1 = wa_hdr3-sgtxt.
              ELSE.
                gs_header-faktur1 = wa_hdr3-sgtxt.
*                CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur1.
              ENDIF.
            WHEN 2.
              IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
                gs_header-faktur2 = wa_hdr3-sgtxt.
              ELSE.
                gs_header-faktur2 = wa_hdr3-sgtxt.
*                CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur2.
              ENDIF.
            WHEN 3.
              IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
                gs_header-faktur3 = wa_hdr3-sgtxt.
              ELSE.
                gs_header-faktur3 = wa_hdr3-sgtxt.
*                CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur3.
              ENDIF.
            WHEN 4.
              IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
                gs_header-faktur4 = wa_hdr3-sgtxt.
              ELSE.
                gs_header-faktur4 = wa_hdr3-sgtxt.
*                CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur4.
              ENDIF.
            WHEN 5.
              IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
                gs_header-faktur5 = wa_hdr3-sgtxt.
              ELSE.
                gs_header-faktur5 = wa_hdr3-sgtxt.
*                CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur5.
              ENDIF.
          ENDCASE.
        ENDAT.
        CLEAR: ld_len.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NOMOR_FAKTUR

*&---------------------------------------------------------------------*
*&      Form  F_PEMBELI
*&---------------------------------------------------------------------*
FORM f_pembeli USING fs_itab  TYPE ta_itab1.
  DATA : l_adrnr     LIKE tvbur-adrnr,
         l_pkpname   LIKE zgdtxdt0005-pkpname,
         l_pkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
         l_pkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
         l_pkppostal LIKE zgdtxdt0005-pkppostal,
         l_pkpcity   LIKE zgdtxdt0005-pkpcity.

  SELECT SINGLE name1
    FROM t001 JOIN adrc ON t001~adrnr = adrc~addrnumber
    INTO gs_header-name1
    WHERE bukrs = fs_itab-bukrs.

  IF p_gsber = '02TM'.
    SELECT SINGLE adrnr
      FROM tvbur
      INTO l_adrnr
      WHERE vkbur = fs_itab-gsber.
  ELSE.
    SELECT SINGLE adrnr
      FROM tvbur
      INTO l_adrnr
      WHERE vkbur = p_gsber.
  ENDIF.

  IF fs_itab-budat LT '20111101'.
    SELECT SINGLE street city1
      FROM adrc
      INTO (gs_header-street, gs_header-city1)
      WHERE addrnumber = l_adrnr.
  ELSE.
    IF p_gsber = '02TM'.
      SELECT SINGLE pkpname pkpaddrs1 pkpaddrs2 pkppostal pkpcity
        FROM zgdtxdt0005
        INTO (l_pkpname, l_pkpaddrs1, l_pkpaddrs2, l_pkppostal, l_pkpcity)
        WHERE bukrs EQ p_bukrs
          AND brnch EQ fs_itab-gsber.
    ELSE.
      SELECT SINGLE pkpname pkpaddrs1 pkpaddrs2 pkppostal pkpcity
        FROM zgdtxdt0005
        INTO (l_pkpname, l_pkpaddrs1, l_pkpaddrs2, l_pkppostal, l_pkpcity)
        WHERE bukrs EQ p_bukrs
          AND brnch EQ p_gsber.
    ENDIF.
    gs_header-street = l_pkpaddrs1.
    CONCATENATE l_pkpaddrs2 l_pkpcity l_pkppostal INTO gs_header-city1 SEPARATED BY space.
  ENDIF.

  IF p_gsber = '02TM'.
    SELECT SINGLE npwp
      FROM zftax
      INTO gs_header-npwp
      WHERE bukrs = p_bukrs
        AND gsber = fs_itab-gsber.
  ELSE.
    SELECT SINGLE npwp
      FROM zftax
      INTO gs_header-npwp
      WHERE bukrs = p_bukrs
        AND gsber = p_gsber.
  ENDIF.
ENDFORM.                    " F_PEMBELI

*&---------------------------------------------------------------------*
*&      Form  F_PENJUAL
*&---------------------------------------------------------------------*
FORM f_penjual  USING    fs_itab  TYPE ta_itab1.

  CONCATENATE fs_itab-name1 fs_itab-name2 INTO gs_header-names
  SEPARATED BY space.
  gs_header-streets = fs_itab-stras.
*  gs_header-street1 = fs_itab-ort01.
  gs_header-street1 = fs_itab-city1.
  gs_header-stceg   = fs_itab-stceg.
ENDFORM.                    " F_PENJUAL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
      IF p_type4 IS NOT INITIAL AND
        pa_new IS INITIAL.
        IF s_belnr[] IS INITIAL.
          PERFORM f_error_selection_screen USING 'SBE' '0' ''.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error fu_mess.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'You are not authorized'.
    WHEN '2'.
      lv_mess = fu_mess.
      CONDENSE lv_mess.
      CONCATENATE 'Enter a number greater than to' lv_mess INTO lv_mess
      SEPARATED BY space.
  ENDCASE.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN
