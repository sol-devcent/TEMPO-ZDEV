*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
       EXPORTING
            langu = sy-langu
       TABLES
            users = t_user.
  .
  IF sy-subrc <> 0.
  ENDIF.

* Ranges for Billing type
  ra_fkart-low    = 'ZI06'.
  ra_fkart-option = 'EQ'.
  ra_fkart-sign   = 'I'.
  APPEND ra_fkart.

  ra_fkart-low    = 'ZR06'.
  ra_fkart-option = 'EQ'.
  ra_fkart-sign   = 'I'.
  APPEND ra_fkart.

* Ranges for Condition type
  ra_kschl-low    = 'ZHJM'.
  ra_kschl-option = 'EQ'.
  ra_kschl-sign   = 'I'.
  APPEND ra_kschl.

  ra_kschl-low    = 'Z100'.
  ra_kschl-option = 'EQ'.
  ra_kschl-sign   = 'I'.
  APPEND ra_kschl.

  ra_kschl-low    = 'ZS01'.
  ra_kschl-high   = 'ZS02'.
  ra_kschl-option = 'BT'.
  ra_kschl-sign   = 'I'.
  APPEND ra_kschl.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA lt_matnr LIKE t_vbrp OCCURS 0 WITH HEADER LINE.
  DATA ld_kwert LIKE konv-kwert.

* select data based on bill create date
  SELECT vbeln fkart fkdat kurrf knumv erdat FROM vbrk
    INTO CORRESPONDING FIELDS OF TABLE t_vbrk
    WHERE vkorg IN s_vkorg AND       "added by Rahmadi
          fkdat IN s_period AND
          bzirk IN s_bzirk AND
          kunag IN s_kunnr AND
          fkart IN ra_fkart.
*              vbeln IN s_vbeln AND
*              fkart IN s_fkart.
  SORT t_vbrk BY vbeln.

* select bill item
  CHECK NOT t_vbrk[] IS INITIAL.
  SELECT * FROM vbrp
    INTO TABLE t_vbrp
    FOR ALL ENTRIES IN t_vbrk
    WHERE vbeln = t_vbrk-vbeln AND
          vkbur IN s_vkbur     AND
          matnr IN s_matnr.

* Read condition price data
  SELECT * FROM konv
    INTO TABLE t_konv
    FOR ALL ENTRIES IN t_vbrk
    WHERE knumv = t_vbrk-knumv AND
          kschl IN ra_kschl. "'ZHJM'.
  SORT t_konv BY knumv kposn.

* select sold to from sales order
  CHECK NOT t_vbrp[] IS INITIAL.
  SELECT vbeln vkorg vtweg spart kunnr waerk FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE t_vbak
  FOR ALL ENTRIES IN t_vbrp
  WHERE
     vbeln = t_vbrp-aubel.
  SORT t_vbak BY vbeln.

* select base uom
  CHECK NOT t_vbrp[] IS INITIAL.
  lt_matnr[] = t_vbrp[].
  SORT lt_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING matnr.
  CHECK NOT lt_matnr[] IS INITIAL.
  SELECT matnr meins  FROM mara INTO
  CORRESPONDING FIELDS OF TABLE t_mara
  FOR ALL ENTRIES IN lt_matnr
  WHERE
     matnr = lt_matnr-matnr.
  SORT t_mara BY matnr.

* select material group
  CHECK NOT t_mara[] IS INITIAL.
  SELECT matnr mvgr1 mvgr4 FROM mvke INTO
  CORRESPONDING FIELDS OF TABLE t_mvke
  FOR ALL ENTRIES IN t_mara
  WHERE matnr = t_mara-matnr AND
*        vkorg = '8010'       AND
        vkorg IN s_vkorg      AND   "modified by Rahmadi
        vtweg = '10'.
  SORT t_mvke BY matnr vkorg.

* select material group 1 description
  CHECK NOT t_mvke[] IS INITIAL.
  SELECT mvgr1 bezei FROM tvm1t INTO
  CORRESPONDING FIELDS OF TABLE t_tvm1t
  FOR ALL ENTRIES IN t_mvke
  WHERE spras = sy-langu AND
        mvgr1 = t_mvke-mvgr1.
  SORT t_tvm1t BY mvgr1.

* select material group 4 description
  CHECK NOT t_mvke[] IS INITIAL.
  SELECT mvgr4 bezei FROM tvm4t INTO
  CORRESPONDING FIELDS OF TABLE t_tvm4t
  FOR ALL ENTRIES IN t_mvke
  WHERE spras = sy-langu AND
        mvgr4 = t_mvke-mvgr4.
  SORT t_tvm4t BY mvgr4.

* read knvv-bzirk
  CHECK NOT t_vbak[] IS INITIAL.
  SELECT kunnr vkorg vtweg spart bzirk FROM knvv INTO
  CORRESPONDING FIELDS OF TABLE t_knvv
  FOR ALL ENTRIES IN t_vbak
  WHERE
     kunnr = t_vbak-kunnr AND
     vkorg = t_vbak-vkorg AND
     vtweg = t_vbak-vtweg AND
     spart = t_vbak-spart.
  SORT t_knvv BY kunnr vkorg vtweg spart.

  CHECK NOT t_vbak[] IS INITIAL.
* select name1 from kna1
  SELECT kunnr name1 land1 FROM kna1 INTO
  CORRESPONDING FIELDS OF TABLE t_kna1
  FOR ALL ENTRIES IN t_vbak
  WHERE
     kunnr = t_vbak-kunnr AND
     land1 IN s_land1.
  SORT t_kna1 BY kunnr.

* select country desc
  CHECK NOT t_kna1[] IS INITIAL.
  SELECT land1 landx FROM t005t INTO
  CORRESPONDING FIELDS OF TABLE t_t005t
  FOR ALL ENTRIES IN t_kna1
  WHERE
     land1 = t_kna1-land1 AND
     spras = sy-langu.
  SORT t_t005t BY land1.

* select material desc
*  CHECK NOT t_vbrp[] IS INITIAL.
  CHECK NOT lt_matnr[] IS INITIAL.   "modified by Rahmadi
  SELECT matnr maktx FROM makt INTO
  CORRESPONDING FIELDS OF TABLE t_makt
  FOR ALL ENTRIES IN lt_matnr
  WHERE
     matnr = lt_matnr-matnr AND
     spras = sy-langu.
  SORT t_makt BY matnr.

* select region desc
  CHECK NOT t_knvv[] IS INITIAL.
  SELECT bzirk bztxt FROM t171t INTO
  CORRESPONDING FIELDS OF TABLE t_t171t
  FOR ALL ENTRIES IN t_knvv
  WHERE
     bzirk = t_knvv-bzirk AND
     spras = sy-langu.
  SORT t_t171t BY bzirk.

  SELECT * FROM  marm INTO TABLE t_marm
   FOR ALL ENTRIES IN lt_matnr
         WHERE  matnr  = lt_matnr-matnr.
  LOOP AT t_marm.
    IF t_marm-umrez = t_marm-umren.
      DELETE t_marm.
    ENDIF.
  ENDLOOP.
  SORT t_marm BY matnr meinh.

*DATASEL

* assigning values into t_main
  LOOP AT t_vbrp.
    CLEAR t_main.

* read sold to from sales order
    READ TABLE t_vbak WITH KEY
           vbeln = t_vbrp-aubel
           BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_main-kunnr = t_vbak-kunnr.
      t_main-vbels = t_vbak-vbeln.
      t_main-waerk = t_vbak-waerk.
    ENDIF.

* read customer name.
    READ TABLE t_kna1 WITH KEY
           kunnr = t_main-kunnr
           BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_main-name1 = t_kna1-name1.
      t_main-land1 = t_kna1-land1.

* assingning values in vbrp into t_main.
      t_main-vkbur = t_vbrp-vkbur.
      t_main-vbeln = t_vbrp-vbeln.
      t_main-matnr = t_vbrp-matnr.
      t_main-vrkme = t_vbrp-vrkme.
      t_main-fkimg = t_vbrp-fkimg.

