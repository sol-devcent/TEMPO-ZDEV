*----------------------------------------------------------------------*
*   INCLUDE ZF_STRATEGI_RELEASE_V1F01                                  *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  CLEAR: va_wrbtr, va_zlevel.

  break tds_dev01.
  break bcdik.

  IF pa_bukrs EQ '8020'.
    gv_gsber  = '0200'.
    gv_bukrs  = pa_bukrs.
*    CLEAR gv_bukrs.
  ELSEIF pa_bukrs EQ '8070'.
    gv_gsber  = pa_vkbur.
    gv_bukrs  = pa_bukrs.
  ENDIF.

  CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
    EXPORTING
      bname      = sy-uname
    TABLES
      usergroups = usergroups.

  SELECT *
    FROM zfdept
    INTO CORRESPONDING FIELDS OF TABLE t_zfdept.

  SELECT *
    FROM zfusrrel_form3
    INTO CORRESPONDING FIELDS OF TABLE t_zfusrrel_form3
    WHERE bukrs EQ pa_bukrs.

  IF va_usrgroup IS INITIAL.
    LOOP AT usergroups.
      READ TABLE t_zfusrrel_form3 WITH KEY usergroup = usergroups-usergroup.
      IF sy-subrc = 0.
        va_usrgroup = usergroups-usergroup.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.

  CASE 'X'.
    WHEN radio1 OR radio2.
      SELECT SINGLE zgoluser
        FROM zscl_goluser
        INTO va_zgoluser
        WHERE ztype    EQ 'AR' AND
              usrgroup EQ va_usrgroup AND
              bukrs    EQ gv_bukrs.

      SELECT *
        FROM zscl_level
        INTO CORRESPONDING FIELDS OF TABLE t_zscl_level
        WHERE ztype  EQ 'AR' AND
              zflag  EQ space AND
              bukrs  EQ gv_bukrs.

      READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                           usergroup = va_usrgroup.
      IF sy-subrc EQ 0.
        va_zdept  = t_zfusrrel_form3-zdept.
      ENDIF.

    WHEN radio3.
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
  ENDCASE.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  SELECT *
    FROM zfh_kr1at
    INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
    WHERE bukrs   EQ pa_bukrs AND
          gsber   EQ gv_gsber AND
          vkbur   EQ pa_vkbur AND
          noform  IN so_nform AND
          zuonr   IN so_zuonr AND
          kunnr   IN so_kunnr.

  t_kunnr[] = t_zfh_kr1at[].
  SORT t_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM t_kunnr COMPARING kunnr.

  IF t_kunnr[] IS NOT INITIAL.
    SELECT *
      FROM kna1 AS a JOIN knvv AS b ON a~kunnr = b~kunnr
      INTO CORRESPONDING FIELDS OF TABLE t_kna1
      FOR ALL ENTRIES IN t_kunnr
      WHERE a~kunnr EQ t_kunnr-kunnr AND
            vkbur EQ t_kunnr-vkbur.
  ENDIF.
***  LOOP AT t_zfh_kr1at.
***        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
***        BINARY SEARCH.
***        IF sy-subrc EQ 0.
***          AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
***              ID 'VKBUR' FIELD pa_vkbur.
***          IF sy-subrc NE 0.
***            MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
***                     pa_vkbur.
***          ENDIF.
***          .
***        ENDIF.
***
***  ENDLOOP.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio1 OR radio2.
      PERFORM f_alv TABLES t_out.
    WHEN radio3.
      PERFORM f_alv TABLES t_zfh_kr1at.
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
    WHEN radio1 OR radio2.
