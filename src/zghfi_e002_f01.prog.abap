*----------------------------------------------------------------------*
***INCLUDE ZTDNFI_I003_F01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .

  IF p_back NE 'X' AND rb_1 = 'X'.
    PERFORM f_modify_screen USING : 'REQ' '' '' '' '1'.
  ELSE.
    PERFORM f_modify_screen USING : 'REQ' '' '' '' ''.
  ENDIF.
  IF rb_2 = 'X'.
    PERFORM f_modify_screen USING : 'BCK' '0' '' '' ''.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN_1000



*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_get_data. "  TABLES p_itab.
  DATA: lt_bsad TYPE STANDARD TABLE OF bsad.
  DATA: lt_header TYPE STANDARD TABLE OF ty_header.
  DATA: ls_header LIKE LINE OF gt_header.
  DATA: ls_bsad LIKE LINE OF lt_bsad.
  DATA: lt_zghfidt001 TYPE STANDARD TABLE OF zghfidt001.
  DATA: ls_zghfidt001 LIKE LINE OF lt_zghfidt001.
  DATA: lt_zfbid_arpot TYPE STANDARD TABLE OF zfbid_arpot.
  DATA: lt_zfbid_arpot_rev TYPE STANDARD TABLE OF zfbid_arpot.
  DATA: ls_zfbid_arpot LIKE LINE OF lt_zfbid_arpot.
  DATA: lt_bseg TYPE STANDARD TABLE OF bseg.
  DATA: ls_bseg LIKE LINE OF lt_bseg.
  IF rb_3 = 'X'.
    SELECT   a~bukrs  b~vkbur  a~kunnr c~name1 a~belnr a~zuonr a~wrbtr a~waers b~vbeln
      d~kdgrp b~kvgr3 a~budat a~zfbdt a~shkzg d~zterm a~gjahr a~augbl
      e~knumh e~persen AS persen_discount e~hari AS hari e~kzwi5 AS tot_kzwi5
      e~reward AS cash_discount e~erdat AS cpudt
      INTO CORRESPONDING FIELDS OF TABLE gt_header
      FROM bsad AS a JOIN vbrk AS d ON a~belnr = d~vbeln
                     JOIN vbrp AS b ON a~belnr =  b~vbeln
                     JOIN kna1 AS c ON a~kunnr = c~kunnr
                     JOIN zghfidt001 AS e ON a~bukrs = e~vkorg
                                         AND b~vkbur = e~vkbur
                                         AND b~vbeln = e~vbeln

      WHERE a~bukrs = p_bukrs
        AND a~kunnr IN s_kunnr
        AND a~belnr IN s_belnr
        AND zfbdt IN s_zfbdt
        AND blart EQ 'RV'
        AND b~vkbur IN s_vkbur
        AND a~shkzg = 'S'
        AND d~zterm NE 'ZT00'
        AND d~fksto = space.
    DELETE ADJACENT DUPLICATES FROM gt_header COMPARING ALL FIELDS.
    IF gt_header[] IS NOT INITIAL.
      SELECT * INTO TABLE lt_bsad FROM bsad
        FOR ALL ENTRIES IN gt_header
        WHERE bukrs = gt_header-bukrs
          AND kunnr = gt_header-kunnr
     "     AND gjahr = gt_header-gjahr
          AND zuonr = gt_header-zuonr
          AND budat IN s_budat
          AND blart = 'DZ'.
      SORT lt_bsad BY bukrs gjahr zuonr budat DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_bsad COMPARING bukrs gjahr zuonr.
      lt_header[] = gt_header[].
      CLEAR: gt_header[].
      SORT lt_header BY bukrs gjahr zuonr.
      SORT lt_bsad BY bukrs gjahr zuonr.
      LOOP AT lt_header INTO ls_header.
        SORT lt_bsad BY bukrs zuonr.
        READ TABLE lt_bsad INTO ls_bsad
            WITH KEY bukrs = ls_header-bukrs
      "               gjahr = ls_header-gjahr
                     zuonr = ls_header-zuonr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          APPEND ls_header TO gt_header.
        ENDIF.
        CLEAR: ls_header.
      ENDLOOP.
      IF gt_header[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail
          FROM vbrp
          FOR ALL ENTRIES IN gt_header
          WHERE vbeln = gt_header-vbeln.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zghfidt002 FROM zghfidt002
      WHERE vkorg = p_bukrs.
    IF sy-subrc NE 0.
      WRITE: / 'Belum ada data di table ZGHFIDT002, mohon dimaintance dan jalankan ulang'.
      MESSAGE e002(zz) WITH 'Belum ada data di table ZGHFIDT002, mohon dimaintance dan jalankan ulang'.
    ENDIF.
    SELECT   a~bukrs  b~vkbur  a~kunnr c~name1 a~belnr a~zuonr wrbtr a~waers b~vbeln
      d~kdgrp b~kvgr3 a~budat a~zfbdt a~shkzg d~zterm a~gjahr a~augbl
      INTO CORRESPONDING FIELDS OF TABLE gt_header
      FROM bsad AS a JOIN vbrk AS d ON a~belnr = d~vbeln
                     JOIN vbrp AS b ON a~belnr =  b~vbeln
                     JOIN kna1 AS c ON a~kunnr = c~kunnr
  "    FOR ALL ENTRIES IN lt_bsad
      WHERE a~bukrs = p_bukrs
        AND a~kunnr IN s_kunnr
        AND a~belnr IN s_belnr
        AND zfbdt IN s_zfbdt
        AND blart EQ 'RV'
        AND vkbur IN s_vkbur
        AND a~shkzg = 'S'
        AND d~zterm NE 'ZT00'
        AND d~fksto = space.
    DELETE ADJACENT DUPLICATES FROM gt_header COMPARING ALL FIELDS.
    IF gt_header[] IS NOT INITIAL.
      IF rb_1 = 'X'. " OR rb_2 = 'X'..
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zghfidt001
          FROM zghfidt001
          FOR  ALL ENTRIES IN gt_header
          WHERE vkorg = gt_header-bukrs
            AND vkbur = gt_header-vkbur
            AND vbeln = gt_header-vbeln.
        IF sy-subrc EQ 0.
          IF rb_1 = 'X'.
            LOOP AT lt_zghfidt001 INTO ls_zghfidt001.
              SORT gt_header BY bukrs vkbur vbeln.
              DELETE gt_header[] WHERE bukrs = ls_zghfidt001-vkorg
                     AND vkbur = ls_zghfidt001-vkbur
                     AND vbeln = ls_zghfidt001-vbeln.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
      IF gt_header[] IS NOT INITIAL.
        lt_header[] = gt_header[].
        SORT lt_header BY vbeln vkbur bukrs.
        DELETE ADJACENT DUPLICATES FROM lt_header COMPARING vbeln vkbur bukrs.
        IF lt_header[] IS NOT INITIAL.
          SELECT * INTO TABLE lt_zfbid_arpot FROM zfbid_arpot
            FOR ALL ENTRIES IN lt_header
            WHERE vbeln = lt_header-vbeln
              AND vkbur = lt_header-vkbur
              AND bukrs = lt_header-bukrs.
          IF lt_zfbid_arpot[] IS NOT INITIAL.

            lt_zfbid_arpot_rev[] = lt_zfbid_arpot[].
            DELETE lt_zfbid_arpot_rev[] WHERE belnr1 IS INITIAL.
            SORT lt_zfbid_arpot_rev BY belnr1.
            DELETE ADJACENT DUPLICATES FROM lt_zfbid_arpot_rev COMPARING belnr1.
            IF lt_zfbid_arpot_rev[] IS NOT INITIAL.
              SELECT * INTO TABLE lt_bseg FROM bseg
                FOR ALL ENTRIES IN lt_zfbid_arpot_rev
                WHERE belnr = lt_zfbid_arpot_rev-belnr1
                  AND gjahr = lt_zfbid_arpot_rev-gjahr1
                  AND koart = 'D'
                  AND augbl LIKE '04%'.
            ENDIF.
            lt_zfbid_arpot_rev[] = lt_zfbid_arpot[].
            DELETE lt_zfbid_arpot_rev[] WHERE belnr2 IS INITIAL.
            SORT lt_zfbid_arpot_rev BY belnr2.
            DELETE ADJACENT DUPLICATES FROM lt_zfbid_arpot_rev COMPARING belnr1.
            IF lt_zfbid_arpot_rev[] IS NOT INITIAL.
              SELECT * APPENDING TABLE lt_bseg FROM bseg
                FOR ALL ENTRIES IN lt_zfbid_arpot_rev
                WHERE belnr = lt_zfbid_arpot_rev-belnr2
                  AND gjahr = lt_zfbid_arpot_rev-gjahr2
                  AND koart = 'D'
                  AND augbl LIKE '04%'.
            ENDIF.
            SORT lt_bseg BY gjahr belnr.
            DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING gjahr belnr.
            LOOP AT lt_bseg INTO ls_bseg.
              DELETE lt_zfbid_arpot[] WHERE belnr1 = ls_bseg-belnr
                                        AND gjahr1 = ls_bseg-gjahr.
              DELETE lt_zfbid_arpot[] WHERE belnr2 = ls_bseg-belnr
                                        AND gjahr2 = ls_bseg-gjahr.

            ENDLOOP.
            LOOP AT lt_zfbid_arpot INTO ls_zfbid_arpot.
              SORT gt_header BY bukrs vkbur vbeln.
              DELETE gt_header[] WHERE bukrs = ls_zfbid_arpot-bukrs
                     AND vkbur = ls_zfbid_arpot-vkbur
                     AND vbeln = ls_zfbid_arpot-vbeln.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF gt_header[] IS NOT INITIAL.
          SELECT * INTO TABLE lt_bsad FROM bsad
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = gt_header-bukrs
              AND kunnr = gt_header-kunnr
"              AND gjahr = gt_header-gjahr
              AND zuonr = gt_header-zuonr
              AND budat IN s_budat
              AND blart = 'DZ'.
          SORT lt_bsad BY bukrs gjahr zuonr budat DESCENDING.
          DELETE ADJACENT DUPLICATES FROM lt_bsad COMPARING bukrs gjahr zuonr.
          lt_header[] = gt_header[].
          CLEAR: gt_header[].
          SORT lt_header BY bukrs gjahr zuonr.
          SORT lt_bsad BY bukrs gjahr zuonr.
          LOOP AT lt_header INTO ls_header.
            SORT lt_bsad BY bukrs zuonr.
            READ TABLE lt_bsad INTO ls_bsad
                WITH KEY bukrs = ls_header-bukrs
"                         gjahr = ls_header-gjahr
                         zuonr = ls_header-zuonr
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              APPEND ls_header TO gt_header.
            ENDIF.
            CLEAR: ls_header.
          ENDLOOP.
          IF gt_header[] IS NOT INITIAL.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail
              FROM vbrp
              FOR ALL ENTRIES IN gt_header
              WHERE vbeln = gt_header-vbeln.
          ENDIF.
        ENDIF.
      ENDIF.
      "        AND ( mvgr1 = '00'  OR  mvgr1 = '01' ) .
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: BEGIN OF lt_vbeln OCCURS 0,
          vbeln TYPE likp-vbeln,
        END OF lt_vbeln.
  DATA: lt_vbrk TYPE STANDARD TABLE OF vbrk.
  DATA: lt_bsad TYPE STANDARD TABLE OF bsad.
  DATA: lt_bsad_h TYPE STANDARD TABLE OF bsad.
  DATA: lt_bsad_h1 TYPE STANDARD TABLE OF bsad.
  DATA: lt_bsad_vbrk TYPE STANDARD TABLE OF bsad.
  DATA: ls_bsad LIKE LINE OF lt_bsad.
  DATA: ls_bsad_h LIKE LINE OF lt_bsad_h.
  DATA: lt_likp TYPE STANDARD TABLE OF likp.
  DATA: ls_header LIKE LINE OF gt_header.
  DATA: ls_detail LIKE LINE OF gt_detail.
  DATA: ls_likp LIKE LINE OF lt_likp.
  DATA: ls_vbrk LIKE LINE OF lt_vbrk.
  DATA: ld_vbeln TYPE likp-vbeln.
  IF rb_3 = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsad
      FROM bsad
      FOR ALL ENTRIES IN gt_header
      WHERE bukrs = gt_header-bukrs
        AND zuonr = gt_header-zuonr
        AND kunnr = gt_header-kunnr
        AND budat IN s_budat
        AND blart = 'DZ'.
    IF gt_header[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FROM likp
        FOR ALL ENTRIES IN gt_header
        WHERE vbeln = gt_header-zuonr(10).
    ENDIF.
    SORT gt_header BY bukrs kunnr zuonr.
    SORT gt_detail BY vbeln.
    LOOP AT gt_header INTO ls_header.
      SORT lt_bsad BY bukrs kunnr zuonr budat DESCENDING.
      READ TABLE lt_bsad INTO ls_bsad
           WITH KEY bukrs = ls_header-bukrs
                    kunnr = ls_header-kunnr
                    zuonr = ls_header-zuonr
                    BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_header-belnr = ls_bsad-belnr.
        ls_header-budat = ls_bsad-budat.
        ls_header-zfbdt = ls_bsad-zfbdt.
        ls_header-cpudt = ls_bsad-cpudt.
      ENDIF.
      ld_vbeln = ls_header-zuonr.
      SORT lt_likp BY vbeln.
      READ TABLE lt_likp INTO ls_likp
      WITH KEY vbeln = ld_vbeln
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_header-zfbdt = ls_likp-wadat_ist.
      ENDIF.
      ls_header-hari =  ls_header-budat - ls_header-zfbdt.
*** kententukan untuk mendapat payment dicount
      "    PERFORM f_hitung_reward USING ls_header-hari ls_header-bukrs ls_header-vkbur ls_header-kdgrp ls_header-kvgr3 ls_header-budat
      "                            CHANGING ls_header-persen_discount.
      "    CLEAR: ls_header-cash_discount.
      LOOP AT gt_detail INTO ls_detail WHERE vbeln = ls_header-vbeln.
        ls_detail-cash_discount = 0.
**** yg mendapat payment discount khusus untuk mvgr1 = 00 dan 01
*** tambahan matkl(3) = 'ERV' 'TRF'
        IF ( ls_detail-mvgr1 = '00'  OR ls_detail-mvgr1 =  '01'  OR
             ls_detail-matkl(3) = 'ERV' OR ls_detail-matkl(3) = 'TRF' )
          AND ls_header-persen_discount NE 0.
          IF ls_detail-kzwi5 IS NOT INITIAL OR ls_detail-kzwi5 NE 0.
            ls_detail-cash_discount = abs( ls_detail-kzwi5 * ls_header-persen_discount ) / 100.
            "         ls_header-cash_discount = ls_header-cash_discount + ls_detail-cash_discount.
            "         ls_header-tot_kzwi5 = ls_header-tot_kzwi5 + ls_detail-kzwi5.
          ENDIF.
        ELSE.
          CLEAR: ls_detail-cash_discount.
        ENDIF.
        MODIFY gt_detail FROM ls_detail TRANSPORTING cash_discount.
        CLEAR: ls_detail.
      ENDLOOP.
      MODIFY gt_header FROM ls_header TRANSPORTING belnr budat zfbdt hari tot_kzwi5 persen_discount cash_discount cpudt.
      CLEAR ls_header.
    ENDLOOP.

    DELETE gt_header[] WHERE cash_discount = 0.
    DELETE gt_detail[] WHERE cash_discount = 0.
  ELSE.
    IF gt_header[] IS NOT INITIAL.
***** ambil data retur buat hapus billing yang dibayar pakai retur
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsad_h
        FROM bsad
        FOR ALL ENTRIES IN gt_header
        WHERE bukrs = gt_header-bukrs
          AND zuonr = gt_header-zuonr
          AND kunnr = gt_header-kunnr
"          AND gjahr = gt_header-gjahr
          AND augbl = gt_header-augbl
          AND budat IN s_budat
          AND blart = 'DZ'
          AND bschl = '15'.
      IF lt_bsad_h[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsad_h1
          FROM bsad
          FOR ALL ENTRIES IN lt_bsad_h
          WHERE bukrs = lt_bsad_h-bukrs
            AND belnr = lt_bsad_h-belnr
            AND kunnr = lt_bsad_h-kunnr
            AND gjahr = lt_bsad_h-gjahr
            AND blart = 'DZ'
            AND bschl = '05'.

        SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_bsad_h1
          FROM bsid
          FOR ALL ENTRIES IN lt_bsad_h
          WHERE bukrs = lt_bsad_h-bukrs
            AND belnr = lt_bsad_h-belnr
            AND kunnr = lt_bsad_h-kunnr
            AND gjahr = lt_bsad_h-gjahr
            AND blart = 'DZ'
            AND bschl = '05'.

**** Ambil data ke likp untuk mendapatkan tanggal billing diambil dari wadat_ist
        LOOP AT lt_bsad_h1 INTO ls_bsad.
          lt_vbeln-vbeln = ls_bsad-zuonr.
          APPEND lt_vbeln.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING ALL FIELDS.
        IF lt_vbeln[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
            FROM vbrk
            FOR ALL ENTRIES IN lt_vbeln
            WHERE vbeln  = lt_vbeln-vbeln.
          CLEAR: lt_bsad_h[].
          LOOP AT lt_bsad_h1 INTO ls_bsad.
            ld_vbeln = ls_bsad-zuonr.
            SORT lt_vbrk BY vbeln.
            READ TABLE lt_vbrk INTO ls_vbrk
                WITH KEY vbeln = ld_vbeln
                BINARY SEARCH.
            IF sy-subrc EQ 0.
              APPEND ls_bsad TO lt_bsad_h.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT lt_bsad_h INTO ls_bsad_h.
      ld_vbeln = ls_bsad_h-zuonr.
      IF ls_bsad_h-belnr EQ ld_vbeln.
        APPEND ls_bsad_h TO lt_bsad_h1.
      ENDIF.
    ENDLOOP.

    lt_bsad_h[] = lt_bsad_h1[].
    IF gt_header[] IS NOT INITIAL.
      CLEAR: lt_vbeln[].
**** Proses delete billing yg dibyar pakai retur
      LOOP AT lt_bsad_h INTO ls_bsad_h.
        DELETE gt_header[] WHERE belnr = ls_bsad_h-belnr
                             AND kunnr = ls_bsad_h-kunnr.
      ENDLOOP.
      LOOP AT gt_header INTO ls_header.
        lt_vbeln-vbeln = ls_header-zuonr.
        APPEND lt_vbeln.
      ENDLOOP.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsad
        FROM bsad
        FOR ALL ENTRIES IN gt_header
        WHERE bukrs = gt_header-bukrs
          AND zuonr = gt_header-zuonr
          AND kunnr = gt_header-kunnr
          AND budat IN s_budat
          AND blart = 'DZ'.
      IF lt_vbeln[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_likp
          FROM likp
          FOR ALL ENTRIES IN lt_vbeln
          WHERE vbeln = lt_vbeln-vbeln.
      ENDIF.
    ENDIF.

*** Proses delete billing yang dibayar pakai retur
    LOOP AT lt_bsad_h INTO ls_bsad_h.
      READ TABLE lt_vbrk INTO ls_vbrk
                         WITH KEY vbeln = ls_bsad_h-zuonr.
      IF sy-subrc = 0.
        LOOP AT lt_bsad INTO ls_bsad WHERE belnr = ls_bsad_h-belnr AND kunnr = ls_bsad_h-kunnr.
          SORT gt_header BY bukrs kunnr zuonr. " dmbtr.
          DELETE gt_header[] WHERE zuonr = ls_bsad-zuonr.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

*** Proses untuk hitung payment discount
    DELETE gt_detail[] WHERE matkl = 'DUMMY'.
    DELETE gt_detail[] WHERE kzwi5 = 0.

    SORT gt_header BY bukrs kunnr zuonr.
    SORT gt_detail BY vbeln.
    LOOP AT gt_header INTO ls_header.
      SORT lt_bsad BY bukrs kunnr zuonr budat DESCENDING.
      READ TABLE lt_bsad INTO ls_bsad
           WITH KEY bukrs = ls_header-bukrs
                    kunnr = ls_header-kunnr
                    zuonr = ls_header-zuonr
                    BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_header-belnr = ls_bsad-belnr.
        ls_header-budat = ls_bsad-budat.
        ls_header-zfbdt = ls_bsad-zfbdt.
        ls_header-cpudt = ls_bsad-cpudt.
      ENDIF.
      ld_vbeln = ls_header-zuonr.
      SORT lt_likp BY vbeln.
      READ TABLE lt_likp INTO ls_likp
      WITH KEY vbeln = ld_vbeln
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_header-zfbdt = ls_likp-wadat_ist.
      ENDIF.
      ls_header-hari =  ls_header-budat - ls_header-zfbdt.
*** kententukan untuk mendapat payment dicount
      PERFORM f_hitung_reward USING ls_header-hari ls_header-bukrs ls_header-vkbur ls_header-kdgrp ls_header-kvgr3 ls_header-kunnr ls_header-budat
                              CHANGING ls_header-persen_discount.
      CLEAR: ls_header-cash_discount.
      LOOP AT gt_detail INTO ls_detail WHERE vbeln = ls_header-vbeln.
        ls_detail-cash_discount = 0.
**** yg mendapat payment discount khusus untuk mvgr1 = 00 dan 01
*** tambahan matkl(3) = 'ERV' 'TRF'
        IF ( ls_detail-mvgr1 = '00'  OR ls_detail-mvgr1 =  '01'  OR
             ls_detail-matkl(3) = 'ERV' OR ls_detail-matkl(3) = 'TRF' )
          AND ls_header-persen_discount NE 0.
          IF ls_detail-kzwi5 IS NOT INITIAL OR ls_detail-kzwi5 NE 0.
            ls_detail-cash_discount = abs( ls_detail-kzwi5 * ls_header-persen_discount ) / 100.
            ls_header-cash_discount = ls_header-cash_discount + ls_detail-cash_discount.
            ls_header-tot_kzwi5 = ls_header-tot_kzwi5 + ls_detail-kzwi5.
          ENDIF.
        ELSE.
          CLEAR: ls_detail-cash_discount.
        ENDIF.
        MODIFY gt_detail FROM ls_detail TRANSPORTING cash_discount.
        CLEAR: ls_detail.
      ENDLOOP.
      MODIFY gt_header FROM ls_header TRANSPORTING belnr budat zfbdt hari tot_kzwi5 persen_discount cash_discount cpudt.
      CLEAR ls_header.
    ENDLOOP.
    DELETE gt_header[] WHERE cash_discount = 0.
    DELETE gt_detail[] WHERE cash_discount = 0.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
FORM f_document_header . " USING    fu_vbeln.

ENDFORM.                    " F_DOCUMENT_HEADER


*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_posting_document USING p_vkorg TYPE vkorg
                              p_kunnr TYPE kunwe
                              p_zprclstat TYPE zprclstat
                              p_value TYPE vbrp-kzwi5
                     CHANGING fu_docnum.
  DATA: cr           LIKE TABLE OF komv WITH HEADER LINE,
        key_fields   LIKE TABLE OF komg WITH HEADER LINE,
        ls_komk      TYPE komk,
        ls_komp      TYPE komp,
        lv_varkey    TYPE char100,
        copy_staffel LIKE TABLE OF condscale WITH HEADER LINE,
        lt_knumh     TYPE STANDARD TABLE OF knumh_comp WITH HEADER LINE,
        t_komv_idoc  LIKE TABLE OF komv_idoc WITH HEADER LINE,
        lt_knumhs    TYPE STANDARD TABLE OF knumhs,
        lv_value     TYPE komv_idoc-komxwrt,
        ls_knumhs    TYPE knumhs,
        lw_knumh     TYPE knumhs-knumh_new.
  "BBYRQMAX
  DATA: ld_new_record, ld_datab LIKE sy-datum,  ld_datbi LIKE sy-datum, ld_prdat LIKE sy-datum.
  DATA: ld_kunnr    TYPE kunnr, lv_norut(9)  TYPE n.
  DATA: ld_komxwrt TYPE konp-komxwrt,
        lv_mode    TYPE c.

  ld_kunnr = p_kunnr.
  CLEAR: lv_norut.
  ADD 1 TO lv_norut.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ld_kunnr
    IMPORTING
      output = ld_kunnr.

  CONCATENATE p_vkorg ld_kunnr p_zprclstat
                     INTO lv_varkey RESPECTING BLANKS.
  lv_mode = 'A'.
  lv_value = p_value.
  SELECT SINGLE komxwrt a~knumh INTO ( ld_komxwrt, lw_knumh )
    FROM a945 AS a JOIN konp AS b ON a~knumh = b~knumh
    WHERE vkorg = p_vkorg
     AND  kunwe = ld_kunnr.
  IF sy-subrc EQ 0.
    lv_value = lv_value - ld_komxwrt.
    lv_mode = 'B'.
    fu_docnum = lw_knumh.
  ENDIF.
  CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
    EXPORTING
      p_kotabnr = '945'
      p_kvewe   = 'A'
      p_vakey   = lv_varkey
    IMPORTING
      p_komg    = key_fields.
*- Fill KOMK
  MOVE-CORRESPONDING key_fields TO ls_komk.
  ls_komk-mandt = sy-mandt.
*- Fill KOMP
  MOVE-CORRESPONDING key_fields TO ls_komp.
  ls_komp-kposn = '000001'.
  "  ls_komp-BBYRQMAX = abs( p_value ) * -100.
*- Fill KOMV_IDOC
*    t_komv_idoc-kznep = 'X'.
  t_komv_idoc-kosrt = 'REWARD'.
  t_komv_idoc-komxwrt = abs( lv_value ) * -1.
  CLEAR: t_komv_idoc-anzauf.
  APPEND t_komv_idoc.
*- Fill KOMV
  cr-kappl = 'V'.
  cr-kschl = 'ZD08'.
  cr-krech = 'A'.
  cr-kbetr = ( 75000 / 100 ) * -1. " " Unit Price
  cr-waers = '%'.
  cr-kwaeh = 'IDR'.
  cr-zaehk_ind = '01'.

  cr-kpein = '0'.
  CONCATENATE '$' lv_norut INTO cr-knumh.
  cr-mandt = sy-mandt.
**    cr-zaehk_ind  = '01'.
  APPEND cr.
  "lt_komv_idoc-komxwrt = ls_disc_zc01_ze01-komxwrt * -1

  CALL FUNCTION 'RV_CONDITION_COPY'
    EXPORTING
      application              = 'V'
      condition_table          = '945' "gt_zediscst001-KOTABNR "'304'
      condition_type           = 'ZD08'
      date_from                = sy-datum
      date_to                  = '99991231'
      enqueue                  = 'X'
      i_komk                   = ls_komk
      i_komp                   = ls_komp
      key_fields               = key_fields
      maintain_mode            = lv_mode "'A'
      no_authority_check       = 'X'
      keep_old_records         = 'X'
      used_by_idoc             = 'X'      " when suppling scales prices, this flag must be X else price will be created with Zero price.
      overlap_confirmed        = 'X'
    IMPORTING
      e_komk                   = ls_komk
      e_komp                   = ls_komp
      new_record               = ld_new_record
      e_datab                  = ld_datab
      e_datbi                  = ld_datbi
      e_prdat                  = ld_prdat
    TABLES
      copy_records             = cr
      copy_staffel             = copy_staffel
      copy_recs_idoc           = t_komv_idoc
    EXCEPTIONS
      enqueue_on_record        = 01
      invalid_application      = 02
      invalid_condition_number = 03
      invalid_condition_type   = 04
      no_authority_ekorg       = 05
      no_authority_kschl       = 06
      no_authority_vkorg       = 07
      no_selection             = 08
      table_not_valid          = 09.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'RV_CONDITION_SAVE'
      TABLES
        knumh_map = lt_knumh.
    CALL FUNCTION 'RV_CONDITION_RESET'.
    COMMIT WORK AND WAIT.
  ELSE.
    WRITE: / ' Error Create discount : ', sy-subrc.
  ENDIF.
  LOOP AT lt_knumh.
    IF lt_knumh-knumh_new IS NOT INITIAL.
      fu_docnum = lt_knumh-knumh_new.
    ELSE.
      IF fu_docnum IS INITIAL.
        fu_docnum = lt_knumh-knumh_old.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " F_POSTING_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  IF gt_header[] IS NOT INITIAL.
    "    SORT gt_header BY bukrs gjahr kunnr vbeln budat.
    SORT gt_header BY bukrs gjahr vkbur kunnr vbeln.
    SORT gt_detail BY vbeln posnr.
    PERFORM f_alv TABLES gt_header gt_detail.
  ELSE.
    MESSAGE i000(zab) WITH 'Tidak ada data'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_scrtext_s)
                          VALUE(fu_scrtext_m)
                          VALUE(fu_scrtext_l)

*                          value(fu_dosum)
*                          value(fu_hotsp)
*                          value(fu_dec)
*                          value(fu_waers)
*                          value(fu_meins)
*                          value(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_waers)
                          VALUE(fu_input)
*                          value(fu_emphasize)
*                          value(fu_hotspot)
                          "VALUE(fu_edit)
                          VALUE(fu_just). ""just(1)        type c,        " (R)ight (L)eft (C)ent.
  .
*                          value(fu_no_zero).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext_ddic  = fu_fltxt.

  ld_fieldcat-seltext_l  = fu_scrtext_l.
  ld_fieldcat-seltext_m  = fu_scrtext_m.
  ld_fieldcat-seltext_s  = fu_scrtext_s.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-just = fu_just.

*  ld_fieldcat-do_sum            = fu_dosum.
*  ld_fieldcat-hotspot           = fu_hotsp.
*  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
*  ld_fieldcat-quantity          = fu_meins.
*  ld_fieldcat-qfieldname        = fu_meins_f.
*  ld_fieldcat-cfieldname        = fu_waers_f.
*  ld_fieldcat-emphasize         = fu_emphasize.
*  ld_fieldcat-hotspot           = fu_hotspot.
*  ld_fieldcat-edit              = fu_edit.
*  ld_fieldcat-no_zero           = fu_no_zero.

  APPEND ld_fieldcat TO  t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report ft_report1..
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING 'GT_HEADER' : "ft_report:
    'BUKRS'       'BSAD' 'BUKRS' '' '' '' '' '' '' '' '' '' '',
    'VKBUR'       'VBRP' 'VKBUR' '' '' '' '' '' '' '' '' '' '',
    'BELNR'       'BSAD' 'BELNR' '' '' 'Doc. Payment' 'Doc. Payment' 'Doc. Payment' 'Doc. Payment' '' '' '' '',
    'VBELN'       'VBRK' 'VBELN' '' '' '' '' '' '' '' '' '' '',
    'ZUONR'       'BSAD' 'ZUONR' '' '' 'No. DN' 'No. DN' 'No. DN' 'No. DN' '' '' '' '',
    'KDGRP'       'VBRK' 'KDGRP' '' '' '' '' '' '' '' '' '' '',
    'KVGR3'       'VBRP' 'KVGR3' '' '' '' '' '' '' '' '' '' '',
    'KUNNR'       'BSAD' 'KUNNR' '' '' '' '' '' '' '' '' '' '',
    'NAME1'       'KNA1' 'NAME1' '' '' 'Customer Name' 'Customer Name' 'Customer Name' 'Customer Name' '' '' '' '',
    'BUDAT'       'BSAD' 'BUDAT' '' '' 'Pay. Date' 'Pay. Date' 'Payment Date' 'Payment Date' '' '' '' '',
    'ZFBDT'       'BSAD' 'ZFBDT' '' '' '' '' '' '' '' '' '' '',
    'HARI'        ''     ''      '' '' 'Hari' 'Jml. Hari' 'Jumlah Hari' 'Jumlah Hari' '' '' '' '',
    'WRBTR'       'BSAD' 'WRBTR' '' '' 'AR Amount' 'AR Amount' 'AR Amount' 'AR Amount' '' 'IDR' '' '',
    'PERSEN_DISCOUNT'  '' ''      '' '' 'Persen' 'Persen' 'Persen' 'Persen' '' '' '' '',
    'CASH_DISCOUNT'  'VBRP' 'KZWI5'      '' '' 'Cash Discount' 'Cash Discount' 'Cash Discount' 'Cash Discount' '' 'IDR' '' '',
    'KNUMH'       'KONP' 'KNUMH' '' '12' '' '' '' '' '' '' '' '',
    'CPUDT'       'BSAD' 'CPUDT' '' '' '' '' '' '' '' '' '' ''.

  "    'ICON'        '' '' '' '5' 'Icon' 'Icon' 'Icon' 'Icon' '' '' '' '',
  "    'MESS_ERROR'  '' '' '' '150' 'Message' 'Message' 'Message' 'Message' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_DETAIL' : "ft_report1:
  "  'NOTRANS' 'ZTDNFIDT007D' 'NOTRANS' '' '' '' '' '' '' '' '' '' '',
"      'BELNR'   'BSAD' 'BELNR' '' '' '' '' '' '' '' '' '' '',
      'VBELN'   'VBRP' 'VBELN' '' '' '' '' '' '' '' '' '' '',
      'POSNR'   'VBRP' 'POSNR' '' '' '' '' '' '' '' '' '' '',
      'MATNR'   'VBRP' 'MATNR' '' '' '' '' '' '' '' '' '' '',
      'ARKTX'   'VBRP' 'ARKTX' '' '' '' '' '' '' '' '' '' '',
      'MATKL'   'VBRP' 'MATKL' '' '' '' '' '' '' '' '' '' '',
      'MVGR1'   'VBRP' 'MVGR1' '' '' '' '' '' '' '' '' '' '',
      'KZWI5'   'VBRP' 'KZWI5' '' '' '' 'Amount AR' '' '' '' 'IDR' '' '',
        'CASH_DISCOUNT'  'VBRP' 'KZWI5'      '' '' 'Cash Dicount' 'Cash Dicount' 'Cash Dicount' 'Cash Dicount' '' 'IDR' '' ''.
  "      'VATAMT'  '' '' '' '' '' 'Vat Amount' '' '' '' 'IDR' '' '',
  "      'SHKZG'   'ZTDNFIDT007D' 'SHKZG' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_DETAIL'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

ENDFORM.                    " F_BUILD_FIELDCAT

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
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
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

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA: ls_header LIKE LINE OF gt_header.
  REFRESH: lt_dynpread.

  FIELD-SYMBOLS <fs>.
  CASE fu_ucomm.
    WHEN '&EXECUTE'.
      IF rb_1 = 'X'.
        PERFORM f_posting_data.
      ENDIF.
      fu_selfield-refresh = 'X'.
      "      LEAVE TO SCREEN 0.
    WHEN '&ALL'.
      LOOP AT gt_header INTO ls_header .
        ls_header-chkbx = 'X'.
        MODIFY gt_header FROM ls_header TRANSPORTING chkbx.
      ENDLOOP.
    WHEN '&SAL'.
      LOOP AT gt_header INTO ls_header .
        ls_header-chkbx = ' '.
        MODIFY gt_header FROM ls_header TRANSPORTING chkbx.
      ENDLOOP.

  ENDCASE.
ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
FORM f_build_keyinfo  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'VBELN'.
  fu_keyinfo-item01   = 'VBELN'.
ENDFORM.                    " F_BUILD_KEYINFO


*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv TABLES ft_report ft_report2.
  DATA: lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report ft_report2.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.

  PERFORM f_build_event       TABLES  t_alv_event[].

  "lv_func    = 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
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
      i_tabname_header         = 'GT_HEADER'
      i_tabname_item           = 'GT_DETAIL'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.


ENDFORM.                    "F_ALV
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
  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
  "  fu_layout-expand_all = 'X'.
  IF rb_1 = 'X'.
    fu_layout-box_fieldname      = 'CHKBX'.
  ENDIF.
*  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-fieldname = 'BUKRS'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BUDAT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
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
*&      Form  F_LAST_DAY
*&---------------------------------------------------------------------*
FORM f_last_day  USING    fu_date
                 CHANGING fc_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_date
    IMPORTING
      last_day_of_month = fc_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_posting_data .
  DATA: lt_header TYPE STANDARD TABLE OF ty_header.
  DATA: ls_header LIKE LINE OF gt_header.
  DATA: ls_zghfidt001 TYPE zghfidt001.
  DATA: p_knumh TYPE knumh.
  DATA: lv_bukrs  TYPE bukrs, lv_kunnr TYPE kunnr, lv_reward TYPE vbrp-kzwi5.
  DATA: wa_celltab TYPE lvc_s_styl,
        it_celltab TYPE lvc_t_styl,
        l_index    TYPE i.
  CLEAR ls_header.
  IF p_back = 'X'.
    LOOP AT gt_header INTO ls_header.
      ls_header-chkbx = 'X'.
      MODIFY gt_header FROM ls_header TRANSPORTING chkbx.
    ENDLOOP.
  ENDIF.
  SORT gt_header BY bukrs gjahr vkbur kunnr vbeln.
  CLEAR: lv_bukrs, lv_kunnr, lv_reward.
  LOOP AT gt_header INTO ls_header WHERE chkbx = 'X'.
    lv_bukrs = ls_header-bukrs.
    lv_kunnr = ls_header-kunnr.
    lv_reward = lv_reward + ls_header-cash_discount.
    APPEND ls_header TO lt_header.
    AT END OF kunnr.
      PERFORM f_posting_document USING lv_bukrs lv_kunnr 'INT' lv_reward CHANGING p_knumh.
      IF p_back = 'X'.
        WRITE: / lv_bukrs, sy-vline, lv_kunnr, sy-vline, lv_reward, sy-vline, p_knumh.
      ENDIF.
      LOOP AT lt_header INTO ls_header.
        ls_zghfidt001-vkorg = ls_header-bukrs.
        ls_zghfidt001-vkbur = ls_header-vkbur.
        ls_zghfidt001-vbeln = ls_header-vbeln.
        ls_zghfidt001-kzwi5 = ls_header-tot_kzwi5.
        ls_zghfidt001-kunnr = ls_header-kunnr.
        ls_zghfidt001-hari = ls_header-hari.
        ls_zghfidt001-persen = ls_header-persen_discount. " / 100.
        ls_zghfidt001-reward = ls_header-cash_discount.
        ls_zghfidt001-waers = ls_header-waers.
        ls_zghfidt001-erdat = sy-datum.
        ls_zghfidt001-erzet = sy-uzeit.
        ls_zghfidt001-ernam = sy-uname.
        ls_zghfidt001-knumh = p_knumh.
        ls_zghfidt001-budat = ls_header-budat.
        ls_zghfidt001-wadat_ist = ls_header-zfbdt.
        ls_zghfidt001-wrbtr = ls_header-wrbtr.
        MODIFY zghfidt001 FROM ls_zghfidt001.
      ENDLOOP.
      CLEAR: lt_header[].
      CLEAR: lv_bukrs, lv_kunnr, lv_reward.
    ENDAT.
    ls_header-chkbx = '2'.  " buat off kan check box
    ls_header-knumh = p_knumh.
    MODIFY gt_header FROM ls_header TRANSPORTING chkbx knumh.

    CLEAR: ls_header, ls_zghfidt001, p_knumh.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_REWARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_HEADER_HARI  text
*      -->P_LS_HEADER_BUKRS  text
*      -->P_LS_HEADER_VKBUR  text
*      -->P_LS_HEADER_KDGRP  text
*      -->P_LS_+HEADER_KVGR3  text
*      <--P_LS_HEADER_PERSEN_DISCOUNT  text
*----------------------------------------------------------------------*
FORM f_hitung_reward  USING    p_hari
                               p_bukrs
                               p_vkbur
                               p_kdgrp
                               p_kvgr3
                               p_kunnr
                               p_date
                      CHANGING p_persen_discount.
  DATA: lt_zghfidt002 TYPE STANDARD TABLE OF zghfidt002.
  DATA: ls_zghfidt002 LIKE LINE OF lt_zghfidt002.
  DATA: lv_date TYPE sy-datum.
  lv_date = p_date.

  SELECT * INTO TABLE lt_zghfidt002 FROM zghfidt002
  WHERE vkorg = p_bukrs
"    AND kdgrp = p_kdgrp
"    AND kvgr3 = p_kvgr3
    AND kunnr = p_kunnr
    AND datab <= lv_date AND  datbi >= lv_date.

  IF lt_zghfidt002[] IS INITIAL.
    SELECT * INTO TABLE lt_zghfidt002 FROM zghfidt002
      WHERE vkorg = p_bukrs
        AND kdgrp = p_kdgrp
        AND kvgr3 = p_kvgr3
        AND datab <= lv_date AND  datbi >= lv_date.
  ENDIF.

  IF lt_zghfidt002[] IS INITIAL.
    SELECT * INTO TABLE lt_zghfidt002 FROM zghfidt002
      WHERE vkorg = p_bukrs
        AND kvgr3 = p_kvgr3
        AND datab <= lv_date AND  datbi >= lv_date.
  ENDIF.

  IF lt_zghfidt002[] IS INITIAL.
    SELECT * INTO TABLE lt_zghfidt002 FROM zghfidt002
      WHERE vkorg = p_bukrs
        AND kdgrp = p_kdgrp
        AND datab <= lv_date AND  datbi >= lv_date.
  ENDIF.

  DATA: lv_err(1).
  IF lt_zghfidt002[] IS NOT INITIAL.
    CLEAR: p_persen_discount, lv_err..
    lv_err = 'E'.
    LOOP AT lt_zghfidt002 INTO ls_zghfidt002.
      IF ls_zghfidt002-kunnr = p_kunnr.
        IF p_hari >= ls_zghfidt002-fromdays   AND p_hari <= ls_zghfidt002-todays.
          p_persen_discount = ls_zghfidt002-persen.
          CLEAR: lv_err.
          EXIT.
        ENDIF.
      ENDIF.
      IF ls_zghfidt002-kvgr3 = p_kvgr3.
        IF p_hari >= ls_zghfidt002-fromdays   AND p_hari <= ls_zghfidt002-todays.
          p_persen_discount = ls_zghfidt002-persen.
          CLEAR: lv_err.
          EXIT.
        ENDIF.
      ENDIF.
      IF ls_zghfidt002-kdgrp = p_kdgrp.
        IF p_hari >= ls_zghfidt002-fromdays   AND p_hari <= ls_zghfidt002-todays.
          p_persen_discount = ls_zghfidt002-persen.
          CLEAR: lv_err.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MAINTAIN_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_maintain_table .
  DATA : sellist   TYPE STANDARD TABLE OF vimsellist,
         selopt    TYPE STANDARD TABLE OF selopt INITIAL SIZE 0,
         ls_selopt LIKE LINE OF selopt,
         fieldname TYPE vimsellist-viewfield.

  ls_selopt-low    = p_bukrs.
  ls_selopt-sign   = 'I'.
  ls_selopt-option = 'EQ'.
  APPEND ls_selopt TO selopt.

  fieldname = 'VKORG'.
  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      fieldname = fieldname
    TABLES
      sellist   = sellist
      rangetab  = selopt.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
      view_name                    = 'ZGHFIDT002'
    TABLES
      dba_sellist                  = sellist
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.


ENDFORM.

******&---------------------------------------------------------------------*
******&      Form  F_ALV_REFRESH
******&---------------------------------------------------------------------*
*****FORM f_alv_refresh  USING    fu_refresh.
*****  IF fu_refresh IS NOT INITIAL.
*****    gs_stable-row = 'X'.
*****    gs_stable-col = 'X'.
*****    IF g_tabgrid IS NOT INITIAL.
*****      CALL METHOD g_tabgrid->refresh_table_display
*****        EXPORTING
*****          is_stable = gs_stable.
*****    ENDIF.
*****  ENDIF.
*****ENDFORM.                    " F_ALV_REFRESH
