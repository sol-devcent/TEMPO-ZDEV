*----------------------------------------------------------------------*
*   INCLUDE ZF_BLOK_AR_V1SF_F01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

  IF pa_bukrs EQ '8020'.
    gv_gsber  = '0200'.
    gv_bukrs  = pa_bukrs.
*    CLEAR gv_bukrs.
  ELSEIF pa_bukrs EQ '8070'.
    gv_gsber  = '0700'.
    gv_bukrs  = pa_bukrs.
  ENDIF.

  ra_blart-low    = 'DA'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.
  ra_blart-low    = 'DG'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.
  ra_blart-low    = 'DR'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.
  ra_blart-low    = 'DZ'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.
  ra_blart-low    = 'RV'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.
  ra_blart-low    = 'ZA'.
  ra_blart-sign   = 'I'.
  ra_blart-option = 'EQ'.
  APPEND ra_blart.

  IF radio5 NE 'X' AND
    radio6 NE 'X'.
    SELECT *
      FROM zfh_kr1at
      INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
      WHERE bukrs     EQ pa_bukrs AND
            vkbur     EQ pa_vkbur AND
            kunnr     IN so_kunnr AND
            stsrel1   NE '9'      AND
            stsrel2   NE '9'      AND
            stsrel3   NE '9'      AND
            stsrel4   NE '9'      AND
            belnrpos2 EQ space.
  ENDIF.

  SELECT *
    FROM zfhnoform3
    INTO CORRESPONDING FIELDS OF TABLE t_zfhnoform3
    WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur.

  READ TABLE t_zfhnoform3 WITH KEY bukrs = pa_bukrs
                                   vkbur = pa_vkbur.
  IF sy-subrc EQ 0.
    ADD 1 TO t_zfhnoform3-noform.
    va_noform = t_zfhnoform3-noform.
  ELSE.
    t_zfhnoform3-bukrs  = pa_bukrs.
    t_zfhnoform3-gsber  = gv_gsber.
    t_zfhnoform3-vkbur  = pa_vkbur.
    t_zfhnoform3-noform = '000001'.
    APPEND t_zfhnoform3.
  ENDIF.

  SELECT *
    FROM zfhstatus
    INTO TABLE t_zfhstatus
    WHERE bukrs EQ gv_bukrs.

  SELECT *
    FROM zfusrrel_form3
    INTO CORRESPONDING FIELDS OF TABLE t_zfusrrel_form3.
  SORT t_zfusrrel_form3 BY zlevel.
  LOOP AT t_zfusrrel_form3.
    CASE t_zfusrrel_form3-zlevel.
      WHEN '1'.
        va_level1 = t_zfusrrel_form3-usergroup.
      WHEN '2'.
        va_level2 = t_zfusrrel_form3-usergroup.
      WHEN '3'.
        va_level3 = t_zfusrrel_form3-usergroup.
      WHEN '4'.
        va_level4 = t_zfusrrel_form3-usergroup.
    ENDCASE.
  ENDLOOP.
  IF va_level4 IS INITIAL.
    va_level4 = 'XXXXX'.
  ENDIF.

  SELECT *
    FROM zfusrrel_form3
    INTO CORRESPONDING FIELDS OF TABLE t_zfusrrel_form3x
    WHERE zlevel_hdr NE space.
  LOOP AT t_zfusrrel_form3x.
    CASE t_zfusrrel_form3x-zlevel_hdr.
      WHEN 1.
        lv_level1 = t_zfusrrel_form3x-usergroup.
      WHEN 2.
        lv_level2 = t_zfusrrel_form3x-usergroup.
      WHEN 3.
        lv_level3 = t_zfusrrel_form3x-usergroup.
      WHEN 4.
        lv_level4 = t_zfusrrel_form3x-usergroup.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  CASE 'X'.
    WHEN radio1.
      SELECT a~bukrs a~kunnr a~zuonr a~gjahr a~belnr a~buzei a~budat a~bldat
             a~waers a~xblnr a~monat a~shkzg a~gsber a~wrbtr a~hkont a~zfbdt
             a~zterm a~zbd1t a~zlspr a~vbund a~xref1 a~xref2 a~xref3 a~blart
             a~umskz
             b~vkbur b~spart
        INTO CORRESPONDING FIELDS OF TABLE t_data
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
        WHERE a~bukrs EQ pa_bukrs        AND
              a~kunnr IN so_kunnr        AND
              a~zuonr IN so_zuonr        AND
              a~zlspr IN (space,'Z','B') AND
              a~blart IN ra_blart        AND
              a~umskz IN (space,'V')     AND
              b~vkorg EQ pa_bukrs        AND
              b~vtweg EQ '10'            AND
              b~vkbur EQ pa_vkbur.

      SORT t_data BY bukrs gsber vkbur zuonr.
      SORT t_zfh_kr1at BY bukrs gsber vkbur zuonr.

      IF t_zfh_kr1at[] IS NOT INITIAL.
        LOOP AT t_data.
          READ TABLE t_zfh_kr1at WITH KEY bukrs = t_data-bukrs
                                          gsber = t_data-gsber
                                          vkbur = t_data-vkbur
                                          zuonr = t_data-zuonr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            DELETE t_data.
          ENDIF.
        ENDLOOP.
      ENDIF.

      t_kunnr[] = t_data[].
      t_belnr[] = t_data[].
      SORT t_kunnr BY kunnr.
      DELETE ADJACENT DUPLICATES FROM t_kunnr COMPARING kunnr.
      SORT t_belnr BY belnr.
      DELETE ADJACENT DUPLICATES FROM t_belnr COMPARING belnr.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.

        SELECT *
          FROM knkk
          INTO CORRESPONDING FIELDS OF TABLE t_knkk
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr AND
                kkber EQ '8000'.

        SELECT a~kunnr a~kvgr4 b~usrgroup
          FROM knvv AS a JOIN zscl_top AS b ON b~kvgr4 = a~kvgr4
          INTO CORRESPONDING FIELDS OF TABLE t_knvv
          FOR ALL ENTRIES IN t_kunnr
          WHERE a~kunnr EQ t_kunnr-kunnr AND
                a~vkorg EQ pa_bukrs      AND
                a~vtweg EQ '10'          AND
                a~spart EQ '00'          AND
                b~zflag EQ 'X'.
      ENDIF.

    WHEN radio2.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs   EQ pa_bukrs AND
              vkbur   EQ pa_vkbur AND
              kunnr   IN so_kunnr AND
              zuonr   IN so_zuonr AND
              noform  EQ pa_nform AND
              zdesc1  NE space    AND
              ( stsrel1 EQ space  OR
                stsrel2 EQ space ).

      SORT t_zfh_kr1at BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_kunnr-kunnr = t_zfh_kr1at-kunnr.
        COLLECT t_kunnr.
      ENDLOOP.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.

        SELECT a~kunnr a~kvgr4 b~usrgroup
          FROM knvv AS a JOIN zscl_top AS b ON b~kvgr4 = a~kvgr4
          INTO CORRESPONDING FIELDS OF TABLE t_knvv
          FOR ALL ENTRIES IN t_kunnr
          WHERE a~kunnr EQ t_kunnr-kunnr AND
                a~vkorg EQ pa_bukrs      AND
                a~vtweg EQ '10'          AND
                a~spart EQ '00'          AND
                b~zflag EQ 'X'.
      ENDIF.

    WHEN radio3.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs   EQ pa_bukrs AND
              vkbur   EQ pa_vkbur AND
              noform  IN so_nform AND
              zuonr   IN so_zuonr AND
              kunnr   IN so_kunnr.

      SORT t_zfh_kr1at BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_kunnr-kunnr = t_zfh_kr1at-kunnr.
        COLLECT t_kunnr.
      ENDLOOP.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.
      ENDIF.

    WHEN radio4.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs     EQ pa_bukrs AND
              gsber     EQ gv_gsber AND
              vkbur     EQ pa_vkbur AND
              noform    IN so_nform AND
              zuonr     IN so_zuonr AND
              kunnr     IN so_kunnr AND
              stsrel5   EQ space    AND
              belnrpos1 NE space    AND
              belnrpos2 EQ space.

      SORT t_zfh_kr1at BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_kunnr-kunnr = t_zfh_kr1at-kunnr.
        COLLECT t_kunnr.
      ENDLOOP.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.
      ENDIF.

    WHEN radio5.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs   EQ pa_bukrs AND
              vkbur   EQ pa_vkbur AND
              noform  EQ pa_nform.

      SORT t_zfh_kr1at BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_kunnr-kunnr = t_zfh_kr1at-kunnr.
        COLLECT t_kunnr.
      ENDLOOP.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.
      ENDIF.

    WHEN radio6.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs   EQ pa_bukrs AND
              vkbur   EQ pa_vkbur AND
              noform  IN so_nform AND
              zuonr   IN so_zuonr AND
              dtform  IN so_dform AND
              kunnr   IN so_kunnr.

      SORT t_zfh_kr1at BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_kunnr-kunnr = t_zfh_kr1at-kunnr.
        COLLECT t_kunnr.
      ENDLOOP.

      IF t_kunnr[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE t_kna1
          FOR ALL ENTRIES IN t_kunnr
          WHERE kunnr EQ t_kunnr-kunnr.

        SELECT a~kunnr a~kvgr3 b~bezei
          FROM knvv AS a JOIN tvv3t AS b ON a~kvgr3 EQ b~kvgr3
          INTO CORRESPONDING FIELDS OF TABLE t_knvv
          FOR ALL ENTRIES IN t_kunnr
          WHERE a~kunnr EQ t_kunnr-kunnr AND
                b~spras EQ sy-langu.
      ENDIF.
  ENDCASE.

  DELETE t_zfh_kr1at WHERE status EQ 'Z'.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio3.
      PERFORM f_alv TABLES t_zfh_kr1at.
    WHEN OTHERS.
      PERFORM f_alv TABLES t_out.
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

  CASE 'X'.
    WHEN radio1.
* Begin remark unicode coversion - DEVK965979
* 13.03.2020 - sol chirka
**      PERFORM f_fieldcatg USING ft_report:
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '22' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'KNKK' 'KLIMK' '' '14' 'Plafond' '' '' '' '' '' 'WAERS' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '14' 'No.DO/CN' '' '' '' '' '' '' '' '' '',
**        'BELNR' 'BSID' 'BELNR' 'X' '' '' '' 'X' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'BLDAT' 'BSID' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ' 'BSID' 'UMSKZ' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ICON' '' '' '' '4' 'DD' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '14' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'ERROR' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' ''.
**      IF va_valid EQ 1.
**        PERFORM f_fieldcatg USING ft_report:
**        'STATUS' 'ZFH_KR1AT' 'STATUS' '' '' 'Alasan' '' '' '' '' '' '' '' '' ''.
**      ELSE.
**        PERFORM f_fieldcatg USING ft_report:
**        'STATUS' 'ZFH_KR1AT' 'STATUS' '' '' 'Alasan' '' '' '' '' '' '' '' '' 'X'.
**      ENDIF.
**      PERFORM f_fieldcatg USING ft_report:
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio2.
**      PERFORM f_fieldcatg USING ft_report:
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'KNKK' 'KLIMK' '' '15' 'Plafond' '' '' '' '' '' 'WAERS' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '' 'No.DO/CN' '' '' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '',
**        'UMSKZ' 'BSID' 'UMSKZ' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ICON' '' '' '' '4' 'DD' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Alasan' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio3.
**      PERFORM f_fieldcatg USING ft_report:
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'ZFH_KR1AT' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'ZFH_KR1AT' 'ZUONR' '' '' 'No.DO/CN' '' 'X' '' '' '' '' '' '' '',
**        'BUDAT' 'ZFH_KR1AT' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '',
**        'UMSKZ' 'ZFH_KR1AT' 'UMSKZ' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'ZFH_KR1AT' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'ZFH_KR1AT' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Status' '' '' '' '' '' '' '' '' '',
**        'STSREL1' 'ZFH_KR1AT' '' '' '7' 'Gol1' '' '' '' '' '' '' '' '' '',
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' '' '' 'UsrGrp1' '' '' '' '' '' '' '' '' '',
**        'STSREL2' 'ZFH_KR1AT' '' '' '7' 'Gol2' '' '' '' '' '' '' '' '' '',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' '' '' 'UsrGrp2' '' '' '' '' '' '' '' '' '',
**        'SGTXT3' 'ZFH_KR1AT' 'SGTXT3' '' '' 'Giro' '' '' '' '' '' '' '' '' '',
**
**        'STSREL3' 'ZFH_KR1AT' '' 'X' '5' lv_level3 '' '' '' '' '' '' '' '' '',
**        'STSREL4' 'ZFH_KR1AT' '' 'X' '5' lv_level4 '' '' '' '' '' '' '' '' '',
**        'STSREL5' 'ZFH_KR1AT' 'STSREL5' 'X' '' '' '' '' '' '' '' '' '' '' '',
**
**        'BUKRS' 'ZFH_KR1AT' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'GSBER' 'ZFH_KR1AT' 'GSBER' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'VKBUR' 'ZFH_KR1AT' 'VKBUR' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DTFORM' 'ZFH_KR1AT' 'DTFORM' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNR' 'ZFH_KR1AT' 'BELNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'GJAHR' 'ZFH_KR1AT' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'BLDAT' 'ZFH_KR1AT' 'BLDAT' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'ZFBDT' 'ZFH_KR1AT' 'ZFBDT' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'ZTERM' 'ZFH_KR1AT' 'ZTERM' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'ZFH_KR1AT' 'KLIMK' 'X' '' '' '' '' '' '' '' 'WAERS' '' '' '',
**        'OVERDSO' 'ZFH_KR1AT' 'OVERDSO' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'USNAM' 'ZFH_KR1AT' 'USNAM' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'UTIME' 'ZFH_KR1AT' 'UTIME' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL1' 'ZFH_KR1AT' 'NAMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL1' 'ZFH_KR1AT' 'DATEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL1' 'ZFH_KR1AT' 'TIMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL2' 'ZFH_KR1AT' 'NAMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL2' 'ZFH_KR1AT' 'DATEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL2' 'ZFH_KR1AT' 'TIMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL3' 'ZFH_KR1AT' 'NAMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL3' 'ZFH_KR1AT' 'DATEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL3' 'ZFH_KR1AT' 'TIMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL4' 'ZFH_KR1AT' 'NAMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL4' 'ZFH_KR1AT' 'DATEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL4' 'ZFH_KR1AT' 'TIMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL5' 'ZFH_KR1AT' 'NAMEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL5' 'ZFH_KR1AT' 'DATEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL5' 'ZFH_KR1AT' 'TIMEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEPOS1' 'ZFH_KR1AT' 'NAMEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ1' 'ZFH_KR1AT' 'UMSKZ1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' 'X' '' '' '' 'X' '' '' '' '' '' '' '',
**        'GJAHRPOS1' 'ZFH_KR1AT' 'GJAHRPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEPOS1' 'ZFH_KR1AT' 'DATEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEPOS1' 'ZFH_KR1AT' 'TIMEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT1' 'ZFH_KR1AT' 'SGTXT1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEPOS2' 'ZFH_KR1AT' 'NAMEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ2' 'ZFH_KR1AT' 'UMSKZ2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNRPOS2' 'ZFH_KR1AT' 'BELNRPOS2' 'X' '' '' '' 'X' '' '' '' '' '' '' '',
**        'GJAHRPOS2' 'ZFH_KR1AT' 'GJAHRPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEPOS2' 'ZFH_KR1AT' 'DATEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEPOS2' 'ZFH_KR1AT' 'TIMEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT2' 'ZFH_KR1AT' 'SGTXT2' 'X' '' '' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio4.
**      PERFORM f_fieldcatg USING ft_report:
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '15' 'No.DO/CN' '' '' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '',
**        'UMSKZ' 'BSID' 'UMSKZ' '' '' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' ''.
* End remark unicode coversion - DEVK965979
* Begin insert unicode conversion - DEVK965979
* 13.03.2020 - sol chirka
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '22' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'KNKK'      'KLIMK'     ''  '14' 'Plafond'     '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  '14' 'No.DO/CN'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNR'     'BSID'      'BELNR'     'X' ''   ''            '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BLDAT'     'BSID'      'BLDAT'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ'     'BSID'      'UMSKZ'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ICON'      ''          ''          ''  '4'  'DD'          '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '14' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ERROR'     ''          ''          ''  '4'  'Sts'         '' '' '' '' '' '' '' '' ''.
      IF va_valid EQ 1.
        PERFORM f_fieldcatg USING :
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    ''  ''   'Alasan'      '' '' '' '' '' '' '' '' ''.
      ELSE.
        PERFORM f_fieldcatg USING :
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    ''  ''   'Alasan'      '' '' '' '' '' '' '' '' 'X'.
      ENDIF.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' ''.

    WHEN radio2.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'KNKK'      'KLIMK'     ''  '15' 'Plafond'     '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  ''   'No.DO/CN'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ'     'BSID'      'UMSKZ'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ICON'      ''          ''          ''  '4'  'DD'          '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''   'Alasan'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' ''.

    WHEN radio3.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'ZFH_KR1AT' 'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'ZFH_KR1AT' 'ZUONR'     ''  ''   'No.DO/CN'    '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'ZFH_KR1AT' 'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ'     'ZFH_KR1AT' 'UMSKZ'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'ZFH_KR1AT' 'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'ZFH_KR1AT' 'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''   'Status'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL1'   'ZFH_KR1AT' ''          ''  '7'  'Gol1'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' ''  ''   'UsrGrp1'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL2'   'ZFH_KR1AT' ''          ''  '7'  'Gol2'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' ''  ''   'UsrGrp2'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT3'    'ZFH_KR1AT' 'SGTXT3'    ''  ''   'Giro'        '' '' '' '' '' '' '' '' '',

        'FT_REPORT' 'STSREL3'   'ZFH_KR1AT' ''          'X' '5'  lv_level3     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL4'   'ZFH_KR1AT' ''          'X' '5'  lv_level4     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL5'   'ZFH_KR1AT' 'STSREL5'   'X' ''   ''            '' '' '' '' '' '' '' '' '',

        'FT_REPORT' 'BUKRS'     'ZFH_KR1AT' 'BUKRS'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GSBER'     'ZFH_KR1AT' 'GSBER'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DTFORM'    'ZFH_KR1AT' 'DTFORM'    'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNR'     'ZFH_KR1AT' 'BELNR'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHR'     'ZFH_KR1AT' 'GJAHR'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BLDAT'     'ZFH_KR1AT' 'BLDAT'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZFBDT'     'ZFH_KR1AT' 'ZFBDT'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZTERM'     'ZFH_KR1AT' 'ZTERM'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'ZFH_KR1AT' 'KLIMK'     'X' ''   ''            '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'OVERDSO'   'ZFH_KR1AT' 'OVERDSO'   'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USNAM'     'ZFH_KR1AT' 'USNAM'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UTIME'     'ZFH_KR1AT' 'UTIME'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL1'  'ZFH_KR1AT' 'NAMEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL1'  'ZFH_KR1AT' 'DATEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL1'  'ZFH_KR1AT' 'TIMEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL2'  'ZFH_KR1AT' 'NAMEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL2'  'ZFH_KR1AT' 'DATEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL2'  'ZFH_KR1AT' 'TIMEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL3'  'ZFH_KR1AT' 'NAMEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL3'  'ZFH_KR1AT' 'DATEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL3'  'ZFH_KR1AT' 'TIMEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL4'  'ZFH_KR1AT' 'NAMEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL4'  'ZFH_KR1AT' 'DATEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL4'  'ZFH_KR1AT' 'TIMEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL5'  'ZFH_KR1AT' 'NAMEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL5'  'ZFH_KR1AT' 'DATEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL5'  'ZFH_KR1AT' 'TIMEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS1'  'ZFH_KR1AT' 'NAMEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ1'    'ZFH_KR1AT' 'UMSKZ1'    'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' 'X' ''   ''            '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS1' 'ZFH_KR1AT' 'GJAHRPOS1' 'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS1'  'ZFH_KR1AT' 'DATEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS1'  'ZFH_KR1AT' 'TIMEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT1'    'ZFH_KR1AT' 'SGTXT1'    'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS2'  'ZFH_KR1AT' 'NAMEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ2'    'ZFH_KR1AT' 'UMSKZ2'    'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS2' 'ZFH_KR1AT' 'BELNRPOS2' 'X' ''   ''            '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS2' 'ZFH_KR1AT' 'GJAHRPOS2' 'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS2'  'ZFH_KR1AT' 'DATEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS2'  'ZFH_KR1AT' 'TIMEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT2'    'ZFH_KR1AT' 'SGTXT2'    'X' ''   ''            '' '' '' '' '' '' '' '' ''.

    WHEN radio4.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  '15' 'No.DO/CN'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ'     'BSID'      'UMSKZ'     ''  ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' ''.
* End insert unicode conversion - DEVK965979
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
FORM f_fieldcatg USING
                          value(fu_types)
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
                          value(fu_input).

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
  fu_layout-detail_popup       = 'X'.
  CASE 'X'.
    WHEN radio2 OR radio4.
      fu_layout-box_fieldname      = 'CHECK'.
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
    WHEN radio3.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NOFORM'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

    WHEN OTHERS.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'ZUONR'.
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
  DATA: ld_bulan(100).

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
  IF radio6 EQ 'X'.
    SELECT SINGLE bezei
      FROM tvkbt
      INTO wa_header-bezei
      WHERE spras EQ sy-langu AND
            vkbur EQ pa_vkbur.

    ld_bulan = so_dform-low+4(2).
    CALL FUNCTION 'ZMONTH_NAME'
      EXPORTING
        month = ld_bulan
      IMPORTING
        name  = ld_bulan.

    CONCATENATE 'BULAN : ' ld_bulan INTO ld_bulan SEPARATED BY space.
*--- Output line
    PERFORM f_hdr_pad_title1 USING wa_header-bezei '' ''.
    PERFORM f_hdr_pad_title1 USING ld_bulan '' 'FORM 1 B'.
    SKIP 1.
    PERFORM f_column_header.
  ENDIF.
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
  REFRESH: t_data.
  CLEAR: t_data.
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
  CASE 'X'.
    WHEN radio1.
      sy-title = 'Create Otorisasi FORM 3'.
      IF va_valid EQ 1.
        SET PF-STATUS 'TOPREV'.
      ELSE.
        SET PF-STATUS 'TOVALID'.
      ENDIF.
    WHEN radio2.
      sy-title = 'Koreksi FORM 3'.
      SET PF-STATUS 'TODELETE'.
    WHEN radio3.
      sy-title = 'FORM 3 Report'.
      SET PF-STATUS 'STANDARD'.
    WHEN radio4.
      sy-title = 'Status Pencairan'.
      IF va_status IS INITIAL.
        SET PF-STATUS 'TOEXEC'.
      ELSE.
        SET PF-STATUS 'STANDARD'.
      ENDIF.
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
  DATA: lv_kunnr  LIKE kna1-kunnr,
        lv_budat  LIKE bsid-budat,
        lv_gjahr  LIKE bsid-gjahr,
        lv_zfbdt  LIKE bsid-zfbdt,
        lv_zterm  LIKE bsid-zterm,
        lv_duedt  TYPE sy-datum.

  CASE 'X'.
    WHEN radio1.
      SORT t_data BY kunnr zuonr gjahr budat.
      SORT t_kna1 BY kunnr.
      SORT t_knkk BY kunnr.

      LOOP AT t_data.
        t_out-bukrs  = t_data-bukrs.
        t_out-gsber  = t_data-gsber.
        t_out-vkbur  = t_data-vkbur.

        t_out-kunnr = t_data-kunnr.
        lv_kunnr    = t_data-kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_data-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-name1 = t_kna1-name1.
        ENDIF.

        t_out-zuonr = t_data-zuonr.
        lv_budat    = t_data-budat.
        lv_gjahr    = t_data-gjahr.
        lv_zterm    = t_data-zterm.
        lv_zfbdt    = t_data-zfbdt.

        lv_duedt    = t_data-zfbdt + t_data-zbd1t.

        t_out-umskz  = t_data-umskz.

        AT NEW zuonr.
          READ TABLE t_knkk WITH KEY kunnr = lv_kunnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_out-klimk = t_knkk-klimk.
          ENDIF.
          t_out-budat = lv_budat.
          t_out-gjahr = lv_gjahr.
          t_out-zterm = lv_zterm.
          t_out-zfbdt = lv_zfbdt.
          t_out-duedt = lv_duedt.
          IF t_out-duedt LT sy-datum.
            t_out-icon = icon_alert.
            t_out-dd   = 'X'.
          ELSE.
            CLEAR: t_out-icon, t_out-dd.
          ENDIF.
        ENDAT.

        t_out-waers = t_data-waers.
        IF t_data-shkzg EQ 'H'.
          t_out-wrbtr = t_data-wrbtr * -1.
        ELSE.
          t_out-wrbtr = t_data-wrbtr.
        ENDIF.
        COLLECT t_out.
        CLEAR: t_out-klimk.
      ENDLOOP.

      SORT t_out BY zuonr.
      SORT t_data BY zuonr belnr.
      LOOP AT t_out.
        READ TABLE t_data WITH KEY zuonr = t_out-zuonr
                                   blart = 'RV'
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-belnr = t_data-belnr.
          t_out-bldat = t_data-bldat.
          MODIFY t_out TRANSPORTING belnr bldat.
        ELSE.
          READ TABLE t_data WITH KEY zuonr = t_out-zuonr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_out-belnr = t_data-belnr.
            t_out-bldat = t_data-bldat.
            MODIFY t_out TRANSPORTING belnr bldat.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN radio2.
      SORT t_zfh_kr1at BY kunnr.
      SORT t_kna1 BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_out-bukrs  = t_zfh_kr1at-bukrs.
        t_out-gsber  = t_zfh_kr1at-gsber.
        t_out-vkbur  = t_zfh_kr1at-vkbur.

        t_out-kunnr = t_zfh_kr1at-kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-name1 = t_kna1-name1.
        ENDIF.

        lv_duedt    = t_data-zfbdt + t_data-zbd1t.
        IF t_out-duedt LT sy-datum.
          t_out-icon = icon_alert.
          t_out-dd   = 'X'.
        ELSE.
          CLEAR: t_out-icon, t_out-dd.
        ENDIF.

        t_out-waers  = t_zfh_kr1at-waers.
        t_out-klimk  = t_zfh_kr1at-klimk.
        t_out-zuonr  = t_zfh_kr1at-zuonr.
        t_out-budat  = t_zfh_kr1at-budat.
        t_out-wrbtr  = t_zfh_kr1at-wrbtr.
        t_out-status = t_zfh_kr1at-status.
        t_out-zdesc1 = t_zfh_kr1at-zdesc1.
        t_out-belnr  = t_zfh_kr1at-belnr.
        t_out-gjahr  = t_zfh_kr1at-gjahr.
        t_out-umskz  = t_zfh_kr1at-umskz.
        APPEND t_out.
      ENDLOOP.

    WHEN radio3.
      SORT t_zfh_kr1at BY kunnr.
      SORT t_kna1 BY kunnr.
      LOOP AT t_zfh_kr1at.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_zfh_kr1at-name1 = t_kna1-name1.
          MODIFY t_zfh_kr1at TRANSPORTING name1.
        ENDIF.
      ENDLOOP.

    WHEN radio4.
      LOOP AT t_zfh_kr1at.
        t_out-kunnr = t_zfh_kr1at-kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-name1 = t_kna1-name1.
        ENDIF.
        t_out-bukrs    = t_zfh_kr1at-bukrs.
        t_out-gsber    = t_zfh_kr1at-gsber.
        t_out-vkbur    = t_zfh_kr1at-vkbur.
        t_out-noform   = t_zfh_kr1at-noform.
        t_out-klimk    = t_zfh_kr1at-klimk.
        t_out-waers    = t_zfh_kr1at-waers.
        t_out-zuonr    = t_zfh_kr1at-zuonr.
        t_out-budat    = t_zfh_kr1at-budat.
        t_out-wrbtr    = t_zfh_kr1at-wrbtr.
        t_out-status   = t_zfh_kr1at-status.
        t_out-zdesc1   = t_zfh_kr1at-zdesc1.
        t_out-zfbdt    = t_zfh_kr1at-zfbdt.
        t_out-zterm    = t_zfh_kr1at-zterm.
        t_out-belnr    = t_zfh_kr1at-belnr.
        t_out-gjahr    = t_zfh_kr1at-gjahr.
        t_out-umskz    = t_zfh_kr1at-umskz.
        IF t_zfh_kr1at-stsrel1 IS NOT INITIAL.
          t_out-stsrel1  = t_zfh_kr1at-stsrel1.
        ENDIF.
        IF t_zfh_kr1at-stsrel2 IS NOT INITIAL.
          t_out-stsrel2  = t_zfh_kr1at-stsrel2.
        ENDIF.
        IF t_zfh_kr1at-stsrel3 IS NOT INITIAL.
          t_out-stsrel3  = t_zfh_kr1at-stsrel3.
        ENDIF.
        IF t_zfh_kr1at-stsrel4 IS NOT INITIAL.
          t_out-stsrel4  = t_zfh_kr1at-stsrel4.
        ENDIF.
        IF t_zfh_kr1at-stsrel5 IS NOT INITIAL.
          t_out-stsrel5  = t_zfh_kr1at-stsrel5.
        ENDIF.
        APPEND t_out.
        CLEAR: t_out.
      ENDLOOP.

    WHEN radio5.
      SORT t_zfh_kr1at BY kunnr.
      SORT t_kna1 BY kunnr.
      LOOP AT t_zfh_kr1at.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_zfh_kr1at-name1 = t_kna1-name1.
          MODIFY t_zfh_kr1at TRANSPORTING name1.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE,
        lv_mess(100).

  DATA: lv_error TYPE i.

  REFRESH: lt_dynpread.

  CASE 'X'.
    WHEN radio1.
      CONCATENATE 'Data has been printed & saved. No FORM3' va_noform
      INTO lv_mess
      SEPARATED BY space.
    WHEN radio2.
      CONCATENATE 'Data has been printed & saved. No FORM3' pa_nform
      INTO lv_mess
      SEPARATED BY space.
  ENDCASE.

  CASE fu_ucomm.
    WHEN '&HLP'.
      CALL SCREEN 502 STARTING AT 10 10 ENDING AT 80 22.

    WHEN '&LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&POS'.
      PERFORM f_post_entries.
      PERFORM f_table_unlocking.

    WHEN '&PRE'.
      va_print = 0.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_validate_data CHANGING lv_error.
          IF lv_error IS INITIAL.
            PERFORM f_print_form.
            PERFORM f_table_unlocking.
          ENDIF.
          PERFORM f_alv TABLES t_out.
          LEAVE TO SCREEN 0.

        WHEN OTHERS.
          PERFORM f_print_form.
          PERFORM f_table_unlocking.
          PERFORM f_alv TABLES t_out.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&PRI'.
      va_print = 1.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_validate_data CHANGING lv_error.
          IF lv_error IS INITIAL.
            PERFORM f_print_form.
            MESSAGE s000(zab) WITH lv_mess.
            PERFORM f_table_unlocking.
            LEAVE TO SCREEN 0.
          ELSE.
            PERFORM f_alv TABLES t_out.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN OTHERS.
          PERFORM f_print_form.
          MESSAGE s000(zab) WITH lv_mess.
          PERFORM f_table_unlocking.
          LEAVE TO SCREEN 0.
      ENDCASE.


    WHEN '&VAL'.
      PERFORM f_validate_data CHANGING lv_error.
      PERFORM f_alv TABLES t_out.
      LEAVE TO SCREEN 0.

    WHEN '&ALS'.
      CALL SCREEN 502 STARTING AT 10 10 ENDING AT 80 22.

    WHEN '&DEL'.
      PERFORM f_delete_data.
      PERFORM f_alv TABLES t_out.
      LEAVE TO SCREEN 0.

    WHEN '&IC1'.
      CASE 'X'.
        WHEN radio1 OR radio2.
          CHECK NOT fu_selfield-tabindex IS INITIAL.
          READ TABLE t_out INDEX fu_selfield-tabindex.
          CASE fu_selfield-fieldname.
            WHEN 'BELNR'.
              SET PARAMETER ID 'BLN' FIELD t_out-belnr.
              SET PARAMETER ID 'BUK' FIELD t_out-bukrs.
              SET PARAMETER ID 'GJR' FIELD t_out-gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDCASE.

        WHEN radio3.
          CHECK NOT fu_selfield-tabindex IS INITIAL.
          READ TABLE t_zfh_kr1at INDEX fu_selfield-tabindex.
          CASE fu_selfield-fieldname.
            WHEN 'ZUONR'.
              IF t_zfh_kr1at-belnr IS NOT INITIAL.
                SET PARAMETER ID 'BLN' FIELD t_zfh_kr1at-belnr.
                SET PARAMETER ID 'BUK' FIELD t_zfh_kr1at-bukrs.
                SET PARAMETER ID 'GJR' FIELD t_zfh_kr1at-gjahr.
                CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
              ENDIF.
            WHEN 'BELNRPOS1'.
              IF t_zfh_kr1at-belnrpos1 IS NOT INITIAL.
                SET PARAMETER ID 'BLN' FIELD t_zfh_kr1at-belnrpos1.
                SET PARAMETER ID 'BUK' FIELD t_zfh_kr1at-bukrs.
                SET PARAMETER ID 'GJR' FIELD t_zfh_kr1at-gjahrpos1.
                CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
              ENDIF.
            WHEN 'BELNRPOS2'.
              IF t_zfh_kr1at-belnrpos2 IS NOT INITIAL.
                SET PARAMETER ID 'BLN' FIELD t_zfh_kr1at-belnrpos2.
                SET PARAMETER ID 'BUK' FIELD t_zfh_kr1at-bukrs.
                SET PARAMETER ID 'GJR' FIELD t_zfh_kr1at-gjahrpos2.
                CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
              ENDIF.
          ENDCASE.
      ENDCASE.
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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data CHANGING fc_error.
  DATA: lv_error   TYPE i,
        lv_switch  TYPE i,
        lv_rec1    TYPE i,
        lv_rec2    TYPE i,
        lv_zgroup  LIKE zfhstatus-zgroup,
        lv_zgroup1 LIKE zfhstatus-zgroup,
        lv_check   TYPE i,
        lv_umskz   TYPE bsid-umskz.

  DATA: BEGIN OF lt_zfbid OCCURS 0.
          INCLUDE STRUCTURE zfbid.
  DATA: END OF lt_zfbid.

  DATA: BEGIN OF lt_zfbicheck OCCURS 0.
          INCLUDE STRUCTURE zfbicheck.
  DATA: END OF lt_zfbicheck.

  DATA: BEGIN OF lt_zfbicheck1 OCCURS 0.
          INCLUDE STRUCTURE zfbicheck.
  DATA: END OF lt_zfbicheck1.

  DATA: BEGIN OF t_fourth OCCURS 0,
          bukrs   LIKE zfh_kr1at-bukrs,
          gsber   LIKE zfh_kr1at-gsber,
          vkbur   LIKE zfh_kr1at-vkbur,
          noform  LIKE zfh_kr1at-noform,
          zuonr   LIKE zfh_kr1at-zuonr,
          kunnr   LIKE zfh_kr1at-kunnr,
          status  LIKE zfh_kr1at-status.
  DATA: END OF t_fourth.

  DATA: ld_tanggal(8),
        ld_cekno  LIKE zfbicheck-cekno.
  CLEAR: t_error1, t_error2, t_error3.
  REFRESH: t_error1, t_error2, t_error3.

* first validate
  IF t_belnr[] IS NOT INITIAL.
    SELECT *
      FROM zfbid
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
      FOR ALL ENTRIES IN t_belnr
      WHERE bukrs EQ t_belnr-bukrs AND
            vkbur EQ t_belnr-vkbur AND
            vbeln EQ t_belnr-belnr AND
            zuonr EQ t_belnr-zuonr AND
            bflag EQ space.

    SORT lt_zfbid BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_zfbid COMPARING vbeln.

    SELECT *
      FROM zfbicheck
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbicheck
      FOR ALL ENTRIES IN t_belnr
      WHERE bukrs EQ t_belnr-bukrs AND
            vkbur EQ t_belnr-vkbur AND
            belnr EQ t_belnr-belnr AND
            zuonr EQ t_belnr-zuonr AND
            pcair EQ space.
  ENDIF.

  IF t_out[] IS NOT INITIAL.
    SELECT *
      FROM zfbicheck
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbicheck1
      FOR ALL ENTRIES IN t_out
      WHERE bukrs EQ t_out-bukrs AND
            vkbur EQ t_out-vkbur AND
            zuonr EQ t_out-zuonr.
  ENDIF.

  DESCRIBE TABLE t_out LINES lv_rec1.
  SORT t_out BY bukrs vkbur belnr zuonr.
  SORT lt_zfbid BY bukrs vkbur vbeln zuonr.
  SORT lt_zfbicheck BY bukrs vkbur belnr zuonr.
  SORT lt_zfbicheck1 BY bukrs vkbur belnr zuonr bbeln DESCENDING.

  LOOP AT t_out.
    READ TABLE lt_zfbicheck1 WITH KEY vkbur = t_out-vkbur
                                      zuonr = t_out-zuonr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF lt_zfbicheck1-pcair EQ 'B' OR
        lt_zfbicheck1-pcair EQ 'T'.
        CONCATENATE lt_zfbicheck1-duedt+6(2) lt_zfbicheck1-duedt+4(2)
                    lt_zfbicheck1-duedt(4)
        INTO ld_tanggal.
        ld_cekno  = lt_zfbicheck1-cekno.
        SHIFT ld_cekno LEFT DELETING LEADING '0'.
        CONCATENATE lt_zfbicheck1-bname ld_cekno '/' ld_tanggal '(' lt_zfbicheck1-pcair ')' INTO t_out-sgtxt3.
      ELSE.
        CLEAR: t_out-sgtxt3.
      ENDIF.
      MODIFY t_out TRANSPORTING sgtxt3.
    ENDIF.

    IF t_out-status IS INITIAL.
      CLEAR: t_out-zdesc1.
      MODIFY t_out TRANSPORTING zdesc1.
    ELSE.
      READ TABLE t_zfhstatus WITH KEY status = t_out-status
                                      bukrs  = gv_bukrs.
      IF sy-subrc EQ 0.
        IF lv_switch EQ 0.
          lv_switch = 1.
          lv_zgroup = t_zfhstatus-zgroup.
          t_out-error = icon_led_green.
        ENDIF.
        lv_zgroup1   = t_zfhstatus-zgroup.
        IF lv_zgroup1 NE lv_zgroup.
          lv_error = 4.
          t_error2-kunnr = t_out-kunnr.
          t_error2-zuonr = t_out-zuonr.
          t_error2-msg   = 'Status salah'.
          APPEND t_error2.
          t_out-zdesc1 = t_zfhstatus-zdesc1.
          t_out-umskz1 = t_zfhstatus-zgroup.
          t_out-error  = icon_led_red.
          MODIFY t_out TRANSPORTING error zdesc1 umskz1.
          CLEAR: t_zfhstatus-zdesc1, t_zfhstatus-zgroup.
        ELSE.
          t_out-zdesc1 = t_zfhstatus-zdesc1.
          t_out-umskz1 = t_zfhstatus-zgroup.
          t_out-error  = icon_led_green.
          MODIFY t_out TRANSPORTING error zdesc1 umskz1.
          CLEAR: t_zfhstatus-zdesc1, t_zfhstatus-zgroup.
        ENDIF.
      ELSE.
        lv_error = 4.
        t_error2-kunnr = t_out-kunnr.
        t_error2-zuonr = t_out-zuonr.
        t_error2-msg   = 'Status salah'.
        APPEND t_error2.
        t_out-zdesc1 = t_zfhstatus-zdesc1.
        t_out-umskz1 = t_zfhstatus-zgroup.
        t_out-error  = icon_led_red.
        MODIFY t_out TRANSPORTING error zdesc1 umskz1.
        CLEAR: t_zfhstatus-zdesc1, t_zfhstatus-zgroup.
      ENDIF.
    ENDIF.

    IF t_out-status IS INITIAL.
      ADD 1 TO lv_rec2.
      IF t_out-error IS NOT INITIAL.
        CLEAR: t_out-error.
        MODIFY t_out TRANSPORTING error.
      ENDIF.
    ELSE.
      READ TABLE lt_zfbid WITH KEY bukrs = t_out-bukrs
                                   vkbur = t_out-vkbur
                                   vbeln = t_out-belnr
                                   zuonr = t_out-zuonr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_error = 1.
        t_error3-kunnr = t_out-kunnr.
        t_error3-vbeln = lt_zfbid-vbeln.
        t_error3-bbeln = lt_zfbid-bbeln.
        t_error3-zuonr = lt_zfbid-zuonr.
        t_error3-msg   = 'Dokumen sudah ada di BI'.
        APPEND t_error3.
        t_out-error = icon_led_red.
      ELSE.
        READ TABLE lt_zfbicheck WITH KEY bukrs = t_out-bukrs
                                         vkbur = t_out-vkbur
                                         belnr = t_out-belnr
                                         zuonr = t_out-zuonr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_error = 1.
          t_error3-kunnr = t_out-kunnr.
          t_error3-vbeln = lt_zfbicheck-belnr.
          t_error3-bbeln = lt_zfbicheck-bbeln.
          t_error3-zuonr = lt_zfbicheck-zuonr.
          t_error3-msg   = 'Dokumen sudah ada di BI'.
          APPEND t_error3.
          t_out-error = icon_led_red.
        ELSE.
          lv_check = 1.
        ENDIF.
      ENDIF.
      MODIFY t_out TRANSPORTING error.
    ENDIF.
  ENDLOOP.

* second validate
  CLEAR: lt_zfbid, lt_zfbicheck.
  REFRESH: lt_zfbid, lt_zfbicheck.

  IF lv_check EQ 1.
*{   REPLACE        P01K910204                                        1
*\    SELECT *
*\      FROM zfbid
*\      INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
*\      FOR ALL ENTRIES IN t_belnr
*\      WHERE bukrs EQ t_belnr-bukrs AND
*\            vkbur EQ t_belnr-vkbur AND
*\            vbeln EQ t_belnr-belnr AND
*\            zuonr EQ t_belnr-zuonr AND
*\            bflag EQ 'E'           AND
*\            ptype IN ('P1', 'P2').
    "Start SOH: Shell SCI Adjustment 20240221 RZL
    SELECT *
      FROM zfbid
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
      FOR ALL ENTRIES IN t_belnr
      WHERE bukrs EQ t_belnr-bukrs AND
            vkbur EQ t_belnr-vkbur AND
            vbeln EQ t_belnr-belnr AND
            zuonr EQ t_belnr-zuonr AND
            bflag EQ 'E'           AND
            ptype IN ('P1', 'P2') ORDER BY PRIMARY KEY.
     "End SOH: Shell SCI Adjustment 20240221 RZL
*}   REPLACE

    LOOP AT t_out.
*{   INSERT         P01K910204                                        2
      "Start SOH: Shell SCI Adjustment 20240221 RZL
      SORT lt_zfbid by bukrs vkbur vbeln zuonr.
      "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
      READ TABLE lt_zfbid WITH KEY bukrs = t_out-bukrs
                                   vkbur = t_out-vkbur
                                   vbeln = t_out-belnr
                                   zuonr = t_out-zuonr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF t_out-status IS NOT INITIAL.
          lv_error = 1.
          t_error3-kunnr = t_out-kunnr.
          t_error3-vbeln = lt_zfbid-vbeln.
          t_error3-bbeln = lt_zfbid-bbeln.
          t_error3-zuonr = lt_zfbid-zuonr.
          t_error3-msg   = 'Dokumen sudah ada di BI'.
          APPEND t_error3.
          t_out-error = icon_led_red.
        ENDIF.
      ELSE.
        lv_check = 2.
        t_out4 = t_out.
        APPEND t_out4.
      ENDIF.
      MODIFY t_out TRANSPORTING error.
    ENDLOOP.
  ENDIF.

* third validate
  IF t_out4[] IS NOT INITIAL.
    PERFORM f_validate_bsid CHANGING lv_error.
  ENDIF.

  IF lv_rec1 = lv_rec2.
    lv_error = 2.
  ENDIF.

* fourth validate
  SELECT bukrs gsber vkbur noform zuonr kunnr status
    FROM zfh_kr1at
    INTO CORRESPONDING FIELDS OF TABLE t_fourth
    FOR ALL ENTRIES IN t_out
    WHERE bukrs EQ t_out-bukrs AND
          gsber EQ t_out-gsber AND
          vkbur EQ t_out-vkbur AND
          zuonr EQ t_out-zuonr AND
          kunnr EQ t_out-kunnr.
  SORT t_out BY bukrs gsber vkbur zuonr kunnr.
  SORT t_fourth BY bukrs gsber vkbur zuonr kunnr.
  LOOP AT t_out.
    READ TABLE t_fourth WITH KEY bukrs = t_out-bukrs
                                 gsber = t_out-gsber
                                 vkbur = t_out-vkbur
                                 zuonr = t_out-zuonr
                                 kunnr = t_out-kunnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE t_zfhstatus WITH KEY status = t_out-status
                                      bukrs  = gv_bukrs.
      IF sy-subrc EQ 0.
        IF t_zfhstatus-zflag IS INITIAL.
          IF t_fourth-status = 'Z'.
            t_out-error  = icon_led_green.
            MODIFY t_out TRANSPORTING error.
          ELSEIF t_out-status <> t_fourth-status.
            t_out-error  = icon_led_green.
            MODIFY t_out TRANSPORTING error.
          ELSE.
            lv_error = 4.
            t_error2-kunnr = t_out-kunnr.
            t_error2-zuonr = t_out-zuonr.
            t_error2-msg   = 'Alasan salah'.
            APPEND t_error2.
            t_out-error  = icon_led_red.
            MODIFY t_out TRANSPORTING error.
          ENDIF.
        ELSE.
          t_out-error  = icon_led_green.
          MODIFY t_out TRANSPORTING error.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* fifth validate
  CLEAR: lv_switch.
  LOOP AT t_out WHERE status IS NOT INITIAL.
    IF lv_switch IS INITIAL.
      lv_switch = 1.
    ELSE.
      IF t_out-umskz NE lv_umskz.
        lv_error = 5.
        CONTINUE.
      ENDIF.
    ENDIF.
    lv_umskz  = t_out-umskz.
  ENDLOOP.
  IF lv_error EQ 5.
    LOOP AT t_out WHERE status IS NOT INITIAL.
      lv_error = 5.
      t_error2-kunnr = t_out-kunnr.
      t_error2-zuonr = t_out-zuonr.
      t_error2-msg   = 'Beda Special G/L Indicator'.
      APPEND t_error2.
      t_out-error  = icon_led_red.
      MODIFY t_out TRANSPORTING error.
    ENDLOOP.
  ENDIF.

  IF lv_error IS INITIAL.
    va_valid = 1.
  ELSE.
    CASE lv_error.
      WHEN 1.
        MESSAGE i000(zab) WITH 'Dokumen sudah ada di BI'.
      WHEN 2.
        MESSAGE i000(zab) WITH 'No data to be processed'.
      WHEN 3.
        MESSAGE i000(zab) WITH 'Nilai dokumen tidak sama'.
      WHEN 4.
        MESSAGE i000(zab) WITH 'Alasan salah'.
      WHEN 5.
        MESSAGE i000(zab) WITH 'Beda Special G/L Indicator'.
    ENDCASE.
  ENDIF.

  fc_error = lv_error.
ENDFORM.                    " f_validate_data

*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form .
  DATA: lv_noform LIKE zfhnoform3-noform,
        lv_nou    LIKE zfhstblokd-nou.

  IF va_print EQ 1.
    p_disp = space.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  d_output_opt-tdnoprint = p_disp.

  SELECT SINGLE padest
    FROM tsp03l
    INTO va_spld
    WHERE lname = p_dest.
  d_output_opt-tddest    = va_spld.

  CASE 'X'.
    WHEN radio1.
      REFRESH: t_zfh_kr1at, t_out1.
      CLEAR: t_zfh_kr1at, t_out1.
      lv_noform = t_zfhnoform3-noform.
      LOOP AT t_out WHERE zdesc1 NE space.
        ADD 1 TO lv_nou.
        t_zfh_kr1at-bukrs   = t_out-bukrs.
        t_zfh_kr1at-gsber   = t_out-gsber.
        t_zfh_kr1at-vkbur   = t_out-vkbur.
        t_zfh_kr1at-noform  = lv_noform.
        t_zfh_kr1at-zuonr   = t_out-zuonr.
        t_zfh_kr1at-umskz   = t_out-umskz.
        t_zfh_kr1at-dtform  = sy-datum.
        t_zfh_kr1at-umskz1  = t_out-umskz1.
        t_zfh_kr1at-kunnr   = t_out-kunnr.
        t_zfh_kr1at-gjahr   = t_out-gjahr.
        t_zfh_kr1at-bldat   = t_out-bldat.
        t_zfh_kr1at-belnr   = t_out-belnr.
        t_zfh_kr1at-budat   = t_out-budat.
        t_zfh_kr1at-zfbdt   = t_out-zfbdt.
        t_zfh_kr1at-zterm   = t_out-zterm.
        t_zfh_kr1at-waers   = t_out-waers.
        t_zfh_kr1at-wrbtr   = t_out-wrbtr.
        t_zfh_kr1at-klimk   = t_out-klimk.
        t_zfh_kr1at-status  = t_out-status.
        t_zfh_kr1at-zdesc1  = t_out-zdesc1.
        t_zfh_kr1at-usnam   = sy-uname.
        t_zfh_kr1at-utime   = sy-uzeit.
        t_zfh_kr1at-sgtxt3  = t_out-sgtxt3.
        APPEND t_zfh_kr1at.

        t_out1 = t_out.
        t_out1-nou = lv_nou.
        APPEND t_out1.
      ENDLOOP.

    WHEN radio2.
      va_reprint = 'X'.
      lv_noform  = pa_nform.
      SORT t_zfh_kr1at BY bukrs gsber vkbur zuonr.
      SORT t_out BY bukrs gsber vkbur zuonr.
      LOOP AT t_zfh_kr1at.
        READ TABLE t_out WITH KEY bukrs  = t_zfh_kr1at-bukrs
                                  gsber  = t_zfh_kr1at-gsber
                                  vkbur  = t_zfh_kr1at-vkbur
                                  zuonr  = t_zfh_kr1at-zuonr
        BINARY SEARCH.
        IF sy-subrc NE 0.
          t_zfh_kr1at_del = t_zfh_kr1at.
          APPEND t_zfh_kr1at_del.
          CLEAR: t_zfh_kr1at-noform, t_zfh_kr1at-status, t_zfh_kr1at-zdesc1,
                 t_zfh_kr1at-usnam, t_zfh_kr1at-utime.
          MODIFY t_zfh_kr1at TRANSPORTING noform status zdesc1 usnam utime.
        ELSE.
          ADD 1 TO lv_nou.
          t_out-nou = lv_nou.
          MODIFY t_out INDEX sy-tabix TRANSPORTING nou .
        ENDIF.
      ENDLOOP.
      t_out1[] = t_out[].
  ENDCASE.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO wa_header-bezei
    WHERE spras EQ sy-langu AND
          vkbur EQ pa_vkbur.

  SELECT SINGLE gtext
    FROM tgsbt
    INTO wa_header-gtext
    WHERE spras EQ sy-langu AND
          gsber EQ gv_gsber.

  PERFORM f_read_text USING 'ZF_BLOK_AR'
                      CHANGING wa_header-lampiran.

  wa_header-vkbur  = pa_vkbur.
  wa_header-noform = lv_noform.

  IF d_frm_subrc IS INITIAL.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters   = d_ctrl_param
        output_options       = d_output_opt
        user_settings        = space
        wa_header            = wa_header
        va_reprint           = va_reprint
      IMPORTING
        document_output_info = document_output_info
        job_output_info      = job_output_info
        job_output_options   = job_output_options
      TABLES
        t_out1               = t_out1
        t_out2               = t_out2
        t_zfusrrel_form3x    = t_zfusrrel_form3x.
  ENDIF.

  IF job_output_info-spoolids IS NOT INITIAL.
    PERFORM f_save_data ON COMMIT.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_print_form

*&---------------------------------------------------------------------*
*&      Form  f_save_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_data .
  CASE 'X'.
    WHEN radio1.
      INSERT zfh_kr1at FROM TABLE t_zfh_kr1at.

      IF t_zfhnoform3-noform EQ 1.
        INSERT zfhnoform3 FROM t_zfhnoform3.
      ELSE.
        UPDATE zfhnoform3 FROM t_zfhnoform3.
      ENDIF.

    WHEN radio2.
      LOOP AT t_zfh_kr1at_del.
        DELETE zfh_kr1at FROM t_zfh_kr1at_del.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_save_data

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mess(50) VALUE 'Make an entry in all required fields'.

  IF pa_vkbur IS INITIAL.
    va_error  = 1.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'VKB'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF p_dest IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'DST'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ENDIF.

    WHEN radio2.
      IF pa_nform IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'NFO'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ENDIF.

    WHEN radio5.
      IF pa_nform IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'NFO'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ENDIF.

    WHEN radio6.
      IF so_dform[] IS INITIAL.
        va_error  = 1.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'DTF'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ELSE.
        IF so_dform-high IS NOT INITIAL.
          IF so_dform-high+4(2) NE so_dform-low+4(2).
            va_error  = 1.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'DTF'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'Harus dalam period yang sama'.
            CLEAR: sscrfields-ucomm.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        IF screen-group1 = 'DTF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFR'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        IF screen-group1 = 'DTF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFR'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio3.
      LOOP AT SCREEN.
        IF screen-group1 = 'DTF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DST'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio4.
      LOOP AT SCREEN.
        IF screen-group1 = 'DTF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DST'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio5.
      LOOP AT SCREEN.
        IF screen-group1 = 'DTF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KUN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZUO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NFR'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio6.
      LOOP AT SCREEN.
        IF screen-group1 = 'NFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DST'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_modify_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_delete_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_data .
  LOOP AT t_out WHERE check EQ 'X'.
    DELETE t_out.
  ENDLOOP.
ENDFORM.                    " f_delete_data

*&---------------------------------------------------------------------*
*&      Form  f_table_locking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_locking .
  DATA: lw_data       LIKE t_data,
        lw_zfh_kr1at  LIKE t_zfh_kr1at,
        ld_user       LIKE sy-uname,
        ld_msg(100),
        ld_subrc      LIKE sy-subrc.

  CASE 'X'.
    WHEN radio1.
      LOOP AT t_data INTO lw_data.
        CALL FUNCTION 'ENQUEUE_EFVIBSID'
          EXPORTING
            mode_bsid      = 'E'
            mandt          = sy-mandt
            bukrs          = lw_data-bukrs
            kunnr          = lw_data-kunnr
            zuonr          = lw_data-zuonr
            gjahr          = lw_data-gjahr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc NE 0.
          va_lock  = 1.
          ld_user  = sy-msgv1.
          ld_subrc = sy-subrc.
          PERFORM f_error_log_bsid USING lw_data
                                         ld_user
                                         ld_subrc.
          DELETE t_data.
        ELSE.
          CLEAR t_knvv.
          READ TABLE t_knvv WITH KEY kunnr = lw_data-kunnr
                                     usrgroup = 'PD'.
          IF sy-subrc = 0 AND t_knvv-kvgr4 IS NOT INITIAL.
            va_lock  = 1.
            ld_msg  = 'Customer tersebut termasuk key Account'.
            ld_subrc = 1.
            PERFORM f_error_log_bsid USING lw_data
                                           ld_msg
                                           ld_subrc.
            DELETE t_data.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN radio2 OR radio4.
      LOOP AT t_zfh_kr1at INTO lw_zfh_kr1at.
        CALL FUNCTION 'ENQUEUE_EZFH_KR1AT'
          EXPORTING
            mode_zfh_kr1at = 'X'
            mandt          = sy-mandt
            bukrs          = lw_zfh_kr1at-bukrs
            gsber          = lw_zfh_kr1at-gsber
            vkbur          = lw_zfh_kr1at-vkbur
            noform         = lw_zfh_kr1at-noform
            zuonr          = lw_zfh_kr1at-zuonr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc NE 0.
          va_lock  = 1.
          ld_user  = sy-msgv1.
          ld_subrc = sy-subrc.
          PERFORM f_error_log_zfh_kr1at USING lw_zfh_kr1at
                                              ld_user
                                              ld_subrc.
          DELETE t_zfh_kr1at.
        ELSE.
          CLEAR t_knvv.
          READ TABLE t_knvv WITH KEY kunnr = lw_zfh_kr1at-kunnr
                                     usrgroup = 'PD'.
          IF sy-subrc = 0 AND t_knvv-kvgr4 IS NOT INITIAL.
            va_lock  = 1.
            ld_msg  = 'Customer tersebut termasuk key Account'.
            ld_subrc = 1.
            PERFORM f_error_log_zfh_kr1at USING lw_zfh_kr1at
                                                ld_msg
                                                ld_subrc.
            DELETE t_zfh_kr1at.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_table_locking

*&---------------------------------------------------------------------*
*&      Form  f_error_log_bsid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_DATA  text
*      -->P_LD_USER  text
*      -->P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM f_error_log_bsid USING fu_data LIKE t_data
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
ENDFORM.                    " f_error_log_bsid

*&---------------------------------------------------------------------*
*&      Form  f_table_unlocking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_unlocking .
  CASE 'X'.
    WHEN radio1.
      LOOP AT t_data.
        CALL FUNCTION 'DEQUEUE_EFVIBSID'
          EXPORTING
            mode_bsid = 'E'
            mandt     = sy-mandt
            bukrs     = t_data-bukrs
            kunnr     = t_data-kunnr
            zuonr     = t_data-zuonr
            gjahr     = t_data-gjahr.
      ENDLOOP.

    WHEN radio2 OR radio4.
      LOOP AT t_out.
        CLEAR: t_out-check.
        MODIFY t_out TRANSPORTING check.
      ENDLOOP.

      LOOP AT t_zfh_kr1at.
        CALL FUNCTION 'DEQUEUE_EZFH_KR1AT'
          EXPORTING
            mode_zfh_kr1at = 'X'
            mandt          = sy-mandt
            bukrs          = t_zfh_kr1at-bukrs
            gsber          = t_zfh_kr1at-gsber
            vkbur          = t_zfh_kr1at-vkbur
            noform         = t_zfh_kr1at-noform
            zuonr          = t_zfh_kr1at-zuonr.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_table_unlocking

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
FORM f_error_list .
  CASE 'X'.
    WHEN radio1.
      IF t_error1[] IS INITIAL OR
        t_error2[] IS NOT INITIAL OR
        t_error3[] IS INITIAL.
        SKIP 1.
        WRITE: /13 'No error occurs'.
      ENDIF.

      IF t_error1[] IS NOT INITIAL.
        ULINE AT /(77).
        WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
                  sy-vline NO-GAP, (40) 'User' NO-GAP,
                  sy-vline.
        ULINE AT /(77).
        LOOP AT t_error1.
          WRITE: /  sy-vline NO-GAP, (15) t_error1-kunnr NO-GAP,
                    sy-vline NO-GAP, t_error1-zuonr NO-GAP,
                    sy-vline NO-GAP, t_error1-msg(40) NO-GAP,
                    sy-vline NO-GAP.
        ENDLOOP.
        ULINE AT /(77).
      ENDIF.

      IF t_error2[] IS NOT INITIAL.
        ULINE AT /(77).
        WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
                  sy-vline NO-GAP, (40) 'User' NO-GAP,
                  sy-vline.
        ULINE AT /(77).
        LOOP AT t_error2.
          WRITE: /  sy-vline NO-GAP, (15) t_error2-kunnr NO-GAP,
                    sy-vline NO-GAP, t_error2-zuonr NO-GAP,
                    sy-vline NO-GAP, t_error2-msg(40) NO-GAP,
                    sy-vline NO-GAP.
        ENDLOOP.
        ULINE AT /(77).
      ENDIF.

      IF t_error3[] IS NOT INITIAL.
        ULINE AT /(115).
        WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor Billing' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor DN' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor BI' NO-GAP,
                  sy-vline NO-GAP, (40) 'Message' NO-GAP,
                  sy-vline.
        ULINE AT /(115).
        LOOP AT t_error3.
          WRITE: /  sy-vline NO-GAP, (15) t_error3-kunnr NO-GAP,
                    sy-vline NO-GAP, (18) t_error3-vbeln NO-GAP,
                    sy-vline NO-GAP, (18) t_error3-zuonr NO-GAP,
                    sy-vline NO-GAP, (18) t_error3-bbeln NO-GAP,
                    sy-vline NO-GAP, t_error3-msg(40) NO-GAP,
                    sy-vline NO-GAP.
        ENDLOOP.
        ULINE AT /(115).
      ENDIF.

    WHEN radio2 OR radio4.
      IF t_error2[] IS INITIAL.
        SKIP 1.
        WRITE: /13 'No error occurs'.
      ELSE.
        ULINE AT /(77).
        WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
                  sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
                  sy-vline NO-GAP, (40) 'User' NO-GAP,
                  sy-vline.
        ULINE AT /(77).
        LOOP AT t_error2.
          WRITE: /  sy-vline NO-GAP, (15) t_error2-kunnr NO-GAP,
                    sy-vline NO-GAP, t_error2-zuonr NO-GAP,
                    sy-vline NO-GAP, t_error2-msg(40) NO-GAP,
                    sy-vline NO-GAP.
        ENDLOOP.
        ULINE AT /(67).
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_error_list

*&---------------------------------------------------------------------*
*&      Form  f_error_log_zfh_kr1at
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_ZFH_KR1AT  text
*      -->P_LD_USER  text
*      -->P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM f_error_log_zfh_kr1at USING fu_data LIKE t_zfh_kr1at
                                 fu_user
                                 fu_subrc.

  IF fu_subrc EQ 1.
    MOVE-CORRESPONDING fu_data TO t_error2.
    t_error2-msg = fu_user.
    APPEND t_error2.
  ELSE.
    MOVE-CORRESPONDING fu_data TO t_error2.
    t_error2-msg = 'Error when processing'.
    APPEND t_error2.
  ENDIF.
ENDFORM.                    " f_error_log_zfh_kr1at

*&---------------------------------------------------------------------*
*&      Form  f_le_zero
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_le_zero .
  CASE 'X'.
    WHEN radio1.
      LOOP AT t_out.
        IF t_out-wrbtr LE 0.
          DELETE t_out.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_le_zero

*&---------------------------------------------------------------------*
*&      Module  status_0502  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0502 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " status_0502  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  list_processing_0502  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0502 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_f4_help.
ENDMODULE.                 " list_processing_0502  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  f_f4_help
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_f4_help .
  DATA: lv_count TYPE i.

  CASE 'X'.
    WHEN radio1.
      SKIP 1.
      WRITE: / 'Status Dokumen'.
      ULINE AT /(39).
      FORMAT COLOR 1.
      WRITE: /  sy-vline NO-GAP, 'Status' NO-GAP,
                sy-vline NO-GAP, (30) 'Description' NO-GAP,
                sy-vline.
      FORMAT COLOR OFF.
      ULINE AT /(39).
      FORMAT COLOR 2.
      LOOP AT t_zfhstatus.
        IF lv_count = 0.
          lv_count = 1.
          FORMAT INTENSIFIED OFF.
        ELSE.
          lv_count = 0.
          FORMAT INTENSIFIED ON.
        ENDIF.

        WRITE: /  sy-vline NO-GAP, (6) t_zfhstatus-status CENTERED NO-GAP,
                  sy-vline NO-GAP, (30) t_zfhstatus-zdesc1 NO-GAP,
                  sy-vline NO-GAP.
      ENDLOOP.
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      ULINE AT /(39).
  ENDCASE.
ENDFORM.                                                    " f_f4_help

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries .
  IF t_out[] IS INITIAL.
    MESSAGE i000(zab) WITH 'No data to be processed'.
  ELSE.
    PERFORM f_update_zfh_kr1at ON COMMIT.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE s000(zab) WITH 'Usulan Pencairan KR1A Success'.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.
  LEAVE TO SCREEN 0.
ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  f_update_zfh_kr1at
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_zfh_kr1at .
  DATA: BEGIN OF lt_zfh_kr1at OCCURS 0.
          INCLUDE STRUCTURE zfh_kr1at.
  DATA: END OF lt_zfh_kr1at.

  SORT t_out BY bukrs gsber vkbur noform zuonr.
  SORT t_zfh_kr1at BY bukrs gsber vkbur noform zuonr.
  LOOP AT t_out WHERE check EQ 'X'.
    READ TABLE t_zfh_kr1at WITH KEY bukrs  = t_out-bukrs
                                    gsber  = t_out-gsber
                                    vkbur  = t_out-vkbur
                                    noform = t_out-noform
                                    zuonr  = t_out-zuonr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_zfh_kr1at-stsrel5  = 1.
      t_zfh_kr1at-namerel5 = sy-uname.
      t_zfh_kr1at-daterel5 = sy-datum.
      t_zfh_kr1at-timerel5 = sy-uzeit.
      MODIFY t_zfh_kr1at TRANSPORTING stsrel5 namerel5 daterel5 timerel5
        WHERE bukrs  EQ t_out-bukrs  AND
              gsber  EQ t_out-gsber  AND
              vkbur  EQ t_out-vkbur  AND
              noform EQ t_out-noform AND
              zuonr  EQ t_out-zuonr.

      lt_zfh_kr1at = t_zfh_kr1at.
      APPEND lt_zfh_kr1at.
    ENDIF.
    CLEAR: t_zfh_kr1at.
  ENDLOOP.

  UPDATE zfh_kr1at FROM TABLE lt_zfh_kr1at.
ENDFORM.                    " f_update_zfh_kr1at

*&---------------------------------------------------------------------*
*&      Form  f_reprint_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reprint_form .
  DATA: lv_noform   LIKE zfhnoform3-noform,
        lv_nou1     LIKE zfhstblokd-nou,
        lv_nou2     LIKE zfhstblokd-nou,
        lv_count    TYPE i,
        lv_lines    TYPE i,
        lv_lines_m  TYPE i,
        lv_switch   TYPE i.

  IF va_print EQ 1.
    p_disp = space.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  d_output_opt-tdnoprint = p_disp.

  SELECT SINGLE padest
    FROM tsp03l
    INTO va_spld
    WHERE lname = p_dest.
  d_output_opt-tddest    = va_spld.

  REFRESH: t_out1, t_out2.
  CLEAR: t_out1, t_out2.
  lv_noform = t_zfhnoform3-noform.
  LOOP AT t_zfh_kr1at.
    ADD 1 TO lv_nou1.
    t_out1-kunnr  = t_zfh_kr1at-kunnr.
    t_out1-name1  = t_zfh_kr1at-name1.
    t_out1-waers  = t_zfh_kr1at-waers.
    t_out1-klimk  = t_zfh_kr1at-klimk.
    t_out1-zuonr  = t_zfh_kr1at-zuonr.
    t_out1-budat  = t_zfh_kr1at-budat.
    t_out1-wrbtr  = t_zfh_kr1at-wrbtr.
    t_out1-zdesc1 = t_zfh_kr1at-zdesc1.
    t_out1-status = t_zfh_kr1at-status.
    t_out1-sgtxt3 = t_zfh_kr1at-sgtxt3.
    t_out1-nou    = lv_nou1.
    APPEND t_out1.
    IF t_zfh_kr1at-stsrel5 IS NOT INITIAL OR
      t_zfh_kr1at-belnrpos2 IS NOT INITIAL.
      t_out2 = t_out1.
      ADD 1 TO lv_nou2.
      t_out2-nou = lv_nou2.
      APPEND t_out2.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE t_out2 LINES lv_lines.
  lv_lines_m = lv_lines MOD 5.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO wa_header-bezei
    WHERE spras EQ sy-langu AND
          vkbur EQ pa_vkbur.

  SELECT SINGLE gtext
    FROM tgsbt
    INTO wa_header-gtext
    WHERE spras EQ sy-langu AND
          gsber EQ gv_gsber.

  PERFORM f_read_text USING 'ZF_BLOK_AR'
                      CHANGING wa_header-lampiran.

  wa_header-vkbur  = pa_vkbur.
  wa_header-noform = pa_nform.

  IF d_frm_subrc IS INITIAL.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters   = d_ctrl_param
        output_options       = d_output_opt
        user_settings        = space
        wa_header            = wa_header
        va_reprint           = va_reprint
      IMPORTING
        document_output_info = document_output_info
        job_output_info      = job_output_info
        job_output_options   = job_output_options
      TABLES
        t_out1               = t_out1
        t_out2               = t_out2
        t_zfusrrel_form3x    = t_zfusrrel_form3x.
  ENDIF.
ENDFORM.                    " f_reprint_form

**&---------------------------------------------------------------------*
**&      Form  f_move_table
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM f_move_table USING ft_in LIKE t_out1
*                  CHANGING ft_out LIKE t_out3.
*
*  ft_out-nou       = ft_in-nou.
*  ft_out-kunnr     = ft_in-kunnr.
*  ft_out-name1     = ft_in-name1.
*  WRITE ft_in-klimk TO ft_out-klimk CURRENCY 'IDR'.
*  ft_out-waers     = ft_in-waers.
*  ft_out-zuonr     = ft_in-zuonr.
*  ft_out-budat     = ft_in-budat.
*  WRITE ft_in-wrbtr TO ft_out-wrbtr CURRENCY 'IDR'.
*  ft_out-status    = ft_in-status.
*  ft_out-zdesc1    = ft_in-zdesc1.
*  ft_out-bukrs     = ft_in-bukrs.
*  ft_out-gsber     = ft_in-gsber.
*  ft_out-vkbur     = ft_in-vkbur.
*  ft_out-gjahr     = ft_in-gjahr.
*  ft_out-bldat     = ft_in-bldat.
*  ft_out-zfbdt     = ft_in-zfbdt.
*  ft_out-zterm     = ft_in-zterm.
*  ft_out-belnr     = ft_in-belnr.
*  ft_out-dd        = ft_in-dd.
*  ft_out-belnrpos1 = ft_in-belnrpos1.
*ENDFORM.                    " f_move_table

*&---------------------------------------------------------------------*
*&      Form  f_validate_bsid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_bsid CHANGING fc_error.
  DATA: BEGIN OF lt_data OCCURS 0.
          INCLUDE STRUCTURE t_data.
  DATA: END OF lt_data.

  DATA: BEGIN OF lt_out OCCURS 0.
          INCLUDE STRUCTURE t_out.
  DATA: END OF lt_out.

  SELECT a~bukrs a~kunnr a~zuonr a~gjahr a~belnr a~buzei a~budat a~bldat
         a~waers a~xblnr a~monat a~shkzg a~gsber a~wrbtr a~hkont a~zfbdt
         a~zterm a~zbd1t a~zlspr a~vbund a~xref1 a~xref2 a~xref3 a~blart
         b~vkbur b~spart
    INTO CORRESPONDING FIELDS OF TABLE lt_data
    FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
    FOR ALL ENTRIES IN t_out4
        WHERE a~bukrs EQ t_out4-bukrs    AND
              a~kunnr EQ t_out4-kunnr    AND
              a~zuonr EQ t_out4-zuonr    AND
              a~zlspr IN (space,'Z','B') AND
              a~blart IN ra_blart        AND
              a~umskz EQ space           AND
              b~vkorg EQ t_out4-bukrs    AND
              b~vtweg EQ '10'            AND
              b~vkbur EQ t_out4-vkbur.

  SORT lt_data BY kunnr zuonr gjahr.
  LOOP AT lt_data.
    lt_out-bukrs = lt_data-bukrs.
    lt_out-gsber = lt_data-gsber.
    lt_out-vkbur = lt_data-vkbur.
    lt_out-kunnr = lt_data-kunnr.
    lt_out-zuonr = lt_data-zuonr.
    lt_out-waers = lt_data-waers.
    IF lt_data-shkzg EQ 'H'.
      lt_out-wrbtr = lt_data-wrbtr * -1.
    ELSE.
      lt_out-wrbtr = lt_data-wrbtr.
    ENDIF.
    COLLECT lt_out.
  ENDLOOP.

  SORT t_out BY kunnr zuonr.
  SORT lt_out BY kunnr zuonr.

  LOOP AT t_out.
    READ TABLE lt_out WITH KEY kunnr = t_out-kunnr
                               zuonr = t_out-zuonr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF t_out-wrbtr NE lt_out-wrbtr.
        fc_error = 3.
        t_error1-kunnr = t_out-kunnr.
        t_error1-zuonr = t_out-zuonr.
        t_error1-msg   = 'Nilai dokumen tidak sama'.
        APPEND t_error1.
        t_out-error = icon_led_red.
      ELSE.
        IF t_out-error EQ icon_led_red.
          IF t_out-status IS INITIAL AND
            t_out-zdesc1 IS INITIAL.
            CLEAR: t_out-error.
          ELSE.
            t_out-error = icon_led_red.
          ENDIF.
        ELSE.
          IF t_out-zdesc1 IS INITIAL.
            CLEAR: t_out-error.
          ELSE.
            t_out-error = icon_led_green.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY t_out TRANSPORTING error.
  ENDLOOP.
ENDFORM.                    " f_validate_bsid

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE1
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title1 USING v_left_text v_middle_text v_right_text.

  DATA: page_width TYPE i,       " Width of page
        middle_length TYPE i,    " Length of title text
        left_length TYPE i,      " Length of left text
        right_length TYPE i,     " Length of right text
        left_start TYPE i,       " Position on line for start of left tex
        middle_start TYPE i,     " Position on line for start of middl tex
        right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = STRLEN( v_middle_text ).
  COMPUTE left_length = STRLEN( v_left_text ).
  COMPUTE right_length = STRLEN( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ space.
*--- Insert texts
  IF left_length <> 0.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
  ENDIF.
  WRITE AT sy-linsz space.
ENDFORM.                    " F_HDR_PAD_TITLE1

*&---------------------------------------------------------------------*
*&      Form  f_column_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_column_header .
  WRITE: / sy-uline.

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c9) space CENTERED. WRITE sy-vline.
  WRITE AT (66) 'Status' CENTERED. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c9) 'Alasan Pengajuan Block A/R (beri tanda"V")' CENTERED. WRITE sy-vline.
  WRITE: 187 sy-uline(70).

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c9) space CENTERED. WRITE sy-vline.
  WRITE AT (30) 'Telah Diselesaikan' CENTERED. WRITE sy-vline.
  WRITE AT (33) 'Belum Terselesaikan' CENTERED. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE AT (c2) 'No.' CENTERED. WRITE sy-vline.
  WRITE AT (c3) 'Nama Outlet' CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'Jenis' CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'Tanggal' CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'Tanggal' CENTERED. WRITE sy-vline.
  WRITE AT (c6) 'Jumlah' CENTERED. WRITE sy-vline.
  WRITE: 90 sy-uline(167).

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'Outlet' CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'DN/FAKTUR' CENTERED. WRITE sy-vline.
  WRITE AT (c4) 'Block A/R' CENTERED. WRITE sy-vline.
  WRITE AT (c6) '(Rp.)' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( A )' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( B )' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( C )' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( D )' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( G )' CENTERED. WRITE sy-vline.
  WRITE AT (c7) '( H )' CENTERED. WRITE sy-vline.
  WRITE AT (c5) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c8) space CENTERED. WRITE sy-vline.
  WRITE AT (c5) 'Rencana' CENTERED. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Manipulasi' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Pemilik' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Outlet' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'SSP ALL' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'SSP PPN' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'SSP PPh' CENTERED. WRITE sy-vline.
  WRITE AT (c5) 'Tanggal' CENTERED. WRITE sy-vline.
  WRITE AT (c6) 'Jumlah' CENTERED. WRITE sy-vline.
  WRITE AT (c8) 'Alasan belum' CENTERED. WRITE sy-vline.
  WRITE AT (c5) 'penyelesaian' CENTERED. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Salesman' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Meninggal' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Kebakaran' CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c5) 'Penyelesaian' CENTERED. WRITE sy-vline.
  WRITE AT (c6) '(Rp.)' CENTERED. WRITE sy-vline.
  WRITE AT (c8) 'terselesaikan' CENTERED. WRITE sy-vline.
  WRITE AT (c5) '(sebutkan' CENTERED. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE AT (c2) space CENTERED. WRITE sy-vline.
  WRITE AT (c3) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c4) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) '/ Karyawan' CENTERED. WRITE sy-vline.
  WRITE AT (c7) 'Dunia' CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c7) space CENTERED. WRITE sy-vline.
  WRITE AT (c5) space CENTERED. WRITE sy-vline.
  WRITE AT (c6) space CENTERED. WRITE sy-vline.
  WRITE AT (c8) space CENTERED. WRITE sy-vline.
  WRITE AT (c5) 'tanggal)' CENTERED. WRITE sy-vline.

  WRITE: / sy-uline.
