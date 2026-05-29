*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  PERFORM f_get_order_number.
  PERFORM f_get_po.
  PERFORM f_get_material.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

*  gt_main_tmp[] = gt_main[].
*  ASSIGN gt_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES <fs_table>.
  PERFORM f_write_list1.

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
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

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

ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'WERKS' 'T001W' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '',
    'SPMON' 'S603' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
    'BSTFE' 'MARC' 'BSTFE' '' '' 'Batch Size' '' '' '' '' '' '' '' '',
    'WIPBCH' 'MARC' 'BSTFE' '' '' 'WIP Batch' '' '' '' '' '' '' '' '',
    'WIPMG' 'MARC' 'BSTFE' '' '' 'WIP Total' '' '' '' '' '' '' '' '',
    'CHARG' 'AFKO' 'CHARG' '' '' 'Batch No.' '' '' '' '' '' '' '' '',
    'AUFNR' 'AFKO' 'AUFNR' '' '' '' '' '' '' '' '' '' '' ''.

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
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.

ENDFORM.                    "f_build_layout

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
  ld_sort-fieldname = 'WERKS'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'SPMON'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: ld_plant(100).

  CONCATENATE p_werks gd_werks_name INTO ld_plant
                                    SEPARATED BY ' - '.
  CONCATENATE 'Plant:' ld_plant INTO ld_plant SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ld_plant.
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
  CASE 'X'.
    WHEN r_prev.
      PERFORM f_process_data_prev.
    WHEN r_curr.
      PERFORM f_process_data_curr.
    WHEN OTHERS.
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
    WHEN '&POS'.
      PERFORM f_post_entries.
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
*&      Form  F_INIT_SPMON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_spmon .
  DATA: ld_date TYPE datum.

  CASE 'X'.
    WHEN r_prev.
      CONCATENATE sy-datum(6) '01' INTO gd_month_end.

      CALL FUNCTION 'Z_CALC_DATE'
        EXPORTING
          date      = gd_month_end
          days      = '0'
          months    = '12'
          sign      = '-'
          years     = '0'
        IMPORTING
          calc_date = gd_month_beg.

      SUBTRACT 1 FROM gd_month_end.
      p_spmon = gd_month_end(6).

    WHEN r_curr.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = sy-datum
        IMPORTING
          last_day_of_month = gd_month_end.

      CALL FUNCTION 'Z_CALC_DATE'
        EXPORTING
          date      = gd_month_end
          days      = '0'
          months    = '12'
          sign      = '-'
          years     = '0'
        IMPORTING
          calc_date = gd_month_beg.

      p_spmon = gd_month_end(6).

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_INIT_SPMON

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_order_number .
  CASE 'X'.
    WHEN r_prev.
      SELECT * INTO TABLE gt_t007
        FROM zdgppedt007
        WHERE ordty EQ 'PP'
          AND werks EQ p_werks
          AND matnr IN s_matnr
          AND gltrp BETWEEN gd_month_beg AND gd_month_end.
      IF sy-subrc = 0.
        LOOP AT gt_t007.
          MOVE-CORRESPONDING gt_t007 TO gt_aufk.
          APPEND gt_aufk.
        ENDLOOP.
      ENDIF.

    WHEN r_curr.
* Get order by plant
      SELECT a~aufnr werks INTO TABLE gt_aufk
        FROM aufk AS a JOIN afko AS b ON b~aufnr = a~aufnr
        WHERE autyp = c_autyp
          AND werks = p_werks
          AND gltrp BETWEEN gd_month_beg AND gd_month_end
          AND plnbez IN s_matnr.

      IF r_curr IS NOT INITIAL.
* Concatenate order to object no.
        LOOP AT gt_aufk ASSIGNING <fs_aufk>.
          CONCATENATE 'OR' <fs_aufk>-aufnr INTO <fs_aufk>-objnr.
        ENDLOOP.

