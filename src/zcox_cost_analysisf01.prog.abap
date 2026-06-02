*&---------------------------------------------------------------------*
*&  Include           ZCO_COST_ANALYSISF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  gv_repid = sy-repid.

  SELECT SINGLE waers
    FROM tka01
    INTO gv_waers
    WHERE kokrs = '8010'.

  SELECT istat txt04
    FROM tj02t
    INTO TABLE gt_tj02t
    WHERE txt04 IN so_txt04
      AND spras = sy-langu.

  SELECT mara~matnr mara~meins mara~mtart
    FROM mara JOIN marc ON mara~matnr = marc~matnr
    INTO CORRESPONDING FIELDS OF TABLE gt_material
    WHERE mara~matnr IN so_matnr
      AND marc~werks = pa_werks.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : ls_caufv TYPE caufv,
         ls_stat  TYPE ty_stat,
         ls_tj02t TYPE ty_tj02t,
         lv_subrc TYPE sy-subrc.

  DATA : lt_caufv  TYPE STANDARD TABLE OF caufv,
         lt_mbew   TYPE STANDARD TABLE OF mbew,
         lt_covp   TYPE STANDARD TABLE OF covp,
         ls_ckmlcr LIKE LINE OF gt_ckmlcr,
         ls_covp   LIKE LINE OF gt_covp,
         lt_resb   TYPE STANDARD TABLE OF resb.

  SELECT aufnr plnbez ktext gamng waers objnr gltri bukrs werks
    FROM caufv
    INTO CORRESPONDING FIELDS OF TABLE gt_caufv
    WHERE bukrs  = pa_bukrs
      AND werks  = pa_werks
      AND plnbez IN so_matnr
      AND aufnr  IN so_aufnr
      AND gstrp  IN so_gstrp
      AND gltrp  IN so_gltrp
      AND gltri  IN so_gltri
    ORDER BY PRIMARY KEY.

  IF gt_caufv[] IS NOT INITIAL.
    gt_xcaufv[] = gt_caufv[].

    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE gt_afpo
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr
        AND matnr = gt_caufv-plnbez
      ORDER BY PRIMARY KEY.

    IF pa_bukrs = '8360' AND
      pa_werks = '3600'.
      PERFORM f_additional_data.
    ENDIF.

    PERFORM f_check_status_order.

    SELECT aufnr baugr werks matnr bdmng meins erfmg erfme gpreis
      peinh saknr
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr
        AND baugr = gt_caufv-plnbez
        AND werks = pa_werks.

    LOOP AT gt_caufv INTO ls_caufv.
      READ TABLE gt_stat INTO ls_stat WITH KEY objnr = ls_caufv-objnr.
      IF sy-subrc = 0.
        LOOP AT gt_tj02t INTO ls_tj02t.
          SEARCH ls_stat-sttxt FOR ls_tj02t-txt04 AND MARK.
          IF sy-subrc = 0.
            lv_subrc = 1.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF lv_subrc IS INITIAL.
        DELETE gt_caufv.
      ENDIF.
      CLEAR lv_subrc.
    ENDLOOP.
  ENDIF.

  IF gt_caufv[] IS NOT INITIAL.
    lt_caufv[]  = gt_caufv[].
    SORT lt_caufv BY plnbez.
    DELETE ADJACENT DUPLICATES FROM lt_caufv COMPARING plnbez.

    IF lt_caufv[] IS NOT INITIAL.
      SELECT *
        FROM mbew
        INTO CORRESPONDING FIELDS OF TABLE gt_mbew
        FOR ALL ENTRIES IN lt_caufv
        WHERE matnr = lt_caufv-plnbez
          AND bwkey = pa_werks
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM mara
        INTO CORRESPONDING FIELDS OF TABLE gt_xmara
        FOR ALL ENTRIES IN lt_caufv
        WHERE matnr = lt_caufv-plnbez.
    ENDIF.

    lt_resb[] = gt_resb[].
    SORT lt_resb BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr.
    DELETE lt_resb WHERE matnr IN so_matnr.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM mbew
        APPENDING CORRESPONDING FIELDS OF TABLE gt_mbew
        FOR ALL ENTRIES IN lt_resb
        WHERE matnr = lt_resb-matnr
          AND bwkey = pa_werks
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM mara
        APPENDING CORRESPONDING FIELDS OF TABLE gt_xmara
        FOR ALL ENTRIES IN lt_resb
        WHERE matnr = lt_resb-matnr.
    ENDIF.

    lt_mbew[] = gt_mbew[].
    SORT lt_mbew BY kaln1.
    DELETE ADJACENT DUPLICATES FROM lt_mbew COMPARING kaln1.

    IF lt_mbew[] IS NOT INITIAL.
      SELECT kstar matnr menge meeht umrez umren wertn kostl
        FROM ckis
        INTO CORRESPONDING FIELDS OF TABLE gt_ckis
        FOR ALL ENTRIES IN lt_mbew
        WHERE lednr = '00'
          AND bzobj = '0'
          AND kalnr = lt_mbew-kaln1.

      SELECT *
        FROM ckhs
        INTO CORRESPONDING FIELDS OF TABLE gt_ckhs
        FOR ALL ENTRIES IN lt_mbew
        WHERE lednr = '00'
          AND bzobj = '0'
          AND kalnr = lt_mbew-kaln1
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM ckmlcr
        INTO CORRESPONDING FIELDS OF TABLE gt_ckmlcr
        FOR ALL ENTRIES IN lt_mbew
        WHERE kalnr = lt_mbew-kaln1
        ORDER BY PRIMARY KEY.
    ENDIF.

    SELECT *
      FROM covp
      INTO CORRESPONDING FIELDS OF TABLE gt_covp
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr
      ORDER BY PRIMARY KEY.

    lt_covp[] = gt_covp[].
    SORT lt_covp BY perio gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_covp COMPARING perio gjahr.

    LOOP AT gt_ckmlcr INTO ls_ckmlcr.
      CLEAR ls_covp.
      READ TABLE lt_covp INTO ls_covp
                         WITH KEY perio = ls_ckmlcr-poper
                                  gjahr = ls_ckmlcr-bdatj.
      IF sy-subrc <> 0.
        DELETE TABLE gt_ckmlcr FROM ls_ckmlcr.
      ENDIF.
    ENDLOOP.

    SELECT objnr kstar wrttp vrgng parob uspob twaer meg001
      meg002 meg003 meg004 meg005 meg006 meg007 meg008 meg009
      meg010 meg011 meg012 wtg001 wtg002 wtg003 wtg004 wtg005
      wtg006 wtg007 wtg008 wtg009 wtg010 wtg011 wtg012 wkg001
      wkg002 wkg003 wkg004 wkg005 wkg006 wkg007 wkg008 wkg009
      wkg010 wkg011 wkg012 meinh
      FROM coss
      INTO CORRESPONDING FIELDS OF TABLE gt_coss
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr.

    SELECT objnr kstar wrttp hrkft vrgng twaer meg001 meg002
      meg003 meg004 meg005 meg006 meg007 meg008 meg009 meg010
      meg011 meg012 wtg001 wtg002 wtg003 wtg004 wtg005 wtg006
      wtg007 wtg008 wtg009 wtg010 wtg011 wtg012 wkg001 wkg002
      wkg003 wkg004 wkg005 wkg006 wkg007 wkg008 wkg009 wkg010
      wkg011 wkg012 meinh
      FROM cosp
      INTO CORRESPONDING FIELDS OF TABLE gt_cosp
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr.

    SELECT *
      FROM s026
      INTO CORRESPONDING FIELDS OF TABLE gt_s026
      FOR ALL ENTRIES IN gt_caufv
      WHERE ssour = space
        AND vrsio = '000'
        AND spmon = '000000'
        AND sptag = '00000000'
        AND spwoc = '000000'
        AND spbup = '000000'
        AND werks = pa_werks
        AND matnr = gt_caufv-plnbez
        AND aufnr = gt_caufv-aufnr
      ORDER BY PRIMARY KEY.
  ENDIF.

  PERFORM f_get_description USING 'COVP'.
  PERFORM f_get_description USING 'COSS'.
  PERFORM f_get_description USING 'COSP'.
  PERFORM f_get_description USING 'RESB'.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_caufv  TYPE caufv,
         ls_cosp   TYPE cosp,
         ls_coss   TYPE coss,
         ls_csku   TYPE csku,
         ls_cskt   TYPE cskt,
         ls_cokey  TYPE cokey,
         ls_makt   TYPE makt,
         ls_detail TYPE ty_detail.

  DATA : lv_objnr LIKE caufv-objnr,
         lv_kostl LIKE cskt-kostl,
         ls_xmara LIKE LINE OF gt_mara.

  SORT gt_cosp BY objnr kstar.
  SORT gt_caufv BY objnr.

  LOOP AT gt_cosp INTO ls_cosp.
    ls_detail-objnr     = ls_cosp-objnr.

    CLEAR ls_caufv.
    READ TABLE gt_caufv INTO ls_caufv WITH KEY objnr  = ls_cosp-objnr
                                      BINARY SEARCH.
    IF sy-subrc = 0.
      ls_detail-aufnr     = ls_caufv-aufnr.
      ls_detail-gltri     = ls_caufv-gltri.
*      Add BUKRS and WERKS to gt_detail
      ls_detail-bukrs = ls_caufv-bukrs.
      ls_detail-werks = ls_caufv-werks.
    ENDIF.
    ls_detail-kstar     = ls_cosp-kstar.
    ls_detail-hrkft     = ls_cosp-hrkft.
    ls_detail-twaer     = ls_cosp-twaer.
    ls_detail-tbma_val  = 'COSP'.

    CLEAR ls_csku.
    READ TABLE gt_csku INTO ls_csku WITH KEY kstar = ls_cosp-kstar.
    IF sy-subrc = 0.
      ls_detail-ltext   = ls_csku-ltext.
    ENDIF.

    IF ls_cosp-hrkft IS NOT INITIAL.
      READ TABLE gt_cokey INTO ls_cokey WITH KEY hrkft = ls_cosp-hrkft.
      IF sy-subrc = 0.
        ls_detail-sourc   = ls_cokey-matnr.
        ls_detail-matnr   = ls_cokey-matnr.
        READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_cokey-matnr.
        IF sy-subrc = 0.
          ls_detail-sourt   = ls_makt-maktx.
        ENDIF.
      ENDIF.
    ENDIF.
    COLLECT ls_detail INTO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  SORT gt_coss BY objnr kstar.
  SORT gt_caufv BY objnr.

  LOOP AT gt_coss INTO ls_coss.
    ls_detail-objnr     = ls_coss-objnr.
    CLEAR ls_caufv.
    READ TABLE gt_caufv INTO ls_caufv WITH KEY objnr  = ls_coss-objnr
                                      BINARY SEARCH.
    IF sy-subrc = 0.
      ls_detail-aufnr     = ls_caufv-aufnr.
    ENDIF.

    ls_detail-kstar     = ls_coss-kstar.
    ls_detail-uspob     = ls_coss-uspob.
    ls_detail-twaer     = ls_coss-twaer.
    ls_detail-tbma_val  = 'COSS'.

    CLEAR ls_csku.
    READ TABLE gt_csku INTO ls_csku WITH KEY kstar = ls_coss-kstar.
    IF sy-subrc = 0.
      ls_detail-ltext   = ls_csku-ltext.
    ENDIF.

    ls_detail-sourc = ls_coss-uspob+6(10).

    CLEAR : ls_cskt, lv_kostl.
    lv_kostl          = ls_coss-uspob+6(10).
    READ TABLE gt_cskt INTO ls_cskt WITH KEY kostl = lv_kostl.
    IF sy-subrc = 0.
      ls_detail-sourt   = ls_cskt-ltext.
    ENDIF.

    COLLECT ls_detail INTO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

*  CLEAR ls_xmara.
  CASE 'X'.
    WHEN radio1.
      READ TABLE gt_xmara INTO ls_xmara INDEX 1.
      PERFORM f_display_header USING    '1' ls_xmara-matnr ls_xmara-meins
                               CHANGING lv_objnr.

      PERFORM f_display_detail USING ls_xmara-matnr.
    WHEN radio2.
      PERFORM f_display_detail USING ''.
  ENDCASE.

ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio1.
      CALL SCREEN 100.
    WHEN radio2.
      CALL SCREEN 101.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  CASE 'X'.
    WHEN radio1.
      SET PF-STATUS 'PF_100'.
    WHEN radio2.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
  SET TITLEBAR 'MAIN_TITLE'.

  gs_variant-report = gv_repid.
  gv_dynnr = sy-dynnr.

  CREATE OBJECT event_receiver.

  PERFORM f_excluding_toolbar.

  PERFORM f_modify_screen.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CALL METHOD g_grid->set_function_code
        CHANGING
          c_ucomm = ok_code.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  CASE 'X'.
    WHEN radio1.
      IF g_docking IS INITIAL.
        CREATE OBJECT g_docking
          EXPORTING
            repid     = gv_repid
            dynnr     = gv_dynnr
            side      = g_docking->dock_at_left
            extension = 280.
      ENDIF.
    WHEN radio2.
  ENDCASE.

  IF g_custom_container IS INITIAL.
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name              = 'CC_CONTAINER'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_custom_container
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
*&      Module  TREE  OUTPUT
*&---------------------------------------------------------------------*
MODULE tree OUTPUT.
  CASE 'X'.
    WHEN radio1.
      IF g_tree IS INITIAL.

        PERFORM f_build_fieldcat  USING 'TREE'.

        PERFORM f_build_hierarchy_header CHANGING g_hierarchy_header.

        PERFORM f_create_tree.

        PERFORM f_register_events  USING 'TREE'.

        PERFORM f_create_hierarchy.

      ENDIF.
    WHEN radio2.
  ENDCASE.
ENDMODULE.                 " TREE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TREE
*&---------------------------------------------------------------------*
FORM f_create_tree .
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
      is_hierarchy_header = g_hierarchy_header
      i_save              = 'A'
      is_variant          = gs_variant
    CHANGING
      it_outtab           = gt_tree
      it_fieldcatalog     = gt_fieldcat.
