*----------------------------------------------------------------------*
*   INCLUDE ZM_VENDOR_EVALUATIONF01                                    *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  PERFORM f_get_eindt USING '-60'         "Assign to so_eindt
                            p_assdt.

  SELECT zterm gbtop
    FROM zt052
    INTO CORRESPONDING FIELDS OF TABLE t_zt052.

  LOOP AT t_zvend_eval.
    CASE t_zvend_eval-zline.
      WHEN 11.
        pa_deliv  = t_zvend_eval-bobot.
      WHEN 12.
        pa_intl1  = t_zvend_eval-inter_low.
        pa_intn1  = t_zvend_eval-nilai.
      WHEN 13.
        IF pa_inter GT 2.
          pa_intl2  = t_zvend_eval-inter_low.
          pa_inth2  = t_zvend_eval-inter_high.
          pa_intn2  = t_zvend_eval-nilai.
        ELSEIF pa_inter EQ 2.
          pa_intl2  = t_zvend_eval-inter_low.
          pa_intn2  = t_zvend_eval-nilai.
        ELSE.
          CLEAR: pa_intl2, pa_inth2, pa_intn2.
        ENDIF.
      WHEN 14.
        IF pa_inter GT 3.
          pa_intl3  = t_zvend_eval-inter_low.
          pa_inth3  = t_zvend_eval-inter_high.
          pa_intn3  = t_zvend_eval-nilai.
        ELSEIF pa_inter EQ 3.
          pa_intl3  = t_zvend_eval-inter_low.
          pa_intn3  = t_zvend_eval-nilai.
        ELSE.
          CLEAR: pa_intl3, pa_inth3, pa_intn3.
        ENDIF.
      WHEN 15.
        IF pa_inter GT 4.
          pa_intl4  = t_zvend_eval-inter_low.
          pa_inth4  = t_zvend_eval-inter_high.
          pa_intn4  = t_zvend_eval-nilai.
        ELSEIF pa_inter EQ 4.
          pa_intl4  = t_zvend_eval-inter_low.
          pa_intn4  = t_zvend_eval-nilai.
        ELSE.
          CLEAR: pa_intl4, pa_inth4, pa_intn4.
        ENDIF.
      WHEN 16.
        IF pa_inter EQ 5.
          pa_intl5  = t_zvend_eval-inter_low.
          pa_intn5  = t_zvend_eval-nilai.
        ELSE.
          CLEAR: pa_intl5, pa_intn5.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_ekko TYPE TABLE OF ekko WITH HEADER LINE,
        lt_ekpo TYPE TABLE OF ekpo WITH HEADER LINE.


  FIELD-SYMBOLS: <fs_eindt3y> LIKE gr_eindt3y,
                 <fs_eindt6m> LIKE gr_eindt6m,
                 <fs_eindt3m> LIKE gr_eindt3m,
                 <fs_eindt2m> LIKE gr_eindt2m,
                 <fs_eindt1m> LIKE gr_eindt1m.

* Get 3 years backward
  gr_eindt3y[] = so_eindt[].
*  READ TABLE gr_eindt3y ASSIGNING <fs_eindt3y> INDEX 1.
*  <fs_eindt3y>-low(4) = <fs_eindt3y>-high(4) - 3.

* Get 6 month
  gr_eindt6m[] = so_eindt[].
  READ TABLE gr_eindt6m ASSIGNING <fs_eindt6m> INDEX 1.
  PERFORM f_calculate_date USING '-6' <fs_eindt6m>-high
                           CHANGING <fs_eindt6m>-low.

* Get 3 month
  gr_eindt3m[] = so_eindt[].
  READ TABLE gr_eindt3m ASSIGNING <fs_eindt3m> INDEX 1.
  PERFORM f_calculate_date USING '-3' <fs_eindt3m>-high
                           CHANGING <fs_eindt3m>-low.

* Get 2 month
  gr_eindt2m[] = so_eindt[].
  READ TABLE gr_eindt2m ASSIGNING <fs_eindt2m> INDEX 1.
  PERFORM f_calculate_date USING '-2' <fs_eindt2m>-high
                           CHANGING <fs_eindt2m>-low.

