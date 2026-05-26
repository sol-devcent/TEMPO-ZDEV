*&---------------------------------------------------------------------*
*&  Include           ZFI_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : lv_period(7).

  CONCATENATE so_sptag-high+4(2) '.'
              so_sptag-high(4)
  INTO lv_period.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_selection_date.
      gv_bktxt  = 'Kompensasi Sponsorship'.
      CONCATENATE 'Kompensasi Sponsorship per' lv_period
      INTO gv_sgtxt
      SEPARATED BY space.
      gv_zdistp = 'B'.
    WHEN radio2.
      PERFORM f_modify_selection_date.
      gv_bktxt = 'Claim Discount'.
      CONCATENATE 'Kompensasi Customer Specific TRD DISC per' lv_period
      INTO gv_sgtxt
      SEPARATED BY space.
      gv_zdistp = 'F'.
    WHEN radio3.
      PERFORM f_modify_selection_date.
      gv_bktxt = 'Claim Discount'.
      CONCATENATE 'Kompensasi Customer Specific TRD DISC per' lv_period
      INTO gv_sgtxt
      SEPARATED BY space.
      gv_zdistp = 'F3'.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'PVA' '0' '' '' ''.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'SXB' '0' '' '' '',
                                      'SPR' '' '0' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SXB' '0' '' '' '',
                                      'SPR' '' '0' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SXB' '0' '' '' '',
                                      'SPR' '' '0' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'SPR' '' '0' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'SPR' '' '0' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF so_sptag[] IS INITIAL.
    PERFORM f_error_message USING 'SSP' ''.
  ELSE.
    IF so_sptag-high IS NOT INITIAL.
      IF so_sptag-low(6) <> so_sptag-high(6).
        PERFORM f_error_message USING 'SSP' 'The process must be within the same month'.
      ENDIF.
    ENDIF.
  ENDIF.
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
*&      Form  F_MODIFY_SELECTION_DATE
*&---------------------------------------------------------------------*
FORM f_modify_selection_date .
  DATA : lv_sptag     TYPE s626-sptag,
         lr_date      TYPE RANGE OF p,
         ls_date      LIKE LINE OF lr_date.

  ls_date-low    = 29.
  ls_date-high   = 31.
  ls_date-sign   = 'I'.
  ls_date-option = 'BT'.
  APPEND ls_date TO lr_date.

  IF so_sptag-high IS INITIAL.
    so_sptag-option = 'BT'.
    so_sptag-high   = so_sptag-low.
  ENDIF.

*  IF so_sptag-high+6(2) IN lr_date.
*    PERFORM f_last_day_of_month CHANGING so_sptag-high.
*  ENDIF.
*
*  MODIFY so_sptag INDEX 1.

  gv_budat  = so_sptag-high.
ENDFORM.                    " F_MODIFY_SELECTION_DATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_get_s626.
    WHEN radio2.
      PERFORM f_get_s626.
    WHEN radio3.
      PERFORM f_get_s626.
    WHEN radio4.
      PERFORM f_get_zfidt001.
    WHEN radio5.
      PERFORM f_get_zfidt001.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_discount_b.
    WHEN radio2.
      PERFORM f_discount_f.
    WHEN radio3.
      PERFORM f_discount_f3.
    WHEN radio4.
      PERFORM f_prepare_display.
    WHEN radio5.
      PERFORM f_prepare_report.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio5.
      IF gt_claimdisc[] IS NOT INITIAL.
        CALL SCREEN 101.
      ELSE.
        MESSAGE s000(zab) WITH 'No data found' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN OTHERS.
      IF gt_out[] IS NOT INITIAL.
        CALL SCREEN 101.
      ELSE.
        MESSAGE s000(zab) WITH 'No data found' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
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
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         lv_t1(20),
         lv_text(50).

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  IF gt_001[] IS INITIAL.
    APPEND '&POS' TO fcode.
  ELSE.
    APPEND '&SIM' TO fcode.
  ENDIF.

  CASE 'X'.
    WHEN radio4.
      CLEAR fcode[].
      APPEND '&SIM' TO fcode.
    WHEN radio5.
      APPEND '&POS' TO fcode.
      APPEND '&SIM' TO fcode.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  CASE 'X'.
    WHEN radio1.
      lv_text = 'Claim Discount'.
      lv_t1   = 'B'.
    WHEN radio2.
      lv_text = 'Claim Discount'.
      lv_t1   = 'F'.
    WHEN radio3.
      lv_text = 'Claim Discount'.
      lv_t1   = 'F3'.
    WHEN radio4.
      lv_text = 'Reprint Claim Discount'.
    WHEN radio5.
      lv_text = 'Report Claim Discount'.
  ENDCASE.

  SET TITLEBAR 'TITLE' WITH lv_text lv_t1.
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

    WHEN '&SIM'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
            PERFORM f_posting_data USING 'X'.
            CLEAR : gt_001[], gt_error[].
          WHEN radio2.
            PERFORM f_posting_data USING 'X'.
            CLEAR : gt_001[], gt_error[].
          WHEN radio3.
            PERFORM f_posting_data USING 'X'.
            CLEAR : gt_001[], gt_error[].
          WHEN radio4.
            PERFORM f_prepare_reprint.
            PERFORM f_print_form.
        ENDCASE.
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

    CASE 'X'.
      WHEN radio5.
        CALL METHOD g_tabgrid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout_alv
            i_save               = 'A'
            is_variant           = gs_variant
            i_default            = 'X'
            it_toolbar_excluding = gs_exclude
          CHANGING
            it_sort              = gt_main_sort[]
            it_outtab            = gt_claimdisc[]
            it_fieldcatalog      = gt_main_fieldcat[].
      WHEN OTHERS.
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
    ENDCASE.

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
  IF radio5 = space.
    gs_layout_alv-stylefname          = 'STYLE'.
    gs_layout_alv-ctab_fname          = 'COLOR'.
  ENDIF.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_alv_sort USING : 1 'VKBUR' 'X' '' '',
                                 2 'ZDNCN' '' 'X' '',
                                 3 'SPTAG' 'X' '' '',
                                 4 'VBELN' 'X' '' 'X'.
    WHEN radio2.
      PERFORM f_alv_sort USING : 1 'VKBUR' 'X' '' '',
                                 2 'ZDNCN' '' 'X' '',
                                 3 'SPTAG' 'X' '' '',
                                 4 'VBELN' 'X' '' 'X'.
    WHEN radio3.
      PERFORM f_alv_sort USING : 1 'VKBUR' 'X' '' '',
                                 2 'ZDNCN' '' 'X' 'X'.
    WHEN radio4.
      PERFORM f_alv_sort USING : 1 'VKBUR' 'X' '' '',
                                 2 'ZDISTP' 'X' '' '',
                                 2 'BELNR' 'X' '' 'X'.
    WHEN radio5.
      PERFORM f_alv_sort USING : 1 'VKBUR' 'X' '' '',
                                 2 'SPTAG' 'X' '' '',
                                 3 'VBELN' 'X' '' ''.
  ENDCASE.
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
  CASE 'X'.
    WHEN radio1.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
    WHEN radio2.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
    WHEN radio3.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
    WHEN radio4.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
    WHEN radio5.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_claimdisc.
  ENDCASE.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ICON'.
        CASE 'X'.
          WHEN radio4.
            CONTINUE.
        ENDCASE.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Sts' '4' '' '' '' '' '' '' 'X' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ZDNCN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Type' '4' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VBTYP'.
        CONTINUE.
      WHEN 'ZDISTP'.
        CASE 'X'.
          WHEN radio1.
            CONTINUE.
          WHEN radio2.
            CONTINUE.
          WHEN radio3.
            CONTINUE.
        ENDCASE.
      WHEN 'XBLNR'.
        CASE 'X'.
          WHEN radio1.
            CONTINUE.
          WHEN radio2.
            CONTINUE.
          WHEN radio3.
            CONTINUE.
          WHEN radio4.
            PERFORM f_change_dyn_fieldcat USING :
            '' '' '' '' '' 'No. Claim Disc.' '' '' '' '' '' '' '' '' 'X' ''
            CHANGING ls_fieldcat.
          WHEN radio5.
            CONTINUE.
        ENDCASE.
      WHEN 'XBLN1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No. Claim Disc B' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'XBLN2'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No. Claim Disc F' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'XBLN3'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No. Claim Disc F3' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'UMKZWI1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'STWAE' '' '' '' 'Gross Sales' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'GUKZWI1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'STWAE' '' '' '' 'Return Sales' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
    ENDCASE.

    CASE ls_dfies-datatype.
      WHEN 'CURR'.
        CASE 'X'.
          WHEN radio1.
            CASE ls_dfies-fieldname.
              WHEN 'DISC'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc B' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc B Fin' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN OTHERS.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
            ENDCASE.
          WHEN radio2.
            CASE ls_dfies-fieldname.
              WHEN 'DISC'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F Fin' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN OTHERS.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
            ENDCASE.
          WHEN radio3.
            CASE ls_dfies-fieldname.
              WHEN 'DISC'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F3' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F3 Fin' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN OTHERS.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
            ENDCASE.
          WHEN radio4.
            CASE ls_dfies-fieldname.
              WHEN 'ZDISTP'.
                PERFORM f_change_dyn_fieldcat USING :
                '' '' '' '' '' 'Disc Type' '' '' '' '' '' '' '' '' '' ''
                CHANGING ls_fieldcat.
              WHEN 'DISC'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc Fin' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN OTHERS.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
            ENDCASE.
          WHEN radio5.
            CASE ls_dfies-fieldname.
              WHEN 'DISC1'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc B' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF1'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc Fin B' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'MWSBK1'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'PPN Disc B' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISC2'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF2'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc Fin F' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'MWSBK2'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'PPN Disc F' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISC3'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc F3' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'DISCF3'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'Disc Fin F3' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN 'MWSBK3'.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' 'PPN Disc F3' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
              WHEN OTHERS.
                PERFORM f_change_dyn_fieldcat USING :
                '' 'STWAE' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
                CHANGING ls_fieldcat.
            ENDCASE.
        ENDCASE.
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
FORM f_posting_data USING fu_post.
  DATA : obj_type           LIKE bapiache09-obj_type,
         documentheader     LIKE bapiache09,
         accountgl          LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
         accountpayable     LIKE TABLE OF bapiacap09 WITH HEADER LINE,
         accountreceivable  LIKE TABLE OF bapiacar09 WITH HEADER LINE,
         extension1         LIKE TABLE OF bapiacextc WITH HEADER LINE,
         currencyamount     LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
         criteria           LIKE TABLE OF bapiackec9 WITH HEADER LINE,
         return             LIKE TABLE OF bapiret2 WITH HEADER LINE.

  DATA : lt_xout            TYPE STANDARD TABLE OF ty_out,
         ls_xout            LIKE LINE OF lt_xout,
         lv_subrc           TYPE sy-subrc.

  DATA : lv_belnr           TYPE bkpf-belnr,
         lv_gjahr           TYPE bkpf-gjahr.

  lt_xout[] = gt_out[].
  IF fu_post IS INITIAL.
    DELETE lt_xout WHERE mark = space.
  ELSE.
    DELETE lt_xout WHERE mark = space OR
                         icon <> icon_led_green.
  ENDIF.

  LOOP AT lt_xout INTO ls_xout.
    PERFORM f_prepare_header CHANGING documentheader.
    PERFORM f_prepare_detail TABLES accountgl accountpayable accountreceivable
                                    currencyamount extension1 criteria
                             USING ls_xout-vkbur ls_xout-vbeln ls_xout-zdncn fu_post
                             CHANGING lv_subrc.
    IF lv_subrc <> 0.
      MESSAGE s000(zab) WITH 'Number range not yet maintain' DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      documentheader-ref_doc_no = gv_zuonr.
    ENDIF.

    IF fu_post IS INITIAL.
      PERFORM f_bapi_document_check TABLES accountgl accountpayable accountreceivable
                                           currencyamount extension1 criteria return
                                    USING documentheader obj_type
                                          ls_xout-vkbur ls_xout-vbeln ls_xout-zdncn.
    ELSE.
      PERFORM f_bapi_document_post TABLES accountgl accountpayable accountreceivable
                                          currencyamount extension1 criteria return
                                   USING documentheader obj_type ls_xout-vkbur
                                         ls_xout-vbeln ls_xout-vbtyp
                                   CHANGING lv_belnr lv_gjahr.

      PERFORM f_save_data ON COMMIT.

      IF gv_subrc = 0.
        CLEAR : gv_belnr, gv_gjahr.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        PERFORM f_change_bline_date TABLES accountgl
                                    USING documentheader-doc_type lv_belnr pa_bukrs lv_gjahr gv_budat.
        gv_belnr = lv_belnr.
        gv_gjahr = lv_gjahr.
      ELSE.
        CLEAR gv_subrc.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_head[] IS NOT INITIAL.
    PERFORM f_modify_ppn.
    PERFORM f_print_form.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum
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
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
FORM f_last_day_of_month  CHANGING fc_sptag.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fc_sptag
    IMPORTING
      last_day_of_month = fc_sptag
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
ENDFORM.                    " F_LAST_DAY_OF_MONTH

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POST_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_post_data .

