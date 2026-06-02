*&---------------------------------------------------------------------*
*&  Include           ZFI_FAKTUR_PROCESSF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
*  PERFORM f_modify_screen USING : 'RAD' '0' '' '' ''.

*  CASE 'X'.
*    WHEN radio2.
*      PERFORM f_modify_screen USING : 'PFI' '0' '' '' ''.
*  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

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
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  DATA : lv_subrc      TYPE sy-subrc,
         lv_mess(100),
         stripped_name TYPE rlgrap-filename,
         extension     TYPE rlgrap-filename.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ELSE.
    PERFORM f_authorization_check CHANGING lv_subrc.
    IF lv_subrc IS NOT INITIAL.
      CONCATENATE 'You do not have authorization for CoCd' pa_bukrs
      INTO lv_mess
      SEPARATED BY space.
      PERFORM f_error_message USING 'PWE' lv_mess.
    ENDIF.
  ENDIF.

  IF pa_filnm IS INITIAL.
    PERFORM f_error_message USING 'PFI' ''.
  ELSE.
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = pa_filnm
      IMPORTING
        stripped_name = stripped_name
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    SPLIT stripped_name AT '.' INTO stripped_name extension.
    TRANSLATE extension TO UPPER CASE.
    CASE 'X'.
      WHEN radio1.
        IF extension <> 'XLS' AND
          extension <> 'XLSX'.
          lv_mess = 'Uploaded file must XLS/XLSX file'.
          PERFORM f_error_message USING 'PFI' lv_mess.
        ENDIF.
      WHEN radio2.
        IF extension <> 'CSV'.
          lv_mess = 'Uploaded file must CSV file'.
          PERFORM f_error_message USING 'PFI' lv_mess.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_SELECTION-SCREEN

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
*&      Form  F_GET_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_f4 CHANGING fc_filnm.
  DATA : file_table TYPE STANDARD TABLE OF file_table,
         rc         TYPE i,
         ls_file    LIKE LINE OF file_table.

*  CALL METHOD cl_gui_frontend_services=>directory_browse
*    EXPORTING
*      window_title    = 'File Directory'
*      initial_folder  = 'C:'
*    CHANGING
*      selected_folder = fc_filnm.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'File Directory'
      default_extension       = '*.*'
    CHANGING
      file_table              = file_table
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE file_table INTO ls_file INDEX 1.
  IF sy-subrc = 0.
    fc_filnm  = ls_file-filename.
  ENDIF.
ENDFORM.                    " F_GET_F4

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
FORM f_authorization_check  CHANGING fc_subrc.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'ACTVT' FIELD '01'
  ID 'BUKRS' FIELD pa_bukrs.

  fc_subrc = sy-subrc.
ENDFORM.                    " F_AUTHORIZATION_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM t001k
    INTO CORRESPONDING FIELDS OF TABLE gt_t001k
    WHERE bukrs = pa_bukrs.

  SELECT SINGLE *
    FROM t001
    INTO CORRESPONDING FIELDS OF gs_t001.

  SELECT *
    FROM t052
    INTO CORRESPONDING FIELDS OF TABLE gt_t052.
ENDFORM.                    " F_INIT_DATA

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
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DPP'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DPP_NILAI_LAIN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP NILAI LAIN' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PPN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPN' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PPNBM'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPNBM' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'WAERS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' 'X' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NPWP_PEMBELI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'NPWP Pembeli' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NPWP_PEMBELI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'NPWP Pembeli' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NAMA_PEMBELI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Nama Pembeli' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'KODE_TRANSAKSI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Kode Transaksi' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NOMOR_FP'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Nomor FP' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'TANGGAL_FP'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Tanggal FP' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'MASA_PAJAK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Masa Pajak' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'TAHUN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Tahun' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'STATUS_FAKTUR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Status Faktur' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PENANDATANGAN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Penandatangan' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'REFERENSI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Referensi' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PENJUAL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Penjual' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PEMUNGUT_PPN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Pemungut PPN' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.

    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_upload_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_excel_upload.
    WHEN radio2.
      PERFORM f_csv_upload.
  ENDCASE.
ENDFORM.                    " F_UPLOAD_DATA

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
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode  TYPE TABLE OF sy-ucomm,
         dynlog TYPE smp_dyntxt.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

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
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMANND

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
  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
