*&---------------------------------------------------------------------*
*&  Include           ZFPAYROLLF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'SVK' '0' '',
                                      'PBT' '0' '',
                                      'PFL' '0' '',
                                      'SSP' '0' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SVK' '0' '',
                                      'PBT' '0' '',
                                      'PFL' '0' '',
                                      'SSP' '0' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'SVK' '0' '',
                                      'PGJ' '0' '',
                                      'PMO' '0' '',
                                      'SSP' '0' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'PBT' '0' '',
                                      'PFL' '0' '',
                                      'SSP' '0' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'PBT' '0' '',
                                      'PFL' '0' '',
                                      'PGJ' '0' '',
                                      'PMO' '0' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
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
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_monat IS INITIAL.
        PERFORM f_screen_error USING 'PMO' ''.
      ENDIF.
      IF pa_gjahr IS INITIAL.
        PERFORM f_screen_error USING 'PGJ' ''.
      ENDIF.

      PERFORM f_check_authorization USING '01'.

    WHEN radio2.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_vkbur IS INITIAL.
        PERFORM f_screen_error USING 'PVK' ''.
      ENDIF.
      IF pa_monat IS INITIAL.
        PERFORM f_screen_error USING 'PMO' ''.
      ENDIF.
      IF pa_gjahr IS INITIAL.
        PERFORM f_screen_error USING 'PGJ' ''.
      ENDIF.

      PERFORM f_check_authorization USING '02'.

    WHEN radio3.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_screen_error USING 'PBT' ''.
      ENDIF.
      IF pa_filnm IS INITIAL.
        PERFORM f_screen_error USING 'PFL' ''.
      ENDIF.

      PERFORM f_check_authorization USING '01'.

    WHEN radio4.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_monat IS INITIAL.
        PERFORM f_screen_error USING 'PMO' ''.
      ENDIF.
      IF pa_gjahr IS INITIAL.
        PERFORM f_screen_error USING 'PGJ' ''.
      ENDIF.

      PERFORM f_check_authorization USING '85'.

    WHEN radio5.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.

      PERFORM f_check_authorization USING '03'.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_mess.
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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CASE 'X'.
    WHEN radio1.
      SELECT SINGLE zcocd
        FROM zfgaji_company
        INTO gv_zcocd
        WHERE bukrs = pa_bukrs.

      SELECT *
        FROM zfgaji_proses
        INTO CORRESPONDING FIELDS OF TABLE gt_proses
        WHERE bukrs = pa_bukrs
          AND monat = pa_monat
          AND gjahr = pa_gjahr
          AND ztype = 'PAYB'.

      SELECT *
        FROM zfgaji_lokasi
        INTO CORRESPONDING FIELDS OF TABLE gt_lokasi
        WHERE ztype = 'PAYB'.

    WHEN radio3.
      SELECT *
        FROM zplbc
        INTO CORRESPONDING FIELDS OF TABLE gt_zplbc
        WHERE bukrs = pa_bukrs.

      SELECT *
        FROM zfgaji_company
        INTO CORRESPONDING FIELDS OF TABLE gt_company.

      SELECT *
        FROM zfgaji_lokasi
        INTO CORRESPONDING FIELDS OF TABLE gt_lokasi
        WHERE ztype = 'PAYB'.

      SELECT *
        FROM zfgaji_hkont
        INTO CORRESPONDING FIELDS OF TABLE gt_ghkont.

      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zfgaji_kostl
        INTO CORRESPONDING FIELDS OF TABLE gt_gkostl
        WHERE bukrs = pa_bukrs.

      SELECT *
        FROM zfgaji_proses
        INTO CORRESPONDING FIELDS OF TABLE gt_proses
        WHERE bukrs = pa_bukrs
          AND monat = pa_budat+4(2)
          AND gjahr = pa_budat(4)
          AND ztype = 'PAYB'.

      SELECT *
        FROM zfgaji_control
        INTO CORRESPONDING FIELDS OF TABLE gt_control
        WHERE bukrs = pa_bukrs.

    WHEN radio5.
      SELECT *
        FROM zfgaji_company
        INTO CORRESPONDING FIELDS OF TABLE gt_company.

      SELECT *
        FROM zfgaji_lokasi
        INTO CORRESPONDING FIELDS OF TABLE gt_lokasi
        WHERE ztype = 'PAYB'.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : filename      TYPE rlgrap-filename,
         lt_ghkont     TYPE STANDARD TABLE OF zfgaji_hkont INITIAL SIZE 0,
         lt_lokasi     TYPE STANDARD TABLE OF zfgaji_lokasi INITIAL SIZE 0,
         ls_proses     LIKE LINE OF gt_proses.

  DATA : lt_skat       TYPE STANDARD TABLE OF skat INITIAL SIZE 0.

  DATA : lv_spmon      TYPE bseg-abper.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_validasi_gaji USING pa_gjahr pa_monat.
    WHEN radio2.
      PERFORM f_validasi_gaji USING pa_gjahr pa_monat.
    WHEN radio3.
      filename  = pa_filnm.

      PERFORM f_download_fr_excel USING    filename.
      PERFORM f_get_bukrs_vkbur.
      IF gv_subrc IS INITIAL.
        PERFORM f_validasi_excel.

        lt_ghkont[] = gt_ghkont[].
        SORT lt_ghkont BY hkont.
        DELETE ADJACENT DUPLICATES FROM lt_ghkont COMPARING hkont.
        IF lt_ghkont[] IS NOT INITIAL.
          SELECT *
            FROM skat
            INTO CORRESPONDING FIELDS OF TABLE gt_skat
            FOR ALL ENTRIES IN lt_ghkont
            WHERE spras = sy-langu
              AND ktopl = 'TSPC'
              AND saknr = lt_ghkont-hkont.
        ENDIF.

        lt_ghkont[] = gt_ghkont[].
        SORT lt_ghkont BY hkont1.
        DELETE ADJACENT DUPLICATES FROM lt_ghkont COMPARING hkont1.
        IF lt_ghkont[] IS NOT INITIAL.
          SELECT *
            FROM skat
            APPENDING CORRESPONDING FIELDS OF TABLE gt_skat
            FOR ALL ENTRIES IN lt_ghkont
            WHERE spras = sy-langu
              AND ktopl = 'TSPC'
              AND saknr = lt_ghkont-hkont1.
        ENDIF.

        lt_lokasi[] = gt_lokasi[].
        SORT lt_lokasi BY hkont.
        DELETE ADJACENT DUPLICATES FROM lt_lokasi COMPARING hkont.
        IF lt_lokasi[] IS NOT INITIAL.
          SELECT *
            FROM skat
            APPENDING CORRESPONDING FIELDS OF TABLE gt_skat
            FOR ALL ENTRIES IN lt_lokasi
            WHERE spras = sy-langu
              AND ktopl = 'TSPC'
              AND saknr = lt_lokasi-hkont.
        ENDIF.
      ELSE.
        IF gv_subrc = 8.
          MESSAGE s000(zab) WITH 'Format excel salah' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

      lt_skat[] = gt_skat[].
      SORT lt_skat BY saknr.
      DELETE ADJACENT DUPLICATES FROM lt_skat COMPARING saknr.
      IF lt_skat[] IS NOT INITIAL.
        SELECT saknr xbilk
          FROM ska1
          INTO CORRESPONDING FIELDS OF TABLE gt_ska1
          FOR ALL ENTRIES IN lt_skat
          WHERE saknr = lt_skat-saknr.
      ENDIF.

    WHEN radio4.
      SELECT *
        FROM zfgaji_proses
        INTO CORRESPONDING FIELDS OF TABLE gt_reverse
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND monat = pa_monat
          AND gjahr = pa_gjahr
          AND post_belnr <> space.

    WHEN radio5.
      SELECT *
        FROM zfgaji_proses
        INTO CORRESPONDING FIELDS OF TABLE gt_proses
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur.

      LOOP AT gt_proses INTO ls_proses.
        CONCATENATE ls_proses-gjahr ls_proses-monat INTO lv_spmon.
        IF lv_spmon IN so_spmon.
          CONTINUE.
        ELSE.
          DELETE TABLE gt_proses FROM ls_proses.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lv_subrc    TYPE sy-subrc,
         ls_reverse  LIKE LINE OF gt_reverse,
         ls_proses   LIKE LINE OF gt_proses,
         ls_report   LIKE LINE OF gt_report,
         ls_company  LIKE LINE OF gt_company,
         ls_lokasi   LIKE LINE OF gt_lokasi.

  CASE 'X'.
    WHEN radio3.
      PERFORM f_prepare_posting.
      PERFORM f_posting USING 'SIMULATE'
                        CHANGING lv_subrc.
      PERFORM f_unlock_table.

    WHEN radio4.
      LOOP AT gt_reverse INTO ls_reverse.
        CLEAR : ls_reverse-rev_belnr.
        MODIFY gt_reverse FROM ls_reverse TRANSPORTING rev_belnr.
        CLEAR ls_reverse.
      ENDLOOP.

    WHEN radio5.
      LOOP AT gt_proses INTO ls_proses.
        ls_report-bukrs   = ls_proses-bukrs.
        READ TABLE gt_company INTO ls_company
                              WITH KEY bukrs = pa_bukrs.
        IF sy-subrc = 0.
          ls_report-zcocd   = ls_company-zcocd.
        ENDIF.
        ls_report-vkbur         = ls_proses-vkbur.
        ls_report-zloct         = ls_proses-zloct.
        ls_report-apv_user      = ls_proses-apv_user.
        ls_report-apv_date      = ls_proses-apv_date.
        ls_report-post_belnr    = ls_proses-post_belnr.
        ls_report-post_budat    = ls_proses-post_budat.
        ls_report-post_date     = ls_proses-post_date.
        ls_report-post_user     = ls_proses-post_user.
        ls_report-post_files    = ls_proses-post_files.
        ls_report-rev_belnr     = ls_proses-rev_belnr.
        ls_report-rev_user      = ls_proses-rev_user.
        ls_report-rev_budat     = ls_proses-rev_budat.
        APPEND ls_report TO gt_report.
        CLEAR ls_report.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio3.
      IF gt_error[] IS NOT INITIAL.
        MESSAGE s000(zab) WITH 'Masih ada data yang salah'
                          DISPLAY LIKE 'E'.
      ENDIF.

      TRY.
          cl_salv_table=>factory(
              EXPORTING
                list_display   = if_salv_c_bool_sap=>true
              IMPORTING
                r_salv_table   = gr_table
              CHANGING
                t_table        = gt_post ).
        CATCH cx_salv_data_error cx_salv_not_found.
      ENDTRY.

      gr_table->set_screen_status(
        pfstatus   = 'SALV_STANDARD'
        report     = gv_repid ).

      PERFORM f_set_function.
      PERFORM f_display_setting.
      PERFORM f_set_event.
      PERFORM f_set_sort  USING : 'ZLOCT' '1'.

