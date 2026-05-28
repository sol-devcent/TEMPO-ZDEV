*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E004F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHART_CONTAINER
*&---------------------------------------------------------------------*
FORM chart_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_CHART'.

  IF g_chartcont IS INITIAL.
    CREATE OBJECT g_chartcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitchart
      EXPORTING
        parent  = g_chartcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitchart->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_chartcontain.
  ENDIF.
ENDFORM.                    " CHART_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_CHART
*&---------------------------------------------------------------------*
FORM f_display_chart .

* Bind the container to the object.
  IF g_chart IS INITIAL.
    CREATE OBJECT g_chart
      EXPORTING
        parent = g_chartcontain.

    CREATE OBJECT event_receiver.

    gv_caption   = gs_head-maktx.
    gv_dimension = 'PseudoThree'.
    gv_chartyp   = 'Pie'.
    gv_times     = 1.

*    lo_ixml = cl_ixml=>create( ).
*    lo_ixml_sf = lo_ixml->create_stream_factory( ).
*  ENDIF.

    CLEAR lo_xstr.
* Create XML data using data in internal table.
    PERFORM f_create_xml USING lo_ixml_data.
    lo_ostream = lo_ixml_sf->create_ostream_xstring( lo_xstr ).

* Render Chart Data
    CALL METHOD lo_ixml_data->render
      EXPORTING
        ostream = lo_ostream.

    g_chart->set_data( xdata = lo_xstr ).

    CLEAR lo_xstr.
* Create the customizing the chart
    PERFORM f_global_setting USING lo_ixml_custm.
    lo_ostream = lo_ixml_sf->create_ostream_xstring( lo_xstr ).

* Render Customizing Data
    CALL METHOD lo_ixml_custm->render
      EXPORTING
        ostream = lo_ostream.

    g_chart->set_customizing( xdata = lo_xstr ).
  ENDIF.

* Render the Graph Object.
  CALL METHOD g_chart->render.
ENDFORM.                    " F_DISPLAY_CHART

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_XML
*&---------------------------------------------------------------------*
FORM f_create_xml  USING    fu_ixml TYPE REF TO if_ixml_document.
  DATA : lo_simplechartdata TYPE REF TO if_ixml_element,
         lo_categories      TYPE REF TO if_ixml_element,
         lo_series          TYPE REF TO if_ixml_element,
         lo_element         TYPE REF TO if_ixml_element,
         lo_encoding        TYPE REF TO if_ixml_encoding.

  PERFORM f_create_xml_chart USING fu_ixml
                                   lo_simplechartdata
                                   lo_encoding.

  PERFORM f_create_categories USING fu_ixml
                                    lo_simplechartdata
                                    lo_categories
                                    lo_element.

  PERFORM f_create_series USING fu_ixml
                                lo_simplechartdata
                                lo_series
                                lo_element.
ENDFORM.                    " F_CREATE_XML

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_XML_CHART
*&---------------------------------------------------------------------*
FORM f_create_xml_chart  USING    fu_ixml            TYPE REF TO if_ixml_document
                                  fu_simplechartdata TYPE REF TO if_ixml_element
                                  fu_encoding        TYPE REF TO if_ixml_encoding.

  fu_ixml = lo_ixml->create_document( ).

* Set encoding to UTF-8
  fu_encoding = lo_ixml->create_encoding(
    byte_order = if_ixml_encoding=>co_little_endian
    character_set = 'utf-8' ).
  fu_ixml->set_encoding( fu_encoding ).

* Populate Chart Data
  fu_simplechartdata = fu_ixml->create_simple_element(
    name = 'SimpleChartData'
    parent = fu_ixml ).
ENDFORM.                    " F_CREATE_XML_CHART

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CATEGORIES
*&---------------------------------------------------------------------*
FORM f_create_categories  USING    fu_ixml            TYPE REF TO if_ixml_document
                                   fu_simplechartdata TYPE REF TO if_ixml_element
                                   fu_categories      TYPE REF TO if_ixml_element
                                   fu_element         TYPE REF TO if_ixml_element.

  DATA : ld_value TYPE string,
         ld_char(10).

  FIELD-SYMBOLS : <fs>    TYPE ANY.

* Create an element for Categories label (X-axis)
  fu_categories = fu_ixml->create_simple_element(
    name = 'Categories'
    parent = fu_simplechartdata ).

  LOOP AT <fs_graph> ASSIGNING <fs_sgraph>.
    CLEAR ld_value.
    fu_element = fu_ixml->create_simple_element(
      name = 'C'
      parent = fu_categories ).

    ASSIGN COMPONENT 'CATEGORY' OF STRUCTURE <fs_sgraph> TO <fs>.
    ld_value = <fs>.
    fu_element->if_ixml_node~set_value( ld_value ).
  ENDLOOP.
ENDFORM.                    " F_CREATE_CATEGORIES

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SERIES
*&---------------------------------------------------------------------*
FORM f_create_series  USING    fu_ixml TYPE REF TO if_ixml_document
                               fu_simplechartdata  TYPE REF TO if_ixml_element
                               fu_series           TYPE REF TO if_ixml_element
                               fu_element          TYPE REF TO if_ixml_element.

  DATA: lv_value      TYPE string,
        lv_index      TYPE numc2,
        lv_fieldname  TYPE char30.

  FIELD-SYMBOLS : <label> TYPE ANY,
                  <series> TYPE ANY.

  CLEAR : fu_series, fu_element.

* Create an element for Series Data & Label (Y-axis)
  DO gv_times TIMES.
    lv_index = sy-index.
    CONCATENATE 'LABEL' lv_index INTO lv_fieldname.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_slabel> TO <label>.
    CHECK sy-subrc = 0.

    "Set label of series
    fu_series = fu_ixml->create_simple_element(
      name = 'Series'
      parent = fu_simplechartdata ).

    lv_value = <label>.
    fu_series->set_attribute( name = 'label' value = lv_value ).

    LOOP AT <fs_graph> ASSIGNING <fs_sgraph>.
      CLEAR lv_value.
      CONCATENATE 'SERIES' lv_index INTO lv_fieldname.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_sgraph> TO <series>.
      CHECK sy-subrc = 0.

      "Set series to be displayed as graphic
      fu_element = fu_ixml->create_simple_element(
       name = 'S'
       parent = fu_series ).

      lv_value = lv_index.
      fu_series->set_attribute( name = 'label' value = lv_value ).

      lv_value = <series>.
      fu_element->if_ixml_node~set_value( lv_value ).
    ENDLOOP.
  ENDDO.
ENDFORM.                    " F_CREATE_SERIES

*&---------------------------------------------------------------------*
*&      Form  F_GLOBAL_SETTING
*&---------------------------------------------------------------------*
FORM f_global_setting  USING    fu_lo_ixml TYPE REF TO if_ixml_document.
  DATA: lo_root            TYPE REF TO if_ixml_element,
        lo_globalsettings  TYPE REF TO if_ixml_element,
        lo_default         TYPE REF TO if_ixml_element,
        lo_elements        TYPE REF TO if_ixml_element,
        lo_chartelements   TYPE REF TO if_ixml_element,
        lo_title           TYPE REF TO if_ixml_element,
        lo_element         TYPE REF TO if_ixml_element,
        lo_encoding        TYPE REF TO if_ixml_encoding.

  fu_lo_ixml = lo_ixml->create_document( ).

  lo_encoding = lo_ixml->create_encoding(
    byte_order = if_ixml_encoding=>co_little_endian
    character_set = 'utf-8' ).

  fu_lo_ixml->set_encoding( lo_encoding ).

  lo_root = fu_lo_ixml->create_simple_element(
    name = 'SAPChartCustomizing'
    parent = fu_lo_ixml ).
  lo_root->set_attribute( name = 'version' value = '1.1' ).

  lo_globalsettings = fu_lo_ixml->create_simple_element(
    name = 'GlobalSettings'
    parent = lo_root ).

  lo_element = fu_lo_ixml->create_simple_element(
    name = 'FileType'
    parent = lo_globalsettings ).
  lo_element->if_ixml_node~set_value( 'PNG' ).

* Here you can give the Chart Type i.e. 2D, 3D etc
* Option for Dimensional Graph:
* - PseudoTwo for 2D
* - PseudoThree for 3D
  lo_element = fu_lo_ixml->create_simple_element(
    name = 'Dimension'
    parent = lo_globalsettings ).
  lo_element->if_ixml_node~set_value( gv_dimension ).

* Here you can give the chart type
* Option for char type:
* Lines, StackedLines, Profiles, StackedProfiles, Bars,
* StackedBars, Columns, StackedColumns, Area, StackedArea,
* ProfileArea, StackedProfileArea, Pie,Doughnut, SplitPie, Polar,
* Radar, StackedRadar, Speedometer.
  lo_element = fu_lo_ixml->create_simple_element(
    name = 'ChartType'
    parent = lo_globalsettings ).
  lo_element->if_ixml_node~set_value( gv_chartyp ).

  lo_element = fu_lo_ixml->create_simple_element(
    name = 'FontFamily'
    parent = lo_globalsettings ).
  lo_element->if_ixml_node~set_value( 'Arial' ).

  lo_elements = fu_lo_ixml->create_simple_element(
    name = 'Elements'
    parent = lo_root ).

  lo_chartelements = fu_lo_ixml->create_simple_element(
    name = 'ChartElements'
    parent = lo_elements ).

  lo_title = fu_lo_ixml->create_simple_element(
    name = 'Title'
    parent = lo_chartelements ).

