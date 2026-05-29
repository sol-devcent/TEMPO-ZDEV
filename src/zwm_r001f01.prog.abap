*&---------------------------------------------------------------------*
*&  Include           ZWM_R001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_vorga          LIKE LINE OF gr_vorga.

  gv_process  = 'UNAME'.

  CLEAR ls_vorga.
  ls_vorga-low    = 'ST'.
  ls_vorga-sign   = 'E'.
  ls_vorga-option = 'EQ'.
  APPEND ls_vorga TO gr_vorga.
  CLEAR ls_vorga.
  ls_vorga-low    = 'SL'.
  ls_vorga-sign   = 'E'.
  ls_vorga-option = 'EQ'.
  APPEND ls_vorga TO gr_vorga.
  CLEAR ls_vorga.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_define_mvt USING : '601' 'I' 'EQ'.
    WHEN radio2.
      PERFORM f_define_mvt USING : '101' 'I' 'EQ'.
    WHEN radio3.
      PERFORM f_define_mvt USING : '601' 'E' 'EQ',
                                   '101' 'E' 'EQ',
                                   '7*' 'E' 'CP'.
  ENDCASE.

  SELECT SINGLE werks
    FROM t320
    INTO gv_werks
    WHERE lgnum = pa_lgnum.

  SELECT SINGLE bukrs
    FROM t001k
    INTO gv_bukrs
    WHERE bwkey = gv_werks.

  IF so_datum-high IS NOT INITIAL.
    gv_interval = ( so_datum-high - so_datum-low ) + 1.
  ELSE.
    gv_interval = 1.
  ENDIF.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      factory_calendar           = 'T1'
      date_from                  = so_datum-low
      date_to                    = so_datum-high
    TABLES
      holidays                   = holidays
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.

  SELECT *
    FROM a511
    INTO CORRESPONDING FIELDS OF TABLE gt_a511
    WHERE kappl = 'V'
      AND kschl = 'ZDLV'
      AND vkorg = gv_bukrs
      AND datbi >= sy-datum
      AND datab <= sy-datum.

  SORT gt_a511 BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM gt_a511 COMPARING kdgrp.

  SELECT *
    FROM t151t
    INTO CORRESPONDING FIELDS OF TABLE gt_t151t
    WHERE spras = sy-langu.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'STK' '0' '' '' '' '',
                                      'PVS' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'STK' '0' '' '' '' '',
                                      'PVS' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'STK' '0' '' '' '' '',
                                      'PVS' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'STA' '0' '' '' '' '',
                                      'PVS' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'PVS' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'STA' '0' '' '' '' '',
                                      'STK' '0' '' '' '' '',
                                      'SUN' '0' '' '' '' '',
                                      'PLG' '' '' '' '' '1',
                                      'PVS' '' '' '' '' '1',
                                      'SDA' '' '' '' '' '1'.
    WHEN radio7.
      PERFORM f_modify_screen USING : 'STA' '0' '' '' '' '',
                                      'SVB' '0' '' '' '' '',
                                      'STK' '' '' '' '' '',
                                      'SUN' '0' '' '' '' '',
                                      'PLG' '' '' '' '' '1',
                                      'PVS' '' '' '' '' '1',
                                      'SDA' '' '' '' '' '1'.
  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  IF pa_lgnum IS INITIAL.
    PERFORM f_error_message USING 'PLG' ''.
  ENDIF.

  IF so_datum-low IS INITIAL.
    PERFORM f_error_message USING 'SDA' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION-SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length fu_required.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
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
*&      Form  F_GET_DATA_DELIVERY
*&---------------------------------------------------------------------*
FORM f_get_data_delivery .
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap,
         ls_ltak LIKE LINE OF gt_ltak,
         ls_likp LIKE LINE OF gt_likp,
         ls_mara LIKE LINE OF gt_mara,
         lt_003  TYPE STANDARD TABLE OF zwmdt003,
         ls_003  LIKE LINE OF lt_003,
         lt_004  TYPE STANDARD TABLE OF zwmdt004,
         ls_004  LIKE LINE OF lt_004,
         lt_likp TYPE STANDARD TABLE OF likp.

  CASE 'X'.
    WHEN radio1.
*      lt_ltap[] = gt_ltap[].
*      SORT lt_ltap BY vbeln.
*      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING vbeln.
      IF gt_ltap[] IS NOT INITIAL.
        SELECT *
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN gt_ltap
          WHERE vbeln = gt_ltap-vbeln.
      ENDIF.

      IF gt_ltap[] IS NOT INITIAL.
        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN gt_ltap
          WHERE vbeln = gt_ltap-vbeln.
*            AND posnr = gt_ltap-posnr.
      ENDIF.

    WHEN radio2.
      lt_ltap[] = gt_ltap[].
      SORT lt_ltap BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr.
      IF lt_ltap[] IS NOT INITIAL.
        SELECT *
          FROM mara
          INTO CORRESPONDING FIELDS OF TABLE gt_mara
          FOR ALL ENTRIES IN lt_ltap
         WHERE matnr = lt_ltap-matnr.
      ENDIF.

      IF pa_lgnum = 'C40'.
        SELECT * INTO TABLE @DATA(lt_likp2) FROM likp
          FOR ALL ENTRIES IN @lt_ltap
          WHERE vbeln = @lt_ltap-vlpla.
      ENDIF.

      LOOP AT gt_ltap INTO ls_ltap.
        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_ltap-matnr.
        ls_likp-vbeln   = ls_ltap-vlpla.
        ls_likp-volum   = ls_mara-volum.
        ls_likp-voleh   = ls_mara-voleh.
        ls_likp-btgew   = ls_ltap-brgew.
        ls_likp-gewei   = ls_ltap-gewei.
        READ TABLE lt_likp2 INTO DATA(ls_likp2) WITH KEY vbeln = ls_ltap-vlpla.
        IF sy-subrc = 0.
          ls_likp-erdat = ls_likp2-erdat.
        ENDIF.
        APPEND ls_likp TO gt_likp.
        CLEAR ls_likp.
      ENDLOOP.

    WHEN radio3.
      lt_ltap[] = gt_ltap[].
      SORT lt_ltap BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr.
      IF lt_ltap[] IS NOT INITIAL.
        SELECT *
          FROM mara
          INTO CORRESPONDING FIELDS OF TABLE gt_mara
          FOR ALL ENTRIES IN lt_ltap
         WHERE matnr = lt_ltap-matnr.
      ENDIF.

      LOOP AT gt_ltap INTO ls_ltap.
        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_ltap-matnr.
        ls_likp-vbeln   = ls_ltap-vlpla.
        ls_likp-volum   = ls_mara-volum.
        ls_likp-voleh   = ls_mara-voleh.
        ls_likp-btgew   = ls_ltap-brgew.
        ls_likp-gewei   = ls_ltap-gewei.
        APPEND ls_likp TO gt_likp.
        CLEAR ls_likp.
      ENDLOOP.

    WHEN radio4.
      lt_003[] = gt_003[].
      SORT lt_003 BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING vbeln.
      IF lt_003[] IS NOT INITIAL.
        SELECT *
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN lt_003
          WHERE vbeln = lt_003-vbeln
            AND lgnum = pa_lgnum.

        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN lt_003
          WHERE vbeln = lt_003-vbeln.

        LOOP AT gt_003 INTO ls_003.
          READ TABLE gt_likp INTO ls_likp
                             WITH KEY vbeln = ls_003-vbeln.
          IF sy-subrc <> 0.
            DELETE TABLE gt_003 FROM ls_003.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN radio5.
      lt_004[] = gt_004[].
      SORT lt_004 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING matnr.
      IF lt_004[] IS NOT INITIAL.
        SELECT *
          FROM mara
          INTO CORRESPONDING FIELDS OF TABLE gt_mara
          FOR ALL ENTRIES IN lt_004
         WHERE matnr = lt_004-matnr.
      ENDIF.

      LOOP AT gt_004 INTO ls_004.
        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_004-matnr.
        ls_likp-vbeln   = ls_004-vbeln.
        ls_likp-volum   = ls_mara-volum.
        ls_likp-voleh   = ls_mara-voleh.
        ls_likp-btgew   = ls_mara-brgew.
        ls_likp-gewei   = ls_mara-gewei.
        APPEND ls_likp TO gt_likp.
        CLEAR ls_likp.
      ENDLOOP.

      lt_likp[] = gt_likp[].
      SORT lt_likp BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING vbeln.
      IF lt_likp[] IS NOT INITIAL.
        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN lt_likp
          WHERE vbeln = lt_likp-vbeln.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_TO
*&---------------------------------------------------------------------*
FORM f_process_to .
  DATA : lv_datum     TYPE sy-datum.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_calculate_picking.
    WHEN radio2.
      PERFORM f_calculate_putaway.
    WHEN radio3.
      PERFORM f_calculate_transfer.
    WHEN radio5.
      PERFORM f_calculate_chkin.
  ENDCASE.

  CLEAR : lv_datum.
  PERFORM f_display_modify USING 'UNAME' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_PROCESS_TO

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

  IF g_docking IS INITIAL.
    CREATE OBJECT g_docking
      EXPORTING
        repid     = gv_repid
        dynnr     = gv_dynnr
        side      = g_docking->dock_at_left
        extension = 280.
  ENDIF.

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
        rows    = 2
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_title.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_contain01.

    CALL METHOD g_splitter->set_row_height
      EXPORTING
        id     = 1
        height = 10.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode  TYPE TABLE OF sy-ucomm,
         dynlog TYPE smp_dyntxt.

  CREATE OBJECT event_receiver.
  gs_variant-report = gv_repid.
  gv_dynnr          = sy-dynnr.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'PICKING'.
      ENDIF.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&STATUSDO' TO fcode.
      APPEND '&MONIPICK' TO fcode.
    WHEN radio2.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'PUTAWAY'.
      ENDIF.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&STATUSDO' TO fcode.
      APPEND '&MONIPICK' TO fcode.
    WHEN radio3.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'TRANSFER'.
      ENDIF.
      APPEND '&USERDN' TO fcode.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&USERIT' TO fcode.
      APPEND '&STATUSDO' TO fcode.
      APPEND '&MONIPICK' TO fcode.

    WHEN radio4.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'CHKOUT'.
      ENDIF.
      APPEND '&USERTO' TO fcode.
      APPEND '&STATUSDO' TO fcode.
      APPEND '&MONIPICK' TO fcode.
    WHEN radio5.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'CHKIN'.
      ENDIF.
      APPEND '&MONIPICK' TO fcode.
*      APPEND '&SHIPMENT' TO fcode.
    WHEN radio6.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'STDO'.
      ENDIF.
      APPEND '&USERDN' TO fcode.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&USERIT' TO fcode.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&USERTO' TO fcode.
      APPEND '&USERTM' TO fcode.
      APPEND '&MONIPICK' TO fcode.
    WHEN radio7.
      IF gv_process IS INITIAL.
        SET TITLEBAR 'TITLE1'.
      ELSE.
        SET TITLEBAR 'STDO'.
      ENDIF.
      APPEND '&USERDN' TO fcode.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&USERIT' TO fcode.
      APPEND '&SHIPMENT' TO fcode.
      APPEND '&USERTO' TO fcode.
      APPEND '&USERTM' TO fcode.
      APPEND '&STATUSDO' TO fcode.
  ENDCASE.

  APPEND '&TO' TO fcode.
  APPEND '&DN' TO fcode.
  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
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
FORM   f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&MONIPICK'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'MONITOR_PICKING'.
        PERFORM f_clear_alv USING ''.
        PERFORM f_process_monitor_picking.
      ENDIF.
    WHEN 'STATUS_DO'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'STATUS_DO'.
        PERFORM f_clear_alv USING ''.
        PERFORM f_display_to USING gv_uname 'X'.
      ENDIF.
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
        PERFORM f_post_data.
      ENDIF.

    WHEN '&TO'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'TO'.
        PERFORM f_clear_alv USING ''.
        PERFORM f_display_to USING gv_uname 'X'.
      ENDIF.

    WHEN '&DN'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'DN'.
        PERFORM f_clear_alv USING ''.
        PERFORM f_display_dn USING '' 'X'.
      ENDIF.

    WHEN '&SHIPMENT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CASE 'X'.
          WHEN radio4.
            gv_process  = 'UNAME'.
          WHEN radio5.
            gv_process  = 'USERSHIP'.
          WHEN OTHERS.
        ENDCASE.
        PERFORM f_clear_alv USING 'UNAME'.
        PERFORM f_process_shipment.
      ENDIF.

    WHEN '&USERTO'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'USERTO'.
        CLEAR : gv_uname.
        PERFORM f_clear_alv USING 'UNAME'.
        PERFORM f_process_to.
      ENDIF.

    WHEN '&USERDN'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'USERDN'.
        CLEAR : gv_uname.
        PERFORM f_clear_alv USING 'UNAME'.
        PERFORM f_process_dn.
      ENDIF.

    WHEN '&USERTM'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'USERTM'.
        CLEAR : gv_uname.
        PERFORM f_clear_alv USING 'USERTM'.
        PERFORM f_process_times.
      ENDIF.

    WHEN '&USERIT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        gv_process  = 'USERIT'.
        CLEAR : gv_uname.
        PERFORM f_clear_alv USING 'UNAME'.
        PERFORM f_process_items.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR gv_process.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  CREATE OBJECT g_tabgrid
    EXPORTING
      i_appl_events = selected
      i_parent      = g_contain01.

  PERFORM f_build_layout.
  PERFORM f_build_sort.

  SET HANDLER event_receiver->handle_double_click
              event_receiver->handle_toolbar
              event_receiver->handle_menu_button
              event_receiver->handle_user_command
              event_receiver->handle_top_of_page FOR g_tabgrid.


  IF radio6 IS NOT INITIAL.
    gv_process = 'STATUS_DO'.
  ELSEIF radio7 IS NOT INITIAL.
    gv_process = 'MONITOR_PICKING'.
  ENDIF.

  CASE gv_process.
    WHEN 'UNAME' OR 'USERTO' OR 'USERDN' OR 'USERSHIP' OR 'USERIT'.
      ASSIGN <fs_uname> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'UNAME'.
    WHEN 'KTEXT'.
      ASSIGN <fs_ktext> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'KTEXT'.
    WHEN 'USERTM'.
      ASSIGN <fs_time> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'USERTM'.
    WHEN 'TO'.
      ASSIGN <fs_to> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'TO'.
    WHEN 'DN'.
      ASSIGN <fs_dn> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'DN'.
    WHEN 'SHIPMENT'.
      ASSIGN <fs_ship> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'SHIPMENT'.
    WHEN 'STATUS_DO'.
      ASSIGN <fs_sdo2> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'STATUS_DO'.
    WHEN 'MONITOR_PICKING'.
      ASSIGN <fs_mp2> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'MONITOR_PICKING'.
    WHEN 'DETL'.
      ASSIGN <fs_detl> TO <fs_out>.
      PERFORM f_change_fieldcat USING 'DETL'.
  ENDCASE.

  CALL METHOD g_tabgrid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_alv
      i_save               = 'A'
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gs_exclude
    CHANGING
      it_sort              = gt_main_sort[]
      it_outtab            = <fs_out>[]
      it_fieldcatalog      = gt_main_fieldcat[].

  CALL METHOD g_dyndoc_id->initialize_document.

  CALL METHOD g_tabgrid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = g_dyndoc_id.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-box_fname           = 'MARK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
*  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'XYZSTYLEZYX'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
*  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort[].

  CASE gv_process.
    WHEN 'TO'.
      PERFORM f_alv_sort USING : 2 'DATUM' 'X' '' ''.
    WHEN 'DN'.
      PERFORM f_alv_sort USING : 2 'ERDAT' 'X' '' ''.
      PERFORM f_alv_sort USING : 3 'VBELN' 'X' '' ''.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table TABLES   ft_fcat TYPE lvc_t_fcat
                     USING    fu_fieldname fu_color.
  DATA : lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         ls_lvc_cat   TYPE lvc_s_fcat,
         lt_fcat      TYPE lvc_t_fcat.

  IF ft_fcat[] IS NOT INITIAL.
    lt_fcat[] = ft_fcat[].

    IF fu_color IS NOT INITIAL.
      CLEAR ls_lvc_cat.
      ls_lvc_cat-fieldname = 'COLOR'.
      ls_lvc_cat-ref_table = 'CALENDAR_TYPE'.
      ls_lvc_cat-ref_field = 'COLTAB'.
      APPEND ls_lvc_cat TO lt_fcat.
      CLEAR ls_lvc_cat.
    ENDIF.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = lt_fcat
        i_length_in_byte          = 'X'
        i_style_table             = 'X'
      IMPORTING
        ep_table                  = lt_dyn_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.
    IF sy-subrc EQ 0.
      CASE fu_fieldname.
        WHEN 'TREE'.
          ASSIGN lt_dyn_table->* TO <fs_tree>.
          CREATE DATA ls_line LIKE LINE OF <fs_tree>.
          ASSIGN ls_line->* TO <fs_ltree>.
        WHEN 'UNAME'.
          ASSIGN lt_dyn_table->* TO <fs_utab>.
          CREATE DATA ls_line LIKE LINE OF <fs_utab>.
          ASSIGN ls_line->* TO <fs_lutab>.
        WHEN 'UNAME_C'.
          ASSIGN lt_dyn_table->* TO <fs_uname>.
          CREATE DATA ls_line LIKE LINE OF <fs_uname>.
          ASSIGN ls_line->* TO <fs_luname>.
        WHEN 'KTEXT'.
          ASSIGN lt_dyn_table->* TO <fs_ktab>.
          CREATE DATA ls_line LIKE LINE OF <fs_ktab>.
          ASSIGN ls_line->* TO <fs_lktab>.
        WHEN 'KTEXT_C'.
          ASSIGN lt_dyn_table->* TO <fs_ktext>.
          CREATE DATA ls_line LIKE LINE OF <fs_ktext>.
          ASSIGN ls_line->* TO <fs_lktext>.
        WHEN 'TIME'.
          ASSIGN lt_dyn_table->* TO <fs_ttab>.
          CREATE DATA ls_line LIKE LINE OF <fs_ttab>.
          ASSIGN ls_line->* TO <fs_lttab>.
        WHEN 'TIME_C'.
          ASSIGN lt_dyn_table->* TO <fs_time>.
          CREATE DATA ls_line LIKE LINE OF <fs_time>.
          ASSIGN ls_line->* TO <fs_ltime>.
        WHEN 'TO'.
          ASSIGN lt_dyn_table->* TO <fs_to>.
          CREATE DATA ls_line LIKE LINE OF <fs_to>.
          ASSIGN ls_line->* TO <fs_lto>.
        WHEN 'DN'.
          ASSIGN lt_dyn_table->* TO <fs_dn>.
          CREATE DATA ls_line LIKE LINE OF <fs_dn>.
          ASSIGN ls_line->* TO <fs_ldn>.
        WHEN 'SHIPMENT'.
          ASSIGN lt_dyn_table->* TO <fs_ship>.
          CREATE DATA ls_line LIKE LINE OF <fs_ship>.
          ASSIGN ls_line->* TO <fs_lship>.
        WHEN 'STATUS_DO'.
          ASSIGN lt_dyn_table->* TO <fs_sdo>.
          CREATE DATA ls_line LIKE LINE OF <fs_sdo>.
          ASSIGN ls_line->* TO <fs_lsdo>.
        WHEN 'STATUS_DO_C'.
          ASSIGN lt_dyn_table->* TO <fs_sdo2>.
          CREATE DATA ls_line LIKE LINE OF <fs_sdo2>.
          ASSIGN ls_line->* TO <fs_lsdo2>.
        WHEN 'MONITOR_PICKING'.
          ASSIGN lt_dyn_table->* TO <fs_mp>.
          CREATE DATA ls_line LIKE LINE OF <fs_mp>.
          ASSIGN ls_line->* TO <fs_lmp>.
        WHEN 'MONITOR_PICKING_C'.
          ASSIGN lt_dyn_table->* TO <fs_mp2>.
          CREATE DATA ls_line LIKE LINE OF <fs_mp2>.
          ASSIGN ls_line->* TO <fs_lmp2>.
        WHEN 'DETL'.
          ASSIGN lt_dyn_table->* TO <fs_detl>.
          CREATE DATA ls_line LIKE LINE OF <fs_detl>.
          ASSIGN ls_line->* TO <fs_ldetl>.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_FCAT
*&---------------------------------------------------------------------*
FORM f_dyn_fcat  USING    fu_container fu_fieldname fu_tabname
                          fu_currency fu_cfieldname fu_quantity
                          fu_qfieldname fu_checkbox fu_ref_field
                          fu_ref_table fu_coltext fu_outputlen
                          fu_inttype fu_no_out fu_edit fu_tech
                          fu_just fu_key fu_fix fu_icon fu_sum
                          fu_nosum fu_decimals.
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
  ls_dyn_fcat-decimals    = fu_decimals.
  CASE fu_container.
    WHEN 'TREE'.
      APPEND ls_dyn_fcat TO gt_tree_fieldcat.
    WHEN 'TO'.
      APPEND ls_dyn_fcat TO gt_tofcat.
    WHEN 'DN'.
      APPEND ls_dyn_fcat TO gt_dnfcat.
    WHEN 'SHIPMENT'.
      APPEND ls_dyn_fcat TO gt_shfcat.
    WHEN 'UNAME'.
      APPEND ls_dyn_fcat TO gt_usfcat.
      APPEND ls_dyn_fcat TO gt_uslvcc.
    WHEN 'KTEXT'.
      APPEND ls_dyn_fcat TO gt_nmfcat.
      APPEND ls_dyn_fcat TO gt_nmlvcc.
    WHEN 'TIME'.
      APPEND ls_dyn_fcat TO gt_tmfcat.
      APPEND ls_dyn_fcat TO gt_tmlvcc.
    WHEN 'STATUS_DO'.
      APPEND ls_dyn_fcat TO gt_sdfcat.
    WHEN 'MONITOR_PICKING'.
      APPEND ls_dyn_fcat TO gt_mpfcat.
    WHEN 'DETL'.
      APPEND ls_dyn_fcat TO gt_dfcat.
  ENDCASE.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_FCAT

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
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data .

ENDFORM.                    " F_POST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER
*&---------------------------------------------------------------------*
FORM f_build_header  CHANGING fc_header   TYPE treev_hhdr.
  fc_header-heading   = 'Warehouse'.
  fc_header-width     = 25.
  fc_header-width_pix = ''.
ENDFORM.                    " F_BUILD_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_TREE_ALV
*&---------------------------------------------------------------------*
FORM f_tree_alv .
  CREATE OBJECT g_tree
    EXPORTING
      parent                      = g_docking
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = 'X'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.

  CALL METHOD g_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header  = g_header
      i_save               = 'A'
      is_variant           = gs_variant
      it_toolbar_excluding = gs_exclude
    CHANGING
      it_outtab            = <fs_tree>[]
      it_fieldcatalog      = gt_tree_fieldcat.
ENDFORM.                    " F_TREE_ALV

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_EVENT
*&---------------------------------------------------------------------*
FORM f_register_event .
  DATA : lt_events TYPE cntl_simple_events,
         ls_event  TYPE cntl_simple_event.

  CALL METHOD g_tree->get_registered_events
    IMPORTING
      events = lt_events.

  ls_event-eventid    = cl_gui_column_tree=>eventid_item_double_click.
  ls_event-appl_event = 'X'.
  APPEND ls_event TO lt_events.

  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.

  SET HANDLER event_receiver->handle_item_double_click FOR g_tree.

ENDFORM.                    " F_REGISTER_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_create_hierarchy .
  TYPES : BEGIN OF ty_user,
            uname TYPE sy-uname,
          END OF ty_user.

  DATA : ls_ltap      LIKE LINE OF gt_ltap,
         ls_003       LIKE LINE OF gt_003,
         ls_004       LIKE LINE OF gt_004,
         lt_user      TYPE STANDARD TABLE OF ty_user,
         ls_user      LIKE LINE OF lt_user,
         ls_tree      LIKE LINE OF gt_tree,
         lv_key1      TYPE lvc_nkey,
         lv_key2      TYPE lvc_nkey,
         lv_key3      TYPE lvc_nkey,
         lv_key4      TYPE lvc_nkey,
         lv_node      TYPE lvc_value,
         lv_text(100),
         lv_leaf.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_ltap INTO ls_ltap.
        ls_user-uname   = ls_ltap-ename.
        APPEND ls_user TO lt_user.
        CLEAR ls_user.
      ENDLOOP.
    WHEN radio2.
      LOOP AT gt_ltap INTO ls_ltap.
        ls_user-uname   = ls_ltap-qname.
        APPEND ls_user TO lt_user.
        CLEAR ls_user.
      ENDLOOP.
    WHEN radio3.
      LOOP AT gt_ltap INTO ls_ltap.
        ls_user-uname   = ls_ltap-qname.
        APPEND ls_user TO lt_user.
        CLEAR ls_user.
      ENDLOOP.
    WHEN radio4.
      LOOP AT gt_003 INTO ls_003.
        ls_user-uname   = ls_003-ernam.
        APPEND ls_user TO lt_user.
        CLEAR ls_user.
      ENDLOOP.
    WHEN radio5.
      LOOP AT gt_004 INTO ls_004.
        ls_user-uname   = ls_004-znmuld.
        APPEND ls_user TO lt_user.
        CLEAR ls_user.
      ENDLOOP.
  ENDCASE.

  SORT lt_user BY uname.
  DELETE ADJACENT DUPLICATES FROM lt_user COMPARING uname.

  CLEAR : lv_node, ls_tree.
  lv_node = pa_lgnum.
  PERFORM f_add_node_main USING    <fs_ltree> '' lv_node ''
                          CHANGING lv_key1.

  LOOP AT lt_user INTO ls_user.
    CLEAR : lv_node, ls_tree.
    lv_node = ls_user-uname.
    PERFORM f_add_node_main USING    <fs_ltree> lv_key1 lv_node 'X'
                            CHANGING lv_key2.

    PERFORM f_add_node_main USING    <fs_ltree> lv_key2 'DNs' 'Z'
                            CHANGING lv_key3.

    CASE 'X'.
      WHEN radio4.
        PERFORM f_add_node_main USING    <fs_ltree> lv_key2 'Shipments' 'W'
                                CHANGING lv_key3.
      WHEN radio5.
        PERFORM f_add_node_main USING    <fs_ltree> lv_key2 'TOs' 'Y'
                                CHANGING lv_key3.
        PERFORM f_add_node_main USING    <fs_ltree> lv_key2 'Shipments' 'W'
                                CHANGING lv_key3.
      WHEN OTHERS.
        PERFORM f_add_node_main USING    <fs_ltree> lv_key2 'TOs' 'Y'
                                CHANGING lv_key3.
    ENDCASE.
  ENDLOOP.

  CALL METHOD g_tree->frontend_update.
ENDFORM.                    " F_CREATE_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_ITEM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_item_double_click  USING    fu_fieldname
                                          fu_node_key.
  DATA : node_text   TYPE lvc_value,
         item_layout TYPE lvc_t_layi,
         node_layout TYPE lvc_s_layn,
         parent      TYPE lvc_nkey.

  DATA : ls_xout  LIKE LINE OF gt_xout,
         ls_out   LIKE LINE OF gt_out,
         lv_uname TYPE ltap-qname,
         ls_ltap  LIKE LINE OF gt_ltap.

  CLEAR : gt_out[].

  CALL METHOD g_tree->get_outtab_line
    EXPORTING
      i_node_key     = fu_node_key
    IMPORTING
      e_node_text    = node_text
      et_item_layout = item_layout
      es_node_layout = node_layout.

  CASE node_text.
    WHEN 'TOs'.
      PERFORM f_get_parent USING    fu_node_key
                           CHANGING node_text.
      gv_uname    = node_text.
      gv_process  = 'TO'.
      PERFORM f_clear_alv USING ''.
      PERFORM f_display_to USING gv_uname ''.

    WHEN 'DNs'.
      PERFORM f_get_parent USING    fu_node_key
                           CHANGING node_text.
      gv_uname    = node_text.
      gv_process  = 'DN'.
      PERFORM f_clear_alv USING ''.
      PERFORM f_display_dn USING gv_uname ''.

    WHEN 'Shipments'.
      PERFORM f_get_parent USING    fu_node_key
                           CHANGING node_text.
      gv_uname    = node_text.
      gv_process  = 'SHIPMENT'.
      PERFORM f_clear_alv USING ''.
      PERFORM f_display_shipment USING gv_uname ''.

    WHEN OTHERS.
      CASE 'X'.
        WHEN radio1.
          CLEAR ls_ltap.
          READ TABLE gt_ltap INTO ls_ltap
                             WITH KEY ename = node_text.
          IF sy-subrc = 0.
            gv_uname    = ls_ltap-ename.
            gv_process  = 'KTEXT'.
            PERFORM f_clear_alv USING 'KTEXT'.
            PERFORM f_picking_kdgrp.
          ENDIF.
        WHEN radio2.
*          CLEAR ls_ltap.
*          READ TABLE gt_ltap INTO ls_ltap
*                             WITH KEY qname = node_text.
*          IF sy-subrc = 0.
*            gv_uname  = ls_ltap-qname.
*            gv_process  = 'KTEXT'.
*            PERFORM f_clear_alv USING 'KTEXT'.
*            PERFORM f_putaway_kdgrp.
*          ENDIF.
        WHEN radio3.
*          CLEAR ls_ltap.
*          READ TABLE gt_ltap INTO ls_ltap
*                             WITH KEY qname = node_text.
*          IF sy-subrc = 0.
*            gv_uname  = ls_ltap-qname.
*            gv_process  = 'KTEXT'.
*            PERFORM f_clear_alv USING 'KTEXT'.
*            PERFORM f_transfer_kdgrp.
*          ENDIF.
        WHEN radio5.
      ENDCASE.
  ENDCASE.

*  CASE 'X'.
*    WHEN radio7.
*      LOOP AT <fs_mp2> INTO <fs_lmp2>.
*
*      ENDLOOP.
*  ENDCASE.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_HANDLE_ITEM_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NODE_MAIN
*&---------------------------------------------------------------------*
FORM f_add_node_main  USING    fu_aux        TYPE any
                               fu_relat_key  TYPE lvc_nkey
                               fu_node       TYPE lvc_value
                               fu_leaf
                     CHANGING  fc_node_key   TYPE lvc_nkey.

  DATA : lv_node_text   TYPE lvc_value,
         lt_item_layout TYPE lvc_t_layi,
         ls_item_layout TYPE lvc_s_layi,
         ls_node_layout TYPE lvc_s_layn.

  IF fu_leaf IS NOT INITIAL.
    CASE fu_leaf.
      WHEN 'W'.
        ls_node_layout-n_image   = icon_transport.
      WHEN 'X'.
        ls_node_layout-n_image   = icon_ws_confirm_whse_proc_back.
      WHEN 'Y'.
        ls_node_layout-n_image   = icon_sym_real_server.
      WHEN 'Z'.
        ls_node_layout-n_image   = icon_sym_log_server.
    ENDCASE.
  ENDIF.

  ls_item_layout-fieldname = g_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO lt_item_layout.
  CLEAR ls_item_layout.

  lv_node_text =  fu_node.

  CALL METHOD g_tree->add_node
    EXPORTING
      i_relat_node_key = fu_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = lv_node_text
      is_outtab_line   = fu_aux
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = fc_node_key.
ENDFORM.                    " F_ADD_NODE_MAIN

*&---------------------------------------------------------------------*
*&      Form  F_COLOR_MODIFY
*&---------------------------------------------------------------------*
FORM f_color_modify  USING    fu_fieldname fu_col fu_int fu_inv
                     CHANGING fc_color.
  DATA : lt_cellcolor TYPE lvc_t_scol,
         ls_cellcolor TYPE lvc_s_scol.

  CLEAR ls_cellcolor.

  ls_cellcolor-fname      = fu_fieldname.
  ls_cellcolor-color-col  = fu_col.
  ls_cellcolor-color-int  = fu_int.
  ls_cellcolor-color-inv  = fu_inv.
  INSERT ls_cellcolor INTO TABLE lt_cellcolor.
  fc_color = lt_cellcolor.
ENDFORM.                    " F_COLOR_MODIFY

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
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  CLEAR gs_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_TREE
*&---------------------------------------------------------------------*
FORM f_clear_tree .
  CALL METHOD g_tree->delete_all_nodes.
ENDFORM.                    " F_CLEAR_TREE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_TO
*&---------------------------------------------------------------------*
FORM f_display_to USING fu_uname fu_all.
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap,
         ls_ltak LIKE LINE OF gt_ltak,
         ls_004  LIKE LINE OF  gt_004.

  CLEAR : <fs_to>[].

  lt_ltap[] = gt_ltap[].
  CASE 'X'.
    WHEN radio1.
      SORT lt_ltap BY ename tanum.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING ename tanum.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE ename <> fu_uname.
      ENDIF.
    WHEN radio2.
      SORT lt_ltap BY qname tanum.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname tanum.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE qname <> fu_uname.
      ENDIF.
    WHEN radio3.
      SORT lt_ltap BY qname tanum.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname tanum.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE qname <> fu_uname.
      ENDIF.
    WHEN radio5.
      IF fu_all IS INITIAL.
        LOOP AT gt_004 INTO ls_004 WHERE znmuld = fu_uname.
          ls_ltap-tanum = ls_004-tanum.
          ls_ltap-edatu = ls_004-zdtsul.
          APPEND ls_ltap TO lt_ltap.
          CLEAR ls_ltap.
        ENDLOOP.
      ENDIF.
  ENDCASE.

  LOOP AT lt_ltap INTO ls_ltap.
    PERFORM f_assign_field USING 'TANUM' <fs_lto> ls_ltap-tanum.
    IF pa_lgnum = 'C40'.
      READ TABLE gt_ltak INTO ls_ltak WITH KEY tanum = ls_ltap-tanum.
      IF sy-subrc = 0.
        PERFORM f_assign_field USING 'LZNUM' <fs_lto> ls_ltak-lznum.
      ENDIF.
    ENDIF.
    CASE 'X'.
      WHEN radio1.
        PERFORM f_assign_field USING 'DATUM' <fs_lto> ls_ltap-edatu.
      WHEN radio2.
        PERFORM f_assign_field USING 'DATUM' <fs_lto> ls_ltap-qdatu.
      WHEN radio3.
        PERFORM f_assign_field USING 'DATUM' <fs_lto> ls_ltap-qdatu.
      WHEN radio5.
        PERFORM f_assign_field USING 'DATUM' <fs_lto> ls_ltap-edatu.
    ENDCASE.
    APPEND <fs_lto> TO <fs_to>.
    CLEAR <fs_lto>.
  ENDLOOP.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_DISPLAY_TO

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV
*&---------------------------------------------------------------------*
FORM f_clear_alv USING fu_fieldname.
  DATA : ls_line       TYPE REF TO data.

  CALL METHOD g_tabgrid->free.

  CASE fu_fieldname.
    WHEN 'KTEXT'.
      CLEAR <fs_ktab>.
      CREATE DATA ls_line LIKE LINE OF <fs_ktab>.
      ASSIGN ls_line->* TO <fs_lktab>.
    WHEN 'UNAME'.
      CLEAR <fs_utab>.
      CREATE DATA ls_line LIKE LINE OF <fs_utab>.
      ASSIGN ls_line->* TO <fs_lutab>.
    WHEN 'USERTM'.
      CLEAR <fs_ttab>.
      CREATE DATA ls_line LIKE LINE OF <fs_ttab>.
      ASSIGN ls_line->* TO <fs_lttab>.
  ENDCASE.

  CLEAR : gt_main_fieldcat[], <fs_out>[], gt_times[].
ENDFORM.                    " F_CLEAR_ALV

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DN
*&---------------------------------------------------------------------*
FORM f_display_dn USING fu_uname fu_all.
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         lt_003  TYPE STANDARD TABLE OF zwmdt003,
         lt_004  TYPE STANDARD TABLE OF zwmdt004.

  CASE 'X'.
    WHEN radio1.
      lt_ltap[]   = gt_ltap[].
      SORT lt_ltap BY ename vbeln.
*      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING ename vbeln.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE ename <> fu_uname.
      ENDIF.
      PERFORM f_dn_fr_ltap TABLES lt_ltap.
    WHEN radio2.
      lt_ltap[]   = gt_ltap[].
      IF pa_lgnum = 'C40'.
        SORT lt_ltap BY qname vlpla.
*        DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname vlpla.
      ELSE.
        SORT lt_ltap BY qname vbeln.
        DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname vbeln.
      ENDIF.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE qname <> fu_uname.
      ENDIF.
      PERFORM f_dn_fr_ltap TABLES lt_ltap.
    WHEN radio3.
      lt_ltap[]   = gt_ltap[].
      SORT lt_ltap BY qname vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname vbeln.
      IF fu_all IS INITIAL.
        DELETE lt_ltap WHERE qname <> fu_uname.
      ENDIF.
      PERFORM f_dn_fr_ltap TABLES lt_ltap.
    WHEN radio4.
      lt_003[]    = gt_003[].
      SORT lt_003 BY ernam vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING ernam vbeln.
      IF fu_all IS INITIAL.
        DELETE lt_003 WHERE ernam <> fu_uname.
      ENDIF.
      PERFORM f_dn_fr_003 TABLES lt_003.
    WHEN radio5.
      lt_004[]    = gt_004[].
      SORT lt_004 BY znmuld vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING znmuld vbeln.
      IF fu_all IS INITIAL.
        DELETE lt_004 WHERE znmuld <> fu_uname.
      ENDIF.
      PERFORM f_dn_fr_004 TABLES lt_004.
  ENDCASE.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_DISPLAY_DN

*&---------------------------------------------------------------------*
*&      Form  F_GET_PARENT
*&---------------------------------------------------------------------*
FORM f_get_parent  USING    fu_node_key
                   CHANGING fc_node_text.
  DATA : parent_node_key  TYPE lvc_nkey.

  CALL METHOD g_tree->get_parent
    EXPORTING
      i_node_key        = fu_node_key
    IMPORTING
      e_parent_node_key = parent_node_key.

  CALL METHOD g_tree->get_outtab_line
    EXPORTING
      i_node_key  = parent_node_key
    IMPORTING
      e_node_text = fc_node_text.
ENDFORM.                    " F_GET_PARENT

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_ALV
*&---------------------------------------------------------------------*
FORM f_header_alv .
  CREATE OBJECT g_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.
ENDFORM.                    " F_HEADER_ALV

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM f_top_of_page  USING    g_dyndoc_id TYPE REF TO cl_dd_document.
  DATA : table        TYPE REF TO cl_dd_table_element,
         dl_text(255) TYPE c,
         col_key      TYPE REF TO cl_dd_area,
         col_info     TYPE REF TO cl_dd_area,
         col_key1     TYPE REF TO cl_dd_area,
         col_info1    TYPE REF TO cl_dd_area,
         lv_uzeit(8).

  CLEAR : dl_text.
  CASE 'X'.
    WHEN radio1.
      IF gv_uname IS NOT INITIAL.
        dl_text = gv_uname.
      ELSE.
        CASE gv_process.
          WHEN 'USERTO' OR 'UNAME'.
            dl_text = 'TO'.
          WHEN 'USERDN'.
            dl_text = 'Delivery'.
          WHEN 'USERTM'.
            dl_text = 'Total Times'.
          WHEN 'USERIT'.
            dl_text = 'Total Items'.
        ENDCASE.
      ENDIF.
    WHEN radio2.
      IF gv_uname IS NOT INITIAL.
        dl_text = gv_uname.
      ELSE.
        CASE gv_process.
          WHEN 'USERTO' OR 'UNAME'.
            dl_text = 'TO'.
          WHEN 'USERDN'.
            dl_text = 'Delivery'.
          WHEN 'USERTM'.
            dl_text = 'Total Times'.
          WHEN 'USERIT'.
            dl_text = 'Total Items'.
        ENDCASE.
      ENDIF.
    WHEN radio3.
      IF gv_uname IS NOT INITIAL.
        dl_text = gv_uname.
      ELSE.
        CASE gv_process.
          WHEN 'USERTO' OR 'UNAME'.
            dl_text = 'TO'.
          WHEN 'USERDN'.
            dl_text = 'Delivery'.
          WHEN 'USERIT'.
            dl_text = 'Total Items'.
        ENDCASE.
      ENDIF.
    WHEN radio4.
      IF gv_uname IS NOT INITIAL.
        dl_text = gv_uname.
      ELSE.
        CASE gv_process.
          WHEN 'USERTO' OR 'UNAME'.
            dl_text = 'Shipment'.
          WHEN 'USERDN'.
            dl_text = 'Delivery'.
          WHEN 'USERTM'.
            dl_text = 'Total Times'.
          WHEN 'USERIT'.
            dl_text = 'Total Items'.
        ENDCASE.
      ENDIF.
    WHEN radio5.
      IF gv_uname IS NOT INITIAL.
        dl_text = gv_uname.
      ELSE.
        CASE gv_process.
          WHEN 'USERTO' OR 'UNAME'.
            dl_text = 'TO'.
          WHEN 'USERDN'.
            dl_text = 'Delivery'.
          WHEN 'USERTM'.
            dl_text = 'Total Times'.
          WHEN 'USERSHIP'.
            dl_text = 'Shipment'.
          WHEN 'USERIT'.
            dl_text = 'Total Items'.
        ENDCASE.
      ENDIF.
    WHEN radio6.
      CASE gv_process.
        WHEN 'STATUS_DO'.
          dl_text = 'Status DO'.

      ENDCASE.

    WHEN radio7.
      CASE gv_process.
        WHEN 'MONITOR_PICKING'.
          dl_text = 'Monitor Picking'.

      ENDCASE.
  ENDCASE.

  IF dl_text IS INITIAL.
    dl_text = 'TO'.
    IF <fs_detl> IS NOT INITIAL.
      dl_text = 'Shipment'.
    ENDIF.
  ENDIF.

  CALL METHOD g_dyndoc_id->add_text
    EXPORTING
      text      = dl_text
      sap_style = cl_dd_area=>heading.
  CALL METHOD g_dyndoc_id->new_line.

  CALL METHOD g_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 4
      with_heading  = ' '
      border        = '0'
    IMPORTING
      table         = table.

  CALL METHOD table->add_column
    IMPORTING
      column = col_key.
  CALL METHOD table->add_column
    IMPORTING
      column = col_info.
  CALL METHOD table->add_column
    IMPORTING
      column = col_key1.
  CALL METHOD table->add_column
    IMPORTING
      column = col_info1.

  dl_text = 'Date'.
  CALL METHOD col_key->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = 'STRONG'.
  CALL METHOD col_key->new_line.

  WRITE sy-datum TO dl_text MM/DD/YYYY.
  WRITE sy-uzeit TO lv_uzeit USING EDIT MASK '__:__:__'.
  CONCATENATE dl_text '-' lv_uzeit INTO dl_text
  SEPARATED BY space.

  CALL METHOD col_info->add_gap
    EXPORTING
      width = 6.
  CALL METHOD col_info->add_text
    EXPORTING
      text = dl_text.
  CALL METHOD col_info->new_line.

  PERFORM f_html.
ENDFORM.                    " F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_TEXT
*&---------------------------------------------------------------------*
FORM f_add_text  USING    fu_text TYPE sdydo_text_element
                          fu_type.
  CASE fu_type.
    WHEN 'H'.
    WHEN OTHERS.
      CALL METHOD g_dyndoc_id->add_text
        EXPORTING
          text         = fu_text
          sap_emphasis = cl_dd_area=>heading.
  ENDCASE.
ENDFORM.                    " F_ADD_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_HTML
*&---------------------------------------------------------------------*
FORM f_html .
  DATA : dl_length        TYPE i,
         dl_background_id TYPE sdydo_key VALUE space.

  IF g_html_cntrl IS INITIAL.
    CREATE OBJECT g_html_cntrl
      EXPORTING
        parent = g_title.
  ENDIF.
  CALL FUNCTION 'REUSE_ALV_GRID_COMMENTARY_SET'
    EXPORTING
      document = g_dyndoc_id
      bottom   = space
    IMPORTING
      length   = dl_length.
  CALL METHOD g_dyndoc_id->merge_document.
  CALL METHOD g_dyndoc_id->set_document_background
    EXPORTING
      picture_id = dl_background_id.
  g_dyndoc_id->html_control = g_html_cntrl.
  CALL METHOD g_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = g_title
    EXCEPTIONS
      html_display_error = 1.
ENDFORM.                    " F_HTML

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DN
*&---------------------------------------------------------------------*
FORM f_process_dn .
  DATA : lv_datum     TYPE sy-datum.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_dn_picking_calc.
    WHEN radio2.
      PERFORM f_dn_putaway_calc.
    WHEN radio3.
      PERFORM f_dn_transfer_calc.
    WHEN radio4.
      PERFORM f_dn_chkout_calc.
    WHEN radio5.
      PERFORM f_dn_chkin_calc.
  ENDCASE.

  PERFORM f_display_modify USING 'UNAME' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_PROCESS_DN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_COLOR
*&---------------------------------------------------------------------*
FORM f_modify_color  USING    fu_fieldname TYPE lvc_fname
                              ut_tabcolor  TYPE table
                              fu_col fu_int fu_inv.

  DATA : ls_tabcolor TYPE lvc_s_scol.

  CLEAR ls_tabcolor.
  ls_tabcolor-fname = fu_fieldname.

  ls_tabcolor-color-col = fu_col.
  ls_tabcolor-color-int = fu_int.
  ls_tabcolor-color-inv = fu_inv.
  INSERT ls_tabcolor INTO TABLE ut_tabcolor.
