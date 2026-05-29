*&---------------------------------------------------------------------*
*&  Include           ZUPLOAD_FORECASTF01
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION .
  PUBLIC SECTION .
    METHODS:
**Hot spot Handler
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,
**Double Click Handler
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,
**Top Of Page
      top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid
        IMPORTING e_dyndoc_id.

ENDCLASS.                    "lcl_event_handler DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
*Handle Hotspot Click
  METHOD handle_hotspot_click .
    CLEAR: gv_row,gv_column,gv_row_num.
    gv_row  = e_row_id.
    gv_column = e_column_id.
    gv_row_num = es_row_no.
*    MESSAGE i000 WITH gv_row 'clicked'.
  ENDMETHOD.                    "lcl_event_handler

*Handle Double Click
  METHOD  handle_double_click.

  ENDMETHOD.                    "handle_double_click

  METHOD top_of_page.                   "implementation
* Top-of-page event
    PERFORM event_top_of_page USING dg_dyndoc_id.
  ENDMETHOD.                            "top_of_page
ENDCLASS.                    "LCL_EVENT_HANDLER IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILENAME
*&---------------------------------------------------------------------*
FORM f_get_filename .
  DATA: lv_repid LIKE sy-repid.
  lv_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = lv_repid
      dynpro_number = sy-dynnr
      field_name    = 'P_FILENM'
    IMPORTING
      file_name     = p_filenm
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    CLEAR p_filenm.
  ENDIF.
ENDFORM.                    " F_GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  CASE 'X'.
    WHEN butt2.
      IF gs_003 IS INITIAL.
        CALL METHOD zcl_util=>m_upload_excel_to_itab
          EXPORTING
            pvi_table = 'ZTIAMFIST002'
            pvi_bcol  = p_cbegin
            pvi_ecol  = p_cend
            pvi_brow  = p_rbegin
            pvi_erow  = p_rend
            pv_filenm = p_filenm
          IMPORTING
            pto_data  = gt_002[].   "gt_out[].

        IF gt_002[] IS INITIAL.     "gt_out[] IS INITIAL.
          MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
          STOP.
        ENDIF.
      ELSE.
        CASE gs_003-typename.
          WHEN 'ZTIAMFIST0021'.
            PERFORM f_new_upload_data USING 'ZTIAMFIST0021'.
          WHEN 'ZTIAMFIST0022'.
            PERFORM f_new_upload_data USING 'ZTIAMFIST0022'.
          WHEN 'ZTIAMFIST0023'.
            PERFORM f_new_upload_data USING 'ZTIAMFIST0023'.
          WHEN OTHERS.
            p_cend = 8.
            CALL METHOD zcl_util=>m_upload_excel_to_itab
              EXPORTING
                pvi_table = 'ZTIAMFIST002N'
                pvi_bcol  = p_cbegin
                pvi_ecol  = p_cend
                pvi_brow  = p_rbegin
                pvi_erow  = p_rend
                pv_filenm = p_filenm
              IMPORTING
                pto_data  = gt_002n[].   "gt_out[].

            IF gt_002n[] IS INITIAL.     "gt_out[] IS INITIAL.
              MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
              STOP.
            ENDIF.
        ENDCASE.
      ENDIF.

    WHEN butt4.
      PERFORM f_move_excel_to_jurnal_asset.

      IF gt_detail[] IS INITIAL.
        MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

    WHEN butt6.
      PERFORM f_move_excel_to_partial.

      IF gt_asset[] IS INITIAL.
        MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: lv_zno TYPE zno.

  FIELD-SYMBOLS : <fs>      TYPE any.

  CASE 'X'.
    WHEN butt2.
      IF gs_003 IS INITIAL.
        ASSIGN gt_002 TO <fs_data>.
        LOOP AT <fs_data> ASSIGNING <fs_line>.
          ADD 1 TO lv_zno.
          ASSIGN COMPONENT 'ZNO' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lv_zno.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = p_bukrs.
          ASSIGN COMPONENT 'ANLKL' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = p_anlkl.
        ENDLOOP.
      ELSE.
        CASE gs_003-typename.
          WHEN 'ZTIAMFIST0021'.
          WHEN 'ZTIAMFIST0022'.
          WHEN 'ZTIAMFIST0023'.
          WHEN OTHERS.
            ASSIGN gt_002n TO <fs_data>.
        ENDCASE.

        LOOP AT <fs_data> ASSIGNING <fs_line>.
          ADD 1 TO lv_zno.
          ASSIGN COMPONENT 'ZNO' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lv_zno.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = p_bukrs.
          ASSIGN COMPONENT 'ANLKL' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = p_anlkl.
        ENDLOOP.
      ENDIF.
    WHEN butt4.
      PERFORM f_validate_jurnal_asset.
      ASSIGN gt_detail TO <fs_out1>.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

  SELECT SINGLE *
    FROM ztiamfidt003
    INTO CORRESPONDING FIELDS OF gs_003
    WHERE bukrs = p_bukrs
      AND anlkl = p_anlkl.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN butt2.
      CALL SCREEN 100.
    WHEN butt4.
      CALL SCREEN 101.
    WHEN butt6.
      CALL SCREEN 101.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .
  CLEAR gt_out.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  DATA g_event_handler TYPE REF TO lcl_event_handler.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR fcode[].

  IF gv_create IS INITIAL.
    IF gv_test IS INITIAL.
      APPEND '&CREATE' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
    ELSE.
      APPEND '&TEST' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
    ENDIF.
  ELSE.
    SET PF-STATUS 'STATUS_0100'.
  ENDIF.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

*    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sortfield.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

* Create Header
*    PERFORM f_header_alv.

* Create_object_grid
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

* Create_display_ALV
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
        i_default            = 'X'
        i_save               = 'A'
        is_variant           = gs_variant
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_outtab            = <fs_data>[]    "gt_out[]
        it_sort              = gt_sort[].

* Initializing document
*    CALL METHOD dg_dyndoc_id->initialize_document.

* Processing events
*    CALL METHOD g_grid->list_processing_events
*      EXPORTING
*        i_event_name = 'TOP_OF_PAGE'
*        i_dyndoc_id  = dg_dyndoc_id.

* When edit display
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.                 " PBO100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_OUT':
    'ZNO' 'ZTIAMFIST002' 'ZNO' '' '' 'No.' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ICONID' 'ZTIAMFIST002' 'ICONID' '' '' 'Icon' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ANLKL' 'ZTIAMFIST002' 'ANLKL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'ZTIAMFIST002' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TXT50' 'ZTIAMFIST002' 'TXT50' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'ZTIAMFIST002' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CAUFN' 'ZTIAMFIST002' 'CAUFN' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AFABG' 'ZTIAMFIST002' 'AFABG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ANLN1' 'ZTIAMFIST002' 'ANLN1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ANLN2' 'ZTIAMFIST002' 'ANLN2' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MESSAGE' 'ZTIAMFIST002' 'MESSAGE' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
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
                          VALUE(fu_emphasize)
                          VALUE(fu_hotspot)
                          VALUE(fu_edit)
                          VALUE(fu_no_zero).

  DATA: ld_fieldcat  TYPE  lvc_t_fcat WITH HEADER LINE.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-hotspot           = fu_hotspot.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-no_zero           = fu_no_zero.
  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
  gs_layout-no_rowmark  = 'X'.
  gs_layout-no_toolbar  = 'X'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

*  CLEAR gt_sort.
*  gt_sort-spos      = '1'.
*  gt_sort-fieldname = 'MATNR'.
*  APPEND gt_sort.

*  CLEAR gt_sort.
*  gt_sort-spos      = '2'.
*  gt_sort-fieldname = 'VKBUR'.
*  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
FORM f_toolbar_excluding .
  DATA ls_exclude TYPE ui_func.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.                    " F_TOOLBAR_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DG_DYNDOC_ID  text
*----------------------------------------------------------------------*
FORM event_top_of_page USING   dg_dyndoc_id TYPE REF TO cl_dd_document.
  DATA : dl_text(255) TYPE c,
         dl_date1(10), dl_date2(10).

  DATA : dl_lines TYPE int4.

* Populating header to top-of-page
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text      = 'ALV OO Temp'
      sap_style = cl_dd_area=>heading.
  CALL METHOD dg_dyndoc_id->new_line.

*  CLEAR : dl_text.
*  SELECT SINGLE butxt INTO dl_text FROM t001 WHERE bukrs = p_bukrs.
*  CONCATENATE p_bukrs dl_text INTO dl_text SEPARATED BY ' - '.
*  CONCATENATE 'Company code :' dl_text
*         INTO dl_text SEPARATED BY space.
*  PERFORM add_text USING dl_text.
*  CALL METHOD dg_dyndoc_id->new_line.

*  CLEAR : dl_text,dl_date1,dl_date2.
*  WRITE s_budat-low TO dl_date1.
*  WRITE s_budat-high TO dl_date2.
*  CONCATENATE 'Posting Date :' dl_date1 'to' dl_date2
*         INTO dl_text SEPARATED BY space.
*  PERFORM add_text USING dl_text.
*  CALL METHOD dg_dyndoc_id->new_line.

  CLEAR : dl_text.
  WRITE sy-datum TO dl_text.
  CONCATENATE 'Print Date   :' dl_text INTO dl_text SEPARATED BY space.
  PERFORM add_text USING dl_text.
  CALL METHOD dg_dyndoc_id->new_line.

*  CLEAR : dl_text.
*  WRITE sy-uzeit TO dl_text.
*  CONCATENATE 'Print Time   :' dl_text INTO dl_text SEPARATED BY space.
*  PERFORM add_text USING dl_text.
*  CALL METHOD dg_dyndoc_id->new_line.

* Populating data to html control
  PERFORM html.

ENDFORM.                    " EVENT_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_ALV
*&---------------------------------------------------------------------*
FORM f_header_alv .
* Create TOP-Document
  CREATE OBJECT dg_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

* Create Splitter for custom_container
  CREATE OBJECT dg_splitter
    EXPORTING
      parent  = g_custom_container
      rows    = 2
      columns = 1.

* Split the custom_container to two containers and move the reference
* to receiving containers g_parent_html and g_parent_grid
  CALL METHOD dg_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = dg_parent_html.

  CALL METHOD dg_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = dg_parent_grid.

* Set height for g_parent_html
  CALL METHOD dg_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 20.

* Create_object_grid
  CREATE OBJECT g_grid
    EXPORTING
      i_parent = dg_parent_grid.

  CREATE OBJECT g_event_handler.
  SET HANDLER g_event_handler->top_of_page FOR g_grid.
ENDFORM.                    " F_HEADER_ALV

*&---------------------------------------------------------------------*
*&      Form  ADD_TEXT
*&---------------------------------------------------------------------*
*       To add Text
*----------------------------------------------------------------------*
FORM add_text USING p_text TYPE sdydo_text_element.
* Adding text
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text         = p_text
      sap_emphasis = cl_dd_area=>heading.
ENDFORM.                    " ADD_TEXT

*&---------------------------------------------------------------------*
*&      Form  HTML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM html.
  DATA : dl_length        TYPE i,                           " Length
         dl_background_id TYPE sdydo_key VALUE space. " Background_id
* Creating html control
  IF dg_html_cntrl IS INITIAL.
    CREATE OBJECT dg_html_cntrl
      EXPORTING
        parent = dg_parent_html.
  ENDIF.
* Reuse_alv_grid_commentary_set
  CALL FUNCTION 'REUSE_ALV_GRID_COMMENTARY_SET'
    EXPORTING
      document = dg_dyndoc_id
      bottom   = space
    IMPORTING
      length   = dl_length.
* Get TOP->HTML_TABLE ready
  CALL METHOD dg_dyndoc_id->merge_document.
* Set wallpaper
  CALL METHOD dg_dyndoc_id->set_document_background
    EXPORTING
      picture_id = dl_background_id.
* Connect TOP document to HTML-Control
  dg_dyndoc_id->html_control = dg_html_cntrl.
* Display TOP document
  CALL METHOD dg_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = dg_parent_html
    EXCEPTIONS
      html_display_error = 1.
  IF sy-subrc NE 0.
*    MESSAGE i999 WITH 'Error in displaying top-of-page'(036).
  ENDIF.

ENDFORM.                    " HTML

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai100 INPUT.
  DATA: lv_r_companycode  TYPE bapi1022_1-comp_code,
        lv_r_asset        TYPE bapi1022_1-assetmaino,
        lv_r_subnumber    TYPE bapi1022_1-assetsubno,
        lv_r_assetcreated TYPE bapi1022_reference,
        lt_return         TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE.
  DATA: lr_anln1 TYPE RANGE OF anln1 WITH HEADER LINE.

  FIELD-SYMBOLS : <fs>  TYPE any.

  CLEAR: gv_create,gv_test,gv_post.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      LEAVE TO SCREEN 0.

    WHEN '&CREATE' OR '&TEST'.
      IF sy-ucomm = '&CREATE'.
        CLEAR: gv_test.
        gv_create = 'X'.
      ELSEIF sy-ucomm = '&TEST'.
        CLEAR gv_create.
        gv_test = 'X'.
      ENDIF.

      LOOP AT <fs_data> ASSIGNING <fs_line>.     "gt_out ASSIGNING <fs_out>.
        CLEAR: gv_key,gv_gendata,gv_gendatax,gv_timedep,gv_timedepx,
               gv_inventory,gv_inventoryx,gv_origin,gv_originx,gv_invest,
               gv_investx,lv_r_companycode,lv_r_asset,lv_r_subnumber,
               lv_r_assetcreated,gt_depareas[],gt_depareasx[],lt_return[].

        CASE gs_003-typename.
          WHEN 'ZTIAMFIST0021'.
            PERFORM f_new_bapi_param USING 'ZTIAMFIST0021'.
            PERFORM f_new_bapi_paramx USING 'ZTIAMFIST0021'.
          WHEN 'ZTIAMFIST0022'.
            PERFORM f_new_bapi_param USING 'ZTIAMFIST0022'.
            PERFORM f_new_bapi_paramx USING 'ZTIAMFIST0022'.
          WHEN 'ZTIAMFIST0023'.
            PERFORM f_new_bapi_param USING 'ZTIAMFIST0023'.
            PERFORM f_new_bapi_paramx USING 'ZTIAMFIST0023'.
          WHEN OTHERS.
            PERFORM f_build_bapi_param.
            PERFORM f_build_bapi_paramx.
        ENDCASE.

        CALL FUNCTION 'BAPI_FIXEDASSET_CREATE1'
          EXPORTING
            key                  = gv_key
            testrun              = gv_test
            generaldata          = gv_gendata
            generaldatax         = gv_gendatax
            timedependentdata    = gv_timedep
            timedependentdatax   = gv_timedepx
            inventory            = gv_inventory
            inventoryx           = gv_inventoryx
            origin               = gv_origin
            originx              = gv_originx
            investacctassignmnt  = gv_invest
            investacctassignmntx = gv_investx
          IMPORTING
*           companycode          = lv_r_companycode
*           asset                = lv_r_asset
*           subnumber            = lv_r_subnumber
            assetcreated         = lv_r_assetcreated
            return               = lt_return
          TABLES
            depreciationareas    = gt_depareas[]
            depreciationareasx   = gt_depareasx[].

        IF lt_return-type = 'S'.
          IF gv_create = 'X'.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.

            ASSIGN COMPONENT 'ANLN1' OF STRUCTURE <fs_line> TO <fs>.
            <fs> = lv_r_assetcreated-asset.
            ASSIGN COMPONENT 'ANLN2' OF STRUCTURE <fs_line> TO <fs>.
            <fs> = lv_r_assetcreated-subnumber.
            ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fs_line> TO <fs>.
            <fs> = lt_return-message.

*            <fs_out>-anln1 = lv_r_assetcreated-asset.
*            <fs_out>-anln2 = lv_r_assetcreated-subnumber.
*            <fs_out>-message  = lt_return-message.
            gv_post = 'X'.
          ELSE.
            ASSIGN COMPONENT 'ICONID' OF STRUCTURE <fs_line> TO <fs>.
            <fs> = icon_led_green.
            ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fs_line> TO <fs>.
            <fs> = lt_return-message.

*            <fs_out>-iconid = icon_led_green.
*            <fs_out>-message  = lt_return-message.
          ENDIF.
        ELSE.
          ASSIGN COMPONENT 'ICONID' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = icon_led_red.
          ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lt_return-message.
          ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lt_return-type.
          ASSIGN COMPONENT 'MSGID' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lt_return-id.
          ASSIGN COMPONENT 'MSGNO' OF STRUCTURE <fs_line> TO <fs>.
          <fs> = lt_return-number.

*          <fs_out>-iconid   = icon_led_red.
*          <fs_out>-type     = lt_return-type.
*          <fs_out>-msgid    = lt_return-id.
*          <fs_out>-msgno    = lt_return-number.
*          <fs_out>-message  = lt_return-message.
        ENDIF.
      ENDLOOP.

      CASE 'X'.
        WHEN gv_test.
          READ TABLE gt_out WITH KEY iconid   = icon_led_red
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CLEAR: gv_test,gv_create,gv_post.
          ENDIF.
        WHEN gv_create.
      ENDCASE.

      IF gv_post = 'X'.
        LOOP AT gt_out WHERE anln1 IS NOT INITIAL.
          lr_anln1-sign   = 'I'.
          lr_anln1-option = 'EQ'.
          lr_anln1-low    = gt_out-anln1.
          APPEND lr_anln1.
        ENDLOOP.

        SUBMIT ztiamfi_i001 WITH p_bukrs  EQ p_bukrs
                            WITH p_anlkl  EQ p_anlkl
                            WITH s_anln1  IN lr_anln1
                            WITH p_back   EQ 'X'
                            AND RETURN.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_save_to_table .

  IF sy-subrc = 0.
    MESSAGE 'Data berhasil disave...' TYPE 'S'.
  ELSE.
    MESSAGE 'Data gagal disave...' TYPE 'S'.
  ENDIF.
ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_MESSAGE
*&---------------------------------------------------------------------*
FORM f_popup_message  CHANGING fc_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = 'Confirmation'
      text_question = 'Data bulan & company code tsb sudah pernah disave... Lanjut proses?'
      text_button_1 = 'Yes'
      text_button_2 = 'No'
    IMPORTING
      answer        = fc_answer.
ENDFORM.                    " F_POPUP_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD2
*&---------------------------------------------------------------------*
FORM f_bdc_field2 TABLES ft_bdcdata STRUCTURE bdcdata
                  USING  fu_field fu_value.
  CLEAR ft_bdcdata.
  ft_bdcdata-fnam = fu_field.
  ft_bdcdata-fval = fu_value.
  APPEND ft_bdcdata.
ENDFORM.                    "f_bdc_field2

******&---------------------------------------------------------------------*
******&      Form  F_BUILD_BAPI_PARAM
******&---------------------------------------------------------------------*
*****FORM f_build_bapi_param .
*****  gv_key-companycode          = <fs_out>-bukrs.
*****
*****  gv_gendata-assetclass       = <fs_out>-anlkl.
*****  gv_gendata-descript         = <fs_out>-txt50.
*****  gv_gendata-descript2        = <fs_out>-txt50.
*****  gv_gendata-main_descript    = <fs_out>-txt50.
*****
*****  gv_timedep-bus_area         = <fs_out>-gsber.
*****
*****  IF gs_003 IS INITIAL.
*****    gv_timedep-intern_ord       = <fs_out>-caufn.
*****  ELSE.
*****    gv_timedep-intern_ord       = <fs_out>-typbz.
*****    gv_timedep-costcenter       = <fs_out>-kostl.
*****    gv_timedep-room             = <fs_out>-raumn.
*****    gv_timedep-plate_no         = <fs_out>-kfzkz.
*****  ENDIF.
*****
*****  CLEAR gt_depareas.
*****  gt_depareas-area            = '01'.
*****  gt_depareas-odep_start_date = <fs_out>-afabg.
*****  APPEND gt_depareas.
*****ENDFORM.                    " F_BUILD_BAPI_PARAM

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_BAPI_PARAM
*&---------------------------------------------------------------------*
FORM f_build_bapi_param .
  FIELD-SYMBOLS : <fs> TYPE any.

  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs>.
  gv_key-companycode          = <fs>.
  ASSIGN COMPONENT 'ANLKL' OF STRUCTURE <fs_line> TO <fs>.
  gv_gendata-assetclass       = <fs>.
  ASSIGN COMPONENT 'TXT50' OF STRUCTURE <fs_line> TO <fs>.
  gv_gendata-descript         = <fs>.
  gv_gendata-descript2        = gv_gendata-descript.
  gv_gendata-main_descript    = gv_gendata-descript.
  ASSIGN COMPONENT 'GSBER' OF STRUCTURE <fs_line> TO <fs>.
  gv_timedep-bus_area         = <fs>.

  IF gs_003 IS INITIAL.
    ASSIGN COMPONENT 'CAUFN' OF STRUCTURE <fs_line> TO <fs>.
    gv_timedep-intern_ord       = <fs>.
  ELSE.
    ASSIGN COMPONENT 'KOSTL' OF STRUCTURE <fs_line> TO <fs>.
    gv_timedep-costcenter       = <fs>.
    ASSIGN COMPONENT 'RAUMN' OF STRUCTURE <fs_line> TO <fs>.
    gv_timedep-room             = <fs>.
    ASSIGN COMPONENT 'KFZKZ' OF STRUCTURE <fs_line> TO <fs>.
    gv_timedep-plate_no         = <fs>.
    ASSIGN COMPONENT 'TYPBZ' OF STRUCTURE <fs_line> TO <fs>.
    gv_origin-type_name         = <fs>.
    ASSIGN COMPONENT 'INVZU' OF STRUCTURE <fs_line> TO <fs>.
    gv_inventory-note           = <fs>.
  ENDIF.

  CLEAR gt_depareas.
  gt_depareas-area            = '01'.
  ASSIGN COMPONENT 'AFABG' OF STRUCTURE <fs_line> TO <fs>.
  gt_depareas-odep_start_date = <fs>.
  APPEND gt_depareas.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_BAPI_PARAMX
*&---------------------------------------------------------------------*
FORM f_build_bapi_paramx .
  gv_gendatax-assetclass       = 'X'.
  gv_gendatax-descript         = 'X'.
  gv_gendatax-descript2        = 'X'.
  gv_gendatax-main_descript    = 'X'.

  gv_timedepx-bus_area         = 'X'.

  IF gs_003 IS INITIAL.
    gv_timedepx-intern_ord       = 'X'.
  ELSE.
    gv_timedepx-costcenter       = 'X'.
    gv_timedepx-room             = 'X'.
    gv_timedepx-license_plate_no = 'X'.
    gv_inventoryx-note           = 'X'.
    gv_originx-type_name         = 'X'.
  ENDIF.

  CLEAR gt_depareasx.
  gt_depareasx-area            = '01'.
  gt_depareasx-odep_start_date = 'X'.
  APPEND gt_depareasx.
ENDFORM.                    " F_BUILD_BAPI_PARAMX

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'NDS'.
        screen-active = '0'.
        MODIFY SCREEN.
      WHEN 'FLN'.
        IF butt1 = 'X' OR butt3 = 'X'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  CASE 'X'.
    WHEN butt3 OR butt4.
      PERFORM f_modify_screen USING : 'PAN' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBL' '0' '' '' '',
                                      'PPA' '0' '' '' '',
                                      'PSG' '0' '' '' '',
                                      'SAS' '0' '' '' '',
                                      'PNB' '0' '' '' ''.
    WHEN butt5.
      PERFORM f_modify_screen USING : 'PAN' '0' '' '' '',
                                      'FLN' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBL' '0' '' '' '',
                                      'PPA' '0' '' '' '',
                                      'PSG' '0' '' '' '',
                                      'SAS' '0' '' '' '',
                                      'PNB' '0' '' '' ''.
    WHEN butt6.
      PERFORM f_modify_screen USING : 'PAN' '0' '' '' ''.
      IF pa_parti IS INITIAL.
        PERFORM f_modify_screen USING : 'FLN' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'SAS' '0' '' '' ''.
      ENDIF.

    WHEN OTHERS.
      PERFORM f_modify_screen USING : 'PBD' '0' '' '' '',
                                      'PBL' '0' '' '' '',
                                      'PPA' '0' '' '' '',
                                      'PSG' '0' '' '' '',
                                      'SAS' '0' '' '' '',
                                      'PNB' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN butt1.
      IF p_anlkl IS INITIAL.
        PERFORM f_error_selection_screen USING 'PAN' '0'.
      ENDIF.
    WHEN butt2.
      IF p_anlkl IS INITIAL.
        PERFORM f_error_selection_screen USING 'PAN' '0'.
      ENDIF.
      IF p_filenm IS INITIAL.
        PERFORM f_error_selection_screen USING 'FLN' '0'.
      ENDIF.
    WHEN butt4.
      IF p_filenm IS INITIAL.
        PERFORM f_error_selection_screen USING 'FLN' '0'.
      ENDIF.
    WHEN butt6.
      IF pa_parti IS INITIAL.
        IF so_asse1[] IS INITIAL.
          PERFORM f_error_selection_screen USING 'SAS' ''.
        ENDIF.
        IF so_asse2[] IS INITIAL.
          PERFORM f_error_selection_screen USING 'SAS' ''.
        ENDIF.
      ELSE.
        IF p_filenm IS INITIAL.
          PERFORM f_error_selection_screen USING 'FLN' ''.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
