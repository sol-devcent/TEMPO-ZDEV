*----------------------------------------------------------------------*
***INCLUDE ZF_AR_AGING_NEW_V1F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SUM_05T
*&---------------------------------------------------------------------*
FORM sum_05t .
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr anln1.
  SORT it_bsid BY bukrs vkbur kunnr anln1 budat.

  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING bukrs vkbur kunnr anln1.
  LOOP AT lt_bsid.
    LOOP AT it_bsid WHERE bukrs = lt_bsid-bukrs
                      AND vkbur = lt_bsid-vkbur
                      AND kunnr = lt_bsid-kunnr
                      AND anln1 = lt_bsid-anln1.
      MOVE it_bsid-vkbur TO itab9-gsber.
      MOVE it_bsid-kunnr TO itab9-kunnr.
      MOVE it_bsid-anln1 TO itab9-anln1.
      MOVE p_gerdat(4) TO itab9-gjahr.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab9-begin = itab9-begin + it_bsid-dmbtr.
      ENDIF.

      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab9-sales = itab9-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab9-payment = itab9-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.

      PERFORM due_branch9  TABLES it_bsid.

      MOVE it_bsid-sortl TO itab9-sortl.
      MOVE it_bsid-anln1 TO itab9-anln1.

      itab9-payment = itab9-payment.
      itab9-sales   = itab9-sales.
      itab9-ending  = itab9-begin + itab9-sales + ( itab9-payment ).
      COLLECT itab9.
      CLEAR itab9.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " SUM_05T

*&---------------------------------------------------------------------*
*&      Form  ITAB9
*&---------------------------------------------------------------------*
FORM itab9 .
  APPEND LINES OF itab9 TO itab9_1.
  DELETE itab9_1 WHERE due1 EQ 0.
  APPEND LINES OF itab9 TO itab9_2.
  DELETE itab9_2 WHERE due2 EQ 0.
  APPEND LINES OF itab9 TO itab9_3.
  DELETE itab9_3 WHERE due3 EQ 0.
  APPEND LINES OF itab9 TO itab9_4.
  DELETE itab9_4 WHERE due4 EQ 0.
  APPEND LINES OF itab9 TO itab9_5.
  DELETE itab9_5 WHERE due5 EQ 0.

  IF int1 = space.
    DELETE itab9 WHERE due1 EQ 0.
  ELSEIF int2 = space.
    DELETE itab9 WHERE due2 EQ 0.
  ELSEIF int3 = space.
    DELETE itab9 WHERE due3 EQ 0.
  ELSEIF int4 = space.
    DELETE itab9 WHERE due4 EQ 0.
  ELSEIF int5 = space.
    DELETE itab9 WHERE due5 EQ 0.
  ENDIF.
  REFRESH itab9. CLEAR itab9.

  IF int1 EQ 'X'.
    APPEND LINES OF itab9_1 TO itab9.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab9_2 TO itab9.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab9_3 TO itab9.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab9_4 TO itab9.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab9_5 TO itab9.
  ENDIF.
  SORT itab9.
  DELETE ADJACENT DUPLICATES FROM itab9 COMPARING ALL FIELDS.
  REFRESH: itab9_1, itab9_2, itab9_3, itab9_4, itab9_5.
  CLEAR: itab9_1, itab9_2, itab9_3, itab9_4, itab9_5.
ENDFORM.                    " ITAB9

