*----------------------------------------------------------------------*
*   INCLUDE ZF_FKF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT *
    FROM zplbc
    INTO CORRESPONDING FIELDS OF TABLE gt_zplbc.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_s626  LIKE gt_s626 OCCURS 0 WITH HEADER LINE,
         lt_mseg  LIKE gt_mseg OCCURS 0 WITH HEADER LINE.
  DATA : lv_zfile  TYPE zfile.

  DATA : lr_fkdat   TYPE RANGE OF fkdat,
         lv_fkdat   LIKE LINE OF lr_fkdat.

  CONCATENATE so_fkdat-low(6) '01' INTO lv_fkdat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_fkdat-low
    IMPORTING
      last_day_of_month = lv_fkdat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lv_fkdat-sign   = 'I'.
  lv_fkdat-option = 'BT'.
  APPEND lv_fkdat TO lr_fkdat.

  lv_zfile  = pa_flnm1.

* FK
  CASE 'X'.
    WHEN ra_fk.
      PERFORM f_cek_lock.

* Get Download Numbering
      SELECT *
        FROM zfnoefaktur
        INTO CORRESPONDING FIELDS OF TABLE gt_zfnoefaktur
        WHERE bukrs EQ pa_bukrs
          AND zfakty EQ gc_zfakty.

      IF gt_zfnoefaktur[] IS INITIAL.
        PERFORM f_release_lock.
        MESSAGE i000(zab) WITH 'Please maintenance download numbering'.
        STOP.
      ENDIF.

      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
        WHERE vkorg EQ pa_bukrs
          AND vkbur IN so_vkbur
          AND fkdat IN so_fkdat
          AND vbeln IN so_vbeln
          AND zuonr IN so_zuonr
          AND files EQ space.

      IF gt_zfvato[] IS NOT INITIAL.
        LOOP AT gt_zfvato INTO wa_zfvato.
          wa_zfvato1 = wa_zfvato.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_zfvato-vbeln
            IMPORTING
              output = wa_zfvato1-vbeln.
          APPEND wa_zfvato1 TO gt_zfvato1.
        ENDLOOP.

*        SELECT bukrs belnr gjahr budat
*          FROM bkpf
*          INTO TABLE gt_bkpf
*          FOR ALL ENTRIES IN gt_zfvato
*          WHERE bukrs EQ pa_bukrs
*            AND belnr EQ gt_zfvato-vbeln
*            AND gjahr EQ gt_zfvato-dueyr.
      ENDIF.

    WHEN ra_rfk.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
        WHERE vkorg EQ pa_bukrs
          AND files EQ lv_zfile.

    WHEN ra_del.
      IF pa_vbeln IS NOT INITIAL.
        SELECT *
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
          WHERE vkorg EQ pa_bukrs
            AND vbeln EQ pa_vbeln
            AND files EQ lv_zfile.
      ELSEIF pa_zuonr IS NOT INITIAL.
        SELECT *
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
          WHERE vkorg EQ pa_bukrs
            AND zuonr EQ pa_zuonr
            AND files EQ lv_zfile.
      ENDIF.

    WHEN ra_rpt.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
        WHERE vkorg EQ pa_bukrs
          AND vkbur IN so_vkbur
          AND fkdat IN so_fkdat
          AND vbeln IN so_vbeln
          AND zuonr IN so_zuonr.
  ENDCASE.

