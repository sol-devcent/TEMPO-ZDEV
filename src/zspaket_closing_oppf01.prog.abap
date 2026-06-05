*&-----------------------------------------------------------*
*&  Include           ZS_RPT_OPPF01
*&-----------------------------------------------------------*
*&-----------------------------------------------------------*
*&      Form  f_get_data
*&-----------------------------------------------------------*
*       text
*------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*------------------------------------------------------------*
FORM f_get_data.
* Get data from Table S706
  SELECT *
    FROM s706
    INTO CORRESPONDING FIELDS OF TABLE t_s706
    WHERE ssour  EQ space
      AND vrsio  EQ '000'
      AND spmon  EQ p_spmon
      AND sptag  EQ '00000000'
      AND spwoc  EQ '000000'
      AND spbup  EQ '000000'
      AND vkbur  EQ gv_vstel
      AND pkunwe IN s_kunnr
*      AND mvgr2  IN r_mvgr2
      AND mvgr2  IN r_rptmvgr2
      AND zcount EQ '1'.

* Get data from Table S700
  SELECT *
    FROM s700
    INTO CORRESPONDING FIELDS OF TABLE t_s700
    WHERE ssour  EQ space
      AND vrsio  EQ '000'
      AND spmon  EQ p_spmon
      AND sptag  EQ '00000000'
      AND spwoc  EQ '000000'
      AND spbup  EQ '000000'
      AND pkunwe IN s_kunnr
      AND vkbur  EQ gv_vstel
*      AND mvgr2  IN r_mvgr2.
      AND mvgr2  IN r_rptmvgr2.

* Check ITAB not initial
  IF t_s700[] IS INITIAL AND t_s706[] IS INITIAL.
    MESSAGE i000(zs) WITH 'Data S700 dan S706 tidak ada'.
    WRITE :/ 'Data S700 dan S706 tidak ada'.
    STOP.
  ENDIF.

  PERFORM f_modify_itab_s700.

  IF NOT t_s706[] IS INITIAL.
    LOOP AT t_s706.
      t_s706-matwa    = space.
      t_s706-ztotweek = 0.
      MODIFY t_s706 TRANSPORTING matwa ztotweek.
    ENDLOOP.
  ENDIF.

  IF NOT t_s700[] IS INITIAL.
    t_s700b[] = t_s700[].
  ENDIF.

  SORT t_s706 BY spmon pkunwe matnr.
  SORT t_s700 BY spmon pkunwe matnr.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_zdisc    LIKE s706-zdisc,
        ld_sisa1    LIKE s700-opnbal,
        ld_sisa2    LIKE s700-opnbal,
        ld_add      TYPE i,
        ld_times    TYPE i,
        ld_count    TYPE i,
        ld_ztotweek TYPE zdec.

  DATA: sw,
        l_s706d LIKE t_s706b.
* 1st process, alokasi beban material untuk diri sendiri
  LOOP AT t_s706 WHERE zdisc NE 0.
    t_s706a = t_s706.
    READ TABLE t_s700 WITH KEY pkunwe = t_s706-pkunwe
                               matnr  = t_s706-matnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF t_s700-opnbal GT 0.
        ld_zdisc = abs( t_s706-zdisc ).
        t_s706a-sisa = t_s700-opnbal - ld_zdisc.

        IF t_s706a-sisa LE 0.
          ld_sisa2         = t_s706a-sisa.
          t_s706a-matwa    = t_s700-matnr.
          t_s706a-ztotweek = - t_s700-opnbal.
*          t_s706a-ztotweek = ld_sisa1 * -1.
          t_s706a-sisa     = 0.
          ld_add = 1.
        ELSE.
          IF t_s706a-sisa GT t_s706a-zdisc.
            t_s706a-matwa    = t_s700-matnr.
            t_s706a-ztotweek = t_s706-zdisc.
          ENDIF.
        ENDIF.

        ld_sisa1       = t_s706a-sisa.
        t_s700-opnbal = t_s706a-sisa.

*        MODIFY t_s700 INDEX sy-tabix TRANSPORTING opnbal.
      ELSE.
      ENDIF.
    ENDIF.
    APPEND t_s706a.

    IF ld_add EQ 1.
      t_s706a-zcount = t_s706a-zcount + 1.
      SHIFT t_s706a-zcount LEFT DELETING LEADING space.
      t_s706a-matwa    = space.
      t_s706a-ztotweek = ld_sisa2.
      t_s706a-zdisc    = 0.
      t_s706a-zxx      = 0.
      APPEND t_s706a.
      CLEAR: ld_add.
    ENDIF.
  ENDLOOP.

  CLEAR: ld_zdisc.

* 2nd process ( MATWA eq SPACE ), untuk yang belum ada beban
  t_s700a[] = t_s700[].
  DELETE t_s700a WHERE opnbal EQ 0.
  SORT BY t_s700a pkunwe.
  LOOP AT t_s700a.
    t_count-pkunwe  = t_s700a-pkunwe.
    t_count-opnbal = t_s700a-opnbal.
    t_count-count   = 1.
    COLLECT t_count.
  ENDLOOP.
  DELETE t_count WHERE opnbal EQ 0.
  SORT t_s700 BY pkunwe matnr.
  SORT t_count BY pkunwe.
  LOOP AT t_s700 WHERE opnbal NE 0.
    ON CHANGE OF t_s700-pkunwe.
      CLEAR: ld_count.
    ENDON.
    READ TABLE t_count WITH KEY pkunwe = t_s700-pkunwe
    BINARY SEARCH.
    ADD 1 TO ld_count.

* Percentage digunakan untuk memproporsionalkan beban WB
    IF sy-subrc EQ 0.
      t_s700-percentage = t_s700-opnbal / t_count-opnbal * 100.
    ELSE.
* add by MKO to fix open WB = 0
      t_s700-percentage = 100.
    ENDIF.
    t_s700-count = ld_count.
    MODIFY t_s700 TRANSPORTING percentage count.
  ENDLOOP.

  SORT t_s706a BY pkunwe matnr.
  SORT t_s700 BY pkunwe count.
  LOOP AT t_s706a.
    t_s706b = t_s706a.
    IF t_s706a-matwa EQ space.
      READ TABLE t_s700 WITH KEY pkunwe = t_s706a-pkunwe
                                 count  = 1
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_s706b-matwa = t_s700-matnr.
        IF t_s706a-zdisc NE 0.
          ld_ztotweek = t_s706a-zdisc * t_s700-percentage / 100.
          t_s706b-ztotweek = ld_ztotweek.
          t_s700-opnbal   = t_s700-opnbal + t_s700-oppadj +
                            t_s700-oppext." + t_s706b-ztotweek.
          MODIFY t_s700 INDEX sy-tabix TRANSPORTING opnbal.
        ELSE.
          ld_zdisc         = t_s706b-ztotweek.
          ld_ztotweek = ld_zdisc * t_s700-percentage / 100.
          t_s706b-ztotweek = ld_ztotweek.
          t_s700-opnbal   = t_s700-opnbal + t_s700-oppadj +
                            t_s700-oppext." + t_s706b-ztotweek.
          MODIFY t_s700 INDEX sy-tabix TRANSPORTING opnbal.
        ENDIF.
        APPEND t_s706b.
      ENDIF.

* add by MKO
      t_s706a-zcount = 1.
* end add
      READ TABLE t_count WITH KEY pkunwe = t_s700-pkunwe
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ld_times = t_count-count.
*        ld_times = t_count-count - 1.
        DO ld_times TIMES.
          t_s706a-zcount = t_s706a-zcount + 1.
          t_s706b-zcount = t_s706a-zcount + 1.
          t_s706b-zxx    = 0.
          t_s706b-zdisc  = 0.
          SHIFT t_s706b-zcount LEFT DELETING LEADING space.
          READ TABLE t_s700 WITH KEY pkunwe = t_s706a-pkunwe
                                     count  = t_s706a-zcount
*                                     count  = t_count-count
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_s706b-matwa = t_s700-matnr.
            IF t_s706a-zdisc NE 0.
*            t_s706b-ztotweek = t_s706a-zdisc * t_s700-percentage / 100.
              ld_ztotweek = t_s706a-zdisc * t_s700-percentage / 100.
              t_s706b-ztotweek = ld_ztotweek.
              t_s700-opnbal = t_s700-opnbal + t_s700-oppadj +
                               t_s700-oppext." + t_s706b-ztotweek.
              MODIFY t_s700 INDEX sy-tabix TRANSPORTING opnbal.
            ELSE.
* revisi tgl 23/08/2006
              ld_ztotweek = ld_zdisc * t_s700-percentage / 100.
              t_s706b-ztotweek = ld_ztotweek.
              t_s700-opnbal = t_s700-opnbal + t_s700-oppadj +
                               t_s700-oppext." + t_s706b-ztotweek.
              MODIFY t_s700 INDEX sy-tabix TRANSPORTING opnbal.
            ENDIF.
          ENDIF.
          APPEND t_s706b.
        ENDDO.
      ENDIF.
    ELSE.
      APPEND t_s706b.
    ENDIF.
  ENDLOOP.

  SORT t_s706b
     BY spmon vkbur pkunwe mvgr2 mvgr3 vbeln_01 posnr matnr zcount.
  sw = 1.
  LOOP AT t_s706b.
    ON CHANGE OF t_s706b-spmon OR
                 t_s706b-vkbur OR
                 t_s706b-pkunwe OR
                 t_s706b-mvgr2  OR
                 t_s706b-mvgr3 OR
                 t_s706b-vbeln_01 OR
                 t_s706b-posnr OR
                 t_s706b-matnr.
      IF sw = 1.
      ELSE.
        IF ld_times > 2.
          DELETE t_s706d WHERE spmon = l_s706d-spmon AND
                               vkbur = l_s706d-vkbur AND
                               pkunwe = l_s706d-pkunwe AND
                               mvgr2 = l_s706d-mvgr2 AND
                               mvgr3 = l_s706d-mvgr3 AND
                               vbeln_01 = l_s706d-vbeln_01 AND
                               posnr = l_s706d-posnr AND
                               matnr = l_s706d-matnr AND
                               zcount = l_s706d-zcount.
        ENDIF.
        CLEAR: l_s706d.
      ENDIF.
    ENDON.
    ld_times = t_s706b-zcount.
    sw = 2.
    MOVE-CORRESPONDING t_s706b TO l_s706d.
    APPEND l_s706d TO t_s706d.
  ENDLOOP.
  IF sw = 1.
  ELSE.
    IF ld_times > 2.
      DELETE t_s706d WHERE spmon = l_s706d-spmon AND
                           vkbur = l_s706d-vkbur AND
                           pkunwe = l_s706d-pkunwe AND
                           mvgr2 = l_s706d-mvgr2 AND
                           mvgr3 = l_s706d-mvgr3 AND
                           vbeln_01 = l_s706d-vbeln_01 AND
                           posnr = l_s706d-posnr AND
                           matnr = l_s706d-matnr AND
                           zcount = l_s706d-zcount.
    ENDIF.
    CLEAR: l_s706d.
  ENDIF.

  REFRESH: t_s706b.
  APPEND LINES OF t_s706d  TO t_s706b.
  REFRESH: t_s706d.

*  ld_times = ld_times + 1.
*  DELETE t_s706b WHERE zcount = ld_times.

* 3rd process
* Summary table t_s706b ztotweek
*  SORT t_s706b BY spmon vkbur pkunwe matwa.
  SORT t_s706b BY vbeln_01 posnr zcount.
  LOOP AT t_s706b.
    t_s706b_sum-spmon    = t_s706b-spmon.
    t_s706b_sum-vkbur    = t_s706b-vkbur.
    t_s706b_sum-pkunwe   = t_s706b-pkunwe.
    t_s706b_sum-matwa    = t_s706b-matwa.
    t_s706b_sum-ztotweek = t_s706b-ztotweek.
    t_s706b_sum-zdisc    = t_s706b-zdisc.
    COLLECT t_s706b_sum.

    ON CHANGE OF t_s706b-vbeln_01 OR
                 t_s706b-posnr.
      CLEAR: t_s706_result-zcount.
    ENDON.
    ADD 1 TO t_s706_result-zcount.
    SHIFT t_s706_result-zcount LEFT DELETING LEADING space.

    t_s706_result-vrsio      = t_s706b-vrsio.
    t_s706_result-spmon      = t_s706b-spmon.
    t_s706_result-vkbur      = t_s706b-vkbur.
    t_s706_result-pkunwe     = t_s706b-pkunwe.
    t_s706_result-mvgr2      = t_s706b-mvgr2.
    t_s706_result-mvgr3      = t_s706b-mvgr3.
    t_s706_result-vbeln_01   = t_s706b-vbeln_01.
    t_s706_result-posnr      = t_s706b-posnr.
    t_s706_result-matnr      = t_s706b-matnr.
    t_s706_result-waerk      = t_s706b-waerk.
    t_s706_result-zxx        = t_s706b-zxx.
    t_s706_result-zdisc      = t_s706b-zdisc.
    t_s706_result-ztotweek   = t_s706b-ztotweek.
*    t_s706_result-ztotwexppn = t_s706b-ztotweek / ( 11 / 10 ).
    t_s706_result-ztotwexppn = t_s706b-ztotweek * 10 / 11.
    t_s706_result-matwa      = t_s706b-matwa.
    APPEND t_s706_result.
  ENDLOOP.

*-- penambahan value untuk selisih antara zdisc & ztotweek
  SORT t_s706_result BY pkunwe matwa.
  LOOP AT t_s706_result.
    t_s706_sum-pkunwe   = t_s706_result-pkunwe.
    t_s706_sum-zdisc    = t_s706_result-zdisc.
    t_s706_sum-ztotweek = t_s706_result-ztotweek.
    t_s706_sum-selisih  = t_s706_result-zdisc - t_s706_result-ztotweek.
    COLLECT t_s706_sum.
  ENDLOOP.
*--

  SORT t_s700 BY spmon vkbur pkunwe matnr.
  SORT t_s706b_sum BY spmon vkbur pkunwe matwa.
  SORT t_s700b BY spmon vkbur pkunwe matnr.
  SORT t_s706_sum BY pkunwe.

  LOOP AT t_s700.
    t_s700_result = t_s700.
    t_s700_result-oppend  = t_s700-opnbal.
    READ TABLE t_s706b_sum WITH KEY spmon  = t_s700-spmon
                                    vkbur  = t_s700-vkbur
                                    pkunwe = t_s700-pkunwe
                                    matwa  = t_s700-matnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_s700_result-totweek = t_s706b_sum-ztotweek.
    ELSE.
      CLEAR: t_s700_result-totweek.
    ENDIF.

    ON CHANGE OF t_s700-pkunwe.
      READ TABLE t_s706_sum WITH KEY pkunwe = t_s700-pkunwe
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF NOT t_s706_sum IS INITIAL.
          t_s700_result-totweek = t_s700_result-totweek +
                                   t_s706_sum-selisih.
          t_s700_result-oppend  = t_s700_result-oppend +
                                   t_s706_sum-selisih.
        ENDIF.
      ENDIF.
    ENDON.

    READ TABLE t_s700b WITH KEY spmon  = t_s700-spmon
                                vkbur  = t_s700-vkbur
                                pkunwe = t_s700-pkunwe
                                matnr  = t_s700-matnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_s700_result-opnbal  = t_s700b-opnbal.
      t_s700_result-oppout  = t_s700b-oppout.
    ELSE.
      CLEAR: t_s700_result-opnbal, t_s700_result-oppout.
    ENDIF.
    APPEND t_s700_result.
  ENDLOOP.

* Untuk offset selisih pembulatan hasil pembagian beban ke item pertama
  LOOP AT t_s706_result.
    ON CHANGE OF t_s706_result-pkunwe.
      READ TABLE t_s706_sum WITH KEY pkunwe = t_s706_result-pkunwe
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF NOT t_s706_sum-selisih IS INITIAL.
          t_s706_result-ztotweek = t_s706_result-ztotweek +
                                   t_s706_sum-selisih.
          MODIFY t_s706_result TRANSPORTING ztotweek.
        ENDIF.
      ENDIF.
    ENDON.
  ENDLOOP.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_sort_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sort_data.
  SORT t_s700 BY spmon pkunwe matnr.
  SORT t_s706a BY spmon pkunwe matnr zcount.
  SORT t_s706b BY spmon pkunwe matnr vbeln_01 zcount.
  SORT t_s700b BY spmon pkunwe matnr.
  SORT t_s700_result BY spmon pkunwe matnr.
  SORT t_s706_result BY spmon pkunwe matnr vbeln_01 zcount.