* Begin remark unicode coversion - DEVK965979
* 13.03.2020 - sol chirka
**      PERFORM f_fieldcatg USING ft_report:
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'SGTXT3' 'ZFH_KR1AT' 'SGTXT3' '' '20' 'Giro' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'KLIMK' 'KNKK' 'KLIMK' '' '15' 'Plafond' '' '' '' '' '' 'WAERS' '' '' '',
**        'ZUONR' 'BSID' 'ZUONR' '' '15' 'No.DO/CN' '' '' '' '' '' '' '' '' '',
**        'BUDAT' 'BSID' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'BSID' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '',
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' '' '7' 'UsrGrp1' '' '' '' '' '' '' '' '' '',
**        'ZDEPT1' 'ZFH_KR1AT' 'ZDEPT1' '' '7' 'Depart1' '' '' '' '' '' '' '' '' '',
**        'ZDDESC1' 'ZFDEPT' 'ZDESC' '' '10' 'Desc1' '' '' '' '' '' '' '' '' '',
**        'ZGOLUSER1' 'ZFH_KR1AT' 'STSREL1' '' '' 'Gol.1' '' '' '' '' '' '' '' '' '',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' '' '7' 'UsrGrp2' '' '' '' '' '' '' '' '' '',
**        'ZDEPT2' 'ZFH_KR1AT' 'ZDEPT2' '' '7' 'Depart2' '' '' '' '' '' '' '' '' '',
**        'ZDDESC2' 'ZFDEPT' 'ZDESC' '' '10' 'Desc2' '' '' '' '' '' '' '' '' '',
**        'ZGOLUSER2' 'ZFH_KR1AT' 'STSREL2' '' '' 'Gol.2' '' '' '' '' '' '' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' '' '' 'Status' '' '' '' '' '' '' '' '' '',
**        'ZDESC1' 'ZFH_KR1AT' 'ZDESC1' '' '' 'Keterangan' '' '' '' '' '' '' '' '' ''.
**
**    WHEN radio3.
**      PERFORM f_fieldcatg USING ft_report:
**        'NOFORM' 'ZFH_KR1AT' 'NOFORM' '' '' 'No. FORM3' '' '' '' '' '' '' '' '' '',
**        'KUNNR' 'ZFH_KR1AT' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NAME1' 'KNA1' 'NAME1' '' '25' 'Nama Outlet' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'ZFH_KR1AT' 'ZUONR' '' '' 'No.DO/CN' '' 'X' '' '' '' '' '' '' '',
**        'BUDAT' 'ZFH_KR1AT' 'BUDAT' '' '' 'Tanggal' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'ZFH_KR1AT' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'WRBTR' 'ZFH_KR1AT' 'WRBTR' '' '15' 'Nilai(Rp.)' '' '' '' '' '' 'WAERS' '' '' '',
**        'STATUS' 'ZFH_KR1AT' 'STATUS' 'X' '' 'Status' '' '' '' '' '' '' '' '' '',
**        'STSREL1' 'ZFH_KR1AT' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '',
**        'STSREL2' 'ZFH_KR1AT' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '',
**        'STSREL3' 'ZFH_KR1AT' '' '' '8' 'Golongan' '' '' '' '' '' '' '' '' '',
**        'SGTXT3' 'ZFH_KR1AT' 'SGTXT3' '' '' 'Giro' '' '' '' '' '' '' '' '' '',
**        'STSREL4' 'ZFH_KR1AT' 'STSREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'STSREL5' 'ZFH_KR1AT' 'STSREL5' 'X' '' '' '' '' '' '' '' '' '' '' '',
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
**        'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'ZDEPT1' 'ZFH_KR1AT' 'ZDEPT1' 'X' '7' 'Depart1' '' '' '' '' '' '' '' '' '',
**        'ZDDESC1' 'ZFDEPT' 'ZDESC' 'X' '10' 'Desc1' '' '' '' '' '' '' '' '' '',
**        'NAMEREL1' 'ZFH_KR1AT' 'NAMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL1' 'ZFH_KR1AT' 'DATEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL1' 'ZFH_KR1AT' 'TIMEREL1' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'ZDEPT2' 'ZFH_KR1AT' 'ZDEPT2' 'X' '7' 'Depart1' '' '' '' '' '' '' '' '' '',
**        'ZDDESC2' 'ZFDEPT' 'ZDESC' 'X' '10' 'Desc1' '' '' '' '' '' '' '' '' '',
**        'NAMEREL2' 'ZFH_KR1AT' 'NAMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL2' 'ZFH_KR1AT' 'DATEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL2' 'ZFH_KR1AT' 'TIMEREL2' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP3' 'ZFH_KR1AT' 'USRGROUP3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL3' 'ZFH_KR1AT' 'NAMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL3' 'ZFH_KR1AT' 'DATEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL3' 'ZFH_KR1AT' 'TIMEREL3' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP4' 'ZFH_KR1AT' 'USRGROUP4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'NAMEREL4' 'ZFH_KR1AT' 'NAMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'DATEREL4' 'ZFH_KR1AT' 'DATEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'TIMEREL4' 'ZFH_KR1AT' 'TIMEREL4' 'X' '' '' '' '' '' '' '' '' '' '' '',
**        'USRGROUP5' 'ZFH_KR1AT' 'USRGROUP5' 'X' '' '' '' '' '' '' '' '' '' '' '',
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
* End remark unicode coversion - DEVK965979
* Begin insert unicode conversion - DEVK965979
* 13.03.2020 - sol chirka
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''   ''             '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'KNVV'      'KUNNR'     ''  ''   ''             '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25' 'Nama Outlet'  '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT3'    'ZFH_KR1AT' 'SGTXT3'    ''  '20' 'Giro'         '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'BSID'      'WAERS'     'X' ''   ''             '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'KNKK'      'KLIMK'     ''  '15' 'Plafond'      '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ZUONR'     'BSID'      'ZUONR'     ''  '15' 'No.DO/CN'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'BSID'      'BUDAT'     ''  ''   'Tanggal'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'BSID'      'WRBTR'     ''  '15' 'Nilai(Rp.)'   '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'ICON'      ''          ''          ''  '4'  'Sts'          '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' ''  '7'  'UsrGrp1'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDEPT1'    'ZFH_KR1AT' 'ZDEPT1'    ''  '7'  'Depart1'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDDESC1'   'ZFDEPT'    'ZDESC'     ''  '10' 'Desc1'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZGOLUSER1' 'ZFH_KR1AT' 'STSREL1'   ''  ''   'Gol.1'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' ''  '7'  'UsrGrp2'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDEPT2'    'ZFH_KR1AT' 'ZDEPT2'    ''  '7'  'Depart2'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDDESC2'   'ZFDEPT'    'ZDESC'     ''  '10' 'Desc2'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZGOLUSER2' 'ZFH_KR1AT' 'STSREL2'   ''  ''   'Gol.2'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    ''  ''   'Status'       '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    ''  ''   'Keterangan'   '' '' '' '' '' '' '' '' ''.

    WHEN radio3.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'NOFORM'    'ZFH_KR1AT' 'NOFORM'    ''  ''    'No. FORM3'   '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KUNNR'     'ZFH_KR1AT' 'KUNNR'     ''  ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAME1'     'KNA1'      'NAME1'     ''  '25'  'Nama Outlet' '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZUONR'     'ZFH_KR1AT' 'ZUONR'     ''  ''    'No.DO/CN'    '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUDAT'     'ZFH_KR1AT' 'BUDAT'     ''  ''    'Tanggal'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WAERS'     'ZFH_KR1AT' 'WAERS'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'WRBTR'     'ZFH_KR1AT' 'WRBTR'     ''  '15'  'Nilai(Rp.)'  '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'STATUS'    'ZFH_KR1AT' 'STATUS'    'X' ''    'Status'      '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL1'   'ZFH_KR1AT' ''          ''  '8'   'Golongan'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL2'   'ZFH_KR1AT' ''          ''  '8'   'Golongan'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL3'   'ZFH_KR1AT' ''          ''  '8'   'Golongan'    '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT3'    'ZFH_KR1AT' 'SGTXT3'    ''  ''    'Giro'        '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL4'   'ZFH_KR1AT' 'STSREL4'   'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'STSREL5'   'ZFH_KR1AT' 'STSREL5'   'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BUKRS'     'ZFH_KR1AT' 'BUKRS'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GSBER'     'ZFH_KR1AT' 'GSBER'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'VKBUR'     'ZFH_KR1AT' 'VKBUR'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DTFORM'    'ZFH_KR1AT' 'DTFORM'    'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNR'     'ZFH_KR1AT' 'BELNR'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHR'     'ZFH_KR1AT' 'GJAHR'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BLDAT'     'ZFH_KR1AT' 'BLDAT'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZFBDT'     'ZFH_KR1AT' 'ZFBDT'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZTERM'     'ZFH_KR1AT' 'ZTERM'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'KLIMK'     'ZFH_KR1AT' 'KLIMK'     'X' ''    ''            '' '' '' '' '' 'WAERS' '' '' '',
        'FT_REPORT' 'OVERDSO'   'ZFH_KR1AT' 'OVERDSO'   'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDESC1'    'ZFH_KR1AT' 'ZDESC1'    'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USNAM'     'ZFH_KR1AT' 'USNAM'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UTIME'     'ZFH_KR1AT' 'UTIME'     'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP1' 'ZFH_KR1AT' 'USRGROUP1' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDEPT1'    'ZFH_KR1AT' 'ZDEPT1'    'X' '7'   'Depart1'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDDESC1'   'ZFDEPT'    'ZDESC'     'X' '10'  'Desc1'       '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL1'  'ZFH_KR1AT' 'NAMEREL1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL1'  'ZFH_KR1AT' 'DATEREL1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL1'  'ZFH_KR1AT' 'TIMEREL1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP2' 'ZFH_KR1AT' 'USRGROUP2' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDEPT2'    'ZFH_KR1AT' 'ZDEPT2'    'X' '7'   'Depart1'     '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'ZDDESC2'   'ZFDEPT'    'ZDESC'     'X' '10'  'Desc1'       '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL2'  'ZFH_KR1AT' 'NAMEREL2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL2'  'ZFH_KR1AT' 'DATEREL2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL2'  'ZFH_KR1AT' 'TIMEREL2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP3' 'ZFH_KR1AT' 'USRGROUP3' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL3'  'ZFH_KR1AT' 'NAMEREL3'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL3'  'ZFH_KR1AT' 'DATEREL3'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL3'  'ZFH_KR1AT' 'TIMEREL3'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP4' 'ZFH_KR1AT' 'USRGROUP4' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL4'  'ZFH_KR1AT' 'NAMEREL4'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL4'  'ZFH_KR1AT' 'DATEREL4'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL4'  'ZFH_KR1AT' 'TIMEREL4'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'USRGROUP5' 'ZFH_KR1AT' 'USRGROUP5' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEREL5'  'ZFH_KR1AT' 'NAMEREL5'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEREL5'  'ZFH_KR1AT' 'DATEREL5'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEREL5'  'ZFH_KR1AT' 'TIMEREL5'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS1'  'ZFH_KR1AT' 'NAMEPOS1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ1'    'ZFH_KR1AT' 'UMSKZ1'    'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS1' 'ZFH_KR1AT' 'BELNRPOS1' 'X' ''    ''            '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS1' 'ZFH_KR1AT' 'GJAHRPOS1' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS1'  'ZFH_KR1AT' 'DATEPOS1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS1'  'ZFH_KR1AT' 'TIMEPOS1'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT1'    'ZFH_KR1AT' 'SGTXT1'    'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'NAMEPOS2'  'ZFH_KR1AT' 'NAMEPOS2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'UMSKZ2'    'ZFH_KR1AT' 'UMSKZ2'    'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'BELNRPOS2' 'ZFH_KR1AT' 'BELNRPOS2' 'X' ''    ''            '' 'X' '' '' '' '' '' '' '',
        'FT_REPORT' 'GJAHRPOS2' 'ZFH_KR1AT' 'GJAHRPOS2' 'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'DATEPOS2'  'ZFH_KR1AT' 'DATEPOS2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'TIMEPOS2'  'ZFH_KR1AT' 'TIMEPOS2'  'X' ''    ''            '' '' '' '' '' '' '' '' '',
        'FT_REPORT' 'SGTXT2'    'ZFH_KR1AT' 'SGTXT2'    'X' ''    ''            '' '' '' '' '' '' '' '' ''.
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
  CASE 'X'.
    WHEN radio1 OR radio2.
      IF va_valid IS INITIAL.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'NOFORM'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
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
  CASE 'X'.
    WHEN radio1 OR radio2.
      PERFORM f_hdr_uline.
      PERFORM f_hdr_line4 USING ''.
    WHEN radio3.
      PERFORM f_hdr_uline.
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
    WHEN radio1 OR radio2.
      IF va_valid EQ 1.
        SET PF-STATUS 'TOEXECUTE'.
      ELSE.
        SET PF-STATUS 'TOVALID'.
      ENDIF.
    WHEN radio3.
      SET PF-STATUS 'STANDARD'.
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
  DATA: ld_zgol    LIKE zscl_level-zgol,
        ld_zgol1   LIKE zscl_level-zgol,
        ld_strlen  TYPE i.

  CASE 'X'.
    WHEN radio1 OR radio2.
      SORT t_zfh_kr1at BY kunnr.
      SORT t_kna1 BY kunnr.
      LOOP AT t_zfh_kr1at.
        t_out-kunnr = t_zfh_kr1at-kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_zfh_kr1at-kunnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_out-name1 = t_kna1-name1.
          IF t_kna1-kvgr3 IS NOT INITIAL.
            AUTHORITY-CHECK OBJECT 'ZSKVGR3'
                ID 'KVGR3' FIELD t_kna1-kvgr3.
            IF sy-subrc NE 0.
              CLEAR t_out.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
        t_out-sgtxt3      = t_zfh_kr1at-sgtxt3.
        t_out-noform      = t_zfh_kr1at-noform.
        t_out-bukrs       = t_zfh_kr1at-bukrs.
        t_out-gsber       = t_zfh_kr1at-gsber.
        t_out-vkbur       = t_zfh_kr1at-vkbur.
        t_out-klimk       = t_zfh_kr1at-klimk.
        t_out-waers       = t_zfh_kr1at-waers.
        t_out-zuonr       = t_zfh_kr1at-zuonr.
        t_out-budat       = t_zfh_kr1at-budat.
        t_out-wrbtr       = t_zfh_kr1at-wrbtr.
        t_out-status      = t_zfh_kr1at-status.
        t_out-zdesc1      = t_zfh_kr1at-zdesc1.
        t_out-belnr       = t_zfh_kr1at-belnr.
        t_out-gjahr       = t_zfh_kr1at-gjahr.
        t_out-belnrpos1   = t_zfh_kr1at-belnrpos1.

        t_out-zgoluser1   = t_zfh_kr1at-stsrel1.
        t_out-zgoluser2   = t_zfh_kr1at-stsrel2.
        t_out-zgoluser3   = t_zfh_kr1at-stsrel3.
        t_out-zgoluser4   = t_zfh_kr1at-stsrel4.
        t_out-zgoluser5   = t_zfh_kr1at-stsrel5.

        t_out-usrgroup1   = t_zfh_kr1at-usrgroup1.
        t_out-usrgroup2   = t_zfh_kr1at-usrgroup2.
        t_out-usrgroup3   = t_zfh_kr1at-usrgroup3.
        t_out-usrgroup4   = t_zfh_kr1at-usrgroup4.
        t_out-usrgroup5   = t_zfh_kr1at-usrgroup5.

        t_out-zdept1      = t_zfh_kr1at-zdept1.
        READ TABLE t_zfdept WITH KEY zdept = t_zfh_kr1at-zdept1.
        IF sy-subrc EQ 0.
          t_out-zddesc1   = t_zfdept-zdesc.
        ENDIF.
        t_out-zdept2      = t_zfh_kr1at-zdept2.
        READ TABLE t_zfdept WITH KEY zdept = t_zfh_kr1at-zdept2.
        IF sy-subrc EQ 0.
          t_out-zddesc2   = t_zfdept-zdesc.
        ENDIF.

