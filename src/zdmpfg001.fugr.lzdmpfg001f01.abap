*----------------------------------------------------------------------*
***INCLUDE LZDMPFG001F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_POST_COR6N
*&---------------------------------------------------------------------*
FORM f_post_cor6n  TABLES   ft_lines STRUCTURE tline
                   USING    fu_json
                   CHANGING fc_message.
  DATA: lv_json_data TYPE string,
        ls_yield     TYPE ty_yield.

  lv_json_data = fu_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_yield ).

*  PERFORM f_insert_afru USING ls_yield
*                        CHANGING fc_message.

  PERFORM f_run_bapi TABLES   ft_lines
                     USING    ls_yield
                     CHANGING fc_message.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_SHOW_MESSAGE
*&---------------------------------------------------------------------*
FORM f_show_message  USING    fs_bdcmsg   STRUCTURE bdcmsgcoll
                     CHANGING fc_msgv.
  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      id         = fs_bdcmsg-msgid
      no         = fs_bdcmsg-msgnr
      v1         = fs_bdcmsg-msgv1
      v2         = fs_bdcmsg-msgv2
      v3         = fs_bdcmsg-msgv3
      v4         = fs_bdcmsg-msgv4
    IMPORTING
      msg        = fc_msgv
    EXCEPTIONS
      nofs_found = 1
      OTHERS     = 2.
ENDFORM.                    " F_SHOW_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_AFRU
*&---------------------------------------------------------------------*
FORM f_insert_afru  USING    fs_yield STRUCTURE gs_yield
                    CHANGING fc_message.
  DATA: lt_afru TYPE TABLE OF afru.

  SELECT SINGLE * INTO @DATA(ls_afvc)
    FROM afvc WHERE aufpl = @fs_yield-aufpl
                AND vornr = @fs_yield-vornr.

  SELECT MAX( rmzhl ) INTO @DATA(lv_rmzhl)
    FROM afru WHERE rueck = @ls_afvc-rueck.

  ADD 1 TO lv_rmzhl.

  APPEND INITIAL LINE TO lt_afru ASSIGNING FIELD-SYMBOL(<fs_afru>).
  <fs_afru>-rueck   = ls_afvc-rueck.
  <fs_afru>-rmzhl   = lv_rmzhl.
  <fs_afru>-ernam   = sy-uname.
  <fs_afru>-ersda   = sy-datum.
  <fs_afru>-budat   = fs_yield-budat.
  <fs_afru>-arbid   = ls_afvc-arbid.
  <fs_afru>-werks   = ls_afvc-werks.
  <fs_afru>-ltxa1   = ls_afvc-ltxa1.
  <fs_afru>-txtsp   = ls_afvc-txtsp.
  <fs_afru>-ile01   = 'MIN'.
  <fs_afru>-ism01   = 0.
  <fs_afru>-ile02   = 'STD'.
  <fs_afru>-ism02   = fs_yield-mhour.
  <fs_afru>-ile03   = 'STD'.
  <fs_afru>-ism03   = fs_yield-lhour.
  <fs_afru>-ile04   = 'PRS'.
  <fs_afru>-ism04   = 0.
  <fs_afru>-lmnga   = fs_yield-yield.
  <fs_afru>-meinh   = fs_yield-meins.
  <fs_afru>-isdd    = fs_yield-dates_opr.
  <fs_afru>-isdz    = fs_yield-times_opr.
  <fs_afru>-iedd    = fs_yield-datef.
  <fs_afru>-iedz    = fs_yield-timef.
  <fs_afru>-aufnr   = fs_yield-aufnr.
  <fs_afru>-aufpl   = fs_yield-aufpl.
  <fs_afru>-aplzl   = fs_yield-aplzl.
  <fs_afru>-aplfl   = ls_afvc-aplfl.
  <fs_afru>-vornr   = fs_yield-vornr.
  <fs_afru>-erzet   = sy-uzeit.

  INSERT afru FROM TABLE lt_afru.

  IF sy-subrc = 0.
    CONCATENATE 'No. Confirmation' ls_afvc-rueck 'Posted'
      INTO fc_message SEPARATED BY space.
  ELSE.
    fc_message = 'ERROR'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RUN_BAPI
