*&---------------------------------------------------------------------*
*&  Include           ZWM_E005F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  DATA : lv_mess(100).

  IF pa_lgnum IS INITIAL.
    PERFORM f_error_message USING 'PLG' ''.
  ELSE.
    AUTHORITY-CHECK OBJECT 'L_LGNUM'
             ID 'LGNUM' FIELD pa_lgnum.
    IF sy-subrc <> 0.
      CONCATENATE 'You are not authorized for WH' pa_lgnum
      INTO lv_mess
      SEPARATED BY space.
      PERFORM f_error_message USING 'PLG' lv_mess.
    ENDIF.
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
  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE gt_ltak
    WHERE lgnum   = pa_lgnum
      AND tanum   IN so_tanum
      AND bdatu   IN so_bdatu
      AND vbeln   IN so_vbeln
      AND kquit   = space.

  IF gt_ltak[] IS NOT INITIAL.
    SELECT * FROM vttp INTO CORRESPONDING FIELDS OF TABLE gt_vttp
      FOR ALL ENTRIES IN gt_ltak
      WHERE vbeln = gt_ltak-vbeln AND
      tknum IN so_tknum.

  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_ltak LIKE LINE OF gt_ltak,
         ls_out  LIKE LINE OF gt_out.

  IF so_tknum IS NOT INITIAL.
    LOOP AT gt_ltak INTO ls_ltak.
      ls_out-lgnum    = ls_ltak-lgnum.
      ls_out-bdatu    = ls_ltak-bdatu.
      ls_out-vbeln    = ls_ltak-vbeln.
      ls_out-tanum    = ls_ltak-tanum.
      READ TABLE gt_vttp INTO DATA(ls_vttp) WITH KEY vbeln = ls_ltak-vbeln.
      IF sy-subrc = 0 .
        ls_out-tknum = ls_vttp-tknum.
        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDIF.


*    APPEND ls_out TO gt_out.
*    CLEAR ls_out.
    ENDLOOP.
  ELSE.
    LOOP AT gt_ltak INTO ls_ltak.
      ls_out-lgnum    = ls_ltak-lgnum.
      ls_out-bdatu    = ls_ltak-bdatu.
      ls_out-vbeln    = ls_ltak-vbeln.
      ls_out-tanum    = ls_ltak-tanum.

      APPEND ls_out TO gt_out.
      CLEAR ls_out.
    ENDLOOP.
  ENDIF.
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

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE1'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMANND
*&---------------------------------------------------------------------*
FORM f_user_commannd .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c.

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

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMANND

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

  PERFORM f_alv_sort USING : 1 'TANUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '',
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'LGNUM' '' '' '' '' '' '' 'LGNUM' 'LTAK' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'BDATU' '' '' '' '' '' '' 'BDATU' 'LTAK' '' '' '' '' '' '' ''
    '' '' '' '' '',
        'TKNUM' '' '' '' '' '' '' 'TKNUM' 'VTTP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'VBELN' '' '' '' '' '' '' 'VBELN' 'LTAK' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'TANUM' '' '' '' '' '' '' 'TANUM' 'LTAK' '' '' '' '' '' '' ''
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
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out,
         ls_out   LIKE LINE OF lt_out,
         lv_subrc TYPE sy-subrc.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.

  IF lt_out[] IS NOT INITIAL.
    LOOP AT lt_out INTO ls_out.

      PERFORM f_confirm_posible USING '' pa_lgnum ls_out-tanum.
      PERFORM f_confirm_to USING pa_lgnum ls_out-tanum
                           CHANGING lv_subrc.
      "      PERFORM f_update_queue USING lv_subrc pa_lgnum ls_out-tanum.

      IF lv_subrc IS INITIAL.
        ls_out-icon   = icon_led_green.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
        CLEAR ls_out-mark.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark icon style
                      WHERE vbeln = ls_out-vbeln
                        AND tanum = ls_out-tanum.

        IF pa_block IS NOT INITIAL.
          PERFORM f_block_putaway USING pa_lgnum ls_out-tanum.
        ENDIF.
      ELSE.
        ls_out-icon   = icon_led_red.
        CLEAR ls_out-mark.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark icon
                      WHERE vbeln = ls_out-vbeln
                        AND tanum = ls_out-tanum.
      ENDIF.
      CLEAR ls_out.
    ENDLOOP.

    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

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
*&      Form  F_CONFIRM_POSIBLE
*&---------------------------------------------------------------------*
FORM f_confirm_posible  USING    fu_kgvnq fu_lgnum fu_tanum.
  TRY .
      UPDATE ltak SET kgvnq = fu_kgvnq
                  WHERE lgnum = fu_lgnum
                    AND tanum = fu_tanum.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
