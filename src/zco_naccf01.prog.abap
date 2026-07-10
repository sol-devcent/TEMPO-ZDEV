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
  TYPES : BEGIN OF ty_date,
            budat   TYPE sy-datum,
          END OF ty_date.

  DATA : lt_marc    TYPE STANDARD TABLE OF marc,
         lr_budat   TYPE RANGE OF budat,
         ls_budat   LIKE LINE OF lr_budat,
         lt_date    TYPE STANDARD TABLE OF ty_date,
         ls_date    LIKE LINE OF lt_date,
         lv_subrc   TYPE sy-subrc.

  DATA : lt_mkpf    TYPE STANDARD TABLE OF ty_mkpf,
         ls_mkpf    LIKE LINE OF lt_mkpf,
         ls_marc    LIKE LINE OF gt_marc.

  CONCATENATE pa_bdatj so_poper-low+1(2) '01' INTO ls_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_budat-low
    IMPORTING
      last_day_of_month = ls_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  WHILE lv_subrc IS INITIAL.
    IF ls_budat-low = ls_budat-high.
      lv_subrc  = 4.
    ENDIF.
    ls_date-budat = ls_budat-low.
    APPEND ls_date TO lt_date.
    ls_budat-low = ls_budat-low + 1.
  ENDWHILE.

  ls_budat-sign   = 'I'.
  ls_budat-option = 'BT'.
  APPEND ls_budat TO lr_budat.
  CLEAR ls_budat.

  PERFORM f_categ USING : 'VN'.

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
          AND kkzst = space
          AND categ IN gr_categ.
*          AND mlcct IN ('E','F').

      CASE 'X'.
        WHEN radio1.
        WHEN OTHERS.
          SELECT mblnr mjahr
            FROM mkpf
            INTO CORRESPONDING FIELDS OF TABLE lt_mkpf
            FOR ALL ENTRIES IN lt_date
            WHERE budat = lt_date-budat.
          IF lt_mkpf[] IS NOT INITIAL.
            LOOP AT lt_mkpf INTO ls_mkpf.
              LOOP AT gt_marc INTO ls_marc.
                ls_mkpf-matnr = ls_marc-matnr.
                APPEND ls_mkpf TO gt_mkpf.
                CLEAR ls_mkpf-matnr.
              ENDLOOP.
              CLEAR ls_mkpf.
            ENDLOOP.

            SELECT *
              FROM mseg
              INTO CORRESPONDING FIELDS OF TABLE gt_mseg
              FOR ALL ENTRIES IN gt_mkpf
              WHERE mblnr = gt_mkpf-mblnr
                AND mjahr = gt_mkpf-mjahr
                AND bwart = '641'
                AND xauto = space
                AND matnr = gt_mkpf-matnr.

            SORT gt_mseg BY matnr.
            DELETE ADJACENT DUPLICATES FROM gt_mseg COMPARING matnr.
          ENDIF.
      ENDCASE.
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

  DATA : ls_mseg  LIKE LINE OF gt_mseg,
         lv_subrc TYPE sy-subrc.

  lt_matledgr[] = gt_ckmlkeph[].
  SORT lt_matledgr BY kalnr bdatj poper.
  DELETE ADJACENT DUPLICATES FROM lt_matledgr COMPARING kalnr bdatj poper.

  SORT gt_mbew BY matnr bwkey.
  SORT gt_marc BY matnr werks.
  SORT gt_mara BY matnr.

  LOOP AT gt_mbew INTO ls_mbew.
    gt_out-bwkey  = ls_mbew-bwkey.
    gt_out-matnr  = ls_mbew-matnr.

    CASE 'X'.
      WHEN radio2.
        CLEAR : ls_mseg, lv_subrc.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY matnr = ls_mbew-matnr.
        lv_subrc = sy-subrc.
    ENDCASE.

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

    IF lv_subrc IS INITIAL.
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

*        gt_out-kst001 = ls_calc-vn001x - ls_calc-vn001y. "- ls_calc-vn001z - ls_calc-vn001w.
*        gt_out-kst003 = ls_calc-vn003x - ls_calc-vn003y. "- ls_calc-vn003z - ls_calc-vn001w.
        gt_out-kst005 = ls_calc-vn005x - ls_calc-vn005y. "- ls_calc-vn005z - ls_calc-vn001w.
        gt_out-kst007 = ls_calc-vn007x - ls_calc-vn007y. "- ls_calc-vn007z - ls_calc-vn001w.
        gt_out-kst009 = ls_calc-vn009x - ls_calc-vn009y. "- ls_calc-vn009z - ls_calc-vn001w.
        gt_out-kst011 = ls_calc-vn011x - ls_calc-vn011y. "- ls_calc-vn011z - ls_calc-vn001w.

        CASE gt_out-prctr.
          WHEN 'RAWMAT'.
            gt_out-kst001 = ls_calc-vn001x.
            PERFORM f_koreksi_kst001 USING ls_matledgr gt_out-prctr
                                     CHANGING gt_out-kst001.
          WHEN 'PACKMAT'.
            gt_out-kst003 = ls_calc-vn003x.
            PERFORM f_koreksi_kst001 USING ls_matledgr gt_out-prctr
                                     CHANGING gt_out-kst003.
          WHEN OTHERS.
            gt_out-kst001 = ls_calc-vn001x - ls_calc-vn001y.
            gt_out-kst003 = ls_calc-vn003x - ls_calc-vn003y.
        ENDCASE.

        gt_out-total = gt_out-kst001 + gt_out-kst003 + gt_out-kst005 + gt_out-kst007 +
                       gt_out-kst009 + gt_out-kst011.

        IF gt_out-total <> 0.
          APPEND gt_out.
        ENDIF.
        CLEAR : ls_calc.
      ENDLOOP.
    ELSE.
      gt_out-poper  = so_poper-low.
      gt_out-bdatj  = pa_bdatj.
      gt_out-waers  = 'IDR'.
      APPEND gt_out.
    ENDIF.

    CLEAR : gt_out, ls_mbew, ls_makt, ls_mara, ls_t023t, ls_marc,
            ls_ckmlkeph.
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

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
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
                event_receiver->handle_double_click
                event_receiver->on_hotspot_click
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

    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  PERFORM f_alv_refresh.
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
    'MATNR' 'MBEW' 'MATNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '' ''
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
    '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
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
      CASE fu_ckmlkeph-ptyp.
        WHEN space.
          ADD fu_ckmlkeph-kst001 TO fc_calc-vn001x.
          ADD fu_ckmlkeph-kst003 TO fc_calc-vn003x.
          ADD fu_ckmlkeph-kst005 TO fc_calc-vn005x.
          ADD fu_ckmlkeph-kst007 TO fc_calc-vn007x.
          ADD fu_ckmlkeph-kst009 TO fc_calc-vn009x.
          ADD fu_ckmlkeph-kst011 TO fc_calc-vn011x.
*        WHEN 'V+'.
*          ADD fu_ckmlkeph-kst001 TO fc_calc-vn001y.
*          ADD fu_ckmlkeph-kst003 TO fc_calc-vn003y.
*          ADD fu_ckmlkeph-kst005 TO fc_calc-vn005y.
*          ADD fu_ckmlkeph-kst007 TO fc_calc-vn007y.
*          ADD fu_ckmlkeph-kst009 TO fc_calc-vn009y.
*          ADD fu_ckmlkeph-kst011 TO fc_calc-vn011y.
*        WHEN 'VF'.
*          ADD fu_ckmlkeph-kst001 TO fc_calc-vn001z.
*          ADD fu_ckmlkeph-kst003 TO fc_calc-vn003z.
*          ADD fu_ckmlkeph-kst005 TO fc_calc-vn005z.
*          ADD fu_ckmlkeph-kst007 TO fc_calc-vn007z.
*          ADD fu_ckmlkeph-kst009 TO fc_calc-vn009z.
*          ADD fu_ckmlkeph-kst011 TO fc_calc-vn011z.
*        WHEN 'VW'.
*          ADD fu_ckmlkeph-kst001 TO fc_calc-vn001w.
*          ADD fu_ckmlkeph-kst003 TO fc_calc-vn003w.
*          ADD fu_ckmlkeph-kst005 TO fc_calc-vn005w.
*          ADD fu_ckmlkeph-kst007 TO fc_calc-vn007w.
*          ADD fu_ckmlkeph-kst009 TO fc_calc-vn009w.
*          ADD fu_ckmlkeph-kst011 TO fc_calc-vn011w.
        WHEN OTHERS.
          ADD fu_ckmlkeph-kst001 TO fc_calc-vn001y.
          ADD fu_ckmlkeph-kst003 TO fc_calc-vn003y.
          ADD fu_ckmlkeph-kst005 TO fc_calc-vn005y.
          ADD fu_ckmlkeph-kst007 TO fc_calc-vn007y.
          ADD fu_ckmlkeph-kst009 TO fc_calc-vn009y.
          ADD fu_ckmlkeph-kst011 TO fc_calc-vn011y.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_COST_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column fu_row_no.
  DATA : ls_out   LIKE LINE OF gt_out.

  CLEAR ls_out.
  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF sy-subrc = 0.
    SET PARAMETER ID 'MAT' FIELD ls_out-matnr.
    SET PARAMETER ID 'WRK' FIELD ls_out-bwkey.
    SET PARAMETER ID 'POPR' FIELD ls_out-poper.
    SET PARAMETER ID 'BDTJ' FIELD ls_out-bdatj.
    CALL TRANSACTION 'CKM3'.
  ENDIF.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_ON_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM f_on_hotspot_click  USING    fu_row_id fu_row_no.
  DATA : ls_out   LIKE LINE OF gt_out.

  CLEAR ls_out.
  READ TABLE gt_out INTO ls_out INDEX fu_row_id.
  IF sy-subrc = 0.
    CALL FUNCTION 'CKM8N_ML_DATA_DISPLAY'
      EXPORTING
        i_matnr = ls_out-matnr
        i_bwkey = ls_out-bwkey
        i_bdatj = ls_out-bdatj
        i_poper = ls_out-poper.
  ENDIF.
ENDFORM.                    " F_ON_HOTSPOT_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen USING   fu_group fu_active fu_input fu_invisible
                             fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF..

ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_KOREKSI_KST001
*&---------------------------------------------------------------------*
FORM f_koreksi_kst001  USING    fs_matledgr TYPE ckmlkeph
                                fu_prctr
                       CHANGING fc_kst001.
  DATA: lv_estprd LIKE mlcd-estprd,
        lv_estkdm LIKE mlcd-estkdm.

  SELECT SUM( estprd ) sum( estkdm )
    INTO (lv_estprd, lv_estkdm)
    FROM mlcd WHERE kalnr   = fs_matledgr-kalnr
                AND bdatj   = fs_matledgr-bdatj
                AND poper   = fs_matledgr-poper
                AND untper  = fs_matledgr-untper
                AND categ   = fs_matledgr-categ.
  fc_kst001 = fc_kst001 - lv_estprd - lv_estkdm.
ENDFORM.                    " F_KOREKSI_KST001
