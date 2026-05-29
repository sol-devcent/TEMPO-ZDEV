*----------------------------------------------------------------------*
*   INCLUDE ZSSUT_R011NEW_2019F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: lv_spmon    LIKE sy-datum.

  CONCATENATE pa_spmon '01' INTO lv_spmon.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_spmon
    IMPORTING
      last_day_of_month = lv_spmon.

  SELECT *
    FROM zsparameter
    INTO TABLE gt_zsparameter
    WHERE vkorg EQ pa_vkorg
      AND paket EQ 'OPP'
      AND type  EQ pa_mvgr2+1(1)
      AND datbi GE sy-datum
      AND datab LE lv_spmon.

  READ TABLE gt_zsparameter INDEX 1.
  IF sy-subrc EQ 0.
    gv_mintgt   = gt_zsparameter-mintgt.
    gv_waerk    = gt_zsparameter-waerk.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF gv_2020 IS INITIAL.
        r_mvgr2-low    = pa_mvgr2.
        r_mvgr2-sign   = 'I'.
        r_mvgr2-option = 'EQ'.
        APPEND r_mvgr2.
      ELSE.
        PERFORM f_mvgr2_select.
      ENDIF.
    WHEN radio3.
      PERFORM f_mvgr2_select.
  ENDCASE.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lr_sptag TYPE RANGE OF sptag,
        lr_lines LIKE LINE OF lr_sptag.

  DATA: ld_sptag1 LIKE sy-datum,
        ld_sptag2 LIKE sy-datum.

  DATA: BEGIN OF lt_knvp OCCURS 0,
          kunnr TYPE kunnr,
          kunn2 TYPE kunn2,
        END OF lt_knvp.

  DATA: BEGIN OF lt_knvv OCCURS 0,
          kunnr  TYPE kunnr,
          name1  TYPE name1_gp,
          kdgrp  TYPE kdgrp,
          katr10 TYPE katr10,
        END OF lt_knvv.

  DATA: lt_s619     LIKE gt_s619 OCCURS 0 WITH HEADER LINE,
        lt_customer LIKE gt_customer OCCURS 0 WITH HEADER LINE.

  DATA: lv_datab TYPE kodatab,
        lv_datbi TYPE kodatbi.

  CONCATENATE pa_spmon '01' INTO lv_datab.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datab
    IMPORTING
      last_day_of_month = lv_datbi.

  IF gt_dnd[] IS INITIAL.
    SELECT SINGLE field_value2
      FROM zspaket_control
      INTO gv_value2
      WHERE vkorg      = pa_vkorg
        AND paket      = 'OPP'
        AND field_name = 'TW1'
        AND datab      LE lv_datbi
        AND datbi      GE lv_datbi.
  ENDIF.

  CONCATENATE pa_spmon '01' INTO lr_lines-low.
  CONCATENATE pa_spmon gv_value2 INTO lr_lines-high.
  lr_lines-sign     = 'I'.
  lr_lines-option   = 'BT'.
  APPEND lr_lines TO lr_sptag.

  CONCATENATE pa_spmon '01' INTO ld_sptag1.
  CONCATENATE pa_spmon gv_value2 INTO ld_sptag2.

  SELECT kunnr kunn2
    FROM knvp
    INTO TABLE lt_knvp
    WHERE kunn2 IN so_route
      AND parvw EQ 'ZS'
      AND kunnr IN so_kunnr.

  IF sy-subrc EQ 0.
*    IF gv_tds IS INITIAL.
*      SELECT knvv~kunnr name1 kdgrp katr10
*        FROM knvv JOIN kna1 ON knvv~kunnr EQ kna1~kunnr
*        INTO TABLE lt_knvv
*        FOR ALL ENTRIES IN lt_knvp
*        WHERE vkbur EQ pa_vkbur
*          AND vkorg EQ pa_vkorg
*          AND knvv~kunnr EQ lt_knvp-kunnr
*          AND konda EQ pa_konda
*          AND kna1~aufsd EQ space
*          AND ( kna1~katr10 <> 'S'
*          AND   kna1~katr10 <> 'K'
*          AND   kna1~katr10 <> space ).
*    ELSE.
    SELECT knvv~kunnr name1 kdgrp katr10
      FROM knvv JOIN kna1 ON knvv~kunnr EQ kna1~kunnr
      INTO TABLE lt_knvv
      FOR ALL ENTRIES IN lt_knvp
      WHERE vkbur EQ pa_vkbur
        AND vkorg EQ pa_vkorg
        AND knvv~kunnr EQ lt_knvp-kunnr
        AND konda EQ pa_konda
        AND kna1~aufsd EQ space.
*    ENDIF.
  ENDIF.

  SORT lt_knvp BY kunnr.
  SORT lt_knvv BY kunnr.
  LOOP AT lt_knvv.
    READ TABLE lt_knvp WITH KEY kunnr = lt_knvv-kunnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_customer-spmon  = pa_spmon.
      gt_customer-vkbur  = pa_vkbur.
      gt_customer-mvgr2  = pa_mvgr2.
      gt_customer-kunnr  = lt_knvv-kunnr.
      gt_customer-name1  = lt_knvv-name1.
      gt_customer-kdgrp  = lt_knvv-kdgrp.
      gt_customer-kunn2  = lt_knvp-kunn2.
      gt_customer-katr10 = lt_knvv-katr10.
      APPEND gt_customer.
    ENDIF.
  ENDLOOP.

  IF gt_customer[] IS NOT INITIAL.
*    IF radio3 IS INITIAL.
*      CLEAR: r_mvgr2,r_mvgr2[].
*      r_mvgr2-low    = pa_mvgr2.
*      r_mvgr2-sign   = 'I'.
*      r_mvgr2-option = 'EQ'.
*      APPEND r_mvgr2.
*    ENDIF.

    IF pa_stat IS INITIAL.
      SELECT vkorg vtweg gjahr spmon vkbur kunnr matnr mvgr2 mvgr3
             waerk zvaltgt class
        FROM zstarget
        INTO TABLE gt_zstarget
        FOR ALL ENTRIES IN gt_customer
        WHERE vkorg EQ pa_vkorg
          AND vtweg EQ '10'
          AND gjahr EQ '0000'
          AND spmon EQ pa_spmon
          AND vkbur EQ pa_vkbur
          AND kunnr EQ gt_customer-kunnr
*          AND mvgr2 EQ pa_mvgr2
          AND mvgr2 IN r_mvgr2
          AND zsts  IN ('A',' ','N').

      SELECT vkorg vtweg gjahr spmon vkbur kunnr matnr mvgr2 mvgr3
             waerk zvaltgt class
        FROM zstarget
        INTO TABLE gt_qtgt
        FOR ALL ENTRIES IN gt_customer
        WHERE vkorg EQ pa_vkorg
          AND vtweg EQ '10'
          AND gjahr EQ '0000'
          AND spmon IN gr_spmon
          AND vkbur EQ pa_vkbur
          AND kunnr EQ gt_customer-kunnr
          AND mvgr2 IN r_mvgr2
          AND zsts  IN ('A',' ','N').
    ELSE.
      SELECT vkorg vtweg gjahr spmon vkbur kunnr matnr mvgr2 mvgr3
             waerk zvaltgt class
        FROM zstarget_old
        INTO TABLE gt_zstarget
        FOR ALL ENTRIES IN gt_customer
        WHERE vkorg EQ pa_vkorg
          AND vtweg EQ '10'
          AND gjahr EQ '0000'
          AND spmon EQ pa_spmon
          AND vkbur EQ pa_vkbur
          AND kunnr EQ gt_customer-kunnr
*          AND mvgr2 EQ pa_mvgr2
          AND mvgr2 IN r_mvgr2
          AND zsts  IN ('A',' ','N').

      SELECT vkorg vtweg gjahr spmon vkbur kunnr matnr mvgr2 mvgr3
             waerk zvaltgt class
        FROM zstarget_old
        INTO TABLE gt_qtgt
        FOR ALL ENTRIES IN gt_customer
        WHERE vkorg EQ pa_vkorg
          AND vtweg EQ '10'
          AND gjahr EQ '0000'
          AND spmon IN gr_spmon
          AND vkbur EQ pa_vkbur
          AND kunnr EQ gt_customer-kunnr
*          AND mvgr2 EQ pa_mvgr2
          AND mvgr2 IN r_mvgr2
          AND zsts  IN ('A',' ','N').
    ENDIF.

    SELECT vrsio spmon vkorg werks vkbur kunnr vbeln matnr
      waerk vrkme grosval lfimg zdisc mvgr2 mvgr3 zzroutel
      FROM s619
      INTO CORRESPONDING FIELDS OF TABLE gt_s619
      FOR ALL ENTRIES IN gt_customer
      WHERE ssour  EQ ''
        AND vrsio  EQ gc_vrsio
        AND spmon  EQ gt_customer-spmon
        AND sptag  EQ '00000000'
        AND spwoc  EQ '000000'
        AND spbup  EQ '000000'
        AND vkorg  EQ pa_vkorg
        AND vkbur  EQ pa_vkbur
        AND kunnr  EQ gt_customer-kunnr
        AND mvgr2  IN r_mvgr2.

    IF gt_s619[] IS NOT INITIAL.
      lt_s619[] = gt_s619[].
      SORT lt_s619 BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_s619 COMPARING vbeln.
      SELECT vbeln erdat vstel vkorg bldat wadat_ist
        INTO TABLE gt_likp
        FROM likp
        FOR ALL ENTRIES IN lt_s619
        WHERE vbeln = lt_s619-vbeln AND
              wadat_ist IN so_gidat.
    ENDIF.
  ENDIF.

  lt_customer[] = gt_customer[].
  SORT lt_customer BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_customer COMPARING kdgrp.
  IF lt_customer[] IS NOT INITIAL.
    SELECT *
      FROM zsclsopp20
      INTO CORRESPONDING FIELDS OF TABLE gt_zsclassopp
      FOR ALL ENTRIES IN lt_customer
      WHERE vkorg  = pa_vkorg
        AND mvgr2  IN r_mvgr2
        AND kdgrp  = lt_customer-kdgrp
        AND class  = 'A'.
  ENDIF.

  IF gt_dnd[] IS INITIAL.
    SELECT * INTO TABLE gt_dnd
      FROM zspaket_control WHERE vkorg EQ pa_vkorg
                             AND paket EQ 'OPP'
                             AND field_name EQ 'DND'
                             AND datab LE gv_date1
                             AND datbi GE gv_date2.
  ENDIF.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_mvgr2reg
    WHERE vkorg      EQ pa_vkorg
      AND paket      EQ 'OPP'
      AND field_name EQ 'MVGR2SLVR'.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_gtcp
    WHERE vkorg      EQ pa_vkorg
      AND paket      EQ 'OPP'
      AND field_name EQ 'KDGRP'.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_clspkt
    WHERE vkorg      EQ pa_vkorg
      AND paket      EQ 'OPP'
      AND field_name EQ 'CLSPKT'.

  SELECT *
    FROM zstarget_control
    INTO CORRESPONDING FIELDS OF TABLE gt_tgtcust
    FOR ALL ENTRIES IN gt_customer
    WHERE vkorg EQ pa_vkorg
      AND paket EQ 'OPP'
      AND field_name EQ 'MVGR2'
      AND kunnr = gt_customer-kunnr.

  SELECT *
    FROM zstarget_control
    INTO CORRESPONDING FIELDS OF TABLE gt_clssp
    FOR ALL ENTRIES IN gt_customer
    WHERE vkorg      = pa_vkorg
      AND paket      = 'OPP'
      AND field_name = 'CLASS'
      AND kunnr = gt_customer-kunnr
      AND datbi GE lv_datbi
      AND datab LE lv_datbi.

  CLEAR : lt_s619[], lt_s619.
  lt_s619[] = gt_s619[].
  SORT lt_s619 BY matnr mvgr2 mvgr3.
  DELETE ADJACENT DUPLICATES FROM lt_s619 COMPARING matnr mvgr2 mvgr3.
  IF lt_s619[] IS NOT INITIAL.
    SELECT *
      FROM a603
      INTO CORRESPONDING FIELDS OF TABLE gt_a603
      FOR ALL ENTRIES IN lt_s619
      WHERE kappl EQ 'V'
        AND kschl EQ 'ZPKT'
        AND vkorg EQ pa_vkorg
        AND konda EQ pa_konda
*        AND datbi GE sy-datum
*        AND datab LE sy-datum
        AND datbi GE lv_datbi
        AND datab LE lv_datbi
        AND matnr EQ lt_s619-matnr
        AND mvgr2 EQ lt_s619-mvgr2
        AND mvgr3 EQ lt_s619-mvgr3.
  ENDIF.

  SORT gt_qtgt BY vkbur kunnr spmon mvgr2.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA_SUT
*---------------------------------------------------------------------*
FORM f_print_data_sut.
  DATA: lv_it(10),      " TYPE zstrike,
        lv_it1(10),     " TYPE zstrike,
        lv_targettxt(15),
        lv_target45      LIKE gt_detail-target,
        lv_percen        TYPE zpercen,
        lv_wb            TYPE zxx,
        lv_qty           TYPE zqty,
        lv_newpage       TYPE char1.

  DATA : ls_param  LIKE LINE OF gt_param,
         lv_cit(3),
         lv_subrc  TYPE sy-subrc,
         lv_valid,
         lv_0.

  DATA : ls_gtcp   LIKE LINE OF gt_gtcp,
         ls_clspkt LIKE LINE OF gt_clspkt.

  SORT gt_header BY mvgr2 routel.
  SORT gt_detail BY routel pkunwe.
  SORT gt_param BY field_value field_value5 field_value2 DESCENDING.

  LOOP AT gt_header.
    ON CHANGE OF gt_header-mvgr2.
      NEW-PAGE.
      lv_newpage = 'X'.
    ENDON.
    ON CHANGE OF gt_header-routel.
      IF lv_newpage IS INITIAL.
        NEW-PAGE.
      ENDIF.
    ENDON.
    CLEAR lv_newpage.
    LOOP AT gt_detail WHERE spmon  EQ gt_header-spmon
                        AND vkbur  EQ gt_header-vkbur
                        AND routel EQ gt_header-routel.
      WRITE:/ sy-vline NO-GAP, (10) gt_detail-pkunwe NO-GAP,
              sy-vline NO-GAP, (25) gt_detail-name1 NO-GAP.

      CLEAR gt_customer.
      READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

      CLEAR ls_gtcp.
      READ TABLE gt_gtcp INTO ls_gtcp
                         WITH KEY field_value2 = gt_customer-kdgrp.

* Material Group 3
      LOOP AT gt_zsclassopp WHERE mvgr2 = gt_header-mvgr2
                              AND kdgrp = gt_customer-kdgrp.
*        LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
*                              AND vkbur  EQ gt_header-vkbur
*                              AND pkunwe EQ gt_detail-pkunwe
*                              AND mvgr3 EQ gt_zsclassopp-mvgr3.
*          WRITE: sy-vline NO-GAP, (8) gt_quantity-qty DECIMALS 0 NO-GAP.
*
*          IF gt_quantity-qty GE gt_zsclassopp-minqty.
*            ADD 1 TO lv_it.
*          ENDIF.
*        ENDLOOP.
*        IF sy-subrc NE 0.
*          WRITE: sy-vline NO-GAP, (8) space NO-GAP.
*        ENDIF.

        CLEAR lv_qty.
        IF gv_2020 IS INITIAL.
          CASE gt_header-mvgr2.
            WHEN '05' OR '06' OR '07' OR '08' OR '09' OR '10'.
              LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
                                    AND vkbur  EQ gt_header-vkbur
                                    AND pkunwe EQ gt_detail-pkunwe
                                    AND mvgr3  EQ gt_zsclassopp-mvgr3.
                ADD gt_quantity-qty TO lv_qty.
                IF gt_quantity-qty GE gt_zsclassopp-minqty.
                  ADD 1 TO lv_it.
                ENDIF.
              ENDLOOP.
              LOOP AT gt_quantity2 WHERE spmon EQ gt_header-spmon
                                     AND vkbur  EQ gt_header-vkbur
                                     AND pkunwe EQ gt_detail-pkunwe
                                     AND mvgr3  EQ gt_zsclassopp-mvgr3.
                ADD gt_quantity2-qty TO lv_qty.
                IF gt_quantity2-qty GE gt_zsclassopp-minqty.
                  ADD 1 TO lv_it1.
                ENDIF.
              ENDLOOP.
            WHEN OTHERS.
              LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
                                    AND vkbur  EQ gt_header-vkbur
                                    AND pkunwe EQ gt_detail-pkunwe
                                    AND mvgr3  EQ gt_zsclassopp-mvgr3.
                ADD gt_quantity-qty TO lv_qty.
                IF gt_quantity-qty GE gt_zsclassopp-minqty.
                  ADD 1 TO lv_it.
                ENDIF.
              ENDLOOP.
              LOOP AT gt_quantity1 WHERE spmon EQ gt_header-spmon
                                    AND vkbur  EQ gt_header-vkbur
                                    AND pkunwe EQ gt_detail-pkunwe
                                    AND mvgr3  EQ gt_zsclassopp-mvgr3.
                ADD gt_quantity1-qty TO lv_qty.
                IF gt_quantity1-qty GE gt_zsclassopp-minqty.
                  ADD 1 TO lv_it1.
                ENDIF.
              ENDLOOP.
          ENDCASE.
        ELSE.
          LOOP AT gt_quantity2 WHERE spmon  EQ gt_header-spmon
                                 AND vkbur  EQ gt_header-vkbur
                                 AND pkunwe EQ gt_detail-pkunwe
                                 AND mvgr3  EQ gt_zsclassopp-mvgr3.
            ADD gt_quantity2-qty TO lv_qty.
            IF gt_quantity2-qty GE gt_zsclassopp-minqty.
              ADD 1 TO lv_it.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF lv_qty IS INITIAL.
          WRITE: sy-vline NO-GAP, (8) space NO-GAP.
        ELSE.
          WRITE: sy-vline NO-GAP, (8) lv_qty DECIMALS 0 NO-GAP.
        ENDIF.
      ENDLOOP.

      SHIFT lv_it LEFT DELETING LEADING space.

* Target rupiah
      READ TABLE gt_clspkt INTO ls_clspkt
                           WITH KEY field_value2 = gt_header-mvgr2
                                    field_value3 = gt_customer-katr10
                                    field_value  = ls_gtcp-field_value.
      IF sy-subrc <> 0.
        CLEAR gt_detail-target.
      ENDIF.

      WRITE gt_detail-target TO lv_targettxt CURRENCY gt_detail-waerk.
      WRITE: sy-vline NO-GAP, lv_targettxt NO-GAP.

* Target rupiah 45%
      CLEAR lv_targettxt.
      IF gv_2020 IS INITIAL.
        IF pa_mvgr2 <> '05' AND
          pa_mvgr2 <> '06' AND
          pa_mvgr2 <> '07' AND
          pa_mvgr2 <> '08' AND
          pa_mvgr2 <> '09' AND
          pa_mvgr2 <> '10'.
          WRITE gt_detail-target45 TO lv_targettxt CURRENCY gt_detail-waerk.
          WRITE: sy-vline NO-GAP, lv_targettxt NO-GAP.
        ENDIF.
      ENDIF.

* Realisasi rupiah
      WRITE: sy-vline NO-GAP, (15) gt_detail-netsales CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

      READ TABLE gt_zsparameter INDEX 1.
      IF lv_it1 LT gt_zsparameter-strike AND lv_it LT gt_zsparameter-strike.  "Strike 1&2 tdk cukup
        CLEAR: gt_detail-wb1%, gt_detail-wb2%, gt_detail-wb1rp,
               gt_detail-wb2rp, gt_detail-wbrp.
      ELSE.
        IF lv_it1 LT gt_zsparameter-strike.                                   "Strike 1 tdk cukup
          gt_detail-wbrp = gt_detail-wbrp - gt_detail-wb1rp.
          CLEAR: gt_detail-wb1%, gt_detail-wb1rp.
        ENDIF.
        IF lv_it LT gt_zsparameter-strike.                                    "Strike 2 tdk cukup
          gt_detail-wbrp = gt_detail-wbrp - gt_detail-wb2rp.
          CLEAR: gt_detail-wb2%, gt_detail-wb2rp.
        ENDIF.
      ENDIF.

      CASE pa_konda.
        WHEN '02' OR '05' OR '09'.
* R:T WB
          IF gv_2020 IS INITIAL.
            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              WRITE: sy-vline NO-GAP, (7) gt_detail-rth115 NO-GAP NO-ZERO.
            ENDIF.
          ENDIF.
          WRITE: sy-vline NO-GAP, (7) gt_detail-rtwb NO-GAP NO-ZERO.

* IT
          IF gv_2020 IS INITIAL.
            SHIFT lv_it1 LEFT DELETING LEADING space.
            WRITE: sy-vline NO-GAP, (3) lv_it1 CENTERED NO-GAP.

            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              lv_cit = lv_it.
              SHIFT lv_cit LEFT DELETING LEADING '0'.
              WRITE: sy-vline NO-GAP, (3) lv_cit CENTERED NO-GAP.
            ELSE.
              WRITE: sy-vline NO-GAP, (3) space CENTERED NO-GAP.
            ENDIF.
          ELSE.
            lv_cit = lv_it.
            SHIFT lv_cit LEFT DELETING LEADING space.
            WRITE: sy-vline NO-GAP, (3) lv_cit CENTERED NO-GAP.
          ENDIF.

* Percen WB
          IF gv_2020 IS INITIAL.
            WRITE: sy-vline NO-GAP, (7) gt_detail-wb1% NO-GAP NO-ZERO.

            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              WRITE: sy-vline NO-GAP, (7) gt_detail-wb2% NO-GAP NO-ZERO.
            ELSE.
              WRITE: sy-vline NO-GAP, (7) space NO-GAP NO-ZERO.
            ENDIF.
          ELSE.
            lv_cit = lv_it.
            SHIFT lv_cit LEFT DELETING LEADING space.
            PERFORM f_write_wb USING gt_detail-rtwb gt_customer-katr10
                               CHANGING lv_subrc lv_cit
                                        gt_detail-wb2% lv_0.
            IF lv_subrc = 0.
              WRITE: sy-vline NO-GAP, (7) gt_detail-wb2% NO-GAP NO-ZERO.
            ELSE.
              WHILE lv_subrc <> 0.
                IF lv_cit < '000'.
                  WRITE: sy-vline NO-GAP, (7) space NO-GAP NO-ZERO.
                  CLEAR lv_subrc.
                ELSE.
                  lv_cit  = lv_cit - 1.
                  PERFORM f_write_wb USING gt_detail-rtwb gt_customer-katr10
                                     CHANGING lv_subrc lv_cit
                                              gt_detail-wb2% lv_0.
                  IF lv_subrc = 0.
                    WRITE: sy-vline NO-GAP, (7) gt_detail-wb2% NO-GAP NO-ZERO.
                    CLEAR lv_subrc.
                  ENDIF.
                ENDIF.
              ENDWHILE.
            ENDIF.
          ENDIF.

* WB Rupiah
          IF gv_2020 IS INITIAL.
            WRITE: sy-vline NO-GAP, (10) gt_detail-wb1rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              WRITE: sy-vline NO-GAP, (15) gt_detail-wb2rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.
            ELSE.
              WRITE: sy-vline NO-GAP, (15) space NO-GAP NO-ZERO.
            ENDIF.
          ELSE.
            IF pa_konda = '05'.
              lv_valid = 'X'.
              PERFORM f_modify_strike CHANGING lv_valid.
              IF lv_valid IS INITIAL.
                IF lv_0 IS INITIAL.
                  gt_detail-wb2rp = ( gt_detail-wb2% * gt_detail-netsales ) / 100.
                  WRITE: sy-vline NO-GAP, (15) gt_detail-wb2rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.
                ELSE.
                  WRITE: sy-vline NO-GAP, (15) space NO-GAP NO-ZERO.
                ENDIF.
              ELSE.
                WRITE: sy-vline NO-GAP, (15) space NO-GAP NO-ZERO.
              ENDIF.
            ELSE.
              IF lv_0 IS INITIAL.
                gt_detail-wb2rp = ( gt_detail-wb2% * gt_detail-netsales ) / 100.
                WRITE: sy-vline NO-GAP, (15) gt_detail-wb2rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

              ELSE.
                WRITE: sy-vline NO-GAP, (15) space NO-GAP NO-ZERO.
              ENDIF.
            ENDIF.
          ENDIF.

*          WRITE: sy-vline NO-GAP, (10) gt_detail-wbrp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

        WHEN '04'.
* R:T WB
          WRITE: sy-vline NO-GAP, (7) gt_detail-rtwb NO-GAP NO-ZERO.

* IT
          SHIFT lv_it1 LEFT DELETING LEADING '0'.
          WRITE: sy-vline NO-GAP, (3) lv_it1 CENTERED NO-GAP.
          SHIFT lv_it LEFT DELETING LEADING '0'.
          WRITE: sy-vline NO-GAP, (3) lv_it CENTERED NO-GAP.

* Percen WB
          WRITE: sy-vline NO-GAP, (7) gt_detail-wb2% NO-GAP NO-ZERO.

* WB Rupiah
          WRITE: sy-vline NO-GAP, (10) gt_detail-wbrp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

        WHEN OTHERS.
      ENDCASE.

      WRITE: sy-vline NO-GAP.
      CLEAR: lv_it,lv_it1,lv_targettxt,lv_wb,lv_percen,lv_qty.

    ENDLOOP.
*    WRITE:/ sy-uline.
    CASE pa_konda.
      WHEN '02' OR '05' OR '09'.
        WRITE:/ sy-uline.
      WHEN '04'.
        WRITE:/ sy-uline(202).
    ENDCASE.
  ENDLOOP.

*  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA_SUT

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  DATA: lv_it            TYPE zstrike,
        lv_targettxt(15),
        lv_target45      LIKE gt_detail-target,
        lv_percen        TYPE zpercen,
        lv_wb            TYPE zxx,
        lv_newpage       TYPE char1.


  SORT gt_header BY mvgr2 routel.
  SORT gt_detail BY routel pkunwe.

  LOOP AT gt_header.
    ON CHANGE OF gt_header-mvgr2.
      NEW-PAGE.
      lv_newpage = 'X'.
    ENDON.
    ON CHANGE OF gt_header-routel.
      IF lv_newpage IS INITIAL.
        NEW-PAGE.
      ENDIF.
    ENDON.
    LOOP AT gt_detail WHERE spmon  EQ gt_header-spmon
                        AND vkbur  EQ gt_header-vkbur
                        AND routel EQ gt_header-routel.
      WRITE:/ sy-vline NO-GAP, (10) gt_detail-pkunwe NO-GAP,
              sy-vline NO-GAP, (25) gt_detail-name1 NO-GAP.

      CLEAR gt_customer.
      READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

* Material Group 3
      LOOP AT gt_zsclassopp WHERE kdgrp = gt_customer-kdgrp.
*        WRITE: sy-vline NO-GAP, (7) gt_zsclassopp-minqty DECIMALS 0 NO-GAP.
        LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
                              AND vkbur  EQ gt_header-vkbur
                              AND pkunwe EQ gt_detail-pkunwe
                              AND mvgr3 EQ gt_zsclassopp-mvgr3.
          WRITE: sy-vline NO-GAP, (8) gt_quantity-qty DECIMALS 0 NO-GAP.

          IF gt_quantity-qty GE gt_zsclassopp-minqty.
            ADD 1 TO lv_it.
          ENDIF.
        ENDLOOP.
        IF sy-subrc NE 0.
          WRITE: sy-vline NO-GAP, (8) space NO-GAP.
        ENDIF.
      ENDLOOP.

* Target rupiah
      WRITE gt_detail-target TO lv_targettxt CURRENCY gt_detail-waerk.
      WRITE: sy-vline NO-GAP, lv_targettxt NO-GAP.

* Target rupiah 45%
      CLEAR lv_targettxt.
      WRITE gt_detail-target45 TO lv_targettxt CURRENCY gt_detail-waerk.
      WRITE: sy-vline NO-GAP, lv_targettxt NO-GAP.

* Realisasi rupiah
      WRITE: sy-vline NO-GAP, (15) gt_detail-netsales CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

      READ TABLE gt_zsparameter INDEX 1.
      IF lv_it LT gt_zsparameter-strike.
        CLEAR: gt_detail-wb1%, gt_detail-wb2%, gt_detail-wb1rp,
               gt_detail-wb2rp, gt_detail-wbrp.
      ENDIF.

* R:T WB
      WRITE: sy-vline NO-GAP, (7) gt_detail-rth115 NO-GAP NO-ZERO.
      WRITE: sy-vline NO-GAP, (7) gt_detail-rtwb NO-GAP NO-ZERO.

* IT
      SHIFT lv_it LEFT DELETING LEADING '0'.
      WRITE: sy-vline NO-GAP, (3) lv_it CENTERED NO-GAP.

* Percen WB
      WRITE: sy-vline NO-GAP, (7) gt_detail-wb1% NO-GAP NO-ZERO.
      WRITE: sy-vline NO-GAP, (7) gt_detail-wb2% NO-GAP NO-ZERO.

* WB Rupiah
      WRITE: sy-vline NO-GAP, (10) gt_detail-wb1rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.
      WRITE: sy-vline NO-GAP, (10) gt_detail-wb2rp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.
      WRITE: sy-vline NO-GAP, (10) gt_detail-wbrp CURRENCY gt_detail-waerk NO-GAP NO-ZERO.

      WRITE: sy-vline NO-GAP.
      CLEAR: lv_it, lv_targettxt, lv_wb, lv_percen.
    ENDLOOP.
    WRITE:/ sy-uline.
  ENDLOOP.

*  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lw_dyn_fcat  TYPE  lvc_s_fcat.

  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  IF radio3 IS INITIAL.
    PERFORM f_build_fieldcat    TABLES  ft_report.
  ELSE.
    CLEAR lw_dyn_fcat.
    LOOP AT gt_dyn_fcat INTO lw_dyn_fcat.
      PERFORM f_fieldcatg USING 'FT_REPORT':
        lw_dyn_fcat-fieldname lw_dyn_fcat-ref_table lw_dyn_fcat-ref_field
        lw_dyn_fcat-no_out lw_dyn_fcat-outputlen lw_dyn_fcat-coltext
        lw_dyn_fcat-do_sum '' '' '' '' lw_dyn_fcat-cfieldname
        lw_dyn_fcat-qfieldname '' '' lw_dyn_fcat-col_pos.
    ENDLOOP.
*    PERFORM f_build_fieldcat3   TABLES  ft_report.
  ENDIF.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
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
  DATA: ld_tgt      TYPE char15,
        ld_sls      TYPE char15,
        ld_tabix(3).

  DEFINE mac_header.
    READ TABLE gt_zsclassopp INDEX &1.
    ld_tabix = &1.
    IF sy-subrc = 0.
      CASE gt_zsclassopp-status.
        WHEN '03'.
          gt_zsclassopp-status = '3A'.
        WHEN '04'.
          gt_zsclassopp-status = '3B'.
        WHEN OTHERS.
      ENDCASE.
      CLEAR: ld_tgt,ld_sls.
*      concatenate 'Tgt OPP ' gt_zsclassopp-status into ld_tgt.
*      concatenate 'Sls OPP ' gt_zsclassopp-status into ld_sls.
      CONCATENATE 'Tgt OPP' ld_tabix INTO ld_tgt SEPARATED BY '-'.
      CONCATENATE 'Sls OPP' ld_tabix INTO ld_sls SEPARATED BY '-'.
      PERFORM f_fieldcatg USING ft_report:
        'TGT&1' '' '' '' '10' ld_tgt '' '' '' 'IDR' '' '' '' '' '' '',
        'SLS&1' '' '' '' '10' ld_sls '' '' '' 'IDR' '' '' '' '' '' ''.
    ENDIF.
  END-OF-DEFINITION.

  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'SPMON' 'S619' 'SPMON' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'S619' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI20' '' '' '' '20' 'SlOff Desc.' '' '' '' '' '' '' '' '' '' '',
    'MVGR2' 'S619' 'MVGR2' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI40' '' '' '' '20' 'Mat. Group Desc.' '' '' '' '' '' '' '' '' '' '',
    'ROUTEL' '' '' '' '10' 'Route' '' '' '' '' '' '' '' '' '' '',
    'NAME_RT' '' '' '' '20' 'Route Name' '' '' '' '' '' '' '' '' '' '',
    'PKUNWE' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TARGET' '' '' '' '15' 'Target Rp.' '' '' '' 'IDR' '' '' '' '' '' '',
    'TARGET45' '' '' '' '15' 'Target Rp. 45%' '' '' '' 'IDR' '' '' '' '' '' '',
    'NETSALES' '' '' '' '15' 'Realisasi Rp.' '' '' '' 'IDR' '' '' '' '' '' '',
    'RTH115' '' '' '' '10' 'R:T% I' '' '' '' '' '' '' '' '' '' '',
    'RTH215' '' '' '' '10' 'R:T% II' '' '' '' '' '' '' '' '' '' '',
    'RTWB' '' '' '' '10' 'R:T% Total' '' '' '' '' '' '' '' '' '' ''.

*  IF pa_vkorg = '8020'.
*    PERFORM f_fieldcatg USING ft_report:
*      'ZSTRIKE' '' '' '' '6' 'Strike' '' '' '' '' '' '' '' '' '' ''.
*  ELSEIF pa_vkorg = '8070'.
  PERFORM f_fieldcatg USING ft_report:
    'ZSTRIKE1' '' '' '' '9' 'Strike I' '' '' '' '' '' '' '' '' '' '',
    'ZSTRIKE' '' '' '' '10' 'Strike II' '' '' '' '' '' '' '' '' '' ''.
*  ENDIF.

  PERFORM f_fieldcatg USING ft_report:
    'WB1%' '' '' '' '10' 'WB% I' '' '' '' '' '' '' '' '' '' '',
    'WB2%' '' '' '' '10' 'WB% II' '' '' '' '' '' '' '' '' '' '',
    'WB1RP' '' '' '' '15' 'WB Rp. I' '' '' '' 'IDR' '' '' '' '' '' '',
    'WB2RP' '' '' '' '15' 'WB Rp. II' '' '' '' 'IDR' '' '' '' '' '' '',
    'WBRP' '' '' '' '15' 'WB Rp. Total' '' '' '' 'IDR' '' '' '' '' '' ''.

  mac_header: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT3
*---------------------------------------------------------------------*
FORM f_build_fieldcat3 TABLES ft_report.
  DATA: ld_tgt TYPE char15,
        ld_tgu TYPE char15,
        ld_sls TYPE char15,
        ld_sl1 TYPE char15,
        ld_str TYPE char15,
        ld_st1 TYPE char15,
        ld_wb  TYPE char15.

  DEFINE mac_header3.
    READ TABLE gt_cntrl INDEX &1.
    IF sy-subrc = 0.
      CLEAR: ld_tgt,ld_tgu,ld_sls,ld_sl1,ld_str,ld_st1,ld_wb.
      IF gt_cntrl-field_value = '99'.
        CONCATENATE 'Sls.' gt_cntrl-field_value INTO ld_sls.
        PERFORM f_fieldcatg USING ft_report:
          'SLS&1' '' '' '' '12' ld_sls '' '' '' 'IDR' '' '' '' '' '' ''.
      ELSE.
        CONCATENATE 'Tgt.' gt_cntrl-field_value INTO ld_tgt.
        CONCATENATE 'Tgt45%.' gt_cntrl-field_value INTO ld_tgu.
        CONCATENATE 'SlsI.' gt_cntrl-field_value INTO ld_sl1.
        CONCATENATE 'Sls.' gt_cntrl-field_value INTO ld_sls.
        CONCATENATE 'StrI.' gt_cntrl-field_value INTO ld_st1.
        CONCATENATE 'StrII.' gt_cntrl-field_value INTO ld_str.
        CONCATENATE '%R/T-I.' gt_cntrl-field_value INTO ld_wb.
        PERFORM f_fieldcatg USING ft_report:
          'TGT&1' '' '' '' '12' ld_tgt '' '' '' 'IDR' '' '' '' '' '' '',
          'TGU&1' '' '' '' '12' ld_tgu '' '' '' 'IDR' '' '' '' '' '' '',
          'SL1&1' '' '' '' '12' ld_sl1 '' '' '' 'IDR' '' '' '' '' '' '',
          'SLS&1' '' '' '' '12' ld_sls '' '' '' 'IDR' '' '' '' '' '' '',
          '%WB&1' '' '' '' '10' ld_wb '' '' '0' '' '' '' '' '' '' '',
          'ST1&1' '' '' '' '10' ld_st1 '' '' '0' '' '' '' '' '' '' '',
          'STR&1' '' '' '' '10' ld_str '' '' '0' '' '' '' '' '' '' ''.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'SPMON' 'S619' 'SPMON' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'S619' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI20' '' '' '' '20' 'SlOff Desc.' '' '' '' '' '' '' '' '' '' '',
    'ROUTEL' '' '' '' '10' 'Route' '' '' '' '' '' '' '' '' '' '',
    'NAME_RT' '' '' '' '20' 'Route Name' '' '' '' '' '' '' '' '' '' '',
    'PKUNWE' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*  IF pa_vkorg = '8020'.
*    PERFORM f_fieldcatg USING ft_report:
*      'ZSTRIKE' '' '' '' '6' 'Strike' '' '' '' '' '' '' '' '' '' ''.
*  ELSEIF pa_vkorg = '8070'.
*    PERFORM f_fieldcatg USING ft_report:
*      'ZSTRIKE' '' '' '' '8' 'Strike I' '' '' '' '' '' '' '' '' '' '',
*      'ZSTRIKE1' '' '' '' '9' 'Strike II' '' '' '' '' '' '' '' '' '' ''.
*  ENDIF.

  mac_header3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
ENDFORM.                    " F_FIELDCAT3

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
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_colpos).

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
  ld_fieldcat-col_pos           = fu_colpos.
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
  fu_layout-colwidth_optimize  = 'X'.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
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
  ld_sort-fieldname = 'ROUTEL'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PKUNWE'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
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
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_header, gt_header[], gt_detail, gt_detail[],
         gt_out, gt_out[].
ENDFORM.                    " F_FREE_MEMORY

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

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data USING fu_mvgr2.
  DATA: lv_target TYPE zvaltgt,
        lv_oppext TYPE zoppext,
        lv_subrc  TYPE sy-subrc.
  DATA: lt_s619    LIKE gt_s619 OCCURS 0 WITH HEADER LINE.
  DATA: lv_rtwb    TYPE p DECIMALS 8.
  DATA: lv_class(30).

  DATA: lv_zvaltgu     TYPE zstarget-zvaltgt.

  SORT gt_likp BY vbeln.
  SORT gt_s619 BY vbeln.
  LOOP AT gt_s619 WHERE mvgr2 = fu_mvgr2.
    lt_s619-spmon   = gt_s619-spmon.
    lt_s619-kunnr   = gt_s619-kunnr.
    lt_s619-vkorg   = gt_s619-vkorg.
    lt_s619-vkbur   = gt_s619-vkbur.
    lt_s619-waerk   = gt_s619-waerk.
    lt_s619-grosval = gt_s619-grosval.
    lt_s619-zdisc   = gt_s619-zdisc.

    IF gv_2020 IS INITIAL.
      CLEAR gt_likp.
      READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE gt_a603 WITH KEY matnr = gt_s619-matnr
                                    mvgr2 = gt_s619-mvgr2
                                    mvgr3 = gt_s619-mvgr3.
        IF sy-subrc = 0.
          CASE fu_mvgr2.
            WHEN '05' OR '06' OR '07' OR '08' OR '09'.
              lt_s619-grosval1 = gt_s619-grosval.
            WHEN OTHERS.
              IF gt_likp-wadat_ist+6(2) LE gv_value2.
                lt_s619-grosval1 = gt_s619-grosval.
              ELSE.
                lt_s619-grosval2 = gt_s619-grosval.
              ENDIF.
          ENDCASE.
          COLLECT lt_s619.
        ELSE.
          DELETE gt_s619.
        ENDIF.
      ELSE.
        DELETE gt_s619.
      ENDIF.
    ELSE.
      CLEAR gt_likp.
      READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE gt_a603 WITH KEY matnr = gt_s619-matnr
                                    mvgr2 = gt_s619-mvgr2
                                    mvgr3 = gt_s619-mvgr3.
        IF sy-subrc = 0.
          lt_s619-grosval1 = gt_s619-grosval.
          COLLECT lt_s619.
        ELSE.
          DELETE gt_s619.
        ENDIF.
      ELSE.
        DELETE gt_s619.
      ENDIF.
    ENDIF.
    CLEAR lt_s619.
  ENDLOOP.

  SORT gt_s619 BY spmon kunnr vkorg vkbur.

  SORT gt_customer BY kunn2.
  LOOP AT gt_customer.
    PERFORM f_get_header USING gt_customer.

    PERFORM f_get_detail TABLES lt_s619
                         USING gt_customer.

*    IF pa_vkorg = '8020'.
*      PERFORM f_get_mvgr3 USING gt_customer.
*    ELSEIF pa_vkorg = '8070'.
    PERFORM f_get_mvgr3_sut USING gt_customer fu_mvgr2.
*    ENDIF.
  ENDLOOP.

*  SORT gt_s626 BY pkunwe matnr.
*  LOOP AT gt_s626.
*    PERFORM f_extra_wb USING gt_s626.
*  ENDLOOP.

  IF gv_2020 IS INITIAL.
    CLEAR : gt_target[], gt_target.
    LOOP AT gt_zstarget.
      gt_target-vkbur   = gt_zstarget-vkbur.
      gt_target-kunnr   = gt_zstarget-kunnr.
      gt_target-waerk   = gt_zstarget-waerk.
      gt_target-zvaltgt = gt_zstarget-zvaltgt.
      COLLECT gt_target.
    ENDLOOP.
  ENDIF.

  LOOP AT gt_header.
    LOOP AT gt_detail.
      PERFORM f_get_target_rp USING gt_header-vkbur
                                    gt_detail-pkunwe
                                    gt_header-spmon
                                    gt_header-mvgr2
                              CHANGING gt_detail-target
                                       gt_detail-waerk
                                       lv_zvaltgu.

      IF gt_detail-target IS NOT INITIAL.
        CLEAR lv_rtwb.
        lv_rtwb  = gt_detail-netsales / gt_detail-target * 100.
        PERFORM f_round USING lv_rtwb
                        CHANGING gt_detail-rtwb.
        CLEAR lv_rtwb.
        lv_rtwb  = gt_detail-netsales1 / gt_detail-target * 100.
        PERFORM f_round USING lv_rtwb
                        CHANGING gt_detail-rth115.
        CLEAR lv_rtwb.
        lv_rtwb  = gt_detail-netsales2 / gt_detail-target * 100.
        PERFORM f_round USING lv_rtwb
                        CHANGING gt_detail-rth215.
      ENDIF.

      IF gt_detail-rth115 GE gt_zsparameter-percen_min.
        gt_detail-wb1% = gt_zsparameter-percen1.
      ENDIF.

      IF gv_2020 IS INITIAL.
        IF gt_detail-rth215 IS NOT INITIAL AND
           gt_detail-rtwb GE 100.
          gt_detail-wb2% = gt_zsparameter-percen2.
        ENDIF.
      ELSE.

      ENDIF.

      IF gt_detail-wb1% IS NOT INITIAL.
        CASE gt_header-mvgr2.
          WHEN '05' OR '06' OR '07' OR '08' OR '09'.
            gt_detail-wb1rp = gt_detail-wb1% *
            ( ( gt_detail-netsales1 + gt_detail-netsales2 ) / 100 ).
          WHEN OTHERS.
            gt_detail-wb1rp = gt_detail-wb1% * gt_detail-netsales1 / 100.
        ENDCASE.
        gt_detail-wbrp = gt_detail-wb1rp.
        IF gt_detail-wb2% IS NOT INITIAL.
          gt_detail-wb2rp = gt_detail-wb2% * gt_detail-netsales2 / 100.
          gt_detail-wbrp = gt_detail-wb1rp + gt_detail-wb2rp.
        ENDIF.
      ELSEIF gt_detail-wb2% IS NOT INITIAL.
        gt_detail-wb2rp = gt_detail-wb2% * gt_detail-netsales / 100.
        gt_detail-wbrp = gt_detail-wb2rp.
      ENDIF.

      gt_detail-target45 = gt_detail-target * 45 / 100.

* Jika paket nya bukan paket drive WB I dan WB II nya di nol kan
      READ TABLE gt_dnd WITH KEY field_value  = pa_spmon+4(2)
                                 field_value2 = pa_mvgr2.
      IF sy-subrc NE 0.
        CLEAR: gt_detail-wb1%,gt_detail-wb2%,gt_detail-wb1rp,
               gt_detail-wb2rp,gt_detail-wbrp.
      ENDIF.

      MODIFY gt_detail TRANSPORTING target target45 waerk wb1% wb2%
                                    wb1rp wb2rp wbrp rtwb rth115 rth215.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER
*&---------------------------------------------------------------------*
FORM f_get_header  USING    fwa_customer STRUCTURE gt_customer.
  gt_header-spmon   = fwa_customer-spmon.
  gt_header-vkbur   = fwa_customer-vkbur.
  gt_header-mvgr2   = fwa_customer-mvgr2.
  gt_header-routel  = fwa_customer-kunn2.
  COLLECT gt_header.
  CLEAR gt_header.
ENDFORM.                    " F_GET_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER1
*&---------------------------------------------------------------------*
FORM f_write_header1  USING    fu_mvgr2.
  DATA: lv_bezei  TYPE bezei40.

  SELECT SINGLE bezei
    FROM tvm2t
    INTO lv_bezei
    WHERE spras EQ sy-langu
      AND mvgr2 EQ fu_mvgr2.

  IF pa_konda EQ '02' OR
    pa_konda EQ '05' OR
    pa_konda EQ '09'.
    CONCATENATE lv_bezei '- Kredit' INTO lv_bezei
    SEPARATED BY space.
    WRITE: / lv_bezei.
  ELSEIF pa_konda EQ '04'.
    CONCATENATE lv_bezei '- Tunai' INTO lv_bezei
    SEPARATED BY space.
    WRITE: / lv_bezei.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER1

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header2 .
  DATA: lv_routel(50),
        lv_bezei      TYPE bezei20,
        lv_name1      TYPE name1_gp,
        lv_min(15).

  lv_routel  = gt_header-routel.
  SELECT SINGLE name1
    FROM kna1
    INTO lv_name1
    WHERE kunnr EQ gt_header-routel.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO lv_bezei
    WHERE spras EQ sy-langu
      AND vkbur EQ pa_vkbur.

  CONCATENATE lv_routel '-' lv_name1 INTO lv_routel
  SEPARATED BY space.

  WRITE gv_mintgt TO lv_min CURRENCY gv_waerk.

  SHIFT lv_min LEFT DELETING LEADING space.

  WRITE:/ 'Tanggal   : ', sy-datum,
        50 'Cabang   :' , lv_bezei,
        100 'Min.Rp  :' , lv_min.
  WRITE:/ 'Routelist : ', lv_routel,
        50 'Bulan    : ', pa_spmon.
ENDFORM.                    " F_WRITE_HEADER2

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER3
*&---------------------------------------------------------------------*
FORM f_write_header3 .
  SORT gt_zsclassopp BY mvgr2 mvgr3.

  CASE pa_konda.
    WHEN '02' OR '05' OR '09'.
      WRITE:/ sy-uline.
    WHEN '04'.
      WRITE:/ sy-uline(202).
  ENDCASE.
*  WRITE:/ sy-vline NO-GAP, (10) space NO-GAP,
*          sy-vline NO-GAP, (25) space NO-GAP.
*  LOOP AT gt_zsclassopp.
*    WRITE:  sy-vline, (13) gt_zsclassopp-status CENTERED.
*  ENDLOOP.

*  IF pa_vkorg = '8020'.
*    PERFORM f_header USING '0'.
*  ELSEIF pa_vkorg = '8070'.
  PERFORM f_header_sut USING '0'.
*  ENDIF.

  WRITE:/ sy-vline NO-GAP, (10) 'Kode' CENTERED NO-GAP,
          sy-vline NO-GAP, (25) 'Nama' CENTERED NO-GAP.
*  LOOP AT gt_zsclassopp.
*    WRITE: sy-vline NO-GAP, sy-uline(15) NO-GAP.
*  ENDLOOP.
  CLEAR gt_customer.
  READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

  LOOP AT gt_zsclassopp WHERE mvgr2 = gt_tvm2-mvgr2
                          AND kdgrp = gt_customer-kdgrp.
    WRITE: sy-vline NO-GAP, (8) gt_zsclassopp-status CENTERED NO-GAP.
  ENDLOOP.

*  IF pa_vkorg = '8020'.
*    PERFORM f_header USING '1'.
*  ELSEIF pa_vkorg = '8070'.
  PERFORM f_header_sut USING '1'.
*  ENDIF.

  WRITE:/ sy-vline NO-GAP, (10) 'Outlet' CENTERED NO-GAP,
          sy-vline NO-GAP, (25) 'Outlet' CENTERED NO-GAP.

*  LOOP AT gt_zsclassopp.
*    WRITE:  sy-vline NO-GAP, (7) 'Target' NO-GAP,
*            sy-vline NO-GAP, (7) 'Sales' NO-GAP.
*  ENDLOOP.

  CLEAR gt_customer.
  READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

  LOOP AT gt_zsclassopp WHERE mvgr2 = gt_tvm2-mvgr2
                          AND kdgrp = gt_customer-kdgrp.
    WRITE:  sy-vline NO-GAP, (8) 'Sales' CENTERED NO-GAP.
  ENDLOOP.

*  IF pa_vkorg = '8020'.
*    PERFORM f_header USING '2'.
*  ELSEIF pa_vkorg = '8070'.
  PERFORM f_header_sut USING '2'.
*  ENDIF.

  CASE pa_konda.
    WHEN '02' OR '05' OR '09'.
      WRITE:/ sy-uline.
    WHEN '04'.
      WRITE:/ sy-uline(202).
  ENDCASE.
ENDFORM.                    " F_WRITE_HEADER3

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_detail  TABLES   ft_s619 STRUCTURE gt_s619
                   USING    fwa_customer STRUCTURE gt_customer.
  gt_detail-spmon    = fwa_customer-spmon.
  gt_detail-vkbur    = fwa_customer-vkbur.
  gt_detail-routel   = fwa_customer-kunn2.
  gt_detail-pkunwe   = fwa_customer-kunnr.
  gt_detail-name1    = fwa_customer-name1.
  READ TABLE ft_s619 WITH KEY spmon = fwa_customer-spmon
                              kunnr = fwa_customer-kunnr
                              vkorg = pa_vkorg
                              vkbur = fwa_customer-vkbur.
  IF sy-subrc EQ 0.
    gt_detail-waerk     = ft_s619-waerk.
    gt_detail-netsales  = ft_s619-grosval.
    gt_detail-netsales1 = ft_s619-grosval1.
    gt_detail-netsales2 = ft_s619-grosval2.
    gt_detail-zdisc     = ft_s619-zdisc.
  ELSE.
    gt_detail-waerk     = 'IDR'.
  ENDIF.
  APPEND gt_detail.
  CLEAR gt_detail.
ENDFORM.                    " F_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_MVGR3
*&---------------------------------------------------------------------*
FORM f_get_mvgr3  USING    fwa_customer STRUCTURE gt_customer.
  LOOP AT gt_s619 WHERE spmon EQ fwa_customer-spmon
                    AND vkbur EQ fwa_customer-vkbur
                    AND kunnr EQ fwa_customer-kunnr.
    gt_quantity-spmon    = gt_s619-spmon.
    gt_quantity-vkbur    = gt_s619-vkbur.
    gt_quantity-pkunwe   = gt_s619-kunnr.
    gt_quantity-mvgr3    = gt_s619-mvgr3.
    gt_quantity-qty      = gt_s619-lfimg.
    COLLECT gt_quantity.

    CLEAR: gt_quantity.
  ENDLOOP.
ENDFORM.                    " F_GET_MVGR3

*&---------------------------------------------------------------------*
*&      Form  F_GET_MVGR3_SUT
*&---------------------------------------------------------------------*
FORM f_get_mvgr3_sut  USING    fwa_customer STRUCTURE gt_customer
                               fu_mvgr2.
  LOOP AT gt_s619 WHERE spmon EQ fwa_customer-spmon
                    AND vkbur EQ fwa_customer-vkbur
                    AND kunnr EQ fwa_customer-kunnr
                    AND mvgr2 EQ fu_mvgr2.

    CLEAR gt_likp.
    READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln.
    IF sy-subrc = 0.
*      IF gt_likp-wadat_ist+6(2) LE gv_value2.               "Strike 1
*        gt_quantity1-spmon    = gt_s619-spmon.
*        gt_quantity1-vkbur    = gt_s619-vkbur.
*        gt_quantity1-pkunwe   = gt_s619-kunnr.
*        gt_quantity1-mvgr3    = gt_s619-mvgr3.
*        gt_quantity1-qty      = gt_s619-lfimg.
*        COLLECT gt_quantity1.
*      ELSE.                                                 "Strike 2
*        gt_quantity-spmon    = gt_s619-spmon.
*        gt_quantity-vkbur    = gt_s619-vkbur.
*        gt_quantity-pkunwe   = gt_s619-kunnr.
*        gt_quantity-mvgr3    = gt_s619-mvgr3.
*        gt_quantity-qty      = gt_s619-lfimg.
*        COLLECT gt_quantity.
*      ENDIF.
      gt_quantity2-spmon    = gt_s619-spmon.
      gt_quantity2-vkbur    = gt_s619-vkbur.
      gt_quantity2-pkunwe   = gt_s619-kunnr.
      gt_quantity2-mvgr3    = gt_s619-mvgr3.
      gt_quantity2-qty      = gt_s619-lfimg.
      COLLECT gt_quantity2.
    ENDIF.

    CLEAR: gt_quantity,gt_quantity1,gt_quantity2.
  ENDLOOP.
ENDFORM.                    " F_GET_MVGR3_SUT

*&---------------------------------------------------------------------*
*&      Form  F_EXTRA_WB
*&---------------------------------------------------------------------*
FORM f_extra_wb  USING    fwa_s626 STRUCTURE gt_s626.
  gt_extrawb-pkunwe   = fwa_s626-pkunwe.
  gt_extrawb-waerk    = fwa_s626-stwae.
  gt_extrawb-totweek  = fwa_s626-umkzwi1 - fwa_s626-gukzwi1.
  COLLECT gt_extrawb.
  CLEAR gt_extrawb.
ENDFORM.                    " F_EXTRA_WB

**&---------------------------------------------------------------------*
**&      Form  F_GET_MVGR2
**&---------------------------------------------------------------------*
*FORM f_get_mvgr2  USING    fwa_s700 STRUCTURE gt_s700.
*
*ENDFORM.                    " F_GET_MVGR2

*&---------------------------------------------------------------------*
*&      Form  F_A603_FILTER
*&---------------------------------------------------------------------*
FORM f_a603_filter  TABLES   ft_key STRUCTURE gt_key.
*  DATA: lv_matnr  TYPE matnr.
*
*  DATA: lt_kna1   LIKE gt_s619 OCCURS 0 WITH HEADER LINE.
*
*  SORT gt_a603 BY matnr knumh DESCENDING.
*  LOOP AT gt_a603.
*    IF gt_a603-matnr EQ lv_matnr.
*      DELETE gt_a603.
*    ENDIF.
*    IF gt_a603-mvgr2 NE pa_mvgr2.
*      DELETE gt_a603.
*    ENDIF.
*    lv_matnr  = gt_a603-matnr.
*  ENDLOOP.
*
*  lt_kna1[] = gt_s619[].
*  SORT lt_kna1 BY kunnr.
*  DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunnr.
*  LOOP AT lt_kna1.
*    ft_key-pkunwe = lt_kna1-kunnr.
*    LOOP AT gt_a603.
*      ft_key-matnr  = gt_a603-matnr.
*      APPEND ft_key.
*    ENDLOOP.
*    CLEAR ft_key.
*  ENDLOOP.
ENDFORM.                    " F_A603_FILTER

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mvgr2    LIKE s619-mvgr2,
        ld_month(2),
        ld_msg(50),
        ld_msg2(20),
        ld_date1    LIKE sy-datum,
        ld_date2    LIKE sy-datum.

  DATA : return    TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
         groups    TYPE STANDARD TABLE OF bapigroups INITIAL SIZE 0,
         ls_groups LIKE LINE OF groups,
         lv_subrc  TYPE sy-subrc.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup(3) = 'TDS'.
      gv_tds = 4.
      EXIT.
    ENDIF.
  ENDLOOP.

  CONCATENATE pa_spmon '01' INTO ld_date1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_date1
    IMPORTING
      last_day_of_month = ld_date2.

  IF pa_konda NE '02' AND
    pa_konda NE '04' AND
    pa_konda NE '05' AND
    pa_konda NE '09'.
    IF gv_tds IS INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'KON'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      MESSAGE e000(zab) WITH 'Type outlet harus 02,04,05,09'.
    ENDIF.
  ENDIF.

  IF radio1 IS NOT INITIAL AND pa_spmon GE '201410'.
    PERFORM f_get_paket_opp.

    LOOP AT gt_tvm2.
      pa_mvgr2 = gt_tvm2-mvgr2.
      CLEAR: ld_mvgr2,ld_month.
      ld_month = pa_spmon+4(2).
      SELECT SINGLE field_value2 INTO ld_mvgr2
        FROM zspaket_control WHERE vkorg = pa_vkorg
                               AND paket = 'OPP'
                               AND field_name = 'DND'
                               AND field_value = ld_month
                               AND field_value2 = pa_mvgr2
                               AND datab LE ld_date1
                               AND datbi GE ld_date2.
      IF sy-subrc NE 0.
        SELECT SINGLE field_value2 INTO ld_mvgr2
          FROM zspaket_control WHERE vkorg = pa_vkorg
                                 AND paket = 'OPP'
                                 AND field_name = 'DND'
                                 AND field_value = ld_month
                                 AND field_value2 = pa_mvgr2.
        IF sy-subrc NE 0.
          IF ld_msg2 IS INITIAL.
            ld_msg2 = pa_mvgr2.
          ELSE.
            CONCATENATE ld_msg2 pa_mvgr2 INTO ld_msg2 SEPARATED BY ','.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gv_tds IS INITIAL.
      IF ld_msg2 IS NOT INITIAL.
        CONCATENATE 'Paket' ld_msg2 'tidak masuk Program Drive di bulan'
                    INTO ld_msg SEPARATED BY space.
        CASE pa_vkorg.
          WHEN '8020'.
            MESSAGE e000(zab) WITH ld_msg pa_spmon.
          WHEN '8070'.
            MESSAGE i000(zab) WITH ld_msg pa_spmon.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_SUT
*&---------------------------------------------------------------------*
FORM f_header_sut  USING    fu_lines.
  CASE fu_lines.
    WHEN '0'.
*      CASE pa_konda.
*        WHEN '02'.
*          WRITE: sy-vline, (13) space,
*                 sy-vline, (13) space,
*                 sy-vline, (5) space,
*                 sy-vline, (5) space,
*                 sy-vline, (8) space,
*                 sy-vline, (8) space,
*                 sy-vline, (5) space,
*                 sy-vline, (6) space NO-GAP,
*                 sy-vline NO-GAP, (3) space NO-GAP,
*                 sy-vline.
*        WHEN '04'.
*          WRITE: sy-vline, (13) space,
*                 sy-vline, (13) space,
*                 sy-vline, (5) space,
*                 sy-vline, (8) space,
*                 sy-vline, (5) space,
*                 sy-vline NO-GAP, (3) space NO-GAP,
*                 sy-vline.
*      ENDCASE.

    WHEN '1'.
      CASE pa_konda.
        WHEN '02' OR '05' OR '09'.
          IF gv_2020 IS INITIAL.
            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Realisasi' CENTERED.
              WRITE: sy-vline, (5) 'R:T I' CENTERED.
              WRITE: sy-vline NO-GAP, (7) 'R:T Tot' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP.
              WRITE: sy-vline, (5) 'WB I' CENTERED.
              WRITE: sy-vline, (5) 'WB II' CENTERED.
              WRITE: sy-vline, (8) 'WB I' CENTERED.
              WRITE: sy-vline, (15) 'WB II' CENTERED.
*              WRITE: sy-vline, (8) 'WB Total' CENTERED.
              WRITE: sy-vline.
            ELSE.
              WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Realisasi' CENTERED.
              WRITE: sy-vline NO-GAP, (7) 'R:T Tot' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP.
              WRITE: sy-vline, (5) 'WB' CENTERED.
              WRITE: sy-vline, (13) 'WB' CENTERED.
*              WRITE: sy-vline, (8) 'WB Total' CENTERED.
              WRITE: sy-vline.
            ENDIF.
          ELSE.
            WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
            WRITE: sy-vline, (13) 'Realisasi' CENTERED.
            WRITE: sy-vline NO-GAP, (7) 'R:T Tot' CENTERED NO-GAP.
            WRITE: sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP.
            WRITE: sy-vline, (5) 'WB' CENTERED.
            WRITE: sy-vline, (13) 'WB' CENTERED.
*            WRITE: sy-vline, (8) 'WB Total' CENTERED.
            WRITE: sy-vline.
          ENDIF.

        WHEN '04'.
          WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
          WRITE: sy-vline, (13) 'Target Rupiah' CENTERED.
          WRITE: sy-vline, (13) 'Realisasi' CENTERED,
                 sy-vline, (5) 'R:T' CENTERED,
                 sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP,
                 sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP,
                 sy-vline, (5) 'WB' CENTERED,
                 sy-vline, (13) 'WB' CENTERED,
                 sy-vline.
      ENDCASE.

    WHEN '2'.
      CASE pa_konda.
        WHEN '02' OR '05' OR '09'.
          IF gv_2020 IS INITIAL.
            IF pa_mvgr2 <> '05' AND
              pa_mvgr2 <> '06' AND
              pa_mvgr2 <> '07' AND
              pa_mvgr2 <> '08' AND
              pa_mvgr2 <> '09' AND
              pa_mvgr2 <> '10'.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
              WRITE: sy-vline, (13) '45%' CENTERED.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
              WRITE: sy-vline, (5) '%' CENTERED.
              WRITE: sy-vline, (6) '%' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) 'I' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) 'II' CENTERED NO-GAP.
              WRITE: sy-vline, (5) '%' CENTERED.
              WRITE: sy-vline, (5) '%' CENTERED.
              WRITE: sy-vline, (8) 'Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
*              WRITE: sy-vline, (8) 'Rupiah' CENTERED.
              WRITE: sy-vline.
            ELSE.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
              WRITE: sy-vline, (6) '%' CENTERED NO-GAP.
              WRITE: sy-vline NO-GAP, (3) space CENTERED NO-GAP.
              WRITE: sy-vline, (5) '%' CENTERED.
              WRITE: sy-vline, (8) 'Rupiah' CENTERED.
              WRITE: sy-vline, (13) 'Rupiah' CENTERED.
              WRITE: sy-vline.
            ENDIF.
          ELSE.
            WRITE: sy-vline, (13) 'Rupiah' CENTERED.
            WRITE: sy-vline, (13) 'Rupiah' CENTERED.
            WRITE: sy-vline, (6) '%' CENTERED NO-GAP.
            WRITE: sy-vline NO-GAP, (3) space CENTERED NO-GAP.
            WRITE: sy-vline, (5) '%' CENTERED.
            WRITE: sy-vline, (13) 'Rupiah' CENTERED.
*            WRITE: sy-vline, (8) 'Rupiah' CENTERED.
            WRITE: sy-vline.
          ENDIF.

        WHEN '04'.
          WRITE: sy-vline, (13) 'Rupiah' CENTERED.
          WRITE: sy-vline, (13) '45%' CENTERED.
          WRITE: sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline NO-GAP, (3) 'I' CENTERED NO-GAP,
                 sy-vline NO-GAP, (3) 'II' CENTERED NO-GAP,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_HEADER_SUT

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  USING    fu_lines.
  CASE fu_lines.
    WHEN '0'.
*      CASE pa_konda.
*        WHEN '02'.
*          WRITE: sy-vline, (13) space,
*                 sy-vline, (13) space,
*                 sy-vline, (5) space,
*                 sy-vline, (5) space,
*                 sy-vline, (8) space,
*                 sy-vline, (8) space,
*                 sy-vline, (5) space,
*                 sy-vline, (6) space NO-GAP,
*                 sy-vline NO-GAP, (3) space NO-GAP,
*                 sy-vline.
*        WHEN '04'.
*          WRITE: sy-vline, (13) space,
*                 sy-vline, (13) space,
*                 sy-vline, (5) space,
*                 sy-vline, (8) space,
*                 sy-vline, (5) space,
*                 sy-vline NO-GAP, (3) space NO-GAP,
*                 sy-vline.
*      ENDCASE.

    WHEN '1'.
      CASE pa_konda.
        WHEN '02'.
          WRITE: sy-vline, (13) 'Target Rupiah' CENTERED,
                 sy-vline, (13) 'Target Rupiah' CENTERED,
                 sy-vline, (13) 'Realisasi' CENTERED,
                 sy-vline, (5) 'R:T I' CENTERED,
                 sy-vline NO-GAP, (7) 'R:T Tot' CENTERED NO-GAP,
                 sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP,
                 sy-vline, (5) 'WB I' CENTERED,
                 sy-vline, (5) 'WB II' CENTERED,
                 sy-vline, (8) 'WB I' CENTERED,
                 sy-vline, (8) 'WB II' CENTERED,
                 sy-vline, (8) 'WB Total' CENTERED,
                 sy-vline.
        WHEN '04'.
          WRITE: sy-vline, (13) 'Target Rupiah' CENTERED,
                 sy-vline, (13) 'Target Rupiah' CENTERED,
                 sy-vline, (13) 'Realisasi' CENTERED,
                 sy-vline, (5) 'R:T' CENTERED,
                 sy-vline NO-GAP, (3) 'IT' CENTERED NO-GAP,
                 sy-vline, (5) 'WB' CENTERED,
                 sy-vline, (8) 'WB' CENTERED,
                 sy-vline.
      ENDCASE.

    WHEN '2'.
      CASE pa_konda.
        WHEN '02'.
          WRITE: sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline, (13) '45%' CENTERED,
                 sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline, (6) '%' CENTERED NO-GAP,
                 sy-vline NO-GAP, (3) 'X' CENTERED NO-GAP,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline, (8) 'Rupiah' CENTERED,
                 sy-vline, (8) 'Rupiah' CENTERED,
                 sy-vline, (8) 'Rupiah' CENTERED,
                 sy-vline.
        WHEN '04'.
          WRITE: sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline, (13) '45%' CENTERED,
                 sy-vline, (13) 'Rupiah' CENTERED,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline NO-GAP, (3) 'X' CENTERED NO-GAP,
                 sy-vline, (5) '%' CENTERED,
                 sy-vline, (8) 'Rupiah' CENTERED,
                 sy-vline.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_GET_TARGET_RP
*&---------------------------------------------------------------------*
FORM f_get_target_rp  USING    fu_vkbur fu_pkunwe fu_spmon fu_mvgr2
                      CHANGING fc_target fc_waerk fc_zvaltgu.

  DATA : ls_tgtcust   LIKE LINE OF gt_tgtcust,
         ls_mvgr2reg  LIKE LINE OF gt_mvgr2reg,
         lv_mvgr2low  TYPE a603-mvgr2,
         lv_mvgr2high TYPE a603-mvgr2,
         lv_kdgrp     TYPE knvv-kdgrp,
         ls_cltgt     LIKE LINE OF gt_cltgt,
         ls_mintgt    LIKE LINE OF gt_mintgt,
         ls_gtcp      LIKE LINE OF gt_gtcp,
         ls_zstarget  LIKE LINE OF gt_zstarget.

  DATA : lv_tgtclass  TYPE zstarget-zvaltgt,
         lv_opptgtreg TYPE zstarget-zvaltgt.

  CLEAR lv_kdgrp.
  READ TABLE gt_customer WITH KEY kunnr = fu_pkunwe.
  IF sy-subrc = 0.
    lv_kdgrp = gt_customer-kdgrp.
  ENDIF.

  READ TABLE gt_gtcp INTO ls_gtcp
                     WITH KEY field_value2 = gt_customer-kdgrp.

  CLEAR ls_cltgt.
  READ TABLE gt_cltgt INTO ls_cltgt
                      WITH KEY field_value = lv_kdgrp.
  IF sy-subrc = 0.
    CLEAR ls_mintgt.
    READ TABLE gt_mintgt INTO ls_mintgt
                         WITH KEY field_value  = ls_cltgt-field_value2
                                  field_value2 = fu_mvgr2.
    IF sy-subrc = 0.
      gv_mintgt = ls_mintgt-field_value3.
    ENDIF.
  ENDIF.

  IF gv_2020 IS INITIAL.
    READ TABLE gt_target WITH KEY vkbur = fu_vkbur
                                  kunnr = fu_pkunwe.
    IF sy-subrc EQ 0.
      IF gt_target-zvaltgt LT gv_mintgt.
        fc_target = gv_mintgt.
        fc_waerk  = gv_waerk.
      ELSE.
        fc_target = gt_target-zvaltgt.
        fc_waerk  = gt_target-waerk.
      ENDIF.
    ELSE.
      fc_target = gv_mintgt.
      fc_target = 0.
      fc_waerk  = gv_waerk.
    ENDIF.

    CLEAR ls_mvgr2reg.
    READ TABLE gt_mvgr2reg INTO ls_mvgr2reg
                           WITH KEY field_value = fu_mvgr2.
    IF sy-subrc <> 0.
      CLEAR ls_tgtcust.
      READ TABLE gt_tgtcust INTO ls_tgtcust
                            WITH KEY kunnr        = fu_pkunwe
                                     field_value1 = fu_spmon
                                     field_value2 = fu_mvgr2.
      IF sy-subrc <> 0.
        CLEAR ls_zstarget.
        READ TABLE gt_zstarget INTO ls_zstarget
                               WITH KEY spmon = fu_spmon
                                        vkbur = fu_vkbur
                                        kunnr = fu_pkunwe
                                        mvgr2 = fu_mvgr2.
        IF sy-subrc <> 0.
          fc_target = 0.
          fc_waerk  = gv_waerk.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR : fc_target, fc_zvaltgu.
    PERFORM f_hitung_target USING fu_vkbur fu_pkunwe fu_mvgr2
                                  gt_customer-katr10 ls_gtcp-field_value
                            CHANGING fc_target fc_zvaltgu.

    PERFORM f_minimum_target USING fc_target lv_kdgrp
                                   fu_mvgr2
                             CHANGING fc_target lv_tgtclass.
  ENDIF.
ENDFORM.                    " F_GET_TARGET_RP

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_alv .
  DATA: lv_bezei20 TYPE bezei40,
        lv_bezei40 TYPE bezei40,
        ld_row     LIKE sy-tabix.

  DATA: BEGIN OF lt_routel OCCURS 0,
          kunnr TYPE kunnr,
          name1 TYPE name1_gp,
        END OF lt_routel.

  DEFINE mac_tgt.
    WHEN '&1'.
      gt_out-tgt&1 = gt_zsclassopp-minqty.
      gt_out-sls&1 = gt_quantity-qty.
  END-OF-DEFINITION.

  IF gt_header[] IS NOT INITIAL.
    SELECT kunnr name1 INTO TABLE lt_routel
      FROM kna1
      FOR ALL ENTRIES IN gt_header
      WHERE kunnr EQ gt_header-routel.

    SELECT SINGLE bezei INTO lv_bezei20
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ pa_vkbur.

    SELECT SINGLE bezei INTO lv_bezei40
      FROM tvm2t
      WHERE spras EQ sy-langu
        AND mvgr2 EQ pa_mvgr2.

    IF pa_konda EQ '02'.
      CONCATENATE lv_bezei40 '- Kredit' INTO lv_bezei40 SEPARATED BY space.
    ELSEIF pa_konda EQ '04'.
      CONCATENATE lv_bezei40 '- Tunai' INTO lv_bezei40 SEPARATED BY space.
    ENDIF.
  ENDIF.

  SORT gt_header BY routel.
  SORT gt_detail BY routel pkunwe.

  LOOP AT gt_header.
    gt_out-spmon = pa_spmon.
    gt_out-vkbur = pa_vkbur.
    gt_out-bezei20 = lv_bezei20.
    gt_out-mvgr2 = pa_mvgr2.
    gt_out-bezei40 = lv_bezei40.
    gt_out-routel = gt_header-routel.
    CLEAR lt_routel.
    READ TABLE lt_routel WITH KEY kunnr = gt_header-routel.
    gt_out-name_rt = lt_routel-name1.

    LOOP AT gt_detail WHERE spmon  EQ gt_header-spmon
                        AND vkbur  EQ gt_header-vkbur
                        AND routel EQ gt_header-routel.

      CLEAR gt_customer.
      READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

* Material Group 3
      LOOP AT gt_zsclassopp WHERE kdgrp = gt_customer-kdgrp.
        ld_row = sy-tabix.
        LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
                              AND vkbur  EQ gt_header-vkbur
                              AND pkunwe EQ gt_detail-pkunwe
                              AND mvgr3 EQ gt_zsclassopp-mvgr3.
          IF gt_quantity-qty GE gt_zsclassopp-minqty.
            ADD 1 TO gt_out-zstrike.
          ENDIF.
        ENDLOOP.
        CASE ld_row.
            mac_tgt: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
        ENDCASE.
        CLEAR: gt_zsclassopp,gt_quantity.
      ENDLOOP.

      MOVE-CORRESPONDING gt_detail TO gt_out.

      READ TABLE gt_zsparameter INDEX 1.
      IF gt_out-zstrike LT gt_zsparameter-strike.
        CLEAR: gt_out-wb1%, gt_out-wb2%, gt_out-wb1rp,
               gt_out-wb2rp, gt_out-wbrp.
      ENDIF.

      APPEND gt_out.
      CLEAR: gt_out-wb1%, gt_out-wb2%, gt_out-wb1rp,
             gt_out-wb2rp, gt_out-wbrp, gt_out-zstrike.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_ALV

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_ALV_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_alv_sut .
  DATA: lv_bezei20 TYPE bezei40,
        lv_bezei40 TYPE bezei40,
        ld_row     LIKE sy-tabix,
        lv_qty     TYPE zqty.

  DATA: BEGIN OF lt_routel OCCURS 0,
          kunnr TYPE kunnr,
          name1 TYPE name1_gp,
        END OF lt_routel.

  DEFINE mac_tgt_sut.
    WHEN '&1'.
      gt_out-tgt&1 = gt_zsclassopp-minqty.
      gt_out-sls&1 = lv_qty.
  END-OF-DEFINITION.

  IF gt_header[] IS NOT INITIAL.
    SELECT kunnr name1 INTO TABLE lt_routel
      FROM kna1
      FOR ALL ENTRIES IN gt_header
      WHERE kunnr EQ gt_header-routel.

    SELECT SINGLE bezei INTO lv_bezei20
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ pa_vkbur.

    SELECT SINGLE bezei INTO lv_bezei40
      FROM tvm2t
      WHERE spras EQ sy-langu
        AND mvgr2 EQ pa_mvgr2.

    IF pa_konda EQ '02'.
      CONCATENATE lv_bezei40 '- Kredit' INTO lv_bezei40 SEPARATED BY space.
    ELSEIF pa_konda EQ '04'.
      CONCATENATE lv_bezei40 '- Tunai' INTO lv_bezei40 SEPARATED BY space.
    ENDIF.
  ENDIF.

  SORT gt_header BY routel.
  SORT gt_detail BY routel pkunwe.

  LOOP AT gt_header.
    gt_out-spmon = pa_spmon.
    gt_out-vkbur = pa_vkbur.
    gt_out-bezei20 = lv_bezei20.
    gt_out-mvgr2 = pa_mvgr2.
    gt_out-bezei40 = lv_bezei40.
    gt_out-routel = gt_header-routel.
    CLEAR lt_routel.
    READ TABLE lt_routel WITH KEY kunnr = gt_header-routel.
    gt_out-name_rt = lt_routel-name1.

    LOOP AT gt_detail WHERE spmon  EQ gt_header-spmon
                        AND vkbur  EQ gt_header-vkbur
                        AND routel EQ gt_header-routel.

      CLEAR gt_customer.
      READ TABLE gt_customer WITH KEY kunnr = gt_detail-pkunwe.

* Material Group 3
      LOOP AT gt_zsclassopp WHERE kdgrp = gt_customer-kdgrp.
        ld_row = sy-tabix.
        CLEAR lv_qty.
        LOOP AT gt_quantity1 WHERE spmon  EQ gt_header-spmon
                               AND vkbur  EQ gt_header-vkbur
                               AND pkunwe EQ gt_detail-pkunwe
                               AND mvgr3 EQ gt_zsclassopp-mvgr3.
          ADD gt_quantity1-qty TO lv_qty.
          IF gt_quantity1-qty GE gt_zsclassopp-minqty.
            ADD 1 TO gt_out-zstrike1.
          ENDIF.
        ENDLOOP.
        LOOP AT gt_quantity WHERE spmon  EQ gt_header-spmon
                              AND vkbur  EQ gt_header-vkbur
                              AND pkunwe EQ gt_detail-pkunwe
                              AND mvgr3 EQ gt_zsclassopp-mvgr3.
          ADD gt_quantity-qty TO lv_qty.
          IF gt_quantity-qty GE gt_zsclassopp-minqty.
            ADD 1 TO gt_out-zstrike.
          ENDIF.
        ENDLOOP.
        CASE ld_row.
            mac_tgt_sut: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
        ENDCASE.
        CLEAR: gt_zsclassopp,gt_quantity,gt_quantity1.
      ENDLOOP.

      MOVE-CORRESPONDING gt_detail TO gt_out.

      READ TABLE gt_zsparameter INDEX 1.
*      IF gt_out-zstrike LT gt_zsparameter-strike.
*        CLEAR: gt_out-wb1%, gt_out-wb2%, gt_out-wb1rp,
*               gt_out-wb2rp, gt_out-wbrp.
*      ENDIF.
      IF gt_out-zstrike1 LT gt_zsparameter-strike AND
         gt_out-zstrike LT gt_zsparameter-strike.                   "Strike 1&2 tdk cukup
        CLEAR: gt_out-wb1%, gt_out-wb2%, gt_out-wb1rp,
               gt_out-wb2rp, gt_out-wbrp.
      ELSE.
        IF gt_out-zstrike1 LT gt_zsparameter-strike.                 "Strike 1 tdk cukup
          gt_out-wbrp = gt_out-wbrp - gt_out-wb1rp.
          CLEAR: gt_out-wb1%, gt_out-wb1rp.
        ENDIF.
        IF gt_out-zstrike LT gt_zsparameter-strike.                  "Strike 2 tdk cukup
          gt_out-wbrp = gt_out-wbrp - gt_out-wb2rp.
          CLEAR: gt_out-wb2%, gt_out-wb2rp.
        ENDIF.
      ENDIF.

      APPEND gt_out.
      CLEAR: gt_out-wb1%,gt_out-wb2%,gt_out-wb1rp,gt_out-wb2rp,
             gt_out-wbrp,gt_out-zstrike,gt_out-zstrike1.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_ALV_SUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data3 .
  DATA: lv_bezei20 TYPE bezei20,
        ld_row     LIKE sy-tabix,
        ld_grosval LIKE gt_s619-grosval.

  DATA: BEGIN OF lt_routel OCCURS 0,
          kunnr TYPE kunnr,
          name1 TYPE name1_gp,
        END OF lt_routel.

  DEFINE mac_tgt3.
    WHEN '&1'.
      gt_out-tgt&1 = gt_zstarget-zvaltgt.
  END-OF-DEFINITION.

  DEFINE mac_tgu3.
    WHEN '&1'.
      gt_out-tgu&1 = gt_zstarget-zvaltgt * 45 / 100.
  END-OF-DEFINITION.

  DEFINE mac_sls3.
    WHEN '&1'.
      gt_out-sls&1 = gt_s619-grosval.
      gt_out-sl1&1 = ld_grosval.
  END-OF-DEFINITION.

  DEFINE mac_str3.
    WHEN '&1'.
      gt_out-str&1 = gt_out-str&1 + 1.
  END-OF-DEFINITION.

  DEFINE mac_st13.
    WHEN '&1'.
      gt_out-st1&1 = gt_out-st1&1 + 1.
  END-OF-DEFINITION.

  SELECT SINGLE bezei INTO lv_bezei20
    FROM tvkbt
    WHERE spras EQ sy-langu
      AND vkbur EQ pa_vkbur.

  SELECT kunnr name1 INTO TABLE lt_routel
    FROM kna1
    FOR ALL ENTRIES IN gt_customer
    WHERE kunnr EQ gt_customer-kunn2.

  SORT gt_likp BY vbeln.
  SORT gt_s619 BY vbeln.
  LOOP AT gt_s619.
    READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      IF gt_likp-wadat_ist+6(2) LE gv_value2.               "Strike 1
        gt_quantity1-spmon    = gt_s619-spmon.
        gt_quantity1-vkbur    = gt_s619-vkbur.
        gt_quantity1-pkunwe   = gt_s619-kunnr.
        gt_quantity1-mvgr2    = gt_s619-mvgr2.
        gt_quantity1-mvgr3    = gt_s619-mvgr3.
        gt_quantity1-qty      = gt_s619-lfimg.
        COLLECT gt_quantity1. CLEAR gt_quantity1.
      ELSE.                                                 "Strike 2
        gt_quantity-spmon    = gt_s619-spmon.
        gt_quantity-vkbur    = gt_s619-vkbur.
        gt_quantity-pkunwe   = gt_s619-kunnr.
        gt_quantity-mvgr2    = gt_s619-mvgr2.
        gt_quantity-mvgr3    = gt_s619-mvgr3.
        gt_quantity-qty      = gt_s619-lfimg.
        COLLECT gt_quantity. CLEAR gt_quantity.
      ENDIF.
    ELSE.
      gt_quantity-spmon    = gt_s619-spmon.
      gt_quantity-vkbur    = gt_s619-vkbur.
      gt_quantity-pkunwe   = gt_s619-kunnr.
      gt_quantity-mvgr2    = gt_s619-mvgr2.
      gt_quantity-mvgr3    = gt_s619-mvgr3.
      gt_quantity-qty      = gt_s619-lfimg.
      COLLECT gt_quantity. CLEAR gt_quantity.
    ENDIF.
  ENDLOOP.

  SORT gt_likp BY vbeln.
  SORT gt_s619 BY vkbur kunnr mvgr2 vbeln.
  SORT gt_customer BY vkbur kunnr mvgr2.
  SORT lt_routel BY kunnr.

  LOOP AT gt_s619.
    CLEAR: gt_customer,lt_routel.
    READ TABLE gt_customer WITH KEY vkbur = gt_s619-vkbur
                                    kunnr = gt_s619-kunnr
                           BINARY SEARCH.

    READ TABLE lt_routel WITH KEY kunnr = gt_customer-kunn2.

    gt_out-spmon = pa_spmon.
    gt_out-vkbur = gt_s619-vkbur.
    gt_out-bezei20 = lv_bezei20.
    gt_out-pkunwe = gt_s619-kunnr.
    gt_out-name1 = gt_customer-name1.
    gt_out-routel = gt_customer-kunn2.
    gt_out-name_rt = lt_routel-name1.

    CLEAR: ld_grosval,gt_likp.
    READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      IF gt_likp-wadat_ist+6(2) LE gv_value2.               "Sales 1
        ld_grosval = gt_s619-grosval.
      ENDIF.
    ELSE.
      SORT gt_likp BY vbeln.
      READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        IF gt_likp-wadat_ist+6(2) LE gv_value2.             "Sales 1
          ld_grosval = gt_s619-grosval.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE gt_cntrl WITH KEY field_value = gt_s619-mvgr2.
    IF sy-subrc = 0.
      ld_row = sy-tabix.
      CASE ld_row.
          mac_sls3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
      ENDCASE.
    ENDIF.

