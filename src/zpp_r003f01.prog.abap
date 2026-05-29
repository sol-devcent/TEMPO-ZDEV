*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'AUF' '0' '' '' ''.
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
  DATA: lt_ztspppdt009 TYPE STANDARD TABLE OF ztspppdt009.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ztspppdt009
    FROM ztspppdt009 WHERE werks  EQ pa_werks
                       AND afind  IN so_afind
                       AND equnr  IN so_equnr
                       AND wbooth IN so_wboot
                       AND aufnr  IN so_aufnr.
  IF gt_ztspppdt009[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  lt_ztspppdt009[] = gt_ztspppdt009[].
  DELETE lt_ztspppdt009 WHERE aufnr IS INITIAL.
  IF lt_ztspppdt009[] IS NOT INITIAL.
    SELECT DISTINCT aufnr posnr matnr charg
      INTO CORRESPONDING FIELDS OF TABLE gt_afpo
      FROM afpo FOR ALL ENTRIES IN lt_ztspppdt009
      WHERE aufnr = lt_ztspppdt009-aufnr.
  ENDIF.

  IF gt_afpo[] IS NOT INITIAL.
    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_afpo
      WHERE matnr = gt_afpo-matnr
        AND spras = sy-langu.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: ls_ztspppdt009 LIKE LINE OF gt_ztspppdt009,
        ls_afpo        LIKE LINE OF gt_afpo,
        ls_makt        LIKE LINE OF gt_makt.

  LOOP AT gt_ztspppdt009 INTO ls_ztspppdt009.
    CLEAR: ls_afpo,ls_makt.
    IF ls_ztspppdt009-aufnr IS NOT INITIAL.
      READ TABLE gt_afpo INTO ls_afpo
                         WITH KEY aufnr = ls_ztspppdt009-aufnr.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr = ls_afpo-matnr.
    ENDIF.

    IF so_fgbat[] IS NOT INITIAL.
      IF ls_afpo-charg NOT IN so_fgbat.
        CONTINUE.
      ENDIF.
    ENDIF.

    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
    MOVE-CORRESPONDING ls_ztspppdt009 TO <fs_out>.
    <fs_out>-fgmat = ls_afpo-matnr.
    <fs_out>-fgbat = ls_afpo-charg.
    <fs_out>-fgdes = ls_makt-maktx.
  ENDLOOP.
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

*    CREATE OBJECT g_splitter
*      EXPORTING
*        parent  = g_customcont
*        rows    = 2
*        columns = 1.
*
*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 1
*      RECEIVING
*        container = g_contain01.
*
*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_contain02.
*
*    CREATE OBJECT g_splitter1
*      EXPORTING
*        parent  = g_contain02
*        rows    = 1
*        columns = 2.
*
*    CALL METHOD g_splitter1->get_container
*      EXPORTING
*        row       = 1
*        column    = 1
*      RECEIVING
*        container = g_contain03.
*
*    CALL METHOD g_splitter1->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain04.

  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

*  IF gt_bapiret2[] IS NOT INITIAL.
*    dynlog-icon_id      = icon_error_protocol.
*    dynlog-icon_text    = 'Error Log'.
*  ENDIF.

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

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
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
        PERFORM f_posting_data.
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
        i_parent      = g_customcont. "g_contain01.

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
*  gs_layout_alv-sel_mode            = selected.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'WERKS' 'X' '' ''.
  PERFORM f_alv_sort USING : 2 'EQUNR' 'X' '' ''.
  PERFORM f_alv_sort USING : 3 'SHTXT' 'X' '' ''.
  PERFORM f_alv_sort USING : 4 'WBOOTH' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK' OR 'ICON' OR 'STYLE' OR 'COLOR' OR
           'MANDT' OR 'AUFNR' OR 'SANTL'.
        CONTINUE.
      WHEN 'WERKS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '1'
        CHANGING ls_fieldcat.
      WHEN 'EQUNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '2'
        CHANGING ls_fieldcat.
      WHEN 'SHTXT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '3'
        CHANGING ls_fieldcat.
      WHEN 'WBOOTH'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '4'
        CHANGING ls_fieldcat.
      WHEN 'OPERATOR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Operator' '' '' '' '' '' '' '' '' '' '' '5'
        CHANGING ls_fieldcat.
      WHEN 'ASTAD'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Start Date' '' '' '' '' '' '' '' '' '' '' '6'
        CHANGING ls_fieldcat.
      WHEN 'ASTAU'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Start Time' '' '' '' '' '' '' '' '' '' '' '7'
        CHANGING ls_fieldcat.
      WHEN 'AFIND'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Finish Date' '' '' '' '' '' '' '' '' '' '' '8'
        CHANGING ls_fieldcat.
      WHEN 'AFINU'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Finish Time' '' '' '' '' '' '' '' '' '' '' '9'
        CHANGING ls_fieldcat.
      WHEN 'MATNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '10'
        CHANGING ls_fieldcat.
      WHEN 'MAKTX'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '11'
        CHANGING ls_fieldcat.
      WHEN 'CHARG'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '12'
        CHANGING ls_fieldcat.
      WHEN 'FGMAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FG Material' '' '' '' '' '' '' '' '' '' '' '13'
        CHANGING ls_fieldcat.
      WHEN 'FGDES'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FG Description' '' '' '' '' '' '' '' '' '' '' '14'
        CHANGING ls_fieldcat.
      WHEN 'FGBAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FG Batch' '' '' '' '' '' '' '' '' '' '' '15'
        CHANGING ls_fieldcat.
      WHEN 'LTXA1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '16'
        CHANGING ls_fieldcat.
      WHEN 'PENGAWAS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Pengawas' '' '' '' '' '' '' '' '' '' '' '17'
        CHANGING ls_fieldcat.
      WHEN 'AVALD'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '18'
        CHANGING ls_fieldcat.
      WHEN 'AVALU'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '19'
        CHANGING ls_fieldcat.
      WHEN 'SANTX'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Jenis Sanitasi' '' '' '' '' '' '' '' '' '' '' '20'
        CHANGING ls_fieldcat.
    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
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
        lv_tabix = sy-tabix.

        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
          CLEAR ls_filter.
          READ TABLE gt_filter INTO ls_filter
                               WITH KEY INDEX = lv_tabix.
          IF sy-subrc = 0.
            CONTINUE.
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
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  IF lt_out[] IS NOT INITIAL.

  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum fu_colpos
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  fs_dyn_fcat-currency    = fu_currency.
  fs_dyn_fcat-cfieldname  = fu_cfieldname.
  fs_dyn_fcat-quantity    = fu_quantity.
  fs_dyn_fcat-qfieldname  = fu_qfieldname.
  fs_dyn_fcat-checkbox    = fu_checkbox.
  fs_dyn_fcat-coltext     = fu_coltext.
  fs_dyn_fcat-edit        = fu_edit.
  fs_dyn_fcat-outputlen   = fu_outputlen.
  fs_dyn_fcat-inttype     = fu_inttype.
  fs_dyn_fcat-no_out      = fu_no_out.
  fs_dyn_fcat-tech        = fu_tech.
  fs_dyn_fcat-key         = fu_key.
  fs_dyn_fcat-fix_column  = fu_fix.
  fs_dyn_fcat-icon        = fu_icon.
  fs_dyn_fcat-do_sum      = fu_sum.
  fs_dyn_fcat-no_sum      = fu_nosum.
  fs_dyn_fcat-col_pos     = fu_colpos.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT
