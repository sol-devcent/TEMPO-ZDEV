*&---------------------------------------------------------------------*
*&  Include           ZMM_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  PERFORM f_get_field USING 'HEAD'.
  PERFORM f_get_field USING 'ITEM'.
  PERFORM f_get_field USING 'GL'.
  PERFORM f_get_field USING 'MATERIAL'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'P02' '0' '' '' ''.
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
      window_title      = 'Select the File'
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
  IF pa_fhead IS NOT INITIAL.
    PERFORM f_get_upload_file USING 'HEAD'.
  ENDIF.
  IF pa_fitem IS NOT INITIAL.
    PERFORM f_get_upload_file USING 'ITEM'.
  ENDIF.
  IF pa_fglac IS NOT INITIAL.
    PERFORM f_get_upload_file USING 'GL'.
  ENDIF.
  IF pa_fmatn IS NOT INITIAL.
    PERFORM f_get_upload_file USING 'MATERIAL'.
  ENDIF.

  IF gt_rdoc[] IS NOT INITIAL.
    SELECT *
      FROM rbkp
      INTO CORRESPONDING FIELDS OF TABLE gt_rbkp
      FOR ALL ENTRIES IN gt_rdoc
      WHERE xblnr = gt_rdoc-xblnr.
  ENDIF.

  IF gt_bdoc[] IS NOT INITIAL.
    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
      FOR ALL ENTRIES IN gt_bdoc
      WHERE bukrs = gt_bdoc-bukrs
        AND bstat = gt_bdoc-bstat
        AND xblnr = gt_bdoc-xblnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out           LIKE LINE OF gt_out,
         ls_rbkp          LIKE LINE OF gt_rbkp,
         ls_bkpf          LIKE LINE OF gt_bkpf.

  DATA : lt_stylerow      TYPE lvc_t_styl,
         ls_stylerow      TYPE lvc_s_styl.

  DATA : lv_bstat         TYPE bkpf-bstat.

  FIELD-SYMBOLS : <fs>    TYPE ANY.

  LOOP AT <fs_thead> INTO <fs_shead>.
    ASSIGN COMPONENT 'REF_DOC_NO' OF STRUCTURE <fs_shead> TO <fs>.
    ls_out-xblnr  = <fs>.
    ASSIGN COMPONENT 'COMP_CODE' OF STRUCTURE <fs_shead> TO <fs>.
    ls_out-bukrs  = <fs>.

    CASE 'X'.
      WHEN radio1.
        READ TABLE gt_rbkp INTO ls_rbkp
                           WITH KEY xblnr = ls_out-xblnr.
        IF sy-subrc = 0.
          ls_out-belnr  = ls_rbkp-belnr.
          ls_out-gjahr  = ls_rbkp-gjahr.
        ELSE.
          READ TABLE gt_bkpf INTO ls_bkpf
                             WITH KEY bukrs = ls_out-bukrs
                                      bstat = lv_bstat
                                      xblnr = ls_out-xblnr.
          IF sy-subrc = 0.
            ls_out-belnr  = ls_bkpf-belnr.
            ls_out-gjahr  = ls_bkpf-gjahr.

            ls_stylerow-fieldname = 'MARK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
          ELSE.
            PERFORM f_prepare_data USING ls_out-xblnr.
            PERFORM f_park_document CHANGING ls_out-belnr ls_out-gjahr.
          ENDIF.
        ENDIF.

        IF ls_out-belnr IS INITIAL.
          ls_out-icon = icon_led_red.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR ls_out.

      WHEN radio2.
        READ TABLE gt_bkpf INTO ls_bkpf
                           WITH KEY bukrs = ls_out-bukrs
                                    bstat = lv_bstat
                                    xblnr = ls_out-xblnr.
        IF sy-subrc = 0.
          ls_out-belnr  = ls_bkpf-belnr.
          ls_out-gjahr  = ls_bkpf-gjahr.

          ls_stylerow-fieldname = 'MARK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
        ELSE.
          PERFORM f_prepare_data USING ls_out-xblnr.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR ls_out.
    ENDCASE.
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

  PERFORM f_alv_sort USING : 1 'XBLNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    '' 'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '' '',
    '' 'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    '' 'BUKRS' '' '' '' '' '' '' 'BUKRS' 'BKPF' '' '' '' '' '' ''
    '' 'X' '' '' '' '' '',
    '' 'XBLNR' '' '' '' '' '' '' 'XBLNR' 'BKPF' '' '' '' '' '' ''
    '' 'X' '' '' '' '' '',
    '' 'BELNR' '' '' '' '' '' '' 'BELNR' 'RBKP' '' '' '' '' '' ''
    '' '' '' '' '' '' '',
    '' 'GJAHR' '' '' '' '' '' '' 'GJAHR' 'RBKP' '' '' '' '' '' ''
    '' '' '' '' '' '' ''.

ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_filenm fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum fu_colpos.
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
  ls_dyn_fcat-col_pos     = fu_colpos.

  CASE fu_filenm.
    WHEN 'HEAD'.
      APPEND ls_dyn_fcat TO gt_thead_fieldcat.
    WHEN 'ITEM'.
      APPEND ls_dyn_fcat TO gt_tglac_fieldcat.
    WHEN 'GL'.
      APPEND ls_dyn_fcat TO gt_tglac_fieldcat.
    WHEN 'MATERIAL'.
      APPEND ls_dyn_fcat TO gt_tmatn_fieldcat.
    WHEN OTHERS.
      APPEND ls_dyn_fcat TO gt_main_fieldcat.
  ENDCASE.

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
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_xout    TYPE STANDARD TABLE OF ty_out,
         ls_xout    LIKE LINE OF lt_xout.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      PERFORM f_post_document USING ls_xout-belnr ls_xout-gjahr.
    ENDLOOP.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_UPLOAD_FILE