*&---------------------------------------------------------------------*
FORM f_run_bapi  TABLES   ft_lines STRUCTURE tline
                 USING    fs_yield STRUCTURE gs_yield
                 CHANGING fc_message.
  DATA: return           LIKE  bapiret1,
        timetickets      TYPE TABLE OF bapi_pi_timeticket1,
        lt_detail_return TYPE TABLE OF bapi_coru_return.

  SELECT SINGLE * INTO @DATA(ls_afvc)
    FROM afvc WHERE aufpl = @fs_yield-aufpl
                AND vornr = @fs_yield-vornr.
  IF sy-subrc = 0.
    ADD 1 TO ls_afvc-rmzhl.
  ENDIF.

  APPEND INITIAL LINE TO timetickets ASSIGNING FIELD-SYMBOL(<fs_tt>).
  <fs_tt>-conf_no           = ls_afvc-rueck.
  <fs_tt>-orderid           = fs_yield-aufnr.
  <fs_tt>-phase             = fs_yield-vornr.
  <fs_tt>-fin_conf          = 'X'.
  <fs_tt>-clear_res         = 'X'.
  <fs_tt>-postg_date        = fs_yield-budat.
  IF fs_yield-ltxa1 IS INITIAL.
    <fs_tt>-conf_text       = ls_afvc-ltxa1.
  ELSE.
    <fs_tt>-conf_text       = fs_yield-ltxa1.
  ENDIF.
  <fs_tt>-plant             = ls_afvc-werks.
  <fs_tt>-recordtype        = 'L40'.
  <fs_tt>-conf_quan_unit    = fs_yield-meins.
  <fs_tt>-yield             = fs_yield-yield.
  <fs_tt>-conf_acti_unit1   = 'MIN'.
  <fs_tt>-conf_activity1    = 0.
  <fs_tt>-conf_acti_unit2   = 'STD'.
  <fs_tt>-conf_activity2    = fs_yield-mhour.
  <fs_tt>-conf_acti_unit3   = 'STD'.
  <fs_tt>-conf_activity3    = fs_yield-lhour.
  <fs_tt>-conf_acti_unit4   = 'PRS'.
  <fs_tt>-conf_activity4    = 0.
  <fs_tt>-exec_start_date   = fs_yield-dates_opr.
  <fs_tt>-exec_start_time   = fs_yield-times_opr.
*  <fs_tt>-exec_fin_date     = fs_yield-datef.
*  <fs_tt>-exec_fin_time     = fs_yield-timef.

*  SELECT SINGLE aufnr, vornr,
*                MAX( actwh ) AS actwh_max,
*                MAX( datef ) AS datef_max,
*                MAX( timef ) AS timef_max
*    INTO @DATA(ls_ztspppdt014)
*    FROM ztspppdt014 WHERE aufnr = @fs_yield-aufnr
*                       AND vornr = @fs_yield-vornr
*    GROUP BY aufnr, vornr.
  SELECT DISTINCT aufnr, vornr, actwh, datef, timef
    INTO TABLE @DATA(lt_ztspppdt014)
    FROM ztspppdt014 WHERE aufnr = @fs_yield-aufnr
                       AND vornr = @fs_yield-vornr
    ORDER BY aufnr, vornr, actwh DESCENDING,
             datef DESCENDING, timef DESCENDING.
  IF sy-subrc = 0.
    DATA(ls_ztspppdt014)  = lt_ztspppdt014[ 1 ].
    <fs_tt>-exec_fin_date = ls_ztspppdt014-datef.
    <fs_tt>-exec_fin_time = ls_ztspppdt014-timef.
  ENDIF.

  CALL FUNCTION 'BAPI_PROCORDCONF_CREATE_TT'
*    EXPORTING
*      testrun     = 'X'
    IMPORTING
      return        = return
    TABLES
      timetickets   = timetickets
      detail_return = lt_detail_return.

  IF sy-subrc = 0.
    IF return-type = 'E'.
*      fc_message = 'ERROR'.
      fc_message = |ERROR| && | | && lt_detail_return[ 1 ]-message.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      PERFORM f_insert_ztspppdt012 USING fs_yield.
      PERFORM f_save_text TABLES ft_lines
                          USING  ls_afvc-rueck ls_afvc-rmzhl.

      CONCATENATE 'No. Confirmation' ls_afvc-rueck 'Posted'
        INTO fc_message SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_ZTSPPPDT012
*&---------------------------------------------------------------------*
FORM f_insert_ztspppdt012  USING    fs_yield STRUCTURE gs_yield.
  DATA: lt_ztspppdt012 TYPE TABLE OF ztspppdt012.

  SELECT SINGLE * INTO @DATA(ls_afvc)
    FROM afvc WHERE aufpl = @fs_yield-aufpl
                AND vornr = @fs_yield-vornr.

  APPEND INITIAL LINE TO lt_ztspppdt012 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt012>).
  <fs_ztspppdt012>-aufpl    = fs_yield-aufpl.
  <fs_ztspppdt012>-aplzl    = fs_yield-aplzl.
  <fs_ztspppdt012>-stats    = fs_yield-stats.
  <fs_ztspppdt012>-vornr    = fs_yield-vornr.
*  <fs_ztspppdt012>-actwh    = fs_yield-actwh.
  <fs_ztspppdt012>-aufnr    = fs_yield-aufnr.
*  <fs_ztspppdt012>-werks    = ls_afvc-werks.
*  <fs_ztspppdt012>-ltxa1    = ls_afvc-ltxa1.
  <fs_ztspppdt012>-rooms    = fs_yield-rooms.
  <fs_ztspppdt012>-dates    = fs_yield-dates_conf.
  <fs_ztspppdt012>-times    = fs_yield-times_conf.
  <fs_ztspppdt012>-datef    = fs_yield-datef.
  <fs_ztspppdt012>-timef    = fs_yield-timef.
  <fs_ztspppdt012>-operator = fs_yield-operator.
  <fs_ztspppdt012>-pengawas = fs_yield-pengawas.

  INSERT ztspppdt012 FROM TABLE lt_ztspppdt012.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_HOUR
*&---------------------------------------------------------------------*
FORM f_get_hour  USING    fu_json
                 CHANGING fc_second.
  DATA: lv_json_data TYPE string,
        ls_yield     TYPE ty_yield.

  DATA: lv_stats  TYPE zstats_dmp,
        lv_lines  TYPE sy-tabix,
        lv_second TYPE int4,
        lv_dates  TYPE datum,
        lv_times  TYPE uzeit,
        lv_datef  TYPE datum,
        lv_timef  TYPE uzeit.

  DATA: lv_timestamp1 TYPE tzntstmps,
        lv_timestamp2 TYPE tzntstmps.

  lv_json_data = fu_json.
  zcl_json=>deserialize( EXPORTING json = lv_json_data
                         CHANGING  data = ls_yield ).

  SELECT SINGLE phseq INTO @DATA(lv_phseq)
    FROM afvc WHERE aufpl = @ls_yield-aufpl
                AND vornr = @ls_yield-vornr
                AND steus = 'ZP01'.
  IF sy-subrc = 0.
    lv_phseq(1) = 'W'.
    SELECT aufpl, aplzl, vornr, phseq, steus, ltxa1
      INTO TABLE @DATA(lt_afvc)
      FROM afvc WHERE aufpl = @ls_yield-aufpl
                  AND phseq = @lv_phseq
                  AND steus = 'ZP01'.

    SELECT * INTO TABLE @DATA(lt_ztspppdt012)
      FROM ztspppdt012 FOR ALL ENTRIES IN @lt_afvc
      WHERE aufpl = @ls_yield-aufpl
        AND aplzl = @ls_yield-aplzl
        AND vornr = @ls_yield-vornr
        AND actwh = @lt_afvc-vornr
        AND stats LIKE '003%'
      ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      SELECT * INTO TABLE @DATA(lt_ztspppdt014)
        FROM ztspppdt014 FOR ALL ENTRIES IN @lt_ztspppdt012
        WHERE aufnr = @lt_ztspppdt012-aufnr
          AND vornr = @lt_ztspppdt012-vornr
          AND actwh = @lt_ztspppdt012-actwh
        ORDER BY PRIMARY KEY.

      SELECT * INTO TABLE @DATA(lt_ztspppdt015)
        FROM ztspppdt015 FOR ALL ENTRIES IN @lt_ztspppdt012
        WHERE aufnr = @lt_ztspppdt012-aufnr
          AND vornr = @lt_ztspppdt012-vornr
          AND actwh = @lt_ztspppdt012-actwh
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  SORT lt_ztspppdt014 BY aufnr vornr actwh erdat ertim.
  SORT lt_ztspppdt015 BY aufnr vornr actwh erdat ertim.

  lv_lines = lines( lt_ztspppdt012 ).

  LOOP AT lt_ztspppdt012 INTO DATA(ls_ztspppdt012).
    CLEAR: lv_dates,lv_times,lv_datef,lv_timef,lv_second,
           lv_timestamp1,lv_timestamp2.

    IF sy-tabix LT lv_lines.
      DATA(lv_index) = sy-tabix + 1.
      DATA(ls_ztspppdt012_nx) = lt_ztspppdt012[ lv_index ].
    ENDIF.

    lv_dates = ls_ztspppdt012-dates.
    lv_times = ls_ztspppdt012-times.
*    lv_datef = lt_ztspppdt014[ aufnr = ls_ztspppdt012-aufnr
*                               vornr = ls_ztspppdt012-vornr
*                               actwh = ls_ztspppdt012-actwh ]-erdat.
*    lv_timef = lt_ztspppdt014[ aufnr = ls_ztspppdt012-aufnr
*                               vornr = ls_ztspppdt012-vornr
*                               actwh = ls_ztspppdt012-actwh ]-ertim.

    READ TABLE lt_ztspppdt014 INTO DATA(ls_ztspppdt014)
                              WITH KEY aufnr = ls_ztspppdt012-aufnr
                                       vornr = ls_ztspppdt012-vornr
                                       actwh = ls_ztspppdt012-actwh.
    IF sy-subrc = 0.
      PERFORM f_get_timestamp USING ls_ztspppdt014-erdat
                                    ls_ztspppdt014-ertim
                              CHANGING lv_timestamp1.
    ENDIF.

    READ TABLE lt_ztspppdt015 INTO DATA(ls_ztspppdt015)
                              WITH KEY aufnr = ls_ztspppdt012-aufnr
                                       vornr = ls_ztspppdt012-vornr
                                       actwh = ls_ztspppdt012-actwh.
    IF sy-subrc = 0.
      PERFORM f_get_timestamp USING ls_ztspppdt015-erdat
                                    ls_ztspppdt015-ertim
                              CHANGING lv_timestamp2.
    ENDIF.

    IF lv_timestamp1 IS NOT INITIAL AND lv_timestamp2 IS NOT INITIAL.
      IF lv_timestamp1 LE lv_timestamp2.
        lv_datef = ls_ztspppdt014-erdat.
        lv_timef = ls_ztspppdt014-ertim.
      ELSE.
        lv_datef = ls_ztspppdt015-erdat.
        lv_timef = ls_ztspppdt015-ertim.
      ENDIF.
    ELSEIF lv_timestamp1 IS NOT INITIAL AND lv_timestamp2 IS INITIAL.
      lv_datef = ls_ztspppdt014-erdat.
      lv_timef = ls_ztspppdt014-ertim.
    ELSEIF lv_timestamp1 IS INITIAL AND lv_timestamp2 IS NOT INITIAL.
      lv_datef = ls_ztspppdt015-erdat.
      lv_timef = ls_ztspppdt015-ertim.
    ENDIF.

    IF lv_index LE lv_lines AND lv_index IS NOT INITIAL.
      IF ls_ztspppdt012_nx-dates LT lv_datef.
        lv_datef = ls_ztspppdt012_nx-dates.
        lv_timef = ls_ztspppdt012_nx-times.
      ELSEIF ls_ztspppdt012_nx-times LT lv_timef.
        lv_timef = ls_ztspppdt012_nx-times.
      ENDIF.
    ENDIF.

    IF lv_dates IS NOT INITIAL AND
       lv_times IS NOT INITIAL AND
       lv_datef IS NOT INITIAL AND
       lv_timef IS NOT INITIAL.
      CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
        EXPORTING
          date_1  = lv_dates
          time_1  = lv_times
          date_2  = lv_datef
          time_2  = lv_timef
        IMPORTING
          seconds = lv_second.
      IF sy-subrc = 0.
        ADD lv_second TO fc_second.
      ENDIF.
    ENDIF.

    CLEAR: lv_index,ls_ztspppdt012_nx.
  ENDLOOP.

  SORT lt_ztspppdt014 BY aufnr vornr actwh wadah.
  LOOP AT lt_ztspppdt014 INTO ls_ztspppdt014.
    CLEAR: lv_dates,lv_times,lv_datef,lv_timef,lv_second.
    lv_dates = ls_ztspppdt014-erdat.
    lv_times = ls_ztspppdt014-ertim.
    lv_datef = ls_ztspppdt014-datef.
    lv_timef = ls_ztspppdt014-timef.
    CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
      EXPORTING
        date_1  = lv_dates
        time_1  = lv_times
        date_2  = lv_datef
        time_2  = lv_timef
      IMPORTING
        seconds = lv_second.
    IF sy-subrc = 0.
      ADD lv_second TO fc_second.
    ENDIF.
  ENDLOOP.

  SORT lt_ztspppdt015 BY aufnr vornr actwh wadah.
  LOOP AT lt_ztspppdt015 INTO ls_ztspppdt015.
    CLEAR: lv_dates,lv_times,lv_datef,lv_timef,lv_second.
    lv_dates = ls_ztspppdt015-erdat.
    lv_times = ls_ztspppdt015-ertim.
    lv_datef = ls_ztspppdt015-datef.
    lv_timef = ls_ztspppdt015-timef.
    CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
      EXPORTING
        date_1  = lv_dates
        time_1  = lv_times
        date_2  = lv_datef
        time_2  = lv_timef
      IMPORTING
        seconds = lv_second.
    IF sy-subrc = 0.
      ADD lv_second TO fc_second.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_get_timestamp  USING    fu_date
                               fu_time
                      CHANGING fc_timestamp.
  CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_INTO'
    EXPORTING
      iv_date          = fu_date
      iv_time          = fu_time
    IMPORTING
      ev_timestamp     = fc_timestamp
    EXCEPTIONS
      conversion_error = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_GET_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TEXT
