*&---------------------------------------------------------------------*
*&  Include           ZWM_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT SINGLE lgnum
    FROM lrf_wkqu
    INTO gv_lgnum
    WHERE bname = sy-uname
      AND statu = 'X'.

  SELECT SINGLE werks
    FROM t320
    INTO gv_werks
    WHERE lgnum = gv_lgnum.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  CASE 'X'.
    WHEN radio1 OR radio4.
      PERFORM f_modify_screen USING : 'S02' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'S01' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'S02' '0' '' '' '',
                                      'SZD' '0' '' '' ''.

  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  IF pa_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION-SCREEN

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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_get_data_tlog.
    WHEN radio2.
      PERFORM f_get_data_principal.
    WHEN radio3.
      PERFORM f_get_data_complete.
    WHEN radio4.
      PERFORM f_get_data_004.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_tlog_process.
      PERFORM f_new_material.
      PERFORM f_non_batch.
    WHEN radio2.
      PERFORM f_pricipal_process.
    WHEN radio3.
      PERFORM f_move_data_to_process.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL OR gt_004[] IS NOT INITIAL.
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

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode  TYPE TABLE OF sy-ucomm,
         dynlog TYPE smp_dyntxt.

  CASE 'X'.
    WHEN radio3.
      APPEND '&LOG' TO fcode.
    WHEN OTHERS.
      IF gt_bapiret2[] IS NOT INITIAL.
        dynlog-icon_id      = icon_error_protocol.
        dynlog-icon_text    = 'Error Log'.
      ENDIF.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  CASE 'X'.
    WHEN radio1.
      SET TITLEBAR 'TITLE1'.
    WHEN radio2.
      SET TITLEBAR 'TITLE2'.
    WHEN radio3.
      SET TITLEBAR 'TITLE3'.
    WHEN radio4.
      SET TITLEBAR 'TITLE4'.
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
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      PERFORM f_show_error_message.

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
          WHEN radio3.
            PERFORM f_uncomplete.
          WHEN OTHERS.
            CALL SELECTION-SCREEN 200 STARTING AT 10 10.
            IF sy-subrc = 0.
              PERFORM f_gr_process.
            ENDIF.
        ENDCASE.
      ENDIF.

    WHEN '&PRNT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_print_bast.
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

    IF radio4 = 'X'.
      CALL METHOD g_tabgrid->set_table_for_first_display
        EXPORTING
          is_layout            = gs_layout_alv
          i_save               = 'A'
          is_variant           = gs_variant
          i_default            = 'X'
          it_toolbar_excluding = gs_exclude
        CHANGING
          it_sort              = gt_main_sort[]
          it_outtab            = gt_004[]
          it_fieldcatalog      = gt_main_fieldcat[].
    ELSE.
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
    ENDIF.
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
  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'TKNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  IF radio4 = 'X'.
  ELSE.
    PERFORM f_dyn_int_table USING :
      'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
      'X' 'X' '' '' ''.
  ENDIF.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_dyn_int_table USING :
        'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'TKNUM' '' '' '' '' '' '' 'TKNUM' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' ''.
    WHEN radio2.
      PERFORM f_dyn_int_table USING :
        'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'TKNUM' '' '' '' '' '' '' 'TKNUM' 'ZWMDT004' 'Purchase Doc.' '' ''
        '' '' '' '' 'X' 'X' '' '' ''.
    WHEN radio3.
      PERFORM f_dyn_int_table USING :
        'TKNUM' '' '' '' '' '' '' 'TKNUM' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' ''.
  ENDCASE.
  CASE 'X'.
    WHEN radio4.
      PERFORM f_dyn_int_table USING :
        'TKNUM' '' '' '' '' '' '' 'TKNUM' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'VBELN' '' '' '' '' '' '' 'VBELN' 'ZWMDT004' 'Delivery  Number' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'POSNR' '' '' '' '' '' '' 'POSNR' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'LZNUM' '' '' '' '' '' '' 'LZNUM' 'ZWMDT004' 'Pallet Number' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'MATNR' '' '' '' '' '' '' 'MATNR' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHARG' '' '' '' '' '' '' 'CHARG' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'TANUM' '' '' '' '' '' '' 'TANUM' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'LFIMG' '' '' '' '' 'VRKME' '' 'LFIMG' 'ZWMDT004' '' '' '' '' ''
        '' '' '' '' '' '' '',
        'VRKME' '' '' '' '' '' '' 'VRKME' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NEWCH' '' '' '' '' '' '' 'NEWCH' 'ZWMDT004' 'New Batch' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZERO' '' '' '' '' '' '' 'ZERO' 'ZWMDT004' 'Zero' '' '' '' '' '' ''
        '' '' '' '' '',
        'RUSAK' '' '' '' '' '' '' 'RUSAK' 'ZWMDT004' 'Rusak' '' '' '' '' '' ''
        '' '' '' '' '',
        'NEWBC' '' '' '' '' '' '' 'NEWBC' 'ZWMDT004' 'New Material' '' '' '' '' '' ''
        '' '' '' '' '',
        'NEWSN' '' '' '' '' '' '' 'NEWSN' 'ZWMDT004' 'New SN' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZNMULD' '' '' '' '' '' '' 'ZNMULD' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZDTSUL' '' '' '' '' '' '' 'ZDTSUL' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZUZSUL' '' '' '' '' '' '' 'ZUZSUL' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZDTEUL' '' '' '' '' '' '' 'ZDTEUL' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZUZEUL' '' '' '' '' '' '' 'ZUZEUL' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
          'MBLNR101' '' '' '' '' '' '' 'MBLNR' 'ZWMDT004' 'Mat.Doc.(101)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR101' '' '' '' '' '' '' 'MJAHR' 'ZWMDT004' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR303' '' '' '' '' '' '' 'MBLNR' 'ZWMDT004' 'Mat.Doc.(303)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR303' '' '' '' '' '' '' 'MJAHR' 'ZWMDT004' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR343' '' '' '' '' '' '' 'MBLNR' 'ZWMDT004' 'Mat.Doc.(343)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR343' '' '' '' '' '' '' 'MJAHR' 'ZWMDT004' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR344' '' '' '' '' '' '' 'MBLNR' 'ZWMDT004' 'Mat.Doc.(344)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR344' '' '' '' '' '' '' 'MJAHR' 'ZWMDT004' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'BASTNO' '' '' '' '' '' '' 'CHAR50' 'ZWMDT004' 'Remark' '' '' '' '' '' ''
          '' '' '' '' '',
          'ZCMPLT' '' '' '' '' '' '' 'ZCMPLT' 'ZWMDT004' 'Status' '' '' '' '' '' ''
          '' '' '' '' ''.

    WHEN radio3.
      PERFORM f_dyn_int_table USING :
        'VBELN' '' '' '' '' '' '' '' '' 'Delivery' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'POSNR' '' '' '' '' '' '' 'POSNR' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'MATNR' '' '' '' '' '' '' 'MATNR' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHARG' '' '' '' '' '' '' 'CHARG' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'TANUM' '' '' '' '' '' '' 'TANUM' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'LFIMG' '' '' '' '' 'VRKME' '' 'LFIMG' 'ZWMDT004' '' '' '' '' ''
        '' '' '' '' '' '' '',
        'VRKME' '' '' '' '' '' '' 'VRKME' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' ''.
    WHEN OTHERS.
      PERFORM f_dyn_int_table USING :
        'VBELN' '' '' '' '' '' '' '' '' 'Delivery' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'POSNR' '' '' '' '' '' '' 'POSNR' 'ZWMDT004' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        'MATNR' '' '' '' '' '' '' 'MATNR' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHARG' '' '' '' '' '' '' 'CHARG' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'LFIMG' '' '' '' '' 'VRKME' '' 'LFIMG' 'ZWMDT004' '' '' '' '' ''
        '' '' '' '' '' '' '',
        'VRKME' '' '' '' '' '' '' 'VRKME' 'ZWMDT004' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NSOLM' '' '' '' '' 'VRKME' '' 'NSOLM' 'LTAP' 'Putaway' '' '' '' ''
        '' '' '' '' '' '' '',
        'LESSD' '' '' '' '' 'VRKME' '' 'NSOLM' 'LTAP' 'Selisih Kurang' '' '' '' ''
        '' '' '' '' '' '' '',
        'MORED' '' '' '' '' 'VRKME' '' 'NSOLM' 'LTAP' 'Selisih Lebih' '' '' '' ''
        '' '' '' '' '' '' '',
        'RUSAK' '' '' '' '' 'VRKME' '' 'NSOLM' 'LTAP' 'Rusak' '' '' '' ''
        '' '' '' '' '' '' '',
        'MBLNR101' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(101)' '' '' '' '' '' ''
        '' '' '' '' '',
        'MJAHR101' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
        '' '' '' '' ''.

      IF radio1 IS NOT INITIAL. " or radio4 IS NOT INITIAL.
        PERFORM f_dyn_int_table USING :
          'MBLNR303L' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(303)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR303L' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR343L' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(343)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR343L' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR344L' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(344)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR344L' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR303R' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(303)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR303R' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR343R' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(343)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR343R' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' '',
          'MBLNR344R' '' '' '' '' '' '' 'MBLNR' 'MKPF' 'Mat.Doc.(344)' '' '' '' '' '' ''
          '' '' '' '' '',
          'MJAHR344R' '' '' '' '' '' '' 'MJAHR' 'MKPF' '' '' '' '' '' '' ''
          '' '' '' '' ''.
      ENDIF.
  ENDCASE.
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
         ls_stylerow TYPE lvc_s_styl.

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
*&      Form  F_STYLE_CELL
*&---------------------------------------------------------------------*
FORM f_style_cell  USING    fu_flag fu_fieldname fu_fieldname1
                   CHANGING fc_celltab  TYPE lvc_t_styl.
  DATA : lt_celltab   TYPE lvc_t_styl WITH HEADER LINE.

  CLEAR : lt_celltab[], lt_celltab.

  IF fu_flag IS NOT INITIAL.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  CLEAR fc_celltab[].

  IF fu_fieldname1 IS NOT INITIAL.
    lt_celltab-fieldname = fu_fieldname1.
    APPEND lt_celltab.
  ENDIF.
  lt_celltab-fieldname = fu_fieldname.
  APPEND lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE fc_celltab.
