*----------------------------------------------------------------------*
*   INCLUDE ZFNOTA_RETURF01                                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: ld_numki_so LIKE zsrange-numki_so,
        ld_vbeln    LIKE vbrk-vbeln,
        ld_vkbur    LIKE knvv-vkbur.

  DATA: BEGIN OF lt_zfrange OCCURS 0.
          INCLUDE STRUCTURE zfnr_range.
        DATA: END OF lt_zfrange.

  SELECT SINGLE vkbur
    FROM knvv
    INTO va_vkbur
    WHERE kunnr EQ pa_kunnr AND
          vkorg EQ pa_vkorg.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = t_user.

* Penambahan untuk ZRA* & ZD* untuk tanggal billing 01-03-2007
* tidak diambil
  SELECT fkart fkdat
    INTO (ra_fkart-low, va_fkdat)
    FROM zfnrexclude.
    ra_fkart-sign    = 'I'.
    ra_fkart-option  = 'CP'.
    APPEND ra_fkart.
  ENDSELECT.

  IF va_fkdat IS INITIAL.
    va_fkdat = '20070301'.
    ra_fkart-low     = 'ZRA*'.
    ra_fkart-sign    = 'I'.
    ra_fkart-option  = 'CP'.
    APPEND ra_fkart.
    ra_fkart-low     = 'ZD*'.
    ra_fkart-sign    = 'I'.
    ra_fkart-option  = 'CP'.
    APPEND ra_fkart.
  ENDIF.

* Get range billing document
  IF radio1 EQ 'X'.
    IF so_vbeln IS INITIAL.
      SELECT *
        FROM zfnr_range
        INTO CORRESPONDING FIELDS OF TABLE lt_zfrange
        WHERE vkbur EQ pa_vkbur.

      LOOP AT lt_zfrange.
        IF pa_vkorg = '8020'.
          CONCATENATE '1' lt_zfrange-numki_so '*' INTO ld_vbeln.
        ELSE.
          CONCATENATE  lt_zfrange-numki_so '*' INTO ld_vbeln.
        ENDIF.
        so_vbeln-low    = ld_vbeln.
        so_vbeln-sign   = 'I'.
        so_vbeln-option = 'CP'.
        APPEND so_vbeln.
      ENDLOOP.

*      SELECT SINGLE numki_so
*        FROM zsrange
*        INTO ld_numki_so
*        WHERE vkbur EQ ld_vkbur.
*
*      CONCATENATE '1' ld_numki_so '*' INTO ld_vbeln.
*      so_vbeln-low    = ld_vbeln.
*      so_vbeln-sign   = 'I'.
*      so_vbeln-option = 'CP'.
*      APPEND so_vbeln.
    ENDIF.
    SELECT SINGLE * INTO wa_zfnrcncust
      FROM zfnrcncust
      WHERE vkorg = pa_vkorg  AND
            vkbur = pa_vkbur  AND
            kunnr = pa_kunnr.
  ENDIF.

* Validasi sales office yang boleh print nota retur
  SELECT *
    FROM zfnrvalid
    INTO CORRESPONDING FIELDS OF TABLE t_zfnrvalid
    WHERE vkorg EQ pa_vkorg AND
          vkbur EQ pa_vkbur AND
          datab GE sy-datum.
  IF sy-subrc EQ 0.
    va_valcust = 0.
  ELSE.
* Validasi customer NR
    SELECT SINGLE *
      FROM zfnrcustm
      INTO t_zfnrcustm
      WHERE vkorg EQ pa_vkorg AND
            vkbur EQ pa_vkbur AND
            kunnr EQ pa_kunnr.
    IF sy-subrc EQ 0.
      va_valcust = 0.
    ELSE.
      va_valcust = 1.
    ENDIF.
  ENDIF.

* Get "KEPADA PENJUAL"
  SELECT SINGLE pkpname pkpaddrs1 pkpaddrs2 pkppostal pkpcity pkpnpwp pkpkuh
    FROM zgdtxdt0005
    INTO (wa_header-pkpname, wa_header-pkpaddrs1, wa_header-pkpaddrs2, wa_header-pkppostal, wa_header-pkpcity, wa_header-pkpnpwp, wa_header-pkpkuh)
    WHERE bukrs EQ pa_vkorg AND
          brnch EQ pa_vkorg.

  SELECT *
    FROM zgdtxdt0005
    INTO CORRESPONDING FIELDS OF TABLE t_alamat
    WHERE bukrs EQ pa_vkorg AND
          brnch EQ pa_vkorg.

* Get range
  SELECT SINGLE *
    FROM zfnrrange
    INTO t_zfnrrange
    WHERE vkorg EQ pa_vkorg AND
          vkbur EQ pa_vkbur AND
          kunnr EQ pa_kunnr.

  IF sy-subrc EQ 0.
    va_ranges = 0.
  ELSE.
    va_ranges = 1.
  ENDIF.

  SELECT *
    FROM zfnrstatus
    INTO CORRESPONDING FIELDS OF TABLE t_zfnrstatus.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  CASE 'X'.
    WHEN radio1.
      SELECT *
        FROM zfppnnrd
        INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrd
        WHERE bukrs EQ pa_vkorg AND
*              vkbur EQ pa_vkbur AND
              kunnr EQ pa_kunnr.

      IF va_mixlive EQ 'X'.
        IF pa_kunnr EQ 'TSB8071'.
          PERFORM f_get_billing USING '0'.
        ELSE.
          PERFORM f_get_billing USING '1'.
        ENDIF.

        LOOP AT t_detail.
          IF t_detail-fkdat GE va_fkdat.
*            IF t_data-fkart IN ra_fkart.
            IF t_detail-auart IN ra_fkart.
              DELETE t_detail.
            ENDIF.
          ENDIF.
        ENDLOOP.

        CASE pa_vkorg.
          WHEN '8020'.
            SELECT *
              FROM zsl_hsales
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                    vkbur EQ pa_vkbur AND
*                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr EQ pa_kunnr.
          WHEN '8070'.
            SELECT *
              FROM zssutdt005
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                    vkbur EQ pa_vkbur AND
*                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr EQ pa_kunnr.
          WHEN OTHERS.
        ENDCASE.

        PERFORM f_filter_legacy.

        IF t_zsl_hsales[] IS NOT INITIAL.
          CASE pa_vkorg.
            WHEN '8020'.
              SELECT *
              FROM zsl_dsales
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_dsales
              FOR ALL ENTRIES IN t_zsl_hsales
              WHERE vbeln EQ t_zsl_hsales-vbeln AND
                    gjahr EQ t_zsl_hsales-gjahr.
            WHEN '8070'.
              SELECT *
              FROM zssutdt006
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_dsales
              FOR ALL ENTRIES IN t_zsl_hsales
              WHERE vbeln EQ t_zsl_hsales-vbeln AND
                    gjahr EQ t_zsl_hsales-gjahr.
            WHEN OTHERS.
          ENDCASE.

          t_matnr[] = t_zsl_dsales[].
          SORT t_matnr BY matnr.
          DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.
          IF t_matnr[] IS NOT INITIAL.
            SELECT a~matnr a~meins
                   b~maktx
              FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
              INTO CORRESPONDING FIELDS OF TABLE t_mara
              FOR ALL ENTRIES IN t_matnr
              WHERE a~matnr EQ t_matnr-matnr.
          ENDIF.
        ENDIF.
      ELSE.
        IF va_live EQ 'X'.
          IF pa_kunnr EQ 'TSB8071'.
            PERFORM f_get_billing USING '0'.
          ELSE.
            PERFORM f_get_billing USING '1'.
          ENDIF.

          LOOP AT t_detail.
            IF t_detail-fkdat GE va_fkdat.
*              IF t_data-fkart IN ra_fkart.
              IF t_detail-auart IN ra_fkart.
                DELETE t_detail.
              ENDIF.
            ENDIF.
          ENDLOOP.

          t_matnr1[] = t_detail[].
          SORT t_matnr1 BY matnr.
          DELETE ADJACENT DUPLICATES FROM t_matnr1 COMPARING matnr.
          IF t_matnr1[] IS NOT INITIAL.
            SELECT a~matnr a~meins
                   b~maktx
              FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
              INTO CORRESPONDING FIELDS OF TABLE t_mara
              FOR ALL ENTRIES IN t_matnr1
              WHERE a~matnr EQ t_matnr1-matnr.
          ENDIF.
        ELSE.
          CASE pa_vkorg.
            WHEN '8020'.
              SELECT *
              FROM zsl_hsales
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                    vkbur EQ pa_vkbur AND
*                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr EQ pa_kunnr.
            WHEN '8070'.
              SELECT *
              FROM zssutdt005
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                    vkbur EQ pa_vkbur AND
*                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr EQ pa_kunnr.
            WHEN OTHERS.
          ENDCASE.

          PERFORM f_filter_legacy.

          IF t_zsl_hsales[] IS NOT INITIAL.
            CASE pa_vkorg.
              WHEN '8020'.
                SELECT *
                FROM zsl_dsales
                INTO CORRESPONDING FIELDS OF TABLE t_zsl_dsales
                FOR ALL ENTRIES IN t_zsl_hsales
                WHERE vbeln EQ t_zsl_hsales-vbeln AND
                      gjahr EQ t_zsl_hsales-gjahr.
              WHEN '8070'.
                SELECT *
                FROM zssutdt006
                INTO CORRESPONDING FIELDS OF TABLE t_zsl_dsales
                FOR ALL ENTRIES IN t_zsl_hsales
                WHERE vbeln EQ t_zsl_hsales-vbeln AND
                      gjahr EQ t_zsl_hsales-gjahr.
              WHEN OTHERS.
            ENDCASE.

            t_matnr[] = t_zsl_dsales[].
            SORT t_matnr BY matnr.
            DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.
            IF t_matnr[] IS NOT INITIAL.
              SELECT a~matnr a~meins
                     b~maktx
                FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
                INTO CORRESPONDING FIELDS OF TABLE t_mara
                FOR ALL ENTRIES IN t_matnr
                WHERE a~matnr EQ t_matnr-matnr.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio2.
      IF va_usrgrp IS INITIAL.
        SELECT *
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                                 a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~nonr  EQ b~nonr
          INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh
          WHERE a~vrsio   EQ space    AND
                a~bukrs   EQ pa_vkorg AND
                a~monat   EQ pa_monat AND
                b~gjahr   EQ pa_gjahr AND
                b~vkbur   EQ pa_vkbur AND
                a~kunnr   IN so_kunnr AND
                a~nonr    IN so_nonr  AND
                a~bdcflag EQ space.
        SORT t_zfppnnrh BY kunnr nonr.
        DELETE ADJACENT DUPLICATES FROM t_zfppnnrh COMPARING kunnr nonr.
      ELSE.
        SELECT *
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                                 a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~nonr  EQ b~nonr
          INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh
          WHERE a~vrsio   EQ pa_vrsio AND
                a~bukrs   EQ pa_vkorg AND
                a~monat   EQ pa_monat AND
                b~gjahr   EQ pa_gjahr AND
                b~vkbur   EQ pa_vkbur AND
                a~kunnr   IN so_kunnr AND
                a~nonr    IN so_nonr  AND
                a~bdcflag EQ space.
        SORT t_zfppnnrh BY kunnr nonr.
        DELETE ADJACENT DUPLICATES FROM t_zfppnnrh COMPARING kunnr nonr.
      ENDIF.

    WHEN radio4.
      SELECT a~kunnr a~name1 a~stceg sortl a~stkza
             name_co
        FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                       JOIN adrc AS c ON a~adrnr EQ c~addrnumber
        INTO CORRESPONDING FIELDS OF TABLE t_kna1
        WHERE a~kunnr IN so_kunnr AND
              b~vkorg EQ pa_vkorg.
      IF va_auth EQ 1.
        PERFORM f_get_data1.      "per sales office
      ELSE.
        PERFORM f_get_data2.      "all sales office
      ENDIF.

    WHEN radio5.
      SELECT a~bukrs a~kunnr a~monat a~gjahr a~nonr a~nrdt a~waers
             a~ttlnr a~dppnr a~ppnnr a~ttlcn a~dppcn a~ppncn
             b~vkbur b~belnr
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                                 a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~nonr  EQ b~nonr
        INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh
        WHERE a~bukrs   EQ pa_vkorg AND
              b~vkbur   IN so_vkbur AND
              a~monat   EQ pa_monat AND
              a~gjahr   EQ pa_gjahr AND
              a~bdcflag EQ space.
      SORT t_zfppnnrh BY kunnr nonr.
      DELETE ADJACENT DUPLICATES FROM t_zfppnnrh COMPARING kunnr nonr.

    WHEN radio6.
*      READ TABLE t_close WITH KEY vkorg = pa_vkorg
*                                  vkbur = pa_vkbur.
*      va_subrc = sy-subrc.
*      CALL SCREEN 600.

    WHEN radio7.
      IF va_valcust = 0.
        MESSAGE i000(zab) WITH 'Nota retur can not be printed'.
      ELSE.
        SELECT *
          FROM zfppnnrdtl
          INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrdtl
          WHERE bukrs EQ pa_vkorg AND
                vkbur EQ pa_vkbur AND
                kunnr EQ pa_kunnr AND
                nonr  IN so_nonr
          ORDER BY PRIMARY KEY.
        IF t_zfppnnrdtl[] IS NOT INITIAL.
          SELECT *
            FROM zfppnnrh
            INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh
            WHERE bukrs EQ pa_vkorg AND
                  kunnr EQ pa_kunnr AND
                  nonr  IN so_nonr.

          SELECT *
            FROM zfppnnrd
            INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrd
            WHERE bukrs EQ pa_vkorg AND
                  vkbur EQ pa_vkbur AND
                  kunnr EQ pa_kunnr AND
                  nonr  IN so_nonr.
        ELSE.
          MESSAGE s000(zab) WITH 'Data not found'.
        ENDIF.
      ENDIF.

    WHEN radio10.
      SELECT *
        FROM zfppnnrh_d
        INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh_d
        WHERE bukrs EQ pa_vkorg  AND
              kunnr IN so_kunnr  AND
              monat IN so_mona1  AND
              gjahr IN so_gjah1.

    WHEN radio11.
*      SELECT a~bukrs b~vkbur a~kunnr a~monat a~gjahr
*             b~belnr b~zuonr b~budat b~nonr b~nrdt b~status b~refnr
      SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
             a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
             b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
             b~ttlcn b~status b~refnr
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                                 a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~monat EQ b~monat AND
                                                 a~gjahr EQ b~gjahr AND
                                                 a~nonr  EQ b~nonr
        INTO CORRESPONDING FIELDS OF TABLE t_radio11
*        WHERE a~vrsio EQ space    AND
        WHERE a~vrsio IN so_vrsio AND
              a~bukrs EQ pa_vkorg AND
*              b~vkbur EQ pa_vkbur AND
              b~vkbur IN so_vkbur AND
*              a~kunnr EQ pa_kunnr AND
              a~kunnr IN so_kunnr AND
              a~nonr  IN so_nonr  AND
              b~zuonr IN so_vbeln AND
              b~budat IN so_fkdat.

      IF t_radio11[] IS NOT INITIAL.
        IF va_live EQ 'X'.
          SELECT vbeln vbeln waerk vkorg fkdat netwr
                 kunrg stceg mwsbk fkart ktgrd
            FROM vbrk
            INTO CORRESPONDING FIELDS OF TABLE t_vbrk
            FOR ALL ENTRIES IN t_radio11
            WHERE vbeln EQ t_radio11-belnr AND
*                fkdat IN so_fkdat AND
                  vkorg EQ pa_vkorg AND
                  vbtyp IN ('O', '6') AND
*                  kunrg EQ pa_kunnr AND
                  kunrg IN so_kunnr AND
                  fksto EQ space    AND
                  ktgrd NE '00'
            ORDER BY PRIMARY KEY.
          "AND
*                vkbur EQ pa_vkbur.
          DELETE ADJACENT DUPLICATES FROM t_vbrk COMPARING vbeln.
        ELSE.
          SELECT *
            FROM zsl_hsales
            INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
            FOR ALL ENTRIES IN t_radio11
            WHERE vkorg EQ pa_vkorg AND
*                vkbur EQ pa_vkbur AND
                  vbeln EQ t_radio11-belnr AND
                  vbtyp EQ 'O'      AND
*                fkdat IN so_fkdat AND
*                  kunnr EQ pa_kunnr AND
                  kunnr IN so_kunnr AND
                  tax_status EQ 'T1'.
        ENDIF.
      ENDIF.

    WHEN radio14.
      SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
             a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
             b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
             b~ttlcn b~status b~refnr
        INTO CORRESPONDING FIELDS OF TABLE t_radio11
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                                 a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~monat EQ b~monat AND
                                                 a~gjahr EQ b~gjahr AND
                                                 a~nonr  EQ b~nonr
        FOR ALL ENTRIES IN t_zfstppnnr
        WHERE a~vrsio = space
          AND a~bukrs = t_zfstppnnr-bukrs
          AND a~kunnr = t_zfstppnnr-kunnr
          AND a~monat = t_zfstppnnr-monat
          AND a~gjahr = t_zfstppnnr-gjahr
          AND a~nonr  = t_zfstppnnr-nonr
          AND b~vkbur = t_zfstppnnr-vkbur
          AND b~zuonr = t_zfstppnnr-zuonr.

      IF t_radio11[] IS NOT INITIAL.
        SELECT vbeln vbeln waerk vkorg fkdat netwr
               kunrg stceg mwsbk fkart ktgrd
          FROM vbrk
          INTO CORRESPONDING FIELDS OF TABLE t_vbrk
          FOR ALL ENTRIES IN t_radio11
          WHERE vbeln EQ t_radio11-belnr AND
                vkorg EQ t_radio11-bukrs AND
                vbtyp IN ('O', '6')      AND
                kunrg EQ t_radio11-kunnr AND
                fksto EQ space           AND
                ktgrd NE '00'
          ORDER BY PRIMARY KEY.
        DELETE ADJACENT DUPLICATES FROM t_vbrk COMPARING vbeln.

        SELECT *
          FROM zsl_hsales
          INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
          FOR ALL ENTRIES IN t_radio11
          WHERE vkorg EQ t_radio11-bukrs AND
                vbeln EQ t_radio11-belnr AND
                vbtyp EQ 'O'             AND
                kunnr EQ t_radio11-kunnr AND
                tax_status EQ 'T1'.
      ENDIF.
  ENDCASE.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  DATA: ld_error(100).

  CASE 'X'.
    WHEN radio1.
      PERFORM f_alv TABLES t_out1.

    WHEN radio2.
      PERFORM f_alv TABLES t_out2.

    WHEN radio3.
      PERFORM f_alv TABLES t_out3.

    WHEN radio4.
      PERFORM f_alv TABLES t_out4.

    WHEN radio5.
      PERFORM f_alv TABLES t_out5.

    WHEN radio10.
      PERFORM f_alv TABLES t_zfppnnrh_d.

    WHEN radio11 OR radio14.
      PERFORM f_alv TABLES t_radio11.

    WHEN radio12.
      PERFORM f_alv TABLES t_vdata.

    WHEN radio15.
      PERFORM f_alv TABLES gt_out.
  ENDCASE.
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
  PERFORM f_alv_variant_exist USING   pa_vari
                                      d_alv_variant.

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

  CASE 'X'.
    WHEN radio1.
      IF va_preview EQ 1.
        PERFORM f_fieldcatg USING ft_report:
          'MATNR' 'VBRP' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '',
          'ARKTX' 'VBRP' 'ARKTX' '' '' '' '' '' '' '' '' '' '' '' '',
          'VRKME' 'VBRP' 'VRKME' 'X' '' '' '' '' '' '' '' '' '' '' '',
          'WAERK' 'VBRP' 'WAERK' 'X' '' '' '' '' '' '' '' '' '' '' ''.

        IF wa_zfnrcncust IS NOT INITIAL.
          PERFORM f_fieldcatg USING ft_report:
            'FKIMG' 'VBRP' 'FKIMG' '' '13' 'Kuantum' '' '' '' '' '' '' 'VRKME' '' 'X'.
        ELSE.
          PERFORM f_fieldcatg USING ft_report:
            'FKIMG' 'VBRP' 'FKIMG' '' '13' 'Kuantum' '' '' '' '' '' '' 'VRKME' '' ''.
        ENDIF.

        IF va_ranges EQ 0 OR wa_zfnrcncust IS NOT INITIAL.
          PERFORM f_fieldcatg USING ft_report:
            'HRGSAT' 'VBRP' 'NETWR' '' '15' 'Hrg satuan inc.PPN' '' '' '' '' '' 'WAERK' '' '' 'X'.
        ELSE.
          PERFORM f_fieldcatg USING ft_report:
            'HRGSAT' 'VBRP' 'NETWR' '' '15' 'Hrg satuan inc.PPN' '' '' '' '' '' 'WAERK' '' '' ''.
        ENDIF.

        PERFORM f_fieldcatg USING ft_report:
          'KZWI1' 'VBRP' 'KZWI1' '' '' 'Gross value' '' '' '' '' '' 'WAERK' '' '' ''.

        IF va_ranges EQ 0 OR wa_zfnrcncust IS NOT INITIAL.
          PERFORM f_fieldcatg USING ft_report:
            'SKFBP' 'VBRP' 'SKFBP' '' '' 'Discount' '' '' '' '' '' 'WAERK' '' '' 'X'.
        ELSE.
          PERFORM f_fieldcatg USING ft_report:
            'SKFBP' 'VBRP' 'SKFBP' '' '' 'Discount' '' '' '' '' '' 'WAERK' '' '' ''.
        ENDIF.

        PERFORM f_fieldcatg USING ft_report:
          'KZWI5' 'VBRP' 'KZWI5' '' '' 'Net value' 'X' '' '' '' '' 'WAERK' '' '' '',
          'NETWR' 'VBRP' 'NETWR' 'X' '' '' 'X' '' '' '' '' 'WAERK' '' '' ''.
      ELSE.
        PERFORM f_fieldcatg USING ft_report:
          'VKORG' 'VBRK' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '',
          'FKART' 'VBRK' 'FKART' '' '' '' '' '' '' '' '' '' '' '' '',
          'KTGRD' 'VBRK' 'KTGRD' '' '' '' '' '' '' '' '' '' '' '' '',
          'VBELN' 'VBRK' 'VBELN' '' '' '' '' 'X' '' '' '' '' '' '' '',
          'FKDAT' 'VBRK' 'FKDAT' '' '' '' '' '' '' '' '' '' '' '' '',
          'STCEG' 'VBRK' 'STCEG' '' '' 'N.P.W.P' '' '' '' '' '' '' '' '' '',
          'AMTCN' 'VBRK' 'NETWR' '' '' 'DPP CN' 'X' '' '' '' ''
          'WAERK' '' '' '',
          'VATCN' 'VBRK' 'NETWR' '' '' 'PPN CN' 'X' '' '' '' '' 'WAERK'
          '' '' '',
          'NETWR' 'VBRK' 'NETWR' '' '' 'Total CN' 'X' '' '' '' '' 'WAERK'
          '' '' ''.
      ENDIF.

    WHEN radio2.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' '' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' '' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' ''.

    WHEN radio3.
      IF NOT va_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'ICON1' '' '' '' '4' '' '' '' '' '' '' '' '' '' ''.
      ENDIF.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '',
        'MESSAGE' '' '' '' '50' 'Message' '' '' '' '' '' '' '' '' ''.

    WHEN radio4.
      PERFORM f_fieldcatg USING ft_report:
        'VRSIO' 'ZFPPNNRH' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
        'FKART' 'VBRK' 'FKART' '' '' '' '' '' '' '' '' '' '' '' '',
        'KTGRD' 'VBRK' 'KTGRD' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NAME1' 'ZFPPNNRH' 'NAME1' '' '' 'Customer Name' '' '' '' '' ''
        '' '' '' '',
        'NAME_CO' 'ZFPPNNRH' 'NAME_CO' 'X' '' '' '' '' '' '' '' '' '' '' '',
        'EXTEND' '' '' 'X' '120' 'Extended C/O Name' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFPPNNRH' 'STCEG' '' '' 'N.P.W.P' '' '' '' '' '' '' ''
        '' '',
        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRRC' 'ZFPPNNRH' 'BELNRRC' '' '' 'Acc.Doc.' '' 'X' '' '' ''
        '' '' '' '',
        'ZUONR' 'ZFPPNNRH' 'ZUONR' '' '' 'No CN' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' 'ZFPPNNRD' 'BUDAT' '' '' 'Tgl CN' '' '' '' '' '' '' ''
        '' '',
        'DPPCN' 'ZFPPNNRH' 'DPPCN' '' '' 'DPP CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'TTLCN' 'ZFPPNNRH' 'TTLCN' '' '' 'Total CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' '' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' '' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' ''.
      PERFORM f_fieldcatg USING ft_report:
        'VATPR1' 'ZFPPNNRH' 'VATPR1' '' '' 'Reff.FP 1' '' '' '' '' '' '' '' '' '',
        'VATPR2' 'ZFPPNNRH' 'VATPR2' 'X' '' 'Reff.FP 2' '' '' '' '' '' '' '' '' '',
        'VATPR3' 'ZFPPNNRH' 'VATPR3' 'X' '' 'Reff.FP 3' '' '' '' '' '' '' '' '' '',
        'VATPR4' 'ZFPPNNRH' 'VATPR4' 'X' '' 'Reff.FP 4' '' '' '' '' '' '' '' '' ''.
      PERFORM f_fieldcatg USING ft_report:
        'NPPKP' 'KNA1' 'STCEG' '' '' 'N.P.P.K.P' '' '' '' '' '' '' '' '' '',
        'STATUS' 'ZFPPNNRD' 'STATUS' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZDESC' 'ZFNRSTATUS' 'ZDESC' '' '' '' '' '' '' '' '' '' '' '' '',
        'REFNR' 'ZFPPNNRD' 'REFNR' '' '' '' '' '' '' '' '' '' '' '' '',
        'ERDT1' '' '' 'X' '12' 'Created date' '' '' '' '' '' '' '' '' '',
        'VATDTSAP' '' '' 'X' '12' 'VAT Date SAP' '' '' '' '' '' '' '' '' '',
        'VATDT1' '' '' 'X' '12' 'VAT Date NR' '' '' '' '' '' '' '' '' ''.

    WHEN radio5.
      IF NOT va_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'ICON' '' '' '' '4' 'Sts.' '' '' '' '' '' '' '' '' ''.
      ENDIF.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'BSIS' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' 'X' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' 'X' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'DPPCN' 'ZFPPNNRH' 'DPPCN' 'X' '' 'DPP CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLCN' 'ZFPPNNRH' 'TTLCN' 'X' '' 'Total CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'SELISIH' '' '' '' '15' 'Selisih' '' '' '' '' '' 'WAERS' '' '' ''.
      IF NOT va_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'MSG' '' '' '' '50' 'Message' '' '' '' '' '' '' '' '' ''.
      ENDIF.

    WHEN radio10.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'NAME1' 'ZFPPNNRH' 'NAME1' '' '' 'Customer Name' '' '' '' '' ''
        '' '' '' '',
        'NAME_CO' 'ZFPPNNRH' 'NAME_CO' 'X' '' '' '' '' '' '' '' '' '' '' '',
        'EXTEND' '' '' 'X' '120' 'Extended C/O Name' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFPPNNRH' 'STCEG' '' '' 'N.P.W.P' '' '' '' '' '' '' ''
        '' '',
        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
        'DPPCN' 'ZFPPNNRH' 'DPPCN' '' '' 'DPP CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'TTLCN' 'ZFPPNNRH' 'TTLCN' '' '' 'Total CN' 'X' '' '' '' ''
        'WAERS' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' '' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' '' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' ''.

    WHEN radio11 OR radio14.
*      PERFORM f_fieldcatg USING ft_report:
*        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
*        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
*        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
*        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
*        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
*        'BELNR' 'ZFPPNNRD' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
*        'ZUONR' 'ZFPPNNRD' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '',
*        'BUDAT' 'ZFPPNNRD' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '',
*        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
*        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
*        'STATUS' 'ZFPPNNRD' 'STATUS' '' '' '' '' '' '' '' '' '' '' '' '',
*        'ZDESC' 'ZFNRSTATUS' 'ZDESC' '' '' '' '' '' '' '' '' '' '' '' '',
*        'REFNR' 'ZFPPNNRD' 'REFNR' '' '' '' '' '' '' '' '' '' '' '' ''.
      PERFORM f_fieldcatg USING ft_report:
        'VRSIO' 'ZFPPNNRH' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
        'FKART' 'VBRK' 'FKART' '' '' '' '' '' '' '' '' '' '' '' '',
        'KTGRD' 'VBRK' 'KTGRD' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' 'Customer' '' '' '' '' '' '' ''
        '' '',
        'NAME1' 'ZFPPNNRH' 'NAME1' '' '' 'Customer Name' '' '' '' '' ''
        '' '' '' '',
        'NAME_CO' 'ZFPPNNRH' 'NAME_CO' 'X' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFPPNNRH' 'STCEG' '' '' 'N.P.W.P' '' '' '' '' '' '' ''
        '' '',
        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRRC' 'ZFPPNNRH' 'BELNRRC' '' '' 'Acc.Doc.' '' 'X' '' '' ''
        '' '' '' '',
        'BELNR' 'ZFPPNNRD' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR' 'ZFPPNNRH' 'ZUONR' '' '' 'No CN' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' 'ZFPPNNRH' 'BUDAT' '' '' 'Tgl CN' '' '' '' '' '' '' ''
        '' '',
        'DPPCN' 'ZFPPNNRH' 'DPPCN' '' '' 'DPP CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLCN' 'ZFPPNNRH' 'TTLCN' '' '' 'Total CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' '' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' '' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' ''.
      PERFORM f_fieldcatg USING ft_report:
        'VATPR1' 'ZFPPNNRH' 'VATPR1' '' '' 'Reff.FP 1' '' '' '' '' '' '' '' '' '',
        'VATPR2' 'ZFPPNNRH' 'VATPR2' 'X' '' 'Reff.FP 2' '' '' '' '' '' '' '' '' '',
        'VATPR3' 'ZFPPNNRH' 'VATPR3' 'X' '' 'Reff.FP 3' '' '' '' '' '' '' '' '' '',
        'VATPR4' 'ZFPPNNRH' 'VATPR4' 'X' '' 'Reff.FP 4' '' '' '' '' '' '' '' '' ''.
      PERFORM f_fieldcatg USING ft_report:
        'NPPKP' 'KNA1' 'STCEG' '' '' 'N.P.P.K.P' '' '' '' '' '' '' '' '' '',
        'STATUS' 'ZFPPNNRD' 'STATUS' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZDESC' 'ZFNRSTATUS' 'ZDESC' '' '30' '' '' '' '' '' '' '' '' '' '',
        'REFNR' 'ZFPPNNRD' 'REFNR' '' '' '' '' '' '' '' '' '' '' '' ''.

    WHEN radio12.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'ZFPPNNRH' 'NAME1' '' '' 'Customer Name' '' '' '' '' ''
        '' '' '' '',
        'NAME_CO' 'ZFPPNNRH' 'NAME_CO' '' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFPPNNRH' 'STCEG' '' '' 'N.P.W.P' '' '' '' '' '' '' ''
        '' '',
        'NPPKP' 'KNA1' 'STCEG' '' '' 'N.P.P.K.P' '' '' '' '' '' '' '' '' '',
        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRRC' 'ZFPPNNRH' 'BELNRRC' '' '' 'Acc.Doc.' '' '' '' '' ''
        '' '' '' '',
        'ZUONR' 'ZFPPNNRH' 'ZUONR' '' '' 'No CN' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' 'ZFPPNNRH' 'BUDAT' '' '' 'Tgl CN' '' '' '' '' '' '' ''
        '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' '' '' '' 'IDR' ''
        '' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' 'IDR' ''
        '' '' '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'STATUS' 'ZFPPNNRH' 'STATUS' '' '' 'Status' '' '' '' '' '' '' '' '' '',
        'REFNR' 'ZFPPNNRH' 'REFNR' '' '' 'Ref.NR' '' '' '' '' '' '' '' '' ''.

    WHEN radio15.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'ZFPPNNRH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFPPNNRD' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFPPNNRH' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
        'MONAT' 'ZFPPNNRH' 'MONAT' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFPPNNRH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR' 'ZFPPNNRH' 'ZUONR' '' '' 'No CN' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' 'ZFPPNNRH' 'BUDAT' '' '' 'Tgl CN' '' '' '' '' '' '' ''
        '' '',
        'WAERS' 'ZFPPNNRH' 'WAERS' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'DPPCN' 'ZFPPNNRH' 'DPPCN' '' '' 'DPP CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNCN' 'ZFPPNNRH' 'PPNCN' '' '' 'PPN CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLCN' 'ZFPPNNRH' 'TTLCN' '' '' 'Total CN' '' '' '' '' ''
        'WAERS' '' '' '',
        'NONR' 'ZFPPNNRH' 'NONR' '' '' 'No NR' '' '' '' '' '' '' '' '' '',
        'NRDT' 'ZFPPNNRH' 'NRDT' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '',
        'DPPNR' 'ZFPPNNRH' 'DPPNR' '' '' 'DPP NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'PPNNR' 'ZFPPNNRH' 'PPNNR' '' '' 'PPN NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'TTLNR' 'ZFPPNNRH' 'TTLNR' '' '' 'Total NR' '' '' '' '' ''
        'WAERS' '' '' '',
        'VATPR' 'ZFPPNNRH' 'VATPR1' '' '' 'Referensi FP' '' '' '' '' '' '' ''
        '' '',
        'VATDT' 'ZFPPNNRH' 'VATDT1' '' '' 'Tgl.Ref.FP' '' '' '' '' '' '' ''
        '' ''.
  ENDCASE.
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
                          VALUE(fu_input).

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

  CASE 'X'.
    WHEN radio1.
      IF va_preview = 0.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.
    WHEN radio2.
      fu_layout-box_fieldname      = 'CHECK'.
    WHEN radio3.
      IF va_proc IS INITIAL.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.
    WHEN radio5.
      IF va_proc IS INITIAL.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.
  ENDCASE.
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

  CASE 'X'.
    WHEN radio1.
      IF va_preview = 1.
        CLEAR ld_sort.
        ld_sort-fieldname = 'MATNR'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
      ELSE.
        CLEAR ld_sort.
        ld_sort-fieldname = 'VBELN'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
      ENDIF.
    WHEN radio2.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NONR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN radio3.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NONR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN radio4 OR radio11 OR radio14.
      CLEAR ld_sort.
      ld_sort-fieldname = 'VKBUR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NONR'.
      ld_sort-up        = 'X'.
      ld_sort-subtot    = 'X'.
      ld_sort-group     = 'UL'.
      APPEND ld_sort TO fu_sort.
    WHEN radio5.
      CLEAR ld_sort.
      ld_sort-fieldname = 'VKBUR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'HKONT'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
  ENDCASE.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  CASE 'X'.
    WHEN radio1.
      sy-title = 'Input Nota Retur'.
    WHEN radio2.
      sy-title = 'Delete Nota Retur'.
    WHEN radio3.
      sy-title = 'Upload Nota Retur'.
    WHEN radio4.
      sy-title = 'Report'.
    WHEN radio5.
      sy-title = 'Reconsiliasi Nota Retur & CN'.
  ENDCASE.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_input_header.
    WHEN radio3.
      PERFORM f_upload_header.
  ENDCASE.
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
  REFRESH: t_out1, t_data, t_zfppnnrh, t_zfppnnrd, t_out2, t_data1,
           t_record, t_record1, t_out3.
  CLEAR: t_out1, t_data, t_zfppnnrh, t_zfppnnrd, t_out2, t_data1,
         t_record, t_record1, t_out3.

  CLEAR: ttlnr, ppnnr, dppnr.
  CLEAR: va_auth.
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
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  CASE 'X'.
    WHEN radio1.
      IF va_preview EQ 1.
        IF wa_zfnrcncust IS INITIAL.
          SET PF-STATUS 'TOPREVIEW'.
        ELSE.
          SET PF-STATUS 'TOUPDATE'.
        ENDIF.
      ELSE.
        SET PF-STATUS 'TOEXECUTE'.
      ENDIF.
    WHEN radio2.
      SET PF-STATUS 'TODELETE'.
    WHEN radio3.
      IF va_proc IS INITIAL.
        SET PF-STATUS 'TOEXECUTE'.
      ELSE.
        SET PF-STATUS 'STANDARD'.
      ENDIF.
    WHEN radio4.
      SET PF-STATUS 'STANDARD'.
    WHEN radio5.
      IF va_proc IS INITIAL.
        SET PF-STATUS 'TOEXECUTE_LOG'.
      ELSE.
        SET PF-STATUS 'STANDARD_LOG'.
      ENDIF.
    WHEN radio10.
      SET PF-STATUS 'STANDARD'.
    WHEN radio12.
      SET PF-STATUS 'TOUPDATE'.
    WHEN radio15.
      IF gt_bapiret2[] IS NOT INITIAL.
        APPEND '&PRC' TO fcode.
      ELSEIF gt_bapiret2[] IS INITIAL AND
        va_proc = 0.
        APPEND '&LOG' TO fcode.
      ELSEIF gt_bapiret2[] IS INITIAL AND
        va_proc = 1.
        APPEND '&PRC' TO fcode.
        APPEND '&LOG' TO fcode.
      ENDIF.
      SET PF-STATUS 'TOEXECUTE_LOG' EXCLUDING fcode.
  ENDCASE.
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

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_zuonr     LIKE zfppnnrd-zuonr,
        ld_ttlcn     LIKE zfppnnrd-ttlcn,
        ld_ttlnr     LIKE zfppnnrd-ttlnr,
        ld_bldat     LIKE zfppnnrd-budat,
        ld_switch    TYPE i,
        ld_count     TYPE i,
        ld_nocn(255),
        ld_vkbur     LIKE knvv-vkbur.

  DATA: ld_tdname LIKE stxh-tdname,
        ld_tdid   LIKE stxh-tdid.

  DATA: BEGIN OF lt_lines OCCURS 0.
          INCLUDE STRUCTURE tline.
        DATA: END OF lt_lines.

  DATA: lt_radio11 LIKE t_radio11 OCCURS 0.

  CASE 'X'.
    WHEN radio1.
      IF va_vkbur NE pa_vkbur.
        REFRESH t_detail.
        REFRESH t_zsl_hsales.
      ENDIF.

      SELECT a~kunnr a~name1 a~stceg a~sortl a~gform
        FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
        INTO CORRESPONDING FIELDS OF TABLE t_kna1
        WHERE a~kunnr EQ pa_kunnr AND
              b~vkorg EQ pa_vkorg AND
              b~vkbur EQ va_vkbur.

      READ TABLE t_kna1 INDEX 1.
      IF sy-subrc EQ 0.
        va_gform = t_kna1-gform.
      ENDIF.

      LOOP AT t_detail.
        t_data-vkorg = t_detail-vkorg.
        t_data-vkbur = va_vkbur.
        t_data-kunrg = t_detail-kunrg.
        t_data-fkart = t_detail-fkart.
        t_data-ktgrd = t_detail-ktgrd.
        t_data-vbeln = t_detail-vbeln.
        t_data-aubel = t_detail-aubel.
        t_data-fkdat = t_detail-fkdat.
        t_data-stceg = t_detail-stceg.
        t_data-waerk = t_detail-waerk.
        t_data-netwr = t_detail-netwr.
        t_data-netwr = t_detail-netwr.
        t_data-aubel = t_detail-aubel.
        t_data-kzwi1 = t_detail-kzwi1.
        t_data-kzwi5 = t_detail-kzwi5.
        t_data-skfbp = t_detail-kzwi1 - t_detail-kzwi5.
        WRITE t_detail-mwsbk TO t_data-mwsbk CURRENCY t_detail-waerk.
        COLLECT t_data.
      ENDLOOP.

      SORT t_data BY vbeln.
      SORT t_zfppnnrd BY zuonr.
      IF NOT t_zsl_hsales[] IS INITIAL.
        LOOP AT t_zsl_hsales.
          t_data-vbeln      = t_zsl_hsales-vbeln.
          t_data-vbtyp      = t_zsl_hsales-vbtyp.
          t_data-waerk      = t_zsl_hsales-curr.
          t_data-vkorg      = t_zsl_hsales-vkorg.
*          t_data-fkdat      = t_zsl_hsales-fkdat.
          t_data-fkdat      = t_zsl_hsales-bldat.
          t_data-netwr      = t_zsl_hsales-netwr.
          t_data-kunrg      = t_zsl_hsales-kunnr.
          t_data-vkbur      = t_zsl_hsales-vkbur.
          t_data-mwsbk      = t_zsl_hsales-mwsbp.
          t_data-fkart      = t_zsl_hsales-fkart.

          READ TABLE t_kna1 WITH KEY kunnr = t_zsl_hsales-kunnr.
          IF sy-subrc EQ 0.
            t_data-stceg = t_kna1-stceg.
          ELSE.
            CLEAR: t_data-stceg.
          ENDIF.

*          IF t_zsl_hsales-tax_status EQ 'T1'.
          IF t_data-stceg IS INITIAL.
*            IF t_data-ktgrd EQ '00'.
            CONTINUE.
*            ENDIF.
          ENDIF.

          t_data-account_no = t_zsl_hsales-account_no.
          COLLECT t_data.
        ENDLOOP.
      ENDIF.

      IF wa_zfnrcncust IS INITIAL.
        LOOP AT t_data.
          ld_zuonr     = t_data-vbeln.
          t_out1-aubel = t_data-aubel.
          READ TABLE t_zfppnnrd WITH KEY zuonr = ld_zuonr
          BINARY SEARCH.
          IF sy-subrc NE 0.
            t_out1 = t_data.
            IF va_live EQ 'X'.
              t_out1-amtcn = t_data-netwr.
*              t_out1-amtcn = t_data-mwsbk.

*            PERFORM f_tax_calc USING '' t_out1-amtcn 'F'
*                               CHANGING t_out1-vatcn.

              t_out1-vatcn = t_out1-kzwi5 - t_out1-amtcn.
*              t_out1-vatcn = t_out1-amtcn * 10 / 100.
*****              t_out1-vatcn = t_data-mwsbk.
              t_out1-netwr = t_out1-amtcn + t_out1-vatcn.
*              t_out1-netwr = t_data-netwr.
            ELSE.
*            PERFORM f_tax_calc USING '' t_data-netwr 'C'
*                               CHANGING t_out1-amtcn.

              t_out1-amtcn = t_data-netwr * 10 / 11.
              t_out1-vatcn = t_data-mwsbk.
              t_out1-netwr = t_out1-amtcn + t_out1-vatcn.
            ENDIF.
*            t_out1-amtcn = t_data-netwr * 10 / 11.
*            t_out1-vatcn = t_data-netwr * 1 / 11.
            t_out1-zuonr = t_out1-vbeln.
            APPEND t_out1.
            ADD t_out1-amtcn TO va_amtcn.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT t_data.
          ld_zuonr     = t_data-vbeln.
          t_out1-aubel = t_data-aubel.
          CLEAR: ld_ttlcn,ld_ttlnr.
          LOOP AT t_zfppnnrd WHERE zuonr = ld_zuonr.
            ld_ttlcn = t_zfppnnrd-ttlcn.
            ld_ttlnr = ld_ttlnr + t_zfppnnrd-ttlnr.
          ENDLOOP.
          IF sy-subrc NE 0 OR ld_ttlnr LT ld_ttlcn.
            t_out1 = t_data.
            IF va_live EQ 'X'.
              t_out1-amtcn = t_data-netwr.

*            PERFORM f_tax_calc USING '' t_out1-amtcn 'F'
*                               CHANGING t_out1-vatcn.

              t_out1-vatcn = t_out1-kzwi5 - t_out1-amtcn.
*              t_out1-vatcn = t_data-mwsbk.
              t_out1-netwr = t_out1-amtcn + t_out1-vatcn.
            ELSE.
*            PERFORM f_tax_calc USING '' t_data-netwr 'C'
*                               CHANGING t_out1-amtcn.

              t_out1-amtcn = t_data-netwr * 10 / 11.
              t_out1-vatcn = t_data-mwsbk.
              t_out1-netwr = t_out1-amtcn + t_out1-vatcn.
            ENDIF.
*            t_out1-amtcn = t_data-netwr * 10 / 11.
*            t_out1-vatcn = t_data-netwr * 1 / 11.
            t_out1-zuonr = t_out1-vbeln.
            APPEND t_out1.
            ADD t_out1-amtcn TO va_amtcn.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF NOT t_out1[] IS INITIAL.
        SELECT *
          FROM bsis
          INTO CORRESPONDING FIELDS OF TABLE t_bsis
          FOR ALL ENTRIES IN t_out1
          WHERE bukrs EQ pa_vkorg     AND
                hkont EQ '0315300200' AND
                zuonr EQ t_out1-zuonr AND
                gjahr EQ pa_gjahr.
      ENDIF.

    WHEN radio2.
      LOOP AT t_zfppnnrh.
        CLEAR t_zfnrstatus.
        READ TABLE t_zfnrstatus WITH KEY status = t_zfppnnrh-status.
        IF t_zfnrstatus-zdele = 'X'.
          t_error-nonr = t_zfppnnrh-nonr.
          t_error-msg  = 'Status NR: Approval Sukses'.
          APPEND t_error.
        ELSE.
          t_out2 = t_zfppnnrh.
          t_out2-zuonr = t_out2-belnr.
          APPEND t_out2.
        ENDIF.
      ENDLOOP.

      IF NOT t_out2[] IS INITIAL.
        SELECT *
          FROM bsis
          INTO CORRESPONDING FIELDS OF TABLE t_bsis
          FOR ALL ENTRIES IN t_out2
          WHERE bukrs EQ pa_vkorg     AND
                hkont EQ '0315300200' AND
                zuonr EQ t_out2-zuonr AND
                gjahr EQ pa_gjahr.
      ENDIF.

    WHEN radio3.
      LOOP AT t_record1.
        IF NOT t_record1-message IS INITIAL.
          va_error = 1.
          t_out3-icon = icon_led_red.
        ELSE.
          t_out3-icon = icon_led_green.
        ENDIF.
        t_out3-bukrs   = pa_vkorg.
        t_out3-kunnr   = t_record1-kunnr.
        t_out3-monat   = t_record1-bln.
        t_out3-gjahr   = t_record1-thn.
        t_out3-nonr    = t_record1-nomor.
        t_out3-nrdt    = t_record1-tanggal.
        t_out3-vatpr1  = t_record1-ktr1.
        t_out3-vatpr2  = t_record1-ktr2.
        t_out3-message = t_record1-message.
        t_out3-usna1   = sy-uname.
        t_out3-erdt1   = sy-datum.
        t_out3-erzet   = sy-uzeit.
        APPEND t_out3.
      ENDLOOP.

    WHEN radio4.
      SORT t_data1 BY vkbur kunnr nonr.
      IF NOT t_data1[] IS INITIAL.
        LOOP AT t_data1.
          ON CHANGE OF t_data1-vkbur OR
                       t_data1-kunnr OR
                       t_data1-monat OR
                       t_data1-gjahr OR
                       t_data1-nonr.
            t_out4 = t_data1.
            ld_switch = 1.
          ENDON.

          IF ld_switch EQ 0.
            t_out4 = t_data1.
*            CLEAR: t_out4-ttlnr, t_out4-ppnnr, t_out4-dppnr.
          ENDIF.

          READ TABLE t_zfnrstatus WITH KEY status  = t_data1-status.
          IF sy-subrc EQ 0.
            t_out4-zdesc  = t_zfnrstatus-zdesc.
          ELSE.
            CLEAR: t_out4-zdesc.
          ENDIF.

          READ TABLE t_kna1 WITH KEY kunnr = t_out4-kunnr.
          IF sy-subrc EQ 0.
            t_out4-name1   = t_kna1-name1.
            t_out4-name_co = t_kna1-name_co.
            IF t_kna1-stkza IS INITIAL.
              CLEAR: t_out4-nppkp.
            ELSE.
              t_out4-nppkp  = t_kna1-stceg.
            ENDIF.
          ELSE.
            CLEAR: t_out4-name1, t_out4-nppkp.
          ENDIF.
          IF t_data1-stceg IS NOT INITIAL.
            t_out4-stceg = t_data1-stceg.
          ELSE.
            t_out4-stceg = t_kna1-stceg.
          ENDIF.
*          IF t_out4-stceg IS INITIAL.
          IF t_out4-ktgrd EQ '00'.
            CLEAR: t_out4-ppncn.
            t_out4-ttlcn = t_out4-dppcn + t_out4-ppncn.
          ENDIF.
          READ TABLE t_data WITH KEY vbeln = t_data1-zuonr.
          IF sy-subrc EQ 0.
            t_out4-fkart = t_data-fkart.
          ENDIF.

          CASE t_out4-bukrs.
            WHEN '8020'.
              SELECT SINGLE bldat INTO ld_bldat
              FROM zsl_hsales
              WHERE vkorg = t_out4-bukrs AND
                    vkbur = t_out4-vkbur AND
                    kunnr = t_out4-kunnr AND
                    vbeln = t_out4-belnr AND
                    gjahr = t_out4-budat(4).
            WHEN '8070'.
              SELECT SINGLE bldat INTO ld_bldat
              FROM zssutdt005
              WHERE vkorg = t_out4-bukrs AND
                    vkbur = t_out4-vkbur AND
                    kunnr = t_out4-kunnr AND
                    vbeln = t_out4-belnr AND
                    gjahr = t_out4-budat(4).
            WHEN OTHERS.
          ENDCASE.
          IF sy-subrc = 0.
            t_out4-budat = ld_bldat.
          ENDIF.
          IF t_out4-vkbur IN so_vkbur AND
             t_out4-budat IN so_fkdat.
            APPEND t_out4.
          ENDIF.
          CLEAR: t_out4, ld_switch.
        ENDLOOP.
      ENDIF.

      SORT t_data1 BY zuonr.
      SORT t_data2 BY vbeln.
      SORT t_zsl_hsales BY vbeln.

      IF NOT t_data2[] IS INITIAL.
        LOOP AT t_data2.
          t_out4-bukrs = t_data2-vkorg.
          t_out4-vkbur = t_data2-vkbur.
          t_out4-kunnr = t_data2-kunrg.
          t_out4-stceg = t_data2-stceg.
          t_out4-ktgrd = t_data2-ktgrd.
          READ TABLE t_kna1 WITH KEY kunnr = t_out4-kunnr.
          IF sy-subrc EQ 0.
            t_out4-name1   = t_kna1-name1.
            t_out4-name_co = t_kna1-name_co.
            IF t_kna1-stkza IS INITIAL.
              CLEAR: t_out4-nppkp.
            ELSE.
              t_out4-nppkp   = t_kna1-stceg.
            ENDIF.
          ELSE.
            CLEAR: t_out4-name1, t_out4-nppkp.
          ENDIF.
          t_out4-gjahr = t_data2-fkdat(4).
          t_out4-monat = t_data2-fkdat+4(2).
          t_out4-fkart = t_data2-fkart.
          t_out4-belnr = t_data2-vbeln.
          t_out4-zuonr = t_data2-vbeln.
          t_out4-budat = t_data2-fkdat.
          t_out4-waers = t_data2-waerk.
          t_out4-dppcn = t_data2-netwr.
*          IF t_out4-stceg IS INITIAL.
          IF t_out4-ktgrd EQ '00'.
            CLEAR: t_out4-ppncn.
          ELSE.
            t_out4-ppncn = t_data2-mwsbk.
*            t_out4-ppncn = t_out4-dppcn * 10 / 100.
          ENDIF.
          t_out4-ttlcn = t_out4-dppcn + t_out4-ppncn.
*          t_out4-dppcn = t_data-netwr * 10 / 11.
*          t_out4-ppncn = t_data-netwr * 1 / 11.
          READ TABLE t_data1 WITH KEY zuonr = t_out4-zuonr
          BINARY SEARCH.
          IF sy-subrc NE 0.
            IF t_data2-vkbur IN so_vkbur.
              APPEND t_out4.
            ENDIF.
            CLEAR: t_out4.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF NOT t_zsl_hsales[] IS INITIAL.
        LOOP AT t_zsl_hsales.
          t_out4-bukrs = t_zsl_hsales-vkorg.
          t_out4-vkbur = t_zsl_hsales-vkbur.
          t_out4-kunnr = t_zsl_hsales-kunnr.
          t_out4-fkart = t_zsl_hsales-fkart.
          READ TABLE t_kna1 WITH KEY kunnr = t_out4-kunnr.
          IF sy-subrc EQ 0.
            t_out4-name1   = t_kna1-name1.
            t_out4-name_co = t_kna1-name_co.
            t_out4-stceg   = t_kna1-stceg.
            IF t_kna1-stkza IS INITIAL.
              CLEAR: t_out4-nppkp.
            ELSE.
              t_out4-nppkp  = t_kna1-stceg.
            ENDIF.
          ELSE.
            CLEAR: t_out4-name1, t_out4-stceg, t_out4-nppkp.
          ENDIF.

          IF t_zsl_hsales-tax_status EQ 'T1'.
*            IF t_out4-stceg IS INITIAL.
            IF t_out4-ktgrd EQ '00'.
              CONTINUE.
            ENDIF.
          ENDIF.

          t_out4-gjahr = t_zsl_hsales-gjahr.
*          t_out4-monat = t_zsl_hsales-fkdat+4(2).
          t_out4-monat = t_zsl_hsales-bldat+4(2).
          t_out4-belnr = t_zsl_hsales-account_no.
          t_out4-zuonr = t_zsl_hsales-vbeln.
*          t_out4-budat = t_zsl_hsales-fkdat.
          t_out4-budat = t_zsl_hsales-bldat.
          t_out4-waers = t_zsl_hsales-curr.
*          t_out4-ttlcn = t_zsl_hsales-netwr.

*          PERFORM f_tax_calc USING '' t_zsl_hsales-netwr 'C'
*                             CHANGING t_out4-dppcn.

          t_out4-dppcn = t_zsl_hsales-netwr * 10 / 11.
*          IF t_out4-stceg IS INITIAL.
          IF t_out4-ktgrd EQ '00'.
            CLEAR: t_out4-ppncn.
          ELSE.
*            PERFORM f_tax_calc USING '' t_zsl_hsales-netwr 'D'
*                               CHANGING t_out4-dppcn.

            t_out4-ppncn = t_zsl_hsales-netwr * 1 / 11.
          ENDIF.
          t_out4-ttlcn = t_out4-dppcn + t_out4-ppncn.
          READ TABLE t_data1 WITH KEY zuonr = t_out4-zuonr
          BINARY SEARCH.
          IF sy-subrc NE 0.
            IF t_zsl_hsales-vkbur IN so_vkbur.
              APPEND t_out4.
            ENDIF.
            CLEAR: t_out4.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF NOT so_monat IS INITIAL.
        SORT t_out4 BY monat gjahr.
        DELETE t_out4 WHERE monat NE so_monat-low.
      ENDIF.
      IF NOT so_monat IS INITIAL AND
         NOT so_gjahr IS INITIAL.
        SORT t_out4 BY monat gjahr.
        DELETE t_out4 WHERE monat NE so_monat-low OR
                            gjahr NE so_gjahr-low.
      ENDIF.
      IF NOT so_gjahr IS INITIAL.
        SORT t_out4 BY gjahr.
        DELETE t_out4 WHERE gjahr NE so_gjahr-low.
      ENDIF.
      SORT t_out4 BY vrsio.
      DELETE t_out4 WHERE vrsio NOT IN so_vrsio.

      DATA : lv_name      TYPE tdobname,
             lv_length    TYPE int4,
             lv_from      TYPE int4,
             lv_datum(10),
             lines        TYPE STANDARD TABLE OF tline,
             wa_lines     LIKE tline.

      LOOP AT t_out4.
        CLEAR : lines[], lines, lv_name, lv_length, lv_datum,
                wa_lines.
        lv_name = t_out4-zuonr.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'Z008'
            language                = sy-langu
            name                    = lv_name
            object                  = 'VBBK'
          TABLES
            lines                   = lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.

        READ TABLE lines INTO wa_lines INDEX 1.
        IF sy-subrc = 0.
          lv_length = strlen( wa_lines-tdline ).
          IF lv_length > 10.
            lv_from = lv_length - 10.
          ENDIF.
          lv_datum  = wa_lines-tdline+lv_from(10).
          CONCATENATE lv_datum+6(4) lv_datum+3(2) lv_datum(2)
          INTO t_out4-vatdtsap.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = t_out4-vatdtsap
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc = 0.
            MODIFY t_out4 TRANSPORTING vatdtsap.
          ENDIF.
        ENDIF.

        PERFORM f_extended_name USING t_out4-kunnr.

        CLEAR t_out4.
      ENDLOOP.

    WHEN radio5.
      LOOP AT t_zfppnnrh.
        t_out5 = t_zfppnnrh.
        READ TABLE t_zfnrhkont WITH KEY bukrs = t_zfppnnrh-bukrs
                                        vkbur = t_zfppnnrh-vkbur.
        IF sy-subrc EQ 0.
          t_out5-hkont = t_zfnrhkont-hkont.
        ENDIF.
        t_out5-selisih = t_out5-ppnnr - t_out5-ppncn.
        APPEND t_out5.
      ENDLOOP.

    WHEN radio7.
      IF t_zfppnnrdtl[] IS NOT INITIAL.
        LOOP AT t_zfppnnrdtl.
          t_out6-nonr   = t_zfppnnrdtl-nonr.
          t_out6-nrdt   = t_zfppnnrdtl-nrdt.
          t_out6-waerk  = t_zfppnnrdtl-waerk.
          t_out6-vrkme  = t_zfppnnrdtl-vrkme.
          t_out6-matnr  = t_zfppnnrdtl-matnr.
          t_out6-arktx  = t_zfppnnrdtl-arktx.
          t_out6-fkimg  = t_zfppnnrdtl-fkimg.
          t_out6-kzwi1  = t_zfppnnrdtl-kzwi1.
          t_out6-hrgsat = t_zfppnnrdtl-kzwi1 / t_zfppnnrdtl-fkimg.
          t_out6-skfbp  = t_zfppnnrdtl-skfbp.
          t_out6-kzwi5  = t_zfppnnrdtl-kzwi5.
          t_out6-netwr  = t_zfppnnrdtl-dppnr.
          APPEND t_out6.

          t_header            = wa_header.
          t_header-name1      = name_co.
          CONCATENATE street city
          INTO t_header-address
          SEPARATED BY space.
          t_header-nonr   = t_zfppnnrdtl-nonr.
          t_header-nrdt   = t_zfppnnrdtl-nrdt.

          SORT t_alamat BY bukrs brnch masafrom DESCENDING.
          LOOP AT t_alamat WHERE bukrs = pa_vkorg AND
                                 brnch = pa_vkorg AND
                                 masafrom LE t_header-nrdt.
            t_header-pkpname = t_alamat-pkpname.
            t_header-pkpaddrs1 = t_alamat-pkpaddrs1.
            t_header-pkpaddrs2 = t_alamat-pkpaddrs2.
            t_header-pkppostal = t_alamat-pkppostal.
            t_header-pkpcity = t_alamat-pkpcity.
            t_header-pkpnpwp = t_alamat-pkpnpwp.
            t_header-pkpkuh = t_alamat-pkpkuh.
            EXIT.
          ENDLOOP.

          LOOP AT t_zfppnnrd WHERE nonr EQ t_zfppnnrdtl-nonr.
* Get No. CN for printing
            CONCATENATE ld_nocn t_zfppnnrd-belnr INTO ld_nocn
              SEPARATED BY ','.
            SHIFT ld_nocn LEFT DELETING LEADING ','.

