*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  CLEAR: gr_vkbur,gr_vkbur[].
  gr_vkbur-sign = 'I'.
  gr_vkbur-option = 'EQ'.
  gr_vkbur-low = gt_tvbur-vkbur.
  APPEND gr_vkbur.

  CLEAR: wa_header,va_gjahr,va_month.

  CONCATENATE pa_spmon '01' INTO va_datef.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = va_datef
    IMPORTING
      last_day_of_month = va_datet.

  IF radio2 IS NOT INITIAL OR
    radio3 IS NOT INITIAL.
    SELECT tplst exti1 tknum
      INTO TABLE i_listbox
      FROM vttk
      WHERE tplst IN gr_vkbur AND
            erdat BETWEEN va_datef AND va_datet.
    SORT i_listbox BY tplst exti1.
    DELETE ADJACENT DUPLICATES FROM i_listbox COMPARING tplst exti1.
  ENDIF.

  IF pa_vkorg = '8020'.
    pa_lfart  = 'LF'.
  ELSEIF pa_vkorg = '8070'.
    pa_lfart  = 'YF'.
  ENDIF.

  CLEAR: ship_pnt,ship_pnt[].
  ship_pnt-low     = gt_tvbur-vkbur.
  ship_pnt-sign    = 'I'.
  ship_pnt-option  = 'EQ'.
  APPEND ship_pnt.

  CLEAR: ra_date,ra_date[].
  ra_date-low     = va_datef.
  ra_date-high    = va_datet.
  ra_date-sign    = 'I'.
  ra_date-option  = 'BT'.
  APPEND ra_date.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: ld_datet LIKE va_datet,
        lt_likp  LIKE t_likp OCCURS 0 WITH HEADER LINE.

  va_gjahr = pa_spmon(4).
  va_month = pa_spmon+4(2).

  SELECT vkbur bezei INTO TABLE gt_tvkbt
    FROM tvkbt WHERE spras = sy-langu AND
                     vkbur IN gr_vkbur.

  SELECT vstel city1 INTO TABLE i_tvst
    FROM tvst INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
    WHERE vstel IN gr_vkbur.

  SELECT kschl vkbur zdelvp katr1 INTO TABLE gt_rayon
    FROM a777 WHERE kappl = 'V'
                AND kschl = 'ZIWD'
                AND vkorg = pa_vkorg
                AND vkbur IN gr_vkbur
                AND datab LE va_datef
                AND datbi GE va_datet.

  CASE 'X'.
    WHEN radio1.
** Get Target Sales
      SELECT spmon vkorg gjahr vkbur m01 m02 m03 m04 m05 m06 m07 m08 m09 m10 m11 m12
        FROM s629
        INTO CORRESPONDING FIELDS OF TABLE t_s629
        WHERE spmon = '000000'
          AND vkorg IN sales_org
          AND gjahr = va_gjahr
          AND vkbur IN ship_pnt
          AND vrsio = 'TGO'
          AND kvgr2 <> 'TRD'.

*** Get Actual Sales
**  perform ini untuk get MCSI S603 old version
*      PERFORM f_get_s603.

**  perform ini untuk request baru by ESU
**  untuk perhitungan actual sales ER kosmetik
**  refer email 99210002842
      IF act = 'X'.
** Get Target Sales
        SELECT spmon vkorg gjahr vkbur m01 m02 m03 m04 m05 m06 m07 m08 m09 m10 m11 m12
          INTO CORRESPONDING FIELDS OF TABLE t_s629_act
          FROM s629
          WHERE spmon = '000000'
            AND vkorg IN sales_org
            AND gjahr = va_gjahr
            AND vkbur IN ship_pnt
            AND vrsio = 'ACT'
            AND kvgr2 <> 'TRD'.
      ELSE.
        PERFORM f_get_s603_new.
      ENDIF.

    WHEN radio2 OR radio3.
      SELECT a~kappl a~kschl vkorg vkbur ztype katr1 kdgrp kvgr3
             zdaywk zdelvp zminach zminp zdiffach zdiffp datbi
             datab a~knumh kbetr
        INTO CORRESPONDING FIELDS OF TABLE t_a777
        FROM a777 AS a JOIN konp AS b ON a~knumh = b~knumh
        WHERE vkorg = pa_vkorg AND
              vkbur IN gr_vkbur AND
              loevm_ko = space AND
              datab LE va_datef AND
              datbi GE va_datet.

      SELECT a~kappl a~kschl vkorg vkbur ztype katr1 kdgrp kvgr3
             zdaywk zdelvp zminach zminp zdiffach zdiffp datbi
             datab a~knumh kbetr
        APPENDING CORRESPONDING FIELDS OF TABLE t_a777
        FROM a777 AS a JOIN konp AS b ON a~knumh = b~knumh
        WHERE vkorg = pa_vkorg AND
              vkbur = space    AND
*              ztype IN ('IK1','IK2','IK3','IO1','IO2','IO3',
*                        'IS1','IS2','IS3') AND
              ztype IN ra_ztype AND
              loevm_ko = space AND
              datab LE va_datef AND
              datbi GE va_datet.

      SELECT a~kappl a~kschl vkorg vkbur ztype katr1 kdgrp kvgr3
             zdaywk zdelvp zminach zminp zdiffach zdiffp datbi
             datab a~knumh kbetr
        APPENDING CORRESPONDING FIELDS OF TABLE t_a777
        FROM a777 AS a JOIN konp AS b ON a~knumh = b~knumh
        WHERE vkorg = pa_vkorg AND
              a~kschl IN ('ZIDP','ZIDT') AND
              loevm_ko = space AND
              datab LE va_datef AND
              datbi GE va_datet.

      SELECT a~kappl a~kschl vkorg vkbur ztype katr1 kdgrp kvgr3
             zdaywk zdelvp zminach zminp zdiffach zdiffp datbi
             datab a~knumh kbetr
        APPENDING CORRESPONDING FIELDS OF TABLE t_a777
        FROM a777 AS a JOIN konp AS b ON a~knumh = b~knumh
        WHERE vkorg = pa_vkorg AND
              ztype IN ('DL1','DL2','DL3') AND
              loevm_ko = space AND
              datab LE va_datef AND
              datbi GE va_datet.

** Get end date of next month
      ld_datet = va_datet + 1.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ld_datet
        IMPORTING
          last_day_of_month = ld_datet.

** Get Holiday
      CALL FUNCTION 'HOLIDAY_GET'
        EXPORTING
          holiday_calendar           = 'T1'
          factory_calendar           = 'T1'
          date_from                  = va_datef
          date_to                    = ld_datet
        TABLES
          holidays                   = t_holiday
        EXCEPTIONS
          factory_calendar_not_found = 1
          holiday_calendar_not_found = 2
          date_has_invalid_format    = 3
          date_inconsistency         = 4
          OTHERS                     = 5.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

** Get Delivery
      IF i_listbox[] IS NOT INITIAL.
        SELECT tknum vbtyp shtyp tplst erdat exti1 add03 datbg
          INTO CORRESPONDING FIELDS OF TABLE t_vttk
          FROM vttk
          FOR ALL ENTRIES IN i_listbox
          WHERE tplst IN gr_vkbur AND
                erdat BETWEEN va_datef AND va_datet AND
                exti1 = i_listbox-exti1.
        IF t_vttk[] IS NOT INITIAL.
          SELECT *
            FROM zmshphist
            INTO CORRESPONDING FIELDS OF TABLE gt_zmshphist
            FOR ALL ENTRIES IN t_vttk
            WHERE tknum  = t_vttk-tknum.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_vttpori
            FROM vttp
            FOR ALL ENTRIES IN t_vttk
            WHERE tknum = t_vttk-tknum.
          IF t_vttpori[] IS NOT INITIAL.
            SELECT vbeln kunnr
              INTO CORRESPONDING FIELDS OF TABLE t_likp
              FROM likp
              FOR ALL ENTRIES IN t_vttpori
              WHERE vbeln = t_vttpori-vbeln.
            IF sy-subrc = 0.
              lt_likp[] = t_likp[].
              SORT lt_likp BY kunnr.
              DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
              IF lt_likp[] IS NOT INITIAL.
                SELECT a~kunnr name1 katr1 kdgrp kvgr3
                  INTO CORRESPONDING FIELDS OF TABLE t_kna1
                  FROM kna1 AS a JOIN knvv AS b ON b~kunnr = a~kunnr
                  FOR ALL ENTRIES IN lt_likp
                  WHERE a~kunnr = lt_likp-kunnr AND
*                        vkorg = pa_vkorg       AND
                        vkorg IN ('8020','8070') AND
                        vtweg = '10'           AND
                        spart = '00'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio1.
      SORT gt_detail BY spmon vkbur norut.
      LOOP AT gt_detail.
        WRITE:/ gt_detail-spmon,
                gt_detail-vkbur,
                gt_detail-norut,
                gt_detail-types,
                gt_detail-target,
                gt_detail-actual,
                gt_detail-persen.
        AT END OF vkbur.
          WRITE:/ sy-uline.
        ENDAT.
      ENDLOOP.

    WHEN radio2 OR radio3.
      PERFORM f_alv TABLES gt_report.
  ENDCASE.
ENDFORM.                    "f_print_data

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  REFRESH: t_itab,t_detail,t_report,gt_detail,gt_report.
  CLEAR: t_itab,t_detail,t_report,gt_detail,gt_report.
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  CASE 'X'.
    WHEN radio1.
      SORT t_s629 BY vkbur.
      SORT gt_tvkbt BY vkbur.
      LOOP AT gt_tvkbt.
        PERFORM f_hitung_target_actual_sales.
        PERFORM f_get_a511.
        PERFORM f_delivery_level.
      ENDLOOP.

    WHEN radio2.
      SORT gt_tvkbt BY vkbur.
      LOOP AT gt_tvkbt.
        LOOP AT i_listbox WHERE tplst = gt_tvkbt-vkbur.
          PERFORM f_delete_vttp_by_kunnr.
          PERFORM f_hitung_target.
          PERFORM f_hitung_aktual.
          PERFORM f_hitung_ft.
          PERFORM f_hitung_total.
*          PERFORM f_new_delivery_man.
        ENDLOOP.
      ENDLOOP.

    WHEN radio3.
      SORT gt_tvkbt BY vkbur.
      LOOP AT gt_tvkbt.
        LOOP AT i_listbox WHERE tplst = gt_tvkbt-vkbur.
          PERFORM f_delete_vttp_by_kunnr.
          PERFORM f_hitung_target.
          PERFORM f_hitung_aktual.
          PERFORM f_hitung_ft.
          PERFORM f_hitung_total.
*          PERFORM f_new_delivery_man.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_DELIVERY_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delivery_level .
  DATA: lt_a777   LIKE t_a777 OCCURS 0 WITH HEADER LINE,
        ld_target LIKE wa_outpl3-target.

  DATA: i_objectid       TYPE t_objectid OCCURS 0,
        wa_objectid      TYPE t_objectid,
        l_dataset1(70),
        ld_day           LIKE a511-zday4,
        ld_dlk           LIKE wa_outpl3-dlk,
        ld_kdgrp         LIKE a511-kdgrp,
        ld_bzirk         LIKE a511-zday1,
        ld_hari          TYPE p DECIMALS 2,
        ld_hari1         TYPE p DECIMALS 2,
        ld_hari2         TYPE p DECIMALS 2,
        ld_total         TYPE p DECIMALS 2,
        ld_total1        TYPE p DECIMALS 2,
        ld_total2        TYPE p DECIMALS 2,
        ld_avr           TYPE p DECIMALS 2,
        ld_avr1          TYPE p DECIMALS 2,
        ld_avrcp         TYPE p DECIMALS 2,
        ld_avrtrm        TYPE p DECIMALS 2,
        ld_avrmvr        TYPE p DECIMALS 2,
        ld_avrdktrm      TYPE p DECIMALS 2,
        ld_avrdkcp       TYPE p DECIMALS 2,
        ld_avrdkmvr      TYPE p DECIMALS 2,
        ld_avrlktrm      TYPE p DECIMALS 2,
        ld_avrlkcp       TYPE p DECIMALS 2,
        ld_avrlkmvr      TYPE p DECIMALS 2,
        ld_cp            TYPE i,
        ld_trm           TYPE i,
        ld_mvr           TYPE i,
        ld_avrttl        TYPE i,
        ld_pk_create_dt  LIKE a511-zday3,
        ld_gi_create_dt  LIKE a511-zday2,
        ld_gi_vs_pk_dt   LIKE a511-zday4,
        ld_spgd_vs_gi_dt LIKE a511-zday5,
        ld_cr_vs_spgd_dt LIKE a511-zday6,
        ld_do_vs_spgd_dt LIKE a511-zday6,
        ld_cr_vs_do_dt   LIKE a511-zday6,
        ld_vkbur         LIKE a511-vkbur,
        ld_datab         LIKE a511-datab,
        ld_datbi         LIKE a511-datbi,
        ld_lgort         LIKE lips-lgort,
        i1               TYPE i,
        ld_ort01         LIKE kna1-name4,
        ld_flag          TYPE i.

  CLEAR: va_delv,va_whs,va_dlp.

  DELETE ADJACENT DUPLICATES FROM ship_pnt COMPARING ALL FIELDS.

  LOOP AT ship_pnt.
    PERFORM f_dataset USING pa_path ship_pnt-low pa_spmon 'SD' '' ''.
  ENDLOOP.

  PERFORM f_kdgrp04.

* Untuk data hari ini jangan dimasukkan karena akan dibaca lagi
  PERFORM f_delete_today_transaction.

  PERFORM f_get_sales_district.

  IF i_vbeln[] IS NOT INITIAL.
    PERFORM f_get_do USING ''.
  ENDIF.

* Cek apakah ada data hari ini yang akan ditampilkan
  IF pa_spmon = sy-datum(6).
    PERFORM f_get_do USING 'X'.
  ENDIF.

  IF united IS NOT INITIAL.
    PERFORM f_modify_united TABLES i_result.
    PERFORM f_modify_united TABLES i_result2.
  ENDIF.

*----------------------------------------------------------------------*
* Proses cleansing data from database
*----------------------------------------------------------------------*
* Kalau pakai left join, harus delete data berikut ini
  PERFORM f_cleansing_data.

  PERFORM f_move_data USING ''.

  PERFORM f_change_document.

  PERFORM f_field_modify.

  PERFORM f_get_spgd.

  PERFORM f_process_data_from_db.

  IF slk IS INITIAL.
    ld_flag = 0.
  ELSE.
    ld_flag = 1.
  ENDIF.

  PERFORM f_sales_district USING ld_flag.

  PERFORM f_detail_slk USING ld_flag 'SD' 'X' '' ''.
  PERFORM f_detail_slk USING ld_flag 'SD' '' 'X' ''.
  PERFORM f_detail_slk USING ld_flag 'SD' '' '' 'X'.

  SORT i_result BY vbeln.

  va_avr  = 1.

  LOOP AT i_result INTO wa_result.

    CLEAR : wa_outpl3.

    wa_outpl3-vstel = wa_result-vstel.
    wa_outpl3-kdgrp = wa_result-kdgrp.
    wa_outpl3-dlk = wa_result-dlk.
    wa_outpl3-bzirk = wa_result-bzirk.

    CASE wa_outpl3-kdgrp.
      WHEN '04' OR '05' OR '07' OR '10' OR '11'.
        wa_outpl3-type = 'GT'.
      WHEN '03'.
        IF wa_result-kvgr3 = '031' OR wa_result-kvgr3 = '034'.
          wa_outpl3-ktext = 'SM Key account'.
        ENDIF.
        wa_outpl3-type = 'MT'.
      WHEN '02' OR '06' OR '08' OR '09'.
        wa_outpl3-type = 'Corp. Pharma'.
    ENDCASE.