ENDFORM.                    " F_STYLE_CELL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data  USING    fu_tknum fu_zcmplt
                      CHANGING fc_subrc.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_validate_tlog USING fu_tknum
                              CHANGING fc_subrc.
    WHEN radio2.
      PERFORM f_validate_principal USING fu_tknum fu_zcmplt
                                   CHANGING fc_subrc.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GR_PROCESS
*&---------------------------------------------------------------------*
FORM f_gr_process .
  DATA : lt_xout         TYPE STANDARD TABLE OF ty_out,
         ls_xout         LIKE LINE OF lt_xout,
         lt_yout         TYPE STANDARD TABLE OF ty_out,
         ls_yout         LIKE LINE OF lt_xout,
         ls_out          LIKE LINE OF gt_out,
         lt_gr           TYPE STANDARD TABLE OF ztwsmmst01,
         ls_gr           LIKE LINE OF lt_gr,
         lv_mblnr        TYPE mkpf-mblnr,
         lv_mjahr        TYPE mkpf-mjahr,
         lv_tanum        TYPE ltak-tanum,
         lv_subrc        TYPE sy-subrc,
         lt_post         TYPE STANDARD TABLE OF ztwsmmst01,
         lt_post1        TYPE STANDARD TABLE OF ztwsmmst01,
         lt_post2        TYPE STANDARD TABLE OF ztwsmmst01,
         ls_post         TYPE ztwsmmst01,
         lv_04(100),
         lv_message(255).

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  DELETE lt_xout WHERE icon <> space.

  lt_yout[] = gt_out[].
  SORT lt_yout BY tknum vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_yout COMPARING tknum vbeln.

  LOOP AT lt_xout INTO ls_xout.
    IF ls_xout-tknum = ls_xout-vbeln.
      CONTINUE.
    ENDIF.
    LOOP AT lt_yout INTO ls_yout WHERE tknum = ls_xout-tknum.
      CASE 'X'.
        WHEN radio1.
* GR from TLOG
          PERFORM f_create_goods_receipt USING '01' ls_yout-vbeln pa_budat pa_bktxt
                                         CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                  lv_message.
          IF lv_subrc IS INITIAL.
            PERFORM f_modify_zwmdt004 USING ls_yout '' '101'
                                            lv_mblnr lv_mjahr '' ''.
* Transfer Posting
            CLEAR : lt_post1[], lt_post2[].
            LOOP AT gt_out INTO ls_out WHERE tknum = ls_yout-tknum
                                         AND vbeln = ls_yout-vbeln.
              ls_post-xblnr   = ls_out-vbeln.
              ls_post-posnr   = ls_out-posnr.
              ls_post-lfimg   = ls_out-lfimg.
              ls_post-werks   = gv_werks.
              ls_post-matnr   = ls_out-matnr.
              ls_post-charg   = ls_out-charg.
              IF ls_out-rusak IS NOT INITIAL.
                ls_post-grund        = '0007'.
                ls_post-menge   = ls_out-rusak.
                APPEND ls_post TO lt_post2.
              ENDIF.
              IF ls_out-lessd IS NOT INITIAL.
                ls_post-grund        = '0003'.
                ls_post-menge        = ls_out-lessd.
                APPEND ls_post TO lt_post1.
              ENDIF.
              IF ls_out-mored IS NOT INITIAL.
                ls_post-grund        = '0003'.
                ls_post-menge        = ls_out-mored.
                APPEND ls_post TO lt_post1.
              ENDIF.
              CLEAR ls_post.
            ENDLOOP.

            CLEAR lt_post[].
            lt_post[] = lt_post1[].
            IF lt_post[] IS NOT INITIAL.
              CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
              EXPORT lt_post TO MEMORY ID lv_04.
