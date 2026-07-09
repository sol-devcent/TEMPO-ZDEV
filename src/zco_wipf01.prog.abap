*&---------------------------------------------------------------------*
*&  Include           ZCO_WIPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  IF pa_werks IS INITIAL.
    PERFORM f_error_selection_screen USING 'PWE' '0'.
  ENDIF.

  IF pa_monat IS INITIAL.
    PERFORM f_error_selection_screen USING 'PMO' '0'.
  ENDIF.

  IF pa_gjahr IS INITIAL.
    PERFORM f_error_selection_screen USING 'PGJ' '0'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'You are not authorized'.
  ENDCASE.

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
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  TYPES : BEGIN OF ly_keys,
            lednr   LIKE cosb-lednr,
            wrttp   LIKE cosb-wrttp,
            versn   LIKE cosb-versn,
          END OF ly_keys.

  DATA : lt_keys    TYPE STANDARD TABLE OF ly_keys INITIAL SIZE 0,
         ls_keys    TYPE ly_keys,
         lt_cosb    LIKE gt_cosb OCCURS 0 WITH HEADER LINE,
         ls_cosb    LIKE gt_cosb.

  DATA : lv_monat(2).

  ls_keys-lednr   = '00'.
  ls_keys-wrttp   = '32'.
  ls_keys-versn   = '000'.
  APPEND ls_keys TO lt_keys.

  SELECT objnr gjahr twaer kstar wog001 wog002 wog003 wog004
    wog005 wog006 wog007 wog008 wog009 wog010 wog011 wog012
    FROM cosb
    INTO CORRESPONDING FIELDS OF TABLE lt_cosb
    FOR ALL ENTRIES IN lt_keys
    WHERE lednr   = lt_keys-lednr
      AND objnr   LIKE 'OR%'
      AND wrttp   = lt_keys-wrttp
      AND versn   = lt_keys-versn
      AND kstar   <> '1300000001'.

  LOOP AT lt_cosb INTO ls_cosb.
    ls_cosb-kstar = space.
    ls_cosb-wog001 = ls_cosb-wog001 * -1.
    ls_cosb-wog002 = ls_cosb-wog002 * -1.
    ls_cosb-wog003 = ls_cosb-wog003 * -1.
    ls_cosb-wog004 = ls_cosb-wog004 * -1.
    ls_cosb-wog005 = ls_cosb-wog005 * -1.
    ls_cosb-wog006 = ls_cosb-wog006 * -1.
    ls_cosb-wog007 = ls_cosb-wog007 * -1.
    ls_cosb-wog008 = ls_cosb-wog008 * -1.
    ls_cosb-wog009 = ls_cosb-wog009 * -1.
    ls_cosb-wog010 = ls_cosb-wog010 * -1.
    ls_cosb-wog011 = ls_cosb-wog011 * -1.
    ls_cosb-wog012 = ls_cosb-wog012 * -1.
    ls_cosb-aufnr  = ls_cosb-objnr+2(12).
    COLLECT ls_cosb INTO gt_cosb.
    CLEAR ls_cosb.
  ENDLOOP.

  CLEAR : lt_cosb[], lt_cosb.

  lt_cosb[]   = gt_cosb[].
  SORT lt_cosb BY objnr.
  DELETE ADJACENT DUPLICATES FROM lt_cosb COMPARING objnr.
  IF so_aufnr[] IS NOT INITIAL.
    LOOP AT lt_cosb.
      IF lt_cosb-aufnr IN so_aufnr.
        CONTINUE.
      ELSE.
        DELETE lt_cosb.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lt_cosb[] IS NOT INITIAL.
    SELECT aufnr werks objnr gamng
      FROM caufv
      INTO CORRESPONDING FIELDS OF TABLE gt_caufv
      FOR ALL ENTRIES IN lt_cosb
      WHERE aufnr   = lt_cosb-aufnr
        AND werks   = pa_werks.

    IF gt_caufv[] IS NOT INITIAL.
      SELECT aufnr posnr matnr wemng
        FROM afpo
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo
        FOR ALL ENTRIES IN gt_caufv
        WHERE aufnr  = gt_caufv-aufnr
          AND matnr  IN so_matnr.
    ENDIF.
  ENDIF.

  PERFORM f_get_master_and_desc.

  SELECT SINGLE name1
    FROM t001w
    INTO gv_name1
    WHERE werks = pa_werks.

  CONCATENATE ':' pa_werks INTO gv_werks
  SEPARATED BY space.

  lv_monat  = pa_monat.
  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = lv_monat
    IMPORTING
      name  = gv_perio.

  CONCATENATE ':' gv_perio pa_gjahr INTO gv_perio
  SEPARATED BY space.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_cosb    LIKE gt_cosb,
         ls_caufv   TYPE caufv,
         ls_afpo    TYPE afpo,
         lt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out     LIKE LINE OF gt_out,
         ls_mara    LIKE LINE OF gt_mara.

  DATA : lv_gamng   LIKE caufv-gamng,
         lv_matnr   LIKE mara-matnr.

  SORT gt_cosb BY aufnr.
  SORT gt_caufv BY aufnr.

  LOOP AT gt_cosb INTO ls_cosb.
    ls_out-monat  = pa_monat.
    ls_out-gjahr  = ls_cosb-gjahr.
    ls_out-objnr  = ls_cosb-objnr.

    CLEAR ls_caufv.
    READ TABLE gt_caufv INTO ls_caufv WITH KEY aufnr = ls_cosb-aufnr
                                      BINARY SEARCH.
    IF sy-subrc = 0.
      ls_out-werks  = ls_caufv-werks.
      ls_out-gamng  = ls_caufv-gamng.
      lv_gamng      = ls_caufv-gamng.
      ls_out-aufnr  = ls_caufv-aufnr.
      LOOP AT gt_afpo INTO ls_afpo WHERE aufnr = ls_caufv-aufnr.
        ls_out-matnr  = ls_afpo-matnr.
        READ TABLE gt_mara INTO ls_mara WITH KEY matnr = ls_afpo-matnr.
        IF sy-subrc = 0.
          ls_out-maktx  = ls_mara-maktx.
          ls_out-meins  = ls_mara-meins.
        ENDIF.
        ls_out-wemng  = ls_afpo-wemng.

        ls_out-vaqty  = lv_gamng - ls_afpo-wemng.
        APPEND ls_out TO lt_out.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_out INTO ls_out WHERE gjahr = pa_gjahr.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  CLEAR ls_out.
  SORT gt_out BY matnr.
  READ TABLE gt_out INTO ls_out INDEX 1.
  IF sy-subrc = 0.
    lv_matnr  = ls_out-matnr.
    CONCATENATE ls_out-matnr '-' ls_out-maktx INTO gv_matnr
    SEPARATED BY space.
  ENDIF.

  CLEAR ls_out.
  LOOP AT gt_out INTO ls_out.
    PERFORM f_get_begin_end USING ls_out-objnr
                            CHANGING ls_out-beqty ls_out-enqty ls_out-adqty
                                     ls_out-deqty.
    CLEAR : ls_out-aufnr, ls_out-objnr.
    COLLECT ls_out INTO gt_out1.

    MODIFY gt_out FROM ls_out TRANSPORTING beqty enqty adqty deqty.
    CLEAR ls_out.
  ENDLOOP.

  LOOP AT gt_out INTO ls_out WHERE matnr = lv_matnr.
    APPEND ls_out TO gt_out2.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'PF100' EXCLUDING '&POS'.

  SET TITLEBAR 'TITLE'.

  PERFORM f_excluding_toolbar.

  gv_repid = sy-repid.
  gv_dynnr = sy-dynnr.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_OUT'.

  IF g_outcont IS INITIAL.
    CREATE OBJECT g_outcont
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
        parent  = g_outcont
        rows    = 2
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_container.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_container1.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  OUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE out OUTPUT.
  IF g_outgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_outgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sort_tab.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_user_command
                event_receiver->handle_menu_button
                event_receiver->handle_toolbar
                event_receiver->handle_data_changed
                event_receiver->handle_double_click FOR g_outgrid.

    CALL METHOD g_outgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort_grid[]
        it_outtab            = gt_out1[]
        it_fieldcatalog      = gt_fieldcat[].
  ENDIF.

  CALL METHOD cl_gui_control=>set_focus
    EXPORTING
      control = g_outgrid.

  CALL METHOD cl_gui_cfw=>flush.

  PERFORM f_alv_refresh.
ENDMODULE.                 " OUT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DETAIL  OUTPUT
*&---------------------------------------------------------------------*
MODULE detail OUTPUT.
  IF g_outgrid1 IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_outgrid1
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container1.

    PERFORM f_build_fieldcat1.
    PERFORM f_build_layout1.
    PERFORM f_build_sort_tab.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_user_command
                event_receiver->handle_menu_button
                event_receiver->handle_toolbar
                event_receiver->handle_data_changed FOR g_outgrid1.

    CALL METHOD g_outgrid1->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv1
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort_grid[]
        it_outtab            = gt_out2[]
        it_fieldcatalog      = gt_fieldcat1[].
  ENDIF.

  CALL METHOD cl_gui_control=>set_focus
    EXPORTING
      control = g_outgrid1.

  CALL METHOD cl_gui_cfw=>flush.

  PERFORM f_alv_refresh.
ENDMODULE.                 " DETAIL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_valid   TYPE c.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_outcont IS INITIAL.
        CALL METHOD g_outcont->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR g_outcont.
        CLEAR g_outgrid.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh .
  gs_stable-row = 'X'.
  gs_stable-col = 'X'.

  IF g_outgrid IS NOT INITIAL.
    CALL METHOD g_outgrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.

  IF g_outgrid1 IS NOT INITIAL.
    gs_layout_alv1-grid_title          = gv_matnr.
    CALL METHOD g_outgrid1->set_frontend_layout
      EXPORTING
        is_layout = gs_layout_alv1.

    CALL METHOD g_outgrid1->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR : gt_fieldcat[], gt_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT1' :
    'MATNR' 'AFPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'WEMNG' '' '' '' '15' 'Delivered Qty' '' '' '' '' '' '' 'MEINS' ''
    '' '' '' '' '' '' '' '',
    'GAMNG' '' '' '' '15' 'Plan Qty' '' '' '' '' '' '' 'MEINS' ''
    '' '' '' '' '' '' '' '',
    'VAQTY' '' '' '' '15' 'Variance Qty' '' '' '' '' '' '' 'MEINS'
    '' '' '' '' '' '' '' '' '',
    'BEQTY' '' '' '' '15' 'Beginning' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'ADQTY' '' '' '' '15' 'Additional' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'DEQTY' '' '' '' '15' 'Deduction' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'ENQTY' '' '' '' '15' 'Ending' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-box_fname           = 'CHECK'.
