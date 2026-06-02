*&---------------------------------------------------------------------*
*&  Include           ZCO_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_date    LIKE LINE OF gt_date.

  gv_categ    = 'VN'.
  gv_mlcct    = 'E'.
  gv_bklas    = '7920'.
  gv_blart    = 'SA'.

  SELECT SINGLE bukrs
    FROM t001k
    INTO gv_bukrs
    WHERE bwkey = pa_bwkey.

  CONCATENATE pa_bdatj pa_poper+1(2) '01' INTO ls_date-budat.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_date-budat
    IMPORTING
      last_day_of_month = gv_datum
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  PERFORM f_range_table USING : ls_date-budat gv_datum 'BUDAT'.

  PERFORM f_range_table USING : '101' '102' 'BWART'.

  PERFORM f_range_table USING : 'ZRM' '' 'MTART',
                                'ZSFG' '' 'MTART',
                                'ZPM' '' 'MTART'.

  PERFORM f_range_table USING : '0711100000' '' 'HKONT',
                                '0712100000' '' 'HKONT',
                                '0715200000' '' 'HKONT',
                                '0720100000' '' 'HKONT',
                                '0720300000' '' 'HKONT',
                                '0720500000' '' 'HKONT',
                                '0711200000' '' 'HKONT'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
*  PERFORM f_error_message USING '' ''.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory  TYPE string,
         filetable  TYPE filetable,
         line       TYPE LINE OF filetable,
         rc         TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'SELECT THE FILE'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

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

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_bseg TYPE TABLE OF bseg WITH HEADER LINE.

  SELECT bukrs belnr gjahr blart bldat budat monat
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FROM bkpf WHERE bukrs = gv_bukrs
                AND bstat = space
                AND budat IN gr_budat.

  IF gt_bkpf[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.

  ELSE.
    SELECT bukrs belnr gjahr buzei shkzg gsber dmbtr wrbtr
           matnr werks menge meins erfmg erfme
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM bseg FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs = gt_bkpf-bukrs
        AND belnr = gt_bkpf-belnr
        AND gjahr = gt_bkpf-gjahr
        AND hkont IN gr_hkont
        AND gsber = pa_bwkey.
  ENDIF.

  IF gt_bseg[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.

  ELSE.
    lt_bseg[] = gt_bseg[].
    SORT lt_bseg BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING matnr.

    SELECT matnr mtart matkl meins
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FROM mara FOR ALL ENTRIES IN lt_bseg
      WHERE matnr = lt_bseg-matnr
        AND mtart IN gr_mtart.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN lt_bseg
      WHERE spras = sy-langu
        AND matnr = lt_bseg-matnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_mara        LIKE LINE OF gt_mara,
         ls_makt        LIKE LINE OF gt_makt,
         ls_bseg        LIKE LINE OF gt_bseg.

  DATA : lt_stylerow    TYPE lvc_t_styl,
         ls_stylerow    TYPE lvc_s_styl.

  LOOP AT gt_bseg INTO ls_bseg.
    CLEAR: ls_mara,ls_makt.
    READ TABLE gt_mara INTO ls_mara
                       WITH KEY matnr = ls_bseg-matnr.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_bseg-matnr.

    IF ls_mara-mtart IN gr_mtart.
    ELSE.
      CONTINUE.
    ENDIF.

    IF ls_bseg-shkzg = 'H'.
      ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
    ENDIF.

    READ TABLE gt_out ASSIGNING <fs_out>
                      WITH KEY bwkey = pa_bwkey
                               poper = pa_poper
                               bdatj = pa_bdatj
                               matnr = ls_bseg-matnr.
    IF sy-subrc = 0.
      ADD ls_bseg-dmbtr TO <fs_out>-dmbtr.
    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-bwkey    = pa_bwkey.
      <fs_out>-poper    = pa_poper.
      <fs_out>-bdatj    = pa_bdatj.
      <fs_out>-matnr    = ls_bseg-matnr.
      <fs_out>-maktx    = ls_makt-maktx.
      <fs_out>-mtart    = ls_mara-mtart.
      <fs_out>-dmbtr    = ls_bseg-dmbtr.
      <fs_out>-waers    = 'IDR'.
    ENDIF.
  ENDLOOP.

  DELETE gt_out WHERE dmbtr IS INITIAL.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  IF gv_post IS INITIAL.
    dynpost-icon_id      = icon_simulate.
    dynpost-icon_text    = 'Simulate'.
  ELSE.
    dynpost-icon_id      = icon_execute_object.
    dynpost-icon_text    = 'Posting'.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm       TYPE sy-ucomm,
         lv_valid       TYPE c,
         lt_fidx        TYPE lvc_t_fidx,
         ls_fidx        TYPE sy-tabix,
         ls_filter      LIKE LINE OF gt_filter.

  DATA : lt_xout        TYPE STANDARD TABLE OF ty_out,
         ls_xout        LIKE LINE OF lt_xout,
         ls_out         LIKE LINE OF gt_out,
         lt_stylerow    TYPE lvc_t_styl,
         ls_stylerow    TYPE lvc_s_styl.

  DATA : lv_icon(4),
         lv_lines       TYPE i.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        lt_xout[] = gt_out[].
        DELETE lt_xout WHERE mark IS INITIAL.
        IF gv_post IS NOT INITIAL.
          DELETE lt_xout WHERE icon <> icon_led_green.
        ENDIF.
        IF lt_xout[] IS NOT INITIAL.
          LOOP AT lt_xout INTO ls_xout.
            PERFORM f_prepare_data USING ls_xout-matnr ls_xout-mtart.
            IF gv_post IS INITIAL.
              PERFORM f_bapi_simulate CHANGING ls_out-icon.
              MODIFY gt_out FROM ls_out
                            TRANSPORTING icon
                            WHERE matnr = ls_xout-matnr.
            ELSE.
              PERFORM f_bapi_posting CHANGING ls_out-belnr ls_out-gjahr.
              CLEAR : ls_out-style[].
              IF ls_out-belnr IS NOT INITIAL.
                CLEAR ls_out-mark.
                ls_stylerow-fieldname = 'MARK'.
                ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
                APPEND ls_stylerow TO ls_out-style.
              ENDIF.
              MODIFY gt_out FROM ls_out
                            TRANSPORTING mark belnr gjahr style
                            WHERE matnr = ls_xout-matnr.
            ENDIF.

            PERFORM f_alv_refresh USING 'X'.
          ENDLOOP.
          CLEAR : ls_out-belnr, ls_out-gjahr.
          IF gv_post IS INITIAL.
            READ TABLE gt_out WITH KEY icon = icon_led_green
                              TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              gv_post = 'X'.
            ELSE.
              CLEAR gv_post.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'BWKEY' '' '' '' '' '' '' 'BWKEY' 'MBEW' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'POPER' '' '' '' '' '' '' 'POPER' 'CKMLKEPH' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'BDATJ' '' '' '' '' '' '' 'BDATJ' 'CKMLKEPH' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'MBEW' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DMBTR' '' '' 'WAERS' '' '' '' 'DMBTR' 'BSEG' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'CKMLKEPH' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BELNR' '' '' '' '' '' '' 'BELNR' 'BKPF' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GJAHR' '' '' '' '' '' '' 'GJAHR' 'BKPF' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl,
         lv_tabix           TYPE sy-tabix,
         ls_filter          LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
*          CLEAR : ls_sort, lv_tabix.
*          READ TABLE gt_sort INTO ls_sort
*                             WITH KEY banfn = ls_out-banfn
*                                      bnfpo = ls_out-bnfpo.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
            CLEAR ls_filter.
            READ TABLE gt_filter INTO ls_filter
                                 WITH KEY INDEX = lv_tabix.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tabgrid IS NOT INITIAL.
      CALL METHOD g_tabgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_GET_PROCESS_ORDER
*&---------------------------------------------------------------------*
FORM f_get_process_order  USING    fu_matnr fu_kaln1
                          CHANGING fc_aufnr fc_menge fc_meins fc_shkzg.
  DATA : ls_mlcd    LIKE LINE OF gt_mlcd,
         ls_aufm    LIKE LINE OF gt_aufm.

  DATA : lv_aufnr   TYPE mseg-aufnr,
         lv_menge   TYPE mseg-menge,
         lv_meins   TYPE mseg-meins.

  CLEAR : fc_aufnr, fc_menge, fc_meins.

  CLEAR ls_mlcd.
  READ TABLE gt_mlcd INTO ls_mlcd
                     WITH KEY kalnr = fu_kaln1.
  IF sy-subrc = 0.
    lv_menge  = ls_mlcd-lbkum.
    lv_meins  = ls_mlcd-meins.
  ENDIF.

  CLEAR ls_aufm.
  SORT gt_aufm BY matnr aufnr DESCENDING.
  READ TABLE gt_aufm INTO ls_aufm
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    lv_aufnr  = ls_aufm-aufnr.
  ENDIF.

*  LOOP AT gt_mseg INTO ls_mseg WHERE matnr = fu_matnr.
*    IF lv_aufnr IS INITIAL.
*      lv_aufnr    = ls_mseg-aufnr.
*    ENDIF.
*    IF lv_meins IS INITIAL.
*      lv_meins    = ls_mseg-meins.
*    ENDIF.
*    IF ls_mseg-shkzg = 'H'.
*      ls_mseg-menge = ls_mseg-menge * -1.
*    ENDIF.
*    ADD ls_mseg-menge TO lv_menge.
*  ENDLOOP.

  IF lv_menge < 0.
    fc_shkzg  = 'H'.
  ELSE.
    fc_shkzg  = 'S'.
  ENDIF.

  fc_aufnr  = lv_aufnr.
  fc_meins  = lv_meins.
  fc_menge  = lv_menge.
ENDFORM.                    " F_GET_PROCESS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data USING fu_matnr fu_mtart.
  DATA : ls_out     LIKE LINE OF gt_out.

  DATA : lv_bsch1   TYPE rf05a-newbs,
         lv_bsch2   TYPE rf05a-newbs,
         lv_alloc   TYPE ckmlkeph-kst001,
         lv_count   TYPE i.

  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = gv_bukrs.
  documentheader-doc_date   = gv_datum.
  documentheader-pstng_date = gv_datum.
  documentheader-doc_type   = gv_blart.
*  documentheader-ref_doc_no = pa_xblnr.
*  documentheader-header_txt = pa_bktxt.

  obj_type = 'BKPF'.

  LOOP AT gt_out INTO ls_out WHERE matnr = fu_matnr.
    ADD 1 TO lv_count.
*    CASE ls_out-shkzg.
*      WHEN 'S'.
*        lv_bsch1 = '40'.
*        lv_bsch2 = '50'.
*      WHEN 'H'.
*        lv_bsch1 = '50'.
*        lv_bsch2 = '40'.
*    ENDCASE.
    IF ls_out-dmbtr GT 0.
      lv_bsch1 = '40'.
      lv_bsch2 = '50'.
    ELSE.
      lv_bsch1 = '50'.
      lv_bsch2 = '40'.
    ENDIF.

    CASE fu_mtart.
      WHEN 'ZRM' OR 'ZSFG'.
        PERFORM f_add_data_posting USING '0122374010' lv_bsch2 '' fu_matnr
                                         ls_out-dmbtr lv_count gv_bukrs
                                         'Auto Reclass ZCOE'.
        ADD 1 TO lv_count.
        PERFORM f_add_data_posting USING '0720100000' lv_bsch1 '' fu_matnr
                                         ls_out-dmbtr lv_count ''
                                         'Auto Reclass ZCOE'.
      WHEN 'ZPM'.
        PERFORM f_add_data_posting USING '0122374020' lv_bsch2 '' fu_matnr
                                         ls_out-dmbtr lv_count gv_bukrs
                                         'Auto Reclass ZCOE'.
        ADD 1 TO lv_count.
        PERFORM f_add_data_posting USING '0720100000' lv_bsch1 '' fu_matnr
                                         ls_out-dmbtr lv_count ''
                                         'Auto Reclass ZCOE'.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_POSTING
*&---------------------------------------------------------------------*
FORM f_bapi_posting CHANGING fc_belnr fc_gjahr.
  DATA : ls_return    LIKE LINE OF return.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = documentheader
    IMPORTING
      obj_type       = obj_type
    TABLES
      accountgl      = accountgl
      currencyamount = currencyamount
      return         = return
      extension1     = extension1.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'S'.
      fc_belnr    = ls_return-message_v2(10).
      fc_gjahr    = ls_return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait   = 'X'
    IMPORTING
      return = ls_return.

  CLEAR : documentheader, obj_type, accountgl[],
          currencyamount[], return[], extension1[].
ENDFORM.                    " F_BAPI_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_SIMULATE
*&---------------------------------------------------------------------*
FORM f_bapi_simulate  CHANGING fc_icon.
  DATA : ls_return    LIKE LINE OF return,
         ls_bapiret2  LIKE LINE OF gt_bapiret2.

  CLEAR fc_icon.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader = documentheader
    TABLES
      accountgl      = accountgl
      currencyamount = currencyamount
      extension1     = extension1
      return         = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'A' OR ls_return-type = 'E'.
      ls_bapiret2  = ls_return.
      IF ls_return-id <> 'RW' OR
        ls_return-number <> '609'.
        fc_icon = icon_led_red.
        APPEND ls_bapiret2 TO gt_bapiret2.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF fc_icon IS INITIAL.
    fc_icon = icon_led_green.
*    gv_post = 'X'.
  ENDIF.

  CLEAR : documentheader, obj_type, accountgl[],
          currencyamount[], return[], extension1[].
ENDFORM.                    " F_BAPI_SIMULATE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DATA_POSTING
*&---------------------------------------------------------------------*
FORM f_add_data_posting  USING    fu_hkont fu_bschl fu_aufnr fu_matnr
                                  fu_alloc fu_count fu_bukrs fu_zuonr.

  DATA : ls_accgl       LIKE LINE OF accountgl,
         ls_curam       LIKE LINE OF currencyamount,
         ls_exte1       LIKE LINE OF extension1.

  DATA : lv_alloc       TYPE ckmlkeph-kst001.

  ls_accgl-itemno_acc            = fu_count.
  ls_accgl-gl_account            = fu_hkont.
  ls_accgl-bus_area              = pa_bwkey.
  IF fu_aufnr IS NOT INITIAL.
    ls_accgl-orderid               = fu_aufnr.
  ENDIF.
  ls_accgl-material              = fu_matnr.
  IF fu_bukrs IS NOT INITIAL.
    PERFORM f_modify_alpha USING fu_bukrs
                           CHANGING ls_accgl-trade_id.
  ENDIF.
  IF fu_zuonr IS NOT INITIAL.
    ls_accgl-alloc_nmbr = fu_zuonr .
  ENDIF.
  APPEND ls_accgl TO accountgl.

  ls_exte1(3)                    = fu_count.
  ls_exte1+3(2)                  = fu_bschl.
  APPEND ls_exte1 TO extension1.

  IF fu_alloc > 0.
    IF fu_bschl = '40'.
      lv_alloc  = fu_alloc * -1.
    ELSE.
      lv_alloc  = fu_alloc.
    ENDIF.
  ELSE.
    IF fu_bschl = '50'.
      lv_alloc  = fu_alloc * -1.
    ELSE.
      lv_alloc  = fu_alloc.
    ENDIF.
  ENDIF.

  ls_curam-itemno_acc    = fu_count.
  ls_curam-curr_type     = '00'.
  ls_curam-currency      = 'IDR'.
  ls_curam-amt_doccur    = lv_alloc * 100.
  APPEND ls_curam TO currencyamount.
ENDFORM.                    " F_ADD_DATA_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_TABLE
*&---------------------------------------------------------------------*
FORM f_range_table  USING    fu_low fu_high fu_field.
  DATA : ls_hkont   LIKE LINE OF gr_hkont,
         ls_bwart   LIKE LINE OF gr_bwart,
         ls_mtart   LIKE LINE OF gr_mtart,
         ls_budat   LIKE LINE OF gr_budat.

  CASE fu_field.
    WHEN 'BUDAT'.
      ls_budat-low  = fu_low.
      IF fu_high IS NOT INITIAL.
        ls_budat-high   = fu_high.
        ls_budat-option = 'BT'.
      ELSE.
        ls_budat-option = 'EQ'.
      ENDIF.
      ls_budat-sign  = 'I'.
      APPEND ls_budat TO gr_budat.
      CLEAR ls_budat.

    WHEN 'BWART'.
      ls_bwart-low  = fu_low.
      IF fu_high IS NOT INITIAL.
        ls_bwart-high   = fu_high.
        ls_bwart-option = 'BT'.
      ELSE.
        ls_bwart-option = 'EQ'.
      ENDIF.
      ls_bwart-sign  = 'I'.
      APPEND ls_bwart TO gr_bwart.
      CLEAR ls_bwart.

    WHEN 'MTART'.
      ls_mtart-low  = fu_low.
      IF fu_high IS NOT INITIAL.
        ls_mtart-high   = fu_high.
        ls_mtart-option = 'BT'.
      ELSE.
        ls_mtart-option = 'EQ'.
      ENDIF.
      ls_mtart-sign  = 'I'.
      APPEND ls_mtart TO gr_mtart.
      CLEAR ls_mtart.

    WHEN 'HKONT'.
      ls_hkont-low  = fu_low.
      IF fu_high IS NOT INITIAL.
        ls_hkont-high   = fu_high.
        ls_hkont-option = 'BT'.
      ELSE.
        ls_hkont-option = 'EQ'.
      ENDIF.
      ls_hkont-sign  = 'I'.
      APPEND ls_hkont TO gr_hkont.
      CLEAR ls_hkont.
  ENDCASE.
ENDFORM.                    " F_RANGE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ALPHA
*&---------------------------------------------------------------------*
FORM f_modify_alpha  USING    fu_value
                     CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_MODIFY_ALPHA
