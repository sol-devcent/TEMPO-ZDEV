*----------------------------------------------------------------------*
***INCLUDE ZMM_PO_SO_UPLOAD_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR : fcode[], fcode.

  CASE 'X'.
    WHEN prpo_sto.
      CASE sy-dynnr.
        WHEN '0100'.
          IF gt_error[] IS INITIAL.
            APPEND '&LOG'  TO fcode.
          ENDIF.
          SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
          SET TITLEBAR 'TITLE'.
        WHEN '0101'.
          SET PF-STATUS space.
      ENDCASE.
  ENDCASE.

  PERFORM f_excluding_toolbar.

ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
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
        container = g_container.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_maingrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_maingrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    PERFORM f_build_fieldcat USING 'MAIN'.
    PERFORM f_build_layout USING 'MAIN'.
    PERFORM f_build_sort_tab_grid USING 'MAIN'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command
            FOR g_maingrid.

    CALL METHOD g_maingrid->set_table_for_first_display
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

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_maingrid.

    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  CALL METHOD g_maingrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  PERFORM f_alv_refresh USING 'X'.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_valid.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_container IS INITIAL.
        CALL METHOD g_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR : g_container, g_maingrid.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN '&PO'.
      CLEAR : gt_error[], gt_error.

      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_proces_create_po.
      ENDIF.

    WHEN '&STO'.
      CLEAR : gt_error[], gt_error.
      PERFORM f_proces_create_sto.

    WHEN '&LOG'.
      CALL SCREEN 101 STARTING AT 10 10
                      ENDING AT 140 20.

    WHEN '&SALL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X' ''.
      ENDIF.

    WHEN '&DALL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING '' ''.
      ENDIF.
  ENDCASE.

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_filter.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_views .
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refr01.
  IF fu_refr01 IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_maingrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat  USING    fu_container.
  CLEAR : gt_main_fieldcat[], gt_main_fieldcat.

  CASE fu_container.
    WHEN 'MAIN'.
      CASE 'X'.
        WHEN prpo_sto.
          PERFORM f_fieldcat USING 'GT_OUT' :
            'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' '' '' '' 'X'
            '' '',
            'STATS' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' 'X' ''
            '' '' '',
            'BANFN' 'EBAN' 'BANFN' '' '' '' '' '' '' '' '' '' '' '' '' ''
            '' '' '' '',
            'EBELN' 'EBAN' 'EBELN' '' '' 'PO Number' '' '' '' '' '' '' ''
            '' '' '' '' '' '' '',
            'BEDNR' 'EKPO' 'BEDNR' '' '' 'STO Number' '' '' '' '' '' '' ''
            '' '' '' '' '' '' '',
            'VENDOR' 'LFA1' 'LIFNR' '' '15' 'Vendor' '' '' '' '' '' '' ''
            '' '' '' '' 'X' '' '',
            'BSGRU' 'EKPO' 'BSGRU' '' '10' '' '' '' '' '' '' '' '' '' ''
            '' '' 'X' '' ''.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_layout.
  gs_layout_alv-zebra   = selected.
  CASE fu_layout.
    WHEN 'MAIN'.
      gs_layout_alv-box_fname   = 'CHECK'.
      gs_layout_alv-col_opt     = selected.
  ENDCASE.