*  CLEAR gt_main_sort.
*
*  PERFORM f_alv_sort USING : 1 'WERKS' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

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
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
*  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
*  DATA : lv_style    TYPE lvc_s_styl-style,
*         lt_stylerow TYPE lvc_t_styl,
*         ls_stylerow TYPE lvc_s_styl.
*
*  DATA : ls_out             LIKE LINE OF gt_out.
*
*  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
*    IMPORTING
*      et_fieldcatalog = ls_fieldcatalog[].
*
*  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
*  IF sy-subrc = 0.
*    IF ls_fieldcatalog-edit IS NOT INITIAL.
*      LOOP AT gt_out INTO ls_out.
*        READ TABLE ls_out-style INTO ls_stylerow
*                                WITH KEY fieldname = 'MARK'.
*        IF sy-subrc = 0 AND
*            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*          CONTINUE.
*        ENDIF.
*        ls_out-mark = fu_check.
*        MODIFY gt_out FROM ls_out.
*        CLEAR ls_out.
*      ENDLOOP.
*    ENDIF.
*    PERFORM f_alv_refresh USING 'X'.
*  ENDIF.
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
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_data   LIKE LINE OF gt_data,
         ls_out    LIKE LINE OF gt_out,
         ls_005    LIKE LINE OF gt_005,
         lt_value  TYPE STANDARD TABLE OF string,
         ls_value  LIKE LINE OF lt_value,
         lv_count  TYPE sy-tabix,
         lv_monat  TYPE t247-mnr,
         lv_masatx TYPE zcoretax0005-masatx.

  LOOP AT gt_data INTO ls_data.
    ls_out-npwp_pembeli   = ls_data-npwp_pembeli.
    ls_out-nama_pembeli   = ls_data-nama_pembeli.
    ls_out-kode_transaksi = ls_data-kode_transaksi.
    ls_out-nomor_fp       = ls_data-nomor_fp.
    ls_out-tanggal_fp     = ls_data-tanggal_fp.
    ls_out-masa_pajak     = ls_data-masa_pajak.
    ls_out-tahun          = ls_data-tahun.
    ls_out-status_faktur  = ls_data-status_faktur.
    ls_out-esignstatus    = ls_data-esignstatus.
    PERFORM f_move_amount USING ls_data-dpp
                          CHANGING ls_out-dpp.
    PERFORM f_move_amount USING ls_data-dpp_nilai_lain
                          CHANGING ls_out-dpp_nilai_lain.
    PERFORM f_move_amount USING ls_data-ppn
                          CHANGING ls_out-ppn.
    PERFORM f_move_amount USING ls_data-ppnbm
                          CHANGING ls_out-ppnbm.
    ls_out-waers          = 'IDR'.
    ls_out-penandatangan  = ls_data-penandatangan.
    ls_out-referensi      = ls_data-referensi.
    ls_out-penjual        = ls_data-penjual.
    ls_out-pemungut_ppn   = ls_data-pemungut_ppn.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.

    IF ls_data-status_faktur = 'APPROVED'.
      ls_005-bukrs  = pa_bukrs.
      ls_005-type   = 'FKX'.
      IF lv_masatx IS INITIAL.
        SELECT SINGLE mnr
          FROM t247
          INTO lv_monat
          WHERE spras = 'i'
            AND ltx = ls_data-masa_pajak.
        CONCATENATE ls_data-tahun lv_monat INTO lv_masatx.
      ENDIF.
      ls_005-masatx = lv_masatx.
      SPLIT ls_data-referensi AT space INTO TABLE lt_value.
      CLEAR : ls_value, lv_count, lv_masatx.
      DO 4 TIMES.
        ADD 1 TO lv_count.
        CLEAR ls_value.
        READ TABLE lt_value INTO ls_value INDEX lv_count.
        CASE lv_count.
          WHEN 1.
            ls_005-vkbur  = ls_value.
          WHEN 3.
            ls_005-belnr  = ls_value.
        ENDCASE.
      ENDDO.
      ls_005-fakturno       = ls_data-nomor_fp.
      ls_005-penandatangan  = ls_data-penandatangan.
      ls_005-status_faktur  = ls_data-status_faktur.
      ls_005-esignstatus    = ls_data-esignstatus.
      ls_005-tglprs         = ls_data-tanggal_fp.
      ls_005-npwppembeli    = ls_data-npwp_pembeli.
      ls_005-namapembeli    = ls_data-nama_pembeli.
      ls_005-dpp            = ls_data-dpp.
      ls_005-dpplain        = ls_data-dpp_nilai_lain.
      ls_005-ppn            = ls_data-ppn.
      ls_005-ppnbm          = ls_data-ppnbm.
      ls_005-referensi      = ls_data-referensi.
      CONCATENATE ls_data-tanggal_fp(4) ls_data-tanggal_fp+5(2)
                  ls_data-tanggal_fp+8(2) INTO ls_005-tglprs.
      APPEND ls_005 TO gt_005.
      CLEAR ls_005.
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
*&      Form  F_EXCEL_UPLOAD
*&---------------------------------------------------------------------*
FORM f_excel_upload .
  TYPES : BEGIN OF ty_excel,
            row   LIKE alsmex_tabline-row,
            col   LIKE alsmex_tabline-col,
            value LIKE alsmex_tabline-value,
          END OF ty_excel.

  DATA : lt_excel TYPE STANDARD TABLE OF ty_excel,
         ls_excel LIKE LINE OF lt_excel,
         ls_data  LIKE LINE OF gt_data,
         lt_value TYPE STANDARD TABLE OF string,
         ls_value LIKE LINE OF lt_value,
         ls_t001k LIKE LINE OF gt_t001k.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pa_filnm
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT lt_excel BY row col.
  LOOP AT lt_excel INTO ls_excel.
    CASE ls_excel-col.
      WHEN '0001'.
        ls_data-npwp_pembeli    = ls_excel-value.
      WHEN '0002'.
        ls_data-nama_pembeli    = ls_excel-value.
      WHEN '0003'.
        ls_data-kode_transaksi  = ls_excel-value.
      WHEN '0004'.
        ls_data-nomor_fp        = ls_excel-value.
      WHEN '0005'.
        ls_data-tanggal_fp      = ls_excel-value.
      WHEN '0006'.
        ls_data-masa_pajak      = ls_excel-value.
      WHEN '0007'.
        ls_data-tahun           = ls_excel-value.
      WHEN '0008'.
        ls_data-status_faktur   = ls_excel-value.
      WHEN '0009'.
        ls_data-esignstatus     = ls_excel-value.
      WHEN '0010'.
        ls_data-dpp             = ls_excel-value.
        TRANSLATE ls_data-dpp USING ',.'.
      WHEN '0011'.
        ls_data-dpp_nilai_lain  = ls_excel-value.
        TRANSLATE ls_data-dpp_nilai_lain USING ',.'.
      WHEN '0012'.
        ls_data-ppn             = ls_excel-value.
        TRANSLATE ls_data-ppn USING ',.'.
      WHEN '0013'.
        ls_data-ppnbm           = ls_excel-value.
        TRANSLATE ls_data-ppnbm USING ',.'.
      WHEN '0014'.
        ls_data-penandatangan   = ls_excel-value.
      WHEN '0015'.
        SPLIT ls_excel-value AT space INTO TABLE lt_value.
        CLEAR : ls_value, ls_t001k.
        READ TABLE lt_value INTO ls_value INDEX 1.
        READ TABLE gt_t001k INTO ls_t001k
                            WITH KEY bwkey = ls_value.
        IF sy-subrc = 0.
          ls_data-referensi       = ls_excel-value.
        ELSE.
          gv_subrc = 4.
          EXIT.
        ENDIF.
      WHEN '0016'.
        ls_data-penjual         = ls_excel-value.
      WHEN '0017'.
        ls_data-pemungut_ppn    = ls_excel-value.
    ENDCASE.

    AT END OF row.
      APPEND ls_data TO gt_data.
      CLEAR ls_data.
    ENDAT.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CSV_UPLOAD