*&---------------------------------------------------------------------*
FORM f_get_upload_file  USING    fu_filenm.
  TYPES : BEGIN OF ty_excel,
            row   LIKE alsmex_tabline-row,
            col   LIKE alsmex_tabline-col,
            value LIKE alsmex_tabline-value,
          END OF ty_excel.

  DATA : lt_excel     TYPE STANDARD TABLE OF ty_excel,
         ls_excel     LIKE LINE OF lt_excel,
         lt_dyntab    TYPE STANDARD TABLE OF ty_excel,
         ls_dyntab    LIKE LINE OF lt_dyntab.

  DATA : lv_fname     TYPE rlgrap-filename,
         lv_colpos    TYPE i.

  DATA : lt_stru      TYPE STANDARD TABLE OF dfies.

  CASE fu_filenm.
    WHEN 'HEAD'.
      lv_fname   = pa_fhead.
      lt_stru[]  = gt_sthead[].
    WHEN 'ITEM'.
      lv_fname   = pa_fitem.
      lt_stru[]  = gt_stitem[].
    WHEN 'GL'.
      lv_fname   = pa_fglac.
      lt_stru[]  = gt_stglac[].
    WHEN 'MATERIAL'.
      lv_fname   = pa_fmatn.
      lt_stru[]  = gt_stmatn[].
  ENDCASE.

  REFRESH lt_excel. CLEAR lt_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_fname
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  lt_dyntab[] = lt_excel[].
  SORT lt_dyntab BY row.
  DELETE lt_dyntab WHERE row <> '0001'.
  LOOP AT lt_dyntab INTO ls_dyntab.
    PERFORM f_create_dyn_table TABLES lt_stru
                               USING fu_filenm ls_dyntab-value ls_dyntab-col.
  ENDLOOP.

  PERFORM f_dyn_table USING fu_filenm.

  LOOP AT lt_excel INTO ls_excel.
    IF ls_excel-row = '0001'.
      CONTINUE.
    ENDIF.
    CASE fu_filenm.
      WHEN 'HEAD'.
        PERFORM f_data_table TABLES gt_thead_fieldcat
                             USING ls_excel-col fu_filenm ls_excel-value.
      WHEN 'ITEM'.
        PERFORM f_data_table TABLES gt_titem_fieldcat
                             USING ls_excel-col fu_filenm ls_excel-value.
      WHEN 'GL'.
        PERFORM f_data_table TABLES gt_tglac_fieldcat
                             USING ls_excel-col fu_filenm ls_excel-value.
      WHEN 'MATERIAL'.
        PERFORM f_data_table TABLES gt_tmatn_fieldcat
                             USING ls_excel-col fu_filenm ls_excel-value.
    ENDCASE.
    AT END OF row.
      CASE fu_filenm.
        WHEN 'HEAD'.
          APPEND <fs_shead> TO <fs_thead>.
          APPEND gs_rdoc TO gt_rdoc.
          APPEND gs_bdoc TO gt_bdoc.
          CLEAR : gs_rdoc, gs_bdoc.

        WHEN 'ITEM'.
          APPEND <fs_sitem> TO <fs_titem>.
        WHEN 'GL'.
          APPEND <fs_sglac> TO <fs_tglac>.
        WHEN 'MATERIAL'.
          APPEND <fs_smatn> TO <fs_tmatn>.
      ENDCASE.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_GET_UPLOAD_FILE

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_table  TABLES   ft_stru   STRUCTURE dfies
                         USING    fu_filenm fu_value fu_colpos.
  DATA : ls_stru      TYPE dfies.
  DATA : lv_colpos    TYPE alsmex_tabline-col.

  READ TABLE ft_stru INTO ls_stru
                       WITH KEY fieldname = fu_value.
  IF sy-subrc = 0.
    PERFORM f_dyn_int_table USING :
     fu_filenm fu_value '' '' '' '' '' ''
     ls_stru-fieldname ls_stru-tabname ls_stru-fieldtext ls_stru-outputlen
     ls_stru-inttype '' '' '' '' '' '' '' '' '' fu_colpos.
  ELSE.
    IF fu_value = 'REF_DOC_NO'.
      lv_colpos = 1.
    ENDIF.
    PERFORM f_dyn_int_table USING :
     fu_filenm fu_value '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
     '' '' '' lv_colpos.
  ENDIF.
