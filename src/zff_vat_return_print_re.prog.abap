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
        l_zuonr LIKE rbkp-zuonr,
        l_bktxt LIKE rbkp-bktxt,
        l_stceg LIKE lfa1-stceg,
        l_stenr LIKE lfa1-stenr,
        l_street LIKE adrc-street,
        l_house_num1 LIKE adrc-house_num1.

  DATA : lt_znr   TYPE STANDARD TABLE OF zfvatin_nr,
         ls_znr   LIKE LINE OF lt_znr.

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
            belnr = p_belnr      AND
            gjahr = p_gjahr      AND
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
      READ TABLE lt_znr INTO ls_znr
                        WITH KEY bukrs = wa_itab1-bukrs
                                 gsber = p_gsber
                                 belnr = wa_itab1-belnr
                                 gjahr = wa_itab1-gjahr.
      IF sy-subrc = 0.
        DELETE i_itab1.
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
        INTO (l_street, l_house_num1, gs_header-street1)
        WHERE addrnumber EQ l_adrnr.

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
      MOVE l_zuonr TO wa_itab1-zuonr1.
      MOVE l_bktxt TO wa_itab1-bktxt.
***** Ganti kode vendor kembali.
      IF wa_itab1-lifnr = 'TSB8010'.
        wa_itab1-lifnr = l_lifnr.
      ENDIF.
******
      MODIFY i_itab1 FROM wa_itab1.
      MOVE wa_itab1-lifnr TO va_lifnr.
      MOVE wa_itab1-blart TO va_blart.
      MOVE wa_itab1-budat TO va_date.
      CLEAR wa_itab1.
    ENDLOOP.

* GET BSIS-SGTXT
    SELECT bukrs hkont gjahr belnr sgtxt
           FROM bsis
           INTO CORRESPONDING FIELDS OF TABLE i_hdr3
           WHERE bukrs = p_bukrs AND
                ( hkont = '0312600300' OR hkont = '0312600700' ) AND
                 gjahr = p_gjahr AND
                 belnr = p_belnr.

    IF sy-subrc NE 0.
      SELECT bukrs hkont gjahr belnr sgtxt
             FROM bsas
             INTO CORRESPONDING FIELDS OF TABLE i_hdr3
             WHERE bukrs = p_bukrs AND
                  ( hkont = '0312600300' OR hkont = '0312600700' ) AND
                   gjahr = p_gjahr AND
                   belnr = p_belnr.
    ENDIF.

* GET DISCOUNT
    SELECT bukrs hkont gjahr belnr sgtxt shkzg dmbtr
           FROM bsis
           INTO CORRESPONDING FIELDS OF TABLE i_hdr4
           WHERE bukrs = p_bukrs AND
                 hkont LIKE '031825%' AND
                 gjahr = p_gjahr AND
                 belnr = p_belnr.

    IF sy-subrc NE 0.
      SELECT bukrs hkont gjahr belnr sgtxt shkzg dmbtr
             FROM bsas
             INTO CORRESPONDING FIELDS OF TABLE i_hdr4
             WHERE bukrs = p_bukrs AND
                   hkont LIKE '031825%' AND
                   gjahr = p_gjahr AND
                   belnr = p_belnr.
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
  DATA: l_amnt    LIKE rseg-wrbtr,
        l_tmeng   LIKE rseg-menge,
        l_menge(20),
        l_bstme   LIKE rseg-bstme,
        l_wrbtr   LIKE rseg-wrbtr,
        l_hasat(20).

  counter = 0.
  counter1 = 0.
  ebelp = 0.