* Get order TECO
        IF gt_aufk[] IS NOT INITIAL.
          SELECT * INTO TABLE gt_jest
            FROM jest FOR ALL ENTRIES IN gt_aufk
            WHERE objnr =  gt_aufk-objnr
              AND stat  IN (c_teco,c_dlfl)
              AND inact =  space.
        ENDIF.

* Delete order TECO
        SORT gt_aufk BY objnr.
        SORT gt_jest BY objnr.
        LOOP AT gt_aufk.
          READ TABLE gt_jest INTO wa_jest WITH KEY objnr = gt_aufk-objnr
                             BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE gt_aufk.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

* Get order header & detail
  IF gt_aufk[] IS NOT INITIAL.
    SELECT a~aufnr gltrp posnr psmng wemng matnr charg
      INTO TABLE gt_afko
      FROM afko AS a JOIN afpo AS b ON b~aufnr = a~aufnr
      FOR ALL ENTRIES IN gt_aufk
      WHERE a~aufnr = gt_aufk-aufnr
*        AND gltrp BETWEEN gd_month_beg AND gd_month_end
        AND matnr IN s_matnr.
  ENDIF.

* Completed itab AFKO
  SORT gt_aufk BY aufnr.
  SORT gt_afko BY aufnr.
  SORT gt_t007 BY aufnr.
  LOOP AT gt_afko ASSIGNING <fs_afko>.
    CLEAR: gt_aufk,gt_t007.
    READ TABLE gt_aufk WITH KEY aufnr = <fs_afko>-aufnr.
    READ TABLE gt_t007 WITH KEY aufnr = <fs_afko>-aufnr.
    <fs_afko>-werks =  gt_aufk-werks.

    CASE 'X'.
      WHEN r_prev.
        <fs_afko>-spmon = gt_t007-gltrp(6).
      WHEN r_curr.
        <fs_afko>-spmon = <fs_afko>-gltrp(6).
    ENDCASE.

    gt_matnr-matnr = <fs_afko>-matnr.
    COLLECT gt_matnr.
  ENDLOOP.
ENDFORM.                    " F_GET_ORDER_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_material .
  IF gt_matnr[] IS NOT INITIAL.
    SELECT a~matnr maktx meins INTO TABLE gt_mara
      FROM mara AS a JOIN makt AS b ON b~matnr = a~matnr
      FOR ALL ENTRIES IN gt_matnr
      WHERE a~matnr = gt_matnr-matnr AND
            mtart = c_zpha          AND
            spras = sy-langu.

    SELECT matnr werks bstfe INTO TABLE gt_marc
      FROM marc FOR ALL ENTRIES IN gt_matnr
      WHERE matnr = gt_matnr-matnr AND
            werks = p_werks.

    SELECT * INTO TABLE gt_t003
      FROM zdgppedt003 FOR ALL ENTRIES IN gt_matnr
      WHERE matnr = gt_matnr-matnr AND
            werks = p_werks      AND
            pdatu BETWEEN gd_month_beg AND gd_month_end.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_werks .
*  DATA: lt_t001w LIKE t001w OCCURS 0 WITH HEADER LINE.
*
*  IF p_werks = '0101' OR p_werks = '0102' OR
*     p_werks = '0901' OR p_werks = '3600'.
*    SELECT SINGLE name1 INTO gd_werks_name
*      FROM t001w WHERE werks = p_werks.
*  ELSE.
*    MESSAGE 'Only for plant 0101, 0102, 0901, 3600' TYPE 'E'.
*  ENDIF.
ENDFORM.                    " F_VALIDATE_WERKS

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_append_itab_main .
  DATA: ld_percen TYPE wewrt,
        ld_wipmg  TYPE zwipmg.

  CLEAR gt_marc.
  READ TABLE gt_marc WITH KEY matnr = gt_main-matnr
                              werks = gt_main-werks.
  gt_main-bstfe = gt_marc-bstfe.