*  gs_layout_alv-no_rowmark          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT1
*&---------------------------------------------------------------------*
FORM f_build_layout1 .
  gs_layout_alv1-zebra               = selected.
  gs_layout_alv1-box_fname           = 'CHECK'.
  gs_layout_alv1-grid_title          = gv_matnr.
*  gs_layout_alv1-no_rowmark          = selected.
ENDFORM.                    " F_BUILD_LAYOUT1

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB
*&---------------------------------------------------------------------*
FORM f_build_sort_tab .

ENDFORM.                    " F_BUILD_SORT_TAB

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING    value(fu_types)
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
                           value(fu_emphasize)
                           value(fu_decimals_o)
                           value(fu_grid).

  DATA: lv_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: lv_fieldcat.
  lv_fieldcat-tabname           = fu_types.
  lv_fieldcat-fieldname         = fu_fname.
  lv_fieldcat-ref_field         = fu_refld.
  lv_fieldcat-ref_table         = fu_reftb.
  lv_fieldcat-no_out            = fu_noout.
  lv_fieldcat-outputlen         = fu_outln.
  lv_fieldcat-scrtext_l         = fu_fltxt.
  lv_fieldcat-scrtext_m         = fu_fltxt.
  lv_fieldcat-scrtext_s         = fu_fltxt.
  lv_fieldcat-reptext           = fu_fltxt.
  lv_fieldcat-no_out            = fu_noout.
  lv_fieldcat-do_sum            = fu_dosum.
  lv_fieldcat-hotspot           = fu_hotsp.
  lv_fieldcat-col_pos           = fu_colpos.
  lv_fieldcat-currency          = fu_waers.
  lv_fieldcat-quantity          = fu_meins.
  lv_fieldcat-qfieldname        = fu_meins_f.
  lv_fieldcat-cfieldname        = fu_waers_f.
  lv_fieldcat-checkbox          = fu_checkbox.
  lv_fieldcat-icon              = fu_icon.
  lv_fieldcat-just              = fu_just.
  lv_fieldcat-edit              = fu_edit.
  lv_fieldcat-emphasize         = fu_emphasize.
  lv_fieldcat-decimals_o        = fu_decimals_o.

  IF fu_grid IS INITIAL.
    APPEND lv_fieldcat TO gt_fieldcat.
  ELSE.
    APPEND lv_fieldcat TO gt_fieldcat1.
  ENDIF.
  CLEAR lv_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT1