* OF
  IF ra_rpt IS INITIAL.
    LOOP AT gt_zfvato1 INTO wa_zfvato1.
      READ TABLE gt_zplbc INTO wa_zplbc WITH KEY bukrs = pa_bukrs
                                                 werks = wa_zfvato1-vkbur.
      IF sy-subrc = 0.
        IF wa_zplbc-live IS INITIAL.
          wa_zfvato1-vbeln = wa_zfvato1-zuonr.
        ENDIF.
      ENDIF.
      MODIFY gt_zfvato1 FROM wa_zfvato1 TRANSPORTING vbeln.
    ENDLOOP.

    IF gt_zfvato1[] IS NOT INITIAL.
      SELECT ssour vrsio spmon sptag spwoc spbup vkbur fkart vbeln
        pkunwe matnr basme umkzwi1 ummenge mwsbp umkzwi5
        FROM s626
        INTO TABLE gt_s626
        FOR ALL ENTRIES IN gt_zfvato1
        WHERE ssour EQ space
          AND vrsio EQ '000'
          AND spmon EQ '000000'
          AND sptag IN lr_fkdat
          AND spwoc EQ '000000'
          AND spbup EQ '000000'
          AND vkbur EQ gt_zfvato1-vkbur
          AND vbeln EQ gt_zfvato1-vbeln
          AND pkunwe EQ gt_zfvato1-kunrg.
    ENDIF.

    IF gt_zfvato[] IS NOT INITIAL.
      SELECT mblnr mjahr zeile matnr menge meins dmbtr waers bukrs umwrk
        FROM mseg
        INTO TABLE lt_mseg
        FOR ALL ENTRIES IN gt_zfvato
        WHERE bukrs = gt_zfvato-vkorg
          AND bwart = '641'
          AND umwrk = gt_zfvato-vkbur
          AND mjahr = gt_zfvato-dueyr
          AND mblnr = gt_zfvato-vbeln.
    ENDIF.

    LOOP AT gt_s626.
      lt_s626-matnr = gt_s626-matnr.
      APPEND lt_s626.
      CLEAR lt_s626.
    ENDLOOP.
    SORT lt_mseg BY mblnr matnr.
    LOOP AT lt_mseg.
      lt_s626-matnr = lt_mseg-matnr.
      APPEND lt_s626.
      CLEAR lt_s626.

      gt_mseg = lt_mseg.
      CLEAR gt_mseg-zeile.
      COLLECT gt_mseg.
    ENDLOOP.

    SORT lt_s626 BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_s626 COMPARING matnr.
    IF lt_s626[] IS NOT INITIAL.
      SELECT matnr maktx
        FROM makt
        INTO TABLE gt_makt
        FOR ALL ENTRIES IN lt_s626
        WHERE matnr EQ lt_s626-matnr
          AND spras EQ sy-langu.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN ra_rpt.
      PERFORM f_alv1 TABLES gt_zfvato.
    WHEN OTHERS.
      PERFORM f_alv TABLES gt_out gt_of.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report ft_report1.
  DATA: lv_func(30),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report ft_report1.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'.

  CALL FUNCTION lv_func
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
      i_tabname_header         = 'GT_OUT'
      i_tabname_item           = 'GT_OF'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report
      t_outtab_item            = ft_report1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*&---------------------------------------------------------------------*
