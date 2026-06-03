*&---------------------------------------------------------------------*
*&  Include           ZCO_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT SINGLE waers
    FROM tka01
    INTO gv_waers
    WHERE kokrs = '8010'.

  IF gv_datbi IS INITIAL.
    CONCATENATE pa_gjahr pa_perio+1(2) '01' INTO gv_datbi.
  ENDIF.
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
*  PERFORM f_error_message USING '' ''.
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
  DATA: ls_csks LIKE LINE OF gt_csks,
        lt_csks TYPE STANDARD TABLE OF csks.

  FIELD-SYMBOLS: <fs_csks> TYPE csks.

  IF gt_csks[] IS INITIAL.
    SELECT *
      FROM csks
      INTO CORRESPONDING FIELDS OF TABLE gt_csks
      WHERE kokrs = '8010'
        AND bukrs = pa_bukrs
        AND gsber = pa_gsber
        AND khinr = pa_khinr
        AND datbi >= gv_datbi.
  ELSE.
    SORT gt_csks BY khinr.
    DELETE gt_csks WHERE khinr <> pa_khinr.
  ENDIF.

  IF gt_csks[] IS NOT INITIAL.
    LOOP AT gt_csks INTO ls_csks.
      APPEND INITIAL LINE TO lt_csks ASSIGNING <fs_csks>.
      MOVE-CORRESPONDING ls_csks TO <fs_csks>.

      UNASSIGN <fs_csks>.
      APPEND INITIAL LINE TO lt_csks ASSIGNING <fs_csks>.
      MOVE-CORRESPONDING ls_csks TO <fs_csks>.
      <fs_csks>-objnr+1(1) = 'L'.
      CONCATENATE <fs_csks>-objnr 'LABOR' INTO <fs_csks>-objnr.

      UNASSIGN <fs_csks>.
      APPEND INITIAL LINE TO lt_csks ASSIGNING <fs_csks>.
      MOVE-CORRESPONDING ls_csks TO <fs_csks>.
      <fs_csks>-objnr+1(1) = 'L'.
      CASE pa_bukrs.
        WHEN '8190'.
          CONCATENATE <fs_csks>-objnr 'MACH' INTO <fs_csks>-objnr.
        WHEN OTHERS.
          CONCATENATE <fs_csks>-objnr 'NONLBR' INTO <fs_csks>-objnr.
      ENDCASE.
    ENDLOOP.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_coep
      FROM coep FOR ALL ENTRIES IN lt_csks
      WHERE kokrs = '8010'
        AND bukrs = pa_bukrs
        AND gsber = pa_gsber
        AND perio = pa_perio
        AND gjahr = pa_gjahr
        AND objnr = lt_csks-objnr.

    SELECT *
      FROM cskt
      INTO CORRESPONDING FIELDS OF TABLE gt_cskt
      FOR ALL ENTRIES IN gt_csks
      WHERE spras = sy-langu
        AND kokrs = '8010'
        AND kostl = gt_csks-kostl
        AND datbi >= gv_datbi.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_csks LIKE LINE OF gt_csks,
         ls_coep LIKE LINE OF gt_coep,
         ls_cskt LIKE LINE OF gt_cskt,
         ls_out  LIKE LINE OF gt_out.

  SORT gt_csks BY kostl.
  SORT gt_coep BY objnr.

  LOOP AT gt_csks INTO ls_csks.
    LOOP AT gt_coep INTO ls_coep.
      IF ls_coep-objnr+6(10) = ls_csks-kostl.
        ADD ls_coep-wkgbtr  TO ls_out-wkgbtr.
      ENDIF.
    ENDLOOP.
    CLEAR ls_cskt.
    READ TABLE gt_cskt INTO ls_cskt
                       WITH KEY kostl = ls_csks-kostl.
    IF sy-subrc = 0.
      ls_out-ktext    = ls_cskt-ktext.
    ENDIF.
    ls_out-bukrs    = pa_bukrs.
    ls_out-gsber    = pa_gsber.
    ls_out-perio    = pa_perio.
    ls_out-gjahr    = pa_gjahr.
    ls_out-kostl    = ls_csks-kostl.
    ls_out-waers    = gv_waers.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ENDIF.
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
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynerrlog-icon_id      = icon_error_protocol.
    dynerrlog-icon_text    = 'Error Log'.
    dynerrlog-text         = 'Error Log'.
  ELSE.
    dynerrlog-icon_id      = icon_protocol.
    dynerrlog-icon_text    = 'Error Log'.
    dynerrlog-text         = 'Error Log'.
  ENDIF.

  IF gv_simulate IS INITIAL.
    dynpost-icon_id        = icon_simulate.
    dynpost-icon_text      = 'Simulate'.
  ELSE.
    dynpost-icon_id        = icon_execute_object.
    dynpost-icon_text      = 'Post'.
  ENDIF.

  IF gv_post IS NOT INITIAL.
    APPEND '&POS' TO fcode.
    APPEND '&LOG' TO fcode.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
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
         lv_valid TYPE c.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
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
      IF gv_post IS INITIAL.
        PERFORM f_posting_data.
        IF gt_bapiret2[] IS NOT INITIAL.
          MESSAGE s000(zab) WITH 'Error in posting, please check in Error Log'
                            DISPLAY LIKE 'E'.
        ELSE.
          IF gv_simulate IS INITIAL.
            MESSAGE s614(rw).
            gv_simulate = 'X'.
          ELSE.
            MESSAGE s605(rw) WITH gv_belnr gv_gjahr.
            gv_post   = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'Document already posted'
                          DISPLAY LIKE 'E'.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
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
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