ENDFORM.                    " f_column_header

*&---------------------------------------------------------------------*
*&      Form  f_print_data_radio6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data_radio6 .
  DATA: ld_lines  TYPE i,
        ld_mod    TYPE i,
        ld_nou    TYPE i,
        ld_page   TYPE i,
        ld_bezei  LIKE tvv3t-bezei.

  DESCRIBE TABLE t_zfh_kr1at LINES ld_lines.
  ld_mod = ld_lines MOD 20.

  LOOP AT t_zfh_kr1at.
    ADD 1 TO ld_nou.
    ADD 1 TO ld_page.

    READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_zfh_kr1at-name1 = t_kna1-name1.
    ENDIF.

*{   INSERT         P01K910204                                        1
    "Start SOH: Shell SCI Adjustment 20240221 RZL
    SORT t_knvv by kunnr.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
    READ TABLE t_knvv WITH KEY kunnr = t_zfh_kr1at-kunnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      ld_bezei = t_knvv-bezei.
    ELSE.
      CLEAR: ld_bezei.
    ENDIF.

    WRITE: / sy-vline.
    WRITE AT (c2) ld_nou. WRITE sy-vline.
    WRITE AT (c3) t_zfh_kr1at-name1. WRITE sy-vline.
    WRITE AT (c4) ld_bezei. WRITE sy-vline.
    WRITE AT (c4) t_zfh_kr1at-budat. WRITE sy-vline.
    WRITE AT (c4) space. WRITE sy-vline.
    WRITE AT (c6) t_zfh_kr1at-wrbtr CURRENCY t_zfh_kr1at-waers. WRITE sy-vline.
    IF t_zfh_kr1at-status EQ 'A'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.
    IF t_zfh_kr1at-status EQ 'B'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.
    IF t_zfh_kr1at-status EQ 'C'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.
    IF t_zfh_kr1at-status EQ 'D'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.
    IF t_zfh_kr1at-status EQ 'G'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.
    IF t_zfh_kr1at-status EQ 'H'.
      WRITE AT (c7) 'V' CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c7) space CENTERED. WRITE sy-vline.
    ENDIF.

    IF t_zfh_kr1at-datepos2 IS INITIAL.
      WRITE AT (c5) space CENTERED. WRITE sy-vline.
      WRITE AT (c6) space CENTERED. WRITE sy-vline.
    ELSE.
      WRITE AT (c5) t_zfh_kr1at-datepos2 CENTERED. WRITE sy-vline.
      WRITE AT (c6) t_zfh_kr1at-wrbtr CURRENCY t_zfh_kr1at-waers. WRITE sy-vline.
    ENDIF.
    WRITE AT (c10) space CENTERED. WRITE sy-vline.
    WRITE AT (c10) space CENTERED. WRITE sy-vline.
    WRITE AT (c10) space CENTERED. WRITE sy-vline.
    WRITE AT (c5) space CENTERED. WRITE sy-vline.

    IF ld_page EQ 20.
      PERFORM f_footer.
      NEW-PAGE.
      CLEAR: ld_page.
    ENDIF.
  ENDLOOP.

  IF ld_mod NE 0.
    PERFORM f_footer.
  ENDIF.
