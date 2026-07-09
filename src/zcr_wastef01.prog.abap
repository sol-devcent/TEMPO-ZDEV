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
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'AFPO' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AUFNR' 'CAUFV' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PERIOD' '' '' '' '6' 'Period' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINH' '' '' '' '3' 'UM1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'UMREN' '' '' '' '15' 'Satuan terkecil' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BOBOT' '' '' '' '6' 'Bobot Std' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'BOBOTX' '' '' '' '6' 'Bobot Act' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'SMENG' 'AFRU' 'SMENG' '' '' 'OP. Qty' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'LMNGA' 'AFRU' 'LMNGA' '' '' 'Yield Qty' 'X' '' '1' '' '' '' '' '' '' '' '' '' '',
    'WASTE' '' '' '' '10' 'Waste Qty' 'X' '' '1' '' '' '' '' '' '' '' '' '' '',
    'WASTE%' '' '' '' '10' 'Waste %' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'MEINH2' '' '' '' '3' 'UM2' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SMENG2' 'AFRU' 'SMENG' '' '' 'Batch Size' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'LMNGA2' 'AFRU' 'LMNGA' '' '' 'Dlv Qty' 'X' '' '1' '' '' '' '' '' '' '' '' '' '',
    'DLVQTY' '' '' '' '10' 'Dlv Qty 2' 'X' '' '1' '' '' '' '' '' '' '' '' '' '',
    'WASTE2' '' '' '' '10' 'Waste2 Qty' 'X' '' '1' '' '' '' '' '' '' '' '' '' '',
    'WASTE2%' '' '' '' '10' 'Waste2 %' '' '' '1' '' '' '' '' '' '' '' '' '' '',
    'WASTET' '' '' '' '15' 'Waste Total Qty' 'X' '' '1' '' '' '' '' '' '' '' '' '' ''.
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
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'MATNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'AUFNR'.
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
*  gt_out-chbox = abap_true.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
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
  DEFINE mac_ltxa1.
    gv_ltxa1-sign = &1.
    gv_ltxa1-option = &2.
    gv_ltxa1-low = &3.
    append gv_ltxa1. clear gv_ltxa1.
  END-OF-DEFINITION.

  gv_cetak1 = 'Cetak Tablet'.
  gv_cetak2 = 'Cetak Kaplet'.
  gv_kemas1 = 'Pengemasan Sekunder'.
  gv_kemas2 = 'Pengemasan  Sekunder'.

  mac_ltxa1 'I' 'EQ' gv_cetak1.
  mac_ltxa1 'I' 'EQ' gv_cetak2.
  mac_ltxa1 'I' 'EQ' gv_kemas1.
  mac_ltxa1 'I' 'EQ' gv_kemas2.

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
  DATA: lt_makt   LIKE gt_caufv OCCURS 0 WITH HEADER LINE,
        lt_caufv  LIKE gt_caufv OCCURS 0 WITH HEADER LINE,
        lt_plmk   TYPE STANDARD TABLE OF plmk INITIAL SIZE 0
                  WITH HEADER LINE.

  DATA: BEGIN OF lt_key OCCURS 0,
          prueflos    TYPE caufv-prueflos,
          plnkn       TYPE plmk-plnkn,
          merknr      TYPE plmk-merknr,
        END OF lt_key.

  SELECT aufnr werks gstri gltri plnbez plnty plnnr prueflos
    FROM caufv
    INTO TABLE gt_caufv
    WHERE aufnr   IN s_aufnr  AND
          werks   IN s_werks  AND
          gstri   IN s_gstri  AND
          gltri   IN s_gltri  AND
          plnbez  IN s_matnr.

  lt_caufv[]  = gt_caufv[].
  SORT lt_caufv BY plnnr.
  DELETE ADJACENT DUPLICATES FROM lt_caufv COMPARING plnnr.
  IF lt_caufv[] IS NOT INITIAL.
    SELECT plnty plnnr plnkn kzeinstell merknr zaehl
      FROM plmk
      INTO CORRESPONDING FIELDS OF TABLE gt_plmk
      FOR ALL ENTRIES IN lt_caufv
      WHERE plnnr     = lt_caufv-plnnr
        AND verwmerkm = 'QNI00080'.

    lt_plmk[] = gt_plmk[].
    SORT lt_plmk BY plnkn merknr.
    DELETE ADJACENT DUPLICATES FROM lt_plmk COMPARING plnkn merknr.
  ENDIF.

  IF gt_caufv[] IS NOT INITIAL.
    lt_makt[] = gt_caufv[].
    SORT lt_makt BY plnbez.
    DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING plnbez.

    SELECT a~matnr meins maktx
      FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
      INTO TABLE gt_makt
      FOR ALL ENTRIES IN lt_makt
      WHERE a~matnr EQ lt_makt-plnbez AND
            spras EQ sy-langu.

    SELECT matnr bwkey stprs peinh
      FROM mbew
      INTO TABLE gt_mbew
      FOR ALL ENTRIES IN lt_makt
      WHERE matnr EQ lt_makt-plnbez AND
            bwkey IN s_werks.

    SELECT * INTO TABLE gt_marm
      FROM marm FOR ALL ENTRIES IN lt_makt
      WHERE matnr EQ lt_makt-plnbez
        AND meinh IN ('MG','TAB','KAP').

    SELECT DISTINCT aufnr posnr charg
      INTO TABLE gt_afpo
      FROM afpo FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr EQ gt_caufv-aufnr.

    SELECT a~rueck a~rmzhl aufnr a~vornr lmnga smeng meinh
           b~aufpl b~aplzl b~ltxa1
      FROM afru AS a JOIN afvc AS b ON a~aufpl EQ b~aufpl AND
                                       a~aplzl EQ b~aplzl AND
                                       a~vornr EQ b~vornr
      INTO TABLE gt_afru
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr EQ gt_caufv-aufnr
        AND b~ltxa1 IN gv_ltxa1.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.

  LOOP AT gt_caufv.
    lt_key-prueflos = gt_caufv-prueflos.
    LOOP AT lt_plmk.
      lt_key-plnkn    = lt_plmk-plnkn.
      lt_key-merknr   = lt_plmk-merknr.
      APPEND lt_key.
    ENDLOOP.
  ENDLOOP.

  IF lt_key[] IS NOT INITIAL.
    SELECT prueflos vorglfnr merknr mittelwert
      FROM qamr
      INTO CORRESPONDING FIELDS OF TABLE gt_qamr
      FOR ALL ENTRIES IN lt_key
      WHERE prueflos = lt_key-prueflos
        AND vorglfnr = lt_key-plnkn
        AND merknr   = lt_key-merknr.
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
  DATA: lt_afru       LIKE gt_afru OCCURS 0 WITH HEADER LINE,
        lt_marmmg     LIKE gt_marm OCCURS 0 WITH HEADER LINE,
        lt_marmtab    LIKE gt_marm OCCURS 0 WITH HEADER LINE.

  DATA: ls_qamr   LIKE LINE OF gt_qamr.
  DATA : lv_mittelwert  TYPE qamr-mittelwert.

  lt_marmmg[] = lt_marmtab[] = gt_marm[].
  DELETE lt_marmmg WHERE meinh = 'TAB'.
  DELETE lt_marmmg WHERE meinh = 'KAP'.
  DELETE lt_marmtab WHERE meinh = 'MG'.

  SORT gt_afru BY aufnr vornr.
  LOOP AT gt_afru.
    lt_afru-aufnr = gt_afru-aufnr.
    lt_afru-vornr = gt_afru-vornr.
    lt_afru-ltxa1 = gt_afru-ltxa1.
    lt_afru-lmnga = gt_afru-lmnga.
    lt_afru-aufpl = gt_afru-aufpl.
    lt_afru-aplzl = gt_afru-aplzl.
    COLLECT lt_afru.
  ENDLOOP.

  SORT gt_caufv BY plnbez aufnr.
  SORT gt_afru BY aufnr aufpl aplzl vornr.
  SORT lt_afru BY aufnr aufpl aplzl vornr.
  LOOP AT gt_caufv.
    IF gt_caufv-plnbez IS NOT INITIAL.
      gt_out-matnr  = gt_caufv-plnbez.
      READ TABLE gt_makt WITH KEY matnr = gt_caufv-plnbez.
      IF sy-subrc EQ 0.
        gt_out-maktx  = gt_makt-maktx.
        gt_out-meinh2 = gt_makt-meins.
      ENDIF.
      READ TABLE gt_afpo WITH KEY aufnr = gt_caufv-aufnr.
      IF sy-subrc EQ 0.
        gt_out-charg  = gt_afpo-charg.
      ENDIF.
      gt_out-werks  = gt_caufv-werks.
      gt_out-plnty  = gt_caufv-plnty.
      gt_out-plnnr  = gt_caufv-plnnr.
      gt_out-gstri  = gt_caufv-gstri.
      gt_out-gltri  = gt_caufv-gltri.
      gt_out-aufnr  = gt_caufv-aufnr.
      gt_out-period = gt_caufv-gltri+4(2).

      CLEAR lv_mittelwert.
      LOOP AT gt_qamr INTO ls_qamr WHERE prueflos = gt_caufv-prueflos.
        ADD ls_qamr-mittelwert TO lv_mittelwert.
      ENDLOOP.

      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          input = lv_mittelwert
          ivalu = 'X'
          decim = 2
        IMPORTING
          flstr = gt_out-bobotx.

      LOOP AT lt_afru WHERE aufnr EQ gt_caufv-aufnr.
        gt_out-vornr  = lt_afru-vornr.
        gt_out-ltxa1  = lt_afru-ltxa1.

        CASE lt_afru-ltxa1.
          WHEN gv_cetak1.
            READ TABLE lt_marmtab WITH KEY matnr = gt_caufv-plnbez
                                           meinh = 'TAB'.
            IF sy-subrc = 0.
              gt_out-umren = lt_marmtab-umren.
              READ TABLE lt_marmmg WITH KEY matnr = gt_caufv-plnbez.
              IF sy-subrc = 0.