*        IF t_zfh_kr1at-stsrel1 IS INITIAL.
*          IF t_zfh_kr1at-stsrel2 IS NOT INITIAL.
*            t_out-icon = icon_led_yellow.
*          ELSE.
*            t_out-icon = space.
*          ENDIF.
*        ELSE.
*          IF t_zfh_kr1at-stsrel2 IS INITIAL.
*            t_out-icon = icon_led_yellow.
*          ELSE.
*            t_out-icon = icon_release.
*          ENDIF.
*        ENDIF.

        IF t_zfh_kr1at-stsrel1 IS NOT INITIAL AND
          t_zfh_kr1at-stsrel2 IS NOT INITIAL.
          t_out-icon = icon_release.
        ELSE.
          t_out-icon = icon_led_yellow.
        ENDIF.

        APPEND t_out.
        CLEAR: t_out-name1, ld_zgol1, t_out-zddesc1, t_out-zddesc2.
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
  ENDCASE.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: lv_error TYPE i.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&STA'.
      CASE 'X'.
        WHEN radio1.
          IF va_count EQ 0.
            va_count = 1.
            PERFORM f_alv TABLES t_out1.
          ELSE.
            va_count = 0.
            PERFORM f_alv TABLES t_out.
          ENDIF.
          LEAVE TO SCREEN 0.

        WHEN radio2.
          IF va_count EQ 0.
            va_count = 1.
            PERFORM f_alv TABLES t_out2.
          ELSE.
            va_count = 0.
            PERFORM f_alv TABLES t_out.
          ENDIF.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&VAL'.
      PERFORM f_validate_data CHANGING lv_error.
      IF va_count EQ 0.
        PERFORM f_alv TABLES t_out.
      ELSE.
        CASE 'X'.
          WHEN radio1.
            PERFORM f_alv TABLES t_out1.
          WHEN radio2.
            PERFORM f_alv TABLES t_out2.
        ENDCASE.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN '&PRC'.
      PERFORM f_post_entries ON COMMIT.
      IF sy-subrc EQ 0.
        PERFORM f_table_unlocking.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN '&IC1'.
      CASE 'X'.
        WHEN radio1 OR radio2.
          CHECK NOT fu_selfield-tabindex IS INITIAL.
          CASE va_count.
            WHEN 0.
              READ TABLE t_out INDEX fu_selfield-tabindex.
              SET PARAMETER ID 'BLN' FIELD t_out-belnr.
              SET PARAMETER ID 'BUK' FIELD t_out-bukrs.
              SET PARAMETER ID 'GJR' FIELD t_out-gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            WHEN 1.
              READ TABLE t_out1 INDEX fu_selfield-tabindex.
              SET PARAMETER ID 'BLN' FIELD t_out1-belnr.
              SET PARAMETER ID 'BUK' FIELD t_out1-bukrs.
              SET PARAMETER ID 'GJR' FIELD t_out1-gjahr.
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
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.
  DATA: BEGIN OF lt_zfh_kr1at OCCURS 0.
          INCLUDE STRUCTURE zfh_kr1at.
  DATA: END OF lt_zfh_kr1at.

  SORT t_out BY bukrs gsber vkbur zuonr.
  SORT t_out1 BY bukrs gsber vkbur zuonr.
  SORT t_zfh_kr1at BY bukrs gsber vkbur zuonr.

  CASE va_count.
    WHEN 0.
      t_data[] = t_out[].
    WHEN 1.
      CASE 'X'.
        WHEN radio1.
          t_data[] = t_out1[].
        WHEN radio2.
          t_data[] = t_out2[].
      ENDCASE.
  ENDCASE.

  LOOP AT t_data WHERE check EQ 'X' AND
                       icon  EQ icon_led_green.
    READ TABLE t_zfh_kr1at WITH KEY bukrs = t_data-bukrs
                                    gsber = t_data-gsber
                                    vkbur = t_data-vkbur
                                    zuonr = t_data-zuonr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      CASE 'X'.
        WHEN radio1.
          IF t_data-zgoluser1 IS NOT INITIAL.
            t_zfh_kr1at-stsrel1    = t_data-zgoluser1.
            t_zfh_kr1at-usrgroup1  = t_data-usrgroup1.
            t_zfh_kr1at-zdept1     = t_data-zdept1.
            IF t_zfh_kr1at-namerel1 IS INITIAL.
              t_zfh_kr1at-namerel1   = sy-uname.
              t_zfh_kr1at-daterel1   = sy-datum.
              t_zfh_kr1at-timerel1   = sy-uzeit.
            ENDIF.
          ENDIF.
          IF t_data-zgoluser2 IS NOT INITIAL.
            t_zfh_kr1at-stsrel2    = t_data-zgoluser2.
            t_zfh_kr1at-usrgroup2  = t_data-usrgroup2.
            t_zfh_kr1at-zdept2     = t_data-zdept2.
            IF t_zfh_kr1at-namerel2 IS INITIAL.
              t_zfh_kr1at-namerel2   = sy-uname.
              t_zfh_kr1at-daterel2   = sy-datum.
              t_zfh_kr1at-timerel2   = sy-uzeit.
            ENDIF.
          ENDIF.

        WHEN radio2.
          IF t_data-usrgroup1 EQ va_usrgroup.
            CLEAR: t_zfh_kr1at-usrgroup1, t_zfh_kr1at-zdept1, t_zfh_kr1at-stsrel1,
                   t_zfh_kr1at-namerel1, t_zfh_kr1at-daterel1, t_zfh_kr1at-timerel1.
          ENDIF.

          IF t_data-usrgroup2 EQ va_usrgroup.
            CLEAR: t_zfh_kr1at-usrgroup2, t_zfh_kr1at-zdept2, t_zfh_kr1at-stsrel2,
                   t_zfh_kr1at-namerel2, t_zfh_kr1at-daterel2, t_zfh_kr1at-timerel2.
          ENDIF.
      ENDCASE.

      MODIFY t_zfh_kr1at TRANSPORTING usrgroup1 zdept1 stsrel1 namerel1 daterel1 timerel1
                                      usrgroup2 zdept2 stsrel2 namerel2 daterel2 timerel2
        WHERE bukrs  EQ t_data-bukrs       AND
              gsber  EQ t_data-gsber       AND
              vkbur  EQ t_data-vkbur       AND
              noform EQ t_zfh_kr1at-noform AND
              zuonr  EQ t_data-zuonr.

      lt_zfh_kr1at = t_zfh_kr1at.
      APPEND lt_zfh_kr1at.
    ENDIF.
    CLEAR: t_zfh_kr1at.
  ENDLOOP.

  UPDATE zfh_kr1at FROM TABLE lt_zfh_kr1at.
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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data CHANGING fc_error.
  DATA: lv_error TYPE i,
        lv_rec1  TYPE i,
        lv_rec2  TYPE i,
        lv_icon(4).

  CLEAR: t_error1, t_error1[].

  CASE va_count.
    WHEN 0.
      CASE 'X'.
        WHEN radio1.
          DESCRIBE TABLE t_out LINES lv_rec1.
          LOOP AT t_out.
            IF t_out-status EQ 'Z'.
              PERFORM f_validasi_z USING lv_rec1 t_out-usrgroup1
                                   CHANGING lv_error lv_rec2 lv_icon.
              t_out-icon  = lv_icon.
              IF lv_icon EQ icon_led_green.
                IF t_out-usrgroup1 IS INITIAL.
                  t_out-usrgroup1 = va_usrgroup.
                  t_out-zgoluser1 = va_zgoluser.
                  t_out-zdept1    = va_zdept.
                  MODIFY t_out TRANSPORTING icon usrgroup1 zgoluser1 zdept1.
                ELSE.
                  t_out-usrgroup2 = va_usrgroup.
                  t_out-zgoluser2 = va_zgoluser.
                  t_out-zdept2    = va_zdept.
                  MODIFY t_out TRANSPORTING icon usrgroup2 zgoluser2 zdept2.
                ENDIF.
              ENDIF.
            ELSE.
              PERFORM f_validasi_non_z USING lv_rec1 va_count
                                       CHANGING lv_error lv_rec2.
            ENDIF.
          ENDLOOP.

        WHEN radio2.
          DESCRIBE TABLE t_out LINES lv_rec1.
          LOOP AT t_out.
            IF t_out-check EQ 'X'.
              IF t_out-belnrpos1 IS NOT INITIAL.
                lv_error = 4.
              ELSE.
                IF t_out-icon IS INITIAL.
                  lv_error = 3.
                  EXIT.
                ELSE.
                  PERFORM f_validasi_release TABLES t_out
                                             CHANGING lv_error.
                  IF lv_error IS INITIAL AND
                    t_out-icon IS INITIAL.
                    lv_error = 5.
                  ELSE.
                    IF t_error5[] IS NOT INITIAL.
                      lv_error = 5.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              ADD 1 TO lv_rec2.
              IF t_out-icon EQ icon_release.
              ELSE.
                IF t_out-icon EQ icon_led_yellow.
                  t_out-icon = icon_led_yellow.
                ELSE.
                  IF t_out-zgoluser1 IS NOT INITIAL.
                    IF t_out-zgoluser2 IS NOT INITIAL.
                      t_out-icon = icon_release.
                    ELSE.
                      t_out-icon = icon_led_yellow.
                    ENDIF.
                  ELSE.
                    IF t_out-zgoluser2 IS NOT INITIAL.
                      t_out-icon = icon_led_yellow.
                    ELSE.
                      CLEAR: t_out-icon.
                    ENDIF.
                  ENDIF.
                ENDIF.
                MODIFY t_out TRANSPORTING icon.
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.

    WHEN 1.
      CASE 'X'.
        WHEN radio1.
          DESCRIBE TABLE t_out1 LINES lv_rec1.
          LOOP AT t_out1.
            IF t_out-status EQ 'Z'.
              PERFORM f_validasi_z USING lv_rec1 t_out-usrgroup1
                                   CHANGING lv_error lv_rec2 lv_icon.
              t_out1-icon  = lv_icon.
              MODIFY t_out TRANSPORTING icon.
            ELSE.
              PERFORM f_validasi_non_z USING lv_rec1 va_count
                                       CHANGING lv_error lv_rec2.
            ENDIF.
          ENDLOOP.

        WHEN radio2.
          DESCRIBE TABLE t_out2 LINES lv_rec1.
          LOOP AT t_out2.
            IF t_out2-check EQ 'X'.
              IF t_out-belnrpos1 IS NOT INITIAL.
                lv_error = 4.
              ELSE.
                IF t_out2-icon IS INITIAL.
                  lv_error = 3.
                  EXIT.
                ELSE.
                  PERFORM f_validasi_release TABLES t_out2
                                             CHANGING lv_error.
                  IF lv_error IS INITIAL AND
                    t_out-icon IS INITIAL.
                    lv_error = 5.
                  ELSE.
                    IF t_error5[] IS NOT INITIAL.
                      lv_error = 5.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              ADD 1 TO lv_rec2.
              IF t_out-icon EQ icon_release.
              ELSE.
                IF t_out-icon EQ icon_led_yellow.
                  t_out-icon = icon_led_yellow.
                ELSE.
                  IF t_out-zgoluser1 IS NOT INITIAL.
                    IF t_out-zgoluser2 IS NOT INITIAL.
                      t_out-icon = icon_release.
                    ELSE.
                      t_out-icon = icon_led_yellow.
                    ENDIF.
                  ELSE.
                    CLEAR: t_out-icon.
                  ENDIF.
                ENDIF.
                MODIFY t_out TRANSPORTING icon.
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.
  ENDCASE.

  IF lv_rec1 = lv_rec2.
    lv_error = 2.
  ENDIF.

  IF lv_error IS INITIAL.
    va_valid = 1.
  ELSE.
    CASE lv_error.
      WHEN 1.
        va_valid = 1.
      WHEN 2.
        MESSAGE i000(zab) WITH 'No data to be processed'.
      WHEN 3.
        CASE 'X'.
          WHEN radio1.
            MESSAGE i000(zab) WITH 'Document have been released'.
          WHEN radio2.
            MESSAGE i000(zab) WITH 'Document have not been released'.
        ENDCASE.
      WHEN 4.
        MESSAGE i000(zab) WITH 'Document already posted'.
      WHEN 5.
        MESSAGE i000(zab) WITH 'You are not authorized'.
    ENDCASE.
  ENDIF.

  fc_error = lv_error.