* Selisih kurang
              PERFORM f_transfer_posting USING '04' ls_yout-vbeln '344' '' pa_budat 'PP'
                                         CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                  lv_message.
              IF lv_subrc IS INITIAL.
                PERFORM f_modify_zwmdt004 USING ls_yout '' '344'
                                                lv_mblnr lv_mjahr '' ''.
* TO 902
                PERFORM f_create_to USING lv_mblnr lv_mjahr '902' '001' ls_yout-vbeln 'TO'
                                    CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum lv_message.
                IF lv_tanum IS NOT INITIAL.
                  CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
                  EXPORT lt_post TO MEMORY ID lv_04.
                  PERFORM f_transfer_posting USING '04' ls_yout-vbeln '343' 'X' pa_budat 'PP'
                                             CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                      lv_message.
                  IF lv_subrc IS INITIAL.
                    PERFORM f_modify_zwmdt004 USING ls_yout '' '343'
                                                    lv_mblnr lv_mjahr '' ''.

                    CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
                    EXPORT lt_post TO MEMORY ID lv_04.
                    PERFORM f_transfer_posting USING '04' ls_yout-vbeln '303' 'X' pa_budat 'PP'
                                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                        lv_message.
                    IF lv_subrc IS INITIAL.
                      PERFORM f_modify_zwmdt004 USING ls_yout '' '303'
                                                      lv_mblnr lv_mjahr '' ''.
                    ELSE.
                      PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                    ENDIF.
                  ELSE.
                    PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                  ENDIF.
                ELSE.
                  PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                ENDIF.
              ELSE.
                PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
              ENDIF.
            ENDIF.

            CLEAR lt_post[].
            lt_post[] = lt_post2[].
            IF lt_post[] IS NOT INITIAL.
              CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
              EXPORT lt_post TO MEMORY ID lv_04.
* Barang rusak
              PERFORM f_transfer_posting USING '04' ls_yout-vbeln '344' '' pa_budat 'EXP'
                                         CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                  lv_message.
              IF lv_subrc IS INITIAL.
                PERFORM f_modify_zwmdt004 USING ls_yout 'X' '344'
                                                lv_mblnr lv_mjahr '' ''.
* TO 997
                PERFORM f_create_to USING lv_mblnr lv_mjahr '997' '001' 'DAMAGE' 'TO'
                                    CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum lv_message.
                IF lv_tanum IS NOT INITIAL.
                  CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
                  EXPORT lt_post TO MEMORY ID lv_04.
                  PERFORM f_transfer_posting USING '04' ls_yout-vbeln '343' 'X' pa_budat 'EXP'
                                             CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                      lv_message.
                  IF lv_subrc IS INITIAL.
                    PERFORM f_modify_zwmdt004 USING ls_yout 'X' '343'
                                                    lv_mblnr lv_mjahr '' ''.

                    CONCATENATE 'TWSGR_04' sy-uname INTO lv_04.
                    EXPORT lt_post TO MEMORY ID lv_04.
                    PERFORM f_transfer_posting USING '04' ls_yout-vbeln '303' 'X' pa_budat 'EXP'
                                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_tanum
                                                        lv_message.
                    IF lv_subrc IS INITIAL.
                      PERFORM f_modify_zwmdt004 USING ls_yout 'X' '303'
                                                      lv_mblnr lv_mjahr '' ''.
                    ELSE.
                      PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                    ENDIF.
                  ELSE.
                    PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                  ENDIF.
                ELSE.
                  PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
                ENDIF.
              ELSE.
                PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
              ENDIF.
            ENDIF.
          ELSE.
            PERFORM f_bapi_error_message USING lv_message ls_yout-tknum ls_yout-vbeln.
          ENDIF.

        WHEN radio2.
* GR from Principal
          PERFORM f_gr_principal USING '01' ls_yout-tknum ls_yout-vbeln
                                 CHANGING lv_subrc lv_mblnr lv_mjahr lv_message.
          IF lv_subrc IS INITIAL.
            IF lv_mblnr IS NOT INITIAL.
              PERFORM f_modify_zwmdt004 USING ls_yout '' '101'
                                              lv_mblnr lv_mjahr '' ''.
            ENDIF.
          ENDIF.
      ENDCASE.
      CLEAR ls_yout.
    ENDLOOP.
    CLEAR ls_xout.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_GR_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_RETURN_MESSAGE
*&---------------------------------------------------------------------*
FORM f_return_message  USING    fu_memory fu_proc fu_vbeln
                       CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum fc_message.
  DATA : lv_memory(100),
         gt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  CLEAR : fc_mblnr, fc_mjahr, fc_tanum, fc_message.

  CONCATENATE fu_memory sy-uname INTO lv_memory.
  IMPORT gt_return FROM MEMORY ID lv_memory.

  IF sy-subrc = 0.
    READ TABLE gt_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      fc_subrc = 4.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = gt_return-id
          lang      = sy-langu
          no        = gt_return-number
          v1        = gt_return-message_v1
          v2        = gt_return-message_v2
          v3        = gt_return-message_v3
          v4        = gt_return-message_v4
        IMPORTING
          msg       = fc_message
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
    ELSE.
      READ TABLE gt_return WITH KEY type = space.
      CASE gt_return-number.
        WHEN '001'.
          SPLIT gt_return-message AT '|' INTO fc_mblnr fc_mjahr.
        WHEN '002'.
          fc_tanum = gt_return-message.
      ENDCASE.
    ENDIF.
  ENDIF.

  FREE MEMORY ID lv_memory.
  CLEAR : rspar_tab[].
ENDFORM.                    " F_RETURN_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_PARAMETER
*&---------------------------------------------------------------------*
FORM f_submit_parameter  USING    fu_selname fu_value fu_kind.
  rspar_line-selname = fu_selname.
  rspar_line-kind    = fu_kind.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = fu_value.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
