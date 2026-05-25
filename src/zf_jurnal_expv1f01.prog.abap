
*----------------------------------------------------------------------*
*   INCLUDE ZF_JURNAL_EXPV1F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : ls_tvro    LIKE LINE OF gt_tvro.

  pa_gsber    = pa_vkbur.
  so_gsber[]  = so_vkbur[].
  IF p_timde6 = 'X' OR p_timde7 = 'X'..
    p_timdes = 'X'.
  ENDIF.
  SELECT SINGLE waers
    FROM t093b
    INTO t093b-waers
    WHERE bukrs   = pa_bukrs
      AND afabe   = '01'.

  CALL FUNCTION 'RK_KOKRS_FIND'
    EXPORTING
      bukrs = pa_bukrs
    IMPORTING
      kokrs = zfmstper-kokrs.

  SELECT *
    FROM zf63typeexp
    INTO CORRESPONDING FIELDS OF TABLE gt_typeexp
    WHERE bukrs   = pa_bukrs
      AND gtype   = pa_gtype.

  SELECT *
    FROM zf63tytpeexpdesc
    INTO CORRESPONDING FIELDS OF TABLE gt_tyexpdtl
    WHERE gtype   = pa_gtype
    ORDER BY PRIMARY KEY.

  IF gs_gtype IS INITIAL.
    SELECT SINGLE *
      FROM zf63gtype
      INTO gs_gtype
      WHERE gtype = pa_gtype
        AND bukrs = pa_bukrs.
  ENDIF.

  SELECT *
    FROM zf63acckasexp
    INTO CORRESPONDING FIELDS OF TABLE gt_zf63acc
    WHERE gsber = pa_gsber
      AND gtype = pa_gtype.

  SELECT *
    FROM zf63persenbiaya
    INTO CORRESPONDING FIELDS OF TABLE gt_biaya
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur.

  CASE 'X'.
    WHEN radio2.
      SELECT *
        FROM zf63plat
        INTO CORRESPONDING FIELDS OF TABLE gt_plat
        WHERE bukrs   = pa_bukrs
          AND vkbur   = pa_vkbur
          AND gsber   = pa_gsber
          AND loevm   = space.

      SELECT *
        FROM zf63asset
        INTO CORRESPONDING FIELDS OF TABLE gt_asset
        WHERE bukrs   = pa_bukrs.

    WHEN radio4 OR radio14.
      SELECT vbund name1
        FROM zfgskunnr JOIN t880 ON zfgskunnr~vbund = t880~rcomp
        INTO CORRESPONDING FIELDS OF TABLE gt_trpar.

      SELECT *
        FROM zf63pddklk
        INTO CORRESPONDING FIELDS OF TABLE gt_pddklk.

      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zf63accexp
        INTO CORRESPONDING FIELDS OF TABLE gt_accexp.

      SELECT nmvch kdvch
        FROM zf63nomor
        INTO CORRESPONDING FIELDS OF TABLE gt_voucher
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur.

    WHEN radio5.
      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zf63accexp
        INTO CORRESPONDING FIELDS OF TABLE gt_accexp.

    WHEN radio6.
      SELECT vbund name1
        FROM zfgskunnr JOIN t880 ON zfgskunnr~vbund = t880~rcomp
        INTO CORRESPONDING FIELDS OF TABLE gt_trpar.

      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zf63accexp
        INTO CORRESPONDING FIELDS OF TABLE gt_accexp.

      SELECT *
        FROM zf63kostlexp
        INTO CORRESPONDING FIELDS OF TABLE gt_kostlexp.

    WHEN radio8.
      SELECT *
        FROM zf63accexp
        INTO CORRESPONDING FIELDS OF TABLE gt_accexp.

    WHEN radio9.
      SELECT *
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE gt_gtype
        WHERE gtype IN so_gtype
          AND bukrs = pa_bukrs.

    WHEN radio10.
      SELECT *
        FROM zf63jnskendexp
        INTO CORRESPONDING FIELDS OF TABLE gt_jnskend.

      SELECT *
        FROM tvro
        INTO CORRESPONDING FIELDS OF TABLE gt_tvro.

      LOOP AT gt_tvro INTO ls_tvro.
        gs_route-low    = ls_tvro-route.
        gs_route-sign   = 'I'.
        gs_route-option = 'EQ'.
        APPEND gs_route TO gr_route.
        CLEAR gs_route.
      ENDLOOP.

    WHEN radio11 OR radio12.
      SELECT *
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE gt_gtype
        WHERE bukrs = pa_bukrs.

    WHEN radio15.
      SELECT *
        FROM zf63proseqctrl
        INTO CORRESPONDING FIELDS OF TABLE gt_proseq
        WHERE bukrs = pa_bukrs.

      SELECT *
        FROM zf63salesarea
        INTO CORRESPONDING FIELDS OF TABLE gt_slarea
        WHERE vkbur = pa_vkbur.

      SELECT *
        FROM zf63pddklk
        INTO CORRESPONDING FIELDS OF TABLE gt_pddklk.

      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zf63accexp
        INTO CORRESPONDING FIELDS OF TABLE gt_accexp.

    WHEN radio17.
      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.
  ENDCASE.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : sellist   TYPE STANDARD TABLE OF vimsellist INITIAL SIZE 0,
         ls_mstk   LIKE LINE OF gt_mstk,
         lt_mstp   TYPE STANDARD TABLE OF ty_mstp INITIAL SIZE 0,
         ls_mstp   LIKE LINE OF gt_mstp,
         lt_trnhdr TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         ls_trnhdr LIKE LINE OF lt_trnhdr,
         lt_lips   TYPE STANDARD TABLE OF lips INITIAL SIZE 0.

  DATA : lt_bkpf   TYPE STANDARD TABLE OF bkpf INITIAL SIZE 0,
         ls_bkpf   LIKE LINE OF lt_bkpf,
         ls_trnvch LIKE LINE OF gt_trnvch.

  DATA : lt_zf63mp    TYPE STANDARD TABLE OF ty_mstp INITIAL SIZE 0.

  DATA : condition(1000),
         lv_lifnr   TYPE lfa1-lifnr.

  DATA : lt_trnvch TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         ls_trnshp LIKE LINE OF gt_trnshp,
         ls_vttk   LIKE LINE OF gt_vttk.

  DATA : lr_gtype   TYPE RANGE OF zgtype,
         lr_gtypex  TYPE RANGE OF zgtype,
         ls_gtypex  LIKE LINE OF lr_gtypex,
         ls_gtype   LIKE LINE OF gt_gtype,
         lv_uname   TYPE sy-uname,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_sellist TABLES sellist
                        USING pa_bukrs 'BUKRS' 'AND'.

      PERFORM f_sellist TABLES sellist
                        USING pa_vkbur 'VKBUR' 'AND'.

      PERFORM f_sellist TABLES sellist
                        USING pa_gsber 'GSBER' 'AND'.

      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                       = 'U'
          view_name                    = 'ZF63PDDKLK'
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

    WHEN radio2.
      PERFORM f_get_asset.

      IF pa_zidke IS NOT INITIAL.
        SELECT *
          FROM zf63masterkend
          INTO CORRESPONDING FIELDS OF TABLE gt_mstk
          WHERE bukrs = pa_bukrs
            AND vkbur = pa_vkbur
            AND gsber = pa_gsber
            AND gtype = pa_gtype
            AND zidke = pa_zidke.
        IF sy-subrc <> 0.
          gv_subrc = sy-subrc.
        ELSE.
          SORT gt_mstk BY buzei.
          LOOP AT gt_mstk INTO zfmstken.
            ls_mstk = zfmstken.
            IF zfmstken-loevm IS NOT INITIAL.
              ls_mstk-status   = icon_delete.
            ELSE.
              gv_znopol  = zfmstken-znopol.
            ENDIF.
            MODIFY gt_mstk FROM ls_mstk TRANSPORTING status.
          ENDLOOP.
          READ TABLE gt_mstk INTO zfmstken INDEX 1.
        ENDIF.
      ELSE.
        zfmstken-bukrs = pa_bukrs.
        zfmstken-vkbur = pa_vkbur.
        zfmstken-gsber = pa_gsber.
        zfmstken-gtype = pa_gtype.
        APPEND zfmstken TO gt_mstk.
      ENDIF.

      CLEAR ls_mstk.
      READ TABLE gt_mstk INTO ls_mstk INDEX 1.
      IF sy-subrc = 0.
        gv_bukrs  = ls_mstk-bukrs.
        gv_anln1  = ls_mstk-anln1.
        gv_anln2  = ls_mstk-anln2.
      ENDIF.

    WHEN radio3.
      PERFORM f_get_asset.

      SELECT *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF TABLE gt_mstk
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND gsber = pa_gsber
          AND gtype = pa_gtype
          AND loevm = space.

      IF pa_zidno IS NOT INITIAL.
        SELECT *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF TABLE gt_mstp
          WHERE bukrs = pa_bukrs
            AND vkbur = pa_vkbur
            AND gsber = pa_gsber
            AND gtype = pa_gtype
            AND zidno = pa_zidno.
        IF sy-subrc <> 0.
          gv_subrc = sy-subrc.
        ELSE.
          READ TABLE gt_mstp INTO zfmstper INDEX 1.
          IF sy-subrc = 0.
            IF zfmstper-pernr IS NOT INITIAL.
              PERFORM f_get_description USING 'PA0001' 'SNAME' 'PERNR'
                                              zfmstper-pernr
                                        CHANGING zfexpense-pernr_name1.
            ENDIF.
            IF zfmstper-lifnr IS NOT INITIAL.
              PERFORM f_get_description USING 'LFA1' 'NAME1' 'LIFNR'
                                              zfmstper-lifnr
                                        CHANGING zfexpense-lifnr_name1.

            ENDIF.
            IF zfmstper-kunnr IS NOT INITIAL.
              PERFORM f_get_description USING 'KNA1' 'NAME1' 'KUNNR'
                                              zfmstper-kunnr
                                        CHANGING zfexpense-kunnr_name1.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        zfmstper-bukrs = pa_bukrs.
        zfmstper-vkbur = pa_vkbur.
        zfmstper-gsber = pa_gsber.
        zfmstper-gtype = pa_gtype.
        APPEND zfmstper TO gt_mstp.
      ENDIF.

    WHEN radio4 OR radio14.
      zfexpense-bukrs = pa_bukrs.
      zfexpense-vkbur = pa_vkbur.
      zfexpense-gsber = pa_gsber.
      zfexpense-gtype = pa_gtype.
      zfexpense-waers = t093b-waers.

      APPEND zfexpense TO gt_ship.

    WHEN radio15.
      zfexpense-bukrs = pa_bukrs.
      zfexpense-vkbur = pa_vkbur.
      zfexpense-gsber = pa_gsber.
      zfexpense-gtype = pa_gtype.
      zfexpense-waers = t093b-waers.

      APPEND zfexpense TO gt_ship.

    WHEN radio5.
      zfexpense-bukrs = pa_bukrs.
      zfexpense-vkbur = pa_vkbur.
      zfexpense-gsber = pa_gsber.
      zfexpense-gtype = pa_gtype.

      PERFORM f_text_screen USING '' '' '' '' '' '' '' '' '' '' ''
                            CHANGING gs_ship-butxt gs_ship-bezei
                                     gs_ship-gtext gs_ship-description
                                     gs_ship-salesman gs_ship-vendor
                                     gs_ship-customer gs_ship-shipment
                                     gs_ship-lfa1 gs_ship-znopol.

      CALL SCREEN 808 STARTING AT 10 10.

      PERFORM f_lock_table USING 'ENQUEUE_EZFPERSON' 'ZF63MASTERPERSON'
                                 zfexpense-bukrs zfexpense-gsber
                                 zfexpense-vkbur zfexpense-gtype
                                 '' zfexpense-zidno_low
                           CHANGING lv_uname.

      IF lv_uname IS NOT INITIAL.
        gv_subrc = 1.
        MESSAGE s000(zab) WITH 'Transaction lock by' lv_uname
        DISPLAY LIKE 'E'.
      ENDIF.

      IF gv_subrc IS INITIAL.
        IF zfexpense-zidno_low IS INITIAL AND
          zfexpense-zidno_high IS INITIAL.
          SELECT lifnr
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
            WHERE bukrs = zfexpense-bukrs
              AND vkbur = zfexpense-vkbur
              AND gsber = zfexpense-gsber
              AND lifnr <> space.
          LOOP AT lt_zf63mp INTO ls_mstp.
            gs_zidno-low      = ls_mstp-lifnr.
            gs_zidno-sign     = 'I'.
            gs_zidno-option   = 'EQ'.
            APPEND gs_zidno TO gr_zidno.
            CLEAR gs_zidno.
          ENDLOOP.
        ELSE.
          gs_zidno-low      = zfexpense-zidno_low.
          IF zfexpense-zidno_high IS INITIAL.
            gs_zidno-high     = zfexpense-zidno_low.
          ELSE.
            gs_zidno-high     = zfexpense-zidno_high.
          ENDIF.
          gs_zidno-sign     = 'I'.
          gs_zidno-option   = 'BT'.
          APPEND gs_zidno TO gr_zidno.
          CLEAR gs_zidno.
        ENDIF.

        SELECT *
          FROM zf63trnhdr
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          WHERE bukrs   = pa_bukrs
            AND gsber   = pa_gsber
            AND vkbur   = pa_vkbur
            AND gtype   = pa_gtype
            AND zidno   IN gr_zidno
            AND zidvc   = space.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY bukrs gsber vkbur gtype expnr gjahr.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr
        COMPARING bukrs gsber vkbur gtype expnr gjahr.

        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63trndtl
            INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs   = pa_bukrs
              AND gsber   = pa_gsber
              AND vkbur   = pa_vkbur
              AND gtype   = pa_gtype
              AND expnr   = lt_trnhdr-expnr
              AND gjahr   = lt_trnhdr-gjahr.
        ENDIF.

        IF gs_gtype-advance IS INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            WHERE bukrs = pa_bukrs
              AND gsber = pa_gsber
              AND vkbur = pa_vkbur
*              AND gtype = pa_gtype
              AND zidno IN gr_zidno.
        ELSE.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            WHERE bukrs = pa_bukrs
              AND gsber = pa_gsber
              AND vkbur = pa_vkbur
              AND lifnr IN gr_zidno.
        ENDIF.

        lt_mstp[] = gt_mstp[].
        SORT lt_mstp BY lifnr.
        DELETE ADJACENT DUPLICATES FROM lt_mstp COMPARING lifnr.

        LOOP AT lt_mstp INTO ls_mstp.
          PERFORM f_get_bsik USING pa_bukrs ls_mstp-lifnr 'C'
                                   '' '' pa_gsber 'X'.
          PERFORM f_advance_modify.
        ENDLOOP.
      ENDIF.

    WHEN radio6.
      PERFORM f_get_zf63n_6.
**      CASE sy-tcode.
**        WHEN 'ZF63B'.
**          PERFORM f_get_zf63b_6.
**
**        WHEN 'ZF63N'.
**          PERFORM f_get_zf63n_6.
**      ENDCASE.

    WHEN radio7.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_get_zf63b_7.

        WHEN 'ZF63N'.
          PERFORM f_get_zf63n_7.
      ENDCASE.

    WHEN radio8.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_get_zf63b_8.
        WHEN 'ZF63N'.
          PERFORM f_get_zf63n_8.
      ENDCASE.

    WHEN radio9.
      LOOP AT gt_gtype INTO ls_gtype.
        ls_gtypex-low     = ls_gtype-gtype.
        ls_gtypex-sign    = 'I'.
        ls_gtypex-option  = 'EQ'.
        IF ls_gtype-advance IS INITIAL.
          APPEND ls_gtypex TO lr_gtype.
        ELSE.
          APPEND ls_gtypex TO lr_gtypex.
        ENDIF.
        CLEAR ls_gtypex.
      ENDLOOP.

      SELECT *
        FROM zf63trnhdr
        INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
        WHERE bukrs   = pa_bukrs
          AND gsber   = pa_gsber
          AND vkbur   = pa_vkbur
          AND gtype   IN so_gtype.

      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur gtype zidvc.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr
      COMPARING bukrs gsber vkbur gtype zidvc.
      IF lt_trnhdr[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnvch
          INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE bukrs       = lt_trnhdr-bukrs
            AND gsber       = lt_trnhdr-gsber
            AND vkbur       = lt_trnhdr-vkbur
            AND gtype       IN lr_gtypex
            AND zidvc       = lt_trnhdr-zidvc
            AND budatpadv   IN so_budat.

        SELECT *
          FROM zf63trnvch
          APPENDING CORRESPONDING FIELDS OF TABLE gt_trnvch
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE bukrs   = lt_trnhdr-bukrs
            AND gsber   = lt_trnhdr-gsber
            AND vkbur   = lt_trnhdr-vkbur
            AND gtype   IN lr_gtype
            AND zidvc   = lt_trnhdr-zidvc
            AND budat   IN so_budat.
      ENDIF.

      LOOP AT gt_trnhdr INTO ls_trnhdr.
        CLEAR ls_trnvch.
        IF ls_trnhdr-rekanan IS INITIAL.
          READ TABLE gt_trnvch INTO ls_trnvch
                               WITH KEY bukrs   = ls_trnhdr-bukrs
                                        gsber   = ls_trnhdr-gsber
                                        vkbur   = ls_trnhdr-vkbur
                                        gtype   = ls_trnhdr-gtype
                                        zidvc   = ls_trnhdr-zidvc
                               TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            DELETE TABLE gt_trnhdr FROM ls_trnhdr.
          ENDIF.
        ENDIF.
      ENDLOOP.

      CLEAR : lt_trnhdr[], lt_trnhdr.
      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur gtype expnr gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr
      COMPARING bukrs gsber vkbur gtype expnr gjahr.
      IF lt_trnhdr[] IS NOT INITIAL.
        SELECT *
          FROM zf63trndtl
          INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE bukrs   = pa_bukrs
            AND gsber   = pa_gsber
            AND vkbur   = pa_vkbur
            AND gtype   IN so_gtype
            AND expnr   = lt_trnhdr-expnr
            AND gjahr   = lt_trnhdr-gjahr.
      ENDIF.

      CLEAR : lt_trnhdr[], lt_trnhdr.
      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur gtype zidno.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr
      COMPARING bukrs gsber vkbur gtype zidno.

      IF lt_trnhdr[] IS NOT INITIAL.
        IF gs_gtype-advance IS INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs   = lt_trnhdr-bukrs
              AND gsber   = lt_trnhdr-gsber
              AND vkbur   = lt_trnhdr-vkbur
              AND gtype   IN so_gtype
              AND zidno   = lt_trnhdr-zidno.
        ELSE.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs   = lt_trnhdr-bukrs
              AND gsber   = lt_trnhdr-gsber
              AND vkbur   = lt_trnhdr-vkbur.
        ENDIF.
      ENDIF.

      PERFORM f_get_bsik USING pa_bukrs gs_mstp-lifnr 'C' '' ''
                               pa_gsber ''.

    WHEN radio10.
      SELECT *
        FROM zf63trnshp
        INTO CORRESPONDING FIELDS OF TABLE gt_trnshp
        WHERE bukrs = pa_bukrs
          AND gsber IN so_gsber
          AND vkbur IN so_vkbur
          AND gtype = pa_gtype
          AND erdat IN so_budat
          AND expnr IN so_expnr.

      IF gt_trnshp[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_trnshp
          WHERE bukrs = gt_trnshp-bukrs
            AND gsber = gt_trnshp-gsber
            AND vkbur = gt_trnshp-vkbur
            AND gtype = gt_trnshp-gtype
            AND expnr = gt_trnshp-expnr
            AND gjahr = gt_trnshp-gjahr.

        IF gt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63trndtl
            INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
            FOR ALL ENTRIES IN gt_trnhdr
            WHERE bukrs = gt_trnhdr-bukrs
              AND gsber = gt_trnhdr-gsber
              AND vkbur = gt_trnhdr-vkbur
              AND gtype = gt_trnhdr-gtype
              AND expnr = gt_trnhdr-expnr
              AND gjahr = gt_trnhdr-gjahr.

          SELECT *
            FROM zf63trnvch
            INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
            FOR ALL ENTRIES IN gt_trnhdr
            WHERE bukrs = gt_trnhdr-bukrs
              AND gsber = gt_trnhdr-gsber
              AND vkbur = gt_trnhdr-vkbur
              AND gtype = gt_trnhdr-gtype
              AND zidvc = gt_trnhdr-zidvc
              AND userrev = space
              AND belnr <> space.
        ENDIF.

        LOOP AT gt_trnshp INTO ls_trnshp.
          READ TABLE gt_trnhdr INTO ls_trnhdr
                               WITH KEY bukrs = ls_trnshp-bukrs
                                        gsber = ls_trnshp-gsber
                                        vkbur = ls_trnshp-vkbur
                                        gtype = ls_trnshp-gtype
                                        expnr = ls_trnshp-expnr.
          IF sy-subrc = 0.
            IF ls_trnhdr-rekanan IS INITIAL OR
               ls_trnhdr-zidvc IS NOT INITIAL.

              READ TABLE gt_trnvch INTO ls_trnvch
                                   WITH KEY bukrs = ls_trnhdr-bukrs
                                            gsber = ls_trnhdr-gsber
                                            vkbur = ls_trnhdr-vkbur
                                            gtype = ls_trnhdr-gtype
                                            zidvc = ls_trnhdr-zidvc.
              IF sy-subrc <> 0.
                DELETE gt_trnshp WHERE bukrs = ls_trnhdr-bukrs
                                   AND gsber = ls_trnhdr-gsber
                                   AND vkbur = ls_trnhdr-vkbur
                                   AND gtype = ls_trnhdr-gtype
                                   AND expnr = ls_trnhdr-expnr
                                   AND gjahr = ls_trnhdr-gjahr.

                DELETE TABLE gt_trnhdr FROM ls_trnhdr.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF gt_trnshp[] IS NOT INITIAL.
          SELECT tknum route
            FROM vttk
            INTO CORRESPONDING FIELDS OF TABLE gt_vttk
            FOR ALL ENTRIES IN gt_trnshp
            WHERE tknum = gt_trnshp-tknum.
*              AND route IN gr_route.
        ENDIF.

        LOOP AT gt_trnshp INTO ls_trnshp.
          READ TABLE gt_vttk INTO ls_vttk
                             WITH KEY tknum = ls_trnshp-tknum
                             TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            DELETE TABLE gt_trnshp FROM ls_trnshp.
          ENDIF.
        ENDLOOP.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY zidno.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.
        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT zidno name1
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE zidno = lt_trnhdr-zidno.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY znopol.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING znopol.
        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT znopol jnskend
            FROM zf63masterkend
            INTO CORRESPONDING FIELDS OF TABLE gt_mstk
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE znopol = lt_trnhdr-znopol.
        ENDIF.

        IF gt_vttk[] IS NOT INITIAL.
          SELECT tknum tpnum vbeln
            FROM vttp
            INTO CORRESPONDING FIELDS OF TABLE gt_vttp
            FOR ALL ENTRIES IN gt_vttk
            WHERE tknum = gt_vttk-tknum.

          SELECT *
            FROM zmshphist
            INTO CORRESPONDING FIELDS OF TABLE gt_zmshphist
            FOR ALL ENTRIES IN gt_vttk
            WHERE tknum = gt_vttk-tknum.

          IF gt_vttp[] IS NOT INITIAL.
            SELECT vbeln kunnr btgew gewei volum voleh
              FROM likp
              INTO CORRESPONDING FIELDS OF TABLE gt_likp
              FOR ALL ENTRIES IN gt_vttp
              WHERE vbeln = gt_vttp-vbeln.

            SELECT vbeln posnr matnr vgbel vgpos vrkme lfimg
              meins kcmeng
              brgew gewei kcbrgew kcgewei volum voleh
              kcvolum kcvoleh uecha uepos
              FROM lips
              INTO CORRESPONDING FIELDS OF TABLE gt_lips
              FOR ALL ENTRIES IN gt_vttp
              WHERE vbeln = gt_vttp-vbeln.

            IF gt_lips[] IS NOT INITIAL.
              SELECT vbeln posnr matnr waerk netwr mwsbp
                kwmeng vrkme brgew gewei volum voleh
               FROM vbap
               INTO CORRESPONDING FIELDS OF TABLE gt_vbap
               FOR ALL ENTRIES IN gt_lips
               WHERE vbeln = gt_lips-vgbel.

              lt_lips[] = gt_lips[].
              SORT lt_lips BY matnr.
              DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
              IF lt_lips[] IS NOT INITIAL.
                SELECT *
                  FROM zmsutdt005
                  INTO CORRESPONDING FIELDS OF TABLE gt_005
                  FOR ALL ENTRIES IN lt_lips
                  WHERE bukrs = pa_bukrs
                    AND matnr = lt_lips-matnr
                    AND zaun  = 'KAR'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio11.
      SELECT *
        FROM zf63trnvch
        INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND gsber IN so_gsber
          AND gtype IN so_gtype
          AND budat IN so_budat
          AND userrev = space
          AND belnr <> space.

      IF gt_trnvch[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_trnvch
          WHERE bukrs = gt_trnvch-bukrs
            AND vkbur = gt_trnvch-vkbur
            AND gsber = gt_trnvch-gsber
            AND gtype = gt_trnvch-gtype
            AND zidvc = gt_trnvch-zidvc
            AND gjahr = gt_trnvch-vjahr
            AND znopol  IN so_nopol.

        PERFORM f_add_rekanan.

        IF gt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63trndtl
            INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
            FOR ALL ENTRIES IN gt_trnhdr
            WHERE bukrs = gt_trnhdr-bukrs
              AND gsber = gt_trnhdr-gsber
              AND vkbur = gt_trnhdr-vkbur
              AND gtype = gt_trnhdr-gtype
              AND expnr = gt_trnhdr-expnr
              AND gjahr = gt_trnhdr-gjahr.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY znopol.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING znopol.

        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterkend
            INTO CORRESPONDING FIELDS OF TABLE gt_mstk
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs  = lt_trnhdr-bukrs
              AND gsber  = lt_trnhdr-gsber
              AND vkbur  = lt_trnhdr-vkbur
              AND gtype  = lt_trnhdr-gtype
              AND znopol = lt_trnhdr-znopol.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY zidno.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.

        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs  = lt_trnhdr-bukrs
              AND gsber  = lt_trnhdr-gsber
              AND vkbur  = lt_trnhdr-vkbur
              AND gtype  = lt_trnhdr-gtype
              AND zidno  = lt_trnhdr-zidno.
        ENDIF.
      ENDIF.

    WHEN radio12.
      SELECT *
        FROM zf63trnvch
        INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND gsber IN so_gsber
          AND gtype IN so_gtype
          AND budat IN so_budat
          AND userrev = space
          AND belnr <> space.

      IF gt_trnvch[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_trnvch
          WHERE bukrs = gt_trnvch-bukrs
            AND vkbur = gt_trnvch-vkbur
            AND gsber = gt_trnvch-gsber
            AND gtype = gt_trnvch-gtype
            AND zidvc = gt_trnvch-zidvc
            AND gjahr = gt_trnvch-vjahr.

        IF gt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63trndtl
            INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
            FOR ALL ENTRIES IN gt_trnhdr
            WHERE bukrs = gt_trnhdr-bukrs
              AND gsber = gt_trnhdr-gsber
              AND vkbur = gt_trnhdr-vkbur
              AND gtype = gt_trnhdr-gtype
              AND expnr = gt_trnhdr-expnr
              AND gjahr = gt_trnhdr-gjahr.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY znopol.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING znopol.

        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterkend
            INTO CORRESPONDING FIELDS OF TABLE gt_mstk
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs  = lt_trnhdr-bukrs
              AND gsber  = lt_trnhdr-gsber
              AND vkbur  = lt_trnhdr-vkbur
              AND znopol = lt_trnhdr-znopol.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY zidno.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.

        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs  = lt_trnhdr-bukrs
              AND gsber  = lt_trnhdr-gsber
              AND vkbur  = lt_trnhdr-vkbur
              AND gtype  = lt_trnhdr-gtype
              AND zidno  = lt_trnhdr-zidno.

          LOOP AT gt_mstp INTO ls_mstp.
            IF ls_mstp-name1 IN so_name1.
              CONTINUE.
            ELSE.
              DELETE TABLE gt_mstp FROM ls_mstp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

    WHEN radio13.
      SELECT *
        FROM zf63trnvch
        INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
        WHERE bukrs        = pa_bukrs
          AND gsber        IN so_gsber
          AND vkbur        IN so_vkbur
          AND gtype        = pa_gtype
          AND budatpadv    <= pa_stida
          AND belnrpadv    <> space
          AND belnrpadvrev = space.

      lt_trnvch[] = gt_trnvch[].
      SORT lt_trnvch[] BY belnrpadv.
      IF lt_trnvch[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnvch
          INTO CORRESPONDING FIELDS OF TABLE gt_trnvch1
          FOR ALL ENTRIES IN lt_trnvch
          WHERE bukrs     = lt_trnvch-bukrs
            AND gsber     = lt_trnvch-gsber
            AND vkbur     = lt_trnvch-vkbur
            AND adv_belnr = lt_trnvch-belnrpadv
            AND belnrrev  = space.
      ENDIF.

      IF gt_trnvch[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_trnvch
          WHERE bukrs   = gt_trnvch-bukrs
            AND gsber   = gt_trnvch-gsber
            AND vkbur   = gt_trnvch-vkbur
            AND gtype   = gt_trnvch-gtype
            AND zidvc   = gt_trnvch-zidvc
            AND gjahr   = gt_trnvch-vjahr.

        SELECT bukrs vkbur gsber zidno lifnr name1
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF TABLE gt_mstp
          WHERE bukrs = pa_bukrs
            AND gsber IN so_gsber
            AND vkbur IN so_vkbur
            AND lifnr IN so_zidno.
      ENDIF.

    WHEN radio17.
      READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
      lv_lifnr  = ls_trnhdr2-zidno.

      SELECT bukrs vkbur gsber zidno lifnr name1
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE gt_mstp
        WHERE bukrs = pa_bukrs
          AND gsber = pa_gsber
          AND vkbur = pa_vkbur
          AND lifnr = lv_lifnr.

      IF gt_trnhdr2[] IS NOT INITIAL.
        SELECT *
          FROM zf63trndtl2
          INTO CORRESPONDING FIELDS OF TABLE gt_trndtl2
          FOR ALL ENTRIES IN gt_trnhdr2
          WHERE bukrs = gt_trnhdr2-bukrs
            AND gsber = gt_trnhdr2-gsber
            AND vkbur = gt_trnhdr2-vkbur
            AND gtype = gt_trnhdr2-gtype
            AND gjahr = gt_trnhdr2-gjahr
            AND zidvc = gt_trnhdr2-zidvc.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*d       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio5.
      IF gt_head[] IS NOT INITIAL.
        PERFORM f_alv_hierarchy.
      ENDIF.
      PERFORM f_unlock_table USING '' 'DEQUEUE_EZFPERSON'.
    WHEN radio6.
      IF gv_execute IS NOT INITIAL.
        PERFORM f_alv_list_post.
      ENDIF.
*    WHEN radio7.
*      PERFORM f_alv_list_reverse.
    WHEN radio8.
      PERFORM f_alv_list_reprint.
    WHEN radio9.
      IF gt_head[] IS NOT INITIAL.
        PERFORM f_alv_hierarchy.
      ENDIF.
    WHEN radio10.
      NEW-PAGE LINE-SIZE 269.
      PERFORM f_print_delivery.
    WHEN radio11.
      NEW-PAGE LINE-SIZE 473.
      PERFORM f_print_kendaraan.
    WHEN radio12.
      NEW-PAGE LINE-SIZE 751.
      PERFORM f_print_personel.
    WHEN radio13.
      PERFORM f_alv_list_advance.
    WHEN radio17.
      PERFORM f_alv_list_cancel.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_out, gt_out[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA : lt_trnhdr  TYPE STANDARD TABLE OF zf63trnhdr
                    INITIAL SIZE 0,
         ls_trnhdr2 TYPE zf63trnhdr2,
         lt_trndtl  TYPE STANDARD TABLE OF zf63trndtl
                    INITIAL SIZE 0,
         lt_mstp    TYPE STANDARD TABLE OF ty_mstp
                    INITIAL SIZE 0,
         lt_mstk    TYPE STANDARD TABLE OF ty_mstk
                    INITIAL SIZE 0,
         lt_jnskend TYPE STANDARD TABLE OF zf63jnskendexp
                    INITIAL SIZE 0,
         lt_vttp    TYPE STANDARD TABLE OF vttp
                    INITIAL SIZE 0.

  DATA : ls_trndtl    LIKE LINE OF gt_trndtl,
         ls_trnhdr    LIKE LINE OF gt_trnhdr,
         ls_head      LIKE LINE OF gt_head,
         ls_detl      LIKE LINE OF gt_detl,
         ls_mstk      LIKE LINE OF gt_mstk,
         ls_mstp      LIKE LINE OF gt_mstp,
         ls_trnvch    LIKE LINE OF gt_trnvch,
         ls_trnvch1   LIKE LINE OF gt_trnvch1,
         ls_trnshp    LIKE LINE OF gt_trnshp,
         ls_zmshphist LIKE LINE OF gt_zmshphist,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_typeexp   LIKE LINE OF gt_typeexp,
         ls_accexp    LIKE LINE OF gt_accexp,
         ls_out       LIKE LINE OF gt_out,
         ls_reverse   LIKE LINE OF gt_reverse,
         ls_bkpf      LIKE LINE OF gt_bkpf,
         ls_bsik      LIKE LINE OF gt_bsik,
         ls_lips      LIKE LINE OF gt_lips,
         ls_vbap      LIKE LINE OF gt_vbap,
         ls_jnskend   LIKE LINE OF gt_jnskend,
         ls_reprint   LIKE LINE OF gt_reprint,
         ls_headl     LIKE LINE OF gt_headl,
         ls_total     LIKE LINE OF gt_total,
         ls_k001      LIKE LINE OF gt_k001,
         ls_k002      LIKE LINE OF gt_k002,
         ls_gtype     LIKE LINE OF gt_gtype,
         ls_advance   LIKE LINE OF gt_advance.

  DATA : lv_error,
         lv_stat  TYPE icon_d,
         lv_tabix TYPE sy-tabix,
         lv_post  TYPE int4,
         lv_lifnr TYPE lfa1-lifnr,
         lv_bktxt TYPE bkpf-bktxt,
         lv_value TYPE vbap-netwr,
         lv_uname TYPE sy-uname.

  CASE 'X'.
    WHEN radio2.
      IF gv_subrc IS INITIAL.
        PERFORM f_text_screen USING   '' '' '' '' '' '' '' '' '' '' ''
                              CHANGING gs_mstk-butxt gs_mstk-bezei
                                       gs_mstk-gtext gs_mstk-description
                                       gs_mstk-salesman gs_mstk-vendor
                                       gs_mstk-customer gs_mstk-shipment
                                       gs_mstk-lfa1 gs_mstk-znopol.

        CALL SCREEN 801.
      ELSE.
        MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN radio3.
      IF gv_subrc IS INITIAL.
        PERFORM f_text_screen USING    '' '' '' '' '' '' '' '' '' '' ''
                              CHANGING gs_mstp-butxt gs_mstp-bezei
                                       gs_mstp-gtext gs_mstp-description
                                       gs_mstp-salesman gs_mstp-vendor
                                       gs_mstp-customer gs_mstp-shipment
                                       gs_mstp-lfa1 gs_mstp-znopol.

        CALL SCREEN 802.
      ELSE.
        MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN radio4 OR radio14 OR radio15.
      PERFORM f_text_screen USING '' '' '' '' '' '' '' '' '' '' ''
                            CHANGING gs_ship-butxt gs_ship-bezei
                                     gs_ship-gtext gs_ship-description
                                     gs_ship-salesman gs_ship-vendor
                                     gs_ship-customer gs_ship-shipment
                                     gs_ship-lfa1 gs_ship-znopol.
      IF radio15 IS NOT INITIAL.
        zfexpense-advance = selected.
        CALL SCREEN 810.
      ELSE.
        CALL SCREEN 803.
      ENDIF.

    WHEN radio5.
      IF gv_subrc IS INITIAL.
        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY bukrs gsber vkbur zidno.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.
        IF lt_trnhdr[] IS NOT INITIAL.
          IF gs_gtype-advance IS INITIAL.
            SELECT *
              FROM zf63masterperson
              INTO CORRESPONDING FIELDS OF TABLE lt_mstp
              FOR ALL ENTRIES IN lt_trnhdr
              WHERE bukrs = lt_trnhdr-bukrs
                AND gsber = lt_trnhdr-gsber
                AND vkbur = lt_trnhdr-vkbur
                AND gtype = lt_trnhdr-gtype
                AND zidno = lt_trnhdr-zidno.
          ELSE.
            SELECT *
              FROM zf63masterperson
              INTO CORRESPONDING FIELDS OF TABLE lt_mstp
              FOR ALL ENTRIES IN lt_trnhdr
              WHERE bukrs = lt_trnhdr-bukrs
                AND gsber = lt_trnhdr-gsber
                AND vkbur = lt_trnhdr-vkbur.
          ENDIF.
        ENDIF.

        LOOP AT gt_trnhdr INTO ls_trnhdr.
          ls_head-bukrs    = ls_trnhdr-bukrs.
          ls_head-gsber    = ls_trnhdr-gsber.
          ls_head-vkbur    = ls_trnhdr-vkbur.
          ls_head-gtype    = ls_trnhdr-gtype.
          ls_head-expnr    = ls_trnhdr-expnr.
          ls_head-kjahr    = ls_trnhdr-gjahr.
          ls_head-zidvc    = ls_trnhdr-zidvc.
          ls_head-zidno    = ls_trnhdr-zidno.

          IF gs_gtype-advance IS INITIAL.
            READ TABLE lt_mstp INTO ls_mstp WITH KEY bukrs = ls_trnhdr-bukrs
                                                     gsber = ls_trnhdr-gsber
                                                     vkbur = ls_trnhdr-vkbur
                                                     gtype = ls_trnhdr-gtype
                                                     zidno = ls_trnhdr-zidno.
            IF sy-subrc = 0.
              ls_head-name1   = ls_mstp-name1.
            ENDIF.
          ELSE.
            READ TABLE lt_mstp INTO ls_mstp WITH KEY bukrs = ls_trnhdr-bukrs
                                                     gsber = ls_trnhdr-gsber
                                                     vkbur = ls_trnhdr-vkbur
                                                     lifnr = ls_trnhdr-zidno.
            IF sy-subrc = 0.
              ls_head-name1   = ls_mstp-name1.
            ENDIF.
          ENDIF.

          ls_head-znopol   = ls_trnhdr-znopol.
          ls_head-bktxt    = ls_trnhdr-bktxt.
          ls_head-waers    = ls_trnhdr-waers.
          ls_head-wrbtr    = ls_trnhdr-wrbtr.
          ls_head-ernam    = ls_trnhdr-ernam.
          ls_head-erdat    = ls_trnhdr-erdat.
          ls_head-erzet    = ls_trnhdr-erzet.
          ls_head-shkzg    = ls_trnhdr-shkzg.
          ls_head-rekanan  = ls_trnhdr-rekanan.
          APPEND ls_head TO gt_head.
          CLEAR ls_head.
        ENDLOOP.

        SORT gt_trndtl BY bukrs gsber vkbur gtype expnr.
        LOOP AT gt_trndtl INTO ls_trndtl.
          ls_detl-bukrs       = ls_trndtl-bukrs.
          ls_detl-gsber       = ls_trndtl-gsber.
          ls_detl-vkbur       = ls_trndtl-vkbur.
          ls_detl-gtype       = ls_trndtl-gtype.
          ls_detl-expnr       = ls_trndtl-expnr.
          ls_detl-type        = ls_trndtl-type.
          ls_detl-kjahr       = ls_trndtl-gjahr.
          ls_detl-description = ls_trndtl-description.
          ls_detl-meins       = ls_trndtl-meins.
          ls_detl-menge       = ls_trndtl-menge.
          ls_detl-speed       = ls_trndtl-speed.
          ls_detl-kmstr       = ls_trndtl-kmstr.
          ls_detl-kmend       = ls_trndtl-kmend.
          ls_detl-waers       = ls_trndtl-waers.
          ls_detl-vbund       = ls_trndtl-vbund.
          ls_detl-text        = ls_trndtl-text.
          IF ls_trndtl-shkzg = 'H'.
            ls_detl-wrbtrv      = ls_trndtl-wrbtr * -1.
          ELSE.
            ls_detl-wrbtrv      = ls_trndtl-wrbtr.
          ENDIF.
          APPEND ls_detl TO gt_detl.
          CLEAR ls_detl.
        ENDLOOP.
      ENDIF.

    WHEN radio6.
      PERFORM f_process_zf63n_6.
**      CASE sy-tcode.
**        WHEN 'ZF63B'.
**          PERFORM f_process_zf63b_6.
**
**        WHEN 'ZF63N'.
**          PERFORM f_process_zf63n_6.
**      ENDCASE.

    WHEN radio7.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_process_zf63b_7.

        WHEN 'ZF63N'.
          PERFORM f_process_zf63n_7.
      ENDCASE.

    WHEN radio8.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_process_zf63b_8.

        WHEN 'ZF63N'.
          PERFORM f_process_zf63n_8.
      ENDCASE.

    WHEN radio9.
      SORT gt_trnhdr BY bukrs gsber vkbur gtype zidvc.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        ls_head-bukrs    = ls_trnhdr-bukrs.
        ls_head-gsber    = ls_trnhdr-gsber.
        ls_head-vkbur    = ls_trnhdr-vkbur.
        ls_head-gtype    = ls_trnhdr-gtype.
        ls_head-zidno    = ls_trnhdr-zidno.
        ls_head-zidvc    = ls_trnhdr-zidvc.
        ls_head-kjahr    = ls_trnhdr-gjahr.

        CLEAR ls_gtype.
        READ TABLE gt_gtype INTO ls_gtype WITH KEY gtype = ls_trnhdr-gtype.

        IF ls_gtype-advance IS INITIAL.
          READ TABLE gt_mstp INTO ls_mstp WITH KEY bukrs = ls_trnhdr-bukrs
                                                   gsber = ls_trnhdr-gsber
                                                   vkbur = ls_trnhdr-vkbur
                                                   gtype = ls_trnhdr-gtype
                                                   zidno = ls_trnhdr-zidno.
          IF sy-subrc = 0.
            ls_head-name1   = ls_mstp-name1.
          ENDIF.
        ELSE.
          lv_lifnr  = ls_trnhdr-zidno.
          READ TABLE gt_mstp INTO ls_mstp WITH KEY bukrs = ls_trnhdr-bukrs
                                                   gsber = ls_trnhdr-gsber
                                                   vkbur = ls_trnhdr-vkbur
                                                   lifnr = lv_lifnr.
          IF sy-subrc = 0.
            ls_head-name1   = ls_mstp-name1.
          ENDIF.
        ENDIF.

        CLEAR ls_trnvch.
        READ TABLE gt_trnvch INTO ls_trnvch WITH KEY bukrs   = ls_trnhdr-bukrs
                                                     gsber   = ls_trnhdr-gsber
                                                     vkbur   = ls_trnhdr-vkbur
                                                     gtype   = ls_trnhdr-gtype
                                                     zidvc   = ls_trnhdr-zidvc
                                                     vjahr   = ls_trnhdr-gjahr.
        IF sy-subrc = 0.
          ls_head-bktxt         = ls_trnvch-bktxt.
          ls_head-belnr         = ls_trnvch-belnr.
          ls_head-belnrpadv     = ls_trnvch-belnrpadv.
          IF ls_gtype-advance IS INITIAL.
            ls_head-gjahr         = ls_trnvch-gjahr.
            ls_head-budat         = ls_trnvch-budat.
          ELSE.
            ls_head-gjahr         = ls_trnvch-gjahrpadv.
            ls_head-budat         = ls_trnvch-budatpadv.
          ENDIF.
          ls_head-xblnr         = ls_trnvch-xblnr.
          ls_head-hkont         = ls_trnvch-hkont.
          ls_head-belnrrev      = ls_trnvch-belnrrev.
          ls_head-belnrpadvrev  = ls_trnvch-belnrpadvrev.
          ls_head-userpost      = ls_trnvch-userpost.
          ls_head-userrev       = ls_trnvch-userrev.
          ls_head-tglrev        = ls_trnvch-tglrev.
        ELSE.
          CONTINUE.
        ENDIF.

        ls_head-znopol   = ls_trnhdr-znopol.
        ls_head-waers    = ls_trnhdr-waers.
        ls_head-wrbtr    = ls_trnhdr-wrbtr.
        ls_head-ernam    = ls_trnhdr-ernam.
        ls_head-erdat    = ls_trnhdr-erdat.
        COLLECT ls_head INTO gt_head.
        CLEAR ls_head.
      ENDLOOP.

      SORT gt_trndtl BY bukrs gsber vkbur gtype expnr.
      LOOP AT gt_trndtl INTO ls_trndtl.
        ls_detl-bukrs       = ls_trndtl-bukrs.
        ls_detl-gsber       = ls_trndtl-gsber.
        ls_detl-vkbur       = ls_trndtl-vkbur.
        ls_detl-gtype       = ls_trndtl-gtype.
        ls_detl-expnr       = ls_trndtl-expnr.
        ls_detl-kjahr       = ls_trndtl-gjahr.
        CLEAR ls_trnhdr.
        READ TABLE gt_trnhdr INTO ls_trnhdr WITH KEY bukrs = ls_trndtl-bukrs
                                                     gsber = ls_trndtl-gsber
                                                     vkbur = ls_trndtl-vkbur
                                                     gtype = ls_trndtl-gtype
                                                     expnr = ls_trndtl-expnr
                                                     gjahr = ls_trndtl-gjahr.
        IF sy-subrc = 0.
          ls_detl-zidvc       = ls_trnhdr-zidvc.
        ENDIF.
        ls_detl-type        = ls_trndtl-type.
        ls_detl-description = ls_trndtl-description.
        ls_detl-meins       = ls_trndtl-meins.
        ls_detl-menge       = ls_trndtl-menge.
        ls_detl-speed       = ls_trndtl-speed.
        ls_detl-kmstr       = ls_trndtl-kmstr.
        ls_detl-kmend       = ls_trndtl-kmend.
        ls_detl-waers       = ls_trndtl-waers.
        IF ls_trndtl-shkzg = 'H'.
          ls_detl-wrbtrv      = ls_trndtl-wrbtr * -1.
        ELSE.
          ls_detl-wrbtrv      = ls_trndtl-wrbtr.
        ENDIF.
        APPEND ls_detl TO gt_detl.
        CLEAR ls_detl.
      ENDLOOP.

    WHEN radio10.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        CLEAR ls_trnshp.
        READ TABLE gt_trnshp INTO ls_trnshp
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
                                      gtype = ls_trnhdr-gtype
                                      expnr = ls_trnhdr-expnr.
        IF sy-subrc <> 0.
          DELETE TABLE gt_trnhdr FROM ls_trnhdr.
        ENDIF.
      ENDLOOP.

      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY znopol.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING znopol.
      IF lt_trnhdr[] IS NOT INITIAL.
        LOOP AT lt_trnhdr INTO ls_trnhdr.
          CLEAR ls_trnvch.
          IF ls_trnhdr-rekanan IS INITIAL.
            READ TABLE gt_trnvch INTO ls_trnvch
                                 WITH KEY bukrs = ls_trnhdr-bukrs
                                          gsber = ls_trnhdr-gsber
                                          vkbur = ls_trnhdr-vkbur
                                          gtype = ls_trnhdr-gtype
                                          zidvc = ls_trnhdr-zidvc.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
          ENDIF.

          ls_headl-znopol  = ls_trnhdr-znopol.
          READ TABLE gt_mstk INTO ls_mstk
                             WITH KEY znopol = ls_trnhdr-znopol.
          IF sy-subrc = 0.
            READ TABLE gt_jnskend INTO ls_jnskend
                                  WITH KEY jnskend = ls_mstk-jnskend.
            IF sy-subrc = 0.
              ls_headl-jnskend     = ls_jnskend-jnskend.
              ls_headl-description = ls_jnskend-description.
            ENDIF.
          ENDIF.
          APPEND ls_headl TO gt_headl.
        ENDLOOP.
      ENDIF.

      LOOP AT gt_trnshp INTO ls_trnshp.
        LOOP AT gt_vttp INTO ls_vttp WHERE tknum = ls_trnshp-tknum.
          LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_vttp-vbeln.
            IF ls_lips-uecha IS INITIAL.
              CLEAR ls_vbap.
              LOOP AT gt_vbap INTO ls_vbap WHERE vbeln = ls_lips-vgbel
                                             AND posnr = ls_lips-vgpos.
                lv_value  = lv_value + ls_vbap-netwr + ls_vbap-mwsbp.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        ls_total-expnr  = ls_trnshp-expnr.
        ls_total-netwr  = lv_value.
        COLLECT ls_total INTO gt_total.
        CLEAR : ls_total, lv_value.
      ENDLOOP.

    WHEN radio11.
      SORT gt_trnhdr BY gtype znopol zidno.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        IF ls_trnhdr-znopol IS NOT INITIAL.
          ls_k001-gtype    = ls_trnhdr-gtype.
          ls_k001-znopol   = ls_trnhdr-znopol.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY zidno = ls_trnhdr-zidno.
          IF sy-subrc = 0.
            ls_k001-name1   = ls_mstp-name1.
            ls_k001-jabat   = ls_mstp-jabatpd.
            ls_k001-kostl   = ls_mstp-kostl.
            ls_k001-wwsfr   = ls_mstp-wwsfr.
            ls_k001-wwpos   = ls_mstp-wwpos.
          ENDIF.
          READ TABLE gt_mstk INTO ls_mstk
                             WITH KEY znopol = ls_trnhdr-znopol.
          IF sy-subrc = 0.
            ls_k001-jnskend   = ls_mstk-jnskend.
            ls_k001-zujhr     = ls_mstk-zujhr.
          ENDIF.

          LOOP AT gt_trndtl INTO ls_trndtl WHERE bukrs = ls_trnhdr-bukrs
                                             AND gsber = ls_trnhdr-gsber
                                             AND vkbur = ls_trnhdr-vkbur
                                             AND expnr = ls_trnhdr-expnr
                                             AND gjahr = ls_trnhdr-gjahr.
            ls_k001-waers   = ls_trndtl-waers.
            CASE ls_trndtl-type.
              WHEN '102' OR '103'.
                ls_k001-meins   = ls_trndtl-meins.
                PERFORM f_formula USING    ls_trndtl-kmstr
                                           ls_trndtl-kmend '-'
                                  CHANGING ls_k001-jarak.
                PERFORM f_formula USING    ls_trndtl-menge
                                           '' '+'
                                  CHANGING ls_k001-liter.
                IF ls_trndtl-type = '102'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k001-bensin.
                ELSEIF ls_trndtl-type = '103'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k001-solar.
                ENDIF.

              WHEN '205'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-gbrp.
                    PERFORM f_formula USING    ls_trndtl-menge
                                               '' '+'
                                      CHANGING ls_k001-gbqt.
                    ls_k001-gbkm  = ls_trndtl-kmend.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-akirp.
                    ls_k001-akikm  = ls_trndtl-kmend.
                  WHEN '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-sprp.
                  WHEN '004'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-sbrp.
                  WHEN '005'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-skrp.
                  WHEN '006'.
*                    PERFORM f_formula USING    ls_trndtl-wrbtr
*                                               '' '+'
*                                      CHANGING ls_k001-omrp.
                  WHEN '007'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-ogrp.
                    ls_k001-ogkm  = ls_trndtl-kmend.
                  WHEN '008'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-otrp.
                    ls_k001-otkm  = ls_trndtl-kmend.
                  WHEN '009'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-gmrp.
                  WHEN '010'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-tbrp.
                ENDCASE.

              WHEN '204'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-stnk.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-gprp.
                  WHEN '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-bpkb.
                  WHEN '004'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k001-kir.
                ENDCASE.

              WHEN '206'.
                PERFORM f_formula USING    ls_trndtl-wrbtr
                                           '' '+'
                                  CHANGING ls_k001-rmfee.

              WHEN '112'.
                IF ls_trndtl-buzei = '001'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k001-tbrp.
                ENDIF.
            ENDCASE.
          ENDLOOP.
          COLLECT ls_k001 INTO gt_k001.
          CLEAR : ls_k001-jarak, ls_k001-liter, ls_k001-bensin,
                  ls_k001-solar, ls_k001-ogkm, ls_k001-ogrp,
                  ls_k001-otkm, ls_k001-otrp, ls_k001-gbqt,
                  ls_k001-gbrp, ls_k001-gbkm, ls_k001-akirp,
                  ls_k001-tbrp, ls_k001-gmrp, ls_k001-sprp,
                  ls_k001-sbrp, ls_k001-skrp, ls_k001-rmfee,
                  ls_k001-stnk, ls_k001-gprp, ls_k001-bpkb,
                  ls_k001-kir.
        ENDIF.
      ENDLOOP.

    WHEN radio12.
      SORT gt_trnhdr BY gtype zidno znopol.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        IF ls_trnhdr-zidno IS NOT INITIAL.
          ls_k002-gtype    = ls_trnhdr-gtype.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY zidno = ls_trnhdr-zidno.
          IF sy-subrc = 0.
            ls_k002-name1   = ls_mstp-name1.
            ls_k002-jabat   = ls_mstp-jabatpd.
            ls_k002-kostl   = ls_mstp-kostl.
            ls_k002-wwsfr   = ls_mstp-wwsfr.
            ls_k002-wwpos   = ls_mstp-wwpos.
          ELSE.
            CONTINUE.
          ENDIF.

          IF ls_trnhdr-znopol IS NOT INITIAL.
            ls_k002-znopol   = ls_trnhdr-znopol.
            READ TABLE gt_mstk INTO ls_mstk
                               WITH KEY znopol = ls_trnhdr-znopol.
            IF sy-subrc = 0.
              ls_k002-jnskend   = ls_mstk-jnskend.
              ls_k002-zujhr     = ls_mstk-zujhr.
            ENDIF.
          ELSE.
            CLEAR : ls_k002-znopol, ls_k002-jnskend, ls_k002-zujhr.
          ENDIF.

          LOOP AT gt_trndtl INTO ls_trndtl WHERE bukrs = ls_trnhdr-bukrs
                                             AND gsber = ls_trnhdr-gsber
                                             AND vkbur = ls_trnhdr-vkbur
                                             AND expnr = ls_trnhdr-expnr
                                             AND gjahr = ls_trnhdr-gjahr.
            ls_k002-waers   = ls_trndtl-waers.
            CASE ls_trndtl-type.
              WHEN '101'.
                CASE ls_trndtl-buzei.
                  WHEN '001' OR '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-pddk.
                  WHEN '002' OR '004' OR '005' OR '006' OR '007'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-pdlk.
                ENDCASE.

              WHEN '102' OR '103'.
                ls_k002-meins   = ls_trndtl-meins.
                PERFORM f_formula USING    ls_trndtl-kmstr
                                           ls_trndtl-kmend '-'
                                  CHANGING ls_k002-jarak.
                PERFORM f_formula USING    ls_trndtl-menge
                                           '' '+'
                                  CHANGING ls_k002-liter.
                IF ls_trndtl-type = '102'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k002-bensin.
                ELSEIF ls_trndtl-type = '103'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k002-solar.
                ENDIF.

              WHEN '104'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-parkir.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-tol.
                  WHEN '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-ptrp.
                  WHEN '004'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-turp.
                  WHEN '005'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-ojek.
                ENDCASE.

              WHEN '105'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-hotel.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-kost.
                ENDCASE.

              WHEN '106'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-scan.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-warnet.
                ENDCASE.

              WHEN '107'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-fotocopy.
                ENDCASE.

              WHEN '108'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-materai.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-ongkir.
                ENDCASE.

              WHEN '109'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-buku.
                ENDCASE.

              WHEN '110'.
                PERFORM f_formula USING    ls_trndtl-wrbtr
                                           '' '+'
                                  CHANGING ls_k002-hand.

              WHEN '111'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-pasar.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-timb.
                ENDCASE.

              WHEN '112'.
                IF ls_trndtl-buzei = '001'.
                  PERFORM f_formula USING    ls_trndtl-wrbtr
                                             '' '+'
                                    CHANGING ls_k002-tbrp.
                ENDIF.

              WHEN '201'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-pkrp.
                ENDCASE.

              WHEN '202'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-pulsa.
                ENDCASE.

              WHEN '203'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-kost.
                ENDCASE.

              WHEN '204'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-stnk.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-gprp.
                  WHEN '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-bpkb.
                  WHEN '004'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-kir.
                ENDCASE.

              WHEN '205'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-gbrp.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-akirp.
                  WHEN '003'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-sprp.
                  WHEN '004'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-sbrp.
                  WHEN '005'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-skrp.
                  WHEN '006'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-omrp.
                  WHEN '007'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-ogrp.
                  WHEN '008'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-otrp.
                  WHEN '009'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-gmrp.
                  WHEN '010'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-tbrp.
                ENDCASE.

              WHEN '206'.
                PERFORM f_formula USING    ls_trndtl-wrbtr
                                           '' '+'
                                  CHANGING ls_k002-rmfee.

              WHEN '211'.
                CASE ls_trndtl-buzei.
                  WHEN '001'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-izin.
                  WHEN '002'.
                    PERFORM f_formula USING    ls_trndtl-wrbtr
                                               '' '+'
                                      CHANGING ls_k002-muat.
                ENDCASE.

            ENDCASE.
          ENDLOOP.
          COLLECT ls_k002 INTO gt_k002.
          CLEAR : ls_k002-bensin, ls_k002-solar, ls_k002-parkir,
                  ls_k002-tol, ls_k002-pkrp, ls_k002-ptrp, ls_k002-turp,
                  ls_k002-ojek, ls_k002-hotel, ls_k002-kost, ls_k002-ogrp,
                  ls_k002-pddk, ls_k002-pdlk, ls_k002-ogrp, ls_k002-otrp,
                  ls_k002-omrp, ls_k002-gbrp, ls_k002-akirp, ls_k002-tbrp,
                  ls_k002-gmrp, ls_k002-sprp, ls_k002-sbrp, ls_k002-skrp,
                  ls_k002-rmfee, ls_k002-stnk, ls_k002-kir, ls_k002-gprp,
                  ls_k002-bpkb, ls_k002-izin, ls_k002-muat, ls_k002-pasar,
                  ls_k002-timb, ls_k002-hand, ls_k002-materai,
                  ls_k002-ongkir, ls_k002-pulsa, ls_k002-warnet,
                  ls_k002-scan, ls_k002-buku, ls_k002-fotocopy,
                  ls_k002-total.
        ENDIF.
      ENDLOOP.

    WHEN radio13.
      LOOP AT gt_trnvch INTO ls_trnvch.
        ls_advance-belnrpadv    = ls_trnvch-belnrpadv.
        ls_advance-budatpadv    = ls_trnvch-budatpadv.
        ls_advance-waers        = ls_trnvch-waers.
        ls_advance-wrbtr        = ls_trnvch-wrbtr.
        ls_advance-bktxt        = ls_trnvch-bktxt.
        READ TABLE gt_trnvch1 INTO ls_trnvch1
                              WITH KEY bukrs     = ls_trnvch-bukrs
                                       gsber     = ls_trnvch-gsber
                                       vkbur     = ls_trnvch-vkbur
                                       adv_belnr = ls_trnvch-belnrpadv.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        READ TABLE gt_trnhdr INTO ls_trnhdr
                             WITH KEY bukrs = ls_trnvch-bukrs
                                      gsber = ls_trnvch-gsber
                                      vkbur = ls_trnvch-vkbur
                                      gtype = ls_trnvch-gtype
                                      zidvc = ls_trnvch-zidvc
                                      gjahr = ls_trnvch-vjahr.
        IF sy-subrc = 0.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
                                      lifnr = ls_trnhdr-zidno.
          IF sy-subrc = 0.
            ls_advance-lifnr  = ls_mstp-lifnr.
            ls_advance-name1  = ls_mstp-name1.
            APPEND ls_advance TO gt_advance.
            CLEAR ls_advance.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN radio17.
      IF p_timdes = 'X'.
        pa_xbln2 = c_refer.
        pa_budat = c_date.
        gv_ktext = 'CASH'.
        gv_payhkont = c_hkont.
        CLEAR ls_trnhdr2.
        READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
        IF sy-subrc = 0.
          PERFORM f_prepare_cancel_data USING ls_trnhdr2.
          PERFORM f_simulate USING ls_trnhdr2.
        ENDIF.
**      ELSE.
**        CALL SCREEN 809 STARTING AT 10 10.
      ENDIF.
      IF sy-tcode = 'ZF63N'.
        CALL SCREEN 809 STARTING AT 10 10.
      ENDIF.

  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELLIST
*&---------------------------------------------------------------------*
FORM f_sellist  TABLES   sellist  STRUCTURE vimsellist
                USING    fu_value fieldname append_conjunction.

  DATA : selopt    TYPE STANDARD TABLE OF selopt INITIAL SIZE 0,
         ls_selopt LIKE LINE OF selopt.

  ls_selopt-low    = fu_value.
  ls_selopt-sign   = 'I'.
  ls_selopt-option = 'EQ'.
  APPEND ls_selopt TO selopt.

  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      fieldname          = fieldname
      append_conjunction = append_conjunction
    TABLES
      sellist            = sellist
      rangetab           = selopt.
ENDFORM.                    " F_SELLIST

*&---------------------------------------------------------------------*
*&      Form  F_TEXT_SCREEN
*&---------------------------------------------------------------------*
FORM f_text_screen USING    fu_value
                            fu_butxt fu_bezei fu_gtext fu_description
                            fu_salesman fu_vendor fu_customer fu_shipment
                            fu_lfa1 fu_znopol
                   CHANGING fc_butxt fc_bezei fc_gtext fc_description
                            fc_salesman fc_vendor fc_customer fc_shipment
                            fc_lfa1 fc_znopol.
  CASE fu_value.
    WHEN 'C'.
      fc_butxt         = fu_butxt.
      fc_bezei         = fu_bezei.
      fc_gtext         = fu_gtext.
      fc_description   = fu_description.
      fc_salesman      = fu_salesman.
      fc_vendor        = fu_vendor.
      fc_customer      = fu_customer.
      fc_shipment      = fu_shipment.
      fc_lfa1          = fu_lfa1.

    WHEN OTHERS.
      SELECT SINGLE butxt
        FROM t001
        INTO fc_butxt
        WHERE bukrs = pa_bukrs.

      SELECT SINGLE bezei
        FROM tvkbt
        INTO fc_bezei
        WHERE spras = sy-langu
          AND vkbur = pa_vkbur.

      SELECT SINGLE gtext
        FROM tgsbt
        INTO fc_gtext
        WHERE spras = sy-langu
          AND gsber = pa_gsber.

      fc_description  = gs_gtype-description.
      fc_salesman     = gs_gtype-salesman.
      fc_vendor       = gs_gtype-vendor.
      fc_customer     = gs_gtype-customer.
      fc_shipment     = gs_gtype-shipment.
      fc_lfa1         = gs_gtype-lfa1.
      fc_znopol       = gs_gtype-znopol.
  ENDCASE.
ENDFORM.                    " F_TEXT_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE sy-tcode.
    WHEN 'ZF63B'.
      PERFORM f_modify_screen USING : 'R15' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'R16' '0' '' '' '',
                                      'R17' '0' '' '' ''.
    WHEN 'ZF63N'.
      PERFORM f_modify_screen USING : 'R04' '0' '' '' '',
                                      'R05' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'R09' '0' '' '' '',
                                      'R10' '0' '' '' '',
                                      'R11' '0' '' '' '',
                                      'R12' '0' '' '' '',
                                      'R13' '0' '' '' ''.
  ENDCASE.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PGT' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PID' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
    WHEN radio4 OR radio14 OR radio15.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
      IF radio14 IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'PCT' '0' '' '' '',
                                        'PBE' '0' '' '' ''.
      ENDIF.

    WHEN radio5.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

    WHEN radio6.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

    WHEN radio7.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
    WHEN radio8.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
    WHEN radio9.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'PGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.
      IF so_budat[] IS INITIAL.
        CONCATENATE sy-datum(6) '01' INTO so_budat-low.
        so_budat-high   = sy-datum.
        so_budat-sign   = 'I'.
        so_budat-option = 'BT'.
        APPEND so_budat.
        CLEAR so_budat.
      ENDIF.

    WHEN radio10.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'PVK' '0' '' '' '',
                                      'PGS' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

      IF so_budat[] IS INITIAL.
        CONCATENATE sy-datum(6) '01' INTO so_budat-low.
        so_budat-high   = sy-datum.
        so_budat-sign   = 'I'.
        so_budat-option = 'BT'.
        APPEND so_budat.
        CLEAR so_budat.
      ENDIF.

    WHEN radio11.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'PVK' '0' '' '' '',
                                      'PGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'PGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

      IF so_budat[] IS INITIAL.
        CONCATENATE sy-datum(6) '01' INTO so_budat-low.
        so_budat-high   = sy-datum.
        so_budat-sign   = 'I'.
        so_budat-option = 'BT'.
        APPEND so_budat.
        CLEAR so_budat.
      ENDIF.

    WHEN radio12.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'PVK' '0' '' '' '',
                                      'PGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'PGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

      IF so_budat[] IS INITIAL.
        CONCATENATE sy-datum(6) '01' INTO so_budat-low.
        so_budat-high   = sy-datum.
        so_budat-sign   = 'I'.
        so_budat-option = 'BT'.
        APPEND so_budat.
        CLEAR so_budat.
      ENDIF.

    WHEN radio13.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PVC' '0' '' '' '',
                                      'PV2' '0' '' '' '',
                                      'PX1' '0' '' '' '',
                                      'PX2' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PVK' '0' '' '' '',
                                      'PGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'PVJ' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' '',
                                      'PBE' '0' '' '' ''.

      IF so_budat[] IS INITIAL.
        CONCATENATE sy-datum(6) '01' INTO so_budat-low.
        so_budat-high   = sy-datum.
        so_budat-sign   = 'I'.
        so_budat-option = 'BT'.
        APPEND so_budat.
        CLEAR so_budat.
      ENDIF.
      IF pa_gtype IS INITIAL.
        pa_gtype = '10'.
      ENDIF.

    WHEN radio17.
      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
                                      'PID' '0' '' '' '',
                                      'SEN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SVC' '0' '' '' '',
                                      'SV2' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SVK' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PKA' '0' '' '' '',
                                      'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SGT' '0' '' '' '',
                                      'SID' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'CHK' '0' '' '' '',
                                      'PCT' '0' '' '' ''.

*    WHEN radio16.
*      PERFORM f_modify_screen USING : 'PKE' '0' '' '' '',
*                                      'PID' '0' '' '' '',
*                                      'PMJ' '0' '' '' '',
*                                      'SEN' '0' '' '' '',
*                                      'PVC' '0' '' '' '',
*                                      'PV2' '0' '' '' '',
*                                      'PGT' '0' '' '' '',
*                                      'PX1' '0' '' '' '',
*                                      'PX2' '0' '' '' '',
*                                      'PBD' '0' '' '' '',
*                                      'SVC' '0' '' '' '',
*                                      'SV2' '0' '' '' '',
*                                      'SER' '0' '' '' '',
*                                      'SBD' '0' '' '' '',
*                                      'SVK' '0' '' '' '',
*                                      'SGS' '0' '' '' '',
*                                      'PKA' '0' '' '' '',
*                                      'SNA' '0' '' '' '',
*                                      'SNO' '0' '' '' '',
*                                      'SGT' '0' '' '' '',
*                                      'SID' '0' '' '' '',
*                                      'PST' '0' '' '' '',
*                                      'PVJ' '0' '' '' '',
*                                      'CHK' '0' '' '' '',
*                                      'PCT' '0' '' '' '',
*                                      'PBU' '0' '' '' '',
*                                      'PVK' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_gtype TYPE zf63masterperson-gtype,
         lv_subrc TYPE sy-subrc,
         lv_gsber TYPE tgsb-gsber.

*  IF radio16 IS INITIAL.
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ELSE.
    PERFORM f_master_check USING 'T001' 'BUKRS' pa_bukrs
                           CHANGING lv_subrc.
    IF lv_subrc IS NOT INITIAL.
      PERFORM f_error_message USING 'PBU' 'Company Code not defined'.
    ENDIF.
  ENDIF.
*  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      PERFORM f_cek_authorization USING '01'.

    WHEN radio2.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.
      PERFORM f_cek_number_range USING 'ZIDKEND' '01' '' ''.
      PERFORM f_cek_authorization USING '01'.

    WHEN radio3.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.
      PERFORM f_cek_number_range USING 'ZIDPERSON' '01' '' ''.
      PERFORM f_cek_authorization USING '01'.

    WHEN radio4 OR radio14.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF radio4 IS NOT INITIAL.
        IF pa_ctype IS NOT INITIAL.
          PERFORM f_master_check USING 'ZF63CTRLTYPE' 'TYPE_CTRL' pa_ctype
                                 CHANGING lv_subrc.
          IF lv_subrc IS NOT INITIAL.
            PERFORM f_error_message USING 'PCT' 'Type not defined'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        IF radio4 IS NOT INITIAL.
          PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                                 CHANGING lv_subrc.
          IF lv_subrc IS NOT INITIAL.
            PERFORM f_error_message USING 'PGT' 'Type not defined'.
          ENDIF.
        ELSE.
          PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                                 CHANGING lv_subrc.
          IF lv_subrc IS NOT INITIAL.
            PERFORM f_error_message USING 'PGT' 'Type not defined'.
          ENDIF.
        ENDIF.
      ENDIF.

      PERFORM f_dynp_value_read USING 'PA_VKBUR'
                          CHANGING lv_gsber.

      PERFORM f_cek_number_range USING 'ZIDEXP' '01'
                                       lv_gsber sy-datum(4).
      PERFORM f_cek_authorization USING '02'.

    WHEN radio5.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.

      PERFORM f_dynp_value_read USING 'PA_VKBUR'
                                CHANGING lv_gsber.

      PERFORM f_cek_number_range USING 'ZIDVCH' '01'
                                       lv_gsber sy-datum(4).
      PERFORM f_cek_authorization USING '02'.

    WHEN radio6.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.

      CASE sy-tcode.
        WHEN 'ZF63B'.
          IF pa_zidvc IS INITIAL.
            PERFORM f_error_message USING 'PVC' ''.
          ENDIF.
        WHEN 'ZF63N'.
          IF pa_zidv2 IS INITIAL.
            PERFORM f_error_message USING 'PV2' ''.
          ENDIF.
      ENDCASE.
      PERFORM f_cek_authorization USING '01'.

    WHEN radio7.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.

      CASE sy-tcode.
        WHEN 'ZF63B'.
          IF pa_zidvc IS INITIAL.
            PERFORM f_error_message USING 'PVC' ''.
          ENDIF.
        WHEN 'ZF63N'.
          IF pa_zidv2 IS INITIAL.
            PERFORM f_error_message USING 'PV2' ''.
          ENDIF.
      ENDCASE.

      PERFORM f_cek_authorization USING 'G7'.

    WHEN radio8.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.

      PERFORM f_cek_authorization USING '02'.

    WHEN radio9.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
*      IF pa_gsber IS INITIAL.
*        PERFORM f_error_message USING 'PGS' ''.
*      ELSE.
*        PERFORM f_master_check USING 'TGSB' 'GSBER' pa_gsber
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGS' 'Business Area not defined'.
*        ENDIF.
*      ENDIF.
*      IF pa_gtype IS INITIAL.
*        PERFORM f_error_message USING 'PGT' ''.
*      ELSE.
*        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
*                               CHANGING lv_subrc.
*        IF lv_subrc IS NOT INITIAL.
*          PERFORM f_error_message USING 'PGT' 'Type not defined'.
*        ENDIF.
*      ENDIF.
      PERFORM f_cek_authorization USING '03'.

    WHEN radio10.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.
      PERFORM f_cek_authorization USING '03'.

    WHEN radio11.
      PERFORM f_cek_authorization USING '03'.

    WHEN radio12.
      PERFORM f_cek_authorization USING '03'.

    WHEN radio13.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.
      PERFORM f_cek_authorization USING '03'.

    WHEN radio15.
      PERFORM f_cek_authorization USING '02'.

    WHEN radio17.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_message USING 'PVK' ''.
      ELSE.
        PERFORM f_master_check USING 'TVBUR' 'VKBUR' pa_vkbur
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PVK' 'Sales Office not defined'.
        ENDIF.
      ENDIF.
      IF pa_gtype IS INITIAL.
        PERFORM f_error_message USING 'PGT' ''.
      ELSE.
        PERFORM f_master_check USING 'ZF63GTYPE' 'GTYPE' pa_gtype
                               CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type not defined'.
        ENDIF.
      ENDIF.
      IF pa_zidv2 IS INITIAL.
        PERFORM f_error_message USING 'PV2' ''.
      ENDIF.
      IF pa_belnr IS INITIAL.
        PERFORM f_error_message USING 'PBE' ''.
      ELSE.
        PERFORM f_cancel_check CHANGING lv_subrc.
        IF lv_subrc IS NOT INITIAL.
          PERFORM f_error_message USING 'PBE' 'Document number not defined'.
        ENDIF.
      ENDIF.
      PERFORM f_cek_authorization USING '01'.
  ENDCASE.

  IF pa_gtype IS NOT INITIAL OR
    so_gtype[] IS NOT INITIAL.
    CASE 'X'.
      WHEN radio9 OR radio11 OR radio12.
        CLEAR pa_gtype.
      WHEN OTHERS.
        CLEAR : so_gtype[], so_gtype.
    ENDCASE.
    PERFORM f_gtype_authorization.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : lt_mstk     TYPE STANDARD TABLE OF zf63masterkend INITIAL SIZE 0,
         ls_mstk     LIKE LINE OF gt_mstk,
         ls_zf63mstk LIKE zf63masterkend,
         ls_zf63mk   LIKE LINE OF lt_mstk,
         lt_mstp     TYPE STANDARD TABLE OF zf63masterperson INITIAL SIZE 0,
         ls_mstp     LIKE LINE OF lt_mstp,
         lt_plat     TYPE STANDARD TABLE OF zf63plat INITIAL SIZE 0,
         lt_xplat    TYPE STANDARD TABLE OF zf63plat INITIAL SIZE 0,
         lt_yplat    TYPE STANDARD TABLE OF zf63plat INITIAL SIZE 0,
         ls_plat     LIKE LINE OF lt_plat,
         lt_insra    TYPE STANDARD TABLE OF zf63asset INITIAL SIZE 0,
         lt_delea    TYPE STANDARD TABLE OF zf63asset INITIAL SIZE 0,
         ls_asset    LIKE LINE OF lt_insra,
         lv_zidke    TYPE zf63masterkend-zidke,
         lv_kdvch    TYPE zf63nomor-kdvch,
         lv_zidno    TYPE zf63masterperson-zidno,
         lv_expnr    TYPE zf63trndtl-expnr,
         lv_zidvc    TYPE zf63trnhdr2-zidvc,
         lv_zidvc2   TYPE zf63trnhdr2-zidvc,
         lv_shkzg    TYPE zf63trnhdr2-shkzg,
         lv_cnt01    TYPE p,
         lt_nopol    TYPE STANDARD TABLE OF ty_mstk INITIAL SIZE 0,
         ls_save     LIKE LINE OF gt_save,
         lt_trnhdr   TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         ls_trnhdr   LIKE LINE OF lt_trnhdr,
         lt_trndtl   TYPE STANDARD TABLE OF zf63trndtl INITIAL SIZE 0,
         ls_trndtl   LIKE LINE OF lt_trndtl,
         ls_ship     LIKE LINE OF gt_ship,
         lt_trnshp   TYPE STANDARD TABLE OF zf63trnshp INITIAL SIZE 0,
         ls_trnshp   LIKE LINE OF lt_trnshp,
         lt_kmh      TYPE STANDARD TABLE OF zf63kmhexph INITIAL SIZE 0,
         ls_kmh      LIKE LINE OF lt_kmh,
         ls_anla     LIKE LINE OF gt_anla.

  DATA : ls_ctrladv   TYPE zf63ctrladv.

  DATA : lt_trnhdr2 TYPE STANDARD TABLE OF zf63trnhdr2 INITIAL SIZE 0,
         ls_trnhdr2 LIKE LINE OF lt_trnhdr2,
         lt_trndtl2 TYPE STANDARD TABLE OF zf63trndtl2 INITIAL SIZE 0,
         ls_trndtl2 LIKE LINE OF lt_trndtl2,
         ls_trnshp2 LIKE LINE OF gt_trnshp2,
         ls_zf63acc LIKE LINE OF gt_zf63acc.

  CASE 'X'.
    WHEN radio2.
      CLEAR : ls_mstk, lv_zidke.

      lt_nopol[] = gt_mstk[].
      DELETE lt_nopol WHERE znopol = space.

      IF lt_nopol[] IS INITIAL.
        MESSAGE s000(zab) WITH 'Nomor Polisi harus diisi' DISPLAY LIKE 'E'.
      ELSE.
        IF zfmstken-zidke IS INITIAL.
        ENDIF.

        LOOP AT gt_mstk INTO ls_mstk.
          IF ls_mstk-loevm IS INITIAL.
            ADD 1 TO lv_cnt01.
          ENDIF.
          PERFORM f_prepare_save_data TABLES lt_mstk lt_plat
                                      USING ls_mstk.
          CLEAR ls_mstk.
        ENDLOOP.

        CLEAR : ls_mstk.
        READ TABLE gt_mstk INTO ls_mstk INDEX 1.
        IF sy-subrc = 0.
          IF gv_bukrs = ls_mstk-bukrs AND
            gv_anln1 = ls_mstk-anln1 AND
            gv_anln2 = ls_mstk-anln2.
          ELSE.
            ls_asset-anln1       = gv_anln1.
            ls_asset-anln2       = gv_anln2.
            ls_asset-bukrs       = gv_bukrs.
            APPEND ls_asset TO lt_delea.
            CLEAR ls_asset.
            IF ls_mstk-anln1 IS NOT INITIAL.
              ls_asset-anln1       = ls_mstk-anln1.
              ls_asset-anln2       = ls_mstk-anln2.
              ls_asset-bukrs       = ls_mstk-bukrs.
              APPEND ls_asset TO lt_insra.
            ENDIF.
            CLEAR ls_asset.
          ENDIF.
        ENDIF.

        IF ls_mstk-anln1 IS NOT INITIAL.
          SELECT SINGLE *
            FROM zf63masterkend
            INTO CORRESPONDING FIELDS OF ls_zf63mstk
            WHERE anln1 = ls_mstk-anln1
              AND anln2 = ls_mstk-anln2.
          IF sy-subrc = 0.
            IF ls_zf63mstk-bukrs = zfmstken-bukrs AND
              ls_zf63mstk-vkbur = zfmstken-vkbur AND
              ls_zf63mstk-gsber = zfmstken-gsber AND
              ls_zf63mstk-gtype = zfmstken-gtype AND
              ls_zf63mstk-zidke = zfmstken-zidke.
            ELSE.
              lv_cnt01  = 8.
            ENDIF.
          ENDIF.
        ENDIF.

        CASE lv_cnt01.
          WHEN 0.
            MESSAGE s000(zab) WITH 'Nomor Polisi harus diisi' DISPLAY LIKE 'E'.
          WHEN 1.
            IF zfmstken-zidke IS INITIAL.
              PERFORM f_get_next_number USING 'ZIDKEND' '' '' '' '' ''
                                        CHANGING lv_zidke lv_kdvch.

              LOOP AT lt_mstk INTO ls_zf63mk.
                ls_zf63mk-zidke = lv_zidke.
                MODIFY lt_mstk FROM ls_zf63mk.
                CLEAR ls_zf63mk.
              ENDLOOP.

              INSERT zf63masterkend FROM TABLE lt_mstk.
              INSERT zf63plat FROM TABLE lt_plat.
              MESSAGE s000(zab) WITH 'Data already saved' lv_zidke.
            ELSE.
              MODIFY zf63masterkend FROM TABLE lt_mstk.
              MODIFY zf63plat FROM TABLE lt_plat.
              lt_xplat[]  = lt_plat[].
              DELETE lt_xplat WHERE loevm = 'X'.
              DELETE lt_plat WHERE loevm = space.
              IF lt_plat[] IS NOT INITIAL.
                DELETE zf63plat FROM TABLE lt_plat.
              ENDIF.
              IF lt_xplat[] IS NOT INITIAL.
                SELECT *
                  FROM zf63plat
                  INTO CORRESPONDING FIELDS OF TABLE lt_yplat
                  FOR ALL ENTRIES IN lt_xplat
                  WHERE bukrs   = lt_xplat-bukrs
                    AND vkbur   = lt_xplat-vkbur
                    AND gsber   = lt_xplat-gsber
                    AND znopol  = lt_xplat-znopol.
                IF sy-subrc <> 0.
                  INSERT zf63plat FROM TABLE lt_xplat.
                ENDIF.
              ENDIF.
              MESSAGE s000(zab) WITH 'Data already updated'.
            ENDIF.

            IF lt_delea[] IS NOT INITIAL.
              DELETE zf63asset FROM TABLE lt_delea.
            ENDIF.
            IF lt_insra[] IS NOT INITIAL.
              INSERT zf63asset FROM TABLE lt_insra.
            ENDIF.

            LEAVE TO SCREEN 0.
          WHEN 8.
            MESSAGE s000(zab) WITH 'Nomor Asset sudah digunakan'
                              DISPLAY LIKE 'E'.
          WHEN OTHERS.
            MESSAGE s000(zab) WITH 'Daftar Nomor Polisi tidak boleh lebih dari satu'
                              DISPLAY LIKE 'E'.
        ENDCASE.
      ENDIF.

    WHEN radio3.
      IF zfmstper-zidno IS INITIAL.
        PERFORM f_get_next_number USING 'ZIDPERSON' '' '' '' '' ''
                                  CHANGING lv_zidno lv_kdvch.
      ELSE.
        lv_zidno = zfmstper-zidno.
      ENDIF.

      ls_mstp-bukrs       = zfmstper-bukrs.
      ls_mstp-gsber       = zfmstper-gsber.
      ls_mstp-vkbur       = zfmstper-vkbur.
      ls_mstp-gtype       = zfmstper-gtype.
      ls_mstp-zidno       = lv_zidno.
      ls_mstp-zidke       = zfmstper-zidke.
      ls_mstp-pernr       = zfmstper-pernr.
      ls_mstp-lifnr       = zfmstper-lifnr.
      ls_mstp-kunnr       = zfmstper-kunnr.
      ls_mstp-name1       = zfmstper-name1.
      ls_mstp-katr1       = zfmstper-katr1.
      ls_mstp-kostl       = zfmstper-kostl.
      ls_mstp-wwpfn       = zfmstper-wwpfn.
      ls_mstp-wwsfr       = zfmstper-wwsfr.
      ls_mstp-wwpos       = zfmstper-wwpos.

      IF ls_mstp-kostl IS NOT INITIAL.
        READ TABLE gt_anla INTO ls_anla WITH KEY anln1 = ls_mstk-anln1
                                                 anln2 = ls_mstk-anln2.
        IF sy-subrc = 0.
          IF zfmstper-kostl+7(3) = '101' OR
            zfmstper-kostl+7(3) = '109'.
            IF zfmstper-wwsfr IS INITIAL.
              zfmstper-wwsfr = ls_anla-ord41.
            ENDIF.
          ELSEIF zfmstper-kostl+7(3) = '201'.
            IF zfmstper-wwpos IS INITIAL.
              zfmstper-wwpos = ls_anla-ord41.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      ls_mstp-vbund       = zfmstper-vbund.
      ls_mstp-jabatpd     = zfmstper-jabatpd.
      ls_mstp-keterangan  = zfmstper-keterangan.
      APPEND ls_mstp TO lt_mstp.

      IF zfmstper-zidno IS INITIAL.
        INSERT zf63masterperson FROM TABLE lt_mstp.
        MESSAGE s000(zab) WITH 'Data already saved' lv_zidno.
      ELSE.
        MODIFY zf63masterperson FROM TABLE lt_mstp.
        MESSAGE s000(zab) WITH 'Data already updated'.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN radio4 OR radio14.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_get_next_number USING 'ZIDEXP' pa_gsber sy-datum(4)
                                          '' '' ''
                                    CHANGING lv_expnr lv_kdvch.

          SORT gt_kmh BY type item bldat buzei DESCENDING.
          LOOP AT gt_save INTO ls_save.
            IF lt_trnhdr[] IS INITIAL.
              ls_trnhdr-bukrs         = ls_save-bukrs.
              ls_trnhdr-gsber         = ls_save-gsber.
              ls_trnhdr-vkbur         = ls_save-vkbur.
              ls_trnhdr-gtype         = ls_save-gtype.
              ls_trnhdr-expnr         = lv_expnr.
              ls_trnhdr-gjahr         = sy-datum(4).
              ls_trnhdr-zidno         = ls_save-zidno.
              ls_trnhdr-znopol        = ls_save-znopol.
              ls_trnhdr-bktxt         = ls_save-bktxt.
              ls_trnhdr-waers         = ls_save-waers.
              ls_trnhdr-wrbtr         = abs( gv_azsal ).
              ls_trnhdr-shkzg         = ls_save-shkzg.
              ls_trnhdr-ernam         = sy-uname.
              ls_trnhdr-erdat         = sy-datum.
              ls_trnhdr-erzet         = sy-uzeit.
              ls_trnhdr-rekanan       = ls_save-rekanan.
              APPEND ls_trnhdr TO lt_trnhdr.
              CLEAR ls_trnhdr.
            ENDIF.

            ls_trndtl-bukrs         = ls_save-bukrs.
            ls_trndtl-gsber         = ls_save-gsber.
            ls_trndtl-vkbur         = ls_save-vkbur.
            ls_trndtl-gtype         = ls_save-gtype.
            ls_trndtl-expnr         = lv_expnr.
            ls_trndtl-type          = ls_save-type.
            ls_trndtl-buzei         = ls_save-buzei.
            ls_trndtl-gjahr         = sy-datum(4).
            ls_trndtl-meins         = ls_save-meins.
            ls_trndtl-menge         = ls_save-menge.
            ls_trndtl-speed         = ls_save-speed.
            ls_trndtl-kmstr         = ls_save-kmstr.
            ls_trndtl-kmend         = ls_save-kmend.
            ls_trndtl-description   = ls_save-description.

            IF ls_save-trf_inap IS NOT INITIAL.
              ls_trndtl-tarif         = ls_save-trf_inap.
            ENDIF.
            IF ls_save-trf_hari IS NOT INITIAL.
              ls_trndtl-tarif         = ls_save-trf_hari.
            ENDIF.
            ls_trndtl-waers         = ls_save-waers.
            ls_trndtl-wrbtr         = ls_save-wrbtr.
            ls_trndtl-shkzg         = ls_save-shkzg.
            ls_trndtl-text          = ls_save-text.
            ls_trndtl-vbund         = ls_save-vbund.
            APPEND ls_trndtl TO lt_trndtl.
            CLEAR ls_trndtl.

            READ TABLE gt_kmh INTO ls_kmh WITH KEY bukrs   = ls_save-bukrs
                                                   gsber   = ls_save-gsber
                                                   vkbur   = ls_save-vkbur
                                                   znopol  = ls_save-znopol
                                                   type    = ls_save-type
                                                   item    = ls_save-buzei
                                                   bldat   = sy-datum.
            IF sy-subrc = 0.
              ADD 1 TO ls_kmh-buzei.
            ELSE.
              ls_kmh-buzei = 1.
            ENDIF.

            ls_kmh-bukrs         = ls_save-bukrs.
            ls_kmh-gsber         = ls_save-gsber.
            ls_kmh-vkbur         = ls_save-vkbur.
            ls_kmh-znopol        = ls_save-znopol.
            ls_kmh-type          = ls_save-type.
            ls_kmh-item          = ls_save-buzei.
            ls_kmh-bldat         = sy-datum.
            ls_kmh-speed         = ls_save-speed.
            ls_kmh-kmstr         = ls_save-kmstr.
            ls_kmh-kmend         = ls_save-kmend.
            ls_kmh-expnr         = lv_expnr.
            ls_kmh-lvorm         = space.
            IF ls_save-kmstr IS NOT INITIAL OR
              ls_save-kmend IS NOT INITIAL.
              APPEND ls_kmh TO lt_kmh.
            ENDIF.
            CLEAR ls_kmh.
          ENDLOOP.

          LOOP AT gt_ship INTO ls_ship.
            ls_trnshp-bukrs   = ls_ship-bukrs.
            ls_trnshp-gsber   = ls_ship-gsber.
            ls_trnshp-vkbur   = ls_ship-vkbur.
            ls_trnshp-gtype   = ls_ship-gtype.
            ls_trnshp-expnr   = lv_expnr.
            ls_trnshp-tknum   = ls_ship-tknum.
            ls_trnshp-gjahr   = sy-datum(4).
            ls_trnshp-erdat   = ls_ship-erdat.
            APPEND ls_trnshp TO lt_trnshp.
            CLEAR ls_trnshp.
          ENDLOOP.

          INSERT zf63trnhdr FROM TABLE lt_trnhdr.
          INSERT zf63trndtl FROM TABLE lt_trndtl.
          INSERT zf63trnshp FROM TABLE lt_trnshp.
          IF radio4 IS NOT INITIAL.
            INSERT zf63kmhexph FROM TABLE lt_kmh.
          ENDIF.
          MODIFY zf63ctrladv FROM gs_ctrladv.

          CLEAR : lt_trnhdr[], lt_trnhdr, lt_trndtl[], lt_trndtl,
                  lt_trnshp[], lt_trnshp, gs_ctrladv.

          MESSAGE s000(zab) WITH 'Data already saved' lv_expnr.
          LEAVE TO SCREEN 0.

        WHEN 'ZF63N'.
          MODIFY zf63ctrladv FROM gs_ctrladv.

          LOOP AT gt_save INTO ls_save.
            IF lt_trnhdr2[] IS INITIAL.
              ls_trnhdr2-bukrs    = ls_save-bukrs.
              ls_trnhdr2-gsber    = ls_save-gsber.
              ls_trnhdr2-vkbur    = ls_save-vkbur.
              ls_trnhdr2-gtype    = ls_save-gtype.
              ls_trnhdr2-gjahr    = sy-datum(4).
              CONCATENATE gv_kdvch '/' sy-datum(6) '/' gv_nomor
              INTO ls_trnhdr2-zidvc.
              ls_trnhdr2-zidno    = ls_save-zidno.
              ls_trnhdr2-bktxt    = ls_save-bktxt.
              ls_trnhdr2-waers    = ls_save-waers.
              ls_trnhdr2-wrbtr    = abs( gv_azsal ).
              ls_trnhdr2-shkzg    = ls_save-shkzg.
              ls_trnhdr2-ernam    = sy-uname.
              ls_trnhdr2-erdat    = sy-datum.
              ls_trnhdr2-erzet    = sy-uzeit.
              ls_trnhdr2-rekanan  = ls_save-rekanan.
              ls_trnhdr2-hkont    = gs_header-hkont.
              APPEND ls_trnhdr2 TO lt_trnhdr2.
              CLEAR ls_trnhdr2.
            ENDIF.

            ls_trndtl2-bukrs         = ls_save-bukrs.
            ls_trndtl2-gsber         = ls_save-gsber.
            ls_trndtl2-vkbur         = ls_save-vkbur.
            ls_trndtl2-gtype         = ls_save-gtype.
            CONCATENATE gv_kdvch '/' sy-datum(6) '/' gv_nomor
            INTO ls_trndtl2-zidvc.
            ls_trndtl2-type          = ls_save-type.
            ls_trndtl2-buzei         = ls_save-buzei.
            ls_trndtl2-gjahr         = sy-datum(4).
            ls_trndtl2-meins         = ls_save-meins.
            ls_trndtl2-menge         = ls_save-menge.
            ls_trndtl2-znopol        = ls_save-znopol.
            ls_trndtl2-speed         = ls_save-speed.
            ls_trndtl2-kmstr         = ls_save-kmstr.
            ls_trndtl2-kmend         = ls_save-kmend.
            ls_trndtl2-description   = ls_save-description.
            IF ls_save-trf_inap IS NOT INITIAL.
              ls_trndtl2-tarif         = ls_save-trf_inap.
            ENDIF.
            IF ls_save-trf_hari IS NOT INITIAL.
              ls_trndtl2-tarif         = ls_save-trf_hari.
            ENDIF.
            ls_trndtl2-waers         = ls_save-waers.
            ls_trndtl2-wrbtr         = ls_save-wrbtr.
            ls_trndtl2-shkzg         = ls_save-shkzg.
            ls_trndtl2-text          = ls_save-text.
            ls_trndtl2-vbund         = ls_save-vbund.
            APPEND ls_trndtl2 TO lt_trndtl2.
            CLEAR ls_trndtl2.
          ENDLOOP.

          lv_zidvc  = ls_trndtl2-zidvc.

          INSERT zf63trnhdr2 FROM TABLE lt_trnhdr2.
          INSERT zf63trndtl2 FROM TABLE lt_trndtl2.

          CLEAR : lt_trnhdr2[], lt_trnhdr2, lt_trndtl2[], lt_trndtl2,
                  gs_ctrladv.

          MESSAGE s000(zab) WITH 'Data already saved' lv_zidvc.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN radio15.
      CLEAR ls_zf63acc.
      READ TABLE gt_zf63acc INTO ls_zf63acc
                            WITH KEY ktext = zfexpense-ktext.
      CLEAR ls_trnhdr2.
      READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
      IF sy-subrc = 0.
        lv_zidvc  = gv_zidvc.
        lv_zidvc2 = gv_zidvc2.

        IF gv_lock IS INITIAL.
          LOOP AT gt_trnhdr2 INTO ls_trnhdr2.
            ls_trnhdr2-zidvc   = lv_zidvc.
            ls_trnhdr2-zidvc2  = lv_zidvc2.
            MODIFY gt_trnhdr2 FROM ls_trnhdr2 TRANSPORTING zidvc zidvc2.
            CLEAR ls_trnhdr2.
          ENDLOOP.

          LOOP AT gt_trndtl2 INTO ls_trndtl2.
            ls_trndtl2-zidvc  = lv_zidvc.
            MODIFY gt_trndtl2 FROM ls_trndtl2 TRANSPORTING zidvc.
            CLEAR ls_trndtl2.
          ENDLOOP.

          PERFORM f_calculate_km TABLES lt_kmh
                                 USING lv_zidvc.

          LOOP AT gt_trnshp2 INTO ls_trnshp2.
            ls_trnshp2-zidvc = lv_zidvc.
            MODIFY gt_trnshp2 FROM ls_trnshp2 TRANSPORTING zidvc.
            CLEAR ls_trnshp2.
          ENDLOOP.

          INSERT zf63trnhdr2 FROM TABLE gt_trnhdr2.
          INSERT zf63trndtl2 FROM TABLE gt_trndtl2.
          INSERT zf63trnshp2 FROM TABLE gt_trnshp2.
          INSERT zf63kmhexph FROM TABLE lt_kmh.

          CLEAR : ls_kmh, lt_kmh[].

          CLEAR : gt_trnhdr2[], gt_trnhdr2, gt_trndtl2[], gt_trndtl2,
                  gt_trnshp2[], gt_trnshp2, gs_ctrladv.

          MESSAGE s000(zab) WITH 'Data already saved' lv_zidvc.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_object fu_subobject fu_year fu_spmon
                                 fu_shkzg fu_nmvch
                        CHANGING fc_number fc_kdvch.
  IF fu_object IS INITIAL.
    CALL FUNCTION 'ENQUEUE_EZF63NOMOR'
      EXPORTING
        bukrs          = pa_bukrs
        vkbur          = pa_vkbur
        spmon          = fu_spmon
        shkzg          = fu_shkzg
        nmvch          = fu_nmvch
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc = 0.
      CLEAR : fc_number, fc_kdvch.
      SELECT SINGLE nomor kdvch
        FROM zf63nomor
        INTO (fc_number, fc_kdvch)
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND spmon = fu_spmon
          AND shkzg = fu_shkzg
          AND nmvch = fu_nmvch.
      IF sy-subrc = 0.
        fc_number = fc_number + 1.
      ELSE.
        gv_lock = 'X'.
        MESSAGE s000(zab) WITH 'No.Voucher belum dimaintain'
                          DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      gv_lock = 'X'.
      MESSAGE s000(zab) WITH 'Transaction lock by another user'
                        DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    IF fu_subobject IS INITIAL.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = fu_object
        IMPORTING
          number                  = fc_number
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
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = fu_object
          subobject               = fu_subobject
          toyear                  = fu_year
        IMPORTING
          number                  = fc_number
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DATA : ls_mstk LIKE LINE OF gt_mstk,
         ls_ship LIKE LINE OF gt_ship.

  CASE 'X'.
    WHEN radio2.
      LOOP AT gt_mstk INTO ls_mstk.
        IF ls_mstk-mark IS NOT INITIAL.
          ls_mstk-loevm   = 'X'.
          ls_mstk-status  = icon_delete.
          MODIFY gt_mstk FROM ls_mstk TRANSPORTING loevm status.
        ENDIF.
        CLEAR ls_mstk.
      ENDLOOP.

    WHEN radio4.
      LOOP AT gt_ship INTO ls_ship.
        IF ls_ship-mark IS NOT INITIAL.
          DELETE TABLE gt_ship FROM ls_ship.
        ENDIF.
        CLEAR ls_ship.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_save_data  TABLES   ft_mstk STRUCTURE zf63masterkend
                                   ft_plat STRUCTURE zf63plat
                          USING    fs_mstk LIKE LINE OF gt_mstk.
  DATA : ls_mstk  TYPE zf63masterkend,
         ls_plat  TYPE zf63plat,
         ls_asset TYPE zf63asset,
         ls_anla  LIKE LINE OF gt_anla,
         ls_anlc  LIKE LINE OF gt_anlc.

  ls_mstk-bukrs       = fs_mstk-bukrs.
  ls_mstk-vkbur       = fs_mstk-vkbur.
  ls_mstk-gsber       = fs_mstk-gsber.
  ls_mstk-gtype       = fs_mstk-gtype.
  ls_mstk-zidke       = fs_mstk-zidke.
  ls_mstk-buzei       = fs_mstk-buzei.
  ls_mstk-znopol      = fs_mstk-znopol.
  ls_mstk-znorangka   = fs_mstk-znorangka.
  ls_mstk-anln1       = fs_mstk-anln1.
  ls_mstk-anln2       = fs_mstk-anln2.
  ls_mstk-jnskend     = fs_mstk-jnskend.
  ls_mstk-txt50       = fs_mstk-txt50.

  IF fs_mstk-zujhr IS INITIAL.
    CLEAR ls_anla.
    READ TABLE gt_anla INTO ls_anla WITH KEY anln1 = fs_mstk-anln1
                                             anln2 = fs_mstk-anln2.
    IF sy-subrc = 0.
      ls_mstk-zujhr  = ls_anla-zujhr.
    ENDIF.
  ELSE.
    ls_mstk-zujhr  = fs_mstk-zujhr.
  ENDIF.

  IF fs_mstk-answl IS INITIAL.
    CLEAR ls_anlc.
    READ TABLE gt_anlc INTO ls_anlc WITH KEY anln1 = fs_mstk-anln1
                                             anln2 = fs_mstk-anln2
                                             gjahr = ls_mstk-zujhr.
    IF sy-subrc = 0.
      ls_mstk-answl  = ls_anlc-answl.
    ENDIF.
  ELSE.
    ls_mstk-answl       = fs_mstk-answl.
  ENDIF.

  ls_mstk-loevm       = fs_mstk-loevm.
  ls_mstk-keterangan  = fs_mstk-keterangan.
  APPEND ls_mstk TO ft_mstk.

  ls_plat-bukrs       = fs_mstk-bukrs.
  ls_plat-vkbur       = fs_mstk-vkbur.
  ls_plat-gsber       = fs_mstk-gsber.
  ls_plat-znopol      = fs_mstk-znopol.
  ls_plat-loevm       = fs_mstk-loevm.
  APPEND ls_plat TO ft_plat.
ENDFORM.                    " F_PREPARE_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_READ_MASTER_KENDARAAN
*&---------------------------------------------------------------------*
FORM f_read_master_kendaraan  USING    fu_zidke fu_f4.
  DATA : ls_mstk LIKE LINE OF gt_mstk,
         ls_anlz LIKE LINE OF gt_anlz,
         ls_anla LIKE LINE OF gt_anla.

  READ TABLE gt_mstk INTO ls_mstk WITH KEY zidke = fu_zidke.
  IF sy-subrc = 0.
    PERFORM f_dynpfield TABLES dynpfields
                        USING 'ZFMSTPER-ZIDKE' fu_zidke ''.
    PERFORM f_dynpfield TABLES dynpfields
                        USING 'ZFMSTPER-ZNOPOL' ls_mstk-znopol ''.

    IF fu_f4 IS INITIAL.
      zfmstper-znopol = ls_mstk-znopol.
    ENDIF.

    IF ls_mstk-anln1 IS NOT INITIAL.
      READ TABLE gt_anlz INTO ls_anlz WITH KEY anln1 = ls_mstk-anln1
                                               anln2 = ls_mstk-anln2.
      IF sy-subrc = 0.
        zfmstper-kostl = ls_anlz-kostl.
        READ TABLE gt_anla INTO ls_anla WITH KEY anln1 = ls_mstk-anln1
                                                 anln2 = ls_mstk-anln2.
        IF sy-subrc = 0.
          IF ls_anla-ord41 IS NOT INITIAL.
            IF zfmstper-kostl+7(3) = '101' OR
              zfmstper-kostl+7(3) = '109'.
              zfmstper-wwsfr = ls_anla-ord41.
              PERFORM f_get_description USING 'T25A5' 'BEZEK' 'WWSFR'
                                              zfmstper-wwsfr
                                        CHANGING gs_mstp-bezeksfr.
            ELSEIF zfmstper-kostl+7(3) = '201'.
              zfmstper-wwpos = ls_anla-ord41.
              PERFORM f_get_description USING 'T25A8' 'BEZEK' 'WWPOS'
                                              zfmstper-wwpos
                                        CHANGING gs_mstp-bezekpos.
            ENDIF.
          ENDIF.
*          IF ls_anla-vbund IS NOT INITIAL.
*            zfmstper-vbund  = ls_anla-vbund.
*          ENDIF.
        ENDIF.
        gv_input  = '0'.
      ELSE.
        CLEAR : zfmstper-kostl, zfmstper-wwsfr, zfmstper-wwpos,
                gs_mstp-ktext, gs_mstp-bezeksfr, gs_mstp-bezekpos.
        gv_input  = '1'.
      ENDIF.
    ELSE.
      IF zfmstper-kostl IS NOT INITIAL.
        PERFORM f_get_description USING 'CSKT' 'KTEXT' 'KOSTL'
                                        zfmstper-kostl
                                  CHANGING gs_mstp-ktext.
      ENDIF.
      IF zfmstper-wwsfr IS NOT INITIAL.
        PERFORM f_get_description USING 'T25A5' 'BEZEK' 'WWSFR'
                                        zfmstper-wwsfr
                                  CHANGING gs_mstp-bezeksfr.
      ENDIF.
      IF zfmstper-wwpos IS NOT INITIAL.
        PERFORM f_get_description USING 'T25A8' 'BEZEK' 'WWPOS'
                                        zfmstper-wwpos
                                  CHANGING gs_mstp-bezekpos.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_READ_MASTER_KENDARAAN

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_CONVERSION
*&---------------------------------------------------------------------*
FORM f_alpha_conversion  USING    fu_value
                         CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_ALPHA_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_ZIDKE
*&---------------------------------------------------------------------*
FORM f_value_zidke USING fu_field.
  DATA : BEGIN OF lt_kend OCCURS 0,
           zidke  TYPE zf63masterkend-zidke,
           znopol TYPE zf63masterkend-znopol,
         END OF lt_kend.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_kend  LIKE LINE OF lt_kend,
         lv_zidke TYPE zf63masterkend-zidke,
         lv_subrc TYPE sy-subrc,
         lv_bukrs TYPE zf63masterkend-bukrs,
         lv_vkbur TYPE zf63masterkend-vkbur,
         lv_gsber TYPE zf63masterkend-gsber.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_VKBUR'
                            CHANGING lv_vkbur.
  lv_gsber  = lv_vkbur.

  CLEAR : lt_kend[], lt_kend, dynpfields[], dynpfields.
  SELECT zidke znopol
    FROM zf63masterkend
    INTO CORRESPONDING FIELDS OF TABLE lt_kend
      WHERE bukrs = lv_bukrs
        AND vkbur = lv_vkbur
        AND gsber = lv_gsber
        AND loevm = space.

  ASSIGN lt_kend[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDKE' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidke  = ls_return-fieldval.
      READ TABLE lt_kend INTO ls_kend WITH KEY zidke = lv_zidke.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_kend-zidke ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field '' ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_ZIDKE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_ZIDNO
*&---------------------------------------------------------------------*
FORM f_value_zidno USING fu_field.
  DATA : BEGIN OF lt_person OCCURS 0,
           zidno TYPE zf63masterperson-zidno,
           name1 TYPE zf63masterperson-name1,
         END OF lt_person.

  DATA : lt_mstp TYPE STANDARD TABLE OF zf63masterperson INITIAL SIZE 0,
         ls_mstp LIKE LINE OF lt_mstp.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_person LIKE LINE OF lt_person,
         lv_zidno  TYPE zf63masterperson-zidno,
         lv_subrc  TYPE sy-subrc,
         lv_bukrs  TYPE zf63masterperson-bukrs,
         lv_vkbur  TYPE zf63masterperson-vkbur,
         lv_gsber  TYPE zf63masterperson-gsber,
         lv_gtype  TYPE zf63masterperson-gtype.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_VKBUR'
                            CHANGING lv_vkbur.
  lv_gsber  = lv_vkbur.
  PERFORM f_dynp_value_read USING 'PA_GTYPE'
                            CHANGING lv_gtype.

  CLEAR : lt_person[], lt_person, dynpfields[], dynpfields.

  SELECT SINGLE *
    FROM zf63gtype
    INTO gs_gtype
    WHERE gtype = lv_gtype
      AND bukrs = pa_bukrs.

  IF gs_gtype-lfa1 IS NOT INITIAL.
    SELECT zidno name1 lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_mstp
      WHERE bukrs = lv_bukrs
        AND vkbur = lv_vkbur
        AND gsber = lv_gsber.
    LOOP AT lt_mstp INTO ls_mstp.
      ls_person-zidno   = ls_mstp-lifnr.
      ls_person-name1   = ls_mstp-name1.
      APPEND ls_person TO lt_person.
    ENDLOOP.
  ELSE.
    SELECT zidno name1
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_person
      WHERE bukrs = lv_bukrs
        AND vkbur = lv_vkbur
        AND gsber = lv_gsber
        AND gtype = lv_gtype.
  ENDIF.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDNO' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidno  = ls_return-fieldval.
      READ TABLE lt_person INTO ls_person WITH KEY zidno = lv_zidno.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_person-zidno ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALUE_ZIDNO

*&---------------------------------------------------------------------*
*&      Form  F_VALUE-ZNOPL
*&---------------------------------------------------------------------*
FORM f_value-znopl .
  DATA : lv_bukrs TYPE zf63masterperson-bukrs,
         lv_vkbur TYPE zf63masterperson-vkbur,
         lv_gsber TYPE zf63masterperson-gsber,
         lv_gtype TYPE zf63masterperson-gtype.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_VKBUR'
                            CHANGING lv_vkbur.
  PERFORM f_dynp_value_read USING 'PA_GSBER'
                            CHANGING lv_gsber.
  PERFORM f_dynp_value_read USING 'PA_GTYPE'
                            CHANGING lv_gtype.


ENDFORM.                    " F_VALUE-ZNOPL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data  USING    fu_value fu_kmstr fu_kmend fu_menge
                               fu_type fu_wrbtr fu_description.
  DATA : ls_plat    LIKE LINE OF gt_plat,
         ls_mstk    TYPE zf63masterkend,
         ls_mstp    TYPE zf63masterperson,
         lv_char1   TYPE string,
         lv_char2   TYPE string,
         ls_typeexp TYPE zf63typeexp,
         ls_trpar   LIKE LINE OF gt_trpar,
         ls_trnshp  LIKE LINE OF gt_trnshp,
         ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_trnvch  LIKE LINE OF gt_trnvch,
         ls_final   LIKE LINE OF gt_final.
  DATA : lv_tknum     TYPE vttk-tknum.
  DATA : lt_trnhdr  TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         lt_trnvch1 TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0.

  CASE fu_value.
    WHEN 'NOPOL'.
      IF zfmstken-loevm IS INITIAL AND
        zfmstken-mark IS INITIAL.
        IF gv_znopol <> zfmstken-znopol.
          READ TABLE gt_plat INTO ls_plat WITH KEY bukrs  = zfmstken-bukrs
                                                   vkbur  = zfmstken-vkbur
                                                   gsber  = zfmstken-gsber
                                                   znopol = zfmstken-znopol.
          IF sy-subrc = 0.
            MESSAGE s000(zab) WITH 'Nomor Polisi sudah terdaftar'
                              DISPLAY LIKE 'E'.
            gv_error  = 'X'.
          ENDIF.
        ENDIF.

        IF radio4 IS NOT INITIAL.
          IF gs_gtype-advance IS INITIAL.
            SELECT SINGLE znopol
              FROM zf63plat
              INTO CORRESPONDING FIELDS OF ls_plat
              WHERE bukrs   = zfexpense-bukrs
                AND vkbur   = zfexpense-vkbur
                AND gsber   = zfexpense-gsber
                AND znopol  = zfexpense-znopol.
            IF sy-subrc <> 0.
              MESSAGE s000(zab) WITH 'Nomor Polisi tidak terdaftar'
                                DISPLAY LIKE 'E'.
              gv_error  = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'TKNUM'.
      SELECT SINGLE *
        FROM zf63trnshp
        INTO ls_trnshp
        WHERE tknum = zfexpense-tknum.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM zf63trnhdr
          INTO ls_trnhdr
          WHERE bukrs = ls_trnshp-bukrs
            AND gsber = ls_trnshp-gsber
            AND vkbur = ls_trnshp-vkbur
            AND gtype = ls_trnshp-gtype
            AND expnr = ls_trnshp-expnr.
        IF sy-subrc = 0.
          SELECT SINGLE *
            FROM zf63trnvch
            INTO ls_trnvch
            WHERE bukrs = ls_trnhdr-bukrs
              AND gsber = ls_trnhdr-gsber
              AND vkbur = ls_trnhdr-vkbur
              AND gtype = ls_trnhdr-gtype
              AND zidvc = ls_trnhdr-zidvc.
          IF sy-subrc = 0.
            IF ls_trnvch-belnrrev IS INITIAL.
              MESSAGE s000(zab) WITH 'Nomor Shipment sudah digunakan'
                                DISPLAY LIKE 'E'.
              gv_error  = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT SINGLE tknum
          FROM vttk
          INTO lv_tknum
          WHERE tknum = zfexpense-tknum
            AND tplst = pa_gsber.
        IF sy-subrc <> 0.
          gv_error  = selected.
          MESSAGE s000(zab) WITH 'Nomor Shipment salah'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN 'TYPE'.
      IF gs_gtype-lfa1 IS INITIAL.
        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF ls_mstp
          WHERE zidno = zfexpense-zidno.
        IF sy-subrc <> 0.
          gv_error = selected.
          MESSAGE i000(zab) WITH 'Vendor tidak ada'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF ls_mstp
          WHERE lifnr = zfexpense-zidno.
        IF sy-subrc <> 0.
          gv_error = selected.
          MESSAGE i000(zab) WITH 'Vendor tidak ada'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

      SELECT SINGLE *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF ls_mstk
        WHERE zidke = ls_mstp-zidke.

***      SPLIT ls_mstk-jnskend AT space INTO lv_char1 lv_char2.
***      CASE lv_char2.
***        WHEN 'BENSIN'.
***          IF zfexpense-type = '102'.
***            gv_error = selected.
***            MESSAGE i000(zab) WITH 'Must be entry Type 101'
***                              DISPLAY LIKE 'E'.
***          ENDIF.
***        WHEN 'SOLAR'.
***          IF zfexpense-type = '101'.
***            gv_error = selected.
***            MESSAGE i000(zab) WITH 'Must be entry Type 102'
***                              DISPLAY LIKE 'E'.
***          ENDIF.
***      ENDCASE.

    WHEN 'KM'.
      IF fu_kmstr IS NOT INITIAL AND
        fu_kmend IS NOT INITIAL.
        IF fu_kmend <= fu_kmstr.
          gv_error = selected.
          MESSAGE i000(zab) WITH 'KM Start lebih besar dari KM End'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN 'VBUND'.
      READ TABLE gt_typeexp INTO ls_typeexp
                            WITH KEY bukrs = pa_bukrs
                                     gtype = pa_gtype
                                     type  = zfexpense-type.
      IF ls_typeexp-zvbund IS NOT INITIAL.
        IF zfexpense-vbund IS INITIAL.
          gv_error = selected.
          MESSAGE i000(zab) WITH 'TrPart harus diisi'
                            DISPLAY LIKE 'E'.
        ELSEIF zfexpense-vbund IS NOT INITIAL AND
               zfexpense-vbund <> 'OTHERS'.
          READ TABLE gt_trpar INTO ls_trpar WITH KEY vbund = zfexpense-vbund.
          IF sy-subrc <> 0.
            gv_error = selected.
            MESSAGE i000(zab) WITH 'Trading Partner salah'
                              DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'OBLIGATORY'.
      READ TABLE gt_typeexp INTO ls_typeexp
                            WITH KEY bukrs = pa_bukrs
                                     gtype = pa_gtype
                                     type  = fu_type.
      IF ls_typeexp-zoblig IS NOT INITIAL.
        IF fu_wrbtr IS NOT INITIAL.
          IF fu_kmstr IS INITIAL OR
            fu_kmend IS INITIAL OR
            fu_menge IS INITIAL.
            gv_error = selected.
            MESSAGE i000(zab) WITH 'KM & Quantity harus diisi'
                              DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          READ TABLE gt_final INTO ls_final
                              WITH KEY bukrs = pa_bukrs
                                       gtype = pa_gtype
                                       type  = fu_type.
          IF ls_final-rekanan IS NOT INITIAL.
            IF fu_kmstr IS INITIAL OR
              fu_kmend IS INITIAL OR
              fu_menge IS INITIAL.
              gv_error = selected.
              MESSAGE i000(zab) WITH 'KM & Quantity'
                                     fu_description
                                     'harus diisi'
                                DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'ZIDNO'.
      SELECT zidno zidvc
        FROM zf63trnhdr
        INTO CORRESPONDING FIELDS OF TABLE lt_trnhdr
        WHERE zidno = zfexpense-zidno.
      IF lt_trnhdr[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnvch
          INTO CORRESPONDING FIELDS OF TABLE lt_trnvch1
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE zidvc  = lt_trnhdr-zidvc.
        IF sy-subrc = 0.
        ELSE.
          gv_error  = selected.
          MESSAGE s000(zab) WITH 'Advance ????'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN 'NMVCH'.
      IF zfexpense-nmvch IS NOT INITIAL.
        SELECT SINGLE *
          FROM zf63nomor
          WHERE bukrs = pa_bukrs
            AND vkbur = pa_vkbur
            AND nmvch = zfexpense-nmvch.
        IF sy-subrc <> 0.
          gv_error  = selected.
          MESSAGE s000(zab) WITH 'Pembayaran tidak terdaftar'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_ASSET
*&---------------------------------------------------------------------*
FORM f_get_asset .
  SELECT bukrs anln1 anln2 bdatu adatu kostl werks gsber
    FROM anlz
    INTO CORRESPONDING FIELDS OF TABLE gt_anlz
    WHERE bukrs = pa_bukrs
      AND gsber = pa_gsber
      AND bdatu >= sy-datum
      AND adatu <= sy-datum.

  IF gt_anlz[] IS NOT INITIAL.
    SELECT bukrs anln1 anln2 zujhr ord41 vbund txt50
      FROM anla
      INTO CORRESPONDING FIELDS OF TABLE gt_anla
      FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs = gt_anlz-bukrs
        AND anln1 = gt_anlz-anln1
        AND anln2 = gt_anlz-anln2.

    IF gt_anla[] IS NOT INITIAL.
      SELECT bukrs anln1 anln2 gjahr answl
        FROM anlc
        INTO CORRESPONDING FIELDS OF TABLE gt_anlc
        FOR ALL ENTRIES IN gt_anla
        WHERE bukrs = gt_anla-bukrs
          AND anln1 = gt_anla-anln1
          AND anln2 = gt_anla-anln2
          AND gjahr = gt_anla-zujhr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ASSET

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        fc_value  = ls_dynpfields-fieldvalue.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_DYNP_VALUE_READ

*&---------------------------------------------------------------------*
*&      Form  F_CALL_SCREEN_804
*&---------------------------------------------------------------------*
FORM f_call_screen_804 .
  PERFORM f_text_screen USING    'C'
                                 gs_ship-butxt gs_ship-bezei
                                 gs_ship-gtext gs_ship-description
                                 gs_ship-salesman gs_ship-vendor
                                 gs_ship-customer gs_ship-shipment
                                 gs_ship-lfa1 gs_ship-znopol
                        CHANGING gs_expe-butxt gs_expe-bezei
                                 gs_expe-gtext gs_expe-description
                                 gs_expe-salesman gs_expe-vendor
                                 gs_expe-customer gs_expe-shipment
                                 gs_expe-lfa1 gs_expe-znopol.

  SET SCREEN 804.
ENDFORM.                    " F_CALL_SCREEN_804

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data USING fu_screen.
  DATA : ls_tyexpdtl LIKE LINE OF gt_tyexpdtl,
         ls_typeexp  LIKE LINE OF gt_typeexp,
         ls_accexp   LIKE LINE OF gt_accexp,
         ls_expe     LIKE LINE OF gt_expe,
         ls_final    LIKE LINE OF gt_final,
         ls_save     LIKE LINE OF gt_save.

  DATA : ls_pddklk LIKE LINE OF gt_pddklk,
         ls_tbsl   LIKE LINE OF gt_tbsl,
         ls_mstp   LIKE LINE OF gt_mstp,
         ls_kmh    LIKE LINE OF gt_kmh.

  DATA : lv_char1 TYPE string,
         lv_char2 TYPE string,
         lv_char3 TYPE string.

  DATA : ls_xexp    LIKE LINE OF gt_xexp,
         ls_xshp    LIKE LINE OF gt_xshp,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_trndtl2 LIKE LINE OF gt_trndtl2,
         ls_trnshp2 LIKE LINE OF gt_trnshp2,
         ls_zf63acc LIKE LINE OF gt_zf63acc,
         ls_proseq  LIKE LINE OF gt_proseq,
         ls_slarea  LIKE LINE OF gt_slarea.

  DATA : lt_xexp TYPE STANDARD TABLE OF zfexpense,
         lt_xshp TYPE STANDARD TABLE OF zfshipment.

  DATA : lv_wrbtr TYPE zfexpense-wrbtr,
         lv_buzei TYPE zfexpense-buzei.

  CASE fu_screen.
    WHEN '804'.
      IF gs_gtype-lfa1 IS INITIAL.
        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF gs_mstp
          WHERE bukrs = zfexpense-bukrs
            AND gsber = zfexpense-gsber
            AND vkbur = zfexpense-vkbur
            AND zidno = zfexpense-zidno.
      ELSE.
        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF gs_mstp
          WHERE bukrs = zfexpense-bukrs
            AND gsber = zfexpense-gsber
            AND vkbur = zfexpense-vkbur
            AND lifnr = zfexpense-zidno.
      ENDIF.

      SELECT SINGLE *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF gs_mstk
        WHERE bukrs   = zfexpense-bukrs
          AND gsber   = zfexpense-gsber
          AND vkbur   = zfexpense-vkbur
          AND znopol  = zfexpense-znopol
          AND loevm   = space.

      SELECT *
        FROM zf63kmhexph
        INTO CORRESPONDING FIELDS OF TABLE gt_kmh
        WHERE bukrs   = zfexpense-bukrs
          AND gsber   = zfexpense-gsber
          AND vkbur   = zfexpense-vkbur
          AND znopol  = zfexpense-znopol.

      CLEAR : gt_expe[], gt_expe.
      SORT gt_kmh BY znopol type item bldat DESCENDING buzei DESCENDING.
      LOOP AT gt_tyexpdtl INTO ls_tyexpdtl WHERE gtype = zfexpense-gtype.
        SPLIT gs_mstk-jnskend AT space INTO lv_char1 lv_char2.

        SEARCH ls_tyexpdtl-description FOR 'BENSIN'.
        IF sy-subrc = 0.
          IF lv_char2 <> 'BENSIN'.
            CONTINUE.
          ENDIF.
        ENDIF.

        SEARCH ls_tyexpdtl-description FOR 'SOLAR'.
        IF sy-subrc = 0.
          IF lv_char2 <> 'SOLAR'.
            CONTINUE.
          ENDIF.
        ENDIF.

        ls_expe               = zfexpense.

        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp
                              WITH KEY gtype = ls_tyexpdtl-gtype
                                       type  = ls_tyexpdtl-type.
        IF sy-subrc = 0.
          gs_expe-acctype   = ls_typeexp-acctype.
          IF ls_typeexp-zoblig IS INITIAL.
            CLEAR ls_expe-rekanan.
          ENDIF.
        ENDIF.

        READ TABLE gt_pddklk INTO ls_pddklk WITH KEY bukrs   = zfexpense-bukrs
                                                     vkbur   = zfexpense-vkbur
                                                     gsber   = zfexpense-gsber
                                                     type    = ls_tyexpdtl-type
                                                     item    = ls_tyexpdtl-item
                                                     jabatpd = gs_mstp-jabatpd.
        IF sy-subrc = 0.
          ls_expe-trf_inap    = ls_pddklk-trf_inap.
          ls_expe-trf_hari    = ls_pddklk-trf_hari.
        ENDIF.

        ls_expe-type          = ls_tyexpdtl-type.
        ls_expe-buzei         = ls_tyexpdtl-item.
        ls_expe-ltext         = ls_tyexpdtl-ltext.
        ls_expe-description   = ls_tyexpdtl-description.
        ls_expe-meins         = ls_tyexpdtl-meins.
        ls_expe-waers         = ls_tyexpdtl-waers.
        ls_expe-speed         = ls_tyexpdtl-speed.

        LOOP AT gt_kmh INTO ls_kmh WHERE bukrs   = zfexpense-bukrs
                                     AND vkbur   = zfexpense-vkbur
                                     AND gsber   = zfexpense-gsber
                                     AND znopol  = zfexpense-znopol
                                     AND type    = ls_tyexpdtl-type
                                     AND item    = ls_tyexpdtl-item.

          IF ls_kmh-lvorm IS NOT INITIAL.
            CONTINUE.
          ELSE.
            ls_expe-kmstr = ls_kmh-kmend.
            EXIT.
          ENDIF.
        ENDLOOP.

        APPEND ls_expe TO gt_expe.
        CLEAR ls_expe.
      ENDLOOP.

      IF gt_final[] IS INITIAL.
        LOOP AT gt_expe INTO ls_expe.
          ls_final = ls_expe.
          APPEND ls_final TO gt_final.
          CLEAR ls_final.
        ENDLOOP.
      ELSE.
        LOOP AT gt_expe INTO ls_expe.
          READ TABLE gt_final INTO ls_final
                              WITH KEY type  = ls_expe-type
                                       buzei = ls_expe-buzei.
          IF sy-subrc = 0.
            ls_expe = ls_final.
            MODIFY gt_expe FROM ls_expe.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN '805'.
      CLEAR : gt_save[], gt_save, gv_azsal.
      LOOP AT gt_final INTO ls_final.
        IF ls_final-wrbtr IS INITIAL.
          IF ls_final-rekanan IS INITIAL.
            CONTINUE.
          ENDIF.
        ENDIF.

        ls_save   = ls_final.
        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp
                              WITH KEY bukrs = ls_save-bukrs
                                       gtype = ls_save-gtype
                                       type  = ls_save-type.
        IF sy-subrc = 0.
          CLEAR ls_accexp.
          READ TABLE gt_accexp INTO ls_accexp
                               WITH KEY acctype = ls_typeexp-acctype
                                       zmejl   = gs_gtype-memojurnal.
          IF sy-subrc = 0.
            CLEAR ls_tbsl.
            READ TABLE gt_tbsl INTO ls_tbsl
                               WITH KEY bschl = ls_accexp-bschl.
            IF sy-subrc = 0.
              ls_save-shkzg = ls_tbsl-shkzg.
            ENDIF.
          ENDIF.
        ENDIF.
        APPEND ls_save TO gt_save.
        CLEAR ls_save.
      ENDLOOP.
      SORT gt_save BY type buzei.

    WHEN '813'.
      lt_xexp[] = gt_xexp[].
      DELETE lt_xexp WHERE icon = icon_delete.
      SORT lt_xexp BY bukrs gsber vkbur gtype gjahr zidvc.
      DELETE ADJACENT DUPLICATES FROM lt_xexp
      COMPARING bukrs gsber vkbur gtype gjahr zidvc.

      LOOP AT lt_xexp INTO ls_xexp.
        ls_trnhdr2-bukrs      = ls_xexp-bukrs.
        ls_trnhdr2-gsber      = ls_xexp-gsber.
        ls_trnhdr2-vkbur      = ls_xexp-vkbur.
        ls_trnhdr2-gtype      = ls_xexp-gtype.
        ls_trnhdr2-gjahr      = sy-datum(4).
        ls_trnhdr2-zidno      = ls_xexp-zidno.
        ls_trnhdr2-bktxt      = zfexpense-bktxt.
        ls_trnhdr2-waers      = ls_xexp-waers.
        ls_trnhdr2-ernam      = sy-uname.
        ls_trnhdr2-erdat      = sy-datum.
        ls_trnhdr2-erzet      = sy-uzeit.
        ls_trnhdr2-adv_gjahr  = gv_gjahr.
        ls_trnhdr2-adv_belnr  = gv_belnr.
        CLEAR ls_zf63acc.
        READ TABLE gt_zf63acc INTO ls_zf63acc
                              WITH KEY ktext = zfexpense-ktext.
        IF sy-subrc = 0.
          ls_trnhdr2-hkont      = ls_zf63acc-hkont.
        ENDIF.

        CLEAR : ls_xexp, lv_buzei.
        LOOP AT gt_xexp INTO ls_xexp WHERE icon = space.

          PERFORM f_dc_fr_type USING ls_xexp-bukrs ls_xexp-gtype ls_xexp-type
                               CHANGING ls_xexp-wrbtr.

          ADD ls_xexp-wrbtr TO ls_trnhdr2-wrbtr.
          ls_trndtl2-bukrs       = ls_xexp-bukrs.
          ls_trndtl2-gsber       = ls_xexp-gsber.
          ls_trndtl2-vkbur       = ls_xexp-vkbur.
          ls_trndtl2-gtype       = ls_xexp-gtype.
          ls_trndtl2-type        = ls_xexp-type.
          ADD 1 TO lv_buzei.
          ls_trndtl2-buzei       = lv_buzei.
          ls_trndtl2-gjahr       = sy-datum(4).
          ls_trndtl2-meins       = ls_xexp-meins.
          ls_trndtl2-menge       = ls_xexp-menge.
          ls_trndtl2-speed       = ls_xexp-speed.
          ls_trndtl2-kmstr       = ls_xexp-kmstr.
          ls_trndtl2-kmend       = ls_xexp-kmend.
          ls_trndtl2-znopol      = ls_xexp-znopol.
          ls_trndtl2-description = ls_xexp-ltext.
          ls_trndtl2-persentase  = ls_xexp-percentage.
          ls_trndtl2-waers       = ls_xexp-waers.
          IF ls_xexp-trf_inap IS NOT INITIAL.
            ls_trndtl2-tarif       = ls_xexp-trf_inap.
          ELSEIF ls_xexp-trf_hari IS NOT INITIAL.
            ls_trndtl2-tarif       = ls_xexp-trf_hari.
          ENDIF.
          ADD ls_xexp-wrbtr TO lv_wrbtr.
          IF ls_xexp-wrbtr >= 0.
            ls_trndtl2-shkzg  = 'S'.
          ELSE.
            ls_trndtl2-shkzg  = 'H'.
          ENDIF.
          ls_trndtl2-wrbtr = abs( ls_xexp-wrbtr ).

          CLEAR ls_proseq.
          READ TABLE gt_proseq INTO ls_proseq
                               WITH KEY departemen = ls_xexp-departemen.
          IF sy-subrc = 0.
            PERFORM f_cost_center USING ls_xexp-bukrs ls_xexp-vkbur
                                        ls_proseq-kostl
                                  CHANGING ls_trndtl2-kostl.
            ls_trndtl2-wwsfr  = ls_proseq-wwsfr.
            ls_trndtl2-wwpos  = ls_proseq-wwpos.
          ENDIF.

          CLEAR ls_slarea.
          READ TABLE gt_slarea INTO ls_slarea
                               WITH KEY vkbur = ls_xexp-vkbur.
          IF sy-subrc = 0.
            ls_trndtl2-wwpfn  = ls_slarea-wwpfn.
          ENDIF.
          ls_trndtl2-vbund  = ls_xexp-vbund.
          ls_trndtl2-text   = ls_xexp-text.
          APPEND ls_trndtl2 TO gt_trndtl2.
          CLEAR ls_trndtl2.
        ENDLOOP.

        IF lv_wrbtr >= 0.
          ls_trnhdr2-shkzg  = 'S'.
        ELSE.
          ls_trnhdr2-shkzg  = 'H'.
        ENDIF.
        ls_trnhdr2-wrbtr = abs( lv_wrbtr ).
        APPEND ls_trnhdr2 TO gt_trnhdr2.
        CLEAR ls_trnhdr2.
      ENDLOOP.

      LOOP AT gt_xshp INTO ls_xshp.
        ls_trnshp2-bukrs       = zfexpense-bukrs.
        ls_trnshp2-gsber       = zfexpense-gsber.
        ls_trnshp2-vkbur       = zfexpense-vkbur.
        ls_trnshp2-gtype       = zfexpense-gtype.
        ls_trnshp2-znopol      = ls_xshp-znopol.
        ls_trnshp2-tknum       = ls_xshp-tknum.
        ls_trnshp2-gjahr       = ls_xshp-erdat(4).
        ls_trnshp2-erdat       = ls_xshp-erdat.
        APPEND ls_trnshp2 TO gt_trnshp2.
        CLEAR ls_trnshp2.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_Alv_HIERARCHY
*&---------------------------------------------------------------------*
FORM  f_alv_hierarchy .
  DATA : lt_binding      TYPE salv_t_hierseq_binding,
         ls_binding      TYPE salv_s_hierseq_binding,
         lr_selections   TYPE REF TO cl_salv_selections,
         lr_columns      TYPE REF TO cl_salv_columns_hierseq,
         lr_column       TYPE REF TO cl_salv_column_hierseq,
         lr_functions    TYPE REF TO cl_salv_functions_list,
         lr_display      TYPE REF TO cl_salv_display_settings,
         lr_layout       TYPE REF TO cl_salv_layout,
         lr_events       TYPE REF TO cl_salv_events_hierseq,
         lr_aggregations TYPE REF TO cl_salv_aggregations,
         lr_sorts        TYPE REF TO cl_salv_sorts.

  DATA : text_del         TYPE gui_dyntxt.

  IF radio5 IS NOT INITIAL.
    ls_binding-master = 'BUKRS'.
    ls_binding-slave  = 'BUKRS'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'GSBER'.
    ls_binding-slave  = 'GSBER'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'VKBUR'.
    ls_binding-slave  = 'VKBUR'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'GTYPE'.
    ls_binding-slave  = 'GTYPE'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'EXPNR'.
    ls_binding-slave  = 'EXPNR'.
    APPEND ls_binding TO lt_binding.
  ELSEIF radio9 IS NOT INITIAL.
    ls_binding-master = 'GSBER'.
    ls_binding-slave  = 'GSBER'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'VKBUR'.
    ls_binding-slave  = 'VKBUR'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'GTYPE'.
    ls_binding-slave  = 'GTYPE'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'ZIDVC'.
    ls_binding-slave  = 'ZIDVC'.
    APPEND ls_binding TO lt_binding.
    ls_binding-master = 'KJAHR'.
    ls_binding-slave  = 'KJAHR'.
    APPEND ls_binding TO lt_binding.
  ENDIF.

  TRY.
      cl_salv_hierseq_table=>factory(
        EXPORTING
          t_binding_level1_level2  = lt_binding
        IMPORTING
          r_hierseq                = gr_hierseq
        CHANGING
          t_table_level1           = gt_head
          t_table_level2           = gt_detl ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  IF radio5 IS NOT INITIAL.
    IF gs_gtype-advance IS INITIAL.
      gr_hierseq->set_screen_status(
        pfstatus   = 'SALV_STANDARD4'
        report     = gv_repid ).
    ELSE.
      gr_hierseq->set_screen_status(
        pfstatus   = 'SALV_STANDARD5'
        report     = gv_repid ).
    ENDIF.
  ELSE.
    gr_hierseq->set_screen_status(
      pfstatus   = 'SALV_STANDARD3'
      report     = gv_repid ).
  ENDIF.

  IF radio9 IS NOT INITIAL.
    PERFORM f_set_text_hier USING : 'BELNR' 'Doc.Deklr' 'X',
                                    'BELNRPADV' 'Doc.PADV' 'X',
                                    'GJAHR' 'Year' 'X',
                                    'BELNRREV' 'Rev.Deklr' 'X',
                                    'BELNRPADVREV' 'Rev.PADV' 'X',
                                    'USERPOST' 'UserPost' 'X',
                                    'USERREV' 'UserRev' 'X'.
  ENDIF.

  TRY .
      lr_functions = gr_hierseq->get_functions( ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lr_functions->set_all( abap_true ).

  TRY.
      lr_columns = gr_hierseq->get_columns( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      lr_columns->set_expand_column( 'EXPAND' ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_column ?= lr_columns->get_column( 'ICON' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).

  IF radio9 IS NOT INITIAL.
    lr_column ?= lr_columns->get_column( 'EXPNR' ).
    lr_column->set_visible( abap_false ).
  ENDIF.

  lr_column ?= lr_columns->get_column( 'SHKZG' ).
  lr_column->set_visible( abap_false ).

  TRY .
      lr_display = gr_hierseq->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  IF radio5 IS NOT INITIAL.
    TRY.
        lr_selections = gr_hierseq->get_selections( '1' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    lr_selections->set_selection_mode( if_salv_c_selection_mode=>single ).
  ENDIF.

  TRY .
      lr_sorts = gr_hierseq->get_sorts( 1 ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_sorts->set_group_active( ).

  TRY.
      lr_sorts->add_sort(
        columnname = 'NAME1'
        position   = 1
        sequence   = if_salv_c_sort=>sort_up ).
    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
  ENDTRY.
  TRY.
      lr_sorts->add_sort(
        columnname = 'ZNOPOL'
        position   = 2
        sequence   = if_salv_c_sort=>sort_up ).
    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
  ENDTRY.

  lr_events = gr_hierseq->get_event( ).

  CREATE OBJECT event_receiver.

  IF radio5 IS NOT INITIAL.
    SET HANDLER event_receiver->on_user_command FOR lr_events.
  ELSE.
    SET HANDLER event_receiver->on_user_command FOR lr_events.
  ENDIF.

  TRY.
      lr_aggregations = gr_hierseq->get_aggregations( 2 ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_aggregations->add_aggregation( 'WRBTRV' ).

  gr_hierseq->display( ).

ENDFORM.                    " F_ALV_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
FORM handle_user_command  USING    i_ucomm TYPE salv_de_function.
  DATA : lv_subrc TYPE sy-subrc,
         lt_out   TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out   LIKE LINE OF lt_out.

  DATA : lv_belnr    TYPE bseg-belnr,
         lv_gjahr    TYPE bseg-gjahr,
         lv_message  TYPE bapiret2-message,
         lv_budat    TYPE sy-datum,
         lv_formname TYPE tdsfname,
         lv_zidvc    TYPE zfstexphdr-zidvc,
         lv_vbund    TYPE zf63trndtl-vbund.

  DATA : ls_reprint LIKE LINE OF gt_reprint,
         lv_uname   TYPE sy-uname.

  DATA : BEGIN OF lt_k OCCURS 0,
           lifnr TYPE lfa1-lifnr.
  DATA : END OF lt_k.
  DATA : ls_k    LIKE LINE OF lt_k,
         char(1).

  DATA : ls_ctrladv LIKE LINE OF gt_ctrladv,
         ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2.

  DATA : lv_zidvc2 LIKE zf63trnhdr2-zidvc2,
         lv_kdvch  LIKE zf63nomor-kdvch,
         lv_bktxt  LIKE zf63trnhdr2-bktxt,
         lv_lifnr  LIKE lfa1-lifnr.

  CASE i_ucomm.
    WHEN '&SALL'.
      PERFORM f_select USING 'X'.

    WHEN '&DALL'.
      PERFORM f_select USING ''.

    WHEN '&POS'.
      CASE 'X'.
        WHEN radio5.
          CLEAR lv_subrc.
          PERFORM f_validasi_voucher CHANGING lv_subrc lv_vbund.
          CASE lv_subrc.
            WHEN 1.
              MESSAGE s000(zab) WITH 'Nomor Polisi harus sama'
              DISPLAY LIKE 'E'.
            WHEN 4.
              MESSAGE s000(zab) WITH 'Tidak ada data yang dipilih'
              DISPLAY LIKE 'E'.
            WHEN 8.
              MESSAGE s000(zab) WITH 'Penyelesaian Advance belum dipilih'
              DISPLAY LIKE 'E'.
            WHEN OTHERS.
              IF gs_gtype-advance IS INITIAL.
                IF gv_accba IS NOT INITIAL.
                  PERFORM f_create_voucher CHANGING lv_zidvc.
                  lv_formname = 'ZFEXP_F001'.
                  PERFORM f_print_form USING 'PRNT' lv_formname lv_zidvc
                                             'Cash/Bank Payment Voucher'
                                             lv_vbund.
                ELSE.
                  MESSAGE s000(zab) WITH 'Cash/Bank belum diisi/salah'
                  DISPLAY LIKE 'E'.
                ENDIF.
              ELSE.
                lv_formname = 'ZFEXP_F001'.
                PERFORM f_print_form1 USING 'PRNT' lv_formname lv_zidvc
                                            'Cash/Bank Payment Voucher'
                                      CHANGING lv_subrc.
              ENDIF.
          ENDCASE.

          IF lv_subrc IS INITIAL.
            CLEAR : gv_belnr, gv_gjahr, gv_dmbtr, gv_description, gv_bktxt,
                    gv_hkont, zfexpense-advance, zfexpense-hkont.
          ENDIF.

        WHEN radio6.
          IF gt_error[] IS INITIAL.
            LOOP AT gt_out INTO ls_out.
              IF ls_out-koart = 'K'.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_out-hkont
                  IMPORTING
                    output = ls_k-lifnr.
                APPEND ls_k TO lt_k.
                READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
                IF sy-subrc = 0.
                  CLEAR ls_ctrladv.
                  SELECT SINGLE *
                    FROM zf63ctrladv
                    INTO CORRESPONDING FIELDS OF ls_ctrladv
                    WHERE bukrs   = ls_trnhdr2-bukrs
                      AND vkbur   = ls_trnhdr2-vkbur
                      AND gtype   = gs_gtype-jeadv
                      AND lifnr   = ls_k-lifnr
                      AND zidno   = ls_trnhdr2-zidno.
*                          AND gjahr   = ls_trnhdr2-gjahr.
                ENDIF.

**                CASE sy-tcode.
**                  WHEN 'ZF63B'.
**                    READ TABLE gt_trnhdr INTO ls_trnhdr INDEX 1.
**                    IF sy-subrc = 0.
**                      CLEAR ls_ctrladv.
**                      SELECT SINGLE *
**                        FROM zf63ctrladv
**                        INTO CORRESPONDING FIELDS OF ls_ctrladv
**                        WHERE bukrs   = ls_trnhdr-bukrs
**                          AND vkbur   = ls_trnhdr-vkbur
**                          AND gtype   = gs_gtype-jeadv
**                          AND lifnr   = ls_k-lifnr
**                          AND zidno   = ls_trnhdr-zidno.
***                          AND gjahr   = ls_trnhdr-gjahr.
**                    ENDIF.
**
**                  WHEN 'ZF63N'.
**                    READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
**                    IF sy-subrc = 0.
**                      CLEAR ls_ctrladv.
**                      SELECT SINGLE *
**                        FROM zf63ctrladv
**                        INTO CORRESPONDING FIELDS OF ls_ctrladv
**                        WHERE bukrs   = ls_trnhdr2-bukrs
**                          AND vkbur   = ls_trnhdr2-vkbur
**                          AND gtype   = gs_gtype-jeadv
**                          AND lifnr   = ls_k-lifnr
**                          AND zidno   = ls_trnhdr2-zidno.
***                          AND gjahr   = ls_trnhdr2-gjahr.
**                    ENDIF.
**                ENDCASE.

                CLEAR ls_k.
              ENDIF.
            ENDLOOP.

            CLEAR : ls_out.
            READ TABLE gt_out INTO ls_out WITH KEY belnr = space
                                          TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              lt_out[]  = gt_out[].
              SORT lt_out BY post.
              DELETE ADJACENT DUPLICATES FROM lt_out COMPARING post.

              LOOP AT lt_out INTO ls_out.
                CLEAR: lv_belnr, lv_gjahr, lv_message.
                CASE ls_out-post.
                  WHEN 1.
                    PERFORM f_posting_data TABLES   gl ap ar ca ex cr
                                           USING    dh ls_out-post
                                           CHANGING lv_belnr lv_gjahr lv_message.
                    IF lv_belnr IS NOT INITIAL.
                      PERFORM f_update_zf63trnhdr2 USING ls_out-post lv_belnr
                                                         lv_gjahr.
                      IF gv_tabix IS NOT INITIAL.
                        UPDATE zf63trndtl2 SET vbund = gs_trndtl-vbund
                                               text  = gs_trndtl-text
                                          WHERE bukrs = gs_trndtl-bukrs
                                            AND gsber = gs_trndtl-gsber
                                            AND vkbur = gs_trndtl-vkbur
                                            AND gtype = gs_trndtl-gtype
                                            AND zidvc = pa_zidv2
                                            AND gjahr = gs_trndtl-gjahr
                                            AND type  = gs_trndtl-type
                                            AND buzei = gs_trndtl-buzei.
                      ENDIF.

**                      CASE sy-tcode.
**                        WHEN 'ZF63B'.
**                          PERFORM f_update_zf63trnvch USING ls_out-post lv_belnr
**                                                            lv_gjahr.
**                          IF gv_tabix IS NOT INITIAL.
**                            UPDATE zf63trndtl SET vbund = gs_trndtl-vbund
**                                                  text  = gs_trndtl-text
**                                              WHERE bukrs = gs_trndtl-bukrs
**                                                AND gsber = gs_trndtl-gsber
**                                                AND vkbur = gs_trndtl-vkbur
**                                                AND gtype = gs_trndtl-gtype
**                                                AND expnr = gs_trndtl-expnr
**                                                AND gjahr = gs_trndtl-gjahr
**                                                AND type  = gs_trndtl-type
**                                                AND buzei = gs_trndtl-buzei.
**                          ENDIF.
**                        WHEN 'ZF63N'.
**                          PERFORM f_update_zf63trnhdr2 USING ls_out-post lv_belnr
**                                                             lv_gjahr.
**                          IF gv_tabix IS NOT INITIAL.
**                            UPDATE zf63trndtl2 SET vbund = gs_trndtl-vbund
**                                                   text  = gs_trndtl-text
**                                              WHERE bukrs = gs_trndtl-bukrs
**                                                AND gsber = gs_trndtl-gsber
**                                                AND vkbur = gs_trndtl-vkbur
**                                                AND gtype = gs_trndtl-gtype
**                                                AND zidvc = pa_zidv2
**                                                AND gjahr = gs_trndtl-gjahr
**                                                AND type  = gs_trndtl-type
**                                                AND buzei = gs_trndtl-buzei.
**                          ENDIF.
**                      ENDCASE.
                    ENDIF.

                  WHEN 2.
                    PERFORM f_posting_data TABLES   advgl advap advar advca
                                                    advex advcr
                                           USING    advdh ls_out-post
                                           CHANGING lv_belnr lv_gjahr lv_message.

                    IF lv_belnr IS NOT INITIAL.
                      UPDATE zf63trnhdr2 SET belnrpadv = lv_belnr
                                             gjahrpadv = lv_gjahr
                                             budatpadv = pa_budat
                                             bldatpadv = pa_budat
                                             xblnradv  = pa_xbln2
                                             userpost = sy-uname
                                             tglpost  = sy-datum
                                             jampost  = sy-uzeit
                                        WHERE bukrs = pa_bukrs
                                          AND gsber = pa_gsber
                                          AND vkbur = pa_vkbur
                                          AND gtype = pa_gtype
                                          AND zidvc = pa_zidv2
                                          AND gjahr = pa_vjahr.
                      IF p_timdes = 'X'.
                        SORT gt_trnhdr2  BY bukrs vkbur gjahr zidvc.
                        "                        DATA: ls_trnhdr2 LIKE LINE OF gt_trnhdr2.
                        READ TABLE gt_trnhdr2 INTO ls_trnhdr2 WITH KEY bukrs = pa_bukrs
                                                       vkbur = pa_vkbur
                                                       gjahr = pa_vjahr
                                                       zidvc = pa_zidv2
                               BINARY SEARCH.
                        IF sy-subrc EQ 0.
                          IF sy-tcode = 'ZF63N'.
                            PERFORM f_send_api_to_timdes  USING 'MDS_POSTADVUJP' ls_trnhdr2-transaction_id
                                        pa_zidv2 lv_belnr pa_budat.
                          ENDIF.
                        ENDIF.
                      ENDIF.
**                      CASE sy-tcode.
**                        WHEN 'ZF63B'.
**                          UPDATE zf63trnvch SET belnrpadv = lv_belnr
**                                                gjahrpadv = lv_gjahr
**                                                budatpadv = pa_budat
**                                                bldatpadv = pa_budat
**                                            WHERE bukrs = pa_bukrs
**                                              AND gsber = pa_gsber
**                                              AND vkbur = pa_vkbur
**                                              AND gtype = pa_gtype
**                                              AND zidvc = pa_zidvc
**                                              AND vjahr = pa_vjahr.
**                        WHEN 'ZF63N'.
**                          UPDATE zf63trnhdr2 SET belnrpadv = lv_belnr
**                                                 gjahrpadv = lv_gjahr
**                                                 budatpadv = pa_budat
**                                                 bldatpadv = pa_budat
**                                                 xblnradv  = pa_xbln2
**                                                 userpost = sy-uname
**                                                 tglpost  = sy-datum
**                                                 jampost  = sy-uzeit
**                                            WHERE bukrs = pa_bukrs
**                                              AND gsber = pa_gsber
**                                              AND vkbur = pa_vkbur
**                                              AND gtype = pa_gtype
**                                              AND zidvc = pa_zidv2
**                                              AND gjahr = pa_vjahr.
**                      ENDCASE.
                    ENDIF.
                ENDCASE.
              ENDLOOP.
              LOOP AT lt_k INTO ls_k.
                PERFORM f_automatic_clearing USING ls_k-lifnr.
              ENDLOOP.
              ls_ctrladv-zreal  = ls_ctrladv-zreal + 1.
              UPDATE zf63ctrladv FROM ls_ctrladv.
              IF sy-tcode = 'ZF63N'.
                gr_table->refresh( refresh_mode = 2 ).
              ENDIF.
            ELSE.
              MESSAGE s000(zab) WITH 'Masih ada error'
              DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH 'Data sudah diproses'
            DISPLAY LIKE 'E'.
          ENDIF.

          PERFORM f_unlock_table USING '' 'DEQUEUE_EZF63TRNVCH'.

        WHEN radio17.
          IF advdh IS NOT INITIAL.
            PERFORM f_posting_data TABLES   advgl advap advar advca
                                            advex advcr
                                   USING    advdh ls_out-post
                                   CHANGING lv_belnr lv_gjahr lv_message.

            IF lv_belnr IS NOT INITIAL.
              PERFORM f_update_data USING lv_belnr lv_gjahr
                                    CHANGING lv_zidvc2 lv_kdvch lv_bktxt
                                             gv_payhkont gs_header-txt20
*                                             gs_header-hkont gs_header-txt20
                                             gs_header-totalt lv_lifnr.
              IF lv_zidvc2 IS NOT INITIAL.
                IF p_timdes = 'X'.
                  SORT gt_trnhdr2  BY bukrs vkbur gjahr zidvc.
                  "                        DATA: ls_trnhdr2 LIKE LINE OF gt_trnhdr2.
                  READ TABLE gt_trnhdr2 INTO ls_trnhdr2 WITH KEY bukrs = pa_bukrs
                                                 vkbur = pa_vkbur
                                                 gjahr = pa_vjahr
                                                 zidvc = pa_zidv2
                         BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    IF sy-tcode = 'ZF63N'.
                      PERFORM f_send_api_to_timdes  USING 'MDS_CAN_ADVUJP' ls_trnhdr2-transaction_id
                                  pa_zidv2 lv_belnr pa_budat.
                    ENDIF.
                  ENDIF.

                ELSE.
                  PERFORM f_print_cancel_advance USING 'ZFEXP_F002' lv_zidvc2
                                                       lv_kdvch lv_bktxt
                                                       gs_header-totalt.
                ENDIF.
                PERFORM f_automatic_clearing USING lv_lifnr.
              ENDIF.

              CLEAR : advdh.
              IF p_timdes = 'X' AND sy-tcode NE 'ZF63N'.
              ELSE.
                gr_table->refresh( refresh_mode = 2 ).
                MESSAGE s000(zab) WITH 'Data sudah diproses'.
              ENDIF.
*              LEAVE TO SCREEN 0.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH 'Data sudah pernah diproses'
            DISPLAY LIKE 'E'.
          ENDIF.
      ENDCASE.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.

    WHEN '&DEL' OR '&DELE' OR '&DELEXP' OR '&DELADV'.
      PERFORM f_delete_expense USING i_ucomm.

    WHEN '&PREV'.
      PERFORM f_validasi_voucher CHANGING lv_subrc lv_vbund.
      CASE lv_subrc.
        WHEN 1.
          MESSAGE s000(zab) WITH 'Nomor Polisi harus sama'
          DISPLAY LIKE 'E'.
        WHEN 8.
          MESSAGE s000(zab) WITH 'Penyelesaian advance belum dipilih'
          DISPLAY LIKE 'E'.
        WHEN OTHERS.
          IF gs_gtype-advance IS INITIAL.
            IF gs_gtype-memojurnal IS NOT INITIAL.
              lv_formname = 'ZFEXP_F003'.
              PERFORM f_print_form USING 'PREV' lv_formname '' 'JOURNAL VOUCHER'
                                         lv_vbund.
            ELSE.
              IF gv_accba IS NOT INITIAL.
                lv_formname = 'ZFEXP_F001'.
                PERFORM f_print_form USING 'PREV' lv_formname ''
                                           'Cash/Bank Payment Voucher'
                                           lv_vbund.
              ELSE.
                MESSAGE s000(zab) WITH 'Cash/Bank belum diisi/salah'
                DISPLAY LIKE 'E'.
              ENDIF.
            ENDIF.
          ELSE.
            lv_formname = 'ZFEXP_F001'.
            PERFORM f_print_form1 USING 'PREV' lv_formname ''
                                        'Cash/Bank Payment Voucher'
                                  CHANGING lv_subrc.
          ENDIF.
      ENDCASE.

    WHEN '&ACC'.
      CLEAR lv_subrc.
      PERFORM f_validasi_voucher CHANGING lv_subrc lv_vbund.
      CASE lv_subrc.
        WHEN 1.
          gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).
          MESSAGE s000(zab) WITH 'Nomor Polisi harus sama'
          DISPLAY LIKE 'E'.
        WHEN 2.
          gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).
          MESSAGE s000(zab) WITH 'Hanya boleh proses 1 expense'
          DISPLAY LIKE 'E'.
        WHEN OTHERS.
          IF zfexpense-total IS NOT INITIAL.
            PERFORM f_cash_bank.
          ELSE.
            gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).
            MESSAGE s000(zab) WITH 'No data selected' DISPLAY LIKE 'E'.
          ENDIF.
      ENDCASE.

    WHEN '&REVERSE'.
      PERFORM f_reverse_document.

    WHEN '&DELETE'.
      CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
        EXPORTING
          textline1 = TEXT-031
          textline2 = space
          titel     = TEXT-030
        IMPORTING
          answer    = char.

      IF char = 'J'.
        PERFORM f_delete_voucher.
        PERFORM f_unlock_table USING 'X' 'DEQUEUE_ALL'.
      ENDIF.

    WHEN '&REPRINT'.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_prepare_reprint_b.
        WHEN 'ZF63N'.
          PERFORM f_prepare_reprint_n.
      ENDCASE.
      PERFORM f_reprint_voucher.
  ENDCASE.
ENDFORM.                    " HANDLE_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_select.
  DATA : ls_head    LIKE LINE OF gt_head,
         ls_reprint LIKE LINE OF gt_reprint.
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row.

  CASE 'X'.
    WHEN radio8.
      LOOP AT gt_reprint INTO ls_reprint.
        IF fu_select = 'X'.
          APPEND sy-tabix TO lt_rows.
        ENDIF.
        TRY.
            lr_selections = gr_table->get_selections( ).
          CATCH cx_salv_not_found.
        ENDTRY.
        lr_selections->set_selected_rows( lt_rows ).
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT gt_head INTO ls_head.
        IF fu_select = 'X'.
          APPEND sy-tabix TO lt_rows.
        ENDIF.
        TRY.
            lr_selections = gr_hierseq->get_selections( 1 ).
          CATCH cx_salv_not_found.
        ENDTRY.
        lr_selections->set_selected_rows( lt_rows ).
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_VOUCHER
*&---------------------------------------------------------------------*
FORM f_create_voucher CHANGING fc_zidvc.
  DATA : lt_voucher    TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         ls_voucher    LIKE LINE OF lt_voucher,
         ls_head       LIKE LINE OF gt_head,
         lt_header     TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         ls_header     LIKE LINE OF lt_header,
         lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row.

  DATA : i        TYPE i,
         lv_kdvch TYPE zf63nomor-kdvch.

  TRY.
      lr_selections = gr_hierseq->get_selections( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  PERFORM f_get_next_number USING 'ZIDVCH' pa_gsber sy-datum(4)
                                  '' '' ''
                            CHANGING fc_zidvc lv_kdvch.

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      CLEAR ls_head.
      READ TABLE gt_head INTO ls_head INDEX i.
      IF sy-subrc = 0.
        IF ls_head-icon = icon_led_green.
          CONTINUE.
        ENDIF.
        ls_head-zidvc   = fc_zidvc.
        ls_head-icon    = icon_led_green.
        MODIFY gt_head FROM ls_head INDEX i TRANSPORTING icon zidvc.

        MOVE-CORRESPONDING ls_head TO ls_header.
        ls_header-gjahr = ls_head-kjahr.
        APPEND ls_header TO lt_header.
        CLEAR : ls_header.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ls_voucher-bukrs      = pa_bukrs.
  ls_voucher-gsber      = pa_gsber.
  ls_voucher-vkbur      = pa_vkbur.
  ls_voucher-gtype      = pa_gtype.
  ls_voucher-zidvc      = fc_zidvc.
  ls_voucher-vjahr      = sy-datum(4).
  ls_voucher-hkont      = zfexpense-hkont.
  ls_voucher-waers      = zfexpense-waers.
  ls_voucher-wrbtr      = zfexpense-wrbtr.
  ls_voucher-bktxt      = zfexpense-bktxt.
  IF zfexpense-advance IS NOT INITIAL.
    ls_voucher-adv_gjahr  = gv_gjahr.
    ls_voucher-adv_belnr  = gv_belnr.
  ENDIF.
  ls_voucher-ernam      = sy-uname.
  ls_voucher-erdat      = sy-datum.
  ls_voucher-erzet      = sy-uzeit.
  INSERT INTO zf63trnvch VALUES ls_voucher.

  MODIFY zf63trnhdr FROM TABLE lt_header.

  gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).
ENDFORM.                    " F_CREATE_VOUCHER

*&---------------------------------------------------------------------*
*&      Form  F_CEK_NUMBER_RANGE
*&---------------------------------------------------------------------*
FORM f_cek_number_range  USING    fu_object fu_nrrangenr fu_subobject
                                  fu_toyear.

  IF fu_subobject IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        nr_range_nr        = fu_nrrangenr
        object             = fu_object
      EXCEPTIONS
        interval_not_found = 1
        object_not_found   = 2
        OTHERS             = 3.
  ELSE.
    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        nr_range_nr        = fu_nrrangenr
        object             = fu_object
        subobject          = fu_subobject
        toyear             = fu_toyear
      EXCEPTIONS
        interval_not_found = 1
        object_not_found   = 2
        OTHERS             = 3.
  ENDIF.

  IF sy-subrc <> 0.
    PERFORM f_error_message USING ''
                                  'Number range interval does not exist'.
  ENDIF.
ENDFORM.                    " F_CEK_NUMBER_RANGE

*&---------------------------------------------------------------------*
*&      Form  F_CASH_BANK
*&---------------------------------------------------------------------*
FORM f_cash_bank .
  DATA : ls_head  LIKE LINE OF gt_head.

  zfexpense-waers = t093b-waers.
  READ TABLE gt_head INTO ls_head INDEX 1.
  CONCATENATE 'DEKLARASI' ls_head-name1 INTO zfexpense-bktxt
  SEPARATED BY space.
  gv_accba  = selected.
  zfexpense-total     = abs( zfexpense-total ).
  zfexpense-wrbtr     = zfexpense-total.
*  zfexpense-hkont     = gs_gtype-hkont.
  IF gs_gtype-jeadv IS NOT INITIAL.
    zfexpense-advance   = 'X'.
  ENDIF.
  CALL SCREEN 806 STARTING AT 10 10.
ENDFORM.                    " F_CASH_BANK

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_VOUCHER
*&---------------------------------------------------------------------*
FORM f_validasi_voucher CHANGING fc_subrc fc_vbund.
  DATA : ls_head   LIKE LINE OF gt_head,
         ls_detl   LIKE LINE OF gt_detl,
         lt_detail TYPE STANDARD TABLE OF zfexpstprnt INITIAL SIZE 0,
         ls_detail LIKE LINE OF gt_detail.
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row.
  DATA : i        TYPE i,
         lv_zidvc TYPE zfstexphdr-zidvc,
         lv_count TYPE i.
  DATA : lt_mstk TYPE STANDARD TABLE OF ty_mstk INITIAL SIZE 0,
         ls_mstk LIKE LINE OF lt_mstk.
  DATA : ls_typeexp LIKE LINE OF gt_typeexp,
         ls_accexp  LIKE LINE OF gt_accexp,
         lv_flag.

  CLEAR : zfexpense-total, gt_detail[], gt_detail, gt_window3[], gt_window3,
          lt_rows[], lt_rows, gs_header.

  gs_header-advance = gs_gtype-advance.
  gs_header-hkont   = zfexpense-hkont.
  PERFORM f_get_description USING 'SKAT' 'TXT20' 'SAKNR' zfexpense-hkont
                            CHANGING gs_header-txt20.

  TRY.
      lr_selections = gr_hierseq->get_selections( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      ADD 1 TO lv_count.
      READ TABLE gt_head INTO ls_head INDEX i.
      IF sy-subrc = 0.
        IF ls_head-icon = icon_led_green.
          CONTINUE.
        ENDIF.

        IF gs_header-znopol IS INITIAL.
          gs_header-znopol  = ls_head-znopol.
        ENDIF.

        ls_mstk-znopol  = ls_head-znopol.
        APPEND ls_mstk TO lt_mstk.
        CLEAR ls_mstk.

        LOOP AT gt_detl INTO ls_detl WHERE bukrs = ls_head-bukrs
                                       AND gsber = ls_head-gsber
                                       AND vkbur = ls_head-vkbur
                                       AND gtype = ls_head-gtype
                                       AND expnr = ls_head-expnr
                                       AND zidvc = ls_head-zidvc.
          ls_detail-bukrs         = ls_detl-bukrs.
          ls_detail-gsber         = ls_detl-gsber.
          ls_detail-vkbur         = ls_detl-vkbur.
          ls_detail-gtype         = ls_detl-gtype.
          ls_detail-expnr         = ls_detl-expnr.
          ADD ls_detl-wrbtrv TO zfexpense-total.
          ls_detail-type          = ls_detl-type.
          IF ls_detl-text IS INITIAL.
            ls_detail-description   = ls_detl-description.
          ELSE.
            CONCATENATE ls_detl-description '-' ls_detl-text
            INTO ls_detail-description
            SEPARATED BY space.
          ENDIF.
          IF ls_detl-wrbtrv < 0.
            ls_detail-shkzg = 'H'.
          ELSE.
            ls_detail-shkzg = 'S'.
          ENDIF.
          ls_detail-wrbtr         = abs( ls_detl-wrbtrv ).
          ls_detail-waers         = ls_detl-waers.

          IF fc_vbund IS INITIAL.
            fc_vbund  = ls_detl-vbund.
          ENDIF.

          APPEND ls_detail TO lt_detail.
          CLEAR ls_detail.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ELSE.
    fc_subrc = 4.
  ENDIF.

  IF fc_subrc IS INITIAL.
    CLEAR ls_detail.
    SORT lt_detail BY type.
    LOOP AT lt_detail INTO ls_detail.
      IF gs_header-advance IS INITIAL.
        READ TABLE gt_typeexp INTO ls_typeexp WITH KEY bukrs = pa_bukrs
                                                       gtype = pa_gtype
                                                       type  = ls_detail-type.
        IF sy-subrc = 0.
          READ TABLE gt_accexp INTO ls_accexp WITH KEY acctype = ls_typeexp-acctype
                                                       zmejl   = gs_gtype-memojurnal.
          IF sy-subrc = 0.
            ls_detail-hkont   = ls_accexp-hkont.
          ENDIF.
        ENDIF.
      ELSE.
        IF lv_flag IS INITIAL.
          lv_flag = selected.
          ls_detail-hkont   = '0141130000'.
        ENDIF.
      ENDIF.

      IF gs_gtype-advance IS INITIAL.
        CLEAR : ls_detail-bukrs, ls_detail-gsber, ls_detail-vkbur,
                ls_detail-gtype, ls_detail-expnr.
        COLLECT ls_detail INTO gt_detail.
      ELSE.
        APPEND ls_detail TO gt_detail.
      ENDIF.
      CLEAR ls_detail.
    ENDLOOP.

    LOOP AT gt_detail INTO ls_detail.
      WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_detail-waers.
      CONDENSE ls_detail-wrbtrt NO-GAPS.
      IF gs_gtype-memojurnal IS INITIAL.
        IF ls_detail-shkzg  = 'H'.
          CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt
          SEPARATED BY space.
        ENDIF.
      ENDIF.
      MODIFY gt_detail FROM ls_detail TRANSPORTING wrbtrt.
    ENDLOOP.

    CLEAR i.
    SORT lt_mstk BY znopol.
    DELETE ADJACENT DUPLICATES FROM lt_mstk COMPARING znopol.
    DESCRIBE TABLE lt_mstk LINES i.
    IF i > 1.
      fc_subrc = 1.
    ENDIF.

    IF gs_gtype-advance IS NOT INITIAL.
      IF lv_count > 1.
        fc_subrc = 2.
      ENDIF.
    ENDIF.

    IF zfexpense-advance IS NOT INITIAL.
      IF gv_belnr IS INITIAL.
        fc_subrc = 8.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_VOUCHER

*&---------------------------------------------------------------------*
*&      Form  F_CEK_HKONT
*&---------------------------------------------------------------------*
FORM f_cek_hkont  USING    fu_hkont
                  CHANGING fc_subrc.
  DATA : ls_zf63acc   LIKE LINE OF gt_zf63acc.

  CLEAR gv_nmvch.
  READ TABLE gt_zf63acc INTO ls_zf63acc WITH KEY hkont = fu_hkont.
  fc_subrc = sy-subrc.
  IF sy-subrc = 0.
    gv_nmvch  = ls_zf63acc-nmvoucher.
  ENDIF.
ENDFORM.                    " F_CEK_HKONT

*&---------------------------------------------------------------------*
*&      Form  F_Alv_LIST_POST
*&---------------------------------------------------------------------*
FORM f_alv_list_post .
  DATA : lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings,
         lr_events    TYPE REF TO cl_salv_events_table,
         lr_aggrs     TYPE REF TO cl_salv_aggregations.

  TRY.
      cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = gr_table
          CHANGING
            t_table        = gt_out ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_table->set_screen_status(
    pfstatus   = 'SALV_STANDARD1'
    report     = gv_repid ).

  PERFORM f_set_text USING : 'ICON' 'Sts' 'X',
                             'VBUND' 'Tr.Prt' 'X',
                             'WAERS' 'Curr.' 'X',
                             'GJAHR' 'Year' '',
                             'WWPOS' 'W & D' '',
                             'WWPFN' 'Sales area' '',
                             'WWSFR' 'Sales forc' '',
                             'KOART' 'Acct Type' '',
                             'XREF3' 'RefKey 3' '',
                             'SHKZG' 'D/C' '',
                             'POST' 'Flag' '',
                             'TEXT' 'Text' '',
                             'KMSTR' 'KM Start' 'X',
                             'KMEND' 'KM End' 'X'.

  PERFORM f_set_text USING : 'MEINS' '' abap_false,
                             'MENGE' '' abap_false.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  lr_aggrs = gr_table->get_aggregations( ).
  TRY.
      lr_aggrs->add_aggregation(
        columnname  = 'WRBTR'
        aggregation = if_salv_c_aggregation=>total ).

    CATCH cx_salv_data_error cx_salv_not_found cx_salv_existing.
  ENDTRY.

  PERFORM f_set_sort  USING : 'BLART'.

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.

  gr_table->display( ).
ENDFORM.                    " F_AlV_LIST_POST

*&---------------------------------------------------------------------*
*&      Form  F_Alv_LIST_REVERSE
*&---------------------------------------------------------------------*
FORM f_alv_list_reverse .
  DATA : lr_functions  TYPE REF TO cl_salv_functions,
         lr_display    TYPE REF TO cl_salv_display_settings,
         lr_events     TYPE REF TO cl_salv_events_table,
         lr_aggrs      TYPE REF TO cl_salv_aggregations,
         lr_selections TYPE REF TO cl_salv_selections.

  TRY.
      cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = gr_table
          CHANGING
            t_table        = gt_reverse ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_table->set_screen_status(
    pfstatus   = 'SALV_STANDARD2'
    report     = gv_repid ).

*  PERFORM f_set_text USING : 'ICON' 'Sts' 'X',
*                             'VBUND' 'Tr.Prt' 'X',
*                             'WAERS' 'Curr.' 'X',
*                             'GJAHR' 'Year' '',
*                             'WWPOS' 'W & D' '',
*                             'WWPFN' 'Sales area' '',
*                             'WWSFR' 'Sales forc' '',
*                             'KOART' 'Acct Type' '',
*                             'XREF3' 'RefKey 3' '',
*                             'SHKZG' 'D/C' '',
*                             'POST' 'Flag' ''.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

*  PERFORM f_set_sort  USING : 'BLART'.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_selections->set_selection_mode( if_salv_c_selection_mode=>single ).

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.

  gr_table->display( ).
ENDFORM.                    " F_Alv_LIST_REVERSE

*&---------------------------------------------------------------------*
*&      Form  F_SET_TEXT
*&---------------------------------------------------------------------*
FORM f_set_text  USING    fu_column fu_text fu_visible.
  DATA : lr_columns TYPE REF TO cl_salv_columns_table,
         lr_column  TYPE REF TO cl_salv_column_table.

  TRY.
      lr_columns = gr_table->get_columns( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_column ?= lr_columns->get_column( fu_column ).
  lr_column->set_long_text( fu_text ).
  lr_column->set_medium_text( fu_text ).
  lr_column->set_short_text( fu_text ).
  lr_column->set_visible( fu_visible ).
ENDFORM.                    " F_LONG_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_SET_TEXT_HIER
*&---------------------------------------------------------------------*
FORM f_set_text_hier  USING    fu_column fu_text fu_visible.
  DATA : lr_columns TYPE REF TO cl_salv_columns_hierseq,
         lr_column  TYPE REF TO cl_salv_column_hierseq.

  TRY.
      lr_columns = gr_hierseq->get_columns( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_column ?= lr_columns->get_column( fu_column ).
  lr_column->set_long_text( fu_text ).
  lr_column->set_medium_text( fu_text ).
  lr_column->set_short_text( fu_text ).
  lr_column->set_visible( fu_visible ).
ENDFORM.                    " F_SET_TEXT_HIER

*&---------------------------------------------------------------------*
*&      Form  F_HIDDEN_COLUMN
*&---------------------------------------------------------------------*
FORM f_hidden_column  USING    fu_group fu_invisible.
  DATA : ls_cols1 LIKE LINE OF tc_expense-cols,
         ls_cols2 LIKE LINE OF tc_final-cols.

  CASE sy-dynnr.
    WHEN '0804'.
      READ TABLE tc_expense-cols INTO ls_cols1
                                 WITH KEY screen-group1 = fu_group.
      IF sy-subrc = 0.
        IF fu_invisible IS INITIAL.
          ls_cols1-invisible = 'X'.
        ELSE.
          CLEAR : ls_cols1-invisible.
        ENDIF.
        MODIFY tc_expense-cols FROM ls_cols1 INDEX sy-tabix.
      ENDIF.

    WHEN '0805'.
      READ TABLE tc_final-cols INTO ls_cols2
                               WITH KEY screen-group1 = fu_group.
      IF sy-subrc = 0.
        IF fu_invisible IS INITIAL.
          ls_cols2-invisible = 'X'.
        ELSE.
          CLEAR : ls_cols2-invisible.
        ENDIF.
        MODIFY tc_final-cols FROM ls_cols2 INDEX sy-tabix.
      ENDIF.

    WHEN '0811'.
      READ TABLE tc_transaction-cols INTO ls_cols2
                                     WITH KEY screen-group1 = fu_group.
      IF sy-subrc = 0.
        IF fu_invisible IS INITIAL.
          ls_cols2-invisible = 'X'.
        ELSE.
          CLEAR : ls_cols2-invisible.
        ENDIF.
        MODIFY tc_transaction-cols FROM ls_cols2 INDEX sy-tabix.
      ENDIF.

    WHEN '0813'.
      READ TABLE tc_simtran-cols INTO ls_cols2
                                 WITH KEY screen-group1 = fu_group.
      IF sy-subrc = 0.
        IF fu_invisible IS INITIAL.
          ls_cols2-invisible = 'X'.
        ELSE.
          CLEAR : ls_cols2-invisible.
        ENDIF.
        MODIFY tc_simtran-cols FROM ls_cols2 INDEX sy-tabix.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_HIDDEN_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_SIMULATE
*&---------------------------------------------------------------------*
FORM f_bapi_simulate TABLES   accountgl         STRUCTURE bapiacgl09
                              accountpayable    STRUCTURE bapiacap09
                              accountreceivable STRUCTURE bapiacar09
                              currencyamount    STRUCTURE bapiaccr09
                              extension1        STRUCTURE bapiacextc
                              criteria          STRUCTURE bapiackec9
                     USING    documentheader    STRUCTURE bapiache09
                     CHANGING fc_error.

  DATA : ls_return TYPE bapiret2,
         ls_error  TYPE bapiret2.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'E'.
      fc_error            = selected.
      ls_error-type       = ls_return-type.
      ls_error-id         = ls_return-id.
      ls_error-number     = ls_return-number.
      ls_error-message    = ls_return-message.
      ls_error-message_v1 = ls_return-message_v1.
      ls_error-message_v2 = ls_return-message_v2.
      ls_error-message_v3 = ls_return-message_v3.
      APPEND ls_error TO gt_error.
      CLEAR ls_error.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_SIMULATE

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
FORM f_document_header USING    fu_glvor fu_blart fu_bktxt fu_xblnr
                       CHANGING documentheader    STRUCTURE bapiache09.

  documentheader-bus_act     = fu_glvor.
  documentheader-username    = sy-uname.
  documentheader-comp_code   = pa_bukrs.
  documentheader-doc_date    = pa_budat.
  documentheader-pstng_date  = pa_budat.
  documentheader-doc_type    = fu_blart.
  documentheader-ref_doc_no  = fu_xblnr.
  documentheader-header_txt  = fu_bktxt.
ENDFORM.                    " F_DOCUMENT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_GL
*&---------------------------------------------------------------------*
FORM f_account_gl  TABLES   accountgl         STRUCTURE bapiacgl09
                            currencyamount    STRUCTURE bapiaccr09
                            extension1        STRUCTURE bapiacextc
                            criteria          STRUCTURE bapiackec9
                   USING    fs_out            LIKE LINE OF gt_out
                            fu_name1 fu_znopol fu_blart fu_bktxt fu_cancel.

  DATA : ls_gl      LIKE LINE OF accountgl,
         ls_ca      LIKE LINE OF currencyamount,
         ls_ex      LIKE LINE OF extension1,
         ls_cr      LIKE LINE OF criteria,
         ls_zf63acc LIKE LINE OF gt_zf63acc.

  DATA : lv_jnskend TYPE zf63masterkend-jnskend,
         lv_subrc   TYPE sy-subrc,
         ls_bsik    LIKE LINE OF gt_bsik,
         lv_day(20).

  ls_gl-itemno_acc            = fs_out-buzei.
  PERFORM f_alpha_conversion USING fs_out-hkont
                             CHANGING ls_gl-gl_account.
  ls_gl-bus_area              = fs_out-gsber.
  ls_gl-trade_id              = fs_out-vbund.
  ls_gl-costcenter            = fs_out-kostl.
  ls_gl-ref_key_3             = fs_out-xref3.
  ls_gl-alloc_nmbr            = fs_out-zuonr.

  IF fs_out-kostl+7(3) = '101' OR
    fs_out-kostl+7(3) = '109' OR
    fs_out-kostl+7(3) = '201'.
    IF fs_out-wwsfr IS NOT INITIAL.
      PERFORM f_item_text USING fs_out-wwsfr ';' '0'
                          CHANGING ls_gl-item_text.
    ELSEIF fs_out-wwpos IS NOT INITIAL.
      PERFORM f_item_text USING fs_out-wwpos ';' '0'
                          CHANGING ls_gl-item_text.
    ENDIF.

    PERFORM f_item_text USING ls_gl-item_text
                              fu_name1 '0'
                        CHANGING ls_gl-item_text.
    PERFORM f_item_text USING ls_gl-item_text ';' '0'
                        CHANGING ls_gl-item_text.
    PERFORM f_item_text USING ls_gl-item_text
                              fs_out-description '0'
                        CHANGING ls_gl-item_text.
    PERFORM f_item_text USING ls_gl-item_text ';' '0'
                        CHANGING ls_gl-item_text.

    IF fs_out-meins = 'TAG'.
      PERFORM f_days_conversion USING fs_out-menge fs_out-meins
                                CHANGING lv_day.

      PERFORM f_item_text USING ls_gl-item_text
                                lv_day '0'
                          CHANGING ls_gl-item_text.
      PERFORM f_item_text USING ls_gl-item_text ';' '0'
                          CHANGING ls_gl-item_text.
    ENDIF.

    PERFORM f_item_text USING ls_gl-item_text
                              fu_znopol '0'
                        CHANGING ls_gl-item_text.
  ELSE.
    CASE fu_blart.
      WHEN 'SA'.
        READ TABLE gt_zf63acc INTO ls_zf63acc
                              WITH KEY hkont = ls_gl-gl_account
                              TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          IF fs_out-description IS NOT INITIAL.
            ls_gl-item_text   = fs_out-description.
          ELSE.
            ls_gl-item_text   = fu_bktxt.
          ENDIF.
        ELSE.
          PERFORM f_item_text USING fu_name1 ';' '0'
                              CHANGING ls_gl-item_text.
          PERFORM f_item_text USING ls_gl-item_text
                                    fs_out-description '0'
                              CHANGING ls_gl-item_text.
          PERFORM f_item_text USING ls_gl-item_text ';' '0'
                              CHANGING ls_gl-item_text.

          IF fs_out-meins = 'TAG'.
            PERFORM f_days_conversion USING fs_out-menge fs_out-meins
                                      CHANGING lv_day.

            PERFORM f_item_text USING ls_gl-item_text
                                      lv_day '0'
                                CHANGING ls_gl-item_text.
            PERFORM f_item_text USING ls_gl-item_text ';' '0'
                                CHANGING ls_gl-item_text.
          ENDIF.

          PERFORM f_item_text USING ls_gl-item_text
                                    fu_znopol '0'
                              CHANGING ls_gl-item_text.
        ENDIF.
      WHEN 'KZ'.
        IF gs_gtype-advance IS NOT INITIAL.
          IF fu_cancel IS INITIAL.
            PERFORM f_item_text USING gs_gtype-ltext fu_name1 '1'
                                CHANGING ls_gl-item_text.
*            PERFORM f_item_text USING ls_gl-item_text fs_out-text '1'
*                                CHANGING ls_gl-item_text.
**          PERFORM f_item_text USING fu_bktxt '' '1'
**                              CHANGING ls_gl-item_text.
          ELSE.
            ls_gl-item_text   = fu_bktxt.
          ENDIF.
        ELSE.
          IF fu_cancel IS INITIAL.
            PERFORM f_item_text USING 'Peny' fu_bktxt '1'
                                CHANGING ls_gl-item_text.

            PERFORM f_item_text USING ls_gl-item_text ',' '0'
                                CHANGING ls_gl-item_text.
            IF fs_out-wwsfr IS NOT INITIAL.
              PERFORM f_item_text USING ls_gl-item_text fs_out-wwsfr '0'
                                  CHANGING ls_gl-item_text.
              PERFORM f_item_text USING ls_gl-item_text ',' '0'
                                  CHANGING ls_gl-item_text.
            ELSEIF fs_out-wwpos IS NOT INITIAL.
              PERFORM f_item_text USING ls_gl-item_text fs_out-wwpos '0'
                                  CHANGING ls_gl-item_text.
              PERFORM f_item_text USING ls_gl-item_text ',' '0'
                                  CHANGING ls_gl-item_text.
            ENDIF.
            CLEAR ls_bsik.
            READ TABLE gt_bsik INTO ls_bsik INDEX 1.
            IF sy-subrc = 0.
              PERFORM f_item_text USING ls_gl-item_text ls_bsik-zuonr '0'
                                  CHANGING ls_gl-item_text.
            ENDIF.
          ELSE.
            ls_gl-item_text   = fu_bktxt.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

  CLEAR lv_subrc.
  WHILE lv_subrc IS INITIAL.
    REPLACE ',,' WITH ',' INTO ls_gl-item_text.
    lv_subrc = sy-subrc.
  ENDWHILE.

  IF gs_gtype-advance IS INITIAL.
    IF fs_out-text IS NOT INITIAL.
      IF fs_out-blart = 'SA'.
        ls_gl-item_text = fs_out-text.
      ENDIF.
    ENDIF.
  ENDIF.

  APPEND ls_gl TO accountgl.

  ls_ca-itemno_acc    = fs_out-buzei.
  ls_ca-curr_type     = '00'.
  ls_ca-currency      = 'IDR'.
  PERFORM f_amount_modify  USING fs_out-wrbtr
                           CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_ex(3)                = fs_out-buzei.
  ls_ex+3(2)              = fs_out-bschl.
  APPEND ls_ex TO extension1.

  IF fs_out-kostl+7(3) = '101' OR
    fs_out-kostl+7(3) = '109' OR
    fs_out-kostl+7(3) = '201'.
    criteria-itemno_acc        = fs_out-buzei.
    criteria-fieldname         = 'WWSFR'.
    criteria-character         = fs_out-wwsfr.
    APPEND criteria.
    criteria-itemno_acc        = fs_out-buzei.
    criteria-fieldname         = 'WWPOS'.
    criteria-character         = fs_out-wwpos.
    APPEND criteria.
    criteria-itemno_acc        = fs_out-buzei.
    criteria-fieldname         = 'WWPFN'.
    criteria-character         = fs_out-wwpfn.
    APPEND criteria.
    criteria-itemno_acc        = fs_out-buzei.
    criteria-fieldname         = 'COPA_KOSTL'.
    criteria-character         = fs_out-kostl.
    APPEND criteria.
  ENDIF.
ENDFORM.                    " F_ACCOUNT_GL

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_PAYABLE
*&---------------------------------------------------------------------*
FORM f_account_payable  TABLES   accountpayable    STRUCTURE bapiacap09
                                 currencyamount    STRUCTURE bapiaccr09
                                 extension1        STRUCTURE bapiacextc
                                 criteria          STRUCTURE bapiackec9
                        USING    fs_out            LIKE LINE OF gt_out
                                 fu_name1 fu_bktxt fu_cancel.

  DATA : ls_ap LIKE LINE OF accountpayable,
         ls_ca LIKE LINE OF currencyamount,
         ls_ex LIKE LINE OF extension1,
         ls_cr LIKE LINE OF criteria.

  DATA : lv_subrc   TYPE sy-subrc.

  ls_ap-itemno_acc    = fs_out-buzei.
  PERFORM f_alpha_conversion USING fs_out-hkont
                             CHANGING ls_ap-vendor_no.
  ls_ap-bus_area      = fs_out-gsber.
  ls_ap-sp_gl_ind     = fs_out-umskz.
  ls_ap-alloc_nmbr    = fs_out-zuonr.

  IF gs_gtype-advance IS NOT INITIAL.
    ls_ap-bline_date = pa_budat + 30.
    IF fu_cancel IS INITIAL.
*    PERFORM f_item_text USING fu_bktxt '' '0'
*                        CHANGING ls_ap-item_text.
      PERFORM f_item_text USING gs_gtype-ltext fu_name1 '1'
                          CHANGING ls_ap-item_text.
*      PERFORM f_item_text USING ls_ap-item_text fs_out-text '1'
*                          CHANGING ls_ap-item_text.
    ELSE.
      ls_ap-item_text   = fu_bktxt.
    ENDIF.
  ELSE.
    IF fu_cancel IS INITIAL.
      PERFORM f_item_text USING 'Peny' fu_bktxt '1'
                          CHANGING ls_ap-item_text.

      PERFORM f_item_text USING ls_ap-item_text ',' '0'
                          CHANGING ls_ap-item_text.
      IF fs_out-wwsfr IS NOT INITIAL.
        PERFORM f_item_text USING ls_ap-item_text fs_out-wwsfr '0'
                            CHANGING ls_ap-item_text.
        PERFORM f_item_text USING ls_ap-item_text ',' '0'
                            CHANGING ls_ap-item_text.
      ELSEIF fs_out-wwpos IS NOT INITIAL.
        PERFORM f_item_text USING ls_ap-item_text fs_out-wwpos '0'
                            CHANGING ls_ap-item_text.
        PERFORM f_item_text USING ls_ap-item_text ',' '0'
                            CHANGING ls_ap-item_text.
      ENDIF.

      PERFORM f_item_text USING ls_ap-item_text fs_out-zuonr '0'
                          CHANGING ls_ap-item_text.
    ELSE.
      ls_ap-item_text   = fu_bktxt.
    ENDIF.
  ENDIF.

  CLEAR lv_subrc.
  WHILE lv_subrc IS INITIAL.
    REPLACE ',,' WITH ',' INTO ls_ap-item_text.
    lv_subrc = sy-subrc.
  ENDWHILE.

  APPEND ls_ap TO accountpayable.

  ls_ca-itemno_acc    = fs_out-buzei.
  ls_ca-curr_type     = '00'.
  ls_ca-currency      = 'IDR'.
  PERFORM f_amount_modify  USING fs_out-wrbtr
                           CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_ex(3)    = fs_out-buzei.
  ls_ex+3(2)  = fs_out-bschl.
  APPEND ls_ex TO extension1.
ENDFORM.                    " F_ACCOUNT_PAYABLE

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_RECEIVABLE
*&---------------------------------------------------------------------*
FORM f_account_receivable  TABLES   accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    criteria          STRUCTURE bapiackec9
                           USING    fs_out            LIKE LINE OF gt_out.

  DATA : ls_ar LIKE LINE OF accountreceivable,
         ls_ca LIKE LINE OF currencyamount,
         ls_ex LIKE LINE OF extension1,
         ls_cr LIKE LINE OF criteria.

*  ls_ar-itemno_acc.
*  ls_ar-customer
*  ls_ar-bus_area
*  ls_ar-ref_key_3
*  ls_ar-alloc_nmbr
*  ls_ar-item_text
*  APPEND ls_ar TO accountreceivable.
*
*  ls_ca-itemno_acc
*  ls_ca-curr_type     = '00'.
*  ls_ca-currency      = 'IDR'.
*  PERFORM f_amount_modify  USING shkzg wrbtr
*                            CHANGING ls_ca-amt_doccur.
*  APPEND ls_ca TO currencyamount.
*
*  ls_ex(3)                = fu_buzei.
*  ls_ex+3(2)              = gs_post-newbs.
*  APPEND ls_e1 TO extension1.
ENDFORM.                    " F_ACCOUNT_RECEIVABLE

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNT_MODIFY
*&---------------------------------------------------------------------*
FORM f_amount_modify   USING    fu_wrbtr
                       CHANGING fc_wrbtr.
  DATA : lv_wrbtr     TYPE bseg-wrbtr,
         lv_value(50).

  lv_wrbtr = fu_wrbtr.

  WRITE lv_wrbtr TO lv_value CURRENCY 'IDR'.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.

  fc_wrbtr = lv_value.
ENDFORM.                    " F_AMOUNT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_SET_SORT
*&---------------------------------------------------------------------*
FORM f_set_sort  USING    fu_blart.
  DATA : lr_sorts   TYPE REF TO cl_salv_sorts.

  lr_sorts = gr_table->get_sorts( ).

  lr_sorts->clear( ).

  TRY.
      lr_sorts->add_sort(
        columnname = fu_blart
        position   = 1
        group      = 2
        subtotal   = abap_true
        sequence   = if_salv_c_sort=>sort_up ).
    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
  ENDTRY.
ENDFORM.                    " F_SET_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_alpha  USING    fu_hkont fu_lifnr fu_koart
                         CHANGING fc_value fc_description
                                  fc_kostl fc_wwpfn fc_wwsfr fc_wwpos
                                  fc_vbund.

  DATA : ls_ska1 LIKE LINE OF gt_ska1,
         ls_mstp LIKE LINE OF gt_mstp.

  DATA : lv_hkont TYPE ska1-saknr,
         lv_lifnr TYPE lfa1-lifnr.

  CASE fu_koart.
    WHEN 'S'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = fu_hkont
        IMPORTING
          output = fc_value.

      READ TABLE gt_ska1 INTO ls_ska1 WITH KEY saknr = fc_value.
      IF sy-subrc = 0.
        IF ls_ska1-xbilk = space.
          READ TABLE gt_mstp INTO ls_mstp INDEX 1.
          IF sy-subrc = 0.
            IF fc_kostl IS INITIAL.
              fc_kostl  = ls_mstp-kostl.
            ENDIF.
            fc_wwpfn  = ls_mstp-wwpfn.
            IF fc_wwsfr IS INITIAL.
              fc_wwsfr  = ls_mstp-wwsfr.
            ENDIF.
            IF fc_wwpos IS INITIAL.
              fc_wwpos  = ls_mstp-wwpos.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      SELECT SINGLE txt20
        FROM skat
        INTO fc_description
        WHERE saknr = fc_value.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = fu_lifnr
        IMPORTING
          output = lv_lifnr.

      IF fc_vbund IS INITIAL.
        SELECT SINGLE vbund
          FROM zf63masterperson
          INTO fc_vbund
          WHERE lifnr = lv_lifnr.
      ENDIF.

    WHEN 'K'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = fu_lifnr
        IMPORTING
          output = fc_value.

      SELECT SINGLE name1
        FROM lfa1
        INTO fc_description
        WHERE lifnr = fc_value.

      IF fc_vbund IS INITIAL.
        SELECT SINGLE vbund
          FROM zf63masterperson
          INTO fc_vbund
          WHERE lifnr = fc_value.
      ENDIF.

    WHEN 'D'.
      SELECT SINGLE name1
        FROM kna1
        INTO fc_description
        WHERE kunnr = fc_value.
  ENDCASE.
ENDFORM.                    " F_CONVERSION_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data TABLES    accountgl         STRUCTURE bapiacgl09
                              accountpayable    STRUCTURE bapiacap09
                              accountreceivable STRUCTURE bapiacar09
                              currencyamount    STRUCTURE bapiaccr09
                              extension1        STRUCTURE bapiacextc
                              criteria          STRUCTURE bapiackec9
                     USING    documentheader    STRUCTURE bapiache09
                              fu_post
                     CHANGING fc_belnr fc_gjahr fc_message.

  DATA : obj_type  LIKE bapiache09-obj_type,
         return    LIKE TABLE OF bapiret2 WITH HEADER LINE,
         ls_out    LIKE LINE OF gt_out,
         ls_cancel LIKE LINE OF gt_cancel.

  obj_type = 'BKPF'.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  IF return[] IS NOT INITIAL.
    READ TABLE return INDEX 1.
    IF return-type = 'S'.
      fc_belnr  = return-message_v2(10).
      fc_gjahr  = return-message_v2+14(4).

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      IF gt_out[] IS NOT INITIAL.
        LOOP AT gt_out INTO ls_out WHERE post = fu_post.
          ls_out-belnr    = fc_belnr.
          ls_out-gjahr    = fc_gjahr.
          MODIFY gt_out FROM ls_out TRANSPORTING belnr gjahr.
          CLEAR ls_out.
        ENDLOOP.
      ELSEIF gt_cancel[] IS NOT INITIAL.
        LOOP AT gt_cancel INTO ls_cancel.
          ls_cancel-belnr    = fc_belnr.
          ls_cancel-gjahr    = fc_gjahr.
          MODIFY gt_cancel FROM ls_cancel TRANSPORTING belnr gjahr.
          CLEAR ls_cancel.
        ENDLOOP.
      ENDIF.
    ELSE.
      LOOP AT return WHERE type = 'E'.
        fc_message = return-message.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING
*&---------------------------------------------------------------------*
FORM f_prepare_posting  USING    fu_blart fu_xblnr fu_bschl fu_umskz
                                 fu_lifnr fu_hkont fu_acctype
                                 fs_trnvch  LIKE LINE OF gt_trnvch
                                 fs_trndtl  LIKE LINE OF gt_trndtl
                                 fu_tabnm.

  DATA : ls_out      LIKE LINE OF gt_out,
         ls_tbsl     LIKE LINE OF gt_tbsl,
         ls_bsik     LIKE LINE OF gt_bsik,
         ls_kostlexp LIKE LINE OF gt_kostlexp.

  DATA : ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_trndtl2 LIKE LINE OF gt_trndtl2.

  ADD 1 TO gv_buzei.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = fu_bschl.

  ls_out-buzei         = gv_buzei.
  ls_out-blart         = fu_blart.
  ls_out-xblnr         = fu_xblnr.
  ls_out-bschl         = fu_bschl.
  ls_out-shkzg         = ls_tbsl-shkzg.
  ls_out-umskz         = fu_umskz.
  ls_out-gsber         = pa_gsber.
  ls_out-koart         = ls_tbsl-koart.
  ls_out-xref3         = fs_trnvch-zidvc.
  ls_out-text          = fs_trndtl-text.

  CASE fu_tabnm.
    WHEN 'ZF63TRNDTL'.
      ls_out-description   = fs_trndtl-description.
      ls_out-zuonr         = fu_xblnr.
      ls_out-menge         = fs_trndtl-menge.
      ls_out-meins         = fs_trndtl-meins.
      ls_out-vbund         = fs_trndtl-vbund.
    WHEN 'ZF63TRNVCH'.
      ls_out-description   = fs_trnvch-bktxt.
      ls_out-zuonr         = fu_xblnr.
    WHEN 'BSIK'.
      IF fu_umskz IS INITIAL.
        ls_out-zuonr         = fu_xblnr.
      ELSE.
        CLEAR ls_bsik.
        READ TABLE gt_bsik INTO ls_bsik INDEX 1.
        IF sy-subrc = 0.
          ls_out-zuonr         = ls_bsik-zuonr.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      ls_out-zuonr         = fu_xblnr.
  ENDCASE.

  IF fu_acctype IS NOT INITIAL.
    CLEAR : ls_kostlexp.
    READ TABLE gt_kostlexp INTO ls_kostlexp WITH KEY gsber   = pa_gsber
                                                     vkbur   = pa_vkbur
                                                     gtype   = pa_gtype
                                                     acctype = fu_acctype.
    IF sy-subrc = 0.
      ls_out-kostl  = ls_kostlexp-kostl.
      ls_out-wwsfr  = ls_kostlexp-wwsfr.
      ls_out-wwpos  = ls_kostlexp-wwpos.
    ENDIF.
  ENDIF.

  CASE ls_tbsl-koart.
    WHEN 'S'.
      PERFORM f_conversion_alpha USING    fu_hkont fu_lifnr ls_tbsl-koart
                                 CHANGING ls_out-hkont
                                          ls_out-ktext
                                          ls_out-kostl ls_out-wwpfn
                                          ls_out-wwsfr ls_out-wwpos
                                          ls_out-vbund.

    WHEN 'K'.
      PERFORM f_conversion_alpha USING    fu_hkont fu_lifnr ls_tbsl-koart
                                 CHANGING ls_out-hkont
                                          ls_out-ktext
                                          ls_out-kostl ls_out-wwpfn
                                          ls_out-wwsfr ls_out-wwpos
                                          ls_out-vbund.
    WHEN 'D'.
  ENDCASE.

  PERFORM f_get_amount  USING fu_lifnr fu_tabnm fs_trnvch fs_trndtl
                              ls_trnhdr2 ls_trndtl2 ls_tbsl-shkzg
                        CHANGING ls_out-waers ls_out-wrbtr.

  APPEND ls_out TO gt_out.
  CLEAR ls_out.
ENDFORM.                    " F_PREPARE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_GET_AMOUNT
*&---------------------------------------------------------------------*
FORM f_get_amount  USING    fu_lifnr fu_tabnm
                            fs_trnvch   LIKE LINE OF gt_trnvch
                            fs_trndtl   LIKE LINE OF gt_trndtl
                            fs_trnhdr2  LIKE LINE OF gt_trnhdr2
                            fs_trndtl2  LIKE LINE OF gt_trndtl2
                            fu_shkzg
                   CHANGING fc_waers fc_wrbtr.

  DATA : lt_bsik TYPE STANDARD TABLE OF bsik INITIAL SIZE 0,
         ls_bsik LIKE LINE OF lt_bsik.

  CASE fu_tabnm.
    WHEN 'BSIK'.
      CLEAR ls_bsik.
      LOOP AT gt_bsik INTO ls_bsik.
        IF fc_waers IS INITIAL.
          fc_waers = ls_bsik-waers.
        ENDIF.
        ADD ls_bsik-dmbtr TO fc_wrbtr.
      ENDLOOP.

    WHEN 'ZF63TRNDTL'.
      fc_waers  = fs_trndtl-waers.
      fc_wrbtr  = fs_trndtl-wrbtr.

    WHEN 'ZF63TRNDTL2'.
      fc_waers  = fs_trndtl2-waers.
      fc_wrbtr  = fs_trndtl2-wrbtr.

    WHEN 'ZF63TRNVCH'.
      fc_waers  = fs_trnvch-waers.
      fc_wrbtr  = fs_trnvch-wrbtr.

    WHEN OTHERS.
      IF fs_trnvch IS NOT INITIAL.
        fc_waers  = fs_trnvch-waers.
        fc_wrbtr  = fs_trnvch-wrbtr.
      ELSEIF fs_trnhdr2 IS NOT INITIAL.
        fc_waers  = fs_trnhdr2-waers.
        fc_wrbtr  = fs_trnhdr2-wrbtr.
      ENDIF.
  ENDCASE.

  IF fu_shkzg = 'H'.
    fc_wrbtr  = fc_wrbtr * -1.
  ENDIF.
ENDFORM.                    " F_GET_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_GET_BSIK
*&---------------------------------------------------------------------*
FORM f_get_bsik  USING    fu_bukrs fu_lifnr fu_umskz fu_gjahr fu_belnr
                          fu_gsber fu_voucher.
  DATA : lt_bsik    TYPE STANDARD TABLE OF bsik INITIAL SIZE 0,
         ls_bsik    LIKE LINE OF lt_bsik,
         lt_trnvch  TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         ls_trnvch  LIKE LINE OF lt_trnvch,
         lv_delete,
         lt_trnhdr2 TYPE STANDARD TABLE OF zf63trnhdr2 INITIAL SIZE 0,
         ls_trnhdr2 LIKE LINE OF lt_trnhdr2.

  IF fu_belnr IS INITIAL.
    SELECT bukrs lifnr umsks umskz augdt augbl zuonr gjahr belnr buzei
      budat bldat waers gsber dmbtr sgtxt hkont
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE gt_bsik
      WHERE bukrs = fu_bukrs
        AND lifnr = fu_lifnr
        AND umskz = fu_umskz
        AND gsber = fu_gsber.
  ELSE.
    SELECT bukrs lifnr umsks umskz augdt augbl zuonr gjahr belnr buzei
      budat bldat waers gsber dmbtr sgtxt hkont
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE gt_bsik
      WHERE bukrs = fu_bukrs
        AND lifnr = fu_lifnr
        AND umskz = fu_umskz
        AND gjahr = fu_gjahr
        AND belnr = fu_belnr
        AND gsber = fu_gsber.
  ENDIF.

  IF fu_voucher IS NOT INITIAL.
    lt_bsik[] = gt_bsik[].
    SORT lt_bsik BY belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING belnr gjahr.
    IF lt_bsik[] IS NOT INITIAL.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          SELECT *
            FROM zf63trnvch
            INTO CORRESPONDING FIELDS OF TABLE lt_trnvch
            FOR ALL ENTRIES IN lt_bsik
            WHERE bukrs     = lt_bsik-bukrs
              AND gsber     = lt_bsik-gsber
              AND adv_belnr = lt_bsik-belnr
              AND adv_gjahr = lt_bsik-gjahr.

          LOOP AT gt_bsik INTO ls_bsik.
            CLEAR : lv_delete.
            LOOP AT lt_trnvch INTO ls_trnvch WHERE adv_belnr = ls_bsik-belnr
                                               AND adv_gjahr = ls_bsik-gjahr.
              IF ls_trnvch-belnrrev IS INITIAL AND
                ls_trnvch-belnrpadvrev IS INITIAL.
                lv_delete = selected.
              ENDIF.
              IF lv_delete IS NOT INITIAL.
                DELETE TABLE gt_bsik FROM ls_bsik.
              ENDIF.
            ENDLOOP.
            CLEAR ls_bsik.
          ENDLOOP.

        WHEN 'ZF63N'.
          SELECT *
            FROM zf63trnhdr2
            INTO CORRESPONDING FIELDS OF TABLE lt_trnhdr2
            FOR ALL ENTRIES IN lt_bsik
            WHERE bukrs     = lt_bsik-bukrs
              AND gsber     = lt_bsik-gsber
              AND belnrpadv = lt_bsik-belnr
              AND gjahrpadv = lt_bsik-gjahr
              AND gtype     = gs_gtype-jeadv.

          LOOP AT gt_bsik INTO ls_bsik.
            READ TABLE lt_trnhdr2 INTO ls_trnhdr2
                                  WITH KEY bukrs     = ls_bsik-bukrs
                                           gsber     = ls_bsik-gsber
                                           belnrpadv = ls_bsik-belnr
                                           gjahrpadv = ls_bsik-gjahr.
            IF sy-subrc <> 0.
              DELETE TABLE gt_bsik FROM ls_bsik.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BSIK

*&---------------------------------------------------------------------*
*&      Form  F_ITEM_TEXT
*&---------------------------------------------------------------------*
FORM f_item_text  USING    fu_value1 fu_value2 fu_flag
                  CHANGING fc_value.

  CASE fu_flag.
    WHEN '0'.
      CONCATENATE fu_value1 fu_value2 INTO fc_value.
    WHEN '1'.
      CONCATENATE fu_value1 fu_value2 INTO fc_value
      SEPARATED BY space.
  ENDCASE.
ENDFORM.                    " F_ITEM_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING    fu_proc fu_fname fu_zidvc fu_title fu_vbund.
  DATA : lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop,
         lv_formname        TYPE tdsfname,
         ls_detail          LIKE LINE OF gt_detail,
         ls_tbsl            LIKE LINE OF gt_tbsl,
         lv_prefix1(3),
         lv_prefix2(3).

  IF gs_gtype-memojurnal IS INITIAL.
    TRANSLATE gv_nmvch TO UPPER CASE.
    SEARCH gv_nmvch FOR 'CASH'.
    IF sy-subrc = 0.
      lv_prefix1  = 'CPV'.
      lv_prefix2  = 'CRV'.
    ELSE.
      lv_prefix1  = 'BPV'.
      lv_prefix2  = 'BRV'.
    ENDIF.
  ELSE.
    lv_prefix1  = 'MJ'.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  lwa_output_option-tdnewid   = 'X'.
  CASE fu_proc.
    WHEN 'PREV'.
      lwa_output_option-tdnoprint = 'X'.
    WHEN 'PRNT'.
      lwa_output_option-tdnoprev = 'X'.
  ENDCASE.

  IF gs_gtype-memojurnal IS NOT INITIAL.
    zfexpense-total = abs( zfexpense-total ).
  ENDIF.

  PERFORM f_isi_form USING fu_zidvc fu_title
                           zfexpense-bktxt zfexpense-total ''
                           gs_header-znopol lv_prefix1 fu_vbund ''.

  IF gs_gtype-memojurnal IS NOT INITIAL.
    READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = gs_gtype-bschl.
    IF sy-subrc = 0.
      ls_detail-shkzg   = ls_tbsl-shkzg.
    ENDIF.
    ls_detail-buzei         = '999'.
    ls_detail-description   = gs_header-txt20.
    ls_detail-hkont         = gs_header-hkont.
    ls_detail-wrbtrt        = gs_header-totalt.
    APPEND ls_detail TO gt_detail.
    CLEAR ls_detail.
    SORT gt_detail BY buzei DESCENDING.
  ENDIF.

  IF zfexpense-advance IS NOT INITIAL.
    lwa_control_option-no_close = 'X'.
  ENDIF.

  CALL FUNCTION lv_funcname
    EXPORTING
      output_options     = lwa_output_option
      control_parameters = lwa_control_option
      user_settings      = 'X'
      gs_header          = gs_header
    TABLES
      gt_window3         = gt_window3
      gt_detail          = gt_detail
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF zfexpense-advance IS NOT INITIAL.
    lwa_control_option-no_open = 'X'.

    lv_formname = 'ZFEXP_F002'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lv_formname
      IMPORTING
        fm_name            = lv_funcname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CLEAR : gt_window3[], gt_window3, gt_detail[], gt_detail.

    CONCATENATE 'PENY' gv_bktxt INTO gv_bktxt
    SEPARATED BY space.
    PERFORM f_isi_form USING fu_zidvc 'Cash/Bank Receipt Voucher'
                             gv_bktxt gv_dmbtr '' '' lv_prefix2 fu_vbund ''.

    ls_detail-description   = gv_description.
    ls_detail-hkont         = gv_hkont.
    ls_detail-wrbtrt        = gs_header-totalt.
    APPEND ls_detail TO gt_detail.

    lwa_control_option-no_close = space.

    CALL FUNCTION lv_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gs_header          = gs_header
      TABLES
        gt_window3         = gt_window3
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM double_click  USING    row column.
  DATA : ls_out     LIKE LINE OF gt_out,
         ls_cancel  LIKE LINE OF gt_cancel,
         ls_accexp  LIKE LINE OF gt_accexp,
         ls_typeexp LIKE LINE OF gt_typeexp,
         lv_valid   TYPE c.

  CASE 'X'.
    WHEN radio17.
      READ TABLE gt_cancel INTO ls_cancel INDEX row.
      IF sy-subrc = 0.
        CASE column.
          WHEN 'BELNR'.
            IF ls_cancel-belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_cancel-belnr.
              SET PARAMETER ID 'BUK' FIELD pa_bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_cancel-gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
        ENDCASE.
      ENDIF.
    WHEN OTHERS.
      READ TABLE gt_out INTO ls_out INDEX row.
      IF sy-subrc = 0.
        CASE column.
          WHEN 'BELNR'.
            IF ls_out-belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_out-belnr.
              SET PARAMETER ID 'BUK' FIELD pa_bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_out-gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
        ENDCASE.
      ENDIF.
  ENDCASE.
ENDFORM.                    " DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_reverse_document .
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i,
         ls_reverse    LIKE LINE OF gt_reverse.

  CALL SCREEN 807 STARTING AT 10 10.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      READ TABLE gt_reverse INTO ls_reverse INDEX i.
      IF sy-subrc = 0.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_REVERSE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_validasi_reverse_document  CHANGING fc_reverse.
  DATA : lv_xabwd TYPE t041c-xabwd,
         lv_gjahr TYPE t001b-frye1,
         lv_monat TYPE t001b-frpe1.
  DATA : lv_subrc TYPE sy-subrc,
         lv_datum TYPE sy-datum,
         ls_bseg  LIKE LINE OF gt_bseg.

  IF uf05a-stgrd IS INITIAL.
    lv_subrc  = sy-subrc.
    MESSAGE s601(f0) DISPLAY LIKE 'E'.
  ELSE.
    SELECT SINGLE txt40
      FROM t041ct
      INTO t041ct-txt40
      WHERE spras = sy-langu
        AND stgrd = uf05a-stgrd.
    IF sy-subrc <> 0.
      lv_subrc  = sy-subrc.
      MESSAGE s602(f0) WITH uf05a-stgrd DISPLAY LIKE 'E'.
    ELSE.
      IF bsis-budat IS INITIAL.
        IF zf63reverse-budat IS NOT INITIAL.
          bsis-budat  = zf63reverse-budat.
        ELSE.
          bsis-budat  = zf63reverse-budatpadv.
        ENDIF.
      ENDIF.

      IF zf63reverse-budat IS NOT INITIAL.
        lv_datum  = zf63reverse-budat.
      ELSE.
        lv_datum  = zf63reverse-budatpadv.
      ENDIF.

      lv_gjahr  = bsis-budat(4).
      lv_monat  = bsis-budat+4(2).

      CALL FUNCTION 'FI_PERIOD_CHECK'
        EXPORTING
          i_bukrs = pa_bukrs
          i_gjahr = lv_gjahr
          i_koart = '+'
          i_monat = lv_monat
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc <> 0.
        lv_subrc  = sy-subrc.
        MESSAGE s201(f5) WITH lv_monat lv_gjahr
                         DISPLAY LIKE 'E'.
      ENDIF.

      CALL FUNCTION 'FI_REVERSE_POSTING_PARAMETERS'
        EXPORTING
          i_stgrd = uf05a-stgrd
        IMPORTING
          e_xabwd = lv_xabwd.
      IF lv_xabwd IS INITIAL AND
        bsis-budat > '00000000' AND
        bsis-budat <> lv_datum.
        lv_subrc  = sy-subrc.
        MESSAGE s745(f5) WITH uf05a-stgrd zf63reverse-budat
                         DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lv_subrc IS INITIAL.
    LOOP AT gt_bseg INTO ls_bseg.
      IF ls_bseg-augbl IS NOT INITIAL.
        lv_subrc  = 4.
        MESSAGE s308(f5) DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_subrc IS INITIAL.
    fc_reverse  = selected.
  ENDIF.
ENDFORM.                    " F_VALIDASI_REVERSE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_ISI_FORM
*&---------------------------------------------------------------------*
FORM f_isi_form USING fu_zidvc fu_title fu_bktxt
                      fu_total fu_zidno fu_znopol fu_prefix fu_vbund
                      fu_reference .
  DATA : lv_txt01(50),
         lv_txt02(50),
         in_words       TYPE spell,
         lv_langu       TYPE sy-langu VALUE 'id',
         lv_vendor(100),
         lv_zidvc(30),
         lv_waers       TYPE bkpf-waers,
         lv_budat(10).

  DATA : ls_mstp    LIKE LINE OF gt_mstp.

  IF fu_zidno IS INITIAL.
    READ TABLE gt_mstp INTO ls_mstp INDEX 1.
  ELSE.
    READ TABLE gt_mstp INTO ls_mstp WITH KEY lifnr = fu_zidno.
  ENDIF.

  gs_header-title   = fu_title.

  IF zfexpense-waers IS NOT INITIAL.
    lv_waers  = zfexpense-waers.
  ELSE.
    lv_waers  = 'IDR'.
  ENDIF.

  WRITE fu_total TO gs_header-totalt CURRENCY lv_waers.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = fu_total
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
  TRANSLATE gs_header-terbilang TO UPPER CASE.

  gs_header-bukrs  = pa_bukrs.

  PERFORM f_get_description USING 'T001' 'BUTXT' 'BUKRS' pa_bukrs
                            CHANGING gs_header-butxt.
  TRANSLATE gs_header-butxt TO UPPER CASE.
  PERFORM f_get_description USING 'TVKBT' 'BEZEI' 'VKBUR' pa_vkbur
                            CHANGING gs_header-bezei.
  TRANSLATE gs_header-bezei TO UPPER CASE.

  IF ls_mstp-lifnr IS INITIAL.
    lv_vendor = ls_mstp-name1.
  ELSE.
    CONCATENATE ls_mstp-lifnr '-' ls_mstp-name1 INTO lv_vendor
    SEPARATED BY space.
  ENDIF.

  CONCATENATE fu_prefix fu_zidvc INTO lv_zidvc.
  IF lv_zidvc IS INITIAL.
    lv_zidvc  = gv_zidvc2.
  ENDIF.

  PERFORM f_window3 USING : 'Vendor' ':' lv_vendor ''
                            'No.Voucher' ':' lv_zidvc.
  PERFORM f_window3 USING : 'No.Polisi' ':' fu_znopol ''
                            'Reference' ':' fu_reference.

  IF ls_mstp-wwsfr IS NOT INITIAL.
    PERFORM f_get_description USING 'T25A5' 'BEZEK' 'WWSFR' ls_mstp-wwsfr
                              CHANGING lv_txt01.
    CONCATENATE ls_mstp-wwsfr '-' lv_txt01 INTO lv_txt01
    SEPARATED BY space.
  ELSEIF ls_mstp-wwpos IS NOT INITIAL.
    PERFORM f_get_description USING 'T25A8' 'BEZEK' 'WWPOS' ls_mstp-wwpos
                              CHANGING lv_txt01.
    CONCATENATE ls_mstp-wwpos '-' lv_txt01 INTO lv_txt01
    SEPARATED BY space.
  ENDIF.

  IF fu_vbund IS INITIAL.
    IF ls_mstp-vbund IS INITIAL.
      lv_txt02 = ls_mstp-kostl.
    ELSE.
      CONCATENATE ls_mstp-kostl '/' ls_mstp-vbund INTO lv_txt02
      SEPARATED BY space.
    ENDIF.
  ELSE.
    CONCATENATE ls_mstp-kostl '/' fu_vbund INTO lv_txt02
    SEPARATED BY space.
  ENDIF.

  IF fu_reference IS INITIAL.
    PERFORM f_window3 USING : 'Doc.Header Text' ':' fu_bktxt ''
                              'Posting Date' ':' ''.
    PERFORM f_window3 USING : 'CostCtr/TrPart' ':' lv_txt02 ''
                              'SF/WD' ':' lv_txt01.
  ELSE.
    WRITE pa_budat TO lv_budat DD/MM/YYYY.
    PERFORM f_window3 USING : 'Doc.Header Text' ':' fu_bktxt ''
                              'Posting Date' ':' lv_budat.
  ENDIF.
ENDFORM.                    " F_ISI_FORM

*&---------------------------------------------------------------------*
*&      Form  F_WINDOW3
*&---------------------------------------------------------------------*
FORM f_window3  USING    fu_cell14 fu_cell15 fu_cell16 fu_cell17
                         fu_cell18 fu_cell19 fu_cell20.
  DATA : ls_window3   LIKE LINE OF gt_window3.

  ls_window3-cell14 = fu_cell14.
  ls_window3-cell15 = fu_cell15.
  ls_window3-cell16 = fu_cell16.
  ls_window3-cell17 = fu_cell17.
  ls_window3-cell18 = fu_cell18.
  ls_window3-cell19 = fu_cell19.
  ls_window3-cell20 = fu_cell20.
  APPEND ls_window3 TO gt_window3.
ENDFORM.                                                    " F_WINDOW3

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description  USING    fu_tabnm fu_fieldin fu_fieldco fu_value
                        CHANGING fc_text.

  DATA : dfies_tab       TYPE STANDARD TABLE OF dfies INITIAL SIZE 0,
         ls_dfies_tab    LIKE LINE OF dfies_tab,
         lv_value        TYPE string,
         condition(1000).

  FIELD-SYMBOLS <fs>    TYPE any.

  CLEAR : fc_text.

  IF fu_tabnm IS NOT INITIAL.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = fu_tabnm
      TABLES
        dfies_tab = dfies_tab
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    READ TABLE dfies_tab INTO ls_dfies_tab WITH KEY fieldname = 'SPRAS'
                                                    keyflag   = 'X'.
    IF sy-subrc = 0.
      ASSIGN sy-langu TO <fs>.
      CONCATENATE ''' '<fs>' ''' INTO lv_value.
      CONDENSE lv_value NO-GAPS.
      CONCATENATE 'spras =' lv_value INTO condition
      SEPARATED BY space.
      ASSIGN fu_value TO <fs>.
      CONCATENATE ''' '<fs>' ''' INTO lv_value.
      CONDENSE lv_value NO-GAPS.
      CONCATENATE condition
                  'AND'
                  fu_fieldco '=' lv_value
             INTO condition
      SEPARATED BY space.
    ELSE.
      ASSIGN fu_value TO <fs>.
      CONCATENATE ''' '<fs>' ''' INTO lv_value.
      CONDENSE lv_value NO-GAPS.
      CONCATENATE fu_fieldco '=' lv_value
             INTO condition
      SEPARATED BY space.
    ENDIF.

    SELECT SINGLE (fu_fieldin)
      FROM (fu_tabnm)
      INTO fc_text
      WHERE (condition).
  ENDIF.
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_EXPENSE
*&---------------------------------------------------------------------*
FORM f_delete_expense USING i_ucomm.
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : ls_head LIKE LINE OF gt_head,
         lt_head TYPE STANDARD TABLE OF ty_trnhdr INITIAL SIZE 0.
  DATA : ls_mstp    LIKE LINE OF gt_mstp,
         ls_ctrladv LIKE LINE OF gt_ctrladv,
         lv_advan   TYPE zf63ctrladv-advan.

  TRY.
      lr_selections = gr_hierseq->get_selections( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    lt_head[]  = gt_head[].
    LOOP AT lt_rows INTO i.
      READ TABLE lt_head INTO ls_head INDEX i.
      IF ls_head-zidvc IS INITIAL.
        CASE sy-tcode.
          WHEN 'ZF63B'.
            PERFORM f_delete_b USING ls_head i_ucomm.
          WHEN 'ZF63N'.
            PERFORM f_delete_n USING ls_head i_ucomm.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.
  gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).
ENDFORM.                    " F_DELETE_EXPENSE

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM1
*&---------------------------------------------------------------------*
FORM f_print_form1  USING    fu_proc fu_fname fu_zidvc fu_title
                    CHANGING fc_subrc.
  DATA : lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop,
         lv_formname        TYPE tdsfname,
         ls_detail          LIKE LINE OF gt_detail,
         lv_prefix1(3),
         lv_prefix2(3).

  DATA : ls_head       LIKE LINE OF gt_head,
         lt_detail     TYPE STANDARD TABLE OF zfexpstprnt INITIAL SIZE 0,
         lv_wrbtr      TYPE bseg-wrbtr,
         lv_zidvc      TYPE zf63trnhdr-zidvc,
         lv_kdvch      TYPE zf63nomor-kdvch,
         lt_header     TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         ls_header     LIKE LINE OF lt_header,
         lt_voucher    TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         ls_voucher    LIKE LINE OF lt_voucher,
         lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row.

  DATA : i             TYPE i.

  gr_hierseq->refresh( refresh_mode = if_salv_c_refresh=>full ).

  TRY.
      lr_selections = gr_hierseq->get_selections( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      CLEAR ls_head.
      TRANSLATE gv_nmvch TO UPPER CASE.
      SEARCH gv_nmvch FOR 'CASH'.
      IF sy-subrc = 0.
        lv_prefix1  = 'CPV'.
        lv_prefix2  = 'CRV'.
      ELSE.
        lv_prefix1  = 'BPV'.
        lv_prefix2  = 'BRV'.
      ENDIF.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = fu_fname
        IMPORTING
          fm_name            = lv_funcname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      lwa_output_option-tdnewid   = 'X'.
      CASE fu_proc.
        WHEN 'PREV'.
          lwa_output_option-tdnoprint = 'X'.
        WHEN 'PRNT'.
          lwa_output_option-tdnoprev = 'X'.
      ENDCASE.

      READ TABLE gt_head INTO ls_head INDEX i.
      IF sy-subrc = 0 AND
        ls_head-icon IS INITIAL.
        IF fu_proc = 'PRNT'.
          CLEAR : lt_header[], lt_header, ls_voucher.
          CASE sy-tcode.
            WHEN 'ZF63B'.
              PERFORM f_get_next_number USING 'ZIDVCH' pa_gsber sy-datum(4)
                                              '' '' ''
                                        CHANGING lv_zidvc lv_kdvch.
            WHEN 'ZF63N'.
              PERFORM f_get_next_number USING '' pa_gsber sy-datum(4)
                                              '' '' ''
                                        CHANGING lv_zidvc lv_kdvch.
          ENDCASE.
          ls_head-zidvc   = lv_zidvc.
          ls_head-icon    = icon_led_green.
          MODIFY gt_head FROM ls_head INDEX i TRANSPORTING icon zidvc.
          MOVE-CORRESPONDING ls_head TO ls_header.
          ls_header-gjahr       = sy-datum(4).
          APPEND ls_header TO lt_header.
          CLEAR : ls_header.

          ls_voucher-bukrs      = pa_bukrs.
          ls_voucher-gsber      = pa_gsber.
          ls_voucher-vkbur      = pa_vkbur.
          ls_voucher-gtype      = pa_gtype.
          ls_voucher-zidvc      = lv_zidvc.
          ls_voucher-vjahr      = sy-datum(4).
          ls_voucher-hkont      = zfexpense-hkont.
          ls_voucher-waers      = ls_head-waers.
          ls_voucher-wrbtr      = ls_head-wrbtr.
          ls_voucher-bktxt      = ls_head-bktxt.
          ls_voucher-adv_gjahr  = gv_gjahr.
          ls_voucher-adv_belnr  = gv_belnr.
          ls_voucher-ernam      = sy-uname.
          ls_voucher-erdat      = sy-datum.
          ls_voucher-erzet      = sy-uzeit.
          INSERT INTO zf63trnvch VALUES ls_voucher.

          MODIFY zf63trnhdr FROM TABLE lt_header.
        ENDIF.

        AT FIRST.
          lwa_control_option-no_close = 'X'.
        ENDAT.

        AT LAST.
          lwa_control_option-no_close = space.
        ENDAT.

        CLEAR : gt_window3[], gt_window3,
                lt_detail, lt_detail[], lv_wrbtr.

        LOOP AT gt_detail INTO ls_detail WHERE bukrs = ls_head-bukrs
                                           AND gsber = ls_head-gsber
                                           AND vkbur = ls_head-vkbur
                                           AND gtype = ls_head-gtype
                                           AND expnr = ls_head-expnr.
          WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_detail-waers.
          IF ls_detail-shkzg  = 'H'.
            CONDENSE ls_detail-wrbtrt NO-GAPS.
            CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt
            SEPARATED BY space.
          ENDIF.
          APPEND ls_detail TO lt_detail.
          CLEAR ls_detail.
        ENDLOOP.

        zfexpense-waers = ls_head-waers.

        PERFORM f_isi_form USING lv_zidvc fu_title
                                 ls_head-bktxt ls_head-wrbtr ls_head-zidno
                                 ls_head-znopol lv_prefix1 '' ''.

        IF lt_detail[] IS NOT INITIAL.
          CALL FUNCTION lv_funcname
            EXPORTING
              output_options     = lwa_output_option
              control_parameters = lwa_control_option
              user_settings      = 'X'
              gs_header          = gs_header
            TABLES
              gt_window3         = gt_window3
              gt_detail          = lt_detail
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
        ENDIF.

        lwa_control_option-no_open = 'X'.
      ENDIF.
    ENDLOOP.
  ELSE.
    fc_subrc = 4.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM1

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_ZIDVC
*&---------------------------------------------------------------------*
FORM f_value_zidvc USING fu_field.
  DATA : BEGIN OF lt_voucher OCCURS 0,
           zidvc TYPE zf63trnvch-zidvc,
           vjahr TYPE zf63trnvch-gjahr,
           bktxt TYPE zf63trnvch-bktxt,
         END OF lt_voucher.

  DATA : BEGIN OF lt_vouch2 OCCURS 0,
           zidvc     TYPE zf63trnhdr2-zidvc,
           gjahr     TYPE zf63trnhdr2-gjahr,
           bktxt     TYPE zf63trnhdr2-bktxt,
           belnrpadv TYPE zf63trnhdr2-belnrpadv,
         END OF lt_vouch2.

  DATA : BEGIN OF lt_vouch2x OCCURS 0,
           zidvc     TYPE zf63trnhdr2-zidvc,
           gjahr     TYPE zf63trnhdr2-gjahr,
           bktxt     TYPE zf63trnhdr2-bktxt,
           belnrpadv TYPE zf63trnhdr2-belnrpadv,
           adv_belnr TYPE zf63trnhdr2-adv_belnr,
         END OF lt_vouch2x.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_bukrs   TYPE zf63trnvch-bukrs,
         lv_vkbur   TYPE zf63trnvch-vkbur,
         lv_gsber   TYPE zf63trnvch-gsber,
         lv_gtype   TYPE zf63trnvch-gtype,
         lv_zidvc   TYPE zf63trnvch-zidvc,
         lv_zidvc2  TYPE zf63trnhdr2-zidvc,
         lv_subrc   TYPE sy-subrc,
         ls_voucher LIKE LINE OF lt_voucher,
         ls_vouch2  LIKE LINE OF lt_vouch2,
         ls_vouch2x LIKE LINE OF lt_vouch2x,
         lv_gjahr   TYPE zf63trnhdr-gjahr,
         lv_belnr   TYPE zf63trnhdr2-belnrpadv.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_VKBUR'
                            CHANGING lv_vkbur.
  lv_gsber = lv_vkbur.
  PERFORM f_dynp_value_read USING 'PA_GTYPE'
                            CHANGING lv_gtype.
  PERFORM f_dynp_value_read USING 'PA_VJAHR'
                            CHANGING lv_gjahr.

  CLEAR : lt_voucher[], lt_voucher,
          dynpfields[], dynpfields,
          lt_vouch2[], lt_vouch2.

  CASE sy-tcode.
    WHEN 'ZF63B'.
      IF radio7 IS NOT INITIAL.
        SELECT vjahr zidvc bktxt
          FROM zf63trnvch
          INTO CORRESPONDING FIELDS OF TABLE lt_voucher
          WHERE bukrs = lv_bukrs
            AND vkbur = lv_vkbur
            AND gsber = lv_gsber
            AND gtype = lv_gtype
            AND ( belnr <> space
             OR belnrpadv <> space )
            AND userrev = space.
      ELSE.
        SELECT vjahr zidvc bktxt
          FROM zf63trnvch
          INTO CORRESPONDING FIELDS OF TABLE lt_voucher
          WHERE bukrs = lv_bukrs
            AND vkbur = lv_vkbur
            AND gsber = lv_gsber
            AND gtype = lv_gtype
            AND belnr = space
            AND belnrpadv = space.
      ENDIF.
      ASSIGN lt_voucher[] TO <fs_tab>.

    WHEN 'ZF63N'.
      IF radio7 IS NOT INITIAL.
        SELECT zidvc gjahr bktxt
          FROM zf63trnhdr2
          INTO CORRESPONDING FIELDS OF TABLE lt_vouch2
          WHERE bukrs     = lv_bukrs
            AND vkbur     = lv_vkbur
            AND gsber     = lv_gsber
            AND gtype     = lv_gtype
            AND gjahr     = lv_gjahr
            AND ( belnrpadv <> space
             OR   belnrpexp <> space )
            AND userrev   = space.
      ELSEIF radio17 IS NOT INITIAL.
        SELECT zidvc gjahr bktxt belnrpadv
          FROM zf63trnhdr2
          INTO CORRESPONDING FIELDS OF TABLE lt_vouch2
          WHERE bukrs = lv_bukrs
            AND vkbur = lv_vkbur
            AND gsber = lv_gsber
            AND gtype = lv_gtype
            AND gjahr = lv_gjahr
            AND belnrpadv <> space
            AND userpost  <> space
            AND belnrpadvrev = space.
        IF lt_vouch2[] IS NOT INITIAL.
          SELECT zidvc gjahr bktxt belnrpadv adv_belnr
            FROM zf63trnhdr2
            INTO CORRESPONDING FIELDS OF TABLE lt_vouch2x
            FOR ALL ENTRIES IN lt_vouch2
            WHERE bukrs = lv_bukrs
              AND vkbur = lv_vkbur
              AND gsber = lv_gsber
              AND adv_gjahr = lt_vouch2-gjahr
              AND adv_belnr = lt_vouch2-belnrpadv.

          LOOP AT lt_vouch2 INTO ls_vouch2.
            CLEAR ls_vouch2x.
            READ TABLE lt_vouch2x INTO ls_vouch2x
                                  WITH KEY adv_belnr = ls_vouch2-belnrpadv.
            IF sy-subrc = 0.
              DELETE TABLE lt_vouch2 FROM ls_vouch2.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ELSE.
        SELECT zidvc gjahr bktxt
          FROM zf63trnhdr2
          INTO CORRESPONDING FIELDS OF TABLE lt_vouch2
          WHERE bukrs     = lv_bukrs
            AND vkbur     = lv_vkbur
            AND gsber     = lv_gsber
            AND gtype     = lv_gtype
            AND gjahr     = lv_gjahr
            AND belnrpadv = space
            AND belnrpexp = space.
      ENDIF.
      ASSIGN lt_vouch2[] TO <fs_tab>.
  ENDCASE.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDVC' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          lv_zidvc  = ls_return-fieldval.
          READ TABLE lt_voucher INTO ls_voucher WITH KEY zidvc = lv_zidvc.
          IF sy-subrc = 0.
            PERFORM f_dynpfield TABLES dynpfields
                                USING fu_field ls_voucher-zidvc ''.
          ENDIF.
        WHEN 'ZF63N'.
          lv_zidvc2  = ls_return-fieldval.
          READ TABLE lt_vouch2 INTO ls_vouch2 WITH KEY zidvc = lv_zidvc2.
          IF sy-subrc = 0.
            PERFORM f_dynpfield TABLES dynpfields
                                USING fu_field ls_vouch2-zidvc ''.
            PERFORM f_dynpfield TABLES dynpfields
                                USING 'PA_BELNR' ls_vouch2-belnrpadv ''.
          ENDIF.
      ENDCASE.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALUE_ZIDVC

*&---------------------------------------------------------------------*
*&      Form  F_AUTOMATIC_CLEARING
*&---------------------------------------------------------------------*
FORM f_automatic_clearing  USING    fu_lifnr.
  d_bdc_tctxt = 'Executing Transaction F.13'.
  d_bdc_batch = 'N'.

  CLEAR: t_bdcdata, t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPF124'          '1000',
    ' ' 'BDC_OKCODE'       '=ONLI',
    ' ' 'BUKRX-LOW'        pa_bukrs,
    ' ' 'X_LIFNR'          'X',
    ' ' 'X_SHBLF'          'X',
    ' ' 'SHBKK-LOW'        'C',
    ' ' 'KONTK-LOW'        fu_lifnr,
    ' ' 'AUGDT'            space,
    ' ' 'XAUGDT'           'X',
    ' ' 'X_TESTL'          space,
    ' ' 'XAUSBEL'          'X',
    ' ' 'XNAUSBEL'         'X',
    ' ' 'X_FEHLER'         'X'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPMSSY0'         '0120',
    ' ' 'BDC_OKCODE'       '=BACK'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPF124'          '1000',
    ' ' 'BDC_OKCODE'       '/EE'.

  PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                          t_bdcmsg
                                   USING  'F.13'
                                          d_bdc_tctxt.

  CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, d_bdc_error.
ENDFORM.                    " F_AUTOMATIC_CLEARING

*&---------------------------------------------------------------------*
*&      Form  F_Alv_LIST_REPRINT
*&---------------------------------------------------------------------*
FORM f_alv_list_reprint .
  DATA : lr_functions  TYPE REF TO cl_salv_functions,
         lr_display    TYPE REF TO cl_salv_display_settings,
         lr_events     TYPE REF TO cl_salv_events_table,
         lr_aggrs      TYPE REF TO cl_salv_aggregations,
         lr_selections TYPE REF TO cl_salv_selections.

  TRY.
      cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = gr_table
          CHANGING
            t_table        = gt_reprint ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_table->set_screen_status(
    pfstatus   = 'SALV_STANDARD2'
    report     = gv_repid ).


  IF gs_gtype-advance IS NOT INITIAL.
    PERFORM f_set_text USING : 'ADV_GJAHR' '' abap_false,
                               'ADV_BELNR' '' abap_false,
                               'ADV_WRBTR' '' abap_false.
  ENDIF.

  CASE sy-tcode.
    WHEN 'ZF63B'.
      PERFORM f_set_text USING : 'ZIDVC2' '' abap_false.
    WHEN 'ZF63N'.
      PERFORM f_set_text USING : 'ZIDVC' '' abap_false.
  ENDCASE.

  PERFORM f_set_text USING : 'VBUND' 'Tr.Part.' '',
                             'TEXT' 'Text' ''.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_selections->set_selection_mode( if_salv_c_selection_mode=>single ).

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.

  gr_table->display( ).
ENDFORM.                    " F_Alv_LIST_REPRINT

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_VOUCHER
*&---------------------------------------------------------------------*
FORM f_delete_voucher .
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : ls_reprint    LIKE LINE OF gt_reprint.
  DATA : lt_reprint    TYPE STANDARD TABLE OF ty_reprint INITIAL SIZE 0.
  DATA : lv_uname      TYPE sy-uname.
  DATA : ls_mstp    LIKE LINE OF gt_mstp,
         ls_ctrladv LIKE LINE OF gt_ctrladv,
         lv_advan   TYPE zf63ctrladv-advan.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  lt_reprint[]  = gt_reprint[].

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      READ TABLE lt_reprint INTO ls_reprint INDEX i.
      IF sy-subrc = 0.
        CASE sy-tcode.
          WHEN 'ZF63B'.
            DELETE FROM zf63trnvch WHERE bukrs = ls_reprint-bukrs
                                     AND gsber = ls_reprint-gsber
                                     AND vkbur = ls_reprint-vkbur
                                     AND gtype = ls_reprint-gtype
                                     AND zidvc = ls_reprint-zidvc.

            UPDATE zf63trnhdr SET zidvc = space
                              WHERE bukrs = ls_reprint-bukrs
                                AND gsber = ls_reprint-gsber
                                AND vkbur = ls_reprint-vkbur
                                AND gtype = ls_reprint-gtype
                                AND zidvc = ls_reprint-zidvc.

            DELETE gt_reprint WHERE bukrs = ls_reprint-bukrs
                                AND gsber = ls_reprint-gsber
                                AND vkbur = ls_reprint-vkbur
                                AND gtype = ls_reprint-gtype
                                AND zidvc = ls_reprint-zidvc.

          WHEN 'ZF63N'.
            UPDATE zf63kmhexph SET lvorm = 'X'
                             WHERE bukrs = ls_reprint-bukrs
                               AND vkbur = ls_reprint-vkbur
                               AND gsber = ls_reprint-gsber
                               AND zidvc = ls_reprint-zidvc2.

            DELETE FROM zf63trnhdr2 WHERE bukrs = ls_reprint-bukrs
                                      AND gsber = ls_reprint-gsber
                                      AND vkbur = ls_reprint-vkbur
                                      AND gtype = ls_reprint-gtype
                                      AND zidvc = ls_reprint-zidvc2.

            DELETE FROM zf63trndtl2 WHERE bukrs = ls_reprint-bukrs
                                      AND gsber = ls_reprint-gsber
                                      AND vkbur = ls_reprint-vkbur
                                      AND gtype = ls_reprint-gtype
                                      AND zidvc = ls_reprint-zidvc2.

            DELETE FROM zf63trnshp2 WHERE bukrs = ls_reprint-bukrs
                                      AND gsber = ls_reprint-gsber
                                      AND vkbur = ls_reprint-vkbur
                                      AND gtype = ls_reprint-gtype
                                      AND zidvc = ls_reprint-zidvc2.

            DELETE gt_reprint WHERE bukrs  = ls_reprint-bukrs
                                AND gsber  = ls_reprint-gsber
                                AND vkbur  = ls_reprint-vkbur
                                AND gtype  = ls_reprint-gtype
                                AND zidvc2 = ls_reprint-zidvc2.

            CLEAR ls_mstp.
            READ TABLE gt_mstp INTO ls_mstp
                               WITH KEY bukrs = ls_reprint-bukrs
                                        gsber = ls_reprint-gsber
                                        vkbur = ls_reprint-vkbur
                                        lifnr = ls_reprint-zidno.

            CLEAR ls_ctrladv.
            SELECT SINGLE *
              FROM zf63ctrladv
              INTO CORRESPONDING FIELDS OF ls_ctrladv
              WHERE bukrs   = ls_reprint-bukrs
                AND vkbur   = ls_reprint-vkbur
                AND gtype   = ls_reprint-gtype
                AND lifnr   = ls_reprint-zidno
                AND zidno   = ls_mstp-zidno.
*                AND gjahr   = ls_reprint-vjahr.

            IF sy-subrc = 0.
              lv_advan  = ls_ctrladv-advan - 1.
              UPDATE zf63ctrladv SET advan = lv_advan
                               WHERE bukrs = ls_reprint-bukrs
                                 AND vkbur = ls_reprint-vkbur
                                 AND gtype = ls_reprint-gtype
                                 AND lifnr = ls_reprint-zidno
                                 AND zidno = ls_mstp-zidno.
*                                 AND gjahr = ls_reprint-vjahr.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
ENDFORM.                    " F_DELETE_VOUCHER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_REPRINT_B
*&---------------------------------------------------------------------*
FORM f_prepare_reprint_b .
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : ls_reprint LIKE LINE OF gt_reprint,
         ls_header  LIKE LINE OF gt_header,
         ls_trnvch  LIKE LINE OF gt_trnvch,
         ls_mstp    LIKE LINE OF gt_mstp,
         ls_trnhdr  LIKE LINE OF gt_trnhdr.
  DATA : lv_nmvch      TYPE zf63acckasexp-nmvoucher,
         lv_prefix1(3),
         lv_prefix2(3).

  CLEAR : gt_header[], gt_header.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      READ TABLE gt_reprint INTO ls_reprint INDEX i.
      IF sy-subrc = 0.
        CLEAR ls_trnvch.
        READ TABLE gt_trnvch INTO ls_trnvch
                             WITH KEY bukrs = ls_reprint-bukrs
                                      gsber = ls_reprint-gsber
                                      vkbur = ls_reprint-vkbur
                                      gtype = ls_reprint-gtype
                                      zidvc = ls_reprint-zidvc.

        IF sy-subrc = 0.
          SELECT SINGLE nmvoucher
            FROM zf63acckasexp
            INTO lv_nmvch
            WHERE hkont = ls_trnvch-hkont.

          CLEAR ls_trnhdr.
          READ TABLE gt_trnhdr INTO ls_trnhdr
                               WITH KEY bukrs = ls_reprint-bukrs
                                        gsber = ls_reprint-gsber
                                        vkbur = ls_reprint-vkbur
                                        gtype = ls_reprint-gtype
                                        zidvc = ls_reprint-zidvc.
          IF sy-subrc = 0.
            CLEAR : ls_mstp.
            IF gs_gtype-advance IS INITIAL.
              READ TABLE gt_mstp INTO ls_mstp
                                 WITH KEY bukrs = ls_reprint-bukrs
                                          gsber = ls_reprint-gsber
                                          vkbur = ls_reprint-vkbur
                                          gtype = ls_reprint-gtype
                                          zidno = ls_trnhdr-zidno.
            ELSE.
              READ TABLE gt_mstp INTO ls_mstp
                                 WITH KEY bukrs = ls_reprint-bukrs
                                          gsber = ls_reprint-gsber
                                          vkbur = ls_reprint-vkbur
                                          lifnr = ls_trnhdr-zidno.
            ENDIF.
          ENDIF.

          TRANSLATE lv_nmvch TO UPPER CASE.
          SEARCH lv_nmvch FOR 'CASH'.
          IF sy-subrc = 0.
            lv_prefix1  = 'CPV'.
            lv_prefix2  = 'CRV'.
          ELSE.
            lv_prefix1  = 'BPV'.
            lv_prefix2  = 'BRV'.
          ENDIF.

          IF ls_reprint-adv_belnr IS INITIAL.
            PERFORM f_append_header USING 'ZFEXP_F001' 'Cash/Bank Payment Voucher'
                                           lv_prefix1 ls_trnvch-zidvc ls_trnhdr-znopol
                                           ls_mstp-lifnr ls_mstp-name1 ls_trnvch-bktxt
                                           ls_mstp-kostl ls_mstp-wwsfr ls_mstp-wwpos
                                           ls_reprint-wrbtr ls_trnvch-waers
                                           ls_trnvch-hkont ls_trnhdr-expnr '' ''
                                           ls_reprint-vbund ls_mstp-vbund ls_reprint-text.
          ELSE.
            PERFORM f_append_header USING 'ZFEXP_F001' 'Cash/Bank Payment Voucher'
                                           lv_prefix1 ls_trnvch-zidvc ls_trnhdr-znopol
                                           ls_mstp-lifnr ls_mstp-name1 ls_trnvch-bktxt
                                           ls_mstp-kostl ls_mstp-wwsfr ls_mstp-wwpos
                                           ls_reprint-wrbtr ls_trnvch-waers
                                           ls_trnvch-hkont ls_trnhdr-expnr '' ''
                                           ls_reprint-vbund ls_mstp-vbund ls_reprint-text.

            PERFORM f_append_header USING 'ZFEXP_F002' 'Cash/Bank Receipt Voucher'
                                           lv_prefix2 ls_trnvch-zidvc ls_trnhdr-znopol
                                           ls_mstp-lifnr ls_mstp-name1 ls_trnvch-bktxt
                                           ls_mstp-kostl ls_mstp-wwsfr ls_mstp-wwpos
                                           ls_reprint-adv_wrbtr ls_trnvch-waers
                                           ls_trnvch-hkont ls_trnhdr-expnr
                                           ls_reprint-adv_belnr ls_reprint-adv_gjahr
                                           ls_reprint-vbund ls_mstp-vbund ls_reprint-text.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
ENDFORM.                    " F_PREPARE_REPRINT_B

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT_VOUCHER
*&---------------------------------------------------------------------*
FORM f_reprint_voucher .
  DATA : lt_header          TYPE STANDARD TABLE OF zfexpstprnt
                             INITIAL SIZE 0,
         ls_header          LIKE LINE OF lt_header,
         ls_trnvch          LIKE LINE OF gt_trnvch,
         ls_trnhdr          LIKE LINE OF gt_trnhdr,
         ls_trndtl          LIKE LINE OF gt_trndtl,
         ls_detail          LIKE LINE OF gt_detail,
         ls_typeexp         LIKE LINE OF gt_typeexp,
         ls_accexp          LIKE LINE OF gt_accexp,
         ls_bsik            LIKE LINE OF gt_bsik,
         lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop,
         lt_detail          TYPE STANDARD TABLE OF zfexpstprnt
                             INITIAL SIZE 0,
         lv_langu           TYPE sy-langu VALUE 'id',
         in_words           TYPE spell,
         lv_flag,
         lv_text1(50).

  lt_header[] = gt_header[].
  SORT lt_header BY fname zidvc.
  DELETE ADJACENT DUPLICATES FROM lt_header COMPARING fname zidvc.

  LOOP AT lt_header INTO ls_header.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = ls_header-fname
      IMPORTING
        fm_name            = lv_funcname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    LOOP AT gt_header INTO gs_header WHERE fname = ls_header-fname
                                       AND zidvc = ls_header-zidvc.
      CLEAR : gt_window3[], gt_window3, lt_detail[], lt_detail.

      PERFORM f_get_description USING 'T001' 'BUTXT' 'BUKRS' pa_bukrs
                                CHANGING gs_header-butxt.
      TRANSLATE gs_header-butxt TO UPPER CASE.
      PERFORM f_get_description USING 'TVKBT' 'BEZEI' 'VKBUR' pa_vkbur
                                CHANGING gs_header-bezei.
      TRANSLATE gs_header-bezei TO UPPER CASE.

      PERFORM f_window3 USING : 'Vendor' ':' gs_header-cell15 ''
                                'No.Voucher' ':' gs_header-cell14.
      PERFORM f_window3 USING : 'No.Polisi' ':' gs_header-znopol ''
                                'Reference' ':' ''.
      PERFORM f_window3 USING : 'Doc.Header Text' ':' gs_header-bktxt ''
                                'Posting Date' ':' ''.

      IF gs_header-vbund IS INITIAL.
        lv_text1  = gs_header-kostl.
      ELSE.
        CONCATENATE gs_header-kostl '/' gs_header-vbund INTO lv_text1
        SEPARATED BY space.
      ENDIF.

      IF sy-tcode = 'ZF63B'.
        PERFORM f_window3 USING : 'CostCtr/TrPart' ':' lv_text1 ''
                                  'SF/WD' ':' gs_header-cell16.
      ENDIF.

      CALL FUNCTION 'SPELL_AMOUNT'
        EXPORTING
          amount    = gs_header-wrbtr
          currency  = gs_header-waers
          language  = lv_langu
        IMPORTING
          in_words  = in_words
        EXCEPTIONS
          not_found = 1
          too_large = 2
          OTHERS    = 3.

      CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
      TRANSLATE gs_header-terbilang TO UPPER CASE.

      CASE gs_header-fname.
        WHEN 'ZFEXP_F001'.
          CASE sy-tcode.
            WHEN 'ZF63B'.
              PERFORM f_reprint_voucher_b TABLES lt_detail.
            WHEN 'ZF63N'.
              PERFORM f_reprint_voucher_n TABLES lt_detail.
          ENDCASE.
        WHEN 'ZFEXP_F002'.
          CLEAR ls_bsik.
          READ TABLE gt_bsik INTO ls_bsik WITH KEY bukrs = gs_header-bukrs
                                                   belnr = gs_header-belnr
                                                   gjahr = gs_header-gjahr.
          IF sy-subrc = 0.
            CONCATENATE ls_bsik-sgtxt '-' ls_bsik-zuonr ',' ls_bsik-belnr
            INTO ls_detail-description
            SEPARATED BY space.
            ls_detail-hkont =  ls_bsik-hkont.
            WRITE ls_bsik-wrbtr TO ls_detail-wrbtrt CURRENCY ls_bsik-waers.
            APPEND ls_detail TO lt_detail.
          ENDIF.
          CLEAR ls_detail.
      ENDCASE.

      CALL FUNCTION lv_funcname
        EXPORTING
          output_options     = lwa_output_option
          control_parameters = lwa_control_option
          user_settings      = 'X'
          gs_header          = gs_header
        TABLES
          gt_window3         = gt_window3
          gt_detail          = lt_detail
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      lwa_control_option-no_open = 'X'.

      CLEAR gs_header.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_REPRINT_VOUCHER

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_HEADER
*&---------------------------------------------------------------------*
FORM f_append_header  USING    fu_fname fu_title fu_prefix fu_zidvc
                               fu_znopol fu_lifnr fu_name1 fu_bktxt
                               fu_kostl fu_wwsfr fu_wwpos fu_wrbtr
                               fu_waers fu_hkont fu_expnr fu_belnr
                               fu_gjahr fu_vbund fu_vbund1 fu_text.
  DATA : ls_header  LIKE LINE OF gt_header.

  ls_header-fname   = fu_fname.
  ls_header-bukrs   = pa_bukrs.
  ls_header-vkbur   = pa_vkbur.
  ls_header-gsber   = pa_gsber.
  ls_header-gtype   = pa_gtype.
  ls_header-zidvc   = fu_zidvc.
  ls_header-expnr   = fu_expnr.
  ls_header-title   = fu_title.
  ls_header-reprint = 'REPRINT'.
  CONCATENATE fu_prefix fu_zidvc INTO ls_header-cell14.
  ls_header-bktxt   = fu_bktxt.
  IF fu_lifnr IS INITIAL.
    ls_header-cell15 = fu_name1.
  ELSE.
    CONCATENATE fu_lifnr '-' fu_name1 INTO ls_header-cell15
    SEPARATED BY space.
  ENDIF.
  ls_header-znopol  = fu_znopol.
  ls_header-hkont   = fu_hkont.
  ls_header-kostl   = fu_kostl.
  ls_header-wrbtr   = fu_wrbtr.
  WRITE fu_wrbtr TO ls_header-wrbtrt CURRENCY fu_waers.
  ls_header-totalt  = ls_header-wrbtrt.

  IF fu_wwsfr IS NOT INITIAL.
    PERFORM f_get_description USING 'T25A5' 'BEZEK' 'WWSFR' fu_wwsfr
                              CHANGING ls_header-cell16.
    CONCATENATE fu_wwsfr '-' ls_header-cell16 INTO ls_header-cell16
    SEPARATED BY space.
  ELSEIF fu_wwpos IS NOT INITIAL.
    PERFORM f_get_description USING 'T25A8' 'BEZEK' 'WWPOS' fu_wwpos
                              CHANGING ls_header-cell16.
    CONCATENATE fu_wwpos '-' ls_header-cell16 INTO ls_header-cell16
    SEPARATED BY space.
  ENDIF.

  PERFORM f_get_description USING 'SKAT' 'TXT20' 'SAKNR' fu_hkont
                            CHANGING ls_header-txt20.

  ls_header-belnr   = fu_belnr.
  ls_header-gjahr   = fu_gjahr.

  IF fu_vbund IS NOT INITIAL.
    ls_header-vbund   = fu_vbund.
  ELSE.
    ls_header-vbund   = fu_vbund1.
  ENDIF.
  ls_header-text    = fu_text.

  APPEND ls_header TO gt_header.
  CLEAR ls_header.
ENDFORM.                    " F_APPEND_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_DAYS_CONVERSION
*&---------------------------------------------------------------------*
FORM f_days_conversion  USING    fu_menge fu_meins
                        CHANGING fc_day.
  DATA : lv_day1(20),
         lv_day2(20).

  WRITE fu_menge TO fc_day UNIT fu_meins.
  CONDENSE fc_day NO-GAPS.
  SPLIT fc_day AT ',' INTO lv_day1 lv_day2.
  CONDENSE lv_day1 NO-GAPS.
  TRANSLATE lv_day2 USING '0 '.
  CONDENSE lv_day2 NO-GAPS.
  IF lv_day2 IS NOT INITIAL.
    CONCATENATE lv_day1 ',' lv_day2 INTO fc_day.
  ELSE.
    fc_day  = lv_day1.
  ENDIF.
  CONCATENATE fc_day 'hari' INTO fc_day
  SEPARATED BY space.
ENDFORM.                    " F_DAYS_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DELIVERY
*&---------------------------------------------------------------------*
FORM f_print_delivery .
  DATA : lt_vttp     TYPE STANDARD TABLE OF vttp INITIAL SIZE 0.

  DATA : ls_headl   LIKE LINE OF gt_headl,
         ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_trndtl  LIKE LINE OF gt_trndtl,
         ls_trnshp  LIKE LINE OF gt_trnshp,
         ls_mstp    LIKE LINE OF gt_mstp,
         ls_typeexp LIKE LINE OF gt_typeexp.

  DATA : ls_biaya  TYPE ty_biaya,
         lr_typerm TYPE RANGE OF zf63typeexp-type,
         ls_typerm LIKE LINE OF lr_typerm,
         lr_typetl TYPE RANGE OF zf63typeexp-type,
         ls_typetl LIKE LINE OF lr_typetl.

  DATA : lv_value     TYPE vbap-netwr,
         lv_carton    TYPE vbap-kwmeng,
         lv_brgew     TYPE lips-brgew,
         lv_volum     TYPE lips-volum,
         lv_menge     TYPE zf63trndtl-menge,
         lv_bbm       TYPE zf63trndtl-wrbtr,
         lv_pddk      TYPE zf63trndtl-wrbtr,
         lv_pdlk      TYPE zf63trndtl-wrbtr,
         lv_kuli      TYPE zf63trndtl-wrbtr,
         lv_lodging   TYPE zf63trndtl-wrbtr,
         lv_parkir    TYPE zf63trndtl-wrbtr,
         lv_tol       TYPE zf63trndtl-wrbtr,
         lv_retribusi TYPE zf63trndtl-wrbtr,
         lv_rm        TYPE zf63trndtl-wrbtr,
         lv_tl        TYPE zf63trndtl-wrbtr,
         lv_total     TYPE zf63trndtl-wrbtr.

  DATA : lv_lines TYPE i,
         lv_count TYPE i.

  LOOP AT gt_typeexp INTO ls_typeexp.
    SEARCH ls_typeexp-description FOR 'REPAIR AND MAINTENANCE'.
    IF sy-subrc = 0.
      SEARCH ls_typeexp-description FOR 'FEE'.
      IF sy-subrc <> 0.
        ls_typerm-low     = ls_typeexp-type.
        ls_typerm-sign    = 'I'.
        ls_typerm-option  = 'EQ'.
        APPEND ls_typerm TO lr_typerm.
        CLEAR ls_typerm.
      ENDIF.
    ELSE.
      SEARCH ls_typeexp-description FOR 'TAX AND LICENSE - MOTOR VEHICLES LICENSE'.
      IF sy-subrc = 0.
        ls_typetl-low     = ls_typeexp-type.
        ls_typetl-sign    = 'I'.
        ls_typetl-option  = 'EQ'.
        APPEND ls_typetl TO lr_typetl.
        CLEAR ls_typerm.
      ENDIF.
    ENDIF.
  ENDLOOP.

  lt_vttp[] = gt_vttp[].
  SORT lt_vttp[] BY tknum vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING tknum vbeln.

  DESCRIBE TABLE gt_headl LINES lv_lines.

  IF lt_vttp[] IS NOT INITIAL.
    sy-title  = 'Delivery Report'.
    LOOP AT gt_headl INTO ls_headl.
      ADD 1 TO lv_count.
      PERFORM f_header_delivery USING ls_headl.
      LOOP AT gt_trnhdr INTO ls_trnhdr WHERE znopol = ls_headl-znopol.
        CLEAR ls_mstp.
        READ TABLE gt_mstp INTO ls_mstp WITH KEY zidno = ls_trnhdr-zidno.

        LOOP AT gt_trnshp INTO ls_trnshp WHERE bukrs = ls_trnhdr-bukrs
                                           AND gsber = ls_trnhdr-gsber
                                           AND vkbur = ls_trnhdr-vkbur
                                           AND gtype = ls_trnhdr-gtype
                                           AND expnr = ls_trnhdr-expnr.

          CLEAR : ls_biaya.
          LOOP AT gt_trndtl INTO ls_trndtl WHERE bukrs = ls_trnhdr-bukrs
                                             AND gsber = ls_trnhdr-gsber
                                             AND vkbur = ls_trnhdr-vkbur
                                             AND gtype = ls_trnhdr-gtype
                                             AND expnr = ls_trnhdr-expnr.
            SEARCH ls_trndtl-description FOR 'BENSIN'.
            IF sy-subrc = 0.
              ls_biaya-jarak  = ls_trndtl-kmend - ls_trndtl-kmstr.
              ls_biaya-bbm    = ls_trndtl-wrbtr.
              ls_biaya-menge  = ls_trndtl-menge.
              ls_biaya-meins  = ls_trndtl-meins.
            ELSE.
              SEARCH ls_trndtl-description FOR 'SOLAR'.
              IF sy-subrc = 0.
                ls_biaya-jarak  = ls_trndtl-kmend - ls_trndtl-kmstr.
                ls_biaya-bbm    = ls_trndtl-wrbtr.
                ls_biaya-menge  = ls_trndtl-menge.
                ls_biaya-meins  = ls_trndtl-meins.
              ENDIF.
            ENDIF.

            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'PDDK'
                                   CHANGING ls_biaya-pddk.
            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'PDLK'
                                   CHANGING ls_biaya-pdlk.

            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'KULI'
                                   CHANGING ls_biaya-kuli.
            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'LODGING'
                                   CHANGING ls_biaya-lodging.
            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'PARKIR'
                                   CHANGING ls_biaya-parkir.
            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'TOL'
                                   CHANGING ls_biaya-tol.
            PERFORM f_search_value USING ls_trndtl-description
                                         ls_trndtl-wrbtr 'RETRIBUSI'
                                   CHANGING ls_biaya-retribusi.

            IF ls_trndtl-type IN lr_typerm.
              ls_biaya-rm = ls_biaya-rm + ls_trndtl-wrbtr.
            ENDIF.
            IF ls_trndtl-type IN lr_typetl.
              ls_biaya-tl = ls_biaya-tl + ls_trndtl-wrbtr.
            ENDIF.
          ENDLOOP.

          ls_biaya-total  = ls_biaya-bbm + ls_biaya-pddk + ls_biaya-pdlk +
                            ls_biaya-kuli + ls_biaya-lodging + ls_biaya-parkir +
                            ls_biaya-tol + ls_biaya-retribusi + ls_biaya-rm +
                            ls_biaya-tl.

          PERFORM f_detail_delivery TABLES  lt_vttp
                                    USING   ls_trnshp ls_mstp-name1
                                            ls_biaya ls_trnhdr-expnr
                                    CHANGING lv_value lv_carton lv_brgew lv_volum.
        ENDLOOP.

        ADD ls_biaya-menge TO lv_menge.
        ADD ls_biaya-bbm TO lv_bbm.
        ADD ls_biaya-pddk TO lv_pddk.
        ADD ls_biaya-pdlk TO lv_pdlk.
        ADD ls_biaya-kuli TO lv_kuli.
        ADD ls_biaya-lodging TO lv_lodging.
        ADD ls_biaya-parkir TO lv_parkir.
        ADD ls_biaya-tol TO lv_tol.
        ADD ls_biaya-retribusi TO lv_retribusi.
        ADD ls_biaya-rm TO lv_rm.
        ADD ls_biaya-tl TO lv_tl.
        ADD ls_biaya-total TO lv_total.
      ENDLOOP.

      WRITE : / sy-uline(255).

      FORMAT COLOR COL_TOTAL.
      FORMAT INTENSIFIED ON.
      PERFORM f_write_text USING : 'Total' '70' 'X' '' '' '' '' '',
                                   lv_value '15' '' '' 'R' '' 'IDR' '',
                                   lv_carton '10' '' '' 'R' 'KAR' '' '',
                                   lv_brgew '10' '' '' 'R' 'KG' '' '',
                                   lv_volum '10' '' '' 'R' 'M3' '' '',
                                   '' '10' '' '' 'R' '' '' '',
                                   lv_menge '10' '' '' 'R' 'L' '' '',
                                   lv_bbm '10' '' '' 'R' '' 'IDR' '',
                                   lv_pddk '10' '' '' 'R' '' 'IDR' '',
                                   lv_pdlk '10' '' '' 'R' '' 'IDR' '',
                                   lv_lodging '10' '' '' 'R' '' 'IDR' '',
                                   lv_kuli '10' '' '' 'R' '' 'IDR' '',
                                   lv_parkir '10' '' '' 'R' '' 'IDR' '',
                                   lv_tol '10' '' '' 'R' '' 'IDR' '',
                                   lv_retribusi '10' '' '' 'R' '' 'IDR' '',
                                   lv_rm '10' '' '' 'R' '' 'IDR' '',
                                   lv_tl '15' '' '' 'R' '' 'IDR' '',
                                   lv_total '10' '' 'X' 'R' '' 'IDR' ''.
      FORMAT COLOR COL_BACKGROUND.

      PERFORM f_grand_total USING lv_value lv_carton lv_brgew lv_volum lv_menge lv_bbm
                                  lv_pddk lv_pdlk lv_lodging lv_kuli lv_parkir lv_tol
                                  lv_retribusi lv_rm lv_tl lv_total
                            CHANGING gs_gdelv.

      CLEAR : gv_zebra, lv_value, lv_carton, lv_brgew, lv_volum, lv_menge, lv_bbm,
              lv_pddk, lv_pdlk, lv_lodging, lv_kuli, lv_parkir, lv_tol, lv_retribusi,
              lv_rm, lv_tl, lv_total.

      WRITE : / sy-uline(255).

      IF lv_count < lv_lines.
        SKIP 1.
      ENDIF.
    ENDLOOP.

    FORMAT COLOR COL_GROUP.
    FORMAT INTENSIFIED ON.
    PERFORM f_write_text USING : 'Grand Total' '70' 'X' '' '' '' '' '',
                                 gs_gdelv-value '15' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-carton '10' '' '' 'R' 'KAR' '' '',
                                 gs_gdelv-brgew '10' '' '' 'R' 'KG' '' '',
                                 gs_gdelv-volum '10' '' '' 'R' 'M3' '' '',
                                 '' '10' '' '' 'R' '' '' '',
                                 gs_gdelv-menge '10' '' '' 'R' 'L' '' '',
                                 gs_gdelv-bbm '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-pddk '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-pdlk '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-lodging '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-kuli '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-parkir '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-tol '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-retribusi '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-rm '10' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-tl '15' '' '' 'R' '' 'IDR' '',
                                 gs_gdelv-total '10' '' 'X' 'R' '' 'IDR' ''.
    FORMAT COLOR COL_BACKGROUND.
    WRITE : / sy-uline.
  ENDIF.
ENDFORM.                    " F_PRINT_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_DELIVERY
*&---------------------------------------------------------------------*
FORM f_header_delivery  USING    fs_break1  LIKE LINE OF gt_headl.
  DATA : lv_datum(10),
         holidays     TYPE STANDARD TABLE OF iscal_day INITIAL SIZE 0,
         lv_lines     TYPE i.

  CONCATENATE so_budat-low+6(2) '.'
              so_budat-low+4(2) '.'
              so_budat-low(4) '.'
         INTO lv_datum.
  fs_break1-postingdate = lv_datum.
  IF so_budat-high IS NOT INITIAL.
    CONCATENATE so_budat-high+6(2) '.'
                so_budat-high+4(2) '.'
                so_budat-high(4)
           INTO lv_datum.
    CONCATENATE fs_break1-postingdate '-' lv_datum
    INTO fs_break1-postingdate
    SEPARATED BY space.

    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'T1'
        factory_calendar           = 'T1'
        date_from                  = so_budat-low
        date_to                    = so_budat-high
      TABLES
        holidays                   = holidays
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.

    DESCRIBE TABLE holidays LINES lv_lines.

    fs_break1-days = ( so_budat-high - so_budat-low ) - lv_lines + 1.
  ENDIF.

  FORMAT COLOR COL_BACKGROUND.
  FORMAT INTENSIFIED ON.

  WRITE : / 'No.Polisi      :', fs_break1-znopol,
          / 'Jenis Kendaraan :', fs_break1-description,
          / 'Posting Date    :', fs_break1-postingdate,
          / 'Hari Kerja      :', fs_break1-days, 'hari'.

  SKIP 1.
  FORMAT COLOR COL_HEADING.
  FORMAT INTENSIFIED ON.

  WRITE : / sy-uline(255).
  PERFORM f_write_text USING : '' '11' 'X' '' '' '' '' '',
                               '' '20' '' '' '' '' '' '',
                               'Data Shipment' '27' '' 'X' 'C' '' '' '',
                               '' '9' '' 'X' '' '' '' '',
                               '' '15' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' ''.
  PERFORM f_write_text USING : 'Data Biaya' '125' '' 'X' 'C' '' '' '',
                               '' '10' '' 'X' 'C' '' '' ''.

  PERFORM f_write_text USING : 'Tgl Actual' '11' 'X' '' '' '' '' '',
                               'Pemakai' '20' '' '' '' '' '' ''.
  PERFORM f_write_line USING : '34' '29'.
  PERFORM f_write_text USING : 'DP sukses' '9' '' 'X' 'C' '' '' '',
                               'Value' '15' '' 'X' 'C' '' '' '',
                               'Crt' '10' '' 'X' 'C' '' '' '',
                               'KG' '10' '' 'X' 'C' '' '' '',
                               'M3' '10' '' 'X' 'C' '' '' '',
                               'Jarak' '10' '' 'X' 'C' '' '' ''.
  PERFORM f_write_line USING : '133' '127'.
  PERFORM f_write_text USING : 'Total' '10' '' 'X' 'C' '' '' ''.

  PERFORM f_write_text USING : 'Pengiriman' '11' 'X' '' '' '' '' '',
                               '' '20' '' '' '' '' '' '',
                               'No.Shipment' '11' '' '' '' '' '' '',
                               'DN' '7' '' '' 'C' '' '' '',
                               'DP' '7' '' '' 'C' '' '' '',
                               'dikirim' '9' '' 'X' 'C' '' '' '',
                               '' '15' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               '' '10' '' 'X' '' '' '' '',
                               'Tempuh' '10' '' 'X' 'C' '' '' '',
                               'BBM(liter)' '10' '' 'X' 'C' '' '' '',
                               'BBM' '10' '' 'X' 'C' '' '' ''.
  PERFORM f_write_text USING : 'PDDK' '10' '' 'X' 'C' '' '' '',
                               'PDLK' '10' '' 'X' 'C' '' '' '',
                               'Lodging' '10' '' 'X' 'C' '' '' ''.
  PERFORM f_write_text USING : 'Kuli' '10' '' 'X' 'C' '' '' '',
                               'Parkir' '10' '' 'X' 'C' '' '' '',
                               'Tol' '10' '' 'X' 'C' '' '' '',
                               'Retribusi' '10' '' 'X' 'C' '' '' '',
                               'R-M' '10' '' 'X' 'C' '' '' '',
                               'Tax-Licenses' '15' '' 'X' 'C' '' '' '',
                               '' '10' '' 'X' 'C' '' '' ''.
  WRITE : / sy-uline(255).
  CLEAR gv_zebra.
ENDFORM.                    " F_HEADER_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_CEK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_cek_authorization  USING    fu_actvt.

  IF pa_bukrs IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD pa_bukrs
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      MESSAGE e002(zz) WITH
      'You have no authorization for Company Code' pa_bukrs.
    ENDIF.
  ENDIF.

  IF pa_vkbur IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
        ID 'VKBUR' FIELD pa_vkbur
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      MESSAGE e002(zz) WITH
      'You have no authorization for Sales Office' pa_vkbur.
    ENDIF.
  ENDIF.

  IF pa_gsber IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
        ID 'GSBER' FIELD pa_gsber
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      MESSAGE e002(zz) WITH
      'You have no authorization for Business Area' pa_gsber.
    ENDIF.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZEXP01'
            ID 'ACTVT' FIELD fu_actvt.
  IF sy-subrc <> 0.
    PERFORM f_error_message USING '' 'You are not authorized'.
  ENDIF.
ENDFORM.                    " F_CEK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_TEXT
*&---------------------------------------------------------------------*
FORM f_write_text  USING    fu_value fu_length fu_newline
                            fu_endline fu_allignment fu_meins fu_waers
                            fu_condense.
  DATA : lv_text(132).

  IF fu_meins IS NOT INITIAL.
    WRITE fu_value TO lv_text UNIT fu_meins.
  ELSEIF fu_waers IS NOT INITIAL.
    WRITE fu_value TO lv_text CURRENCY fu_waers.
  ELSE.
    lv_text = fu_value.
    IF fu_condense IS NOT INITIAL.
      CONDENSE lv_text NO-GAPS.
    ENDIF.
  ENDIF.

  IF fu_newline IS NOT INITIAL.
    c = 1.
    WRITE : / sy-vline. c = c + 1.
    CASE fu_allignment.
      WHEN 'C'.
        WRITE AT c(fu_length) lv_text CENTERED.
      WHEN 'R'.
        WRITE AT c(fu_length) lv_text RIGHT-JUSTIFIED.
      WHEN OTHERS.
        WRITE AT c(fu_length) lv_text.
    ENDCASE.
  ELSE.
    WRITE AT c(1) sy-vline. c = c + 1.
    CASE fu_allignment.
      WHEN 'C'.
        WRITE AT c(fu_length) lv_text CENTERED.
      WHEN 'R'.
        WRITE AT c(fu_length) lv_text RIGHT-JUSTIFIED.
      WHEN OTHERS.
        WRITE AT c(fu_length) lv_text.
    ENDCASE.
  ENDIF.
  c = c + fu_length.
  IF fu_endline IS NOT INITIAL.
    WRITE AT c(1) sy-vline.
  ENDIF.
ENDFORM.                    " F_WRITE_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LINE
*&---------------------------------------------------------------------*
FORM f_write_line  USING    fu_left fu_witdh.
  WRITE AT fu_left sy-uline(fu_witdh).
  c = c + fu_witdh - 1.
ENDFORM.                    " F_WRITE_LINE

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_DELIVERY
*&---------------------------------------------------------------------*
FORM f_detail_delivery  TABLES   ft_vttp    STRUCTURE vttp
                        USING    fs_trnshp  LIKE LINE OF gt_trnshp
                                 fu_name1
                                 fs_biaya   TYPE ty_biaya
                                 fu_expnr
                        CHANGING fc_value fc_carton fc_brgew fc_volum.

  DATA : ls_vttp           LIKE LINE OF gt_vttp,
         lv_cntdn          TYPE p DECIMALS 0,
         lv_cntdpall       TYPE p DECIMALS 0,
         lv_cntdp          TYPE p DECIMALS 0,
         lv_value          TYPE vbap-netwr,
         lv_totaldn        TYPE vbap-netwr,
         lv_carton         TYPE vbap-kwmeng,
         lv_brgew          TYPE lips-brgew,
         lv_volum          TYPE lips-volum,
         lv_jarak          TYPE p,
         ls_biaya          TYPE ty_biaya,
         lv_menget(18),
         lv_bbmt(18),
         lv_pddkt(18),
         lv_pdlkt(18),
         lv_kulit(18),
         lv_lodgingt(18),
         lv_parkirt(18),
         lv_tolt(18),
         lv_retribusit(18),
         lv_rmt(18),
         lv_tlt(18),
         lv_totalt(18).

  DATA : lt_dpall     TYPE STANDARD TABLE OF ty_dp INITIAL SIZE 0,
         lt_dp        TYPE STANDARD TABLE OF ty_dp INITIAL SIZE 0,
         ls_dp        LIKE LINE OF lt_dp,
         ls_likp      LIKE LINE OF gt_likp,
         ls_zmshphist LIKE LINE OF gt_zmshphist,
         ls_lips      LIKE LINE OF gt_lips,
         ls_vbap      LIKE LINE OF gt_vbap,
         ls_005       LIKE LINE OF gt_005.

  IF gv_zebra IS INITIAL.
    FORMAT COLOR COL_NORMAL.
    FORMAT INTENSIFIED OFF.
    gv_zebra = selected.
  ELSE.
    FORMAT INTENSIFIED ON.
    CLEAR gv_zebra.
  ENDIF.

  lv_jarak  = fs_biaya-jarak.
  PERFORM f_write_text USING : fs_trnshp-erdat '11' 'X' '' '' '' '' '',
                               fu_name1 '20' '' '' '' '' '' '',
                               fs_trnshp-tknum '11' '' '' '' '' '' ''.
  CLEAR : lv_cntdn.
  LOOP AT ft_vttp INTO ls_vttp WHERE tknum = fs_trnshp-tknum.
    ADD 1 TO lv_cntdn.

    ls_dp-vbeln   = ls_vttp-vbeln.
    READ TABLE gt_likp INTO ls_likp WITH KEY vbeln = ls_vttp-vbeln.
    IF sy-subrc = 0.
      ls_dp-kunnr   = ls_likp-kunnr.
      APPEND ls_dp TO lt_dp.
      CLEAR ls_dp.
    ENDIF.

    CLEAR ls_lips.
    LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_vttp-vbeln.
      IF ls_lips-uecha IS INITIAL.
        CLEAR ls_vbap.
        LOOP AT gt_vbap INTO ls_vbap WHERE vbeln = ls_lips-vgbel
                                       AND posnr = ls_lips-vgpos.
          lv_value  = lv_value + ls_vbap-netwr + ls_vbap-mwsbp.
        ENDLOOP.

        CLEAR ls_005.
        READ TABLE gt_005 INTO ls_005 WITH KEY matnr = ls_lips-matnr
                                               meins = ls_lips-meins.
        IF sy-subrc = 0.
          IF ls_lips-lfimg IS NOT INITIAL.
            PERFORM f_unit_conversion USING ls_lips-lfimg
                                            ls_005-umrez
                                            '' '' '' '' '1'
                                      CHANGING lv_carton.
          ELSEIF ls_lips-kcmeng IS NOT INITIAL.
            PERFORM f_unit_conversion USING ls_lips-kcmeng
                                            ls_005-umrez
                                            '' '' '' '' '1'
                                      CHANGING lv_carton.
          ENDIF.
        ENDIF.

        IF ls_lips-brgew IS NOT INITIAL.
          PERFORM f_unit_conversion USING '' ''
                                          ls_lips-brgew ls_lips-gewei 'KG'
                                          '' '2'
                                    CHANGING lv_brgew.
        ELSEIF ls_lips-kcbrgew IS NOT INITIAL.
          PERFORM f_unit_conversion USING '' ''
                                          ls_lips-kcbrgew ls_lips-kcgewei 'KG'
                                          '' '2'
                                    CHANGING lv_brgew.
        ENDIF.

        IF ls_lips-volum IS NOT INITIAL.
          PERFORM f_unit_conversion USING '' ''
                                          '' ls_lips-voleh 'M3'
                                          ls_lips-volum  '3'
                                    CHANGING lv_volum.
        ELSEIF ls_lips-kcvolum IS NOT INITIAL.
          PERFORM f_unit_conversion USING '' ''
                                          '' ls_lips-kcvoleh 'M3'
                                          ls_lips-kcvolum  '3'
                                    CHANGING lv_volum.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_zmshphist INTO ls_zmshphist WHERE tknum = fs_trnshp-tknum.
    ls_dp-vbeln   = ls_zmshphist-vbeln.
    READ TABLE gt_likp INTO ls_likp WITH KEY vbeln = ls_zmshphist-vbeln.
    IF sy-subrc = 0.
      ls_dp-kunnr   = ls_likp-kunnr.
*      APPEND ls_dp TO lt_dpall.
      CASE ls_zmshphist-zreason.
        WHEN '51' OR '52' OR '53' OR '58'.
          APPEND ls_dp TO lt_dpall.
      ENDCASE.
      CLEAR ls_dp.
    ENDIF.
  ENDLOOP.

  SORT lt_dp BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_dp COMPARING kunnr.
  DESCRIBE TABLE lt_dp LINES lv_cntdp.
  SORT lt_dpall BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_dpall COMPARING kunnr.
  DESCRIBE TABLE lt_dpall LINES lv_cntdpall.

  PERFORM f_prorate_calc USING lv_value lv_jarak fu_expnr
                               '' ''
                         CHANGING ls_biaya-jarak.
  PERFORM f_prorate_calc USING lv_value fs_biaya-menge fu_expnr
                               fs_biaya-meins ''
                         CHANGING lv_menget.
  PERFORM f_prorate_calc USING lv_value fs_biaya-bbm fu_expnr
                               '' 'IDR'
                         CHANGING lv_bbmt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-pddk fu_expnr
                               '' 'IDR'
                         CHANGING lv_pddkt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-pdlk fu_expnr
                               '' 'IDR'
                         CHANGING lv_pdlkt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-kuli fu_expnr
                               '' 'IDR'
                         CHANGING lv_kulit.
  PERFORM f_prorate_calc USING lv_value fs_biaya-parkir fu_expnr
                               '' 'IDR'
                         CHANGING lv_parkirt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-lodging fu_expnr
                               '' 'IDR'
                         CHANGING lv_lodgingt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-tol fu_expnr
                               '' 'IDR'
                         CHANGING lv_tolt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-retribusi fu_expnr
                               '' 'IDR'
                         CHANGING lv_retribusit.
  PERFORM f_prorate_calc USING lv_value fs_biaya-rm fu_expnr
                               '' 'IDR'
                         CHANGING lv_rmt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-tl fu_expnr
                               '' 'IDR'
                         CHANGING lv_tlt.
  PERFORM f_prorate_calc USING lv_value fs_biaya-total fu_expnr
                               '' 'IDR'
                         CHANGING lv_totalt.

  ADD lv_value TO fc_value.
  ADD lv_carton TO fc_carton.
  ADD lv_brgew TO fc_brgew.
  ADD lv_volum TO fc_volum.

  PERFORM f_write_text USING : lv_cntdn '7' '' '' 'R' '' '' 'X',
                               lv_cntdp '7' '' '' 'R' '' '' 'X',
                               lv_cntdpall '9' '' '' 'R' '' '' 'X',
                               lv_value '15' '' '' 'R' '' 'IDR' '',
                               lv_carton '10' '' '' 'R' 'KAR' '' '',
                               lv_brgew '10' '' '' 'R' 'KG' '' '',
                               lv_volum '10' '' 'X' 'R' 'M3' '' '',
                               ls_biaya-jarak '10' '' 'X' 'R' '' '' '',
                               lv_menget '10' '' 'X' 'R' '' '' '',
                               lv_bbmt '10' '' 'X' 'R' '' '' '',
                               lv_pddkt '10' '' 'X' 'R' '' '' '',
                               lv_pdlkt '10' '' 'X' 'R' '' '' ''.
  PERFORM f_write_text USING : lv_lodgingt '10' '' 'X' 'R' '' '' ''.
  PERFORM f_write_text USING : lv_kulit '10' '' 'X' 'R' '' '' '',
                               lv_parkirt '10' '' 'X' 'R' '' '' '',
                               lv_tolt '10' '' 'X' 'R' '' '' '',
                               lv_retribusit '10' '' 'X' 'R' '' '' '',
                               lv_rmt '10' '' 'X' 'R' '' '' '',
                               lv_tlt '15' '' 'X' 'R' '' '' '',
                               lv_totalt '10' '' 'X' 'R' '' '' ''.
ENDFORM.                    " F_DETAIL_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_lfimg fu_umrez
                                 fu_brgew fu_in fu_out
                                 fu_volum fu_proc
                        CHANGING fc_output.
  DATA : lv_lfimg TYPE lips-lfimg,
         lv_brgew TYPE lips-brgew,
         lv_volum TYPE lips-volum.

  CASE fu_proc.
    WHEN 1.
      lv_lfimg  = fu_lfimg / fu_umrez.
      fc_output = fc_output + lv_lfimg.
    WHEN 2.
      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input                = fu_brgew
          unit_in              = fu_in
          unit_out             = fu_out
        IMPORTING
          output               = lv_brgew
        EXCEPTIONS
          conversion_not_found = 1
          division_by_zero     = 2
          input_invalid        = 3
          output_invalid       = 4
          overflow             = 5
          type_invalid         = 6
          units_missing        = 7
          unit_in_not_found    = 8
          unit_out_not_found   = 9
          OTHERS               = 10.

      fc_output = fc_output + lv_brgew.

    WHEN 3.
      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input                = fu_volum
          unit_in              = fu_in
          unit_out             = fu_out
        IMPORTING
          output               = lv_volum
        EXCEPTIONS
          conversion_not_found = 1
          division_by_zero     = 2
          input_invalid        = 3
          output_invalid       = 4
          overflow             = 5
          type_invalid         = 6
          units_missing        = 7
          unit_in_not_found    = 8
          unit_out_not_found   = 9
          OTHERS               = 10.

      fc_output = fc_output + lv_volum.
  ENDCASE.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_MASTER_CHECK
*&---------------------------------------------------------------------*
FORM f_master_check  USING    fu_tabnm fu_field fu_value
                     CHANGING fc_subrc.
  DATA : condition(1000),
         lv_value       TYPE string.
  DATA : dfies_tab TYPE STANDARD TABLE OF dfies,
         ls_dfies  LIKE dfies.
  DATA : lt_dyn_fcat  TYPE lvc_t_fcat,
         ls_dyn_fcat  TYPE lvc_s_fcat,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data.

  DATA : lv_ctype    TYPE zf63ctrltype-type_ctrl,
         lv_field    TYPE string,
         lv_operator TYPE string,
         lv_tabname  TYPE string.

  FIELD-SYMBOLS : <fs_itab> TYPE STANDARD TABLE,
                  <fs_wa>   TYPE any,
                  <fs>      TYPE any.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = fu_tabnm
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  LOOP AT dfies_tab INTO ls_dfies.
    MOVE-CORRESPONDING ls_dfies TO ls_dyn_fcat.
    APPEND ls_dyn_fcat TO lt_dyn_fcat.
    CLEAR ls_dyn_fcat.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = lt_dyn_fcat
* Begin remark unicode coversion - DEVK966065
* 18.03.2020 - sol chirka
      i_length_in_byte          = 'X'
* End insert Unicode conversion - DEVK966065
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_itab>.
    CREATE DATA ls_line LIKE LINE OF <fs_itab>.
    ASSIGN ls_line->* TO <fs_wa>.
  ENDIF.

  ASSIGN fu_value TO <fs>.
  CONCATENATE ''' '<fs>' ''' INTO lv_value.
  CONDENSE lv_value NO-GAPS.
  IF fu_value = 'AR POTONGAN'.
    CONCATENATE lv_value(3) lv_value+3(9) INTO lv_value
    SEPARATED BY space.
  ENDIF.
  CONCATENATE fu_field '=' lv_value
         INTO condition
  SEPARATED BY space.

  lv_tabname  = fu_tabnm.

  IF radio4 IS NOT INITIAL.
    IF fu_tabnm = 'ZF63GTYPE'.
      lv_tabname  = 'ZF63CTRLTYPE'.
      PERFORM f_dynp_value_read USING 'PA_CTYPE'
                                CHANGING lv_ctype.
      lv_field    = 'TYPE_CTRL'.
      lv_operator = 'AND'.
      ASSIGN lv_ctype TO <fs>.
      CONCATENATE ''' '<fs>' ''' INTO lv_value.
      CONDENSE lv_value NO-GAPS.
      IF lv_ctype = 'AR POTONGAN'.
        CONCATENATE lv_value(3) lv_value+3(9) INTO lv_value
        SEPARATED BY space.
      ENDIF.

      CONCATENATE lv_field '=' lv_value lv_operator condition
      INTO condition
      SEPARATED BY space.
*      PERFORM f_checkbox_checking CHANGING condition.
    ENDIF.
  ENDIF.

  IF <fs_wa> IS ASSIGNED.
    SELECT SINGLE *
      FROM (lv_tabname)
      INTO CORRESPONDING FIELDS OF <fs_wa>
      WHERE (condition).
  ENDIF.

  fc_subrc = sy-subrc.
ENDFORM.                    " F_MASTER_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_SEARCH_VALUE
*&---------------------------------------------------------------------*
FORM f_search_value  USING    fu_description fu_wrbtr fu_value
                     CHANGING fc_value.
  SEARCH fu_description FOR fu_value.
  IF sy-subrc = 0.
    fc_value  = fu_wrbtr.
  ENDIF.
ENDFORM.                    " F_SEARCH_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_PRORATE_CALC
*&---------------------------------------------------------------------*
FORM f_prorate_calc  USING    fu_value fu_valuex fu_expnr
                              fu_meins fu_waers
                     CHANGING fc_value.

  DATA : ls_total LIKE LINE OF gt_total,
         lv_menge TYPE vbap-kwmeng,
         lv_wrbtr TYPE vbap-netwr.

  READ TABLE gt_total INTO ls_total WITH KEY expnr = fu_expnr.
  IF sy-subrc = 0.
    IF fu_meins IS NOT INITIAL.
      lv_menge = ( fu_value / ls_total-netwr ) * fu_valuex.
      WRITE lv_menge TO fc_value UNIT fu_meins.
    ELSEIF fu_waers IS NOT INITIAL.
      lv_wrbtr = ( fu_value / ls_total-netwr ) * fu_valuex.
      WRITE lv_wrbtr TO fc_value CURRENCY fu_waers.
    ELSE.
      fc_value = ( fu_value / ls_total-netwr ) * fu_valuex.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRORATE_CALC

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_KENDARAAN
*&---------------------------------------------------------------------*
FORM f_print_kendaraan .
  DATA : lt_k001    TYPE STANDARD TABLE OF ty_k001 INITIAL SIZE 0.
  DATA : ls_gtype LIKE LINE OF gt_gtype,
         ls_k001  LIKE LINE OF gt_k001,
         ls_k001t LIKE LINE OF gt_k001,
         ls_k001g LIKE LINE OF gt_k001.

  DATA : lv_subrc TYPE sy-subrc,
         lv_lcurr TYPE i VALUE 15.

  DATA : lv_01 TYPE zf63trndtl-wrbtr,
         lv_02 TYPE zf63trndtl-wrbtr,
         lv_03 TYPE zf63trndtl-wrbtr.

  SORT gt_k001 BY gtype kostl wwsfr wwpos znopol.
  lt_k001[] = gt_k001[].
  SORT lt_k001 BY gtype kostl znopol.
  DELETE ADJACENT DUPLICATES FROM lt_k001 COMPARING gtype kostl znopol.

  SORT lt_k001 BY gtype kostl wwsfr wwpos znopol.

  LOOP AT gt_gtype INTO ls_gtype.
    IF ls_gtype-advance IS INITIAL.
      READ TABLE lt_k001 INTO ls_k001
                         WITH KEY gtype = ls_gtype-gtype
                         TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CLEAR : lv_subrc, lv_01, lv_02, lv_03.
        LOOP AT gt_k001 INTO ls_k001 WHERE gtype  = ls_gtype-gtype.
          lv_01 = lv_01 + ls_k001-bensin + ls_k001-solar.
          lv_02 = lv_02 + ls_k001-ogrp + ls_k001-otrp +
                          ls_k001-gbrp +  ls_k001-akirp + ls_k001-tbrp +
                          ls_k001-gmrp +  ls_k001-sprp + ls_k001-sbrp +
                          ls_k001-skrp.
          lv_03 = lv_03 + ls_k001-stnk + ls_k001-gprp +
                          ls_k001-bpkb + ls_k001-kir.
        ENDLOOP.
        IF lv_01 IS INITIAL AND
           lv_02 IS INITIAL AND
           lv_03 IS INITIAL.
          lv_subrc = 4.
        ENDIF.

        IF lv_subrc IS INITIAL.
          PERFORM f_header_kendaraan USING ls_gtype-description.
          LOOP AT lt_k001 INTO ls_k001 WHERE gtype  = ls_gtype-gtype.
            LOOP AT gt_k001 INTO ls_k001 WHERE gtype  = ls_k001-gtype
                                           AND znopol = ls_k001-znopol
                                           AND kostl  = ls_k001-kostl.
              IF gv_zebra IS INITIAL.
                FORMAT COLOR COL_NORMAL.
                FORMAT INTENSIFIED OFF.
                gv_zebra = selected.
              ELSE.
                FORMAT COLOR COL_NORMAL.
                FORMAT INTENSIFIED ON.
                CLEAR gv_zebra.
              ENDIF.

              TRY .
                  ls_k001-ratio = ls_k001-jarak / ls_k001-liter.
                CATCH cx_sy_zerodivide.
              ENDTRY.

              ls_k001-t0001 = ls_k001-bensin + ls_k001-solar.
              ls_k001-t0002 = ls_k001-ogrp + ls_k001-otrp + ls_k001-gbrp +
                              ls_k001-akirp + ls_k001-tbrp + ls_k001-gmrp +
                              ls_k001-sprp + ls_k001-sbrp + ls_k001-skrp.
              ls_k001-t0003 = ls_k001-stnk + ls_k001-gprp + ls_k001-bpkb +
                              ls_k001-kir.
              ls_k001-grand = ls_k001-t0001 + ls_k001-t0002 + ls_k001-t0003 +
                              ls_k001-rmfee.

              IF ls_k001-t0001 IS INITIAL AND
                 ls_k001-t0002 IS INITIAL AND
                 ls_k001-t0003 IS INITIAL.
                CONTINUE.
              ENDIF.

              PERFORM f_write_text USING : ls_k001-znopol '12' 'X' '' '' '' '' '',
                                           ls_k001-name1 '15' '' '' '' '' '' '',
                                           ls_k001-jabat '15' '' '' '' '' '' '',
                                           ls_k001-kostl '10' '' '' '' '' '' '',
                                           ls_k001-wwsfr '8' '' '' '' '' '' '',
                                           ls_k001-wwpos '8' '' '' '' '' '' '',
                                           ls_k001-jnskend '12' '' '' '' '' '' '',
                                           ls_k001-zujhr '6' '' '' '' '' '' '',
                                           ls_k001-jarak '6' '' '' 'R' '' '' '',
                                           ls_k001-liter '6' '' '' 'R' 'LT' '' '',
                                           ls_k001-ratio '8' '' '' 'R' '' '' '',
                                           ls_k001-bensin lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-solar lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-t0001 lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-ogkm '6' '' '' 'R' 'KM' '' '',
                                           ls_k001-ogrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-otkm '6' '' '' 'R' 'KM' '' '',
                                           ls_k001-otrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-gbkm '6' '' '' 'R' '' '' '',
                                           ls_k001-gbqt '6' '' '' 'R' 'PC' '' '',
                                           ls_k001-gbrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-akikm '6' '' '' 'R' '' '' '',
                                           ls_k001-akirp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-tbrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-gmrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-sprp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-sbrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-skrp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-t0002 lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-rmfee lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-stnk lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-kir lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-gprp lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-bpkb lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-t0003 lv_lcurr '' '' 'R' '' ls_k001-waers '',
                                           ls_k001-grand lv_lcurr '' 'X' 'R' '' ls_k001-waers ''.

              PERFORM f_subtotal1 USING ls_k001
                                  CHANGING ls_k001t.
            ENDLOOP.

            IF  ls_k001t-t0001 IS INITIAL AND
                ls_k001t-t0002 IS INITIAL AND
                ls_k001t-t0003 IS INITIAL.
              CONTINUE.
            ENDIF.

            WRITE : / sy-uline.
            FORMAT COLOR COL_TOTAL.
            FORMAT INTENSIFIED ON.

            PERFORM f_write_text USING : 'Total' '93' 'X' '' '' '' '' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         '' '8' '' '' 'R' '' '' '',
                                         ls_k001t-bensin lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-solar lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-t0001 lv_lcurr '' '' 'R' '' 'IDR' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         ls_k001t-ogrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         ls_k001t-otrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         ls_k001t-gbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         '' '6' '' '' 'R' '' '' '',
                                         ls_k001t-akirp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-tbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-gmrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-sprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-sbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-skrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-t0002 lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-rmfee lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-stnk lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-kir lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-gprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-bpkb lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-t0003 lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k001t-grand lv_lcurr '' 'X' 'R' '' 'IDR' ''.

            PERFORM f_subtotal1 USING ls_k001t
                                CHANGING ls_k001g.

            FORMAT COLOR COL_BACKGROUND.
            CLEAR : gv_zebra, ls_k001t.
            WRITE : / sy-uline.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_k001[] IS NOT INITIAL.
    FORMAT COLOR COL_GROUP.
    FORMAT INTENSIFIED ON.
    PERFORM f_write_text USING : 'Grand Total' '93' 'X' '' '' '' '' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 '' '8' '' '' 'R' '' '' '',
                                 ls_k001g-bensin lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-solar lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-t0001 lv_lcurr '' '' 'R' '' 'IDR' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 ls_k001g-ogrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 ls_k001g-otrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 ls_k001g-gbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 '' '6' '' '' 'R' '' '' '',
                                 ls_k001g-akirp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-tbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-gmrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-sprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-sbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-skrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-t0002 lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-rmfee lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-stnk lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-kir lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-gprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-bpkb lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-t0003 lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k001g-grand lv_lcurr '' 'X' 'R' '' 'IDR' ''.
    WRITE : / sy-uline.
  ENDIF.
ENDFORM.                    " F_PRINT_KENDARAAN

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_KENDARAAN
*&---------------------------------------------------------------------*
FORM f_header_kendaraan  USING    fu_description.
  DATA : lv_lcurr   TYPE i VALUE 15.

  FORMAT COLOR COL_BACKGROUND.
  FORMAT INTENSIFIED ON.

  WRITE : / 'Departemen      :', fu_description.

  FORMAT COLOR COL_HEADING.
  FORMAT INTENSIFIED ON.

  WRITE : / sy-uline.
  PERFORM f_write_text USING : '' '12' 'X' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               'Pemakaian Bahan Bakar' '70' '' '' 'C' '' '' '',
                               'Repair and Maintenance' '194' '' 'X' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'Tax & License' '95' '' 'X' 'C' '' '' ''.

  PERFORM f_write_text USING : '' '12' 'X' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' 'C' '' '' '',
                               '' '8' '' '' 'C' '' '' '',
                               '' '8' '' '' 'C' '' '' '',
                               '' '12' '' '' 'C' '' '' '',
                               '' '6' '' '' 'C' '' '' ''.
  PERFORM f_write_line USING : '95' '57',
                               '151' '80',
                               '231' '132'.
  PERFORM f_write_text USING : '' lv_lcurr '' '' '' '' '' ''.
  PERFORM f_write_line USING : '377' '97'.

  PERFORM f_write_text USING : 'No.Kendaraan' '12' 'X' '' '' '' '' '',
                               'Pemakai' '15' '' '' '' '' '' '',
                               'Jabatan' '15' '' '' '' '' '' '',
                               'Cost' '10' '' '' 'C' '' '' '',
                               'Sales' '8' '' '' 'C' '' '' '',
                               'W&D' '8' '' '' 'C' '' '' '',
                               'Jenis' '12' '' '' 'C' '' '' '',
                               'Tahun' '6' '' '' '' '' '' '',
                               '' '6' '' '' 'C' '' '' '',
                               '' '6' '' '' 'C' '' '' '',
                               '' '8' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'Oli Gardan' '22' '' '' 'C' '' '' '',
                               'Oli Transmisi' '22' '' '' 'C' '' '' '',
                               'Ganti Ban' '29' '' '' 'C' '' '' '',
                               'Aki' '22' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'RM Fee' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' ''.

  PERFORM f_write_text USING : '' '12' 'X' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               'Center' '10' '' '' 'C' '' '' '',
                               'Force' '8' '' '' 'C' '' '' '',
                               'Category' '8' '' '' 'C' '' '' '',
                               'Kendaraan' '12' '' '' 'C' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               'km/bln' '6' '' '' 'C' '' '' '',
                               'Liter' '6' '' '' 'C' '' '' '',
                               'Ratio' '8' '' '' 'C' '' '' '',
                               'Bensin' lv_lcurr '' '' 'C' '' '' '',
                               'Solar' lv_lcurr '' '' 'C' '' '' '',
                               'Total' lv_lcurr '' '' 'C' '' '' ''.
  PERFORM f_write_line USING : '166' '100'.
  PERFORM f_write_text USING : 'Tambal' lv_lcurr '' '' 'C' '' '' '',
                               'Gembok' lv_lcurr '' '' 'C' '' '' '',
                               'Sparepart' lv_lcurr '' '' 'C' '' '' '',
                               'Service' lv_lcurr '' '' 'C' '' '' '',
                               'Service' lv_lcurr '' '' 'C' '' '' '',
                               'Total' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'STNK' lv_lcurr '' '' 'C' '' '' '',
                               'KIR' lv_lcurr '' '' 'C' '' '' '',
                               'Ganti Plat' lv_lcurr '' '' 'C' '' '' '',
                               'Ganti Nama' lv_lcurr '' '' 'C' '' '' '',
                               'Total' lv_lcurr '' '' 'C' '' '' '',
                               'Grand' lv_lcurr '' 'X' 'C' '' '' ''.

  PERFORM f_write_text USING : '' '12' 'X' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               'Kend.' '8' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'KM' '6' '' '' 'C' '' '' '',
                               'Rp' lv_lcurr '' '' 'C' '' '' '',
                               'KM' '6' '' '' 'C' '' '' '',
                               'Rp' lv_lcurr '' '' 'C' '' '' '',
                               'KM' '6' '' '' 'C' '' '' '',
                               'Qty' '6' '' '' 'C' '' '' '',
                               'Rp' lv_lcurr '' '' 'C' '' '' '',
                               'KM' '6' '' '' 'C' '' '' '',
                               'Rp' lv_lcurr '' '' 'C' '' '' '',
                               'Ban' lv_lcurr '' '' 'C' '' '' '',
                               'Mobil' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Besar' lv_lcurr '' '' 'C' '' '' '',
                               'Kecil' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'BPKB' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'Total' lv_lcurr '' 'X' 'C' '' '' ''.
  WRITE : / sy-uline.
  CLEAR gv_zebra.
ENDFORM.                    " F_HEADER_KENDARAAN

*&---------------------------------------------------------------------*
*&      Form  F_FORMULA
*&---------------------------------------------------------------------*
FORM f_formula  USING    fu_value1 fu_value2 fu_sign
                CHANGING fc_value.
  CASE fu_sign.
    WHEN '-'.
      fc_value  = fu_value2 - fu_value1.
    WHEN '+'.
      fc_value  = fc_value + fu_value1.
  ENDCASE.
ENDFORM.                    " F_FORMULA

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL1
*&---------------------------------------------------------------------*
FORM f_subtotal1  USING    fu_k001   LIKE LINE OF gt_k001
                  CHANGING fc_k001   LIKE LINE OF gt_k001.

  PERFORM f_formula USING    fu_k001-bensin
                             '' '+'
                    CHANGING fc_k001-bensin.
  PERFORM f_formula USING    fu_k001-solar
                             '' '+'
                    CHANGING fc_k001-solar.
  PERFORM f_formula USING    fu_k001-t0001
                             '' '+'
                    CHANGING fc_k001-t0001.
  PERFORM f_formula USING    fu_k001-ogrp
                             '' '+'
                    CHANGING fc_k001-ogrp.
  PERFORM f_formula USING    fu_k001-otrp
                             '' '+'
                    CHANGING fc_k001-otrp.
  PERFORM f_formula USING    fu_k001-gbrp
                             '' '+'
                    CHANGING fc_k001-gbrp.
  PERFORM f_formula USING    fu_k001-akirp
                             '' '+'
                    CHANGING fc_k001-akirp.
  PERFORM f_formula USING    fu_k001-tbrp
                             '' '+'
                    CHANGING fc_k001-tbrp.
  PERFORM f_formula USING    fu_k001-gmrp
                             '' '+'
                    CHANGING fc_k001-gmrp.
  PERFORM f_formula USING    fu_k001-sprp
                             '' '+'
                    CHANGING fc_k001-sprp.
  PERFORM f_formula USING    fu_k001-sbrp
                             '' '+'
                    CHANGING fc_k001-sbrp.
  PERFORM f_formula USING    fu_k001-skrp
                             '' '+'
                    CHANGING fc_k001-skrp.
  PERFORM f_formula USING    fu_k001-t0002
                             '' '+'
                    CHANGING fc_k001-t0002.
  PERFORM f_formula USING    fu_k001-rmfee
                             '' '+'
                    CHANGING fc_k001-rmfee.
  PERFORM f_formula USING    fu_k001-stnk
                             '' '+'
                    CHANGING fc_k001-stnk.
  PERFORM f_formula USING    fu_k001-gprp
                             '' '+'
                    CHANGING fc_k001-gprp.
  PERFORM f_formula USING    fu_k001-bpkb
                             '' '+'
                    CHANGING fc_k001-bpkb.
  PERFORM f_formula USING    fu_k001-kir
                             '' '+'
                    CHANGING fc_k001-kir.
  PERFORM f_formula USING    fu_k001-t0003
                             '' '+'
                    CHANGING fc_k001-t0003.
  PERFORM f_formula USING    fu_k001-grand
                             '' '+'
                    CHANGING fc_k001-grand.
ENDFORM.                    " F_SUBTOTAL1

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_PERSONEL
*&---------------------------------------------------------------------*
FORM f_print_personel .
  DATA : lt_k002    TYPE STANDARD TABLE OF ty_k002 INITIAL SIZE 0.
  DATA : ls_gtype LIKE LINE OF gt_gtype,
         ls_k002  LIKE LINE OF gt_k002,
         ls_k002t LIKE LINE OF gt_k002,
         ls_k002g LIKE LINE OF gt_k002.

  DATA : lv_subrc TYPE sy-subrc,
         lv_lcurr TYPE i VALUE 15.

  DATA : lv_01    TYPE zf63trndtl-wrbtr,
         lv_total TYPE zf63trndtl-wrbtr.

  SORT gt_k002 BY gtype kostl wwsfr wwpos name1.
  lt_k002[] = gt_k002[].
  SORT lt_k002 BY gtype kostl name1.
  DELETE ADJACENT DUPLICATES FROM lt_k002 COMPARING gtype kostl name1.

  SORT lt_k002 BY gtype kostl wwsfr wwpos name1.

  LOOP AT gt_gtype INTO ls_gtype.
    IF ls_gtype-advance IS INITIAL.
      READ TABLE lt_k002 INTO ls_k002
                         WITH KEY gtype = ls_gtype-gtype
                         TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CLEAR : lv_subrc, lv_01.
        LOOP AT gt_k002 INTO ls_k002 WHERE gtype  = ls_gtype-gtype.
          lv_01    = lv_01 + ls_k002-bensin + ls_k002-solar.
          lv_total = lv_total + lv_01 + ls_k002-parkir +
                     ls_k002-tol + ls_k002-pkrp + ls_k002-ptrp +
                     ls_k002-turp + ls_k002-ojek + ls_k002-hotel +
                     ls_k002-kost + ls_k002-pddk + ls_k002-pdlk +
                     ls_k002-ogrp + ls_k002-otrp + ls_k002-omrp +
                     ls_k002-gbrp + ls_k002-akirp + ls_k002-tbrp +
                     ls_k002-gmrp + ls_k002-sprp + ls_k002-sbrp +
                     ls_k002-skrp + ls_k002-rmfee + ls_k002-stnk +
                     ls_k002-kir + ls_k002-gprp + ls_k002-bpkb +
                     ls_k002-izin + ls_k002-muat + ls_k002-pasar +
                     ls_k002-timb + ls_k002-hand + ls_k002-materai +
                     ls_k002-ongkir + ls_k002-pulsa + ls_k002-warnet +
                     ls_k002-scan + ls_k002-buku + ls_k002-fotocopy.
        ENDLOOP.
        IF lv_total IS INITIAL.
          CONTINUE.
        ENDIF.

        IF lv_subrc IS INITIAL.
          PERFORM f_header_personel USING ls_gtype-description.
          LOOP AT lt_k002 INTO ls_k002 WHERE gtype  = ls_gtype-gtype.
            LOOP AT gt_k002 INTO ls_k002 WHERE gtype  = ls_k002-gtype
                                           AND name1  = ls_k002-name1
                                           AND kostl  = ls_k002-kostl.
              IF gv_zebra IS INITIAL.
                FORMAT COLOR COL_NORMAL.
                FORMAT INTENSIFIED OFF.
                gv_zebra = selected.
              ELSE.
                FORMAT COLOR COL_NORMAL.
                FORMAT INTENSIFIED ON.
                CLEAR gv_zebra.
              ENDIF.

              TRY .
                  ls_k002-ratio = ls_k002-jarak / ls_k002-liter.
                CATCH cx_sy_zerodivide.
              ENDTRY.

              ls_k002-t0001 = ls_k002-bensin + ls_k002-solar.
              ls_k002-total = ls_k002-t0001 + ls_k002-parkir + ls_k002-tol +
                              ls_k002-pkrp + ls_k002-ptrp + ls_k002-turp +
                              ls_k002-ojek + ls_k002-hotel + ls_k002-kost +
                              ls_k002-pddk + ls_k002-pdlk + ls_k002-ogrp +
                              ls_k002-otrp + ls_k002-omrp + ls_k002-gbrp +
                              ls_k002-akirp + ls_k002-tbrp + ls_k002-gmrp +
                              ls_k002-sprp + ls_k002-sbrp + ls_k002-skrp +
                              ls_k002-rmfee + ls_k002-stnk + ls_k002-kir +
                              ls_k002-gprp + ls_k002-bpkb + ls_k002-izin +
                              ls_k002-muat + ls_k002-pasar + ls_k002-timb +
                              ls_k002-hand + ls_k002-materai + ls_k002-ongkir +
                              ls_k002-pulsa + ls_k002-warnet + ls_k002-scan +
                              ls_k002-buku + ls_k002-fotocopy.

              IF ls_k002-total IS INITIAL.
                CONTINUE.
              ENDIF.

              PERFORM f_write_text USING : ls_k002-name1 lv_lcurr 'X' '' '' '' '' '',
                                           ls_k002-znopol '12' '' '' '' '' '' '',
                                           ls_k002-jabat lv_lcurr '' '' '' '' '' '',
                                           ls_k002-kostl '10' '' '' '' '' '' '',
                                           ls_k002-wwsfr '8' '' '' '' '' '' '',
                                           ls_k002-wwpos '8' '' '' '' '' '' '',
                                           ls_k002-jnskend '12' '' '' '' '' '' '',
                                           ls_k002-zujhr '6' '' '' '' '' '' '',
                                           ls_k002-bensin lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-solar lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-t0001 lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-parkir lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-tol lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-pkrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-ptrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-turp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-ojek lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-hotel lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-kost lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-pddk lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-pdlk lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-ogrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-otrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-omrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-gbrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-akirp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-tbrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-gmrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-sprp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-sbrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-skrp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-rmfee lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-stnk lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-kir lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-gprp lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-bpkb lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-izin lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-muat lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-pasar lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-timb lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-hand lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-materai lv_lcurr '' 'X' 'R' '' ls_k002-waers '',
                                           ls_k002-ongkir lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-pulsa lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-warnet lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-scan lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-buku lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-fotocopy lv_lcurr '' '' 'R' '' ls_k002-waers '',
                                           ls_k002-total lv_lcurr '' 'X' 'R' '' ls_k002-waers ''.

              PERFORM f_subtotal2 USING ls_k002
                                  CHANGING ls_k002t.
            ENDLOOP.

            IF ls_k002t-total IS INITIAL.
              CONTINUE.
            ENDIF.

            WRITE : / sy-uline.
            FORMAT COLOR COL_TOTAL.
            FORMAT INTENSIFIED ON.
            PERFORM f_write_text USING : 'Total' '93' 'X' '' '' '' '' '',
                                         ls_k002t-bensin lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-solar lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-t0001 lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-parkir lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-tol lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-pkrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-ptrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-turp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-ojek lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-hotel lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-kost lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-pddk lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-pdlk lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-ogrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-otrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-omrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-gbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-akirp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-tbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-gmrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-sprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-sbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-skrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-rmfee lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-stnk lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-kir lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-gprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-bpkb lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-izin lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-muat lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-pasar lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-timb lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-hand lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-materai lv_lcurr '' 'X' 'R' '' 'IDR' '',
                                         ls_k002t-ongkir lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-pulsa lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-warnet lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-scan lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-buku lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-fotocopy lv_lcurr '' '' 'R' '' 'IDR' '',
                                         ls_k002t-total lv_lcurr '' 'X' 'R' '' 'IDR' ''.
            FORMAT COLOR COL_BACKGROUND.

            PERFORM f_subtotal2 USING ls_k002t
                                CHANGING ls_k002g.

            CLEAR : gv_zebra, ls_k002t.
            WRITE : / sy-uline.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_k002[] IS NOT INITIAL.
    FORMAT COLOR COL_GROUP.
    FORMAT INTENSIFIED ON.
    PERFORM f_write_text USING : 'Grand Total' '93' 'X' '' '' '' '' '',
                                 ls_k002g-bensin lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-solar lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-t0001 lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-parkir lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-tol lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-pkrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-ptrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-turp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-ojek lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-hotel lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-kost lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-pddk lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-pdlk lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-ogrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-otrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-omrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-gbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-akirp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-tbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-gmrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-sprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-sbrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-skrp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-rmfee lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-stnk lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-kir lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-gprp lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-bpkb lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-izin lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-muat lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-pasar lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-timb lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-hand lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-materai lv_lcurr '' 'X' 'R' '' 'IDR' '',
                                 ls_k002g-ongkir lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-pulsa lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-warnet lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-scan lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-buku lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-fotocopy lv_lcurr '' '' 'R' '' 'IDR' '',
                                 ls_k002g-total lv_lcurr '' 'X' 'R' '' 'IDR' ''.
    FORMAT COLOR COL_BACKGROUND.
    WRITE : / sy-uline.
  ENDIF.
ENDFORM.                    " F_PRINT_PERSONEL

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_PERSONEL
*&---------------------------------------------------------------------*
FORM f_header_personel  USING    fu_description.
  DATA : lv_lcurr   TYPE i VALUE 15.

  FORMAT COLOR COL_BACKGROUND.
  FORMAT INTENSIFIED ON.

  WRITE : / 'Departemen      :', fu_description.

  FORMAT COLOR COL_HEADING.
  FORMAT INTENSIFIED ON.

  WRITE : / sy-uline.
  PERFORM f_write_text USING : '' '15' 'X' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               'Travel & Lodging' '207' '' '' 'C' '' '' '',
                               'Repair & Maintenance' '159' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Tax & License' '127' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Biaya Postage' '31' '' '' 'C' '' '' '',
                               'Biaya Telp & Fax' '47' '' '' 'C' '' '' '',
                               'Office Exp' '31' '' '' 'C' '' '' '',
                               '' lv_lcurr '' 'X' '' '' '' ''.

  PERFORM f_write_text USING : '' '15' 'X' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' ''.
  PERFORM f_write_line USING : '95' '49',
                               '144' '96',
                               '240' '34',
                               '274' '33',
                               '307' '161'.
  PERFORM f_write_text USING : '' lv_lcurr '' '' '' '' '' ''.
  PERFORM f_write_line USING : '479' '129'.
  PERFORM f_write_text USING : '' lv_lcurr '' '' '' '' '' ''.
  PERFORM f_write_line USING : '623' '113'.
  PERFORM f_write_text USING : '' lv_lcurr '' 'X' '' '' '' ''.

  PERFORM f_write_text USING : 'Pemakai' '15' 'X' '' '' '' '' '',
                               'No.Kendaraan ' '12' '' '' '' '' '' '',
                               'Jabatan' '15' '' '' '' '' '' '',
                               'Cost' '10' '' '' 'C' '' '' '',
                               'Sales' '8' '' '' 'C' '' '' '',
                               'W&D' '8' '' '' 'C' '' '' '',
                               'Jenis' '12' '' '' 'C' '' '' '',
                               'Tahun' '6' '' '' 'C' '' '' '',
                               'BBM' '47' '' '' 'C' '' '' '',
                               'Travelling' '95' '' '' 'C' '' '' '',
                               'Lodging' '31' '' '' 'C' '' '' '',
                               'Trav.Other' '31' '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'RM' lv_lcurr '' '' 'C' '' '' '',
                               'Vehicle' '63' '' '' 'C' '' '' '',
                               'Registrasi & Retribusi' '63' '' '' 'C' '' '' '',
                               'Handling' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Total' lv_lcurr '' 'X' 'C' '' '' ''.

  PERFORM f_write_text USING : '' '15' 'X' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               'Center' '10' '' '' 'C' '' '' '',
                               'Force' '8' '' '' 'C' '' '' '',
                               'Category' '8' '' '' 'C' '' '' '',
                               'Kendaraan' '12' '' '' 'C' '' '' '',
                               '' '6' '' '' '' '' '' ''.
  PERFORM f_write_line USING : '95' '49',
                               '144' '96',
                               '240' '32',
                               '272' '35'.
  PERFORM f_write_text USING : 'Oli' lv_lcurr '' '' 'C' '' '' '',
                               'Oli' lv_lcurr '' '' 'C' '' '' '',
                               'Oli' lv_lcurr '' '' 'C' '' '' '',
                               'Ganti' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Tambal' lv_lcurr '' '' 'C' '' '' '',
                               'Gembok' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Service' lv_lcurr '' '' 'C' '' '' '',
                               'Service' lv_lcurr '' '' 'C' '' '' '',
                               'Fee' lv_lcurr '' '' 'C' '' '' ''.
  PERFORM f_write_line USING : '479' '129'.
  PERFORM f_write_text USING : 'Cost' lv_lcurr '' '' 'C' '' '' '',
                               'Materai' lv_lcurr '' '' 'C' '' '' '',
                               'Biaya' lv_lcurr '' '' 'C' '' '' '',
                               'Pulsa' lv_lcurr '' '' 'C' '' '' '',
                               'Biaya' lv_lcurr '' '' 'C' '' '' '',
                               'Biaya' lv_lcurr '' '' 'C' '' '' '',
                               'Buku PO' lv_lcurr '' '' 'C' '' '' '',
                               'Fotocopy' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' 'X' '' '' '' ''.

  PERFORM f_write_text USING : '' '15' 'X' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               'Bensin' lv_lcurr '' '' 'C' '' '' '',
                               'Solar' lv_lcurr '' '' 'C' '' '' '',
                               'Total' lv_lcurr '' '' 'C' '' '' '',
                               'Parkir' lv_lcurr '' '' 'C' '' '' '',
                               'Tol' lv_lcurr '' '' 'C' '' '' '',
                               'Pemakaian' lv_lcurr '' '' 'C' '' '' '',
                               'Pembelian' lv_lcurr '' '' 'C' '' '' '',
                               'Trans' lv_lcurr '' '' 'C' '' '' '',
                               'Ojek' lv_lcurr '' '' 'C' '' '' '',
                               'Hotel' lv_lcurr '' '' 'C' '' '' '',
                               'Kost' lv_lcurr '' '' 'C' '' '' '',
                               'PDDK' lv_lcurr '' '' 'C' '' '' '',
                               'PDLK  ' lv_lcurr '' '' 'C' '' '' '',
                               'Gardan' lv_lcurr '' '' 'C' '' '' '',
                               'Transmisi' lv_lcurr '' '' 'C' '' '' '',
                               'Mesin' lv_lcurr '' '' 'C' '' '' '',
                               'Ban' lv_lcurr '' '' 'C' '' '' '',
                               'Aki' lv_lcurr '' '' 'C' '' '' '',
                               'Ban' lv_lcurr '' '' 'C' '' '' '',
                               'Mobil' lv_lcurr '' '' 'C' '' '' '',
                               'Sparepart' lv_lcurr '' '' 'C' '' '' '',
                               'Besar' lv_lcurr '' '' 'C' '' '' '',
                               'Kecil' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'STNK' lv_lcurr '' '' 'C' '' '' '',
                               'KIR' lv_lcurr '' '' 'C' '' '' '',
                               'Ganti' lv_lcurr '' '' 'C' '' '' '',
                               'Ganti' lv_lcurr '' '' 'C' '' '' '',
                               'Izin Kend/' lv_lcurr '' '' 'C' '' '' '',
                               'Izin' lv_lcurr '' '' 'C' '' '' '',
                               'Retribusi' lv_lcurr '' '' 'C' '' '' '',
                               'Timbangan' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Kirim' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Warnet' lv_lcurr '' '' 'C' '' '' '',
                               'Scan' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' 'X' '' '' '' ''.

  PERFORM f_write_text USING : '' '15' 'X' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '15' '' '' '' '' '' '',
                               '' '10' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '8' '' '' '' '' '' '',
                               '' '12' '' '' '' '' '' '',
                               '' '6' '' '' '' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' 'C' '' '' '',
                               'Kendaraan' lv_lcurr '' '' 'C' '' '' '',
                               'Tiket' lv_lcurr '' '' 'C' '' '' '',
                               'Angk.Umum' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Plat' lv_lcurr '' '' 'C' '' '' '',
                               'Nama BPKB' lv_lcurr '' '' 'C' '' '' '',
                               'Msk Kota' lv_lcurr '' '' 'C' '' '' '',
                               'BngkrMuat' lv_lcurr '' '' 'C' '' '' '',
                               'Pasar' lv_lcurr '' '' 'C' '' '' '',
                               'Kendaraan' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Dokumen' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               'Dokumen' lv_lcurr '' '' 'C' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' '' '' '' '' '',
                               '' lv_lcurr '' 'X' '' '' '' ''.
  WRITE : / sy-uline.
  CLEAR gv_zebra.
ENDFORM.                    " F_HEADER_PERSONEL

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL2
*&---------------------------------------------------------------------*
FORM f_subtotal2  USING    fu_k002   LIKE LINE OF gt_k002
                  CHANGING fc_k002   LIKE LINE OF gt_k002.

  PERFORM f_formula USING    fu_k002-bensin
                             '' '+'
                    CHANGING fc_k002-bensin.
  PERFORM f_formula USING    fu_k002-solar
                             '' '+'
                    CHANGING fc_k002-solar.
  PERFORM f_formula USING    fu_k002-t0001
                             '' '+'
                    CHANGING fc_k002-t0001.
  PERFORM f_formula USING    fu_k002-parkir
                             '' '+'
                    CHANGING fc_k002-parkir.
  PERFORM f_formula USING    fu_k002-tol
                             '' '+'
                    CHANGING fc_k002-tol.
  PERFORM f_formula USING    fu_k002-pkrp
                             '' '+'
                    CHANGING fc_k002-pkrp.
  PERFORM f_formula USING    fu_k002-ptrp
                             '' '+'
                    CHANGING fc_k002-ptrp.
  PERFORM f_formula USING    fu_k002-turp
                             '' '+'
                    CHANGING fc_k002-turp.
  PERFORM f_formula USING    fu_k002-ojek
                             '' '+'
                    CHANGING fc_k002-ojek.
  PERFORM f_formula USING    fu_k002-hotel
                             '' '+'
                    CHANGING fc_k002-hotel.
  PERFORM f_formula USING    fu_k002-kost
                             '' '+'
                    CHANGING fc_k002-kost.
  PERFORM f_formula USING    fu_k002-pddk
                             '' '+'
                    CHANGING fc_k002-pddk.
  PERFORM f_formula USING    fu_k002-pdlk
                             '' '+'
                    CHANGING fc_k002-pdlk.
  PERFORM f_formula USING    fu_k002-ogrp
                             '' '+'
                    CHANGING fc_k002-ogrp.
  PERFORM f_formula USING    fu_k002-otrp
                             '' '+'
                    CHANGING fc_k002-otrp.
  PERFORM f_formula USING    fu_k002-omrp
                             '' '+'
                    CHANGING fc_k002-omrp.
  PERFORM f_formula USING    fu_k002-gbrp
                             '' '+'
                    CHANGING fc_k002-gbrp.
  PERFORM f_formula USING    fu_k002-akirp
                             '' '+'
                    CHANGING fc_k002-akirp.
  PERFORM f_formula USING    fu_k002-tbrp
                             '' '+'
                    CHANGING fc_k002-tbrp.
  PERFORM f_formula USING    fu_k002-gmrp
                             '' '+'
                    CHANGING fc_k002-gmrp.
  PERFORM f_formula USING    fu_k002-sprp
                             '' '+'
                    CHANGING fc_k002-sprp.
  PERFORM f_formula USING    fu_k002-sbrp
                             '' '+'
                    CHANGING fc_k002-sbrp.
  PERFORM f_formula USING    fu_k002-skrp
                             '' '+'
                    CHANGING fc_k002-skrp.
  PERFORM f_formula USING    fu_k002-rmfee
                             '' '+'
                    CHANGING fc_k002-rmfee.
  PERFORM f_formula USING    fu_k002-stnk
                             '' '+'
                    CHANGING fc_k002-stnk.
  PERFORM f_formula USING    fu_k002-gprp
                             '' '+'
                    CHANGING fc_k002-gprp.
  PERFORM f_formula USING    fu_k002-bpkb
                             '' '+'
                    CHANGING fc_k002-bpkb.
  PERFORM f_formula USING    fu_k002-kir
                             '' '+'
                    CHANGING fc_k002-kir.
  PERFORM f_formula USING    fu_k002-izin
                             '' '+'
                    CHANGING fc_k002-izin.
  PERFORM f_formula USING    fu_k002-muat
                             '' '+'
                    CHANGING fc_k002-muat.
  PERFORM f_formula USING    fu_k002-pasar
                             '' '+'
                    CHANGING fc_k002-pasar.
  PERFORM f_formula USING    fu_k002-timb
                             '' '+'
                    CHANGING fc_k002-timb.
  PERFORM f_formula USING    fu_k002-hand
                             '' '+'
                    CHANGING fc_k002-hand.
  PERFORM f_formula USING    fu_k002-materai
                             '' '+'
                    CHANGING fc_k002-materai.
  PERFORM f_formula USING    fu_k002-ongkir
                             '' '+'
                    CHANGING fc_k002-ongkir.
  PERFORM f_formula USING    fu_k002-pulsa
                             '' '+'
                    CHANGING fc_k002-pulsa.
  PERFORM f_formula USING    fu_k002-warnet
                             '' '+'
                    CHANGING fc_k002-warnet.
  PERFORM f_formula USING    fu_k002-scan
                             '' '+'
                    CHANGING fc_k002-scan.
  PERFORM f_formula USING    fu_k002-buku
                             '' '+'
                    CHANGING fc_k002-buku.
  PERFORM f_formula USING    fu_k002-fotocopy
                             '' '+'
                    CHANGING fc_k002-fotocopy.
  PERFORM f_formula USING    fu_k002-total
                             '' '+'
                    CHANGING fc_k002-total.
ENDFORM.                    " F_SUBTOTAL2

*&---------------------------------------------------------------------*
*&      Form  F_ALV_LIST_ADVANCE
*&---------------------------------------------------------------------*
FORM f_alv_list_advance .
  DATA : lr_functions  TYPE REF TO cl_salv_functions,
         lr_display    TYPE REF TO cl_salv_display_settings,
         lr_events     TYPE REF TO cl_salv_events_table,
         lr_aggrs      TYPE REF TO cl_salv_aggregations,
         lr_selections TYPE REF TO cl_salv_selections.

  TRY.
      cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = gr_table
          CHANGING
            t_table        = gt_advance ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_table->set_screen_status(
    pfstatus   = 'SALV_STANDARD3'
    report     = gv_repid ).

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.

  gr_table->display( ).
ENDFORM.                    " F_Alv_LIST_ADVANCE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VBUND
*&---------------------------------------------------------------------*
FORM f_check_vbund  USING    fu_vbund
                    CHANGING fc_subrc.
  DATA : ls_trpar   LIKE LINE OF gt_trpar.

  READ TABLE gt_trpar INTO ls_trpar WITH KEY vbund = fu_vbund.
  fc_subrc = sy-subrc.
ENDFORM.                    " F_CHECK_VBUND

*&---------------------------------------------------------------------*
*&      Form  F_GRAND_TOTAL
*&---------------------------------------------------------------------*
FORM f_grand_total  USING    fu_value fu_carton fu_brgew fu_volum fu_menge
                             fu_bbm fu_pddk fu_pdlk fu_lodging fu_kuli
                             fu_parkir fu_tol fu_retribusi fu_rm fu_tl
                             fu_total
                    CHANGING fs_gdelv   TYPE ty_gdelv.

  ADD fu_value      TO fs_gdelv-value.
  ADD fu_carton     TO fs_gdelv-carton.
  ADD fu_brgew      TO fs_gdelv-brgew.
  ADD fu_volum      TO fs_gdelv-volum.
  ADD fu_menge      TO fs_gdelv-menge.
  ADD fu_bbm        TO fs_gdelv-bbm.
  ADD fu_pddk       TO fs_gdelv-pddk.
  ADD fu_pdlk       TO fs_gdelv-pdlk.
  ADD fu_lodging    TO fs_gdelv-lodging.
  ADD fu_kuli       TO fs_gdelv-kuli.
  ADD fu_parkir     TO fs_gdelv-parkir.
  ADD fu_tol        TO fs_gdelv-tol.
  ADD fu_retribusi  TO fs_gdelv-retribusi.
  ADD fu_rm         TO fs_gdelv-rm.
  ADD fu_tl         TO fs_gdelv-tl.
  ADD fu_total      TO fs_gdelv-total.
ENDFORM.                    " F_GRAND_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_ADD_REKANAN
*&---------------------------------------------------------------------*
FORM f_add_rekanan .
  SELECT *
    FROM zf63trnhdr
    APPENDING CORRESPONDING FIELDS OF TABLE gt_trnhdr
    WHERE bukrs = pa_bukrs
      AND vkbur IN so_vkbur
      AND gsber IN so_gsber
      AND gtype IN so_gtype
      AND erdat IN so_budat
      AND rekanan = 'X'.
ENDFORM.                    " F_ADD_REKANAN

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_NAME1
*&---------------------------------------------------------------------*
FORM f_value_name1 USING fu_field.
  DATA : BEGIN OF lt_tvbur OCCURS 0,
           vkbur TYPE tvbur-vkbur,
         END OF lt_tvbur.

  DATA : BEGIN OF lt_person OCCURS 0,
           zidno TYPE zf63masterperson-zidno,
           name1 TYPE zf63masterperson-name1,
         END OF lt_person.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_person LIKE LINE OF lt_person,
         lv_zidno  TYPE zf63masterperson-zidno,
         lv_subrc  TYPE sy-subrc,
         lv_bukrs  TYPE zf63masterperson-bukrs,
         lv_vkbur  TYPE zf63masterperson-vkbur,
         lv_gsber  TYPE zf63masterperson-gsber,
         lv_gtype  TYPE zf63masterperson-gtype.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.

  SELECT vkbur
    FROM tvbur
    INTO TABLE lt_tvbur
    WHERE vkbur IN so_vkbur.

  PERFORM f_dynp_value_read USING 'SO_VKBUR-LOW'
                            CHANGING lv_vkbur.
  lv_gsber = lv_vkbur.
  PERFORM f_dynp_value_read USING 'PA_GTYPE'
                            CHANGING lv_gtype.

  CLEAR : lt_person[], lt_person, dynpfields[], dynpfields.
  SELECT zidno name1
    FROM zf63masterperson
    INTO CORRESPONDING FIELDS OF TABLE lt_person
      WHERE bukrs = lv_bukrs
        AND vkbur = lv_vkbur
        AND gsber = lv_gsber
        AND gtype = lv_gtype.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDNO' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidno  = ls_return-fieldval.
      READ TABLE lt_person INTO ls_person WITH KEY zidno = lv_zidno.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_person-zidno ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field '' ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_NAME1

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table  USING    fu_function fu_gname
                            fu_bukrs fu_gsber fu_vkbur fu_gtype fu_zidvc
                            fu_zidno
                   CHANGING fc_uname.
  DATA : enq    TYPE STANDARD TABLE OF seqg3 INITIAL SIZE 0,
         ls_enq LIKE LINE OF enq.

  DATA : lv_bukrs TYPE zf63masterperson-bukrs,
         lv_gsber TYPE zf63masterperson-gsber,
         lv_vkbur TYPE zf63masterperson-vkbur.

  CASE fu_gname.
    WHEN 'ZF63MASTERPERSON'.
      CALL FUNCTION fu_function
        EXPORTING
          bukrs          = fu_bukrs
          gsber          = fu_gsber
          vkbur          = fu_vkbur
          zidno          = fu_zidno
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      IF sy-subrc <> 0.
        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            gname                 = fu_gname
            guname                = space
          TABLES
            enq                   = enq
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2
            OTHERS                = 3.

        IF fu_zidno = '0000000000'.
          LOOP AT enq INTO ls_enq.
            CLEAR : lv_bukrs, lv_gsber, lv_vkbur.
            IF ls_enq-garg+3(4) = lv_bukrs AND
              ls_enq-garg+7(4) = lv_gsber AND
              ls_enq-garg+11(4) = lv_vkbur.
              fc_uname  = ls_enq-guname.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE enq INTO ls_enq INDEX 1.
          IF sy-subrc = 0.
            fc_uname  = ls_enq-guname.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'ZF63TRNVCH'.
      CALL FUNCTION fu_function
        EXPORTING
          bukrs          = fu_bukrs
          gsber          = fu_gsber
          vkbur          = fu_vkbur
          gtype          = fu_gtype
          zidvc          = fu_zidvc
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      IF sy-subrc <> 0.
        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            gname                 = fu_gname
            guname                = space
          TABLES
            enq                   = enq
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2
            OTHERS                = 3.

        READ TABLE enq INTO ls_enq INDEX 1.
        IF sy-subrc = 0.
          fc_uname  = ls_enq-guname.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table  USING    fu_flag fu_function.
  IF fu_flag IS INITIAL.
    CALL FUNCTION fu_function
      EXPORTING
        bukrs = pa_bukrs
        gsber = pa_gsber
        vkbur = pa_vkbur
        gtype = pa_gtype
        zidvc = pa_zidvc.
  ELSE.
    CALL FUNCTION 'DEQUEUE_ALL'.
  ENDIF.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CTYPE
*&---------------------------------------------------------------------*
FORM f_value_ctype  USING    fu_field.
  DATA : BEGIN OF lt_xtype OCCURS 0,
           zeile     TYPE zf63ctrltype-zeile,
           type_ctrl TYPE zf63ctrltype-type_ctrl,
         END OF lt_xtype.
  DATA : BEGIN OF lt_ctype OCCURS 0,
           type_ctrl TYPE zf63ctrltype-type_ctrl,
         END OF lt_ctype.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_ctype LIKE LINE OF lt_ctype,
         ls_xtype LIKE LINE OF lt_xtype,
         lv_subrc TYPE sy-subrc.

  SELECT zeile type_ctrl
    FROM zf63ctrltype
    INTO CORRESPONDING FIELDS OF TABLE lt_xtype.

  SORT lt_xtype BY type_ctrl.
  DELETE ADJACENT DUPLICATES FROM lt_xtype COMPARING type_ctrl.
  SORT lt_xtype BY zeile.
  LOOP AT lt_xtype INTO ls_xtype.
    ls_ctype-type_ctrl    = ls_xtype-type_ctrl.
    APPEND ls_ctype TO lt_ctype.
  ENDLOOP.
  ASSIGN lt_ctype[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'TYPE_CTRL' fu_field
                          CHANGING lv_subrc.

ENDFORM.                    " F_VALUE_CTYPE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_GTYPE
*&---------------------------------------------------------------------*
FORM f_value_gtype  USING    fu_field.
  DATA : BEGIN OF lt_gtype OCCURS 0,
           gtype       TYPE zf63gtype-gtype,
           description TYPE zf63gtype-description,
         END OF lt_gtype.
  DATA : BEGIN OF lt_ctype OCCURS 0,
           zeile     TYPE zf63ctrltype-zeile,
           type_ctrl TYPE zf63ctrltype-type_ctrl,
           gtype     TYPE zf63ctrltype-gtype,
         END OF lt_ctype.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_gtype LIKE LINE OF lt_gtype,
         ls_ctype LIKE LINE OF lt_ctype,
         lv_gtype TYPE zf63gtype-gtype,
         lv_subrc TYPE sy-subrc,
         lv_bukrs TYPE t001-bukrs,
         lv_ctype TYPE zf63ctrltype-type_ctrl.

  CLEAR : lt_gtype[], lt_gtype, lt_ctype[], lt_ctype,
          dynpfields[], dynpfields.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_GTYPE'
                            CHANGING lv_gtype.
  PERFORM f_dynp_value_read USING 'PA_CTYPE'
                            CHANGING lv_ctype.

  CASE 'X'.
    WHEN radio2 OR radio3 OR radio11 OR radio12.
      SELECT gtype description jeadv
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
          WHERE bukrs   = pa_bukrs
            AND advance = space.

    WHEN radio4 OR radio15.
      CLEAR : lt_ctype[].
      SELECT zeile type_ctrl gtype
        FROM zf63ctrltype
        INTO CORRESPONDING FIELDS OF TABLE lt_ctype
          WHERE type_ctrl = lv_ctype.

      IF lt_ctype[] IS NOT INITIAL.
        CLEAR : lt_gtype[].
        SELECT gtype description jeadv
          FROM zf63gtype
          INTO CORRESPONDING FIELDS OF TABLE lt_gtype
          FOR ALL ENTRIES IN lt_ctype
            WHERE gtype = lt_ctype-gtype
              AND bukrs = lv_bukrs.
      ENDIF.

    WHEN radio13 OR radio14 OR radio17.
      SELECT gtype description
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
          WHERE bukrs   = lv_bukrs
            AND advance = 'X'.

    WHEN radio5 OR radio6 OR radio7 OR radio8 OR radio9 OR radio10.
      SELECT gtype description
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
        WHERE bukrs = lv_bukrs.
  ENDCASE.

  ASSIGN lt_gtype[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'GTYPE' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_gtype  = ls_return-fieldval.
      READ TABLE lt_gtype INTO ls_gtype WITH KEY gtype = lv_gtype.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_gtype-gtype ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field lv_gtype ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_GTYPE

*&---------------------------------------------------------------------*
*&      Form  F_GTYPE_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_gtype_authorization .
  DATA : lt_gtype     TYPE STANDARD TABLE OF zf63gtype INITIAL SIZE 0,
         ls_gtype     TYPE zf63gtype,
         lv_mess(100).

  IF pa_gtype IS NOT INITIAL.
    SELECT SINGLE *
      FROM zf63gtype
      INTO ls_gtype
        WHERE gtype = pa_gtype
          AND bukrs = pa_bukrs.
    CASE 'X'.
      WHEN radio2 OR radio3 OR radio4 OR radio11 OR radio12 OR radio15.
        IF ls_gtype IS INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type tidak ada'.
        ELSE.
          IF ls_gtype-advance IS NOT INITIAL.
            PERFORM f_error_message USING 'PGT' 'Hanya untuk type Expense'.
          ENDIF.
        ENDIF.
      WHEN radio13 OR radio14 OR radio17.
        IF ls_gtype IS INITIAL.
          PERFORM f_error_message USING 'PGT' 'Type tidak ada'.
        ELSE.
          IF ls_gtype-advance IS INITIAL.
            PERFORM f_error_message USING 'PGT' 'Hanya untuk type Advance'.
          ENDIF.
        ENDIF.
    ENDCASE.
  ELSEIF so_gtype[] IS NOT INITIAL.
    SELECT *
      FROM zf63gtype
      INTO CORRESPONDING FIELDS OF TABLE lt_gtype
        WHERE gtype IN so_gtype
          AND bukrs = pa_bukrs.

    CASE 'X'.
      WHEN radio2 OR radio3 OR radio4 OR radio11 OR radio12 OR radio15.
        IF lt_gtype[] IS INITIAL.
          PERFORM f_error_message USING 'SGT' 'Type tidak ada'.
        ELSE.
          LOOP AT lt_gtype INTO ls_gtype WHERE advance = 'X'.
            PERFORM f_error_message USING 'SGT' 'Hanya untuk type Expense'.
            EXIT.
          ENDLOOP.
        ENDIF.
      WHEN radio13 OR radio14.
        IF lt_gtype[] IS INITIAL.
          PERFORM f_error_message USING 'SGT' 'Type tidak ada'.
        ELSE.
          LOOP AT lt_gtype INTO ls_gtype WHERE advance = space.
            PERFORM f_error_message USING 'SGT' 'Hanya untuk type Advance'.
            EXIT.
          ENDLOOP.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GTYPE_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_COUNTER_ADVANCE
*&---------------------------------------------------------------------*
FORM f_counter_advance .
  DATA : lv_advan   TYPE zf63ctrladv-advan,
         ls_mstp    TYPE zf63masterperson,
         lr_gjahr   TYPE RANGE OF gjahr,
         ls_gjahr   LIKE LINE OF lr_gjahr,
         ls_ctrladv LIKE LINE OF gt_ctrladv.

  ls_gjahr-low    = sy-datum(4) - 1.
  ls_gjahr-high   = sy-datum(4).
  ls_gjahr-sign   = 'I'.
  ls_gjahr-option = 'BT'.
  APPEND ls_gjahr TO lr_gjahr.

  IF gs_gtype-lfa1 IS INITIAL.
    SELECT SINGLE *
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF ls_mstp
      WHERE bukrs = zfexpense-bukrs
        AND gsber = zfexpense-gsber
        AND vkbur = zfexpense-vkbur
        AND zidno = zfexpense-zidno.
  ELSE.
    SELECT SINGLE *
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF ls_mstp
      WHERE bukrs = zfexpense-bukrs
        AND gsber = zfexpense-gsber
        AND vkbur = zfexpense-vkbur
        AND lifnr = zfexpense-zidno.
  ENDIF.

  IF ls_mstp IS NOT INITIAL.
    SELECT *
      FROM zf63ctrladv
      INTO CORRESPONDING FIELDS OF TABLE gt_ctrladv
      WHERE bukrs   = pa_bukrs
        AND vkbur   = pa_vkbur
        AND gtype   = pa_gtype
        AND lifnr   = ls_mstp-lifnr
        AND zidno   = ls_mstp-zidno.
*        AND gjahr   IN lr_gjahr.

    READ TABLE gt_ctrladv INTO gs_ctrladv INDEX 1. "WITH KEY gjahr = sy-datum(4).
    IF sy-subrc <> 0.
      gs_ctrladv-bukrs   = pa_bukrs.
      gs_ctrladv-vkbur   = pa_vkbur.
      gs_ctrladv-gtype   = pa_gtype.
      gs_ctrladv-lifnr   = ls_mstp-lifnr.
      gs_ctrladv-zidno   = ls_mstp-zidno.
*      gs_ctrladv-gjahr   = sy-datum(4).
    ENDIF.

    LOOP AT gt_ctrladv INTO ls_ctrladv.
      lv_advan  = ls_ctrladv-advan - ls_ctrladv-zreal.
      IF lv_advan >= gs_gtype-toadv.
        gv_error = 'X'.
      ENDIF.
    ENDLOOP.

    gs_ctrladv-advan = gs_ctrladv-advan + 1.
  ENDIF.
ENDFORM.                    " F_COUNTER_ADVANCE

*&---------------------------------------------------------------------*
*&      Form  F_ADVANCE_MODIFY
*&---------------------------------------------------------------------*
FORM f_advance_modify .
  DATA : lt_bsik   TYPE STANDARD TABLE OF bsik INITIAL SIZE 0,
         ls_bsik   LIKE LINE OF lt_bsik,
         lt_trnvch TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         ls_trnvch LIKE LINE OF lt_trnvch.

  lt_bsik[] = gt_bsik[].
  SORT lt_bsik BY belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING belnr gjahr.
  IF lt_bsik[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnvch
      INTO CORRESPONDING FIELDS OF TABLE lt_trnvch
      FOR ALL ENTRIES IN lt_bsik
      WHERE bukrs      = lt_bsik-bukrs
        AND gsber      = lt_bsik-gsber
        AND gtype      = gs_gtype-jeadv
        AND belnrpadv  = lt_bsik-belnr
        AND gjahrpadv  = lt_bsik-gjahr.
  ENDIF.

  LOOP AT gt_bsik INTO ls_bsik.
    CLEAR ls_trnvch.
    READ TABLE lt_trnvch INTO ls_trnvch
                         WITH KEY belnrpadv = ls_bsik-belnr
                                  gjahrpadv = ls_bsik-gjahr.
    IF sy-subrc = 0.
      CONTINUE.
    ELSE.
      DELETE TABLE gt_bsik FROM ls_bsik.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ADVANCE_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CHECKBOX_CHECKING
*&---------------------------------------------------------------------*
FORM f_checkbox_checking  CHANGING fc_condition.
  DATA : lv_value    TYPE string,
         lv_field    TYPE string,
         lv_operator TYPE string,
         lv_str1     TYPE string,
         lv_str2     TYPE string.

  FIELD-SYMBOLS : <fs>        TYPE any.

  IF pa_chk1 IS NOT INITIAL.
    lv_operator = 'AND'.
    lv_value  = '10'.
    ASSIGN lv_value TO <fs>.
    CONCATENATE ''' '<fs>' ''' INTO lv_value.
    CONDENSE lv_value NO-GAPS.
    CONCATENATE fc_condition lv_operator 'JEADV =' lv_value
    INTO fc_condition
    SEPARATED BY space.
  ENDIF.
  IF pa_chk2 IS NOT INITIAL.
    IF pa_chk1 IS NOT INITIAL.
      lv_operator = 'OR'.
    ELSE.
      lv_operator = 'AND'.
    ENDIF.
    lv_value  = '11'.
    ASSIGN lv_value TO <fs>.
    CONCATENATE ''' '<fs>' ''' INTO lv_value.
    CONDENSE lv_value NO-GAPS.
    CONCATENATE fc_condition lv_operator 'JEADV =' lv_value
    INTO fc_condition
    SEPARATED BY space.
  ENDIF.
  IF pa_chk3 IS NOT INITIAL.
    IF pa_chk1 IS NOT INITIAL OR
      pa_chk2 IS NOT INITIAL.
      lv_operator = 'OR'.
    ELSE.
      lv_operator = 'AND'.
    ENDIF.
    lv_value  = space.
    ASSIGN lv_value TO <fs>.
    CONCATENATE ''' '<fs>' ''' INTO lv_value.
    CONDENSE lv_value NO-GAPS.
    CONCATENATE fc_condition lv_operator 'JEADV =' lv_value
    INTO fc_condition
    SEPARATED BY space.
  ENDIF.
  SPLIT fc_condition AT 'AND' INTO lv_str1 lv_str2.
  IF lv_str2 IS NOT INITIAL.
    SHIFT lv_str2 LEFT DELETING LEADING space.
    CONCATENATE lv_str1 'AND (' lv_str2 ')' INTO fc_condition
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_CHECKBOX_CHECKING

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_NEW
*&---------------------------------------------------------------------*
FORM f_print_form_new USING fu_fname fu_proc fu_flag
                      CHANGING fc_shkzg.
  DATA : lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop,
         lv_formname        TYPE tdsfname,
         lv_text1(50),
         lv_prefix2(3),
         ls_detail          LIKE LINE OF gt_detail.

  DATA : ls_acc  LIKE LINE OF gt_zf63acc,
         ls_xexp LIKE LINE OF gt_xexp.

  CLEAR : gt_window3[], gt_window3.

  gs_header-bukrs = pa_bukrs.
  gs_header-title = 'Cash/Bank Payment Voucher'.

  CLEAR ls_xexp.
  LOOP AT gt_xexp INTO ls_xexp.
    IF ls_xexp-znopol IS NOT INITIAL.
      gs_header-znopol  = ls_xexp-znopol.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gs_header-znopol IS INITIAL.
    SELECT SINGLE znopol
      FROM zf63masterkend
      INTO gs_header-znopol
      WHERE bukrs = pa_bukrs
        AND gsber = pa_vkbur
        AND vkbur = pa_vkbur
        AND zidke = gs_mstp-zidke
        AND loevm = space.
  ENDIF.

  READ TABLE gt_zf63acc INTO ls_acc WITH KEY ktext = zfexpense-ktext.
  IF sy-subrc = 0.
    gs_header-hkont = ls_acc-hkont.
    gv_nmvch        = ls_acc-nmvoucher.
    PERFORM f_get_description USING 'SKAT' 'TXT20' 'SAKNR' ls_acc-hkont
                              CHANGING gs_header-txt20.
  ENDIF.

  CASE fu_proc.
    WHEN 'PRNT'.
      PERFORM f_get_next_number USING '' pa_gsber sy-datum(4)
                                      sy-datum(6) 'H' gv_nmvch
                                CHANGING gv_nomor gv_kdvch.
      CONCATENATE gv_kdvch '/' sy-datum(6) '/' gv_nomor
      INTO gs_header-cell14.
      gv_zidvc  = gs_header-cell14.

      PERFORM f_modify_nomor USING pa_bukrs pa_vkbur
                                   'H' gv_kdvch gv_nmvch
                                   sy-datum(6) gv_nomor.

      CALL FUNCTION 'DEQUEUE_ALL'.

    WHEN 'PREV'.
      SELECT SINGLE kdvch
        FROM zf63nomor
        INTO gv_kdvch
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND spmon = sy-datum(6)
          AND shkzg = 'H'
          AND nmvch = gv_nmvch.
  ENDCASE.

  IF gv_kdvch IS NOT INITIAL.
    IF gv_lock IS INITIAL.
      gs_header-bktxt = zfexpense-bktxt.

      IF gs_mstp-lifnr IS INITIAL.
        gs_header-cell15  = gs_mstp-name1.
      ELSE.
        CONCATENATE gs_mstp-lifnr '-' gs_mstp-name1 INTO gs_header-cell15
        SEPARATED BY space.
      ENDIF.

      IF gs_mstp-vbund IS INITIAL.
        lv_text1  = gs_mstp-kostl.
      ELSE.
        CONCATENATE gs_mstp-kostl '/' gs_mstp-vbund INTO lv_text1
        SEPARATED BY space.
      ENDIF.

      IF gs_mstp-wwsfr IS NOT INITIAL.
        gs_header-cell16  = gs_mstp-wwsfr.
      ENDIF.
      IF gs_mstp-wwpos IS NOT INITIAL.
        gs_header-cell16  = gs_mstp-wwpos.
      ENDIF.

      PERFORM f_window3 USING : 'Vendor' ':' gs_header-cell15 ''
                                'No.Voucher' ':' gs_header-cell14.
      PERFORM f_window3 USING : 'No.Polisi' ':' gs_header-znopol ''
                                'Reference' ':' ''.
      PERFORM f_window3 USING : 'Doc.Header Text' ':' gs_header-bktxt ''
                                'Posting Date' ':' ''.
      IF fu_flag IS NOT INITIAL.
        PERFORM f_window3 USING : 'CostCtr/TrPart' ':' lv_text1 ''
                                  'SF/WD' ':' gs_header-cell16.
      ENDIF.

      SELECT SINGLE butxt
        FROM t001
        INTO gs_header-butxt
        WHERE bukrs = pa_bukrs.

      SELECT SINGLE bezei
        FROM tvkbt
        INTO gs_header-bezei
        WHERE spras = sy-langu
          AND vkbur = pa_vkbur.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = fu_fname
        IMPORTING
          fm_name            = lv_funcname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      lwa_output_option-tdnewid   = 'X'.
      CASE fu_proc.
        WHEN 'PREV'.
          lwa_output_option-tdnoprint = 'X'.
        WHEN 'PRNT'.
          lwa_output_option-tdnoprev = 'X'.
      ENDCASE.

      IF zfexpense-advance IS NOT INITIAL.
        lwa_control_option-no_close = 'X'.
      ENDIF.

      CALL FUNCTION lv_funcname
        EXPORTING
          output_options     = lwa_output_option
          control_parameters = lwa_control_option
          user_settings      = 'X'
          gs_header          = gs_header
        TABLES
          gt_window3         = gt_window3
          gt_detail          = gt_detail
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF zfexpense-advance IS NOT INITIAL.
        lwa_control_option-no_open = 'X'.

        lv_formname = 'ZFEXP_F002'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = lv_formname
          IMPORTING
            fm_name            = lv_funcname
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        CLEAR : gt_window3[], gt_window3, gt_detail[], gt_detail.

        PERFORM f_get_next_number USING '' pa_gsber sy-datum(4)
                                        sy-datum(6) 'S' gv_nmvch
                                  CHANGING gv_nomor gv_kdvch.
        CONCATENATE gv_kdvch '/' sy-datum(6) '/' gv_nomor
        INTO gs_header-cell14.
        gv_zidvc2  = gs_header-cell14.

        PERFORM f_modify_nomor USING pa_bukrs pa_vkbur
                                     'S' gv_kdvch gv_nmvch
                                     sy-datum(6) gv_nomor.

        CALL FUNCTION 'DEQUEUE_ALL'.

        CONCATENATE 'PENY' gv_bktxt INTO gv_bktxt
        SEPARATED BY space.
        PERFORM f_isi_form USING '' 'Cash/Bank Receipt Voucher'
                                 gv_bktxt gv_dmbtr '' '' lv_prefix2 '' ''.

        ls_detail-description   = gv_description.
        ls_detail-hkont         = gv_hkont.
        ls_detail-wrbtrt        = gs_header-totalt.
        APPEND ls_detail TO gt_detail.

        lwa_control_option-no_close = space.

        CALL FUNCTION lv_funcname
          EXPORTING
            output_options     = lwa_output_option
            control_parameters = lwa_control_option
            user_settings      = 'X'
            gs_header          = gs_header
          TABLES
            gt_window3         = gt_window3
            gt_detail          = gt_detail
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM_NEW

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_NOMOR
*&---------------------------------------------------------------------*
FORM f_modify_nomor  USING    fu_bukrs fu_vkbur fu_shkzg
                              fu_kdvch fu_nmvch fu_spmon
                              fu_nomor.
  IF gv_lock IS INITIAL.
    UPDATE zf63nomor SET nomor = fu_nomor
                     WHERE bukrs  = fu_bukrs
                       AND vkbur  = fu_vkbur
                       AND shkzg  = fu_shkzg
                       AND nmvch  = fu_nmvch
                       AND spmon  = fu_spmon.
    CLEAR : gv_lock.
    CALL FUNCTION 'DEQUEUE_ALL'.
  ENDIF.
ENDFORM.                    " F_MODIFY_NOMOR

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  CHANGING fc_shkzg.
  DATA : ls_save   LIKE LINE OF gt_save,
         ls_detail LIKE LINE OF gt_detail,
         lv_flag,
         lv_total  TYPE zfexpense-total,
         in_words  TYPE spell,
         lv_waers  TYPE zfexpense-waers,
         lv_langu  TYPE sy-langu VALUE 'id'.

  CLEAR : gt_detail[].

  LOOP AT gt_save INTO ls_save.
    IF lv_flag IS INITIAL.
      lv_flag = selected.
      ls_detail-hkont   = '0141130000'.
    ENDIF.

    IF ls_save-text IS INITIAL.
      ls_detail-description   = ls_save-description.
    ELSE.
      CONCATENATE ls_save-description '-' ls_save-text INTO ls_detail-description
      SEPARATED BY space.
    ENDIF.

    WRITE ls_save-wrbtr TO ls_detail-wrbtrt CURRENCY ls_save-waers.
    CONDENSE ls_detail-wrbtrt NO-GAPS.
    IF ls_save-shkzg  = 'H'.
      CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt
      SEPARATED BY space.
    ENDIF.
    ADD ls_save-wrbtr TO lv_total.
    lv_waers  = ls_save-waers.
    APPEND ls_detail TO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  WRITE lv_total TO gs_header-totalt CURRENCY lv_waers.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_total
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
  TRANSLATE gs_header-terbilang TO UPPER CASE.
ENDFORM.                    " F_PREPARE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63B_6
*&---------------------------------------------------------------------*
FORM f_get_zf63b_6 .
  DATA : lv_uname TYPE sy-uname,
         lv_lifnr TYPE lfa1-lifnr.
  DATA : lt_trnhdr TYPE STANDARD TABLE OF zf63trnhdr INITIAL SIZE 0,
         ls_trnhdr LIKE LINE OF lt_trnhdr.

  PERFORM f_lock_table USING 'ENQUEUE_EZF63TRNVCH' 'ZF63TRNVCH'
                             pa_bukrs pa_gsber pa_vkbur pa_gtype
                             pa_zidvc ''
                       CHANGING lv_uname.

  IF lv_uname IS INITIAL.
    SELECT *
      FROM ska1
      INTO CORRESPONDING FIELDS OF TABLE gt_ska1.

    SELECT *
      FROM zf63trnvch
      INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
      WHERE bukrs     = pa_bukrs
        AND gsber     = pa_gsber
        AND vkbur     = pa_vkbur
        AND gtype     = pa_gtype
        AND zidvc     = pa_zidvc
        AND vjahr     = pa_vjahr
        AND belnr     = space
        AND belnrpadv = space.

    IF gt_trnvch[] IS NOT INITIAL.
      SELECT *
        FROM zf63trnhdr
        INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
        FOR ALL ENTRIES IN gt_trnvch
        WHERE bukrs     = pa_bukrs
          AND gsber     = pa_gsber
          AND vkbur     = pa_vkbur
          AND gtype     = pa_gtype
          AND zidvc     = gt_trnvch-zidvc
          AND gjahr     = gt_trnvch-vjahr.

      CLEAR : lt_trnhdr[], lt_trnhdr.
      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur gtype zidno.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr
      COMPARING bukrs gsber vkbur gtype zidno.

      IF gs_gtype-advance IS INITIAL.
        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs = lt_trnhdr-bukrs
              AND gsber = lt_trnhdr-gsber
              AND vkbur = lt_trnhdr-vkbur
*                  AND gtype = lt_trnhdr-gtype
              AND zidno = lt_trnhdr-zidno.
        ENDIF.
      ELSE.
        IF lt_trnhdr[] IS NOT INITIAL.
          READ TABLE lt_trnhdr INTO ls_trnhdr INDEX 1.
          IF sy-subrc = 0.
            lv_lifnr  = ls_trnhdr-zidno.
          ENDIF.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstp
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs = lt_trnhdr-bukrs
              AND gsber = lt_trnhdr-gsber
              AND vkbur = lt_trnhdr-vkbur
              AND lifnr = lv_lifnr.
        ENDIF.
      ENDIF.

      CLEAR : lt_trnhdr[], lt_trnhdr.
      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur gtype expnr gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr
      COMPARING bukrs gsber vkbur gtype expnr gjahr.

      IF lt_trnhdr[] IS NOT INITIAL.
        SELECT *
          FROM zf63trndtl
          INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE bukrs   = pa_bukrs
            AND gsber   = pa_gsber
            AND vkbur   = pa_vkbur
            AND gtype   = pa_gtype
            AND expnr   = lt_trnhdr-expnr
            AND gjahr   = lt_trnhdr-gjahr.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE s000(zab) WITH 'Transaction lock by' lv_uname
    DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_GET_ZF63B_6

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63N_6
*&---------------------------------------------------------------------*
FORM f_get_zf63n_6 .
  DATA : lv_lifnr        TYPE lfa1-lifnr.
  DATA : lt_trnhdr2 TYPE STANDARD TABLE OF zf63trnhdr2 INITIAL SIZE 0,
         ls_trnhdr2 LIKE LINE OF lt_trnhdr2.

  SELECT *
    FROM zf63trnhdr2
    INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr2
    WHERE bukrs     = pa_bukrs
      AND gsber     = pa_gsber
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND zidvc     = pa_zidv2
      AND gjahr     = pa_vjahr
      AND userpost  = space.
  IF p_timdes = 'X'.
    IF gt_trnhdr2[] IS INITIAL.
      SELECT SINGLE *
        FROM zf63trnhdr2
        INTO CORRESPONDING FIELDS OF ls_trnhdr2
        WHERE bukrs     = pa_bukrs
          AND gsber     = pa_gsber
          AND vkbur     = pa_vkbur
          AND gtype     = pa_gtype
          AND zidvc     = pa_zidv2
          AND gjahr     = pa_vjahr.
      "      AND userpost  = space.
      IF sy-subrc EQ 0.
        "        PERFORM f_send_api_to_timdes USING 'MDS_POSTADVUJP' ls_trnhdr2-transaction_id ls_trnhdr2-zidvc ls_trnhdr2-belnrpadv  ls_trnhdr2-budatpadv.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR : lt_trnhdr2[], lt_trnhdr2.
  lt_trnhdr2[] = gt_trnhdr2[].
  SORT lt_trnhdr2 BY bukrs gsber vkbur gtype zidno.
  DELETE ADJACENT DUPLICATES FROM lt_trnhdr2
  COMPARING bukrs gsber vkbur gtype zidno.

  IF lt_trnhdr2[] IS NOT INITIAL.
    IF gs_gtype-advance IS INITIAL.
      IF lt_trnhdr2[] IS NOT INITIAL.
        SELECT *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF TABLE gt_mstp
          FOR ALL ENTRIES IN lt_trnhdr2
          WHERE bukrs = lt_trnhdr2-bukrs
            AND gsber = lt_trnhdr2-gsber
            AND vkbur = lt_trnhdr2-vkbur
            AND zidno = lt_trnhdr2-zidno.
      ENDIF.
    ELSE.
      IF lt_trnhdr2[] IS NOT INITIAL.
        READ TABLE lt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
        IF sy-subrc = 0.
          lv_lifnr  = ls_trnhdr2-zidno.
        ENDIF.
        SELECT *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF TABLE gt_mstp
          FOR ALL ENTRIES IN lt_trnhdr2
          WHERE bukrs = lt_trnhdr2-bukrs
            AND gsber = lt_trnhdr2-gsber
            AND vkbur = lt_trnhdr2-vkbur
            AND lifnr = lv_lifnr.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_trnhdr2[] IS NOT INITIAL.
    SELECT *
      FROM zf63trndtl2
      INTO CORRESPONDING FIELDS OF TABLE gt_trndtl2
      FOR ALL ENTRIES IN gt_trnhdr2
      WHERE bukrs     = gt_trnhdr2-bukrs
        AND gsber     = gt_trnhdr2-gsber
        AND vkbur     = gt_trnhdr2-vkbur
        AND gtype     = gt_trnhdr2-gtype
        AND zidvc     = gt_trnhdr2-zidvc
        AND gjahr     = gt_trnhdr2-gjahr.

    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_trnhdr2
      WHERE bukrs = gt_trnhdr2-bukrs
        AND belnr = gt_trnhdr2-adv_belnr
        AND gjahr = gt_trnhdr2-adv_gjahr.
  ENDIF.
ENDFORM.                    " F_GET_ZF63N_6

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63B_6
*&---------------------------------------------------------------------*
FORM f_process_zf63b_6 .
  DATA : lt_trnhdr TYPE STANDARD TABLE OF zf63trnhdr
                    INITIAL SIZE 0,
         lt_trndtl TYPE STANDARD TABLE OF zf63trndtl
                    INITIAL SIZE 0.

  DATA : ls_typeexp LIKE LINE OF gt_typeexp,
         ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_mstp    LIKE LINE OF gt_mstp,
         ls_trnvch  LIKE LINE OF gt_trnvch,
         ls_trndtl  LIKE LINE OF gt_trndtl,
         ls_out     LIKE LINE OF gt_out,
         ls_accexp  LIKE LINE OF gt_accexp,
         ls_bsik    LIKE LINE OF gt_bsik.

  DATA : lv_tabix TYPE sy-tabix,
         lv_error,
         lv_stat  TYPE icon_d,
         lv_bktxt TYPE bkpf-bktxt.

  IF gt_trndtl[] IS NOT INITIAL.
    LOOP AT gt_trndtl INTO gs_trndtl.
      gv_tabix  = sy-tabix.
      READ TABLE gt_typeexp INTO ls_typeexp
                            WITH KEY bukrs = gs_trndtl-bukrs
                                     gtype = gs_trndtl-gtype
                                     type  = gs_trndtl-type.
      IF sy-subrc = 0.
        IF ls_typeexp-ztext IS NOT INITIAL.
          zfexpense-text   = gs_trndtl-text.
        ENDIF.
        IF ls_typeexp-zvbund IS NOT INITIAL.
          zfexpense-vbund  = gs_trndtl-vbund.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CALL SCREEN 809 STARTING AT 10 10.

    IF gv_execute IS NOT INITIAL.
      CLEAR ls_trnhdr.
      READ TABLE gt_trnhdr INTO ls_trnhdr INDEX 1.
      IF sy-subrc = 0.
        CLEAR ls_mstp.
        IF gs_gtype-advance IS INITIAL.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
*                                          gtype = ls_trnhdr-gtype
                                      zidno = ls_trnhdr-zidno.
        ELSE.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
                                      lifnr = ls_trnhdr-zidno.
        ENDIF.
      ENDIF.

      CLEAR ls_trnvch.
      READ TABLE gt_trnvch INTO ls_trnvch INDEX 1.
      IF sy-subrc = 0.
        SORT gt_trndtl BY type.
        CLEAR ls_trndtl.
        LOOP AT gt_trndtl INTO ls_trndtl.
          CLEAR : ls_trndtl-expnr, ls_trndtl-buzei, ls_trndtl-speed,
                  ls_trndtl-kmstr, ls_trndtl-kmend.
          COLLECT ls_trndtl INTO lt_trndtl.
*              CLEAR ls_trndtl.
        ENDLOOP.

        IF gs_gtype-advance IS NOT INITIAL.
          CLEAR : gv_buzei.
          PERFORM f_document_header USING    'RFBU' gs_gtype-blart
                                             ls_trnvch-bktxt pa_xbln2
                                    CHANGING advdh.

          PERFORM f_prepare_posting USING gs_gtype-blart pa_xbln2
                                          gs_gtype-adv_bschl
                                          gs_gtype-umskz
                                          ls_trnhdr-zidno ls_trnvch-hkont ''
                                          ls_trnvch ls_trndtl ''.

          PERFORM f_prepare_posting USING gs_gtype-blart pa_xbln2 gs_gtype-bschl ''
                                          ls_trnhdr-zidno ls_trnvch-hkont ''
                                          ls_trnvch ls_trndtl ''.

          LOOP AT gt_out INTO ls_out WHERE post IS INITIAL.
            lv_tabix  = sy-tabix.
            CASE ls_out-koart.
              WHEN 'S'.
                PERFORM f_account_gl TABLES   advgl advca advex advcr
                                     USING    ls_out ls_mstp-name1 ls_trnhdr-znopol
                                              gs_gtype-blart ls_trnvch-bktxt ''.
              WHEN 'K'.
                PERFORM f_account_payable TABLES   advap advca advex advcr
                                          USING    ls_out ls_mstp-name1 ls_trnvch-bktxt ''.
              WHEN 'D'.
                PERFORM f_account_receivable TABLES  advar advca advex advcr
                                             USING   ls_out.
            ENDCASE.
            ls_out-post   = 2.
            MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
          ENDLOOP.

          PERFORM f_bapi_simulate TABLES   advgl advap advar
                                           advca advex advcr
                                  USING    advdh
                                  CHANGING lv_error.

          IF lv_stat <> icon_led_red.
            IF lv_error IS NOT INITIAL.
              lv_stat   = icon_led_red.
            ELSE.
              lv_stat   = icon_led_green.
            ENDIF.
          ENDIF.

          LOOP AT gt_out INTO ls_out.
            ls_out-icon = lv_stat.
            MODIFY gt_out FROM ls_out TRANSPORTING icon.
          ENDLOOP.
        ELSE.
          PERFORM f_document_header USING    'RFBU' gs_gtype-blart
                                             ls_trnvch-bktxt pa_xbln1
                                    CHANGING dh.

          PERFORM f_prepare_posting USING gs_gtype-blart pa_xbln1 gs_gtype-bschl
                                          '' ls_mstp-lifnr ls_trnvch-hkont ''
                                          ls_trnvch ls_trndtl 'ZF63TRNVCH'.

          CLEAR ls_trndtl.
          LOOP AT lt_trndtl INTO ls_trndtl.
            CLEAR ls_typeexp.
            READ TABLE gt_typeexp INTO ls_typeexp
                                  WITH KEY type = ls_trndtl-type.
            IF sy-subrc = 0.
              CLEAR ls_accexp.
              READ TABLE gt_accexp INTO ls_accexp
                                   WITH KEY acctype = ls_typeexp-acctype
                                            zmejl   = gs_gtype-memojurnal.
            ENDIF.

            PERFORM f_prepare_posting USING gs_gtype-blart pa_xbln1 ls_accexp-bschl
                                            '' ls_mstp-lifnr ls_accexp-hkont
                                            ls_typeexp-acctype
                                            ls_trnvch ls_trndtl 'ZF63TRNDTL'.
          ENDLOOP.

          LOOP AT gt_out INTO ls_out.
            lv_tabix  = sy-tabix.
            CASE ls_out-koart.
              WHEN 'S'.
                PERFORM f_account_gl TABLES   gl ca ex cr
                                     USING    ls_out ls_mstp-name1
                                              ls_trnhdr-znopol gs_gtype-blart
                                              ls_trnvch-bktxt ''.
              WHEN 'K'.
                PERFORM f_account_payable TABLES   ap ca ex cr
                                          USING    ls_out '' ls_trnvch-bktxt ''.
              WHEN 'D'.
                PERFORM f_account_receivable TABLES   ar ca ex cr
                                             USING    ls_out.
            ENDCASE.
            ls_out-post   = 1.
            MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
          ENDLOOP.

          PERFORM f_bapi_simulate TABLES   gl ap ar ca ex cr
                                  USING    dh
                                  CHANGING lv_error.
          IF lv_error IS NOT INITIAL.
            lv_stat   = icon_led_red.
          ELSE.
            lv_stat   = icon_led_green.
          ENDIF.

          IF ls_trnvch-adv_belnr IS NOT INITIAL.
            CLEAR : gv_buzei.
            PERFORM f_get_bsik USING pa_bukrs ls_mstp-lifnr 'C'
                                     ls_trnvch-adv_gjahr ls_trnvch-adv_belnr
                                     pa_gsber ''.

            READ TABLE gt_bsik INTO ls_bsik INDEX 1.
            IF sy-subrc = 0.
              CONCATENATE 'PENY' ls_bsik-sgtxt INTO lv_bktxt
              SEPARATED BY space.
            ENDIF.
            PERFORM f_document_header USING    'RFBU' gs_gtype-adv_blart
                                               lv_bktxt pa_xbln2
                                      CHANGING advdh.

            PERFORM f_prepare_posting USING gs_gtype-adv_blart pa_xbln2
                                            gs_gtype-adv_bschl
                                            gs_gtype-umskz
                                            ls_mstp-lifnr ls_trnvch-hkont ''
                                            ls_trnvch ls_trndtl 'BSIK'.

            PERFORM f_prepare_posting USING gs_gtype-adv_blart pa_xbln2 '40' ''
                                            ls_mstp-lifnr ls_trnvch-hkont ''
                                            ls_trnvch ls_trndtl 'BSIK'.

            LOOP AT gt_out INTO ls_out WHERE post IS INITIAL.
              lv_tabix  = sy-tabix.
              CASE ls_out-koart.
                WHEN 'S'.
                  PERFORM f_account_gl TABLES   advgl advca advex advcr
                                       USING    ls_out ls_mstp-name1 ls_trnhdr-znopol
                                                gs_gtype-adv_blart ls_bsik-sgtxt ''.
                WHEN 'K'.
                  PERFORM f_account_payable TABLES   advap advca advex advcr
                                            USING    ls_out ls_mstp-name1 ls_bsik-sgtxt ''.
                WHEN 'D'.
                  PERFORM f_account_receivable TABLES  advar advca advex advcr
                                               USING   ls_out.
              ENDCASE.
              ls_out-post   = 2.
              MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
            ENDLOOP.

            PERFORM f_bapi_simulate TABLES   advgl advap advar
                                             advca advex advcr
                                    USING    advdh
                                    CHANGING lv_error.

            IF lv_stat <> icon_led_red.
              IF lv_error IS NOT INITIAL.
                lv_stat   = icon_led_red.
              ELSE.
                lv_stat   = icon_led_green.
              ENDIF.
            ENDIF.

            LOOP AT gt_out INTO ls_out.
              ls_out-icon = lv_stat.
              MODIFY gt_out FROM ls_out TRANSPORTING icon.
            ENDLOOP.
          ELSE.
            LOOP AT gt_out INTO ls_out.
              ls_out-icon = lv_stat.
              MODIFY gt_out FROM ls_out TRANSPORTING icon.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PROCESS_ZF63B_6

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63N_6
*&---------------------------------------------------------------------*
FORM f_process_zf63n_6 .
  DATA : lt_trndtl2  TYPE STANDARD TABLE OF zf63trndtl2
                     INITIAL SIZE 0.

  DATA : ls_typeexp LIKE LINE OF gt_typeexp,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_mstp    LIKE LINE OF gt_mstp,
         ls_out     LIKE LINE OF gt_out,
         ls_trndtl2 LIKE LINE OF gt_trndtl2,
         ls_accexp  LIKE LINE OF gt_accexp.

  DATA : lv_tabix TYPE sy-tabix,
         lv_error,
         lv_stat  TYPE icon_d,
         lv_post  TYPE i.

  IF gt_trndtl2[] IS NOT INITIAL.
    LOOP AT gt_trndtl2 INTO gs_trndtl2.
      gv_tabix  = sy-tabix.
      READ TABLE gt_typeexp INTO ls_typeexp
                            WITH KEY bukrs = gs_trndtl2-bukrs
                                     gtype = gs_trndtl2-gtype
                                     type  = gs_trndtl2-type.
      IF sy-subrc = 0.
        IF ls_typeexp-ztext IS NOT INITIAL.
          zfexpense-text   = gs_trndtl2-text.
        ENDIF.
        IF ls_typeexp-zvbund IS NOT INITIAL.
          zfexpense-vbund  = gs_trndtl2-vbund.
          EXIT.
        ENDIF.
      ENDIF.
      ls_trndtl2-text = gs_trndtl2-text.
      APPEND ls_trndtl2 TO lt_trndtl2.
    ENDLOOP.

    SORT lt_trndtl2 BY text.
    DELETE lt_trndtl2 WHERE text = space.
    DELETE ADJACENT DUPLICATES FROM lt_trndtl2 COMPARING text.
    CLEAR : gv_lines.
    DESCRIBE TABLE lt_trndtl2 LINES gv_lines.
    CLEAR : lt_trndtl2[], lt_trndtl2.
    CLEAR ls_trnhdr2.
    READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
    IF sy-subrc = 0.
      IF gs_gtype-advance IS INITIAL.
        IF ls_trnhdr2-adv_belnr IS INITIAL.
          lv_post = 1.
        ELSE.
          lv_post = 2.
          "           IF p_timdes = 'X'.
          IF pa_gtype = '20' AND p_timdes = 'X'.
            pa_xbln1 = ls_trnhdr2-xblnrexp.
            pa_xbln2 = ls_trnhdr2-xblnradv.
            pa_budat = ls_trnhdr2-budatpexp.
            zfexpense-text = ls_trnhdr2-bktxt.
            "                CALL SCREEN 809 STARTING AT 10 10.
          ENDIF.
          "           ENDIF.
        ENDIF.
      ELSE.
        lv_post = 2.
        "         IF p_timdes = 'X'.
        IF pa_gtype = '15' AND p_timdes = 'X'.
          pa_budat = ls_trnhdr2-budatpadv.
          pa_xbln2 = ls_trnhdr2-xblnradv.
          zfexpense-text = ls_trnhdr2-bktxt.
        ENDIF.
        "            CALL SCREEN 809 STARTING AT 10 10.
        "         ENDIF.
      ENDIF.

    ENDIF.

    IF p_timdes = 'X'.
      gv_execute = 'X'.
      "      pa_xbln2 = '223123132'.
      "      pa_budat = '20250101'.
      "      zfexpense-text = 'BIAYA PDLK fg'.
      "      CALL SCREEN 809 STARTING AT 10 10.
    ELSE.
      CALL SCREEN 809 STARTING AT 10 10.
    ENDIF.

    IF gv_execute IS NOT INITIAL.
      CLEAR ls_trnhdr2.
      READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
      IF sy-subrc = 0.
        IF gs_gtype-advance IS INITIAL.
          IF ls_trnhdr2-adv_belnr IS INITIAL.
            lv_post = 1.
          ELSE.
            lv_post = 2.
            "           IF p_timdes = 'X'.
            IF pa_gtype = '24' AND p_timdes = 'X'.
              pa_xbln1 = ls_trnhdr2-xblnrexp.
              pa_xbln2 = ls_trnhdr2-xblnradv.
              pa_budat = ls_trnhdr2-budatpexp.
              zfexpense-text = ls_trnhdr2-bktxt.
              "                CALL SCREEN 809 STARTING AT 10 10.
            ENDIF.
            "           ENDIF.
          ENDIF.
        ELSE.
          lv_post = 2.
          "         IF p_timdes = 'X'.
          IF pa_gtype = '12' AND p_timdes = 'X'.
            pa_budat = ls_trnhdr2-budatpadv.
            pa_xbln2 = ls_trnhdr2-xblnradv.
            zfexpense-text = ls_trnhdr2-bktxt.
          ENDIF.
          "            CALL SCREEN 809 STARTING AT 10 10.
          "         ENDIF.
        ENDIF.

        READ TABLE gt_mstp INTO ls_mstp
                           WITH KEY bukrs = ls_trnhdr2-bukrs
                                    gsber = ls_trnhdr2-gsber
                                    vkbur = ls_trnhdr2-vkbur
                                    lifnr = ls_trnhdr2-zidno.
        IF sy-subrc <> 0.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY bukrs = ls_trnhdr2-bukrs
                                      gsber = ls_trnhdr2-gsber
                                      vkbur = ls_trnhdr2-vkbur
                                      zidno = ls_trnhdr2-zidno.
        ENDIF.

*        IF ls_trnhdr2-zidvc IS NOT INITIAL.
*          lv_post = 1.
*        ENDIF.
*        IF ls_trnhdr2-zidvc2 IS NOT INITIAL.
*          lv_post = 2.
*        ENDIF.
*        CLEAR ls_mstp.
*        IF gs_gtype-advance IS INITIAL.
*          CASE lv_post.
*            WHEN 1.
*              READ TABLE gt_mstp INTO ls_mstp
*                                 WITH KEY bukrs = ls_trnhdr2-bukrs
*                                          gsber = ls_trnhdr2-gsber
*                                          vkbur = ls_trnhdr2-vkbur
*                                          lifnr = ls_trnhdr2-zidno.
*
*            WHEN 2.
*              READ TABLE gt_mstp INTO ls_mstp
*                                 WITH KEY bukrs = ls_trnhdr2-bukrs
*                                          gsber = ls_trnhdr2-gsber
*                                          vkbur = ls_trnhdr2-vkbur
*                                          zidno = ls_trnhdr2-zidno.
*          ENDCASE.
*        ELSE.
*          READ TABLE gt_mstp INTO ls_mstp
*                             WITH KEY bukrs = ls_trnhdr2-bukrs
*                                      gsber = ls_trnhdr2-gsber
*                                      vkbur = ls_trnhdr2-vkbur
*                                      lifnr = ls_trnhdr2-zidno.
*        ENDIF.
      ENDIF.

      SORT gt_trndtl2 BY type.
      CLEAR ls_trndtl2.
      LOOP AT gt_trndtl2 INTO ls_trndtl2.
        CLEAR : ls_trndtl2-buzei.
*        CLEAR : ls_trndtl2-speed, ls_trndtl2-kmstr, ls_trndtl2-kmend.
        COLLECT ls_trndtl2 INTO lt_trndtl2.
      ENDLOOP.

      IF gs_gtype-advance IS NOT INITIAL.
        CLEAR : gv_buzei.
        PERFORM f_document_header USING    'RFBU' gs_gtype-blart
                                           ls_trnhdr2-bktxt pa_xbln2
                                  CHANGING advdh.

        PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln2
                                         gs_gtype-adv_bschl
                                         gs_gtype-umskz
                                         ls_trnhdr2-zidno ls_trnhdr2-hkont ''
                                         ls_trnhdr2 ls_trndtl2 ''.

        PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln2
                                         gs_gtype-bschl ''
                                         ls_trnhdr2-zidno ls_trnhdr2-hkont ''
                                         ls_trnhdr2 ls_trndtl2 ''.

        LOOP AT gt_out INTO ls_out WHERE post IS INITIAL.
          lv_tabix  = sy-tabix.
          CASE ls_out-koart.
            WHEN 'S'.
              PERFORM f_account_gl TABLES   advgl advca advex advcr
                                   USING    ls_out ls_mstp-name1 '' "ls_trnhdr2-znopol
                                            gs_gtype-blart ls_trnhdr2-bktxt ''.
            WHEN 'K'.
              PERFORM f_account_payable TABLES   advap advca advex advcr
                                        USING    ls_out ls_mstp-name1 ls_trnhdr2-bktxt ''.
            WHEN 'D'.
              PERFORM f_account_receivable TABLES  advar advca advex advcr
                                           USING   ls_out.
          ENDCASE.
          ls_out-post   = 2.
          MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
        ENDLOOP.

        PERFORM f_bapi_simulate TABLES   advgl advap advar
                                         advca advex advcr
                                USING    advdh
                                CHANGING lv_error.

        IF lv_stat <> icon_led_red.
          IF lv_error IS NOT INITIAL.
            lv_stat   = icon_led_red.
          ELSE.
            lv_stat   = icon_led_green.
          ENDIF.
        ENDIF.

        LOOP AT gt_out INTO ls_out.
          ls_out-icon = lv_stat.
          MODIFY gt_out FROM ls_out TRANSPORTING icon.
        ENDLOOP.
      ELSE.
        CASE lv_post.
          WHEN 1.
            PERFORM f_document_header USING    'RFBU' gs_gtype-blart
                                               ls_trnhdr2-bktxt pa_xbln1
                                      CHANGING dh.

            PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln1 gs_gtype-bschl
                                             '' ls_mstp-lifnr ls_trnhdr2-hkont ''
                                             ls_trnhdr2 ls_trndtl2 'ZF63TRNHDR2'.

            CLEAR ls_trndtl2.
            LOOP AT lt_trndtl2 INTO ls_trndtl2.
              CLEAR ls_typeexp.
              READ TABLE gt_typeexp INTO ls_typeexp
                                    WITH KEY type = ls_trndtl2-type.
              IF sy-subrc = 0.
                CLEAR ls_accexp.
                READ TABLE gt_accexp INTO ls_accexp
                                     WITH KEY acctype = ls_typeexp-acctype
                                              zmejl   = gs_gtype-memojurnal.
              ENDIF.

              IF gv_lines = 1.
                IF ls_trndtl2-text IS NOT INITIAL.
                  ls_trndtl2-text = zfexpense-text.
                ENDIF.
              ENDIF.

              PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln1 ls_accexp-bschl
                                               '' ls_mstp-lifnr ls_accexp-hkont
                                               ls_typeexp-acctype
                                               ls_trnhdr2 ls_trndtl2 'ZF63TRNDTL2'.
            ENDLOOP.

            LOOP AT gt_out INTO ls_out.
              lv_tabix  = sy-tabix.
              CASE ls_out-koart.
                WHEN 'S'.
                  PERFORM f_account_gl TABLES   gl ca ex cr
                                       USING    ls_out ls_mstp-name1
                                                ls_out-znopol gs_gtype-blart
                                                ls_trnhdr2-bktxt ''.
                WHEN 'K'.
                  PERFORM f_account_payable TABLES   ap ca ex cr
                                            USING    ls_out '' ls_trnhdr2-bktxt ''.
                WHEN 'D'.
                  PERFORM f_account_receivable TABLES   ar ca ex cr
                                               USING    ls_out.
              ENDCASE.
              ls_out-post   = 1.
              MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
            ENDLOOP.

            PERFORM f_bapi_simulate TABLES   gl ap ar ca ex cr
                                    USING    dh
                                    CHANGING lv_error.
            IF lv_error IS NOT INITIAL.
              lv_stat   = icon_led_red.
            ELSE.
              lv_stat   = icon_led_green.
            ENDIF.

            LOOP AT gt_out INTO ls_out.
              ls_out-icon = lv_stat.
              MODIFY gt_out FROM ls_out TRANSPORTING icon.
            ENDLOOP.

          WHEN 2.
            PERFORM f_document_header USING    'RFBU' gs_gtype-blart
                                               ls_trnhdr2-bktxt pa_xbln1
                                      CHANGING dh.

            PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln1 gs_gtype-bschl
                                             '' ls_mstp-lifnr ls_trnhdr2-hkont ''
                                             ls_trnhdr2 ls_trndtl2 'ZF63TRNHDR2'.

            CLEAR ls_trndtl2.
            LOOP AT lt_trndtl2 INTO ls_trndtl2.
              CLEAR ls_typeexp.
              READ TABLE gt_typeexp INTO ls_typeexp
                                    WITH KEY type = ls_trndtl2-type.
              IF sy-subrc = 0.
                CLEAR ls_accexp.
                READ TABLE gt_accexp INTO ls_accexp
                                     WITH KEY acctype = ls_typeexp-acctype
                                              zmejl   = gs_gtype-memojurnal.
              ENDIF.

              PERFORM f_prepare_posting2 USING gs_gtype-blart pa_xbln1 ls_accexp-bschl
                                               '' ls_mstp-lifnr ls_accexp-hkont
                                               ls_typeexp-acctype
                                               ls_trnhdr2 ls_trndtl2 'ZF63TRNDTL2'.
            ENDLOOP.

            LOOP AT gt_out INTO ls_out.
              lv_tabix  = sy-tabix.
              CASE ls_out-koart.
                WHEN 'S'.
                  PERFORM f_account_gl TABLES   gl ca ex cr
                                       USING    ls_out ls_mstp-name1
                                                ls_out-znopol gs_gtype-blart
                                                ls_trnhdr2-bktxt ''.
                WHEN 'K'.
                  PERFORM f_account_payable TABLES   ap ca ex cr
                                            USING    ls_out '' ls_trnhdr2-bktxt ''.
                WHEN 'D'.
                  PERFORM f_account_receivable TABLES   ar ca ex cr
                                               USING    ls_out.
              ENDCASE.
              ls_out-post   = 1.
              MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
            ENDLOOP.

            PERFORM f_bapi_simulate TABLES   gl ap ar ca ex cr
                                    USING    dh
                                    CHANGING lv_error.
            IF lv_error IS NOT INITIAL.
              lv_stat   = icon_led_red.
            ELSE.
              lv_stat   = icon_led_green.
            ENDIF.
*--------------------------------------------------------------------*

            CLEAR : gv_buzei.
            PERFORM f_document_header USING    'RFBU' gs_gtype-adv_blart
                                               ls_trnhdr2-bktxt pa_xbln2
                                      CHANGING advdh.

            PERFORM f_prepare_posting2 USING gs_gtype-adv_blart pa_xbln2
                                             gs_gtype-adv_bschl
                                             gs_gtype-umskz
                                             ls_mstp-lifnr ls_trnhdr2-hkont ''
                                             ls_trnhdr2 ls_trndtl2 'BSIK'.

            PERFORM f_prepare_posting2 USING gs_gtype-adv_blart pa_xbln2
                                             '40' ''
                                             ls_mstp-lifnr ls_trnhdr2-hkont ''
                                             ls_trnhdr2 ls_trndtl2 'BSIK'.

            LOOP AT gt_out INTO ls_out WHERE post IS INITIAL.
              lv_tabix  = sy-tabix.
              CASE ls_out-koart.
                WHEN 'S'.
                  PERFORM f_account_gl TABLES   advgl advca advex advcr
                                       USING    ls_out ls_mstp-name1 '' "ls_trnhdr2-znopol
                                                gs_gtype-adv_blart ls_trnhdr2-bktxt ''.
                WHEN 'K'.
                  PERFORM f_account_payable TABLES   advap advca advex advcr
                                            USING    ls_out ls_mstp-name1 ls_trnhdr2-bktxt ''.
                WHEN 'D'.
                  PERFORM f_account_receivable TABLES  advar advca advex advcr
                                               USING   ls_out.
              ENDCASE.
              ls_out-post   = 2.
              MODIFY gt_out FROM ls_out INDEX lv_tabix TRANSPORTING post.
            ENDLOOP.

            PERFORM f_bapi_simulate TABLES   advgl advap advar
                                             advca advex advcr
                                    USING    advdh
                                    CHANGING lv_error.

            IF lv_stat <> icon_led_red.
              IF lv_error IS NOT INITIAL.
                lv_stat   = icon_led_red.
              ELSE.
                lv_stat   = icon_led_green.
              ENDIF.
            ENDIF.

            LOOP AT gt_out INTO ls_out.
              ls_out-icon = lv_stat.
              MODIFY gt_out FROM ls_out TRANSPORTING icon.
            ENDLOOP.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PROCESS_ZF63N_6

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING2
*&---------------------------------------------------------------------*
FORM f_prepare_posting2  USING   fu_blart fu_xblnr fu_bschl fu_umskz
                                 fu_lifnr fu_hkont fu_acctype
                                 fs_trnhdr2  LIKE LINE OF gt_trnhdr2
                                 fs_trndtl2  LIKE LINE OF gt_trndtl2
                                 fu_tabnm.

  DATA : ls_out      LIKE LINE OF gt_out,
         ls_tbsl     LIKE LINE OF gt_tbsl,
         ls_bsik     LIKE LINE OF gt_bsik,
         ls_kostlexp LIKE LINE OF gt_kostlexp.

  DATA : ls_trnvch LIKE LINE OF gt_trnvch,
         ls_trndtl LIKE LINE OF gt_trndtl.

  ADD 1 TO gv_buzei.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = fu_bschl.

  ls_out-buzei         = gv_buzei.
  ls_out-blart         = fu_blart.
  ls_out-xblnr         = fu_xblnr.
  ls_out-bschl         = fu_bschl.
  ls_out-shkzg         = ls_tbsl-shkzg.
  ls_out-umskz         = fu_umskz.
  ls_out-gsber         = pa_gsber.
  ls_out-koart         = ls_tbsl-koart.
  ls_out-xref3         = fs_trnhdr2-zidvc.
  IF fu_hkont = '0112100020'.
    ls_out-text          = fs_trnhdr2-bktxt.
  ELSE.
    ls_out-text          = fs_trndtl2-text.
  ENDIF.

  CASE fu_tabnm.
    WHEN 'ZF63TRNDTL' OR 'ZF63TRNDTL2'.
      ls_out-description   = fs_trndtl2-description.
      ls_out-zuonr         = fu_xblnr.
      ls_out-menge         = fs_trndtl2-menge.
      ls_out-meins         = fs_trndtl2-meins.
      ls_out-vbund         = fs_trndtl2-vbund.
      ls_out-znopol        = fs_trndtl2-znopol.
      ls_out-kmstr         = fs_trndtl2-kmstr.
      ls_out-kmend         = fs_trndtl2-kmend.
      ls_out-speed         = fs_trndtl2-speed.
    WHEN 'ZF63TRNVCH'.
      ls_out-description   = fs_trnhdr2-bktxt.
      ls_out-zuonr         = fu_xblnr.
    WHEN 'BSIK'.
      IF fu_umskz IS INITIAL.
        ls_out-zuonr         = fu_xblnr.
      ELSE.
        CLEAR ls_bsik.
        READ TABLE gt_bsik INTO ls_bsik INDEX 1.
        IF sy-subrc = 0.
          ls_out-zuonr         = ls_bsik-zuonr.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      ls_out-zuonr         = fu_xblnr.
  ENDCASE.

  IF fu_acctype IS NOT INITIAL.
    CLEAR : ls_kostlexp.
    READ TABLE gt_kostlexp INTO ls_kostlexp WITH KEY gsber   = pa_gsber
                                                     vkbur   = pa_vkbur
                                                     gtype   = pa_gtype
                                                     acctype = fu_acctype.
    IF sy-subrc = 0.
      ls_out-kostl  = ls_kostlexp-kostl.
      ls_out-wwsfr  = ls_kostlexp-wwsfr.
      ls_out-wwpos  = ls_kostlexp-wwpos.
    ELSE.
      ls_out-kostl  = fs_trndtl2-kostl.
      ls_out-wwsfr  = fs_trndtl2-wwsfr.
      ls_out-wwpos  = fs_trndtl2-wwpos.
      ls_out-wwpfn  = fs_trndtl2-wwpfn.
    ENDIF.
  ENDIF.

  CASE ls_tbsl-koart.
    WHEN 'S'.
      PERFORM f_conversion_alpha USING    fu_hkont fu_lifnr ls_tbsl-koart
                                 CHANGING ls_out-hkont
                                          ls_out-ktext
                                          ls_out-kostl ls_out-wwpfn
                                          ls_out-wwsfr ls_out-wwpos
                                          ls_out-vbund.

    WHEN 'K'.
      PERFORM f_conversion_alpha USING    fu_hkont fu_lifnr ls_tbsl-koart
                                 CHANGING ls_out-hkont
                                          ls_out-ktext
                                          ls_out-kostl ls_out-wwpfn
                                          ls_out-wwsfr ls_out-wwpos
                                          ls_out-vbund.
    WHEN 'D'.
  ENDCASE.

  PERFORM f_get_amount  USING fu_lifnr fu_tabnm ls_trnvch ls_trndtl
                              fs_trnhdr2 fs_trndtl2
                              ls_tbsl-shkzg
                        CHANGING ls_out-waers ls_out-wrbtr.

  APPEND ls_out TO gt_out.
  CLEAR ls_out.
ENDFORM.                    " F_PREPARE_POSTING2

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ZF63TRNVCH
*&---------------------------------------------------------------------*
FORM f_update_zf63trnvch  USING    fu_post fu_belnr fu_gjahr.
  DATA : lv_xblnr   TYPE zf63trnvch-xblnr.
  CASE fu_post.
    WHEN 1.
      IF gs_gtype-advance IS NOT INITIAL.
        lv_xblnr  = pa_xbln2.
      ELSE.
        lv_xblnr = pa_xbln1.
      ENDIF.

      UPDATE zf63trnvch SET belnr    = fu_belnr
                            gjahr    = fu_gjahr
                            budat    = pa_budat
                            bldat    = pa_budat
                            xblnr    = lv_xblnr
                            userpost = sy-uname
                            tglpost  = sy-datum
                            jampost  = sy-uzeit
                        WHERE bukrs = pa_bukrs
                          AND gsber = pa_gsber
                          AND vkbur = pa_vkbur
                          AND gtype = pa_gtype
                          AND zidvc = pa_zidvc
                          AND vjahr = pa_vjahr.

    WHEN 2.
      UPDATE zf63trnvch SET belnrpadv = fu_belnr
                            gjahrpadv = fu_gjahr
                            budatpadv = pa_budat
                            bldatpadv = pa_budat
                            xblnr     = pa_xbln2
                            userpost  = sy-uname
                            tglpost   = sy-datum
                            jampost   = sy-uzeit
                        WHERE bukrs = pa_bukrs
                          AND gsber = pa_gsber
                          AND vkbur = pa_vkbur
                          AND gtype = pa_gtype
                          AND zidvc = pa_zidvc
                          AND vjahr = pa_vjahr.
  ENDCASE.
ENDFORM.                    " F_UPDATE_ZF63TRNVCH

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ZF63TRNHDR2
*&---------------------------------------------------------------------*
FORM f_update_zf63trnhdr2  USING    fu_post fu_belnr fu_gjahr.
  DATA : lv_xblnr   TYPE zf63trnvch-xblnr.
  CASE fu_post.
    WHEN 1.
      IF gs_gtype-advance IS NOT INITIAL.
        UPDATE zf63trnhdr2 SET belnrpadv = fu_belnr
                               gjahrpadv = fu_gjahr
                               budatpadv = pa_budat
                               bldatpadv = pa_budat
                               xblnradv  = pa_xbln2
                               userpost  = sy-uname
                               tglpost   = sy-datum
                               jampost   = sy-uzeit
                          WHERE bukrs = pa_bukrs
                            AND gsber = pa_gsber
                            AND vkbur = pa_vkbur
                            AND gtype = pa_gtype
                            AND zidvc = pa_zidv2
                            AND gjahr = pa_vjahr.

      ELSE.
        UPDATE zf63trnhdr2 SET belnrpexp = fu_belnr
                               gjahrpexp = fu_gjahr
                               budatpexp = pa_budat
                               bldatpexp = pa_budat
                               xblnrexp  = pa_xbln1
                               userpost  = sy-uname
                               tglpost   = sy-datum
                               jampost   = sy-uzeit
                          WHERE bukrs = pa_bukrs
                            AND gsber = pa_gsber
                            AND vkbur = pa_vkbur
                            AND gtype = pa_gtype
                            AND zidvc = pa_zidv2
                            AND gjahr = pa_vjahr.
      ENDIF.


    WHEN 2.
*      UPDATE zf63trnhdr2 SET belnrpadv = fu_belnr
*                             gjahrpadv = fu_gjahr
*                             budatpadv = pa_budat
*                             bldatpadv = pa_budat
*                             xblnrexp  = pa_xbln2
*                             userpost  = sy-uname
*                             tglpost   = sy-datum
*                             jampost   = sy-uzeit
*                        WHERE bukrs = pa_bukrs
*                          AND gsber = pa_gsber
*                          AND vkbur = pa_vkbur
*                          AND gtype = pa_gtype
*                          AND zidvc = pa_zidvc
*                          AND vjahr = pa_vjahr.
  ENDCASE.
ENDFORM.                    " F_UPDATE_ZF63TRNHDR2

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63B_7
*&---------------------------------------------------------------------*
FORM f_get_zf63b_7 .
  DATA : lt_bkpf   TYPE STANDARD TABLE OF bkpf INITIAL SIZE 0,
         ls_bkpf   LIKE LINE OF lt_bkpf,
         ls_trnvch LIKE LINE OF gt_trnvch.

  SELECT *
    FROM zf63trnvch
    INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
    WHERE bukrs     = pa_bukrs
      AND gsber     = pa_gsber
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND zidvc     = pa_zidvc
      AND vjahr     = pa_vjahr
      AND userrev   = space.

  SELECT *
    FROM zf63trnhdr
    INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
    WHERE bukrs     = pa_bukrs
      AND gsber     = pa_gsber
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND zidvc     = pa_zidvc
      AND gjahr     = pa_vjahr.
  SORT gt_trnhdr BY expnr.
  DELETE ADJACENT DUPLICATES FROM gt_trnhdr COMPARING expnr.

  LOOP AT gt_trnvch INTO ls_trnvch.
    IF ls_trnvch-belnr IS NOT INITIAL.
      ls_bkpf-bukrs = ls_trnvch-bukrs.
      ls_bkpf-belnr = ls_trnvch-belnr.
      ls_bkpf-gjahr = ls_trnvch-gjahr.
      APPEND ls_bkpf TO lt_bkpf.
      CLEAR ls_bkpf.
    ENDIF.
    IF ls_trnvch-belnrpadv IS NOT INITIAL.
      ls_bkpf-bukrs = ls_trnvch-bukrs.
      ls_bkpf-belnr = ls_trnvch-belnrpadv.
      ls_bkpf-gjahr = ls_trnvch-gjahrpadv.
      APPEND ls_bkpf TO lt_bkpf.
      CLEAR ls_bkpf.
    ENDIF.
  ENDLOOP.

  IF lt_bkpf[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr blart
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
      FOR ALL ENTRIES IN lt_bkpf
      WHERE bukrs = lt_bkpf-bukrs
        AND belnr = lt_bkpf-belnr
        AND gjahr = lt_bkpf-gjahr.

    SELECT bukrs belnr gjahr buzei augbl koart lifnr
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FOR ALL ENTRIES IN lt_bkpf
      WHERE bukrs = lt_bkpf-bukrs
        AND belnr = lt_bkpf-belnr
        AND gjahr = lt_bkpf-gjahr.
  ENDIF.
ENDFORM.                    " F_GET_ZF63B_7

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63N_7
*&---------------------------------------------------------------------*
FORM f_get_zf63n_7 .
  DATA : lt_bkpf    TYPE STANDARD TABLE OF bkpf INITIAL SIZE 0,
         ls_bkpf    LIKE LINE OF lt_bkpf,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2.

  SELECT *
    FROM zf63trnhdr2
    INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr2
    WHERE bukrs     = pa_bukrs
      AND gsber     = pa_gsber
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND zidvc     = pa_zidv2
      AND gjahr     = pa_vjahr
      AND ( belnrpadv <> space
       OR   belnrpexp <> space )
      AND userrev   = space.

  LOOP AT gt_trnhdr2 INTO ls_trnhdr2.
    IF ls_trnhdr2-belnrpexp IS NOT INITIAL.
      ls_bkpf-bukrs = ls_trnhdr2-bukrs.
      ls_bkpf-belnr = ls_trnhdr2-belnrpexp.
      ls_bkpf-gjahr = ls_trnhdr2-gjahrpexp.
      APPEND ls_bkpf TO lt_bkpf.
      CLEAR ls_bkpf.
    ENDIF.
    IF ls_trnhdr2-belnrpadv IS NOT INITIAL.
      ls_bkpf-bukrs = ls_trnhdr2-bukrs.
      ls_bkpf-belnr = ls_trnhdr2-belnrpadv.
      ls_bkpf-gjahr = ls_trnhdr2-gjahrpadv.
      APPEND ls_bkpf TO lt_bkpf.
      CLEAR ls_bkpf.
    ENDIF.
  ENDLOOP.

  IF lt_bkpf[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr blart
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FOR ALL ENTRIES IN lt_bkpf
    WHERE bukrs = lt_bkpf-bukrs
      AND belnr = lt_bkpf-belnr
      AND gjahr = lt_bkpf-gjahr.

    SELECT bukrs belnr gjahr buzei augbl koart lifnr
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FOR ALL ENTRIES IN lt_bkpf
      WHERE bukrs = lt_bkpf-bukrs
        AND belnr = lt_bkpf-belnr
        AND gjahr = lt_bkpf-gjahr.
  ENDIF.
ENDFORM.                    " F_GET_ZF63N_7

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63B_7
*&---------------------------------------------------------------------*
FORM f_process_zf63b_7 .
  DATA : ls_trnvch LIKE LINE OF gt_trnvch,
         ls_bkpf   LIKE LINE OF gt_bkpf.

  READ TABLE gt_trnvch INTO ls_trnvch INDEX 1.
  IF sy-subrc = 0.
    zf63reverse-zidvc      = ls_trnvch-zidvc.
    IF ls_trnvch-belnr IS NOT INITIAL.
      zf63reverse-gjahr      = ls_trnvch-gjahr.
      zf63reverse-belnr      = ls_trnvch-belnr.
      READ TABLE gt_bkpf INTO ls_bkpf
                         WITH KEY bukrs = ls_trnvch-bukrs
                                  belnr = ls_trnvch-belnr
                                  gjahr = ls_trnvch-gjahr.
      IF sy-subrc = 0.
        zf63reverse-blart      = ls_bkpf-blart.
      ENDIF.
      zf63reverse-budat      = ls_trnvch-budat.
    ENDIF.

    IF ls_trnvch-belnrpadv IS NOT INITIAL.
      zf63reverse-gjahrpadv  = ls_trnvch-gjahrpadv.
      zf63reverse-belnrpadv  = ls_trnvch-belnrpadv.
      READ TABLE gt_bkpf INTO ls_bkpf
                         WITH KEY bukrs = ls_trnvch-bukrs
                                  belnr = ls_trnvch-belnrpadv
                                  gjahr = ls_trnvch-gjahrpadv.
      IF sy-subrc = 0.
        zf63reverse-blartpadv  = ls_bkpf-blart.
      ENDIF.
      zf63reverse-budatpadv  = ls_trnvch-budatpadv.
    ENDIF.

    CALL SCREEN 807 STARTING AT 10 10.
  ENDIF.
ENDFORM.                    " F_PROCESS_ZF63B_7

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63N_7
*&---------------------------------------------------------------------*
FORM f_process_zf63n_7 .
  DATA : ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_bkpf    LIKE LINE OF gt_bkpf.

  READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
  IF sy-subrc = 0.
    zf63reverse-zidvc      = ls_trnhdr2-zidvc.
    IF ls_trnhdr2-belnrpexp IS NOT INITIAL.
      zf63reverse-gjahr      = ls_trnhdr2-gjahrpexp.
      zf63reverse-belnr      = ls_trnhdr2-belnrpexp.
      READ TABLE gt_bkpf INTO ls_bkpf
                         WITH KEY bukrs = ls_trnhdr2-bukrs
                                  belnr = ls_trnhdr2-belnrpexp
                                  gjahr = ls_trnhdr2-gjahrpexp.
      IF sy-subrc = 0.
        zf63reverse-blart      = ls_bkpf-blart.
      ENDIF.
      zf63reverse-budat      = ls_trnhdr2-budatpexp.
    ENDIF.

    IF ls_trnhdr2-belnrpadv IS NOT INITIAL.
      zf63reverse-gjahrpadv   = ls_trnhdr2-gjahrpadv.
      zf63reverse-belnrpadv   = ls_trnhdr2-belnrpadv.
      READ TABLE gt_bkpf INTO ls_bkpf
                         WITH KEY bukrs = ls_trnhdr2-bukrs
                                  belnr = ls_trnhdr2-belnrpadv
                                  gjahr = ls_trnhdr2-gjahrpadv.
      IF sy-subrc = 0.
        zf63reverse-blartpadv    = ls_bkpf-blart.
      ENDIF.
      zf63reverse-budatpadv    = ls_trnhdr2-budatpadv.
    ENDIF.

    IF ls_trnhdr2-xblnrexp IS NOT INITIAL.
      zf63reverse-xblnrexp   = ls_trnhdr2-xblnrexp.
    ENDIF.

    IF ls_trnhdr2-xblnradv IS NOT INITIAL.
      zf63reverse-xblnradv   = ls_trnhdr2-xblnradv.
    ENDIF.

    CALL SCREEN 807 STARTING AT 10 10.
  ENDIF.
ENDFORM.                    " F_PROCESS_ZF63N_7

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_UCOMM
*&---------------------------------------------------------------------*
FORM f_excluding_ucomm  USING    fu_fcode.
  APPEND fu_fcode  TO fcode.
ENDFORM.                    " F_EXCLUDING_UCOMM

*&---------------------------------------------------------------------*
*&      Form  F_COST_CENTER
*&---------------------------------------------------------------------*
FORM f_cost_center  USING    fu_bukrs fu_vkbur fu_kostl
                    CHANGING fc_kostl.
  DATA : lv_kostl1(10),
         lv_kostl2(10),
         lv_kostl(20),
         lv_alpha.

  lv_alpha  = 'X'.

  IF fu_kostl IS NOT INITIAL.
    SELECT SINGLE kostl
      FROM zfgaji_lokasi
      INTO lv_kostl1
      WHERE bukrs = fu_bukrs
        AND vkbur = fu_vkbur.

    IF sy-subrc <> 0.
      SELECT SINGLE kostl
        FROM zo2ofidt002
        INTO lv_kostl1
        WHERE bukrs = fu_bukrs
          AND gsber = fu_vkbur
          AND blart = 'SA'.
      IF sy-subrc = 0.
        CLEAR lv_alpha.
      ENDIF.
    ENDIF.

    lv_kostl2 = fu_kostl.
    SHIFT lv_kostl2 LEFT DELETING LEADING '0'.
    CONCATENATE lv_kostl1 lv_kostl2 INTO lv_kostl.

    IF lv_alpha IS INITIAL.
      SHIFT lv_kostl LEFT DELETING LEADING '0'.
      fc_kostl = lv_kostl.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_kostl
        IMPORTING
          output = fc_kostl.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_COST_CENTER

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63B_8
*&---------------------------------------------------------------------*
FORM f_get_zf63b_8 .
  DATA : lt_trnvch TYPE STANDARD TABLE OF zf63trnvch INITIAL SIZE 0,
         lt_trnhdr TYPE STANDARD TABLE OF zf63trnhdr.

  SELECT *
    FROM zf63trnvch
    INTO CORRESPONDING FIELDS OF TABLE gt_trnvch
    WHERE bukrs     = pa_bukrs
      AND gsber     = pa_gsber
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND zidvc     IN so_zidvc
      AND vjahr     = pa_vjahr
      AND belnr     = space
      AND belnrpadv = space.

  CLEAR : lt_trnvch[], lt_trnvch.
  lt_trnvch[] = gt_trnvch[].
  SORT lt_trnvch BY bukrs gsber vkbur gtype adv_gjahr adv_belnr.
  DELETE ADJACENT DUPLICATES FROM lt_trnvch COMPARING
  bukrs gsber vkbur gtype adv_gjahr adv_belnr.
  IF lt_trnvch[] IS NOT INITIAL.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN lt_trnvch
      WHERE bukrs = lt_trnvch-bukrs
        AND belnr = lt_trnvch-adv_belnr
        AND gjahr = lt_trnvch-adv_gjahr.
  ENDIF.

  CLEAR : lt_trnvch[], lt_trnvch.
  lt_trnvch[] = gt_trnvch[].
  SORT lt_trnvch BY bukrs gsber vkbur gtype zidvc.
  DELETE ADJACENT DUPLICATES FROM lt_trnvch COMPARING
  bukrs gsber vkbur gtype zidvc.
  IF lt_trnvch[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnhdr
      INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
      FOR ALL ENTRIES IN lt_trnvch
      WHERE bukrs     = lt_trnvch-bukrs
        AND gsber     = lt_trnvch-gsber
        AND vkbur     = lt_trnvch-vkbur
        AND gtype     = lt_trnvch-gtype
        AND zidvc     = lt_trnvch-zidvc
        AND gjahr     = lt_trnvch-vjahr.
  ENDIF.

  CLEAR : lt_trnhdr[], lt_trnhdr.
  lt_trnhdr[] = gt_trnhdr[].
  SORT lt_trnhdr BY bukrs gsber vkbur gtype expnr.
  DELETE ADJACENT DUPLICATES FROM lt_trnhdr
  COMPARING bukrs gsber vkbur gtype expnr.
  IF lt_trnhdr[] IS NOT INITIAL.
    SELECT *
      FROM zf63trndtl
      INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
      FOR ALL ENTRIES IN lt_trnhdr
      WHERE bukrs   = lt_trnhdr-bukrs
        AND gsber   = lt_trnhdr-gsber
        AND vkbur   = lt_trnhdr-vkbur
        AND gtype   = lt_trnhdr-gtype
        AND expnr   = lt_trnhdr-expnr
        AND gjahr   = lt_trnhdr-gjahr.
  ENDIF.

  CLEAR : lt_trnhdr[], lt_trnhdr.
  lt_trnhdr[] = gt_trnhdr[].
  SORT lt_trnhdr BY bukrs gsber vkbur gtype zidno.
  DELETE ADJACENT DUPLICATES FROM lt_trnhdr
  COMPARING bukrs gsber vkbur gtype zidno.
  IF lt_trnhdr[] IS NOT INITIAL.
    IF gs_gtype-advance IS INITIAL.
      SELECT *
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE gt_mstp
        FOR ALL ENTRIES IN lt_trnhdr
        WHERE bukrs   = lt_trnhdr-bukrs
          AND gsber   = lt_trnhdr-gsber
          AND vkbur   = lt_trnhdr-vkbur
          AND gtype   = lt_trnhdr-gtype
          AND zidno   = lt_trnhdr-zidno.
    ELSE.
      SELECT *
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE gt_mstp
        FOR ALL ENTRIES IN lt_trnhdr
        WHERE bukrs   = lt_trnhdr-bukrs
          AND gsber   = lt_trnhdr-gsber
          AND vkbur   = lt_trnhdr-vkbur.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ZF63B_8

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZF63N_8
*&---------------------------------------------------------------------*
FORM f_get_zf63n_8 .
  SELECT *
    FROM zf63trnhdr2
    INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr2
    WHERE bukrs     = pa_bukrs
      AND vkbur     = pa_vkbur
      AND gtype     = pa_gtype
      AND gjahr     = pa_vjahr
      AND zidvc     IN so_zidv2
      AND belnrpadv = space
      AND belnrpexp = space.

  IF gt_trnhdr2[] IS NOT INITIAL.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_trnhdr2
      WHERE bukrs = gt_trnhdr2-bukrs
        AND belnr = gt_trnhdr2-adv_belnr
        AND gjahr = gt_trnhdr2-adv_gjahr.

    SELECT *
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE gt_mstp
      FOR ALL ENTRIES IN gt_trnhdr2
      WHERE bukrs   = gt_trnhdr2-bukrs
        AND gsber   = gt_trnhdr2-gsber
        AND vkbur   = gt_trnhdr2-vkbur.

    SELECT *
      FROM zf63trndtl2
      INTO CORRESPONDING FIELDS OF TABLE gt_trndtl2
      FOR ALL ENTRIES IN gt_trnhdr2
      WHERE bukrs   = gt_trnhdr2-bukrs
        AND gsber   = gt_trnhdr2-gsber
        AND vkbur   = gt_trnhdr2-vkbur
        AND gtype   = gt_trnhdr2-gtype
        AND zidvc   = gt_trnhdr2-zidvc
        AND gjahr   = gt_trnhdr2-gjahr.
  ENDIF.
ENDFORM.                    " F_GET_ZF63N_8

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63B_8
*&---------------------------------------------------------------------*
FORM f_process_zf63b_8 .
  DATA : ls_trnvch  LIKE LINE OF gt_trnvch,
         ls_reprint LIKE LINE OF gt_reprint,
         ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_trndtl  LIKE LINE OF gt_trndtl,
         ls_bsik    LIKE LINE OF gt_bsik.
  DATA : lv_uname     TYPE sy-uname.

  LOOP AT gt_trnvch INTO ls_trnvch.
    ls_reprint-bukrs      = ls_trnvch-bukrs.
    ls_reprint-vkbur      = ls_trnvch-vkbur.
    ls_reprint-gsber      = ls_trnvch-gsber.
    ls_reprint-gtype      = ls_trnvch-gtype.
    ls_reprint-zidvc      = ls_trnvch-zidvc.
    ls_reprint-vjahr      = ls_trnvch-vjahr.
    ls_reprint-bktxt      = ls_trnvch-bktxt.
    ls_reprint-waers      = ls_trnvch-waers.
    ls_reprint-wrbtr      = ls_trnvch-wrbtr.
    ls_reprint-adv_gjahr  = ls_trnvch-adv_gjahr.
    ls_reprint-adv_belnr  = ls_trnvch-adv_belnr.
    CLEAR ls_bsik.
    READ TABLE gt_bsik INTO ls_bsik
                       WITH KEY bukrs = ls_trnvch-bukrs
                                belnr = ls_trnvch-adv_belnr
                                gjahr = ls_trnvch-adv_gjahr.
    IF sy-subrc = 0.
      ls_reprint-adv_wrbtr  = ls_bsik-wrbtr.
    ENDIF.

    LOOP AT gt_trnhdr INTO ls_trnhdr WHERE bukrs = ls_trnvch-bukrs
                                       AND gsber = ls_trnvch-gsber
                                       AND vkbur = ls_trnvch-vkbur
                                       AND gtype = ls_trnvch-gtype
                                       AND zidvc = ls_trnvch-zidvc.
      LOOP AT gt_trndtl INTO ls_trndtl WHERE bukrs = ls_trnhdr-bukrs
                                         AND gsber = ls_trnhdr-gsber
                                         AND vkbur = ls_trnhdr-vkbur
                                         AND gtype = ls_trnhdr-gtype
                                         AND expnr = ls_trnhdr-expnr.
        IF ls_reprint-vbund IS INITIAL.
          ls_reprint-vbund  = ls_trndtl-vbund.
        ENDIF.
        IF ls_reprint-text IS INITIAL.
          ls_reprint-text  = ls_trndtl-text.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    APPEND ls_reprint TO gt_reprint.
    CLEAR ls_reprint.
  ENDLOOP.

  LOOP AT gt_reprint INTO ls_reprint.
    PERFORM f_lock_table USING 'ENQUEUE_EZF63TRNVCH' 'ZF63TRNVCH'
                               ls_reprint-bukrs ls_reprint-gsber
                               ls_reprint-vkbur ls_reprint-gtype
                               ls_reprint-zidvc ''
                         CHANGING lv_uname.
    IF lv_uname IS NOT INITIAL.
      DELETE TABLE gt_reprint FROM ls_reprint.
    ENDIF.
    CLEAR lv_uname.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_ZF63B_8

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ZF63N_8
*&---------------------------------------------------------------------*
FORM f_process_zf63n_8 .
  DATA : ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_reprint LIKE LINE OF gt_reprint,
         ls_bsik    LIKE LINE OF gt_bsik.

  LOOP AT gt_trnhdr2 INTO ls_trnhdr2.
    ls_reprint-bukrs      = ls_trnhdr2-bukrs.
    ls_reprint-gsber      = ls_trnhdr2-gsber.
    ls_reprint-vkbur      = ls_trnhdr2-vkbur.
    ls_reprint-gtype      = ls_trnhdr2-gtype.
    ls_reprint-zidvc2     = ls_trnhdr2-zidvc.
    ls_reprint-vjahr      = ls_trnhdr2-gjahr.
    ls_reprint-bktxt      = ls_trnhdr2-bktxt.
    ls_reprint-wrbtr      = ls_trnhdr2-wrbtr.
    ls_reprint-waers      = ls_trnhdr2-waers.
    ls_reprint-zidno      = ls_trnhdr2-zidno.
    ls_reprint-adv_belnr  = ls_trnhdr2-adv_belnr.
    ls_reprint-adv_gjahr  = ls_trnhdr2-adv_gjahr.
    READ TABLE gt_bsik INTO ls_bsik
                   WITH KEY belnr = ls_trnhdr2-adv_belnr
                            gjahr = ls_trnhdr2-adv_gjahr.
    IF sy-subrc = 0.
      ls_reprint-adv_wrbtr    = ls_bsik-wrbtr.
    ENDIF.
    APPEND ls_reprint TO gt_reprint.
    CLEAR ls_reprint.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_ZF63N_8

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_REPRINT_N
*&---------------------------------------------------------------------*
FORM f_prepare_reprint_n .
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : ls_reprint LIKE LINE OF gt_reprint,
         ls_header  LIKE LINE OF gt_header,
         ls_mstp    LIKE LINE OF gt_mstp,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_trndtl2 LIKE LINE OF gt_trndtl2.
  DATA : lv_nmvch      TYPE zf63acckasexp-nmvoucher,
         lv_prefix1(3),
         lv_prefix2(3).

  CLEAR : gt_header[], gt_header.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lt_rows = lr_selections->get_selected_rows( ).

  IF lt_rows[] IS NOT INITIAL.
    LOOP AT lt_rows INTO i.
      READ TABLE gt_reprint INTO ls_reprint INDEX i.
      IF sy-subrc = 0.

        CLEAR ls_trnhdr2.
        READ TABLE gt_trnhdr2 INTO ls_trnhdr2
                             WITH KEY bukrs   = ls_reprint-bukrs
                                      gsber   = ls_reprint-gsber
                                      vkbur   = ls_reprint-vkbur
                                      gtype   = ls_reprint-gtype
                                      zidvc   = ls_reprint-zidvc2.
        IF sy-subrc = 0.
          CLEAR ls_trndtl2.
          READ TABLE gt_trndtl2 INTO ls_trndtl2
                                WITH KEY bukrs   = ls_reprint-bukrs
                                         gsber   = ls_reprint-gsber
                                         vkbur   = ls_reprint-vkbur
                                         gtype   = ls_reprint-gtype
                                         zidvc   = ls_reprint-zidvc2.

          CLEAR lv_nmvch.
          SELECT SINGLE nmvoucher
            FROM zf63acckasexp
            INTO lv_nmvch
            WHERE hkont = ls_trnhdr2-hkont.

          CLEAR ls_mstp.
          READ TABLE gt_mstp INTO ls_mstp
                             WITH KEY bukrs = ls_reprint-bukrs
                                      gsber = ls_reprint-gsber
                                      vkbur = ls_reprint-vkbur
                                      lifnr = ls_trnhdr2-zidno.
          IF sy-subrc <> 0.
            CLEAR ls_mstp.
            READ TABLE gt_mstp INTO ls_mstp
                               WITH KEY bukrs = ls_reprint-bukrs
                                        gsber = ls_reprint-gsber
                                        vkbur = ls_reprint-vkbur
                                        zidno = ls_trnhdr2-zidno.
          ENDIF.

          PERFORM f_append_header USING 'ZFEXP_F001' 'Cash/Bank Payment Voucher'
                                        lv_prefix1 ls_trnhdr2-zidvc ls_trndtl2-znopol
                                        ls_mstp-lifnr ls_mstp-name1 ls_trnhdr2-bktxt
                                        ls_mstp-kostl ls_mstp-wwsfr ls_mstp-wwpos
                                        ls_reprint-wrbtr ls_trnhdr2-waers
                                        ls_trnhdr2-hkont '' '' ''
                                        ls_reprint-vbund ls_mstp-vbund ls_reprint-text.

          IF ls_trnhdr2-zidvc2 IS NOT INITIAL.
            PERFORM f_append_header USING 'ZFEXP_F002' 'Cash/Bank Receipt Voucher'
                                          lv_prefix1 ls_trnhdr2-zidvc2 ls_trndtl2-znopol
                                          ls_mstp-lifnr ls_mstp-name1 ls_trnhdr2-bktxt
                                          ls_mstp-kostl ls_mstp-wwsfr ls_mstp-wwpos
                                          ls_reprint-adv_wrbtr ls_trnhdr2-waers
                                          ls_trnhdr2-hkont '' ls_reprint-adv_belnr
                                          ls_reprint-adv_gjahr
                                          ls_reprint-vbund ls_mstp-vbund ls_reprint-text.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).

ENDFORM.                    " F_PREPARE_REPRINT_N

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT_VOUCHER_B
*&---------------------------------------------------------------------*
FORM f_reprint_voucher_b TABLES ft_detail   STRUCTURE zfexpstprnt.
  DATA : ls_trnhdr  LIKE LINE OF gt_trnhdr,
         ls_trndtl  LIKE LINE OF gt_trndtl,
         ls_detail  LIKE LINE OF gt_detail,
         ls_typeexp LIKE LINE OF gt_typeexp,
         ls_accexp  LIKE LINE OF gt_accexp,
         lv_flag.

  LOOP AT gt_trnhdr INTO ls_trnhdr WHERE bukrs = gs_header-bukrs
                                     AND gsber = gs_header-gsber
                                     AND vkbur = gs_header-vkbur
                                     AND gtype = gs_header-gtype
                                     AND zidvc = gs_header-zidvc.
    LOOP AT gt_trndtl INTO ls_trndtl WHERE bukrs = ls_trnhdr-bukrs
                                       AND gsber = ls_trnhdr-gsber
                                       AND vkbur = ls_trnhdr-vkbur
                                       AND gtype = ls_trnhdr-gtype
                                       AND expnr = ls_trnhdr-expnr.
      IF ls_trndtl-text IS INITIAL.
        ls_detail-description  = ls_trndtl-description.
      ELSE.
        CONCATENATE ls_trndtl-description '-' ls_trndtl-text
        INTO ls_detail-description
        SEPARATED BY space.
      ENDIF.
      IF gs_gtype-advance IS INITIAL.
        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp WITH KEY bukrs = ls_trndtl-bukrs
                                                       gtype = ls_trndtl-gtype
                                                       type  = ls_trndtl-type.
        IF sy-subrc = 0.
          CLEAR ls_accexp.
          READ TABLE gt_accexp INTO ls_accexp WITH KEY acctype  = ls_typeexp-acctype.
          IF sy-subrc = 0.
            ls_detail-hkont   = ls_accexp-hkont.
          ENDIF.
        ENDIF.
      ELSE.
        IF lv_flag IS INITIAL.
          lv_flag = selected.
          ls_detail-hkont   = '0141130000'.
        ENDIF.
      ENDIF.
      WRITE ls_trndtl-wrbtr TO ls_detail-wrbtrt CURRENCY ls_trndtl-waers.
      IF ls_trndtl-shkzg = 'H'.
        CONDENSE ls_detail-wrbtrt NO-GAPS.
        CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt.
      ENDIF.
      APPEND ls_detail TO ft_detail.
      CLEAR ls_detail.
    ENDLOOP.
    CLEAR lv_flag.
  ENDLOOP.
ENDFORM.                    " F_REPRINT_VOUCHER_B

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT_VOUCHER_N
*&---------------------------------------------------------------------*
FORM f_reprint_voucher_n TABLES ft_detail   STRUCTURE zfexpstprnt.
  DATA : ls_trnhdr2     LIKE LINE OF gt_trnhdr2,
         ls_trndtl2     LIKE LINE OF gt_trndtl2,
         ls_typeexp     LIKE LINE OF gt_typeexp,
         ls_accexp      LIKE LINE OF gt_accexp,
         ls_detail      LIKE LINE OF gt_detail,
         lv_flag,
         lv_proseq(100).

  SORT gt_trndtl2 BY zidvc buzei.
  LOOP AT gt_trnhdr2 INTO ls_trnhdr2 WHERE bukrs = gs_header-bukrs
                                       AND gsber = gs_header-gsber
                                       AND vkbur = gs_header-vkbur
                                       AND gtype = gs_header-gtype
                                       AND zidvc = gs_header-cell14.
    LOOP AT gt_trndtl2 INTO ls_trndtl2 WHERE bukrs = ls_trnhdr2-bukrs
                                         AND gsber = ls_trnhdr2-gsber
                                         AND vkbur = ls_trnhdr2-vkbur
                                         AND gtype = ls_trnhdr2-gtype
                                         AND zidvc = gs_header-cell14.
      IF ls_trndtl2-text IS INITIAL.
        ls_detail-description  = ls_trndtl2-description.
      ELSE.
        CONCATENATE ls_trndtl2-description '-' ls_trndtl2-text
        INTO ls_detail-description
        SEPARATED BY space.
      ENDIF.
      IF gs_gtype-advance IS INITIAL.
        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp WITH KEY bukrs = ls_trndtl2-bukrs
                                                       gtype = ls_trndtl2-gtype
                                                       type  = ls_trndtl2-type.
        IF sy-subrc = 0.
          CLEAR ls_accexp.
          READ TABLE gt_accexp INTO ls_accexp WITH KEY acctype  = ls_typeexp-acctype.
          IF sy-subrc = 0.
            ls_detail-hkont   = ls_accexp-hkont.
          ENDIF.
        ENDIF.
      ELSE.
        IF lv_flag IS INITIAL.
          lv_flag = selected.
          ls_detail-hkont   = '0141130000'.
        ENDIF.
      ENDIF.
      ls_detail-wrbtr   = ls_trndtl2-wrbtr.
      ls_detail-shkzg   = ls_trndtl2-shkzg.
      ls_detail-type    = ls_trndtl2-type.
      COLLECT ls_detail INTO ft_detail.
      CLEAR ls_detail.
    ENDLOOP.

    LOOP AT ft_detail INTO ls_detail.
      WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_trndtl2-waers.
      IF ls_detail-shkzg = 'H'.
        CONDENSE ls_detail-wrbtrt NO-GAPS.
        CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt.
      ENDIF.

      LOOP AT gt_trndtl2 INTO ls_trndtl2 WHERE bukrs = ls_trnhdr2-bukrs
                                           AND gsber = ls_trnhdr2-gsber
                                           AND vkbur = ls_trnhdr2-vkbur
                                           AND gtype = ls_trnhdr2-gtype
                                           AND zidvc = gs_header-cell14
                                           AND type  = ls_detail-type.
        lv_proseq = ls_trndtl2-kostl.
        SHIFT lv_proseq LEFT DELETING LEADING '0'.
        IF ls_trndtl2-wwsfr IS NOT INITIAL.
          CONCATENATE lv_proseq '-' ls_trndtl2-wwsfr
          INTO lv_proseq.
        ELSEIF ls_trndtl2-wwpos IS NOT INITIAL.
          CONCATENATE lv_proseq '-' ls_trndtl2-wwpos
          INTO lv_proseq.
        ENDIF.

        IF ls_detail-proseq IS INITIAL.
          ls_detail-proseq = lv_proseq.
        ELSE.
          CONCATENATE ls_detail-proseq ',' lv_proseq
          INTO ls_detail-proseq.
        ENDIF.
        CLEAR lv_proseq.
      ENDLOOP.
      MODIFY ft_detail FROM ls_detail TRANSPORTING wrbtrt proseq.
      CLEAR ls_detail-proseq.
    ENDLOOP.
    CLEAR lv_flag.
  ENDLOOP.
ENDFORM.                    " F_REPRINT_VOUCHER_N

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_B
*&---------------------------------------------------------------------*
FORM f_delete_b USING ls_head LIKE LINE OF gt_head
                      i_ucomm.
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : lt_head       TYPE STANDARD TABLE OF ty_trnhdr INITIAL SIZE 0.
  DATA : ls_mstp    LIKE LINE OF gt_mstp,
         ls_ctrladv LIKE LINE OF gt_ctrladv,
         lv_advan   TYPE zf63ctrladv-advan.

  DELETE FROM zf63trnhdr WHERE bukrs = ls_head-bukrs
                           AND gsber = ls_head-gsber
                           AND vkbur = ls_head-vkbur
                           AND gtype = ls_head-gtype
                           AND expnr = ls_head-expnr
                           AND gjahr = ls_head-kjahr.

  DELETE FROM zf63trndtl WHERE bukrs = ls_head-bukrs
                           AND gsber = ls_head-gsber
                           AND vkbur = ls_head-vkbur
                           AND gtype = ls_head-gtype
                           AND expnr = ls_head-expnr
                           AND gjahr = ls_head-kjahr.

  DELETE FROM zf63trnshp WHERE bukrs = ls_head-bukrs
                           AND gsber = ls_head-gsber
                           AND vkbur = ls_head-vkbur
                           AND gtype = ls_head-gtype
                           AND expnr = ls_head-expnr
                           AND gjahr = ls_head-kjahr.

  UPDATE zf63kmhexph SET lvorm = selected
                     WHERE bukrs = ls_head-bukrs
                       AND gsber = ls_head-gsber
                       AND vkbur = ls_head-vkbur
                       AND expnr = ls_head-expnr.

  DELETE gt_head WHERE bukrs = ls_head-bukrs
                   AND gsber = ls_head-gsber
                   AND vkbur = ls_head-vkbur
                   AND gtype = ls_head-gtype
                   AND expnr = ls_head-expnr
                   AND gjahr = ls_head-gjahr.

  DELETE gt_detl WHERE bukrs = ls_head-bukrs
                   AND gsber = ls_head-gsber
                   AND vkbur = ls_head-vkbur
                   AND gtype = ls_head-gtype
                   AND expnr = ls_head-expnr
                   AND kjahr = ls_head-gjahr.

  IF i_ucomm = '&DELADV'.
    CLEAR ls_mstp.
    READ TABLE gt_mstp INTO ls_mstp
                       WITH KEY bukrs = ls_head-bukrs
                                gsber = ls_head-gsber
                                vkbur = ls_head-vkbur
                                lifnr = ls_head-zidno.

    CLEAR ls_ctrladv.
    SELECT SINGLE *
      FROM zf63ctrladv
      INTO CORRESPONDING FIELDS OF ls_ctrladv
      WHERE bukrs   = ls_head-bukrs
        AND vkbur   = ls_head-vkbur
        AND gtype   = ls_head-gtype
        AND lifnr   = ls_head-zidno
        AND zidno   = ls_mstp-zidno.
*        AND gjahr   = ls_head-kjahr.

    IF sy-subrc = 0.
      lv_advan  = ls_ctrladv-advan - 1.
      UPDATE zf63ctrladv SET advan = lv_advan
                       WHERE bukrs = ls_head-bukrs
                         AND vkbur = ls_head-vkbur
                         AND gtype = ls_head-gtype
                         AND lifnr = ls_head-zidno
                         AND zidno = ls_mstp-zidno.
*                         AND gjahr = ls_head-kjahr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DELETE_B

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_N
*&---------------------------------------------------------------------*
FORM f_delete_n  USING    ls_head   LIKE LINE OF gt_head
                          i_ucomm.
  DATA : lr_selections TYPE REF TO cl_salv_selections,
         lt_rows       TYPE salv_t_row,
         i             TYPE i.
  DATA : lt_head       TYPE STANDARD TABLE OF ty_trnhdr INITIAL SIZE 0.
  DATA : ls_mstp    LIKE LINE OF gt_mstp,
         ls_ctrladv LIKE LINE OF gt_ctrladv,
         lv_advan   TYPE zf63ctrladv-advan.

  DELETE FROM zf63trnhdr2 WHERE bukrs = ls_head-bukrs
                            AND gsber = ls_head-gsber
                            AND vkbur = ls_head-vkbur
                            AND gtype = ls_head-gtype
                            AND zidvc = ls_head-zidvc
                            AND gjahr = ls_head-kjahr.

  DELETE FROM zf63trndtl2 WHERE bukrs = ls_head-bukrs
                            AND gsber = ls_head-gsber
                            AND vkbur = ls_head-vkbur
                            AND gtype = ls_head-gtype
                            AND zidvc = ls_head-zidvc
                            AND gjahr = ls_head-kjahr.

  DELETE FROM zf63trnshp2 WHERE bukrs = ls_head-bukrs
                            AND gsber = ls_head-gsber
                            AND vkbur = ls_head-vkbur
                            AND gtype = ls_head-gtype
                            AND zidvc = ls_head-zidvc
                            AND gjahr = ls_head-kjahr.

*  UPDATE zf63kmhexph SET lvorm = selected
*                     WHERE bukrs = ls_head-bukrs
*                       AND gsber = ls_head-gsber
*                       AND vkbur = ls_head-vkbur
*                       AND expnr = ls_head-expnr.

  DELETE gt_head WHERE bukrs = ls_head-bukrs
                   AND gsber = ls_head-gsber
                   AND vkbur = ls_head-vkbur
                   AND gtype = ls_head-gtype
                   AND zidvc = ls_head-zidvc
                   AND gjahr = ls_head-gjahr.

  DELETE gt_detl WHERE bukrs = ls_head-bukrs
                   AND gsber = ls_head-gsber
                   AND vkbur = ls_head-vkbur
                   AND gtype = ls_head-gtype
                   AND zidvc = ls_head-zidvc
                   AND kjahr = ls_head-gjahr.

  IF i_ucomm = '&DELADV'.
    CLEAR ls_mstp.
    READ TABLE gt_mstp INTO ls_mstp
                       WITH KEY bukrs = ls_head-bukrs
                                gsber = ls_head-gsber
                                vkbur = ls_head-vkbur
                                lifnr = ls_head-zidno.

    CLEAR ls_ctrladv.
    SELECT SINGLE *
      FROM zf63ctrladv
      INTO CORRESPONDING FIELDS OF ls_ctrladv
      WHERE bukrs   = ls_head-bukrs
        AND vkbur   = ls_head-vkbur
        AND gtype   = ls_head-gtype
        AND lifnr   = ls_head-zidno
        AND zidno   = ls_mstp-zidno.
*        AND gjahr   = ls_head-kjahr.

    IF sy-subrc = 0.
      lv_advan  = ls_ctrladv-advan - 1.
      UPDATE zf63ctrladv SET advan = lv_advan
                       WHERE bukrs = ls_head-bukrs
                         AND vkbur = ls_head-vkbur
                         AND gtype = ls_head-gtype
                         AND lifnr = ls_head-zidno
                         AND zidno = ls_mstp-zidno.
*                         AND gjahr = ls_head-kjahr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DELETE_N

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_SMARTFORMS
*&---------------------------------------------------------------------*
FORM f_move_to_smartforms .
  DATA : ls_trndtl2 LIKE LINE OF gt_trndtl2,
         ls_detail  LIKE LINE OF gt_detail,
         ls_typeexp LIKE LINE OF gt_typeexp,
         lv_total   TYPE bseg-wrbtr,
         lv_wrbtr   TYPE bseg-wrbtr,
         in_words   TYPE spell,
         lv_waers   TYPE zfexpense-waers,
         lv_langu   TYPE sy-langu VALUE 'id'.

  DATA : ls_kostl     LIKE LINE OF gt_kostl.

  CLEAR : gt_window3[], gt_window3, gt_detail[], gt_detail.

  SELECT SINGLE *
    FROM zf63masterperson
    INTO CORRESPONDING FIELDS OF gs_mstp
    WHERE bukrs = zfexpense-bukrs
      AND gsber = zfexpense-gsber
      AND vkbur = zfexpense-vkbur
      AND zidno = zfexpense-zidno.

  LOOP AT gt_trndtl2 INTO ls_trndtl2.
    ls_detail-waers       = ls_trndtl2-waers.
    ls_detail-wrbtr       = ls_trndtl2-wrbtr.
    ls_detail-shkzg       = ls_trndtl2-shkzg.
    ls_detail-type        = ls_trndtl2-type.
    READ TABLE gt_typeexp INTO ls_typeexp
                          WITH KEY type = ls_trndtl2-type.
    IF sy-subrc = 0.
      SELECT SINGLE hkont
        FROM zf63accexp
        INTO ls_detail-hkont
        WHERE acctype = ls_typeexp-acctype.
    ENDIF.
    ls_detail-description = ls_trndtl2-description.

    CLEAR lv_wrbtr.
    IF ls_trndtl2-shkzg = 'H'.
      lv_wrbtr  = ls_trndtl2-wrbtr * -1.
    ELSE.
      lv_wrbtr  = ls_trndtl2-wrbtr.
    ENDIF.
    ADD lv_wrbtr TO lv_total.
    COLLECT ls_detail INTO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  LOOP AT gt_detail INTO ls_detail.
    lv_waers  = ls_detail-waers.
    WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_detail-waers.
    IF ls_detail-shkzg = 'H'.
      CONDENSE ls_detail-wrbtrt NO-GAPS.
      CONCATENATE '(' ls_detail-wrbtrt ')' INTO ls_detail-wrbtrt.
    ENDIF.
    CLEAR : ls_detail-proseq, ls_kostl.
    LOOP AT gt_kostl INTO ls_kostl WHERE type = ls_detail-type.
      IF ls_detail-proseq IS INITIAL.
        ls_detail-proseq = ls_kostl-proseq.
      ELSE.
        CONCATENATE ls_detail-proseq ls_kostl-proseq
        INTO ls_detail-proseq
        SEPARATED BY ','.
      ENDIF.
    ENDLOOP.
    MODIFY gt_detail FROM ls_detail TRANSPORTING wrbtrt proseq.
  ENDLOOP.

  WRITE lv_total TO gs_header-totalt CURRENCY 'IDR'.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_total
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
  TRANSLATE gs_header-terbilang TO UPPER CASE.
ENDFORM.                    " F_MOVE_TO_SMARTFORMS

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_KM
*&---------------------------------------------------------------------*
FORM f_calculate_km  TABLES   ft_kmh STRUCTURE zf63kmhexph
                     USING    fu_zidvc.
  DATA : lt_xtrndtl2 TYPE STANDARD TABLE OF zf63trndtl2 INITIAL SIZE 0,
         ls_xtrndtl2 LIKE LINE OF lt_xtrndtl2,
         lt_xkmh     TYPE STANDARD TABLE OF zf63kmhexph,
         ls_xkmh     LIKE LINE OF lt_xkmh,
         ls_kmh      LIKE LINE OF gt_kmh,
         ls_trndtl2  LIKE LINE OF gt_trndtl2.

  lt_xtrndtl2[] = gt_trndtl2[].
  SORT lt_xtrndtl2 BY bukrs gsber vkbur znopol type.
  DELETE ADJACENT DUPLICATES FROM lt_xtrndtl2 COMPARING bukrs gsber vkbur znopol type.
  DELETE lt_xtrndtl2 WHERE speed IS INITIAL.

  IF lt_xtrndtl2[] IS NOT INITIAL.
    SELECT *
      FROM zf63kmhexph
      INTO CORRESPONDING FIELDS OF TABLE lt_xkmh
      FOR ALL ENTRIES IN lt_xtrndtl2
      WHERE bukrs   = lt_xtrndtl2-bukrs
        AND gsber   = lt_xtrndtl2-gsber
        AND vkbur   = lt_xtrndtl2-vkbur
        AND znopol  = lt_xtrndtl2-znopol
        AND type    = lt_xtrndtl2-type
        AND bldat   = sy-datum.
  ENDIF.

  SORT lt_xkmh BY znopol buzei DESCENDING.

  LOOP AT lt_xtrndtl2 INTO ls_xtrndtl2.
    READ TABLE lt_xkmh INTO ls_kmh
                      WITH KEY bukrs  = ls_xtrndtl2-bukrs
                               gsber  = ls_xtrndtl2-gsber
                               vkbur  = ls_xtrndtl2-vkbur
                               znopol = ls_xtrndtl2-znopol
                               type   = ls_xtrndtl2-type.
    IF sy-subrc = 0.
      ADD 1 TO ls_kmh-buzei.
    ELSE.
      ls_kmh-buzei = 1.
    ENDIF.

    CLEAR ls_trndtl2.
    LOOP AT gt_trndtl2 INTO ls_trndtl2 WHERE bukrs  = ls_xtrndtl2-bukrs
                                         AND gsber  = ls_xtrndtl2-gsber
                                         AND vkbur  = ls_xtrndtl2-vkbur
                                         AND znopol = ls_xtrndtl2-znopol
                                         AND type   = ls_xtrndtl2-type.
      ls_kmh-bukrs         = ls_trndtl2-bukrs.
      ls_kmh-gsber         = ls_trndtl2-gsber.
      ls_kmh-vkbur         = ls_trndtl2-vkbur.
      ls_kmh-znopol        = ls_trndtl2-znopol.
      ls_kmh-type          = ls_trndtl2-type.
      ls_kmh-item          = ls_kmh-buzei.
      ls_kmh-speed         = ls_trndtl2-speed.
      ls_kmh-kmstr         = ls_trndtl2-kmstr.
      ls_kmh-bldat         = sy-datum.
      ls_kmh-kmend         = ls_trndtl2-kmend.
      ls_kmh-expnr         = space.
      ls_kmh-zidvc         = fu_zidvc.
      ls_kmh-lvorm         = space.
      IF ls_kmh-kmstr IS NOT INITIAL OR
        ls_kmh-kmend IS NOT INITIAL.
        APPEND ls_kmh TO ft_kmh.
        ADD 1 TO ls_kmh-buzei.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_KM

*&---------------------------------------------------------------------*
*&      Form  F_DC_FR_TYPE
*&---------------------------------------------------------------------*
FORM f_dc_fr_type  USING    fu_bukrs fu_gtype fu_type
                   CHANGING fc_wrbtr.
  DATA : ls_typeexp LIKE LINE OF gt_typeexp,
         ls_accexp  LIKE LINE OF gt_accexp,
         ls_tbsl    LIKE LINE OF gt_tbsl.

  CLEAR ls_typeexp.
  READ TABLE gt_typeexp INTO ls_typeexp
                        WITH KEY bukrs = fu_bukrs
                                 gtype = fu_gtype
                                 type  = fu_type.
  IF sy-subrc = 0.
    CLEAR : ls_accexp.
    READ TABLE gt_accexp INTO ls_accexp
                         WITH KEY acctype = ls_typeexp-acctype.
    IF sy-subrc = 0.
      CLEAR ls_tbsl.
      READ TABLE gt_tbsl INTO ls_tbsl
                         WITH KEY bschl = ls_accexp-bschl.
      IF sy-subrc = 0.
        IF ls_tbsl-shkzg = 'H'.
          fc_wrbtr = fc_wrbtr * -1.
        ELSEIF
          fc_wrbtr = fc_wrbtr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DC_FR_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_PROFIT_SEQMENT
*&---------------------------------------------------------------------*
FORM f_profit_seqment  TABLES   ft_kostl  STRUCTURE zfexpstprnt
                       USING    fu_vkbur fu_departemen.
  DATA : ls_proseq LIKE LINE OF gt_proseq,
         ls_kostl  TYPE zfexpstprnt.

  ls_kostl-type   = zftransaction-type.
  CLEAR ls_proseq.
  READ TABLE gt_proseq INTO ls_proseq
                       WITH KEY departemen = fu_departemen.
  IF sy-subrc = 0.
    CONCATENATE fu_vkbur ls_proseq-kostl+6(4)
    INTO ls_kostl-proseq.
    IF ls_proseq-wwsfr IS INITIAL AND
      ls_proseq-wwpos IS INITIAL.
    ELSEIF ls_proseq-wwsfr IS NOT INITIAL AND
      ls_proseq-wwpos IS INITIAL.
      CONCATENATE ls_kostl-proseq '-' ls_proseq-wwsfr
      INTO ls_kostl-proseq.
    ELSEIF ls_proseq-wwpos IS NOT INITIAL AND
      ls_proseq-wwsfr IS INITIAL.
      CONCATENATE ls_kostl-proseq '-' ls_proseq-wwpos
      INTO ls_kostl-proseq.
    ENDIF.
    SHIFT ls_kostl-proseq LEFT DELETING LEADING '0'.
    APPEND ls_kostl TO ft_kostl.
    CLEAR ls_kostl.
  ENDIF.
ENDFORM.                    " F_PROFIT_SEQMENT

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_CHECK
*&---------------------------------------------------------------------*
FORM f_cancel_check  CHANGING fc_subrc.
  DATA : ls_trnhdr2   TYPE zf63trnhdr2.

  SELECT *
    FROM zf63trnhdr2
    INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr2
    WHERE bukrs        = pa_bukrs
      AND vkbur        = pa_vkbur
      AND gtype        = pa_gtype
      AND zidvc        = pa_zidv2
      AND belnrpadv    = pa_belnr
      AND gjahr        = pa_vjahr
      AND userpost     <> space
      AND belnrpadvrev = space.

  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM zf63trnhdr2
      INTO CORRESPONDING FIELDS OF ls_trnhdr2
      WHERE bukrs       = pa_bukrs
        AND vkbur       = pa_vkbur
        AND adv_gjahr   = pa_vjahr
        AND adv_belnr   = pa_belnr.
    IF sy-subrc = 0.
      fc_subrc = 4.
    ENDIF.
  ELSE.
    fc_subrc = 4.
  ENDIF.
ENDFORM.                    " F_CANCEL_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_ALV_LIST_CANCEL
*&---------------------------------------------------------------------*
FORM f_alv_list_cancel .
  DATA : lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings,
         lr_events    TYPE REF TO cl_salv_events_table,
         lr_aggrs     TYPE REF TO cl_salv_aggregations.

  TRY.
      cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = gr_table
          CHANGING
            t_table        = gt_cancel ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_table->set_screen_status(
    pfstatus   = 'SALV_STANDARD1'
    report     = gv_repid ).

  PERFORM f_set_text USING : 'ICON' 'Sts' 'X',
                             'VBUND' 'Tr.Prt' 'X',
                             'WAERS' 'Curr.' 'X',
                             'GJAHR' 'Year' '',
                             'WWPOS' 'W & D' '',
                             'WWPFN' 'Sales area' '',
                             'WWSFR' 'Sales forc' '',
                             'KOART' 'Acct Type' '',
                             'XREF3' 'RefKey 3' '',
                             'SHKZG' 'D/C' '',
                             'POST' 'Flag' '',
                             'DESCRIPTION' '' '',
                             'TEXT' 'Text' 'X',
                             'KMSTR' 'KM Start' '',
                             'KMEND' 'KM End' '',
                             'ZNOPOL' '' '',
                             'SPEED' '' ''.

  PERFORM f_set_text USING : 'MEINS' '' abap_false,
                             'MENGE' '' abap_false.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  lr_aggrs = gr_table->get_aggregations( ).
  TRY.
      lr_aggrs->add_aggregation(
        columnname  = 'WRBTR'
        aggregation = if_salv_c_aggregation=>total ).

    CATCH cx_salv_data_error cx_salv_not_found cx_salv_existing.
  ENDTRY.

  PERFORM f_set_sort  USING : 'BLART'.

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.

  gr_table->display( ).
ENDFORM.                    " F_ALV_LIST_CANCEL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_CANCEL_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_cancel_data  USING    fs_trnhdr2   TYPE zf63trnhdr2.
  DATA : ls_cancel LIKE LINE OF gt_cancel,
         ls_tbsl   LIKE LINE OF gt_tbsl,
         ls_mstp   LIKE LINE OF gt_mstp.

  ls_cancel-blart  = 'KZ'.
  ls_cancel-xblnr  = pa_xbln2.
  ls_cancel-waers  = 'IDR'.
  ls_cancel-gsber  = fs_trnhdr2-gsber.
  DO 2 TIMES.
    IF ls_cancel-bschl IS INITIAL.
      ls_cancel-bschl = '39'.
    ELSE.
      ls_cancel-bschl = '40'.
    ENDIF.

    ADD 1 TO ls_cancel-buzei.

    CLEAR ls_tbsl.
    READ TABLE gt_tbsl INTO ls_tbsl
                       WITH KEY bschl = ls_cancel-bschl.
    IF sy-subrc = 0.
      ls_cancel-koart = ls_tbsl-koart.
      ls_cancel-shkzg = ls_tbsl-shkzg.
    ENDIF.

    IF ls_cancel-shkzg = 'H'.
    ENDIF.

    CLEAR ls_mstp.
    READ TABLE gt_mstp INTO ls_mstp
               WITH KEY bukrs = pa_bukrs
                        gsber = pa_gsber
                        vkbur = pa_vkbur
                        lifnr = fs_trnhdr2-zidno.
    IF sy-subrc <> 0.
      READ TABLE gt_mstp INTO ls_mstp
                         WITH KEY bukrs = pa_bukrs
                                  gsber = pa_gsber
                                  vkbur = pa_vkbur
                                  zidno = fs_trnhdr2-zidno.
    ENDIF.

    CASE ls_cancel-bschl.
      WHEN '39'.
        ls_cancel-umskz = 'C'.
        ls_cancel-zuonr = fs_trnhdr2-xblnradv.
        ls_cancel-hkont = fs_trnhdr2-zidno.

        ls_cancel-wrbtr = fs_trnhdr2-wrbtr * -1.
        SELECT SINGLE name1 vbund
          FROM lfa1
          INTO (ls_cancel-ktext, ls_cancel-vbund)
          WHERE lifnr = fs_trnhdr2-zidno.

        CONCATENATE 'Cancel' gs_gtype-ltext ls_mstp-name1
                    ',' pa_xbln2
          INTO ls_cancel-text
          SEPARATED BY space.

      WHEN '40'.
        ls_cancel-wrbtr = fs_trnhdr2-wrbtr.
        ls_cancel-umskz = space.
        ls_cancel-zuonr = pa_xbln2.
        ls_cancel-hkont = gv_payhkont.
        SELECT SINGLE txt20
          FROM skat
          INTO ls_cancel-ktext
          WHERE spras = sy-langu
            AND ktopl = 'TSPC'
            AND saknr = gv_payhkont.

        SELECT SINGLE vbund
          FROM lfa1
          INTO ls_cancel-vbund
          WHERE lifnr = fs_trnhdr2-zidno.

        CONCATENATE 'Cancel' gs_gtype-ltext ls_mstp-name1
                    ',' fs_trnhdr2-xblnradv
          INTO ls_cancel-text
          SEPARATED BY space.
    ENDCASE.
    APPEND ls_cancel TO gt_cancel.
  ENDDO.
ENDFORM.                    " F_PREPARE_CANCEL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE
*&---------------------------------------------------------------------*
FORM f_simulate  USING    fs_trnhdr2  TYPE zf63trnhdr2.
  DATA : candh LIKE bapiache09,
         cangl TYPE STANDARD TABLE OF bapiacgl09 INITIAL SIZE 0,
         canap TYPE STANDARD TABLE OF bapiacap09 INITIAL SIZE 0,
         canar TYPE STANDARD TABLE OF bapiacar09 INITIAL SIZE 0,
         canex TYPE STANDARD TABLE OF bapiacextc INITIAL SIZE 0,
         canca TYPE STANDARD TABLE OF bapiaccr09 INITIAL SIZE 0,
         cancr TYPE STANDARD TABLE OF bapiackec9 INITIAL SIZE 0.

  DATA : ls_cancel LIKE LINE OF gt_cancel,
         lv_tabix  TYPE sy-tabix,
         lv_error,
         lv_stat   TYPE icon_d.

  PERFORM f_document_header USING    'RFBU' 'KZ'
                                     fs_trnhdr2-bktxt pa_xbln2
                            CHANGING candh.

  LOOP AT gt_cancel INTO ls_cancel.
    lv_tabix  = sy-tabix.
    CASE ls_cancel-koart.
      WHEN 'S'.
        PERFORM f_account_gl TABLES   cangl canca canex cancr
                             USING    ls_cancel '' ''
                                      'KZ' ls_cancel-text 'X'.
      WHEN 'K'.
        PERFORM f_account_payable TABLES   canap canca canex cancr
                                  USING    ls_cancel '' ls_cancel-text 'X'.
    ENDCASE.
  ENDLOOP.

  PERFORM f_bapi_simulate TABLES   cangl canap canar
                                   canca canex cancr
                          USING    candh
                          CHANGING lv_error.

  IF lv_stat <> icon_led_red.
    IF lv_error IS NOT INITIAL.
      lv_stat   = icon_led_red.
    ELSE.
      lv_stat   = icon_led_green.
      advgl[] = cangl[].
      advap[] = canap[].
      advar[] = canar[].
      advca[] = canca[].
      advex[] = canex[].
      advcr[] = cancr[].
      advdh = candh.
    ENDIF.
  ENDIF.

  LOOP AT gt_cancel INTO ls_cancel.
    ls_cancel-icon = lv_stat.
    MODIFY gt_cancel FROM ls_cancel TRANSPORTING icon.
  ENDLOOP.
ENDFORM.                    " F_SIMULATE

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATA
*&---------------------------------------------------------------------*
FORM f_update_data  USING    fu_belnr fu_gjahr
                    CHANGING fc_zidvc fc_kdvch fc_bktxt fc_hkont fc_txt20
                             fc_wrbtr fc_lifnr.
  DATA : ls_kas     TYPE zf63acckasexp,
         ls_nomor   TYPE zf63nomor,
         lv_nomor   TYPE zf63nomor-nomor,
         lv_advan   TYPE zf63ctrladv-advan,
         lv_zidvc2  TYPE zf63trnhdr2-zidvc2,
         ls_trnhdr2 LIKE LINE OF gt_trnhdr2,
         ls_detail  LIKE LINE OF gt_detail.

  READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
  IF sy-subrc = 0.
    fc_lifnr  = ls_trnhdr2-zidno.
    SELECT SINGLE *
      FROM zf63acckasexp
      INTO CORRESPONDING FIELDS OF ls_kas
      WHERE gsber = pa_gsber
        AND gtype = pa_gtype
        AND hkont = gv_payhkont.

    IF sy-subrc = 0.
      SELECT SINGLE *
        FROM zf63nomor
        INTO CORRESPONDING FIELDS OF ls_nomor
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND spmon = pa_budat(6)
          AND nmvch = ls_kas-nmvoucher
          AND shkzg = 'S'.

      lv_nomor  = ls_nomor-nomor + 1.

      CONCATENATE ls_nomor-kdvch '/' ls_nomor-spmon '/' lv_nomor INTO lv_zidvc2.
    ENDIF.

    SELECT SINGLE advan
      FROM zf63ctrladv
      INTO lv_advan
      WHERE bukrs = pa_bukrs
        AND vkbur = pa_vkbur
        AND gtype = pa_gtype
        AND lifnr = ls_trnhdr2-zidno.
    IF sy-subrc = 0.
      IF lv_advan > 0.
        lv_advan = lv_advan - 1.
      ENDIF.
    ENDIF.
  ENDIF.

  UPDATE zf63trnhdr2 SET belnrpadvrev = fu_belnr
                         gjahrpadvrev = fu_gjahr
                         budatpadvrev = pa_budat
                         userrev      = sy-uname
                         tglrev       = sy-datum
                         jamrev       = sy-uzeit
                         zidvc2       = lv_zidvc2
                     WHERE bukrs     = pa_bukrs
                       AND gsber     = pa_gsber
                       AND vkbur     = pa_vkbur
                       AND gtype     = pa_gtype
                       AND zidvc     = pa_zidv2
                       AND belnrpadv = pa_belnr
                       AND gjahr     = pa_vjahr.

  UPDATE zf63ctrladv SET advan = lv_advan
                     WHERE bukrs = pa_bukrs
                       AND vkbur = pa_vkbur
                       AND gtype = pa_gtype
                       AND lifnr = ls_trnhdr2-zidno.

  UPDATE zf63nomor SET nomor = lv_nomor
                   WHERE bukrs = pa_bukrs
                     AND vkbur = pa_vkbur
                     AND spmon = pa_budat(6)
                     AND nmvch = ls_kas-nmvoucher
                     AND shkzg = 'S'.

  fc_zidvc  = lv_zidvc2.
  fc_kdvch  = ls_nomor-kdvch.
  fc_bktxt  = ls_trnhdr2-bktxt.
  fc_hkont  = ls_trnhdr2-hkont.

  SELECT SINGLE txt20
    FROM skat
    INTO fc_txt20
    WHERE spras = sy-langu
      AND ktopl = 'TSPC'
      AND saknr = ls_trnhdr2-hkont.

  WRITE ls_trnhdr2-wrbtr TO fc_wrbtr CURRENCY 'IDR'.

  CONCATENATE ls_trnhdr2-bktxt ls_trnhdr2-xblnradv
  INTO ls_detail-description
  SEPARATED BY ','.

  SELECT SINGLE hkont
    FROM bsik
    INTO ls_detail-hkont
    WHERE bukrs = pa_bukrs
      AND lifnr = ls_trnhdr2-zidno
      AND gjahr = fu_gjahr
      AND belnr = fu_belnr.

  WRITE ls_trnhdr2-wrbtr TO ls_detail-wrbtrt CURRENCY 'IDR'.
  APPEND ls_detail TO gt_detail.
ENDFORM.                    " F_UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_CANCEL_ADVANCE
*&---------------------------------------------------------------------*
FORM f_print_cancel_advance  USING    fu_fname fu_zidvc2 fu_kdvch fu_bktxt
                                      fu_total.
  DATA : lv_funcname        TYPE tdsfname,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop.

  DATA : ls_trndtl2    LIKE LINE OF gt_trndtl2.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  READ TABLE gt_trndtl2 INTO ls_trndtl2 INDEX 1.

  PERFORM f_isi_form USING fu_zidvc2 'Cash/Bank Receipt Voucher'
                           fu_bktxt fu_total '' ls_trndtl2-znopol '' ''
                           pa_xbln2.

  lwa_output_option-tdnoprev = 'X'.
  lwa_output_option-tdnewid  = 'X'.

  CALL FUNCTION lv_funcname
    EXPORTING
      output_options     = lwa_output_option
      control_parameters = lwa_control_option
      user_settings      = 'X'
      gs_header          = gs_header
    TABLES
      gt_window3         = gt_window3
      gt_detail          = gt_detail
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
ENDFORM.                    " F_PRINT_CANCEL_ADVANCE
*&---------------------------------------------------------------------*
*&      Form  F_SEND_API_TO_TIMDES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_TRNHDR2_TRANSACTION_ID  text
*      -->P_LS_TRNHDR2_ZIDVC  text
*      -->P_LS_TRNHDR2_BELNRPADV  text
*      -->P_LS_TRNHDR2_BUDATPADV  text
*----------------------------------------------------------------------*
FORM f_send_api_to_timdes  USING    p_proses
                                    p_transaction_id
                                    p_zidvc
                                    p_belnr
                                    p_budat.

  DATA: lv_str TYPE string.
  DATA: lv_json TYPE string.
  DATA: lv_proses TYPE char15.
  lv_proses = p_proses.
  IF lv_proses = 'MDS_POSTADVUJP'.
    CONCATENATE '{ "transaction_id": "' p_transaction_id  '", "no_voucher_sap":" ' p_zidvc
                '", "no_doc_sap":" ' p_belnr '", "date_posting_doc_sap" : " '  p_budat '" }' INTO lv_json.

    PERFORM f_post_data_json(ztdsit_i001) USING lv_json lv_proses sy-subrc lv_str.
  ELSEIF lv_proses = 'MDS_CAN_ADVUJP'.
    CONCATENATE '{ "transaction_id": "' p_transaction_id  '", "no_voucher_sap":" ' p_zidvc
                '", "no_doc_sap":" ' p_belnr '", "date_posting_doc_sap" : " '  p_budat '" }' INTO lv_json.

    PERFORM f_post_data_json(ztdsit_i001) USING lv_json lv_proses sy-subrc lv_str.
  ENDIF.
ENDFORM.