*  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-no_toolbar          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB_GRID
*&---------------------------------------------------------------------*
FORM f_build_sort_tab_grid  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'MAIN'.
      gt_main_sort-spos = 1.
      gt_main_sort-fieldname = 'BANFN'.
      gt_main_sort-up        = selected.
      gt_main_sort-subtot    = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT_TAB_GRID

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_fieldcat  USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_colpos)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_icon)
                          value(fu_just)
                          value(fu_edit)
                          value(fu_colopt)
                          value(fu_emphasize).

  DATA: ld_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-col_pos           = fu_colpos.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.

  CASE fu_types.
    WHEN 'GT_OUT'.
      APPEND ld_fieldcat TO gt_main_fieldcat.
  ENDCASE.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check fu_container.
  DATA : ls_out           LIKE gt_out,
         ls_fieldcatalog  TYPE lvc_t_fcat WITH HEADER LINE.

  CALL METHOD g_maingrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        IF ls_out-check = '-'.
          CONTINUE.
        ENDIF.
        ls_out-check  = fu_check.
        MODIFY gt_out FROM ls_out TRANSPORTING check.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0101  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0101 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  DATA : lv_zebra(1).

  ULINE AT /(128).
  FORMAT COLOR COL_HEADING.
  WRITE: /  sy-vline NO-GAP, (4) 'Sts.' NO-GAP,
            sy-vline NO-GAP, (20) 'PR No.' NO-GAP,
            sy-vline NO-GAP, (100) 'Error message' NO-GAP,
            sy-vline.
  ULINE AT /(128).
  LOOP AT gt_error.
    PERFORM f_zebra CHANGING lv_zebra.
    WRITE: /  sy-vline NO-GAP, (4) gt_error-icon NO-GAP,
              sy-vline NO-GAP, (20) gt_error-banfn NO-GAP,
              sy-vline NO-GAP, gt_error-mess(100) NO-GAP,
              sy-vline NO-GAP.
  ENDLOOP.
  ULINE AT /(128).
ENDMODULE.                 " LIST_PROCESSING_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ZEBRA
*&---------------------------------------------------------------------*
FORM f_zebra  CHANGING fc_zebra.
  FORMAT INTENSIFIED OFF.
  IF fc_zebra IS INITIAL.
    fc_zebra = 'X'.
    FORMAT COLOR COL_HEADING.
  ELSE.
    CLEAR : fc_zebra.
    FORMAT COLOR COL_NORMAL.
  ENDIF.
ENDFORM.                    " F_ZEBRA

*&---------------------------------------------------------------------*
*&      Form  F_PROCES_CREATE_PO
*&---------------------------------------------------------------------*
FORM f_proces_create_po .
  DATA : lt_out     LIKE gt_out OCCURS 0,
         lt_lfa1    TYPE STANDARD TABLE OF lfa1 INITIAL SIZE 0,
         lt_tbsg    TYPE STANDARD TABLE OF tbsg INITIAL SIZE 0,
         ls_lfa1    LIKE lfa1,
         ls_tbsg    LIKE tbsg,
         lt_out1    LIKE gt_out OCCURS 0,
         lt_out2    LIKE gt_out OCCURS 0,
         ls_out     LIKE gt_out,
         lv_mess(100).

  LOOP AT gt_out WHERE stats IS NOT INITIAL.
    CLEAR gt_out-stats.
    MODIFY gt_out TRANSPORTING stats.
  ENDLOOP.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  lt_out2[] = lt_out1[] = lt_out[].

  SORT lt_out1 BY vendor.
  DELETE ADJACENT DUPLICATES FROM lt_out1 COMPARING vendor.
  DELETE lt_out1 WHERE vendor IS INITIAL.

  SORT lt_out2 BY bsgru.
  DELETE ADJACENT DUPLICATES FROM lt_out2 COMPARING bsgru.
  DELETE lt_out2 WHERE bsgru IS INITIAL.

  IF lt_out1[] IS NOT INITIAL.
    SELECT lifnr
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
      FOR ALL ENTRIES IN lt_out1
      WHERE lifnr = lt_out1-vendor.
  ENDIF.

  IF lt_out2[] IS NOT INITIAL.
    SELECT bsgru
      FROM tbsg
      INTO CORRESPONDING FIELDS OF TABLE lt_tbsg
      FOR ALL ENTRIES IN lt_out2
      WHERE bsgru = lt_out2-bsgru.
  ENDIF.

  LOOP AT lt_out INTO ls_out.
    ls_out-stats    = icon_led_green.
    CLEAR ls_out-check.

    IF ls_out-ebeln IS NOT INITIAL.
      ls_out-stats    = icon_led_red.
      CONCATENATE 'PR' ls_out-banfn 'already closed' INTO lv_mess
      SEPARATED BY space.
      PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                    '' '' lv_mess.
    ENDIF.

    IF ls_out-stats = icon_led_green.
      IF ls_out-vendor IS INITIAL OR
        ls_out-bsgru IS INITIAL.
        ls_out-stats    = icon_led_red.
        lv_mess         = 'Vendor & Order Reason must entry'.
        PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                      '' '' lv_mess.
      ELSEIF ls_out-vendor IS NOT INITIAL.
        CLEAR ls_lfa1.
        READ TABLE lt_lfa1 INTO ls_lfa1 WITH KEY lifnr = ls_out-vendor.
        IF sy-subrc <> 0.
          ls_out-stats    = icon_led_red.
          CONCATENATE 'Vendor' ls_out-vendor 'not found' INTO lv_mess
          SEPARATED BY space.
          PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                        '' '' lv_mess.
        ENDIF.
      ELSEIF ls_out-bsgru IS NOT INITIAL.
        CLEAR ls_tbsg.
        READ TABLE lt_tbsg INTO ls_tbsg WITH KEY bsgru = ls_out-bsgru.
        IF sy-subrc <> 0.
          ls_out-stats    = icon_led_red.
          CONCATENATE 'Order reason' ls_out-bsgru 'not found' INTO lv_mess
          SEPARATED BY space.
          PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                        '' '' lv_mess.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_out-stats = icon_led_green.
      PERFORM f_posting USING ls_out '' ''
                        CHANGING ls_out-stats ls_out-ebeln.
    ENDIF.

    MODIFY gt_out FROM ls_out TRANSPORTING check stats ebeln
                              WHERE banfn = ls_out-banfn.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCES_CREATE_PO

*&---------------------------------------------------------------------*
*&      Form  F_PROCES_CREATE_STO
*&---------------------------------------------------------------------*
FORM f_proces_create_sto .
  DATA : lt_out LIKE gt_out OCCURS 0,
         ls_out LIKE gt_out,
         lv_mess(100).

  DATA : lt_tvkol   TYPE STANDARD TABLE OF tvkol INITIAL SIZE 0,
         ls_tvkol   LIKE tvkol,
         lt_out1    LIKE gt_out OCCURS 0,
         lt_out2    LIKE gt_out OCCURS 0,
         lv_vstel   LIKE tvkol-vstel,
         lv_werks   LIKE tvkol-werks,
         lv_lgort   LIKE tvkol-lgort.

  LOOP AT gt_out WHERE stats IS NOT INITIAL.
    CLEAR gt_out-stats.
    MODIFY gt_out TRANSPORTING stats.
  ENDLOOP.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  CLEAR lt_out1.
  lt_out1[] = lt_out[].
  SORT lt_out1 BY afnam.
  LOOP AT lt_out1 INTO ls_out.
    lv_vstel  = ls_out-afnam.
    CLEAR ls_out.
    ls_out-vstel  = lv_vstel.
    COLLECT ls_out INTO lt_out2.
    CLEAR : ls_out, lv_vstel.
  ENDLOOP.

  IF lt_out1[] IS NOT INITIAL.
    SELECT vstel werks lgort
      FROM tvkol
      INTO CORRESPONDING FIELDS OF TABLE lt_tvkol
      FOR ALL ENTRIES IN lt_out2
      WHERE vstel = lt_out2-vstel.
  ENDIF.

  LOOP AT lt_out INTO ls_out.
    ls_out-stats  = icon_led_green.
    CLEAR ls_out-check.

    IF ls_out-bednr IS NOT INITIAL.
      ls_out-stats    = icon_led_red.
      CONCATENATE 'STO' 'already closed' INTO lv_mess
      SEPARATED BY space.
      PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                    '' '' lv_mess.
    ENDIF.

    IF ls_out-stats = icon_led_green.
      IF ls_out-ebeln IS INITIAL.
        ls_out-stats    = icon_led_red.
        lv_mess         = 'Create PO for Principal first'.
        PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                      '' '' lv_mess.
      ENDIF.
    ENDIF.

    IF ls_out-stats = icon_led_green.
      IF ls_out-bsgru IS INITIAL.
        ls_out-stats    = icon_led_red.
        lv_mess         = 'Order Reason must entry'.
        PERFORM f_error_message USING ls_out-stats ls_out-banfn
                                      '' '' lv_mess.
      ENDIF.
    ENDIF.

    IF ls_out-stats = icon_led_green.
      CLEAR : lv_vstel, ls_tvkol, lv_werks, lv_lgort.
      lv_vstel  = ls_out-afnam.
      READ TABLE lt_tvkol INTO ls_tvkol WITH KEY vstel = lv_vstel.
      IF sy-subrc = 0.
        lv_werks  = ls_tvkol-werks.
        lv_lgort  = ls_tvkol-lgort.
      ENDIF.

      PERFORM f_posting USING ls_out lv_werks lv_lgort
                        CHANGING ls_out-stats ls_out-bednr.
    ENDIF.

    MODIFY gt_out FROM ls_out TRANSPORTING check stats bednr
                              WHERE banfn = ls_out-banfn.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCES_CREATE_STO