ENDFORM.                    " F_CREATE_DYN_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELD
*&---------------------------------------------------------------------*
FORM f_get_field  USING    fu_filenm.
  DATA : tabname      TYPE ddobjname,
         dfies_tab    TYPE STANDARD TABLE OF dfies.

  CASE fu_filenm.
    WHEN 'HEAD'.
      tabname = 'BAPI_INCINV_CREATE_HEADER'.
    WHEN 'ITEM'.
      tabname = 'BAPI_INCINV_CREATE_ITEM'.
    WHEN 'GL'.
      tabname = 'BAPI_INCINV_CREATE_GL_ACCOUNT'.
    WHEN 'MATERIAL'.
      tabname = 'BAPI_INCINV_CREATE_MATERIAL'.
  ENDCASE.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = tabname
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  CASE fu_filenm.
    WHEN 'HEAD'.
      gt_sthead[] = dfies_tab[].
    WHEN 'ITEM'.
      gt_stitem[] = dfies_tab[].
    WHEN 'GL'.
      gt_stglac[] = dfies_tab[].
    WHEN 'MATERIAL'.
      gt_stmatn[] = dfies_tab[].
  ENDCASE.
ENDFORM.                    " F_GET_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_DYN_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_table  USING    fu_filenm.
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data.

  CASE fu_filenm.
    WHEN 'HEAD'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_thead_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_thead>.
        CREATE DATA ls_line LIKE LINE OF <fs_thead>.
        ASSIGN ls_line->* TO <fs_shead>.
      ENDIF.

    WHEN 'ITEM'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_titem_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_titem>.
        CREATE DATA ls_line LIKE LINE OF <fs_titem>.
        ASSIGN ls_line->* TO <fs_sitem>.
      ENDIF.

    WHEN 'GL'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_tglac_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_tglac>.
        CREATE DATA ls_line LIKE LINE OF <fs_tglac>.
        ASSIGN ls_line->* TO <fs_sglac>.
      ENDIF.

    WHEN 'MATERIAL'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_tmatn_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_tmatn>.
        CREATE DATA ls_line LIKE LINE OF <fs_tmatn>.
        ASSIGN ls_line->* TO <fs_smatn>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DYN_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DATA_TABLE