FORM f_download_template .
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.
  SET PROPERTY OF h_excel 'Visible' = 1.
  CALL METHOD OF h_excel 'Workbooks' = h_mapl.
  CALL METHOD OF h_mapl 'Add' = h_map.

  CASE 'X'.
    WHEN butt1.
      IF gs_003 IS INITIAL.
        PERFORM fill_cell USING 1 1 1 'Description'.
        PERFORM fill_cell USING 1 2 1 'Business Area'.
        PERFORM fill_cell USING 1 3 1 'Internal Order'.
        PERFORM fill_cell USING 1 4 1 'Depre.Start'.
      ELSE.
        CASE gs_003-typename.
          WHEN 'ZTIAMFIST0021'.
            PERFORM fill_cell USING 1 1 1 'Description'.
            PERFORM fill_cell USING 1 2 1 'Inventory Note'.
            PERFORM fill_cell USING 1 3 1 'Business Area'.
            PERFORM fill_cell USING 1 4 1 'Cost Center'.
            PERFORM fill_cell USING 1 5 1 'No.CEB Plan'.
            PERFORM fill_cell USING 1 6 1 'Depre.Start'.
          WHEN 'ZTIAMFIST0022'.
            PERFORM fill_cell USING 1 1 1 'Description'.
            PERFORM fill_cell USING 1 2 1 'Profit Center'.
            PERFORM fill_cell USING 1 3 1 'Business Area'.
            PERFORM fill_cell USING 1 4 1 'Cost Center'.
            PERFORM fill_cell USING 1 5 1 'Support Expense Category'.
            PERFORM fill_cell USING 1 6 1 'Internal Order'.
            PERFORM fill_cell USING 1 7 1 'No.CEB Plan'.
            PERFORM fill_cell USING 1 8 1 'Depre.Start'.
          WHEN 'ZTIAMFIST0023'.
            PERFORM fill_cell USING 1 1 1 'Description'.
            PERFORM fill_cell USING 1 2 1 'Business Area'.
            PERFORM fill_cell USING 1 3 1 'Internal Order'.
            PERFORM fill_cell USING 1 4 1 'Depre.Start'.
            PERFORM fill_cell USING 1 5 1 'Cost Center'.
            PERFORM fill_cell USING 1 6 1 'Profit Center'.
            PERFORM fill_cell USING 1 7 1 'Support Expense Category'.
            PERFORM fill_cell USING 1 8 1 'Key Account'.
            PERFORM fill_cell USING 1 9 1 'Kode.Vendor'.
          WHEN OTHERS.
            PERFORM fill_cell USING 1 1 1 'Description'.
            PERFORM fill_cell USING 1 2 1 'Business Area'.
            PERFORM fill_cell USING 1 3 1 'Internal Order'.
            PERFORM fill_cell USING 1 4 1 'Depre.Start'.
            PERFORM fill_cell USING 1 5 1 'Cost Center'.
            PERFORM fill_cell USING 1 6 1 'Profit Center'.
            PERFORM fill_cell USING 1 7 1 'Support Expense Category'.
            PERFORM fill_cell USING 1 8 1 'Key Account'.
        ENDCASE.
      ENDIF.
    WHEN butt3.
      PERFORM fill_cell USING 2 1 1 'Doc.Date                :'.
      PERFORM fill_cell USING 2 3 1 'Type                      :'.
      PERFORM fill_cell USING 3 1 1 'Post.Date               :'.
      PERFORM fill_cell USING 3 3 1 'Company Code:'.
      PERFORM fill_cell USING 4 1 1 'Refference            :'.
      PERFORM fill_cell USING 4 3 1 'Currency/Rate  :'.
      PERFORM fill_cell USING 5 1 1 'Doc.Header Text :'.

      PERFORM fill_cell USING 8 1 1 'Posting Key'.
      PERFORM fill_cell USING 8 2 1 'Account'.
      PERFORM fill_cell USING 8 3 1 'SGL Ind'.
      PERFORM fill_cell USING 8 4 1 'TType'.
      PERFORM fill_cell USING 8 5 1 'Amount'.
      PERFORM fill_cell USING 8 6 1 'Tax.Code'.
      PERFORM fill_cell USING 8 7 1 'B.Area'.
      PERFORM fill_cell USING 8 8 1 'TRD.PART.'.
      PERFORM fill_cell USING 8 9 1 'Cost.Centre'.
      PERFORM fill_cell USING 8 10 1 'Order'.
      PERFORM fill_cell USING 8 11 1 'Profit center'.
      PERFORM fill_cell USING 8 12 1 'Plant'.
      PERFORM fill_cell USING 8 13 1 'Text'.
      PERFORM fill_cell USING 8 14 1 'SalesOrg'.
      PERFORM fill_cell USING 8 15 1 'DisChan'.
      PERFORM fill_cell USING 8 16 1 'Soff'.
      PERFORM fill_cell USING 8 17 1 'Sales Force'.
      PERFORM fill_cell USING 8 18 1 'Sales Area'.
      PERFORM fill_cell USING 8 19 1 'W&D category'.
      PERFORM fill_cell USING 8 20 1 'Assignment '.
* Tambahan untuk COPA
      PERFORM fill_cell USING 8 21 1 'SalesGrp'.
      PERFORM fill_cell USING 8 22 1 'Customer'.
      PERFORM fill_cell USING 8 23 1 'Product'.
      PERFORM fill_cell USING 8 24 1 'Pro.brand'.
      PERFORM fill_cell USING 8 25 1 'prdGrpTSP'.
      PERFORM fill_cell USING 8 26 1 'Principal'.
      PERFORM fill_cell USING 8 27 1 'Division'.
      PERFORM fill_cell USING 8 28 1 'Cust.Grp'.
      PERFORM fill_cell USING 8 29 1 'materialGrp'.
      PERFORM fill_cell USING 8 30 1 'Cust type'.
      PERFORM fill_cell USING 8 31 1 'Ext. Matl Grp'.
      PERFORM fill_cell USING 8 32 1 'prod. Range'.
      PERFORM fill_cell USING 8 33 1 'prdGrp PTT/EC'.
      PERFORM fill_cell USING 8 34 1 'SupportExpCategory'.
      PERFORM fill_cell USING 8 35 1 'key account'.
      PERFORM fill_cell USING 8 36 1 'Material'.
    WHEN butt5.
      PERFORM fill_cell USING : 1 1 1 'Asset Number 1',
                                1 2 1 'Sub Number Asset 1',
                                1 3 1 'Asset Number 2',
                                1 4 1 'Sub Number Asset 2',
                                1 5 1 'Amount Partial Transfer'.
  ENDCASE.

  FREE OBJECT h_excel.
ENDFORM.                    " F_DOWNLOAD_TEMPLATE

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
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr  TYPE REF TO cl_abap_structdescr,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         lt_dfies     TYPE ddfields,
         ls_dfies     TYPE dfies,
         ls_fieldcat  TYPE lvc_s_fcat,
         ls_exclfield LIKE LINE OF gt_exclfield.

  DATA : lv_add.

  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN butt2.
      IF gs_003 IS INITIAL.
        CREATE DATA lt_dyn_table LIKE LINE OF gt_002.
      ELSE.
        CASE gs_003-typename.
          WHEN 'ZTIAMFIST0021'.
            PERFORM f_dyn_data USING gs_003-typename.
            lv_add = 'X'.
          WHEN 'ZTIAMFIST0022'.
            PERFORM f_dyn_data USING gs_003-typename.
            lv_add = 'X'.
          WHEN 'ZTIAMFIST0023'.
            PERFORM f_dyn_data USING gs_003-typename.
            lv_add = 'X'.
          WHEN OTHERS.
            CREATE DATA lt_dyn_table LIKE LINE OF gt_002n.
        ENDCASE.
      ENDIF.
    WHEN butt4.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_detail.
    WHEN butt6.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_asset.
  ENDCASE.

  IF lv_add IS INITIAL.
    lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
    lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

    PERFORM f_excluding_field.

    LOOP AT lt_dfies INTO ls_dfies.
      CLEAR ls_fieldcat.
      MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
      CLEAR ls_exclfield.
      READ TABLE gt_exclfield INTO ls_exclfield
                              WITH KEY fieldname = ls_fieldcat-fieldname.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CASE ls_dfies-fieldname.
        WHEN 'MARK'.
          PERFORM f_change_dyn_fieldcat USING :
          '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' ''
          CHANGING ls_fieldcat.
        WHEN 'ICON'.
          PERFORM f_change_dyn_fieldcat USING :
          '' '' '' '' '' 'Sts' '' '' '' '' '' '' '' 'X' '' ''
          CHANGING ls_fieldcat.
        WHEN 'MENGE'.
          PERFORM f_change_dyn_fieldcat USING :
          '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
          CHANGING ls_fieldcat.
        WHEN 'DMBTR'.
          PERFORM f_change_dyn_fieldcat USING :
          '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
          CHANGING ls_fieldcat.
        WHEN 'ANBTR'.
          PERFORM f_change_dyn_fieldcat USING :
          'IDR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          CHANGING ls_fieldcat.
        WHEN 'NBVAL'.
          PERFORM f_change_dyn_fieldcat USING :
          'IDR' '' '' '' '' 'Book Val.' '' '' '' '' '' '' '' '' '' ''
          CHANGING ls_fieldcat.
      ENDCASE.
      APPEND ls_fieldcat TO gt_fieldcat.
      CLEAR ls_fieldcat.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_upload_data .
  CLEAR : gt_excel, gt_excel[].
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
ENDFORM.                    " F_UPLOAD_DATA

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
*&      Form  F_EXCLUDING_FIELD
*&---------------------------------------------------------------------*
FORM f_excluding_field .
  CLEAR gt_exclfield[].

  PERFORM f_exclfields USING : 'KURSF', 'NEWUM', 'MWSKZ', 'VBUND',
                               'KOSTL', 'AUFNR', 'PRCTR', 'WERKS',
                               'VTWEG', 'VKBUR', 'WWSFR', 'WWPFN',
                               'WWPOS', 'VKGRP', 'KNDNR', 'ARTNR',
                               'WWPBR', 'WWPGR', 'WWPRC', 'SPART',
                               'KDGRP', 'MATKL', 'WWCTP', 'EXTWG',
                               'WWPRR', 'WWPRD', 'WWSEC', 'WWTRZ',
                               'MATNR', 'KOART'.

ENDFORM.                    " F_EXCLUDING_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_EXCLFIELDS
*&---------------------------------------------------------------------*
FORM f_exclfields  USING    fu_field.
  DATA : ls_exclfield     LIKE LINE OF gt_exclfield.

  ls_exclfield-fieldname  = fu_field.
  APPEND ls_exclfield TO gt_exclfield.
ENDFORM.                    " F_EXCLFIELDS

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
*&      Form  F_MOVE_EXCEL_TO_JURNAL_ASSET
*&---------------------------------------------------------------------*
FORM f_move_excel_to_jurnal_asset .
  DATA : ls_excel  LIKE LINE OF gt_excel,
         ls_tbsl   LIKE LINE OF gt_tbsl,
         ls_header LIKE LINE OF gt_header,
         ls_detail LIKE LINE OF gt_detail.

  DATA : lv_buzei TYPE bseg-buzei,
         lv_waers TYPE bkpf-waers,
         lv_kursf TYPE bkpf-kursf,
         lv_koart TYPE bseg-koart,
         lv_shkzg TYPE bseg-shkzg.

  LOOP AT gt_excel INTO ls_excel.
    CASE ls_excel-row.
      WHEN '0001'.
        IF ls_excel-col EQ '0002'.
          PERFORM f_conversion_date USING ls_excel-value 'I'
                                    CHANGING ls_header-bldat.
          pa_bldat  = ls_header-bldat.
        ELSEIF ls_excel-col EQ '0004'.
          ls_header-blart   = ls_excel-value.
        ENDIF.
      WHEN '0002'.
        IF ls_excel-col EQ '0002'.
          PERFORM f_conversion_date USING ls_excel-value 'I'
                                    CHANGING ls_header-budat.
          pa_budat  = ls_header-budat.
        ELSEIF ls_excel-col EQ '0004'.
          ls_header-bukrs  = ls_excel-value.
          IF ls_header-bukrs NE p_bukrs.
            gv_subrc  = 1.
            EXIT.
          ENDIF.
        ENDIF.
      WHEN '0003'.
        IF ls_excel-col EQ '0002'.
          ls_header-xblnr = ls_excel-value.
          gv_xblnr        = ls_header-xblnr.
        ELSEIF ls_excel-col EQ '0004'.
          ls_header-waers = ls_excel-value.
          lv_waers        = ls_header-waers.
        ELSEIF ls_excel-col EQ '0005'.
          PERFORM f_amount_modify USING ls_excel-value '' '' 'I'
                                  CHANGING lv_kursf.
        ENDIF.
      WHEN '0004'.
        IF ls_excel-col EQ '0002'.
          ls_header-bktxt = ls_excel-value.
          APPEND ls_header TO gt_header.
        ENDIF.
      WHEN '0001' OR '0006' OR '0007'.
        CONTINUE.
      WHEN OTHERS.
        CASE ls_excel-col.
          WHEN '0001'.
            CLEAR lv_koart.
            ls_detail-newbs  = ls_excel-value.
            CLEAR ls_tbsl.
            READ TABLE gt_tbsl INTO ls_tbsl
                               WITH KEY bschl = ls_detail-newbs.
            IF sy-subrc EQ 0.
              lv_koart  = ls_tbsl-koart.
              lv_shkzg  = ls_tbsl-shkzg.
            ENDIF.
          WHEN '0002'.
            PERFORM f_modify_data USING 'ALPHA' ls_excel-value 'INPUT'
                                  CHANGING ls_detail-newko.
          WHEN '0003'.
            ls_detail-newum  = ls_excel-value.
          WHEN '0004'.
            ls_detail-newbw  = ls_excel-value.
          WHEN '0005'.
            PERFORM f_amount_modify USING ls_excel-value lv_waers lv_shkzg 'I'
                                    CHANGING ls_detail-dmbtr.
          WHEN '0006'.
            ls_detail-mwskz  = ls_excel-value.
          WHEN '0007'.
            ls_detail-gsber  = ls_excel-value.
          WHEN '0008'.
            ls_detail-vbund  = ls_excel-value.
          WHEN '0009'.
            PERFORM f_modify_data USING 'ALPHA' ls_excel-value 'INPUT'
                                  CHANGING ls_detail-kostl.
          WHEN '0010'.
            PERFORM f_modify_data USING 'ALPHA' ls_excel-value 'INPUT'
                                  CHANGING ls_detail-aufnr.
          WHEN '0011'.
            ls_detail-prctr  = ls_excel-value.
          WHEN '0012'.
            ls_detail-werks  = ls_excel-value.
          WHEN '0013'.
            ls_detail-sgtxt  = ls_excel-value.
          WHEN '0014'.
            ls_detail-vkorg  = ls_excel-value.
          WHEN '0015'.
            ls_detail-vtweg  = ls_excel-value.
          WHEN '0016'.
            ls_detail-vkbur  = ls_excel-value.
          WHEN '0017'.
            ls_detail-wwsfr  = ls_excel-value.
          WHEN '0018'.
            ls_detail-wwpfn  = ls_excel-value.
          WHEN '0019'.
            ls_detail-wwpos  = ls_excel-value.
          WHEN '0020'.
            ls_detail-zuonr  = ls_excel-value.
          WHEN '0021'.
            ls_detail-vkgrp  = ls_excel-value.
          WHEN '0022'.
            ls_detail-kndnr  = ls_excel-value.
          WHEN '0023'.
            ls_detail-artnr  = ls_excel-value.
          WHEN '0024'.
            ls_detail-wwpbr  = ls_excel-value.
          WHEN '0025'.
            ls_detail-wwpgr  = ls_excel-value.
          WHEN '0026'.
            ls_detail-wwprc  = ls_excel-value.
          WHEN '0027'.
            ls_detail-spart  = ls_excel-value.
          WHEN '0028'.
            ls_detail-kdgrp  = ls_excel-value.
          WHEN '0029'.
            ls_detail-matkl  = ls_excel-value.
          WHEN '0030'.
            ls_detail-wwctp  = ls_excel-value.
          WHEN '0031'.
            ls_detail-extwg  = ls_excel-value.
          WHEN '0032'.
            ls_detail-wwprr  = ls_excel-value.
          WHEN '0033'.
            ls_detail-wwprd  = ls_excel-value.
          WHEN '0034'.
            ls_detail-wwsec  = ls_excel-value.
          WHEN '0035'.
            ls_detail-wwtrz  = ls_excel-value.
          WHEN '0036'.
            ls_detail-matnr  = ls_excel-value.
        ENDCASE.
        AT END OF row.
          ADD 1 TO lv_buzei.
          ls_detail-buzei = lv_buzei.
          IF lv_waers IS INITIAL.
            lv_waers  = 'IDR'.
          ENDIF.
          ls_detail-koart = lv_koart.
          ls_detail-waers = lv_waers.
          ls_detail-kursf = lv_kursf.
          CASE gv_subrc.
            WHEN 1.
              ls_detail-icon    = icon_led_red.
              ls_detail-msgv    = 'Company code error'.
          ENDCASE.
          APPEND ls_detail TO gt_detail.
          CLEAR ls_detail.
        ENDAT.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MOVE_EXCEL_TO_JURNAL_ASSET

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNT_MODIFY
*&---------------------------------------------------------------------*
FORM f_amount_modify  USING    fu_value fu_waers fu_shkzg fu_process
                      CHANGING fc_value.
  DATA : lv_value(20),
         lv_dmbtr   TYPE bseg-dmbtr.

  lv_value = fu_value.
  IF fu_waers IS INITIAL.
    TRANSLATE lv_value USING ',.'.
  ELSE.
    CASE fu_process.
      WHEN 'I'.
        lv_value = fu_value / 100.
        IF fu_shkzg = 'H'.
          lv_value = lv_value * -1.
        ENDIF.
      WHEN 'O'.
        TRANSLATE lv_value USING '. '.
        TRANSLATE lv_value USING ',.'.
        CONDENSE lv_value NO-GAPS.
        lv_value = abs( lv_value ).
    ENDCASE.
  ENDIF.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value.
ENDFORM.                    " F_AMOUNT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_DATE
*&---------------------------------------------------------------------*
FORM f_conversion_date  USING    fu_datum fu_flag
                        CHANGING fc_datum.
  IF fu_flag = 'I'.
    CONCATENATE fu_datum+6(4) fu_datum+3(2) fu_datum(2)
    INTO fc_datum.
  ELSEIF fu_flag = 'O'.
    WRITE fu_datum TO fc_datum DD/MM/YYYY.
  ENDIF.
ENDFORM.                    " F_CONVERSION_DATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data  USING    fu_convexit fu_value fu_function
                    CHANGING fc_value.
  DATA : lv_function    TYPE string.

  IF fu_convexit IS NOT INITIAL.
    CONCATENATE 'CONVERSION_EXIT_' fu_convexit '_' fu_function
    INTO lv_function.
    CALL FUNCTION lv_function
      EXPORTING
        input  = fu_value
      IMPORTING
        output = fc_value.
  ENDIF.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_JURNAL_ASSET
*&---------------------------------------------------------------------*
FORM f_validate_jurnal_asset .
  DATA : lt_knb1   TYPE STANDARD TABLE OF knb1,
         lt_lfb1   TYPE STANDARD TABLE OF lfb1,
         lt_anla   TYPE STANDARD TABLE OF anla,
         lt_skb1   TYPE STANDARD TABLE OF skb1,
         ls_knb1   LIKE LINE OF lt_knb1,
         ls_lfb1   LIKE LINE OF lt_lfb1,
         ls_anla   LIKE LINE OF lt_anla,
         ls_skb1   LIKE LINE OF lt_skb1,
         ls_detail LIKE LINE OF gt_detail.

  DATA : lv_anln1 TYPE anla-anln1,
         lv_anln2 TYPE anla-anln2,
         lv_lifnr TYPE lfb1-lifnr,
         lv_kunnr TYPE knb1-kunnr,
         lv_saknr TYPE skb1-saknr,
         lv_tabix TYPE sy-tabix.

  DATA : lr_koart TYPE RANGE OF koart,
         ls_koart LIKE LINE OF lr_koart.

  CLEAR : lt_knb1[], lt_lfb1[], lt_anla[], lt_skb1[].
  PERFORM f_get_master_data TABLES lt_knb1
                                   lt_lfb1
                                   lt_anla
                                   lt_skb1.

  LOOP AT gt_detail INTO ls_detail.
    lv_tabix  = sy-tabix.
    IF lv_tabix = 1.
      IF ls_detail-koart <> 'S'.
        PERFORM f_error_before_posting USING 'Use a posting key for G/L accounts'
                                             '' lv_tabix '' '' '' '' '' ''.
      ENDIF.
    ENDIF.

    IF gv_subrc = 0.
      CASE ls_detail-koart.
        WHEN 'A'.
          CLEAR : lv_anln1, lv_anln2, ls_anla.
          SPLIT ls_detail-newko AT '-' INTO lv_anln1 lv_anln2.
          READ TABLE lt_anla INTO ls_anla
                             WITH KEY anln1 = lv_anln1
                                      anln2 = lv_anln2.
          IF sy-subrc <> 0.
            PERFORM f_error_before_posting USING '' '1' lv_tabix
                                                 lv_anln1 lv_anln2 '' '' '' ''.
          ENDIF.
        WHEN 'K'.
          CLEAR : ls_lfb1, lv_lifnr.
          PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                                CHANGING lv_lifnr.
          READ TABLE lt_lfb1 INTO ls_lfb1
                             WITH KEY lifnr = lv_lifnr.
          IF sy-subrc <> 0.
            PERFORM f_error_before_posting USING '' '2' lv_tabix
                                                 '' '' '' lv_lifnr '' ''.
          ENDIF.
        WHEN 'D'.
          CLEAR : ls_knb1, lv_kunnr.
          PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                                CHANGING lv_kunnr.
          READ TABLE lt_knb1 INTO ls_knb1
                             WITH KEY kunnr = lv_kunnr.
          IF sy-subrc <> 0.
            PERFORM f_error_before_posting USING '' '3' lv_tabix
                                                 '' '' lv_kunnr '' '' ''.
          ENDIF.
        WHEN 'S'.
          CLEAR : ls_skb1, lv_saknr.
          PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                                CHANGING lv_saknr.
          READ TABLE lt_skb1 INTO ls_skb1
                             WITH KEY saknr = lv_saknr.
          IF sy-subrc <> 0.
            PERFORM f_error_before_posting USING '' '4' lv_tabix
                                                 '' '' '' '' lv_saknr ''.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_JURNAL_ASSET

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_BEFORE_POSTING
*&---------------------------------------------------------------------*
FORM f_error_before_posting  USING    fu_msgv fu_subrc fu_row fu_anln1 fu_anln2
                                  fu_kunnr fu_lifnr fu_saknr fu_newum.
  DATA : ls_detail  LIKE LINE OF gt_detail,
         return     TYPE bapiret2,
         ls_message TYPE bdcmsgcoll.

  gv_subrc = fu_subrc.

  IF fu_row IS INITIAL.
    LOOP AT gt_detail INTO ls_detail.
      ls_detail-icon    = icon_led_red.
      ls_detail-msgv    = fu_msgv.
      MODIFY gt_detail FROM ls_detail TRANSPORTING icon msgv.
    ENDLOOP.
  ELSE.
    ls_detail-icon    = icon_led_red.
    CASE fu_subrc.
      WHEN 1.
        return-id           = 'AA'.
        return-number       = '001'.
        return-message_v1   = fu_anln1.
        return-message_v2   = fu_anln2.
        return-message_v3   = p_bukrs.
      WHEN 2.
        return-id           = 'F5'.
        return-number       = '104'.
        return-message_v1   = fu_lifnr.
        return-message_v2   = p_bukrs.
      WHEN 3.
        return-id           = 'F5'.
        return-number       = '102'.
        return-message_v1   = fu_kunnr.
        return-message_v2   = p_bukrs.
      WHEN 4.
        return-id           = 'F5'.
        return-number       = '106'.
        return-message_v1   = fu_saknr.
        return-message_v2   = p_bukrs.
      WHEN 5.
        return-id           = 'F5'.
        return-number       = '838'.
        return-message_v1   = fu_newum.
    ENDCASE.

    IF fu_msgv IS INITIAL.
      ls_message-msgid      = return-id.
      ls_message-msgnr      = return-number.
      ls_message-msgv1      = return-message_v1.
      ls_message-msgv2      = return-message_v2.
      ls_message-msgv3      = return-message_v3.
      ls_message-msgv4      = return-message_v4.

      PERFORM f_show_message USING ls_message
                             CHANGING ls_detail-msgv.
    ELSE.
      ls_detail-msgv  = fu_msgv.
    ENDIF.

    MODIFY gt_detail FROM ls_detail
                     INDEX fu_row
                     TRANSPORTING icon msgv.
  ENDIF.