ENDFORM.                    " F_SUBMIT_PARAMETER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ZWMDT004
*&---------------------------------------------------------------------*
FORM f_modify_zwmdt004  USING    fs_out   TYPE ty_out
                                 fu_ketr fu_flag fu_mblnr fu_mjahr
                                 fu_tknum fu_vbeln.

  DATA : ls_out   LIKE LINE OF gt_out.

  CASE fu_flag.
    WHEN '101'.
      TRY .
          UPDATE zwmdt004 SET mblnr101 = fu_mblnr
                              mjahr101 = fu_mjahr
                          WHERE lgnum = gv_lgnum
                            AND tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      fs_out-mblnr101  = fu_mblnr.
      fs_out-mjahr101  = fu_mjahr.

      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY tknum = fs_out-tknum
                                 vbeln = fs_out-vbeln.
      IF ls_out-icon <> icon_led_red.
        fs_out-icon = icon_led_green.
      ENDIF.

      TRY .
          MODIFY gt_out FROM fs_out
                        TRANSPORTING icon mblnr101 mjahr101
                        WHERE tknum = fs_out-tknum
                          AND vbeln = fs_out-vbeln
                          AND posnr = fs_out-posnr
                          AND matnr = fs_out-matnr
                          AND charg = fs_out-charg.
        CATCH cx_root.
      ENDTRY.

    WHEN '303'.
      IF fu_ketr IS INITIAL.
        TRY .
            UPDATE zwmdt004 SET mblnr303 = fu_mblnr
                                mjahr303 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = space.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr303l  = fu_mblnr.
        fs_out-mjahr303l  = fu_mjahr.
      ELSE.
        TRY .
            UPDATE zwmdt004 SET mblnr303 = fu_mblnr
                                mjahr303 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = 'X'.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr303r  = fu_mblnr.
        fs_out-mjahr303r  = fu_mjahr.
      ENDIF.

      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY tknum = fs_out-tknum
                                 vbeln = fs_out-vbeln.
      IF ls_out-icon <> icon_led_red.
        fs_out-icon = icon_led_green.
      ENDIF.

      IF fu_ketr IS INITIAL.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr303l mjahr303l
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ELSE.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr303r mjahr303r
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ENDIF.

    WHEN '343'.
      IF fu_ketr IS INITIAL.
        TRY .
            UPDATE zwmdt004 SET mblnr343 = fu_mblnr
                                mjahr343 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = space.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr343l  = fu_mblnr.
        fs_out-mjahr343l  = fu_mjahr.
      ELSE.
        TRY .
            UPDATE zwmdt004 SET mblnr343 = fu_mblnr
                                mjahr343 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = 'X'.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr343r  = fu_mblnr.
        fs_out-mjahr343r  = fu_mjahr.
      ENDIF.

      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY tknum = fs_out-tknum
                                 vbeln = fs_out-vbeln.
      IF ls_out-icon <> icon_led_red.
        fs_out-icon = icon_led_green.
      ENDIF.

      IF fu_ketr IS INITIAL.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr343l mjahr343l
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ELSE.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr343r mjahr343r
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ENDIF.

    WHEN '344'.
      IF fu_ketr IS INITIAL.
        TRY .
            UPDATE zwmdt004 SET mblnr344 = fu_mblnr
                                mjahr344 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = space.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr344l  = fu_mblnr.
        fs_out-mjahr344l  = fu_mjahr.
      ELSE.
        TRY .
            UPDATE zwmdt004 SET mblnr344 = fu_mblnr
                                mjahr344 = fu_mjahr
                            WHERE lgnum = gv_lgnum
                              AND tknum = fs_out-tknum
                              AND vbeln = fs_out-vbeln
                              AND rusak = 'X'.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        fs_out-mblnr344r  = fu_mblnr.
        fs_out-mjahr344r  = fu_mjahr.
      ENDIF.

      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY tknum = fs_out-tknum
                                 vbeln = fs_out-vbeln.
      IF ls_out-icon <> icon_led_red.
        fs_out-icon = icon_led_green.
      ENDIF.

      IF fu_ketr IS INITIAL.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr344l mjahr344l
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ELSE.
        TRY .
            MODIFY gt_out FROM fs_out
                          TRANSPORTING icon mblnr344r mjahr344r
                          WHERE tknum = fs_out-tknum
                            AND vbeln = fs_out-vbeln
                            AND posnr = fs_out-posnr
                            AND matnr = fs_out-matnr
                            AND charg = fs_out-charg.
          CATCH cx_root.
        ENDTRY.
      ENDIF.

    WHEN OTHERS.
      fs_out-icon = icon_led_red.
      TRY .
          MODIFY gt_out FROM fs_out
                        TRANSPORTING icon
                        WHERE tknum = fu_tknum
                          AND vbeln = fu_vbeln.
        CATCH cx_root.
      ENDTRY.
  ENDCASE.
ENDFORM.                    " F_MODIFY_ZWMDT004

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_bapi_error_message  USING    fu_message fu_tknum fu_vbeln.
  DATA : ls_return TYPE bapiret2,
         ls_out    TYPE ty_out.

  ls_return-type        = 'E'.
  ls_return-id          = 'ZAB'.
  ls_return-number      = '000'.
  ls_return-message     = fu_message.
  ls_return-message_v1  = fu_message.
  ls_return-message_v2  = fu_tknum.
  ls_return-message_v3  = fu_vbeln.
  APPEND ls_return TO gt_bapiret2.

  PERFORM f_modify_zwmdt004 USING ls_out '' '' '' '' fu_tknum fu_vbeln.
ENDFORM.                    " F_BAPI_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TO
*&---------------------------------------------------------------------*
FORM f_create_to  USING    fu_mblnr fu_mjahr fu_vltyp fu_vlber fu_vlpla
                           fu_proc
                  CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum fc_message.

  PERFORM f_submit_parameter USING : 'PA_MBLNR' fu_mblnr 'P',
                                     'PA_MJAHR' fu_mjahr 'P',
                                     'PA_VLTYP' fu_vltyp 'P',
                                     'PA_VLBER' fu_vlber 'P',
                                     'PA_VLPLA' fu_vlpla 'P'.
  SUBMIT zwmto WITH SELECTION-TABLE rspar_tab AND RETURN.
  PERFORM f_return_message USING 'ZWMTO_RETURN' fu_proc fu_vlpla
                           CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum
                                    fc_message.
ENDFORM.                    " F_CREATE_TO

*&---------------------------------------------------------------------*
*&      Form  F_TRANSEFER_POSTING
*&---------------------------------------------------------------------*
FORM f_transfer_posting  USING    fu_gmcod fu_vbeln fu_bwart fu_grund fu_budat fu_proc
                         CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum fc_message.
  PERFORM f_submit_parameter USING : 'PA_GMCOD' fu_gmcod 'P',
                                     'PA_XBLNR' fu_vbeln 'P',
                                     'PA_BWART' fu_bwart 'P',
                                     'PA_GRUND' fu_grund 'P',
                                     'PA_BUDAT' fu_budat 'P'.
  SUBMIT ztwsgr WITH SELECTION-TABLE rspar_tab AND RETURN.
  PERFORM f_return_message USING 'TWSGR_RETURN' fu_proc fu_vbeln
                           CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum
                                    fc_message.
ENDFORM.                    " F_TRANSEFER_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_GOODS_RECEIPT
*&---------------------------------------------------------------------*
FORM f_create_goods_receipt  USING    fu_gmcod fu_vbeln fu_budat fu_bktxt
                             CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum
                                      fc_message.

  PERFORM f_submit_parameter USING : 'PA_GMCOD' fu_gmcod 'P',
                                     'PA_XBLNR' fu_vbeln 'P',
                                     'PA_BUDAT' fu_budat 'P',
                                     'PA_BKTXT' fu_bktxt 'P'.
  SUBMIT ztwsgr WITH SELECTION-TABLE rspar_tab AND RETURN.
  PERFORM f_return_message USING 'TWSGR_RETURN' 'GR' fu_vbeln
                           CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum fc_message.