*                gt_out-bobot = lt_marmmg-umren / lt_marmtab-umren.
                TRY .
                    gt_out-bobot = lt_marmmg-umren / lt_marmtab-umren.
                  CATCH
                    cx_sy_zerodivide.
                ENDTRY.
              ENDIF.
            ENDIF.
          WHEN gv_cetak2.
            READ TABLE lt_marmtab WITH KEY matnr = gt_caufv-plnbez
                                           meinh = 'KAP'.
            IF sy-subrc = 0.
              gt_out-umren = lt_marmtab-umren.
              READ TABLE lt_marmmg WITH KEY matnr = gt_caufv-plnbez.
              IF sy-subrc = 0.
*                gt_out-bobot = lt_marmmg-umren / lt_marmtab-umren.
                TRY .
                    gt_out-bobot = lt_marmmg-umren / lt_marmtab-umren.
                  CATCH
                    cx_sy_zerodivide.
                ENDTRY.
              ENDIF.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

        CLEAR gt_afru.
        READ TABLE gt_afru WITH KEY aufnr = lt_afru-aufnr
                                    aufpl = lt_afru-aufpl
                                    aplzl = lt_afru-aplzl
                                    vornr = lt_afru-vornr.

        CASE lt_afru-ltxa1.
          WHEN gv_cetak1 OR gv_cetak2.
            gt_out-lmnga  = lt_afru-lmnga.
            IF sy-subrc EQ 0.
              gt_out-smeng  = gt_afru-smeng.
              gt_out-meinh  = gt_afru-meinh.
            ENDIF.
            gt_out-waste = gt_out-smeng - gt_out-lmnga.