ENDFORM.                    " F_MODIFY_COLOR

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_TIMES
*&---------------------------------------------------------------------*
FORM f_process_times .
  DATA : lv_datum     TYPE sy-datum.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_times_picking_calc.
    WHEN radio2.
      PERFORM f_times_putaway_calc.
    WHEN radio3.
      PERFORM f_times_transfer_calc.
    WHEN radio4.
      PERFORM f_times_chkout_calc.
    WHEN radio5.
      PERFORM f_times_chkin_calc.
  ENDCASE.

  CLEAR : lv_datum.
  PERFORM f_display_modify USING 'USERTM' 'X'
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_PROCESS_TIMES

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MODIFY
*&---------------------------------------------------------------------*
FORM f_display_modify USING    fu_fieldname fu_time
                      CHANGING fc_datum.
  DATA : lv_value(15),
         lv_xvalue(15),
         lv_int           TYPE p DECIMALS 0,
         lv_xint          TYPE p DECIMALS 0,
         lv_fieldname(30),
         lv_uname         TYPE sy-uname,
         lv_name          TYPE adrp-name_text,
         lv_tot_to        TYPE i,
         lv_tot_car       TYPE i,
         lv_tot_ec        TYPE i,
         lv_ktext         TYPE t151t-ktext,
         lv_datum         TYPE sy-datum,
         ls_holidays      LIKE LINE OF holidays,
         lv_color,
         lv_total         TYPE p DECIMALS 0,
         lv_average       TYPE p DECIMALS 2,
         lv_ctotal(15),
         lv_cavrge(15).

  CASE fu_fieldname.
    WHEN 'UNAME'.
      LOOP AT <fs_utab> ASSIGNING <fs_lutab>.
        CLEAR <fs_luname>.

        ASSIGN COMPONENT fu_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        lv_uname = <fs>.
        ASSIGN COMPONENT fu_fieldname OF STRUCTURE <fs_luname> TO <fs1>.
        <fs1> = lv_uname.

        ASSIGN COMPONENT 'NAME' OF STRUCTURE <fs_lutab> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'NAME' OF STRUCTURE <fs_luname> TO <fs1>.
        <fs1> = lv_name.

        IF pa_lgnum = 'C40' AND ( radio1 IS NOT INITIAL OR radio4 IS NOT INITIAL ).
          ASSIGN COMPONENT 'TOTAL_TO_GROUP' OF STRUCTURE <fs_lutab> TO <fs>.
          lv_tot_to = <fs>.
          ASSIGN COMPONENT 'TOTAL_TO_GROUP' OF STRUCTURE <fs_luname> TO <fs1>.
          <fs1> = lv_tot_to.


          ASSIGN COMPONENT 'TOTAL_CARTON' OF STRUCTURE <fs_lutab> TO <fs>.
          lv_tot_car = <fs>.
          ASSIGN COMPONENT 'TOTAL_CARTON' OF STRUCTURE <fs_luname> TO <fs1>.
          <fs1> = lv_tot_car.

          ASSIGN COMPONENT 'TOTAL_ECER' OF STRUCTURE <fs_lutab> TO <fs>.
          lv_tot_ec = <fs>.
          ASSIGN COMPONENT 'TOTAL_ECER' OF STRUCTURE <fs_luname> TO <fs1>.
          <fs1> = lv_tot_ec.
        ENDIF.

        fc_datum = so_datum-low - 1.
        CLEAR lv_total.
        DO gv_interval TIMES.
          ADD 1 TO fc_datum.
          CONCATENATE 'TO' fc_datum INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
          lv_value = <fs>.

          CONDENSE lv_value NO-GAPS.
          lv_int  = lv_value.

          ADD lv_int TO lv_total.

          IF lv_value <> 0.
            IF lv_int > lv_xint.
              lv_color = '4'.
            ELSEIF lv_int < lv_xint.
              lv_color = '5'.
            ELSE.
            ENDIF.
            lv_xvalue = lv_value.
            lv_xint   = lv_xvalue.
          ENDIF.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_luname> TO <fs1>.
          <fs1> = <fs>.

          CLEAR ls_holidays.
          READ TABLE holidays INTO ls_holidays
                              WITH KEY date = fc_datum.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_luname> TO <fs1>.
            IF sy-subrc = 0.
              PERFORM f_modify_color USING lv_fieldname <fs1> '6' '0' '0'.
            ENDIF.
          ELSE.
            IF lv_value <> 0.
              ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <fs_luname> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_style USING lv_fieldname <fs1>.
              ENDIF.

              ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_luname> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_color USING lv_fieldname <fs1> lv_color '0' '1'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDDO.

        PERFORM f_assign_field USING 'TOTAL' <fs_luname> lv_total.

        TRY .
            lv_average  = lv_total / gv_interval.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        PERFORM f_assign_field USING 'AVERAGE' <fs_luname> lv_average.

        APPEND <fs_luname> TO <fs_uname>.
        CLEAR : fc_datum, lv_xvalue, lv_xint.
      ENDLOOP.

    WHEN 'KTEXT'.
      LOOP AT <fs_ktab> ASSIGNING <fs_lktab>.
        CLEAR <fs_lktext>.

        ASSIGN COMPONENT fu_fieldname OF STRUCTURE <fs_lktab> TO <fs>.
        lv_ktext = <fs>.

        ASSIGN COMPONENT fu_fieldname OF STRUCTURE <fs_lktext> TO <fs1>.
        <fs1> = lv_ktext.

        fc_datum = so_datum-low - 1.
        CLEAR lv_total.
        DO gv_interval TIMES.
          ADD 1 TO fc_datum.
          CONCATENATE 'TO' fc_datum INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lktab> TO <fs>.
          lv_value = <fs>.
          CONDENSE lv_value NO-GAPS.
          lv_int  = lv_value.

          ADD lv_int TO lv_total.

          IF lv_value <> 0.
            IF lv_int > lv_xint.
              lv_color = '5'.
            ELSEIF lv_int < lv_xint.
              lv_color = '6'.
            ELSE.
            ENDIF.
            lv_xvalue = lv_value.
            lv_xint   = lv_xvalue.
          ENDIF.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lktext> TO <fs1>.
          <fs1> = <fs>.

          CLEAR ls_holidays.
          READ TABLE holidays INTO ls_holidays
                              WITH KEY date = fc_datum.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_lktext> TO <fs1>.
            IF sy-subrc = 0.
              PERFORM f_modify_color USING lv_fieldname <fs1> '6' '0' '0'.
            ENDIF.
          ELSE.
            IF lv_value <> 0.
              ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <fs_lktext> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_style USING lv_fieldname <fs1>.
              ENDIF.

              ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_lktext> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_color USING lv_fieldname <fs1> lv_color '0' '1'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDDO.

        PERFORM f_assign_field USING 'TOTAL' <fs_lktext> lv_total.

        TRY .
            lv_average  = lv_total / gv_interval.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        PERFORM f_assign_field USING 'AVERAGE' <fs_lktext> lv_average.

        APPEND <fs_lktext> TO <fs_ktext>.
        CLEAR : fc_datum, lv_xvalue, lv_xint.
      ENDLOOP.

    WHEN 'USERTM'.
      LOOP AT <fs_ttab> ASSIGNING <fs_lttab>.
        CLEAR <fs_ltime>.

        ASSIGN COMPONENT 'UNAME' OF STRUCTURE <fs_lttab> TO <fs>.
        lv_uname = <fs>.
        ASSIGN COMPONENT 'UNAME' OF STRUCTURE <fs_ltime> TO <fs1>.
        <fs1> = lv_uname.

        ASSIGN COMPONENT 'NAME' OF STRUCTURE <fs_lttab> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'NAME' OF STRUCTURE <fs_ltime> TO <fs1>.
        <fs1> = lv_name.

        fc_datum = so_datum-low - 1.
        CLEAR lv_total.
        DO gv_interval TIMES.
          ADD 1 TO fc_datum.
          CONCATENATE 'TO' fc_datum INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
          lv_value = <fs>.

          IF fu_time IS NOT INITIAL.
            PERFORM f_second_conversion USING lv_value lv_fieldname
                                        CHANGING lv_value.
          ENDIF.

          CONDENSE lv_value NO-GAPS.
          lv_int  = lv_value.

          ADD lv_int TO lv_total.

          IF lv_value <> 0.
            IF lv_int > lv_xint.
              lv_color = '4'.
            ELSEIF lv_int < lv_xint.
              lv_color = '5'.
            ELSE.
            ENDIF.
            lv_xvalue = lv_value.
            lv_xint   = lv_xvalue.
          ENDIF.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ltime> TO <fs1>.
          <fs1> = <fs>.

          CLEAR ls_holidays.
          READ TABLE holidays INTO ls_holidays
                              WITH KEY date = fc_datum.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_ltime> TO <fs1>.
            IF sy-subrc = 0.
              PERFORM f_modify_color USING lv_fieldname <fs1> '6' '0' '0'.
            ENDIF.
          ELSE.
            IF lv_value <> 0.
              ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <fs_ltime> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_style USING lv_fieldname <fs1>.
              ENDIF.

              ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_ltime> TO <fs1>.
              IF sy-subrc = 0.
                PERFORM f_modify_color USING lv_fieldname <fs1> lv_color '0' '1'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDDO.

        PERFORM f_second_conversion USING lv_total ''
                                    CHANGING lv_ctotal.

        PERFORM f_assign_field USING 'TOTAL' <fs_ltime> lv_ctotal.

        TRY .
            lv_average  = lv_total / gv_interval.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        PERFORM f_second_conversion USING lv_average ''
                                    CHANGING lv_cavrge.

        PERFORM f_assign_field USING 'AVERAGE' <fs_ltime> lv_cavrge.

        APPEND <fs_ltime> TO <fs_time>.
        CLEAR : fc_datum, lv_xvalue, lv_xint.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TIMES_1
*&---------------------------------------------------------------------*
FORM f_calc_times_1  TABLES   ft_yltap STRUCTURE ltap
                     USING    fu_uname fu_datum
                     CHANGING fc_totalsec.

  DATA : ls_yltap TYPE ltap,
         ls_ltap  TYPE ltap,
         ls_ltak  TYPE ltak.

  DATA : lt_econf TYPE STANDARD TABLE OF ty_econf,
         ls_econf LIKE LINE OF lt_econf,
         ls_times LIKE LINE OF gt_times.

  DATA : lv_second   TYPE i,
         lv_totalsec TYPE i,
         lv_lines    TYPE i.

  DATA : lv_timestamp1 TYPE ccupeaka-timestamp,
         lv_timestamp2 TYPE ccupeaka-timestamp,
         lv_different  TYPE i.

  DATA : lv_t1 TYPE sy-uzeit,
         lv_t2 TYPE sy-uzeit,
         lv_d1 TYPE sy-datum,
         lv_d2 TYPE sy-datum.

  LOOP AT ft_yltap INTO ls_yltap WHERE ename = fu_uname
                                   AND edatu = fu_datum.
    CLEAR : lt_econf[].
    LOOP AT gt_ltap INTO ls_ltap WHERE ename = ls_yltap-ename
                                   AND tanum = ls_yltap-tanum.
      IF ls_ltap-edatu IS NOT INITIAL.
        ls_econf-edatu  = ls_ltap-edatu.
        ls_econf-ezeit  = ls_ltap-ezeit.
        APPEND ls_econf TO lt_econf.
        CLEAR ls_econf.
      ENDIF.
    ENDLOOP.

    CLEAR ls_ltak.
    READ TABLE gt_ltak INTO ls_ltak
                       WITH KEY lgnum = pa_lgnum
                                tanum = ls_yltap-tanum.

    IF lt_econf[] IS NOT INITIAL.
      SORT lt_econf BY edatu ezeit.
      CLEAR : ls_econf, lv_timestamp1, lv_timestamp2, lv_different,
              lv_t1, lv_t2, lv_d1, lv_d2, lv_second.
      READ TABLE lt_econf INTO ls_econf INDEX 1.

      CONCATENATE ls_ltak-stdat ls_ltak-stuzt INTO lv_timestamp1.
      CONCATENATE ls_econf-edatu ls_econf-ezeit INTO lv_timestamp2.

      IF lv_timestamp1 IS NOT INITIAL AND
        lv_timestamp2 IS NOT INITIAL.
        CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
          EXPORTING
            timestamp1 = lv_timestamp1
            timestamp2 = lv_timestamp2
          IMPORTING
            difference = lv_different.
      ELSEIF lv_timestamp1 IS INITIAL.
        lv_different = 0.
      ENDIF.

      IF lv_different < 0.
        lv_t1 = ls_ltak-stuzt.
        lv_d1 = ls_ltak-stdat.
      ELSE.
        lv_t1 = ls_econf-ezeit.
        lv_d1 = ls_econf-edatu.
      ENDIF.

      DESCRIBE TABLE lt_econf LINES lv_lines.
      CLEAR ls_econf.
      READ TABLE lt_econf INTO ls_econf INDEX lv_lines.
      lv_t2 = ls_econf-ezeit.
      lv_d2 = ls_econf-edatu.

      CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
        EXPORTING
          date_1  = lv_d1
          time_1  = lv_t1
          date_2  = lv_d2
          time_2  = lv_t2
        IMPORTING
          seconds = lv_second.
    ELSE.
      CLEAR lv_second.
    ENDIF.

    ADD lv_second TO lv_totalsec.
  ENDLOOP.

  fc_totalsec  = lv_totalsec.
ENDFORM.                    " F_CALC_TIMES_1

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TIMES_2
*&---------------------------------------------------------------------*
FORM f_calc_times_2  TABLES   ft_yltap STRUCTURE ltap
                     USING    fu_uname fu_datum
                     CHANGING fc_totalsec.

  DATA : ls_yltap TYPE ltap,
         ls_ltap  TYPE ltap,
         ls_ltak  TYPE ltak.

  DATA : lt_qconf TYPE STANDARD TABLE OF ty_qconf,
         ls_qconf LIKE LINE OF lt_qconf,
         ls_times LIKE LINE OF gt_times.

  DATA : lv_second   TYPE i,
         lv_totalsec TYPE i,
         lv_lines    TYPE i.

  DATA : lv_timestamp1 TYPE ccupeaka-timestamp,
         lv_timestamp2 TYPE ccupeaka-timestamp,
         lv_different  TYPE i.

  DATA : lv_t1 TYPE sy-uzeit,
         lv_t2 TYPE sy-uzeit,
         lv_d1 TYPE sy-datum,
         lv_d2 TYPE sy-datum.

  LOOP AT ft_yltap INTO ls_yltap WHERE qname = fu_uname
                                   AND qdatu = fu_datum.
    CLEAR : lt_qconf[].
    LOOP AT gt_ltap INTO ls_ltap WHERE qname = ls_yltap-qname
                                   AND tanum = ls_yltap-tanum.
      IF ls_ltap-edatu IS NOT INITIAL.
        ls_qconf-qdatu  = ls_ltap-qdatu.
        ls_qconf-qzeit  = ls_ltap-qzeit.
        APPEND ls_qconf TO lt_qconf.
        CLEAR ls_qconf.
      ENDIF.
    ENDLOOP.

    CLEAR ls_ltak.
    READ TABLE gt_ltak INTO ls_ltak
                       WITH KEY lgnum = pa_lgnum
                                tanum = ls_yltap-tanum.

    IF lt_qconf[] IS NOT INITIAL.
      SORT lt_qconf BY qdatu qzeit.
      CLEAR : ls_qconf, lv_timestamp1, lv_timestamp2, lv_different,
              lv_t1, lv_t2, lv_d1, lv_d2, lv_second.
      READ TABLE lt_qconf INTO ls_qconf INDEX 1.

      CONCATENATE ls_ltak-stdat ls_ltak-stuzt INTO lv_timestamp1.
      CONCATENATE ls_qconf-qdatu ls_qconf-qzeit INTO lv_timestamp2.

      IF lv_timestamp1 IS NOT INITIAL AND
        lv_timestamp2 IS NOT INITIAL.
        CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
          EXPORTING
            timestamp1 = lv_timestamp1
            timestamp2 = lv_timestamp2
          IMPORTING
            difference = lv_different.
      ELSEIF lv_timestamp1 IS INITIAL.
        lv_different = 0.
      ENDIF.

      IF lv_different < 0.
        lv_t1 = ls_ltak-stuzt.
        lv_d1 = ls_ltak-stdat.
      ELSE.
        lv_t1 = ls_qconf-qzeit.
        lv_d1 = ls_qconf-qdatu.
      ENDIF.

      DESCRIBE TABLE lt_qconf LINES lv_lines.
      CLEAR ls_qconf.
      READ TABLE lt_qconf INTO ls_qconf INDEX lv_lines.
      lv_t2 = ls_qconf-qzeit.
      lv_d2 = ls_qconf-qdatu.

      CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
        EXPORTING
          date_1  = lv_d1
          time_1  = lv_t1
          date_2  = lv_d2
          time_2  = lv_t2
        IMPORTING
          seconds = lv_second.
    ELSE.
      CLEAR lv_second.
    ENDIF.

    ADD lv_second TO lv_totalsec.
  ENDLOOP.

  fc_totalsec  = lv_totalsec.
ENDFORM.                    " F_CALC_TIMES_2

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PICKING
*&---------------------------------------------------------------------*
FORM f_get_data_picking .
  DATA : lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         lt_yltap TYPE STANDARD TABLE OF ltap,
         ls_yltap LIKE LINE OF lt_yltap,
         lt_zltap TYPE STANDARD TABLE OF ltap,
         ls_zltap LIKE LINE OF lt_yltap,
         lv_count TYPE i,
         lv_index TYPE i,
         lv_subrc TYPE sy-subrc,
         ls_ltak  LIKE LINE OF gt_ltak,
         ls_ltap  LIKE LINE OF gt_ltap.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE gt_ltap
    WHERE lgnum = pa_lgnum
      AND tanum IN so_tanum
      AND ename IN so_uname
      AND vorga IN gr_vorga
      AND edatu IN so_datum
      AND nltyp = '916'.

  lt_xltap[] = gt_ltap[].
  SORT lt_xltap BY tanum edatu DESCENDING ezeit DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum edatu ename.
  lt_yltap[] = lt_xltap[].
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING tanum.

  IF lt_yltap[] IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FOR ALL ENTRIES IN lt_yltap
      WHERE lgnum = pa_lgnum
        AND tanum = lt_yltap-tanum
        AND bwlvs IN gr_bwlvs
        AND kquit = 'X'.
  ENDIF.

  IF pa_lgnum <> 'C40'.
    LOOP AT lt_yltap INTO ls_yltap.
      CLEAR ls_ltak.
      READ TABLE gt_ltak INTO ls_ltak
                         WITH KEY tanum = ls_yltap-tanum.
      IF sy-subrc <> 0.
        DELETE gt_ltap WHERE tanum = ls_yltap-tanum.
        CONTINUE.
      ENDIF.

      CLEAR : ls_xltap, lv_count, lt_zltap[].
      LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_yltap-tanum.
        APPEND ls_xltap TO lt_zltap.
        ADD 1 TO lv_count.
      ENDLOOP.

      IF lv_count > 1.
        lv_subrc = 4.
        lv_index = 1.
        WHILE lv_subrc IS NOT INITIAL.
          READ TABLE lt_zltap INTO ls_zltap INDEX lv_index.
          IF ls_zltap-ename CP '*PICK*'.
            ls_ltap = ls_zltap.
            CLEAR lv_subrc.
          ELSE.
            IF lv_index = lv_count.
              READ TABLE lt_zltap INTO ls_zltap INDEX 1.
              ls_ltap = ls_zltap.
              CLEAR lv_subrc.
            ELSE.
              ADD 1 TO lv_index.
            ENDIF.
          ENDIF.
        ENDWHILE.
        MODIFY gt_ltap FROM ls_ltap
                       TRANSPORTING edatu ezeit ename
                       WHERE tanum = ls_yltap-tanum.
      ENDIF.
      CLEAR ls_ltap.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_PICKING

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_get_data_putaway .
  DATA : lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         lt_yltap TYPE STANDARD TABLE OF ltap,
         ls_yltap LIKE LINE OF lt_yltap,
         lt_zltap TYPE STANDARD TABLE OF ltap,
         ls_zltap LIKE LINE OF lt_zltap,
         lv_count TYPE i,
         lv_index TYPE i,
         lv_subrc TYPE sy-subrc,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_ltak  LIKE LINE OF gt_ltak.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE gt_ltap
    WHERE lgnum = pa_lgnum
      AND tanum  IN so_tanum
      AND qname IN so_uname
      AND vorga IN gr_vorga
      AND qdatu IN so_datum
      AND vltyp = '902'.

  lt_xltap[] = gt_ltap[].
  SORT lt_xltap BY tanum qdatu DESCENDING qzeit DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum qdatu qname.
  lt_yltap[] = lt_xltap[].
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING tanum.

  IF lt_yltap[] IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FOR ALL ENTRIES IN lt_yltap
      WHERE lgnum = pa_lgnum
        AND tanum = lt_yltap-tanum
        AND bwlvs IN gr_bwlvs
        AND kquit = 'X'.
  ENDIF.

  LOOP AT lt_yltap INTO ls_yltap.
    CLEAR ls_ltak.
    READ TABLE gt_ltak INTO ls_ltak
                       WITH KEY tanum = ls_yltap-tanum.
    IF sy-subrc <> 0.
      DELETE gt_ltap WHERE tanum = ls_yltap-tanum.
      CONTINUE.
    ENDIF.

    CLEAR : ls_xltap, lv_count, lt_zltap[].
    LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_yltap-tanum.
      APPEND ls_xltap TO lt_zltap.
      ADD 1 TO lv_count.
    ENDLOOP.

    IF lv_count > 1.
      lv_subrc = 4.
      lv_index = 1.
      WHILE lv_subrc IS NOT INITIAL.
        READ TABLE lt_zltap INTO ls_zltap INDEX lv_index.
        IF ls_zltap-qname CP '*PUT*'.
          ls_ltap = ls_zltap.
          CLEAR lv_subrc.
        ELSE.
          IF lv_index = lv_count.
            READ TABLE lt_zltap INTO ls_zltap INDEX 1.
            ls_ltap = ls_zltap.
            CLEAR lv_subrc.
          ELSE.
            ADD 1 TO lv_index.
          ENDIF.
        ENDIF.
      ENDWHILE.
      MODIFY gt_ltap FROM ls_ltap
                     TRANSPORTING qdatu qzeit qname
                     WHERE tanum = ls_yltap-tanum.
    ENDIF.
    CLEAR ls_ltap.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_PUTAWAY

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_PICKING
*&---------------------------------------------------------------------*
FORM f_calculate_picking .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lv_fieldname(30).

  TYPES: BEGIN OF ty_mat,
           ename TYPE ltap-ename,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.


  SORT gt_ltap BY ename tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING ename tanum.

  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename tanum.

  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY ename.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING ename.

  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  CLEAR: temp_lznum.
  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-ename.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-ename.

    LOOP AT lt_yltap INTO ls_yltap WHERE ename = ls_xltap-ename.
      CONCATENATE 'TO' ls_yltap-edatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
      IF pa_lgnum = 'C40'.
        READ TABLE lt_ltak INTO DATA(ls_ltak) WITH KEY tanum = ls_yltap-tanum.
        IF sy-subrc = 0.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap DESCENDING BY ename matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm,
            temp_ename TYPE ltap-ename.
      LOOP AT lt_ltap INTO DATA(ls_ltap) WHERE ename = ls_xltap-ename.
        IF temp_matnr = ls_ltap-matnr AND temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          CLEAR: temp_nistm.
