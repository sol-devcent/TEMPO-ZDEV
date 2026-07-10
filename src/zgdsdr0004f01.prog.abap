*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  DATA: l_budat      TYPE sy-datum,
        l_budat_low  TYPE sy-datum,
        l_budat_high TYPE sy-datum.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
       EXPORTING
            langu = sy-langu
       TABLES
            users = t_user.

**Get period based on the selection
  CASE 'X'.
    WHEN radio1.
      CONCATENATE sy-datum(4) '01' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '04' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    WHEN radio2.
      CONCATENATE sy-datum(4) '04' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    WHEN radio3.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '10' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    WHEN radio4.
      CONCATENATE sy-datum(4) '10' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '12' '31' INTO l_budat_high.
  ENDCASE.

  CLEAR r_period. REFRESH r_period.
  r_period-low     = l_budat_low.
  r_period-high    = l_budat_high.
  r_period-option  = 'BT'.
  r_period-sign    = 'I'.
  APPEND r_period.

***Get Sales organization text
  SELECT SINGLE vkorg vtext INTO wa_tvkot
         FROM tvkot
         WHERE vkorg = p_vkorg AND
               spras = sy-langu.


** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*-- Get Range for Next month (5 Months after)
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_month_after                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_DATE                                                       *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_matnr(70).

  DATA lt_konv LIKE konv OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_vbrk OCCURS 0,
          vbeln LIKE vbrk-vbeln,
          waerk LIKE vbrk-waerk,
          vkorg LIKE vbrk-vkorg,
          knumv LIKE vbrk-knumv,
          fkdat LIKE vbrk-fkdat,
          land1 LIKE vbrk-land1,
        END OF lt_vbrk.

  DATA lt_vkorg LIKE lt_vbrk OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_tvkot OCCURS 0,
          vkorg LIKE tvkot-vkorg,
          vtext LIKE tvkot-vtext,
        END OF lt_tvkot.

  DATA lt_vbeln LIKE t_vbrp OCCURS 0 WITH HEADER LINE.

*-- Added by didik Get Deskripsi Obat
  SELECT *
    FROM zgdppdt0012
    INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0012
    WHERE hrtype EQ 'OJ'.

  CLEAR: wa_zgdppdt0012.
  LOOP AT i_zgdppdt0012 INTO wa_zgdppdt0012.
    CONCATENATE '*' wa_zgdppdt0012-hrcode '*' INTO wa_zgdppdt0012-ferth.
    ra_ferth-low     = wa_zgdppdt0012-ferth.
    ra_ferth-option  = 'CP'.
    ra_ferth-sign    = 'I'.
    APPEND ra_ferth.
    MODIFY i_zgdppdt0012 FROM wa_zgdppdt0012 TRANSPORTING ferth.
    CLEAR: wa_zgdppdt0012.
  ENDLOOP.
*--

  SELECT * FROM likp INTO TABLE t_likp
*  WHERE wadat_ist IN s_period.
  WHERE wadat_ist IN r_period AND
        vkorg = p_vkorg.
  SORT t_likp BY vbeln.

  CHECK NOT t_likp[] IS INITIAL.
  SELECT * FROM vbrp INTO TABLE t_vbrp
  FOR ALL ENTRIES IN t_likp
  WHERE
     vgbel = t_likp-vbeln and
     matnr in s_matnr.

  CHECK NOT t_vbrp[] IS INITIAL.
  lt_vbeln[] = t_vbrp[].
  SORT lt_vbeln BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING vbeln.

  SELECT vbeln waerk vkorg knumv fkdat land1
         INTO TABLE lt_vbrk
         FROM vbrk
         FOR ALL ENTRIES IN lt_vbeln
         WHERE vbeln = lt_vbeln-vbeln.
  SORT lt_vbrk BY vbeln.

  IF NOT lt_vbrk[] IS INITIAL.
    lt_vkorg[] = lt_vbrk[].
    SORT lt_vkorg BY vkorg.
    DELETE ADJACENT DUPLICATES FROM lt_tvkot COMPARING vkorg.

    SELECT vkorg vtext INTO TABLE lt_tvkot
     FROM tvkot
     FOR ALL ENTRIES IN lt_vkorg
     WHERE vkorg = lt_vkorg-vkorg.
    SORT lt_tvkot BY vkorg.

* read condition price data
    SELECT * FROM konv
      INTO TABLE lt_konv
      FOR ALL ENTRIES IN lt_vbrk
      WHERE knumv = lt_vbrk-knumv AND
            kschl = 'ZHJM'.
    SORT lt_konv BY knumv kposn.
  ENDIF.

  SELECT * FROM vbak INTO TABLE t_vbak
  FOR ALL ENTRIES IN t_vbrp
  WHERE
     vbeln = t_vbrp-aubel AND
     auart IN s_auart.

  SELECT mara~matnr mara~ferth
           FROM mara JOIN mvke
           ON mara~matnr = mvke~matnr
           INTO TABLE t_mara
  FOR ALL ENTRIES IN t_vbrp
  WHERE
     mara~matnr = t_vbrp-matnr AND
     vkorg = p_vkorg AND
     mvgr2 <> '30'.
  SORT t_mara BY matnr.


  LOOP AT t_vbrp.
    CLEAR t_main.
    READ TABLE t_vbak
      WITH KEY
      vbeln = t_vbrp-aubel.
    CHECK sy-subrc EQ 0.
    t_main-matnr = t_vbrp-matnr.
    t_main-arktx = t_vbrp-arktx.
    t_main-vrkme = t_vbrp-vrkme.
    t_main-fkimg = t_vbrp-fkimg.
    t_main-netwr = t_vbrp-netwr.
