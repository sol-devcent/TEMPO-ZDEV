*&---------------------------------------------------------------------*
*&  Include           ZDG2MM_I0007F01
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
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  DATA g_event_handler TYPE REF TO lcl_event_handler.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR: fcode, fcode[].
  CASE 'X'.
    WHEN p_rad1.
      APPEND 'REL' TO fcode.
      APPEND 'UNREL' TO fcode.
      APPEND 'DOWN' TO fcode.
*      APPEND '&ALL' TO fcode.
*      APPEND '&SAL' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_0500'.
    WHEN p_rad3.
      APPEND 'DOWN' TO fcode.
      APPEND 'UNREL' TO fcode.
      APPEND 'CRTBI' TO fcode.
      APPEND 'KR1A' TO fcode.
      APPEND 'BI' TO fcode.
      APPEND '&ALL' TO fcode.
      APPEND '&SAL' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_0100'.
    WHEN p_rad4 OR p_rad6.
      APPEND 'REL' TO fcode.
      APPEND 'UNREL' TO fcode.
      APPEND 'CRTBI' TO fcode.
      APPEND 'KR1A' TO fcode.
      APPEND 'BI' TO fcode.
      APPEND '&ALL' TO fcode.
      APPEND '&SAL' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_0200'.
    WHEN p_rad5.
      APPEND 'REL' TO fcode.
      APPEND 'DOWN' TO fcode.
      APPEND 'CRTBI' TO fcode.
      APPEND 'KR1A' TO fcode.
      APPEND 'BI' TO fcode.
      APPEND '&ALL' TO fcode.
      APPEND '&SAL' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_0300'.
    WHEN p_rad7.
      APPEND 'REL' TO fcode.
      APPEND 'UNREL' TO fcode.
      APPEND 'DOWN' TO fcode.
      APPEND 'CRTBI' TO fcode.
      APPEND 'KR1A' TO fcode.
      APPEND 'BI' TO fcode.
      APPEND '&ALL' TO fcode.
      APPEND '&SAL' TO fcode.
      SET PF-STATUS 'STATUS_0100' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_0700'.
  ENDCASE.

  IF g_custom_container IS INITIAL.
*  IF g_grid IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    CASE 'X'.
      WHEN p_rad1.
        PERFORM f_build_fieldcat1.
        PERFORM f_build_sortfield1.
      WHEN p_rad7.
        PERFORM f_build_fieldcat7.
        PERFORM f_build_sortfield7.
      WHEN OTHERS.
        PERFORM f_build_fieldcat.
        PERFORM f_build_sortfield.
    ENDCASE.

    PERFORM f_build_layout.
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
    CASE 'X'.
      WHEN p_rad1.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out[]
            it_sort              = gt_sort[].
      WHEN p_rad7.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out7[]
            it_sort              = gt_sort[].
      WHEN OTHERS.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out2[]
            it_sort              = gt_sort[].
    ENDCASE.

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
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  IF p_rad4 IS INITIAL AND p_rad6 IS INITIAL.
    PERFORM f_fieldcatg USING 'GT_OUT2':
      'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' ''.
  ENDIF.
  PERFORM f_fieldcatg USING 'GT_OUT2':
    'BBELN' '' '' '' '10' 'No B/I' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DCP' '' '' '' '6' 'No DCP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SDATE' '' '' '' '10' 'Tgl DCP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PARNR' '' '' '' '10' 'Kode Sales' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SNAME' '' '' '' '30' 'Nama Sales' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CNT_OUT' '' '' '' '15' 'Jumlah Outlet' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CNT_DN' '' '' '' '15' 'Jumlah DN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' '' '' '' '15' 'Total Amount' '' '' '' 'IDR' '' '' '' '' '' '' '' '' ''.

  IF p_rad6 IS NOT INITIAL.
    PERFORM f_fieldcatg USING 'GT_OUT2':
      'FILENM_DWN' '' '' '' '10' 'Filename' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT1
*&---------------------------------------------------------------------*
FORM f_build_fieldcat1 .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_OUT2':
    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '',
    'ZICON' '' '' '' '5' 'Icon' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'BSID' 'KUNNR' '' '' 'Pelanggan' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' 'Nama_Pelanggan' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BLART' 'BSID' 'BLART' '' '' 'DocTy' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'BSEG' 'ZUONR' '' '' 'Nomor_DN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNR' 'BSID' 'BELNR' '' '' 'Nomor_Billing' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BLDAT' 'BSID' 'BLDAT' '' '' 'Tanggal_DN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFBDT' 'BSID' 'ZFBDT' '' '' 'Base LDate' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUDAT' 'ZFBID_SFA' 'DUDAT' '' '' 'Due_Date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WRBTR' 'ZFBID_SFA' 'WRBTR' '' '' 'Amount' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOTTF' 'ZFBID_SFA' 'NOTTF' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TGLTTF' 'ZFBID_SFA' 'TGLTTF' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZTEXT' '' '' 'X' '30' 'Keterangan' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT1

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT7
*&---------------------------------------------------------------------*
FORM f_build_fieldcat7 .
  CLEAR gt_fieldcat[].
  PERFORM f_fieldcatg USING 'GT_OUT7':
    'BUKRS' 'ZFBIH_SFA' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFBIH_SFA' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BBELN' '' '' '' '10' 'No B/I' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BIDAT' '' '' '' '10' 'Tgl B/I' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PARNR' '' '' '' '10' 'Kode Sales' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SNAME' '' '' '' '30' 'Nama Sales' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PARVW' '' '' '' '10' 'PARVW' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DAILY_CALL_NUM' '' '' '' '6' 'No DCP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SDATE' '' '' '' '10' 'Tgl DCP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'BSID' 'KUNNR' '' '' 'Pelanggan' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' 'Nama_Pelanggan' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' '' '' '' '18' 'Nomor DN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' '' '' '' '15' 'Nomor Billing' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' '' '' '' '5' 'Tahun' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFBDT' '' '' '' '15' 'Baseline Date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FKDAT' '' '' '' '15' 'Billing Date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUDAT' '' '' '' '15' 'Due Date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WRBTR' 'S603' 'ZXX' '' '' 'Nilai Amount' 'X' '' '' 'IDR' '' '' '' '' '' '' '' '' '',
    'USNA1' 'ZFBIH_SFA' 'USNA1' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT1' 'ZFBIH_SFA' 'ERDT1' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET' 'ZFBIH_SFA' 'ERZET' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNA2' 'ZFBIH_SFA' 'USNA2' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT2' 'ZFBIH_SFA' 'ERDT2' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET2' 'ZFBIH_SFA' 'ERZET2' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNAM_REL' 'ZFBIH_SFA' 'USNAM_REL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT_REL' 'ZFBIH_SFA' 'ERDAT_REL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET_REL' 'ZFBIH_SFA' 'ERZET_REL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FILENM_DWN' 'ZFBIH_SFA' 'FILENM_DWN' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT_DWN' 'ZFBIH_SFA' 'ERDAT_DWN' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FILENM_UNREL' 'ZFBIH_SFA' 'FILENM_UNREL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT_UNREL' 'ZFBIH_SFA' 'ERDAT_UNREL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET_UNREL' 'ZFBIH_SFA' 'ERZET_UNREL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FILENM_UNREL' 'ZFBIH_SFA' 'FILENM_UNREL' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT7

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
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.

  IF p_rad1 = 'X'.
*    gs_layout-box_fname = 'CHBOX'.
    gs_layout-no_rowmark  = 'X'.
  ELSE.
    gs_layout-no_rowmark  = 'X'.
  ENDIF.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'BBELN'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'DCP'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD1
*&---------------------------------------------------------------------*
FORM f_build_sortfield1 .
  CLEAR gt_sort[].

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'KUNNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'ZUONR'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD1

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD7
*&---------------------------------------------------------------------*
FORM f_build_sortfield7 .
  CLEAR gt_sort[].

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'BUKRS'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'VKBUR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'BBELN'.
*  gt_sort-subtot    = 'X'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '4'.
  gt_sort-fieldname = 'BIDAT'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '5'.
  gt_sort-fieldname = 'ZUONR'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD7

*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
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
  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      PERFORM f_lock_table_check USING 'D'.
      LEAVE TO SCREEN 0.
    WHEN '&ALL'.
      PERFORM select_all_checkboxes.
    WHEN '&SAL'.
      PERFORM deselect_all_checkboxes.
    WHEN 'REL'.
      PERFORM f_release_table.
      LEAVE TO SCREEN 0.
    WHEN 'UNREL'.
      PERFORM f_unrelease_table.
      LEAVE TO SCREEN 0.
    WHEN 'DOWN'.
      PERFORM f_download_data.
      LEAVE TO SCREEN 0.
    WHEN 'CRTBI'.
      PERFORM f_create_bi.
    WHEN 'KR1A' OR 'BI'.
      save_ok = sy-ucomm.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all_checkboxes .
  DATA: lt_filtered_entries TYPE lvc_t_fidx.                "#EC NEEDED
  DATA: ls_filtered_entries LIKE LINE OF lt_filtered_entries .
  DATA: lt_filter TYPE lvc_t_filt.                          "#EC NEEDED

  g_grid->get_filtered_entries(
    IMPORTING et_filtered_entries = lt_filtered_entries ).

  g_grid->get_filter_criteria(
    IMPORTING et_filter = lt_filter ).

  gt_out-chbox = abap_true.
  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.

  IF lt_filter[] IS NOT INITIAL.
    LOOP AT lt_filtered_entries INTO ls_filtered_entries.
      READ TABLE gt_out ASSIGNING <fs_out> INDEX ls_filtered_entries.
      <fs_out>-chbox = abap_false.
    ENDLOOP.
  ENDIF.

*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " SELECT_ALL_CHECKBOXES

*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all_checkboxes .
  gt_out-chbox = abap_false.
  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_true.
*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " DESELECT_ALL_CHECKBOXES

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data .
  gv_repid = sy-repid.
  gs_variant-report = gv_repid.
*  gs_variant-variant = pa_vari.

  CASE 'X'.
    WHEN p_rad1 OR p_rad2.
      gr_pernr[] = s_pernr1[].
      gr_sdate[] = s_sdate1[].
      gr_dcp[]   = s_daily1[].
      gr_bbeln[] = s_bbeln1[].
    WHEN OTHERS.
      gr_pernr[] = s_pernr2[].
      gr_sdate[] = s_sdate2[].
      gr_dcp[]   = s_daily2[].
      gr_bbeln[] = s_bbeln2[].
  ENDCASE.

  CLEAR: gv_bbeln,gv_ready.
  IF p_inkas1 IS INITIAL.
    SELECT SINGLE bbeln INTO gv_bbeln
      FROM zfbih_sfa WHERE bukrs = p_vkorg
                       AND vkbur = p_vkbur
                       AND parnr IN gr_pernr
                       AND sdate IN gr_sdate.
  ENDIF.
*  IF sy-subrc = 0.
*    gv_ready = 'X'.
*  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  CASE 'X'.
    WHEN p_rad1.
      IF gv_bbeln IS INITIAL. "gv_ready IS INITIAL.
        PERFORM f_get_data_rad1.
      ELSE.
        MESSAGE 'Data sudah dibuat BI, silahkan gunakan menu UPDATE' TYPE 'S'.
        STOP.
      ENDIF.
    WHEN p_rad2.
      PERFORM f_get_data_rad2.
      PERFORM f_get_customer_route.
      PERFORM f_get_data_rad1_a.
    WHEN p_rad3.
      PERFORM f_get_data_rad2.
      PERFORM f_remove_delete_item.
    WHEN p_rad4 OR p_rad5 OR p_rad6.
      PERFORM f_get_data_rad3.
      PERFORM f_remove_delete_item.
    WHEN p_rad7.
      PERFORM f_get_data_rad7.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN p_rad1.
      IF gv_ready IS INITIAL.
        PERFORM f_process_data_rad1.
      ELSE.
        PERFORM f_process_data_rad2.
      ENDIF.
    WHEN p_rad2.
      PERFORM f_process_data_rad1.
      PERFORM f_process_data_rad2.
    WHEN p_rad3 OR p_rad4 OR p_rad5 OR p_rad6.
      PERFORM f_process_data_rad3.
    WHEN p_rad7.
      PERFORM f_process_data_rad7.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.