*&---------------------------------------------------------------------*
FORM f_data_table  TABLES   ft_fieldcat STRUCTURE lvc_s_fcat
                   USING    fu_col fu_filenm fu_value.

  DATA : ls_field     TYPE lvc_s_fcat,
         ls_stru      TYPE dfies,
         lv_value(50).

  FIELD-SYMBOLS <fs>  TYPE ANY.

  READ TABLE ft_fieldcat INTO ls_field
                         WITH KEY col_pos = fu_col.
  IF sy-subrc = 0.
    CASE fu_filenm.
      WHEN 'HEAD'.
        READ TABLE gt_sthead INTO ls_stru
                             WITH KEY fieldname = ls_field-fieldname.
        IF sy-subrc = 0.
          lv_value  = fu_value.
          PERFORM f_conversion USING ls_stru-datatype ls_stru-convexit ls_stru-outputlen
                               CHANGING lv_value.

          ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_shead> TO <fs>.
          <fs> = lv_value.
        ELSE.
          IF ls_field-fieldname = 'REF_DOC_NO'.
            ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_shead> TO <fs>.
            <fs> = fu_value.
          ENDIF.
        ENDIF.

        CASE ls_field-fieldname.
          WHEN 'REF_DOC_NO'.
            gs_rdoc-xblnr   = fu_value.
            gs_bdoc-xblnr   = fu_value.
          WHEN 'COMP_CODE'.
            gs_bdoc-bukrs   = fu_value.
        ENDCASE.

      WHEN 'ITEM'.
        READ TABLE gt_stitem INTO ls_stru
                             WITH KEY fieldname = ls_field-fieldname.
        IF sy-subrc = 0.
          lv_value  = fu_value.
          PERFORM f_conversion USING ls_stru-datatype ls_stru-convexit ls_stru-outputlen
                               CHANGING lv_value.

          ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_sitem> TO <fs>.
          <fs> = lv_value.
        ELSE.
          IF ls_field-fieldname = 'REF_DOC_NO'.
            ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_sitem> TO <fs>.
            <fs> = fu_value.
          ENDIF.
        ENDIF.
      WHEN 'GL'.
        READ TABLE gt_stglac INTO ls_stru
                             WITH KEY fieldname = ls_field-fieldname.
        IF sy-subrc = 0.
          lv_value  = fu_value.
          PERFORM f_conversion USING ls_stru-datatype ls_stru-convexit ls_stru-outputlen
                               CHANGING lv_value.

          ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_sglac> TO <fs>.
          <fs> = lv_value.
        ELSE.
          IF ls_field-fieldname = 'REF_DOC_NO'.
            ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_sglac> TO <fs>.
            <fs> = fu_value.
          ENDIF.
        ENDIF.
      WHEN 'MATERIAL'.
        READ TABLE gt_stmatn INTO ls_stru
                             WITH KEY fieldname = ls_field-fieldname.
        IF sy-subrc = 0.
          lv_value  = fu_value.
          PERFORM f_conversion USING ls_stru-datatype ls_stru-convexit ls_stru-outputlen
                               CHANGING lv_value.

          ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_smatn> TO <fs>.
          <fs> = lv_value.
        ELSE.
          IF ls_field-fieldname = 'REF_DOC_NO'.
            ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <fs_smatn> TO <fs>.
            <fs> = fu_value.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_DATA_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_datatype fu_convexit fu_outputlen
                   CHANGING fc_value.
  TYPES : BEGIN OF ty_date,
            date1 TYPE char2,
            date2 TYPE char2,
            date3 TYPE char4,
          END OF ty_date.

  DATA : ls_date      TYPE ty_date,
         lv_func      TYPE string,
         lv_length    TYPE i.

  CASE fu_datatype.
    WHEN 'DEC' OR 'QUAN' OR 'CURR'.
      TRANSLATE fc_value USING '. '.
      TRANSLATE fc_value USING ',.'.
      CONDENSE fc_value NO-GAPS.
    WHEN 'DATS'.
      TRANSLATE fc_value USING '. '.
      TRANSLATE fc_value USING '/ '.
      CONDENSE fc_value NO-GAPS.

      ls_date = fc_value.
      CLEAR fc_value.

      IF ls_date-date3 GE '2000'.
        IF ls_date-date2 LE '12'.
          CONCATENATE ls_date-date3 ls_date-date2 ls_date-date1
            INTO fc_value.
        ELSE.
          CONCATENATE ls_date-date3 ls_date-date1 ls_date-date2
            INTO fc_value.
        ENDIF.
      ENDIF.
  ENDCASE.

  CASE fu_convexit.
    WHEN 'CUNIT'.
      CONCATENATE 'CONVERSION_EXIT_' fu_convexit '_INPUT'
        INTO lv_func.
      CALL FUNCTION lv_func
        EXPORTING
          input  = fc_value
        IMPORTING
          output = fc_value.

    WHEN 'ALPHA'.
      CONCATENATE 'CONVERSION_EXIT_' fu_convexit '_INPUT'
        INTO lv_func.
      CALL FUNCTION lv_func
        EXPORTING
          input  = fc_value
        IMPORTING
          output = fc_value.

      lv_length = 50 - fu_outputlen.
      CASE fu_outputlen.
        WHEN 10.
          fc_value  = fc_value+lv_length(10).
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data  USING    fu_xblnr .
  DATA : ls_thead        LIKE LINE OF gt_thead_fieldcat,
         ls_titem        LIKE LINE OF gt_titem_fieldcat,
         ls_tglac        LIKE LINE OF gt_tglac_fieldcat,
         ls_tmatn        LIKE LINE OF gt_tmatn_fieldcat.

  DATA : ls_item         LIKE LINE OF itemdata,
         ls_glac         LIKE LINE OF glaccountdata,
         ls_matn         LIKE LINE OF materialdata,
         ls_rbkp         LIKE LINE OF gt_rbkp.

  DATA : lv_fieldname(30),
         condition       TYPE string.

  FIELD-SYMBOLS : <fs>   TYPE ANY,
                  <fs1>  TYPE ANY.

  CLEAR : headerdata, itemdata[], itemdata, glaccountdata[], glaccountdata,
          materialdata[], materialdata.

  LOOP AT gt_thead_fieldcat INTO ls_thead.
    CONCATENATE 'HEADERDATA-' ls_thead-fieldname INTO lv_fieldname.
    ASSIGN (lv_fieldname) TO <fs1>.
    ASSIGN COMPONENT ls_thead-fieldname OF STRUCTURE <fs_shead> TO <fs>.
    <fs1> = <fs>.
  ENDLOOP.

  IF pa_fitem IS NOT INITIAL.
    LOOP AT <fs_titem> INTO <fs_sitem>.
      ASSIGN COMPONENT 'REF_DOC_NO' OF STRUCTURE <fs_sitem> TO <fs>.
      CHECK <fs> = fu_xblnr.
      LOOP AT gt_titem_fieldcat INTO ls_titem.
        CONCATENATE 'LS_ITEM-' ls_titem-fieldname INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs1>.
        ASSIGN COMPONENT ls_titem-fieldname OF STRUCTURE <fs_sitem> TO <fs>.
        <fs1> = <fs>.
      ENDLOOP.
      APPEND ls_item TO itemdata.
      CLEAR ls_item.
    ENDLOOP.
  ENDIF.

  IF pa_fglac IS NOT INITIAL.
    LOOP AT <fs_tglac> INTO <fs_sglac>.
      ASSIGN COMPONENT 'REF_DOC_NO' OF STRUCTURE <fs_sglac> TO <fs>.
      CHECK <fs> = fu_xblnr.
      LOOP AT gt_tglac_fieldcat INTO ls_tglac.
        CONCATENATE 'LS_GLAC-' ls_tglac-fieldname INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs1>.
        ASSIGN COMPONENT ls_tglac-fieldname OF STRUCTURE <fs_sglac> TO <fs>.
        <fs1> = <fs>.
      ENDLOOP.
      APPEND ls_glac TO glaccountdata.
      CLEAR ls_glac.
    ENDLOOP.
  ENDIF.

  IF pa_fmatn IS NOT INITIAL.
    LOOP AT <fs_tmatn> INTO <fs_smatn>.
      ASSIGN COMPONENT 'REF_DOC_NO' OF STRUCTURE <fs_smatn> TO <fs>.
      CHECK <fs> = fu_xblnr.
      LOOP AT gt_tmatn_fieldcat INTO ls_tmatn.
        CONCATENATE 'LS_MATN-' ls_tmatn-fieldname INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs1>.
        ASSIGN COMPONENT ls_tmatn-fieldname OF STRUCTURE <fs_smatn> TO <fs>.
        <fs1> = <fs>.
      ENDLOOP.
      APPEND ls_matn TO materialdata.
      CLEAR ls_matn.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PARK_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_park_document  CHANGING fc_belnr fc_gjahr.
  DATA : return       TYPE STANDARD TABLE OF bapiret2,
         ls_return    LIKE LINE OF return.

  DATA : lv_lines     TYPE i.

  CALL FUNCTION 'BAPI_INCOMINGINVOICE_PARK'
    EXPORTING
      headerdata       = headerdata
    IMPORTING
      invoicedocnumber = fc_belnr
      fiscalyear       = fc_gjahr
    TABLES
      itemdata         = itemdata
      glaccountdata    = glaccountdata
      materialdata     = materialdata
      return           = return.

  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    LOOP AT return INTO ls_return WHERE type = 'E'.
      APPEND ls_return TO gt_bapiret2.
      CLEAR ls_return.
    ENDLOOP.

    DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
    IF lv_lines = 1.
      APPEND INITIAL LINE TO gt_bapiret2.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PARK_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_POST_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_post_document  USING    fu_belnr fu_gjahr.
  DATA : return           TYPE STANDARD TABLE OF bapiret2,
         ls_return        LIKE LINE OF return,
         ls_out           LIKE LINE OF gt_out.

  DATA : lt_stylerow      TYPE lvc_t_styl,
         ls_stylerow      TYPE lvc_s_styl.

  DATA : lv_lines         TYPE i.

  CASE 'X'.
    WHEN radio1.
      CALL FUNCTION 'BAPI_INCOMINGINVOICE_POST'
        EXPORTING
          invoicedocnumber = fu_belnr
          fiscalyear       = fu_gjahr
        TABLES
          return           = return.

      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        CLEAR ls_out-mark.
        ls_stylerow-fieldname = 'MARK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_out-style.
        MODIFY TABLE gt_out FROM ls_out
                            TRANSPORTING mark style.
        CLEAR ls_out.
      ENDIF.

      LOOP AT return INTO ls_return WHERE type = 'E'.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ENDLOOP.

    WHEN radio2.
      CLEAR : gt_bapiret2[].

      CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
        EXPORTING
          headerdata       = headerdata
        IMPORTING
          invoicedocnumber = ls_out-belnr
          fiscalyear       = ls_out-gjahr
        TABLES
          itemdata         = itemdata
          glaccountdata    = glaccountdata
          materialdata     = materialdata
          return           = return.

      IF ls_out-belnr IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        CLEAR ls_out-mark.
        ls_stylerow-fieldname = 'MARK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_out-style.

        MODIFY TABLE gt_out FROM ls_out
                            TRANSPORTING belnr gjahr mark style.
        CLEAR ls_out.
      ELSE.
        ls_out-icon = icon_led_red.
        MODIFY TABLE gt_out FROM ls_out
                            TRANSPORTING icon.
        CLEAR ls_out.
      ENDIF.

      LOOP AT return INTO ls_return WHERE type = 'E'.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ENDLOOP.

      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_POST_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out   LIKE LINE OF gt_out.

  CASE fu_column.
    WHEN 'BELNR'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        SET PARAMETER ID 'BUK' FIELD ls_out-bukrs.
        SET PARAMETER ID 'BLP' FIELD ls_out-belnr.
        SET PARAMETER ID 'GJR' FIELD ls_out-gjahr.
        CALL TRANSACTION 'FBV3' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK
