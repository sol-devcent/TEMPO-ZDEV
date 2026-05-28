*----------------------------------------------------------------------*
*   INCLUDE ZF_POSTING_KR1A_V1F01                                      *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  IF pa_bukrs EQ '8020'.
    CLEAR gv_bukrs.
    gs_gsber-low    = '0200'.
    gs_gsber-sign   = 'I'.
    gs_gsber-option = 'EQ'.
    APPEND gs_gsber TO gr_gsber.
  ELSEIF pa_bukrs EQ '8070'.
    gv_bukrs = pa_bukrs.
    gr_gsber[]  = so_vkbur[].
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

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = t_user.

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

  IF pa_backg IS NOT INITIAL.
    CASE 'X'.
      WHEN radio1 OR radio3 OR radio5.
        pa_budat  = sy-datum.
    ENDCASE.
  ENDIF.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lv_error TYPE i,
        lv_mess(100).

  CASE 'X'.
    WHEN radio1.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_data
        WHERE bukrs     EQ pa_bukrs AND
              gsber     IN gr_gsber AND
              vkbur     IN so_vkbur AND
              noform    IN so_nform AND
              zuonr     IN so_zuonr AND
              kunnr     IN so_kunnr.

      LOOP AT t_data.
        IF ( t_data-stsrel1 IS INITIAL OR
          t_data-stsrel2 IS INITIAL ) AND
          t_data-belnrpos1 EQ space.
          t_error2 = t_data.
          t_error2-msg = 'Belum di otorisasi'.
          lv_error = 1.
        ENDIF.
        IF t_data-belnrpos1 NE space.
          t_error2 = t_data.
          CONCATENATE 'Sudah diposting (' t_data-belnrpos1 ')' INTO lv_mess
          SEPARATED BY space.
          t_error2-msg = lv_mess.
          lv_error = 1.
        ENDIF.

        IF lv_error IS INITIAL.
          t_zfh_kr1at = t_data.
          APPEND t_zfh_kr1at.
        ELSE.
          APPEND t_error2.
        ENDIF.
        CLEAR: lv_error.
      ENDLOOP.

      t_belnr[] = t_zfh_kr1at[].
      SORT t_belnr BY belnr.
      DELETE ADJACENT DUPLICATES FROM t_belnr COMPARING belnr.

      IF t_belnr[] IS NOT INITIAL.
        SELECT *
          FROM zfbid
          INTO CORRESPONDING FIELDS OF TABLE t_zfbid
          FOR ALL ENTRIES IN t_belnr
          WHERE bukrs EQ t_belnr-bukrs AND
                vkbur EQ t_belnr-vkbur AND
                vbeln EQ t_belnr-belnr AND
                bflag EQ space.

        SORT t_zfbid BY vbeln.
        DELETE ADJACENT DUPLICATES FROM t_zfbid COMPARING vbeln.
      ENDIF.

    WHEN radio3.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_data
        WHERE bukrs     EQ pa_bukrs AND
              gsber     IN gr_gsber AND
              vkbur     IN so_vkbur AND
              noform    IN so_nform AND
              zuonr     IN so_zuonr AND
              kunnr     IN so_kunnr.

      LOOP AT t_data.
        IF ( t_data-stsrel1 IS INITIAL OR
          t_data-stsrel2 IS INITIAL ) AND
          t_data-stsrel5 IS INITIAL AND
          t_data-belnrpos1 IS INITIAL AND
          t_data-belnrpos2 IS INITIAL.
          t_error2 = t_data.
          t_error2-msg = 'Belum di otorisasi'.
          lv_error = 1.
        ENDIF.
        IF ( t_data-stsrel1 IS NOT INITIAL OR
          t_data-stsrel2 IS NOT INITIAL ) AND
          t_data-stsrel5 IS INITIAL.
          t_error2 = t_data.
          t_error2-msg = 'Blm posting KR1 ke KR1A'.
          lv_error = 1.
        ENDIF.
        IF ( t_data-stsrel1 IS NOT INITIAL OR
          t_data-stsrel2 IS NOT INITIAL ) AND
          t_data-stsrel5 IS INITIAL AND
          t_data-belnrpos1 IS NOT INITIAL.
          t_error2 = t_data.
          t_error2-msg = 'Blm melakukan usulan pencairan'.
          lv_error = 1.
        ENDIF.
        IF ( t_data-stsrel1 IS NOT INITIAL OR
          t_data-stsrel2 IS NOT INITIAL ) AND
          t_data-stsrel5 IS NOT INITIAL AND
          t_data-belnrpos1 IS NOT INITIAL AND
          t_data-belnrpos2 IS NOT INITIAL.
          t_error2 = t_data.
          CONCATENATE 'Sudah diposting (' t_data-belnrpos2 ')' INTO lv_mess
          SEPARATED BY space.
          t_error2-msg = lv_mess.
          lv_error = 1.
        ENDIF.

        IF lv_error IS INITIAL.
          t_zfh_kr1at = t_data.
          APPEND t_zfh_kr1at.
        ELSE.
          APPEND t_error2.
        ENDIF.
        CLEAR: lv_error.
      ENDLOOP.

    WHEN radio4.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
        WHERE bukrs     EQ pa_bukrs AND
              gsber     IN gr_gsber AND
              vkbur     IN so_vkbur AND
              noform    IN so_nform AND
              zuonr     IN so_zuonr AND
              kunnr     IN so_kunnr.

    WHEN radio5.
      SELECT *
        FROM zfh_kr1at
        INTO CORRESPONDING FIELDS OF TABLE t_data
        WHERE bukrs     EQ pa_bukrs AND
              gsber     IN gr_gsber AND
              vkbur     IN so_vkbur AND
              noform    IN so_nform AND
              zuonr     IN so_zuonr AND
              kunnr     IN so_kunnr AND
              status    IN so_stat.

      LOOP AT t_data.
        IF ( t_data-stsrel1 IS INITIAL OR
          t_data-stsrel2 IS INITIAL ) AND
          t_data-belnrpos1 IS INITIAL AND
          t_data-belnrpos2 IS INITIAL.
          t_error2 = t_data.
          t_error2-msg = 'Belum di otorisasi'.
          lv_error = 1.
        ENDIF.
        IF ( t_data-stsrel1 IS NOT INITIAL OR
          t_data-stsrel2 IS NOT INITIAL ) AND
          t_data-belnrpos1 IS INITIAL.
          t_error2 = t_data.
          t_error2-msg = 'Blm posting KR1 ke KR1A'.
          lv_error = 1.
        ENDIF.
        IF ( t_data-stsrel1 IS NOT INITIAL OR
          t_data-stsrel2 IS NOT INITIAL ) AND
          t_data-belnrpos1 IS NOT INITIAL AND
          t_data-belnrpos2 IS NOT INITIAL.
          t_error2 = t_data.
          CONCATENATE 'Sudah diposting (' t_data-belnrpos2 ')' INTO lv_mess
          SEPARATED BY space.
          t_error2-msg = lv_mess.
          lv_error = 1.
        ENDIF.

        IF lv_error IS INITIAL.
          t_zfh_kr1at = t_data.
          APPEND t_zfh_kr1at.
        ELSE.
          APPEND t_error2.
        ENDIF.
        CLEAR: lv_error.
      ENDLOOP.
  ENDCASE.

  t_kunnr[] = t_zfh_kr1at[].
  SORT t_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM t_kunnr COMPARING kunnr.

  IF t_kunnr[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE t_kna1
      FOR ALL ENTRIES IN t_kunnr
      WHERE kunnr EQ t_kunnr-kunnr.
  ENDIF.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio4 OR radio5.
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
  DATA: lv_level1(12),
        lv_level2(12),
        lv_level3(12),
        lv_level4(12).

  CASE 'X'.
    WHEN radio1.
* Begin remark unicode coversion - DEVK965979
* 13.03.2020 - sol chirka
**      PERFORM f_fieldcatg USING ft_report:
**        'ERROR' '' '' '' '5' 'BISts' '' '' '' '' '' '' '' '' '' '',
**        'ICON' '' '' '' '5' 'Sts' '' '' '' '' '' '' '' '' '' '',
**        'STSREL1' '' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' '' '' 'UsrGrp1' '' '' '' '' '' '' '' '' '' '',
**        'STSREL2' '' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' '' '' 'UsrGrp2' '' '' '' '' '' '' '' '' '' '',
**        'VKBUR' 'ZFH_KR1AT' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ1' 'ZFH_KR1AT' 'UMSKZ1' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT3' 'ZFH_KR1AT' 'SGTXT3' '' '' 'Giro' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'KNKK' 'KLIMK' '' '15' 'Plafond' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '15' 'No.DO/CN' '' '' '' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Status' '' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' '',
**        'MSG' '' '' '' '75' 'Message' '' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio3.
**      PERFORM f_fieldcatg USING ft_report:
**        'ICON' '' '' '' '5' 'Sts' '' '' '' '' '' '' '' '' '' '',
**        'STSREL1' '' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' '' '' 'UsrGrp1' '' '' '' '' '' '' '' '' '' '',
**        'STSREL2' '' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' '' '' 'UsrGrp2' '' '' '' '' '' '' '' '' '' '',
**        'VKBUR' 'ZFH_KR1AT' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'KNKK' 'KLIMK' '' '15' 'Plafond' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '15' 'No.DO/CN' '' '' '' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Status' '' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' '',
**        'MSG' '' '' '' '75' 'Message' '' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio4.
**      PERFORM f_fieldcatg USING ft_report:
**        'STSREL1' 'ZFH_KR1AT' 'STSREL1' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' '' '' 'UsrGrp1' '' '' '' '' '' '' '' '' '' '',
**        'STSREL2' 'ZFH_KR1AT' 'STSREL2' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '' 'C',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' '' '' 'UsrGrp2' '' '' '' '' '' '' '' '' '' '',
**        'STSREL3' 'ZFH_KR1AT' 'STSREL3' 'X' '' '' '' '' '' '' '' '' '' '' '' 'C',
**        'STSREL4' 'ZFH_KR1AT' 'STSREL4' 'X' '' '' '' '' '' '' '' '' '' '' '' 'C',
**        'STSREL5' 'ZFH_KR1AT' 'STSREL5' 'X' '' '' '' '' '' '' '' '' '' '' '' 'C',
**        'VKBUR' 'ZFH_KR1AT' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'ZFH_KR1AT' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'ZFH_KR1AT' 'ZUONR' '' '' 'No.DO/CN' '' 'X' '' '' '' '' '' '' '' '',
**        'BUDAT' 'ZFH_KR1AT' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'ZFH_KR1AT' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'ZFH_KR1AT' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Status' '' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' '',
**
**        'BUKRS' 'ZFH_KR1AT' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'GSBER' 'ZFH_KR1AT' 'GSBER' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DTFORM' 'ZFH_KR1AT' 'DTFORM' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNR' 'ZFH_KR1AT' 'BELNR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'GJAHR' 'ZFH_KR1AT' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'BLDAT' 'ZFH_KR1AT' 'BLDAT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZFBDT' 'ZFH_KR1AT' 'ZFBDT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZTERM' 'ZFH_KR1AT' 'ZTERM' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'ZFH_KR1AT' 'KLIMK' 'X' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'OVERDSO' 'ZFH_KR1AT' 'OVERDSO' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'USNAM' 'ZFH_KR1AT' 'USNAM' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'UTIME' 'ZFH_KR1AT' 'UTIME' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT3' 'ZFH_KR1AT' 'SGTXT3' '' '' 'Giro' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL1' 'ZFH_KR1AT' 'NAMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL1' 'ZFH_KR1AT' 'DATEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL1' 'ZFH_KR1AT' 'TIMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL2' 'ZFH_KR1AT' 'NAMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL2' 'ZFH_KR1AT' 'DATEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL2' 'ZFH_KR1AT' 'TIMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP3' 'ZFH_KR1AT' 'USRGROUP3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL3' 'ZFH_KR1AT' 'NAMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL3' 'ZFH_KR1AT' 'DATEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL3' 'ZFH_KR1AT' 'TIMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP4' 'ZFH_KR1AT' 'USRGROUP4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL4' 'ZFH_KR1AT' 'NAMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL4' 'ZFH_KR1AT' 'DATEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL4' 'ZFH_KR1AT' 'TIMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP5' 'ZFH_KR1AT' 'USRGROUP5' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL5' 'ZFH_KR1AT' 'NAMEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL5' 'ZFH_KR1AT' 'DATEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL5' 'ZFH_KR1AT' 'TIMEREL5' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEPOS1' 'ZFH_KR1AT' 'NAMEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ1' 'ZFH_KR1AT' 'UMSKZ1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' 'X' '' '' '' 'X' '' '' '' '' '' '' '' '',
**        'GJAHRPOS1' 'ZFH_KR1AT' 'GJAHRPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEPOS1' 'ZFH_KR1AT' 'DATEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEPOS1' 'ZFH_KR1AT' 'TIMEPOS1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT1' 'ZFH_KR1AT' 'SGTXT1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEPOS2' 'ZFH_KR1AT' 'NAMEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'UMSKZ2' 'ZFH_KR1AT' 'UMSKZ2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNRPOS2' 'ZFH_KR1AT' 'BELNRPOS2' 'X' '' '' '' 'X' '' '' '' '' '' '' '' '',
**        'GJAHRPOS2' 'ZFH_KR1AT' 'GJAHRPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEPOS2' 'ZFH_KR1AT' 'DATEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEPOS2' 'ZFH_KR1AT' 'TIMEPOS2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT2' 'ZFH_KR1AT' 'SGTXT2' 'X' '' '' '' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio5.
**      PERFORM f_fieldcatg USING ft_report:
**        'ICON' '' '' '' '5' 'Sts' '' '' '' '' '' '' '' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' '' '' 'Status' '' '' '' '' '' '' '' '' '' '',
**        'VKBUR' 'ZFH_KR1AT' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'ZFH_KR1AT' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
**        'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
**        'DATEPOS1' 'ZFH_KR1AT' 'DATEPOS1' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'ZFH_KR1AT' 'ZUONR' '' '' 'No.DO/CN' '' 'X' '' '' '' '' '' '' '' '',
**        'BUDAT' 'ZFH_KR1AT' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'ZFH_KR1AT' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'ZFH_KR1AT' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL5' 'ZFH_KR1AT' 'NAMEREL5' '' '' 'Req.Cair' '' '' '' '' '' '' '' '' '' '',
**        'MSG' '' '' '' '75' 'Message' '' '' '' '' '' '' '' '' '' ''.
* End remark unicode coversion - DEVK965979
* Begin insert unicode conversion - DEVK965979
* 13.03.2020 - sol chirka
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'ERROR'     ''          ''          ''  '5'  'BISts'       '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ICON'      ''          ''          ''  '5'  'Sts'         '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL1'   ''          ''          ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' ''  ''   'UsrGrp1'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL2'   ''          ''          ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' ''  ''   'UsrGrp2'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ1'    'ZFH_KR1AT' 'UMSKZ1'    ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT3'    'ZFH_KR1AT' 'SGTXT3'    ''  ''   'Giro'        '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'KNKK'      'KLIMK'     ''  '15' 'Plafond'     '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  '15' 'No.DO/CN'    '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''   'Status'      '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'MSG'       ''          ''          ''  '75' 'Message'     '' '' '' '' '' '' '' '' '' ''.

    WHEN radio3.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'ICON'      ''          ''          ''  '5'  'Sts'         '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL1'   ''          ''          ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' ''  ''   'UsrGrp1'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL2'   ''          ''          ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' ''  ''   'UsrGrp2'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'KNKK'      'KLIMK'     ''  '15' 'Plafond'     '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  '15' 'No.DO/CN'    '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''   'Status'      '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'MSG'       ''          ''          ''  '75' 'Message'     '' '' '' '' '' '' '' '' '' ''.

    WHEN radio4.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'STSREL1'   'ZFH_KR1AT' 'STSREL1'   ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' ''  ''   'UsrGrp1'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL2'   'ZFH_KR1AT' 'STSREL2'   ''  '8'  'Golongan'    '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' ''  ''   'UsrGrp2'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL3'   'ZFH_KR1AT' 'STSREL3'   'X' ''   ''            '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'STSREL4'   'ZFH_KR1AT' 'STSREL4'   'X' ''   ''            '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'STSREL5'   'ZFH_KR1AT' 'STSREL5'   'X' ''   ''            '' '' '' '' '' '' '' '' '' 'C',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'ZFH_KR1AT' 'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'ZFH_KR1AT' 'ZUONR'     ''  ''   'No.DO/CN'    '' 'X' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'ZFH_KR1AT' 'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'ZFH_KR1AT' 'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'ZFH_KR1AT' 'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''   'Status'      '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' '' '',

        'FT_REPORT' 'BUKRS'     'ZFH_KR1AT' 'BUKRS'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GSBER'     'ZFH_KR1AT' 'GSBER'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DTFORM'    'ZFH_KR1AT' 'DTFORM'    'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNR'     'ZFH_KR1AT' 'BELNR'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHR'     'ZFH_KR1AT' 'GJAHR'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BLDAT'     'ZFH_KR1AT' 'BLDAT'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZFBDT'     'ZFH_KR1AT' 'ZFBDT'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZTERM'     'ZFH_KR1AT' 'ZTERM'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'ZFH_KR1AT' 'KLIMK'     'X' ''   ''            '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'OVERDSO'   'ZFH_KR1AT' 'OVERDSO'   'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USNAM'     'ZFH_KR1AT' 'USNAM'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UTIME'     'ZFH_KR1AT' 'UTIME'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT3'    'ZFH_KR1AT' 'SGTXT3'    ''  ''   'Giro'        '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL1'  'ZFH_KR1AT' 'NAMEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL1'  'ZFH_KR1AT' 'DATEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL1'  'ZFH_KR1AT' 'TIMEREL1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL2'  'ZFH_KR1AT' 'NAMEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL2'  'ZFH_KR1AT' 'DATEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL2'  'ZFH_KR1AT' 'TIMEREL2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP3' 'ZFH_KR1AT' 'USRGROUP3' 'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL3'  'ZFH_KR1AT' 'NAMEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL3'  'ZFH_KR1AT' 'DATEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL3'  'ZFH_KR1AT' 'TIMEREL3'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP4' 'ZFH_KR1AT' 'USRGROUP4' 'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL4'  'ZFH_KR1AT' 'NAMEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL4'  'ZFH_KR1AT' 'DATEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL4'  'ZFH_KR1AT' 'TIMEREL4'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP5' 'ZFH_KR1AT' 'USRGROUP5' 'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL5'  'ZFH_KR1AT' 'NAMEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL5'  'ZFH_KR1AT' 'DATEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL5'  'ZFH_KR1AT' 'TIMEREL5'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS1'  'ZFH_KR1AT' 'NAMEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ1'    'ZFH_KR1AT' 'UMSKZ1'    'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' 'X' ''   ''            '' 'X' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS1' 'ZFH_KR1AT' 'GJAHRPOS1' 'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS1'  'ZFH_KR1AT' 'DATEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS1'  'ZFH_KR1AT' 'TIMEPOS1'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT1'    'ZFH_KR1AT' 'SGTXT1'    'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS2'  'ZFH_KR1AT' 'NAMEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ2'    'ZFH_KR1AT' 'UMSKZ2'    'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS2' 'ZFH_KR1AT' 'BELNRPOS2' 'X' ''   ''            '' 'X' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS2' 'ZFH_KR1AT' 'GJAHRPOS2' 'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS2'  'ZFH_KR1AT' 'DATEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS2'  'ZFH_KR1AT' 'TIMEPOS2'  'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT2'    'ZFH_KR1AT' 'SGTXT2'    'X' ''   ''            '' '' '' '' '' '' '' '' '' ''.

    WHEN radio5.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'ICON'      ''          ''          ''  '5'  'Sts'         '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    ''  ''   'Status'      '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   'No. FORM3'   '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'ZFH_KR1AT' 'KUNNR'     ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' ''  ''   ''            '' 'X' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS1'  'ZFH_KR1AT' 'DATEPOS1'  ''  ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'ZFH_KR1AT' 'ZUONR'     ''  ''   'No.DO/CN'    '' 'X' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'ZFH_KR1AT' 'BUDAT'     ''  ''   'Tanggal'     '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'ZFH_KR1AT' 'WAERS'     'X' ''   ''            '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'ZFH_KR1AT' 'WRBTR'     ''  '15' 'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'  '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL5'  'ZFH_KR1AT' 'NAMEREL5'  ''  ''   'Req.Cair'    '' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'MSG'       ''          ''          ''  '75' 'Message'     '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_just).

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
  ld_fieldcat-just              = fu_just.
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
      IF va_status IS INITIAL.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.
      IF va_valid IS INITIAL.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.

    WHEN radio4.

    WHEN OTHERS.
      IF va_status IS INITIAL.
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
    WHEN radio4 OR radio5.
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
  ENDCASE.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
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
  REFRESH: t_out.
  CLEAR: t_out.
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
      IF va_valid EQ 1.
        SET PF-STATUS 'TOEXECUTE'.
      ELSE.
        SET PF-STATUS 'TOVALID'.
      ENDIF.

    WHEN radio4.
      SET PF-STATUS 'STANDARD'.

    WHEN OTHERS.
      IF va_status IS INITIAL.
        SET PF-STATUS 'TOEXECUTE'.
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
  DATA: lv_datum   TYPE sy-datum,
        lv_selisih(3).

  SORT t_zfh_kr1at BY kunnr.
  SORT t_kna1 BY kunnr.

  CASE 'X'.
    WHEN radio4.
      LOOP AT t_zfh_kr1at.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_zfh_kr1at-name1 = t_kna1-name1.
          MODIFY t_zfh_kr1at TRANSPORTING name1.
        ENDIF.
      ENDLOOP.

    WHEN radio5.
      LOOP AT t_zfh_kr1at.
        lv_datum = t_zfh_kr1at-datepos1 + pa_lewat.
        IF lv_datum LE sy-datum.
          READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_zfh_kr1at-name1 = t_kna1-name1.
            MODIFY t_zfh_kr1at TRANSPORTING name1.
          ENDIF.
        ELSE.
          lv_selisih = sy-datum - t_zfh_kr1at-datepos1.
          t_error2 = t_zfh_kr1at.
          CONCATENATE 'Tgl pencairan masih' lv_selisih 'hari' INTO t_error2-msg
          SEPARATED BY space..
          APPEND t_error2.
          DELETE t_zfh_kr1at.
        ENDIF.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT t_zfh_kr1at.
        t_out-kunnr = t_zfh_kr1at-kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-name1 = t_kna1-name1.
        ENDIF.
        t_out-sgtxt3   = t_zfh_kr1at-sgtxt3.
        t_out-bukrs    = t_zfh_kr1at-bukrs.
        t_out-gsber    = t_zfh_kr1at-gsber.
        t_out-vkbur    = t_zfh_kr1at-vkbur.
        t_out-noform   = t_zfh_kr1at-noform.
        t_out-klimk    = t_zfh_kr1at-klimk.
        t_out-waers    = t_zfh_kr1at-waers.
        t_out-zuonr    = t_zfh_kr1at-zuonr.
        t_out-umskz    = t_zfh_kr1at-umskz.
        t_out-budat    = t_zfh_kr1at-budat.
        t_out-wrbtr    = t_zfh_kr1at-wrbtr.
        t_out-status   = t_zfh_kr1at-status.
        t_out-zdesc1   = t_zfh_kr1at-zdesc1.
        t_out-zfbdt    = t_zfh_kr1at-zfbdt.
        t_out-zterm    = t_zfh_kr1at-zterm.
        t_out-belnr    = t_zfh_kr1at-belnr.
        t_out-gjahr      = t_zfh_kr1at-gjahr.
        t_out-umskz1     = t_zfh_kr1at-umskz1.
        t_out-stsrel1    = t_zfh_kr1at-stsrel1.
        t_out-stsrel2    = t_zfh_kr1at-stsrel2.
        t_out-stsrel3    = t_zfh_kr1at-stsrel3.
        t_out-usrgroup1  = t_zfh_kr1at-usrgroup1.
        t_out-usrgroup2  = t_zfh_kr1at-usrgroup2.
        t_out-umskz1   = t_zfh_kr1at-umskz1.
        APPEND t_out.
        CLEAR: t_out.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&VAL'.
      PERFORM f_validate_data.
      PERFORM f_alv TABLES t_out.
      LEAVE TO SCREEN 0.

    WHEN '&POS'.
      PERFORM f_post_entries.
      PERFORM f_table_unlocking.

    WHEN '&IC1'.
      CASE 'X'.
        WHEN radio4 OR radio5.
          CHECK NOT fu_selfield-tabindex IS INITIAL.
          CLEAR t_zfh_kr1at.
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

        WHEN OTHERS.
          CHECK NOT fu_selfield-tabindex IS INITIAL.
          READ TABLE t_out INDEX fu_selfield-tabindex.
          SET PARAMETER ID 'BLN' FIELD t_out-belnr.
          SET PARAMETER ID 'BUK' FIELD t_out-bukrs.
          SET PARAMETER ID 'GJR' FIELD t_out-gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.
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
  CASE 'X'.
    WHEN radio1.