*&---------------------------------------------------------------------*
FORM f_csv_upload .
  DATA : lt_csv   TYPE STANDARD TABLE OF kcde_cells,
         ls_csv   LIKE LINE OF lt_csv,
         ls_data  LIKE LINE OF gt_data,
         ls_t001k LIKE LINE OF gt_t001k.

  CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
    EXPORTING
      i_filename      = pa_filnm
      i_separator     = pa_separ
    TABLES
      e_intern        = lt_csv
    EXCEPTIONS
      upload_csv      = 1
      upload_filetype = 2
      OTHERS          = 3.

  SORT lt_csv BY row col.
  LOOP AT lt_csv INTO ls_csv.
    IF ls_csv-row = '0001'.
      CONTINUE.
    ENDIF.
    CASE ls_csv-col.
      WHEN '0002'.
        ls_data-npwp_pembeli    = ls_csv-value.
      WHEN '0003'.
        ls_data-nama_pembeli    = ls_csv-value.
      WHEN '0004'.
        ls_data-kode_transaksi  = ls_csv-value.
      WHEN '0005'.
        ls_data-nomor_fp        = ls_csv-value.
      WHEN '0006'.
        ls_data-tanggal_fp      = ls_csv-value.
      WHEN '0007'.
        ls_data-masa_pajak      = ls_csv-value.
      WHEN '0008'.
        ls_data-tahun           = ls_csv-value.
      WHEN '0009'.
        ls_data-status_faktur   = ls_csv-value.
      WHEN '0010'.
        ls_data-esignstatus     = ls_csv-value.
      WHEN '0011'.
        ls_data-dpp             = ls_csv-value.
        TRANSLATE ls_data-dpp USING ',.'.
      WHEN '0012'.
        ls_data-dpp_nilai_lain  = ls_csv-value.
        TRANSLATE ls_data-dpp_nilai_lain USING ',.'.
      WHEN '0013'.
        ls_data-ppn             = ls_csv-value.
        TRANSLATE ls_data-ppn USING ',.'.
      WHEN '0014'.
        ls_data-ppnbm           = ls_csv-value.
        TRANSLATE ls_data-ppnbm USING ',.'.
      WHEN '0015'.
        ls_data-penandatangan   = ls_csv-value.
      WHEN '0016'.
        CLEAR ls_t001k.
        READ TABLE gt_t001k INTO ls_t001k
                            WITH KEY bwkey = ls_csv-value(4).
        IF sy-subrc = 0.
          ls_data-referensi       = ls_csv-value.
        ELSE.
          gv_subrc = 4.
          EXIT.
        ENDIF.
      WHEN '0017'.
        ls_data-penjual         = ls_csv-value.
      WHEN '0018'.
        ls_data-pemungut_ppn    = ls_csv-value.
    ENDCASE.

    AT END OF row.
      APPEND ls_data TO gt_data.
      CLEAR ls_data.
    ENDAT.
  ENDLOOP.
