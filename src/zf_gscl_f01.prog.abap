*&---------------------------------------------------------------------*
*&  Include           ZCO_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CLEAR: gt_excel,gt_upload.
  gv_repid = sy-repid.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'HID' '0' '' '' ''.

  CASE 'X'.
    WHEN p_upld OR p_down.
      PERFORM f_modify_screen USING : 'KUN' '0' '' '' ''.
      PERFORM f_modify_screen USING : 'MKL' '0' '' '' ''.
      PERFORM f_modify_screen USING : 'PER' '0' '' '' ''.
      IF p_down = 'X'.
        PERFORM f_modify_screen USING : 'FLN' '0' '' '' ''.
      ENDIF.
    WHEN p_chng.
      PERFORM f_modify_screen USING : 'FLN' '0' '' '' ''.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  CASE 'X'.
    WHEN p_upld.
      IF pa_fname IS INITIAL.
        PERFORM f_error_message USING 'FLN' 'Filename required entries'.
      ENDIF.
    WHEN p_chng.
*      IF p_bukrs IS INITIAL.
*        PERFORM f_error_message USING 'BUK' 'Filename required entries'.
*      ENDIF.
*      IF p_gsber IS INITIAL.
*        PERFORM f_error_message USING 'GSB' 'Filename required entries'.
*      ENDIF.
*      IF p_anlkl IS INITIAL.
*        PERFORM f_error_message USING 'ANK' 'Filename required entries'.
*      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

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
  CASE 'X'.
    WHEN p_upld.
      PERFORM f_upload_xls.
    WHEN p_chng.
      PERFORM f_select_data.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_XLS
*&---------------------------------------------------------------------*
FORM f_upload_xls.
  DATA: ls_stylerow TYPE lvc_s_styl.

  CALL METHOD zcl_util=>m_upload_excel_to_itab_v3
    EXPORTING
      pvi_table = 'ZSTCLNUMBER'
      pvi_bcol  = p_cbegin
      pvi_ecol  = p_cend
      pvi_brow  = p_rbegin
      pvi_erow  = p_rend
      pv_filenm = pa_fname
    IMPORTING
      pto_data  = gt_excel[].

  IF gt_excel[] IS INITIAL.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.

  ELSE.
    SELECT kdgrp, datab, datbi, matkl INTO TABLE @DATA(lt_zclnumber)
      FROM zclnumber FOR ALL ENTRIES IN @gt_excel
      WHERE kdgrp = @gt_excel-kdgrp
        AND datab = @gt_excel-datab
        AND datbi = @gt_excel-datbi
        AND matkl = @gt_excel-matkl.

    LOOP AT gt_excel INTO DATA(ls_excel).
      IF ls_excel IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO gt_upload ASSIGNING FIELD-SYMBOL(<fs_upload>).
      MOVE-CORRESPONDING ls_excel TO <fs_upload>.
*      <fs_upload>-kunnr = |{ <fs_upload>-kunnr ALPHA = IN }|.
*      <fs_upload>-wgbez60 = VALUE #( lt_t023t[ matkl = <fs_upload>-matkl ]-wgbez60 OPTIONAL ).

      IF line_exists( lt_zclnumber[ kdgrp = ls_excel-kdgrp
                                    datab = ls_excel-datab
                                    datbi = ls_excel-datbi
                                    matkl = ls_excel-matkl ] ).
        <fs_upload>-icon = icon_red_light.
        <fs_upload>-msg = 'CL Number already upload'.

        CASE 'X'.
          WHEN p_chng.
            ls_stylerow-fieldname = 'MARK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO <fs_upload>-style.
            CLEAR ls_stylerow .
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    SORT gt_upload BY kdgrp datab datbi matkl.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_DATA
*&---------------------------------------------------------------------*
FORM f_select_data .
  SELECT * INTO TABLE @DATA(lt_zclnumber)
    FROM zclnumber WHERE kdgrp IN @s_kdgrp
                     AND datab BETWEEN @p_datab AND @p_datbi
                     AND ( datbi BETWEEN @p_datab AND @p_datbi OR datbi GE @p_datbi )
                     AND matkl IN @s_matkl.

  IF sy-subrc = 0.
