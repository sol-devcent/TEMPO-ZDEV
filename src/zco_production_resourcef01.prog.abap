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

    CASE 'X'.
      WHEN butt1.
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
      WHEN butt2.
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
            it_outtab            = gt_outsum[]
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
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  DATA: lv_field1 TYPE char20,
        lv_field2 TYPE char20,
        lv_text1  TYPE char50,
        lv_text2  TYPE char50,
        lv_count  TYPE char3.

  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN butt1.
      PERFORM f_fieldcatg USING 'GT_OUT':
        'WERKS' 'MKAL' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PLNNR' 'MKAL' 'PLNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MKAL' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ARBPL' 'CRHD' 'ARBPL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ARBID' 'PLPO' 'ARBID' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTXA1' 'PLPO' 'LTXA1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KTEXT' 'CRTX' 'KTEXT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KTEXT_UP' 'CRTX' 'KTEXT_UP' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'CRCO' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*        'LTEXT' 'CSKT' 'LTEXT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MCTXT' 'CSKT' 'MCTXT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VGW02' 'PLPO' 'VGW02' '' '' 'Machine Hour' '' '' '' '' '' '' 'VGE02' '' '' '' '' '' '',
        'VGW03' 'PLPO' 'VGW03' '' '' 'Labor Hour' '' '' '' '' '' '' 'VGE03' '' '' '' '' '' '',
        'VGW04' 'PLPO' 'VGW04' '' '' '# of Labor' '' '' '' '' '' '' 'VGE04' '' '' '' '' '' '',
        'LABOR' 'PLPO' 'VGW02' '' '' 'Labor' '' '' '' '' '' '' 'VGE04' '' '' '' '' '' '',
        'NLABOR' 'PLPO' 'VGW02' '' '' 'Non Labor' '' '' '' '' '' '' 'VGE04' '' '' '' '' '' ''.

    WHEN butt2.
      PERFORM f_fieldcatg USING 'GT_OUTSUM':
        'WERKS' 'MKAL' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PLNNR' 'MKAL' 'PLNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MKAL' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINH' 'PLPO' 'MEINH' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*        'UMREN' 'PLPO' 'UMREN' '' '' '' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '',
        'BMSCH' 'PLPO' 'BMSCH' '' '' '' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '',
        'MKSP' '' '' '' '30' 'Status' '' '' '' '' '' '' '' '' '' '' '' '' ''.

      LOOP AT gt_kostl.
        CLEAR: lv_field1,lv_field2,lv_text1,lv_text2.
        ADD 1 TO lv_count.
        CONDENSE lv_count.
        CONCATENATE 'LABOR' lv_count INTO lv_field1.
        CONCATENATE 'NLABOR' lv_count INTO lv_field2.