*  PERFORM f_alv_sort USING : 1 'TKNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
*    'X' 'X' '' '' '',
*    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
*    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'BUKRS' '' '' '' '' '' '' 'BUKRS' 'COEP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GSBER' '' '' '' '' '' '' 'GSBER' 'COEP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'PERIO' '' '' '' '' '' '' 'PERIO' 'COEP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GJAHR' '' '' '' '' '' '' 'GJAHR' 'COEP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'KOSTL' '' '' '' '' '' '' 'KOSTL' 'CSKS' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'KTEXT' '' '' '' '' '' '' 'KTEXT' 'CSKT' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'WKGBTR' '' '' 'WAERS' '' '' '' 'WKGBTR' 'COEP' 'Amount' '' '' ''
    '' '' '' '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'TKA01' '' '' '' '' '' '' ''
    '' '' '' '' ''.
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
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
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
*&      Form  F_VALUE_KOSTL_GROUP
*&---------------------------------------------------------------------*
FORM f_value_kostl_group  USING    fu_field.
  TYPES : BEGIN OF ty_xcsks,
            khinr    TYPE csks-khinr,
            descript TYPE setheadert-descript,
          END OF ty_xcsks.

  DATA : lt_xcsks      TYPE STANDARD TABLE OF ty_xcsks,
         ls_xcsks      LIKE LINE OF lt_xcsks,
         ls_csks       LIKE LINE OF gt_csks,
         lv_subrc      TYPE sy-subrc,
         lv_bukrs      TYPE csks-bukrs,
         lv_gsber      TYPE csks-gsber,
         lv_khinr      TYPE csks-khinr,
         lv_perio      TYPE coep-perio,
         lv_gjahr      TYPE coep-gjahr,
         lt_setheadert TYPE STANDARD TABLE OF setheadert,
         ls_setheadert LIKE LINE OF lt_setheadert,
         lt_group      TYPE STANDARD TABLE OF setheadert,
         ls_group      LIKE LINE OF lt_group.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab,
         dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

  PERFORM f_dynp_value_read USING 'PA_BUKRS'
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING 'PA_GSBER'
                            CHANGING lv_gsber.
  PERFORM f_dynp_value_read USING 'PA_PERIO'
                            CHANGING lv_perio.
  PERFORM f_dynp_value_read USING 'PA_GJAHR'
                            CHANGING lv_gjahr.

  CONCATENATE lv_gjahr lv_perio+1(2) '01' INTO gv_datbi.

  SELECT *
    FROM csks
    INTO CORRESPONDING FIELDS OF TABLE gt_csks
    WHERE kokrs = '8010'
      AND bukrs = lv_bukrs
      AND gsber = lv_gsber
      AND datbi >= gv_datbi.

  LOOP AT gt_csks INTO ls_csks.
    ls_xcsks-khinr    = ls_csks-khinr.
    APPEND ls_xcsks TO lt_xcsks.

    ls_group-setname  = ls_csks-khinr.
    APPEND ls_group TO lt_group.
    CLEAR : ls_xcsks, ls_group.
  ENDLOOP.

  SORT lt_group BY setname.
  DELETE ADJACENT DUPLICATES FROM lt_group COMPARING setname.
  IF lt_group[] IS NOT INITIAL.
    SELECT *
      FROM setheadert
      INTO CORRESPONDING FIELDS OF TABLE lt_setheadert
      FOR ALL ENTRIES IN lt_group
      WHERE setclass  = '0101'
        AND subclass  = '8010'
        AND setname   = lt_group-setname
        AND langu     = sy-langu.
  ENDIF.

  SORT lt_xcsks BY khinr.
  DELETE ADJACENT DUPLICATES FROM lt_xcsks COMPARING khinr.
  LOOP AT lt_xcsks INTO ls_xcsks.
    CLEAR ls_setheadert.
    READ TABLE lt_setheadert INTO ls_setheadert
                             WITH KEY setname = ls_xcsks-khinr.
    IF sy-subrc = 0.
      ls_xcsks-descript = ls_setheadert-descript.
      MODIFY lt_xcsks FROM ls_xcsks TRANSPORTING descript.
    ENDIF.
  ENDLOOP.

  ASSIGN lt_xcsks[] TO <fs_tab>.
  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KHINR' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_khinr  = ls_return-fieldval.
      READ TABLE lt_xcsks INTO ls_xcsks WITH KEY khinr = lv_khinr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_xcsks-khinr ''.
      ENDIF.
    ENDIF.

    PERFORM f_dyn_values_update TABLES dynpfields.
  ENDIF.