*    SELECT * INTO TABLE @DATA(lt_t023t)
*      FROM t023t FOR ALL ENTRIES IN @lt_zclnumber
*      WHERE spras = @sy-langu
*        AND matkl = @lt_zclnumber-matkl.

    LOOP AT lt_zclnumber INTO DATA(ls_zclnumber).
      APPEND INITIAL LINE TO gt_upload ASSIGNING FIELD-SYMBOL(<fs_upload>).
      MOVE-CORRESPONDING ls_zclnumber TO <fs_upload>.
*      <fs_upload>-wgbez60 = VALUE #( lt_t023t[ matkl = <fs_upload>-matkl ]-wgbez60 OPTIONAL ).
    ENDLOOP.

  ELSE.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_upload[] IS NOT INITIAL.
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
  DATA: fcode        TYPE TABLE OF sy-ucomm,
        lv_title(50).

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  CASE 'X'.
    WHEN p_upld.
      dynpost-icon_id      = icon_create.
      dynpost-icon_text    = 'Create'.
    WHEN p_chng.
      dynpost-icon_id      = icon_delete.
      dynpost-icon_text    = 'Delete'.
  ENDCASE.

  IF gv_post = 'P'.
    APPEND INITIAL LINE TO fcode ASSIGNING FIELD-SYMBOL(<fs_fcode>).
    <fs_fcode> = '&POS'.
  ENDIF.

  CASE 'X'.
    WHEN p_upld.
      IF NOT line_exists( gt_upload[ icon = space ] ).
        APPEND INITIAL LINE TO fcode ASSIGNING <fs_fcode>.
        <fs_fcode> = '&POS'.
      ENDIF.
    WHEN p_chng.
*      IF NOT line_exists( gt_upload[ icon = icon_green_light ] ).
*        APPEND INITIAL LINE TO fcode ASSIGNING <fs_fcode>.
*        <fs_fcode> = '&POS'.
*      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  CASE 'X'.
    WHEN p_upld.
      lv_title = 'Upload CL Number'.
      SET TITLEBAR 'TITLE' WITH lv_title.
    WHEN p_chng.
      lv_title = 'Delete CL Number'.
      SET TITLEBAR 'TITLE' WITH lv_title.
  ENDCASE.
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
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  DATA : lt_xout     TYPE STANDARD TABLE OF ty_out,
         ls_xout     LIKE LINE OF lt_xout,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_belnr TYPE belnr_d,
         lv_gjahr TYPE gjahr.

  DATA : lv_icon(4),
         lv_lines       TYPE i.

  DATA: lt_zfidt016 TYPE TABLE OF zfidt016,
        lv_afabg    TYPE afabg.

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
        CASE 'X'.
          WHEN p_upld.
            IF line_exists( gt_upload[ icon = space ] ).
*              MESSAGE 'Masih ada data ERROR' TYPE 'S' DISPLAY LIKE 'E'.
*            ELSE.
              DELETE gt_upload WHERE icon = icon_red_light.
              PERFORM f_update_table CHANGING gv_post.
            ENDIF.
            PERFORM f_alv_refresh USING 'X'.

          WHEN p_chng.
            IF line_exists( gt_upload[ mark = 'X' ] ).
              PERFORM f_update_table CHANGING gv_post.
            ELSE.
              MESSAGE 'No data selected' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
            PERFORM f_alv_refresh USING 'X'.

        ENDCASE.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

*      gt_xout[] = gt_out[].

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
        it_outtab            = gt_upload[]
        it_fieldcatalog      = gt_main_fieldcat[].

*    gt_xout[] = gt_out[].
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

*  PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  CASE 'X'.
    WHEN p_upld.
    WHEN p_chng.
      PERFORM f_dyn_int_table USING :
        'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' '' 'X' 'X' '' '' ''.
  ENDCASE.

  PERFORM f_dyn_int_table USING :
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' '' 'X' 'X' '' '' '',
    'KDGRP' '' '' '' '' '' '' 'KDGRP' 'ZSTCLNUMBER' '' '' '' '' '' '' '' 'X' '' '' '' '',
    'DATAB' '' '' '' '' '' '' 'DATAB' 'ZSTCLNUMBER' '' '' '' '' '' '' '' 'X' '' '' '' '',
    'DATBI' '' '' '' '' '' '' 'DATBI' 'ZSTCLNUMBER' '' '' '' '' '' '' '' 'X' '' '' '' '',
    'MATKL' '' '' '' '' '' '' 'MATKL' 'ZSTCLNUMBER' '' '' '' '' '' '' '' 'X' '' '' '' '',