*        CONCATENATE 'Labor' gt_kostl-ltext INTO lv_text1 SEPARATED BY space.
*        CONCATENATE 'Non Labor' gt_kostl-ltext INTO lv_text2 SEPARATED BY space.
        CONCATENATE 'Labor' gt_kostl-mctxt INTO lv_text1 SEPARATED BY space.
        CONCATENATE 'Non Labor' gt_kostl-mctxt INTO lv_text2 SEPARATED BY space.

        PERFORM f_fieldcatg USING 'GT_OUTSUM':
          lv_field1 'PLPO' 'VGW03' '' '' lv_text1 '' '' '' '' '' '' '' '' '' '' '' '' '',
          lv_field2 'PLPO' 'VGW02' '' '' lv_text2 '' '' '' '' '' '' '' '' '' '' '' '' ''.
      ENDLOOP.

      PERFORM f_fieldcatg USING 'GT_OUTSUM':
        'LABORTOT' 'PLPO' 'VGW03' '' '' 'Total Labor' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NLABORTOT' 'PLPO' 'VGW02' '' '' 'Total Nonlabor' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
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
  gt_sort-fieldname = 'WERKS'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'PLNNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'MATNR'.
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
*  DATA: lt_filtered_entries TYPE lvc_t_fidx.                "#EC NEEDED
*  DATA: ls_filtered_entries LIKE LINE OF lt_filtered_entries .
*  DATA: lt_filter TYPE lvc_t_filt.                          "#EC NEEDED
*
*  BREAK-POINT.
*
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
**  PERFORM get_grid_infos.
**  gt_out-chbox = abap_true.
**  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
**  CALL METHOD g_grid->refresh_table_display( ).
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
**  CALL METHOD g_grid->refresh_table_display( ).
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
  DATA: lv_kokrs TYPE kokrs,
        lt_crco  TYPE TABLE OF crco WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_mkal
    FROM mkal AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE verid BETWEEN '0000' AND '9999'
      AND plnty EQ '2'
      AND plnnr IN s_plnnr
      AND a~matnr IN s_matnr
      AND werks IN s_werks
      AND mksp  IN s_mksp
      AND b~mtart IN s_mtart.

  IF sy-subrc EQ 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_makt FROM makt
      FOR ALL ENTRIES IN gt_mkal
      WHERE matnr EQ gt_mkal-matnr AND
            spras EQ sy-langu.

    SELECT plnty plnnr plnkn zaehl steus arbid werks ltxa1 pvzkn
           meinh umren umrez vge02 vgw02 vge03 vgw03 vge04 vgw04
           bmsch
      INTO CORRESPONDING FIELDS OF TABLE gt_plpo
      FROM plpo FOR ALL ENTRIES IN gt_mkal
      WHERE plnty EQ gt_mkal-plnty
        AND plnnr EQ gt_mkal-plnnr.

    IF sy-subrc = 0.
      SELECT * INTO TABLE gt_plas
        FROM plas FOR ALL ENTRIES IN gt_plpo
        WHERE plnty = gt_plpo-plnty
          AND plnnr = gt_plpo-plnnr
          AND plnkn = gt_plpo-plnkn
          AND zaehl = gt_plpo-zaehl
          AND loekz = space.

      gt_plpo3[] = gt_plpo2[] = gt_plpo[].
      DELETE gt_plpo  WHERE arbid IS NOT INITIAL.
      DELETE gt_plpo  WHERE vgw04 IS INITIAL.
      DELETE gt_plpo2 WHERE arbid IS INITIAL.
      DELETE gt_plpo3 WHERE steus NE 'ZP02'
                        AND steus NE 'ZP01'.
    ENDIF.

    IF gt_plpo2[] IS NOT INITIAL.
      SELECT objty objid arbpl werks
        INTO CORRESPONDING FIELDS OF TABLE gt_crhd
        FROM crhd FOR ALL ENTRIES IN gt_plpo2
        WHERE objid EQ gt_plpo2-arbid.
    ENDIF.

    IF gt_crhd[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_crtx FROM crtx
        FOR ALL ENTRIES IN gt_crhd
        WHERE objty EQ gt_crhd-objty
          AND objid EQ gt_crhd-objid
          AND spras EQ sy-langu.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_crco FROM crco
        FOR ALL ENTRIES IN gt_crhd
        WHERE objty EQ gt_crhd-objty
          AND objid EQ gt_crhd-objid
          AND endda GE sy-datum
          AND begda LT sy-datum.

      lt_crco[] = gt_crco[].
      SORT lt_crco BY kokrs kostl.
      DELETE ADJACENT DUPLICATES FROM lt_crco COMPARING kokrs kostl.
      IF lt_crco[] IS NOT INITIAL.
        SELECT * INTO TABLE gt_cskt
          FROM cskt FOR ALL ENTRIES IN lt_crco
          WHERE spras = sy-langu
            AND kokrs = lt_crco-kokrs
            AND kostl = lt_crco-kostl.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'GET_DOMAIN_VALUES'
      EXPORTING
        domname    = 'MKSP'
      TABLES
        values_tab = gt_mksp.

    PERFORM f_get_base_quantity.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
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
  SORT: gt_mkal  BY plnnr,
        gt_plpo  BY plnnr pvzkn,
        gt_plpo2 BY plnnr plnkn.

  LOOP AT gt_mkal.
    CLEAR: gt_makt.
    READ TABLE gt_makt WITH KEY matnr = gt_mkal-matnr.

    LOOP AT gt_plpo WHERE plnnr EQ gt_mkal-plnnr.
      READ TABLE gt_plas WITH KEY plnty = gt_plpo-plnty
                                  plnnr = gt_plpo-plnnr
                                  plnkn = gt_plpo-plnkn
                                  zaehl = gt_plpo-zaehl
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      CLEAR: gt_plpo2,gt_crhd,gt_crtx,gt_crco,gt_cskt.

*      IF gt_plpo-arbid IS NOT INITIAL.
      READ TABLE gt_plpo2 WITH KEY plnnr = gt_plpo-plnnr
                                   plnkn = gt_plpo-pvzkn
                                   BINARY SEARCH.
      READ TABLE gt_crhd WITH KEY objid = gt_plpo2-arbid.
      READ TABLE gt_crtx WITH KEY objid = gt_plpo2-arbid.
      READ TABLE gt_crco WITH KEY objid = gt_plpo2-arbid.
      READ TABLE gt_cskt WITH KEY kostl = gt_crco-kostl.

      IF gt_crco-kostl IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.

      <fs_out>-werks   = gt_mkal-werks.
      <fs_out>-plnnr   = gt_mkal-plnnr.
      <fs_out>-matnr   = gt_mkal-matnr.
      <fs_out>-maktx   = gt_makt-maktx.
      <fs_out>-arbpl   = gt_crhd-arbpl.
      <fs_out>-arbid   = gt_plpo2-arbid.
      <fs_out>-ltxa1   = gt_plpo-ltxa1.
      <fs_out>-ktext   = gt_crtx-ktext.
      <fs_out>-ktext_up = gt_crtx-ktext_up.
      <fs_out>-kostl   = gt_crco-kostl.
      <fs_out>-ltext   = gt_cskt-ltext.
      <fs_out>-mctxt   = gt_cskt-mctxt.
      <fs_out>-vge02   = gt_plpo-vge02.
      <fs_out>-vgw02   = gt_plpo-vgw02.
      <fs_out>-vge03   = gt_plpo-vge03.
      <fs_out>-vgw03   = gt_plpo-vgw03.
      <fs_out>-vge04   = gt_plpo-vge04.
      <fs_out>-vgw04   = gt_plpo-vgw04.
      <fs_out>-labor   = gt_plpo-vgw03 * gt_plpo-vgw04 / 60.
      <fs_out>-nlabor  = gt_plpo-vgw02 / 60.
      <fs_out>-meinh   = gt_plpo-meinh.
      <fs_out>-umren   = gt_plpo-umren.
      <fs_out>-umrez   = gt_plpo-umrez.
      <fs_out>-bmsch   = gt_plpo-bmsch.

*      ELSE.
*        IF <fs_out> IS ASSIGNED.
*          <fs_out>-vge02   = gt_plpo-vge02.
*          <fs_out>-vgw02   = <fs_out>-vgw02 + gt_plpo-vgw02.
*          <fs_out>-vge03   = gt_plpo-vge03.
*          <fs_out>-vgw03   = <fs_out>-vgw03 + gt_plpo-vgw03.
*          <fs_out>-vge04   = gt_plpo-vge04.
*          <fs_out>-vgw04   = <fs_out>-vgw04 + gt_plpo-vgw04.
*        ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CASE 'X'.
    WHEN butt1.
    WHEN butt2.
      PERFORM f_process_summary.
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
  IF s_matnr[] IS INITIAL.
    MESSAGE 'Please input material number' TYPE 'I'.
    RETURN.
  ENDIF.
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
*&      Form  F_PROCESS_SUMMARY
*&---------------------------------------------------------------------*
FORM f_process_summary .
  DATA: lv_lines  TYPE int1,
        lv_nomor  TYPE char3,
        lv_field1 TYPE char20,
        lv_field2 TYPE char20.

  FIELD-SYMBOLS: <fs_field1> TYPE ANY,
                 <fs_field2> TYPE ANY.

  LOOP AT gt_out ASSIGNING <fs_out>.
    READ TABLE gt_outsum ASSIGNING <fs_outsum>
                         WITH KEY werks  = <fs_out>-werks
                                  plnnr  = <fs_out>-plnnr
                                  matnr  = <fs_out>-matnr.

    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gt_outsum ASSIGNING <fs_outsum>.
      <fs_outsum>-werks  = <fs_out>-werks.
      <fs_outsum>-plnnr  = <fs_out>-plnnr.
      <fs_outsum>-matnr  = <fs_out>-matnr.
      <fs_outsum>-maktx  = <fs_out>-maktx.
    ENDIF.

    READ TABLE gt_kostl WITH KEY kostl = <fs_out>-kostl.
    IF sy-subrc = 0.
      lv_nomor = gt_kostl-nomor.
    ELSE.
      IF gt_kostl[] IS INITIAL.
        CLEAR lv_nomor.
      ELSE.
        DESCRIBE TABLE gt_kostl LINES lv_lines.
        READ TABLE gt_kostl INDEX lv_lines.
        lv_nomor = gt_kostl-nomor.
      ENDIF.
      ADD 1 TO lv_nomor.
      CONDENSE lv_nomor.
      gt_kostl-nomor = lv_nomor.
      gt_kostl-kostl = <fs_out>-kostl.
      gt_kostl-ltext = <fs_out>-ltext.
      gt_kostl-mctxt = <fs_out>-mctxt.
      APPEND gt_kostl.
    ENDIF.

    CLEAR: lv_field1,lv_field2.
    UNASSIGN: <fs_field1>,<fs_field2>.
    CONCATENATE '<FS_OUTSUM>-LABOR' lv_nomor INTO lv_field1.
    ASSIGN (lv_field1) TO <fs_field1>.
    CONCATENATE '<FS_OUTSUM>-NLABOR' lv_nomor INTO lv_field2.
    ASSIGN (lv_field2) TO <fs_field2>.

    ADD <fs_out>-labor  TO <fs_field1>.
    ADD <fs_out>-nlabor TO <fs_field2>.
    ADD <fs_out>-labor  TO <fs_outsum>-labortot.
    ADD <fs_out>-nlabor TO <fs_outsum>-nlabortot.
  ENDLOOP.

  LOOP AT gt_outsum ASSIGNING <fs_outsum>.
    PERFORM f_get_umren USING    <fs_outsum>-plnnr
                        CHANGING <fs_outsum>-meinh
                                 <fs_outsum>-umren
                                 <fs_outsum>-bmsch.
    PERFORM f_get_mksp  USING    <fs_outsum>-werks
                                 <fs_outsum>-matnr
                                 <fs_outsum>-plnnr
                        CHANGING <fs_outsum>-mksp.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_GET_UMREN
*&---------------------------------------------------------------------*
FORM f_get_umren  USING    fu_plnnr
                  CHANGING fc_meinh
                           fc_umren
                           fc_bmsch.

  DATA : ls_plmz    LIKE LINE OF gt_plmz,
         ls_stko    LIKE LINE OF gt_stko.

  SORT gt_plpo3 BY plnty plnnr plnkn DESCENDING.
  CLEAR gt_plpo3.
  READ TABLE gt_plpo3 WITH KEY plnnr = fu_plnnr.
*                               steus = 'ZP02'.
  fc_meinh = gt_plpo3-meinh.
  fc_umren = gt_plpo3-umren.
  fc_bmsch = gt_plpo3-bmsch.

  CLEAR ls_plmz.
  READ TABLE gt_plmz INTO ls_plmz
                     WITH KEY plnnr = fu_plnnr.
  IF sy-subrc = 0.
    CLEAR ls_stko.
    READ TABLE gt_stko INTO ls_stko
                       WITH KEY stlty = ls_plmz-stlty
                                stlnr = ls_plmz-stlnr
                                stlal = ls_plmz-stlal.
    IF sy-subrc = 0.
      fc_meinh  = ls_stko-bmein.
      fc_bmsch  = ls_stko-bmeng.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_UMREN

*&---------------------------------------------------------------------*
*&      Form  F_GET_MKSP
*&---------------------------------------------------------------------*
FORM f_get_mksp  USING    fu_werks
                          fu_matnr
                          fu_plnnr
                 CHANGING fc_mksp.
  CLEAR: gt_mkal,gt_mksp.
  READ TABLE gt_mkal WITH KEY matnr = fu_matnr
                              werks = fu_werks
                              plnnr = fu_plnnr.
  READ TABLE gt_mksp WITH KEY domvalue_l(1) = gt_mkal-mksp.
  fc_mksp = gt_mksp-ddtext.
ENDFORM.                    " F_GET_MKSP

*&---------------------------------------------------------------------*
*&      Form  F_GET_BASE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_get_base_quantity .
  IF butt2 IS NOT INITIAL.
    IF gt_mkal[] IS NOT INITIAL.
      SELECT plnty plnnr stlty stlnr stlal
        FROM plmz
        INTO CORRESPONDING FIELDS OF TABLE gt_plmz
        FOR ALL ENTRIES IN gt_mkal
        WHERE plnty = gt_mkal-plnty
          AND plnnr = gt_mkal-plnnr.

      IF gt_plmz[] IS NOT INITIAL.
        SELECT stlty stlnr stlal bmein bmeng
          FROM stko
          INTO CORRESPONDING FIELDS OF TABLE gt_stko
          FOR ALL ENTRIES IN gt_plmz
          WHERE stlty = gt_plmz-stlty
            AND stlnr = gt_plmz-stlnr
            AND stlal = gt_plmz-stlal
            AND stlst NE '2'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BASE_QUANTITY