*  PERFORM f_set_selection.

      PERFORM f_set_text USING : 'TXT50' '' '' '' '' '',
                                 'TEXT' 'Item Text' '' 'X' '' ''.

      gr_table->display( ).

    WHEN radio4.
      TRY.
          cl_salv_table=>factory(
              EXPORTING
                list_display   = if_salv_c_bool_sap=>true
              IMPORTING
                r_salv_table   = gr_table
              CHANGING
                t_table        = gt_reverse ).
        CATCH cx_salv_data_error cx_salv_not_found.
      ENDTRY.

      gr_table->set_screen_status(
        pfstatus   = 'SALV_STANDARD1'
        report     = gv_repid ).

      PERFORM f_set_function.
      PERFORM f_display_setting.
      PERFORM f_set_event.
      PERFORM f_set_selection.

      PERFORM f_set_text USING : 'POST_FILES' 'Filename' '' 'X' '' '50',
                                 'REV_BELNR' 'Rev.Doc.' '' 'X' '' '20',
                                 'ZLOCT' 'Location' '' 'X' '' '40'.

      gr_table->display( ).

    WHEN radio5.
      TRY.
          cl_salv_table=>factory(
              EXPORTING
                list_display   = if_salv_c_bool_sap=>true
              IMPORTING
                r_salv_table   = gr_table
              CHANGING
                t_table        = gt_report ).
        CATCH cx_salv_data_error cx_salv_not_found.
      ENDTRY.

      gr_table->set_screen_status(
        pfstatus   = 'SALV_STANDARD2'
        report     = gv_repid ).

      PERFORM f_set_function.
      PERFORM f_display_setting.
      PERFORM f_set_event.

      PERFORM f_set_text USING : 'ZLOCT' 'SOff Name' 'Desc' 'X' '' '20',
                                 'ZCOCD' 'Company Name' 'Desc' 'X' '' '20',
                                 'BUKRS' 'Company Code' 'CoCd' 'X' '' '5',
                                 'VKBUR' 'Sales Office' 'SOff' 'X' '' '5',
                                 'APV_USER' 'Approve User' 'ApprvUser' 'X' '' '10',
                                 'APV_DATE' 'Approve Date' 'ApprvDate' 'X' '' '10',
                                 'POST_FILES' 'Filename' '' 'X' '' '50',
                                 'POST_BELNR' 'Doc.Posting' '' 'X' '' '20',
                                 'POST_USER' 'PostUser' '' 'X' '' '10',
                                 'REV_BELNR' 'Rev.Doc.' '' 'X' '' '20',
                                 'REV_BUDAT' 'Rev.Date' '' 'X' '' '10',
                                 'REV_USER' 'Rev.User' '' 'X' '' '10',
                                 'POST_DATE' 'ProcDate' '' 'X' '' '10'.

      gr_table->display( ).
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_SET_FUNCTION
*&---------------------------------------------------------------------*
FORM f_set_function .
  DATA : lr_functions     TYPE REF TO cl_salv_functions.

  TRY .
      lr_functions = gr_table->get_functions( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_functions->set_all( abap_true ).
ENDFORM.                    " F_SET_FUNCTION

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SETTING
*&---------------------------------------------------------------------*
FORM f_display_setting .
  DATA : lr_display       TYPE REF TO cl_salv_display_settings.

  TRY .
      lr_display = gr_table->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).
ENDFORM.                    " F_DISPLAY_SETTING

*&---------------------------------------------------------------------*
*&      Form  F_SET_EVENT
*&---------------------------------------------------------------------*
FORM f_set_event .
  DATA : lr_events    TYPE REF TO cl_salv_events_table.

  lr_events = gr_table->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command
              event_receiver->on_double_click FOR lr_events.
ENDFORM.                    " F_SET_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_SET_SORT
*&---------------------------------------------------------------------*
FORM f_set_sort  USING    fu_gsber fu_position.
  DATA : lr_sorts   TYPE REF TO cl_salv_sorts.

  lr_sorts = gr_table->get_sorts( ).

  lr_sorts->clear( ).

  TRY.
      lr_sorts->add_sort(
        columnname = fu_gsber
        position   = fu_position
        group      = 2
*        subtotal   = abap_true
        sequence   = if_salv_c_sort=>sort_up ).
    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
  ENDTRY.