*          temp_matnr = ls_ltap-matnr.
**          temp_ename = ls_ltap-ename.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ELSE.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ENDIF.
*        wa_mat-ename = ls_ltap-ename.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.

      SORT it_mat DESCENDING BY ename matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING ename matnr.
      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat WHERE ename = ls_xltap-ename.
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
        IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
          lv_mod    = wa_mat-nistm MOD lv_umrez.
          lv_div    = wa_mat-nistm DIV lv_umrez.
          ADD lv_div TO lv_carton.
          ADD lv_mod TO lv_ecer.
        ENDIF.
      ENDLOOP.

      lv_fieldname = 'TOTAL_CARTON'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_carton.
      lv_fieldname = 'TOTAL_ECER'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_ecer.

    ENDIF.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR: <fs_lutab>.", temp_lznum.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_PICKING

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_calculate_putaway .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum qdatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY qname tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname tanum.

  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
      CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_PUTAWAY

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_TRANSFER
*&---------------------------------------------------------------------*
FORM f_get_data_transfer .
  DATA : lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         lt_yltap TYPE STANDARD TABLE OF ltap,
         ls_yltap LIKE LINE OF lt_yltap,
         lt_zltap TYPE STANDARD TABLE OF ltap,
         ls_zltap LIKE LINE OF lt_yltap,
         lv_count TYPE i,
         lv_index TYPE i,
         lv_subrc TYPE sy-subrc,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_ltak  LIKE LINE OF gt_ltak.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE gt_ltap
    WHERE lgnum = pa_lgnum
      AND tanum IN so_tanum
      AND qname IN so_uname
      AND vorga IN gr_vorga
      AND qdatu IN so_datum.

  lt_xltap[] = gt_ltap[].
  SORT lt_xltap BY tanum qdatu DESCENDING qzeit DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum qdatu qname.
  lt_yltap[] = lt_xltap[].
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING tanum.

  IF lt_yltap[] IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FOR ALL ENTRIES IN lt_yltap
      WHERE lgnum = pa_lgnum
        AND tanum = lt_yltap-tanum
        AND bwlvs IN gr_bwlvs
        AND kquit = 'X'.
  ENDIF.

  LOOP AT lt_yltap INTO ls_yltap.
    CLEAR ls_ltak.
    READ TABLE gt_ltak INTO ls_ltak
                       WITH KEY tanum = ls_yltap-tanum.
    IF sy-subrc <> 0.
      DELETE gt_ltap WHERE tanum = ls_yltap-tanum.
      CONTINUE.
    ENDIF.

    CLEAR : ls_xltap, lv_count, lt_zltap[].
    LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_yltap-tanum.
      APPEND ls_xltap TO lt_zltap.
      ADD 1 TO lv_count.
    ENDLOOP.

    IF lv_count > 1.
      READ TABLE lt_zltap INTO ls_zltap INDEX 1.
      ls_ltap = ls_zltap.
      MODIFY gt_ltap FROM ls_ltap
                     TRANSPORTING qdatu qzeit qname
                     WHERE tanum = ls_yltap-tanum.
    ENDIF.
    CLEAR ls_ltap.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_TRANSFER

*&---------------------------------------------------------------------*
*&      Form  F_DEFINE_MVT
*&---------------------------------------------------------------------*
FORM f_define_mvt  USING    fu_bwlvs fu_sign fu_option.
  DATA : ls_bwlvs          LIKE LINE OF gr_bwlvs.

  CLEAR ls_bwlvs.
  ls_bwlvs-low    = fu_bwlvs.
  ls_bwlvs-sign   = fu_sign.
  ls_bwlvs-option = fu_option.
  APPEND ls_bwlvs TO gr_bwlvs.
ENDFORM.                    " F_DEFINE_MVT

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_TRANSFER
*&---------------------------------------------------------------------*
FORM f_calculate_transfer .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY qname tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname tanum.

  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
      CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_TRANSFER

*&---------------------------------------------------------------------*
*&      Form  F_PICKING_KDGRP
*&---------------------------------------------------------------------*
FORM f_picking_kdgrp .
  DATA : ls_t151t         LIKE LINE OF gt_t151t,
         lt_ltap          TYPE STANDARD TABLE OF ltap,
         ls_ltap          LIKE LINE OF lt_ltap,
         ls_likp          LIKE LINE OF gt_likp,
         lt_custgrp       TYPE STANDARD TABLE OF ty_custgrp,
         ls_custgrp       LIKE LINE OF lt_custgrp,
         lt_tempcg        TYPE STANDARD TABLE OF ty_custgrp,
         ls_tempcg        LIKE LINE OF lt_tempcg,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum.

  lt_ltap[] = gt_ltap[].
  CASE 'X'.
    WHEN radio1.
      DELETE lt_ltap WHERE ename <> gv_uname.
    WHEN radio2.
      DELETE lt_ltap WHERE qname <> gv_uname.
    WHEN radio3.
      DELETE lt_ltap WHERE qname <> gv_uname.
  ENDCASE.

  SORT lt_ltap BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING tanum.
  LOOP AT lt_ltap INTO ls_ltap.
    CLEAR ls_likp.
    READ TABLE gt_likp INTO ls_likp
                       WITH KEY vbeln = ls_ltap-vbeln.
    IF sy-subrc = 0.
      ls_custgrp-lgnum    = ls_ltap-lgnum.
      ls_custgrp-tanum    = ls_ltap-tanum.
      ls_custgrp-edatu    = ls_ltap-edatu.
      ls_custgrp-qdatu    = ls_ltap-qdatu.
      IF ls_likp-kdgrp IS INITIAL.
        ls_custgrp-kdgrp    = 'SB'.
      ELSE.
        ls_custgrp-kdgrp    = ls_likp-kdgrp.
      ENDIF.
      APPEND ls_custgrp TO lt_custgrp.
      CLEAR ls_custgrp.
    ENDIF.
    CLEAR ls_ltap.
  ENDLOOP.

  lt_tempcg[] = lt_custgrp[].
  SORT lt_tempcg BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_tempcg COMPARING kdgrp.

  LOOP AT lt_tempcg INTO ls_tempcg.
    CLEAR ls_t151t.
    READ TABLE gt_t151t INTO ls_t151t
                        WITH KEY kdgrp = ls_tempcg-kdgrp.

    PERFORM f_assign_field USING 'KTEXT' <fs_lktab> ls_t151t-ktext.

    LOOP AT lt_custgrp INTO ls_custgrp WHERE kdgrp = ls_t151t-kdgrp.
      CONCATENATE 'TO' ls_custgrp-edatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lktab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lktab> TO <fs_ktab>.
    CLEAR <fs_lktab>.
  ENDLOOP.

  CLEAR : lv_datum.
  PERFORM f_display_modify USING 'KTEXT' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_PICKING_KDGRP

*&---------------------------------------------------------------------*
*&      Form  F_PUTAWAY_KDGRP
*&---------------------------------------------------------------------*
FORM f_putaway_kdgrp .

ENDFORM.                    " F_PUTAWAY_KDGRP

*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_KDGRP
*&---------------------------------------------------------------------*
FORM f_transfer_kdgrp .

ENDFORM.                    " F_TRANSFER_KDGRP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_STYLE
*&---------------------------------------------------------------------*
FORM f_modify_style  USING    fu_fieldname TYPE lvc_fname
                              ut_tabstyle  TYPE lvc_t_styl.

  CONSTANTS lc_bold TYPE int4 VALUE '00000121'.

  DATA : ls_tabstyle TYPE lvc_s_styl.

  CLEAR ls_tabstyle.
  ls_tabstyle-fieldname = fu_fieldname.

  ls_tabstyle-maxlen = 0.
  ls_tabstyle-style  = '00000121'.
  INSERT ls_tabstyle INTO TABLE ut_tabstyle.
ENDFORM.                    " F_MODIFY_STYLE

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_FIELD
*&---------------------------------------------------------------------*
FORM f_assign_field  USING    fu_fieldname
                              fu_fs TYPE any
                              fu_value.
  ASSIGN COMPONENT fu_fieldname OF STRUCTURE fu_fs TO <fs>.
  IF <fs> IS ASSIGNED.
    <fs> = fu_value.
  ENDIF.
ENDFORM.                    " F_ASSIGN_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_create_fieldcat  USING    fu_container.
  DATA : lv_datum         TYPE sy-datum,
         lv_title(10),
         lv_fieldname(30).

  CASE fu_container.
    WHEN 'DETL'.
      PERFORM f_dyn_fcat USING :
      fu_container 'SHIPMENT' '' '' '' '' '' '' '' '' 'Shipment' '12' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'DATUM' '' '' '' '' '' '' '' '' 'Shipment Date' '12' 'D' '' '' '' ''
       '' '' '' '' '' '',
      fu_container 'VBELN' '' '' '' '' '' '' 'VBELN' 'VTTP' 'DN' '' '' '' '' '' ''
       '' '' '' '' '' '',
      fu_container 'LZNUM' '' '' '' '' '' '' 'LZNUM' 'LTAK' 'TO Group' '' '' '' '' '' ''
      '' '' '' '' '' '',
       fu_container 'TANUM' '' '' '' '' '' '' 'TANUM' 'LTAP' 'TO Number' '' '' '' '' '' ''
      '' '' '' '' '' ''.
    WHEN 'MONITOR_PICKING'.
      PERFORM f_dyn_fcat USING :
      fu_container 'SHIPMENT' '' '' '' '' '' '' '' '' 'Shipment' '12' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'SHIPMENT_DATE' '' '' '' '' '' '' '' '' 'Shipment Date' '15' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'LPICK' '' '' '' '' '' '' '' '' 'LPICK' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER1' '' '' '' '' '' '' '' '' 'PICKER1' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER2' '' '' '' '' '' '' '' '' 'PICKER2' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER3' '' '' '' '' '' '' '' '' 'PICKER3' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER4' '' '' '' '' '' '' '' '' 'PICKER4' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER5' '' '' '' '' '' '' '' '' 'PICKER5' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER6' '' '' '' '' '' '' '' '' 'PICKER6' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER7' '' '' '' '' '' '' '' '' 'PICKER7' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'PICKER8' '' '' '' '' '' '' '' '' 'PICKER8' '20' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'START_SHIPMENT' '' '' '' '' '' '' '' '' 'Start Shipment' '15' 'C' '' '' '' ''
      '' '' '' '' '' ''.
*      fu_container 'TOTAL' '' '' '' '' '' '' '' '' 'Total' '15' 'C' '' '' '' ''
*            '' '' '' '' '' ''.
    WHEN 'TREE'.
      PERFORM f_dyn_fcat USING :
        fu_container 'NODE_MAIN' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' ''
        '' '' '' '' '' ''.
    WHEN 'TO'.
      PERFORM f_dyn_fcat USING :
            fu_container 'TANUM' '' '' '' '' '' '' 'TANUM' 'LTAP' '' '' '' '' '' '' ''
  '' '' '' '' '' ''.
      IF pa_lgnum = 'C40'.
        PERFORM f_dyn_fcat USING :
              fu_container 'LZNUM' '' '' '' '' '' '' 'LZNUM' 'LTAK' '' '' '' '' '' '' ''
'' '' '' '' '' ''.
      ENDIF.
      PERFORM f_dyn_fcat USING :
            fu_container 'DATUM' '' '' '' '' '' '' '' '' 'Date' '12' 'D' '' '' '' ''
'' '' '' '' '' ''.
*      PERFORM f_dyn_fcat USING :
*        fu_container 'TANUM' '' '' '' '' '' '' 'TANUM' 'LTAP' '' '' '' '' '' '' ''
*        '' '' '' '' '' '',
*        fu_container 'DATUM' '' '' '' '' '' '' '' '' 'Date' '12' 'D' '' '' '' ''
*        '' '' '' '' '' ''.
    WHEN 'SHIPMENT'.
      PERFORM f_dyn_fcat USING :
        fu_container 'TKNUM' '' '' '' '' '' '' 'TKNUM' 'VTTK' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'DATUM' '' '' '' '' '' '' '' '' 'Date' '12' 'D' '' '' '' ''
        '' '' '' '' '' ''.
    WHEN 'DN'.
      PERFORM f_dyn_fcat USING :
        fu_container 'ICON' '' '' '' '' '' '' '' '' 'Sts' '4' '' '' '' '' ''
        '' '' 'X' '' '' '',
        fu_container 'VBELN' '' '' '' '' '' '' 'VBELN' 'ZWMDT004' 'DN' '' '' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'ERDAT' '' '' '' '' '' '' 'ERDAT' 'LIKP' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'ITEM' '' '' '' '' '' '' '' '' 'Item' '15' 'I' '' '' '' 'R'
        '' '' '' '' '' '',
        fu_container 'BTGEW' '' '' '' '' 'GEWEI' '' 'BTGEW' 'LIKP' '' '' '' '' '' ''
        '' '' '' '' '' '' '',
        fu_container 'GEWEI' '' '' '' '' '' '' 'GEWEI' 'LIKP' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'VOLUM' '' '' '' '' 'VOLEH' '' 'VOLUM' 'LIKP' '' '' '' '' '' ''
        '' '' '' '' '' '' '',
        fu_container 'VOLEH' '' '' '' '' '' '' 'VOLEH' 'LIKP' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'LZNUM' '' '' '' '' '' '' 'LZNUM' 'LTAK' '' '' '' '' '' '' ''
        '' '' '' '' '' ''.
    WHEN 'TIME'.
      PERFORM f_dyn_fcat USING :
        fu_container 'UNAME' '' '' '' '' '' '' 'QNAME' 'LTAP' '' '' '' '' '' '' ''
        '' 'X' '' '' '' '',
        fu_container 'NAME' '' '' '' '' '' '' 'NAME_TEXT' 'ADRP' 'Name' '20' '' '' '' '' ''
        '' 'X' '' '' '' '',
        fu_container 'TOTAL' '' '' '' '' '' '' '' '' 'Total' '15' 'C' '' '' '' ''
        '' '' '' '' '' '',
        fu_container 'AVERAGE' '' '' '' '' '' '' '' '' 'Average' '15' 'C' '' '' '' ''
        '' '' '' '' '' ''.
      CLEAR lv_datum.
      lv_datum = so_datum-low.
      DO gv_interval TIMES.
        WRITE lv_datum TO lv_title DD/MM/YYYY.
        CONCATENATE 'TO' lv_datum INTO lv_fieldname.
        CONDENSE lv_fieldname NO-GAPS.
        PERFORM f_dyn_fcat USING :
          fu_container lv_fieldname '' '' '' '' '' '' '' '' lv_title '15' 'C' '' '' '' ''
          '' '' '' '' '' ''.
        lv_datum = lv_datum + 1.
      ENDDO.
    WHEN 'STATUS_DO'.
      PERFORM f_dyn_fcat USING :
      fu_container 'TANGGAL' '' '' '' '' '' '' '' '' 'Date' '12' 'C' '' '' '' ''
'' '' '' '' '' '',
      fu_container 'TOTAL_DO' '' '' '' '' '' '' '' '' 'Total DO' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'TOTAL_PICKING' '' '' '' '' '' '' '' '' 'Total Picking' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'PICK_DO' '' '' '' '' '' '' '' '' 'Pick vs DO' '15' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'TOTAL_GI' '' '' '' '' '' '' '' '' 'Total GI' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'GI_DO' '' '' '' '' '' '' '' '' 'GI vs DO' '15' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'TOTAL_SHIPMENT' '' '' '' '' '' '' '' '' 'Total Shipment' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'SHIPMENT_DO' '' '' '' '' '' '' '' '' 'Shipment vs DO' '15' 'C' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'START_SHIPMENT' '' '' '' '' '' '' '' '' 'Total Start Shipment' '15' 'I' '' '' '' ''
      '' '' '' '' '' '',
      fu_container 'START_SHIPMENT_DO' '' '' '' '' '' '' '' '' 'Start Shipment vs DO' '15' 'C' '' '' '' ''
      '' '' '' '' '' ''.
    WHEN OTHERS.
      IF fu_container = 'UNAME'.
        PERFORM f_dyn_fcat USING :
          fu_container 'UNAME' '' '' '' '' '' '' 'QNAME' 'LTAP' '' '' '' '' '' '' ''
          '' 'X' '' '' '' '',
          fu_container 'NAME' '' '' '' '' '' '' 'NAME_TEXT' 'ADRP' 'Name' '20' '' '' '' '' ''
          '' 'X' '' '' '' ''.
      ELSEIF fu_container = 'KTEXT'.
        PERFORM f_dyn_fcat USING :
          fu_container 'KTEXT' '' '' '' '' '' '' 'KTEXT' 'T151T' '' '' '' '' '' '' ''
          '' 'X' '' '' '' ''.
      ENDIF.
*      PERFORM f_dyn_fcat USING :
*      fu_container 'TOTAL' '' '' '' '' '' '' '' '' 'Total' '15' 'I' '' '' '' 'R'
*      '' '' '' '' '' '',
*      fu_container 'AVERAGE' '' '' '' '' '' '' '' '' 'Average' '15' 'P' '' '' '' 'R'
*      '' '' '' '' '' '2'.
      PERFORM f_dyn_fcat USING :
      fu_container 'TOTAL' '' '' '' '' '' '' '' '' 'Total' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' ''.
      IF pa_lgnum = 'C40' AND ( radio1 IS NOT INITIAL OR radio4 IS NOT INITIAL ).
        PERFORM f_dyn_fcat USING :
      fu_container 'TOTAL_TO_GROUP' '' '' '' '' '' '' '' '' 'Total TO Group' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'TOTAL_CARTON' '' '' '' '' '' '' '' '' 'Total Carton' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' '',
      fu_container 'TOTAL_ECER' '' '' '' '' '' '' '' '' 'Total Ecer' '15' 'I' '' '' '' 'R'
      '' '' '' '' '' ''.
      ENDIF.
      PERFORM f_dyn_fcat USING :
fu_container 'AVERAGE' '' '' '' '' '' '' '' '' 'Average' '15' 'P' '' '' '' 'R'
'' '' '' '' '' '2'.


      CLEAR lv_datum.
      lv_datum = so_datum-low.
      DO gv_interval TIMES.
        WRITE lv_datum TO lv_title DD/MM/YYYY.
        CONCATENATE 'TO' lv_datum INTO lv_fieldname.
        CONDENSE lv_fieldname NO-GAPS.
        PERFORM f_dyn_fcat USING :
          fu_container lv_fieldname '' '' '' '' '' '' '' '' lv_title '15' 'I' '' '' '' 'R'
          '' '' '' '' '' ''.
        lv_datum = lv_datum + 1.
      ENDDO.
  ENDCASE.
ENDFORM.                    " F_CREATE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_fieldcat  USING    fu_container.
  CASE fu_container.
    WHEN 'TO'.
      gt_main_fieldcat[] = gt_tofcat[].
    WHEN 'DN'.
      gt_main_fieldcat[] = gt_dnfcat[].
    WHEN 'USERTM'.
      gt_main_fieldcat[] = gt_tmfcat[].
    WHEN 'UNAME'.
      gt_main_fieldcat[] = gt_usfcat[].
    WHEN 'KTEXT'.
      gt_main_fieldcat[] = gt_nmfcat[].
    WHEN 'SHIPMENT'.
      gt_main_fieldcat[] = gt_shfcat[].
    WHEN 'STATUS_DO'.
      gt_main_fieldcat[] = gt_sdfcat[].
    WHEN 'MONITOR_PICKING'.
      gt_main_fieldcat[] = gt_mpfcat[].
    WHEN 'DETL'.
      gt_main_fieldcat[] = gt_dfcat[].
  ENDCASE.
ENDFORM.                    " F_CHANGE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_DN_PICKING_CALC
*&---------------------------------------------------------------------*
FORM f_dn_picking_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lv_fieldname(30).


  TYPES: BEGIN OF ty_mat,
           ename TYPE ltap-ename,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.

  SORT gt_ltap BY ename tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING ename vbeln.

  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename tanum.

  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY ename.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING ename.

  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  CLEAR: temp_lznum.
  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-ename.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-ename.

    LOOP AT lt_yltap INTO ls_yltap WHERE ename = ls_xltap-ename.
      CONCATENATE 'TO' ls_yltap-edatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    LOOP AT lt_zltap INTO DATA(ls_zltap) WHERE ename = ls_xltap-ename.
      IF pa_lgnum = 'C40'.
        READ TABLE lt_ltak INTO DATA(ls_ltak) WITH KEY tanum = ls_zltap-tanum.
        IF sy-subrc = 0.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap BY ename matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm,
            temp_ename TYPE ltap-ename,
            count      TYPE i.
*      LOOP AT lt_ltap INTO DATA(ls_ltap).
*        IF temp_matnr <> ls_ltap-matnr.
*          CLEAR: temp_nistm.
*          temp_matnr = ls_ltap-matnr.
*          ADD ls_ltap-nistm TO temp_nistm.
*        ELSE.
*          ADD ls_ltap-nistm TO temp_nistm.
*        ENDIF.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = temp_nistm.
*        APPEND wa_mat TO it_mat.
*      ENDLOOP.
      LOOP AT lt_ltap INTO DATA(ls_ltap) WHERE ename = ls_xltap-ename.
        IF temp_matnr = ls_ltap-matnr AND temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          CLEAR: temp_nistm.
*          temp_matnr = ls_ltap-matnr.
**          temp_ename = ls_ltap-ename.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ELSE.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ENDIF.
*        wa_mat-ename = ls_ltap-ename.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.


      SORT it_mat DESCENDING BY ename matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING ename matnr.
*      CLEAR: count.
*      LOOP AT lt_ltap INTO DATA(ls_ltap).
*        ADD 1 TO count.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = ls_ltap-nistm.
*        wa_mat-count = count.
*        COLLECT wa_mat INTO it_mat.
*        CLEAR: count.
*      ENDLOOP.


      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat WHERE ename = ls_xltap-ename..
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
        IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
          lv_mod    = wa_mat-nistm MOD lv_umrez.
          lv_div    = wa_mat-nistm DIV lv_umrez.
          ADD lv_div TO lv_carton.
          ADD lv_mod TO lv_ecer.
        ENDIF.
      ENDLOOP.
      lv_fieldname = 'TOTAL_CARTON'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_carton.
      lv_fieldname = 'TOTAL_ECER'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_ecer.
    ENDIF.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_DN_PICKING_CALC

*&---------------------------------------------------------------------*
*&      Form  F_DN_PUTAWAY_CALC
*&---------------------------------------------------------------------*
FORM f_dn_putaway_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum qdatu.
  lt_yltap[] = gt_ltap[].
  IF pa_lgnum = 'C40'.
    SORT lt_yltap BY qname vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vlpla.
  ELSE.
    SORT lt_yltap BY qname vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vbeln.
  ENDIF.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
      CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_DN_PUTAWAY_CALC

*&---------------------------------------------------------------------*
*&      Form  F_DN_TRANSFER_CALC
*&---------------------------------------------------------------------*
FORM f_dn_transfer_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum qdatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY qname vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vbeln.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
      CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_DN_TRANSFER_CALC