*  IF gt_main-bstfe IS NOT INITIAL.
*    gt_main-wipbch = gt_main-wipmg / gt_main-bstfe.
*  ENDIF.

  TRY .
      gt_main-wipbch = gt_main-wipmg / gt_main-bstfe.
    CATCH cx_sy_zerodivide.

  ENDTRY.

  LOOP AT gt_afko WHERE matnr = gt_main-matnr AND
                        spmon = gt_main-spmon.

    IF r_curr IS NOT INITIAL.
* Hitung percen & WIP
      CLEAR: ld_percen,ld_wipmg.
      ld_percen = gt_afko-wemng / gt_afko-psmng * 100.
      ld_wipmg = gt_afko-psmng - gt_afko-wemng.

* Hanya untuk yg percen lebih kecil dr 75% dan WIP lebih besar dr 0
      IF ld_percen LT 75 AND ld_wipmg GT 0.
        gt_main-charg = gt_afko-charg.
        gt_main-aufnr = gt_afko-aufnr.
        gt_main-aufnr1 = gt_main-aufnr.
        gt_main-wipmgdtl = gt_main-wipmg.
        APPEND gt_main.

      ELSE.
        CONTINUE.
      ENDIF.

    ELSE.
      gt_main-charg = gt_afko-charg.
      gt_main-aufnr = gt_afko-aufnr.
      CLEAR gt_t007.
      READ TABLE gt_t007 WITH KEY ordty = 'PP'
                                  aufnr = gt_main-aufnr.
      gt_main-wipmgdtl = gt_t007-wipmg.
      gt_main-aufnr1 = gt_main-aufnr.
      APPEND gt_main.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_ekpo WHERE matnr = gt_main-matnr AND
                        spmon = gt_main-spmon.

    IF r_curr IS NOT INITIAL.
* Hitung percen & WIP
      CLEAR: ld_percen,ld_wipmg.
      ld_percen = gt_ekpo-wemng / gt_ekpo-menge * 100.
      ld_wipmg = gt_ekpo-menge - gt_ekpo-wemng.

* Hanya untuk yg percen lebih kecil dr 75% dan WIP lebih besar dr 0
      IF ld_percen LT 75 AND ld_wipmg GT 0.
*        gt_main-charg = gt_afko-charg.
        gt_main-aufnr = gt_ekpo-ebeln.
        gt_main-ebelp = gt_ekpo-ebelp.
        CONCATENATE gt_main-aufnr gt_main-ebelp INTO gt_main-aufnr1 SEPARATED BY space.
        gt_main-wipmgdtl = gt_main-wipmg.
        APPEND gt_main.

      ELSE.
        CONTINUE.
      ENDIF.

    ELSE.
      gt_main-charg = gt_ekpo-charg.
      gt_main-aufnr = gt_ekpo-ebeln.
      gt_main-ebelp = gt_ekpo-ebelp.
      CLEAR gt_t007.
      READ TABLE gt_t007 WITH KEY ordty = 'PO'
                                  aufnr = gt_main-aufnr
                                  ebelp = gt_main-ebelp.
      IF sy-subrc = 0.
        gt_main-wipmgdtl = gt_t007-wipmg.
        CONCATENATE gt_main-aufnr gt_main-ebelp INTO gt_main-aufnr1 SEPARATED BY '/'.
        APPEND gt_main.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR: gt_main-werks,gt_main-spmon,gt_main-bstfe,gt_main-wipmg,
         gt_main-wipbch,gt_main-charg,gt_main-aufnr,gt_main-aufnr1.
