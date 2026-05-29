*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  CLEAR: s_bwart,s_bwart[].
  APPEND LINES OF gr_in_bbm    TO s_bwart.
  APPEND LINES OF gr_in_retur  TO s_bwart.
  APPEND LINES OF gr_out_bbk   TO s_bwart.
  APPEND LINES OF gr_out_scrap TO s_bwart.
  APPEND LINES OF gr_other     TO s_bwart.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_s933 TYPE TABLE OF s933 WITH HEADER LINE,
        lt_mseg LIKE gt_mseg OCCURS 0 WITH HEADER LINE.

* Get Material Description
  SELECT a~matnr maktx meins INTO TABLE gt_makt
    FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE a~matnr = p_matnr
      AND a~spras = sy-langu.

* Get Opening Stock
  PERFORM f_get_opening_stock.
*  CALL METHOD zcl_mm_open_stock=>m_by_matnr
*    EXPORTING
*      i_matnr  = p_matnr
*      i_werks  = p_werks
*      i_lgort  = p_lgort
*      i_budat  = s_budat-low
*    IMPORTING
*      t_opnstk = gt_opnstk.

* Append gt_s933 from S644
  PERFORM f_append_s933.

* Get Transaction
  lt_s933[] = gt_s933[].
  DELETE lt_s933 WHERE budat NOT IN s_budat.
  IF lt_s933[] IS NOT INITIAL.
    SELECT a~mblnr a~mjahr zeile bwart xauto matnr werks lgort charg lifnr
           kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt shkzg
           budat xblnr frbnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg
      FROM mseg AS a JOIN mkpf AS b ON a~mblnr = b~mblnr AND
                                       a~mjahr = b~mjahr
      FOR ALL ENTRIES IN lt_s933
      WHERE a~mblnr EQ lt_s933-mblnr
        AND a~mjahr EQ lt_s933-spmon(4)
        AND matnr   EQ p_matnr
        AND werks   EQ p_werks
        AND lgort   EQ p_lgort
        AND bwart   IN s_bwart
        AND b~budat IN s_budat.
  ENDIF.

  IF gt_mseg[] IS NOT INITIAL.