ENDFORM.                    " F_CREATE_GOODS_RECEIPT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_TLOG
*&---------------------------------------------------------------------*
FORM f_get_data_tlog .
  DATA : lt_004  TYPE STANDARD TABLE OF zwmdt004,
         lt_likp TYPE STANDARD TABLE OF likp,
         ls_vttp LIKE LINE OF gt_vttp,
         ls_likp LIKE LINE OF lt_likp,
         ls_004  LIKE LINE OF lt_004.

  SELECT *
    FROM zwmdt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE lgnum    = gv_lgnum
      AND tknum    IN so_tknum
      AND zdtsul   IN so_zdtsu
      AND mblnr101 = space.

  PERFORM f_validate_004.

  lt_004[] = gt_004[].
  SORT lt_004[] BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tknum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM vttp
      INTO CORRESPONDING FIELDS OF TABLE gt_vttp
      FOR ALL ENTRIES IN lt_004
      WHERE tknum = lt_004-tknum.

    IF gt_vttp[] IS NOT INITIAL.
      SELECT *
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbeln = gt_vttp-vbeln
          AND werks = pa_werks.
      IF lt_likp[] IS NOT INITIAL.
        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN lt_likp
          WHERE vbeln = lt_likp-vbeln
            AND lfimg <> 0.
      ENDIF.

      LOOP AT gt_vttp INTO ls_vttp.
        CLEAR ls_004.
        READ TABLE gt_004 INTO ls_004
                          WITH KEY tknum = ls_vttp-tknum
                                   vbeln = ls_vttp-vbeln.
        IF sy-subrc <> 0.
          DELETE TABLE gt_vttp FROM ls_vttp.
          CONTINUE.
        ENDIF.

        CLEAR ls_likp.
        READ TABLE lt_likp INTO ls_likp
                           WITH KEY vbeln = ls_vttp-vbeln.
        IF sy-subrc = 0.
          IF ls_likp-lfart = 'YTO1'.
            DELETE TABLE gt_vttp FROM ls_vttp.
          ENDIF.
        ELSE.
          DELETE TABLE gt_vttp FROM ls_vttp.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  lt_004[] = gt_004[].
  SORT lt_004[] BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tanum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = gv_lgnum
        AND tanum = lt_004-tanum.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = gv_lgnum
        AND tanum = lt_004-tanum.
  ENDIF.
ENDFORM.                    " F_GET_DATA_TLOG

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PRINCIPAL
*&---------------------------------------------------------------------*
FORM f_get_data_principal .
  DATA : lt_004   TYPE STANDARD TABLE OF zwmdt004.

  SELECT *
    FROM zwmdt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE tknum    IN so_ebeln
      AND zdtsul   IN so_zdtsu.

  PERFORM f_validate_004.

  lt_004[] = gt_004[].
  SORT lt_004[] BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tknum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
      FOR ALL ENTRIES IN lt_004
      WHERE ebeln = lt_004-tknum
        AND werks = pa_werks.
  ENDIF.

  lt_004[] = gt_004[].
  SORT lt_004[] BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tanum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = gv_lgnum
        AND tanum = lt_004-tanum.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = gv_lgnum
        AND tanum = lt_004-tanum.
  ENDIF.
ENDFORM.                    " F_GET_DATA_PRINCIPAL

*&---------------------------------------------------------------------*
*&      Form  F_TLOG_PROCESS
*&---------------------------------------------------------------------*
FORM f_tlog_process .
  DATA : lt_xvttp TYPE STANDARD TABLE OF vttp,
         lt_004   TYPE STANDARD TABLE OF zwmdt004,
         lt_x004  TYPE STANDARD TABLE OF ty_004,
         ls_x004  LIKE LINE OF lt_x004,
         ls_xvttp LIKE LINE OF lt_xvttp,
         ls_vttp  LIKE LINE OF gt_vttp,
         ls_lips  LIKE LINE OF gt_lips,
         ls_ltak  LIKE LINE OF gt_ltak,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_004   LIKE LINE OF gt_004,
         ls_out   LIKE LINE OF gt_out,
         lv_flag,
         lv_subrc TYPE sy-subrc,
         lv_nsolm TYPE ltap-nsolm.

  lt_xvttp[] = gt_vttp[].
  SORT lt_xvttp[] BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_xvttp COMPARING tknum.

  lt_x004[] = lt_004[] = gt_004[].
  DELETE lt_004 WHERE posnr IS NOT INITIAL.
  DELETE lt_x004 WHERE posnr IS NOT INITIAL.

  LOOP AT lt_xvttp INTO ls_xvttp.
    lv_flag = 'X'.
    PERFORM f_validate_data USING ls_xvttp-tknum ''
                            CHANGING lv_subrc.
    LOOP AT gt_vttp INTO ls_vttp WHERE tknum = ls_xvttp-tknum.
      LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_vttp-vbeln.
        IF lv_flag IS INITIAL.
          PERFORM f_style_cell USING '' 'MARK' ''
                               CHANGING ls_out-style.
        ENDIF.
        IF lv_subrc IS NOT INITIAL.
          ls_out-icon   = icon_led_red.
        ENDIF.
        ls_out-tknum    = ls_xvttp-tknum.
        ls_out-vbeln    = ls_lips-vbeln.
        ls_out-posnr    = ls_lips-posnr.
        ls_out-matnr    = ls_lips-matnr.
        ls_out-charg    = ls_lips-charg.
        ls_out-lfimg    = ls_lips-lfimg.
        ls_out-vrkme    = ls_lips-vrkme.

        LOOP AT gt_004 INTO ls_004 WHERE tknum = ls_xvttp-tknum
                                     AND vbeln = ls_lips-vbeln
                                     AND posnr = ls_lips-posnr
                                     AND newch = space.
          IF ls_004-rusak IS INITIAL AND
            ls_004-rusak IS INITIAL.
            LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_004-tanum.
              ADD ls_ltap-nsolm TO ls_out-nsolm.
            ENDLOOP.
          ELSEIF ls_004-rusak IS NOT INITIAL.
            ADD ls_004-lfimg TO ls_out-rusak.
          ELSEIF ls_004-zero IS NOT INITIAL.
            ADD ls_004-lfimg TO ls_out-lessd.
          ENDIF.

          CLEAR ls_ltak.
          READ TABLE gt_ltak INTO ls_ltak
                             WITH KEY lgnum = gv_lgnum
                                      tanum = ls_004-tanum.
          IF sy-subrc = 0.
            IF ls_ltak-kquit = space.
              PERFORM f_bapi_error_message USING 'Ada TO belum confirm' '' ''.
              ls_out-icon = icon_led_red.
            ENDIF.
          ENDIF.
        ENDLOOP.