ENDFORM.                    " F_CREATE_TREE

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat USING   fu_container.
  CLEAR : gt_fieldcat[], gt_fieldcat.

  CASE fu_container.
    WHEN 'TREE'.
      PERFORM f_fieldcatg USING 'GT_TREE' :
        'NODE_MAIN' '' '' 'X' '12' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NODE_N01' '' '' '' '15' 'Act.Val.' '' '' '' '' '' '' '' '' '' ''
        'R' '' '' '' '',
        'NODE_N02' '' '' '' '15' 'Tgt.Val.' '' '' '' '' '' '' '' '' '' ''
        'R' '' '' '' '',
        'NODE_N03' '' '' '' '15' 'Plan.Val.' '' '' '' '' '' '' '' '' '' ''
        'R' '' '' '' ''.
    WHEN 'ALV'.
      PERFORM f_fieldcatg USING 'GT_ALV' :
        'AUFNR' 'CAUFV' 'AUFNR' '' '12' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X',
        'KSTAR' 'COVP' 'KSTAR' '' '12' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X',
        'LTEXT' 'CSKU' 'LTEXT' '' '20' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X',
        'SOURC' '' '' '' '12' 'Source' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X',
        'SOURT' '' '' '' '30' 'Source Text' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X',
        'ACTQTY' '' '' '' '12' 'Actual Qty' '' '' '' '' '' ''
        'MEINB' '' '' '' '' '' '' '' '',
        'PLNQTY' '' '' '' '12' 'Planning Qty' '' '' '' '' '' ''
        'MEINB' '' '' '' '' '' '' '' '',
        'TGTQTY' '' '' '' '12' 'Target Qty' '' '' '' '' '' ''
        'MEINB' '' '' '' '' '' '' '' '',
        'TWAER' 'COVP' 'TWAER' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ACTVAL' '' '' '' '12' 'Actual Value' '' '' '' '' ''
        'TWAER' '' '' '' '' '' '' '' '' '',
        'PLNVAL' '' '' '' '12' 'Planning Value' '' '' '' '' ''
        'TWAER' '' '' '' '' '' '' '' '' '',
        'TGTVAL' '' '' '' '12' 'Target Value' '' '' '' '' ''
        'TWAER' '' '' '' '' '' '' '' '' '',
        'PVPRS' 'CKMLCR' 'PVPRS' '' '12' 'Actual Price' '' '' '' '' ''
        'TWAER' '' '' '' '' '' '' '' '' '',
        'MEGBTR' 'COVP' 'MEGBTR' '' '12' 'Actual Confirmation' '' '' ''
        '' '' '' 'MEINB' '' '' '' '' '' '' '' '',
        'ACTAMT' 'CKMLCR' 'PVPRS' '' '12' 'Actual Amount ' '' '' '' '' ''
        'TWAER' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_create_hierarchy .
  DATA : ls_xmara     LIKE LINE OF gt_xmara,
         lv_node      TYPE lvc_value,
         lv_key_main  TYPE lvc_nkey,
         lv_key_node1 TYPE lvc_nkey,
         ls_caufv     TYPE caufv,
         ls_xcaufv    LIKE LINE OF gt_xcaufv,
         ls_afpo      LIKE LINE OF gt_afpo,
         ls_xafpo     LIKE LINE OF gt_afpo,
         lt_mara      TYPE STANDARD TABLE OF mara,
         ls_mara      LIKE LINE OF lt_mara.

  lt_mara[] = gt_xmara[].

  CLEAR : wa_tree.
  LOOP AT gt_xmara INTO ls_xmara.
    IF ls_xmara-matnr IN so_matnr.
      lv_node = ls_xmara-matnr.
      wa_tree-node_main = ls_xmara-matnr.
      PERFORM f_add_node_main USING wa_tree '' lv_node
                              CHANGING lv_key_main.
      LOOP AT gt_caufv INTO ls_caufv.
        IF ls_caufv-plnbez  = ls_xmara-matnr.
          PERFORM f_add_node_detail USING ls_caufv-aufnr lv_key_main
                                    CHANGING lv_key_node1.
        ELSE.
          IF pa_bukrs = '8360' AND
            pa_werks = '3600'.
            READ TABLE lt_mara INTO ls_mara
                               WITH KEY matnr = ls_caufv-plnbez.
            CASE ls_mara-mtart.
              WHEN 'ZSFG'.
                IF ls_caufv-plnbez(1) = 'I'.
                  CLEAR ls_afpo.
                  READ TABLE gt_afpo INTO ls_afpo
                                     WITH KEY aufnr = ls_caufv-aufnr.
                  IF sy-subrc = 0.
                    CLEAR ls_xafpo.
                    READ TABLE gt_afpo INTO ls_xafpo
                                       WITH KEY matnr = ls_xmara-matnr
                                                charg = ls_afpo-charg.
                    IF sy-subrc = 0.
                      PERFORM f_add_node_detail USING ls_caufv-aufnr lv_key_main
                                                CHANGING lv_key_node1.
                    ENDIF.
                  ENDIF.
                ENDIF.
              WHEN OTHERS.
                IF ls_caufv-plnbez(1) <> 'I'.
                  CLEAR ls_afpo.
                  READ TABLE gt_afpo INTO ls_afpo
                                     WITH KEY aufnr = ls_caufv-aufnr.
                  IF sy-subrc = 0.
                    CLEAR ls_xafpo.
                    READ TABLE gt_afpo INTO ls_xafpo
                                       WITH KEY matnr = ls_xmara-matnr
                                                charg = ls_afpo-charg.
                    IF sy-subrc = 0.
                      PERFORM f_add_node_detail USING ls_caufv-aufnr lv_key_main
                                                CHANGING lv_key_node1.
                    ENDIF.
                  ENDIF.
                ENDIF.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CALL METHOD g_tree->frontend_update.
ENDFORM.                    " F_CREATE_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_EVENTS
*&---------------------------------------------------------------------*
FORM f_register_events USING   fu_container.
  DATA : lt_events TYPE cntl_simple_events,
         ls_event  TYPE cntl_simple_event.

  CASE fu_container.
    WHEN 'TREE'.
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

    WHEN 'ALV'.
  ENDCASE.
ENDFORM.                    " F_REGISTER_EVENTS

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
*&      Form  F_BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
FORM f_build_hierarchy_header  CHANGING fc_header   TYPE treev_hhdr.
  fc_header-heading   = 'Material & Process Order'.
  fc_header-width     = 25.
  fc_header-width_pix = ''.
ENDFORM.                    " F_BUILD_HIERARCHY_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NODE_MAIN
*&---------------------------------------------------------------------*
FORM f_add_node_main  USING    fu_aux        TYPE ty_tree
                               fu_relat_key  TYPE lvc_nkey
                               fu_node       TYPE lvc_value
                     CHANGING  fc_node_key   TYPE lvc_nkey.

  DATA : lv_node_text   TYPE lvc_value,
         lt_item_layout TYPE lvc_t_layi,
         ls_item_layout TYPE lvc_s_layi,
         ls_node_layout TYPE lvc_s_layn.

*  ls_node_layout-n_image   = icon_transport_point.

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
*&      Form  F_ADD_NODE
*&---------------------------------------------------------------------*
FORM f_add_node  USING    fu_aux        TYPE ty_tree
                          fu_relat_key  TYPE lvc_nkey
                          fu_node       TYPE lvc_value
                 CHANGING fc_node_key   TYPE lvc_nkey.

  DATA : lv_node_text   TYPE lvc_value,
         lt_item_layout TYPE lvc_t_layi,
         ls_item_layout TYPE lvc_s_layi,
         ls_node_layout TYPE lvc_s_layn.

  ls_item_layout-fieldname = g_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO lt_item_layout.
  CLEAR ls_item_layout.

  ls_node_layout-n_image   = icon_order.
  ls_item_layout-fieldname = 'NODE_N01'.
  APPEND ls_item_layout TO lt_item_layout.
  CLEAR ls_item_layout.

  lv_node_text = fu_node.

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
ENDFORM.                    " F_ADD_NODE

*&---------------------------------------------------------------------*
*&      Module  ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE alv OUTPUT.

  PERFORM f_build_fieldcat  USING 'ALV'.

  PERFORM f_build_layout.

  PERFORM f_sort_tab.

  PERFORM f_create_alv.

ENDMODULE.                 " ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ALV
*&---------------------------------------------------------------------*
FORM f_create_alv .
  IF g_grid IS INITIAL.
    CREATE OBJECT g_grid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    PERFORM f_register_events  USING 'ALV'.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort_grid[]
        it_outtab            = gt_alv[]
        it_fieldcatalog      = gt_fieldcat[].
  ENDIF.

  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  PERFORM f_alv_refresh.
