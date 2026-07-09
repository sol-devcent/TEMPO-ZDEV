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

  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
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
  DATA: ld_fieldname TYPE lvc_fname,
        ld_reptext   TYPE reptext,
        ld_count     TYPE numc2,
        ld_do        TYPE int3.

  CLEAR: gt_fieldcat[],ld_count.

  PERFORM f_fieldcatg USING 'GT_OUT':
    'WERKS' 'MAPL' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'MTART' 'MARA' 'MTART' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PLNNR' 'MAPL' 'PLNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STATS' '' '' '' '10' 'Status' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BMSCH' 'PLPO' 'BMSCH' '' '' 'Lot Size' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'BSTFE' 'MARC' 'BSTFE' '' '' 'Lot Size' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'UMREN' 'PLPO' 'UMREN' '' '' 'Lot Size' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINH' 'PLPO' 'MEINH' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

  CASE p_werks.
    WHEN '0101'.
      ld_do = 22.
    WHEN '0102'.
      ld_do = 20.
  ENDCASE.

  DO ld_do TIMES.
    CLEAR: ld_fieldname,ld_reptext.

    ADD 1 TO ld_count.
    CONCATENATE 'VGW' ld_count INTO ld_fieldname.

    PERFORM f_reptext USING p_werks ld_count
                      CHANGING ld_reptext.

    PERFORM f_fieldcatg USING 'GT_OUT':
      ld_fieldname 'PLPO' 'VGW03' '' '' ld_reptext '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' ''.
  ENDDO.

  PERFORM f_fieldcatg USING 'GT_OUT':
    'VGW99' 'PLPO' 'VGW03' '' '' 'Total Labor' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
    'VGW00' 'PLPO' 'VGW03' '' '' 'Total NonLabor' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' ''.
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
                          value(fu_no_zero)
                          value(fu_key).

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
  ld_fieldcat-key               = fu_key.
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
  gt_sort-fieldname = 'WERKS'.
  APPEND gt_sort.

  CLEAR gt_sort.
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
    WHEN '&ALL'.
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
  gt_out-chbox = abap_true.
  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
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
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE p_werks.
    WHEN '0101'.
    WHEN '0102'.
    WHEN OTHERS.
      MESSAGE 'For Plant 0101 & 0102 Only' TYPE 'I'.
      RETURN.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  gv_repid = sy-repid.
  gs_variant-report = gv_repid.
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
  DATA: lt_mkal LIKE gt_mkal OCCURS 0 WITH HEADER LINE.

  SELECT a~matnr werks verid bdatu adatu stlal stlan plnty plnnr alnal
         beskz sobsl bstmi bstma rgekz alort pltyg plnng alnag pltym
         plnnm alnam csplt mksp	b~mtart
    FROM mkal AS a JOIN mara AS b ON a~matnr = b~matnr
    INTO CORRESPONDING FIELDS OF TABLE gt_mkal
    WHERE a~matnr IN s_matnr
      AND werks   EQ p_werks
      AND plnnr   IN s_plnnr
      AND mksp    IN s_mksp
      AND mtart   IN s_mtart.

  IF sy-subrc = 0.
    lt_mkal[] = gt_mkal[].
    SORT lt_mkal BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mkal COMPARING matnr.
    SELECT * INTO TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN lt_mkal
      WHERE matnr = lt_mkal-matnr
        AND spras = sy-langu.

    lt_mkal[] = gt_mkal[].
    SORT lt_mkal BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM lt_mkal COMPARING matnr werks.
    SELECT matnr werks fevor bstfe
      INTO CORRESPONDING FIELDS OF TABLE gt_marc
      FROM marc FOR ALL ENTRIES IN lt_mkal
      WHERE matnr = lt_mkal-matnr
        AND werks = lt_mkal-werks.

    lt_mkal[] = gt_mkal[].
    SORT lt_mkal BY plnty plnnr.
    DELETE ADJACENT DUPLICATES FROM lt_mkal COMPARING plnty plnnr.
    SELECT plnty plnnr plnkn zaehl loekz umren meinh steus phseq vgw02
           vgw03 vgw04 bmsch ltxa1
      INTO CORRESPONDING FIELDS OF TABLE gt_plpo
      FROM plpo FOR ALL ENTRIES IN lt_mkal
      WHERE plnty = lt_mkal-plnty
        AND plnnr = lt_mkal-plnnr
        AND loekz = space.

    IF gt_plpo[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_plas
        FROM plas FOR ALL ENTRIES IN gt_plpo
        WHERE plnty = gt_plpo-plnty
          AND plnnr = gt_plpo-plnnr
          AND plnkn = gt_plpo-plnkn
          AND zaehl = gt_plpo-zaehl
          AND loekz = space.
    ENDIF.

  ELSE.
    MESSAGE 'No Data' TYPE 'S'.
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
  DATA: lv_ltxa1 LIKE plpo-ltxa1.

  SORT gt_mkal BY plnty plnnr matnr.
  SORT gt_plpo BY plnty plnnr.

  LOOP AT gt_mkal.
    CLEAR: gt_marc,gt_makt.
    READ TABLE gt_marc WITH KEY matnr = gt_mkal-matnr
                                werks = gt_mkal-werks.
    READ TABLE gt_makt WITH KEY matnr = gt_mkal-matnr.

    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.

    <fs_out>-werks = gt_mkal-werks.
    <fs_out>-matnr = gt_mkal-matnr.
    <fs_out>-maktx = gt_makt-maktx.
    <fs_out>-mtart = gt_mkal-mtart.
    <fs_out>-plnnr = gt_mkal-plnnr.
    CASE gt_mkal-mksp.
      WHEN space.
        <fs_out>-stats = 'Not locked'.
      WHEN '1'.
        <fs_out>-stats = 'Locked'.
    ENDCASE.

    <fs_out>-bstfe = gt_marc-bstfe.

    LOOP AT gt_plpo WHERE plnty = gt_mkal-plnty
                      AND plnnr = gt_mkal-plnnr.

      READ TABLE gt_plas WITH KEY plnty = gt_plpo-plnty
                                  plnnr = gt_plpo-plnnr
                                  plnkn = gt_plpo-plnkn
                                  zaehl = gt_plpo-zaehl
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

*      IF gt_plpo-steus = 'ZP02'.
*      IF gt_plpo-phseq = 'S1'.
*      IF gt_plpo-ltxa1 = 'Goods Receipt'.
      lv_ltxa1 = gt_plpo-ltxa1.
      TRANSLATE lv_ltxa1 TO UPPER CASE.
      IF lv_ltxa1 = gc_good_receipt OR lv_ltxa1 = gc_goods_receipt.
        <fs_out>-umren = gt_plpo-umren.
        <fs_out>-meinh = gt_plpo-meinh.
        <fs_out>-bmsch = gt_plpo-bmsch.
      ENDIF.

      CASE p_werks.
        WHEN '0101'.
          PERFORM f_hit_0101.
        WHEN '0102'.
          PERFORM f_hit_0102.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
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
*&      Form  F_HIT_0101
*&---------------------------------------------------------------------*
FORM f_hit_0101 .
  DATA: lv_ok TYPE flag.

  CASE gt_plpo-steus(2).
    WHEN 'ZP'.
      CASE gt_plpo-phseq(1).
        WHEN 'W'.
          "Weighing (1010802 ) Labor
          <fs_out>-vgw01 = <fs_out>-vgw01 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Weighing (1010802 ) NonLabor
          <fs_out>-vgw02 = <fs_out>-vgw02 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'D' OR 'G'.
          "Mixing Solid (1010803) Labor
          <fs_out>-vgw03 = <fs_out>-vgw03 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Mixing Solid (1010803) NonLabor
          <fs_out>-vgw04 = <fs_out>-vgw04 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'T'.
          "Tableting (1010804) Solid Labor
          <fs_out>-vgw05 = <fs_out>-vgw05 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Tableting (1010804) NonLabor
          <fs_out>-vgw06 = <fs_out>-vgw06 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'C'.
          "Coating Solid (1010805) Labor
          <fs_out>-vgw07 = <fs_out>-vgw07 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Coating Solid (1010805) NonLabor
          <fs_out>-vgw08 = <fs_out>-vgw08 + ( gt_plpo-vgw02 / 60 ).
*            WHEN 'P'.
*              IF gt_marc-fevor = 'SOL'.
*                "Pack Primer Solid (1010806) Labor
*                <fs_out>-vgw09 = <fs_out>-vgw09 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
*                "Pack Primer Solid (1010806) NonLabor
*                <fs_out>-vgw10 = <fs_out>-vgw10 + ( gt_plpo-vgw02 / 60 ).
*              ENDIF.
        WHEN 'S'.
          "Pack Secondary (1010807) Labor
          <fs_out>-vgw11 = <fs_out>-vgw11 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Pack Secondary (1010807) NonLabor
          <fs_out>-vgw12 = <fs_out>-vgw12 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'O'.
          "Mixing Semi Solid (1010808) Labor
          <fs_out>-vgw13 = <fs_out>-vgw13 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Mixing Semi Solid (1010808) NonLabor
          <fs_out>-vgw14 = <fs_out>-vgw14 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'P'.
          IF gt_marc-fevor = 'SSD'.
            "Pack Prm Semi Solid (1010809) Labor
            <fs_out>-vgw15 = <fs_out>-vgw15 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Pack Prm Semi Solid (1010809) NonLabor
            <fs_out>-vgw16 = <fs_out>-vgw16 + ( gt_plpo-vgw02 / 60 ).
          ELSEIF gt_marc-fevor = 'LQD'.
            "Pack Primr Liquid (1010811) Labor
            <fs_out>-vgw19 = <fs_out>-vgw19 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Pack Primr Liquid (1010811) NonLabor
            <fs_out>-vgw20 = <fs_out>-vgw20 + ( gt_plpo-vgw02 / 60 ).
          ELSEIF gt_marc-fevor = 'SOL'.
            "Pack Primer Solid (1010806) Labor
            <fs_out>-vgw09 = <fs_out>-vgw09 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Pack Primer Solid (1010806) NonLabor
            <fs_out>-vgw10 = <fs_out>-vgw10 + ( gt_plpo-vgw02 / 60 ).
          ELSEIF gt_marc-fevor = 'OTH'.
            "Pack Primer Solid (1010806) Labor
            <fs_out>-vgw09 = <fs_out>-vgw09 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Pack Primer Solid (1010806) NonLabor
            <fs_out>-vgw10 = <fs_out>-vgw10 + ( gt_plpo-vgw02 / 60 ).
          ENDIF.
        WHEN 'L'.
          "Mixing Liquid (1010810) Labor
          <fs_out>-vgw17 = <fs_out>-vgw17 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Mixing Liquid (1010810) NonLabor
          <fs_out>-vgw18 = <fs_out>-vgw18 + ( gt_plpo-vgw02 / 60 ).
      ENDCASE.
    WHEN 'ZQ'.
      "IPC (1010816) Labor
      <fs_out>-vgw21 = <fs_out>-vgw21 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
      "IPC (1010816) NonLabor
      <fs_out>-vgw22 = <fs_out>-vgw22 + ( gt_plpo-vgw02 / 60 ).
  ENDCASE.

  <fs_out>-vgw99 = <fs_out>-vgw01 + <fs_out>-vgw03 + <fs_out>-vgw05 +
                   <fs_out>-vgw07 + <fs_out>-vgw09 + <fs_out>-vgw11 + <fs_out>-vgw13 +
                   <fs_out>-vgw15 + <fs_out>-vgw17 + <fs_out>-vgw19 + <fs_out>-vgw21.
  <fs_out>-vgw00 = <fs_out>-vgw02 + <fs_out>-vgw04 + <fs_out>-vgw06 +
                   <fs_out>-vgw08 + <fs_out>-vgw10 + <fs_out>-vgw12 + <fs_out>-vgw14 +
                   <fs_out>-vgw16 + <fs_out>-vgw18 + <fs_out>-vgw20 + <fs_out>-vgw22.
ENDFORM.                    " F_HIT_0101

*&---------------------------------------------------------------------*
*&      Form  F_HIT_0102
*&---------------------------------------------------------------------*
FORM f_hit_0102 .
  CASE gt_plpo-steus(2).
    WHEN 'ZP'.
      CASE gt_plpo-phseq(1).
        WHEN 'W'.
          "Weighing (1010802 ) Labor
          <fs_out>-vgw01 = <fs_out>-vgw01 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Weighing (1010802 ) NonLabor
          <fs_out>-vgw02 = <fs_out>-vgw02 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'D' OR 'G'.
          IF gt_marc-fevor = 'EFF'.
            "Mixing Powder (1020803) Labor
            <fs_out>-vgw03 = <fs_out>-vgw03 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Mixing Powder (1020803) NonLabor
            <fs_out>-vgw04 = <fs_out>-vgw04 + ( gt_plpo-vgw02 / 60 ).
          ELSEIF gt_marc-fevor = 'CAP' OR gt_marc-fevor = 'SFI' OR
            gt_marc-fevor = 'SOL'.
            "Mixing Capsule (1020805) Labor
            <fs_out>-vgw07 = <fs_out>-vgw07 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Mixing Capsule (1020805) NonLabor
            <fs_out>-vgw08 = <fs_out>-vgw08 + ( gt_plpo-vgw02 / 60 ).
          ENDIF.
        WHEN 'P'.
          IF gt_marc-fevor = 'EFF'.
            "Sacheting (1020804) Solid Labor
            <fs_out>-vgw05 = <fs_out>-vgw05 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Sacheting (1020804) NonLabor
            <fs_out>-vgw06 = <fs_out>-vgw06 + ( gt_plpo-vgw02 / 60 ).
          ELSEIF gt_marc-fevor = 'CAP' OR gt_marc-fevor = 'SFI' OR
            gt_marc-fevor = 'SOL'.
            "Packaging Primer (1020807) Labor
            <fs_out>-vgw11 = <fs_out>-vgw11 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
            "Packaging Primer (1020807) NonLabor
            <fs_out>-vgw12 = <fs_out>-vgw12 + ( gt_plpo-vgw02 / 60 ).
          ENDIF.
        WHEN 'F'.
          "Filling Capsule (1020806) Labor
          <fs_out>-vgw09 = <fs_out>-vgw09 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Filling Capsule (1020806) NonLabor
          <fs_out>-vgw10 = <fs_out>-vgw10 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'O'.
          "Packaging Secondary (1020808) Labor
          <fs_out>-vgw13 = <fs_out>-vgw13 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Packaging Secondary (1020808) NonLabor
          <fs_out>-vgw14 = <fs_out>-vgw14 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'S'.
*          IF gt_marc-fevor = 'CAP'.
*            "Packaging Primer (1020807) Labor
*            <fs_out>-vgw11 = <fs_out>-vgw11 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
*            "Packaging Primer (1020807) NonLabor
*            <fs_out>-vgw12 = <fs_out>-vgw12 + ( gt_plpo-vgw02 / 60 ).
          "Packaging Secondary (1020808) Labor
          <fs_out>-vgw13 = <fs_out>-vgw13 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Packaging Secondary (1020808) NonLabor
          <fs_out>-vgw14 = <fs_out>-vgw14 + ( gt_plpo-vgw02 / 60 ).
*          ENDIF.
        WHEN 'T'.
          "Tableting (1020810) Solid Labor
          <fs_out>-vgw15 = <fs_out>-vgw15 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Tableting (1020810) NonLabor
          <fs_out>-vgw16 = <fs_out>-vgw16 + ( gt_plpo-vgw02 / 60 ).
        WHEN 'C'.
          "Coating Solid (1020811) Labor
          <fs_out>-vgw17 = <fs_out>-vgw17 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
          "Coating Solid (1020811) NonLabor
          <fs_out>-vgw18 = <fs_out>-vgw18 + ( gt_plpo-vgw02 / 60 ).
      ENDCASE.
    WHEN 'ZQ'.
      "IPC (1010816) Labor
      <fs_out>-vgw19 = <fs_out>-vgw19 + ( gt_plpo-vgw03 / 60 * gt_plpo-vgw04 ).
      "IPC (1010816) NonLabor
      <fs_out>-vgw20 = <fs_out>-vgw20 + ( gt_plpo-vgw02 / 60 ).
  ENDCASE.

  <fs_out>-vgw99 = <fs_out>-vgw01 + <fs_out>-vgw03 + <fs_out>-vgw05 + <fs_out>-vgw07 +
                   <fs_out>-vgw09 + <fs_out>-vgw11 + <fs_out>-vgw13 + <fs_out>-vgw15 +
                   <fs_out>-vgw17 + <fs_out>-vgw19.
  <fs_out>-vgw00 = <fs_out>-vgw02 + <fs_out>-vgw04 + <fs_out>-vgw06 + <fs_out>-vgw08 +
                   <fs_out>-vgw10 + <fs_out>-vgw12 + <fs_out>-vgw14 + <fs_out>-vgw16 +
                   <fs_out>-vgw18 + <fs_out>-vgw20.
ENDFORM.                    " F_HIT_0102

*&---------------------------------------------------------------------*
*&      Form  F_REPTEXT
*&---------------------------------------------------------------------*
FORM f_reptext  USING    fu_werks
                         fu_count
                CHANGING fc_reptext.
  CASE fu_werks.
    WHEN '0101'.
      CASE fu_count.
        WHEN '01'.
          fc_reptext = 'Weighing Labor'.
        WHEN '02'.
          fc_reptext = 'Weighing NonLabor'.
        WHEN '03'.
          fc_reptext = 'Mixing Solid Labor'.
        WHEN '04'.
          fc_reptext = 'Mixing Solid NonLabor'.
        WHEN '05'.
          fc_reptext = 'Tableting Labor'.
        WHEN '06'.
          fc_reptext = 'Tableting NonLabor'.
        WHEN '07'.
          fc_reptext = 'Coating Solid Labor'.
        WHEN '08'.
          fc_reptext = 'Coating Solid NonLabor'.
        WHEN '09'.
          fc_reptext = 'Pack Primer Solid Labor'.
        WHEN '10'.
          fc_reptext = 'Pack Primer Solid NonLabor'.
        WHEN '11'.
          fc_reptext = 'Pack Secondary Labor'.
        WHEN '12'.
          fc_reptext = 'Pack Secondary NonLabor'.
        WHEN '13'.
          fc_reptext = 'Mixing Semi Solid Labor'.
        WHEN '14'.
          fc_reptext = 'Mixing Semi Solid NonLabor'.
        WHEN '15'.
          fc_reptext = 'Pack Prm Semi Solid Labor'.
        WHEN '16'.
          fc_reptext = 'Pack Prm Semi Solid NonLabor'.
        WHEN '17'.
          fc_reptext = 'Mixing Liquid Labor'.
        WHEN '18'.
          fc_reptext = 'Mixing Liquid NonLabor'.
        WHEN '19'.
          fc_reptext = 'Pack Primr Liquid Labor'.
        WHEN '20'.
          fc_reptext = 'Pack Primr Liquid NonLabor'.
        WHEN '21'.
          fc_reptext = 'IPC Labor'.
        WHEN '22'.
          fc_reptext = 'IPC NonLabor'.
      ENDCASE.
    WHEN '0102'.
      CASE fu_count.
        WHEN '01'.
          fc_reptext = 'Weighing Labor'.
        WHEN '02'.
          fc_reptext = 'Weighing NonLabor'.
        WHEN '03'.
          fc_reptext = 'Mixing Powder Labor'.
        WHEN '04'.
          fc_reptext = 'Mixing Powder NonLabor'.
        WHEN '05'.
          fc_reptext = 'Sacheting Labor'.
        WHEN '06'.
          fc_reptext = 'Sacheting NonLabor'.
        WHEN '07'.
          fc_reptext = 'Mixing Capsule Labor'.
        WHEN '08'.
          fc_reptext = 'Mixing Capsule NonLabor'.
        WHEN '09'.
          fc_reptext = 'Filling Capsule Labor'.
        WHEN '10'.
          fc_reptext = 'Filling Capsule NonLabor'.
        WHEN '11'.
          fc_reptext = 'Packaging Primer Labor'.
        WHEN '12'.
          fc_reptext = 'Packaging Primer NonLabor'.
        WHEN '13'.
          fc_reptext = 'Packaging Secondary Labor'.
        WHEN '14'.
          fc_reptext = 'Packaging Secondary NonLabor'.
        WHEN '15'.
          fc_reptext = 'Tableting Labor'.
        WHEN '16'.
          fc_reptext = 'Tableting NonLabor'.
        WHEN '17'.
          fc_reptext = 'Coating Solid Labor'.
        WHEN '18'.
          fc_reptext = 'Coating Solid NonLabor'.
        WHEN '19'.
          fc_reptext = 'IPC Labor'.
        WHEN '20'.
          fc_reptext = 'IPC NonLabor'.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_REPTEXT