ENDFORM.                    " f_validate_data

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0695   text
*----------------------------------------------------------------------*
FORM f_hdr_line4  USING fu_title.
  DATA: lv_ketr(100),
        lv_value(20),
        lv_zdesc(40),
        lv_usrgrp LIKE usgroups-usergroup.

  SKIP 1.
  WRITE: / sy-uline(37).
  WRITE: / sy-vline, icon_release AS ICON, (30)'= Document have been released', sy-vline.
  CASE 'X'.
    WHEN radio1.
      WRITE: / sy-vline, icon_led_green AS ICON, (30)'= Release OK', sy-vline.
      WRITE: / sy-vline, icon_led_yellow AS ICON, (30)'= Release was not completed', sy-vline.
    WHEN radio2.
      WRITE: / sy-vline, icon_led_green AS ICON, (30)'= Unrelease OK', sy-vline.
      WRITE: / sy-vline, icon_led_yellow AS ICON, (30)'= Unrelease was not completed', sy-vline.
  ENDCASE.
  WRITE: / sy-vline, icon_led_red AS ICON, (30)'= You are not authorized', sy-vline.
  WRITE: / sy-uline(37).

  WRITE va_wrbtr TO lv_value CURRENCY 'IDR'.

  SELECT SINGLE usergroup
    FROM zfusrrel_form3
    INTO lv_usrgrp
    WHERE zlevel_hdr EQ va_zlevel.

  SELECT SINGLE zdesc
    FROM zfdept
    INTO lv_zdesc
    WHERE zdept EQ va_zdept.

  CONCATENATE 'User Group : ' va_usrgroup '(' va_zgoluser ')' INTO lv_ketr
  SEPARATED BY space.

  FORMAT COLOR 5.
  WRITE:/(sy-linsz) lv_ketr.

  CONCATENATE 'Departement : ' va_zdept lv_zdesc INTO lv_ketr
  SEPARATED BY space.
  WRITE:/(sy-linsz) lv_ketr.

  FORMAT COLOR OFF.
