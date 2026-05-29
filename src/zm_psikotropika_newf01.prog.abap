*----------------------------------------------------------------------*
*   INCLUDE ZM_PSIKOTROPIKA_CSVF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  PERFORM f_init_plant.
  PERFORM f_init_budat.
  PERFORM f_init_bwart.
  PERFORM f_init_t001w.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  PERFORM f_get_opening_stock.
  PERFORM f_get_transaction.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  SORT gt_out BY matnr budat norut sawchg inchg outchg.
  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
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
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'BUDAT' 'MKPF' 'BUDAT' '' '' 'TANGGAL' '' '' '' '' '' '' '' '' '' '' '',
    'SALAW' 'MARD' 'LABST' '' '' 'SALDOAWAL_BULAN' '' '' '' '' '' '' 'MEINS' '' '' '' '',
    'SAWCHG' 'MSEG' 'CHARG' '' '' 'BATCH_AWAL' '' '' '' '' '' '' '' '' '' '' '',
    'INDOC' 'MSEG' 'MBLNR' '' '' 'NO_FAKTUR_MASUK' '' '' '' '' '' '' '' '' '' '' '',
    'INTXT' '' '' '' '40' 'SUMBER' '' '' '' '' '' '' '' '' '' '' '',
    'INQTY' 'MSEG' 'MENGE' '' '' 'JUM_MASUK' '' '' '' '' '' '' 'MEINS' '' '' '' '',
    'INCHG' 'MSEG' 'CHARG' '' '' 'BATCH_MASUK' '' '' '' '' '' '' '' '' '' '' '',
    'OUTDOC' 'MSEG' 'MBLNR' '' '' 'NO_FAKTUR_KELUAR' '' '' '' '' '' '' '' '' '' '' '',
    'OUTTXT' '' '' '' '40' 'TUJUAN' '' '' '' '' '' '' '' '' '' '' '',
    'OUTQTY' 'MSEG' 'MENGE' '' '' 'JUM_KELUAR' '' '' '' '' '' '' 'MEINS' '' '' '' '',
    'OUTCHG' 'MSEG' 'CHARG' '' '' 'BATCH_KELUAR' '' '' '' '' '' '' '' '' '' '' '',
    'SALAK' 'MARD' 'LABST' '' '' 'SALDO_AKHIR' '' '' '' '' '' '' 'MEINS' '' '' '' '',
    'SAKCHG' 'MSEG' 'CHARG' '' '' 'BATCH_AKHIR' '' '' '' '' '' '' '' '' '' '' '',
    'VFDAT' 'MCHA' 'VFDAT' '' '' 'EXPIRED' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
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
                          VALUE(fu_input)
                          VALUE(fu_emphasize)
                          VALUE(fu_just).

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
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-just              = fu_just.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
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
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'TANGGAL'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_out, gt_out[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
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
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'TOEXECUTE'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
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
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA: lt_mch1   TYPE TABLE OF mch1 WITH HEADER LINE,
        lv_charg  TYPE charg_d,
        lv_faktur TYPE mblnr,
        lv_mblnr  TYPE mblnr,
        lv_mjahr  TYPE mjahr,
        lv_norut2 TYPE numc3,
        lv_norut3 TYPE numc3,
        lv_code   TYPE char10,
        lv_adrnr  TYPE adrnr,
        lv_name1  TYPE char40.

  DATA: lt_sak LIKE gt_out OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_sak> LIKE gt_out.

  SORT: gt_opnstk      BY matnr charg,
        gt_mseg        BY matnr budat charg bwart.

  LOOP AT gt_opnstk.
    PERFORM f_collect_batch USING gt_opnstk-charg.
    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
    <fs_out>-norut  = '100'.
    <fs_out>-budat  = gr_budat-low.
    <fs_out>-matnr  = gt_opnstk-matnr.
    <fs_out>-salaw  = gt_opnstk-labst.
    <fs_out>-sawchg = gt_opnstk-charg.
  ENDLOOP.

  LOOP AT gt_mseg.
    PERFORM f_collect_batch USING gt_mseg-charg.

    CLEAR lv_faktur.
    READ TABLE gt_vbfa WITH KEY vbeln = gt_mseg-mblnr
                                matnr = gt_mseg-matnr
                                vbtyp_v = 'T'.
    IF sy-subrc = 0.
      lv_faktur = gt_vbfa-vbelv.
    ELSE.
      CLEAR lv_faktur.
      READ TABLE gt_vbfa WITH KEY vbeln = gt_mseg-mblnr
                                  matnr = gt_mseg-matnr
                                  vbtyp_v = 'J'.
      IF sy-subrc = 0.
        lv_faktur = gt_vbfa-vbelv.
      ELSE.
        lv_faktur = gt_mseg-mblnr.
      ENDIF.
    ENDIF.

** Pemasukan
    IF gt_mseg-bwart IN gr_bwartin AND
       gt_mseg-shkzg EQ 'S'.

      CLEAR: lv_code,lv_name1.
      CASE gt_mseg-bwart.
        WHEN '101'.
          CLEAR: gt_ekko,gt_lfa1_101,gt_t001w.
          READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.

          IF gt_ekko-bsart = 'CVSR'.
            CONTINUE.
          ENDIF.

          IF gt_ekko-lifnr IS NOT INITIAL.
            lv_code = gt_ekko-lifnr.
            READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
            lv_name1 = gt_lfa1_101-name1.
          ELSEIF gt_ekko-reswk IS NOT INITIAL.
            lv_code = gt_ekko-reswk.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
            lv_name1 = gt_t001w-name1.
            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = gt_t001w-adrnr.
          ENDIF.

        WHEN '305'.
          CLEAR: lv_mblnr,lv_mjahr,gt_mseg_305,gt_t001w.
          SPLIT gt_mseg-sgtxt AT '/' INTO lv_mblnr lv_mjahr.
          READ TABLE gt_mseg_305 WITH KEY mblnr = lv_mblnr
                                          mjahr = lv_mjahr
                                          matnr = gt_mseg-matnr
                                          charg = gt_mseg-charg.
          lv_code = gt_mseg_305-werks.
          READ TABLE gt_t001w WITH KEY werks = lv_code(4).
          lv_name1 = gt_t001w-name1.
          SELECT SINGLE name3 INTO lv_name1
            FROM adrc WHERE addrnumber = gt_t001w-adrnr.

        WHEN '311'.
          CLEAR: lv_adrnr,lv_name1.
          lv_code = gt_mseg-umwrk.

          SELECT SINGLE adrnr INTO lv_adrnr
            FROM twlad WHERE werks = gt_mseg-umwrk
                         AND lgort = gt_mseg-umlgo.
          IF sy-subrc NE 0.
            SELECT SINGLE adrnr INTO lv_adrnr
              FROM t001w WHERE werks = gt_mseg-umwrk.
          ENDIF.
          SELECT SINGLE name3 INTO lv_name1
            FROM adrc WHERE addrnumber = lv_adrnr.

        WHEN '653' OR '655' OR 'Z13' OR '913'.
          CLEAR: gt_kna1_655.
          lv_code = gt_mseg-wempf.
          READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
          lv_name1 = gt_kna1_655-name1.

        WHEN '675'.
          CLEAR: gt_mseg_641,gt_t001w.
          READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                          mjahr = gt_mseg-mjahr
                                          parent_id = gt_mseg-line_id.
*                                          matnr = gt_mseg-matnr
*                                          charg = gt_mseg-charg.
          lv_code = gt_mseg_641-werks.
          READ TABLE gt_t001w WITH KEY werks = lv_code(4).
          lv_name1 = gt_t001w-name1.
          SELECT SINGLE name3 INTO lv_name1
            FROM adrc WHERE addrnumber = gt_t001w-adrnr.

        WHEN '920'.
          lv_code  = '44'.
          lv_name1 = 'Claim to Expedisi'.

        WHEN '555'.
          lv_code  = '55'.
          lv_name1 = 'Pemusnahan'.

        WHEN '922'.
          lv_code  = '66'.
          lv_name1 = 'Claim to Asuransi'.

        WHEN '926'.
          lv_code  = '77'.
          lv_name1 = 'Claim to Principal'.

        WHEN '701' OR '702' OR '703' OR '704' OR '707' OR '708' OR '711' OR
             '712' OR '713' OR '714' OR '715' OR '716' OR '717' OR '718'.
          lv_code  = '88'.
          lv_name1 = 'Adjustment Stock Opname'.

        WHEN '919'.
          lv_code  = '99'.
          lv_name1 = 'Koreksi Batch'.
      ENDCASE.

      READ TABLE gt_out ASSIGNING <fs_out> WITH KEY matnr  = gt_mseg-matnr
                                                    budat  = gt_mseg-budat
                                                    inchg  = gt_mseg-charg
                                                    indoc  = lv_faktur
                                                    incode = lv_code
                                                    norut  = '200'.
      IF sy-subrc = 0.
        <fs_out>-inqty = <fs_out>-inqty + gt_mseg-menge.
      ELSE.
        APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
        <fs_out>-norut  = '200'.
        <fs_out>-budat  = gt_mseg-budat.
        <fs_out>-matnr  = gt_mseg-matnr.
        <fs_out>-indoc  = lv_faktur.
        <fs_out>-inqty  = gt_mseg-menge.
        <fs_out>-inchg  = gt_mseg-charg.
        <fs_out>-incode = lv_code.
        <fs_out>-intxt  = lv_name1.
      ENDIF.
    ENDIF.

** Pengeluaran
    IF gt_mseg-bwart IN gr_bwartout AND
       gt_mseg-shkzg EQ 'H'.

      CLEAR: lv_code,lv_name1.
      CASE gt_mseg-bwart.
        WHEN '161'.
          CLEAR: gt_ekko,gt_lfa1_101.
          READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.
          lv_code = gt_ekko-lifnr.
          READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
          lv_name1 = gt_lfa1_101-name1.

        WHEN '303' OR '641' OR '645' OR 'Z47' OR 'Z41'.
          CLEAR: gt_mseg_641,gt_t001w.
          READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                          mjahr = gt_mseg-mjahr
                                          parent_id = gt_mseg-line_id.
          lv_code = gt_mseg_641-werks.
          READ TABLE gt_t001w WITH KEY werks = lv_code(4).
          lv_name1 = gt_t001w-name1.
          SELECT SINGLE name3 INTO lv_name1
            FROM adrc WHERE addrnumber = gt_t001w-adrnr.

          PERFORM f_tujuan_for_641 USING    gt_mseg_641
                                   CHANGING lv_code lv_name1.

        WHEN '311'.
          CLEAR: lv_adrnr,lv_name1.
          lv_code = gt_mseg-umwrk.

          SELECT SINGLE adrnr INTO lv_adrnr
            FROM twlad WHERE werks = gt_mseg-umwrk
                         AND lgort = gt_mseg-umlgo.
          IF sy-subrc NE 0.
            SELECT SINGLE adrnr INTO lv_adrnr
              FROM t001w WHERE werks = gt_mseg-umwrk.
          ENDIF.
          SELECT SINGLE name3 INTO lv_name1
            FROM adrc WHERE addrnumber = lv_adrnr.

        WHEN '601' OR 'Z07'.
          CLEAR: gt_kna1_655.
          lv_code = gt_mseg-wempf.
          READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
          lv_name1 = gt_kna1_655-name1.

        WHEN '920'.
          lv_code  = '44'.
          lv_name1 = 'Claim to Expedisi'.

        WHEN '555'.
          lv_code  = '55'.
          lv_name1 = 'Pemusnahan'.

        WHEN '922'.
          lv_code  = '66'.
          lv_name1 = 'Claim to Asuransi'.

        WHEN '926'.
          lv_code  = '77'.
          lv_name1 = 'Claim to Principal'.

        WHEN '701' OR '702' OR '703' OR '704' OR '707' OR '708' OR '711' OR
             '712' OR '713' OR '714' OR '715' OR '716' OR '717' OR '718'.
          lv_code  = '88'.
          lv_name1 = 'Adjustment Stock Opname'.

        WHEN '919'.
          lv_code  = '99'.
          lv_name1 = 'Koreksi Batch'.
      ENDCASE.

      READ TABLE gt_out ASSIGNING <fs_out> WITH KEY matnr   = gt_mseg-matnr
                                                    budat   = gt_mseg-budat
                                                    outchg  = gt_mseg-charg
                                                    outdoc  = lv_faktur
                                                    outcode = lv_code
                                                    norut   = '300'.
      IF sy-subrc = 0.
        <fs_out>-outqty = <fs_out>-outqty + gt_mseg-menge.
      ELSE.
        APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
        <fs_out>-norut  = '300'.
        <fs_out>-budat  = gt_mseg-budat.
        <fs_out>-matnr  = gt_mseg-matnr.
        <fs_out>-outdoc  = lv_faktur.
        <fs_out>-outqty  = gt_mseg-menge.
        <fs_out>-outchg  = gt_mseg-charg.
        <fs_out>-outcode = lv_code.
        <fs_out>-outtxt  = lv_name1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DELETE gt_out WHERE salaw  IS INITIAL
                  AND inqty  IS INITIAL
                  AND outqty IS INITIAL.

  IF gt_out[] IS NOT INITIAL.
    SELECT matnr charg vfdat hsdat
      INTO CORRESPONDING FIELDS OF TABLE lt_mch1
      FROM mch1 WHERE matnr = pa_matnr
                  AND charg IN gr_charg.

    SORT gt_out BY matnr norut sawchg inchg outchg.
    LOOP AT gt_out WHERE norut NE '900'.

** Expirated Date
      CLEAR lv_charg.
      IF gt_out-sawchg IS NOT INITIAL.
        lv_charg = gt_out-sawchg.
      ELSEIF gt_out-inchg IS NOT INITIAL.
        lv_charg = gt_out-inchg.
      ELSEIF gt_out-outchg IS NOT INITIAL.
        lv_charg = gt_out-outchg.
      ENDIF.

      CLEAR lt_mch1.
      READ TABLE lt_mch1 WITH KEY matnr = gt_out-matnr
                                  charg = lv_charg.
      gt_out-vfdat = lt_mch1-vfdat.
      MODIFY gt_out TRANSPORTING vfdat.

** Ending Stock
      READ TABLE gt_out ASSIGNING <fs_out> WITH KEY matnr   = gt_out-matnr
                                                    budat   = gr_budat-high
                                                    sakchg  = lv_charg
                                                    norut   = '900'.
      IF sy-subrc = 0.
        CASE gt_out-norut.
          WHEN '100'.
            <fs_out>-salak = <fs_out>-salak + gt_out-salaw.
          WHEN '200'.
            <fs_out>-salak = <fs_out>-salak + gt_out-inqty.
          WHEN '300'.
            <fs_out>-salak = <fs_out>-salak - gt_out-outqty.
        ENDCASE.
      ELSE.
        APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
        <fs_out>-norut  = '900'.
        <fs_out>-budat  = gr_budat-high.
        <fs_out>-matnr  = gt_out-matnr.
        CASE gt_out-norut.
          WHEN '100'.
            <fs_out>-salak  = gt_out-salaw.
            <fs_out>-sakchg = lv_charg.
          WHEN '200'.
            <fs_out>-salak  = gt_out-inqty.
            <fs_out>-sakchg = lv_charg.
          WHEN '300'.
            <fs_out>-salak  = gt_out-outqty * -1.
            <fs_out>-sakchg = lv_charg.
        ENDCASE.
        CLEAR lt_mch1.
        READ TABLE lt_mch1 WITH KEY matnr = <fs_out>-matnr
                                    charg = <fs_out>-sakchg.
        <fs_out>-vfdat = lt_mch1-vfdat.
      ENDIF.
    ENDLOOP.

    DELETE gt_out WHERE salaw  IS INITIAL
                    AND inqty  IS INITIAL
                    AND outqty IS INITIAL
                    AND salak  IS INITIAL
                    AND norut  NE '900'.
  ENDIF.

  PERFORM f_modify_uom.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      CALL SELECTION-SCREEN 500 STARTING AT 3 3
                                ENDING AT  90 5 .

      IF sy-subrc = 0.
        PERFORM f_post_entries.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  PERFORM f_header USING 'ZMPSIKO_CSV'
                   CHANGING gv_filename gv_files.

  LOOP AT gt_out. "INTO wa_out.
    PERFORM f_move_to_wa.
    PERFORM f_add_line USING gt_download-fieldline wa_out-tanggal '' '1' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-saldoawal_bulan ''  '2' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-batch_awal '' '3' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-no_faktur_masuk '' '4' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-sumber '' '5' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-jum_masuk '' '6' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-batch_masuk '' '7' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-no_faktur_keluar '' '8' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-tujuan '' '9' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-jum_keluar '' '10' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-batch_keluar '' '11' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-saldo_akhir '' '12' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-batch_akhir '' '13' ''
                       CHANGING gt_download-fieldline.
    PERFORM f_add_line USING gt_download-fieldline wa_out-expired 'X' '14' ''
                       CHANGING gt_download-fieldline.
    APPEND gt_download.
    CLEAR gt_download.
  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = gv_filename
      filetype                = 'ASC'
*     TRUNC_TRAILING_BLANKS   = 'X'
    TABLES
      data_tab                = gt_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
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
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .

ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .

ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_FOLDER_F4
*&---------------------------------------------------------------------*
FORM f_folder_f4  CHANGING fc_filename.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'File Directory'
      initial_folder  = 'C:'
    CHANGING
      selected_folder = gv_path.

  CALL METHOD cl_gui_cfw=>flush.

  CONCATENATE gv_path '' INTO fc_filename.
ENDFORM.                    " F_FOLDER_F4

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_basme fu_in fu_out
                     CHANGING fc_value.
  DATA : lv_length  TYPE i.

  IF fu_value IS NOT INITIAL.
    IF fu_basme IS NOT INITIAL.
      WRITE fu_value TO fc_value UNIT fu_basme." NO-SIGN.
    ELSE.
      fc_value = fu_value.
    ENDIF.

    CONDENSE fc_value NO-GAPS.

    lv_length = strlen( fc_value ).
    IF lv_length GT 1.
      SHIFT fc_value LEFT DELETING LEADING '0'.
    ENDIF.
  ELSE.
    IF fu_in IS NOT INITIAL OR
      fu_out IS NOT INITIAL.
      fc_value  = 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PLANT
*&---------------------------------------------------------------------*
FORM f_init_plant .
  DATA: lv_lgort TYPE char20,
        lw_tvkol LIKE tvkol,
        lt_t001l TYPE TABLE OF t001l WITH HEADER LINE.

  CLEAR: gr_werks[],gr_lgort[].

  SELECT SINGLE * INTO lw_tvkol
    FROM tvkol WHERE vstel EQ pa_vkbur.

  IF sy-subrc = 0.
    IF lw_tvkol-lgort(1) = '1'.
      CONCATENATE lw_tvkol-lgort(1) '%' INTO lv_lgort.
    ELSE.
      CONCATENATE lw_tvkol-lgort(2) '%' INTO lv_lgort.
    ENDIF.

    SELECT * INTO TABLE lt_t001l
      FROM t001l WHERE werks = lw_tvkol-werks
                   AND lgort LIKE lv_lgort.

    LOOP AT lt_t001l.
      CLEAR: gr_werks,gr_lgort.

      gr_werks-sign   = 'I'.
      gr_werks-option = 'EQ'.
      gr_werks-low    = lt_t001l-werks.
      COLLECT gr_werks. CLEAR gr_werks.

      gr_lgort-sign   = 'I'.
      gr_lgort-option = 'EQ'.
      gr_lgort-low    = lt_t001l-lgort.
      COLLECT gr_lgort. CLEAR gr_lgort.
    ENDLOOP.

  ELSE.
    MESSAGE 'No Sales Office' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " F_INIT_PLANT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BUDAT
*&---------------------------------------------------------------------*
FORM f_init_budat .
  CLEAR gr_budat[].
  CONCATENATE pa_spmon '01' INTO gr_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gr_budat-low
    IMPORTING
      last_day_of_month = gr_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  gr_budat-sign   = 'I'.
  gr_budat-option = 'BT'.
  APPEND gr_budat TO gr_budat.
ENDFORM.                    " F_INIT_BUDAT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BWART
*&---------------------------------------------------------------------*
FORM f_init_bwart .
  DATA lt_zmmmvt_cntrl TYPE TABLE OF zmmmvt_cntrl WITH HEADER LINE.

  CLEAR: gr_bwart[],gr_bwartin[],gr_bwartout[].

  READ TABLE gr_werks INDEX 1.
  SELECT SINGLE bukrs INTO gv_bukrs
    FROM t001k WHERE bwkey EQ gr_werks-low.

  SELECT * INTO TABLE lt_zmmmvt_cntrl
    FROM zmmmvt_cntrl WHERE bukrs = gv_bukrs
                        AND tcode = gc_tcode.

  LOOP AT lt_zmmmvt_cntrl.
    CLEAR: gr_bwart,gr_bwartin,gr_bwartout.

    gr_bwart-sign   = 'I'.
    gr_bwart-option = 'EQ'.
    gr_bwart-low    = lt_zmmmvt_cntrl-bwart.
    COLLECT gr_bwart.

    CASE lt_zmmmvt_cntrl-zio.
      WHEN '10'.
        gr_bwartin-sign   = 'I'.
        gr_bwartin-option = 'EQ'.
        gr_bwartin-low    = lt_zmmmvt_cntrl-bwart.
        APPEND gr_bwartin.

      WHEN '20'.
        gr_bwartout-sign   = 'I'.
        gr_bwartout-option = 'EQ'.
        gr_bwartout-low    = lt_zmmmvt_cntrl-bwart.
        APPEND gr_bwartout.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_INIT_BWART

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPENING_STOCK
*&---------------------------------------------------------------------*
FORM f_get_opening_stock .
  DATA: lt_s035 TYPE TABLE OF s035 WITH HEADER LINE,
        lt_s034 TYPE TABLE OF s034 WITH HEADER LINE.

  SELECT * INTO TABLE lt_s035 FROM s035
    WHERE ssour = space
      AND vrsio = '000'
      AND matnr = pa_matnr
      AND werks IN gr_werks
      AND lgort IN gr_lgort
      AND lgort NE space.

  SELECT * INTO TABLE lt_s034 FROM s034
    WHERE ssour = space
      AND vrsio = '000'
      AND spmon GE gr_budat-low(6)
      AND sptag = '00000000'
      AND spwoc = space
      AND spbup = space
      AND werks IN gr_werks
      AND lgort IN gr_lgort
      AND lgort NE space
      AND matnr = pa_matnr.

  SORT: lt_s035 BY matnr werks charg,
        lt_s034 BY matnr werks charg.

  LOOP AT lt_s035.
    gt_opnstk-matnr = lt_s035-matnr.
    gt_opnstk-werks = lt_s035-werks.
*    gt_opnstk-LGORT = lt_s035-lgort.
    gt_opnstk-charg = lt_s035-charg.
    gt_opnstk-labst = lt_s035-cmbwbest.
    LOOP AT lt_s034 WHERE matnr = lt_s035-matnr
                      AND werks = lt_s035-werks
                      AND charg = lt_s035-charg.
      gt_opnstk-labst = gt_opnstk-labst + lt_s034-cmagbb - lt_s034-cmzubb.
      DELETE lt_s034.
    ENDLOOP.
    COLLECT gt_opnstk. CLEAR gt_opnstk.
  ENDLOOP.

  LOOP AT lt_s034.
    gt_opnstk-matnr = lt_s034-matnr.
    gt_opnstk-werks = lt_s034-werks.
*    gt_opnstk-LGORT = lt_s034-lgort.
    gt_opnstk-charg = lt_s034-charg.
    gt_opnstk-labst = lt_s034-cmagbb - lt_s034-cmzubb.
    COLLECT gt_opnstk.
    CLEAR gt_opnstk.
  ENDLOOP.
ENDFORM.                    " F_GET_OPENING_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_GET_TRANSACTION
*&---------------------------------------------------------------------*
FORM f_get_transaction .
  DATA: lt_mseg_revers LIKE gt_mseg OCCURS 0 WITH HEADER LINE.

  SELECT a~mblnr a~mjahr a~budat line_id parent_id
         zeile bwart xauto matnr werks lgort charg lifnr kunnr menge meins
         ebeln ebelp sjahr smbln smblp elikz sgtxt shkzg budat xblnr wempf
         grund umwrk umlgo
    INTO CORRESPONDING FIELDS OF TABLE gt_mseg
    FROM mkpf AS a JOIN mseg AS b ON b~mblnr = a~mblnr AND
                                     b~mjahr = a~mjahr
    WHERE budat IN gr_budat
      AND bwart IN gr_bwart
      AND matnr EQ pa_matnr
      AND werks IN gr_werks
      AND lgort IN gr_lgort
      AND bukrs EQ gv_bukrs
      AND sobkz EQ space.

  lt_mseg_revers[] = gt_mseg[].
  DELETE gt_mseg WHERE smbln NE space.
  DELETE lt_mseg_revers WHERE smbln EQ space.

  SORT: gt_mseg BY mblnr mjahr zeile,
        lt_mseg_revers BY smbln sjahr smblp.

  LOOP AT lt_mseg_revers.
    READ TABLE gt_mseg WITH KEY mblnr = lt_mseg_revers-smbln
                                mjahr = lt_mseg_revers-sjahr
                                zeile = lt_mseg_revers-smblp
                                BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE gt_mseg INDEX sy-tabix.
    ELSE.
      SORT: gt_mseg BY mblnr mjahr zeile.
      READ TABLE gt_mseg WITH KEY mblnr = lt_mseg_revers-smbln
                                  mjahr = lt_mseg_revers-sjahr
                                  zeile = lt_mseg_revers-smblp
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE gt_mseg INDEX sy-tabix.
      ELSE.
        APPEND lt_mseg_revers TO gt_mseg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_mseg WHERE bwart = '311'.
    IF gt_mseg-umlgo(1) = '1' AND gt_mseg-lgort(1) = '1' AND
       gt_mseg-umwrk = gt_mseg-werks.
      DELETE gt_mseg.
      CONTINUE.
    ENDIF.
    IF gt_mseg-umlgo(1) = '2' AND gt_mseg-lgort(1) = '2' AND
       gt_mseg-umwrk = gt_mseg-werks.
      IF gt_mseg-umlgo(2) = gt_mseg-lgort(2).
        DELETE gt_mseg.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_mseg[] IS NOT INITIAL.
    PERFORM f_get_vbfa.
    PERFORM f_get_sumber.
  ENDIF.
ENDFORM.                    " F_GET_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_VBFA
*&---------------------------------------------------------------------*
FORM f_get_vbfa .
  SELECT vbelv posnv vbeln posnn vbtyp_n rfmng meins matnr bwart lgnum
         mjahr vbtyp_v
    INTO CORRESPONDING FIELDS OF TABLE gt_vbfa
    FROM vbfa FOR ALL ENTRIES IN gt_mseg
    WHERE vbeln = gt_mseg-mblnr
      AND posnn = gt_mseg-zeile
      AND vbtyp_v IN ('T','J').
ENDFORM.                    " F_GET_VBFA

*&---------------------------------------------------------------------*
*&      Form  F_GET_SUMBER
*&---------------------------------------------------------------------*
FORM f_get_sumber .
  DATA: lt_mseg_temp LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lt_ekko_temp TYPE TABLE OF ekko WITH HEADER LINE,
        lv_gjahr     TYPE gjahr.

** 101, 161
  CLEAR lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '101'
                        AND bwart NE '161'.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT ebeln lifnr reswk bsart
      INTO CORRESPONDING FIELDS OF TABLE gt_ekko
      FROM ekko FOR ALL ENTRIES IN lt_mseg_temp
      WHERE ebeln = lt_mseg_temp-ebeln.

    IF sy-subrc = 0.
      CLEAR lt_ekko_temp[].
      lt_ekko_temp[] = gt_ekko[].
      DELETE lt_ekko_temp WHERE lifnr EQ space.
      IF lt_ekko_temp[] IS NOT INITIAL.
        SELECT lifnr name1 adrnr
          INTO CORRESPONDING FIELDS OF TABLE gt_lfa1_101
          FROM lfa1 FOR ALL ENTRIES IN lt_ekko_temp
          WHERE lifnr = lt_ekko_temp-lifnr.
      ENDIF.
    ENDIF.
  ENDIF.

** 305
  CLEAR: lv_gjahr,lt_mseg_temp[].
  lv_gjahr = pa_spmon(4) - 1.
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '305'.
  SORT lt_mseg_temp BY sgtxt.
  DELETE ADJACENT DUPLICATES FROM lt_mseg_temp COMPARING sgtxt.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile bwart xauto matnr werks lgort
           charg shkzg grund
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg_305
      FROM mseg FOR ALL ENTRIES IN lt_mseg_temp
      WHERE mblnr = lt_mseg_temp-sgtxt(10)
        AND mjahr BETWEEN lv_gjahr AND pa_spmon(4)
        AND bwart = '303'
        AND xauto = space.
  ENDIF.

** 303, 641, 645, 675
  CLEAR: lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '303'
                        AND bwart NE '641'
                        AND bwart NE '645'
                        AND bwart NE '675'
                        AND bwart NE 'Z47'
                        AND bwart NE 'Z41'.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile line_id parent_id bwart xauto
           matnr werks lgort charg shkzg kunnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg_641
      FROM mseg FOR ALL ENTRIES IN lt_mseg_temp
      WHERE mblnr = lt_mseg_temp-mblnr
        AND mjahr = lt_mseg_temp-mjahr
        AND parent_id = lt_mseg_temp-line_id.
  ENDIF.

** 655, 653, 601, 641,, 645, 675, Z07
  CLEAR lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '655'
                        AND bwart NE '653'
                        AND bwart NE '601'
                        AND bwart NE '641'
                        AND bwart NE '645'
                        AND bwart NE '675'
                        AND bwart NE 'Z07'
                        AND bwart NE 'Z13'
                        AND bwart NE '913'
                        AND bwart NE 'Z47'
                        AND bwart NE 'Z41'.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT kunnr name1 adrnr
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1_655
      FROM kna1 FOR ALL ENTRIES IN lt_mseg_temp
      WHERE kunnr = lt_mseg_temp-wempf(10).
*      WHERE kunnr = lt_mseg_temp-kunnr.
  ENDIF.
ENDFORM.                    " F_GET_SUMBER

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_BATCH
*&---------------------------------------------------------------------*
FORM f_collect_batch USING fu_charg.
  CLEAR gr_charg.
  gr_charg-sign   = 'I'.
  gr_charg-option = 'EQ'.
  gr_charg-low    = fu_charg.
  COLLECT gr_charg.
ENDFORM.                    " F_COLLECT_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_INIT_T001W
*&---------------------------------------------------------------------*
FORM f_init_t001w .
  SELECT * INTO TABLE gt_t001w
    FROM t001w.
ENDFORM.                    " F_INIT_T001W

*&---------------------------------------------------------------------*
*&      Form  F_TUJUAN_FOR_641
*&---------------------------------------------------------------------*
FORM f_tujuan_for_641  USING    fu_mseg STRUCTURE mseg
                       CHANGING fc_code
                                fc_name1.
  DATA: ls_t001l LIKE t001l,
        ls_twlad LIKE twlad,
        ls_adrct LIKE adrct,
        ls_adrc  LIKE adrc.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_t001l
    FROM t001l WHERE kunnr = fu_mseg-kunnr.

  IF sy-subrc = 0.
    SELECT SINGLE werks lgort adrnr
      INTO CORRESPONDING FIELDS OF ls_twlad
      FROM twlad WHERE werks = ls_t001l-werks
                   AND lgort = ls_t001l-lgort.
    IF sy-subrc = 0.
      SELECT SINGLE addrnumber name3
        INTO CORRESPONDING FIELDS OF ls_adrc
        FROM adrc WHERE addrnumber = ls_twlad-adrnr.
      IF sy-subrc = 0.
        CLEAR fc_name1.
        fc_code  = ls_t001l-vstel.
        fc_name1 = ls_adrc-name3.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_TUJUAN_FOR_641

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  USING    fu_tabname
               CHANGING fc_filename fc_files.

  DATA: BEGIN OF lt_dd03l OCCURS 0,
          tabname   TYPE tabname,
          fieldname TYPE fieldname,
          as4local  TYPE as4local,
          as4vers   TYPE as4vers,
          position  TYPE tabfdpos,
        END OF lt_dd03l.
  DATA: lv_flag(1),
        lv_record  TYPE i,
        lv_count   TYPE i.

  SELECT tabname fieldname as4local as4vers position
    FROM dd03l
    INTO TABLE lt_dd03l
    WHERE tabname   EQ fu_tabname.

  DESCRIBE TABLE lt_dd03l LINES lv_record.
  SORT lt_dd03l BY position.
  LOOP AT lt_dd03l.
    ADD 1 TO lv_count.
    IF lv_count EQ lv_record.
      lv_flag = 'X'.
    ENDIF.

    CASE lv_count.
      WHEN 1.
        wa_out-tanggal = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-tanggal lv_flag
                                 lv_count  ''
                           CHANGING gt_download-fieldline.
      WHEN 2.
        wa_out-saldoawal_bulan = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-saldoawal_bulan lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 3.
        wa_out-batch_awal = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-batch_awal lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 4.
        wa_out-no_faktur_masuk = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-no_faktur_masuk lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 5.
        wa_out-sumber = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-sumber lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 6.
        wa_out-jum_masuk = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-jum_masuk lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 7.
        wa_out-batch_masuk = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-batch_masuk lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 8.
        wa_out-no_faktur_keluar = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-no_faktur_keluar lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 9.
        wa_out-tujuan = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-tujuan lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 10.
        wa_out-jum_keluar = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-jum_keluar lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 11.
        wa_out-batch_keluar = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-batch_keluar lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 12.
        wa_out-saldo_akhir = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-saldo_akhir lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 13.
        wa_out-batch_akhir = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-batch_akhir lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
      WHEN 14.
        wa_out-expired = lt_dd03l-fieldname.
        PERFORM f_add_line USING gt_download-fieldline wa_out-expired lv_flag
                                 lv_count ''
                           CHANGING gt_download-fieldline.
    ENDCASE.

  ENDLOOP.
  APPEND gt_download.

  CLEAR : gt_download, wa_out.
  gt_temp[] = gt_download[].

  CONCATENATE filename '\F' pa_matnr '.CSV'
         INTO fc_filename.
  CONCATENATE '\F' pa_matnr '.CSV'
         INTO fc_files.

ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ADD_LINE
*&---------------------------------------------------------------------*
FORM f_add_line  USING    fu_fieldline fu_value fu_flag fu_count fu_point
                 CHANGING fc_fieldline.

  DATA : lv_subrc   TYPE int4.

  IF fu_point IS NOT INITIAL.
    WHILE lv_subrc IS INITIAL.
      REPLACE '.' IN fu_value WITH space.
      lv_subrc  = sy-subrc.
      CONDENSE fu_value.
    ENDWHILE.
  ENDIF.

  CASE fu_count.
    WHEN 1.
      fc_fieldline = fu_value.
      fc_fieldline+11(1) = gc_delim.
    WHEN 2.
      fc_fieldline+12(16) = fu_value.
      fc_fieldline+28(1) = gc_delim.
    WHEN 3.
      fc_fieldline+29(12) = fu_value.
      fc_fieldline+41(1) = gc_delim.
    WHEN 4.
      fc_fieldline+42(16) = fu_value.
      fc_fieldline+58(1) = gc_delim.
    WHEN 5.
      fc_fieldline+59(40) = fu_value.
      fc_fieldline+99(1) = gc_delim.
    WHEN 6.
      fc_fieldline+100(10) = fu_value.
      fc_fieldline+110(1) = gc_delim.
    WHEN 7.
      fc_fieldline+111(12) = fu_value.
      fc_fieldline+123(1) = gc_delim.
    WHEN 8.
      fc_fieldline+124(17) = fu_value.
      fc_fieldline+141(1) = gc_delim.
    WHEN 9.
      fc_fieldline+142(40) = fu_value.
      fc_fieldline+182(1) = gc_delim.
    WHEN 10.
      fc_fieldline+183(11) = fu_value.
      fc_fieldline+194(1) = gc_delim.
    WHEN 11.
      fc_fieldline+195(13) = fu_value.
      fc_fieldline+208(1) = gc_delim.
    WHEN 12.
      fc_fieldline+209(12) = fu_value.
      fc_fieldline+221(1) = gc_delim.
    WHEN 13.
      fc_fieldline+222(12) = fu_value.
      fc_fieldline+234(1) = gc_delim.
    WHEN 14.
      fc_fieldline+235(11) = fu_value.
  ENDCASE.
ENDFORM.                    " F_ADD_LINE

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_WA
*&---------------------------------------------------------------------*
FORM f_move_to_wa .
  CLEAR: wa_out.

  CONCATENATE gt_out-budat(4) gt_out-budat+4(2) gt_out-budat+6(2)
    INTO wa_out-tanggal SEPARATED BY '-'.
  CONCATENATE gt_out-vfdat(4) gt_out-vfdat+4(2) gt_out-vfdat+6(2)
    INTO wa_out-expired SEPARATED BY '-'.

  WRITE: "gt_out-budat  TO wa_out-tanggal,
         gt_out-salaw  TO wa_out-saldoawal_bulan UNIT gt_out-meins NO-ZERO,
         gt_out-sawchg TO wa_out-batch_awal,
         gt_out-indoc  TO wa_out-no_faktur_masuk,
         gt_out-intxt  TO wa_out-sumber,
         gt_out-inqty  TO wa_out-jum_masuk UNIT gt_out-meins NO-ZERO,
         gt_out-inchg  TO wa_out-batch_masuk,
         gt_out-outdoc TO wa_out-no_faktur_keluar,
         gt_out-outtxt TO wa_out-tujuan,
         gt_out-outqty TO wa_out-jum_keluar UNIT gt_out-meins NO-ZERO,
         gt_out-outchg TO wa_out-batch_keluar,
         gt_out-salak  TO wa_out-saldo_akhir UNIT gt_out-meins,
         gt_out-sakchg TO wa_out-batch_akhir.
  "gt_out-vfdat  TO wa_out-expired.

  IF wa_out-batch_akhir IS INITIAL.
    CLEAR wa_out-saldo_akhir.
  ENDIF.

  REPLACE ALL OCCURRENCES OF '.' IN wa_out-saldoawal_bulan WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN wa_out-saldoawal_bulan WITH '.'.
  CONDENSE wa_out-saldoawal_bulan.

  REPLACE ALL OCCURRENCES OF '.' IN wa_out-jum_masuk WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN wa_out-jum_masuk WITH '.'.
  CONDENSE wa_out-jum_masuk.

  REPLACE ALL OCCURRENCES OF '.' IN wa_out-jum_keluar WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN wa_out-jum_keluar WITH '.'.
  CONDENSE wa_out-jum_keluar.

  REPLACE ALL OCCURRENCES OF '.' IN wa_out-saldo_akhir WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN wa_out-saldo_akhir WITH '.'.
  CONDENSE wa_out-saldo_akhir.
ENDFORM.                    " F_MOVE_TO_WA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UOM
*&---------------------------------------------------------------------*
FORM f_modify_uom .
  IF gt_out[] IS NOT INITIAL.
    SELECT matnr meins INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FROM mara FOR ALL ENTRIES IN gt_out
      WHERE matnr = gt_out-matnr.

    LOOP AT gt_out ASSIGNING <fs_out>.
      CLEAR: gt_mara.
      READ TABLE gt_mara WITH KEY matnr = <fs_out>-matnr.
      <fs_out>-meins = gt_mara-meins.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_UOM