* Collect Warehouse&Delv perf. level
    PERFORM f_day_collect_level USING 'DLV' wa_result-cr_create_dt
                                CHANGING wa_outpl3.

* Collect Whs perf. level
    PERFORM f_day_collect_level USING 'WHS' wa_result-do_vs_spgd_dt
                                CHANGING wa_outpl3.

*  Collect Delv perf. level
    PERFORM f_day_collect_level USING 'DLP' wa_result-cr_vs_spgd_dt
                                CHANGING wa_outpl3.

    wa_result-ktext = wa_outpl3-ktext.
    wa_result-type = wa_outpl3-type.
    MODIFY i_result FROM wa_result TRANSPORTING ktext type.
  ENDLOOP.

  CLEAR: wa_outpl3, ld_day.
  SORT i_outpl3 BY text type.
  LOOP AT i_outpl3 INTO wa_outpl3.
    PERFORM f_hitung_average USING wa_outpl3 '1' ''.

    READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                zday1 = wa_outpl3-bzirk.
    IF sy-subrc EQ 0.
      ld_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
    ELSE.
      READ TABLE t_a511 WITH KEY vkorg = pa_vkorg
                                 vkbur = wa_outpl3-vstel
                                 katr1 = wa_outpl3-dlk
                                 kdgrp = wa_outpl3-kdgrp.
      IF sy-subrc EQ 0.
        ld_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
      ELSE.
        READ TABLE t_a511x WITH KEY vkorg = pa_vkorg
                                    vkbur = space
                                    katr1 = wa_outpl3-dlk
                                    kdgrp = wa_outpl3-kdgrp.
        IF sy-subrc EQ 0.
          ld_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
        ELSE.
          CLEAR: ld_day.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE wa_outpl3-dlk.
      WHEN 'DK'.
        CASE wa_outpl3-type.
          WHEN 'Corp. Pharma'.
            PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                           wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari '' ''
                                           wa_outpl3-total wa_outpl3-shtyp
                                     CHANGING wa_outpl3-std.
          WHEN 'GT'.
            PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                           wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari '' ''
                                           wa_outpl3-total wa_outpl3-shtyp
                                     CHANGING wa_outpl3-std.
          WHEN 'MT'.
            PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                           wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari '' ''
                                           wa_outpl3-total wa_outpl3-shtyp
                                     CHANGING wa_outpl3-std.
        ENDCASE.
      WHEN 'LK'.
        PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                       wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari '' ''
                                       wa_outpl3-total wa_outpl3-shtyp
                                 CHANGING wa_outpl3-std.
    ENDCASE.

    MODIFY i_outpl3 FROM wa_outpl3.
  ENDLOOP.

  IF slk IS NOT INITIAL.
    PERFORM f_average_khusus USING ld_day 'X'.
  ENDIF.

  SORT i_outpl3 BY vstel text type dlk.
  LOOP AT i_outpl3 INTO wa_outpl3.

    ld_dlk = wa_outpl3-dlk.
    ld_kdgrp = wa_outpl3-kdgrp.
    ld_bzirk = wa_outpl3-bzirk.

    READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                zday1 = wa_outpl3-bzirk.
    IF sy-subrc EQ 0.
      CASE wa_outpl3-text.
        WHEN 'WHS'.
          wa_outpl3-target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
        WHEN 'DLP'.
          wa_outpl3-target  = t_a511y-zday6.
        WHEN 'DLV'.
          wa_outpl3-target  = t_a511y-zday5 + t_a511y-zday6.
      ENDCASE.
    ELSE.
      READ TABLE t_a511 WITH KEY vkorg = pa_vkorg
                                 vkbur = wa_outpl3-vstel
                                 katr1 = wa_outpl3-dlk
                                 kdgrp = wa_outpl3-kdgrp.
      IF sy-subrc EQ 0.
        CASE wa_outpl3-text.
          WHEN 'WHS'.
            wa_outpl3-target  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5.
          WHEN 'DLP'.
            wa_outpl3-target  = t_a511-zday6.
          WHEN 'DLV'.
            IF wa_outpl3-dlk = 'DK'.
              wa_outpl3-target  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
            ELSEIF wa_outpl3-dlk = 'LK'.
              wa_outpl3-target  = t_a511-zday5 + t_a511-zday6.
            ENDIF.
        ENDCASE.
      ELSE.
        READ TABLE t_a511x WITH KEY vkorg = pa_vkorg
                                    vkbur = space
                                    katr1 = wa_outpl3-dlk
                                    kdgrp = wa_outpl3-kdgrp.
        IF sy-subrc EQ 0.
          CASE wa_outpl3-text.
            WHEN 'WHS'.
              wa_outpl3-target  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5.
            WHEN 'DLP'.
              wa_outpl3-target  = t_a511x-zday6.
            WHEN 'DLV'.
              IF wa_outpl3-dlk = 'DK'.
                wa_outpl3-target  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
              ELSEIF wa_outpl3-dlk = 'LK'.
                wa_outpl3-target  = t_a511x-zday5 + t_a511x-zday6.
              ENDIF.
          ENDCASE.
        ELSE.
          CLEAR: wa_outpl3-target.
        ENDIF.
      ENDIF.
    ENDIF.

    IF wa_outpl3-bzirk IS NOT INITIAL.
      READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                  zday1 = wa_outpl3-bzirk.
      IF sy-subrc EQ 0.
        ld_target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
      ENDIF.
    ENDIF.

    READ TABLE t_avr WITH KEY text = wa_outpl3-text
                              type = wa_outpl3-type
                              dlk  = wa_outpl3-dlk.
    IF sy-subrc EQ 0.
      PERFORM f_hitung_average USING wa_outpl3 '2' sy-tabix.
    ENDIF.

    CASE ld_dlk.
      WHEN 'DK'.
        CASE wa_outpl3-type.
          WHEN 'Corp. Pharma'.
            ADD wa_outpl3-std TO ld_avrdkcp.
            ADD 1 TO ld_cp.
          WHEN 'GT'.
            ADD wa_outpl3-std TO ld_avrdktrm.
            ADD 1 TO ld_trm.
          WHEN 'MT'.
            ADD wa_outpl3-std TO ld_avrdkmvr.
            ADD 1 TO ld_mvr.
        ENDCASE.

      WHEN 'LK'.
        CASE wa_outpl3-type.
          WHEN 'Corp. Pharma'.
            ADD wa_outpl3-std TO ld_avrlkcp.
            ADD 1 TO ld_cp.
          WHEN 'GT'.
            ADD wa_outpl3-std TO ld_avrlktrm.
            ADD 1 TO ld_trm.
          WHEN 'MT'.
            ADD wa_outpl3-std TO ld_avrlkmvr.
            ADD 1 TO ld_mvr.
        ENDCASE.
    ENDCASE.

    AT END OF dlk.
      READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                  zday1 = wa_outpl3-bzirk.
      IF sy-subrc EQ 0.
        ld_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
      ELSE.
        READ TABLE t_a511 WITH KEY vkorg = pa_vkorg
                                   vkbur = wa_outpl3-vstel
                                   katr1 = ld_dlk
                                   kdgrp = ld_kdgrp.
        IF sy-subrc EQ 0.
          ld_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
        ELSE.
          READ TABLE t_a511x WITH KEY vkorg = pa_vkorg
                                      vkbur = space
                                      katr1 = ld_dlk
                                      kdgrp = ld_kdgrp.
          IF sy-subrc EQ 0.
            ld_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
          ELSE.
            CLEAR: ld_day.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDAT.
  ENDLOOP.

  IF slk IS NOT INITIAL.
    SORT i_outpl6 BY bzirk type.
*    PERFORM f_dynamic_day.
    PERFORM f_get_days.
    LOOP AT i_outpl6 INTO wa_outpl6.
      va_avr  = 2.
      READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                  zday1 = wa_outpl6-bzirk.
      IF sy-subrc EQ 0.
        CASE wa_outpl6-text.
          WHEN 'WHS'.
            wa_outpl6-target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
          WHEN 'DLP'.
            wa_outpl6-target  = t_a511y-zday6.
          WHEN 'DLV'.
            wa_outpl6-target  = t_a511y-zday5 + t_a511y-zday6.
*          WHEN OTHERS.
*            wa_outpl6-target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
        ENDCASE.
      ELSE.
        wa_outpl6-target = gv_day01.
      ENDIF.

      READ TABLE t_avr WITH KEY text = wa_outpl6-text
                                type = wa_outpl6-type
                                dlk  = wa_outpl6-dlk.
      IF sy-subrc EQ 0.
        PERFORM f_hitung_average_khusus USING wa_outpl6 va_avr sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CLEAR: ld_avr,ld_avr1,ld_hari,ld_hari1,ld_hari2,
         ld_total,ld_total1,ld_total2.
  LOOP AT t_avr WHERE type IS NOT INITIAL AND
                      dlk  IS NOT INITIAL.
    CASE t_avr-text.
      WHEN 'DLV'.
        ld_hari = ld_hari + t_avr-hari.
        ld_total = ld_total + t_avr-total.
      WHEN 'DLP'.
        ld_hari2 = ld_hari2 + t_avr-hari.
        ld_total2 = ld_total2 + t_avr-total.
      WHEN 'WHS'.
        ld_hari1 = ld_hari1 + t_avr-hari.
        ld_total1 = ld_total1 + t_avr-total.
      WHEN OTHERS.
    ENDCASE.

    AT LAST.
*      ld_avr = ld_hari / ld_total * 100.
*      ld_avr1 = ld_hari1 / ld_total1 * 100.
      va_delv = ld_hari / ld_total * 100.
      va_whs = ld_hari1 / ld_total1 * 100.
      va_dlp = ld_hari2 / ld_total2 * 100.
    ENDAT.
  ENDLOOP.

** Append itab detail
  CLEAR: t_detail.
  t_detail-norut = '20'.
  t_detail-types = 'Warehouse Performance'. " Warehouse Level
  t_detail-vkbur = gt_tvkbt-vkbur.
  t_detail-spmon = pa_spmon.
  t_detail-target = ld_total1.
  t_detail-actual = ld_hari1.
  t_detail-persen = va_whs.
  APPEND t_detail. CLEAR: t_detail.

  CLEAR: t_detail.
  t_detail-norut = '25'.
  t_detail-types = 'W&D Performance'. " Delivery Level
  t_detail-vkbur = gt_tvkbt-vkbur.
  t_detail-spmon = pa_spmon.
  t_detail-target = ld_total.
  t_detail-actual = ld_hari.
  t_detail-persen = va_delv.
  APPEND t_detail. CLEAR: t_detail.

  CLEAR: t_detail.
  t_detail-norut = '26'.
  t_detail-types = 'Delivery Performance'.
  t_detail-vkbur = gt_tvkbt-vkbur.
  t_detail-spmon = pa_spmon.
  t_detail-target = ld_total2.
  t_detail-actual = ld_hari2.
  t_detail-persen = va_dlp.
  APPEND t_detail. CLEAR: t_detail.

ENDFORM.                    " F_DELIVERY_LEVEL

*&---------------------------------------------------------------------*
*&      Form  F_GET_A511
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_a511x .
  DATA: BEGIN OF lt_konp OCCURS 0.
          INCLUDE STRUCTURE konp.
        DATA: END OF lt_konp.

  SELECT kappl kschl vkorg vkbur katr1 kdgrp
         zday3 zday4 zday5 zday6 datbi datab
         knumh
    FROM a511
    INTO CORRESPONDING FIELDS OF TABLE t_a511
    WHERE kappl EQ 'V' AND
          kschl EQ 'ZDLV' AND
          katr1 NE space  AND
          kdgrp NE space.

  SELECT kappl kschl vkorg vkbur katr1 kdgrp zday1
         zday3 zday4 zday5 zday6 datbi datab
         knumh
    FROM a511
    APPENDING CORRESPONDING FIELDS OF TABLE t_a511
    WHERE kappl EQ 'V'      AND
          kschl EQ 'ZDLV'   AND
          zday1 NE space.

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
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_A511

*&---------------------------------------------------------------------*
*&      Form  F_GET_PERCENTAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUTPL4  text
*      -->P_LD_DAY  text
*      <--P_WA_OUTPL4_STD  text
*----------------------------------------------------------------------*
FORM f_get_percentagex  USING    fu_day fu_0hari fu_1hari fu_2hari fu_3hari fu_4hari fu_total
                       CHANGING fc_std.
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
ENDFORM.                    " F_GET_PERCENTAGE

*&---------------------------------------------------------------------*
*&      Form  F_DK_LK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_dk_lk  USING    fu_datab fu_datbi fu_erdat fu_kodat fu_vstel fu_vkbur fu_pk_create_dt
                       fu_gi_vs_pk_dt fu_spgd_vs_gi_dt fu_cr_vs_spgd_dt fu_do_vs_spgd_dt
                       fu_gi_create_dt fu_cr_vs_do_dt
              CHANGING fc_result_pkdo fc_result_gipk fc_result_spgdgi fc_result_crspgd
                       fc_result_dospgd fc_result_gido fc_result_crdo.

  RANGES: lr_datum FOR a511-datab.

  lr_datum-low    = fu_datab.
  lr_datum-high   = fu_datbi.
  lr_datum-sign   = 'I'.
  lr_datum-option = 'BT'.
  APPEND lr_datum.

  IF fu_datab IS INITIAL AND
    fu_datbi IS INITIAL.
    CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd, fc_result_gido.
  ELSE.
    IF fu_erdat IN lr_datum.
      IF fu_kodat IN lr_datum.
        IF wa_result-pk_create_dt <= fu_pk_create_dt.
          fc_result_pkdo = '1'.
        ENDIF.
      ELSE.
        CLEAR: fc_result_pkdo.
      ENDIF.

      IF wa_result-gi_create_dt <= fu_gi_create_dt.
        fc_result_gido = '1'.
      ENDIF.

      IF wa_result-gi_vs_pk_dt <= fu_gi_vs_pk_dt AND
        wa_result-wadat_ist NE '00000000' AND
        wa_result-kodat NE '00000000'.
        fc_result_gipk = '1'.
      ENDIF.

      IF wa_result-spgd_vs_gi_dt <= fu_spgd_vs_gi_dt.
        fc_result_spgdgi = '1'.
      ENDIF.

      IF wa_result-cr_vs_spgd_dt <= fu_cr_vs_spgd_dt.
        fc_result_crspgd = '1'.
      ENDIF.
    ELSE.
      CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd,
             fc_result_gido.
    ENDIF.
  ENDIF.

  IF fu_vstel IS NOT INITIAL.
    IF fu_vkbur IS NOT INITIAL.
      IF fu_vstel NE fu_vkbur.
        CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd,
               fc_result_gido.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DK_LK