*&---------------------------------------------------------------------*
*&      Form  F_DYNINT_TABLE
*&---------------------------------------------------------------------*
FORM f_dynint_table  TABLES   ft_fcat TYPE lvc_t_fcat
                     USING    fu_fieldname fu_color.
  DATA : lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         ls_lvc_cat   TYPE lvc_s_fcat,
         lt_fcat      TYPE lvc_t_fcat.

  IF ft_fcat[] IS NOT INITIAL.
    lt_fcat[] = ft_fcat[].

    IF fu_color IS NOT INITIAL.
      CLEAR ls_lvc_cat.
      ls_lvc_cat-fieldname = 'COLOR'.
      ls_lvc_cat-ref_table = 'CALENDAR_TYPE'.
      ls_lvc_cat-ref_field = 'COLTAB'.
      APPEND ls_lvc_cat TO lt_fcat.
      CLEAR ls_lvc_cat.
    ENDIF.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = lt_fcat
        i_length_in_byte          = 'X'
        i_style_table             = 'X'
      IMPORTING
        ep_table                  = lt_dyn_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.
    IF sy-subrc EQ 0.
      CASE fu_fieldname.
        WHEN 'TREE'.
          ASSIGN lt_dyn_table->* TO <fs_tree>.
          CREATE DATA ls_line LIKE LINE OF <fs_tree>.
          ASSIGN ls_line->* TO <fs_ltree>.
        WHEN 'UNAME'.
          ASSIGN lt_dyn_table->* TO <fs_utab>.
          CREATE DATA ls_line LIKE LINE OF <fs_utab>.
          ASSIGN ls_line->* TO <fs_lutab>.
        WHEN 'UNAME_C'.
          ASSIGN lt_dyn_table->* TO <fs_uname>.
          CREATE DATA ls_line LIKE LINE OF <fs_uname>.
          ASSIGN ls_line->* TO <fs_luname>.
        WHEN 'KTEXT'.
          ASSIGN lt_dyn_table->* TO <fs_ktab>.
          CREATE DATA ls_line LIKE LINE OF <fs_ktab>.
          ASSIGN ls_line->* TO <fs_lktab>.
        WHEN 'KTEXT_C'.
          ASSIGN lt_dyn_table->* TO <fs_ktext>.
          CREATE DATA ls_line LIKE LINE OF <fs_ktext>.
          ASSIGN ls_line->* TO <fs_lktext>.
        WHEN 'TO'.
          ASSIGN lt_dyn_table->* TO <fs_to>.
          CREATE DATA ls_line LIKE LINE OF <fs_to>.
          ASSIGN ls_line->* TO <fs_lto>.
        WHEN 'DN'.
          ASSIGN lt_dyn_table->* TO <fs_dn>.
          CREATE DATA ls_line LIKE LINE OF <fs_dn>.
          ASSIGN ls_line->* TO <fs_ldn>.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CREATE_DYNINT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_TIMES_PICKING_CALC
*&---------------------------------------------------------------------*
FORM f_times_picking_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum,
         lv_totalsec      TYPE i.

  SORT gt_ltap BY ename tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING ename tanum.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY ename.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING ename.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lttab> ls_xltap-ename.
    PERFORM f_get_user_name USING 'LTTAB' ls_xltap-ename.

    lv_datum = so_datum-low - 1.
    DO gv_interval TIMES.
      ADD 1 TO lv_datum.
      IF pa_lgnum(1) = 'C'.
*        IF pa_lgnum = 'C40'.
*          PERFORM f_calc_times_1_c40 TABLES lt_yltap
*                       USING ls_xltap-ename lv_datum
*                       CHANGING lv_totalsec.
*        ELSE.
        PERFORM f_calc_times_1 TABLES lt_yltap
                               USING ls_xltap-ename lv_datum
                               CHANGING lv_totalsec.
*        ENDIF.
      ENDIF.

      CONCATENATE 'TO' lv_datum INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
      <fs> = lv_totalsec.
      CLEAR lv_totalsec.
    ENDDO.
    APPEND <fs_lttab> TO <fs_ttab>.
    CLEAR : <fs_lttab>.
  ENDLOOP.
ENDFORM.                    " F_TIMES_PICKING_CALC

*&---------------------------------------------------------------------*
*&      Form  F_SECOND_CONVERSION
*&---------------------------------------------------------------------*
FORM f_second_conversion  USING    fu_value fu_fieldname
                          CHANGING fc_value.
  DATA : lv_second    TYPE i,
         lv_days      TYPE i,
         lv_uzeit     TYPE sy-uzeit,
         lv_value(15).

  lv_second    = fu_value.
  lv_days      = lv_second DIV 86400.
  lv_second    = lv_second MOD 86400.
  lv_uzeit     = lv_second.

  WRITE lv_uzeit TO lv_value USING EDIT MASK '__:__:__'.
  IF fu_fieldname IS NOT INITIAL.
    ASSIGN COMPONENT fu_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
    <fs> = lv_value.
  ELSE.
    fc_value = lv_value.
  ENDIF.
ENDFORM.                    " F_SECOND_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_TIMES_PUTAWAY_CALC
*&---------------------------------------------------------------------*
FORM f_times_putaway_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum,
         lv_totalsec      TYPE i.

  SORT gt_ltap BY qname tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname tanum.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lttab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LTTAB' ls_xltap-qname.

    lv_datum = so_datum-low - 1.
    DO gv_interval TIMES.
      ADD 1 TO lv_datum.
      IF pa_lgnum(1) = 'C'.
        PERFORM f_calc_times_2 TABLES lt_yltap
                               USING ls_xltap-qname lv_datum
                               CHANGING lv_totalsec.
      ENDIF.

      CONCATENATE 'TO' lv_datum INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
      <fs> = lv_totalsec.
      CLEAR lv_totalsec.
    ENDDO.
    APPEND <fs_lttab> TO <fs_ttab>.
    CLEAR : <fs_lttab>.
  ENDLOOP.
ENDFORM.                    " F_TIMES_PUTAWAY_CALC

*&---------------------------------------------------------------------*
*&      Form  F_TIMES_TRANSFER_CALC
*&---------------------------------------------------------------------*
FORM f_times_transfer_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum,
         lv_totalsec      TYPE i.

  SORT gt_ltap BY qname tanum edatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename tanum.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname tanum.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lttab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LTTAB' ls_xltap-qname.

    lv_datum = so_datum-low - 1.
    DO gv_interval TIMES.
      ADD 1 TO lv_datum.
      IF pa_lgnum(1) = 'C'.
        PERFORM f_calc_times_2 TABLES lt_yltap
                               USING ls_xltap-qname lv_datum
                               CHANGING lv_totalsec.
      ENDIF.

      CONCATENATE 'TO' lv_datum INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
      <fs> = lv_totalsec.
      CLEAR lv_totalsec.
    ENDDO.
    APPEND <fs_lttab> TO <fs_ttab>.
    CLEAR : <fs_lttab>.
  ENDLOOP.
ENDFORM.                    " F_TIMES_TRANSFER_CALC

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CHKOUT
*&---------------------------------------------------------------------*
FORM f_get_data_chkout .
  SELECT *
    FROM zwmdt003
    INTO CORRESPONDING FIELDS OF TABLE gt_003
    WHERE tknum IN so_tknum
      AND dalbg IN so_datum
      AND ernam IN so_uname.



  IF pa_lgnum = 'C40'.
    DATA : lt_xltap TYPE STANDARD TABLE OF ltap,
           ls_xltap LIKE LINE OF lt_xltap,
           lt_yltap TYPE STANDARD TABLE OF ltap,
           ls_yltap LIKE LINE OF lt_yltap,
           lt_zltap TYPE STANDARD TABLE OF ltap,
           ls_zltap LIKE LINE OF lt_yltap,
           lv_count TYPE i,
           lv_index TYPE i,
           lv_subrc TYPE sy-subrc,
           ls_ltak  LIKE LINE OF gt_ltak,
           ls_ltap  LIKE LINE OF gt_ltap.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      WHERE lgnum = pa_lgnum
        AND tanum IN so_tanum
        AND qname IN so_uname
        AND nltyp = '916'.

    lt_xltap[] = gt_ltap[].
    SORT lt_xltap BY tanum edatu DESCENDING ezeit DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum edatu ename.
    lt_yltap[] = lt_xltap[].
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING tanum.

    IF lt_yltap[] IS NOT INITIAL.
      SELECT *
        FROM ltak
        INTO CORRESPONDING FIELDS OF TABLE gt_ltak
        FOR ALL ENTRIES IN lt_yltap
        WHERE lgnum = pa_lgnum
          AND tanum = lt_yltap-tanum
          AND bwlvs IN gr_bwlvs
          AND kquit = 'X'.
    ENDIF.

  ENDIF.
ENDFORM.                    " F_GET_DATA_CHKOUT

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_CHKOUT
*&---------------------------------------------------------------------*
FORM f_calculate_chkout .
  DATA : lt_x003          TYPE STANDARD TABLE OF zwmdt003,
         ls_x003          LIKE LINE OF lt_x003,
         lt_y003          TYPE STANDARD TABLE OF zwmdt003,
         ls_y003          LIKE LINE OF lt_y003,
         lt_z003          TYPE STANDARD TABLE OF zwmdt003,
         ls_ltak          LIKE LINE OF gt_ltak,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lv_fieldname(30).

  TYPES: BEGIN OF ty_mat,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.


  SORT gt_ltap BY ename tanum edatu.

  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename tanum.

  SORT gt_003 BY ernam tknum dalbg.
  lt_z003[] = gt_003[].
  SORT lt_z003 BY ernam vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_z003 COMPARING ernam vbeln.

  lt_y003[] = gt_003[].
  SORT lt_y003 BY ernam tknum.
  DELETE ADJACENT DUPLICATES FROM lt_y003 COMPARING ernam tknum.

  lt_x003[] = lt_y003[].
  SORT lt_x003 BY ernam.
  DELETE ADJACENT DUPLICATES FROM lt_x003 COMPARING ernam.

  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  LOOP AT lt_x003 INTO ls_x003.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x003-ernam.
    PERFORM f_get_user_name USING 'LUTAB' ls_x003-ernam.

    LOOP AT lt_y003 INTO ls_y003 WHERE ernam = ls_x003-ernam.
      CONCATENATE 'TO' ls_y003-dalbg INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    IF pa_lgnum = 'C40'.
      LOOP AT lt_z003 INTO DATA(ls_z003) WHERE ernam = ls_x003-ernam.
        LOOP AT lt_ltak INTO ls_ltak WHERE vbeln = ls_z003-vbeln.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap BY matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm.
      LOOP AT lt_ltap INTO DATA(ls_ltap).
        IF temp_matnr <> ls_ltap-matnr.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          ADD ls_ltap-nistm TO temp_nistm.
        ELSE.
          ADD ls_ltap-nistm TO temp_nistm.
        ENDIF.
        wa_mat-matnr = ls_ltap-matnr.
        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.

      SORT it_mat DESCENDING BY matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING matnr.
      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat.
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
        IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
          lv_mod    = wa_mat-nistm MOD lv_umrez.
          lv_div    = wa_mat-nistm DIV lv_umrez.
          ADD lv_div TO lv_carton.
          ADD lv_mod TO lv_ecer.
        ENDIF.
      ENDLOOP.
      lv_fieldname = 'TOTAL_CARTON'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_carton.
      lv_fieldname = 'TOTAL_ECER'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      <fs> = lv_ecer.
    ENDIF.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_CHKOUT

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_display_shipment  USING    fu_uname fu_all.
  DATA : lt_003 TYPE STANDARD TABLE OF zwmdt003,
         ls_003 LIKE LINE OF lt_003,
         lt_004 TYPE STANDARD TABLE OF zwmdt004,
         ls_004 LIKE LINE OF lt_004.

  CLEAR : <fs_ship>[].

  CASE 'X'.
    WHEN radio4.
      lt_003[] = gt_003[].
      SORT lt_003 BY ernam tknum.
      DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING ernam tknum.
      IF fu_all IS INITIAL.
        DELETE lt_003 WHERE ernam <> fu_uname.
      ENDIF.

      LOOP AT lt_003 INTO ls_003.
        PERFORM f_assign_field USING 'TKNUM' <fs_lship> ls_003-tknum.
        PERFORM f_assign_field USING 'DATUM' <fs_lship> ls_003-dalbg.
        APPEND <fs_lship> TO <fs_ship>.
        CLEAR <fs_lship>.
      ENDLOOP.

    WHEN radio5.
      lt_004[] = gt_004[].
      SORT lt_004 BY znmuld tknum.
      DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING znmuld tknum.
      IF fu_all IS INITIAL.
        DELETE lt_004 WHERE znmuld <> fu_uname.
      ENDIF.

      LOOP AT lt_004 INTO ls_004.
        PERFORM f_assign_field USING 'TKNUM' <fs_lship> ls_004-tknum.
        PERFORM f_assign_field USING 'DATUM' <fs_lship> ls_004-zdtsul.
        APPEND <fs_lship> TO <fs_ship>.
        CLEAR <fs_lship>.
      ENDLOOP.
  ENDCASE.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_DISPLAY_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_DN_FR_LTAP
*&---------------------------------------------------------------------*
FORM f_dn_fr_ltap  TABLES   ft_ltap STRUCTURE ltap.
  DATA : ls_likp  LIKE LINE OF gt_likp,
         ls_lips  LIKE LINE OF gt_lips,
         ls_ltap  TYPE ltap,
         lv_item  TYPE i,
         lv_vbeln TYPE likp-vbeln.
  DATA: lv_fieldname(30).

  DATA(xft_ltap) = ft_ltap[].
  IF pa_lgnum = 'C40'.
    DELETE ADJACENT DUPLICATES FROM xft_ltap COMPARING ename vbeln.
*    DELETE ADJACENT DUPLICATES FROM xft_ltap COMPARING ename vlpla.
*    SORT xft_ltap BY ename vbeln.
*    DELETE ADJACENT DUPLICATES FROM xft_ltap COMPARING ename vbeln.
  ELSE.
*        DELETE ADJACENT DUPLICATES FROM xft_ltap COMPARING ename vlpla.
    DELETE ADJACENT DUPLICATES FROM xft_ltap COMPARING ename vbeln.
  ENDIF.
  DATA: temp_vbeln TYPE ltak-vbeln.
  CLEAR: temp_vbeln.
  LOOP AT xft_ltap INTO ls_ltap.
    CASE 'X'.
      WHEN radio1.
        lv_vbeln  = ls_ltap-vbeln.
      WHEN radio2.
        lv_vbeln  = ls_ltap-vlpla.
    ENDCASE.

    IF lv_vbeln IS INITIAL.
      CONTINUE.
    ENDIF.

    IF pa_lgnum = 'C40'.
      READ TABLE gt_ltak INTO DATA(ls_ltak) WITH KEY tanum = ls_ltap-tanum.
      IF sy-subrc = 0.
        PERFORM f_assign_field USING 'LZNUM' <fs_ldn> ls_ltak-lznum.
      ENDIF.
*      CLEAR lv_item.
*      LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_ltap-vbeln.
*        IF ls_lips-uecha IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.
*        IF ls_lips-lfimg IS NOT INITIAL.
*          ADD 1 TO lv_item.
*        ENDIF.
*      ENDLOOP.
*
*      PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.
*      LOOP AT gt_items INTO gs_items WHERE vbeln = lv_vbeln.
*        lv_fieldname = 'ITEM'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldn> TO <fs>.
*        <fs> = gs_items-item.
*      ENDLOOP.
*      LOOP AT ft_ltap INTO DATA(ls_ltap2) WHERE ename = ls_ltap-ename AND vlpla = ls_ltap-vlpla AND vbeln = ls_ltap-vbeln.
*        lv_fieldname = 'ITEM'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldn> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
        CLEAR lv_item.
        LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_ltap-vbeln.
*        IF ls_lips-uecha IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.
          IF ls_lips-lfimg IS NOT INITIAL.
            ADD 1 TO lv_item.
          ENDIF.
        ENDLOOP.

        PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.
      ELSE.
*      LOOP AT ft_ltap INTO ls_ltap2 WHERE ename = ls_ltap-ename AND vlpla = ls_ltap-vlpla AND vbeln = ls_ltap-vbeln.
*        lv_fieldname = 'ITEM'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldn> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
        CLEAR lv_item.
        LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_ltap-vbeln.
*        IF ls_lips-uecha IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.
          IF ls_lips-lfimg IS NOT INITIAL.
            ADD 1 TO lv_item.
          ENDIF.
        ENDLOOP.

        PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.
      ENDIF.

      PERFORM f_assign_field USING 'VBELN' <fs_ldn> lv_vbeln.

      CLEAR ls_likp.
      READ TABLE gt_likp INTO ls_likp
                         WITH KEY vbeln = lv_vbeln.
      IF sy-subrc = 0.
        PERFORM f_assign_field USING 'ERDAT' <fs_ldn> ls_likp-erdat.
        IF temp_vbeln <> ls_ltap-vbeln.
          temp_vbeln = ls_ltap-vbeln.
          PERFORM f_assign_field USING 'BTGEW' <fs_ldn> ls_likp-btgew.
          PERFORM f_assign_field USING 'GEWEI' <fs_ldn> ls_likp-gewei.
          PERFORM f_assign_field USING 'VOLUM' <fs_ldn> ls_likp-volum.
          PERFORM f_assign_field USING 'VOLEH' <fs_ldn> ls_likp-voleh.
        ELSE.
          PERFORM f_assign_field USING 'BTGEW' <fs_ldn> ''."ls_likp-btgew.
          PERFORM f_assign_field USING 'GEWEI' <fs_ldn> ''."ls_likp-gewei.
          PERFORM f_assign_field USING 'VOLUM' <fs_ldn> ''."ls_likp-volum.
          PERFORM f_assign_field USING 'VOLEH' <fs_ldn> ''."ls_likp-voleh.
        ENDIF.
      ELSE.
        PERFORM f_assign_field USING 'ICON' <fs_ldn> icon_delete.
      ENDIF.

*    CLEAR lv_item.
*    LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_ltap-vbeln.
*      IF ls_lips-uecha IS NOT INITIAL.
*        CONTINUE.
*      ENDIF.
*      IF ls_lips-lfimg IS NOT INITIAL.
*        ADD 1 TO lv_item.
*      ENDIF.
*    ENDLOOP.
*
*    PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.

*    IF pa_lgnum = 'C40'.
*      READ TABLE gt_ltak INTO DATA(ls_ltak) WITH KEY tanum = ls_ltap-tanum.
*      IF sy-subrc = 0.
*        PERFORM f_assign_field USING 'LZNUM' <fs_ldn> ls_ltak-lznum.
*      ENDIF.
*
*      LOOP AT ft_ltap INTO DATA(ls_ltap2) WHERE ename = ls_ltap-ename AND vbeln = ls_ltap-vbeln.
*        lv_fieldname = 'ITEM'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldn> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
*    ELSE.
*      CLEAR lv_item.
*      LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_ltap-vbeln.
*        IF ls_lips-uecha IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.
*        IF ls_lips-lfimg IS NOT INITIAL.
*          ADD 1 TO lv_item.
*        ENDIF.
*      ENDLOOP.
*
*      PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.
*    ENDIF.


      APPEND <fs_ldn> TO <fs_dn>.
      CLEAR: <fs_ldn>.
    ENDLOOP.

ENDFORM.                    " F_DN_FR_LTAP

*&---------------------------------------------------------------------*
*&      Form  F_DN_FR_003
*&---------------------------------------------------------------------*
FORM f_dn_fr_003  TABLES   ft_003 STRUCTURE zwmdt003.
  DATA : ls_likp  LIKE LINE OF gt_likp,
         ls_lips  LIKE LINE OF gt_lips,
         ls_003   TYPE zwmdt003,
         lv_item  TYPE i,
         lv_vbeln TYPE likp-vbeln.

  LOOP AT ft_003 INTO ls_003.
    IF ls_003-vbeln IS INITIAL.
      CONTINUE.
    ENDIF.

**    Added lznum
*    READ TABLE gt_ltak INTO DATA(ls_ltak) WITH KEY vbeln = ls_003-vbeln.
*    IF sy-subrc = 0.
*      PERFORM f_assign_field USING 'LZNUM' <fs_ldn> ls_ltak-lznum.
*    ENDIF.

    PERFORM f_assign_field USING 'VBELN' <fs_ldn> ls_003-vbeln.

    CLEAR ls_likp.
    READ TABLE gt_likp INTO ls_likp
                       WITH KEY vbeln = ls_003-vbeln.
    IF sy-subrc = 0.
      PERFORM f_assign_field USING 'ERDAT' <fs_ldn> ls_likp-erdat.
      PERFORM f_assign_field USING 'BTGEW' <fs_ldn> ls_likp-btgew.
      PERFORM f_assign_field USING 'GEWEI' <fs_ldn> ls_likp-gewei.
      PERFORM f_assign_field USING 'VOLUM' <fs_ldn> ls_likp-volum.
      PERFORM f_assign_field USING 'VOLEH' <fs_ldn> ls_likp-voleh.
    ELSE.
      PERFORM f_assign_field USING 'ICON' <fs_ldn> icon_delete.
    ENDIF.

    CLEAR lv_item.
    LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_003-vbeln.
      IF ls_lips-uecha IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF ls_lips-lfimg IS NOT INITIAL.
        ADD 1 TO lv_item.
      ENDIF.
    ENDLOOP.

    PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.

    APPEND <fs_ldn> TO <fs_dn>.
    CLEAR <fs_ldn>.
  ENDLOOP.
ENDFORM.                    " F_DN_FR_003

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_process_shipment .
  DATA : lv_datum     TYPE sy-datum.

  CASE 'X'.
    WHEN radio4.
      PERFORM f_calculate_chkout.
    WHEN radio5.
      PERFORM f_calculate_chkin.
  ENDCASE.
  CLEAR : lv_datum.
  PERFORM f_display_modify USING 'UNAME' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " F_PROCESS_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_DN_CHKOUT_CALC
*&---------------------------------------------------------------------*
FORM f_dn_chkout_calc .
  DATA : lt_x003          TYPE STANDARD TABLE OF zwmdt003,
         ls_x003          LIKE LINE OF lt_x003,
         lt_y003          TYPE STANDARD TABLE OF zwmdt003,
         ls_y003          LIKE LINE OF lt_y003,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lv_fieldname(30).

  TYPES: BEGIN OF ty_mat,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.


  SORT gt_ltap BY ename tanum edatu.

  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename tanum.

  SORT gt_003 BY ernam tknum dalbg.
  lt_y003[] = gt_003[].
  SORT lt_y003 BY ernam vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_y003 COMPARING ernam vbeln.
  lt_x003[] = lt_y003[].
  SORT lt_x003 BY ernam.
  DELETE ADJACENT DUPLICATES FROM lt_x003 COMPARING ernam.


  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  LOOP AT lt_x003 INTO ls_x003.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x003-ernam.
    PERFORM f_get_user_name USING 'LUTAB' ls_x003-ernam.

    LOOP AT lt_y003 INTO ls_y003 WHERE ernam = ls_x003-ernam.
      CONCATENATE 'TO' ls_y003-dalbg INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
      IF pa_lgnum = 'C40'.
        LOOP AT lt_ltak INTO DATA(ls_ltak) WHERE vbeln = ls_y003-vbeln.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap BY matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm.
      LOOP AT lt_ltap INTO DATA(ls_ltap).
        IF temp_matnr <> ls_ltap-matnr.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          ADD ls_ltap-nistm TO temp_nistm.
        ELSE.
          ADD ls_ltap-nistm TO temp_nistm.
        ENDIF.
        wa_mat-matnr = ls_ltap-matnr.
        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.

      SORT it_mat DESCENDING BY matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING matnr.
      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat.
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
          IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
            lv_mod    = wa_mat-nistm MOD lv_umrez.
            lv_div    = wa_mat-nistm DIV lv_umrez.
            ADD lv_div TO lv_carton.
            ADD lv_mod TO lv_ecer.
          ENDIF.
        ENDLOOP.
        lv_fieldname = 'TOTAL_CARTON'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_carton.
        lv_fieldname = 'TOTAL_ECER'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_ecer.
      ENDIF.
      APPEND <fs_lutab> TO <fs_utab>.
      CLEAR <fs_lutab>.
    ENDLOOP.