ENDFORM.                    " F_SET_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SET_SELECTION
*&---------------------------------------------------------------------*
FORM f_set_selection .
  DATA : lr_selections    TYPE REF TO cl_salv_selections,
         lt_rows          TYPE salv_t_row.

  TRY.
      lr_selections = gr_table->get_selections( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  lr_selections->set_selection_mode( if_salv_c_selection_mode=>multiple ).

*  APPEND '1' TO lt_rows.
*  lr_selections->set_selected_rows( lt_rows ).

ENDFORM.                    " F_SET_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_SET_TEXT
*&---------------------------------------------------------------------*
FORM f_set_text  USING    fu_column fu_text fu_short fu_visible fu_type fu_length.
  DATA : lr_columns       TYPE REF TO cl_salv_columns_table,
         lr_column        TYPE REF TO cl_salv_column_table.

  DATA : lv_short(10).

  TRY.
      lr_columns = gr_table->get_columns( ).
    CATCH cx_salv_not_found.
  ENDTRY.

  IF fu_short IS INITIAL.
    lv_short  = fu_text.
  ELSE.
    lv_short  = fu_short.
  ENDIF.

  lr_column ?= lr_columns->get_column( fu_column ).
  lr_column->set_long_text( fu_text ).
  lr_column->set_medium_text( fu_text ).
  lr_column->set_short_text( lv_short ).
  lr_column->set_visible( fu_visible ).
  lr_column->set_cell_type( fu_type ).
  IF fu_length IS NOT INITIAL.
    lr_column->set_output_length( fu_length ).
  ENDIF.
ENDFORM.                    " F_SET_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_ON_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_on_user_command  USING    fu_ucomm TYPE salv_de_function.
  DATA : ls_post        LIKE LINE OF gt_post,
         lv_subrc       TYPE sy-subrc,
         ls_reverse     LIKE LINE OF gt_reverse.

  DATA : lr_selections  TYPE REF TO cl_salv_selections,
         lt_rows        TYPE salv_t_row,
         i              TYPE i.

  CASE fu_ucomm.
    WHEN 'MYFUNCTION'.
      PERFORM f_globals_from_slvc_fullscr.

    WHEN '&SALL'.
      PERFORM f_select USING 'X'.

    WHEN '&DALL'.
      PERFORM f_select USING ''.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.

    WHEN '&POS'.
      IF gt_error[] IS INITIAL.
        READ TABLE gt_post INTO ls_post WITH KEY icon = icon_led_red.
        IF sy-subrc = 0.
          MESSAGE s000(zab) WITH 'Ada data yang masih error'
                            DISPLAY LIKE 'E'.
        ELSE.
          PERFORM f_posting USING 'POSTING'
                            CHANGING lv_subrc.
          IF lv_subrc IS INITIAL.
            MESSAGE s000(zab) WITH 'Data sudah diposting'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'Masih ada data yang salah'
                          DISPLAY LIKE 'E'.
      ENDIF.

    WHEN '&REV'.
      TRY.
          lr_selections = gr_table->get_selections( ).
        CATCH cx_salv_not_found.
      ENDTRY.
      lt_rows = lr_selections->get_selected_rows( ).

      IF lt_rows[] IS NOT INITIAL.
        LOOP AT lt_rows INTO i.
          READ TABLE gt_reverse INTO ls_reverse INDEX i.
          IF sy-subrc = 0.
            IF ls_reverse-rev_belnr IS INITIAL.
              PERFORM f_reverse USING ls_reverse
                                CHANGING ls_reverse-rev_belnr.
              MODIFY gt_reverse FROM ls_reverse INDEX i TRANSPORTING rev_belnr.
            ELSE.
              MESSAGE s361(f5) DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
      gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
  ENDCASE.
ENDFORM.                    " F_ON_USER_COMMAND

**&---------------------------------------------------------------------*
**&      Form  F_DYN_FIELDCATG
**&---------------------------------------------------------------------*
*FORM f_dyn_fieldcatg  USING    value(fu_fname)
*                               value(fu_reftable)
*                               value(fu_reffield)
*                               value(fu_noout)
*                               value(fu_outln)
*                               value(fu_fltxt)
*                               value(fu_dosum)
*                               value(fu_hotsp)
*                               value(fu_dec)
*                               value(fu_waers)
*                               value(fu_meins)
*                               value(fu_waers_f)
*                               value(fu_meins_f)
*                               value(fu_checkbox)
*                               value(fu_edit)
*                               value(fu_emphasize)
*                               value(fu_inttype)
*                               value(fu_fix).
*
*  DATA lw_dyn_fcat  TYPE  lvc_s_fcat.
*
*  CLEAR lw_dyn_fcat.
*  lw_dyn_fcat-fieldname         = fu_fname.
*  lw_dyn_fcat-ref_table         = fu_reftable.
*  lw_dyn_fcat-ref_field         = fu_reffield.
*  lw_dyn_fcat-no_out            = fu_noout.
*  lw_dyn_fcat-outputlen         = fu_outln.
*  lw_dyn_fcat-coltext           = fu_fltxt.
*  lw_dyn_fcat-no_out            = fu_noout.
*  lw_dyn_fcat-do_sum            = fu_dosum.
*  lw_dyn_fcat-hotspot           = fu_hotsp.
*  lw_dyn_fcat-decimals          = fu_dec.
*  lw_dyn_fcat-currency          = fu_waers.
*  lw_dyn_fcat-quantity          = fu_meins.
*  lw_dyn_fcat-qfieldname        = fu_meins_f.
*  lw_dyn_fcat-cfieldname        = fu_waers_f.
*  lw_dyn_fcat-checkbox          = fu_checkbox.
*  lw_dyn_fcat-edit              = fu_edit.
*  lw_dyn_fcat-emphasize         = fu_emphasize.
*  lw_dyn_fcat-inttype           = fu_inttype.
*  lw_dyn_fcat-fix_column        = fu_fix.
*  APPEND lw_dyn_fcat TO gt_dyn_fcat.
*  CLEAR lw_dyn_fcat.
*ENDFORM.                    " F_DYN_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_FIELDSTYLE
*&---------------------------------------------------------------------*
FORM f_fieldstyle  USING    fu_fieldname fu_edit
                   CHANGING fc_style.
  DATA : ls_stylerow          TYPE lvc_s_styl,
         lv_style             TYPE lvc_s_styl-style,
         lt_main_stylerow     TYPE lvc_t_styl.

  CLEAR : ls_stylerow.

  IF fu_edit IS INITIAL.
    lv_style      = cl_gui_alv_grid=>mc_style_disabled.
  ELSE.
    lv_style      = cl_gui_alv_grid=>mc_style_enabled.
  ENDIF.

  ls_stylerow-fieldname = fu_fieldname.
  ls_stylerow-style     = lv_style.

  INSERT ls_stylerow INTO TABLE lt_main_stylerow.
  fc_style  = lt_main_stylerow.
ENDFORM.                    " F_FIELDSTYLE

*&---------------------------------------------------------------------*
*&      Form  F_GLOBALS_FROM_SLVC_FULLSCR
*&---------------------------------------------------------------------*
FORM f_globals_from_slvc_fullscr .
  DATA : lr_grid      TYPE REF TO cl_gui_alv_grid,
         lv_layout    TYPE lvc_s_layo.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = lr_grid.

  CALL METHOD lr_grid->get_frontend_layout
    IMPORTING
      es_layout = lv_layout.
ENDFORM.                    " F_GLOBALS_FROM_SLVC_FULLSCR

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_GAJI
*&---------------------------------------------------------------------*
FORM f_validasi_gaji USING    fu_gjahr fu_monat.
  DATA : lv_msgv1   TYPE symsgv,
         lv_msgv2   TYPE symsgv,
         lv_msgv3   TYPE symsgv,
         lv_msgv4   TYPE symsgv,
         lv_subrc   TYPE sy-subrc,
         ls_proses  LIKE LINE OF gt_proses,
         ls_lokasi  LIKE LINE OF gt_lokasi.

  SELECT SINGLE *
    FROM zfgaji_period
    WHERE bukrs  = pa_bukrs
      AND gjahr  = fu_gjahr
      AND monat  = fu_monat
      AND ztype  = 'PAYB'.
  IF sy-subrc <> 0.
    gv_subrc  = 4.
    MESSAGE s000(zab) WITH 'Period gaji belum dimaintain'
                      DISPLAY LIKE 'E'.
  ELSE.
    CONCATENATE pa_monat '.' pa_gjahr INTO lv_msgv2.
    CASE 'X'.
      WHEN radio1.
        IF zfgaji_period-closed IS INITIAL.
          gv_text   = 'is still open'.
        ELSE.
          gv_text = 'has been closed'.
        ENDIF.

        LOOP AT gt_proses INTO ls_proses.
          gs_appr-vkbur       = ls_proses-vkbur.
          gs_appr-zloct       = ls_proses-zloct.
          gs_appr-apv_user    = ls_proses-apv_user.
          gs_appr-apv_date    = ls_proses-apv_date.
          gs_appr-post_user   = ls_proses-post_user.
          gs_appr-post_date   = ls_proses-post_date.
          IF ls_proses-apv_user IS INITIAL AND
            ls_proses-post_user IS INITIAL.
            gs_appr-icon  = icon_led_red.
          ELSEIF ls_proses-post_user IS INITIAL.
            gs_appr-icon  = icon_led_yellow.
          ELSE.
            gs_appr-icon  = icon_led_green.
          ENDIF.
          gs_appr-rev_user   = ls_proses-rev_user.
          gs_appr-rev_date   = ls_proses-rev_budat.

*          LOOP AT gt_lokasi INTO ls_lokasi WHERE vkbur = ls_proses-vkbur.
*            gs_appr-zloct       = ls_lokasi-zloct.
*          ENDLOOP.
          APPEND gs_appr TO gt_appr.
          CLEAR gs_appr.
        ENDLOOP.

        CALL SCREEN 900.

      WHEN radio2.
        IF zfgaji_period-closed IS NOT INITIAL.
          gv_subrc  = 3.
          MESSAGE s000(zab) WITH 'Period gaji sudah ditutup'
                            DISPLAY LIKE 'E'.
        ELSE.
          CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
            EXPORTING
              titel = 'Approved'
              msgid = 'ZAB'
              msgty = 'I'
              msgno = '000'
              msgv1 = 'Period'
              msgv2 = lv_msgv2
              msgv3 = 'will be approved ?'.

          IF sy-ucomm = 'OKAY'.
            SELECT SINGLE *
              FROM zfgaji_proses
              WHERE bukrs = pa_bukrs
                AND vkbur = pa_vkbur
                AND monat = pa_monat
                AND gjahr = pa_gjahr
                AND ztype = 'PAYB'.

            IF zfgaji_proses-apv_user IS INITIAL.
              UPDATE zfgaji_proses SET apv_user = sy-uname
                                       apv_date = sy-datum
                                   WHERE bukrs = pa_bukrs
                                     AND vkbur = pa_vkbur
                                     AND monat = pa_monat
                                     AND gjahr = pa_gjahr
                                     AND ztype = 'PAYB'.
              IF sy-subrc = 0.
                CONCATENATE 'Period' lv_msgv2 'sudah diapprove'
                INTO lv_msgv1
                SEPARATED BY space.
                MESSAGE s000(zab) WITH lv_msgv1.
              ENDIF.
            ELSE.
              gv_subrc  = 5.
              CONCATENATE 'Period' lv_msgv2 'sudah diapprove'
              INTO lv_msgv1
              SEPARATED BY space.
              MESSAGE s000(zab) WITH lv_msgv1 DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_VALIDASI_GAJI

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_authorization USING fu_actvt.
  AUTHORITY-CHECK OBJECT 'ZFPAYROLL'
            ID 'ACTVT' FIELD fu_actvt.
  IF sy-subrc <> 0.
    PERFORM f_screen_error USING '' 'You are not authorized'.
  ENDIF.
ENDFORM.                    " F_CHECK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F4_PA_FILNM
*&---------------------------------------------------------------------*
FORM f4_pa_filnm  CHANGING pa_filnm.
  DATA : lt_files       TYPE filetable,
         filename       TYPE string.

  filename  = pa_filnm.

  cl_gui_frontend_services=>file_open_dialog(
  EXPORTING
    default_filename        = filename
  CHANGING
    file_table              = lt_files
    rc                      = sy-tabix
  EXCEPTIONS
    OTHERS                  = 1 ).

  READ TABLE lt_files INDEX 1 INTO pa_filnm.
ENDFORM.                    " F4_PA_FILNM

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table  USING    fu_value.

ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_APPROVED_PROCESS
*&---------------------------------------------------------------------*
FORM f_approved_process USING    fu_datum
                        CHANGING fc_subrc fc_vkbur.

  DATA : lt_proses  TYPE STANDARD TABLE OF zfgaji_proses INITIAL SIZE 0,
         ls_proses  LIKE LINE OF lt_proses.

  DATA : ls_lokasi  LIKE LINE OF gt_lokasi,
         lt_lokasi  TYPE STANDARD TABLE OF zfgaji_lokasi INITIAL SIZE 0.

  IF fu_datum IS INITIAL.
    SELECT *
      FROM zfgaji_proses
      INTO CORRESPONDING FIELDS OF TABLE lt_proses
      WHERE bukrs = pa_bukrs
        AND monat = pa_monat
        AND gjahr = pa_gjahr
        AND ztype = 'PAYB'.

    LOOP AT lt_proses INTO ls_proses.
      fc_vkbur = ls_proses-vkbur.
      IF ls_proses-apv_user IS INITIAL.
        fc_subrc = 1.
        EXIT.
      ENDIF.
      IF ls_proses-post_user IS INITIAL.
        fc_subrc = 2.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF fc_subrc IS INITIAL.
      CLEAR fc_vkbur.
    ENDIF.
  ELSE.
    lt_lokasi[] = gt_lokasi[].
    SORT lt_lokasi BY bukrs vkbur zloct.
    DELETE ADJACENT DUPLICATES FROM lt_lokasi COMPARING bukrs vkbur zloct.

    LOOP AT lt_lokasi INTO ls_lokasi WHERE bukrs = pa_bukrs.
      zfgaji_proses-bukrs   = pa_bukrs.
      zfgaji_proses-vkbur   = ls_lokasi-vkbur.
      zfgaji_proses-zloct   = ls_lokasi-zloct.
      zfgaji_proses-monat   = fu_datum+4(2).
      zfgaji_proses-gjahr   = fu_datum(4).
      zfgaji_proses-ztype   = 'PAYB'.
      zfgaji_proses-znomor  = '000'.
      INSERT zfgaji_proses.
      fc_subrc = sy-subrc.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_APPROVED_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_FR_EXCEL
*&---------------------------------------------------------------------*
FORM f_download_fr_excel  USING    fu_filename.
  CLEAR : gt_excel[], gt_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = fu_filename
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 100
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
ENDFORM.                    " F_DOWNLOAD_FR_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUKRS_VKBUR
*&---------------------------------------------------------------------*
FORM f_get_bukrs_vkbur  .
  DATA : lt_excel      TYPE STANDARD TABLE OF alsmex_tabline INITIAL SIZE 0,
         ls_excel      LIKE LINE OF lt_excel,
         ls_ghkont     LIKE LINE OF gt_ghkont,
         ls_zplbc      LIKE LINE OF gt_zplbc,
         str1          TYPE string,
         ls_head       LIKE LINE OF gt_head,
         ls_detl       LIKE LINE OF gt_detl,
         ls_item       LIKE LINE OF gt_item,
         ls_company    LIKE LINE OF gt_company,
         ls_lokasi     LIKE LINE OF gt_lokasi,
         ls_proses     LIKE LINE OF gt_proses,
         ls_error      LIKE LINE OF gt_error,
         ls_thp        LIKE LINE OF gt_thp,
         lv_row        TYPE alsmex_tabline-row,
         lv_coll       TYPE alsmex_tabline-col,
         lv_colh       TYPE alsmex_tabline-col.

  lt_excel[] = gt_excel[].
  SORT lt_excel BY row col.

  LOOP AT lt_excel INTO ls_excel.
    IF ls_excel-row = '0003'.
      CASE ls_excel-col.
        WHEN '0004'.
          IF ls_excel-value <> 'Department'.
            gv_subrc = 8.
            EXIT.
          ENDIF.
        WHEN '0005'.
          IF ls_excel-value <> 'Job Level Group Name'.
            gv_subrc = 8.
            EXIT.
          ENDIF.
        WHEN '0006'.
          IF ls_excel-value <> 'Employment Type Group'.
            gv_subrc = 8.
            EXIT.
          ENDIF.
        WHEN '0008'.
          IF ls_excel-value <> 'Currency Item'.
            gv_subrc = 8.
            EXIT.
          ENDIF.
      ENDCASE.

      IF ls_excel-value(3) = 'THP'.
        lv_colh  = ls_excel-col.
      ENDIF.
    ENDIF.

    SEARCH ls_excel-value FOR 'Company Name:' .
    IF sy-subrc = 0.
      SPLIT ls_excel-value AT ':' INTO str1 ls_head-zcocd.
      IF sy-subrc = 0.
        SHIFT ls_head-zcocd LEFT DELETING LEADING space.
        READ TABLE gt_company INTO ls_company
                              WITH KEY zcocd = ls_head-zcocd.
        IF sy-subrc = 0.
          ls_head-bukrs   = ls_company-bukrs.
          IF ls_head-bukrs <> pa_bukrs.
            MESSAGE s000(zab) WITH 'Company code salah'
            DISPLAY LIKE 'E'.
            gv_subrc  = 10.
            EXIT.
          ENDIF.
        ELSE.
          MESSAGE s000(zab) WITH 'Company code belum dimaintain'
          DISPLAY LIKE 'E'.
          gv_subrc  = 10.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR : ls_head-zloct, ls_head-vkbur.
    SEARCH ls_excel-value FOR 'Location Report:' .
    IF sy-subrc = 0.
      SPLIT ls_excel-value AT ':' INTO str1 ls_head-zloct.
      IF sy-subrc = 0.
        SHIFT ls_head-zloct LEFT DELETING LEADING space.
        READ TABLE gt_lokasi INTO ls_lokasi
                             WITH KEY zloct = ls_head-zloct.
        IF sy-subrc = 0.
          ls_head-vkbur  = ls_lokasi-vkbur.
          ls_head-gsber  = ls_lokasi-gsber.
          ls_head-blart  = ls_lokasi-blart.
          ls_head-newbs  = ls_lokasi-newbs.
          ls_head-hkont  = ls_lokasi-hkont.
          ls_head-kostl  = ls_lokasi-kostl.
          ls_head-desc   = ls_lokasi-description.
          ls_head-col    = ls_excel-col.
          ls_head-row    = ls_excel-row.
          lv_row         = ls_excel-row + 1.

          CLEAR : ls_proses.
          READ TABLE gt_proses INTO ls_proses
                               WITH KEY bukrs = ls_head-bukrs
                                        vkbur = ls_head-vkbur
                                        monat = pa_budat+4(2)
                                        gjahr = pa_budat(4).
          IF sy-subrc = 0.
            ADD 1 TO ls_proses-znomor.
            MODIFY TABLE gt_proses FROM ls_proses TRANSPORTING znomor.
            CONCATENATE ls_head-vkbur '/PY/'
                        pa_budat+4(2) pa_budat+2(2) '/'
                        ls_proses-znomor
            INTO ls_head-xblnr.
          ENDIF.

          APPEND ls_head TO gt_head.
        ELSE.
          ls_error-type       = 'E'.
          ls_error-id         = 'ZAB'.
          ls_error-number     = '000'.
          ls_error-message_v1 = 'Lokasi'.
          ls_error-message_v2 = ls_head-zloct.
          ls_error-message_v3 = 'belum dimaintain/salah'.
          APPEND ls_error TO gt_error.
          CLEAR ls_error.
        ENDIF.
      ENDIF.
    ELSE.
      IF lv_row IS NOT INITIAL.
        IF ls_excel-col = '0004'.
          IF ls_excel-value IS INITIAL.
            CLEAR lv_row.
          ELSE.
            lv_row = ls_excel-row.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR : ls_ghkont.
    READ TABLE gt_ghkont INTO ls_ghkont WITH KEY itemgaji = ls_excel-value.
    IF sy-subrc = 0.
      IF lv_coll IS INITIAL.
        lv_coll = ls_excel-col.
      ENDIF.
      ls_detl-col       = ls_excel-col.
      ls_detl-row       = ls_excel-row.
      ls_detl-itemgaji  = ls_excel-value.
      CLEAR : ls_detl-count.
      APPEND ls_detl TO gt_detl.
      IF ls_ghkont-hkont1 IS NOT INITIAL.
        ls_detl-col       = ls_excel-col.
        ls_detl-row       = ls_excel-row.
        ls_detl-itemgaji  = ls_excel-value.
        ls_detl-count     = 1.
        APPEND ls_detl TO gt_detl.
      ENDIF.
    ENDIF.

    CLEAR ls_detl.
    IF ls_excel-row = lv_row.
      IF ls_excel-col = lv_colh.
        ls_thp-bukrs  = pa_bukrs.
        ls_thp-vkbur  = ls_lokasi-vkbur.
        ls_thp-gsber  = ls_lokasi-gsber.
        ls_thp-row    = ls_excel-row.
        ls_thp-tthp   = 0.
        PERFORM f_modify_value USING ls_excel-value '' ''
                                     CHANGING ls_thp-value.
        COLLECT ls_thp INTO gt_thp.
      ELSEIF ls_excel-col BETWEEN lv_coll AND lv_colh.
        READ TABLE gt_detl INTO ls_detl WITH KEY col = ls_excel-col.
        IF sy-subrc = 0.
          ls_thp-bukrs  = pa_bukrs.
          ls_thp-vkbur  = ls_lokasi-vkbur.
          ls_thp-gsber  = ls_lokasi-gsber.
          ls_thp-row    = ls_excel-row.
          PERFORM f_modify_value USING ls_excel-value '' ''
                                       CHANGING ls_thp-tthp.
          ls_thp-value  = 0.
          COLLECT ls_thp INTO gt_thp.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_BUKRS_VKBUR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_div fu_shkzg
                     CHANGING fc_value.

  DATA : lv_value(132),
         lv_wrbtr   TYPE bseg-wrbtr.

  lv_value = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.

  IF fu_div IS INITIAL.
    fc_value  = lv_value.
  ELSE.
    fc_value  = lv_value / fu_div.
  ENDIF.

  CASE fu_shkzg.
    WHEN 'H'.
      IF fc_value < 0.
        fc_value  = fc_value.
      ELSE.
        fc_value  = fc_value * -1.
      ENDIF.
    WHEN 'S'.
      IF fc_value < 0.
        fc_value  = fc_value * -1.
      ELSE.
        fc_value  = fc_value.
      ENDIF.
    WHEN space.
*      fc_value  = lv_value / 100.
  ENDCASE.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_EXCEL
*&---------------------------------------------------------------------*
FORM f_validasi_excel .
  DATA : ls_head       LIKE LINE OF gt_head,
         ls_proses     LIKE LINE OF gt_proses,
         lv_text(10),
         ls_error      LIKE LINE OF gt_error,
         ls_thp        LIKE LINE OF gt_thp.

  LOOP AT gt_head INTO ls_head.
    READ TABLE gt_proses INTO ls_proses
                         WITH KEY bukrs = ls_head-bukrs
                                  vkbur = ls_head-vkbur
                                  monat = pa_budat+4(2)
                                  gjahr = pa_budat(4).
    IF sy-subrc = 0.
      PERFORM f_lock_table USING ls_head-bukrs ls_head-vkbur
                                 pa_budat+4(2) pa_budat(4).
      IF gv_subrc IS INITIAL.
        IF ls_proses-apv_user IS INITIAL.
          CONCATENATE pa_budat+4(2) '.' pa_budat(4) INTO lv_text.

          ls_error-type       = 'E'.
          ls_error-id         = 'ZAB'.
          ls_error-number     = '000'.
          ls_error-message_v1 = 'Sales Office'.
          ls_error-message_v2 = ls_head-vkbur.
          ls_error-message_v3 = 'belum ada Approval'.
          APPEND ls_error TO gt_error.
          CLEAR ls_error.

          ls_head-subrc   = 6.
          MODIFY gt_head FROM ls_head TRANSPORTING subrc.
        ENDIF.
        IF ls_proses-post_user IS NOT INITIAL.
          CONCATENATE pa_budat+4(2) '.' pa_budat(4) INTO lv_text.
          ls_error-type       = 'E'.
          ls_error-id         = 'ZAB'.
          ls_error-number     = '000'.
          ls_error-message_v1 = 'Sales Office'.
          ls_error-message_v2 = ls_head-vkbur.
          ls_error-message_v3 = 'sudah posting'.
          APPEND ls_error TO gt_error.
          CLEAR ls_error.

          ls_head-subrc   = 7.
          MODIFY gt_head FROM ls_head TRANSPORTING subrc.
        ENDIF.
      ENDIF.
    ELSE.
      gv_subrc  = 4.
      MESSAGE s000(zab) WITH 'Period gaji belum dimaintain'
                        DISPLAY LIKE 'E'.
    ENDIF.

*    LOOP AT gt_thp INTO ls_thp WHERE bukrs = ls_head-bukrs
*                                 AND vkbur = ls_head-vkbur.
*      IF ls_thp-tthp <> ls_thp-value.
*        ls_error-type       = 'E'.
*        ls_error-id         = 'ZAB'.
*        ls_error-number     = '000'.
*        ls_error-message_v1 = 'Nilai THP'.
*        ls_error-message_v2 = ls_head-vkbur.
*        ls_error-message_v3 = 'tidak sama dengan'.
*        ls_error-message_v4 = 'Nilai Bank'.
*        APPEND ls_error TO gt_error.
*        CLEAR ls_error.
*
*        ls_head-subrc   = 11.
*        MODIFY gt_head FROM ls_head TRANSPORTING subrc.
*      ENDIF.
*    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING
*&---------------------------------------------------------------------*
FORM  f_prepare_posting .
  DATA : ls_head     LIKE LINE OF gt_head,
         ls_excel    LIKE LINE OF gt_excel,
         ls_detl     LIKE LINE OF gt_detl,
         ls_ghkont   LIKE LINE OF gt_ghkont,
         ls_gkostl   LIKE LINE OF gt_gkostl,
         ls_post     LIKE LINE OF gt_post,
         ls_skat     LIKE LINE OF gt_skat,
         ls_ska1     LIKE LINE OF gt_ska1,
         ls_tbsl     LIKE LINE OF gt_tbsl,
         ls_proses   LIKE LINE OF gt_proses,
         ls_control  LIKE LINE OF gt_control,
         ls_lokasi   LIKE LINE OF gt_lokasi,
         lv_row      TYPE alsmex_tabline-row,
         lv_subrc    TYPE sy-subrc,
         lv_waers    TYPE bkpf-waers,
         lv_job      TYPE zfgaji_hkont-job,
         lv_type     TYPE zfgaji_hkont-type,
         lv_total    TYPE bseg-wrbtr,
         lv_depar    TYPE zfgaji_kostl-departement,
         lv_kost1(10),
         lv_kost2(10),
         lv_znomor   TYPE zfgaji_proses-znomor,
         ls_zplbc    LIKE LINE OF gt_zplbc,
         lv_flag,
         lv_hkont    TYPE ska1-saknr,
         lv_bschl    TYPE tbsl-bschl,
         ls_thp      LIKE LINE OF gt_thp.

  SORT gt_excel BY row col.
  LOOP AT gt_head INTO ls_head.
    CLEAR ls_zplbc.
    READ TABLE gt_zplbc INTO ls_zplbc
                        WITH KEY werks = ls_head-vkbur.

    READ TABLE gt_excel INTO ls_excel
                        WITH KEY col = ls_head-col
                                 row = ls_head-row.
    IF sy-subrc = 0.
      lv_row = ls_head-row + 1.
      CLEAR lv_subrc.
      WHILE lv_subrc IS INITIAL.
        LOOP AT gt_excel INTO ls_excel WHERE row = lv_row.
          CASE ls_excel-col.
            WHEN '0004'.
              lv_depar = ls_excel-value.
            WHEN '0008'.
              lv_waers = ls_excel-value.
            WHEN '0005'.
              lv_job   = ls_excel-value.
            WHEN '0006'.
              lv_type  = ls_excel-value.
          ENDCASE.

          IF lv_depar IS NOT INITIAL.
            LOOP AT gt_detl INTO ls_detl WHERE col = ls_excel-col.
              READ TABLE gt_gkostl INTO ls_gkostl
                                   WITH KEY departement = lv_depar.
              IF sy-subrc = 0.
                IF ls_head-kostl IS NOT INITIAL.
                  SHIFT ls_head-kostl LEFT DELETING LEADING '0'.
                  SHIFT ls_gkostl-kostl LEFT DELETING LEADING '0'.
                  CONCATENATE ls_head-kostl ls_gkostl-kostl INTO ls_post-kostl.
                ELSE.
                  ls_post-kostl = ls_gkostl-kostl.
                ENDIF.
                PERFORM f_alpha_input CHANGING ls_post-kostl.

                ls_post-wwsfr   = ls_gkostl-wwsfr.
                ls_post-wwpos   = ls_gkostl-wwpos.
              ENDIF.

              CLEAR : lv_flag.
              READ TABLE gt_ghkont INTO ls_ghkont
                                   WITH KEY itemgaji = ls_detl-itemgaji
                                            type     = lv_type
                                            job      = lv_job
                                            live     = ls_zplbc-live.
              IF sy-subrc <> 0.
                lv_flag = 'X'.
                READ TABLE gt_ghkont INTO ls_ghkont
                                     WITH KEY itemgaji = ls_detl-itemgaji
                                              type     = lv_type
                                              job      = lv_job.
                IF sy-subrc = 0.
                  CLEAR lv_flag.
                ENDIF.
              ENDIF.

              IF lv_flag IS INITIAL.
                IF ls_detl-count IS INITIAL.
                  lv_bschl  = ls_ghkont-bschl.
                  lv_hkont  = ls_ghkont-hkont.
                ELSE.
                  lv_bschl  = ls_ghkont-bschl1.
                  lv_hkont  = ls_ghkont-hkont1.
                ENDIF.

                ls_post-gjahr = pa_budat(4).

                IF ls_excel-value = '0'.
                  CONTINUE.
                ENDIF.

                ls_post-vkbur = ls_head-vkbur.
                ls_post-zloct = ls_head-zloct.
                ls_post-gsber = ls_head-gsber.
                ls_post-blart = ls_head-blart.

                PERFORM f_posting_key_validate USING ls_excel-value
                                               CHANGING lv_bschl.
                ls_post-bschl = lv_bschl.
                READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = lv_bschl.
                IF sy-subrc = 0.
                  ls_post-shkzg = ls_tbsl-shkzg.
                  ls_post-koart = ls_tbsl-koart.
                ENDIF.

                ls_post-hkont = lv_hkont.
                READ TABLE gt_skat INTO ls_skat WITH KEY saknr = lv_hkont.
                IF sy-subrc = 0.
                  ls_post-txt20 = ls_skat-txt20.
                  ls_post-txt50 = ls_skat-txt50.
                  READ TABLE gt_ska1 INTO ls_ska1 WITH KEY saknr = lv_hkont.
                  IF sy-subrc = 0.
                    IF ls_ska1-xbilk IS NOT INITIAL.
                      CLEAR ls_post-kostl.
                    ENDIF.
                  ENDIF.
                ENDIF.

                PERFORM f_modify_value USING ls_excel-value 100 ls_post-shkzg
                                       CHANGING ls_post-wrbtr.

                ADD ls_post-wrbtr TO lv_total.
                ls_post-waers = lv_waers.

                IF ls_ghkont-text1 IS NOT INITIAL.
                  CONCATENATE ls_ghkont-text1 '-' lv_job '-' lv_type
                  INTO ls_post-text.
                ELSE.
                  CONCATENATE ls_detl-itemgaji '-' lv_job '-' lv_type
                  INTO ls_post-text.
                ENDIF.

                CLEAR ls_post-text.
                CONCATENATE ls_post-txt20 '-' pa_budat+4(2) pa_budat(4)
                INTO ls_post-text SEPARATED BY space.

                IF ls_post-wwsfr IS NOT INITIAL.
                  CONCATENATE ls_post-wwsfr '-' ls_post-text
                  INTO ls_post-text SEPARATED BY space.
                ELSEIF ls_post-wwpos IS NOT INITIAL.
                  CONCATENATE ls_post-wwpos '-' ls_post-text
                  INTO ls_post-text SEPARATED BY space.
                ENDIF.
                ls_post-xblnr   = ls_head-xblnr.
                ls_post-zuonr   = ls_head-xblnr.

                IF ls_head-subrc  = 7.
                  READ TABLE gt_proses INTO ls_proses WITH KEY bukrs = ls_head-bukrs
                                                               vkbur = ls_head-vkbur
                                                               monat = pa_budat+4(2)
                                                               gjahr = pa_budat(4).
                  IF sy-subrc = 0.
                    ls_post-belnr   = ls_proses-post_belnr.
                  ENDIF.
                ENDIF.

                READ TABLE gt_control INTO ls_control WITH KEY bukrs = ls_head-bukrs
                                                               hkont = lv_hkont.
                IF sy-subrc = 0.
                  ls_post-gsber = ls_control-gsber.
                ENDIF.

                APPEND ls_post TO gt_post.
                CLEAR ls_post.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        ADD 1 TO lv_row.
        CLEAR : lv_depar.
        SEARCH ls_excel-value FOR 'Location Report:'.
        IF sy-subrc = 0.
          lv_subrc = 4.
        ENDIF.
      ENDWHILE.

      CLEAR ls_post.

      READ TABLE gt_proses INTO ls_proses WITH KEY bukrs = ls_head-bukrs
                                                   vkbur = ls_head-vkbur
                                                   zloct = ls_head-zloct
                                                   monat = pa_budat+4(2)
                                                   gjahr = pa_budat(4).
      IF sy-subrc = 0.
        ls_post-belnr   = ls_proses-post_belnr.
      ENDIF.

      READ TABLE gt_lokasi INTO ls_lokasi
                           WITH KEY bukrs = ls_head-bukrs
                                    gsber = ls_head-gsber
                                    vkbur = ls_head-vkbur
                                    zloct = ls_head-zloct.
      IF sy-subrc = 0.
        IF ls_lokasi-gsber1 IS NOT INITIAL.
          ls_post-gsber = ls_lokasi-gsber1.
        ELSE.
          ls_post-gsber = ls_head-gsber.
        ENDIF.
      ELSE.
        ls_post-gsber = ls_head-gsber.
      ENDIF.

      ls_post-gjahr = pa_budat(4).
      ls_post-vkbur = ls_head-vkbur.
      ls_post-zloct = ls_head-zloct.
      ls_post-blart = ls_head-blart.
      ls_post-waers = 'IDR'.
      ls_post-bschl = ls_head-newbs.
      READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = ls_post-bschl.
      IF sy-subrc = 0.
        ls_post-shkzg = ls_tbsl-shkzg.
        ls_post-koart = ls_tbsl-koart.
      ENDIF.

      ls_post-hkont = ls_head-hkont.
      READ TABLE gt_skat INTO ls_skat WITH KEY saknr = ls_post-hkont.
      IF sy-subrc = 0.
        ls_post-txt20 = ls_skat-txt20.
        ls_post-txt50 = ls_skat-txt50.
      ENDIF.
      PERFORM f_modify_value USING lv_total 100 ls_post-shkzg
                             CHANGING ls_post-wrbtr.

      CONCATENATE ls_head-desc pa_budat+4(2) pa_budat(4)
      INTO ls_post-text SEPARATED BY space.

      ls_post-xblnr   = ls_head-xblnr.
      ls_post-zuonr   = ls_head-xblnr.

      APPEND ls_post TO gt_post.
      CLEAR : ls_post, lv_total.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting USING    fu_proc
               CHANGING fc_subrc.
  DATA : ls_head  LIKE LINE OF gt_head,
         ls_post  LIKE LINE OF gt_post.

  DATA : advdh   LIKE bapiache09,
         advgl   TYPE STANDARD TABLE OF bapiacgl09 INITIAL SIZE 0,
         advap   TYPE STANDARD TABLE OF bapiacap09 INITIAL SIZE 0,
         advar   TYPE STANDARD TABLE OF bapiacar09 INITIAL SIZE 0,
         advex   TYPE STANDARD TABLE OF bapiacextc INITIAL SIZE 0,
         advca   TYPE STANDARD TABLE OF bapiaccr09 INITIAL SIZE 0,
         advcr   TYPE STANDARD TABLE OF bapiackec9 INITIAL SIZE 0.

  DATA : lv_error,
         lv_subrc    TYPE sy-subrc,
         lv_stat     TYPE icon_d,
         lv_belnr    TYPE bseg-belnr,
         lv_gjahr    TYPE bseg-gjahr,
         lv_bktxt    TYPE bkpf-bktxt,
         lv_znomor   TYPE zfgaji_proses-znomor,
         ls_proses   LIKE LINE OF gt_proses.

  DATA : lv_buzei    TYPE bseg-buzei.

  fc_subrc = 4.

  SORT gt_head BY bukrs vkbur zloct.
  DELETE ADJACENT DUPLICATES FROM gt_head COMPARING bukrs vkbur zloct.

  LOOP AT gt_head INTO ls_head.
    CLEAR : lv_subrc, lv_buzei.
    IF ls_head-subrc IS NOT INITIAL.
      lv_subrc = 4.
    ENDIF.

    CONCATENATE ls_head-desc pa_budat+4(2) pa_budat(4)
    INTO lv_bktxt SEPARATED BY space.

    PERFORM f_document_header USING    'RFBU' ls_head-blart
                                       lv_bktxt ls_head-xblnr
                              CHANGING advdh.

    LOOP AT gt_post INTO ls_post WHERE vkbur = ls_head-vkbur
                                   AND xblnr = ls_head-xblnr
                                   AND zloct = ls_head-zloct.
      ADD 1 TO lv_buzei.
      ls_post-buzei   = lv_buzei.
      IF ls_post-belnr IS NOT INITIAL.
        lv_subrc = 4.
        EXIT.
      ENDIF.
      CASE ls_post-koart.
        WHEN 'S'.
          PERFORM f_account_gl TABLES   advgl advca advex advcr
                               USING    ls_post ls_post-gsber.
        WHEN 'D'.
          PERFORM f_account_receivable TABLES  advar advca advex advcr
                                       USING   ls_post.
        WHEN 'K'.
          PERFORM f_account_payable TABLES   advap advca advex advcr
                                    USING    ls_post.
      ENDCASE.
      MODIFY gt_post FROM ls_post TRANSPORTING buzei.
    ENDLOOP.

    CASE fu_proc.
      WHEN 'SIMULATE'.
        CLEAR lv_error.
        IF lv_subrc IS INITIAL.
          PERFORM f_bapi_simulate TABLES   advgl advap advar
                                           advca advex advcr
                                  USING    advdh
                                  CHANGING lv_error.
        ELSE.
          lv_error  = 'X'.
        ENDIF.

        IF lv_error IS NOT INITIAL.
          lv_stat   = icon_led_red.
        ELSE.
          IF ls_head-subrc IS INITIAL.
            lv_stat   = icon_led_green.
          ELSE.
            lv_stat   = icon_led_red.
          ENDIF.
        ENDIF.

        LOOP AT gt_post INTO ls_post WHERE vkbur = ls_head-vkbur
                                       AND xblnr = ls_head-xblnr
                                       AND zloct = ls_head-zloct.
          ls_post-icon = lv_stat.
          MODIFY gt_post FROM ls_post TRANSPORTING icon.
        ENDLOOP.

      WHEN 'POSTING'.
        IF lv_subrc IS INITIAL.
          PERFORM f_bapi_posting TABLES   advgl advap advar
                                          advca advex advcr
                                 USING    advdh
                                 CHANGING lv_belnr lv_gjahr.

          LOOP AT gt_post INTO ls_post WHERE vkbur = ls_head-vkbur
                                         AND xblnr = ls_head-xblnr
                                         AND zloct = ls_head-zloct.
            ls_post-belnr = lv_belnr.
            MODIFY gt_post FROM ls_post TRANSPORTING belnr.
          ENDLOOP.

          gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).

          CLEAR lv_znomor.
          READ TABLE gt_proses INTO ls_proses
                               WITH KEY bukrs = ls_head-bukrs
                                        vkbur = ls_head-vkbur
                                        zloct = ls_head-zloct
                                        monat = pa_budat+4(2)
                                        gjahr = pa_budat(4).
          IF sy-subrc = 0.
            lv_znomor = ls_proses-znomor + 1.
          ENDIF.

          UPDATE zfgaji_proses SET znomor       = lv_znomor
                                   post_user    = sy-uname
                                   post_date    = sy-datum
                                   post_belnr   = lv_belnr
                                   post_gjahr   = lv_gjahr
                                   post_files   = pa_filnm
                                   post_budat   = pa_budat
                               WHERE bukrs = ls_head-bukrs
                                 AND vkbur = ls_head-vkbur
                                 AND zloct = ls_head-zloct
                                 AND monat = pa_budat+4(2)
                                 AND gjahr = pa_budat(4)
                                 AND ztype = 'PAYB'.

          CLEAR fc_subrc.
        ELSE.
          MESSAGE s000(zab) WITH 'Data sudah diposting'
                            DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.

    CLEAR : advgl[], advca[], advex[], advcr[],
            advgl, advca, advex, advcr,
            lv_belnr, lv_gjahr.
  ENDLOOP.