*    SELECT SINGLE * FROM vbrk
*     WHERE vbeln = t_vbrp-vbeln.
*    SELECT SINGLE vtext INTO t_main-vtext
*     FROM tvkot
*     WHERE vkorg = vbrk-vkorg.
    CLEAR: lt_vbrk, lt_tvkot, lt_konv.
    READ TABLE lt_vbrk WITH KEY vbeln = t_vbrp-vbeln
         BINARY SEARCH.
    IF sy-subrc = 0.
*-----Condition value
      READ TABLE lt_konv WITH KEY knumv = lt_vbrk-knumv
                                  kposn = t_vbrp-posnr
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        t_main-kwert = lt_konv-kwert.
      ENDIF.

***to cater foreign currency other than USD
      IF lt_vbrk-waerk <> 'USD' AND
         lt_vbrk-waerk <> 'IDR'.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
             EXPORTING
                  rate_type  = 'M'
                  from_curr  = lt_vbrk-waerk
                  to_currncy = 'IDR'
                  date       = lt_vbrk-fkdat
             IMPORTING
                  exch_rate  = d_exch_rate_idr
                  return     = d_return_idr.
        IF sy-subrc <> 0.
          MESSAGE i000(zab) WITH 'Exchange rate is not maintained'
                                 'for currency'
                                 lt_vbrk-waerk.
        ELSEIF sy-subrc EQ 0 AND d_exch_rate_idr-exch_rate > 0.
*          t_main-kuridr = d_exch_rate_idr-exch_rate *
*                          d_exch_rate_idr-to_factor /
*                          d_exch_rate_idr-from_factor.
        ENDIF.
        t_main-kwert = t_main-kwert * d_exch_rate_idr-exch_rate * 10.
      ENDIF.

* CONVERT TO USD
      IF lt_vbrk-waerk <> 'USD'.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
             EXPORTING
                  rate_type  = 'M'
                  from_curr  = 'USD'
*                  to_currncy = lt_vbrk-waerk
                  to_currncy = 'IDR'
                  date       = lt_vbrk-fkdat
             IMPORTING
                  exch_rate  = d_exch_rate
                  return     = d_return.
        IF sy-subrc <> 0.
          MESSAGE i000(zab) WITH 'Exchange rate is not maintained'
                                 'for currency'
                                 lt_vbrk-waerk.
        ELSEIF sy-subrc EQ 0 AND d_exch_rate-exch_rate > 0.
          t_main-kurusd = 1 / d_exch_rate-exch_rate.
        ENDIF.
*      break bcrmd.
* calculate amount in IDR and USD
        t_main-kwert = t_main-kwert * t_main-kurusd / 10.
      ENDIF.

*-----Sales org text
      READ TABLE lt_tvkot WITH KEY vkorg = lt_vbrk-vkorg
           BINARY SEARCH.
      IF sy-subrc = 0.
        t_main-vtext = lt_tvkot-vtext.
      ENDIF.

*-----Destination country
      SELECT SINGLE landx INTO t_main-landx
      FROM t005t
      WHERE land1 = lt_vbrk-land1 AND
      spras = sy-langu.
    ENDIF.

** Comment by didik
****(RAHMADI)ALWAYS USE READ BINARY SEARCH WHERE POSSIBLE
**    READ TABLE t_mara WITH KEY
**      matnr = t_mara-matnr
**      BINARY SEARCH.
**    IF sy-subrc EQ 0.
**      t_main-ferth = t_mara-ferth.
**    ENDIF.

*-- Added by didik
    READ TABLE t_mara WITH KEY
      matnr = t_vbrp-matnr
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_main-ferth = t_mara-ferth.
    ENDIF.

    LOOP AT i_zgdppdt0012 INTO wa_zgdppdt0012.
      IF t_mara-ferth CP wa_zgdppdt0012-ferth.
        t_main-hrdesc = wa_zgdppdt0012-hrdesc.
        EXIT.
      ENDIF.
    ENDLOOP.

* Get bentuk sediaan
    l_matnr = t_vbrp-matnr.
    CALL FUNCTION 'READ_TEXT'
         EXPORTING
              id                      = 'GRUN'
              language                = sy-langu
              name                    = l_matnr
              object                  = 'MATERIAL'
         TABLES
              lines                   = t_lines
         EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
    IF sy-subrc EQ 0.
      READ TABLE t_lines INTO wa_lines.
      IF sy-subrc EQ 0.
        t_main-tdline = wa_lines-tdline.
      ENDIF.
    ENDIF.