ENDFORM.                    " F_APPEND_ITAB_MAIN

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LIST1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_list1 .
  DATA: ld_sw1(1),
        ld_sw2(1),
        ld_sw3(1).

  SORT gt_main BY werks matnr spmon charg.
  LOOP AT gt_main.
    AT NEW matnr.
      ld_sw1 = 'X'.
      WRITE: / '|', (12)gt_main-matnr, '|',
                        gt_main-maktx, '|',
                        gt_main-meins, '|'.
    ENDAT.

    AT NEW spmon.
      IF ld_sw1 IS INITIAL.
        PERFORM f_write_blanks USING 'SPMON'.
        ld_sw2 = 'X'.
      ENDIF.
      WRITE: AT 67 gt_main-spmon, '|',
                   gt_main-bstfe, '|',
                   (10)gt_main-wipbch, '|',
                   gt_main-wipmg, '|'.
    ENDAT.

    IF ld_sw1 IS INITIAL AND ld_sw2 IS INITIAL.
      PERFORM f_write_blanks USING 'DETAIL'.
    ENDIF.
    CLEAR: ld_sw1,ld_sw2.
    WRITE: AT 130 gt_main-charg, '|',
*                  gt_main-aufnr, '|',
                  gt_main-aufnr1, '|',
                  gt_main-wipmgdtl, '|'.
    AT END OF matnr.
      WRITE sy-uline.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_WRITE_LIST1

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sub_header .
  WRITE: / '|', (12)'Material' CENTERED, '|',
                (40)'Description' CENTERED, '|',
                 (3)'UoM', '|',
                 (7)'Month' CENTERED, '|',
                (17)'Batch Size' CENTERED, '|',
                (10)'WIP Batch' CENTERED, '|',
                (17)'WIP Total' CENTERED, '|',
                (10)'Batch No.' CENTERED, '|',
                (16)'Order No.' CENTERED, '|',
                (17)'WIP Quantity' CENTERED, '|'.
  WRITE / sy-uline.
ENDFORM.                    " F_SUB_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_BLANKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPE   text
*----------------------------------------------------------------------*
FORM f_write_blanks  USING    fu_type.
  CASE fu_type.
    WHEN 'SPMON'.
      WRITE: / '|', (12)'', '|',
                    (40)'', '|',
                     (3)'', '|'.
    WHEN 'DETAIL'.
      WRITE: / '|', (12)'', '|',
                    (40)'', '|',
                     (3)'', '|',
                     (7)'', '|',
                    (17)'', '|',
                    (10)'', '|',
                    (17)'', '|'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_WRITE_BLANKS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_PREV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_prev .
  DATA: ld_spmon TYPE spmon.

  SORT gt_mara BY matnr.
  SORT gt_marc BY matnr werks.
  SORT gt_t003 BY matnr werks pdatu.
  SORT gt_afko BY matnr werks spmon gltrp.
  SORT gt_ekpo BY matnr werks spmon eindt.

  LOOP AT gt_mara.

    CLEAR: ld_spmon.
    gt_main-matnr = gt_mara-matnr.
    gt_main-maktx = gt_mara-maktx.
    gt_main-meins = gt_mara-meins.

    LOOP AT gt_t003 WHERE matnr = gt_main-matnr.

      IF gt_t003-wipmg IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ld_spmon IS INITIAL.
        ld_spmon = gt_main-spmon = gt_t003-pdatu(6).
        gt_main-werks = gt_t003-werks.
        gt_main-wipmg = gt_t003-wipmg.
      ELSE.
        IF ld_spmon = gt_t003-pdatu(6).
          ADD gt_t003-wipmg TO gt_main-wipmg.
        ELSE.
          PERFORM f_append_itab_main.
          ld_spmon = gt_main-spmon = gt_t003-pdatu(6).
          gt_main-werks = gt_t003-werks.
          gt_main-wipmg = gt_t003-wipmg.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF ld_spmon IS NOT INITIAL.
      PERFORM f_append_itab_main.
    ENDIF.
    CLEAR gt_main.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_PREV

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_CURR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_curr .
  DATA: ld_spmon TYPE spmon,
        ld_percen TYPE wewrt,
        ld_wipmg  TYPE zwipmg.

  SORT gt_mara BY matnr.
  SORT gt_marc BY matnr werks.
  SORT gt_t003 BY matnr werks pdatu.
  SORT gt_afko BY matnr werks spmon gltrp.

  LOOP AT gt_mara.

    CLEAR: ld_spmon.
    gt_main-matnr = gt_mara-matnr.
    gt_main-maktx = gt_mara-maktx.
    gt_main-meins = gt_mara-meins.

    LOOP AT gt_afko ASSIGNING <fs_afko> WHERE matnr = gt_main-matnr.

* Hitung percen & WIP
      CLEAR: ld_percen,ld_wipmg.
      ld_percen = <fs_afko>-wemng / <fs_afko>-psmng * 100.
      ld_wipmg = <fs_afko>-psmng - <fs_afko>-wemng.

* Hanya untuk yg percen lebih kecil dr 75% dan WIP lebih besar dr 0
      IF ld_percen LT 75 AND ld_wipmg GT 0.

        IF ld_spmon IS INITIAL.
          ld_spmon = gt_main-spmon = <fs_afko>-spmon.
          gt_main-werks = <fs_afko>-werks.
          gt_main-wipmg = ld_wipmg.
        ELSE.
          IF ld_spmon = <fs_afko>-spmon.
            ADD ld_wipmg TO gt_main-wipmg.
          ELSE.
            PERFORM f_append_itab_main.
            ld_spmon = gt_main-spmon = <fs_afko>-spmon.
            gt_main-werks = <fs_afko>-werks.
            gt_main-wipmg = ld_wipmg.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF ld_spmon IS NOT INITIAL.
      PERFORM f_append_itab_main.
    ENDIF.
    CLEAR gt_main.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_CURR

*&---------------------------------------------------------------------*
*&      Form  F_GET_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_po .
  DATA lt_ebeln TYPE TABLE OF ebelntab WITH HEADER LINE.

  CASE 'X'.
    WHEN r_prev.
      SELECT * APPENDING TABLE gt_t007
        FROM zdgppedt007
        WHERE ordty EQ 'PO'
          AND werks EQ p_werks
          AND gltrp BETWEEN gd_month_beg AND gd_month_end.

      IF sy-subrc = 0.
        LOOP AT gt_t007 WHERE ordty = 'PO'.
          lt_ebeln-ebeln = gt_t007-aufnr.
          APPEND lt_ebeln.
        ENDLOOP.

        SELECT a~ebeln a~ebelp a~matnr a~bukrs a~werks a~lgort a~elikz
               b~menge b~wemng b~bedat b~eindt b~charg
          INTO TABLE gt_ekpo
          FROM ekpo AS a JOIN eket AS b ON a~ebeln = b~ebeln AND
                                           a~ebelp = b~ebelp
          FOR ALL ENTRIES IN lt_ebeln
          WHERE a~ebeln EQ lt_ebeln-ebeln
            AND matnr IN s_matnr
            AND werks = p_werks
            AND bstyp = 'F'
            AND loekz = space
            AND elikz = space
            AND eindt BETWEEN gd_month_beg AND gd_month_end.
      ENDIF.

    WHEN r_curr.
      SELECT a~ebeln a~ebelp a~matnr a~bukrs a~werks a~lgort a~elikz
             b~menge b~wemng b~bedat b~eindt b~charg
        INTO TABLE gt_ekpo
        FROM ekpo AS a JOIN eket AS b ON a~ebeln = b~ebeln AND
                                         a~ebelp = b~ebelp
        WHERE matnr IN s_matnr
          AND werks = p_werks
          AND bstyp = 'F'
          AND loekz = space
          AND elikz = space
          AND eindt BETWEEN gd_month_beg AND gd_month_end.
  ENDCASE.

  LOOP AT gt_ekpo ASSIGNING <fs_ekpo>.
    <fs_ekpo>-spmon = <fs_ekpo>-eindt(6).

    gt_matnr-matnr = <fs_ekpo>-matnr.
    COLLECT gt_matnr.
  ENDLOOP.
ENDFORM.                    " F_GET_PO