*&---------------------------------------------------------------------*
*&      Form  F_ON_F4_HELP
*&---------------------------------------------------------------------*
FORM f_on_f4_help  USING    fu_fieldname
                            fu_row_id
                            fu_event_data TYPE REF TO cl_alv_event_data
                            fu_bad_cells
                            fu_display.

  DATA : BEGIN OF lt_f4 OCCURS 0,
           zrecd       LIKE zgdmmt0002-zrecd,
           zrecdt      LIKE zgdmmt0002-zrecdt,
         END OF lt_f4.

  DATA : ls_zgdmmt0002  TYPE zgdmmt0002,
         lv_dynprofld   TYPE help_info-dynprofld,
         ls_out         TYPE zgdmmst001.

  DATA : lt_ret TYPE TABLE OF ddshretval  WITH HEADER LINE.

*  CLEAR : lt_f4[], lt_f4.
*  LOOP AT gt_zgdmmt0002 INTO ls_zgdmmt0002.
*    lt_f4-zrecd     = ls_zgdmmt0002-zrecd.
*    lt_f4-zrecdt    = ls_zgdmmt0002-zrecdt.
*    APPEND lt_f4.
*  ENDLOOP.
*
*  lv_dynprofld  = 'GT_OUT-PENYEBAB'.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield    = 'ZRECD'
*      dynpprog    = sy-repid
*      dynpnr      = sy-dynnr
*      dynprofield = lv_dynprofld
*      value_org   = 'S'
*    TABLES
*      value_tab   = lt_f4
*      return_tab  = lt_ret.
*
*  CHECK sy-subrc IS INITIAL.
*
*  READ TABLE lt_f4 WITH KEY zrecd = lt_ret-fieldval.
*  IF sy-subrc = 0.
*    ls_out-penyebab = lt_f4-zrecdt.
*    MODIFY gt_out FROM ls_out INDEX fu_row_id TRANSPORTING penyebab.
*  ENDIF.
ENDFORM.                    " F_ON_F4_HELP

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_stats fu_banfn fu_parameter fu_row fu_mess.
  DATA : ls_error   LIKE gt_error.

  ls_error-icon   = fu_stats.
  ls_error-banfn  = fu_banfn.
  IF fu_parameter IS INITIAL AND
    fu_row IS INITIAL.
    ls_error-mess   = fu_mess.
  ELSE.
    ls_error-mess = fu_row.
    CONDENSE ls_error-mess NO-GAPS.
    CONCATENATE fu_mess fu_parameter ls_error-mess INTO ls_error-mess
    SEPARATED BY '|'.
  ENDIF.
  APPEND ls_error TO gt_error.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting  USING    fs_out   STRUCTURE gt_out
                         fu_werks fu_lgort
                CHANGING fc_stats fc_ebeln.

  DATA : i_poh1 LIKE bapimepoheader,
         i_poh2 LIKE bapimepoheaderx,
         i_poi1 LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         i_poi2 LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
         i_poi3 LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
         i_poi4 LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE,
         ls_eban  TYPE eban.

  SELECT SINGLE bukrs FROM t001k INTO i_poh1-comp_code
  WHERE bwkey = fs_out-werks.
  i_poh2-comp_code   = 'X'.
  i_poh1-creat_date  = sy-datum.
  i_poh2-creat_date  = 'X'.
  i_poh1-purch_org   = 'SOM'.
  i_poh2-purch_org   = 'X'.
  i_poh1-pur_group   = fs_out-ekgrp.
  i_poh2-pur_group   = 'X'.
  i_poh1-gr_message  = 'X'.
  i_poh2-gr_message  = 'X'.

  CASE ok_code.
    WHEN '&PO'.
      i_poh1-doc_type = 'NB'.
      i_poh2-doc_type = 'X'.
      i_poh1-vendor   = fs_out-vendor.
      i_poh2-vendor   = 'X'.

    WHEN '&STO'.
      i_poh1-doc_type   = 'UB'.
      i_poh2-doc_type   = 'X'.
      i_poh1-suppl_plnt = '0200'.
      i_poh2-suppl_plnt = 'X'.
  ENDCASE.

  LOOP AT gt_eban INTO ls_eban WHERE banfn = fs_out-banfn.
    i_poi1-po_item        = ls_eban-bnfpo.
    i_poi2-po_item        = ls_eban-bnfpo.
    i_poi1-material       = ls_eban-matnr.
    i_poi2-material       = 'X'.
    i_poi1-quantity       = ls_eban-menge.
    i_poi2-quantity       = 'X'.
    i_poi1-order_reason   = fs_out-bsgru.
    i_poi2-order_reason   = 'X'.
    i_poi1-preq_name      = ls_eban-bnfpo.
    i_poi2-preq_name      = 'X'.

    CASE ok_code.
      WHEN '&PO'.
        i_poi1-preq_no    = ls_eban-banfn.
        i_poi2-preq_no    = 'X'.
        i_poi1-preq_item  = ls_eban-bnfpo.
        i_poi2-preq_item  = 'X'.
        i_poi1-plant      = ls_eban-werks.
        i_poi2-plant      = 'X'.
        i_poi1-stge_loc   = ls_eban-lgort.
        i_poi2-stge_loc   = 'X'.

      WHEN '&STO'.
        IF fu_werks IS NOT INITIAL.
          i_poi1-plant        = fu_werks.
        ELSE.
          i_poi1-plant        = ls_eban-afnam.
        ENDIF.
        i_poi2-plant        = 'X'.
        IF fu_lgort IS NOT INITIAL.
          i_poi1-stge_loc     = fu_lgort.
        ELSE.
          i_poi1-stge_loc     = '1000'.
        ENDIF.
        i_poi2-stge_loc     = 'X'.
        i_poi1-trackingno   = ls_eban-ebeln.
        i_poi2-trackingno   = 'X'.
        i_poi1-suppl_stloc  = '1000'.
        i_poi2-suppl_stloc  = 'X'.
    ENDCASE.

    APPEND i_poi1.
    CLEAR i_poi1.
    APPEND i_poi2.
    CLEAR i_poi2.
  ENDLOOP.

  CLEAR : l_t_return[], l_t_return, txtmsg.
  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = i_poh1
      poheaderx        = i_poh2
    IMPORTING
      exppurchaseorder = po_num
    TABLES
      return           = l_t_return
      poitem           = i_poi1
      poitemx          = i_poi2
      poschedule       = i_poi3
      poschedulex      = i_poi4.

  LOOP AT l_t_return.
    IF l_t_return-type  = 'E'.
      l_error_found = 'X'.
      fc_stats  = icon_led_red.
      PERFORM f_error_message USING fs_out-stats fs_out-banfn
                                    l_t_return-parameter
                                    l_t_return-row
                                    l_t_return-message.
    ENDIF.
  ENDLOOP.

  IF l_error_found = 'X'.
    ROLLBACK WORK.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    fc_ebeln = po_num.

    IF ok_code = '&STO'.
      CLEAR : i_poi1[], i_poi1, i_poi2[], i_poi2,
              l_t_return[], l_t_return, l_error_found.

      LOOP AT gt_eban INTO ls_eban WHERE banfn = fs_out-banfn.
        i_poi1-po_item        = ls_eban-bnfpo.
        i_poi2-po_item        = ls_eban-bnfpo.
        i_poi1-trackingno     = po_num.
        i_poi2-trackingno     = 'X'.
        APPEND i_poi1.
        CLEAR i_poi1.
        APPEND i_poi2.
        CLEAR i_poi2.
      ENDLOOP.

      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = fs_out-ebeln
        TABLES
          return        = l_t_return
          poitem        = i_poi1
          poitemx       = i_poi2.

      LOOP AT l_t_return.
        IF l_t_return-type  = 'E'.
          l_error_found = 'X'.
          fc_stats  = icon_led_red.
          PERFORM f_error_message USING fs_out-stats fs_out-banfn
                                        '' ''
                                        l_t_return-message.
        ENDIF.
      ENDLOOP.

      IF l_error_found = 'X'.
        ROLLBACK WORK.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA1