ENDFORM.                    " F_ERROR_BEFORE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_GET_MASTER_DATA
*&---------------------------------------------------------------------*
FORM f_get_master_data  TABLES   ft_knb1 STRUCTURE knb1
                                 ft_lfb1 STRUCTURE lfb1
                                 ft_anla STRUCTURE anla
                                 ft_skb1 STRUCTURE skb1.
  TYPES : BEGIN OF ty_acc,
            koart TYPE bseg-koart,
            anln1 TYPE anla-anln1,
            anln2 TYPE anla-anln2,
            lifnr TYPE lfb1-lifnr,
            saknr TYPE skb1-saknr,
            kunnr TYPE knb1-kunnr,
          END OF ty_acc.

  DATA : lt_xdetail TYPE STANDARD TABLE OF ty_detail,
         ls_detail  LIKE LINE OF gt_detail,
         ls_acc     TYPE ty_acc,
         lt_xknb1   TYPE STANDARD TABLE OF ty_acc,
         lt_xlfb1   TYPE STANDARD TABLE OF ty_acc,
         lt_xanla   TYPE STANDARD TABLE OF ty_acc,
         lt_xskb1   TYPE STANDARD TABLE OF ty_acc.

  LOOP AT gt_detail INTO ls_detail.
    ls_acc-koart  = ls_detail-koart.
    CASE ls_detail-koart.
      WHEN 'A'.
        SPLIT ls_detail-newko AT '-' INTO ls_acc-anln1 ls_acc-anln2.
        APPEND ls_acc TO lt_xanla.
      WHEN 'K'.
        PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                              CHANGING ls_acc-lifnr.
        APPEND ls_acc TO lt_xlfb1.
      WHEN 'D'.
        PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                              CHANGING ls_acc-kunnr.
        APPEND ls_acc TO lt_xknb1.
      WHEN 'S'.
        PERFORM f_modify_data USING 'ALPHA' ls_detail-newko 'INPUT'
                              CHANGING ls_acc-saknr.
        APPEND ls_acc TO lt_xskb1.
    ENDCASE.
    CLEAR ls_acc.
  ENDLOOP.

  SORT lt_xskb1 BY saknr.
  DELETE ADJACENT DUPLICATES FROM lt_xskb1 COMPARING saknr.
  SORT lt_xlfb1 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xlfb1 COMPARING lifnr.
  SORT lt_xanla BY anln1 anln2.
  DELETE ADJACENT DUPLICATES FROM lt_xanla COMPARING anln1 anln2.
  SORT lt_xknb1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_xknb1 COMPARING kunnr.

  IF lt_xlfb1[] IS NOT INITIAL.
    SELECT *
      FROM lfb1
      INTO CORRESPONDING FIELDS OF TABLE ft_lfb1
      FOR ALL ENTRIES IN lt_xlfb1
      WHERE lifnr = lt_xlfb1-lifnr
        AND bukrs = p_bukrs.
  ENDIF.

  IF lt_xknb1[] IS NOT INITIAL.
    SELECT *
      FROM knb1
      INTO CORRESPONDING FIELDS OF TABLE ft_knb1
      FOR ALL ENTRIES IN lt_xknb1
      WHERE kunnr = lt_xknb1-kunnr
        AND bukrs = p_bukrs.
  ENDIF.

  IF lt_xskb1[] IS NOT INITIAL.
    SELECT *
      FROM skb1
      INTO CORRESPONDING FIELDS OF TABLE ft_skb1
      FOR ALL ENTRIES IN lt_xskb1
      WHERE bukrs = p_bukrs
        AND saknr = lt_xskb1-saknr.
  ENDIF.

  IF lt_xanla[] IS NOT INITIAL.
    SELECT *
      FROM anla
      INTO CORRESPONDING FIELDS OF TABLE ft_anla
      FOR ALL ENTRIES IN lt_xanla
      WHERE bukrs = p_bukrs
        AND anln1 = lt_xanla-anln1
        AND anln2 = lt_xanla-anln2.
  ENDIF.
ENDFORM.                    " F_GET_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SHOW_MESSAGE
*&---------------------------------------------------------------------*
FORM f_show_message  USING    fs_bdcmsg   STRUCTURE bdcmsgcoll
                     CHANGING fc_msgv.
  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      id         = fs_bdcmsg-msgid
      no         = fs_bdcmsg-msgnr
      v1         = fs_bdcmsg-msgv1
      v2         = fs_bdcmsg-msgv2
      v3         = fs_bdcmsg-msgv3
      v4         = fs_bdcmsg-msgv4
    IMPORTING
      msg        = fc_msgv
    EXCEPTIONS
      nofs_found = 1
      OTHERS     = 2.
ENDFORM.                    " F_SHOW_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  APPEND '&SIM' TO fcode.

  IF gv_end IS NOT INITIAL OR
    gv_subrc IS NOT INITIAL.
    APPEND '&SIM' TO fcode.
    APPEND '&POS' TO fcode.
    APPEND '&NBV' TO fcode.
  ENDIF.

  CASE 'X'.
    WHEN butt6.
    WHEN OTHERS.
      APPEND '&NBV' TO fcode.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  SET TITLEBAR 'TITLE' WITH 'Jurnal Interest Asset'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_custom_container IS INITIAL.
    CREATE OBJECT g_custom_container
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
        parent  = g_custom_container
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
  IF g_grid IS INITIAL.
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sortfield.

    gs_variant-report = gv_repid.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_sort              = gt_sort[]
        it_outtab            = <fs_out1>[]
        it_fieldcatalog      = gt_fieldcat[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SUBTOTAL
*&---------------------------------------------------------------------*
FORM f_check_subtotal .
  DATA : lt_itab00 TYPE REF TO data,
         lt_itab01 TYPE REF TO data.

  DATA : lv_subrc     TYPE sy-subrc.

  FIELD-SYMBOLS : <fs_tab>  TYPE STANDARD TABLE,
                  <fs_line> TYPE ty_detail.

  CALL METHOD g_grid->get_subtotals
    IMPORTING
      ep_collect00 = lt_itab00
      ep_collect01 = lt_itab01.

  ASSIGN lt_itab00->* TO <fs_tab>.
  IF sy-subrc EQ 0 AND <fs_tab>[] IS NOT INITIAL.
    READ TABLE <fs_tab> ASSIGNING <fs_line> INDEX 1.
    IF <fs_line>-dmbtr <> 0.
      lv_subrc = 4.
    ENDIF.
  ENDIF.

  IF lv_subrc <> 0.
    PERFORM f_error_before_posting USING 'Balance in transaction currency'
                                         '3' '' '' '' '' '' '' ''.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_CHECK_SUBTOTAL

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
         lv_subrc TYPE sy-subrc,
         lv_valid TYPE c,
         lt_fidx  TYPE lvc_t_fidx,
         ls_fidx  TYPE sy-tabix.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&NBV'.
      CALL METHOD g_grid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_change_amount_posted.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_grid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_check_error CHANGING lv_subrc.
        IF lv_subrc = 0.
          CASE 'X'.
            WHEN butt6.
              IF pa_parti IS INITIAL.
                PERFORM f_posting_transfer_asset.
              ELSE.
*                PERFORM f_posting_partial_transfer_new.
                PERFORM f_posting_partial_transfer_bdc.
              ENDIF.
            WHEN OTHERS.
              PERFORM f_posting_jurnal_asset.
          ENDCASE.
        ELSE.
          MESSAGE s000(zab) WITH 'Data cannot executed' DISPLAY LIKE 'E'.
        ENDIF.
        gv_end = 'X'.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_grid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  CALL METHOD g_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_grid IS NOT INITIAL.
      CALL METHOD g_grid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ERROR
*&---------------------------------------------------------------------*
FORM f_check_error  CHANGING fc_subrc.
  DATA ls_detail    LIKE LINE OF gt_detail.

  READ TABLE gt_detail INTO ls_detail
                       WITH KEY icon = icon_led_red.
  IF sy-subrc = 0.
    fc_subrc = 4.
  ENDIF.
ENDFORM.                    " F_CHECK_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_JURNAL_ASSET
*&---------------------------------------------------------------------*
FORM f_posting_jurnal_asset .
  DATA : ls_asset     LIKE LINE OF gt_asset,
         ls_header    LIKE LINE OF gt_header,
         ls_detail    LIKE LINE OF gt_detail,
         lv_bldat(10),
         lv_budat(10),
         lv_wrbtr(20),
         lv_koart     TYPE bseg-koart,
         lv_icon(4),
         lv_msgv      TYPE bapiret2-message,
         lv_lines     TYPE i,
         lv_count     TYPE i,
         lv_kostl     TYPE bseg-kostl.

  d_bdc_batch = 'N'.

  LOOP AT gt_header INTO ls_header.
    PERFORM f_conversion_date USING ls_header-bldat 'O'
                              CHANGING lv_bldat.
    PERFORM f_conversion_date USING ls_header-budat 'O'
                              CHANGING lv_budat.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMF05A'       '0100',
      ' '   'BDC_OKCODE'     '/00',
      ' '   'BKPF-BLDAT'     lv_bldat,
      ' '   'BKPF-BLART'     ls_header-blart,
      ' '   'BKPF-BUKRS'     ls_header-bukrs,
      ' '   'BKPF-BUDAT'     lv_budat,
      ' '   'BKPF-MONAT'     lv_budat+3(2),
      ' '   'BKPF-WAERS'     ls_header-waers,
      ' '   'BKPF-XBLNR'     ls_header-xblnr,
      ' '   'BKPF-BKTXT'     ls_header-bktxt.

    lv_count = 1.
    CLEAR : lv_lines, ls_detail.
    DESCRIBE TABLE gt_detail LINES lv_lines.

    READ TABLE gt_detail INTO ls_detail INDEX lv_count.
    IF sy-subrc = 0.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
        ' '   'RF05A-NEWBS'    ls_detail-newbs,
        ' '   'RF05A-NEWKO'    ls_detail-newko,
        ' '   'RF05A-NEWBW'    ls_detail-newbw.

      PERFORM f_amount_modify USING ls_detail-dmbtr ls_detail-waers '' 'O'
                              CHANGING lv_wrbtr.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X'   'SAPMF05A'       '0300',
        ' '   'BDC_OKCODE'     '/00',
        ' '   'BSEG-WRBTR'     lv_wrbtr,
        ' '   'BSEG-ZUONR'     ls_detail-zuonr,
        ' '   'BSEG-SGTXT'     ls_detail-sgtxt.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X'   'SAPLKACB'       '0002',
        ' '   'BDC_OKCODE'     '=ENTE',
        ' '   'COBL-GSBER'     ls_detail-gsber.
    ENDIF.

    LOOP AT gt_detail INTO ls_detail FROM lv_count.
      ADD 1 TO lv_count.

      IF ls_detail-koart = 'A'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X'   'SAPMF05A'       '0305',
          ' '   'BDC_OKCODE'     '/00',
          ' '   'BSEG-WRBTR'     lv_wrbtr,
          ' '   'BSEG-ZUONR'     ls_detail-zuonr,
          ' '   'BSEG-SGTXT'     ls_detail-sgtxt.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X'   'SAPMF05A'       '0300',
          ' '   'BDC_OKCODE'     '/00',
          ' '   'BSEG-WRBTR'     lv_wrbtr,
          ' '   'BSEG-ZUONR'     ls_detail-zuonr,
          ' '   'BSEG-SGTXT'     ls_detail-sgtxt.
      ENDIF.

      lv_koart = ls_detail-koart.

      READ TABLE gt_detail INTO ls_detail INDEX lv_count.
      IF sy-subrc = 0.
        PERFORM f_amount_modify USING ls_detail-dmbtr ls_detail-waers '' 'O'
                                CHANGING lv_wrbtr.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' '   'RF05A-NEWBS'    ls_detail-newbs,
          ' '   'RF05A-NEWKO'    ls_detail-newko,
          ' '   'RF05A-NEWBW'    ls_detail-newbw.
      ENDIF.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X'   'SAPLKACB'       '0002',
        ' '   'BDC_OKCODE'     '=ENTE'.

      IF lv_koart <> 'A'.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          ' '   'COBL-GSBER'     ls_detail-gsber.
        IF lv_kostl IS NOT INITIAL.
          PERFORM f_bdc_data TABLES t_bdcdata USING:
            ' '   'COBL-KOSTL'     lv_kostl.
        ENDIF.
      ENDIF.

      lv_kostl  = ls_detail-kostl.

      IF lv_count = lv_lines.
        EXIT.
      ENDIF.
    ENDLOOP.

    PERFORM f_amount_modify USING ls_detail-dmbtr ls_detail-waers '' 'O'
                            CHANGING lv_wrbtr.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMF05A'       '0305',
      ' '   'BDC_OKCODE'     '=AB',
      ' '   'BSEG-WRBTR'     lv_wrbtr,
      ' '   'BSEG-ZUONR'     ls_detail-zuonr,
      ' '   'BSEG-SGTXT'     ls_detail-sgtxt.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPLKACB'       '0002',
      ' '   'BDC_OKCODE'     '=ENTE'.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMF05A'       '0700',
      ' '   'BDC_OKCODE'     '=BU'.

    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                            t_bdcmsg
                                     USING 'F-90' d_bdc_tctxt.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      lv_icon   = icon_led_red.
      PERFORM f_show_message USING t_bdcmsg
                             CHANGING lv_msgv.
    ELSE.
      READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'
                                   msgid  = '00'
                                   msgnr  = '344'.
      IF sy-subrc = 0.
        lv_icon   = icon_led_red.
        PERFORM f_show_message USING t_bdcmsg
                               CHANGING lv_msgv.
      ELSE.
        READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'
                                     msgid  = 'F5'
                                     msgnr  = '312'.
        IF sy-subrc = 0.
          PERFORM f_show_message USING t_bdcmsg
                                 CHANGING lv_msgv.
          lv_icon   = icon_led_green.
        ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT gt_detail INTO ls_detail.
      ls_detail-icon  = lv_icon.
      ls_detail-msgv  = lv_msgv.
      MODIFY gt_detail FROM ls_detail TRANSPORTING icon msgv.
    ENDLOOP.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_POSTING_JURNAL_ASSET

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
*&      Form  F_SPLIT_ASSET
*&---------------------------------------------------------------------*
FORM f_split_asset .
  DATA : ls_asset   LIKE LINE OF gt_asset.

  LOOP AT so_asse1.
    ls_asset-anln1 = so_asse1-low(12).
    ls_asset-anln2 = so_asse1-low+12(4).
    READ TABLE so_asse2 INDEX sy-tabix.
    IF sy-subrc = 0.
      ls_asset-anln3 = so_asse2-low(12).
      ls_asset-anln4 = so_asse2-low+12(4).
      APPEND ls_asset TO gt_asset.
      CLEAR ls_asset.
    ENDIF.
  ENDLOOP.

  ASSIGN gt_asset TO <fs_out1>.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_EXCEL_TO_PARTIAL
*&---------------------------------------------------------------------*
FORM f_move_excel_to_partial .
  DATA : ls_excel LIKE LINE OF gt_excel,
         ls_asset LIKE LINE OF gt_asset.

  DATA : lt_xanla    TYPE STANDARD TABLE OF anla.

  LOOP AT gt_excel INTO ls_excel.
    CASE ls_excel-col.
      WHEN '0001'.
        PERFORM f_modify_data USING 'ALPHA' ls_excel-value 'INPUT'
                              CHANGING ls_asset-anln1.
      WHEN '0002'.
        ls_asset-anln2   = ls_excel-value.
        PERFORM f_store_asset_data TABLES lt_xanla
                                   USING ls_asset-anln1 ls_asset-anln2.
      WHEN '0003'.
        PERFORM f_modify_data USING 'ALPHA' ls_excel-value 'INPUT'
                              CHANGING ls_asset-anln3.
      WHEN '0004'.
        ls_asset-anln4   = ls_excel-value.
        PERFORM f_store_asset_data TABLES lt_xanla
                                   USING ls_asset-anln3 ls_asset-anln4.
      WHEN '0005'.
        PERFORM f_amount_modify USING ls_excel-value '' '' ''
                                CHANGING ls_asset-anbtr.
        ls_asset-anbtr = ls_asset-anbtr / 100.
    ENDCASE.
    AT END OF row.
      APPEND ls_asset TO gt_asset.
      CLEAR ls_asset.
    ENDAT.
  ENDLOOP.

  IF lt_xanla[] IS NOT INITIAL.
    SELECT *
      FROM anla
      INTO CORRESPONDING FIELDS OF TABLE gt_anla
      FOR ALL ENTRIES IN lt_xanla
      WHERE bukrs = lt_xanla-bukrs
        AND anln1 = lt_xanla-anln1
        AND anln2 = lt_xanla-anln2.

    CLEAR : lt_xanla[].
    lt_xanla[] = gt_anla[].
    SORT lt_xanla BY ktogr.
    DELETE ADJACENT DUPLICATES FROM lt_xanla COMPARING ktogr.
    IF lt_xanla[] IS NOT INITIAL.
      SELECT *
        FROM t095
        INTO CORRESPONDING FIELDS OF TABLE gt_t095
        FOR ALL ENTRIES IN lt_xanla
        WHERE ktopl = 'TSPC'
          AND ktogr = lt_xanla-ktogr
          AND afabe = '01'.
    ENDIF.
  ENDIF.

  ASSIGN gt_asset TO <fs_out1>.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_STORE_ASSET_DATA
*&---------------------------------------------------------------------*
FORM f_store_asset_data  TABLES   ft_xanla STRUCTURE anla
                         USING    fu_anln1 fu_anln2.
  DATA : ls_xanla   TYPE anla.

  ls_xanla-bukrs = p_bukrs.
  ls_xanla-anln1 = fu_anln1.
  ls_xanla-anln2 = fu_anln2.
  APPEND ls_xanla TO ft_xanla.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_TRANSFER_ASSET
*&---------------------------------------------------------------------*
FORM f_posting_transfer_asset .
  DATA : ls_asset     LIKE LINE OF gt_asset,
         lv_bldat(10),
         lv_budat(10).

  d_bdc_batch = 'N'.

  LOOP AT gt_asset INTO ls_asset.
    PERFORM f_conversion_date USING pa_bldat 'O'
                              CHANGING lv_bldat.
    PERFORM f_conversion_date USING pa_budat 'O'
                              CHANGING lv_budat.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPLAMDP'       '0100',
      ' '   'BDC_OKCODE'     '=SHWD',
      ' '   'RAIFP2-ANLN1'   ls_asset-anln1,
      ' '   'RAIFP2-ANLN2'   ls_asset-anln2,
      ' '   'RAIFP1-BLDAT'   lv_bldat,
      ' '   'RAIFP1-BUDAT'   lv_budat,
      ' '   'RAIFP1-BZDAT'   lv_budat,
      ' '   'RAIFP2-SGTXT'   pa_sgtxt,
      ' '   'RAIFP3-XBANL'   'X',
      ' '   'RAIFP3-ANLN1'   ls_asset-anln3,
      ' '   'RAIFP3-ANLN2'   ls_asset-anln4.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMSSY0'       '0120',
      ' '   'BDC_OKCODE'     '=BUCH'.

    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                            t_bdcmsg
                                     USING 'ABUMN' d_bdc_tctxt.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ls_asset-icon   = icon_led_red.
      PERFORM f_show_message USING t_bdcmsg
                             CHANGING ls_asset-msgv.
    ELSE.
      ls_asset-icon   = icon_led_green.
      PERFORM f_get_document_number USING ls_asset-anln1 ls_asset-anln2
                                    CHANGING ls_asset-msgv.
    ENDIF.
    MODIFY gt_asset FROM ls_asset TRANSPORTING icon msgv.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_PARTIAL_TRANSFER_NEW
*&---------------------------------------------------------------------*
FORM f_posting_partial_transfer_new .
  DATA : ls_asset     LIKE LINE OF gt_asset.

  DATA : obj_type       LIKE bapiache09-obj_type,
         documentheader TYPE bapiache09,
         accountgl      TYPE STANDARD TABLE OF bapiacgl09,
         currencyamount TYPE STANDARD TABLE OF bapiaccr09,
         criteria       TYPE STANDARD TABLE OF bapiackec9,
         extension1     TYPE STANDARD TABLE OF bapiacextc,
         extension2     TYPE STANDARD TABLE OF bapiparex,
         return         TYPE STANDARD TABLE OF bapiret2,
         ls_return      LIKE LINE OF return.

  DATA : lv_belnr TYPE bkpf-belnr,
         lv_gjahr TYPE bkpf-gjahr,
         lt_tbsl  TYPE STANDARD TABLE OF tbsl.

  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE lt_tbsl.

  obj_type = 'BKPF'.

  LOOP AT gt_asset INTO ls_asset.
    PERFORM f_prepare_header CHANGING documentheader.

    PERFORM f_prepare_detail TABLES accountgl currencyamount extension1 extension2 criteria
                             USING ls_asset.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = documentheader
      IMPORTING
        obj_type       = obj_type
      TABLES
        accountgl      = accountgl
        currencyamount = currencyamount
        criteria       = criteria
        extension1     = extension1
        extension2     = extension2
        return         = return.

    IF sy-subrc = 0.
      LOOP AT return INTO ls_return.
        IF ls_return-type = 'S'.
          lv_belnr    = ls_return-message_v2(10).
          lv_gjahr    = ls_return-message_v2+14(4).
          CONCATENATE 'Document posted successfully :' lv_belnr lv_gjahr
          INTO ls_asset-msgv
          SEPARATED BY space.
        ENDIF.
        IF lv_belnr IS NOT INITIAL.
          ls_asset-icon   = icon_led_green.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ELSE.
          ls_asset-icon   = icon_led_red.
        ENDIF.
        IF ls_asset-msgv IS INITIAL.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = ls_return-id
              lang      = sy-langu
              no        = ls_return-number
              v1        = ls_return-message_v1
              v2        = ls_return-message_v2
              v3        = ls_return-message_v3
              v4        = ls_return-message_v4
            IMPORTING
              msg       = ls_asset-msgv
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
        ENDIF.

        MODIFY gt_asset FROM ls_asset TRANSPORTING icon msgv.
      ENDLOOP.
    ENDIF.
    CLEAR : lv_belnr, lv_gjahr.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_document_number  USING    fu_anln1 fu_anln2
                            CHANGING fc_msgv.
  DATA : lt_anek    TYPE STANDARD TABLE OF anek,
         ls_anek    LIKE LINE OF lt_anek,
         ls_message TYPE bdcmsgcoll.

  DATA : lv_tcode TYPE sy-tcode,
         lv_awkey TYPE bkpf-awkey,
         lv_belnr TYPE bkpf-belnr.

  lv_tcode  = 'ABUMN'.

  SELECT *
    FROM anek
    INTO CORRESPONDING FIELDS OF TABLE lt_anek
    WHERE bukrs = p_bukrs
      AND anln1 = fu_anln1
      AND anln2 = fu_anln2
      AND gjahr = pa_budat(4)
      AND tcode = lv_tcode.

  SORT lt_anek BY lnran DESCENDING.
  READ TABLE lt_anek INTO ls_anek INDEX 1.
  IF sy-subrc = 0.
    CONCATENATE ls_anek-belnr ls_anek-bukrs ls_anek-gjahr INTO lv_awkey.
    SELECT SINGLE belnr
      FROM bkpf
      INTO lv_belnr
      WHERE awkey = lv_awkey
        AND gjahr = pa_budat(4)
        AND tcode = lv_tcode.

    IF sy-subrc = 0.
      ls_message-msgid      = 'AA'.
      ls_message-msgnr      = '374'.
      ls_message-msgv1      = p_bukrs.
      ls_message-msgv2      = lv_belnr.

      PERFORM f_show_message USING ls_message
                             CHANGING fc_msgv.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   accountgl         STRUCTURE bapiacgl09
                                currencyamount    STRUCTURE bapiaccr09
                                extension1        STRUCTURE bapiacextc
                                extension2        STRUCTURE bapiparex
                                criteria          STRUCTURE bapiackec9
                       USING    fs_asset    TYPE ty_asset.

  DATA : ls_anla LIKE LINE OF gt_anla,
         ls_t095 LIKE LINE OF gt_t095.

  DATA : lv_buzei  TYPE bseg-buzei,
         lv_count  TYPE i,
         lv_ktansw TYPE t095-ktansw,
         lv_nbval  TYPE anlcv-bchwrt_gje.

  CLEAR : accountgl[], currencyamount[], extension1[], criteria[].

  ADD 1 TO lv_count.
  lv_buzei  = lv_count.
  CLEAR : ls_anla, ls_t095, lv_ktansw.
  READ TABLE gt_anla INTO ls_anla
                     WITH KEY anln1 = fs_asset-anln1
                              anln2 = fs_asset-anln2.
  IF sy-subrc = 0.
    READ TABLE gt_t095 INTO ls_t095
                       WITH KEY ktogr = ls_anla-ktogr.
    IF sy-subrc = 0.
      PERFORM f_modify_data USING 'ALPHA' ls_t095-ktansw 'INPUT'
                            CHANGING lv_ktansw.
    ENDIF.
  ENDIF.

  IF fs_asset-nbval = 0.
    lv_nbval  = fs_asset-anbtr.
  ELSE.
    lv_nbval  = fs_asset-nbval.
  ENDIF.

  PERFORM f_line_post TABLES  accountgl
                              currencyamount
                              extension1
                              extension2
                              criteria
                      USING   '75' lv_buzei pa_sgtxt lv_nbval
                              '' lv_ktansw fs_asset-anln1 fs_asset-anln2.

  ADD 1 TO lv_count.
  lv_buzei  = lv_count.
  CLEAR : ls_anla, ls_t095, lv_ktansw.
  READ TABLE gt_anla INTO ls_anla
                     WITH KEY anln1 = fs_asset-anln3
                              anln2 = fs_asset-anln4.
  IF sy-subrc = 0.
    READ TABLE gt_t095 INTO ls_t095
                       WITH KEY ktogr = ls_anla-ktogr.
    IF sy-subrc = 0.
      PERFORM f_modify_data USING 'ALPHA' ls_t095-ktansw 'INPUT'
                            CHANGING lv_ktansw.
    ENDIF.
  ENDIF.

  PERFORM f_line_post TABLES  accountgl
                              currencyamount
                              extension1
                              extension2
                              criteria
                      USING   '70' lv_buzei pa_sgtxt lv_nbval
                              '' lv_ktansw fs_asset-anln3 fs_asset-anln4.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LINE_POST
*&---------------------------------------------------------------------*
FORM f_line_post  TABLES   accountgl         STRUCTURE bapiacgl09
                           currencyamount    STRUCTURE bapiaccr09
                           extension1        STRUCTURE bapiacextc
                           extension2        STRUCTURE bapiparex
                           criteria          STRUCTURE bapiackec9
                   USING   fu_bschl fu_buzei fu_sgtxt fu_wrbtr
                           fu_zuonr fu_hkont fu_anln1 fu_anln2.

  DATA : lv_wrbtr TYPE s626-zdisb1,
         lv_gsber TYPE bseg-gsber VALUE '3603'.

  accountgl-itemno_acc         = fu_buzei.
  accountgl-bus_area           = lv_gsber.
  accountgl-gl_account         = fu_hkont.
  accountgl-alloc_nmbr         = fu_zuonr.
  accountgl-item_text          = fu_sgtxt.
  accountgl-asset_no           = fu_anln1.
  accountgl-sub_number         = fu_anln2.
  accountgl-acct_type          = 'A'.
  APPEND accountgl.

  extension1(3)                = fu_buzei.
  extension1+3(2)              = fu_bschl.
  APPEND extension1.

  extension2-structure         = 'ANBWA'.
  extension2-valuepart1        = fu_buzei.
  extension2-valuepart2        = '110'.
  APPEND extension2.
  CLEAR extension2.

  currencyamount-itemno_acc    = fu_buzei.
  currencyamount-curr_type     = '00'.
  currencyamount-currency      = 'IDR'.
  lv_wrbtr  = abs( fu_wrbtr ).
*  lv_wrbtr = lv_wrbtr / 100.
  PERFORM f_value_conversion USING lv_wrbtr fu_bschl
                             CHANGING currencyamount-amt_doccur.
  APPEND currencyamount.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_HEADER
*&---------------------------------------------------------------------*
FORM f_prepare_header  CHANGING documentheader   TYPE bapiache09.
  CLEAR : documentheader.

  documentheader-bus_act    = 'RFBU'.    "'RMWE'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = p_bukrs.
  documentheader-doc_date   = pa_bldat.
  documentheader-pstng_date = pa_budat.
  documentheader-fisc_year  = pa_budat(4).
  documentheader-doc_type   = 'AA'.
  documentheader-ref_doc_no = ''.
  documentheader-header_txt = ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_value_conversion  USING    fu_value fu_bschl
                         CHANGING fc_value.
  DATA : ls_tbsl      LIKE LINE OF gt_tbsl,
         lv_value(15).

  lv_value = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl
                     WITH KEY bschl = fu_bschl.
  IF ls_tbsl-shkzg = 'H'.
    fc_value = fc_value * -1.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_AMOUNT_POSTED
*&---------------------------------------------------------------------*
FORM f_change_amount_posted .
  DATA : ls_asset LIKE LINE OF gt_asset,
         ants     TYPE ants,
         t_anlb   TYPE STANDARD TABLE OF anlb,
         xanlbza  TYPE STANDARD TABLE OF anlbza,
         t_anlc   TYPE STANDARD TABLE OF anlc,
         t_anlz   TYPE STANDARD TABLE OF anlz,
         t_anea   TYPE STANDARD TABLE OF anea,
         t_anep   TYPE STANDARD TABLE OF anep,
         t_anfm   TYPE STANDARD TABLE OF anfm,
         s_anlcv  TYPE anlcv.

  LOOP AT gt_asset INTO ls_asset.
    CLEAR : ants, s_anlcv.
    READ TABLE gt_ants INTO ants
                       WITH KEY anln1 = ls_asset-anln1
                                anln2 = ls_asset-anln2.
    IF sy-subrc = 0.
      CLEAR : t_anlb[], xanlbza[], t_anlc[], t_anlz[],
              t_anea[], t_anep[].

      LOOP AT gt_anlb INTO DATA(ls_anlb)
                      WHERE anln1 = ls_asset-anln1
                        AND anln2 = ls_asset-anln2.
        APPEND ls_anlb TO t_anlb.
        CLEAR ls_anlb.
      ENDLOOP.

      LOOP AT gt_anlbza INTO DATA(ls_anlbza)
                        WHERE anln1 = ls_asset-anln1
                          AND anln2 = ls_asset-anln2.
        APPEND ls_anlbza TO xanlbza.
        CLEAR ls_anlbza.
      ENDLOOP.

      LOOP AT gt_anlc INTO DATA(ls_anlc)
                      WHERE anln1 = ls_asset-anln1
                        AND anln2 = ls_asset-anln2.
        APPEND ls_anlc TO t_anlc.
        CLEAR ls_anlc.
      ENDLOOP.

      LOOP AT gt_anlz INTO DATA(ls_anlz)
                      WHERE anln1 = ls_asset-anln1
                        AND anln2 = ls_asset-anln2.
        APPEND ls_anlz TO t_anlz.
        CLEAR ls_anlz.
      ENDLOOP.

      LOOP AT gt_anea INTO DATA(ls_anea)
                      WHERE anln1 = ls_asset-anln1
                        AND anln2 = ls_asset-anln2.
        APPEND ls_anea TO t_anea.
        CLEAR ls_anea.
      ENDLOOP.

      LOOP AT gt_anep INTO DATA(ls_anep)
                      WHERE anln1 = ls_asset-anln1
                        AND anln2 = ls_asset-anln2.
        APPEND ls_anep TO t_anep.
        CLEAR ls_anep.
      ENDLOOP.

      CALL FUNCTION 'ZFFM_ASSET'
        EXPORTING
          ants     = ants
          i_datbis = gv_datum
        IMPORTING
          e_anlcv  = s_anlcv
        TABLES
          t_anea   = t_anea
          t_anep   = t_anep
          t_anfm   = t_anfm
          t_anlb   = t_anlb
          t_anlc   = t_anlc
          t_anlz   = t_anlz
          t_anlbza = xanlbza.

      ls_asset-nbval = s_anlcv-bchwrt_gje.
      IF ls_asset-nbval = 0.
        ls_asset-icon  = icon_led_yellow.
        ls_asset-nbval = ls_asset-anbtr.
      ENDIF.
      MODIFY gt_asset FROM ls_asset TRANSPORTING icon nbval.
    ENDIF.
    CLEAR ls_asset.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_ASSET
*&---------------------------------------------------------------------*
FORM f_get_asset .
  DATA : ls_asset LIKE LINE OF gt_asset,
         ls_anla  LIKE LINE OF gt_anla,
         ls_ants  LIKE LINE OF gt_ants.

  DATA : lv_afabe TYPE anlc-afabe,
         lv_gjahr TYPE anlc-gjahr,
         lv_datum TYPE sy-datum.

  lv_afabe  = '01'.
  lv_datum  = |{ pa_budat(6) }{ '01' }|.
  gv_datum  = lv_datum - 1.
  lv_gjahr  = gv_datum(4).

  LOOP AT gt_anla INTO ls_anla.
    READ TABLE gt_asset INTO ls_asset
                        WITH KEY anln1 = ls_anla-anln1
                                 anln2 = ls_anla-anln2.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_anla TO ls_ants.
      APPEND ls_ants TO gt_ants.
      CLEAR ls_ants.
    ENDIF.
  ENDLOOP.

  IF gt_ants[] IS NOT INITIAL.
    SELECT *
      FROM anlb
      INTO CORRESPONDING FIELDS OF TABLE gt_anlb
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND afabe = lv_afabe
        AND bdatu >= gv_datum.

    SELECT *
      FROM anlbza
      INTO CORRESPONDING FIELDS OF TABLE gt_anlbza
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND afabe = lv_afabe
        AND bdatu >= gv_datum.

    SELECT *
      FROM anlc
      INTO CORRESPONDING FIELDS OF TABLE gt_anlc
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND gjahr = lv_gjahr
        AND afabe = lv_afabe.

    SELECT *
      FROM anlz
      INTO CORRESPONDING FIELDS OF TABLE gt_anlz
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND bdatu >= gv_datum.

    SELECT *
      FROM anea
      INTO CORRESPONDING FIELDS OF TABLE gt_anea
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND gjahr = lv_gjahr
        AND afabe = lv_afabe.

    SELECT *
      FROM anep
      INTO CORRESPONDING FIELDS OF TABLE gt_anep
      FOR ALL ENTRIES IN gt_ants
      WHERE bukrs = gt_ants-bukrs
        AND anln1 = gt_ants-anln1
        AND anln2 = gt_ants-anln2
        AND gjahr = lv_gjahr
        AND afabe = lv_afabe.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_PARTIAL_TRANSFER_BDC
*&---------------------------------------------------------------------*
FORM f_posting_partial_transfer_bdc .
  DATA : ls_asset     LIKE LINE OF gt_asset,
         ls_anla      LIKE LINE OF gt_anla,
         lv_bldat(10),
         lv_budat(10),
         lv_wrbtr(20),
         lv_nbval     TYPE anlcv-bchwrt_gje.

  d_bdc_batch = 'N'.

  LOOP AT gt_asset INTO ls_asset.
    PERFORM f_conversion_date USING pa_bldat 'O'
                              CHANGING lv_bldat.
    PERFORM f_conversion_date USING pa_budat 'O'
                              CHANGING lv_budat.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPLAMDP'       '0100',
      ' '   'BDC_OKCODE'     '=TAB02',
      ' '   'RAIFP2-ANLN1'   ls_asset-anln1,
      ' '   'RAIFP2-ANLN2'   ls_asset-anln2,
      ' '   'RAIFP1-BLDAT'   lv_bldat,
      ' '   'RAIFP1-BUDAT'   lv_budat,
      ' '   'RAIFP1-BZDAT'   lv_budat,
      ' '   'RAIFP2-SGTXT'   pa_sgtxt,
      ' '   'RAIFP3-XBANL'   'X',
      ' '   'RAIFP3-ANLN1'   ls_asset-anln3,
      ' '   'RAIFP3-ANLN2'   ls_asset-anln4.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPLAMDP'       '0100',
      ' '   'BDC_OKCODE'     '=TAB03',
      ' '   'RAIFP2-MONAT'   lv_budat+3(2),
      ' '   'RAIFP1-BLART'   'AA'.

    IF ls_asset-nbval = 0.
      lv_nbval = ls_asset-anbtr.
    ELSE.
      lv_nbval = ls_asset-nbval.
    ENDIF.

    PERFORM f_amount_modify USING lv_nbval 'IDR' '' 'O'
                            CHANGING lv_wrbtr.

    CLEAR ls_anla.
    READ TABLE gt_anla INTO ls_anla
                       WITH KEY anln1 = ls_asset-anln1
                                anln2 = ls_asset-anln2.
    IF pa_budat(4) = ls_anla-aktiv(4).
      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X'   'SAPLAMDP'       '0100',
        ' '   'BDC_OKCODE'     '=SHWD',
        ' '   'RAIFP2-ANBTR'   lv_wrbtr,
        ' '   'RAIFP2-XANEU'   'X'.
    ELSE.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X'   'SAPLAMDP'       '0100',
        ' '   'BDC_OKCODE'     '=SHWD',
        ' '   'RAIFP2-ANBTR'   lv_wrbtr,
        ' '   'RAIFP2-XAALT'   'X'.
    ENDIF.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMSSY0'       '0120',
      ' '   'BDC_OKCODE'     '=BUCH'.

    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                            t_bdcmsg
                                     USING 'ABUMN' d_bdc_tctxt.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ls_asset-icon   = icon_led_red.
      PERFORM f_show_message USING t_bdcmsg
                             CHANGING ls_asset-msgv.
    ELSE.
      ls_asset-icon   = icon_led_green.
      PERFORM f_get_document_number USING ls_asset-anln1 ls_asset-anln2
                                    CHANGING ls_asset-msgv.
    ENDIF.
    MODIFY gt_asset FROM ls_asset TRANSPORTING icon msgv.
    CLEAR ls_asset.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYN_DATA
*&---------------------------------------------------------------------*
FORM f_dyn_data  USING    fu_typename.
  DATA : dyn_table      TYPE REF TO data,
         dyn_line       TYPE REF TO data,
         lo_structdescr TYPE REF TO cl_abap_structdescr,
         lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
         ddfields       TYPE ddfields,
         dfies          TYPE dfies,
         ls_fieldcat    TYPE lvc_s_fcat.

  DATA : lv_colpos      TYPE lvc_s_fcat-col_pos.

  lo_structdescr ?= cl_abap_typedescr=>describe_by_name( fu_typename ).
  lo_tabledescr = cl_abap_tabledescr=>create( lo_structdescr ).

  ddfields = cl_salv_data_descr=>read_structdescr( lo_structdescr ).
  LOOP AT ddfields INTO dfies.
    MOVE-CORRESPONDING dfies TO ls_fieldcat.
    ADD 1 TO lv_colpos.
    ls_fieldcat-col_pos = lv_colpos.
    APPEND ls_fieldcat TO gt_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_new_upload_data  USING    fu_tabname.
  DATA : intern       TYPE STANDARD TABLE OF alsmex_tabline.

  DATA : lv_ecol      TYPE i.

  CLEAR : intern[].

  DESCRIBE TABLE gt_fieldcat LINES lv_ecol.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = lv_ecol
      i_end_row               = 65000
    TABLES
      intern                  = intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  PERFORM f_move_xls_to_table TABLES intern.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_XLS_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_move_xls_to_table  TABLES   intern STRUCTURE alsmex_tabline.
  DATA : ls_intern   TYPE alsmex_tabline,
         lt_fieldcat TYPE lvc_t_fcat,
         ls_fieldcat LIKE LINE OF gt_fieldcat,
         dyn_tab     TYPE REF TO data,
         dyn_line    TYPE REF TO data.

  DATA : lv_value  TYPE string.

  FIELD-SYMBOLS : <fs>  TYPE any.

  lt_fieldcat[] = gt_fieldcat[].

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = lt_fieldcat
      i_length_in_byte          = 'X'
    IMPORTING
      ep_table                  = dyn_tab
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  ASSIGN dyn_tab->* TO <fs_data>.
  CREATE DATA dyn_line LIKE LINE OF <fs_data>.
  ASSIGN dyn_line->* TO <fs_line>.

  LOOP AT intern INTO ls_intern.
    CLEAR ls_fieldcat.
    READ TABLE gt_fieldcat INTO ls_fieldcat
                           WITH KEY col_pos = ls_intern-col.
    IF sy-subrc = 0.
      ASSIGN COMPONENT ls_fieldcat-fieldname OF STRUCTURE <fs_line> TO <fs>.
      CASE ls_fieldcat-datatype .
        WHEN 'DATS'.
          lv_value = ls_intern-value.
          PERFORM f_date_format CHANGING ls_intern-value.
      ENDCASE.
      <fs> = ls_intern-value.
    ENDIF.
    AT END OF row.
      APPEND <fs_line> TO <fs_data>.
      CLEAR ls_intern.
    ENDAT.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DATE_FORMAT
*&---------------------------------------------------------------------*
FORM f_date_format  CHANGING fc_value.
  DATA : lv_value TYPE string,
         lv_count TYPE i,
         lv_lines TYPE i,
         lv_date  TYPE n LENGTH 2,
         lv_datum TYPE sy-datum,
         lv_mnr   TYPE t247-mnr.

  DATA : lt_t247   TYPE STANDARD TABLE OF t247,
         ls_t247   LIKE LINE OF lt_t247,
         lr_spras  TYPE RANGE OF spras,
         ls_spras  LIKE LINE OF lr_spras,
         lt_string TYPE STANDARD TABLE OF string,
         ls_string LIKE LINE OF lt_string.

  lv_value = fc_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING '/ '.
  TRANSLATE lv_value USING '- '.

  ls_spras-low    = sy-langu.
  ls_spras-sign   = 'I'.
  ls_spras-option = 'EQ'.
  APPEND ls_spras TO lr_spras.
  ls_spras-low    = 'i'.
  ls_spras-sign   = 'I'.
  ls_spras-option = 'EQ'.
  APPEND ls_spras TO lr_spras.

  SELECT *
    FROM t247
    INTO CORRESPONDING FIELDS OF TABLE lt_t247
    WHERE spras IN lr_spras.

  LOOP AT lt_t247 INTO ls_t247.
    TRANSLATE ls_t247-ltx TO UPPER CASE.
    MODIFY lt_t247 FROM ls_t247 TRANSPORTING ltx.
    CLEAR ls_t247.
  ENDLOOP.

  SPLIT lv_value AT space INTO TABLE lt_string.
  LOOP AT lt_string INTO ls_string.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        lv_lines = strlen( ls_string ).
        CASE lv_lines.
          WHEN 1.
            lv_date       = ls_string.
            lv_datum+6(2) = lv_date.
          WHEN 2.
            lv_datum+6(2) = ls_string.
        ENDCASE.
      WHEN 2.
        lv_lines = strlen( ls_string ).
        CASE lv_lines.
          WHEN 1.
            lv_mnr        = ls_string.
            lv_datum+4(2) = lv_mnr.
          WHEN 2.
            lv_datum+4(2) = ls_string.
          WHEN 3.
            TRANSLATE ls_string TO UPPER CASE.
            CLEAR ls_t247.
            READ TABLE lt_t247 INTO ls_t247
                               WITH KEY ktx = ls_string.
            IF sy-subrc = 0.
              lv_datum+4(2) = ls_t247-mnr.
            ENDIF.
          WHEN OTHERS.
            TRANSLATE ls_string TO UPPER CASE.
            CLEAR ls_t247.
            READ TABLE lt_t247 INTO ls_t247
                               WITH KEY ltx = ls_string.
            IF sy-subrc = 0.
              lv_datum+4(2) = ls_t247-mnr.
            ENDIF.
        ENDCASE.
      WHEN 3.
        lv_datum(4) = ls_string.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_datum
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.

  IF sy-subrc = 0.
    fc_value = lv_datum.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_BAPI_PARAM
*&---------------------------------------------------------------------*
FORM f_new_bapi_param USING   fu_tabname.
  FIELD-SYMBOLS : <fs> TYPE any.

  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs>.
  gv_key-companycode          = <fs>.
  ASSIGN COMPONENT 'ANLKL' OF STRUCTURE <fs_line> TO <fs>.
  gv_gendata-assetclass       = <fs>.
  ASSIGN COMPONENT 'TXT50' OF STRUCTURE <fs_line> TO <fs>.
  gv_gendata-descript         = <fs>.
  gv_gendata-descript2        = gv_gendata-descript.
  gv_gendata-main_descript    = gv_gendata-descript.
  ASSIGN COMPONENT 'SERNR' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    PERFORM f_modify_data USING 'ALPHA' <fs> 'INPUT'
                          CHANGING gv_gendata-serial_no.
  ENDIF.
  ASSIGN COMPONENT 'GSBER' OF STRUCTURE <fs_line> TO <fs>.
  gv_timedep-bus_area         = <fs>.
  ASSIGN COMPONENT 'KOSTL' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    PERFORM f_modify_data USING 'ALPHA' <fs> 'INPUT'
                          CHANGING gv_timedep-costcenter.
  ENDIF.

  CASE fu_tabname.
    WHEN 'ZTIAMFIST0021'.
      ASSIGN COMPONENT 'PRCTR' OF STRUCTURE <fs_line> TO <fs>.
      gv_inventory-note           = <fs>.
    WHEN 'ZTIAMFIST0022'.
      ASSIGN COMPONENT 'INVZU' OF STRUCTURE <fs_line> TO <fs>.
      gv_inventory-note           = <fs>.
      ASSIGN COMPONENT 'RAUMN' OF STRUCTURE <fs_line> TO <fs>.
      gv_timedep-room             = <fs>.
      ASSIGN COMPONENT 'TYPBZ' OF STRUCTURE <fs_line> TO <fs>.
      gv_origin-type_name         = <fs>.
    WHEN 'ZTIAMFIST0023'.
      ASSIGN COMPONENT 'PRCTR' OF STRUCTURE <fs_line> TO <fs>.
      gv_inventory-note           = <fs>.
      ASSIGN COMPONENT 'ROOM' OF STRUCTURE <fs_line> TO <fs>.
      gv_timedep-room             = <fs>.
      ASSIGN COMPONENT 'PLATE_NO' OF STRUCTURE <fs_line> TO <fs>.
      gv_timedep-plate_no         = <fs>.
      ASSIGN COMPONENT 'EAUFN' OF STRUCTURE <fs_line> TO <fs>.
      gv_origin-type_name         = <fs>.
      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_line> TO <fs>.
      gv_origin-vendor_no        = <fs>.
  ENDCASE.

  ASSIGN COMPONENT 'EAUFN' OF STRUCTURE <fs_line> TO <fs>.
  gv_invest-invest_ord        = <fs>.

  CLEAR gt_depareas.
  gt_depareas-area            = '01'.
  ASSIGN COMPONENT 'AFABG' OF STRUCTURE <fs_line> TO <fs>.
  gt_depareas-odep_start_date = <fs>.
  APPEND gt_depareas.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_BAPI_PARAMX
*&---------------------------------------------------------------------*
FORM f_new_bapi_paramx USING   fu_tabname.
  gv_gendatax-assetclass       = 'X'.
  gv_gendatax-descript         = 'X'.
  gv_gendatax-descript2        = 'X'.
  gv_gendatax-main_descript    = 'X'.
*  gv_gendatax-serial_no        = 'X'.

  gv_timedepx-bus_area         = 'X'.
  gv_timedepx-costcenter       = 'X'.

  CASE fu_tabname.
    WHEN 'ZTIAMFIST0021'.
      gv_inventoryx-note           = 'X'.

    WHEN 'ZTIAMFIST0022'.
      gv_inventoryx-note           = 'X'.
      gv_originx-type_name         = 'X'.
      gv_timedepx-room             = 'X'.
      gv_timedepx-license_plate_no = 'X'.

    WHEN 'ZTIAMFIST0023'.
      gv_inventoryx-note           = 'X'.
      gv_timedepx-room             = 'X'.
      gv_timedepx-license_plate_no = 'X'.
      gv_originx-type_name         = 'X'.
      gv_originx-vendor_no         = 'X'.
  ENDCASE.

  gv_investx-invest_ord        = 'X'.

  CLEAR gt_depareasx.
  gt_depareasx-area            = '01'.
  gt_depareasx-odep_start_date = 'X'.
  APPEND gt_depareasx.
ENDFORM.