*{   REPLACE        P01K910178                                        1
*\  SELECT belnr gjahr buzei ebeln ebelp matnr menge bstme wrbtr rbwwr rbmng
*\    FROM rseg
*\    INTO CORRESPONDING FIELDS OF TABLE i_itab2
*\    WHERE belnr = wa_itab1-rbeln AND
*\          gjahr = wa_itab1-gjahr AND
*\          bukrs = p_bukrs.
  "Start SOH: Shell SCI Adjustment 20240221 KRS
  SELECT belnr gjahr buzei ebeln ebelp matnr menge bstme wrbtr rbwwr rbmng
    FROM rseg
    INTO CORRESPONDING FIELDS OF TABLE i_itab2
    WHERE belnr = wa_itab1-rbeln AND
          gjahr = wa_itab1-gjahr AND
          bukrs = p_bukrs ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE

  IF sy-subrc <> 0.
*{   REPLACE        P01K910178                                        2
*\    SELECT belnr gjahr buzei matnr menge wrbtr "RBMNG RBWWR
*\      FROM rbma
*\      INTO CORRESPONDING FIELDS OF TABLE i_itab2
*\      WHERE belnr = wa_itab1-rbeln AND
*\            gjahr = wa_itab1-gjahr.
    "Start SOH: Shell SCI Adjustment 20240221 KRS
    SELECT belnr gjahr buzei matnr menge wrbtr "RBMNG RBWWR
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
    ADD wa_itab2-amnt TO va_wrbtr.
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
      l_wrbtr = va_wrbtr / l_tmeng.
      WRITE l_wrbtr TO l_hasat CURRENCY 'IDR'.
      CONDENSE l_hasat NO-GAPS.

      PERFORM cetak_detail USING l_menge l_hasat.
      CLEAR : va_amnt2, va_wrbtr.
    ENDAT.

    AT END OF belnr.
      va_amnt = va_amnt * 100.
*              VA_PPN = ( 10 / 100 ) * VA_AMNT.
      WRITE va_amnt TO amnt1 DECIMALS 0.
*              WRITE VA_PPN  TO PPN DECIMALS 0.

      LOOP AT i_hdr4.
        IF i_hdr4-shkzg = 'H'.
          i_hdr4-dmbtr = i_hdr4-dmbtr * -1.
        ENDIF.
        ADD i_hdr4-dmbtr TO va_disc.
      ENDLOOP.
      va_disc = va_disc * 100.
      va_dpp = va_amnt - va_disc.
      va_ppn = ( 10 / 100 ) * va_dpp.

      WRITE va_disc TO disc DECIMALS 0.
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
  DATA : ls_nonr    TYPE zfvatin_nr,
         lv_stceg   TYPE lfa1-stceg,
         lv_street  TYPE adrc-street,
         lv_city1   TYPE adrc-city1.

  SELECT SINGLE stceg street city1
    FROM lfa1 JOIN adrc ON lfa1~adrnr = adrc~addrnumber
    INTO (lv_stceg, lv_street, lv_city1)
    WHERE lifnr = va_lifnr.

  ls_nonr-bukrs     = p_bukrs.
  ls_nonr-gsber     = p_gsber.
  ls_nonr-belnr     = p_belnr.
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
  DATA : lt_rbkp  TYPE STANDARD TABLE OF rbkp,
         lt_nr    TYPE STANDARD TABLE OF ty_nr,
         lt_lfa1  TYPE STANDARD TABLE OF lfa1,
         ls_lfa1  LIKE LINE OF lt_lfa1,
         ls_nr    LIKE LINE OF gt_nr,
         ls_rbkp  LIKE LINE OF lt_rbkp.

  IF p_type4 IS NOT INITIAL.
    s_belnr-low     = p_belnr.
    s_belnr-sign    = 'I'.
    s_belnr-option  = 'EQ'.
    APPEND s_belnr.
  ENDIF.

*{   REPLACE        P01K910178                                        1
*\  SELECT *
*\    FROM zfvatin_nr
*\    INTO CORRESPONDING FIELDS OF TABLE gt_nr
*\    WHERE bukrs = p_bukrs
*\      AND gsber = p_gsber
*\      AND belnr IN s_belnr
*\      AND gjahr = p_gjahr.
  "Start SOH: Shell SCI Adjustment 20240222 KRS
  SELECT *
    FROM zfvatin_nr
    INTO CORRESPONDING FIELDS OF TABLE gt_nr
    WHERE bukrs = p_bukrs
      AND gsber = p_gsber
      AND belnr IN s_belnr
      AND gjahr = p_gjahr
    ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240222 KRS
*}   REPLACE

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

  IF gt_nr[] IS NOT INITIAL.
    SELECT *
      FROM rbkp
      INTO CORRESPONDING FIELDS OF TABLE lt_rbkp
      FOR ALL ENTRIES IN gt_nr
      WHERE belnr = gt_nr-belnr
        AND gjahr = gt_nr-gjahr.

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
        MODIFY gt_nr FROM ls_nr TRANSPORTING budat bldat name1.
      ELSE.
        DELETE gt_nr FROM ls_nr.
      ENDIF.
      CLEAR ls_nr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_NR

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  PERFORM f_alv TABLES gt_nr.
ENDFORM.                    " F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN p_type5.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFVATIN_NR' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZFVATIN_NR' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFVATIN_NR' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFVATIN_NR' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'RBKP' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'RBKP' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'ZFVATIN_NR' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STREET' 'ZFVATIN_NR' 'STREET' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CITY1' 'ZFVATIN_NR' 'CITY1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFVATIN_NR' 'STCEG' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NONR' 'ZFVATIN_NR' 'NONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VATPR1' 'ZFVATIN_NR' 'VATPR1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VATDT1' 'ZFVATIN_NR' 'VATDT1' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN OTHERS.
      PERFORM f_fieldcatg USING ft_report:
        'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' 'C601',
        'AUGBL' 'BSIS' 'AUGBL' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'BSIK' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'ZUONR' 'BSIK' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR1' 'RBKP' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  CASE 'X'.
    WHEN p_type5..
    WHEN OTHERS.
      fu_layout-box_fieldname      = 'CHECK'.
  ENDCASE.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CASE 'X'.
    WHEN p_type5.
    WHEN OTHERS.
      CLEAR ld_sort.
      ld_sort-fieldname = 'AUGBL'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'BUDAT'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
  ENDCASE.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA : fcode TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  CASE 'X'.
    WHEN p_type1.
      APPEND '&PREV'  TO fcode.
    WHEN p_type2.
      APPEND '&PREV'  TO fcode.
    WHEN p_type3.
    WHEN p_type5.
      APPEND '&PREV'  TO fcode.
      APPEND '&POS'  TO fcode.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM_NEW
*&---------------------------------------------------------------------*
FORM f_cetak_form_new USING fu_answer.
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         lwa_output_option   TYPE ssfcompop,
         lwa_control_option  TYPE ssfctrlop.

  DATA : lt_itab    TYPE ta_itab1 OCCURS 0,
         lt_itab2   TYPE ta_itab2 OCCURS 0,
         ls_itab    LIKE LINE OF lt_itab,
         ls_itab2   LIKE LINE OF lt_itab2,
         lv_count   TYPE i,
         lv_lines   TYPE i,
         lv_ebelp   TYPE i,
         lv_wrbtr   TYPE rseg-wrbtr,
         lv_dmbtr   TYPE bsid-dmbtr,
         lv_disc    TYPE konv-kwert,
         lv_dpp     TYPE bsid-dmbtr,
         lv_ppn     TYPE bsid-dmbtr.

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
  SORT lt_itab BY rbeln DESCENDING gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING rbeln gjahr.
  DESCRIBE TABLE lt_itab LINES lv_lines.

  IF lt_itab[] IS NOT INITIAL.
    SELECT belnr gjahr buzei ebeln ebelp matnr menge bstme wrbtr rbwwr rbmng
      FROM rseg
      INTO CORRESPONDING FIELDS OF TABLE i_itab2
      FOR ALL ENTRIES IN lt_itab
      WHERE belnr = lt_itab-rbeln
        AND gjahr = lt_itab-gjahr
        AND bukrs = p_bukrs.

    IF sy-subrc <> 0.
      SELECT belnr gjahr buzei matnr menge wrbtr "RBMNG RBWWR
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

  CASE fu_answer.
    WHEN '1'.
      lwa_output_option-tdnoprev = 'X'.
    WHEN '2'.
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

    PERFORM f_header_sf USING ls_itab fu_answer.
    CLEAR : gt_detail[], gt_detail.

    LOOP AT lt_itab2 INTO ls_itab2
                     WHERE belnr = ls_itab-rbeln
                       AND gjahr = ls_itab-gjahr.
      ADD 1 TO lv_ebelp.
      PERFORM f_detail_sf USING ls_itab2-belnr ls_itab2-gjahr
                                ls_itab2-matnr ls_itab2-bstme
                          CHANGING lv_ebelp lv_wrbtr lv_disc.
    ENDLOOP.

    WRITE lv_wrbtr TO gs_header-amnt1 CURRENCY 'IDR'.

    LOOP AT i_hdr4 WHERE belnr = ls_itab2-belnr
                     AND gjahr = ls_itab2-gjahr.
      IF i_hdr4-shkzg = 'H'.
        i_hdr4-dmbtr = i_hdr4-dmbtr * -1.
      ENDIF.
      ADD i_hdr4-dmbtr TO lv_dmbtr.
    ENDLOOP.

    "TDN Condition
    IF ( p_type3 = 'X' AND check1 = 'X' ) OR
       ( p_type4 = 'X' AND check2 = 'X' ).
      lv_dmbtr = lv_disc.
    ENDIF.

    WRITE lv_dmbtr TO gs_header-amnt2 CURRENCY 'IDR'.

    lv_dpp = lv_wrbtr - lv_dmbtr.
    WRITE lv_dpp TO gs_header-amnt4 CURRENCY 'IDR'.

    PERFORM f_tax_calc USING va_date lv_dpp 'E'
                       CHANGING lv_ppn.

*    lv_ppn = ( 10 / 100 ) * lv_dpp.

    IF ls_itab-dmbtr IS NOT INITIAL.
      WRITE ls_itab-dmbtr TO gs_header-amnt5 CURRENCY 'IDR'.
    ELSE.
      WRITE lv_ppn TO gs_header-amnt5 CURRENCY 'IDR'.
    ENDIF.

    "TDN Condition
    IF p_bukrs = '8380' AND
       ( ( p_type3 = 'X' AND check1 = 'X' ) OR
       ( p_type4 = 'X' AND check2 = 'X' ) ).
      gv_jumlah   = gs_header-amnt1.
      gv_discount = gs_header-amnt2.
      gv_dpp      = gs_header-amnt4.
      gv_ppn      = gs_header-amnt5.

      "Run ALV report
      gv_refresh = 'X'.
      WHILE gv_refresh = 'X'.
        CALL SCREEN 100.
      ENDWHILE.

      IF gv_print = 'X'.
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
      ENDIF.

    ELSE.
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

    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CETAK_FORM_NEW

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_SF
*&---------------------------------------------------------------------*
FORM f_header_sf USING fs_itab  TYPE ta_itab1 fu_answer.
  PERFORM f_nomor_nota_retur USING fs_itab fu_answer.
  PERFORM f_nomor_faktur USING fs_itab.
  PERFORM f_pembeli USING fs_itab.
  PERFORM f_penjual USING fs_itab.

  va_zuonr1 = fs_itab-zuonr1.
  va_bktxt  = fs_itab-bktxt.

  WRITE fs_itab-budat TO gs_header-date DD/MM/YYYY.
  gs_header-sign = sign.

  gs_header-new  = 'X'.
ENDFORM.                    " F_HEADER_SF

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_SF
*&---------------------------------------------------------------------*
FORM f_detail_sf USING    fu_rbeln fu_gjahr fu_matnr fu_bstme
                 CHANGING fc_ebelp fc_wrbtr fu_disc.
  DATA : ls_detail  LIKE LINE OF gt_detail,
         lv_hasat   TYPE rseg-wrbtr,
         lv_menge   TYPE rseg-menge,
         lv_wrbtr   TYPE rseg-wrbtr,
         lv_wrbtr2  TYPE rseg-wrbtr,
         lv_disc    TYPE konv-kwert.

  DATA: lv_knumv LIKE ekko-knumv,
        lt_konv  TYPE TABLE OF konv WITH HEADER LINE.

  "TDN Condition
  IF ( p_type3 = 'X' AND check1 = 'X' ) OR
     ( p_type4 = 'X' AND check2 = 'X' ).
    LOOP AT i_itab2 INTO wa_itab2.
      wa_itab2-kposn = wa_itab2-ebelp.
      MODIFY i_itab2 FROM wa_itab2 TRANSPORTING kposn.
    ENDLOOP.

    READ TABLE i_itab2 INTO wa_itab2 INDEX 1.
    SELECT SINGLE knumv INTO lv_knumv
      FROM ekko WHERE ebeln = wa_itab2-ebeln.

    SELECT knumv kposn stunr zaehk kappl kschl kbetr kwert waers
      INTO CORRESPONDING FIELDS OF TABLE lt_konv
      FROM konv FOR ALL ENTRIES IN i_itab2
      WHERE knumv = lv_knumv
        AND kposn = i_itab2-kposn
*        AND kschl IN ('ZHJP','ZHJR','ZMDP').
        AND koaid = 'A'.  "Discount Condition
  ENDIF.

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

    "TDN Condition
    IF ( p_type3 = 'X' AND check1 = 'X' ) OR
       ( p_type4 = 'X' AND check2 = 'X' ).
      CLEAR: lt_konv,lv_disc.
      READ TABLE lt_konv WITH KEY knumv = lv_knumv
                                  kposn = wa_itab2-kposn.
*                                  kschl = 'ZMDP'.
      IF lt_konv-kbetr IS NOT INITIAL.
        lt_konv-kbetr = ABS( lt_konv-kbetr ).
        DIVIDE lt_konv-kbetr BY 10.
        lv_wrbtr2 = wa_itab2-wrbtr / ( ( 100 - lt_konv-kbetr ) / 100 ).

        "PMH Condition
        CLEAR wa_itab1.
        READ TABLE i_itab1 INTO wa_itab1 INDEX 1.
        IF wa_itab1-lifnr = 'TSB8220'.
          lv_wrbtr2 = lv_wrbtr2 / ( 91 / 100 ).
          lv_disc = lv_wrbtr2 * ( 2265 / 10000 ). "Discount 22,65
        ELSE.
          lv_disc = lv_wrbtr2 * lt_konv-kbetr / 100.
        ENDIF.
      ENDIF.
*      LOOP AT lt_konv WHERE knumv = lv_knumv
*                        AND kposn = wa_itab2-kposn.
*        CASE lt_konv-kschl.
*          WHEN 'ZHJP'.
*            ADD lt_konv-kwert TO lv_wrbtr2.
*          WHEN 'ZHJR'.
*            lt_konv-kwert = lt_konv-kwert * 10 / 11.
*            ADD lt_konv-kwert TO lv_wrbtr2.
*          WHEN 'ZMDP'.
*            lt_konv-kwert = lt_konv-kwert * 10 / 11.
*            ADD lt_konv-kwert TO lv_disc.
*        ENDCASE.
*      ENDLOOP.
    ENDIF.
  ENDLOOP.

  "TDN Condition
  IF ( p_type3 = 'X' AND check1 = 'X' ) OR
     ( p_type4 = 'X' AND check2 = 'X' ).
    lv_wrbtr = ABS( lv_wrbtr2 ).
    ADD lv_disc TO fu_disc.
  ENDIF.

  WRITE lv_menge TO ls_detail-menge UNIT fu_bstme.
  WRITE lv_wrbtr TO ls_detail-amnt CURRENCY 'IDR' .
  WRITE lv_disc TO ls_detail-amnt2 CURRENCY 'IDR' .
  lv_hasat = lv_wrbtr / lv_menge.
  WRITE lv_hasat TO ls_detail-hasat CURRENCY 'IDR'.

  ls_detail-hasatv = lv_hasat.
  ls_detail-amntv  = lv_wrbtr.
  ls_detail-amnt2v = lv_disc.

  APPEND ls_detail TO gt_detail.
  CLEAR ls_detail.

  ADD lv_wrbtr TO fc_wrbtr.
ENDFORM.                    " F_DETAIL_SF

*&---------------------------------------------------------------------*
*&      Form  F_NOMOR_NOTA_RETUR
*&---------------------------------------------------------------------*
FORM f_nomor_nota_retur USING fs_itab  TYPE ta_itab1 fu_answer.
  DATA : lv_nonr(8),
         l_noret(20),
         ls_nr    LIKE LINE OF gt_nr,
         lv_view.

  CASE 'X'.
    WHEN p_type3.
      CASE fu_answer.
        WHEN '1'.
          CLEAR lv_view.
        WHEN '2'.
          lv_view   = 'X'.
      ENDCASE.

      PERFORM f_next_number USING 'ZNONR' p_bukrs p_gjahr lv_view
                            CHANGING lv_nonr.

      CASE p_bukrs.
        WHEN '8020'.
          CONCATENATE 'PTT/' p_gjahr '/' lv_nonr INTO l_noret.
        WHEN '8070'.
          CONCATENATE 'SUT/' p_gjahr '/' lv_nonr INTO l_noret.
        WHEN '8380'.
          CONCATENATE 'TDN/' p_gjahr '/' lv_nonr INTO l_noret.
      ENDCASE.
    WHEN p_type4.
      READ TABLE gt_nr INTO ls_nr
                       WITH KEY bukrs = fs_itab-bukrs
                                gsber = fs_itab-gsber
                                belnr = fs_itab-belnr
                                gjahr = fs_itab-gjahr.
      IF sy-subrc = 0.
        l_noret = ls_nr-nonr.
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
         ld_len TYPE i.

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
    SORT i_hdr3 BY sgtxt.
    LOOP AT i_hdr3 INTO wa_hdr3.
      AT NEW sgtxt.
        ld_len = STRLEN( wa_hdr3-sgtxt ).
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
              CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur1.
            ENDIF.
          WHEN 2.
            IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
              gs_header-faktur2 = wa_hdr3-sgtxt.
            ELSE.
              CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur2.
            ENDIF.
          WHEN 3.
            IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
              gs_header-faktur3 = wa_hdr3-sgtxt.
            ELSE.
              CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur3.
            ENDIF.
          WHEN 4.
            IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
              gs_header-faktur4 = wa_hdr3-sgtxt.
            ELSE.
              CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur4.
            ENDIF.
          WHEN 5.
            IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
              gs_header-faktur5 = wa_hdr3-sgtxt.
            ELSE.
              CONCATENATE fs_itab-stcd1 wa_hdr3-sgtxt INTO gs_header-faktur5.
            ENDIF.
        ENDCASE.
      ENDAT.
      CLEAR: ld_len.
    ENDLOOP.
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
  IF p_bukrs <> '8380'.
    gs_header-street1 = fs_itab-ort01.
  ENDIF.
  gs_header-stceg   = fs_itab-stceg.
ENDFORM.                    " F_PENJUAL