*    LOOP AT gt_zsclassopp WHERE mvgr2 = gt_s619-mvgr2.
*      LOOP AT gt_quantity WHERE spmon  EQ gt_out-spmon      "Strike 2
*                            AND vkbur  EQ gt_out-vkbur
*                            AND pkunwe EQ gt_out-pkunwe
*                            AND mvgr2 EQ gt_zsclassopp-mvgr2
*                            AND mvgr3 EQ gt_zsclassopp-mvgr3.
*        IF gt_quantity-qty GE gt_zsclassopp-minqty.
*          READ TABLE gt_cntrl WITH KEY field_value = gt_s619-mvgr2.
*          IF sy-subrc = 0.
*            ld_row = sy-tabix.
*            CASE ld_row.
*                mac_str3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
*            ENDCASE.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*      LOOP AT gt_quantity1 WHERE spmon  EQ gt_out-spmon     "Strike 1
*                             AND vkbur  EQ gt_out-vkbur
*                             AND pkunwe EQ gt_out-pkunwe
*                             AND mvgr2 EQ gt_zsclassopp-mvgr2
*                             AND mvgr3 EQ gt_zsclassopp-mvgr3.
*        IF gt_quantity1-qty GE gt_zsclassopp-minqty.
*          READ TABLE gt_cntrl WITH KEY field_value = gt_s619-mvgr2.
*          IF sy-subrc = 0.
*            ld_row = sy-tabix.
*            CASE ld_row.
*                mac_st13: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
*            ENDCASE.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.

    COLLECT gt_out. CLEAR gt_out.
  ENDLOOP.

  SORT gt_zstarget BY vkbur kunnr mvgr2.
  SORT gt_customer BY vkbur kunnr mvgr2.
  LOOP AT gt_zstarget.
    IF gt_dnd[] IS NOT INITIAL.
      READ TABLE gt_dnd WITH KEY field_value = pa_spmon+4(2)
                                 field_value2 = gt_zstarget-mvgr2.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR: gt_customer,lt_routel.
    READ TABLE gt_customer WITH KEY vkbur = gt_zstarget-vkbur
                                    kunnr = gt_zstarget-kunnr
                           BINARY SEARCH.

    READ TABLE lt_routel WITH KEY kunnr = gt_customer-kunn2.

    gt_out-spmon = pa_spmon.
    gt_out-vkbur = gt_zstarget-vkbur.
    gt_out-bezei20 = lv_bezei20.
    gt_out-pkunwe = gt_zstarget-kunnr.
    gt_out-name1 = gt_customer-name1.
    gt_out-routel = gt_customer-kunn2.
    gt_out-name_rt = lt_routel-name1.

    READ TABLE gt_cntrl WITH KEY field_value = gt_zstarget-mvgr2.
    IF sy-subrc = 0.
      ld_row = sy-tabix.
      CASE ld_row.
          mac_tgt3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
      ENDCASE.

      ld_row = sy-tabix.
      CASE ld_row.
          mac_tgu3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
      ENDCASE.
    ENDIF.

    COLLECT gt_out. CLEAR gt_out.
  ENDLOOP.

  SORT gt_out BY spmon vkbur pkunwe.
  SORT gt_quantity BY spmon vkbur pkunwe mvgr2 mvgr3.
  SORT gt_quantity1 BY spmon vkbur pkunwe mvgr2 mvgr3.
  SORT gt_zsclassopp BY mvgr2 mvgr3.

  LOOP AT gt_out.
    CLEAR gt_customer.
    READ TABLE gt_customer WITH KEY kunnr = gt_out-pkunwe.

    LOOP AT gt_quantity WHERE spmon  EQ gt_out-spmon        "Strike 2
                          AND vkbur  EQ gt_out-vkbur
                          AND pkunwe EQ gt_out-pkunwe.

      CLEAR gt_zsclassopp.
      READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity-mvgr2
                                        mvgr3 = gt_quantity-mvgr3
                                        kdgrp = gt_customer-kdgrp
                               BINARY SEARCH.
      IF sy-subrc NE 0.
        SORT gt_zsclassopp BY mvgr2 mvgr3.
        READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity-mvgr2
                                          mvgr3 = gt_quantity-mvgr3
                                          kdgrp = gt_customer-kdgrp.
      ENDIF.
      IF gt_quantity-qty GE gt_zsclassopp-minqty.
        READ TABLE gt_cntrl WITH KEY field_value = gt_quantity-mvgr2.
        IF sy-subrc = 0.
          ld_row = sy-tabix.
          CASE ld_row.
              mac_str3: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_quantity1 WHERE spmon  EQ gt_out-spmon       "Strike 1
                           AND vkbur  EQ gt_out-vkbur
                           AND pkunwe EQ gt_out-pkunwe.
      CLEAR gt_zsclassopp.
      READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity1-mvgr2
                                        mvgr3 = gt_quantity1-mvgr3
                                        kdgrp = gt_customer-kdgrp
                               BINARY SEARCH.
      IF sy-subrc NE 0.
        SORT gt_zsclassopp BY mvgr2 mvgr3.
        READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity1-mvgr2
                                          mvgr3 = gt_quantity1-mvgr3
                                          kdgrp = gt_customer-kdgrp.
      ENDIF.
      IF gt_quantity1-qty GE gt_zsclassopp-minqty.
        READ TABLE gt_cntrl WITH KEY field_value = gt_quantity1-mvgr2.
        IF sy-subrc = 0.
          ld_row = sy-tabix.
          CASE ld_row.
              mac_st13: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gt_out-tgu1 IS NOT INITIAL.
      gt_out-%wb1 = gt_out-sl11 / gt_out-tgu1 * 100.
    ENDIF.
    IF gt_out-tgu2 IS NOT INITIAL.
      gt_out-%wb2 = gt_out-sl12 / gt_out-tgu2 * 100.
    ENDIF.
    IF gt_out-tgu3 IS NOT INITIAL.
      gt_out-%wb3 = gt_out-sl13 / gt_out-tgu3 * 100.
    ENDIF.
    IF gt_out-tgu4 IS NOT INITIAL.
      gt_out-%wb4 = gt_out-sl14 / gt_out-tgu4 * 100.
    ENDIF.
    IF gt_out-tgu5 IS NOT INITIAL.
      gt_out-%wb5 = gt_out-sl15 / gt_out-tgu5 * 100.
    ENDIF.
    IF gt_out-tgu6 IS NOT INITIAL.
      gt_out-%wb6 = gt_out-sl16 / gt_out-tgu6 * 100.
    ENDIF.
    IF gt_out-tgu7 IS NOT INITIAL.
      gt_out-%wb7 = gt_out-sl17 / gt_out-tgu7 * 100.
    ENDIF.
    IF gt_out-tgu8 IS NOT INITIAL.
      gt_out-%wb8 = gt_out-sl18 / gt_out-tgu8 * 100.
    ENDIF.
    IF gt_out-tgu9 IS NOT INITIAL.
      gt_out-%wb9 = gt_out-sl19 / gt_out-tgu9 * 100.
    ENDIF.
    IF gt_out-tgu10 IS NOT INITIAL.
      gt_out-%wb10 = gt_out-sl110 / gt_out-tgu10 * 100.
    ENDIF.
    MODIFY gt_out TRANSPORTING %wb1 %wb2 %wb3 %wb4 %wb5
                               %wb6 %wb7 %wb8 %wb9 %wb10
                               str1 str2 str3 str4 str5
                               str6 str7 str8 str9 str10
                               st11 st12 st13 st14 st15
                               st16 st17 st18 st19 st110.
    CLEAR gt_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA3

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAKET_OPP
*&---------------------------------------------------------------------*
FORM f_get_paket_opp .
  DATA : ls_cltgt LIKE LINE OF gt_cltgt,
         ls_class LIKE LINE OF gt_class.

  CLEAR: gt_tvm2,gt_tvm2[].
  SELECT * INTO TABLE gt_tvm2
    FROM tvm2 WHERE mvgr2 IN so_mvgr2.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_cltgt
    WHERE vkorg       = pa_vkorg
      AND paket       = 'OPP'
      AND field_name  = 'CLASSTGT'.

  LOOP AT gt_cltgt INTO ls_cltgt.
    ls_class-kdgrp    = ls_cltgt-field_value.
    ls_class-zvaltgt  = ls_cltgt-field_value3.
    ls_class-text     = ls_cltgt-text.
    APPEND ls_class TO gt_class.
    CLEAR ls_class.
  ENDLOOP.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_mintgt
    WHERE vkorg       = pa_vkorg
      AND paket       = 'OPP'
      AND field_name  = 'MINTGT'.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_param
    WHERE vkorg       = pa_vkorg
      AND paket       = 'OPP'
      AND field_name  = 'PARAM'.

  SELECT SINGLE flag
    FROM zproject
    INTO gv_2020
    WHERE name = 'OPP042020'
      AND datab <= sy-datum.
ENDFORM.                    " F_GET_PAKET_OPP

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_itab .
  CLEAR: gt_zsparameter,r_mvgr2,r_mvgr2[],gt_cntrl,gt_cntrl[],
         gt_customer,gt_customer[],gt_zstarget,gt_zstarget[],
         gt_s619,gt_s619[],gt_zsclassopp,gt_zsclassopp[],
         gt_likp,gt_likp[],gt_quantity,gt_quantity[],gt_out,gt_out[],
         gt_quantity1,gt_quantity1[],gt_quantity2,gt_quantity2[].
ENDFORM.                    " F_CLEAR_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_date .
  DATA : lv_start TYPE sy-datum,
         lv_end   TYPE sy-datum,
         ls_spmon LIKE LINE OF gr_spmon.

  CONCATENATE pa_spmon '01' INTO gv_date1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gv_date1
    IMPORTING
      last_day_of_month = gv_date2.

  CALL FUNCTION 'BKK_GET_QUARTER_DATE'
    EXPORTING
      i_date          = gv_date1
    IMPORTING
      e_quarter_start = lv_start
      e_quarter_end   = lv_end.

  ls_spmon-low    = lv_start(6).
  ls_spmon-high   = lv_end(6).
  ls_spmon-sign   = 'I'.
  ls_spmon-option = 'BT'.
  APPEND ls_spmon TO gr_spmon.
  CLEAR ls_spmon.
ENDFORM.                    " F_GET_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA: lv_fldnm01    TYPE lvc_fname,
        lv_fldnm02    TYPE lvc_fname,
        lv_fldnm03    TYPE lvc_fname,
        lv_fldnm04    TYPE lvc_fname,
        lv_fldnm05    TYPE lvc_fname,
        lv_fldnm06    TYPE lvc_fname,
        lv_fldnm07    TYPE lvc_fname,
        lv_fldnm08    TYPE lvc_fname,

        lv_text01(40),
        lv_text02(40),
        lv_text03(40),
        lv_text04(40),
        lv_text05(40),
        lv_text06(40),
        lv_text07(40),
        lv_text08(40),
        lv_value(10).

  PERFORM f_dyn_fieldcatg USING :
    'SPMON' 'S619' 'SPMON' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'S619' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI' '' '' '' '20' 'SlOff Desc.' '' '' '' '' '' '' '' '' '' '' '',
    'ROUTEL' '' '' '' '10' 'Route' '' '' '' '' '' '' '' '' '' '' '',
    'NAME_RT' '' '' '' '20' 'Route Name' '' '' '' '' '' '' '' '' '' '' '',
    'PKUNWE' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERK' 'S619' 'WAERK' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CLASS' '' '' '' '20' 'Class' '' '' '' '' '' '' '' '' '' '' ''.

  LOOP AT gt_cntrl.
    IF gv_2020 IS INITIAL.
      lv_value  = gt_cntrl-field_value2.
    ELSE.
      lv_value  = gt_cntrl-field_value4.
    ENDIF.

    CASE lv_value.
      WHEN '1'.     "Green
        CONCATENATE 'TGT' gt_cntrl-field_value INTO lv_fldnm01.
        CONCATENATE 'TGT' gt_cntrl-field_value INTO lv_text01
        SEPARATED BY space.
        CONCATENATE 'MINTGT' gt_cntrl-field_value INTO lv_fldnm08.
        CONCATENATE 'MINTGT' gt_cntrl-field_value INTO lv_text08
        SEPARATED BY space.
        CONCATENATE 'TGU' gt_cntrl-field_value INTO lv_fldnm02.
        CONCATENATE 'TGT45%' gt_cntrl-field_value INTO lv_text02
        SEPARATED BY space.
        CONCATENATE 'SLSI' gt_cntrl-field_value INTO lv_fldnm03.
        CONCATENATE 'SLS I' gt_cntrl-field_value INTO lv_text03
        SEPARATED BY space.
        CONCATENATE 'SLS' gt_cntrl-field_value INTO lv_fldnm04.
        CONCATENATE 'SLS' gt_cntrl-field_value INTO lv_text04
        SEPARATED BY space.
        CONCATENATE 'RT%' gt_cntrl-field_value INTO lv_fldnm05.
        CONCATENATE '%R/T' gt_cntrl-field_value INTO lv_text05
        SEPARATED BY space.
        CONCATENATE 'STR1' gt_cntrl-field_value INTO lv_fldnm06.
        CONCATENATE 'STR I' gt_cntrl-field_value INTO lv_text06
        SEPARATED BY space.
        CONCATENATE 'STR2' gt_cntrl-field_value INTO lv_fldnm07.
        CONCATENATE 'STR II' gt_cntrl-field_value INTO lv_text07
        SEPARATED BY space.

        PERFORM f_dyn_fieldcatg USING :
          lv_fldnm01 'ZSTARGET' 'ZVALTGT' 'X' '' lv_text01 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm08 'ZSTARGET' 'ZVALTGT' '' '' lv_text08 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm02 'ZSTARGET' 'ZVALTGT' '' '' lv_text02 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm03 'ZSTARGET' 'ZVALTGT' '' '' lv_text03 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm04 'ZSTARGET' 'ZVALTGT' '' '' lv_text04 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm05 'ZSCLASSOPP' 'ZPERSENMIN' '' '' lv_text05 '' '' '' '' '' ''
          '' '' '' '' '',
          lv_fldnm06 'ZSCLASSOPP' 'ZPERSENMIN' '' '' lv_text06 '' '' '' '' '' ''
          '' '' '' '' '',
          lv_fldnm07 'ZSCLASSOPP' 'ZPERSENMIN' '' '' lv_text07 '' '' '' '' '' ''
          '' '' '' '' ''.

      WHEN '2'.     "Blue
        CONCATENATE 'TGT' gt_cntrl-field_value INTO lv_fldnm01.
        CONCATENATE 'TGT' gt_cntrl-field_value INTO lv_text01
        SEPARATED BY space.
        CONCATENATE 'MINTGT' gt_cntrl-field_value INTO lv_fldnm08.
        CONCATENATE 'MINTGT' gt_cntrl-field_value INTO lv_text08
        SEPARATED BY space.
        CONCATENATE 'SLS' gt_cntrl-field_value INTO lv_fldnm02.
        CONCATENATE 'SLS' gt_cntrl-field_value INTO lv_text02
        SEPARATED BY space.
        CONCATENATE 'RT%' gt_cntrl-field_value INTO lv_fldnm03.
        CONCATENATE '%R/T' gt_cntrl-field_value INTO lv_text03
        SEPARATED BY space.
        CONCATENATE 'STR' gt_cntrl-field_value INTO lv_fldnm04.
        CONCATENATE 'STR' gt_cntrl-field_value INTO lv_text04
        SEPARATED BY space.

        PERFORM f_dyn_fieldcatg USING :
          lv_fldnm01 'ZSTARGET' 'ZVALTGT' 'X' '' lv_text01 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm08 'ZSTARGET' 'ZVALTGT' '' '' lv_text08 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm02 'ZSTARGET' 'ZVALTGT' '' '' lv_text02 '' '' '' '' '' 'WAERK'
          '' '' '' '' '',
          lv_fldnm03 'ZSCLASSOPP' 'ZPERSENMIN' '' '' lv_text03 '' '' '' '' '' ''
          '' '' '' '' '',
          lv_fldnm04 'ZSCLASSOPP' 'ZPERSENMIN' '' '' lv_text04 '' '' '' '' '' ''
          '' '' '' '' ''.
    ENDCASE.
  ENDLOOP.

  PERFORM f_dyn_fieldcatg USING :
    'TGTREG' 'ZSTARGET' 'ZVALTGT' '' '20' 'Target OPP Quartal' '' '' ''
    '' '' 'WAERK' '' '' '' '' '',
    'TTGT' 'ZSTARGET' 'ZVALTGT' 'X' '20' 'Total Target' '' '' '' '' '' 'WAERK'
    '' '' '' '' '',
    'TSLS' 'ZSTARGET' 'ZVALTGT' '' '20' 'Total Sales' '' '' '' '' '' 'WAERK'
    '' '' '' '' ''.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = gt_dyn_fcat
* Begin remark unicode coversion - DEVK966054
* 18.03.2020 - sol chirka
      i_length_in_byte          = 'X'
* End insert Unicode conversion - DEVK966054
    IMPORTING
      ep_table                  = gt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
    ASSIGN gt_dyn_table->* TO <fs_gt>.
    CREATE DATA gw_line LIKE LINE OF <fs_gt>.
    ASSIGN gw_line->* TO <fs_gs>.
  ENDIF.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_dyn_fieldcatg  USING    VALUE(fu_fname)
                               VALUE(fu_reftable)
                               VALUE(fu_reffield)
                               VALUE(fu_noout)
                               VALUE(fu_outln)
                               VALUE(fu_fltxt)
                               VALUE(fu_dosum)
                               VALUE(fu_hotsp)
                               VALUE(fu_dec)
                               VALUE(fu_waers)
                               VALUE(fu_meins)
                               VALUE(fu_waers_f)
                               VALUE(fu_meins_f)
                               VALUE(fu_checkbox)
                               VALUE(fu_input)
                               VALUE(fu_emphasize)
                               VALUE(fu_colpos).

  DATA: lw_dyn_fcat  TYPE  lvc_s_fcat.

  CLEAR: lw_dyn_fcat.
  lw_dyn_fcat-fieldname         = fu_fname.
  lw_dyn_fcat-ref_table         = fu_reftable.
  lw_dyn_fcat-ref_field         = fu_reffield.
  lw_dyn_fcat-no_out            = fu_noout.
  lw_dyn_fcat-outputlen         = fu_outln.
  lw_dyn_fcat-coltext           = fu_fltxt.
  lw_dyn_fcat-no_out            = fu_noout.
  lw_dyn_fcat-do_sum            = fu_dosum.
  lw_dyn_fcat-hotspot           = fu_hotsp.
  lw_dyn_fcat-currency          = fu_waers.
  lw_dyn_fcat-quantity          = fu_meins.
  lw_dyn_fcat-qfieldname        = fu_meins_f.
  lw_dyn_fcat-cfieldname        = fu_waers_f.
  lw_dyn_fcat-checkbox          = fu_checkbox.
  lw_dyn_fcat-emphasize         = fu_emphasize.
  lw_dyn_fcat-col_pos           = fu_colpos.
  APPEND lw_dyn_fcat TO gt_dyn_fcat.
  CLEAR lw_dyn_fcat.
ENDFORM.                    " F_DYN_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_DYN_PROCESS
*&---------------------------------------------------------------------*
FORM f_dyn_process .
  DATA: BEGIN OF lt_routel OCCURS 0,
          kunnr TYPE kunnr,
          name1 TYPE name1_gp,
        END OF lt_routel.

  DATA: lt_s619        LIKE gt_s619 OCCURS 0 WITH HEADER LINE.
  DATA: lv_bezei20     TYPE tvkbt-bezei.
  DATA: lv_dynfldnm01 TYPE lvc_fname,
        lv_dynfldnm02 TYPE lvc_fname,
        lv_dynfldnm03 TYPE lvc_fname,
        lv_dynfldnm04 TYPE lvc_fname,
        lv_dynfldnm05 TYPE lvc_fname,
        lv_dynfldnm06 TYPE lvc_fname,
        lv_dynfldnm07 TYPE lvc_fname,
        lv_dynfldnm08 TYPE lvc_fname,
        lv_zvaltgt    TYPE zstarget-zvaltgt,
        lv_tgtclass   TYPE zstarget-zvaltgt,
        lv_tgtmin     TYPE zstarget-zvaltgt,
        lv_slsclass   TYPE zstarget-zvaltgt,
        lv_zvaltgu    TYPE zstarget-zvaltgt,
        lv_opptgt     TYPE zstarget-zvaltgt,
        lv_mvgr2      TYPE zstarget-mvgr2,
        lv_grosval1   TYPE s619-grosval,
        lv_grosval    TYPE s619-grosval,
        lv_rt         TYPE zsclassopp-zpersenmin,
        lv_strike1    TYPE zsclassopp-zpersenmin,
        lv_strike2    TYPE zsclassopp-zpersenmin.
  DATA: lt_zstarget  LIKE gt_zstarget OCCURS 0 WITH HEADER LINE,
        lv_value(10),
        lv_text(30).
  DATA: ls_gtcp        LIKE LINE OF gt_gtcp.

  SELECT SINGLE bezei INTO lv_bezei20
    FROM tvkbt
    WHERE spras EQ sy-langu
      AND vkbur EQ pa_vkbur.

  SELECT kunnr name1 INTO TABLE lt_routel
    FROM kna1
    FOR ALL ENTRIES IN gt_customer
    WHERE kunnr EQ gt_customer-kunn2.

  SORT gt_likp BY vbeln.
  SORT gt_s619 BY vkbur kunnr mvgr2 vbeln.
  SORT gt_customer BY vkbur kunnr mvgr2.
  SORT lt_routel BY kunnr.
  SORT gt_zstarget BY vkbur kunnr mvgr2.

  lt_s619[] = gt_s619[].
  DELETE ADJACENT DUPLICATES FROM lt_s619 COMPARING vkbur kunnr.

  lt_zstarget[] = gt_zstarget[].
  DELETE ADJACENT DUPLICATES FROM lt_zstarget COMPARING vkbur kunnr.