ENDFORM.                    " F_DN_CHKOUT_CALC

*&---------------------------------------------------------------------*
*&      Form  F_TIMES_CHKOUT_CALC
*&---------------------------------------------------------------------*
FORM f_times_chkout_calc .
  DATA : lt_x003          TYPE STANDARD TABLE OF zwmdt003,
         ls_x003          LIKE LINE OF lt_x003,
         lt_y003          TYPE STANDARD TABLE OF zwmdt003,
         ls_y003          LIKE LINE OF lt_y003,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum,
         lv_totalsec      TYPE i.

  SORT gt_003 BY ernam tknum dalbg.
  lt_y003[] = gt_003[].
  SORT lt_y003 BY ernam tknum.
  DELETE ADJACENT DUPLICATES FROM lt_y003 COMPARING ernam tknum.
  lt_x003[] = lt_y003[].
  SORT lt_x003 BY ernam.
  DELETE ADJACENT DUPLICATES FROM lt_x003 COMPARING ernam.

  LOOP AT lt_x003 INTO ls_x003.
    PERFORM f_assign_field USING 'UNAME' <fs_lttab> ls_x003-ernam.
    PERFORM f_get_user_name USING 'LTTAB' ls_x003-ernam.

    lv_datum = so_datum-low - 1.
    DO gv_interval TIMES.
      ADD 1 TO lv_datum.
      IF pa_lgnum(1) = 'C'.
        PERFORM f_calc_times_3 TABLES lt_y003
                               USING ls_x003-ernam lv_datum
                               CHANGING lv_totalsec.
      ENDIF.

      CONCATENATE 'TO' lv_datum INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
      <fs> = lv_totalsec.
      CLEAR lv_totalsec.
    ENDDO.
    APPEND <fs_lttab> TO <fs_ttab>.
    CLEAR : <fs_lttab>.
  ENDLOOP.
ENDFORM.                    " F_TIMES_CHKOUT_CALC

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TIMES_3
*&---------------------------------------------------------------------*
FORM f_calc_times_3  TABLES   ft_y003 STRUCTURE zwmdt003
                     USING    fu_uname fu_datum
                     CHANGING fc_totalsec.

  DATA : ls_y003        TYPE zwmdt003.

  DATA : lv_second   TYPE i,
         lv_totalsec TYPE i,
         lv_lines    TYPE i.

  DATA : lv_timestamp1 TYPE ccupeaka-timestamp,
         lv_timestamp2 TYPE ccupeaka-timestamp,
         lv_different  TYPE i.

  DATA : lv_t1 TYPE sy-uzeit,
         lv_t2 TYPE sy-uzeit,
         lv_d1 TYPE sy-datum,
         lv_d2 TYPE sy-datum.

  LOOP AT ft_y003 INTO ls_y003 WHERE ernam = fu_uname
                                 AND dalbg = fu_datum.

    CLEAR : lv_timestamp1, lv_timestamp2, lv_different,
            lv_t1, lv_t2, lv_d1, lv_d2, lv_second.

    CONCATENATE ls_y003-dalbg ls_y003-ualbg INTO lv_timestamp1.
    CONCATENATE ls_y003-dalen ls_y003-ualen INTO lv_timestamp2.

    IF lv_timestamp1 IS NOT INITIAL AND
      lv_timestamp2 IS NOT INITIAL.
      CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
        EXPORTING
          timestamp1 = lv_timestamp1
          timestamp2 = lv_timestamp2
        IMPORTING
          difference = lv_different.
    ELSEIF lv_timestamp1 IS INITIAL.
      lv_different = 0.
    ENDIF.

    lv_t1 = ls_y003-ualbg.
    lv_d1 = ls_y003-dalbg.
    lv_t2 = ls_y003-ualen.
    lv_d2 = ls_y003-dalen.

    CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
      EXPORTING
        date_1  = lv_d1
        time_1  = lv_t1
        date_2  = lv_d2
        time_2  = lv_t2
      IMPORTING
        seconds = lv_second.

    ADD lv_second TO lv_totalsec.
  ENDLOOP.

  fc_totalsec  = lv_totalsec.
ENDFORM.                    " F_CALC_TIMES_3

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CHKIN
*&---------------------------------------------------------------------*
FORM f_get_data_chkin .
  SELECT *
    FROM zwmdt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE lgnum  = pa_lgnum
      AND tknum  IN so_tknum
      AND tanum  IN so_tanum
      AND zdtsul IN so_datum
      AND znmuld IN so_uname.
ENDFORM.                    " F_GET_DATA_CHKIN

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_CHKIN
*&---------------------------------------------------------------------*
FORM f_calculate_chkin .
  DATA : lt_x004          TYPE STANDARD TABLE OF zwmdt004,
         ls_x004          LIKE LINE OF lt_x004,
         lt_y004          TYPE STANDARD TABLE OF zwmdt004,
         ls_y004          LIKE LINE OF lt_y004,
         lv_fieldname(30).

  CASE gv_process.
    WHEN 'USERSHIP'.
      SORT gt_004 BY znmuld tknum zdtsul.
      lt_y004[] = gt_004[].
      SORT lt_y004 BY znmuld tknum.
      DELETE ADJACENT DUPLICATES FROM lt_y004 COMPARING znmuld tknum.

      lt_x004[] = lt_y004[].
      SORT lt_x004 BY znmuld.
      DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING znmuld.

      LOOP AT lt_x004 INTO ls_x004.
        PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x004-znmuld.
        PERFORM f_get_user_name USING 'LUTAB' ls_x004-znmuld.

        LOOP AT lt_y004 INTO ls_y004 WHERE znmuld = ls_x004-znmuld.
          CONCATENATE 'TO' ls_y004-zdtsul INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
          ADD 1 TO <fs>.
        ENDLOOP.
        APPEND <fs_lutab> TO <fs_utab>.
        CLEAR <fs_lutab>.
      ENDLOOP.

    WHEN OTHERS.
      SORT gt_004 BY znmuld tanum zdtsul.
      lt_y004[] = gt_004[].
      SORT lt_y004 BY znmuld tanum.
      DELETE ADJACENT DUPLICATES FROM lt_y004 COMPARING znmuld tanum.

      lt_x004[] = lt_y004[].
      SORT lt_x004 BY znmuld.
      DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING znmuld.

      LOOP AT lt_x004 INTO ls_x004.
        PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x004-znmuld.
        PERFORM f_get_user_name USING 'LUTAB' ls_x004-znmuld.

        LOOP AT lt_y004 INTO ls_y004 WHERE znmuld = ls_x004-znmuld.
          CONCATENATE 'TO' ls_y004-zdtsul INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
          ADD 1 TO <fs>.
        ENDLOOP.
        APPEND <fs_lutab> TO <fs_utab>.
        CLEAR <fs_lutab>.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALCULATE_CHKIN

*&---------------------------------------------------------------------*
*&      Form  F_DN_CHKIN_CALC
*&---------------------------------------------------------------------*
FORM f_dn_chkin_calc .
  DATA : lt_x004          TYPE STANDARD TABLE OF zwmdt004,
         ls_x004          LIKE LINE OF lt_x004,
         lt_y004          TYPE STANDARD TABLE OF zwmdt004,
         ls_y004          LIKE LINE OF lt_y004,
         lv_fieldname(30).

  SORT gt_004 BY znmuld tanum zdtsul.
  lt_y004[] = gt_004[].
  SORT lt_y004 BY znmuld vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_y004 COMPARING znmuld vbeln.
  lt_x004[] = lt_y004[].
  SORT lt_x004 BY znmuld.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING znmuld.

  LOOP AT lt_x004 INTO ls_x004.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x004-znmuld.
    PERFORM f_get_user_name USING 'LUTAB' ls_x004-znmuld.

    LOOP AT lt_y004 INTO ls_y004 WHERE znmuld = ls_x004-znmuld.
      CONCATENATE 'TO' ls_y004-zdtsul INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.                    " F_DN_CHKIN_CALC

*&---------------------------------------------------------------------*
*&      Form  F_TIMES_CHKIN_CALC
*&---------------------------------------------------------------------*
FORM f_times_chkin_calc .
  DATA : lt_x004          TYPE STANDARD TABLE OF zwmdt004,
         ls_x004          LIKE LINE OF lt_x004,
         lt_y004          TYPE STANDARD TABLE OF zwmdt004,
         ls_y004          LIKE LINE OF lt_y004,
         lv_fieldname(30),
         lv_datum         TYPE sy-datum,
         lv_totalsec      TYPE i.

  SORT gt_004 BY znmuld tanum zdtsul.
  lt_y004[] = gt_004[].
  SORT lt_y004 BY znmuld tanum.
  DELETE ADJACENT DUPLICATES FROM lt_y004 COMPARING znmuld tanum.
  lt_x004[] = lt_y004[].
  SORT lt_x004 BY znmuld.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING znmuld.

  LOOP AT lt_x004 INTO ls_x004.
    PERFORM f_assign_field USING 'UNAME' <fs_lttab> ls_x004-znmuld.
    PERFORM f_get_user_name USING 'LTTAB' ls_x004-znmuld.

    lv_datum = so_datum-low - 1.
    DO gv_interval TIMES.
      ADD 1 TO lv_datum.
      IF pa_lgnum(1) = 'C'.
        PERFORM f_calc_times_4 TABLES lt_y004
                               USING ls_x004-znmuld lv_datum
                               CHANGING lv_totalsec.
      ENDIF.

      CONCATENATE 'TO' lv_datum INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lttab> TO <fs>.
      <fs> = lv_totalsec.
      CLEAR lv_totalsec.
    ENDDO.
    APPEND <fs_lttab> TO <fs_ttab>.
    CLEAR : <fs_lttab>.
  ENDLOOP.
ENDFORM.                    " F_TIMES_CHKIN_CALC

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TIMES_4
*&---------------------------------------------------------------------*
FORM f_calc_times_4  TABLES   ft_y004 STRUCTURE zwmdt004
                     USING    fu_uname fu_datum
                     CHANGING fc_totalsec.
  DATA : ls_y004 TYPE zwmdt004,
         ls_004  TYPE zwmdt004.

  DATA : lt_econf TYPE STANDARD TABLE OF ty_econf,
         ls_econf LIKE LINE OF lt_econf,
         ls_times LIKE LINE OF gt_times.

  DATA : lv_second   TYPE i,
         lv_totalsec TYPE i,
         lv_lines    TYPE i.

  DATA : lv_timestamp1 TYPE ccupeaka-timestamp,
         lv_timestamp2 TYPE ccupeaka-timestamp,
         lv_different  TYPE i.

  DATA : lv_t1 TYPE sy-uzeit,
         lv_t2 TYPE sy-uzeit,
         lv_d1 TYPE sy-datum,
         lv_d2 TYPE sy-datum.

  LOOP AT ft_y004 INTO ls_y004 WHERE znmuld = fu_uname
                                 AND zdtsul = fu_datum.

    lv_t1 = ls_y004-zuzsul.
    lv_d1 = ls_y004-zdtsul.
    lv_t2 = ls_y004-zuzeul.
    lv_d2 = ls_y004-zdteul.

    CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
      EXPORTING
        date_1  = lv_d1
        time_1  = lv_t1
        date_2  = lv_d2
        time_2  = lv_t2
      IMPORTING
        seconds = lv_second.

    ADD lv_second TO lv_totalsec.
  ENDLOOP.

  fc_totalsec  = lv_totalsec.
ENDFORM.                    " F_CALC_TIMES_4

*&---------------------------------------------------------------------*
*&      Form  F_DN_FR_004
*&---------------------------------------------------------------------*
FORM f_dn_fr_004  TABLES   ft_004 STRUCTURE zwmdt004.
  DATA : ls_likp  LIKE LINE OF gt_likp,
         ls_lips  LIKE LINE OF gt_lips,
         ls_004   TYPE zwmdt004,
         ls_x004  TYPE zwmdt004,
         lv_item  TYPE i,
         lv_vbeln TYPE zwmdt004-vbeln.

  LOOP AT ft_004 INTO ls_004.
    IF ls_004-vbeln IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM f_assign_field USING 'VBELN' <fs_ldn> ls_004-vbeln.
    PERFORM f_assign_field USING 'ERDAT' <fs_ldn> ls_004-zdtsul.

    CLEAR ls_likp.
    READ TABLE gt_likp INTO ls_likp
                       WITH KEY vbeln = ls_004-vbeln.
    IF sy-subrc = 0.
      PERFORM f_assign_field USING 'BTGEW' <fs_ldn> ls_likp-btgew.
      PERFORM f_assign_field USING 'GEWEI' <fs_ldn> ls_likp-gewei.
      PERFORM f_assign_field USING 'VOLUM' <fs_ldn> ls_likp-volum.
      PERFORM f_assign_field USING 'VOLEH' <fs_ldn> ls_likp-voleh.
    ELSE.
      PERFORM f_assign_field USING 'ICON' <fs_ldn> icon_delete.
    ENDIF.

    CLEAR lv_item.
    LOOP AT gt_004 INTO ls_x004 WHERE vbeln = ls_004-vbeln.
      ADD 1 TO lv_item.
    ENDLOOP.

    PERFORM f_assign_field USING 'ITEM' <fs_ldn> lv_item.

    APPEND <fs_ldn> TO <fs_dn>.
    CLEAR <fs_ldn>.
  ENDLOOP.
ENDFORM.                    " F_DN_FR_004

*&---------------------------------------------------------------------*
*&      Form  F_GET_FULL_NAME
*&---------------------------------------------------------------------*
FORM f_get_full_name .
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         lt_003  TYPE STANDARD TABLE OF zwmdt003,
         lt_004  TYPE STANDARD TABLE OF zwmdt004,
         lv_flag.

  lt_ltap[] = gt_ltap[].
  lt_003[] = gt_003[].
  lt_004[] = gt_004[].

  CASE 'X'.
    WHEN radio1.
      SORT lt_ltap BY ename.
      DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING ename.
      IF lt_ltap[] IS NOT INITIAL.
        SELECT *
          FROM usr21
          INTO CORRESPONDING FIELDS OF TABLE gt_usr21
          FOR ALL ENTRIES IN lt_ltap
          WHERE bname = lt_ltap-ename.
        ENDIF.
      WHEN radio2.
        SORT lt_ltap BY qname.
        DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname.
        IF lt_ltap[] IS NOT INITIAL.
          SELECT *
            FROM usr21
            INTO CORRESPONDING FIELDS OF TABLE gt_usr21
            FOR ALL ENTRIES IN lt_ltap
            WHERE bname = lt_ltap-qname.
          ENDIF.
        WHEN radio3.
          SORT lt_ltap BY qname.
          DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname.
          IF lt_ltap[] IS NOT INITIAL.
            SELECT *
              FROM usr21
              INTO CORRESPONDING FIELDS OF TABLE gt_usr21
              FOR ALL ENTRIES IN lt_ltap
              WHERE bname = lt_ltap-qname.
            ENDIF.
          WHEN radio4.
            SORT lt_003 BY ernam.
            DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING ernam.
            IF lt_003[] IS NOT INITIAL.
              SELECT *
                FROM usr21
                INTO CORRESPONDING FIELDS OF TABLE gt_usr21
                FOR ALL ENTRIES IN lt_003
                WHERE bname = lt_003-ernam.
              ENDIF.
            WHEN radio5.
              SORT lt_004 BY znmuld.
              DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING znmuld.
              IF lt_004[] IS NOT INITIAL.
                SELECT *
                  FROM usr21
                  INTO CORRESPONDING FIELDS OF TABLE gt_usr21
                  FOR ALL ENTRIES IN lt_004
                  WHERE bname = lt_004-znmuld.
                ENDIF.
            ENDCASE.


            IF gt_usr21[] IS NOT INITIAL.
              SELECT *
                FROM adrp
                INTO CORRESPONDING FIELDS OF TABLE gt_adrp
                FOR ALL ENTRIES IN gt_usr21
                WHERE persnumber = gt_usr21-persnumber.
              ENDIF.
ENDFORM.                    " F_GET_FULL_NAME

*&---------------------------------------------------------------------*
*&      Form  F_GET_USER_NAME
*&---------------------------------------------------------------------*
FORM f_get_user_name  USING    fu_fs fu_ename.
  DATA : ls_usr21 LIKE LINE OF gt_usr21,
         ls_adrp  LIKE LINE OF gt_adrp.

  CLEAR ls_usr21.
  READ TABLE gt_usr21 INTO ls_usr21
                      WITH KEY bname = fu_ename.
  IF sy-subrc = 0.
    CLEAR ls_adrp.
    READ TABLE gt_adrp INTO ls_adrp
                       WITH KEY persnumber = ls_usr21-persnumber.
    IF sy-subrc = 0.
      CASE fu_fs.
        WHEN 'LTTAB'.
          PERFORM f_assign_field USING 'NAME' <fs_lttab> ls_adrp-name_text.
        WHEN 'LUTAB'.
          PERFORM f_assign_field USING 'NAME' <fs_lutab> ls_adrp-name_text.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_USER_NAME

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ITEMS
*&---------------------------------------------------------------------*
FORM f_process_items .
  DATA : lv_datum     TYPE sy-datum.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_items_picking_calc.
    WHEN radio2.
      PERFORM f_items_putaway_calc.
    WHEN radio3.
      PERFORM f_items_transfer_calc.
    WHEN radio4.
      PERFORM f_items_chkout_calc.
    WHEN radio5.
      PERFORM f_items_chkin_calc.
  ENDCASE.

  PERFORM f_display_modify USING 'UNAME' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ITEMS_PICKING_CALC
*&---------------------------------------------------------------------*
FORM f_items_picking_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lt_xlips         TYPE STANDARD TABLE OF lips,
         ls_xlips         LIKE LINE OF lt_xlips,
         lv_fieldname(30).

  TYPES: BEGIN OF ty_mat,
           ename TYPE ltap-ename,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.


  SORT gt_ltap BY ename tanum edatu.
  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename vbeln.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY ename vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING ename vbeln.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY ename.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING ename.
  lt_xlips[] = gt_lips[].
  SORT lt_xlips BY vbeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vbeln matnr.

  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  CLEAR: temp_lznum.
  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-ename.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-ename.

*    LOOP AT lt_yltap INTO ls_yltap WHERE ename = ls_xltap-ename.
*      CONCATENATE 'TO' ls_yltap-edatu INTO lv_fieldname.
*      CONDENSE lv_fieldname NO-GAPS.
*      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
*      LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_yltap-vbeln.
*        ADD 1 TO <fs>.
*      ENDLOOP.
*    ENDLOOP.
    LOOP AT lt_zltap INTO DATA(ls_zltap) WHERE ename = ls_xltap-ename.
      CONCATENATE 'TO' ls_zltap-edatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      ADD 1 TO <fs>.
      IF pa_lgnum = 'C40'.
        READ TABLE lt_ltak INTO DATA(ls_ltak) WITH KEY tanum = ls_zltap-tanum.
        IF sy-subrc = 0.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap BY ename matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm,
            temp_ename TYPE ltap-ename.
      LOOP AT lt_ltap INTO DATA(ls_ltap) WHERE ename = ls_xltap-ename.
        IF temp_matnr = ls_ltap-matnr AND temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          CLEAR: temp_nistm.
*          temp_matnr = ls_ltap-matnr.
**          temp_ename = ls_ltap-ename.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ELSE.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          temp_ename = ls_ltap-ename.
          ADD ls_ltap-nistm TO temp_nistm.
          wa_mat-nistm = temp_nistm.
          wa_mat-ename = ls_ltap-ename.
          wa_mat-matnr = ls_ltap-matnr.
*          ADD ls_ltap-nistm TO temp_nistm.
*          wa_mat-nistm = temp_nistm.
        ENDIF.
*        wa_mat-ename = ls_ltap-ename.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.

*      LOOP AT lt_ltap INTO DATA(ls_ltap).
*        IF temp_matnr <> ls_ltap-matnr.
*          CLEAR: temp_nistm.
*          temp_matnr = ls_ltap-matnr.
*          ADD ls_ltap-nistm TO temp_nistm.
*        ELSE.
*          ADD ls_ltap-nistm TO temp_nistm.
*        ENDIF.
*        wa_mat-matnr = ls_ltap-matnr.
*        wa_mat-nistm = temp_nistm.
*        APPEND wa_mat TO it_mat.
*      ENDLOOP.

      SORT it_mat DESCENDING BY ename matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING ename matnr.
      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat WHERE ename = ls_xltap-ename.
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
          IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
            lv_mod    = wa_mat-nistm MOD lv_umrez.
            lv_div    = wa_mat-nistm DIV lv_umrez.
            ADD lv_div TO lv_carton.
            ADD lv_mod TO lv_ecer.
          ENDIF.
        ENDLOOP.
        lv_fieldname = 'TOTAL_CARTON'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_carton.
        lv_fieldname = 'TOTAL_ECER'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_ecer.
      ENDIF.
      APPEND <fs_lutab> TO <fs_utab>.
      CLEAR <fs_lutab>.
    ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ITEMS_PUTAWAY_CALC
*&---------------------------------------------------------------------*
FORM f_items_putaway_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lt_xlips         TYPE STANDARD TABLE OF lips,
         ls_xlips         LIKE LINE OF lt_xlips,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum qdatu.
  lt_yltap[] = gt_ltap[].
  IF pa_lgnum = 'C40'.
    SORT lt_yltap BY qname vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vlpla.
    DATA(lt_ltap) = gt_ltap[].
    SORT lt_ltap BY qname tanum.
    DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING qname tanum.
  ELSE.
    SORT lt_yltap BY qname vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vbeln.
  ENDIF.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.
  lt_xlips[] = gt_lips[].
  SORT lt_xlips BY vbeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vbeln matnr.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    IF pa_lgnum = 'C40'.
      LOOP AT lt_ltap INTO DATA(ls_ltap2) WHERE qname = ls_xltap-qname.
        LOOP AT gt_ltap INTO DATA(gs_ltap) WHERE tanum = ls_ltap2-tanum AND qdatu = ls_ltap2-qdatu.
          CONCATENATE 'TO' ls_ltap2-qdatu INTO lv_fieldname.
          CONDENSE lv_fieldname NO-GAPS.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
          ADD 1 TO <fs>.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
        CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
        CONDENSE lv_fieldname NO-GAPS.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_yltap-vbeln.
          ADD 1 TO <fs>.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ITEMS_TRANSFER_CALC