ENDFORM.                    " f_sort_data

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data.
  DATA: ld_percentage TYPE decv5.
  WRITE:/ 'TABLE S706'.
  WRITE:/ sy-uline.
  WRITE:/ sy-vline, 'SPMON',
          sy-vline, 'VKBUR',
          sy-vline, (8) 'PKUNWE',
          sy-vline, 'MVGR2',
          sy-vline, 'MVGR3',
          sy-vline, 'VBELN_01',
          sy-vline, 'POSNR',
          sy-vline, 'ZCOUNT',
          sy-vline, (8) 'MATNR',
          sy-vline, (8) 'MATWA',
          sy-vline, (13) 'ZDISC',
          sy-vline, (13) 'ZTOTWEEK',
          sy-vline, (13) 'ZXX',
          sy-vline.
  WRITE:/ sy-uline.
  LOOP AT t_s706_result.
    WRITE: / sy-vline NO-GAP, t_s706_result-spmon NO-GAP,
             sy-vline, (5) t_s706_result-vkbur,
             sy-vline NO-GAP, t_s706_result-pkunwe NO-GAP,
             sy-vline, (5) t_s706_result-mvgr2,
             sy-vline, (5) t_s706_result-mvgr3,
             sy-vline NO-GAP, t_s706_result-vbeln_01 NO-GAP,
             sy-vline, t_s706_result-posnr NO-GAP,
             sy-vline, (6) t_s706_result-zcount,
             sy-vline NO-GAP, (10) t_s706_result-matnr NO-GAP,
             sy-vline NO-GAP, (10) t_s706_result-matwa NO-GAP,
             sy-vline NO-GAP, (15) t_s706_result-zdisc CURRENCY
                                   t_s706_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s706_result-ztotweek CURRENCY
                                   t_s706_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s706_result-zxx CURRENCY
                                   t_s706_result-waerk NO-GAP,
             sy-vline.
  ENDLOOP.
  WRITE:/ sy-uline.

  SKIP 2.
  WRITE:/ 'TABLE S700'.
  WRITE:/ sy-uline.
  WRITE:/ sy-vline, 'SPMON',
          sy-vline, 'VKBUR',
          sy-vline, (8) 'PKUNWE',
          sy-vline, 'KDGRP',
          sy-vline, 'MVGR2',
          sy-vline, 'MVGR3',
          sy-vline, (8) 'MATNR',
          sy-vline, (13) 'OPNBAL',
          sy-vline, (13) 'OPPOUT',
          sy-vline, (13) 'OPPIN',
          sy-vline, (13) 'OPPEND',
          sy-vline, (13) 'TOTWEEK',
          sy-vline.
  WRITE:/ sy-uline.
  LOOP AT t_s700_result.
*    ld_percentage = t_s700-percentage.
    WRITE: / sy-vline NO-GAP, t_s700_result-spmon NO-GAP,
             sy-vline, (5) t_s700_result-vkbur,
             sy-vline NO-GAP, t_s700_result-pkunwe NO-GAP,
             sy-vline, (5) t_s700_result-kdgrp,
             sy-vline, (5) t_s700_result-mvgr2,
             sy-vline, (5) t_s700_result-mvgr3,
             sy-vline NO-GAP, (10) t_s700_result-matnr NO-GAP,
             sy-vline NO-GAP, (15) t_s700_result-opnbal CURRENCY
                                   t_s700_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s700_result-oppout CURRENCY
                                   t_s700_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s700_result-oppin CURRENCY
                                   t_s700_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s700_result-oppend CURRENCY
                                   t_s700_result-waerk NO-GAP,
             sy-vline NO-GAP, (15) t_s700_result-totweek CURRENCY
                                   t_s700_result-waerk NO-GAP,
             sy-vline.
  ENDLOOP.
  WRITE:/ sy-uline.
ENDFORM.                    " f_print_data

*&---------------------------------------------------------------------*
*&      Form  f_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Untuk Update table S700 dan S706 dengan data hasil perhitungan beban
FORM f_modify.
  MODIFY s706 FROM TABLE t_s706_result.
  MODIFY s700 FROM TABLE t_s700_result.
  COMMIT WORK AND WAIT.
ENDFORM.                    " f_modify

*&---------------------------------------------------------------------*
*&      Form  f_summary_target
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary_target.
  LOOP AT i_s7002 INTO wa_s700.
    wa_s700_sum-pkunwe   = wa_s700-pkunwe.
    wa_s700_sum-mvgr2    = wa_s700-mvgr2.
    wa_s700_sum-netsales = wa_s700-netsales.
    COLLECT wa_s700_sum INTO i_s7002_sum.
  ENDLOOP.
ENDFORM.                    " f_summary_target

*&------------------------------------------------------------------*
*&      Form  f_modify_zoppin
*&------------------------------------------------------------------*
*       text
*-------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*-------------------------------------------------------------------*
FORM f_modify_zoppin USING fu_pkunwe
                           fu_mvgr2
                     CHANGING fc_zoppin
                              fc_zoppext.

  DATA: ld_ztgtmin LIKE zsclassopp-ztgtmin.

  READ TABLE i_zstargetsum WITH KEY kunnr = fu_pkunwe
                                    mvgr2  = fu_mvgr2.
  IF sy-subrc EQ 0.
    READ TABLE lt_parameter INTO wa_zsparameter WITH KEY type = fu_mvgr2+1(1).
    IF i_zstargetsum-zvaltgt LT wa_zsparameter-mintgt.
      ld_ztgtmin = wa_zsparameter-mintgt.
    ENDIF.
  ENDIF.

  READ TABLE i_s7002_sum INTO wa_s700_sum WITH KEY pkunwe = fu_pkunwe
                                                   mvgr2  = fu_mvgr2
  BINARY SEARCH.
  IF sy-subrc EQ 0.
* jika ach nya kurang dari % atau realisasi < target, wb 2 nya di hapus
    IF wa_s700_sum-netsales LE ld_ztgtmin.
      CLEAR: fc_zoppin.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_modify_zoppin

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TARGET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_target .

  DATA: ld_day          TYPE sy-datum,       "Date bulan berikutnya
        ld_day1         TYPE sy-datum,      "Date bulan sebelumnya
        lt_zstarget     LIKE zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargetn    LIKE lt_zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargeto    LIKE lt_zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargetold  LIKE zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargetnext LIKE zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargettmp  LIKE zstarget OCCURS 0 WITH HEADER LINE,
        lt_zstargetna   LIKE zstarget_na OCCURS 0 WITH HEADER LINE.

  DATA: ld_month TYPE fcmnr,
        ld_year  TYPE gjahr,
        ld_mvgr2 LIKE zstarget-mvgr2,
        ld_date1 LIKE sy-datum,
        ld_date2 LIKE sy-datum,
        l_kbert  LIKE konp-kbetr,
        dat1     LIKE a510-datab,
        dat2     LIKE a510-datbi.

  DATA: BEGIN OF lt_konp OCCURS 0,
          knumh TYPE knumh,
          kappl TYPE kappl,
          kschl TYPE kscha,
          matnr TYPE matnr,
          datab TYPE datab,
          datbi TYPE datbi,
          kbetr TYPE kbetr,
        END OF lt_konp.

  CONCATENATE p_spmon '01' INTO dat1.
  CONCATENATE p_spmon '31' INTO dat2.

  CONCATENATE p_spmon '01' INTO ld_day.
  dat1 = ld_day.
*  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*    EXPORTING
*      day_in            = ld_day
*    IMPORTING
*      last_day_of_month = ld_day.
*  dat2 = ld_day.
*  ld_day = ld_day + 1.

  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      days        = '0'
      months      = '-1'
      start_date  = ld_day
    IMPORTING
      result_date = ld_day1.

  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      days        = '0'
      months      = '1'
      start_date  = ld_day
    IMPORTING
      result_date = ld_day.

  SELECT * FROM zstarget
  INTO CORRESPONDING FIELDS OF TABLE lt_zstarget
  WHERE vkorg EQ p_vkorg AND
        vtweg EQ p_vtweg AND
        gjahr BETWEEN '0000' AND '9999' AND
        spmon BETWEEN p_spmon AND ld_day(6) AND
        vkbur EQ p_vstel AND
        kunnr IN s_kunnr AND
        mvgr2 IN r_mvgr2 AND
        zsts  IN ('A', 'N').

  lt_zstargetn[] = lt_zstarget[].
  lt_zstargeto[] = lt_zstarget[].

  lt_zstarget-spmon = ld_day(6).

* lt_zstarget  = target bulan lalu
* lt_zstargetn = target bulan ini yang sudah ada
*--------------------------------------------------------------------*
  DELETE lt_zstarget WHERE spmon = lt_zstarget-spmon.   "Hapus next month
  DELETE lt_zstargeto WHERE spmon = lt_zstarget-spmon.  "Hapus next month
  DELETE lt_zstargetn  WHERE spmon = p_spmon.           "Hapus current month

  MODIFY lt_zstarget TRANSPORTING spmon WHERE spmon = p_spmon.  "Rubah spmon kebulan berikut

* Kalau bulan ini belum ada target
  IF lt_zstargetn IS INITIAL.
    IF lt_zstarget[] IS NOT INITIAL.
      SELECT * FROM zstarget_old
      INTO CORRESPONDING FIELDS OF TABLE lt_zstargetold
      FOR ALL ENTRIES IN lt_zstarget
      WHERE vkorg EQ lt_zstarget-vkorg AND
            vtweg EQ lt_zstarget-vtweg AND
            gjahr BETWEEN '0000' AND '9999' AND
            spmon EQ ld_day1(6)        AND
            vkbur EQ lt_zstarget-vkbur AND
            kunnr EQ lt_zstarget-kunnr AND
            mvgr2 EQ lt_zstarget-mvgr2 AND
            zsts  IN ('A', 'N').

      SELECT * FROM zstarget
      INTO CORRESPONDING FIELDS OF TABLE lt_zstargetnext
      FOR ALL ENTRIES IN lt_zstarget
      WHERE vkorg EQ lt_zstarget-vkorg AND
            vtweg EQ lt_zstarget-vtweg AND
            gjahr BETWEEN '0000' AND '9999' AND
            spmon EQ ld_day(6)         AND
            vkbur EQ lt_zstarget-vkbur AND
            kunnr EQ lt_zstarget-kunnr AND
            mvgr2 EQ lt_zstarget-mvgr2 AND
            zsts  IN ('A', 'N').
    ENDIF.

    SORT lt_zstarget BY vkorg vkbur.
    SORT lt_zstargetna BY vkorg vkbur.
    LOOP AT lt_zstarget.
      SELECT a~knumh a~kappl a~kschl matnr datab datbi kbetr
             FROM konp AS a JOIN a510 AS b ON
                  a~knumh = b~knumh AND
                  a~kappl = b~kappl AND
                  a~kschl = b~kschl
              INTO TABLE lt_konp
              WHERE b~matnr EQ lt_zstarget-matnr AND
                    b~kappl EQ 'V'     AND
                    b~kschl EQ 'ZN01'  AND
                    b~datab <= dat2 AND
                    b~datbi >= dat1.

      SORT lt_konp BY knumh DESCENDING.
      READ TABLE lt_konp WITH KEY matnr = lt_zstarget-matnr
                                  kappl = 'V'
                                  kschl = 'ZN01'.
      IF sy-subrc EQ 0.
        lt_zstarget-zvaltgt = lt_zstarget-tgt_qty * lt_konp-kbetr.
        MODIFY lt_zstarget TRANSPORTING zvaltgt.
      ENDIF.

      CLEAR i_mvke.
      READ TABLE i_mvke WITH KEY vkorg = p_vkorg
                                 matnr = lt_zstarget-matnr.
      lt_zstarget-mvgr2 = i_mvke-mvgr2.
      lt_zstarget-mvgr3 = i_mvke-mvgr3.
      MODIFY lt_zstarget TRANSPORTING mvgr2 mvgr3.
    ENDLOOP.

*HATI-HATI bila sudah ada target di bulan berikut
*Jangan jalankan closing lagi, karena semua sudah terupdate kecuali target
    CLEAR lt_zstargeto-gjahr.
    MODIFY lt_zstargeto TRANSPORTING gjahr WHERE gjahr NE '0000'.

    CLEAR lt_zstargetold-gjahr.
    MODIFY lt_zstargetold TRANSPORTING gjahr WHERE gjahr NE '0000'.

    IF lt_zstargetold[] IS INITIAL.
      INSERT zstarget_old FROM TABLE lt_zstargeto.
    ELSE.
      MODIFY zstarget_old FROM TABLE lt_zstargeto.
      lt_zstargetold-spmon = ld_day(6).
      MODIFY lt_zstargetold TRANSPORTING spmon WHERE spmon = ld_day1(6).  "Rubah spmon kebulan berikut
    ENDIF.

    IF lt_zstargetnext[] IS INITIAL.
      INSERT zstarget FROM TABLE lt_zstargetold.
    ELSE.
      MODIFY zstarget FROM TABLE lt_zstargetold.
    ENDIF.
    DELETE zstarget FROM TABLE lt_zstargeto.
*    DELETE zstarget_na FROM TABLE lt_zstargetna.
    COMMIT WORK AND WAIT.
  ENDIF.

*--------------------------*
* Update Condition Master
*--------------------------*
  CLEAR: opnbal, pkunwe.
  IF p_updvk = 'X'.
**    PERFORM f_bapi_pricing.
*    PERFORM f_bapi_pricing_zc01.
*    PERFORM f_bapi_pricing_ze01.
  ENDIF.
ENDFORM.                    " F_UPDATE_TARGET

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PERCEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_percen CHANGING fc_datum.

* Get tanggal awal dan akhir bulan current month
  ld_month = p_spmon+4(2).
  ld_year = p_spmon(4).
  CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
    EXPORTING
      i_month     = ld_month
      i_year      = ld_year
    IMPORTING
      e_first_day = ld_date1
      e_last_day  = ld_date2
    EXCEPTIONS
      wrong_date  = 1
      OTHERS      = 2.

  fc_datum = ld_date2.

  SELECT *
    INTO TABLE lt_parameter
    FROM zsparameter
    WHERE vkorg = p_vkorg AND
          paket = p_paket AND
        ( datab LE ld_date1 OR datab LE ld_date2 ) AND
          datbi GE ld_date2.

  LOOP AT lt_parameter.
    wa_zsparameter = lt_parameter.
    CASE lt_parameter-type.
      WHEN '0'.
        percen_ext10 = lt_parameter-percen1.
      WHEN '1'.
        persen = lt_parameter-percen2.
        percen_ext1 = lt_parameter-percen1.
      WHEN '2'.
        persen1 = lt_parameter-percen2.
        percen_ext2 = lt_parameter-percen1.
      WHEN '3'.
        persen2 = lt_parameter-percen2.
        percen_ext3 = lt_parameter-percen1.
      WHEN '4'.
        persen3 = lt_parameter-percen2.
        percen_ext4 = lt_parameter-percen1.
      WHEN '5'.
        percen_ext5 = lt_parameter-percen1.
      WHEN '6'.
        percen_ext6 = lt_parameter-percen1.
      WHEN '7'.
        percen_ext7 = lt_parameter-percen1.
      WHEN '8'.
        percen_ext8 = lt_parameter-percen1.
      WHEN '9'.
        percen_ext9 = lt_parameter-percen1.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_INIT_PERCEN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_S700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_itab_s700 .
  DATA: BEGIN OF lt_knvv OCCURS 0,
          kunnr LIKE knvv-kunnr,
          vkorg LIKE knvv-vkorg,
          vtweg LIKE knvv-vtweg,
          spart LIKE knvv-spart,
          kdgrp LIKE knvv-kdgrp,
          vkbur LIKE knvv-vkbur,
          konda LIKE knvv-konda,
        END OF lt_knvv.

  DATA: lt_mvke  TYPE t_mvke OCCURS 0 WITH HEADER LINE,
        ld_month TYPE fcmnr,
        ld_year  TYPE gjahr,
        ld_date1 LIKE sy-datum,
        ld_date2 LIKE sy-datum.

* Get tanggal awal dan akhir bulan current month
  ld_month = p_spmon+4(2).
  ld_year = p_spmon(4).
  CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
    EXPORTING
      i_month     = ld_month
      i_year      = ld_year
    IMPORTING
      e_first_day = ld_date1
      e_last_day  = ld_date2
    EXCEPTIONS
      wrong_date  = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mvke
    FROM a603
    WHERE kappl = 'V'       AND
          kschl = 'ZPKT'    AND
          vkorg = p_vkorg   AND
          konda IN r_konda  AND
          auart_sd = space  AND
          matnr NE space    AND
*          mvgr2 < '10'      AND
          mvgr2  IN r_rptmvgr2 AND
        ( datab LE ld_date1 OR datab LE ld_date2 ) AND
          datbi GE ld_date2.

  SELECT kunnr vkorg vtweg spart kdgrp vkbur konda
    INTO CORRESPONDING FIELDS OF TABLE lt_knvv
    FROM knvv
    FOR ALL ENTRIES IN t_s700
    WHERE kunnr = t_s700-pkunwe  AND
          vkorg = p_vkorg        AND
          vtweg = p_vtweg        AND
          spart = '00'.

  LOOP AT t_s700.
    CLEAR: lt_knvv,lt_mvke.
    READ TABLE lt_knvv WITH KEY kunnr = t_s700-pkunwe.
    IF sy-subrc = 0.
      t_s700-kdgrp = lt_knvv-kdgrp.
    ENDIF.
    READ TABLE lt_mvke WITH KEY matnr = t_s700-matnr
                                konda = lt_knvv-konda.
    IF sy-subrc = 0.
      t_s700-mvgr2 = lt_mvke-mvgr2.
      t_s700-mvgr3 = lt_mvke-mvgr3.
    ELSE.
      t_s700-mvgr2 = '99'.
    ENDIF.
*    IF sy-subrc NE 0 AND p_vkorg = '8070'.
*      t_s700-mvgr2 = '99'.
*    ENDIF.
    MODIFY t_s700 TRANSPORTING kdgrp mvgr2 mvgr3.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_ITAB_S700

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_EXTRAWB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_PKUNWE  text
*      -->FU_MVGR2  text
*      -->FU_NETSALES  text
*      -->FU_VALTGT  text
*      <--FC_OPPEXT  text
*----------------------------------------------------------------------*
FORM f_hitung_extrawb  USING    fu_pkunwe
                                fu_mvgr2
                                fu_matnr
                                fu_netsales
                                fu_valtgt
                       CHANGING fc_oppext fc_netsales.

  DATA: ld_persen LIKE s626-ummenge,
        ld_mintgt LIKE zsparameter-mintgt.

*  IF fu_valtgt IS NOT INITIAL.
  IF fu_netsales IS NOT INITIAL.
    CLEAR: i_s626_sum,i_s626_matnr,ld_persen,ld_mintgt,i_zstargetsum.
    READ TABLE i_s626_sum WITH KEY pkunwe = fu_pkunwe
                                   mvgr2  = fu_mvgr2
                          BINARY SEARCH.
    READ TABLE i_s626_matnr WITH KEY pkunwe = fu_pkunwe
                                     mvgr2  = fu_mvgr2
                                     matnr  = fu_matnr
                          BINARY SEARCH.
    READ TABLE i_zstargetsum WITH KEY kunnr = fu_pkunwe
                                      mvgr2  = fu_mvgr2
                             BINARY SEARCH.

