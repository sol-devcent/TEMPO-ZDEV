*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_kvgr3 LIKE t_s603key OCCURS 0 WITH HEADER LINE,
        l_knkli LIKE zscl_sm-knkli.

  DATA: lt_s603  LIKE t_s603 OCCURS 0 WITH HEADER LINE,
        lt_knvv  LIKE knvv OCCURS 0 WITH HEADER LINE.

* Get Detail
  SELECT a~vkbur pkunwe kdgrp kvgr3 spmon zclass umkzwi1 gukzwi1
    INTO CORRESPONDING FIELDS OF TABLE t_s603
    FROM s603 AS a JOIN zscl_class AS b ON a~vkbur = b~vkbur
*    WHERE vrsio EQ pa_vrsio  AND
*          spmon IN so_spmon  AND
*          a~vkbur IN so_vkbur  AND
*          pkunwe IN so_knkli.
     WHERE ssour = space
       AND vrsio = pa_vrsio
       AND spmon  IN so_spmon
       AND pkunwe IN so_knkli
*       AND kdgrp  IN sl_kdgrp
*       AND kvgr3  IN sl_kvgr3
       AND a~vkbur  IN so_vkbur.

* Modify Sales office
  lt_s603[] = t_s603[].
  SORT lt_s603[] BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM lt_s603 COMPARING pkunwe.
  IF lt_s603[] IS NOT INITIAL.
    SELECT kunnr vkbur
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE lt_knvv
      FOR ALL ENTRIES IN lt_s603
      WHERE kunnr EQ lt_s603-pkunwe
        AND vkorg EQ pa_vkorg
        AND vtweg EQ '10'.

    SORT t_s603 BY pkunwe.
    SORT lt_knvv BY kunnr.
    LOOP AT t_s603.
      READ TABLE lt_knvv WITH KEY kunnr = t_s603-pkunwe
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_s603-vkbur  = lt_knvv-vkbur.
        MODIFY t_s603 TRANSPORTING vkbur.
      ENDIF.
    ENDLOOP.
  ENDIF.
  REFRESH: lt_s603, lt_knvv.
  CLEAR: lt_s603, lt_knvv.

  SORT t_s603 BY pkunwe vkbur spmon DESCENDING.
  t_s603key[] = t_s603[].
  DELETE ADJACENT DUPLICATES FROM t_s603key COMPARING pkunwe vkbur.

  l_kvgr3[] = t_s603key[].
  SORT l_kvgr3 BY kvgr3.
  DELETE ADJACENT DUPLICATES FROM l_kvgr3 COMPARING kvgr3.

  IF t_s603key[] IS NOT INITIAL.
* Get Customer Group
    SELECT kunnr vkorg kdgrp kvgr3 a~zterm b~ztag1
      INTO CORRESPONDING FIELDS OF TABLE t_knvv
      FROM knvv AS a JOIN t052 AS b ON a~zterm = b~zterm
      FOR ALL ENTRIES IN t_s603key
      WHERE kunnr = t_s603key-pkunwe AND
            vkorg = pa_vkorg         AND
            vtweg = pa_vtweg         AND
            spart = pa_spart         AND
            vkbur IN so_vkbur.

* Get Customer
    SELECT kunnr sortl name1 erdat
    INTO CORRESPONDING FIELDS OF TABLE t_kna1
    FROM kna1
    FOR ALL ENTRIES IN t_s603key
    WHERE kunnr = t_s603key-pkunwe.

*Get Credit limit
    SELECT knkli kkber klimk
    INTO CORRESPONDING FIELDS OF TABLE t_knkk
    FROM knkk
    FOR ALL ENTRIES IN t_s603key
    WHERE knkli = t_s603key-pkunwe AND
          kkber IN so_kkber.

