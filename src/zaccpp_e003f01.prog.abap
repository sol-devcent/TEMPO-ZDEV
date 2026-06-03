*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FILENAME_F4
*&---------------------------------------------------------------------*
FORM f_filename_f4  CHANGING fc_filename.
  DATA : lv_rc  TYPE i.
  DATA : lt_file_table TYPE filetable,
         ls_file_table TYPE file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Select a file'
    CHANGING
      file_table   = lt_file_table
      rc           = lv_rc.
  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    fc_filename = ls_file_table-filename.
  ENDIF.
ENDFORM.                    " F_FILENAME_F4

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FR_EXCEL
*&---------------------------------------------------------------------*
FORM f_upload_fr_excel .
  DATA : lv_doc_name TYPE char256,
         lt_data     TYPE soi_generic_table,
         ls_data     TYPE soi_generic_item,
         lt_ranges   TYPE soi_range_list,
         ls_ranges   TYPE soi_range_item,
         lv_changed  TYPE int4.

  DATA : ls_upload    LIKE LINE OF gt_upload.

  CONCATENATE 'FILE://' filenm INTO lv_doc_name.

  CALL METHOD o_document->open_document
    EXPORTING
      open_inplace   = 'X'
      document_title = 'Excel'
      document_url   = lv_doc_name
      no_flush       = ''
    IMPORTING
      error          = o_error.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Open Spreadsheet interface
  CALL METHOD o_document->get_spreadsheet_interface
    EXPORTING
      no_flush        = ''
    IMPORTING
      sheet_interface = o_spreadsheet
      error           = o_error.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Set selection for 1000 rows
  CALL METHOD o_spreadsheet->set_selection
    EXPORTING
      top     = 1
      left    = 1
      rows    = '1000'
      columns = '36'.

* Define Range in spreadsheet
  CALL METHOD o_spreadsheet->insert_range
    EXPORTING
      name     = 'Sheet1'
      rows     = '1000'
      columns  = '36'
      no_flush = ''
    IMPORTING
      error    = o_error.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

  ls_ranges-name    = 'Sheet1'.
  ls_ranges-rows    = '1000'.
  ls_ranges-columns = '36'.
  APPEND ls_ranges TO lt_ranges.
  CLEAR ls_ranges.

