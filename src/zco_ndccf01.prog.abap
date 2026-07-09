*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  IF pa_bwkey IS INITIAL.
    PERFORM f_error_selection_screen USING 'PBW' '0'.
  ENDIF.
  IF pa_bdatj IS INITIAL.
    PERFORM f_error_selection_screen USING 'PBD' '0'.
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
  DATA : lt_marc  TYPE STANDARD TABLE OF marc.

  SELECT SINGLE bukrs INTO gv_bukrs
    FROM t001k WHERE bwkey = pa_bwkey.

  PERFORM f_categ USING : 'AB', 'EB', 'ZU', 'VN'.

  SELECT matnr werks prctr
    FROM marc
    INTO CORRESPONDING FIELDS OF TABLE gt_marc
    WHERE matnr IN so_matnr
      AND werks = pa_bwkey.

  lt_marc[] = gt_marc[].
  SORT lt_marc BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING matnr.

  IF lt_marc[] IS NOT INITIAL.
    SELECT matnr matkl
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_marc
      WHERE matnr = lt_marc-matnr.

    PERFORM f_get_description USING 'MATNR'.
    PERFORM f_get_description USING 'MATKL'.
  ENDIF.

  IF gt_marc[] IS NOT INITIAL.
    SELECT matnr bwkey bwtar kaln1
      FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE gt_mbew
      FOR ALL ENTRIES IN gt_marc
      WHERE matnr = gt_marc-matnr
        AND bwkey = gt_marc-werks.

    IF gt_mbew[] IS NOT INITIAL.
      SELECT kalnr bdatj poper untper categ ptyp bvalt
        keart mlcct kkzst patnr dipa curtp waers kst001
        kst003 kst005 kst007 kst009 kst011
        FROM ckmlkeph
        INTO CORRESPONDING FIELDS OF TABLE gt_ckmlkeph
        FOR ALL ENTRIES IN gt_mbew
        WHERE kalnr = gt_mbew-kaln1
          AND bdatj = pa_bdatj
          AND poper IN so_poper
          AND bvalt = space
          AND mlcct = co_mlcct
          AND kkzst = space
          AND categ IN gr_categ.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CATEG
*&---------------------------------------------------------------------*
FORM f_categ  USING    fu_categ.
  DATA : lr_categ   LIKE LINE OF gr_categ.

  lr_categ-low    = fu_categ.
  lr_categ-sign   = 'I'.
  lr_categ-option = 'EQ'.
  APPEND lr_categ TO gr_categ.
  CLEAR lr_categ.
