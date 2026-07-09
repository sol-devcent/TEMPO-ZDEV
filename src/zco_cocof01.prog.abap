*&---------------------------------------------------------------------*
*&  Include           ZCO_COCOF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_keph_mlcd       TYPE ccs01_t_keph_mlcd,
         ls_keph_mlcd       LIKE LINE OF lt_keph_mlcd,
         lt_keph_mlcd_na    TYPE ccs01_t_keph_mlcd,
         ls_keph_mlcd_na    LIKE LINE OF lt_keph_mlcd_na,

         lt_mbew        TYPE STANDARD TABLE OF mbew,
         ls_mbew        TYPE mbew,
         lt_ckmlhd      TYPE STANDARD TABLE OF ckmlhd,
         ls_ckmlhd      TYPE ckmlhd.

  DATA : it_kalnr     TYPE ckmv0_matobj_tbl,
         ls_kalnr     LIKE LINE OF it_kalnr,
         ir_keart     TYPE ckmv0_yt_keart,
         ls_keart     LIKE LINE OF ir_keart,
         ir_mlcct     TYPE ckmv0_yt_mlcct,
         ls_mlcct     LIKE LINE OF ir_mlcct,
         ir_kkzst     TYPE ckmv0_yt_kkzst,
         ls_kkzst     LIKE LINE OF ir_kkzst,
         ir_curtp     TYPE ckmv0_yt_curtp,
         ls_curtp     LIKE LINE OF ir_curtp.

  SELECT matnr bwkey bwtar kaln1
    FROM mbew
    INTO CORRESPONDING FIELDS OF TABLE gt_mbew
    WHERE matnr IN so_matnr
      AND bwkey = pa_bwkey
      AND lvorm = space.

  PERFORM f_get_detail_material.

  lt_mbew[] = gt_mbew[].
  SORT lt_mbew BY kaln1.
  DELETE ADJACENT DUPLICATES FROM lt_mbew COMPARING kaln1.

  IF lt_mbew[] IS NOT INITIAL.
    SELECT *
      FROM ckmlhd
      INTO CORRESPONDING FIELDS OF TABLE lt_ckmlhd
      FOR ALL ENTRIES IN lt_mbew
      WHERE kalnr = lt_mbew-kaln1.

    CLEAR : it_kalnr[], it_kalnr, ls_kalnr.

    LOOP AT lt_mbew INTO ls_mbew.
      ls_kalnr-kalnr  = ls_mbew-kaln1.
      ls_kalnr-bwkey  = pa_bwkey.
      READ TABLE lt_ckmlhd INTO ls_ckmlhd
                           WITH KEY kalnr = ls_mbew-kaln1
                           TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND ls_kalnr TO it_kalnr.
      ENDIF.
    ENDLOOP.

    CLEAR : ir_keart[], ir_keart, ls_keart.
    ls_keart-sign   = 'I'.
    ls_keart-option = 'EQ'.
    ls_keart-low    = 'H'.
    APPEND ls_keart TO ir_keart.

    CLEAR : ir_mlcct[], ir_mlcct, ls_mlcct.
    ls_mlcct-sign   = 'I'.
    ls_mlcct-option = 'EQ'.
    APPEND ls_mlcct TO ir_mlcct.

    CLEAR : ir_kkzst[], ir_kkzst, ls_kkzst.
    ls_kkzst-sign   = 'I'.
    ls_kkzst-option = 'EQ'.
    APPEND ls_kkzst TO ir_kkzst.

    CLEAR : ir_curtp[], ir_curtp, ls_curtp.
    ls_curtp-sign   = 'I'.
    ls_curtp-option = 'EQ'.
    ls_curtp-low    = '10'.
    APPEND ls_curtp TO ir_curtp.

    CLEAR : lt_keph_mlcd[], lt_keph_mlcd, ls_keph_mlcd.

    CALL FUNCTION 'MLCCS_KEPH_MLCD_READ'
      EXPORTING
        i_refresh_buffer       = 'X'
        it_kalnr               = it_kalnr
        i_from_bdatj           = pa_bdatj
        i_from_poper           = pa_poper
        ir_keart               = ir_keart
        ir_mlcct               = ir_mlcct
        ir_kkzst               = ir_kkzst
        ir_curtp               = ir_curtp
      IMPORTING
        et_keph_mlcd           = lt_keph_mlcd
        et_keph_mlcd_not_alloc = lt_keph_mlcd_na.

    LOOP AT lt_keph_mlcd INTO ls_keph_mlcd.
      gs_keph_mlcd = ls_keph_mlcd.
      APPEND gs_keph_mlcd TO gt_keph_mlcd.
      CLEAR gs_keph_mlcd.
      IF ls_keph_mlcd-bvalt IS NOT INITIAL.
        gs_text_read-kalnr  = ls_keph_mlcd-bvalt.
        APPEND gs_text_read TO gt_text_read.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'CKML_MGV_TEXT_READ'
      EXPORTING
        i_language   = sy-langu
      CHANGING
        ct_text_read = gt_text_read.

    IF gt_text_read[] IS NOT INITIAL.
      SELECT kalnr saknr_nd spez_name_nd
        FROM ckmlmv005
        INTO CORRESPONDING FIELDS OF TABLE gt_ckmlmv005
        FOR ALL ENTRIES IN gt_text_read
        WHERE kalnr = gt_text_read-kalnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_detail_material .
  DATA : lt_mbew  TYPE STANDARD TABLE OF mbew,
         lt_mara  TYPE ty_mara OCCURS 0.

  lt_mbew[] = gt_mbew[].
  SORT lt_mbew BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mbew COMPARING matnr.

  IF lt_mbew[] IS NOT INITIAL.
    SELECT mara~matnr matkl maktx
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_mbew
      WHERE mara~matnr = lt_mbew-matnr
        AND spras = sy-langu.

    lt_mara[] = gt_mara[].
    SORT lt_mara BY matkl.
    DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matkl.

    IF lt_mara[] IS NOT INITIAL.
      SELECT matkl wgbez
        FROM t023t
        INTO CORRESPONDING FIELDS OF TABLE gt_t023t
        FOR ALL ENTRIES IN lt_mara
        WHERE spras = sy-langu
          AND matkl = lt_mara-matkl.
    ENDIF.

    SELECT matnr werks prctr
      FROM marc
      INTO CORRESPONDING FIELDS OF TABLE gt_marc
      FOR ALL ENTRIES IN lt_mbew
      WHERE matnr = lt_mbew-matnr
        AND werks = pa_bwkey
        AND lvorm = space.
  ENDIF.