* read base UoM
*DATAREAD
      READ TABLE t_mara WITH KEY
         matnr = t_vbrp-matnr
         BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-vrkmeb = t_mara-meins.
      ENDIF.
      IF t_main-vrkme NE t_main-vrkmeb.
        READ TABLE t_marm
          WITH KEY
            matnr = t_main-matnr
            meinh = t_main-vrkme
            BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_main-umrez = t_marm-umrez.
          t_main-umren = t_marm-umren.
** penambahan kondisi untuk base UoM.
        ELSE.
          t_main-umrez = 1.
          t_main-umren = 1.
**
        ENDIF.
      ELSE.
        t_main-umrez = 1.
        t_main-umren = 1.
      ENDIF.

* Read header billing
      READ TABLE t_vbrk WITH KEY
             vbeln = t_vbrp-vbeln
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-vkorg = t_vbrk-vkorg.
        t_main-fkdat = t_vbrk-fkdat.
        t_main-kurrf = t_vbrk-kurrf.
        IF t_vbrk-fkart EQ 'ZR06'.
          t_main-fkimg = t_vbrp-fkimg * -1.
        ENDIF.
      ENDIF.

* Calculate qty in UoM.
      IF t_main-umren > 0.
        t_main-fkimgb =  t_main-umrez * t_main-fkimg / t_main-umren.
      ENDIF.

*---- Read condition price OLD
*****      READ TABLE t_konv WITH KEY
*****            knumv = t_vbrk-knumv
*****            kposn = t_vbrp-posnr
*****            BINARY SEARCH.
*****      IF sy-subrc EQ 0.
*****        t_main-kwert = t_konv-kwert.
*****      ENDIF.

*---- Read condition price NEW 17/10/2005
      LOOP AT t_konv WHERE knumv EQ t_vbrk-knumv AND
                           kposn EQ t_vbrp-posnr.
        IF t_vbrk-fkart EQ 'ZR06'.
          ld_kwert = t_konv-kwert * -1.
        ELSE.
          ld_kwert = t_konv-kwert.
        ENDIF.
        ADD ld_kwert TO t_main-kwert.
      ENDLOOP.

** CONVERT TO USD
*      CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*           EXPORTING
*                rate_type  = 'M'
*                from_curr  = 'USD'
*                to_currncy = t_main-waerk
*                date       = t_main-fkdat
*           IMPORTING
*                exch_rate  = d_exch_rate
*                return     = d_return.
*      IF sy-subrc EQ 0 AND d_exch_rate-exch_rate > 0.
*        t_main-kurusd = 1 / d_exch_rate-exch_rate.
*      ENDIF.
**      break bcrmd.
** calculate amount in IDR and USD
*      t_main-kwertidr = t_main-kwert * t_main-kurrf.
*      t_main-kwertusd = t_main-kwert * t_main-kurusd / 10.

      break bcrmd.
**----CONVERT TO IDR
      IF t_main-waerk <> 'IDR'.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
             EXPORTING
                  rate_type  = 'M'
                  from_curr  = t_main-waerk
                  to_currncy = 'IDR'
                  date       = t_main-fkdat
             IMPORTING
                  exch_rate  = d_exch_rate_idr
                  return     = d_return_idr.
        IF sy-subrc <> 0.
          MESSAGE i000(zab) WITH 'Exchange rate is not maintained'
                                 'for currency'
                                 t_main-waerk.
        ELSEIF sy-subrc EQ 0 AND d_exch_rate_idr-exch_rate > 0.
*          t_main-kuridr = d_exch_rate_idr-exch_rate *
*                          d_exch_rate_idr-to_factor /
*                          d_exch_rate_idr-from_factor.
        ENDIF.
      ENDIF.