ENDFORM.                    " F_PREPARE_POST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_HEADER
*&---------------------------------------------------------------------*
FORM f_prepare_header  CHANGING documentheader   TYPE bapiache09.
  CLEAR : documentheader.

  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = pa_bukrs.
  documentheader-doc_date   = gv_budat.
  documentheader-pstng_date = gv_budat.
  documentheader-doc_type   = 'DR'.
  documentheader-header_txt = gv_bktxt.
ENDFORM.                    " F_PREPARE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   accountgl         STRUCTURE bapiacgl09
                                accountpayable    STRUCTURE bapiacap09
                                accountreceivable STRUCTURE bapiacar09
                                currencyamount    STRUCTURE bapiaccr09
                                extension1        STRUCTURE bapiacextc
                                criteria          STRUCTURE bapiackec9
                       USING    fu_vkbur fu_vbeln fu_zdncn fu_post
                       CHANGING fc_subrc.
  DATA : ls_out             LIKE LINE OF gt_out,
         lv_zdncn(2),
         lv_text(4),
         lv_discf           TYPE s626-zdisb1,
         lv_vat             TYPE s626-zdisb1,
         lv_total           TYPE s626-zdisb1,
         lv_count           TYPE i,
         lv_buzei           TYPE bseg-buzei,
         lv_bschl           TYPE bseg-bschl,
         lv_bsch1           TYPE bseg-bschl,
         lv_bsch2           TYPE bseg-bschl,
         lv_koart           TYPE bseg-koart,
         lv_koar1           TYPE bseg-koart,
         lv_koar2           TYPE bseg-koart,
         lv_sgtxt           TYPE bseg-sgtxt,
         lv_gsber           TYPE bseg-gsber,
         lv_kunnr           TYPE bseg-kunnr,
         lv_hkont           TYPE bseg-hkont,
         lv_hkvat           TYPE bseg-hkont,
         lv_number(8),
         lv_object          TYPE inri-object,
         lv_vbund           TYPE bseg-vbund.

  CLEAR : accountgl[], accountpayable[], accountreceivable[],
          currencyamount[], extension1[], criteria[].

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        ADD ls_out-discf TO lv_discf.
        ADD ls_out-disc TO lv_total.
        lv_zdncn  = ls_out-zdncn.
      ENDLOOP.
    WHEN radio2.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        ADD ls_out-discf TO lv_discf.
        ADD ls_out-disc TO lv_total.
        lv_zdncn  = ls_out-zdncn.
      ENDLOOP.
    WHEN radio3.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND zdncn = fu_zdncn.
        ADD ls_out-discf TO lv_discf.
        ADD ls_out-disc TO lv_total.
        lv_zdncn  = ls_out-zdncn.
      ENDLOOP.
  ENDCASE.

  CASE lv_zdncn.
    WHEN 'DN'.
      lv_bsch1     = '01'.
      lv_bsch2     = '50'.
      lv_koar1     = 'D'.
      lv_koar2     = 'S'.
      lv_object    = 'ZFICLADISC'.
      lv_text      = '/DN/'.

    WHEN 'CN'.
      lv_bsch1     = '11'.
      lv_bsch2     = '40'.
      lv_koar1     = 'D'.
      lv_koar2     = 'S'.
      lv_object    = 'ZFICLDISCN'.
      lv_text      = '/KN/'.
  ENDCASE.

  CLEAR gv_zuonr.

  lv_gsber    = '0200'.
  lv_kunnr    = '3800000002'.
  lv_hkont    = '0122310400'.
  lv_vbund    = 'UNILEV'.

  lv_koart    = 'S'.
  lv_bschl    = '50'.
  lv_hkvat    = '0315300100'.

  PERFORM f_get_next_number USING lv_object fu_post
                            CHANGING lv_number fc_subrc.

  CONCATENATE 'UNI'
              lv_number(4)
              lv_text
              lv_number+4(4)
  INTO gv_zuonr.

  IF fc_subrc = 0.
    ADD 1 TO lv_count.
    lv_buzei  = lv_count.

    IF pa_vat IS INITIAL.
      lv_total = lv_discf.
    ENDIF.

    CASE 'X'.
      WHEN radio1.
*        IF fu_vkbur = '0246'.
        PERFORM f_calc_vat USING lv_discf
                           CHANGING lv_vat.
        lv_total = lv_discf + lv_vat.
*        ENDIF.
      WHEN radio2.
*        IF fu_vkbur = '0246'.
        PERFORM f_calc_vat USING lv_discf
                           CHANGING lv_vat.
        lv_total = lv_discf + lv_vat.