*&      Form  F_ALV1
*&---------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_report.
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
ENDFORM.                                                    " F_ALV1

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report ft_report1.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING 'GT_OUT':
    'FK' '' '' '' '4' 'FK' '' '' '' '' '' '' '' '' '' '',
    'KD_JENIS_TRANSAKSI' '' '' '' '10' 'KdJnsTran.' '' '' '' '' '' '' '' '' '' '',
    'FG_PENGGANTI' '' '' '' '15' 'FG_PENGGANTI' '' '' '' '' '' '' '' '' '' '',
    'NOMOR_FAKTUR' '' '' '' '15' 'NOMOR_FAKTUR' '' '' '' '' '' '' '' '' '' '',
    'MASA_PAJAK' '' '' '' '7' 'MsPajak' '' '' '' '' '' '' '' '' '' '',
    'TAHUN_PAJAK' '' '' '' '5' 'Tahun' '' '' '' '' '' '' '' '' '' '',
    'TANGGAL_FAKTUR' '' '' '' '10' 'TglFktr' '' '' '' '' '' '' '' '' '' '',
    'NPWP' '' '' '' '20' 'NPWP' '' '' '' '' '' '' '' '' '' '',
    'NAMA' '' '' '' '30' 'NAMA' '' '' '' '' '' '' '' '' '' '',
    'ALAMAT_LENGKAP' '' '' '' '40' 'Alamat' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_DPP' '' '' '' '20' 'DPP' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_PPN' '' '' '' '20' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_PPNBM' '' '' '' '20' 'PPN BM' '' '' '' '' '' '' '' '' '' '',
    'ID_KETERANGAN_TAMBAHAN' '' '' '' '4' 'ID' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA' '' '' '' '20' 'UANG MUKA' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA_DPP' '' '' '' '20' 'UANG_MUKA_DPP' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA_PPN' '' '' '' '20' 'UANG_MUKA_PPN' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA_PPNBM' '' '' '' '20' 'UANG_MUKA_PPNBM' '' '' '' '' '' '' '' '' '' '',
    'REFERENSI' '' '' '' '50' 'REFERENSI' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_OF':
    'OF' '' '' '' '4' 'OF' '' '' '' '' '' '' '' '' '' '',
    'KODE_OBJEK' '' '' '' '20' 'KODE_OBJEK' '' '' '' '' '' '' '' '' '' '',
    'NAMA' '' '' '' '30' 'NAMA' '' '' '' '' '' '' '' '' '' '',
    'HARGA_SATUAN' '' '' '' '20' 'HARGA_SATUAN' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_BARANG' '' '' '' '20' 'JUMLAH_BARANG' '' '' '' '' '' '' '' '' '' '',
    'HARGA_TOTAL' '' '' '' '20' 'HARGA_TOTAL' '' '' '' '' '' '' '' '' '' '',
    'DISKON' '' '' '' '20' 'DISKON' '' '' '' '' '' '' '' '' '' '',
    'DPP' '' '' '' '20' 'DPP' '' '' '' '' '' '' '' '' '' '',
    'PPN' '' '' '' '20' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'TARIF_PPNBM' '' '' '' '20' 'TARIF_PPNBM' '' '' '' '' '' '' '' '' '' '',
    'PPNBM' '' '' '' '20' 'PPNBM' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_OUT'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_OF'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT1
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'VKORG' 'ZFVATO' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFVATO' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VATNO' 'ZFVATO' 'VATNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'ZFVATO' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'ZFVATO' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUEYR' 'ZFVATO' 'DUEYR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME_CO' 'ZFVATO' 'NAME_CO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STCEG' 'ZFVATO' 'STCEG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NETWR' 'ZFVATO' 'NETWR' '' '' '' '' '' '' 'IDR' '' '' '' '' '' '',
    'MWSBK' 'ZFVATO' 'MWSBK' '' '' '' '' '' '' 'IDR' '' '' '' '' '' '',
    'FILES' 'ZFVATO' 'FILES' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_emphasize).

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

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
FORM f_build_keyinfo  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'VBELN'.
  fu_keyinfo-item01   = 'VBELN'.
