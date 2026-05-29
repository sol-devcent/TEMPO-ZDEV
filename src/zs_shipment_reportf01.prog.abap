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

**Data Changed
    data_changed        FOR EVENT data_changed
                        OF cl_gui_alv_grid
                        IMPORTING er_data_changed
                                  e_onf4
                                  e_onf4_before
                                  e_onf4_after,
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

*Data Changed
  METHOD data_changed.
    PERFORM event_data_changed USING er_data_changed
                                     e_onf4
                                     e_onf4_before
                                     e_onf4_after.
  ENDMETHOD.                    "data_changed

  METHOD top_of_page.                   "implementation
* Top-of-page event
    PERFORM event_top_of_page USING dg_dyndoc_id.
  ENDMETHOD.                            "top_of_page
ENDCLASS.                    "LCL_EVENT_HANDLER IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  event_data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM event_data_changed USING er_data_changed
                              e_onf4
                              e_onf4_before
                              e_onf4_after.                 "#EC *

  DATA: l_text TYPE string.

  CONCATENATE text-001
              text-103 e_onf4
              text-104 e_onf4_before
              text-105 e_onf4_after
              INTO l_text SEPARATED BY space.

  DATA: l_event TYPE lvc_fname.                             "#EC NEEDED

  IF gs_test-info_popup_once EQ 'X'.
    READ TABLE gs_test-events_info_popup INTO l_event
               WITH KEY table_line = 'DATA_CHANGED'.
    IF sy-subrc NE 0.
      INSERT 'DATA_CHANGED' INTO gs_test-events_info_popup INDEX 1.
      MESSAGE i000(0k) WITH l_text.
    ENDIF.
  ELSEIF gs_test-no_info_popup EQ space.
    MESSAGE i000(0k) WITH l_text.
  ENDIF.

*... die Ausgabetabelle ist noch nicht aktualisiert
*    hier sollen semantische Prüfungen zunächst erfolgen über
*      er_data_changed->mt_good_cells
*    Fehler können dann dem Fehlerprotokoll angehängt werden
*      er_data_changed->add_protocol_entry
*    Es darf an dieser Stelle kein Refresh erfolgen!

  PERFORM get_grid_infos.

ENDFORM.                    " event_data_changed

*&---------------------------------------------------------------------*
*&      Form  get_grid_infos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_grid_infos .

  BREAK-POINT.

  DATA: lt_filtered_entries TYPE lvc_t_fidx.                "#EC NEEDED

  g_grid->get_filtered_entries(
    IMPORTING et_filtered_entries = lt_filtered_entries ).

  DATA: lt_filter TYPE lvc_t_filt.                          "#EC NEEDED

  g_grid->get_filter_criteria(
    IMPORTING et_filter = lt_filter ).

  DATA: lt_fcat TYPE lvc_t_fcat.                            "#EC NEEDED

  g_grid->get_frontend_fieldcatalog(
    IMPORTING et_fieldcatalog = lt_fcat ).

  DATA: lt_sort TYPE lvc_t_sort.                            "#EC NEEDED

  g_grid->get_sort_criteria(
    IMPORTING et_sort = lt_sort ).

ENDFORM.                    " get_grid_infos
*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  DATA g_event_handler TYPE REF TO lcl_event_handler.

  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
*  IF g_grid IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat.
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
        it_outtab            = gt_out[]
        it_sort              = gt_sort[].

* Initializing document
*    CALL METHOD dg_dyndoc_id->initialize_document.

* Processing events
*    CALL METHOD g_grid->list_processing_events
*      EXPORTING
*        i_event_name = 'TOP_OF_PAGE'
*        i_dyndoc_id  = dg_dyndoc_id.