** Cek target dibawah minimum target
    READ TABLE lt_parameter INTO wa_zsparameter WITH KEY type = fu_mvgr2+1(1).
    IF i_zstargetsum-zvaltgt LT wa_zsparameter-mintgt.
      i_zstargetsum-zvaltgt = wa_zsparameter-mintgt.
    ENDIF.

    ld_mintgt = i_zstargetsum-zvaltgt * wa_zsparameter-percen_min / 100.  "45% dari target per paket

    IF i_s626_sum-netsales GE ld_mintgt.
      IF i_zstargetsum-zvaltgt IS NOT INITIAL.
        ld_persen = ( i_s626_sum-netsales / i_zstargetsum-zvaltgt ) * 100.
      ENDIF.
      IF ld_persen GE wa_zsparameter-percen_min.   "Lebih dari 45%
        CASE fu_mvgr2.
          WHEN '01'.
            fc_oppext = percen_ext1 * i_s626_matnr-netsales / 100.
          WHEN '02'.
            fc_oppext = percen_ext2 * i_s626_matnr-netsales / 100.
          WHEN '03'.
            fc_oppext = percen_ext3 * i_s626_matnr-netsales / 100.
          WHEN '04'.
            fc_oppext = percen_ext4 * i_s626_matnr-netsales / 100.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDIF.

* jika oppext (wb1) dapat perhitungan wb2 dari field VALPER2
*    IF fc_oppext IS NOT INITIAL." AND
**      gv_strikewb1 IS INITIAL.
*      fc_netsales = fc_netsales - i_s626_matnr-netsales.
*    ENDIF.
  ENDIF.

ENDFORM.                    " F_HITUNG_EXTRAWB

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_S626
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary_s626 .
  DATA : wa_s626 LIKE i_s626,
         ls_cust LIKE LINE OF gt_cust.

  SORT i_mvke BY matnr.
  SORT i_s626 BY matnr.
  SORT i_s626_2 BY matnr.

  LOOP AT i_s626.
    CLEAR ls_cust.
    READ TABLE gt_cust INTO ls_cust WITH KEY kunnr = i_s626-pkunwe.

    CLEAR wa_mvke.
    READ TABLE i_mvke INTO wa_mvke WITH KEY konda = ls_cust-konda
                                            matnr = i_s626-matnr.
    IF gv_strikewb1 IS NOT INITIAL.
      gt_sum-pkunwe    = i_s626-pkunwe.
      gt_sum-mvgr2    = wa_mvke-mvgr2.
      gt_sum-mvgr3    = wa_mvke-mvgr3.
      gt_sum-netsales = i_s626-umkzwi1 + i_s626-gukzwi1.
      gt_sum-qty      = i_s626-ummenge + i_s626-gumenge.

* For paket Blue
      gt_sum_3 = gt_sum.
      COLLECT gt_sum_3. CLEAR gt_sum_3.

      COLLECT gt_sum. CLEAR gt_sum.
    ENDIF.

    wa_s626-pkunwe   = i_s626-pkunwe.
    wa_s626-mvgr2    = wa_mvke-mvgr2.
    wa_s626-netsales = i_s626-umkzwi1 + i_s626-gukzwi1.
    COLLECT wa_s626 INTO i_s626_sum.
    COLLECT wa_s626 INTO i_s626_total.
    CLEAR i_s626_sum.
    i_s626_matnr-pkunwe   = i_s626-pkunwe.
    i_s626_matnr-mvgr2    = wa_mvke-mvgr2.
    i_s626_matnr-matnr    = i_s626-matnr.
    i_s626_matnr-netsales = i_s626-umkzwi1 + i_s626-gukzwi1.
    COLLECT i_s626_matnr. CLEAR i_s626_matnr.
    i_s626-mvgr2    = wa_mvke-mvgr2.
    i_s626-netsales = i_s626-umkzwi1 + i_s626-gukzwi1.
    MODIFY i_s626 TRANSPORTING mvgr2 netsales.
  ENDLOOP.

  IF gv_strikewb1 IS NOT INITIAL.
    LOOP AT i_s626_2.
      CLEAR ls_cust.
      READ TABLE gt_cust INTO ls_cust WITH KEY kunnr = i_s626_2-pkunwe.

      CLEAR wa_mvke.
      READ TABLE i_mvke INTO wa_mvke WITH KEY konda = ls_cust-konda
                                              matnr = i_s626_2-matnr.
      gt_sum_2-pkunwe   = i_s626_2-pkunwe.
      gt_sum_2-mvgr2    = wa_mvke-mvgr2.
      gt_sum_2-mvgr3    = wa_mvke-mvgr3.
      gt_sum_2-netsales = i_s626_2-umkzwi1 + i_s626_2-gukzwi1.
      gt_sum_2-qty      = i_s626_2-ummenge + i_s626_2-gumenge.

* For paket Blue
      gt_sum_3 = gt_sum_2.
      COLLECT gt_sum_3. CLEAR gt_sum_3.

      COLLECT gt_sum_2. CLEAR gt_sum_2.

      wa_s626-pkunwe   = i_s626_2-pkunwe.
      wa_s626-mvgr2    = wa_mvke-mvgr2.
      wa_s626-netsales = i_s626_2-umkzwi1 + i_s626_2-gukzwi1.
      COLLECT wa_s626 INTO i_s626_sum_2.
      COLLECT wa_s626 INTO i_s626_total.
      CLEAR wa_s626.
      i_s626_matnr_2-pkunwe   = i_s626_2-pkunwe.
      i_s626_matnr_2-mvgr2    = wa_mvke-mvgr2.
      i_s626_matnr_2-matnr    = i_s626_2-matnr.
      i_s626_matnr_2-netsales = i_s626_2-umkzwi1 + i_s626_2-gukzwi1.
      COLLECT i_s626_matnr_2. CLEAR i_s626_matnr_2.
      i_s626_2-mvgr2    = wa_mvke-mvgr2.
      i_s626_2-netsales = i_s626_2-umkzwi1 + i_s626_2-gukzwi1.
      MODIFY i_s626_2 TRANSPORTING mvgr2 netsales.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SUMMARY_S626

*&---------------------------------------------------------------------*
*&      Form  F_INIT_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_vkorg .
  SELECT SINGLE parva
    FROM usr05
    INTO p_vkorg
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.
ENDFORM.                    " F_INIT_VKORG

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTH
*&---------------------------------------------------------------------*
FORM f_check_auth .
  AUTHORITY-CHECK OBJECT 'ZCLOSEPKT'
    ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'You are not authorized'.
    STOP.
  ENDIF.

  IF p_spmon EQ sy-datum(6).
    AUTHORITY-CHECK OBJECT 'ZCLOSEPKT'
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc NE 0.
      MESSAGE i000(zab) WITH 'Tidak bisa closing di bulan yang sama'.
      STOP.
    ELSE.
      MESSAGE i000(zab) WITH 'Closing di bulan yang sama'.
      STOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_AUTH

*&---------------------------------------------------------------------*
*&      Form  F_GET_MVGR2
*&---------------------------------------------------------------------*
FORM f_get_mvgr2 .
  DATA : ls_konda LIKE LINE OF r_konda,
         ls_cntrl LIKE LINE OF gt_cntrl.

  SELECT *
    FROM zspaket_control
    INTO TABLE gt_cntrl
    WHERE vkorg EQ p_vkorg
      AND paket EQ p_paket
      AND datab LE sy-datum
      AND datbi GE sy-datum.

  gt_cntrl_dnd[] = gt_cntrl[].
  DELETE gt_cntrl_dnd WHERE field_name NP 'DND*'.      "bulan program drive non drive
  gt_cntrl_jwb[] = gt_cntrl[].
  DELETE gt_cntrl_jwb WHERE field_name NP 'JWB*'.      "jumlah wb setiap paket untuk prog.extra wb
  gt_cntrl_ewb[] = gt_cntrl[].
  DELETE gt_cntrl_ewb WHERE field_name NP 'EWB*'.      "% extra wb sesuai ach & class
  gt_cntrl_pew[] = gt_cntrl[].
  DELETE gt_cntrl_pew WHERE field_name NP 'PEW*'.      "flag proses extra wb
  gt_cntrl_class[] = gt_cntrl[].
  DELETE gt_cntrl_class WHERE field_name NP 'CLASS*'.  "class prog. extra wb
  gt_cntrl_cwb[] = gt_cntrl[].
  DELETE gt_cntrl_cwb WHERE field_name NP 'CWB*'.      "max % WB C di VK (ZC01)
  gt_cntrl_ewm[] = gt_cntrl[].
  DELETE gt_cntrl_ewm WHERE field_name NP 'EWM*'.      "max % WB E di VK (ZE01)
  gt_cntrl_cdn[] = gt_cntrl[].
  DELETE gt_cntrl_cdn WHERE field_name NP 'CDN*'.      "wb in cek program drive non drive

  LOOP AT gt_cntrl WHERE field_name EQ 'MVGR2'.
    r_mvgr2-low    = gt_cntrl-field_value.
    r_mvgr2-sign   = 'I'.
    r_mvgr2-option = 'EQ'.
    APPEND r_mvgr2.
  ENDLOOP.

  LOOP AT gt_cntrl WHERE field_name EQ 'WBOUT'.
    r_rptmvgr2-low    = gt_cntrl-field_value.
    r_rptmvgr2-sign   = 'I'.
    r_rptmvgr2-option = 'EQ'.
    APPEND r_rptmvgr2.
  ENDLOOP.

  LOOP AT gt_cntrl WHERE field_name EQ 'MVGR2REG'.
    r_mvgr2reg-low    = gt_cntrl-field_value.
    r_mvgr2reg-sign   = 'I'.
    r_mvgr2reg-option = 'EQ'.
    APPEND r_mvgr2reg.
  ENDLOOP.

  READ TABLE gt_cntrl WITH KEY vkorg = p_vkorg
                               paket = p_paket
                               field_name = 'KONDA'.
  IF sy-subrc EQ 0.
    p_konda = gt_cntrl-field_value.
  ENDIF.

  LOOP AT gt_cntrl INTO ls_cntrl
                   WHERE vkorg        = p_vkorg
                     AND paket        = p_paket
                     AND field_name   = 'KONDA'
                     AND field_value5 = 'X'.
    ls_konda-low    = ls_cntrl-field_value.
    ls_konda-sign   = 'I'.
    ls_konda-option = 'EQ'.
    APPEND ls_konda TO r_konda.
    CLEAR ls_konda.
  ENDLOOP.

  READ TABLE gt_cntrl WITH KEY vkorg = p_vkorg
                               paket = p_paket
                               field_name = 'SWB'.
  IF sy-subrc EQ 0.
    gv_strikewb1 = gt_cntrl-field_value.
    gv_strikewb2 = gt_cntrl-field_value2.
  ENDIF.

ENDFORM.                    " F_GET_MVGR2

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PRICING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bapi_pricing .
  DATA: lti_bapicondct  LIKE bapicondct OCCURS 0 WITH HEADER LINE,
        lti_bapicondhd  LIKE bapicondhd OCCURS 0 WITH HEADER LINE,
        lti_bapicondit  LIKE bapicondit OCCURS 0 WITH HEADER LINE,
        lti_bapicondqs  LIKE bapicondqs OCCURS 0 WITH HEADER LINE,
        lti_bapicondvs  LIKE bapicondvs OCCURS 0 WITH HEADER LINE,
        lto_bapiret2    LIKE bapiret2   OCCURS 0 WITH HEADER LINE,
        lto_bapiknumhs  LIKE bapiknumhs OCCURS 0 WITH HEADER LINE,
        lto_mem_initial LIKE cnd_mem_initial OCCURS 0 WITH HEADER LINE,
        ld_norut(9)     TYPE n.

  DATA: ld_message(100),
        ld_datum_fr     LIKE sy-datum,
        ld_datum_to     LIKE sy-datum.

  SORT i_vk11 BY pkunwe.
  LOOP AT i_vk11 INTO wa_vk11.
    opnbal = opnbal +  wa_vk11-opnbal.
    pkunwe = wa_vk11-pkunwe.

    AT END OF pkunwe.
      CLEAR: i_bdc, i_messtab, wa_bdc, wa_messtab.
      REFRESH: i_bdc, i_messtab.

      IF opnbal < 0 AND va_live = 'X'.
        ADD 1 TO ld_norut.

*    * Get itab lti_bapicondct
        lti_bapicondct-operation = '009'.
        lti_bapicondct-cond_usage = 'A'.
        lti_bapicondct-table_no = '631'.
        lti_bapicondct-applicatio = 'V'.
        lti_bapicondct-cond_type = 'ZC01'.

        CASE p_paket.
          WHEN 'OPP'.
            CONCATENATE p_vkorg '02' '0' pkunwe INTO lti_bapicondct-varkey.
          WHEN 'PPI'.
            CONCATENATE p_vkorg '02' '1' pkunwe INTO lti_bapicondct-varkey.
          WHEN 'OKM'.
            CONCATENATE p_vkorg '02' '2' pkunwe INTO lti_bapicondct-varkey.
        ENDCASE.

        lti_bapicondct-valid_to = v_date2.
        lti_bapicondct-valid_from = v_date1.
        CONCATENATE '$' ld_norut INTO lti_bapicondct-cond_no.
        APPEND lti_bapicondct. CLEAR lti_bapicondct.

** Get itab lti_bapicondhd
        lti_bapicondhd-operation = '009'.
        CONCATENATE '$' ld_norut INTO lti_bapicondhd-cond_no.
        lti_bapicondhd-created_by = sy-uname.
        CONCATENATE sy-datum(4) sy-datum+4(2) sy-datum+6(2) INTO lti_bapicondhd-creat_date.
        lti_bapicondhd-cond_usage = 'A'.
        lti_bapicondhd-table_no = '631'.
        lti_bapicondhd-applicatio = 'V'.
        lti_bapicondhd-cond_type = 'ZC01'.

        CASE p_paket.
          WHEN 'OPP'.
            CONCATENATE p_vkorg '02' '0' pkunwe INTO lti_bapicondhd-varkey.
          WHEN 'PPI'.
            CONCATENATE p_vkorg '02' '1' pkunwe INTO lti_bapicondhd-varkey.
          WHEN 'OKM'.
            CONCATENATE p_vkorg '02' '2' pkunwe INTO lti_bapicondhd-varkey.
        ENDCASE.

        lti_bapicondhd-valid_to = v_date2.
        lti_bapicondhd-valid_from = v_date1.
        APPEND lti_bapicondhd. CLEAR lti_bapicondhd.

** Get itab lti_bapicondit
        lti_bapicondit-operation = '009'.
        CONCATENATE '$' ld_norut INTO lti_bapicondit-cond_no.
        lti_bapicondit-cond_count = '01'.
        lti_bapicondit-applicatio = 'V'.
        lti_bapicondit-scaletype = 'A'.
        lti_bapicondit-calctypcon = 'A'.
        lti_bapicondit-cond_value = 25 * -1.
        lti_bapicondit-condcurr = '%'.
        lti_bapicondit-condcurren = 'IDR'.
        lti_bapicondit-lowerlimit = 25 * -1.
        lti_bapicondit-maxconval = opnbal * 100.
        lti_bapicondit-cond_type = 'ZC01'.

        APPEND lti_bapicondit. CLEAR lti_bapicondit.

      ENDIF.
      CLEAR: opnbal, pkunwe.
    ENDAT.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
*     EXPORTING
*       PI_INITIALMODE       = ' '
*       PI_BLOCKNUMBER       =
    TABLES
      ti_bapicondct  = lti_bapicondct
      ti_bapicondhd  = lti_bapicondhd
      ti_bapicondit  = lti_bapicondit
      ti_bapicondqs  = lti_bapicondqs
      ti_bapicondvs  = lti_bapicondvs
      to_bapiret2    = lto_bapiret2
      to_bapiknumhs  = lto_bapiknumhs
      to_mem_initial = lto_mem_initial
    EXCEPTIONS
      update_error   = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.                    " F_BAPI_PRICING

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PRICING_ZC01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bapi_pricing_zc01 .
  DATA: lti_bapicondct  LIKE bapicondct OCCURS 0 WITH HEADER LINE,
        lti_bapicondhd  LIKE bapicondhd OCCURS 0 WITH HEADER LINE,
        lti_bapicondit  LIKE bapicondit OCCURS 0 WITH HEADER LINE,
        lti_bapicondqs  LIKE bapicondqs OCCURS 0 WITH HEADER LINE,
        lti_bapicondvs  LIKE bapicondvs OCCURS 0 WITH HEADER LINE,
        lto_bapiret2    LIKE bapiret2   OCCURS 0 WITH HEADER LINE,
        lto_bapiknumhs  LIKE bapiknumhs OCCURS 0 WITH HEADER LINE,
        lto_mem_initial LIKE cnd_mem_initial OCCURS 0 WITH HEADER LINE,
        ld_norut(9)     TYPE n.

  DATA: ld_message(100),
        ld_datum_fr     LIKE sy-datum,
        ld_datum_to     LIKE sy-datum.

  CLEAR gt_cntrl_cwb.
  READ TABLE gt_cntrl_cwb INDEX 1.

  LOOP AT i_vk11.
    CLEAR: i_bdc, i_messtab, wa_bdc, wa_messtab.
    REFRESH: i_bdc, i_messtab.

    IF i_vk11-opnbal < 0 AND va_live = 'X'.
      ADD 1 TO ld_norut.

*    * Get itab lti_bapicondct
      lti_bapicondct-operation = '009'.
      lti_bapicondct-cond_usage = 'A'.
      lti_bapicondct-table_no = '631'.
      lti_bapicondct-applicatio = 'V'.
      lti_bapicondct-cond_type = 'ZC01'.

      CASE p_paket.
        WHEN 'OPP'.
          CONCATENATE p_vkorg '02' '0' i_vk11-pkunwe INTO lti_bapicondct-varkey.
        WHEN 'PPI'.
          CONCATENATE p_vkorg '02' '1' i_vk11-pkunwe INTO lti_bapicondct-varkey.
        WHEN 'OKM'.
          CONCATENATE p_vkorg '02' '2' i_vk11-pkunwe INTO lti_bapicondct-varkey.
      ENDCASE.

      lti_bapicondct-valid_to = v_date2.
      lti_bapicondct-valid_from = v_date1.
      CONCATENATE '$' ld_norut INTO lti_bapicondct-cond_no.
      APPEND lti_bapicondct. CLEAR lti_bapicondct.

** Get itab lti_bapicondhd
      lti_bapicondhd-operation = '009'.
      CONCATENATE '$' ld_norut INTO lti_bapicondhd-cond_no.
      lti_bapicondhd-created_by = sy-uname.
      CONCATENATE sy-datum(4) sy-datum+4(2) sy-datum+6(2) INTO lti_bapicondhd-creat_date.
      lti_bapicondhd-cond_usage = 'A'.
      lti_bapicondhd-table_no = '631'.
      lti_bapicondhd-applicatio = 'V'.
      lti_bapicondhd-cond_type = 'ZC01'.

      CASE p_paket.
        WHEN 'OPP'.
          CONCATENATE p_vkorg '02' '0' i_vk11-pkunwe INTO lti_bapicondhd-varkey.
        WHEN 'PPI'.
          CONCATENATE p_vkorg '02' '1' i_vk11-pkunwe INTO lti_bapicondhd-varkey.
        WHEN 'OKM'.
          CONCATENATE p_vkorg '02' '2' i_vk11-pkunwe INTO lti_bapicondhd-varkey.
      ENDCASE.

      lti_bapicondhd-valid_to = v_date2.
      lti_bapicondhd-valid_from = v_date1.
      APPEND lti_bapicondhd. CLEAR lti_bapicondhd.

** Get itab lti_bapicondit
      lti_bapicondit-operation = '009'.
      CONCATENATE '$' ld_norut INTO lti_bapicondit-cond_no.
      lti_bapicondit-cond_count = '01'.
      lti_bapicondit-applicatio = 'V'.
      lti_bapicondit-scaletype = 'A'.
      lti_bapicondit-calctypcon = 'A'.
*      lti_bapicondit-cond_value = 25 * -1.
      lti_bapicondit-cond_value = gt_cntrl_cwb-field_value * -1.
      lti_bapicondit-condcurr = '%'.
      lti_bapicondit-condcurren = 'IDR'.
*      lti_bapicondit-lowerlimit = 25 * -1.
      lti_bapicondit-lowerlimit = gt_cntrl_cwb-field_value * -1.
      lti_bapicondit-maxconval = i_vk11-opnbal * 100.
      lti_bapicondit-cond_type = 'ZC01'.

      APPEND lti_bapicondit. CLEAR lti_bapicondit.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
*     EXPORTING
*       PI_INITIALMODE       = ' '
*       PI_BLOCKNUMBER       =
    TABLES
      ti_bapicondct  = lti_bapicondct
      ti_bapicondhd  = lti_bapicondhd
      ti_bapicondit  = lti_bapicondit
      ti_bapicondqs  = lti_bapicondqs
      ti_bapicondvs  = lti_bapicondvs
      to_bapiret2    = lto_bapiret2
      to_bapiknumhs  = lto_bapiknumhs
      to_mem_initial = lto_mem_initial
    EXCEPTIONS
      update_error   = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.                    " F_BAPI_PRICING_ZC01

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PRICING_ZE01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bapi_pricing_ze01 .
  DATA: lti_bapicondct  LIKE bapicondct OCCURS 0 WITH HEADER LINE,
        lti_bapicondhd  LIKE bapicondhd OCCURS 0 WITH HEADER LINE,
        lti_bapicondit  LIKE bapicondit OCCURS 0 WITH HEADER LINE,
        lti_bapicondqs  LIKE bapicondqs OCCURS 0 WITH HEADER LINE,
        lti_bapicondvs  LIKE bapicondvs OCCURS 0 WITH HEADER LINE,
        lto_bapiret2    LIKE bapiret2   OCCURS 0 WITH HEADER LINE,
        lto_bapiknumhs  LIKE bapiknumhs OCCURS 0 WITH HEADER LINE,
        lto_mem_initial LIKE cnd_mem_initial OCCURS 0 WITH HEADER LINE,
        ld_norut(9)     TYPE n.

  DATA: ld_message(100),
        ld_datum_fr     LIKE sy-datum,
        ld_datum_to     LIKE sy-datum,
        lw_quarter      TYPE p99sg_quarter.

  CALL FUNCTION 'HR_99S_GET_QUARTER'
    EXPORTING
      im_date    = v_date1
    IMPORTING
      ex_quarter = lw_quarter.
  v_date22 = lw_quarter-endda.

  CLEAR gt_cntrl_ewm.
  READ TABLE gt_cntrl_ewm INDEX 1.

  LOOP AT i_vk113.
    CLEAR: i_bdc, i_messtab, wa_bdc, wa_messtab.
    REFRESH: i_bdc, i_messtab.

    IF i_vk113-opnbal < 0 AND va_live = 'X'.
      ADD 1 TO ld_norut.

*    * Get itab lti_bapicondct
      lti_bapicondct-operation = '009'.
      lti_bapicondct-cond_usage = 'A'.
      lti_bapicondct-table_no = '631'.
      lti_bapicondct-applicatio = 'V'.
      lti_bapicondct-cond_type = 'ZE01'.

      CASE p_paket.
        WHEN 'OPP'.
          CONCATENATE p_vkorg '02' '0' i_vk113-pkunwe INTO lti_bapicondct-varkey.
        WHEN 'PPI'.
          CONCATENATE p_vkorg '02' '1' i_vk113-pkunwe INTO lti_bapicondct-varkey.
        WHEN 'OKM'.
          CONCATENATE p_vkorg '02' '2' i_vk113-pkunwe INTO lti_bapicondct-varkey.
      ENDCASE.

      lti_bapicondct-valid_to = v_date22.
      lti_bapicondct-valid_from = v_date1.
      CONCATENATE '$' ld_norut INTO lti_bapicondct-cond_no.
      APPEND lti_bapicondct. CLEAR lti_bapicondct.

** Get itab lti_bapicondhd
      lti_bapicondhd-operation = '009'.
      CONCATENATE '$' ld_norut INTO lti_bapicondhd-cond_no.
      lti_bapicondhd-created_by = sy-uname.
      CONCATENATE sy-datum(4) sy-datum+4(2) sy-datum+6(2) INTO lti_bapicondhd-creat_date.
      lti_bapicondhd-cond_usage = 'A'.
      lti_bapicondhd-table_no = '631'.
      lti_bapicondhd-applicatio = 'V'.
      lti_bapicondhd-cond_type = 'ZE01'.

      CASE p_paket.
        WHEN 'OPP'.
          CONCATENATE p_vkorg '02' '0' i_vk113-pkunwe INTO lti_bapicondhd-varkey.
        WHEN 'PPI'.
          CONCATENATE p_vkorg '02' '1' i_vk113-pkunwe INTO lti_bapicondhd-varkey.
        WHEN 'OKM'.
          CONCATENATE p_vkorg '02' '2' i_vk113-pkunwe INTO lti_bapicondhd-varkey.
      ENDCASE.

      lti_bapicondhd-valid_to = v_date22.
      lti_bapicondhd-valid_from = v_date1.
      APPEND lti_bapicondhd. CLEAR lti_bapicondhd.

** Get itab lti_bapicondit
      lti_bapicondit-operation = '009'.
      CONCATENATE '$' ld_norut INTO lti_bapicondit-cond_no.
      lti_bapicondit-cond_count = '01'.
      lti_bapicondit-applicatio = 'V'.
      lti_bapicondit-scaletype = 'A'.
      lti_bapicondit-calctypcon = 'A'.
*      lti_bapicondit-cond_value = 25 * -1.
      lti_bapicondit-cond_value = gt_cntrl_ewm-field_value * -1.
      lti_bapicondit-condcurr = '%'.
      lti_bapicondit-condcurren = 'IDR'.
*      lti_bapicondit-lowerlimit = 25 * -1.
      lti_bapicondit-lowerlimit = gt_cntrl_ewm-field_value * -1.
      lti_bapicondit-maxconval = i_vk113-opnbal * 100.
      lti_bapicondit-cond_type = 'ZE01'.

      APPEND lti_bapicondit. CLEAR lti_bapicondit.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
*     EXPORTING
*       PI_INITIALMODE       = ' '
*       PI_BLOCKNUMBER       =
    TABLES
      ti_bapicondct  = lti_bapicondct
      ti_bapicondhd  = lti_bapicondhd
      ti_bapicondit  = lti_bapicondit
      ti_bapicondqs  = lti_bapicondqs
      ti_bapicondvs  = lti_bapicondvs
      to_bapiret2    = lto_bapiret2
      to_bapiknumhs  = lto_bapiknumhs
      to_mem_initial = lto_mem_initial
    EXCEPTIONS
      update_error   = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.                    " F_BAPI_PRICING_ZE01

*&---------------------------------------------------------------------*
*&      Form  F_KEY_ITAB_S700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_key_itab_s700 .
  i_s700key[] = i_s700[].
  SORT i_s700key BY pkunwe matnr vrkme routel kvgr3 prodh1 prodh2 prodh3.
  DELETE ADJACENT DUPLICATES FROM i_s700key
         COMPARING pkunwe matnr vrkme routel kvgr3 prodh1 prodh2 prodh3.
ENDFORM.                    " F_KEY_ITAB_S700

*&---------------------------------------------------------------------*
*&      Form  UPDATE_S700_QUARTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_s700_quarter .
  DATA: ld_date    LIKE sy-datum,
        ld_spmon   LIKE s700-spmon,
        ld_spmon2  LIKE s700-spmon,
        lw_quarter TYPE p99sg_quarter.

  CONCATENATE p_spmon '01' INTO ld_date.
  CALL FUNCTION 'HR_99S_GET_QUARTER'
    EXPORTING
      im_date    = ld_date
    IMPORTING
      ex_quarter = lw_quarter.

  IF sy-subrc = 0.
    CLEAR gt_cntrl_pew.
    READ TABLE gt_cntrl_pew INDEX 1.
    ld_spmon = lw_quarter-begda(6).
    ld_spmon2 = lw_quarter-endda(6).

    IF ld_spmon2 = p_spmon AND gt_cntrl_pew-field_value = '1'.
      SELECT * FROM zstarget_old
      INTO CORRESPONDING FIELDS OF TABLE gt_tgtold_quart
      WHERE vkorg EQ p_vkorg     AND
            vtweg EQ p_vtweg     AND
            gjahr BETWEEN '0000' AND '9999' AND
            spmon BETWEEN ld_spmon AND ld_spmon2   AND
            vkbur EQ p_vstel     AND
            kunnr IN s_kunnr     AND
            mvgr2 IN r_rptmvgr2  AND
            zsts  IN ('A', 'N').

      APPEND LINES OF i_zstarget TO gt_tgtold_quart.

      SELECT *
        FROM s700
        INTO CORRESPONDING FIELDS OF TABLE t_s700_quart
        WHERE ssour  EQ space
          AND vrsio  EQ '000'
          AND spmon  BETWEEN ld_spmon AND ld_spmon2
          AND sptag  EQ '00000000'
          AND spwoc  EQ '000000'
          AND spbup  EQ '000000'
          AND pkunwe IN s_kunnr
          AND vkbur  EQ gv_vstel
          AND mvgr2  IN r_rptmvgr2.

      PERFORM f_summary_itab_quarter.
      PERFORM f_update_extwb_s700 USING ld_spmon ld_spmon2.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_S700_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_ITAB_QUARTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary_itab_quarter .
  DATA: lt_cntrl LIKE gt_cntrl OCCURS 0 WITH HEADER LINE.

  lt_cntrl[] = gt_cntrl[].
  DELETE lt_cntrl WHERE field_name NE 'MVGR2'.
  SORT lt_cntrl BY field_value.

  LOOP AT gt_tgtold_quart.
    gt_tgtold_quart_sum-vkorg = gt_tgtold_quart-vkorg.
    gt_tgtold_quart_sum-vtweg = gt_tgtold_quart-vtweg.
    gt_tgtold_quart_sum-gjahr = gt_tgtold_quart-gjahr.
*    gt_tgtold_quart_sum-spmon = gt_tgtold_quart-spmon.
    gt_tgtold_quart_sum-vkbur = gt_tgtold_quart-vkbur.
    gt_tgtold_quart_sum-kunnr = gt_tgtold_quart-kunnr.
    gt_tgtold_quart_sum-zvaltgt = gt_tgtold_quart-zvaltgt.

* Summaries by type paket "GREEN/BLUE"
    CLEAR lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = gt_tgtold_quart-mvgr2
                        BINARY SEARCH.
    gt_tgtold_quart_sum-mvgr2 = lt_cntrl-field_value3.

    READ TABLE gt_cntrl_dnd WITH KEY field_value = gt_tgtold_quart-spmon+4(2)
                                     field_value2 = gt_tgtold_quart-mvgr2.
    IF sy-subrc NE 0.
      CLEAR: gt_tgtold_quart_sum-zvaltgt.
    ENDIF.
    COLLECT gt_tgtold_quart_sum.
    CLEAR gt_tgtold_quart_sum.
  ENDLOOP.

  LOOP AT t_s700_quart.
*    t_s700_quart_sum-spmon    = t_s700_quart-spmon.
    t_s700_quart_sum-pkunwe   = t_s700_quart-pkunwe.
    t_s700_quart_sum-vkorg    = t_s700_quart-vkorg.
    t_s700_quart_sum-vkbur    = t_s700_quart-vkbur.
    t_s700_quart_sum-netsales = t_s700_quart-netsales.
    t_s700_quart_sum-point    = t_s700_quart-point.

* Summaries by type paket "GREEN/BLUE"
    CLEAR lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = t_s700_quart-mvgr2
                        BINARY SEARCH.
    t_s700_quart_sum-mvgr2 = lt_cntrl-field_value3.

    READ TABLE gt_cntrl_dnd WITH KEY field_value = t_s700_quart-spmon+4(2)
                                     field_value2 = t_s700_quart-mvgr2.
    IF sy-subrc NE 0.
      CLEAR: t_s700_quart_sum-netsales.
    ENDIF.
    COLLECT t_s700_quart_sum.
    CLEAR t_s700_quart_sum.
  ENDLOOP.
ENDFORM.                    " F_SUMMARY_ITAB_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_EXTWB_S700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  fu_spmon      text
*  -->  fu_spmon2     text
*----------------------------------------------------------------------*
FORM f_update_extwb_s700 USING fu_spmon fu_spmon2.
  DATA: lt_s700   LIKE t_s700_quart OCCURS 0 WITH HEADER LINE,
        lt_s703   LIKE s703 OCCURS 0 WITH HEADER LINE,
        lv_persen TYPE zvaltgt.

  DATA: lt_cntrl LIKE gt_cntrl OCCURS 0 WITH HEADER LINE.

  lt_cntrl[] = gt_cntrl[].
  DELETE lt_cntrl WHERE field_name NE 'MVGR2'.
  SORT lt_cntrl BY field_value.

  lt_s700[] = t_s700_quart[].
  DELETE lt_s700 WHERE spmon NE p_spmon.
  SORT lt_s700 BY pkunwe mvgr2 matnr.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.

  LOOP AT lt_s700.
    CLEAR: lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = lt_s700-mvgr2
                        BINARY SEARCH.
    lt_s700-ptype = lt_cntrl-field_value3.
    MODIFY lt_s700 TRANSPORTING ptype.
  ENDLOOP.

  SORT lt_s700 BY pkunwe ptype mvgr2 matnr.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe ptype.

  SORT gt_tgtold_quart_sum BY kunnr mvgr2.
  SORT t_s700_quart_sum BY pkunwe mvgr2.
  SORT gt_cntrl_class BY vkorg paket field_name field_value.
  SORT gt_cntrl_jwb BY vkorg paket field_name field_value.
  SORT gt_cntrl_ewb BY vkorg paket field_name datbi DESCENDING.
  LOOP AT lt_s700.
    CLEAR: gt_tgtold_quart_sum,t_s700_quart_sum,gt_cntrl_class,gt_cntrl_jwb,gt_cntrl_ewb.
    CLEAR: lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = lt_s700-mvgr2
                        BINARY SEARCH.
    READ TABLE gt_tgtold_quart_sum WITH KEY kunnr = lt_s700-pkunwe
                                            mvgr2 = lt_cntrl-field_value3
                                   BINARY SEARCH.
    READ TABLE t_s700_quart_sum WITH KEY pkunwe = lt_s700-pkunwe
                                         mvgr2 = lt_cntrl-field_value3
                                BINARY SEARCH.

    lv_persen = t_s700_quart_sum-netsales / gt_tgtold_quart_sum-zvaltgt * 100.

    CLEAR: gv_pattern,gv_value.
    PERFORM f_get_pattern_paket USING lt_s700-mvgr2
                                CHANGING gv_pattern.
    CONCATENATE c_ewb gv_pattern INTO gv_value.

    LOOP AT gt_cntrl_ewb WHERE field_name = gv_value.
      IF lv_persen GE gt_cntrl_ewb-field_value.
        EXIT.
      ELSE.
        CLEAR gt_cntrl_ewb.
      ENDIF.
    ENDLOOP.

    CLEAR: gv_value.
    CONCATENATE c_class gv_pattern INTO gv_value.

    LOOP AT gt_cntrl_class WHERE field_name = gv_value.
      IF gt_tgtold_quart_sum-zvaltgt GE gt_cntrl_class-field_value2.
        EXIT.
      ELSE.
        CLEAR gt_cntrl_class.
      ENDIF.
    ENDLOOP.

    IF gt_cntrl_ewb IS NOT INITIAL AND gt_cntrl_class IS NOT INITIAL.
      CLEAR: gv_value.
      CONCATENATE c_jwb gv_pattern INTO gv_value.
      READ TABLE gt_cntrl_jwb WITH KEY field_name  = gv_value
                                       field_value = gt_cntrl_class-field_value.
      IF t_s700_quart_sum-point GE gt_cntrl_jwb-field_value2.
        CASE gt_cntrl_class-field_value.
          WHEN '01'.
            lt_s700-extrawb = gt_cntrl_ewb-field_value3 * t_s700_quart_sum-netsales / 100.
          WHEN '02'.
            lt_s700-extrawb = gt_cntrl_ewb-field_value4 * t_s700_quart_sum-netsales / 100.
          WHEN '03'.
            lt_s700-extrawb = gt_cntrl_ewb-field_value5 * t_s700_quart_sum-netsales / 100.
          WHEN OTHERS.
            CLEAR lt_s700-extrawb.
        ENDCASE.
      ELSE.
        CLEAR lt_s700-extrawb.
      ENDIF.
    ELSE.
      CLEAR lt_s700-extrawb.
    ENDIF.
    MODIFY lt_s700 TRANSPORTING extrawb.

    MOVE-CORRESPONDING lt_s700 TO lt_s703.
    lt_s703-zoppin = lt_s700-extrawb.
    APPEND lt_s703.
  ENDLOOP.

* Modify S700
  MODIFY s700 FROM TABLE lt_s700.
  DELETE lt_s700 WHERE extrawb IS INITIAL.

*Modify S703
  PERFORM f_update_s703 TABLES lt_s703
                        USING fu_spmon fu_spmon2.
ENDFORM.                    " F_UPDATE_EXTWB_S700

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_S703
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_S703     text
*      -->fu_spmon    text
*      -->fu_spmon2   text
*----------------------------------------------------------------------*
FORM f_update_s703  TABLES   ft_s703 STRUCTURE s703
                    USING    fu_spmon fu_spmon2.
  DATA: lt_s703    LIKE s703 OCCURS 0 WITH HEADER LINE,
        lt_s703n   LIKE s703 OCCURS 0 WITH HEADER LINE,
        lw_s703n   LIKE s703,
        ld_zopnbal TYPE zendbal_opp.

*  SELECT * INTO TABLE lt_s703
*    FROM s703 WHERE ssour  EQ space AND
*                    vrsio  EQ '000' AND
*                    spmon BETWEEN fu_spmon AND fu_spmon2 AND
*                    sptag  EQ '00000000' AND
*                    spwoc  EQ '000000'   AND
*                    spbup  EQ '000000'   AND
*                    zpaket = 'EWB'       AND
*                    pkunwe IN s_kunnr.
*  IF sy-subrc = 0.
*    SORT ft_s703 BY spmon zpaket pkunwe.
*    SORT lt_s703 BY spmon zpaket pkunwe.
*    LOOP AT lt_s703.
*      IF lt_s703-spmon = p_spmon.
*        READ TABLE ft_s703 WITH KEY pkunwe = lt_s703-pkunwe BINARY SEARCH.
*        IF sy-subrc = 0.
*          lt_s703-zoppin = lt_s703-zoppin + ft_s703-zoppin.
*          lt_s703-zoppend = lt_s703-zopnbal + lt_s703-zoppin + lt_s703-zoppout.
*          lt_s703-zalamat = 'Extra WB OPP'.
*          lt_s703-zpaket = 'EWB'.
*          MODIFY lt_s703 TRANSPORTING zoppin zoppend zalamat zpaket.
*        ELSE.
*          lt_s703-zoppend = lt_s703-zopnbal + lt_s703-zoppin + lt_s703-zoppout.
*          lt_s703-zalamat = 'Extra WB OPP'.
*          lt_s703-zpaket = 'EWB'.
*          MODIFY lt_s703 TRANSPORTING zoppend zalamat zpaket.
*        ENDIF.
*      ELSE.
*        lt_s703-zoppend = lt_s703-zopnbal + lt_s703-zoppin + lt_s703-zoppout.
*        MODIFY lt_s703 TRANSPORTING zoppend.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

  SORT ft_s703 BY spmon zpaket pkunwe.
*  SORT lt_s703 BY spmon zpaket pkunwe.
  LOOP AT ft_s703.
*    READ TABLE lt_s703 WITH KEY spmon = ft_s703-spmon
*                                pkunwe = ft_s703-pkunwe BINARY SEARCH.
*    IF sy-subrc NE 0.
    MOVE-CORRESPONDING ft_s703 TO lt_s703.
*      lt_s703-zoppin = lt_s703-zoppend = ft_s703-zoppin.
    lt_s703-zoppin = ft_s703-zoppin.
    lt_s703-zalamat = 'Extra WB OPP'.
    lt_s703-zpaket = 'EWB'.
    APPEND lt_s703.
*    ENDIF.
  ENDLOOP.

* Collect next month
  SORT lt_s703 BY spmon zpaket pkunwe vbeln matnr vrsio.
  LOOP AT lt_s703.
    MOVE-CORRESPONDING lt_s703 TO lt_s703n.
*    ld_zopnbal = lt_s703n-zoppend.
    ld_zopnbal = lt_s703n-zoppin.
    CLEAR: lt_s703n-zopnbal,lt_s703n-zoppout,lt_s703n-zoppin,lt_s703n-zoppend.
    lt_s703n-spmon = v_spmon.
*    lt_s703n-zopnbal = lt_s703n-zoppend = ld_zopnbal.
    lt_s703n-zopnbal = ld_zopnbal.
    READ TABLE lt_s703n INTO lw_s703n WITH KEY spmon = lt_s703n-spmon
                                              zpaket = lt_s703n-zpaket
                                              pkunwe = lt_s703n-pkunwe.
    IF sy-subrc = 0.
      lt_s703n-matnr = lw_s703n-matnr.
    ENDIF.
    COLLECT lt_s703n.

    i_vk113-pkunwe = lt_s703n-pkunwe.
    i_vk113-opnbal = lt_s703n-zopnbal * -1.
    COLLECT i_vk113.
    CLEAR: lt_s703n,i_vk113,ld_zopnbal.
  ENDLOOP.
*  APPEND LINES OF lt_s703n TO lt_s703.

  LOOP AT lt_s703n.
    IF lt_s703n-zopnbal <= 0.
      DELETE lt_s703n.
    ENDIF.
  ENDLOOP.

*  MODIFY s703 FROM TABLE lt_s703.
  MODIFY s703 FROM TABLE lt_s703n.
ENDFORM.                    " F_UPDATE_S703

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA_SUT1
*&---------------------------------------------------------------------*
FORM proses_data_sut1 .
  DATA: li_s700       TYPE t_s700 OCCURS 0,
        lwa_s700      TYPE t_s700,
        l_ctr         TYPE i,
        l_ctr2        TYPE i,
        l_lines       TYPE i,
        l_count       TYPE i,
        l_toleransi   LIKE wa_s700-opnbal,
        l_achieve(15) TYPE p DECIMALS 5,
        ld_ztgtmin    LIKE zsclassopp-ztgtmin,
        ld_percen     LIKE s626-umkzwi1,
        ld_subrc      TYPE sy-subrc.

  DATA : lt_s700 TYPE t_s700 OCCURS 0,
         ls_s700 TYPE t_s700.

  DATA: BEGIN OF lt_zsclassopp OCCURS 0.
          INCLUDE STRUCTURE zsclassopp.
        DATA: END OF lt_zsclassopp.

  DATA: l_zpersenach LIKE zsclassopp-zpersenach.

  DATA : d_datab LIKE zproject-datab.

  DATA: lv_sales LIKE wa_s700-valper2.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr, l_ctr2, li_s700, lwa_s700, wa_s700.

  SELECT * FROM zsclassopp
    INTO CORRESPONDING FIELDS OF TABLE lt_zsclassopp
    WHERE mvgr2 IN r_mvgr2
      AND class EQ 'A'
      AND ( datab LE ld_date1 OR datab LE ld_date2 )
      AND datbi GE ld_date2.

  LOOP AT i_s700 INTO wa_s700.
* validasi paket drive, wb hanya di paket drive saja
    CLEAR gt_cntrl_cdn.
    READ TABLE gt_cntrl_cdn INDEX 1.
    IF gt_cntrl_cdn-field_value = '1'.
      CLEAR ld_subrc.
      READ TABLE gt_cntrl_dnd WITH KEY field_value  = wa_s700-spmon+4(2)
                                       field_value2 = wa_s700-mvgr2.
      ld_subrc = sy-subrc.
    ENDIF.

    IF ld_subrc IS NOT INITIAL.
      DELETE TABLE i_s700 FROM wa_s700.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE i_s700 LINES l_lines.

  SORT lt_zsclassopp BY mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

  lt_s700[] = i_s700[].
  SORT lt_s700 BY pkunwe mvgr2.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.

  LOOP AT lt_s700 INTO ls_s700.
    CLEAR: l_ctr, l_ctr2.
    CLEAR : ld_ztgtmin, ld_percen.

*cek target < target minimum ?
    READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                      mvgr2 = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      READ TABLE lt_parameter WITH KEY type = ls_s700-mvgr2+1(1).
      IF sy-subrc EQ 0.
        IF i_zstargetsum-zvaltgt LT lt_parameter-mintgt.
          ld_ztgtmin = lt_parameter-mintgt.
        ELSE.
          ld_ztgtmin = i_zstargetsum-zvaltgt.
        ENDIF.
      ENDIF.
    ENDIF.

*baca total sales per customer per paket
    READ TABLE i_s626_total WITH KEY pkunwe = ls_s700-pkunwe
                                     mvgr2  = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      IF ld_ztgtmin IS NOT INITIAL.
        ld_percen  = ( i_s626_total-netsales / ld_ztgtmin ) * 100.
      ENDIF.
    ENDIF.

*proses hitung strike periode1
    LOOP AT gt_sum WHERE pkunwe = ls_s700-pkunwe AND
                         mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum-mvgr2
                                        mvgr3 = gt_sum-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr.
        ENDIF.
      ENDIF.
    ENDLOOP.

*proses hitung strike periode2
    LOOP AT gt_sum_2 WHERE pkunwe = ls_s700-pkunwe AND
                           mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_2-mvgr2
                                        mvgr3 = gt_sum_2-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum_2-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr2.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR : i_s7001, i_s7001[].

    LOOP AT i_s700 INTO wa_s700 WHERE pkunwe = ls_s700-pkunwe
                                  AND mvgr2  = ls_s700-mvgr2.
      ADD 1 TO l_count.

      CLEAR : lt_parameter.
      READ TABLE lt_parameter WITH KEY type = wa_s700-mvgr2+1(1).
      IF sy-subrc EQ 0.
        l_zpersenach = lt_parameter-achive.
      ENDIF.

      IF l_ctr >= lt_parameter-strike.
        IF wa_s700-netsales NE 0.
* proses WB period I
          PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                         wa_s700-mvgr2
                                         wa_s700-matnr
                                         wa_s700-netsales
                                         wa_s700-valtgt
                                   CHANGING wa_s700-oppext
                                            wa_s700-netsales.
        ENDIF.
      ENDIF.

*proses WB period II
      IF l_ctr2 >= lt_parameter-strike AND
        ld_percen >= l_zpersenach.
        IF wa_s700-netsales NE 0.
          IF wa_s700-oppext > 0.
            lv_sales = wa_s700-valper2.
          ELSE.
            lv_sales = wa_s700-netsales.
          ENDIF.

          IF wa_s700-mvgr2 EQ '01'.
            wa_s700-oppin =  persen / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '02'.
            wa_s700-oppin =  persen1 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '03'.
            wa_s700-oppin =  persen2 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '04'.
            wa_s700-oppin =  persen3 / 100 * lv_sales.
          ENDIF.
        ENDIF.
      ENDIF.

*      APPEND LINES OF i_s7001 TO i_s7002.

      APPEND wa_s700 TO i_s7001.
      CLEAR: wa_s700.

*      IF l_count EQ l_lines.
*        APPEND LINES OF i_s7001 TO i_s7002.
*      ENDIF.
    ENDLOOP.

    APPEND LINES OF i_s7001 TO i_s7002.
  ENDLOOP.

*  REFRESH: i_s7001.
*  CLEAR: l_ctr, l_ctr2, lwa_s700, i_s7001.
ENDFORM.                    " PROSES_DATA_SUT1

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA_SUT2
*&---------------------------------------------------------------------*
FORM proses_data_sut2 .
  DATA: li_s700       TYPE t_s700 OCCURS 0,
        lwa_s700      TYPE t_s700,
        l_ctr         TYPE i,
        l_ctr2        TYPE i,
        l_ctr3        TYPE i,
        l_lines       TYPE i,
        l_count       TYPE i,
        l_toleransi   LIKE wa_s700-opnbal,
        l_achieve(15) TYPE p DECIMALS 5,
        ld_ztgtmin    LIKE zsclassopp-ztgtmin,
*        ld_percen   LIKE s626-umkzwi1,
        ld_percen(15) TYPE p DECIMALS 10,
        ld_subrc      TYPE sy-subrc.

  DATA : lt_s700 TYPE t_s700 OCCURS 0,
         ls_s700 TYPE t_s700.

  DATA: BEGIN OF lt_zsclassopp OCCURS 0.
          INCLUDE STRUCTURE zsclassopp.
        DATA: END OF lt_zsclassopp.

  DATA: l_zpersenach LIKE zsclassopp-zpersenach.

  DATA : d_datab LIKE zproject-datab.

  DATA: lv_sales LIKE wa_s700-valper2.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr, l_ctr2, l_ctr3, li_s700, lwa_s700, wa_s700.

  SELECT * FROM zsclassopp
    INTO CORRESPONDING FIELDS OF TABLE lt_zsclassopp
    WHERE mvgr2 IN r_mvgr2
      AND class EQ 'A'
      AND ( datab LE ld_date1 OR datab LE ld_date2 )
      AND datbi GE ld_date2.

  LOOP AT i_s700 INTO wa_s700.
* validasi paket drive, wb hanya di paket drive saja
    CLEAR gt_cntrl_cdn.
    READ TABLE gt_cntrl_cdn INDEX 1.
    IF gt_cntrl_cdn-field_value = '1'.
      CLEAR ld_subrc.
      READ TABLE gt_cntrl_dnd WITH KEY field_value  = wa_s700-spmon+4(2)
                                       field_value2 = wa_s700-mvgr2.
      ld_subrc = sy-subrc.
    ENDIF.

    IF ld_subrc IS NOT INITIAL.
      DELETE TABLE i_s700 FROM wa_s700.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE i_s700 LINES l_lines.

  SORT lt_zsclassopp BY mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

  lt_s700[] = i_s700[].
  SORT lt_s700 BY pkunwe mvgr2.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.

  LOOP AT lt_s700 INTO ls_s700.
    CLEAR: l_ctr, l_ctr2, l_ctr3.
    CLEAR : ld_ztgtmin, ld_percen.

*cek target < target minimum ?
    READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                      mvgr2 = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      READ TABLE lt_parameter WITH KEY type = ls_s700-mvgr2+1(1).
      IF sy-subrc EQ 0.
        IF i_zstargetsum-zvaltgt LT lt_parameter-mintgt.
          ld_ztgtmin = lt_parameter-mintgt.
        ELSE.
          ld_ztgtmin = i_zstargetsum-zvaltgt.
        ENDIF.
      ENDIF.
    ENDIF.

*baca total sales per customer per paket
    READ TABLE i_s626_total WITH KEY pkunwe = ls_s700-pkunwe
                                     mvgr2  = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      IF ld_ztgtmin IS NOT INITIAL.
*        ld_percen  = ( i_s626_total-netsales / ld_ztgtmin ) * 100.
        ld_percen  = i_s626_total-netsales / ld_ztgtmin.
        ld_percen = ld_percen * 100.
      ENDIF.
    ENDIF.

*proses hitung strike periode1
    LOOP AT gt_sum WHERE pkunwe = ls_s700-pkunwe AND
                         mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum-mvgr2
                                        mvgr3 = gt_sum-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr.
        ENDIF.
      ENDIF.
    ENDLOOP.

*proses hitung strike periode2
    LOOP AT gt_sum_2 WHERE pkunwe = ls_s700-pkunwe AND
                           mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_2-mvgr2
                                        mvgr3 = gt_sum_2-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum_2-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr2.
        ENDIF.
      ENDIF.
    ENDLOOP.

*proses hitung strike periode1+2
    LOOP AT gt_sum_3 WHERE pkunwe = ls_s700-pkunwe AND
                           mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_3-mvgr2
                                        mvgr3 = gt_sum_3-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum_3-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr3.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR : i_s7001, i_s7001[].

    LOOP AT i_s700 INTO wa_s700 WHERE pkunwe = ls_s700-pkunwe
                                  AND mvgr2  = ls_s700-mvgr2.
      ADD 1 TO l_count.

      CLEAR gt_cntrl.
      READ TABLE gt_cntrl WITH KEY field_name = 'MVGR2'
                                   field_value = ls_s700-mvgr2.
      IF gt_cntrl-field_value2 = '2'.
        l_ctr2 = l_ctr3.
        CLEAR: l_ctr.
      ENDIF.

      CLEAR : lt_parameter.
      READ TABLE lt_parameter WITH KEY type = wa_s700-mvgr2+1(1).
      IF sy-subrc EQ 0.
        l_zpersenach = lt_parameter-achive.
      ENDIF.

      IF l_ctr >= lt_parameter-strike.
        IF wa_s700-netsales NE 0.
* proses WB period I
          PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                         wa_s700-mvgr2
                                         wa_s700-matnr
                                         wa_s700-netsales
                                         wa_s700-valtgt
                                   CHANGING wa_s700-oppext
                                            wa_s700-netsales.
        ENDIF.
      ENDIF.

*proses WB period II
      IF l_ctr2 >= lt_parameter-strike AND
        ld_percen >= l_zpersenach.
        IF wa_s700-netsales NE 0.
*          IF wa_s700-oppext > 0.
*            lv_sales = wa_s700-valper2.
*          ELSE.
*            lv_sales = wa_s700-netsales.
*          ENDIF.
          IF gt_cntrl-field_value2 = '2'.   "wa_s700-mvgr2 = '05' OR wa_s700-mvgr2 = '06'.
            lv_sales = wa_s700-netsales.
          ELSE.
            IF wa_s700-oppext > 0.
              lv_sales = wa_s700-valper2.
            ELSE.
              lv_sales = wa_s700-netsales.
            ENDIF.
          ENDIF.

          IF wa_s700-mvgr2 EQ '01'.
            wa_s700-oppin =  persen / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '02'.
            wa_s700-oppin =  persen1 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '03'.
            wa_s700-oppin =  persen2 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '04'.
            wa_s700-oppin =  persen3 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '05'.
            wa_s700-oppin =  percen_ext5 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '06'.
            wa_s700-oppin =  percen_ext6 / 100 * lv_sales.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR wa_s700-oppin.
      ENDIF.

*      APPEND LINES OF i_s7001 TO i_s7002.

      APPEND wa_s700 TO i_s7001.
      CLEAR: wa_s700.

*      IF l_count EQ l_lines.
*        APPEND LINES OF i_s7001 TO i_s7002.
*      ENDIF.
    ENDLOOP.

    APPEND LINES OF i_s7001 TO i_s7002.
  ENDLOOP.

*  REFRESH: i_s7001.
*  CLEAR: l_ctr, l_ctr2, lwa_s700, i_s7001.
ENDFORM.                    " PROSES_DATA_SUT2

*&---------------------------------------------------------------------*
*&      Form  F_GET_S626
*&---------------------------------------------------------------------*
FORM f_get_s626  USING    fu_sptag1 fu_sptag2 fu_sptag3 fu_sptag4.
  DATA : lt_s626 LIKE i_s626 OCCURS 0 WITH HEADER LINE,
         lt_temp LIKE i_s626 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_vbrp OCCURS 0,
           vbeln TYPE vbrp-vbeln,
           vgbel TYPE vbrp-vgbel,
         END OF lt_vbrp.
  DATA : BEGIN OF lt_vbrp2 OCCURS 0,
           vbeln TYPE vbrp-vbeln,
           vgbel TYPE vbrp-vgbel,
         END OF lt_vbrp2.
  DATA : BEGIN OF lt_likp OCCURS 0,
           vbeln     TYPE likp-vbeln,
           wadat_ist TYPE likp-wadat_ist,
         END OF lt_likp.
  DATA : lv_vkbur     TYPE s626-vkbur.

  IF p_vstel1 IS NOT INITIAL.
    lv_vkbur = p_vstel1.
  ELSE.
    lv_vkbur = p_vstel.
  ENDIF.

  SELECT sptag vkbur fkart vbeln pkunwe kdgrp kvgr3
         prodh1 matkl matnr umkzwi1 gukzwi1 ummenge gumenge
    INTO CORRESPONDING FIELDS OF TABLE lt_s626
    FROM s626
    WHERE ssour = space
      AND vrsio = '000'
      AND spmon = '000000'
      AND sptag BETWEEN fu_sptag1 AND fu_sptag4
      AND spwoc = '000000'
      AND spbup = '000000'
      AND vkbur = lv_vkbur
      AND pkunwe IN s_kunnr.

  lt_temp[] = lt_s626[].
  SORT lt_temp BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING pkunwe.
  IF lt_temp[] IS NOT INITIAL.
    SELECT kunnr konda
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_cust
      FOR ALL ENTRIES IN lt_temp
      WHERE kunnr = lt_temp-pkunwe.
  ENDIF.

  lt_temp[] = lt_s626[].
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    SELECT vbeln vgbel
      FROM vbrp
      INTO CORRESPONDING FIELDS OF TABLE lt_vbrp
      FOR ALL ENTRIES IN lt_temp
      WHERE vbeln = lt_temp-vbeln.

    SORT lt_vbrp BY vgbel.
    lt_vbrp2[] = lt_vbrp[].
    DELETE ADJACENT DUPLICATES FROM lt_vbrp2 COMPARING vgbel.
    IF lt_vbrp2[] IS NOT INITIAL.
      SELECT vbeln wadat_ist
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN lt_vbrp2
        WHERE vbeln = lt_vbrp2-vgbel.
    ENDIF.
  ENDIF.

  LOOP AT lt_s626.
    READ TABLE lt_vbrp WITH KEY vbeln = lt_s626-vbeln.
    IF sy-subrc = 0.
      READ TABLE lt_likp WITH KEY vbeln = lt_vbrp-vgbel.
      IF sy-subrc = 0.
        IF lt_likp-wadat_ist BETWEEN fu_sptag1 AND fu_sptag2.
          i_s626 = lt_s626.
          APPEND i_s626.
        ELSEIF lt_likp-wadat_ist BETWEEN fu_sptag3 AND fu_sptag4.
          i_s626_2  = lt_s626.
          APPEND i_s626_2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_S626

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAKET_TYPE
*&---------------------------------------------------------------------*
FORM f_get_paket_type .
  SELECT * INTO TABLE gt_paket_type
    FROM zspaket_type
    WHERE vkorg EQ p_vkorg.
ENDFORM.                    " F_GET_PAKET_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_GET_PATTERN_PAKET
*&---------------------------------------------------------------------*
FORM f_get_pattern_paket  USING    fu_mvgr2
                          CHANGING fc_pattern.
  DATA: ls_cntrl LIKE gt_cntrl,
        ls_type  LIKE gt_paket_type.

  READ TABLE gt_cntrl INTO ls_cntrl
                      WITH KEY field_name = 'MVGR2'
                               field_value = fu_mvgr2.
  IF sy-subrc = 0.
    READ TABLE gt_paket_type INTO ls_type
                             WITH KEY vkorg = ls_cntrl-vkorg
                                      ptype = ls_cntrl-field_value3.
    IF sy-subrc = 0.
      fc_pattern = ls_type-field_value.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_PATTERN_PAKET

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA_SUT3
*&---------------------------------------------------------------------*
FORM proses_data_sut3 .

  DATA: li_s700       TYPE t_s700 OCCURS 0,
        lwa_s700      TYPE t_s700,
        l_ctr         TYPE i,
        l_ctr2        TYPE i,
        l_ctr3        TYPE i,
        l_lines       TYPE i,
        l_count       TYPE i,
        l_toleransi   LIKE wa_s700-opnbal,
        l_achieve(15) TYPE p DECIMALS 5,
        ld_ztgtmin    LIKE zsclassopp-ztgtmin,
*        ld_percen   LIKE s626-umkzwi1,
        ld_percen(15) TYPE p DECIMALS 10,
        ld_subrc      TYPE sy-subrc.

  DATA : lt_s700 TYPE t_s700 OCCURS 0,
         ls_s700 TYPE t_s700.

  DATA: BEGIN OF lt_zsclassopp OCCURS 0.
          INCLUDE STRUCTURE zsclassopp.
        DATA: END OF lt_zsclassopp.

  DATA: l_zpersenach LIKE zsclassopp-zpersenach.

  DATA : d_datab LIKE zproject-datab.

  DATA: lv_sales LIKE wa_s700-valper2.

  DATA : lt_zstgt_control TYPE STANDARD TABLE OF zstarget_control,
         lt_cntrl         TYPE STANDARD TABLE OF zstarget_control,
         ls_cntrl         LIKE LINE OF lt_cntrl,
         lv_subrc         TYPE sy-subrc.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr, l_ctr2, l_ctr3, li_s700, lwa_s700, wa_s700.

  SELECT * FROM zsclassopp
    INTO CORRESPONDING FIELDS OF TABLE lt_zsclassopp
    WHERE mvgr2 IN r_mvgr2
      AND class EQ 'A'
      AND ( datab LE ld_date1 OR datab LE ld_date2 )
      AND datbi GE ld_date2.

  LOOP AT i_s700 INTO ls_s700.
    ls_cntrl-kunnr        = ls_s700-pkunwe.
    ls_cntrl-field_value1 = ls_s700-spmon.
    ls_cntrl-field_value2 = ls_s700-mvgr2.
    APPEND ls_cntrl TO lt_cntrl.
    CLEAR ls_cntrl.
  ENDLOOP.
  SORT lt_cntrl BY kunnr field_value1 field_value2.
  DELETE ADJACENT DUPLICATES FROM lt_cntrl
  COMPARING kunnr field_value1 field_value2.

  IF lt_cntrl[] IS NOT INITIAL.
    SELECT * FROM zstarget_control
      INTO CORRESPONDING FIELDS OF TABLE lt_zstgt_control
      FOR ALL ENTRIES IN lt_cntrl
      WHERE vkorg          = p_vkorg
        AND paket          = 'OPP'
        AND field_name     = 'MVGR2'
        AND kunnr          = lt_cntrl-kunnr
        AND field_value1   = lt_cntrl-field_value1
        AND field_value2   = lt_cntrl-field_value2.
  ENDIF.

  LOOP AT i_s700 INTO wa_s700.
* validasi paket drive, wb hanya di paket drive saja
    CLEAR gt_cntrl_cdn.
    READ TABLE gt_cntrl_cdn INDEX 1.
    IF gt_cntrl_cdn-field_value = '1'.
      CLEAR ld_subrc.
      READ TABLE gt_cntrl_dnd WITH KEY field_value  = wa_s700-spmon+4(2)
                                       field_value2 = wa_s700-mvgr2.
      ld_subrc = sy-subrc.
    ENDIF.

    IF ld_subrc IS NOT INITIAL.
      DELETE TABLE i_s700 FROM wa_s700.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE i_s700 LINES l_lines.

  SORT lt_zsclassopp BY mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

  lt_s700[] = i_s700[].
  SORT lt_s700 BY pkunwe mvgr2.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.

  LOOP AT lt_s700 INTO ls_s700.
    CLEAR: l_ctr, l_ctr2, l_ctr3.
    CLEAR : ld_ztgtmin, ld_percen.

    CLEAR : ls_cntrl, lv_subrc.
    READ TABLE lt_zstgt_control INTO ls_cntrl
                                WITH KEY kunnr        = ls_s700-pkunwe
                                         field_value1 = ls_s700-spmon
                                         field_value2 = ls_s700-mvgr2.
    lv_subrc = sy-subrc.

    IF sy-subrc = 0.
*cek target < target minimum ?
      READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                        mvgr2 = ls_s700-mvgr2.
      IF sy-subrc EQ 0.
        READ TABLE lt_parameter WITH KEY type = ls_s700-mvgr2+1(1).
        IF sy-subrc EQ 0.
          READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                            mvgr2 = ls_s700-mvgr2.

          IF i_zstargetsum-zvaltgt LT lt_parameter-mintgt.
            ld_ztgtmin = lt_parameter-mintgt.
          ELSE.
            ld_ztgtmin = i_zstargetsum-zvaltgt.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*baca total sales per customer per paket
    READ TABLE i_s626_total WITH KEY pkunwe = ls_s700-pkunwe
                                     mvgr2  = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      IF ld_ztgtmin IS NOT INITIAL.
*        ld_percen  = ( i_s626_total-netsales / ld_ztgtmin ) * 100.
        ld_percen  = i_s626_total-netsales / ld_ztgtmin.
        ld_percen = ld_percen * 100.
      ENDIF.
    ENDIF.

*proses hitung strike periode1
    LOOP AT gt_sum WHERE pkunwe = ls_s700-pkunwe AND
                         mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum-mvgr2
                                        mvgr3 = gt_sum-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr.
        ENDIF.
      ENDIF.
    ENDLOOP.

*proses hitung strike periode2
    LOOP AT gt_sum_2 WHERE pkunwe = ls_s700-pkunwe AND
                           mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_2-mvgr2
                                        mvgr3 = gt_sum_2-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum_2-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr2.
        ENDIF.
      ENDIF.
    ENDLOOP.

*proses hitung strike periode1+2
    LOOP AT gt_sum_3 WHERE pkunwe = ls_s700-pkunwe AND
                           mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_3-mvgr2
                                        mvgr3 = gt_sum_3-mvgr3
                                        class = 'A'
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_sum_3-qty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr3.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR : i_s7001, i_s7001[].

    LOOP AT i_s700 INTO wa_s700 WHERE pkunwe = ls_s700-pkunwe
                                  AND mvgr2  = ls_s700-mvgr2.
      ADD 1 TO l_count.

      CLEAR gt_cntrl.
      READ TABLE gt_cntrl WITH KEY field_name = 'MVGR2'
                                   field_value = ls_s700-mvgr2.
      IF gt_cntrl-field_value2 = '2'.
        l_ctr2 = l_ctr3.
        CLEAR: l_ctr.
      ENDIF.

      CLEAR : lt_parameter.
      READ TABLE lt_parameter WITH KEY type = wa_s700-mvgr2+1(1).
      IF sy-subrc EQ 0.
        l_zpersenach = lt_parameter-achive.
      ENDIF.

      IF lv_subrc IS INITIAL.
        IF l_ctr >= lt_parameter-strike.
          IF wa_s700-netsales NE 0.
* proses WB period I
            IF p_wbmat IS INITIAL.
              READ TABLE i_s626_sum WITH KEY pkunwe = wa_s700-pkunwe
                                             mvgr2  = wa_s700-mvgr2.
              IF sy-subrc = 0.
                PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                               wa_s700-mvgr2
                                               wa_s700-matnr
                                               wa_s700-netsales
                                               wa_s700-valtgt
                                         CHANGING wa_s700-oppext
                                                  wa_s700-netsales.
              ELSE.
                CLEAR wa_s700-oppext.
              ENDIF.
            ELSE.
              READ TABLE i_s626_matnr WITH KEY pkunwe = wa_s700-pkunwe
                                               mvgr2  = wa_s700-mvgr2
                                               matnr  = wa_s700-matnr.
              IF sy-subrc = 0.
                PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                               wa_s700-mvgr2
                                               wa_s700-matnr
                                               wa_s700-netsales
                                               wa_s700-valtgt
                                         CHANGING wa_s700-oppext
                                                  wa_s700-netsales.
              ELSE.
                CLEAR wa_s700-oppext.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR wa_s700-oppext.
      ENDIF.

*proses WB period II
      IF l_ctr2 >= lt_parameter-strike AND
        ld_percen >= l_zpersenach.
        IF wa_s700-netsales NE 0.
*          IF p_wbmat IS INITIAL.
*            READ TABLE i_s626_matnr_2 WITH KEY pkunwe = wa_s700-pkunwe
*                                               mvgr2  = wa_s700-mvgr2.
*            IF sy-subrc = 0.
*          IF wa_s700-oppext > 0.
*            lv_sales = wa_s700-valper2.
*          ELSE.
*            lv_sales = wa_s700-netsales.
*          ENDIF.
          IF gt_cntrl-field_value2 = '2'.   "wa_s700-mvgr2 = '05' OR wa_s700-mvgr2 = '06'.
            lv_sales = wa_s700-netsales.
          ELSE.
            IF wa_s700-oppext > 0.
              lv_sales = wa_s700-valper2.
            ELSE.
              lv_sales = wa_s700-netsales.
            ENDIF.
          ENDIF.

          IF wa_s700-mvgr2 EQ '01'.
            wa_s700-oppin =  persen / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '02'.
            wa_s700-oppin =  persen1 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '03'.
            wa_s700-oppin =  persen2 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '04'.
            wa_s700-oppin =  persen3 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '05'.
            wa_s700-oppin =  percen_ext5 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '06'.
            wa_s700-oppin =  percen_ext6 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '07'.
            wa_s700-oppin =  percen_ext7 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '08'.
            wa_s700-oppin =  percen_ext8 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '09'.
            wa_s700-oppin =  percen_ext8 / 100 * lv_sales.
          ELSEIF wa_s700-mvgr2 EQ '10'.
            wa_s700-oppin =  percen_ext10 / 100 * lv_sales.
          ENDIF.
*            ELSE.
*              CLEAR wa_s700-oppin.
*            ENDIF.
        ELSE.
          READ TABLE i_s626_sum_2 WITH KEY pkunwe = wa_s700-pkunwe
                                           mvgr2  = wa_s700-mvgr2
                                           matnr  = wa_s700-matnr.
          IF sy-subrc = 0.
*          IF wa_s700-oppext > 0.
*            lv_sales = wa_s700-valper2.
*          ELSE.
*            lv_sales = wa_s700-netsales.
*          ENDIF.
            IF gt_cntrl-field_value2 = '2'.   "wa_s700-mvgr2 = '05' OR wa_s700-mvgr2 = '06'.
              lv_sales = wa_s700-netsales.
            ELSE.
              IF wa_s700-oppext > 0.
                lv_sales = wa_s700-valper2.
              ELSE.
                lv_sales = wa_s700-netsales.
              ENDIF.
            ENDIF.

            IF wa_s700-mvgr2 EQ '01'.
              wa_s700-oppin =  persen / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '02'.
              wa_s700-oppin =  persen1 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '03'.
              wa_s700-oppin =  persen2 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '04'.
              wa_s700-oppin =  persen3 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '05'.
              wa_s700-oppin =  percen_ext5 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '06'.
              wa_s700-oppin =  percen_ext6 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '07'.
              wa_s700-oppin =  percen_ext7 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '08'.
              wa_s700-oppin =  percen_ext8 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '09'.
              wa_s700-oppin =  percen_ext8 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '10'.
              wa_s700-oppin =  percen_ext10 / 100 * lv_sales.
            ENDIF.
          ELSE.
            CLEAR wa_s700-oppin.
          ENDIF.