ENDFORM.                    " F_BUILD_KEYINFO

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'MATKL'.
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
  PERFORM f_hdr_line3 USING gv_filename.
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
  CASE 'X'.
    WHEN ra_rpt.
      SET PF-STATUS 'STANDARD'.
    WHEN OTHERS.
      SET PF-STATUS 'TOEXECUTE'.
  ENDCASE.
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
  DATA : lv_vatpr      TYPE zvapr,
         lv_hargasat   TYPE mc_umkzwi1,
         lv_hargattl   TYPE mc_umkzwi1,
         lv_dpp        TYPE mc_umkzwi1,
         lv_ppn        TYPE mc_umkzwi1,
         lv_diskon     TYPE mc_umkzwi1,
         lv_netwr      TYPE mc_umkzwi1,
         lv_vbeln      TYPE vbeln.

  DATA : name   TYPE tdobname.

  DATA :  lt_itab  TYPE STANDARD TABLE OF tline,
          lt_lines TYPE STANDARD TABLE OF tline,
          wa_lines LIKE tline.

  PERFORM f_header CHANGING gv_filename gv_files gv_nomor.

  LOOP AT gt_zfvato INTO wa_zfvato.
    wa_zfvato-files = gv_files.
    MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING files.

    gt_out-fk                   = 'FK'.
    gt_out-vkbur                = wa_zfvato-vkbur.
    gt_out-vbeln                = wa_zfvato-vbeln.

    PERFORM f_modify_npwp USING wa_zfvato-vatpr
                        CHANGING lv_vatpr.

    gt_out-kd_jenis_transaksi   = lv_vatpr(2).
    gt_out-fg_pengganti         = '0'.
    gt_out-nomor_faktur         = lv_vatpr+3(13).

    IF wa_zfvato-flkor IS INITIAL.
      gt_out-fg_pengganti   = '0'.
    ELSE.
      gt_out-fg_pengganti   = '1'.
    ENDIF.

    gt_out-masa_pajak    = wa_zfvato-dudat+4(2).
    gt_out-tahun_pajak   = wa_zfvato-dudat(4).

    PERFORM f_modify_date USING wa_zfvato-dudat
                          CHANGING gt_out-tanggal_faktur.

    IF wa_zfvato-stceg IS INITIAL.
      wa_zfvato-stceg = '000000000000000'.
    ENDIF.
    PERFORM f_modify_npwp USING wa_zfvato-stceg
                        CHANGING gt_out-npwp.

    PERFORM f_remove_special_char USING wa_zfvato-name_co
                                  CHANGING wa_zfvato-name_co.
    gt_out-nama   = wa_zfvato-name_co.

    PERFORM f_remove_special_char USING wa_zfvato-str_suppl1
                                  CHANGING wa_zfvato-str_suppl1.
    PERFORM f_remove_special_char USING wa_zfvato-str_suppl2
                                  CHANGING wa_zfvato-str_suppl2.
    PERFORM f_remove_special_char USING wa_zfvato-ort01
                                  CHANGING wa_zfvato-ort01.

    CONCATENATE wa_zfvato-str_suppl1 wa_zfvato-str_suppl2
                wa_zfvato-ort01 wa_zfvato-pstlz
           INTO gt_out-alamat_lengkap
    SEPARATED BY space.

    PERFORM f_modify_value USING wa_zfvato-netwr ''
                           CHANGING gt_out-jumlah_dpp.
    PERFORM f_modify_value USING wa_zfvato-mwsbk ''
                           CHANGING gt_out-jumlah_ppn.
    PERFORM f_modify_value USING '0' ''
                           CHANGING gt_out-jumlah_ppnbm.

    CASE lv_vatpr+1(2).
      WHEN '07'.
        gt_out-id_keterangan_tambahan = '1'.
      WHEN '08'.
        gt_out-id_keterangan_tambahan = '1'.
    ENDCASE.

    PERFORM f_modify_value USING '0' ''
                           CHANGING gt_out-uang_muka.
    PERFORM f_modify_value USING '0' ''
                           CHANGING gt_out-uang_muka_dpp.
    PERFORM f_modify_value USING '0' ''
                           CHANGING gt_out-uang_muka_ppn.
    PERFORM f_modify_value USING '0' ''
                           CHANGING gt_out-uang_muka_ppnbm.

    CONCATENATE wa_zfvato-vkbur wa_zfvato-kunrg wa_zfvato-vbeln
                wa_zfvato-zuonr gv_files
    INTO gt_out-referensi
    SEPARATED BY space.

    APPEND gt_out.
    CLEAR gt_out.

    CASE wa_zfvato-vtart.
      WHEN 'DN'.
        LOOP AT gt_mseg WHERE bukrs = wa_zfvato-vkorg
                          AND umwrk = wa_zfvato-vkbur
                          AND mjahr = wa_zfvato-dueyr
                          AND mblnr = wa_zfvato-vbeln.

          CLEAR : lv_hargasat.
          gt_of-vkbur  = wa_zfvato-vkbur.
          gt_of-vbeln  = wa_zfvato-vbeln.
          gt_of-of     = 'OF'.
          gt_of-kode_objek  = gt_mseg-matnr.
          READ TABLE gt_makt WITH KEY matnr = gt_mseg-matnr.
          IF sy-subrc EQ 0.
            gt_of-nama  = gt_makt-maktx.
          ENDIF.

          lv_hargasat = gt_mseg-dmbtr / gt_mseg-menge.
          lv_ppn  = gt_mseg-dmbtr / 10.

          PERFORM f_add_value USING gt_mseg-menge gt_mseg-meins lv_hargasat
                                    gt_mseg-dmbtr 0 gt_mseg-dmbtr lv_ppn.

          APPEND gt_of.
          CLEAR gt_of.
        ENDLOOP.

      WHEN 'FI'.
        gt_of-vkbur  = wa_zfvato-vkbur.
        gt_of-vbeln  = wa_zfvato-vbeln.
        gt_of-of     = 'OF'.

        CONCATENATE wa_zfvato-vkorg wa_zfvato-vbeln wa_zfvato-dueyr
        INTO name.

        CALL FUNCTION 'READ_TEXT_INLINE'
          EXPORTING
            id             = '0004'
            inline_count   = 15
            language       = 'E'
            name           = name
            object         = 'BELEG'
          TABLES
            inlines        = lt_itab
            lines          = lt_lines
          EXCEPTIONS
            id             = 1
            language       = 2
            name           = 3
            not_found      = 4
            object         = 5
            refrence_check = 6
            OTHERS         = 7.

        READ TABLE lt_lines INTO wa_lines INDEX 1.

        gt_s626-ummenge = wa_lines-tdline+50(13).
        gt_s626-ummenge = gt_s626-ummenge / 100.
        gt_s626-basme   = wa_lines-tdline+94(4).

        TRY .
            lv_hargasat = wa_zfvato-wrbtr / gt_s626-ummenge.

          CATCH cx_sy_zerodivide.

        ENDTRY.

        PERFORM f_add_value USING gt_s626-ummenge gt_s626-basme lv_hargasat
                                  wa_zfvato-wrbtr 0 wa_zfvato-netwr wa_zfvato-mwsbk.

        APPEND gt_of.
        CLEAR gt_of.

      WHEN 'SD'.
        READ TABLE gt_zplbc INTO wa_zplbc WITH KEY bukrs = pa_bukrs
                                                   werks = wa_zfvato-vkbur.
        IF sy-subrc = 0.
          IF wa_zplbc-live IS INITIAL.
            lv_vbeln  = wa_zfvato-zuonr.
          ELSE.
            lv_vbeln  = wa_zfvato-vbeln.
          ENDIF.
        ENDIF.

        LOOP AT gt_s626 WHERE vkbur = wa_zfvato-vkbur
                          AND vbeln = lv_vbeln.

          CLEAR : lv_hargasat.

          gt_of-vkbur  = wa_zfvato-vkbur.
          gt_of-vbeln  = wa_zfvato-vbeln.
          gt_of-of     = 'OF'.
          gt_of-kode_objek  = gt_s626-matnr.
          READ TABLE gt_makt WITH KEY matnr = gt_s626-matnr.
          IF sy-subrc EQ 0.
            gt_of-nama  = gt_makt-maktx.
          ENDIF.

          lv_dpp  = gt_s626-umkzwi5 / ( 11 / 10 ).

          TRY .
              lv_hargasat  = lv_dpp / gt_s626-ummenge.

            CATCH cx_sy_zerodivide.

          ENDTRY.

          lv_hargattl = gt_s626-umkzwi1 / ( 11 / 10 ).

          lv_diskon = lv_hargattl - lv_dpp.
          lv_diskon = ABS( lv_diskon ).

          ADD lv_dpp TO lv_netwr.

          PERFORM f_add_value USING gt_s626-ummenge gt_s626-basme lv_hargasat
                                    lv_hargattl lv_diskon lv_dpp gt_s626-mwsbp.

          APPEND gt_of.
          CLEAR gt_of.
        ENDLOOP.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&LOG'.
      CALL SCREEN 1400 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA : lv_subrc   TYPE sy-subrc,
         filename   TYPE string.

  PERFORM f_validasi_data.

  IF gt_error[] IS INITIAL.
    filename  = gv_filename.

    CALL FUNCTION 'ZF_EFAKTUR'
      EXPORTING
        filename     = filename
        delimiter    = pa_delim
        fk           = 'X'
        of           = 'X'
      IMPORTING
        zresult      = lv_subrc
      TABLES
        zfstefktr_fk = gt_out
        zfstefktr_of = gt_of.

    IF lv_subrc IS INITIAL.
      CASE 'X'.
        WHEN ra_fk.
          UPDATE zfnoefaktur SET znomor = gv_nomor
                           WHERE bukrs EQ pa_bukrs
                             AND zfakty EQ gc_zfakty.

          MODIFY zfvato FROM TABLE gt_zfvato.
      ENDCASE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Format error, please check in error log'.
  ENDIF.
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
  CASE 'X'.
    WHEN ra_fk.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FN1' OR 'VB1' OR 'ZU1'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_rfk.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'VKB' OR 'KUN' OR 'FKD' OR 'VBE' OR 'VB1' OR 'ZUO' OR 'ZU1'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_del.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'VKB' OR 'KUN' OR 'FKD' OR 'VBE' OR 'ZUO'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_rpt.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FN1' OR 'VB1' OR 'DIS' OR 'DEL' OR 'ZU1'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lt_zfnoefaktur  LIKE zfnoefaktur OCCURS 0 WITH HEADER LINE.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' '0'.
  ENDIF.

  SELECT *
    FROM zfnoefaktur
    INTO CORRESPONDING FIELDS OF TABLE lt_zfnoefaktur
    WHERE bukrs  = pa_bukrs
      AND zfakty = gc_zfakty.

  READ TABLE lt_zfnoefaktur INDEX 1.

  CASE 'X'.
    WHEN ra_fk.
      IF lt_zfnoefaktur-masatx = space.
        PERFORM f_error_selection_screen USING 'FKD' '2'.
      ELSE.
        IF so_fkdat-low(6) < lt_zfnoefaktur-masatx.
          PERFORM f_error_selection_screen USING 'FKD' '1'.
        ENDIF.
      ENDIF.
    WHEN ra_rfk.
      IF pa_flnm1 IS INITIAL.
        PERFORM f_error_selection_screen USING 'FN1' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  CHANGING fc_filename fc_files fc_nomor.

  READ TABLE gt_zfnoefaktur INDEX 1.
  IF sy-subrc EQ 0.
    IF ra_rfk IS NOT INITIAL.
      gt_zfnoefaktur-znomor = pa_flnm1+2(6).
    ENDIF.
    pa_flnm1  = gt_zfnoefaktur-folder.
    CONCATENATE pa_flnm1 '\' gc_zfakty gt_zfnoefaktur-znomor '.CSV'
           INTO fc_filename.
    CONCATENATE gc_zfakty gt_zfnoefaktur-znomor '.CSV'
           INTO fc_files.
    fc_nomor  = gt_zfnoefaktur-znomor + 1.
  ENDIF.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CEK_LOCK