* Give the desired caption for the chart here
  lo_element = fu_lo_ixml->create_simple_element(
    name = 'Caption'
    parent = lo_title ).
  lo_element->if_ixml_node~set_value( gv_caption ).
ENDFORM.                    " F_GLOBAL_SETTING

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_LABEL
*&---------------------------------------------------------------------*
FORM f_create_dyn_label  USING    lv_times.
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  DATA : lv_count(2)   TYPE n,
         lv_fieldname(30).

  CLEAR gt_label_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_label.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    APPEND ls_fieldcat TO gt_label_fieldcat.
  ENDLOOP.

  DO lv_times TIMES.
    ADD 1 TO lv_count.
    CONCATENATE 'LABEL' lv_count INTO lv_fieldname.
    PERFORM f_dyn_int_table USING :
      'LABEL' lv_fieldname '' '' '' '' '' '' 'FIELDNAME' 'LVC_S_FCAT'
      '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDDO.
ENDFORM.                    " F_CREATE_DYN_LABEL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_GRAPH
*&---------------------------------------------------------------------*
FORM f_create_dyn_graph  USING    lv_times.
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  DATA : lv_count(2)   TYPE n,
         lv_fieldname(30).

  CLEAR gt_graph_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_graph.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    APPEND ls_fieldcat TO gt_graph_fieldcat.
  ENDLOOP.

  DO lv_times TIMES.
    ADD 1 TO lv_count.
    CONCATENATE 'SERIES' lv_count INTO lv_fieldname.
    PERFORM f_dyn_int_table USING :
      'GRAPH' lv_fieldname '' '' '' '' '' '' 'TABIX' 'SYST'
      '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDDO.