*&---------------------------------------------------------------------*
*&      Form  f_get_holiday
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_DATETO    text
*      -->FU_DATEFR    text
*      <--FC_DAY       text
*----------------------------------------------------------------------*
FORM f_get_holiday  USING    fu_dateto
                             fu_datefr
                    CHANGING fc_day.

  DATA: BEGIN OF lt_holidays OCCURS 0.
          INCLUDE STRUCTURE iscal_day.
        DATA: END OF lt_holidays.
  DATA: ld_day(004) TYPE p  DECIMALS 00.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      holiday_calendar           = 'T1'
      factory_calendar           = 'T1'
      date_from                  = fu_datefr
      date_to                    = fu_dateto
    TABLES
      holidays                   = lt_holidays
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    DESCRIBE TABLE lt_holidays LINES ld_day.
    fc_day = fc_day - ld_day.
  ENDIF.

ENDFORM.                    " f_get_holiday

*&---------------------------------------------------------------------*
*&      Form  F_GET_LISTBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_listbox .
  REFRESH: i_listbox. CLEAR: i_listbox.

  CONCATENATE pa_spmon '01' INTO va_datef.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = va_datef
    IMPORTING
      last_day_of_month = va_datet.

*  SELECT DISTINCT exti1
  SELECT tknum tplst exti1
    INTO TABLE i_listbox
    FROM vttk
    WHERE tplst IN gr_vkbur AND
          erdat BETWEEN va_datef AND va_datet.

  SORT i_listbox BY tplst exti1.
  DELETE ADJACENT DUPLICATES FROM i_listbox COMPARING tplst exti1.
ENDFORM.                    " F_GET_LISTBOX

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE4
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING fu_title.
*--- output line
  PERFORM f_hdr_pad_title USING '' fu_title ''.

ENDFORM.                    " F_HDR_LINE3

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TARGET_ACTUAL_SALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_target_actual_sales .
  CLEAR: t_detail.

  LOOP AT t_s629." WHERE vkbur = gt_tvkbt-vkbur.
    CASE va_month.
      WHEN '01'.
        ADD t_s629-m01 TO t_detail-target.
      WHEN '02'.
        ADD t_s629-m02 TO t_detail-target.
      WHEN '03'.
        ADD t_s629-m03 TO t_detail-target.
      WHEN '04'.
        ADD t_s629-m04 TO t_detail-target.
      WHEN '05'.
        ADD t_s629-m05 TO t_detail-target.
      WHEN '06'.
        ADD t_s629-m06 TO t_detail-target.
      WHEN '07'.
        ADD t_s629-m07 TO t_detail-target.
      WHEN '08'.
        ADD t_s629-m08 TO t_detail-target.
      WHEN '09'.
        ADD t_s629-m09 TO t_detail-target.
      WHEN '10'.
        ADD t_s629-m10 TO t_detail-target.
      WHEN '11'.
        ADD t_s629-m11 TO t_detail-target.
      WHEN '12'.
        ADD t_s629-m12 TO t_detail-target.
    ENDCASE.
  ENDLOOP.

  IF act = 'X'.
    LOOP AT t_s629_act." WHERE vkbur = gt_tvkbt-vkbur.
      CASE va_month.
        WHEN '01'.
          ADD t_s629_act-m01 TO t_detail-actual.
        WHEN '02'.
          ADD t_s629_act-m02 TO t_detail-actual.
        WHEN '03'.
          ADD t_s629_act-m03 TO t_detail-actual.
        WHEN '04'.
          ADD t_s629_act-m04 TO t_detail-actual.
        WHEN '05'.
          ADD t_s629_act-m05 TO t_detail-actual.
        WHEN '06'.
          ADD t_s629_act-m06 TO t_detail-actual.
        WHEN '07'.
          ADD t_s629_act-m07 TO t_detail-actual.
        WHEN '08'.
          ADD t_s629_act-m08 TO t_detail-actual.
        WHEN '09'.
          ADD t_s629_act-m09 TO t_detail-actual.
        WHEN '10'.
          ADD t_s629_act-m10 TO t_detail-actual.
        WHEN '11'.
          ADD t_s629_act-m11 TO t_detail-actual.
        WHEN '12'.
          ADD t_s629_act-m12 TO t_detail-actual.
      ENDCASE.
    ENDLOOP.
  ELSE.
    LOOP AT t_s603." WHERE vkbur = gt_tvkbt-vkbur.
*    ADD t_s603-zxx TO t_detail-actual.
      t_s603-zqnetsls = t_s603-umkzwi1 + t_s603-gukzwi1.
      ADD t_s603-zqnetsls TO t_detail-actual.
      CLEAR t_s603.
    ENDLOOP.
  ENDIF.

  t_detail-target = t_detail-target * 100.
  t_detail-actual = t_detail-actual * 100.

  IF t_detail-target IS INITIAL.
    t_detail-persen = 0.
  ELSE.
    t_detail-persen = t_detail-actual / t_detail-target * 100.
  ENDIF.

  t_detail-norut = '10'.
  t_detail-types = 'Incentive Sales (Rp)'.
  t_detail-vkbur = gt_tvkbt-vkbur.
  t_detail-spmon = pa_spmon.
  APPEND t_detail. CLEAR: t_detail.
ENDFORM.                    " F_HITUNG_TARGET_ACTUAL_SALES

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_DELIVERY_KDGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_A777_KATR1  text
*      -->P_LT_A777_KDGRP  text
*----------------------------------------------------------------------*
FORM f_hitung_delivery_kdgrp USING p_lt_a777_katr1
                                   p_lt_a777_kdgrp.
  DATA: ld_day(2)    TYPE n,
        ld_date      LIKE sy-datum,
*        ld_zdelvp LIKE t_a777-zdelvp.
        ld_zdelvp(3).

  WHILE ld_day LT va_datet+6(2).
    ld_day = ld_day + 1.
    CLEAR: t_holiday,ld_date,ld_zdelvp.
    CONCATENATE pa_spmon ld_day INTO ld_date.
    READ TABLE t_holiday WITH KEY date = ld_date.
    IF sy-subrc = 0.
      ld_zdelvp = 'X'.
    ELSE.
      LOOP AT t_vttk WHERE erdat = ld_date AND
                           tplst = gt_tvkbt-vkbur AND
                           exti1 = i_listbox-exti1.
        CLEAR: t_vttp,t_likp,t_kna1,t_a777.
        LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
          READ TABLE t_likp WITH KEY vbeln = t_vttp-vbeln.
          IF sy-subrc = 0.
*            IF p_lt_a777_katr1 = 'LK' AND p_lt_a777_kdgrp NE '03'.
*              READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
*                                         katr1 = p_lt_a777_katr1.
*              IF sy-subrc = 0.
*                READ TABLE t_a777 WITH KEY kschl = 'ZIDP'
*                                           katr1 = t_kna1-katr1.
*                IF sy-subrc = 0.
*                  ld_zdelvp = ld_zdelvp + t_a777-zdelvp.
*                ENDIF.
*              ENDIF.
*            ELSE.
            READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
                                       katr1 = p_lt_a777_katr1
                                       kdgrp = p_lt_a777_kdgrp.
            IF sy-subrc = 0.
              READ TABLE t_a777 WITH KEY kschl = 'ZIDP'
                                         katr1 = t_kna1-katr1
                                         kdgrp = t_kna1-kdgrp.
              IF sy-subrc = 0.
                ld_zdelvp = ld_zdelvp + t_a777-zdelvp.
              ENDIF.
            ENDIF.
*            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    PERFORM f_jumlah_pertanggal USING ld_day
                                      ld_zdelvp.
  ENDWHILE.
ENDFORM.                    " F_HITUNG_DELIVERY_KDGRP

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_DELIVERY_KVGR3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_A777_KATR1  text
*      -->P_LT_A777_KVGR3  text
*----------------------------------------------------------------------*
FORM f_hitung_delivery_kvgr3 USING p_lt_a777_katr1
                                   p_lt_a777_kvgr3.
  DATA: ld_day(2)    TYPE n,
        ld_date      LIKE sy-datum,
*        ld_zdelvp LIKE t_a777-zdelvp.
        ld_zdelvp(3).

  WHILE ld_day LT va_datet+6(2).
    ld_day = ld_day + 1.
    CLEAR: t_holiday,ld_date,ld_zdelvp.
    CONCATENATE pa_spmon ld_day INTO ld_date.
    READ TABLE t_holiday WITH KEY date = ld_date.
    IF sy-subrc = 0.
      ld_zdelvp = 'X'.
    ELSE.
      LOOP AT t_vttk WHERE erdat = ld_date AND
                           tplst = gt_tvkbt-vkbur AND
                           exti1 = i_listbox-exti1.
        CLEAR: t_vttp,t_likp,t_kna1,t_a777.
        LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
          READ TABLE t_likp WITH KEY vbeln = t_vttp-vbeln.
          IF sy-subrc = 0.
*            IF p_lt_a777_katr1 = 'LK' AND p_lt_a777_kvgr3(2) NE '03'.
*              READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
*                                         katr1 = p_lt_a777_katr1.
*              IF sy-subrc = 0.
*                READ TABLE t_a777 WITH KEY kschl = 'ZIDP'
*                                           katr1 = t_kna1-katr1.
*                IF sy-subrc = 0.
*                  ld_zdelvp = ld_zdelvp + t_a777-zdelvp.
*                ENDIF.
*              ENDIF.
*            ELSE.
            READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
                                       katr1 = p_lt_a777_katr1
                                       kvgr3 = p_lt_a777_kvgr3.
            IF sy-subrc = 0.
              READ TABLE t_a777 WITH KEY kschl = 'ZIDP'
                                         katr1 = t_kna1-katr1
                                         kvgr3 = t_kna1-kvgr3.
              IF sy-subrc = 0.
                ld_zdelvp = ld_zdelvp + t_a777-zdelvp.
              ENDIF.
            ENDIF.
*            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    PERFORM f_jumlah_pertanggal USING ld_day
                                      ld_zdelvp.
  ENDWHILE.
ENDFORM.                    " F_HITUNG_DELIVERY_KVGR3

*&---------------------------------------------------------------------*
*&      Form  F_JUMLAH_PERTANGGAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_DAY  text
*      -->P_LD_ZDELVP  text
*----------------------------------------------------------------------*
FORM f_jumlah_pertanggal USING p_ld_day
                               p_ld_zdelvp.
  IF p_ld_zdelvp = 'X'.
    CASE p_ld_day.
      WHEN '01'.
        t_report-tgl01 = p_ld_zdelvp.
      WHEN '02'.
        t_report-tgl02 = p_ld_zdelvp.
      WHEN '03'.
        t_report-tgl03 = p_ld_zdelvp.
      WHEN '04'.
        t_report-tgl04 = p_ld_zdelvp.
      WHEN '05'.
        t_report-tgl05 = p_ld_zdelvp.
      WHEN '06'.
        t_report-tgl06 = p_ld_zdelvp.
      WHEN '07'.
        t_report-tgl07 = p_ld_zdelvp.
      WHEN '08'.
        t_report-tgl08 = p_ld_zdelvp.
      WHEN '09'.
        t_report-tgl09 = p_ld_zdelvp.
      WHEN '10'.
        t_report-tgl10 = p_ld_zdelvp.
      WHEN '11'.
        t_report-tgl11 = p_ld_zdelvp.
      WHEN '12'.
        t_report-tgl12 = p_ld_zdelvp.
      WHEN '13'.
        t_report-tgl13 = p_ld_zdelvp.
      WHEN '14'.
        t_report-tgl14 = p_ld_zdelvp.
      WHEN '15'.
        t_report-tgl15 = p_ld_zdelvp.
      WHEN '16'.
        t_report-tgl16 = p_ld_zdelvp.
      WHEN '17'.
        t_report-tgl17 = p_ld_zdelvp.
      WHEN '18'.
        t_report-tgl18 = p_ld_zdelvp.
      WHEN '19'.
        t_report-tgl19 = p_ld_zdelvp.
      WHEN '20'.
        t_report-tgl20 = p_ld_zdelvp.
      WHEN '21'.
        t_report-tgl21 = p_ld_zdelvp.
      WHEN '22'.
        t_report-tgl22 = p_ld_zdelvp.
      WHEN '23'.
        t_report-tgl23 = p_ld_zdelvp.
      WHEN '24'.
        t_report-tgl24 = p_ld_zdelvp.
      WHEN '25'.
        t_report-tgl25 = p_ld_zdelvp.
      WHEN '26'.
        t_report-tgl26 = p_ld_zdelvp.
      WHEN '27'.
        t_report-tgl27 = p_ld_zdelvp.
      WHEN '28'.
        t_report-tgl28 = p_ld_zdelvp.
      WHEN '29'.
        t_report-tgl29 = p_ld_zdelvp.
      WHEN '30'.
        t_report-tgl30 = p_ld_zdelvp.
      WHEN '31'.
        t_report-tgl31 = p_ld_zdelvp.
    ENDCASE.
  ELSE.
    CASE p_ld_day.
      WHEN '01'.
        t_report-tgl01 = t_report-tgl01 + p_ld_zdelvp.
      WHEN '02'.
        t_report-tgl02 = t_report-tgl02 + p_ld_zdelvp.
      WHEN '03'.
        t_report-tgl03 = t_report-tgl03 + p_ld_zdelvp.
      WHEN '04'.
        t_report-tgl04 = t_report-tgl04 + p_ld_zdelvp.
      WHEN '05'.
        t_report-tgl05 = t_report-tgl05 + p_ld_zdelvp.
      WHEN '06'.
        t_report-tgl06 = t_report-tgl06 + p_ld_zdelvp.
      WHEN '07'.
        t_report-tgl07 = t_report-tgl07 + p_ld_zdelvp.
      WHEN '08'.
        t_report-tgl08 = t_report-tgl08 + p_ld_zdelvp.
      WHEN '09'.
        t_report-tgl09 = t_report-tgl09 + p_ld_zdelvp.
      WHEN '10'.
        t_report-tgl10 = t_report-tgl10 + p_ld_zdelvp.
      WHEN '11'.
        t_report-tgl11 = t_report-tgl11 + p_ld_zdelvp.
      WHEN '12'.
        t_report-tgl12 = t_report-tgl12 + p_ld_zdelvp.
      WHEN '13'.
        t_report-tgl13 = t_report-tgl13 + p_ld_zdelvp.
      WHEN '14'.
        t_report-tgl14 = t_report-tgl14 + p_ld_zdelvp.
      WHEN '15'.
        t_report-tgl15 = t_report-tgl15 + p_ld_zdelvp.
      WHEN '16'.
        t_report-tgl16 = t_report-tgl16 + p_ld_zdelvp.
      WHEN '17'.
        t_report-tgl17 = t_report-tgl17 + p_ld_zdelvp.
      WHEN '18'.
        t_report-tgl18 = t_report-tgl18 + p_ld_zdelvp.
      WHEN '19'.
        t_report-tgl19 = t_report-tgl19 + p_ld_zdelvp.
      WHEN '20'.
        t_report-tgl20 = t_report-tgl20 + p_ld_zdelvp.
      WHEN '21'.
        t_report-tgl21 = t_report-tgl21 + p_ld_zdelvp.
      WHEN '22'.
        t_report-tgl22 = t_report-tgl22 + p_ld_zdelvp.
      WHEN '23'.
        t_report-tgl23 = t_report-tgl23 + p_ld_zdelvp.
      WHEN '24'.
        t_report-tgl24 = t_report-tgl24 + p_ld_zdelvp.
      WHEN '25'.
        t_report-tgl25 = t_report-tgl25 + p_ld_zdelvp.
      WHEN '26'.
        t_report-tgl26 = t_report-tgl26 + p_ld_zdelvp.
      WHEN '27'.
        t_report-tgl27 = t_report-tgl27 + p_ld_zdelvp.
      WHEN '28'.
        t_report-tgl28 = t_report-tgl28 + p_ld_zdelvp.
      WHEN '29'.
        t_report-tgl29 = t_report-tgl29 + p_ld_zdelvp.
      WHEN '30'.
        t_report-tgl30 = t_report-tgl30 + p_ld_zdelvp.
      WHEN '31'.
        t_report-tgl31 = t_report-tgl31 + p_ld_zdelvp.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_JUMLAH_PERTANGGAL

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_AVERAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_averagex USING fw_outpl STRUCTURE wa_outpl3 fu_avr fu_tabix fu_target.
  DATA: ld_hari  TYPE p.

  CASE fu_avr.
    WHEN 1.
      t_avr-text   = fw_outpl-text.
      t_avr-type   = fw_outpl-type.
      t_avr-dlk    = fw_outpl-dlk.
      t_avr-total  = fw_outpl-total.
      COLLECT t_avr. CLEAR t_avr.
    WHEN 2.
      READ TABLE gt_rayon WITH KEY vkbur = fw_outpl-vstel BINARY SEARCH.
      IF sy-subrc NE 0.
        SORT gt_rayon BY vkbur.
        READ TABLE gt_rayon WITH KEY vkbur = fw_outpl-vstel BINARY SEARCH.
      ENDIF.
      IF gt_rayon-katr1 IS NOT INITIAL AND fw_outpl-bzirk IS NOT INITIAL.
        IF fw_outpl-target LT 6.
          ld_hari = fw_outpl-00hari.
        ENDIF.
        CASE fw_outpl-target.
          WHEN 6.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari.
          WHEN 7.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari.
          WHEN 8.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari.
          WHEN 9.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari + fw_outpl-09hari.
          WHEN 10.
            ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                      fw_outpl-08hari + fw_outpl-09hari + fw_outpl-10hari.
        ENDCASE.
        IF fw_outpl-target GT 10.
          ld_hari = fw_outpl-00hari + fw_outpl-06hari + fw_outpl-07hari +
                    fw_outpl-08hari + fw_outpl-09hari + fw_outpl-10hari +
                    fw_outpl-11hari.
        ENDIF.
        ADD ld_hari TO t_avr-hari.
      ELSE.
        CASE fw_outpl-target.
          WHEN 0.
            ld_hari  = fw_outpl-0hari.
          WHEN 1.
            ld_hari  = fw_outpl-0hari + fw_outpl-1hari.
          WHEN 2.
            ld_hari  = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari.
          WHEN 3.
            ld_hari  = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari +
                       fw_outpl-3hari.
          WHEN OTHERS.
            ld_hari  = fw_outpl-0hari + fw_outpl-1hari + fw_outpl-2hari +
                       fw_outpl-3hari + fw_outpl-4hari.
        ENDCASE.
        ADD ld_hari TO t_avr-hari.
      ENDIF.

      MODIFY t_avr INDEX fu_tabix TRANSPORTING hari.
  ENDCASE.
ENDFORM.                    " F_HITUNG_AVERAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_DISTRICT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sales_districtx .
  DATA: BEGIN OF lt_knvv OCCURS 0,
          kunnr LIKE knvv-kunnr,
          bzirk LIKE knvv-bzirk.
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
*&      Form  F_DELETE_VTTP_BY_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_vttp_by_kunnr .
  CLEAR : t_vttp[], t_vttp.
*  t_vttp[]  = t_vttpori[].

*  LOOP AT t_vttk WHERE tplst = gt_tvkbt-vkbur
*                   AND exti1 = i_listbox-exti1.
*    LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
*      CLEAR t_likp.
*      READ TABLE t_likp WITH KEY vbeln = t_vttp-vbeln.
*      t_vttp-kunnr = t_likp-kunnr.
*      MODIFY t_vttp TRANSPORTING kunnr.
*    ENDLOOP.
*  ENDLOOP.
*
*  SORT t_vttp BY tknum kunnr.
*  DELETE ADJACENT DUPLICATES FROM t_vttp COMPARING tknum kunnr.

  LOOP AT t_vttk WHERE tplst = gt_tvkbt-vkbur
                   AND exti1 = i_listbox-exti1.
    LOOP AT t_vttpori WHERE tknum = t_vttk-tknum.
      CLEAR t_likp.
      READ TABLE t_likp WITH KEY vbeln = t_vttpori-vbeln.
      t_vttpori-kunnr = t_likp-kunnr.
      MODIFY t_vttpori TRANSPORTING kunnr.
    ENDLOOP.
  ENDLOOP.

  SORT t_vttpori BY tknum kunnr.
  LOOP AT t_vttpori.
    CHECK t_vttpori-kunnr IS NOT INITIAL.
    t_vttp = t_vttpori.
    COLLECT t_vttp.
  ENDLOOP.

  SORT t_vttp BY tknum kunnr.
  DELETE ADJACENT DUPLICATES FROM t_vttp COMPARING tknum kunnr.

ENDFORM.                    " F_DELETE_VTTP_BY_KUNNR

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TARGET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_target .
  DATA: ld_day(2)    TYPE n,
        ld_date      LIKE sy-datum,
*        ld_zdelvp LIKE t_a777-zdelvp.
        ld_zdelvp(3),
        ld_dayinweek LIKE scal-indicator,
        ld_daytxt    LIKE rnpb2-day_txt,
        lv_month(2).

  t_report-vkbur = gt_tvkbt-vkbur.
  t_report-bezei = gt_tvkbt-bezei.
  t_report-nama = i_listbox-exti1.
  lv_month  = pa_spmon+4(2).
  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = lv_month
    IMPORTING
      name  = t_report-bulan.

  t_report-urutan = '05'.
  t_report-text = 'Target Point'.
  WHILE ld_day LT va_datet+6(2).
    ld_day = ld_day + 1.
    CLEAR: t_holiday,ld_date,ld_zdelvp.
    CONCATENATE pa_spmon ld_day INTO ld_date.
    READ TABLE t_holiday WITH KEY date = ld_date.
    IF sy-subrc = 0.
      ld_zdelvp = 'X'.
    ELSE.
      CLEAR ld_zdelvp.
      LOOP AT t_vttk WHERE erdat = ld_date
                       AND exti1 = i_listbox-exti1.
        LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
          LOOP AT t_likp WHERE vbeln = t_vttp-vbeln.
            ADD 1 TO ld_zdelvp.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
*      CALL FUNCTION 'ISH_GET_DAY_OF_WEEK'
*        EXPORTING
*          date    = ld_date
*        IMPORTING
*          day     = ld_dayinweek
*          day_txt = ld_daytxt.
*      IF sy-subrc = 0.
*        CLEAR t_a777.
*        IF ld_dayinweek = 6.
*          READ TABLE t_a777 WITH KEY kschl = 'ZIDT'
*                                     zdaywk = 6.
*        ELSE.
*          READ TABLE t_a777 WITH KEY kschl = 'ZIDT'
*                                     zdaywk = space.
*        ENDIF.
*      ENDIF.
*      ld_zdelvp = t_a777-zdelvp.
    ENDIF.

    PERFORM f_split_date USING ld_day ld_zdelvp.

  ENDWHILE.
  APPEND t_report. CLEAR t_report.
ENDFORM.                    " F_HITUNG_TARGET

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_AKTUAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_aktual .
  DATA: lt_a777   LIKE t_a777 OCCURS 0 WITH HEADER LINE,
        ld_zdaywk LIKE a777-zdaywk,
        ld_dklk   LIKE a777-katr1,
        ld_length TYPE i,
        ld_text   LIKE t_report-text.

  lt_a777[] = t_a777[].
  DELETE lt_a777 WHERE kschl NE 'ZIDP'.
  SORT lt_a777 BY katr1 zdaywk kdgrp kvgr3.
  SORT t_vttk BY erdat.
  SORT t_vttp BY tknum vbeln.
  SORT t_likp BY vbeln kunnr.
  SORT t_kna1 BY kunnr.

  t_report-vkbur = gt_tvkbt-vkbur.
  t_report-bezei = va_bezei.
  t_report-nama = i_listbox-exti1.
  t_report-bulan = va_bulan.
  LOOP AT lt_a777.
    AT NEW katr1.
      ld_dklk = lt_a777-katr1.
      t_report-dklk = lt_a777-katr1.
    ENDAT.

    AT NEW zdaywk.
      ld_zdaywk = lt_a777-zdaywk.
      t_report-urutan = lt_a777-zdaywk.

      IF t_report-urutan EQ 'FT'.
        t_report-dklk   = 'FT'.
        t_report-urutan = '998'.
      ENDIF.
    ENDAT.

    IF lt_a777-kvgr3 IS INITIAL.
      IF t_report-text IS INITIAL.
        t_report-text = lt_a777-kdgrp.
      ELSE.
        CONCATENATE t_report-text lt_a777-kdgrp INTO t_report-text SEPARATED BY '/'.
      ENDIF.
      IF lt_a777-zdaywk = '99'.
        t_report-text = 'MIX'.
      ENDIF.

      CASE 'X'.
        WHEN radio2.
          PERFORM f_hitung_delivery_kdgrp USING lt_a777-katr1
                                                lt_a777-kdgrp.
        WHEN radio3.
          PERFORM f_delv_count_kdgrp_cust USING lt_a777-katr1
                                                lt_a777-kdgrp.
      ENDCASE.
    ELSE.
      IF t_report-text IS INITIAL.
        t_report-text = lt_a777-kvgr3.
      ELSE.
        CONCATENATE t_report-text lt_a777-kvgr3 INTO t_report-text SEPARATED BY '/'.
      ENDIF.
      IF lt_a777-zdaywk = '99'.
        t_report-text = 'MIX'.
      ENDIF.

      CASE 'X'.
        WHEN radio2.
          PERFORM f_hitung_delivery_kvgr3 USING lt_a777-katr1
                                                lt_a777-kvgr3.
        WHEN radio3.
          PERFORM f_delv_count_kvgr3_cust USING lt_a777-katr1
                                                lt_a777-kvgr3.
      ENDCASE.
    ENDIF.
*    IF t_report-dklk = 'LK' AND t_report-text IS INITIAL.
*      t_report-urutan = '900'.
*      t_report-text = 'MIX'.
*    ENDIF.
    AT END OF zdaywk.
      IF t_report-text NA '/'.
        ld_length = strlen( t_report-text ).
        IF ld_length = 2.
          SELECT SINGLE ktext INTO ld_text
            FROM t151t WHERE spras = sy-langu AND
                             kdgrp = t_report-text.
          IF sy-subrc = 0.
            t_report-text = ld_text.
          ENDIF.
        ELSE.
          SELECT SINGLE bezei INTO ld_text
            FROM tvv3t WHERE spras = sy-langu AND
                             kvgr3 = t_report-text.
          IF sy-subrc = 0.
            t_report-text = ld_text.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND t_report.
      CLEAR: ld_text,t_report-text,
             t_report-tgl01,t_report-tgl02,t_report-tgl03,t_report-tgl04,
             t_report-tgl05,t_report-tgl06,t_report-tgl07,t_report-tgl08,
             t_report-tgl09,t_report-tgl10,t_report-tgl11,t_report-tgl12,
             t_report-tgl13,t_report-tgl14,t_report-tgl15,t_report-tgl16,
             t_report-tgl17,t_report-tgl18,t_report-tgl19,t_report-tgl20,
             t_report-tgl21,t_report-tgl22,t_report-tgl23,t_report-tgl24,
             t_report-tgl25,t_report-tgl26,t_report-tgl27,t_report-tgl28,
             t_report-tgl29,t_report-tgl30,t_report-tgl31.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_HITUNG_AKTUAL

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_FT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_ft .
  DATA: ld_day(2) TYPE n,
        lt_report LIKE t_report OCCURS 0 WITH HEADER LINE,
        lt_modi   LIKE t_ft OCCURS 0 WITH HEADER LINE.

  LOOP AT t_report WHERE urutan EQ '998' AND
                         vkbur  EQ gt_tvkbt-vkbur AND
                         nama   EQ i_listbox-exti1.
    lt_modi-vkbur   = t_report-vkbur.
    lt_modi-bezei   = t_report-bezei.
    lt_modi-nama    = t_report-nama.
    lt_modi-bulan   = t_report-bulan.
    lt_modi-urutan  = t_report-urutan.
    lt_modi-dklk    = t_report-dklk.
    lt_modi-text    = t_report-text.

    READ TABLE t_a777 WITH KEY kappl  = 'V'
                               kschl  = 'ZIDP'
                               vkorg  = pa_vkorg
                               zdaywk = 'FT'
                               vkbur  = t_report-vkbur.
    IF sy-subrc EQ 0.
      LOOP AT t_vttk WHERE add03 EQ '01' AND
                           tplst EQ t_report-vkbur AND
                           exti1 EQ t_report-nama.
        ld_day  = t_vttk-datbg+6(2).
        PERFORM f_split_date USING ld_day t_a777-zdelvp.
        PERFORM f_add_ft TABLES lt_modi.
      ENDLOOP.

      lt_report-vkbur   = t_report-vkbur.
      lt_report-bezei   = t_report-bezei.
      lt_report-nama    = t_report-nama.
      lt_report-bulan   = t_report-bulan.
      lt_report-urutan  = t_report-urutan.
      lt_report-dklk    = t_report-dklk.
      lt_report-text    = t_report-text.

      READ TABLE lt_modi INDEX 1.
      PERFORM f_move_ft TABLES lt_report
                               lt_modi.
    ENDIF.
    APPEND lt_report.
    MODIFY t_report FROM lt_report.
  ENDLOOP.

  LOOP AT t_report.
    CASE t_report-dklk.
      WHEN 'DK'.
        PERFORM f_modi_dklk TABLES lt_report
                            USING t_report.
        MODIFY t_report.
      WHEN 'LK'.
        PERFORM f_modi_dklk TABLES lt_report
                            USING t_report.
        MODIFY t_report.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_HITUNG_FT

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_total .
  DATA: lw_report LIKE t_report.

  CLEAR: va_totaktual,va_tottarget.
  lw_report-vkbur = gt_tvkbt-vkbur.
  lw_report-bezei = va_bezei.
  lw_report-nama = i_listbox-exti1.
  lw_report-bulan = va_bulan.
  lw_report-urutan = '999'.
  lw_report-text = 'Total Realisasi'.

  LOOP AT t_report WHERE vkbur EQ gt_tvkbt-vkbur AND
                         nama  EQ i_listbox-exti1.
    .