*        ENDIF.
      WHEN radio3.
        PERFORM f_calc_vat USING lv_discf
                           CHANGING lv_vat.
        lv_total = lv_discf + lv_vat.
    ENDCASE.

    PERFORM f_line_post TABLES  accountgl
                                accountpayable
                                accountreceivable
                                currencyamount
                                extension1
                                criteria
                        USING lv_bsch1 lv_koar1 lv_buzei gv_sgtxt lv_total   " lv_discf
                              lv_gsber lv_kunnr '' lv_vbund.

    IF pa_vat IS NOT INITIAL.
      CASE 'X'.
        WHEN radio1.
*          IF fu_vkbur = '0246'.
          PERFORM f_calc_vat USING lv_discf
                             CHANGING lv_vat.
          lv_total = lv_discf + lv_vat.
*          ELSE.
*            lv_vat  = lv_total - lv_discf.
*          ENDIF.
        WHEN radio2.
*          IF fu_vkbur = '0246'.
          PERFORM f_calc_vat USING lv_discf
                             CHANGING lv_vat.
          lv_total = lv_discf + lv_vat.
*          ELSE.
*            lv_vat  = lv_total - lv_discf.
*        ENDIF.
        WHEN radio3.
          PERFORM f_calc_vat USING lv_discf
                             CHANGING lv_vat.
          lv_total = lv_discf + lv_vat.
      ENDCASE.

      ADD 1 TO lv_count.
      lv_buzei  = lv_count.
      PERFORM f_line_post TABLES  accountgl
                                  accountpayable
                                  accountreceivable
                                  currencyamount
                                  extension1
                                  criteria
                          USING lv_bschl lv_koart lv_buzei gv_sgtxt lv_vat
                                lv_gsber '' lv_hkvat lv_vbund.
    ENDIF.

    ADD 1 TO lv_count.
    lv_buzei  = lv_count.
    PERFORM f_line_post TABLES  accountgl
                                accountpayable
                                accountreceivable
                                currencyamount
                                extension1
                                criteria
                        USING lv_bsch2 lv_koar2 lv_buzei gv_sgtxt lv_discf
                              lv_gsber '' lv_hkont lv_vbund.
  ENDIF.
ENDFORM.                    " F_PREPARE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_CHECK
*&---------------------------------------------------------------------*
FORM f_bapi_document_check  TABLES   accountgl         STRUCTURE bapiacgl09
                                     accountpayable    STRUCTURE bapiacap09
                                     accountreceivable STRUCTURE bapiacar09
                                     currencyamount    STRUCTURE bapiaccr09
                                     extension1        STRUCTURE bapiacextc
                                     criteria          STRUCTURE bapiackec9
                                     return            STRUCTURE bapiret2
                            USING    documentheader    STRUCTURE bapiache09
                                     obj_type
                                     fu_vkbur fu_vbeln fu_zdncn.

  DATA : lv_error     TYPE i,
         ls_error     LIKE LINE OF gt_error,
         ls_out       LIKE LINE OF gt_out,
         ls_001       LIKE LINE OF gt_001.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  LOOP AT return.
    IF return-type = 'A' OR return-type = 'E'.
      MOVE-CORRESPONDING return TO ls_error.
      lv_error          = 1.
      IF return-id NE 'RW' OR
        return-number NE '609'.
        ls_error-vbeln = fu_vbeln.
        APPEND ls_error TO gt_error.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        IF lv_error IS NOT INITIAL.
          ls_out-icon  = icon_led_red.
        ELSE.
          ls_out-icon  = icon_led_green.
          MOVE-CORRESPONDING ls_out TO ls_001.
          ls_001-bukrs    = pa_bukrs.
          ls_001-fkdat    = ls_out-sptag.
          ls_001-zdisc    = ls_out-disc.
          ls_001-zdiscf   = ls_out-discf.
          APPEND ls_001 TO gt_001.
          CLEAR ls_001.
        ENDIF.
        MODIFY gt_out FROM ls_out TRANSPORTING icon.
      ENDLOOP.
    WHEN radio2.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        IF lv_error IS NOT INITIAL.
          ls_out-icon  = icon_led_red.
        ELSE.
          ls_out-icon  = icon_led_green.
          MOVE-CORRESPONDING ls_out TO ls_001.
          ls_001-bukrs    = pa_bukrs.
          ls_001-fkdat    = ls_out-sptag.
          ls_001-zdisc    = ls_out-disc.
          ls_001-zdiscf   = ls_out-discf.
          APPEND ls_001 TO gt_001.
          CLEAR ls_001.
        ENDIF.
        MODIFY gt_out FROM ls_out TRANSPORTING icon.
      ENDLOOP.
    WHEN radio3.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND zdncn = fu_zdncn.
        IF lv_error IS NOT INITIAL.
          ls_out-icon  = icon_led_red.
        ELSE.
          ls_out-icon  = icon_led_green.
          MOVE-CORRESPONDING ls_out TO ls_001.
          ls_001-bukrs    = pa_bukrs.
          ls_001-fkdat    = ls_out-sptag.
          ls_001-zdisc    = ls_out-disc.
          ls_001-zdiscf   = ls_out-discf.
          APPEND ls_001 TO gt_001.
          CLEAR ls_001.
        ENDIF.
        MODIFY gt_out FROM ls_out TRANSPORTING icon.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_BAPI_DOCUMENT_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_bapi_document_post  TABLES   accountgl         STRUCTURE bapiacgl09
                                    accountpayable    STRUCTURE bapiacap09
                                    accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    criteria          STRUCTURE bapiackec9
                                    return            STRUCTURE bapiret2
                            USING   documentheader    STRUCTURE bapiache09
                                    obj_type fu_vkbur fu_vbeln fu_vbtyp
                            CHANGING fc_belnr fc_gjahr.

  DATA : ls_out         LIKE LINE OF gt_out,
         lv_error       TYPE i,
         ls_error       LIKE LINE OF gt_error,
         ls_001         LIKE LINE OF gt_001,
         lv_belnr       TYPE bkpf-belnr,
         lv_gjahr       TYPE bkpf-gjahr.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  LOOP AT return.
    IF return-type = 'A' OR return-type = 'E'.
      MOVE-CORRESPONDING return TO ls_error.
      lv_error          = 1.
      IF return-id NE 'RW' OR
        return-number NE '609'.
        ls_error-vbeln = fu_vbeln.
        APPEND ls_error TO gt_error.
      ENDIF.
    ELSE.
      lv_belnr   = return-message_v2(10).
      lv_gjahr   = return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

  fc_belnr  = lv_belnr.
  fc_gjahr  = lv_gjahr.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        PERFORM f_modify_table USING ls_out lv_error lv_belnr lv_gjahr.
        CLEAR ls_out.
      ENDLOOP.
      CLEAR : gt_save[].
      LOOP AT gt_001 INTO ls_001 WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        PERFORM f_prepare_save USING ls_001 lv_belnr lv_gjahr
                                     documentheader-doc_date documentheader-pstng_date.
        CLEAR ls_001.
      ENDLOOP.
    WHEN radio2.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        PERFORM f_modify_table USING ls_out lv_error lv_belnr lv_gjahr.
        CLEAR ls_out.
      ENDLOOP.
      CLEAR : gt_save[].
      LOOP AT gt_001 INTO ls_001 WHERE vkbur = fu_vkbur
                                   AND vbeln = fu_vbeln.
        PERFORM f_prepare_save USING ls_001 lv_belnr lv_gjahr
                                     documentheader-doc_date documentheader-pstng_date.
        CLEAR ls_001.
      ENDLOOP.
    WHEN radio3.
      LOOP AT gt_out INTO ls_out WHERE vkbur = fu_vkbur
                                   AND vbtyp = fu_vbtyp.
        PERFORM f_modify_table USING ls_out lv_error lv_belnr lv_gjahr.
        CLEAR ls_out.
      ENDLOOP.
      CLEAR : gt_save[].
      LOOP AT gt_001 INTO ls_001 WHERE vkbur = fu_vkbur
                                   AND vbtyp = fu_vbtyp.
        PERFORM f_prepare_save USING ls_001 lv_belnr lv_gjahr
                                     documentheader-doc_date documentheader-pstng_date.
        CLEAR ls_001.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_BAPI_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out         LIKE LINE OF gt_out,
         ls_claimdisc   LIKE LINE OF gt_claimdisc,
         lv_vbeln       TYPE zfidt001-vbeln,
         lv_belnr       TYPE zfidt001-belnr,
         lv_gjahr       TYPE zfidt001-gjahr.

  CASE fu_column.
    WHEN 'ICON'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF ls_out-icon = icon_led_red.
        PERFORM f_error_log USING ls_out-vbeln.
      ENDIF.

    WHEN 'VBELN'.
      CLEAR : lv_vbeln, lv_belnr, lv_gjahr.
      IF gt_out[] IS INITIAL.
        READ TABLE gt_claimdisc INTO ls_claimdisc INDEX fu_row.
        lv_vbeln = ls_claimdisc-vbeln.
      ELSE.
        READ TABLE gt_out INTO ls_out INDEX fu_row.
        lv_vbeln = ls_out-vbeln.
      ENDIF.
      IF lv_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD lv_vbeln.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'BELNR'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      lv_belnr = ls_out-belnr.
      lv_gjahr = ls_out-sptag(4).

    WHEN 'BELN1'.
      READ TABLE gt_claimdisc INTO ls_claimdisc INDEX fu_row.
      lv_belnr = ls_claimdisc-beln1.
      lv_gjahr = ls_claimdisc-sptag(4).

    WHEN 'BELN2'.
      READ TABLE gt_claimdisc INTO ls_claimdisc INDEX fu_row.
      lv_belnr = ls_claimdisc-beln2.
      lv_gjahr = ls_claimdisc-sptag(4).

    WHEN 'BELN3'.
      READ TABLE gt_claimdisc INTO ls_claimdisc INDEX fu_row.
      lv_belnr = ls_claimdisc-beln3.
      lv_gjahr = ls_claimdisc-sptag(4).
  ENDCASE.

  IF lv_belnr IS NOT INITIAL.
    SET PARAMETER ID 'BLN' FIELD lv_belnr.
    SET PARAMETER ID 'BUK' FIELD pa_bukrs.
    SET PARAMETER ID 'GJR' FIELD lv_gjahr.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log USING fu_vbeln.
  DATA : lt_bapiret2    TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2    LIKE LINE OF lt_bapiret2,
         ls_error       LIKE LINE OF gt_error,
         lv_lines       TYPE i.

  LOOP AT gt_error INTO ls_error WHERE vbeln = fu_vbeln.
    MOVE-CORRESPONDING ls_error TO ls_bapiret2.
    APPEND ls_bapiret2 TO lt_bapiret2.
    CLEAR ls_bapiret2.
  ENDLOOP.

  DESCRIBE TABLE lt_bapiret2 LINES lv_lines.
  IF lv_lines = 1.
    APPEND INITIAL LINE TO lt_bapiret2.
  ENDIF.

  CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
    TABLES
      i_bapiret2_tab = lt_bapiret2.
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_LINE_POST
*&---------------------------------------------------------------------*
FORM f_line_post  TABLES  accountgl         STRUCTURE bapiacgl09
                          accountpayable    STRUCTURE bapiacap09
                          accountreceivable STRUCTURE bapiacar09
                          currencyamount    STRUCTURE bapiaccr09
                          extension1        STRUCTURE bapiacextc
                          criteria          STRUCTURE bapiackec9
                  USING   fu_bschl fu_koart fu_buzei fu_sgtxt fu_discf
                          fu_gsber fu_kunnr fu_hkont fu_vbund.

  DATA : lv_discf           TYPE s626-zdisb1.

  CASE fu_koart.
    WHEN 'D'.
      accountreceivable-itemno_acc         = fu_buzei.
      accountreceivable-bus_area           = fu_gsber.
      accountreceivable-customer           = fu_kunnr.
      accountreceivable-alloc_nmbr         = gv_zuonr.
      accountreceivable-item_text          = fu_sgtxt.
      APPEND accountreceivable.

    WHEN 'S'.
      accountgl-itemno_acc                 = fu_buzei.
      accountgl-bus_area                   = fu_gsber.
      accountgl-gl_account                 = fu_hkont.
      accountgl-alloc_nmbr                 = gv_zuonr.
      accountgl-item_text                  = fu_sgtxt.
      accountgl-trade_id                   = fu_vbund.
      APPEND accountgl.
  ENDCASE.

  extension1(3)                = fu_buzei.
  extension1+3(2)              = fu_bschl.
  APPEND extension1.

  currencyamount-itemno_acc    = fu_buzei.
  currencyamount-curr_type     = '00'.
  currencyamount-currency      = 'IDR'.
  lv_discf  = ABS( fu_discf ).
  PERFORM f_value_conversion USING lv_discf fu_bschl
                             CHANGING currencyamount-amt_doccur.
  APPEND currencyamount.