*&---------------------------------------------------------------------*
FORM f_cek_lock .
  CALL FUNCTION 'ENQUEUE_EZFNOEFAKTUR'
    EXPORTING
      bukrs          = pa_bukrs
      zfakty         = gc_zfakty
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(zf) WITH 'Transaction current process by another W-S'.
  ENDIF.
ENDFORM.                    " F_CEK_LOCK

*&---------------------------------------------------------------------*
*&      Form  F_RELEASE_LOCK
*&---------------------------------------------------------------------*
FORM f_release_lock .
  CALL FUNCTION 'DEQUEUE_EZFNOEFAKTUR'
    EXPORTING
      bukrs  = pa_bukrs
      zfakty = gc_zfakty.
ENDFORM.                    " F_RELEASE_LOCK

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_NPWP
*&---------------------------------------------------------------------*
FORM f_modify_npwp  USING    fu_stceg
                    CHANGING fc_npwp.

  DATA : lv_subrc   TYPE sy-subrc.

  IF fu_stceg IS NOT INITIAL.
    fc_npwp = fu_stceg.
    WHILE lv_subrc EQ 0.
      REPLACE '.' WITH space INTO fc_npwp.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CLEAR lv_subrc.
    WHILE lv_subrc EQ 0.
      REPLACE '-' WITH space INTO fc_npwp.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CONDENSE fc_npwp NO-GAPS.
  ENDIF.