*    PERFORM f_cek_reverse_document.

    SELECT DISTINCT ebeln gjahr belnr xblnr
      INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
      FROM ekbe FOR ALL ENTRIES IN gt_mseg
      WHERE ebeln = gt_mseg-ebeln.

    lt_mseg[] = gt_mseg[].
    SORT lt_mseg BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING kunnr.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FROM kna1 FOR ALL ENTRIES IN lt_mseg
        WHERE kunnr = lt_mseg-kunnr.
    ENDIF.

    CLEAR: lt_mseg,lt_mseg[].
    lt_mseg[] = gt_mseg[].
    SORT lt_mseg BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING lifnr.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT lifnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
        FROM lfa1 FOR ALL ENTRIES IN lt_mseg
        WHERE lifnr = lt_mseg-lifnr.
    ENDIF.

    CLEAR: lt_mseg,lt_mseg[].
    lt_mseg[] = gt_mseg[].
    SORT lt_mseg BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr charg.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_mch1
        FROM mch1 FOR ALL ENTRIES IN lt_mseg
        WHERE matnr = lt_mseg-matnr
          AND charg = lt_mseg-charg.
    ENDIF.

    CLEAR: lt_mseg,lt_mseg[].
    lt_mseg[] = gt_mseg[].
    DELETE lt_mseg WHERE ebeln NE space.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT DISTINCT vbelv vbeln
        INTO CORRESPONDING FIELDS OF TABLE gt_vbfa
        FROM vbfa FOR ALL ENTRIES IN lt_mseg
        WHERE vbeln = lt_mseg-xblnr(10).
    ENDIF.

    IF gt_vbfa[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_vbak
        FROM vbak FOR ALL ENTRIES IN gt_vbfa
        WHERE vbeln = gt_vbfa-vbelv.

      SELECT DISTINCT vbelv vbeln
        INTO CORRESPONDING FIELDS OF TABLE gt_vbfa2
        FROM vbfa FOR ALL ENTRIES IN gt_vbfa
        WHERE vbelv = gt_vbfa-vbeln
          AND vbtyp_n = 'M'.

      IF gt_vbfa2[] IS NOT INITIAL.
        SELECT vbeln xblnr
          INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
          FROM vbrk FOR ALL ENTRIES IN gt_vbfa2
          WHERE vbeln = gt_vbfa2-vbeln.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_detail.
*  PERFORM f_print_list.
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

  IF pa_grid IS NOT INITIAL.
    lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
    lv_title   = sy-title.
  ELSE.
    PERFORM f_build_event       TABLES  t_alv_event[].
    lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

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
    'BUDAT' 'MPKF' 'BUDAT' '' '' 'Date' '' '' '' '' '' '' '' '' '' '',
    'EBELN' 'MSEG' 'EBELN' '' '12' 'Cust/Supp PO' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '35' 'Cust/Supp Name' '' '' '' '' '' '' '' '' '' '',
    'XBLNR' 'MKPF' 'XBLNR' '' '20' 'Inv Supp/SJ to Cust' '' '' '' '' '' '' '' '' '' '',
    'IN_BBM' 'MSEG' 'MENGE' '' '' 'BBM' '' '' '' '' '' '' 'MEINS' '' '' '',
    'IN_RETUR' 'MSEG' 'MENGE' '' '' 'Retur' '' '' '' '' '' '' 'MEINS' '' '' '',
    'OUT_BBK' 'MSEG' 'MENGE' '' '' 'BBK' '' '' '' '' '' '' 'MEINS' '' '' '',
    'OUT_SCRAP' 'MSEG' 'MENGE' '' '' 'Pemusnahan' '' '' '' '' '' '' 'MEINS' '' '' '',
    'SALDO' 'MSEG' 'MENGE' '' '' 'S A L D O' '' '' '' '' '' '' 'MEINS' '' '' '',
    'BATCHPRIN' 'MCH1' 'LICHA' '' '' 'Batch Principal' '' '' '' '' '' '' '' '' '' '',
    'VFDAT' 'MCH1' 'VFDAT' '' '' 'Exp. Date' '' '' '' '' '' '' '' '' '' '',
    'LICHA' 'MCH1' 'LICHA' 'X' '' 'Batch#' '' '' '' '' '' '' '' '' '' '',
    'DELNOTE' 'EKBE' 'XBLNR' 'X' '' 'No. Faktur' '' '' '' '' '' '' '' '' '' '',
    'BOLNO' 'MKPF' 'FRBNR' 'X' '' 'BillOfLading' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'VBAK' 'VBELN' 'X' '' 'Sales Document' '' '' '' '' '' '' '' '' '' ''.
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
                          VALUE(fu_emphasize).

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

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'MATNR'.
*  ld_sort-up        = 'X'.
**  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'LGORT'.
*  ld_sort-up        = 'X'.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'LFGJA'.
*  ld_sort-up        = 'X'.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'LFMON'.
*  ld_sort-up        = 'X'.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: lv_header1 TYPE char100,
        lv_header2 TYPE char100,
        lv_header3 TYPE char100,
        lv_header4 TYPE char100,
        lv_opnstk  TYPE char15,
        lv_endstk  TYPE char15,
        lv_datlow  TYPE char10,
        lv_dathigh TYPE char10.

  WRITE: wa_opnstk-labst TO lv_opnstk UNIT wa_makt-meins.
  WRITE: gv_opnstk TO lv_endstk UNIT wa_makt-meins.
  WRITE: s_budat-low TO lv_datlow.
  WRITE: s_budat-high TO lv_dathigh.

  CONCATENATE 'Item Code                   :' wa_makt-matnr INTO lv_header1 SEPARATED BY space.
  CONCATENATE 'Description                 :' wa_makt-maktx INTO lv_header2 SEPARATED BY space.
  CONCATENATE 'Opening Stock on' lv_datlow ':' lv_opnstk INTO lv_header3 SEPARATED BY space.
  CONCATENATE 'Ending Stock on' lv_dathigh ' :' lv_endstk INTO lv_header4 SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_pad_title USING '' '' ''.
  PERFORM f_hdr_pad_title USING lv_header1 '' ''.
  PERFORM f_hdr_pad_title USING lv_header2 '' ''.
  PERFORM f_hdr_pad_title USING lv_header3 '' ''.
  PERFORM f_hdr_pad_title USING lv_header4 '' ''.
*  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_opnstk,gt_opnstk[],gt_detail,gt_detail[].
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
  SET PF-STATUS 'STANDARD'.
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
  SORT gt_mseg BY budat bwart.

  LOOP AT gt_mseg.
    CLEAR: gt_ekbe,gt_kna1,gt_lfa1,gt_mch1.
    READ TABLE gt_ekbe WITH KEY ebeln = gt_mseg-ebeln
                                belnr = gt_mseg-mblnr.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_mseg-kunnr.
    READ TABLE gt_lfa1 WITH KEY lifnr = gt_mseg-lifnr.
    READ TABLE gt_mch1 WITH KEY matnr = gt_mseg-matnr
                                charg = gt_mseg-charg.

    IF gt_mseg-bwart IN gr_in_bbm.
      IF gt_mseg-shkzg = 'H'.
        gt_mseg-menge = gt_mseg-menge * -1.
      ENDIF.
      gt_detail-in_bbm = gt_mseg-menge.
      gt_detail-bwart  = gt_mseg-bwart.
      gt_detail-zflag  = '1'.

    ELSEIF gt_mseg-bwart IN gr_in_retur.
      IF gt_mseg-shkzg = 'H'.
        gt_mseg-menge = gt_mseg-menge * -1.
      ENDIF.
      gt_detail-in_retur = gt_mseg-menge.
      gt_detail-bwart  = gt_mseg-bwart.
      gt_detail-zflag  = '1'.

    ELSEIF gt_mseg-bwart IN gr_out_bbk.
      IF gt_mseg-shkzg = 'S'.
        gt_mseg-menge = gt_mseg-menge * -1.
      ENDIF.
      gt_detail-out_bbk = gt_mseg-menge.
      gt_detail-bwart  = gt_mseg-bwart.
      gt_detail-zflag  = '2'.

    ELSEIF gt_mseg-bwart IN gr_out_scrap.
      IF gt_mseg-shkzg = 'S'.
        gt_mseg-menge = gt_mseg-menge * -1.
      ENDIF.
      gt_detail-out_scrap = gt_mseg-menge.
      gt_detail-bwart  = gt_mseg-bwart.
      gt_detail-zflag  = '2'.

    ELSE.
      CASE gt_mseg-shkzg.
        WHEN 'S'.
          gt_detail-in_bbm = gt_mseg-menge.
        WHEN 'H'.
          gt_detail-out_bbk = gt_mseg-menge.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    IF gt_mseg-ebeln IS INITIAL.
      READ TABLE gt_vbfa WITH KEY vbeln = gt_mseg-xblnr(10).
      IF sy-subrc = 0.
        READ TABLE gt_vbak WITH KEY vbeln = gt_vbfa-vbelv.
        IF sy-subrc = 0.
          gt_detail-ebeln = gt_vbak-bstnk.
          gt_detail-vbeln = gt_vbak-vbeln.
        ENDIF.
        READ TABLE gt_vbfa2 WITH KEY vbelv = gt_vbfa-vbeln.
        IF sy-subrc = 0.
          READ TABLE gt_vbrk WITH KEY vbeln = gt_vbfa2-vbeln.
          IF sy-subrc = 0.
            gt_detail-delnote = gt_vbrk-xblnr.
          ENDIF.
        ENDIF.
      ENDIF.
      gt_detail-name1 = gt_kna1-name1.
    ELSE.
      gt_detail-ebeln = gt_mseg-ebeln.
      gt_detail-name1 = gt_lfa1-name1.
*      gt_detail-delnote = gt_ekbe-xblnr.
    ENDIF.
    gt_detail-budat = gt_mseg-budat.
    gt_detail-xblnr = gt_mseg-xblnr.
    gt_detail-licha = gt_mseg-charg.
    gt_detail-vfdat = gt_mch1-vfdat.
    gt_detail-batchprin = gt_mch1-licha.
    gt_detail-bolno = gt_mseg-frbnr.
*    COLLECT gt_detail. CLEAR gt_detail.
    APPEND gt_detail. CLEAR gt_detail.
  ENDLOOP.

* Hitung Saldo
  CLEAR: wa_makt,wa_opnstk.
  READ TABLE gt_makt INTO wa_makt INDEX 1.
  READ TABLE gt_opnstk INTO wa_opnstk INDEX 1.
  gv_opnstk = wa_opnstk-labst.

*  SORT gt_detail BY batchprin ebeln xblnr bwart vbeln licha budat.
*  DELETE ADJACENT DUPLICATES FROM gt_detail COMPARING ebeln xblnr bwart batchprin vbeln licha.

  SORT gt_detail BY budat zflag licha.
  LOOP AT gt_detail.
    gv_opnstk = gv_opnstk + gt_detail-in_bbm + gt_detail-in_retur -
                gt_detail-out_bbk - gt_detail-out_scrap.
    gt_detail-saldo = gv_opnstk.
    gt_detail-meins = wa_makt-meins.
    MODIFY gt_detail TRANSPORTING saldo meins.
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
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

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
*&      Form  F_INIT_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_period .
  DATA: ld_datum  LIKE sy-datum,
        ld_datum2 LIKE sy-datum.

  CONCATENATE sy-datum(6) '01' INTO ld_datum.
  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      months  = '-1'
      olddate = ld_datum
    IMPORTING
      newdate = ld_datum.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_datum
    IMPORTING
      last_day_of_month = ld_datum2.

  s_budat-sign = 'I'.
  s_budat-option = 'BT'.
  s_budat-low = ld_datum.
  s_budat-high = ld_datum2.
  APPEND s_budat.
ENDFORM.                    " F_INIT_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BWART
*&---------------------------------------------------------------------*
FORM f_init_bwart .
  DATA: lt_ztntmmdt002 TYPE TABLE OF ztntmmdt002 WITH HEADER LINE.

  SELECT * INTO TABLE lt_ztntmmdt002
    FROM ztntmmdt002.

  CLEAR: gr_in_bbm,gr_in_retur,gr_out_bbk,gr_out_scrap,gr_other.

  LOOP AT lt_ztntmmdt002.
    CASE lt_ztntmmdt002-seqno.
      WHEN '01'.
        gr_in_bbm-sign = 'I'.
        gr_in_bbm-option = 'EQ'.
        gr_in_bbm-low = lt_ztntmmdt002-bwart.
        APPEND gr_in_bbm.
      WHEN '02'.
        gr_in_retur-sign = 'I'.
        gr_in_retur-option = 'EQ'.
        gr_in_retur-low = lt_ztntmmdt002-bwart.
        APPEND gr_in_retur.
      WHEN '03'.
        gr_out_bbk-sign = 'I'.
        gr_out_bbk-option = 'EQ'.
        gr_out_bbk-low = lt_ztntmmdt002-bwart.
        APPEND gr_out_bbk.
      WHEN '04'.
        gr_out_scrap-sign = 'I'.
        gr_out_scrap-option = 'EQ'.
        gr_out_scrap-low = lt_ztntmmdt002-bwart.
        APPEND gr_out_scrap.
      WHEN OTHERS.
        gr_other-sign = 'I'.
        gr_other-option = 'EQ'.
        gr_other-low = lt_ztntmmdt002-bwart.
        APPEND gr_other.
    ENDCASE.
  ENDLOOP.

  APPEND LINES OF gr_in_bbm    TO s_bwart.
  APPEND LINES OF gr_in_retur  TO s_bwart.
  APPEND LINES OF gr_out_bbk   TO s_bwart.
  APPEND LINES OF gr_out_scrap TO s_bwart.
  APPEND LINES OF gr_other     TO s_bwart.
ENDFORM.                    " F_INIT_BWART

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LIST
*&---------------------------------------------------------------------*
FORM f_print_list .
  DATA: lv_char1 TYPE char10,
        lv_char2 TYPE char10.

  IF gt_detail[] IS INITIAL.
    WRITE:  / '|',
              '*Null',
          214 '|'.
  ELSE.
    LOOP AT gt_detail.
      WRITE gt_detail-budat TO lv_char1.
      WRITE gt_detail-vfdat TO lv_char2.
      WRITE: / '|',
      lv_char1, '|',
      (12)gt_detail-ebeln CENTERED, '|',
      gt_detail-name1, '|',
      gt_detail-xblnr, '|',
      gt_detail-in_bbm UNIT wa_makt-meins, '|',
      gt_detail-in_retur UNIT wa_makt-meins, '|',
      gt_detail-out_bbk UNIT wa_makt-meins, '|',
      gt_detail-out_scrap UNIT wa_makt-meins, '|',
      gt_detail-saldo UNIT wa_makt-meins, '|',
      gt_detail-licha, '|',
      (12)lv_char2 CENTERED, '|'.
    ENDLOOP.
  ENDIF.

  PERFORM f_hdr_uline.
ENDFORM.                    " F_PRINT_LIST

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER
*&---------------------------------------------------------------------*
FORM f_sub_header .
  DATA: lv_char TYPE char40.

  WRITE: / '|',
  (10)' ' CENTERED, '|',
  (12)'PO Customer/', '|',
  (30)'Supplier/Customer' CENTERED, '|',
  (16)'Invoice Suppl./', '|',
  (37)'M A S U K' CENTERED, '|',
  (37)'K E L U A R' CENTERED, '|',
  (17)' ' CENTERED, '|',
  (30)'Catatan' CENTERED, '|'.


  WRITE: / '|',
  (10)'Date' CENTERED, '|',
  (12)'PO Supplier', '|',
  (30)'Name' CENTERED, '|',
  (16)'SJ Customer' CENTERED, '|' NO-GAP,
  (39)sy-uline NO-GAP, '|' NO-GAP,
  (39)sy-uline NO-GAP, '|',
  (17)'S A L D O' CENTERED, '|' NO-GAP,
  (32)sy-uline NO-GAP, '|'.

  WRITE: / '|',
  (10)' ', '|',
  (12)' ', '|',
  (30)' ', '|',
  (16)' ', '|',
  (17)'BBM' CENTERED, '|',
  (17)'Retur' CENTERED, '|',
  (17)'BBK' CENTERED, '|',
  (17)'Pemusnahan' CENTERED, '|',
  (17)' ', '|',
  (15)'Batch#' CENTERED, '|',
  (12)'Expired Date', '|'.
ENDFORM.                    " F_SUB_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CEK_REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_cek_reverse_document .
  DATA: lt_mseg     LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lt_mseg_rev LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lv_bwart    TYPE bwart.

  lt_mseg[] = lt_mseg_rev[] = gt_mseg[].
  DELETE lt_mseg WHERE smbln IS NOT INITIAL.
  DELETE lt_mseg_rev WHERE smbln IS INITIAL.

* Hapus dokumen reverse
  IF lt_mseg_rev[] IS NOT INITIAL.
    SORT lt_mseg BY mblnr mjahr zeile.
    SORT lt_mseg_rev BY smbln sjahr smblp.
    LOOP AT lt_mseg_rev.
      lv_bwart = lt_mseg_rev-bwart - 1.
      READ TABLE lt_mseg WITH KEY mblnr = lt_mseg_rev-smbln
                                  mjahr = lt_mseg_rev-sjahr
                                  zeile = lt_mseg_rev-smblp
                                  bwart = lv_bwart TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE lt_mseg INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

* Pindahkan itab tanpa dokumen reverse ke itab asli
    CLEAR: gt_mseg,gt_mseg[].
    gt_mseg[] = lt_mseg[].
  ENDIF.
ENDFORM.                    " F_CEK_REVERSE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPENING_STOCK
*&---------------------------------------------------------------------*
FORM f_get_opening_stock .
  DATA: lt_s933 TYPE TABLE OF s933 WITH HEADER LINE,
        lt_mard TYPE TABLE OF mard WITH HEADER LINE,
        lt_mseg LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lv_date TYPE datum.

  CONCATENATE s_budat-low(6) '01' INTO lv_date.

  SELECT * INTO TABLE lt_mard
    FROM mard WHERE matnr EQ p_matnr
                AND werks EQ p_werks
                AND lgort EQ p_lgort.

  SELECT * INTO TABLE gt_s933
    FROM s933 WHERE budat GE s_budat-low   "spmon GE s_budat-low(6)
                AND werks EQ p_werks
                AND matnr EQ p_matnr
                AND lgort EQ p_lgort
                AND vrsio EQ '000'
    ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.
    lt_s933[] = gt_s933[].
*****    DELETE lt_s933 WHERE budat NOT IN s_budat.
    SORT lt_s933 BY mblnr spmon.
    DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.

    IF lt_s933[] IS NOT INITIAL.
      SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
             kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt shkzg
        INTO CORRESPONDING FIELDS OF TABLE lt_mseg
        FROM mseg FOR ALL ENTRIES IN lt_s933
        WHERE mblnr  EQ lt_s933-mblnr
          AND mjahr  EQ lt_s933-spmon(4)
          AND matnr  EQ p_matnr
          AND werks  EQ p_werks
          AND lgort  EQ p_lgort
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  "Get MvType 601
  SELECT a~mblnr a~mjahr zeile bwart xauto matnr werks lgort charg lifnr
         kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt shkzg
    APPENDING CORRESPONDING FIELDS OF TABLE lt_mseg
    FROM mseg AS a JOIN mkpf AS b ON a~mblnr = b~mblnr AND
                                     a~mjahr = b~mjahr
    WHERE werks  EQ p_werks
      AND bwart  IN ('601','602')
      AND xauto  EQ space
      AND sgtxt  EQ space
      AND matnr  EQ p_matnr
*        AND budat  GE lv_date. "Update based on req bu NIA- report on date
      AND budat GE s_budat-low
*      AND budat IN s_budat
    ORDER BY a~mblnr a~mjahr zeile.

  SORT lt_mard BY matnr werks lgort.
  SORT lt_mseg BY matnr werks lgort shkzg.

  LOOP AT lt_mard.
    wa_opnstk-matnr = lt_mard-matnr.
    wa_opnstk-werks = lt_mard-werks.
    wa_opnstk-lgort = lt_mard-lgort.
    wa_opnstk-labst = lt_mard-labst + lt_mard-insme + lt_mard-speme
                    + lt_mard-einme + lt_mard-retme.
    LOOP AT lt_mseg WHERE matnr = lt_mard-matnr
                      AND werks = lt_mard-werks
                      AND lgort = lt_mard-lgort.
      CASE lt_mseg-shkzg.
        WHEN 'H'.
          lt_mseg-menge = lt_mseg-menge.
        WHEN 'S'.
          lt_mseg-menge = lt_mseg-menge * -1.
      ENDCASE.
      wa_opnstk-labst = wa_opnstk-labst + lt_mseg-menge.
    ENDLOOP.
    COLLECT wa_opnstk INTO gt_opnstk.
    CLEAR wa_opnstk.
  ENDLOOP.
  DELETE gt_opnstk WHERE labst IS INITIAL.
ENDFORM.                    " F_GET_OPENING_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_S933
*&---------------------------------------------------------------------*
FORM f_append_s933 .
  DATA: lt_s644    TYPE TABLE OF s644  WITH HEADER LINE,
        lt_vbfa    TYPE TABLE OF vbfa  WITH HEADER LINE,
        lt_tvkbz   TYPE TABLE OF tvkbz WITH HEADER LINE,
        lr_spmon   TYPE RANGE OF spmon WITH HEADER LINE,
        lr_vkbur   TYPE RANGE OF vkbur WITH HEADER LINE,
        lt_docflow TYPE tdt_docflow,
        lw_docflow TYPE LINE OF tdt_docflow,
        lv_vkorg   TYPE vkorg.

  DATA: lr_bwart TYPE RANGE OF bwart,
        ls_bwart LIKE LINE OF lr_bwart.

  ls_bwart-low    = '601'.
  ls_bwart-high   = '602'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'BT'.
  APPEND ls_bwart TO lr_bwart.
  CLEAR ls_bwart.

  LOOP AT s_budat.
    CLEAR lr_spmon.
    lr_spmon-sign = s_budat-sign.
    lr_spmon-option = s_budat-option.
    lr_spmon-low = s_budat-low(6).
    lr_spmon-high = s_budat-high(6).
    APPEND lr_spmon.
  ENDLOOP.

  CONCATENATE '8' p_werks INTO lv_vkorg.

  SELECT * INTO TABLE lt_tvkbz
    FROM tvkbz WHERE vkorg = lv_vkorg.

  IF sy-subrc = 0.
    LOOP AT lt_tvkbz.
      CLEAR lr_vkbur.
      lr_vkbur-sign = 'I'.
      lr_vkbur-option = 'EQ'.
      lr_vkbur-low = lt_tvkbz-vkbur.
      APPEND lr_vkbur.
    ENDLOOP.
  ELSE.
    CLEAR lr_vkbur.
    lr_vkbur-sign = 'I'.
    lr_vkbur-option = 'BT'.
    CONCATENATE lv_vkorg+1(2) '00' INTO lr_vkbur-low.
    CONCATENATE lv_vkorg+1(2) '99' INTO lr_vkbur-high.
    APPEND lr_vkbur.
  ENDIF.

  SELECT * INTO TABLE lt_s644
    FROM s644 WHERE ssour = space
                AND vrsio = '000'
                AND spmon IN lr_spmon
                AND sptag = '00000000'
                AND spwoc = '000000'
                AND spbup = '000000'
                AND vkorg = lv_vkorg
                AND vkbur IN lr_vkbur
                AND matnr = p_matnr.

  IF sy-subrc = 0.
    SELECT * INTO TABLE lt_vbfa
      FROM vbfa FOR ALL ENTRIES IN lt_s644
      WHERE vbeln = lt_s644-vbeln
        AND vbtyp_v = 'J'.

    LOOP AT lt_vbfa.
      CLEAR: lt_s644,lt_docflow.
      READ TABLE lt_s644 WITH KEY vbeln = lt_vbfa-vbeln.

      CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
        EXPORTING
          iv_docnum  = lt_vbfa-vbelv
        IMPORTING
          et_docflow = lt_docflow.

      IF sy-subrc = 0.
        LOOP AT lt_docflow INTO lw_docflow
          WHERE ( vbtyp_n EQ 'R' OR vbtyp_n EQ 'h' )
            AND bwart IN lr_bwart.      " EQ '601'.
          CLEAR gt_s933.
          gt_s933-spmon = lt_s644-spmon.
          gt_s933-werks = lt_s644-vkbur.
          gt_s933-matnr = lt_s644-matnr.
          gt_s933-bwart = lw_docflow-bwart.
          gt_s933-mblnr = lw_docflow-docnum.
          gt_s933-budat = s_budat-low.    "lw_docflow-erdat.
          APPEND gt_s933.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_APPEND_S933