ENDFORM.                    " F_CONFIRM_POSIBLE

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_TO
*&---------------------------------------------------------------------*
FORM f_confirm_to  USING    fu_lgnum fu_tanum
                   CHANGING fc_subrc.
  DATA : t_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         s_ltap_conf LIKE LINE OF t_ltap_conf,
         lt_ltap     TYPE STANDARD TABLE OF ltap,
         ls_ltap     LIKE LINE OF lt_ltap.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum   = fu_lgnum
      AND tanum   = fu_tanum
      AND pvqui = space.

  LOOP AT lt_ltap INTO ls_ltap.
    s_ltap_conf-tanum   = ls_ltap-tanum.
    s_ltap_conf-tapos   = ls_ltap-tapos.
    s_ltap_conf-squit   = 'X'.
    APPEND s_ltap_conf TO t_ltap_conf.
    CLEAR s_ltap_conf.
  ENDLOOP.

  CALL FUNCTION 'L_TO_CONFIRM'
    EXPORTING
      i_lgnum                        = fu_lgnum
      i_tanum                        = fu_tanum
    TABLES
      t_ltap_conf                    = t_ltap_conf
    EXCEPTIONS
      to_confirmed                   = 1
      to_doesnt_exist                = 2
      item_confirmed                 = 3
      item_subsystem                 = 4
      item_doesnt_exist              = 5
      item_without_zero_stock_check  = 6
      item_with_zero_stock_check     = 7
      one_item_with_zero_stock_check = 8
      item_su_bulk_storage           = 9
      item_no_su_bulk_storage        = 10
      one_item_su_bulk_storage       = 11
      foreign_lock                   = 12
      squit_or_quantities            = 13
      vquit_or_quantities            = 14
      bquit_or_quantities            = 15
      quantity_wrong                 = 16
      double_lines                   = 17
      kzdif_wrong                    = 18
      no_difference                  = 19
      no_negative_quantities         = 20
      wrong_zero_stock_check         = 21
      su_not_found                   = 22
      no_stock_on_su                 = 23
      su_wrong                       = 24
      too_many_su                    = 25
      nothing_to_do                  = 26
      no_unit_of_measure             = 27
      xfeld_wrong                    = 28
      update_without_commit          = 29
      no_authority                   = 30
      lqnum_missing                  = 31
      charg_missing                  = 32
      no_sobkz                       = 33
      no_charg                       = 34
      nlpla_wrong                    = 35
      two_step_confirmation_required = 36
      two_step_conf_not_allowed      = 37
      pick_confirmation_missing      = 38
      quknz_wrong                    = 39
      hu_data_wrong                  = 40
      no_hu_data_required            = 41
      hu_data_missing                = 42
      hu_not_found                   = 43
      picking_of_hu_not_possible     = 44
      not_enough_stock_in_hu         = 45
      serial_number_data_wrong       = 46
      serial_numbers_not_required    = 47
      no_differences_allowed         = 48
      serial_number_not_available    = 49
      serial_number_data_missing     = 50
      to_item_split_not_allowed      = 51
      input_wrong                    = 52
      OTHERS                         = 53.

  fc_subrc = sy-subrc.
ENDFORM.                    " F_CONFIRM_TO

*&---------------------------------------------------------------------*
*&      Form  F_BLOCK_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_block_putaway  USING    fu_lgnum fu_tanum.
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  IF sy-subrc = 0.
    LOOP AT lt_ltap INTO ls_ltap.
      TRY .
          UPDATE lagp SET skzue = 'X'
                          spgru = 'Z'
                      WHERE lgnum = pa_lgnum
                        AND lgtyp = ls_ltap-vltyp
                        AND lgpla = ls_ltap-vlpla.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_BLOCK_PUTAWAY

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_QUEUE
*&---------------------------------------------------------------------*
FORM f_update_queue  USING    fu_subrc fu_lgnum fu_tanum.
  DATA : lv_queue   TYPE ltak-queue.

  IF fu_subrc = 0.
    CASE fu_lgnum.
      WHEN 'C40'.
***        SELECT SINGLE queue
***          FROM ltak
***          INTO lv_queue
***          WHERE lgnum = fu_lgnum
***            AND tanum = fu_tanum.
***
***        lv_queue = |{ lv_queue }{ 'AB' }|.
***        CONDENSE lv_queue NO-GAPS.
***
***        TRY .
***            UPDATE ltak SET queue = lv_queue
***                        WHERE lgnum = fu_lgnum
***                          AND tanum = fu_tanum.
***          CATCH cx_sy_open_sql_db.
***        ENDTRY.
    ENDCASE.
  ENDIF.
ENDFORM.