***        LOOP AT lt_x004 INTO ls_x004 WHERE tknum = ls_xvttp-tknum
***                                       AND matnr = ls_lips-matnr
***                                       AND charg = ls_lips-charg.
****                                       AND flag  = space.
***          IF ls_x004-charg IS NOT INITIAL.
***            ADD ls_x004-lfimg  TO ls_out-mored.
***            ls_x004-flag = 'X'.
***            MODIFY lt_x004 FROM ls_x004
***                           TRANSPORTING flag
***                           WHERE tknum = ls_xvttp-tknum
***                             AND matnr = ls_lips-matnr
***                             AND charg = ls_lips-charg.
***          ENDIF.
***          CLEAR ls_x004.
***        ENDLOOP.

        IF ls_out-icon <> icon_led_red.
          ls_out-lessd  = ls_out-lfimg - ls_out-nsolm - ls_out-rusak.
          IF ls_out-lessd < 0.
            ls_out-mored = abs( ls_out-lessd ).
            CLEAR ls_out-lessd.
          ENDIF.
        ELSE.
          IF lv_subrc <> 4.
            ls_out-lessd  = ls_out-lfimg - ls_out-nsolm - ls_out-rusak.
            IF ls_out-lessd < 0.
              ls_out-mored = abs( ls_out-lessd ).
              CLEAR ls_out-lessd.
            ENDIF.
          ENDIF.
        ENDIF.
        APPEND ls_out TO gt_out.
        CLEAR : ls_out, ls_lips, lv_flag.
      ENDLOOP.
      CLEAR ls_vttp.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_TLOG_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_PRICIPAL_PROCESS
*&---------------------------------------------------------------------*
FORM f_pricipal_process .
  DATA : lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_x004  TYPE STANDARD TABLE OF zwmdt004,
         ls_xekpo LIKE LINE OF lt_xekpo,
         ls_out   LIKE LINE OF gt_out,
         lt_xout  TYPE STANDARD TABLE OF ty_out,
         ls_xout  LIKE LINE OF gt_out,
         ls_ltak  LIKE LINE OF gt_ltak,
         lv_flag,
         lv_subrc TYPE sy-subrc,
         ls_x004  LIKE LINE OF gt_004,
         ls_004   LIKE LINE OF gt_004,
         ls_ltap  LIKE LINE OF gt_ltap,
         lv_lfimg TYPE lips-lfimg.

  lt_xekpo[] = gt_ekpo[].
  SORT lt_xekpo[] BY ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING ebeln ebelp.

  lt_x004[] = gt_004[].
  SORT lt_x004 BY tknum vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING tknum vbeln posnr.

  LOOP AT lt_xekpo INTO ls_xekpo.
    LOOP AT lt_x004 INTO ls_x004 WHERE tknum = ls_xekpo-ebeln
                                   AND posnr = ls_xekpo-ebelp.
      LOOP AT gt_004 INTO ls_004 WHERE tknum = ls_x004-tknum
                                   AND vbeln = ls_x004-vbeln
                                   AND posnr = ls_x004-posnr.

        PERFORM f_validate_data USING ls_xekpo-ebeln ls_004-zcmplt
                                CHANGING lv_subrc.

        IF lv_subrc IS NOT INITIAL.
          ls_out-icon   = icon_led_red.
        ENDIF.

        ls_out-tknum    = ls_xekpo-ebeln.
        ls_out-vbeln    = ls_004-vbeln.
        ls_out-posnr    = ls_xekpo-ebelp.
        ls_out-matnr    = ls_xekpo-matnr.
        ls_out-lfimg    = ls_xekpo-menge.
        ls_out-vrkme    = ls_xekpo-meins.

        IF ls_004-rusak IS INITIAL AND
          ls_004-zero IS INITIAL.
          LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_004-tanum.
            ADD ls_ltap-nsolm TO ls_out-nsolm.
          ENDLOOP.
        ELSEIF ls_004-rusak IS NOT INITIAL.
          ADD ls_004-lfimg TO ls_out-rusak.
        ELSEIF ls_004-zero IS NOT INITIAL.
          ADD ls_004-lfimg TO ls_out-lessd.
        ENDIF.

        ls_out-mblnr101 = ls_004-mblnr101.
        ls_out-mjahr101 = ls_004-mjahr101.
        IF ls_out-mblnr101 IS NOT INITIAL.
          ADD ls_004-lfimg TO lv_lfimg.
        ENDIF.

        IF ls_out-mjahr101 IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        ls_out-nsolm  = ls_out-nsolm - lv_lfimg.

        IF ls_out-nsolm = 0.
          IF ls_out-rusak IS NOT INITIAL.
            CLEAR ls_xout.
            READ TABLE gt_out INTO ls_xout
                              WITH KEY tknum = ls_out-tknum
                                       vbeln = ls_out-vbeln
                                       posnr = ls_out-posnr.

            ls_out-lessd = ls_xout-lessd - ls_out-rusak.

            MODIFY gt_out FROM ls_out
                          TRANSPORTING lessd rusak
                          WHERE tknum = ls_out-tknum
                            AND vbeln = ls_out-vbeln
                            AND posnr = ls_out-posnr.
            CLEAR : ls_out, lv_lfimg.
          ENDIF.
          CONTINUE.
        ELSE.
          ls_out-lessd  = ls_out-lfimg - ls_out-nsolm. " - ls_out-rusak.
        ENDIF.

        CLEAR ls_ltak.
        READ TABLE gt_ltak INTO ls_ltak
                           WITH KEY lgnum = gv_lgnum
                                    tanum = ls_004-tanum.
        IF sy-subrc = 0.
          IF ls_ltak-kquit = space.
            PERFORM f_bapi_error_message USING 'Ada TO belum confirm' '' ''.
            ls_out-icon = icon_led_red.
          ENDIF.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR : ls_out, lv_lfimg.
      ENDLOOP.
    ENDLOOP.
    CLEAR : lv_subrc, ls_xekpo.
  ENDLOOP.

  lt_xout[] = gt_out[].
  SORT lt_xout BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum.
  LOOP AT lt_xout INTO ls_xout.
    lv_flag = 'X'.
    LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum.
      IF lv_flag IS INITIAL.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      ENDIF.
      MODIFY gt_out FROM ls_out
                    TRANSPORTING style.
      CLEAR : ls_out, lv_flag.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PRICIPAL_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TLOG
*&---------------------------------------------------------------------*
FORM f_validate_tlog  USING    fu_tknum
                      CHANGING fc_subrc.
  DATA : lv_cntr1  TYPE i,
         lv_cntr2  TYPE i,
         ls_vttp   LIKE LINE OF gt_vttp,
         ls_004    LIKE LINE OF gt_004,
         lt_vttp   TYPE STANDARD TABLE OF vttp,
         lt_004    TYPE STANDARD TABLE OF zwmdt004,
         lv_zcmplt TYPE zwmdt004-zcmplt.

  CLEAR : lv_cntr1, lv_cntr2, fc_subrc.
  LOOP AT gt_vttp INTO ls_vttp WHERE tknum = fu_tknum.
    ADD 1 TO lv_cntr1.
  ENDLOOP.
  lt_004[] = gt_004[].
  SORT lt_004 BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tknum vbeln.
  LOOP AT lt_004 INTO ls_004 WHERE tknum = fu_tknum
                               AND posnr <> 0.
    IF ls_004-tknum = ls_004-vbeln.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_cntr2.
    IF ls_004-zcmplt IS NOT INITIAL.
      lv_zcmplt  = ls_004-zcmplt.
    ENDIF.
  ENDLOOP.

  IF lv_cntr1 <> lv_cntr2.
    fc_subrc = 4.
  ENDIF.

  IF lv_zcmplt IS INITIAL.
    PERFORM f_bapi_error_message USING 'Transaksi belum complete' fu_tknum ''.
    fc_subrc = 5.
  ENDIF.

  IF fc_subrc IS INITIAL.
  ENDIF.