** Tgl 01
    IF t_report-tgl01 = 'X'.
      lw_report-tgl01 = t_report-tgl01.
    ELSEIF t_report-tgl01 = ' 0'.
      CLEAR t_report-tgl01.
      MODIFY t_report TRANSPORTING tgl01.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl01 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl01 + va_totaktual.
        IF lw_report-tgl01 = 'X'.
        ELSE.
          lw_report-tgl01 = t_report-tgl01 + lw_report-tgl01.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 02
    IF t_report-tgl02 = 'X'.
      lw_report-tgl02 = t_report-tgl02.
    ELSEIF t_report-tgl02 = ' 0'.
      CLEAR t_report-tgl02.
      MODIFY t_report TRANSPORTING tgl02.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl02 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl02 + va_totaktual.
        IF lw_report-tgl02 = 'X'.
        ELSE.
          lw_report-tgl02 = t_report-tgl02 + lw_report-tgl02.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 03
    IF t_report-tgl03 = 'X'.
      lw_report-tgl03 = t_report-tgl03.
    ELSEIF t_report-tgl03 = ' 0'.
      CLEAR t_report-tgl03.
      MODIFY t_report TRANSPORTING tgl03.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl03 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl03 + va_totaktual.
        IF lw_report-tgl03 = 'X'.
        ELSE.
          lw_report-tgl03 = t_report-tgl03 +  lw_report-tgl03.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 04
    IF t_report-tgl04 = 'X'.
      lw_report-tgl04 = t_report-tgl04.
    ELSEIF t_report-tgl04 = ' 0'.
      CLEAR t_report-tgl04.
      MODIFY t_report TRANSPORTING tgl04.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl04 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl04 + va_totaktual.
        IF lw_report-tgl04 = 'X'.
        ELSE.
          lw_report-tgl04 = t_report-tgl04 + lw_report-tgl04.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 05
    IF t_report-tgl05 = 'X'.
      lw_report-tgl05 = t_report-tgl05.
    ELSEIF t_report-tgl05 = ' 0'.
      CLEAR t_report-tgl05.
      MODIFY t_report TRANSPORTING tgl05.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl05 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl05 + va_totaktual.
        IF lw_report-tgl05 = 'X'.
        ELSE.
          lw_report-tgl05 = t_report-tgl05 +  lw_report-tgl05.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 06
    IF t_report-tgl06 = 'X'.
      lw_report-tgl06 = t_report-tgl06.
    ELSEIF t_report-tgl06 = ' 0'.
      CLEAR t_report-tgl06.
      MODIFY t_report TRANSPORTING tgl06.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl06 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl06 + va_totaktual.
        IF lw_report-tgl06 = 'X'.
        ELSE.
          lw_report-tgl06 = t_report-tgl06 + lw_report-tgl06.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 07
    IF t_report-tgl07 = 'X'.
      lw_report-tgl07 = t_report-tgl07.
    ELSEIF t_report-tgl07 = ' 0'.
      CLEAR t_report-tgl07.
      MODIFY t_report TRANSPORTING tgl07.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl07 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl07 + va_totaktual.
        IF lw_report-tgl07 = 'X'.
        ELSE.
          lw_report-tgl07 = t_report-tgl07 + lw_report-tgl07.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 08
    IF t_report-tgl08 = 'X'.
      lw_report-tgl08 = t_report-tgl08.
    ELSEIF t_report-tgl08 = ' 0'.
      CLEAR t_report-tgl08.
      MODIFY t_report TRANSPORTING tgl08.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl08 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl08 + va_totaktual.
        IF lw_report-tgl08 = 'X'.
        ELSE.
          lw_report-tgl08 = t_report-tgl08 + lw_report-tgl08.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 09
    IF t_report-tgl09 = 'X'.
      lw_report-tgl09 = t_report-tgl09.
    ELSEIF t_report-tgl09 = ' 0'.
      CLEAR t_report-tgl09.
      MODIFY t_report TRANSPORTING tgl09.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl09 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl09 + va_totaktual.
        IF lw_report-tgl09 = 'X'.
        ELSE.
          lw_report-tgl09 = t_report-tgl09 + lw_report-tgl09.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 10
    IF t_report-tgl10 = 'X'.
      lw_report-tgl10 = t_report-tgl10.
    ELSEIF t_report-tgl10 = ' 0'.
      CLEAR t_report-tgl10.
      MODIFY t_report TRANSPORTING tgl10.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl10 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl10 + va_totaktual.
        IF lw_report-tgl10 = 'X'.
        ELSE.
          lw_report-tgl10 = t_report-tgl10 + lw_report-tgl10.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 11
    IF t_report-tgl11 = 'X'.
      lw_report-tgl11 = t_report-tgl11.
    ELSEIF t_report-tgl11 = ' 0'.
      CLEAR t_report-tgl11.
      MODIFY t_report TRANSPORTING tgl11.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl11 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl11 + va_totaktual.
        IF lw_report-tgl11 = 'X'.
        ELSE.
          lw_report-tgl11 = t_report-tgl11 + lw_report-tgl11.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 12
    IF t_report-tgl12 = 'X'.
      lw_report-tgl12 = t_report-tgl12.
    ELSEIF t_report-tgl12 = ' 0'.
      CLEAR t_report-tgl12.
      MODIFY t_report TRANSPORTING tgl12.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl12 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl12 + va_totaktual.
        IF lw_report-tgl12 = 'X'.
        ELSE.
          lw_report-tgl12 = t_report-tgl12 + lw_report-tgl12.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 13
    IF t_report-tgl13 = 'X'.
      lw_report-tgl13 = t_report-tgl13.
    ELSEIF t_report-tgl13 = ' 0'.
      CLEAR t_report-tgl13.
      MODIFY t_report TRANSPORTING tgl13.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl13 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl13 + va_totaktual.
        IF lw_report-tgl13 = 'X'.
        ELSE.
          lw_report-tgl13 = t_report-tgl13 + lw_report-tgl13.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 14
    IF t_report-tgl14 = 'X'.
      lw_report-tgl14 = t_report-tgl14.
    ELSEIF t_report-tgl14 = ' 0'.
      CLEAR t_report-tgl14.
      MODIFY t_report TRANSPORTING tgl14.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl14 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl14 + va_totaktual.
        IF lw_report-tgl14 = 'X'.
        ELSE.
          lw_report-tgl14 = t_report-tgl14 + lw_report-tgl14.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 15
    IF t_report-tgl15 = 'X'.
      lw_report-tgl15 = t_report-tgl15.
    ELSEIF t_report-tgl15 = ' 0'.
      CLEAR t_report-tgl15.
      MODIFY t_report TRANSPORTING tgl15.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl15 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl15 + va_totaktual.
        IF lw_report-tgl15 = 'X'.
        ELSE.
          lw_report-tgl15 = t_report-tgl15 + lw_report-tgl15.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 16
    IF t_report-tgl16 = 'X'.
      lw_report-tgl16 = t_report-tgl16.
    ELSEIF t_report-tgl16 = ' 0'.
      CLEAR t_report-tgl16.
      MODIFY t_report TRANSPORTING tgl16.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl16 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl16 + va_totaktual.
        IF lw_report-tgl16 = 'X'.
        ELSE.
          lw_report-tgl16 = t_report-tgl16 + lw_report-tgl16.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 17
    IF t_report-tgl17 = 'X'.
      lw_report-tgl17 = t_report-tgl17.
    ELSEIF t_report-tgl17 = ' 0'.
      CLEAR t_report-tgl17.
      MODIFY t_report TRANSPORTING tgl17.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl17 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl17 + va_totaktual.
        IF lw_report-tgl17 = 'X'.
        ELSE.
          lw_report-tgl17 = t_report-tgl17 + lw_report-tgl17.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 18
    IF t_report-tgl18 = 'X'.
      lw_report-tgl18 = t_report-tgl18.
    ELSEIF t_report-tgl18 = ' 0'.
      CLEAR t_report-tgl18.
      MODIFY t_report TRANSPORTING tgl18.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl18 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl18 + va_totaktual.
        IF lw_report-tgl18 = 'X'.
        ELSE.
          lw_report-tgl18 = t_report-tgl18 + lw_report-tgl18.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 19
    IF t_report-tgl19 = 'X'.
      lw_report-tgl19 = t_report-tgl19.
    ELSEIF t_report-tgl19 = ' 0'.
      CLEAR t_report-tgl19.
      MODIFY t_report TRANSPORTING tgl19.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl19 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl19 + va_totaktual.
        IF lw_report-tgl19 = 'X'.
        ELSE.
          lw_report-tgl19 = t_report-tgl19 + lw_report-tgl19.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 20
    IF t_report-tgl20 = 'X'.
      lw_report-tgl20 = t_report-tgl20.
    ELSEIF t_report-tgl20 = ' 0'.
      CLEAR t_report-tgl20.
      MODIFY t_report TRANSPORTING tgl20.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl20 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl20 + va_totaktual.
        IF lw_report-tgl20 = 'X'.
        ELSE.
          lw_report-tgl20 = t_report-tgl20 + lw_report-tgl20.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 21
    IF t_report-tgl21 = 'X'.
      lw_report-tgl21 = t_report-tgl21.
    ELSEIF t_report-tgl21 = ' 0'.
      CLEAR t_report-tgl21.
      MODIFY t_report TRANSPORTING tgl21.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl21 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl21 + va_totaktual.
        IF lw_report-tgl21 = 'X'.
        ELSE.
          lw_report-tgl21 = t_report-tgl21 + lw_report-tgl21.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 22
    IF t_report-tgl22 = 'X'.
      lw_report-tgl22 = t_report-tgl22.
    ELSEIF t_report-tgl22 = ' 0'.
      CLEAR t_report-tgl22.
      MODIFY t_report TRANSPORTING tgl22.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl22 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl22 + va_totaktual.
        IF lw_report-tgl22 = 'X'.
        ELSE.
          lw_report-tgl22 = t_report-tgl22 + lw_report-tgl22.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 23
    IF t_report-tgl23 = 'X'.
      lw_report-tgl23 = t_report-tgl23.
    ELSEIF t_report-tgl23 = ' 0'.
      CLEAR t_report-tgl23.
      MODIFY t_report TRANSPORTING tgl23.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl23 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl23 + va_totaktual.
        IF lw_report-tgl23 = 'X'.
        ELSE.
          lw_report-tgl23 = t_report-tgl23 + lw_report-tgl23.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 24
    IF t_report-tgl24 = 'X'.
      lw_report-tgl24 = t_report-tgl24.
    ELSEIF t_report-tgl24 = ' 0'.
      CLEAR t_report-tgl24.
      MODIFY t_report TRANSPORTING tgl24.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl24 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl24 + va_totaktual.
        IF lw_report-tgl24 = 'X'.
        ELSE.
          lw_report-tgl24 = t_report-tgl24 + lw_report-tgl24.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 25
    IF t_report-tgl25 = 'X'.
      lw_report-tgl25 = t_report-tgl25.
    ELSEIF t_report-tgl25 = ' 0'.
      CLEAR t_report-tgl25.
      MODIFY t_report TRANSPORTING tgl25.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl25 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl25 + va_totaktual.
        IF lw_report-tgl25 = 'X'.
        ELSE.
          lw_report-tgl25 = t_report-tgl25 + lw_report-tgl25.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 26
    IF t_report-tgl26 = 'X'.
      lw_report-tgl26 = t_report-tgl26.
    ELSEIF t_report-tgl26 = ' 0'.
      CLEAR t_report-tgl26.
      MODIFY t_report TRANSPORTING tgl26.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl26 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl26 + va_totaktual.
        IF lw_report-tgl26 = 'X'.
        ELSE.
          lw_report-tgl26 = t_report-tgl26 + lw_report-tgl26.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 27
    IF t_report-tgl27 = 'X'.
      lw_report-tgl27 = t_report-tgl27.
    ELSEIF t_report-tgl27 = ' 0'.
      CLEAR t_report-tgl27.
      MODIFY t_report TRANSPORTING tgl27.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl27 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl27 + va_totaktual.
        IF lw_report-tgl27 = 'X'.
        ELSE.
          lw_report-tgl27 = t_report-tgl27 + lw_report-tgl27.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 28
    IF t_report-tgl28 = 'X'.
      lw_report-tgl28 = t_report-tgl28.
    ELSEIF t_report-tgl28 = ' 0'.
      CLEAR t_report-tgl28.
      MODIFY t_report TRANSPORTING tgl28.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl28 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl28 + va_totaktual.
        IF lw_report-tgl28 = 'X'.
        ELSE.
          lw_report-tgl28 = t_report-tgl28 + lw_report-tgl28.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 29
    IF t_report-tgl29 = 'X'.
      lw_report-tgl29 = t_report-tgl29.
    ELSEIF t_report-tgl29 = ' 0'.
      CLEAR t_report-tgl29.
      MODIFY t_report TRANSPORTING tgl29.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl29 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl29 + va_totaktual.
        IF lw_report-tgl29 = 'X'.
        ELSE.
          lw_report-tgl29 = t_report-tgl29 + lw_report-tgl29.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 30
    IF t_report-tgl30 = 'X'.
      lw_report-tgl30 = t_report-tgl30.
    ELSEIF t_report-tgl30 = ' 0'.
      CLEAR t_report-tgl30.
      MODIFY t_report TRANSPORTING tgl30.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl30 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl30 + va_totaktual.
        IF lw_report-tgl30 = 'X'.
        ELSE.
          lw_report-tgl30 = t_report-tgl30 + lw_report-tgl30.
        ENDIF.
      ENDIF.
    ENDIF.
** Tgl 31
    IF t_report-tgl31 = 'X'.
      lw_report-tgl31 = t_report-tgl31.
    ELSEIF t_report-tgl31 = ' 0'.
      CLEAR t_report-tgl31.
      MODIFY t_report TRANSPORTING tgl31.
    ELSE.
      IF t_report-urutan = '05'.
        va_tottarget = t_report-tgl31 + va_tottarget.
      ELSE.
        va_totaktual = t_report-tgl31 + va_totaktual.
        IF lw_report-tgl31 = 'X'.
        ELSE.
          lw_report-tgl31 = t_report-tgl31 + lw_report-tgl31.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

** Hitung persentase
  IF va_tottarget IS INITIAL.
    va_totpercen = 0.
  ELSE.
    va_totpercen = va_totaktual / va_tottarget * 100.
  ENDIF.