ENDFORM.                    " F_LINE_POST

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_value_conversion  USING    fu_value fu_bschl
                         CHANGING fc_value.
  DATA : ls_tbsl    LIKE LINE OF gt_tbsl,
         lv_value(15).

  lv_value = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl
                     WITH KEY bschl = fu_bschl.
  IF ls_tbsl-shkzg = 'H'.
    fc_value = fc_value * -1.
  ENDIF.
ENDFORM.                    " F_VALUE_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  TRY .
      MODIFY zfidt001 FROM TABLE gt_save.
    CATCH cx_sy_open_sql_db.
      gv_subrc = 4.
  ENDTRY.

  IF gv_subrc = 0.
    PERFORM f_prepare_form.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISCOUNT_B
*&---------------------------------------------------------------------*
FORM f_discount_b .
  DATA : lt_x626        TYPE STANDARD TABLE OF ty_s626,
         lt_celltab     TYPE lvc_t_styl WITH HEADER LINE,
         ls_x626        LIKE LINE OF lt_x626,
         ls_s626        LIKE LINE OF gt_s626,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_adrc        LIKE LINE OF gt_adrc,
         ls_out         LIKE LINE OF gt_out,
         ls_x001        LIKE LINE OF gt_x001.

  DATA : lv_flag,
         lv_subrc       TYPE sy-subrc.

  lt_x626[] = gt_s626[].
  SORT lt_x626 BY vkbur vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_x626 COMPARING vkbur vbeln.
  IF lt_x626[] IS NOT INITIAL.
    LOOP AT lt_x626 INTO ls_x626.
      CLEAR : ls_s626, lv_flag.
      LOOP AT gt_s626 INTO ls_s626 WHERE vkbur = ls_x626-vkbur
                                     AND vbeln = ls_x626-vbeln.

        PERFORM f_check_already_process USING ls_s626-vkbur
                                              ls_s626-prodh1
                                              ls_s626-vbeln
                                        CHANGING lv_subrc.
        IF lv_subrc <> 0.
          CONTINUE.
        ENDIF.

        PERFORM f_move_data USING ls_s626 ls_s626-zdisb ls_s626-zdisb1
                            CHANGING ls_out.

        CLEAR ls_kna1.
        READ TABLE gt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_s626-pkunwe.
        IF sy-subrc = 0.
          CLEAR ls_adrc.
          READ TABLE gt_adrc INTO ls_adrc
                             WITH KEY addrnumber = ls_kna1-adrnr.
          IF sy-subrc = 0.
            ls_out-name1    = ls_adrc-name1.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ls_out-disc = 0 AND
        ls_out-discf = 0.
        CONTINUE.
      ENDIF.

      IF ls_out-zdncn = 'CN'.
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lt_celltab[].
*      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DISCOUNT_B

*&---------------------------------------------------------------------*
*&      Form  F_DISCOUNT_F
*&---------------------------------------------------------------------*
FORM f_discount_f .
  DATA : lt_x626        TYPE STANDARD TABLE OF ty_s626,
         lt_celltab     TYPE lvc_t_styl WITH HEADER LINE,
         ls_x626        LIKE LINE OF lt_x626,
         ls_s626        LIKE LINE OF gt_s626,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_adrc        LIKE LINE OF gt_adrc,
         ls_out         LIKE LINE OF gt_out,
         ls_x001        LIKE LINE OF gt_x001.

  DATA : lv_flag,
         lv_subrc       TYPE sy-subrc.

  lt_x626[] = gt_s626[].
  SORT lt_x626 BY vkbur vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_x626 COMPARING vkbur vbeln.
  IF lt_x626[] IS NOT INITIAL.
    LOOP AT lt_x626 INTO ls_x626.
      CLEAR : ls_s626, lv_flag.
      LOOP AT gt_s626 INTO ls_s626 WHERE vkbur = ls_x626-vkbur
                                     AND vbeln = ls_x626-vbeln.

        PERFORM f_check_already_process USING ls_s626-vkbur
                                              ls_s626-prodh1
                                              ls_s626-vbeln
                                        CHANGING lv_subrc.
        IF lv_subrc <> 0.
          CONTINUE.
        ENDIF.

        PERFORM f_move_data USING ls_s626 ls_s626-zdisf ls_s626-zdisf1
                            CHANGING ls_out.

        CLEAR ls_kna1.
        READ TABLE gt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_s626-pkunwe.
        IF sy-subrc = 0.
          CLEAR ls_adrc.
          READ TABLE gt_adrc INTO ls_adrc
                             WITH KEY addrnumber = ls_kna1-adrnr.
          IF sy-subrc = 0.
            ls_out-name1    = ls_adrc-name1.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ls_out-disc = 0 AND
        ls_out-discf = 0.
        CONTINUE.
      ENDIF.

      IF ls_out-zdncn = 'CN'.
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lt_celltab[].
*      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DISCOUNT_F

*&---------------------------------------------------------------------*
*&      Form  F_DISCOUNT_F3
*&---------------------------------------------------------------------*
FORM f_discount_f3 .
  DATA : lt_x626        TYPE STANDARD TABLE OF ty_s626,
         lt_y626        TYPE STANDARD TABLE OF ty_s626,
         lt_celltab     TYPE lvc_t_styl WITH HEADER LINE,
         ls_x626        LIKE LINE OF lt_x626,
         ls_y626        LIKE LINE OF lt_y626,
         ls_s626        LIKE LINE OF gt_s626,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_adrc        LIKE LINE OF gt_adrc,
         ls_out         LIKE LINE OF gt_out.

  DATA : lv_flag,
         lv_subrc       TYPE sy-subrc.

  lt_x626[] = gt_s626[].
  SORT lt_x626 BY vkbur vbtyp vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_x626 COMPARING vkbur vbtyp vbeln.
  lt_y626[] = lt_x626[].
  SORT lt_y626 BY vkbur vbtyp.
  DELETE ADJACENT DUPLICATES FROM lt_y626 COMPARING vkbur vbtyp.

  IF lt_y626[] IS NOT INITIAL.
    LOOP AT lt_y626 INTO ls_y626.
      CLEAR lv_flag.
      LOOP AT lt_x626 INTO ls_x626 WHERE vkbur = ls_y626-vkbur
                                     AND vbtyp = ls_y626-vbtyp.
        LOOP AT gt_s626 INTO ls_s626 WHERE vkbur = ls_x626-vkbur
                                       AND vbtyp = ls_x626-vbtyp
                                       AND vbeln = ls_x626-vbeln.
          PERFORM f_check_already_process USING ls_s626-vkbur
                                                ls_s626-prodh1
                                                ls_s626-vbeln
                                          CHANGING lv_subrc.
          IF lv_subrc <> 0.
            CONTINUE.
          ENDIF.

          PERFORM f_move_data USING ls_s626 ls_s626-zdisf3 ls_s626-zdisf3t
                              CHANGING ls_out.

          CLEAR ls_kna1.
          READ TABLE gt_kna1 INTO ls_kna1
                             WITH KEY kunnr = ls_s626-pkunwe.
          IF sy-subrc = 0.
            CLEAR ls_adrc.
            READ TABLE gt_adrc INTO ls_adrc
                               WITH KEY addrnumber = ls_kna1-adrnr.
            IF sy-subrc = 0.
              ls_out-name1    = ls_adrc-name1.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF ls_out-disc = 0 AND
          ls_out-discf = 0.
          CONTINUE.
        ENDIF.

        IF ls_out-zdncn = 'CN'.
          lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
          lt_celltab-fieldname = 'MARK'.
          APPEND lt_celltab.
          INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
        ELSE.
          IF lv_flag IS INITIAL.
            lv_flag = 'X'.
          ELSE.
            lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
            lt_celltab-fieldname = 'MARK'.
            APPEND lt_celltab.
            INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
          ENDIF.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR : ls_out, lt_celltab[].
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DISCOUNT_F3

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         ls_info             TYPE ssfcrescl,
         ls_options          TYPE ssfcresop,
         ls_control_option   TYPE ssfctrlop,
         ls_output_option    TYPE ssfcompop.

  DATA : ls_head             LIKE LINE OF gt_head,
         ls_detl             LIKE LINE OF gt_detl,
         lt_detl             TYPE STANDARD TABLE OF zdgfisd_f001.

  lv_formname = 'ZDGFI_001B'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  ls_control_option-getotf       = 'X'.

  LOOP AT gt_head INTO ls_head.
    AT FIRST.
      ls_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      ls_control_option-no_close = space.
    ENDAT.

    IF radio4 IS NOT INITIAL.
      ls_head-reprint = 'X'.
    ENDIF.

    CLEAR : lt_detl[].
    LOOP AT gt_detl INTO ls_detl WHERE belnr = ls_head-belnr
                                   AND gjahr = ls_head-gjahr.
      APPEND ls_detl TO lt_detl.
      CLEAR ls_detl.
    ENDLOOP.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ls_control_option
        output_options     = ls_output_option
        user_settings      = space
        sf_header          = ls_head
      IMPORTING
        job_output_info    = ls_info
        job_output_options = ls_options
      TABLES
        gt_detail          = lt_detl
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    ls_control_option-no_open = 'X'.
  ENDLOOP.

  PERFORM f_crete_pdf USING ls_info.

ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FORM
*&---------------------------------------------------------------------*
FORM f_prepare_form .
  DATA : ls_save    LIKE LINE OF gt_save,
         ls_kna1    LIKE LINE OF gt_kna1,
         ls_adrc    LIKE LINE OF gt_adrc,
         ls_head    LIKE LINE OF gt_head,
         ls_detl    LIKE LINE OF gt_detl.

  DATA : lv_flag,
         lv_mwsbk   TYPE vbrk-mwsbk.

  LOOP AT gt_save INTO ls_save.
    IF lv_flag IS INITIAL.
      lv_flag = 'X'.
      ls_head-bukrs   = pa_bukrs.
      CASE ls_save-vbtyp.
        WHEN 'M' OR 'S'.
          ls_head-judul = 'DEBIT NOTE'.
        WHEN 'O' OR 'N'.
          ls_head-judul = 'KREDIT NOTE'.
      ENDCASE.
      ls_head-belnr = ls_save-belnr.
      ls_head-gjahr = ls_save-gjahr.
      ls_head-budat = ls_save-budat.
      ls_head-waers = ls_save-stwae.
      ls_head-xblnr = gv_zuonr.

      CLEAR ls_kna1.
      READ TABLE gt_kna1 INTO ls_kna1
                         WITH KEY kunnr = '3800000002'.
      IF sy-subrc = 0.
        CLEAR ls_adrc.
        READ TABLE gt_adrc INTO ls_adrc
                           WITH KEY addrnumber = ls_kna1-adrnr.
        IF sy-subrc = 0.
          ls_head-name1        = ls_adrc-name1.
          ls_head-street       = ls_adrc-street.
          ls_head-city1        = ls_adrc-city1.
*          ls_head-post_code1   = ls_adrc-post_code1.
        ENDIF.
      ENDIF.
    ENDIF.

    ls_detl-bukrs = pa_bukrs.
    ls_detl-belnr = ls_save-belnr.
    ls_detl-gjahr = ls_save-gjahr.
    ls_detl-sgtxt = gv_sgtxt.
    ls_detl-wrbtr = ABS( ls_save-zdiscf ).

*    IF ls_save-zdistp = 'F3'.
    PERFORM f_calc_vat USING ls_save-zdiscf
                       CHANGING lv_mwsbk.
*    ELSE.
*      IF ls_save-vkbur = '0246'.
*        PERFORM f_calc_vat USING ls_save-zdiscf
*                           CHANGING lv_mwsbk.
*      ELSE.
*        lv_mwsbk = ls_save-zdisc - ls_save-zdiscf.
*      ENDIF.
*    ENDIF.
    ADD lv_mwsbk TO ls_head-mwsbk.

    ls_detl-waers = ls_save-stwae.
    ADD ls_detl-wrbtr TO ls_head-vtotal.
    COLLECT ls_detl INTO gt_detl.
    CLEAR ls_detl.
  ENDLOOP.

  ls_head-mwsbk  = ABS( ls_head-mwsbk ).
  ls_head-vtotal = ls_head-vtotal + ls_head-mwsbk.

  PERFORM f_say_amount USING ls_head-vtotal ls_head-waers
                       CHANGING ls_head-stotal.

  APPEND ls_head TO gt_head.
  CLEAR ls_head.
ENDFORM.                    " F_PREPARE_FORM

*&---------------------------------------------------------------------*
*&      Form  F_S626_DOCN
*&---------------------------------------------------------------------*
FORM f_s626_docn .
  DATA : ls_s626      LIKE LINE OF gt_s626.

  LOOP AT gt_s626 INTO ls_s626.
    CASE ls_s626-vbtyp.
      WHEN 'M'.
        ls_s626-zdncn    = 'DN'.
      WHEN 'S'.
        ls_s626-zdncn    = 'Cancel CN'.
      WHEN 'O'.
        ls_s626-zdncn    = 'CN'.
      WHEN 'N'.
        ls_s626-zdncn    = 'Cancel DN'.
    ENDCASE.
    MODIFY gt_s626 FROM ls_s626 TRANSPORTING zdncn.
  ENDLOOP.
ENDFORM.                    " F_S626_DOCN