ENDFORM.                    " F_VALIDATE_TLOG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PRINCIPAL
*&---------------------------------------------------------------------*
FORM f_validate_principal  USING    fu_tknum fu_zcmplt
                           CHANGING fc_subrc.
  IF fu_zcmplt IS INITIAL.
    PERFORM f_bapi_error_message USING 'Transaksi belum complete' fu_tknum ''.
    fc_subrc = 5.
  ENDIF.
ENDFORM.                    " F_VALIDATE_PRINCIPAL

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_BAST
*&---------------------------------------------------------------------*
FORM f_print_bast .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.

  CASE 'X'.
    WHEN radio1.
      LOOP AT lt_xout INTO ls_xout.
        PERFORM f_submit_parameter USING : 'SO_TKNUM-LOW' ls_xout-tknum 'S'.
      ENDLOOP.

      PERFORM f_submit_parameter USING : 'PA_WERKS' pa_werks 'P',
                                         'RADIO1' 'X' 'P',
                                         'RADIO2' '' 'P'.
    WHEN radio2.
      LOOP AT lt_xout INTO ls_xout.
        PERFORM f_submit_parameter USING : 'SO_EBELN-LOW' ls_xout-tknum 'S'.
        LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum
                                     AND vbeln = ls_xout-vbeln.
          PERFORM f_submit_parameter USING : 'SO_VBELN-LOW' ls_xout-vbeln 'S'.
        ENDLOOP.
      ENDLOOP.
      PERFORM f_submit_parameter USING : 'PA_WERKS' pa_werks 'P',
                                         'RADIO1' '' 'P',
                                         'RADIO2' 'X' 'P'.
  ENDCASE.

  SUBMIT zwm_f001 WITH SELECTION-TABLE rspar_tab AND RETURN.
*  PERFORM f_return_message USING 'TWSGR_RETURN' 'GR' fu_vbeln
*                           CHANGING fc_subrc fc_mblnr fc_mjahr fc_tanum fc_message.
ENDFORM.                    " F_PRINT_BAST

*&---------------------------------------------------------------------*
*&      Form  F_SHOW_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_show_error_message .
  DATA : ls_bapiret2    LIKE LINE OF gt_bapiret2.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT gt_bapiret2 INTO ls_bapiret2.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb                  = ls_bapiret2-id
        msgty                  = ls_bapiret2-type
        msgv1                  = ls_bapiret2-message_v1
        msgv2                  = ls_bapiret2-message_v2
        msgv3                  = ls_bapiret2-message_v3
        msgv4                  = ls_bapiret2-message_v4
        txtnr                  = ls_bapiret2-number
        zeile                  = ls_bapiret2-row
      EXCEPTIONS
        message_type_not_valid = 1
        not_active             = 2
        OTHERS                 = 3.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.
ENDFORM.                    " F_SHOW_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GR_PRINCIPAL
*&---------------------------------------------------------------------*
FORM f_gr_principal  USING    fu_gmcod fu_tknum fu_vbeln
                     CHANGING fc_subrc fc_mblnr fc_mjahr fc_message.
  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
         gs_item          LIKE LINE OF goodsmvt_item.

  DATA : ls_out    LIKE LINE OF gt_out,
         lv_subrc  TYPE sy-subrc,
         gt_return TYPE STANDARD TABLE OF bapiret2.

  CLEAR : fc_mblnr, fc_mjahr.

  READ TABLE gt_out INTO ls_out
                    WITH KEY tknum = fu_tknum
                             vbeln = fu_vbeln
                             mark  = 'X'.
  IF sy-subrc = 0.
    goodsmvt_code                     = fu_gmcod.

    IF pa_budat IS INITIAL.
      goodsmvt_header-pstng_date        = sy-datum.
      goodsmvt_header-doc_date          = sy-datum.
    ELSE.
      goodsmvt_header-pstng_date        = pa_budat.
      goodsmvt_header-doc_date          = pa_budat.
    ENDIF.
    goodsmvt_header-ver_gr_gi_slip    = '3'.
    goodsmvt_header-ver_gr_gi_slipx   = 'X'.
    goodsmvt_header-ref_doc_no        = fu_vbeln.
    goodsmvt_header-header_txt        = pa_bktxt.

    LOOP AT gt_out INTO ls_out WHERE tknum = fu_tknum
                                 AND vbeln = fu_vbeln
                                 AND nsolm <> 0.
      gs_item-po_number         = fu_tknum.
      gs_item-po_item           = ls_out-posnr.

      gs_item-material          = ls_out-matnr.
      gs_item-move_type         = '101'.
      gs_item-stge_loc          = '1000'.
      gs_item-plant             = pa_werks.
*    gs_item-batch         = ls_out-charg.
      gs_item-entry_qnt         = ls_out-nsolm.
      gs_item-entry_uom         = ls_out-vrkme.
*    gs_item-expirydate    = gs_lips-vfdat.
      gs_item-mvt_ind           = 'B'.
      gs_item-stge_bin          = fu_vbeln.
      gs_item-no_transfer_req   = 'X'.
      APPEND gs_item TO goodsmvt_item.
      CLEAR gs_item.
    ENDLOOP.

    IF goodsmvt_item[] IS NOT INITIAL.
      SORT goodsmvt_item BY deliv_numb po_number po_item deliv_item.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = goodsmvt_header
          goodsmvt_code    = goodsmvt_code
        IMPORTING
          materialdocument = materialdocument
          matdocumentyear  = matdocumentyear
        TABLES
          goodsmvt_item    = goodsmvt_item
          return           = return.

      LOOP AT return.
        IF return-type = 'E'.
          lv_subrc  = 4.
        ENDIF.
        APPEND return TO gt_bapiret2.
        CLEAR return.
      ENDLOOP.

      IF lv_subrc IS INITIAL.
        fc_mblnr    = materialdocument.
        fc_mjahr    = matdocumentyear.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        PERFORM f_modify_zwmdt004 USING ls_out '' '' '' '' fu_tknum fu_vbeln.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GR_PRINCIPAL

*&---------------------------------------------------------------------*
*&      Form  F_NEW_MATERIAL
*&---------------------------------------------------------------------*
FORM f_new_material .
  DATA : lt_004 TYPE STANDARD TABLE OF zwmdt004,
         ls_004 LIKE LINE OF lt_004,
         ls_out LIKE LINE OF gt_out.

  lt_004[] = gt_004[].
  DELETE lt_004 WHERE newch = space.

  LOOP AT lt_004 INTO ls_004.
    IF ls_004-tknum <> ls_004-vbeln.
      READ TABLE gt_out INTO ls_out
                        WITH KEY tknum = ls_004-tknum
                                 matnr = ls_004-matnr
                                 charg = ls_004-charg.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    PERFORM f_style_cell USING '' 'MARK' ''
                         CHANGING ls_out-style.
    ls_out-tknum    = ls_004-tknum.
    ls_out-vbeln    = ls_004-vbeln.
    ls_out-posnr    = ls_004-posnr.
    ls_out-matnr    = ls_004-matnr.
    ls_out-charg    = ls_004-charg.
    ls_out-lfimg    = ls_004-lfimg.
    ls_out-vrkme    = ls_004-vrkme.
    ls_out-mored    = ls_004-lfimg.
    IF ls_004-zcmplt IS INITIAL.
      ls_out-icon   = icon_led_red.
    ENDIF.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_NEW_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_004