** append total
  MOVE va_tottarget TO lw_report-tottarget.
  MOVE va_totaktual TO lw_report-totaktual.

  t_report = lw_report.
  APPEND t_report.
ENDFORM.                    " F_HITUNG_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_DAY  text
*      -->P_T_A777_ZDELVP  text
*----------------------------------------------------------------------*
FORM f_split_date  USING    fu_day fu_zdelvp.
  CASE fu_day.
    WHEN '01'.
      t_report-tgl01 = fu_zdelvp.
    WHEN '02'.
      t_report-tgl02 = fu_zdelvp.
    WHEN '03'.
      t_report-tgl03 = fu_zdelvp.
    WHEN '04'.
      t_report-tgl04 = fu_zdelvp.
    WHEN '05'.
      t_report-tgl05 = fu_zdelvp.
    WHEN '06'.
      t_report-tgl06 = fu_zdelvp.
    WHEN '07'.
      t_report-tgl07 = fu_zdelvp.
    WHEN '08'.
      t_report-tgl08 = fu_zdelvp.
    WHEN '09'.
      t_report-tgl09 = fu_zdelvp.
    WHEN '10'.
      t_report-tgl10 = fu_zdelvp.
    WHEN '11'.
      t_report-tgl11 = fu_zdelvp.
    WHEN '12'.
      t_report-tgl12 = fu_zdelvp.
    WHEN '13'.
      t_report-tgl13 = fu_zdelvp.
    WHEN '14'.
      t_report-tgl14 = fu_zdelvp.
    WHEN '15'.
      t_report-tgl15 = fu_zdelvp.
    WHEN '16'.
      t_report-tgl16 = fu_zdelvp.
    WHEN '17'.
      t_report-tgl17 = fu_zdelvp.
    WHEN '18'.
      t_report-tgl18 = fu_zdelvp.
    WHEN '19'.
      t_report-tgl19 = fu_zdelvp.
    WHEN '20'.
      t_report-tgl20 = fu_zdelvp.
    WHEN '21'.
      t_report-tgl21 = fu_zdelvp.
    WHEN '22'.
      t_report-tgl22 = fu_zdelvp.
    WHEN '23'.
      t_report-tgl23 = fu_zdelvp.
    WHEN '24'.
      t_report-tgl24 = fu_zdelvp.
    WHEN '25'.
      t_report-tgl25 = fu_zdelvp.
    WHEN '26'.
      t_report-tgl26 = fu_zdelvp.
    WHEN '27'.
      t_report-tgl27 = fu_zdelvp.
    WHEN '28'.
      t_report-tgl28 = fu_zdelvp.
    WHEN '29'.
      t_report-tgl29 = fu_zdelvp.
    WHEN '30'.
      t_report-tgl30 = fu_zdelvp.
    WHEN '31'.
      t_report-tgl31 = fu_zdelvp.
  ENDCASE.
ENDFORM.                    " F_SPLIT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_FT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_MODI  text
*----------------------------------------------------------------------*
FORM f_add_ft  TABLES   ft_report STRUCTURE t_ft.
  PERFORM f_add USING t_report-tgl01
                CHANGING ft_report-tgl01.
  PERFORM f_add USING t_report-tgl02
                CHANGING ft_report-tgl02.
  PERFORM f_add USING t_report-tgl03
                CHANGING ft_report-tgl03.
  PERFORM f_add USING t_report-tgl04
                CHANGING ft_report-tgl04.
  PERFORM f_add USING t_report-tgl05
                CHANGING ft_report-tgl05.
  PERFORM f_add USING t_report-tgl06
                CHANGING ft_report-tgl06.
  PERFORM f_add USING t_report-tgl07
                CHANGING ft_report-tgl07.
  PERFORM f_add USING t_report-tgl08
                CHANGING ft_report-tgl08.
  PERFORM f_add USING t_report-tgl09
                CHANGING ft_report-tgl09.
  PERFORM f_add USING t_report-tgl10
                CHANGING ft_report-tgl10.
  PERFORM f_add USING t_report-tgl11
                CHANGING ft_report-tgl11.
  PERFORM f_add USING t_report-tgl12
                CHANGING ft_report-tgl12.
  PERFORM f_add USING t_report-tgl13
                CHANGING ft_report-tgl13.
  PERFORM f_add USING t_report-tgl14
                CHANGING ft_report-tgl14.
  PERFORM f_add USING t_report-tgl15
                CHANGING ft_report-tgl15.
  PERFORM f_add USING t_report-tgl16
                CHANGING ft_report-tgl16.
  PERFORM f_add USING t_report-tgl17
                CHANGING ft_report-tgl17.
  PERFORM f_add USING t_report-tgl18
                CHANGING ft_report-tgl18.
  PERFORM f_add USING t_report-tgl19
                CHANGING ft_report-tgl19.
  PERFORM f_add USING t_report-tgl20
                CHANGING ft_report-tgl20.
  PERFORM f_add USING t_report-tgl21
                CHANGING ft_report-tgl21.
  PERFORM f_add USING t_report-tgl22
                CHANGING ft_report-tgl22.
  PERFORM f_add USING t_report-tgl23
                CHANGING ft_report-tgl23.
  PERFORM f_add USING t_report-tgl24
                CHANGING ft_report-tgl24.
  PERFORM f_add USING t_report-tgl25
                CHANGING ft_report-tgl25.
  PERFORM f_add USING t_report-tgl26
                CHANGING ft_report-tgl26.
  PERFORM f_add USING t_report-tgl27
                CHANGING ft_report-tgl27.
  PERFORM f_add USING t_report-tgl28
                CHANGING ft_report-tgl28.
  PERFORM f_add USING t_report-tgl29
                CHANGING ft_report-tgl29.
  PERFORM f_add USING t_report-tgl30
                CHANGING ft_report-tgl30.
  PERFORM f_add USING t_report-tgl31
                CHANGING ft_report-tgl31.

  COLLECT ft_report.

  CLEAR: t_report-tgl01,t_report-tgl02,t_report-tgl03,t_report-tgl04,
         t_report-tgl05,t_report-tgl06,t_report-tgl07,t_report-tgl08,
         t_report-tgl09,t_report-tgl10,t_report-tgl11,t_report-tgl12,
         t_report-tgl13,t_report-tgl14,t_report-tgl15,t_report-tgl16,
         t_report-tgl17,t_report-tgl18,t_report-tgl19,t_report-tgl20,
         t_report-tgl21,t_report-tgl22,t_report-tgl23,t_report-tgl24,
         t_report-tgl25,t_report-tgl26,t_report-tgl27,t_report-tgl28,
         t_report-tgl29,t_report-tgl30,t_report-tgl31.
ENDFORM.                    " F_ADD_FT

*&---------------------------------------------------------------------*
*&      Form  F_ADD
*&---------------------------------------------------------------------*
FORM f_add  USING    fu_tgl
            CHANGING fc_tgl.
  IF fu_tgl = 'X'.
    fc_tgl = -99.
  ELSE.
    fc_tgl = fu_tgl.
  ENDIF.
ENDFORM.                    " F_ADD

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_REPORT  text
*      -->P_LT_MODI  text
*----------------------------------------------------------------------*
FORM f_move_ft  TABLES   ft_report STRUCTURE t_report
                         ft_modi STRUCTURE t_ft.
  PERFORM f_move USING ft_modi-tgl01
                 CHANGING ft_report-tgl01.
  PERFORM f_move USING ft_modi-tgl02
                 CHANGING ft_report-tgl02.
  PERFORM f_move USING ft_modi-tgl03
                 CHANGING ft_report-tgl03.
  PERFORM f_move USING ft_modi-tgl04
                 CHANGING ft_report-tgl04.
  PERFORM f_move USING ft_modi-tgl05
                 CHANGING ft_report-tgl05.
  PERFORM f_move USING ft_modi-tgl06
                 CHANGING ft_report-tgl06.
  PERFORM f_move USING ft_modi-tgl07
                 CHANGING ft_report-tgl07.
  PERFORM f_move USING ft_modi-tgl08
                 CHANGING ft_report-tgl08.
  PERFORM f_move USING ft_modi-tgl09
                 CHANGING ft_report-tgl09.
  PERFORM f_move USING ft_modi-tgl10
                 CHANGING ft_report-tgl10.
  PERFORM f_move USING ft_modi-tgl11
                 CHANGING ft_report-tgl11.
  PERFORM f_move USING ft_modi-tgl12
                 CHANGING ft_report-tgl12.
  PERFORM f_move USING ft_modi-tgl13
                 CHANGING ft_report-tgl13.
  PERFORM f_move USING ft_modi-tgl14
                 CHANGING ft_report-tgl14.
  PERFORM f_move USING ft_modi-tgl15
                 CHANGING ft_report-tgl15.
  PERFORM f_move USING ft_modi-tgl16
                 CHANGING ft_report-tgl16.
  PERFORM f_move USING ft_modi-tgl17
                 CHANGING ft_report-tgl17.
  PERFORM f_move USING ft_modi-tgl18
                 CHANGING ft_report-tgl18.
  PERFORM f_move USING ft_modi-tgl19
                 CHANGING ft_report-tgl19.
  PERFORM f_move USING ft_modi-tgl20
                 CHANGING ft_report-tgl20.
  PERFORM f_move USING ft_modi-tgl21
                 CHANGING ft_report-tgl21.
  PERFORM f_move USING ft_modi-tgl22
                 CHANGING ft_report-tgl22.
  PERFORM f_move USING ft_modi-tgl23
                 CHANGING ft_report-tgl23.
  PERFORM f_move USING ft_modi-tgl24
                 CHANGING ft_report-tgl24.
  PERFORM f_move USING ft_modi-tgl25
                 CHANGING ft_report-tgl25.
  PERFORM f_move USING ft_modi-tgl26
                 CHANGING ft_report-tgl26.
  PERFORM f_move USING ft_modi-tgl27
                 CHANGING ft_report-tgl27.
  PERFORM f_move USING ft_modi-tgl28
                 CHANGING ft_report-tgl28.
  PERFORM f_move USING ft_modi-tgl29
                 CHANGING ft_report-tgl29.
  PERFORM f_move USING ft_modi-tgl30
                 CHANGING ft_report-tgl30.
  PERFORM f_move USING ft_modi-tgl31
                 CHANGING ft_report-tgl31.
ENDFORM.                    " F_MOVE_FT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
FORM f_move  USING    fu_tgl
             CHANGING fc_tgl.
  IF fu_tgl EQ -99.
    fc_tgl  = 'X'.
  ELSE.
    fc_tgl  = fu_tgl.
  ENDIF.
ENDFORM.                    " F_MOVE

*&---------------------------------------------------------------------*
*&      Form  F_MODI_DKLK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_REPORT  text
*      -->P_T_REPORT  text
*----------------------------------------------------------------------*
FORM f_modi_dklk  TABLES   ft_report STRUCTURE t_report
                  USING    lwa_report STRUCTURE t_report.
  READ TABLE ft_report INDEX 1.
  IF sy-subrc EQ 0.
    PERFORM f_modify_value USING ft_report-tgl01
                           CHANGING lwa_report-tgl01.
    PERFORM f_modify_value USING ft_report-tgl02
                           CHANGING lwa_report-tgl02.
    PERFORM f_modify_value USING ft_report-tgl03
                           CHANGING lwa_report-tgl03.
    PERFORM f_modify_value USING ft_report-tgl04
                           CHANGING lwa_report-tgl04.
    PERFORM f_modify_value USING ft_report-tgl05
                           CHANGING lwa_report-tgl05.
    PERFORM f_modify_value USING ft_report-tgl06
                           CHANGING lwa_report-tgl06.
    PERFORM f_modify_value USING ft_report-tgl07
                           CHANGING lwa_report-tgl07.
    PERFORM f_modify_value USING ft_report-tgl08
                           CHANGING lwa_report-tgl08.
    PERFORM f_modify_value USING ft_report-tgl09
                           CHANGING lwa_report-tgl09.
    PERFORM f_modify_value USING ft_report-tgl10
                           CHANGING lwa_report-tgl10.
    PERFORM f_modify_value USING ft_report-tgl11
                           CHANGING lwa_report-tgl11.
    PERFORM f_modify_value USING ft_report-tgl12
                           CHANGING lwa_report-tgl12.
    PERFORM f_modify_value USING ft_report-tgl13
                           CHANGING lwa_report-tgl13.
    PERFORM f_modify_value USING ft_report-tgl14
                           CHANGING lwa_report-tgl14.
    PERFORM f_modify_value USING ft_report-tgl15
                           CHANGING lwa_report-tgl15.
    PERFORM f_modify_value USING ft_report-tgl16
                           CHANGING lwa_report-tgl16.
    PERFORM f_modify_value USING ft_report-tgl17
                           CHANGING lwa_report-tgl17.
    PERFORM f_modify_value USING ft_report-tgl18
                           CHANGING lwa_report-tgl18.
    PERFORM f_modify_value USING ft_report-tgl19
                           CHANGING lwa_report-tgl19.
    PERFORM f_modify_value USING ft_report-tgl20
                           CHANGING lwa_report-tgl20.
    PERFORM f_modify_value USING ft_report-tgl21
                           CHANGING lwa_report-tgl21.
    PERFORM f_modify_value USING ft_report-tgl22
                           CHANGING lwa_report-tgl22.
    PERFORM f_modify_value USING ft_report-tgl23
                           CHANGING lwa_report-tgl23.
    PERFORM f_modify_value USING ft_report-tgl24
                           CHANGING lwa_report-tgl24.
    PERFORM f_modify_value USING ft_report-tgl25
                           CHANGING lwa_report-tgl25.
    PERFORM f_modify_value USING ft_report-tgl26
                           CHANGING lwa_report-tgl26.
    PERFORM f_modify_value USING ft_report-tgl27
                           CHANGING lwa_report-tgl27.
    PERFORM f_modify_value USING ft_report-tgl28
                           CHANGING lwa_report-tgl28.
    PERFORM f_modify_value USING ft_report-tgl29
                           CHANGING lwa_report-tgl29.
    PERFORM f_modify_value USING ft_report-tgl30
                           CHANGING lwa_report-tgl30.
    PERFORM f_modify_value USING ft_report-tgl31
                           CHANGING lwa_report-tgl31.
  ENDIF.