*      PERFORM f_kr1_to_kr1a ON COMMIT.
      PERFORM f_kr1_to_kr1a_f22 ON COMMIT.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

*    WHEN radio2.
*      IF t_out[] IS INITIAL.
*        MESSAGE i000(zab) WITH 'No data to be processed'.
*      ELSE.
*        PERFORM f_update_zfh_kr1at ON COMMIT.
*        IF sy-subrc EQ 0.
*          COMMIT WORK AND WAIT.
*          MESSAGE s000(zab) WITH 'Usulan Pencairan KR1A Success'.
*        ELSE.
*          ROLLBACK WORK.
*        ENDIF.
*      ENDIF.
*      LEAVE TO SCREEN 0.

    WHEN radio3.
      PERFORM f_kr1a_to_kr1 ON COMMIT.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    WHEN radio5.
      PERFORM f_tanpa_pencairan ON COMMIT.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_post_entries

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
*&      Form  f_modify_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1 OR radio3.
      LOOP AT SCREEN.
        IF screen-group1 = 'DFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'LEW'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'STA'.
          screen-active  = 0.
        ENDIF.
        IF radio3 IS NOT INITIAL.
          IF screen-group1 = 'BAC'.
            screen-active  = 0.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

      IF pa_backg IS NOT INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 = 'DAT'.
            screen-active  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

    WHEN radio4.
      LOOP AT SCREEN.
        IF screen-group1 = 'BAC'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DFO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'LEW'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'STA'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio5.
      IF pa_backg IS NOT INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 = 'DAT'.
            screen-active  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_modify_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mess(50) VALUE 'Make an entry in all required fields',
        ld_frye1  LIKE t001b-frye1,
        ld_frpe1  LIKE t001b-frpe1,
        ld_toye1  LIKE t001b-toye1,
        ld_tope1  LIKE t001b-tope1,
        ld_datlo  TYPE sy-datum,
        ld_dathi  TYPE sy-datum.

  RANGES: lr_budat FOR sy-datum.

  SELECT SINGLE frye1 frpe1 toye1 tope1
    FROM t001b
    INTO (ld_frye1, ld_frpe1, ld_toye1, ld_tope1)
    WHERE bukrs EQ pa_bukrs AND
          mkoar EQ '+'.
  CONCATENATE ld_frye1 ld_frpe1+1(2) '01' INTO ld_datlo.
  IF ld_tope1+1(2) GT 12.
    ld_tope1 = '012'.
  ENDIF.
  CONCATENATE ld_toye1 ld_tope1+1(2) '01' INTO ld_dathi.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_dathi
    IMPORTING
      last_day_of_month = ld_dathi.

  lr_budat-low    = ld_datlo.
  lr_budat-high   = ld_dathi.
  lr_budat-sign   = 'E'.
  lr_budat-option = 'BT'.
  APPEND lr_budat.

  CASE 'X'.
    WHEN radio1 OR radio3.
      IF pa_backg IS INITIAL.
        IF pa_budat IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'DAT'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          IF pa_budat IN lr_budat.
            va_error  = 1.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'DAT'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'Posting date error'.
            CLEAR: sscrfields-ucomm.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio5.
      IF pa_backg IS INITIAL.

        IF pa_budat IS INITIAL.
          va_error  = 1.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'DAT'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
          CLEAR: sscrfields-ucomm.
        ELSE.
          IF pa_budat IN lr_budat.
            va_error  = 1.
            LOOP AT SCREEN.
              IF screen-group1 EQ 'DAT'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH 'Posting date error'.
            CLEAR: sscrfields-ucomm.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_table_locking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_locking .
  DATA: lw_zfh_kr1at  LIKE t_zfh_kr1at,
        ld_user       LIKE sy-uname,
        ld_subrc      LIKE sy-subrc.

  CASE 'X'.
    WHEN radio4.

    WHEN OTHERS.
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
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_table_locking

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
    MOVE-CORRESPONDING fu_data TO t_error1.
    t_error1-msg = fu_user.
    APPEND t_error1.
  ELSE.
    MOVE-CORRESPONDING fu_data TO t_error1.
    t_error1-msg = 'Error when processing the billing'.
    APPEND t_error1.
  ENDIF.