* When edit display
*    CALL METHOD g_grid->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

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
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '',
    'TPLST' 'VTTK' 'TPLST' '' '' 'Trans. Plan. Pt' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TDLNR' 'VTTK' 'TDLNR' '' '' 'Vendor' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME_VND' 'LFA1' 'NAME1' '' '' 'Vendor Name' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TKNUM' 'VTTK' 'TKNUM' '' '' 'Shipment' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SHTYP' 'VTTK' 'SHTYP' '' '' 'Shipment Type' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT' 'VTTK' 'ERDAT' '' '' 'Shipping date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET' 'VTTK' 'ERZET' '' '' 'Shipping Time' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STTRG' 'VTTK' 'STTRG' '' '' 'Shipment Status' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EXTI2' 'VTTK' 'EXTI2' '' '' 'No Pol Pick Up Truck' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ROUTE' 'VTTK' 'ROUTE' '' '' 'Route' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LFART' 'LIKP' 'LFART' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'LIKP' 'KUNNR' '' '' 'Cust. Code' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME_CUST' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LZONE' 'KNA1' 'LZONE' '' '' 'TranspZone' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WADAT_IST' 'LIKP' 'WADAT_IST' '' '' 'DN date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'VTTP' 'VBELN' '' '' 'DN Number' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZREASON' 'ZMSHPHIST' 'ZREASON' '' '' 'DN status' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CREXRSDESC' 'ZSEXTRECREAS' 'CREXRSDESC' '' '' 'DN Status description' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CRDAT' 'ZSEXTREC' 'CRDAT' '' '' 'CR2 Date' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CRTIM' 'ZSEXTREC' 'CRTIM' '' '' 'CR2 Time' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZTYPE' 'ZSMATJAS' 'ZJASDESC' '' '' 'Type' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BRGEW' 'VEKP' 'BRGEW' '' '' 'Berat (kg)' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BTVOL' 'VEKP' 'BTVOL' '' '' 'Volume (m3)' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KOLI' 'ZSMATJAS' 'ZJASQTY' '' '' 'Jumlah Koli' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TNDR_MAXP' 'VTTK' 'TNDR_MAXP' '' '' 'Biaya Kirim' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '',
    'TNDR_TRKID' 'VTTK' 'TNDR_TRKID' '' '' 'TrackID' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'COUNT' '' '' '' '6' 'Count' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_emphasize)
                          value(fu_hotspot)
                          value(fu_edit)
                          value(fu_no_zero).

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
*  gs_layout-no_rowmark  = 'X'.
  gs_layout-no_rowmark  = space.
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

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'TPLST'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'TDLNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'TKNUM'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '4'.
  gt_sort-fieldname = 'VBELN'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

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
  DATA : dl_length  TYPE i,                           " Length
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
      LEAVE TO SCREEN 0.
    WHEN '&SALL'.
      PERFORM select_all_checkboxes.
    WHEN '&SAL'.
      PERFORM deselect_all_checkboxes.
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