*            gt_out-waste% = gt_out-waste / gt_out-smeng * 100.
            TRY .
                gt_out-waste% = gt_out-waste / gt_out-smeng * 100.
              CATCH
                cx_sy_zerodivide.
            ENDTRY.
          WHEN gv_kemas1 OR gv_kemas2.
            gt_out-lmnga2  = lt_afru-lmnga.
            gt_out-dlvqty = ( gt_out-lmnga2 * gt_out-umren * gt_out-bobot ) / 1000.
            IF sy-subrc EQ 0.
              gt_out-smeng2  = gt_afru-smeng.
              gt_out-meinh2  = gt_afru-meinh.
            ENDIF.
*            gt_out-waste2 = gt_out-lmnga - gt_out-lmnga2.
            gt_out-waste2 = gt_out-lmnga - gt_out-dlvqty.
*            gt_out-waste2% = gt_out-waste2 / gt_out-lmnga * 100.
            TRY .
                gt_out-waste2% = gt_out-waste2 / gt_out-lmnga * 100.
              CATCH
                cx_sy_zerodivide.
            ENDTRY.
        ENDCASE.
      ENDLOOP.

      IF sy-subrc = 0.
        gt_out-wastet = gt_out-waste + gt_out-waste2.
*        gt_out-dlvqty = ( gt_out-lmnga2 * gt_out-umren * gt_out-bobot ) / 1000.
        APPEND gt_out.
      ENDIF.
    ENDIF.
    CLEAR gt_out.
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
*  LOOP AT SCREEN.
*    CASE screen-group1.
*      WHEN 'MO1'.
*        screen-invisible = '0'.
*        screen-input     = '1'.
*        MODIFY SCREEN.
*      WHEN 'MO2'.
*        screen-invisible = '1'.
*        screen-input     = '0'.
*        MODIFY SCREEN.
*      WHEN 'MO3'.
*        screen-invisible = '1'.
*        screen-input     = '0'.
*        MODIFY SCREEN.
*      WHEN 'MO4'.
*        screen-invisible = '1'.
*        screen-input     = '0'.
*        MODIFY SCREEN.
*      WHEN OTHERS.
*    ENDCASE.
*  ENDLOOP.
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
ENDFORM.                    " F_HEADER_ALV