ENDFORM.

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
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_AMOUNT
*&---------------------------------------------------------------------*
FORM f_move_amount  USING    fu_value
                    CHANGING fc_value.
  TRY.
      fc_value            = fu_value / 100.
    CATCH cx_sy_conversion_no_number.
      TRANSLATE fu_value USING ',.'.
      fc_value = fu_value.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_005     TYPE STANDARD TABLE OF zcoretax0005,
         ls_005     LIKE LINE OF gt_005,
         lt_x005    TYPE STANDARD TABLE OF zcoretax0005,
         ls_x005    LIKE LINE OF lt_x005,
         lt_zfvato  TYPE STANDARD TABLE OF zfvato,
         lt_xfvato  TYPE STANDARD TABLE OF zfvato,
         lt_bkpf    TYPE STANDARD TABLE OF bkpf,
         lt_bseg    TYPE STANDARD TABLE OF bseg,
         lt_kna1    TYPE STANDARD TABLE OF kna1,
         lt_adrc    TYPE STANDARD TABLE OF adrc,
         lt_vbrk    TYPE STANDARD TABLE OF vbrk,
         lt_vbrp    TYPE STANDARD TABLE OF vbrp,
         lt_vbak    TYPE STANDARD TABLE OF vbak,
         lt_vbpa    TYPE STANDARD TABLE OF vbpa,
         lt_vttk    TYPE STANDARD TABLE OF vttk,
         lt_konv    TYPE STANDARD TABLE OF konv,
         lt_002     TYPE STANDARD TABLE OF zgdtxdt0002,
         lt_003     TYPE STANDARD TABLE OF zgdtxdt0003,
         lt_x003    TYPE STANDARD TABLE OF zgdtxdt0003,
         lt_zfvatnm TYPE STANDARD TABLE OF zfvatnm.

  DATA : lv_subrc TYPE sy-subrc,
         lv_form  TYPE zgdtxdt0003-form.

  lt_005[] = gt_005[].
  SORT lt_005 BY bukrs belnr.
  DELETE ADJACENT DUPLICATES FROM lt_005 COMPARING bukrs belnr.
  IF lt_005[] IS NOT INITIAL.
    SELECT *
      FROM zgdtxdt0003
      INTO CORRESPONDING FIELDS OF TABLE lt_x003
      FOR ALL ENTRIES IN lt_005
      WHERE bukrs = lt_005-bukrs
        AND vbeln = lt_005-belnr.
  ENDIF.

  IF gt_005[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      INTO CORRESPONDING FIELDS OF TABLE lt_x005
      FOR ALL ENTRIES IN gt_005
      WHERE bukrs  = gt_005-bukrs
        AND type   = gt_005-type
        AND masatx = gt_005-masatx
        AND vkbur  = gt_005-vkbur
        AND belnr  = gt_005-belnr.

    SELECT *
      FROM zfvatnm
      INTO CORRESPONDING FIELDS OF TABLE lt_zfvatnm
      WHERE vkorg = pa_bukrs.

    PERFORM f_get_zfvato TABLES lt_x005
                                lt_xfvato.
    PERFORM f_get_fi_document TABLES lt_x005
                                     lt_bkpf
                                     lt_bseg.
    PERFORM f_get_customer TABLES lt_bseg
                                  lt_kna1
                                  lt_adrc.
    PERFORM f_get_sd_document TABLES lt_x005
                                     lt_vbrk
                                     lt_vbrp
                                     lt_vbak
                                     lt_vbpa.
    PERFORM f_get_shipment TABLES lt_x005
                                  lt_vttk.
    PERFORM f_get_pricing TABLES lt_vbrk
                                 lt_konv.
  ENDIF.

  SORT lt_x005 BY bukrs type masatx vkbur belnr.
  SORT gt_005 BY bukrs type masatx vkbur belnr.
  LOOP AT lt_x005 INTO ls_x005.
    CLEAR : ls_005.
    READ TABLE gt_005 INTO ls_005
                      WITH KEY bukrs  = ls_x005-bukrs
                               type   = ls_x005-type
                               masatx = ls_x005-masatx
                               vkbur  = ls_x005-vkbur
                               belnr  = ls_x005-belnr
                      BINARY SEARCH.
    IF sy-subrc = 0.
      ls_x005-fakturno      = ls_005-fakturno.
      ls_x005-aenam         = ls_005-aenam.
      ls_x005-aedat         = ls_005-aedat.
      ls_x005-aezet         = ls_005-aezet.
      ls_x005-penandatangan = ls_005-penandatangan.
      ls_x005-status_faktur = ls_005-status_faktur.
      ls_x005-esignstatus   = ls_005-esignstatus.
      ls_x005-tglprs        = ls_005-tglprs.
      ls_x005-npwppembeli   = ls_005-npwppembeli.
      ls_x005-namapembeli   = ls_005-namapembeli.
      PERFORM f_translate_amount USING ls_005-dpp
                                 CHANGING ls_x005-dpp.
      PERFORM f_translate_amount USING ls_005-dpplain
                                 CHANGING ls_x005-dpplain.
      PERFORM f_translate_amount USING ls_005-ppn
                                 CHANGING ls_x005-ppn.
      PERFORM f_translate_amount USING ls_005-ppnbm
                                 CHANGING ls_x005-ppnbm.

*      ls_x005-dpp           = ls_005-dpp.
*      ls_x005-dpplain       = ls_005-dpplain.
*      ls_x005-ppn           = ls_005-ppn.
*      ls_x005-ppnbm         = ls_005-ppnbm.
      ls_x005-referensi     = ls_005-referensi.

      MODIFY lt_x005 FROM ls_x005 TRANSPORTING fakturno aenam aedat aezet
                                               penandatangan status_faktur esignstatus
                                               tglprs npwppembeli namapembeli
                                               dpp dpplain ppn ppnbm referensi
                     WHERE bukrs  = ls_005-bukrs
                       AND type   = ls_005-type
                       AND masatx = ls_005-masatx
                       AND vkbur  = ls_005-vkbur
                       AND belnr  = ls_005-belnr.
    ELSE.
*      lv_subrc = 4.
    ENDIF.

    IF lv_subrc = 0.
      CASE pa_bukrs.
        WHEN '8020' OR '8070'.
          PERFORM f_prepare_zfvato TABLES lt_bkpf
                                          lt_bseg
                                          lt_kna1
                                          lt_adrc
                                          lt_vbrk
                                          lt_vbrp
                                          lt_konv
                                          lt_vbak
                                          lt_vttk
                                          lt_zfvato
                                          lt_zfvatnm
                                   USING ls_x005 ls_005-tglprs.
        WHEN OTHERS.
          PERFORM f_prepare_003 TABLES lt_003
                                       lt_x003
                                USING  ls_005-bukrs ls_005-belnr ls_x005-fakturno.

*          IF pa_bukrs = '8800'.
*            lv_form = 'A5'.
*          ELSE.
*            lv_form = 'A1'.
*          ENDIF.
*          PERFORM f_prepare_zgdtax TABLES lt_vbrk
*                                          lt_vbrp
*                                          lt_bseg
*                                          lt_kna1
*                                          lt_adrc
*                                          lt_vbak
*                                          lt_vbpa
*                                          lt_002
*                                          lt_003
*                                   USING ls_x005 ls_005-tglprs lv_form.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  CLEAR lv_subrc.
  IF lt_x005[] IS NOT INITIAL.
    TRY.
        MODIFY zcoretax0005 FROM TABLE lt_x005.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 3.
    ENDTRY.
  ENDIF.

  COMMIT WORK AND WAIT.

  IF lt_003[] IS NOT INITIAL.
    TRY.
        MODIFY zgdtxdt0003 FROM TABLE lt_003.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 7.
    ENDTRY.
  ENDIF.

  IF lv_subrc = 0.
    IF lt_xfvato[] IS NOT INITIAL.
      TRY.
          DELETE zfvato FROM TABLE lt_xfvato.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.
    ENDIF.

    COMMIT WORK AND WAIT.

    IF lt_zfvato[] IS NOT INITIAL.
      TRY.
          MODIFY zfvato FROM TABLE lt_zfvato.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  IF lv_subrc = 0.
    MESSAGE s000(zab) WITH 'Data already processed'.
  ELSE.
    CASE lv_subrc.
      WHEN 3.
        MESSAGE s000(zab) WITH 'Modify CORETAX table error' DISPLAY LIKE 'E'.
      WHEN 4.
        MESSAGE s000(zab) WITH 'Insert ZFVATO table error' DISPLAY LIKE 'E'.
      WHEN 5.
        MESSAGE s000(zab) WITH 'Insert ZGDTXDT0003 table error' DISPLAY LIKE 'E'.
      WHEN 6.
        MESSAGE s000(zab) WITH 'Insert ZGDTXDT0002 table error' DISPLAY LIKE 'E'.
      WHEN 7.
        MESSAGE s000(zab) WITH 'Modify ZGDTXDT0003 table error' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.
  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_FI_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_fi_document  TABLES   ft_005 STRUCTURE zcoretax0005
                                 ft_bkpf STRUCTURE bkpf
                                 ft_bseg STRUCTURE bseg.
  DATA : lv_koart   TYPE bseg-koart.

  lv_koart  = 'D'.

  IF ft_005[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE ft_bseg
      FOR ALL ENTRIES IN ft_005
      WHERE bukrs = pa_bukrs
        AND belnr = ft_005-belnr
        AND gjahr = ft_005-masatx(4)
        AND koart = lv_koart.

    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE ft_bkpf
      FOR ALL ENTRIES IN ft_005
      WHERE bukrs = pa_bukrs
        AND belnr = ft_005-belnr
        AND gjahr = ft_005-masatx(4).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer  TABLES   ft_bseg STRUCTURE bseg
                              ft_kna1 STRUCTURE kna1
                              ft_adrc STRUCTURE adrc.
  DATA : lt_bseg    TYPE STANDARD TABLE OF bseg.

  lt_bseg[] = ft_bseg[].
  SORT lt_bseg BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING kunnr.
  IF lt_bseg[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE ft_kna1
      FOR ALL ENTRIES IN lt_bseg
      WHERE kunnr = lt_bseg-kunnr.

    IF ft_kna1[] IS NOT INITIAL.
      SELECT *
        FROM adrc
        INTO CORRESPONDING FIELDS OF TABLE ft_adrc
        FOR ALL ENTRIES IN ft_kna1
        WHERE addrnumber = ft_kna1-adrnr.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SD_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_sd_document  TABLES   ft_005 STRUCTURE zcoretax0005
                                 ft_vbrk STRUCTURE vbrk
                                 ft_vbrp STRUCTURE vbrp
                                 ft_vbak STRUCTURE vbak
                                 ft_vbpa STRUCTURE vbpa.
  DATA : lt_vbrp    TYPE STANDARD TABLE OF vbrp.

  IF ft_005[] IS NOT INITIAL.
    SELECT *
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE ft_vbrk
      FOR ALL ENTRIES IN ft_005
      WHERE vbeln = ft_005-belnr.
    IF ft_vbrk[] IS NOT INITIAL.
      SELECT *
        FROM vbrp
        INTO CORRESPONDING FIELDS OF TABLE ft_vbrp
        FOR ALL ENTRIES IN ft_vbrk
        WHERE vbeln = ft_vbrk-vbeln.
    ENDIF.

    SELECT *
      FROM vbpa
      INTO CORRESPONDING FIELDS OF TABLE ft_vbpa
      FOR ALL ENTRIES IN ft_005
      WHERE vbeln = ft_005-belnr
        AND parvw = 'SH'.

    lt_vbrp[] = ft_vbrp[].
    SORT lt_vbrp BY aubel.
    DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING aubel.
    IF lt_vbrp[] IS NOT INITIAL.
      SELECT *
        FROM vbak
        INTO CORRESPONDING FIELDS OF TABLE ft_vbak
        FOR ALL ENTRIES IN lt_vbrp
        WHERE vbeln = lt_vbrp-aubel.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRICING
*&---------------------------------------------------------------------*
FORM f_get_pricing  TABLES   ft_vbrk STRUCTURE vbrk
                             ft_konv STRUCTURE konv.
  DATA : lv_koaid   TYPE konv-koaid.

  lv_koaid    = 'B'.

  IF ft_vbrk[] IS NOT INITIAL.
    SELECT *
      FROM konv
      INTO CORRESPONDING FIELDS OF TABLE ft_konv
      FOR ALL ENTRIES IN ft_vbrk
      WHERE knumv = ft_vbrk-knumv
        AND koaid = lv_koaid
        AND kntyp = space.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ZFVATO
*&---------------------------------------------------------------------*
FORM f_prepare_zfvato  TABLES   ft_bkpf STRUCTURE bkpf
                                ft_bseg STRUCTURE bseg
                                ft_kna1 STRUCTURE kna1
                                ft_adrc STRUCTURE adrc
                                ft_vbrk STRUCTURE vbrk
                                ft_vbrp STRUCTURE vbrp
                                ft_konv STRUCTURE konv
                                ft_vbak STRUCTURE vbak
                                ft_vttk STRUCTURE vttk
                                ft_zfvato STRUCTURE zfvato
                                ft_zfvatnm STRUCTURE zfvatnm
                       USING    fs_x005   TYPE zcoretax0005
                                fu_dudat.

  DATA : ls_zfvato  TYPE zfvato,
         ls_zfvatnm TYPE zfvatnm,
         ls_bkpf    TYPE bkpf,
         ls_bseg    TYPE bseg,
         ls_kna1    TYPE kna1,
         ls_adrc    TYPE adrc,
         ls_vbrk    TYPE vbrk,
         ls_vbrp    TYPE vbrp,
         ls_vbak    TYPE vbak,
         ls_vttk    TYPE vttk,
         ls_konv    TYPE konv.

  DATA : lv_length TYPE i,
         lv_kwert  TYPE konv-kwert,
         lv_subrc  TYPE sy-subrc.

  ls_zfvato-vkorg   = fs_x005-bukrs.
  ls_zfvato-vkbur   = fs_x005-vkbur.
  lv_length = strlen( fs_x005-fakturno ).
  lv_length = lv_length - 8.
  ls_zfvato-vatno   = fs_x005-fakturno+lv_length(8).
  ls_zfvato-vbeln   = fs_x005-belnr.
  ls_zfvato-zuonr   = fs_x005-zuonr.
  ls_zfvato-dueyr   = fs_x005-masatx(4).
  ls_zfvato-erdat   = fs_x005-erdat.
  ls_zfvato-duemm   = fs_x005-masatx+4(2).
*  ls_zfvato-netwr   = fs_x005-dpplain / 100.
  ls_zfvato-netwr   = ( fs_x005-dpplain * 12 / 11 ) / 100.
  ls_zfvato-mwsbk   = fs_x005-ppn / 100.
  ls_zfvato-wrbt1   = fs_x005-ppn / 100.
  ls_zfvato-vatpr   = fs_x005-fakturno.
  ls_zfvato-dudat   = fu_dudat.
  ls_zfvato-vatdt   = fu_dudat.
  ls_zfvato-vatnm   = fs_x005-penandatangan.
*  ls_zfvato-st_post = 'X'.
  ls_zfvato-files   = fs_x005-files.
  CASE pa_bukrs.
    WHEN '8020'.
      ls_zfvato-gsber   = '0200'.
    WHEN OTHERS.
      ls_zfvato-gsber   = fs_x005-vkbur.
  ENDCASE.

  CLEAR : ls_bkpf.
  READ TABLE ft_bkpf INTO ls_bkpf
                     WITH KEY belnr = fs_x005-belnr
                              gjahr = fs_x005-masatx(4).
  IF sy-subrc = 0.
    ls_zfvato-gjahr   = ls_bkpf-gjahr.
    ls_zfvato-blart   = ls_bkpf-blart.
    ls_zfvato-xblnr   = ls_bkpf-xblnr.
    ls_zfvato-budat   = ls_bkpf-budat.
    ls_zfvato-bldat   = ls_bkpf-bldat.
    ls_zfvato-waerk   = ls_bkpf-waers.
    CLEAR : ls_bseg.
    READ TABLE ft_bseg INTO ls_bseg
                       WITH KEY belnr = ls_bkpf-belnr
                                gjahr = ls_bkpf-gjahr.
    IF sy-subrc = 0.
      ls_zfvato-wrbtr   = ls_bseg-wrbtr.
      ls_zfvato-zuonr   = ls_bseg-zuonr.
      ls_zfvato-sgtxt   = ls_bseg-sgtxt.
      ls_zfvato-kunrg   = ls_bseg-kunnr.
      CLEAR : ls_kna1, ls_adrc.
      READ TABLE ft_kna1 INTO ls_kna1
                         WITH KEY kunnr = ls_bseg-kunnr.
      IF sy-subrc = 0.
        ls_zfvato-ort01   = ls_kna1-ort01.
        ls_zfvato-cityc   = ls_kna1-cityc.
        ls_zfvato-pstlz   = ls_kna1-pstlz.
        ls_zfvato-stceg   = ls_kna1-stceg.
        ls_zfvato-adrnr   = ls_kna1-adrnr.
        READ TABLE ft_adrc INTO ls_adrc
                           WITH KEY addrnumber = ls_kna1-adrnr.
        IF sy-subrc = 0.
          ls_zfvato-name_co     = ls_adrc-name_co.
          ls_zfvato-str_suppl1  = ls_adrc-str_suppl1.
          ls_zfvato-str_suppl2  = ls_adrc-str_suppl2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : ls_vbrk, ls_vbrp, ls_vbak, ls_konv, lv_kwert.
  READ TABLE ft_vbrk INTO ls_vbrk
                     WITH KEY vbeln = fs_x005-belnr.
  IF sy-subrc = 0.
    ls_zfvato-vtart   = 'SD'.
    ls_zfvato-fkdat   = ls_vbrk-fkdat.
    ls_zfvato-zterm   = ls_vbrk-zterm.
    ls_zfvato-spart   = ls_vbrk-spart.
    ls_zfvato-vbtyp   = ls_vbrk-vbtyp.
    ls_zfvato-fkart   = ls_vbrk-fkart.
    ls_zfvato-knumv   = ls_vbrk-knumv.
    LOOP AT ft_konv INTO ls_konv WHERE knumv = ls_vbrk-knumv.
      ADD ls_konv-kwert TO lv_kwert.
    ENDLOOP.
    ls_zfvato-tkwert  = lv_kwert.
    READ TABLE ft_vbrp INTO ls_vbrp
                       WITH KEY vbeln = ls_vbrk-vbeln.
    IF sy-subrc = 0.
      ls_zfvato-vbelv   = ls_vbrp-aubel.
      READ TABLE ft_vbak INTO ls_vbak
                         WITH KEY vbeln = ls_vbrp-aubel.
      IF sy-subrc = 0.
        ls_zfvato-mahdt   = ls_vbak-mahdt.
        ls_zfvato-audat   = ls_vbak-audat.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR : ls_vttk.
    READ TABLE ft_vttk INTO ls_vttk
                       WITH KEY tknum = fs_x005-belnr.
    IF sy-subrc = 0.
      lv_subrc = 4.
    ELSE.
      ls_zfvato-vtart  = 'FI'.
      ls_zfvato-fkdat  = ls_bkpf-budat.
      ls_zfvato-dudat  = ls_bkpf-budat.
      ls_zfvato-tkwert = 0.
    ENDIF.
  ENDIF.

  IF lv_subrc = 0.
    CLEAR ls_zfvatnm.
    READ TABLE ft_zfvatnm INTO ls_zfvatnm
                          WITH KEY vkorg = ls_zfvato-vkorg
                                   vkbur = ls_zfvato-vkbur
                                   vtart = ls_zfvato-vtart.
    IF sy-subrc = 0.
      ls_zfvato-vattl   = ls_zfvatnm-vattl.
    ENDIF.
    APPEND ls_zfvato TO ft_zfvato.
  ENDIF.
  CLEAR : ls_zfvato, lv_subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ZGDTAX
*&---------------------------------------------------------------------*
FORM f_prepare_zgdtax  TABLES   ft_vbrk STRUCTURE vbrk
                                ft_vbrp STRUCTURE vbrp
                                ft_bseg STRUCTURE bseg
                                ft_kna1 STRUCTURE kna1
                                ft_adrc STRUCTURE adrc
                                ft_vbak STRUCTURE vbak
                                ft_vbpa STRUCTURE vbpa
                                ft_002 STRUCTURE zgdtxdt0002
                                ft_003 STRUCTURE zgdtxdt0003
                       USING    fs_x005 TYPE zcoretax0005
                                fu_dudat fu_form.

  DATA : ls_002  TYPE zgdtxdt0002,
         ls_003  TYPE zgdtxdt0003,
         ls_vbrk TYPE vbrk,
         ls_vbrp TYPE vbrp,
         ls_bseg TYPE bseg,
         ls_t052 TYPE t052,
         ls_kna1 TYPE kna1,
         ls_adrc TYPE adrc,
         ls_vbak TYPE vbak,
         ls_vbpa TYPE vbpa.

  ls_003-bukrs        = pa_bukrs.
  ls_003-brnch        = pa_bukrs.
  ls_003-fakturno     = fs_x005-fakturno.
  ls_003-masatx       = fs_x005-masatx.
  ls_003-returcount   = '000'.
  ls_003-batal        = space.

  CLEAR : ls_bseg.
  READ TABLE ft_bseg INTO ls_bseg
                     WITH KEY belnr = fs_x005-belnr
                              gjahr = fs_x005-masatx(4).
  IF sy-subrc = 0.
    ls_003-busln        = '99'.
    ls_003-fakcurr      = gs_t001-waers.
    ls_003-zterm        = ls_bseg-zterm.
    ls_003-waerk        = gs_t001-waers.
    ls_003-kunnr        = ls_bseg-kunnr.
    CLEAR : ls_kna1, ls_adrc.
    READ TABLE ft_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_bseg-kunnr.
    IF sy-subrc = 0.
      ls_003-npwp   = ls_kna1-stceg.
      READ TABLE ft_adrc INTO ls_adrc
                         WITH KEY addrnumber = ls_kna1-adrnr.
      IF sy-subrc = 0.
        ls_003-name     = ls_adrc-name_co.
        ls_003-addrs1   = ls_adrc-str_suppl1.
        CONCATENATE ls_adrc-str_suppl2 ls_adrc-str_suppl3 INTO ls_003-addrs2
        SEPARATED BY space.
        ls_003-city     = ls_adrc-location.
        ls_003-postal   = ls_adrc-post_code1.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : ls_vbrk.
  READ TABLE ft_vbrk INTO ls_vbrk
                     WITH KEY vbeln = fs_x005-belnr.
  IF sy-subrc = 0.
    ls_003-busln        = '01'.
    ls_003-fakcurr      = ls_vbrk-waerk.
    ls_003-fakrate      = ls_vbrk-kurrf.
    ls_003-bilrate      = ls_vbrk-kurrf.
    ls_003-zterm        = ls_vbrk-zterm.
    ls_003-spart        = ls_vbrk-spart.
    ls_003-waerk        = ls_vbrk-waerk.
  ENDIF.

  ls_003-form         = 'A1'.
  CASE pa_bukrs.
    WHEN '8050'.
      IF ls_003-spart = '60'.
        ls_003-form         = 'A5'.
      ENDIF.
    WHEN '8800'.
      IF ls_003-spart = '60'.
        ls_003-form         = 'A5'.
      ENDIF.
  ENDCASE.

  CLEAR : ls_t052.
  READ TABLE gt_t052 INTO ls_t052
                     WITH KEY zterm = ls_003-zterm.
  IF sy-subrc = 0.
    ls_003-ztag1        = ls_t052-ztag1.
  ENDIF.

  CLEAR : ls_vbrp, ls_vbak.
  READ TABLE ft_vbrp INTO ls_vbrp
                     WITH KEY vbeln = fs_x005-belnr.
  IF sy-subrc = 0.
    READ TABLE ft_vbak INTO ls_vbak
                       WITH KEY vbeln = ls_vbrp-aubel.
    IF sy-subrc = 0.
      ls_003-bstkd        = ls_vbak-bstnk.
      ls_003-bstdk        = ls_vbak-bstdk.
    ENDIF.
  ENDIF.

  CLEAR : ls_vbpa.
  READ TABLE ft_vbpa INTO ls_vbpa
                     WITH KEY vbeln = fs_x005-belnr.
  IF sy-subrc = 0.
    ls_003-kunag        = ls_vbpa-kunnr.
    ls_003-kunwe        = ls_vbpa-kunnr.
  ENDIF.

  ls_003-fakdat       = fu_dudat.
  ls_003-faktur_type  = 'S'.
  ls_003-fakppn       = fs_x005-ppn / 100.
  ls_003-fakppn_f     = ''.
  ls_003-fakxppnbm    = ''.
  ls_003-fakxppnbm_f  = ''.
  ls_003-fakppnbm     = fs_x005-ppnbm / 100.
  ls_003-fakppnbm_f   = ''.
  ls_003-name2        = ''.
  ls_003-wapu         = 'N'.
  ls_003-sspdat       = ''.
  ls_003-sspval       = ''.
  ls_003-pkpstat      = ''.
  ls_003-cetakke      = ''.
  ls_003-flaga2       = ''.
  ls_003-versi        = ''.
  ls_003-userid       = sy-uname.
  ls_003-udate        = sy-datum.
  ls_003-utime        = sy-uname.
  ls_003-fakgr        = '2'.
  ls_003-fakpph22     = ''.
  ls_003-fakpph23     = ''.
  ls_003-fakdpp       = ''.
  ls_003-pph22pflag   = ''.
  ls_003-vkorg        = fs_x005-bukrs.
  ls_003-gsber        = fs_x005-vkbur.
  ls_003-deliv        = ls_vbrp-vgbel.
  ls_003-lfdat        = ''.
  ls_003-yeartx       = fs_x005-masatx(4).
  ls_003-vbeln        = fs_x005-belnr.
  ls_003-files        = fs_x005-files.
  ls_003-zupos        = ''.
  ls_003-zdpos        = ''.
  ls_003-zzpos        = ''.
  APPEND ls_003 TO ft_003.

  LOOP AT ft_vbrp INTO ls_vbrp WHERE vbeln = fs_x005-belnr.
    ls_002-bukrs      = pa_bukrs.
    ls_002-brnch      = pa_bukrs.
    ls_002-busln      = ls_003-busln.
    ls_002-vbeln      = ls_003-vbeln.
    ls_002-posnr      = ls_vbrp-posnr.
    ls_002-gjahr      = ls_003-masatx(4).
    ls_002-fakturno   = ls_003-fakturno.
    ls_002-fkdat      = ls_003-fakdat.
    ls_002-fkart      = ls_vbrk-fkart.
    ls_002-splitno    = ''.
    ls_002-karoseri   = ''.
    ls_002-masatx     = ls_003-masatx.
    ls_002-matnr      = ls_vbrp-matnr.
    ls_002-itemdiv    = '  '.
    ls_002-item       = ls_vbrp-arktx.
    ls_002-itqty      = '  '.
    ls_002-itqtylast  = '  '.
    ls_002-itamt      = '  '.
    ls_002-itamtlast  = '  '.
    ls_002-itdisc     = '  '.
    ls_002-itdisclast = '  '.
    ls_002-itcurr     = ls_vbrk-waerk.
    ls_002-itoth      = '  '.
    ls_002-itothlast  = '  '.
    ls_002-dpp        = '  '.
    ls_002-dpplast    = '  '.
    ls_002-ppn        = '  '.
    ls_002-ppnlast    = '  '.
    ls_002-ppn2       = '  '.
    ls_002-ppn2last   = '  '.
    ls_002-ppnbm      = '  '.
    ls_002-ppnbmlast  = '  '.
    ls_002-xppnbm     = '  '.
    ls_002-xppnbmlast = '  '.
    ls_002-tarifxpbm  = '  '.
    ls_002-belnr      = ls_vbrk-vbeln.
    ls_002-bilref     = '  '.
    ls_002-rangka     = ''.
    ls_002-mesin      = ''.
    ls_002-th_buat    = ''.
    ls_002-rectype    = '  '.
    ls_002-exclude    = '  '.
    ls_002-skb        = '  '.
    ls_002-skbval     = '  '.
    ls_002-kwitansi   = '  '.
    ls_002-erdt2      = '  '.
    ls_002-dtretur    = '  '.
    ls_002-noretur    = '  '.
    ls_002-form       = fu_form.
    ls_002-pstyv      = '  '.
    ls_002-flaga2     = '  '.
    ls_002-internal   = '  '.
    ls_002-name       = ls_003-name.
    ls_002-stnk       = '  '.
    ls_002-stnklast   = '  '.
    ls_002-wapu       = ls_003-wapu.
    ls_002-ppndate    = '  '.
    ls_002-trcurr     = '  '.
    ls_002-rate_std   = '  '.
    ls_002-rate_tax   = '  '.
    ls_002-versi      = '  '.
    ls_002-userid     = sy-uname.
    ls_002-udate      = sy-datum.
    ls_002-utime      = sy-uzeit.
    ls_002-itamt_f    = '  '.
    ls_002-itdisc_f   = '  '.
    ls_002-itoth_f    = '  '.
    ls_002-dpp_f      = '  '.
    ls_002-ppn_f      = '  '.
    ls_002-ppnbm_f    = '  '.
    ls_002-xppnbm_f   = '  '.
    ls_002-waers      = ls_003-waerk.
    ls_002-meins      = '  '.
    ls_002-pph22      = '  '.
    ls_002-pph23      = '  '.
    ls_002-vrkme      = ls_vbrp-vrkme.
    ls_002-vkorg      = pa_bukrs.
    ls_002-gsber      = fs_x005-vkbur.
    ls_002-spart      = ls_003-spart.
    ls_002-fakgr      = ls_003-fakgr.
    ls_002-zterm      = ls_003-zterm.
    ls_002-ztag1      = ls_003-ztag1.
    ls_002-name2      = ''.
    ls_002-addrs1     = ls_003-addrs1.
    ls_002-addrs2     = ls_003-addrs2.
    ls_002-city       = ls_003-city.
    ls_002-postal     = ls_003-postal.
    ls_002-kunnr      = ls_003-kunnr.
    ls_002-kunrg      = ls_003-kunnr.
    ls_002-npwp       = ls_003-npwp.
    ls_002-kunag      = ls_003-kunag.
    ls_002-kunwe      = ls_003-kunwe.
    ls_002-bstkd      = ls_003-bstkd.
    ls_002-bstdk      = ls_003-bstdk.
    ls_002-deliv      = '  '.
    ls_002-lfdat      = '  '.
    ls_002-yeartx     = ls_003-yeartx.
    ls_002-files      = ls_003-files.
    ls_002-zupos      = ''.
    ls_002-zdpos      = ''.
    ls_002-zzpos      = ''.
    APPEND ls_002 TO ft_002.
    CLEAR ls_002.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_get_shipment  TABLES   ft_x005 STRUCTURE zcoretax0005
                              ft_vttk STRUCTURE vttk.
  IF ft_x005[] IS NOT INITIAL.
    SELECT *
      FROM vttk
      INTO CORRESPONDING FIELDS OF TABLE ft_vttk
      FOR ALL ENTRIES IN ft_x005
      WHERE tknum = ft_x005-belnr.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFVATO
*&---------------------------------------------------------------------*
FORM f_get_zfvato  TABLES   ft_x005 STRUCTURE zcoretax0005
                            ft_zfvato STRUCTURE zfvato.
  IF ft_x005[] IS NOT INITIAL.
    SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE ft_zfvato
      FOR ALL ENTRIES IN ft_x005
      WHERE vkorg = ft_x005-bukrs
        AND vkbur = ft_x005-vkbur
        AND vbeln = ft_x005-belnr
        AND zuonr = ft_x005-zuonr
        AND dueyr = ft_x005-masatx(4).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TRANSLATE_AMOUNT
*&---------------------------------------------------------------------*
FORM f_translate_amount  USING    fu_value
                         CHANGING fc_value.
  DATA : ls_y005    TYPE ty_out.

  PERFORM f_move_amount USING fu_value
                        CHANGING ls_y005-dpp.
  fc_value           = ls_y005-dpp.
  TRANSLATE fc_value USING '. '.
  CONDENSE fc_value NO-GAPS.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_003
*&---------------------------------------------------------------------*
FORM f_prepare_003  TABLES   ft_003 STRUCTURE zgdtxdt0003
                             ft_x003 STRUCTURE zgdtxdt0003
                    USING    fu_bukrs fu_belnr fu_fakturno.
  DATA : ls_x003 TYPE zgdtxdt0003,
         ls_003  TYPE zgdtxdt0003.

  READ TABLE ft_x003 INTO ls_x003
                     WITH KEY bukrs = fu_bukrs
                              vbeln = fu_belnr.
  IF sy-subrc = 0.
    ls_003 = ls_x003.
    ls_003-nocoretax = fu_fakturno.
    APPEND ls_003 TO ft_003.
  ENDIF.
ENDFORM.