ENDFORM.                    " f_error_log_zfh_kr1at

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

  IF t_error1[] IS INITIAL AND
    t_error2[] IS INITIAL AND
    t_error3[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ENDIF.

  IF t_error1[] IS NOT INITIAL.
    ULINE AT /(57).
    WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
              sy-vline NO-GAP, (20) 'User' NO-GAP,
              sy-vline.
    ULINE AT /(57).
    LOOP AT t_error1.
      WRITE: /  sy-vline NO-GAP, (15) t_error1-kunnr NO-GAP,
                sy-vline NO-GAP, t_error1-zuonr NO-GAP,
                sy-vline NO-GAP, t_error1-msg(20) NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(57).
  ENDIF.

  IF t_error2[] IS NOT INITIAL.
    SKIP 1.
    ULINE AT /(86).
    WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
              sy-vline NO-GAP, (18) 'Amount' NO-GAP,
              sy-vline NO-GAP, (30) 'Message' NO-GAP,
              sy-vline.
    ULINE AT /(86).
    LOOP AT t_error2.
      WRITE: /  sy-vline NO-GAP, (15) t_error2-kunnr NO-GAP,
                sy-vline NO-GAP, t_error2-zuonr NO-GAP,
                sy-vline NO-GAP, t_error2-wrbtr CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, t_error2-msg(30) NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(86).
  ENDIF.

  IF t_error3[] IS NOT INITIAL.
    SKIP 1.
    ULINE AT /(86).
    WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor Dokumen' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor BI' NO-GAP,
              sy-vline NO-GAP, (30) 'Message' NO-GAP,
              sy-vline.
    ULINE AT /(86).
    LOOP AT t_error3.
      WRITE: /  sy-vline NO-GAP, (15) t_error3-kunnr NO-GAP,
                sy-vline NO-GAP, (18) t_error3-vbeln NO-GAP,
                sy-vline NO-GAP, (18) t_error3-bbeln NO-GAP,
                sy-vline NO-GAP, t_error3-msg(30) NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(86).
  ENDIF.
ENDFORM.                    " f_error_list

*&---------------------------------------------------------------------*
*&      Form  f_kr1_to_kr1a
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_kr1_to_kr1a .
  DATA: lt_proc   LIKE t_out OCCURS 0 WITH HEADER LINE,
        lw_proc   LIKE lt_proc,
        lv_count  TYPE i,
        lv_budat(8),
        lv_wrbtr(11),
        lv_bldat  LIKE bsid-bldat,
        lv_zfbdt  LIKE bsid-zfbdt,
        lv_sgtxt  LIKE bsid-sgtxt,
        lv_screen TYPE i.

  lt_proc[] = t_out[].
  DELETE lt_proc WHERE check = space.

  IF lt_proc[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    PERFORM f_format_date USING    pa_budat
                          CHANGING lv_budat.

    d_bdc_tctxt = 'Executing Transaction F-30'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    SORT lt_proc BY bukrs kunnr zuonr.
    SORT t_bsidsum BY bukrs kunnr zuonr.

    LOOP AT lt_proc INTO lw_proc.
      PERFORM f_format_date USING    lw_proc-budat
                            CHANGING lv_bldat.

      PERFORM f_format_date USING    lw_proc-zfbdt
                            CHANGING lv_zfbdt.

*      READ TABLE t_zfhstatus WITH KEY status = lw_proc-status.
*      IF sy-subrc EQ 0.
      CONCATENATE lw_proc-zdesc1 lw_proc-noform INTO lv_sgtxt
      SEPARATED BY '-'.
**      CONCATENATE lw_proc-noform lw_proc-zdesc1 INTO lv_sgtxt
**      SEPARATED BY '-'.
*      ENDIF.

*      READ TABLE t_bsidsum WITH KEY bukrs = lw_proc-bukrs
*                                    kunnr = lw_proc-kunnr
*                                    zuonr = lw_proc-zuonr
*      BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        IF t_bsidsum-count GT 0.
*          lv_screen = 1.
*        ELSE.
*          lv_screen = 0.
*        ENDIF.
*      ELSE.
*        lv_screen = 0.
*      ENDIF.

      lv_wrbtr = lw_proc-wrbtr.
      REPLACE '.' WITH space INTO lv_wrbtr.
      CONDENSE lv_wrbtr NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0122',
*        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'BDC_OKCODE'       '=SL',
        ' ' 'BKPF-BLDAT'       lv_bldat,
        ' ' 'BKPF-BLART'       'DA',
        ' ' 'BKPF-BUKRS'       lw_proc-bukrs,
        ' ' 'BKPF-BUDAT'       lv_budat,
        ' ' 'BKPF-MONAT'       lv_budat+2(2),
        ' ' 'BKPF-WAERS'       'IDR',
        ' ' 'FS006-DOCID'      '*',
        ' ' 'BKPF-BUDAT'       lv_budat,
        ' ' 'RF05A-NEWBS'      '09',
        ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
        ' ' 'RF05A-NEWUM'      lw_proc-umskz1.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0303',
        ' ' 'BDC_OKCODE'       '=SL',
        ' ' 'BSEG-WRBTR'       lv_wrbtr,
        ' ' 'BSEG-GSBER'       lw_proc-gsber,
        ' ' 'BSEG-ZFBDT'       lv_zfbdt,
        ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
        ' ' 'BSEG-SGTXT'       lv_sgtxt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0710',
        ' ' 'BDC_OKCODE'       '=PA',
        ' ' 'RF05A-AGBUK'      lw_proc-bukrs,
        ' ' 'RF05A-AGKON'      lw_proc-kunnr,
        ' ' 'RF05A-XPOS1(08)'  'X'.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0731',
        ' ' 'BDC_OKCODE'       '=PA',
        ' ' 'RF05A-SEL01(01)'  lw_proc-zuonr.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPDF05X'         '3100',
        ' ' 'BDC_OKCODE'       '=BU',
        ' ' 'RF05A-ABPOS'      '1'.

      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'F-30'
                                             d_bdc_tctxt.

      PERFORM f_get_message USING t_bdcmsg
                            CHANGING t_out-msg.

*-----Update message for the status report
      IF d_bdc_error = 0.
        t_out-icon = icon_led_green.
      ELSE.
        t_out-icon = icon_led_red.
        va_errcnt = va_errcnt + lv_count.
        va_success = va_success - lv_count.
      ENDIF.
      MODIFY t_out TRANSPORTING icon msg WHERE bukrs EQ lw_proc-bukrs AND
                                               gsber EQ lw_proc-gsber AND
                                               vkbur EQ lw_proc-vkbur AND
                                               zuonr EQ lw_proc-zuonr.

* Update table ZFH_KR1AT.
      IF d_bdc_error = 0.
        UPDATE zfh_kr1at SET belnrpos1 = t_bdcmsg-msgv1
                             gjahrpos1 = pa_budat(4)
                             namepos1  = sy-uname
                             datepos1  = sy-datum
                             timepos1  = sy-uzeit
                             sgtxt1    = lv_sgtxt
          WHERE bukrs  EQ lw_proc-bukrs AND
                gsber  EQ lw_proc-gsber AND
                vkbur  EQ lw_proc-vkbur AND
                noform EQ lw_proc-noform AND
                zuonr  EQ lw_proc-zuonr.
      ENDIF.
      CLEAR: t_bdcdata, t_bdcmsg, d_bdc_error, lv_count.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.

    PERFORM f_status_rep.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " f_kr1_to_kr1a

*&---------------------------------------------------------------------*
*&      Form  f_kr1a_to_kr1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_kr1a_to_kr1 .
  DATA: lt_proc  LIKE t_out OCCURS 0 WITH HEADER LINE,
        lw_proc  LIKE lt_proc,
        lv_count TYPE i,
        lv_budat(8),
        lv_wrbtr(11),
        lv_bldat LIKE bsid-bldat,
        lv_zfbdt LIKE bsid-zfbdt,
        lv_sgtxt(50).

  lt_proc[] = t_out[].
  DELETE lt_proc WHERE check = space.

  IF lt_proc[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    PERFORM f_format_date USING    pa_budat
                          CHANGING lv_budat.

    d_bdc_tctxt = 'Executing Transaction F-22'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    LOOP AT lt_proc INTO lw_proc.
      PERFORM f_format_date USING    lw_proc-budat
                            CHANGING lv_bldat.
      PERFORM f_format_date USING    lw_proc-zfbdt
                            CHANGING lv_zfbdt.

      CONCATENATE 'Pencairan FORM 3' lw_proc-noform INTO lv_sgtxt
      SEPARATED BY '-'.
*      CONCATENATE lw_proc-noform 'Pencairan FORM 3' INTO lv_sgtxt
*      SEPARATED BY '-'.

      lv_wrbtr = lw_proc-wrbtr.
      REPLACE '.' WITH space INTO lv_wrbtr.
      CONDENSE lv_wrbtr NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0100',
        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'BKPF-BLDAT'       lv_bldat.
* Tambahan logik untuk Special G/L Indicator 'V'
      IF lw_proc-umskz EQ 'V'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'BKPF-BLART'       'DA'.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'BKPF-BLART'       'DR'.
      ENDIF.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
        ' ' 'BKPF-BUKRS'       lw_proc-bukrs,
        ' ' 'BKPF-BUDAT'       lv_budat,
        ' ' 'BKPF-MONAT'       lv_budat+2(2),
        ' ' 'BKPF-WAERS'       'IDR',
        ' ' 'FS006-DOCID'      '*'.
      IF lw_proc-umskz EQ 'V'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
        ' ' 'RF05A-NEWBS'      '09',
        ' ' 'RF05A-NEWUM'      lw_proc-umskz,
        ' ' 'RF05A-NEWKO'      lw_proc-kunnr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0303',
          ' ' 'BDC_OKCODE'       '/00',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
*          ' ' 'BSEG-ZFBDT'       lv_bldat,
          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt,
          ' ' 'RF05A-NEWBS'      '19',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
          ' ' 'RF05A-NEWUM'      lw_proc-umskz1.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
        ' ' 'RF05A-NEWBS'      '01',
        ' ' 'RF05A-NEWKO'      lw_proc-kunnr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0301',
          ' ' 'BDC_OKCODE'       '/00',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
          ' ' 'BSEG-ZTERM'       lw_proc-zterm,
          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt,
          ' ' 'RF05A-NEWBS'      '19',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
          ' ' 'RF05A-NEWUM'      lw_proc-umskz1.
      ENDIF.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0303',
        ' ' 'BDC_OKCODE'       '=AB',
        ' ' 'BSEG-WRBTR'       lv_wrbtr,
        ' ' 'BSEG-MWSKZ'       '**',
        ' ' 'BSEG-GSBER'       lw_proc-gsber,
        ' ' 'BSEG-ZFBDT'       lv_budat,
        ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
        ' ' 'BSEG-SGTXT'       lv_sgtxt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0700',
        ' ' 'BDC_OKCODE'       '=BU'.

      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'F-22'
                                             d_bdc_tctxt.

      PERFORM f_get_message USING t_bdcmsg
                            CHANGING t_out-msg.

*-----Update message for the status report
      IF d_bdc_error = 0.
        t_out-icon = icon_led_green.
      ELSE.
        t_out-icon = icon_led_red.
        va_errcnt = va_errcnt + lv_count.
        va_success = va_success - lv_count.
      ENDIF.
      MODIFY t_out TRANSPORTING icon msg WHERE bukrs EQ lw_proc-bukrs AND
                                               gsber EQ lw_proc-gsber AND
                                               vkbur EQ lw_proc-vkbur AND
                                               zuonr EQ lw_proc-zuonr.

* Update table ZFH_KR1AT.
      IF d_bdc_error = 0.
        UPDATE zfh_kr1at SET belnrpos2 = t_bdcmsg-msgv1
                             gjahrpos2 = pa_budat(4)
                             namepos2  = sy-uname
                             datepos2  = sy-datum
                             timepos2  = sy-uzeit
                             sgtxt2    = lv_sgtxt
          WHERE bukrs  EQ lw_proc-bukrs AND
                gsber  EQ lw_proc-gsber AND
                vkbur  EQ lw_proc-vkbur AND
                noform EQ lw_proc-noform AND
                zuonr  EQ lw_proc-zuonr.
      ENDIF.
      CLEAR: t_bdcdata, t_bdcmsg, d_bdc_error, lv_count.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.

    PERFORM f_status_rep.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " f_kr1a_to_kr1

*&---------------------------------------------------------------------*
*&      Form  f_status_rep
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_status_rep .
  CASE 'X'.
    WHEN radio5.
      va_status = 1.
      PERFORM f_alv TABLES t_zfh_kr1at.

    WHEN OTHERS.
      va_status = 1.
      PERFORM f_alv TABLES t_out.
  ENDCASE.
ENDFORM.                    " f_status_rep

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
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
*&      Form  f_table_unlocking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_unlocking .
  CASE 'X'.
    WHEN radio4.

    WHEN OTHERS.
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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data .
  DATA: lv_error TYPE i,
        lv_rec1  TYPE i,
        lv_rec2  TYPE i.

  CLEAR: t_error3.
  REFRESH: t_error3.

  DESCRIBE TABLE t_out LINES lv_rec1.
  SORT t_out BY bukrs vkbur belnr.
  SORT t_zfbid BY bukrs vkbur vbeln.

  LOOP AT t_out.
    IF t_out-check IS INITIAL.
      ADD 1 TO lv_rec2.
      IF t_out-error IS NOT INITIAL.
        CLEAR: t_out-error.
        MODIFY t_out TRANSPORTING error.
      ENDIF.
    ELSE.
      READ TABLE t_zfbid WITH KEY bukrs = t_out-bukrs
                                  vkbur = t_out-vkbur
                                  vbeln = t_out-belnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_error = 1.
        t_error3-kunnr = t_out-kunnr.
        t_error3-vbeln = t_zfbid-vbeln.
        t_error3-bbeln = t_zfbid-bbeln.
        t_error3-msg   = 'Dokumen sudah ada di BI'.
        APPEND t_error3.
        t_out-error = icon_led_red.
      ELSE.
        t_out-error = icon_led_green.
      ENDIF.
      MODIFY t_out TRANSPORTING error.
    ENDIF.
  ENDLOOP.

  IF lv_rec1 = lv_rec2.
    lv_error = 2.
  ENDIF.

  IF lv_error IS INITIAL.
    va_valid = 1.
  ELSE.
    CASE lv_error.
      WHEN 1.
        MESSAGE i000(zab) WITH 'Dokumen sudah ada di BI'.
      WHEN 2.
        MESSAGE i000(zab) WITH 'No data to be processed'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " f_validate_data

*&---------------------------------------------------------------------*
*&      Form  f_tanpa_pencairan
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tanpa_pencairan .
  DATA: lt_proc  LIKE t_zfh_kr1at OCCURS 0 WITH HEADER LINE,
        lw_proc  LIKE lt_proc,
        lv_count TYPE i,
        lv_budat(8),
        lv_wrbtr(11),
        lv_bldat LIKE bsid-bldat,
        lv_zfbdt LIKE bsid-zfbdt,
        lv_sgtxt(50).

  lt_proc[] = t_zfh_kr1at[].
  DELETE lt_proc WHERE check = space.

  IF lt_proc[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    PERFORM f_format_date USING    pa_budat
                          CHANGING lv_budat.

    d_bdc_tctxt = 'Executing Transaction F-22'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    LOOP AT lt_proc INTO lw_proc.
      PERFORM f_format_date USING    lw_proc-budat
                            CHANGING lv_bldat.
      PERFORM f_format_date USING    lw_proc-zfbdt
                            CHANGING lv_zfbdt.

      CONCATENATE  'Pencairan FORM 3' lw_proc-noform INTO lv_sgtxt
      SEPARATED BY '-'.
*      CONCATENATE  lw_proc-noform 'Pencairan FORM 3' INTO lv_sgtxt
*      SEPARATED BY '-'.

      lv_wrbtr = lw_proc-wrbtr.
      REPLACE '.' WITH space INTO lv_wrbtr.
      CONDENSE lv_wrbtr NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0100',
        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'BKPF-BLDAT'       lv_bldat.
* Tambahan logik untuk Special G/L Indicator 'V'
      IF lw_proc-umskz EQ 'V'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'BKPF-BLART'       'DA'.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'BKPF-BLART'       'DR'.
      ENDIF.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        ' ' 'BKPF-BUKRS'       lw_proc-bukrs,
        ' ' 'BKPF-BUDAT'       lv_budat,
        ' ' 'BKPF-MONAT'       lv_budat+2(2),
        ' ' 'BKPF-WAERS'       'IDR',
        ' ' 'FS006-DOCID'      '*'.

      IF lw_proc-umskz EQ 'V'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'RF05A-NEWBS'      '09',
          ' ' 'RF05A-NEWUM'      lw_proc-umskz,
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0303',
          ' ' 'BDC_OKCODE'       '/00',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
*          ' ' 'BSEG-ZFBDT'       lv_bldat,
          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt,
          ' ' 'RF05A-NEWBS'      '19',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
          ' ' 'RF05A-NEWUM'      lw_proc-umskz1.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'RF05A-NEWBS'      '01',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0301',
          ' ' 'BDC_OKCODE'       '/00',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
          ' ' 'BSEG-ZTERM'       lw_proc-zterm,
          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt,
          ' ' 'RF05A-NEWBS'      '19',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
          ' ' 'RF05A-NEWUM'      lw_proc-umskz1.
      ENDIF.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0303',
        ' ' 'BDC_OKCODE'       '=AB',
        ' ' 'BSEG-WRBTR'       lv_wrbtr,
        ' ' 'BSEG-MWSKZ'       '**',
        ' ' 'BSEG-GSBER'       lw_proc-gsber,
        ' ' 'BSEG-ZFBDT'       lv_budat,
        ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
        ' ' 'BSEG-SGTXT'       lv_sgtxt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0700',
        ' ' 'BDC_OKCODE'       '=BU'.

      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'F-22'
                                             d_bdc_tctxt.

      PERFORM f_get_message USING t_bdcmsg
                            CHANGING t_zfh_kr1at-msg.

*-----Update message for the status report
      IF d_bdc_error = 0.
        t_zfh_kr1at-icon = icon_led_green.
      ELSE.
        t_zfh_kr1at-icon = icon_led_red.
        va_errcnt = va_errcnt + lv_count.
        va_success = va_success - lv_count.
      ENDIF.
      MODIFY t_zfh_kr1at TRANSPORTING icon msg WHERE bukrs EQ lw_proc-bukrs AND
                                                     gsber EQ lw_proc-gsber AND
                                                     vkbur EQ lw_proc-vkbur AND
                                                     zuonr EQ lw_proc-zuonr.

* Update table ZFH_KR1AT.
      IF d_bdc_error = 0.
        UPDATE zfh_kr1at SET stsrel5   = 1
                             namerel5  = sy-uname
                             daterel5  = sy-datum
                             timerel5  = sy-uzeit
                             belnrpos2 = t_bdcmsg-msgv1
                             gjahrpos2 = pa_budat(4)
                             namepos2  = sy-uname
                             datepos2  = sy-datum
                             timepos2  = sy-uzeit
                             sgtxt2    = lv_sgtxt
          WHERE bukrs  EQ lw_proc-bukrs AND
                gsber  EQ lw_proc-gsber AND
                vkbur  EQ lw_proc-vkbur AND
                noform EQ lw_proc-noform AND
                zuonr  EQ lw_proc-zuonr.
      ENDIF.
      CLEAR: t_bdcdata, t_bdcmsg, d_bdc_error, lv_count.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.

    PERFORM f_status_rep.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " f_tanpa_pencairan

*&---------------------------------------------------------------------*
*&      Form  f_kr1_to_kr1a_f22
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_kr1_to_kr1a_f22 .
  DATA: lt_proc   LIKE t_out OCCURS 0 WITH HEADER LINE,
        lw_proc   LIKE lt_proc,
        lv_count  TYPE i,
        lv_budat(8),
        lv_wrbtr(11),
        lv_bldat  LIKE bsid-bldat,
        lv_zfbdt  LIKE bsid-zfbdt,
        lv_sgtxt  LIKE bsid-sgtxt,
        lv_screen TYPE i.

  DATA: BEGIN OF lt_kunnr OCCURS 0,
        bukrs  LIKE zfhstblokd-bukrs,
        kunnr  LIKE kna1-kunnr,
        error  TYPE i.
  DATA: END OF lt_kunnr.

  lt_proc[] = t_out[].
  DELETE lt_proc WHERE check = space.

  IF lt_proc[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    PERFORM f_format_date USING    pa_budat
                          CHANGING lv_budat.

    d_bdc_tctxt = 'Executing Transaction F-22'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    SORT lt_proc BY bukrs kunnr zuonr.
    SORT t_bsidsum BY bukrs kunnr zuonr.

    LOOP AT lt_proc INTO lw_proc.
      PERFORM f_format_date USING    lw_proc-budat
                            CHANGING lv_bldat.

      PERFORM f_format_date USING    lw_proc-zfbdt
                            CHANGING lv_zfbdt.

*      CONCATENATE lw_proc-noform lw_proc-zdesc1 INTO lv_sgtxt
*      SEPARATED BY '-'.
      CONCATENATE lw_proc-zdesc1 lw_proc-noform INTO lv_sgtxt
      SEPARATED BY '-'.

      lv_wrbtr = lw_proc-wrbtr.
      REPLACE '.' WITH space INTO lv_wrbtr.
      CONDENSE lv_wrbtr NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0100',
        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'BKPF-BLDAT'       lv_zfbdt,
        ' ' 'BKPF-BLART'       'DA',
        ' ' 'BKPF-BUKRS'       lw_proc-bukrs,
        ' ' 'BKPF-BUDAT'       lv_budat,
        ' ' 'BKPF-MONAT'       lv_budat+2(2),
        ' ' 'BKPF-WAERS'       'IDR',
        ' ' 'FS006-DOCID'      '*',
        ' ' 'RF05A-NEWBS'      '09',
        ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
        ' ' 'RF05A-NEWUM'      lw_proc-umskz1.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPMF05A'         '0303',
        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'BSEG-WRBTR'       lv_wrbtr,
        ' ' 'BSEG-GSBER'       lw_proc-gsber,
        ' ' 'BSEG-ZFBDT'       lv_zfbdt,
        ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
        ' ' 'BSEG-SGTXT'       lv_sgtxt.
* Tambahan logik untuk Special G/L Indicator 'V'
      IF lw_proc-umskz EQ 'V'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'RF05A-NEWBS'      '19',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr,
          ' ' 'RF05A-NEWUM'      lw_proc-umskz.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0303',
          ' ' 'BDC_OKCODE'       '=BU',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
*          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZFBDT'       lv_budat,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' ' 'RF05A-NEWBS'      '17',
          ' ' 'RF05A-NEWKO'      lw_proc-kunnr.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMF05A'         '0301',
          ' ' 'BDC_OKCODE'       '=BU',
          ' ' 'BSEG-WRBTR'       lv_wrbtr,
          ' ' 'BSEG-MWSKZ'       '**',
          ' ' 'BSEG-GSBER'       lw_proc-gsber,
          ' ' 'BSEG-ZFBDT'       lv_zfbdt,
          ' ' 'BSEG-ZUONR'       lw_proc-zuonr,
          ' ' 'BSEG-SGTXT'       lv_sgtxt.
      ENDIF.


      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'F-22'
                                             d_bdc_tctxt.

      PERFORM f_get_message USING t_bdcmsg
                            CHANGING t_out-msg.

*-----Update message for the status report
      IF d_bdc_error = 0.
        t_out-icon = icon_led_green.
        lt_kunnr-error = 0.
      ELSE.
        t_out-icon = icon_led_red.
        va_errcnt = va_errcnt + lv_count.
        va_success = va_success - lv_count.
        lt_kunnr-error = 1.
      ENDIF.

      lt_kunnr-bukrs = lw_proc-bukrs.
      lt_kunnr-kunnr = lw_proc-kunnr.
      COLLECT lt_kunnr.

      MODIFY t_out TRANSPORTING icon msg WHERE bukrs EQ lw_proc-bukrs AND
                                               gsber EQ lw_proc-gsber AND
                                               vkbur EQ lw_proc-vkbur AND
                                               zuonr EQ lw_proc-zuonr.

* Update table ZFH_KR1AT.
      IF d_bdc_error = 0.
        UPDATE zfh_kr1at SET belnrpos1 = t_bdcmsg-msgv1
                             gjahrpos1 = pa_budat(4)
                             namepos1  = sy-uname
                             datepos1  = sy-datum
                             timepos1  = sy-uzeit
                             sgtxt1    = lv_sgtxt
          WHERE bukrs  EQ lw_proc-bukrs AND
                gsber  EQ lw_proc-gsber AND
                vkbur  EQ lw_proc-vkbur AND
                noform EQ lw_proc-noform AND
                zuonr  EQ lw_proc-zuonr.
      ENDIF.
      CLEAR: t_bdcdata, t_bdcmsg, d_bdc_error, lv_count.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.

* Clearing process F.13
    d_bdc_tctxt = 'Executing Transaction F.13'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.

    LOOP AT lt_kunnr.
      IF lt_kunnr-error EQ 0.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPF124'          '1000',
          ' ' 'BDC_OKCODE'       '=ONLI',
          ' ' 'BUKRX-LOW'        lt_kunnr-bukrs,
          ' ' 'X_KUNNR'          'X',
          ' ' 'X_SHBKN'          'X',
          ' ' 'KONTD-LOW'        lt_kunnr-kunnr,
          ' ' 'AUGDT'            space,
          ' ' 'XAUGDT'           'X',
          ' ' 'X_TESTL'          space,
          ' ' 'XAUSBEL'          'X',
          ' ' 'XNAUSBEL'         'X',
          ' ' 'X_FEHLER'         'X'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPMSSY0'         '0120',
          ' ' 'BDC_OKCODE'       '=&F03'.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPF124'          '1000',
          ' ' 'BDC_OKCODE'       '/EE'.

        PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                                t_bdcmsg
                                         USING 'F.13'
                                               d_bdc_tctxt.
      ENDIF.
      CLEAR: t_bdcdata, t_bdcmsg, d_bdc_error.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.

    PERFORM f_status_rep.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " f_kr1_to_kr1a_f22