ENDFORM.                    " F_MODI_DKLK

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_tgl
                     CHANGING fc_tgl.
  IF fu_tgl EQ 'X'.
  ELSE.
    IF fu_tgl EQ 0.
    ELSE.
      fc_tgl = 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
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
ENDFORM.                    "f_alv

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'VKBUR' '' '' '' '5' 'SlOff' '' '' '' '' '' '' '' '' 'X' '' '',
    'NAMA' '' '' '' '20' 'Delivery' '' '' '' '' '' '' '' '' 'X' '' '',
    'DKLK' '' '' '' '4' 'DKLK' '' '' '' '' '' '' '' '' 'X' '' '',
    'TEXT' '' '' '' '20' 'Desription' '' '' '' '' '' '' '' '' 'X' '' '',
    'TGL01' '' '' '' '3' '01' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL02' '' '' '' '3' '02' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL03' '' '' '' '3' '03' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL04' '' '' '' '3' '04' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL05' '' '' '' '3' '05' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL06' '' '' '' '3' '06' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL07' '' '' '' '3' '07' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL08' '' '' '' '3' '08' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL09' '' '' '' '3' '09' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL10' '' '' '' '3' '10' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL11' '' '' '' '3' '11' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL12' '' '' '' '3' '12' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL13' '' '' '' '3' '13' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL14' '' '' '' '3' '14' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL15' '' '' '' '3' '15' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL16' '' '' '' '3' '16' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL17' '' '' '' '3' '17' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL18' '' '' '' '3' '18' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL19' '' '' '' '3' '19' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL20' '' '' '' '3' '20' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL21' '' '' '' '3' '21' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL22' '' '' '' '3' '22' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL23' '' '' '' '3' '23' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL24' '' '' '' '3' '24' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL25' '' '' '' '3' '25' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL26' '' '' '' '3' '26' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL27' '' '' '' '3' '27' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL28' '' '' '' '3' '28' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL29' '' '' '' '3' '29' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL30' '' '' '' '3' '30' '' '' '' '' '' '' '' '' '' 'C' 'X',
    'TGL31' '' '' '' '3' '31' '' '' '' '' '' '' '' '' '' 'C' 'X'.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
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
                          VALUE(fu_key)
                          VALUE(fu_just)
                          VALUE(fu_no_zero).

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
  ld_fieldcat-key               = fu_key.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-no_zero           = fu_no_zero.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST'.
*  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'NAMA'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'URUTAN'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'DKLK'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_header(50),
        ld_header1(50),
        ld_header2(50),
        ld_header3(50).
  CASE 'X'.
    WHEN radio1.
      ld_header = 'Incentive Supervisor W&D'.
      CONCATENATE 'Cabang:' t_report-vkbur '-' t_report-bezei '(' va_zdelvp ')'
          INTO ld_header1 SEPARATED BY space.
      CONCATENATE 'Nama:' t_report-nama INTO ld_header2 SEPARATED BY space.
      CONCATENATE 'Bulan:' t_report-bulan INTO ld_header3 SEPARATED BY space.
    WHEN radio2.
      ld_header = 'Report Harian Delivery Man'.
      CONCATENATE 'Cabang:' t_report-vkbur '-' t_report-bezei '(' va_zdelvp ')'
          INTO ld_header1 SEPARATED BY space.
      CONCATENATE 'Nama:' t_report-nama INTO ld_header2 SEPARATED BY space.
      CONCATENATE 'Bulan:' t_report-bulan INTO ld_header3 SEPARATED BY space.
    WHEN radio3.
      CONCATENATE 'Cabang:' gt_report-vkbur '-' gt_report-bezei '(' va_zdelvp ')'
          INTO ld_header1 SEPARATED BY space.
      CONCATENATE 'Nama:' gt_report-nama INTO ld_header2 SEPARATED BY space.
      CONCATENATE 'Bulan:' gt_report-bulan INTO ld_header3 SEPARATED BY space.
  ENDCASE.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_header.
  PERFORM f_hdr_line2 USING ld_header1.
  PERFORM f_hdr_line3 USING ld_header2.
  PERFORM f_hdr_line4 USING ld_header3.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_text .
  PERFORM format_nama_file.
  PERFORM write_to_file.
  PERFORM mode777.
ENDFORM.                    " F_WRITE_TEXT

*&---------------------------------------------------------------------*
*&      Form  FORMAT_NAMA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_nama_file .
  CASE 'X'.
    WHEN radio1.
*      IF sy-opsys = 'AIX'.
      CONCATENATE pa_path1 '/Wnd/' pa_spmon '_' pa_vkorg '.txt'
            INTO va_filename.
*      ELSE.
*        CONCATENATE pa_path1 '\wnd\' pa_spmon '_' pa_vkorg '.txt'
*              INTO va_filename.
*      ENDIF.

    WHEN radio2 OR radio3.
*      IF sy-opsys = 'AIX'.
      CONCATENATE pa_path1 '/Driver/' pa_spmon '_' pa_vkorg '.txt'
            INTO va_filename.
*      ELSE.
*        CONCATENATE pa_path1 '\driver\' pa_spmon '_' pa_vkorg '.txt'
*              INTO va_filename.
*      ENDIF.
  ENDCASE.
ENDFORM.                    " FORMAT_NAMA_FILE

*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_to_file .
* Open Dataset Consolidation
  OPEN DATASET va_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DELETE DATASET va_filename.
    OPEN DATASET va_filename FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ELSE.
    OPEN DATASET va_filename FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ENDIF.

* Transfer to text
  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_detail.
        MOVE-CORRESPONDING gt_detail TO wa_detail.
        TRANSFER wa_detail TO va_filename.
      ENDLOOP.

    WHEN radio2 OR radio3.
      SORT gt_report BY vkbur nama urutan dklk.
      LOOP AT gt_report.
        TRANSFER gt_report TO va_filename.
      ENDLOOP.
  ENDCASE.

* Close Dataset Consolidation
  CLOSE DATASET va_filename.
ENDFORM.                    " WRITE_TO_FILE

*&---------------------------------------------------------------------*
*&      Form  MODE777
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mode777 .
  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl,
         l_command(125) TYPE c.

* Change Mode 777
  CLEAR l_command.
  CONCATENATE 'chmod 777' va_filename INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                                                    " MODE777

*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOFF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sloff .
  DATA: lr_vkbur TYPE RANGE OF vkbur WITH HEADER LINE.

  IF so_vkbur[] IS INITIAL.
    lr_vkbur-sign = 'I'.
    lr_vkbur-option = 'CP'.
    CASE pa_vkorg.
      WHEN '8010'.
        lr_vkbur-low = '01*'.
      WHEN '8020'.
        lr_vkbur-low = '02*'.
      WHEN '8030'.
        lr_vkbur-low = '03*'.
      WHEN '8070'.
        lr_vkbur-low = '07*'.
    ENDCASE.
    APPEND lr_vkbur.
  ELSE.
    LOOP AT so_vkbur.
      MOVE-CORRESPONDING so_vkbur TO lr_vkbur.
      APPEND lr_vkbur.
    ENDLOOP.
  ENDIF.

  SELECT * INTO TABLE gt_tvbur
    FROM tvbur WHERE vkbur IN lr_vkbur.
ENDFORM.                    " F_GET_SLOFF

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary_itab .
  CASE 'X'.
    WHEN radio1.
      APPEND LINES OF t_detail TO gt_detail.
    WHEN radio2 OR radio3.
      APPEND LINES OF t_report TO gt_report.
  ENDCASE.
ENDFORM.                    " F_SUMMARY_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_FREE_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_itab .
  REFRESH: t_itab,gr_vkbur,i_listbox,gt_tvkbt,i_tvst,t_report,
           gt_rayon,t_s629,t_s603,t_a777,t_holiday,t_vttk,t_vttp,t_likp,
           t_kna1,t_a511,t_a511x,t_a511y,i_result,i_result2,i_result3,
           i_bzirk,i_outpl3,i_cdpos,i_cdhdr,t_vttp,gt_lips,i_outpl3,t_avr.
  CLEAR: t_itab,gr_vkbur,i_listbox,gt_tvkbt,i_tvst,t_report,
         gt_rayon,t_s629,t_s603,t_a777,t_holiday,t_vttk,t_vttp,t_likp,
         t_kna1,t_a511,t_a511x,t_a511y,i_result,i_result2,i_result3,
         i_bzirk,i_outpl3,i_cdpos,i_cdhdr,t_vttp,gt_lips,i_outpl3,t_avr.

  CLEAR : t_detail, t_detail[].
  CLEAR : i_outpl6, i_outpl6[].
  CLEAR : i_slsdist, i_slsdist[].
ENDFORM.                    " F_FREE_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SPMON_BACKGROUND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_spmon_background .
  DATA : lv_datum   TYPE sy-datum.
  IF sy-batch <> 'X' AND sy-uzeit < '160000' AND out1 = 'X'.
    pa_spmon = sy-datum(6).
  ELSEIF sy-batch <> 'X' AND sy-uzeit < '160000'.
  ELSE.
    CONCATENATE sy-datum(6) '01' INTO lv_datum.
    lv_datum  = lv_datum - 1.
    pa_spmon = lv_datum(6).
  ENDIF.
ENDFORM.                    " F_CHANGE_SPMON_BACKGROUND

*&---------------------------------------------------------------------*
*&      Form  F_KDGRP04
*&---------------------------------------------------------------------*
FORM f_kdgrp04x .
  LOOP AT i_result INTO wa_result.
    IF wa_result-kdgrp = '04'.
      DELETE i_result.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " F_KDGRP04

*&---------------------------------------------------------------------*
*&      Form  F_INIT_RANGES_ZTYPE
*&---------------------------------------------------------------------*
FORM f_init_ranges_ztype .
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IK1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IK2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IK3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IO1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IO2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IO3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IS1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IS2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'IS3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WK1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WK2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WK3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WO1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WO2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WO3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WS1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WS2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'WS3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SK1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SK2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SK3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SO1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SO2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SO3'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SS1'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SS2'.
  APPEND ra_ztype . CLEAR ra_ztype.
  ra_ztype-sign = 'I'.
  ra_ztype-option = 'EQ'.
  ra_ztype-low = 'SS3'.
  APPEND ra_ztype . CLEAR ra_ztype.
ENDFORM.                    " F_INIT_RANGES_ZTYPE

*&---------------------------------------------------------------------*
*&      Form  F_NEW_DELIVERY_MAN
*&---------------------------------------------------------------------*
FORM f_new_delivery_man .
  DATA : lt_detail    LIKE t_detail OCCURS 0 WITH HEADER LINE,
         lv_t         TYPE p DECIMALS 2,
         lv_r         TYPE p DECIMALS 2,
         lv_rt        TYPE p DECIMALS 2,
         lv_rt2       LIKE a777-zminach,
         lv_subrc     LIKE sy-subrc,
         lv_count     TYPE numc2,
         lt_a777      LIKE t_a777 OCCURS 0 WITH HEADER LINE,
         lt_zmshphist TYPE STANDARD TABLE OF zmshphist,
         ls_zmshphist TYPE zmshphist,
         lr_zreason   TYPE RANGE OF zreason2,
         ls_zreason   LIKE LINE OF lr_zreason.

  FIELD-SYMBOLS: <fs_report> LIKE t_report.

  ls_zreason-low    = '51'.
  ls_zreason-high   = '53'.
  ls_zreason-sign   = 'I'.
  ls_zreason-option = 'BT'.
  APPEND ls_zreason TO lr_zreason.
  CLEAR ls_zreason.
  ls_zreason-low    = '58'.
  ls_zreason-sign   = 'I'.
  ls_zreason-option = 'EQ'.
  APPEND ls_zreason TO lr_zreason.
  CLEAR ls_zreason.

  lt_detail[]   = t_detail[].
  CLEAR : t_detail[], t_detail.

  lt_zmshphist[] = gt_zmshphist[].
  SORT lt_zmshphist BY tknum vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_zmshphist COMPARING tknum vbeln.

  SORT gt_zmshphist BY tknum vbeln zreason.

  LOOP AT t_vttk WHERE tplst = gt_tvkbt-vkbur
                   AND exti1 = i_listbox-exti1.
    LOOP AT lt_zmshphist INTO ls_zmshphist WHERE tknum = t_vttk-tknum.
      ADD 1 TO lv_t.
*      LOOP AT gt_zmshphist INTO gs_zmshphist WHERE tknum = ls_zmshphist-tknum
*                                               AND vbeln = ls_zmshphist-vbeln.
*        IF gs_zmshphist-zreason IN lr_zreason.
*          ADD 1 TO lv_r.
*        ENDIF.
*      ENDLOOP.
      lv_subrc = 4.
      lv_count = '50'.
      WHILE lv_subrc IS NOT INITIAL AND lv_count LT '58'.
        ADD 1 TO lv_count.
        IF lv_count = '54'.
          ADD 4 TO lv_count.
        ENDIF.
        PERFORM f_cek_delivered USING ls_zmshphist-tknum
                                      ls_zmshphist-vbeln
                                      lv_count
                                CHANGING lv_subrc
                                         lv_r.
      ENDWHILE.
    ENDLOOP.
  ENDLOOP.

  READ TABLE t_report ASSIGNING <fs_report> WITH KEY vkbur = gt_tvkbt-vkbur
                                                     nama  = i_listbox-exti1
                                                     urutan = '999'.
  IF sy-subrc = 0.
    WRITE lv_t TO <fs_report>-tottarget DECIMALS 0.
    WRITE lv_r TO <fs_report>-totaktual DECIMALS 0.
  ENDIF.
ENDFORM.                    " F_NEW_DELIVERY_MAN

*&---------------------------------------------------------------------*
*&      Form  F_CEK_DELIVERED
*&---------------------------------------------------------------------*
FORM f_cek_delivered  USING    fu_tknum
                               fu_vbeln
                               fu_reasn
                      CHANGING fc_subrc
                               fc_r.
  READ TABLE gt_zmshphist WITH KEY tknum = fu_tknum
                                   vbeln = fu_vbeln
                                   zreason = fu_reasn
                                   TRANSPORTING NO FIELDS
                                   BINARY SEARCH.
  IF sy-subrc = 0.
    ADD 1 TO fc_r.
  ENDIF.
  fc_subrc = sy-subrc.
ENDFORM.                    " F_CEK_DELIVERED

*&---------------------------------------------------------------------*
*&      Form  F_DELV_COUNT_KDGRP_CUST
*&---------------------------------------------------------------------*
FORM f_delv_count_kdgrp_cust  USING    fu_katr1 fu_kdgrp.
  DATA: ld_day(2)    TYPE n,
        ld_date      LIKE sy-datum,
        ld_zdelvp(3).

  DATA ls_zmshphist   LIKE LINE OF gt_zmshphist.

  WHILE ld_day LT va_datet+6(2).
    ld_day = ld_day + 1.
    CLEAR: t_holiday,ld_date,ld_zdelvp.
    CONCATENATE pa_spmon ld_day INTO ld_date.
    READ TABLE t_holiday WITH KEY date = ld_date.
    IF sy-subrc = 0.
      ld_zdelvp = 'X'.
    ELSE.
      LOOP AT t_vttk WHERE erdat = ld_date AND
                           tplst = gt_tvkbt-vkbur AND
                           exti1 = i_listbox-exti1.
        CLEAR: t_vttp,t_likp,t_kna1,t_a777.
        LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
          READ TABLE t_likp WITH KEY vbeln = t_vttp-vbeln.
          IF sy-subrc = 0.
            READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
                                       katr1 = fu_katr1
                                       kdgrp = fu_kdgrp.
            IF sy-subrc = 0.
              PERFORM f_count_hit_outlet USING t_vttk-tknum t_vttp-vbeln
                                         CHANGING ld_zdelvp.