ENDFORM.                    " F_CATEG

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description  USING    fu_field.
  FIELD-SYMBOLS : <fs_itab> TYPE STANDARD TABLE.

  DATA : sortfield  TYPE string,
         wherecond  TYPE TABLE OF string.

  DATA : lt_mara  TYPE STANDARD TABLE OF mara.

  lt_mara[] = gt_mara[].

  CASE fu_field.
    WHEN 'MATNR'.
      sortfield = fu_field.

      APPEND 'MATNR = <FS_ITAB>-MATNR AND' TO wherecond.
      APPEND 'SPRAS = SY-LANGU' TO wherecond.

      ASSIGN lt_mara TO <fs_itab>.

      SORT <fs_itab> BY (sortfield).
      DELETE ADJACENT DUPLICATES FROM <fs_itab> COMPARING (sortfield).
      IF <fs_itab> IS NOT INITIAL.
        SELECT matnr maktx
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN <fs_itab>
          WHERE (wherecond).
      ENDIF.

    WHEN 'MATKL'.
      sortfield = fu_field.

      APPEND 'SPRAS = SY-LANGU AND' TO wherecond.
      APPEND 'MATKL = <FS_ITAB>-MATKL' TO wherecond.

      ASSIGN lt_mara TO <fs_itab>.

      SORT <fs_itab> BY (sortfield).
      DELETE ADJACENT DUPLICATES FROM <fs_itab> COMPARING (sortfield).
      IF <fs_itab> IS NOT INITIAL.
        SELECT matkl wgbez
          FROM t023t
          INTO CORRESPONDING FIELDS OF TABLE gt_t023t
          FOR ALL ENTRIES IN <fs_itab>
          WHERE (wherecond).
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_mbew      TYPE mbew,
         ls_mara      TYPE mara,
         ls_makt      TYPE makt,
         ls_t023t     TYPE t023t,
         ls_marc      TYPE marc,
         ls_ckmlkeph  TYPE ckmlkeph,
         ls_matledgr  TYPE ckmlkeph.

  DATA : lt_matledgr  TYPE STANDARD TABLE OF ckmlkeph.

  DATA : lv_kst001    LIKE ckmlkeph-kst001,
         lv_kst003    LIKE ckmlkeph-kst003,
         lv_kst005    LIKE ckmlkeph-kst005,
         lv_kst007    LIKE ckmlkeph-kst007,
         lv_kst009    LIKE ckmlkeph-kst009,
         lv_kst011    LIKE ckmlkeph-kst011.

  DATA : ls_calc  LIKE gt_calc.

  DATA : lt_out      LIKE gt_out OCCURS 0,
         lt_zcodt009 TYPE TABLE OF zcodt009 WITH HEADER LINE,
         lt_t001k    TYPE TABLE OF t001k    WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_out> LIKE LINE OF gt_out.

  lt_matledgr[] = gt_ckmlkeph[].
  SORT lt_matledgr BY kalnr bdatj poper.
  DELETE ADJACENT DUPLICATES FROM lt_matledgr COMPARING kalnr bdatj poper.

  SORT gt_mbew BY matnr bwkey.
  SORT gt_marc BY matnr werks.
  SORT gt_mara BY matnr.

  LOOP AT gt_mbew INTO ls_mbew.
    gt_out-bwkey  = ls_mbew-bwkey.
    gt_out-matnr  = ls_mbew-matnr.
    READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_mbew-matnr.
    IF sy-subrc = 0.
      gt_out-maktx  = ls_makt-maktx.
    ENDIF.

    READ TABLE gt_mara INTO ls_mara WITH KEY matnr = ls_mbew-matnr.
    IF sy-subrc = 0.
      gt_out-matkl  = ls_mara-matkl.
      READ TABLE gt_t023t INTO ls_t023t WITH KEY matkl = ls_mara-matkl.
      IF sy-subrc = 0.
        gt_out-wgbez  = ls_t023t-wgbez.
      ENDIF.
    ENDIF.

    READ TABLE gt_marc INTO ls_marc WITH KEY matnr = ls_mbew-matnr
                                             werks = ls_mbew-bwkey
                                    BINARY SEARCH.
    IF sy-subrc = 0.
      gt_out-prctr  = ls_marc-prctr.
    ENDIF.

    LOOP AT lt_matledgr INTO ls_matledgr WHERE kalnr = ls_mbew-kaln1.
      LOOP AT gt_ckmlkeph INTO ls_ckmlkeph WHERE kalnr = ls_matledgr-kalnr
                                             AND bdatj = ls_matledgr-bdatj
                                             AND poper = ls_matledgr-poper.
        gt_out-poper  = ls_ckmlkeph-poper.
        gt_out-bdatj  = ls_ckmlkeph-bdatj.
        gt_out-waers  = ls_ckmlkeph-waers.

        PERFORM f_cost_calculate USING ls_ckmlkeph
                                 CHANGING ls_calc.
      ENDLOOP.

      gt_out-kst001 = ls_calc-eb001 - ls_calc-ab001 - ls_calc-zu001 + ls_calc-vn001.
      gt_out-kst003 = ls_calc-eb003 - ls_calc-ab003 - ls_calc-zu003 + ls_calc-vn003.
      gt_out-kst005 = ls_calc-eb005 - ls_calc-ab005 - ls_calc-zu005 + ls_calc-vn005.
      gt_out-kst007 = ls_calc-eb007 - ls_calc-ab007 - ls_calc-zu007 + ls_calc-vn007.
      gt_out-kst009 = ls_calc-eb009 - ls_calc-ab009 - ls_calc-zu009 + ls_calc-vn009.
      gt_out-kst011 = ls_calc-eb011 - ls_calc-ab011 - ls_calc-zu011 + ls_calc-vn011.

      MULTIPLY: gt_out-kst001 BY -1,
                gt_out-kst003 BY -1,
                gt_out-kst005 BY -1,
                gt_out-kst007 BY -1,
                gt_out-kst009 BY -1,
                gt_out-kst011 BY -1.

      gt_out-total = gt_out-kst001 + gt_out-kst003 + gt_out-kst005 + gt_out-kst007 +
                     gt_out-kst009 + gt_out-kst011.

      IF gt_out-total <> 0.
        APPEND gt_out.
      ENDIF.
      CLEAR : ls_calc.
    ENDLOOP.

    CLEAR : gt_out, ls_mbew, ls_makt, ls_mara, ls_t023t, ls_marc,
            ls_ckmlkeph.
  ENDLOOP.

  IF gt_out[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_zcodt009
      FROM zcodt009 FOR ALL ENTRIES IN gt_out
      WHERE bukrs	= gv_bukrs
        AND werks = gt_out-bwkey
        AND bdatj = gt_out-bdatj
        AND poper = gt_out-poper
        AND matnr = gt_out-matnr.

    LOOP AT gt_out ASSIGNING <fs_out>.
      READ TABLE lt_zcodt009 WITH KEY bukrs = gv_bukrs
                                      werks = <fs_out>-bwkey
                                      bdatj = <fs_out>-bdatj
                                      poper = <fs_out>-poper
                                      matnr = <fs_out>-matnr.
      IF sy-subrc = 0.
        <fs_out>-message = <fs_out>-status = 'POSTED'.
      ELSE.
        CLEAR: <fs_out>-message,<fs_out>-status.
      ENDIF.
    ENDLOOP.
  ENDIF.
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
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'PF100' EXCLUDING '&POS'.

  SET TITLEBAR 'TITLE'.

  PERFORM f_excluding_toolbar.

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
*&      Module  OUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE out OUTPUT.
  IF g_outgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_outgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_outcont.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sort_tab.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_user_command
                event_receiver->handle_menu_button
                event_receiver->handle_toolbar
                event_receiver->handle_data_changed FOR g_outgrid.

    CALL METHOD g_outgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort_grid[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_fieldcat[].

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_outgrid.

*    CALL METHOD cl_gui_cfw=>flush.

  ELSE.
    PERFORM f_alv_refresh.
  ENDIF.
ENDMODULE.                 " OUT  OUTPUT

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
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR : gt_fieldcat[], gt_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT' :
    'BWKEY' 'MBEW' 'BWKEY' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'POPER' 'CKMLKEPH' 'POPER' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'BDATJ' 'CKMLKEPH' 'BDATJ' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MATNR' 'MBEW' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'WGBEZ' 'T023T' 'WGBEZ' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'PRCTR' 'MARC' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'WAERS' 'CKMLKEPH' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'KST001' '' '' '' '15' 'RawMat Cost' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '',
    'KST003' '' '' '' '15' 'PackMat Cost' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '',
    'KST005' '' '' '' '15' 'Labor Cost' '' '' '' '' '' 'WAERS' '' '' ''
    '' '' '' '' '' '',
    'KST007' '' '' '' '15' 'Machine Cost' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '',
    'KST009' '' '' '' '15' 'Ext.Activities' '' '' '' '' '' 'WAERS'
    '' '' '' '' '' '' '' '' '',
    'KST011' '' '' '' '15' 'FG Cost' '' '' '' '' '' 'WAERS' '' '' ''
    '' '' '' '' '' '',
    'TOTAL' '' '' '' '15' 'Total' '' '' '' '' '' 'WAERS' '' '' '' '' ''
    '' '' '' '',
    'MESSAGE' '' '' '' '100' 'Message Post' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-sel_mode            = 'A'.
ENDFORM.                    " F_BUILD_LAYOUT

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
                           value(fu_decimals_o).

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

  APPEND lv_fieldcat TO gt_fieldcat.
  CLEAR lv_fieldcat.
ENDFORM.                    " F_FIELDCATG

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
*&      Form  F_COST_CALCULATE
*&---------------------------------------------------------------------*
FORM f_cost_calculate  USING    fu_ckmlkeph   STRUCTURE ckmlkeph
                       CHANGING fc_calc STRUCTURE gt_calc.

  CASE fu_ckmlkeph-categ.
    WHEN 'EB'.
      ADD fu_ckmlkeph-kst001 TO fc_calc-eb001.
      ADD fu_ckmlkeph-kst003 TO fc_calc-eb003.
      ADD fu_ckmlkeph-kst005 TO fc_calc-eb005.
      ADD fu_ckmlkeph-kst007 TO fc_calc-eb007.
      ADD fu_ckmlkeph-kst009 TO fc_calc-eb009.
      ADD fu_ckmlkeph-kst011 TO fc_calc-eb011.
    WHEN 'AB'.
      ADD fu_ckmlkeph-kst001 TO fc_calc-ab001.
      ADD fu_ckmlkeph-kst003 TO fc_calc-ab003.
      ADD fu_ckmlkeph-kst005 TO fc_calc-ab005.
      ADD fu_ckmlkeph-kst007 TO fc_calc-ab007.
      ADD fu_ckmlkeph-kst009 TO fc_calc-ab009.
      ADD fu_ckmlkeph-kst011 TO fc_calc-ab011.
    WHEN 'ZU'.
      ADD fu_ckmlkeph-kst001 TO fc_calc-zu001.
      ADD fu_ckmlkeph-kst003 TO fc_calc-zu003.
      ADD fu_ckmlkeph-kst005 TO fc_calc-zu005.
      ADD fu_ckmlkeph-kst007 TO fc_calc-zu007.
      ADD fu_ckmlkeph-kst009 TO fc_calc-zu009.
      ADD fu_ckmlkeph-kst011 TO fc_calc-zu011.
    WHEN 'VN'.
      ADD fu_ckmlkeph-kst001 TO fc_calc-vn001.
      ADD fu_ckmlkeph-kst003 TO fc_calc-vn003.
      ADD fu_ckmlkeph-kst005 TO fc_calc-vn005.
      ADD fu_ckmlkeph-kst007 TO fc_calc-vn007.
      ADD fu_ckmlkeph-kst009 TO fc_calc-vn009.
      ADD fu_ckmlkeph-kst011 TO fc_calc-vn011.
  ENDCASE.
ENDFORM.                    " F_COST_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting USING fu_type.
  DATA : lt_ipdata    TYPE TABLE OF bapi_copa_data,
         lt_flist     TYPE TABLE OF bapi_copa_field,
         lt_ret       TYPE TABLE OF bapiret2 WITH HEADER LINE.

  DATA : lt_out       LIKE gt_out OCCURS 0,
         ls_out       LIKE LINE OF gt_out,
         lv_budat     TYPE datum,
         lv_vrgar     TYPE rke_vrgar,
         lv_perio(7),
         lv_rec(6).

  DATA: et_index_rows TYPE lvc_t_row,
        et_row_no     TYPE lvc_t_roid,
        wa_et_row_no  LIKE LINE OF et_row_no,
        n             TYPE i,
        row_id        TYPE i.

  CLEAR: et_index_rows,et_row_no.

  CALL METHOD g_outgrid->get_selected_rows
    IMPORTING
      et_index_rows = et_index_rows
      et_row_no     = et_row_no.

  DESCRIBE TABLE et_index_rows LINES n.

  IF n GT 0.
    LOOP AT et_row_no INTO wa_et_row_no.
      READ TABLE gt_out INTO ls_out INDEX wa_et_row_no-row_id.
      IF sy-subrc = 0.
        APPEND ls_out TO lt_out.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CASE fu_type.
    WHEN 'POST'.
*      lt_out[] = gt_out[].
      DELETE lt_out WHERE status = 'POSTED'.
    WHEN 'REVS'.
*      lt_out[] = gt_out[].
      DELETE lt_out WHERE status NE 'POSTED'.
  ENDCASE.

  IF lt_out[] IS INITIAL.
    CASE fu_type.
      WHEN 'POST'.
        MESSAGE 'No data to be POST' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 'REVS'.
        MESSAGE 'No data to be REVERSE' TYPE 'S' DISPLAY LIKE 'E'.
    ENDCASE.

  ELSE.
    LOOP AT lt_out INTO ls_out.
      CLEAR : lv_budat,lv_vrgar,lv_perio,lv_rec.

      CONCATENATE ls_out-bdatj ls_out-poper INTO lv_perio.
      lv_rec    = '000001'.
      lv_vrgar  = 'B'.

      PERFORM f_get_budat USING     ls_out-poper
                                    ls_out-bdatj
                                    ls_out-bwkey
                          CHANGING  lv_budat.

      CASE fu_type.
        WHEN 'POST'.
        WHEN 'REVS'.
          MULTIPLY: ls_out-kst001 BY -1,
                    ls_out-kst003 BY -1,
                    ls_out-kst005 BY -1,
                    ls_out-kst007 BY -1,
                    ls_out-kst009 BY -1,
                    ls_out-kst011 BY -1.
          ls_out-total = ls_out-kst001 + ls_out-kst003 +
                         ls_out-kst005 + ls_out-kst007 +
                         ls_out-kst009 + ls_out-kst011.
      ENDCASE.

      PERFORM f_post_data TABLES lt_ipdata lt_flist lt_ret
                          USING:
        'KOKRS' '8010'        lv_rec '' '',
        'BUDAT' lv_budat      lv_rec '' '',
        'PERIO' lv_perio      lv_rec '' '',
        'GJAHR' ls_out-bdatj  lv_rec '' '',
        'VRGAR' lv_vrgar      lv_rec '' '',
        'BUKRS' gv_bukrs      lv_rec '' '',
        'ARTNR' ls_out-matnr  lv_rec '' '',
        'WERKS' ls_out-bwkey  lv_rec '' '',
        'PRCTR' ls_out-prctr  lv_rec '' '',
        'GSBER' ls_out-bwkey  lv_rec '' '',
        'VVD11' ls_out-kst001 lv_rec '1' ls_out-waers,
        'VVD12' ls_out-kst003 lv_rec '1' ls_out-waers,
        'VVD13' ls_out-kst005 lv_rec '1' ls_out-waers,
        'VVD14' ls_out-kst007 lv_rec '1' ls_out-waers,
        'VVD15' ls_out-kst009 lv_rec '1' ls_out-waers,
        'VVD16' ls_out-kst011 lv_rec '1' ls_out-waers,
        'VVD00' ls_out-total  lv_rec '1' ls_out-waers.

      CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
        EXPORTING
          operatingconcern = '8010'
          testrun          = space
        TABLES
          inputdata        = lt_ipdata
          fieldlist        = lt_flist
          return           = lt_ret.

      READ TABLE lt_ret WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
        ls_out-message = lt_ret-message.

      ELSE.
        READ TABLE lt_ret WITH KEY type = 'A'.
        IF sy-subrc EQ 0.
          ls_out-message = lt_ret-message.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          PERFORM f_save_ztable USING fu_type
                                      gv_bukrs
                                      ls_out-bwkey
                                      ls_out-bdatj
                                      ls_out-poper
                                      ls_out-matnr.

          CASE fu_type.
            WHEN 'POST'.
              ls_out-message = 'Successfully Post'.
              ls_out-status = 'POSTED'.
            WHEN 'REVS'.
              ls_out-message = 'Successfully Reverse'.
              CLEAR ls_out-status.
          ENDCASE.
        ENDIF.
      ENDIF.

      gt_out-message = ls_out-message.
      gt_out-status  = ls_out-status.
      MODIFY gt_out TRANSPORTING message status
        WHERE bwkey = ls_out-bwkey
          AND poper = ls_out-poper
          AND bdatj = ls_out-bdatj
          AND matnr = ls_out-matnr.

      CLEAR: lt_ipdata, lt_ipdata[],
             lt_flist, lt_flist[],
             lt_ret, lt_ret[].
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data  TABLES   ft_ipdata STRUCTURE bapi_copa_data
                           ft_flist STRUCTURE bapi_copa_field
                           ft_ret STRUCTURE bapiret2
                  USING    fu_fieldname fu_value
                           fu_rec fu_flag fu_waers.
  DATA : lwa_ipdata   LIKE LINE OF ft_ipdata,
         lwa_flist    LIKE LINE OF ft_flist.

  DATA: lv_value(50).

  CLEAR sy-subrc.

  CASE fu_flag.
    WHEN 1.
      WRITE fu_value TO lv_value CURRENCY fu_waers.
      WHILE sy-subrc EQ 0.
        REPLACE '.' WITH space INTO lv_value.
      ENDWHILE.
      CONDENSE lv_value NO-GAPS.
  ENDCASE.

  CLEAR: lwa_ipdata.
  lwa_ipdata-record_id = fu_rec.
  lwa_ipdata-fieldname = fu_fieldname.

  CASE fu_flag.
    WHEN 1.
      lwa_ipdata-value     = lv_value.
      lwa_ipdata-currency  = fu_waers.
    WHEN OTHERS.
      lwa_ipdata-value     = fu_value.
  ENDCASE.

  APPEND lwa_ipdata TO ft_ipdata.
  lwa_flist-fieldname  = lwa_ipdata-fieldname.
  APPEND lwa_flist TO ft_flist.
ENDFORM.                    " F_POST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDAT
*&---------------------------------------------------------------------*
FORM f_get_budat  USING    fu_poper
                           fu_bdatj
                           fu_bwkey
                  CHANGING fc_budat.
  DATA: lv_date TYPE datum.

  CONCATENATE fu_bdatj fu_poper+1(2) '01' INTO lv_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_date
    IMPORTING
      last_day_of_month = fc_budat.
ENDFORM.                    " F_GET_BUDAT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_ZTABLE
*&---------------------------------------------------------------------*
FORM f_save_ztable  USING    fu_type
                             fu_bukrs
                             fu_bwkey
                             fu_bdatj
                             fu_poper
                             fu_matnr.
  DATA: ls_zcodt009 TYPE zcodt009,
        lr_cx       TYPE REF TO cx_root.

  ls_zcodt009-bukrs   = fu_bukrs.
  ls_zcodt009-werks   = fu_bwkey.
  ls_zcodt009-bdatj   = fu_bdatj.
  ls_zcodt009-poper   = fu_poper.
  ls_zcodt009-matnr   = fu_matnr.
  ls_zcodt009-zuser   = sy-uname.
  ls_zcodt009-tglprs  = sy-datum.

  CASE fu_type.
    WHEN 'POST'.
      TRY .
          INSERT zcodt009 FROM ls_zcodt009.
        CATCH cx_sy_open_sql_db INTO lr_cx.

      ENDTRY.
    WHEN 'REVS'.
      TRY .
          DELETE zcodt009 FROM ls_zcodt009.
        CATCH cx_sy_open_sql_db INTO lr_cx.

      ENDTRY.
  ENDCASE.

ENDFORM.                    " F_SAVE_ZTABLE