*&---------------------------------------------------------------------*
FORM f_items_transfer_calc .
  DATA : lt_xltap         TYPE STANDARD TABLE OF ltap,
         ls_xltap         LIKE LINE OF lt_xltap,
         lt_yltap         TYPE STANDARD TABLE OF ltap,
         ls_yltap         LIKE LINE OF lt_yltap,
         lt_xlips         TYPE STANDARD TABLE OF lips,
         ls_xlips         LIKE LINE OF lt_xlips,
         lv_fieldname(30).

  SORT gt_ltap BY qname tanum qdatu.
  lt_yltap[] = gt_ltap[].
  SORT lt_yltap BY qname vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING qname vbeln.
  lt_xltap[] = lt_yltap[].
  SORT lt_xltap BY qname.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING qname.
  lt_xlips[] = gt_lips[].
  SORT lt_xlips BY vbeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vbeln matnr.

  LOOP AT lt_xltap INTO ls_xltap.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_xltap-qname.
    PERFORM f_get_user_name USING 'LUTAB' ls_xltap-qname.

    LOOP AT lt_yltap INTO ls_yltap WHERE qname = ls_xltap-qname.
      CONCATENATE 'TO' ls_yltap-qdatu INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_yltap-vbeln.
        ADD 1 TO <fs>.
      ENDLOOP.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ITEMS_CHKOUT_CALC
*&---------------------------------------------------------------------*
FORM f_items_chkout_calc .
  DATA : lt_x003          TYPE STANDARD TABLE OF zwmdt003,
         ls_x003          LIKE LINE OF lt_x003,
         lt_y003          TYPE STANDARD TABLE OF zwmdt003,
         ls_y003          LIKE LINE OF lt_y003,
         lt_zltap         TYPE STANDARD TABLE OF ltap,
         lt_xlips         TYPE STANDARD TABLE OF lips,
         ls_xlips         LIKE LINE OF lt_xlips,
         lv_fieldname(30).

  TYPES: BEGIN OF ty_mat,
           matnr TYPE ltap-matnr,
           nistm TYPE ltap-nistm,
           count TYPE i,
         END OF ty_mat.

  DATA: it_mat TYPE TABLE OF ty_mat,
        wa_mat TYPE ty_mat.

  DATA: lv_carton TYPE i,
        lv_ecer   TYPE i,
        lv_mod    TYPE p DECIMALS 0,
        lv_div    TYPE p DECIMALS 0,
        lv_umrez  TYPE marm-umrez.


  SORT gt_ltap BY ename tanum edatu.

  lt_zltap[] = gt_ltap[].
  SORT lt_zltap BY ename tanum.

  SORT gt_003 BY ernam tknum dalbg.
  lt_y003[] = gt_003[].
  SORT lt_y003 BY ernam vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_y003 COMPARING ernam vbeln.
  lt_x003[] = lt_y003[].
  SORT lt_x003 BY ernam.
  DELETE ADJACENT DUPLICATES FROM lt_x003 COMPARING ernam.
  lt_xlips[] = gt_lips[].
  SORT lt_xlips BY vbeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vbeln matnr.

  DATA(lt_ltak) = gt_ltak[].
  SORT lt_ltak DESCENDING BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lznum.
  DATA: temp_lznum TYPE ltak-lznum.
  LOOP AT lt_x003 INTO ls_x003.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x003-ernam.
    PERFORM f_get_user_name USING 'LUTAB' ls_x003-ernam.

    LOOP AT lt_y003 INTO ls_y003 WHERE ernam = ls_x003-ernam.
      CONCATENATE 'TO' ls_y003-dalbg INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_y003-vbeln.
        ADD 1 TO <fs>.
      ENDLOOP.
      IF pa_lgnum = 'C40'.
        LOOP AT lt_ltak INTO DATA(ls_ltak) WHERE vbeln = ls_y003-vbeln.
          IF ls_ltak-lznum = space.
            CONTINUE.
          ELSE.
            IF temp_lznum <> ls_ltak-lznum.
              temp_lznum = ls_ltak-lznum.
              lv_fieldname = 'TOTAL_TO_GROUP'.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
              ADD 1 TO <fs>.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    IF pa_lgnum = 'C40'.
      DATA(lt_ltap) = lt_zltap[].
      SORT lt_ltap BY matnr.
      DATA: temp_matnr TYPE ltap-matnr,
            temp_nistm TYPE ltap-nistm.
      LOOP AT lt_ltap INTO DATA(ls_ltap).
        IF temp_matnr <> ls_ltap-matnr.
          CLEAR: temp_nistm.
          temp_matnr = ls_ltap-matnr.
          ADD ls_ltap-nistm TO temp_nistm.
        ELSE.
          ADD ls_ltap-nistm TO temp_nistm.
        ENDIF.
        wa_mat-matnr = ls_ltap-matnr.
        wa_mat-nistm = temp_nistm.
        APPEND wa_mat TO it_mat.
      ENDLOOP.

      SORT it_mat DESCENDING BY matnr nistm.
      DELETE ADJACENT DUPLICATES FROM it_mat COMPARING matnr.
      CLEAR: lv_carton, lv_ecer.
      LOOP AT it_mat INTO wa_mat.
        CLEAR : lv_umrez, lv_mod, lv_div.
        SELECT SINGLE umrez
          FROM marm
          INTO lv_umrez
          WHERE matnr = wa_mat-matnr
            AND meinh = 'KAR'.
          IF sy-subrc = 0.
*        CLEAR : lv_mod, lv_div, lv_carton, lv_ecer.
            lv_mod    = wa_mat-nistm MOD lv_umrez.
            lv_div    = wa_mat-nistm DIV lv_umrez.
            ADD lv_div TO lv_carton.
            ADD lv_mod TO lv_ecer.
          ENDIF.
        ENDLOOP.
        lv_fieldname = 'TOTAL_CARTON'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_carton.
        lv_fieldname = 'TOTAL_ECER'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
        <fs> = lv_ecer.
      ENDIF.
      APPEND <fs_lutab> TO <fs_utab>.
      CLEAR <fs_lutab>.
    ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ITEMS_CHKIN_CALC
*&---------------------------------------------------------------------*
FORM f_items_chkin_calc .
  DATA : lt_x004          TYPE STANDARD TABLE OF zwmdt004,
         ls_x004          LIKE LINE OF lt_x004,
         lt_y004          TYPE STANDARD TABLE OF zwmdt004,
         ls_y004          LIKE LINE OF lt_y004,
         lt_xlips         TYPE STANDARD TABLE OF lips,
         ls_xlips         LIKE LINE OF lt_xlips,
         lv_fieldname(30).

  SORT gt_004 BY znmuld tanum zdtsul.
  lt_y004[] = gt_004[].
  SORT lt_y004 BY znmuld vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_y004 COMPARING znmuld vbeln.
  lt_x004[] = lt_y004[].
  SORT lt_x004 BY znmuld.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING znmuld.
  lt_xlips[] = gt_lips[].
  SORT lt_xlips BY vbeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vbeln matnr.

  LOOP AT lt_x004 INTO ls_x004.
    PERFORM f_assign_field USING 'UNAME' <fs_lutab> ls_x004-znmuld.
    PERFORM f_get_user_name USING 'LUTAB' ls_x004-znmuld.

    LOOP AT lt_y004 INTO ls_y004 WHERE znmuld = ls_x004-znmuld.
      CONCATENATE 'TO' ls_y004-zdtsul INTO lv_fieldname.
      CONDENSE lv_fieldname NO-GAPS.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lutab> TO <fs>.
      LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_y004-vbeln.
        ADD 1 TO <fs>.
      ENDLOOP.
    ENDLOOP.
    APPEND <fs_lutab> TO <fs_utab>.
    CLEAR <fs_lutab>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_STATUS_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_status_do .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp FROM likp
    WHERE vstel = pa_vstel
    AND vbeln IN so_vbeln
    AND lfart = 'LF'
    AND erdat IN so_datum.