* Get text for 'ATAS FAKTUR PAJAK NO.'
            ld_tdname     = t_zfppnnrd-aubel.
            t_faktur-nonr = t_zfppnnrd-nonr.

            CLEAR: ld_count.
            DO 4 TIMES.
              ADD 1 TO ld_count.
              CASE ld_count.
                WHEN 1.
                  ld_tdid  = 'Z008'.
                WHEN 2.
                  ld_tdid  = 'Z009'.
                WHEN 3.
                  ld_tdid  = 'Z010'.
                WHEN 4.
                  ld_tdid  = 'Z011'.
              ENDCASE.
              CALL FUNCTION 'READ_TEXT'
                EXPORTING
                  id                      = ld_tdid
                  language                = sy-langu
                  name                    = ld_tdname
                  object                  = 'VBBK'
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
              IF sy-subrc <> 0.
                CONTINUE.
              ELSE.
                READ TABLE lt_lines INDEX 1.
                IF sy-subrc EQ 0.
                  t_faktur-faktur = lt_lines-tdline.
                  COLLECT t_faktur.
                ENDIF.
              ENDIF.
            ENDDO.
          ENDLOOP.

          AT END OF nonr.
            CLEAR: ld_count.
            LOOP AT t_faktur WHERE nonr EQ t_zfppnnrd-nonr.
              ADD 1 TO ld_count.
              CASE ld_count.
                WHEN 1.
                  t_header-faktur1 = t_faktur-faktur.
                  TRANSLATE t_header-faktur1 TO UPPER CASE.
                WHEN 2.
                  t_header-faktur2 = t_faktur-faktur.
                  TRANSLATE t_header-faktur2 TO UPPER CASE.
                WHEN 3.
                  t_header-faktur3 = t_faktur-faktur.
                  TRANSLATE t_header-faktur3 TO UPPER CASE.
                WHEN 4.
                  t_header-faktur4 = t_faktur-faktur.
                  TRANSLATE t_header-faktur4 TO UPPER CASE.
              ENDCASE.
            ENDLOOP.
            t_header-nocn = ld_nocn.
            APPEND t_header.
            REFRESH: t_faktur.
            CLEAR: t_faktur, ld_nocn.
          ENDAT.
          CLEAR: ld_nocn.
        ENDLOOP.
        PERFORM f_reprint_form.
      ENDIF.

    WHEN radio10.
      LOOP AT t_zfppnnrh_d.
        PERFORM f_extended_name USING t_zfppnnrh_d-kunnr.
      ENDLOOP.

    WHEN radio11.
      SET PF-STATUS '100'.

      lt_radio11[] = t_radio11[].
      SORT lt_radio11 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_radio11 COMPARING kunnr.

      IF lt_radio11[] IS NOT INITIAL.
        SELECT a~kunnr a~name1 a~stceg sortl a~stkza
               name_co
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                         JOIN adrc AS c ON a~adrnr EQ c~addrnumber
          FOR ALL ENTRIES IN lt_radio11
          WHERE a~kunnr EQ lt_radio11-kunnr AND  "pa_kunnr AND
                b~vkorg EQ pa_vkorg.
      ENDIF.

      LOOP AT t_radio11.
        READ TABLE t_kna1 WITH KEY kunnr = t_radio11-kunnr.
        IF sy-subrc EQ 0.
          t_radio11-name1   = t_kna1-name1.
          t_radio11-name_co = t_kna1-name_co.
          t_radio11-stceg   = t_kna1-stceg.
          IF t_kna1-stkza IS INITIAL.
            CLEAR: t_radio11-nppkp.
          ELSE.
            t_radio11-nppkp  = t_kna1-stceg.
          ENDIF.
        ELSE.
          CLEAR: t_radio11-name1,t_radio11-name_co,t_radio11-stceg,t_radio11-nppkp.
        ENDIF.

        IF t_radio11-status IS NOT INITIAL.
          READ TABLE t_zfnrstatus WITH KEY status = t_radio11-status.
          IF sy-subrc EQ 0.
            t_radio11-zdesc  = t_zfnrstatus-zdesc.
          ELSE.
            CLEAR: t_radio11-zdesc.
          ENDIF.
        ELSE.
          CLEAR: t_radio11-zdesc.
        ENDIF.

        CLEAR: t_vbrk, t_zsl_hsales.
        IF va_live EQ 'X'.
          READ TABLE t_vbrk WITH KEY vbeln = t_radio11-belnr.
          t_radio11-fkart = t_vbrk-fkart.
          t_radio11-ktgrd = t_vbrk-ktgrd.
        ELSE.
          READ TABLE t_zsl_hsales WITH KEY vbeln = t_radio11-zuonr.
          t_radio11-fkart = t_vbrk-fkart.
          t_radio11-ktgrd = t_vbrk-ktgrd.
        ENDIF.

        MODIFY t_radio11 TRANSPORTING fkart ktgrd name1 name_co stceg nppkp zdesc.
        CLEAR t_radio11.
      ENDLOOP.

    WHEN radio14.
      SET PF-STATUS '100'.

      lt_radio11[] = t_radio11[].
      SORT lt_radio11 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_radio11 COMPARING kunnr.

      IF lt_radio11[] IS NOT INITIAL.
        SELECT a~kunnr a~name1 a~stceg sortl a~stkza
               name_co
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                         JOIN adrc AS c ON a~adrnr EQ c~addrnumber
          FOR ALL ENTRIES IN lt_radio11
          WHERE a~kunnr EQ lt_radio11-kunnr AND  "pa_kunnr AND
                b~vkorg EQ pa_vkorg.
      ENDIF.

      LOOP AT t_radio11.
        READ TABLE t_zfstppnnr WITH KEY bukrs = t_radio11-bukrs
                                        vkbur = t_radio11-vkbur
                                        zuonr = t_radio11-zuonr
                                        kunnr = t_radio11-kunnr
                                        monat = t_radio11-monat
                                        gjahr = t_radio11-gjahr
                                        nonr  = t_radio11-nonr.
        IF sy-subrc = 0.
          t_radio11-status = t_zfstppnnr-status.
          t_radio11-refnr  = t_zfstppnnr-refnr.

          READ TABLE t_kna1 WITH KEY kunnr = t_radio11-kunnr.
          IF sy-subrc EQ 0.
            t_radio11-name1   = t_kna1-name1.
            t_radio11-name_co = t_kna1-name_co.
            t_radio11-stceg   = t_kna1-stceg.
            IF t_kna1-stkza IS INITIAL.
              CLEAR: t_radio11-nppkp.
            ELSE.
              t_radio11-nppkp  = t_kna1-stceg.
            ENDIF.
          ELSE.
            CLEAR: t_radio11-name1,t_radio11-name_co,t_radio11-stceg,t_radio11-nppkp.
          ENDIF.

          IF t_radio11-status IS NOT INITIAL.
            READ TABLE t_zfnrstatus WITH KEY status = t_radio11-status.
            IF sy-subrc EQ 0.
              t_radio11-zdesc  = t_zfnrstatus-zdesc.
            ELSE.
              CLEAR: t_radio11-zdesc.
            ENDIF.
          ELSE.
            CLEAR: t_radio11-zdesc.
          ENDIF.

          CLEAR: t_vbrk, t_zsl_hsales.
          READ TABLE t_vbrk WITH KEY vbeln = t_radio11-belnr.
          IF sy-subrc = 0.
            t_radio11-fkart = t_vbrk-fkart.
            t_radio11-ktgrd = t_vbrk-ktgrd.
          ELSE.
            READ TABLE t_zsl_hsales WITH KEY vbeln = t_radio11-zuonr.
            t_radio11-fkart = t_zsl_hsales-fkart.
            t_radio11-ktgrd = t_vbrk-ktgrd.
          ENDIF.

          MODIFY t_radio11
            TRANSPORTING fkart ktgrd name1 name_co stceg nppkp status refnr zdesc.
          CLEAR t_radio11.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: fu_valid(3),
        fc_error     TYPE i,
        ld_mess(255),
        ld_ttlnr     LIKE zfppnnrh-ttlnr,
        ld_tolrs     LIKE zfnrcncust-toleransi,
        index(1),
        lv_lines     TYPE i.

  CONCATENATE 'Invalid net value for customer' pa_kunnr
  INTO ld_mess
  SEPARATED BY space.

  CASE fu_ucomm.
    WHEN 'SAVE'.
      CASE 'X'.
        WHEN radio1.
          IF wa_zfnrcncust IS NOT INITIAL.
            LOOP AT t_out6.
              SUM.
              ld_ttlnr = t_out6-kzwi5.
            ENDLOOP.
            ld_tolrs = ld_ttlnr - ttlnr.
            IF ld_tolrs GT wa_zfnrcncust-toleransi.
              MESSAGE 'Total value <> total NR' TYPE 'E'.
            ENDIF.
          ENDIF.
          PERFORM f_isi_table.

          IF NOT t_zfppnnrh[] IS INITIAL.
            va_commit = 1.
            PERFORM f_commit_work.
          ENDIF.

          IF sy-subrc EQ 0.
            PERFORM f_table_unlocking.
            IF va_error EQ 0.
              MESSAGE s000(zab) WITH 'Records was CREATED successfully'.
              SUBMIT zfnota_retur VIA SELECTION-SCREEN.
            ELSE.
              MESSAGE e000(zab) WITH 'Customer tidak ada N.P.W.P'.
            ENDIF.
            LEAVE TO SCREEN 0.
          ELSE.
            MESSAGE e000(zab) WITH 'Processing error'.
          ENDIF.
        WHEN radio11 OR radio14.
          PERFORM f_save_status.
        WHEN radio12 OR radio1.
          PERFORM f_update_data.
      ENDCASE.

    WHEN 'CHOOSE'.
      READ CURRENT LINE FIELD VALUE: t_radio11-monat, t_radio11-gjahr,
                                     t_radio11-kunnr, t_radio11-nonr,
                                     t_radio11-zuonr, t_radio11-belnr
                                     t_radio11-status, t_radio11-refnr.

      CALL SCREEN 503 STARTING AT 10 10 ENDING AT 150 22.
      LEAVE TO SCREEN 0.

    WHEN '&LOG'.
      IF radio15 IS NOT INITIAL.
        DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
        IF lv_lines = 1.
          APPEND INITIAL LINE TO gt_bapiret2.
        ENDIF.
        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            i_bapiret2_tab = gt_bapiret2.
      ELSE.
        CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.
      ENDIF.

    WHEN '&VAL'.
      va_valid = 1.
      fu_valid = 'VAL'.
      PERFORM f_output_validate USING fu_valid
                                CHANGING fc_error.
      IF fc_error EQ 2.
        MESSAGE i000(zab) WITH ld_mess.
      ENDIF.

    WHEN '&FKT'.
      CALL SELECTION-SCREEN 502 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&PRE' OR '&PRNT'.
      IF va_ranges = 1.
        va_valid = 1.
      ENDIF.

      IF va_valid EQ 1.
        IF va_preview EQ 1.
          fu_valid = 'PRE'.
          PERFORM f_output_validate USING fu_valid
                                    CHANGING fc_error.
          IF fc_error EQ 0.
            PERFORM f_print_form USING fu_ucomm.
