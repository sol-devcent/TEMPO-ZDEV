*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  IF p_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' '0'.
  ENDIF.
  IF p_gsber IS INITIAL.
    PERFORM f_error_selection_screen USING 'GSB' '0'.
  ENDIF.
  IF p_perio IS INITIAL.
    PERFORM f_error_selection_screen USING 'PER' '0'.
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
  PERFORM f_get_document_status.
  PERFORM f_get_posting_date.
  PERFORM f_get_gl_account.

  SELECT bukrs belnr gjahr blart budat monat bstat
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FROM bkpf WHERE bukrs EQ p_bukrs
                AND bstat IN gr_bstat
                AND budat IN gr_budat
    ORDER BY PRIMARY KEY.

  IF gt_bkpf[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr buzei shkzg gsber dmbtr
           matnr werks menge meins bwkey
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM bseg FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs EQ gt_bkpf-bukrs
        AND belnr EQ gt_bkpf-belnr
        AND gjahr EQ gt_bkpf-gjahr
        AND ( gsber EQ p_gsber OR bwkey EQ p_gsber )
        AND hkont IN gr_hkont
      ORDER BY PRIMARY KEY.

    IF sy-subrc = '0'.
      LOOP AT gt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>)
                      WHERE gsber IS INITIAL.
        <fs_bseg>-gsber = <fs_bseg>-bwkey.
      ENDLOOP.
    ENDIF.
  ENDIF.

  SELECT paledger vrgar versi perio paobjnr pasubnr belnr posnr
         gjahr budat artnr bukrs gsber vvd00 vvd11 vvd12 vvd13
         vvd14 vvd15 vvd16 vv845
    INTO CORRESPONDING FIELDS OF TABLE gt_ce18010
    FROM ce18010 WHERE bukrs  EQ p_bukrs
                   AND gsber  EQ p_gsber
                   AND perio  EQ p_perio
                   AND paledger EQ '01'   "Konversi dr 'B0'
                   AND vrgar  IN ('B','F')
*                   AND prctr NOT IN ('RAWMAT_CPC','PACKMT_CPC')
                   AND skost  EQ space
    ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: lt_zcodt011 TYPE STANDARD TABLE OF zcodt011,
        ls_zcodt011 LIKE LINE OF lt_zcodt011,
        ls_zcor018  LIKE LINE OF gt_zcor018,
        ls_bkpf     LIKE LINE OF gt_bkpf,
        ls_bseg     LIKE LINE OF gt_bseg,
        ls_ce18010  LIKE LINE OF gt_ce18010,
        ls_makt     LIKE LINE OF gt_makt,
        ls_marc     LIKE LINE OF gt_marc,
        ls_celltab  TYPE lvc_s_styl,
        lv_perio    TYPE jahrper,
        lv_gjahr    TYPE gjahr,
        lv_bdatj    TYPE bdatj,
        lv_poper    TYPE poper.

  lv_bdatj = p_perio(4).
  lv_poper = p_perio+4(3).
  PERFORM f_get_data_zcor018 USING p_gsber lv_poper lv_bdatj.

  LOOP AT gt_bseg INTO ls_bseg.
    CASE ls_bseg-matnr(1).
      WHEN '0' OR '1' OR '2' OR '3' OR '4' OR '5' OR '6' OR '7' OR
           '8' OR '9' OR 'F'.
        "Do nothing
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    IF ls_bseg-shkzg = 'H'.
      MULTIPLY ls_bseg-dmbtr BY -1.
    ENDIF.

    CLEAR: ls_bkpf,lv_perio,lv_gjahr.
    READ TABLE gt_bkpf INTO ls_bkpf WITH KEY bukrs = ls_bseg-bukrs
                                             belnr = ls_bseg-belnr
                                             gjahr = ls_bseg-gjahr.

    CONCATENATE ls_bkpf-budat(4) '0' ls_bkpf-budat+4(2) INTO lv_perio.
    lv_gjahr = ls_bkpf-budat(4).

    READ TABLE gt_out ASSIGNING <fs_out> WITH KEY bukrs = ls_bseg-bukrs
                                                  gsber = ls_bseg-gsber
                                                  perio = lv_perio
                                                  gjahr = lv_gjahr
                                                  artnr = ls_bseg-matnr.
    IF sy-subrc = 0.
      ADD ls_bseg-dmbtr TO <fs_out>-dmbtr.
    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-bukrs = ls_bseg-bukrs.
      <fs_out>-gsber = ls_bseg-gsber.
      <fs_out>-perio = lv_perio.
      <fs_out>-gjahr = lv_gjahr.
      <fs_out>-artnr = ls_bseg-matnr.
      <fs_out>-dmbtr = ls_bseg-dmbtr.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_ce18010 INTO ls_ce18010.
    lv_gjahr = ls_ce18010-perio(4).
    READ TABLE gt_out ASSIGNING <fs_out> WITH KEY bukrs = ls_ce18010-bukrs
                                                  gsber = ls_ce18010-gsber
                                                  perio = ls_ce18010-perio
                                                  gjahr = lv_gjahr
                                                  artnr = ls_ce18010-artnr.
    IF sy-subrc = 0.
