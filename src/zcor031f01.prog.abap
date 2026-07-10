*&---------------------------------------------------------------------*
*&  Include           ZCOR031F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_bklas         LIKE LINE OF gr_bklas.

  PERFORM f_create_row.
  PERFORM f_create_period_column.

  CLEAR ls_bklas.
  ls_bklas-low    = '7920'.
  ls_bklas-sign   = 'E'.
  ls_bklas-option = 'EQ'.
  APPEND ls_bklas TO gr_bklas.
  CLEAR ls_bklas.
  ls_bklas-low    = '7930'.
  ls_bklas-sign   = 'E'.
  ls_bklas-option = 'EQ'.
  APPEND ls_bklas TO gr_bklas.
  CLEAR ls_bklas.
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
  IF pa_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.

  IF pa_bdatj IS INITIAL.
    PERFORM f_error_message USING 'PBJ' ''.
  ENDIF.

  IF pa_poper IS INITIAL.
    PERFORM f_error_message USING 'PPO' ''.
  ENDIF.
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
  DATA : lr_bdatj   TYPE RANGE OF bdatj,
         ls_bdatj   LIKE LINE OF lr_bdatj.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  ls_bdatj-low    = pa_bdatj - 1.
  ls_bdatj-high   = pa_bdatj.
  ls_bdatj-sign   = 'I'.
  ls_bdatj-option = 'BT'.
  APPEND ls_bdatj TO lr_bdatj.

  SELECT *
    FROM marc
    INTO CORRESPONDING FIELDS OF TABLE gt_marc
    WHERE werks = pa_werks.

  IF gt_marc[] IS NOT INITIAL.
    SELECT *
      FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE gt_mbew
      FOR ALL ENTRIES IN gt_marc
      WHERE matnr = gt_marc-matnr
        AND bwkey = gt_marc-werks.
  ENDIF.

  IF gt_mbew[] IS NOT INITIAL.
    SELECT *
      FROM ckmlcr
      INTO CORRESPONDING FIELDS OF TABLE gt_ckmlcr
      FOR ALL ENTRIES IN gt_mbew
      WHERE kalnr = gt_mbew-kaln1
        AND bdatj IN lr_bdatj.
  ENDIF.

  PERFORM f_get_wip.
  PERFORM f_get_cogs.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  PERFORM f_inventory_position.
  PERFORM f_calculate_quantity.
  PERFORM f_cost_of_goods_sold.
  PERFORM f_coverage_turn_over.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 101.
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
        rows    = 4
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_contain02.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 3
        column    = 1
      RECEIVING
        container = g_contain03.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 4
        column    = 1
      RECEIVING
        container = g_contain04.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         dynlog   TYPE smp_dyntxt.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE1'.

  PERFORM f_excluding_toolbar.

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
      CALL METHOD g_grid1->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_grid1->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_grid1->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMANND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_grid1 IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_grid1
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout USING '1'.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_grid1.

    CALL METHOD g_grid1->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort1[]
        it_outtab            = <fs_1>[]
        it_fieldcatalog      = gt_fieldcat1[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER2_ALV
*&---------------------------------------------------------------------*
FORM f_container2_alv .
  IF g_grid2 IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_grid2
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain02.

    PERFORM f_build_layout USING '2'.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_grid2.

    CALL METHOD g_grid2->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort2[]
        it_outtab            = <fs_2>[]
        it_fieldcatalog      = gt_fieldcat2[].
  ENDIF.
ENDFORM.                    " F_CONTAINER2_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout USING fu_container.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-zebra               = selected.
*  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.

  gs_layout_alv-info_fname      = 'LINE_COLOR'.
  gs_layout_alv-stylefname      = 'XYZSTYLEZYX'.
  gs_layout_alv-ctab_fname      = 'COLOR'.

  CASE fu_container.
    WHEN '1'.
      gs_layout_alv-grid_title         = 'INVENTORY POSITION'.
    WHEN '2'.
      gs_layout_alv-grid_title         = 'COST OF GOODS SOLD'.
    WHEN '3'.
      gs_layout_alv-grid_title         = 'INVENTORY COVERAGE'.
    WHEN '4'.
      gs_layout_alv-grid_title         = 'INVENTORY TURNOVER'.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_sort2.

*  PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_container1.
  PERFORM f_container2.
  PERFORM f_container2x.
  PERFORM f_container3.
  PERFORM f_container4.
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
                               fu_nosum fu_container.
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

  CASE fu_container.
    WHEN '1'.
      APPEND ls_dyn_fcat TO gt_fieldcat1.
    WHEN '2'.
      APPEND ls_dyn_fcat TO gt_fieldcat2.
    WHEN '2X'.
      APPEND ls_dyn_fcat TO gt_fieldcat2x.
    WHEN '3'.
      APPEND ls_dyn_fcat TO gt_fieldcat3.
    WHEN '4'.
      APPEND ls_dyn_fcat TO gt_fieldcat4.
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

  gt_sort1-spos      = fu_spos.
  gt_sort1-fieldname = fu_fieldname.
  gt_sort1-up        = fu_up.
  gt_sort1-down      = fu_down.
  gt_sort1-subtot    = fu_subtot.
  APPEND gt_sort1.
  CLEAR gt_sort1.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
*  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
*  DATA : lv_style           TYPE lvc_s_styl-style,
*         lt_stylerow        TYPE lvc_t_styl,
*         ls_stylerow        TYPE lvc_s_styl.
*
*  DATA : ls_out             LIKE LINE OF gt_out.
*
*  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
*    IMPORTING
*      et_fieldcatalog = ls_fieldcatalog[].
*
*  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
*  IF sy-subrc = 0.
*    IF ls_fieldcatalog-edit IS NOT INITIAL.
*      LOOP AT gt_out INTO ls_out.
*        READ TABLE ls_out-style INTO ls_stylerow
*                                WITH KEY fieldname = 'MARK'.
*        IF sy-subrc = 0 AND
*            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*          CONTINUE.
*        ENDIF.
*        ls_out-mark = fu_check.
*        MODIFY gt_out FROM ls_out.
*        CLEAR ls_out.
*      ENDLOOP.
*    ENDIF.
*    PERFORM f_alv_refresh USING 'X'.
*  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_grid1 IS NOT INITIAL.
      CALL METHOD g_grid1->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_value
                   CHANGING fc_value fc_ktx fc_bdatj.

  DATA : lv_mnr   TYPE t247-mnr.

  lv_mnr  = fu_value(2).

  CALL FUNCTION 'CONVERSION_EXIT_PERI7_INPUT'
    EXPORTING
      input           = fu_value
    IMPORTING
      output          = fc_value
    EXCEPTIONS
      input_not_valid = 1
      OTHERS          = 2.

  SELECT SINGLE ktx
    FROM t247
    INTO fc_ktx
    WHERE spras = sy-langu
      AND mnr   = lv_mnr.

  fc_bdatj  = fu_value+3(4).
ENDFORM.                    " F_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_COMPONENT
*&---------------------------------------------------------------------*
FORM f_assign_component  USING    fu_field fu_value fu_count fu_container.
  FIELD-SYMBOLS <fs>  TYPE ANY.

  CASE fu_container.
    WHEN '1'.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    WHEN '2'.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    WHEN '2X'.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2x> TO <fs>.
    WHEN '3'.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l3> TO <fs>.
    WHEN '4'.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l4> TO <fs>.
  ENDCASE.

  IF <fs> IS ASSIGNED.
    IF fu_count IS INITIAL.
      <fs> = fu_value.
    ELSE.
      ADD fu_value TO <fs>.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ASSIGN_COMPONENT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ROW
*&---------------------------------------------------------------------*
FORM f_create_row .
  PERFORM f_row USING : '1' 'Raw Material' '2000' '' '1',
                        '2' 'Pack Material' '3050' '' '1',
                        '3' 'Work in Process' '7900' '' '1',
                        '3' 'Work in Process' '7910' '' '1',
                        '4' 'Finished Goods' '7920' '' '1',
                        '4' 'Finished Goods' '7930' '' '1'.

  PERFORM f_row USING : '1' 'Raw Material' '' '' '2',
                        '2' '6 month average' '' '' '2',
                        '3' 'Pack Material' '' '' '2',
                        '4' '6 month average' '' '' '2',
                        '5' 'MOH' '' '' '2',
                        '6' '6 month average' '' '' '2',
                        '7' 'Finished Goods' '' '' '2',
                        '8' '6 month average' '' '' '2',
                        '9' 'Total' '' '' '2',
                        '10' '6 month average' '' '' '2'.

  PERFORM f_row USING : '1' 'Raw Material' '' '' '3',
                        '2' 'Pack Material' '' '' '3',
                        '3' 'Work in Process' '' '' '3',
                        '4' 'Total' '' '' '3'.

  PERFORM f_row USING : '1' 'Raw Material' '' '' '4',
                        '2' 'Pack Material' '' '' '4',
                        '3' 'Work in Process' '' '' '4'.
ENDFORM.                    " F_CREATE_ROW

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PERIOD_COLUMN
*&---------------------------------------------------------------------*
FORM f_create_period_column .
  DATA : lv_datum   TYPE sy-datum,
         lv_input(10),
         ls_x1      TYPE ty_x,
         ls_x2      TYPE ty_x,
         lv_subrc   TYPE sy-subrc.

  CONCATENATE pa_bdatj pa_poper+1(2) '01' INTO lv_datum.

  WHILE lv_subrc IS INITIAL.
    WRITE lv_datum TO lv_input DD/MM/YYYY.
    PERFORM f_conversion USING lv_input+3(7)
                         CHANGING ls_x1-perio ls_x1-ktx ls_x1-bdatj.
    APPEND ls_x1 TO gt_x1.
    lv_datum = lv_datum - 1.
    CONCATENATE lv_datum(6) '01' INTO lv_datum.
    IF lv_datum(4) <> pa_bdatj.
      lv_subrc = 4.
    ENDIF.
  ENDWHILE.

  gt_x2[] = gt_x1[].
  CONCATENATE pa_bdatj '0101' INTO lv_datum.
  lv_datum = lv_datum - 1.
  DO 6 TIMES.
    WRITE lv_datum TO lv_input DD/MM/YYYY.
    PERFORM f_conversion USING lv_input+3(7)
                         CHANGING ls_x2-perio ls_x2-ktx
                                  ls_x2-bdatj.
    APPEND ls_x2 TO gt_x2.
    CONCATENATE lv_datum(6) '01' INTO lv_datum.
    lv_datum = lv_datum - 1.
  ENDDO.
ENDFORM.                    " F_CREATE_PERIOD_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_ROW
*&---------------------------------------------------------------------*
FORM f_row  USING    fu_buzei fu_bkbez fu_low fu_high fu_container.
  DATA : ls_row   LIKE LINE OF gt_row1.

  ls_row-buzei  = fu_buzei.
  ls_row-bkbez  = fu_bkbez.
  ls_row-low    = fu_low.
  IF fu_high IS INITIAL.
    ls_row-high   = fu_low.
  ELSE.
    ls_row-high   = fu_high.
  ENDIF.
  ls_row-sign   = 'I'.
  ls_row-option = 'BT'.

  CASE fu_container.
    WHEN '1'.
      APPEND ls_row TO gt_row1.
    WHEN '2'.
      APPEND ls_row TO gt_row2.
    WHEN '3'.
      APPEND ls_row TO gt_row3.
    WHEN '4'.
      APPEND ls_row TO gt_row4.
  ENDCASE.
ENDFORM.                    " F_ROW

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER1
*&---------------------------------------------------------------------*
FORM f_container1 .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data,
         ls_x             LIKE LINE OF gt_x1,
         fname(30),
         title(30),
         lv_mnr           TYPE t247-mnr.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'MARC' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '1',
    'BKBEZ' '' '' '' '' '' '' 'BKBEZ' 'T025T' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '1',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'CKMLCR' '' '' '' '' '' '' ''
    '' '' '' '' '' '1'.

  SORT gt_x1 BY perio.
  LOOP AT gt_x1 INTO ls_x.
    CONCATENATE 'SALKV' ls_x-perio INTO fname.
    CONCATENATE ls_x-ktx ls_x-bdatj INTO title
    SEPARATED BY space.
    PERFORM f_dyn_int_table USING :
      fname '' '' 'WAERS' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' ''
      '' '' '' '' '' 'X' '' '1'.
  ENDLOOP.

  lv_mnr  = pa_poper.
  SELECT SINGLE ktx
    FROM t247
    INTO title
    WHERE spras = sy-langu
      AND mnr   = lv_mnr.
  IF sy-subrc = 0.
    CONCATENATE 'Average' title pa_bdatj INTO title
    SEPARATED BY space.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'SALKV' '' '' 'WAERS' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' '' ''
    '' '' '' '' '' '' '1'.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fieldcat1
      i_length_in_byte          = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_1>.
    CREATE DATA ls_line LIKE LINE OF <fs_1>.
    ASSIGN ls_line->* TO <fs_l1>.
  ENDIF.
ENDFORM.                    " F_CONTAINER1

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER2
*&---------------------------------------------------------------------*
FORM f_container2 .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data,
         ls_xline         TYPE REF TO data,
         ls_x             LIKE LINE OF gt_x1,
         fname(30),
         title(30),
         lv_mnr           TYPE t247-mnr.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'MARC' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '2',
    'BKBEZ' '' '' '' '' '' '' 'BKBEZ' 'T025T' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '2',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'CKMLCR' '' '' '' '' '' '' ''
    '' '' '' '' '' '2'.

  SORT gt_x2 BY perio.
  LOOP AT gt_x2 INTO ls_x.
    CONCATENATE 'SALKV' ls_x-perio INTO fname.
    CONCATENATE ls_x-ktx ls_x-bdatj INTO title
    SEPARATED BY space.
    PERFORM f_dyn_int_table USING :
      fname '' '' 'WAERS' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' ''
      '' '' '' '' '' '' '' '2'.
  ENDLOOP.

  lv_mnr  = pa_poper.
  SELECT SINGLE ktx
    FROM t247
    INTO title
    WHERE spras = sy-langu
      AND mnr   = lv_mnr.
  IF sy-subrc = 0.
    CONCATENATE 'Average' title pa_bdatj INTO title
    SEPARATED BY space.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'SALKV' '' '' 'WAERS' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' '' ''
    '' '' '' '' '' '' '2',
    'LINE_COLOR' '' '' '' '' '' '' '' '' '4' '' '' '' '' '' ''
    '' '' '' '' '' '2'.

  PERFORM f_dyn_int_table USING :
    'COLOR' '' '' '' '' '' '' 'COLTAB' 'CALENDAR_TYPE' '' '' '' '' ''
    '' '' '' '' '' '' '' '2'.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fieldcat2
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_2>.
    CREATE DATA ls_line LIKE LINE OF <fs_2>.
    ASSIGN ls_line->* TO <fs_l2>.
  ENDIF.
ENDFORM.                    " F_CONTAINER2

*&---------------------------------------------------------------------*
*&      Form  F_AVERAGE_CALCULATE
*&---------------------------------------------------------------------*
FORM 	f_average_calculate USING fs TYPE any fs_x TYPE any
                                fu_calc.
  DATA : ls_x1      LIKE LINE OF gt_x1,
         lv_fname(30),
         lv_salkv   TYPE ckmlcr-salkv,
         lv_total   TYPE ckmlcr-salkv,
         lv_count   TYPE i,
         lv_datum   TYPE sy-datum,
         lv_subrc   TYPE sy-subrc.

  FIELD-SYMBOLS : <fs>    TYPE ANY.

  CASE fu_calc.
    WHEN '1'.
      CLEAR : lv_count, lv_salkv, lv_total.
      LOOP AT gt_x1 INTO ls_x1.
        CONCATENATE 'FS-SALKV' ls_x1-perio INTO lv_fname.
        ASSIGN (lv_fname) TO <fs>.
        IF <fs> IS ASSIGNED.
          lv_salkv = <fs>.
          IF lv_salkv IS NOT INITIAL.
            ADD lv_salkv TO lv_total.
            ADD 1 TO lv_count.
          ENDIF.
        ENDIF.
      ENDLOOP.

      TRY .
          lv_total  = lv_total / lv_count.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      lv_fname  = 'FS-SALKV'.
      ASSIGN (lv_fname) TO <fs>.
      <fs> = lv_total.

    WHEN '2'.
      LOOP AT gt_x1 INTO ls_x1.
        CONCATENATE 'FS_X-TEMP' ls_x1-perio INTO lv_fname.
        ASSIGN (lv_fname) TO <fs>.
        IF <fs> IS ASSIGNED.
          lv_total = <fs>.
          IF lv_total IS NOT INITIAL.
            ADD 1 TO lv_count.
          ENDIF.
        ENDIF.

        CONCATENATE ls_x1-perio(4) ls_x1-perio+5(2) '01' INTO lv_datum.
        DO 5 TIMES.
          lv_subrc = 4.
          lv_datum = lv_datum - 1.
          CONCATENATE 'FS_X-TEMP' lv_datum(4) '0' lv_datum+4(2)
          INTO lv_fname.
          ASSIGN (lv_fname) TO <fs>.
          IF sy-subrc IS INITIAL.
            CLEAR lv_subrc.
          ELSE.
            CONCATENATE 'FS-SALKV' lv_datum(4) '0' lv_datum+4(2)
            INTO lv_fname.
            IF sy-subrc IS INITIAL.
              CLEAR lv_subrc.
            ENDIF.
          ENDIF.

          IF lv_subrc IS INITIAL.
            IF <fs> IS ASSIGNED.
              lv_salkv = <fs>.
              IF lv_salkv IS NOT INITIAL.
                ADD 1 TO lv_count.
                ADD lv_salkv TO lv_total.
              ENDIF.
            ENDIF.
          ENDIF.
          CONCATENATE lv_datum(6) '01' INTO lv_datum.
          CLEAR : lv_salkv.
        ENDDO.

        TRY .
            lv_total = lv_total / lv_count.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        CONCATENATE 'FS-SALKV' ls_x1-perio INTO lv_fname.
        ASSIGN (lv_fname) TO <fs>.
        <fs> = lv_total.
        CLEAR : lv_count, lv_total.
      ENDLOOP.

      lv_fname  = 'FS-SALKV'.
      ASSIGN (lv_fname) TO <fs>.
      CLEAR <fs>.
  ENDCASE.
ENDFORM.                    " F_AVERAGE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_WIP
*&---------------------------------------------------------------------*
FORM f_get_wip .
  DATA : lt_glt0    TYPE STANDARD TABLE OF glt0,
         ls_glt0    LIKE LINE OF lt_glt0,
         lr_racct   TYPE RANGE OF racct,
         ls_racct   LIKE LINE OF lr_racct,
         ls_x       LIKE LINE OF gt_x1,
         lv_field(30),
         lt_wip     TYPE STANDARD TABLE OF ty_wip,
         ls_wip     LIKE LINE OF lt_wip.

  FIELD-SYMBOLS : <fs>  TYPE ANY.

  ls_racct-low    = '0132200000'.
  ls_racct-sign   = 'I'.
  ls_racct-option = 'EQ'.
  APPEND ls_racct TO lr_racct.
  ls_racct-low    = '0132200009'.
  ls_racct-sign   = 'I'.
  ls_racct-option = 'EQ'.
  APPEND ls_racct TO lr_racct.

  SELECT *
    FROM glt0
    INTO CORRESPONDING FIELDS OF TABLE lt_glt0
    WHERE ryear   = pa_bdatj
      AND racct   IN lr_racct
      AND rbusa   = pa_werks.

  LOOP AT lt_glt0 INTO ls_glt0.
    PERFORM f_calc_wip USING '' ls_glt0-drcrk ls_glt0-tslvt.
    LOOP AT gt_x1 INTO ls_x.
      CONCATENATE 'LS_GLT0-TSL' ls_x-perio+5(2) INTO lv_field.
      ASSIGN (lv_field) TO <fs>.
      IF <fs> IS ASSIGNED.
        PERFORM f_calc_wip USING ls_x-perio ls_glt0-drcrk <fs>.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  lt_wip[] = gt_wip[].
  CLEAR : gt_wip[].
  SORT lt_wip BY perio.
  LOOP AT lt_wip INTO ls_wip.
    COLLECT ls_wip INTO gt_wip.
    CLEAR ls_wip.
  ENDLOOP.
ENDFORM.                    " F_GET_WIP

*&---------------------------------------------------------------------*
*&      Form  F_CALC_WIP
*&---------------------------------------------------------------------*
FORM f_calc_wip  USING    fu_perio fu_drcrk fu_tslvt.
  DATA : ls_wip   LIKE LINE OF gt_wip.

  ls_wip-perio  = fu_perio.
  IF fu_drcrk = 'H'.
    ls_wip-tslvt_h  = fu_tslvt.
  ELSE.
    ls_wip-tslvt_s  = fu_tslvt.
  ENDIF.
  APPEND ls_wip TO gt_wip.
ENDFORM.                    " F_CALC_WIP

*&---------------------------------------------------------------------*
*&      Form  F_INVENTORY_POSITION
*&---------------------------------------------------------------------*
FORM f_inventory_position .
  DATA : lt_xrow    TYPE STANDARD TABLE OF ty_row,
         ls_xrow    LIKE LINE OF lt_xrow,
         ls_row     LIKE LINE OF gt_row1,
         ls_mbew    LIKE LINE OF gt_mbew,
         ls_ckmlcr  LIKE LINE OF gt_ckmlcr,
         lv_field(30),
         lv_perio   TYPE jahrper,
         ls_x       LIKE LINE OF gt_x1,
         lv_tslvt   TYPE glt0-tslvt,
         ls_wip     LIKE LINE OF gt_wip,
         lv_salkv   TYPE ckmlcr-salkv.

  FIELD-SYMBOLS <fs> TYPE ANY.

  lt_xrow[] = gt_row1[].
  SORT lt_xrow BY buzei.
  DELETE ADJACENT DUPLICATES FROM lt_xrow COMPARING buzei.

  LOOP AT lt_xrow INTO ls_xrow.
    PERFORM f_assign_component USING : 'WERKS' pa_werks '' '1',
                                       'BKBEZ' ls_xrow-bkbez '' '1',
                                       'WAERS' 'IDR' '' '1'.
    CASE ls_xrow-buzei.
      WHEN '003'.
        LOOP AT gt_x1 INTO ls_x.
          CLEAR lv_salkv.
          LOOP AT gt_wip INTO ls_wip.
            IF ls_wip-perio > ls_x-perio.
              EXIT.
            ENDIF.
            lv_tslvt  = ls_wip-tslvt_s + ls_wip-tslvt_h.
            ADD lv_tslvt TO lv_salkv.
          ENDLOOP.
          CONCATENATE 'SALKV' ls_x-perio INTO lv_field.
          PERFORM f_assign_component USING lv_field lv_salkv 'X' '1'.
        ENDLOOP.

      WHEN OTHERS.
        LOOP AT gt_row1 INTO ls_row WHERE buzei = ls_xrow-buzei.
          LOOP AT gt_mbew INTO ls_mbew WHERE bklas = ls_row-low.
            LOOP AT gt_ckmlcr INTO ls_ckmlcr WHERE kalnr = ls_mbew-kaln1.
              CONCATENATE ls_ckmlcr-bdatj ls_ckmlcr-poper
              INTO lv_perio.
              CLEAR ls_x.
              READ TABLE gt_x1 INTO ls_x
                               WITH KEY perio = lv_perio.
              IF sy-subrc = 0.
                CONCATENATE 'SALKV' ls_ckmlcr-bdatj ls_ckmlcr-poper
                INTO lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlcr-salkv 'X' '1'.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDLOOP.
    ENDCASE.

    PERFORM f_average_calculate USING <fs_l1> '' '1'.

    APPEND <fs_l1> TO <fs_1>.
    CLEAR <fs_l1>.
  ENDLOOP.
ENDFORM.                    " F_INVENTORY_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_COST_OF_GOODS_SOLD
*&---------------------------------------------------------------------*
FORM f_cost_of_goods_sold .
  DATA : lt_mbew          TYPE STANDARD TABLE OF mbew,
         ls_row           LIKE LINE OF gt_row2,
         ls_mbew          LIKE LINE OF gt_mbew,
         ls_ckmlprkeph    LIKE LINE OF gt_ckmlprkeph,
         lv_perio         TYPE jahrper,
         ls_x1            LIKE LINE OF gt_x1,
         ls_x2            LIKE LINE OF gt_x2,
         lv_field(30),
         lv_clear,
         lv_kst000        TYPE mlccs_d_kstel.

  FIELD-SYMBOLS <fs> TYPE ANY.

  lt_mbew[] = gt_mbew[].
  DELETE lt_mbew WHERE bklas IN gr_bklas.

  LOOP AT gt_row2 INTO ls_row.
    PERFORM f_assign_component USING : 'WERKS' pa_werks '' '2',
                                       'BKBEZ' ls_row-bkbez '' '2',
                                       'WAERS' 'IDR' '' '2'.

    PERFORM f_assign_component USING : 'WERKS' pa_werks '' '2X',
                                       'BKBEZ' ls_row-bkbez '' '2X'.

    LOOP AT lt_mbew INTO ls_mbew.
      LOOP AT gt_ckmlprkeph INTO ls_ckmlprkeph WHERE kalnr = ls_mbew-kaln1.
        CONCATENATE ls_ckmlprkeph-bdatj ls_ckmlprkeph-poper
        INTO lv_perio.
        CLEAR ls_x2.
        READ TABLE gt_x2 INTO ls_x2
                         WITH KEY perio = lv_perio.
        IF sy-subrc = 0.
          CASE ls_row-buzei.
            WHEN '1'.
              IF ls_ckmlprkeph-kst001 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst001 'X' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst001 'X' '2X'.
                ENDIF.
              ENDIF.
            WHEN '3'.
              IF ls_ckmlprkeph-kst003 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst003 'X' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst003 'X' '2X'.
                ENDIF.
              ENDIF.
            WHEN '5'.
              IF ls_ckmlprkeph-kst005 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst005 'X' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst005 'X' '2X'.
                ENDIF.
              ENDIF.

              IF ls_ckmlprkeph-kst007 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst007 'X' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst007 'X' '2X'.
                ENDIF.
              ENDIF.
            WHEN '7'.
              IF ls_ckmlprkeph-kst011 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst011 'X ' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field ls_ckmlprkeph-kst011 'X' '2X'.
                ENDIF.
              ENDIF.
            WHEN '9'.
              lv_kst000 = ls_ckmlprkeph-kst001 + ls_ckmlprkeph-kst003 + ls_ckmlprkeph-kst005 +
                          ls_ckmlprkeph-kst007 + ls_ckmlprkeph-kst011.
              IF lv_kst000 IS NOT INITIAL.
                PERFORM f_create_dyn_field USING 'SALKV' ls_ckmlprkeph-bdatj
                                                  ls_ckmlprkeph-poper
                                           CHANGING lv_field.
                PERFORM f_assign_component USING lv_field lv_kst000 'X ' '2'.
                CLEAR ls_x1.
                READ TABLE gt_x1 INTO ls_x1
                                 WITH KEY perio = lv_perio.
                IF sy-subrc = 0.
                  PERFORM f_create_dyn_field USING 'TEMP' ls_ckmlprkeph-bdatj
                                                    ls_ckmlprkeph-poper
                                             CHANGING lv_field.
                  PERFORM f_assign_component USING lv_field lv_kst000 'X' '2X'.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    CASE ls_row-buzei.
      WHEN '1' OR '3' OR '5' OR '7' OR '9'.
        PERFORM f_average_calculate USING <fs_l2> '' '1'.
        IF ls_row-buzei = '9'.
          PERFORM f_assign_component USING 'LINE_COLOR' 'C310' '' '2'.
          PERFORM f_total_style TABLES gt_x2
                                USING <fs_l2>.
        ENDIF.
      WHEN OTHERS.
        PERFORM f_average_calculate USING <fs_l2> <fs_l2x> '2'.
        IF ls_row-buzei = '10'.
          PERFORM f_assign_component USING 'LINE_COLOR' 'C310' '' '2'.
        ELSE.
          PERFORM f_assign_component USING 'LINE_COLOR' 'C300' '' '2'.
        ENDIF.
        PERFORM f_clear_field USING <fs_l2> :
                                    'SALKV' 'X',
                                    'WERKS' ''.
        lv_clear = 'X'.
    ENDCASE.

    APPEND <fs_l2> TO <fs_2>.
    IF lv_clear IS NOT INITIAL.
      CLEAR : <fs_l2>, <fs_l2x>, lv_clear.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_COST_OF_GOODS_SOLD

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER2X
*&---------------------------------------------------------------------*
FORM f_container2x .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data,
         ls_xline         TYPE REF TO data,
         ls_x             LIKE LINE OF gt_x1,
         fname(30),
         title(30).

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'MARC' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '2X',
    'BKBEZ' '' '' '' '' '' '' 'BKBEZ' 'T025T' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '2X'.

  SORT gt_x1 BY perio.
  LOOP AT gt_x1 INTO ls_x.
    CONCATENATE 'TEMP' ls_x-perio INTO fname.
    CONCATENATE ls_x-ktx ls_x-bdatj INTO title
    SEPARATED BY space.
    PERFORM f_dyn_int_table USING :
      fname '' '' 'WAERS' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' ''
      '' '' '' '' '' '' '' '2X'.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fieldcat2x
      i_length_in_byte          = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_2x>.
    CREATE DATA ls_line LIKE LINE OF <fs_2x>.
    ASSIGN ls_line->* TO <fs_l2x>.
  ENDIF.
ENDFORM.                    " F_CONTAINER2X

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_FIELD
*&---------------------------------------------------------------------*
FORM f_clear_field  USING fs TYPE any
                          fu_field fu_concat.
  DATA : ls_x1    LIKE LINE OF gt_x1,
         ls_x2    LIKE LINE OF gt_x2,
         lv_fname(30).

  FIELD-SYMBOLS <fs>  TYPE ANY.

  IF fu_concat IS NOT INITIAL.
    LOOP AT gt_x2 INTO ls_x2.
      READ TABLE gt_x1 INTO ls_x1
                       WITH KEY perio = ls_x2-perio.
      IF sy-subrc <> 0.
        CONCATENATE fu_field ls_x2-perio INTO lv_fname.
        ASSIGN COMPONENT lv_fname OF STRUCTURE fs TO <fs>.
        CLEAR <fs>.
      ENDIF.
    ENDLOOP.
  ELSE.
    ASSIGN COMPONENT fu_field OF STRUCTURE fs TO <fs>.
    CLEAR <fs>.
  ENDIF.
ENDFORM.                    " F_CLEAR_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_FIELD
*&---------------------------------------------------------------------*
FORM f_create_dyn_field  USING    fu_val01 fu_val02 fu_val03
                         CHANGING fc_value.
  CLEAR fc_value.
  CONCATENATE fu_val01 fu_val02 fu_val03
  INTO fc_value.
ENDFORM.                    " F_CREATE_DYN_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_STYLE_CELL
*&---------------------------------------------------------------------*
FORM f_style_cell  USING    ft_tabstyle   TYPE lvc_t_styl
                            ft_tabcolor   TYPE lvc_t_scol
                            fu_field fu_bold fu_col fu_int fu_inv.
  DATA : ls_tabstyle  TYPE lvc_s_styl,
         ls_tabcolor  TYPE lvc_s_scol.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  IF fu_bold IS NOT INITIAL.
    CLEAR ls_tabstyle.
    ls_tabstyle-fieldname = fu_field.

    ls_tabstyle-maxlen = 0.
    ls_tabstyle-style  = fu_bold.
    INSERT ls_tabstyle INTO TABLE ft_tabstyle.
  ENDIF.

  IF fu_col IS NOT INITIAL.
    CLEAR ls_tabcolor.
    ls_tabcolor-fname = fu_field.

    ls_tabcolor-color-col = fu_col.
    ls_tabcolor-color-int = fu_int.
    ls_tabcolor-color-inv = fu_inv.
    INSERT ls_tabcolor INTO TABLE ft_tabcolor.
  ENDIF.
ENDFORM.                    " F_STYLE_CELL

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER3
*&---------------------------------------------------------------------*
FORM f_container3 .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data,
         ls_x             LIKE LINE OF gt_x1,
         fname(30),
         title(30),
         lv_mnr           TYPE t247-mnr.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'MARC' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '3',
    'BKBEZ' '' '' '' '' '' '' 'BKBEZ' 'T025T' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '3'.

  SORT gt_x1 BY perio.
  LOOP AT gt_x1 INTO ls_x.
    CONCATENATE 'SALKV' ls_x-perio INTO fname.
    CONCATENATE ls_x-ktx ls_x-bdatj INTO title
    SEPARATED BY space.
    PERFORM f_dyn_int_table USING :
      fname '' '' '' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' ''
      '' '' '' '' '' '' '' '3'.
  ENDLOOP.

  lv_mnr  = pa_poper.
  SELECT SINGLE ktx
    FROM t247
    INTO title
    WHERE spras = sy-langu
      AND mnr   = lv_mnr.
  IF sy-subrc = 0.
    CONCATENATE 'Average' title pa_bdatj INTO title
    SEPARATED BY space.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'SALKV' '' '' '' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' '' ''
    '' '' '' '' '' '' '3',
    'LINE_COLOR' '' '' '' '' '' '' '' '' '4' '' '' '' '' '' ''
    '' '' '' '' '' '3'.

  PERFORM f_dyn_int_table USING :
    'COLOR' '' '' '' '' '' '' 'COLTAB' 'CALENDAR_TYPE' '' '' '' '' ''
    '' '' '' '' '' '' '' '3'.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fieldcat3
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_3>.
    CREATE DATA ls_line LIKE LINE OF <fs_3>.
    ASSIGN ls_line->* TO <fs_l3>.
  ENDIF.
ENDFORM.                    " F_CONTAINER3

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER3_ALV
*&---------------------------------------------------------------------*
FORM f_container3_alv .
  IF g_grid3 IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_grid3
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain03.

    PERFORM f_build_layout USING '3'.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_grid3.

    CALL METHOD g_grid3->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort3[]
        it_outtab            = <fs_3>[]
        it_fieldcatalog      = gt_fieldcat3[].
  ENDIF.
ENDFORM.                    " F_CONTAINER3_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER4
*&---------------------------------------------------------------------*
FORM f_container4 .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data,
         ls_x             LIKE LINE OF gt_x1,
         fname(30),
         title(30),
         lv_mnr           TYPE t247-mnr.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'MARC' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '4',
    'BKBEZ' '' '' '' '' '' '' 'BKBEZ' 'T025T' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '4'.

  SORT gt_x1 BY perio.
  LOOP AT gt_x1 INTO ls_x.
    CONCATENATE 'SALKV' ls_x-perio INTO fname.
    CONCATENATE ls_x-ktx ls_x-bdatj INTO title
    SEPARATED BY space.
    PERFORM f_dyn_int_table USING :
      fname '' '' '' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' ''
      '' '' '' '' '' '' '' '4'.
  ENDLOOP.

  lv_mnr  = pa_poper.
  SELECT SINGLE ktx
    FROM t247
    INTO title
    WHERE spras = sy-langu
      AND mnr   = lv_mnr.
  IF sy-subrc = 0.
    CONCATENATE 'Average' title pa_bdatj INTO title
    SEPARATED BY space.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'SALKV' '' '' '' '' '' '' 'SALKV' 'CKMLCR' title '' '' '' '' ''
    '' '' '' '' '' '' '4',
    'LINE_COLOR' '' '' '' '' '' '' '' '' '4' '' '' '' '' '' ''
    '' '' '' '' '' '4'.

  PERFORM f_dyn_int_table USING :
    'COLOR' '' '' '' '' '' '' 'COLTAB' 'CALENDAR_TYPE' '' '' '' '' ''
    '' '' '' '' '' '' '' '4'.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fieldcat4
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_4>.
    CREATE DATA ls_line LIKE LINE OF <fs_4>.
    ASSIGN ls_line->* TO <fs_l4>.
  ENDIF.
ENDFORM.                    " F_CONTAINER4

*&---------------------------------------------------------------------*
*&      Module  CONTAINER4_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE container4_alv OUTPUT.
  PERFORM f_container4_alv.
ENDMODULE.                 " CONTAINER4_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CONTAINER4_ALV
*&---------------------------------------------------------------------*
FORM f_container4_alv .
  IF g_grid4 IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_grid4
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain04.

    PERFORM f_build_layout USING '4'.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_grid4.

    CALL METHOD g_grid4->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort4[]
        it_outtab            = <fs_4>[]
        it_fieldcatalog      = gt_fieldcat4[].
  ENDIF.
ENDFORM.                    " F_CONTAINER4_ALV

*&---------------------------------------------------------------------*
*&      Form  F_COVERAGE_TURN_OVER
*&---------------------------------------------------------------------*
FORM f_coverage_turn_over .
  DATA : ls_row     LIKE LINE OF gt_row3,
         lv_field(30),
         ls_x1      LIKE LINE OF gt_x1,
         lv_flag.

  LOOP AT gt_row3 INTO ls_row.
    PERFORM f_assign_component USING : 'WERKS' pa_werks '' '3',
                                       'BKBEZ' ls_row-bkbez '' '3'.

    PERFORM f_assign_component USING : 'WERKS' pa_werks '' '4',
                                       'BKBEZ' ls_row-bkbez '' '4'.

    LOOP AT gt_x1 INTO ls_x1.
      CONCATENATE 'SALKV' ls_x1-perio INTO lv_field.
      CASE ls_row-buzei.
        WHEN '1'.
          PERFORM f_inventory_coverage_rpm USING ls_row-buzei lv_field 'X'.
        WHEN '2'.
          PERFORM f_inventory_coverage_rpm USING ls_row-buzei lv_field 'X'.
        WHEN '3'.
          PERFORM f_inventory_coverage_wip USING ls_row-buzei lv_field 'X'.
        WHEN '4'.
          PERFORM f_inventory_coverage_total USING ls_row-buzei lv_field 'X'.
      ENDCASE.
    ENDLOOP.

    CASE ls_row-buzei.
      WHEN '1'.
        PERFORM f_inventory_coverage_rpm USING ls_row-buzei 'SALKV' ''.
      WHEN '2'.
        PERFORM f_inventory_coverage_rpm USING ls_row-buzei 'SALKV' ''.
      WHEN '3'.
        PERFORM f_inventory_coverage_wip USING ls_row-buzei 'SALKV' ''.
      WHEN '4'.
        PERFORM f_inventory_coverage_total USING ls_row-buzei 'SALKV' ''.
    ENDCASE.

    IF ls_row-buzei = '4'.
      lv_flag = 'X'.
      PERFORM f_total_style TABLES gt_x1
                            USING <fs_l3>.

      PERFORM f_clear_field USING <fs_l3> :
                                  'WERKS' ''.
    ENDIF.

    IF lv_flag IS INITIAL.
      APPEND <fs_l3> TO <fs_3>.
      APPEND <fs_l4> TO <fs_4>.
    ELSE.
      APPEND <fs_l3> TO <fs_3>.
    ENDIF.
    CLEAR <fs_l3>.
  ENDLOOP.
ENDFORM.                    " F_COVERAGE_TURN_OVER

*&---------------------------------------------------------------------*
*&      Form  F_TOTAL_STYLE
*&---------------------------------------------------------------------*
FORM f_total_style TABLES ft_x  LIKE gt_x2
                   USING  fs TYPE any.
  DATA : lt_tabstyle  TYPE lvc_t_styl,
         lt_tabcolor  TYPE lvc_t_scol,
         ls_x         LIKE LINE OF gt_x2,
         lv_field(30).

  FIELD-SYMBOLS <fs>  TYPE ANY.

  PERFORM f_style_cell USING lt_tabstyle lt_tabcolor :
                             'WERKS' '00000121' '2' '1' '0',
                             'BKBEZ' '00000121' '2' '1' '0',
                             'WAERS' '00000121' '2' '1' '0',
                             'SALKV' '00000121' '2' '1' '0'.
  LOOP AT ft_x INTO ls_x.
    CONCATENATE 'SALKV' ls_x-perio INTO lv_field.
    PERFORM f_style_cell USING lt_tabstyle lt_tabcolor :
                               lv_field '00000121' '2' '1' '0'.
  ENDLOOP.

  IF lt_tabstyle[] IS NOT INITIAL.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE fs TO <fs>.
    <fs> = lt_tabstyle.
  ENDIF.
  IF lt_tabcolor[] IS NOT INITIAL.
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE fs TO <fs>.
    <fs> = lt_tabcolor.
  ENDIF.
ENDFORM.                    " F_TOTAL_STYLE

*&---------------------------------------------------------------------*
*&      Form  F_INVENTORY_COVERAGE_RPM
*&---------------------------------------------------------------------*
FORM f_inventory_coverage_rpm  USING    fu_index fu_field fu_add.
  DATA : lv_index   TYPE i,
         lv_salkv1  TYPE ckmlcr-salkv,
         lv_salkv2  TYPE ckmlcr-salkv,
         lv_salkv3  TYPE ckmlcr-salkv,
         lv_salkv4  TYPE ckmlcr-salkv.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  lv_index  = fu_index.

  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    IF <fs> IS ASSIGNED.
      lv_salkv1  = <fs>.
    ENDIF.
  ENDIF.

  IF fu_add IS INITIAL.
    CASE fu_index.
      WHEN 1.
        lv_index = 1.
      WHEN 2.
        lv_index = 3.
      WHEN 3.
        lv_index = 5.
    ENDCASE.
  ELSE.
    lv_index  = lv_index + 1.
  ENDIF.

  READ TABLE <fs_2> ASSIGNING <fs_l2> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    lv_salkv2  = <fs>.
  ENDIF.

  TRY.
      lv_salkv3 = ( lv_salkv1 / lv_salkv2 ) * 30.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l3> TO <fs>.
      <fs> = lv_salkv3.
    CATCH cx_sy_zerodivide.
  ENDTRY.

  TRY .
      lv_salkv4 = 360 / lv_salkv3.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l4> TO <fs>.
      <fs> = lv_salkv4.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_INVENTORY_COVERAGE_RPM

*&---------------------------------------------------------------------*
*&      Form  F_INVENTORY_COVERAGE_WIP
*&---------------------------------------------------------------------*
FORM f_inventory_coverage_wip  USING    fu_index fu_field fu_add.
  DATA : lv_index   TYPE i,
         lv_salkv1  TYPE ckmlcr-salkv,
         lv_salkv2  TYPE ckmlcr-salkv,
         lv_salkv3  TYPE ckmlcr-salkv,
         lv_salkv4  TYPE ckmlcr-salkv,
         lv_salkv5  TYPE ckmlcr-salkv,
         lv_salkv6  TYPE ckmlcr-salkv.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  lv_index  = fu_index.

  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    IF <fs> IS ASSIGNED.
      lv_salkv1  = <fs>.
    ENDIF.
  ENDIF.

  IF fu_add IS INITIAL.
    lv_index = 1.
  ELSE.
    lv_index  = 2.
  ENDIF.
  READ TABLE <fs_2> ASSIGNING <fs_l2> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    lv_salkv2  = <fs>.
  ENDIF.
  IF fu_add IS INITIAL.
    lv_index = 3.
  ELSE.
    lv_index  = 4.
  ENDIF.
  READ TABLE <fs_2> ASSIGNING <fs_l2> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    lv_salkv3  = <fs>.
  ENDIF.
  IF fu_add IS INITIAL.
    lv_index = 5.
  ELSE.
    lv_index  = 6.
  ENDIF.
  READ TABLE <fs_2> ASSIGNING <fs_l2> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    lv_salkv4  = <fs>.
  ENDIF.

  TRY.
      lv_salkv5 = ( lv_salkv1 / ( lv_salkv2 + lv_salkv3 + lv_salkv4 ) ) * 30.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l3> TO <fs>.
      <fs> = lv_salkv5.
    CATCH cx_sy_zerodivide.
  ENDTRY.

  TRY .
      lv_salkv6 = 360 / lv_salkv5.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l4> TO <fs>.
      <fs> = lv_salkv6.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_INVENTORY_COVERAGE_WIP

*&---------------------------------------------------------------------*
*&      Form  F_INVENTORY_COVERAGE_TOTAL
*&---------------------------------------------------------------------*
FORM f_inventory_coverage_total  USING    fu_index fu_field fu_flag.
  DATA : lv_index   TYPE i,
         lv_salkv1  TYPE ckmlcr-salkv,
         lv_salkv2  TYPE ckmlcr-salkv,
         lv_salkv3  TYPE ckmlcr-salkv,
         lv_salkv4  TYPE ckmlcr-salkv,
         lv_salkv5  TYPE ckmlcr-salkv,
         lv_salkv6  TYPE ckmlcr-salkv.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  lv_index  = 1.
  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    IF <fs> IS ASSIGNED.
      lv_salkv1  = <fs>.
    ENDIF.
  ENDIF.
  lv_index  = 2.
  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    lv_salkv2  = <fs>.
  ENDIF.
  lv_index  = 3.
  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    lv_salkv3  = <fs>.
  ENDIF.
  lv_index  = 4.
  READ TABLE <fs_1> ASSIGNING <fs_l1> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l1> TO <fs>.
    lv_salkv4  = <fs>.
  ENDIF.

  IF fu_flag IS INITIAL.
    lv_index  = 9.
  ELSE.
    lv_index  = 10.
  ENDIF.
  READ TABLE <fs_2> ASSIGNING <fs_l2> INDEX lv_index.
  IF sy-subrc = 0.
    ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l2> TO <fs>.
    lv_salkv5  = <fs>.
  ENDIF.

  TRY.
      lv_salkv6 = ( ( lv_salkv1 + lv_salkv2 + lv_salkv3 + lv_salkv4 ) / lv_salkv5 ) * 30.
      ASSIGN COMPONENT fu_field OF STRUCTURE <fs_l3> TO <fs>.
      <fs> = lv_salkv6.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_INVENTORY_COVERAGE_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_COGS
*&---------------------------------------------------------------------*
FORM f_get_cogs .
  DATA : lt_mbew    TYPE STANDARD TABLE OF mbew,
         ls_mbew    LIKE LINE OF lt_mbew,
         lr_bdatj   TYPE RANGE OF bdatj,
         ls_bdatj   LIKE LINE OF lr_bdatj.

  ls_bdatj-low    = pa_bdatj - 1.
  ls_bdatj-high   = pa_bdatj.
  ls_bdatj-sign   = 'I'.
  ls_bdatj-option = 'BT'.
  APPEND ls_bdatj TO lr_bdatj.

  lt_mbew[] = gt_mbew[].
  DELETE lt_mbew WHERE bklas IN gr_bklas.
  IF lt_mbew[] IS NOT INITIAL.
    SELECT *
      FROM ckmlprkeph
      INTO CORRESPONDING FIELDS OF TABLE gt_ckmlprkeph
      FOR ALL ENTRIES IN lt_mbew
      WHERE kalnr = lt_mbew-kaln1
        AND bdatj IN lr_bdatj
        AND keart = 'H'
        AND prtyp = 'V'
        AND kkzst = space
        AND curtp = '10'.

    SELECT *
      FROM keko
      INTO CORRESPONDING FIELDS OF TABLE gt_keko
      FOR ALL ENTRIES IN lt_mbew
      WHERE kalnr = lt_mbew-kaln1
        AND freidat <> 0
        AND bwvar = '001'.

    SELECT *
      FROM mlcd
      INTO CORRESPONDING FIELDS OF TABLE gt_mlcd
      FOR ALL ENTRIES IN lt_mbew
      WHERE kalnr = lt_mbew-kaln1
        AND bdatj IN lr_bdatj.

    IF gt_mlcd[] IS NOT INITIAL.
      SELECT *
        FROM ckmlmv005
        INTO CORRESPONDING FIELDS OF TABLE gt_ckmlmv005
        FOR ALL ENTRIES IN gt_mlcd
        WHERE kalnr = gt_mlcd-bvalt
          AND spez_name_nd = 'V_REST'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_COGS

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calculate_quantity .
  DATA : ls_ckmlprkeph    LIKE LINE OF gt_ckmlprkeph,
         ls_mlcd          LIKE LINE OF gt_mlcd,
         ls_ckmlmv005     LIKE LINE OF gt_ckmlmv005,
         ls_keko          LIKE LINE OF gt_keko.

  DATA : lv_lbkum         TYPE mlcd-lbkum,
         lv_losau         TYPE keko-losau,
         lv_datum         TYPE sy-datum.

  LOOP AT gt_ckmlprkeph INTO ls_ckmlprkeph.
    CLEAR ls_mlcd.
    LOOP AT gt_mlcd INTO ls_mlcd WHERE kalnr = ls_ckmlprkeph-kalnr
                                   AND bdatj = ls_ckmlprkeph-bdatj
                                   AND poper = ls_ckmlprkeph-poper.
      CLEAR : ls_ckmlmv005, lv_lbkum.
      READ TABLE gt_ckmlmv005 INTO ls_ckmlmv005
                              WITH KEY kalnr = ls_mlcd-bvalt.
      IF sy-subrc = 0.
        lv_lbkum  = ls_mlcd-lbkum.
        EXIT.
      ENDIF.
    ENDLOOP.

    CONCATENATE ls_ckmlprkeph-bdatj ls_ckmlprkeph-poper+1(2) '01'
    INTO lv_datum.

    CLEAR ls_keko.
    LOOP AT gt_keko INTO ls_keko WHERE kalnr = ls_ckmlprkeph-kalnr.
      IF ls_keko-kadat <= lv_datum AND
        ls_keko-bidat >= lv_datum.
        lv_losau  = ls_keko-losau.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_losau IS NOT INITIAL.
      ls_ckmlprkeph-kst001 = ls_ckmlprkeph-kst001 * lv_lbkum / lv_losau.
      ls_ckmlprkeph-kst003 = ls_ckmlprkeph-kst003 * lv_lbkum / lv_losau.
      ls_ckmlprkeph-kst005 = ls_ckmlprkeph-kst005 * lv_lbkum / lv_losau.
      ls_ckmlprkeph-kst007 = ls_ckmlprkeph-kst007 * lv_lbkum / lv_losau.
      ls_ckmlprkeph-kst011 = ls_ckmlprkeph-kst011 * lv_lbkum / lv_losau.
      MODIFY TABLE gt_ckmlprkeph FROM ls_ckmlprkeph
                                 TRANSPORTING kst001 kst003 kst005 kst007
                                              kst011.
    ENDIF.
    CLEAR ls_ckmlprkeph.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_QUANTITY