*--
    READ TABLE t_likp
    WITH KEY
    vbeln = t_vbrp-vgbel
    BINARY SEARCH.
    t_main-wadat_ist = t_likp-wadat_ist.
    APPEND t_main.
  ENDLOOP.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  t_main_tmp[] = t_main[].
  ASSIGN t_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES <fs_table>.
  PERFORM f_alv TABLES t_main.


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
  PERFORM f_alv_variant_exist USING  p_vari
                                     d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
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

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'FERTH' 'MARA' 'FERTH' '' '' 'Material Type' '' '' '' '' '' '' ''
* '',
*
    'HRDESC' '' '' '' '15' 'Material Type' '' '' '' '' '' '' '' '',
    'MATNR' 'MARA' 'MATNR' '' '' 'Material No' '' '' '' '' '' '' '' '',
    'ARKTX' 'VBRP' 'ARKTX' '' '' '' '' '' '' '' '' '' '' '',
    'VRKME' 'VBRP' 'VRKME' '' '' 'UoM' '' '' '' '' '' '' '' '',
    'TDLINE' '' '' '' '18' 'Bentuk Sediaan' '' '' '' '' '' '' '' '',
    'FKIMG' 'VBRP' 'FKIMG' '' '' 'Export Qty' '' '' '' '' '' '' '' '',
*    'NETWR' 'VBRP' 'NETWR' '' '' 'Export Value(US$)' '' '' '' '' '' ''
*'' '',
    'KWERT' 'KONV' 'KWERT' '' '' 'Export Value(US$)' '' '' '' 'USD' ''
    '' '' '',
    'VTEXT' 'TVKOT' 'VTEXT' '' '' 'Exportir' '' '' '' '' '' '' '' '',
    'LANDX' 'T005T' 'LANDX' '' '' 'Dest.Country' '' '' '' '' '' '' '' ''
,
    'WADAT_IST'   'LIKP' 'WADAT_IST' '' '' 'Shipment Date' '' '' '' ''
'' '' '' ''.


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
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'FERTH'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
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

*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.

  PERFORM f_hdr_line_page USING ''.
  SKIP 1.
  PERFORM f_hdr_line4 USING ''.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE_PAGE
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line_page USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE '',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
*  IF sy-cprog EQ sy-repid.
*    REPLACE 'xx' WITH sy-repid INTO progname.
*  ELSE.
*    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
*    REPLACE 'xx' WITH ld_progname INTO progname.
*  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_page USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_PAGE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_page USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
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
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ ''.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
*  write at sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_PAGE

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0617   text
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING    value(p_0617).
  DATA: l_start          TYPE i,
        l_length         TYPE i,
        l_title(100),
        l_plant(60)      VALUE 'NAMA INDUSTRI FARMASI : ',
        l_alamat(100)    VALUE 'ALAMAT                : ',
        l_ort01(100)     VALUE '                       ',
        l_tahun(100)     VALUE 'TAHUN                 : '.

*--- Title
  l_title = 'LAPORAN REALISASI PRODUKSI OBAT JADI'.
  COMPUTE l_length = strlen( l_title ).
  COMPUTE l_start = ( sy-linsz - l_length ) / 2.

*--- Plant
*-Changed by Rahmadi: VA_NAME1 to VA_NAME2
  CONCATENATE l_plant wa_tvkot-vtext INTO l_plant
    SEPARATED BY space.
*--- Tahun
  CONCATENATE l_tahun sy-datum(4) INTO l_tahun
    SEPARATED BY space.

*--- output line
  WRITE: / l_start, l_title.
  SKIP 1.
  WRITE: / l_plant,
         / l_tahun.

  IF radio1 EQ 'X'.
    WRITE: / 'SEMESTER              : ',
             sym_checkbox AS SYMBOL,
             'JANUARI - MARET'.
  ELSE.
    WRITE: / 'SEMESTER              : ',
             sym_large_square AS SYMBOL,
             'JANUARI - MARET'.
  ENDIF.
  IF radio2 EQ 'X'.
    WRITE: /26 sym_checkbox AS SYMBOL,
               'APRIL - JUNI'.
  ELSE.
    WRITE: /26 sym_large_square AS SYMBOL,
               'APRIL - JUNI'.
  ENDIF.
  IF radio3 EQ 'X'.
    WRITE: /26 sym_checkbox AS SYMBOL,
               'JULI - SEPTEMBER'.
  ELSE.
    WRITE: /26 sym_large_square AS SYMBOL,
               'JULI - SEPTEMBER'.
  ENDIF.
  IF radio4 EQ 'X'.
    WRITE: /26 sym_checkbox AS SYMBOL,
               'OKTOBER - DESEMBER'.
  ELSE.
    WRITE: /26 sym_large_square AS SYMBOL,
               'OKTOBER - DESEMBER'.
  ENDIF.

ENDFORM.                    " f_hdr_line4

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
FORM f_validate_data.

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
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date