ENDFORM.                    " F_CREATE_ALV

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
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra         = selected.
  CASE 'X'.
    WHEN radio1.
    WHEN radio2.
      gs_layout_alv-no_toolbar    = selected.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

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
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen .
  IF gs_header-plnbez IS NOT INITIAL AND
    gs_header-aufnr IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1  = 'HDR' OR
        screen-group1  = 'DTL'.
        screen-invisible = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1  = 'HDR'.
        screen-invisible = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SORT_TAB
*&---------------------------------------------------------------------*
FORM f_sort_tab .
  CLEAR gt_sort_grid.

  gt_sort_grid-spos      = 1.
  gt_sort_grid-fieldname = 'KSTAR'.
  gt_sort_grid-up        = selected.
  gt_sort_grid-subtot    = selected.
  APPEND gt_sort_grid.
  CLEAR gt_sort_grid.

  gt_sort_grid-spos      = 2.
  gt_sort_grid-fieldname = 'SOURC'.
  gt_sort_grid-up        = selected.
  APPEND gt_sort_grid.
  CLEAR gt_sort_grid.
ENDFORM.                    " F_SORT_TAB

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh .
  gs_stable-row = 'X'.
  gs_stable-col = 'X'.
  IF g_grid IS NOT INITIAL.
    CALL METHOD g_grid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_HEADER
*&---------------------------------------------------------------------*
FORM f_display_header USING    fu_flag fu_matnr fu_meins
                      CHANGING fc_objnr.
  DATA : ls_caufv TYPE caufv,
         ls_afpo  TYPE afpo,
         ls_stat  TYPE ty_stat.

  CASE fu_flag.
    WHEN '1'.
      gs_header-plnbez  = fu_matnr.
      gs_header-meins   = fu_meins.

      READ TABLE gt_caufv INTO ls_caufv
                          WITH KEY plnbez = fu_matnr.
      IF sy-subrc = 0.
        gs_header-ktext  = ls_caufv-ktext.
        CONCATENATE ls_caufv-plnbez gs_header-ktext INTO gs_header-descr
        SEPARATED BY space.
        gs_header-waers  = ls_caufv-waers.

        CLEAR ls_caufv.
        LOOP AT gt_caufv INTO ls_caufv WHERE plnbez = fu_matnr.
          ADD ls_caufv-gamng TO gs_header-gamng.
          LOOP AT gt_afpo INTO ls_afpo WHERE aufnr = ls_caufv-aufnr
                                         AND matnr = fu_matnr.
            ADD ls_afpo-wemng TO gs_header-wemng.
            ADD ls_afpo-wewrt TO gs_header-wewrt.
            CLEAR ls_afpo.
          ENDLOOP.
          CLEAR ls_caufv.
        ENDLOOP.
      ENDIF.

      TRY .
          gs_header-yield = ( gs_header-wemng / gs_header-gamng ) * 100.

        CATCH cx_sy_zerodivide .
          gs_header-yield = 0.
      ENDTRY.

    WHEN OTHERS.
      gs_header-meins   = gv_meins.
      READ TABLE gt_caufv INTO ls_caufv WITH KEY aufnr = gs_header-aufnr.
      IF sy-subrc = 0.
        gs_header-plnbez  = ls_caufv-plnbez.
        gs_header-ktext   = ls_caufv-ktext.
        gs_header-gamng   = ls_caufv-gamng.
        gs_header-waers   = ls_caufv-waers.
        fc_objnr          = ls_caufv-objnr.
        READ TABLE gt_afpo INTO ls_afpo WITH KEY aufnr = gs_header-aufnr.
        IF sy-subrc = 0.
          gs_header-wemng  = ls_afpo-wemng.
          gs_header-wewrt  = ls_afpo-wewrt.
        ENDIF.
      ENDIF.

      TRY .
          gs_header-yield = ( gs_header-wemng / gs_header-gamng ) * 100.

        CATCH cx_sy_zerodivide .
          gs_header-yield = 0.
      ENDTRY.

      CONCATENATE gs_header-plnbez gs_header-ktext INTO gs_header-descr
      SEPARATED BY space.

      READ TABLE gt_stat INTO ls_stat WITH KEY objnr = fc_objnr.
      IF sy-subrc = 0.
        gs_header-stat  = ls_stat-sttxt.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description  USING    fu_table.
  DATA : lt_covp  TYPE STANDARD TABLE OF covp,
         lt_coss  TYPE STANDARD TABLE OF coss,
         lt_cosp  TYPE STANDARD TABLE OF cosp,
         lt_cokey TYPE STANDARD TABLE OF cokey,
         lt_resb  TYPE STANDARD TABLE OF resb,
         ls_coss  TYPE coss.

  DATA : BEGIN OF lt_cskt OCCURS 0,
           kostl LIKE cskt-kostl,
         END OF lt_cskt.

  CASE fu_table.
    WHEN 'COVP'.
      lt_covp[] = gt_covp[].
      SORT lt_covp BY kstar.
      DELETE ADJACENT DUPLICATES FROM lt_covp COMPARING kstar.
      IF lt_covp[] IS NOT INITIAL.
        SELECT kstar ltext
          FROM csku
          APPENDING CORRESPONDING FIELDS OF TABLE gt_csku
          FOR ALL ENTRIES IN lt_covp
          WHERE spras = sy-langu
            AND ktopl = 'TSPC'
            AND kstar = lt_covp-kstar.

        CLEAR : lt_covp[], lt_covp.
        lt_covp[] = gt_covp[].
        SORT lt_covp BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_covp COMPARING matnr.
        IF lt_covp[] IS NOT INITIAL.
          SELECT matnr meins
            FROM mara
            APPENDING CORRESPONDING FIELDS OF TABLE gt_mara
            FOR ALL ENTRIES IN lt_covp
            WHERE matnr = lt_covp-matnr.

          SELECT matnr maktx
            FROM makt
            APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
            FOR ALL ENTRIES IN lt_covp
            WHERE spras = sy-langu
              AND matnr = lt_covp-matnr.
        ENDIF.
      ENDIF.

    WHEN 'COSS'.
      lt_coss[] = gt_coss[].
      SORT lt_coss BY kstar.
      DELETE ADJACENT DUPLICATES FROM lt_coss COMPARING kstar.
      IF lt_coss[] IS NOT INITIAL.
        SELECT kstar ltext
          FROM csku
          APPENDING CORRESPONDING FIELDS OF TABLE gt_csku
          FOR ALL ENTRIES IN lt_coss
          WHERE spras = sy-langu
            AND ktopl = 'TSPC'
            AND kstar = lt_coss-kstar.
      ENDIF.

      SORT gt_coss BY uspob.
      LOOP AT gt_coss INTO ls_coss.
        lt_cskt-kostl = ls_coss-uspob+6(10).
        COLLECT lt_cskt.
        CLEAR lt_cskt.
      ENDLOOP.
      IF lt_cskt[] IS NOT INITIAL.
        SELECT kostl ltext
          FROM cskt
          INTO CORRESPONDING FIELDS OF TABLE gt_cskt
          FOR ALL ENTRIES IN lt_cskt
          WHERE spras = sy-langu
            AND kokrs = '8010'
            AND kostl = lt_cskt-kostl.
      ENDIF.

    WHEN 'COSP'.
      lt_cosp[] = gt_cosp[].
      SORT lt_cosp BY kstar.
      DELETE ADJACENT DUPLICATES FROM lt_cosp COMPARING kstar.
      IF lt_cosp[] IS NOT INITIAL.
        SELECT kstar ltext
          FROM csku
          APPENDING CORRESPONDING FIELDS OF TABLE gt_csku
          FOR ALL ENTRIES IN lt_cosp
          WHERE spras = sy-langu
            AND ktopl = 'TSPC'
            AND kstar = lt_cosp-kstar.
      ENDIF.

      CLEAR : lt_cosp[], lt_cosp.
      lt_cosp[] = gt_cosp[].
      SORT lt_cosp BY hrkft.
      DELETE ADJACENT DUPLICATES FROM lt_cosp COMPARING hrkft.
      IF lt_cosp[] IS NOT INITIAL.
        SELECT hrkft matnr
          FROM cokey
          APPENDING CORRESPONDING FIELDS OF TABLE gt_cokey
          FOR ALL ENTRIES IN lt_cosp
          WHERE hrkft = lt_cosp-hrkft
            AND werks = pa_werks.

        CLEAR : lt_cokey[], lt_cokey.
        lt_cokey[] = gt_cokey[].
        SORT lt_cokey BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_cokey COMPARING matnr.
        IF lt_cokey[] IS NOT INITIAL.
          SELECT matnr meins
            FROM mara
            APPENDING CORRESPONDING FIELDS OF TABLE gt_mara
            FOR ALL ENTRIES IN lt_cokey
            WHERE matnr = lt_cokey-matnr.

          SELECT matnr maktx
            FROM makt
            APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
            FOR ALL ENTRIES IN lt_cokey
            WHERE spras = sy-langu
              AND matnr = lt_cokey-matnr.
        ENDIF.
      ENDIF.

    WHEN 'RESB'.
      lt_resb[]   = gt_resb[].
      SORT lt_resb BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr.
      IF lt_resb[] IS NOT INITIAL.
        SELECT matnr meins
          FROM mara
          APPENDING CORRESPONDING FIELDS OF TABLE gt_mara
          FOR ALL ENTRIES IN lt_resb
          WHERE matnr = lt_resb-matnr.

        SELECT matnr maktx
          FROM makt
          APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_resb
          WHERE spras = sy-langu
            AND matnr = lt_resb-matnr.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_STATUS_ORDER