*&---------------------------------------------------------------------*
FORM f_validate_004 .
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap,
         lt_004  TYPE STANDARD TABLE OF zwmdt004,
         ls_004  LIKE LINE OF lt_004.

  lt_004[] = gt_004[].
  SORT lt_004 BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tanum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = gv_lgnum
        AND tanum = lt_004-tanum.

    LOOP AT lt_004 INTO ls_004.
      CLEAR ls_ltap.
      READ TABLE lt_ltap INTO ls_ltap
                         WITH KEY tanum = ls_004-tanum.
      IF sy-subrc = 0.
        IF ls_ltap-vorga = 'ST' OR
          ls_ltap-vorga = 'SL'.
          DELETE TABLE gt_004 FROM ls_004.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_VALIDATE_004

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_COMPLETE
*&---------------------------------------------------------------------*
FORM f_get_data_complete .
  SELECT *
    FROM zwmdt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE lgnum    = gv_lgnum
      AND tknum    IN so_tknum
      AND zcmplt   <> space.
ENDFORM.                    " F_GET_DATA_COMPLETE

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_DATA_TO_PROCESS
*&---------------------------------------------------------------------*
FORM f_move_data_to_process .
  DATA : lt_x004 TYPE STANDARD TABLE OF zwmdt004,
         ls_x004 LIKE LINE OF lt_x004,
         ls_004  LIKE LINE OF gt_004,
         ls_out  LIKE LINE OF gt_out,
         lv_flag.

  lt_x004[] = gt_004[].
  SORT lt_x004 BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING tknum.
  LOOP AT lt_x004 INTO ls_x004.
    lv_flag = 'X'.
    LOOP AT gt_004 INTO ls_004 WHERE tknum = ls_x004-tknum.
      IF lv_flag IS INITIAL.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      ENDIF.
      ls_out-tknum  = ls_004-tknum.
      ls_out-vbeln  = ls_004-vbeln.
      ls_out-posnr  = ls_004-posnr.
      ls_out-matnr  = ls_004-matnr.
      ls_out-charg  = ls_004-charg.
      ls_out-tanum  = ls_004-tanum.
      ls_out-lfimg  = ls_004-lfimg.
      ls_out-vrkme  = ls_004-vrkme.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lv_flag.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_MOVE_DATA_TO_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_UNCOMPLETE
*&---------------------------------------------------------------------*
FORM f_uncomplete .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  LOOP AT lt_xout INTO ls_xout.
    TRY .
        UPDATE zwmdt004 SET zcmplt = space
                        WHERE lgnum = gv_lgnum
                          AND tknum = ls_xout-tknum.
      CATCH cx_sy_open_sql_db.
    ENDTRY.

    TRY .
        DELETE gt_out WHERE tknum = ls_xout-tknum.
      CATCH cx_os_db_delete.
    ENDTRY.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_UNCOMPLETE

*&---------------------------------------------------------------------*
*&      Form  F_NON_BATCH
*&---------------------------------------------------------------------*
FORM f_non_batch .
  DATA : lt_out TYPE STANDARD TABLE OF ty_out,
         ls_out LIKE LINE OF lt_out.

*lt_out[] = gt_out[].
*SORT lt_out by tknum.
*DELETE ADJACENT DUPLICATES FROM lt_out COMPARING tknum.
*LOOP AT lt_out INTO ls_out.
*
*ENDLOOP.

ENDFORM.                    " F_NON_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_VIEW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_view_data .
  DATA : sellist      TYPE STANDARD TABLE OF vimsellist INITIAL SIZE 0.
  CLEAR: sellist[], sellist.
  SELECT SINGLE lgnum
      FROM t320
      INTO gv_lgnum
      WHERE werks = pa_werks.


  IF gv_lgnum IS NOT INITIAL.
    PERFORM f_sellist TABLES sellist so_tknum
                      USING gv_lgnum 'LGNUM' 'AND' 'PARA'.
  ENDIF.

  IF so_tknum IS NOT INITIAL.
    PERFORM f_sellist TABLES sellist so_tknum
                      USING  ' ' 'TKNUM' 'AND' 'SELE'.
  ENDIF.
  IF so_vbeln IS NOT INITIAL.
    PERFORM f_sellist TABLES sellist so_vbeln
                      USING  ' ' 'VBELN' 'AND' 'SELE'.
  ENDIF.
  IF so_zdtsu IS NOT INITIAL.
    PERFORM f_sellist TABLES sellist so_zdtsu
                      USING  ' ' 'ZDTSUL' 'AND' 'SELED'.
  ENDIF.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'S'
      view_name                    = 'ZWMDT004'
    TABLES
      dba_sellist                  = sellist
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELLIST
*&---------------------------------------------------------------------*
FORM f_sellist  TABLES   sellist  STRUCTURE vimsellist
                         seleopt
                USING    fu_value fieldname append_conjunction p_type.

  DATA : selopt     TYPE STANDARD TABLE OF selopt INITIAL SIZE 0,
         ls_selopt  LIKE LINE OF selopt,
         ls_selopt1 LIKE LINE OF selopt.

  IF p_type = 'PARA'.
    ls_selopt-low    = fu_value.
    ls_selopt-sign   = 'I'.
    ls_selopt-option = 'EQ'.
    APPEND ls_selopt TO selopt.
  ELSE.
    LOOP AT seleopt.
      MOVE-CORRESPONDING seleopt TO ls_selopt.
      IF p_type = 'SELED'.
        IF ls_selopt-low IS NOT INITIAL.
          CONCATENATE ls_selopt-low+5(2) ls_selopt-low+4(2) ls_selopt-low(4) INTO ls_selopt-low.
        ENDIF.
        IF ls_selopt-high IS NOT INITIAL.
          CONCATENATE ls_selopt-high+5(2) ls_selopt-high+4(2) ls_selopt-high(4) INTO ls_selopt-high.
        ENDIF.
        APPEND ls_selopt TO selopt.
      ELSE.
        APPEND ls_selopt TO selopt.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      fieldname          = fieldname
      append_conjunction = append_conjunction
    TABLES
      sellist            = sellist
      rangetab           = selopt.
ENDFORM.                    " F_SELLIST
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_004
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_004 .
  SELECT SINGLE lgnum
      FROM t320
      INTO gv_lgnum
      WHERE werks = pa_werks.

  SELECT *
    FROM zwmdt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE lgnum    = gv_lgnum
      AND tknum    IN so_tknum
      AND zdtsul   IN so_zdtsu.
  "      AND mblnr101 = space.


ENDFORM.
