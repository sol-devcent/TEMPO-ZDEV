*&---------------------------------------------------------------------*
*&  Include           ZM_INCENTIF_UNITED
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_UNITED
*&---------------------------------------------------------------------*
FORM f_united USING fu_flag fu_vkorg.
  SELECT *
    FROM zplbc
    INTO CORRESPONDING FIELDS OF TABLE gt_zplbc
    WHERE reswk IN ship_pnt.

  LOOP AT gt_zplbc.
    ship_pnt-low      = gt_zplbc-werks.
    ship_pnt-sign     = 'I'.
    ship_pnt-option   = 'EQ'.
    APPEND ship_pnt.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ship_pnt COMPARING ALL FIELDS.

  CLEAR : i_tvst[],i_tvst.

  SELECT vstel city1
    FROM tvst
    INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
    INTO TABLE i_tvst
    WHERE vstel IN ship_pnt.

  CASE fu_flag.
    WHEN '0'.
      IF gt_zplbc[] IS NOT INITIAL.
        IF pa_lfart = 'LF'.
          ra_lfart-low    = 'LF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YFI'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
        ENDIF.
      ELSE.
        ra_lfart-low    = pa_lfart.
        ra_lfart-sign   = 'I'.
        ra_lfart-option = 'EQ'.
        APPEND ra_lfart.
      ENDIF.

    WHEN '1'.
      IF gt_zplbc[] IS NOT INITIAL.
        IF pa_lfart = 'LF'.
          ra_lfart-low    = 'LF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'NLCC'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YFI'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
        ENDIF.
      ELSE.
        ra_lfart-low    = pa_lfart.
        ra_lfart-sign   = 'I'.
        ra_lfart-option = 'EQ'.
        APPEND ra_lfart.
      ENDIF.

    WHEN OTHERS.
      IF gt_zplbc[] IS NOT INITIAL.
        IF pa_lfart = 'LF'.
          ra_lfart-low    = 'LF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'NLCC'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YFI'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
        ENDIF.
      ELSE.
        IF fu_vkorg = '8020'.
          ra_lfart-low    = 'LF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
        ELSE.
          ra_lfart-low    = 'YF'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
          ra_lfart-low    = 'YFI'.
          ra_lfart-sign   = 'I'.
          ra_lfart-option = 'EQ'.
          APPEND ra_lfart.
        ENDIF.
      ENDIF.

      sales_org-low     = pa_vkorg.
      sales_org-sign    = 'I'.
      sales_org-option  = 'EQ'.
      APPEND sales_org.
      sales_org-low     = '8070'.
      sales_org-sign    = 'I'.
      sales_org-option  = 'EQ'.
      APPEND sales_org.

      SELECT *
        FROM zplbc
        APPENDING CORRESPONDING FIELDS OF TABLE gt_zplbc
        WHERE werks IN ship_pnt.

      SORT gt_zplbc BY bukrs.
      DELETE ADJACENT DUPLICATES FROM gt_zplbc COMPARING ALL FIELDS.
  ENDCASE.
ENDFORM.                    " F_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UNITED
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UNITED
*&---------------------------------------------------------------------*
FORM f_modify_united  TABLES   ft_result STRUCTURE wa_result.
  DATA : lv_vstel   TYPE vstel,
         lv_subrc   TYPE sy-subrc.
  DATA : lt_result  LIKE wa_result OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_lips OCCURS 0,
           vbeln  TYPE vbeln_vl,
           posnr  TYPE posnr_vl,
           vgbel  TYPE vgbel,
         END OF lt_lips.
  DATA : BEGIN OF lt_ekpo OCCURS 0,
           ebeln  TYPE ebeln,
           ebelp  TYPE ebelp,
           bednr  TYPE bednr,
         END OF lt_ekpo.
  DATA : BEGIN OF lt_vbak OCCURS 0,
           vbeln  TYPE vbeln,
           katr1  TYPE katr1,
         END OF lt_vbak.

  lt_result[] = ft_result[].
  DELETE lt_result WHERE lfart <> 'NLCC'.
  SORT lt_result BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_result COMPARING vbeln.

  IF lt_result[] IS NOT INITIAL.
    SELECT vbeln posnr vgbel
      FROM lips
      INTO TABLE lt_lips
      FOR ALL ENTRIES IN lt_result
      WHERE vbeln = lt_result-vbeln.

    SORT lt_lips BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vgbel.
    IF lt_lips[] IS NOT INITIAL.
      SELECT ebeln ebelp bednr
        FROM ekpo
        INTO TABLE lt_ekpo
        FOR ALL ENTRIES IN lt_lips
        WHERE ebeln = lt_lips-vgbel.

      SORT lt_ekpo BY bednr.
      DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING bednr.
      IF lt_ekpo[] IS NOT INITIAL.
        SELECT vbeln katr1
          FROM vbak JOIN kna1 ON vbak~kunnr = kna1~kunnr
          INTO TABLE lt_vbak
          FOR ALL ENTRIES IN lt_ekpo
          WHERE vbeln = lt_ekpo-bednr.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT ft_result INTO wa_result.
*{   REPLACE        P01K910176                                        1
*\    READ TABLE gt_zplbc WITH KEY werks = wa_result-vstel
*\                        BINARY SEARCH.
*\    IF sy-subrc = 0.
*\      lv_vstel        = wa_result-vstel.
*\      wa_result-vstel = gt_zplbc-reswk.
*\    ENDIF.
*\
*\    READ TABLE lt_lips WITH KEY vbeln = wa_result-vbeln
*\                       BINARY SEARCH.
*\    IF sy-subrc = 0.
*\      READ TABLE lt_ekpo WITH KEY ebeln = lt_lips-vgbel
*\                         BINARY SEARCH.
*\      IF sy-subrc = 0.
*\        READ TABLE lt_vbak WITH KEY vbeln = lt_ekpo-bednr
*\                           BINARY SEARCH.
*\        IF sy-subrc = 0.
*\          wa_result-katr1 = lt_vbak-katr1.
*\        ENDIF.
*\      ENDIF.
*\    ELSE.
    "Start SOH: Shell SCI Adjustment 20240221 KS
    SORT gt_zplbc BY werks.
    READ TABLE gt_zplbc WITH KEY werks = wa_result-vstel
                        BINARY SEARCH.
    IF sy-subrc = 0.
      lv_vstel        = wa_result-vstel.
      wa_result-vstel = gt_zplbc-reswk.
    ENDIF.

    SORT lt_lips BY vbeln.
    READ TABLE lt_lips WITH KEY vbeln = wa_result-vbeln
                       BINARY SEARCH.
    IF sy-subrc = 0.
      SORT lt_ekpo BY ebeln.
      READ TABLE lt_ekpo WITH KEY ebeln = lt_lips-vgbel
                         BINARY SEARCH.
      IF sy-subrc = 0.
        SORT lt_vbak BY vbeln.
        READ TABLE lt_vbak WITH KEY vbeln = lt_ekpo-bednr
                           BINARY SEARCH.
        IF sy-subrc = 0.
          wa_result-katr1 = lt_vbak-katr1.
        ENDIF.
      ENDIF.
    ELSE.
      "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE
      PERFORM f_modify_dklk USING lv_vstel
                            CHANGING lv_subrc wa_result-katr1.
      IF lv_subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.
    MODIFY ft_result FROM wa_result TRANSPORTING vstel katr1.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DKLK
*&---------------------------------------------------------------------*
FORM f_modify_dklk  USING    fu_vstel
                    CHANGING fc_subrc fc_katr1.
  DATA : d_ort01 LIKE kna1-name4,
         i1      TYPE i.

*{   REPLACE        P01K910176                                        1
*\  READ TABLE i_tvst
*\  WITH KEY vstel = fu_vstel
*\  BINARY SEARCH.
*\  wa_result-city1 = i_tvst-city1.
  "Start SOH: Shell SCI Adjustment 20240221 KS
  SORT i_tvst BY vstel.
  READ TABLE i_tvst
  WITH KEY vstel = fu_vstel
  BINARY SEARCH.
  wa_result-city1 = i_tvst-city1.
  "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE

  IF wa_result-kdgrp = '01' OR
   ( wa_result-kdgrp = 'BR' AND wa_result-vstel NE 'A200' ) OR
   ( wa_result-kdgrp = 'BR' AND wa_result-vstel NE 'B102' ).
    fc_subrc = 4.
  ENDIF.

  CHECK fc_subrc IS INITIAL.

  d_ort01 = wa_result-ort01.

  CONDENSE d_ort01 NO-GAPS.
  TRANSLATE d_ort01 TO UPPER CASE.
  TRANSLATE i_tvst-city1 TO UPPER CASE.

  IF wa_result-katr1 IS NOT INITIAL.
    fc_katr1 = wa_result-katr1.
  ELSE.
    i1 = STRLEN( i_tvst-city1 ).
    IF d_ort01(i1) = i_tvst-city1.
      fc_katr1 = 'DK'.
    ELSE.
      IF ( fu_vstel = '0201' OR
           fu_vstel = '0202' OR
           fu_vstel = '0203' ) AND
           d_ort01(7) = 'JAKARTA'.
        fc_katr1 = 'DK'.
      ELSEIF fu_vstel = '0240' AND
           d_ort01(6) = 'MORAWA'.
        fc_katr1 = 'DK'.
      ELSEIF fu_vstel = '0223' AND
         ( d_ort01(5) = 'YOGYA' OR
           d_ort01(8) = 'KOTAGEDE' OR
           d_ort01(6) = 'SLEMAN' OR
           d_ort01(6) = 'GODEAN' ).
        fc_katr1 = 'DK'.
      ELSE.
        fc_katr1 = 'LK'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_DKLK

*&---------------------------------------------------------------------*
*&      Form  F_GET_A511
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_a511 .
  DATA: BEGIN OF lt_sorg OCCURS 0,
          vkorg   TYPE vkorg,
        END OF lt_sorg.

  DATA: BEGIN OF lt_konp OCCURS 0.
          INCLUDE STRUCTURE konp.
  DATA: END OF lt_konp.

* United condition
  lt_sorg-vkorg = pa_vkorg.
  APPEND lt_sorg.
  IF united IS NOT INITIAL.
    IF pa_vkorg = '8020'.
      lt_sorg-vkorg = '8070'.
      APPEND lt_sorg.
    ELSEIF pa_vkorg = '8070'.
      lt_sorg-vkorg = '8020'.
      APPEND lt_sorg.
    ENDIF.
  ENDIF.

  SELECT kappl kschl vkorg vkbur katr1 kdgrp zday1
         zday3 zday4 zday5 zday6 datbi datab
         knumh
    FROM a511
    INTO CORRESPONDING FIELDS OF TABLE t_a511
    FOR ALL ENTRIES IN lt_sorg
    WHERE kappl EQ 'V'
      AND kschl EQ 'ZDLV'
      AND vkorg EQ lt_sorg-vkorg
      AND katr1 NE space
      AND kdgrp NE space
      AND datab LE ra_date-low
      AND datbi GE ra_date-high.

  SELECT kappl kschl vkorg vkbur katr1 kdgrp zday1
         zday3 zday4 zday5 zday6 datbi datab
         knumh
    FROM a511
    APPENDING CORRESPONDING FIELDS OF TABLE t_a511
    FOR ALL ENTRIES IN lt_sorg
    WHERE kappl EQ 'V'
      AND kschl EQ 'ZDLV'
      AND vkorg EQ lt_sorg-vkorg
      AND zday1 NE space
      AND datab LE ra_date-low
      AND datbi GE ra_date-high.

  IF t_a511[] IS NOT INITIAL.
    SORT t_a511 BY knumh.

    SELECT knumh loevm_ko
      FROM konp
      INTO CORRESPONDING FIELDS OF TABLE lt_konp
      FOR ALL ENTRIES IN t_a511
      WHERE knumh EQ t_a511-knumh.

    SORT lt_konp BY knumh.
    LOOP AT t_a511.
      READ TABLE lt_konp WITH KEY knumh = t_a511-knumh
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF lt_konp-loevm_ko EQ 'X'.
          DELETE t_a511.
        ELSE.
          IF t_a511-vkbur IS INITIAL.
            t_a511x  = t_a511.
            APPEND t_a511x.
          ENDIF.
          IF t_a511-zday1 IS NOT INITIAL.
            t_a511y  = t_a511.
            APPEND t_a511y.
          ENDIF.
        ENDIF.
      ELSE.
        DELETE t_a511.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_A511

*&---------------------------------------------------------------------*
*&      Form  F_DATASET
*&---------------------------------------------------------------------*
FORM f_dataset  USING  fu_path fu_vstel fu_datum fu_proc fu_proc1 fu_dpl.

  DATA : l_dataset1(70).

  CONCATENATE fu_path fu_vstel '-' fu_datum+4(2) '_' fu_datum(4) '-DO.TXT'
         INTO l_dataset1.

  OPEN DATASET l_dataset1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.

  IF sy-subrc EQ 0.
    DO.
      READ DATASET l_dataset1 INTO wa_dataset.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

* Correction for read dataset file created using NT
      IF wa_dataset-lgort EQ space.
        wa_dataset-cnt_dn = '1'.
      ENDIF.

      MOVE-CORRESPONDING wa_dataset TO wa_result.

      CASE fu_proc.
        WHEN 'MM'.
          PERFORM f_get_dospgd.

          PERFORM f_get_name1 USING wa_dataset-kunnr
                              CHANGING wa_result-name1.

* Hitung total DO Canvas utk customer group 01
          IF fu_dpl = 'X' AND
            wa_result-kdgrp = '01' AND
            wa_result-lfart = pa_lfart.
            wa_outpl2-vstel = wa_result-vstel.
            wa_outpl2-kdgrp = wa_result-kdgrp.
            wa_outpl2-type  = 'GT'.
            wa_outpl2-total = '1'.
            COLLECT wa_outpl2 INTO i_outpl2.
          ENDIF.

* Delivery Type & Storage Location Check
          CHECK wa_result-lfart IN ra_lfart
            AND ( wa_result-lgort IN ra_lgorti OR
                  wa_result-lgort = '10E0' ).

* Customer Group Check
          CHECK wa_result-kdgrp <> 'BR'
            AND wa_result-kdgrp <> '01'.

          IF fu_proc1 IS NOT INITIAL.
            CHECK wa_result-erdat IN crt_date
              AND wa_result-kunnr IN ship_to
              AND wa_result-vbeln IN del_num
              AND wa_result-erzet IN ent_time
              AND wa_result-kvgr3 IN so_kvgr3 .

            IF wa_result-kdgrp = 'BR'.
              IF ( wa_result-kdgrp = 'BR' AND wa_result-vstel = 'A200' ) OR
                 ( wa_result-kdgrp = 'BR' AND wa_result-vstel = 'B102' ).
                APPEND wa_result TO i_result.
              ENDIF.
            ELSE.
              APPEND wa_result TO i_result.
            ENDIF.
          ELSE.
            CHECK wa_result-kvgr3 IN so_kvgr3 AND
                  wa_result-kunnr IN ship_to AND
                  wa_result-erdat IN crt_date.

            APPEND wa_result TO i_result.
          ENDIF.

        WHEN 'SD'.
* Delivery Type & Storage Location Check
          CHECK wa_result-lfart IN ra_lfart
            AND ( wa_result-lgort IN ra_lgorti OR
                  wa_result-lgort = '10E0' ).

* Customer Group Check
          CHECK wa_result-kdgrp <> 'BR'
            AND wa_result-kdgrp <> '01'.

          PERFORM f_get_dospgd.

          APPEND wa_result TO i_result.
      ENDCASE.
    ENDDO.
  ENDIF.
  CLOSE DATASET l_dataset1.
ENDFORM.                    " F_DATASET

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOSPGD
*&---------------------------------------------------------------------*
FORM f_get_dospgd .
  SELECT SINGLE erdat erzet
    FROM vttp
    INTO (wa_result-erdat_spgd, wa_result-erzet_spgd)
    WHERE vbeln EQ wa_result-vbeln.

  IF wa_result-erdat_spgd <> '00000000'.
    wa_result-do_vs_spgd_dt = wa_result-erdat_spgd - wa_result-erdat.
    PERFORM f_get_holiday USING wa_result-erdat_spgd
                                wa_result-erdat
                          CHANGING wa_result-do_vs_spgd_dt.
    IF wa_result-erzet_spgd < wa_result-erzet.
      wa_result-do_vs_spgd_dt = wa_result-do_vs_spgd_dt - 1.
    ENDIF.
  ELSE.
    wa_result-do_vs_spgd_dt = 999.
  ENDIF.

  IF wa_result-do_vs_spgd_dt < 0.
    wa_result-do_vs_spgd_dt = 0.
  ENDIF.
ENDFORM.                    " F_GET_DOSPGD

*&---------------------------------------------------------------------*
*&      Form  F_GET_NAME1
*&---------------------------------------------------------------------*
FORM f_get_name1  USING    fu_kunnr
                  CHANGING fc_name1.
  SELECT SINGLE name1
    FROM kna1
    INTO fc_name1
    WHERE kunnr EQ fu_kunnr.
ENDFORM.                    " f_get_name1

*&---------------------------------------------------------------------*
*&      Form  F_KDGRP04
*&---------------------------------------------------------------------*
FORM f_kdgrp04 .
  LOOP AT i_result INTO wa_result.
    IF wa_result-kdgrp = '04'.
      DELETE i_result.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " F_KDGRP04

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_TODAY_TRANSACTION
*&---------------------------------------------------------------------*
FORM f_delete_today_transaction .
  REFRESH i_vbeln.
  LOOP AT i_result INTO wa_result WHERE kostk <> 'C'
                                     OR wbstk <> 'C'
                                     OR pdstk <> 'C'.
    IF wa_result-erdat <> sy-datum.
      i_vbeln-vbeln = wa_result-vbeln.
      APPEND i_vbeln.
    ENDIF.
    DELETE TABLE i_result FROM wa_result.
  ENDLOOP.
ENDFORM.                    " F_DELETE_TODAY_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_DISTRICT
*&---------------------------------------------------------------------*
FORM f_get_sales_district .
  DATA: BEGIN OF lt_knvv OCCURS 0,
          kunnr  LIKE knvv-kunnr,
          bzirk  LIKE knvv-bzirk.
  DATA: END OF lt_knvv.

  i_bzirk[]  = i_result[].
  SORT i_bzirk BY kunnr.
  DELETE ADJACENT DUPLICATES FROM i_bzirk COMPARING kunnr.
  IF i_bzirk[] IS NOT INITIAL.
    SELECT kunnr bzirk
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE lt_knvv
      FOR ALL ENTRIES IN i_bzirk
      WHERE kunnr EQ i_bzirk-kunnr.
  ENDIF.

  CLEAR: wa_result.
  LOOP AT i_result INTO wa_result.
    READ TABLE lt_knvv WITH KEY kunnr = wa_result-kunnr.
    IF sy-subrc EQ 0.
      wa_result-bzirk  = lt_knvv-bzirk.
    ELSE.
      CLEAR: wa_result-bzirk.
    ENDIF.
    MODIFY i_result FROM wa_result TRANSPORTING bzirk.
    CLEAR: wa_result.
  ENDLOOP.
ENDFORM.                    " F_GET_SALES_DISTRICT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DO
*&---------------------------------------------------------------------*
FORM f_get_do  USING    fu_flag.
  IF fu_flag IS INITIAL.
    SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
           likp~erzet likp~podat likp~potim likp~wadat_ist
           zmm_cust_rec~crdat zmm_cust_rec~crtim
           knvv~kdgrp knvv~kvgr3 kna1~ort01 kna1~katr1 kna1~name1
           vbuk~kostk vbuk~wbstk vbuk~pdstk knvv~bzirk kna1~katr6
      INTO CORRESPONDING FIELDS OF TABLE i_result2
      FROM ( likp  LEFT JOIN zmm_cust_rec
                          ON zmm_cust_rec~vbeln = likp~vbeln
                  INNER JOIN knvv
                          ON knvv~kunnr = likp~kunnr
                         AND knvv~vkorg = likp~vkorg
                  INNER JOIN kna1
                          ON kna1~kunnr = knvv~kunnr
                  INNER JOIN vbuk
                          ON vbuk~vbeln = likp~vbeln )
      FOR ALL entries IN i_vbeln
      WHERE likp~vbeln = i_vbeln-vbeln
        AND knvv~vtweg = dc
        AND knvv~spart = div
        AND knvv~kvgr3 IN so_kvgr3.
  ELSE.
    SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
           likp~erzet likp~podat likp~potim likp~wadat_ist
           zmm_cust_rec~crdat zmm_cust_rec~crtim
           knvv~kdgrp knvv~kvgr3 kna1~ort01 kna1~katr1 kna1~name1
           vbuk~kostk vbuk~wbstk vbuk~pdstk knvv~bzirk kna1~katr6
      APPENDING CORRESPONDING FIELDS OF TABLE i_result2
      FROM ( likp  LEFT JOIN zmm_cust_rec
                          ON zmm_cust_rec~vbeln = likp~vbeln
                  INNER JOIN knvv
                          ON knvv~kunnr = likp~kunnr
                         AND knvv~vkorg = likp~vkorg
                  INNER JOIN kna1
                          ON kna1~kunnr = knvv~kunnr
                  INNER JOIN vbuk
                          ON vbuk~vbeln = likp~vbeln )
      WHERE likp~vstel IN ship_pnt
        AND likp~kunnr IN ship_to
        AND likp~vbeln IN del_num
        AND likp~erdat EQ sy-datum
        AND knvv~vtweg EQ dc
        AND knvv~spart EQ div
        AND knvv~kvgr3 IN so_kvgr3.
  ENDIF.
ENDFORM.                    " F_GET_DO

*&---------------------------------------------------------------------*
*&      Form  F_CLEANSING_DATA
*&---------------------------------------------------------------------*
FORM f_cleansing_data .
  DELETE i_result2 WHERE lfart = 'LR' OR
                       ( kdgrp = 'BR' AND vstel NE 'A200' ) OR
                       ( kdgrp = 'BR' AND vstel NE 'B102' ).
ENDFORM.                    " F_CLEANSING_DATA

*&---------------------------------------------------------------------*
*&      Form  f_MOVE_DATA
*&---------------------------------------------------------------------*
FORM f_move_data  USING    fu_flag.
  LOOP AT i_result2 INTO wa_result WHERE kdgrp = '01'.
    IF fu_flag IS INITIAL.
      wa_outpl3-vstel = wa_result-vstel.
      wa_outpl3-kdgrp = wa_result-kdgrp.
      wa_outpl3-type  = 'GT'.
      wa_outpl3-total = '1'.
      COLLECT wa_outpl3 INTO i_outpl3.
      APPEND wa_result TO i_result3.
    ELSE.
      wa_outpl2-vstel = wa_result-vstel.
      wa_outpl2-kdgrp = wa_result-kdgrp.
      wa_outpl2-type  = 'GT'.
      wa_outpl2-total = '1'.
      COLLECT wa_outpl2 INTO i_outpl2.
      APPEND wa_result TO i_result3.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MOVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_change_document .
  DATA : i_objectid  TYPE t_objectid OCCURS 0,
         wa_objectid TYPE t_objectid.

  DELETE i_result2 WHERE kdgrp = '01'.

  LOOP AT i_result2 INTO wa_result WHERE kostk = 'C'
                                     OR  kostk IS INITIAL.
    wa_objectid-objectid = wa_result-vbeln.
    APPEND wa_objectid TO i_objectid.
  ENDLOOP.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '30'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  IF i_objectid[] IS NOT INITIAL.
    SELECT objectid changenr fname
      FROM cdpos
      INTO CORRESPONDING FIELDS OF TABLE i_cdpos
      FOR ALL ENTRIES IN i_objectid
      WHERE objectclas = 'LIEFERUNG'
        AND objectid   = i_objectid-objectid
        AND tabname    = 'VBUK'
        AND ( fname    = 'KOQUK'
         OR fname      = 'WBSTK' )
        AND value_new  = 'C'.

    IF i_cdpos[] IS NOT INITIAL.
      SORT i_cdpos BY objectid fname changenr.
      DELETE ADJACENT DUPLICATES FROM i_cdpos COMPARING objectid fname.

      REFRESH i_objectid.
      APPEND LINES OF i_cdpos TO i_objectid.
      DELETE ADJACENT DUPLICATES FROM i_objectid COMPARING changenr.

*-----------------------------------------------------*
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = '50'
          text       = 'Data is being read...'.
*------------------------------------------------------*
      SELECT objectid changenr udate utime
        FROM cdhdr
        INTO CORRESPONDING FIELDS OF TABLE i_cdhdr
        FOR ALL ENTRIES IN i_objectid
        WHERE objectclas = 'LIEFERUNG'
          AND objectid = i_objectid-objectid
          AND changenr = i_objectid-changenr.

      REFRESH i_objectid.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHANGE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_SPGD
*&---------------------------------------------------------------------*
FORM f_get_spgd .
  DATA : lt_vttp  TYPE STANDARD TABLE OF vttp INITIAL SIZE 0
                  WITH HEADER LINE.

  SORT i_result2 BY vbeln.
  IF i_result2[] IS NOT INITIAL.
    SELECT vbeln erdat erzet tknum
      FROM vttp
      INTO CORRESPONDING FIELDS OF TABLE t_vttp
      FOR ALL ENTRIES IN i_result2
      WHERE vbeln EQ i_result2-vbeln.

    lt_vttp[] = t_vttp[].
    SORT lt_vttp BY tknum.
    DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING tknum.

    IF lt_vttp[] IS NOT INITIAL.
      SELECT tknum add04
        FROM vttk
        INTO CORRESPONDING FIELDS OF TABLE t_vttk
        FOR ALL ENTRIES IN lt_vttp
        WHERE tknum = lt_vttp-tknum.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_SPGD

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_FROM_DB
*&---------------------------------------------------------------------*
FORM f_process_data_from_db .
  DATA: BEGIN OF lt_lips OCCURS 0,
          vbeln	TYPE vbeln_vl,
          posnr	TYPE posnr_vl,
          lgort	TYPE lgort_d,
        END OF lt_lips.

  DATA: ld_pk_create_dt   LIKE a511-zday3,
        ld_gi_create_dt   LIKE a511-zday2,
        ld_gi_vs_pk_dt    LIKE a511-zday4,
        ld_spgd_vs_gi_dt  LIKE a511-zday5,
        ld_cr_vs_spgd_dt  LIKE a511-zday6,
        ld_do_vs_spgd_dt  LIKE a511-zday6,
        ld_cr_vs_do_dt    LIKE a511-zday6,
        ld_vkbur          LIKE a511-vkbur,
        ld_datab          LIKE a511-datab,
        ld_datbi          LIKE a511-datbi.

  DATA: ld_sw(1).

  DATA : lv_vgbel   LIKE lips-vgbel,
         lv_erdat   LIKE vbak-erdat,
         lv_erzet   LIKE vbak-erzet.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '70'
      text       = 'Data is being process...'.
*------------------------------------------------------*
  DATA : i1 TYPE i, d_ort01 LIKE kna1-name4,
         d_lgort LIKE lips-lgort.

  DESCRIBE TABLE i_result2 LINES i1.
  IF i1 <= 0.
    EXIT.
  ENDIF.

  SORT t_a511 BY katr1 vkbur kdgrp.

* Completed
  SORT i_cdhdr BY objectid changenr.
  LOOP AT i_cdpos INTO wa_cdpos.
    CLEAR wa_cdhdr.
    READ TABLE i_cdhdr INTO wa_cdhdr
       WITH KEY objectid = wa_cdpos-objectid
                changenr = wa_cdpos-changenr
       BINARY SEARCH.
    wa_cdpos-udate = wa_cdhdr-udate.
    wa_cdpos-utime = wa_cdhdr-utime.
    MODIFY i_cdpos FROM wa_cdpos.
  ENDLOOP.

  REFRESH i_cdhdr. CLEAR wa_cdhdr.

  IF i_result2[] IS NOT INITIAL.
    SELECT vbeln posnr lgort
      FROM lips
      INTO TABLE lt_lips
      FOR ALL ENTRIES IN i_result2
      WHERE vbeln = i_result2-vbeln.
  ENDIF.

  SORT i_result2 BY vbeln.
  SORT lt_lips BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vbeln.

  LOOP AT i_result2 INTO wa_result.

    CLEAR : i1.

* Jika menggunakan left join maka harus cek sloc
    READ TABLE lt_lips WITH KEY vbeln = wa_result-vbeln.
    IF sy-subrc = 0.
      d_lgort = lt_lips-lgort.
    ELSE.
      CLEAR d_lgort.
    ENDIF.

    IF ( d_lgort IN ra_lgorte OR d_lgort = '10E0' ).
      DELETE TABLE i_result2 FROM wa_result.
      CONTINUE.
    ENDIF.

    wa_result-cnt_dn = 1.

*-------------------------*
* Baca SPGD
*-------------------------*
    READ TABLE t_vttp WITH KEY vbeln = wa_result-vbeln.
    IF sy-subrc EQ 0.
      wa_result-erdat_spgd  = t_vttp-erdat.
      wa_result-erzet_spgd  = t_vttp-erzet.
      wa_result-tknum       = t_vttp-tknum.

      CLEAR wa_result-add04.
      IF wa_result-tknum IS NOT INITIAL.
        READ TABLE t_vttk WITH KEY tknum = wa_result-tknum.
        IF sy-subrc = 0.
          wa_result-add04 = t_vttk-add04.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR: wa_result-erdat_spgd, wa_result-erzet_spgd,
             wa_result-tknum, wa_result-add04.
    ENDIF.

*-------------------------*
* Baca Picking date & time
*-------------------------*
    CLEAR wa_cdpos.
* Jika Pick status = C, baca data
    IF wa_result-kostk = 'C'.
      READ TABLE i_cdpos INTO wa_cdpos
         WITH KEY objectid = wa_result-vbeln
                  fname    = 'KOQUK'
         BINARY SEARCH.
      IF sy-subrc = 0.
        wa_result-kodat = wa_cdpos-udate.
        wa_result-kouhr = wa_cdpos-utime.
      ENDIF.
    ENDIF.

*---------------------*
* Baca GI date & time
*---------------------*
    CLEAR wa_cdpos.
* Jika GI status = C, baca data
    IF wa_result-wbstk = 'C'.
      READ TABLE i_cdpos INTO wa_cdpos
         WITH KEY objectid = wa_result-vbeln
                  fname    = 'WBSTK'
         BINARY SEARCH.
      IF sy-subrc = 0.
        wa_result-wadat_ist = wa_cdpos-udate.
        wa_result-gi_time   = wa_cdpos-utime.
      ENDIF.
    ELSE.
      CLEAR : wa_result-wadat_ist, wa_result-gi_time.
    ENDIF.

*---------------------------------------*
* Baca SO/STO Creation Date and Time
*---------------------------------------*
    CLEAR : lv_vgbel, lv_erdat, lv_erzet.

    SELECT SINGLE vgbel
      FROM lips
      INTO lv_vgbel
      WHERE vbeln = wa_result-vbeln.
    IF sy-subrc = 0.
      SELECT SINGLE erdat erzet
      FROM vbak
      INTO (lv_erdat, lv_erzet)
      WHERE vbeln = lv_vgbel.
      IF sy-subrc NE 0.
        SELECT SINGLE aedat
          FROM ekko
          INTO lv_erdat
          WHERE ebeln = lv_vgbel.
      ENDIF.
    ENDIF.

    IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
      wa_result-erdat_so = lv_erdat.
      wa_result-erzet_so = lv_erzet.
    ENDIF.

*------------------*
* Hitung lead time
*------------------*
* Hitung jam
    IF wa_result-kouhr <> '000000'.
*      wa_result-pk_create_tm = wa_result-kouhr - wa_result-erzet.
      IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
        wa_result-pk_create_tm = wa_result-kouhr - wa_result-erzet_so.
      ELSE.
        wa_result-pk_create_tm = wa_result-kouhr - wa_result-erzet.
      ENDIF.
    ENDIF.

    IF wa_result-gi_time <> '000000'.
      IF wa_result-kouhr <> '000000'.
        wa_result-gi_vs_pk_tm = wa_result-gi_time - wa_result-kouhr.
      ENDIF.
    ENDIF.

    IF wa_result-crtim <> '000000'.
*      wa_result-cr_create_tm = wa_result-crtim - wa_result-erzet.
      IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
        wa_result-cr_create_tm = wa_result-crtim - wa_result-erzet_so.
      ELSE.
        wa_result-cr_create_tm = wa_result-crtim - wa_result-erzet.
      ENDIF.
    ENDIF.

    IF wa_result-erzet_spgd <> '000000'.
      wa_result-spgd_vs_gi_tm = wa_result-erzet_spgd - wa_result-gi_time.
    ENDIF.

    IF wa_result-crtim <> '000000'.
      wa_result-cr_vs_spgd_tm = wa_result-crtim - wa_result-erzet_spgd.
    ENDIF.

    IF wa_result-erzet_spgd <> '000000'.
      wa_result-do_vs_spgd_tm = wa_result-erzet_spgd - wa_result-erzet.
    ENDIF.

    IF wa_result-crtim <> '000000'.
      wa_result-cr_vs_gi_tm = wa_result-crtim - wa_result-gi_time.
    ENDIF.

    IF wa_result-gi_time <> '000000'.
*      wa_result-gi_create_tm = wa_result-gi_time - wa_result-erzet.
      IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
        wa_result-gi_create_tm = wa_result-gi_time - wa_result-erzet_so.
      ELSE.
        wa_result-gi_create_tm = wa_result-gi_time - wa_result-erzet.
      ENDIF.
    ENDIF.

* Hitung hari
    IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
      IF wa_result-kodat <> '00000000'.
        wa_result-pk_create_dt = wa_result-kodat - wa_result-erdat_so.
        PERFORM f_get_holiday USING wa_result-kodat
                                    wa_result-erdat_so
                              CHANGING wa_result-pk_create_dt.
        IF wa_result-kouhr < wa_result-erzet_so.
          wa_result-pk_create_dt = wa_result-pk_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-pk_create_dt = sy-datum - wa_result-erdat_so.
      ENDIF.
    ELSE.
      IF wa_result-kodat <> '00000000'.
        wa_result-pk_create_dt = wa_result-kodat - wa_result-erdat.
        PERFORM f_get_holiday USING wa_result-kodat
                                    wa_result-erdat
                              CHANGING wa_result-pk_create_dt.
        IF wa_result-kouhr < wa_result-erzet.
          wa_result-pk_create_dt = wa_result-pk_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-pk_create_dt = sy-datum - wa_result-erdat.
      ENDIF.
    ENDIF.

    IF wa_result-wadat_ist <> '00000000'.
      IF wa_result-kodat <> '00000000'.
        wa_result-gi_vs_pk_dt = wa_result-wadat_ist - wa_result-kodat.
        PERFORM f_get_holiday USING wa_result-wadat_ist
                                    wa_result-kodat
                              CHANGING wa_result-gi_vs_pk_dt.
        IF wa_result-gi_time < wa_result-kouhr.
          wa_result-gi_vs_pk_dt = wa_result-gi_vs_pk_dt - 1.
        ENDIF.
      ENDIF.
      IF wa_result-erdat_spgd <> '00000000'.
        wa_result-spgd_vs_gi_dt = wa_result-erdat_spgd - wa_result-wadat_ist.
        PERFORM f_get_holiday USING wa_result-erdat_spgd
                                    wa_result-wadat_ist
                              CHANGING wa_result-spgd_vs_gi_dt.
        IF wa_result-erzet_spgd < wa_result-gi_time.
          wa_result-spgd_vs_gi_dt = wa_result-spgd_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-spgd_vs_gi_dt = 999.
      ENDIF.
      IF wa_result-crdat <> '00000000'.
        wa_result-cr_vs_gi_dt = wa_result-crdat - wa_result-wadat_ist.
        PERFORM f_get_holiday USING wa_result-crdat
                                    wa_result-wadat_ist
                              CHANGING wa_result-cr_vs_gi_dt.
        IF wa_result-crtim < wa_result-gi_time.
          wa_result-cr_vs_gi_dt = wa_result-cr_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-cr_vs_gi_dt = 999.
      ENDIF.

    ELSE.
      wa_result-gi_vs_pk_dt  = sy-datum - wa_result-kodat.
      PERFORM f_get_holiday USING sy-datum
                                  wa_result-kodat
                            CHANGING wa_result-gi_vs_pk_dt.
      IF wa_result-kodat = '00000000'.
        wa_result-gi_vs_pk_dt = 0.
      ENDIF.
      wa_result-spgd_vs_gi_dt = 999.
    ENDIF.

    IF wa_result-spgd_vs_gi_dt < 0.
      wa_result-spgd_vs_gi_dt = 0.
    ENDIF.

    IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
      IF wa_result-crdat <> '00000000'.
        wa_result-cr_create_dt = wa_result-crdat - wa_result-erdat_so.
        PERFORM f_get_holiday USING wa_result-crdat
                                    wa_result-erdat_so
                              CHANGING wa_result-cr_create_dt.
        IF wa_result-crtim < wa_result-erzet_so.
          wa_result-cr_create_dt = wa_result-cr_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-cr_create_dt = 999.
      ENDIF.
    ELSE.
      IF wa_result-crdat <> '00000000'.
        wa_result-cr_create_dt = wa_result-crdat - wa_result-erdat.
        PERFORM f_get_holiday USING wa_result-crdat
                                    wa_result-erdat
                              CHANGING wa_result-cr_create_dt.
        IF wa_result-crtim < wa_result-erzet.
          wa_result-cr_create_dt = wa_result-cr_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-cr_create_dt = 999.
      ENDIF.
    ENDIF.

    IF wa_result-cr_create_dt < 0.
      wa_result-cr_create_dt = 0.
    ENDIF.

    IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
      IF wa_result-wadat_ist <> '00000000'.
        wa_result-gi_create_dt = wa_result-wadat_ist - wa_result-erdat_so.
        PERFORM f_get_holiday USING wa_result-wadat_ist
                                    wa_result-erdat_so
                              CHANGING wa_result-gi_create_dt.
        IF wa_result-gi_time < wa_result-erzet_so.
          wa_result-gi_create_dt = wa_result-gi_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-gi_create_dt = 999.
      ENDIF.
    ELSE.
      IF wa_result-wadat_ist <> '00000000'.
        wa_result-gi_create_dt = wa_result-wadat_ist - wa_result-erdat.
        PERFORM f_get_holiday USING wa_result-wadat_ist
                                    wa_result-erdat
                              CHANGING wa_result-gi_create_dt.
        IF wa_result-gi_time < wa_result-erzet.
          wa_result-gi_create_dt = wa_result-gi_create_dt - 1.
        ENDIF.
      ELSE.
        wa_result-gi_create_dt = 999.
      ENDIF.
    ENDIF.

    IF wa_result-gi_create_dt < 0.
      wa_result-gi_create_dt = 0.
    ENDIF.

    IF wa_result-crdat <> '00000000'.
*    IF wa_result-erdat_spgd <> '00000000'.
      wa_result-cr_vs_spgd_dt = wa_result-crdat - wa_result-erdat_spgd.
      PERFORM f_get_holiday USING wa_result-crdat
                                  wa_result-erdat_spgd
                            CHANGING wa_result-cr_vs_spgd_dt.
      IF wa_result-crtim < wa_result-erzet_spgd.
        wa_result-cr_vs_spgd_dt = wa_result-cr_vs_spgd_dt - 1.
      ENDIF.
    ELSE.
      wa_result-cr_vs_spgd_dt = 999.
    ENDIF.

    IF wa_result-cr_vs_spgd_dt < 0.
      wa_result-cr_vs_spgd_dt = 0.
    ENDIF.

    IF wa_result-erdat BETWEEN '20170201' AND '20171231'.
      IF wa_result-erdat_spgd <> '00000000'.
        wa_result-do_vs_spgd_dt = wa_result-erdat_spgd - wa_result-erdat_so.
        PERFORM f_get_holiday USING wa_result-erdat_spgd
                                    wa_result-erdat_so
                              CHANGING wa_result-do_vs_spgd_dt.
        IF wa_result-erzet_spgd < wa_result-erzet_so.
          wa_result-do_vs_spgd_dt = wa_result-do_vs_spgd_dt - 1.
        ENDIF.
      ELSE.
        wa_result-do_vs_spgd_dt = 999.
      ENDIF.
    ELSE.
      IF wa_result-erdat_spgd <> '00000000'.
        wa_result-do_vs_spgd_dt = wa_result-erdat_spgd - wa_result-erdat.
        PERFORM f_get_holiday USING wa_result-erdat_spgd
                                    wa_result-erdat
                              CHANGING wa_result-do_vs_spgd_dt.
        IF wa_result-erzet_spgd < wa_result-erzet.
          wa_result-do_vs_spgd_dt = wa_result-do_vs_spgd_dt - 1.
        ENDIF.
      ELSE.
        wa_result-do_vs_spgd_dt = 999.
      ENDIF.
    ENDIF.

    IF wa_result-do_vs_spgd_dt < 0.
      wa_result-do_vs_spgd_dt = 0.
    ENDIF.

*Incentive 2019 DEL Performance.
    IF wa_result-crdat <> '00000000'.
      wa_result-cr2_create_dt = wa_result-crdat - wa_result-erdat_spgd.
      PERFORM f_get_holiday USING wa_result-crdat
                                  wa_result-erdat_spgd
                            CHANGING wa_result-cr2_create_dt.
      IF wa_result-crtim < wa_result-erzet_spgd.
        wa_result-cr2_create_dt = wa_result-cr2_create_dt - 1.
      ENDIF.
    ELSE.
      wa_result-cr2_create_dt = 999.
    ENDIF.

    IF wa_result-cr2_create_dt < 0.
      wa_result-cr2_create_dt = 0.
    ENDIF.



*----------------------------------
* Check dalam kota / luar kota
*----------------------------------
*{   REPLACE        P01K910176                                        1
*\    READ TABLE i_tvst
*\       WITH KEY vstel = wa_result-vstel
*\       BINARY SEARCH.
"Start SOH: Shell SCI Adjustment 20240221 KS
    SORT i_tvst BY vstel.
    READ TABLE i_tvst
       WITH KEY vstel = wa_result-vstel
       BINARY SEARCH.
"End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE
    wa_result-city1 = i_tvst-city1.

    IF wa_result-kdgrp = '01' OR
     ( wa_result-kdgrp = 'BR' AND wa_result-vstel NE 'A200' ) OR
     ( wa_result-kdgrp = 'BR' AND wa_result-vstel NE 'B102' ).
      CONTINUE.
    ENDIF.

    d_ort01 = wa_result-ort01.

    CONDENSE d_ort01 NO-GAPS.
    TRANSLATE d_ort01 TO UPPER CASE.
    TRANSLATE i_tvst-city1 TO UPPER CASE.

    IF wa_result-katr1 IS NOT INITIAL.
      wa_result-dlk = wa_result-katr1.
    ELSE.
      i1 = STRLEN( i_tvst-city1 ).
****************************** Koreksi disini .............
      IF d_ort01(i1) = i_tvst-city1.
        wa_result-dlk = 'DK'.
      ELSE.
        IF ( wa_result-vstel = '0201' OR
             wa_result-vstel = '0202' OR
             wa_result-vstel = '0203' ) AND
             d_ort01(7) = 'JAKARTA'.
          wa_result-dlk = 'DK'.
        ELSEIF wa_result-vstel = '0240' AND
             d_ort01(6) = 'MORAWA'.
          wa_result-dlk = 'DK'.
        ELSEIF wa_result-vstel = '0223' AND
           ( d_ort01(5) = 'YOGYA' OR
             d_ort01(8) = 'KOTAGEDE' OR
             d_ort01(6) = 'SLEMAN' OR
             d_ort01(6) = 'GODEAN' ).
          wa_result-dlk = 'DK'.
        ELSE.
          wa_result-dlk = 'LK'.
        ENDIF.
      ENDIF.
************************** batas disini...............
    ENDIF.
*----------------------------------------
* Calculation for KPI evaluation criteria
*----------------------------------------
    READ TABLE t_a511y WITH KEY zday1 = wa_result-bzirk.
    IF sy-subrc EQ 0.
      ld_pk_create_dt   = t_a511y-zday3.
      ld_gi_create_dt   = t_a511y-zday2.
      ld_gi_vs_pk_dt    = t_a511y-zday4.
      ld_spgd_vs_gi_dt  = t_a511y-zday5.
      ld_cr_vs_spgd_dt  = t_a511y-zday6.
      ld_do_vs_spgd_dt  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
      ld_cr_vs_do_dt    = t_a511y-zday3 + t_a511y-zday4 +
                          t_a511y-zday5 + t_a511y-zday6.
      ld_datab          = t_a511y-datab.
      ld_datbi          = t_a511y-datbi.
      IF t_a511y-vkbur IS NOT INITIAL.
        ld_vkbur = t_a511y-vkbur.
      ELSE.
        CLEAR: ld_vkbur.
      ENDIF.
    ELSE.
      READ TABLE t_a511 WITH KEY katr1 = wa_result-dlk
                                 vkbur = wa_result-vstel
                                 kdgrp = wa_result-kdgrp.
      IF sy-subrc EQ 0.
        ld_pk_create_dt   = t_a511-zday3.
        ld_gi_create_dt   = t_a511-zday2.
        ld_gi_vs_pk_dt    = t_a511-zday4.
        ld_spgd_vs_gi_dt  = t_a511-zday5.
        ld_cr_vs_spgd_dt  = t_a511-zday6.
        ld_do_vs_spgd_dt  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5.
        ld_cr_vs_do_dt    = t_a511-zday3 + t_a511-zday4 +
                            t_a511-zday5 + t_a511-zday6.
        ld_datab          = t_a511-datab.
        ld_datbi          = t_a511-datbi.
        IF t_a511-vkbur IS NOT INITIAL.
          ld_vkbur = t_a511-vkbur.
        ELSE.
          CLEAR: ld_vkbur.
        ENDIF.
      ELSE.
        READ TABLE t_a511x WITH KEY katr1 = wa_result-dlk
                                    kdgrp = wa_result-kdgrp.
        IF sy-subrc EQ 0.
          ld_pk_create_dt   = t_a511x-zday3.
          ld_gi_create_dt   = t_a511x-zday2.
          ld_gi_vs_pk_dt    = t_a511x-zday4.
          ld_spgd_vs_gi_dt  = t_a511x-zday5.
          ld_cr_vs_spgd_dt  = t_a511x-zday6.
          ld_do_vs_spgd_dt  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5.
          ld_cr_vs_do_dt    = t_a511x-zday3 + t_a511x-zday4 +
                              t_a511x-zday5 + t_a511x-zday6.
          ld_datab          = t_a511x-datab.
          ld_datbi          = t_a511x-datbi.
          IF t_a511x-vkbur IS NOT INITIAL.
            ld_vkbur = t_a511x-vkbur.
          ELSE.
            CLEAR: ld_vkbur.
          ENDIF.
        ELSE.
          DELETE i_result2.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE wa_result-kdgrp.
      WHEN '02' OR '03' OR '04' OR '05' OR '06' OR '07' OR '08' OR '09' OR '10'.
        PERFORM f_dk_lk USING ld_datab ld_datbi wa_result-erdat wa_result-kodat wa_result-vstel ld_vkbur
                              ld_pk_create_dt ld_gi_vs_pk_dt ld_spgd_vs_gi_dt ld_cr_vs_spgd_dt ld_do_vs_spgd_dt
                              ld_gi_create_dt ld_cr_vs_do_dt
                        CHANGING wa_result-pkdo wa_result-gipk wa_result-spgdgi wa_result-crspgd wa_result-dospgd
                                 wa_result-gido wa_result-crdo.
    ENDCASE.

    MODIFY i_result2 FROM wa_result.
  ENDLOOP.

  APPEND LINES OF i_result2 TO i_result.

  REFRESH : i_cdpos, i_result2.
  CLEAR   : wa_cdpos, wa_result.
ENDFORM.                    " F_PROCESS_DATA_FROM_DB

*&---------------------------------------------------------------------*
*&      Form  F_SALES_DISTRICT
*&---------------------------------------------------------------------*
FORM f_sales_district USING fu_flag.
  DATA: wa_slsdist  LIKE wa_result.

  SELECT kdgrp ktext FROM t151t
  INTO TABLE i_t151
  WHERE spras EQ 'EN'.
  SORT i_t151 BY kdgrp.

  IF fu_flag EQ 0.
    LOOP AT i_result INTO wa_result.
      IF wa_result-bzirk IS NOT INITIAL.
        wa_result-bzirk = space.
        MODIFY i_result FROM wa_result TRANSPORTING bzirk.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT i_result INTO wa_result.
      IF wa_result-bzirk IS NOT INITIAL.
        wa_slsdist  = wa_result.

        IF cr_date = 'X'.
          IF wa_result-crdat IS INITIAL.
            CONTINUE.
          ENDIF.
        ENDIF.

        APPEND wa_slsdist TO i_slsdist.
        DELETE i_result.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SALES_DISTRICT

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_SLK
*&---------------------------------------------------------------------*
FORM f_detail_slk USING fu_flag fu_func fu_dis fu_wh2 fu_dp2.
  DATA: ld_create_dt LIKE wa_result-cr_create_dt,
        lv_day   TYPE int3,
        lv_01    TYPE int3,
        lv_02    TYPE int3,
        lv_03    TYPE int3,
        lv_04    TYPE int3.

  IF fu_flag = 1.
    CLEAR: wa_outpl6.
    SORT i_slsdist BY bzirk.
    LOOP AT i_slsdist INTO wa_result.
      wa_outpl6-vstel = wa_result-vstel.
      wa_outpl6-kdgrp = wa_result-kdgrp.
      wa_outpl6-dlk = wa_result-dlk.
      wa_outpl6-bzirk = wa_result-bzirk.

      READ TABLE i_t151
         WITH KEY kdgrp = wa_outpl6-kdgrp
         BINARY SEARCH.
      wa_outpl6-ktext = i_t151-ktext.

      CASE wa_outpl6-kdgrp.
        WHEN '04' OR '05' OR '07' OR '10' OR '11' OR 'T1'.
          wa_outpl6-type = 'GT'.
        WHEN '03'.
          IF wa_result-kvgr3 = '031' OR wa_result-kvgr3 = '034'.
            wa_outpl6-ktext = 'SM Key account'.
          ENDIF.
          wa_outpl6-type = 'MT'.
        WHEN '02' OR '06' OR '08' OR '09'.
          wa_outpl6-type = 'Corp. Pharma'.
      ENDCASE.

      CLEAR: ld_create_dt.
      IF fu_dis = 'X'.
        ld_create_dt = wa_result-cr_create_dt.
      ELSEIF fu_wh2 = 'X'.
        ld_create_dt = wa_result-do_vs_spgd_dt.
      ELSEIF fu_dp2 = 'X'.
        ld_create_dt = wa_result-cr_vs_spgd_dt.
      ENDIF.

      READ TABLE t_a511 WITH KEY zday1 = wa_result-bzirk.
      IF sy-subrc EQ 0.
        CASE 'X'.
          WHEN dis OR day.
            lv_day  = t_a511-zday5 + t_a511-zday6.
          WHEN wh1 OR wh2.
            lv_day  = t_a511-zday3 + t_a511-zday4 +
                      t_a511-zday5.
          WHEN dp1 OR dp2.
            lv_day  = t_a511-zday6.
          WHEN fu_wh2.
            IF fu_func = 'SD'.
              lv_day  = t_a511-zday3 + t_a511-zday4 +
                        t_a511-zday5.
            ENDIF.
          WHEN OTHERS.
            lv_day  = t_a511-zday3 + t_a511-zday4 +
                      t_a511-zday5 + t_a511-zday6.
        ENDCASE.
      ENDIF.
      lv_01  = lv_day + 1.
      lv_02  = lv_day + 2.
      lv_03  = lv_day + 3.
      lv_04  = lv_day + 4.

      IF ld_create_dt LT lv_day.
        wa_outpl6-00hari  = 1.
      ENDIF.
      CASE ld_create_dt.
        WHEN lv_day.
          wa_outpl6-06hari  = 1.
        WHEN lv_01.
          wa_outpl6-07hari  = 1.
        WHEN lv_02.
          wa_outpl6-08hari  = 1.
        WHEN lv_03.
          wa_outpl6-09hari  = 1.
      ENDCASE.
      IF ld_create_dt GT lv_03.
        IF cr_date = 'X'.
          IF wa_result-crdat IS NOT INITIAL.
            wa_outpl6-10hari  = 1.
          ENDIF.
        ELSE.
          wa_outpl6-10hari  = 1.
        ENDIF.
      ENDIF.

      wa_outpl6-total = wa_outpl6-00hari + wa_outpl6-06hari + wa_outpl6-07hari +
                        wa_outpl6-08hari + wa_outpl6-09hari + wa_outpl6-10hari.

      IF fu_func = 'SD'.
        IF fu_dis IS NOT INITIAL.
          wa_outpl6-text = 'DLV'.
        ENDIF.
        IF fu_wh2 IS NOT INITIAL.
          wa_outpl6-text = 'WHS'.
        ENDIF.
        IF fu_dp2 IS NOT INITIAL.
          wa_outpl6-text = 'DLP'.
        ENDIF.
      ENDIF.

      COLLECT wa_outpl6 INTO i_outpl6.

      wa_result-ktext = wa_outpl6-ktext.
      wa_result-type = wa_outpl6-type.
      MODIFY i_slsdist FROM wa_result TRANSPORTING ktext type.
      CLEAR: wa_outpl6.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DETAIL_SLK

*&---------------------------------------------------------------------*
*&      Form  F_AVERAGE_KHUSUS
*&---------------------------------------------------------------------*
FORM f_average_khusus USING ld_day fu_flag.
  CLEAR: wa_outpl6, ld_day.
  SORT i_outpl6 BY text type.
  LOOP AT i_outpl6 INTO wa_outpl6.
    PERFORM f_hitung_average_khusus USING wa_outpl6 va_avr ''.
    READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                zday1 = wa_outpl6-bzirk.
    IF sy-subrc EQ 0.
      CASE 'X'.
        WHEN dis OR day.
          ld_day  = t_a511y-zday5 + t_a511y-zday6.
        WHEN wh1 OR wh2.
          ld_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
        WHEN dp1 OR dp2.
          ld_day  = t_a511y-zday6.
        WHEN OTHERS.
          ld_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
      ENDCASE.
    ENDIF.

    PERFORM f_get_percentage USING ld_day wa_outpl6-bzirk wa_outpl6-00hari wa_outpl6-06hari
                                   wa_outpl6-07hari wa_outpl6-08hari wa_outpl6-09hari
                                   wa_outpl6-10hari fu_flag wa_outpl6-total  "wa_outpl6-11hari
                             CHANGING wa_outpl6-std.
    MODIFY i_outpl6 FROM wa_outpl6.
  ENDLOOP.
  SORT i_outpl6 BY text vstel type dlk.
ENDFORM.                    " F_AVERAGE_KHUSUS

*&---------------------------------------------------------------------*
*&      Form  F_GET_PERCENTAGE
*&---------------------------------------------------------------------*
FORM f_get_percentage  USING    fu_day fu_bzirk fu_0hari fu_1hari fu_2hari fu_3hari fu_4hari
                                fu_5hari fu_flag fu_total   "fu_6hari
                       CHANGING fc_std.

  DATA : lv_day   TYPE int3,
         lv_01    TYPE int3,
         lv_02    TYPE int3,
         lv_03    TYPE int3.
*         lv_04    TYPE int3.

  CASE fu_day.
    WHEN 0.
      fc_std = ( fu_0hari / fu_total ) * 100.
    WHEN 1.
      fc_std = ( ( fu_0hari + fu_1hari ) / fu_total ) * 100.
    WHEN 2.
      fc_std = ( ( fu_0hari + fu_1hari + fu_2hari ) / fu_total ) * 100.
    WHEN 3.
      fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari ) / fu_total ) * 100.
    WHEN OTHERS.
      fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari + fu_4hari ) / fu_total ) * 100.
  ENDCASE.

  READ TABLE t_a511 WITH KEY zday1 = fu_bzirk.
  IF sy-subrc EQ 0.
    lv_day  = t_a511-zday3 + t_a511-zday4 +
              t_a511-zday5 + t_a511-zday6.
  ENDIF.

  lv_01  = lv_day + 1.
  lv_02  = lv_day + 2.
  lv_03  = lv_day + 3.
*  lv_04  = lv_day + 4.

  IF fu_flag IS NOT INITIAL.
    IF fu_bzirk IS NOT INITIAL.
      IF fu_day LT lv_day.
*        fc_std = ( fu_0hari / fu_total ) * 100.
        fc_std = ( ( fu_0hari + fu_1hari ) / fu_total ) * 100.
      ENDIF.
      CASE fu_day.
        WHEN lv_day.
          fc_std = ( ( fu_0hari + fu_1hari ) / fu_total ) * 100.
        WHEN lv_01.
          fc_std = ( ( fu_0hari + fu_1hari + fu_2hari ) / fu_total ) * 100.
        WHEN lv_02.
          fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari ) / fu_total ) * 100.
        WHEN lv_03.
          fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari + fu_4hari ) / fu_total ) * 100.
*        WHEN lv_04.
*          fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari + fu_4hari + fu_5hari ) / fu_total ) * 100.
      ENDCASE.
      IF fu_day GT lv_03.
*        fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari + fu_4hari + fu_5hari + fu_6hari ) / fu_total ) * 100.
        fc_std = ( ( fu_0hari + fu_1hari + fu_2hari + fu_3hari + fu_4hari + fu_5hari ) / fu_total ) * 100.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_PERCENTAGE

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_AVERAGE_KHUSUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_average_khusus USING fw_outpl STRUCTURE wa_outpl5
                                   fu_avr fu_tabix.

  DATA: ld_hari   TYPE p.

  CASE fu_avr.
    WHEN 1.
      t_avr-text   = fw_outpl-text.
      t_avr-type   = fw_outpl-type.
      t_avr-dlk    = fw_outpl-dlk.
      t_avr-total  = fw_outpl-total.
      COLLECT t_avr.

    WHEN 2.
      IF fw_outpl-bzirk IS NOT INITIAL.
        IF fw_outpl-target = gv_day01. "1.
          ld_hari  = fw_outpl-00hari + fw_outpl-06hari.
        ELSEIF fw_outpl-target LT gv_day01. "6.
          ld_hari  = fw_outpl-00hari.
        ENDIF.
        CASE fw_outpl-target.
          WHEN gv_day02. "6.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari.
          WHEN gv_day03. "7.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari.
          WHEN gv_day04. "8.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari.
          WHEN gv_day05. "9.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari + fw_outpl-09hari.
          WHEN gv_day06. "10.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari + fw_outpl-09hari + fw_outpl-10hari.
        ENDCASE.
        IF fw_outpl-target GT gv_day06. "10.
          ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                    fw_outpl-08hari + fw_outpl-09hari + fw_outpl-10hari.
*                    fw_outpl-11hari.
        ENDIF.
      ENDIF.

      ADD ld_hari   TO t_avr-hari.
      MODIFY t_avr INDEX fu_tabix TRANSPORTING hari.
  ENDCASE.
ENDFORM.                    " F_HITUNG_AVERAGE_KHUSUS

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_AVERAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_average USING fw_outpl STRUCTURE wa_outpl3 fu_avr fu_tabix.
  DATA: ld_hari   TYPE p,
        ld_hari1  TYPE p.

  CASE fu_avr.
    WHEN 1.
      t_avr-text   = fw_outpl-text.
      t_avr-type   = fw_outpl-type.
      t_avr-dlk    = fw_outpl-dlk.
      t_avr-total  = fw_outpl-total.
      COLLECT t_avr.
    WHEN 2.
      IF pa_chwh1 IS INITIAL.
        CASE fw_outpl-target.
          WHEN 0.
            ld_hari   = fw_outpl-0hari.
          WHEN 1.
            ld_hari   = fw_outpl-0hari + fw_outpl-1hari.
          WHEN 2.
            ld_hari   = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari.
          WHEN 3.
            ld_hari   = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari +
                        fw_outpl-3hari.
          WHEN OTHERS.
            ld_hari   = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari +
                        fw_outpl-3hari + fw_outpl-4hari.
        ENDCASE.
      ELSE.
        ld_hari1   = fw_outpl-0hari + fw_outpl-1hari.
      ENDIF.

      ADD ld_hari TO t_avr-hari.
      ADD ld_hari1 TO t_avr-hari1.
      MODIFY t_avr INDEX fu_tabix TRANSPORTING hari hari1.
  ENDCASE.
ENDFORM.                    " F_HITUNG_AVERAGE

*&---------------------------------------------------------------------*
*&      Form  F_DYNAMIC_DAY
*&---------------------------------------------------------------------*
FORM f_dynamic_day .
  DATA : lt_outpl6 LIKE wa_outpl6 OCCURS 0,
         lv_day(10),
         l_day     TYPE int4.

  lt_outpl6[] = i_outpl6[].
  SORT lt_outpl6 BY bzirk.
  DELETE ADJACENT DUPLICATES FROM lt_outpl6 COMPARING bzirk.

  LOOP AT lt_outpl6 INTO wa_outpl6.
    READ TABLE t_a511 WITH KEY zday1 = wa_outpl6-bzirk.
    IF sy-subrc EQ 0.
      lv_day  = t_a511-zday3 + t_a511-zday4 +
                t_a511-zday5 + t_a511-zday6.
    ENDIF.
    l_day   = lv_day.

    SHIFT lv_day LEFT DELETING LEADING space.

    gv_day01 = lv_day.
    gv_day02 = lv_day.

    DO 3 TIMES.
      l_day = l_day + 1.
      lv_day  = l_day.
      SHIFT lv_day LEFT DELETING LEADING space.
      CASE sy-index.
        WHEN 1.
          gv_day03 = lv_day.

        WHEN 2.
          gv_day04 = lv_day.

        WHEN 3.
          gv_day05 = lv_day.

      ENDCASE.
    ENDDO.
    gv_day06 = lv_day.
  ENDLOOP.
ENDFORM.                    " F_DYNAMIC_DAY