* New version
  LOOP AT lt_zstarget.
    CLEAR: gt_customer,lt_routel.
    READ TABLE gt_customer WITH KEY vkbur = lt_zstarget-vkbur
                                    kunnr = lt_zstarget-kunnr
                           BINARY SEARCH.

    READ TABLE gt_gtcp INTO ls_gtcp
                       WITH KEY field_value2 = gt_customer-kdgrp.

    CLEAR lt_routel.
    READ TABLE lt_routel WITH KEY kunnr = gt_customer-kunn2.

    PERFORM f_assign_to_fs USING :
      'SPMON' pa_spmon,
      'VKBUR' lt_zstarget-vkbur,
      'BEZEI' lv_bezei20,
      'PKUNWE' lt_zstarget-kunnr,
      'NAME1' gt_customer-name1,
      'ROUTEL' gt_customer-kunn2,
      'NAME_RT' lt_routel-name1,
      'WAERK' lt_zstarget-waerk.

    READ TABLE lt_s619 WITH KEY vkbur = lt_zstarget-vkbur
                                kunnr = lt_zstarget-kunnr.
    IF sy-subrc = 0.
      LOOP AT lt_s619 WHERE vkbur = lt_zstarget-vkbur
                        AND kunnr = lt_zstarget-kunnr.

        LOOP AT gt_cntrl.
          lv_mvgr2  = gt_cntrl-field_value.

          IF gv_2020 IS INITIAL.
            lv_value  = gt_cntrl-field_value2.
          ELSE.
            lv_value  = gt_cntrl-field_value4.
          ENDIF.

          CASE lv_value.
            WHEN '1'.     "Green
              CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
              CONCATENATE 'MINTGT' lv_mvgr2 INTO lv_dynfldnm08.
              CONCATENATE 'TGU' lv_mvgr2 INTO lv_dynfldnm02.
              CONCATENATE 'SLSI' lv_mvgr2 INTO lv_dynfldnm03.
              CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm04.
              CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm05.
              CONCATENATE 'STR1' lv_mvgr2 INTO lv_dynfldnm06.
              CONCATENATE 'STR2' lv_mvgr2 INTO lv_dynfldnm07.

*     Target & Target 45%
              CLEAR : lv_zvaltgt, lv_zvaltgu.
              PERFORM f_hitung_target USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                            gt_customer-katr10 ls_gtcp-field_value
                                      CHANGING lv_zvaltgt lv_zvaltgu.
*     Minimum Target
              PERFORM f_minimum_target USING lv_zvaltgt gt_customer-kdgrp
                                             lv_mvgr2
                                       CHANGING lv_tgtmin lv_tgtclass.

*     SLS I & SLS
              CLEAR : lv_grosval1, lv_grosval.
              PERFORM f_hitung_sales  USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                      CHANGING lv_grosval1 lv_grosval.

              ADD lv_grosval TO lv_slsclass.

*     Realisasi Target
              CLEAR : lv_rt.
              TRY .
                  lv_rt = ( lv_grosval1 / lv_zvaltgu ) * 100.
                CATCH cx_sy_zerodivide.

              ENDTRY.

*     Strike
              CLEAR : lv_strike1, lv_strike2.
              PERFORM f_hitung_strike USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                            gt_cntrl-field_value2 gt_customer-kdgrp
                                      CHANGING lv_strike1 lv_strike2.

              PERFORM f_assign_to_fs USING :
                 lv_dynfldnm01 lv_zvaltgt,
                 lv_dynfldnm08 lv_tgtmin,
                 lv_dynfldnm02 lv_zvaltgu,
                 lv_dynfldnm03 lv_grosval1,
                 lv_dynfldnm04 lv_grosval,
                 lv_dynfldnm05 lv_rt,
                 lv_dynfldnm06 lv_strike1,
                 lv_dynfldnm07 lv_strike2.

            WHEN '2'.     "Blue
              CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
              CONCATENATE 'MINTGT' lv_mvgr2 INTO lv_dynfldnm08.
              CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm02.
              CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm03.
              CONCATENATE 'STR' lv_mvgr2 INTO lv_dynfldnm04.

*     Target
              CLEAR : lv_zvaltgt, lv_zvaltgu.
              PERFORM f_hitung_target USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                            gt_customer-katr10 ls_gtcp-field_value
                                      CHANGING lv_zvaltgt lv_zvaltgu.
*     Minimum Target
              PERFORM f_minimum_target USING lv_zvaltgt gt_customer-kdgrp
                                             lv_mvgr2
                                       CHANGING lv_tgtmin lv_tgtclass.
*     SLS
              CLEAR : lv_grosval1, lv_grosval.
              PERFORM f_hitung_sales  USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                      CHANGING lv_grosval1 lv_grosval.

              ADD lv_grosval TO lv_slsclass.

*     Realisasi Target
              CLEAR : lv_rt.
              TRY .
                  lv_rt = ( lv_grosval / lv_zvaltgt ) * 100.
                CATCH cx_sy_zerodivide.

              ENDTRY.

*     Strike
              CLEAR : lv_strike1, lv_strike2.
              PERFORM f_hitung_strike USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
                                            gt_cntrl-field_value2 gt_customer-kdgrp
                                      CHANGING lv_strike1 lv_strike2.

              PERFORM f_assign_to_fs USING :
                 lv_dynfldnm01 lv_zvaltgt,
                 lv_dynfldnm08 lv_tgtmin,
                 lv_dynfldnm02 lv_grosval,
                 lv_dynfldnm03 lv_rt,
                 lv_dynfldnm04 lv_strike1.
          ENDCASE.
        ENDLOOP.

        PERFORM f_hitung_target_quarter USING lt_zstarget-vkbur lt_zstarget-kunnr gt_customer-kdgrp
                                              gt_customer-katr10 ls_gtcp-field_value
                                        CHANGING lv_opptgt.

        PERFORM f_get_class USING lv_opptgt gt_customer-kdgrp lt_zstarget-kunnr lt_zstarget-class
                            CHANGING lv_text.

        PERFORM f_assign_to_fs USING :
              'TGTREG' lv_opptgt,
              'TTGT' lv_tgtclass,
              'TSLS' lv_slsclass,
              'CLASS' lv_text.

        APPEND <fs_gs> TO <fs_gt>.
        CLEAR : <fs_gs>, lv_tgtclass, lv_opptgt, lv_slsclass, lv_text.
      ENDLOOP.
    ELSE.
      LOOP AT gt_cntrl.
        lv_mvgr2  = gt_cntrl-field_value.

        IF gv_2020 IS INITIAL.
          lv_value  = gt_cntrl-field_value2.
        ELSE.
          lv_value  = gt_cntrl-field_value4.
        ENDIF.

        CASE lv_value.
          WHEN '1'.     "Green
            CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
            CONCATENATE 'MINTGT' lv_mvgr2 INTO lv_dynfldnm08.
            CONCATENATE 'TGU' lv_mvgr2 INTO lv_dynfldnm02.
            CONCATENATE 'SLSI' lv_mvgr2 INTO lv_dynfldnm03.
            CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm04.
            CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm05.
            CONCATENATE 'STR1' lv_mvgr2 INTO lv_dynfldnm06.
            CONCATENATE 'STR2' lv_mvgr2 INTO lv_dynfldnm07.

*     Target & Target 45%
            CLEAR : lv_zvaltgt, lv_zvaltgu.
            PERFORM f_hitung_target USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
                                          gt_customer-katr10 ls_gtcp-field_value
                                    CHANGING lv_zvaltgt lv_zvaltgu.
*     Minimum Target
            PERFORM f_minimum_target USING lv_zvaltgt gt_customer-kdgrp
                                           lv_mvgr2
                                     CHANGING lv_tgtmin lv_tgtclass.

*     SLS I & SLS
            CLEAR : lv_grosval1, lv_grosval, lv_slsclass.
*            PERFORM f_hitung_sales  USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
*                                    CHANGING lv_grosval1 lv_grosval.
*     Realisasi Target
            CLEAR : lv_rt.
*            TRY .
*                lv_rt = ( lv_grosval1 / lv_zvaltgu ) * 100.
*              CATCH cx_sy_zerodivide.
*            ENDTRY.

*     Strike
            CLEAR : lv_strike1, lv_strike2.
            PERFORM f_hitung_strike USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
                                          gt_cntrl-field_value2 gt_customer-kdgrp
                                    CHANGING lv_strike1 lv_strike2.

            PERFORM f_assign_to_fs USING :
               lv_dynfldnm01 lv_zvaltgt,
               lv_dynfldnm08 lv_tgtmin,
               lv_dynfldnm02 lv_zvaltgu,
               lv_dynfldnm03 lv_grosval1,
               lv_dynfldnm04 lv_grosval,
               lv_dynfldnm05 lv_rt,
               lv_dynfldnm06 lv_strike1,
               lv_dynfldnm07 lv_strike2.

          WHEN '2'.     "Blue
            CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
            CONCATENATE 'MINTGT' lv_mvgr2 INTO lv_dynfldnm08.
            CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm02.
            CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm03.
            CONCATENATE 'STR' lv_mvgr2 INTO lv_dynfldnm04.

*     Target
            CLEAR : lv_zvaltgt, lv_zvaltgu.
            PERFORM f_hitung_target USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
                                          gt_customer-katr10 ls_gtcp-field_value
                                    CHANGING lv_zvaltgt lv_zvaltgu.
*     Minimum Target
            PERFORM f_minimum_target USING lv_zvaltgt gt_customer-kdgrp
                                           lv_mvgr2
                                     CHANGING lv_tgtmin lv_tgtclass.

*     SLS
            CLEAR : lv_grosval1, lv_grosval, lv_slsclass.
*            PERFORM f_hitung_sales  USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
*                                    CHANGING lv_grosval1 lv_grosval.

*     Realisasi Target
            CLEAR : lv_rt.
*            TRY .
*                lv_rt = ( lv_grosval / lv_zvaltgt ) * 100.
*              CATCH cx_sy_zerodivide.
*            ENDTRY.

*     Strike
            CLEAR : lv_strike1, lv_strike2.
            PERFORM f_hitung_strike USING lt_zstarget-vkbur lt_zstarget-kunnr lv_mvgr2
                                          gt_cntrl-field_value2 gt_customer-kdgrp
                                    CHANGING lv_strike1 lv_strike2.

            PERFORM f_assign_to_fs USING :
               lv_dynfldnm01 lv_zvaltgt,
               lv_dynfldnm08 lv_tgtmin,
               lv_dynfldnm02 lv_grosval,
               lv_dynfldnm03 lv_rt,
               lv_dynfldnm04 lv_strike1.
        ENDCASE.
      ENDLOOP.

      PERFORM f_hitung_target_quarter USING lt_zstarget-vkbur lt_zstarget-kunnr gt_customer-kdgrp
                                            gt_customer-katr10 ls_gtcp-field_value
                                      CHANGING lv_opptgt.

      PERFORM f_get_class USING lv_opptgt gt_customer-kdgrp lt_zstarget-kunnr lt_zstarget-class
                          CHANGING lv_text.

      PERFORM f_assign_to_fs USING :
            'TGTREG' lv_opptgt,
            'TTGT' lv_tgtclass,
            'TSLS' lv_slsclass,
            'CLASS' lv_text.

      APPEND <fs_gs> TO <fs_gt>.
      CLEAR : <fs_gs>, lv_tgtclass, lv_opptgt, lv_slsclass, lv_text.
    ENDIF.
  ENDLOOP.

* Old version
*  LOOP AT lt_s619.
*    CLEAR: gt_customer,lt_routel.
*    READ TABLE gt_customer WITH KEY vkbur = lt_s619-vkbur
*                                    kunnr = lt_s619-kunnr
*                           BINARY SEARCH.
*
*    READ TABLE lt_routel WITH KEY kunnr = gt_customer-kunn2.
*
*    PERFORM f_assign_to_fs USING :
*      'SPMON' pa_spmon,
*      'VKBUR' lt_s619-vkbur,
*      'BEZEI' lv_bezei20,
*      'PKUNWE' lt_s619-kunnr,
*      'NAME1' gt_customer-name1,
*      'ROUTEL' gt_customer-kunn2,
*      'NAME_RT' lt_routel-name1,
*      'WAERK' lt_s619-waerk.
*
*    LOOP AT gt_cntrl.
*      lv_mvgr2  = gt_cntrl-field_value.
*      CASE gt_cntrl-field_value2.
*        WHEN '1'.     "Green
*          CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
*          CONCATENATE 'TGU' lv_mvgr2 INTO lv_dynfldnm02.
*          CONCATENATE 'SLSI' lv_mvgr2 INTO lv_dynfldnm03.
*          CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm04.
*          CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm05.
*          CONCATENATE 'STR1' lv_mvgr2 INTO lv_dynfldnm06.
*          CONCATENATE 'STR2' lv_mvgr2 INTO lv_dynfldnm07.
*
** Target & Target 45%
*          CLEAR : lv_zvaltgt, lv_zvaltgu.
*          PERFORM f_hitung_target USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                  CHANGING lv_zvaltgt lv_zvaltgu.
*
** SLS I & SLS
*          CLEAR : lv_grosval1, lv_grosval.
*          PERFORM f_hitung_sales  USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                  CHANGING lv_grosval1 lv_grosval.
** Realisasi Target
*          CLEAR : lv_rt.
*          TRY .
*              lv_rt = ( lv_grosval1 / lv_zvaltgu ) * 100.
*            CATCH cx_sy_zerodivide.
*
*          ENDTRY.
*
** Strike
*          CLEAR : lv_strike1, lv_strike2.
*          PERFORM f_hitung_strike USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                        gt_cntrl-field_value2
*                                  CHANGING lv_strike1 lv_strike2.
*
*          PERFORM f_assign_to_fs USING :
*             lv_dynfldnm01 lv_zvaltgt,
*             lv_dynfldnm02 lv_zvaltgu,
*             lv_dynfldnm03 lv_grosval1,
*             lv_dynfldnm04 lv_grosval,
*             lv_dynfldnm05 lv_rt,
*             lv_dynfldnm06 lv_strike1,
*             lv_dynfldnm07 lv_strike2.
*
*        WHEN '2'.     "Blue
*          CONCATENATE 'TGT' lv_mvgr2 INTO lv_dynfldnm01.
*          CONCATENATE 'SLS' lv_mvgr2 INTO lv_dynfldnm02.
*          CONCATENATE 'RT%' lv_mvgr2 INTO lv_dynfldnm03.
*          CONCATENATE 'STR' lv_mvgr2 INTO lv_dynfldnm04.
*
** Target
*          CLEAR : lv_zvaltgt, lv_zvaltgu.
*          PERFORM f_hitung_target USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                  CHANGING lv_zvaltgt lv_zvaltgu.
*
** SLS
*          CLEAR : lv_grosval1, lv_grosval.
*          PERFORM f_hitung_sales  USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                  CHANGING lv_grosval1 lv_grosval.
*
** Realisasi Target
*          CLEAR : lv_rt.
*          TRY .
*              lv_rt = ( lv_grosval / lv_zvaltgt ) * 100.
*            CATCH cx_sy_zerodivide.
*
*          ENDTRY.
*
*
** Strike
*          CLEAR : lv_strike1, lv_strike2.
*          PERFORM f_hitung_strike USING lt_s619-vkbur lt_s619-kunnr lv_mvgr2
*                                        gt_cntrl-field_value2
*                                  CHANGING lv_strike1 lv_strike2.
*
*          PERFORM f_assign_to_fs USING :
*             lv_dynfldnm01 lv_zvaltgt,
*             lv_dynfldnm02 lv_grosval,
*             lv_dynfldnm03 lv_rt,
*             lv_dynfldnm04 lv_strike1.
*      ENDCASE.
*    ENDLOOP.
*    APPEND <fs_gs> TO <fs_gt>.
*    CLEAR <fs_gs>.
*  ENDLOOP.
ENDFORM.                    " F_DYN_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_TO_FS
*&---------------------------------------------------------------------*
FORM f_assign_to_fs  USING    fu_component fu_value.
  ASSIGN COMPONENT fu_component OF STRUCTURE <fs_gs> TO <fs>.
  <fs> = fu_value.
  UNASSIGN <fs>.