*          ENDIF.
        ENDIF.
      ELSE.
        CLEAR wa_s700-oppin.
      ENDIF.

*      APPEND LINES OF i_s7001 TO i_s7002.

      APPEND wa_s700 TO i_s7001.
      CLEAR: wa_s700.

*      IF l_count EQ l_lines.
*        APPEND LINES OF i_s7001 TO i_s7002.
*      ENDIF.
    ENDLOOP.

    APPEND LINES OF i_s7001 TO i_s7002.
  ENDLOOP.

*  REFRESH: i_s7001.
*  CLEAR: l_ctr, l_ctr2, lwa_s700, i_s7001.
ENDFORM.                    " PROSES_DATA_SUT3

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
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
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA_SUT4
*&---------------------------------------------------------------------*
FORM proses_data_sut4 .
  DATA : li_s700       TYPE t_s700 OCCURS 0,
         lwa_s700      TYPE t_s700,
         lt_s700       TYPE t_s700 OCCURS 0,
         ls_s700       TYPE t_s700,
         l_ctr         TYPE i,
         l_ctr2        TYPE i,
         l_ctr3        TYPE i,
         l_lines       TYPE i,
         l_count       TYPE i,
         l_toleransi   LIKE wa_s700-opnbal,
         l_achieve(15) TYPE p DECIMALS 5,
         ld_ztgtmin    LIKE zsclassopp-ztgtmin,
         ld_percen(15) TYPE p DECIMALS 10,
         ld_subrc      TYPE sy-subrc,
         lv_append,
         lv_sales      TYPE s700-valper2.

  DATA : lt_zstgt_control TYPE STANDARD TABLE OF zstarget_control,
         lt_zsclsopp20    TYPE STANDARD TABLE OF zsclsopp20,
         ls_kna1          LIKE LINE OF gt_kna1,
         lt_xkna1         TYPE STANDARD TABLE OF ty_kna1,
         lt_cntrl         TYPE STANDARD TABLE OF zstarget_control,
         ls_cntrl         LIKE LINE OF lt_cntrl,
         ls_param         LIKE LINE OF gt_param.

  DATA : ls_gtcp       LIKE LINE OF gt_gtcp,
         ls_mintgt     LIKE LINE OF gt_mintgt,
         ls_zsclsopp20 LIKE LINE OF lt_zsclsopp20.

  DATA : ls_mvgr2slvr LIKE LINE OF gt_mvgr2slvr,
         ls_clspkt    LIKE LINE OF gt_clspkt.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr, l_ctr2, l_ctr3, li_s700, lwa_s700, wa_s700.

  CLEAR : gt_kna1[].
  PERFORM f_get_customer TABLES gt_gtcp gt_clspkt
                         USING '3'.

  SORT gt_kna1 BY vkbur kunnr kdgrp konda.
  lt_xkna1[] = gt_kna1[].
  SORT lt_xkna1 BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_xkna1 COMPARING kdgrp.

  IF lt_xkna1[] IS NOT INITIAL.
    SELECT *
      FROM zsclsopp20
      INTO CORRESPONDING FIELDS OF TABLE lt_zsclsopp20
      FOR ALL ENTRIES IN lt_xkna1
      WHERE vkorg = p_vkorg
        AND mvgr2 IN r_mvgr2
        AND kdgrp = lt_xkna1-kdgrp
        AND class EQ 'A'
        AND ( datab LE ld_date1 OR datab LE ld_date2 )
        AND datbi GE ld_date2.
  ENDIF.

  LOOP AT i_s700 INTO ls_s700.
    ls_cntrl-kunnr        = ls_s700-pkunwe.
    ls_cntrl-field_value1 = ls_s700-spmon.
    ls_cntrl-field_value2 = ls_s700-mvgr2.
    IF ls_s700-mvgr2 = '05' OR
      ls_s700-mvgr2 = '07' OR
      ls_s700-mvgr2 = '09' OR
      ls_s700-mvgr2 = '10'.
      APPEND ls_cntrl TO lt_cntrl.
    ENDIF.

* validasi paket drive, wb hanya di paket drive saja
    CLEAR gt_cntrl_cdn.
    READ TABLE gt_cntrl_cdn INDEX 1.
    IF gt_cntrl_cdn-field_value = '1'.
      CLEAR ld_subrc.
      READ TABLE gt_cntrl_dnd WITH KEY field_value  = ls_s700-spmon+4(2)
                                       field_value2 = ls_s700-mvgr2.
      ld_subrc = sy-subrc.
    ENDIF.

    IF ld_subrc IS NOT INITIAL.
      DELETE TABLE i_s700 FROM ls_s700.
    ENDIF.
    CLEAR ls_cntrl.
  ENDLOOP.

  SORT lt_cntrl BY kunnr field_value1 field_value2.
  DELETE ADJACENT DUPLICATES FROM lt_cntrl
  COMPARING kunnr field_value1 field_value2.

  IF lt_cntrl[] IS NOT INITIAL.
    SELECT * FROM zstarget_control
      INTO CORRESPONDING FIELDS OF TABLE lt_zstgt_control
      FOR ALL ENTRIES IN lt_cntrl
      WHERE vkorg          = p_vkorg
        AND paket          = 'OPP'
        AND field_name     = 'MVGR2'
        AND kunnr          = lt_cntrl-kunnr
        AND field_value1   = lt_cntrl-field_value1
        AND field_value2   = lt_cntrl-field_value2.
  ENDIF.

  DESCRIBE TABLE i_s700 LINES l_lines.

  SORT lt_zsclsopp20 BY vkorg kdgrp mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

  SORT gt_param BY field_value field_value5 field_value2 DESCENDING.

  lt_s700[] = i_s700[].
  SORT lt_s700 BY pkunwe mvgr2.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.

  CLEAR ls_s700.
  LOOP AT lt_s700 INTO ls_s700.

    CLEAR: l_ctr, l_ctr2, l_ctr3.
    CLEAR : ld_ztgtmin, ld_percen.

    CLEAR : ls_cntrl, ld_subrc.
    READ TABLE lt_zstgt_control INTO ls_cntrl
                                WITH KEY kunnr        = ls_s700-pkunwe
                                         field_value1 = ls_s700-spmon
                                         field_value2 = ls_s700-mvgr2.
    ld_subrc = sy-subrc.
    IF ld_subrc <> 0.
      READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                        spmon = ls_s700-spmon
                                        mvgr2 = ls_s700-mvgr2.
      ld_subrc = sy-subrc.
      IF sy-subrc <> 0.
        CLEAR ls_mvgr2slvr.
        READ TABLE gt_mvgr2slvr INTO ls_mvgr2slvr
                                WITH KEY field_value = ls_s700-mvgr2.
        ld_subrc = sy-subrc.
      ENDIF.
    ENDIF.

* cek target < target minimum ?
    IF ld_subrc = 0.
      READ TABLE i_zstargetsum WITH KEY kunnr = ls_s700-pkunwe
                                        mvgr2 = ls_s700-mvgr2.
      IF sy-subrc EQ 0.
        CLEAR ls_gtcp.
        READ TABLE gt_gtcp INTO ls_gtcp
                           WITH KEY field_value2 = ls_s700-kdgrp.
        IF sy-subrc = 0.
          CLEAR ls_mintgt.
          READ TABLE gt_mintgt INTO ls_mintgt
                               WITH KEY field_value  = ls_gtcp-field_value
                                        field_value2 = ls_s700-mvgr2.
          IF sy-subrc = 0.
            IF i_zstargetsum-zvaltgt < ls_mintgt-field_value3.
              ld_ztgtmin  = ls_mintgt-field_value3.
            ELSE.
              ld_ztgtmin = i_zstargetsum-zvaltgt.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*baca total sales per customer per paket
    READ TABLE i_s626_total WITH KEY pkunwe = ls_s700-pkunwe
                                     mvgr2  = ls_s700-mvgr2.
    IF sy-subrc EQ 0.
      IF ld_ztgtmin IS NOT INITIAL.
        ld_percen  = i_s626_total-netsales / ld_ztgtmin.
        ld_percen = ld_percen * 100.
      ENDIF.
    ENDIF.

*proses hitung strike periode1+2
    LOOP AT gt_sum_3 WHERE pkunwe = ls_s700-pkunwe
                       AND mvgr2  = ls_s700-mvgr2.
      READ TABLE lt_zsclsopp20 INTO ls_zsclsopp20
                               WITH KEY vkorg = ls_s700-vkorg
                                        kdgrp = ls_s700-kdgrp
                                        mvgr2 = gt_sum_3-mvgr2
                                        mvgr3 = gt_sum_3-mvgr3
                                        class = 'A'.
      IF sy-subrc EQ 0.
        IF gt_sum_3-qty >= ls_zsclsopp20-minqty.
          ADD 1 TO l_ctr3.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR : i_s7001, i_s7001[].
    LOOP AT i_s700 INTO wa_s700 WHERE pkunwe = ls_s700-pkunwe
                                  AND mvgr2  = ls_s700-mvgr2.

      CLEAR gt_cntrl.
      READ TABLE gt_cntrl WITH KEY field_name  = 'MVGR2'
                                   field_value = wa_s700-mvgr2.
      IF gt_cntrl-field_value4 = '2'.
        l_ctr2 = l_ctr3.
        CLEAR: l_ctr.
      ENDIF.

      CLEAR ls_kna1.
      READ TABLE gt_kna1 INTO ls_kna1
                         WITH KEY kunnr = wa_s700-pkunwe.
      IF sy-subrc = 0.
* Validasi Class Paket
        CLEAR ls_clspkt.
        READ TABLE gt_clspkt INTO ls_clspkt
                             WITH KEY field_value2 = ls_s700-mvgr2
                                      field_value  = ls_gtcp-field_value
                                      field_value3 = ls_kna1-katr10.
        IF sy-subrc = 0.
          CLEAR : ls_param, lv_append.
          LOOP AT gt_param INTO ls_param
                              WHERE field_value  = wa_s700-mvgr2
                                AND field_value5 = ls_kna1-katr10.
* proses WB period II
            IF l_ctr2 >= ls_param-field_value2 AND
              ld_percen >= ls_param-field_value6.

              IF wa_s700-netsales <> 0.
                IF gt_cntrl-field_value4 = '2'.
                  lv_sales = wa_s700-netsales.
                ELSE.
                  IF wa_s700-oppext > 0.
                    lv_sales = wa_s700-valper2.
                  ELSE.
                    lv_sales = wa_s700-netsales.
                  ENDIF.
                ENDIF.

                wa_s700-oppin =  ls_param-field_value3 / 100 * lv_sales.

*              PERFORM f_get_oppin USING wa_s700-mvgr2 lv_sales
*                                        ls_param-field_value5 l_ctr2
*                                  CHANGING wa_s700-oppin.
              ELSE.
****              READ TABLE i_s626_total WITH KEY pkunwe = wa_s700-pkunwe
****                                               mvgr2  = wa_s700-mvgr2.
*****                                               matnr  = wa_s700-matnr.
****              IF sy-subrc = 0.
****                IF gt_cntrl-field_value2 = '2'.
****                  lv_sales = i_s626_total-netsales.
****                ELSE.
****                  IF wa_s700-oppext > 0.
****                    lv_sales = wa_s700-valper2.
****                  ELSE.
****                    lv_sales = i_s626_total-netsales.
****                  ENDIF.
****                ENDIF.
****
****                wa_s700-oppin =  ls_param-field_value3 / 100 * lv_sales.
****
*****                PERFORM f_get_oppin USING wa_s700-mvgr2 lv_sales
*****                                          ls_param-field_value5 l_ctr2
*****                                    CHANGING wa_s700-oppin.
****
****              ELSE.
                CLEAR wa_s700-oppin.
****              ENDIF.
              ENDIF.
              lv_append = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF lv_append IS NOT INITIAL.
          APPEND wa_s700 TO i_s7001.
        ENDIF.
        CLEAR wa_s700.
      ENDIF.
      APPEND LINES OF i_s7001 TO i_s7002.
      CLEAR : i_s7001, i_s7001[].
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " PROSES_DATA_SUT4

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAKET_CONTROL
*&---------------------------------------------------------------------*
FORM f_get_paket_control  TABLES   ft_paket   STRUCTURE zspaket_control
                          USING    fu_fieldname fu_datum fu_4.
  IF fu_datum IS INITIAL AND
    fu_4 IS INITIAL.
    SELECT *
      FROM zspaket_control
      INTO CORRESPONDING FIELDS OF TABLE ft_paket
      WHERE vkorg      = p_vkorg
        AND paket      = 'OPP'
        AND field_name = fu_fieldname
      ORDER BY PRIMARY KEY.
  ELSEIF fu_4 IS NOT INITIAL.
    SELECT *
      FROM zspaket_control
      INTO CORRESPONDING FIELDS OF TABLE ft_paket
      WHERE vkorg        = p_vkorg
        AND paket        = 'OPP'
        AND field_name   = fu_fieldname
        AND field_value4 = fu_4
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_GET_PAKET_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPPIN
*&---------------------------------------------------------------------*
FORM f_get_oppin  USING    fu_mvgr2 fu_sales fu_class fu_cntr
                  CHANGING fc_oppin.

  DATA : ls_param     LIKE LINE OF gt_param,
         ls_mvgr2slvr LIKE LINE OF gt_mvgr2slvr.

  READ TABLE gt_mvgr2slvr INTO ls_mvgr2slvr
                          WITH KEY field_value = fu_mvgr2.
  IF sy-subrc = 0.
    READ TABLE gt_param INTO ls_param
                        WITH KEY field_value  = fu_mvgr2
                                 field_value5 = fu_class.
    IF sy-subrc = 0.
      fc_oppin =  ls_param-field_value3 / 100 * fu_sales.
    ENDIF.
  ELSE.
    READ TABLE gt_param INTO ls_param
                        WITH KEY field_value  = fu_mvgr2.
    IF sy-subrc = 0.
      fc_oppin =  ls_param-field_value3 / 100 * fu_sales.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_OPPIN

*&---------------------------------------------------------------------*
*&      Form  UPDATE_S700_QUARTER1
*&---------------------------------------------------------------------*
FORM update_s700_quarter1 .
  DATA: ld_date    LIKE sy-datum,
        ld_spmon   LIKE s700-spmon,
        ld_spmon2  LIKE s700-spmon,
        lw_quarter TYPE p99sg_quarter.

  CONCATENATE p_spmon '01' INTO ld_date.
  CALL FUNCTION 'HR_99S_GET_QUARTER'
    EXPORTING
      im_date    = ld_date
    IMPORTING
      ex_quarter = lw_quarter.

  IF sy-subrc = 0.
    CLEAR gt_cntrl_pew.
    READ TABLE gt_cntrl_pew INDEX 1.
    ld_spmon = lw_quarter-begda(6).
    ld_spmon2 = lw_quarter-endda(6).

    IF gt_kna1[] IS NOT INITIAL.
      IF ld_spmon2 = p_spmon AND gt_cntrl_pew-field_value = '1'.
        SELECT * FROM zstarget_old
          INTO CORRESPONDING FIELDS OF TABLE gt_tgtold_quart
          FOR ALL ENTRIES IN gt_kna1
          WHERE vkorg EQ p_vkorg
            AND vtweg EQ p_vtweg
            AND gjahr BETWEEN '0000'
            AND '9999'
            AND spmon BETWEEN ld_spmon
            AND ld_spmon2
            AND vkbur EQ p_vstel
            AND kunnr = gt_kna1-kunnr
            AND mvgr2 IN r_mvgr2reg
            AND zsts  IN ('A', 'N').

        APPEND LINES OF i_zstarget TO gt_tgtold_quart.

        SELECT *
          FROM s700
          INTO CORRESPONDING FIELDS OF TABLE t_s700_quart
          FOR ALL ENTRIES IN gt_kna1
          WHERE ssour  EQ space
            AND vrsio  EQ '000'
            AND spmon  BETWEEN ld_spmon AND ld_spmon2
            AND sptag  EQ '00000000'
            AND spwoc  EQ '000000'
            AND spbup  EQ '000000'
            AND pkunwe EQ gt_kna1-kunnr
            AND vkbur  EQ gv_vstel
            AND mvgr2  IN r_mvgr2reg.

        PERFORM f_summary_itab_quarter1.
        PERFORM f_update_extwb_s7001 USING ld_spmon ld_spmon2.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_S700_QUARTER1

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_ITAB_QUARTER1
*&---------------------------------------------------------------------*
FORM f_summary_itab_quarter1 .
  DATA: lt_cntrl LIKE gt_cntrl OCCURS 0 WITH HEADER LINE.
  DATA: lt_s700 TYPE STANDARD TABLE OF s700,
        ls_s700 LIKE LINE OF lt_s700.

  lt_cntrl[] = gt_cntrl[].
  DELETE lt_cntrl WHERE field_name NE 'MVGR2REG'.
  SORT lt_cntrl BY field_value.

  SORT gt_tgtold_quart BY kunnr mvgr2.
  LOOP AT gt_tgtold_quart.
    gt_tgtold_quart_sum-vkorg = gt_tgtold_quart-vkorg.
    gt_tgtold_quart_sum-vtweg = gt_tgtold_quart-vtweg.
    gt_tgtold_quart_sum-gjahr = gt_tgtold_quart-gjahr.