*&---------------------------------------------------------------------*
*&      Form  F_SAY_AMOUNT
*&---------------------------------------------------------------------*
FORM f_say_amount  USING    fu_value fu_stwae
                   CHANGING fc_value.
  DATA : lv_langu     TYPE sy-langu,
         lv_in_words  TYPE spell,
         lv_ktext     TYPE tcurt-ktext.

  IF fu_stwae = 'IDR'.
    lv_langu  = 'i'.
  ELSE.
    lv_langu  = sy-langu.
  ENDIF.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = fu_value
      currency  = fu_stwae
      language  = lv_langu
    IMPORTING
      in_words  = lv_in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  IF sy-subrc = 0.
    CLEAR lv_ktext.
    SELECT SINGLE ktext
      FROM tcurt
      INTO lv_ktext
      WHERE spras = sy-langu
        AND waers = fu_stwae.

    TRANSLATE lv_ktext TO UPPER CASE.
    IF lv_langu = sy-langu.
      IF lv_in_words-decword EQ 'ZERO'.
        CONCATENATE 'Say: ' lv_in_words-word lv_ktext INTO fc_value SEPARATED BY space.
      ELSE.
        CONCATENATE 'Say: '
                    lv_in_words-word
                    'AND'
                    lv_in_words-decword
                    lv_ktext
        INTO fc_value
        SEPARATED BY space.
      ENDIF.
    ELSE.
      CONCATENATE lv_in_words-word
                  lv_ktext
      INTO fc_value
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SAY_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table  USING    fs_out    TYPE ty_out
                              fu_error fu_belnr fu_gjahr.

  DATA : ls_out         LIKE LINE OF gt_out,
         lt_celltab     TYPE lvc_t_styl WITH HEADER LINE.

  ls_out = fs_out.

  IF fu_error IS NOT INITIAL.
    ls_out-icon  = icon_led_red.
  ELSE.
    ls_out-belnr  = fu_belnr.
    ls_out-gjahr  = fu_gjahr.
    IF ls_out-mark IS NOT INITIAL.
      CLEAR ls_out-mark.
      lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
      lt_celltab-fieldname = 'MARK'.
      APPEND lt_celltab.
      INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
    ENDIF.
  ENDIF.
  MODIFY gt_out FROM ls_out TRANSPORTING mark icon style belnr gjahr.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE
*&---------------------------------------------------------------------*
FORM f_prepare_save  USING    fs_001    STRUCTURE zfidt001
                              fu_belnr fu_gjahr fu_bldat fu_budat.
  DATA : ls_001   LIKE LINE OF gt_001.

  ls_001 = fs_001.

  ls_001-belnr  = fu_belnr.
  ls_001-gjahr  = fu_gjahr.
  ls_001-zdistp = gv_zdistp.
  ls_001-bldat  = fu_bldat.
  ls_001-budat  = fu_budat.
  ls_001-xblnr  = gv_zuonr.
  ls_001-vatfl  = pa_vat.
  APPEND ls_001 TO gt_save.
ENDFORM.                    " F_PREPARE_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_object fu_post
                        CHANGING fc_number fc_subrc.
  DATA : lv_nrrange   TYPE inri-nrrangenr,
         lv_gjahr     TYPE inri-toyear,
         ls_nriv      TYPE nriv.

  lv_nrrange    = so_sptag-high+4(2).
  lv_gjahr      = so_sptag-high(4).

  SELECT SINGLE *
    FROM nriv
    INTO ls_nriv
    WHERE object    = fu_object
      AND subobject = pa_bukrs
      AND nrrangenr = lv_nrrange
      AND toyear    = lv_gjahr.
  IF sy-subrc = 0.
    IF fu_post IS NOT INITIAL.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = lv_nrrange
          object                  = fu_object
          subobject               = pa_bukrs
          toyear                  = lv_gjahr
        IMPORTING
          number                  = fc_number
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
    ELSE.
      IF ls_nriv-nrlevel IS INITIAL.
        fc_number = ls_nriv-fromnumber.
      ELSE.
        fc_number = ls_nriv-nrlevel+12(8).
      ENDIF.
    ENDIF.
  ELSE.
    fc_subrc = 4.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_S626
