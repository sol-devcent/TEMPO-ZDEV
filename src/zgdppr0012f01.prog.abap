*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  DATA: l_budat      TYPE sy-datum,
        l_budat_low  TYPE sy-datum,
        l_budat_high TYPE sy-datum.

  ra_bwart-low     = '101'.
  ra_bwart-high    = '102'.
  ra_bwart-option  = 'BT'.
  ra_bwart-sign    = 'I'.
  APPEND ra_bwart.

  IF option EQ 0.
    radio5 = space.
    radio6 = space.
    IF radio1 EQ 'X'.
      CONCATENATE sy-datum(4) '01' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '04' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    ELSEIF radio2 EQ 'X'.
      CONCATENATE sy-datum(4) '04' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    ELSEIF radio3 EQ 'X'.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '10' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    ELSEIF radio4 EQ 'X'.
      CONCATENATE sy-datum(4) '10' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '12' '31' INTO l_budat_high.
    ENDIF.
    va_hrtype       = 'OJ'.
  ELSE.
    radio1 = space.
    radio2 = space.
    radio3 = space.
    radio4 = space.
    IF radio5 EQ 'X'.
      CONCATENATE sy-datum(4) '01' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat.
      l_budat_high = l_budat - 1.
    ELSEIF radio6 EQ 'X'.
      CONCATENATE sy-datum(4) '07' '01' INTO l_budat_low.
      CONCATENATE sy-datum(4) '12' '31' INTO l_budat_high.
    ENDIF.
    va_hrtype       = 'TR'.
  ENDIF.

  ra_budat-low     = l_budat_low.
  ra_budat-high    = l_budat_high.
  ra_budat-option  = 'BT'.
  ra_budat-sign    = 'I'.
  APPEND ra_budat.

*-Added by Rahmadi: VA_NAME2 for plant name
  SELECT SINGLE name1 stras ort01 name2
    FROM t001w
    INTO (va_name1, va_stras, va_ort01, va_name2)
    WHERE werks EQ p_werks.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_matnr(70).

  DATA: ld_month LIKE mbewh-lfmon,
        ld_year LIKE mbewh-lfgja.

  DATA lw_mbew TYPE ta_itab.
  DATA lw_itab TYPE ta_itab.

  DATA ld_plow TYPE abper_rf.
  DATA ld_phigh TYPE abper_rf.
  DATA ld_per TYPE abper_rf.

* Get Deskripsi Obat
  SELECT *
    FROM zgdppdt0012
    INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0012
    WHERE hrtype EQ va_hrtype.

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
**

  IF NOT i_zgdppdt0012[] IS INITIAL.
* Get material
    SELECT a~matnr a~ferth
           c~maktx
      FROM mara AS a JOIN marc AS b ON a~matnr EQ b~matnr
                     JOIN makt AS c ON a~matnr EQ c~matnr
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE a~ferth IN ra_ferth AND
            b~werks EQ p_werks AND
            c~spras EQ sy-langu.

*---Added by Rahmadi: Proceed if only the material exist
    IF sy-subrc = 0.
      CLEAR: wa_itab.
      LOOP AT i_itab INTO wa_itab.
        LOOP AT i_zgdppdt0012 INTO wa_zgdppdt0012.
          IF wa_itab-ferth CP wa_zgdppdt0012-ferth.
            wa_itab-hrcode = wa_zgdppdt0012-hrcode.
            wa_itab-hrdesc = wa_zgdppdt0012-hrdesc.
*-----------Added by Rahmadi: HRMEINS, MSEH6 (Description)
            wa_itab-hrmeins = wa_zgdppdt0012-hrmeins.
            SELECT SINGLE mseh6
                   INTO wa_itab-mseh6
                   FROM t006a
                   WHERE spras = sy-langu AND
                         msehi = wa_itab-hrmeins.
            EXIT.
          ENDIF.
        ENDLOOP.
*-------Added by Rahmadi: Currency
        wa_itab-waers = 'IDR'.
        MODIFY i_itab FROM wa_itab TRANSPORTING hrcode hrdesc hrmeins
                                                mseh6 waers.
        CLEAR: wa_itab.
      ENDLOOP.
**

* Get harga satuan
*    SELECT matnr stprs peinh
*      FROM mbew
*      INTO CORRESPONDING FIELDS OF TABLE i_mbew
*      FOR ALL ENTRIES IN i_itab
*      WHERE matnr EQ i_itab-matnr.

*-----Changed by Rahmadi --- taking from historical data (MBEWH)
*-----for the last month in the selection
      READ TABLE ra_budat INDEX 1.
****This logic must be applied since MBEWH for period N will only be
****updated if only there is stock movement in period (N+1)
      ld_month = ra_budat-high+4(2).
      ld_year = ra_budat-high+(4).
      CONCATENATE ra_budat-high+(4) ra_budat-high+4(2) INTO ld_phigh.
      CONCATENATE ra_budat-low+(4) ra_budat-low+4(2) INTO ld_plow.
      LOOP AT i_itab INTO lw_itab.
        CLEAR: lw_mbew, ld_per.
        ld_month = ra_budat-high+4(2).
        ld_year = ra_budat-high+(4).
        DO.
          SELECT SINGLE matnr stprs peinh
            FROM mbewh