* Get 1 month
  gr_eindt1m[] = so_eindt[].
  READ TABLE gr_eindt1m ASSIGNING <fs_eindt1m> INDEX 1.
  PERFORM f_calculate_date USING '-1' <fs_eindt1m>-high
                           CHANGING <fs_eindt1m>-low.
  ADD 1 TO <fs_eindt1m>-low.

  PERFORM f_append_mpn_material.

  SELECT a~infnr a~matnr a~matkl a~lifnr b~ekorg b~esokz b~werks b~inco1
    INTO CORRESPONDING FIELDS OF TABLE gt_eina
    FROM eina AS a JOIN eine AS b ON a~infnr = b~infnr
    WHERE a~matnr IN gr_matmpn    "so_matnr
      AND a~lifnr IN so_lifnr
      AND a~loekz EQ space
      AND b~ekorg EQ 'TNT'
      AND b~esokz EQ '0'
      AND b~loekz EQ space.
  IF sy-subrc = 0.
    SELECT DISTINCT infnr ebeln
      INTO CORRESPONDING FIELDS OF TABLE gt_eipa
      FROM eipa FOR ALL ENTRIES IN gt_eina
      WHERE infnr EQ gt_eina-infnr
        AND ebeln IN so_ponum
        AND esokz EQ '0'
        AND werks IN so_werks
        AND ekorg EQ 'TNT'
        AND bedat IN so_eindt.
  ENDIF.

  IF gt_eipa[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I'.
    STOP.
  ENDIF.

* PO History
  SELECT ebeln lifnr bedat waers knumv ekorg bsart
    INTO CORRESPONDING FIELDS OF TABLE lt_ekko
    FROM ekko FOR ALL ENTRIES IN gt_eipa
    WHERE ebeln EQ gt_eipa-ebeln
      AND bukrs IN so_bukrs
      AND lifnr IN so_lifnr
      AND ekgrp IN so_ekgrp
      AND ebeln IN so_ponum.
  IF sy-subrc = 0.
    SELECT ebeln ebelp matnr meins menge netwr
      INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
      FROM ekpo FOR ALL ENTRIES IN gt_eipa
      WHERE ebeln EQ gt_eipa-ebeln
        AND matnr IN so_matnr
        AND werks IN so_werks
        AND loekz IN so_loekz.

    LOOP AT lt_ekko.
      LOOP AT lt_ekpo WHERE ebeln = lt_ekko-ebeln.
        CLEAR t_history.
        t_history-ebeln = lt_ekko-ebeln.
        t_history-lifnr = lt_ekko-lifnr.
        t_history-bedat = lt_ekko-bedat.
        t_history-waers = lt_ekko-waers.
        t_history-knumv = lt_ekko-knumv.
        t_history-ekorg = lt_ekko-ekorg.
        t_history-bsart = lt_ekko-bsart.
        t_history-ebelp = lt_ekpo-ebelp.
        t_history-matnr = lt_ekpo-matnr.
        t_history-meins = lt_ekpo-meins.
        t_history-menge = lt_ekpo-menge.
        t_history-netwr = lt_ekpo-netwr.
        APPEND t_history.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  IF t_history[] IS NOT INITIAL.
    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bwart budat
           shkzg menge matnr bldat lfgja lfbnr lfpos
      FROM ekbe
      INTO CORRESPONDING FIELDS OF TABLE t_ekbeh
      FOR ALL ENTRIES IN t_history
      WHERE ebeln EQ t_history-ebeln AND
            ebelp EQ t_history-ebelp AND
            zekkn EQ 0               AND
            vgabe EQ 1               AND
            bwart IN ('101', '102', '122', '123').

    SELECT ebeln ebelp etenr banfn bnfpo eindt menge wemng
      INTO CORRESPONDING FIELDS OF TABLE t_eketh
      FROM eket FOR ALL ENTRIES IN t_history
      WHERE ebeln EQ t_history-ebeln AND
            ebelp EQ t_history-ebelp.
  ENDIF.

  PERFORM f_cek_cancel_102.
  PERFORM f_get_gi_doc.
  PERFORM f_get_revese_doc.
  PERFORM f_filter_po_history.
  PERFORM f_select_budget.
  PERFORM f_select_harga.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_out.
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

  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'EKPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'ADRC' 'NAME1' '' '' '' '' '' '' '' '' '' '' '',
*    'BUDGET' 'ZSTVEND_EVAL' 'BUDGET' '' '' '' '' '' '' '' '' '' '' '',
    'HARGA' 'ZSTVEND_EVAL' 'HARGA' '' '' 'Harga' '' '' '' '' '' '' '' '',
    'BUDGET' 'ZSTVEND_EVAL' 'BUDGET' '' '' 'Budget' '' '' '' '' '' '' '' '',
    'SYSDAT' 'ZSTVEND_EVAL' 'SYSDAT' '' '' 'Running Date' '' '' '' '' '' '' '' '',
    'SCORH' 'ZSTVEND_EVAL' 'SCORH' '' '' 'Score Harga' '' '' '' '' '' '' '' '',
    'HRGAB' 'ZSTVEND_EVAL' 'HRGAB' '' '' 'Bobot Harga' '' '' '' '' '' '' '' '',
    'RJQTY' 'ZSTVEND_EVAL' 'RJQTY' 'X' '' 'Reject Qty' '' '' '' '' '' '' '' '',
    'POQTY' 'ZSTVEND_EVAL' 'POQTY' 'X' '' 'PO Qty' '' '' '' '' '' '' '' '',
    'SCORQUAL' 'ZSTVEND_EVAL' 'SCORQUAL' '' '' 'Score Quality' '' 'X' '' '' '' '' '' '',
    'BQUAL' 'ZSTVEND_EVAL' 'BQUAL' '' '' 'Bobot Quality' '' '' '' '' '' '' '' '',
    'SCORD' 'ZSTVEND_EVAL' 'SCORD' '' '' 'Score Delivery' '' 'X' '' '' '' '' '' '',
    'BDELV' 'ZSTVEND_EVAL' 'BDELV' '' '' 'Bobot Delivery' '' '' '' '' '' '' '' '',
    'SCORQTY' 'ZSTVEND_EVAL' 'SCORQTY' '' '' 'Score Quantity' '' 'X' '' '' '' '' '' '',
    'BOBOTQTY' 'ZSTVEND_EVAL' 'BOBOTQTY' '' '' 'Bobot Quantity' '' '' '' '' '' '' '' '',
    'ZTERM' 'ZSTVEND_EVAL' 'ZTERM' '' '' 'TOP' '' '' '' '' '' '' '' '',
    'BOBOTTOP' 'ZSTVEND_EVAL' 'BOBOTTOP' '' '' 'Bobot TOP' '' '' '' '' '' '' '' '',
    'BOBOTTOTAL' 'ZSTVEND_EVAL' 'BOBOTTOTAL' '' '' 'Total Bobot' '' '' '' '' '' '' '' ''.
*    'QTYREAL' 'ZSTVEND_EVAL' 'QTYREAL' '' '' 'Qty Realisasi' '' '' '' '' '' '' '' '',
*    'BQTYREAL' 'ZSTVEND_EVAL' 'BQTYREAL' '' '' '' '' '' '' '' '' '' '' '',
*    'VALIDR' 'ZSTVEND_EVAL' 'VALIDR' '' '' 'Amout Realisasi' '' '' '' '' '' '' '' '',
*    'BAMTR' 'ZSTVEND_EVAL' 'BAMTR' '' '' '' '' '' '' '' '' '' '' ''.
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

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
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
  REFRESH: t_vdata.
  CLEAR: t_vdata.
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
  DATA: ld_currdec  LIKE tcurx-currdec,
        ld_flag     TYPE i,
        ld_adapo    TYPE i.

  DATA: BEGIN OF lt_matnr OCCURS 0,
        matnr  LIKE ekpo-matnr.
  DATA: END OF lt_matnr.
  DATA: BEGIN OF lt_lifnr OCCURS 0,
        lifnr  LIKE ekko-lifnr.
  DATA: END OF lt_lifnr.
  DATA: BEGIN OF lt_bqtyreal OCCURS 0,
          matnr    LIKE ekpo-matnr,
          qtyreal  LIKE eket-menge.
  DATA: END OF lt_bqtyreal.
  DATA: BEGIN OF lt_bobotreal OCCURS 0,
          matnr    LIKE ekpo-matnr,
          validr   LIKE zstvend_eval-validr.
  DATA: END OF lt_bobotreal.

  DATA: lv_matnr LIKE t_out-matnr,
        lv_lifnr LIKE t_out-lifnr.

  SORT t_history BY matnr lifnr DESCENDING.
  LOOP AT t_history.
    t_vdata-matnr       = lt_matnr-matnr  = t_history-matnr.
    t_vdata-lifnr       = lt_lifnr-lifnr  = t_history-lifnr.
    t_vdata-waers        = 'IDR'.
*    t_vdata-waers       = t_history-waers.
    t_vdata-poqty_hist  = t_history-menge.
    t_vdata-ekorg       = t_history-ekorg.

* Reject quantity,
    LOOP AT t_ekbeh WHERE ebeln EQ t_history-ebeln AND
                          ebelp EQ t_history-ebelp.
      t_ekbedata-matnr  = t_history-matnr.
      t_ekbedata-lifnr  = t_history-lifnr.
      t_ekbedata-ebeln  = t_ekbeh-ebeln.
      t_ekbedata-ebelp  = t_ekbeh-ebelp.
      t_ekbedata-menge  = t_ekbeh-menge.
      t_ekbedata-count  = 1.
      IF t_ekbeh-shkzg EQ 'H'.
        t_ekbedata-cancel  = 1.
        t_ekbedata-rjqty   = t_ekbeh-menge.
        ADD t_ekbeh-menge TO t_vdata-rjqty.
      ENDIF.
      COLLECT t_ekbedata.       "for SCORQUAL (Score Quality)
      CLEAR: t_ekbedata.

      IF t_ekbeh-bldat GT t_eketdata3-budat.
        t_eketdata3-budat = t_ekbeh-budat.
      ENDIF.
    ENDLOOP.

    COLLECT t_vdata.
    COLLECT lt_matnr.
    COLLECT lt_lifnr.
    CLEAR: t_vdata.
  ENDLOOP.

* ZM70
  PERFORM f_get_from_zm70.

  IF lt_matnr[] IS NOT INITIAL.
    SELECT matnr maktx
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE t_makt
      FOR ALL ENTRIES IN lt_matnr
      WHERE matnr EQ lt_matnr-matnr AND
            spras EQ sy-langu.
  ENDIF.

  IF lt_lifnr[] IS NOT INITIAL.
    SELECT a~lifnr b~name1
      FROM lfa1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
      INTO CORRESPONDING FIELDS OF TABLE t_adrc
      FOR ALL ENTRIES IN lt_lifnr
      WHERE a~lifnr EQ lt_lifnr-lifnr.

    SELECT lifnr zterm ekorg
      FROM lfm1
      INTO CORRESPONDING FIELDS OF TABLE t_zterm
      FOR ALL ENTRIES IN lt_lifnr
      WHERE lifnr EQ lt_lifnr-lifnr.
  ENDIF.

  SORT t_vdata BY matnr lifnr.
  LOOP AT t_vdata.
    t_out-matnr    = lt_bqtyreal-matnr  = lt_bobotreal-matnr  = t_vdata-matnr.
    t_out-lifnr    = t_vdata-lifnr.
    READ TABLE t_makt WITH KEY matnr = t_vdata-matnr.
    IF sy-subrc EQ 0.
      t_out-maktx    = t_makt-maktx.
    ELSE.
      CLEAR: t_out-maktx.
    ENDIF.
    READ TABLE t_adrc WITH KEY lifnr = t_vdata-lifnr.
    IF sy-subrc EQ 0.
      t_out-name1    = t_adrc-name1.
    ELSE.
      CLEAR: t_out-name1.
    ENDIF.
    t_out-waers         = t_vdata-waers.
    t_out-budget        = t_vdata-budget.
    t_out-validr        = t_vdata-validr.
    t_out-rjqty         = t_vdata-rjqty.
    t_out-poqty_hist    = t_vdata-poqty_hist.
    t_out-poqty_real    = t_vdata-poqty_real.
* Harga
    IF t_vdata-poqty_real IS NOT INITIAL.
      t_out-harga    = ( t_vdata-validr / t_vdata-poqty_real ).
    ELSE.
      CLEAR: t_out-harga.
    ENDIF.

    READ TABLE t_zterm WITH KEY lifnr = t_vdata-lifnr
                                ekorg = t_vdata-ekorg.
    IF sy-subrc EQ 0.
      t_out-zterm    = t_zterm-zterm.
    ELSE.
      CLEAR: t_out-zterm.
    ENDIF.

    t_out-qtyreal  = t_vdata-qtyreal.
    lt_bqtyreal-qtyreal  = t_vdata-qtyreal.
    lt_bobotreal-validr  = t_vdata-validr.
    APPEND t_out.
    COLLECT lt_bqtyreal.
    COLLECT lt_bobotreal.
  ENDLOOP.

* Score quality, Bobot quality, Score harga, Harga bobot
  SORT t_ekbedata BY matnr lifnr ebeln ebelp.
  SORT t_eketdata2 BY matnr lifnr eindt.
  SORT t_eketdata3 BY matnr lifnr eindt DESCENDING.
  SORT t_out BY matnr lifnr.

  LOOP AT t_out.
    CLEAR: t_eketdata3,t_history.
    READ TABLE t_eketdata3 WITH KEY matnr = t_out-matnr
                                    lifnr = t_out-lifnr.
    READ TABLE t_history WITH KEY ebeln = t_eketdata3-ebeln.
    PERFORM f_get_budget_price  USING    'X'
                                         t_out-matnr
                                         t_history-bedat  "t_eketdata3-eindt
                                CHANGING t_out-waers
                                         t_out-budget
                                         t_out-inco1.

    CLEAR: gt_mara,lv_matnr,lv_lifnr.
    READ TABLE gt_mara WITH KEY matnr = t_out-matnr.
    IF gt_mara-mprof = 'Z001'.                        "MPN material
*      PERFORM f_get_material_eina USING t_out-matnr
*                                        t_out-lifnr
*                                  CHANGING lv_matnr
*                                           lv_lifnr.
      PERFORM f_get_harga_mpn USING    t_out-matnr
                                       t_out-lifnr
                              CHANGING t_out-harga
                                       t_out-waers.
    ELSE.
      CLEAR gt_eina.
      READ TABLE gt_eina WITH KEY matnr = t_out-matnr
                                  lifnr = t_out-lifnr.
      PERFORM f_get_harga USING    t_out-matnr
                                   t_out-lifnr
                                   t_out-inco1
                                   gt_eina-inco1
                          CHANGING t_out-harga
                                   t_out-waers.
    ENDIF.

    IF t_out-harga IS NOT INITIAL.
      t_out-scorh     = ( t_out-budget / t_out-harga ) * pa_hrgn.
    ELSE.
      CLEAR: t_out-scorh.
    ENDIF.

    IF t_out-scorh > 80.
      t_out-scorh = 80.
    ENDIF.

    t_out-hrgab     = t_out-scorh * pa_hrgb.

    IF t_out-poqty_hist IS NOT INITIAL.
      t_out-scorqual  = 100 - ( ( t_out-rjqty / t_out-poqty_hist ) * 100 ).
      ld_adapo  = 1.
    ELSE.
      CLEAR: t_out-scorqual.
    ENDIF.

    "Recalculate Score Quality
    PERFORM f_recalc_scorqual.

    IF t_out-scorqual LT 1.
      t_out-bqual  = 0.
    ELSE.
      IF t_out-scorqual EQ pa_quala.
        IF t_out-scorqual IS INITIAL.
          IF ld_adapo IS NOT INITIAL.
            t_out-bqual  = t_out-scorqual * pa_qualb.
          ELSE.
            CLEAR: t_out-bqual.
          ENDIF.
        ELSE.
          t_out-bqual  = 100 * pa_qualb.
        ENDIF.
      ELSE.
        t_out-bqual  =  t_out-scorqual  * pa_qualb.
      ENDIF.
    ENDIF.

    READ TABLE t_zt052 WITH KEY zterm = t_out-zterm.
    IF sy-subrc EQ 0.
      CASE t_zt052-gbtop.
        WHEN 5.
          t_out-bobottop  = pa_term * pa_top1.
        WHEN 6.
          t_out-bobottop  = pa_term * pa_top2.
        WHEN 7.
          t_out-bobottop  = pa_term * pa_top3.
        WHEN 8.
          t_out-bobottop  = pa_term * pa_top4.
        WHEN 9.
          t_out-bobottop  = pa_term * pa_top5.
      ENDCASE.
    ENDIF.

* Score quantity, Bobot quantity
    READ TABLE t_scord WITH KEY matnr  = t_out-matnr
                                lifnr  = t_out-lifnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF t_out-scorqual IS INITIAL.
        IF ld_adapo IS NOT INITIAL.
          t_out-scord    = t_scord-scord.
          t_out-bdelv    = t_scord-bdelv.
          CLEAR: ld_adapo.
        ELSE.
          CLEAR: t_out-scord, t_out-bdelv.
        ENDIF.
      ELSE.
        t_out-scord    = t_scord-scord.
        t_out-bdelv    = t_scord-bdelv.
      ENDIF.

      IF t_out-poqty_hist IS NOT INITIAL.
        t_out-scorqty  = ( t_scord-menge / t_out-poqty_hist ) * 100.
      ELSE.
        CLEAR: t_out-scorqty.
      ENDIF.

      "Recalculate Score Quantity
      PERFORM f_recalc_scorqty.

      IF t_out-scorqty EQ pa_quana.
        t_out-bobotqty  = 100 * pa_quanb.
      ELSE.
        IF t_out-scorqty GE pa_quana.
*          t_out-bobotqty  = 10.
          t_out-bobotqty  = 100 * pa_quanb.
        ELSE.
          t_out-bobotqty  = t_out-scorqty * pa_quanb.
        ENDIF.
      ENDIF.

      IF t_out-scorqty GE pa_quana.
        t_out-scorqty  = pa_quann.
      ENDIF.
    ELSE.
      CLEAR: t_out-scord, t_out-bdelv, t_out-scorqty, t_out-bobotqty.
    ENDIF.

* Bobot quantity realisasi
    READ TABLE lt_bqtyreal WITH KEY matnr = t_out-matnr.
    IF sy-subrc EQ 0.
      t_out-bqtyreal  = ( t_out-qtyreal / lt_bqtyreal-qtyreal ) * 100.
    ELSE.
      CLEAR: t_out-bqtyreal.
    ENDIF.

* Bobot amount realisasi
    READ TABLE lt_bobotreal WITH KEY matnr = t_out-matnr.
    IF sy-subrc EQ 0.
      t_out-bamtr  = ( t_out-validr / lt_bobotreal-validr ) * 100.
    ELSE.
      CLEAR: t_out-bamtr.
    ENDIF.

    "Recalculate Score Delivery
    PERFORM f_recalc_scord.

    t_out-bdelv  = t_out-scord * pa_deliv.
    t_out-sysdat = sy-datum.
    t_out-bobottotal = t_out-hrgab + t_out-bqual + t_out-bdelv + t_out-bobotqty +
                       t_out-bobottop + t_out-bqtyreal + t_out-bamtr.

    MODIFY t_out TRANSPORTING scorqual bqual scorh hrgab scord bdelv scorqty
                              bobotqty bobottop bqtyreal bamtr sysdat harga
                              waers bobottotal budget.
  ENDLOOP.

  "Insert rows to t_out
  PERFORM f_insert_from_eina.
ENDFORM.                    " f_process_data

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
    WHEN '&IC1'.
      CASE fu_selfield-fieldname.
        WHEN 'SCORQUAL' OR 'SCORD' OR 'SCORQTY'.
          gv_index = fu_selfield-tabindex.
          gv_fieldname = fu_selfield-fieldname.
          CALL SCREEN 100 STARTING AT 10 10 ENDING AT 80 20.
        WHEN OTHERS.
      ENDCASE. .
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    IF screen-group1 = 'OUT'.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  CASE pa_inter.
    WHEN 1.
      LOOP AT SCREEN.
        IF screen-group1 = 'IL2' OR
          screen-group1 = 'IH2' OR
          screen-group1 = 'IL3' OR
          screen-group1 = 'IH3' OR
          screen-group1 = 'IL4' OR
          screen-group1 = 'IH4' OR
          screen-group1 = 'IL5'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
          screen-group1 = 'GE2' OR
          screen-group1 = 'GE3' OR
          screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 2.
      LOOP AT SCREEN.
        IF screen-group1 = 'IH2' OR
          screen-group1 = 'IL3' OR
          screen-group1 = 'IH3' OR
          screen-group1 = 'IL4' OR
          screen-group1 = 'IH4' OR
          screen-group1 = 'IL5'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE2' OR
          screen-group1 = 'GE3' OR
          screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 3.
      LOOP AT SCREEN.
        IF screen-group1 = 'IH3' OR
          screen-group1 = 'IL4' OR
          screen-group1 = 'IH4' OR
          screen-group1 = 'IL5'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
          screen-group1 = 'GE3' OR
          screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 4.
      LOOP AT SCREEN.
        IF screen-group1 = 'IH4' OR
          screen-group1 = 'IL5'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
          screen-group1 = 'GE2' OR
          screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 5.
      LOOP AT SCREEN.
        IF screen-group1 = 'GE1' OR
          screen-group1 = 'GE2' OR
          screen-group1 = 'GE3'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mess(50) VALUE 'Error in interval'.

  IF pa_inter GT 5.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'INT'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDGET_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_budget_price  USING    fu_flag fu_matnr fu_bedat
                         CHANGING fc_waers fc_budget fc_inco1.

  DATA: bgt_prc   TYPE p DECIMALS 4.
  DATA: lv_budgt  LIKE konp-kbetr.

  SORT gt_a049 BY matnr knumh DESCENDING.
  SORT gt_a501 BY matnr knumh DESCENDING.

  CLEAR: gr_eindt3m,gt_a049,gt_a501.
  READ TABLE gr_eindt3m INDEX 1.

  READ TABLE gt_a501  WITH KEY matnr = fu_matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    fc_inco1 = gt_a501-inco1.
    CLEAR gt_konpb.
    READ TABLE gt_konpb2 INTO gt_konpb WITH KEY knumh = gt_a501-knumh.

  ELSE.
    READ TABLE gt_a049  WITH KEY matnr = fu_matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      CLEAR gt_konpb.
      READ TABLE gt_konpb WITH KEY knumh = gt_a049-knumh.

    ELSE.
      fc_waers  = 'IDR'.
      CLEAR: fc_budget.
    ENDIF.
  ENDIF.

  IF gt_konpb IS NOT INITIAL.
    IF gt_konpb-konwa EQ 'IDR'.
      bgt_prc = gt_konpb-kbetr * 100 / gt_konpb-kpein.

    ELSE.
      bgt_prc = gt_konpb-kbetr / gt_konpb-kpein.
*      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*        EXPORTING
*          date             = sy-datum
*          foreign_amount   = gt_konpb-kbetr
*          foreign_currency = gt_konpb-konwa
*          local_currency   = 'IDR'
*        IMPORTING
*          local_amount     = lv_budgt
*        EXCEPTIONS
*          no_rate_found    = 1
*          overflow         = 2
*          no_factors_found = 3
*          no_spread_found  = 4
*          derived_2_times  = 5
*          OTHERS           = 6.
*      bgt_prc = lv_budgt * 100 / gt_konpb-kpein.
    ENDIF.

    "Balik ke konwa lagi.... :)
    fc_waers  = gt_konpb-konwa.       "'IDR'.    "gt_konpb-konwa.
  ENDIF.

  fc_budget  = bgt_prc.

  IF fu_flag IS INITIAL.
    CLEAR: fc_budget.
  ENDIF.
ENDFORM.                    " F_GET_BUDGET_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_IDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_value_idr  USING    fu_knumv fu_ebelp fu_bedat fu_waers fu_netwr
                           fu_menge
                  CHANGING fc_validr.

  DATA: ld_netwr       LIKE ekpo-netwr,
        ld_kkurs       LIKE konv-kkurs,
        ld_waers       LIKE konv-waers,
        ld_ratio       LIKE tcurf-tfact VALUE 1,
        exc_rate(10)   TYPE p DECIMALS 2,
        ld_currdec     LIKE tcurx-currdec VALUE 2.

  SELECT SINGLE kkurs waers
    FROM konv
    INTO (ld_kkurs, ld_waers)
    WHERE knumv EQ fu_knumv AND
          kposn EQ fu_ebelp AND
          kappl EQ 'M' AND
        ( kschl EQ 'ZPB0' OR kschl EQ 'ZPB1' ).
  IF sy-subrc EQ 0.
    SELECT SINGLE tfact
      FROM tcurf
      INTO ld_ratio
      WHERE kurst EQ 'M' AND
            fcurr EQ ld_waers AND
            tcurr EQ 'IDR' AND
            gdatu GE fu_bedat.
  ELSE.
    CLEAR: ld_ratio.
  ENDIF.

  exc_rate = ld_kkurs * ld_ratio.
  IF fu_waers NE 'IDR'.
    ld_netwr = fu_netwr * exc_rate.
  ELSE.
    ld_netwr = fu_netwr.
  ENDIF.

  SELECT SINGLE currdec
    FROM tcurx
    INTO ld_currdec
    WHERE currkey EQ fu_waers.
  IF ld_currdec = 0.
    fc_validr   = ld_netwr * 100.
  ELSE.
    IF ld_currdec EQ 3.
      fc_validr = ld_netwr * 10.
    ELSE.
      fc_validr = ld_netwr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALUE_IDR

*&---------------------------------------------------------------------*
*&      Form  F_GET_FROM_ZM70
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_from_zm70.
  DATA: ld_menge     LIKE ekbe-menge.

  SORT t_history BY ebeln ebelp.
  SORT t_realisasi BY ebeln ebelp.
  SORT t_eketh BY ebeln ebelp eindt etenr.

  LOOP AT t_eketh.
    t_eketdata-ebeln   = t_eketh-ebeln.
    t_eketdata-ebelp   = t_eketh-ebelp.
    t_eketdata-count   = 1.
    IF t_eketh-menge IS NOT INITIAL.
      t_eketdata-menge = 1.
    ELSE.
      CLEAR: t_eketdata-menge.
    ENDIF.
    IF t_eketh-wemng IS NOT INITIAL.
      t_eketdata-wemng = 1.
    ELSE.
      CLEAR: t_eketdata-wemng.
    ENDIF.
    COLLECT t_eketdata.
    t_interval-ebeln        = t_eketh-ebeln.
    t_interval-etenr        = t_eketh-etenr.
    t_interval-ebelp        = t_eketh-ebelp.
    t_interval-eindt        = t_eketh-eindt.
    t_interval-menge_eket   = t_eketh-menge.
    t_interval-wemng        = t_eketh-wemng.
    READ TABLE t_history WITH KEY ebeln = t_eketh-ebeln
                                  ebelp = t_eketh-ebelp
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_history TO t_interval.
      t_interval-eindt = t_eketh-eindt.
      IF t_history-matnr CP 'PCC*'.
        SORT t_ekbeh BY ebeln ebelp bldat belnr.
      ELSE.
        SORT t_ekbeh BY ebeln ebelp budat belnr.
      ENDIF.
      APPEND t_interval.
      CLEAR: t_interval.
    ENDIF.
  ENDLOOP.
  PERFORM f_interval.
* Score delivery, Bobot delivery
  PERFORM f_get_nilai_interval.
ENDFORM.                    " F_GET_FROM_ZM70.

*&---------------------------------------------------------------------*
*&      Form  F_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_interval .
  DATA: lw_out          LIKE t_interval,
        ld_tabix        LIKE sy-tabix,
        ld_tabix1       LIKE sy-tabix,
        ld_tabix2       LIKE sy-tabix,
        ld_count        TYPE i,
        ld_noexit       TYPE i,
        lw_ekbe         LIKE t_ekbeh,
        ld_eindt        LIKE sy-datum,
        ld_first        TYPE i,
        ld_cancel       TYPE i,
        ld_flag         TYPE i.

  DATA: ld_firstqtygr   LIKE t_interval-firstqtygr,
        ld_switch       TYPE i.

  SORT t_interval BY ebeln ebelp eindt etenr.
  SORT t_ekbedata BY ebeln ebelp.
  SORT t_eketdata BY ebeln ebelp.

  t_ekbe1[]  = t_ekbeh[].
  LOOP AT t_interval.
    ADD 1 TO ld_count.
    lw_out       = t_interval.
    ld_tabix     = sy-tabix - 1.
    ld_tabix1    = sy-tabix.
    ld_tabix2    = sy-tabix.
    IF t_ekbeh-matnr CP 'PCC*'.
      SORT t_ekbeh BY ebeln ebelp bldat belnr buzei.
      SORT t_ekbe1 BY ebeln ebelp bldat belnr buzei.
    ELSE.
      SORT t_ekbeh BY ebeln ebelp budat belnr buzei.
      SORT t_ekbe1 BY ebeln ebelp budat belnr buzei.
    ENDIF.

    ld_noexit = 1.
    IF ld_flag IS INITIAL.
      ld_flag = 1.
      READ TABLE t_ekbedata WITH KEY ebeln = t_interval-ebeln
                                     ebelp = t_interval-ebelp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ld_cancel = t_ekbedata-cancel.
      ENDIF.
    ENDIF.

    READ TABLE t_eketdata WITH KEY ebeln = t_interval-ebeln
                                   ebelp = t_interval-ebelp
    BINARY SEARCH.

    WHILE ld_noexit IS NOT INITIAL.
      PERFORM f_get_interval USING lw_out-eindt.
      PERFORM f_loop_ekbe USING ld_tabix ld_tabix1 ld_tabix2 ld_count ld_cancel
                                lw_out-ebeln lw_out-ebelp lw_out-wemng
                          CHANGING lw_out-menge_eket ld_noexit ld_eindt
                                   ld_first.
      IF ld_eindt IS NOT INITIAL.
        lw_out-eindt  = ld_eindt.
      ENDIF.
      DELETE t_ekbeh WHERE ebeln EQ lw_out-ebeln AND
                           ebelp EQ lw_out-ebelp AND
                           menge EQ 0.
      READ TABLE t_ekbeh INTO lw_ekbe WITH KEY ebeln = lw_out-ebeln
                                              ebelp = lw_out-ebelp.
      IF sy-subrc NE 0.
        CLEAR: ld_noexit.
      ENDIF.
      CLEAR: t_interval, ld_eindt.
    ENDWHILE.

    CLEAR: ld_first.
    AT END OF ebeln.
      CLEAR: ld_count, lw_out, ld_first, ld_flag, ld_cancel, ld_tabix2.
    ENDAT.

    AT END OF ebelp.
      CLEAR: ld_count, lw_out, ld_flag, ld_cancel, ld_tabix2.
    ENDAT.
  ENDLOOP.

  SORT t_interval BY ebeln ebelp eindt etenr.
  LOOP AT t_interval.
    IF t_interval-firstbudat IS NOT INITIAL.
      t_interval-grpo_first = t_interval-firstbudat - t_interval-eindt.
    ENDIF.
    MODIFY t_interval TRANSPORTING grpo_first.

    CLEAR: ld_switch.
    ld_firstqtygr  = t_interval-menge_eket.
    LOOP AT t_ekbe1 WHERE ebeln EQ t_interval-ebeln AND
                          ebelp EQ t_interval-ebelp.
      IF t_ekbe1-shkzg EQ 'H'.
        t_ekbe1-menge = t_ekbe1-menge * -1.
      ENDIF.

      IF ld_switch IS INITIAL.
        IF t_ekbe1-menge LT 0.
          t_interval-menge_eket  = t_interval-menge_eket + t_ekbe1-menge.
          DELETE t_ekbe1.
        ELSE.
          IF t_interval-menge_eket LT 0.
            t_interval-menge_eket  = t_interval-menge_eket + t_ekbe1-menge.
            IF t_interval-menge_eket EQ ld_firstqtygr.
              DELETE t_ekbe1.
            ENDIF.
          ELSE.
            IF t_interval-menge_eket LT t_ekbe1-menge.
              t_ekbe1-menge     = t_ekbe1-menge - t_interval-menge_eket.
              MODIFY t_ekbe1 TRANSPORTING menge.
              IF ld_switch IS INITIAL.
                ld_switch  = 1.
                t_interval-firstqtygr  = ld_firstqtygr.
                MODIFY t_interval TRANSPORTING firstqtygr.
              ENDIF.
              EXIT.
            ENDIF.
          ENDIF.

          IF t_interval-menge_eket GE t_ekbe1-menge.
            IF ld_switch IS INITIAL.
              ld_switch  = 1.
              t_interval-firstqtygr  = t_ekbe1-menge.
              MODIFY t_interval TRANSPORTING firstqtygr.
            ENDIF.
            t_interval-menge_eket  = t_interval-menge_eket - t_ekbe1-menge.
            DELETE t_ekbe1.
          ENDIF.
        ENDIF.
      ELSE.
        IF t_interval-menge_eket LT t_ekbe1-menge.
          t_ekbe1-menge     = t_ekbe1-menge - t_interval-menge_eket.
          MODIFY t_ekbe1 TRANSPORTING menge.
          IF ld_switch IS INITIAL.
            ld_switch  = 1.
            t_interval-firstqtygr  = ld_firstqtygr.
            MODIFY t_interval TRANSPORTING firstqtygr.
          ENDIF.
          EXIT.
        ENDIF.

        IF t_interval-menge_eket GE t_ekbe1-menge.
          IF ld_switch IS INITIAL.
            ld_switch  = 1.
            t_interval-firstqtygr  = t_ekbe1-menge.
            MODIFY t_interval TRANSPORTING firstqtygr.
          ENDIF.
          t_interval-menge_eket  = t_interval-menge_eket - t_ekbe1-menge.
        ENDIF.
        DELETE t_ekbe1.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_interval USING fu_eindt.
  CASE pa_inter.
    WHEN 1.
      ra_inter1-low    = fu_eindt + pa_intl1.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'GE'.
      APPEND ra_inter1.

    WHEN 2.
      ra_inter1-low    = fu_eindt + pa_intl1.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_intl2.
      ra_inter2-high   = fu_eindt + pa_inth2.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'GE'.
      APPEND ra_inter2.

    WHEN 3.
      ra_inter1-low    = fu_eindt + pa_intl1.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_intl2.
      ra_inter2-high   = fu_eindt + pa_inth2.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_intl3.
      ra_inter3-high   = fu_eindt + pa_inth3.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'GE'.
      APPEND ra_inter3.

    WHEN 4.
      ra_inter1-low    = fu_eindt + pa_intl1.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_intl2.
      ra_inter2-high   = fu_eindt + pa_inth2.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_intl3.
      ra_inter3-high   = fu_eindt + pa_inth3.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'BT'.
      APPEND ra_inter3.

      ra_inter4-low    = fu_eindt + pa_intl4.
      ra_inter4-high   = fu_eindt + pa_inth4.
      ra_inter4-sign   = 'I'.
      ra_inter4-option = 'GE'.
      APPEND ra_inter4.

    WHEN 5.
      ra_inter1-low    = fu_eindt + pa_intl1.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_intl2.
      ra_inter2-high   = fu_eindt + pa_inth2.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_intl3.
      ra_inter3-high   = fu_eindt + pa_inth3.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'BT'.
      APPEND ra_inter3.

      ra_inter4-low    = fu_eindt + pa_intl4.
      ra_inter4-high   = fu_eindt + pa_inth4.
      ra_inter4-sign   = 'I'.
      ra_inter4-option = 'BT'.
      APPEND ra_inter4.

      ra_inter5-low    = fu_eindt + pa_intl5.
      ra_inter5-sign   = 'I'.
      ra_inter5-option = 'GE'.
      APPEND ra_inter5.
  ENDCASE.
ENDFORM.                    " F_GET_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_LOOP_EKBE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_loop_ekbe  USING fu_tabix fu_tabix1 fu_tabix2 fu_count fu_cancel
                        fu_ebeln fu_ebelp fu_wemng
                  CHANGING fc_menge_eket fc_noexit fc_eindt
                           fc_first.

  DATA: ld_date      TYPE sy-datum,
        ld_qtyinter  LIKE ekbe-menge,
        ld_count     TYPE i,
        ld_inter     TYPE i,
        ld_menge     LIKE ekbe-menge,
        lw_out       LIKE t_interval,
        lw_ekbe      LIKE t_ekbeh,
        ld_flag      TYPE i,
        ld_flag1     TYPE i.

  DATA : lv_tabix1   TYPE sy-tabix.

  CLEAR: ld_flag.
  READ TABLE t_eketdata WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF t_eketdata-menge NE t_eketdata-wemng.
      READ TABLE t_ekbeh WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF fu_wemng IS INITIAL.
          LOOP AT t_ekbeh WHERE ebeln EQ fu_ebeln AND
                               ebelp EQ fu_ebelp.
            ADD 1 TO ld_flag.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT t_ekbeh WHERE ebeln EQ fu_ebeln AND
                       ebelp EQ fu_ebelp.

    t_interval-budat  = t_ekbeh-budat.
    IF t_ekbeh-matnr CP 'PCC*'.
      ld_date = t_ekbeh-bldat.
    ELSE.
      ld_date = t_ekbeh-budat.
    ENDIF.

    IF t_ekbeh-shkzg EQ 'H'.
      t_ekbeh-menge = t_ekbeh-menge * -1.
    ENDIF.

    IF fc_first IS INITIAL AND t_ekbeh-menge GT 0.
      fc_first  = 1.
      t_interval-firstbudat  = t_ekbeh-budat.
      MODIFY t_interval INDEX fu_tabix1 TRANSPORTING firstbudat.
    ENDIF.

    IF fc_menge_eket IS INITIAL.
      IF t_ekbeh-menge GE 0 AND
        t_ekbeh-shkzg = 'H'.
        IF fu_cancel IS NOT INITIAL.
          PERFORM f_hitung_qtyinter_cancel USING lw_out
                                           CHANGING fu_tabix fu_tabix1 ld_count fc_menge_eket
                                                    t_interval-qtyotim t_interval-qtylate01 t_interval-qtylate02 t_interval-qtylate03
                                                    t_interval-qtylate04 ld_menge ld_qtyinter.
        ELSE.
          PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
        ENDIF.
      ELSE.
        PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
      ENDIF.
    ELSE.
      IF ld_flag EQ 1.
        fu_tabix      = fu_tabix - 1.
        lv_tabix1     = fu_tabix1.
        fu_tabix1     = fu_tabix1 - 1.
        IF fu_tabix1 = 0.
          fu_tabix1 = lv_tabix1.
        ENDIF.
        fc_menge_eket = t_ekbeh-menge.
      ENDIF.
      PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
    ENDIF.

    CLEAR: ld_inter.

    PERFORM f_modify_interval USING ld_date ld_qtyinter
                              CHANGING t_interval-qtyotim t_interval-qtylate01 t_interval-qtylate02
                                       t_interval-qtylate03 t_interval-qtylate04 ld_inter.

    IF ld_inter IS NOT INITIAL.
      PERFORM f_hitung_qty_minus USING ld_inter fu_tabix fu_tabix1 fu_ebeln fu_ebelp
                                       t_interval-qtyotim t_interval-qtylate01 t_interval-qtylate02
                                       t_interval-qtylate03 t_interval-qtylate04
                                 CHANGING fc_menge_eket ld_date.
      REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
      CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
      PERFORM f_get_interval USING ld_date.
    ELSE.
      IF ld_qtyinter IS NOT INITIAL.
        MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtyotim qtylate01 qtylate02
                                                  qtylate03 qtylate04 budat.
      ENDIF.
    ENDIF.

    IF ld_count IS INITIAL.
      READ TABLE t_eketdata WITH KEY ebeln = fu_ebeln
                                     ebelp = fu_ebelp.
      IF sy-subrc EQ 0.
        IF fu_count EQ t_eketdata-count.
          PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                   CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                            fc_noexit.
          EXIT.
        ELSE.
          IF fu_tabix1 LT fu_tabix2.
            IF ld_count IS INITIAL.
              ld_flag1 = fu_tabix2 - fu_tabix1.
              IF ld_flag1 EQ 1.
                PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                         CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                                  fc_noexit.
                EXIT.
              ELSE.
                IF ld_flag IS INITIAL.
                  PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                           CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                                    fc_noexit.
                  EXIT.
                ELSE.
                  CLEAR: fc_noexit.
                  EXIT.
                ENDIF.
              ENDIF.
            ELSE.
              CLEAR: fc_noexit.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: fc_noexit.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: fc_noexit.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
  CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
  CLEAR: lw_out, ld_count.
ENDFORM.                    " F_LOOP_EKBE

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_MENGE_0
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_delete_menge_0 USING fu_ebeln fu_ebelp
                            fw_out STRUCTURE t_interval
                            fw_ekbe STRUCTURE t_ekbeh
                      CHANGING fc_tabix fc_tabix1 fc_menge_eket fc_eindt
                               fc_noexit.

  DELETE t_ekbeh WHERE ebeln EQ fu_ebeln AND
                      ebelp EQ fu_ebelp AND
                      menge EQ 0.

  READ TABLE t_ekbeh INTO fw_ekbe WITH KEY ebeln = fu_ebeln
                                          ebelp = fu_ebelp.
  IF sy-subrc EQ 0.
    fc_tabix   = fc_tabix + 1.
    fc_tabix1  = fc_tabix1 + 1.
    READ TABLE t_interval INTO fw_out INDEX fc_tabix1.
    IF fw_out-ebeln EQ fu_ebeln AND
      fw_out-ebelp EQ fu_ebelp.
      fc_menge_eket   = fw_out-menge_eket.
      fc_eindt        = fw_out-eindt.
      fc_noexit       = 1.
    ELSE.
      CLEAR: fc_noexit.
    ENDIF.
  ELSE.
    CLEAR: fc_noexit.
  ENDIF.
ENDFORM.                    " F_DELETE_MENGE_0

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTYINTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_qtyinter CHANGING fc_menge_eket fc_count fc_menge fc_qtyinter fc_cancel.
  IF fc_menge_eket GE t_ekbeh-menge.
    fc_count      = 1.
    fc_menge_eket = fc_menge_eket - t_ekbeh-menge.
    fc_menge      = t_ekbeh-menge.
    fc_qtyinter   = fc_menge.
    t_ekbeh-menge  = 0.
    MODIFY t_ekbeh TRANSPORTING menge.
    IF fc_menge_eket EQ fc_qtyinter.
      IF fc_cancel IS NOT INITIAL.
        CLEAR: fc_count.
      ENDIF.
    ENDIF.
    CLEAR: fc_menge.
  ELSE.
    ADD t_ekbeh-menge TO fc_menge.
    fc_qtyinter  = fc_menge_eket.
    t_ekbeh-menge = t_ekbeh-menge - fc_menge_eket.
    MODIFY t_ekbeh TRANSPORTING menge.
    CLEAR: fc_count, fc_menge_eket.
  ENDIF.
ENDFORM.                    " F_HITUNG_QTYINTER

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTYINTER_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_qtyinter_cancel USING ft_interval STRUCTURE t_interval
                              CHANGING fc_tabix fc_tabix1 fc_count fc_menge_eket fc_qtyotim
                                       fc_qtylate01 fc_qtylate02 fc_qtylate03 fc_qtylate04
                                       fc_menge fc_qtyinter.
  fc_tabix  = fc_tabix + 1.
  fc_tabix1 = fc_tabix1 + 1.
  READ TABLE t_interval INTO ft_interval INDEX fc_tabix1.
  IF sy-subrc EQ 0.
    fc_count        = 1.
    fc_menge_eket   = ft_interval-menge_eket.
    fc_qtyotim      = ft_interval-qtyotim.
    fc_qtylate01    = ft_interval-qtylate01.
    fc_qtylate02    = ft_interval-qtylate02.
    fc_qtylate03    = ft_interval-qtylate03.
    fc_qtylate04    = ft_interval-qtylate04.
    REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
    CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
    PERFORM f_get_interval USING ft_interval-eindt.
    fc_menge_eket = fc_menge_eket - t_ekbeh-menge.
    fc_menge      = t_ekbeh-menge.
    fc_qtyinter   = fc_menge.
    t_ekbeh-menge  = 0.
    MODIFY t_ekbeh TRANSPORTING menge.
    CLEAR: fc_menge.
  ENDIF.
ENDFORM.                    " F_HITUNG_QTYINTER_CANCEL

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTY_MINUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_qty_minus  USING fu_inter fu_tabix fu_tabix1 fu_ebeln fu_ebelp
                               fu_qtyotim fu_qtylate01 fu_qtylate02
                               fu_qtylate03 fu_qtylate04
                         CHANGING fc_menge_eket fc_date.
  DATA: ld_qty  LIKE eket-menge.
  DATA: lw_out  LIKE t_interval.

  CASE fu_inter.
    WHEN 1.
      ld_qty  = fu_qtyotim.
    WHEN 2.
      ld_qty  = fu_qtylate01.
    WHEN 3.
      ld_qty  = fu_qtylate02.
    WHEN 4.
      ld_qty  = fu_qtylate03.
    WHEN 5.
      ld_qty  = fu_qtylate04.
  ENDCASE.

  WHILE ld_qty LT 0.
    IF fu_inter IS NOT INITIAL.
      IF fu_qtylate04 LT 0.
        fu_qtylate03 = fu_qtylate03 + fu_qtylate04.
        ld_qty       = fu_qtylate03.
        fu_qtylate04 = 0.
        MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtylate04 qtylate03.
      ENDIF.
      IF fu_qtylate03 LT 0.
        fu_qtylate02 = fu_qtylate02 + fu_qtylate03.
        ld_qty       = fu_qtylate02.
        fu_qtylate03 = 0.
        MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtylate03 qtylate02.
      ENDIF.
      IF fu_qtylate02 LT 0.
        fu_qtylate01 = fu_qtylate01 + fu_qtylate02.
        ld_qty       = fu_qtylate01.
        fu_qtylate02 = 0.
        MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtylate02 qtylate01.
      ENDIF.
      IF fu_qtylate01 LT 0.
        fu_qtyotim   = fu_qtyotim + fu_qtylate01.
        ld_qty       = fu_qtyotim.
        fu_qtylate01 = 0.
        MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtylate01 qtyotim.
      ENDIF.
      IF fu_qtyotim LT 0.
        READ TABLE t_interval INTO lw_out INDEX fu_tabix.
        IF lw_out-ebeln EQ fu_ebeln AND
          lw_out-ebelp EQ fu_ebelp.
          lw_out-qtylate04 = lw_out-qtylate04 + fu_qtyotim.
          ld_qty           = fu_qtylate04 = lw_out-qtylate04.
          fu_qtyotim       = 0.
          MODIFY t_interval INDEX fu_tabix1 TRANSPORTING qtyotim.
          fu_qtylate03     = lw_out-qtylate03.
          fu_qtylate02     = lw_out-qtylate02.
          fu_qtylate01     = lw_out-qtylate01.
          fu_qtyotim       = lw_out-qtyotim.
          fu_tabix1        = fu_tabix.
          MODIFY t_interval FROM lw_out INDEX fu_tabix TRANSPORTING qtylate04.
          fu_tabix         = fu_tabix - 1.
        ELSE.
          ld_qty  = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDWHILE.

  IF lw_out-wemng IS INITIAL.
    READ TABLE t_interval INTO lw_out INDEX fu_tabix1.
  ELSE.
    IF lw_out-ebeln NE fu_ebeln OR
      lw_out-ebelp NE fu_ebelp.
      READ TABLE t_interval INTO lw_out INDEX fu_tabix1.
    ENDIF.
  ENDIF.

  fc_menge_eket  = lw_out-menge_eket - fu_qtyotim - fu_qtylate01 - fu_qtylate02 -
                   fu_qtylate03 - fu_qtylate04.
  fc_date        = lw_out-eindt.
ENDFORM.                    " F_HITUNG_QTY_MINUS

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_interval USING fu_date fu_wmeng
                       CHANGING fc_qtyotim fc_qtylate01 fc_qtylate02
                                fc_qtylate03 fc_qtylate04 fc_inter.
  IF ra_inter1[] IS NOT INITIAL.
    IF fu_date IN ra_inter1.
      ADD fu_wmeng TO fc_qtyotim.
      IF fc_qtyotim LT 0.
        fc_inter  = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter2[] IS NOT INITIAL.
    IF fu_date IN ra_inter2.
      ADD fu_wmeng TO fc_qtylate01.
      IF fc_qtylate01 LT 0.
        fc_inter  = 2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter3[] IS NOT INITIAL.
    IF fu_date IN ra_inter3.
      ADD fu_wmeng TO fc_qtylate02.
      IF fc_qtylate02 LT 0.
        fc_inter  = 3.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter4[] IS NOT INITIAL.
    IF fu_date IN ra_inter4.
      ADD fu_wmeng TO fc_qtylate03.
      IF fc_qtylate03 LT 0.
        fc_inter  = 4.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter5[] IS NOT INITIAL.
    IF fu_date IN ra_inter5.
      ADD fu_wmeng TO fc_qtylate04.
      IF fc_qtylate04 LT 0.
        fc_inter  = 5.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_NILAI_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_nilai_interval .
  RANGES: lr_inter1  FOR zvend_eval-inter_low,
          lr_inter2  FOR zvend_eval-inter_low,
          lr_inter3  FOR zvend_eval-inter_low,
          lr_inter4  FOR zvend_eval-inter_low,
          lr_inter5  FOR zvend_eval-inter_low.

  lr_inter1-low    = pa_intl1.
  lr_inter1-sign   = 'I'.
  lr_inter1-option = 'EQ'.
  APPEND lr_inter1.
  lr_inter2-low    = pa_intl2.
  lr_inter2-high   = pa_inth2.
  lr_inter2-sign   = 'I'.
  lr_inter2-option = 'BT'.
  APPEND lr_inter2.
  lr_inter3-low    = pa_intl3.
  lr_inter3-high   = pa_inth3.
  lr_inter3-sign   = 'I'.
  lr_inter3-option = 'BT'.
  APPEND lr_inter3.
  lr_inter4-low    = pa_intl4.
  lr_inter4-high   = pa_inth4.
  lr_inter4-sign   = 'I'.
  lr_inter4-option = 'BT'.
  APPEND lr_inter4.
  lr_inter5-low    = pa_intl5.
  lr_inter5-sign   = 'I'.
  lr_inter5-option = 'EQ'.
  APPEND lr_inter5.

  SORT t_interval BY matnr lifnr.
  LOOP AT t_interval.
    t_scord-matnr  = t_interval-matnr.
    t_scord-lifnr  = t_interval-lifnr.
    t_scord-count  = 1.
    IF t_interval-grpo_first LE pa_intl1.
      t_scord-menge  = t_interval-qtyotim.
    ELSE.
      t_scord-menge  = t_interval-firstqtygr.
    ENDIF.

    CASE pa_inter.
      WHEN 1.
        t_scord-nilai  = pa_intn1.
      WHEN 2.
        IF t_interval-grpo_first LE pa_intl1.
          t_scord-nilai  = pa_intn1.
        ELSEIF t_interval-grpo_first GE pa_intl2.
          t_scord-nilai  = pa_intn2.
        ENDIF.
      WHEN 3.
        IF t_interval-grpo_first LE pa_intl1.
          t_scord-nilai  = pa_intn1.
        ELSEIF t_interval-grpo_first IN lr_inter2.
          t_scord-nilai  = pa_intn2.
        ELSEIF t_interval-grpo_first GE pa_intl3.
          t_scord-nilai  = pa_intn3.
        ENDIF.
      WHEN 4.
        IF t_interval-grpo_first LE pa_intl1.
          t_scord-nilai  = pa_intn1.
        ELSEIF t_interval-grpo_first IN lr_inter2.
          t_scord-nilai  = pa_intn2.
        ELSEIF t_interval-grpo_first IN lr_inter3.
          t_scord-nilai  = pa_intn3.
        ELSEIF t_interval-grpo_first GE pa_intl4.
          t_scord-nilai  = pa_intn4.
        ENDIF.
      WHEN 5.
        IF t_interval-grpo_first LE pa_intl1.
          t_scord-nilai  = pa_intn1.
        ELSEIF t_interval-grpo_first IN lr_inter2.
          t_scord-nilai  = pa_intn2.
        ELSEIF t_interval-grpo_first IN lr_inter3.
          t_scord-nilai  = pa_intn3.
        ELSEIF t_interval-grpo_first IN lr_inter4.
          t_scord-nilai  = pa_intn4.
        ELSEIF t_interval-grpo_first GE pa_intl5.
          t_scord-nilai  = pa_intn5.
        ENDIF.
    ENDCASE.
    COLLECT t_scord.
  ENDLOOP.

  LOOP AT t_scord.
    t_scord-scord  = t_scord-nilai / t_scord-count.
    t_scord-bdelv  = t_scord-scord * pa_deliv.
    MODIFY t_scord TRANSPORTING scord bdelv.
  ENDLOOP.
ENDFORM.                    " F_GET_NILAI_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_PO_HISTORY
*&---------------------------------------------------------------------*
FORM f_filter_po_history .
  DATA: lv_key    TYPE char30,
        lv_count  TYPE int3.

  DATA: lt_eketdata3 LIKE t_eketdata3 OCCURS 0 WITH HEADER LINE.

  "Get ITAB Score Delivery
  t_ekbeh_101[] = t_ekbeh[].
  DELETE t_ekbeh_101 WHERE bwart NE '101'.

  "Get ITAB reject Score Quality
  t_ekbeh_rj[] = t_ekbeh[].
  DELETE t_ekbeh_rj WHERE bwart NE '122'
                      AND bwart NE '123'.

  "Get material & vendor
  SORT t_eketh BY ebeln ebelp eindt etenr.
  SORT t_ekbeh BY ebeln ebelp zekkn vgabe gjahr belnr buzei bldat.
  SORT t_ekbeh_101 BY ebeln ebelp zekkn vgabe gjahr belnr buzei bldat.
  SORT t_history BY ebeln ebelp.

  LOOP AT t_eketh.

    CLEAR t_history.
    READ TABLE t_history WITH KEY ebeln = t_eketh-ebeln
                                  ebelp = t_eketh-ebelp BINARY SEARCH.
    t_eketh-matnr = t_history-matnr.
    t_eketh-lifnr = t_history-lifnr.
    CONCATENATE t_eketh-matnr t_eketh-lifnr INTO t_eketh-key.
    MODIFY t_eketh TRANSPORTING matnr lifnr key.

    IF t_eketh-eindt NOT IN gr_eindt2m.
      PERFORM f_data_score_quality.
    ENDIF.
    PERFORM f_data_score_quantity.
    PERFORM f_data_score_delivery.
    CLEAR t_eketh.
  ENDLOOP.

  "Backup EKET
  t_eketh_sv[] = t_eketh[].

  "Filter 6 item by eindt for score_quality
  CLEAR: lv_count,lv_key.
  SORT t_eketh BY matnr lifnr eindt DESCENDING etenr DESCENDING.
  LOOP AT t_eketh WHERE eindt NOT IN gr_eindt2m
                    AND eindt LE p_assdt.
    IF lv_key = t_eketh-key.
      ADD 1 TO lv_count.
    ELSE.
      lv_count = 1.
      lv_key = t_eketh-key.
    ENDIF.

    IF lv_count LE gc_item_limit.
      "Do Nothing
    ELSE.
      DELETE t_eketh.
    ENDIF.
  ENDLOOP.

  IF p_get6 = 'X'.
    "Filter 6 item by eindt for score quantity
    CLEAR: lv_count,lv_key.
    SORT t_eketdata2 BY matnr lifnr eindt DESCENDING etenr DESCENDING.
    LOOP AT t_eketdata2 WHERE eindt LE p_assdt.
      IF lv_key = t_eketdata2-key.
        ADD 1 TO lv_count.
      ELSE.
        lv_count = 1.
        lv_key = t_eketdata2-key.
      ENDIF.

      IF lv_count LE gc_item_limit.
        "Do Nothing
      ELSE.
        DELETE t_eketdata2.
      ENDIF.
    ENDLOOP.

    "Filter 6 item by eindt for score delivery
    SORT t_eketdata3 BY matnr lifnr eindt DESCENDING etenr DESCENDING.
    LOOP AT t_eketdata3.
      lt_eketdata3-ebeln = t_eketdata3-ebeln.
      lt_eketdata3-bsart = t_eketdata3-bsart.
      lt_eketdata3-etenr = t_eketdata3-etenr.
      lt_eketdata3-eindt = t_eketdata3-eindt.
      lt_eketdata3-budat = t_eketdata3-budat.
      lt_eketdata3-grqty = t_eketdata3-grqty.
      lt_eketdata3-menge = t_eketdata3-menge.
      lt_eketdata3-matnr = t_eketdata3-matnr.
      lt_eketdata3-lifnr = t_eketdata3-lifnr.
      CONCATENATE lt_eketdata3-matnr lt_eketdata3-lifnr lt_eketdata3-eindt
        INTO lt_eketdata3-key.
      COLLECT lt_eketdata3. CLEAR lt_eketdata3.
    ENDLOOP.

    CLEAR: lv_count,lv_key.
    t_eketdata3[] = lt_eketdata3[].
    LOOP AT t_eketdata3 WHERE eindt LE p_assdt.
      IF lv_key IS INITIAL.
        lv_count = 1.
        lv_key = t_eketdata3-key.
      ELSEIF lv_key NE t_eketdata3-key.
        ADD 1 TO lv_count.
        lv_key = t_eketdata3-key.
      ENDIF.
*      IF lv_key = t_eketdata3-key.
*        ADD 1 TO lv_count.
*      ELSE.
*        lv_count = 1.
*        lv_key = t_eketdata3-key.
*      ENDIF.

      IF lv_count LE gc_item_limit.
        "Do Nothing
      ELSE.
        DELETE t_eketdata3.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_FILTER_PO_HISTORY

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_SCORQUAL
*&---------------------------------------------------------------------*
FORM f_recalc_scorqual .
  DATA: lv_reject%(10) TYPE p DECIMALS 1,
        lv_score%(10)  TYPE p DECIMALS 1,
        lv_avg%(10)    TYPE p DECIMALS 1,
        lv_count       TYPE int3.

  LOOP AT t_eketh WHERE matnr = t_out-matnr
                    AND lifnr = t_out-lifnr
                    AND eindt LE p_assdt
                    AND eindt NOT IN gr_eindt2m.
    ADD 1 TO lv_count.
    lv_reject% = t_eketh-rjqty / t_eketh-menge * 100.

    IF lv_reject% LE 1.
      lv_score% = 100.                  "<= 1% , 100%
    ELSEIF lv_reject% LE 5.
      lv_score% = 90.                   "1% - 5% , 90%
    ELSEIF lv_reject% LE 10.
      lv_score% = 80.                   "5% - 10% , 80%
    ELSEIF lv_reject% LE 15.
      lv_score% = 60.                   "10% - 15% , 60%
    ELSEIF lv_reject% LE 20.
      lv_score% = 40.                   "15% - 20% , 40%
    ELSE.
      lv_score% = 0.                                        "> 20% , 0%
    ENDIF.

    ADD lv_score% TO lv_avg%.
  ENDLOOP.

  t_out-scorqual = lv_avg% / lv_count.

  IF t_out-scorqual GT 100.
    t_out-scorqual = 100.
  ENDIF.

ENDFORM.                    " F_RECALC_SCORQUAL

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_SCORQTY
*&---------------------------------------------------------------------*
FORM f_recalc_scorqty .
  DATA: lv_scoret%(10)  TYPE p DECIMALS 1,
        lv_score%(10)   TYPE p DECIMALS 1,
        lv_variant%(10) TYPE p DECIMALS 1,
        lv_variant      LIKE ekbe-menge,
        lv_count       TYPE int3.

  LOOP AT t_eketdata2 WHERE matnr = t_out-matnr
                        AND lifnr = t_out-lifnr.
    ADD 1 TO lv_count.
    lv_variant =  t_eketdata2-menge - t_eketdata2-grqty.

    IF lv_variant IS INITIAL.
      lv_variant% = 0.
    ELSE.
      lv_variant% = lv_variant /  t_eketdata2-menge * 100.
    ENDIF.

    lv_score% = 100 - lv_variant%.
    IF lv_score% GT 100.
      lv_score% = 100.
    ENDIF.
    ADD lv_score% TO lv_scoret%.
  ENDLOOP.

  t_out-scorqty = lv_scoret% / lv_count.
ENDFORM.                    " F_RECALC_SCORQTY

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_SCORD
*&---------------------------------------------------------------------*
FORM f_recalc_scord .
  DATA: lv_scoret%(10)  TYPE p DECIMALS 1,
        lv_score%(10)   TYPE p DECIMALS 1,
        lv_count        TYPE int3,
        lv_days         TYPE int3,
        lv_holiday      TYPE int3.

  LOOP AT t_eketdata3 WHERE matnr = t_out-matnr
                        AND lifnr = t_out-lifnr.
    IF t_eketdata3-eindt IN gr_eindt3m.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR: lv_days,lv_score%.
    IF t_eketdata3-budat GT t_eketdata3-eindt.
      lv_days = t_eketdata3-budat - t_eketdata3-eindt.
      PERFORM f_get_holiday USING t_eketdata3-eindt t_eketdata3-budat
                            CHANGING lv_holiday.
      SUBTRACT lv_holiday FROM lv_days.
    ELSE.
      lv_days = 0.
    ENDIF.

    CASE t_eketdata3-bsart.
      WHEN 'ZIMP'.
        IF lv_days LE 7.
          lv_score% = 100.
        ELSEIF lv_days LE 14.
          lv_score% = 80.
        ELSE.
          lv_score% = 60.
        ENDIF.

      WHEN 'ZLOC'.
        IF lv_days = 0.
          lv_score% = 100.
        ELSEIF lv_days LE 3.
          lv_score% = 90.
        ELSEIF lv_days LE 7.
          lv_score% = 80.
        ELSEIF lv_days LE 12.
          lv_score% = 60.
        ELSE.
          lv_score% = 50.
        ENDIF.
    ENDCASE.

    lv_score% = lv_score% * t_eketdata3-grqty / t_eketdata3-menge.

    ADD lv_score% TO lv_scoret%.
  ENDLOOP.

  PERFORM f_get_lines USING t_out-matnr t_out-lifnr
                      CHANGING lv_count.
  t_out-scord = lv_scoret% / lv_count.

  IF t_out-scord GT 100.
    t_out-scord = 100.
  ENDIF.

ENDFORM.                    " F_RECALC_SCORD

*&---------------------------------------------------------------------*
*&      Form  F_GET_GI_DOC
*&---------------------------------------------------------------------*
FORM f_get_gi_doc .
  DATA: lt_ekbeh LIKE t_ekbeh OCCURS 0 WITH HEADER LINE.

  lt_ekbeh[] = t_ekbeh[].
  DELETE lt_ekbeh WHERE bwart NE '101'.
  IF lt_ekbeh[] IS NOT INITIAL.
    SELECT mblnr mjahr vgart blart blaum bldat budat cpudt cputm aedat
           usnam tcode xblnr bktxt
      INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
      FROM mkpf FOR ALL ENTRIES IN lt_ekbeh
      WHERE mblnr = lt_ekbeh-belnr.
  ENDIF.
ENDFORM.                    " F_GET_GI_DOC

*&---------------------------------------------------------------------*
*&      Form  F_GET_REVESE_DOC
*&---------------------------------------------------------------------*
FORM f_get_revese_doc .
  DATA: lt_ekbeh LIKE t_ekbeh OCCURS 0 WITH HEADER LINE.

  lt_ekbeh[] = t_ekbeh[].
  DELETE lt_ekbeh WHERE bwart = '101'.
  IF lt_ekbeh[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile bwart matnr werks lgort menge ebeln ebelp
           lfbja lfbnr lfpos smbln sjahr smblp shkzg
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg
      FROM mseg FOR ALL ENTRIES IN lt_ekbeh
      WHERE mblnr = lt_ekbeh-belnr
        AND mjahr = lt_ekbeh-gjahr
        AND zeile = lt_ekbeh-buzei.
  ENDIF.
ENDFORM.                    " F_GET_REVESE_DOC

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATE
*&---------------------------------------------------------------------*
FORM f_calculate_date  USING    fu_month fu_date2
                       CHANGING fc_date.
  DATA: lv_datum TYPE datum.

  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
*     DAYS              = '0'
      months            = fu_month
      start_date        = fu_date2
    IMPORTING
      result_date       = lv_datum.

  IF lv_datum IS NOT INITIAL.
    fc_date = lv_datum.
  ELSE.

    CONCATENATE fu_date2(6) '01' INTO lv_datum.
    CALL FUNCTION 'CALCULATE_DATE'
      EXPORTING
*       DAYS              = '0'
        months            = fu_month
        start_date        = lv_datum
      IMPORTING
        result_date       = lv_datum.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_datum
      IMPORTING
        last_day_of_month = lv_datum.

    fc_date = lv_datum.
  ENDIF.
ENDFORM.                    " F_CALCULATE_DATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_HOLIDAY
*&---------------------------------------------------------------------*
FORM f_get_holiday  USING  fu_eindt fu_budat
                    CHANGING fc_holiday TYPE int3.
  DATA: lt_holidays TYPE TABLE OF iscal_day.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      holiday_calendar           = 'T1'
      factory_calendar           = 'T1'
      date_from                  = fu_eindt
      date_to                    = fu_budat
    TABLES
      holidays                   = lt_holidays
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    DESCRIBE TABLE lt_holidays LINES fc_holiday.
  ENDIF.
ENDFORM.                    " F_GET_HOLIDAY

*&---------------------------------------------------------------------*
*&      Form  F_GET_LINES
*&---------------------------------------------------------------------*
FORM f_get_lines  USING    fu_matnr
                           fu_lifnr
                  CHANGING fc_count.
  DATA: lt_eketh     LIKE t_eketh OCCURS 0 WITH HEADER LINE,
        lt_eketdata3 LIKE t_eketdata3 OCCURS 0 WITH HEADER LINE.

  IF p_get6 IS INITIAL.
    lt_eketh[] = t_eketh_sv[].
    DELETE lt_eketh WHERE eindt NOT IN gr_eindt3m.
    DELETE lt_eketh WHERE matnr NE fu_matnr.
    DELETE lt_eketh WHERE lifnr NE fu_lifnr.
    fc_count = LINES( lt_eketh ).
  ELSE.
    lt_eketdata3[] = t_eketdata3[].
    SORT lt_eketdata3 BY key.
    DELETE ADJACENT DUPLICATES FROM lt_eketdata3 COMPARING key.
    fc_count = LINES( lt_eketdata3 ).
  ENDIF.
ENDFORM.                    " F_GET_LINES

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SCORE_QUALITY
*&---------------------------------------------------------------------*
FORM f_data_score_quality .
**  DATA: ls_eketh  LIKE t_eketh.
  DATA: lv_total_rj LIKE ekbe-menge.

  IF gs_eketh-ebeln = t_eketh-ebeln AND
     gs_eketh-ebelp = t_eketh-ebelp.

    IF gs_eketh-sisa = t_eketh-menge.

      t_eketh-menge_ekbe = gs_eketh-sisa.
      t_eketh-rjqty = gs_eketh-sisa_rj.

*    IF t_eketh-menge_ekbe GT t_eketh-menge.
*      gs_eketh-sisa = t_eketh-menge_ekbe - t_eketh-menge.
*      t_eketh-menge_ekbe = t_eketh-menge.
*    ENDIF.

      MODIFY t_eketh TRANSPORTING menge_ekbe grqty rjqty sisa sisa_rj.
      CLEAR gs_eketh.

    ELSEIF gs_eketh-sisa GT t_eketh-menge.
      IF gs_eketh-sisa_rj GT t_eketh-menge.
        t_eketh-rjqty = t_eketh-menge.
        t_eketh-sisa_rj = gs_eketh-sisa_rj - t_eketh-menge.
      ELSE.
        t_eketh-rjqty = gs_eketh-sisa_rj.
      ENDIF.
      t_eketh-sisa = gs_eketh-sisa - t_eketh-menge.
      t_eketh-menge_ekbe = t_eketh-menge.
      MODIFY t_eketh TRANSPORTING menge_ekbe grqty rjqty sisa sisa_rj.
      gs_eketh = t_eketh.

    ELSE.
      ADD gs_eketh-sisa TO t_eketh-menge_ekbe.
      ADD gs_eketh-sisa_rj TO t_eketh-rjqty.
      CLEAR gs_eketh.

      LOOP AT t_ekbeh WHERE ebeln = t_eketh-ebeln
                        AND ebelp = t_eketh-ebelp
                        AND bwart = '101'
                        AND read_flg = space.
        t_ekbeh-read_flg = 'X'.
        MODIFY t_ekbeh TRANSPORTING read_flg.

*        READ TABLE t_history WITH KEY ebeln = t_ekbeh-ebeln
*                                      ebelp = t_ekbeh-ebelp.
*        IF sy-subrc IS INITIAL AND t_history-bedat IN gr_eindt6m.
*        ELSE.
*          CONTINUE.
*        ENDIF.

*      IF t_ekbeh-bwart = '122'.
        CLEAR lv_total_rj.
        LOOP AT t_ekbeh_rj WHERE lfbnr = t_ekbeh-belnr
                             AND ebeln = t_ekbeh-ebeln
                             AND ebelp = t_ekbeh-ebelp
                             AND bwart = '122'
                             AND read_flg = space.
          t_ekbeh_rj-read_flg = 'X'.
          MODIFY t_ekbeh_rj TRANSPORTING read_flg.
          READ TABLE gt_mseg WITH KEY smbln = t_ekbeh_rj-belnr
                                      sjahr = t_ekbeh_rj-gjahr
                                      bwart = '123'
                             TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            lv_total_rj = lv_total_rj + t_ekbeh_rj-menge.
            IF lv_total_rj LE t_eketh-menge.
              ADD t_ekbeh_rj-menge TO t_eketh-rjqty.
            ELSE.
              t_eketh-rjqty = t_eketh-menge.
              t_eketh-sisa_rj = lv_total_rj - t_eketh-menge.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
*      ENDIF.

        IF t_ekbeh-shkzg EQ 'H'.
          MULTIPLY t_ekbeh-menge BY -1.
        ENDIF.
        ADD t_ekbeh-menge TO t_eketh-menge_ekbe.

        IF t_eketh-menge LE t_eketh-menge_ekbe.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF t_eketh-menge_ekbe GT t_eketh-menge.
        t_eketh-sisa = t_eketh-menge_ekbe - t_eketh-menge.
        t_eketh-menge_ekbe = t_eketh-menge.
      ENDIF.

      MODIFY t_eketh TRANSPORTING menge_ekbe grqty rjqty sisa sisa_rj.

      IF t_eketh-sisa IS INITIAL.
        CLEAR gs_eketh.
      ELSE.
        gs_eketh = t_eketh.
      ENDIF.
    ENDIF.

  ELSE.
    LOOP AT t_ekbeh WHERE ebeln = t_eketh-ebeln
                      AND ebelp = t_eketh-ebelp
                      AND bwart = '101'
                      AND read_flg = space.
      t_ekbeh-read_flg = 'X'.
      MODIFY t_ekbeh TRANSPORTING read_flg.

*      READ TABLE t_history WITH KEY ebeln = t_ekbeh-ebeln
*                                    ebelp = t_ekbeh-ebelp.
*      IF sy-subrc IS INITIAL AND t_history-bedat IN gr_eindt6m.
*      ELSE.
*        CONTINUE.
*      ENDIF.

*      IF t_ekbeh-bwart = '122'.
      CLEAR lv_total_rj.
      LOOP AT t_ekbeh_rj WHERE lfbnr = t_ekbeh-belnr
                           AND ebeln = t_ekbeh-ebeln
                           AND ebelp = t_ekbeh-ebelp
                           AND bwart = '122'
                           AND read_flg = space.
        t_ekbeh_rj-read_flg = 'X'.
        MODIFY t_ekbeh_rj TRANSPORTING read_flg.
        READ TABLE gt_mseg WITH KEY smbln = t_ekbeh_rj-belnr
                                    sjahr = t_ekbeh_rj-gjahr
                                    bwart = '123'
                           TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          lv_total_rj = lv_total_rj + t_ekbeh_rj-menge.
          IF lv_total_rj LE t_eketh-menge.
            ADD t_ekbeh_rj-menge TO t_eketh-rjqty.
          ELSE.
            t_eketh-rjqty = t_eketh-menge.
            t_eketh-sisa_rj = lv_total_rj - t_eketh-menge.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
*      ENDIF.

      IF t_ekbeh-shkzg EQ 'H'.
        MULTIPLY t_ekbeh-menge BY -1.
      ENDIF.
      ADD t_ekbeh-menge TO t_eketh-menge_ekbe.

      IF t_eketh-menge LE t_eketh-menge_ekbe.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF t_eketh-menge_ekbe GT t_eketh-menge.
      t_eketh-sisa = t_eketh-menge_ekbe - t_eketh-menge.
      t_eketh-menge_ekbe = t_eketh-menge.
    ENDIF.

    MODIFY t_eketh TRANSPORTING menge_ekbe grqty rjqty sisa sisa_rj.

    IF t_eketh-sisa IS INITIAL.
      CLEAR gs_eketh.
    ELSE.
      gs_eketh = t_eketh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DATA_SCORE_QUALITY

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SCORE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_data_score_quantity .
  IF t_eketh-eindt IN gr_eindt3m.
    t_eketdata2-matnr    = t_history-matnr.
    t_eketdata2-lifnr    = t_history-lifnr.
    t_eketdata2-ebeln    = t_eketh-ebeln.
    t_eketdata2-ebelp    = t_eketh-ebelp.
    t_eketdata2-etenr    = t_eketh-etenr.
    t_eketdata2-eindt    = t_eketh-eindt.
    t_eketdata2-menge    = t_eketh-menge.
    t_eketdata2-grqty    = t_eketh-wemng.
    CONCATENATE t_eketdata2-matnr t_eketdata2-lifnr INTO t_eketdata2-key.
    COLLECT t_eketdata2. CLEAR: t_eketdata2.
  ENDIF.
ENDFORM.                    " F_DATA_SCORE_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SCORE_DELIVERY
*&---------------------------------------------------------------------*
FORM f_data_score_delivery .
  DATA: lv_grtot LIKE ekbe-menge.

  CLEAR: lv_grtot,gs_eketdata3sum-grqty.

  IF gs_eketdata3sum-matnr = t_history-matnr AND
     gs_eketdata3sum-ebeln = t_eketh-ebeln   AND
     gs_eketdata3sum-ebelp = t_eketh-ebelp   AND
     gs_eketdata3sum-sisa = t_eketh-menge.
    t_eketdata3-matnr    = t_history-matnr.
    t_eketdata3-lifnr    = t_history-lifnr.
    t_eketdata3-bsart    = t_history-bsart.
    t_eketdata3-ebeln    = t_eketh-ebeln.
    t_eketdata3-ebelp    = t_eketh-ebelp.
    t_eketdata3-eindt    = t_eketh-eindt.
    t_eketdata3-menge    = t_eketh-menge.
    t_eketdata3-budat    = gs_eketdata3sum-budat.
    t_eketdata3-grqty    = gs_eketdata3sum-sisa.
    CONCATENATE t_eketdata3-matnr t_eketdata3-lifnr INTO t_eketdata3-key.
    CLEAR gs_eketdata3sum-sisa.
    APPEND t_eketdata3. CLEAR t_eketdata3.

  ELSE.
    READ TABLE t_ekbeh_101 WITH KEY ebeln = t_eketh-ebeln
                                    ebelp = t_eketh-ebelp
                                    read_flg = space.
    IF sy-subrc = 0.
      LOOP AT t_ekbeh_101 WHERE ebeln = t_eketh-ebeln
                            AND ebelp = t_eketh-ebelp
                            AND read_flg = space.
        t_ekbeh_101-read_flg = 'X'.
        MODIFY t_ekbeh_101 TRANSPORTING read_flg.

        t_eketdata3-matnr    = t_history-matnr.
        t_eketdata3-lifnr    = t_history-lifnr.
        t_eketdata3-bsart    = t_history-bsart.
        t_eketdata3-ebeln    = t_eketh-ebeln.
        t_eketdata3-ebelp    = t_eketh-ebelp.
        t_eketdata3-eindt    = t_eketh-eindt.
        t_eketdata3-menge    = t_eketh-menge.
        t_eketdata3-budat    = t_ekbeh_101-bldat.
        t_eketdata3-grqty    = t_ekbeh_101-menge.
        CONCATENATE t_eketdata3-matnr t_eketdata3-lifnr INTO t_eketdata3-key.

*      CLEAR gt_mkpf.
*      READ TABLE gt_mkpf WITH KEY mblnr = t_ekbeh_101-belnr
*                                  mjahr = t_ekbeh_101-gjahr.
*      <fs_eketdata3sum>-budat = t_eketdata3-budat = gt_mkpf-bldat.

        LOOP AT gt_mseg WHERE lfbja = t_ekbeh_101-gjahr
                          AND lfbnr = t_ekbeh_101-belnr
                          AND lfpos = t_ekbeh_101-buzei.
          IF gt_mseg-bwart = '102'.
            IF gt_mseg-shkzg EQ 'H'.
              MULTIPLY gt_mseg-menge BY -1.
            ENDIF.
            ADD gt_mseg-menge TO t_eketdata3-grqty.
          ENDIF.
        ENDLOOP.

        IF t_eketdata3-grqty IS NOT INITIAL.
          ADD t_eketdata3-grqty TO lv_grtot.

          IF gs_eketdata3sum IS INITIAL.
            IF lv_grtot GE t_eketdata3-menge.
              t_eketdata3-sisa = lv_grtot - t_eketdata3-menge.
              t_eketdata3-grqty = t_eketdata3-menge.
              MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
              APPEND t_eketdata3. CLEAR t_eketdata3.
              EXIT.

            ELSE.
              MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
              APPEND t_eketdata3. CLEAR t_eketdata3.
            ENDIF.

          ELSE.
            IF t_eketdata3-matnr = gs_eketdata3sum-matnr AND
               t_eketdata3-ebeln = gs_eketdata3sum-ebeln AND
               t_eketdata3-ebelp = gs_eketdata3sum-ebelp.

              ADD gs_eketdata3sum-sisa TO lv_grtot.

              IF lv_grtot GE t_eketdata3-menge.
                PERFORM f_insert_from_summary.
                t_eketdata3-sisa = lv_grtot - t_eketdata3-menge.
                t_eketdata3-grqty = t_eketh-menge - gs_eketdata3sum-grqty.
                ADD t_eketdata3-grqty TO gs_eketdata3sum-grqty.
                gs_eketdata3sum-sisa = t_eketdata3-sisa.
                gs_eketdata3sum-budat = t_eketdata3-budat.
*                APPEND t_eketdata3. CLEAR t_eketdata3.
*                EXIT.
                IF t_eketdata3-sisa IS NOT INITIAL.
                  APPEND t_eketdata3. CLEAR t_eketdata3.
                  EXIT.
                ENDIF.

*              ELSEIF lv_grtot EQ t_eketdata3-menge.
*                PERFORM f_insert_from_summary.
*                t_eketdata3-sisa = lv_grtot - t_eketdata3-menge.
*                t_eketdata3-grqty = t_eketdata3-menge.
*                ADD t_eketdata3-grqty TO gs_eketdata3sum-grqty.
*                gs_eketdata3sum-sisa = t_eketdata3-sisa.
*                gs_eketdata3sum-budat = t_eketdata3-budat.
*                APPEND t_eketdata3. CLEAR t_eketdata3.
*                EXIT.

              ELSE.
                PERFORM f_insert_from_summary.
                t_eketdata3-grqty = lv_grtot - gs_eketdata3sum-grqty.
                IF t_eketdata3-grqty LE 0.
                  CLEAR t_eketdata3-grqty.
                ENDIF.
                ADD t_eketdata3-grqty TO gs_eketdata3sum-grqty.
                gs_eketdata3sum-budat = t_eketdata3-budat.
*                APPEND t_eketdata3. CLEAR t_eketdata3.
                IF t_eketdata3-sisa IS NOT INITIAL.
                  APPEND t_eketdata3. CLEAR t_eketdata3.
                ENDIF.
              ENDIF.

            ELSE.
              CLEAR gs_eketdata3sum.
              IF lv_grtot GE t_eketdata3-menge.
                t_eketdata3-sisa = lv_grtot - t_eketdata3-menge.
                t_eketdata3-grqty = t_eketdata3-menge.
                MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
                APPEND t_eketdata3. CLEAR t_eketdata3.
                EXIT.

              ELSE.
                MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
                APPEND t_eketdata3. CLEAR t_eketdata3.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ELSE.
      IF t_history-matnr = gs_eketdata3sum-matnr AND
         t_eketh-ebeln   = gs_eketdata3sum-ebeln AND
         t_eketh-ebelp   = gs_eketdata3sum-ebelp.
        t_eketdata3-matnr    = t_history-matnr.
        t_eketdata3-lifnr    = t_history-lifnr.
        t_eketdata3-bsart    = t_history-bsart.
        t_eketdata3-ebeln    = t_eketh-ebeln.
        t_eketdata3-ebelp    = t_eketh-ebelp.
        t_eketdata3-eindt    = t_eketh-eindt.
        t_eketdata3-menge    = t_eketh-menge.
        t_eketdata3-budat    = gs_eketdata3sum-budat.
        t_eketdata3-grqty    = gs_eketdata3sum-sisa.
        CONCATENATE t_eketdata3-matnr t_eketdata3-lifnr INTO t_eketdata3-key.

        IF t_eketdata3-grqty GE t_eketdata3-menge.
          t_eketdata3-sisa = t_eketdata3-grqty - t_eketdata3-menge.
          t_eketdata3-grqty = t_eketdata3-menge.
          MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
          APPEND t_eketdata3. CLEAR t_eketdata3.
          EXIT.

        ELSE.
          MOVE-CORRESPONDING t_eketdata3 TO gs_eketdata3sum.
          APPEND t_eketdata3. CLEAR t_eketdata3.
        ENDIF.
      ELSE.
        CLEAR gs_eketdata3sum.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DATA_SCORE_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_FROM_SUMMARY
*&---------------------------------------------------------------------*
FORM f_insert_from_summary .
  DATA: lv_grqty LIKE gs_eketdata3sum-grqty.

  lv_grqty = gs_eketdata3sum-grqty.

  IF gs_eketdata3sum-sisa IS NOT INITIAL.
    IF gs_eketdata3sum-sisa LE t_eketdata3-grqty.
      gs_eketdata3sum-grqty = gs_eketdata3sum-sisa.
      gs_eketdata3sum-sisa  = 0.
    ELSE.
      gs_eketdata3sum-grqty = t_eketdata3-grqty.
      SUBTRACT gs_eketdata3sum-grqty FROM gs_eketdata3sum-sisa.
    ENDIF.
  ELSE.
    gs_eketdata3sum-budat = t_eketdata3-budat.
    gs_eketdata3sum-grqty = t_eketdata3-grqty.
  ENDIF.
  gs_eketdata3sum-eindt = t_eketdata3-eindt.
  gs_eketdata3sum-menge = t_eketdata3-menge.
  APPEND gs_eketdata3sum TO t_eketdata3.

  ADD  lv_grqty TO gs_eketdata3sum-grqty.
ENDFORM.                    " F_INSERT_FROM_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_GET_HARGA
*&---------------------------------------------------------------------*
FORM f_get_harga  USING    fu_matnr
                           fu_lifnr
                           fu_inco1
                           fu_eina_inco1
                  CHANGING fu_harga
                           fu_waers.
  DATA: lv_harga LIKE konp-kbetr.
  DATA: lv_inco1 LIKE ekko-inco1.

  SORT gt_a018 BY matnr lifnr knumh DESCENDING.

  CLEAR: gr_eindt3m,gt_a018,gt_konph.
  READ TABLE gr_eindt3m INDEX 1.
  READ TABLE gt_a018 WITH KEY matnr = fu_matnr
                              lifnr = fu_lifnr
                              BINARY SEARCH.
  IF sy-subrc = 0.
    READ TABLE gt_konph WITH KEY knumh = gt_a018-knumh.
    IF sy-subrc = 0.
*      IF gt_konph-konwa NE 'IDR'.
      IF gt_konph-konwa NE fu_waers.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = sy-datum
            foreign_amount   = gt_konph-kbetr
            foreign_currency = gt_konph-konwa
            local_currency   = fu_waers
          IMPORTING
            local_amount     = lv_harga
          EXCEPTIONS
            no_rate_found    = 1
            overflow         = 2
            no_factors_found = 3
            no_spread_found  = 4
            derived_2_times  = 5
            OTHERS           = 6.

        IF fu_waers = 'IDR'.
          fu_harga = lv_harga * 100 / gt_konph-kpein.
        ELSE.
          fu_harga = lv_harga / gt_konph-kpein.
        ENDIF.

      ELSE.
        IF fu_waers = 'IDR'.
          fu_harga = gt_konph-kbetr * 100 / gt_konph-kpein.
        ELSE.
          fu_harga = gt_konph-kbetr / gt_konph-kpein.
        ENDIF.
      ENDIF.
*      fu_waers = 'IDR'.
    ENDIF.
  ENDIF.

  CLEAR lv_inco1.
*  PERFORM f_koreksi_inco1 USING fu_matnr
*                                fu_lifnr
*                                gt_a018-knumh
*                          CHANGING lv_inco1.
  lv_inco1 = fu_eina_inco1.

*  PERFORM f_konversi_incoterm USING gt_eina-inco1 fu_inco1
  PERFORM f_konversi_incoterm USING lv_inco1 fu_inco1
                              CHANGING fu_harga.
ENDFORM.                    " F_GET_HARGA

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0100 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_print_popup.
ENDMODULE.                 " LIST_PROCESSING_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_POPUP
*&---------------------------------------------------------------------*
FORM f_print_popup .
  DATA: ls_out LIKE LINE OF t_out.

  READ TABLE t_out INTO ls_out INDEX gv_index.
  CASE gv_fieldname.
    WHEN 'SCORQUAL'.
      LOOP AT t_eketh WHERE matnr  = ls_out-matnr
                         AND lifnr = ls_out-lifnr
                         AND eindt LE p_assdt
                         AND eindt NOT IN gr_eindt2m.
*        IF t_eketh-eindt NOT IN gr_eindt2m.
        WRITE:/ sy-vline NO-GAP, (10) t_eketh-ebeln NO-GAP,
                sy-vline NO-GAP,  (5) t_eketh-ebelp NO-GAP,
                sy-vline NO-GAP, (10) t_eketh-eindt NO-GAP,
*                sy-vline NO-GAP, (10) t_eketh-matnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-maktx NO-GAP,
*                sy-vline NO-GAP, (10) t_eketh-lifnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-name1 NO-GAP,
                sy-vline NO-GAP, (15) t_eketh-menge NO-GAP,
                sy-vline NO-GAP.
*        ENDIF.
      ENDLOOP.
      ULINE AT /(45).
    WHEN 'SCORQTY'.
      LOOP AT t_eketdata2 WHERE matnr = ls_out-matnr
                            AND lifnr = ls_out-lifnr.
        WRITE:/ sy-vline NO-GAP, (10) t_eketdata2-ebeln NO-GAP,
                sy-vline NO-GAP,  (5) t_eketdata2-ebelp NO-GAP,
                sy-vline NO-GAP, (10) t_eketdata2-eindt NO-GAP,
*                sy-vline NO-GAP, (10) t_eketdata2-matnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-maktx NO-GAP,
*                sy-vline NO-GAP, (10) t_eketdata2-lifnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-name1 NO-GAP,
                sy-vline NO-GAP, (15) t_eketdata2-menge NO-GAP,
                sy-vline NO-GAP.
      ENDLOOP.
      ULINE AT /(45).
    WHEN 'SCORD'.
      LOOP AT t_eketdata3 WHERE matnr = ls_out-matnr
                            AND lifnr = ls_out-lifnr.
        IF t_eketdata3-eindt IN gr_eindt3m.
          WRITE:/ sy-vline NO-GAP, (10) t_eketdata3-ebeln NO-GAP,
                  sy-vline NO-GAP,  (5) t_eketdata3-ebelp NO-GAP,
                  sy-vline NO-GAP, (10) t_eketdata3-eindt NO-GAP,
                  sy-vline NO-GAP, (10) t_eketdata3-budat NO-GAP,
*                sy-vline NO-GAP, (10) t_eketdata3-matnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-maktx NO-GAP,
*                sy-vline NO-GAP, (10) t_eketdata3-lifnr NO-GAP,
*                sy-vline NO-GAP, (40) ls_out-name1 NO-GAP,
                  sy-vline NO-GAP, (15) t_eketdata3-grqty NO-GAP,
                  sy-vline NO-GAP, (15) t_eketdata3-menge NO-GAP,
                  sy-vline NO-GAP.
        ENDIF.
      ENDLOOP.
      ULINE AT /(72).
  ENDCASE.
ENDFORM.                    " F_PRINT_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_CEK_CANCEL_102
*&---------------------------------------------------------------------*
FORM f_cek_cancel_102 .
  DATA: lt_ekbeh LIKE TABLE OF t_ekbeh WITH HEADER LINE.

  lt_ekbeh[] = t_ekbeh[].
  DELETE lt_ekbeh WHERE bwart NE '102'.

  LOOP AT t_ekbeh WHERE bwart = '101'.
    CLEAR lt_ekbeh.
    READ TABLE lt_ekbeh WITH KEY lfgja = t_ekbeh-gjahr
                                 lfbnr = t_ekbeh-belnr
                                 lfpos = t_ekbeh-buzei.
    IF sy-subrc = 0.
      DELETE t_ekbeh.                                 "Delete 101
      DELETE t_ekbeh WHERE ebeln = lt_ekbeh-ebeln     "Delete 102
                       AND ebelp = lt_ekbeh-ebelp
                       AND zekkn = lt_ekbeh-zekkn
                       AND vgabe = lt_ekbeh-vgabe
                       AND gjahr = lt_ekbeh-gjahr
                       AND belnr = lt_ekbeh-belnr
                       AND buzei = lt_ekbeh-buzei
                       AND bwart = lt_ekbeh-bwart.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CEK_CANCEL_102

*&---------------------------------------------------------------------*
*&      Form  F_GET_EINDT
*&---------------------------------------------------------------------*
FORM f_get_eindt  USING fu_month
                        fu_date.
  DATA: lv_datum TYPE datum.

  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
*     DAYS              = '0'
      months            = fu_month
      start_date        = fu_date
    IMPORTING
      result_date       = lv_datum.

  CLEAR: so_eindt,so_eindt[].
  so_eindt-sign   = 'I'.
  so_eindt-option = 'BT'.
  so_eindt-low    = lv_datum.
  so_eindt-high   = fu_date.
  APPEND so_eindt.
ENDFORM.                    " F_GET_EINDT

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_FROM_EINA
*&---------------------------------------------------------------------*
FORM f_insert_from_eina .
  DATA: lv_matnr TYPE matnr,
        lv_mpn   TYPE matnr,
        lt_eina  LIKE gt_eina OCCURS 0 WITH HEADER LINE.

  SELECT matnr maktx
    FROM makt
    APPENDING CORRESPONDING FIELDS OF TABLE t_makt
    FOR ALL ENTRIES IN gt_eina
    WHERE matnr EQ gt_eina-matnr AND
          spras EQ sy-langu.

  SELECT a~lifnr b~name1
    FROM lfa1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO CORRESPONDING FIELDS OF TABLE t_adrc
    FOR ALL ENTRIES IN gt_eina
    WHERE a~lifnr EQ gt_eina-lifnr.

  lt_eina[] = gt_eina[].
  SORT lt_eina BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_eina COMPARING lifnr.
  IF lt_eina[] IS NOT INITIAL.
    SELECT lifnr zterm ekorg
      FROM lfm1
      APPENDING CORRESPONDING FIELDS OF TABLE t_zterm
      FOR ALL ENTRIES IN lt_eina
      WHERE lifnr EQ lt_eina-lifnr.
  ENDIF.

  LOOP AT gt_eina.
    READ TABLE gt_mara WITH KEY matnr = gt_eina-matnr.
    IF sy-subrc = 0 AND gt_mara-mprof = 'Z001'.
      CONTINUE.
    ENDIF.

    CLEAR: lv_matnr,lv_mpn.
    SPLIT gt_eina-matnr AT '-' INTO lv_matnr lv_mpn.
    READ TABLE t_out WITH KEY matnr = lv_matnr
                              lifnr = gt_eina-lifnr
                              TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_eipa WITH KEY infnr = gt_eina-infnr.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO t_out ASSIGNING <fs_out>.

      CLEAR: t_makt,t_adrc.
      READ TABLE t_makt WITH KEY matnr = lv_matnr.      "gt_eina-matnr.
      READ TABLE t_adrc WITH KEY lifnr = gt_eina-lifnr.

      <fs_out>-matnr = lv_matnr.        "gt_eina-matnr.
      <fs_out>-maktx = t_makt-maktx.
      <fs_out>-lifnr = gt_eina-lifnr.
      <fs_out>-name1 = t_adrc-name1.
      <fs_out>-sysdat = sy-datum.

      PERFORM f_get_budget_price  USING    'X'
                                           <fs_out>-matnr
                                           ' '
                                  CHANGING <fs_out>-waers
                                           <fs_out>-budget
                                           <fs_out>-inco1.

      PERFORM f_get_harga USING    gt_eina-matnr    "<fs_out>-matnr
                                   <fs_out>-lifnr
                                   <fs_out>-inco1
                                   gt_eina-inco1
                          CHANGING <fs_out>-harga
                                   <fs_out>-waers.

      IF <fs_out>-harga IS NOT INITIAL.
        <fs_out>-scorh = ( <fs_out>-budget / <fs_out>-harga ) * pa_hrgn.
      ELSE.
        CLEAR: <fs_out>-scorh.
      ENDIF.
      <fs_out>-hrgab = <fs_out>-scorh * pa_hrgb.

      READ TABLE t_zterm WITH KEY lifnr = gt_eina-lifnr
                                  ekorg = gt_eina-ekorg.
      IF sy-subrc EQ 0.
        <fs_out>-zterm = t_zterm-zterm.
      ELSE.
        CLEAR: <fs_out>-zterm.
      ENDIF.

      READ TABLE t_zt052 WITH KEY zterm = <fs_out>-zterm.
      IF sy-subrc EQ 0.
        CASE t_zt052-gbtop.
          WHEN 5.
            <fs_out>-bobottop  = pa_term * pa_top1.
          WHEN 6.
            <fs_out>-bobottop  = pa_term * pa_top2.
          WHEN 7.
            <fs_out>-bobottop  = pa_term * pa_top3.
          WHEN 8.
            <fs_out>-bobottop  = pa_term * pa_top4.
          WHEN 9.
            <fs_out>-bobottop  = pa_term * pa_top5.
        ENDCASE.
      ENDIF.

      <fs_out>-bobottotal = <fs_out>-hrgab + <fs_out>-bqual + <fs_out>-bdelv +
                            <fs_out>-bobotqty + <fs_out>-bobottop + <fs_out>-bqtyreal +
                            <fs_out>-bamtr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_INSERT_FROM_EINA

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_BUDGET
*&---------------------------------------------------------------------*
FORM f_select_budget .
  CLEAR gr_eindt3m.
  READ TABLE gr_eindt3m INDEX 1.

  SELECT matnr knumh
    INTO CORRESPONDING FIELDS OF TABLE gt_a049
    FROM a049
    WHERE kappl EQ 'M'      AND
          kschl EQ 'ZBGT'   AND
          ekorg EQ 'TNT'    AND
          esokz EQ '0'      AND
          matnr IN so_matnr AND
          datbi GE gr_eindt3m-low AND
          datab LE gr_eindt3m-high.
  IF sy-subrc EQ 0.
    SELECT knumh kbetr kpein konwa
      INTO CORRESPONDING FIELDS OF TABLE gt_konpb
      FROM konp FOR ALL ENTRIES IN gt_a049
      WHERE knumh EQ gt_a049-knumh AND
            kopos EQ '1'.
  ENDIF.

  SELECT matnr inco1 knumh
    INTO CORRESPONDING FIELDS OF TABLE gt_a501
    FROM a501
    WHERE kappl EQ 'M'      AND
          kschl EQ 'ZBGT'   AND
          ekorg EQ 'TNT'    AND
          esokz EQ '0'      AND
          matnr IN so_matnr AND
          datbi GE gr_eindt3m-low AND
          datab LE gr_eindt3m-high.
  IF sy-subrc EQ 0.
    SELECT knumh kbetr kpein konwa
      INTO CORRESPONDING FIELDS OF TABLE gt_konpb2
      FROM konp FOR ALL ENTRIES IN gt_a501
      WHERE knumh EQ gt_a501-knumh AND
            kopos EQ '1'.
  ENDIF.
ENDFORM.                    " F_SELECT_BUDGET

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_HARGA
*&---------------------------------------------------------------------*
FORM f_select_harga .
  CLEAR gr_eindt3m.
  READ TABLE gr_eindt3m INDEX 1.

  SELECT * INTO TABLE gt_a018
    FROM a018 WHERE kappl = 'M'
                AND lifnr IN so_lifnr
                AND matnr IN gr_matmpn      "so_matnr
                AND ekorg = 'TNT'
                AND datbi GE gr_eindt3m-low
                AND datab LE gr_eindt3m-high.
  IF sy-subrc = 0.
    SELECT * INTO TABLE gt_konph
      FROM konp FOR ALL ENTRIES IN gt_a018
      WHERE knumh = gt_a018-knumh.
  ENDIF.
ENDFORM.                    " F_SELECT_HARGA

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_MPN_MATERIAL
*&---------------------------------------------------------------------*
FORM f_append_mpn_material .
  APPEND LINES OF so_matnr TO gr_matmpn.

  SELECT matnr mprof
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
    FROM mara WHERE matnr IN so_matnr
                AND mprof EQ 'Z001'.

  IF gt_mara[] IS NOT INITIAL.
    LOOP AT gt_mara.
      CLEAR gr_matmpn.
      gr_matmpn-sign = 'I'.
      gr_matmpn-option = 'CP'.
      CONCATENATE gt_mara-matnr '-MPN*' INTO gr_matmpn-low.
      APPEND gr_matmpn.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_APPEND_MPN_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_EINA
*&---------------------------------------------------------------------*
FORM f_get_material_eina  USING    fu_matnr
                                   fu_lifnr
                          CHANGING fc_matnr
                                   fc_lifnr.
  DATA: lv_len TYPE numc2.

  lv_len = STRLEN( fu_matnr ).
  SORT gt_eina BY infnr DESCENDING matnr lifnr.
  LOOP AT gt_eina.
    IF gt_eina-matnr(lv_len) = fu_matnr AND
       gt_eina-lifnr = fu_lifnr.
      fc_matnr = gt_eina-matnr.
      fc_lifnr = gt_eina-lifnr.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_MATERIAL_EINA

*&---------------------------------------------------------------------*
*&      Form  F_GET_HARGA_MPN
*&---------------------------------------------------------------------*
FORM f_get_harga_mpn  USING    fu_matnr
                               fu_lifnr
                      CHANGING fu_harga
                               fu_waers.
  DATA: lv_harga LIKE konp-kbetr.
  DATA: lv_len   TYPE numc2.
  DATA: ls_a018  LIKE a018.

  lv_len = STRLEN( fu_matnr ).
  SORT gt_a018 BY datab DESCENDING datbi DESCENDING matnr lifnr.
  LOOP AT gt_a018.
    IF gt_a018-matnr(lv_len) = fu_matnr AND
       gt_a018-lifnr = fu_lifnr.
      MOVE-CORRESPONDING gt_a018 TO ls_a018.
      EXIT.
    ENDIF.
  ENDLOOP.

  CLEAR: gr_eindt3m,gt_a018,gt_konph.
  READ TABLE gr_eindt3m INDEX 1.
*  READ TABLE gt_a018 WITH KEY matnr = fu_matnr
*                              lifnr = fu_lifnr
*                              BINARY SEARCH.
*  IF sy-subrc = 0.
  IF ls_a018 IS NOT INITIAL.
    READ TABLE gt_konph WITH KEY knumh = ls_a018-knumh.
    IF sy-subrc = 0.
*      IF gt_konph-konwa NE 'IDR'.
      IF gt_konph-konwa NE fu_waers.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = sy-datum
            foreign_amount   = gt_konph-kbetr
            foreign_currency = gt_konph-konwa
            local_currency   = fu_waers           "'IDR'
          IMPORTING
            local_amount     = lv_harga
          EXCEPTIONS
            no_rate_found    = 1
            overflow         = 2
            no_factors_found = 3
            no_spread_found  = 4
            derived_2_times  = 5
            OTHERS           = 6.

        IF fu_waers = 'IDR'.
          fu_harga = lv_harga * 100 / gt_konph-kpein.
        ELSE.
          fu_harga = lv_harga / gt_konph-kpein.
        ENDIF.

      ELSE.
        IF fu_waers = 'IDR'.
          fu_harga = gt_konph-kbetr * 100 / gt_konph-kpein.
        ELSE.
          fu_harga = gt_konph-kbetr / gt_konph-kpein.
        ENDIF.
      ENDIF.
*      fu_waers = 'IDR'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_HARGA_MPN

*&---------------------------------------------------------------------*
*&      Form  F_KONVERSI_INCOTERM
*&---------------------------------------------------------------------*
FORM f_konversi_incoterm  USING    fu_inco1 fu_inco1a
                          CHANGING fc_harga.
  DATA: lt_zvend_eval TYPE TABLE OF zvend_eval WITH HEADER LINE,
        lv_count      TYPE numc1,
        lv_field      TYPE char20,
        lv_inco1      TYPE inco1,
        lv_desc1      TYPE zdesc2,
        lv_desc2      TYPE zdesc2.

  FIELD-SYMBOLS: <fs_inco> TYPE ANY.

  IF fu_inco1a IS NOT INITIAL.
    IF fu_inco1 IS INITIAL.
      lv_inco1 = 'Landed'.
    ELSE.
      lv_inco1 = fu_inco1.
    ENDIF.

    lt_zvend_eval[] = t_zvend_eval[].
    DELETE lt_zvend_eval WHERE zline(2) NE '02'.
    LOOP AT lt_zvend_eval.
      ADD 1 TO lv_count.
      CLEAR: lv_desc1,lv_desc2.
      SPLIT lt_zvend_eval-description AT 'to' INTO lv_desc1 lv_desc2.

      IF lv_desc1 CS lv_inco1 AND lv_desc2 CS fu_inco1a.
        CONCATENATE 'PA_INCO' lv_count INTO lv_field.
        ASSIGN (lv_field) TO <fs_inco>.
*        fc_harga = fc_harga * lt_zvend_eval-nilai / 100.
        fc_harga = fc_harga * <fs_inco> / 100.
      ENDIF.
    ENDLOOP.
  ENDIF.
  UNASSIGN <fs_inco>.
ENDFORM.                    " F_KONVERSI_INCOTERM

*&---------------------------------------------------------------------*
*&      Form  F_KOREKSI_INCO1
*&---------------------------------------------------------------------*
FORM f_koreksi_inco1  USING    fu_matnr
                               fu_lifnr
                               fu_knumh
                      CHANGING fc_inco1.
  DATA: lt_history LIKE t_history OCCURS 0 WITH HEADER LINE,
        lt_eketh   LIKE t_eketh OCCURS 0 WITH HEADER LINE,
        lt_ekko TYPE TABLE OF ekko WITH HEADER LINE.

  lt_history[] = t_history[].
  DELETE lt_history WHERE matnr NE fu_matnr
                      AND lifnr NE fu_lifnr.

  IF lt_history[] IS NOT INITIAL.
    SELECT ebeln inco1 knumv
      INTO CORRESPONDING FIELDS OF TABLE lt_ekko
      FROM ekko FOR ALL ENTRIES IN lt_history
      WHERE ebeln = lt_history-ebeln.
    IF sy-subrc = 0.
      PERFORM f_get_inco1 TABLES lt_ekko
                          USING  fu_knumh
                          CHANGING fc_inco1.

    ELSE.
      lt_eketh[] = t_eketh[].
      DELETE lt_eketh WHERE matnr NE fu_matnr
                        AND lifnr NE fu_lifnr.

      IF lt_eketh[] IS NOT INITIAL.
        SELECT ebeln inco1 knumv
          INTO CORRESPONDING FIELDS OF TABLE lt_ekko
          FROM ekko FOR ALL ENTRIES IN lt_eketh
          WHERE ebeln = lt_eketh-ebeln.
        IF sy-subrc = 0.
          PERFORM f_get_inco1 TABLES lt_ekko
                              USING  fu_knumh
                              CHANGING fc_inco1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_KOREKSI_INCO1

*&---------------------------------------------------------------------*
*&      Form  F_GET_INCO1
*&---------------------------------------------------------------------*
FORM f_get_inco1  TABLES   ft_ekko STRUCTURE ekko
                  USING    fu_knumh
                  CHANGING fc_inco1.
  DATA: lt_konv TYPE TABLE OF konv WITH HEADER LINE,
        ls_ekko LIKE ekko.

  SELECT knumv kposn stunr zaehk kschl kdatu knumh
    INTO CORRESPONDING FIELDS OF TABLE lt_konv
    FROM konv FOR ALL ENTRIES IN ft_ekko
    WHERE knumv = ft_ekko-knumv
      AND knumh = fu_knumh.
  IF sy-subrc = 0.
    SORT lt_konv BY knumv DESCENDING.
    CLEAR: lt_konv,ls_ekko.
    READ TABLE lt_konv INDEX 1.
    READ TABLE ft_ekko INTO ls_ekko WITH KEY knumv = lt_konv-knumv.
    fc_inco1 = ls_ekko-inco1.
  ENDIF.
ENDFORM.                    " F_GET_INCO1