ENDFORM.                    " F_VALUE_KOSTL_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update TABLES   dynpfields STRUCTURE dynpread.
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.

ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F4CALLBACK
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                    " F4CALLBACK

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        fc_value  = ls_dynpfields-fieldvalue.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_DYNP_VALUE_READ

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : documentheader TYPE bapiache09,  "bapiache08,
         accountgl      TYPE STANDARD TABLE OF bapiacgl09, "bapiacgl08,
         ls_accountgl   LIKE LINE OF accountgl,
         currencyamount TYPE STANDARD TABLE OF bapiaccr09, "bapiaccr08,
         ls_currency    LIKE LINE OF currencyamount,
         return         TYPE STANDARD TABLE OF bapiret2,
         ls_return      LIKE LINE OF return,
         extension1     TYPE STANDARD TABLE OF bapiextc,
         ls_extension1  LIKE LINE OF extension1,
         criteria       TYPE STANDARD TABLE OF bapiackec9,
         ls_criteria    LIKE LINE OF criteria,
         obj_type       TYPE bapiache09-obj_type.

  DATA : ls_out           LIKE LINE OF gt_out.

  DATA : lv_buzei     TYPE bseg-buzei,
         lv_wkgbtr    TYPE coep-wkgbtr,
         lv_datum     TYPE sy-datum,
         lv_kostl     TYPE csks-kostl,
         lv_dmbtr(19).

  CONCATENATE pa_gjahr pa_perio+1(2) '01' INTO lv_datum.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datum
    IMPORTING
      last_day_of_month = lv_datum
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  obj_type = 'BKPF'.

  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = pa_bukrs.
  documentheader-doc_date   = lv_datum.
  documentheader-pstng_date = lv_datum.
  documentheader-doc_type   = 'SA'.