* Get data
  CALL METHOD o_spreadsheet->get_ranges_data
    EXPORTING
      all      = ''
      no_flush = ''
    IMPORTING
      contents = lt_data
      error    = o_error
    CHANGING
      ranges   = lt_ranges.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Close the document
  CALL METHOD o_document->close_document
    EXPORTING
      do_save     = ''
      no_flush    = ''
    IMPORTING
      has_changed = lv_changed
      error       = o_error.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Clear Document Resources
  CALL METHOD o_document->release_document
    EXPORTING
      no_flush = ''
    IMPORTING
      error    = o_error.

  IF o_error->has_failed = 'X'.
    CALL METHOD o_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Clear table of filefq names
  FREE : o_control.

  SORT lt_data BY row column.
  DELETE lt_data WHERE row = '1'.
  LOOP AT lt_data INTO ls_data.
    CASE 'X'.
      WHEN radio1.
        PERFORM f_template1 USING ls_data-column ls_data-value
                            CHANGING ls_upload.
      WHEN radio2.
        PERFORM f_template2 USING ls_data-column ls_data-value
                            CHANGING ls_upload.
    ENDCASE.

    AT END OF row.
      IF ls_upload-aufnr IS NOT INITIAL.
        APPEND ls_upload TO gt_upload.
      ENDIF.
      CLEAR ls_upload.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_FR_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_date_modify  USING    fu_datum
                    CHANGING fc_datum.
  DATA : lv_datum TYPE sy-datum,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  lv_datum  = fu_datum.
  lv_subrc  = 4.
  WHILE lv_subrc IS NOT INITIAL.
    ADD 1 TO lv_count.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_datum
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.

    IF sy-subrc <> 0.
      CASE lv_count.
        WHEN 1.
          CONCATENATE fu_datum(4) fu_datum+5(2) fu_datum+8(2) INTO lv_datum.
        WHEN 2.
          CONCATENATE fu_datum+6(4) fu_datum+4(2) fu_datum(2) INTO lv_datum.
        WHEN 3.
          fc_datum = fu_datum.
          CLEAR lv_subrc.
      ENDCASE.
    ELSE.
      fc_datum  = lv_datum.
      CLEAR lv_subrc.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " F_DATE_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  PERFORM f_batch_detail.
  PERFORM f_get_nie.
  PERFORM f_get_het.
  PERFORM f_get_mara.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  FIELD-SYMBOLS <fs>   TYPE any.

  DATA : ls_upload      LIKE LINE OF gt_upload,
         ls_accdtm      LIKE LINE OF gt_accdtm,
         ls_mch1        LIKE LINE OF gt_mch1,
         ls_t001k       LIKE LINE OF gt_t001k,
         ls_a989        LIKE LINE OF gt_a989,
         ls_konp        LIKE LINE OF gt_konp,
         ls_ztspmmdt002 LIKE LINE OF gt_ztspmmdt002,
         ls_mara        LIKE LINE OF gt_mara.

  LOOP AT gt_upload INTO ls_upload.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = icon_led_green.
    ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-aufnr.
    ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-maktx.
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-werks.
    ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-lgort.
    ASSIGN COMPONENT 'SENUM' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-senum.
    ASSIGN COMPONENT 'AGGR1' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-aggr1.
    ASSIGN COMPONENT 'ZACT1' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-zact1.
    ASSIGN COMPONENT 'PACKDAT1' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-packdat1.
    ASSIGN COMPONENT 'AGGR2' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-aggr2.
    ASSIGN COMPONENT 'ZACT2' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-zact1.
    ASSIGN COMPONENT 'PACKDAT2' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-packdat2.
    ASSIGN COMPONENT 'KEMASAN' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-kemasan.
    ASSIGN COMPONENT 'PSMNG' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-psmng.
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-matnr.
    ASSIGN COMPONENT 'CHARG' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-charg.
    ASSIGN COMPONENT 'GTIN' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-gtin.
    ASSIGN COMPONENT 'NIE' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-nie.
    ASSIGN COMPONENT 'VFDAT' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_upload-vfdat.

    CLEAR ls_ztspmmdt002.
    READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                              WITH KEY werks = ls_upload-werks
                                       matnr = ls_upload-matnr.
    IF sy-subrc = 0.
      IF ls_upload-nie <> ls_ztspmmdt002-nie.
        CLEAR ls_upload-nie.
      ENDIF.
    ENDIF.

    CLEAR ls_mch1.
    READ TABLE gt_mch1 INTO ls_mch1
                       WITH KEY matnr = ls_upload-matnr
                                charg = ls_upload-charg.
    IF sy-subrc = 0.
      IF ls_upload-vfdat <> ls_mch1-vfdat.
        CLEAR ls_upload-vfdat.
      ENDIF.
    ENDIF.

    CLEAR ls_mara.
    READ TABLE gt_mara INTO ls_mara
                       WITH KEY matnr = ls_upload-matnr.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'AMEIN' OF STRUCTURE <fs_ltop> TO <fs>.
      <fs> = ls_mara-meins.
    ENDIF.

