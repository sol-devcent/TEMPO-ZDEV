*&---------------------------------------------------------------------*
*&  Include           ZCO_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CLEAR: gv_post,gv_simulate.
  PERFORM f_init_material.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'NDS' '0' '' '' ''.
  PERFORM f_modify_screen USING : 'GRY' '' '0' '' ''.

  CASE 'X'.
    WHEN butt2 OR butt3.
      PERFORM f_modify_screen USING : 'BUD' '0' '' '' ''.
    WHEN OTHERS.
  ENDCASE.
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
  SELECT * INTO TABLE gt_zfidt009
    FROM zfidt009 WHERE bukrs = pa_bukrs.

  IF gt_zfidt009[] IS INITIAL.
    MESSAGE 'Data Mapping Account blm ada' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  SELECT a~bukrs a~belnr a~gjahr budat waers buzei gsber bschl hkont
         kostl matnr dmbtr kunnr zuonr prctr
    INTO CORRESPONDING FIELDS OF TABLE gt_bseg
    FROM bkpf AS a JOIN bseg AS b ON a~bukrs = b~bukrs AND
                                     a~belnr = b~belnr AND
                                     a~gjahr = b~gjahr
    FOR ALL ENTRIES IN gt_zfidt009
    WHERE a~bukrs = pa_bukrs
      AND a~budat IN so_budat
      AND a~blart = 'RV'
      AND b~matnr IN so_matnr
      AND hkont   = gt_zfidt009-hkont
      AND b~kunnr NOT LIKE 'TSB%'.

  PERFORM f_filter_customer.

  IF gt_bseg[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  IF so_matnr[] IS NOT INITIAL.
    SELECT matnr maktx INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt WHERE matnr IN so_matnr
                  AND spras EQ sy-langu.
  ELSE.
    SELECT matnr maktx INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_bseg
      WHERE matnr = gt_bseg-matnr
        AND spras = sy-langu.
  ENDIF.

  SELECT * INTO TABLE gt_zfidt008
    FROM zfidt008 FOR ALL ENTRIES IN gt_bseg
    WHERE bukrs = gt_bseg-bukrs
      AND belnr = gt_bseg-belnr
      AND gjahr = gt_bseg-gjahr.

  "Filter GT_BSEG
  LOOP AT gt_bseg INTO DATA(lw_bseg).
    READ TABLE gt_zfidt008 WITH KEY bukrs = lw_bseg-bukrs
                                    belnr = lw_bseg-belnr
                                    gjahr = lw_bseg-gjahr
                                    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      IF butt1 = 'X'.
        DELETE TABLE gt_bseg FROM lw_bseg.
      ENDIF.
    ELSE.
      IF butt11 = 'X'.
        DELETE TABLE gt_bseg FROM lw_bseg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_bseg[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  LOOP AT gt_bseg INTO DATA(lw_bseg).
    READ TABLE gt_makt INTO DATA(lw_makt)
                       WITH KEY matnr = lw_bseg-matnr.
    READ TABLE gt_zfidt009 INTO DATA(lv_zfidt009)
                       WITH KEY bukrs = lw_bseg-bukrs
                                hkont = lw_bseg-hkont.
    APPEND INITIAL LINE TO gt_out ASSIGNING FIELD-SYMBOL(<fs_out>).
    MOVE-CORRESPONDING lw_bseg TO <fs_out>.
    <fs_out>-maktx = lw_makt-maktx.
    <fs_out>-hkont_clr = lv_zfidt009-hkont_clr.
    <fs_out>-acctyp    = lv_zfidt009-acctyp.

    IF butt11 = 'X'.
      READ TABLE gt_zfidt008 INTO DATA(ls_zfidt008)
                             WITH KEY bukrs = lw_bseg-bukrs
                                      belnr = lw_bseg-belnr
                                      gjahr = lw_bseg-gjahr.
      IF sy-subrc = 0.
        <fs_out>-belnr_r = ls_zfidt008-belnr_reclass.
        <fs_out>-gjahr_r = ls_zfidt008-gjahr_reclass.
      ENDIF.
    ENDIF.
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

  IF butt11 = 'X'.
    APPEND '&POS' TO fcode.
    APPEND '&LOG' TO fcode.
  ELSE.
    IF gv_post IS NOT INITIAL.
      APPEND '&POS' TO fcode.
      APPEND '&LOG' TO fcode.
    ENDIF.
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
      READ TABLE gt_out WITH KEY mark = 'X' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        IF gv_post IS INITIAL.
          PERFORM f_posting_data.
          IF gt_bapiret2[] IS NOT INITIAL.
            MESSAGE s000(zab) WITH 'Error in posting, please check in Error Log'
                              DISPLAY LIKE 'E'.
          ELSE.
            IF gv_simulate IS INITIAL.
              MESSAGE s614(rw).
              gv_simulate = 'X'.

              READ TABLE gt_out WITH KEY icon = icon_red_light
                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                DELETE gt_out WHERE mark IS INITIAL.
              ENDIF.
            ELSE.
*            MESSAGE s605(rw) WITH gv_belnr gv_gjahr.
              gv_post   = 'X'.
              PERFORM f_write_table.
              MESSAGE s000(zab) WITH 'Posting Successful'.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE s000(zab) WITH 'Document already posted'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'No data selected' TYPE 'S' DISPLAY LIKE 'E'.
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

* When edit display
    CALL METHOD g_tabgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  ELSE.
    CALL METHOD g_tabgrid->refresh_table_display( ).
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-box_fname           = 'MARK'.
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
  IF butt1 = 'X'.
    PERFORM f_dyn_int_table USING :
      'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
      'X' 'X' '' '' '',
      'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
      'X' 'X' '' '' ''.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'BUKRS' '' '' '' '' '' '' 'BUKRS' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BELNR' '' '' '' '' '' '' 'BELNR' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GJAHR' '' '' '' '' '' '' 'GJAHR' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BUZEI' '' '' '' '' '' '' 'BUZEI' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GSBER' '' '' '' '' '' '' 'GSBER' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BSCHL' '' '' '' '' '' '' 'BSCHL' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'HKONT' '' '' '' '' '' '' 'HKONT' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
*    'KOSTL' '' '' '' '' '' '' 'KOSTL' 'BSEG' '' '' '' '' '' '' ''
*    '' '' '' '' '',
    'PRCTR' '' '' '' '' '' '' 'PRCTR' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BUDAT' '' '' '' '' '' '' 'BUDAT' 'BKPF' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'DMBTR' '' '' 'WAERS' '' '' '' 'DMBTR' 'BSEG' 'Amount' '' '' ''
    '' '' '' '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'BKPF' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BELNR_R' '' '' '' '' '' '' 'BELNR' 'BSEG' 'RclassNo' '' '' '' '' '' ''
    '' '' '' '' '',
    'GJAHR_r' '' '' '' '' '' '' 'GJAHR' 'BSEG' 'RclassYr' '' '' '' '' '' ''
    '' '' '' '' ''.
*    'BUDAT_R' '' '' '' '' '' '' 'BUDAT' 'BKPF' 'RclassDate' '' '' '' '' '' ''
*    '' '' '' '' ''.
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
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : documentheader TYPE bapiache09,  "bapiache08,
         accountgl      TYPE STANDARD TABLE OF bapiacgl09, "bapiacgl08,
         ls_accountgl   LIKE LINE OF accountgl,
         ls_accountgl2  LIKE LINE OF accountgl,
         ls_accountgl3  LIKE LINE OF accountgl,
         currencyamount TYPE STANDARD TABLE OF bapiaccr09, "bapiaccr08,
         ls_currency    LIKE LINE OF currencyamount,
         ls_currency2   LIKE LINE OF currencyamount,
         ls_currency3   LIKE LINE OF currencyamount,
         return         TYPE STANDARD TABLE OF bapiret2,
         ls_return      LIKE LINE OF return,
         extension1     TYPE STANDARD TABLE OF bapiextc,
         ls_extension1  LIKE LINE OF extension1,
         ls_extension12 LIKE LINE OF extension1,
         ls_extension13 LIKE LINE OF extension1,
         criteria       TYPE STANDARD TABLE OF bapiackec9,
         ls_criteria    LIKE LINE OF criteria,
         ls_criteria2   LIKE LINE OF criteria,
         ls_criteria3   LIKE LINE OF criteria,
         obj_type       TYPE bapiache09-obj_type.

  DATA : lt_out  TYPE STANDARD TABLE OF ty_out,
         lt_out2 TYPE STANDARD TABLE OF ty_out.

  DATA : lv_buzei  TYPE bseg-buzei,
         lv_bsch1  TYPE rf05a-newbs,
         lv_bsch2  TYPE rf05a-newbs,
         lv_hkont1 TYPE bseg-hkont,
         lv_hkont2 TYPE bseg-hkont,
         lv_wkgbtr TYPE coep-wkgbtr,
         lv_datum  TYPE sy-datum,
         lv_kostl  TYPE csks-kostl,
         lv_dmbtr  TYPE bseg-dmbtr,
         lv_dmbtr2 TYPE bseg-dmbtr,
         lv_hkont  TYPE bseg-hkont.

  DATA : lv_cnt    TYPE numc1,
         lv_field1 TYPE char20,
         lv_field2 TYPE char20.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  SORT lt_out BY bukrs belnr gjahr buzei.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING bukrs belnr gjahr.

  lt_out2[] = gt_out[].
  SORT lt_out2 BY bukrs belnr gjahr acctyp hkont_clr hkont buzei.
  DELETE ADJACENT DUPLICATES FROM lt_out2 COMPARING bukrs belnr gjahr acctyp hkont_clr.

  SORT gt_out BY bukrs belnr gjahr acctyp hkont_clr hkont buzei.

  IF lt_out[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'S' DISPLAY LIKE 'E'.

  ELSE.
    CLEAR gt_bapiret2.
    LOOP AT lt_out INTO DATA(ls_out).
      CLEAR: documentheader,accountgl,ls_accountgl,currencyamount,
             ls_currency,return,ls_return,extension1,ls_extension1,
             criteria,ls_criteria,obj_type,lv_hkont,lv_buzei.

      documentheader-bus_act    = 'RFBU'.
      documentheader-username   = sy-uname.
      documentheader-comp_code  = pa_bukrs.
      documentheader-doc_date   = ls_out-budat.
      documentheader-pstng_date = ls_out-budat.
      documentheader-doc_type   = 'SA'.
      documentheader-ref_doc_no = ls_out-belnr.
*      documentheader-header_txt = 'Reclass Jurnal Discount F'.

      obj_type = 'BKPF'.

      LOOP AT lt_out2 INTO DATA(ls_out2) WHERE bukrs = ls_out-bukrs
                                           AND belnr = ls_out-belnr
                                           AND gjahr = ls_out-gjahr.

        CLEAR: lv_dmbtr,lv_bsch1,lv_bsch2.
        LOOP AT gt_out INTO DATA(gs_out) WHERE bukrs = ls_out2-bukrs
                                           AND belnr = ls_out2-belnr
                                           AND gjahr = ls_out2-gjahr
                                           AND hkont_clr = ls_out2-hkont_clr.
          gs_out-mark = 'X'.
          MODIFY gt_out FROM gs_out TRANSPORTING mark.

          IF gs_out-dmbtr IS INITIAL.
            CONTINUE.
          ENDIF.

          CASE gs_out-bschl.
            WHEN '40'.
              lv_bsch1 = '50'.
              lv_bsch2 = '40'.
            WHEN '50'.
              lv_bsch1 = '40'.
              lv_bsch2 = '50'.
          ENDCASE.

          ADD 1 TO lv_buzei.

          ls_accountgl-itemno_acc   = lv_buzei.
          ls_accountgl-gl_account   = gs_out-hkont.
          ls_accountgl-bus_area     = gs_out-gsber.
          ls_accountgl-profit_ctr   = gs_out-prctr.
          ls_accountgl-alloc_nmbr   = gs_out-zuonr.
          ls_accountgl-costcenter   = gs_out-kostl.
          ls_accountgl-trade_id     = gs_out-bukrs.
          ls_accountgl-material     = gs_out-matnr.
          APPEND ls_accountgl TO accountgl. CLEAR ls_accountgl.

          ls_extension1(3)          = lv_buzei.
          ls_extension1+3(2)        = lv_bsch1.
          APPEND ls_extension1 TO extension1. CLEAR ls_extension1.

          ls_currency-itemno_acc    = lv_buzei.
          ls_currency-curr_type     = '00'.
          ls_currency-currency      = gs_out-waers.
          PERFORM f_modify_currency USING gs_out-dmbtr
                                    CHANGING ls_currency-amt_doccur.
          IF lv_bsch1 = '50'.
            ls_currency-amt_doccur = ls_currency-amt_doccur * -1.
          ENDIF.
          ADD gs_out-dmbtr TO lv_dmbtr.
          APPEND ls_currency TO currencyamount. CLEAR ls_currency.

          ls_criteria-itemno_acc        = lv_buzei.
          ls_criteria-fieldname         = 'PRCTR'.
          ls_criteria-character         = gs_out-prctr.
          APPEND ls_criteria TO criteria. CLEAR ls_criteria.
        ENDLOOP.

        ADD 1 TO lv_buzei.

        ls_accountgl-itemno_acc   = lv_buzei.
        ls_accountgl-gl_account   = ls_out2-hkont_clr.
        ls_accountgl-bus_area     = ls_out2-gsber.
        ls_accountgl-profit_ctr   = ls_out2-prctr.
        ls_accountgl-alloc_nmbr   = ls_out2-zuonr.
        ls_accountgl-costcenter   = ls_out2-kostl.
        ls_accountgl-trade_id     = ls_out2-bukrs.
        ls_accountgl-material     = ls_out2-matnr.
        APPEND ls_accountgl TO accountgl. CLEAR ls_accountgl.

        ls_extension1(3)          = lv_buzei.
        ls_extension1+3(2)        = lv_bsch2.
        APPEND ls_extension1 TO extension1. CLEAR ls_extension1.

        ls_currency-itemno_acc    = lv_buzei.
        ls_currency-curr_type     = '00'.
        ls_currency-currency      = ls_out2-waers.
        PERFORM f_modify_currency USING lv_dmbtr
                                  CHANGING ls_currency-amt_doccur.
        IF lv_bsch2 = '50'.
          ls_currency-amt_doccur = ls_currency-amt_doccur * -1.
        ENDIF.
        APPEND ls_currency TO currencyamount. CLEAR ls_currency.

        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'PRCTR'.
        ls_criteria-character         = ls_out2-prctr.
        APPEND ls_criteria TO criteria. CLEAR ls_criteria.
      ENDLOOP.

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

        IF gv_simulate IS INITIAL.
          gs_out-icon = icon_green_light.
          MODIFY gt_out FROM gs_out TRANSPORTING icon
                        WHERE bukrs = ls_out-bukrs
                          AND belnr = ls_out-belnr
                          AND gjahr = ls_out-gjahr.
        ELSE.
          gs_out-budat_r = sy-datum.
          gs_out-belnr_r = gv_belnr.
          gs_out-gjahr_r = gv_gjahr.
          MODIFY gt_out FROM gs_out TRANSPORTING budat_r belnr_r gjahr_r
                        WHERE bukrs = ls_out-bukrs
                          AND belnr = ls_out-belnr
                          AND gjahr = ls_out-gjahr.
        ENDIF.

      ELSE.
        LOOP AT return INTO ls_return.
          APPEND ls_return TO gt_bapiret2.
          CLEAR ls_return.
        ENDLOOP.

        gs_out-icon = icon_red_light.
        MODIFY gt_out FROM gs_out TRANSPORTING icon
                      WHERE bukrs = ls_out-bukrs
                        AND belnr = ls_out-belnr
                        AND gjahr = ls_out-gjahr.
      ENDIF.
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

*&---------------------------------------------------------------------*
*&      Form  F_INIT_MATERIAL
*&---------------------------------------------------------------------*
FORM f_init_material .
  SELECT * INTO TABLE @DATA(lt_zfidt007)
    FROM zfidt007 WHERE bukrs = @pa_bukrs.
  IF sy-subrc = 0.
    LOOP AT lt_zfidt007 INTO DATA(lw_zfidt007).
      so_matnr-sign = 'I'.
      so_matnr-option = 'EQ'.
      so_matnr-low = lw_zfidt007-matnr.
      APPEND so_matnr. CLEAR so_matnr.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_TABLE
*&---------------------------------------------------------------------*
FORM f_write_table .
  DATA: lt_zfidt008 TYPE TABLE OF zfidt008,
        ls_zfidt008 LIKE LINE OF lt_zfidt008,
        lt_stylerow TYPE lvc_t_styl,
        ls_stylerow TYPE lvc_s_styl.


  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<fs_out>)
                 WHERE mark = 'X'
                   AND belnr NE space
                   AND gjahr NE space.
    ls_zfidt008-bukrs         = <fs_out>-bukrs.
    ls_zfidt008-belnr         = <fs_out>-belnr.
    ls_zfidt008-gjahr         = <fs_out>-gjahr.
    ls_zfidt008-budat         = <fs_out>-budat.
    ls_zfidt008-belnr_reclass = <fs_out>-belnr_r.
    ls_zfidt008-gjahr_reclass = <fs_out>-gjahr_r.
    COLLECT ls_zfidt008 INTO lt_zfidt008.

    CLEAR: <fs_out>-mark,ls_stylerow,lt_stylerow.

    ls_stylerow-fieldname = 'MARK'.
    ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    APPEND ls_stylerow TO lt_stylerow.
    INSERT LINES OF lt_stylerow INTO TABLE <fs_out>-style.
  ENDLOOP.

  IF lt_zfidt008[] IS NOT INITIAL.
    MODIFY zfidt008 FROM TABLE lt_zfidt008.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_filter_customer .
  DATA: lv_kunnr TYPE bseg-kunnr VALUE IS INITIAL.

  DATA(lt_bseg) = gt_bseg[].
  SORT lt_bseg BY bukrs belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING bukrs belnr gjahr.

  SELECT DISTINCT bukrs, belnr, gjahr, buzei, kunnr
    INTO TABLE @DATA(lt_bseg2)
    FROM bseg FOR ALL ENTRIES IN @lt_bseg
    WHERE bukrs = @lt_bseg-bukrs
      AND belnr = @lt_bseg-belnr
      AND gjahr = @lt_bseg-gjahr
      AND kunnr NE @lv_kunnr.

  LOOP AT gt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
    READ TABLE lt_bseg2 INTO DATA(ls_bseg2)
                        WITH KEY bukrs = <fs_bseg>-bukrs
                                 belnr = <fs_bseg>-belnr
                                 gjahr = <fs_bseg>-gjahr.
    IF sy-subrc = 0.
      <fs_bseg>-kunnr = ls_bseg2-kunnr.
    ENDIF.
  ENDLOOP.

  DELETE gt_bseg WHERE kunnr(3) = 'TSB'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .
  CLEAR: gt_bapiret2,gt_out,gt_bseg,gt_makt,gt_zfidt007,gt_zfidt008,
         gt_zfidt009,gr_hkont,gv_post,gv_simulate,gv_belnr,gv_gjahr.
ENDFORM.