ENDFORM.                    " F_MODIFY_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATE
*&---------------------------------------------------------------------*
FORM f_modify_date  USING    fu_datum
                    CHANGING fc_datum.

  CONCATENATE fu_datum+6(2) fu_datum+4(2) fu_datum(4)
  INTO fc_datum
  SEPARATED BY '/'.
ENDFORM.                    " F_MODIFY_DATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_basme
                     CHANGING fc_value.
  DATA : lv_subrc   TYPE sy-subrc,
         lv_length  TYPE i.

  IF fu_value IS NOT INITIAL.
    IF fu_basme IS NOT INITIAL.
      WRITE fu_value TO fc_value UNIT fu_basme.
    ELSE.
      fc_value = fu_value.
    ENDIF.

    WHILE lv_subrc EQ 0.
      REPLACE '.' WITH space INTO fc_value.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CONDENSE fc_value NO-GAPS.

    lv_length = STRLEN( fc_value ).
    IF lv_length GT 1.
      SHIFT fc_value LEFT DELETING LEADING '0'.
    ENDIF.
  ENDIF.

  IF fc_value IS INITIAL.
    fc_value = '0'.
  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Periode Pajak belum berlaku untuk eFaktur'.
    WHEN '2'.
      lv_mess = 'Periode Pajak belum di maintain untuk eFaktur'.
  ENDCASE.

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
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data .
  DATA : lv_baris   TYPE int4.
  DATA : lt_kdjnstr TYPE STANDARD TABLE OF zfe_kdjnstr.

  CLEAR lv_baris.
  SELECT *
    FROM zfe_kdjnstr
    INTO CORRESPONDING FIELDS OF TABLE lt_kdjnstr.

  LOOP AT gt_out.
    ADD 1 TO lv_baris.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-kd_jenis_transaksi
                                      lv_baris '1'.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-nomor_faktur
                                      lv_baris '2'.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-npwp
                                      lv_baris '3'.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_EFAKTUR