*  IF gt_likp[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltap FROM ltap
*      FOR ALL ENTRIES IN gt_likp
*      WHERE nlpla = gt_likp-vbeln
*      AND pvqui = 'X'
**      AND edatu = gt_likp-erdat
*      AND lgnum = pa_lgnum.
*
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp2 FROM likp
*      FOR ALL ENTRIES IN gt_likp
*      WHERE wadat_ist <> '00000000'
*      AND vbeln = gt_likp-vbeln.
*
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttp FROM vttp
*      FOR ALL ENTRIES IN gt_likp
*      WHERE vbeln = gt_likp-vbeln.
*  ENDIF.



    IF gt_likp[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_lips FROM lips
        FOR ALL ENTRIES IN gt_likp
        WHERE lgort = '1000'
        AND vbeln = gt_likp-vbeln
        AND erdat = gt_likp-erdat.

        SORT gt_lips[] BY vbeln.
        DELETE ADJACENT DUPLICATES FROM gt_lips[] COMPARING vbeln.

        IF gt_lips[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltak FROM ltak
            FOR ALL ENTRIES IN gt_lips
            WHERE vbeln = gt_lips-vbeln.

            IF gt_ltak[] IS NOT INITIAL.
              SORT gt_ltak DESCENDING BY vbeln bwlvs.
              DATA: temp_vbeln TYPE ltak-vbeln.
              LOOP AT gt_ltak INTO DATA(gs_ltak).
                IF temp_vbeln <> gs_ltak-vbeln.
                  temp_vbeln = gs_ltak-vbeln.
                ELSE.
                  IF gs_ltak-bwlvs = '999'.
                    DELETE gt_ltak WHERE vbeln = gs_ltak-vbeln.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltap FROM ltap
              FOR ALL ENTRIES IN gt_ltak
              WHERE nlpla = gt_ltak-vbeln
              AND pvqui = 'X'
              AND vorga <> 'ST'
              AND vorga <> 'SL'
*      AND edatu = gt_likp-erdat
              AND lgnum = pa_lgnum.
              ENDIF.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltap FROM ltap
*        FOR ALL ENTRIES IN gt_lips
*        WHERE nlpla = gt_lips-vbeln
*        AND pvqui = 'X'
*        AND ( vorga NE 'ST' OR vorga NE 'SL' )
**      AND edatu = gt_likp-erdat
*        AND lgnum = pa_lgnum.

              SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp2 FROM likp
                FOR ALL ENTRIES IN gt_lips
                WHERE wadat_ist <> '00000000'
                AND vbeln = gt_lips-vbeln.

                SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttp FROM vttp
                  FOR ALL ENTRIES IN gt_lips
                  WHERE vbeln = gt_lips-vbeln.

                  IF gt_vttp[] IS NOT INITIAL.
                    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttk FROM vttk
                      FOR ALL ENTRIES IN gt_vttp
                      WHERE tknum = gt_vttp-tknum.
                    ENDIF.
                  ENDIF.
                ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_STATUS_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_status_do .
  DATA : lv_datum     TYPE sy-datum.

  PERFORM f_calculate_status_do.

  CLEAR : lv_datum.
  PERFORM f_display_modify_status_do USING 'STATUS_DO' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_STATUS_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_calculate_status_do .
  DATA: lt_xlips         TYPE STANDARD TABLE OF lips,
        ls_xlips         LIKE LINE OF lt_xlips,
        lt_ylips         TYPE STANDARD TABLE OF lips,
        ls_ylips         LIKE LINE OF lt_ylips,
        lt_ltap          TYPE STANDARD TABLE OF ltap,
        ls_ltap          LIKE LINE OF lt_ltap,
        lt_vttk          TYPE STANDARD TABLE OF vttk,
        ls_vttk          LIKE LINE OF lt_vttk,
        lv_fieldname(30).

  lt_vttk[] = gt_vttk[].

  SORT gt_lips[] BY erdat vbeln.
  lt_xlips[] = gt_lips[].
  DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING erdat.
  lt_ylips[] = gt_lips[].

  SORT gt_ltap[] BY nlpla edatu.
  lt_ltap[] = gt_ltap[].
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING nlpla.

  DATA(lt_vttp) = gt_vttp[].
  SORT lt_vttp BY tknum erdat.
  DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING vbeln."tknum.

  LOOP AT lt_xlips INTO ls_xlips.
    CONCATENATE ls_xlips-erdat+6(2) '.' ls_xlips-erdat+4(2) '.' ls_xlips-erdat(4) INTO DATA(date).
    PERFORM f_assign_field USING 'TANGGAL' <fs_lsdo> date.
    LOOP AT lt_ylips INTO ls_ylips WHERE erdat = ls_xlips-erdat.
      lv_fieldname = 'TOTAL_DO'.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
      ADD 1 TO <fs>.
      LOOP AT lt_ltap INTO ls_ltap WHERE nlpla = ls_ylips-vbeln. "edatu = ls_ylikp-erdat AND
        lv_fieldname = 'TOTAL_PICKING'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
        ADD 1 TO <fs>.
      ENDLOOP.
      LOOP AT gt_likp2 INTO DATA(ls_likp2) WHERE vbeln = ls_ylips-vbeln.
        lv_fieldname = 'TOTAL_GI'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
        ADD 1 TO <fs>.
      ENDLOOP.
      LOOP AT lt_vttp INTO DATA(ls_vttp) WHERE vbeln = ls_ylips-vbeln.
        lv_fieldname = 'TOTAL_SHIPMENT'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
        ADD 1 TO <fs>.
*        Added start shipment
        READ TABLE lt_vttk INTO ls_vttk WITH KEY tknum = ls_vttp-tknum.
        IF sy-subrc = 0.
*          CONCATENATE ls_vttk-datbg+6(2) '.' ls_vttk-datbg+4(2) '.' ls_vttk-datbg(4) INTO DATA(start_shipment).
*          PERFORM f_assign_field USING 'START_SHIPMENT' <fs_lsdo> start_shipment.
          IF ls_vttk-datbg IS NOT INITIAL.
            lv_fieldname = 'START_SHIPMENT'.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
            ADD 1 TO <fs>.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    APPEND <fs_lsdo> TO <fs_sdo>.
    CLEAR: <fs_lsdo>.
  ENDLOOP.

*  DATA: lt_xlikp         TYPE STANDARD TABLE OF likp,
*        ls_xlikp         LIKE LINE OF lt_xlikp,
*        lt_ylikp         TYPE STANDARD TABLE OF likp,
*        ls_ylikp         LIKE LINE OF lt_ylikp,
*        lt_ltap          TYPE STANDARD TABLE OF ltap,
*        ls_ltap          LIKE LINE OF lt_ltap,
*        lv_fieldname(30).
*
*  SORT gt_likp[] BY erdat vbeln.
*  lt_xlikp[] = gt_likp[].
*  DELETE ADJACENT DUPLICATES FROM lt_xlikp COMPARING erdat.
*  lt_ylikp[] = gt_likp[].
*
*  SORT gt_ltap[] BY nlpla edatu.
*  lt_ltap[] = gt_ltap[].
*  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING nlpla.
*
*  DATA(lt_vttp) = gt_vttp[].
*  SORT lt_vttp BY tknum erdat.
*  DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING vbeln."tknum.
*
*  LOOP AT lt_xlikp INTO ls_xlikp.
*    CONCATENATE ls_xlikp-erdat+6(2) '.' ls_xlikp-erdat+4(2) '.' ls_xlikp-erdat(4) INTO DATA(date).
*    PERFORM f_assign_field USING 'TANGGAL' <fs_lsdo> date.
*    LOOP AT lt_ylikp INTO ls_ylikp WHERE erdat = ls_xlikp-erdat.
*      lv_fieldname = 'TOTAL_DO'.
*      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
*      ADD 1 TO <fs>.
*      LOOP AT lt_ltap INTO ls_ltap WHERE nlpla = ls_ylikp-vbeln. "edatu = ls_ylikp-erdat AND
*        lv_fieldname = 'TOTAL_PICKING'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
*      LOOP AT gt_likp2 INTO DATA(ls_likp2) WHERE vbeln = ls_ylikp-vbeln.
*        lv_fieldname = 'TOTAL_GI'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
*      LOOP AT lt_vttp INTO DATA(ls_vttp) WHERE vbeln = ls_ylikp-vbeln.
*        lv_fieldname = 'TOTAL_SHIPMENT'.
*        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_lsdo> TO <fs>.
*        ADD 1 TO <fs>.
*      ENDLOOP.
*    ENDLOOP.
*    APPEND <fs_lsdo> TO <fs_sdo>.
*    CLEAR: <fs_lsdo>.
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MODIFY_STATUS_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4661   text
*      -->P_4662   text
*      <--P_LV_DATUM  text
*----------------------------------------------------------------------*
FORM f_display_modify_status_do  USING    fu_fieldname fu_time
                      CHANGING fc_datum.
  DATA : lv_value(15),
         lv_xvalue(15),
         lv_int                         TYPE p DECIMALS 0,
         lv_xint                        TYPE p DECIMALS 0,
         lv_fieldname(30),
         lv_uname                       TYPE sy-uname,
         lv_name                        TYPE adrp-name_text,
         lv_tot_to                      TYPE i,
         lv_tot_car                     TYPE i,
         lv_tot_ec                      TYPE i,
         lv_ktext                       TYPE t151t-ktext,
         lv_datum                       TYPE sy-datum,
         ls_holidays                    LIKE LINE OF holidays,
         lv_color,
         lv_total                       TYPE p DECIMALS 0,
         lv_average                     TYPE p DECIMALS 2,
         lv_percent_do_picking          TYPE p DECIMALS 0,
         lv_sum_percent_do_picking      TYPE p DECIMALS 0,
         lv_percent_gi_do               TYPE p DECIMALS 0,
         lv_sum_percent_gi_do           TYPE p DECIMALS 0,
         lv_percent_shipment_do         TYPE p DECIMALS 0,
         lv_sum_percent_shipment_do     TYPE p DECIMALS 0,
         lv_percent_str_shipment_do     TYPE p DECIMALS 0,
         lv_sum_percent_str_shipment_do TYPE p DECIMALS 0,
         lv_ctotal(15),
         lv_cavrge(15).

  DATA: lv_total_do                   TYPE i,
        lv_total_picking              TYPE i,
        lv_percent_do_picking_string  TYPE string,
        lv_sum_total_do               TYPE i,
        lv_sum_total_picking          TYPE i,
        lv_sum_percent_do_picking_str TYPE string.


  DATA: lv_total_gi                    TYPE i,
        lv_total_shipment              TYPE i,
        lv_sum_total_gi                TYPE i,
        lv_sum_total_shipment          TYPE i,
        lv_percent_gi_do_string        TYPE string,
        lv_percent_shipment_do_string  TYPE string,
        lv_sum_percent_gi_do_str       TYPE string,
        lv_sum_percent_shipment_do_str TYPE string.

  DATA:lv_total_start_shipment       TYPE i,
       lv_sum_total_start_shipment   TYPE i,
       percent_str_shipment_do_s     TYPE string,
       sum_percent_str_shipment_do_s TYPE string.

  CLEAR: lv_percent_do_picking_string, lv_sum_total_do, lv_sum_total_picking, lv_sum_percent_do_picking_str.
  CASE fu_fieldname.
    WHEN 'STATUS_DO'.
      LOOP AT <fs_sdo> INTO <fs_lsdo>.
*        Added start shipment
        ASSIGN COMPONENT 'START_SHIPMENT' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'START_SHIPMENT' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.
        lv_total_start_shipment = <fs1>.
        ADD lv_total_start_shipment TO lv_sum_total_start_shipment.

        ASSIGN COMPONENT 'TANGGAL' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'TANGGAL' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.

        ASSIGN COMPONENT 'TOTAL_DO' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'TOTAL_DO' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.
        lv_total_do = <fs1>.
        ADD lv_total_do TO lv_sum_total_do.

        ASSIGN COMPONENT 'TOTAL_PICKING' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'TOTAL_PICKING' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.
        lv_total_picking = <fs1>.
        ADD lv_total_picking TO lv_sum_total_picking.
        TRY .
            lv_percent_do_picking  = ( lv_total_picking / lv_total_do  ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        lv_percent_do_picking_string = lv_percent_do_picking.
        CONCATENATE lv_percent_do_picking_string '%' INTO lv_percent_do_picking_string.
        PERFORM f_assign_field USING 'PICK_DO' <fs_lsdo2> lv_percent_do_picking_string.

        ASSIGN COMPONENT 'TOTAL_GI' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'TOTAL_GI' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.
        lv_total_gi = <fs1>.
        ADD lv_total_gi TO lv_sum_total_gi.

        ASSIGN COMPONENT 'TOTAL_SHIPMENT' OF STRUCTURE <fs_lsdo> TO <fs>.
        lv_name = <fs>.
        ASSIGN COMPONENT 'TOTAL_SHIPMENT' OF STRUCTURE <fs_lsdo2> TO <fs1>.
        <fs1> = lv_name.
        lv_total_shipment = <fs1>.
        ADD lv_total_shipment TO lv_sum_total_shipment.

        TRY .
            lv_percent_gi_do  = ( lv_total_gi / lv_total_do  ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        lv_percent_gi_do_string = lv_percent_gi_do.
        CONCATENATE lv_percent_gi_do_string '%' INTO lv_percent_gi_do_string.
        PERFORM f_assign_field USING 'GI_DO' <fs_lsdo2> lv_percent_gi_do_string.


        TRY .
            lv_percent_shipment_do  = ( lv_total_shipment / lv_total_do  ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        lv_percent_shipment_do_string = lv_percent_shipment_do.
        CONCATENATE lv_percent_shipment_do_string '%' INTO lv_percent_shipment_do_string.
        PERFORM f_assign_field USING 'SHIPMENT_DO' <fs_lsdo2> lv_percent_shipment_do_string.

        TRY .
            lv_percent_str_shipment_do  = ( lv_total_start_shipment / lv_total_do  ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        percent_str_shipment_do_s = lv_percent_str_shipment_do.
        CONCATENATE percent_str_shipment_do_s '%' INTO percent_str_shipment_do_s.
        PERFORM f_assign_field USING 'START_SHIPMENT_DO' <fs_lsdo2> percent_str_shipment_do_s.

        APPEND <fs_lsdo2> TO <fs_sdo2>.
        CLEAR: <fs_lsdo>.
      ENDLOOP.
      PERFORM f_assign_field USING 'TANGGAL' <fs_lsdo2> 'Total'.
      PERFORM f_assign_field USING 'TOTAL_DO' <fs_lsdo2> lv_sum_total_do.
      PERFORM f_assign_field USING 'TOTAL_PICKING' <fs_lsdo2> lv_sum_total_picking.
      TRY .
          lv_sum_percent_do_picking  = ( lv_sum_total_picking / lv_sum_total_do  ) * 100.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      lv_sum_percent_do_picking_str =  lv_sum_percent_do_picking.
      CONCATENATE lv_sum_percent_do_picking_str '%' INTO lv_sum_percent_do_picking_str.
      PERFORM f_assign_field USING 'PICK_DO' <fs_lsdo2> lv_sum_percent_do_picking_str.

      PERFORM f_assign_field USING 'TOTAL_GI' <fs_lsdo2> lv_sum_total_gi.
      PERFORM f_assign_field USING 'TOTAL_SHIPMENT' <fs_lsdo2> lv_sum_total_shipment.

      TRY .
          lv_sum_percent_gi_do  = ( lv_sum_total_gi / lv_sum_total_do  ) * 100.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      lv_sum_percent_gi_do_str =  lv_sum_percent_gi_do.
      CONCATENATE lv_sum_percent_gi_do_str '%' INTO lv_sum_percent_gi_do_str.
      PERFORM f_assign_field USING 'GI_DO' <fs_lsdo2> lv_sum_percent_gi_do_str.

      TRY .
          lv_sum_percent_shipment_do  = ( lv_sum_total_shipment / lv_sum_total_do  ) * 100.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      lv_sum_percent_shipment_do_str =  lv_sum_percent_shipment_do.
      CONCATENATE lv_sum_percent_shipment_do_str '%' INTO lv_sum_percent_shipment_do_str.
      PERFORM f_assign_field USING 'SHIPMENT_DO' <fs_lsdo2> lv_sum_percent_shipment_do_str.

      PERFORM f_assign_field USING 'START_SHIPMENT' <fs_lsdo2> lv_sum_total_start_shipment.
      TRY .
          lv_sum_percent_str_shipment_do  = ( lv_sum_total_start_shipment / lv_sum_total_do  ) * 100.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      sum_percent_str_shipment_do_s =  lv_sum_percent_str_shipment_do.
      CONCATENATE sum_percent_str_shipment_do_s '%' INTO sum_percent_str_shipment_do_s.
      PERFORM f_assign_field USING 'START_SHIPMENT_DO' <fs_lsdo2> sum_percent_str_shipment_do_s.
      APPEND <fs_lsdo2> TO <fs_sdo2>.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_MONITORING_PICKING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_monitoring_picking .
  DATA: ls_t333  TYPE t333,
        ls_t340d TYPE t340d,
        ls_t334t TYPE t334t.
  DATA: ls_mlvs TYPE mlvs.
  DATA: ls_mgef TYPE mgef.
  DATA: ls_vorga TYPE vorga.
  DATA: ls_ausml TYPE rl03t-ausml.
  DATA: lv_ausme TYPE rl03t-ausme.
  DATA:  iltapa TYPE STANDARD TABLE OF ltapa.
  DATA:    weiter_nach_mwmto008    TYPE c.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_t333 FROM t333
  WHERE lgnum = pa_lgnum
    AND bwlvs = '601'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_t340d FROM t340d
      WHERE lgnum = pa_lgnum.

*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttk FROM vttk
*    WHERE tplst = pa_vstel
*    AND tknum IN so_tknum
*    AND erdat IN so_datum.
*
*  IF gt_vttk[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttp FROM vttp
*      FOR ALL ENTRIES IN gt_vttk
*      WHERE tknum = gt_vttk-tknum.
*  ENDIF.
*
*  IF gt_vttp[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltak FROM ltak
*      FOR ALL ENTRIES IN gt_vttp
*      WHERE vbeln = gt_vttp-vbeln
*      AND lgnum = pa_lgnum.
*  ENDIF.
*
*  IF gt_ltak[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltap FROM ltap
*      FOR ALL ENTRIES IN gt_ltak
*      WHERE tanum = gt_ltak-tanum
*      AND lgnum = gt_ltak-lgnum.
*
*  ENDIF.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltak FROM ltak
        WHERE bdatu IN so_datum
        AND lgnum = pa_lgnum
        AND bwart = '601'.

        IF gt_ltak[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttp FROM vttp
            FOR ALL ENTRIES IN gt_ltak
            WHERE vbeln = gt_ltak-vbeln
            AND tknum IN so_tknum
            AND erdat = gt_ltak-bdatu.
          ENDIF.

          IF gt_vttp[] IS NOT INITIAL.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ltap FROM ltap
                FOR ALL ENTRIES IN gt_vttp
                WHERE nlpla = gt_vttp-vbeln.

              SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttk FROM vttk
                FOR ALL ENTRIES IN gt_vttp
                WHERE tknum = gt_vttp-tknum.
*      AND datbg IN so_datum.

                LOOP AT gt_ltak INTO DATA(ls_ltak).
                  READ TABLE gt_vttp INTO DATA(ls_vttp) WITH KEY vbeln = ls_ltak-vbeln.
                  IF sy-subrc <> 0.
                    DELETE gt_ltak WHERE vbeln = ls_ltak-vbeln.
                  ENDIF.
                ENDLOOP.

              ENDIF.




              DATA: gt_ltap_vb TYPE TABLE OF ltap_vb.
              gt_ltap_vb[] = gt_ltap[].
              DATA: ltap_queue TYPE TABLE OF ltap_qu.
              DATA: wm_queue TYPE REF TO zcl_im_le_wm_rf_queue.
              wm_queue = NEW #( ).
              wm_queue->if_ex_le_wm_rf_queue~queue_determination(
              EXPORTING
                it_tap = gt_ltap_vb[]
              IMPORTING
                et_ltap_qu = ltap_queue[]
                ).


              LOOP AT gt_ltap INTO DATA(ls_ltap).
                ls_check_pick-tanum = ls_ltap-tanum.
                ls_check_pick-vbeln = ls_ltap-vbeln.
                ls_check_pick-lgnum = ls_ltap-lgnum.
                ls_check_pick-pvqui = ls_ltap-pvqui.
                READ TABLE gt_vttp INTO ls_vttp WITH KEY vbeln = ls_ltap-vbeln.
                IF sy-subrc = 0.
                  ls_check_pick-tknum = ls_vttp-tknum.
                  ls_check_pick-erdat = ls_vttp-erdat.
                ENDIF.
                APPEND ls_check_pick TO gt_check_pick.
              ENDLOOP.
              LOOP AT ltap_queue INTO DATA(ls_ltap_queue).
                ls_check_pick-queue = ls_ltap_queue-queue.
                MODIFY gt_check_pick FROM ls_check_pick INDEX sy-tabix TRANSPORTING queue.
              ENDLOOP.

              SORT gt_ltak[] BY lznum.
              LOOP AT gt_ltak INTO ls_ltak.
                READ TABLE gt_check_pick INTO ls_check_pick WITH KEY tanum = ls_ltak-tanum.
                IF sy-subrc = 0.
                  ls_check_pick-lznum = ls_ltak-lznum.
                  ls_check_pick-kquit = ls_ltak-kquit.
                  MODIFY gt_check_pick FROM ls_check_pick TRANSPORTING lznum kquit WHERE tanum = ls_check_pick-tanum.
                ELSE.
                  DELETE gt_check_pick WHERE tanum = ls_check_pick-tanum.
                ENDIF.
              ENDLOOP.

*  LOOP AT gt_ltak INTO DATA(ls_ltak).
*    READ TABLE gt_ltap INTO DATA(ls_ltap) WITH KEY vbeln = ls_ltak-vbeln.
*    IF sy-subrc = 0.
**      CALL FUNCTION 'EXIT_SAPML03T_003'
**        EXPORTING
**          i_ltak  = ls_ltak
**          i_ltap  = ls_ltap "ls_ltap
**          i_mlvs  = ls_mlvs
**          i_mgef  = ls_mgef
**          i_t333  = ls_t333
**          i_t340d = ls_t340d
**          i_vorga = ls_vorga
**          i_ausml = ls_ausml
**          i_ausme = lv_ausme
**        TABLES
**          t_ltapa = iltapa
**        CHANGING
**          c_conti = weiter_nach_mwmto008
**          c_lgty0 = ls_t334t-lgty0
**          c_lgty1 = ls_t334t-lgty1
**          c_lgty2 = ls_t334t-lgty2
**          c_lgty3 = ls_t334t-lgty3
**          c_lgty4 = ls_t334t-lgty4
**          c_lgty5 = ls_t334t-lgty5
**          c_lgty6 = ls_t334t-lgty6
**          c_lgty7 = ls_t334t-lgty7
**          c_lgty8 = ls_t334t-lgty8
**          c_lgty9 = ls_t334t-lgty9
**          c_lgt10 = ls_t334t-lgt10
**          c_lgt11 = ls_t334t-lgt11
**          c_lgt12 = ls_t334t-lgt12
**          c_lgt13 = ls_t334t-lgt13
**          c_lgt14 = ls_t334t-lgt14
**          c_lgt15 = ls_t334t-lgt15
**          c_lgt16 = ls_t334t-lgt16
**          c_lgt17 = ls_t334t-lgt17
**          c_lgt18 = ls_t334t-lgt18
**          c_lgt19 = ls_t334t-lgt19
**          c_lgt20 = ls_t334t-lgt20
**          c_lgt21 = ls_t334t-lgt21
**          c_lgt22 = ls_t334t-lgt22
**          c_lgt23 = ls_t334t-lgt23
**          c_lgt24 = ls_t334t-lgt24
**          c_lgt25 = ls_t334t-lgt25
**          c_lgt26 = ls_t334t-lgt26
**          c_lgt27 = ls_t334t-lgt27
**          c_lgt28 = ls_t334t-lgt28
**          c_lgt29 = ls_t334t-lgt29.
**
**      IF ls_t334t IS NOT INITIAL.
**        ls_check_pick-lznum = ls_ltak-lznum.
**        ls_check_pick-tanum = ls_ltak-tanum.
**        ls_check_pick-vbeln = ls_ltak-vbeln.
**        ls_check_pick-lgnum = ls_ltap-lgnum.
**        ls_check_pick-queue = ls_ltak-queue.
**        ls_check_pick-kquit = ls_ltak-kquit.
**        ls_check_pick-pvqui = ls_ltap-pvqui.
**        ls_check_pick-status = 'Not yet picking'.
**      ELSE.
*      SELECT SINGLE queue INTO @DATA(lv_queue)
*        FROM mara JOIN zwmdt016 ON mara~matkl = zwmdt016~matkl
*        WHERE matnr = @ls_ltap-matnr.
*      ls_check_pick-lznum = ls_ltak-lznum.
*      ls_check_pick-tanum = ls_ltak-tanum.
*      ls_check_pick-vbeln = ls_ltak-vbeln.
*      ls_check_pick-lgnum = ls_ltap-lgnum.
*      ls_check_pick-queue = lv_queue.
*      ls_check_pick-kquit = ls_ltak-kquit.
*      ls_check_pick-pvqui = ls_ltap-pvqui.
**        ls_check_pick-status = 'Not yet picking'.
**      ENDIF.
*      APPEND ls_check_pick TO gt_check_pick.
*      CLEAR: ls_t334t.
*    ENDIF.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_MONITOR_PICKING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_monitor_picking .
  DATA : lv_datum     TYPE sy-datum.

  PERFORM f_calculate_monitor_pick.

  CLEAR : lv_datum.
  PERFORM f_display_modify_monitor_pick USING 'MONITOR_PICKING' ''
                           CHANGING lv_datum.

  CLEAR : g_tabgrid.
  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_MONITOR_PICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_calculate_monitor_pick .
  DATA: lt_vttp TYPE TABLE OF vttp,
        ls_vttp TYPE vttp,
        lt_vttk TYPE TABLE OF vttk,
        ls_vttk TYPE vttk.
  DATA: lv_status TYPE char30.
  CLEAR: <fs_mp>.

  lt_vttk = gt_vttk[].

  lt_vttp[] = gt_vttp[].
  SORT lt_vttp[] BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING tknum.

  DATA(lt_check_pick) = gt_check_pick[].
  SORT lt_check_pick[] BY kquit.
  SORT lt_check_pick[] DESCENDING BY tknum lznum.
*  DELETE lt_check_pick[] WHERE lznum = space.
  DELETE ADJACENT DUPLICATES FROM lt_check_pick COMPARING tknum lznum.
  LOOP AT lt_vttp INTO ls_vttp.
    PERFORM f_assign_field USING 'SHIPMENT' <fs_lmp> ls_vttp-tknum.
    CONCATENATE ls_vttp-erdat+6(2) '.' ls_vttp-erdat+4(2) '.' ls_vttp-erdat(4) INTO DATA(shipment_date).
    PERFORM f_assign_field USING 'SHIPMENT_DATE' <fs_lmp> shipment_date.
    READ TABLE lt_vttk INTO ls_vttk WITH KEY tknum = ls_vttp-tknum.
    IF sy-subrc = 0.
      CONCATENATE ls_vttk-datbg+6(2) '.' ls_vttk-datbg+4(2) '.' ls_vttk-datbg(4) INTO DATA(start_shipment).
      PERFORM f_assign_field USING 'START_SHIPMENT' <fs_lmp> start_shipment.
    ENDIF.
    LOOP AT lt_check_pick INTO DATA(ls_check_pick) WHERE tknum = ls_vttp-tknum.
      PERFORM f_check_picking USING ls_check_pick-tknum ls_check_pick-lznum lv_status.
      IF ls_check_pick-queue = 'LPICK'.
        PERFORM f_assign_field USING 'LPICK' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER1'.
        PERFORM f_assign_field USING 'PICKER1' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER2'.
        PERFORM f_assign_field USING 'PICKER2' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER3'.
        PERFORM f_assign_field USING 'PICKER3' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER4'.
        PERFORM f_assign_field USING 'PICKER4' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER5'.
        PERFORM f_assign_field USING 'PICKER5' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER6'.
        PERFORM f_assign_field USING 'PICKER6' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER7'.
        PERFORM f_assign_field USING 'PICKER7' <fs_lmp> lv_status.
      ELSEIF ls_check_pick-queue(7) = 'PICKER8'.
        PERFORM f_assign_field USING 'PICKER8' <fs_lmp> lv_status.
      ENDIF.
    ENDLOOP.

    APPEND <fs_lmp> TO <fs_mp>.
    CLEAR: <fs_lmp>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MODIFY_MONITOR_PICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5920   text
*      -->P_5921   text
*      <--P_LV_DATUM  text
*----------------------------------------------------------------------*
FORM f_display_modify_monitor_pick   USING    fu_fieldname fu_time
                      CHANGING fc_datum.
  DATA : lv_value(15),
         lv_xvalue(15),
         lv_int                     TYPE p DECIMALS 0,
         lv_xint                    TYPE p DECIMALS 0,
         lv_fieldname(30),
         lv_uname                   TYPE sy-uname,
         lv_name                    TYPE adrp-name_text,
         lv_tot_to                  TYPE i,
         lv_tot_car                 TYPE i,
         lv_tot_ec                  TYPE i,
         lv_ktext                   TYPE t151t-ktext,
         lv_datum                   TYPE sy-datum,
         ls_holidays                LIKE LINE OF holidays,
         lv_color,
         lv_total                   TYPE p DECIMALS 0,
         lv_average                 TYPE p DECIMALS 2,
         lv_percent_do_picking      TYPE p DECIMALS 0,
         lv_sum_percent_do_picking  TYPE p DECIMALS 0,
         lv_percent_gi_do           TYPE p DECIMALS 0,
         lv_sum_percent_gi_do       TYPE p DECIMALS 0,
         lv_percent_shipment_do     TYPE p DECIMALS 0,
         lv_sum_percent_shipment_do TYPE p DECIMALS 0,
         lv_ctotal(15),
         lv_cavrge(15).

  CLEAR: <fs_mp2>.

  LOOP AT <fs_mp> INTO <fs_lmp>.
    ASSIGN COMPONENT 'START_SHIPMENT' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'START_SHIPMENT' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'SHIPMENT_DATE' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'SHIPMENT_DATE' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'SHIPMENT' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'SHIPMENT' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'LPICK' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'LPICK' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER1' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER1' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER2' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER2' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER3' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER3' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER4' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER4' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER5' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER5' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER6' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER6' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER7' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER7' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    ASSIGN COMPONENT 'PICKER8' OF STRUCTURE <fs_lmp> TO <fs>.
    lv_name = <fs>.
    ASSIGN COMPONENT 'PICKER8' OF STRUCTURE <fs_lmp2> TO <fs1>.
    <fs1> = lv_name.

    APPEND <fs_lmp2> TO <fs_mp2>.
    CLEAR: <fs_lmp>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PICKING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_CHECK_PICK_LZNUM  text
*----------------------------------------------------------------------*
FORM f_check_picking  USING fu_tknum fu_lznum CHANGING fu_status.
  DATA(lt_check_pick) = gt_check_pick[].
  SORT lt_check_pick[] BY kquit.
  SORT lt_check_pick[] DESCENDING BY tknum lznum.
  DELETE lt_check_pick[] WHERE lznum = space.
  DELETE lt_check_pick WHERE lznum <> fu_lznum OR tknum <> fu_tknum.
  DESCRIBE TABLE lt_check_pick LINES DATA(lv_lines).

  DATA(flag) = '0'.
  LOOP AT lt_check_pick INTO ls_check_pick.
    IF ls_check_pick-kquit = 'X' AND sy-tabix = lv_lines.
      flag = '2'.
    ENDIF.
    IF ls_check_pick-kquit = 'X' AND sy-tabix <> lv_lines.
      flag = '1'.
    ELSE.
    ENDIF.
  ENDLOOP.
  IF flag = '1'.
    LOOP AT lt_check_pick INTO ls_check_pick.
      IF ls_check_pick-pvqui = space AND sy-tabix = lv_lines.
        flag = '0'.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF flag = '0'.
    fu_status = 'Not yet picking'.
  ELSEIF flag = '1'.
    fu_status = 'Picking on process'.
  ELSEIF flag = '2'.
    fu_status = 'Picking done'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_handle_double_click USING fu_row STRUCTURE lvc_s_row
                                 fu_col STRUCTURE lvc_s_col.
*  gv_process = 'DETL'.
*  PERFORM f_main_alv.
  CLEAR: <fs_detl>.
  DATA: lv_name TYPE adrp-name_text.
  DATA: dl_text(255) TYPE c.
  IF radio7 IS NOT INITIAL.
    DATA(lt_check_pick) = gt_check_pick[].
    SORT lt_check_pick BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_check_pick COMPARING vbeln lznum tanum.
    READ TABLE <fs_mp2> INDEX fu_row-index INTO <fs_lmp2>.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'SHIPMENT' OF STRUCTURE <fs_lmp2> TO <fs>.
      lv_name = <fs>.
      ASSIGN COMPONENT 'SHIPMENT' OF STRUCTURE <fs_ldetl> TO <fs1>.
      <fs1> = lv_name.
      LOOP AT lt_check_pick INTO DATA(ls_check_pick) WHERE tknum = <fs1>.
        PERFORM f_assign_field USING 'SHIPMENT' <fs_ldetl> ls_check_pick-tknum.
        PERFORM f_assign_field USING 'LZNUM' <fs_ldetl> ls_check_pick-lznum.
        PERFORM f_assign_field USING 'TANUM' <fs_ldetl> ls_check_pick-tanum.
        PERFORM f_assign_field USING 'VBELN' <fs_ldetl> ls_check_pick-vbeln.
        PERFORM f_assign_field USING 'DATUM' <fs_ldetl> ls_check_pick-erdat.
        APPEND <fs_ldetl> TO <fs_detl>.
        CLEAR: <fs_ldetl>.
      ENDLOOP.
    ENDIF.

    ASSIGN <fs_detl> TO <fs_out>.
    PERFORM f_change_fieldcat USING 'DETL'.
    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_out>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    CALL METHOD g_dyndoc_id->initialize_document.

    CALL METHOD g_tabgrid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = g_dyndoc_id.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CALC_TIMES_1_C40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_YLTAP  text
*      -->P_LS_XLTAP_ENAME  text
*      -->P_LV_DATUM  text
*      <--P_LV_TOTALSEC  text
*----------------------------------------------------------------------*
FORM f_calc_times_1_c40  TABLES   ft_yltap STRUCTURE ltap
                     USING    fu_uname fu_datum
                     CHANGING fc_totalsec.

  DATA : ls_yltap TYPE ltap,
         ls_ltap  TYPE ltap,
         ls_ltak  TYPE ltak.

  DATA : lt_econf TYPE STANDARD TABLE OF ty_econf,
         ls_econf LIKE LINE OF lt_econf,
         lt_qconf TYPE STANDARD TABLE OF ty_qconf,
         ls_qconf LIKE LINE OF lt_qconf,
         ls_times LIKE LINE OF gt_times.

  DATA : lv_second   TYPE i,
         lv_totalsec TYPE i,
         lv_lines    TYPE i.

  DATA : lv_timestamp1 TYPE ccupeaka-timestamp,
         lv_timestamp2 TYPE ccupeaka-timestamp,
         lv_different  TYPE i.

  DATA : lv_t1 TYPE sy-uzeit,
         lv_t2 TYPE sy-uzeit,
         lv_d1 TYPE sy-datum,
         lv_d2 TYPE sy-datum.

  LOOP AT ft_yltap INTO ls_yltap WHERE ename = fu_uname
                                   AND edatu = fu_datum.
    CLEAR : lt_econf[], lt_qconf[].
    LOOP AT gt_ltap INTO ls_ltap WHERE ename = ls_yltap-ename
                                   AND tanum = ls_yltap-tanum.
      IF ls_ltap-edatu IS NOT INITIAL.
        ls_econf-edatu  = ls_ltap-edatu.
        ls_econf-ezeit  = ls_ltap-ezeit.
        ls_qconf-qdatu = ls_ltap-qdatu.
        ls_qconf-qzeit = ls_ltap-qzeit.
        APPEND ls_econf TO lt_econf.
        APPEND ls_qconf TO lt_qconf.
        CLEAR: ls_econf, ls_qconf.
      ENDIF.
    ENDLOOP.

    CLEAR ls_ltak.
*    READ TABLE gt_ltak INTO ls_ltak
*                       WITH KEY lgnum = pa_lgnum
*                                tanum = ls_yltap-tanum.

    IF lt_econf[] IS NOT INITIAL.
      SORT lt_econf BY edatu ezeit.
      SORT lt_qconf BY qdatu qzeit.
      CLEAR : ls_econf, ls_qconf, lv_timestamp1, lv_timestamp2, lv_different,
              lv_t1, lv_t2, lv_d1, lv_d2, lv_second.
      READ TABLE lt_econf INTO ls_econf INDEX 1.
      READ TABLE lt_qconf INTO ls_qconf INDEX 1.
      CONCATENATE ls_qconf-qdatu ls_qconf-qzeit INTO lv_timestamp1.
      CONCATENATE ls_econf-edatu ls_econf-ezeit INTO lv_timestamp2.

      IF lv_timestamp1 IS NOT INITIAL AND
        lv_timestamp2 IS NOT INITIAL.
        CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
          EXPORTING
            timestamp1 = lv_timestamp1
            timestamp2 = lv_timestamp2
          IMPORTING
            difference = lv_different.
      ELSEIF lv_timestamp1 IS INITIAL.
        lv_different = 0.
      ENDIF.

      IF lv_different < 0.
        lv_t1 = ls_qconf-qzeit.
        lv_d1 = ls_qconf-qdatu.
      ELSE.
        lv_t1 = ls_econf-ezeit.
        lv_d1 = ls_econf-edatu.
      ENDIF.

      DESCRIBE TABLE lt_econf LINES lv_lines.
      CLEAR: ls_econf, ls_qconf.
      READ TABLE lt_econf INTO ls_econf INDEX lv_lines.
      lv_t2 = ls_econf-ezeit.
      lv_d2 = ls_econf-edatu.

      CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
        EXPORTING
          date_1  = lv_d1
          time_1  = lv_t1
          date_2  = lv_d2
          time_2  = lv_t2
        IMPORTING
          seconds = lv_second.
    ELSE.
      CLEAR lv_second.
    ENDIF.

    ADD lv_second TO lv_totalsec.
  ENDLOOP.

  fc_totalsec  = lv_totalsec.
ENDFORM.                    " F_CALC_TIMES_1
