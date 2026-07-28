*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E011F01
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
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
*  PERFORM f_error_message USING '' ''.
ENDFORM.                    " F_SELECTION_SCREEN

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
  SELECT aufnr gstrp werks plnbez ktext
    FROM caufv
    INTO TABLE gt_caufv
    WHERE aufnr   IN so_aufnr
      AND werks   = pa_werks
      AND gstrp   IN so_gstrp
      AND plnbez  IN so_matnr.

  IF gt_caufv[] IS NOT INITIAL.
    SELECT aufnr objnr
      FROM resb
      INTO TABLE gt_resb
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_caufv   LIKE LINE OF gt_caufv,
         ls_resb    LIKE LINE OF gt_resb,
         ls_jsto    LIKE LINE OF gt_jsto,
         ls_jest    LIKE LINE OF gt_jest,
         ls_out     LIKE LINE OF gt_out.

  DATA : lv_flag,
         lt_stylerow  TYPE lvc_t_styl,
         ls_stylerow  TYPE lvc_s_styl.

  LOOP AT gt_caufv INTO ls_caufv.
    CLEAR lv_flag.
    LOOP AT gt_resb INTO ls_resb WHERE aufnr = ls_caufv-aufnr.
      CLEAR lt_stylerow[].
      IF lv_flag IS NOT INITIAL.
        ls_stylerow-fieldname = 'MARK'.
        ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO lt_stylerow.
        ls_out-style  = lt_stylerow.
      ENDIF.

      CALL FUNCTION 'STATUS_READ'
        EXPORTING
          objnr            = ls_resb-objnr
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        ls_out-aufnr    = ls_caufv-aufnr.
        ls_out-gstrp    = ls_caufv-gstrp.
        ls_out-werks    = ls_caufv-werks.
        ls_out-objnr    = ls_resb-objnr.
        ls_out-plnbez   = ls_caufv-plnbez.
        ls_out-ktext    = ls_caufv-ktext.
        lv_flag         = 'X'.
        APPEND ls_out TO gt_out.

        PERFORM f_status_insert USING : ls_resb-objnr '' 'I0001' 'X' '2' '',
                                        ls_resb-objnr '' 'I0002' '' '1' '',
                                        ls_resb-objnr 'OKP' '' '' '1' 'X'.
      ENDIF.
      CLEAR ls_out-style[].
    ENDLOOP.
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
  DATA : lv_ucomm   TYPE sy-ucomm,
         lv_valid   TYPE c.

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

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_post_data.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
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

  PERFORM f_alv_sort USING : 1 'AUFNR' 'X' '' ''.
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
    'AUFNR' '' '' '' '' '' '' 'AUFNR' 'CAUFV' '' '' '' '' '' '' ''
    'X' '' '' '' '',
    'PLNBEZ' '' '' '' '' '' '' 'PLNBEZ' 'CAUFV' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'KTEXT' '' '' '' '' '' '' 'KTEXT' 'CAUFV' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GSTRP' '' '' '' '' '' '' 'GSTRP' 'CAUFV' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'WERKS' '' '' '' '' '' '' 'WERKS' 'CAUFV' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'OBJNR' '' '' '' '' '' '' 'OBJNR' 'RESB' '' '' '' '' '' '' ''
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
         ls_stylerow        TYPE lvc_s_styl.

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
*&      Form  F_STATUS_INSERT
*&---------------------------------------------------------------------*
FORM f_status_insert  USING    fu_objnr fu_obtyp fu_stat fu_inact
                               fu_chgnr fu_chgkz.
  DATA : ls_jest    LIKE LINE OF gt_jest,
         ls_jsto    LIKE LINE OF gt_jsto.

  IF fu_obtyp IS INITIAL.
    ls_jest-objnr  = fu_objnr.
    ls_jest-stat   = fu_stat.
    ls_jest-inact	 = fu_inact.
    ls_jest-chgnr  = fu_chgnr.
    APPEND ls_jest TO gt_jest.
  ELSE.
    ls_jsto-objnr  = fu_objnr.
    ls_jsto-obtyp  = fu_obtyp.
    ls_jsto-stsma	 = space.
    ls_jsto-chgkz	 = fu_chgkz.
    ls_jsto-chgnr  = fu_chgnr.
    APPEND ls_jsto TO gt_jsto.
  ENDIF.
ENDFORM.                    " F_STATUS_INSERT

*&---------------------------------------------------------------------*
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data .
  DATA : lt_xout  TYPE STANDARD TABLE OF ty_out,
         lt_jest  TYPE STANDARD TABLE OF jest,
         lt_jsto  TYPE STANDARD TABLE OF jsto,
         ls_out   LIKE LINE OF gt_out,
         ls_xout  LIKE LINE OF lt_xout,
         ls_jest  LIKE LINE OF lt_jest,
         ls_jsto  LIKE LINE OF lt_jsto.

  DATA : oref         TYPE REF TO cx_root,
         lt_stylerow  TYPE lvc_t_styl,
         ls_stylerow  TYPE lvc_s_styl,
         lv_message(100).

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      LOOP AT gt_out INTO ls_out WHERE aufnr = ls_xout-aufnr.
        LOOP AT gt_jest INTO ls_jest WHERE objnr = ls_out-objnr.
          APPEND ls_jest TO lt_jest.
          CLEAR ls_jest.
        ENDLOOP.
        LOOP AT gt_jsto INTO ls_jsto WHERE objnr = ls_out-objnr.
          APPEND ls_jsto TO lt_jsto.
          CLEAR ls_jsto.
        ENDLOOP.
      ENDLOOP.

      IF ls_xout-style[] IS INITIAL.
        ls_stylerow-fieldname = 'MARK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO lt_stylerow.
        ls_xout-style  = lt_stylerow.
        ls_xout-mark   = space.
        MODIFY gt_out FROM ls_xout
                      TRANSPORTING style mark
                      WHERE aufnr = ls_out-aufnr.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lt_jest[] IS NOT INITIAL.
    TRY .
        INSERT jest FROM TABLE lt_jest.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.

  IF lt_jsto[] IS NOT INITIAL.
    TRY .
        INSERT jsto FROM TABLE lt_jsto.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_POST_DATA