* Koreksi after Training SFA
* Create BI display dg ALV
*    WHEN p_rad1 OR p_rad2.
    WHEN p_rad2.
      CLEAR gv_msgfl.
      REFRESH CONTROL 'INPUT' FROM SCREEN 500.
      CALL SCREEN 500.

    WHEN p_rad1 OR p_rad3 OR p_rad4 OR p_rad5 OR p_rad6 OR p_rad7.
      CALL SCREEN 100.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory .
  CLEAR: gv_bbeln,va_bbeln,gv_ready,gv_new.
  CLEAR: gt_knvp1[],gt_knvp2[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN p_rad1.
      PERFORM f_modify_screen USING : 'PI2' '0' '' '' ''.
      IF p_inkas1 IS INITIAL.
        PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                        'SZU' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'SD1' '0' '' '' '',
                                        'DA1' '0' '' '' '',
                                        'PE1' '0' '' '' ''.
      ENDIF.
    WHEN p_rad2.
      PERFORM f_modify_screen USING : 'PI1' '0' '' '' ''.
      IF p_inkas2 IS INITIAL.
        PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                        'SZU' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'SD1' '0' '' '' '',
                                        'DA1' '0' '' '' '',
                                        'PE1' '0' '' '' ''.
      ENDIF.
    WHEN p_rad3.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PI1' '0' '' '' '',
                                      'PI2' '0' '' '' ''.
    WHEN p_rad4.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PI1' '0' '' '' '',
                                      'PI2' '0' '' '' ''.
    WHEN p_rad5.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PI1' '0' '' '' '',
                                      'PI2' '0' '' '' ''.
    WHEN p_rad6.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PI1' '0' '' '' '',
                                      'PI2' '0' '' '' ''.
    WHEN p_rad7.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PI1' '0' '' '' '',
                                      'PI2' '0' '' '' ''.
  ENDCASE.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'PE2' OR 'SD2' OR 'DA2' OR 'DAI'.
        CASE 'X'.
          WHEN p_rad1 OR p_rad2.
            screen-active = '0'.
            MODIFY SCREEN.
          WHEN OTHERS.
            screen-active = '1'.
            MODIFY SCREEN.
        ENDCASE.
      WHEN 'PE1' OR 'SD1' OR 'DA1'.
        CASE 'X'.
          WHEN p_rad1 OR p_rad2.
            screen-active = '1'.
            MODIFY SCREEN.
          WHEN OTHERS.
            screen-active = '0'.
            MODIFY SCREEN.
        ENDCASE.
      WHEN 'BB1'.
        CASE 'X'.
          WHEN p_rad2.
            screen-active = '1'.
            MODIFY SCREEN.
          WHEN OTHERS.
            screen-active = '0'.
            MODIFY SCREEN.
        ENDCASE.
      WHEN 'BB2'.
        CASE 'X'.
          WHEN p_rad1 OR p_rad2.
            screen-active = '0'.
            MODIFY SCREEN.
          WHEN OTHERS.
            screen-active = '1'.
            MODIFY SCREEN.
        ENDCASE.
      WHEN 'PAT'.
        CASE 'X'.
          WHEN p_rad4 OR p_rad6.
            screen-active = '1'.
            screen-input  = '0'.
            MODIFY SCREEN.
          WHEN OTHERS.
            screen-active = '0'.
            MODIFY SCREEN.
        ENDCASE.
      WHEN 'MO4'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_vkorg IS INITIAL.
    PERFORM f_screen_error USING 'PVO'.
  ENDIF.
  IF p_vkbur IS INITIAL.
    PERFORM f_screen_error USING 'PVB'.
  ENDIF.

  CASE 'X'.
    WHEN p_rad1.
      IF p_inkas1 IS INITIAL.
        IF s_pernr1[] IS INITIAL.
          PERFORM f_screen_error USING 'PE1'.
        ENDIF.
        IF s_sdate1[] IS INITIAL.
          PERFORM f_screen_error USING 'SD1'.
        ENDIF.
      ELSE.
        CLEAR s_pernr1[].
        IF s_kunnr[] IS INITIAL.
          PERFORM f_screen_error USING 'SKU'.
        ENDIF.
      ENDIF.
    WHEN p_rad2.
      IF p_inkas2 IS INITIAL.
        IF s_pernr1[] IS INITIAL.
          PERFORM f_screen_error USING 'PE1'.
        ENDIF.
        IF s_sdate1[] IS INITIAL.
          PERFORM f_screen_error USING 'SD1'.
        ENDIF.
      ELSE.
        IF s_bbeln1-low IS INITIAL .
          PERFORM f_screen_error USING 'BB1'.
        ENDIF.
        CLEAR s_pernr1[].
      ENDIF.
    WHEN p_rad3.
    WHEN p_rad4.
    WHEN p_rad5.
    WHEN p_rad6.
      IF s_bbeln2[] IS INITIAL.
        PERFORM f_screen_error USING 'BB2'.
      ENDIF.
    WHEN p_rad7.
  ENDCASE.

*  IF p_rad1 = 'X' OR p_rad2 = 'X'.
*  ENDIF.
*  IF p_rad6 = 'X'.
*  ENDIF.
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
*&      Form  F_HEADER_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv  CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
*  DATA fcode TYPE TABLE OF sy-ucomm.

  PERFORM f_init_header_screen.
  IF gv_msgfl IS INITIAL.
    PERFORM f_check_header_data.
    gv_msgfl = 'X'.
  ENDIF.

  CLEAR: fcode, fcode[].
  IF gv_bbeln IS NOT INITIAL AND p_rad1 IS NOT INITIAL.
    APPEND 'NEW' TO fcode.
    APPEND 'DELE' TO fcode.
    APPEND 'SAVE' TO fcode.
    SET PF-STATUS 'STAT500' EXCLUDING fcode.
  ELSE.
    SET PF-STATUS 'STAT500'.
  ENDIF.

*  SET PF-STATUS 'STAT500'.
  CASE 'X'.
    WHEN p_rad1.
      SET TITLEBAR '001'.
    WHEN p_rad2.
      SET TITLEBAR '002'.
  ENDCASE.
  DESCRIBE TABLE gt_out LINES fill.
  input-lines = fill.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  READ TABLE gt_out INTO gt_vout INDEX input-current_line.

* Disable Row
  LOOP AT SCREEN.
    CASE sy-ucomm.
      WHEN 'NEW'.
*        IF gt_vout IS INITIAL.
        IF sy-subrc NE 0 OR gt_vout-zicon = icon_booking_stop.
          IF screen-name = 'GT_VOUT-KUNNR' OR
             screen-name = 'GT_VOUT-ZUONR' OR
*             screen-name = 'GT_VOUT-BLART' OR
*             screen-name = 'GT_VOUT-BELNR' OR
             screen-name = 'GT_VOUT-ZTEXT'.
            screen-input ='1'.
          ELSE.
            screen-input ='0'.
          ENDIF.
        ELSE.
          IF gt_vout-kunnr IS INITIAL.
            IF screen-name = 'GT_VOUT-KUNNR' OR
               screen-name = 'GT_VOUT-ZUONR' OR
*             screen-name = 'GT_VOUT-BLART' OR
*             screen-name = 'GT_VOUT-BELNR' OR
               screen-name = 'GT_VOUT-ZTEXT'.
              screen-input ='1'.
            ELSE.
              screen-input ='0'.
            ENDIF.
          ELSE.
            screen-input ='0'.
          ENDIF.
        ENDIF.

        IF p_inkas2 IS NOT INITIAL.
          IF screen-name = 'GT_VOUT-KUNNR'.
            screen-input ='0'.
          ENDIF.
        ENDIF.

      WHEN 'DELE'.
        IF screen-name = 'GT_VOUT-CHBOX'.
          screen-input ='1'.
        ELSE.
          screen-input ='0'.
        ENDIF.

      WHEN OTHERS.
        IF screen-name = 'GT_VOUT-CHBOX'.
          screen-input ='1'.
        ELSE.
          screen-input ='0'.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control INPUT.
  CASE sy-ucomm.
*  CASE save_ok.
    WHEN 'NEW'.
*      CLEAR gt_vout-chbox.

    WHEN 'DELE'.
*      IF gt_vout-zicon = icon_delete.     "Undelete
*        IF gt_vout-newrow IS INITIAL.
*          CLEAR gt_vout-zicon.
*        ENDIF.
*      ELSE.
*        gt_vout-zicon = icon_delete.      "Delete
*      ENDIF.
*      CLEAR gt_vout-chbox.
*      gt_vout-change = 'X'.

    WHEN 'ENTR'.
      CLEAR gt_vout-chgrow.
      IF p_inkas2 IS INITIAL.
        PERFORM f_entry_check USING gt_vout.
      ELSE.
        PERFORM f_get_fi_document CHANGING gt_vout.
      ENDIF.
  ENDCASE.

  READ TABLE gt_out INDEX input-current_line.
  IF sy-subrc = 0.
    MODIFY gt_out FROM gt_vout INDEX input-current_line.
  ELSE.
    INSERT gt_vout INTO gt_out INDEX input-current_line.
  ENDIF.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR: ok_code.

  CASE save_ok.
    WHEN 'NEW'.
      gv_new = 'X'.

    WHEN 'MARK'.
      PERFORM f_selection USING 'X'.

    WHEN 'DMRK'.
      PERFORM f_selection USING ''.

    WHEN 'DELE'.
      PERFORM f_delete_undelete.
      PERFORM f_validate_data.

    WHEN 'ENTR'.
      IF p_inkas2 IS NOT INITIAL.
        PERFORM f_validate_data.
      ENDIF.
*      PERFORM f_validate_data.

    WHEN 'SAVE'.
      IF p_inkas2 IS INITIAL.
        LOOP AT gt_out INTO gt_vout
                       WHERE zicon = space.
          PERFORM f_entry_check USING gt_vout.
        ENDLOOP.
      ELSE.
        PERFORM f_validate_data.
      ENDIF.
      PERFORM f_save_data.

    WHEN 'KR1A' OR 'BI'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.

    WHEN 'BACK'.
      PERFORM f_lock_table_check USING 'D'.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN 'CANCL'.
      PERFORM f_lock_table_check USING 'D'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ENTRY_CHECK
*&---------------------------------------------------------------------*
FORM f_entry_check  USING  ft_vout STRUCTURE gt_vout.
  DATA: lv_kunnr TYPE kunnr,
        lv_zuonr TYPE zuonr.

  DATA: ls_itab1 LIKE LINE OF i_itab1.

  FIELD-SYMBOLS: <fs_out> LIKE gt_out.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ft_vout-kunnr
    IMPORTING
      output = lv_kunnr.

  ft_vout-kunnr = lv_kunnr.

  "Check Double
  IF ft_vout-zicon IS INITIAL.
    READ TABLE gt_out WITH KEY kunnr = ft_vout-kunnr
                               zuonr = ft_vout-zuonr.
    IF sy-subrc = 0.
      ft_vout-zicon = icon_booking_stop.
      ft_vout-ztext = 'Double Entry'.
    ENDIF.
  ENDIF.

  "Check DCP / Route
  IF ft_vout-zicon IS INITIAL.
* Keputusan Training user : tdk baca dcp lagi tetapi baca routelist
*    READ TABLE gt_zssutdt026 WITH KEY kunnr = ft_vout-kunnr.
*    IF sy-subrc NE 0.
*      ft_vout-zicon = icon_booking_stop.
*      ft_vout-ztext = 'Customer tidak ada di DCP'.
    READ TABLE gt_knvp2 WITH KEY kunnr = ft_vout-kunnr.
    IF sy-subrc NE 0.
      ft_vout-zicon = icon_booking_stop.
      ft_vout-ztext = 'Customer bukan Route List Collector'.
    ELSE.
      READ TABLE i_itab1 WITH KEY kunnr = ft_vout-kunnr
                                  zuonr = ft_vout-zuonr.
      IF sy-subrc NE 0.
        READ TABLE i_itab1b WITH KEY kunnr = ft_vout-kunnr
                                     zuonr = ft_vout-zuonr.
        IF sy-subrc = 0.
          IF i_itab1b-wrbtr = 0.
            ft_vout-zicon = icon_booking_stop.
            ft_vout-ztext = 'Amount Nol'.
          ELSEIF i_itab1b-zlspr = 'B'.
            ft_vout-zicon = icon_booking_stop.  "icon_delete.
            ft_vout-ztext = 'DN masih terikat BI'.
          ENDIF.
        ELSE.
          ft_vout-zicon = icon_booking_stop.
          ft_vout-ztext = 'Nomor DN tidak ada'.
        ENDIF.
      ELSE.
        CLEAR: i_itab7.
        READ TABLE i_itab7 WITH KEY kunnr = ft_vout-kunnr
                                    zuonr = ft_vout-zuonr.
        IF sy-subrc = 0.
          IF i_itab7-shkzg = 'S'.
            "Update Doc. CN yg Error
            LOOP AT gt_out ASSIGNING <fs_out>
                           WHERE kunnr = ft_vout-kunnr
                             AND zicon = '@B2@'.
              CLEAR: ls_itab1,gt_kna1.
              READ TABLE i_itab1 INTO ls_itab1
                                 WITH KEY kunnr = <fs_out>-kunnr
                                          zuonr = <fs_out>-zuonr.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.
              READ TABLE gt_kna1 WITH KEY kunnr = <fs_out>-kunnr.
              IF sy-subrc NE 0.
                SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                  FROM kna1 WHERE kunnr = <fs_out>-kunnr.
              ENDIF.
              MOVE-CORRESPONDING ls_itab1 TO <fs_out>.
              <fs_out>-name1 = gt_kna1-name1.
              <fs_out>-zicon = icon_booking_ok.
              <fs_out>-chgrow = 'X'.
              CLEAR <fs_out>-ztext.
            ENDLOOP.

            "Prepare Added Records
            CLEAR gt_kna1.
            READ TABLE gt_kna1 WITH KEY kunnr = ft_vout-kunnr.
            IF sy-subrc NE 0.
              SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                FROM kna1 WHERE kunnr = ft_vout-kunnr.
            ENDIF.
            MOVE-CORRESPONDING i_itab1 TO ft_vout.
            ft_vout-name1 = gt_kna1-name1.
            ft_vout-zicon = icon_booking_ok.
            ft_vout-chgrow = 'X'.
            CLEAR ft_vout-ztext.

          ELSEIF i_itab7-shkzg = 'H'.
            READ TABLE gt_out WITH KEY kunnr = ft_vout-kunnr
                                       ztext = space
                                       TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              CLEAR gt_kna1.
              READ TABLE gt_kna1 WITH KEY kunnr = ft_vout-kunnr.
              IF sy-subrc NE 0.
                SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                  FROM kna1 WHERE kunnr = ft_vout-kunnr.
              ENDIF.
              MOVE-CORRESPONDING i_itab1 TO ft_vout.
              ft_vout-name1 = gt_kna1-name1.
              ft_vout-zicon = icon_booking_ok.
              ft_vout-chgrow = 'X'.
              CLEAR ft_vout-ztext.
            ELSE.
              ft_vout-zicon = icon_booking_stop.
              ft_vout-ztext = 'Harap entry DO utk Customer tsb, terlebih dahulu'.
            ENDIF.
          ENDIF.

        ELSE.
          CLEAR: i_itab6.
          READ TABLE i_itab6 WITH KEY kunnr = ft_vout-kunnr
                                      zuonr = ft_vout-zuonr.
          IF i_itab6-shkzg = 'S'.
            "Update Doc. CN yg Error
            LOOP AT gt_out ASSIGNING <fs_out>
                           WHERE kunnr = ft_vout-kunnr
                             AND zicon = '@B2@'.
              CLEAR: ls_itab1,gt_kna1.
              READ TABLE i_itab1 INTO ls_itab1
                                 WITH KEY kunnr = <fs_out>-kunnr
                                          zuonr = <fs_out>-zuonr.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.
              READ TABLE gt_kna1 WITH KEY kunnr = <fs_out>-kunnr.
              IF sy-subrc NE 0.
                SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                  FROM kna1 WHERE kunnr = <fs_out>-kunnr.
              ENDIF.
              MOVE-CORRESPONDING ls_itab1 TO <fs_out>.
              <fs_out>-name1 = gt_kna1-name1.
              <fs_out>-zicon = icon_booking_ok.
              <fs_out>-chgrow = 'X'.
              CLEAR <fs_out>-ztext.
            ENDLOOP.

            "Prepare Added Records
            CLEAR gt_kna1.
            READ TABLE gt_kna1 WITH KEY kunnr = ft_vout-kunnr.
            IF sy-subrc NE 0.
              SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                FROM kna1 WHERE kunnr = ft_vout-kunnr.
            ENDIF.
            MOVE-CORRESPONDING i_itab1 TO ft_vout.
            ft_vout-name1 = gt_kna1-name1.
            ft_vout-zicon = icon_booking_ok.
            ft_vout-chgrow = 'X'.
            CLEAR ft_vout-ztext.

          ELSEIF i_itab6-shkzg = 'H'.
            READ TABLE gt_out WITH KEY kunnr = ft_vout-kunnr
                                       ztext = space
                                       TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              CLEAR gt_kna1.
              READ TABLE gt_kna1 WITH KEY kunnr = ft_vout-kunnr.
              IF sy-subrc NE 0.
                SELECT SINGLE kunnr name1 INTO CORRESPONDING FIELDS OF gt_kna1
                  FROM kna1 WHERE kunnr = ft_vout-kunnr.
              ENDIF.
              MOVE-CORRESPONDING i_itab1 TO ft_vout.
              ft_vout-name1 = gt_kna1-name1.
              ft_vout-zicon = icon_booking_ok.
              ft_vout-chgrow = 'X'.
              CLEAR ft_vout-ztext.
            ELSE.
              ft_vout-zicon = icon_booking_stop.
              ft_vout-ztext = 'Harap entry DO utk Customer tsb, terlebih dahulu'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*ENDIF.

  "Check BI SFA
  IF ft_vout-zicon IS INITIAL.
    SELECT SINGLE * INTO gt_zfbid_sfa
      FROM zfbid_sfa WHERE bukrs     EQ p_vkorg       AND
                           vkbur     EQ p_vkbur       AND
                           zuonr     EQ ft_vout-zuonr AND
                           kunnr     EQ ft_vout-kunnr AND
                           ( bflag EQ space AND pstat = 'F' ).
    IF sy-subrc = 0.
*      APPEND gt_zfbid_sfa.
      ft_vout-zicon = icon_booking_stop.
      CONCATENATE 'DN terikat BI' gt_zfbid_sfa-bbeln
          INTO ft_vout-ztext SEPARATED BY space.
    ENDIF.
  ENDIF.

  "Check Block AR
  IF ft_vout-zicon IS INITIAL.
    SELECT SINGLE * INTO gt_zfh_kr1at
      FROM zfh_kr1at WHERE bukrs     EQ p_vkorg       AND
                           gsber     EQ '0200'        AND
                           vkbur     EQ p_vkbur       AND
                           zuonr     EQ ft_vout-zuonr AND
                           kunnr     EQ ft_vout-kunnr AND
                           belnrpos2 EQ space.
    IF sy-subrc = 0.
      APPEND gt_zfh_kr1at.
      ft_vout-zicon = icon_booking_stop.
      CONCATENATE 'DN terikat FORM3' gt_zfh_kr1at-noform
          INTO ft_vout-ztext SEPARATED BY space.
    ENDIF.
  ENDIF.

  "Check BI lama
  IF ft_vout-zicon IS INITIAL.
    SELECT SINGLE * INTO gt_zfbid
      FROM zfbid WHERE bukrs     EQ p_vkorg       AND
                       vkbur     EQ p_vkbur       AND
                       zuonr     EQ ft_vout-zuonr AND
                       kunnr     EQ ft_vout-kunnr AND
                       ( bflag EQ space AND pstat = 'F' ).
    IF sy-subrc = 0.
*      APPEND gt_zfbid.
      ft_vout-zicon = icon_booking_stop.
      CONCATENATE 'DN terikat BI' gt_zfbid-bbeln
          INTO ft_vout-ztext SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ENTRY_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_data .
  READ TABLE gt_out WITH KEY zicon = icon_booking_stop.
  IF sy-subrc = 0.
    MESSAGE s000(zf) WITH 'Masih ada data salah' DISPLAY LIKE 'E'.
  ELSE.
*    gt_outnew[] = gt_out[].
*    DELETE gt_outnew WHERE newrow IS INITIAL.
*    DELETE gt_outnew WHERE zicon NE icon_booking_ok.

*    gt_outdel[] = gt_out[].
*    DELETE gt_outdel WHERE zicon NE icon_delete.

    CASE 'X'.
      WHEN p_rad1.
        PERFORM f_save_data2.
      WHEN p_rad2.
        PERFORM f_save_data22.
    ENDCASE.
*    PERFORM f_check_header_data.
    PERFORM f_lock_table_check USING 'D'.
    MESSAGE s000(zf) WITH 'DCP sudah dibuatkan BI no.' gv_bbeln.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA2
*&---------------------------------------------------------------------*
FORM f_save_data2 .
  READ TABLE gt_zssutdt025 INDEX 1.
  PERFORM f_write_header_table.
  PERFORM f_write_item_table.
ENDFORM.                    " F_SAVE_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_INIT_HEADER_SCREEN
*&---------------------------------------------------------------------*
FORM f_init_header_screen .
  DATA: lw_tvkot   LIKE tvkot,
        lw_tvkbt   LIKE tvkbt,
*        lv_sdate TYPE sdate,
*        lv_dcp   TYPE num6,
        lv_weekday TYPE week_day,
        lv_date    TYPE char10.

  IF gs_bukrs IS INITIAL.
    CLEAR: gv_sdate,gv_dcp.
    SELECT SINGLE * INTO lw_tvkot FROM tvkot
      WHERE spras = sy-langu
        AND vkorg = p_vkorg.
    SELECT SINGLE * INTO lw_tvkbt FROM tvkbt
      WHERE spras = sy-langu
        AND vkbur = p_vkbur.

    READ TABLE gt_pa0001 INDEX 1.

    IF gv_ready = 'X' OR p_rad2 = 'X'.
      READ TABLE gt_zfbih_sfa INDEX 1.
      gv_sdate = gt_zfbih_sfa-sdate.
      gv_dcp   = gt_zfbih_sfa-daily_call_num.
    ELSE.
      READ TABLE gt_zssutdt025 INDEX 1.
      gv_sdate = gt_zssutdt025-sdate.
      gv_dcp   = gt_zssutdt025-daily_call_num.
    ENDIF.

    WRITE gv_sdate TO lv_date.
    CALL FUNCTION 'ZDATE_TO_DAY'
      EXPORTING
        date    = gv_sdate
      IMPORTING
        weekday = lv_weekday.

    CONCATENATE p_vkorg lw_tvkot-vtext INTO gs_bukrs SEPARATED BY ' - '.
    CONCATENATE p_vkbur lw_tvkbt-bezei INTO gs_vkbur SEPARATED BY ' - '.
    CONCATENATE s_pernr1-low gt_pa0001-sname INTO gs_pernr SEPARATED BY ' - '.
    CONCATENATE lv_weekday lv_date INTO gs_date SEPARATED BY ' / '.

    IF p_inkas2 IS NOT INITIAL.
      CLEAR gv_dcp.
    ENDIF.
    gs_dcp = gv_dcp.
  ENDIF.
ENDFORM.                    " F_INIT_HEADER_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER_TABLE
*&---------------------------------------------------------------------*
FORM f_write_header_table .
  DATA : lv_nrrangenr     TYPE inrdp-nrrangenr.

  CLEAR: va_bbeln.

  IF p_inkas1 IS INITIAL.
    lv_nrrangenr = '01'.
  ELSE.
    lv_nrrangenr = '02'.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = lv_nrrangenr
      object                  = 'ZBBELN_SFA'
      subobject               = p_vkbur
*     toyear                  = sy-datum(4)
    IMPORTING
      number                  = va_bbeln
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

*  SELECT  MAX( bbeln ) INTO va_bbeln FROM zfbih_sfa
*    WHERE bukrs EQ p_vkorg
*      AND vkbur EQ p_vkbur.
*
*  IF sy-subrc EQ 0.
*    IF va_bbeln IS INITIAL.
*      IF p_inkas1 IS INITIAL.
*        va_bbeln = '9000001'.
*      ELSE.
*        va_bbeln = '1000001'.
*      ENDIF.
*    ELSE.
*      ADD 1 TO va_bbeln.
*    ENDIF.
*  ELSE.
*    IF p_inkas1 IS INITIAL.
*      va_bbeln = '9000001'.
*    ELSE.
*      va_bbeln = '1000001'.
*    ENDIF.
*  ENDIF.

  READ TABLE gr_pernr INDEX 1.

  MOVE: p_vkorg  TO zfbih_sfa-bukrs,
        p_vkbur  TO zfbih_sfa-vkbur,
        va_bbeln TO zfbih_sfa-bbeln,
        gr_pernr-low  TO zfbih_sfa-parnr,
        'IDR'    TO zfbih_sfa-waers,
        sy-uname TO zfbih_sfa-usna1,
        sy-uzeit TO zfbih_sfa-erzet,
        sy-datum TO zfbih_sfa-erdt1.

  IF p_inkas1 IS INITIAL.
    MOVE: gt_zssutdt025-daily_call_num TO zfbih_sfa-daily_call_num,
          gt_zssutdt025-sdate TO zfbih_sfa-sdate,
          gt_zssutdt025-sdate TO zfbih_sfa-bidat.
  ELSE.
    MOVE: sy-datum TO zfbih_sfa-bidat,
          sy-datum TO zfbih_sfa-sdate.
  ENDIF.

  MODIFY zfbih_sfa.

  IF sy-subrc = 0.
*    gv_ready = 'X'.
    gv_bbeln = zfbih_sfa-bbeln.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ITEM_TABLE
*&---------------------------------------------------------------------*
FORM f_write_item_table .
  DATA: lt_zfbid_sfa TYPE TABLE OF zfbid_sfa,
        lv_ebelp     LIKE zfbid_sfa-ebelp,
        lv_zbd1t     LIKE bsid-zbd1t,
        lv_shkzg     LIKE bsid-shkzg,
        lt_vbpa      TYPE STANDARD TABLE OF vbpa,
        ls_vbpa      TYPE vbpa,
        lt_xout      LIKE gt_out OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS <fs_zfbid_sfa> LIKE zfbid_sfa.

  IF p_inkas1 IS NOT INITIAL.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE chbox IS INITIAL.
    IF lt_xout[] IS NOT INITIAL.
      SELECT *
        FROM vbpa
        INTO CORRESPONDING FIELDS OF TABLE lt_vbpa
        FOR ALL ENTRIES IN lt_xout
        WHERE vbeln EQ lt_xout-belnr.
    ENDIF.
  ENDIF.

  SORT i_itab1 BY kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.
    READ TABLE gt_out WITH KEY kunnr = wa_itab1-kunnr
                               zuonr = wa_itab1-zuonr
                               chbox = 'X'.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    IF sy-subrc = 0 AND gt_out-zicon = icon_delete.
      CONTINUE.
    ENDIF.

    CLEAR s_pernr1.
    READ TABLE s_pernr1 INDEX 1.

    ADD 10 TO lv_ebelp.
    APPEND INITIAL LINE TO lt_zfbid_sfa ASSIGNING <fs_zfbid_sfa>.
    MOVE wa_itab1-bukrs TO <fs_zfbid_sfa>-bukrs.
    MOVE wa_itab1-vkbur TO <fs_zfbid_sfa>-vkbur.
    MOVE wa_itab1-gjahr TO <fs_zfbid_sfa>-gjahr.
    MOVE va_bbeln       TO <fs_zfbid_sfa>-bbeln.
    MOVE lv_ebelp       TO <fs_zfbid_sfa>-ebelp.
    MOVE wa_itab1-belnr TO <fs_zfbid_sfa>-vbeln.
    MOVE wa_itab1-gsber TO <fs_zfbid_sfa>-gsber.
    MOVE wa_itab1-zuonr TO <fs_zfbid_sfa>-zuonr.
    MOVE wa_itab1-buzei TO <fs_zfbid_sfa>-buzei.
    MOVE wa_itab1-budat TO <fs_zfbid_sfa>-fkdat.
    MOVE wa_itab1-kunnr TO <fs_zfbid_sfa>-kunnr.
    MOVE wa_itab1-parvw TO <fs_zfbid_sfa>-parvw.
*    MOVE gs_pernr(8)    TO <fs_zfbid_sfa>-slcod.
    MOVE s_pernr1-low   TO <fs_zfbid_sfa>-slcod.

    MOVE wa_itab1-bldat TO <fs_zfbid_sfa>-bldat.
    MOVE wa_itab1-blart TO <fs_zfbid_sfa>-blart.
    MOVE wa_itab1-belnr TO <fs_zfbid_sfa>-belnr.
    MOVE wa_itab1-zfbdt TO <fs_zfbid_sfa>-zfbdt.
    MOVE wa_itab1-pstat TO <fs_zfbid_sfa>-pstat.
    MOVE sy-datum       TO <fs_zfbid_sfa>-erdt2.
    <fs_zfbid_sfa>-wrbtr = wa_itab1-wrbtr / 100.

    CLEAR: lv_zbd1t.
    SELECT SINGLE zbd1t shkzg xref1 xref3
      INTO (lv_zbd1t, lv_shkzg, <fs_zfbid_sfa>-parvw, <fs_zfbid_sfa>-xref3)
      FROM bsid WHERE bukrs = <fs_zfbid_sfa>-bukrs
                  AND kunnr = <fs_zfbid_sfa>-kunnr
                  AND zuonr = <fs_zfbid_sfa>-zuonr(10)
                  AND blart = 'RV'.
    IF sy-subrc = 0.
*      <fs_zfbid_sfa>-dudat = <fs_zfbid_sfa>-zfbdt + lv_zbd1t.
      PERFORM f_calculate_duedt USING lv_zbd1t <fs_zfbid_sfa>-zfbdt lv_shkzg
                                CHANGING <fs_zfbid_sfa>-dudat.
    ELSE.
      SELECT SINGLE zbd1t shkzg xref1 xref3
        INTO (lv_zbd1t, lv_shkzg, <fs_zfbid_sfa>-parvw, <fs_zfbid_sfa>-xref3)
        FROM bsad WHERE bukrs = <fs_zfbid_sfa>-bukrs
                    AND kunnr = <fs_zfbid_sfa>-kunnr
                    AND zuonr = <fs_zfbid_sfa>-zuonr(10)
                    AND blart = 'RV'.
      IF sy-subrc = 0.
*        <fs_zfbid_sfa>-dudat = <fs_zfbid_sfa>-zfbdt + lv_zbd1t.
        PERFORM f_calculate_duedt USING lv_zbd1t <fs_zfbid_sfa>-zfbdt lv_shkzg
                                  CHANGING <fs_zfbid_sfa>-dudat.
      ENDIF.
    ENDIF.

    IF p_inkas1 IS NOT INITIAL.
      LOOP AT lt_vbpa INTO ls_vbpa WHERE vbeln = wa_itab1-belnr.
        CASE ls_vbpa-parvw.
          WHEN 'VE'.
            MOVE ls_vbpa-pernr TO <fs_zfbid_sfa>-slcod.
          WHEN 'ZC'.
            MOVE ls_vbpa-kunnr TO <fs_zfbid_sfa>-parvw.
          WHEN 'ZS'.
            MOVE ls_vbpa-kunnr TO <fs_zfbid_sfa>-xref3.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF lt_zfbid_sfa[] IS NOT INITIAL.
    MODIFY zfbid_sfa FROM TABLE lt_zfbid_sfa.
    IF sy-subrc = 0.
      PERFORM f_payment_block TABLES lt_zfbid_sfa
                              USING 'B'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_WRITE_ITEM_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RAD1
*&---------------------------------------------------------------------*
FORM f_get_data_rad1 .
  SELECT * INTO TABLE gt_zssutdt025
    FROM zssutdt025 WHERE vkorg = p_vkorg
                      AND vkbur = p_vkbur
                      AND pernr IN gr_pernr
                      AND sdate IN gr_sdate
                      AND daily_call_num IN gr_dcp
                      AND zrelease = 'X'
                      AND zprint = 'X'.
  IF sy-subrc EQ 0.
    SELECT * INTO TABLE gt_zssutdt026
      FROM zssutdt026 FOR ALL ENTRIES IN gt_zssutdt025
      WHERE vkbur = gt_zssutdt025-vkbur
        AND daily_call_num = gt_zssutdt025-daily_call_num
        AND umjah = gt_zssutdt025-umjah.

    SELECT pernr ansvh sname ename
      INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
      FROM pa0001 FOR ALL ENTRIES IN gt_zssutdt025
      WHERE pernr = gt_zssutdt025-pernr.

    IF sy-subrc = 0.
      SELECT * INTO TABLE gt_channel
        FROM zfsfa_channel FOR ALL ENTRIES IN gt_pa0001
        WHERE ansvh = gt_pa0001-ansvh.

      IF sy-subrc = 0.
        SELECT * INTO TABLE gt_jh
          FROM zfsfa_jh FOR ALL ENTRIES IN gt_channel
          WHERE bukrs = p_vkorg
            AND vkbur = p_vkbur
            AND zchannel = gt_channel-zchannel.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.

  IF p_inkas1 IS INITIAL.
    IF gt_zssutdt026[] IS NOT INITIAL.
      SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
             a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
             a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
             d~pernr a~xref1 a~xref2 a~xref3 a~vbund a~blart a~umskz
          INTO CORRESPONDING FIELDS OF TABLE i_itab7
          FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
               JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                 d~bukrs EQ a~bukrs
          FOR ALL ENTRIES IN gt_zssutdt026
          WHERE a~bukrs EQ p_vkorg AND
*              a~belnr IN so_belnr AND
                a~zlspr IN (space,'Z','B')    AND
                a~blart IN ('DA', 'RV','DR','DG', 'ZA')   AND
                a~umskz EQ space AND
                a~kunnr EQ gt_zssutdt026-kunnr AND
                b~vkbur EQ p_vkbur AND
                b~vkorg EQ p_vkorg AND
                b~vtweg EQ '10'.
*              d~pernr IN so_parnr
*              ORDER BY a~zuonr.

      SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
             a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
             a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
             d~pernr a~xref1 a~xref2 a~xref3 a~vbund a~blart a~umskz
          APPENDING CORRESPONDING FIELDS OF TABLE i_itab7
          FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
               JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                 d~bukrs EQ a~bukrs
          FOR ALL ENTRIES IN gt_zssutdt026
          WHERE a~bukrs EQ p_vkorg AND
*              a~belnr IN so_belnr AND
                a~zlspr IN (space,'Z','B') AND
                a~blart EQ 'DA'            AND
                a~umskz NE space AND
                a~kunnr EQ gt_zssutdt026-kunnr AND
                b~vkbur EQ p_vkbur AND
                b~vkorg EQ p_vkorg AND
                b~vtweg EQ '10'.
*              d~pernr IN so_parnr
*              ORDER BY a~zuonr.

      SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
             a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
             a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
             d~pernr a~xref1 a~xref2 a~vbund a~blart a~umskz
        INTO CORRESPONDING FIELDS OF TABLE i_itab6
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                       JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                         d~bukrs EQ a~bukrs
        FOR ALL ENTRIES IN gt_zssutdt026
        WHERE a~bukrs EQ p_vkorg AND
*            a~belnr IN so_belnr AND
              a~zlspr IN (space,'Z')    AND
              a~blart EQ 'DZ'     AND
              a~umskz EQ space AND
              a~kunnr EQ gt_zssutdt026-kunnr AND
              b~vkbur EQ p_vkbur AND
              b~vkorg EQ p_vkorg AND
              b~vtweg EQ '10'.
*            d~pernr IN so_parnr
*            ORDER BY a~zuonr.

      DELETE i_itab6 WHERE blart = 'DA' AND umskz = 'V'.
      DELETE i_itab7 WHERE blart = 'DA' AND umskz = 'V'.
    ENDIF.
  ELSE.
    PERFORM f_bi_inkaso.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RAD1

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RAD1_A
*&---------------------------------------------------------------------*
FORM f_get_data_rad1_a .
  SELECT pernr ansvh sname ename
    INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
    FROM pa0001 WHERE pernr = s_pernr1-low.

  IF sy-subrc = 0.
    SELECT * INTO TABLE gt_channel
      FROM zfsfa_channel FOR ALL ENTRIES IN gt_pa0001
      WHERE ansvh = gt_pa0001-ansvh.

    IF sy-subrc = 0.
      SELECT * INTO TABLE gt_jh
        FROM zfsfa_jh FOR ALL ENTRIES IN gt_channel
        WHERE bukrs = p_vkorg
          AND vkbur = p_vkbur
          AND zchannel = gt_channel-zchannel.
    ENDIF.
  ENDIF.

  IF gt_knvp2[] IS NOT INITIAL.
    SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
           a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
           a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
           d~pernr a~xref1 a~xref2 a~xref3 a~vbund a~blart a~umskz
        INTO CORRESPONDING FIELDS OF TABLE i_itab7
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                       JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                    d~bukrs EQ a~bukrs
        FOR ALL ENTRIES IN gt_knvp2
        WHERE a~bukrs EQ p_vkorg AND
*              a~belnr IN so_belnr AND
              a~zlspr IN (space,'Z','B')    AND
              a~blart IN ('DA', 'RV','DR','DG', 'ZA')   AND
              a~umskz EQ space AND
              a~kunnr EQ gt_knvp2-kunnr AND
              b~vkbur EQ p_vkbur AND
              b~vkorg EQ p_vkorg AND
              b~vtweg EQ '10'.
*              d~pernr IN so_parnr
*              ORDER BY a~zuonr.

    SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
                a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
                a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
                d~pernr a~xref1 a~xref2 a~vbund a~blart a~umskz
             INTO CORRESPONDING FIELDS OF TABLE i_itab6
             FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                  JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                    d~bukrs EQ a~bukrs
             FOR ALL ENTRIES IN gt_knvp2
             WHERE a~bukrs EQ p_vkorg AND
*                   a~belnr IN so_belnr AND
                   a~zlspr IN (space,'Z')    AND
                   a~blart EQ 'DZ'     AND
                   a~umskz EQ space AND
                   a~kunnr EQ gt_knvp2-kunnr AND
                   b~vkbur EQ p_vkbur AND
                   b~vkorg EQ p_vkorg AND
                   b~vtweg EQ '10'.
*                   d~pernr IN so_parnr
*                   ORDER BY a~zuonr.

    SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
                a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
                a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
                d~pernr a~xref1 a~xref2 a~vbund a~blart a~umskz
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab6
             FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                  JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                    d~bukrs EQ a~bukrs
             FOR ALL ENTRIES IN gt_knvp2
             WHERE a~bukrs EQ p_vkorg AND
*                   a~belnr IN so_belnr AND
                   a~zlspr NE space    AND
                   a~blart EQ 'DZ'     AND
                   a~umskz NE space AND
                   a~kunnr EQ gt_knvp2-kunnr AND
                   b~vkbur EQ p_vkbur AND
                   b~vkorg EQ p_vkorg AND
                   b~vtweg EQ '10'.
*                   d~pernr IN so_parnr
*                   ORDER BY a~zuonr.

    DELETE i_itab6 WHERE blart = 'DA' AND umskz = 'V'.
    DELETE i_itab7 WHERE blart = 'DA' AND umskz = 'V'.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RAD1_A

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RAD2
*&---------------------------------------------------------------------*
FORM f_get_data_rad2 .
  SELECT * INTO TABLE gt_zfbih_sfa
    FROM zfbih_sfa WHERE bukrs = p_vkorg
                     AND vkbur = p_vkbur
                     AND bbeln IN gr_bbeln
                     AND parnr IN gr_pernr
                     AND sdate IN gr_sdate
                     AND daily_call_num IN gr_dcp
                     AND usnam_rel = space.
  IF sy-subrc EQ 0.
    SELECT * INTO TABLE gt_zfbid_sfa
      FROM zfbid_sfa FOR ALL ENTRIES IN gt_zfbih_sfa
      WHERE bukrs = p_vkorg
        AND vkbur = p_vkbur
        AND bbeln = gt_zfbih_sfa-bbeln.

    IF gt_pa0001[] IS INITIAL.
      SELECT pernr ansvh sname ename
        INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
        FROM pa0001 FOR ALL ENTRIES IN gt_zfbih_sfa
        WHERE pernr = gt_zfbih_sfa-parnr+2(8).
    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RAD2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_RAD1
*&---------------------------------------------------------------------*
FORM f_process_data_rad1 .
  DATA: lv_zbd1t LIKE bsid-zbd1t,
        l_kunde  LIKE vbpa-kunnr,
        nilai    LIKE bsid-wrbtr,
        nilai2   LIKE bsid-wrbtr,
        lr_kunnr TYPE RANGE OF kunnr WITH HEADER LINE.

  SORT i_itab6 BY kunnr zuonr.
  LOOP AT i_itab6.
    MOVE-CORRESPONDING i_itab6 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab3.
    IF i_itab6-shkzg = 'H'.
      i_itab6-wrbtr = i_itab6-wrbtr * -1.
    ENDIF.
    MODIFY i_itab6.
    IF wa_itab1-kunnr EQ i_itab6-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab3-shkzg = 'S'.
        i_itab3-wrbtr = i_itab6-wrbtr.
        APPEND i_itab3.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab7 BY kunnr zuonr.
  LOOP AT i_itab7.
    MOVE-CORRESPONDING i_itab7 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab1.
    IF i_itab7-shkzg = 'H'.
      i_itab7-wrbtr = i_itab7-wrbtr * -1.
    ENDIF.
    lv_zbd1t = i_itab7-zbd1t.
    i_itab7-zbd1t = 0.
    MODIFY i_itab7.
    IF wa_itab1-kunnr EQ i_itab7-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab1-shkzg = 'S'.
        i_itab1-wrbtr = i_itab7-wrbtr.
        i_itab1-zbd1t = lv_zbd1t.
        APPEND i_itab1.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab1 BY kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-zlspr NE 'B'.  "or flag eq 'X'.

*      wa_itab1-zfbdt = wa_itab1-zfbdt + wa_itab1-zbd1t.
      wa_itab1-wrbtr = wa_itab1-wrbtr * 100.
      wa_itab1-zuonr1 = wa_itab1-zuonr.
***untuk CN
      IF wa_itab1-shkzg EQ 'H'.
        wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
      ENDIF.
***
      nilai = 0.
*            IF VAL IS INITIAL.
      LOOP AT i_itab3 INTO wa_itab3 WHERE kunnr = wa_itab1-kunnr
                                      AND zuonr = wa_itab1-zuonr.
        wa_itab3-wrbtr = wa_itab3-wrbtr * 100.
        nilai = nilai + wa_itab3-wrbtr.
        CLEAR wa_itab3.
        DELETE i_itab3.
*          wa_itab1-pstat = 'P'.
        wa_itab1-pstat = 'F'.
      ENDLOOP.

      wa_itab1-wrbtr = wa_itab1-wrbtr + nilai.

      SELECT SUM( cchek ) INTO nilai FROM zfbicheck
        WHERE bukrs EQ wa_itab1-bukrs
          AND vkbur EQ wa_itab1-vkbur
          AND gjahr EQ wa_itab1-gjahr
          AND zuonr EQ wa_itab1-zuonr
          AND pcair EQ space.
      IF sy-subrc EQ 0.
        wa_itab1-wrbtr = wa_itab1-wrbtr - nilai * 100.
      ENDIF.

      SELECT SUM( bank_amt ) INTO nilai2 FROM zfbic_sfa
        WHERE bukrs EQ wa_itab1-bukrs
          AND vkbur EQ wa_itab1-vkbur
*          AND tahun EQ wa_itab1-gjahr
          AND zuonr EQ wa_itab1-zuonr
          AND pcair EQ space.
      IF sy-subrc EQ 0.
        wa_itab1-wrbtr = wa_itab1-wrbtr - nilai2 * 100.
      ENDIF.

      IF wa_itab1-pstat <> 'F'.
        wa_itab1-pstat = 'F'.
      ENDIF.

      MODIFY i_itab1 FROM wa_itab1.
    ENDIF.
    IF wa_itab1-zlspr EQ 'B'.
      LOOP AT i_itab3 INTO wa_itab3 WHERE zuonr = wa_itab1-zuonr.
        DELETE i_itab3.
      ENDLOOP.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  LOOP AT i_itab3 INTO wa_itab1.
    wa_itab1-wrbtr = wa_itab1-wrbtr * 100.

    IF wa_itab1-shkzg = 'H'.
      wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
    ENDIF.

    i_itab1-bukrs = wa_itab1-bukrs.
    MOVE wa_itab1-vkbur TO i_itab1-vkbur.
    MOVE wa_itab1-gjahr TO i_itab1-gjahr.
    MOVE wa_itab1-ebelp TO i_itab1-ebelp.
    MOVE wa_itab1-belnr TO i_itab1-belnr.
    MOVE wa_itab1-gsber TO i_itab1-gsber.
    MOVE wa_itab1-zuonr TO i_itab1-zuonr.
    MOVE wa_itab1-buzei TO i_itab1-buzei.
    MOVE wa_itab1-budat TO i_itab1-budat.
    MOVE wa_itab1-kunnr TO i_itab1-kunnr.
    MOVE wa_itab1-zfbdt TO i_itab1-zfbdt.
    MOVE wa_itab1-wrbtr TO i_itab1-wrbtr.
    MOVE wa_itab1-zuonr TO i_itab1-zuonr1.
    MOVE wa_itab1-vbund TO i_itab1-vbund.
    MOVE wa_itab1-zlspr TO i_itab1-zlspr.
    i_itab1-pstat = 'F'.

    APPEND  i_itab1.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab1 BY kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.

    IF wa_itab1-wrbtr EQ 0 OR wa_itab1-zlspr EQ 'B'.
      "Delete main itab
      DELETE i_itab1.

      IF wa_itab1-zlspr EQ 'B'.
        "Save to itab terikat BI
        APPEND wa_itab1 TO i_itab1b.
      ENDIF.

    ELSE.

      "Check Block AR
      SELECT SINGLE * INTO gt_zfh_kr1at
        FROM zfh_kr1at WHERE bukrs     EQ p_vkorg       AND
                             gsber     EQ '0200'        AND
                             vkbur     EQ p_vkbur       AND
                             zuonr     EQ wa_itab1-zuonr AND
                             kunnr     EQ wa_itab1-kunnr AND
                             belnrpos2 EQ space.
      IF sy-subrc = 0.
        "Delete main itab
        DELETE i_itab1.

        "Save to itab terikat Blok AR
        APPEND gt_zfh_kr1at.
      ELSE.

        IF wa_itab1-xref1 NE space.
          wa_itab1-parvw = wa_itab1-xref1.
        ELSE.

          SELECT SINGLE kunnr INTO l_kunde FROM vbpa
            WHERE vbeln EQ wa_itab1-belnr
              AND parvw EQ 'ZC'.
          IF l_kunde IS NOT INITIAL.
            wa_itab1-parvw = l_kunde.
          ELSE.

            CLEAR i_itab6.
            READ TABLE i_itab6 WITH KEY kunnr = wa_itab1-kunnr
                                        belnr = wa_itab1-belnr.
            wa_itab1-parvw = i_itab6-xref1.
          ENDIF.
        ENDIF.
        MODIFY i_itab1 FROM wa_itab1 TRANSPORTING parvw.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF i_itab1[] IS NOT INITIAL.
    SELECT kunnr name1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 FOR ALL ENTRIES IN i_itab1
      WHERE kunnr EQ i_itab1-kunnr.

    IF p_rad1 = 'X'.

      PERFORM f_get_kr1a.
      PERFORM f_get_data_detail.

      SORT i_itab1 BY kunnr zuonr.
      SORT gt_kna1 BY kunnr.

      LOOP AT i_itab1.

        READ TABLE gt_zfbid_sfa2 WITH KEY zuonr = i_itab1-zuonr
                                          kunnr = i_itab1-kunnr.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        CLEAR: gt_kna1,gt_zfbid_sfa3.
        READ TABLE gt_kna1 WITH KEY kunnr = i_itab1-kunnr BINARY SEARCH.
        READ TABLE gt_zfbid_sfa3 WITH KEY zuonr = i_itab1-zuonr
                                          kunnr = i_itab1-kunnr.

        APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
        MOVE-CORRESPONDING i_itab1 TO <fs_out>.
        <fs_out>-name1  = gt_kna1-name1.
        <fs_out>-nottf  = gt_zfbid_sfa3-nottf.
        <fs_out>-tglttf = gt_zfbid_sfa3-tglttf.

        READ TABLE gt_zfh_kr1at WITH KEY kunnr = <fs_out>-kunnr
                                         zuonr = <fs_out>-zuonr.
        IF sy-subrc = 0.
          <fs_out>-zicon = icon_delete.   "icon_booking_stop.
          CONCATENATE 'DN terikat FORM3' gt_zfh_kr1at-noform
            INTO <fs_out>-ztext SEPARATED BY space.
        ENDIF.

        PERFORM f_modify_dudat USING i_itab1-bukrs
                                     i_itab1-kunnr
                                     i_itab1-zuonr
                                     i_itab1-zfbdt
                                     'RV'
                               CHANGING <fs_out>-dudat.

        READ TABLE gt_zfbid WITH KEY kunnr = <fs_out>-kunnr
                                     zuonr = <fs_out>-zuonr.
        IF sy-subrc = 0.
          IF <fs_out>-zicon IS INITIAL.
            <fs_out>-zicon = icon_delete.   "icon_booking_stop.
            CONCATENATE 'DN terikat BI' gt_zfbid-bbeln
              INTO <fs_out>-ztext SEPARATED BY space.
          ELSE.
            CONCATENATE <fs_out>-ztext '& BI' gt_zfbid-bbeln
              INTO <fs_out>-ztext SEPARATED BY space.
          ENDIF.

          "Save to itab tmp
          i_itab1-bbeln = gt_zfbid-bbeln.
          APPEND i_itab1 TO i_itab1b.
        ENDIF.

        "Save Customer SHKZG = 'S'
        IF <fs_out>-zicon IS INITIAL.
          CLEAR: i_itab7,i_itab3.
          READ TABLE i_itab7 WITH KEY kunnr = i_itab1-kunnr
                                      zuonr = i_itab1-zuonr.
          IF sy-subrc = 0.
            IF i_itab7-shkzg = 'S'.
              lr_kunnr-sign = 'I'.
              lr_kunnr-option = 'EQ'.
              lr_kunnr-low = i_itab1-kunnr.
              COLLECT lr_kunnr. CLEAR lr_kunnr.
            ENDIF.
          ELSE.
*            READ TABLE i_itab3 WITH KEY kunnr = i_itab1-kunnr
*                                        zuonr = i_itab1-zuonr.
*            IF sy-subrc = 0.
*              lr_kunnr-sign = 'I'.
*              lr_kunnr-option = 'EQ'.
*              lr_kunnr-low = i_itab1-kunnr.
*              COLLECT lr_kunnr. CLEAR lr_kunnr.
*            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT gt_out ASSIGNING <fs_out>.
        IF <fs_out>-kunnr IN lr_kunnr.
          CLEAR nilai.
          LOOP AT i_itab6 WHERE kunnr = <fs_out>-kunnr
                            AND zuonr = <fs_out>-zuonr.
            IF i_itab6-blart = 'DZ'.
              IF i_itab6-shkzg = 'H'.
                ADD i_itab6-wrbtr TO nilai.
              ENDIF.
            ENDIF.
          ENDLOOP.

          nilai = <fs_out>-wrbtr + nilai.
          IF nilai = 0.
            <fs_out>-zicon = icon_delete.
          ENDIF.

*          READ TABLE i_itab6 WITH KEY kunnr = <fs_out>-kunnr
*                                      zuonr = <fs_out>-zuonr.
*          IF sy-subrc = 0.
*            IF i_itab6-blart = 'DZ'.
*              IF i_itab6-shkzg = 'H'.
*                <fs_out>-zicon = icon_delete.
*              ENDIF.
*            ENDIF.
*          ENDIF.
        ELSE.
          <fs_out>-zicon = icon_delete.
        ENDIF.
      ENDLOOP.

      DELETE gt_out WHERE zicon = '@11@'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_RAD1

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_RAD2
*&---------------------------------------------------------------------*
FORM f_process_data_rad2 .
  IF gt_zfbid_sfa[] IS NOT INITIAL.
    CLEAR: gt_kna1,gt_kna1[].
    SELECT kunnr name1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 FOR ALL ENTRIES IN gt_zfbid_sfa
      WHERE kunnr EQ gt_zfbid_sfa-kunnr.

    SORT gt_zfbid_sfa BY kunnr.
    SORT gt_kna1 BY kunnr.
    LOOP AT gt_zfbid_sfa.
      CLEAR gt_kna1.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_zfbid_sfa-kunnr BINARY SEARCH.

      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      MOVE-CORRESPONDING gt_zfbid_sfa TO <fs_out>.
      <fs_out>-name1 = gt_kna1-name1.
      IF gt_zfbid_sfa-zdele = 'X'.
        <fs_out>-zicon = icon_delete.
      ENDIF.
      IF p_rad2 = abap_true.
        MULTIPLY <fs_out>-wrbtr BY 100.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_RAD2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_RAD3
*&---------------------------------------------------------------------*
FORM f_process_data_rad3 .
  DATA: BEGIN OF lt_cntout OCCURS 0,
          kunnr TYPE kunnr,
        END OF lt_cntout.

  DATA: BEGIN OF lt_cntdn OCCURS 0,
          zuonr TYPE zuonr,
        END OF lt_cntdn.

  DATA: lv_wrbtr TYPE wrbtr.

  IF gt_zfbid_sfa[] IS NOT INITIAL.
    SELECT pernr ansvh sname ename
      INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
      FROM pa0001 FOR ALL ENTRIES IN gt_zfbih_sfa
      WHERE pernr = gt_zfbih_sfa-parnr(8).

    SORT gt_zfbih_sfa BY bbeln.
    SORT gt_zfbid_sfa BY bbeln.

    LOOP AT gt_zfbih_sfa.

      CLEAR gt_pa0001.
      READ TABLE gt_pa0001 WITH KEY pernr = gt_zfbih_sfa-parnr BINARY SEARCH.

      CLEAR: lv_wrbtr,lt_cntout[],lt_cntdn[].
      APPEND INITIAL LINE TO gt_out2 ASSIGNING <fs_out2>.

      LOOP AT gt_zfbid_sfa WHERE bbeln = gt_zfbih_sfa-bbeln
                             AND zdele IS INITIAL.
        lt_cntout-kunnr = gt_zfbid_sfa-kunnr.
        COLLECT lt_cntout.
        lt_cntdn-zuonr = gt_zfbid_sfa-zuonr.
        COLLECT lt_cntdn.
        ADD gt_zfbid_sfa-wrbtr TO lv_wrbtr.
      ENDLOOP.

      <fs_out2>-bbeln = gt_zfbih_sfa-bbeln.
      <fs_out2>-dcp   = gt_zfbih_sfa-daily_call_num.
      <fs_out2>-sdate = gt_zfbih_sfa-sdate.
      <fs_out2>-parnr = gt_zfbih_sfa-parnr.
      <fs_out2>-sname = gt_pa0001-sname.
      DESCRIBE TABLE lt_cntout LINES <fs_out2>-cnt_out.
      DESCRIBE TABLE lt_cntdn LINES <fs_out2>-cnt_dn.
      <fs_out2>-amount = lv_wrbtr.
      <fs_out2>-filenm_dwn = gt_zfbih_sfa-filenm_dwn.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_RAD3

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RAD3
*&---------------------------------------------------------------------*
FORM f_get_data_rad3 .
  SELECT * INTO TABLE gt_zfbih_sfa
    FROM zfbih_sfa WHERE bukrs = p_vkorg
                     AND vkbur = p_vkbur
                     AND bbeln IN gr_bbeln
                     AND parnr IN gr_pernr
                     AND sdate IN gr_sdate
                     AND daily_call_num IN gr_dcp
                     AND usnam_rel NE space.
  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN p_rad4 OR p_rad5.
        PERFORM f_remove_download_item.
      WHEN p_rad6.
        PERFORM f_remove_redownload_item.
        PERFORM f_remove_payment_item.
      WHEN OTHERS.
    ENDCASE.

    IF gt_zfbih_sfa[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_zfbid_sfa
        FROM zfbid_sfa FOR ALL ENTRIES IN gt_zfbih_sfa
        WHERE bukrs = p_vkorg
          AND vkbur = p_vkbur
          AND bbeln = gt_zfbih_sfa-bbeln.
    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RAD3

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_HEADER_DATA
*&---------------------------------------------------------------------*
FORM f_check_header_data .
  IF gv_ready = 'X'.
    MESSAGE s000(zf) WITH 'DCP sudah dibuatkan BI no.' gv_bbeln.
  ENDIF.
ENDFORM.                    " F_CHECK_HEADER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA22
*&---------------------------------------------------------------------*
FORM f_save_data22 .
  PERFORM f_modify_header_table.
  IF p_inkas2 IS INITIAL.
    PERFORM f_modify_item_table.
  ELSE.
    gv_bbeln = s_bbeln1-low.
    PERFORM f_modify_item_table_inkaso.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA22

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_HEADER_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_header_table .
  IF gt_zfbih_sfa[] IS NOT INITIAL.
    gt_zfbih_sfa-usna2 = sy-uname.
    gt_zfbih_sfa-erdt2 = sy-datum.
    gt_zfbih_sfa-erzet2 = sy-uzeit.
    MODIFY gt_zfbih_sfa TRANSPORTING usna2 erdt2 erzet2
                        WHERE usna2 NE sy-uname
                           OR erdt2 NE sy-datum
                           OR erzet2 NE sy-uzeit.
    MODIFY zfbih_sfa FROM TABLE gt_zfbih_sfa.
  ENDIF.
ENDFORM.                    " F_MODIFY_HEADER_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITEM_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_item_table .
  DATA: lt_zfbid_sfa TYPE TABLE OF zfbid_sfa WITH HEADER LINE,
        lv_ebelp     LIKE zfbid_sfa-ebelp,
        lv_bbeln     TYPE zbbeln_sfa,
        lv_zbd1t     LIKE bsid-zbd1t.

  FIELD-SYMBOLS <fs_zfbid_sfa> LIKE zfbid_sfa.

  SORT gt_zfbid_sfa BY bukrs vkbur bbeln ebelp DESCENDING.
  READ TABLE gt_zfbid_sfa INDEX 1.
  IF sy-subrc = 0.
    lv_ebelp = gt_zfbid_sfa-ebelp.
    lv_bbeln = gt_zfbid_sfa-bbeln.
  ELSE.
    lv_ebelp = '00000'.
    lv_bbeln = gv_bbeln.
  ENDIF.

  SORT gt_out  BY kunnr zuonr.
  SORT i_itab1 BY kunnr zuonr.
  SORT gt_zfbid_sfa BY kunnr zuonr.

  LOOP AT gt_out WHERE chgrow = 'X'.
    READ TABLE gt_zfbid_sfa WITH KEY kunnr = gt_out-kunnr
                                     zuonr = gt_out-zuonr
                                     bbeln = lv_bbeln.
    IF sy-subrc = 0.
      APPEND INITIAL LINE TO lt_zfbid_sfa ASSIGNING <fs_zfbid_sfa>.
      MOVE-CORRESPONDING gt_zfbid_sfa TO <fs_zfbid_sfa>.
      IF gt_out-zicon = icon_delete AND
         gt_zfbid_sfa-zdele = ' '.
        <fs_zfbid_sfa>-bflag = 'D'.
        <fs_zfbid_sfa>-zdele = 'X'.
      ELSE.
        <fs_zfbid_sfa>-bflag = <fs_zfbid_sfa>-zdele = ' '.
      ENDIF.

    ELSE.
      IF gt_out-zicon = icon_delete.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lt_zfbid_sfa ASSIGNING <fs_zfbid_sfa>.

      CLEAR wa_itab1.
      READ TABLE i_itab1 INTO wa_itab1 WITH KEY kunnr = gt_out-kunnr
                                                zuonr = gt_out-zuonr.

      CLEAR s_pernr1.
      READ TABLE s_pernr1 INDEX 1.

      ADD 10 TO lv_ebelp.
      MOVE wa_itab1-bukrs TO <fs_zfbid_sfa>-bukrs.
      MOVE wa_itab1-vkbur TO <fs_zfbid_sfa>-vkbur.
      MOVE wa_itab1-gjahr TO <fs_zfbid_sfa>-gjahr.
      MOVE lv_bbeln       TO <fs_zfbid_sfa>-bbeln.
      MOVE lv_ebelp       TO <fs_zfbid_sfa>-ebelp.
      MOVE wa_itab1-belnr TO <fs_zfbid_sfa>-vbeln.
      MOVE wa_itab1-gsber TO <fs_zfbid_sfa>-gsber.
      MOVE wa_itab1-zuonr TO <fs_zfbid_sfa>-zuonr.
      MOVE wa_itab1-buzei TO <fs_zfbid_sfa>-buzei.
      MOVE wa_itab1-budat TO <fs_zfbid_sfa>-fkdat.
      MOVE wa_itab1-kunnr TO <fs_zfbid_sfa>-kunnr.
      MOVE s_pernr1-low   TO <fs_zfbid_sfa>-slcod.
      MOVE wa_itab1-parvw TO <fs_zfbid_sfa>-parvw.
      MOVE wa_itab1-bldat TO <fs_zfbid_sfa>-bldat.
      MOVE wa_itab1-blart TO <fs_zfbid_sfa>-blart.
      MOVE wa_itab1-belnr TO <fs_zfbid_sfa>-belnr.
      MOVE wa_itab1-zfbdt TO <fs_zfbid_sfa>-zfbdt.
      MOVE wa_itab1-pstat TO <fs_zfbid_sfa>-pstat.
      MOVE sy-datum       TO <fs_zfbid_sfa>-erdt2.
      <fs_zfbid_sfa>-wrbtr = wa_itab1-wrbtr / 100.

      CLEAR: lv_zbd1t.
      SELECT SINGLE zbd1t xref1 xref3
        INTO (lv_zbd1t, <fs_zfbid_sfa>-parvw, <fs_zfbid_sfa>-xref3)
        FROM bsid WHERE bukrs = <fs_zfbid_sfa>-bukrs
                    AND kunnr = <fs_zfbid_sfa>-kunnr
                    AND zuonr = <fs_zfbid_sfa>-zuonr(10)
                    AND blart = 'RV'.
      IF sy-subrc = 0.
        <fs_zfbid_sfa>-dudat = <fs_zfbid_sfa>-zfbdt + lv_zbd1t.
      ELSE.
        SELECT SINGLE zbd1t xref1 xref3
          INTO (lv_zbd1t, <fs_zfbid_sfa>-parvw, <fs_zfbid_sfa>-xref3)
          FROM bsad WHERE bukrs = <fs_zfbid_sfa>-bukrs
                      AND kunnr = <fs_zfbid_sfa>-kunnr
                      AND zuonr = <fs_zfbid_sfa>-zuonr(10)
                      AND blart = 'RV'.
        IF sy-subrc = 0.
          <fs_zfbid_sfa>-dudat = <fs_zfbid_sfa>-zfbdt + lv_zbd1t.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_zfbid_sfa[] IS NOT INITIAL.
    MODIFY zfbid_sfa FROM TABLE lt_zfbid_sfa.
    IF sy-subrc = 0.
      PERFORM f_modify_payment_block TABLES lt_zfbid_sfa.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_ITEM_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_RELEASE_TABLE
*&---------------------------------------------------------------------*
FORM f_release_table .
  DATA lt_out2 LIKE gt_out2 OCCURS 0 WITH HEADER LINE.

  lt_out2[] = gt_out2[].
  DELETE lt_out2 WHERE chbox IS INITIAL.

  LOOP AT lt_out2.
    UPDATE zfbih_sfa SET usnam_rel = sy-uname
                         erdat_rel = sy-datum
                         erzet_rel = sy-uzeit
                     WHERE bukrs = p_vkorg
                       AND vkbur = p_vkbur
                       AND bbeln = lt_out2-bbeln.
  ENDLOOP.
ENDFORM.                    " F_RELEASE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNRELEASE_TABLE
*&---------------------------------------------------------------------*
FORM f_unrelease_table .
  DATA lt_out2 LIKE gt_out2 OCCURS 0 WITH HEADER LINE.

  lt_out2[] = gt_out2[].
  DELETE lt_out2 WHERE chbox IS INITIAL.

  LOOP AT lt_out2.
    UPDATE zfbih_sfa SET usnam_rel   = space
                         erdat_rel   = '00000000' "space
                         erzet_rel   = '000000' "space
                         filenm_dwn  = space
                         erdat_dwn   = '00000000' "space
                         usnam_unrel = sy-uname
                         erdat_unrel = sy-datum
                         erzet_unrel = sy-uzeit
                     WHERE bukrs = p_vkorg
                       AND vkbur = p_vkbur
                       AND bbeln = lt_out2-bbeln.
  ENDLOOP.
ENDFORM.                    " F_UNRELEASE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_download_data .
  TYPES: BEGIN OF t_detail,
           ebelp TYPE char5,
           kunnr TYPE char10,
           parvw TYPE char10,
           blart TYPE char2,
           zuonr TYPE char18,
           zfbdt TYPE char10,
           gjahr TYPE char4,
           vbeln TYPE char10,
           fkdat TYPE char10,
           dudat TYPE char10,
           wrbtr TYPE char20,
         END OF t_detail.
  TYPES: BEGIN OF ti_header,
           bukrs      TYPE char4,
           vkbur      TYPE char4,
           bbeln      TYPE char7,
           bidat      TYPE char10,
           parnr      TYPE char10,
           dsp        TYPE char6,
           sdate      TYPE char10,
           receive_ke TYPE zreceive_ke,
           bi_detail  TYPE t_detail OCCURS 0,
         END OF ti_header.


  DATA: wa_detail TYPE t_detail.
  DATA: wa_header TYPE ti_header OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF i_json OCCURS 0,
          bi_header TYPE ti_header,
        END OF i_json.
  DATA: lo_json_data TYPE REF TO zcl_trex_json_serializer,
        json         TYPE string.
  DATA: l_len       TYPE i, lv_error(1).
  DATA: lv_path     LIKE p_path,
        lv_filename TYPE char25.

  DATA: gv_xml TYPE xstring.
  DATA: gv_str TYPE string.
  DATA: l_date LIKE sy-datum.
  DATA: l_ctr TYPE i.

  SORT gt_zfbih_sfa BY bukrs vkbur bbeln.
  SORT gt_zfbid_sfa BY bukrs vkbur bbeln ebelp.

  LOOP AT gt_zfbih_sfa.
    CLEAR: lv_path,lv_filename,gt_hdrdwn,gt_hdrdwn[],gt_itmdwn[],
           gt_download,gt_download[], i_json-bi_header, i_json-bi_header-bi_detail[],
           wa_header-bi_detail[].
    CLEAR: i_json[], gv_str, lv_error, l_len, l_ctr, json, gs_zsfafidt002, wa_detail.

    CASE 'X'.
      WHEN p_rad4.
        CONCATENATE 'BI' gt_zfbih_sfa-vkbur gt_zfbih_sfa-bbeln
          INTO lv_filename SEPARATED BY '_'.
      WHEN p_rad6.
        lv_filename = gt_zfbih_sfa-filenm_dwn.
    ENDCASE.
    CONCATENATE p_path lv_filename '.txt' INTO lv_path.
    MOVE-CORRESPONDING gt_zfbih_sfa TO gt_hdrdwn.
    gt_hdrdwn-doctyp = 'H'.
    gt_hdrdwn-gsber = gt_zfbih_sfa-vkbur.
    gt_hdrdwn-dsp = gt_zfbih_sfa-daily_call_num.
    WRITE gt_zfbih_sfa-bidat TO gt_hdrdwn-bidat.
    IF gt_zfbih_sfa-sdate IS INITIAL OR gt_zfbih_sfa-sdate = '00000000'.
      gt_zfbih_sfa-sdate = gt_zfbih_sfa-bidat.
    ENDIF.
    WRITE gt_zfbih_sfa-sdate TO gt_hdrdwn-sdate.
    SHIFT gt_hdrdwn-parnr BY 2 PLACES.
    APPEND gt_hdrdwn.
    gs_zsfafidt002-bukrs     = gt_zfbih_sfa-bukrs.
    gs_zsfafidt002-vkbur     = gt_zfbih_sfa-vkbur.
    gs_zsfafidt002-bbeln     = gt_zfbih_sfa-bbeln.

    MOVE-CORRESPONDING gt_hdrdwn TO wa_header.
    CONCATENATE wa_header-bidat+6(4) wa_header-bidat+3(2) wa_header-bidat(2) INTO wa_header-bidat.
    CONCATENATE wa_header-sdate+6(4) wa_header-sdate+3(2) wa_header-sdate(2) INTO wa_header-sdate.
    LOOP AT gt_zfbid_sfa WHERE bukrs = gt_zfbih_sfa-bukrs
                           AND vkbur = gt_zfbih_sfa-vkbur
                           AND bbeln = gt_zfbih_sfa-bbeln.
      CLEAR: gt_itmdwn.
      MOVE-CORRESPONDING gt_zfbid_sfa TO gt_itmdwn.
      gt_itmdwn-doctyp = 'D'.
      WRITE gt_zfbid_sfa-fkdat TO gt_itmdwn-fkdat.
      WRITE gt_zfbid_sfa-zfbdt TO gt_itmdwn-zfbdt.
      WRITE gt_zfbid_sfa-dudat TO gt_itmdwn-dudat.
      WRITE gt_zfbid_sfa-wrbtr TO gt_itmdwn-wrbtr CURRENCY 'IDR'.
      REPLACE ALL OCCURRENCES OF '.' IN gt_itmdwn-wrbtr WITH space.
      CONDENSE gt_itmdwn-wrbtr.
      IF gt_zfbid_sfa-wrbtr LT 0.
        CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
          CHANGING
            value = gt_itmdwn-wrbtr.
      ENDIF.
      CALL FUNCTION 'STRING_MOVE_RIGHT'
        EXPORTING
          string    = gt_itmdwn-wrbtr
        IMPORTING
          rstring   = gt_itmdwn-wrbtr
        EXCEPTIONS
          too_small = 1
          OTHERS    = 2.
      MOVE-CORRESPONDING gt_itmdwn TO wa_detail.
      CONCATENATE wa_detail-zfbdt+6(4) wa_detail-zfbdt+3(2) wa_detail-zfbdt(2) INTO wa_detail-zfbdt.
      CONCATENATE wa_detail-fkdat+6(4) wa_detail-fkdat+3(2) wa_detail-fkdat(2) INTO wa_detail-fkdat.
      CONCATENATE wa_detail-dudat+6(4) wa_detail-dudat+3(2) wa_detail-dudat(2) INTO wa_detail-dudat.
      CONDENSE wa_detail-wrbtr.
      APPEND wa_detail TO wa_header-bi_detail.
      APPEND gt_itmdwn.
    ENDLOOP.
    MOVE-CORRESPONDING wa_header TO i_json-bi_header.
    CREATE OBJECT lo_json_data
      EXPORTING
        data = i_json.

    lo_json_data->serialize( ).
    json = lo_json_data->get_data( ).
    CLEAR: gv_str, lv_error .
    PERFORM f_post_data_json(zsfa_i0001)  USING json 'BINEW'
                        CHANGING lv_error gv_str .
    gs_zsfafidt002-status = gv_str.
    gs_zsfafidt002-ername = sy-uname.
    gs_zsfafidt002-ertime = sy-uzeit.
    gs_zsfafidt002-erdate = sy-datum.
    SELECT SINGLE counter INTO gs_zsfafidt002-counter FROM zsfafidt002
      WHERE bukrs = gs_zsfafidt002-bukrs AND
            vkbur = gs_zsfafidt002-vkbur AND
            bbeln = gs_zsfafidt002-bbeln.
    IF sy-subrc EQ 0.
      l_ctr = gs_zsfafidt002-counter.
      ADD 1 TO l_ctr.
      gs_zsfafidt002-counter = l_ctr.
    ELSE.
      gs_zsfafidt002-counter = 1.
    ENDIF.
    MOVE-CORRESPONDING gs_zsfafidt002 TO zsfafidt002.
    MODIFY zsfafidt002.
    CLEAR: l_ctr.
    WRITE: / 'Result API BI NEW: ', gv_str,
           / 'Result : ', lv_error.
    l_len = strlen( gv_str ).
    FIND '"status":"' IN gv_str MATCH OFFSET l_ctr.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 10.
      l_len = l_len - l_ctr.
      "      json1 = gv_str+l_ctr(1).
      WRITE: / 'Status : ', gv_str+l_ctr(1).
      lv_error = gv_str+l_ctr(1).
    ELSE.
      lv_error = 'E'.
      WRITE: / gv_str.
    ENDIF.
    DATA: lv_counter TYPE i.
    CLEAR: lv_counter.
    lv_counter = 1.
    SKIP 1.
    DO  3 TIMES.
      IF lv_error EQ 'S'.
        WRITE: / 'Sukses Send BI to TIMOS'.
        WRITE: / gv_str.
        EXIT.
      ENDIF.
      SKIP 1.
      WRITE: / 'Gagal send API - Error Code: ', sy-subrc.
      WRITE: / 'Resend API : ', lv_counter.
      CLEAR: gv_str, lv_error .
      PERFORM f_post_data_json(zsfa_i0001)  USING json 'BINEW'
                          CHANGING lv_error gv_str .
      gs_zsfafidt002-status = gv_str.
      gs_zsfafidt002-ername = sy-uname.
      gs_zsfafidt002-ertime = sy-uzeit.
      gs_zsfafidt002-erdate = sy-datum.
      SELECT SINGLE counter INTO gs_zsfafidt002-counter FROM zsfafidt002
        WHERE bukrs = gs_zsfafidt002-bukrs AND
              vkbur = gs_zsfafidt002-vkbur AND
              bbeln = gs_zsfafidt002-bbeln.
      IF sy-subrc EQ 0.
        l_ctr = gs_zsfafidt002-counter.
        ADD 1 TO l_ctr.
        gs_zsfafidt002-counter = l_ctr.
      ELSE.
        gs_zsfafidt002-counter = 1.
      ENDIF.
      MOVE-CORRESPONDING gs_zsfafidt002 TO zsfafidt002.
      MODIFY zsfafidt002.
      CLEAR: l_ctr.
      WRITE: / 'Hasil Resend API BI NEW ke - ', lv_counter, ' : ', gv_str,
             / 'Result : ', lv_error.
      l_len = strlen( gv_str ).
      FIND '"status":"' IN gv_str MATCH OFFSET l_ctr.
      IF sy-subrc EQ 0.
        l_ctr = l_ctr + 10.
        l_len = l_len - l_ctr.
        "      json1 = gv_str+l_ctr(1).
        WRITE: / 'Status : ', gv_str+l_ctr(1).
        lv_error = gv_str+l_ctr(1).
      ELSE.
        lv_error = 'E'.
        WRITE: / gv_str.
      ENDIF.
      IF lv_error = 'S'.
        WRITE: / 'Sukses Send BI to TIMOS'.
        WRITE: / gv_str.
        EXIT.
      ENDIF.
      ADD 1 TO lv_counter.
    ENDDO.
    IF lv_counter >= 3 AND lv_error NE 'S'.
      PERFORM send_email USING gt_zfbih_sfa-bukrs gt_zfbih_sfa-vkbur gt_zfbih_sfa-bbeln.
    ENDIF.
    DATA: lv_message(150).
    CLEAR: lv_message..
    IF lv_error EQ 'E'.
      CONCATENATE 'Gagal Kirim BI ke TIMOS, mohon Re-download BI no.' gt_zfbih_sfa-bbeln INTO lv_message.
      MESSAGE w000(zs) WITH lv_message.
    ELSEIF lv_error EQ 'S'.
      CONCATENATE 'Berhasil Kirim BI ke Timos. (BI no. ' gt_zfbih_sfa-bbeln ')' INTO lv_message.
      MESSAGE i000(zs) WITH lv_message.
    ELSEIF lv_error EQ 'A'.
      CONCATENATE 'BI No.' gt_zfbih_sfa-bbeln 'sudah ada di TIMOS, mohon cek di web' INTO lv_message.
      MESSAGE i000(zs) WITH lv_message.
    ENDIF.
    IF p_rad4 = 'X'.
      lv_filename = 'SEND VIA API'.
      UPDATE zfbih_sfa SET filenm_dwn = lv_filename
                           erdat_dwn  = sy-datum
                       WHERE bukrs = gt_zfbih_sfa-bukrs
                         AND vkbur = gt_zfbih_sfa-vkbur
                         AND bbeln = gt_zfbih_sfa-bbeln.
    ENDIF.
    CLEAR: i_json[], gv_str, lv_error, l_len, l_ctr, json.
  ENDLOOP.


ENDFORM.                    " F_DOWNLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_DELETE_ITEM
*&---------------------------------------------------------------------*
FORM f_remove_delete_item .
  IF gt_zfbid_sfa[] IS NOT INITIAL.
    DELETE gt_zfbid_sfa WHERE zdele IS NOT INITIAL.
  ENDIF.
ENDFORM.                    " F_REMOVE_DELETE_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_DOWNLOAD_ITEM
*&---------------------------------------------------------------------*
FORM f_remove_download_item .
  IF gt_zfbih_sfa[] IS NOT INITIAL.
    DELETE gt_zfbih_sfa WHERE filenm_dwn IS NOT INITIAL.
*    DELETE gt_zfbih_sfa WHERE payupl_filenm IS NOT INITIAL.
  ENDIF.
ENDFORM.                    " F_REMOVE_DOWNLOAD_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_REDOWNLOAD_ITEM
*&---------------------------------------------------------------------*
FORM f_remove_redownload_item .
  IF gt_zfbih_sfa[] IS NOT INITIAL.
    DELETE gt_zfbih_sfa WHERE filenm_dwn IS INITIAL.
  ENDIF.
ENDFORM.                    " F_REMOVE_REDOWNLOAD_ITEM

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL_CHBOX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control_chbox INPUT.
  DATA : ls_out   LIKE LINE OF gt_out.

  CLEAR ls_out-chgrow.
  CASE sy-ucomm.
    WHEN 'NEW'.

    WHEN 'DELE'.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out INDEX input-current_line.
      IF ls_out-zicon = icon_delete.     "Undelete
        CLEAR: ls_out-zicon.
      ELSE.
        ls_out-zicon = icon_delete.      "Delete
      ENDIF.

*      IF ls_out-kunnr IS NOT INITIAL.
*        IF gt_vout-zicon = icon_delete.     "Undelete
*          CLEAR: gt_vout-zicon.
*        ELSE.
*          gt_vout-zicon = icon_delete.      "Delete
*        ENDIF.
*        gt_vout-chgrow = 'X'.
*      ELSE.
*        CLEAR: gt_vout-zicon, gt_vout-chgrow.
*      ENDIF.
*
    WHEN 'ENTR'.
  ENDCASE.

  CLEAR ls_out-chbox.
  MODIFY gt_out FROM ls_out INDEX input-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL_CHBOX  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_KR1A
*&---------------------------------------------------------------------*
FORM f_get_kr1a .
  CLEAR: gt_zfbid,gt_zfbid[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfbid
    FROM zfbid FOR ALL ENTRIES IN i_itab1
    WHERE bukrs     EQ p_vkorg       AND
          vkbur     EQ p_vkbur       AND
          zuonr     EQ i_itab1-zuonr AND
          kunnr     EQ i_itab1-kunnr AND
          ( bflag EQ space AND pstat = 'F' ).

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfbid_sfa2
    FROM zfbid_sfa FOR ALL ENTRIES IN i_itab1
    WHERE bukrs     EQ p_vkorg       AND
          vkbur     EQ p_vkbur       AND
          zuonr     EQ i_itab1-zuonr AND
          kunnr     EQ i_itab1-kunnr AND
          ( bflag EQ space AND pstat = 'F' ).
ENDFORM.                    " F_GET_KR1A

*&---------------------------------------------------------------------*
*&      Module  STATUS_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0501 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0501 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  CASE save_ok.
    WHEN 'KR1A'.
      PERFORM f_kr1a_list.
    WHEN 'BI'.
      PERFORM f_terikat_bi_list.
  ENDCASE.
ENDMODULE.                 " LIST_PROCESSING_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_KR1A_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_kr1a_list .
  IF gt_zfh_kr1at[] IS INITIAL.
    WRITE: /13 'No Data'.
  ELSE.
    ULINE AT /(89).
    WRITE: /  sy-vline NO-GAP, (5) 'SOff' NO-GAP,
              sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO' NO-GAP,
              sy-vline NO-GAP, (15) 'Nomor FORM 3' NO-GAP,
              sy-vline NO-GAP, (30) 'Message' NO-GAP,
              sy-vline.
    ULINE AT /(89).
    LOOP AT gt_zfh_kr1at.
      WRITE: /  sy-vline NO-GAP, (5) gt_zfh_kr1at-vkbur NO-GAP,
                sy-vline NO-GAP, (15) gt_zfh_kr1at-kunnr NO-GAP,
                sy-vline NO-GAP, gt_zfh_kr1at-zuonr NO-GAP,
                sy-vline NO-GAP, (15) gt_zfh_kr1at-noform NO-GAP,
                sy-vline NO-GAP, (30) 'No DO sudah ada di FORM 3' NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(89).
  ENDIF.
ENDFORM.                    " F_KR1A_LIST

*&---------------------------------------------------------------------*
*&      Form  F_PAYMENT_BLOCK
*&---------------------------------------------------------------------*
FORM f_payment_block  TABLES lt_zfbid_sfa STRUCTURE zfbid_sfa
                      USING fu_flag.
  DATA: ls_zfbid_sfa LIKE zfbid_sfa.

  LOOP AT lt_zfbid_sfa INTO ls_zfbid_sfa.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
           'X'  'SAPMF05L'   '0102',
           ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
           ' ' 'BDC_OKCODE'  '/00',
           ' ' 'RF05L-BELNR' ls_zfbid_sfa-belnr,
           ' ' 'RF05L-BUKRS' p_vkorg,
           ' ' 'RF05L-GJAHR' ls_zfbid_sfa-gjahr,
*               ' ' 'RF05L-XKDEB' 'X',
           ' ' 'RF05L-BUZEI' ls_zfbid_sfa-buzei,
           'X' 'SAPMF05L'    '0301',
           ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
           ' ' 'BDC_OKCODE'  '=AE',
           ' ' 'BSEG-ZLSPR'	 fu_flag.
    CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
           MESSAGES INTO messtab.
  ENDLOOP.
ENDFORM.                    " F_PAYMENT_BLOCK

*&---------------------------------------------------------------------*
*&      Form  F_DYNPRO
*&---------------------------------------------------------------------*
FORM f_dynpro USING dynbegin name value.
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_PAYMENT_BLOCK
*&---------------------------------------------------------------------*
FORM f_modify_payment_block  TABLES ft_zfbid_sfa STRUCTURE zfbid_sfa.
  DATA: ls_zfbid_sfa LIKE zfbid_sfa.

  LOOP AT ft_zfbid_sfa INTO ls_zfbid_sfa.
    CASE ls_zfbid_sfa-zdele.
      WHEN space.
        CLEAR i_bdc.
        PERFORM f_dynpro USING:
               'X'  'SAPMF05L'   '0102',
               ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
               ' ' 'BDC_OKCODE'  '/00',
               ' ' 'RF05L-BELNR' ls_zfbid_sfa-belnr,
               ' ' 'RF05L-BUKRS' ls_zfbid_sfa-bukrs,    "p_vkorg,
               ' ' 'RF05L-GJAHR' ls_zfbid_sfa-gjahr,
*                   ' ' 'RF05L-XKDEB' 'X',
               ' ' 'RF05L-BUZEI' ls_zfbid_sfa-buzei,
               'X' 'SAPMF05L'    '0301',
               ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
               ' ' 'BDC_OKCODE'  '=AE',
               ' ' 'BSEG-ZLSPR'	 'B'.
        CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
               MESSAGES INTO messtab.
      WHEN 'X'.
        CLEAR i_bdc.
        PERFORM f_dynpro USING:
               'X'  'SAPMF05L'   '0102',
               ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
               ' ' 'BDC_OKCODE'  '/00',
               ' ' 'RF05L-BELNR' ls_zfbid_sfa-belnr,
               ' ' 'RF05L-BUKRS' ls_zfbid_sfa-bukrs,  "p_vkorg,
               ' ' 'RF05L-GJAHR' ls_zfbid_sfa-gjahr,
*                   ' ' 'RF05L-XKDEB' 'X',
               ' ' 'RF05L-BUZEI' ls_zfbid_sfa-buzei,
               'X' 'SAPMF05L'    '0301',
               ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
               ' ' 'BDC_OKCODE'  '=AE',
               ' ' 'BSEG-ZLSPR'	 'Z'.
        CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
               MESSAGES INTO messtab.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_PAYMENT_BLOCK

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_PAYMENT_ITEM
*&---------------------------------------------------------------------*
FORM f_remove_payment_item .
  IF gt_zfbih_sfa[] IS NOT INITIAL.
    DELETE gt_zfbih_sfa WHERE payupl_filenm IS NOT INITIAL.
  ENDIF.
ENDFORM.                    " F_REMOVE_PAYMENT_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_TERIKAT_BI_LIST
*&---------------------------------------------------------------------*
FORM f_terikat_bi_list .
  DATA: lv_msg TYPE char30.

  IF i_itab1b[] IS INITIAL.
    WRITE: /13 'No Data'.
  ELSE.
    ULINE AT /(89).
    WRITE: /  sy-vline NO-GAP,  (5) 'SOff' NO-GAP,
              sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO' NO-GAP,
              sy-vline NO-GAP, (15) 'Nomor Billing' NO-GAP,
              sy-vline NO-GAP, (30) 'Message' NO-GAP,
              sy-vline.
    ULINE AT /(89).
    LOOP AT i_itab1b.
      CLEAR lv_msg.
      CONCATENATE 'No DO sudah terikat BI' i_itab1b-bbeln INTO lv_msg
        SEPARATED BY space.
      WRITE: /  sy-vline NO-GAP, (5) i_itab1b-vkbur NO-GAP,
                sy-vline NO-GAP, (15) i_itab1b-kunnr NO-GAP,
                sy-vline NO-GAP, i_itab1b-zuonr NO-GAP,
                sy-vline NO-GAP, (15) i_itab1b-belnr NO-GAP,
                sy-vline NO-GAP, (30) lv_msg NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(89).
  ENDIF.
ENDFORM.                    " F_TERIKAT_BI_LIST

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RAD7
*&---------------------------------------------------------------------*
FORM f_get_data_rad7 .
  SELECT * INTO TABLE gt_zfbih_sfa
    FROM zfbih_sfa WHERE bukrs = p_vkorg
                     AND vkbur = p_vkbur
                     AND bbeln IN gr_bbeln
                     AND parnr IN gr_pernr
                     AND sdate IN gr_sdate
                     AND daily_call_num IN gr_dcp.
  IF sy-subrc = 0.
    SELECT pernr ansvh sname ename
      INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
      FROM pa0001 FOR ALL ENTRIES IN gt_zfbih_sfa
      WHERE pernr = gt_zfbih_sfa-parnr+2(8).

    SELECT * INTO TABLE gt_zfbid_sfa
      FROM zfbid_sfa FOR ALL ENTRIES IN gt_zfbih_sfa
      WHERE bukrs = p_vkorg
        AND vkbur = p_vkbur
        AND bbeln = gt_zfbih_sfa-bbeln.

    IF sy-subrc = 0.
      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FROM kna1 FOR ALL ENTRIES IN gt_zfbid_sfa
        WHERE kunnr EQ gt_zfbid_sfa-kunnr.
    ENDIF.
  ELSE.
    MESSAGE 'No Data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RAD7

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_RAD7
*&---------------------------------------------------------------------*
FORM f_process_data_rad7 .
  LOOP AT gt_zfbih_sfa.
    CLEAR gt_pa0001.
    READ TABLE gt_pa0001 WITH KEY pernr = gt_zfbih_sfa-parnr.
    LOOP AT gt_zfbid_sfa WHERE bukrs = gt_zfbih_sfa-bukrs
                           AND vkbur = gt_zfbih_sfa-vkbur
                           AND bbeln = gt_zfbih_sfa-bbeln.

      IF gt_zfbid_sfa-zdele IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR gt_kna1.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_zfbid_sfa-kunnr.

      MOVE-CORRESPONDING gt_zfbih_sfa TO gt_out7.
      gt_out7-sname = gt_pa0001-sname.
      gt_out7-parvw = gt_zfbid_sfa-parvw.
      gt_out7-vbeln = gt_zfbid_sfa-vbeln.
      gt_out7-gjahr = gt_zfbid_sfa-gjahr.
      gt_out7-zuonr = gt_zfbid_sfa-zuonr.
      gt_out7-fkdat = gt_zfbid_sfa-fkdat.
      gt_out7-zfbdt = gt_zfbid_sfa-zfbdt.
      gt_out7-wrbtr = gt_zfbid_sfa-wrbtr.
      gt_out7-dudat = gt_zfbid_sfa-dudat.
      gt_out7-kunnr = gt_zfbid_sfa-kunnr.
      gt_out7-name1 = gt_kna1-name1.

      COLLECT gt_out7. CLEAR gt_out7.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_RAD7

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_detail .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfbid_sfa3
    FROM zfbid_sfa FOR ALL ENTRIES IN i_itab1
    WHERE bukrs     EQ p_vkorg       AND
          vkbur     EQ p_vkbur       AND
          zuonr     EQ i_itab1-zuonr.
ENDFORM.                    " F_GET_DATA_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER_ROUTE
*&---------------------------------------------------------------------*
FORM f_get_customer_route .
  SELECT * INTO TABLE gt_knvp1
    FROM knvp WHERE pernr = s_pernr1-low
                AND vkorg = p_vkorg
                AND parvw = 'ZP'.
  IF gt_knvp1[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_knvp2
      FROM knvp FOR ALL ENTRIES IN gt_knvp1
      WHERE kunn2 = gt_knvp1-kunnr
        AND vkorg = gt_knvp1-vkorg.
    IF sy-subrc = 0.
      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FROM kna1 FOR ALL ENTRIES IN gt_knvp2
        WHERE kunnr EQ gt_knvp2-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CUSTOMER_ROUTE

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE_CHECK
*&---------------------------------------------------------------------*
FORM f_lock_table_check USING fu_flag.
  DATA: lv_umjah TYPE umjah.

  CLEAR: s_pernr1,s_sdate1.
  READ TABLE s_pernr1 INDEX 1.
  READ TABLE s_sdate1 INDEX 1.
  lv_umjah = s_sdate1-low(4).

  CASE fu_flag.
    WHEN 'E'.
      CALL FUNCTION 'ENQUEUE_EZSSUTDT025'
        EXPORTING
          vkorg          = p_vkorg
          vkbur          = p_vkbur
          pernr          = s_pernr1-low
          umjah          = lv_umjah
          sdate          = s_sdate1-low
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc NE 0.
        IF sy-subrc EQ 1.
          MESSAGE a000(zf) WITH 'Data masih ter-lock'.
          STOP.
        ENDIF.
      ENDIF.

    WHEN 'D'.
      CALL FUNCTION 'DEQUEUE_EZSSUTDT025'
        EXPORTING
          vkorg          = p_vkorg
          vkbur          = p_vkbur
          pernr          = s_pernr1-low
          umjah          = lv_umjah
          sdate          = s_sdate1-low
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc NE 0.
        IF sy-subrc EQ 1.
          MESSAGE a000(zf) WITH 'Data masih ter-lock'.
          STOP.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_LOCK_TABLE_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BI
*&---------------------------------------------------------------------*
FORM f_create_bi .
  DATA:
    ls_row  TYPE lvc_s_row,
    lt_rows TYPE lvc_t_row,
    lt_out  LIKE gt_out OCCURS 0 WITH HEADER LINE.

*  CALL METHOD g_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = lt_rows
**      et_row_no     =
*      .
*
*  IF lt_rows IS INITIAL.
*    MESSAGE 'No data selected' TYPE 'S'.
*
*  ELSE.
*    LOOP AT lt_rows INTO ls_row.
*      READ TABLE gt_out INDEX ls_row-index.
*      APPEND gt_out TO lt_out.
*    ENDLOOP.
*
*    CLEAR gt_out[].
*    gt_out[] = lt_out[].

  lt_out[] = gt_out[].
  DELETE lt_out WHERE chbox IS NOT INITIAL.

  LOOP AT lt_out INTO gt_vout
                 WHERE zicon = space.
    PERFORM f_entry_check USING gt_vout.
  ENDLOOP.
  PERFORM f_save_data.
*  ENDIF.
ENDFORM.                    " F_CREATE_BI

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DUDAT
*&---------------------------------------------------------------------*
FORM f_modify_dudat  USING    fu_bukrs
                              fu_kunnr
                              fu_zuonr
                              fu_zfbdt
                              fu_blart
                     CHANGING fc_dudat.
  DATA : lv_zbd1t LIKE bsid-zbd1t,
         lv_shkzg LIKE bsid-shkzg.

  SELECT SINGLE zbd1t shkzg INTO (lv_zbd1t, lv_shkzg)
    FROM bsid WHERE bukrs = fu_bukrs
                AND kunnr = fu_kunnr
                AND zuonr = fu_zuonr(10)
                AND blart = fu_blart.
  IF sy-subrc = 0.
*    fc_dudat = fu_zfbdt + lv_zbd1t.
    PERFORM f_calculate_duedt USING lv_zbd1t fu_zfbdt lv_shkzg
                              CHANGING fc_dudat.

  ELSE.
    SELECT SINGLE zbd1t shkzg INTO (lv_zbd1t, lv_shkzg)
      FROM bsad WHERE bukrs = fu_bukrs
                  AND kunnr = fu_kunnr
                  AND zuonr = fu_zuonr(10)
                  AND blart = fu_blart.
    IF sy-subrc = 0.
*      fc_dudat = fu_zfbdt + lv_zbd1t.
      PERFORM f_calculate_duedt USING lv_zbd1t fu_zfbdt lv_shkzg
                                CHANGING fc_dudat.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_DUDAT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION
*&---------------------------------------------------------------------*
FORM f_selection  USING    fu_select.
  DATA : ls_out LIKE LINE OF gt_out.
  CLEAR ls_out.
  LOOP AT gt_out INTO ls_out.
    ls_out-chbox  = fu_select.
    MODIFY gt_out FROM ls_out TRANSPORTING chbox.
  ENDLOOP.
  REFRESH CONTROL 'INPUT' FROM SCREEN '500'.
ENDFORM.                    " F_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_UNDELETE
*&---------------------------------------------------------------------*
FORM f_delete_undelete .
  DATA : ls_out LIKE LINE OF gt_out.
  CLEAR ls_out.
  LOOP AT gt_out INTO ls_out.
    IF ls_out-chbox IS NOT INITIAL.
      IF ls_out-zicon = icon_delete.     "Undelete
        CLEAR: ls_out-zicon.
      ELSE.
        ls_out-zicon = icon_delete.      "Delete
      ENDIF.
      ls_out-chgrow = 'X'.
    ENDIF.
    MODIFY gt_out FROM ls_out TRANSPORTING zicon chgrow.
  ENDLOOP.
ENDFORM.                    " F_DELETE_UNDELETE

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
*&      Form  F_BI_INKASO
*&---------------------------------------------------------------------*
FORM f_bi_inkaso .
  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2 a~xref3 a~vbund a~blart a~umskz
      INTO CORRESPONDING FIELDS OF TABLE i_itab7
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                     JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                       d~bukrs EQ a~bukrs
      WHERE a~bukrs EQ p_vkorg
        AND a~zlspr IN (space,'Z','B')
        AND a~blart IN ('DA','RV','DR','DG','ZA')
        AND a~umskz EQ space
        AND a~kunnr IN s_kunnr
        AND a~zuonr IN s_zuonr
        AND b~vkbur EQ p_vkbur
        AND b~vkorg EQ p_vkorg
        AND b~vtweg EQ '10'.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2 a~xref3 a~vbund a~blart a~umskz
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab7
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                     JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                       d~bukrs EQ a~bukrs
      WHERE a~bukrs EQ p_vkorg
        AND a~zlspr IN (space,'Z','B')
        AND a~blart EQ 'DA'
        AND a~umskz NE space
        AND a~kunnr IN s_kunnr
        AND a~zuonr IN s_zuonr
        AND b~vkbur EQ p_vkbur
        AND b~vkorg EQ p_vkorg
        AND b~vtweg EQ '10'.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2 a~vbund a~blart a~umskz
    INTO CORRESPONDING FIELDS OF TABLE i_itab6
    FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                   JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                     d~bukrs EQ a~bukrs
    WHERE a~bukrs EQ p_vkorg
      AND a~zlspr IN (space,'Z')
      AND a~blart EQ 'DZ'
      AND a~umskz EQ space
      AND a~kunnr IN s_kunnr
      AND a~zuonr IN s_zuonr
      AND b~vkbur EQ p_vkbur
      AND b~vkorg EQ p_vkorg
      AND b~vtweg EQ '10'.

  DELETE i_itab6 WHERE blart = 'DA' AND umskz = 'V'.
  DELETE i_itab7 WHERE blart = 'DA' AND umskz = 'V'.
ENDFORM.                    " F_BI_INKASO

*&---------------------------------------------------------------------*
*&      Form  F_GET_FI_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_fi_document  USING    ft_vout STRUCTURE gt_vout.
  DATA : lt_bsid TYPE STANDARD TABLE OF ty_bsid,
         ls_bsid LIKE LINE OF gt_bsid.

  SELECT bsid~bukrs bsid~kunnr bsid~umsks bsid~umskz bsid~augdt
    bsid~augbl bsid~zuonr bsid~gjahr bsid~belnr bsid~buzei
    bsid~blart bsid~zfbdt bsid~zbd1t bsid~shkzg bsid~gsber
    bsid~wrbtr
    kna1~name1
    FROM bsid JOIN kna1 ON bsid~kunnr = kna1~kunnr
    INTO TABLE lt_bsid
    WHERE bukrs = p_vkorg
      AND zuonr = ft_vout-zuonr.

  LOOP AT lt_bsid INTO ls_bsid.
    ft_vout-kunnr  = ls_bsid-kunnr.
    ft_vout-name1  = ls_bsid-name1.
    ft_vout-blart  = ls_bsid-blart.
    ft_vout-bldat  = ls_bsid-zfbdt.
    ft_vout-zfbdt  = ls_bsid-zfbdt + ls_bsid-zbd1t.
    IF ls_bsid-shkzg = 'H'.
      ft_vout-wrbtr  = ls_bsid-wrbtr * -100.
    ELSE.
      ft_vout-wrbtr  = ls_bsid-wrbtr * 100.
    ENDIF.
    ft_vout-belnr  = ls_bsid-belnr.
    PERFORM f_calculate_duedt USING ls_bsid-zbd1t ls_bsid-zfbdt
                                    ls_bsid-shkzg
                              CHANGING ft_vout-dudat.

    ft_vout-chgrow = 'X'.
    APPEND ls_bsid TO gt_bsid.
    CLEAR ls_bsid.
  ENDLOOP.
ENDFORM.                    " F_GET_FI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITEM_TABLE_INKASO
*&---------------------------------------------------------------------*
FORM f_modify_item_table_inkaso .
  DATA : lv_ebelp     LIKE zfbid_sfa-ebelp.
  DATA : lt_zfbid_sfa TYPE TABLE OF zfbid_sfa,
         ls_zfbid_sfa LIKE LINE OF lt_zfbid_sfa,
         ls_bsid      LIKE LINE OF gt_bsid,
         lt_vbpa      TYPE STANDARD TABLE OF vbpa,
         ls_vbpa      TYPE vbpa,
         lt_xout      LIKE gt_out OCCURS 0 WITH HEADER LINE.

  SORT gt_zfbid_sfa BY bbeln ebelp DESCENDING.
  READ TABLE gt_zfbid_sfa INDEX 1.
  IF sy-subrc = 0.
    lv_ebelp = gt_zfbid_sfa-ebelp.
  ENDIF.

  SORT gt_out  BY kunnr zuonr.
  SORT gt_bsid BY kunnr zuonr.
  SORT gt_zfbid_sfa BY kunnr zuonr.

  IF p_inkas2 IS NOT INITIAL.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE chgrow IS INITIAL.
    IF lt_xout[] IS NOT INITIAL.
      SELECT *
        FROM vbpa
        INTO CORRESPONDING FIELDS OF TABLE lt_vbpa
        FOR ALL ENTRIES IN lt_xout
        WHERE vbeln EQ lt_xout-belnr.
    ENDIF.
  ENDIF.

  LOOP AT gt_out WHERE chgrow = 'X'.
    IF p_inkas2 IS NOT INITIAL.
      LOOP AT lt_vbpa INTO ls_vbpa WHERE vbeln = gt_out-belnr.
        CASE ls_vbpa-parvw.
          WHEN 'VE'.
            MOVE ls_vbpa-pernr TO ls_zfbid_sfa-slcod.
          WHEN 'ZC'.
            MOVE ls_vbpa-kunnr TO ls_zfbid_sfa-parvw.
          WHEN 'ZS'.
            MOVE ls_vbpa-kunnr TO ls_zfbid_sfa-xref3.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    READ TABLE gt_zfbid_sfa WITH KEY kunnr = gt_out-kunnr
                                     zuonr = gt_out-zuonr
                                     bbeln = s_bbeln1-low
                            BINARY SEARCH.
    IF sy-subrc = 0.
      ls_zfbid_sfa = gt_zfbid_sfa.
      IF gt_out-zicon = icon_delete.
        ls_zfbid_sfa-bflag = 'D'.
        ls_zfbid_sfa-zdele = 'X'.
        APPEND ls_zfbid_sfa TO lt_zfbid_sfa.
        CLEAR ls_zfbid_sfa.
      ELSEIF gt_out-zicon IS INITIAL AND
        gt_out-chbox IS NOT INITIAL.
        CLEAR : ls_zfbid_sfa-bflag, ls_zfbid_sfa-zdele.
        APPEND ls_zfbid_sfa TO lt_zfbid_sfa.
        CLEAR ls_zfbid_sfa.
      ENDIF.
    ELSE.
      READ TABLE gt_bsid INTO ls_bsid
                         WITH KEY kunnr = gt_out-kunnr
                                  zuonr = gt_out-zuonr
                         BINARY SEARCH.
      ADD 10 TO lv_ebelp.
      ls_zfbid_sfa-bukrs  = p_vkorg.
      ls_zfbid_sfa-vkbur  = p_vkbur.
      ls_zfbid_sfa-bbeln  = s_bbeln1-low.
      ls_zfbid_sfa-ebelp  = lv_ebelp.
      ls_zfbid_sfa-vbeln  = gt_out-belnr.
      ls_zfbid_sfa-gjahr  = gt_out-bldat(4).
      ls_zfbid_sfa-zuonr  = gt_out-zuonr.
      ls_zfbid_sfa-buzei  = ls_bsid-buzei.
      ls_zfbid_sfa-gsber  = ls_bsid-gsber.
      ls_zfbid_sfa-fkdat  = gt_out-bldat.
      ls_zfbid_sfa-kunnr  = gt_out-kunnr.
      ls_zfbid_sfa-zfbdt  = gt_out-zfbdt.
      ls_zfbid_sfa-wrbtr  = gt_out-wrbtr / 100.
      ls_zfbid_sfa-erdt2  = sy-datum.
      ls_zfbid_sfa-pstat  = 'F'.
      ls_zfbid_sfa-blart  = ls_bsid-blart.
      ls_zfbid_sfa-bldat  = gt_out-bldat.
      ls_zfbid_sfa-belnr  = ls_bsid-belnr.
      ls_zfbid_sfa-dudat  = gt_out-dudat.

      APPEND ls_zfbid_sfa TO lt_zfbid_sfa.
      CLEAR ls_zfbid_sfa.
    ENDIF.
  ENDLOOP.

  IF lt_zfbid_sfa[] IS NOT INITIAL.
    MODIFY zfbid_sfa FROM TABLE lt_zfbid_sfa.
    IF sy-subrc = 0.
      PERFORM f_modify_payment_block TABLES lt_zfbid_sfa.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_ITEM_TABLE_INKASO

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DUEDT
*&---------------------------------------------------------------------*
FORM f_calculate_duedt  USING    fu_zbd1t fu_zfbdt fu_shkzg
                        CHANGING fc_dudat.
  DATA : i_faede TYPE faede,
         e_faede TYPE faede.

  i_faede-shkzg = fu_shkzg.
  i_faede-koart = 'D'.
  i_faede-zfbdt = fu_zfbdt.
  i_faede-zbd1t = fu_zbd1t.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede                    = i_faede
      i_gl_faede                 = 'X'
    IMPORTING
      e_faede                    = e_faede
    EXCEPTIONS
      account_type_not_supported = 1
      OTHERS                     = 2.

  fc_dudat  = e_faede-netdt.
ENDFORM.                    " F_CALCULATE_DUEDT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .
  DATA : lt_xbsid TYPE STANDARD TABLE OF ty_bsid,
         ls_xbsid LIKE LINE OF lt_xbsid,
         lt_xout  LIKE TABLE OF gt_out WITH HEADER LINE,
         ls_xout  LIKE LINE OF lt_xout,
         ls_vout  LIKE LINE OF gt_vout,
         ls_bsid  LIKE LINE OF gt_bsid,
         ls_ebsid TYPE bsid.
  DATA : lv_tabix       TYPE i,
         lv_message(50).

  lt_xbsid[] = gt_bsid[].
  DELETE lt_xbsid WHERE shkzg = 'H'.
  LOOP AT gt_bsid INTO ls_bsid.
    IF ls_bsid-shkzg = 'H'.
      READ TABLE lt_xbsid INTO ls_xbsid
                         WITH KEY kunnr = ls_bsid-kunnr.
      IF sy-subrc <> 0.
        PERFORM f_message_error USING ls_bsid-kunnr ls_bsid-zuonr
                                      'Harap entry DO utk Customer tsb, terlebih dahulu'.
      ELSE.
        PERFORM f_message_error USING ls_bsid-kunnr ls_bsid-zuonr
                                      ''.
      ENDIF.
    ENDIF.
  ENDLOOP.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE zicon = icon_delete.
  LOOP AT gt_out INTO ls_vout.
    IF ls_vout-kunnr IS INITIAL.
      PERFORM f_message_error USING ls_vout-kunnr ls_vout-zuonr 'Nomer DN tidak ada'.
    ELSE.
      CLEAR : ls_xout, lv_tabix.
      LOOP AT lt_xout INTO ls_xout WHERE kunnr = ls_vout-kunnr
                                     AND zuonr = ls_vout-zuonr.
        ADD 1 TO lv_tabix.
      ENDLOOP.
      IF lv_tabix > 1.
        PERFORM f_message_error USING ls_vout-kunnr ls_vout-zuonr 'Double Entry'.
      ENDIF.

* Check Block AR
      SELECT SINGLE * INTO gt_zfh_kr1at
        FROM zfh_kr1at WHERE bukrs     EQ p_vkorg       AND
                             gsber     EQ '0200'        AND
                             vkbur     EQ p_vkbur       AND
                             zuonr     EQ ls_vout-zuonr AND
                             kunnr     EQ ls_vout-kunnr AND
                             belnrpos2 EQ space.
      IF sy-subrc = 0.
        APPEND gt_zfh_kr1at.
        CONCATENATE 'DN terikat FORM3' gt_zfh_kr1at-noform
          INTO lv_message SEPARATED BY space.
        PERFORM f_message_error USING ls_vout-kunnr ls_vout-zuonr lv_message.
      ENDIF.

* Check BI
      SELECT SINGLE * INTO gt_zfbid
        FROM zfbid WHERE bukrs     EQ p_vkorg       AND
                         vkbur     EQ p_vkbur       AND
                         zuonr     EQ ls_vout-zuonr AND
                         kunnr     EQ ls_vout-kunnr AND
                         ( bflag EQ space AND pstat = 'F' ).
      IF sy-subrc = 0.
        APPEND gt_zfbid.
        CONCATENATE 'DN terikat BI' gt_zfbid-bbeln
          INTO lv_message SEPARATED BY space.
        PERFORM f_message_error USING ls_vout-kunnr ls_vout-zuonr lv_message.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MESSAGE_ERROR
*&---------------------------------------------------------------------*
FORM f_message_error  USING    fu_kunnr fu_zuonr fu_message.
  DATA : ls_vout      LIKE LINE OF gt_vout.

  IF fu_message IS INITIAL.
    CLEAR ls_vout-zicon.
  ELSE.
    ls_vout-zicon = icon_booking_stop.
  ENDIF.
  ls_vout-ztext = fu_message.
  MODIFY gt_out FROM ls_vout
                TRANSPORTING zicon ztext
                WHERE kunnr = fu_kunnr
                  AND zuonr = fu_zuonr.
ENDFORM.                    " F_MESSAGE_ERROR
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ZFBIH_SFA_BUKRS  text
*      -->P_GT_ZFBIH_SFA_VKBUR  text
*      -->P_GT_ZFBIH_SFA_BBELN  text
*----------------------------------------------------------------------*
FORM send_email  USING    p_bukrs
                          p_vkbur
                          p_bbeln.

  DATA: send_request   TYPE REF TO cl_bcs,
        lv_sent_to_all TYPE os_boolean,
        mailsubject    TYPE so_obj_des,
        mailtext       TYPE bcsy_text,
        document       TYPE REF TO cl_document_bcs,
        sender         TYPE REF TO cl_cam_address_bcs,
        recipient_to   TYPE REF TO cl_cam_address_bcs,
        recipient_cc   TYPE REF TO cl_cam_address_bcs,
        recipient_bcc  TYPE REF TO cl_cam_address_bcs,
        bcs_exception  TYPE REF TO cx_bcs.
  DATA: lv_message(150).
  DATA: lv_email TYPE ad_smtpadr. " ADR6-SMTP_ADDR.
  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc WITH HEADER LINE.
  TRY.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tvarvc FROM tvarvc WHERE name = 'ZSFAFI_E001'.
      send_request = cl_bcs=>create_persistent( ).
**                1         2         3         4         5
**       12345678901234567890123456789012345678901234567890
**       [TIMOS-Send BI] 8020 - 0240 - 1234567890 to web
**      '[e-Procurement]- Send Tender no. 1234567890 to Web'
      CONCATENATE '[TIMOS-Send BI]' p_bukrs '-' p_vkbur '-' p_bbeln 'To TIMOS' INTO mailsubject SEPARATED BY space.
      "      mailsubject = '[Tempo e-Procurement]-Send Tender to Web'.
      WRITE: / 'Isi Body Message : '.
      CONCATENATE '<br>Company Code-Sales Office-BI no ' p_bukrs '-' p_vkbur '-' p_bbeln '</br>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br>Mohon dikirim ulang dengan menjalankan program/Tcode ZSFAFI_E001 / ZF06SFA </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br>Massukan company Code, Sales Office dan No BI, Pilih Radio Botton Re-Download data to Text File </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br></br><br></br><br>Terima kasih </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      CONCATENATE '<br></br><br></br><br> Email Auto Generated by System </br> <br> </br> <br> </br> <br>' sy-uname  '</br></P>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.

      IF lt_tvarvc[] IS INITIAL.
        lv_message = '<br></br><br></br><br>NB: </br>'.
        APPEND lv_message TO mailtext.
        lv_message = '<br> NB: Penerima email dapat dimaintance di table TVARVC </br>'.
        APPEND lv_message TO mailtext.
        lv_message = '<br>    TVARVC-Name = ZSFAFI_E001 </br>'.
        APPEND lv_message TO mailtext.
        lv_message = '<br>    TVARVC-opti diisi dengan TO/CC/BC </br>'.
        APPEND lv_message TO mailtext.
        lv_message = '<br>    TVARVC-Low diisi dengan email penerima </br>'.
        APPEND lv_message TO mailtext.
      ENDIF.


      document = cl_document_bcs=>create_document(
       i_type = 'HTM'
       i_text = mailtext
       i_subject = mailsubject ).
      send_request->set_document( document ).

      send_request->set_document( document ).
      sender = cl_cam_address_bcs=>create_internet_address( 'Support.Center@TheTempoGroup.com@thetempogroup.com' ).
      send_request->set_sender( sender ).

      LOOP AT lt_tvarvc WHERE opti = 'TO'.
        lv_email = lt_tvarvc-low.
        recipient_to = cl_cam_address_bcs=>create_internet_address( lv_email ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
      ENDLOOP.

      LOOP AT lt_tvarvc WHERE opti = 'CC'.
        lv_email = lt_tvarvc-low.
        recipient_cc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).
      ENDLOOP.

      LOOP AT lt_tvarvc WHERE opti = 'BC'.
        lv_email = lt_tvarvc-low.
        recipient_bcc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_blind_copy = 'X' ).
      ENDLOOP.
      IF lt_tvarvc[] IS INITIAL.
        recipient_to = cl_cam_address_bcs=>create_internet_address( 'Support.Center@TheTempoGroup.com' ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
        recipient_cc = cl_cam_address_bcs=>create_internet_address( 'Fransisca@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).
        recipient_bcc = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_copy = 'X' ).
      ENDIF.

      lv_sent_to_all = send_request->send( ).
      IF lv_sent_to_all = 'X'.
        WRITE: / 'Email sent to all recipients'.
      ELSE.
        WRITE: / 'Email could not be sent to all recipients!'.
      ENDIF.
      COMMIT WORK.

    CATCH cx_bcs INTO bcs_exception.
      WRITE: 'Error occurred while sending email: Error Type', bcs_exception->error_type.

  ENDTRY.


ENDFORM.