*&---------------------------------------------------------------------*
FORM f_check_status_order .
  DATA : ls_caufv TYPE caufv,
         ls_stat  TYPE ty_stat,
         lv_sttxt LIKE bsvx-sttxt.

  LOOP AT gt_caufv INTO ls_caufv.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        objnr            = ls_caufv-objnr
        spras            = sy-langu
      IMPORTING
        line             = lv_sttxt
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    IF sy-subrc = 0.
      ls_stat-objnr   = ls_caufv-objnr.
      ls_stat-sttxt   = lv_sttxt.
      APPEND ls_stat TO gt_stat.
      CLEAR ls_stat.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_STATUS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DETAIL
*&---------------------------------------------------------------------*
FORM f_display_detail USING fu_matnr.
  DATA : ls_detail TYPE ty_detail,
         ls_alv    TYPE ty_detail,
         ls_mara   TYPE mara,
         lt_alv    TYPE STANDARD TABLE OF ty_detail.

  DATA : ls_caufv  LIKE LINE OF gt_caufv,
         ls_xcaufv LIKE LINE OF gt_xcaufv,
         ls_xafpo  LIKE LINE OF gt_afpo,
         ls_afpo   LIKE LINE OF gt_afpo,
         ls_xmara  LIKE LINE OF gt_xmara.

  CLEAR : gt_alv[], gt_alv.

  LOOP AT gt_detail INTO ls_detail.
    PERFORM f_detail_to_alv TABLES   lt_alv
                            USING    ls_detail.
  ENDLOOP.

  SORT lt_alv BY objnr kstar sourc.
  DELETE ADJACENT DUPLICATES FROM lt_alv COMPARING objnr kstar sourc.

  PERFORM f_actual_qty_val TABLES lt_alv.

  PERFORM f_plan_qty_val TABLES lt_alv.

  PERFORM f_target_qty_val TABLES lt_alv.

  gt_all[]  = lt_alv[].

  SORT lt_alv BY kstar sourc.
  LOOP AT gt_caufv INTO ls_caufv.
    IF pa_bukrs = '8360'.
      CLEAR ls_xcaufv.
      READ TABLE gt_xcaufv INTO ls_xcaufv
                           WITH KEY plnbez = ls_caufv-plnbez.
      IF sy-subrc = 0.
        PERFORM f_collect_alv_data TABLES lt_alv
                                   USING ls_caufv-aufnr.
      ELSE.  "IF ls_caufv-plnbez(1) = 'I'.
        CLEAR ls_afpo.
        READ TABLE gt_afpo INTO ls_afpo
                           WITH KEY aufnr = ls_caufv-aufnr.
        IF sy-subrc = 0.
          IF fu_matnr IS NOT INITIAL.
            READ TABLE gt_afpo INTO ls_xafpo
                               WITH KEY matnr = fu_matnr
                                        charg = ls_afpo-charg.
            IF sy-subrc = 0.
              PERFORM f_collect_alv_data TABLES lt_alv
                                         USING ls_caufv-aufnr.
            ENDIF.
          ELSE.
            LOOP AT gt_xmara INTO ls_xmara.
              READ TABLE gt_afpo INTO ls_xafpo
                                 WITH KEY matnr = ls_xmara-matnr
                                          charg = ls_afpo-charg.
              IF sy-subrc = 0.
                PERFORM f_collect_alv_data TABLES lt_alv
                                           USING ls_caufv-aufnr.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF fu_matnr IS NOT INITIAL.
        IF ls_caufv-plnbez = fu_matnr.
          PERFORM f_collect_alv_data TABLES lt_alv
                                     USING ls_caufv-aufnr.
        ENDIF.
      ELSE.
        LOOP AT gt_xmara INTO ls_xmara.
          IF ls_caufv-plnbez = ls_xmara-matnr.
            PERFORM f_collect_alv_data TABLES lt_alv
                                       USING ls_caufv-aufnr.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM f_calc_act_amount USING ''.

ENDFORM.                    " F_DISPLAY_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ACTUAL_QTY_VAL
*&---------------------------------------------------------------------*
FORM f_actual_qty_val  TABLES   ft_alv STRUCTURE gt_detlgen.
  DATA : ls_alv  TYPE ty_detail,
         ls_s026 TYPE s026.

  DATA : lv_megxxx TYPE megxxx,
         lv_wtgxxx TYPE wtgxxx,
         lv_wkgxxx TYPE wkgxxx,
         lv_meinh  TYPE meinh.

  LOOP AT ft_alv INTO ls_alv.
    CASE ls_alv-tbma_val.
      WHEN 'COSP'.
        CLEAR : ls_s026, lv_megxxx, lv_wtgxxx.
        IF ls_alv-hrkft IS INITIAL.
          IF ls_alv-sourc IS INITIAL.
            PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                           ls_alv-hrkft '' ls_alv-tbma_val '04'
                                     CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
          ELSE.
            LOOP AT gt_s026 INTO ls_s026 WHERE aufnr = ls_alv-aufnr
                                           AND mcomp = ls_alv-matnr.
              ADD ls_s026-enwrt TO lv_wtgxxx.
              ADD ls_s026-enmng TO lv_megxxx.
            ENDLOOP.
          ENDIF.
        ELSE.
          PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                         ls_alv-hrkft '' ls_alv-tbma_val '04'
                                   CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
        ENDIF.

        ls_alv-actqty  = lv_megxxx.
        ls_alv-actval  = lv_wtgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING actqty actval.

      WHEN 'COSS'.
        CLEAR : lv_megxxx, lv_wtgxxx.
        PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                       '' ls_alv-uspob ls_alv-tbma_val '04'
                                 CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.

        ls_alv-actqty  = lv_megxxx.
        ls_alv-meinb   = lv_meinh.
        ls_alv-actval  = lv_wtgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING actqty meinb actval.
    ENDCASE.
    CLEAR ls_alv.
  ENDLOOP.
ENDFORM.                    " F_ACTUAL_QTY_VAL

*&---------------------------------------------------------------------*
*&      Form  F_PLAN_QTY_VAL
*&---------------------------------------------------------------------*
FORM f_plan_qty_val  TABLES   ft_alv STRUCTURE gt_detlgen.
  DATA : ls_alv  TYPE ty_detail,
         ls_resb TYPE resb.

  DATA : lv_megxxx TYPE megxxx,
         lv_wtgxxx TYPE wtgxxx,
         lv_wkgxxx TYPE wkgxxx,
         lv_meinh  TYPE meinh.

  SORT ft_alv BY objnr kstar.
  SORT gt_cosp BY objnr kstar.
  SORT gt_coss BY objnr kstar.

  LOOP AT ft_alv INTO ls_alv.
    CASE ls_alv-tbma_val.
      WHEN 'COSP'.
        CLEAR : ls_resb, lv_megxxx, lv_wtgxxx, lv_meinh.
        IF ls_alv-hrkft IS INITIAL.
          IF ls_alv-sourc IS INITIAL.
            PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                           ls_alv-hrkft '' 'COSP' '01'
                                     CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
          ELSE.
            READ TABLE gt_resb INTO ls_resb WITH KEY aufnr = ls_alv-aufnr
                                                     matnr = ls_alv-matnr.
            IF sy-subrc = 0.
              lv_wtgxxx      = ( ls_resb-gpreis / ls_resb-peinh ) * ls_resb-erfmg.
              lv_megxxx      = ls_resb-erfmg.
            ENDIF.
          ENDIF.
        ELSE.
          PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                         ls_alv-hrkft '' 'COSP' '01'
                                   CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
        ENDIF.

        ls_alv-plnqty  = lv_megxxx.
        ls_alv-plnval  = lv_wtgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING plnqty plnval.

      WHEN 'COSS'.
        CLEAR : lv_megxxx, lv_wtgxxx, lv_meinh.
        PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                       '' ls_alv-uspob 'COSS' '01'
                                 CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.

        ls_alv-plnqty  = lv_megxxx.
        ls_alv-meinb   = lv_meinh.
        ls_alv-plnval  = lv_wtgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING plnqty meinb plnval.
    ENDCASE.
    CLEAR ls_alv.
  ENDLOOP.
ENDFORM.                    " F_PLAN_QTY_VAL

*&---------------------------------------------------------------------*
*&      Form  F_TARGET_QTY_VAL
*&---------------------------------------------------------------------*
FORM f_target_qty_val  TABLES   ft_alv STRUCTURE gt_detlgen.
  DATA : ls_alv  TYPE ty_detail,
         ls_s026 TYPE s026.

  DATA : lv_megxxx TYPE megxxx,
         lv_wtgxxx TYPE wtgxxx,
         lv_wkgxxx TYPE wkgxxx,
         lv_meinh  TYPE meinh.

  LOOP AT ft_alv INTO ls_alv.
    CASE ls_alv-tbma_val.
      WHEN 'COSP'.
        CLEAR : ls_s026, lv_megxxx, lv_wtgxxx, lv_wkgxxx.
        IF ls_alv-hrkft IS INITIAL.
          IF ls_alv-sourc IS INITIAL.
            PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                           ls_alv-hrkft '' ls_alv-tbma_val '05'
                                     CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
          ENDIF.
        ELSE.
          PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                         ls_alv-hrkft '' ls_alv-tbma_val '05'
                                   CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.
        ENDIF.

        ls_alv-tgtqty  = lv_megxxx.
        ls_alv-tgtval  = lv_wkgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING tgtqty tgtval.

      WHEN 'COSS'.
        CLEAR : lv_megxxx, lv_wtgxxx, lv_wkgxxx.
        PERFORM f_calc_fr_period USING ls_alv-objnr ls_alv-kstar
                                       '' ls_alv-uspob ls_alv-tbma_val '05'
                                 CHANGING lv_megxxx lv_wtgxxx lv_wkgxxx lv_meinh.

        ls_alv-tgtqty  = lv_megxxx.
        ls_alv-meinb   = lv_meinh.
        ls_alv-tgtval  = lv_wkgxxx.

        MODIFY ft_alv FROM ls_alv TRANSPORTING tgtqty meinb tgtval.
    ENDCASE.
    CLEAR ls_alv.
  ENDLOOP.
ENDFORM.                    " F_TARGET_QTY_VAL

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_TO_ALV
*&---------------------------------------------------------------------*
FORM f_detail_to_alv  TABLES   ft_alv STRUCTURE gt_detlgen
                      USING    fu_detail  STRUCTURE gt_detlgen.
  DATA : ls_alv   TYPE ty_detail,
         ls_resb  TYPE resb,
         ls_makt  TYPE makt,
         ls_cokey LIKE LINE OF gt_cokey.

  ls_alv  = fu_detail.

  IF fu_detail-matnr IS NOT INITIAL.
    APPEND ls_alv TO ft_alv.
  ELSE.
    READ TABLE gt_resb INTO ls_resb WITH KEY aufnr = fu_detail-aufnr
                                             saknr = fu_detail-kstar
                                    TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_resb INTO ls_resb WHERE aufnr = fu_detail-aufnr
                                     AND saknr = fu_detail-kstar.
        ls_alv-sourc   = ls_resb-matnr.
        ls_alv-matnr   = ls_resb-matnr.

        READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_resb-matnr.
        IF sy-subrc = 0.
          ls_alv-sourt   = ls_makt-maktx.
        ENDIF.

        READ TABLE gt_cokey INTO ls_cokey WITH KEY matnr = ls_resb-matnr.
        IF sy-subrc = 0.
          ls_alv-hrkft   = ls_cokey-hrkft.
        ELSE.
          CONTINUE.
        ENDIF.
        APPEND ls_alv TO ft_alv.
      ENDLOOP.
    ELSE.
      APPEND ls_alv TO ft_alv.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DETAIL_TO_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CALC_FR_PERIOD