*&---------------------------------------------------------------------*
FORM f_validasi_efaktur  TABLES   ft_kdjnstr STRUCTURE zfe_kdjnstr
                         USING    fu_value fu_baris fu_flag.
  DATA : lv_length    TYPE i,
         lv_subrc     TYPE sy-subrc.

  CLEAR : lv_length, lv_subrc.

  gt_error-baris  = fu_baris.
  CASE fu_flag.
    WHEN '1'.
      READ TABLE ft_kdjnstr WITH KEY kdjnstr = fu_value.
      IF sy-subrc <> 0.
        lv_subrc  = fu_flag.
        gt_error-msg  = 'Kode Jenis Transaksi salah'.
      ENDIF.

    WHEN '2'.
      lv_length = STRLEN( fu_value ).
      IF lv_length <> 13.
        lv_subrc  = fu_flag.
      ELSE.
        IF fu_value CA '.-,'.
          lv_subrc  = fu_flag.
        ENDIF.
      ENDIF.

      CHECK lv_subrc IS NOT INITIAL.

      gt_error-msg  = 'Nomor Seri Faktur Pajak harus diisi 13 digit,'.
      CONCATENATE gt_error-msg 'tanpa tanda baca' INTO gt_error-msg
      SEPARATED BY space.

    WHEN '3'.
      lv_length = STRLEN( fu_value ).
      IF lv_length <> 15.
        lv_subrc  = fu_flag.
      ELSE.
        IF fu_value CA '.-,'.
          lv_subrc  = fu_flag.
        ENDIF.
      ENDIF.

      CHECK lv_subrc IS NOT INITIAL.

      gt_error-msg  = 'NPWP harus diisi 15 digit,'.
      CONCATENATE gt_error-msg 'tanpa tanda baca' INTO gt_error-msg
      SEPARATED BY space.
  ENDCASE.

  CHECK lv_subrc IS NOT INITIAL.

  APPEND gt_error.
ENDFORM.                    " F_VALIDASI_EFAKTUR