ENDFORM.                    " f_hdr_line4

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
    WHEN radio1.
      LOOP AT t_zfh_kr1at INTO lw_zfh_kr1at WHERE stsrel1 EQ space.
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

    WHEN radio2.
      LOOP AT t_zfh_kr1at INTO lw_zfh_kr1at WHERE stsrel1 NE space.
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
    t_error1-msg = 'Error when processing'.
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
  IF t_error1[] IS INITIAL OR
    t_error5[] IS INITIAL.
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

  IF t_error5[] IS NOT INITIAL.
    ULINE AT /(87).
    WRITE: /  sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO/CN' NO-GAP,
              sy-vline NO-GAP, (50) 'Error message' NO-GAP,
              sy-vline.
    ULINE AT /(87).
    LOOP AT t_error5.
      WRITE: /  sy-vline NO-GAP, (15) t_error5-kunnr NO-GAP,
                sy-vline NO-GAP, t_error5-zuonr NO-GAP,
                sy-vline NO-GAP, t_error5-msg(50) NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(87).
  ENDIF.

ENDFORM.                    " f_error_list

*&---------------------------------------------------------------------*
*&      Form  f_table_unlocking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_table_unlocking .
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
ENDFORM.                    " f_table_unlocking

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
  ELSE.
    AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
        ID 'VKBUR' FIELD pa_vkbur.
    IF sy-subrc <> 0.
      va_error  = 1.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'VKB'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      MESSAGE e000(zab) WITH 'You are not authorized with Sales Office' pa_vkbur.
      CLEAR: sscrfields-ucomm.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_validasi_release
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validasi_release TABLES ft_out STRUCTURE t_out
                        CHANGING fv_error.

  IF radio1 EQ 'X'.
    CASE ft_out-icon.
      WHEN icon_led_red.
        fv_error    = 5.

      WHEN icon_led_yellow.
        DELETE t_error5 WHERE kunnr EQ ft_out-kunnr
                          AND zuonr EQ ft_out-zuonr.

        IF ft_out-zgoluser1 IS INITIAL.
          IF ft_out-usrgroup2 EQ va_usrgroup.
            t_error5-kunnr = t_out-kunnr.
            t_error5-zuonr = t_out-zuonr.
            t_error5-msg   = 'You are not authorized (Gol. User Kosong)'.
            APPEND t_error5.
            fv_error    = 5.
            ft_out-icon = icon_led_red.
          ELSE.
            PERFORM f_cek_value USING ft_out-wrbtr ft_out-zgoluser1
                                CHANGING fv_error ft_out-icon.

            IF fv_error IS INITIAL.
              ft_out-zgoluser1 = va_zgoluser.
              ft_out-usrgroup1 = va_usrgroup.
              READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                                   usergroup  = va_usrgroup.
              IF sy-subrc EQ 0.
                ft_out-zdept1    = t_zfusrrel_form3-zdept.
              ENDIF.
              ft_out-icon      = icon_led_green.
            ENDIF.
          ENDIF.
        ELSE.
          IF va_zgoluser EQ 'A'.
            IF ft_out-usrgroup1 EQ va_usrgroup.
              t_error5-kunnr = t_out-kunnr.
              t_error5-zuonr = t_out-zuonr.
              t_error5-msg   = 'You are not authorized (Gol. User A)'.
              APPEND t_error5.
              fv_error    = 5.
              ft_out-icon = icon_led_red.
            ELSE.
              ft_out-zgoluser2 = va_zgoluser.
              ft_out-usrgroup2 = va_usrgroup.
              IF ft_out-zdept1 IS NOT INITIAL.
                READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                                     usergroup  = va_usrgroup.
                IF sy-subrc EQ 0.
                  ft_out-zdept2    = t_zfusrrel_form3-zdept.
                ENDIF.
              ENDIF.
              ft_out-icon = icon_led_green.
            ENDIF.
          ELSE.