*              READ TABLE gt_zmshphist WITH KEY tknum = t_vttk-tknum
*                                               vbeln = t_vttp-vbeln
*                                               zreason = c_51
*                                      TRANSPORTING NO FIELDS.
*              IF sy-subrc = 0.
*                ADD 1 TO ld_zdelvp.
*              ELSE.
*                READ TABLE gt_zmshphist WITH KEY tknum = t_vttk-tknum
*                                                 vbeln = t_vttp-vbeln
*                                                 zreason = c_52
*                                        TRANSPORTING NO FIELDS.
*                IF sy-subrc = 0.
*                  ADD 1 TO ld_zdelvp.
*                ENDIF.
*              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    PERFORM f_jumlah_pertanggal USING ld_day
                                      ld_zdelvp.
  ENDWHILE.
ENDFORM.                    " F_DELV_COUNT_KDGRP_CUST

*&---------------------------------------------------------------------*
*&      Form  F_DELV_COUNT_KVGR3_CUST
*&---------------------------------------------------------------------*
FORM f_delv_count_kvgr3_cust  USING    fu_katr1 fu_kvgr3.
  DATA: ld_day(2)    TYPE n,
        ld_date      LIKE sy-datum,
        ld_zdelvp(3).

  WHILE ld_day LT va_datet+6(2).
    ld_day = ld_day + 1.
    CLEAR: t_holiday,ld_date,ld_zdelvp.
    CONCATENATE pa_spmon ld_day INTO ld_date.
    READ TABLE t_holiday WITH KEY date = ld_date.
    IF sy-subrc = 0.
      ld_zdelvp = 'X'.
    ELSE.
      LOOP AT t_vttk WHERE erdat = ld_date AND
                           tplst = gt_tvkbt-vkbur AND
                           exti1 = i_listbox-exti1.
        CLEAR: t_vttp,t_likp,t_kna1,t_a777.
        LOOP AT t_vttp WHERE tknum = t_vttk-tknum.
          READ TABLE t_likp WITH KEY vbeln = t_vttp-vbeln.
          IF sy-subrc = 0.
            READ TABLE t_kna1 WITH KEY kunnr = t_likp-kunnr
                                       katr1 = fu_katr1
                                       kvgr3 = fu_kvgr3.
            IF sy-subrc = 0.
              READ TABLE gt_zmshphist WITH KEY tknum   = t_vttk-tknum
                                               vbeln   = t_vttp-vbeln
                                               zreason = c_51
                                      TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                ADD 1 TO ld_zdelvp.
              ELSE.
                READ TABLE gt_zmshphist WITH KEY tknum   = t_vttk-tknum
                                                 vbeln   = t_vttp-vbeln
                                                 zreason = c_52
                                        TRANSPORTING NO FIELDS.
                IF sy-subrc = 0.
                  ADD 1 TO ld_zdelvp.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    PERFORM f_jumlah_pertanggal USING ld_day
                                      ld_zdelvp.
  ENDWHILE.
ENDFORM.                    " F_DELV_COUNT_KVGR3_CUST

*&---------------------------------------------------------------------*
*&      Form  F_COUNT_HIT_OUTLET
*&---------------------------------------------------------------------*
FORM f_count_hit_outlet  USING    fu_tknum fu_vbeln
                         CHANGING fc_zdelvp.
  DATA ls_zmshphist   LIKE LINE OF gt_zmshphist.

  SORT gt_zmshphist BY tknum vbeln zcount DESCENDING.
  READ TABLE gt_zmshphist INTO ls_zmshphist
                          WITH KEY tknum = t_vttk-tknum
                                   vbeln = t_vttp-vbeln.
  IF ls_zmshphist-zreason = c_51 OR
    ls_zmshphist-zreason = c_52.
    ADD 1 TO fc_zdelvp.
  ENDIF.
ENDFORM.                    " F_COUNT_HIT_OUTLET

*&---------------------------------------------------------------------*
*&      Form  F_DAY_COLLECT_LEVEL
*&---------------------------------------------------------------------*
FORM f_day_collect_level  USING    fu_text fu_day
                          CHANGING fc_outpl3  LIKE wa_outpl3.

  CLEAR : wa_outpl3-0hari,wa_outpl3-1hari,wa_outpl3-2hari,wa_outpl3-3hari,
          wa_outpl3-4hari,wa_outpl3-total,wa_outpl3-06hari,wa_outpl3-07hari,
          wa_outpl3-08hari,wa_outpl3-09hari,wa_outpl3-10hari,wa_outpl3-00hari,
          wa_outpl3-11hari,wa_outpl3-total1,wa_outpl3-text.

  CASE fu_day.
    WHEN 0.
      wa_outpl3-0hari  = 1.
    WHEN 1.
      wa_outpl3-1hari  = 1.
    WHEN 2.
      wa_outpl3-2hari  = 1.
    WHEN 3.
      wa_outpl3-3hari  = 1.
    WHEN 999.
      wa_outpl3-4hari  = 1.
    WHEN OTHERS.
      wa_outpl3-4hari  = 1.
  ENDCASE.

  wa_outpl3-total = wa_outpl3-0hari + wa_outpl3-1hari + wa_outpl3-2hari +
                    wa_outpl3-3hari + wa_outpl3-4hari.

  IF fu_day LT 6.
    wa_outpl3-00hari  = 1.
  ENDIF.

  CASE fu_day.
    WHEN 6.
      wa_outpl3-06hari  = 1.
    WHEN 7.
      wa_outpl3-07hari  = 1.
    WHEN 8.
      wa_outpl3-08hari  = 1.
    WHEN 9.
      wa_outpl3-09hari  = 1.
    WHEN 10.
      wa_outpl3-10hari  = 1.
  ENDCASE.

  IF fu_day GT 10.
    wa_outpl3-11hari  = 1.
  ENDIF.

  wa_outpl3-total1 = wa_outpl3-00hari + wa_outpl3-06hari + wa_outpl3-07hari +
                    wa_outpl3-08hari + wa_outpl3-09hari + wa_outpl3-10hari +
                    wa_outpl3-11hari.

  wa_outpl3-text = fu_text.

  COLLECT wa_outpl3 INTO i_outpl3.
ENDFORM.                    " F_DAY_COLLECT_LEVEL

*&---------------------------------------------------------------------*
*&      Form  F_GET_S603_NEW
*&---------------------------------------------------------------------*
FORM f_get_s603_new .
  TYPES : BEGIN OF ty_soff,
            vkbur  TYPE tvbur-vkbur,
            zshvkb TYPE s603-zshvkb,
          END OF ty_soff.

  DATA : lt_s603 LIKE t_s603 OCCURS 0,
         ls_s603 LIKE LINE OF lt_s603.
  DATA : lt_mapp  TYPE STANDARD TABLE OF zsmapping_soff,
         ls_mapp  LIKE LINE OF lt_mapp,
         lt_soff  TYPE STANDARD TABLE OF ty_soff,
         ls_soff  LIKE LINE OF lt_soff,
         lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr,
         ls_zplbc LIKE LINE OF gt_zplbc.

  ls_matnr-low    = '000-00-00'.
  ls_matnr-high   = '999-99-99'.
  ls_matnr-sign   = 'E'.
  ls_matnr-option = 'BT'.
  APPEND ls_matnr TO lr_matnr.

  SELECT *
    FROM zsmapping_soff
    INTO CORRESPONDING FIELDS OF TABLE lt_mapp
    WHERE vkbur1  = gt_tvbur-vkbur.

  IF sy-subrc = 0.
    LOOP AT lt_mapp INTO ls_mapp.
      ls_soff-vkbur   = ls_mapp-vkbur1.
      ls_soff-zshvkb  = gt_tvbur-vkbur.
      APPEND ls_soff TO lt_soff.
      CLEAR ls_soff.
      ls_soff-vkbur   = ls_mapp-vkbur2.
      ls_soff-zshvkb  = gt_tvbur-vkbur.
      APPEND ls_soff TO lt_soff.
      CLEAR ls_soff.
    ENDLOOP.

    SORT lt_soff BY vkbur.
    DELETE ADJACENT DUPLICATES FROM lt_soff COMPARING vkbur.

    IF united IS NOT INITIAL.
      CLEAR ls_zplbc.
      READ TABLE gt_zplbc INTO ls_zplbc
                          WITH KEY reswk = gt_tvbur-vkbur.
      IF sy-subrc = 0.
        ls_soff-vkbur   = ls_zplbc-werks.
        ls_soff-zshvkb  = ls_zplbc-werks.
        APPEND ls_soff TO lt_soff.
        CLEAR ls_soff.
      ENDIF.
    ENDIF.

    SELECT ssour vrsio spmon sptag spwoc spbup pkunwe kvgr3 kdgrp
      vkbur zshvkb matnr prodh1 vkgrp pvrtnr zzroutel zxx zqnetsls
      umkzwi1 gukzwi1
      FROM s603
      INTO TABLE lt_s603
      FOR ALL ENTRIES IN lt_soff
      WHERE ssour  = ''
        AND vrsio  = '000'
        AND spmon  = pa_spmon
        AND sptag  = '00000000'
        AND spwoc  = '000000'
        AND spbup  = '000000'
        AND vkbur  = lt_soff-vkbur
        AND zshvkb = lt_soff-zshvkb.

    CLEAR : t_s603[].

    LOOP AT lt_s603 INTO ls_s603.
      IF ls_s603-matnr IN lr_matnr.
        CONTINUE.
      ENDIF.
      IF ls_s603-pkunwe(6) = 'TSB807' OR
        ls_s603-pkunwe(5) = 'TSB07'.
        CONTINUE.
      ELSE.
        APPEND ls_s603 TO t_s603.
      ENDIF.
      CLEAR ls_s603.
    ENDLOOP.
  ELSE.
    PERFORM f_get_s603.
  ENDIF.
ENDFORM.                    " F_GET_S603_NEW

*&---------------------------------------------------------------------*
*&      Form  F_GET_S603
*&---------------------------------------------------------------------*
FORM f_get_s603 .
  SELECT ssour vrsio spmon sptag spwoc spbup pkunwe kvgr3 kdgrp
         vkbur zshvkb matnr prodh1 vkgrp pvrtnr zzroutel zxx zqnetsls
         umkzwi1 gukzwi1
    INTO TABLE t_s603 FROM s603
    WHERE ssour = ''
      AND vrsio = '000'
      AND spmon = pa_spmon
      AND sptag = '00000000'
      AND spwoc = '000000'
      AND spbup = '000000'
      AND ( pkunwe NOT LIKE 'TSB807%' AND pkunwe NOT LIKE 'TSB07%' )
      AND vkbur IN ship_pnt
      AND matnr BETWEEN '000-00-00' AND '999-99-99'.
ENDFORM.                    " F_GET_S603

*&---------------------------------------------------------------------*
*&      Form  F_GET_DAYS
*&---------------------------------------------------------------------*
FORM f_get_days .
  DATA : lt_outpl6  LIKE wa_outpl6 OCCURS 0,
         lv_day(10),
         l_day      TYPE int4.

  lt_outpl6[] = i_outpl6[].
  SORT lt_outpl6 BY bzirk.
  DELETE ADJACENT DUPLICATES FROM lt_outpl6 COMPARING bzirk.

  LOOP AT lt_outpl6 INTO wa_outpl6.
    READ TABLE t_a511 WITH KEY zday1 = wa_outpl6-bzirk.
    IF sy-subrc EQ 0.
      lv_day  = t_a511-zday3 + t_a511-zday4 +
                t_a511-zday5.
    ELSE.
      CLEAR lv_day.
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
ENDFORM.                    " F_GET_DAYS

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_MODIFY
*&---------------------------------------------------------------------*
FORM f_field_modify .
  DATA : lt_zsextrec TYPE STANDARD TABLE OF zsextrec,
         ls_zsextrec LIKE LINE OF lt_zsextrec.

  SELECT tknum, shtyp, add04
    INTO TABLE @DATA(lt_vttk)
    FROM vttk FOR ALL ENTRIES IN @i_result
    WHERE tknum = @i_result-tknum.

  SELECT *
    FROM zsextrec
    INTO CORRESPONDING FIELDS OF TABLE lt_zsextrec
    FOR ALL ENTRIES IN i_result
    WHERE vbeln = i_result-vbeln.

  LOOP AT i_result INTO wa_result.
    wa_result-shtyp = VALUE #( lt_vttk[ tknum = wa_result-tknum ]-shtyp OPTIONAL ).
    CLEAR ls_zsextrec.
    READ TABLE lt_zsextrec INTO ls_zsextrec
                           WITH KEY vbeln = wa_result-vbeln.
    IF sy-subrc = 0 AND
       wa_result-shtyp = 'YN02' AND
       ( wa_result-bzirk = 'SLK3' OR wa_result-bzirk = 'SLK4' OR
         wa_result-bzirk = 'SLK5' OR wa_result-bzirk = 'SLK6' ).
      wa_result-cr2dt = ls_zsextrec-crdat.
      wa_result-cr2tm = ls_zsextrec-crtim.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-erdat_spgd
                                        wa_result-cr2tm wa_result-erzet_spgd
                               CHANGING wa_result-cr2_vs_spgd_dt
                                        wa_result-cr2_vs_spgd_tm.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-wadat_ist
                                        wa_result-cr2tm wa_result-gi_time
                               CHANGING wa_result-cr2_vs_gi_dt
                                        wa_result-cr2_vs_gi_tm.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-erdat
                                        wa_result-cr2tm wa_result-erzet
                               CHANGING wa_result-cr2_create_dt
                                        wa_result-cr2_create_tm.

    ELSE.
      wa_result-cr2dt           = wa_result-crdat.
      wa_result-cr2tm           = wa_result-crtim.
      wa_result-cr2_vs_spgd_dt  = wa_result-cr_vs_spgd_dt.
      wa_result-cr2_vs_spgd_tm  = wa_result-cr_vs_spgd_tm.
      wa_result-cr2_vs_gi_dt    = wa_result-cr_vs_gi_dt.
      wa_result-cr2_vs_gi_tm    = wa_result-cr_vs_gi_tm.
      wa_result-cr2_create_dt   = wa_result-cr_create_dt.
      wa_result-cr2_create_tm   = wa_result-cr_create_tm.
    ENDIF.
    MODIFY i_result FROM wa_result TRANSPORTING cr2_vs_spgd_dt
                                                cr2_vs_spgd_tm
                                                cr2_vs_gi_dt cr2_vs_gi_tm
                                                cr2_create_dt cr2_create_tm
                                                cr2dt cr2tm.
    CLEAR wa_result.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_date_calculate  USING    fu_date1 fu_date2 fu_time1 fu_time2
                       CHANGING fc_date fc_time.
  IF fu_date1 <> '00000000'.
    fc_date = fu_date1 - fu_date2.
    PERFORM f_get_holiday USING fu_date1 fu_date2
                          CHANGING fc_date.
    IF fu_time1 < fu_time2.
      fc_date = fc_date - 1.
    ENDIF.
  ELSE.
    fc_date = 999.
  ENDIF.

  IF fu_date1 <> '000000'.
    fc_time = fu_time1 - fu_time2.
  ENDIF.
ENDFORM.
