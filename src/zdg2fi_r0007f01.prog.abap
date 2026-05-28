*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_R0007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.

*  IF so_anlkl[] IS INITIAL.
*    PERFORM f_error_message USING 'PAN' ''.
*  ENDIF.

  IF pa_bdatu IS INITIAL.
    PERFORM f_error_message USING 'PBD' ''.
  ENDIF.

  IF pa_afabe IS INITIAL.
    PERFORM f_error_message USING 'PAF' ''.
  ENDIF.
ENDFORM.

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
ENDFORM.

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
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : ls_anla  TYPE anla,
         ls_anlc  TYPE anlc,
         ls_anek  TYPE anek,
         ls_key   LIKE LINE OF gt_key,
         lr_gjahr TYPE RANGE OF gjahr,
         ls_gjahr LIKE LINE OF lr_gjahr,
         ls_data  TYPE ty_data,
         lt_anla  TYPE STANDARD TABLE OF anla.

  DATA : lt_anlb   TYPE STANDARD TABLE OF anlb,
         lt_anlc   TYPE STANDARD TABLE OF anlc,
         lt_anep   TYPE STANDARD TABLE OF anep,
         lt_anea   TYPE STANDARD TABLE OF anea,
         lt_anek   TYPE STANDARD TABLE OF anek,
         lt_anfm   TYPE STANDARD TABLE OF anfm,
         lt_anlbza TYPE STANDARD TABLE OF anlbza.

  DATA : lv_srtvr   TYPE rbada-srtvr,
         lv_afblpe  TYPE anlp-peraf,
         lv_xafblpe TYPE anlp-peraf,
         lv_bdatu   TYPE rbada-brdatu,
         lv_post.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_bdatu
    IMPORTING
      last_day_of_month = pa_bdatu
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  ls_gjahr-high   = pa_bdatu(4).
  ls_gjahr-low    = ls_gjahr-high - 1.
  ls_gjahr-sign   = 'I'.
  ls_gjahr-option = 'BT'.
  APPEND ls_gjahr TO lr_gjahr.

  lv_afblpe = pa_bdatu+4(2).
  lv_srtvr  = '0001'.

  SELECT SINGLE *
    FROM t001
    INTO CORRESPONDING FIELDS OF gs_t001
    WHERE bukrs = pa_bukrs.

  SELECT SINGLE *
    FROM t093b
    INTO CORRESPONDING FIELDS OF gs_t093b
    WHERE bukrs = pa_bukrs
      AND afabe = pa_afabe.

  SELECT SINGLE *
    FROM t093t
    INTO CORRESPONDING FIELDS OF gs_t093t
    WHERE spras  = sy-langu
      AND afapl  = 'TSPC'
      AND afaber = pa_afabe.

  SELECT SINGLE *
    FROM ankt
    INTO CORRESPONDING FIELDS OF gs_ankt
    WHERE spras = sy-langu
      AND anlkl IN so_anlkl.

  SELECT *
    FROM anla
    INTO CORRESPONDING FIELDS OF TABLE gt_anla
    WHERE bukrs = pa_bukrs
      AND anln1 IN so_anln1
      AND anln2 IN so_anln2
      AND anlkl IN so_anlkl
      AND deakt = '00000000'
      AND zugdt <> '00000000'
      AND aktiv <> '00000000'
  ORDER BY PRIMARY KEY.

  lt_anla[] = gt_anla[].
  DELETE lt_anla WHERE lifnr = space.
  DELETE ADJACENT DUPLICATES FROM lt_anla COMPARING lifnr.
  IF lt_anla[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
      FOR ALL ENTRIES IN lt_anla
      WHERE lifnr = lt_anla-lifnr.
  ENDIF.

  IF gt_anla[] IS NOT INITIAL.
    LOOP AT gt_anla INTO ls_anla.
      ls_key-bukrs = ls_anla-bukrs.
      ls_key-anln1 = ls_anla-anln1.
      ls_key-anln2 = ls_anla-anln2.
      ls_key-gjahr = ls_anla-aktiv(4).
      APPEND ls_key TO gt_key.
      ls_key-gjahr  = pa_bdatu(4).
      APPEND ls_key TO gt_key.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM gt_key COMPARING ALL FIELDS.

    SELECT *
      FROM anlb
      INTO CORRESPONDING FIELDS OF TABLE gt_anlb
      FOR ALL ENTRIES IN gt_anla
      WHERE bukrs = gt_anla-bukrs
        AND anln1 = gt_anla-anln1
        AND anln2 = gt_anla-anln2
        AND afabe = pa_afabe
        AND bdatu >= pa_bdatu
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM anlbza
      INTO CORRESPONDING FIELDS OF TABLE gt_anlbza
      FOR ALL ENTRIES IN gt_anla
      WHERE bukrs = gt_anla-bukrs
        AND anln1 = gt_anla-anln1
        AND anln2 = gt_anla-anln2
        AND afabe = pa_afabe
        AND bdatu >= pa_bdatu
      ORDER BY PRIMARY KEY.

    IF gt_key[] IS NOT INITIAL.
      SELECT *
        FROM anlc
        INTO CORRESPONDING FIELDS OF TABLE gt_xanlc
        FOR ALL ENTRIES IN gt_key
        WHERE bukrs = gt_key-bukrs
          AND anln1 = gt_key-anln1
          AND anln2 = gt_key-anln2
          AND gjahr = gt_key-gjahr
          AND afabe = pa_afabe
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM anek
        INTO CORRESPONDING FIELDS OF TABLE gt_xanek
        FOR ALL ENTRIES IN gt_key
        WHERE bukrs = gt_key-bukrs
          AND anln1 = gt_key-anln1
          AND anln2 = gt_key-anln2
          AND gjahr = gt_key-gjahr
        ORDER BY PRIMARY KEY.
    ENDIF.

    gt_anlc[] = gt_xanlc[].
    DELETE gt_anlc WHERE gjahr <> ls_gjahr-high.
    gt_anek[] = gt_xanek[].
    DELETE gt_anek WHERE gjahr <> ls_gjahr-high.

    SELECT *
      FROM anlz
      INTO CORRESPONDING FIELDS OF TABLE gt_anlz
      FOR ALL ENTRIES IN gt_anla
      WHERE bukrs = gt_anla-bukrs
        AND anln1 = gt_anla-anln1
        AND anln2 = gt_anla-anln2
        AND gsber IN so_gsber
        AND bdatu >= pa_bdatu
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM anea
      INTO CORRESPONDING FIELDS OF TABLE gt_anea
      FOR ALL ENTRIES IN gt_anla
      WHERE bukrs = gt_anla-bukrs
        AND anln1 = gt_anla-anln1
        AND anln2 = gt_anla-anln2
        AND gjahr = ls_gjahr-high
        AND afabe = pa_afabe
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM anep
      INTO CORRESPONDING FIELDS OF TABLE gt_anep
      FOR ALL ENTRIES IN gt_anla
      WHERE bukrs = gt_anla-bukrs
        AND anln1 = gt_anla-anln1
        AND anln2 = gt_anla-anln2
        AND gjahr = ls_gjahr-high
        AND afabe = pa_afabe
      ORDER BY PRIMARY KEY.
  ENDIF.

  LOOP AT gt_anla INTO ls_anla.
    IF ls_anla-zugdt+(6) > pa_bdatu(6) OR
      ls_anla-zugdt = '00000000'.
      DELETE TABLE gt_anla FROM ls_anla.
      CONTINUE.
    ENDIF.

* Command ANEK
*    LOOP AT gt_xanek INTO ls_anek WHERE anln1 = ls_anla-anln1
*                                    AND anln2 = ls_anla-anln2.
*      IF ls_anek-budat <> ls_anla-aktiv.
*        DELETE TABLE gt_xanek FROM ls_anek.
*      ENDIF.
*    ENDLOOP.

    PERFORM f_prepare_data TABLES lt_anlb
                                  lt_anlc
                                  lt_anep
                                  lt_anea
                                  lt_anek
                                  lt_anfm
                                  lt_anlbza
                           USING ls_anla.

    PERFORM f_show_post_depr TABLES gt_dpost
                                    lt_anlb
                                    lt_anlc
                                    lt_anep
                                    lt_anea
                                    lt_anek
                                    lt_anfm
                                    lt_anlbza
                             USING ls_anla 'X'
                             CHANGING lv_post.

    IF lv_post IS NOT INITIAL.
      CLEAR ls_anlc.
      READ TABLE gt_anlc INTO ls_anlc
                         WITH KEY anln1 = ls_anla-anln1
                                  anln2 = ls_anla-anln2.
      IF sy-subrc = 0.
        IF ls_anlc-afblpe+1(2) >= pa_bdatu+4(2).
          PERFORM f_call_ar25 TABLES itab_data
                              USING ls_anla-anln1 ls_anla-anln2
                                    lv_afblpe pa_bdatu lv_srtvr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_xanek[] IS NOT INITIAL.
*    PERFORM f_get_payment_data USING '' '' '' ''
*                               CHANGING ls_data.
    PERFORM f_get_payment_data_new USING '' '' '' ''
                                   CHANGING ls_data.
  ENDIF.

  cl_salv_bs_runtime_info=>clear_all( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_anla  LIKE LINE OF gt_anla,
         ls_anlc  LIKE LINE OF gt_anlc,
         ls_xanlc LIKE LINE OF gt_xanlc,
         ls_anlz  LIKE LINE OF gt_anlz,
         ls_anlb  LIKE LINE OF gt_anlb,
         ls_data  LIKE LINE OF gt_data.

  FIELD-SYMBOLS : <fs> TYPE any.

  PERFORM f_create_dyn_table.

  SORT gt_xanlc BY anln1 anln2 gjahr.

  LOOP AT gt_anla INTO ls_anla.
    CLEAR ls_anlc.
    READ TABLE gt_anlc INTO ls_anlc
                       WITH KEY anln1 = ls_anla-anln1
                                anln2 = ls_anla-anln2.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_xanlc.
    READ TABLE gt_xanlc INTO ls_xanlc
                        WITH KEY anln1 = ls_anla-anln1
                                 anln2 = ls_anla-anln2.
    IF sy-subrc = 0.
      IF ls_xanlc-answl = 0.
        ls_data-answl = ls_xanlc-kansw.
      ELSE.
        ls_data-answl = ls_xanlc-answl.
      ENDIF.
    ENDIF.

    ls_data-anln1 = ls_anla-anln1.
    ls_data-anln2 = ls_anla-anln2.
    ls_data-txt50 = ls_anla-txt50.
    ls_data-typbz = ls_anla-typbz.
    ls_data-eaufn = ls_anla-eaufn.
    ls_data-sernr = ls_anla-sernr.
    ls_data-zugdt = ls_anla-zugdt.
    ls_data-lifnr = ls_anla-lifnr.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = ls_anla-invzu
*      IMPORTING
*        output = ls_data-prctr.
    ls_data-prctr = ls_anla-invzu.

    ls_data-waers = gs_t093b-waers.

    CLEAR ls_anlz.
    READ TABLE gt_anlz INTO ls_anlz
                       WITH KEY anln1 = ls_anla-anln1
                                anln2 = ls_anla-anln2.
    IF sy-subrc = 0.
      ls_data-gsber = ls_anlz-gsber.
      ls_data-kostl = ls_anlz-kostl.
      ls_data-raumn = ls_anlz-raumn.
      ls_data-kfzkz = ls_anlz-kfzkz.
    ENDIF.

    IF ls_data-gsber NOT IN so_gsber.
      CLEAR ls_data.
      CONTINUE.
    ENDIF.

    CLEAR ls_anlb.
    READ TABLE gt_anlb INTO ls_anlb
                       WITH KEY anln1 = ls_anla-anln1
                                anln2 = ls_anla-anln2.
    IF sy-subrc = 0.
      ls_data-ndjar = ls_anlb-ndjar.
      ls_data-afabg = ls_anlb-afabg.
      ls_data-afasl = ls_anlb-afasl.
    ENDIF.

    PERFORM f_calculate_amount USING ls_anla
                               CHANGING ls_data.

*    PERFORM f_get_payment_data USING ls_anla-anln1 ls_anla-anln2
*                                     ls_anla-lifnr ls_anla-aktiv
*                               CHANGING ls_data.

    PERFORM f_get_payment_data_new USING ls_anla-anln1 ls_anla-anln2
                                         ls_anla-lifnr ls_anla-aktiv
                                   CHANGING ls_data.
    APPEND ls_data TO gt_data.
    CLEAR : ls_data.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA : lv_sypfkey  TYPE sypfkey.

  IF gt_data[] IS NOT INITIAL.
    SET TITLEBAR 'TITLEBAR'.
    lv_sypfkey = 'STANDARD'.

    TRY.
        cl_salv_table=>factory(
            IMPORTING
              r_salv_table   = gr_table
            CHANGING
              t_table        = gt_data ).
      CATCH cx_salv_data_error cx_salv_not_found.
    ENDTRY.

    gr_table->set_screen_status(
      pfstatus      = lv_sypfkey
      report        = gv_repid
      set_functions = gr_table->c_functions_all ).

    PERFORM f_set_function.
    PERFORM f_display_setting.
    PERFORM f_sort_data.
    PERFORM f_set_event.
    PERFORM f_display_modify.
    PERFORM f_header_title.
    PERFORM f_aggregations_data.

    gr_table->display( ).
  ENDIF.

  PERFORM f_parameter_id USING 'BUK' ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SET_FUNCTION
*&---------------------------------------------------------------------*
FORM f_set_function .
  DATA : lr_functions TYPE REF TO cl_salv_functions,
         lt_func_list TYPE salv_t_ui_func,
         ls_func_list LIKE LINE OF lt_func_list.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lt_func_list = lr_functions->get_functions( ).
  lr_functions->set_all( abap_true ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SETTING
*&---------------------------------------------------------------------*
FORM f_display_setting .
  DATA : lr_display TYPE REF TO cl_salv_display_settings,
         lr_columns TYPE REF TO cl_salv_columns,
         lr_layout  TYPE REF TO cl_salv_layout,
         ls_key     TYPE salv_s_layout_key.

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  TRY.
      lr_columns = gr_table->get_columns( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_columns->set_optimize( abap_true ).

  TRY .
      lr_layout = gr_table->get_layout( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  ls_key-report = gv_repid.
  lr_layout->set_key( ls_key ).

  lr_layout->set_save_restriction( if_salv_c_layout=>restrict_user_dependant ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SORT_DATA
*&---------------------------------------------------------------------*
FORM f_sort_data .
  DATA : lr_sorts TYPE REF TO cl_salv_sorts.

  TRY.
      lr_sorts = gr_table->get_sorts( ).
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SET_EVENT
*&---------------------------------------------------------------------*
FORM f_set_event .
  DATA : lr_events    TYPE REF TO cl_salv_events_table.

  lr_events = gr_table->get_event( ).

  CREATE OBJECT gr_events.
  SET HANDLER gr_events->on_user_command
              gr_events->on_double_click
          FOR lr_events.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MODIFY
*&---------------------------------------------------------------------*
FORM f_display_modify .
  DATA : ls_fieldcat TYPE lvc_s_fcat.

  DATA : lt_t247          TYPE STANDARD TABLE OF t247,
         lv_l             TYPE lvc_s_fcat-scrtext_l,
         lv_m             TYPE lvc_s_fcat-scrtext_m,
         lv_s             TYPE lvc_s_fcat-scrtext_s,
         lv_gjahr1        TYPE bsis-gjahr,
         lv_gjahr2        TYPE bsis-gjahr,
         lv_month         TYPE n LENGTH 3,
         lv_fieldname(30),
         lv_visible.

  lv_gjahr1 = pa_bdatu(4).
  lv_gjahr2 = lv_gjahr1 - 1.
  SELECT *
    FROM t247
    INTO CORRESPONDING FIELDS OF TABLE lt_t247
    WHERE spras = sy-langu.

  LOOP AT gt_fieldcat INTO ls_fieldcat.
    lv_visible = 'X'.
    CASE ls_fieldcat-fieldname.
      WHEN 'TXT50'.
        PERFORM f_change_title USING 'Asset Description' 'Asset Description' 'AssetDesc.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'LIFNR'.
        PERFORM f_change_title USING 'Vendor' 'Vendor' 'Vendor'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'ANSWL'.
        PERFORM f_change_title USING 'Price Acquistion' 'Price Acquistion' 'Price Acq.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'BUDAT'.
        PERFORM f_change_title USING 'Payment Date' 'Payment Date' 'PayDt.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'BELNR'.
        PERFORM f_change_title USING 'Payment Doc.' 'Payment Doc.' 'PayDoc.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'DEPMO'.
        PERFORM f_change_title USING 'Depr./Month' 'Depr./Month' 'Depr./Month'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'ADELY'.
        lv_l = |{ 'Acc.Deprc.' } { lv_gjahr2 }|.
        lv_m = |{ 'Acc.Deprc.' } { lv_gjahr2 }|.
        lv_s = |{ 'Acc.Deprc.' } { lv_gjahr2 }|.
        PERFORM f_change_title USING lv_l lv_m lv_s
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'ADECU'.
        lv_l = |{ 'Acc.Deprc.' } { lv_month } { lv_gjahr1 }|.
        lv_m = |{ 'Acc.Deprc.' } { lv_month } { lv_gjahr1 }|.
        lv_s = |{ 'Acc.Deprc.' } { lv_month } { lv_gjahr1 }|.
        PERFORM f_change_title USING lv_l lv_m lv_s
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'NBVAL'.
        PERFORM f_change_title USING 'Net Book Value' 'Net Book Value' 'NetBook Val.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
      WHEN 'INVZU'.
*        PERFORM f_change_title USING 'Profit Center( Inv.No )' 'Profit Center( Inv.No )'
*                                     'Profit ctr(InvNo)'
        PERFORM f_change_title USING 'Inv.No/Profit Center' 'Inv.No/Profit Center'
                                     'InvNo/PrfCtr'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.

      WHEN 'ICON'.
        PERFORM f_change_title USING 'Status Depr.' 'Status Depr.' 'StsDepr.'
                               CHANGING ls_fieldcat-scrtext_l
                                        ls_fieldcat-scrtext_m
                                        ls_fieldcat-scrtext_s.
    ENDCASE.

    IF ls_fieldcat-fieldname(3) = 'DEP' AND
      ls_fieldcat-fieldname <> 'DEPMO'.
      ADD 1 TO lv_month.
      IF lv_month+1(2) <> pa_bdatu+4(2).
        lv_visible = space.
      ENDIF.
      lv_fieldname = |{ 'DEP' }{ lv_month }|.
      CASE ls_fieldcat-fieldname.
        WHEN lv_fieldname.
          PERFORM f_concatenate_month TABLES lt_t247
                                      USING lv_month lv_gjahr1
                                      CHANGING lv_l lv_m lv_s.
          PERFORM f_change_title USING lv_l lv_m lv_s
                                 CHANGING ls_fieldcat-scrtext_l
                                          ls_fieldcat-scrtext_m
                                          ls_fieldcat-scrtext_s.
      ENDCASE.
    ENDIF.

    PERFORM f_modify_alv USING ls_fieldcat-fieldname lv_visible
                               ls_fieldcat-key
                               ls_fieldcat-scrtext_l
                               ls_fieldcat-scrtext_m
                               ls_fieldcat-scrtext_s
                               ls_fieldcat-datatype
                               'WAERS' ''.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_TITLE
*&---------------------------------------------------------------------*
FORM f_header_title .
  DATA : lr_grid  TYPE REF TO cl_salv_form_layout_grid,
         lr_label TYPE REF TO cl_salv_form_label,
         lr_flow  TYPE REF TO cl_salv_form_layout_flow.

  DATA : lv_datum(10),
         lv_uzeit(8),
         lv_text(100).

  WRITE pa_bdatu TO lv_datum DD/MM/YYYY.

  CREATE OBJECT lr_grid.
  lr_label = lr_grid->create_label( row = 1 column = 1 ).
  lv_text = |Asset Report per { lv_datum }|.
  lr_label->set_text( lv_text ).

  lr_flow = lr_grid->create_flow( row = 2 column = 1 ).

  WRITE sy-datum TO lv_datum DD/MM/YYYY.
  WRITE sy-uzeit TO lv_uzeit USING EDIT MASK '__:__:__'.

  lr_flow = lr_grid->create_flow( row = 3 column = 1 ).
  lr_flow->create_text( text = |Company code| ).
  lr_flow = lr_grid->create_flow( row = 3 column = 2 ).
  lr_flow->create_text( text = |: { gs_t001-butxt }| ).

  lr_flow = lr_grid->create_flow( row = 5 column = 1 ).
  lr_flow->create_text( text = |Generated on| ).
  lr_flow = lr_grid->create_flow( row = 5 column = 2 ).
  lr_flow->create_text( text = |: { lv_datum } { lv_uzeit }| ).

  lr_flow = lr_grid->create_flow( row = 4 column = 1 ).
  lr_flow->create_text( text = |Asset Class| ).
  lr_flow = lr_grid->create_flow( row = 4 column = 2 ).
  lr_flow->create_text( text = |: { gs_ankt-txk50 }| ).

  lr_flow = lr_grid->create_flow( row = 6 column = 1 ).
  lr_flow->create_text( text = |Depreciation area| ).
  lr_flow = lr_grid->create_flow( row = 6 column = 2 ).
  lr_flow->create_text( text = |: { pa_afabe }-{ gs_t093t-afbktx }| ).

  gr_table->set_top_of_list( lr_grid ).
  gr_table->set_top_of_list_print( lr_grid ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_AGGREGATIONS_DATA
*&---------------------------------------------------------------------*
FORM f_aggregations_data .
  DATA : lr_aggrs    TYPE REF TO cl_salv_aggregations,
         ls_fieldcat TYPE lvc_s_fcat.

  lr_aggrs = gr_table->get_aggregations( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ALV
*&---------------------------------------------------------------------*
FORM f_modify_alv  USING    fu_column fu_visible fu_key
                            fu_scrtext_l fu_scrtext_m fu_scrtext_s
                            fu_datatype fu_fwaers fu_fmeins.
  DATA : lr_columns TYPE REF TO cl_salv_columns_table,
         lr_column  TYPE REF TO cl_salv_column_table,
         ls_color   TYPE lvc_s_colo.

  TRY.
      lr_columns = gr_table->get_columns( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_column ?= lr_columns->get_column( fu_column ).
  lr_column->set_long_text( fu_scrtext_l ).
  lr_column->set_medium_text( fu_scrtext_m ).
  lr_column->set_short_text( fu_scrtext_s ).
  lr_column->set_visible( fu_visible ).
  CASE fu_datatype.
    WHEN 'CURR'.
      lr_column->set_currency_column( fu_fwaers ).
      lr_column->set_alignment( 2 ).
    WHEN 'QUAN'.
      lr_column->set_quantity_column( fu_fmeins ).
      lr_column->set_alignment( 2 ).
  ENDCASE.

  IF fu_key IS NOT INITIAL.
    ls_color-col = col_heading.
    ls_color-int = 1.
    ls_color-inv = 0.
    lr_column->set_color( ls_color ).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command  USING    fu_ucomm LIKE sy-ucomm.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_table .
  DATA : dyn_table   TYPE REF TO data,
         dyn_line    TYPE REF TO data,
         ls_fieldcat TYPE lvc_s_fcat,
         lo_tabdescr TYPE REF TO cl_abap_structdescr,
         ddfields    TYPE ddfields,
         dfies       TYPE dfies.

  FIELD-SYMBOLS : <ft_data> TYPE STANDARD TABLE,
                  <fs_data> TYPE any.

  CREATE DATA dyn_table LIKE LINE OF gt_data.
  lo_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( dyn_table ).
  ddfields = cl_salv_data_descr=>read_structdescr( lo_tabdescr ).
  LOOP AT ddfields INTO dfies.
    MOVE-CORRESPONDING dfies TO ls_fieldcat.
    APPEND ls_fieldcat TO gt_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.

  CLEAR : dyn_table.

  IF gt_fieldcat[] IS NOT INITIAL.
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = gt_fieldcat
        i_length_in_byte          = 'X'
      IMPORTING
        ep_table                  = dyn_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.
    IF sy-subrc = 0.
      ASSIGN dyn_table->* TO <ft_data>.
      CREATE DATA dyn_line LIKE LINE OF <ft_data>.
      ASSIGN dyn_line->* TO <fs_data>.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_AMOUNT
*&---------------------------------------------------------------------*
FORM f_calculate_amount  USING    fs_anla   TYPE anla
                         CHANGING fs_data   TYPE ty_data.

  DATA : ants      TYPE ants,
         t_anea    TYPE STANDARD TABLE OF anea,
         t_anep    TYPE STANDARD TABLE OF anep,
         t_anfm    TYPE STANDARD TABLE OF anfm,
         t_anlb    TYPE STANDARD TABLE OF anlb,
         t_anlc    TYPE STANDARD TABLE OF anlc,
         t_anlz    TYPE STANDARD TABLE OF anlz,
         t_anek    TYPE STANDARD TABLE OF anek,
         t_anlbza  TYPE STANDARD TABLE OF anlbza,

         lt_anea   TYPE STANDARD TABLE OF anea,
         lt_anep   TYPE STANDARD TABLE OF anep,
         lt_anfm   TYPE STANDARD TABLE OF anfm,
         lt_anlb   TYPE STANDARD TABLE OF anlb,
         lt_anlc   TYPE STANDARD TABLE OF anlc,
         lt_anlz   TYPE STANDARD TABLE OF anlz,
         lt_anek   TYPE STANDARD TABLE OF anek,
         lt_anlbza TYPE STANDARD TABLE OF anlbza,
         lt_xpost  TYPE STANDARD TABLE OF ty_dpost,
         lt_dpost  TYPE STANDARD TABLE OF fiaa_dpost,

         s_anlcv   TYPE anlcv,
         ls_anla   TYPE anla,
         ls_anep   LIKE LINE OF t_anep,
         ls_itab   LIKE LINE OF itab_data,
         ls_xpost  LIKE LINE OF lt_xpost,
         ls_dpost  LIKE LINE OF lt_dpost.

  DATA : lv_peraf   TYPE fiaa_dpost-peraf.

  MOVE-CORRESPONDING fs_anla TO ants.
  t_anea[]   = gt_anea[].
  t_anep[]   = gt_anep[].
  t_anlb[]   = gt_anlb[].
  t_anlc[]   = gt_anlc[].
  t_anlz[]   = gt_anlz[].
  t_anek[]   = gt_anek[].
  t_anlbza[] = gt_anlbza[].

  DELETE t_anea WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anep WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anek WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anlb WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anlc WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anlz WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE t_anlbza WHERE anln1 <> fs_anla-anln1
                     OR anln2 <> fs_anla-anln2.

*  lt_anlb[] = t_anlb[].
*  lt_anlc[] = t_anlc[].
*  lt_anep[] = t_anep[].
*  lt_anea[] = t_anea[].
*  lt_anek[] = t_anek[].
*  lt_anfm[] = t_anfm[].
*  lt_anlbza[] = t_anlbza[].

  CLEAR ls_itab.
  READ TABLE itab_data INTO ls_itab
                       WITH KEY anln1 = fs_anla-anln1
                                anln2 = fs_anla-anln2.

  lt_xpost[] = gt_dpost[].
  DELETE lt_xpost WHERE anln1 <> fs_anla-anln1
                     OR anln2 <> fs_anla-anln2.
  LOOP AT lt_xpost INTO ls_xpost.
    MOVE-CORRESPONDING ls_xpost TO ls_dpost.
    APPEND ls_dpost TO lt_dpost.
    CLEAR ls_dpost.
  ENDLOOP.

  lv_peraf  = pa_bdatu+4(2).

  CLEAR ls_dpost.
  READ TABLE lt_dpost INTO ls_dpost
                      WITH KEY peraf = lv_peraf
                               xfeld = 'X'.
  IF sy-subrc = 0.
    fs_data-icon  = icon_led_green.
  ELSE.
    fs_data-icon  = icon_led_yellow.

    CALL FUNCTION 'ZFFM_ASSET'
      EXPORTING
        ants     = ants
        i_datbis = pa_bdatu
      IMPORTING
        e_anlcv  = s_anlcv
      TABLES
        t_anea   = t_anea
        t_anep   = t_anep
        t_anfm   = t_anfm
        t_anlb   = t_anlb
        t_anlc   = t_anlc
        t_anlz   = t_anlz
        t_anlbza = t_anlbza.
  ENDIF.

  PERFORM f_validate_amount TABLES t_anlb lt_dpost
                            USING s_anlcv fs_anla ls_itab
                            CHANGING fs_data.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_AMOUNT
*&---------------------------------------------------------------------*
FORM f_validate_amount  TABLES   ft_anlb   STRUCTURE anlb
                                 ft_dpost  STRUCTURE fiaa_dpost
                        USING    s_anlcv   TYPE anlcv
                                 fs_anla   TYPE anla
                                 fs_itab   TYPE fiaa_salvtab_ragafa
                        CHANGING fs_data   TYPE ty_data.
  DATA : ls_anlc  TYPE anlc,
         ls_dpost TYPE fiaa_dpost.

  DATA : lv_peraf         TYPE fiaa_dpost-peraf,
         lv_gjahr         TYPE anlc-gjahr,
         lv_nafaz         TYPE fiaa_dpost-nafaz,
         lv_depmo         TYPE fiaa_dpost-nafaz,
         lv_month         TYPE p DECIMALS 0,
         lv_fieldname(30).

  FIELD-SYMBOLS : <fs>  TYPE any.

  lv_peraf = pa_bdatu+4(2).
  lv_gjahr = pa_bdatu+4 - 1.

  IF fs_itab-btr4 = 0.
    fs_data-nbval = s_anlcv-bchwrt_gje.
  ELSE.
    fs_data-nbval = fs_itab-btr4.
  ENDIF.

  CLEAR ls_anlc.
  READ TABLE gt_xanlc INTO ls_anlc
                      WITH KEY anln1 = fs_data-anln1
                               anln2 = fs_data-anln2
                               gjahr = lv_gjahr.
  IF sy-subrc = 0.
    fs_data-adely = ls_anlc-nafag.
  ENDIF.

  CLEAR : lv_depmo.
  LOOP AT ft_dpost INTO ls_dpost.
    lv_fieldname = |{ 'FS_DATA-DEP' }{ ls_dpost-peraf }|.
    ASSIGN (lv_fieldname) TO <fs>.
    <fs> = ls_dpost-nafaz.
    IF ls_dpost-peraf = lv_peraf.
      lv_depmo = ls_dpost-nafaz.
    ENDIF.
    IF ls_dpost-xfeld IS NOT INITIAL.
      ADD ls_dpost-nafaz TO lv_nafaz.
    ENDIF.
  ENDLOOP.

  fs_data-adecu = lv_nafaz.

  READ TABLE ft_dpost INTO ls_dpost
                      WITH KEY peraf = lv_peraf.
  IF sy-subrc = 0.
    IF ls_dpost-xfeld = 'X'.
    ELSE.
      IF fs_data-nbval = 0.
        CLEAR : fs_data-icon.
      ENDIF.
    ENDIF.
  ELSE.
    IF fs_data-nbval = 0.
      CLEAR : fs_data-icon.
    ENDIF.
  ENDIF.

  CASE fs_data-afasl.
    WHEN 'Z100'.
      lv_month = fs_data-ndjar * 12.
      TRY.
          fs_data-depmo = fs_data-answl / lv_month.
        CATCH cx_sy_zerodivide.
      ENDTRY.
    WHEN OTHERS.
      fs_data-depmo = lv_depmo.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TITLE
*&---------------------------------------------------------------------*
FORM f_change_title  USING    fu_scrtext_l fu_scrtext_m fu_scrtext_s
                     CHANGING fc_scrtext_l fc_scrtext_m fc_scrtext_s.
  fc_scrtext_l  = fu_scrtext_l.
  fc_scrtext_m  = fu_scrtext_m.
  fc_scrtext_s  = fu_scrtext_s.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PARAMETER_ID
*&---------------------------------------------------------------------*
FORM f_parameter_id  USING    fu_parid fu_value.
  DATA : user_parameters TYPE STANDARD TABLE OF usparam,
         ls_usparam      TYPE usparam.

  CALL FUNCTION 'SUSR_USER_PARAMETERS_GET'
    EXPORTING
      user_name           = sy-uname
    TABLES
      user_parameters     = user_parameters
    EXCEPTIONS
      user_name_not_exist = 1
      OTHERS              = 2.

  IF sy-subrc = 0.
    DELETE user_parameters WHERE parid = fu_parid.

    IF fu_value IS NOT INITIAL.
      ls_usparam-parid = 'BUK'.
      ls_usparam-parva = fu_value.
      APPEND ls_usparam TO user_parameters.
    ENDIF.

    CALL FUNCTION 'SUSR_USER_PARAMETERS_PUT'
      EXPORTING
        user_name           = sy-uname
      TABLES
        user_parameters     = user_parameters
      EXCEPTIONS
        user_name_not_exist = 1
        OTHERS              = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'SUSR_USER_BUFFERS_TO_DB'
        EXCEPTIONS
          no_logondata_for_new_user = 1
          no_init_password          = 2
          db_insert_usr02_failed    = 3
          db_update_usr02_failed    = 4
          db_insert_usr01_failed    = 5
          db_update_usr01_failed    = 6
          db_insert_usr05_failed    = 7
          db_update_usr05_failed    = 8
          db_insert_usr21_failed    = 9
          db_update_usr21_failed    = 10
          internal_error            = 11
          OTHERS                    = 12.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALL_AR25
*&---------------------------------------------------------------------*
FORM f_call_ar25  TABLES   itab_data STRUCTURE fiaa_salvtab_ragafa
                  USING    fu_anln1 fu_anln2 fu_afblpe fu_bdatu fu_srtvr.
  DATA : lr_data TYPE REF TO data,
         ls_data TYPE REF TO data,
         ls_itab LIKE LINE OF itab_data.

  DATA : lv_field(30),
         lv_component(30),
         lv_count         TYPE c LENGTH 2.

  FIELD-SYMBOLS : <ft_data> TYPE STANDARD TABLE,
                  <fs_data> TYPE any,
                  <fs>      TYPE any,
                  <fs1>     TYPE any.

  cl_salv_bs_runtime_info=>set(
    EXPORTING display  = abap_false
              metadata = abap_false
              data     = abap_true ).

  SUBMIT ragafa_alv01
    WITH bukrs-low    EQ pa_bukrs
    WITH anlage       EQ fu_anln1
    WITH afblpe       EQ fu_afblpe
    WITH berdatum     EQ fu_bdatu
    WITH bereich1     EQ pa_afabe
    WITH srtvr        EQ fu_srtvr
    WITH xeinzel      EQ 'X'
    AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
        IMPORTING r_data = lr_data ).
      ASSIGN lr_data->* TO <ft_data>.
      IF <ft_data> IS ASSIGNED.
        CREATE DATA ls_data LIKE LINE OF <ft_data>.
        ASSIGN ls_data->* TO <fs_data>.
      ENDIF.
    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.

  IF <ft_data> IS ASSIGNED.
    LOOP AT <ft_data> ASSIGNING <fs_data>.
      ASSIGN COMPONENT 'ANLN1' OF STRUCTURE <fs_data> TO <fs>.
      ls_itab-anln1 = <fs>.
      ASSIGN COMPONENT 'ANLN2' OF STRUCTURE <fs_data> TO <fs>.
      ls_itab-anln2 = <fs>.
      IF ls_itab-anln1 = fu_anln1 AND
        ls_itab-anln2 = fu_anln2.
        DO 25 TIMES.
          ADD 1 TO lv_count.
          lv_component = |{ 'BTR' }{ lv_count }|.
          lv_field     = |{ 'LS_ITAB-' }{ lv_component }|.
          ASSIGN (lv_field) TO <fs1>.
          ASSIGN COMPONENT lv_component OF STRUCTURE <fs_data> TO <fs>.
          <fs1> = <fs>.
        ENDDO.
        APPEND ls_itab TO itab_data.
        CLEAR : ls_data, lv_count.
      ENDIF.
    ENDLOOP.
    CLEAR : <ft_data>[].
    UNASSIGN <ft_data>.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_DATA
*&---------------------------------------------------------------------*
FORM f_get_payment_data USING    fu_anln1 fu_anln2 fu_lifnr fu_aktiv
                        CHANGING fs_data   TYPE ty_data.
  DATA : lt_xanek TYPE STANDARD TABLE OF anek,
         lt_xbseg TYPE STANDARD TABLE OF bseg,
         lt_xanla TYPE STANDARD TABLE OF anla,
         ls_xanek TYPE anek,
         ls_xbseg TYPE bseg,
         ls_ybseg TYPE bseg,
         ls_zbseg TYPE bseg,
         ls_lfa1  TYPE lfa1,
         ls_ekbe  TYPE ekbe.

  DATA : lv_lifnr TYPE lfa1-lifnr,
         lv_belnr TYPE bseg-belnr,
         lv_gjahr TYPE bseg-gjahr.

  IF fu_anln1 IS NOT INITIAL.
    READ TABLE gt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = fu_lifnr.
    IF sy-subrc = 0.
      fs_data-lifnr = ls_lfa1-lifnr.
      fs_data-name1 = ls_lfa1-name1.
    ENDIF.

    lt_xanek[] = gt_xanek[].
    DELETE lt_xanek WHERE anln1 <> fu_anln1
                       OR anln2 <> fu_anln2.
    DELETE lt_xanek WHERE budat <> fu_aktiv.
    READ TABLE lt_xanek INTO ls_xanek INDEX 1.
    IF ls_xanek-ebeln IS NOT INITIAL.
      LOOP AT lt_xanek INTO ls_xanek.
        CLEAR ls_ekbe.
        READ TABLE gt_ekbe INTO ls_ekbe
                           WITH KEY ebeln = ls_xanek-ebeln
                                    lfbnr = ls_xanek-belnr.
        IF sy-subrc = 0.
          CLEAR ls_xbseg.
          READ TABLE gt_bseg INTO ls_xbseg
                             WITH KEY belnr = ls_ekbe-belnr
                                      gjahr = ls_ekbe-gjahr
                                      koart = 'K'.
          IF sy-subrc = 0.
            fs_data-belnr = ls_xbseg-augbl.
            fs_data-budat = ls_xbseg-augdt.
            CLEAR ls_lfa1.
            READ TABLE gt_lfa1 INTO ls_lfa1
                               WITH KEY lifnr = ls_xbseg-lifnr.
            IF sy-subrc = 0.
              fs_data-lifnr = ls_lfa1-lifnr.
              fs_data-name1 = ls_lfa1-name1.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT gt_bseg INTO ls_xbseg WHERE belnr = ls_xanek-belnr
                                      AND gjahr = ls_xanek-gjahr
                                      AND augbl <> space.
        LOOP AT gt_bseg INTO ls_ybseg WHERE augbl = ls_xbseg-augbl
                                        AND gjahr = ls_xbseg-gjahr.
          LOOP AT gt_bseg INTO ls_zbseg WHERE belnr = ls_ybseg-belnr
                                          AND gjahr = ls_ybseg-gjahr.
            IF ls_zbseg-koart = 'K'.
              fs_data-belnr = ls_zbseg-augbl.
              fs_data-budat = ls_zbseg-augdt.
              CLEAR ls_lfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY lifnr = ls_zbseg-lifnr.
              IF sy-subrc = 0.
                fs_data-lifnr = ls_lfa1-lifnr.
                fs_data-name1 = ls_lfa1-name1.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        CLEAR ls_xbseg.
      ENDLOOP.
    ENDIF.
  ELSE.
    PERFORM f_fi_documentx.

    lt_xbseg[] = gt_bseg[].
    DELETE lt_xbseg WHERE koart <> 'K'.
    DELETE ADJACENT DUPLICATES FROM lt_xbseg COMPARING lifnr.
    IF lt_xbseg[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_xbseg
        WHERE lifnr = lt_xbseg-lifnr.
    ENDIF.

    lt_xanla[] = gt_anla[].
    DELETE lt_xanla WHERE lifnr = space.
    DELETE ADJACENT DUPLICATES FROM lt_xanla COMPARING lifnr.
    IF lt_xanla[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_xanla
        WHERE lifnr = lt_xanla-lifnr.
    ENDIF.

    SORT gt_lfa1 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM gt_lfa1 COMPARING lifnr.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_double_click  USING    fu_row fu_column.
  DATA : ls_data    LIKE LINE OF gt_data.

  READ TABLE gt_data INTO ls_data INDEX fu_row.
  CASE fu_column.
    WHEN 'BELNR'.
      SET PARAMETER ID 'BLN' FIELD ls_data-belnr.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD pa_bdatu(4).
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    WHEN 'ANLN1' OR 'ANLN2'.
      SET PARAMETER ID 'AN1' FIELD ls_data-anln1.
      SET PARAMETER ID 'AN2' FIELD ls_data-anln2.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      CALL TRANSACTION 'AS03' AND SKIP FIRST SCREEN.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FI_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_fi_document TABLES   ft_anek   STRUCTURE anek.
  DATA : lt_bsik  TYPE STANDARD TABLE OF bsik.

  SELECT *
    FROM bsas
    INTO CORRESPONDING FIELDS OF TABLE gt_bsas1
    FOR ALL ENTRIES IN ft_anek
    WHERE bukrs = pa_bukrs
      AND belnr = ft_anek-belnr
      AND gjahr = ft_anek-gjahr
  ORDER BY PRIMARY KEY.
  DELETE ADJACENT DUPLICATES FROM gt_bsas1 COMPARING bukrs augbl gjahr.

  IF gt_bsas1[] IS NOT INITIAL.
    SELECT *
      FROM bsas
      INTO CORRESPONDING FIELDS OF TABLE gt_bsas2
      FOR ALL ENTRIES IN gt_bsas1
      WHERE bukrs = pa_bukrs
        AND augbl = gt_bsas1-augbl
        AND gjahr = gt_bsas1-gjahr
        AND shkzg = 'S'
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF gt_bsas2[] IS NOT INITIAL.
    SELECT *
      FROM bsik
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_bsas2
      WHERE bukrs = pa_bukrs
        AND gjahr = gt_bsas2-gjahr
        AND belnr = gt_bsas2-belnr
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_bsas2
      WHERE bukrs = pa_bukrs
        AND gjahr = gt_bsas2-gjahr
        AND belnr = gt_bsas2-belnr
      ORDER BY PRIMARY KEY.

    lt_bsik[] = gt_bsik[].
    SORT lt_bsik BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING lifnr.
    IF lt_bsik[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_bsik
        WHERE lifnr = lt_bsik-lifnr.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MIGO_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_migo_document  TABLES   ft_anek  STRUCTURE anek.
  DATA : lt_bsik  TYPE STANDARD TABLE OF bsik.

  SELECT *
    FROM ekbe JOIN rbkp ON ekbe~belnr = rbkp~belnr
                       AND ekbe~gjahr = rbkp~gjahr
    INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
    FOR ALL ENTRIES IN ft_anek
    WHERE ebeln = ft_anek-ebeln
      AND bewtp = 'Q'
      AND stblg = space.

  IF gt_ekbe[] IS NOT INITIAL.
    SELECT *
      FROM bsik
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_ekbe
      WHERE bukrs = pa_bukrs
        AND gjahr = gt_ekbe-gjahr
        AND belnr = gt_ekbe-belnr
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
      FOR ALL ENTRIES IN gt_ekbe
      WHERE bukrs = pa_bukrs
        AND gjahr = gt_ekbe-gjahr
        AND belnr = gt_ekbe-belnr
      ORDER BY PRIMARY KEY.

    lt_bsik[] = gt_bsik[].
    SORT lt_bsik BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING lifnr.
    IF lt_bsik[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_bsik
        WHERE lifnr = lt_bsik-lifnr.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_DATA_NEW
*&---------------------------------------------------------------------*
FORM f_get_payment_data_new  USING    fu_anln1 fu_anln2 fu_lifnr fu_aktiv
                             CHANGING fs_data   TYPE ty_data.
  DATA : lt_xanek TYPE STANDARD TABLE OF anek,
         lt_yanek TYPE STANDARD TABLE OF anek,
         lt_bsik  TYPE STANDARD TABLE OF bsik,
         ls_xanek TYPE anek,
         ls_bsas1 TYPE bsis,
         ls_bsas2 TYPE bsis,
         ls_bsik  TYPE bsik,
         ls_lfa1  TYPE lfa1,
         ls_ekbe  TYPE ekbe,
         ls_bkpf  TYPE bkpf.

  DATA : lv_gjahr TYPE bkpf-gjahr.

  IF fu_anln1 IS INITIAL.
    lt_xanek[] = lt_yanek[] = gt_xanek[].
    DELETE lt_xanek WHERE tcode = 'FB01'.
    DELETE lt_yanek WHERE tcode = 'MIGO_GR'.

    IF lt_yanek[] IS NOT INITIAL.
      PERFORM f_fi_document TABLES lt_yanek.
    ENDIF.

    IF lt_xanek[] IS NOT INITIAL.
      PERFORM f_migo_document TABLES lt_xanek.
    ENDIF.

    lt_bsik[] = gt_bsik[].
    SORT lt_bsik BY bukrs augbl gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING bukrs augbl gjahr.
    IF lt_bsik[] IS NOT INITIAL.
      SELECT *
        FROM bkpf
        INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
        FOR ALL ENTRIES IN lt_bsik
        WHERE bukrs = lt_bsik-bukrs
          AND belnr = lt_bsik-augbl
          AND gjahr = lt_bsik-gjahr.
    ENDIF.
  ELSE.
    IF fu_lifnr IS NOT INITIAL.
      CLEAR ls_lfa1.
      READ TABLE gt_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = fu_lifnr.
      IF sy-subrc = 0.
        fs_data-name1 = ls_lfa1-name1.
      ENDIF.
    ENDIF.

    lt_xanek[] = gt_xanek[].
    DELETE lt_xanek WHERE anln1 <> fu_anln1
                       OR anln2 <> fu_anln2.
* Command ANEK
*****    DELETE lt_xanek WHERE budat <> fu_aktiv.
    SORT lt_xanek BY budat.
    READ TABLE lt_xanek INTO ls_xanek INDEX 1.
    IF sy-subrc = 0.
      CASE ls_xanek-tcode.
        WHEN 'FB01'.
          CLEAR ls_bsas1.
          READ TABLE gt_bsas1 INTO ls_bsas1
                              WITH KEY belnr = ls_xanek-belnr
                                       gjahr = ls_xanek-gjahr.
          IF sy-subrc = 0.
            CLEAR ls_bsas2.
            READ TABLE gt_bsas2 INTO ls_bsas2
                                WITH KEY augbl = ls_bsas1-augbl
                                         gjahr = ls_bsas1-gjahr.
            IF sy-subrc = 0.
              CLEAR ls_bsik.
              READ TABLE gt_bsik INTO ls_bsik
                                 WITH KEY gjahr = ls_bsas2-gjahr
                                          belnr = ls_bsas2-belnr.
              IF sy-subrc = 0.
                fs_data-lifnr = ls_bsik-lifnr.
                CLEAR ls_lfa1.
                READ TABLE gt_lfa1 INTO ls_lfa1
                                   WITH KEY lifnr = ls_bsik-lifnr.
                IF sy-subrc = 0.
                  fs_data-name1 = ls_lfa1-name1.
                ENDIF.
                fs_data-belnr = ls_bsik-augbl.
                fs_data-budat = ls_bsik-augdt.
                lv_gjahr = ls_bsik-gjahr.
              ENDIF.
            ENDIF.
          ENDIF.
        WHEN 'MIGO_GR'.
          LOOP AT lt_xanek INTO ls_xanek.
            CLEAR : ls_ekbe.
            READ TABLE gt_ekbe INTO ls_ekbe
                               WITH KEY ebeln = ls_xanek-ebeln
                                        lfbnr = ls_xanek-belnr.
            IF sy-subrc = 0.
              CLEAR ls_bsik.
              READ TABLE gt_bsik INTO ls_bsik
                                 WITH KEY gjahr = ls_ekbe-gjahr
                                          belnr = ls_ekbe-belnr.
              IF sy-subrc = 0.
                fs_data-lifnr = ls_bsik-lifnr.
                CLEAR ls_lfa1.
                READ TABLE gt_lfa1 INTO ls_lfa1
                                   WITH KEY lifnr = ls_bsik-lifnr.
                IF sy-subrc = 0.
                  fs_data-name1 = ls_lfa1-name1.
                ENDIF.
                fs_data-belnr = ls_bsik-augbl.
                fs_data-budat = ls_bsik-augdt.
                lv_gjahr = ls_bsik-gjahr.
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    ENDIF.
    CLEAR ls_bkpf.
    READ TABLE gt_bkpf INTO ls_bkpf
                       WITH KEY belnr = fs_data-belnr
                                gjahr = lv_gjahr.
    IF sy-subrc = 0.
      fs_data-xblnr = ls_bkpf-xblnr.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FI_DOCUMENTX
*&---------------------------------------------------------------------*
FORM f_fi_documentx .
  DATA : lt_xanek TYPE STANDARD TABLE OF anek,
         lt_yanek TYPE STANDARD TABLE OF anek,
         lt_ekbe  TYPE STANDARD TABLE OF ekbe,
         lt_xbseg TYPE STANDARD TABLE OF bseg.

  lt_yanek[] = lt_xanek[] = gt_anek[].
  DELETE lt_xanek WHERE ebeln <> space.
  DELETE ADJACENT DUPLICATES FROM lt_xanek COMPARING belnr.
  DELETE lt_yanek WHERE ebeln = space.
  DELETE ADJACENT DUPLICATES FROM lt_yanek COMPARING ebeln.

  IF lt_xanek[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg
      FOR ALL ENTRIES IN lt_xanek
      WHERE bukrs = pa_bukrs
        AND belnr = lt_xanek-belnr
        AND gjahr = lt_xanek-gjahr.

    lt_xbseg[] = gt_bseg[].
    SORT lt_xbseg BY augbl.
    DELETE lt_xbseg WHERE augbl = space.
    DELETE ADJACENT DUPLICATES FROM lt_xbseg COMPARING augbl.
    IF lt_xbseg[] IS NOT INITIAL.
      SELECT *
        FROM bseg
        APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg
        FOR ALL ENTRIES IN lt_xbseg
        WHERE bukrs = pa_bukrs
          AND augbl = lt_xbseg-augbl
          AND gjahr = lt_xbseg-gjahr.
    ENDIF.

    lt_xbseg[] = gt_bseg[].
    SORT lt_xbseg BY belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_xbseg COMPARING belnr gjahr.
    IF lt_xbseg[] IS NOT INITIAL.
      SELECT *
        FROM bseg
        APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg
        FOR ALL ENTRIES IN lt_xbseg
        WHERE bukrs = pa_bukrs
          AND belnr = lt_xbseg-belnr
          AND gjahr = lt_xbseg-gjahr.
    ENDIF.
  ENDIF.

  IF lt_yanek[] IS NOT INITIAL.
    SELECT *
      FROM ekbe JOIN rbkp ON ekbe~belnr = rbkp~belnr
                         AND ekbe~gjahr = rbkp~gjahr
      INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
      FOR ALL ENTRIES IN lt_yanek
      WHERE ebeln = lt_yanek-ebeln
        AND bewtp = 'Q'
        AND stblg = space.

*    lt_ekbe[] = gt_ekbe[].
*    SORT lt_ekbe BY ebeln lfbnr.
*    DELETE ADJACENT DUPLICATES FROM lt_ekbe COMPARING ebeln lfbnr.
*    IF lt_ekbe[] IS NOT INITIAL.
*      SELECT *
*        FROM mseg
*        INTO CORRESPONDING FIELDS OF TABLE gt_mseg
*        FOR ALL ENTRIES IN lt_ekbe
*        WHERE ebeln = lt_ekbe-ebeln
*          AND mjahr = lt_ekbe-gjahr
*          AND lfbnr = lt_ekbe-lfbnr.
*    ENDIF.

    lt_ekbe[] = gt_ekbe[].
    DELETE ADJACENT DUPLICATES FROM lt_ekbe COMPARING belnr.
    IF lt_ekbe[] IS NOT INITIAL.
      SELECT *
        FROM bseg
        APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg
        FOR ALL ENTRIES IN lt_ekbe
        WHERE bukrs = pa_bukrs
          AND belnr = lt_ekbe-belnr
          AND gjahr = lt_ekbe-gjahr.
    ENDIF.
  ENDIF.

  SORT gt_bseg BY bukrs belnr gjahr buzei.
  DELETE ADJACENT DUPLICATES FROM gt_bseg COMPARING bukrs belnr gjahr buzei.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHOW_POST_DEPR
*&---------------------------------------------------------------------*
FORM f_show_post_depr  TABLES   ft_dpost TYPE STANDARD TABLE "STRUCTURE fiaa_dpost
                                ft_anlb STRUCTURE anlb
                                ft_anlc STRUCTURE anlc
                                ft_anep STRUCTURE anep
                                ft_anea STRUCTURE anea
                                ft_anek STRUCTURE anek
                                ft_anfm STRUCTURE anfm
                                ft_anlbza STRUCTURE anlbza
                       USING    fs_anla TYPE anla
                                fu_proc
                       CHANGING fc_post.

  DATA : lt_dpost TYPE STANDARD TABLE OF fiaa_dpost,
         ls_dpost LIKE LINE OF lt_dpost,
         ls_xpost TYPE ty_dpost.

  DATA : lv_peraf   TYPE fiaa_dpost-peraf.

  CLEAR fc_post.

  IF fu_proc IS NOT INITIAL.
    CALL FUNCTION 'AM_SHOW_POST_DEPR'
      EXPORTING
        i_anla                 = fs_anla
        i_afabe                = pa_afabe
        i_gjahr                = pa_bdatu(4)
      TABLES
        t_dpost                = lt_dpost
        t_anlb                 = ft_anlb
        t_anlc                 = ft_anlc
        t_anep                 = ft_anep
        t_anea                 = ft_anea
        t_anek                 = ft_anek
        t_anfm                 = ft_anfm
        t_anlbza               = ft_anlbza
      EXCEPTIONS
        not_found              = 1
        differences_posted_afa = 2
        OTHERS                 = 3.

    READ TABLE lt_dpost INTO ls_dpost
                        WITH KEY peraf = lv_peraf.
    IF sy-subrc = 0.
      fc_post = 'X'.
    ENDIF.

    LOOP AT lt_dpost INTO ls_dpost.
      MOVE-CORRESPONDING ls_dpost TO ls_xpost.
      ls_xpost-anln1 = fs_anla-anln1.
      ls_xpost-anln2 = fs_anla-anln2.
      APPEND ls_xpost TO ft_dpost.
      CLEAR ls_xpost.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data  TABLES   ft_anlb STRUCTURE anlb
                              ft_anlc STRUCTURE anlc
                              ft_anep STRUCTURE anep
                              ft_anea STRUCTURE anea
                              ft_anek STRUCTURE anek
                              ft_anfm STRUCTURE anfm
                              ft_anlbza STRUCTURE anlbza
                     USING    fs_anla TYPE anla.

  CLEAR : ft_anea[], ft_anep[], ft_anlb[], ft_anlc[], ft_anek[], ft_anlbza[].

  ft_anea[]   = gt_anea[].
  ft_anep[]   = gt_anep[].
  ft_anlb[]   = gt_anlb[].
  ft_anlc[]   = gt_anlc[].
  ft_anek[]   = gt_anek[].
  ft_anlbza[] = gt_anlbza[].

  DELETE ft_anea WHERE anln1 <> fs_anla-anln1
                    OR anln2 <> fs_anla-anln2.
  DELETE ft_anep WHERE anln1 <> fs_anla-anln1
                    OR anln2 <> fs_anla-anln2.
  DELETE ft_anek WHERE anln1 <> fs_anla-anln1
                   OR anln2 <> fs_anla-anln2.
  DELETE ft_anlb WHERE anln1 <> fs_anla-anln1
                    OR anln2 <> fs_anla-anln2.
  DELETE ft_anlc WHERE anln1 <> fs_anla-anln1
                    OR anln2 <> fs_anla-anln2.
  DELETE ft_anlbza WHERE anln1 <> fs_anla-anln1
                      OR anln2 <> fs_anla-anln2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_F4_HELP
*&---------------------------------------------------------------------*
FORM f_f4_help  USING    fu_field.
  TYPES : BEGIN OF ty_anla,
            bukrs TYPE anla-bukrs,
            anlkl TYPE anla-anlkl,
            mcoa1 TYPE anla-mcoa1,
            ktogr TYPE anla-ktogr,
            aktiv TYPE anla-aktiv,
            anln1 TYPE anla-anln1,
            anln2 TYPE anla-anln2,
          END OF ty_anla.

  TYPES : BEGIN OF ty_ankt,
            anlkl TYPE ankt-anlkl,
            txk20 TYPE ankt-txk20,
          END OF ty_ankt.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab,
         lt_anla    TYPE STANDARD TABLE OF ty_anla,
         lt_ankt    TYPE STANDARD TABLE OF ty_ankt,
         ls_anla    LIKE LINE OF lt_anla.

  DATA : lv_bukrs     TYPE t001-bukrs,
         lv_anlkl     TYPE ankl-anlkl,
         lv_subrc     TYPE sy-subrc,
         lv_field(30).

  PERFORM f_dynp_value_read USING 'PA_BUKRS' ''
                            CHANGING lv_bukrs.

  PERFORM f_dynp_value_read USING 'SO_ANLKL-LOW' 'X'
                            CHANGING lv_anlkl.

  CLEAR lt_anla[].
  CASE fu_field.
    WHEN 'SO_ANLKL-LOW'.
      SELECT *
        FROM ankt
        INTO CORRESPONDING FIELDS OF TABLE lt_ankt
        WHERE spras = sy-langu.

      ASSIGN lt_ankt[] TO <fs_tab>.
      CLEAR lv_subrc.
      PERFORM f_value_request TABLES return_tab
                              USING fu_field+3(5) fu_field
                              CHANGING lv_subrc.

    WHEN 'SO_ANLKL-HIGH'.
      SELECT *
        FROM ankt
        INTO CORRESPONDING FIELDS OF TABLE lt_ankt
        WHERE spras = sy-langu.

      ASSIGN lt_ankt[] TO <fs_tab>.
      CLEAR lv_subrc.
      PERFORM f_value_request TABLES return_tab
                              USING fu_field+3(5) fu_field
                              CHANGING lv_subrc.

    WHEN OTHERS.
      SELECT *
        FROM m_aanla
        INTO CORRESPONDING FIELDS OF TABLE lt_anla
        WHERE bukrs = lv_bukrs
          AND anlkl = lv_anlkl.

      ASSIGN lt_anla[] TO <fs_tab>.

      CLEAR lv_subrc.
      PERFORM f_value_request TABLES return_tab
                              USING fu_field+3(5) fu_field
                              CHANGING lv_subrc.
*      IF lv_subrc = 0.
*        READ TABLE return_tab INTO ls_return INDEX 1.
*        IF sy-subrc = 0.
*          CLEAR ls_anla.
*          READ TABLE lt_anla INTO ls_anla
*                             WITH KEY anln1 = ls_return-fieldval.
*          IF sy-subrc = 0.
*            PERFORM f_dynpfield TABLES dynpfields
*                                USING fu_field ls_anla-anln1 ''.
*            lv_field = fu_field.
*            TRANSLATE lv_field USING '12'.
*            PERFORM f_dynpfield TABLES dynpfields
*                                USING lv_field ls_anla-anln2 ''.
*          ENDIF.
*          PERFORM f_dyn_values_update.
*        ENDIF.
*      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname fu_routine
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
        IF fu_routine IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_dynpfields-fieldvalue
            IMPORTING
              output = fc_value.
        ELSE.
          fc_value  = ls_dynpfields-fieldvalue.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = fu_retfield
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = fu_dynprofield
      value_org   = 'S'
    TABLES
      value_tab   = <fs_tab>
      return_tab  = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
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
ENDFORM.

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
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONCATENATE_MONTH
*&---------------------------------------------------------------------*
FORM f_concatenate_month  TABLES   ft_t247    STRUCTURE t247
                          USING    fu_month fu_gjahr
                          CHANGING fc_l fc_m fc_s.
  DATA : ls_t247    TYPE t247.

  READ TABLE ft_t247 INTO ls_t247
                     WITH KEY mnr = fu_month+1(2).
  IF sy-subrc = 0.
    fc_l = |{ 'Deprc.' } { ls_t247-ktx } { fu_gjahr }|.
    fc_m = |{ 'Deprc.' } { ls_t247-ktx } { fu_gjahr }|.
    fc_s = |{ 'Deprc.' } { ls_t247-ktx } { fu_gjahr }|.
  ENDIF.
ENDFORM.
