*&---------------------------------------------------------------------*
*&  Include           ZTIMDESFI_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT SINGLE butxt
    FROM t001
    INTO gv_butxt
    WHERE bukrs = pa_bukrs.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO gv_bezei
    WHERE spras = sy-langu
      AND vkbur = pa_vkbur.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'PCO' '0' '' '' '',
                                  'PBT' '0' '' '' ''.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PST' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SZD' '0' '' '' '',
                                      'SVB' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBL' '0' '' '' '',
                                      'PXB' '0' '' '' '',
                                      'PHK' '0' '' '' '',
                                      'PDM' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PST' '0' '' '' '',
                                      'SVB' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBL' '0' '' '' '',
                                      'PXB' '0' '' '' '',
                                      'PHK' '0' '' '' '',
                                      'PDM' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.
  IF pa_vkbur IS INITIAL.
    PERFORM f_error_message USING 'PVK' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_blart IS INITIAL.
        PERFORM f_error_message USING 'PBT' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
      IF pa_bldat IS INITIAL.
        PERFORM f_error_message USING 'PBL' ''.
      ENDIF.
      IF pa_xblnr IS INITIAL.
        PERFORM f_error_message USING 'PXB' ''.
      ENDIF.
      IF pa_hkont IS INITIAL.
        PERFORM f_error_message USING 'PHK' ''.
      ENDIF.
      IF pa_dmbtr IS INITIAL.
        PERFORM f_error_message USING 'PDM' ''.
      ENDIF.
    WHEN radio2.
      IF pa_stgrd IS INITIAL.
        PERFORM f_error_message USING 'PST' ''.
      ENDIF.
      IF pa_belnr IS INITIAL.
        PERFORM f_error_message USING 'PBE' ''.
      ENDIF.
      IF pa_gjahr IS INITIAL.
        PERFORM f_error_message USING 'PGJ' ''.
      ENDIF.
    WHEN radio3.
  ENDCASE.

ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Select the files'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

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
  DATA : lr_abrvw  TYPE RANGE OF abrvw,
         ls_abrvw  LIKE LINE OF lr_abrvw,
         ls_zfacct TYPE zfacct.

  IF pa_cod IS INITIAL.
    ls_abrvw-low    = 'CB'.
    ls_abrvw-sign   = 'I'.
    ls_abrvw-option = 'EQ'.
    APPEND ls_abrvw TO lr_abrvw.
    CLEAR ls_abrvw.
    ls_abrvw-low    = 'CBD'.
    ls_abrvw-sign   = 'I'.
    ls_abrvw-option = 'EQ'.
    APPEND ls_abrvw TO lr_abrvw.
    CLEAR ls_abrvw.
  ELSE.
    ls_abrvw-low    = 'CD'.
    ls_abrvw-sign   = 'I'.
    ls_abrvw-option = 'EQ'.
    APPEND ls_abrvw TO lr_abrvw.
    CLEAR ls_abrvw.
    ls_abrvw-low    = 'COD'.
    ls_abrvw-sign   = 'I'.
    ls_abrvw-option = 'EQ'.
    APPEND ls_abrvw TO lr_abrvw.
    CLEAR ls_abrvw.
  ENDIF.

  SELECT SINGLE waers
    FROM t001
    INTO gv_waers
    WHERE bukrs = pa_bukrs.

  SELECT *
    FROM zcdssd_003
    INTO CORRESPONDING FIELDS OF TABLE gt_003
    WHERE vkorg = pa_bukrs
      AND vkbur = pa_vkbur
      AND knkli IN so_kunnr
      AND vbeln IN so_vbeln
      AND erdat IN so_erdat
      AND abrvw IN lr_abrvw.

  IF gt_003[] IS NOT INITIAL.
    SELECT *
      FROM zfidt010
      INTO CORRESPONDING FIELDS OF TABLE gt_010
      FOR ALL ENTRIES IN gt_003
      WHERE bukrs = pa_bukrs
        AND vkbur = pa_vkbur
        AND vbeva = gt_003-vbeln
        AND stblg = space.

    SELECT *
      FROM vbuk
      INTO CORRESPONDING FIELDS OF TABLE gt_vbuk
      FOR ALL ENTRIES IN gt_003
      WHERE vbeln = gt_003-vbeln.
  ENDIF.

  SELECT SINGLE *
    FROM zfacct
    INTO CORRESPONDING FIELDS OF ls_zfacct
    WHERE bukrs = pa_bukrs
      AND vtart = 'BI'
      AND saknr = pa_hkont.
  IF sy-subrc = 0.
    SELECT *
      FROM skat
      INTO CORRESPONDING FIELDS OF TABLE gt_skat
      WHERE spras = sy-langu
        AND saknr = pa_hkont.
  ELSE.
    gv_subrc = 4.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_003  LIKE LINE OF gt_003,
         ls_out  LIKE LINE OF gt_out,
         lt_x003 TYPE STANDARD TABLE OF zcdssd_003,
         ls_x003 LIKE LINE OF lt_x003,
         lt_kna1 TYPE STANDARD TABLE OF kna1,
         ls_kna1 LIKE LINE OF lt_kna1,
         ls_cust LIKE LINE OF gt_cust,
         ls_010  LIKE LINE OF gt_010,
         ls_vbuk LIKE LINE OF gt_vbuk.

  DATA : lv_payment TYPE bseg-dmbtr,
         lv_cicil   TYPE bseg-dmbtr.

  lt_x003[] = gt_003[].
  SORT lt_x003 BY knkli.
  DELETE ADJACENT DUPLICATES FROM lt_x003 COMPARING knkli.
  IF lt_x003[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE lt_kna1
      FOR ALL ENTRIES IN lt_x003
      WHERE kunnr = lt_x003-knkli
        AND aufsd = space.
  ENDIF.

  LOOP AT lt_x003 INTO ls_x003.
    ls_cust-kunnr  = ls_x003-knkli.
    CLEAR ls_kna1.
    READ TABLE lt_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_x003-knkli.
    IF sy-subrc = 0.
      ls_cust-name1   = ls_kna1-name1.
    ELSE.
      CONTINUE.
    ENDIF.
    ls_cust-waerk  = ls_x003-waerk.
    LOOP AT gt_003 INTO ls_003 WHERE knkli = ls_x003-knkli.
      ls_out-bukrs  = ls_003-vkorg.
      ls_out-vkbur  = ls_003-vkbur.
      ls_out-kunnr  = ls_003-knkli.
      ls_out-vbeva  = ls_003-vbeln.
      CLEAR ls_vbuk.
      READ TABLE gt_vbuk INTO ls_vbuk
                         WITH KEY vbeln = ls_003-vbeln.
      IF sy-subrc = 0.
        IF ls_vbuk-bestk <> 'C'.
          ls_out-icon = icon_led_red.
        ENDIF.
      ENDIF.
      ls_out-kzwi5  = ls_003-amount_dn.
      ls_out-waerk  = ls_003-waerk.
*      ADD ls_out-kzwi5 TO ls_cust-kzwi5.

      CLEAR : ls_010, lv_payment, lv_cicil.
      LOOP AT gt_010 INTO ls_010 WHERE vbeva = ls_003-vbeln.
        ADD ls_010-dmbtr TO lv_payment.
      ENDLOOP.
      lv_cicil      = lv_payment.
      ls_out-pmbtr  = lv_cicil.

      lv_payment = ls_003-amount_dn - lv_payment.
      IF lv_payment <= 0.
        CLEAR ls_out.
        CONTINUE.
      ENDIF.

*      ADD ls_out-kzwi5 TO ls_cust-kzwi5.
      ADD lv_cicil TO ls_cust-umbtr.
      ADD lv_payment TO ls_cust-dmbtr.
      APPEND ls_out TO gt_out.
      CLEAR ls_out.
    ENDLOOP.
    CLEAR ls_out.
    LOOP AT gt_out INTO ls_out WHERE kunnr = ls_x003-knkli.
      ADD ls_out-kzwi5 TO ls_cust-kzwi5.
      CLEAR ls_out.
    ENDLOOP.
    IF ls_cust-kzwi5 <= 0.
      CLEAR ls_cust.
      CONTINUE.
    ENDIF.
    APPEND ls_cust TO gt_cust.
    CLEAR ls_cust.
  ENDLOOP.

  ASSIGN gt_out TO <fs_out>.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio1.
      IF gt_out[] IS NOT INITIAL.
        CALL SCREEN 102.
*    CALL SCREEN 101.
      ENDIF.
    WHEN radio2.
      PERFORM f_alv TABLES gt_header gt_detail.
    WHEN radio3.
      PERFORM f_alv TABLES gt_header gt_detail.
  ENDCASE.
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
  DATA : ls_skat    LIKE LINE OF gt_skat.

  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ELSE.
    CLEAR dynlog.
  ENDIF.

  SET PF-STATUS 'MAIN' EXCLUDING fcode.
  READ TABLE gt_skat INTO ls_skat INDEX 1.
  SET TITLEBAR 'TITLE' WITH ls_skat-txt50.
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
FORM f_user_command USING fu_ucomm    LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter,
         ls_detail LIKE LINE OF gt_detail.

  DATA : lv_ucomm    TYPE sy-ucomm,
         lv_valid    TYPE c,
         lv_text(50).

  lv_ucomm  = ok_code.

  IF fu_ucomm IS NOT INITIAL.
    lv_ucomm = fu_ucomm.
  ENDIF.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&SOLOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_select USING 'X'.
          ENDIF.
        WHEN '0102'.
          PERFORM f_tc_select USING 'X'.
      ENDCASE.

    WHEN '&SAL'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_select USING ''.
          ENDIF.
        WHEN '0102'.
          PERFORM f_tc_select USING ''.
      ENDCASE.

    WHEN '&DEL'.
      CASE sy-dynnr.
        WHEN '0102'.
          PERFORM f_clear_data.
          PERFORM f_cancel_payment USING ''.
      ENDCASE.

    WHEN '&CALC'.
      CASE sy-dynnr.
        WHEN '0102'.
          PERFORM f_clear_data.
          PERFORM f_payment_calculate.
      ENDCASE.

    WHEN '&SIM'.
      CASE sy-dynnr.
        WHEN '0102'.
          PERFORM f_clear_data.
          PERFORM f_prepare_data.
          IF gv_dmbtr = 0.
            PERFORM f_simulate_data.
            IF gt_bapiret2[] IS NOT INITIAL.
              MESSAGE s000(zab) WITH 'Any error, Please check error log'
              DISPLAY LIKE 'E'.
            ELSE.
              MESSAGE s000(zab) WITH 'Data OK'.
            ENDIF.
          ELSE.
            WRITE gv_dmbtr TO lv_text CURRENCY gv_waers.
            MESSAGE s033(rw) WITH lv_text gv_waers DISPLAY LIKE 'E'.
          ENDIF.
      ENDCASE.

    WHEN '&POS'.
      CASE 'X'.
        WHEN radio1.
          CASE sy-dynnr.
            WHEN '0101'.
              CALL METHOD g_tabgrid->check_changed_data
                IMPORTING
                  e_valid = lv_valid.

              IF lv_valid IS NOT INITIAL.
                PERFORM f_posting_data.
              ENDIF.
            WHEN '0102'.
              PERFORM f_posting_data.
              PERFORM f_lock_table USING ''.
              IF gv_subrc = 0.
                MESSAGE s000(zab) WITH 'Document' gv_belnr 'posted'.
                PERFORM f_clear_data.
                LEAVE TO SCREEN 0.
              ELSE.
                MESSAGE s000(zab) WITH 'Error posting' DISPLAY LIKE 'E'.
              ENDIF.
          ENDCASE.
        WHEN radio2.
          READ TABLE gt_detail INTO ls_detail
                               WITH KEY icon = icon_led_red.
          IF sy-subrc = 0.
            MESSAGE s000(zab) WITH 'Document' pa_belnr 'cannot reversed'
            DISPLAY LIKE 'E'.
          ELSE.
            PERFORM f_reverse_document.
          ENDIF.
      ENDCASE.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->set_function_code
            CHANGING
              c_ucomm = lv_ucomm.

          gt_xout[] = gt_out[].
      ENDCASE.

    WHEN '&ILT'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->set_function_code
            CHANGING
              c_ucomm = lv_ucomm.

          CLEAR : gt_filter[].
          CALL METHOD g_tabgrid->get_filtered_entries
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
      ENDCASE.

    WHEN OTHERS.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->set_function_code
            CHANGING
              c_ucomm = lv_ucomm.
      ENDCASE.
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
        it_outtab            = <fs_out>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-sel_mode            = 'A'.
*  gs_layout_alv-box_fname           = 'MARK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
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

*  PERFORM f_alv_sort USING : 1 '' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr  TYPE REF TO cl_abap_structdescr,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         lt_dfies     TYPE ddfields,
         ls_dfies     TYPE dfies,
         ls_fieldcat  TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ICON'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Sts.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'KZWI5'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERK' '' '' '' 'Amount DN' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
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
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        lv_tabix = sy-tabix.

        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
          CLEAR ls_filter.
          READ TABLE gt_filter INTO ls_filter
                               WITH KEY index = lv_tabix.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
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
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : ls_return    LIKE LINE OF return.

  DATA : obj_type     TYPE bapiache09-obj_type.

  IF gt_bapiret2[] IS INITIAL AND
    documentheader IS NOT INITIAL.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = documentheader
      IMPORTING
        obj_type          = obj_type
      TABLES
        accountgl         = accountgl
        accountpayable    = accountpayable
        accountreceivable = accountreceivable
        currencyamount    = currencyamount
        extension1        = extension1
        criteria          = criteria
        return            = return.

    LOOP AT return INTO ls_return.
      IF ls_return-type = 'A' OR ls_return-type = 'E'.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ELSEIF ls_return-type = 'S'.
        gv_belnr    = ls_return-message_v2(10).
        gv_gjahr    = ls_return-message_v2+14(4).
      ENDIF.
    ENDLOOP.

    IF gv_belnr IS NOT INITIAL.
      PERFORM f_save_data.
      IF gv_subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  PERFORM f_move_fieldcat USING fu_currency
                          CHANGING fs_dyn_fcat-currency.
  PERFORM f_move_fieldcat USING fu_cfieldname
                          CHANGING fs_dyn_fcat-cfieldname.
  PERFORM f_move_fieldcat USING fu_quantity
                          CHANGING fs_dyn_fcat-quantity.
  PERFORM f_move_fieldcat USING fu_qfieldname
                          CHANGING fs_dyn_fcat-qfieldname.
  PERFORM f_move_fieldcat USING fu_checkbox
                          CHANGING fs_dyn_fcat-checkbox.
  PERFORM f_move_fieldcat USING fu_edit
                          CHANGING fs_dyn_fcat-edit.
  PERFORM f_move_fieldcat USING fu_outputlen
                          CHANGING fs_dyn_fcat-outputlen.
  PERFORM f_move_fieldcat USING fu_inttype
                          CHANGING fs_dyn_fcat-inttype.
  PERFORM f_move_fieldcat USING fu_no_out
                          CHANGING fs_dyn_fcat-no_out.
  PERFORM f_move_fieldcat USING fu_tech
                          CHANGING fs_dyn_fcat-tech.
  PERFORM f_move_fieldcat USING fu_key
                          CHANGING fs_dyn_fcat-key.
  PERFORM f_move_fieldcat USING fu_fix
                          CHANGING fs_dyn_fcat-fix_column.
  PERFORM f_move_fieldcat USING fu_icon
                          CHANGING fs_dyn_fcat-icon.
  PERFORM f_move_fieldcat USING fu_sum
                          CHANGING fs_dyn_fcat-do_sum.
  PERFORM f_move_fieldcat USING fu_nosum
                          CHANGING fs_dyn_fcat-no_sum.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_MOVE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  DATA : ls_skat LIKE LINE OF gt_skat,
         ls_cust LIKE LINE OF gt_cust.

  CASE sy-dynnr.
    WHEN '0102'.
      DESCRIBE TABLE gt_cust LINES fill1.
      tc_cust-lines = fill1.

      DESCRIBE TABLE gt_out LINES fill2.
      tc_main-lines = fill2.

      PERFORM f_modify_screen USING : 'W01' '0' '' '' ''.

      READ TABLE gt_skat INTO ls_skat INDEX 1.
      IF sy-subrc = 0.
        gv_txt50  = ls_skat-txt50.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  DATA : ls_out   LIKE LINE OF gt_out.

  CASE sy-dynnr.
    WHEN '0102'.
      READ TABLE gt_cust INTO gs_cust INDEX tc_cust-current_line.
      READ TABLE gt_out INTO gs_out INDEX tc_main-current_line.

      IF gs_out-icon = space.
        CLEAR ls_out.
        READ TABLE gt_out INTO ls_out
                          WITH KEY kunnr = gs_out-kunnr
                                   icon  = icon_led_yellow.
        IF sy-subrc <> 0.
          PERFORM f_modify_screen USING : 'D02' '' '0' '' ''.
        ENDIF.
      ELSEIF gs_out-icon = icon_led_red.
        PERFORM f_modify_screen USING : 'D02' '' '0' '' ''.
      ENDIF.

      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY kunnr = gs_cust-kunnr
                                 icon  = icon_led_yellow.
      IF sy-subrc = 0.
        PERFORM f_modify_screen USING : 'D01' '' '0' '' ''.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  CASE sy-dynnr.
    WHEN '0102'.
      MODIFY gt_cust FROM gs_cust INDEX tc_cust-current_line.
      IF gs_out-icon = icon_led_yellow AND
        gs_out-dmbtr = 0.
        CLEAR gs_out-icon.
      ENDIF.
      MODIFY gt_out FROM gs_out INDEX tc_main-current_line.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TC_SELECT
*&---------------------------------------------------------------------*
FORM f_tc_select  USING    fu_check.
  DATA : ls_cust   LIKE LINE OF gt_cust.

  LOOP AT gt_cust INTO ls_cust.
    IF fu_check IS INITIAL.
      ls_cust-mark = space.
    ELSE.
      ls_cust-mark = 'X'.
    ENDIF.
    MODIFY gt_cust FROM ls_cust.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PAYMENT_CALCULATE
*&---------------------------------------------------------------------*
FORM f_payment_calculate .
  DATA : lt_xcust TYPE STANDARD TABLE OF ty_cust,
         ls_xcust LIKE LINE OF lt_xcust,
         lt_xout  TYPE STANDARD TABLE OF ty_out,
         ls_xout  LIKE LINE OF lt_xout,
         ls_cust  LIKE LINE OF gt_cust,
         ls_out   LIKE LINE OF gt_out.

  DATA : lv_dmbtr    TYPE bseg-dmbtr,
         lv_sisa     TYPE bseg-dmbtr,
         lv_selisih  TYPE bseg-dmbtr,
         lv_total    TYPE bseg-dmbtr,
         lv_text(50).

  lv_total = pa_dmbtr / 100.

  lt_xcust[] = gt_cust[].
  DELETE lt_xcust WHERE mark IS INITIAL.
  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE dmbtr = 0.

  LOOP AT lt_xcust INTO ls_xcust.
    ADD ls_xcust-dmbtr TO lv_dmbtr.
  ENDLOOP.

  LOOP AT lt_xout INTO ls_xout.
    IF ls_xout-icon = icon_led_red.
      ls_out-icon = icon_led_yellow.
      MODIFY gt_out FROM ls_out
                    TRANSPORTING icon
                    WHERE kunnr = ls_xout-kunnr
                      AND vbeva = ls_xout-vbeva
                      AND vbevl = ls_xout-vbevl.
    ENDIF.
    ADD ls_xout-dmbtr TO lv_dmbtr.
  ENDLOOP.

  IF lv_dmbtr = lv_total.
    IF lt_xcust[] IS INITIAL.
      DELETE lt_xout WHERE icon <> space.
      LOOP AT lt_xout INTO ls_xout.
        ls_out-icon = icon_led_yellow.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING icon
                      WHERE kunnr = ls_xout-kunnr
                        AND vbeva = ls_xout-vbeva
                        AND vbevl = ls_xout-vbevl.
        CLEAR ls_out.
      ENDLOOP.
    ELSE.
      LOOP AT lt_xcust INTO ls_xcust.
        PERFORM f_cancel_payment USING ls_xcust-kunnr.

        lv_dmbtr = ls_xcust-dmbtr - ls_xcust-kzwi5.
        lv_sisa  = ls_xcust-dmbtr.
        LOOP AT gt_out INTO ls_out WHERE kunnr = ls_xcust-kunnr.
          IF ls_out-icon = icon_led_red.
            CONTINUE.
          ENDIF.
          IF lv_sisa < 0.
            EXIT.
          ENDIF.
          IF lv_dmbtr >= 0.
            ls_out-icon   = icon_led_yellow.
            ls_out-dmbtr  = ls_out-kzwi5.
          ELSE.
            IF lv_sisa > ls_out-kzwi5.
              ls_out-icon   = icon_led_yellow.
              ls_out-dmbtr  = ls_out-kzwi5.
            ELSE.
              ls_out-icon   = icon_led_yellow.
              ls_out-dmbtr  = lv_sisa.
            ENDIF.
            lv_sisa = lv_sisa - ls_out-kzwi5.
          ENDIF.
          MODIFY gt_out FROM ls_out TRANSPORTING icon dmbtr.
          CLEAR ls_out.
        ENDLOOP.
        ls_cust-mark  = space.
        MODIFY gt_cust FROM ls_cust TRANSPORTING mark
                       WHERE kunnr = ls_xcust-kunnr.
      ENDLOOP.
    ENDIF.
  ELSE.
    lv_selisih = lv_dmbtr - lv_total.
    WRITE lv_selisih TO lv_text CURRENCY gv_waers.
    MESSAGE s033(rw) WITH lv_text gv_waers DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_PAYMENT
*&---------------------------------------------------------------------*
FORM f_cancel_payment USING fu_kunnr.
  DATA : lt_xcust TYPE STANDARD TABLE OF ty_cust,
         ls_xcust LIKE LINE OF lt_xcust,
         ls_cust  LIKE LINE OF gt_cust,
         ls_out   LIKE LINE OF gt_out.

  DATA : lv_dmbtr  TYPE bseg-dmbtr.

  CLEAR : gv_dmbtr.

  lt_xcust[] = gt_cust[].
  IF fu_kunnr IS INITIAL.
    DELETE lt_xcust WHERE mark IS INITIAL.
  ELSE.
    DELETE lt_xcust WHERE kunnr <> fu_kunnr.
  ENDIF.

  LOOP AT lt_xcust INTO ls_xcust.
    LOOP AT gt_out INTO ls_out WHERE kunnr = ls_xcust-kunnr.
      IF ls_out-icon = icon_led_red.
        CONTINUE.
      ENDIF.
      CLEAR : ls_out-dmbtr, ls_out-icon.
      MODIFY gt_out FROM ls_out TRANSPORTING icon dmbtr.
      CLEAR ls_out.
    ENDLOOP.
    ls_cust-mark  = space.
    MODIFY gt_cust FROM ls_cust TRANSPORTING mark
                   WHERE kunnr = ls_xcust-kunnr.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : lt_xout              TYPE STANDARD TABLE OF ty_out,
         ls_xout              LIKE LINE OF lt_xout,
         ls_out               LIKE LINE OF gt_out,
         ls_accountgl         LIKE LINE OF accountgl,
         ls_accountreceivable LIKE LINE OF accountreceivable,
         ls_extension1        LIKE LINE OF extension1,
         ls_currencyamount    LIKE LINE OF currencyamount,
         ls_nriv              TYPE nriv.

  DATA : lv_buzei     TYPE bseg-buzei,
         lv_text(50),
         lv_text1(50),
         lv_object    TYPE inri-object,
         lv_zuonr     TYPE bseg-zuonr,
         lv_prefix(3),
         lv_umskz     TYPE bseg-umskz,
         lv_dmbtr     TYPE bseg-dmbtr.

  CLEAR gv_dmbtr.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE dmbtr = 0.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      ADD ls_xout-dmbtr TO gv_dmbtr.
*      ls_out-icon = icon_led_red.
*      MODIFY gt_out FROM ls_out
*                    TRANSPORTING icon
*                    WHERE kunnr = ls_xout-kunnr
*                      AND vbeva = ls_xout-vbeva
*                      AND vbevl = ls_xout-vbevl.
    ENDLOOP.
  ENDIF.

  lv_dmbtr  = pa_dmbtr / 100.
  gv_dmbtr  = gv_dmbtr - lv_dmbtr.

  IF gv_dmbtr = 0.
    WRITE pa_budat TO lv_text DD/MM/YY.
    CONCATENATE 'Pembayaran CBD-' lv_text INTO lv_text.

    lv_umskz    = 'A'.
    IF pa_cod IS INITIAL.
      lv_object = 'ZFNROCBD'.
      lv_prefix = 'CBD'.
    ELSE.
      lv_object = 'ZFNROCOD'.
      lv_prefix = 'COD'.
    ENDIF.

    PERFORM f_number_get_next USING '01' lv_object lv_prefix
                              CHANGING lv_zuonr.

    IF pa_dmbtr <> 0.
      documentheader-bus_act    = 'RFBU'.
      documentheader-username   = sy-uname.
      documentheader-comp_code  = pa_bukrs.
      documentheader-doc_date   = pa_bldat.
      documentheader-pstng_date = pa_budat.
      documentheader-doc_type   = pa_blart.
      documentheader-ref_doc_no = pa_xblnr.
      documentheader-header_txt = lv_text.

      lv_buzei  = 1.

      ls_accountgl-itemno_acc   = lv_buzei.
      ls_accountgl-gl_account   = pa_hkont.
      ls_accountgl-item_text    = lv_text.
      ls_accountgl-bus_area     = pa_vkbur.
      APPEND ls_accountgl TO accountgl.
      CLEAR ls_accountgl.

      ls_extension1(3)          = lv_buzei.
      ls_extension1+3(2)        = '40'.
      APPEND ls_extension1 TO extension1.
      CLEAR ls_extension1.

      ls_currencyamount-itemno_acc    = lv_buzei.
      ls_currencyamount-curr_type     = '00'.
      ls_currencyamount-currency      = gv_waers.
      ls_currencyamount-amt_doccur    = pa_dmbtr.
      APPEND ls_currencyamount TO currencyamount.
      CLEAR ls_currencyamount.

      lt_xout[] = gt_out[].
      DELETE lt_xout WHERE icon <> icon_led_yellow.
      LOOP AT lt_xout INTO ls_xout.
        ADD 1 TO lv_buzei.
        ls_accountreceivable-itemno_acc    = lv_buzei.
        ls_accountreceivable-customer      = ls_xout-kunnr.
        CONCATENATE lv_text ls_xout-vbeva ls_xout-kunnr INTO lv_text1
        SEPARATED BY '-'.
        ls_accountreceivable-item_text     = lv_text1.
        ls_accountreceivable-bus_area      = pa_vkbur.
        ls_accountreceivable-alloc_nmbr    = ls_xout-vbeva.     "lv_zuonr.
        ls_accountreceivable-sp_gl_ind     = lv_umskz.
        APPEND ls_accountreceivable TO accountreceivable.
        CLEAR ls_accountreceivable.

        ls_extension1(3)                = lv_buzei.
        ls_extension1+3(2)              = '19'.
        APPEND ls_extension1 TO extension1.
        CLEAR ls_extension1.

        ls_currencyamount-itemno_acc    = lv_buzei.
        ls_currencyamount-curr_type     = '00'.
        ls_currencyamount-currency      = ls_xout-waerk.
        ls_currencyamount-amt_doccur    = ls_xout-dmbtr * -100.
        APPEND ls_currencyamount TO currencyamount.
        CLEAR ls_currencyamount.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE_DATA
*&---------------------------------------------------------------------*
FORM f_simulate_data .
  DATA : ls_return    LIKE LINE OF return.

  IF documentheader IS NOT INITIAL.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = documentheader
      TABLES
        accountgl         = accountgl
        accountpayable    = accountpayable
        accountreceivable = accountreceivable
        currencyamount    = currencyamount
        extension1        = extension1
        criteria          = criteria
        return            = return.

    LOOP AT return INTO ls_return.
      IF ls_return-type = 'A' OR ls_return-type = 'E'.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  CLEAR : accountgl, accountpayable, accountreceivable,
          currencyamount, extension1, criteria,
          return, gt_bapiret2,
          accountgl[], accountpayable[], accountreceivable[],
          currencyamount[], extension1[], criteria[],
          return[], gt_bapiret2[].
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : lt_010  TYPE STANDARD TABLE OF zfidt010,
         ls_010  LIKE LINE OF lt_010,
         lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout.

  DATA : lv_payst   TYPE zfidt010-payst.

  CLEAR gv_subrc.

  IF pa_cod IS INITIAL.
    lv_payst  = 'CBD'.
  ELSE.
    lv_payst  = 'COD'.
  ENDIF.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE icon <> icon_led_yellow.
  LOOP AT lt_xout INTO ls_xout.
    IF ls_xout-dmbtr = 0.
      CONTINUE.
    ENDIF.
    ls_010-bukrs  = pa_bukrs.
    ls_010-vkbur  = pa_vkbur.
    ls_010-belnr  = gv_belnr.
    ls_010-gjahr  = gv_gjahr.
    ls_010-payst  = lv_payst.
    ls_010-kunnr  = ls_xout-kunnr.
    ls_010-hkont  = pa_hkont.
    ls_010-vbeva  = ls_xout-vbeva.
    ls_010-vbevl  = ls_xout-vbevl.
    ls_010-kzwi5  = ls_xout-kzwi5.
    ls_010-dmbtr  = ls_xout-dmbtr.
    ls_010-waers  = gv_waers.
    ls_010-xblnr  = pa_xblnr.
    ls_010-budat  = pa_budat.
    ls_010-usnam  = sy-uname.
    ls_010-cpudt  = sy-datum.
    ls_010-cputm  = sy-uzeit.
    APPEND ls_010 TO lt_010.
    CLEAR ls_010.
  ENDLOOP.

  IF lt_010[] IS NOT INITIAL.
    TRY.
        INSERT zfidt010 FROM TABLE lt_010.
      CATCH cx_sy_open_sql_db.
        gv_subrc = 4.
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NUMBER_GET_NEXT
*&---------------------------------------------------------------------*
FORM f_number_get_next  USING    fu_range fu_object fu_prefix
                        CHANGING fc_number.
  DATA : lv_number(10).

*  CALL FUNCTION 'NUMBER_GET_NEXT'
*    EXPORTING
*      nr_range_nr             = fu_range
*      object                  = fu_object
*      subobject               = pa_vkbur
*      toyear                  = pa_bldat(4)
*    IMPORTING
*      number                  = lv_number
*    EXCEPTIONS
*      interval_not_found      = 1
*      number_range_not_intern = 2
*      object_not_found        = 3
*      quantity_is_0           = 4
*      quantity_is_not_1       = 5
*      interval_overflow       = 6
*      buffer_overflow         = 7
*      OTHERS                  = 8.

  CONCATENATE fu_prefix pa_bldat+2(2) '/' lv_number INTO fc_number.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_F4_HKONT
*&---------------------------------------------------------------------*
FORM f_f4_hkont  CHANGING fc_hkont.
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab,
         lt_skat    TYPE STANDARD TABLE OF ty_skat,
         ls_skat    LIKE LINE OF lt_skat,
         lt_zfacct  TYPE STANDARD TABLE OF zfacct,
         ls_zfacct  LIKE LINE OF lt_zfacct.

  SELECT *
    FROM zfacct
    INTO CORRESPONDING FIELDS OF TABLE lt_zfacct
    WHERE bukrs = pa_bukrs
      AND vtart = 'BI'.
  IF lt_zfacct[] IS NOT INITIAL.
    SELECT *
      FROM skat
      INTO CORRESPONDING FIELDS OF TABLE lt_skat
      FOR ALL ENTRIES IN lt_zfacct
      WHERE spras = sy-langu
        AND saknr = lt_zfacct-saknr
      ORDER BY PRIMARY KEY.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield         = 'SAKNR'
        dynpprog         = sy-repid
        dynpnr           = sy-dynnr
        dynprofield      = 'PA_HKONT'
        value_org        = 'S'
        callback_program = sy-repid
        callback_form    = 'F4CALLBACK'
      TABLES
        value_tab        = lt_skat
        return_tab       = return_tab.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table  USING    fu_lock.
  DATA : enq    TYPE STANDARD TABLE OF seqg3,
         ls_enq LIKE LINE OF enq.

  DATA : lv_gname     TYPE seqg3-gname,
         lv_object    TYPE nriv-object,
         lv_subobject TYPE nriv-subobject,
         lv_toyear    TYPE nriv-toyear.

  lv_gname       = 'NRIV'.
  IF pa_cod IS INITIAL.
    lv_object = 'ZFNROCBD'.
  ELSE.
    lv_object = 'ZFNROCOD'.
  ENDIF.
  lv_subobject = pa_vkbur.
  lv_toyear    = pa_bldat(4).

  IF fu_lock IS INITIAL.
    CALL FUNCTION 'DEQUEUE_ESNRIV'
      EXPORTING
        object    = lv_object
        subobject = lv_subobject
        toyear    = lv_toyear.
  ELSE.
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gname                 = lv_gname
        guname                = space
      TABLES
        enq                   = enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    LOOP AT enq INTO ls_enq.
      IF ls_enq-garg+3(8) = lv_object AND
        ls_enq-garg+13(4) = lv_subobject AND
        ls_enq-garg+21(4) = lv_toyear.
        gv_uname = ls_enq-guname.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF gv_uname IS INITIAL.
      CALL FUNCTION 'ENQUEUE_ESNRIV'
        EXPORTING
          object         = lv_object
          subobject      = lv_subobject
          toyear         = lv_toyear
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_REVERSE_DATA
*&---------------------------------------------------------------------*
FORM f_get_reverse_data .
  DATA : ls_header LIKE LINE OF gt_header,
         ls_detail LIKE LINE OF gt_detail,
         lt_010    TYPE STANDARD TABLE OF zfidt010,
         ls_010    LIKE LINE OF lt_010,
         lt_x010   TYPE STANDARD TABLE OF zfidt010,
         lt_bsid   TYPE STANDARD TABLE OF bsid,
         ls_bsid   LIKE LINE OF lt_bsid.

  SELECT *
    FROM zfidt010
    INTO CORRESPONDING FIELDS OF TABLE lt_010
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur
      AND belnr = pa_belnr
      AND gjahr = pa_gjahr.

  lt_x010[] = lt_010[].
  SORT lt_x010 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_x010 COMPARING kunnr.
  IF lt_x010[] IS NOT INITIAL .
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE lt_bsid
      FOR ALL ENTRIES IN lt_x010
      WHERE bukrs = pa_bukrs
        AND kunnr = lt_x010-kunnr
        AND belnr = pa_belnr
        AND gjahr = pa_gjahr.
  ENDIF.

  LOOP AT lt_010 INTO ls_010.
    IF gt_header[] IS INITIAL.
      ls_header-bukrs  = ls_010-bukrs.
      ls_header-vkbur  = ls_010-vkbur.
      ls_header-belnr  = ls_010-belnr.
      ls_header-gjahr  = ls_010-gjahr.
      ls_header-budat  = ls_010-budat.
      ls_header-webno  = ls_010-webno.
      ls_header-payst  = ls_010-payst.
      ls_header-xblnr  = ls_010-xblnr.
      ls_header-usnam  = ls_010-usnam.
      ls_header-hkont  = ls_010-hkont.
      APPEND ls_header TO gt_header.
      CLEAR ls_header.
    ENDIF.

    CLEAR ls_bsid.
    READ TABLE lt_bsid INTO ls_bsid
                       WITH KEY kunnr = ls_010-kunnr.
    IF sy-subrc = 0.
      gv_budat          = ls_bsid-budat.
      ls_detail-icon    = icon_led_green.
    ELSE.
      ls_detail-icon    = icon_led_red.
    ENDIF.
    ls_detail-belnr   = ls_010-belnr.
    ls_detail-kunnr   = ls_010-kunnr.
    ls_detail-vbeva   = ls_010-vbeva.
    ls_detail-vbevl   = ls_010-vbevl.
    ls_detail-waers   = ls_010-waers.
    ls_detail-dmbtr   = ls_010-dmbtr.
    APPEND ls_detail TO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_REPORT_DATA
*&---------------------------------------------------------------------*
FORM f_get_report_data .
  DATA : lt_010    TYPE STANDARD TABLE OF zfidt010,
         ls_010    LIKE LINE OF lt_010,
         lt_x010   TYPE STANDARD TABLE OF zfidt010,
         ls_x010   LIKE LINE OF lt_x010,
         ls_header LIKE LINE OF gt_header,
         ls_detail LIKE LINE OF gt_detail,
         lt_bkpf   TYPE STANDARD TABLE OF bkpf,
         ls_bkpf   LIKE LINE OF lt_bkpf,
         lt_kna1   TYPE STANDARD TABLE OF kna1,
         ls_kna1   LIKE LINE OF lt_kna1.

  DATA : lv_outst   TYPE bseg-belnr.

  SELECT *
    FROM zfidt010
    INTO CORRESPONDING FIELDS OF TABLE lt_010
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur
      AND kunnr IN so_kunnr
      AND budat IN so_budat.

  lt_x010[] = lt_010[].
  SORT lt_x010 BY stblg stjah.
  DELETE ADJACENT DUPLICATES FROM lt_x010 COMPARING stblg stjah.
  IF lt_x010[] IS NOT INITIAL.
    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
      FOR ALL ENTRIES IN lt_x010
      WHERE belnr = lt_x010-stblg
        AND gjahr = lt_x010-stjah.
  ENDIF.

  lt_x010[] = lt_010[].
  SORT lt_x010 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_x010 COMPARING kunnr.
  IF lt_x010[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE lt_kna1
      FOR ALL ENTRIES IN lt_x010
      WHERE kunnr = lt_x010-kunnr.
  ENDIF.

  lt_x010[] = lt_010[].
  SORT lt_x010 BY kunnr vbeva cpudt DESCENDING cputm DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_x010 COMPARING kunnr vbeva.
  LOOP AT lt_x010 INTO ls_x010.
    ls_header-bukrs  = ls_x010-bukrs.
    ls_header-vkbur  = ls_x010-vkbur.
    ls_header-kunnr  = ls_x010-kunnr.
    CLEAR ls_kna1.
    READ TABLE lt_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_x010-kunnr.
    IF sy-subrc = 0.
      ls_header-name1 =  ls_kna1-name1.
    ENDIF.
    ls_header-vbeva  = ls_x010-vbeva.
    ls_header-waers  = ls_x010-waers.
    ls_header-kzwi5  = ls_x010-kzwi5.
    ls_header-aprnm  = ls_x010-aprnm.
    ls_header-aprdt  = ls_x010-aprdt.
    ls_header-aprtm  = ls_x010-aprtm.
    ls_header-waers  = ls_x010-waers.

    CLEAR : lv_outst.
    LOOP AT lt_010 INTO ls_010 WHERE kunnr = ls_x010-kunnr
                                 AND vbeva = ls_x010-vbeva.
      ls_detail-kunnr   = ls_010-kunnr.
      ls_detail-vbeva   = ls_010-vbeva.
      ls_detail-vbevl   = ls_010-vbevl.
      ls_detail-payst   = ls_010-payst.
      CASE ls_010-hkont(4).
        WHEN '0112'.
          ls_detail-stats   = 'CASH'.
        WHEN '0113'.
          ls_detail-stats   = 'BANK'.
      ENDCASE.
      ls_detail-hkont   = ls_010-hkont.
      ls_detail-belnr   = ls_010-belnr.
      ls_detail-gjahr   = ls_010-gjahr.
      ls_detail-xblnr   = ls_010-xblnr.
      ls_detail-budat   = ls_010-budat.
      ls_detail-waers   = ls_010-waers.
      ls_detail-dmbtr   = ls_010-dmbtr.
      ls_detail-usnam   = ls_010-usnam.
      ls_detail-cpudt   = ls_010-cpudt.
      ls_detail-cputm   = ls_010-cputm.
      ls_detail-stblg   = ls_010-stblg.
      CLEAR ls_bkpf.
      READ TABLE lt_bkpf INTO ls_bkpf
                         WITH KEY belnr = ls_010-stblg
                                  gjahr = ls_010-stjah.
      IF sy-subrc = 0.
        ls_detail-revnm   = ls_bkpf-usnam.
      ENDIF.
      ls_detail-revdt   = ls_010-revdt.

      ADD ls_010-dmbtr TO lv_outst.
      APPEND ls_detail TO gt_detail.
      CLEAR ls_detail.
    ENDLOOP.
    ls_header-outst  = ls_header-kzwi5 - lv_outst.
    IF ls_header-outst < 0.
      ls_header-outst = 0.
    ENDIF.
    APPEND ls_header TO gt_header.
    CLEAR ls_header.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv  TABLES   ft_header ft_detail.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_hierarchy      TABLES  ft_header ft_detail.
  PERFORM f_build_layout_hierarchy        USING   d_layout.
  PERFORM f_build_keyinfo_hierarchy       USING   d_alv_keyinfo.
  PERFORM f_build_sortfield_hierarchy     USING   t_alv_isort[].
  PERFORM f_build_event                   TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print_hierarchy         USING   d_print.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_HEADER'
      i_tabname_item           = 'GT_DETAIL'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_header
      t_outtab_item            = ft_detail
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA : fcode       TYPE TABLE OF sy-ucomm,
         lv_text(50).

  CASE 'X'.
    WHEN radio2.
      CONCATENATE 'Reverse' pa_belnr INTO lv_text
      SEPARATED BY space.
    WHEN radio3.
      APPEND '&POS' TO fcode.
      lv_text = 'Report'.
  ENDCASE.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  SET TITLEBAR 'TITLE' WITH lv_text.
ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_GUI_MESSAGE
*&---------------------------------------------------------------------*
FORM f_gui_message  USING    fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data .
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy  TABLES   ft_report1 ft_report2.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN radio2.
      PERFORM f_fieldcatg USING 'GT_HEADER':
        'BUKRS' 'ZFIDT010' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFIDT010' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFIDT010' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFIDT010' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'ZFIDT010' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WEBNO' 'ZFIDT010' 'WEBNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PAYST' 'ZFIDT010' 'PAYST' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'XBLNR' 'ZFIDT010' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'ZFIDT010' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'USNAM' 'ZFIDT010' 'USNAM' '' '' '' '' '' '' '' '' '' '' '' '' ''.

      PERFORM f_fieldcatg USING 'GT_DETAIL':
        'ICON' '' '' '' '' 'Sts' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFIDT010' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VBEVA' 'ZFIDT010' 'VBEVA' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VBEVL' 'ZFIDT010' 'VBEVL' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'ZFIDT010' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DMBTR' 'ZFIDT010' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.

    WHEN radio3.
      PERFORM f_fieldcatg USING 'GT_HEADER':
        'BUKRS' 'ZFIDT010' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFIDT010' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFIDT010' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VBEVA' 'ZFIDT010' 'VBEVA' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'ZFIDT010' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KZWI5' 'ZFIDT010' 'KZWI5' '' '' 'Nilai SO' '' '' '' '' ''
        'WAERS' '' '' '' '',
        'APRNM' 'ZFIDT010' 'APRNM' '' '12' 'User Approve' '' '' '' '' ''
        '' '' '' '' '',
        'APRDT' 'ZFIDT010' 'APRDT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'APRTM' 'ZFIDT010' 'APRTM' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'OUTST' 'ZFIDT010' 'DMBTR' '' '' 'Outstanding Pay' '' '' '' '' ''
        'WAERS' '' '' '' ''.

      PERFORM f_fieldcatg USING 'GT_DETAIL':
        'VBEVL' 'ZFIDT010' 'VBEVL' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PAYST' 'ZFIDT010' 'PAYST' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STATS' '' '' '' '' 'Cash/Bank' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'ZFIDT010' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFIDT010' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFIDT010' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'XBLNR' 'ZFIDT010' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'ZFIDT010' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'ZFIDT010' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DMBTR' 'ZFIDT010' 'DMBTR' '' '' 'Amount Payment' '' '' '' '' ''
        'WAERS' '' '' '' '',
        'USNAM' 'ZFIDT010' 'USNAM' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CPUDT' 'ZFIDT010' 'CPUDT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CPUTM' 'ZFIDT010' 'CPUTM' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STBLG' 'ZFIDT010' 'STBLG' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'REVNM' '' '' '' '' 'User Reverse' '' '' '' '' '' '' '' '' '' '',
        'REVDT' 'ZFIDT010' 'REVDT' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_DETAIL'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING   VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_layout_hierarchy  USING    fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = ' '.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHKBX'.
  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_keyinfo_hierarchy  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'KUNNR'.
  fu_keyinfo-item01   = 'KUNNR'.
  fu_keyinfo-header02 = 'VBEVA'.
  fu_keyinfo-item02   = 'VBEVA'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_sortfield_hierarchy  USING    fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event  TABLES   ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
FORM f_build_event_exit .
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_print_hierarchy  USING    fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_reverse_document .
  DATA : lv_budat TYPE bkpf-budat,
         lv_belnr TYPE bkpf-belnr,
         lv_subrc TYPE sy-subrc.

  CALL FUNCTION 'CALL_FB08'
    EXPORTING
      i_bukrs      = pa_bukrs
      i_belnr      = pa_belnr
      i_gjahr      = pa_gjahr
      i_stgrd      = pa_stgrd
      i_budat      = gv_budat
    IMPORTING
      e_budat      = lv_budat
    EXCEPTIONS
      not_possible = 1
      OTHERS       = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = sy-msgv1
      IMPORTING
        output = lv_belnr.

    IF lv_belnr IS NOT INITIAL.
      TRY.
          UPDATE zfidt010 SET stblg = lv_belnr
                              stjah = lv_budat(4)
                              revdt = lv_budat
                              revtm = sy-uzeit
                          WHERE bukrs = pa_bukrs
                            AND vkbur = pa_vkbur
                            AND belnr = pa_belnr
                            AND gjahr = pa_gjahr.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.

      IF lv_subrc = 0.
        MESSAGE s312(f5) WITH lv_belnr pa_bukrs.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