*&---------------------------------------------------------------------*
*&      Form  WRITE_05T
*&---------------------------------------------------------------------*
FORM write_05t .
  DATA: itab9t     LIKE itab9,
        lt_itab    LIKE itab9 OCCURS 0,
        ls_itab    LIKE itab9.

  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.
  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr  TYPE kunnr,
           name1  TYPE name1_gp,
         END OF lt_kna1.
  DATA : BEGIN OF lt_zplbc OCCURS 0,
           bukrs  TYPE bukrs,
           vstel  TYPE vstel,
           live   TYPE zlive_indicator,
         END OF lt_zplbc.

  DATA : lv_subrc   TYPE sy-subrc,
         l_limit    TYPE p,
         l_lines    TYPE i.

  lt_itab[] = itab9[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.

  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.

    SELECT kunnr name1
      FROM kna1
      INTO TABLE lt_kna1
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.
  CLEAR : lt_itab[], lt_itab.
  lt_itab[] = itab9[].
  SORT lt_itab BY gsber.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING gsber.
  IF lt_itab[] IS NOT INITIAL.
    SELECT b~bukrs a~vstel b~live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    INTO TABLE lt_zplbc
    FOR ALL ENTRIES IN lt_itab
    WHERE b~bukrs EQ p_bukrs
      AND a~vstel EQ lt_itab-gsber
      AND b~live  EQ space.
  ENDIF.

  LOOP AT lt_itab INTO ls_itab.
    PERFORM f_check_write USING ls_itab-begin ls_itab-sales
                                ls_itab-payment ls_itab-ending
                                ls_itab-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      FORMAT COLOR OFF.
      plant = ls_itab-gsber.
      page = 1.
      PERFORM write_header.
    ENDIF.

    LOOP AT itab9 WHERE gsber = ls_itab-gsber.
      PERFORM zebra.
      no = no + 1.
      CLEAR: itab9-limit, itab9-giro.

      READ TABLE lt_knkk WITH KEY kunnr = itab9-kunnr.
      IF sy-subrc EQ 0.
        itab9-limit  = lt_knkk-klimk.
      ENDIF.

      l_limit = itab9-limit * 100.
      IF l_limit >= 99999999999999.
        itab9-limit = 0.
      ENDIF.

      LOOP AT i_giro WHERE vkbur EQ itab9-gsber AND
                           kunnr EQ itab9-kunnr AND
                           anln1 EQ itab9-anln1.
        itab9-giro = itab9-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ itab9-gsber AND
                               kunnr EQ itab9-kunnr.
        itab9-giro = itab9-giro + i_giro_sfa-bank_amt.
      ENDLOOP.

      MODIFY itab9 TRANSPORTING limit giro.

      CLEAR lt_kna1.
      READ TABLE lt_kna1 WITH KEY kunnr = itab9-kunnr.
      CLEAR: lt_zplbc, lv_subrc.
      READ TABLE lt_zplbc WITH KEY vstel = itab9-gsber.
      lv_subrc  = sy-subrc.

      PERFORM write_detail_principal USING lt_kna1-name1 lv_subrc.
      PERFORM f_add_amount USING itab9
                           CHANGING itab9t.
    ENDLOOP.

    SUM.
    SKIP 1.
    PERFORM subtotal9 CHANGING itab9t.

    CLEAR ls_itab.
  ENDLOOP.

  PERFORM write_bottom.
ENDFORM.                    " WRITE_05T

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_PRINCIPAL
*&---------------------------------------------------------------------*
FORM write_detail_principal  USING    fu_name1 fu_subrc.
  DATA : name1 LIKE kna1-name1,
         l_live LIKE zplbc-live.

  c1 = 0.
  name1 = fu_name1.

  MOVE itab9-kunnr TO itab9-kunnr1.
  IF fu_subrc EQ 0.
    MOVE itab9-sortl TO itab9-kunnr.
  ENDIF.

  WRITE AT /(w1) itab9-kunnr HOTSPOT.c1 = w1 + 2.
  HIDE: itab9-gsber, itab9-kunnr, itab9-anln1.
  WRITE AT c1(w2) name1.c1 = c1 + w2 + 1.
  WRITE AT c1(w2) itab9-anln1.c1 = c1 + w2 + 1.
  WRITE AT c1(w3) itab9-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab9-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab9-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab9-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab9-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) itab9-limit CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w9)  itab9-due1 CURRENCY 'IDR'.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) itab9-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab9-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab9-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab9-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                    " WRITE_DETAIL_PRINCIPAL

*&---------------------------------------------------------------------*
*&      Form  DUE_BRANCH9
*&---------------------------------------------------------------------*
FORM due_branch9  TABLES   ft_bsid STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
    "Kondisi utk AR potongan
*    age = p_gerdat - it_bsid-zfbdt.
*    IF it_bsid-umskz = 'V'.
*      age = p_gerdat - it_bsid-budat.
*    ELSE.
*      age = p_gerdat - it_bsid-zfbdt.
*    ENDIF.
    IF age LE int1low.
      itab9-due1 = itab9-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab9-due2 = itab9-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab9-due3 = itab9-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab9-due4 = itab9-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab9-due5 = itab9-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab9-due1 = itab9-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab9-due2 = itab9-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab9-due3 = itab9-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab9-due4 = itab9-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab9-due5 = itab9-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " DUE_BRANCH9

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL9
*&---------------------------------------------------------------------*
FORM subtotal9 CHANGING fu_itab9   LIKE itab9.
  DATA text(40).
  c1 = 0.
  c1 = 43.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) fu_itab9-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) fu_itab9-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) fu_itab9-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) fu_itab9-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) fu_itab9-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) fu_itab9-limit CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w9) fu_itab9-due1 CURRENCY 'IDR'.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) fu_itab9-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) fu_itab9-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) fu_itab9-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) fu_itab9-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

  CLEAR fu_itab9.
ENDFORM.                    " SUBTOTAL9

*&---------------------------------------------------------------------*
*&      Form  F_ADD_AMOUNT
*&---------------------------------------------------------------------*
FORM f_add_amount  USING    fs_itab   LIKE itab9
                   CHANGING fc_itab   LIKE itab9.
  ADD fs_itab-begin TO fc_itab-begin.
  ADD fs_itab-sales TO fc_itab-sales.
  ADD fs_itab-payment TO fc_itab-payment.
  ADD fs_itab-ending TO fc_itab-ending.
  ADD fs_itab-giro  TO fc_itab-giro.
  ADD fs_itab-due1 TO fc_itab-due1.
  ADD fs_itab-due2 TO fc_itab-due2.
  ADD fs_itab-due3 TO fc_itab-due3.
  ADD fs_itab-due4 TO fc_itab-due4.
  ADD fs_itab-due5 TO fc_itab-due5.
ENDFORM.                    " F_ADD_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_CHOOSE9
*&---------------------------------------------------------------------*
FORM f_choose9 .
  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE kunnr NE itab9-kunnr.
  DELETE it_choosekey WHERE gsber NE itab9-gsber.
  DELETE it_choosekey WHERE anln1 NE itab9-anln1.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr anln1.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE it_choosekey-anln1 TO itab-anln1.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber AND
                         anln1 EQ it_choosekey-anln1.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber AND
                             anln1 EQ it_choosekey-anln1.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          anln1 EQ it_choosekey-anln1.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHOOSE9