ENDFORM.                    " F_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
FORM f_document_header  USING    fu_glvor fu_blart fu_bktxt fu_xblnr
                        CHANGING documentheader    STRUCTURE bapiache09.

  documentheader-bus_act     = fu_glvor.
  documentheader-username    = sy-uname.
  documentheader-comp_code   = pa_bukrs.
  documentheader-doc_date    = pa_budat.
  documentheader-pstng_date  = pa_budat.
  documentheader-doc_type    = fu_blart.
  documentheader-ref_doc_no  = fu_xblnr.
  documentheader-header_txt  = fu_bktxt.
ENDFORM.                    " F_DOCUMENT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_GL
*&---------------------------------------------------------------------*
FORM f_account_gl  TABLES   accountgl         STRUCTURE bapiacgl09
                            currencyamount    STRUCTURE bapiaccr09
                            extension1        STRUCTURE bapiacextc
                            criteria          STRUCTURE bapiackec9
                   USING    fs_post           LIKE LINE OF gt_post
                            fu_gsber.

  DATA : ls_gl      LIKE LINE OF accountgl,
         ls_ca      LIKE LINE OF currencyamount,
         ls_ex      LIKE LINE OF extension1,
         ls_cr      LIKE LINE OF criteria.

  ls_gl-itemno_acc            = fs_post-buzei.
  PERFORM f_alpha_conversion USING fs_post-hkont
                             CHANGING ls_gl-gl_account.
  ls_gl-bus_area              = fu_gsber.
  ls_gl-tax_code              = ''.
  ls_gl-trade_id              = fs_post-vbund.
  ls_gl-costcenter            = fs_post-kostl.
  ls_gl-ref_key_3             = fs_post-xref3.
  ls_gl-alloc_nmbr            = fs_post-zuonr.
  ls_gl-item_text             = fs_post-text.
  APPEND ls_gl TO accountgl.

  ls_ca-itemno_acc            = fs_post-buzei.
  ls_ca-curr_type             = '00'.
  ls_ca-currency              = fs_post-waers.
  ls_ca-exch_rate             = ''.
  PERFORM f_modify_value  USING fs_post-wrbtr '' ''
                          CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_ex(3)                = fs_post-buzei.
  ls_ex+3(2)              = fs_post-bschl.
  APPEND ls_ex TO extension1.

  IF fs_post-kostl+7(3) = '101' OR
    fs_post-kostl+7(3) = '109' OR
    fs_post-kostl+7(3) = '201'.
*    criteria-itemno_acc        = fs_post-buzei.
*    criteria-fieldname         = 'WWSFR'.
*    criteria-character         = fs_post-wwsfr.
*    APPEND criteria.
*    criteria-itemno_acc        = fs_post-buzei.
*    criteria-fieldname         = 'WWPOS'.
*    criteria-character         = fs_post-wwpos.
*    APPEND criteria.

    criteria-itemno_acc        = fs_post-buzei.
    criteria-fieldname         = 'COPA_KOSTL'.
    criteria-character         = fs_post-kostl.
    APPEND criteria.
  ENDIF.
ENDFORM.                    " F_ACCOUNT_GL

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_RECEIVABLE
*&---------------------------------------------------------------------*
FORM f_account_receivable  TABLES   accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    criteria          STRUCTURE bapiackec9
                           USING    fs_post           LIKE LINE OF gt_post.

ENDFORM.                    " F_ACCOUNT_RECEIVABLE

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_PAYABLE
*&---------------------------------------------------------------------*
FORM f_account_payable  TABLES   accountpayable    STRUCTURE bapiacap09
                                 currencyamount    STRUCTURE bapiaccr09
                                 extension1        STRUCTURE bapiacextc
                                 criteria          STRUCTURE bapiackec9
                        USING    fs_post           LIKE LINE OF gt_post.