*&---------------------------------------------------------------------*
FORM f_get_s626 .
  DATA : lt_s626    TYPE STANDARD TABLE OF ty_s626,
         ls_s626    LIKE LINE OF lt_s626.

  SELECT *
    FROM tvfk
    INTO CORRESPONDING FIELDS OF TABLE gt_tvfk.

  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

  SELECT ssour vrsio spmon sptag spwoc spbup vkbur fkart vbeln pkunwe
    kdgrp kvgr3 prodh1 matkl matnr stwae basme umkzwi1 gukzwi1 umkzwi4
    gukzwi4 ummenge gumenge zdisa zdisb zdisc zdise zdisf zdisa1 zdisb1
    zdisc1 zdise1 zdisf1 zdisf3 zdisf3t zpmp vbtyp
    FROM s626
    INTO CORRESPONDING FIELDS OF TABLE gt_s626
    WHERE ssour  = space
      AND vrsio  = '000'
      AND spmon  = '000000'
      AND sptag  IN so_sptag
      AND spwoc  = '000000'
      AND spbup  = '000000'
      AND vkbur  IN so_vkbur
      AND prodh1 = pa_prodh.

  PERFORM f_s626_docn.

  lt_s626[] = gt_s626[].
  SORT lt_s626 BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM lt_s626 COMPARING pkunwe.

  ls_s626-pkunwe  = '3800000002'.
  APPEND ls_s626 TO lt_s626.

  IF lt_s626[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FOR ALL ENTRIES IN lt_s626
      WHERE kunnr = lt_s626-pkunwe.

    IF gt_kna1[] IS NOT INITIAL.
      SELECT *
        FROM adrc
        INTO CORRESPONDING FIELDS OF TABLE gt_adrc
        FOR ALL ENTRIES IN gt_kna1
        WHERE addrnumber = gt_kna1-adrnr.
    ENDIF.
  ENDIF.

  lt_s626[] = gt_s626[].
  SORT lt_s626 BY vkbur prodh1 vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_s626 COMPARING vkbur prodh1 vbeln.
  IF lt_s626[] IS NOT INITIAL.
    SELECT *
      FROM zfidt001
      INTO CORRESPONDING FIELDS OF TABLE gt_x001
      FOR ALL ENTRIES IN lt_s626
      WHERE bukrs   = pa_bukrs
        AND vkbur   = lt_s626-vkbur
        AND prodh1  = lt_s626-prodh1
        AND vbeln   = lt_s626-vbeln.
  ENDIF.
ENDFORM.                    " F_GET_S626

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFIDT001
*&---------------------------------------------------------------------*
FORM f_get_zfidt001 .
  DATA : lt_001   TYPE STANDARD TABLE OF zfidt001,
         ls_001   LIKE LINE OF lt_001.

  SELECT *
    FROM zfidt001
    INTO CORRESPONDING FIELDS OF TABLE gt_x001
    WHERE bukrs   = pa_bukrs
      AND vkbur   IN so_vkbur
      AND prodh1  = pa_prodh
      AND xblnr   IN so_xblnr
      AND budat   IN so_sptag.

  lt_001[] = gt_x001[].
  SORT lt_001 BY pkunwe.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING pkunwe.

  ls_001-pkunwe  = '3800000002'.
  APPEND ls_001 TO lt_001.

  IF lt_001[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FOR ALL ENTRIES IN lt_001
      WHERE kunnr = lt_001-pkunwe.

    IF gt_kna1[] IS NOT INITIAL.
      SELECT *
        FROM adrc
        INTO CORRESPONDING FIELDS OF TABLE gt_adrc
        FOR ALL ENTRIES IN gt_kna1
        WHERE addrnumber = gt_kna1-adrnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ZFIDT001

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DISPLAY
*&---------------------------------------------------------------------*
FORM f_prepare_display .
  DATA : lt_001         TYPE STANDARD TABLE OF zfidt001,
         ls_001         LIKE LINE OF lt_001,
         ls_x001        LIKE LINE OF gt_x001,
         lt_celltab     TYPE lvc_t_styl WITH HEADER LINE,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_adrc        LIKE LINE OF gt_adrc,
         ls_out         LIKE LINE OF gt_out.

  DATA : lv_flag.

  lt_001[] = gt_x001[].
  SORT lt_001 BY xblnr.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING xblnr.
  LOOP AT lt_001 INTO ls_001.
    CLEAR : ls_x001, lv_flag.
    LOOP AT gt_x001 INTO ls_x001 WHERE xblnr = ls_001-xblnr.
      ls_out-vkbur    = ls_x001-vkbur.
      ls_out-prodh1   = ls_x001-prodh1.
      ls_out-vbeln    = ls_x001-vbeln.
      ls_out-xblnr    = ls_x001-xblnr.
      ls_out-vbtyp    = ls_x001-vbtyp.
      CASE ls_x001-vbtyp.
        WHEN 'M'.
          ls_out-zdncn    = 'DN'.
        WHEN 'S'.
          ls_out-zdncn    = 'Cancel CN'.
        WHEN 'O'.
          ls_out-zdncn    = 'CN'.
        WHEN 'N'.
          ls_out-zdncn    = 'Cancel DN'.
      ENDCASE.
      ls_out-zdistp   = ls_x001-zdistp.
      ls_out-sptag    = ls_x001-fkdat.
      ls_out-pkunwe	  = ls_x001-pkunwe.

      CLEAR ls_kna1.
      READ TABLE gt_kna1 INTO ls_kna1
                         WITH KEY kunnr = ls_x001-pkunwe.
      IF sy-subrc = 0.
        CLEAR ls_adrc.
        READ TABLE gt_adrc INTO ls_adrc
                           WITH KEY addrnumber = ls_kna1-adrnr.
        IF sy-subrc = 0.
          ls_out-name1    = ls_adrc-name1.
        ENDIF.
      ENDIF.

      ls_out-stwae    = ls_x001-stwae.
      ls_out-umkzwi1  = ls_x001-umkzwi1.
      ls_out-gukzwi1  = ls_x001-gukzwi1.
      ls_out-disc     = ls_x001-zdisc.
      ls_out-discf    = ls_x001-zdiscf.
      ls_out-belnr    = ls_x001-belnr.
      ls_out-gjahr    = ls_x001-gjahr.

      IF ls_out-disc = 0 AND
        ls_out-discf = 0.
        CONTINUE.
      ENDIF.

      IF lv_flag IS INITIAL.
        lv_flag = 'X'.
      ELSE.
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lt_celltab[].
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_REPRINT
*&---------------------------------------------------------------------*
FORM f_prepare_reprint .
  DATA : lt_xout            TYPE STANDARD TABLE OF ty_out,
         ls_xout            LIKE LINE OF lt_xout,
         ls_out             LIKE LINE OF gt_out,
         ls_x001            LIKE LINE OF gt_001,
         ls_head            LIKE LINE OF gt_head,
         ls_detl            LIKE LINE OF gt_detl,
         ls_kna1            LIKE LINE OF gt_kna1,
         ls_adrc            LIKE LINE OF gt_adrc.

  DATA : lt_bseg            TYPE STANDARD TABLE OF bseg,
         ls_bseg            LIKE LINE OF lt_bseg.

  DATA : lv_sgtxt           TYPE bseg-sgtxt,
         lv_mwsbk           TYPE vbrk-mwsbk.

  CLEAR : gt_detl[], gt_head[].

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark = space.
  LOOP AT lt_xout INTO ls_xout.
    ls_head-bukrs   = pa_bukrs.
    CASE ls_xout-vbtyp.
      WHEN 'M' OR 'S'.
        ls_head-judul = 'DEBIT NOTE'.
      WHEN 'O' OR 'N'.
        ls_head-judul = 'KREDIT NOTE'.
    ENDCASE.
    ls_head-belnr = ls_xout-belnr.
    ls_head-gjahr = ls_xout-gjahr.
    ls_head-budat = ls_xout-sptag.
    ls_head-waers = ls_xout-stwae.
    CLEAR ls_x001.
    READ TABLE gt_x001 INTO ls_x001
                      WITH KEY vkbur = ls_xout-vkbur
                               vbeln = ls_xout-vbeln.
    IF sy-subrc = 0.
      ls_head-xblnr = ls_x001-xblnr.
      CONCATENATE ls_xout-sptag+4(2) '.'
                  ls_xout-sptag(4)
      INTO lv_sgtxt.
      CASE ls_x001-zdistp.
        WHEN 'B'.
          CONCATENATE 'Kompensasi Sponsorship per' lv_sgtxt
          INTO lv_sgtxt
          SEPARATED BY space.
        WHEN 'F'.
          CONCATENATE 'Kompensasi Customer Specific TRD DISC per' lv_sgtxt
            INTO lv_sgtxt
            SEPARATED BY space.
        WHEN 'F3'.
          CONCATENATE 'Kompensasi Customer Specific TRD DISC per' lv_sgtxt
            INTO lv_sgtxt
            SEPARATED BY space.
      ENDCASE.
    ENDIF.

    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1
                       WITH KEY kunnr = '3800000002'.
    IF sy-subrc = 0.
      CLEAR ls_adrc.
      READ TABLE gt_adrc INTO ls_adrc
                         WITH KEY addrnumber = ls_kna1-adrnr.
      IF sy-subrc = 0.
        ls_head-name1        = ls_adrc-name1.
        ls_head-street       = ls_adrc-street.
        ls_head-city1        = ls_adrc-city1.
*        ls_head-post_code1   = ls_adrc-post_code1.
      ENDIF.
    ENDIF.

    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg
      WHERE bukrs = pa_bukrs
        AND belnr = ls_xout-belnr
        AND gjahr = ls_xout-gjahr
        AND hkont = '0315300100'.

    LOOP AT gt_out INTO ls_out WHERE belnr = ls_xout-belnr.
      ls_detl-bukrs = pa_bukrs.
      ls_detl-belnr = ls_out-belnr.
      ls_detl-gjahr = ls_out-gjahr.

      ls_detl-sgtxt = lv_sgtxt.
      ls_detl-wrbtr = ABS( ls_out-discf ).

*      CLEAR ls_x001.
*      READ TABLE gt_x001 INTO ls_x001
*                        WITH KEY belnr = ls_out-belnr
*                                 gjahr = ls_out-gjahr.
*      IF sy-subrc = 0.
*        IF ls_x001-vatfl IS NOT INITIAL.
*          IF ls_x001-zdistp = 'F3'.
*            lv_mwsbk = ls_out-discf * ( 11 / 100 ).
*          ELSE.
*            IF ls_out-vkbur = '0246'.
*              lv_mwsbk = ls_out-discf * ( 11 / 100 ).
*            ELSE.
*              lv_mwsbk = ls_out-disc - ls_out-discf.
*            ENDIF.
*          ENDIF.
*          ADD lv_mwsbk TO ls_head-mwsbk.
*        ENDIF.
*      ENDIF.

      ls_detl-waers = ls_out-stwae.
      ADD ls_detl-wrbtr TO ls_head-vtotal.
      COLLECT ls_detl INTO gt_detl.
      CLEAR ls_detl.
    ENDLOOP.

    LOOP AT lt_bseg INTO ls_bseg.
      ADD ls_bseg-dmbtr TO ls_head-mwsbk.
    ENDLOOP.

    ls_head-mwsbk  = ABS( ls_head-mwsbk ).
    ls_head-vtotal = ls_head-vtotal + ls_head-mwsbk.

    PERFORM f_say_amount USING ls_head-vtotal ls_head-waers
                         CHANGING ls_head-stotal.

    APPEND ls_head TO gt_head.
    CLEAR ls_head.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_REPRINT

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_REPORT
*&---------------------------------------------------------------------*
FORM f_prepare_report .
  DATA : ls_claimdisc   LIKE LINE OF gt_claimdisc,
         ls_x001        LIKE LINE OF gt_x001,
         lt_001         TYPE STANDARD TABLE OF zfidt001,
         ls_001         LIKE LINE OF lt_001,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_adrc        LIKE LINE OF gt_adrc.

  lt_001[] = gt_x001[].
  SORT lt_001 BY vkbur vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING vkbur vbeln.
  LOOP AT lt_001 INTO ls_001.
    ls_claimdisc-vkbur   = ls_001-vkbur.
    ls_claimdisc-prodh1  = ls_001-prodh1.
    ls_claimdisc-vbtyp   = ls_001-vbtyp.
    CASE ls_001-vbtyp.
      WHEN 'M'.
        ls_claimdisc-zdncn   = 'DN'.
      WHEN 'S'.
        ls_claimdisc-zdncn   = 'Cancel CN'.
      WHEN 'O'.
        ls_claimdisc-zdncn   = 'CN'.
      WHEN 'N'.
        ls_claimdisc-zdncn   = 'Cancel DN'.
    ENDCASE.
    ls_claimdisc-vbeln   = ls_001-vbeln.
    ls_claimdisc-xblnr   = ls_001-xblnr.
    ls_claimdisc-sptag   = ls_001-fkdat.
    ls_claimdisc-pkunwe  = ls_001-pkunwe.
    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_001-pkunwe.
    IF sy-subrc = 0.
      CLEAR ls_adrc.
      READ TABLE gt_adrc INTO ls_adrc
                         WITH KEY addrnumber = ls_kna1-adrnr.
      IF sy-subrc = 0.
        ls_claimdisc-name1    = ls_adrc-name1.
      ENDIF.
    ENDIF.

    ls_claimdisc-stwae   = ls_001-stwae.
    ls_claimdisc-umkzwi1 = ls_001-umkzwi1.
    ls_claimdisc-gukzwi1 = ls_001-gukzwi1.
    LOOP AT gt_x001 INTO ls_x001 WHERE vkbur = ls_001-vkbur
                                   AND vbeln = ls_001-vbeln.
      CASE ls_x001-zdistp.
        WHEN 'B'.
          ls_claimdisc-xbln1   = ls_x001-xblnr.
          ls_claimdisc-disc1   = ls_x001-zdisc.
          ls_claimdisc-discf1  = ls_x001-zdiscf.
          IF ls_x001-vatfl IS NOT INITIAL.
            ls_claimdisc-mwsbk1  = ls_x001-zdisc - ls_x001-zdiscf.
          ENDIF.
          ls_claimdisc-beln1   = ls_x001-belnr.
        WHEN 'F'.
          ls_claimdisc-xbln2   = ls_x001-xblnr.
          ls_claimdisc-disc2   = ls_x001-zdisc.
          ls_claimdisc-discf2  = ls_x001-zdiscf.
          IF ls_x001-vatfl IS NOT INITIAL.
            ls_claimdisc-mwsbk2  = ls_x001-zdisc - ls_x001-zdiscf.
          ENDIF.
          ls_claimdisc-beln2   = ls_x001-belnr.
        WHEN 'F3'.
          ls_claimdisc-xbln3   = ls_x001-xblnr.
          ls_claimdisc-disc3   = ls_x001-zdisc.
          ls_claimdisc-discf3  = ls_x001-zdiscf.
          IF ls_x001-vatfl IS NOT INITIAL.
            ls_claimdisc-mwsbk3  = ls_x001-zdisc - ls_x001-zdiscf.
          ENDIF.
          ls_claimdisc-beln3   = ls_x001-belnr.
      ENDCASE.
    ENDLOOP.
    APPEND ls_claimdisc TO gt_claimdisc.
    CLEAR ls_claimdisc.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ALREADY_PROCESS
*&---------------------------------------------------------------------*
FORM f_check_already_process  USING    fu_vkbur fu_prodh1 fu_vbeln
                              CHANGING fc_subrc.
  DATA : ls_x001        LIKE LINE OF gt_x001.

  CLEAR : ls_x001, fc_subrc.
  READ TABLE gt_x001 INTO ls_x001
                     WITH KEY vkbur  = fu_vkbur
                              prodh1 = fu_prodh1
                              vbeln  = fu_vbeln.
  IF sy-subrc = 0.
    LOOP AT gt_x001 INTO ls_x001 WHERE vkbur  = fu_vkbur
                                   AND prodh1 = fu_prodh1
                                   AND vbeln  = fu_vbeln.
      CASE 'X'.
        WHEN radio1.
          IF ls_x001-zdistp = 'B'.
            fc_subrc = 4.
            EXIT.
          ENDIF.
        WHEN radio2.
          IF ls_x001-zdistp = 'F'.
            fc_subrc = 4.
            EXIT.
          ENDIF.
        WHEN radio3.
          IF ls_x001-zdistp = 'F3'.
            fc_subrc = 4.
            EXIT.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ELSE.
    CLEAR fc_subrc.
  ENDIF.
ENDFORM.                    " F_CHECK_ALREADY_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_DATA
*&---------------------------------------------------------------------*
FORM f_move_data  USING    fs_s626    TYPE ty_s626
                           fu_disc fu_discf
                  CHANGING fs_out     TYPE ty_out.

  fs_out-vkbur    = fs_s626-vkbur.
  fs_out-prodh1   = fs_s626-prodh1.
  fs_out-vbeln    = fs_s626-vbeln.
  fs_out-vbtyp    = fs_s626-vbtyp.
  fs_out-zdncn    = fs_s626-zdncn.
  fs_out-sptag    = fs_s626-sptag.
  fs_out-pkunwe	  = fs_s626-pkunwe.
  fs_out-stwae    = fs_s626-stwae.
  ADD fs_s626-umkzwi1 TO fs_out-umkzwi1.
  ADD fs_s626-gukzwi1 TO fs_out-gukzwi1.
  ADD fu_disc TO fs_out-disc.
  ADD fu_discf TO fs_out-discf.

*  fs_out-umkzwi1  = fs_s626-umkzwi1.
*  fs_out-gukzwi1  = fs_s626-gukzwi1.
*  fs_out-disc     = fu_disc.
*  fs_out-discf    = fu_discf.
ENDFORM.                    " F_MOVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CRETE_PDF
*&---------------------------------------------------------------------*
FORM f_crete_pdf  USING    fs_info    TYPE ssfcrescl.
  DATA : lt_otf              TYPE TABLE OF itcoo,
         lv_objlen           TYPE sood-objlen,
         lv_xstring          TYPE xstring,
         lt_lines            TYPE TABLE OF tline,
         lt_objbin           TYPE TABLE OF solix.

  DATA : directory           TYPE string,
         lv_filename         TYPE string,
         document            TYPE string.

  lt_otf[] = fs_info-otfdata[].

  IF lt_otf[] IS NOT INITIAL.
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
        max_linewidth         = 132
      IMPORTING
        bin_filesize          = lv_objlen
        bin_file              = lv_xstring
      TABLES
        otf                   = lt_otf
        lines                 = lt_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_xstring
      TABLES
        binary_tab = lt_objbin[].

    CASE 'X'.
      WHEN radio1.
        CONCATENATE 'Claim Discount B' '.pdf' INTO lv_filename.
      WHEN radio2.
        CONCATENATE 'Claim Discount F' '.pdf' INTO lv_filename.
      WHEN radio3.
        CONCATENATE 'Claim Discount F3' '.pdf' INTO lv_filename.
      WHEN radio4.
        CONCATENATE 'Reprint Claim Discount' '.pdf' INTO lv_filename.
    ENDCASE.

    CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
      CHANGING
        sapworkdir            = directory
      EXCEPTIONS
        get_sapworkdir_failed = 1
        cntl_error            = 2
        error_no_gui          = 3
        not_supported_by_gui  = 4
        OTHERS                = 5.

    IF sy-subrc = 0.
      CONCATENATE directory '\' lv_filename INTO document.

      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          filename                = document
          filetype                = 'BIN'
        CHANGING
          data_tab                = lt_objbin
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
          not_supported_by_gui    = 22
          error_no_gui            = 23
          OTHERS                  = 24.

      IF sy-subrc = 0.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = document
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CRETE_PDF

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_BLINE_DATE
*&---------------------------------------------------------------------*
FORM f_change_bline_date  TABLES   accountgl STRUCTURE bapiacgl09
                          USING    fu_blart fu_belnr fu_bukrs fu_gjahr fu_zfbdt.
  DATA : ls_accountgl     LIKE LINE OF accountgl.

  DATA : lv_mode,
         lv_update,
         lv_zfbdt(10),
         lv_buzei         TYPE bseg-buzei,
         lr_hkont         TYPE RANGE OF hkont,
         ls_hkont         LIKE LINE OF lr_hkont.

  lv_mode          = 'N'.
  lv_update        = 'S'.
  ls_hkont-low     = '0315300100'.
  ls_hkont-sign    = 'I'.
  ls_hkont-option  = 'EQ'.
  APPEND ls_hkont TO lr_hkont.

  CONCATENATE fu_zfbdt+6(2) fu_zfbdt+4(2) fu_zfbdt(4) INTO lv_zfbdt.
  LOOP AT accountgl INTO ls_accountgl.
    CLEAR : t_bdcdata[], t_bdcmsg[].
    IF ls_accountgl-gl_account IN lr_hkont.
      lv_buzei  = ls_accountgl-itemno_acc.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0102',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'RF05L-BELNR'   fu_belnr,
           ' '  'RF05L-BUKRS'   fu_bukrs,
           ' '  'RF05L-GJAHR'   fu_gjahr,
           ' '  'RF05L-BUZEI'   lv_buzei.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           ' '  'RF05L-XKSAK'   'X'.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'BSEG-ZFBDT'    lv_zfbdt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '=AE',
           ' '  'BSEG-ZFBDT'    lv_zfbdt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.

      CALL TRANSACTION 'FB09' USING t_bdcdata
                              MODE lv_mode
                              UPDATE lv_update
                              MESSAGES INTO t_bdcmsg.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_BLINE_DATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_PPN
*&---------------------------------------------------------------------*
FORM f_modify_ppn .
  DATA : lt_bseg    TYPE STANDARD TABLE OF bseg,
         ls_bseg    LIKE LINE OF lt_bseg,
         ls_head    LIKE LINE OF gt_head.

  DATA : lv_tabix   TYPE sy-tabix.

  IF gt_head[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg
      FOR ALL ENTRIES IN gt_head
      WHERE bukrs = gt_head-bukrs
        AND belnr = gt_head-belnr
        AND gjahr = gt_head-gjahr
        AND hkont = '0315300100'.
  ENDIF.

  LOOP AT gt_head INTO ls_head.
    lv_tabix  = sy-tabix.
    ls_head-vtotal = ls_head-vtotal - ls_head-mwsbk.
    CLEAR ls_head-mwsbk.
    LOOP AT lt_bseg INTO ls_bseg WHERE belnr = ls_head-belnr
                                   AND gjahr = ls_head-gjahr.
      ADD ls_bseg-dmbtr TO ls_head-mwsbk.
    ENDLOOP.

    ls_head-vtotal = ls_head-vtotal + ls_head-mwsbk.
    PERFORM f_say_amount USING ls_head-vtotal ls_head-waers
                         CHANGING ls_head-stotal.

    MODIFY gt_head FROM ls_head
                   INDEX lv_tabix
                   TRANSPORTING mwsbk vtotal stotal.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_PPN

*&---------------------------------------------------------------------*
*&      Form  F_CALC_VAT
*&---------------------------------------------------------------------*
FORM f_calc_vat  USING    fu_value
                 CHANGING fc_value.
  fc_value   = fu_value * ( 11 / 100 ).
ENDFORM.                    " F_CALC_VAT