*    'WGBEZ60' '' '' '' '' '' '' 'WGBEZ60' 'T023T' '' '' '' '' '' '' '' '' '' '' '' '',
    'SKPNR' '' '' '' '' '' '' 'SKPNR' 'ZSTCLNUMBER' '' '' '' '' '' '' '' '' '' '' '' '',
    'CLNR' '' '' '' '' '' '' 'CLNR' 'ZSTCLNUMBER' '' '' '' '' '' '' '' '' '' '' '' '',
    'MSG' '' '' '' '' '' '' '' '' 'Message' '' '' '' '' '' '' '' '' '' '' ''.
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
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.
  DATA : lt_filtered TYPE lvc_t_fidx.

  g_tabgrid->get_filtered_entries( IMPORTING et_filtered_entries = lt_filtered ).

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_upload INTO DATA(ls_upload).
        READ TABLE lt_filtered WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          READ TABLE ls_upload-style INTO ls_stylerow
                                     WITH KEY fieldname = 'MARK'.
          IF sy-subrc = 0 AND ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            ls_upload-mark = fu_check.
            MODIFY gt_upload FROM ls_upload.
            CLEAR ls_upload.
          ENDIF.
        ENDIF.
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
*&      Form  F_GET_DATA_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_get_data_download .
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.

  SET PROPERTY OF h_excel 'Visible' = 1.

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  CALL METHOD OF h_mapl 'Add' = h_map.

  PERFORM fill_cell USING 1 1 1 'Customer Group'.
  PERFORM fill_cell USING 1 2 1 'Period From'.
  PERFORM fill_cell USING 1 3 1 'Period To'.
  PERFORM fill_cell USING 1 4 1 'Material Group'.
  PERFORM fill_cell USING 1 5 1 'SKP Number'.
  PERFORM fill_cell USING 1 6 1 'CL Number'.

  FREE OBJECT h_excel.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM FILL_CELL                                                *
*---------------------------------------------------------------------*
*       sets cell at coordinates i,j to value val boldtype bold       *
*---------------------------------------------------------------------*
FORM fill_cell USING i j bold val.
  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = i #2 = j.
  SET PROPERTY OF h_zl 'Value' = val .
  GET PROPERTY OF h_zl 'Font' = h_f.
  SET PROPERTY OF h_f 'Bold' = bold .
ENDFORM.                    "fill_cell

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table CHANGING fc_post.
  DATA: ls_stylerow TYPE lvc_s_styl.

  CLEAR gt_zclnumber.

  CASE 'X'.
    WHEN p_upld.
      gt_zclnumber = CORRESPONDING #( gt_upload ).
      INSERT zclnumber FROM TABLE gt_zclnumber.
      IF sy-subrc = 0.
        fc_post = 'P'.
        MESSAGE 'Data has been saved' TYPE 'S'.
      ENDIF.

    WHEN p_chng.
      gt_zclnumber = VALUE #( FOR wa IN gt_upload WHERE ( mark = 'X' )
                            ( CORRESPONDING #( wa ) ) ).
      DELETE zclnumber FROM TABLE gt_zclnumber.
      IF sy-subrc = 0.
        fc_post = 'P'.
        MESSAGE 'Data has been delete' TYPE 'S'.

        LOOP AT gt_zclnumber INTO DATA(ls_zclnumber).
          LOOP AT gt_upload ASSIGNING FIELD-SYMBOL(<fs_upload>)
                            WHERE kdgrp = ls_zclnumber-kdgrp
                              AND datab = ls_zclnumber-datab
                              AND datbi = ls_zclnumber-datbi
                              AND matkl = ls_zclnumber-matkl.
            CLEAR <fs_upload>-mark.
            READ TABLE <fs_upload>-style WITH KEY fieldname = 'MARK'
                                         TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              ls_stylerow-fieldname = 'MARK'.
              ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
              APPEND ls_stylerow TO <fs_upload>-style.
              CLEAR ls_stylerow .
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.
