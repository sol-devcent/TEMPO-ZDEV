*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  SELECT * INTO TABLE gt_zplbc
    FROM zplbc WHERE bukrs EQ '8020'
                 AND werks IN s_werks.

  SELECT * INTO TABLE gt_zaccmmdt001
    FROM zaccmmdt001 FOR ALL ENTRIES IN gt_zplbc
    WHERE ivnr   IN s_ivnr
      AND brcod  EQ gt_zplbc-legacy_branch
      AND upldat IN s_upldat.
*      AND status EQ space.

  CASE 'X'.
    WHEN p_butt1.
      DELETE gt_zaccmmdt001 WHERE status IS NOT INITIAL.
    WHEN p_butt2.
      DELETE gt_zaccmmdt001 WHERE status IS NOT INITIAL.
      DELETE gt_zaccmmdt001 WHERE logno IS INITIAL.
    WHEN p_butt3.
      SELECT * INTO TABLE gt_zaccmmdt001er
        FROM zaccmmdt001er FOR ALL ENTRIES IN gt_zaccmmdt001
        WHERE logno = gt_zaccmmdt001-logno
          AND ivnr  = gt_zaccmmdt001-ivnr
          AND brcod = gt_zaccmmdt001-brcod.
  ENDCASE.

  IF gt_zaccmmdt001[] IS INITIAL.
*    MESSAGE 'No Data' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

*{   REPLACE        P01K910127                                        1
*\  SELECT * INTO TABLE gt_zaccdtm
*\    FROM zaccdtm FOR ALL ENTRIES IN gt_zaccmmdt001
*\    WHERE matnr = gt_zaccmmdt001-matnr
*\      AND charg = gt_zaccmmdt001-charg.
*\*      AND senum = gt_zaccmmdt001-sn.
  "Start SOH: Shell SCI Adjustment 20240221 KRS
  SELECT * INTO TABLE gt_zaccdtm
    FROM zaccdtm FOR ALL ENTRIES IN gt_zaccmmdt001
    WHERE matnr = gt_zaccmmdt001-matnr
      AND charg = gt_zaccmmdt001-charg
      ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE

  SELECT * INTO TABLE gt_zaccdta
    FROM zaccdta FOR ALL ENTRIES IN gt_zaccmmdt001
    WHERE ( matnr = gt_zaccmmdt001-matnr
      AND charg = gt_zaccmmdt001-charg
      AND aggr2 = gt_zaccmmdt001-aggr2
      AND zact2 = 'X' )
      OR ( matnr = gt_zaccmmdt001-matnr
      AND charg = gt_zaccmmdt001-charg
      AND aggr1 = gt_zaccmmdt001-aggr1
      AND zact1 = 'X' ).

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_inventory
    FROM zivh_inventory FOR ALL ENTRIES IN gt_zaccmmdt001
    WHERE ivnr   = gt_zaccmmdt001-ivnr
      AND brcod  = gt_zaccmmdt001-brcod.
*      AND status = 'X'.

  IF gt_inventory[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_inventoryd
      FROM zivd_inventory FOR ALL ENTRIES IN gt_inventory
      WHERE ivnr   = gt_inventory-ivnr
        AND brcod  = gt_inventory-brcod
        AND divcod = gt_inventory-divcod
        AND zgroup = gt_inventory-zgroup
        AND ivtype = gt_inventory-ivtype
        AND ivstyp = gt_inventory-ivstyp
        AND doctyp = gt_inventory-doctyp.
  ENDIF.
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
  DATA: lv_err(1),
        lv_logno LIKE gt_zaccmmdt001-logno,
        lv_sn LIKE gt_zaccmmdt001-sn,
        lv_posnr LIKE gt_s501-posnr.

  DATA: lt_inventoryd TYPE TABLE OF zivd_inventory WITH HEADER LINE.

  CASE 'X'.
    WHEN p_butt1 OR p_butt2.
      gt_key[] = gt_zaccmmdt001[].
      SORT gt_key BY ivnr brcod.
      SORT gt_zaccmmdt001 BY ivnr brcod matnr charg sn.
      DELETE ADJACENT DUPLICATES FROM gt_key COMPARING ivnr brcod.

      LOOP AT gt_key.
        CLEAR: lv_err, gt_zaccmmdt001, lv_logno.
* Looping pertama untuk validasi.
        LOOP AT gt_zaccmmdt001 WHERE ivnr  = gt_key-ivnr
                                 AND brcod = gt_key-brcod.
          READ TABLE gt_zaccdtm WITH KEY matnr = gt_zaccmmdt001-matnr
                       charg = gt_zaccmmdt001-charg
                       senum = gt_zaccmmdt001-sn.
          IF sy-subrc = 0.
            CLEAR gt_inventory.
            IF gt_key-ivnr NE 9999999.
              READ TABLE gt_inventory WITH KEY ivnr  = gt_key-ivnr
                                               brcod = gt_key-brcod.
              IF sy-subrc = 0.
* Error condition status SN tidak sesuai.
                IF gt_inventory-ivtype = '0'.
                  IF gt_zaccdtm-snsta NE 'ECUS'.
                    lv_err = '4'.
                    CONTINUE.
                  ENDIF.
                ELSEIF gt_inventory-ivtype = '1'.
                  IF gt_zaccdtm-snsta NE 'ESTO'.
                    lv_err = '5'.
                    CONTINUE.
                  ENDIF.
                ENDIF.
                LOOP AT gt_inventory WHERE ivnr  = gt_key-ivnr
                                       AND brcod = gt_key-brcod.
                  IF gt_inventory-status IS INITIAL.
* Error condition file inventory belum diproses
                    lv_err = '3'.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ELSE.
* Error condition file inventory belum diupload
                lv_err = '2'.
              ENDIF.
            ENDIF.
          ELSE.
* Error condition sn tidak ada di zaccdtm
            lv_err = '1'.
            lv_sn = gt_zaccmmdt001-sn.
          ENDIF.

          IF lv_err IS NOT INITIAL.
*            CASE 'X'.
*              WHEN p_butt1.
            IF lv_logno IS INITIAL.
              PERFORM f_get_log_no CHANGING lv_logno.
            ENDIF.
*              WHEN p_butt2.
*            ENDCASE.

            PERFORM f_write_error USING lv_logno
                                        gt_key-ivnr
                                        gt_key-brcod
                                        gt_zaccmmdt001-matnr
                                        lv_sn
                                        lv_err.
            IF lv_err = '2'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lv_err IS INITIAL.
* Looping kedua untuk mapping ke itab accuracy
          CLEAR: lv_posnr.
          LOOP AT gt_zaccmmdt001 WHERE ivnr  = gt_key-ivnr
                                   AND brcod = gt_key-brcod.
            CLEAR: gt_zaccdtm, gt_inventory, gt_inventoryd.
            CLEAR gt_zaccmmdt001-logno.
            gt_zaccmmdt001-status = 'X'.
            MODIFY gt_zaccmmdt001 TRANSPORTING logno status
              WHERE ivnr  = gt_key-ivnr
                AND brcod = gt_key-brcod
                AND sn    = gt_zaccmmdt001-sn.

            IF gt_key-ivnr = 9999999.
              gt_inventory-ivtype  = 0.                    "Set terlebih dahulu ivtype = 0 agar doc yang terbentuk adalah INB.
              gt_inventory-ivnr    = gt_zaccmmdt001-ivnr.
              gt_inventory-postdat = gt_zaccmmdt001-upldat.
              gt_inventory-docpost = gt_zaccmmdt001-upldat.

              ON CHANGE OF gt_zaccmmdt001-matnr OR gt_zaccmmdt001-charg.
                lv_posnr = lv_posnr + 1.
              ENDON.
              gt_inventoryd-posnr = lv_posnr.

              READ TABLE gt_zplbc WITH KEY bukrs = '8020'
                                           legacy_branch = gt_zaccmmdt001-brcod.
              gt_inventoryd-werks = gt_zplbc-werks.
              gt_inventoryd-lgort = gt_zplbc-lgort.

              READ TABLE gt_zaccdtm WITH KEY matnr = gt_zaccmmdt001-matnr
                                             charg = gt_zaccmmdt001-charg
                                             senum = gt_zaccmmdt001-sn.

              IF gt_zaccdtm-snsta <> 'ESTO' AND gt_zaccdtm-snsta <> 'EDEL'.
*collect data in di plant yang melakukan stock opname
                PERFORM f_collect_zaccdtd.
                PERFORM f_collect_s501.
                PERFORM f_collect_zaccdtm.
                PERFORM f_collect_zaccdta.
              ELSEIF ( gt_zaccdtm-snsta  = 'ESTO' OR gt_zaccdtm-snsta  = 'EDEL' ) AND
                     gt_zaccdtm-werks <> gt_inventoryd-werks.
*Collect data IN di plant yang melakukan stock opname
                PERFORM f_collect_zaccdtd.
                PERFORM f_collect_s501.
                PERFORM f_collect_zaccdtm.
                PERFORM f_collect_zaccdta.
*Collect data OUT di plant asal SN
                gt_inventory-ivtype = 'DCC'.
                gt_inventoryd-werks = gt_zaccdtm-werks.
                gt_inventoryd-lgort = gt_zaccdtm-lgort.
                PERFORM f_collect_zaccdtd.
                PERFORM f_collect_s501.
              ENDIF.
              CLEAR gt_zaccdtm-ernam.
              MODIFY gt_zaccdtm FROM gt_zaccdtm
                                TRANSPORTING ernam
                                WHERE senum = gt_zaccmmdt001-sn.
            ELSE.
              READ TABLE gt_zaccdtm WITH KEY matnr = gt_zaccmmdt001-matnr
                                             charg = gt_zaccmmdt001-charg
                                             senum = gt_zaccmmdt001-sn.

              READ TABLE gt_inventoryd WITH KEY ivnr  = gt_zaccmmdt001-ivnr
                                                brcod = gt_zaccmmdt001-brcod
                                                matnr = gt_zaccmmdt001-matnr.

              READ TABLE gt_inventory WITH KEY ivnr   = gt_inventoryd-ivnr
                                               brcod  = gt_inventoryd-brcod
                                               divcod = gt_inventoryd-divcod
                                               zgroup = gt_inventoryd-zgroup
                                               ivtype = gt_inventoryd-ivtype
                                               ivstyp = gt_inventoryd-ivstyp
                                               doctyp = gt_inventoryd-doctyp.

              PERFORM f_collect_zaccdtd.
              PERFORM f_collect_s501.
              PERFORM f_collect_zaccdtm.
              PERFORM f_collect_zaccdta.
            ENDIF.
          ENDLOOP.

*Collect data OUT di plant yang melakukan stock opname
          IF gt_key-ivnr = 9999999.
            CLEAR: gt_zaccmmdt001, gt_zaccdtm, gt_inventory, gt_inventoryd.
            gt_inventory-ivtype = 1.
            READ TABLE gt_zplbc WITH KEY bukrs = '8020'
                                         legacy_branch = gt_key-brcod.
            gt_inventoryd-werks = gt_zplbc-werks.
            gt_inventoryd-lgort = gt_zplbc-lgort.

*{   INSERT         P01K910127                                        1
*"Start SOH: Shell SCI Adjustment 20240221 KRS
  sort gt_zaccdtm by matnr charg senum werks lgort snsta.
*"End SOH: Shell SCI Adjustment 20240221 KRS
*}   INSERT
            LOOP AT gt_zaccdtm WHERE ernam IS NOT INITIAL
                                 AND matnr = gt_key-matnr
                                 AND werks = gt_inventoryd-werks
                                 AND lgort = gt_inventoryd-lgort
                                 AND snsta = 'ESTO'.
              READ TABLE gt_zaccmmdt001 WITH KEY matnr = gt_zaccdtm-matnr
                                                 charg = gt_zaccdtm-charg.
              IF sy-subrc = 0.
                gt_zaccmmdt001-sn    = gt_zaccdtm-senum.
                gt_inventory-ivnr    = gt_zaccmmdt001-ivnr.
                gt_inventory-postdat = gt_zaccmmdt001-upldat.
                gt_inventory-docpost = gt_zaccmmdt001-upldat.

                ON CHANGE OF gt_zaccdtm-matnr OR gt_zaccdtm-charg.
                  lv_posnr = lv_posnr + 1.
                ENDON.
                gt_inventoryd-posnr = lv_posnr.

                PERFORM f_collect_zaccdtd.
                PERFORM f_collect_s501.
                PERFORM f_collect_zaccdtm.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      PERFORM f_recollect_zaccdta.
      PERFORM f_update_table.

    WHEN p_butt3.
      LOOP AT gt_zaccmmdt001.
        READ TABLE gt_zaccmmdt001er ASSIGNING <fs_zaccmmdt001er>
                                    WITH KEY logno = gt_zaccmmdt001-logno
                                             ivnr  = gt_zaccmmdt001-ivnr
                                             brcod = gt_zaccmmdt001-brcod.
        IF sy-subrc = 0.
          gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
          MODIFY gt_zaccmmdt001 TRANSPORTING message.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  gt_out[] = gt_zaccmmdt001[].
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA message TYPE REF TO cx_salv_msg.

  DELETE gt_out WHERE status IS NOT INITIAL.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = gr_alv
                              CHANGING  t_table = gt_out ).
    CATCH cx_salv_msg INTO message.
      " error handling
  ENDTRY.

  gr_function = gr_alv->get_functions( ).
  gr_function->set_all( abap_true ).

  gr_columns = gr_alv->get_columns( ).
  gr_columns->set_optimize( abap_true ).

  PERFORM set_columns.

  gr_alv->display( ).
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR: gt_out,gt_zaccmmdt001,gt_inventory,gt_zaccdtm,gt_zplbc.
  REFRESH : gt_out,gt_zaccmmdt001,gt_inventory,gt_zaccdtm,gt_zplbc.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_NO
*&---------------------------------------------------------------------*
FORM f_get_log_no  CHANGING fc_logno.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZACCLOG'
    IMPORTING
      number                  = fc_logno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
ENDFORM.                    " F_GET_LOG_NO

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR
*&---------------------------------------------------------------------*
FORM f_write_error  USING    fu_logno
                             fu_ivnr
                             fu_brcod
                             fu_matnr
                             fu_sn
                             fu_err.
  APPEND INITIAL LINE TO gt_zaccmmdt001er ASSIGNING <fs_zaccmmdt001er>.
  <fs_zaccmmdt001er>-logno = fu_logno.
  <fs_zaccmmdt001er>-ivnr  = fu_ivnr.
  <fs_zaccmmdt001er>-brcod = fu_brcod.
  <fs_zaccmmdt001er>-sn    = fu_sn.

  CASE fu_err.
    WHEN '1'.
      <fs_zaccmmdt001er>-message = 'Data SN tidak ada dimaster'.
      gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
      gt_zaccmmdt001-logno = fu_logno.
      MODIFY gt_zaccmmdt001 TRANSPORTING logno message
        WHERE ivnr  = fu_ivnr
          AND brcod = fu_brcod
          AND sn = fu_sn.

    WHEN '2'.
      <fs_zaccmmdt001er>-message = 'Data inventory belum di upload'.
      gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
      gt_zaccmmdt001-logno = fu_logno.
      MODIFY gt_zaccmmdt001 TRANSPORTING logno message
        WHERE ivnr  = fu_ivnr
          AND brcod = fu_brcod.

    WHEN '3'.
      <fs_zaccmmdt001er>-message = 'Data inventory belum diproses'.
      gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
      gt_zaccmmdt001-logno = fu_logno.
      MODIFY gt_zaccmmdt001 TRANSPORTING logno message
        WHERE ivnr  = fu_ivnr
          AND brcod = fu_brcod
          AND matnr = fu_matnr.

    WHEN '4'.
      <fs_zaccmmdt001er>-message = 'Status SN bukan ECUS'.
      gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
      gt_zaccmmdt001-logno = fu_logno.
      MODIFY gt_zaccmmdt001 TRANSPORTING logno message
        WHERE ivnr  = fu_ivnr
          AND brcod = fu_brcod
          AND sn = fu_sn.

    WHEN '5'.
      <fs_zaccmmdt001er>-message = 'Status SN bukan ESTO'.
      gt_zaccmmdt001-message = <fs_zaccmmdt001er>-message.
      gt_zaccmmdt001-logno = fu_logno.
      MODIFY gt_zaccmmdt001 TRANSPORTING logno message
        WHERE ivnr  = fu_ivnr
          AND brcod = fu_brcod
          AND sn = fu_sn.
  ENDCASE.
ENDFORM.                    " F_WRITE_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table .
  DATA: lt_zaccmmdt001 TYPE TABLE OF zaccmmdt001.

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname    = 'ZACCDTD'
    TABLES
      it_zaccdtd = gt_zaccdtd.

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname = 'S501'
    TABLES
      it_s501 = gt_s501.

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname    = 'ZACCDTM'
    TABLES
      it_zaccdtm = gt_zaccdtm_upd.

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname    = 'ZACCDTA'
    TABLES
      it_zaccdta = gt_zaccdta_upd.

  lt_zaccmmdt001[] = gt_zaccmmdt001[].

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname        = 'ZACCMMDT001'
    TABLES
      it_zaccmmdt001 = lt_zaccmmdt001.

  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname          = 'ZACCMMDT001ER'
    TABLES
      it_zaccmmdt001er = gt_zaccmmdt001er.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    " F_UPDATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  SET_COLUMNS
*&---------------------------------------------------------------------*
FORM set_columns .
  TRY.
      gr_column ?= gr_columns->get_column( 'MANDT' ).
      gr_column->set_visible( abap_false ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      gr_column ?= gr_columns->get_column( 'IVNR' ).
      gr_column->set_long_text( 'Invetory No' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      gr_column ?= gr_columns->get_column( 'AGGR1' ).
      gr_column->set_long_text( 'Aggregate-1' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      gr_column ?= gr_columns->get_column( 'ZACT1' ).
      gr_column->set_long_text( 'Act-1' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      gr_column ?= gr_columns->get_column( 'AGGR2' ).
      gr_column->set_long_text( 'Aggregate-2' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      gr_column ?= gr_columns->get_column( 'ZACT2' ).
      gr_column->set_long_text( 'Act-2' ).
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.                    " SET_COLUMNS

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ZACCTDT
*&---------------------------------------------------------------------*
FORM f_collect_zaccdtd .
  DATA: lv_docat  TYPE zdocat,
        lv_docno  TYPE zdocno.

  IF gt_inventory-ivtype = 0.
    lv_docat = 'INB'.
  ELSEIF gt_inventory-ivtype = 'DCC'.
    lv_docat = 'DCC'.
  ELSE.
    lv_docat = 'DO'.
  ENDIF.

  IF gt_inventory-dnno IS INITIAL.
    lv_docno = gt_inventory-ivnr.
  ELSE.
    lv_docno = gt_inventory-dnno.
  ENDIF.

  APPEND INITIAL LINE TO gt_zaccdtd ASSIGNING <fs_zaccdtd>.
  <fs_zaccdtd>-docat = lv_docat.
  <fs_zaccdtd>-docno = lv_docno.
  <fs_zaccdtd>-posnr = gt_inventoryd-posnr.
  <fs_zaccdtd>-senum = gt_zaccmmdt001-sn.
  <fs_zaccdtd>-scandt = gt_inventory-postdat.
  <fs_zaccdtd>-ernam  = sy-uname.
  <fs_zaccdtd>-time   = sy-uzeit.
ENDFORM.                    " F_COLLECT_ZACCTDT

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_S501
*&---------------------------------------------------------------------*
FORM f_collect_s501 .
  DATA: lv_docat  TYPE zdocat,
        lv_docno  TYPE zdocno.

  IF gt_inventory-ivtype = 0.
    lv_docat = 'INB'.
  ELSEIF gt_inventory-ivtype = 'DCC'.
    lv_docat = 'DCC'.
  ELSE.
    lv_docat = 'DO'.
  ENDIF.

  IF gt_inventory-dnno IS INITIAL.
    lv_docno = gt_inventory-ivnr.
  ELSE.
    lv_docno = gt_inventory-dnno.
  ENDIF.

  CLEAR gt_s501.
  gt_s501-sptag = gt_inventory-postdat.
  gt_s501-docat = lv_docat.
  gt_s501-docno = lv_docno.
  gt_s501-posnr = gt_inventoryd-posnr.
  gt_s501-vrsio = '000'.
  gt_s501-spmon = gt_inventory-postdat(6).
  gt_s501-spwoc = '000000'.
  gt_s501-spbup = '000000'.
  gt_s501-ssour = space.
  gt_s501-periv = space.
  gt_s501-vwdat = space.
  gt_s501-basme = gt_zaccmmdt001-meins.
  gt_s501-werks = gt_inventoryd-werks.
  gt_s501-lgort = gt_inventoryd-lgort.
  gt_s501-charg = '00'.
  gt_s501-matnr = gt_zaccmmdt001-matnr.
  gt_s501-menge = 1.
  gt_s501-meins = gt_zaccmmdt001-meins.
  gt_s501-mblnr = gt_inventory-docpost.
  gt_s501-mjahr = gt_inventory-postdat(4).
  COLLECT gt_s501. CLEAR gt_s501.
ENDFORM.                    " F_COLLECT_S501

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ZACCDTM
*&---------------------------------------------------------------------*
FORM f_collect_zaccdtm .
  DATA: lv_docat  TYPE zdocat,
        lv_docno  TYPE zdocno,
        lv_posnr  TYPE posnr_va,
        lv_snsta  TYPE zsnsta.

  IF gt_inventory-ivtype = 0.
    lv_snsta = 'ESTO'.
  ELSE.
    lv_snsta = 'ECUS'.
  ENDIF.

  APPEND INITIAL LINE TO gt_zaccdtm_upd ASSIGNING <fs_zaccdtm>.
  <fs_zaccdtm>-matnr = gt_zaccmmdt001-matnr.
  <fs_zaccdtm>-charg = gt_zaccmmdt001-charg.
  <fs_zaccdtm>-senum = gt_zaccmmdt001-sn.
  <fs_zaccdtm>-werks = gt_inventoryd-werks.
  <fs_zaccdtm>-lgort = gt_inventoryd-lgort.
  <fs_zaccdtm>-aufnr = gt_zaccdtm-aufnr.
  <fs_zaccdtm>-vbeln = gt_zaccdtm-vbeln.
  <fs_zaccdtm>-erdat = sy-datum.
  <fs_zaccdtm>-ernam = sy-uname.
  <fs_zaccdtm>-sendt = gt_zaccdtm-sendt.
  <fs_zaccdtm>-snsta = lv_snsta.
ENDFORM.                    " F_COLLECT_ZACCDTM

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ZACCDTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_zaccdta .
  APPEND INITIAL LINE TO gt_zaccdta_upd ASSIGNING <fs_zaccdta>.
  <fs_zaccdta>-matnr   = gt_zaccmmdt001-matnr.
  <fs_zaccdta>-charg   = gt_zaccmmdt001-charg.
  <fs_zaccdta>-senum   = gt_zaccmmdt001-sn.
  <fs_zaccdta>-aggr1   = gt_zaccmmdt001-aggr1.
  <fs_zaccdta>-zact1   = gt_zaccmmdt001-zact1.
  <fs_zaccdta>-aggr2   = gt_zaccmmdt001-aggr2.
  <fs_zaccdta>-zact2   = gt_zaccmmdt001-zact2.
ENDFORM.                    " F_COLLECT_ZACCDTA
*&---------------------------------------------------------------------*
*&      Form  F_RECOLLECT_ZACCDTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_recollect_zaccdta .
  DATA: lt_temp TYPE TABLE OF zaccdta WITH HEADER LINE.

  lt_temp[] = gt_zaccdta_upd[].
  SORT lt_temp BY aggr2 aggr1.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING aggr2 aggr1.
  CLEAR : gt_zaccdta_upd[], gt_zaccdta_upd.
  LOOP AT lt_temp.
    IF lt_temp-aggr2 IS NOT INITIAL AND lt_temp-zact2 IS INITIAL.
      LOOP AT gt_zaccdta WHERE matnr = lt_temp-matnr
                           AND charg = lt_temp-charg
                           AND aggr2 = lt_temp-aggr2.
        gt_zaccdta_upd-matnr = gt_zaccdta-matnr.
        gt_zaccdta_upd-charg = gt_zaccdta-charg.
        gt_zaccdta_upd-senum = gt_zaccdta-senum.
        IF gt_zaccdta-aggr1 = lt_temp-aggr1.
          gt_zaccdta_upd-aggr1     = lt_temp-aggr1.
          gt_zaccdta_upd-zact1     = lt_temp-zact1.
          gt_zaccdta_upd-packdat1  = gt_zaccdta-packdat1.
        ELSE.
          gt_zaccdta_upd-aggr1     = gt_zaccdta-aggr1.
          gt_zaccdta_upd-zact1     = gt_zaccdta-zact1.
          gt_zaccdta_upd-packdat1  = gt_zaccdta-packdat1.
        ENDIF.
        gt_zaccdta_upd-aggr2     = lt_temp-aggr2.
        gt_zaccdta_upd-zact2     = lt_temp-zact2.
        gt_zaccdta_upd-packdat2  = gt_zaccdta-packdat2.
        APPEND gt_zaccdta_upd TO gt_zaccdta_upd.
        CLEAR: gt_zaccdta_upd, gt_zaccdta.
      ENDLOOP.
    ELSEIF lt_temp-aggr1 IS NOT INITIAL AND lt_temp-zact1 IS INITIAL..
      LOOP AT gt_zaccdta WHERE matnr = lt_temp-matnr
                           AND charg = lt_temp-charg
                           AND aggr1 = lt_temp-aggr1.
        gt_zaccdta_upd-matnr     = gt_zaccdta-matnr.
        gt_zaccdta_upd-charg     = gt_zaccdta-charg.
        gt_zaccdta_upd-senum     = gt_zaccdta-senum.
        gt_zaccdta_upd-aggr1     = lt_temp-aggr1.
        gt_zaccdta_upd-zact1     = lt_temp-zact1.
        gt_zaccdta_upd-packdat1  = gt_zaccdta-packdat1.
        gt_zaccdta_upd-aggr2     = gt_zaccdta-aggr2.
        gt_zaccdta_upd-zact2     = lt_temp-zact2.
        gt_zaccdta_upd-packdat2  = gt_zaccdta-packdat2.
        APPEND gt_zaccdta_upd TO gt_zaccdta_upd.
        CLEAR: gt_zaccdta_upd, gt_zaccdta.
      ENDLOOP.
    ELSE.
    ENDIF.
    CLEAR lt_temp.
  ENDLOOP.
ENDFORM.                    " F_RECOLLECT_ZACCDTA