*      ADD ls_ce18010-vvd00 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd11 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd12 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd13 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd14 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd15 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd16 TO <fs_out>-vvd00.
      ADD ls_ce18010-vvd11 TO <fs_out>-vvd11.
      ADD ls_ce18010-vvd12 TO <fs_out>-vvd12.
      ADD ls_ce18010-vvd13 TO <fs_out>-vvd13.
      ADD ls_ce18010-vvd14 TO <fs_out>-vvd14.
      ADD ls_ce18010-vvd15 TO <fs_out>-vvd15.
      ADD ls_ce18010-vvd16 TO <fs_out>-vvd16.
      IF p_bukrs = '8230'.
        ADD ls_ce18010-vv845 TO <fs_out>-vvd00.
        ADD ls_ce18010-vv845 TO <fs_out>-vv845.
      ENDIF.
    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-bukrs = ls_ce18010-bukrs.
      <fs_out>-gsber = ls_ce18010-gsber.
      <fs_out>-perio = ls_ce18010-perio.
      <fs_out>-gjahr = lv_gjahr.
      <fs_out>-artnr = ls_ce18010-artnr.
      <fs_out>-vvd11 = ls_ce18010-vvd11.
      <fs_out>-vvd12 = ls_ce18010-vvd12.
      <fs_out>-vvd13 = ls_ce18010-vvd13.
      <fs_out>-vvd14 = ls_ce18010-vvd14.
      <fs_out>-vvd15 = ls_ce18010-vvd15.
      <fs_out>-vvd16 = ls_ce18010-vvd16.
      <fs_out>-vvd00 = ls_ce18010-vvd11 + ls_ce18010-vvd12 + ls_ce18010-vvd13 +
                       ls_ce18010-vvd14 + ls_ce18010-vvd15 + ls_ce18010-vvd16.
      IF p_bukrs = '8230'.
        <fs_out>-vv845 = ls_ce18010-vv845.
        ADD ls_ce18010-vv845 TO <fs_out>-vvd00.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_out[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_zcodt011
      FROM zcodt011 FOR ALL ENTRIES IN gt_out
      WHERE bukrs = p_bukrs
        AND gsber = p_gsber
        AND perio = p_perio
        AND matnr = gt_out-artnr
      ORDER BY PRIMARY KEY.

    SELECT matnr spras maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_out
      WHERE matnr = gt_out-artnr
        AND spras = sy-langu
      ORDER BY PRIMARY KEY.

    SELECT matnr werks prctr
      INTO CORRESPONDING FIELDS OF TABLE gt_marc
      FROM marc FOR ALL ENTRIES IN gt_out
      WHERE matnr EQ gt_out-artnr
        AND werks EQ p_gsber
      ORDER BY PRIMARY KEY.

    SORT: gt_out  BY artnr gsber,
          gt_makt BY matnr,
          gt_marc BY matnr werks.

    LOOP AT gt_out ASSIGNING <fs_out>.
      IF <fs_out>-dmbtr IS INITIAL AND <fs_out>-vvd00 IS INITIAL.
        DELETE TABLE gt_out FROM <fs_out>.
        CONTINUE.
      ENDIF.

      CLEAR: ls_makt,ls_marc.
      READ TABLE gt_makt INTO ls_makt WITH KEY matnr = <fs_out>-artnr
                                               BINARY SEARCH.
      READ TABLE gt_marc INTO ls_marc WITH KEY matnr = <fs_out>-artnr
                                               werks = <fs_out>-gsber
                                               BINARY SEARCH.
      <fs_out>-maktx = ls_makt-maktx.
      <fs_out>-prctr = ls_marc-prctr.
      <fs_out>-variant = <fs_out>-dmbtr - <fs_out>-vvd00.
      <fs_out>-waers = 'IDR'.

      READ TABLE lt_zcodt011 INTO ls_zcodt011
                             WITH KEY bukrs = <fs_out>-bukrs
                                      gsber = <fs_out>-gsber
                                      perio = <fs_out>-perio
                                      matnr = <fs_out>-artnr.
      IF sy-subrc = 0.
        <fs_out>-posval = ls_zcodt011-posval.
        <fs_out>-message = <fs_out>-status = 'POSTED'.
      ELSE.
        CLEAR: <fs_out>-message,<fs_out>-status.
      ENDIF.

      CASE 'X'.
        WHEN p_post.
          IF <fs_out>-variant IS INITIAL OR <fs_out>-status = 'POSTED'.
            ls_celltab-fieldname = 'CHKBOX'.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_celltab TO <fs_out>-celltab.
            CLEAR ls_celltab.
          ELSE.
            READ TABLE gt_zcor018 INTO ls_zcor018
                                  WITH KEY "bukrs = p_bukrs
                                           bwkey = p_gsber
                                           poper = lv_poper
                                           bdatj = lv_bdatj
                                           matnr = <fs_out>-artnr.
            IF sy-subrc = 0 AND ls_zcor018-status NE 'POSTED'.
              ls_celltab-fieldname = 'CHKBOX'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
              APPEND ls_celltab TO <fs_out>-celltab.
              CLEAR ls_celltab.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          IF <fs_out>-status NE 'POSTED'.
            ls_celltab-fieldname = 'CHKBOX'.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_celltab TO <fs_out>-celltab.
            CLEAR ls_celltab.
          ENDIF.
      ENDCASE.
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

    gs_variant-report = sy-repid.   "gv_repid.
    gs_variant-report = sy-uname.

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
    'CHKBOX' '' '' '' '3' 'Cek' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' 'X',
    'BUKRS' 'CE18010' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'GSBER' 'CE18010' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'PERIO' 'CE18010' 'PERIO' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'ARTNR' 'CE18010' 'ARTNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' 'X',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' 'X',
    'PRCTR' 'MARC' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'WAERS' 'T001' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'DMBTR' 'BSEG' 'DMBTR' '' '' 'COGS-FI' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD00' 'CE18010' 'VVD00' '' '' 'COGS-COPA' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD11' 'CE18010' 'VVD11' 'X' '' 'COGS RM' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD12' 'CE18010' 'VVD12' 'X' '' 'COGS PM' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD13' 'CE18010' 'VVD13' 'X' '' 'COGS Labor' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD14' 'CE18010' 'VVD14' 'X' '' 'COGS Machine' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD15' 'CE18010' 'VVD15' 'X' '' 'COGS Man. Fee' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VVD16' 'CE18010' 'VVD16' 'X' '' 'COGS FG' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VV845' 'CE18010' 'VV845' 'X' '' 'Overhead Cost' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'VARIANT' 'CE18010' 'VVD00' '' '' 'Variant' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'POSVAL' 'ZCODT011' 'POSVAL' '' '' '' '' '' '' '' '' 'WAERS' '' ''
    '' '' '' '' '' '' '' '',
    'MESSAGE' '' '' '' '100' 'Message Post' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-sel_mode            = 'A'.
  gs_layout_alv-no_rowmark          = 'X'.
  gs_layout_alv-cwidth_opt          = 'X'.
  gs_layout_alv-box_fname           = 'CHKBOX'.
  gs_layout_alv-stylefname          = 'CELLTAB'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB
*&---------------------------------------------------------------------*
FORM f_build_sort_tab .
  gt_sort_grid-fieldname = 'BUKRS'.
  gt_sort_grid-up        = 'X'.
  APPEND gt_sort_grid. CLEAR gt_sort_grid.

  gt_sort_grid-fieldname = 'GSBER'.
  gt_sort_grid-up        = 'X'.
  APPEND gt_sort_grid. CLEAR gt_sort_grid.

  gt_sort_grid-fieldname = 'PERIO'.
  gt_sort_grid-up        = 'X'.
  APPEND gt_sort_grid. CLEAR gt_sort_grid.

  gt_sort_grid-fieldname = 'ARTNR'.
  gt_sort_grid-up        = 'X'.
  APPEND gt_sort_grid. CLEAR gt_sort_grid.
ENDFORM.                    " F_BUILD_SORT_TAB

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING    VALUE(fu_types)
                           VALUE(fu_fname)
                           VALUE(fu_reftb)
                           VALUE(fu_refld)
                           VALUE(fu_noout)
                           VALUE(fu_outln)
                           VALUE(fu_fltxt)
                           VALUE(fu_dosum)
                           VALUE(fu_hotsp)
                           VALUE(fu_colpos)
                           VALUE(fu_waers)
                           VALUE(fu_meins)
                           VALUE(fu_waers_f)
                           VALUE(fu_meins_f)
                           VALUE(fu_checkbox)
                           VALUE(fu_input)
                           VALUE(fu_icon)
                           VALUE(fu_just)
                           VALUE(fu_edit)
                           VALUE(fu_colopt)
                           VALUE(fu_emphasize)
                           VALUE(fu_decimals_o)
                           VALUE(fu_fix_column).

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
  lv_fieldcat-fix_column        = fu_fix_column.

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
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting USING fu_type.
  DATA : lt_ipdata TYPE TABLE OF bapi_copa_data,
         lt_flist  TYPE TABLE OF bapi_copa_field,
         lt_ret    TYPE TABLE OF bapiret2 WITH HEADER LINE.

  DATA : lt_out      LIKE gt_out OCCURS 0,
         ls_out      LIKE LINE OF gt_out,
         ls_celltab  TYPE lvc_s_styl,
         lv_budat    TYPE datum,
         lv_vrgar    TYPE rke_vrgar,
         lv_perio(7),
         lv_rec(6).

  DATA: et_index_rows TYPE lvc_t_row,
        et_row_no     TYPE lvc_t_roid,
        wa_et_row_no  LIKE LINE OF et_row_no,
        n             TYPE i,
        row_id        TYPE i.

*  CLEAR: et_index_rows,et_row_no.
*
*  CALL METHOD g_outgrid->get_selected_rows
*    IMPORTING
*      et_index_rows = et_index_rows
*      et_row_no     = et_row_no.
*
*  DESCRIBE TABLE et_index_rows LINES n.
*
*  IF n GT 0.
*    LOOP AT et_row_no INTO wa_et_row_no.
*      READ TABLE gt_out INTO ls_out INDEX wa_et_row_no-row_id.
*      IF sy-subrc = 0.
*        APPEND ls_out TO lt_out.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE chkbox IS INITIAL.

  CASE fu_type.
    WHEN 'POST'.
      DELETE lt_out WHERE status = 'POSTED'.
    WHEN 'REVS'.
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

      lv_perio  = ls_out-perio.
      lv_rec    = '000001'.
      lv_vrgar  = 'B'.

      PERFORM f_get_budat USING     ls_out-perio
                          CHANGING  lv_budat.

      CASE fu_type.
        WHEN 'POST'.
        WHEN 'REVS'.
*          MULTIPLY: ls_out-variant BY -1.
          ls_out-variant = ls_out-posval * -1.
      ENDCASE.

      PERFORM f_post_data TABLES lt_ipdata lt_flist lt_ret
                          USING:
        'KOKRS' '8010'        lv_rec '' '',
        'BUDAT' lv_budat      lv_rec '' '',
        'PERIO' lv_perio      lv_rec '' '',
        'GJAHR' ls_out-gjahr  lv_rec '' '',
        'VRGAR' lv_vrgar      lv_rec '' '',
        'BUKRS' ls_out-bukrs  lv_rec '' '',
        'ARTNR' ls_out-artnr  lv_rec '' '',
        'WERKS' ls_out-gsber  lv_rec '' '',
        'PRCTR' ls_out-prctr  lv_rec '' '',
        'GSBER' ls_out-gsber  lv_rec '' '',
        'VVD00' ls_out-variant  lv_rec '1' ls_out-waers,
        'VVD11' ls_out-variant  lv_rec '1' ls_out-waers.

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
                                      ls_out-bukrs
                                      ls_out-gsber
                                      ls_out-perio
                                      ls_out-artnr
                                      ls_out-variant
                                      ls_out-waers.

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

      gt_out-chkbox  = space.
      gt_out-message = ls_out-message.
      gt_out-status  = ls_out-status.

      CASE fu_type.
        WHEN 'POST'.
          gt_out-vvd00 = ls_out-vvd00 + ls_out-variant.
          gt_out-posval  = ls_out-variant.
          gt_out-variant = 0.
        WHEN 'REVS'.
          gt_out-vvd00 = ls_out-vvd00 - ls_out-posval.
          gt_out-variant = ls_out-posval.
          gt_out-posval = 0.
      ENDCASE.

      CLEAR ls_celltab. CLEAR gt_out-celltab.
      ls_celltab-fieldname = 'CHKBOX'.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
      APPEND ls_celltab TO gt_out-celltab.

      MODIFY gt_out TRANSPORTING chkbox message status posval variant vvd00 celltab
        WHERE bukrs = ls_out-bukrs
          AND gsber = ls_out-gsber
          AND perio = ls_out-perio
          AND artnr = ls_out-artnr.

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
  DATA : lwa_ipdata LIKE LINE OF ft_ipdata,
         lwa_flist  LIKE LINE OF ft_flist.

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
FORM f_get_budat  USING    fu_perio
                  CHANGING fc_budat.
  DATA: lv_date TYPE datum.

  CONCATENATE fu_perio(4) fu_perio+5(2) '01' INTO lv_date.
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
                             fu_gsber
                             fu_perio
                             fu_matnr
                             fu_variant
                             fu_waers.
  DATA: ls_zcodt011 TYPE zcodt011,
        lr_cx       TYPE REF TO cx_root.

  ls_zcodt011-bukrs   = fu_bukrs.
  ls_zcodt011-gsber   = fu_gsber.
  ls_zcodt011-perio   = fu_perio.
  ls_zcodt011-matnr   = fu_matnr.
  ls_zcodt011-zuser   = sy-uname.
  ls_zcodt011-tglprs  = sy-datum.
  ls_zcodt011-posval  = fu_variant.
  ls_zcodt011-waers   = fu_waers.

  CASE fu_type.
    WHEN 'POST'.
      TRY .
          INSERT zcodt011 FROM ls_zcodt011.
        CATCH cx_sy_open_sql_db INTO lr_cx.

      ENDTRY.
    WHEN 'REVS'.
      TRY .
          DELETE zcodt011 FROM ls_zcodt011.
        CATCH cx_sy_open_sql_db INTO lr_cx.

      ENDTRY.
  ENDCASE.
ENDFORM.                    " F_SAVE_ZTABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCUMENT_STATUS
*&---------------------------------------------------------------------*
FORM f_get_document_status .
  DATA: ls_bstat LIKE LINE OF gr_bstat,
        lt_dd07v TYPE TABLE OF dd07v,
        ls_dd07v LIKE LINE OF lt_dd07v.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'BSTAT'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dd07v.

  LOOP AT lt_dd07v INTO ls_dd07v.
    ls_bstat-sign   = 'I'.
    ls_bstat-option = 'EQ'.
    ls_bstat-low    = ls_dd07v-domvalue_l.
    APPEND ls_bstat TO gr_bstat. CLEAR ls_bstat.
  ENDLOOP.
ENDFORM.                    " F_GET_DOCUMENT_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_GET_POSTING_DATE
*&---------------------------------------------------------------------*
FORM f_get_posting_date .
  DATA: ls_budat  LIKE LINE OF gr_budat.

  ls_budat-sign   = 'I'.
  ls_budat-option = 'BT'.
  CONCATENATE p_perio(4) p_perio+5(2) '01' INTO ls_budat-low.
  ls_budat-high = ls_budat-low.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_budat-high
    IMPORTING
      last_day_of_month = ls_budat-high.

  APPEND ls_budat TO gr_budat. CLEAR ls_budat.
ENDFORM.                    " F_GET_POSTING_DATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_GL_ACCOUNT
*&---------------------------------------------------------------------*
FORM f_get_gl_account .
  DATA: ls_hkont   LIKE LINE OF gr_hkont,
        lt_setleaf TYPE TABLE OF setleaf,
        ls_setleaf LIKE LINE OF lt_setleaf.

  SELECT * INTO TABLE lt_setleaf
    FROM setleaf WHERE setclass = '0000'
                   AND setname  = 'Z_COGS_TSP'.

  LOOP AT lt_setleaf INTO ls_setleaf.
    ls_hkont-sign   = ls_setleaf-valsign.
    ls_hkont-option = ls_setleaf-valoption.
    ls_hkont-low    = ls_setleaf-valfrom.
    ls_hkont-high   = ls_setleaf-valto.
    APPEND ls_hkont TO gr_hkont. CLEAR ls_hkont.
  ENDLOOP.
ENDFORM.                    " F_GET_GL_ACCOUNT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_ZCOR018
*&---------------------------------------------------------------------*
FORM f_get_data_zcor018  USING    fu_gsber
                             fu_poper
                             fu_bdatj.
  DATA: lv_count    TYPE int1,
        ls_zcor018  LIKE LINE OF gt_zcor018,
        lr_zcor018t TYPE REF TO data,
        ls_zcor018t TYPE REF TO data,
        lr_poper    TYPE RANGE OF poper WITH HEADER LINE,
        lr_werks    TYPE RANGE OF ekpo-werks WITH HEADER LINE,
        lr_ekgrp    TYPE RANGE OF ekko-ekgrp WITH HEADER LINE,
        lr_matnr    TYPE RANGE OF ekpo-matnr WITH HEADER LINE,
        lr_loekz    TYPE RANGE OF ekpo-loekz WITH HEADER LINE.

  FIELD-SYMBOLS: <ft_zcor018t> TYPE ANY TABLE,
                 <fs_zcor018t> TYPE any,
                 <ft_zcor018>  LIKE LINE OF gt_zcor018,
                 <fs_bukrs>    TYPE any,
                 <fs_bwkey>    TYPE any,
                 <fs_poper>    TYPE any,
                 <fs_bdatj>    TYPE any,
                 <fs_matnr>    TYPE any,
                 <fs_status>   TYPE any.

  lr_poper-sign   = 'I'.
  lr_poper-option = 'EQ'.
  lr_poper-low    = fu_poper.
  APPEND lr_poper. CLEAR lr_poper.

  cl_salv_bs_runtime_info=>set(
    EXPORTING display  = abap_false
              metadata = abap_false
              data     = abap_true ).

  SUBMIT zco_notdistr_costcomponen WITH pa_bwkey EQ fu_gsber
                                   WITH so_poper IN lr_poper
                                   WITH pa_bdatj EQ fu_bdatj
                                   AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
        IMPORTING r_data = lr_zcor018t ).
      ASSIGN lr_zcor018t->* TO <ft_zcor018t>.

      IF <ft_zcor018t> IS ASSIGNED.
        CREATE DATA ls_zcor018t LIKE LINE OF <ft_zcor018t>.
        ASSIGN ls_zcor018t->* TO <fs_zcor018t>.
      ENDIF.

    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.

  IF <ft_zcor018t> IS ASSIGNED.
    LOOP AT <ft_zcor018t> ASSIGNING <fs_zcor018t>.
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_zcor018t> TO <fs_bukrs>.
      ASSIGN COMPONENT 'BWKEY' OF STRUCTURE <fs_zcor018t> TO <fs_bwkey>.
      ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_zcor018t> TO <fs_poper>.
      ASSIGN COMPONENT 'BDATJ' OF STRUCTURE <fs_zcor018t> TO <fs_bdatj>.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_zcor018t> TO <fs_matnr>.
      ASSIGN COMPONENT 'STATUS' OF STRUCTURE <fs_zcor018t> TO <fs_status>.
      gt_zcor018-bukrs  = <fs_bukrs>.
      gt_zcor018-bwkey  = <fs_bwkey>.
      gt_zcor018-poper  = <fs_poper>.
      gt_zcor018-bdatj  = <fs_bdatj>.
      gt_zcor018-matnr  = <fs_matnr>.
      gt_zcor018-status = <fs_status>.
      APPEND gt_zcor018.
    ENDLOOP.
  ENDIF.

  cl_salv_bs_runtime_info=>clear_all( ).
ENDFORM.                    " F_GET_DATA_ZCOR018