* Cek Golongan & Value
            PERFORM f_cek_value USING ft_out-wrbtr ft_out-zgoluser1
                                CHANGING fv_error ft_out-icon.

* Cek Username
            IF fv_error IS INITIAL.
              IF ft_out-usrgroup1 EQ va_usrgroup.
                t_error5-kunnr = t_out-kunnr.
                t_error5-zuonr = t_out-zuonr.
                t_error5-msg   = 'You are not authorized (usrgroup1)'.
                APPEND t_error5.
                fv_error    = 5.
                ft_out-icon = icon_led_red.
              ENDIF.
            ENDIF.

* Cek Departement
            IF fv_error IS INITIAL.
              CASE ft_out-zdept1.
                WHEN '*'.
                WHEN OTHERS.
                  READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                                       usergroup  = va_usrgroup.
                  IF sy-subrc EQ 0.
                    IF t_zfusrrel_form3-zdept EQ ft_out-zdept1.
                      t_error5-kunnr = t_out-kunnr.
                      t_error5-zuonr = t_out-zuonr.
                      t_error5-msg   = 'You are not authorized (Departement)'.
                      APPEND t_error5.
                      fv_error    = 5.
                      ft_out-icon = icon_led_red.
                    ENDIF.
                  ENDIF.
              ENDCASE.
            ENDIF.

            IF fv_error IS INITIAL.
              ft_out-zgoluser2 = va_zgoluser.
              ft_out-usrgroup2 = va_usrgroup.
              IF ft_out-zdept1 IS NOT INITIAL.
                READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                                     usergroup  = va_usrgroup.
                IF sy-subrc EQ 0.
                  ft_out-zdept2    = t_zfusrrel_form3-zdept.
                ENDIF.
              ENDIF.
              ft_out-icon = icon_led_green.
            ELSE.
              va_valid = 0.
            ENDIF.
          ENDIF.
        ENDIF.