ENDFORM.                    " F_ACCOUNT_PAYABLE

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_SIMULATE
*&---------------------------------------------------------------------*
FORM f_bapi_simulate  TABLES   accountgl         STRUCTURE bapiacgl09
                               accountpayable    STRUCTURE bapiacap09
                               accountreceivable STRUCTURE bapiacar09
                               currencyamount    STRUCTURE bapiaccr09
                               extension1        STRUCTURE bapiacextc
                               criteria          STRUCTURE bapiackec9
                      USING    documentheader    STRUCTURE bapiache09
                      CHANGING fc_error.

  DATA : ls_return    TYPE bapiret2,
         ls_error     TYPE bapiret2.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'E'.
      fc_error            = 'X'.
      ls_error-type       = ls_return-type.
      ls_error-id         = ls_return-id.
      ls_error-number     = ls_return-number.
      ls_error-message    = ls_return-message.
      ls_error-message_v1 = ls_return-message_v1.
      ls_error-message_v2 = ls_return-message_v2.
      ls_error-message_v3 = ls_return-message_v3.
      APPEND ls_error TO gt_error.
      CLEAR ls_error.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_SIMULATE

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_POSTING
*&---------------------------------------------------------------------*
FORM f_bapi_posting  TABLES   accountgl         STRUCTURE bapiacgl09
                               accountpayable    STRUCTURE bapiacap09
                               accountreceivable STRUCTURE bapiacar09
                               currencyamount    STRUCTURE bapiaccr09
                               extension1        STRUCTURE bapiacextc
                               criteria          STRUCTURE bapiackec9
                      USING    documentheader    STRUCTURE bapiache09
                      CHANGING fc_belnr fc_gjahr.

  DATA : ls_return    TYPE bapiret2,
         ls_error     TYPE bapiret2.

  obj_type = 'BKPF'.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  IF return[] IS NOT INITIAL.
    READ TABLE return INTO ls_return INDEX 1.
    IF ls_return-type = 'S'.
      fc_belnr  = ls_return-message_v2(10).
      fc_gjahr  = ls_return-message_v2+14(4).

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_BAPI_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_CONVERSION
*&---------------------------------------------------------------------*
FORM f_alpha_conversion  USING    fu_value
                         CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_ALPHA_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_INPUT
*&---------------------------------------------------------------------*
FORM f_alpha_input  CHANGING fc_kostl.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fc_kostl
    IMPORTING
      output = fc_kostl.
ENDFORM.                    " F_ALPHA_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ON_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_on_double_click  USING    fu_row fu_column.
  DATA : ls_post     LIKE LINE OF gt_post,
         ls_reverse  LIKE LINE OF gt_reverse,
         ls_report   LIKE LINE OF gt_report.

  CASE fu_column.
    WHEN 'BELNR'.
      READ TABLE gt_post INTO ls_post INDEX fu_row.
      IF sy-subrc = 0.
        IF ls_post-belnr IS NOT INITIAL.
          SET PARAMETER ID 'BLN' FIELD ls_post-belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD ls_post-gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.

    WHEN 'POST_BELNR'.
      CASE 'X'.
        WHEN radio5.
          READ TABLE gt_report INTO ls_report INDEX fu_row.
          IF sy-subrc = 0.
            IF ls_report-post_belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_report-post_belnr.
              SET PARAMETER ID 'BUK' FIELD ls_report-bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_report-post_budat(4).
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          READ TABLE gt_reverse INTO ls_reverse INDEX fu_row.
          IF sy-subrc = 0.
            IF ls_reverse-post_belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_reverse-post_belnr.
              SET PARAMETER ID 'BUK' FIELD ls_reverse-bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_reverse-post_gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN 'REV_BELNR'.
      CASE 'X'.
        WHEN radio5.
          READ TABLE gt_report INTO ls_report INDEX fu_row.
          IF sy-subrc = 0.
            IF ls_report-rev_belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_report-rev_belnr.
              SET PARAMETER ID 'BUK' FIELD ls_report-bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_report-rev_budat(4).
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          READ TABLE gt_reverse INTO ls_reverse INDEX fu_row.
          IF sy-subrc = 0.
            IF ls_reverse-rev_belnr IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD ls_reverse-rev_belnr.
              SET PARAMETER ID 'BUK' FIELD ls_reverse-bukrs.
              SET PARAMETER ID 'GJR' FIELD ls_reverse-post_gjahr.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_ON_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_select.
  DATA : ls_reverse     LIKE LINE OF gt_reverse.
  DATA : lr_selections  TYPE REF TO cl_salv_selections,
         lt_rows        TYPE salv_t_row.

  CASE 'X'.
    WHEN radio4.
      LOOP AT gt_reverse INTO ls_reverse.
        IF fu_select = 'X'.
          APPEND sy-tabix TO lt_rows.
        ENDIF.
        TRY.
            lr_selections = gr_table->get_selections( ).
          CATCH cx_salv_not_found.
        ENDTRY.
        lr_selections->set_selected_rows( lt_rows ).
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE
*&---------------------------------------------------------------------*
FORM f_reverse  USING    fs_reverse  LIKE LINE OF gt_reverse
                CHANGING fc_belnr.
  DATA: lv_stgrd  TYPE stgrd VALUE '01',
        lv_mode,
        lv_update.

  lv_mode   = 'N'.
  lv_update = 'S'.

  CLEAR: t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.

  IF fs_reverse-post_belnr IS NOT INITIAL.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
         'X'  'SAPMF05A'      '0105',
         ' '  'BDC_OKCODE'    '=BU',
         ' '  'RF05A-BELNS'   fs_reverse-post_belnr,
         ' '  'BKPF-BUKRS'    fs_reverse-bukrs,
         ' '  'RF05A-GJAHS'   fs_reverse-gjahr,
         ' '  'UF05A-STGRD'   '01'.

    CALL TRANSACTION 'FB08' USING t_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ROLLBACK WORK.
    ELSE.
      READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        fc_belnr  = t_bdcmsg-msgv1.
        UPDATE zfgaji_proses SET post_user    = space
                                 post_date    = space
                                 post_belnr   = space
                                 post_gjahr   = space
                                 post_files   = space
                                 post_budat   = space
                                 rev_belnr    = fc_belnr
                                 rev_user     = sy-uname
                                 rev_budat    = sy-datum
                             WHERE bukrs = fs_reverse-bukrs
                               AND vkbur = fs_reverse-vkbur
                               AND zloct = fs_reverse-zloct
                               AND monat = fs_reverse-monat
                               AND gjahr = fs_reverse-gjahr
                               AND ztype = 'PAYB'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REVERSE

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table  USING    fu_bukrs fu_vkbur fu_monat fu_gjahr.
  DATA : lv_mess(100).

  CALL FUNCTION 'ENQUEUE_EZFGPROC'
    EXPORTING
      mode_zfgaji_proses = 'E'
      mandt              = sy-mandt
      bukrs              = fu_bukrs
      vkbur              = fu_vkbur
      monat              = fu_monat
      gjahr              = fu_gjahr
      ztype              = 'PAYB'
    EXCEPTIONS
      foreign_lock       = 1
      system_failure     = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    gv_subrc = 9.
    CONCATENATE 'Table Lock by' sy-msgv1 INTO lv_mess
    SEPARATED BY space.
    MESSAGE i000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table .
  DATA : lv_monat   TYPE zfgaji_proses-monat,
         lv_gjahr   TYPE zfgaji_proses-gjahr.

  DATA : ls_head  LIKE LINE OF gt_head.

  lv_monat = pa_budat+4(2).
  lv_gjahr = pa_budat(4).

  LOOP AT gt_head INTO ls_head.
    CALL FUNCTION 'DEQUEUE_EZFGPROC'
      EXPORTING
        bukrs = ls_head-bukrs
        vkbur = ls_head-vkbur
        monat = lv_monat
        gjahr = lv_gjahr
        ztype = 'PAYB'.
  ENDLOOP.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode       TYPE TABLE OF sy-ucomm.

  SET PF-STATUS 'STATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.

  DESCRIBE TABLE gt_appr LINES fill.
  tc_appr-lines = fill.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_subrc   TYPE sy-subrc,
         lv_vkbur   TYPE tvbur-vkbur,
         lv_datum   TYPE sy-datum.

  CASE ok_code.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN '&CLOSE'.
      IF zfgaji_period-closed IS INITIAL.
        PERFORM f_approved_process  USING ''
                                    CHANGING lv_subrc lv_vkbur.
        IF lv_subrc IS INITIAL.
          UPDATE zfgaji_period SET closed = 'X'
                                   userid = sy-uname
                                   waktu  = sy-datum
                               WHERE bukrs = pa_bukrs
                                 AND monat = pa_monat
                                 AND gjahr = pa_gjahr
                                 AND ztype = 'PAYB'.

          CONCATENATE pa_gjahr pa_monat '01' INTO lv_datum.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = lv_datum
            IMPORTING
              last_day_of_month = lv_datum
            EXCEPTIONS
              day_in_no_date    = 1
              OTHERS            = 2.
          IF sy-subrc = 0.
            lv_datum = lv_datum + 1.
          ENDIF.

          zfgaji_period-bukrs = pa_bukrs.
          zfgaji_period-gjahr = lv_datum(4).
          zfgaji_period-monat = lv_datum+4(2).
          zfgaji_period-ztype = 'PAYB'.
          CLEAR : zfgaji_period-closed, zfgaji_period-userid, zfgaji_period-waktu.
          INSERT zfgaji_period.

          IF sy-subrc = 0.
            PERFORM f_approved_process  USING lv_datum
                                        CHANGING lv_subrc lv_vkbur.
            IF lv_subrc = 0.
              gv_text = 'has been closed'.
              MESSAGE s000(zab) WITH 'Period gaji sudah ditutup'.
            ENDIF.
          ENDIF.
        ELSE.
          CASE lv_subrc.
            WHEN 1.
              gv_subrc  = 1.
              MESSAGE s000(zab) WITH 'Cabang' lv_vkbur 'belum approved'
                                DISPLAY LIKE 'E'.
            WHEN 2.
              gv_subrc  = 2.
              MESSAGE s000(zab) WITH 'Cabang' lv_vkbur 'belum proses payroll'
                                DISPLAY LIKE 'E'.
          ENDCASE.
        ENDIF.
      ELSE.
        gv_subrc  = 3.
        MESSAGE s000(zab) WITH 'Period gaji sudah ditutup'
                          DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  READ TABLE gt_appr INTO gs_appr INDEX tc_appr-current_line.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_KEY_VALIDATE
*&---------------------------------------------------------------------*
FORM f_posting_key_validate  USING    fu_value
                             CHANGING fc_value.
  DATA : lv_value(15).

  lv_value  = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.

  IF lv_value < 0.
    CASE fc_value.
      WHEN '40'.
        fc_value = '50'.
      WHEN '50'.
        fc_value = '40'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_POSTING_KEY_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_ZLOCT
*&---------------------------------------------------------------------*
FORM f_value_zloct .

ENDFORM.                    " F_VALUE_ZLOCT