*  documentheader-ref_doc_no = ''.
*  documentheader-header_txt = ''.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-wkgbtr = 0.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_buzei.
    ls_accountgl-itemno_acc   = lv_buzei.
    ls_accountgl-gl_account   = '0751500000'.
    PERFORM f_conversion_alpha USING ls_out-kostl
                               CHANGING lv_kostl.
    ls_accountgl-bus_area     = pa_gsber.
    ls_accountgl-costcenter   = lv_kostl.
    IF pa_bukrs IS NOT INITIAL.
      PERFORM f_modify_alpha USING pa_bukrs
                             CHANGING ls_accountgl-trade_id.
    ENDIF.
    APPEND ls_accountgl TO accountgl.
    CLEAR ls_accountgl.

    ls_out-wkgbtr   = ls_out-wkgbtr * -1.
    ADD ls_out-wkgbtr TO lv_wkgbtr.

    ls_extension1(3)          = lv_buzei.
    IF ls_out-wkgbtr < 0.
      ls_extension1+3(2)        = '50'.
    ELSE.
      ls_extension1+3(2)        = '40'.
    ENDIF.
    APPEND ls_extension1 TO extension1.
    CLEAR ls_extension1.

    ls_currency-itemno_acc    = lv_buzei.
    ls_currency-curr_type     = '00'.
    ls_currency-currency      = ls_out-waers.
    PERFORM f_modify_currency USING ls_out-wkgbtr
                              CHANGING ls_currency-amt_doccur.
    APPEND ls_currency TO currencyamount.
    CLEAR ls_currency.
  ENDLOOP.

  ADD 1 TO lv_buzei.
  ls_accountgl-itemno_acc   = lv_buzei.
  ls_accountgl-gl_account   = '0911900000'.
  CASE pa_gsber.
    WHEN '0901' OR '0101' OR '0102'  OR '0401'.
      CONCATENATE pa_gsber '0401' INTO lv_kostl.
    WHEN '1900'.
      CONCATENATE pa_gsber(3) '4001' INTO lv_kostl.
    WHEN OTHERS.
      CONCATENATE pa_gsber '401' INTO lv_kostl.
  ENDCASE.
  PERFORM f_conversion_alpha USING lv_kostl
                             CHANGING lv_kostl.
  ls_accountgl-bus_area     = pa_gsber.
  ls_accountgl-costcenter   = lv_kostl.
  IF pa_bukrs IS NOT INITIAL.
    PERFORM f_modify_alpha USING pa_bukrs
                           CHANGING ls_accountgl-trade_id.
  ENDIF.
  APPEND ls_accountgl TO accountgl.
  CLEAR ls_accountgl.

  lv_wkgbtr = lv_wkgbtr * -1.
  ls_extension1(3)          = lv_buzei.
  IF lv_wkgbtr < 0.
    ls_extension1+3(2)        = '50'.
  ELSE.
    ls_extension1+3(2)        = '40'.
  ENDIF.
  APPEND ls_extension1 TO extension1.
  CLEAR ls_extension1.

  ls_currency-itemno_acc    = lv_buzei.
  ls_currency-curr_type     = '00'.
  ls_currency-currency      = ls_out-waers.
  PERFORM f_modify_currency USING lv_wkgbtr
                            CHANGING ls_currency-amt_doccur.
  APPEND ls_currency TO currencyamount.
  CLEAR ls_currency.

  IF gv_simulate IS INITIAL.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader = documentheader
      TABLES
        accountgl      = accountgl
        currencyamount = currencyamount
        extension1     = extension1
        criteria       = criteria
        return         = return.
  ELSE.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = documentheader
      IMPORTING
        obj_type       = obj_type
      TABLES
        accountgl      = accountgl
        currencyamount = currencyamount
        return         = return
        extension1     = extension1
        criteria       = criteria.
  ENDIF.

  READ TABLE return INTO ls_return INDEX 1.
  IF ls_return-type = 'S'.
    gv_belnr  = ls_return-message_v2(10).
    gv_gjahr  = ls_return-message_v2+14(4).
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    LOOP AT return INTO ls_return.
      APPEND ls_return TO gt_bapiret2.
      CLEAR ls_return.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_alpha  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_CONVERSION_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_CURRENCY
*&---------------------------------------------------------------------*
FORM f_modify_currency  USING    fu_value
                        CHANGING fc_value.
  DATA : lv_dmbtr(19).

  lv_dmbtr    = fu_value.
  TRANSLATE lv_dmbtr USING '. '.
  TRANSLATE lv_dmbtr USING ',.'.
  CONDENSE lv_dmbtr NO-GAPS.
  fc_value    = lv_dmbtr.
ENDFORM.                    " F_MODIFY_CURRENCY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ALPHA
*&---------------------------------------------------------------------*
FORM f_modify_alpha  USING    fu_value
                     CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_MODIFY_ALPHA