ENDFORM.                    " F_ASSIGN_TO_FS

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TARGET
*&---------------------------------------------------------------------*
FORM f_hitung_target  USING    fu_vkbur fu_kunnr fu_mvgr2 fu_katr10 fu_value
                      CHANGING fc_zvaltgt fc_zvaltgu.

  DATA : ls_tgtcust  LIKE LINE OF gt_tgtcust,
         ls_mvgr2reg LIKE LINE OF gt_mvgr2reg,
         ls_clspkt   LIKE LINE OF gt_clspkt,
         ls_zstarget LIKE LINE OF gt_zstarget.

  LOOP AT gt_zstarget WHERE vkbur = fu_vkbur
                        AND kunnr = fu_kunnr
                        AND mvgr2 = fu_mvgr2.

    CLEAR ls_mvgr2reg.
    READ TABLE gt_mvgr2reg INTO ls_mvgr2reg
                           WITH KEY field_value = fu_mvgr2.
    IF sy-subrc = 0.
*      IF radio3 IS NOT INITIAL.
*        ADD gt_zstarget-zvaltgt TO fc_zvaltgt.
*      ELSE.
      READ TABLE gt_dnd WITH KEY field_value  = pa_spmon+4(2)
                                 field_value2 = gt_zstarget-mvgr2.
      IF sy-subrc = 0.
        ADD gt_zstarget-zvaltgt TO fc_zvaltgt.
      ENDIF.
*      ENDIF.
    ELSE.
      CLEAR ls_tgtcust.
      READ TABLE gt_tgtcust INTO ls_tgtcust
                            WITH KEY kunnr        = fu_kunnr
                                     field_value1 = gt_zstarget-spmon
                                     field_value2 = fu_mvgr2.
      IF sy-subrc = 0.
*        IF radio3 IS NOT INITIAL.
*          ADD gt_zstarget-zvaltgt TO fc_zvaltgt.
*        ELSE.
        READ TABLE gt_dnd WITH KEY field_value  = pa_spmon+4(2)
                                   field_value2 = gt_zstarget-mvgr2.
        IF sy-subrc = 0.
          ADD gt_zstarget-zvaltgt TO fc_zvaltgt.
        ENDIF.
*        ENDIF.
      ELSE.
        CLEAR ls_zstarget.
        READ TABLE gt_zstarget INTO ls_zstarget
                               WITH KEY spmon = gt_zstarget-spmon
                                        vkbur = fu_vkbur
                                        kunnr = fu_kunnr
                                        mvgr2 = fu_mvgr2.
        IF sy-subrc = 0.
          READ TABLE gt_dnd WITH KEY field_value  = pa_spmon+4(2)
                                     field_value2 = gt_zstarget-mvgr2.
          IF sy-subrc = 0.
            ADD gt_zstarget-zvaltgt TO fc_zvaltgt.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  fc_zvaltgu  = fc_zvaltgt * 45 / 100.

  READ TABLE gt_clspkt INTO ls_clspkt
                       WITH KEY field_value2 = fu_mvgr2
                                field_value3 = fu_katr10
                                field_value  = fu_value.
  IF sy-subrc <> 0.
    CLEAR : fc_zvaltgt, fc_zvaltgu.
  ENDIF.
ENDFORM.                    " F_HITUNG_TARGET

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_SALES
*&---------------------------------------------------------------------*
FORM f_hitung_sales  USING    fu_vkbur fu_kunnr fu_mvgr2
                     CHANGING fc_grosval1 fc_grosval.

  CLEAR : gt_quantity1[], gt_quantity1, gt_quantity2[], gt_quantity2.

  LOOP AT gt_s619 WHERE vkbur = fu_vkbur
                    AND kunnr = fu_kunnr
                    AND mvgr2 = fu_mvgr2.
    READ TABLE gt_a603 WITH KEY matnr = gt_s619-matnr
                                mvgr2 = gt_s619-mvgr2
                                mvgr3 = gt_s619-mvgr3.
    IF sy-subrc = 0.
      READ TABLE gt_likp WITH KEY vbeln = gt_s619-vbeln.
      IF sy-subrc = 0.
        IF gt_likp-wadat_ist+6(2) LE gv_value2.
          ADD gt_s619-grosval TO fc_grosval1.

          gt_quantity1-spmon    = gt_s619-spmon.
          gt_quantity1-vkbur    = gt_s619-vkbur.
          gt_quantity1-pkunwe   = gt_s619-kunnr.
          gt_quantity1-mvgr2    = gt_s619-mvgr2.
          gt_quantity1-mvgr3    = gt_s619-mvgr3.
          gt_quantity1-qty      = gt_s619-lfimg.
          COLLECT gt_quantity1.
          CLEAR gt_quantity1.
        ELSE.
          gt_quantity2-spmon    = gt_s619-spmon.
          gt_quantity2-vkbur    = gt_s619-vkbur.
          gt_quantity2-pkunwe   = gt_s619-kunnr.
          gt_quantity2-mvgr2    = gt_s619-mvgr2.
          gt_quantity2-mvgr3    = gt_s619-mvgr3.
          gt_quantity2-qty      = gt_s619-lfimg.
          COLLECT gt_quantity2.
          CLEAR gt_quantity2.
        ENDIF.
      ENDIF.
      ADD gt_s619-grosval TO fc_grosval.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_HITUNG_SALES

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STRIKE
*&---------------------------------------------------------------------*
FORM f_hitung_strike  USING    fu_vkbur fu_kunnr fu_mvgr2 fu_value fu_kdgrp
                      CHANGING fc_strike1 fc_strike2.

  DATA : lt_quantity LIKE gt_quantity OCCURS 0 WITH HEADER LINE.

  CASE fu_value.
    WHEN '1'.     "Green
      LOOP AT gt_quantity1 WHERE vkbur  = fu_vkbur
                             AND pkunwe = fu_kunnr
                             AND mvgr2  = fu_mvgr2.
        CLEAR gt_zsclassopp.
        READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity1-mvgr2
                                          mvgr3 = gt_quantity1-mvgr3
                                          kdgrp = fu_kdgrp.
        IF sy-subrc = 0.
          IF gt_quantity1-qty GE gt_zsclassopp-minqty.
            ADD 1 TO fc_strike1.
          ENDIF.
        ENDIF.
        lt_quantity = gt_quantity1.
        COLLECT lt_quantity.
      ENDLOOP.

      LOOP AT gt_quantity2 WHERE vkbur  = fu_vkbur
                             AND pkunwe = fu_kunnr
                             AND mvgr2  = fu_mvgr2.
        CLEAR gt_zsclassopp.
        READ TABLE gt_zsclassopp WITH KEY mvgr2 = gt_quantity2-mvgr2
                                          mvgr3 = gt_quantity2-mvgr3
                                          kdgrp = fu_kdgrp.
        IF sy-subrc = 0.
          IF gt_quantity2-qty GE gt_zsclassopp-minqty.
            ADD 1 TO fc_strike2.
          ENDIF.
        ENDIF.
        lt_quantity = gt_quantity2.
        COLLECT lt_quantity.
      ENDLOOP.

      IF gv_2020 IS NOT INITIAL.
        CLEAR fc_strike1.
        LOOP AT lt_quantity WHERE vkbur  = fu_vkbur
                              AND pkunwe = fu_kunnr
                              AND mvgr2  = fu_mvgr2.
          CLEAR gt_zsclassopp.
          READ TABLE gt_zsclassopp WITH KEY mvgr2 = lt_quantity-mvgr2
                                            mvgr3 = lt_quantity-mvgr3
                                            kdgrp = fu_kdgrp.
          IF sy-subrc = 0.
            IF lt_quantity-qty GE gt_zsclassopp-minqty.
              ADD 1 TO fc_strike1.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN '2'.     "Blue
      LOOP AT gt_quantity1 WHERE vkbur  = fu_vkbur
                             AND pkunwe = fu_kunnr
                             AND mvgr2  = fu_mvgr2.
        lt_quantity = gt_quantity1.
        COLLECT lt_quantity.
      ENDLOOP.

      LOOP AT gt_quantity2 WHERE vkbur  = fu_vkbur
                             AND pkunwe = fu_kunnr
                             AND mvgr2  = fu_mvgr2.
        lt_quantity = gt_quantity2.
        COLLECT lt_quantity.
      ENDLOOP.

      LOOP AT lt_quantity WHERE vkbur  = fu_vkbur
                            AND pkunwe = fu_kunnr
                            AND mvgr2  = fu_mvgr2.
        CLEAR gt_zsclassopp.
        READ TABLE gt_zsclassopp WITH KEY mvgr2 = lt_quantity-mvgr2
                                          mvgr3 = lt_quantity-mvgr3
                                          kdgrp = fu_kdgrp.
        IF sy-subrc = 0.
          IF lt_quantity-qty GE gt_zsclassopp-minqty.
            ADD 1 TO fc_strike1.
          ENDIF.
        ENDIF.
      ENDLOOP.

*      fc_strike1  = fc_strike1 + fc_strike2.
  ENDCASE.
ENDFORM.                    " F_HITUNG_STRIKE

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_rtwb
              CHANGING fc_rtwb.
  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = fu_rtwb
      sign          = '-'
    IMPORTING
      output        = fc_rtwb
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUND

*&---------------------------------------------------------------------*
*&      Form  F_MINIMUM_TARGET
*&---------------------------------------------------------------------*
FORM f_minimum_target  USING    fu_value fu_kdgrp fu_mvgr2
                       CHANGING fc_tgtmin fc_tgtclass.

  DATA : ls_cltgt  LIKE LINE OF gt_cltgt,
         ls_mintgt LIKE LINE OF gt_mintgt,
         lv_value  TYPE zstarget-zvaltgt.

  CLEAR ls_cltgt.
  READ TABLE gt_cltgt INTO ls_cltgt
                      WITH KEY field_value = fu_kdgrp.
  IF sy-subrc = 0.
    CLEAR ls_mintgt.
    READ TABLE gt_mintgt INTO ls_mintgt
                         WITH KEY field_value  = ls_cltgt-field_value2
                                  field_value2 = fu_mvgr2.
    IF sy-subrc = 0.
      lv_value = ls_mintgt-field_value3.
      IF fu_value = 0.
        fc_tgtmin   = 0.
      ELSEIF fu_value < lv_value.
        fc_tgtmin   = lv_value.
      ELSE.
        fc_tgtmin   = fu_value.
      ENDIF.
    ENDIF.
  ENDIF.

  ADD fc_tgtmin TO fc_tgtclass.
ENDFORM.                    " F_MINIMUM_TARGET

*&---------------------------------------------------------------------*
*&      Form  F_GET_CLASS
*&---------------------------------------------------------------------*
FORM f_get_class  USING    fu_target fu_kdgrp fu_kunnr fu_class
                  CHANGING fc_text.

  DATA : lt_class   TYPE STANDARD TABLE OF ty_class,
         ls_class   LIKE LINE OF lt_class,
         ls_clssp   LIKE LINE OF gt_clssp,
         lv_zvaltgt TYPE zstarget-zvaltgt.

  IF fu_class IS NOT INITIAL.
    SELECT SINGLE vtext
      FROM tvk0t
      INTO fc_text
      WHERE katr10 = fu_class
        AND spras  = sy-langu.
  ELSE.
    READ TABLE gt_clssp INTO ls_clssp WITH KEY kunnr = fu_kunnr.
    IF sy-subrc = 0.
      fc_text = ls_clssp-text.
    ELSE.
      lt_class[] = gt_class[].
      DELETE lt_class WHERE kdgrp <> fu_kdgrp.
      SORT lt_class BY zvaltgt DESCENDING.

      READ TABLE lt_class INTO ls_class INDEX 1.
      IF sy-subrc = 0.
        IF fu_target > ls_class-zvaltgt.
          fc_text = ls_class-text.
        ELSE.
          lv_zvaltgt  = ls_class-zvaltgt.
          LOOP AT lt_class INTO ls_class FROM 2.
            IF fu_target <= lv_zvaltgt AND
              fu_target > ls_class-zvaltgt.
              fc_text = ls_class-text.
              EXIT.
            ELSE.
              lv_zvaltgt  = ls_class-zvaltgt.
            ENDIF.
          ENDLOOP.
          IF fc_text IS INITIAL.
            fc_text = ls_class-text.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CLASS

*&---------------------------------------------------------------------*
*&      Form  F_MVGR2_SELECT
*&---------------------------------------------------------------------*
FORM f_mvgr2_select .
  DATA : ls_tgtreg   LIKE LINE OF gr_tgtreg.

  SELECT *
    FROM zspaket_control
    INTO CORRESPONDING FIELDS OF TABLE gt_cntrl
    WHERE vkorg EQ pa_vkorg
      AND paket EQ 'OPP'
      AND field_name EQ 'MVGR2'
      AND datab LE sy-datum
      AND datbi GE sy-datum.

  SORT gt_cntrl BY field_value.
  LOOP AT gt_cntrl.
    r_mvgr2-low    = gt_cntrl-field_value.
    r_mvgr2-sign   = 'I'.
    r_mvgr2-option = 'EQ'.
    APPEND r_mvgr2.

    IF gt_cntrl-field_value2 = '1'.
      ls_tgtreg-low     = gt_cntrl-field_value.
      ls_tgtreg-sign    = 'I'.
      ls_tgtreg-option  = 'EQ'.
      APPEND ls_tgtreg TO gr_tgtreg.
      CLEAR ls_tgtreg.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MVGR2_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TARGET_QUARTER
*&---------------------------------------------------------------------*
FORM f_hitung_target_quarter  USING    fu_vkbur fu_kunnr fu_kdgrp
                                       fu_katr10 fu_value
                              CHANGING fc_opptgt.
  DATA : lv_zvaltgt TYPE zstarget-zvaltgt,
         lt_qtgt    LIKE gt_zstarget OCCURS 0 WITH HEADER LINE,
         ls_cltgt   LIKE LINE OF gt_cltgt,
         ls_mintgt  LIKE LINE OF gt_mintgt,
         lv_value   TYPE zstarget-zvaltgt,
         lv_mvgr2   TYPE zstarget-mvgr2,
         ls_clspkt  LIKE LINE OF gt_clspkt.

  CLEAR fc_opptgt.
  lt_qtgt[] = gt_qtgt[].
  SORT lt_qtgt BY spmon.
  DELETE ADJACENT DUPLICATES FROM lt_qtgt COMPARING spmon.

  LOOP AT lt_qtgt.
    CLEAR : lv_mvgr2.
    LOOP AT gt_qtgt WHERE vkbur = fu_vkbur
                      AND kunnr = fu_kunnr
                      AND spmon = lt_qtgt-spmon.
      IF gt_qtgt-mvgr2 IN gr_tgtreg.
*      IF radio3 IS NOT INITIAL.
*        ADD gt_zstarget-zvaltgt TO fc_tgtreg.
*      ELSE.

        READ TABLE gt_clspkt INTO ls_clspkt
                             WITH KEY field_value2 = gt_qtgt-mvgr2
                                      field_value3 = fu_katr10
                                      field_value  = fu_value.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        READ TABLE gt_dnd WITH KEY field_value  = gt_qtgt-spmon+4(2)
                                   field_value2 = gt_qtgt-mvgr2.
        IF sy-subrc = 0.
          ADD gt_qtgt-zvaltgt TO lv_zvaltgt.
          lv_mvgr2  = gt_qtgt-mvgr2.
        ENDIF.
*      ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR ls_cltgt.
    READ TABLE gt_cltgt INTO ls_cltgt
                        WITH KEY field_value = fu_kdgrp.
    IF sy-subrc = 0.
      CLEAR ls_mintgt.
      READ TABLE gt_mintgt INTO ls_mintgt
                           WITH KEY field_value  = ls_cltgt-field_value2
                                    field_value2 = lv_mvgr2.
      IF sy-subrc = 0.
        lv_value = ls_mintgt-field_value3.
        IF lv_zvaltgt = 0.
          lv_zvaltgt = 0.
        ELSEIF lv_zvaltgt < lv_value.
          lv_zvaltgt  = lv_value.
        ELSE.
          lv_zvaltgt  = lv_zvaltgt.
        ENDIF.
      ENDIF.
    ENDIF.
    ADD lv_zvaltgt TO fc_opptgt.
    CLEAR lv_zvaltgt.
  ENDLOOP.
ENDFORM.                    " F_HITUNG_TARGET_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_WB
*&---------------------------------------------------------------------*
FORM f_write_wb  USING    fu_rtwb fu_katr10
                 CHANGING fc_subrc fc_cit fc_wb fc_0.

  DATA : ls_param   LIKE LINE OF gt_param.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = fc_cit
*    IMPORTING
*      output = fc_cit.

  CLEAR : ls_param, fc_0.
  LOOP AT gt_param INTO ls_param WHERE field_value  = pa_mvgr2
                                   AND field_value5 = fu_katr10.
    IF fc_cit >= ls_param-field_value2.
      fc_wb = ls_param-field_value3.
      IF fu_rtwb < ls_param-field_value6.
        fc_0  = 'X'.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.
  fc_subrc = sy-subrc.
ENDFORM.                    " F_WRITE_WB

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_STRIKE
*&---------------------------------------------------------------------*
FORM f_modify_strike  CHANGING fc_valid.
  DATA: ls_quantity2  LIKE LINE OF gt_quantity2.

  IF pa_mvgr2 = '01' OR
    pa_mvgr2 = '02' OR
    pa_mvgr2 = '03' OR
    pa_mvgr2 = '04'.
    LOOP AT gt_quantity2 INTO ls_quantity2 WHERE pkunwe = gt_detail-pkunwe.
      IF ls_quantity2-mvgr3 = '09' OR
        ls_quantity2-mvgr3 = '10' OR
        ls_quantity2-mvgr3 = '11'.
        CLEAR fc_valid.
      ENDIF.
    ENDLOOP.
  ELSEIF pa_mvgr2 = '05'.
    CLEAR fc_valid.
  ENDIF.
ENDFORM.                    " F_MODIFY_STRIKE