*            LEAVE TO SCREEN 0.
          ELSEIF fc_error EQ 1.
            MESSAGE i000(zab) WITH 'You must validated data'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE i000(zab) WITH 'You must validated data'.
      ENDIF.

    WHEN '&PRC'.
      CLEAR: va_error.
      CASE 'X'.
        WHEN radio5.
          PERFORM f_post_entries.

        WHEN radio1.
          IF va_preview EQ 0.
            PERFORM f_summary.
            IF va_retval EQ 1.
              CALL SELECTION-SCREEN 500 STARTING AT 0 0.
              LEAVE TO SCREEN 0.
            ELSE.
              MESSAGE i000(zab) WITH 'No data to be processed'.
            ENDIF.
          ENDIF.

        WHEN radio15.
          IF gt_bapiret2[] IS INITIAL.
            va_proc  = 1.
            fu_selfield-refresh = 'X'.
            PERFORM f_isi_table.
            MESSAGE s000(zab) WITH 'Data already processed'.
          ENDIF.

        WHEN OTHERS.
          PERFORM f_isi_table.

          IF NOT t_zfppnnrh[] IS INITIAL.
            va_commit = 0.
            PERFORM f_commit_work ON COMMIT.
          ENDIF.

          IF sy-subrc EQ 0.
            IF va_error EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
            ENDIF.
            CASE 'X'.
              WHEN radio3.
                PERFORM f_alv TABLES t_out3.
                LEAVE TO SCREEN 0.
            ENDCASE.
          ELSE.
            MESSAGE e000(zab) WITH 'Processing error'.
          ENDIF.
      ENDCASE.

    WHEN '&DEL'.
      CLEAR: va_error.
      PERFORM f_delete_data ON COMMIT.
      IF sy-subrc EQ 0.
        IF va_error EQ 1.
          ROLLBACK WORK.
          MESSAGE e000(zab) WITH 'Records can not be DELETED'.
        ELSE.
          COMMIT WORK AND WAIT.
          MESSAGE s000(zab) WITH 'Records was DELETED successfully'.
        ENDIF.
        PERFORM f_alv TABLES t_out2.
        PERFORM f_table_unlocking.
        LEAVE TO SCREEN 0.
      ELSE.
        PERFORM f_table_unlocking.
        MESSAGE e000(zab) WITH 'Processing error'.
      ENDIF.

    WHEN '&IC1'.
      IF radio1 EQ 'X'.
        CHECK NOT fu_selfield-tabindex IS INITIAL.
        READ TABLE t_out1 INDEX fu_selfield-tabindex.
        IF fu_selfield-sel_tab_field EQ 'T_OUT1-VBELN'.
          IF t_out1-vbeln(1) EQ 'C'.
            SET PARAMETER ID 'BLN' FIELD t_out1-account_no.
            SET PARAMETER ID 'BUK' FIELD t_out1-vkorg.
            SET PARAMETER ID 'GJR' FIELD t_out1-fkdat(4).
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ELSE.
            SET PARAMETER ID 'BLN' FIELD t_out1-vbeln.
            SET PARAMETER ID 'BUK' FIELD t_out1-vkorg.
            SET PARAMETER ID 'GJR' FIELD t_out1-fkdat(4).
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.
        ENDIF.
      ELSEIF radio4 EQ 'X'.
        CHECK NOT fu_selfield-tabindex IS INITIAL.
        READ TABLE t_out4 INDEX fu_selfield-tabindex.
        IF fu_selfield-sel_tab_field EQ 'T_OUT4-BELNRRC'.
          IF NOT t_out4-belnrrc IS INITIAL.
            SET PARAMETER ID 'BLN' FIELD t_out4-belnrrc.
            SET PARAMETER ID 'BUK' FIELD t_out4-bukrs.
            SET PARAMETER ID 'GJR' FIELD t_out4-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '&CHCK'.
      IF radio1 EQ 'X' AND wa_zfnrcncust IS NOT INITIAL.
        LOOP AT t_out6.
          t_out6-kzwi1 = t_out6-hrgsat * t_out6-fkimg.
          t_out6-kzwi5 = t_out6-kzwi1 - t_out6-skfbp.
          MODIFY t_out6 TRANSPORTING hrgsat kzwi1 skfbp kzwi5.
        ENDLOOP.
      ENDIF.
      PERFORM f_alv TABLES t_out6.

    WHEN '&BACK' OR '&EXIT' OR '&CANCL'.
      SUBMIT zfnota_retur VIA SELECTION-SCREEN.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.
  DATA: ld_bldat      LIKE bkpf-bldat,
        ld_nilai      LIKE bseg-wrbtr,
        ld_bschl1     LIKE bsis-bschl,
        ld_bschl2     LIKE bsis-bschl,
        ld_hkont      LIKE bsis-hkont,
        ld_hkont1     LIKE bsis-hkont,
        ld_hkont2     LIKE bsis-hkont,
        ld_shkzg      LIKE bsis-shkzg,
        ld_bldat1(10),
        ld_nrdt1(10),
        ld_nilai1(15),
        ld_sgtxt      LIKE bsis-sgtxt,
        ld_bktxt      LIKE bkpf-bktxt,
        ld_hkontcl    LIKE bsis-hkont.

  CLEAR: va_proc.
  IF t_out5[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    d_bdc_tctxt = 'Executing Transaction FB01'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    LOOP AT t_out5 WHERE check EQ 'X'.
      ld_nilai = t_out5-ppnnr - t_out5-ppncn.

      READ TABLE t_zfnrhkont WITH KEY bukrs = t_out5-bukrs
                                      vkbur = t_out5-vkbur.
      IF sy-subrc EQ 0.
        ld_hkontcl = t_zfnrhkont-hkontclear.
      ENDIF.

      IF ld_hkontcl IS INITIAL.
        ld_hkontcl = '0315300100'.
      ENDIF.

      IF ld_nilai NE 0.
        IF ld_nilai GT 0.
          ld_bschl1 = '40'.
          ld_hkont1 = ld_hkontcl.
          ld_bschl2 = '50'.
          ld_hkont2 = t_out5-hkont.
          ld_shkzg  = 'S'.
        ELSEIF ld_nilai LT 0.
          ld_bschl1 = '50'.
          ld_hkont1 = ld_hkontcl.
          ld_bschl2 = '40'.
          ld_hkont2 = t_out5-hkont.
          ld_shkzg  = 'H'.
        ENDIF.

        CONCATENATE pa_vkbur t_out5-nonr t_out5-nrdt INTO ld_sgtxt
          SEPARATED BY '/'.
        CONCATENATE pa_vkbur t_out5-nonr INTO ld_bktxt
          SEPARATED BY '/'.

        ld_nilai = abs( ld_nilai ).
        WRITE ld_nilai TO ld_nilai1 CURRENCY t_out5-waers.
        CONCATENATE t_out5-gjahr t_out5-monat '01' INTO ld_bldat.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = ld_bldat
          IMPORTING
            last_day_of_month = ld_bldat.

        PERFORM f_format_date USING    ld_bldat
                              CHANGING ld_bldat1.
        PERFORM f_format_date USING    t_out5-nrdt
                              CHANGING ld_nrdt1.


        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'      '0100',
          ' ' 'BDC_OKCODE'    '/00',
          ' ' 'BKPF-BLDAT'    ld_bldat1,
          ' ' 'BKPF-BLART'    'SA',
          ' ' 'BKPF-BUKRS'    t_out5-bukrs,
          ' ' 'BKPF-BUDAT'    ld_bldat1,
          ' ' 'BKPF-MONAT'    t_out5-monat,
          ' ' 'BKPF-WAERS'    t_out5-waers,
          ' ' 'BKPF-XBLNR'    t_out5-kunnr,
          ' ' 'BKPF-BKTXT'    ld_bktxt,
          ' ' 'BKPF-MONAT'    t_out5-monat,
          ' ' 'FS006-DOCID'   '*',
          ' ' 'RF05A-NEWBS'   ld_bschl1,
          ' ' 'RF05A-NEWKO'   ld_hkont1.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'      '0300',
          ' ' 'BDC_OKCODE'    '/00',
          ' ' 'BSEG-WRBTR'    ld_nilai1,
          ' ' 'BSEG-ZFBDT'    ld_nrdt1,
          ' ' 'BSEG-ZUONR'    t_out5-belnr,
          ' ' 'BSEG-SGTXT'    ld_sgtxt,
          ' ' 'RF05A-NEWBS'   ld_bschl2,
          ' ' 'RF05A-NEWKO'   ld_hkont2.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'      '0002',
          ' ' 'BDC_OKCODE'    '=ENTE',
          ' ' 'COBL-GSBER'    gv_gsber.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'      '0300',
          ' ' 'BDC_OKCODE'    '=BU',
          ' ' 'BSEG-WRBTR'    '*',
          ' ' 'BSEG-ZUONR'    t_out5-belnr,
          ' ' 'BSEG-SGTXT'    ld_sgtxt.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'      '0002',
          ' ' 'BDC_OKCODE'    '=ENTE',
          ' ' 'COBL-GSBER'    gv_gsber.

        PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                                t_bdcmsg
                                         USING 'FB01' d_bdc_tctxt.

        PERFORM f_get_message USING t_bdcmsg
                              CHANGING t_out5-msg.

*-----Update message for the status report
        IF d_bdc_error = 0.
          t_out5-icon = icon_led_green.
          t_out5-msg = 'Data has been saved'.
          PERFORM f_update_table USING t_bdcmsg-msgv1
                                       ld_bldat
                                       ld_shkzg
                                       ld_hkont2
                                       ld_nilai.
        ELSE.
          t_out5-icon = icon_led_red.
        ENDIF.
        MODIFY t_out5 TRANSPORTING msg icon.

        CLEAR: t_bdcdata, t_bdcmsg.
        REFRESH: t_bdcdata, t_bdcmsg.
      ELSE.
        t_out5-icon = icon_led_green.
        t_out5-msg = 'Data has been saved'.
        PERFORM f_update_table USING '' '00000000' '' '' ''.
        MODIFY t_out5 TRANSPORTING msg icon.
      ENDIF.
    ENDLOOP.
    va_proc = 1.
    PERFORM f_print_data.
    PERFORM f_table_unlocking.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  f_isi_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_isi_table.
  DATA : ld_cnt   TYPE i.

  DATA : ls_out     LIKE LINE OF gt_out.

  REFRESH: t_zfppnnrh, t_zfppnnrd.
  CLEAR: t_zfppnnrh, t_zfppnnrd.

  CASE 'X'.
    WHEN radio1.
      CLEAR: va_error.
      t_zfppnnrh-vatpr1  = wa_header-faktur1.
      t_zfppnnrh-vatpr2  = wa_header-faktur2.
      t_zfppnnrh-vatpr3  = wa_header-faktur3.
      t_zfppnnrh-vatpr4  = wa_header-faktur4.

      IF wa_zfnrcncust IS NOT INITIAL.
        CLEAR t_vatno.
        CASE 'X'.
          WHEN rvat1.
            READ TABLE t_vatno WITH KEY vatpr = vatno.
            t_zfppnnrh-vatpr1 = vatno.
            t_zfppnnrh-vatdt1 = t_vatno-dudat.
          WHEN rvat2.
            t_zfppnnrh-vatpr1 = vatnotxt.
            t_zfppnnrh-vatdt1 = vatdate.
        ENDCASE.
      ENDIF.

      LOOP AT t_out1 WHERE check EQ 'X'.
* Save to table header

*        IF t_out1-stceg IS INITIAL.
*          va_error = 1.
*          CONTINUE.
*        ENDIF.
        IF t_out1-ktgrd EQ '00'.
          va_error = 1.
          CONTINUE.
        ENDIF.

        IF sy-tabix = 1.
          IF rvat2 IS INITIAL.
            PERFORM f_get_vat_number USING t_out1-aubel
                                     CHANGING t_zfppnnrh-vatpr1
                                              t_zfppnnrh-vatpr2
                                              t_zfppnnrh-vatpr3
                                              t_zfppnnrh-vatpr4
                                              t_zfppnnrh-vatdt1.
          ENDIF.
        ENDIF.

        t_zfppnnrh-bukrs  = t_out1-vkorg.
        t_zfppnnrh-kunnr  = t_out1-kunrg.
        t_zfppnnrh-monat  = pa_monat.
        t_zfppnnrh-gjahr  = pa_gjahr.
        t_zfppnnrh-nonr   = nonr.
        t_zfppnnrh-nrdt   = nrdt.
        t_zfppnnrh-name1  = name1.

        READ TABLE t_kna1 WITH KEY kunnr = t_out1-kunrg.
        IF sy-subrc EQ 0.
          t_zfppnnrh-stceg  = t_kna1-stceg.
        ENDIF.
        t_zfppnnrh-waers  = t_out1-waerk.

        IF ld_cnt EQ 0.
          ld_cnt = 1.
          t_zfppnnrh-ttlnr  = dppnr + ppnnr.
          t_zfppnnrh-ttlnr  = ttlnr / 100.
          t_zfppnnrh-dppnr  = dppnr / 100.
          t_zfppnnrh-ppnnr  = ppnnr / 100.
        ELSE.
          CLEAR: t_zfppnnrh-ttlnr, t_zfppnnrh-dppnr, t_zfppnnrh-ppnnr.
        ENDIF.

        t_zfppnnrh-ttlcn  = t_out1-netwr.
        t_zfppnnrh-dppcn  = t_out1-amtcn.
        t_zfppnnrh-ppncn  = t_out1-vatcn.

        t_zfppnnrh-usna1  = sy-uname.
        t_zfppnnrh-erdt1  = sy-datum.
*        t_zfppnnrh-erzet  = sy-uzeit.

        t_zfppnnrh-city   = p_city.
        t_zfppnnrh-nmpem  = p_nmpem.
        t_zfppnnrh-japem  = p_japem.

* Save to table detail.
        t_zfppnnrd-bukrs = t_out1-vkorg.
        t_zfppnnrd-vkbur = pa_vkbur.
        t_zfppnnrd-belnr = t_out1-vbeln.
        t_zfppnnrd-zuonr = t_out1-vbeln.
        t_zfppnnrd-aubel = t_out1-aubel.
        t_zfppnnrd-kunnr = t_out1-kunrg.
        t_zfppnnrd-monat = pa_monat.
        t_zfppnnrd-gjahr = pa_gjahr.
        t_zfppnnrd-nonr  = nonr.
        t_zfppnnrd-budat = t_out1-fkdat.
        t_zfppnnrd-nrdt  = nrdt.
        t_zfppnnrd-waers = t_out1-waerk.

        t_zfppnnrd-ttlcn = t_out1-netwr.
        t_zfppnnrd-dppcn = t_out1-amtcn.
        t_zfppnnrd-ppncn = t_out1-vatcn.

        t_zfppnnrd-usna1 = sy-uname.
        t_zfppnnrd-erdt1 = sy-datum.
        t_zfppnnrd-erzet = sy-uzeit.

        t_zfppnnrd-ttlnr  = ttlnr / 100.
        t_zfppnnrd-dppnr  = dppnr / 100.
        t_zfppnnrd-ppnnr  = ppnnr / 100.

        PERFORM f_change_document.
      ENDLOOP.

    WHEN radio3.
      LOOP AT t_out3 WHERE check EQ 'X'.
        IF t_out3-icon NE '@5C@'.
          t_out3-icon1 = icon_checked.
          LOOP AT t_record1 WHERE kunnr EQ t_out3-kunnr AND
                                  nomor EQ t_out3-nonr.
* Save to table header
            t_zfppnnrh-bukrs  = pa_vkorg.
            t_zfppnnrh-kunnr  = t_record1-kunnr.
            t_zfppnnrh-monat  = t_record1-bln.
            t_zfppnnrh-gjahr  = t_record1-thn.
            t_zfppnnrh-nonr   = t_record1-nomor.
            t_zfppnnrh-nrdt   = t_record1-tanggal.
            t_zfppnnrh-name1  = t_record1-name1.
            t_zfppnnrh-stceg  = t_record1-stceg.
            t_zfppnnrh-vatpr1 = t_record1-ktr1.
            t_zfppnnrh-vatpr2 = t_record1-ktr2.
            t_zfppnnrh-waers  = 'IDR'.
            t_zfppnnrh-ttlnr  = t_record1-total / 100.
            t_zfppnnrh-dppnr  = t_record1-dpp / 100.
            t_zfppnnrh-ppnnr  = t_record1-ppn / 100.
            t_zfppnnrh-ttlcn  = t_record1-val1 + t_record1-val2 +
                                t_record1-val3 + t_record1-val4 +
                                t_record1-val5 + t_record1-val6 +
                                t_record1-val7 + t_record1-val8 +
                                t_record1-val9.

*            PERFORM f_tax_calc USING '' t_zfppnnrh-ttlcn 'C'
*                               CHANGING t_zfppnnrh-dppcn.
*            PERFORM f_tax_calc USING '' t_zfppnnrh-ttlcn 'D'
*                               CHANGING t_zfppnnrh-ppncn.

            t_zfppnnrh-dppcn  = t_zfppnnrh-ttlcn * 10 / 11.
            t_zfppnnrh-ppncn  = t_zfppnnrh-ttlcn * 1 / 11.

            t_zfppnnrh-ttlcn  = t_zfppnnrh-ttlcn / 100.
            t_zfppnnrh-dppcn  = t_zfppnnrh-dppcn / 100.
            t_zfppnnrh-ppncn  = t_zfppnnrh-ppncn / 100.

            t_zfppnnrh-usna1  = sy-uname.
            t_zfppnnrh-erdt1  = sy-datum.
            t_zfppnnrh-erzet  = sy-uzeit.
            APPEND t_zfppnnrh.

* Save to table detail
            t_zfppnnrd-bukrs = pa_vkorg.
            t_zfppnnrd-vkbur = pa_vkbur.
            t_zfppnnrd-kunnr = t_zfppnnrh-kunnr.
            t_zfppnnrd-monat = pa_monat.
            t_zfppnnrd-gjahr = pa_gjahr.
            t_zfppnnrd-nonr  = t_record1-nomor.
            t_zfppnnrd-nrdt  = t_record1-tanggal.
            t_zfppnnrd-waers = 'IDR'.
            t_zfppnnrd-usna1 = sy-uname.
            t_zfppnnrd-erdt1 = sy-datum.
            t_zfppnnrd-erzet = sy-uzeit.

            IF NOT t_record1-beln1 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln1.
              CONCATENATE gv_brcod va_brcode t_record1-seq1 t_record1-dok1
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl1.
              t_zfppnnrd-ttlcn = t_record1-val1.

*            PERFORM f_tax_calc USING '' t_record1-val1 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val1 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val1 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val1 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln2 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln2.
              CONCATENATE gv_brcod va_brcode t_record1-seq2 t_record1-dok2
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl2.
              t_zfppnnrd-ttlcn = t_record1-val2.

*            PERFORM f_tax_calc USING '' t_record1-val2 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val2 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val2 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val2 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln3 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln3.
              CONCATENATE gv_brcod va_brcode t_record1-seq3 t_record1-dok3
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl3.
              t_zfppnnrd-ttlcn = t_record1-val3.

*            PERFORM f_tax_calc USING '' t_record1-val3 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val3 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val3 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val3 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln4 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln4.
              CONCATENATE gv_brcod va_brcode t_record1-seq4 t_record1-dok4
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl4.
              t_zfppnnrd-ttlcn = t_record1-val4.

*            PERFORM f_tax_calc USING '' t_record1-val4 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val4 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val4 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val4 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln5 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln5.
              CONCATENATE gv_brcod va_brcode t_record1-seq5 t_record1-dok5
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl5.
              t_zfppnnrd-ttlcn = t_record1-val5.

*            PERFORM f_tax_calc USING '' t_record1-val5 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val5 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val5 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val5 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln6 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln6.
              CONCATENATE gv_brcod va_brcode t_record1-seq6 t_record1-dok6
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl6.
              t_zfppnnrd-ttlcn = t_record1-val6.

*            PERFORM f_tax_calc USING '' t_record1-val6 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val6 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val6 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val6 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln7 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln7.
              CONCATENATE gv_brcod va_brcode t_record1-seq7 t_record1-dok7
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl7.
              t_zfppnnrd-ttlcn = t_record1-val7.

*            PERFORM f_tax_calc USING '' t_record1-val7 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val7 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val7 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val7 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln8 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln8.
              CONCATENATE gv_brcod va_brcode t_record1-seq8 t_record1-dok8
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl8.
              t_zfppnnrd-ttlcn = t_record1-val8.

*            PERFORM f_tax_calc USING '' t_record1-val8 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val8 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val8 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val8 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.

            IF NOT t_record1-beln9 IS INITIAL.
              t_zfppnnrd-belnr = t_record1-beln9.
              CONCATENATE gv_brcod va_brcode t_record1-seq9 t_record1-dok9
              INTO t_zfppnnrd-zuonr.
              t_zfppnnrd-budat = t_record1-tgl9.
              t_zfppnnrd-ttlcn = t_record1-val9.

*            PERFORM f_tax_calc USING '' t_record1-val9 'C'
*                               CHANGING t_zfppnnrd-dppcn.
*            PERFORM f_tax_calc USING '' t_record1-val9 'D'
*                               CHANGING t_zfppnnrd-ppncn.

              t_zfppnnrd-dppcn = t_record1-val9 * 10 / 11.
              t_zfppnnrd-ppncn = t_record1-val9 * 1 / 11.
              t_zfppnnrd-ttlcn = t_zfppnnrd-ttlcn / 100.
              t_zfppnnrd-dppcn = t_zfppnnrd-dppcn / 100.
              t_zfppnnrd-ppncn = t_zfppnnrd-ppncn / 100.
              APPEND t_zfppnnrd.
            ENDIF.
          ENDLOOP.
        ELSE.
          t_out3-icon1 = icon_incomplete.
        ENDIF.
        MODIFY t_out3 TRANSPORTING icon1.
      ENDLOOP.
      va_proc = 1.

    WHEN radio15.
      CLEAR : gt_zfppnnrh[], gt_zfppnnrd[], gt_zfppnnrdtl[], gv_subrc.

      PERFORM f_data_customer.
      PERFORM f_data_sales_order.

      LOOP AT gt_out INTO ls_out.
        PERFORM f_prepare_zfppnnrh USING ls_out.
        PERFORM f_prepare_zfppnnrd USING ls_out.
        PERFORM f_prepare_zfppnnrdtl USING ls_out.
      ENDLOOP.

      IF gt_zfppnnrh[] IS NOT INITIAL.
        PERFORM f_isi_zfppnnrh ON COMMIT.
      ENDIF.
      IF gt_zfppnnrd[] IS NOT INITIAL.
        PERFORM f_isi_zfppnnrd ON COMMIT.
      ENDIF.
      IF gt_zfppnnrdtl[] IS NOT INITIAL.
        PERFORM f_isi_zfppnnrdtl ON COMMIT.
      ENDIF.

      IF gv_subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_isi_table

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant
                                   fc_desc.

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
*&      Form  f_input_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_input_header.
  DATA: ld_ttlnr(15),
        ld_ppnnr(15),
        ld_dppnr(15),
        ld_npwp(50),
        ld_nppkp(50),
        ld_amtcn(15),
        ld_nomor(100).

  IF va_preview EQ 1.
    WRITE:/ 'Nomor NR   :', nonr,
           50 name1.
    WRITE:/ 'Tanggal NR :', nrdt,
           50 name_co.
  ELSE.
    WRITE:/5 name1.
    WRITE:/5 name_co.
  ENDIF.

  WRITE ttlnr TO ld_ttlnr DECIMALS 0.
  SHIFT ld_ttlnr LEFT DELETING LEADING space.
  WRITE ppnnr TO ld_ppnnr DECIMALS 0.
  SHIFT ld_ppnnr LEFT DELETING LEADING space.
  WRITE dppnr TO ld_dppnr DECIMALS 0.
  SHIFT ld_dppnr LEFT DELETING LEADING space.
  WRITE va_amtcn TO ld_amtcn CURRENCY 'IDR'.
  SHIFT ld_amtcn LEFT DELETING LEADING space.

  IF va_preview EQ 1.
    WRITE:/ 'Total NR   :', ld_ttlnr DECIMALS 0,
           50 street.
    WRITE:/ 'Total DPP  :', ld_dppnr DECIMALS 0,
           50 city.
  ELSE.
    WRITE:/5 street.
    WRITE:/5 city.
  ENDIF.

  IF ld_npwp IS NOT INITIAL AND
    ld_nppkp IS NOT INITIAL.
    CONCATENATE ld_npwp '-' ld_nppkp INTO ld_nomor SEPARATED BY space.
  ENDIF.
  IF ld_npwp IS INITIAL.
    ld_nomor = ld_nppkp.
  ENDIF.
  IF ld_nppkp IS INITIAL.
    ld_nomor = ld_npwp.
  ENDIF.

  IF va_preview EQ 1.
    WRITE:/ 'Total PPN  :', ld_ppnnr,
           50 ld_nomor.
  ELSE.
    WRITE:/5 ld_nomor.
  ENDIF.

*  IF ld_dppnr NE ld_amtcn.
*    FORMAT COLOR 6.
*    WRITE: / ' Total NR tidak sama dengan total CN '.
*    FORMAT COLOR OFF.
*  ELSE.
*    FORMAT COLOR 5.
*    WRITE: / ' Total NR sama dengan total CN '.
*    FORMAT COLOR OFF.
*  ENDIF.
ENDFORM.                    " f_input_header

*&---------------------------------------------------------------------*
*&      Form  f_upload_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload_header.
  IF NOT va_proc IS INITIAL.
    WRITE: /5 icon_checked AS ICON, '= Upload sukses'.
    WRITE: /5 icon_incomplete AS ICON, '= Upload gagal'.
  ENDIF.
ENDFORM.                    " f_upload_header

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_500.
  DATA: ld_date      TYPE sy-datum,
        ld_nonr      LIKE nonr,
        ld_len       TYPE i,
        ld_selisih   LIKE ttlnr,
        ld_error1    TYPE i,
        ld_error2    TYPE i,
        ld_error3    TYPE i,
        ld_error4    TYPE i,
        ld_error5    TYPE i,
        ld_ttlcn     LIKE zfppnnrd-ttlcn,
        ld_ttlnr     LIKE zfppnnrd-ttlnr,
        ld_mess(50)  VALUE 'Format no seri faktur pajak SALAH',
        ld_mess1(50)
        VALUE 'Total DPP & VAT tidak sama dengan Total value'.

* Check tanggal nota retur
  IF NOT pa_monat IS INITIAL AND
    NOT pa_gjahr IS INITIAL.
    CONCATENATE pa_gjahr pa_monat '01' INTO ld_date.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ld_date
      IMPORTING
        last_day_of_month = ld_date.
    IF nrdt GT ld_date.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'NRD'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      va_valcust  = 2.
      MESSAGE e000(zab) WITH 'Tanggal Nota Retur salah'.
    ENDIF.
  ENDIF.

* Check nomor nota retur
  SELECT SINGLE nonr
    FROM zfppnnrh
    INTO ld_nonr
    WHERE bukrs EQ pa_vkorg AND
          kunnr EQ pa_kunnr AND
          gjahr EQ pa_gjahr AND
          nonr  EQ nonr.
  IF sy-subrc EQ 0.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'NNR'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH 'No Nota Retur sudah ada'.
  ENDIF.

* Check Total value VS DPP value + PPN value
  ld_selisih = dppnr + ppnnr.
  IF ttlnr NE ld_selisih.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'TOT'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess1.
  ENDIF.

* Check 1 CN < NR
  IF wa_zfnrcncust IS NOT INITIAL.
    LOOP AT t_zfppnnrd WHERE zuonr = t_out1-vbeln.
      ld_ttlcn = t_zfppnnrd-ttlcn.
      ld_ttlnr = ld_ttlnr + t_zfppnnrd-ttlnr.
    ENDLOOP.
    ld_ttlnr = ld_ttlnr + ( ttlnr / 100 ).
    IF sy-subrc = 0 AND ld_ttlnr GT ld_ttlcn.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'TOT'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      MESSAGE e000(zab) WITH 'Total NR lebih besar dari total CN'.
    ENDIF.
  ENDIF.
  CLEAR: va_preview.
ENDFORM.                    " f_validate_screen_500

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000.
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'KU2' '0' '',
                                        'VK2' '0' '',
                                        'FLN' '0' '',
                                        'NON' '0' '',
                                        'NDT' '0' '',
                                        'VAR' '' '0',
                                        'HKO' '0' '',
                                        'MO1' '0' '',
                                        'GJ1' '0' '',
                                        'MO2' '0' '',
                                        'GJ2' '0' '',
                                        'DES' '0' '',
                                        'PEM' '0' '',
                                        'NPE' '0' '',
                                        'JPE' '0' '',
                                        'VRS' '0' '',
                                        'VR1' '0' '',
                                        'PDW' '' '0'.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio2.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'FLN' '0' '',
                                        'VK2' '0' '',
                                        'KU1' '0' '',
                                        'NDT' '0' '',
                                        'VBE' '0' '',
                                        'FKD' '0' '',
                                        'MO1' '0' '',
                                        'GJ1' '0' '',
                                        'MO2' '0' '',
                                        'GJ2' '0' '',
                                        'VAR' '' '0',
                                        'HKO' '0' '',
                                        'DES' '0' '',
                                        'PEM' '0' '',
                                        'NPE' '0' '',
                                        'JPE' '0' '',
                                        'VR1' '0' '',
                                        'PDW' '' '0'.

        IF screen-group1 = 'VRS' AND va_usrgrp IS INITIAL.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio3 OR radio15.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'KU1' '0' '',
                                        'KU2' '0' '',
                                        'VK2' '0' '',
                                        'NON' '0' '',
                                        'NDT' '0' '',
                                        'VBE' '0' '',
                                        'FKD' '0' '',
                                        'VAR' '' '0',
                                        'HKO' '0' '',
                                        'MO1' '0' '',
                                        'GJ1' '0' '',
                                        'MO2' '0' '',
                                        'GJ2' '0' '',
                                        'DES' '0' '',
                                        'PEM' '0' '',
                                        'NPE' '0' '',
                                        'JPE' '0' '',
                                        'VRS' '0' '',
                                        'VR1' '0' ''.
        IF radio3 = 'X'.
          PERFORM f_modify_screen USING : 'PDW' '' '0'.
        ELSE.
          IF pa_down IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'VKO' '0' '',
                                            'VK1' '0' '',
                                            'MON' '0' '',
                                            'GJH' '0' '',
                                            'FLN' '0' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'MON' '0' '',
                                            'GJH' '0' ''.
          ENDIF.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio4.
      IF radio4 EQ 'X'.
        AUTHORITY-CHECK OBJECT 'ZNOTARETUR'
                  ID 'ACTVT' FIELD '03'.
        IF sy-subrc NE 0.
          va_auth = 1.
        ENDIF.
      ENDIF.

      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF va_auth EQ 1.
          IF screen-group1 = 'VK2'.
            screen-active  = 0.
          ENDIF.
        ELSE.
          IF screen-group1 = 'VK1'.
            screen-active  = 0.
          ENDIF.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio10.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio5.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'VK1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio6.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'VK1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio8 OR radio13.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio7.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio9.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio11.
      LOOP AT SCREEN.
*        IF screen-group1 = 'FKD'.
*          screen-active  = 0.
*        ENDIF.
*        IF screen-group1 = 'KU2'.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
*        IF screen-group1 = 'VK2'.
        IF screen-group1 = 'VK1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FLN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
*        IF screen-group1 = 'VR1'.
*          screen-active  = 0.
*        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio12.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'HKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-input  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio14.
      LOOP AT SCREEN.
        PERFORM f_modify_screen USING : 'PDW' '' '0'.
        IF screen-group1 = 'VK1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VK2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VAR'.
          screen-input   = 0.
        ENDIF.
        IF screen-group1 = 'VBE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'FKD'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MON'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJH'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'MO2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJ2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VR1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DES'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PEM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'JPE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'VRS'.
          screen-active  = 0.
        ENDIF.
        CLEAR: pa_vari.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_modify_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_500.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'KUN'.
      screen-input      = 0.
      screen-display_3d = 0.
    ENDIF.
    IF screen-group1 EQ 'NAM'.
      screen-input      = 0.
      screen-display_3d = 0.
    ENDIF.
    IF screen-group1 EQ 'NCO'.
      screen-input      = 0.
      screen-display_3d = 0.
    ENDIF.
    IF screen-group1 EQ 'STR'.
      screen-input      = 0.
      screen-display_3d = 0.
    ENDIF.
    IF screen-group1 EQ 'CIT'.
      screen-input      = 0.
      screen-display_3d = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  IF va_valcust = 0.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'PRE'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF wa_zfnrcncust IS NOT INITIAL.
    p_city = 'XXX'.
    p_nmpem = 'XXX'.
    p_japem = 'XXX'.
    p_dest = 'XXX'.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'PRE'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    IF rvat1 IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'VA2'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSEIF rvat2 IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'VA1'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'VA1' OR
        screen-group1 EQ 'VA2' OR
        screen-group1 EQ 'VAT'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_modify_screen_500

*&---------------------------------------------------------------------*
*&      Form  f_filename_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FILENAME  text
*----------------------------------------------------------------------*
FORM f_filename_f4 CHANGING p_filename.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
      field_name    = 'FILENAME'
    IMPORTING
      file_name     = p_filename.
ENDFORM.                    " f_filename_f4

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000.
  DATA: ld_brcode(1),
        ld_mess(50)   VALUE 'Make an entry in all required fields',
        ld_error      TYPE i,
        ld_datum      TYPE sy-datum,
        ld_datum_low  TYPE sy-datum,
        ld_datum_high TYPE sy-datum.

  RANGES: ra_datum FOR sy-datum.

  CLEAR: ld_error.

  IF NOT pa_kunnr IS INITIAL.
    SELECT SINGLE a~stkza a~stceg
                  c~name1 c~name_co c~str_suppl1 c~str_suppl2 c~str_suppl3
      FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                     JOIN adrc AS c ON a~adrnr EQ c~addrnumber
      INTO (va_stkza, wa_header-stceg, name1, name_co, wa_header-str_suppl1, wa_header-str_suppl2, wa_header-str_suppl3)
      WHERE a~kunnr EQ pa_kunnr AND
            b~vkbur EQ pa_vkbur.

    IF sy-subrc EQ 0.
      kunnr = pa_kunnr.
      va_name1  = name1.
      CONCATENATE 'Nama D/N :' name1 INTO name SEPARATED BY space.
      CONCATENATE 'Nama c/o :' name_co INTO name_co1 SEPARATED BY space.
      va_alamat = street = wa_header-str_suppl1.
      CONCATENATE wa_header-str_suppl2 wa_header-str_suppl3 INTO city SEPARATED BY space.
      va_kota  = city.
      va_npwp  = wa_header-stceg.
      IF va_stkza IS NOT INITIAL.
        va_nppkp  = wa_header-stceg.
      ENDIF.
    ELSE.
      ld_error = sy-subrc.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      AUTHORITY-CHECK OBJECT 'ZNRENTRY'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF pa_kunnr IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'KU1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF so_fkdat IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-name = '%_SO_FKDAT_%_APP_%-OPTI_PUSH'.
            screen-active = 0.
          ENDIF.
          IF screen-group1 EQ 'FKD'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        IF so_fkdat-low LT '20070101'.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-name = '%_SO_FKDAT_%_APP_%-OPTI_PUSH'.
              screen-active = 0.
            ENDIF.
            IF screen-group1 EQ 'FKD'.
              screen-input = 1.
            ELSE.
              screen-input = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH 'CN Date harus >= thn 2007'.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ENDIF.

      IF pa_monat IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'MON'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF pa_gjahr IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'GJH'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio2.
      AUTHORITY-CHECK OBJECT 'ZNRENTRY'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio3.
      AUTHORITY-CHECK OBJECT 'ZNRUPLOAD'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF pa_monat IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'MON'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF pa_gjahr IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'GJH'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF filename IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'FLN'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio4.
      IF va_auth EQ 1.
        IF pa_vkbur IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'VK1'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ENDIF.

      IF so_fkdat IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-name = '%_SO_FKDAT_%_APP_%-OPTI_PUSH'.
            screen-active = 0.
          ENDIF.
          IF screen-group1 EQ 'FKD'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        IF so_fkdat-low LT '20070101'.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-name = '%_SO_FKDAT_%_APP_%-OPTI_PUSH'.
              screen-active = 0.
            ENDIF.
            IF screen-group1 EQ 'FKD'.
              screen-input = 1.
            ELSE.
              screen-input = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH 'CN Date harus >= thn 2007'.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ENDIF.

    WHEN radio5.
      AUTHORITY-CHECK OBJECT 'ZNOTARETUR'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.

      IF va_auth EQ 0.
        SELECT *
          FROM zfnrhkont
          INTO CORRESPONDING FIELDS OF TABLE t_zfnrhkont
          WHERE bukrs EQ pa_vkorg AND
                vkbur IN so_vkbur.

        IF pa_monat IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'MON'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.

        IF pa_gjahr IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'GJH'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ENDIF.

    WHEN radio6.
      AUTHORITY-CHECK OBJECT 'ZNOTARETUR'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.

    WHEN radio7.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

      IF pa_kunnr IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'KU1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

*      IF p_nmpem1 IS INITIAL.
*        va_error  = 1.
*        LOOP AT SCREEN.
*          IF screen-group1 EQ 'NPE'.
*            screen-input  = 1.
*          ELSE.
*            screen-input  = 0.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDLOOP.
*        MESSAGE e000(zab) WITH ld_mess.
*        CLEAR: sscrfields-ucomm.
*      ELSE.
*        CLEAR: va_error.
*      ENDIF.
*
*      IF p_japem1 IS INITIAL.
*        va_error  = 1.
*        LOOP AT SCREEN.
*          IF screen-group1 EQ 'JPE'.
*            screen-input  = 1.
*          ELSE.
*            screen-input  = 0.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDLOOP.
*        MESSAGE e000(zab) WITH ld_mess.
*        CLEAR: sscrfields-ucomm.
*      ELSE.
*        CLEAR: va_error.
*      ENDIF.

      IF p_dest1 IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'DES'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio8 OR radio13.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio9.
      IF pa_vkbur IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'VK1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        CLEAR: va_error.
      ENDIF.

    WHEN radio15.
      IF pa_down IS INITIAL.

        IF pa_vkbur IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'VK1'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.

        IF filename IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'FLN'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ENDIF.
  ENDCASE.

  CASE 'X'.
    WHEN radio1 OR
      radio2.
      CONCATENATE pa_gjahr pa_monat '01' INTO ld_datum.
      LOOP AT t_close WHERE vkorg EQ pa_vkorg AND
                            vkbur EQ pa_vkbur.
        CONCATENATE t_close-gjahr t_close-monat '01'
          INTO ld_datum_low.
        CONCATENATE t_close-gjahrto t_close-monatto '01'
          INTO ld_datum_high.
        ra_datum-low    = ld_datum_low.
        ra_datum-high   = ld_datum_high.
        ra_datum-sign   = 'E'.
        ra_datum-option = 'BT'.
        APPEND ra_datum.
        IF ld_datum IN ra_datum.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'MON'.
              screen-input  = 1.
            ELSEIF screen-group1 EQ 'GJH'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH 'Period error'.
        ENDIF.
      ENDLOOP.

      IF sy-subrc NE 0.
        LOOP AT t_close WHERE vkorg EQ pa_vkorg AND
                              vkbur EQ space.
          CONCATENATE t_close-gjahr t_close-monat '01'
            INTO ld_datum_low.
          CONCATENATE t_close-gjahrto t_close-monatto '01'
            INTO ld_datum_high.
          ra_datum-low    = ld_datum_low.
          ra_datum-high   = ld_datum_high.
          ra_datum-sign   = 'E'.
          ra_datum-option = 'BT'.
          APPEND ra_datum.
          IF ld_datum IN ra_datum.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'MON'.
                screen-input  = 1.
              ELSEIF screen-group1 EQ 'GJH'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'Period error'.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ld_datum
        IMPORTING
          last_day_of_month = ld_datum.

      IF radio1 EQ 'X'.
        IF so_fkdat-high IS NOT INITIAL.
          IF so_fkdat-high GT ld_datum.
            va_error  = 1.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'FKD'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'CN Date Error'.
            CLEAR: sscrfields-ucomm.
          ELSE.
            CLEAR: va_error.
          ENDIF.
        ELSE.
          IF so_fkdat-low GT ld_datum.
            va_error  = 1.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'FKD'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'CN Date Error'.
            CLEAR: sscrfields-ucomm.
          ELSE.
            CLEAR: va_error.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio11 OR radio12.
      AUTHORITY-CHECK OBJECT 'ZNRENTRY1'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        va_auth = 1.
        MESSAGE i000(zab)
              WITH 'You have no authorization to process this option'.
        STOP.
      ENDIF.
*      IF pa_vkbur IS INITIAL.
*        va_error  = 1.
*        LOOP AT SCREEN.
*          IF screen-group1 EQ 'VK1'.
*            screen-input  = 1.
*          ELSE.
*            screen-input  = 0.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDLOOP.
*        MESSAGE e000(zab) WITH ld_mess.
*        CLEAR: sscrfields-ucomm.
*      ELSE.
*        CLEAR: va_error.
*      ENDIF.

      IF radio11 EQ 'X'.
*        IF pa_kunnr IS INITIAL.
        IF so_kunnr[] IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
*            IF screen-group1 EQ 'KU1'.
            IF screen-group1 EQ 'KU2'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
        IF so_vkbur[] IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'VK2'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
      ELSEIF radio12 EQ 'X'.
        IF pa_vkbur IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'VK1'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
        IF pa_monat IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'MON'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.

        IF pa_gjahr IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'GJH'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.

        IF filename IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'FLN'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          CLEAR: va_error.
        ENDIF.
        CONCATENATE pa_gjahr pa_monat '01' INTO ld_datum.
        LOOP AT t_close WHERE vkorg EQ pa_vkorg AND
                              vkbur EQ pa_vkbur.
          CONCATENATE t_close-gjahr t_close-monat '01'
            INTO ld_datum_low.
          CONCATENATE t_close-gjahrto t_close-monatto '01'
            INTO ld_datum_high.
          ra_datum-low    = ld_datum_low.
          ra_datum-high   = ld_datum_high.
          ra_datum-sign   = 'E'.
          ra_datum-option = 'BT'.
          APPEND ra_datum.
          IF ld_datum IN ra_datum.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'MON'.
                screen-input  = 1.
              ELSEIF screen-group1 EQ 'GJH'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'Period error'.
          ENDIF.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000_rad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000_rad.
  CHECK sy-dynnr <> '0500'.

  LOOP AT t_close WHERE vkorg EQ pa_vkorg AND
                        vkbur EQ pa_vkbur.
    va_subrc = sy-subrc.
    pa_monat = t_close-monat.
    pa_gjahr = t_close-gjahr.
  ENDLOOP.

  IF sy-subrc NE 0.
    va_subrc = sy-subrc.
  ENDIF.

*  SELECT *
*    FROM zfnrclose
*    INTO CORRESPONDING FIELDS OF TABLE t_close
*    WHERE vkorg EQ pa_vkorg AND
*          vkbur EQ space.
*  IF sy-subrc EQ 0.
*    va_subrc = sy-subrc.
*    LOOP AT t_close.
*      pa_monat = t_close-monat.
*      pa_gjahr = t_close-gjahr.
*    ENDLOOP.
*  ELSE.
*    SELECT *
*      FROM zfnrclose
*      INTO CORRESPONDING FIELDS OF TABLE t_close
*      WHERE vkorg EQ pa_vkorg AND
*            vkbur EQ pa_vkbur.
*    va_subrc = sy-subrc.
*    LOOP AT t_close.
*      pa_monat = t_close-monat.
*      pa_gjahr = t_close-gjahr.
*    ENDLOOP.
*  ENDIF.
ENDFORM.                    " f_validate_screen_1000_rad

*&---------------------------------------------------------------------*
*&      Form  f_delete_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_data.
  LOOP AT t_out2 WHERE check EQ 'X'.
    t_delete = t_out2.
    APPEND t_delete.
    UPDATE zfppnnrh_d FROM TABLE t_delete.
    IF sy-subrc NE 0.
      INSERT zfppnnrh_d FROM t_delete.
    ENDIF.

    IF va_usrgrp IS INITIAL.
      DELETE FROM zfppnnrh WHERE vrsio EQ space        AND
                                 bukrs EQ t_out2-bukrs AND
                                 kunnr EQ t_out2-kunnr AND
                                 gjahr EQ t_out2-gjahr AND
                                 nonr  EQ t_out2-nonr.
      DELETE FROM zfppnnrd WHERE vrsio EQ space        AND
                                 bukrs EQ t_out2-bukrs AND
                                 kunnr EQ t_out2-kunnr AND
                                 gjahr EQ t_out2-gjahr AND
                                 nonr  EQ t_out2-nonr.
    ELSE.
      DELETE FROM zfppnnrh WHERE vrsio EQ t_out2-vrsio AND
                                 bukrs EQ t_out2-bukrs AND
                                 kunnr EQ t_out2-kunnr AND
                                 gjahr EQ t_out2-gjahr AND
                                 nonr  EQ t_out2-nonr.
      DELETE FROM zfppnnrd WHERE vrsio EQ t_out2-vrsio AND
                                 bukrs EQ t_out2-bukrs AND
                                 kunnr EQ t_out2-kunnr AND
                                 gjahr EQ t_out2-gjahr AND
                                 nonr  EQ t_out2-nonr.
    ENDIF.
    DELETE FROM zfppnnrdtl WHERE bukrs EQ t_out2-bukrs AND
                                 kunnr EQ t_out2-kunnr AND
                                 gjahr EQ t_out2-gjahr AND
                                 nonr  EQ t_out2-nonr.
    DELETE t_out2.
    PERFORM f_change_document.
  ENDLOOP.
ENDFORM.                    " f_delete_data

*&---------------------------------------------------------------------*
*&      Form  f_commit_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_commit_work.
  IF t_detail[] IS NOT INITIAL AND
    va_legacy IS INITIAL.
    IF va_commit EQ 1.
      PERFORM f_data_modify.
    ELSE.
      SORT t_detail BY matnr.
      LOOP AT t_detail WHERE vbeln EQ t_out1-vbeln.
        t_out6-nonr   = nonr.
        t_out6-matnr  = t_detail-matnr.
        t_out6-arktx  = t_detail-arktx.
        t_out6-fkimg  = t_detail-fkimg.
        t_out6-kzwi1  = t_detail-kzwi1.
        t_out6-kzwi5  = t_detail-kzwi5.
        t_out6-skfbp  = t_detail-kzwi1 - t_detail-kzwi5.
        t_out6-netwr  = t_detail-netwr.
        t_out6-vrkme  = t_detail-vrkme.
        t_out6-waerk  = t_detail-waerk.
        t_out6-hrgsat = 0.
        ON CHANGE OF t_detail-matnr.
          t_out6-hrgsat = t_detail-kzwi1 / t_detail-fkimg.
        ENDON.
        COLLECT t_out6.
      ENDLOOP.

      PERFORM f_data_modify.
    ENDIF.
  ENDIF.

  INSERT zfppnnrh FROM TABLE t_zfppnnrh.
  INSERT zfppnnrd FROM TABLE t_zfppnnrd.
  INSERT zfppnnrdtl FROM TABLE t_zfppnnrdtl.
ENDFORM.                    " f_commit_work

*&---------------------------------------------------------------------*
*&      Form  f_gui_upload_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_RECORD  text
*      -->P_FILENAME  text
*----------------------------------------------------------------------*
FORM f_gui_upload_file TABLES ft_record STRUCTURE t_record
                       USING  fu_filename.

  DATA: ld_filelength TYPE i.
  DATA: ld_filename   LIKE rlgrap-filename.

  ld_filename = fu_filename.

*Begin remark Unicode conversion - DEVK965581
*27.02.2020 - SOL_FELIX
*  CALL FUNCTION 'WS_UPLOAD'
*    EXPORTING
*      filename                = ld_filename
*      filetype                = 'ASC'
*      has_field_separator     = 'X'
*    IMPORTING
*      filelength              = ld_filelength
*    TABLES
*      data_tab                = t_data_tab
*    EXCEPTIONS
*      file_open_error         = 1
*      file_read_error         = 2
*      no_batch                = 3
*      gui_refuse_filetransfer = 4
*      invalid_type            = 5
*      no_authority            = 6
*      unknown_error           = 7
*      bad_data_format         = 8
*      header_not_allowed      = 9
*      separator_not_allowed   = 10
*      header_too_long         = 11
*      unknown_dp_error        = 12
*      access_denied           = 13
*      dp_out_of_memory        = 14
*      disk_full               = 15
*      dp_timeout              = 16
*      OTHERS                  = 17.
**  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  ENDIF.
*End remark Unicode conversion - DEVK965581

*Begin insert Unicode conversion - DEVK965581
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  CLEAR lv_filename.
  lv_filename = ld_filename.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
      has_field_separator     = 'X'
    CHANGING
      data_tab                = t_data_tab[]
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*
  ENDIF.
*End insert Unicode conversion - DEVK965581

  ft_record[] = t_data_tab[].
  REFRESH: t_data_tab. CLEAR: t_data_tab.
ENDFORM.                    " f_gui_upload_file

*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: ld_pattern(5) VALUE ',00',
        ld_sortl      LIKE kna1-sortl,
        ld_count      TYPE i,
        ld_line1      TYPE i,
        ld_line2      TYPE i,
        ld_vbel1      LIKE zfppnnrd-belnr,
        ld_vbel2      LIKE zfppnnrd-belnr,
        ld_vbel3      LIKE zfppnnrd-belnr,
        ld_vbel4      LIKE zfppnnrd-belnr,
        ld_vbel5      LIKE zfppnnrd-belnr,
        ld_vbel6      LIKE zfppnnrd-belnr,
        ld_vbel7      LIKE zfppnnrd-belnr,
        ld_vbel8      LIKE zfppnnrd-belnr,
        ld_vbel9      LIKE zfppnnrd-belnr.

  RANGES: lr_vbeln FOR zsl_hsales-vbeln,
          lr_gjahr FOR zsl_hsales-gjahr.

  CONCATENATE gv_brcod va_brcode '%'
    INTO ld_sortl.
  SELECT a~kunnr a~name1 a~stceg sortl
    FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
    INTO CORRESPONDING FIELDS OF TABLE t_kna1
    WHERE b~vkorg EQ pa_vkorg AND
          b~vkbur EQ pa_vkbur AND
          a~sortl LIKE ld_sortl.

  IF NOT t_record[] IS INITIAL.
    SELECT *
      FROM zfppnnrh
      INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrh
      FOR ALL ENTRIES IN t_record
      WHERE bukrs EQ pa_vkorg AND
            monat EQ pa_monat AND
            gjahr EQ pa_gjahr AND
            nonr  EQ t_record-nomor.
  ENDIF.

  CLEAR: ld_sortl.
  LOOP AT t_record.
    t_record1 = t_record.

*----- Validasi branch legacy -----*
    IF t_record-brcod NE va_brcode.
      t_record1-message = 'Branch code legacy salah'.
    ENDIF.

*----- Validasi bulan -----*
    IF t_record-bln NE pa_monat.
      t_record1-message = 'Bulan salah'.
    ENDIF.

*-----  Validasi tahun -----*
    IF t_record-thn NE pa_gjahr.
      t_record1-message = 'Tahun salah'.
    ENDIF.

*-----  Validasi customer -----*
    CONCATENATE gv_brcod va_brcode t_record-outgr t_record-outcd
      INTO ld_sortl.
    READ TABLE t_kna1 WITH KEY sortl = ld_sortl.
    IF sy-subrc EQ 0.
      t_record1-kunnr   = t_kna1-kunnr.
      t_record1-name1   = t_kna1-name1.
      t_record1-stceg   = t_kna1-stceg.
    ELSE.
      t_record1-message = 'Customer salah'.
    ENDIF.

*-----  Validasi record upload vs ZFPPNNRH -----*
    READ TABLE t_zfppnnrh WITH KEY kunnr = t_record1-kunnr
                                   monat = t_record1-bln
                                   gjahr = t_record1-thn
                                   nonr  = t_record1-nomor.
    IF sy-subrc EQ 0.
      t_record1-message = 'Nomor nota retur sudah ada'.
    ENDIF.

*-----  Validasi accounting document -----*
    IF NOT t_record-dok1 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq1 t_record-dok1
      INTO ld_vbel1.
      lr_vbeln-low    = ld_vbel1.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl1 IS INITIAL.
        lr_gjahr-low    = t_record-tgl1(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel1.
    ENDIF.
    IF NOT t_record-dok2 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq2 t_record-dok2
      INTO ld_vbel2.
      lr_vbeln-low    = ld_vbel2.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl2 IS INITIAL.
        lr_gjahr-low    = t_record-tgl2(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel2.
    ENDIF.
    IF NOT t_record-dok3 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq3 t_record-dok3
      INTO ld_vbel3.
      lr_vbeln-low    = ld_vbel3.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl3 IS INITIAL.
        lr_gjahr-low    = t_record-tgl3(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel3.
    ENDIF.
    IF NOT t_record-dok4 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq4 t_record-dok4
      INTO ld_vbel4.
      lr_vbeln-low    = ld_vbel4.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl4 IS INITIAL.
        lr_gjahr-low    = t_record-tgl4(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel4.
    ENDIF.
    IF NOT t_record-dok5 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq5 t_record-dok5
      INTO ld_vbel5.
      lr_vbeln-low    = ld_vbel5.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl5 IS INITIAL.
        lr_gjahr-low    = t_record-tgl5(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel5.
    ENDIF.
    IF NOT t_record-dok6 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq6 t_record-dok6
      INTO ld_vbel6.
      lr_vbeln-low    = ld_vbel6.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl6 IS INITIAL.
        lr_gjahr-low    = t_record-tgl6(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel6.
    ENDIF.
    IF NOT t_record-dok7 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq7 t_record-dok7
      INTO ld_vbel7.
      lr_vbeln-low    = ld_vbel7.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl7 IS INITIAL.
        lr_gjahr-low    = t_record-tgl7(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel7.
    ENDIF.
    IF NOT t_record-dok8 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq8 t_record-dok8
      INTO ld_vbel8.
      lr_vbeln-low    = ld_vbel8.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl8 IS INITIAL.
        lr_gjahr-low    = t_record-tgl8(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel8.
    ENDIF.
    IF NOT t_record-dok9 IS INITIAL.
      CONCATENATE gv_brcod va_brcode t_record-seq9 t_record-dok9
      INTO ld_vbel9.
      lr_vbeln-low    = ld_vbel9.
      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      APPEND lr_vbeln.

      IF NOT t_record-tgl9 IS INITIAL.
        lr_gjahr-low    = t_record-tgl9(4).
        lr_gjahr-sign   = 'I'.
        lr_gjahr-option = 'EQ'.
        COLLECT lr_gjahr.
      ENDIF.
    ELSE.
      ADD 1 TO ld_count.
      CLEAR: ld_vbel9.
    ENDIF.

    IF ld_count EQ 9.
      t_record1-message = 'Tidak ada data detail'.
    ENDIF.

    IF NOT lr_vbeln IS INITIAL.
      CASE pa_vkorg.
        WHEN '8020'.
          SELECT *
            FROM zsl_hsales
            INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
            WHERE vkorg EQ pa_vkorg AND
                  vkbur EQ pa_vkbur AND
                  gjahr IN lr_gjahr AND
                  vbeln IN lr_vbeln AND
                  vbtyp EQ 'O'.
        WHEN '8070'.
          SELECT *
            FROM zssutdt005
            INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
            WHERE vkorg EQ pa_vkorg AND
                  vkbur EQ pa_vkbur AND
                  gjahr IN lr_gjahr AND
                  vbeln IN lr_vbeln AND
                  vbtyp EQ 'O'.
        WHEN OTHERS.
      ENDCASE.

      IF sy-subrc EQ 0.
        PERFORM f_filter_legacy.

        DESCRIBE TABLE lr_vbeln LINES ld_line1.
        DESCRIBE TABLE t_zsl_hsales LINES ld_line2.
        IF ld_line1 NE ld_line2.
          t_record1-message = 'Accounting document tidak ada'.
        ELSE.
          IF NOT t_record-dok1 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel1.
            IF sy-subrc EQ 0.
              t_record1-beln1 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok2 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel2.
            IF sy-subrc EQ 0.
              t_record1-beln2 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok3 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel3.
            IF sy-subrc EQ 0.
              t_record1-beln3 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok4 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel4.
            IF sy-subrc EQ 0.
              t_record1-beln4 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok5 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel5.
            IF sy-subrc EQ 0.
              t_record1-beln5 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok6 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel6.
            IF sy-subrc EQ 0.
              t_record1-beln6 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok7 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel7.
            IF sy-subrc EQ 0.
              t_record1-beln7 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok8 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel8.
            IF sy-subrc EQ 0.
              t_record1-beln8 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
          IF NOT t_record-dok9 IS INITIAL.
            READ TABLE t_zsl_hsales WITH KEY vbeln = ld_vbel9.
            IF sy-subrc EQ 0.
              t_record1-beln9 = t_zsl_hsales-account_no.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        t_record1-message = 'Accounting document tidak ada'.
      ENDIF.
    ENDIF.

    REPLACE ld_pattern WITH space INTO t_record1-dpp.
    REPLACE ld_pattern WITH space INTO t_record1-ppn.
    REPLACE ld_pattern WITH space INTO t_record1-total.
    REPLACE ld_pattern WITH space INTO t_record1-val1.
    REPLACE ld_pattern WITH space INTO t_record1-val2.
    REPLACE ld_pattern WITH space INTO t_record1-val3.
    REPLACE ld_pattern WITH space INTO t_record1-val4.
    REPLACE ld_pattern WITH space INTO t_record1-val5.
    REPLACE ld_pattern WITH space INTO t_record1-val6.
    REPLACE ld_pattern WITH space INTO t_record1-val7.
    REPLACE ld_pattern WITH space INTO t_record1-val8.
    REPLACE ld_pattern WITH space INTO t_record1-val9.
    APPEND t_record1.

    t_count-kunnr     = t_record1-kunnr.
    t_count-nonr      = t_record1-nomor.
    t_count-count     = 1.
    COLLECT t_count.
    REFRESH: lr_vbeln.
    CLEAR: t_record1, lr_vbeln, ld_line1, ld_line2, ld_count, t_count.
  ENDLOOP.
  REFRESH: t_zfppnnrh.
  CLEAR: t_zfppnnrh.

  DELETE t_count WHERE count EQ 1.

  IF NOT t_count[] IS INITIAL.
    SORT t_record1 BY kunnr nomor.
    SORT t_count BY kunnr nonr.
    LOOP AT t_record1.
      READ TABLE t_count WITH KEY kunnr = t_record1-kunnr
                                  nonr  = t_record1-nomor
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_record1-message = 'Nomor nota retur dobel'.
        MODIFY t_record1 TRANSPORTING message.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_validate_data

*&---------------------------------------------------------------------*
*&      Form  f_update_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_table USING fc_msgv1
                          fc_bldat
                          fc_shkzg
                          fc_hkont2
                          fc_nilai.

  DATA: ld_belnrrc LIKE zfppnnrh-belnrrc.
  UNPACK fc_msgv1 TO ld_belnrrc.

  UPDATE zfppnnrh SET belnrrc = ld_belnrrc
                      gjahrrc = fc_bldat(4)
                      budatrc = fc_bldat
                      hkontrc = fc_hkont2
                      shkzgrc = fc_shkzg
                      wrbtrrc = fc_nilai
                      bdcflag = 'X'
                  WHERE bukrs EQ t_out5-bukrs AND
                        kunnr EQ t_out5-kunnr AND
                        monat EQ t_out5-monat AND
                        gjahr EQ t_out5-gjahr AND
                        nonr  EQ t_out5-nonr.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.                    " f_update_table

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_BLDAT  text
*      <--P_L_DATE  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

  READ TABLE t_user INDEX 1.
  CASE t_user-datfm.
    WHEN 'DD.MM.YYYY'.
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat(4)
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat(4)
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.
ENDFORM.                    " f_format_date

*&---------------------------------------------------------------------*
*&      Form  f_table_locking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_locking.
  DATA: lw_zfppnnrh   LIKE t_zfppnnrh,
        lw_data       LIKE t_data,
        lw_zsl_hsales LIKE t_zsl_hsales,
        ld_user       LIKE sy-uname,
        ld_subrc      LIKE sy-subrc.

  CASE 'X'.
    WHEN radio1.
      LOOP AT t_data.
        MOVE-CORRESPONDING t_data TO lw_data.
        CALL FUNCTION 'ENQUEUE_EVVBRKE'
          EXPORTING
            mode_vbrk      = 'E'
            mandt          = sy-mandt
            vbeln          = lw_data-vbeln
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        IF sy-subrc NE 0.
          va_lock  = 1.
          ld_user  = sy-msgv1.
          ld_subrc = sy-subrc.
          PERFORM f_error_log_vbrk USING lw_data
                                         ld_user
                                         ld_subrc.
          DELETE t_data.
        ENDIF.
      ENDLOOP.

      LOOP AT t_zsl_hsales.
        MOVE-CORRESPONDING t_zsl_hsales TO lw_zsl_hsales.
        CALL FUNCTION 'ENQUEUE_EZSL_HSALES'
          EXPORTING
            mode_zsl_hsales = 'E'
            mandt           = sy-mandt
            vkorg           = lw_zsl_hsales-vkorg
            plant           = lw_zsl_hsales-plant
            vkbur           = lw_zsl_hsales-vkbur
            gjahr           = lw_zsl_hsales-gjahr
            vbeln           = lw_zsl_hsales-vbeln
            vbtyp           = lw_zsl_hsales-vbtyp
            z_uplod         = lw_zsl_hsales-z_uplod
            fkdat           = lw_zsl_hsales-fkdat
          EXCEPTIONS
            foreign_lock    = 1
            system_failure  = 2
            OTHERS          = 3.

        IF sy-subrc NE 0.
          va_lock  = 1.
          ld_user  = sy-msgv1.
          ld_subrc = sy-subrc.
          PERFORM f_error_log_hsales USING lw_zsl_hsales
                                           ld_user
                                           ld_subrc.
          DELETE t_zsl_hsales.
        ENDIF.
      ENDLOOP.

    WHEN radio2 OR
         radio5.
      LOOP AT t_zfppnnrh.
        MOVE-CORRESPONDING t_zfppnnrh TO lw_zfppnnrh.
        CALL FUNCTION 'ENQUEUE_EZFPPNNRH'
          EXPORTING
            mode_zfppnnrh  = 'E'
            mandt          = sy-mandt
            bukrs          = lw_zfppnnrh-bukrs
            kunnr          = lw_zfppnnrh-kunnr
            monat          = lw_zfppnnrh-monat
            gjahr          = lw_zfppnnrh-gjahr
            nonr           = lw_zfppnnrh-nonr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        IF sy-subrc NE 0.
          ld_user  = sy-msgv1.
          ld_subrc = sy-subrc.
          PERFORM f_error_log_zppnnrh USING lw_zfppnnrh
                                            ld_user
                                            ld_subrc.
          DELETE t_zfppnnrh.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_table_locking

*&---------------------------------------------------------------------*
*&      Form  f_table_unlocking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_unlocking.
  CASE 'X'.
    WHEN radio1.
      LOOP AT t_data.
        CALL FUNCTION 'DEQUEUE_EVVBRKE'
          EXPORTING
            mode_vbrk = 'E'
            mandt     = sy-mandt
            vbeln     = t_data-vbeln.
      ENDLOOP.

      LOOP AT t_zsl_hsales.
        CALL FUNCTION 'DEQUEUE_EZSL_HSALES'
          EXPORTING
            mode_zsl_hsales = 'E'
            mandt           = sy-mandt
            vkorg           = t_zsl_hsales-vkorg
            plant           = t_zsl_hsales-plant
            vkbur           = t_zsl_hsales-vkbur
            gjahr           = t_zsl_hsales-gjahr
            vbeln           = t_zsl_hsales-vbeln
            vbtyp           = t_zsl_hsales-vbtyp
            z_uplod         = t_zsl_hsales-z_uplod
            fkdat           = t_zsl_hsales-fkdat.
      ENDLOOP.

    WHEN radio2 OR
      radio5.
      LOOP AT t_zfppnnrh.
        CALL FUNCTION 'DEQUEUE_EZFPPNNRH'
          EXPORTING
            mode_zfppnnrh = 'E'
            mandt         = sy-mandt
            bukrs         = t_zfppnnrh-bukrs
            kunnr         = t_zfppnnrh-kunnr
            monat         = t_zfppnnrh-monat
            gjahr         = t_zfppnnrh-gjahr
            nonr          = t_zfppnnrh-nonr.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_table_unlocking

*&---------------------------------------------------------------------*
*&      Form  f_error_log_vbrk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_ZFPPNNRH  text
*      -->P_LD_USER  text
*      -->P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM f_error_log_vbrk USING fu_data LIKE t_data
                            fu_user
                            fu_subrc.
  IF fu_subrc EQ 1.
    MOVE-CORRESPONDING fu_data TO t_error1.
    t_error1-msg = fu_user.
    APPEND t_error1.
  ELSE.
    MOVE-CORRESPONDING fu_data TO t_error1.
    t_error1-msg = 'Error when processing the billing'.
    APPEND t_error1.
  ENDIF.
ENDFORM.                    " f_error_log_vbrk

*&---------------------------------------------------------------------*
*&      Form  f_error_log_hsales
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_ZSL_HSALES  text
*      -->P_LD_USER  text
*      -->P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM f_error_log_hsales USING fu_zsl_hsales LIKE t_zsl_hsales
                              fu_user
                              fu_subrc.
  IF fu_subrc EQ 1.
    MOVE-CORRESPONDING fu_zsl_hsales TO t_error2.
    t_error2-msg = fu_user.
    APPEND t_error2.
  ELSE.
    MOVE-CORRESPONDING fu_zsl_hsales TO t_error2.
    t_error1-msg = 'Error when processing the billing'.
    APPEND t_error2.
  ENDIF.
ENDFORM.                    " f_error_log_hsales

*&---------------------------------------------------------------------*
*&      Form  f_error_log_zppnnrh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_error_log_zppnnrh USING fu_zfppnnrh LIKE t_zfppnnrh
                               fu_user
                               fu_subrc.

  IF fu_subrc EQ 1.
    MOVE-CORRESPONDING fu_zfppnnrh TO t_error.
    CONCATENATE 'Data is locked by' fu_user INTO t_error-msg
    SEPARATED BY space.
    APPEND t_error.
  ELSE.
    MOVE-CORRESPONDING fu_zfppnnrh TO t_error.
    t_error-msg = 'Error when processing the billing'.
    APPEND t_error.
  ENDIF.
ENDFORM.                    " f_error_log_zppnnrh

*&---------------------------------------------------------------------*
*&      Module  status_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0501 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " status_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  list_processing_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0501 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " list_processing_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  f_error_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_error_list.
  IF radio12 EQ 'X'.
    IF t_error3[] IS INITIAL.
      SKIP 1.
      WRITE: /13 'No error occurs'.
    ELSE.
      ULINE AT /(93).
      WRITE: /  sy-vline NO-GAP, (30) 'No. CN' NO-GAP,
                sy-vline NO-GAP, (60) 'Error message' NO-GAP,
                sy-vline.
      ULINE AT /(93).
      LOOP AT t_error3.
        WRITE: /  sy-vline NO-GAP, (30) t_error3-zuonr NO-GAP,
                  sy-vline NO-GAP, t_error3-msg(60) NO-GAP,
                  sy-vline NO-GAP.
      ENDLOOP.
      ULINE AT /(93).
    ENDIF.
  ELSE.
    IF t_error[] IS INITIAL.
      SKIP 1.
      WRITE: /13 'No error occurs'.
    ELSE.
      ULINE AT /(93).
      WRITE: /  sy-vline NO-GAP, (30) 'Nomor NR' NO-GAP,
                sy-vline NO-GAP, (60) 'Error message' NO-GAP,
                sy-vline.
      ULINE AT /(93).
      LOOP AT t_error.
        WRITE: /  sy-vline NO-GAP, t_error-nonr NO-GAP,
                  sy-vline NO-GAP, t_error-msg(60) NO-GAP,
                  sy-vline NO-GAP.
      ENDLOOP.
      ULINE AT /(93).
    ENDIF.
  ENDIF.
ENDFORM.                    " f_error_list

*&---------------------------------------------------------------------*
*&      Form  f_get_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data1.
  RANGES: lr_zuonr  FOR zfppnnrd-zuonr.

  IF so_nonr[] IS INITIAL AND
    so_nrdt[] IS INITIAL.
    IF va_mixlive EQ 'X'.
      READ TABLE t_kna1 WITH KEY kunnr = gc_kunnr.
      IF sy-subrc EQ 0.
        PERFORM f_get_billing USING '2'.
      ELSE.
        PERFORM f_get_billing USING '3'.
      ENDIF.

      DELETE ADJACENT DUPLICATES FROM t_data2 COMPARING vbeln.
      LOOP AT t_data2.
        SELECT SINGLE vkbur
          FROM knvv
          INTO t_data2-vkbur
          WHERE kunnr EQ t_data2-kunrg AND
                vkorg EQ t_data2-vkorg.
        MODIFY t_data2 TRANSPORTING vkbur.

        IF t_data2-fkdat GE va_fkdat.
*        IF t_data-fkart IN ra_fkart.
          IF t_data2-auart IN ra_fkart.
            DELETE t_data2.
          ENDIF.
        ENDIF.
      ENDLOOP.

      CASE pa_vkorg.
        WHEN '8020'.
          SELECT *
            FROM zsl_hsales
            INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
            WHERE vkorg EQ pa_vkorg AND
*                vkbur EQ pa_vkbur AND
                  vbeln IN so_vbeln AND
                  vbtyp EQ 'O'      AND
*                  fkdat IN so_fkdat AND
                  bldat IN so_fkdat AND
                  kunnr IN so_kunnr AND
                  tax_status EQ 'T1'.
        WHEN '8070'.
          SELECT *
            FROM zssutdt005
            INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
            WHERE vkorg EQ pa_vkorg AND
*                vkbur EQ pa_vkbur AND
                  vbeln IN so_vbeln AND
                  vbtyp EQ 'O'      AND
*                  fkdat IN so_fkdat AND
                  bldat IN so_fkdat AND
                  kunnr IN so_kunnr AND
                  tax_status EQ 'T1'.
        WHEN OTHERS.
      ENDCASE.

      LOOP AT t_zsl_hsales.
        IF t_zsl_hsales-vbeln+2(1) EQ '3'.
          SELECT SINGLE vkbur
            FROM knvv
            INTO t_zsl_hsales-vkbur
            WHERE kunnr EQ t_zsl_hsales-kunnr AND
                  vkorg EQ t_zsl_hsales-vkorg.
          MODIFY t_zsl_hsales TRANSPORTING vkbur.
        ELSE.
          DELETE t_zsl_hsales.
        ENDIF.
      ENDLOOP.
    ELSE.
      IF va_live EQ 'X'.
        READ TABLE t_kna1 WITH KEY kunnr = gc_kunnr.
        IF sy-subrc EQ 0.
          PERFORM f_get_billing USING '2'.
        ELSE.
          PERFORM f_get_billing USING '3'.
        ENDIF.

        DELETE ADJACENT DUPLICATES FROM t_data2 COMPARING vbeln.

        LOOP AT t_data2.
          SELECT SINGLE vkbur
            FROM knvv
            INTO t_data2-vkbur
            WHERE kunnr EQ t_data2-kunrg AND
                  vkorg EQ t_data2-vkorg.
          MODIFY t_data2 TRANSPORTING vkbur.

          IF t_data2-fkdat GE va_fkdat.
*          IF t_data-fkart IN ra_fkart.
            IF t_data-auart IN ra_fkart.
              DELETE t_data2.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ELSE.
        CASE pa_vkorg.
          WHEN '8020'.
            SELECT *
              FROM zsl_hsales
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                  vkbur EQ pa_vkbur AND
                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr IN so_kunnr AND
                    tax_status EQ 'T1'.
          WHEN '8070'.
            SELECT *
              FROM zssutdt005
              INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
              WHERE vkorg EQ pa_vkorg AND
*                  vkbur EQ pa_vkbur AND
                    vbeln IN so_vbeln AND
                    vbtyp EQ 'O'      AND
*                    fkdat IN so_fkdat AND
                    bldat IN so_fkdat AND
                    kunnr IN so_kunnr AND
                    tax_status EQ 'T1'.
          WHEN OTHERS.
        ENDCASE.

        LOOP AT t_zsl_hsales.
          IF t_zsl_hsales-vbeln+2(1) EQ '3'.
            SELECT SINGLE vkbur
              FROM knvv
              INTO t_zsl_hsales-vkbur
              WHERE kunnr EQ t_zsl_hsales-kunnr AND
                    vkorg EQ t_zsl_hsales-vkorg.
            MODIFY t_zsl_hsales TRANSPORTING vkbur.
          ELSE.
            DELETE t_zsl_hsales.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

*  lr_zuonr[]  = so_vbeln[].
  LOOP AT so_vbeln.
    MOVE-CORRESPONDING so_vbeln TO lr_zuonr.
    APPEND lr_zuonr. CLEAR lr_zuonr.
  ENDLOOP.

  SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
         a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
         b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
         b~ttlcn b~status b~refnr a~erdt1 a~vatdt1
    FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                             a~bukrs EQ b~bukrs AND
                                             a~kunnr EQ b~kunnr AND
                                             a~monat EQ b~monat AND
                                             a~gjahr EQ b~gjahr AND
                                             a~nonr  EQ b~nonr
    INTO CORRESPONDING FIELDS OF TABLE t_data1
    WHERE a~vrsio IN so_vrsio AND
          a~bukrs EQ pa_vkorg AND
          a~kunnr IN so_kunnr AND
          a~nonr  IN so_nonr  AND
          a~nrdt  IN so_nrdt  AND
          b~zuonr IN lr_zuonr AND
*          b~belnr IN so_vbeln AND
          b~budat IN so_fkdat. "AND
*          b~vkbur EQ pa_vkbur.

  IF t_zsl_hsales[] IS NOT INITIAL.
    SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
           a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
           b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
           b~ttlcn b~status b~refnr a~erdt1 a~vatdt1
      FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                               a~bukrs EQ b~bukrs AND
                                               a~kunnr EQ b~kunnr AND
                                               a~monat EQ b~monat AND
                                               a~gjahr EQ b~gjahr AND
                                               a~nonr  EQ b~nonr
      APPENDING CORRESPONDING FIELDS OF TABLE t_data1
      FOR ALL ENTRIES IN t_zsl_hsales
      WHERE a~vrsio IN so_vrsio AND
            a~bukrs EQ t_zsl_hsales-vkorg AND
            a~kunnr EQ t_zsl_hsales-kunnr AND
            b~belnr EQ t_zsl_hsales-vbeln.
  ENDIF.

  SORT t_data1 BY vrsio bukrs kunnr nonr vkbur belnr zuonr.
  DELETE ADJACENT DUPLICATES FROM t_data1 COMPARING vrsio bukrs kunnr nonr vkbur belnr zuonr.
ENDFORM.                    " f_get_data1

*&---------------------------------------------------------------------*
*&      Form  f_get_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data2.
  RANGES: lr_zuonr  FOR zfppnnrd-zuonr.

  IF so_nonr[] IS INITIAL AND
    so_nrdt[] IS INITIAL.

    READ TABLE t_kna1 WITH KEY kunnr = gc_kunnr.
    IF sy-subrc EQ 0.
      PERFORM f_get_billing USING '2'.
    ELSE.
      PERFORM f_get_billing USING '3'.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM t_data2 COMPARING vbeln.

    LOOP AT t_data2.
      SELECT SINGLE vkbur
        FROM knvv
        INTO t_data2-vkbur
        WHERE kunnr EQ t_data2-kunrg AND
              vkorg EQ t_data2-vkorg.
      MODIFY t_data2 TRANSPORTING vkbur.

      IF t_data2-fkdat GE va_fkdat.
*      IF t_data-fkart IN ra_fkart.
        IF t_data2-auart IN ra_fkart.
          DELETE t_data2.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CASE pa_vkorg.
      WHEN '8020'.
        SELECT *
          FROM zsl_hsales
          INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
          WHERE vkorg EQ pa_vkorg AND
*              vkbur IN so_vkbur AND
                vbeln IN so_vbeln AND
                vbtyp EQ 'O'      AND
*                fkdat IN so_fkdat AND
                bldat IN so_fkdat AND
                kunnr IN so_kunnr AND
                tax_status EQ 'T1'.
      WHEN '8070'.
        SELECT *
          FROM zssutdt005
          INTO CORRESPONDING FIELDS OF TABLE t_zsl_hsales
          WHERE vkorg EQ pa_vkorg AND
*              vkbur IN so_vkbur AND
                vbeln IN so_vbeln AND
                vbtyp EQ 'O'      AND
*                fkdat IN so_fkdat AND
                bldat IN so_fkdat AND
                kunnr IN so_kunnr AND
                tax_status EQ 'T1'.
      WHEN OTHERS.
    ENDCASE.

    LOOP AT t_zsl_hsales.
      IF t_zsl_hsales-vbeln+2(1) EQ '3'.
        SELECT SINGLE vkbur
          FROM knvv
          INTO t_zsl_hsales-vkbur
          WHERE kunnr EQ t_zsl_hsales-kunnr AND
                vkorg EQ t_zsl_hsales-vkorg.
        MODIFY t_zsl_hsales TRANSPORTING vkbur.
      ELSE.
        DELETE t_zsl_hsales.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  lr_zuonr[]  = so_vbeln[].
  LOOP AT so_vbeln.
    MOVE-CORRESPONDING so_vbeln TO lr_zuonr.
    APPEND lr_zuonr. CLEAR lr_zuonr.
  ENDLOOP.

  SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
         a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
         b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
         b~ttlcn b~status b~refnr a~erdt1 a~vatdt1
    FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                             a~bukrs EQ b~bukrs AND
                                             a~kunnr EQ b~kunnr AND
                                             a~monat EQ b~monat AND
                                             a~gjahr EQ b~gjahr AND
                                             a~nonr  EQ b~nonr
    INTO CORRESPONDING FIELDS OF TABLE t_data1
    WHERE a~vrsio IN so_vrsio AND
          a~bukrs EQ pa_vkorg AND
          a~kunnr IN so_kunnr AND
          a~nonr  IN so_nonr  AND
          a~nrdt  IN so_nrdt  AND
          b~zuonr IN lr_zuonr AND
*          b~belnr IN so_vbeln AND
          b~budat IN so_fkdat. "AND
*          b~vkbur IN so_vkbur.

  IF t_zsl_hsales[] IS NOT INITIAL.
    SELECT a~vrsio a~bukrs a~kunnr a~nonr a~nrdt a~dppnr a~ppnnr a~ttlnr
           a~belnrrc a~gjahr a~monat a~stceg a~vatpr1 a~vatpr2 a~vatpr3 a~vatpr4
           b~vkbur b~belnr b~zuonr b~budat b~waers b~dppcn b~ppncn
           b~ttlcn b~status b~refnr a~erdt1 a~vatdt1
      FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~vrsio EQ b~vrsio AND
                                               a~bukrs EQ b~bukrs AND
                                               a~kunnr EQ b~kunnr AND
                                               a~monat EQ b~monat AND
                                               a~gjahr EQ b~gjahr AND
                                               a~nonr  EQ b~nonr
      APPENDING CORRESPONDING FIELDS OF TABLE t_data1
      FOR ALL ENTRIES IN t_zsl_hsales
      WHERE a~vrsio IN so_vrsio AND
            a~bukrs EQ t_zsl_hsales-vkorg AND
            a~kunnr EQ t_zsl_hsales-kunnr AND
            b~belnr EQ t_zsl_hsales-vbeln.
  ENDIF.

  SORT t_data1 BY vrsio bukrs kunnr nonr vkbur belnr zuonr.
  DELETE ADJACENT DUPLICATES FROM t_data1 COMPARING vrsio bukrs kunnr nonr vkbur belnr zuonr.
ENDFORM.                    " f_get_data2

*&---------------------------------------------------------------------*
*&      Module  status_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS 'STATUS_600'.
ENDMODULE.                 " status_0600  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  DATA: ld_mess(100),
        ld_error        TYPE i,
        ld_datumfr_low  TYPE sy-datum,
        ld_datumfr_high TYPE sy-datum,
        ld_datumto_low  TYPE sy-datum.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      CLEAR: ld_error.
      ra_monat-low    = '1'.
      ra_monat-high   = '12'.
      ra_monat-sign   = 'I'.
      ra_monat-option = 'BT'.
      APPEND ra_monat.

      IF bsis-gjahr IS INITIAL OR
        bsis-monat IS INITIAL OR
        bsas-gjahr IS INITIAL OR
        bsas-monat IS INITIAL.
        DELETE FROM zfnrclose WHERE vkorg EQ pa_vkorg AND
                                    vkbur EQ pa_vkbur.
        LEAVE TO SCREEN 0.
      ELSE.
        CONCATENATE bsis-gjahr bsis-monat '01' INTO ld_datumfr_low.
        CONCATENATE bsas-gjahr bsas-monat '01' INTO ld_datumto_low.

        IF ld_datumfr_low GT ld_datumto_low.
          ld_error = 1.
          MESSAGE i000(zab) WITH 'Error on period ranges'.
        ELSE.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = ld_datumfr_low
            IMPORTING
              last_day_of_month = ld_datumfr_high.

*        ld_datumfr_high = ld_datumfr_high + 1.
*
*        IF ld_datumto_low GT ld_datumfr_high.
*          ld_error = 1.
*          MESSAGE i000(zab) WITH 'Error on period ranges'.
*        ENDIF.
        ENDIF.

        IF ld_error IS INITIAL.
          IF bsis-monat IN ra_monat.
          ELSE.
            ld_error = 1.
            CONCATENATE 'Instead of 01.13.2007, please enter a valid'
                        'value for the decision'
              INTO ld_mess
              SEPARATED BY space.
            MESSAGE i000(zab) WITH ld_mess.
          ENDIF.
          IF bsas-monat IN ra_monat.
          ELSE.
            ld_error = 1.
            CONCATENATE 'Instead of 01.13.2007, please enter a valid'
                        'value for the decision'
              INTO ld_mess
              SEPARATED BY space.
            MESSAGE i000(zab) WITH ld_mess.
          ENDIF.
        ENDIF.

        IF ld_error IS INITIAL.
          IF va_subrc EQ 0.
            UPDATE zfnrclose SET monat   = bsis-monat
                                 gjahr   = bsis-gjahr
                                 monatto = bsas-monat
                                 gjahrto = bsas-gjahr
                                 usna1   = sy-uname
                                 erdt1   = sy-datum
                                 erzet   = sy-uzeit
            WHERE vkorg EQ pa_vkorg AND
                  vkbur EQ pa_vkbur.
          ELSE.
            zfnrclose-vkorg   = pa_vkorg.
            zfnrclose-vkbur   = pa_vkbur.
            zfnrclose-monat   = bsis-monat.
            zfnrclose-gjahr   = bsis-gjahr.
            zfnrclose-monatto = bsas-monat.
            zfnrclose-gjahrto = bsas-gjahr.
            zfnrclose-usna1   = sy-uname.
            zfnrclose-erdt1   = sy-datum.
            zfnrclose-erzet   = sy-uzeit.
            INSERT zfnrclose.
          ENDIF.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " user_command_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  modify  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify OUTPUT.
  IF va_count IS INITIAL.
    LOOP AT t_close WHERE vkorg EQ pa_vkorg AND
                          vkbur EQ pa_vkbur.
      bsis-gjahr = t_close-gjahr.
      bsis-monat = t_close-monat.
      bsas-gjahr = t_close-gjahrto.
      bsas-monat = t_close-monatto.
      va_count = 1.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " modify  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  f_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_document.
  DATA: ld_mess(200),
        ld_error     TYPE i,
        ld_flag      TYPE i,
        ld_belnr     LIKE bsis-belnr,
        ld_xref3     LIKE bsis-xref3.

  CLEAR: va_proc, ld_flag.
  d_bdc_tctxt = 'Executing Transaction FB02'.
  d_bdc_batch = 'N'.

  CLEAR: t_bdcdata, t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN radio1.
        READ TABLE t_bsis WITH KEY zuonr = t_out1-vbeln.
        IF t_bsis-xref3(2) EQ 'XX'.
          CLEAR: ld_error.
          ld_belnr = t_bsis-belnr.
          CONCATENATE 'T1' va_gform pa_monat
          INTO ld_xref3 SEPARATED BY '|'.
        ELSE.
          IF t_bsis-xref3(2) EQ space OR
* Revise by budi 08/02/2006
             t_bsis-xref3(2) EQ 'T0' OR
             t_bsis-xref3(2) EQ 'T1'.
* End revise by budi 08/02/2006
            ld_flag = 1.
          ELSE.
            ld_error = 1.
          ENDIF.
        ENDIF.

      WHEN radio2.
        READ TABLE t_bsis WITH KEY zuonr = t_out2-belnr.
        IF t_bsis-xref3(2) NE 'XX'.
          CLEAR: ld_error.
          ld_belnr = t_bsis-belnr.
          CONCATENATE 'XX' pa_monat pa_gjahr
          INTO ld_xref3 SEPARATED BY '|'.
        ELSE.
          IF t_bsis-xref3(2) EQ space.
            ld_flag = 2.
          ELSE.
            ld_error = 1.
          ENDIF.
        ENDIF.
    ENDCASE.

    IF ld_error IS INITIAL.
      IF ld_flag = 1.
        COLLECT t_zfppnnrh.
        COLLECT t_zfppnnrd.
      ELSEIF ld_flag = 2.
      ELSEIF ld_flag IS INITIAL.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05L'      '0100',
          ' ' 'BDC_OKCODE'    '/00',
          ' ' 'RF05L-BELNR'    ld_belnr,
          ' ' 'RF05L-BUKRS'    pa_vkorg,
          ' ' 'RF05L-GJAHR'    pa_gjahr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05L'      '0700',
          ' ' 'BDC_CURSOR'    'RF05L-ANZDT(01)',
          ' ' 'BDC_OKCODE'    '=PK'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05L'      '0300',
          ' ' 'BDC_OKCODE'    '=ZK',
          ' ' 'DKACB-FMORE'   'X'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'      '0002',
          ' ' 'BDC_OKCODE'    '=ENTE'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05L'      '1300',
          ' ' 'BDC_OKCODE'    '=ENTE',
          ' ' 'BSEG-XREF3'    ld_xref3.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05L'      '0300',
          ' ' 'BDC_OKCODE'    '=AE',
          ' ' 'DKACB-FMORE'   'X'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'      '0002',
          ' ' 'BDC_OKCODE'    '=ENTE'.

        PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                                t_bdcmsg
                                         USING 'FB02' d_bdc_tctxt.

        PERFORM f_get_message USING t_bdcmsg
                              CHANGING ld_mess.

*-----Update message for the status report
        IF d_bdc_error = 0.
          IF radio1 EQ 'X'.
            COLLECT t_zfppnnrh.
            COLLECT t_zfppnnrd.
          ENDIF.
        ELSE.
          IF radio2 EQ 'X'.
            va_error = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_change_document

*&---------------------------------------------------------------------*
*&      Form f_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_dynpro USING dynbegin name value.
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  f_summary
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary.
  DATA: lt_ttlnr(13),
        lt_ppnnr(13),
        lt_dppnr(13).

  CLEAR: ttlnr, ppnnr, dppnr.
  LOOP AT t_out1 WHERE check EQ 'X'.
    ADD t_out1-netwr TO ttlnr.
    ADD t_out1-vatcn TO ppnnr.
    ADD t_out1-amtcn TO dppnr.
    va_retval = 1.
  ENDLOOP.
  WRITE ttlnr TO lt_ttlnr CURRENCY 'IDR'.
  WRITE ppnnr TO lt_ppnnr CURRENCY 'IDR'.
  WRITE dppnr TO lt_dppnr CURRENCY 'IDR'.
  DO 3 TIMES.
    REPLACE '.' WITH space INTO lt_ttlnr.
    REPLACE '.' WITH space INTO lt_ppnnr.
    REPLACE '.' WITH space INTO lt_dppnr.
  ENDDO.
  CONDENSE lt_ttlnr NO-GAPS.
  CONDENSE lt_ppnnr NO-GAPS.
  CONDENSE lt_dppnr NO-GAPS.
  ttlnr = lt_ttlnr.
  ppnnr = lt_ppnnr.
  dppnr = lt_dppnr.
ENDFORM.                    " f_summary

*&---------------------------------------------------------------------*
*&      Form  f_view_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_view_detail.
  DATA: ld_hrgsat LIKE vbrp-kzwi1,
        ld_count  TYPE i.

  DATA: ld_tdname LIKE stxh-tdname,
        ld_tdid   LIKE stxh-tdid.

  DATA: BEGIN OF lt_lines OCCURS 0.
          INCLUDE STRUCTURE tline.
        DATA: END OF lt_lines.

  REFRESH: t_out6.
  CLEAR: t_out6.
  LOOP AT t_out1 WHERE check EQ 'X'.
    t_out1-nonr = nonr.
    MODIFY t_out1 TRANSPORTING nonr.

* Get No. CN for printing
    CONCATENATE wa_header-nocn t_out1-vbeln INTO wa_header-nocn
      SEPARATED BY ','.
    SHIFT wa_header-nocn LEFT DELETING LEADING ','.

* Get text for 'ATAS FAKTUR PAJAK NO.'
    ld_tdname   = t_out1-aubel.
    CLEAR: ld_count.
    DO 4 TIMES.
      ADD 1 TO ld_count.
      CASE ld_count.
        WHEN 1.
          ld_tdid  = 'Z008'.
        WHEN 2.
          ld_tdid  = 'Z009'.
        WHEN 3.
          ld_tdid  = 'Z010'.
        WHEN 4.
          ld_tdid  = 'Z011'.
      ENDCASE.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = ld_tdid
          language                = sy-langu
          name                    = ld_tdname
          object                  = 'VBBK'
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
      IF sy-subrc <> 0.
        CONTINUE.
      ELSE.
        READ TABLE lt_lines INDEX 1.
        IF sy-subrc EQ 0.
          t_faktur-faktur = lt_lines-tdline.
          COLLECT t_faktur.
        ENDIF.
      ENDIF.
    ENDDO.

    IF t_detail[] IS NOT INITIAL.
      SORT t_detail BY matnr.
      SORT t_mara BY matnr.
      LOOP AT t_detail WHERE vbeln EQ t_out1-vbeln.
        t_out6-nonr   = nonr.
        t_out6-matnr  = t_detail-matnr.
        t_out6-arktx  = t_detail-arktx.

        READ TABLE t_mara WITH KEY matnr = t_detail-matnr.
        IF t_mara-meins <> t_detail-vrkme.
          t_out6-vrkme  = t_mara-meins.
          PERFORM f_unit_conversion USING t_detail-matnr t_detail-fkimg
                                          t_mara-meins t_detail-vrkme
                                    CHANGING t_out6-fkimg.
        ELSE.
          t_out6-vrkme  = t_detail-vrkme.
          t_out6-fkimg  = t_detail-fkimg.
        ENDIF.

        t_out6-kzwi1  = t_detail-kzwi1.
        t_out6-kzwi5  = t_detail-kzwi5.

        t_out6-skfbp  = t_detail-kzwi1 - t_detail-kzwi5.
        t_out6-netwr  = t_detail-netwr.
        t_out6-waerk  = t_detail-waerk.
        t_out6-hrgsat = 0.
        ON CHANGE OF t_detail-matnr.
          t_out6-hrgsat = t_detail-kzwi1 / t_detail-fkimg.
        ENDON.
*        READ TABLE t_mara WITH KEY matnr = t_detail-matnr BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          t_out6-arktx  = t_mara-maktx.
*          t_out6-vrkme  = t_mara-meins.
*        ENDIF.
        COLLECT t_out6.
      ENDLOOP.
    ENDIF.

    IF t_zsl_hsales[] IS NOT INITIAL.
      SORT t_zsl_dsales BY matnr.
      SORT t_mara BY matnr.
      LOOP AT t_zsl_hsales WHERE vbeln EQ t_out1-vbeln.
        t_out6-nonr   = nonr.
        t_out6-waerk  = t_zsl_hsales-curr.
        LOOP AT t_zsl_dsales WHERE vbeln EQ t_out1-vbeln.
          t_out6-matnr  = t_zsl_dsales-matnr.
          t_out6-fkimg  = t_zsl_dsales-fkimg.
          t_out6-kzwi1  = t_zsl_dsales-nsp.
          t_out6-skfbp  = t_zsl_dsales-disa + t_zsl_dsales-disb + t_zsl_dsales-disc + t_zsl_dsales-disd +
                          t_zsl_dsales-disdc + t_zsl_dsales-dise + t_zsl_dsales-disf + t_zsl_dsales-dissp +
                          t_zsl_dsales-disvol + t_zsl_dsales-cod.
          READ TABLE t_mara WITH KEY matnr = t_zsl_dsales-matnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_out6-arktx  = t_mara-maktx.
            t_out6-vrkme  = t_mara-meins.
          ENDIF.
          COLLECT t_out6.
        ENDLOOP.
      ENDLOOP.
      LOOP AT t_out6.
        t_out6-hrgsat = t_out6-kzwi1  / t_out6-fkimg.
        t_out6-kzwi5  = t_out6-kzwi1 - t_out6-skfbp.
        MODIFY t_out6 TRANSPORTING hrgsat kzwi5.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_view_detail

*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form USING fu_ucomm.
  DATA: ld_count  TYPE i,
        ld_cabang LIKE va_cabang,
        lv_mastx  TYPE abper_rf,
        lv_kzwi5  TYPE p DECIMALS 0.

  DATA : lt_xout6 TYPE STANDARD TABLE OF zfstnrd,
         ls_xout6 LIKE LINE OF lt_xout6.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  SELECT SINGLE bezei INTO ld_cabang FROM tvkbt WHERE spras = sy-langu AND
*                                                      vkbur = pa_vkbur.
  va_nmpem             = p_nmpem.
  va_japem             = p_japem.
  wa_header-name1      = name_co.
  va_cabang            = p_city.
  CONCATENATE street city
  INTO wa_header-address
  SEPARATED BY space.
  wa_header-nonr       = nonr.
  wa_header-nrdt       = nrdt.

  lt_xout6[] = t_out6[].
  DELETE lt_xout6 WHERE kzwi5 = 0
                    AND netwr = 0.

  READ TABLE lt_xout6 INTO ls_xout6 INDEX 1.
  IF sy-subrc = 0.
    TRY .
        lv_kzwi5 = ( ls_xout6-kzwi5 - ls_xout6-netwr ) / ls_xout6-netwr * 100.
      CATCH cx_sy_zerodivide.
    ENDTRY.
  ENDIF.

  CASE lv_kzwi5.
    WHEN 10.
      wa_header-ppn = '10'.
    WHEN 11.
      wa_header-ppn = '11'.
  ENDCASE.

  SORT t_alamat BY bukrs brnch masafrom DESCENDING.
  LOOP AT t_alamat WHERE bukrs = pa_vkorg AND
                         brnch = pa_vkorg AND
                         masafrom LE wa_header-nrdt.
    wa_header-pkpname = t_alamat-pkpname.
    wa_header-pkpaddrs1 = t_alamat-pkpaddrs1.
    wa_header-pkpaddrs2 = t_alamat-pkpaddrs2.
    wa_header-pkppostal = t_alamat-pkppostal.
    wa_header-pkpcity = t_alamat-pkpcity.
    wa_header-pkpnpwp = t_alamat-pkpnpwp.
    wa_header-pkpkuh = t_alamat-pkpkuh.
    EXIT.
  ENDLOOP.

  IF pa_fakt1 IS NOT INITIAL OR
    pa_fakt2 IS NOT INITIAL OR
    pa_fakt3 IS NOT INITIAL OR
    pa_fakt4 IS NOT INITIAL.
    wa_header-faktur1  = pa_fakt1.
    wa_header-faktur2  = pa_fakt2.
    wa_header-faktur3  = pa_fakt3.
    wa_header-faktur4  = pa_fakt4.
  ELSE.
    LOOP AT t_faktur.
      ADD 1 TO ld_count.
      IF ld_count LE 4.
        CASE ld_count.
          WHEN 1.
            wa_header-faktur1 = t_faktur-faktur.
            TRANSLATE wa_header-faktur1 TO UPPER CASE.
          WHEN 2.
            wa_header-faktur2 = t_faktur-faktur.
            TRANSLATE wa_header-faktur2 TO UPPER CASE.
          WHEN 3.
            wa_header-faktur3 = t_faktur-faktur.
            TRANSLATE wa_header-faktur3 TO UPPER CASE.
          WHEN 4.
            wa_header-faktur4 = t_faktur-faktur.
            TRANSLATE wa_header-faktur4 TO UPPER CASE.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM f_hitung_subtotal.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    SELECT SINGLE padest
      FROM tsp03l
      INTO va_spld
      WHERE lname = p_dest.

    d_output_opt-tddest     = va_spld.
    IF fu_ucomm EQ '&PRE'.
      d_output_opt-tdnoprev   = space.
      d_output_opt-tdnoprint  = 'X'.
    ELSEIF fu_ucomm EQ '&PRNT'.
      d_output_opt-tdnoprev   = 'X'.
      d_output_opt-tdnoprint  = space.
      d_ctrl_param-preview    = space.
    ENDIF.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters   = d_ctrl_param
        output_options       = d_output_opt
        user_settings        = space
        wa_header            = wa_header
        va_reprint           = va_reprint
        va_nmpem             = va_nmpem
        va_japem             = va_japem
        va_cabang            = va_cabang
      IMPORTING
        document_output_info = document_output_info
        job_output_info      = job_output_info
        job_output_options   = job_output_options
      TABLES
        t_subtotal           = t_subtotal
        t_out6               = t_out6.

    IF job_output_info-spoolids IS NOT INITIAL.
      PERFORM f_isi_table.

      IF NOT t_zfppnnrh[] IS INITIAL.
        va_commit = 1.
        PERFORM f_commit_work ON COMMIT.
      ENDIF.

      IF sy-subrc EQ 0.
        IF va_error EQ 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
        CASE 'X'.
          WHEN radio1.
            PERFORM f_table_unlocking.
            IF va_error EQ 0.
              MESSAGE s000(zab)
              WITH 'Records was CREATED successfully'.
            ELSE.
              MESSAGE e000(zab) WITH 'Customer tidak ada N.P.W.P'.
            ENDIF.
            LEAVE TO SCREEN 0.
        ENDCASE.
      ELSE.
        MESSAGE e000(zab) WITH 'Processing error'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_print_form

*&---------------------------------------------------------------------*
*&      Form  f_reprint_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reprint_form .
  DATA: ld_cabang LIKE va_cabang,
        lv_kzwi5  TYPE p DECIMALS 0.

  DATA : lt_xout6 TYPE STANDARD TABLE OF zfstnrd,
         ls_xout6 LIKE LINE OF lt_xout6.

*  SELECT SINGLE bezei INTO ld_cabang FROM tvkbt WHERE spras = sy-langu AND
*                                                      vkbur = pa_vkbur.

*  p_dest    = p_dest1.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  PERFORM f_hitung_subtotal.
  va_reprint = 'X'.

  SELECT SINGLE padest
    FROM tsp03l
    INTO va_spld
    WHERE lname = p_dest1.

  d_output_opt-tddest    = va_spld.

  IF d_frm_subrc IS INITIAL.
    LOOP AT t_header INTO wa_header.
      READ TABLE t_zfppnnrh WITH KEY bukrs = pa_vkorg
                                     kunnr = pa_kunnr
                                     nonr  = wa_header-nonr.

      IF sy-subrc EQ 0.
        va_nmpem  = t_zfppnnrh-nmpem.
        va_japem  = t_zfppnnrh-japem.
        va_cabang = t_zfppnnrh-city.
      ENDIF.

      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      d_output_opt-tddest   = va_spld.

      lt_xout6[] = t_out6[].
      DELETE lt_xout6 WHERE kzwi5 = 0
                        AND netwr = 0.

      READ TABLE lt_xout6 INTO ls_xout6 INDEX 1.
      IF sy-subrc = 0.
        TRY .
            lv_kzwi5 = ( ls_xout6-kzwi5 - ls_xout6-netwr ) / ls_xout6-netwr * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.
      ENDIF.

      CASE lv_kzwi5.
        WHEN 10.
          wa_header-ppn = '10'.
        WHEN 11.
          wa_header-ppn = '11'.
      ENDCASE.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          wa_header          = wa_header
          va_reprint         = va_reprint
          va_nmpem           = va_nmpem
          va_japem           = va_japem
          va_cabang          = va_cabang
        TABLES
          t_subtotal         = t_subtotal
          t_out6             = t_out6.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_reprint_form

*&---------------------------------------------------------------------*
*&      Form  f_data_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_data_modify.
  DATA: ld_ttlnr    LIKE zfppnnrh-ttlnr,
        ld_ttlcn    LIKE zfppnnrh-ttlcn,
        ld_dppcn    LIKE zfppnnrh-dppcn,
        ld_ppncn    LIKE zfppnnrh-ppncn,
        ld_addttl   LIKE zfppnnrd-ttlcn,
        ld_adddpp   LIKE zfppnnrd-dppcn,
        ld_addppn   LIKE zfppnnrd-ppncn,
        ld_lines    TYPE i,
        lt_zfppnnrd LIKE t_zfppnnrd,
        ld_count    TYPE i.

  CLEAR: ld_ttlnr, ld_ttlcn.
  SORT t_zfppnnrh BY nonr.
  SORT t_zfppnnrd BY nonr.
  SORT t_out6 BY nonr.
  LOOP AT t_out6.
    IF sy-tabix = 1.
*      t_zfppnnrdtl-arktx = t_out6-arktx.   "Pindah ke bawah
*      t_zfppnnrdtl-vrkme = t_out6-vrkme.   "Pindah ke bawah
      t_zfppnnrdtl-waerk = t_out6-waerk.
    ENDIF.
    t_zfppnnrdtl-bukrs = pa_vkorg.
    t_zfppnnrdtl-vkbur = pa_vkbur.
    t_zfppnnrdtl-kunnr = pa_kunnr.
    t_zfppnnrdtl-gjahr = pa_gjahr.
    t_zfppnnrdtl-nonr  = t_out6-nonr.
    t_zfppnnrdtl-matnr = t_out6-matnr.
    t_zfppnnrdtl-arktx = t_out6-arktx.
    t_zfppnnrdtl-vrkme = t_out6-vrkme.
    t_zfppnnrdtl-nrdt  = nrdt.
    t_zfppnnrdtl-fkimg = t_out6-fkimg.
    t_zfppnnrdtl-kzwi1 = t_out6-kzwi1.
    IF wa_zfnrcncust IS INITIAL.
      t_zfppnnrdtl-kzwi5 = t_out6-kzwi5.

      "      PERFORM f_tax_calc USING '' t_zfppnnrdtl-kzwi5 'C'
      "                         CHANGING t_zfppnnrdtl-dppnr.
      t_zfppnnrdtl-dppnr = t_out6-netwr.
*      t_zfppnnrdtl-dppnr = t_zfppnnrdtl-kzwi5 * 10 / 11.
      t_zfppnnrdtl-ppnnr = t_zfppnnrdtl-kzwi5 - t_zfppnnrdtl-dppnr.
      t_zfppnnrdtl-skfbp = t_out6-skfbp.
    ELSE.
      t_zfppnnrdtl-kzwi5 = ttlnr / 100.
      t_zfppnnrdtl-dppnr = dppnr / 100.
      t_zfppnnrdtl-ppnnr = ppnnr / 100.
      t_zfppnnrdtl-skfbp = t_out6-skfbp.
    ENDIF.
    COLLECT t_zfppnnrdtl.
  ENDLOOP.

  IF wa_zfnrcncust IS INITIAL.
    LOOP AT t_zfppnnrh.
      LOOP AT t_out6 WHERE nonr EQ t_zfppnnrh-nonr.
        ADD t_out6-kzwi5 TO ld_ttlnr.
        ADD t_out6-kzwi5 TO ld_ttlcn.
        ADD t_out6-netwr TO ld_dppcn.
      ENDLOOP.
      t_zfppnnrh-ttlnr = ld_ttlnr.
*      PERFORM f_tax_calc USING '' ld_ttlnr 'C'
*                         CHANGING t_zfppnnrh-dppnr.

*      t_zfppnnrh-dppnr = ld_ttlnr * 10 / 11.
      t_zfppnnrh-dppnr = ld_dppcn.
      t_zfppnnrh-ppnnr = ld_ttlnr - ld_dppcn.
      t_zfppnnrh-ttlcn = ld_ttlcn.
*      PERFORM f_tax_calc USING '' ld_ttlcn 'C'
*                         CHANGING t_zfppnnrh-dppcn.
      t_zfppnnrh-dppcn = ld_dppcn.
      t_zfppnnrh-ppncn = ld_ttlcn - t_zfppnnrh-dppnr.
      MODIFY t_zfppnnrh TRANSPORTING ttlnr dppnr ppnnr ttlcn dppcn ppncn.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE t_zfppnnrd LINES ld_lines.
  ld_ttlcn = t_zfppnnrh-ttlnr / ld_lines.
  ld_dppcn = t_zfppnnrh-dppcn / ld_lines.
  ld_ppncn = t_zfppnnrh-ppncn / ld_lines.

  LOOP AT t_zfppnnrd.
    lt_zfppnnrd = t_zfppnnrd.
    t_zfppnnrd-ttlcn = ld_ttlcn.
    t_zfppnnrd-dppcn = ld_dppcn.
    t_zfppnnrd-ppncn = ld_ppncn.

    AT LAST.
      ld_count = 1.
      t_zfppnnrd = lt_zfppnnrd.
      t_zfppnnrd-ttlcn = t_zfppnnrh-ttlcn - ld_addttl.
      t_zfppnnrd-dppcn = t_zfppnnrh-dppcn - ld_adddpp.
      t_zfppnnrd-ppncn = t_zfppnnrh-ppncn - ld_addppn.
      MODIFY t_zfppnnrd TRANSPORTING ttlcn dppcn ppncn.
    ENDAT.

    IF ld_count IS INITIAL.
      ADD ld_ttlcn TO ld_addttl.
      ADD ld_dppcn TO ld_adddpp.
      ADD ld_ppncn TO ld_addppn.
      MODIFY t_zfppnnrd TRANSPORTING ttlcn dppcn ppncn.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_data_modify

*&---------------------------------------------------------------------*
*&      Form  f_hitung_subtotal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_subtotal .
  DATA: ld_count TYPE i.
  LOOP AT t_out6.
    ADD 1 TO ld_count.
    t_subtotal-nonr = t_out6-nonr.
    ADD t_out6-kzwi1 TO t_subtotal-kzwi1.
    IF ld_count EQ 17.
      ADD 1 TO t_subtotal-zpage.
      COLLECT t_subtotal.
      CLEAR: ld_count.
    ENDIF.
    AT END OF nonr.
      CLEAR: ld_count, t_subtotal-zpage, t_subtotal-kzwi1.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " f_hitung_subtotal

*&---------------------------------------------------------------------*
*&      Form  f_output_validate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_validate USING fu_valid
                       CHANGING fc_error.

  DATA: ld_kzwi1    LIKE t_out6-kzwi1,
        ld_kzwi5    LIKE t_out6-kzwi5,
        ld_kzwi1min LIKE t_out6-kzwi1,
        ld_kzwi1max LIKE t_out6-kzwi1,
        ld_error    TYPE i.

  CLEAR: ld_kzwi1min, ld_kzwi1max.

  CASE fu_valid.
    WHEN 'VAL'.
      CLEAR: fc_error.
      IF va_valcust EQ 0.
        LOOP AT t_out6.
          ld_kzwi1min  = t_out6-kzwi5 - t_zfnrrange-range_min.
          ld_kzwi1max  = t_out6-kzwi5 + t_zfnrrange-range_max.

          ra_ranges-low    = ld_kzwi1min.
          ra_ranges-high   = ld_kzwi1max.
          ra_ranges-sign   = 'I'.
          ra_ranges-option = 'BT'.
          APPEND ra_ranges.

          t_out6-kzwi1 = t_out6-fkimg * t_out6-hrgsat.
          t_out6-kzwi5 = t_out6-kzwi1 - t_out6-skfbp.
          IF t_out6-kzwi5 IN ra_ranges.
            MODIFY t_out6 TRANSPORTING kzwi1 skfbp kzwi5.
          ELSE.
            fc_error = 2.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF fc_error NE 0.
        va_valid = 0.
      ENDIF.

    WHEN 'PRE'.
      IF va_valcust EQ 0.
        LOOP AT t_out6.
          ld_kzwi1 = t_out6-fkimg * t_out6-hrgsat.
          ld_kzwi5 = t_out6-kzwi1 - t_out6-skfbp.

          IF t_out6-kzwi1 NE ld_kzwi1.
            fc_error = 1.
          ENDIF.
          IF t_out6-kzwi5 NE ld_kzwi5.
            fc_error = 1.
          ENDIF.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_output_validate

*&---------------------------------------------------------------------*
*&      Form  f_validate_radio6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_radio6 .
  DATA: ld_datum_low  LIKE sy-datum,
        ld_datum_high LIKE sy-datum,
        ld_error      TYPE i,
        ld_return     LIKE bapireturn1.

  DATA: BEGIN OF lt_delete OCCURS 0.
          INCLUDE STRUCTURE zfnrclose.
        DATA: END OF lt_delete.
  DATA: BEGIN OF lt_close OCCURS 0.
          INCLUDE STRUCTURE zfnrclose.
        DATA: END OF lt_close.

  SELECT *
    FROM zfnrclose
    INTO CORRESPONDING FIELDS OF TABLE lt_close.

  SORT t_close BY vkorg vkbur.
  SORT lt_close BY vkorg vkbur.

  LOOP AT lt_close.
    READ TABLE t_close WITH KEY vkorg    = lt_close-vkorg
                                vkbur    = lt_close-vkbur
                                monat    = lt_close-monat
                                gjahr    = lt_close-gjahr
                                monatto  = lt_close-monatto
                                gjahrto  = lt_close-gjahrto.
    IF sy-subrc NE 0.
      lt_close-usna1  = sy-uname.
      lt_close-erdt1  = sy-datum.
      lt_close-erzet  = sy-uzeit.
    ENDIF.

    IF lt_close-vkbur IS NOT INITIAL.
      CALL FUNCTION 'BAPI_SALESORG_OFFICE_EXIST'
        EXPORTING
          salesorganization = lt_close-vkorg
          salesoffice       = lt_close-vkbur
        IMPORTING
          return            = ld_return.
      IF ld_return IS NOT INITIAL.
        ld_error = 1.
        lt_delete = lt_close.
        APPEND lt_delete.
        DELETE lt_close.
      ENDIF.
    ENDIF.

    IF ld_error IS INITIAL.
      CONCATENATE lt_close-gjahr lt_close-monat '01' INTO ld_datum_low.
      CONCATENATE lt_close-gjahrto lt_close-monatto '01' INTO ld_datum_high.
      IF ld_datum_high LT ld_datum_low.
        ld_error = 1.
        lt_delete = lt_close.
        APPEND lt_delete.
        DELETE lt_close.
      ENDIF.
    ENDIF.

    IF ld_error IS INITIAL.
      MODIFY lt_close TRANSPORTING usna1 erdt1 erzet.
    ENDIF.
    CLEAR: ld_error, lt_close.
  ENDLOOP.

  IF lt_delete[] IS NOT INITIAL.
    DELETE zfnrclose FROM TABLE lt_delete.
  ENDIF.

  MODIFY zfnrclose FROM TABLE lt_close.
ENDFORM.                    " f_validate_radio6

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_502
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_502 .
  DATA: ld_count  TYPE i.

  IF pa_fakt1 IS INITIAL AND
    pa_fakt2 IS INITIAL AND
    pa_fakt3 IS INITIAL AND
    pa_fakt4 IS INITIAL.
    LOOP AT t_faktur WHERE nonr EQ t_zfppnnrd-nonr.
      ADD 1 TO ld_count.
      CASE ld_count.
        WHEN 1.
          pa_fakt1 = t_faktur-faktur.
          TRANSLATE pa_fakt1 TO UPPER CASE.

        WHEN 2.
          pa_fakt2 = t_faktur-faktur.
          TRANSLATE pa_fakt2 TO UPPER CASE.

        WHEN 3.
          pa_fakt3 = t_faktur-faktur.
          TRANSLATE pa_fakt3 TO UPPER CASE.

        WHEN 4.
          pa_fakt4 = t_faktur-faktur.
          TRANSLATE pa_fakt4 TO UPPER CASE.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF pa_fakt1 IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK1'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF pa_fakt2 IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK2'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK2'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF pa_fakt3 IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK3'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK3'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF pa_fakt4 IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK4'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'FK4'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_modify_screen_502

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_LEGACY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_filter_legacy .
  LOOP AT t_zsl_hsales.
    IF t_zsl_hsales-vbeln+2(1) NE '3'.
      DELETE t_zsl_hsales.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FILTER_LEGACY

*&---------------------------------------------------------------------*
*&      Module  STATUS_0503  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0503 OUTPUT.
  SET PF-STATUS '503'.
ENDMODULE.                 " STATUS_0503  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0503  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0503 INPUT.
  DATA: ld_zdesc LIKE zfnrstatus-zdesc,
        ld_zflag LIKE zfnrstatus-zflag,
        ld_refnr TYPE i.

  CASE sy-ucomm.
    WHEN '&PRC'.
      READ TABLE t_zfnrstatus WITH KEY status = zfppnnrd-status.
      IF sy-subrc EQ 0.
        ld_zdesc  = t_zfnrstatus-zdesc.
        va_zdesc  = ld_zdesc.
        ld_zflag  = t_zfnrstatus-zflag.
      ELSE.
        CLEAR: ld_zdesc, ld_zflag.
      ENDIF.

*      IF ld_zflag IS NOT INITIAL.
*        IF va_refnr IS INITIAL.
*          CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*            EXPORTING
*              popup_title  = 'Error Message'
*              is_error     = 'X'
*              message_text = 'Reference NR harus diisi'.
*        ELSE.
      PERFORM f_modify_data USING '' ld_zdesc.
      CLEAR: zfppnnrd-status, va_refnr.
      SET PF-STATUS '100'.
      PERFORM f_alv TABLES t_radio11.
      LEAVE TO SCREEN 0.
*        ENDIF.
*      ELSE.
*        IF va_refnr IS NOT INITIAL.
*          CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*            EXPORTING
*              popup_title  = 'Warning Message'
*              is_error     = space
*              message_text = 'Reference NR tidak harus diisi'.
*        ENDIF.
*        PERFORM f_modify_data USING '1' ld_zdesc.
*        CLEAR: zfppnnrd-status, va_refnr.
*        SET PF-STATUS '100'.
*        PERFORM f_alv TABLES t_radio11.
*        LEAVE TO SCREEN 0.
*      ENDIF.

    WHEN space.
      READ TABLE t_zfnrstatus WITH KEY status = zfppnnrd-status.
      IF sy-subrc EQ 0.
        va_zdesc          = t_zfnrstatus-zdesc.
        t_radio11-status  = zfppnnrd-status.
        t_radio11-refnr   = va_refnr.
      ENDIF.

    WHEN 'CANC'.
      SET PF-STATUS '100'.
      PERFORM f_alv TABLES t_radio11.
      LEAVE TO SCREEN 0.

    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0503  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_503  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_503 OUTPUT.
  DATA: ld_lenght TYPE i.
  DATA: ls_radio11 LIKE LINE OF t_radio11.

  va_nonr          = t_radio11-nonr.
  va_zuonr         = t_radio11-zuonr.
  va_kunnr         = t_radio11-kunnr.
  va_monat         = t_radio11-monat.
  va_gjahr         = t_radio11-gjahr.
  va_belnr         = t_radio11-belnr.
  zfppnnrd-status  = t_radio11-status.
  va_refnr         = t_radio11-refnr.
  IF strlen( va_kunnr ) LE 9.
    CONCATENATE '0' va_kunnr INTO va_kunnr.
  ENDIF.

  CLEAR ls_radio11.
  READ TABLE t_radio11 INTO ls_radio11 WITH KEY monat = t_radio11-monat
                                                gjahr = t_radio11-gjahr
                                                kunnr = va_kunnr
                                                nonr  = t_radio11-nonr
                                                zuonr = t_radio11-zuonr
                                                belnr = t_radio11-belnr
                                                status = t_radio11-status.
  IF sy-subrc = 0.
    va_refnr = ls_radio11-refnr.
  ENDIF.
ENDMODULE.                 " MODIFY_503  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_data USING fu_flag fu_zdesc.
  READ TABLE t_radio11 WITH KEY monat  = va_monat
                                gjahr  = va_gjahr
                                kunnr  = va_kunnr
                                nonr   = va_nonr
                                zuonr  = va_zuonr
                                belnr  = va_belnr.
  IF sy-subrc EQ 0.
    t_radio11-status  = zfppnnrd-status.
    t_radio11-zdesc   = fu_zdesc.
    IF fu_flag IS INITIAL.
      t_radio11-refnr  = va_refnr.
    ELSE.
      CLEAR: t_radio11-refnr.
    ENDIF.
    MODIFY t_radio11 INDEX sy-tabix TRANSPORTING status zdesc refnr.
  ENDIF.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_status .
  LOOP AT t_radio11.
    UPDATE zfppnnrd SET status   = t_radio11-status
                        refnr    = t_radio11-refnr
                        zstsdt   = sy-datum
                        zstsusr  = sy-uname
    WHERE vrsio  EQ t_radio11-vrsio  AND
          monat  EQ t_radio11-monat  AND
          gjahr  EQ t_radio11-gjahr  AND
          kunnr  EQ t_radio11-kunnr  AND
          nonr   EQ t_radio11-nonr   AND
          belnr  EQ t_radio11-belnr  AND
          zuonr  EQ t_radio11-zuonr.
  ENDLOOP.
  MESSAGE s000(zab) WITH 'Data already updated'.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_SAVE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_GUI_UPLOAD_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILENAME  text
*----------------------------------------------------------------------*
FORM f_gui_upload_excel  USING    fu_filename.
  DATA: v_flag_mater(1) TYPE c,
        ld_error(1),
        ld_vkbur(4),
        ld_budat(10),
        ld_value(50).
  DATA: lt_zfnrcustm  LIKE zfnrcustm OCCURS 0 WITH HEADER LINE.

  SELECT vkorg vkbur kunnr
    FROM zfnrcustm
    INTO CORRESPONDING FIELDS OF TABLE lt_zfnrcustm
    WHERE vkorg EQ pa_vkorg  AND
          vkbur EQ pa_vkbur.

  REFRESH t_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = fu_filename
      i_begin_col             = 3
      i_begin_row             = 3
      i_end_col               = 24
      i_end_row               = 60000
    TABLES
      intern                  = t_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  SORT t_excel BY row col value.
  CLEAR: t_vdata, t_excel.
  v_flag_mater = 'N'.

  LOOP AT t_excel.
    ON CHANGE OF t_excel-row.
      IF v_flag_mater = 'Y'.
        PERFORM f_fields_modify USING 11 ld_budat
                                CHANGING t_vdata-belnrrc.
        PERFORM f_validasi_data TABLES lt_zfnrcustm
                                USING 11
                                CHANGING ld_error.
        IF ld_error IS INITIAL.
          t_vdata-icon  = icon_led_green.
        ELSE.
          t_vdata-icon   = icon_led_red.
          t_vdata-error  = ld_error.
        ENDIF.
        APPEND t_vdata.
        CLEAR: t_vdata, ld_error.
      ENDIF.
      v_flag_mater = 'Y'.
    ENDON.

    v_flag_mater = 'Y'.
    IF t_excel-col = '0001'.
      MOVE t_excel-value TO t_vdata-bukrs.
    ENDIF.
    IF t_excel-col = '0002'.
      MOVE t_excel-value TO t_vdata-vkbur.
      PERFORM f_fields_modify USING 2 ''
                              CHANGING t_vdata-vkbur.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 2
                              CHANGING ld_error.
    ENDIF.
    IF t_excel-col = '0003'.
      MOVE t_excel-value TO t_vdata-kunnr.
      PERFORM f_fields_modify USING 3 ''
                              CHANGING t_vdata-kunnr.
    ENDIF.
    IF t_excel-col = '0004'.
      MOVE t_excel-value TO t_vdata-name1.
    ENDIF.
    IF t_excel-col = '0005'.
      MOVE t_excel-value TO t_vdata-name_co.
    ENDIF.
    IF t_excel-col = '0006'.
      MOVE t_excel-value TO t_vdata-stceg.
    ENDIF.
    IF t_excel-col = '0007'.
      MOVE t_excel-value TO t_vdata-nppkp.
    ENDIF.
*    IF t_excel-col = '0008'.
*    ENDIF.
    IF t_excel-col = '0009'.
      MOVE t_excel-value TO t_vdata-monat.
    ENDIF.
    IF t_excel-col = '0010'.
      MOVE t_excel-value TO t_vdata-gjahr.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 10
                              CHANGING ld_error.
    ENDIF.
*    IF t_excel-col = '0011'.
*      MOVE t_excel-value TO t_vdata-belnrrc.
*    ENDIF.
    IF t_excel-col = '0012'.
      MOVE t_excel-value TO t_vdata-zuonr.
    ENDIF.
    IF t_excel-col = '0013'.
      MOVE t_excel-value TO ld_budat.
      PERFORM f_fields_modify USING 13 ld_budat
                              CHANGING t_vdata-budat.
    ENDIF.
    IF t_excel-col = '0014'.
      MOVE t_excel-value TO ld_value.
      PERFORM f_fields_modify USING 14 ld_value
                              CHANGING t_vdata-ppncn.
    ENDIF.
    IF t_excel-col = '0015'.
      MOVE t_excel-value TO ld_value.
      PERFORM f_fields_modify USING 14 ld_value
                              CHANGING t_vdata-ppnnr.
    ENDIF.
    IF t_excel-col = '0016'.
      MOVE t_excel-value TO t_vdata-nonr.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 16
                              CHANGING ld_error.
    ENDIF.
    IF t_excel-col = '0017'.
      MOVE t_excel-value TO ld_budat.
      PERFORM f_fields_modify USING 13 ld_budat
                              CHANGING t_vdata-nrdt.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 17
                              CHANGING ld_error.
    ENDIF.
*    IF t_excel-col = '0018'.
*    ENDIF.
*    IF t_excel-col = '0019'.
*    ENDIF.
    IF t_excel-col = '0020'.
      MOVE t_excel-value TO t_vdata-status.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 20
                              CHANGING ld_error.
    ENDIF.
    IF t_excel-col = '0021'.
      MOVE t_excel-value TO t_vdata-refnr.
      PERFORM f_validasi_data TABLES lt_zfnrcustm
                              USING 21
                              CHANGING ld_error.
    ENDIF.
    CLEAR t_excel.
  ENDLOOP.

  PERFORM f_fields_modify USING 11 ld_budat
                          CHANGING t_vdata-belnrrc.
  PERFORM f_validasi_data TABLES lt_zfnrcustm
                          USING 11
                          CHANGING ld_error.
  IF v_flag_mater = 'Y'.
    IF ld_error IS INITIAL.
      t_vdata-icon  = icon_led_green.
    ELSE.
      t_vdata-icon  = icon_led_red.
      t_vdata-error = ld_error.
    ENDIF.
    APPEND t_vdata.
    CLEAR: t_vdata, ld_error.
  ENDIF.
ENDFORM.                    " F_GUI_UPLOAD_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validasi_data TABLES ft_zfnrcustm STRUCTURE zfnrcustm
                     USING fu_flag
                     CHANGING fc_error.
  DATA: ld_period(6),
        ld_period1(6).

  IF fc_error IS INITIAL.
    CASE fu_flag.
      WHEN 2.
        IF t_vdata-vkbur NE pa_vkbur.
          fc_error  = 1.
        ENDIF.

      WHEN 10.
        CONCATENATE pa_gjahr pa_monat INTO ld_period.
        CONCATENATE t_vdata-gjahr t_vdata-monat INTO ld_period1.
        IF ld_period1 NE ld_period.
          fc_error  = 2.
        ENDIF.

      WHEN 11.
        IF t_vdata-belnrrc IS INITIAL.
          fc_error  = 7.
        ENDIF.

      WHEN 16.
        IF t_vdata-nonr IS INITIAL.
          fc_error  = 5.
        ENDIF.

      WHEN 17.
        IF t_vdata-nrdt IS INITIAL.
          fc_error  = 6.
        ENDIF.

      WHEN 20.
        READ TABLE t_zfnrstatus WITH KEY status  = t_vdata-status.
        IF sy-subrc NE 0.
          fc_error  = 3.
        ENDIF.

      WHEN 21.
        READ TABLE t_zfnrstatus WITH KEY status  = t_vdata-status.
        IF sy-subrc EQ 0.
          IF t_zfnrstatus-zflag EQ 'X'.
            IF t_vdata-refnr IS INITIAL.
              fc_error  = 4.
            ENDIF.
          ELSE.
            IF t_vdata-refnr IS NOT INITIAL.
              fc_error  = 4.
            ENDIF.
          ENDIF.
        ELSE.
          fc_error  = 4.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELDS_MODIFY
*&---------------------------------------------------------------------*
FORM f_fields_modify  USING fu_flag fu_field
                      CHANGING fc_field.
  DATA: ld_length  TYPE i.
  CASE fu_flag.
    WHEN 2.
      ld_length = strlen( fc_field ).
      IF ld_length EQ 3.
        CONCATENATE '0' fc_field INTO fc_field.
      ENDIF.
    WHEN 3.
      ld_length = strlen( fc_field ).
      IF ld_length EQ 9.
        CONCATENATE '0' fc_field INTO fc_field.
      ENDIF.
    WHEN 11.
      CASE pa_vkorg.
        WHEN '8020'.
          SELECT SINGLE account_no INTO fc_field
            FROM zsl_hsales WHERE vbeln = t_vdata-zuonr AND
                                  vkbur = pa_vkbur      AND
                                  vkorg = pa_vkorg      AND
                                  fkdat = t_vdata-budat AND
                                  vbtyp = 'O'.
        WHEN '8070'.
          SELECT SINGLE account_no INTO fc_field
            FROM zssutdt005 WHERE vbeln = t_vdata-zuonr AND
                                  vkbur = pa_vkbur      AND
                                  vkorg = pa_vkorg      AND
                                  fkdat = t_vdata-budat AND
                                  vbtyp = 'O'.
        WHEN OTHERS.
      ENDCASE.
      IF sy-subrc NE 0.
        SELECT SINGLE belnr INTO fc_field
          FROM bsid WHERE kunnr = t_vdata-kunnr AND
                          bukrs = pa_vkorg      AND
                          gjahr = t_vdata-budat(4) AND
                          zuonr = t_vdata-zuonr AND
                          budat = t_vdata-budat AND
                          blart = 'RV'.
        IF sy-subrc NE 0.
          SELECT SINGLE belnr INTO fc_field
            FROM bsad WHERE bukrs = pa_vkorg      AND
                            kunnr = t_vdata-kunnr AND
                            zuonr = t_vdata-zuonr AND
                            budat = t_vdata-budat AND
                            blart = 'RV'.
        ENDIF.
      ENDIF.
    WHEN 13.
      CONCATENATE fu_field+6(4) fu_field+3(2) fu_field(2) INTO fc_field.
    WHEN 14.
      DO 4 TIMES.
        REPLACE '.' WITH space INTO fu_field.
      ENDDO.
      CONDENSE fu_field NO-GAPS.
      fc_field  = fu_field / 100.
  ENDCASE.
ENDFORM.                    " F_FIELDS_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_data .
  DATA: ld_vrsio     LIKE zfppnnrh-vrsio,
        ld_vrsio1(3) TYPE n.

  IF t_zfppnnrh[] IS NOT INITIAL.
    MODIFY zfppnnrh FROM TABLE t_zfppnnrh.
    IF sy-subrc = 0.
      MODIFY zfppnnrd FROM TABLE t_zfppnnrd.
      IF sy-subrc = 0.
        MODIFY zfppnnrdtl FROM TABLE t_zfppnnrdtl.
        IF sy-subrc = 0.
          SELECT MAX( vrsio ) INTO ld_vrsio
            FROM zfppnnrh.
          IF ld_vrsio IS INITIAL.
            pa_vrsio = '001'.
          ELSE.
            ld_vrsio1 = ld_vrsio.
            ADD 1 TO ld_vrsio1.
            pa_vrsio = ld_vrsio1.
          ENDIF.
          MESSAGE 'Update Table Sukses' TYPE 'S'.
*          LEAVE TO SCREEN 0.
          LEAVE PROGRAM.
        ELSE.
          MESSAGE 'Update Table Gagal' TYPE 'S'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*  LOOP AT t_zfppnnrh.
*    UPDATE zfppnnrh FROM t_zfppnnrh.
*  ENDLOOP.

*  INSERT zfppnnrh FROM TABLE t_zfppnnrh.
*  INSERT zfppnnrd FROM TABLE t_zfppnnrd.
*  INSERT zfppnnrdtl FROM TABLE t_zfppnnrdtl.
ENDFORM.                    " F_UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_NR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_nr .
  DATA: BEGIN OF lt_detail OCCURS 0,
          vkorg LIKE vbrk-vkorg,
          vkbur LIKE vbrp-vkbur,
          vbeln LIKE vbrp-vbeln,
          posnr LIKE vbrp-posnr,
          kunrg LIKE vbrk-kunrg,
          waerk LIKE vbrk-waerk,
          matnr LIKE vbrp-matnr,
          arktx LIKE vbrp-arktx,
          aubel LIKE vbrp-aubel,
          kzwi1 LIKE vbrp-kzwi1,
          kzwi5 LIKE vbrp-kzwi5,
          fkimg LIKE vbrp-fkimg,
          vrkme LIKE vbrp-vrkme.
  DATA: END OF lt_detail.

  DATA: lt_vdata    LIKE t_vdata OCCURS 0 WITH HEADER LINE,
        lt_zfppnnrh LIKE zfppnnrh OCCURS 0 WITH HEADER LINE,
        lt_zfppnnrd LIKE zfppnnrd OCCURS 0 WITH HEADER LINE.

  lt_vdata[]  = t_vdata[].
  IF lt_vdata[] IS NOT INITIAL.
    SELECT bukrs vkbur belnr zuonr kunnr monat gjahr nonr budat
      FROM zfppnnrd
      INTO CORRESPONDING FIELDS OF TABLE lt_zfppnnrd
      FOR ALL ENTRIES IN lt_vdata
      WHERE bukrs EQ lt_vdata-bukrs  AND
            vkbur EQ lt_vdata-vkbur  AND
            zuonr EQ lt_vdata-zuonr  AND
            kunnr EQ lt_vdata-kunnr  AND
            monat EQ lt_vdata-monat  AND
            gjahr EQ lt_vdata-gjahr.

    SELECT bukrs kunnr monat gjahr nonr
      FROM zfppnnrh
      INTO CORRESPONDING FIELDS OF TABLE lt_zfppnnrh
      FOR ALL ENTRIES IN lt_vdata
      WHERE bukrs EQ lt_vdata-bukrs  AND
            kunnr EQ lt_vdata-kunnr  AND
            monat EQ lt_vdata-monat  AND
            gjahr EQ lt_vdata-gjahr.
  ENDIF.

* Validasi Ref. NR
  LOOP AT t_vdata.
    READ TABLE t_zfnrstatus WITH KEY status  = t_vdata-status.
    IF sy-subrc EQ 0.
      IF t_zfnrstatus-zflag EQ 'X'.
        IF t_vdata-refnr IS INITIAL.
          t_vdata-icon = '@5C@'.
          t_vdata-error = '4'.
          MODIFY t_vdata TRANSPORTING icon error.
        ENDIF.
      ELSE.
        IF t_vdata-refnr IS NOT INITIAL.
          t_vdata-icon = '@5C@'.
          t_vdata-error = '4'.
          MODIFY t_vdata TRANSPORTING icon error.
        ENDIF.
      ENDIF.
    ELSE.
      t_vdata-icon = '@5C@'.
      t_vdata-error = '4'.
      MODIFY t_vdata TRANSPORTING icon error.
    ENDIF.

    IF t_vdata-monat IS INITIAL OR t_vdata-gjahr IS INITIAL OR
       t_vdata-nonr IS INITIAL OR t_vdata-nrdt IS INITIAL OR
       t_vdata-status IS INITIAL.
      t_vdata-icon = '@5C@'.
      t_vdata-error = '5'.
      MODIFY t_vdata TRANSPORTING icon error.
    ENDIF.
  ENDLOOP.

  LOOP AT t_vdata.
    IF t_vdata-icon EQ '@5B@'.
      t_zfppnnrh-vrsio  = pa_vrsio.
      t_zfppnnrh-bukrs  = t_vdata-bukrs.
      t_zfppnnrh-kunnr  = t_vdata-kunnr.
      t_zfppnnrh-monat  = t_vdata-monat.
      t_zfppnnrh-gjahr  = t_vdata-gjahr.
      t_zfppnnrh-nonr   = t_vdata-nonr.
      t_zfppnnrh-nrdt   = t_vdata-nrdt.
      t_zfppnnrh-name1  = t_vdata-name1.
      t_zfppnnrh-stceg  = t_vdata-stceg.
      t_zfppnnrh-waers  = 'IDR'.
      t_zfppnnrh-dppnr  = t_vdata-ppnnr * 10.
      t_zfppnnrh-ppnnr  = t_vdata-ppnnr.
      t_zfppnnrh-ttlnr  = t_zfppnnrh-dppnr + t_zfppnnrh-ppnnr.
      t_zfppnnrh-dppcn  = t_vdata-ppnnr * 10.
      t_zfppnnrh-ppncn  = t_vdata-ppnnr.
      t_zfppnnrh-ttlcn  = t_zfppnnrh-dppnr + t_zfppnnrh-ppnnr.
      t_zfppnnrh-usna1  = sy-uname.
      t_zfppnnrh-erdt1  = sy-datum.
      t_zfppnnrh-erzet  = sy-uzeit.
      COLLECT t_zfppnnrh.

      t_zfppnnrd-vrsio  = pa_vrsio.
      t_zfppnnrd-bukrs  = t_vdata-bukrs.
      t_zfppnnrd-vkbur  = t_vdata-vkbur.
*      t_zfppnnrd-belnr  = t_vdata-zuonr.
      t_zfppnnrd-belnr  = t_vdata-belnrrc.
      t_zfppnnrd-zuonr  = t_vdata-zuonr.
      t_zfppnnrd-kunnr  = t_vdata-kunnr.
      t_zfppnnrd-monat  = t_vdata-monat.
      t_zfppnnrd-gjahr  = t_vdata-gjahr.
      t_zfppnnrd-nonr   = t_vdata-nonr.
      t_zfppnnrd-budat  = t_vdata-budat.
      t_zfppnnrd-nrdt   = t_vdata-nrdt.
      t_zfppnnrd-waers  = 'IDR'.
      t_zfppnnrd-dppcn  = t_vdata-ppnnr * 10.
      t_zfppnnrd-ppncn  = t_vdata-ppnnr.
      t_zfppnnrd-ttlcn  = t_zfppnnrd-dppcn + t_zfppnnrd-ppncn.
      t_zfppnnrd-usna1  = sy-uname.
      t_zfppnnrd-erdt1  = sy-datum.
      t_zfppnnrd-erzet  = sy-uzeit.
      t_zfppnnrd-status  = t_vdata-status.
      t_zfppnnrd-refnr  = t_vdata-refnr.
      t_zfppnnrd-ttlnr  = t_zfppnnrd-ttlcn.
      t_zfppnnrd-dppnr  = t_zfppnnrd-dppcn.
      t_zfppnnrd-ppnnr  = t_zfppnnrd-ppncn.
      COLLECT t_zfppnnrd.
    ELSE.
      t_error3-zuonr  = t_vdata-zuonr.
      CASE t_vdata-error.
        WHEN '1'.
          t_error3-msg    = 'Sales office error'.
        WHEN '2'.
          t_error3-msg    = 'Period error'.
        WHEN '3'.
          t_error3-msg    = 'Status NR error'.
        WHEN '4'.
          t_error3-msg    = 'Ref. NR error'.
        WHEN '5' OR '6'.
          t_error3-msg    = 'Period / NR No / NR Dt / Status = Blank'.
        WHEN '7'.
          t_error3-msg    = 'Document No. tidak ada'.
      ENDCASE.
      APPEND t_error3.
    ENDIF.
  ENDLOOP.

  IF t_zfppnnrd[] IS NOT INITIAL.
    SELECT a~vbeln a~waerk a~vkorg a~kunrg
           b~vkbur b~posnr b~matnr b~arktx
           b~vrkme b~fkimg b~kzwi1 b~kzwi5
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE lt_detail
      FOR ALL ENTRIES IN t_zfppnnrd
      WHERE a~vbeln EQ t_zfppnnrd-belnr  AND
            a~vkorg EQ pa_vkorg          AND
            a~vbtyp IN ('O', '6')        AND
            a~kunrg EQ t_zfppnnrd-kunnr  AND
            a~fksto EQ space             AND
            a~ktgrd NE '00'.

    LOOP AT lt_detail.
      t_zfppnnrdtl-bukrs = lt_detail-vkorg.
      t_zfppnnrdtl-vkbur = lt_detail-vkbur.
      t_zfppnnrdtl-kunnr = lt_detail-kunrg.
      t_zfppnnrdtl-waerk = lt_detail-waerk.
      t_zfppnnrdtl-kzwi1 = lt_detail-kzwi1.
      t_zfppnnrdtl-kzwi5 = lt_detail-kzwi5.
      t_zfppnnrdtl-skfbp = lt_detail-kzwi1 - lt_detail-kzwi5.

*    PERFORM f_tax_calc USING '' lt_detail-kzwi5 'C'
*                       CHANGING t_zfppnnrdtl-dppnr.

      t_zfppnnrdtl-dppnr = lt_detail-kzwi5 * 10 / 11.
      t_zfppnnrdtl-ppnnr = lt_detail-kzwi5 - t_zfppnnrdtl-dppnr.
      t_zfppnnrdtl-matnr = lt_detail-matnr.
      t_zfppnnrdtl-arktx = lt_detail-arktx.
      t_zfppnnrdtl-fkimg = lt_detail-fkimg.
      t_zfppnnrdtl-vrkme = lt_detail-vrkme.

      READ TABLE t_zfppnnrd WITH KEY belnr = lt_detail-vbeln
                                     kunnr = lt_detail-kunrg.
      IF sy-subrc EQ 0.
        t_zfppnnrdtl-gjahr = t_zfppnnrd-gjahr.
        t_zfppnnrdtl-nonr  = t_zfppnnrd-nonr.
        t_zfppnnrdtl-nrdt  = t_zfppnnrd-nrdt.
        COLLECT t_zfppnnrdtl.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_NR

*&---------------------------------------------------------------------*
*&      Form  F_VATNO_LISTBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_vatno_listbox .
  DATA: ld_date(10).

  CLEAR: t_vatno,vrmls.
  REFRESH: t_vatno,vrmls.

  SELECT zuonr dudat vatpr INTO TABLE t_vatno
    FROM zfvato
    WHERE vkorg = pa_vkorg AND
          vkbur = pa_vkbur AND
          kunrg = pa_kunnr.

  LOOP AT t_vatno.
    WRITE t_vatno-dudat TO ld_date.
    value-key =  t_vatno-vatpr.
    CONCATENATE t_vatno-vatpr ld_date t_vatno-zuonr INTO value-text
        SEPARATED BY '  |  '.
    APPEND value TO vrmls.
  ENDLOOP.
*  WRITE sy-datum TO ld_date.
*  value-key =  '01234567890123456789'.
*  CONCATENATE '01234567890123456789' ld_date so_vbeln-low INTO value-text
*        SEPARATED BY '  |  '.
*  APPEND value TO vrmls.
*  value-key =  '01234567890123456799'.
*  CONCATENATE '01234567890123456799' ld_date so_vbeln-low INTO value-text
*        SEPARATED BY '  |  '.
*  APPEND value TO vrmls.

  vrmnm = 'VATNO'.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = vrmnm
      values = vrmls.
ENDFORM.                    " F_VATNO_LISTBOX

*&---------------------------------------------------------------------*
*&      Form  F_GET_VAT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_AUBEL  text
*      <--FC_VATPR1  text
*      <--FC_VATPR2  text
*      <--FC_VATPR3  text
*      <--FC_VATPR4  text
*----------------------------------------------------------------------*
FORM f_get_vat_number  USING    fu_aubel
                       CHANGING fc_vatpr1
                                fc_vatpr2
                                fc_vatpr3
                                fc_vatpr4
                                fc_vatdt1.
  DATA: ld_count  TYPE i,
        ld_tdname LIKE stxh-tdname,
        ld_tdid   LIKE stxh-tdid.

  DATA: BEGIN OF lt_lines OCCURS 0.
          INCLUDE STRUCTURE tline.
        DATA: END OF lt_lines.

  ld_tdname = fu_aubel.

  CLEAR: ld_count.
  DO 5 TIMES.
    ADD 1 TO ld_count.

    CASE ld_count.
      WHEN 1.
        ld_tdid  = 'Z008'.
      WHEN 2.
        ld_tdid  = 'Z009'.
      WHEN 3.
        ld_tdid  = 'Z010'.
      WHEN 4.
        ld_tdid  = 'Z011'.
      WHEN 5.
        ld_tdid  = 'Z002'.
    ENDCASE.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = ld_tdid
        language                = sy-langu
        name                    = ld_tdname
        object                  = 'VBBK'
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
    IF sy-subrc <> 0.
      CONTINUE.
    ELSE.
      READ TABLE lt_lines INDEX 1.
      IF sy-subrc EQ 0.
        CASE ld_count.
          WHEN 1.
            fc_vatpr1 = lt_lines-tdline.
          WHEN 2.
            fc_vatpr2 = lt_lines-tdline.
          WHEN 3.
            fc_vatpr3 = lt_lines-tdline.
          WHEN 4.
            fc_vatpr4 = lt_lines-tdline.
          WHEN 5.
            CONCATENATE lt_lines-tdline+6(4) lt_lines-tdline+3(2) lt_lines-tdline(2)
            INTO fc_vatdt1.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDDO.
ENDFORM.                    " F_GET_VAT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING
*&---------------------------------------------------------------------*
FORM f_get_billing USING fu_flag.
  DATA : lt_mapp  TYPE STANDARD TABLE OF zsmapping_augru INITIAL SIZE 0,
         ls_mapp  LIKE LINE OF lt_mapp,
         lr_augru TYPE RANGE OF augru,
         ls_augru LIKE LINE OF lr_augru.

  DATA : lt_vbak TYPE STANDARD TABLE OF vbak INITIAL SIZE 0,
         lt_ekko TYPE STANDARD TABLE OF ekko INITIAL SIZE 0.

  SELECT *
    FROM zsmapping_augru
    INTO CORRESPONDING FIELDS OF TABLE lt_mapp
    WHERE augru_rpt = 'R04'.
  LOOP AT lt_mapp INTO ls_mapp.
    ls_augru-low    = ls_mapp-augru.
    ls_augru-sign   = 'I'.
    ls_augru-option = 'EQ'.
    APPEND ls_augru TO lr_augru.
    CLEAR ls_augru.
  ENDLOOP.

  CASE fu_flag.
    WHEN '0'.
      SELECT a~vbeln a~waerk a~vkorg a~fkdat a~kunrg
             a~stceg a~mwsbk a~fkart a~ktgrd a~cityc
             b~vkbur b~posnr b~matnr b~arktx b~netwr
             b~vrkme b~fkimg b~kzwi1 b~kzwi5 b~aubel
             b~augru_auft
        FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
        INTO CORRESPONDING FIELDS OF TABLE t_detail
        WHERE a~vbeln IN so_vbeln
          AND a~fkdat IN so_fkdat
          AND a~vkorg EQ pa_vkorg
          AND a~vbtyp IN ('O', '6')
          AND a~kunrg EQ pa_kunnr
          AND a~fksto EQ space
          AND a~ktgrd NE '00'
          AND a~cityc NE 'T3'
          AND a~fkart IN ('ZR01', 'ZR02').

    WHEN '1'.
      SELECT a~vbeln a~waerk a~vkorg a~fkdat a~kunrg
             a~stceg a~mwsbk a~fkart a~ktgrd a~cityc
             b~vkbur b~posnr b~matnr b~arktx b~netwr
             b~vrkme b~fkimg b~kzwi1 b~kzwi5 b~aubel
             b~augru_auft "c~auart
        FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
*                       JOIN vbak AS c ON c~vbeln EQ b~aubel
        INTO CORRESPONDING FIELDS OF TABLE t_detail
        WHERE a~vbeln IN so_vbeln
          AND a~fkdat IN so_fkdat
          AND a~vkorg EQ pa_vkorg
          AND a~vbtyp IN ('O', '6')
          AND a~kunrg EQ pa_kunnr
          AND a~fksto EQ space
          AND a~ktgrd NE '00'
          AND a~cityc NE 'T3'.

      IF t_detail[] IS NOT INITIAL.
        PERFORM f_cek_poso  TABLES lt_vbak lt_ekko
                            USING fu_flag.
      ENDIF.

    WHEN '2'.
      SELECT a~vbeln a~vbeln a~waerk a~vkorg a~fkdat a~netwr a~kunrg
             a~stceg a~mwsbk a~fkart a~ktgrd a~cityc
             b~vkbur b~augru_auft b~aubel
        FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
        INTO CORRESPONDING FIELDS OF TABLE t_data2
        WHERE a~vbeln IN so_vbeln
          AND a~fkdat IN so_fkdat
          AND a~vkorg EQ pa_vkorg
          AND a~vbtyp IN ('O', '6')
          AND a~kunrg EQ gc_kunnr
          AND a~fksto EQ space
          AND a~ktgrd NE '00'
          AND a~cityc NE 'T3'
          AND a~fkart IN ('ZR01', 'ZR02').

      SELECT a~vbeln a~vbeln a~waerk a~vkorg a~fkdat a~netwr a~kunrg
             a~stceg a~mwsbk a~fkart a~ktgrd a~cityc
             b~vkbur b~augru_auft b~aubel "c~auart
        FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
*                       JOIN vbak AS c ON c~vbeln EQ b~aubel
        APPENDING CORRESPONDING FIELDS OF TABLE t_data2
        WHERE a~vbeln IN so_vbeln
          AND a~fkdat IN so_fkdat
          AND a~vkorg EQ pa_vkorg
          AND a~vbtyp IN ('O', '6')
          AND a~kunrg IN so_kunnr
          AND a~fksto EQ space
          AND a~ktgrd NE '00'
          AND a~cityc NE 'T3'.

      IF t_data2[] IS NOT INITIAL.
        PERFORM f_cek_poso  TABLES lt_vbak lt_ekko
                            USING fu_flag.
      ENDIF.

    WHEN '3'.
      SELECT a~vbeln a~vbeln a~waerk a~vkorg a~fkdat a~netwr a~kunrg
             a~stceg a~mwsbk a~fkart a~ktgrd a~cityc
             b~vkbur b~augru_auft b~aubel "c~auart
        FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
*                       JOIN vbak AS c ON c~vbeln EQ b~aubel
        INTO CORRESPONDING FIELDS OF TABLE t_data2
        WHERE a~vbeln IN so_vbeln
          AND a~fkdat IN so_fkdat
          AND a~vkorg EQ pa_vkorg
          AND a~vbtyp IN ('O', '6')
          AND a~kunrg IN so_kunnr
          AND a~fksto EQ space
          AND a~ktgrd NE '00'
          AND a~cityc NE 'T3'.

      IF t_data2[] IS NOT INITIAL.
        PERFORM f_cek_poso  TABLES lt_vbak lt_ekko
                            USING fu_flag.
      ENDIF.
  ENDCASE.

  IF t_detail[] IS NOT INITIAL.
    LOOP AT t_detail.
      IF t_detail-augru_auft IN lr_augru.
        DELETE t_detail.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF t_data2[] IS NOT INITIAL.
    LOOP AT t_data2.
      IF t_data2-augru_auft IN lr_augru.
        DELETE t_data2.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_matnr fu_value fu_meins fu_vrkme
                        CHANGING fc_value.

  CLEAR fc_value.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_value
      matnr                = fu_matnr
      meinh                = fu_vrkme
      meins                = fu_meins
    IMPORTING
      output               = fc_value
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

  IF sy-subrc <> 0.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_CEK_POSO
*&---------------------------------------------------------------------*
FORM f_cek_poso  TABLES   ft_vbak STRUCTURE vbak
                          ft_ekko STRUCTURE ekko
                 USING    fu_flag.

  DATA : ls_ekko LIKE LINE OF ft_ekko,
         ls_vbak LIKE LINE OF ft_vbak.

  CASE fu_flag.
    WHEN '1'.
      SELECT *
        FROM vbak
        INTO CORRESPONDING FIELDS OF TABLE ft_vbak
        FOR ALL ENTRIES IN t_detail
        WHERE vbeln = t_detail-aubel.

      SELECT *
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE ft_ekko
        FOR ALL ENTRIES IN t_detail
        WHERE ebeln = t_detail-aubel.

      LOOP AT t_detail.
        IF t_detail-fkart = 'ZR02'.
          READ TABLE ft_ekko INTO ls_ekko WITH KEY ebeln = t_detail-aubel.
          IF sy-subrc <> 0.
            DELETE t_detail.
          ENDIF.
        ELSE.
          READ TABLE ft_vbak INTO ls_vbak WITH KEY vbeln = t_detail-aubel.
          IF sy-subrc <> 0.
            DELETE t_detail.
          ELSE.
            t_detail-auart  = ls_vbak-auart.
            MODIFY t_detail TRANSPORTING auart.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN '2' OR '3'.
      SELECT *
        FROM vbak
        INTO CORRESPONDING FIELDS OF TABLE ft_vbak
        FOR ALL ENTRIES IN t_data2
        WHERE vbeln = t_data2-aubel.

      SELECT *
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE ft_ekko
        FOR ALL ENTRIES IN t_data2
        WHERE ebeln = t_data2-aubel.

      LOOP AT t_data2.
        IF t_data2-fkart = 'ZR02'.
          READ TABLE ft_ekko INTO ls_ekko WITH KEY ebeln = t_data2-aubel.
          IF sy-subrc <> 0.
            DELETE t_data2.
          ENDIF.
        ELSE.
          READ TABLE ft_vbak INTO ls_vbak WITH KEY vbeln = t_data2-aubel.
          IF sy-subrc <> 0.
            DELETE t_data2.
          ELSE.
            t_data2-auart  = ls_vbak-auart.
            MODIFY t_data2 TRANSPORTING auart.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CEK_POSO

*&---------------------------------------------------------------------*
*&      Form  F_EXTENDED_NAME
*&---------------------------------------------------------------------*
FORM f_extended_name USING fu_kunnr.
  DATA : lv_name  TYPE thead-tdname,
         lines    TYPE STANDARD TABLE OF tline,
         ls_lines LIKE LINE OF lines.

  lv_name   = fu_kunnr.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0017'
      language                = sy-langu
      name                    = lv_name
      object                  = 'KNA1'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    READ TABLE lines INTO ls_lines INDEX 1.
    CASE 'X'.
      WHEN radio4.
        t_out4-extend = ls_lines-tdline.
        MODIFY t_out4 TRANSPORTING extend.
      WHEN radio10.
        t_zfppnnrh_d-extend = ls_lines-tdline.
        MODIFY t_zfppnnrh_d TRANSPORTING extend.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_EXTENDED_NAME

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_EXCEL
*&---------------------------------------------------------------------*
FORM f_upload_excel  TABLES   ft_zfstppnnr STRUCTURE zfstppnnr
                     USING    fu_filename.
  CALL METHOD zcl_util=>m_upload_excel_to_itab_new
    EXPORTING
      pvi_table = 'ZFSTPPNNR'
      pvi_bcol  = 1
      pvi_ecol  = 9
      pvi_brow  = 2
      pvi_erow  = 60000
      pv_filenm = fu_filename
    IMPORTING
      pto_data  = ft_zfstppnnr[].

  DELETE ft_zfstppnnr WHERE bukrs NE pa_vkorg.

  IF ft_zfstppnnr[] IS INITIAL.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  LOOP AT ft_zfstppnnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ft_zfstppnnr-kunnr
      IMPORTING
        output = ft_zfstppnnr-kunnr.
    MODIFY ft_zfstppnnr TRANSPORTING kunnr.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group1 fu_active fu_input.
  IF fu_group1 IS NOT INITIAL.
    IF fu_active IS NOT INITIAL.
      IF screen-group1 = fu_group1.
        screen-active  = fu_active.
      ENDIF.
    ENDIF.

    IF fu_input IS NOT INITIAL.
      IF screen-group1 = fu_group1.
        screen-input  = fu_input.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_get_data_download .
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.

  SET PROPERTY OF h_excel 'Visible' = 1.

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  CALL METHOD OF h_mapl 'Add' = h_map.

  PERFORM fill_cell USING 1 1 1 'Company Code'.
  PERFORM fill_cell USING 1 2 1 'Sales Office'.
  PERFORM fill_cell USING 1 3 1 'Customer'.
  PERFORM fill_cell USING 1 4 1 'Period'.
  PERFORM fill_cell USING 1 5 1 'Year'.
  PERFORM fill_cell USING 1 6 1 'No CN'.
  PERFORM fill_cell USING 1 7 1 'Tanggal CN'.
  PERFORM fill_cell USING 1 8 1 'No NR'.
  PERFORM fill_cell USING 1 9 1 'Tanggal NR'.
  PERFORM fill_cell USING 1 10 1 'DPP NR'.
  PERFORM fill_cell USING 1 11 1 'PPN NR'.
  PERFORM fill_cell USING 1 12 1 'Total NR'.

*****  PERFORM fill_cell USING 1 8 1 'DPP CN'.
*****  PERFORM fill_cell USING 1 9 1 'PPN CN'.
*****  PERFORM fill_cell USING 1 10 1 'Total CN'.
*****  PERFORM fill_cell USING 1 16 1 'Referensi FP'.
*****  PERFORM fill_cell USING 1 17 1 'Referensi Tanggal FP'.

  FREE OBJECT h_excel.
ENDFORM.                    " F_GET_DATA_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  FILL_CELL
*&---------------------------------------------------------------------*
FORM fill_cell  USING    i j bold val.
  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = i #2 = j.
  SET PROPERTY OF h_zl 'Value' = val .
  GET PROPERTY OF h_zl 'Font' = h_f.
  SET PROPERTY OF h_f 'Bold' = bold.
ENDFORM.                    " FILL_CELL

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_UPLOAD
*&---------------------------------------------------------------------*
FORM f_get_data_upload .
  DATA: ls_data     LIKE LINE OF gt_data,
        ls_bapiret2 LIKE LINE OF gt_bapiret2.

  CLEAR: gt_excel, gt_excel[].
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT gt_excel BY row col.

  LOOP AT gt_excel.
    CASE gt_excel-col.
      WHEN '0001'.
        ls_data-bukrs = gt_excel-value.
      WHEN '0002'.
        ls_data-vkbur = gt_excel-value.
      WHEN '0003'.
        PERFORM f_convert_data USING 'ALPHA' '' gt_excel-value
                               CHANGING ls_data-kunnr.
      WHEN '0004'.
        ls_data-monat = gt_excel-value.
      WHEN '0005'.
        PERFORM f_convert_data USING 'GJAHR' '' gt_excel-value
                               CHANGING ls_data-gjahr.
      WHEN '0006'.
        ls_data-zuonr = gt_excel-value.
      WHEN '0007'.
        PERFORM f_convert_data USING '' 'D' gt_excel-value
                               CHANGING ls_data-budat.
      WHEN '0008'.
        ls_data-nonr = gt_excel-value.
      WHEN '0009'.
        PERFORM f_convert_data USING '' 'D' gt_excel-value
                               CHANGING ls_data-nrdt.
      WHEN '0010'.
        PERFORM f_convert_data USING '' 'C' gt_excel-value
                               CHANGING ls_data-dppnr.
      WHEN '0011'.
        PERFORM f_convert_data USING '' 'C' gt_excel-value
                               CHANGING ls_data-ppnnr.
      WHEN '0012'.
        PERFORM f_convert_data USING '' 'C' gt_excel-value
                               CHANGING ls_data-ttlnr.
*****      WHEN '0008'.
*****        PERFORM f_convert_data USING '' 'C' gt_excel-value
*****                               CHANGING ls_data-dppcn.
*****      WHEN '0009'.
*****        PERFORM f_convert_data USING '' 'C' gt_excel-value
*****                               CHANGING ls_data-ppncn.
*****      WHEN '0010'.
*****        PERFORM f_convert_data USING '' 'C' gt_excel-value
*****                               CHANGING ls_data-ttlcn.
*****      WHEN '0016'.
*****        ls_data-vatpr = gt_excel-value.
*****      WHEN '0017'.
*****        PERFORM f_convert_data USING '' 'D' gt_excel-value
*****                               CHANGING ls_data-vatdt.
    ENDCASE.
    AT END OF row.
      ls_data-waers   = 'IDR'.
      APPEND ls_data TO gt_data.
      CLEAR ls_data.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_UPLOAD

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATA
*&---------------------------------------------------------------------*
FORM f_convert_data  USING    fu_conve fu_flag fu_value
                     CHANGING fc_value.
  DATA : lv_function TYPE string,
         lv_str      TYPE string,
         lv_str1     TYPE string,
         lv_str2     TYPE string,
         lv_str3     TYPE string.

  IF fu_flag IS INITIAL.
    IF fu_conve IS NOT INITIAL.
      CONCATENATE 'CONVERSION_EXIT_' fu_conve '_INPUT'
      INTO lv_function.
      CALL FUNCTION lv_function
        EXPORTING
          input  = fu_value
        IMPORTING
          output = fc_value.
    ENDIF.
  ELSE.
    CASE fu_flag.
      WHEN 'D'.
        lv_str = fu_value.
        TRANSLATE lv_str USING '. '.
        TRANSLATE lv_str USING '/ '.
        SPLIT lv_str AT space INTO lv_str1 lv_str2 lv_str3.
        CONCATENATE lv_str3 lv_str2 lv_str1 INTO fc_value.
      WHEN 'C'.
        lv_str = fu_value.
        TRANSLATE lv_str USING '. '.
        TRANSLATE lv_str USING ',.'.
        CONDENSE lv_str NO-GAPS.
        fc_value  = lv_str / 100.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_CONVERT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPLDT_VALIDATE
*&---------------------------------------------------------------------*
FORM f_upldt_validate .
  DATA : lt_xdata      TYPE STANDARD TABLE OF ty_data,
         ls_xdata      LIKE LINE OF lt_xdata,
         ls_data       LIKE LINE OF gt_data,
         ls_out        LIKE LINE OF gt_out,
         lt_xout       TYPE STANDARD TABLE OF ty_out,
         ls_xout       LIKE LINE OF lt_xout,
         lt_sout       TYPE STANDARD TABLE OF ty_out,
         ls_sout       LIKE LINE OF lt_sout,
         lt_zfnrcustm  TYPE STANDARD TABLE OF zfnrcustm,
         lt_zfnrcncust TYPE STANDARD TABLE OF zfnrcncust,
         ls_zfnrclose  TYPE zfnrclose,
         lt_zfppnnrh   TYPE STANDARD TABLE OF zfppnnrh,
         lt_zfppnnrd   TYPE STANDARD TABLE OF zfppnnrd,
         lt_xvbrk      TYPE STANDARD TABLE OF vbrk,
         lt_vbrk       TYPE STANDARD TABLE OF vbrk,
         ls_xvbrk      LIKE LINE OF lt_xvbrk.

  DATA : lv_1000  TYPE zfppnnrh-ttlnr,
         lv_value TYPE zfppnnrh-ttlnr.

  DATA : lt_scn TYPE STANDARD TABLE OF ty_sum,
         lt_snr TYPE STANDARD TABLE OF ty_sum,
         ls_snr LIKE LINE OF lt_snr.

  CLEAR : gt_bapiret2[].

  SELECT SINGLE *
    FROM zfnrclose
    INTO CORRESPONDING FIELDS OF ls_zfnrclose
    WHERE vkorg = pa_vkorg
      AND vkbur = pa_vkbur.

  lt_xdata[] = gt_data[].
  SORT lt_xdata BY bukrs vkbur kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING bukrs vkbur kunnr.
  IF lt_xdata[] IS NOT INITIAL.
    SELECT *
      FROM zfnrcustm
      INTO CORRESPONDING FIELDS OF TABLE lt_zfnrcustm
      FOR ALL ENTRIES IN lt_xdata
      WHERE vkorg = lt_xdata-bukrs
        AND vkbur = lt_xdata-vkbur
        AND kunnr = lt_xdata-kunnr.

    SELECT *
      FROM zfnrcncust
      INTO CORRESPONDING FIELDS OF TABLE lt_zfnrcncust
      FOR ALL ENTRIES IN lt_xdata
      WHERE vkorg = lt_xdata-bukrs
        AND vkbur = lt_xdata-vkbur
        AND kunnr = lt_xdata-kunnr.
  ENDIF.

  lt_xdata[] = gt_data[].
  SORT lt_xdata BY bukrs kunnr monat gjahr nonr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING bukrs kunnr monat gjahr nonr.
  IF lt_xdata[] IS NOT INITIAL.
    SELECT *
      FROM zfppnnrh
      INTO CORRESPONDING FIELDS OF TABLE lt_zfppnnrh
      FOR ALL ENTRIES IN lt_xdata
      WHERE vrsio = space
        AND bukrs = lt_xdata-bukrs
        AND kunnr = lt_xdata-kunnr
        AND monat = lt_xdata-monat
        AND gjahr = lt_xdata-gjahr
        AND nonr  = lt_xdata-nonr.
  ENDIF.

  lt_xdata[] = gt_data[].
  SORT lt_xdata BY bukrs zuonr kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING bukrs zuonr kunnr.
  IF lt_xdata[] IS NOT INITIAL.
    SELECT *
      FROM zfppnnrd
      INTO CORRESPONDING FIELDS OF TABLE lt_zfppnnrd
      FOR ALL ENTRIES IN lt_xdata
      WHERE vrsio = space
        AND bukrs = lt_xdata-bukrs
        AND zuonr = lt_xdata-zuonr
        AND kunnr = lt_xdata-kunnr.
  ENDIF.

  lt_xdata[] = gt_data[].
  SORT lt_xdata BY zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING zuonr.
  IF lt_xdata[] IS NOT INITIAL.
    LOOP AT lt_xdata INTO ls_xdata.
      ls_xvbrk-vbeln = ls_xdata-zuonr.
      APPEND ls_xvbrk TO lt_xvbrk.
      CLEAR ls_xvbrk.
    ENDLOOP.
    IF lt_xvbrk[] IS NOT INITIAL.
      SELECT *
        FROM vbrk
        INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
        FOR ALL ENTRIES IN lt_xvbrk
        WHERE vbeln = lt_xvbrk-vbeln.
    ENDIF.
  ENDIF.

  LOOP AT gt_data INTO ls_data.
    MOVE-CORRESPONDING ls_data TO ls_out.
    PERFORM f_get_value_cn TABLES lt_vbrk
                           USING ls_out-zuonr
                           CHANGING ls_out-dppcn ls_out-ppncn ls_out-ttlcn.

    ls_out-icon   = icon_led_green.

    PERFORM f_read_text USING 'Z008' ls_out-zuonr 'VBBK'
                        CHANGING ls_out-vatpr ls_out-vatdt ls_out-icon.

    PERFORM f_check_company_code USING ls_out-bukrs
                                 CHANGING ls_out-icon.

    PERFORM f_check_sales_office USING ls_out-vkbur
                                 CHANGING ls_out-icon.

    PERFORM f_check_customer TABLES lt_zfnrcustm
                                    lt_zfnrcncust
                             USING ls_out-bukrs ls_out-vkbur
                                   ls_out-kunnr
                             CHANGING ls_out-icon.

    PERFORM f_check_period USING ls_zfnrclose ls_out-monat ls_out-gjahr
                           CHANGING ls_out-icon.

    PERFORM f_check_duplicate TABLES lt_zfppnnrh
                              USING ls_out
                              CHANGING ls_out-icon.

    PERFORM f_collect_summary TABLES lt_scn lt_snr
                              USING ls_out.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  lv_1000 = 10.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-icon = icon_led_red.
      CONTINUE.
    ENDIF.

    PERFORM f_check_value_history TABLES lt_zfppnnrd lt_scn
                                  USING ls_out lv_1000
                                  CHANGING ls_out-icon.

    IF ls_out-icon <> icon_led_red.
      CLEAR ls_snr.
      READ TABLE lt_snr INTO ls_snr
                        WITH KEY nonr = ls_out-nonr.
      IF sy-subrc = 0.
        lv_value = ls_out-ttlnr - lv_1000.

        IF ls_snr-ttlcn < lv_value.
          ls_out-icon = icon_led_red.
          PERFORM f_error_log USING 'E' 'No.CN' ls_out-zuonr
                                    'Total CN Upload < NR Upload ( Toleransi 1000 )'
                                    '' ''.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY gt_out FROM ls_out TRANSPORTING icon.
    CLEAR ls_out.
  ENDLOOP.

  IF gt_bapiret2[] IS NOT INITIAL.
    SORT gt_bapiret2 BY parameter.
  ENDIF.
ENDFORM.                    " F_UPLDT_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log  USING    fu_type fu_msgv1 fu_msgv2 fu_msgv3 fu_msgv4
                           fu_parameter.
  DATA : ls_error   TYPE bapiret2.

  ls_error-type          = fu_type.
  ls_error-id            = 'ZAB'.
  ls_error-number        = '000'.
*  ls_error-message       = fu_message.
  ls_error-message_v1    = fu_msgv1.
  ls_error-message_v2    = fu_msgv2.
  ls_error-message_v3    = fu_msgv3.
  ls_error-message_v4    = fu_msgv4.
  ls_error-parameter     = fu_parameter.
  APPEND ls_error TO gt_bapiret2.
  CLEAR ls_error.
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SALES_OFFICE
*&---------------------------------------------------------------------*
FORM f_check_sales_office  USING    fu_vkbur
                           CHANGING fc_icon.
  IF fu_vkbur <> pa_vkbur.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'Sales Office tidak sesuai' '' '' '' ''.
  ENDIF.
ENDFORM.                    " F_CHECK_SALES_OFFICE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_COMPANY_CODE
*&---------------------------------------------------------------------*
FORM f_check_company_code  USING    fu_bukrs
                           CHANGING fc_icon.
  IF fu_bukrs <> pa_vkorg.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'Company Code tidak sesuai' '' '' '' ''.
  ENDIF.
ENDFORM.                    " F_CHECK_COMPANY_CODE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_check_customer  TABLES   ft_zfnrcustm  STRUCTURE zfnrcustm
                                ft_zfnrcncust STRUCTURE zfnrcncust
                       USING    fu_vkorg fu_vkbur fu_kunnr
                       CHANGING fc_icon.

  DATA : ls_zfnrcustm  TYPE zfnrcustm,
         ls_zfnrcncust TYPE zfnrcncust.

  DATA : lv_mess(100).

  READ TABLE ft_zfnrcustm INTO ls_zfnrcustm
                          WITH KEY vkorg = fu_vkorg
                                   vkbur = fu_vkbur
                                   kunnr = fu_kunnr.
  IF sy-subrc <> 0.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'Customer' fu_kunnr 'bukan outlet NR manual' ''
                              fu_kunnr.
  ENDIF.

  CLEAR lv_mess.
  READ TABLE ft_zfnrcncust INTO ls_zfnrcncust
                           WITH KEY vkorg = fu_vkorg
                                    vkbur = fu_vkbur
                                    kunnr = fu_kunnr.
  IF sy-subrc <> 0.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'Customer' fu_kunnr 'bukan outlet 1 CN < NR' ''
                              fu_kunnr.
  ENDIF.
ENDFORM.                    " F_CHECK_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PERIOD
*&---------------------------------------------------------------------*
FORM f_check_period  USING    fs_zfnrclose  TYPE zfnrclose
                              fu_monat fu_gjahr
                     CHANGING fc_icon.
  DATA : lr_datum TYPE RANGE OF datum,
         ls_datum LIKE LINE OF lr_datum.

  DATA : lv_datum      TYPE sy-datum,
         lv_splow(20),
         lv_sphigh(20).

  CONCATENATE fu_gjahr fu_monat '01' INTO lv_datum.

  CONCATENATE fs_zfnrclose-gjahr fs_zfnrclose-monat '01' INTO ls_datum-low.
  CONCATENATE fs_zfnrclose-monat '.' fs_zfnrclose-gjahr INTO lv_splow.
  CONCATENATE fs_zfnrclose-gjahrto fs_zfnrclose-monatto '01' INTO ls_datum-high.
  CONCATENATE '-' fs_zfnrclose-monatto INTO lv_sphigh SEPARATED BY space.
  CONCATENATE lv_sphigh '.' fs_zfnrclose-gjahrto INTO lv_sphigh.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_datum-high
    IMPORTING
      last_day_of_month = ls_datum-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  ls_datum-sign     = 'E'.
  ls_datum-option   = 'BT'.
  APPEND ls_datum TO lr_datum.

  IF lv_datum IN lr_datum.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'Open period' lv_splow lv_sphigh '' ''.
  ENDIF.
ENDFORM.                    " F_CHECK_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_DATA_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_data_customer .
  DATA : lt_xout    TYPE STANDARD TABLE OF ty_out.

  lt_xout[] = gt_out[].
  SORT lt_xout BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING kunnr.
  IF lt_xout[] IS NOT INITIAL.
    SELECT kna1~kunnr kna1~stceg adrc~name1 adrc~name_co
      FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FOR ALL ENTRIES IN lt_xout
      WHERE kunnr = lt_xout-kunnr.
  ENDIF.
ENDFORM.                    " F_DATA_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ZFPPNNRH
*&---------------------------------------------------------------------*
FORM f_prepare_zfppnnrh  USING    fs_out  TYPE ty_out.
  DATA : ls_zfppnnrh LIKE LINE OF gt_zfppnnrh,
         ls_kna1     LIKE LINE OF gt_kna1.

  ls_zfppnnrh-vrsio        = space.
  ls_zfppnnrh-bukrs        = fs_out-bukrs.
  ls_zfppnnrh-kunnr        = fs_out-kunnr.
  ls_zfppnnrh-monat        = fs_out-monat.
  ls_zfppnnrh-gjahr        = fs_out-gjahr.
  ls_zfppnnrh-nonr         = fs_out-nonr.
  ls_zfppnnrh-nrdt         = fs_out-nrdt.

  READ TABLE gt_kna1 INTO ls_kna1
                     WITH KEY kunnr = fs_out-kunnr.
  IF sy-subrc = 0.
    ls_zfppnnrh-name1        = ls_kna1-name1.
    ls_zfppnnrh-name_co      = ls_kna1-name_co.
    ls_zfppnnrh-stceg        = ls_kna1-stceg.
  ENDIF.

  ls_zfppnnrh-vatpr1       = fs_out-vatpr.
  ls_zfppnnrh-vatdt1       = fs_out-vatdt.
  ls_zfppnnrh-waers        = fs_out-waers.
  ls_zfppnnrh-ttlnr        = fs_out-ttlnr.
  ls_zfppnnrh-dppnr        = fs_out-dppnr.
  ls_zfppnnrh-ppnnr        = fs_out-ppnnr.
  ls_zfppnnrh-ttlcn        = fs_out-ttlcn.
  ls_zfppnnrh-dppcn        = fs_out-dppcn.
  ls_zfppnnrh-ppncn        = fs_out-ppncn.
  ls_zfppnnrh-usna1        = sy-uname.
  ls_zfppnnrh-erdt1        = sy-datum.
  ls_zfppnnrh-erzet        = sy-uzeit.
  APPEND ls_zfppnnrh TO gt_zfppnnrh.
ENDFORM.                    " F_PREPARE_ZFPPNNRH

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DUPLICATE
*&---------------------------------------------------------------------*
FORM f_check_duplicate  TABLES   ft_zfppnnrh STRUCTURE zfppnnrh
                        USING    fs_out TYPE ty_out
                        CHANGING fc_icon.
  DATA : ls_zfppnnrh    LIKE LINE OF gt_zfppnnrh.

  READ TABLE ft_zfppnnrh INTO ls_zfppnnrh
                         WITH KEY bukrs = fs_out-bukrs
                                  kunnr = fs_out-kunnr
                                  monat = fs_out-monat
                                  gjahr = fs_out-gjahr
                                  nonr  = fs_out-nonr.
  IF sy-subrc = 0.
    fc_icon = icon_led_red.
    PERFORM f_error_log USING 'E' 'No. NR' fs_out-nonr 'duplicated' '' ''.
  ENDIF.
ENDFORM.                    " F_CHECK_DUPLICATE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ZFPPNNRD
*&---------------------------------------------------------------------*
FORM f_prepare_zfppnnrd  USING    fs_out  TYPE ty_out.
  DATA : ls_zfppnnrd LIKE LINE OF gt_zfppnnrd,
         ls_vbrk     LIKE LINE OF gt_vbrk,
         ls_vbrp     LIKE LINE OF gt_vbrp.

  ls_zfppnnrd-vrsio        = space.
  ls_zfppnnrd-bukrs        = fs_out-bukrs.
  ls_zfppnnrd-vkbur        = fs_out-vkbur.
  ls_zfppnnrd-belnr        = fs_out-zuonr.
  ls_zfppnnrd-zuonr        = fs_out-zuonr.
  ls_zfppnnrd-kunnr        = fs_out-kunnr.
  ls_zfppnnrd-monat        = fs_out-monat.
  ls_zfppnnrd-gjahr        = fs_out-gjahr.
  ls_zfppnnrd-nonr         = fs_out-nonr.

  READ TABLE gt_vbrp INTO ls_vbrp
                     WITH KEY vbeln = fs_out-zuonr.
  IF sy-subrc = 0.
    ls_zfppnnrd-aubel        = ls_vbrp-aubel.
  ENDIF.

  READ TABLE gt_vbrk INTO ls_vbrk
                     WITH KEY vbeln = fs_out-zuonr.
  IF sy-subrc = 0.
    ls_zfppnnrd-budat        = ls_vbrk-fkdat.
  ENDIF.

  ls_zfppnnrd-nrdt         = fs_out-nrdt.
  ls_zfppnnrd-waers        = fs_out-waers.
  ls_zfppnnrd-ttlcn        = fs_out-ttlcn.
  ls_zfppnnrd-dppcn        = fs_out-dppcn.
  ls_zfppnnrd-ppncn        = fs_out-ppncn.
  ls_zfppnnrd-usna1        = sy-uname.
  ls_zfppnnrd-erdt1        = sy-datum.
  ls_zfppnnrd-erzet        = sy-uzeit.
  ls_zfppnnrd-ttlnr        = fs_out-ttlnr.
  ls_zfppnnrd-dppnr        = fs_out-dppnr.
  ls_zfppnnrd-ppnnr        = fs_out-ppnnr.
  APPEND ls_zfppnnrd TO gt_zfppnnrd.
ENDFORM.                    " F_PREPARE_ZFPPNNRD

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SALES_ORDER
*&---------------------------------------------------------------------*
FORM f_data_sales_order .
  DATA : lt_xdata TYPE STANDARD TABLE OF ty_data,
         lt_xvbrp TYPE STANDARD TABLE OF vbrp,
         ls_xdata LIKE LINE OF lt_xdata,
         ls_xvbrp LIKE LINE OF lt_xvbrp,
         ls_vbrp  LIKE LINE OF gt_vbrp.

  lt_xdata[] = gt_data[].
  SORT lt_xdata BY zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING zuonr.
  IF lt_xdata[] IS NOT INITIAL.
    LOOP AT lt_xdata INTO ls_xdata.
      ls_xvbrp-vbeln = ls_xdata-zuonr.
      APPEND ls_xvbrp TO lt_xvbrp.
      CLEAR ls_xvbrp.
    ENDLOOP.

    IF lt_xvbrp[] IS NOT INITIAL.
      SELECT vbeln fkdat waerk
        FROM vbrk
        INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
        FOR ALL ENTRIES IN lt_xvbrp
        WHERE vbeln = lt_xvbrp-vbeln.

      SELECT vbeln posnr aubel matnr arktx fkimg vrkme kzwi1 kzwi5 skfbp
        FROM vbrp
        INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
        FOR ALL ENTRIES IN lt_xvbrp
        WHERE vbeln = lt_xvbrp-vbeln.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DATA_SALES_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ZFPPNNRDTL
*&---------------------------------------------------------------------*
FORM f_prepare_zfppnnrdtl  USING    fs_out  TYPE ty_out.
  DATA : ls_zfppnnrdtl LIKE LINE OF gt_zfppnnrdtl,
         ls_vbrk       LIKE LINE OF gt_vbrk,
         ls_vbrp       LIKE LINE OF gt_vbrp.

  LOOP AT gt_vbrp INTO ls_vbrp WHERE vbeln = fs_out-zuonr.
    ls_zfppnnrdtl-bukrs        = fs_out-bukrs.
    ls_zfppnnrdtl-vkbur        = fs_out-vkbur.
    ls_zfppnnrdtl-kunnr        = fs_out-kunnr.
    ls_zfppnnrdtl-gjahr        = fs_out-gjahr.
    ls_zfppnnrdtl-nonr         = fs_out-nonr.
    ls_zfppnnrdtl-matnr        = ls_vbrp-matnr.
    ls_zfppnnrdtl-nrdt         = fs_out-nrdt.
    ls_zfppnnrdtl-arktx        = ls_vbrp-arktx.
    ls_zfppnnrdtl-fkimg        = ls_vbrp-fkimg.
    ls_zfppnnrdtl-vrkme        = ls_vbrp-vrkme.
    ls_zfppnnrdtl-kzwi1        = ls_vbrp-kzwi1.
    READ TABLE gt_vbrk INTO ls_vbrk
                       WITH KEY vbeln = ls_vbrp-vbeln.
    IF sy-subrc = 0.
      ls_zfppnnrdtl-waerk        = ls_vbrk-waerk.
    ENDIF.
    ls_zfppnnrdtl-kzwi5        = ls_vbrp-kzwi5.
    ls_zfppnnrdtl-skfbp        = ls_vbrp-skfbp.
    COLLECT ls_zfppnnrdtl INTO gt_zfppnnrdtl.
    CLEAR ls_zfppnnrdtl.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_ZFPPNNRDTL

*&---------------------------------------------------------------------*
*&      Form  F_ISI_ZFPPNNRH
*&---------------------------------------------------------------------*
FORM f_isi_zfppnnrh .
  TRY .
      INSERT zfppnnrh FROM TABLE gt_zfppnnrh.
    CATCH cx_sy_open_sql_db.
      gv_subrc = 4.
  ENDTRY.
ENDFORM.                    " F_ISI_ZFPPNNRH

*&---------------------------------------------------------------------*
*&      Form  F_ISI_ZFPPNNRD
*&---------------------------------------------------------------------*
FORM f_isi_zfppnnrd .
  TRY .
      INSERT zfppnnrd FROM TABLE gt_zfppnnrd.
    CATCH cx_sy_open_sql_db.
      gv_subrc = 4.
  ENDTRY.
ENDFORM.                    " F_ISI_ZFPPNNRD

*&---------------------------------------------------------------------*
*&      Form  F_ISI_ZFPPNNRDTL
*&---------------------------------------------------------------------*
FORM f_isi_zfppnnrdtl .
  TRY .
      INSERT zfppnnrdtl FROM TABLE gt_zfppnnrdtl.
    CATCH cx_sy_open_sql_db.
      gv_subrc = 4.
  ENDTRY.
ENDFORM.                    " F_ISI_ZFPPNNRDTL

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  USING    fu_id fu_name fu_object
                  CHANGING fc_vatpr fc_vatdt fc_icon.
  DATA : lv_id        TYPE thead-tdid,
         lv_name      TYPE thead-tdname,
         lv_object    TYPE thead-tdobject,
         lv_str1      TYPE string,
         lv_str2      TYPE string,
         lv_vatpr(20),
         lv_vatdt(10),
         lv_length    TYPE i.

  DATA : lines    TYPE STANDARD TABLE OF tline,
         ls_lines LIKE LINE OF lines.

  lv_id       = fu_id.
  lv_name     = fu_name.
  lv_object   = fu_object.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lv_id
      language                = sy-langu
      name                    = lv_name
      object                  = lv_object
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE lines INTO ls_lines INDEX 1.
  IF ls_lines-tdline IS NOT INITIAL.
    TRANSLATE ls_lines-tdline USING '/ '.
    SPLIT ls_lines-tdline AT space INTO lv_str1 lv_str2.
    CLEAR lv_length.
    lv_length = strlen( lv_str1 ).
    IF lv_length = 17.
      lv_vatpr = lv_str1.
    ELSE.
      lv_vatpr = lv_str1.
      TRANSLATE lv_vatpr USING '- '.
      TRANSLATE lv_vatpr USING '. '.
      CONDENSE lv_vatpr NO-GAPS.
      WRITE lv_vatpr TO lv_vatpr USING EDIT MASK '___.___-__.________'.
    ENDIF.

    lv_vatdt = lv_str2.
    TRANSLATE lv_vatdt USING '. '.
    CONDENSE lv_vatdt NO-GAPS.
    WRITE lv_vatdt TO lv_vatdt USING EDIT MASK '__.__.____'.

    IF lv_vatpr IS INITIAL.
      fc_icon   = icon_led_red.
      PERFORM f_error_log USING 'E' 'Referensi FP kosong' '' '' '' ''.
    ELSE.
      IF lv_str1 = lv_vatpr.
        fc_vatpr  = lv_str1.
      ELSE.
        fc_icon   = icon_led_red.
        PERFORM f_error_log USING 'E' 'Format referensi FP tidak sesuai' '' '' '' ''.
      ENDIF.
    ENDIF.

    IF lv_vatdt IS INITIAL.
      fc_icon   = icon_led_red.
      PERFORM f_error_log USING 'E' 'Tanggal FP kosong' '' '' '' ''.
    ELSE.
      IF lv_str2 = lv_vatdt.
        CONCATENATE lv_str2+6(4) lv_str2+3(2) lv_str2(2) INTO fc_vatdt.
      ELSE.
        fc_icon   = icon_led_red.
        PERFORM f_error_log USING 'E' 'Format tanggal FP tidak sesuai' '' '' '' ''.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUE_CN
*&---------------------------------------------------------------------*
FORM f_get_value_cn  TABLES   ft_vbrk    STRUCTURE vbrk
                     USING    fu_zuonr
                     CHANGING fc_dppcn fc_ppncn fc_ttlcn.
  DATA : ls_vbrk    TYPE vbrk.

  READ TABLE ft_vbrk INTO ls_vbrk
                     WITH KEY vbeln = fu_zuonr.
  IF sy-subrc = 0.
    fc_dppcn = ls_vbrk-netwr.
    fc_ppncn = ls_vbrk-mwsbk.
    fc_ttlcn = ls_vbrk-netwr + ls_vbrk-mwsbk.
  ENDIF.
ENDFORM.                    " F_GET_VALUE_CN

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VALUE_HISTORY
*&---------------------------------------------------------------------*
FORM f_check_value_history  TABLES   ft_zfppnnrd    STRUCTURE zfppnnrd
                                     ft_scn   LIKE gt_sum
                            USING    fs_out   TYPE ty_out
                                     fu_1000
                            CHANGING fc_icon.
  DATA : lv_value TYPE zfppnnrh-ttlnr,
         lv_ttlnr TYPE zfppnnrd-ttlnr,
         lv_count TYPE i.

  DATA : ls_zfppnnrd TYPE zfppnnrd,
         ls_scn      TYPE ty_sum.

  READ TABLE ft_zfppnnrd INTO ls_zfppnnrd
                         WITH KEY zuonr = fs_out-zuonr.
  IF sy-subrc = 0.
    LOOP AT ft_zfppnnrd INTO ls_zfppnnrd WHERE zuonr = fs_out-zuonr.
      ADD ls_zfppnnrd-ttlnr TO lv_ttlnr.
    ENDLOOP.

    READ TABLE ft_scn INTO ls_scn
                      WITH KEY zuonr = fs_out-zuonr.
    IF sy-subrc = 0.
      IF ls_scn-count > 1.
        lv_count  = ls_scn-count.
      ELSE.
        lv_ttlnr  = lv_ttlnr + ls_scn-ttlnr.
      ENDIF.
    ENDIF.

    IF lv_count > 1.
      fc_icon = icon_led_red.
      PERFORM f_error_log USING 'E' 'No.CN' fs_out-zuonr
                                'CN sudah dibuatkan Nota Retur ( toleransi 1000 )'
                                '' ''.
    ELSE.
      lv_value = ( lv_ttlnr + fs_out-ttlnr ) - fu_1000.
      IF lv_value > fs_out-ttlcn.
        fc_icon = icon_led_red.
        PERFORM f_error_log USING 'E' 'No.CN' fs_out-zuonr
                                  'CN sudah dibuatkan Nota Retur ( toleransi 1000 )'
                                  '' ''.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_VALUE_HISTORY

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_SUMMARY
*&---------------------------------------------------------------------*
FORM f_collect_summary  TABLES   ft_scn   LIKE gt_sum
                                 ft_snr   LIKE gt_sum
                        USING    fs_out   TYPE ty_out.
  DATA : ls_out   LIKE LINE OF gt_sum.

  ls_out-nonr   = fs_out-nonr.
  ls_out-count  = 1.
  ls_out-ttlcn  = fs_out-ttlcn.
  COLLECT ls_out INTO ft_snr.
  CLEAR ls_out.

  ls_out-zuonr  = fs_out-zuonr.
  ls_out-count  = 1.
  ls_out-ttlnr  = fs_out-ttlnr.
  COLLECT ls_out INTO ft_snr.
  CLEAR ls_out.
ENDFORM.                    " F_COLLECT_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
FORM f_check_extension  USING    fu_filename
                        CHANGING fu_extension.
  DATA: lv_drive   TYPE pc_drive,
        lv_path    TYPE pc_path,
        lv_fname_e TYPE pc_fname_e,
        lv_fname   TYPE pc_fname,
        lv_fext    TYPE pc_fext,
        lv_path_s  TYPE pc_path.

  lv_path = fu_filename.

  CALL FUNCTION 'PC_SPLIT_COMPLETE_FILENAME'
    EXPORTING
      complete_filename = lv_path
*     CHECK_DOS_FORMAT  =
    IMPORTING
      drive             = lv_drive
      extension         = lv_fext
      name              = lv_fname
      name_with_ext     = lv_fname_e
      path              = lv_path_s
    EXCEPTIONS
      invalid_drive     = 1
      invalid_extension = 2
      invalid_name      = 3
      invalid_path      = 4
      OTHERS            = 5.
  IF sy-subrc = 0.
    fu_extension = lv_fext.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_UPLOAD_TXT
*&---------------------------------------------------------------------*
FORM f_get_data_upload_txt  USING    fu_filename.
  DATA: lv_filename TYPE string.

  lv_filename = fu_filename.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = gt_text
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE 'Upload Error' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  LOOP AT gt_text INTO DATA(ls_text).
    IF sy-tabix = 1.
      CONTINUE.
    ENDIF.
    APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    <fs_data>-bukrs = ls_text-bukrs.
    <fs_data>-vkbur = ls_text-vkbur.
    <fs_data>-kunnr = ls_text-kunnr.
    <fs_data>-monat = ls_text-monat.
    <fs_data>-gjahr = ls_text-gjahr.
    <fs_data>-zuonr = ls_text-zuonr.
    <fs_data>-budat = |{ ls_text-budat+6(4) }| & |{ ls_text-budat+3(2) }| & |{ ls_text-budat(2) }|.
    <fs_data>-nonr  = ls_text-nonr.
    <fs_data>-nrdt  = |{ ls_text-nrdt+6(4) }| & |{ ls_text-nrdt+3(2) }| & |{ ls_text-nrdt(2) }|.
    <fs_data>-dppnr = ls_text-dppnr / 100.
    <fs_data>-ppnnr = ls_text-ppnnr / 100.
    <fs_data>-ttlnr = ls_text-ttlnr / 100.
    <fs_data>-waers = 'IDR'.
  ENDLOOP.
ENDFORM.