*&---------------------------------------------------------------------*
FORM f_get_data1 USING filename.
  DATA : ls_prio    LIKE LINE OF gt_prio.

  REFRESH i_excel.
* GET DATA FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 16
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc = 0.
    CLEAR wa_excel.
    SORT i_excel BY row col value.
    LOOP AT i_excel INTO wa_excel.
      CASE wa_excel-col.
        WHEN '0001'.
          PERFORM f_alpha_modify USING wa_excel-value
                                 CHANGING ls_prio-ebeln.
        WHEN '0002'.
          ls_prio-ebelp = wa_excel-value.
        WHEN '0003'.
          ls_prio-matnr = wa_excel-value.
        WHEN '0004'.
          ls_prio-lprio = wa_excel-value.
      ENDCASE.
      AT END OF  row.
        APPEND ls_prio TO gt_prio.
        CLEAR ls_prio.
      ENDAT.
      CLEAR wa_excel.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_MODIFY
*&---------------------------------------------------------------------*
FORM f_alpha_modify  USING    fu_value
                     CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_ALPHA_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_PO_CHANGE
*&---------------------------------------------------------------------*
FORM f_po_change .
  DATA : lt_xprio     TYPE STANDARD TABLE OF ty_prio,
         ls_xprio     LIKE LINE OF lt_xprio,
         ls_prio      LIKE LINE OF gt_prio,
         return       TYPE STANDARD TABLE OF bapiret2,
         ls_return    LIKE LINE OF return,
         lt_poi1      TYPE STANDARD TABLE OF bapimepoitem,
         lt_poi2      TYPE STANDARD TABLE OF bapimepoitemx,
         ls_poi1      LIKE LINE OF lt_poi1,
         ls_poi2      LIKE LINE OF lt_poi2,
         lt_pos1      TYPE STANDARD TABLE OF bapiitemship,
         lt_pos2      TYPE STANDARD TABLE OF bapiitemshipx,
         ls_pos1      LIKE LINE OF lt_pos1,
         ls_pos2      LIKE LINE OF lt_pos2.

  DATA : lv_stats(4),
         lv_error,
         lv_count     TYPE i.

  lt_xprio[]  = gt_prio[].
  SORT lt_xprio BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xprio COMPARING ebeln.

  LOOP AT lt_xprio INTO ls_xprio.
    LOOP AT gt_prio INTO ls_prio WHERE ebeln = ls_xprio-ebeln.
      ls_poi1-po_item        = ls_prio-ebelp.
      APPEND ls_poi1 TO lt_poi1.

      ls_poi2-po_item        = ls_prio-ebelp.
      ls_poi2-shipping       = 'X'.
      APPEND ls_poi2 TO lt_poi2.

      ls_pos1-po_item        = ls_prio-ebelp.
      ls_pos1-dlv_prio       = ls_prio-lprio.
      APPEND ls_pos1 TO lt_pos1.

      ls_pos2-po_item        = ls_prio-ebelp.
      ls_pos2-po_itemx       = 'X'.
      ls_pos2-dlv_prio       = 'X'.
      APPEND ls_pos2 TO lt_pos2.
      CLEAR : ls_poi1, ls_poi2, ls_pos1, ls_pos2.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = ls_xprio-ebeln
      TABLES
        return        = return
        poitem        = lt_poi1
        poitemx       = lt_poi2
        poshipping    = lt_pos1
        poshippingx   = lt_pos2.

    LOOP AT return INTO ls_return.
      IF ls_return-type  = 'E'.
        lv_error  = 'X'.
        lv_stats  = icon_led_red.
        PERFORM f_error_message USING lv_stats ls_xprio-ebeln
                                      '' ''
                                      ls_return-message.
      ENDIF.
    ENDLOOP.

    IF lv_error = 'X'.
      ROLLBACK WORK.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.
    CLEAR : lv_error, return[], lt_poi1[], lt_poi2[], lt_pos1[], lt_pos2[].
  ENDLOOP.

  IF gt_error[] IS INITIAL.
    MESSAGE s000(zab) WITH 'Data already uploaded'.
  ENDIF.
ENDFORM.                    " F_PO_CHANGE