**----CONVERT TO USD
      IF t_main-waerk <> 'USD'.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
             EXPORTING
                  rate_type  = 'M'
                  from_curr  = 'USD'
                  to_currncy = 'IDR'
                  date       = t_main-fkdat
             IMPORTING
                  exch_rate  = d_exch_rate_usd
                  return     = d_return_usd.
        IF sy-subrc <> 0.
          MESSAGE i000(zab) WITH 'Exchange rate is not maintained'
                                 'for currency'
                                 t_main-waerk.
        ELSEIF sy-subrc EQ 0 AND d_exch_rate_usd-exch_rate > 0.
          t_main-kurusd = 1 / d_exch_rate_usd-exch_rate.
        ENDIF.
      ENDIF.

** calculate amount in IDR and USD
      IF t_main-waerk = 'IDR'.
        t_main-kwertidr = t_main-kwert.
      ELSE.
*        t_main-kwertidr = t_main-kwert * t_main-kuridr.
        IF d_exch_rate_idr-to_factor EQ 1.
          t_main-kwertidr = t_main-kwert *
                            d_exch_rate_idr-exch_rate / 100.
        ELSE.
          t_main-kwertidr = t_main-kwert *
                            d_exch_rate_idr-exch_rate * 10.
        ENDIF.
      ENDIF.

      IF t_main-waerk = 'USD'.
        t_main-kwertusd = t_main-kwert.
      ELSE.
*        t_main-kwertusd = t_main-kwertidr * t_main-kurusd / 10.
        t_main-kwertusd = ( t_main-kwertidr /
                           d_exch_rate_usd-exch_rate ) / 10.
      ENDIF.


* read material description
      READ TABLE t_makt WITH KEY
             matnr = t_main-matnr
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-maktx = t_makt-maktx.
      ENDIF.

* read country
      READ TABLE t_t005t WITH KEY
             land1 = t_main-land1
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-landx = t_t005t-landx.
      ENDIF.

* read knvv-bzirk
      READ TABLE t_knvv WITH KEY
             kunnr = t_vbak-kunnr
             vkorg = t_vbak-vkorg
             vtweg = t_vbak-vtweg
             spart = t_vbak-spart
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-bzirk = t_knvv-bzirk.
      ENDIF.

* select region desc
      READ TABLE t_t171t WITH KEY
             bzirk = t_main-bzirk
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_main-bztxt = t_t171t-bztxt.
      ENDIF.

* select material group description
      READ TABLE t_mvke WITH KEY
             matnr = t_main-matnr
             vkorg = t_main-vkorg
             BINARY SEARCH.
      IF sy-subrc EQ 0.
        READ TABLE t_tvm1t WITH KEY
               mvgr1 = t_mvke-mvgr1
               BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_main-bezei1 = t_tvm1t-bezei.
        ENDIF.
        READ TABLE t_tvm4t WITH KEY
               mvgr4 = t_mvke-mvgr4.
        IF sy-subrc EQ 0.
          t_main-bezei4 = t_tvm4t-bezei.
        ENDIF.
      ENDIF.

* data checking
      CHECK NOT t_main-vbels IS INITIAL.
* populate data
      APPEND t_main.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  t_data[] = t_main[].

ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_alv TABLES t_result.

ENDFORM.


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

  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    i_background_id                = 'ALV_BACKGROUND'
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
*HEADALV
  DATA: ld_jdl(30).
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'BZTXT' 'T171T' 'BZTXT' '' '' 'Region' '' '' '' '' '' '' '' '',
    'LANDX' 'T005T' 'LANDX' '' '' 'Country' '' '' '' '' '' '' '' '',
    'VKBUR' 'VBRP' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '',