ENDFORM.                    " f_print_data_radio6

*&---------------------------------------------------------------------*
*&      Form  f_footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_footer .
  WRITE: / sy-uline.
  WRITE: / sy-vline.
  WRITE: (182) 'Keterangan Block A/R :'. WRITE sy-vline.
  WRITE: 'Tanggal : ', sy-datum.
  WRITE: (44) space. WRITE sy-vline.

  WRITE: / sy-vline.
  WRITE: (182) 'A : Manipulasi Salesman / Karyawan'. WRITE sy-vline.
  WRITE: 187 sy-uline(69).

  WRITE: / sy-vline.
  WRITE: (182) 'B : Pemilik Outlet meninggal dunia'. WRITE sy-vline.
  WRITE: (32) space. WRITE sy-vline.
  WRITE: (31) space.
  WRITE: sy-vline.

  WRITE: / sy-vline.
  WRITE: (182) 'C : Outlet Kebakaran'. WRITE sy-vline.
  WRITE: (32) space. WRITE sy-vline.
  WRITE: (31) space.
  WRITE: sy-vline.

  WRITE: / sy-vline.
  WRITE: (182) 'D : SSP ALL'. WRITE sy-vline.
  WRITE: (32) space. WRITE sy-vline.
  WRITE: (31) space.
  WRITE: sy-vline.

  WRITE: / sy-vline.
  WRITE: (182) 'G : SSP PPN'. WRITE sy-vline.
  WRITE: 187 sy-uline(69).

  WRITE: / sy-vline.
  WRITE: (182) 'H : SSP PPh'. WRITE sy-vline.
  WRITE: (32) 'BM / KCP' CENTERED. WRITE sy-vline.
  WRITE: (31) 'BSM / CSSPV / Sr Spv' CENTERED. WRITE sy-vline.

  WRITE: / sy-uline.

  WRITE: / sy-vline.
  WRITE: (30) 'Lampiran ke 1 : SH/OPH/GMO'.
  WRITE: (218) 'Lampiran ke 3 : SFCH/GMF'.
  WRITE: (1) space. WRITE sy-vline.
  WRITE: / sy-vline.
  WRITE: (30) 'Lampiran ke 2 : SSH'.
  WRITE: (218) 'Lampiran ke 4 : File Cabang'.
  WRITE: (1) space. WRITE sy-vline.
  WRITE: / sy-uline.
ENDFORM.                    " f_footer

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  USING    fu_name
                  CHANGING fc_lampiran.

  DATA : lv_name    TYPE thead-tdname,
         lines      TYPE STANDARD TABLE OF tline,
         ls_lines   LIKE LINE OF lines.

  lv_name   = fu_name.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = fu_name
      object                  = 'TEXT'
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
  IF sy-subrc = 0.
    fc_lampiran = ls_lines-tdline.
  ENDIF.
ENDFORM.                    " F_READ_TEXT
