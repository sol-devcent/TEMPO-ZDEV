*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  DATA: l_budat      TYPE sy-datum,
        l_budat_low  TYPE sy-datum,
        l_budat_high TYPE sy-datum.

  CLEAR: r_bwart, r_bwart[].

  r_bwart-low     = '101'.
  r_bwart-high    = '102'.
  r_bwart-option  = 'BT'.
  r_bwart-sign    = 'I'.
  APPEND r_bwart.

*-Added by Rahmadi: VA_NAME2 for plant name
  SELECT SINGLE name1 stras ort01 name2 adrnr
    FROM t001w
    INTO (va_name1, va_stras, va_ort01, va_name2, va_adrnr)
    WHERE werks EQ p_werks.

  SELECT SINGLE street
    FROM adrc
    INTO va_stras
    WHERE addrnumber EQ va_adrnr.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA: BEGIN OF lt_mara OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
          meins LIKE mara-meins,
          mownr LIKE marc-mownr,
        END OF lt_mara.

  DATA: BEGIN OF lt_makt OCCURS 0,
          matnr LIKE mara-matnr,
          maktx LIKE makt-maktx,
        END OF lt_makt.

  DATA: BEGIN OF lt_s933 OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
          bwart LIKE s933-bwart,
          charg LIKE s933-charg,
          lgort LIKE s933-lgort,
          basme LIKE s933-basme,
          menge LIKE s933-menge,
          dmbtr LIKE s933-dmbtr,
          hwaer LIKE s933-hwaer,
          lifnr LIKE s933-lifnr,
        END OF lt_s933.

  DATA lt_lifnr LIKE lt_s933 OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_lfa1 OCCURS 0,
          lifnr LIKE lfa1-lifnr,
          name1 LIKE lfa1-name1,
        END OF lt_lfa1.

  SELECT a~matnr a~meins
         b~werks b~mownr
    FROM mara AS a JOIN marc AS b ON a~matnr EQ b~matnr
    INTO CORRESPONDING FIELDS OF TABLE lt_mara
    WHERE a~mtart = p_mtart AND
          b~werks = p_werks AND
          b~mownr IN s_mownr.

  IF NOT lt_mara[] IS INITIAL.

*{   REPLACE        P01K910240                                        1
*\    SELECT matnr maktx
*\           INTO TABLE lt_makt
*\           FROM makt
*\           FOR ALL ENTRIES IN lt_mara
*\           WHERE matnr = lt_mara-matnr AND
*\                 spras = sy-langu.
    "Start SOH: Shell SCI Adjustment 20240221 RZL
    SELECT matnr maktx
           INTO TABLE lt_makt
           FROM makt
           FOR ALL ENTRIES IN lt_mara
           WHERE matnr = lt_mara-matnr AND
                 spras = sy-langu ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   REPLACE

    SELECT werks matnr bwart charg lgort basme menge dmbtr hwaer
           lifnr
           INTO CORRESPONDING FIELDS OF TABLE lt_s933
           FROM s933
           FOR ALL ENTRIES IN lt_mara
           WHERE spmon = p_period AND
                 werks = p_werks AND
                 matnr = lt_mara-matnr AND
                 bwart IN r_bwart AND
                 vrsio = '000' AND
                 auart = 'ZIMP'.
    IF sy-subrc = 0.

*---get Vendor detail
      lt_lifnr[] = lt_s933[].
      SORT lt_lifnr BY lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING lifnr.
      IF NOT lt_lifnr[] IS INITIAL.
        SELECT lifnr name1
               INTO TABLE lt_lfa1
               FROM lfa1
               FOR ALL ENTRIES IN lt_lifnr
               WHERE lifnr = lt_lifnr-lifnr.
        SORT lt_lfa1 BY lifnr.
      ENDIF.

      LOOP AT lt_s933.
        MOVE-CORRESPONDING lt_s933 TO t_data.
        t_data-name2 = va_name2.
        CLEAR: t_data-maktx.
*{   INSERT         P01K910240                                        2
        "Start SOH: Shell SCI Adjustment 20240221 RZL
        SORT lt_makt by matnr.
        "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
        READ TABLE lt_makt WITH KEY matnr = lt_s933-matnr
             BINARY SEARCH.
        IF sy-subrc = 0.
          t_data-maktx = lt_makt-maktx.
        ENDIF.
        CLEAR: t_data-name1.
        READ TABLE lt_lfa1 WITH KEY lifnr = lt_s933-lifnr
             BINARY SEARCH.
        IF sy-subrc = 0.
          t_data-name1 = lt_lfa1-name1.
        ENDIF.
        COLLECT t_data.
      ENDLOOP.
    ENDIF.

  ELSE.
    MESSAGE i000(zab) WITH 'Material does not exist'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF t_data[] IS INITIAL.
    MESSAGE i000(zab) WITH 'Data not found'.
  ELSE.
    PERFORM f_alv TABLES t_data.
  ENDIF.
ENDFORM.

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
                          value(fu_nosign).

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
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-no_sign       = fu_nosign.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

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
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
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
  DATA: l_no(4) TYPE p DECIMALS 0.
  LOOP AT t_data.
    ADD 1 TO l_no.
    t_data-no = l_no.
    MODIFY t_data TRANSPORTING no.
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
*{   REPLACE        P01K900131                                        1
*\      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat(4)
*}   REPLACE
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
*{   REPLACE        P01K900131                                        2
*\      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat(4)
*}   REPLACE
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date