*        IF ft_out-zdept1 IS NOT INITIAL.
*          READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
*                                               usergroup  = va_usrgroup.
*          IF sy-subrc EQ 0.
*            ft_out-zdept2    = t_zfusrrel_form3-zdept.
*          ENDIF.

        IF ft_out-icon EQ icon_led_red.
        ELSE.
          IF ft_out-zdept1 IS NOT INITIAL.
            IF ft_out-zdept1 EQ ft_out-zdept2.
              t_error5-kunnr = t_out-kunnr.
              t_error5-zuonr = t_out-zuonr.
              t_error5-msg   = 'You are not authorized (Departement harus beda)'.
              APPEND t_error5.
              fv_error    = 5.
              ft_out-icon = icon_led_red.
            ELSE.
              ft_out-icon = icon_led_green.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN icon_led_green.
        va_valid = 1.
        DELETE t_error5 WHERE kunnr EQ ft_out-kunnr
                          AND zuonr EQ ft_out-zuonr.

      WHEN OTHERS.
        DELETE t_error5 WHERE kunnr EQ ft_out-kunnr
                          AND zuonr EQ ft_out-zuonr.

        IF va_zgoluser IS INITIAL.
          t_error5-kunnr = t_out-kunnr.
          t_error5-zuonr = t_out-zuonr.
          t_error5-msg   = 'You are not authorized (Gol. User kosong)'.
          APPEND t_error5.
          fv_error    = 5.
          ft_out-icon = icon_led_red.
        ELSE.
          ft_out-zgoluser1 = va_zgoluser.
          ft_out-usrgroup1 = va_usrgroup.
          READ TABLE t_zfusrrel_form3 WITH KEY bukrs = pa_bukrs
                                               usergroup  = va_usrgroup.
          IF sy-subrc EQ 0.
            ft_out-zdept1    = t_zfusrrel_form3-zdept.
          ENDIF.
          ft_out-icon      = icon_led_green.
        ENDIF.
    ENDCASE.
  ENDIF.

  IF radio2 EQ 'X'.
    CASE ft_out-icon.
      WHEN icon_led_red.
        fv_error = 5.

      WHEN icon_led_green.
        CLEAR: fv_error.

      WHEN icon_release.
        IF ft_out-usrgroup1 IS NOT INITIAL.
          IF ft_out-usrgroup1 EQ va_usrgroup.
            ft_out-icon  = icon_led_green.
          ENDIF.
          IF ft_out-icon EQ icon_led_green.
            ft_out-icon  = icon_led_green.
          ELSE.
            IF ft_out-usrgroup2 EQ va_usrgroup.
              ft_out-icon  = icon_led_green.
            ELSE.
              t_error5-kunnr = t_out-kunnr.
              t_error5-zuonr = t_out-zuonr.
              t_error5-msg   = 'You are not authorized (User grp tdk sama)'.
              APPEND t_error5.
              fv_error     = 5.
              ft_out-icon  = icon_led_red.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
        IF ft_out-usrgroup1 IS NOT INITIAL.
          IF ft_out-usrgroup1 EQ va_usrgroup.
            ft_out-icon  = icon_led_green.
          ELSE.
            t_error5-kunnr = t_out-kunnr.
            t_error5-zuonr = t_out-zuonr.
            t_error5-msg   = 'You are not authorized (User grp tdk sama)'.
            APPEND t_error5.
            fv_error     = 5.
            ft_out-icon  = icon_led_red.
          ENDIF.
        ELSE.
          IF ft_out-usrgroup2 IS NOT INITIAL.
            IF ft_out-usrgroup2 EQ va_usrgroup.
              ft_out-icon  = icon_led_green.
            ELSE.
              t_error5-kunnr = t_out-kunnr.
              t_error5-zuonr = t_out-zuonr.
              t_error5-msg   = 'You are not authorized (User grp tdk sama)'.
              APPEND t_error5.
              fv_error     = 5.
              ft_out-icon  = icon_led_red.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

  MODIFY ft_out TRANSPORTING icon zgoluser1 usrgroup1
                                  zgoluser2 usrgroup2
                                  zgoluser3 usrgroup3
                                  zdept1 zdept2.
