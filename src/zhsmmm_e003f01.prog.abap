*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'PAE' '' '0' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_frgco IS INITIAL.
    PERFORM f_error_message USING 'PFR' ''.
  ENDIF.
  IF pa_listu IS INITIAL.
    PERFORM f_error_message USING 'PLI' ''.
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
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE gt_05
    WHERE tcode = 'ZMME011'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_xekko TYPE STANDARD TABLE OF ekko,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_xeket TYPE STANDARD TABLE OF eket.

  SELECT *
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE gt_ekko
    FOR ALL ENTRIES IN zus
    WHERE frgrl = 'X'
      AND frggr = zus-frggr
      AND frgsx = zus-frgsx
      AND ebeln IN so_ebeln
      AND bstyp IN so_bstyp
      AND ekorg IN so_ekorg
      AND lifnr IN so_lifnr
      AND reswk IN so_reswk
      AND bedat IN so_bedat
      AND bsart IN so_bsart
      AND ekgrp IN so_ekgrp
      AND submi IN so_submi
      AND loekz = space
      AND procstat IN so_procs.

  CASE 'X'.
    WHEN radio2.
      zus-frggr = ''.
      zus-frgsx = ''.
      APPEND zus.

      SELECT *
        FROM ekko
        APPENDING CORRESPONDING FIELDS OF TABLE gt_ekko
        FOR ALL ENTRIES IN zus
        WHERE frgrl = space
          AND frggr = zus-frggr
          AND frgsx = zus-frgsx
          AND ebeln IN so_ebeln
          AND bstyp IN so_bstyp
          AND ekorg IN so_ekorg
          AND lifnr IN so_lifnr
          AND reswk IN so_reswk
          AND bedat IN so_bedat
          AND bsart IN so_bsart
          AND ekgrp IN so_ekgrp
          AND submi IN so_submi
          AND loekz = space
          AND procstat IN so_procs.
  ENDCASE.

  PERFORM f_validate_authorization_ekko.

  IF gt_ekko[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
      FOR ALL ENTRIES IN gt_ekko
      WHERE ebeln = gt_ekko-ebeln
        AND loekz = space.
  ENDIF.

  lt_xekpo[] = gt_ekpo[].
  SORT lt_xekpo BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING ebeln.
  IF lt_xekpo[] IS NOT INITIAL.
    SELECT *
      FROM eket
      INTO CORRESPONDING FIELDS OF TABLE gt_eket
      FOR ALL ENTRIES IN lt_xekpo
      WHERE ebeln = lt_xekpo-ebeln.
  ENDIF.

  lt_xekko[] = gt_ekko[].
  SORT lt_xekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xekko COMPARING lifnr.
  IF lt_xekko[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FOR ALL ENTRIES IN lt_xekko
      WHERE lifnr = lt_xekko-lifnr.
  ENDIF.

  lt_xekpo[] = gt_ekpo[].
  SORT lt_xekpo BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING matnr.
  IF lt_xekpo[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_xekpo
      WHERE spras = sy-langu
        AND matnr = lt_xekpo-matnr.
  ENDIF.

  lt_xeket[] = gt_eket[].
  SORT lt_xeket BY banfn bnfpo.
  DELETE ADJACENT DUPLICATES FROM lt_xeket COMPARING banfn bnfpo.
  IF lt_xeket[] IS NOT INITIAL.
    SELECT *
      FROM eban
      INTO CORRESPONDING FIELDS OF TABLE gt_eban
      FOR ALL ENTRIES IN lt_xeket
      WHERE banfn = lt_xeket-banfn
        AND bnfpo = lt_xeket-bnfpo.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_ekko LIKE LINE OF gt_ekko,
         ls_lfa1 LIKE LINE OF gt_lfa1,
         ls_ekpo LIKE LINE OF gt_ekpo,
         ls_eket LIKE LINE OF gt_eket,
         ls_out  LIKE LINE OF gt_out,
         ls_makt LIKE LINE OF gt_makt.

  DATA : lt_xdata TYPE STANDARD TABLE OF ty_out,
         ls_xdata LIKE LINE OF lt_xdata,
         ls_data  LIKE LINE OF gt_data.

  DATA : lv_menge   TYPE ekpo-menge.

  LOOP AT gt_ekko INTO ls_ekko.
    IF ls_ekko-submi IS INITIAL.
      CONTINUE.
    ENDIF.
    ls_out-ebeln  = ls_ekko-ebeln.
    ls_out-lifnr  = ls_ekko-lifnr.
    ls_out-ekgrp  = ls_ekko-ekgrp.
    CLEAR ls_lfa1.
    READ TABLE gt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = ls_ekko-lifnr.
    IF sy-subrc = 0.
      ls_out-name1   = ls_lfa1-name1.
    ENDIF.
    ls_out-submi  = ls_ekko-submi.
    ls_out-waers  = ls_ekko-waers.
    ls_out-aedat  = ls_ekko-aedat.
    ls_out-bedat  = ls_ekko-bedat.
    ls_out-ihran  = ls_ekko-ihran.
    ls_out-bwbdt  = ls_ekko-bwbdt.
    ls_out-angdt  = ls_ekko-angdt.
    ls_out-kdatb  = ls_ekko-kdatb.
    ls_out-kdate  = ls_ekko-kdate.
    ls_out-bnddt  = ls_ekko-bnddt.
    ls_out-ernam  = ls_ekko-ernam.

    CLEAR : ls_ekpo.
    LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
      ls_out-ebelp   = ls_ekpo-ebelp.
      ls_out-loekz   = ls_ekpo-loekz.
      ls_out-matnr   = ls_ekpo-matnr.
      CLEAR ls_makt.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr = ls_ekpo-matnr.
      IF sy-subrc = 0.
        ls_out-maktx    = ls_makt-maktx.
      ENDIF.
      ls_out-menge   = ls_ekpo-menge.
      ls_out-meins   = ls_ekpo-meins.

      READ TABLE gt_eket INTO ls_eket
                         WITH KEY ebeln = ls_ekpo-ebeln
                                  ebelp = ls_ekpo-ebelp.
      IF sy-subrc = 0.
        ls_out-banfn   = ls_eket-banfn.
        ls_out-bnfpo   = ls_eket-bnfpo.
      ENDIF.
      APPEND ls_out TO gt_data.
    ENDLOOP.
    CLEAR ls_out.
  ENDLOOP.

  lt_xdata[]  = gt_data[].
  SORT lt_xdata BY matnr submi ebeln lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xdata COMPARING matnr submi ebeln lifnr.
  LOOP AT lt_xdata INTO ls_xdata.
    MOVE-CORRESPONDING ls_xdata TO ls_out.
    CLEAR : ls_data, lv_menge.
    LOOP AT gt_data INTO ls_data WHERE matnr = ls_xdata-matnr
                                   AND submi = ls_xdata-submi
                                   AND ebeln = ls_xdata-ebeln
                                   AND lifnr = ls_xdata-lifnr.
      ADD ls_data-menge TO lv_menge.
    ENDLOOP.
    ls_out-menge  = lv_menge.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 101.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  CREATE OBJECT event_receiver.

  IF gt_bapiret2 IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  gs_variant-report = gv_repid.
  gv_dynnr          = sy-dynnr.

  CASE sy-dynnr.
    WHEN '0101'.
      CASE 'X'.
        WHEN radio1.
          SET TITLEBAR 'RELEASE'.
          dyn_process-icon_id      = icon_set_state.
          dyn_process-icon_text    = 'Release'.
          dyn_reject-icon_id       = icon_set_state.
          dyn_reject-icon_text     = 'Reject'.

        WHEN radio2.
          SET TITLEBAR 'CANCEL'.
          dyn_process-icon_id      = icon_incomplete.
          dyn_process-icon_text    = 'Cancel Release'.
          dyn_reject-icon_id       = icon_incomplete.
          dyn_reject-icon_text     = 'Cancel Reject'.
      ENDCASE.
      SET PF-STATUS 'STANDARD'.

    WHEN '0102'.

  ENDCASE.

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
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c,
         lv_lines TYPE i.

  DATA : lt_out    TYPE STANDARD TABLE OF ty_out,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_prepare_process TABLES lt_out.
        IF lt_out[] IS NOT INITIAL.
          CASE 'X'.
            WHEN radio1.
              PERFORM f_release_quotation TABLES lt_out.
              PERFORM f_send_email USING '1' 'ZAPPROVALRFQ'
                                         'green'.

            WHEN radio2.
              PERFORM f_release_cancel_quotation TABLES lt_out.
              PERFORM f_send_email USING '2' 'ZREJECTRFQ'
                                         'red'.
          ENDCASE.
        ELSE.
          MESSAGE s000(zab) WITH 'No data to process' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN '&RJT'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_prepare_process TABLES lt_out.
        IF lt_out[] IS NOT INITIAL.
          CASE 'X'.
            WHEN radio1.
              PERFORM f_reject_quotation TABLES lt_out.
              PERFORM f_send_email USING '3' 'ZAPPROVALRFQ'
                                         'red'.

            WHEN radio2.
              PERFORM f_reject_cancel_quotation TABLES lt_out.
              PERFORM f_send_email USING '4' 'ZREJECTRFQ'
                                         'red'.
          ENDCASE.
        ELSE.
          MESSAGE s000(zab) WITH 'No data to process' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid01->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid01->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid01->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid01->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid01->get_frontend_fieldcatalog
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
    PERFORM f_alv_refresh USING 'X' 'MAIN'.
  ENDIF.
ENDFORM.                    " F_SELECT

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
        container = g_contain01.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_contain02.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_ITEM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_item_double_click  USING    fu_fieldname
                                          fu_node_key.
  DATA : node_text   TYPE lvc_value,
         item_layout TYPE lvc_t_layi,
         node_layout TYPE lvc_s_layn,
         ls_item     TYPE lvc_s_layi.

  CALL METHOD g_tree->get_outtab_line
    EXPORTING
      i_node_key     = fu_node_key
    IMPORTING
      e_node_text    = node_text
      et_item_layout = item_layout
      es_node_layout = node_layout.

  READ TABLE item_layout INTO ls_item INDEX 1.
  IF sy-subrc = 0.
    gv_fieldname = ls_item-fieldname.
    PERFORM f_call_me42 USING node_text ls_item-fieldname fu_node_key.
*    PERFORM f_prepare_data USING node_text ls_item-fieldname.
  ENDIF.

*  PERFORM f_alv_refresh USING 'X' 'TREE'.
ENDFORM.                    " F_HANDLE_ITEM_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_AUTHORIZATION_EKKO
*&---------------------------------------------------------------------*
FORM f_validate_authorization_ekko .
  DATA : ls_ekko     LIKE LINE OF gt_ekko,
         hfdpos      LIKE sy-fdpos,
         xfrg1       LIKE ekko-frgzu,
         xfrg2       LIKE ekko-frgzu,
         xobjekt(10).

  FIELD-SYMBOLS : <f1>.

  LOOP AT gt_ekko INTO ls_ekko.
    MOVE-CORRESPONDING ls_ekko TO zuskey.
    READ TABLE zus WITH KEY zuskey.
    CHECK sy-subrc EQ 0.
    xfrg1 = zus+9(8).
    xfrg2 = ls_ekko-frgzu.
    TRANSLATE xfrg2 USING 'X  +'.
    OVERLAY xfrg1 WITH xfrg2 ONLY '+'.
    SEARCH xfrg1 FOR 'X'.
    IF sy-subrc NE 0.
      DELETE TABLE gt_ekko FROM ls_ekko.
      CONTINUE.
    ELSE.
      hfdpos = sy-fdpos.
      ASSIGN xfrg2+sy-fdpos(1) TO <f1>.
      CASE 'X'.
        WHEN radio1.
          IF <f1> EQ space.
            DELETE TABLE gt_ekko FROM ls_ekko.
            CONTINUE.
          ELSE.
            IF xfrg1 CA '+'.
              DELETE TABLE gt_ekko FROM ls_ekko.
              CONTINUE.
            ENDIF.
          ENDIF.
        WHEN radio2.
          IF <f1> NE space.
            DELETE TABLE gt_ekko FROM ls_ekko.
            CONTINUE.
          ENDIF.
      ENDCASE.
    ENDIF.

    CASE ls_ekko-bstyp.
      WHEN 'F'.
        xobjekt = 'M_BEST_'.
      WHEN 'A'.
        xobjekt = 'M_ANFR_'.
      WHEN 'L'.
        xobjekt = 'M_LPET_'.
      WHEN 'K'.
        xobjekt = 'M_RAHM_'.
    ENDCASE.

    IF ls_ekko-ekgrp NE space.
      xobjekt+7(3) = 'EKG'.
      AUTHORITY-CHECK OBJECT xobjekt
           ID 'ACTVT' FIELD '02'
           ID 'EKGRP' FIELD ls_ekko-ekgrp.
      IF sy-subrc <> space.
        DELETE TABLE gt_ekko FROM ls_ekko.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF ls_ekko-bsart NE space.
      xobjekt+7(3) = 'BSA'.
      AUTHORITY-CHECK OBJECT xobjekt
      ID 'ACTVT' FIELD '02'
      ID 'BSART' FIELD ls_ekko-bsart.
      IF sy-subrc <> space.
        DELETE TABLE gt_ekko FROM ls_ekko.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF ls_ekko-ekorg NE space.
      xobjekt+7(3) = 'EKO'.
      AUTHORITY-CHECK OBJECT xobjekt
      ID 'ACTVT' FIELD '02'
      ID 'EKORG' FIELD ls_ekko-ekorg.
      IF sy-subrc <> space.
        DELETE TABLE gt_ekko FROM ls_ekko.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_AUTHORIZATION_EKKO

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  CREATE OBJECT g_tabgrid01
    EXPORTING
      i_appl_events = selected
      i_parent      = g_contain01.

  PERFORM f_build_layout USING 'MAIN'.
  PERFORM f_build_sort USING 'MAIN'.

  SET HANDLER event_receiver->handle_double_click
              event_receiver->handle_toolbar
              event_receiver->handle_menu_button
              event_receiver->handle_user_command FOR g_tabgrid01.

  CALL METHOD g_tabgrid01->set_table_for_first_display
    EXPORTING
      is_layout            = gs_main_layout
      i_save               = 'A'
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gs_exclude
    CHANGING
      it_sort              = gt_main_sort[]
      it_outtab            = gt_out[]
      it_fieldcatalog      = gt_main_fieldcat[].

  IF gt_xout[] IS INITIAL.
    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER
*&---------------------------------------------------------------------*
FORM f_build_header  CHANGING fc_header   TYPE treev_hhdr.
  fc_header-heading   = 'Material/Collector No./Vendor/RFQ No.'.
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
      cntl_system_error           = 1
      create_error                = 2
      failed                      = 3
      illegal_node_selection_mode = 4
      lifetime_error              = 5.

  CALL METHOD g_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = g_header
      i_save              = 'A'
      is_variant          = gs_variant
    CHANGING
      it_outtab           = gt_tree
      it_fieldcatalog     = gt_tree_fieldcat.
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

  PERFORM f_hierarchy_by_material.

*  PERFORM f_hierarchy_by_vendor.

  CALL METHOD g_tree->frontend_update.
ENDFORM.                    " F_CREATE_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NODE_MAIN
*&---------------------------------------------------------------------*
FORM f_add_node_main  USING    fu_aux        TYPE ty_tree
                               fu_relat_key  TYPE lvc_nkey
                               fu_node       TYPE lvc_value
                               fu_leaf fu_fieldname
                     CHANGING  fc_node_key   TYPE lvc_nkey.

  DATA : lv_node_text   TYPE lvc_value,
         lt_item_layout TYPE lvc_t_layi,
         ls_item_layout TYPE lvc_s_layi,
         ls_node_layout TYPE lvc_s_layn.

  CASE fu_leaf.
    WHEN '1'.
      ls_node_layout-n_image   = icon_customer.
  ENDCASE.

  ls_item_layout-fieldname = fu_fieldname.   "g_tree->c_hierarchy_column_name.
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
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'TREE' 'NODE_MAIN' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'MAIN' 'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'MAIN' 'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'MAIN' 'LOEKZ' '' '' '' '' '' '' 'LOEKZ' 'EKPO' '' '' '' '' '' '' ''
    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'MAIN' 'EKGRP' '' '' '' '' '' '' 'EKGRP' 'EKKO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAIN' 'MATNR' '' '' '' '' '' '' 'MATNR' 'EKPO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAIN' 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAIN' 'SUBMI' '' '' '' '' '' '' 'SUBMI' 'EKKO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAIN' 'EBELN' '' '' '' '' '' '' 'EBELN' 'EKKO' 'RFQ No.' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'MAIN' 'LIFNR' '' '' '' '' '' '' 'LIFNR' 'EKKO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'NAME1' '' '' '' '' '' '' 'NAME1' 'LFA1' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'BWBDT' '' '' '' '' '' '' 'BWBDT' 'EKKO' '1st Submission Date' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'ANGDT' '' '' '' '' '' '' 'ANGDT' 'EKKO' '2nd Submission Date' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'KDATB' '' '' '' '' '' '' 'KDATB' 'EKKO' 'Validity Start' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'KDATE' '' '' '' '' '' '' 'KDATE' 'EKKO' 'Validity End' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'BNDDT' '' '' '' '' '' '' 'BNDDT' 'EKKO' 'Binding Period' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAIN' 'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EKPO' 'Quantity' ''
    '' '' '' '' '' '' '' '' '' '',
    'MAIN' 'MEINS' '' '' '' '' '' '' 'MEINS' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'DETAIL' 'WERKS' '' '' '' '' '' '' 'WERKS' 'EKPO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'SUBMI' '' '' '' '' '' '' 'SUBMI' 'EKKO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'EBELN' '' '' '' '' '' '' 'EBELN' 'EKPO' 'RFQ No.' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'EBELP' '' '' '' '' '' '' 'EBELP' 'EKPO' 'RFQ Item' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'BANFN' '' '' '' '' '' '' 'BANFN' 'EKPO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'BNFPO' '' '' '' '' '' '' 'BNFPO' 'EKPO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'DETAIL' 'LFDAT' '' '' '' '' '' '' 'LFDAT' 'EBAN' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'DETAIL' 'MATNR' '' '' '' '' '' '' 'MATNR' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'DETAIL' 'TXZ01' '' '' '' '' '' '' 'TXZ01' 'EKPO' 'Description' '' '' '' ''
    '' '' '' '' '' '' '',
    'DETAIL' 'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EKPO' 'RFQ Quantity' ''
    '' '' '' '' '' '' '' '' '' '',
    'DETAIL' 'MEINS' '' '' '' '' '' '' 'MEINS' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_container fu_fieldname fu_tabname
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
  CASE fu_container.
    WHEN 'TREE'.
      APPEND ls_dyn_fcat TO gt_tree_fieldcat.
    WHEN 'MAIN'.
      APPEND ls_dyn_fcat TO gt_main_fieldcat.
    WHEN 'DETAIL'.
      APPEND ls_dyn_fcat TO gt_detail_fieldcat.
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
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.

ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.

ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh fu_container.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CASE fu_container.
      WHEN 'MAIN'.
        IF g_tabgrid01 IS NOT INITIAL.
          CALL METHOD g_tabgrid01->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.

      WHEN 'DETAIL'.
        IF g_tabgrid02 IS NOT INITIAL.
          IF gv_fieldname IS NOT INITIAL.
            PERFORM f_modify_detail_alvtitle.
            CALL METHOD g_tabgrid02->set_frontend_fieldcatalog
              EXPORTING
                it_fieldcatalog = gt_detail_fieldcat.
          ENDIF.

          CALL METHOD g_tabgrid02->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.

      WHEN 'TREE'.
        IF g_tree IS NOT INITIAL.
*          CALL METHOD g_tree->refresh_table_display
*            EXPORTING
*              is_stable = gs_stable.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout USING fu_container.
  CASE fu_container.
    WHEN 'MAIN'.
      gs_main_layout-s_dragdrop-row_ddid = g_handle_alv.
      gs_main_layout-cwidth_opt          = selected.
      gs_main_layout-stylefname          = 'STYLE'.
      gs_main_layout-ctab_fname          = 'COLOR'.
      gs_main_layout-zebra               = selected.
*  gs_main_layout-box_fname           = 'CHECK'.
*  gs_main_layout-no_rowmark          = selected.
*  gs_main_layout-totals_bef          = selected.
      gs_main_layout-no_toolbar          = selected.
    WHEN 'DETAIL'.
      gs_detail_layout-s_dragdrop-row_ddid = g_handle_alv.
      gs_detail_layout-cwidth_opt          = selected.
      gs_detail_layout-stylefname          = 'STYLE'.
      gs_detail_layout-ctab_fname          = 'COLOR'.
      gs_detail_layout-zebra               = selected.
*  gs_detail_layout-no_rowmark          = selected.
*  gs_detail_layout-box_fname           = 'CHECK'.
*  gs_detail_layout-totals_bef          = selected.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort USING fu_container.
  CASE fu_container.
    WHEN 'MAIN'.
      CLEAR gt_main_sort.
      PERFORM f_alv_sort TABLES gt_main_sort
                         USING : 1 'MATNR' 'X' '' '',
                                 2 'SUBMI' 'X' '' ''.
    WHEN 'DETAIL'.
      CLEAR gt_detail_sort.
      PERFORM f_alv_sort TABLES gt_detail_sort
                         USING : 1 'EBELN' 'X' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  TABLES   ft_sort   STRUCTURE lvc_s_sort
                 USING    fu_spos fu_fieldname
                          fu_up fu_down fu_subtot.

  ft_sort-spos      = fu_spos.
  ft_sort-fieldname = fu_fieldname.
  ft_sort-up        = fu_up.
  ft_sort-down      = fu_down.
  ft_sort-subtot    = fu_subtot.
  APPEND ft_sort.
  CLEAR ft_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_ALV
*&---------------------------------------------------------------------*
FORM f_detail_alv .
  CREATE OBJECT g_tabgrid02
    EXPORTING
      i_appl_events = selected
      i_parent      = g_contain02.

  PERFORM f_build_layout USING 'DETAIL'.
  PERFORM f_build_sort USING 'DETAIL'.

  SET HANDLER event_receiver->handle_double_click1
              event_receiver->handle_toolbar1
              event_receiver->handle_menu_button1
              event_receiver->handle_user_command1 FOR g_tabgrid02.

  CALL METHOD g_tabgrid02->set_table_for_first_display
    EXPORTING
      is_layout            = gs_detail_layout
      i_save               = 'A'
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gs_exclude1
    CHANGING
      it_sort              = gt_detail_sort[]
      it_outtab            = gt_out1[]
      it_fieldcatalog      = gt_detail_fieldcat[].
ENDFORM.                    " F_DETAIL_ALV

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data  USING    fu_value fu_fieldname.
  DATA : ls_ekko LIKE LINE OF gt_ekko,
         ls_ekpo LIKE LINE OF gt_ekpo,
         ls_eket LIKE LINE OF gt_eket.

  DATA : lv_lifnr TYPE ekko-lifnr,
         lv_submi TYPE ekko-submi,
         lv_ebeln TYPE ekko-ebeln.

  CLEAR : gt_out1[].

  CASE fu_fieldname.
    WHEN 'LIFNR'.
      lv_lifnr  = fu_value.
      LOOP AT gt_ekko INTO ls_ekko WHERE lifnr = lv_lifnr.
        IF ls_ekko-submi IS INITIAL.
          CONTINUE.
        ENDIF.
        LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
          LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                         AND ebelp = ls_ekpo-ebelp.
            PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

    WHEN 'SUBMI'.
      lv_submi  = fu_value.
      LOOP AT gt_ekko INTO ls_ekko WHERE submi = lv_submi.
        LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
          LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                         AND ebelp = ls_ekpo-ebelp.
            PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

    WHEN 'EBELN'.
      lv_ebeln  = fu_value.
      LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = lv_ebeln.
        LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                       AND ebelp = ls_ekpo-ebelp.
          PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DETAIL_ALVTITLE
*&---------------------------------------------------------------------*
FORM f_modify_detail_alvtitle .
  DATA : ls_title    TYPE ty_title,
         ls_dyn_fcat TYPE lvc_s_fcat.

  LOOP AT gt_detail_fieldcat INTO ls_dyn_fcat.
*    CASE gv_fieldname.
*      WHEN 'LIFNR'.
    PERFORM f_change_title USING ls_dyn_fcat-fieldname 'RFQ No.' 'RFQ Item'
                           CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                                    ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.
*      WHEN OTHERS.
*        PERFORM f_change_title USING ls_dyn_fcat-fieldname 'Purchasing Doc.' 'Item'
*                               CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
**                                        ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.
*    ENDCASE.

    MODIFY gt_detail_fieldcat FROM ls_dyn_fcat
                              TRANSPORTING reptext scrtext_l
                                           scrtext_m scrtext_s.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_DETAIL_ALVTITLE

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TITLE
*&----------------------------------------------------------------------*
FORM f_change_title  USING    fu_fieldname fu_t01 fu_t02
                     CHANGING fc_reptext fc_scrtext_l
                              fc_scrtext_m fc_scrtext_s.
  CASE fu_fieldname.
    WHEN 'EBELN'.
      PERFORM f_isi_judul USING fu_t01 '' '' ''
                          CHANGING fc_reptext fc_scrtext_l
                                   fc_scrtext_m fc_scrtext_s.
    WHEN 'EBELP'.
      PERFORM f_isi_judul USING fu_t02 '' '' ''
                          CHANGING fc_reptext fc_scrtext_l
                                   fc_scrtext_m fc_scrtext_s.
  ENDCASE.
ENDFORM.                    " F_CHANGE_TITLE

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_EKPO_OUT
*&---------------------------------------------------------------------*
FORM f_move_ekpo_out  USING    fs_ekko    TYPE ekko
                               fs_ekpo    TYPE ekpo
                               fs_eket    TYPE eket.
  DATA : ls_out1 LIKE LINE OF gt_out1,
         ls_eban LIKE LINE OF gt_eban.

  ls_out1-submi   = fs_ekko-submi.
  ls_out1-werks   = fs_ekpo-werks.
  ls_out1-ebeln   = fs_ekpo-ebeln.
  ls_out1-ebelp   = fs_ekpo-ebelp.
  ls_out1-banfn   = fs_eket-banfn.
  ls_out1-bnfpo   = fs_eket-bnfpo.
  CLEAR ls_eban.
  READ TABLE gt_eban INTO ls_eban
                     WITH KEY banfn = fs_eket-banfn
                              bnfpo = fs_eket-bnfpo.
  IF sy-subrc = 0.
    ls_out1-lfdat   = ls_eban-lfdat.
  ENDIF.
  ls_out1-matnr   = fs_ekpo-matnr.
  ls_out1-txz01   = fs_ekpo-txz01.
  ls_out1-menge   = fs_eket-menge.
  ls_out1-meins   = fs_ekpo-meins.
  APPEND ls_out1 TO gt_out1.
  CLEAR ls_out1.
ENDFORM.                    " F_MOVE_EKPO_OUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude           TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude1.
  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant.
  APPEND ls_exclude TO gs_exclude1.
  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_save_variant.  "&SAVE
  APPEND ls_exclude TO gs_exclude1.
  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant.  "&LOAD
  APPEND ls_exclude TO gs_exclude1.
  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude1.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_handle_toolbar USING fu_object fu_interactive.

ENDFORM.                    " F_HANDLE_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PROCESS
*&---------------------------------------------------------------------*
FORM f_prepare_process  TABLES   ft_out LIKE gt_out.
  CLEAR : gt_coll[].

  ft_out[]  = gt_out[].
  DELETE ft_out WHERE mark IS INITIAL.
ENDFORM.                    " F_PREPARE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_RELEASE_QUOTATION
*&---------------------------------------------------------------------*
FORM f_release_quotation  TABLES   ft_out LIKE gt_out.
  DATA : ls_out      TYPE ty_out,
         return      TYPE STANDARD TABLE OF bapireturn,
         ls_return   TYPE bapireturn,
         ls_bapiret2 TYPE bapiret2,
         lt_xout     TYPE STANDARD TABLE OF ty_out,
         ls_xout     TYPE ty_out.

  DATA : ls_coll            LIKE LINE OF gt_coll.

  DATA : ls_zhsmmmdt003     TYPE zhsmmmdt003.
  DATA : lt_zhsmmmdt003     TYPE STANDARD TABLE OF zhsmmmdt003.

  DATA : lv_status.
  CLEAR: lt_zhsmmmdt003[].
  lt_xout[] = ft_out[].
  SORT lt_xout BY ekgrp submi ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING ekgrp submi ebeln.

  LOOP AT lt_xout INTO ls_xout.
    CALL FUNCTION 'BAPI_PO_RELEASE'
      EXPORTING
        purchaseorder          = ls_xout-ebeln
        po_rel_code            = pa_frgco
      TABLES
        return                 = return
      EXCEPTIONS
        authority_check_fail   = 1
        document_not_found     = 2
        enqueue_fail           = 3
        prerequisite_fail      = 4
        release_already_posted = 5
        responsibility_fail    = 6
        OTHERS                 = 7.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      PERFORM f_prepare_mail_data USING ls_xout.
    ELSE.
      LOOP AT return INTO ls_return.
        CALL FUNCTION 'BALW_RETURN_TO_RET2'
          EXPORTING
            return_in = ls_return
          IMPORTING
            return_ou = ls_bapiret2.

        APPEND ls_bapiret2 TO gt_bapiret2.
        CLEAR ls_bapiret2.
      ENDLOOP.

      lv_status = 'X'.
    ENDIF.

    PERFORM f_modify_status USING lv_status
                            CHANGING ls_xout.

    MODIFY gt_out FROM ls_xout
                  TRANSPORTING mark icon style
                  WHERE submi = ls_xout-submi
                    AND ebeln = ls_xout-ebeln.

    "OTHERS                 = 5.
    ls_zhsmmmdt003-zproses =  'HSM_SENDRFQ'.
    ls_zhsmmmdt003-zdata = ls_xout-submi.
    ls_zhsmmmdt003-erdat = sy-datum.
    ls_zhsmmmdt003-ernam = sy-uname.
    ls_zhsmmmdt003-erzet = sy-uzeit.
    MODIFY zhsmmmdt003 FROM ls_zhsmmmdt003.
    APPEND ls_zhsmmmdt003 TO lt_zhsmmmdt003.
    CLEAR ls_xout.
  ENDLOOP.
  IF lt_zhsmmmdt003[] IS NOT INITIAL.
    COMMIT WORK AND WAIT.
    CALL FUNCTION 'ZBP_EVENT_RAISE'
      EXPORTING
        eventid                = 'EPROC_QUOT'
      EXCEPTIONS
        bad_eventid            = 1 " eventparm = gv_EVENTPARM
        eventid_does_not_exist = 2
        eventid_missing        = 3
        raise_failed           = 4.
  ENDIF.

  PERFORM f_alv_refresh USING 'X' 'MAIN'.
ENDFORM.                    " F_RELEASE_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_RELEASE_CANCEL_QUOTATION
*&---------------------------------------------------------------------*
FORM f_release_cancel_quotation  TABLES   ft_out LIKE gt_out.
  DATA : ls_out      TYPE ty_out,
         return      TYPE STANDARD TABLE OF bapireturn,
         ls_return   TYPE bapireturn,
         ls_bapiret2 TYPE bapiret2,
         lt_xout     TYPE STANDARD TABLE OF ty_out,
         ls_xout     TYPE ty_out.

  DATA : lv_status.

  lt_xout[] = ft_out[].
  SORT lt_xout BY ekgrp submi ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING ekgrp submi ebeln.

  LOOP AT lt_xout INTO ls_xout.
    CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
      EXPORTING
        purchaseorder            = ls_xout-ebeln
        po_rel_code              = pa_frgco
      TABLES
        return                   = return
      EXCEPTIONS
        authority_check_fail     = 1
        document_not_found       = 2
        enqueue_fail             = 3
        prerequisite_fail        = 4
        release_already_posted   = 5
        responsibility_fail      = 6
        no_release_already       = 7
        no_new_release_indicator = 8
        OTHERS                   = 9.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      PERFORM f_prepare_mail_data USING ls_xout.
    ELSE.
      LOOP AT return INTO ls_return.
        CALL FUNCTION 'BALW_RETURN_TO_RET2'
          EXPORTING
            return_in = ls_return
          IMPORTING
            return_ou = ls_bapiret2.

        APPEND ls_bapiret2 TO gt_bapiret2.
        CLEAR ls_bapiret2.
      ENDLOOP.

      lv_status = 'X'.
    ENDIF.

    PERFORM f_modify_status USING lv_status
                            CHANGING ls_xout.

    MODIFY gt_out FROM ls_xout
                  TRANSPORTING mark icon style
                  WHERE submi = ls_xout-submi
                    AND ebeln = ls_xout-ebeln.
    CLEAR ls_xout.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X' 'MAIN'.
ENDFORM.                    " F_RELEASE_CANCEL_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_STATUS
*&---------------------------------------------------------------------*
FORM f_modify_status  USING    fu_status
                      CHANGING fs_out   TYPE ty_out.
  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  CLEAR fs_out-mark.

  IF fu_status IS INITIAL.
    fs_out-icon   = icon_led_green.
    CLEAR lt_stylerow[].
    ls_stylerow-fieldname = 'MARK'.
    ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
    APPEND ls_stylerow TO lt_stylerow.
    CLEAR ls_stylerow.
    fs_out-style  = lt_stylerow.
  ELSE.
    fs_out-icon   = icon_led_red.
  ENDIF.
ENDFORM.                    " F_MODIFY_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_HIERARCHY_BY_VENDOR
*&---------------------------------------------------------------------*
FORM f_hierarchy_by_vendor .
  DATA : lt_xekko     TYPE STANDARD TABLE OF ekko,
         ls_xekko     LIKE LINE OF lt_xekko,
         lt_yekko     TYPE STANDARD TABLE OF ekko,
         ls_yekko     LIKE LINE OF lt_yekko,
         ls_ekko      LIKE LINE OF gt_ekko,
         ls_tree      LIKE LINE OF gt_tree,
         lv_key1      TYPE lvc_nkey,
         lv_key2      TYPE lvc_nkey,
         lv_key3      TYPE lvc_nkey,
         lv_key4      TYPE lvc_nkey,
         lv_node      TYPE lvc_value,
         lv_text(100),
         lv_empty.

  DATA : ls_lfa1        LIKE LINE OF gt_lfa1.

  lt_yekko[]   = gt_ekko[].
  SORT lt_yekko BY lifnr submi.
  DELETE ADJACENT DUPLICATES FROM lt_yekko COMPARING lifnr submi.
  lt_xekko[]   = lt_yekko[].
  SORT lt_xekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xekko COMPARING lifnr.
  DELETE lt_yekko WHERE submi IS INITIAL.

  CLEAR : lv_node, ls_tree.
  LOOP AT lt_xekko INTO ls_xekko.
    lv_node = ls_xekko-lifnr.
    READ TABLE gt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = ls_xekko-lifnr.
    ls_tree-node_main     = ls_lfa1-name1.

    CLEAR : ls_yekko, lv_empty.
    READ TABLE lt_yekko INTO ls_yekko
                        WITH KEY lifnr = ls_xekko-lifnr
                        TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      lv_empty  = '1'.
    ENDIF.

    PERFORM f_add_node_main USING    ls_tree '' lv_node lv_empty 'LIFNR'
                            CHANGING lv_key1.

    LOOP AT lt_yekko INTO ls_yekko WHERE lifnr = ls_xekko-lifnr.
      CLEAR : lv_node, ls_tree.
      IF ls_yekko-submi IS INITIAL.
        CONTINUE.
      ENDIF.
      lv_node = ls_yekko-submi.
*  ls_tree-node_main = lv_text.
      PERFORM f_add_node_main USING    ls_tree lv_key1 lv_node '' 'SUBMI'
                              CHANGING lv_key2.

      LOOP AT gt_ekko INTO ls_ekko WHERE lifnr = ls_yekko-lifnr
                                     AND submi = ls_yekko-submi.
        CLEAR : lv_node, ls_tree.
        lv_node = ls_ekko-ebeln.
*  ls_tree-node_main = lv_text.
        PERFORM f_add_node_main USING    ls_tree lv_key2 lv_node 'X' 'EBELN'
                                CHANGING lv_key3.

      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_HIERARCHY_BY_VENDOR

*&---------------------------------------------------------------------*
*&      Form  F_HIERARCHY_BY_MATERIAL
*&---------------------------------------------------------------------*
FORM f_hierarchy_by_material .
  DATA : lt_xout      TYPE STANDARD TABLE OF ty_out,
         ls_xout      LIKE LINE OF lt_xout,
         lt_yout      TYPE STANDARD TABLE OF ty_out,
         ls_yout      LIKE LINE OF lt_yout,
         lt_zout      TYPE STANDARD TABLE OF ty_out,
         ls_zout      LIKE LINE OF lt_zout,
         ls_out       LIKE LINE OF gt_out,
         ls_ekpo      LIKE LINE OF gt_ekpo,
         ls_tree      LIKE LINE OF gt_tree,
         lv_key1      TYPE lvc_nkey,
         lv_key2      TYPE lvc_nkey,
         lv_key3      TYPE lvc_nkey,
         lv_key4      TYPE lvc_nkey,
         lv_node      TYPE lvc_value,
         lv_text(100),
         lv_empty.

  DATA : ls_lfa1 LIKE LINE OF gt_lfa1,
         lt_makt TYPE STANDARD TABLE OF makt,
         ls_makt LIKE LINE OF lt_makt.

  lt_zout[]   = gt_data[].
  SORT lt_zout BY matnr submi lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_zout COMPARING matnr submi lifnr.
  lt_yout[]   = lt_zout[].
  SORT lt_yout BY matnr submi.
  DELETE ADJACENT DUPLICATES FROM lt_yout COMPARING matnr submi.
  lt_xout[]   = lt_yout[].
  SORT lt_xout BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING matnr.

  CLEAR : lv_node, ls_tree.
  LOOP AT lt_xout INTO ls_xout.
    lv_node = ls_xout-matnr.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_xout-matnr.
    IF sy-subrc = 0.
      ls_tree-node_main     = ls_makt-maktx.
    ENDIF.

    PERFORM f_add_node_main USING    ls_tree '' lv_node lv_empty 'MATNR'
                            CHANGING lv_key1.

    LOOP AT lt_yout INTO ls_yout WHERE matnr = ls_xout-matnr.
      CLEAR : lv_node, ls_tree.
      IF ls_yout-submi IS INITIAL.
        CONTINUE.
      ENDIF.
      lv_node = ls_yout-submi.
      PERFORM f_add_node_main USING    ls_tree lv_key1 lv_node '' 'SUBMI'
                              CHANGING lv_key2.

      LOOP AT lt_zout INTO ls_zout WHERE matnr = ls_yout-matnr
                                       AND submi = ls_yout-submi.
        CLEAR : lv_node, ls_tree.
        lv_node = ls_zout-lifnr.
        CLEAR ls_lfa1.
        READ TABLE gt_lfa1 INTO ls_lfa1
                           WITH KEY lifnr = ls_zout-lifnr.
        IF sy-subrc = 0.
          ls_tree-node_main     = ls_lfa1-name1.
        ENDIF.
        PERFORM f_add_node_main USING    ls_tree lv_key2 lv_node '' 'LIFNR'
                                CHANGING lv_key3.

        LOOP AT gt_data INTO ls_out WHERE matnr = ls_zout-matnr
                                      AND submi = ls_zout-submi
                                      AND lifnr = ls_zout-lifnr.
          CLEAR : lv_node, ls_tree.
          lv_node = ls_out-ebeln.
          PERFORM f_add_node_main USING    ls_tree lv_key3 lv_node 'X' 'EBELN'
                                  CHANGING lv_key4.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_HIERARCHY_BY_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_CALL_ME42
*&---------------------------------------------------------------------*
FORM f_call_me42  USING    fu_value fu_fieldname fu_node_key.
  DATA : lv_ebeln   TYPE ekko-ebeln.

  CASE fu_fieldname.
    WHEN 'EBELN'.
      PERFORM f_conversion_exit_alpha USING fu_value
                                      CHANGING lv_ebeln.
      SET PARAMETER ID 'ANF' FIELD lv_ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.

      PERFORM f_refresh_data USING lv_ebeln fu_node_key.
  ENDCASE.
ENDFORM.                    " F_CALL_ME42

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_exit_alpha  USING    fu_value
                              CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_CONVERSION_EXIT_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out  LIKE LINE OF gt_out,
         ls_ekko LIKE LINE OF gt_ekko,
         ls_ekpo LIKE LINE OF gt_ekpo,
         ls_eket LIKE LINE OF gt_eket,
         ls_05   LIKE LINE OF gt_05.

  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout.

  DATA : lv_mess(100),
         lv_msgv1	    TYPE symsgv,
         lv_msgv2	    TYPE symsgv,
         lv_msgv3	    TYPE symsgv,
         lv_msgv4	    TYPE symsgv,
         lv_xbwbdt,
         lv_xangdt,
         lv_xkdatb,
         lv_xkdate,
         lv_xbnddt,
         lv_bwbdt(10),
         lv_angdt(10),
         lv_kdatb(10),
         lv_kdate(10),
         lv_bnddt(10).

  CLEAR : gt_out1[].

  CASE fu_column.
    WHEN 'SUBMI'.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        LOOP AT gt_ekko INTO ls_ekko WHERE submi = ls_out-submi.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
            LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                           AND ebelp = ls_ekpo-ebelp.
              PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
            ENDLOOP.
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      PERFORM f_alv_refresh USING 'X' 'DETAIL'.

    WHEN 'EBELN'.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        LOOP AT gt_ekko INTO ls_ekko WHERE ebeln = ls_out-ebeln.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
            LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                           AND ebelp = ls_ekpo-ebelp.
              PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
            ENDLOOP.
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      PERFORM f_alv_refresh USING 'X' 'DETAIL'.

    WHEN 'MENGE'.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        LOOP AT gt_ekko INTO ls_ekko WHERE submi = ls_out-submi
                                       AND lifnr = ls_out-lifnr.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
            CLEAR ls_eket.
            READ TABLE gt_eket INTO ls_eket
                               WITH KEY ebeln = ls_ekpo-ebeln
                                        ebelp = ls_ekpo-ebelp.
            PERFORM f_move_ekpo_out USING ls_ekko ls_ekpo ls_eket.
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      PERFORM f_alv_refresh USING 'X' 'DETAIL'.

    WHEN 'BWBDT' OR 'ANGDT' OR 'KDATB' OR 'KDATE' OR 'BNDDT'.
      CASE 'X'.
        WHEN radio1.
          READ TABLE gt_05 INTO ls_05
                           WITH KEY frgco = pa_frgco
                                    srno1 = 1.
          IF sy-subrc = 0.
            CLEAR : lv_mess, lv_msgv1, lv_msgv2, lv_msgv3, lv_msgv4.

            READ TABLE gt_out INTO ls_out INDEX fu_row.
            IF sy-subrc = 0.
              lt_xout[] = gt_out[].
              DELETE lt_xout WHERE submi <> ls_out-submi.
              pa_aedat    = ls_out-aedat.
              pa_bwbdt    = ls_out-bwbdt.
              pa_angdt    = ls_out-angdt.
              pa_kdatb    = ls_out-kdatb.
              pa_kdate    = ls_out-kdate.
              pa_bnddt    = ls_out-bnddt.

              CALL SELECTION-SCREEN 102 STARTING AT 10 10.

              IF sy-subrc = 0.
                IF pa_bwbdt <> ls_out-bwbdt.
                  lv_xbwbdt  = 'X'.
                ENDIF.
                IF pa_angdt <> ls_out-angdt.
                  lv_xangdt  = 'X'.
                ENDIF.
                IF pa_kdatb <> ls_out-kdatb.
                  lv_xkdatb  = 'X'.
                ENDIF.
                IF pa_kdate <> ls_out-kdate.
                  lv_xkdate  = 'X'.
                ENDIF.
                IF pa_bnddt <> ls_out-bnddt.
                  lv_xbnddt  = 'X'.
                ENDIF.
                ls_out-bwbdt    = pa_bwbdt.
                ls_out-angdt    = pa_angdt.
                ls_out-kdatb    = pa_kdatb.
                ls_out-kdate    = pa_kdate.
                ls_out-bnddt    = pa_bnddt.

                PERFORM f_date_validate USING pa_aedat pa_bwbdt pa_angdt pa_kdatb
                                              pa_kdate pa_bnddt ls_out-submi
                                              lv_xbwbdt lv_xangdt lv_xkdatb
                                              lv_xkdate lv_xbnddt
                                        CHANGING lv_mess lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                IF lv_mess IS INITIAL.
                  MODIFY gt_out FROM ls_out
                  TRANSPORTING bwbdt angdt kdatb kdate bnddt
                  WHERE submi = ls_out-submi.
                  PERFORM f_date_modify USING pa_bwbdt pa_angdt pa_kdatb
                                              pa_kdate pa_bnddt
                                        CHANGING lv_bwbdt lv_angdt lv_kdatb
                                                 lv_kdate lv_bnddt.
                  LOOP AT lt_xout INTO ls_xout.
                    PERFORM f_modify_me42 USING ls_xout-ebeln lv_bwbdt lv_angdt lv_kdatb
                                                lv_kdate lv_bnddt.
                  ENDLOOP.

                  PERFORM f_alv_refresh USING 'X' 'MAIN'.
                ELSE.
                  MESSAGE i000(zab) WITH lv_mess DISPLAY LIKE 'E'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_DATA
*&---------------------------------------------------------------------*
FORM f_refresh_data  USING    fu_ebeln fu_node_key.
  DATA : lt_xekpo TYPE STANDARD TABLE OF ekpo,
         ls_xekpo LIKE LINE OF lt_xekpo.

  DATA : lt_selected_node TYPE lvc_t_nkey.
  DATA : ls_selected_node TYPE lvc_nkey.

  COMMIT WORK AND WAIT.

  CALL METHOD g_tree->frontend_update.

  SELECT *
    FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE lt_xekpo
    WHERE ebeln = fu_ebeln.

  LOOP AT lt_xekpo INTO ls_xekpo.
    IF ls_xekpo-loekz IS NOT INITIAL.
      DELETE gt_out WHERE ebeln = ls_xekpo-ebeln
                      AND ebelp = ls_xekpo-ebelp.
      CALL METHOD g_tree->delete_subtree
        EXPORTING
          i_node_key                = fu_node_key
          i_update_parents_expander = ''
          i_update_parents_folder   = 'X'.
    ENDIF.
  ENDLOOP.

  CALL METHOD g_tree->frontend_update.

  PERFORM f_alv_refresh USING 'X' 'MAIN'.
  CLEAR gt_out1[].
  PERFORM f_alv_refresh USING 'X' 'DETAIL'.
ENDFORM.                    " F_REFRESH_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REJECT_QUOTATION
*&---------------------------------------------------------------------*
FORM f_reject_quotation  TABLES   ft_out LIKE gt_out.
  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   TYPE ty_out,
         ls_out1   LIKE LINE OF gt_out1,
         ls_ekpo   LIKE LINE OF gt_ekpo,
         ls_bdcmsg LIKE LINE OF t_bdcmsg.

  DATA : lv_mode,
         lv_update,
         lv_tabix(2) TYPE n,
         dynfval     TYPE bdc_fval.

  lv_mode   = 'N'.
  lv_update = 'S'.

  lt_xout[] = ft_out[].
  SORT lt_xout BY ekgrp submi ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING ekgrp submi ebeln.

  LOOP AT lt_xout INTO ls_xout.
    CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'          '0305',
         ' '  'BDC_OKCODE'        '/00',
         ' '  'RM06E-ANFNR'       ls_xout-ebeln.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'          '0301',
         ' '  'BDC_OKCODE'        '=AB'.

    READ TABLE gt_ekpo INTO ls_ekpo
                       WITH KEY ebeln = ls_xout-ebeln
                                ebelp = ls_xout-ebelp.
    IF sy-subrc = 0.
      lv_tabix  = sy-tabix.
    ENDIF.

    CONCATENATE 'RM06E-ANFPS(' lv_tabix ')' INTO dynfval.
    CONDENSE dynfval NO-GAPS.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'              '0320',
         ' '  'BDC_OKCODE'            '=MALL'.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'              '0320',
         ' '  'BDC_OKCODE'            '=DL'.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'          '0320',
         ' '  'BDC_CURSOR'        dynfval,
         ' '  'BDC_OKCODE'        '=BU'.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPLSPO1'          '0300',
         ' '  'BDC_OKCODE'        '=YES'.

    CALL TRANSACTION 'ME42' USING t_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg INTO ls_bdcmsg
                    WITH KEY msgtyp = 'E'.
    IF sy-subrc <> 0.
      PERFORM f_prepare_mail_data USING ls_xout.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_REJECT_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_REJECT_CANCEL_QUOTATION
*&---------------------------------------------------------------------*
FORM f_reject_cancel_quotation  TABLES   ft_out LIKE gt_out.
  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   TYPE ty_out,
         ls_out1   LIKE LINE OF gt_out1,
         ls_ekpo   LIKE LINE OF gt_ekpo,
         ls_bdcmsg LIKE LINE OF t_bdcmsg.

  DATA : lv_mode,
         lv_update,
         lv_tabix(2) TYPE n,
         dynfval     TYPE bdc_fval.

  lv_mode   = 'N'.
  lv_update = 'S'.

  lt_xout[] = ft_out[].
  SORT lt_xout BY ekgrp submi ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING ekgrp submi ebeln.

  LOOP AT lt_xout INTO ls_xout.
    CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'          '0305',
         ' '  'BDC_OKCODE'        '/00',
         ' '  'RM06E-ANFNR'       ls_xout-ebeln.
    "remarks by IRG, salah line karena gt_ekpo ada banyak data
    lv_tabix = ls_xout-ebelp.
**    READ TABLE gt_ekpo INTO ls_ekpo
**                       WITH KEY ebeln = ls_xout-ebeln
**                                ebelp = ls_xout-ebelp.
**    IF sy-subrc = 0.
**      lv_tabix  = sy-tabix.
**    ENDIF.

    CONCATENATE 'RM06E-ANFPS(' lv_tabix ')' INTO dynfval.
    CONDENSE dynfval NO-GAPS.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'              '0320',
         ' '  'BDC_CURSOR'            dynfval,
         ' '  'BDC_OKCODE'            '=ES',
         ' '  'RM06E-TCSELFLAG(01)'   'X'.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMM06E'          '0320',
         ' '  'BDC_CURSOR'        dynfval,
         ' '  'BDC_OKCODE'        '=BU'.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPLSPO1'          '0300',
         ' '  'BDC_OKCODE'        '=YES'.

    CALL TRANSACTION 'ME42' USING t_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg INTO ls_bdcmsg
                    WITH KEY msgtyp = 'E'.
    IF sy-subrc <> 0.
      PERFORM f_prepare_mail_data USING ls_xout.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_REJECT_CANCEL_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL
*&---------------------------------------------------------------------*
FORM f_send_email USING    fu_subject fu_name fu_bgcolor.
  DATA : lo_send_request TYPE REF TO cl_bcs,
         lt_message_body TYPE bcsy_text,
         lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service,
         lo_document     TYPE REF TO cl_document_bcs,
         lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

  DATA : lv_subject TYPE so_obj_des,
         lv_status  TYPE bcs_rqst,
         lv_frgct   TYPE zhsmmmdt005-frgct.

  DATA : lt_to    TYPE STANDARD TABLE OF ty_email,
         ls_to    LIKE LINE OF lt_to,
         lt_cc    TYPE STANDARD TABLE OF ty_email,
         ls_cc    LIKE LINE OF lt_cc,
         lt_xcoll TYPE STANDARD TABLE OF ty_coll,
         ls_xcoll LIKE LINE OF lt_xcoll.

  lo_send_request = cl_bcs=>create_persistent( ).

  CASE fu_subject.
    WHEN '1'.
      lv_subject = 'Approval Collective No. (No Reply)'.
    WHEN '2'.
      lv_subject = 'Reject Collective No. (No Reply)'.
    WHEN '3'.
      lv_subject = 'Approval Collective No. (No Reply)'.
    WHEN '4'.
      lv_subject = 'Reject Collective No. (No Reply)'.
  ENDCASE.

  lt_xcoll[] = gt_coll[].
  SORT lt_xcoll BY ekgrp.
  DELETE ADJACENT DUPLICATES FROM lt_xcoll COMPARING ekgrp.

  LOOP AT lt_xcoll INTO ls_xcoll.
    PERFORM f_get_email TABLES lt_to
                        USING ls_xcoll-ekgrp
                        CHANGING lv_frgct.

    CLEAR : lt_message_body[].
    PERFORM f_create_body TABLES lt_message_body
                          USING fu_name fu_bgcolor lv_frgct ls_xcoll-ekgrp.

    CREATE OBJECT lo_mime_helper.
    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_message_body.

    lo_document = cl_document_bcs=>create_from_multirelated(
    i_subject          = lv_subject
    i_importance       = '9'
    i_multirel_service = lo_mime_helper ).

    lo_send_request->set_document( lo_document ).

    CLEAR lo_recipient.

    IF lt_to[] IS NOT INITIAL.
      LOOP AT lt_to INTO ls_to.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = ls_to-email ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient ).
      ENDLOOP.
    ENDIF.

    IF lt_cc[] IS NOT INITIAL.
      LOOP AT lt_cc INTO ls_cc.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = ls_cc-email ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient
                                        i_copy       = 'X').
      ENDLOOP.
    ENDIF.

    lv_status = 'N'.
    CALL METHOD lo_send_request->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.

    TRY.
        lo_send_request->send( ).
        COMMIT WORK.
      CATCH cx_bcs.
        ROLLBACK WORK.
    ENDTRY.
  ENDLOOP.
ENDFORM.                    " F_SEND_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BODY
*&---------------------------------------------------------------------*
FORM f_create_body  TABLES   ft_body STRUCTURE soli
                    USING    fu_name fu_bgcolor fc_frgct fu_ekgrp.

  TYPES : BEGIN OF ty_relcd,
            frgco TYPE t16fd-frgco,
          END OF ty_relcd.

  DATA : lv_name  TYPE thead-tdname,
         lines    TYPE STANDARD TABLE OF tline,
         ls_line  LIKE LINE OF lines,
         lv_line  TYPE i,
         lv_code  TYPE string,
         lv_count TYPE i.

  DATA : lt_relcd TYPE STANDARD TABLE OF ty_relcd,
         ls_relcd LIKE LINE OF lt_relcd.

  DATA : ls_fcat  TYPE lvc_s_fcat,
         lt_body  TYPE bcsy_text,
         ls_body  TYPE soli,
         lt_space TYPE STANDARD TABLE OF string.

  DATA : lt_fields    TYPE STANDARD TABLE OF w3fields.

  lv_name = fu_name.

  SHIFT lv_code LEFT DELETING LEADING space.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = lv_name
      object                  = 'TEXT'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  LOOP AT lines INTO ls_line.
    REPLACE ALL OCCURRENCES OF REGEX '&RELEASECODE&'
    IN ls_line-tdline
    WITH fc_frgct.

    IF ls_line-tdformat IS INITIAL.
      DESCRIBE TABLE lt_body LINES lv_line.
      READ TABLE lt_body INTO ls_body INDEX lv_line.
      CONCATENATE ls_body ls_line-tdline INTO ls_body
      SEPARATED BY space.
      MODIFY lt_body FROM ls_body INDEX lv_line.
    ELSE.
      APPEND ls_line-tdline TO lt_body.
    ENDIF.
  ENDLOOP.

  CLEAR : ft_body[], lv_line, gt_fcat[].
  PERFORM f_create_mail_fieldcat USING : 'Collective No.',
                                         'Create by'.
  IF gt_fcat[] IS NOT INITIAL.
    PERFORM f_create_mail_table TABLES gt_fcat
                                USING fu_bgcolor fu_ekgrp.
  ENDIF.

  LOOP AT lt_body INTO ls_body FROM 1 TO 4.
    IF ls_body-line IS INITIAL.
      ls_body-line = '<br />'.
    ENDIF.
    APPEND ls_body TO ft_body.
    CLEAR ls_body.
  ENDLOOP.

  IF gt_html[] IS NOT INITIAL.
    DO 2 TIMES.
      ls_body-line = '<br />'.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDDO.

    LOOP AT gt_html INTO ls_body.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.

    DO 2 TIMES.
      ls_body-line = '<br />'.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDDO.
  ENDIF.

  LOOP AT lt_body INTO ls_body FROM 5.
    IF ls_body-line IS INITIAL.
      ls_body-line = '<br />'.
    ELSE.
      CONCATENATE ls_body-line '<br />' INTO ls_body-line
      SEPARATED BY space.
    ENDIF.
    APPEND ls_body TO ft_body.
    CLEAR ls_body.
  ENDLOOP.
ENDFORM.                    " F_CREATE_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_create_mail_fieldcat  USING    fu_coltext.
  DATA : ls_fcat      TYPE lvc_s_fcat.

  ls_fcat-coltext = fu_coltext.
  APPEND ls_fcat TO gt_fcat.
ENDFORM.                    " F_CREATE_MAIL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_TABLE
*&---------------------------------------------------------------------*
FORM f_create_mail_table  TABLES   ft_fcat  TYPE lvc_t_fcat
                          USING    fu_bgcolor fu_ekgrp.
  TYPES : BEGIN OF ty_xcoll,
            submi TYPE ekko-submi,
            ernam TYPE ekko-ernam,
          END OF ty_xcoll.

  DATA : lv_text   TYPE w3head-text,
         lt_header TYPE STANDARD TABLE OF w3head,
         lt_fields TYPE STANDARD TABLE OF w3fields,
         lt_coll   TYPE STANDARD TABLE OF ty_coll,
         lt_xcoll  TYPE STANDARD TABLE OF ty_xcoll.

  DATA : ls_fcat  TYPE lvc_s_fcat,
         ls_coll  LIKE LINE OF lt_coll,
         ls_xcoll LIKE LINE OF lt_xcoll.

  LOOP AT ft_fcat INTO ls_fcat.
    lv_text = ls_fcat-coltext.
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        field_nr = sy-tabix
        text     = lv_text
        fgcolor  = 'black'
        bgcolor  = fu_bgcolor
      TABLES
        header   = lt_header.

    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        field_nr = sy-tabix
        fgcolor  = 'black'
        size     = '3'
      TABLES
        fields   = lt_fields.
  ENDLOOP.

  lt_coll[] = gt_coll[].
  SORT lt_coll BY submi.
  DELETE ADJACENT DUPLICATES FROM lt_coll COMPARING submi.
  LOOP AT lt_coll INTO ls_coll WHERE ekgrp = fu_ekgrp.
    MOVE-CORRESPONDING ls_coll TO ls_xcoll.
    APPEND ls_xcoll TO lt_xcoll.
    CLEAR ls_xcoll.
  ENDLOOP.

  CLEAR gt_html[].
  IF lt_xcoll[] IS NOT INITIAL.
    CALL FUNCTION 'WWW_ITAB_TO_HTML'
      TABLES
        html       = gt_html
        fields     = lt_fields
        row_header = lt_header
        itable     = lt_xcoll.
  ENDIF.
ENDFORM.                    " F_CREATE_MAIL_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_MAIL_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_mail_data  USING    fs_out   TYPE ty_out.
  DATA : ls_coll    LIKE LINE OF gt_coll.

  ls_coll-ekgrp   = fs_out-ekgrp.
  ls_coll-submi   = fs_out-submi.
  ls_coll-ernam   = fs_out-ernam.
  APPEND ls_coll TO gt_coll.
ENDFORM.                    " F_PREPARE_MAIL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_EMAIL
*&---------------------------------------------------------------------*
FORM f_get_email  TABLES   ft_to TYPE STANDARD TABLE
                  USING    fu_ekgrp
                  CHANGING fc_frgct.
  DATA : lt_x05   TYPE STANDARD TABLE OF zhsmmmdt005,
         ls_x05   LIKE LINE OF lt_x05,
         ls_05    LIKE LINE OF gt_05,
         ls_email TYPE ty_email.

  DATA : lv_ekgrp TYPE zhsmmmdt005-ekgrp,
         lv_srno1 TYPE zhsmmmdt005-srno1.

  READ TABLE gt_05 INTO ls_05
                   WITH KEY ekgrp = fu_ekgrp
                            frgco = pa_frgco.
  IF sy-subrc = 0.
    lv_srno1  = ls_05-srno1.
    lv_ekgrp  = ls_05-ekgrp.
    fc_frgct  = ls_05-frgct.
    LOOP AT gt_05 INTO ls_05 WHERE ekgrp = lv_ekgrp.
      ls_x05  = ls_05.
      APPEND ls_x05 TO lt_x05.
      CLEAR ls_x05.
    ENDLOOP.
    SORT lt_x05 BY srno1 DESCENDING.
    READ TABLE lt_x05 INTO ls_x05 INDEX 1.

    IF lv_srno1 = ls_x05-srno1.
      CLEAR ls_05.
      LOOP AT gt_05 INTO ls_05 WHERE ekgrp = lv_ekgrp
                                 AND srno1 = 0
                                 AND zto   = 'X'.
        ls_email-email   = ls_05-smtp_addr.
        APPEND ls_email TO ft_to.
        CLEAR ls_email.
      ENDLOOP.
    ELSE.
      lv_srno1 = lv_srno1 + 1.
      CLEAR ls_05.
      LOOP AT gt_05 INTO ls_05 WHERE ekgrp = lv_ekgrp
                                 AND srno1 = lv_srno1
                                 AND zto   = 'X'.
        ls_email-email   = ls_05-smtp_addr.
        APPEND ls_email TO ft_to.
        CLEAR ls_email.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_DATE_VALIDATE
*&---------------------------------------------------------------------*
FORM f_date_validate  USING    fu_aedat fu_bwbdt fu_angdt fu_kdatb
                               fu_kdate fu_bnddt fu_submi fu_xbwbdt
                               fu_xangdt fu_xkdatb fu_xkdate fu_xbnddt
                      CHANGING fc_mess fc_msgv1 fc_msgv2 fc_msgv3 fc_msgv4.
  TYPES : BEGIN OF ty_delv,
            lfdat TYPE eban-lfdat,
          END OF ty_delv.

  DATA : ls_ekko LIKE LINE OF gt_ekko,
         ls_ekpo LIKE LINE OF gt_ekpo,
         ls_eket LIKE LINE OF gt_eket,
         lt_delv TYPE STANDARD TABLE OF ty_delv,
         ls_delv LIKE LINE OF lt_delv,
         ls_eban LIKE LINE OF gt_eban.

  DATA : lr_datum TYPE RANGE OF datum,
         ls_datum LIKE LINE OF lr_datum.

  LOOP AT gt_ekko INTO ls_ekko WHERE submi = fu_submi.
    LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
      LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                     AND ebelp = ls_ekpo-ebelp.
        READ TABLE gt_eban INTO ls_eban
                           WITH KEY banfn = ls_eket-banfn
                                    bnfpo = ls_eket-bnfpo.
        IF sy-subrc = 0.
          ls_delv-lfdat   = ls_eban-lfdat.
          APPEND ls_delv TO lt_delv.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  CLEAR ls_datum.
  ls_datum-low    = fu_kdatb.
  ls_datum-high   = fu_kdate.
  ls_datum-sign   = 'E'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.
  CLEAR ls_datum.

  SORT lt_delv BY lfdat DESCENDING.
  READ TABLE lt_delv INTO ls_delv INDEX 1.

  IF fu_xbwbdt IS NOT INITIAL.
    IF fu_bwbdt < fu_aedat.
      fc_mess   =  '1st Submission Date must greather than RFQ Date'.
    ENDIF.
  ENDIF.

  IF fu_xangdt IS NOT INITIAL.
    IF fu_angdt < fu_aedat.
      fc_mess   = '2st Submission Date must greather than RFQ Date'.
    ELSEIF fu_angdt < fu_bwbdt.
      fc_mess   = '2st Submission Date must greather than 1st Submission Date'.
    ELSEIF fu_angdt > fu_kdate.
      fc_mess   = '2st Submission Date must less than Validity End'.
    ENDIF.
  ENDIF.

  IF fu_xkdatb IS NOT INITIAL.
    IF fu_kdatb < fu_aedat.
      fc_mess   = 'Validity Start must greather than RFQ Date'.
    ELSEIF fu_kdatb > fu_kdate.
      fc_mess   = 'Validity Start must less than Validity End'.
    ELSEIF fu_kdatb > fu_bwbdt.
      fc_mess   = 'Validity Start must less than 1st Submission'.
    ENDIF.
  ENDIF.

  IF fu_xkdate IS NOT INITIAL.
    IF fu_kdate < fu_aedat.
      fc_mess   = 'Validity End must greather than RFQ Date'.
    ELSEIF fu_kdate < fu_angdt.
      fc_mess   = 'Validity End must greather than 2nd Submission Date'.
    ELSEIF fu_kdate < fu_bwbdt.
      fc_mess   = 'Validity End must greather than 1st Submission Date'.
    ENDIF.
  ENDIF.

  IF fu_xkdatb IS NOT INITIAL OR
    fu_xkdate IS NOT INITIAL.
    IF fu_kdate < fu_kdatb.
      fc_mess   = 'Validity End must greather than Validity Start'.
    ENDIF.
  ENDIF.

  IF fu_xkdate IS NOT INITIAL.
    IF fu_kdate > ls_delv-lfdat.
      fc_mess   = 'Validity End must Less than or Equal Delv.Date'.
    ENDIF.
  ENDIF.

  IF fu_xbwbdt IS NOT INITIAL.
    IF fu_bwbdt IN lr_datum.
      fc_mess   = '1st Submission Date must between Validity Start & End'.
    ENDIF.
  ENDIF.

  IF fu_xangdt IS NOT INITIAL OR
    fu_xbwbdt IS NOT INITIAL.
    IF fu_angdt < fu_bwbdt.
      fc_mess   = '2nd Submission Date must greater than 1st Submission Date'.
    ENDIF.
  ENDIF.

  IF fu_xangdt IS NOT INITIAL.
    IF fu_angdt IN lr_datum.
      fc_mess   = '2nd Submission Date must between Validity Start & End'.
    ENDIF.
  ENDIF.

  IF fu_xkdate IS NOT INITIAL OR
    fu_xbnddt IS NOT INITIAL.
    IF fu_bnddt < fu_kdate.
      fc_mess   = 'Binding date must greather than Validity End'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DATE_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ME42
*&---------------------------------------------------------------------*
FORM f_modify_me42  USING    fu_ebeln fu_bwbdt fu_angdt fu_kdatb fu_kdate
                             fu_bnddt.
  DATA : lv_mode,
         lv_update,
         dynfval   TYPE bdc_fval,
         ls_bdcmsg LIKE LINE OF t_bdcmsg.

  lv_mode   = 'N'.
  lv_update = 'S'.

  CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.
  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMM06E'          '0305',
       ' '  'BDC_OKCODE'        '=KOPF',
       ' '  'RM06E-ANFNR'       fu_ebeln.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMM06E'          '0301',
       ' '  'BDC_OKCODE'        '=BU',
       ' '  'EKKO-ANGDT'        fu_angdt,
       ' '  'EKKO-KDATB'        fu_kdatb,
       ' '  'EKKO-KDATE'        fu_kdate,
       ' '  'EKKO-BWBDT'        fu_bwbdt,
       ' '  'EKKO-BNDDT'        fu_bnddt.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPLSPO1'          '0300',
       ' '  'BDC_OKCODE'        '=YES'.

  CALL TRANSACTION 'ME42' USING t_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg INTO ls_bdcmsg
                  WITH KEY msgtyp = 'E'.

ENDFORM.                    " F_MODIFY_ME42

*&---------------------------------------------------------------------*
*&      Form  F_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_date_modify  USING    fu_bwbdt fu_angdt fu_kdatb fu_kdate fu_bnddt
                    CHANGING fc_bwbdt fc_angdt fc_kdatb fc_kdate fc_bnddt.

  WRITE fu_bwbdt TO fc_bwbdt DD/MM/YYYY.
  WRITE fu_angdt TO fc_angdt DD/MM/YYYY.
  WRITE fu_kdatb TO fc_kdatb DD/MM/YYYY.
  WRITE fu_kdate TO fc_kdate DD/MM/YYYY.
  WRITE fu_bnddt TO fc_bnddt DD/MM/YYYY.
ENDFORM.                    " F_DATE_MODIFY