*            INTO CORRESPONDING FIELDS OF TABLE i_mbew
*          FOR ALL ENTRIES IN i_itab
            INTO CORRESPONDING FIELDS OF lw_mbew
            WHERE matnr EQ lw_itab-matnr AND
                  bwkey EQ p_werks AND
                  lfgja EQ ld_year AND
                  lfmon EQ ld_month.
          IF sy-subrc = 0.
            APPEND lw_mbew TO i_mbew.
            EXIT.
          ELSE.
            IF ld_month = '01'.
              ld_month = '12'.
              ld_year = ld_year - 1.
            ELSE.
              ld_month = ld_month - 1.
              ld_year = ld_year.
            ENDIF.
            CONCATENATE ld_year ld_month INTO ld_per.
*-----------Skip if there are no transactions during selected 3 months
            IF ld_per < ld_plow.
              EXIT.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDLOOP.

      CLEAR: wa_mbew.
      LOOP AT i_mbew INTO wa_mbew.
*-------Changed by Rahmadi: no need to multiply by 100, currency based
        wa_mbew-satuan = wa_mbew-stprs / wa_mbew-peinh.     " * 100.
        MODIFY i_mbew FROM wa_mbew TRANSPORTING satuan.
        CLEAR: wa_mbew.
      ENDLOOP.
**

* Get 3 month data
      SELECT mblnr mjahr budat
        FROM mkpf
        INTO CORRESPONDING FIELDS OF TABLE i_mkpf
        WHERE budat IN ra_budat.
**

* Get jumlah produksi & satuan
      IF NOT i_mkpf[] IS INITIAL.
        SELECT matnr mblnr menge meins shkzg
          FROM mseg
          INTO TABLE i_mseg
          FOR ALL ENTRIES IN i_mkpf
          WHERE mblnr EQ i_mkpf-mblnr AND
                werks EQ p_werks     AND
                bwart IN ra_bwart.

        CLEAR: wa_mseg.
        SORT i_mseg BY matnr.
        SORT i_itab BY matnr.
        LOOP AT i_mseg INTO wa_mseg.
          READ TABLE i_itab INTO wa_itab WITH KEY matnr = wa_mseg-matnr
                                         BINARY SEARCH.
          IF sy-subrc EQ 0.
*-----------Changed by Rahmadi: add when S(BWART = 101)
            IF wa_mseg-shkzg = 'S'.
              ADD wa_mseg-menge TO wa_total-menge.
            ELSE.
*-------------Changed by Rahmadi: substract when H(BWART = 102)
              wa_total-menge = wa_total-menge - wa_mseg-menge.
            ENDIF.
            wa_total-matnr = wa_mseg-matnr.
            wa_total-meins = wa_mseg-meins.
            AT END OF matnr.

*-------------Added by Rahmadi: convert UoM to HRMEINS
              CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
                   EXPORTING
                        input                = wa_total-menge
                        matnr                = wa_mseg-matnr
                        meinh                = wa_itab-hrmeins
                        meins                = wa_total-meins
                   IMPORTING
                        output               = wa_total-menge
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
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ELSE.
                wa_total-meins = wa_itab-hrmeins.
                wa_total-mseh6 = wa_itab-mseh6.
              ENDIF.

              APPEND wa_total TO i_total.
              CLEAR: wa_total.
            ENDAT.
          ENDIF.
          CLEAR: wa_mseg.
        ENDLOOP.
      ENDIF.

      CLEAR: wa_itab.
      LOOP AT i_itab INTO wa_itab.
* Get bentuk sediaan
        l_matnr = wa_itab-matnr.
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
            wa_itab-tdline = wa_lines-tdline.
            MODIFY i_itab FROM wa_itab TRANSPORTING tdline.
          ENDIF.
        ENDIF.

        READ TABLE i_mbew INTO wa_mbew WITH KEY matnr = wa_itab-matnr.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING wa_mbew TO wa_itab.
        ENDIF.
        READ TABLE i_total INTO wa_total WITH KEY matnr = wa_itab-matnr.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING wa_total TO wa_itab.
        ENDIF.
        wa_itab-nilai  = wa_itab-menge * wa_itab-satuan.
        IF wa_itab-menge EQ 0 AND
          wa_itab-nilai EQ 0.
          DELETE i_itab.
        ELSE.
          MODIFY i_itab FROM wa_itab
          TRANSPORTING satuan menge meins nilai.
        ENDIF.
        CLEAR: wa_itab.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  IF option EQ 0.
    IF i_itab IS INITIAL.
      MESSAGE i000(zab) WITH 'Data not found'.
    ELSE.
      PERFORM f_alv TABLES i_itab.
    ENDIF.
  ELSE.
    IF i_itab IS INITIAL.
      MESSAGE i000(zab) WITH 'Data not found'.
    ELSE.
      PERFORM f_alv1 TABLES i_itab.
    ENDIF.
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
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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
  ld_sort-fieldname = 'HRDESC'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
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
  REFRESH: i_zgdppdt0012, i_mkpf, i_mbew, i_mseg, i_total, i_itab,
           t_lines.

  CLEAR: wa_zgdppdt0012, wa_mbew, wa_mseg, wa_total, wa_itab,
         wa_lines.

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