*&---------------------------------------------------------------------*
FORM f_calc_fr_period  USING    fu_objnr fu_kstar fu_hrkft fu_uspob
                                fu_tbma_val fu_wrttp
                       CHANGING fc_megxxx fc_wtgxxx fc_wkgxxx fc_meinh.

  DATA : ls_cosp   TYPE cosp,
         ls_coss   TYPE coss,
         lv_megxxx TYPE megxxx,
         lv_wtgxxx TYPE wtgxxx,
         lv_wkgxxx TYPE wkgxxx.

  CASE fu_tbma_val.
    WHEN 'COSP'.
      LOOP AT gt_cosp INTO ls_cosp WHERE objnr = fu_objnr
                                     AND kstar = fu_kstar
                                     AND hrkft = fu_hrkft
                                     AND wrttp = fu_wrttp.
        lv_megxxx   = ls_cosp-meg001 + ls_cosp-meg002 + ls_cosp-meg003 +
                      ls_cosp-meg004 + ls_cosp-meg005 + ls_cosp-meg006 +
                      ls_cosp-meg007 + ls_cosp-meg008 + ls_cosp-meg009 +
                      ls_cosp-meg010 + ls_cosp-meg011 + ls_cosp-meg012.

        lv_wtgxxx   = ls_cosp-wtg001 + ls_cosp-wtg002 + ls_cosp-wtg003 +
                      ls_cosp-wtg004 + ls_cosp-wtg005 + ls_cosp-wtg006 +
                      ls_cosp-wtg007 + ls_cosp-wtg008 + ls_cosp-wtg009 +
                      ls_cosp-wtg010 + ls_cosp-wtg011 + ls_cosp-wtg012.

        lv_wkgxxx   = ls_cosp-wkg001 + ls_cosp-wkg002 + ls_cosp-wkg003 +
                      ls_cosp-wkg004 + ls_cosp-wkg005 + ls_cosp-wkg006 +
                      ls_cosp-wkg007 + ls_cosp-wkg008 + ls_cosp-wkg009 +
                      ls_cosp-wkg010 + ls_cosp-wkg011 + ls_cosp-wkg012.

        fc_meinh   = ls_cosp-meinh.

        ADD lv_megxxx TO fc_megxxx.
        ADD lv_wtgxxx TO fc_wtgxxx.
        ADD lv_wkgxxx TO fc_wkgxxx.
      ENDLOOP.

    WHEN 'COSS'.
      LOOP AT gt_coss INTO ls_coss WHERE objnr = fu_objnr
                                     AND kstar = fu_kstar
                                     AND parob = fu_uspob
                                     AND wrttp = fu_wrttp.
        lv_megxxx   = ls_coss-meg001 + ls_coss-meg002 + ls_coss-meg003 +
                      ls_coss-meg004 + ls_coss-meg005 + ls_coss-meg006 +
                      ls_coss-meg007 + ls_coss-meg008 + ls_coss-meg009 +
                      ls_coss-meg010 + ls_coss-meg011 + ls_coss-meg012.

        lv_wtgxxx   = ls_coss-wtg001 + ls_coss-wtg002 + ls_coss-wtg003 +
                      ls_coss-wtg004 + ls_coss-wtg005 + ls_coss-wtg006 +
                      ls_coss-wtg007 + ls_coss-wtg008 + ls_coss-wtg009 +
                      ls_coss-wtg010 + ls_coss-wtg011 + ls_coss-wtg012.

        lv_wkgxxx   = ls_coss-wkg001 + ls_coss-wkg002 + ls_coss-wkg003 +
                      ls_coss-wkg004 + ls_coss-wkg005 + ls_coss-wkg006 +
                      ls_coss-wkg007 + ls_coss-wkg008 + ls_coss-wkg009 +
                      ls_coss-wkg010 + ls_coss-wkg011 + ls_coss-wkg012.

        fc_meinh    = ls_coss-meinh.

        ADD lv_megxxx TO fc_megxxx.
        ADD lv_wtgxxx TO fc_wtgxxx.
        ADD lv_wkgxxx TO fc_wkgxxx.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALC_FR_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_bukrs IS INITIAL.
    PERFORM f_screen_error USING 'BUK'.
  ENDIF.
  IF pa_werks IS INITIAL.
    PERFORM f_screen_error USING 'WER'.
  ENDIF.
  IF so_matnr[] IS INITIAL.
    PERFORM f_screen_error USING 'MAT'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  USING    fu_dynprofield.
  DATA : lt_tj02t       TYPE STANDARD TABLE OF ty_tj02t,
         ls_tj02t       TYPE tj02t,
         lv_dynprofield TYPE help_info-dynprofld.

  lv_dynprofield  = fu_dynprofield.

  SELECT istat txt04
    FROM tj02t
    INTO TABLE lt_tj02t
    WHERE spras = sy-langu.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TXT04'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_dynprofield
      value_org       = 'S'
    TABLES
      value_tab       = lt_tj02t
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ACT_AMOUNT
*&---------------------------------------------------------------------*
FORM f_calc_act_amount  USING fu_objnr.
  DATA : ls_alv    TYPE ty_detail,
         ls_mbew   LIKE LINE OF gt_mbew,
         ls_covp   LIKE LINE OF gt_covp,
         ls_ckmlcr LIKE LINE OF gt_ckmlcr.

  DATA : lv_megbtr TYPE covp-megbtr,
         lv_pvprs  TYPE ckmlcr-pvprs,
         lv_peinh  TYPE ckmlcr-peinh,
         lv_actamt TYPE covp-wtgbtr.

  DATA : lv_xmegbtr TYPE covp-megbtr,
         lv_xpvprs  TYPE ckmlcr-pvprs,
         lv_xactamt TYPE covp-wtgbtr.

  PERFORM f_added_logic_8040.

  LOOP AT gt_alv INTO ls_alv.
    CLEAR ls_mbew.
    READ TABLE gt_mbew INTO ls_mbew
                       WITH KEY matnr = ls_alv-sourc.
    IF sy-subrc = 0.
      CLEAR : ls_covp, lv_xmegbtr, lv_xactamt.
      LOOP AT gt_covp INTO ls_covp WHERE objnr = ls_alv-objnr
                                     AND matnr = ls_alv-sourc
                                     AND kstar = ls_alv-kstar
                                     AND vrgng = 'COIN'.
        IF fu_objnr IS NOT INITIAL.
          IF ls_covp-objnr <> fu_objnr.
            CONTINUE.
          ENDIF.
        ENDIF.

        CLEAR ls_ckmlcr.
        READ TABLE gt_ckmlcr INTO ls_ckmlcr
                             WITH KEY kalnr = ls_mbew-kaln1
                                      poper = ls_covp-perio
                                      bdatj = ls_covp-gjahr.
        IF sy-subrc = 0.
          IF ls_ckmlcr-peinh IS NOT INITIAL.
*             ls_alv-pvprs  = ls_ckmlcr-pvprs / ls_ckmlcr-peinh.
            lv_actamt     = ( ls_ckmlcr-pvprs / ls_ckmlcr-peinh ) * ls_covp-megbtr.
          ELSE.
*             ls_alv-pvprs  = ls_ckmlcr-pvprs.
            lv_actamt     = ls_ckmlcr-pvprs * ls_covp-megbtr.
          ENDIF.
        ENDIF.

        ADD ls_covp-megbtr TO lv_xmegbtr.
        ADD lv_actamt TO lv_xactamt.
      ENDLOOP.

      ls_alv-megbtr = lv_xmegbtr.
      ls_alv-actamt = lv_xactamt.

      TRY .
          ls_alv-pvprs = ls_alv-actamt / ls_alv-megbtr.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      MODIFY TABLE gt_alv FROM ls_alv TRANSPORTING pvprs megbtr actamt.
    ELSE.
      IF ls_alv-kstar(1) = '1'.
        ls_alv-megbtr = ls_alv-actqty.
        ls_alv-actamt = ls_alv-actval.
      ENDIF.

      TRY .
          ls_alv-pvprs = ls_alv-actamt / ls_alv-megbtr.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      MODIFY TABLE gt_alv FROM ls_alv TRANSPORTING pvprs megbtr actamt.
    ENDIF.
    CLEAR ls_alv.
  ENDLOOP.
ENDFORM.                    " F_CALC_ACT_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_DATA
*&---------------------------------------------------------------------*
FORM f_additional_data .
  DATA : lt_afpo     TYPE STANDARD TABLE OF afpo,
         lt_xafpo    TYPE STANDARD TABLE OF afpo,
         ls_afpo     LIKE LINE OF lt_afpo,
         ls_xcaufv   LIKE LINE OF gt_xcaufv,
         ls_ycaufv   LIKE LINE OF gt_caufv,
         ls_caufv    LIKE LINE OF gt_caufv,
         ls_xafpo    LIKE LINE OF lt_xafpo,
         lr_aufnr    TYPE RANGE OF aufnr,
         ls_aufnr    LIKE LINE OF so_aufnr,
         lr_matnr    TYPE RANGE OF matnr,
         ls_matnr    LIKE LINE OF lr_matnr,
         ls_material LIKE LINE OF gt_material.

  lt_afpo[] = gt_afpo[].
  SORT lt_afpo BY charg.
  DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING charg.