*&---------------------------------------------------------------------*
FORM f_save_text  TABLES   ft_lines STRUCTURE gs_lines
                  USING    fu_rueck
                           fu_rmzhl.
  DATA: lv_lines  TYPE int1,
        lv_name   LIKE thead-tdname,
        lv_header LIKE thead,
        lt_lines  TYPE STANDARD TABLE OF tline.

  DESCRIBE TABLE ft_lines LINES lv_lines.
  IF lv_lines GT 1.
    UPDATE afru SET txtsp = sy-langu
                WHERE rueck = fu_rueck
                  AND rmzhl = fu_rmzhl.

    CONCATENATE sy-mandt fu_rueck fu_rmzhl INTO lv_name.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'RMEL'
        language                = sy-langu
        name                    = lv_name
        object                  = 'AUFK'
      IMPORTING
        header                  = lv_header
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    IF sy-subrc NE 0.
      CALL FUNCTION 'INIT_TEXT'
        EXPORTING
          id       = 'RMEL'
          language = sy-langu
          name     = lv_name
          object   = 'AUFK'
        IMPORTING
          header   = lv_header
        TABLES
          lines    = lt_lines
        EXCEPTIONS
          id       = 1
          language = 2
          name     = 3
          object   = 4
          OTHERS   = 5.
    ENDIF.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = lv_header
        savemode_direct = 'X'
      TABLES
        lines           = ft_lines
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.