ENDFORM.                    " f_validasi_release

*&---------------------------------------------------------------------*
*&      Form  F_CEK_VALUE
*&---------------------------------------------------------------------*
FORM f_cek_value  USING    fu_wrbtr fu_goluser
                  CHANGING fc_error fc_icon.

  DATA: ld_zgol     LIKE zscl_level-zgol,
        ld_zvalue   LIKE zscl_level-zvalue,
        ld_stsrel1  LIKE zfh_kr1at-stsrel1,
        ld_stsrel2  LIKE zfh_kr1at-stsrel2.

  READ TABLE t_zscl_level WITH KEY zgol = va_zgoluser
                                   bukrs = pa_bukrs.
  IF sy-subrc EQ 0.
    IF fu_wrbtr LE t_zscl_level-zvalue.
      CLEAR: fc_error.
    ELSE.
      t_error5-kunnr = t_out-kunnr.
      t_error5-zuonr = t_out-zuonr.
      t_error5-msg   = 'You are not authorized (Gol. User NE zscl_level )'.
      APPEND t_error5.
      fc_error    = 5.
      fc_icon = icon_led_red.
    ENDIF.
  ENDIF.

*  LOOP AT t_zscl_level.
*    IF fu_wrbtr LE t_zscl_level-zvalue.
*      ld_zgol   = t_zscl_level-zgol.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

*  SPLIT ld_zgol AT ',' INTO ld_stsrel1 ld_stsrel2.

*  IF va_zgoluser EQ 'A' AND fu_flag IS INITIAL.
*    CLEAR: fc_error.
*  ELSE.
*  IF va_zgoluser EQ ld_stsrel1.
*    CLEAR: fc_error.
*  ELSE.
*    t_error5-kunnr = t_out-kunnr.
*    t_error5-zuonr = t_out-zuonr.
*    t_error5-msg   = 'You are not authorized (Gol. User NE zscl_level )'.
*    APPEND t_error5.
*    fc_error    = 5.
*    fc_icon = icon_led_red.
*  ENDIF.
*  ENDIF.
ENDFORM.                    " F_CEK_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_NON_Z
*&---------------------------------------------------------------------*
FORM f_validasi_non_z USING fu_rec1 fu_count
                      CHANGING fc_error fc_rec2.

  CASE fu_count.
    WHEN 0.

      IF t_out-check EQ 'X'.
        IF t_out-icon EQ icon_release.
          fc_error = 3.
        ELSE.
          PERFORM f_validasi_release TABLES t_out
                                     CHANGING fc_error.
          IF fc_error IS INITIAL AND
            t_out-icon IS INITIAL.
            fc_error = 5.
          ELSE.
            IF t_error5[] IS NOT INITIAL.
              fc_error = 5.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        ADD 1 TO fc_rec2.
        IF t_out-icon EQ icon_release.
        ELSE.
          IF t_out-icon EQ icon_led_yellow.
            t_out-icon = icon_led_yellow.
          ELSE.
            IF t_out-zgoluser1 IS NOT INITIAL.
              t_out-icon = icon_led_yellow.
            ELSE.
              CLEAR: t_out-icon.
            ENDIF.
          ENDIF.
          MODIFY t_out TRANSPORTING icon.
        ENDIF.
      ENDIF.

    WHEN 1.
      IF t_out1-check EQ 'X'.
        IF t_out1-icon EQ icon_release.
          fc_error = 3.
        ELSE.
          PERFORM f_validasi_release TABLES t_out1
                                     CHANGING fc_error.
          IF fc_error IS INITIAL AND
            t_out-icon IS INITIAL.
            fc_error = 5.
          ELSE.
            IF t_error5[] IS NOT INITIAL.
              fc_error = 5.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        ADD 1 TO fc_rec2.
        IF t_out1-icon EQ icon_release.
        ELSE.
          IF t_out-icon EQ icon_led_yellow.
            t_out-icon = icon_led_yellow.
          ELSE.
            IF t_out-zgoluser1 IS NOT INITIAL.
              t_out-icon = icon_led_yellow.
            ELSE.
              CLEAR: t_out-icon.
            ENDIF.
          ENDIF.
          MODIFY t_out1 TRANSPORTING icon.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDASI_NON_Z

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_Z
*&---------------------------------------------------------------------*
FORM f_validasi_z USING fu_rec1 fu_usrgroup
                  CHANGING fc_error fc_rec2 fc_icon.
  IF va_usrgroup NE 'MDSO' AND
    va_usrgroup NE 'FD'.
    t_error5-kunnr = t_out-kunnr.
    t_error5-zuonr = t_out-zuonr.
    t_error5-msg   = 'You are not authorized'.
    APPEND t_error5.
    fc_error    = 5.
    fc_icon     = icon_led_red.
  ELSE.
    fc_icon     = icon_led_green.
  ENDIF.

  IF fu_usrgroup IS NOT INITIAL.
    IF fu_usrgroup EQ va_usrgroup.
      t_error5-kunnr = t_out-kunnr.
      t_error5-zuonr = t_out-zuonr.
      t_error5-msg   = 'You are not authorized'.
      APPEND t_error5.
      fc_error    = 5.
      fc_icon     = icon_led_red.
    ELSE.
      fc_icon     = icon_led_green.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_Z