*    gt_tgtold_quart_sum-spmon = gt_tgtold_quart-spmon.
    gt_tgtold_quart_sum-vkbur = gt_tgtold_quart-vkbur.
    gt_tgtold_quart_sum-kunnr = gt_tgtold_quart-kunnr.
    gt_tgtold_quart_sum-zvaltgt = gt_tgtold_quart-zvaltgt.

* Summaries by type paket
    CLEAR lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = gt_tgtold_quart-mvgr2
                        BINARY SEARCH.
    IF sy-subrc = 0.
*      gt_tgtold_quart_sum-mvgr2 = gt_tgtold_quart-mvgr2.
    ELSE.
      CONTINUE.
    ENDIF.

    READ TABLE gt_cntrl_dnd WITH KEY field_value = gt_tgtold_quart-spmon+4(2)
                                     field_value2 = gt_tgtold_quart-mvgr2.
    IF sy-subrc NE 0.
      CLEAR: gt_tgtold_quart_sum-zvaltgt.
    ENDIF.
    COLLECT gt_tgtold_quart_sum.
    CLEAR gt_tgtold_quart_sum.
  ENDLOOP.

  LOOP AT t_s700_quart.
*    t_s700_quart_sum-spmon    = t_s700_quart-spmon.
    t_s700_quart_sum-pkunwe   = t_s700_quart-pkunwe.
    t_s700_quart_sum-vkorg    = t_s700_quart-vkorg.
    t_s700_quart_sum-vkbur    = t_s700_quart-vkbur.
    t_s700_quart_sum-netsales = t_s700_quart-netsales.
    t_s700_quart_sum-point    = t_s700_quart-point.

* Summaries by type paket
    CLEAR lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = t_s700_quart-mvgr2
                        BINARY SEARCH.
    IF sy-subrc = 0.
*      t_s700_quart_sum-mvgr2 = t_s700_quart-mvgr2.
    ELSE.
      CONTINUE.
    ENDIF.

    READ TABLE gt_cntrl_dnd WITH KEY field_value = t_s700_quart-spmon+4(2)
                                     field_value2 = t_s700_quart-mvgr2.
    IF sy-subrc NE 0.
      CLEAR: t_s700_quart_sum-netsales.
    ENDIF.
    COLLECT t_s700_quart_sum.
    CLEAR t_s700_quart_sum.

    ls_s700-vrsio  = '000'.
    ls_s700-spmon  = t_s700_quart-spmon.
    ls_s700-vkbur  = t_s700_quart-vkbur.
    ls_s700-pkunwe = t_s700_quart-pkunwe.
    COLLECT ls_s700 INTO lt_s700.
    CLEAR ls_s700.
  ENDLOOP.

  PERFORM f_clear_extrawb TABLES lt_s700.
ENDFORM.                    " F_SUMMARY_ITAB_QUARTER1

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_EXTWB_S7001
*&---------------------------------------------------------------------*
FORM f_update_extwb_s7001  USING    fu_spmon
                                    fu_spmon2.
  DATA: lt_s700   LIKE t_s700_quart OCCURS 0 WITH HEADER LINE,
        lt_s703   LIKE s703 OCCURS 0 WITH HEADER LINE,
        lv_persen TYPE zvaltgt,
        lv_percen TYPE p DECIMALS 2,
        lv_katr10 TYPE kna1-katr10.

  DATA: lt_cntrl  LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
        ls_clsewb LIKE LINE OF gt_clsewb,
        lv_cltgt  TYPE zstarget-zvaltgt,
        lv_tabix  TYPE sy-tabix.

  lt_cntrl[] = gt_cntrl[].
  DELETE lt_cntrl WHERE field_name NE 'MVGR2REG'.
  SORT lt_cntrl BY field_value.

  lt_s700[] = t_s700_quart[].
  DELETE lt_s700 WHERE spmon NE p_spmon.
  SORT lt_s700 BY pkunwe mvgr2 matnr.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe mvgr2.
  LOOP AT lt_s700.
    READ TABLE gt_cntrl_dnd WITH KEY field_value  = lt_s700-spmon+4(2)
                                     field_value2 = lt_s700-mvgr2.
    IF sy-subrc <> 0.
      DELETE lt_s700.
    ENDIF.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe.

****  LOOP AT lt_s700.
****    CLEAR: lt_cntrl.
****    READ TABLE lt_cntrl WITH KEY field_value = lt_s700-mvgr2
****                        BINARY SEARCH.
****    lt_s700-ptype = lt_cntrl-field_value3.
****    MODIFY lt_s700 TRANSPORTING ptype.
****  ENDLOOP.

****  SORT lt_s700 BY pkunwe ptype mvgr2 matnr.
****  DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING pkunwe ptype.

  SORT gt_tgtold_quart_sum BY kunnr mvgr2.
  SORT t_s700_quart_sum BY pkunwe mvgr2.
  SORT gt_cntrl_class BY vkorg paket field_name field_value.
  SORT gt_cntrl_jwb BY vkorg paket field_name field_value.
  SORT gt_cntrl_ewb BY vkorg paket field_name datbi DESCENDING.
  SORT gt_kna1 BY kunnr.
  LOOP AT lt_s700.
    lv_tabix  = sy-tabix.
    CLEAR: gt_tgtold_quart_sum,t_s700_quart_sum,gt_cntrl_class,gt_cntrl_jwb,gt_cntrl_ewb.
    CLEAR: lt_cntrl.
    READ TABLE lt_cntrl WITH KEY field_value = lt_s700-mvgr2
                        BINARY SEARCH.
    READ TABLE gt_tgtold_quart_sum WITH KEY kunnr = lt_s700-pkunwe    "lt_cntrl-field_value3
                                   BINARY SEARCH.
    READ TABLE t_s700_quart_sum WITH KEY pkunwe = lt_s700-pkunwe       "lt_cntrl-field_value3
                                BINARY SEARCH.

    lv_persen = t_s700_quart_sum-netsales / gt_tgtold_quart_sum-zvaltgt * 100.

    CLEAR : lv_percen, lv_katr10.
    PERFORM f_percen_extrawb USING lt_s700-pkunwe lv_persen
                             CHANGING lv_percen lv_katr10.

*****    CLEAR: gv_pattern,gv_value.
*****    PERFORM f_get_pattern_paket USING lt_s700-mvgr2
*****                                CHANGING gv_pattern.
*****    CONCATENATE c_ewb gv_pattern INTO gv_value.

*****    LOOP AT gt_scaleewb WHERE field_name = gv_value.
*****      IF lv_persen GE gt_cntrl_ewb-field_value.
*****        EXIT.
*****      ELSE.
*****        CLEAR gt_cntrl_ewb.
*****      ENDIF.
*****    ENDLOOP.

    CLEAR lv_cltgt.
    READ TABLE gt_clsewb INTO ls_clsewb
                         WITH KEY field_value4 = lv_katr10.
    IF sy-subrc = 0.
      lv_cltgt  = ls_clsewb-field_value3.
      IF gt_tgtold_quart_sum-zvaltgt < lv_cltgt.
        CONTINUE.
      ENDIF.
      IF t_s700_quart_sum-point < ls_clsewb-field_value5.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF lv_percen <> 0.
      lt_s700-extrawb = ( lv_percen * t_s700_quart_sum-netsales ) / 100.
    ELSE.
      CONTINUE.
    ENDIF.

****    CLEAR: gv_value.
****    CONCATENATE c_class gv_pattern INTO gv_value.
****
****    LOOP AT gt_cntrl_class WHERE field_name = gv_value.
****      IF gt_tgtold_quart_sum-zvaltgt GE gt_cntrl_class-field_value2.
****        EXIT.
****      ELSE.
****        CLEAR gt_cntrl_class.
****      ENDIF.
****    ENDLOOP.

****    IF gt_cntrl_ewb IS NOT INITIAL AND gt_cntrl_class IS NOT INITIAL.
****      CLEAR: gv_value.
****      CONCATENATE c_jwb gv_pattern INTO gv_value.
****      READ TABLE gt_cntrl_jwb WITH KEY field_name  = gv_value
****                                       field_value = gt_cntrl_class-field_value.
****      IF t_s700_quart_sum-point GE gt_cntrl_jwb-field_value2.
****        CASE gt_cntrl_class-field_value.
****          WHEN '01'.
****            lt_s700-extrawb = gt_cntrl_ewb-field_value3 * t_s700_quart_sum-netsales / 100.
****          WHEN '02'.
****            lt_s700-extrawb = gt_cntrl_ewb-field_value4 * t_s700_quart_sum-netsales / 100.
****          WHEN '03'.
****            lt_s700-extrawb = gt_cntrl_ewb-field_value5 * t_s700_quart_sum-netsales / 100.
****          WHEN OTHERS.
****            CLEAR lt_s700-extrawb.
****        ENDCASE.
****      ELSE.
****        CLEAR lt_s700-extrawb.
****      ENDIF.
****    ELSE.
****      CLEAR lt_s700-extrawb.
****    ENDIF.

    MODIFY lt_s700 INDEX lv_tabix TRANSPORTING extrawb.

    MOVE-CORRESPONDING lt_s700 TO lt_s703.
    lt_s703-zoppin = lt_s700-extrawb.
    APPEND lt_s703.
  ENDLOOP.

* Modify S700
  MODIFY s700 FROM TABLE lt_s700.
  DELETE lt_s700 WHERE extrawb IS INITIAL.

*Modify S703
  PERFORM f_update_s703 TABLES lt_s703
                        USING fu_spmon fu_spmon2.
ENDFORM.                    " F_UPDATE_EXTWB_S7001

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer  TABLES   ft_gtcp   STRUCTURE zspaket_control
                              ft_class  STRUCTURE zspaket_control
                     USING    fu_value.

  DATA : lt_kgtcp TYPE STANDARD TABLE OF ty_kna1,
         ls_kgtcp LIKE LINE OF lt_kgtcp,
         ls_gtcp  LIKE LINE OF gt_gtcp,
         ls_class TYPE zspaket_control.

  LOOP AT ft_gtcp INTO ls_gtcp.
    ls_kgtcp-konda  = ls_gtcp-field_value3.
    ls_kgtcp-kdgrp  = ls_gtcp-field_value2.
    LOOP AT ft_class INTO ls_class.
      CASE fu_value.
        WHEN '3'.
          ls_kgtcp-katr10 = ls_class-field_value3.
        WHEN '4'.
          IF ls_class-field_value = ls_gtcp-field_value.
            IF ls_class-field_value2 > '03'.
              CONTINUE.
            ENDIF.
          ENDIF.
          ls_kgtcp-katr10 = ls_class-field_value4.
      ENDCASE.
      APPEND ls_kgtcp TO lt_kgtcp.
    ENDLOOP.
    CLEAR ls_kgtcp.
  ENDLOOP.

  ls_kgtcp-konda  = '09'.
  ls_kgtcp-kdgrp  = '07'.
  ls_kgtcp-katr10 = 'O'.
  APPEND ls_kgtcp TO lt_kgtcp.
  ls_kgtcp-konda  = '09'.
  ls_kgtcp-kdgrp  = '05'.
  ls_kgtcp-katr10 = 'O'.
  APPEND ls_kgtcp TO lt_kgtcp.

  SORT lt_kgtcp BY kdgrp konda katr10.
  DELETE ADJACENT DUPLICATES FROM lt_kgtcp COMPARING kdgrp konda katr10.

  IF lt_kgtcp[] IS NOT INITIAL.
    SELECT kna1~kunnr kna1~name1 kna1~katr2 kna1~katr3 kna1~katr4
           kna1~katr5 kna1~katr6 kna1~katr10 kna1~ktokd
           knvv~kdgrp knvv~konda knvv~vkbur knvv~kvgr3
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 JOIN knvv ON kna1~kunnr EQ knvv~kunnr
      FOR ALL ENTRIES IN lt_kgtcp
      WHERE kna1~kunnr IN s_kunnr
        AND kna1~ktokd IN ('ZC04', 'ZSU1')
        AND kna1~katr10 = lt_kgtcp-katr10
        AND knvv~vkorg = p_vkorg
        AND knvv~vtweg = '10'
        AND knvv~spart = '00'
        AND knvv~vkbur = p_vstel
        AND knvv~kdgrp = lt_kgtcp-kdgrp
        AND knvv~konda = lt_kgtcp-konda.
  ENDIF.
ENDFORM.                    " F_GET_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN_EXTRAWB
*&---------------------------------------------------------------------*
FORM f_percen_extrawb  USING    fu_kunnr fu_achieve
                       CHANGING fc_percen fc_katr10.
  DATA : lv_flag,
         ls_scalewb  LIKE LINE OF gt_scaleewb,
         ls_kna1     LIKE LINE OF gt_kna1,
         ls_zstarget TYPE t_zstarget.

  READ TABLE i_zstarget INTO ls_zstarget
                        WITH KEY kunnr = fu_kunnr.
  IF sy-subrc = 0.
    fc_katr10 = ls_zstarget-class.
  ENDIF.

  CLEAR : lv_flag, fc_percen, ls_kna1.
  READ TABLE gt_kna1 INTO ls_kna1 WITH KEY kunnr = fu_kunnr.

  LOOP AT gt_scaleewb INTO ls_scalewb WHERE field_value = ls_kna1-katr10.
    IF lv_flag IS INITIAL.
      lv_flag = 'X'.
      IF fu_achieve >= ls_scalewb-field_value3.
        fc_percen = ls_scalewb-field_value5.
        IF fc_katr10 IS INITIAL.
          fc_katr10 = ls_kna1-katr10.
        ENDIF.
        EXIT.
      ENDIF.
    ELSE.
      IF ls_scalewb-field_value4 IS INITIAL.
        IF fu_achieve < ls_scalewb-field_value4.
          fc_percen = ls_scalewb-field_value5.
          IF fc_katr10 IS INITIAL.
            fc_katr10 = ls_kna1-katr10.
          ENDIF.
          EXIT.
        ENDIF.
      ELSE.
        IF fu_achieve >= ls_scalewb-field_value3 AND
          fu_achieve < ls_scalewb-field_value4.
          fc_percen = ls_scalewb-field_value5.
          IF fc_katr10 IS INITIAL.
            fc_katr10 = ls_kna1-katr10.
          ENDIF.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PERCEN_EXTRAWB

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_EXTRAWB
*&---------------------------------------------------------------------*
FORM f_clear_extrawb  TABLES   ft_s700 STRUCTURE s700.
  DATA : ls_s700    TYPE s700.
  LOOP AT ft_s700 INTO ls_s700.
    UPDATE s700 SET extrawb  = ls_s700-extrawb
                WHERE vrsio  = ls_s700-vrsio
                  AND spmon  = ls_s700-spmon
                  AND vkbur  = ls_s700-vkbur
                  AND pkunwe = ls_s700-pkunwe.
  ENDLOOP.

  LOOP AT t_s700_quart.
    READ TABLE gt_cntrl_dnd WITH KEY field_value  = t_s700_quart-spmon+4(2)
                                     field_value2 = t_s700_quart-mvgr2.
    IF sy-subrc = 0.
      CLEAR: t_s700_quart-extrawb.
      MODIFY t_s700_quart TRANSPORTING extrawb.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CLEAR_EXTRAWB

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_STRIKE
*&---------------------------------------------------------------------*
FORM f_modify_strike .
  DATA : ls_sum      LIKE gt_sum.
  DATA : lt_xsum LIKE gt_sum OCCURS 0 WITH HEADER LINE,
         ls_xsum LIKE LINE OF lt_xsum,
         lt_ysum LIKE gt_sum OCCURS 0 WITH HEADER LINE,
         ls_ysum LIKE LINE OF lt_ysum,
         ls_kna1 LIKE LINE OF gt_kna1,
         ls_s700 TYPE t_s700.
  DATA : lv_subrc    TYPE sy-subrc.

  lt_ysum[] = gt_sum_3[].
  SORT lt_ysum BY pkunwe mvgr2.
  DELETE ADJACENT DUPLICATES FROM lt_ysum COMPARING pkunwe mvgr2.
  lt_xsum[] = lt_ysum[].
  SORT lt_xsum BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM lt_xsum COMPARING pkunwe.

  LOOP AT lt_xsum INTO ls_xsum.
    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_xsum-pkunwe.
    IF sy-subrc = 0.
      IF ls_kna1-konda  = '05'.
        LOOP AT lt_ysum INTO ls_ysum WHERE pkunwe = ls_kna1-kunnr.
          IF ls_ysum-mvgr2 = '01' OR
            ls_ysum-mvgr2 = '02' OR
            ls_ysum-mvgr2 = '03' OR
            ls_ysum-mvgr2 = '04'.
            lv_subrc = 4.
            LOOP AT gt_sum_3 INTO ls_sum WHERE pkunwe = ls_ysum-pkunwe
                                           AND mvgr2  = ls_ysum-mvgr2.
              IF ls_sum-mvgr3 = '09' OR
                ls_sum-mvgr3 = '10' OR
                ls_sum-mvgr3 = '11'.
                CLEAR lv_subrc.
              ENDIF.
            ENDLOOP.

            IF lv_subrc IS NOT INITIAL.
              CLEAR : ls_sum-qty, ls_sum-netsales.
              MODIFY gt_sum_3 FROM ls_sum
                              TRANSPORTING qty netsales
                              WHERE pkunwe = ls_ysum-pkunwe
                                AND mvgr2  = ls_ysum-mvgr2.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT i_s7002 INTO ls_s700.
    CLEAR ls_sum.
    READ TABLE gt_sum_3 INTO ls_sum
                        WITH KEY pkunwe = ls_s700-pkunwe
                                 mvgr2  = ls_s700-mvgr2
                                 mvgr3  = ls_s700-mvgr3.
    IF sy-subrc = 0.
      IF ls_sum-qty IS INITIAL.
        CLEAR : ls_s700-oppin.
        MODIFY i_s7002 FROM ls_s700 TRANSPORTING oppin.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_STRIKE