*  LOOP AT lt_afpo INTO ls_afpo.
*    IF ls_afpo-matnr(1) = 'I'.
*      DELETE TABLE lt_afpo FROM ls_afpo.
*    ENDIF.
*  ENDLOOP.

  IF lt_afpo[] IS NOT INITIAL.
    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE lt_xafpo
      FOR ALL ENTRIES IN lt_afpo
      WHERE charg = lt_afpo-charg
      ORDER BY PRIMARY KEY.

    LOOP AT gt_xcaufv INTO ls_xcaufv.
      CLEAR ls_material.
      READ TABLE gt_material INTO ls_material
                             WITH KEY matnr = ls_xcaufv-plnbez.
      IF sy-subrc = 0.
        CASE ls_material-mtart.
          WHEN 'ZSFG'.
            LOOP AT lt_xafpo INTO ls_xafpo.
              IF ls_xafpo-matnr(1) <> 'I'.
                ls_matnr-low    = ls_xafpo-matnr.
                ls_matnr-sign   = 'I'.
                ls_matnr-option = 'EQ'.
                APPEND ls_matnr TO lr_matnr.
                CLEAR ls_matnr.

                ls_aufnr-low    = ls_xafpo-aufnr.
                ls_aufnr-sign   = 'I'.
                ls_aufnr-option = 'EQ'.
                APPEND ls_aufnr TO lr_aufnr.
                CLEAR ls_aufnr.

                APPEND ls_xafpo TO gt_afpo.
              ENDIF.
              CLEAR ls_xafpo.
            ENDLOOP.
          WHEN OTHERS.
            LOOP AT lt_xafpo INTO ls_xafpo.
              IF ls_xafpo-matnr(1) = 'I'.
                ls_matnr-low    = ls_xafpo-matnr.
                ls_matnr-sign   = 'I'.
                ls_matnr-option = 'EQ'.
                APPEND ls_matnr TO lr_matnr.
                CLEAR ls_matnr.

                ls_aufnr-low    = ls_xafpo-aufnr.
                ls_aufnr-sign   = 'I'.
                ls_aufnr-option = 'EQ'.
                APPEND ls_aufnr TO lr_aufnr.
                CLEAR ls_aufnr.

                APPEND ls_xafpo TO gt_afpo.
              ENDIF.
              CLEAR ls_xafpo.
            ENDLOOP.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lr_matnr[] IS NOT INITIAL AND
    lr_aufnr[] IS NOT INITIAL.
    SELECT aufnr plnbez ktext gamng waers objnr gltri
      FROM caufv
      APPENDING CORRESPONDING FIELDS OF TABLE gt_caufv
      WHERE bukrs  = pa_bukrs
        AND werks  = pa_werks
        AND plnbez IN lr_matnr
        AND aufnr  IN lr_aufnr
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_ADDITIONAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_collect_alv_data  TABLES   ft_alv LIKE gt_alv
                         USING    fu_aufnr.
  DATA : ls_alv  LIKE LINE OF gt_alv,
         ls_mara LIKE LINE OF gt_mara.

  LOOP AT ft_alv INTO ls_alv.
    IF fu_aufnr IS NOT INITIAL.
      IF ls_alv-aufnr <> fu_aufnr.
        CONTINUE.
      ENDIF.
    ENDIF.
    CLEAR : ls_alv-matnr.
    IF ls_alv-meinb IS INITIAL.
      READ TABLE gt_mara INTO ls_mara WITH KEY matnr = ls_alv-sourc.
      IF sy-subrc = 0.
        ls_alv-meinb  = ls_mara-meins.
      ENDIF.
    ENDIF.
    COLLECT ls_alv INTO gt_alv.
    CLEAR ls_alv.
  ENDLOOP.
ENDFORM.                    " F_COLLECT_ALV_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NODE_DETAIL
*&---------------------------------------------------------------------*
FORM f_add_node_detail  USING    fu_aufnr fu_key_main
                        CHANGING fc_node_key   TYPE lvc_nkey.
  DATA : lv_key_main  TYPE lvc_nkey,
         lv_key_node1 TYPE lvc_nkey,
         lv_node      TYPE lvc_value,
         ls_all       TYPE ty_detail.

  DATA : lv_actval LIKE covp-wtgbtr,
         lv_plnval LIKE covp-wtgbtr,
         lv_tgtval LIKE covp-wtgbtr.

  CLEAR lv_node.
  lv_node = fu_aufnr.

  CLEAR : lv_actval, lv_plnval, lv_tgtval.
  LOOP AT gt_all INTO ls_all WHERE aufnr = fu_aufnr.
    IF ls_all-kstar = '0751500000'.
      CONTINUE.
    ENDIF.
    ADD ls_all-actval TO lv_actval.
    ADD ls_all-plnval TO lv_plnval.
    ADD ls_all-tgtval TO lv_tgtval.
  ENDLOOP.

  WRITE lv_actval TO wa_tree-node_n01 CURRENCY 'IDR'.
  WRITE lv_tgtval TO wa_tree-node_n02 CURRENCY 'IDR'.
  WRITE lv_plnval TO wa_tree-node_n03 CURRENCY 'IDR'.

  PERFORM f_add_node USING    wa_tree fu_key_main lv_node
                     CHANGING fc_node_key.
ENDFORM.                    " F_ADD_NODE_DETAIL

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ADDED_LOGIC_8040
*&---------------------------------------------------------------------*
FORM f_added_logic_8040 .
  IF pa_bukrs = '8040'.
    DATA(lt_alv) = gt_alv[].
    REFRESH lt_alv.
    LOOP AT gt_alv INTO DATA(ls_alv).
      IF NOT line_exists( gt_mbew[ matnr = ls_alv-sourc ] ).
        APPEND INITIAL LINE TO lt_alv ASSIGNING FIELD-SYMBOL(<fs_alv>).
        MOVE-CORRESPONDING ls_alv TO <fs_alv>.
        <fs_alv>-matnr = ls_alv-sourc.
      ENDIF.
    ENDLOOP.

    IF lt_alv[] IS NOT INITIAL.
      SELECT * INTO TABLE @DATA(lt_mbew)
        FROM mbew FOR ALL ENTRIES IN @lt_alv
        WHERE matnr = @lt_alv-matnr
          AND bwkey = @pa_werks
        ORDER BY PRIMARY KEY.
      IF lt_mbew[]  IS NOT INITIAL.
        SELECT * INTO TABLE @DATA(lt_ckmlcr)
          FROM ckmlcr FOR ALL ENTRIES IN @lt_mbew
          WHERE kalnr = @lt_mbew-kaln1
          ORDER BY PRIMARY KEY.
      ENDIF.
    ENDIF.

    IF lt_mbew[] IS NOT INITIAL.
      APPEND LINES OF lt_mbew TO gt_mbew.
      SORT gt_mbew BY matnr bwkey bwtar.
    ENDIF.
    IF lt_ckmlcr[] IS NOT INITIAL.
      APPEND LINES OF lt_ckmlcr TO gt_ckmlcr.
      SORT gt_ckmlcr BY kalnr bdatj poper untper curtp.
    ENDIF.
  ENDIF.
ENDFORM.