ENDFORM.                    " F_CREATE_DYN_GRAPH

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_CHART_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_chart_data .
  DATA : lt_xchart   TYPE STANDARD TABLE OF ty_chart,
         ls_chart    LIKE LINE OF gt_chart,
         ls_xchart   LIKE LINE OF lt_xchart,
         ls_splitq   LIKE LINE OF gt_splitq,
         ls_vendor   LIKE LINE OF gt_vendor.

  DATA : lv_lifnr   TYPE lfa1-lifnr,
         lv_category(30),
         lv_count   TYPE i,
         lv_menge   TYPE ekpo-menge,
         lv_meng1   TYPE ekpo-menge,
         lv_mengt(30),
         lv_subrc   TYPE sy-subrc,
         lv_revis   TYPE ekpo-menge,
         lv_mess    TYPE symsgv.

  FIELD-SYMBOLS : <fs>    TYPE ANY.

  IF gt_chart[] IS INITIAL.
    LOOP AT <fs_main> ASSIGNING <fs_lmain>.
      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
      ls_chart-lifnr = <fs>.
      ASSIGN COMPONENT 'ALLOC' OF STRUCTURE <fs_lmain> TO <fs>.
      ls_chart-menge = <fs>.
      ls_chart-zeile    = 0.
      ls_chart-check    = 'X'.
      APPEND ls_chart TO gt_chart.
      ADD ls_chart-menge TO gv_menge.
    ENDLOOP.
    READ TABLE gt_splitq INTO ls_splitq INDEX 1.
    IF sy-subrc = 0.
      ls_xchart-zeile    = 1.
      ls_xchart-menge    = ls_splitq-revis.
      APPEND ls_xchart TO lt_xchart.
    ENDIF.
    ls_xchart-zeile    = 0.
    ls_xchart-menge    = gv_menge - ls_splitq-revis.
    APPEND ls_xchart TO lt_xchart.
  ELSE.
    CLEAR lv_revis.
    LOOP AT gt_splitq INTO ls_splitq.
      ADD ls_splitq-revis TO lv_revis.
      IF ls_splitq-revis IS NOT INITIAL AND
        ls_splitq-zeile IS INITIAL.
        lv_subrc = 1.
      ELSE.
        IF lv_revis > gs_pr-menge.      "gs_pr-alloc.
          lv_subrc = 2.
        ELSE.
          DELETE gt_chart WHERE lifnr = gs_pr-lifnr
                            AND banfn = gs_pr-banfn
                            AND bnfpo = gs_pr-bnfpo
                            AND zeile = ls_splitq-zeile
                            AND check = space.
          ls_chart-lifnr    = gs_pr-lifnr.
          ls_chart-banfn    = gs_pr-banfn.
          ls_chart-bnfpo    = gs_pr-bnfpo.
          ls_chart-zeile    = ls_splitq-zeile.
          ls_chart-menge    = ls_splitq-revis.
          ADD ls_splitq-revis TO lv_menge.
          APPEND ls_chart TO gt_chart.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_subrc = 0.
    CLEAR : <fs_graph>[].

    LOOP AT gt_vendor INTO ls_vendor WHERE split IS INITIAL.
      IF ls_vendor-revis IS INITIAL.
        CONTINUE.
      ENDIF.

      DELETE gt_chart WHERE lifnr = ls_vendor-lifnr
                        AND banfn = gs_pr-banfn
                        AND bnfpo = gs_pr-bnfpo
                        AND zeile = 1
                        AND check = space.

      ls_chart-lifnr    = ls_vendor-lifnr.
      ls_chart-banfn    = gs_pr-banfn.
      ls_chart-bnfpo    = gs_pr-bnfpo.
      ls_chart-zeile    = 1.
      ls_chart-menge    = ls_vendor-revis.
      ADD ls_vendor-revis TO lv_menge.
      APPEND ls_chart TO gt_chart.
    ENDLOOP.

    CLEAR : ls_chart, lv_menge.
    SORT gt_chart BY zeile.
    LOOP AT gt_chart INTO ls_chart.
      IF ls_chart-zeile = 0.
        CONTINUE.
      ENDIF.
      READ TABLE gt_splitq INTO ls_splitq
                           WITH KEY zeile = ls_chart-zeile.
      IF sy-subrc <> 0.
        DELETE gt_chart WHERE lifnr = gs_pr-lifnr
                          AND banfn = gs_pr-banfn
                          AND bnfpo = gs_pr-bnfpo
                          AND zeile = ls_chart-zeile.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      ls_xchart-zeile = ls_chart-zeile.
      ls_xchart-menge = ls_chart-menge.
      ADD ls_chart-menge TO lv_menge.
      COLLECT ls_xchart INTO lt_xchart.
      CLEAR ls_xchart.
    ENDLOOP.

    IF lv_menge <> 0.
      ls_xchart-zeile = 0.
      ls_xchart-menge = gv_menge - lv_menge.
      APPEND ls_xchart TO lt_xchart.
      CLEAR ls_xchart.
    ENDIF.

    PERFORM f_create_dyn_graph USING 1.
    IF <fs_sgraph> IS NOT ASSIGNED.
      PERFORM f_dyn_table USING 'GRAPH'.
    ENDIF.

    SORT lt_xchart BY zeile.
    LOOP AT lt_xchart INTO ls_xchart.
      WRITE ls_xchart-menge TO lv_mengt UNIT gs_pr-meins.
      CONDENSE lv_mengt NO-GAPS.
      CASE ls_xchart-zeile.
        WHEN 0.
          CONCATENATE 'Free =' lv_mengt INTO lv_category
          SEPARATED BY space.
        WHEN OTHERS.
          lv_category = ls_xchart-zeile.
          SHIFT lv_category LEFT DELETING LEADING '0'.
          CONCATENATE 'PO' lv_category '=' lv_mengt INTO lv_category
          SEPARATED BY space.
      ENDCASE.
      ASSIGN COMPONENT 'CATEGORY' OF STRUCTURE <fs_sgraph> TO <fs>.
      <fs> = lv_category.
      ASSIGN COMPONENT 'SERIES01' OF STRUCTURE <fs_sgraph> TO <fs>.
      <fs> = ABS( ls_xchart-menge ).
      APPEND <fs_sgraph> TO <fs_graph>.
      CLEAR <fs_sgraph>.
    ENDLOOP.
  ELSE.
*    CASE lv_subrc.
*      WHEN 1.
*        lv_mess = 'PO must be entries'.
*      WHEN 2.
*        lv_mess = 'Split Qty greater than Allocation Qty'.
*    ENDCASE.
*
*    CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
*      EXPORTING
*        titel = 'Error message'
*        msgid = 'ZAB'
*        msgty = 'E'
*        msgno = '000'
*        msgv1 = lv_mess.
  ENDIF.
ENDFORM.                    " F_PREPARE_CHART_DATA