*&---------------------------------------------------------------------*
FORM f_build_fieldcat1 .
  CLEAR : gt_fieldcat[], gt_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT2' :
    'AUFNR' 'AUFK' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'WEMNG' '' '' '' '15' 'Delivered Qty' 'X' '' '' '' '' '' 'MEINS' ''
    '' '' '' '' '' '' '' 'X',
    'GAMNG' '' '' '' '15' 'Plan Qty' 'X' '' '' '' '' '' 'MEINS' ''
    '' '' '' '' '' '' '' 'X',
    'VAQTY' '' '' '' '15' 'Variance Qty' 'X' '' '' '' '' '' 'MEINS'
    '' '' '' '' '' '' '' '' 'X',
    'BEQTY' '' '' '' '15' 'Beginning' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' 'X',
    'ADQTY' '' '' '' '15' 'Additional' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' 'X',
    'DEQTY' '' '' '' '15' 'Deduction' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' 'X',
    'ENQTY' '' '' '' '15' 'Ending' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' 'X'.
ENDFORM.                    " F_BUILD_FIELDCAT1

*&---------------------------------------------------------------------*
*&      Form  F_GET_MASTER_AND_DESC
*&---------------------------------------------------------------------*
FORM f_get_master_and_desc .
  DATA : lt_afpo  TYPE STANDARD TABLE OF afpo INITIAL SIZE 0.

  lt_afpo[] = gt_afpo[].
  SORT lt_afpo BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING matnr.

  IF lt_afpo[] IS NOT INITIAL.
    SELECT mara~matnr meins maktx
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_afpo
      WHERE mara~matnr  = lt_afpo-matnr
        AND spras       = sy-langu.
  ENDIF.
ENDFORM.                    " F_GET_MASTER_AND_DESC

*&---------------------------------------------------------------------*
*&      Form  F_GET_BEGIN_END
*&---------------------------------------------------------------------*
FORM f_get_begin_end  USING    fu_objnr
                      CHANGING fc_beqty fc_enqty fc_adqty fc_deqty.
  DATA : ls_cosb    TYPE cosb,
         lv_gjahr   TYPE cosb-gjahr,
         lv_wog000  TYPE cosb-wog001.

  lv_gjahr  = pa_gjahr - 1.

  SORT gt_cosb BY objnr gjahr.
  LOOP AT gt_cosb INTO ls_cosb WHERE objnr = fu_objnr.
    IF ls_cosb-gjahr < pa_gjahr.
      fc_enqty = ls_cosb-wog001 + ls_cosb-wog002 + ls_cosb-wog003 +
                 ls_cosb-wog004 + ls_cosb-wog005 + ls_cosb-wog006 +
                 ls_cosb-wog007 + ls_cosb-wog008 + ls_cosb-wog009 +
                 ls_cosb-wog010 + ls_cosb-wog011 + ls_cosb-wog012.
      fc_beqty = ls_cosb-wog001 + ls_cosb-wog002 + ls_cosb-wog003 +
                 ls_cosb-wog004 + ls_cosb-wog005 + ls_cosb-wog006 +
                 ls_cosb-wog007 + ls_cosb-wog008 + ls_cosb-wog009 +
                 ls_cosb-wog010 + ls_cosb-wog011 + ls_cosb-wog012.
    ELSEIF ls_cosb-gjahr = pa_gjahr.
      CASE pa_monat.
        WHEN '01'.
          fc_enqty  = fc_enqty + ls_cosb-wog001.
        WHEN '02'.
          fc_beqty  = fc_beqty + ls_cosb-wog001.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002.
        WHEN '03'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003.
        WHEN '04'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004.
        WHEN '05'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005.
        WHEN '06'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006.
        WHEN '07'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007.
        WHEN '08'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008.
        WHEN '09'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009.
        WHEN '10'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009 + ls_cosb-wog010.
        WHEN '11'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009 + ls_cosb-wog010.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009 + ls_cosb-wog010 + ls_cosb-wog011.
        WHEN '12'.
          fc_beqty  = fc_beqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009 + ls_cosb-wog010 + ls_cosb-wog011.
          fc_enqty  = fc_enqty + ls_cosb-wog001 + ls_cosb-wog002 +
                      ls_cosb-wog003 + ls_cosb-wog004 + ls_cosb-wog005 +
                      ls_cosb-wog006 + ls_cosb-wog007 + ls_cosb-wog008 +
                      ls_cosb-wog009 + ls_cosb-wog010 + ls_cosb-wog011 +
                      ls_cosb-wog012.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  lv_wog000 = fc_enqty - fc_beqty.
  IF lv_wog000 >= 0.
    fc_adqty  = lv_wog000.
  ELSE.
    fc_deqty  = lv_wog000 * -1.
  ENDIF.
ENDFORM.                    " F_GET_BEGIN_END

*&---------------------------------------------------------------------*
*&      Module  HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE header OUTPUT.
  DATA : lr_rows      TYPE REF TO cl_salv_form_layout_grid,
         lr_element   TYPE REF TO cl_salv_form_element,
         lr_container TYPE REF TO cl_gui_container,
         lr_dydos     TYPE REF TO cl_salv_form_dydos.

  CREATE OBJECT lr_rows.

  g_content = lr_rows.

  CLEAR lr_element.
  PERFORM header_line CHANGING lr_element.
  lr_rows->set_element( r_element = lr_element
                        row       = 1
                        column    = 1 ).

  CREATE OBJECT lr_container
    TYPE
      cl_gui_custom_container
    EXPORTING
      container_name          = 'CC_HEADER'.

  CREATE OBJECT lr_dydos
    EXPORTING
      r_container = lr_container
      r_content   = g_content.

  lr_dydos->display( ).
ENDMODULE.                 " HEADER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  HEADER_LINE
*&---------------------------------------------------------------------*
FORM header_line  CHANGING cr_element TYPE REF TO cl_salv_form_element.

  DATA: lr_rows   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_2 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text.

  CREATE OBJECT lr_rows.

  lr_grid = lr_rows->create_grid(
              row    = 3
              column = 1 ).

  lr_grid_1 = lr_grid->create_grid(
    row    = 1
    column = 1 ).
  lr_grid_2 = lr_grid->create_grid(
    row    = 1
    column = 2 ).

  lr_label = lr_grid_1->create_label(
    row    = 1
    column = 1
    text   = text-003 ).
  lr_text = lr_grid_1->create_text(
    row    = 1
    column = 2
    text   = gv_werks ).
  lr_grid_1->create_text(
    row    = 1
    column = 3
    text   = gv_name1 ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 2
    column = 1
    text   = text-004 ).
  lr_text = lr_grid_1->create_text(
    row    = 2
    column = 2
    text   = gv_perio ).
  lr_label->set_label_for( lr_text ).

  cr_element = lr_rows.
ENDFORM.                    " HEADER_LINE