* Get Growth
*{   REPLACE        P01K910180                                        1
*\    SELECT *
*\    INTO CORRESPONDING FIELDS OF TABLE t_zscl_gro
*\    FROM zscl_gro
*\    WHERE vkorg = pa_vkorg.
    "Start SOH: Shell SCI Adjustment 20240221 KS
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_zscl_gro
    FROM zscl_gro
    WHERE vkorg = pa_vkorg ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE

* Get ZSCL_SM
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_zscl_sm
    FROM zscl_sm
    FOR ALL ENTRIES IN t_s603key
    WHERE gjahr = so_spmon-high(4)  AND
          zsmst = pa_zsmst          AND
          vkorg = pa_vkorg          AND
          vkbur = t_s603key-vkbur   AND
          knkli = t_s603key-pkunwe.
  ENDIF.

* req.by pak ZUL 13.06.2014
* jika punya bank Garansi, baca Garansi dan replace CL Hitungan dan User Release.
* Get Bank Garansi

  t_kdgrp[] = t_s603key[].
  t_knkli[] = t_s603key[].
  SORT t_kdgrp BY kdgrp.
  SORT t_knkli BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM t_kdgrp COMPARING kdgrp.
  DELETE t_kdgrp WHERE kdgrp EQ space.
  DELETE ADJACENT DUPLICATES FROM t_knkli COMPARING pkunwe.

  IF t_kdgrp[] IS NOT INITIAL.
    SELECT *
      FROM zsbankgrs
      INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_kdgrp
      FOR ALL ENTRIES IN t_kdgrp
      WHERE kdgrp EQ t_kdgrp-kdgrp.
  ENDIF.

  IF t_knkli[] IS NOT INITIAL.
    SELECT *
      FROM zsbankgrs
      INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
      FOR ALL ENTRIES IN t_knkli
      WHERE kunnr EQ t_knkli-pkunwe.
  ENDIF.

*  IF t_zscl_sm[] IS NOT INITIAL.
*    t_kdgrp[] = t_zscl_sm[].
*    t_knkli[] = t_zscl_sm[].
*    SORT t_kdgrp BY kdgrp.
*    SORT t_knkli BY knkli.
*    DELETE ADJACENT DUPLICATES FROM t_kdgrp COMPARING kdgrp.
*    DELETE t_kdgrp WHERE kdgrp EQ space.
*    DELETE ADJACENT DUPLICATES FROM t_knkli COMPARING knkli.
*
*    IF t_knkli[] IS NOT INITIAL.
*      SELECT *
*        FROM zsbankgrs
*        INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_kdgrp
*        FOR ALL ENTRIES IN t_kdgrp
*        WHERE kdgrp EQ t_kdgrp-kdgrp.
*      SELECT *
*        FROM zsbankgrs
*        INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
*        FOR ALL ENTRIES IN t_knkli
*        WHERE kunnr EQ t_knkli-knkli.
*    ENDIF.
*  ENDIF.

  SORT t_knvv BY kunnr.
  SORT t_kna1 BY kunnr.
  SORT t_knkk BY knkli.
  SORT t_zscl_sm BY knkli vkbur.
ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: l_date TYPE i,
        l_sw1(1),l_sw2(1),l_sw3(1),l_sw4(1),l_sw5(1),l_sw6(1).

  DATA: ld_klimk_hit  LIKE zscl_sm-klimk_hit,
        ld_gjahr LIKE zscl_sm-gjahr,
        ld_zsmst LIKE zscl_sm-zsmst.

  LOOP AT t_s603key.
    CLEAR: t_knvv,t_kna1,t_knkk,t_zscl_gro,t_zscl_sm,ld_gjahr,ld_zsmst.

    ld_gjahr = t_s603key-spmon(4) + 1.
*    IF t_s603key-spmon+4(2) >= '06'.
*      ld_zsmst = 1.
*    ELSE.
*      ld_zsmst = 2.
*    ENDIF.

* Baca ZSCL_SM.
    READ TABLE t_zscl_sm WITH KEY knkli = t_s603key-pkunwe
                                  vkbur = t_s603key-vkbur   "BINARY SEARCH.
                                  gjahr = ld_gjahr
                                  zsmst = pa_zsmst. "ld_zsmst.
    IF sy-subrc = 0.
      t_itab-reason = 'Data Sudah ada /'.
    ENDIF.

* Baca Cust Group
*{   REPLACE        P01K910180                                        1
*\    READ TABLE t_knvv WITH KEY kunnr = t_s603key-pkunwe BINARY SEARCH.
*\    IF sy-subrc NE 0.
*\      CONCATENATE 'err knvv' '/' INTO t_itab-reason SEPARATED BY space.
*\    ENDIF.
*\
*\* Baca Cust Name
*\    READ TABLE t_kna1 WITH KEY kunnr = t_s603key-pkunwe BINARY SEARCH.
*\    IF sy-subrc NE 0.
*\      CONCATENATE t_itab-reason 'kna1' '/' INTO t_itab-reason SEPARATED BY space.
*\    ENDIF.
*\
*\* Baca Growth
*\    READ TABLE t_zscl_gro WITH KEY kvgr3 = t_knvv-kvgr3 BINARY SEARCH.
*\    IF sy-subrc = 0.
*\      IF t_zscl_gro-top = 0.
*\        t_itab-top = t_knvv-ztag1.
*\      ELSE.
*\        t_itab-top = t_zscl_gro-top.
*\      ENDIF.
*\    ELSE.
*\      t_itab-top = t_knvv-ztag1.
*\*      CONCATENATE t_itab-reason 'zscl_gro' '/' INTO t_itab-reason SEPARATED BY space.
*\    ENDIF.
*\
*\* Baca Credit Limit
*\    READ TABLE t_knkk WITH KEY knkli = t_s603key-pkunwe BINARY SEARCH.
*\*    IF sy-subrc NE 0.
*\*      CONCATENATE t_itab-reason 'kna1' '/' INTO t_itab-reason SEPARATED BY space.
*\*    ENDIF.
    "Start SOH: Shell SCI Adjustment 20240221 KS
    SORT t_knvv BY kunnr.
    READ TABLE t_knvv WITH KEY kunnr = t_s603key-pkunwe BINARY SEARCH.
    IF sy-subrc NE 0.
      CONCATENATE 'err knvv' '/' INTO t_itab-reason SEPARATED BY space.
    ENDIF.

* Baca Cust Name
    SORT t_kna1 BY kunnr.
    READ TABLE t_kna1 WITH KEY kunnr = t_s603key-pkunwe BINARY SEARCH.
    IF sy-subrc NE 0.
      CONCATENATE t_itab-reason 'kna1' '/' INTO t_itab-reason SEPARATED BY space.
    ENDIF.

* Baca Growth
    SORT t_zscl_gro BY kvgr3.
    READ TABLE t_zscl_gro WITH KEY kvgr3 = t_knvv-kvgr3 BINARY SEARCH.
    IF sy-subrc = 0.
      IF t_zscl_gro-top = 0.
        t_itab-top = t_knvv-ztag1.
      ELSE.
        t_itab-top = t_zscl_gro-top.
      ENDIF.
    ELSE.
      t_itab-top = t_knvv-ztag1.
*      CONCATENATE t_itab-reason 'zscl_gro' '/' INTO t_itab-reason SEPARATED BY space.
    ENDIF.

* Baca Credit Limit
    SORT t_knkk BY knkli.
    READ TABLE t_knkk WITH KEY knkli = t_s603key-pkunwe BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CONCATENATE t_itab-reason 'kna1' '/' INTO t_itab-reason SEPARATED BY space.
*    ENDIF.
    "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE

* Hitung Sales 6 bulan
    CLEAR: t_s603,l_sw1(1),l_sw2(1),l_sw3(1),l_sw4(1),l_sw5(1),l_sw6(1).
    LOOP AT t_s603 WHERE vkbur = t_s603key-vkbur AND
                         pkunwe = t_s603key-pkunwe.
      CLEAR l_date.
      l_date = so_spmon-high - t_s603-spmon.
      CASE l_date.
        WHEN 0.
          t_itab-slsm6 = t_itab-slsm6 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw6 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            t_itab-count3 = t_itab-count3 + 1.
*            l_sw6 = 'X'.
*          ENDIF.
        WHEN 1 OR 89.
          t_itab-slsm5 = t_itab-slsm5 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw5 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            t_itab-count3 = t_itab-count3 + 1.
*            l_sw5 = 'X'.
*          ENDIF.
        WHEN 2 OR 90.
          t_itab-slsm4 = t_itab-slsm4 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw4 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            t_itab-count3 = t_itab-count3 + 1.
*            l_sw4 = 'X'.
*          ENDIF.
        WHEN 3 OR 91.
          t_itab-slsm3 = t_itab-slsm3 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw3 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            l_sw3 = 'X'.
*          ENDIF.
        WHEN 4 OR 92.
          t_itab-slsm2 = t_itab-slsm2 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw2 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            l_sw2 = 'X'.
*          ENDIF.
        WHEN 5 OR 93.
          t_itab-slsm1 = t_itab-slsm1 + ( t_s603-umkzwi1 + t_s603-gukzwi1 ).
*          IF l_sw1 IS INITIAL AND ( t_s603-umkzwi1 IS NOT INITIAL OR t_s603-gukzwi1 IS NOT INITIAL ).
*            t_itab-count6 = t_itab-count6 + 1.
*            l_sw1 = 'X'.
*          ENDIF.
      ENDCASE.
    ENDLOOP.

* Hitung Count 6 & 3 bulan
    CLEAR: t_itab-count3, t_itab-count6.
    IF t_itab-slsm1 NE 0.
      ADD 1 TO t_itab-count6.
    ENDIF.
    IF t_itab-slsm2 NE 0.
      ADD 1 TO t_itab-count6.
    ENDIF.
    IF t_itab-slsm3 NE 0.
      ADD 1 TO t_itab-count6.
    ENDIF.
    IF t_itab-slsm4 NE 0.
      ADD 1 TO t_itab-count6.
      ADD 1 TO t_itab-count3.
    ENDIF.
    IF t_itab-slsm5 NE 0.
      ADD 1 TO t_itab-count6.
      ADD 1 TO t_itab-count3.
    ENDIF.
    IF t_itab-slsm6 NE 0.
      ADD 1 TO t_itab-count6.
      ADD 1 TO t_itab-count3.
    ENDIF.

    t_itab-spmon = so_spmon-high.
    t_itab-vkorg = pa_vkorg.
    t_itab-vkbur = t_s603key-vkbur.
    t_itab-kkber = so_kkber-low. "'8000'. " t_knkk-kkber.
    t_itab-knkli = t_s603key-pkunwe.
    t_itab-sortl = t_kna1-sortl.
    t_itab-name1 = t_kna1-name1.
    t_itab-kdgrp = t_knvv-kdgrp.
    t_itab-kvgr3 = t_knvv-kvgr3.
    t_itab-klimk = t_knkk-klimk.
    t_itab-waers = 'IDR'.
    t_itab-total6 = t_itab-slsm1 + t_itab-slsm2 + t_itab-slsm3 +
                    t_itab-slsm4 + t_itab-slsm5 + t_itab-slsm6.
    t_itab-total3 = t_itab-slsm4 + t_itab-slsm5 + t_itab-slsm6.
    IF t_itab-count6 NE 0.
      t_itab-avrg6 = t_itab-total6 / t_itab-count6.
    ENDIF.
    IF t_itab-count3 NE 0.
      t_itab-avrg3 = t_itab-total3 / t_itab-count3.
    ENDIF.

    IF t_itab-slsm1 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm1.
    ENDIF.
    IF t_itab-slsm2 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm2.
    ENDIF.
    IF t_itab-slsm3 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm3.
    ENDIF.
    IF t_itab-slsm4 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm4.
    ENDIF.
    IF t_itab-slsm5 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm5.
    ENDIF.
    IF t_itab-slsm6 GT t_itab-maxval.
      t_itab-maxval = t_itab-slsm6.
    ENDIF.
    t_itab-gro = t_zscl_gro-gro.
*    t_itab-top = t_zscl_gro-top.
    t_itab-hist = ( t_itab-avrg6 * pa_6bl / 100 ) +
                  ( t_itab-avrg3 * pa_3bl / 100 ) +
                  ( t_itab-maxval * pa_max / 100 ).
    t_itab-klimk_hit = ( t_itab-hist * t_itab-top / 30 ) * t_itab-gro / 100.
    IF t_itab-klimk_hit <= 0.
      t_itab-klimk_hit = 1 / 100.
    ENDIF.

* Validasi untuk bank garansi.
    LOOP AT t_zsbankgrs_knkli WHERE kunnr EQ t_s603key-pkunwe.
      IF t_zsbankgrs_knkli-valid_to GE sy-datum AND t_zsbankgrs_knkli-valid_fr LE sy-datum.
        ADD t_zsbankgrs_knkli-wrbtr TO ld_klimk_hit.
      ENDIF.
    ENDLOOP.
    IF sy-subrc EQ 0.
      IF t_itab-klimk_hit GT ld_klimk_hit.
        t_itab-klimk_hit = ld_klimk_hit.
      ENDIF.
    ELSE.
      LOOP AT t_zsbankgrs_kdgrp WHERE kdgrp EQ t_s603key-kdgrp.
        IF t_zsbankgrs_kdgrp-valid_to GE sy-datum AND t_zsbankgrs_kdgrp-valid_fr LE sy-datum.
          ADD t_zsbankgrs_kdgrp-wrbtr TO ld_klimk_hit.
        ENDIF.
      ENDLOOP.
      IF sy-subrc EQ 0.
        IF t_itab-klimk_hit GT ld_klimk_hit.
          t_itab-klimk_hit = ld_klimk_hit.
        ENDIF.
      ENDIF.
    ENDIF.
*-----------

    IF t_kna1 IS NOT INITIAL AND t_knkk IS NOT INITIAL.
      DATA(lv_days) = sy-datum - t_kna1-erdat.
      IF lv_days LE 90.
        t_itab-klimk_hit = 1 / 100.
      ENDIF.
    ENDIF.

    t_itab-klimk_usl = t_itab-klimk_hit.
    t_itab-zsmst = pa_zsmst.
    t_itab-gjahr = pa_gjahr.
*    IF pa_zsmst = '1'.
*      t_itab-gjahr = so_spmon-high(4) + 1.
*    ELSE.
*      t_itab-gjahr = so_spmon-high(4).
*    ENDIF.
**** Perubahan CL Semester sesuai dengan kep dir 2013
*    SELECT SINGLE zgol INTO t_itab-zgol
*      FROM zscl_level
*      WHERE ztype = 'CL' AND
*            zvalue > t_itab-klimk_usl.
    DATA: l_sw(1).
    l_sw = 0.

    SELECT SINGLE usrgroup usrgroup2 usrgroup3
      INTO (t_itab-usergroup1, t_itab-usergroup2, t_itab-usergroup3)
      FROM zscl_kredit
      WHERE zvalue > t_itab-klimk_usl AND
            usrgroup = 'BM'.
    IF sy-subrc NE 0.
      SELECT SINGLE usrgroup usrgroup2 usrgroup3
        INTO (t_itab-usergroup1, t_itab-usergroup2, t_itab-usergroup3)
        FROM zscl_kredit
        WHERE zvalue > t_itab-klimk_usl AND
              usrgroup NOT LIKE 'BM%'.
    ENDIF.

    CONDENSE t_itab-usergroup1.
    CONDENSE t_itab-usergroup2.
    CONDENSE t_itab-usergroup3.

    IF t_itab-usergroup3 IS NOT INITIAL.
      CONCATENATE t_itab-usergroup1  t_itab-usergroup2  t_itab-usergroup3
        INTO t_itab-zgol SEPARATED BY '&'.
    ELSEIF t_itab-usergroup2 IS NOT INITIAL.
      CONCATENATE t_itab-usergroup1  t_itab-usergroup2
        INTO t_itab-zgol SEPARATED BY '&'.
    ELSE.
      t_itab-zgol = t_itab-usergroup1.
    ENDIF.

    IF t_itab-reason IS NOT INITIAL.
      t_itab_err = t_itab.
      APPEND t_itab_err.
    ELSE.
      APPEND t_itab.
    ENDIF.
    CLEAR: t_itab, t_itab_err, ld_klimk_hit.
  ENDLOOP.

ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_itab.
ENDFORM.                    "f_print_data

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

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'VKBUR' 'S603' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'KNKLI' 'ZSCL_SM' 'KNKLI' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'SORTL' 'KNA1' 'SORTL' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'KDGRP' 'S603' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'S603' 'KVGR3' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLSM1' '' '' '' '17' 'SLSM M1' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM2' '' '' '' '17' 'SLSM M2' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM3' '' '' '' '17' 'SLSM M3' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM4' '' '' '' '17' 'SLSM M4' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM5' '' '' '' '17' 'SLSM M5' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM6' '' '' '' '17' 'SLSM M6' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL6' '' '' '' '17' 'Total 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL3' '' '' '' '17' 'Total 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'COUNT6' '' '' '' '6' 'Count6bl' '' '' '' '' '' '' '' '' '' '',
    'COUNT3' '' '' '' '6' 'Count3bl' '' '' '' '' '' '' '' '' '' '',
    'AVRG6' '' '' '' '17' 'Average 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'AVRG3' '' '' '' '17' 'Average 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'MAXVAL' '' '' '' '17' 'Max Value' '' '' '' '' '' 'WAERS' '' '' '' '',
    'HIST' '' '' '' '17' 'History' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK' '' '' '' '17' 'Current CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'GRO' '' '' '' '7' 'Growth' '' '' '' '' '' '' '' '' '' '',
    'TOP' '' '' '' '7' 'TOP' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_HIT' '' '' '' '17' 'New CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL' '' '' '' '17' 'Usul CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL%' '' '' '' '10' 'Usul CL %' '' '' '' '' '' '' '' '' '' '',
    'REASON' '' '' '' '30' 'Reason' '' '' '' '' '' '' '' '' '' ''.
*    'USULKP' '' '' '' '17' 'Usulan KP' '' '' '' 'IDR' '' '' '' '' '' '',
*    'USULKP%' '' '' '' '17' 'Usulan KP %' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_key).

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
  ld_fieldcat-key               = fu_key.
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
  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KNKLI'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_period(40),
        l_spmon1(7),
        l_spmon2(7),
        l_vkbur(40).

  WRITE so_spmon-low TO l_spmon1.
  WRITE so_spmon-high TO l_spmon2.
  CONCATENATE 'Period:' l_spmon1 'to' l_spmon2 INTO l_period SEPARATED BY space.

  SELECT SINGLE bezei INTO l_vkbur FROM tvkbt
    WHERE spras = sy-langu     AND
          vkbur = t_itab-vkbur.
  CONCATENATE 'SlOff:' t_itab-vkbur l_vkbur INTO l_vkbur SEPARATED BY space.

  PERFORM f_hdr_uline.
  IF ok_code = '&CONF'.
    PERFORM f_hdr_line1 USING 'Confirm Usulan CL Semester'.
  ELSE.
    PERFORM f_hdr_line1 USING sy-title.
  ENDIF.
  PERFORM f_hdr_line2 USING l_period.
  PERFORM f_hdr_line3 USING l_vkbur.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

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
  REFRESH: t_itab, t_s603key, t_s603, t_knvv, t_kna1, t_knkk, t_zscl_gro.
  CLEAR: t_itab, t_s603key, t_s603, t_knvv, t_kna1, t_knkk, t_zscl_gro.
ENDFORM.                    " F_FREE_MEMORY
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
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  CLEAR ok_code.
  ok_code = fu_ucomm.

  CASE fu_ucomm.
    WHEN '&IC1'.
      PERFORM f_usulan USING fu_selfield.
    WHEN '&SAV'.
      PERFORM f_post_entries.
    WHEN '&CONF'.
      PERFORM f_confirm.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  init_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_screen .
  DATA: l_date LIKE sy-datum.
*** Credit control area
*  so_kkber-low    = '8000'.
*  so_kkber-sign   = 'I'.
*  so_kkber-option = 'EQ'.
*  APPEND so_kkber.
** Period
  CALL FUNCTION 'Z_CALC_DATE'
    EXPORTING
      date      = sy-datum
      days      = '0'
      months    = '5'
      sign      = '-'
      years     = '0'
    IMPORTING
      calc_date = l_date.
  so_spmon-low    = l_date(6).
  so_spmon-high   = sy-datum(6).
  so_spmon-sign   = 'I'.
  so_spmon-option = 'BT'.
  APPEND so_spmon.
ENDFORM.                    " init_screen

*&---------------------------------------------------------------------*
*&      Form  f_update_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_table .
  IF t_itab[] IS NOT INITIAL.
    MODIFY zscl_sm FROM TABLE t_itab.
    IF sy-subrc = 0.
      DESCRIBE TABLE t_itab LINES va_update.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_update_table

*&---------------------------------------------------------------------*
*&      Form  f_write_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_error .
  LOOP AT t_itab_err.
    WRITE: /(4) t_itab_err-gjahr,
            (4) t_itab_err-zsmst,
            (5) t_itab_err-vkorg,
            (5) t_itab_err-vkbur,
            (4) t_itab_err-kdgrp,
            (4) t_itab_err-kvgr3,
           (12) t_itab_err-knkli,
           (12) t_itab_err-sortl,
           (30) t_itab_err-name1,
           (15) t_itab_err-klimk,
           (30) t_itab_err-reason.
  ENDLOOP.
  DESCRIBE TABLE t_itab_err LINES va_error.
  SKIP 3.
  WRITE: / 'Record update:', va_update.
  WRITE: / 'Record error :', va_error.
ENDFORM.                    " f_write_error

*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header .
  WRITE: /(135) 'Error List' CENTERED.
  WRITE: / sy-uline(135).
  WRITE: /(4) 'Tahun',
          (4) 'Quar',
          (5) 'SlOrg',
          (5) 'SlOff',
          (4) 'CGrp',
          (4) 'CSGr',
         (12) 'Customer',
         (12) 'Lgc Code',
         (30) 'Customer Name',
         (15) 'Credit Limit',
         (30) 'Err Reason'.
  WRITE: / sy-uline(135).
ENDFORM.                    " f_write_header
