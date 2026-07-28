*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA BEGIN OF lt_mara OCCURS 0.
  DATA:  matnr LIKE mara-matnr,
         mtart LIKE mara-mtart,
         meins LIKE mara-meins.
  DATA END OF lt_mara.

  DATA lt_mtart LIKE lt_mara OCCURS 0 WITH HEADER LINE.

  DATA BEGIN OF lt_bwart OCCURS 0.
          INCLUDE STRUCTURE zgdcodt0002.
  DATA END OF lt_bwart.

  DATA BEGIN OF lt_mseg OCCURS 0.
  DATA:  mblnr LIKE mkpf-mblnr,
         mjahr LIKE mkpf-mjahr,
         zeile LIKE mseg-zeile,
         budat LIKE mkpf-budat,
         buzei LIKE mseg-buzei,
         matnr LIKE mseg-matnr,
         menge LIKE mseg-menge,
         meins LIKE mseg-meins,
         shkzg LIKE mseg-shkzg,
         bwart LIKE mseg-bwart,
         mtart LIKE mara-mtart.
  DATA END OF lt_mseg.

  RANGES: lr_bwart FOR mseg-bwart.
  RANGES: lr_budat FOR mkpf-budat.

  SELECT mara~matnr mtart meins
         INTO TABLE lt_mara
         FROM mara JOIN marc ON mara~matnr = marc~matnr
         WHERE marc~werks = p_werks.

  CHECK sy-subrc = 0.
  lt_mtart[] = lt_mara[].
  SORT lt_mtart BY mtart.
  DELETE ADJACENT DUPLICATES FROM lt_mtart COMPARING mtart.
  SELECT * INTO TABLE lt_bwart
           FROM zgdcodt0002
           FOR ALL ENTRIES IN lt_mtart
           WHERE mtart = lt_mtart-mtart.
  SORT lt_bwart BY mtart bwart.

  LOOP AT lt_mara.
    READ TABLE lt_bwart WITH KEY mtart = lt_mara-mtart
                        BINARY SEARCH.
    IF sy-subrc <> 0.
      DELETE lt_mara.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_bwart.
    lr_bwart-low = lt_bwart-bwart.
    lr_bwart-sign = 'I'.
    lr_bwart-option = 'EQ'.
    APPEND lr_bwart.
  ENDLOOP.

  CHECK sy-subrc = 0.
  lr_budat-sign = 'I'.
  lr_budat-option = 'BT'.
  CONCATENATE p_bdatj p_poper+1(2) '01' INTO lr_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
       EXPORTING
            day_in            = lr_budat-low
       IMPORTING
            last_day_of_month = lr_budat-high.
  APPEND lr_budat.

  break bcrmd.

  SELECT mkpf~mblnr mkpf~mjahr zeile budat
         buzei matnr menge meins shkzg bwart
         INTO CORRESPONDING FIELDS OF TABLE lt_mseg
         FROM mkpf JOIN mseg ON mkpf~mblnr = mseg~mblnr AND
                                mkpf~mjahr = mseg~mjahr
         FOR ALL entries IN lt_mara
         WHERE matnr = lt_mara-matnr AND
               werks = p_werks AND
               bwart IN lr_bwart AND
               budat IN lr_budat.

  CHECK sy-subrc = 0.

*-- Check movement type dengan table zgdcodt0002 15/12/2005
  SORT lt_mseg BY matnr.
  SORT lt_mara BY matnr.
  LOOP AT lt_mseg.
    READ TABLE lt_mara WITH KEY matnr = lt_mseg-matnr
                        BINARY SEARCH.
    IF sy-subrc EQ 0.
      lt_mseg-mtart = lt_mara-mtart.
    ELSE.
      lt_mseg-mtart = space.
    ENDIF.
    MODIFY lt_mseg TRANSPORTING mtart.
  ENDLOOP.
*--

  SORT lt_mseg BY mtart bwart matnr.
  SORT lt_bwart BY mtart bwart.
  LOOP AT lt_mseg.
    READ TABLE lt_bwart WITH KEY mtart = lt_mseg-mtart
                                 bwart = lt_mseg-bwart
                        BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING lt_mseg TO t_main.
      t_main-werks = p_werks.
      t_main-bdatj = p_bdatj.
      t_main-poper = p_poper.
      t_main-uname = sy-uname.
      t_main-udate = sy-datum.
      t_main-utime = sy-uzeit.
      IF lt_mseg-shkzg = 'S'.
        t_main-menge = ( -1 ) * lt_mseg-menge.
      ENDIF.
      COLLECT t_main.
    ENDIF.
  ENDLOOP.

** Penambahan untuk material dengan menge 0
  LOOP AT lt_mara.
    READ TABLE t_main WITH KEY matnr = lt_mara-matnr.
    IF sy-subrc NE 0.
      t_main-matnr = lt_mara-matnr.
      t_main-meins = lt_mara-meins.
      t_main-werks = p_werks.
      t_main-bdatj = p_bdatj.
      t_main-poper = p_poper.
      t_main-uname = sy-uname.
      t_main-udate = sy-datum.
      t_main-utime = sy-uzeit.
      t_main-menge = 0.
      COLLECT t_main.
    ENDIF.
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
  PERFORM f_alv TABLES <fs_table>.

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
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'T001W' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'BDATJ' 'ZGDCODT0003' 'BDATJ' '' '' '' '' '' '' '' '' '' '' '',
    'POPER' 'ZGDCODT0003' 'POPER' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE' 'ZGDCODT0003' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '',
    'MEINS' 'ZGDCODT0003' 'MEINS' '' '' '' '' '' '' '' '' '' '' ''.

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
  ld_sort-fieldname = 'MATNR'.
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

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.

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

  MODIFY zgdcodt0003 FROM TABLE t_main.
  COMMIT WORK AND WAIT.
  IF sy-subrc = 0.
    MESSAGE s000(zab) WITH 'Data has successfully been updated'.
  ENDIF.

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
  BREAK-POINT.
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