*  g_grid->get_filtered_entries(
*    IMPORTING et_filtered_entries = lt_filtered_entries ).
*
*  g_grid->get_filter_criteria(
*    IMPORTING et_filter = lt_filter ).
*
*  gt_out-chbox = abap_true.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
*
*  IF lt_filter[] IS NOT INITIAL.
*    LOOP AT lt_filtered_entries INTO ls_filtered_entries.
*      READ TABLE gt_out ASSIGNING <fs_out> INDEX ls_filtered_entries.
*      <fs_out>-chbox = abap_false.
*    ENDLOOP.
*  ENDIF.
*  PERFORM get_grid_infos.
*  gt_out-chbox = abap_true.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
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
*  gt_out-chbox = abap_false.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_true.
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
  gs_variant-variant = pa_vari.
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
  DATA: lt_vttk TYPE TABLE OF vttk WITH HEADER LINE,
        lt_vttp TYPE TABLE OF vttp WITH HEADER LINE,
        lt_likp TYPE TABLE OF likp WITH HEADER LINE.

  CONSTANTS: lc_04 TYPE char2 VALUE '02'.

  SELECT * INTO TABLE gt_vttk
    FROM vttk WHERE tplst EQ p_tplst
                AND shtyp IN s_shtyp
                AND erdat IN s_erdat
                AND erzet IN s_erzet
                AND sttrg IN s_sttrg
                AND tdlnr IN s_tdlnr
                AND tknum IN s_tknum
                AND exti2 IN s_exti2
                AND route IN s_route.

  IF gt_vttk[] IS INITIAL.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ELSE.
    LOOP AT gt_vttk ASSIGNING <fs_vttk>.
      <fs_vttk>-vpobjkey = <fs_vttk>-tknum.
    ENDLOOP.
    SELECT * INTO TABLE gt_vekp
      FROM vekp FOR ALL ENTRIES IN gt_vttk
      WHERE vpobj EQ '04'
        AND vpobjkey EQ gt_vttk-vpobjkey.

    SELECT * INTO TABLE gt_vttp
      FROM vttp FOR ALL ENTRIES IN gt_vttk
      WHERE tknum EQ gt_vttk-tknum.

    SELECT * INTO TABLE gt_zmshphist
      FROM zmshphist FOR ALL ENTRIES IN gt_vttp
      WHERE tknum EQ gt_vttp-tknum
        AND vbeln EQ gt_vttp-vbeln.

    lt_vttk[] = gt_vttk[].
    SORT lt_vttk BY tdlnr.
    DELETE ADJACENT DUPLICATES FROM lt_vttk COMPARING tdlnr.
    IF lt_vttk[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_lfa1
        FROM lfa1 FOR ALL ENTRIES IN lt_vttk
        WHERE lifnr EQ lt_vttk-tdlnr.
    ENDIF.

    lt_vttp[] = gt_vttp[].
    SORT lt_vttp BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING vbeln.
    IF lt_vttp[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_likp
        FROM likp FOR ALL ENTRIES IN lt_vttp
        WHERE vbeln EQ lt_vttp-vbeln.

      SELECT * INTO TABLE gt_zsextrec
        FROM zsextrec FOR ALL ENTRIES IN lt_vttp
        WHERE vbeln EQ lt_vttp-vbeln.
    ENDIF.

    lt_likp[] = gt_likp[].
    SORT lt_likp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
    IF lt_likp[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_kna1
        FROM kna1 FOR ALL ENTRIES IN lt_likp
        WHERE kunnr EQ lt_likp-kunnr.
    ENDIF.

    IF gt_vekp[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_vepo
        FROM vepo FOR ALL ENTRIES IN gt_vekp
        WHERE venum = gt_vekp-venum.
    ENDIF.

*    SELECT * INTO TABLE gt_vepo
*      FROM vepo FOR ALL ENTRIES IN gt_vttp
*      WHERE vbeln = gt_vttp-vbeln.

    IF gt_vepo[] IS NOT INITIAL.
      SORT gt_vepo BY vbeln venum.
      DELETE ADJACENT DUPLICATES FROM gt_vepo COMPARING vbeln venum.
      SELECT * INTO TABLE gt_vekp2
        FROM vekp FOR ALL ENTRIES IN gt_vepo
        WHERE venum = gt_vepo-venum.
    ENDIF.

    SELECT * INTO TABLE gt_zmshphistr
      FROM zmshphistr.

    SELECT * INTO TABLE gt_zsmatjas
      FROM zsmatjas.
  ENDIF.
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
  DATA: lt_vekp  TYPE TABLE OF vekp WITH HEADER LINE,
        lv_lines TYPE int2.

  SORT: gt_vttp BY vbeln tknum,
        gt_vttk BY tknum,
        gt_likp BY vbeln,
        gt_zmshphist BY vbeln tknum zcount DESCENDING,
        gt_vepo BY vbeln.

  LOOP AT gt_vttk.
    LOOP AT gt_vttp WHERE tknum = gt_vttk-tknum.
      CLEAR: gt_lfa1,gt_likp,gt_kna1,gt_zmshphist,gt_zmshphistr,
             gt_zsextrec,gt_vekp,gt_vekp2,gt_vepo,gt_zsmatjas.

*      READ TABLE gt_vttk WITH KEY tknum = gt_vttp-tknum.
      READ TABLE gt_lfa1 WITH KEY lifnr = gt_vttk-tdlnr.
      READ TABLE gt_likp WITH KEY vbeln = gt_vttp-vbeln BINARY SEARCH.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.
      READ TABLE gt_zmshphist WITH KEY vbeln = gt_vttp-vbeln
                                       tknum = gt_vttp-tknum BINARY SEARCH.
      READ TABLE gt_zmshphistr WITH KEY zreason = gt_zmshphist-zreason.
      READ TABLE gt_zsextrec WITH KEY vbeln = gt_vttp-vbeln.
      READ TABLE gt_vekp WITH KEY vpobjkey = gt_vttk-vpobjkey.
      READ TABLE gt_zsmatjas WITH KEY vhilm = gt_vekp-vhilm.
      READ TABLE gt_vepo WITH KEY venum = gt_vekp-venum
                                  vbeln = gt_vttp-vbeln.
      READ TABLE gt_vekp2 WITH KEY venum = gt_vepo-venum.

      gt_out-tplst       = gt_vttk-tplst.
      gt_out-tdlnr       = gt_vttk-tdlnr.
      gt_out-name_vnd    = gt_lfa1-name1.
      gt_out-tknum       = gt_vttp-tknum.
      gt_out-shtyp       = gt_vttk-shtyp.
      gt_out-erdat       = gt_vttk-erdat.
      gt_out-erzet       = gt_vttk-erzet.
      gt_out-sttrg       = gt_vttk-sttrg.
      gt_out-exti2       = gt_vttk-exti2.
      gt_out-route       = gt_vttk-route.
      gt_out-kunnr       = gt_likp-kunnr.
      gt_out-lfart       = gt_likp-lfart.
      gt_out-name_cust   = gt_kna1-name1.
      gt_out-lzone       = gt_kna1-lzone.
      gt_out-wadat_ist   = gt_likp-wadat_ist.
      gt_out-vbeln       = gt_vttp-vbeln.
      gt_out-zreason     = gt_zmshphist-zreason.
      gt_out-crexrsdesc  = gt_zmshphistr-zreason1.
      gt_out-crdat       = gt_zsextrec-crdat.
      gt_out-crtim       = gt_zsextrec-crtim.
      gt_out-ztype       = gt_zsmatjas-zjasdesc.
      gt_out-tndr_maxp   = gt_vttk-tndr_maxp.
      gt_out-tndr_trkid  = gt_vttk-tndr_trkid.

      CASE gt_out-ztype.
        WHEN 'KG' OR 'Kg' OR 'kg'.
          gt_out-brgew   = gt_vekp2-brgew.
        WHEN 'M3' OR 'm3'.
          gt_out-btvol   = gt_vekp2-btvol.
        WHEN 'KOLI' OR 'Koli' OR 'koli'.
          lt_vekp[] = gt_vekp[].
          DELETE lt_vekp WHERE vpobjkey NE gt_vttk-vpobjkey.
          LOOP AT lt_vekp.
            LOOP AT gt_vepo WHERE venum = lt_vekp-venum
                              AND vbeln = gt_vttp-vbeln.
              CLEAR gt_zsmatjas.
              READ TABLE gt_zsmatjas WITH KEY vhilm = lt_vekp-vhilm.
              ADD gt_zsmatjas-zjasqty TO gt_out-koli.
            ENDLOOP.
          ENDLOOP.
      ENDCASE.

      COLLECT gt_out. CLEAR gt_out.

*    IF gt_vekp-inhalt IS NOT INITIAL.
*    PERFORM f_insert_inhalt.
*    ENDIF.
    ENDLOOP.

    PERFORM f_insert_inhalt.
  ENDLOOP.

  SORT gt_out BY tplst tdlnr tknum.
  LOOP AT gt_out ASSIGNING <fs_out>.
    AT NEW tknum.
      CONTINUE.
    ENDAT.

    CLEAR <fs_out>-tndr_maxp.

    CASE <fs_out>-ztype.
      WHEN 'KG' OR 'Kg' OR 'kg'.
        CLEAR <fs_out>-brgew.
      WHEN 'M3' OR 'm3'.
        CLEAR <fs_out>-btvol.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  gt_out-count = 1.
  MODIFY gt_out TRANSPORTING count WHERE count = 0.
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
  CALL SCREEN 100.
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
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'MO1'.
        screen-invisible = '0'.
        screen-input     = '1'.
        MODIFY SCREEN.
      WHEN 'MO2'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN 'MO3'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
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
*  IF s_matnr[] IS INITIAL.
*    MESSAGE 'Please input material number' TYPE 'I'.
*    RETURN.
*  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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
  SET HANDLER g_event_handler->data_changed FOR g_grid.
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
*&      Form  F_INIT_ERZET
*&---------------------------------------------------------------------*
FORM f_init_erzet .
  s_erzet-sign = 'I'.
  s_erzet-option = 'BT'.
  s_erzet-low = '000000'.
  s_erzet-high = '235959'.
  APPEND s_erzet. CLEAR s_erzet.
ENDFORM.                    " F_INIT_ERZET

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_INHALT
*&---------------------------------------------------------------------*
FORM f_insert_inhalt .
  DATA: lt_vekp      TYPE TABLE OF vekp WITH HEADER LINE,
        lt_zmshphist LIKE gt_zmshphist OCCURS 0 WITH HEADER LINE.

  DATA: lv_inhalt1 TYPE char10,
        lv_inhalt2 TYPE char10,
        lv_inhalt3 TYPE char10,
        lv_count   TYPE i,
        lv_no      TYPE numc1.

*gt_vekp-inhalt
  lt_vekp[] = gt_vekp[].
  DELETE lt_vekp WHERE vpobjkey NE gt_vttk-vpobjkey.
  DELETE lt_vekp WHERE inhalt EQ space.

  IF lt_vekp[] IS NOT INITIAL.
    LOOP AT lt_vekp.

      CLEAR: lv_count,lv_no,lv_inhalt1,lv_inhalt2,lv_inhalt3.
      SPLIT lt_vekp-inhalt AT '/' INTO lv_inhalt1
                                       lv_inhalt2
                                       lv_inhalt3.

      IF lv_inhalt3 IS NOT INITIAL.
        lv_count = 3.
      ELSEIF lv_inhalt2 IS NOT INITIAL.
        lv_count = 2.
      ELSE.
        lv_count = 1.
      ENDIF.

      DO lv_count TIMES.
        CLEAR: gt_lfa1,gt_likp,gt_kna1,gt_zsextrec.

        ADD 1 TO lv_no.
        CASE lv_no.
          WHEN 1.
            gt_vttp-vbeln = lv_inhalt1.
          WHEN 2.
            gt_vttp-vbeln = lv_inhalt2.
          WHEN 3.
            gt_vttp-vbeln = lv_inhalt3.
        ENDCASE.
*      gt_vttp-vbeln = lt_vekp-inhalt.

        SELECT SINGLE * INTO gt_lfa1
          FROM lfa1 WHERE lifnr EQ gt_vttk-tdlnr.

        SELECT SINGLE * INTO gt_likp
          FROM likp WHERE vbeln EQ gt_vttp-vbeln.

        SELECT SINGLE * INTO gt_kna1
          FROM kna1 WHERE kunnr EQ gt_likp-kunnr.

        SELECT * INTO TABLE lt_zmshphist
          FROM zmshphist WHERE tknum = gt_vttk-tknum
                           AND vbeln = gt_vttp-vbeln.

        SELECT SINGLE * INTO gt_zsextrec
          FROM zsextrec WHERE vbeln EQ gt_vttp-vbeln.

        SORT lt_zmshphist BY vbeln tknum zcount DESCENDING.
        READ TABLE lt_zmshphist INDEX 1.
        READ TABLE gt_zmshphistr WITH KEY zreason = lt_zmshphist-zreason.
        READ TABLE gt_zsmatjas WITH KEY vhilm = lt_vekp-vhilm.

        gt_out-tplst       = gt_vttk-tplst.
        gt_out-tdlnr       = gt_vttk-tdlnr.
        gt_out-name_vnd    = gt_lfa1-name1.
        gt_out-tknum       = gt_vttk-tknum.
        gt_out-shtyp       = gt_vttk-shtyp.
        gt_out-erdat       = gt_vttk-erdat.
        gt_out-erzet       = gt_vttk-erzet.
        gt_out-sttrg       = gt_vttk-sttrg.
        gt_out-exti2       = gt_vttk-exti2.
        gt_out-route       = gt_vttk-route.
        gt_out-kunnr       = gt_likp-kunnr.
        gt_out-name_cust   = gt_kna1-name1.
        gt_out-lzone       = gt_kna1-lzone.
        gt_out-wadat_ist   = gt_likp-wadat_ist.
        gt_out-vbeln       = gt_vttp-vbeln.
        gt_out-zreason     = lt_zmshphist-zreason.
        gt_out-crexrsdesc  = gt_zmshphistr-zreason1.
        gt_out-crdat       = gt_zsextrec-crdat.
        gt_out-crtim       = gt_zsextrec-crtim.
        gt_out-ztype       = gt_zsmatjas-zjasdesc.
        gt_out-tndr_maxp   = gt_vttk-tndr_maxp.

        CASE gt_out-ztype.
          WHEN 'KG' OR 'Kg' OR 'kg'.
            gt_out-brgew   = gt_vekp-brgew.
          WHEN 'M3' OR 'm3'.
            gt_out-btvol   = gt_vekp-btvol.
          WHEN 'KOLI' OR 'Koli' OR 'koli'.
            gt_out-koli = gt_zsmatjas-zjasqty.
        ENDCASE.

        IF lt_zmshphist-zreason = '54'.
          CLEAR: gt_out-brgew,gt_out-btvol,gt_out-koli.
        ENDIF.

        COLLECT gt_out. CLEAR gt_out.
      ENDDO.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_INSERT_INHALT