ENDFORM.                    " F_GET_DETAIL_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_mbew        TYPE mbew,
         ls_out         TYPE ty_out,
         ls_mara        TYPE ty_mara,
         ls_t023t       TYPE t023t,
         ls_marc        TYPE marc,
         ls_ckmlprkeph  TYPE ckmlprkeph,
         ls_mlcd        TYPE mlcd,
         ls_keko        TYPE keko,
         lv_saknr       TYPE ska1-saknr.

  "Start SOH Adjustment 20240808
  DELETE gt_keph_mlcd WHERE categ NE 'VN'.
  DELETE gt_keph_mlcd WHERE ptyp NE 'V+' AND ptyp NE 'B+'.
  SORT gt_keph_mlcd BY kalnr categ ptyp.
  "End SOH Adjustment 20240808

  SORT gt_mbew BY kaln1.
  SORT gt_ckmlprkeph BY kalnr.
  SORT gt_mlcd BY kalnr.
  SORT gt_keko BY kalnr.

  LOOP AT gt_mbew INTO ls_mbew.
    ls_out-bwkey  = pa_bwkey.
    ls_out-poper  = pa_poper.
    ls_out-bdatj  = pa_bdatj.
    ls_out-matnr  = ls_mbew-matnr.
    CLEAR ls_mara.
    READ TABLE gt_mara INTO ls_mara WITH KEY matnr = ls_mbew-matnr.
    IF sy-subrc = 0.
      ls_out-maktx  = ls_mara-maktx.
      ls_out-matkl  = ls_mara-matkl.
      CLEAR ls_t023t.
      READ TABLE gt_t023t INTO ls_t023t WITH KEY matkl = ls_mara-matkl.
      IF sy-subrc = 0.
        ls_out-wgbez  = ls_t023t-wgbez.
      ENDIF.
    ENDIF.
    CLEAR ls_marc.
    READ TABLE gt_marc INTO ls_marc WITH KEY matnr = ls_mbew-matnr
                                             werks = ls_mbew-bwkey.
    IF sy-subrc = 0.
      ls_out-prctr  = ls_marc-prctr.
    ENDIF.

    LOOP AT gt_keph_mlcd INTO gs_keph_mlcd WHERE kalnr = ls_mbew-kaln1.
      IF gs_keph_mlcd-categ = 'VN' AND
        ( gs_keph_mlcd-ptyp = 'V+' OR gs_keph_mlcd-ptyp = 'B+' ).
        ls_out-waers = gs_keph_mlcd-waers.
        ls_out-rawco = gs_keph_mlcd-kst001.
        ls_out-pacco = gs_keph_mlcd-kst003.
        ls_out-labco = gs_keph_mlcd-kst005.
        ls_out-macco = gs_keph_mlcd-kst007.
        ls_out-mfeco = gs_keph_mlcd-kst009.
        ls_out-fgsco = gs_keph_mlcd-kst011.

        ls_out-total  = ls_out-rawco + ls_out-pacco + ls_out-labco +
                        ls_out-macco + ls_out-mfeco + ls_out-fgsco.

        ls_out-menge  = gs_keph_mlcd-menge.
        ls_out-meins  = gs_keph_mlcd-meins.

        "Start SOH Adjustment 20240808
        CLEAR ls_out-valid_name.
        "End SOH Adjustment 20240808

        IF gs_keph_mlcd-ptyp = 'V+'.
          CLEAR gs_text_read.
          READ TABLE gt_text_read INTO gs_text_read
                                  WITH KEY kalnr = gs_keph_mlcd-bvalt.
          IF sy-subrc = 0.
            CLEAR gs_ckmlmv005.
            READ TABLE gt_ckmlmv005 INTO gs_ckmlmv005
                                    WITH KEY kalnr = gs_keph_mlcd-bvalt.
            IF sy-subrc = 0.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = gs_ckmlmv005-saknr_nd
                IMPORTING
                  output = lv_saknr.

              IF gs_ckmlmv005-spez_name_nd = 'V_REST'.
                ls_out-valid_name = gs_text_read-valid_name.
              ELSEIF lv_saknr(3) = '071'.
                ls_out-valid_name = gs_text_read-valid_name.
              ELSE.
                CONTINUE.
              ENDIF.
              APPEND ls_out TO gt_out.
            ENDIF.
          ENDIF.
        ELSEIF gs_keph_mlcd-ptyp = 'B+'.
          APPEND ls_out TO gt_out.
        ENDIF.
      ENDIF.
    ENDLOOP.
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
  SET PF-STATUS 'PF100'.
  SET TITLEBAR 'TITLE100'.
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
        i_parent      = g_container.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sort_tab.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_user_command
                event_receiver->handle_menu_button
                event_receiver->handle_toolbar FOR g_outgrid.

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
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR : gt_fieldcat[], gt_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT' :
    'BWKEY' 'MBEW' 'BWKEY' '' '' 'Plant' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'POPER' 'CKMLPRKEPH' 'POPER' '' '' 'Period' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BDATJ' 'CKMLPRKEPH' 'BDATJ' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MATNR' 'MBEW' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'WGBEZ' 'T023T' 'WGBEZ' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'PRCTR' 'MARC' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'VALID_NAME' '' '' '' '30' 'Consumption' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MENGE' 'MLCD' 'LBKUM' '' '' 'Quantity' '' '' '' '' '' '' 'MEINS' '' ''
    '' '' '' '' '' '',
    'MEINS' 'MLCD' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'WAERS' 'CKMLPRKEPH' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'RAWCO' 'CKMLPRKEPH' 'KST001' '' '' 'Rawmat Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'PACCO' 'CKMLPRKEPH' 'KST003' '' '' 'Packmat Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'LABCO' 'CKMLPRKEPH' 'KST005' '' '' 'Labor Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'MACCO' 'CKMLPRKEPH' 'KST007' '' '' 'Machine Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'MFECO' 'CKMLPRKEPH' 'KST009' '' '' 'Manuf.Fee Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'FGSCO' 'CKMLPRKEPH' 'KST011' '' '' 'FG Cost' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' '',
    'TOTAL' 'CKMLPRKEPH' 'KST011' '' '' 'Total' '' '' '' '' ''
    'WAERS' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-sel_mode            = 'A'.
*  gs_layout_alv-no_rowmark          = selected.
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