*&---------------------------------------------------------------------*
*&      Module  STATUS_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1400 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_1400 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  SORT gt_error BY baris msg.
  DELETE ADJACENT DUPLICATES FROM gt_error COMPARING baris msg.

  IF gt_error[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(90).
    WRITE: /  sy-vline NO-GAP, 'Baris' NO-GAP,
           13 sy-vline NO-GAP, 'Error message' NO-GAP,
           90 sy-vline.
    ULINE AT /(90).
    LOOP AT gt_error.
      WRITE: /  sy-vline NO-GAP, gt_error-baris NO-GAP,
             13 sy-vline NO-GAP, gt_error-msg(60) NO-GAP,
             90 sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(90).
  ENDIF.
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_COMPARE_HEAD_DETAIL
*&---------------------------------------------------------------------*
FORM f_compare_head_detail .
  DATA : lv_dpp     LIKE gt_of-dpp,
         lv_ppn     LIKE gt_of-ppn,
         lwa_of     LIKE gt_of.

  LOOP AT gt_out.
    CLEAR : lv_dpp, lwa_of.

    LOOP AT gt_of WHERE vkbur = gt_out-vkbur
                    AND vbeln = gt_out-vbeln.
      ADD gt_of-dpp TO lv_dpp.
      ADD gt_of-ppn TO lv_ppn.
      IF lwa_of IS INITIAL.
        IF gt_of-diskon <> 0.
          lwa_of  = gt_of.
          DELETE gt_of.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lv_dpp  = gt_out-jumlah_dpp - lv_dpp.
    lv_ppn  = gt_out-jumlah_ppn - lv_ppn.

    IF lwa_of IS INITIAL.
      lwa_of  = gt_of.
      DELETE TABLE gt_of FROM lwa_of.
    ENDIF.
    lwa_of-diskon = lwa_of-diskon - lv_dpp.
    lwa_of-diskon = ABS( lwa_of-diskon ).
    SHIFT lwa_of-diskon LEFT DELETING LEADING space.
    lwa_of-dpp    = lwa_of-dpp + lv_dpp.
    SHIFT lwa_of-dpp LEFT DELETING LEADING space.
    lwa_of-ppn    = lwa_of-ppn + lv_ppn.
    SHIFT lwa_of-ppn LEFT DELETING LEADING space.
    APPEND lwa_of TO gt_of.
    CLEAR lwa_of.
  ENDLOOP.
ENDFORM.                    " F_COMPARE_HEAD_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_SPECIAL_CHAR
*&---------------------------------------------------------------------*
FORM f_remove_special_char  USING    fu_value
                            CHANGING fc_value.
  DATA : specharsear(50) VALUE '"',
       lv_flag(1),
       itab TYPE TABLE OF string,
       wa   LIKE LINE OF itab.

  fc_value = fu_value.
  SPLIT fc_value AT space INTO TABLE itab.

  LOOP AT itab INTO wa.
    TRANSLATE wa USING specharsear.
    CONDENSE wa NO-GAPS.
    IF lv_flag IS INITIAL.
      lv_flag = 'X'.
      fc_value  = wa.
    ELSE.
      CONCATENATE fc_value wa INTO fc_value SEPARATED BY space.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_REMOVE_SPECIAL_CHAR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_VALUE
*&---------------------------------------------------------------------*
FORM f_add_value USING fu_ummenge fu_basme fu_hargasat
                       fu_hargattl fu_diskon fu_dpp fu_ppn.
  PERFORM f_modify_value USING fu_ummenge fu_basme
                         CHANGING gt_of-jumlah_barang.

  PERFORM f_modify_value USING fu_hargasat ''
                         CHANGING gt_of-harga_satuan.

  PERFORM f_modify_value USING fu_hargattl ''
                         CHANGING gt_of-harga_total.

  PERFORM f_modify_value USING fu_diskon ''
                         CHANGING gt_of-diskon.

  PERFORM f_modify_value USING fu_dpp ''
                         CHANGING gt_of-dpp.

  PERFORM f_modify_value USING fu_ppn ''
                         CHANGING gt_of-ppn.

  PERFORM f_modify_value USING '0' ''
                         CHANGING gt_of-tarif_ppnbm.

  PERFORM f_modify_value USING '0' ''
                         CHANGING gt_of-ppnbm.

ENDFORM.                    " F_ADD_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DATA : answer(1),
       button1   TYPE iconname VALUE 'ICON_DELETE',
       button2   TYPE iconname VALUE 'ICON_CANCEL'.

  IF gt_zfvato[] IS NOT INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = 'Delete Data'
        text_button_1         = 'Yes'
        icon_button_1         = button1
        text_button_2         = 'No'
        icon_button_2         = button2
        display_cancel_button = ''
      IMPORTING
        answer                = answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    IF answer = '1'.
      LOOP AT gt_zfvato INTO wa_zfvato.
        CLEAR wa_zfvato-files.
        MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING files.
      ENDLOOP.

      UPDATE zfvato FROM TABLE gt_zfvato.

      gv_subrc = sy-subrc.
    ELSE.
      gv_subrc = 4.
    ENDIF.
  ELSE.
    gv_subrc = 4.
  ENDIF.
ENDFORM.                    " F_DELETE_DATA