*{   DELETE         P01K900131                                        2
*\    'NAME1' 'KNA1' 'NAME1' '' '' 'Cus
*}   DELETE
*{   DELETE         P01K900131                                        1
*\                                     t.name' '' '' '' '' '' '' '' '',#
*}   DELETE
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX'   'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI1' 'TVM1T' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI4' 'TVM4T' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '',
    'FKIMGB'  'VBRP'  'FKIMG'  '' '' 'Qty' '' '' '' '' '' '' '' '',
    'VRKMEB'  'VBAK'  'VRKME'  '' '' 'UoM' '' '' '' '' '' '' '' '',
    'FKIMGX'  'VBRP'  'FKIMG'  '' '' 'Qty (CAR)' '' '' '' '' '' '' ''
    '',
    'KWERTIDR'  'KONV'  'KWERT'  '' '' 'IDR' '' '' '' 'IDR' '' '' '' '',
    'KWERTUSD'  'KONV'  'KWERT'  '' '' 'USD' '' '' '' 'USD' '' '' '' ''.

  DEFINE mac_header.
    read table t_period index &1.
    if sy-subrc eq 0 and not t_period is initial.
      select single * from t247
       where mnr = t_period+4(2)
       and   spras = sy-langu.
      concatenate t_period(4) t247-ktx into ld_jdl
         separated by space.
      perform f_fieldcatg using ft_report:
     'PER&1' 'VBAP' 'KWMENG' '' '' ld_jdl '' '' '' '' '' '' '' ''.
    endif.
  END-OF-DEFINITION.
  mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
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
                          value(fu_checkbox).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency    = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.





ENDFORM.

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

ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
*  DATA: ld_sort TYPE slis_sortinfo_alv.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VERSB'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

*** For ALV LIST
*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.

*** For ALV GRID
  DATA : v_erdatlow(10),
         v_erdathigh(10),
         v_client(10),
         v_time(8).

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  ihead_ln-info = sy-title.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Period'.
  WRITE s_period-low TO v_erdatlow.
  WRITE s_period-high TO v_erdathigh.
  CONCATENATE v_erdatlow 'To' v_erdathigh INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Process Time'.
  WRITE sy-datum TO ihead_ln-info.
  WRITE sy-uzeit TO v_time.
  CONCATENATE ihead_ln-info  v_time  sy-uname
              INTO ihead_ln-info SEPARATED BY ' / '.
  CONCATENATE sy-sysid(3) '(' sy-mandt ')'
              INTO v_client.
  CONCATENATE ihead_ln-info v_client
              INTO ihead_ln-info SEPARATED BY ' / '.
  APPEND ihead_ln TO ihead.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            it_list_commentary = ihead.
  REFRESH ihead.

ENDFORM.



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
* refresh:

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
ENDFORM.


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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reformat_data.
  DATA ld_period(6) TYPE c.
  DATA ld_row LIKE sy-tabix.
  DATA: BEGIN OF lt_mmyy OCCURS 0,
        t_period(6),
        END OF lt_mmyy.

  LOOP AT t_data.
    t_period = t_data-fkdat(6).
    COLLECT t_period.
  ENDLOOP.

  DESCRIBE TABLE t_period LINES d_nline.

  LOOP AT t_period.
    APPEND t_period TO lt_mmyy.
  ENDLOOP.

  DEFINE mac_trans.
  when '&1'.
    t_result-per&1 = t_data-fkimgb.
  END-OF-DEFINITION.

  LOOP AT t_data.
    t_result = t_data.
    ld_period = t_data-fkdat(6).
    READ TABLE lt_mmyy  WITH KEY
      t_period = ld_period.
    ld_row = sy-tabix.
    CASE ld_row.
        mac_trans: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
    ENDCASE.
    CLEAR:
    t_result-fkdat,
    t_result-vbeln,
    t_result-vrkme,
    t_result-vbels,
    t_result-fkimg,
    t_result-waerk.
    COLLECT t_result.
  ENDLOOP.

  LOOP AT t_result.
    READ TABLE t_marm WITH KEY matnr = t_result-matnr
                               meinh = 'KAR'.
    IF sy-subrc EQ 0.
      t_result-fkimgx = t_result-fkimgb / t_marm-umrez.
      MODIFY t_result TRANSPORTING fkimgx.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_validate_data



*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

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


*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.

ENDFORM.

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
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'yyyy/mm/dd' OR 'yyyy-mm-dd'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date