*    CLEAR ls_t001k.
*    READ TABLE gt_t001k INTO ls_t001k
*                        WITH KEY bwkey = ls_upload-werks.
*    IF sy-subrc = 0.
*      CLEAR ls_a989.
*      READ TABLE gt_a989 INTO ls_a989
*                         WITH KEY vkorg = ls_t001k-bukrs
*                                  matnr = ls_accdtm-matnr.
*      IF sy-subrc = 0.
*        CLEAR : ls_konp.
*        READ TABLE gt_konp INTO ls_konp
*                           WITH KEY knumh = ls_a989-knumh.
*        IF sy-subrc = 0.
*          ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_ltop> TO <fs>.
*          <fs> = ls_konp-kbetr.
*        ENDIF.
*      ENDIF.
*    ENDIF.

    PERFORM f_prepare_posting USING ls_upload ls_accdtm.

    APPEND <fs_ltop> TO <fs_top>.
    CLEAR <fs_ltop>.
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
  DATA : fcode         TYPE TABLE OF sy-ucomm,
         lv_title(100),
         dynfield(20).

  lv_title  = 'SN Import Product'.
  dynfield  = 'ICON'.

  READ TABLE <fs_top> INTO <fs_ltop>
                      WITH KEY (dynfield) = icon_led_red.
  IF sy-subrc = 0.
    APPEND '&POS' TO fcode.
  ENDIF.

  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE' WITH lv_title.

  PERFORM f_excluding_toolbar USING :
    '&INFO' 'T',
    '&GRAPH' 'T',

    '&INFO' 'B',
    '&GRAPH' 'B'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar  USING    fu_attribute fu_pos.
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = fu_attribute.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_exclude TO gs_exclude_t.
    WHEN 'B'.
      APPEND ls_exclude TO gs_exclude_b.
  ENDCASE.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_SILVER'.

  IF g_maincont IS INITIAL.
    CREATE OBJECT g_maincont
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
        parent  = g_maincont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_top.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_bottom.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TOP_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE top_alv OUTPUT.
  IF g_tgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_top.

    PERFORM f_build_layout USING 'T'.
    PERFORM f_build_sort USING 'T'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickt
                event_receiver->handle_toolbart
                event_receiver->handle_menu_buttont
                event_receiver->handle_user_commandt FOR g_tgrid.

    CALL METHOD g_tgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_t
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_top>[]
        it_fieldcatalog      = gt_fieldcat_t[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " TOP_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tgrid IS NOT INITIAL.
      CALL METHOD g_tgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.

    IF g_bgrid IS NOT INITIAL.
      CALL METHOD g_bgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_pos.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-cwidth_opt          = selected.
  CASE fu_pos.
    WHEN 'T'.
      gs_layout_alv-zebra               = space.
      gs_layout_alv-no_toolbar          = space.
    WHEN 'B'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'T'.
    WHEN 'B'.
*      gt_main_sort-spos      = 1.
*      gt_main_sort-fieldname = ''.
*      gt_main_sort-up        = selected.
*      APPEND gt_main_sort.
*      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
  FROM t001k
  INTO CORRESPONDING FIELDS OF TABLE gt_t001k.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table  USING    fu_pos.
  DATA : fname        TYPE string,
         title        TYPE string,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data.

  CASE fu_pos.
    WHEN 'T'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'ICON' '' '' '' '' '' '' '' '' 'Sts' '' '' '' '' '' 'X' 'X',
        fu_pos 'AUFNR' '' '' '' '' '' '' 'AUFNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'PSMNG' '' '' '' '' 'AMEIN' '' 'PSMNG' 'AFPO' 'Order Qty' '' ''
        '' '' '' '' 'X',
        fu_pos 'AMEIN' '' '' '' '' '' '' 'AMEIN' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' '' 'X',
        fu_pos 'WERKS' '' '' '' '' '' '' 'DWERK' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'LGORT' '' '' '' '' '' '' 'LGORT' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'KEMASAN' '' '' '' '' '' '' 'KEMASAN' 'ZTSPMMDT002' '' '' '' '' '' '' '' '',
        fu_pos 'NIE' '' '' '' '' '' '' 'NIE' 'ZTSPMMDT002' '' '' '' '' '' '' '' '',
        fu_pos 'GTIN' '' '' '' '' '' '' '' '' 'GTIN' '' '' '' '' '' '' '',
        fu_pos 'CHARG' '' '' '' '' '' '' 'CHARG' 'AFPO' '' '' '' '' '' '' '' '',
        fu_pos 'VFDAT' '' '' '' '' '' '' 'VFDAT' 'MCH1' '' '' '' '' '' '' '' '',
        fu_pos 'SENUM' '' '' '' '' '' '' 'SENUM' 'ZACCDTM' '' '' '' '' '' '' '' '',
        fu_pos 'AGGR1' '' '' '' '' '' '' 'AGGR1' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'ZACT1' '' '' '' '' '' '' 'ZACT1' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'PACKDAT1' '' '' '' '' '' '' 'PACKDAT1' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'AGGR2' '' '' '' '' '' '' 'AGGR2' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'ZACT2' '' '' '' '' '' '' 'ZACT2' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'PACKDAT2' '' '' '' '' '' '' 'PACKDAT2' 'ZACCDTA' '' '' '' '' '' '' '' ''.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_t
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_top>.
        CREATE DATA ls_line LIKE LINE OF <fs_top>.
        ASSIGN ls_line->* TO <fs_ltop>.
      ENDIF.

    WHEN 'B'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KUNNR' '' '' '' '' '' '' 'KUNNR' 'KNA1' '' '' '' '' '' '' '' 'X'.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_b
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_bottom>.
        CREATE DATA ls_line LIKE LINE OF <fs_bottom>.
        ASSIGN ls_line->* TO <fs_lbottom>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_no_out fu_edit fu_tech fu_just fu_icon
                               fu_fix.
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
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_dyn_fcat TO gt_fieldcat_t.
    WHEN 'B'.
      APPEND ls_dyn_fcat TO gt_fieldcat_b.
    WHEN OTHERS.
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
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN '&POS'.
*      PERFORM f_posting_data.
      PERFORM f_save_data_accm.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_xitem TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         ls_xitem LIKE LINE OF lt_xitem,
         ls_item  LIKE LINE OF gt_item.

  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code VALUE '01',
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         return           TYPE STANDARD TABLE OF bapiret2,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year.

  goodsmvt_header-pstng_date       = gs_header-pstng_date.
  goodsmvt_header-doc_date         = gs_header-doc_date.
*  goodsmvt_header-header_txt       = mkpf-bktxt.
  goodsmvt_header-ref_doc_no       = gs_header-ref_doc_no.
  goodsmvt_header-pr_uname         = gs_header-pr_uname.
  goodsmvt_header-ver_gr_gi_slip   = gs_header-ver_gr_gi_slip.
  goodsmvt_header-ver_gr_gi_slipx  = gs_header-ver_gr_gi_slipx.

  lt_xitem[] = gt_item[].
  SORT lt_xitem BY plant.
  DELETE ADJACENT DUPLICATES FROM lt_xitem COMPARING plant.
  LOOP AT lt_xitem INTO ls_xitem.
    LOOP AT gt_item INTO ls_item WHERE plant = ls_xitem-plant.
      APPEND ls_item TO goodsmvt_item.
      CLEAR ls_item.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = goodsmvt_code
      IMPORTING
        materialdocument = materialdocument
        matdocumentyear  = matdocumentyear
      TABLES
        goodsmvt_item    = goodsmvt_item
        return           = return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    IF materialdocument IS NOT INITIAL.
      PERFORM f_save_data TABLES goodsmvt_item
                          USING gs_header-pstng_date
                                materialdocument matdocumentyear.

      MESSAGE s000(zab) WITH 'Data already posted' materialdocument.
    ENDIF.
    CLEAR : goodsmvt_item[], return[], materialdocument, matdocumentyear.
  ENDLOOP.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING
*&---------------------------------------------------------------------*
FORM f_prepare_posting  USING    fs_upload   LIKE LINE OF gt_upload
                                 fs_accdtm   LIKE LINE OF gt_accdtm.

  DATA : ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         ls_accdta  LIKE LINE OF gt_accdta.

  ls_zaccdtm-matnr  = fs_upload-matnr.
  ls_zaccdtm-charg  = fs_upload-charg.
  ls_zaccdtm-senum  = fs_upload-senum.
  ls_zaccdtm-werks  = fs_upload-werks.
  ls_zaccdtm-lgort  = fs_upload-lgort.
  ls_zaccdtm-aufnr  = fs_upload-aufnr.
  ls_zaccdtm-erdat  = sy-datum.
  ls_zaccdtm-ernam  = sy-uname.
  ls_zaccdtm-snsta  = 'CRTD'.
  APPEND ls_zaccdtm TO gt_zaccdtm.
  CLEAR ls_zaccdtm.

  ls_accdta-matnr      = fs_upload-matnr.
  ls_accdta-charg      = fs_upload-charg.
  ls_accdta-senum      = fs_upload-senum.
  ls_accdta-aggr1      = fs_upload-aggr1.
  ls_accdta-zact1      = fs_upload-zact1.
  ls_accdta-packdat1   = fs_upload-packdat1.

  ls_accdta-aggr2      = fs_upload-aggr2.
  ls_accdta-zact2      = fs_upload-zact2.
  ls_accdta-packdat2   = fs_upload-packdat2.
  APPEND ls_accdta TO gt_accdta.
  CLEAR ls_accdta.
ENDFORM.                    " F_PREPARE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_MODIFY
*&---------------------------------------------------------------------*
FORM f_alpha_modify  USING    fu_aufnr
                     CHANGING fc_aufnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_aufnr
    IMPORTING
      output = fc_aufnr.
ENDFORM.                    " F_ALPHA_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_BATCH_DETAIL
*&---------------------------------------------------------------------*
FORM f_batch_detail .
  DATA : lt_upload    TYPE STANDARD TABLE OF zaccstp.

  lt_upload[] = gt_upload[].
  SORT lt_upload BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING matnr charg.
  IF lt_upload[] IS NOT INITIAL.
    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN lt_upload
      WHERE matnr = lt_upload-matnr
        AND charg = lt_upload-charg
        AND lvorm = space.
  ENDIF.
ENDFORM.                    " F_BATCH_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_HET
*&---------------------------------------------------------------------*
FORM f_get_het .
  DATA : lt_upload   TYPE STANDARD TABLE OF zaccstp,
         ls_upload   LIKE LINE OF gt_upload,
         lt_a989_key TYPE STANDARD TABLE OF ty_a989_key,
         ls_a989_key LIKE LINE OF lt_a989_key,
         ls_t001k    LIKE LINE OF gt_t001k.

  lt_upload[] = gt_upload[].
  SORT lt_upload BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING werks matnr.
  LOOP AT lt_upload INTO ls_upload.
    READ TABLE gt_t001k INTO ls_t001k
                        WITH KEY bwkey = ls_upload-werks.
    IF sy-subrc = 0.
      ls_a989_key-vkorg   = ls_t001k-bukrs.
      ls_a989_key-matnr   = ls_upload-matnr.
      APPEND ls_a989_key TO lt_a989_key.
      CLEAR ls_a989_key.
    ENDIF.
  ENDLOOP.

  IF lt_a989_key[] IS NOT INITIAL.
    SELECT *
      FROM a989
      INTO CORRESPONDING FIELDS OF TABLE gt_a989
      FOR ALL ENTRIES IN lt_a989_key
      WHERE kappl = 'V'
        AND kschl = 'ZHET'
        AND vkorg = lt_a989_key-vkorg
        AND matnr = lt_a989_key-matnr
        AND datab <= sy-datum
        AND datbi >= sy-datum.

    IF gt_a989[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE gt_konp
        FOR ALL ENTRIES IN gt_a989
        WHERE knumh = gt_a989-knumh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_HET

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data  TABLES   ft_item    STRUCTURE bapi2017_gm_item_create
                  USING    fu_budat fu_mblnr fu_mjahr.
  TRY.
      INSERT zaccdta FROM TABLE gt_accdta.
    CATCH cx_sy_open_sql_db.
  ENDTRY.

  TRY.
      INSERT zaccdtm FROM TABLE gt_zaccdtm.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA_ACCM
*&---------------------------------------------------------------------*
FORM f_save_data_accm .
  DATA: lx_sql_error TYPE REF TO cx_sy_open_sql_db,
        lv_error_msg TYPE string.

  TRY.
      INSERT zaccdtm FROM TABLE gt_zaccdtm.

      IF sy-subrc = 0.
        MESSAGE 'Data berhasil disimpan ke tabel ZACCDTM.' TYPE 'S'.
      ELSE.
        MESSAGE 'Beberapa data gagal disimpan atau sudah ada.' TYPE 'W'.
      ENDIF.

    CATCH cx_sy_open_sql_db INTO lx_sql_error.
      lv_error_msg = lx_sql_error->get_text( ).
      MESSAGE |Gagal menyimpan data: { lv_error_msg }| TYPE 'E'.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FR_HTTP
*&---------------------------------------------------------------------*
FORM f_upload_fr_http .

ENDFORM.                    " F_UPLOAD_FR_HTTP

*&---------------------------------------------------------------------*
*&      Form  F_GET_NIE
*&---------------------------------------------------------------------*
FORM f_get_nie .
  DATA : lt_upload    TYPE STANDARD TABLE OF zaccstp.

  lt_upload[] = gt_upload[].
  SORT lt_upload BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING werks matnr.
  IF lt_upload[] IS NOT INITIAL.
    SELECT *
      FROM ztspmmdt002
      INTO CORRESPONDING FIELDS OF TABLE gt_ztspmmdt002
      FOR ALL ENTRIES IN lt_upload
      WHERE werks    = lt_upload-werks
        AND matnr    = lt_upload-matnr
        AND trandtrc = 'X'.
  ENDIF.
ENDFORM.                    " F_GET_NIE

*&---------------------------------------------------------------------*
*&      Form  F_GET_MARA
*&---------------------------------------------------------------------*
FORM f_get_mara .
  DATA : lt_upload    TYPE STANDARD TABLE OF zaccstp.

  lt_upload[] = gt_upload[].
  SORT lt_upload BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING matnr.
  IF lt_upload[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_upload
      WHERE matnr = lt_upload-matnr.
  ENDIF.
ENDFORM.                    " F_GET_MARA

*&---------------------------------------------------------------------*
*&      Form  F_TEMPLATE1
*&---------------------------------------------------------------------*
FORM f_template1  USING    fu_column fu_value
                  CHANGING fs_upload    TYPE zaccstp.
  CASE fu_column.
    WHEN '1'.
      PERFORM f_alpha_modify USING fu_value
                             CHANGING fs_upload-aufnr.
    WHEN '2'.
      fs_upload-psmng       = fu_value.
    WHEN '3'.
      fs_upload-matnr       = fu_value.
    WHEN '4'.
      fs_upload-maktx       = fu_value.
    WHEN '5'.
      fs_upload-werks       = fu_value.
    WHEN '6'.
      fs_upload-lgort       = fu_value.
    WHEN '7'.
      fs_upload-kemasan     = fu_value.
    WHEN '8'.
      fs_upload-nie         = fu_value.
    WHEN '9'.
      fs_upload-gtin        = fu_value.
    WHEN '10'.
      fs_upload-charg       = fu_value.
    WHEN '11'.
      PERFORM f_date_modify USING fu_value
                            CHANGING fs_upload-vfdat.
    WHEN '12'.
      fs_upload-senum       = fu_value.
    WHEN '13'.
      PERFORM f_date_modify USING fu_value
                            CHANGING fs_upload-hsdat.
*    WHEN '14'.
    WHEN '14'.
      fs_upload-aggr1       = fu_value.
    WHEN '15'.
      fs_upload-zact1       = fu_value.
    WHEN '16'.
      PERFORM f_date_modify USING fu_value
                            CHANGING fs_upload-packdat1.
    WHEN '17'.
      fs_upload-aggr2       = fu_value.
    WHEN '18'.
      fs_upload-zact2       = fu_value.
    WHEN '19'.
      PERFORM f_date_modify USING fu_value
                            CHANGING fs_upload-packdat2.
  ENDCASE.
ENDFORM.                    " F_TEMPLATE1

*&---------------------------------------------------------------------*
*&      Form  F_TEMPLATE2
*&---------------------------------------------------------------------*
FORM f_template2  USING    fu_column fu_value
                  CHANGING fs_upload    TYPE zaccstp.

  CASE fu_column.
    WHEN '1'.
      CALL METHOD zcl_util=>m_acc_split_sn
        EXPORTING
          pvi_senum = fu_value
        IMPORTING
          pvo_senum = fs_upload-senum
          pvo_matnr = fs_upload-matnr
          pvo_charg = fs_upload-charg.
  ENDCASE.
ENDFORM.                    " F_TEMPLATE2

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_TEMPLATE_1
*&---------------------------------------------------------------------*
FORM f_download_template_1 .
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.

  SET PROPERTY OF h_excel 'Visible' = 1.

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  CALL METHOD OF h_mapl 'Add' = h_map.

  PERFORM fill_cell USING 1 1 1 'Order Number'.
  PERFORM fill_cell USING 1 2 1 'Order item quantity'.
  PERFORM fill_cell USING 1 3 1 'Material Number'.
  PERFORM fill_cell USING 1 4 1 'Material Description'.
  PERFORM fill_cell USING 1 5 1 'Plant'.
  PERFORM fill_cell USING 1 6 1 'Storage Location'.
  PERFORM fill_cell USING 1 7 1 'Kemasan'.
  PERFORM fill_cell USING 1 8 1 'NIE'.
  PERFORM fill_cell USING 1 9 1 'GTIN'.
  PERFORM fill_cell USING 1 10 1 'Batch Number'.
  PERFORM fill_cell USING 1 11 1 'Exp. Date'.
  PERFORM fill_cell USING 1 12 1 'Serial Number'.
  PERFORM fill_cell USING 1 13 1 'Manufacture Date'.
*  PERFORM fill_cell USING 1 14 1 'Space'.
  PERFORM fill_cell USING 1 14 1 'Aggregate-1'.
  PERFORM fill_cell USING 1 15 1 'Agg. Flag-1'.
  PERFORM fill_cell USING 1 16 1 'Agg. Date-1'.
  PERFORM fill_cell USING 1 17 1 'Aggregate-2'.
  PERFORM fill_cell USING 1 18 1 'Agg. Flag-2'.
  PERFORM fill_cell USING 1 19 1 'Agg. Date-2'.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM FILL_CELL                                                *
*---------------------------------------------------------------------*
*       sets cell at coordinates i,j to value val boldtype bold       *
*---------------------------------------------------------------------*
FORM fill_cell USING i j bold val.
  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = i #2 = j.
  SET PROPERTY OF h_zl 'Value' = val .
  GET PROPERTY OF h_zl 'Font' = h_f.
  SET PROPERTY OF h_f 'Bold' = bold .
ENDFORM.                    "fill_cell

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio3.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'PFL'.
            screen-active  = 0.
          WHEN 'GRY'.
            screen-input  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'GRY'.
            screen-input  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN radio3.
    WHEN OTHERS.
      IF filenm IS INITIAL.
        PERFORM f_error_selection_screen USING 'PFL' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Error in Posting date'.
  ENDCASE.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN
