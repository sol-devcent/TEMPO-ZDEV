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
                IMPORTING e_dyndoc_id,
**Change data Handler
    handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
                        IMPORTING er_data_changed,
**Custom Toolbar
    toolbar FOR EVENT toolbar OF  cl_gui_alv_grid
            IMPORTING e_object,
**User Command
    user_command FOR EVENT user_command OF cl_gui_alv_grid
                 IMPORTING e_ucomm.
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

  METHOD handle_data_changed.
    DATA: ls_good TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
*      CASE ls_good-fieldname.
*        WHEN 'CHBOX'.
*          READ TABLE gt_out ASSIGNING <fs_out> INDEX ls_good-row_id.
*          <fs_out>-chbox = ls_good-value.
*          IF <fs_out>-chbox = 'X'.
*            <fs_out>-icon = icon_green_light.
*          ELSE.
*            IF <fs_out>-exist = 'X'.
*              <fs_out>-icon = icon_yellow_light.
*            ELSE.
*              <fs_out>-icon = icon_red_light.
*            ENDIF.
*          ENDIF.
*        WHEN OTHERS.
*      ENDCASE.
    ENDLOOP.
    IF sy-subrc = 0.
      CALL METHOD g_grid->refresh_table_display( ).
    ENDIF.
  ENDMETHOD.                    "handle_data_changed

  METHOD toolbar.
    DATA: wa_tool TYPE stb_button.

    wa_tool-butn_type = '3'.      "Sepearator line
    APPEND wa_tool TO e_object->mt_toolbar. CLEAR wa_tool.

    IF radio1 IS NOT INITIAL.
      wa_tool-function = '&CHK'.
      wa_tool-text     = 'Check'.
      wa_tool-icon     = '@38@'.
      APPEND wa_tool TO e_object->mt_toolbar. CLEAR wa_tool.
    ENDIF.

    wa_tool-function = '&CETAK'.
    wa_tool-text     = 'Cetak Form'.
    wa_tool-icon     = '@0X@'.
    APPEND wa_tool TO e_object->mt_toolbar. CLEAR wa_tool.
  ENDMETHOD.                    "toolbar

  METHOD user_command.
    DATA: lv_error TYPE char1.

    CASE e_ucomm.
      WHEN '&CHK'.
        PERFORM f_check_value CHANGING lv_error.
        CALL METHOD g_grid->refresh_table_display( ).

      WHEN '&CETAK'.
        PERFORM f_check_value CHANGING lv_error.
        IF lv_error IS INITIAL.
          CASE 'X'.
            WHEN radio1.
              p_tdform = 'ZTSPPPSF001_01'.
*              p_tdform = 'ZTSPPPSF001'.
              PERFORM f_save_to_table.
            WHEN radio2.
              IF p_new IS INITIAL.
                p_tdform = 'ZTSPPPSF004'.
              ELSE.
                p_tdform = 'ZTSPPPSF004N'.
              ENDIF.
              PERFORM f_modify_gt_batch2.
              PERFORM f_modify_zrm_output.
          ENDCASE.

          PERFORM f_cetak_form.
          LEAVE TO SCREEN 0.
        ELSE.
          CALL METHOD g_grid->refresh_table_display( ).
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "user_command
ENDCLASS.                    "LCL_EVENT_HANDLER IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  DATA g_event_handler TYPE REF TO lcl_event_handler.

  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100' WITH gv_title.

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

*    PERFORM f_header_alv.

    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

    CREATE OBJECT g_event_handler.
    SET HANDLER: g_event_handler->toolbar FOR g_grid,
                 g_event_handler->user_command FOR g_grid.

* Create_display_ALV
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
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
  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN radio1.
      PERFORM f_fieldcatg USING 'GT_OUT':
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '' '',
        'AUFNR' 'AFPO' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MATNR' 'AFPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MEINS' 'AFPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'CHARG' 'AFPO' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'VFDAT' 'MCH1' 'VFDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'BSTFE' 'MARC' 'BSTFE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'QTYBLS' '' '' '' '' 'Qty Blister' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'QTYTAB' '' '' '' '' 'Qty Tablet' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'QTYNYATA' '' '' '' '' 'Qty Nyata' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'MATNR2' '' 'MATNR' '' '' 'Kode Bahan Pengemasan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX2' '' 'MAKTX' '' '' 'Nama Bahan Pengemasan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CHARG2' '' '' '' '' 'Nomor Pemeriksaan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS' 'RESB' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BDMNG' '' 'BDMNG' '' '' 'Qty Standard' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'ERFMG' '' 'ERFMG' '' '' 'Qty Jumlah' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'BAIK' 'AUFM' 'ERFMG' '' '15' 'Quantity Baik' '' '' '' '' '' '' 'MEINS' '' '' '' '' 'X' '' '' '',
        'RUSAK' 'AUFM' 'ERFMG' '' '15' 'Quantity Rusak' '' '' '' '' '' '' 'MEINS' '' '' '' '' 'X' '' '' '',
        'ICON1' '' '' '' '4' 'ICON' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''.
    WHEN radio2.
      PERFORM f_fieldcatg USING 'GT_OUT':
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '' '',
        'AUFNR' 'AFPO' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MATNR' 'AFPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MEINS' 'AFPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'CHARG' 'AFPO' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'VFDAT' 'MCH1' 'VFDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'PHSEQ' 'AFVC' 'PHSEQ' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTXA1' 'AFVC' 'LTXA1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*        'BSTFE' 'MARC' 'BSTFE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
*        'QTYNYATA' '' '' '' '' 'Qty Nyata' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' '' '',
        'MATNR2' '' 'MATNR' '' '' 'Kode Bahan Pengemasan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX2' '' 'MAKTX' '' '' 'Nama Bahan Pengemasan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CHARG2' '' '' '' '' 'Nomor Pemeriksaan' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS2' 'RESB' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BDMNG' '' 'BDMNG' '' '' 'Qty Standard' '' '' '' '' '' '' 'MEINS2' '' '' '' '' '' '' '' '',
        'ERFMG' '' 'ERFMG' '' '' 'Qty Jumlah' '' '' '' '' '' '' 'MEINS2' '' '' '' '' '' '' '' '',
        'SHTXT' 'ZPPRESB_ADD' 'SHTXT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'OPERATOR' 'ZPPRESB_ADD' 'OPERATOR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PENGAWAS' 'ZPPRESB_ADD' 'PENGAWAS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ICON1' '' '' '' '4' 'ICON' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''.
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
                          value(fu_icon)
                          value(fu_key)
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
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-key               = fu_key.
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
*  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'AUFNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
*  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'MATNR'.
  APPEND gt_sort.

  CLEAR gt_sort.
*  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'MAKTX'.
  APPEND gt_sort.

  IF radio2 = 'X'.
    gt_sort-fieldname = 'PHSEQ'.
    APPEND gt_sort.
  ENDIF.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DG_DYNDOC_ID  text
*----------------------------------------------------------------------*
FORM event_top_of_page USING   dg_dyndoc_id TYPE REF TO cl_dd_document.

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
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data .
  gv_title = sy-title.
  CASE 'X'.
    WHEN radio1.
      gv_mtart  = 'ZPM'.
    WHEN radio2.
      gv_mtart  = 'ZRM'.
  ENDCASE.
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
  SELECT * INTO TABLE gt_ztspppdt001
    FROM ztspppdt001 WHERE aufnr = p_aufnr.

  SELECT SINGLE aufnr stlnr stlal
    INTO CORRESPONDING FIELDS OF gt_caufv
    FROM caufv WHERE aufnr = p_aufnr.
  IF sy-subrc = 0.
    SELECT SINGLE stlty stlnr stlal stkoz bmeng
      INTO CORRESPONDING FIELDS OF gt_stko
      FROM stko WHERE stlnr = gt_caufv-stlnr
                  AND stlal = gt_caufv-stlal.
  ENDIF.

  SELECT aufnr posnr psamg psmng wemng iamng amein meins matnr pamng
         pgmng dwerk charg wemng
    INTO CORRESPONDING FIELDS OF TABLE gt_afpo
    FROM afpo WHERE aufnr = p_aufnr
                AND matnr IN s_matnr
                AND dwerk IN s_werks.

  IF gt_afpo[] IS NOT INITIAL.
    "Header
    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_afpo
      WHERE matnr = gt_afpo-matnr
        AND spras = sy-langu.

    SELECT matnr charg vfdat
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FROM mch1 FOR ALL ENTRIES IN gt_afpo
      WHERE matnr = gt_afpo-matnr
        AND charg = gt_afpo-charg.

    SELECT matnr werks bstfe fevor
      INTO CORRESPONDING FIELDS OF TABLE gt_marc
      FROM marc FOR ALL ENTRIES IN gt_afpo
      WHERE matnr = gt_afpo-matnr
        AND werks = gt_afpo-dwerk.

    SELECT matnr meinh umrez umren
      INTO CORRESPONDING FIELDS OF TABLE gt_marm
      FROM marm FOR ALL ENTRIES IN gt_afpo
      WHERE matnr = gt_afpo-matnr.

    SELECT * INTO TABLE gt_ztspppdt0011
      FROM ztspppdt0011 FOR ALL ENTRIES IN gt_makt
      WHERE matnr = gt_makt-matnr.

    SELECT * INTO TABLE gt_ztspppdt0012
      FROM ztspppdt0012 FOR ALL ENTRIES IN gt_marc
      WHERE werks = gt_marc-werks
        AND fevor = gt_marc-fevor.

    SELECT * INTO TABLE gt_t006a
      FROM t006a WHERE spras = sy-langu.

    "Item
    SELECT mblnr mjahr zeile bwart a~matnr werks lgort charg
           menge a~meins erfmg erfme aufnr bwart rsnum rspos
      INTO CORRESPONDING FIELDS OF TABLE gt_aufm
      FROM aufm AS a JOIN mara AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN gt_afpo
      WHERE aufnr = gt_afpo-aufnr
        AND bwart IN ('261','262')
        AND b~mtart = gv_mtart.

    SELECT rsnum rspos rsart a~matnr werks lgort charg bdmng a~meins nomng
           fmeng enmng erfmg erfme aufnr bwart posnr kzear splkz aufpl aplzl
           wempf sortf postp potx1 vornr
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FROM resb AS a JOIN mara AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN gt_afpo
      WHERE aufnr = gt_afpo-aufnr
        AND bwart IN ('261','262')
        AND b~mtart = gv_mtart.

    IF radio2 = 'X'.
      SELECT rsnum rspos rsart matnr werks lgort charg bdmng meins nomng
             fmeng enmng erfmg erfme aufnr bwart posnr kzear splkz aufpl aplzl
             wempf sortf postp potx1 vornr
        APPENDING CORRESPONDING FIELDS OF TABLE gt_resb
        FROM resb FOR ALL ENTRIES IN gt_afpo
        WHERE aufnr = gt_afpo-aufnr
          AND postp = 'T'.
    ENDIF.

    IF gt_resb[] IS NOT INITIAL.
      SELECT matnr maktx
        INTO CORRESPONDING FIELDS OF TABLE gt_makt2
        FROM makt FOR ALL ENTRIES IN gt_resb
        WHERE matnr = gt_resb-matnr
          AND spras = sy-langu.

      CASE 'X'.
        WHEN radio1.
          PERFORM f_modify_itab_resb.
        WHEN radio2.
          PERFORM f_get_additional_data.
          PERFORM f_documented_goods_movements.
      ENDCASE.
    ENDIF.
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
  DATA ls_makt LIKE LINE OF gt_makt.
  DATA ls_makt2 LIKE LINE OF gt_makt2.
  DATA ls_afpo LIKE LINE OF gt_afpo.
  DATA ls_resb LIKE LINE OF gt_resb.
  DATA ls_aufm LIKE LINE OF gt_aufm.
  DATA ls_mch1 LIKE LINE OF gt_mch1.
  DATA ls_marc LIKE LINE OF gt_marc.
  DATA ls_marm01 LIKE LINE OF gt_marm.
  DATA ls_marm02 LIKE LINE OF gt_marm.
  DATA ls_marm03 LIKE LINE OF gt_marm.
  DATA ls_marm04 LIKE LINE OF gt_marm.
  DATA ls_t006a01 LIKE LINE OF gt_t006a.
  DATA ls_t006a02 LIKE LINE OF gt_t006a.
  DATA ls_ztspppdt001 LIKE LINE OF gt_ztspppdt001.
  DATA ls_ztspppdt0012 LIKE LINE OF gt_ztspppdt0012.

  SORT gt_afpo BY aufnr matnr.
  SORT gt_aufm BY	aufnr matnr charg.
  SORT gt_resb BY aufnr matnr charg.
  SORT gt_makt2 BY matnr.
  SORT gt_makt BY matnr.
  SORT gt_marc BY matnr werks.
  SORT gt_marm BY matnr meinh.
  SORT gt_mch1 BY matnr charg.

  DATA ls_add   LIKE LINE OF gt_add.

  LOOP AT gt_afpo INTO ls_afpo.
    CLEAR: ls_makt,ls_mch1,ls_marc,ls_marm01,ls_marm02,ls_marm03,ls_marm04,
           ls_t006a01,ls_t006a02.
    READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_afpo-matnr.
    READ TABLE gt_mch1 INTO ls_mch1 WITH KEY matnr = ls_afpo-matnr
                                             charg = ls_afpo-charg.
    READ TABLE gt_marc INTO ls_marc WITH KEY matnr = ls_afpo-matnr
                                             werks = ls_afpo-dwerk.

    LOOP AT gt_ztspppdt0012 INTO ls_ztspppdt0012 WHERE werks = ls_afpo-dwerk
                                                   AND fevor = ls_marc-fevor.
      READ TABLE gt_marm INTO ls_marm01 WITH KEY matnr = ls_afpo-matnr
                                                 meinh = ls_ztspppdt0012-uom01.
      IF sy-subrc = 0.
        READ TABLE gt_marm INTO ls_marm02 WITH KEY matnr = ls_afpo-matnr
                                                   meinh = ls_ztspppdt0012-uom02.
        IF sy-subrc = 0.
          EXIT.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF ls_marm03 IS INITIAL.
      READ TABLE gt_marm INTO ls_marm03 WITH KEY matnr = ls_afpo-matnr
                                                 meinh = 'SW'.
      IF sy-subrc NE 0.
        READ TABLE gt_marm INTO ls_marm03 WITH KEY matnr = ls_afpo-matnr
                                                   meinh = 'SP'.
        IF sy-subrc NE 0.
          READ TABLE gt_marm INTO ls_marm03 WITH KEY matnr = ls_afpo-matnr
                                                     meinh = 'FBX'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_marm03-meinh = 'SW' OR ls_marm03-meinh = 'SP'.
      READ TABLE gt_marm INTO ls_marm04 WITH KEY matnr = ls_afpo-matnr
                                                 meinh = 'FBX'.
    ELSEIF ls_marm03-meinh = 'FBX'.
      READ TABLE gt_marm INTO ls_marm04 WITH KEY matnr = ls_afpo-matnr
                                                 meinh = 'BT'.
    ENDIF.

    READ TABLE gt_t006a INTO ls_t006a01 WITH KEY msehi = ls_marm01-meinh.
    READ TABLE gt_t006a INTO ls_t006a02 WITH KEY msehi = ls_marm02-meinh.

    CASE 'X'.
      WHEN radio1.
        PERFORM f_zpm_reservation_detail USING ls_afpo ls_makt ls_mch1
                                               ls_marc ls_marm01 ls_marm02
                                               ls_marm03 ls_marm04
                                               ls_t006a01 ls_t006a02.
      WHEN radio2.
        PERFORM f_zrm_reservation_detail USING ls_afpo  ls_makt ls_mch1
                                               ls_marc ls_marm01 ls_marm02
                                               ls_marm03 ls_marm04
                                               ls_t006a01 ls_t006a02.
    ENDCASE.
  ENDLOOP.

  CASE 'X'.
    WHEN radio1.
    WHEN radio2.
      PERFORM f_modify_itab_out.
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
      WHEN 'GRY'.
        screen-invisible = '0'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN 'PHS'.
        IF radio1 = 'X'.
          screen-active    = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'NEW'.
        IF sy-uname = 'TDS_DEV01' OR
           sy-uname = 'ABSUK' OR
           sy-uname = 'PPIFA' OR sy-uname = 'PPMRA'.
        ELSE.
          screen-active    = '0'.
          MODIFY SCREEN.
        ENDIF.
*      WHEN 'MO4'.
*        screen-invisible = '1'.
*        screen-input     = '0'.
*        MODIFY SCREEN.
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

  IF p_aufnr IS INITIAL.
    PERFORM f_error_message USING 'PAU' ''.
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
ENDFORM.                    " F_HEADER_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VALUE
*&---------------------------------------------------------------------*
FORM f_check_value CHANGING fc_error.
  DATA: lv_jumlah TYPE erfmg.

  LOOP AT gt_out ASSIGNING <fs_out>.
    CLEAR: <fs_out>-icon1.
    IF <fs_out>-baik IS NOT INITIAL OR
       <fs_out>-rusak IS NOT INITIAL.
      lv_jumlah = <fs_out>-baik + <fs_out>-rusak.
      IF lv_jumlah NE <fs_out>-erfmg.
        <fs_out>-icon1 = '@5C@'.
        fc_error = 'E'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF fc_error IS NOT INITIAL.
    MESSAGE 'Input data masih salah' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_CHECK_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM
*&---------------------------------------------------------------------*
FORM f_cetak_form .
  DATA: lt_detail  LIKE ztspppst001 OCCURS 0,
        lt_detail2 LIKE ztspppst001 OCCURS 0,
        ls_header  LIKE ztspppst001,
        ls_detail  LIKE ztspppst001,
        lv_larutan TYPE flag,
        lv_count   TYPE int1,
        lv_lines   TYPE int1.

  CALL SELECTION-SCREEN 101 STARTING AT 10 2
                            ENDING AT 100 10.
  IF sy-subrc = 0.
    CASE 'X'.
      WHEN radio1.
        lt_detail[] = gt_out[].

      WHEN radio2.
        IF p_phseq IS INITIAL.
        ELSE.
          DELETE gt_xout WHERE phseq NE p_phseq.
        ENDIF.
        lt_detail[] = gt_xout[].
    ENDCASE.

    READ TABLE lt_detail INTO ls_header INDEX 1.
    PERFORM f_determine_smrt_funcmod USING p_tdform
                                           d_smrt_funcmod
                                           d_frm_subrc.
    IF d_frm_subrc IS INITIAL.
      d_output_opt-tdimmed  = nast-dimme.
      d_output_opt-tddelete = nast-delet.
      d_output_opt-tdcopies = nast-anzal.

      CASE 'X'.
        WHEN radio1.
          CALL FUNCTION d_smrt_funcmod
            EXPORTING
              control_parameters = d_ctrl_param
              output_options     = d_output_opt
              user_settings      = space
              gs_header          = ls_header
            TABLES
              gt_detail          = lt_detail.

        WHEN radio2.
          lt_detail2[] = lt_detail.
          SORT lt_detail2 BY phseq sortf.
          DELETE ADJACENT DUPLICATES FROM lt_detail2 COMPARING phseq sortf.
          DESCRIBE TABLE lt_detail2 LINES lv_lines.

          d_ctrl_param-no_close = ' '.
          d_ctrl_param-no_open = ' '.

          LOOP AT lt_detail2 INTO ls_detail.
            lt_detail[] = gt_xout[].
            DELETE lt_detail WHERE phseq NE ls_detail-phseq.
            DELETE lt_detail WHERE sortf NE ls_detail-sortf.

            ADD 1 TO lv_count.

            IF p_new = 'X'.
              READ TABLE lt_detail INTO ls_header INDEX 1.
              READ TABLE lt_detail WITH KEY sortf2 = 'D'
                                   TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
*              IF ls_detail-sortf = 'D'.
                lv_larutan = 'X'.
              ELSE.
                CLEAR lv_larutan.
              ENDIF.
            ENDIF.

            IF lv_count = lv_lines.
              d_ctrl_param-no_close = ' '.
            ELSE.
              d_ctrl_param-no_close = 'X'.
            ENDIF.

            CALL FUNCTION d_smrt_funcmod
              EXPORTING
                control_parameters = d_ctrl_param
                output_options     = d_output_opt
                user_settings      = space
                gs_header          = ls_header
                gv_larutan         = lv_larutan
              TABLES
                gt_detail          = lt_detail.

            d_ctrl_param-no_open = 'X'.
          ENDLOOP.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CETAK_FORM

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_save_to_table .
  DATA: lt_ztspppdt001 TYPE STANDARD TABLE OF ztspppdt001.

  FIELD-SYMBOLS: <fs_ztspppdt001> TYPE ztspppdt001.

  LOOP AT gt_out ASSIGNING <fs_out>.
    APPEND INITIAL LINE TO lt_ztspppdt001 ASSIGNING <fs_ztspppdt001>.
    <fs_ztspppdt001>-aufnr = <fs_out>-aufnr.
    <fs_ztspppdt001>-matnr = <fs_out>-matnr2.
    <fs_ztspppdt001>-meins = <fs_out>-meins2.
    <fs_ztspppdt001>-qty_baik = <fs_out>-baik.
    <fs_ztspppdt001>-qty_rusak = <fs_out>-rusak.
  ENDLOOP.

  IF lt_ztspppdt001 IS NOT INITIAL.
    MODIFY ztspppdt001 FROM TABLE lt_ztspppdt001.
  ENDIF.
ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_RESB
*&---------------------------------------------------------------------*
FORM f_modify_itab_resb .
  DATA: lt_resb TYPE STANDARD TABLE OF resb,
        ls_resb LIKE LINE OF lt_resb,
        lt_aufm TYPE STANDARD TABLE OF aufm,
        ls_aufm LIKE LINE OF lt_aufm.

  FIELD-SYMBOLS: <fs_resb> TYPE resb,
                 <fs_aufm> TYPE aufm.

  lt_resb[] = gt_resb[].
  DELETE lt_resb WHERE bwart = '261'.
  DELETE gt_resb WHERE bwart = '262'.

  LOOP AT lt_resb INTO ls_resb.
    READ TABLE gt_resb ASSIGNING <fs_resb> WITH KEY rsnum = ls_resb-rsnum
                                                    matnr = ls_resb-matnr
                                                    charg = ls_resb-charg.
    IF sy-subrc = 0.
      <fs_resb>-bdmng = <fs_resb>-bdmng - ls_resb-bdmng.
    ENDIF.
  ENDLOOP.

  lt_aufm[] = gt_aufm[].
  DELETE lt_aufm WHERE bwart = '261'.
  DELETE gt_aufm WHERE bwart = '262'.

  LOOP AT lt_aufm INTO ls_aufm.
    READ TABLE gt_aufm ASSIGNING <fs_aufm> WITH KEY aufnr = ls_aufm-aufnr
                                                    matnr = ls_aufm-matnr
                                                    charg = ls_aufm-charg.
    IF sy-subrc = 0.
      <fs_aufm>-erfmg = <fs_aufm>-erfmg - ls_aufm-erfmg.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_ITAB_RESB

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2193   text
*      -->P_2194   text
*----------------------------------------------------------------------*
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
*&      Form  F_MODIFY_ZRM_OUTPUT
*&---------------------------------------------------------------------*
FORM f_modify_zrm_output .
  DATA : lt_batch2 LIKE gt_batch2 OCCURS 0 WITH HEADER LINE,
         lt_xout   LIKE gt_out OCCURS 0,
         lt_xout2  LIKE gt_out OCCURS 0,
         lt_xout01 LIKE gt_out OCCURS 0,
         ls_xout   LIKE LINE OF gt_xout,
         ls_xout2  LIKE LINE OF lt_xout,
         ls_xout01 LIKE LINE OF lt_xout01,
         ls_out    LIKE LINE OF gt_xout,
         ls_resb   LIKE LINE OF gt_resb,
         ls_add    LIKE LINE OF gt_add,
         ls_afvc   LIKE LINE OF gt_afvc,
         ls_afvu   LIKE LINE OF gt_afvu,
         ls_ztspppdt008 LIKE LINE OF gt_ztspppdt008,
         ls_ztspppdt007 LIKE LINE OF gt_ztspppdt007,
         ls_ztspppdt007d LIKE LINE OF gt_ztspppdt007d,
         lv_aufnr  LIKE resb-aufnr,
         lv_posnr  LIKE resb-posnr,
         lv_aufnrx LIKE resb-aufnr,
         lv_posnrx LIKE resb-posnr,
         lv_nomng  LIKE resb-nomng,
         lv_nomngs LIKE resb-nomng,
         lv_postp  LIKE ls_resb-postp,
         lv_factor LIKE ztnpppdt002-factor,
         lv_extyp  TYPE ztspppdt006,
         lv_zno    TYPE zno,
         lv_uline  TYPE zno,
         lv_maktx2 TYPE maktx,
         lv_nomngc TYPE char15,
         lv_matnr  TYPE posnr,
         lv_rwork  TYPE zrwork,
         lv_index,
         lv_index2(1) TYPE n,
         lv_count2 TYPE sytabix,
         lv_matnr2 TYPE matnr,
         lv_posnr2 LIKE resb-posnr,
         lv_vornr2 TYPE vornr,
         lv_matnr3 TYPE matnr,
         lv_nomng3 TYPE nomng,
         lv_idx01  TYPE sytabix,
         lv_loop   TYPE sytabix,
         lv_fieldname(30),
         lv_erfmg(9),
         lv_t1,lv_t2,lv_t3,lv_t4.

  FIELD-SYMBOLS: <fs>       TYPE ANY,
                 <fs2>      TYPE ANY,
                 <fs_xout>  LIKE gt_out,
                 <fs_xout2> LIKE gt_out.


  IF p_new = 'X'.
    PERFORM f_get_wbooth.
  ENDIF.

  "Save batch to temporary
  lt_batch2[] = gt_batch2[].

  DELETE gt_resb WHERE splkz IS INITIAL AND
                       postp NE 'T'.

  DELETE gt_out WHERE erfmg IS INITIAL
                  AND nomng4 IS INITIAL.

  gt_xout[] = gt_out[].
*  SORT gt_xout BY phseq matnr2 nomng4 posnr.
*  DELETE ADJACENT DUPLICATES FROM gt_xout COMPARING phseq matnr2 nomng4. "posnr.
  SORT gt_xout BY phseq matnr2 nomng4 idx01 vornr posnr.
  DELETE ADJACENT DUPLICATES FROM gt_xout COMPARING phseq matnr2 nomng4 idx01 vornr. "posnr.
  SORT gt_resb BY matnr aufnr vornr posnr rsnum rspos.

  LOOP AT gt_xout INTO ls_xout WHERE granul = space.
    READ TABLE gt_resb INTO ls_resb WITH KEY matnr = ls_xout-matnr2
                                             vornr = ls_xout-vornr
                                             posnr = ls_xout-posnr
                                             TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    lv_nomngs = ls_xout-nomng4.

    IF lv_matnr3 = ls_xout-matnr2 AND
       lv_nomng3 = ls_xout-nomng4.
      IF lv_idx01 NE ls_xout-idx01.
        CLEAR lv_index.
        lv_matnr3 = ls_xout-matnr2.
        lv_nomng3 = ls_xout-nomng4.
        lv_idx01  = ls_xout-idx01.
      ENDIF.
    ELSE.
      CLEAR lv_index.
      lv_matnr3 = ls_xout-matnr2.
      lv_nomng3 = ls_xout-nomng4.
      lv_idx01  = ls_xout-idx01.
    ENDIF.

    CLEAR: lv_uline,lv_count2,lv_matnr2,lv_posnr2,lv_vornr2.
    CLEAR: ls_xout-erfmgt1,ls_xout-erfmgt2,ls_xout-erfmgt3,ls_xout-erfmgt4.
    CLEAR: lv_aufnr,lv_aufnrx,lv_posnr,lv_posnrx.

    LOOP AT gt_resb INTO ls_resb WHERE matnr = ls_xout-matnr2
                                   AND vornr = ls_xout-vornr
                                   AND posnr = ls_xout-posnr.
*      IF ls_resb-splkz IS INITIAL AND
*         ls_resb-bdmng IS INITIAL AND
*         ls_resb-erfmg IS INITIAL.
*        CONTINUE.
*      ENDIF.

      CLEAR: ls_afvc,ls_afvu.
      READ TABLE gt_afvc INTO ls_afvc WITH KEY aufpl = ls_resb-aufpl
                                               aplzl = ls_resb-aplzl.
      READ TABLE gt_afvu INTO ls_afvu WITH KEY aufpl = ls_resb-aufpl
                                               aplzl = ls_resb-aplzl.
      IF ls_afvc-phseq NE ls_xout-phseq.
        CONTINUE.
      ENDIF.

      CLEAR lv_nomng.
      CASE ls_resb-splkz.
        WHEN space.
          lv_nomng = ls_resb-bdmng.
        WHEN '1'.
          lv_nomng = ls_resb-nomng.
      ENDCASE.

      IF ls_resb-splkz = '1' OR ls_resb-splkz = space.
*        "Convertion Qty
*        IF ls_resb-meins NE ls_resb-erfme.
*          PERFORM f_uom_conversion USING lv_nomng
*                                         ls_resb-meins
*                                         ls_resb-erfme.
*        ENDIF.

*        IF lv_nomng NE ls_xout-erfmg.
        IF lv_nomng = ls_xout-nomng4.
          lv_aufnr = ls_resb-aufnr.
          lv_posnr = ls_resb-posnr.

          IF ls_resb-sortf = 'D' AND ls_resb-postp = 'L'.
            lv_index = 4.

          ELSEIF ls_resb-sortf = 'D' AND ls_resb-postp = 'T'.
            MOVE-CORRESPONDING ls_xout TO ls_out.
            ADD 1 TO lv_zno.
            ls_out-zno    = lv_zno.
            ls_out-meins3 = ls_out-meins2.
            ls_out-werks  = ls_resb-werks.
            ls_out-werks  = ls_resb-werks.
*            ls_out-sortf  = ls_resb-sortf.
            ls_out-usr02  = ls_afvu-usr02.

            APPEND ls_out TO lt_xout.

          ELSE.
            ADD 1 TO lv_index.
          ENDIF.

          CLEAR lv_zno.
        ELSE.
          lv_aufnrx = ls_resb-aufnr.
          lv_posnrx = ls_resb-posnr.
          CONTINUE.
        ENDIF.

      ELSEIF ls_resb-splkz = '2'.
        IF ls_resb-aufnr = lv_aufnrx AND
           ls_resb-posnr = lv_posnrx.
          CONTINUE.
        ENDIF.
        IF ls_resb-aufnr = lv_aufnr AND
           ls_resb-posnr = lv_posnr.
          CLEAR: lv_erfmg,lv_fieldname.
          MOVE-CORRESPONDING ls_xout TO ls_out.

          ADD 1 TO lv_zno.
          ls_out-zno = lv_zno.
          ls_out-rsnum  = ls_resb-rsnum.
          ls_out-rspos  = ls_resb-rspos.
          ls_out-charg2 = ls_resb-charg.
          ls_out-matnr3 = ls_out-matnr2.
          ls_out-meins3 = ls_out-meins2.
          ls_out-werks  = ls_resb-werks.
*          ls_out-sortf  = ls_resb-sortf.
          ls_out-usr02  = ls_afvu-usr02.

          IF ls_resb-wempf IS INITIAL.
            ls_out-wempf = 'F'.
          ELSE.
            ls_out-wempf = 'W'.
          ENDIF.

          "Assign operator
          IF ls_xout-operator IS NOT INITIAL AND
             ls_out-wempf = 'W'.
            CLEAR lv_fieldname.
            CONCATENATE 'LS_OUT-OPER' lv_index INTO lv_fieldname.
            ASSIGN (lv_fieldname) TO <fs>.
            CONCATENATE 'Opr:' ls_xout-operator INTO <fs>.
          ENDIF.

          "Assign pengawas
          IF ls_xout-pengawas IS NOT INITIAL AND
             ls_out-wempf = 'W'.
            CLEAR lv_fieldname.
            CONCATENATE 'LS_OUT-AWAS' lv_index INTO lv_fieldname.
            ASSIGN (lv_fieldname) TO <fs>.
            CONCATENATE 'Pws:' ls_xout-pengawas INTO <fs>.
          ENDIF.

          "Assign timbangan
          IF ls_out-wempf = 'W'.
            CLEAR lv_fieldname.
            CONCATENATE 'LS_OUT-SHTXT' lv_index INTO lv_fieldname.
            ASSIGN (lv_fieldname) TO <fs>.
            <fs> = ls_xout-shtxt.
          ENDIF.

          "Assign WBOOTH
          IF ls_xout-wbooth IS NOT INITIAL AND
             ls_out-wempf = 'W'.
            CLEAR lv_fieldname.
            CONCATENATE 'LS_OUT-WBOOTH' lv_index INTO lv_fieldname.
            ASSIGN (lv_fieldname) TO <fs>.
            CONCATENATE 'WB' ls_xout-wbooth INTO <fs>.
          ENDIF.

          "Assign Quantity
          IF ls_resb-erfmg IS NOT INITIAL.
            CLEAR: lv_erfmg,lv_fieldname.
            WRITE ls_resb-erfmg TO lv_erfmg UNIT ls_out-meins3.
            CONCATENATE 'LS_OUT-ERFMGT' lv_index INTO lv_fieldname.
            ASSIGN (lv_fieldname) TO <fs>.
            <fs> = lv_erfmg.
            CONDENSE <fs>.
            CONCATENATE <fs> ls_out-meins3 INTO <fs> SEPARATED BY space.
          ENDIF.

          "Assign batch
          CLEAR lv_fieldname.
          CONCATENATE 'LS_OUT-BATCH' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          <fs> = ls_resb-charg.

          "Assign Seq.No
          CLEAR lv_fieldname.
          CONCATENATE 'LS_OUT-SEQNO' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          PERFORM f_get_seqno USING ls_out-phseq ls_out-matnr3 ls_out-nomng4
                                    ls_resb-charg
                              CHANGING <fs>.

          IF ls_out-zno = '0001'.
          ELSE.
            CLEAR: ls_out-matnr2,ls_out-maktx2,ls_out-bdmngt,ls_out-meins2.
          ENDIF.

          READ TABLE lt_xout WITH KEY matnr3 = ls_out-matnr3
                                      erfmg  = ls_out-erfmg
                                      phseq  = ls_xout-phseq
                                      zno    = ls_out-zno
                                      idx01  = lv_idx01
                             TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CASE lv_index.
              WHEN '1'.
                MODIFY lt_xout INDEX sy-tabix FROM ls_out
                  TRANSPORTING charg2 shtxt erfmgt1 batch1 seqno1 oper1 awas1 shtxt1
                               wbooth1 zno seqno.
              WHEN '2'.
                MODIFY lt_xout INDEX sy-tabix FROM ls_out
                  TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                               erfmgt2 batch2 seqno2 oper2 awas2 shtxt2 wbooth2 zno seqno.
              WHEN '3'.
                MODIFY lt_xout INDEX sy-tabix FROM ls_out
                  TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                               erfmgt3 batch3 seqno3 oper3 awas3 shtxt3 wbooth3 zno seqno.
              WHEN '4'.
                MODIFY lt_xout INDEX sy-tabix FROM ls_out
                  TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                               erfmgt4 batch4 seqno4 oper4 awas4 shtxt4 wbooth4 zno seqno.
            ENDCASE.

          ELSE.
            APPEND ls_out TO lt_xout.

            IF ls_out-zno GT lv_uline.
              lv_uline = ls_out-zno.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF ls_out-matnr3 IS INITIAL.
      READ TABLE lt_xout ASSIGNING <fs_xout>
                         WITH KEY matnr3 = space
                                  phseq  = ls_out-phseq
                                  nomng4 = ls_xout-nomng4
                                  idx01  = lv_idx01
                                  zno    = '0001'.
    ELSE.
      READ TABLE lt_xout ASSIGNING <fs_xout>
                         WITH KEY matnr3 = ls_out-matnr3
                                  phseq  = ls_out-phseq
                                  nomng4 = ls_xout-nomng4
                                  idx01  = lv_idx01
                                  zno    = lv_uline.    "ls_out-zno.
    ENDIF.
    IF sy-subrc = 0.
      <fs_xout>-uline = 'X'.

      IF lv_uline GT '0001' AND
         <fs_xout>-wempf = 'W'.
        lv_loop = lv_uline - 1.
        DO lv_loop TIMES.
          SUBTRACT 1 FROM lv_uline.
          READ TABLE lt_xout ASSIGNING <fs_xout2>
                             WITH KEY matnr3 = ls_out-matnr3
                                      phseq  = ls_out-phseq
                                      nomng4 = ls_xout-nomng4
                                      idx01  = lv_idx01
                                      zno    = lv_uline.    "ls_out-zno.
          IF sy-subrc = 0.
            CLEAR <fs_xout2>-uline.

            DO 4 TIMES.
              ADD 1 TO lv_index2.

              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout2>-oper' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs2>.
              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout>-oper' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs>.
              PERFORM f_modify_field USING    <fs2>
                                     CHANGING <fs>.

              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout2>-awas' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs2>.
              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout>-awas' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs>.
              PERFORM f_modify_field USING    <fs2>
                                     CHANGING <fs>.

              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout2>-shtxt' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs2>.
              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout>-shtxt' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs>.
              PERFORM f_modify_field USING    <fs2>
                                     CHANGING <fs>.

              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout2>-wbooth' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs2>.
              CLEAR lv_fieldname.
              CONCATENATE '<fs_xout>-wbooth' lv_index2 INTO lv_fieldname.
              ASSIGN (lv_fieldname) TO <fs>.
              PERFORM f_modify_field USING    <fs2>
                                     CHANGING <fs>.
            ENDDO.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_xout INTO ls_xout WHERE granul = 'X'.
    lv_nomngs = ls_xout-nomng4.

    CLEAR: lv_index,lv_uline,lv_rwork.
    CLEAR: ls_xout-erfmgt1,ls_xout-erfmgt2,ls_xout-erfmgt3,ls_xout-erfmgt4.
    CLEAR: lv_aufnr,lv_aufnrx,lv_posnr,lv_posnrx.
    ADD 1 TO lv_matnr.

    LOOP AT gt_ztspppdt008 INTO ls_ztspppdt008.
      IF ls_xout-maktx2 CS ls_ztspppdt008-rwork.
        lv_rwork = ls_ztspppdt008-rwork.
        EXIT.
      ELSE.
        CLEAR lv_rwork.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_ztspppdt007 INTO ls_ztspppdt007.
      IF ls_ztspppdt007-maktx CS lv_rwork.
      ELSE.
        CONTINUE.
      ENDIF.

      CLEAR lv_zno.
      ADD 1 TO lv_index.

      LOOP AT gt_ztspppdt007d INTO ls_ztspppdt007d
                              WHERE werks = ls_ztspppdt007-werks
                                AND afind = ls_ztspppdt007-afind
                                AND afinu = ls_ztspppdt007-afinu.
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            input  = ls_ztspppdt007d-charg
*          IMPORTING
*            output = ls_ztspppdt007d-charg.

        MOVE-CORRESPONDING ls_xout TO ls_out.

        ADD 1 TO lv_zno.
        ls_out-zno = lv_zno.
        ls_out-maktx2 = ls_out-maktx2(18).
        ls_out-charg2 = ls_ztspppdt007d-charg.
        CONCATENATE 'Z' lv_rwork INTO ls_out-matnr3.
        ls_out-meins3 = ls_out-meins2.
        ls_out-werks  = ls_ztspppdt007d-werks.

        "Assign operator
        IF ls_xout-operator IS NOT INITIAL.
          CLEAR lv_fieldname.
          CONCATENATE 'LS_OUT-OPER' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          CONCATENATE 'Opr:' ls_xout-operator INTO <fs>.
        ENDIF.

        "Assign pengawas
        IF ls_xout-pengawas IS NOT INITIAL.
          CLEAR lv_fieldname.
          CONCATENATE 'LS_OUT-AWAS' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          CONCATENATE 'Pws:' ls_xout-pengawas INTO <fs>.
        ENDIF.

        "Assign timbangan
        CLEAR lv_fieldname.
        CONCATENATE 'LS_OUT-SHTXT' lv_index INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        <fs> = ls_xout-shtxt.

        "Assign WBOOTH
        IF ls_ztspppdt007-wbooth IS NOT INITIAL.
          CLEAR lv_fieldname.
          CONCATENATE 'LS_OUT-WBOOTH' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          CONCATENATE 'WB' ls_ztspppdt007-wbooth INTO <fs>.
        ENDIF.

        "Assign Quantity
        IF ls_ztspppdt007d-netto IS NOT INITIAL.
          CLEAR: lv_erfmg,lv_fieldname.
          WRITE ls_ztspppdt007d-netto TO lv_erfmg UNIT ls_out-meins3.
          CONCATENATE 'LS_OUT-ERFMGT' lv_index INTO lv_fieldname.
          ASSIGN (lv_fieldname) TO <fs>.
          <fs> = lv_erfmg.
          CONDENSE <fs>.
          CONCATENATE <fs> ls_out-meins3 INTO <fs> SEPARATED BY space.
        ENDIF.

        "Assign batch
        CLEAR lv_fieldname.
        CONCATENATE 'LS_OUT-BATCH' lv_index INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        <fs> = ls_ztspppdt007d-charg.

        "Assign Seq.No
        CLEAR lv_fieldname.
        CONCATENATE 'LS_OUT-SEQNO' lv_index INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        PERFORM f_get_seqno USING ls_out-phseq ls_out-matnr3 ls_out-nomng4
                                  ls_ztspppdt007d-charg
                            CHANGING <fs>.

        IF ls_out-zno = '0001'.
        ELSE.
          CLEAR: ls_out-matnr2,ls_out-maktx2,ls_out-bdmngt,ls_out-meins2.
        ENDIF.

        READ TABLE lt_xout WITH KEY matnr3 = ls_out-matnr3
                                    erfmg  = ls_out-erfmg
                                    phseq  = ls_out-phseq
                                    zno    = ls_out-zno
                           TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          CASE lv_index.
            WHEN '1'.
              MODIFY lt_xout INDEX sy-tabix FROM ls_out
                TRANSPORTING charg2 shtxt erfmgt1 batch1 seqno1 oper1 awas1 shtxt1
                             wbooth1 zno.
            WHEN '2'.
              MODIFY lt_xout INDEX sy-tabix FROM ls_out
                TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                             erfmgt2 batch2 seqno2 oper2 awas2 shtxt2 wbooth2 zno.
            WHEN '3'.
              MODIFY lt_xout INDEX sy-tabix FROM ls_out
                TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                             erfmgt3 batch3 seqno3 oper3 awas3 shtxt3 wbooth3 zno.
            WHEN '4'.
              MODIFY lt_xout INDEX sy-tabix FROM ls_out
                TRANSPORTING matnr2 maktx2 charg2 shtxt bdmngt meins2 operator pengawas
                             erfmgt4 batch4 seqno4 oper4 awas4 shtxt4 wbooth4 zno.
          ENDCASE.

        ELSE.
          APPEND ls_out TO lt_xout.

          IF ls_out-zno GT lv_uline.
            lv_uline = ls_out-zno.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF ls_out-matnr3 IS INITIAL.
      READ TABLE lt_xout ASSIGNING <fs_xout>
                         WITH KEY matnr3 = space
                                  phseq  = ls_out-phseq
                                  nomng4 = ls_xout-nomng4
                                  zno    = '0001'.
    ELSE.
      READ TABLE lt_xout ASSIGNING <fs_xout>
                         WITH KEY matnr3 = ls_out-matnr3
                                  phseq  = ls_out-phseq
                                  nomng4 = ls_xout-nomng4
                                  zno    = lv_uline.    "ls_out-zno.
    ENDIF.
    IF sy-subrc = 0.
      <fs_xout>-uline = 'X'.
    ENDIF.
  ENDLOOP.

  "Modify POSNR
  LOOP AT lt_xout ASSIGNING <fs_xout>.
    IF <fs_xout>-matnr2 IS NOT INITIAL.
      lv_posnr  = <fs_xout>-posnr.
      lv_matnr2 = <fs_xout>-matnr2.
    ELSE.
      IF <fs_xout>-matnr3 = lv_matnr2 AND
         <fs_xout>-posnr NE lv_posnr.
        <fs_xout>-posnr = lv_posnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF p_new = 'X'.
    LOOP AT lt_xout ASSIGNING <fs_xout> WHERE uline = 'X'.
      CLEAR: lv_zno,ls_xout.
      lv_zno = <fs_xout>-zno - 1.
      READ TABLE lt_xout INTO ls_xout WITH KEY aufnr  = <fs_xout>-aufnr
                                               matnr3 = <fs_xout>-matnr3
                                               posnr  = <fs_xout>-posnr
                                               zno    = lv_zno.   "'0001'.
      PERFORM _f_modify_field USING    ls_xout-oper1
                              CHANGING <fs_xout>-oper1.
      PERFORM _f_modify_field USING    ls_xout-oper2
                              CHANGING <fs_xout>-oper2.
      PERFORM _f_modify_field USING    ls_xout-oper3
                              CHANGING <fs_xout>-oper3.
      PERFORM _f_modify_field USING    ls_xout-oper4
                              CHANGING <fs_xout>-oper4.
      PERFORM _f_modify_field USING    ls_xout-awas1
                              CHANGING <fs_xout>-awas1.
      PERFORM _f_modify_field USING    ls_xout-awas2
                              CHANGING <fs_xout>-awas2.
      PERFORM _f_modify_field USING    ls_xout-awas3
                              CHANGING <fs_xout>-awas3.
      PERFORM _f_modify_field USING    ls_xout-awas4
                              CHANGING <fs_xout>-awas4.
      PERFORM _f_modify_field USING    ls_xout-shtxt1
                              CHANGING <fs_xout>-shtxt1.
      PERFORM _f_modify_field USING    ls_xout-shtxt2
                              CHANGING <fs_xout>-shtxt2.
      PERFORM _f_modify_field USING    ls_xout-shtxt3
                              CHANGING <fs_xout>-shtxt3.
      PERFORM _f_modify_field USING    ls_xout-shtxt4
                              CHANGING <fs_xout>-shtxt4.
      PERFORM _f_modify_field USING    ls_xout-wbooth1
                              CHANGING <fs_xout>-wbooth1.
      PERFORM _f_modify_field USING    ls_xout-wbooth2
                              CHANGING <fs_xout>-wbooth2.
      PERFORM _f_modify_field USING    ls_xout-wbooth3
                              CHANGING <fs_xout>-wbooth3.
      PERFORM _f_modify_field USING    ls_xout-wbooth4
                              CHANGING <fs_xout>-wbooth4.
    ENDLOOP.

  ELSE.

    DELETE gt_batch2 WHERE charg IS INITIAL.

    SORT gt_operator BY phseq matnr nomng wempf.
    SORT gt_pengawas BY phseq matnr nomng wempf.

    "Assign Batch to Itab (1)
    LOOP AT lt_xout ASSIGNING <fs_xout>.
      CLEAR lv_nomngc.
      WRITE <fs_xout>-nomng4 TO lv_nomngc UNIT <fs_xout>-meins4.
      CONDENSE lv_nomngc.

      CLEAR <fs_xout>-charg2.
      LOOP AT gt_batch2 WHERE phseq = <fs_xout>-phseq
                          AND matnr = <fs_xout>-matnr3
                          AND nomng = lv_nomngc.
        <fs_xout>-charg2 = gt_batch2-charg.
        DELETE gt_batch2.
        EXIT.
      ENDLOOP.

      IF <fs_xout>-charg2 IS INITIAL.
        CLEAR: <fs_xout>-batch1,<fs_xout>-batch2,<fs_xout>-batch3,
               <fs_xout>-batch4,<fs_xout>-seqno1,<fs_xout>-seqno2,
               <fs_xout>-seqno3,<fs_xout>-seqno4,<fs_xout>-seqno.
      ENDIF.

      CLEAR <fs_xout>-operator.
      LOOP AT gt_operator WHERE phseq = <fs_xout>-phseq
                            AND matnr = <fs_xout>-matnr3
                            AND nomng = lv_nomngc.
        <fs_xout>-operator = gt_operator-operator.
        DELETE gt_operator.
        EXIT.
      ENDLOOP.

      CLEAR <fs_xout>-pengawas.
      LOOP AT gt_pengawas WHERE phseq = <fs_xout>-phseq
                            AND matnr = <fs_xout>-matnr3
                            AND nomng = lv_nomngc.
        <fs_xout>-pengawas = gt_pengawas-pengawas.
        DELETE gt_pengawas.
        EXIT.
      ENDLOOP.

      CLEAR <fs_xout>-shtxt.
      LOOP AT gt_shtxt WHERE phseq = <fs_xout>-phseq
                         AND matnr = <fs_xout>-matnr3
                         AND nomng = lv_nomngc.
        <fs_xout>-shtxt = gt_shtxt-shtxt.
        DELETE gt_shtxt.
        EXIT.
      ENDLOOP.
    ENDLOOP.

    "Assign Batch to Itab (2)
    LOOP AT lt_xout ASSIGNING <fs_xout> WHERE uline = 'X'.
      CLEAR lv_nomngc.
      WRITE <fs_xout>-nomng4 TO lv_nomngc UNIT <fs_xout>-meins4.
      CONDENSE lv_nomngc.

      READ TABLE gt_batch2 WITH KEY phseq = <fs_xout>-phseq
                                    matnr = <fs_xout>-matnr3
                                    TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_zno = <fs_xout>-zno.

        LOOP AT gt_batch2 WHERE phseq = <fs_xout>-phseq
                            AND matnr = <fs_xout>-matnr3
                            AND nomng = lv_nomngc.
          IF <fs_xout>-uline = 'X'.
            CLEAR <fs_xout>-uline.
          ENDIF.

          ADD 1 TO lv_zno.
          APPEND INITIAL LINE TO lt_xout2 ASSIGNING <fs_xout2>.
          MOVE-CORRESPONDING <fs_xout> TO <fs_xout2>.
          <fs_xout2>-charg2 = gt_batch2-charg.
          <fs_xout2>-zno    = lv_zno.


          CLEAR <fs_xout2>-operator.
          LOOP AT gt_operator WHERE phseq = <fs_xout2>-phseq
                                AND matnr = <fs_xout2>-matnr3
                                AND nomng = lv_nomngc.
            <fs_xout2>-operator = gt_operator-operator.
            DELETE gt_operator.
            EXIT.
          ENDLOOP.

          CLEAR <fs_xout2>-pengawas.
          LOOP AT gt_pengawas WHERE phseq = <fs_xout2>-phseq
                                AND matnr = <fs_xout2>-matnr3
                                AND nomng = lv_nomngc.
            <fs_xout2>-pengawas = gt_pengawas-pengawas.
            DELETE gt_pengawas.
            EXIT.
          ENDLOOP.

          CLEAR <fs_xout2>-shtxt.
          LOOP AT gt_shtxt WHERE phseq = <fs_xout2>-phseq
                             AND matnr = <fs_xout2>-matnr3
                             AND nomng = lv_nomngc.
            <fs_xout2>-shtxt = gt_shtxt-shtxt.
            DELETE gt_shtxt.
            EXIT.
          ENDLOOP.

          CLEAR: <fs_xout2>-matnr2,<fs_xout2>-maktx2,<fs_xout2>-meins2,
                 <fs_xout2>-bdmngt,<fs_xout2>-erfmgt1,                  "<fs_xout2>-shtxt,
                 <fs_xout2>-erfmgt2,<fs_xout2>-erfmgt3,<fs_xout2>-erfmgt4.
        ENDLOOP.

        <fs_xout2>-uline = 'X'.
      ENDIF.
    ENDLOOP.

    IF lt_xout2[] IS NOT INITIAL.
      APPEND LINES OF lt_xout2 TO lt_xout.
    ENDIF.
  ENDIF.

  SORT lt_xout BY aufnr matnr phseq matnr3 zno.
  lt_xout01[] = lt_xout[].
  DELETE lt_xout01 WHERE zno NE '0001'.

  LOOP AT lt_xout01 INTO ls_xout01.
    lv_t1 = 'X'. lv_t2 = 'X'. lv_t3 = 'X'. lv_t4 = 'X'.
    LOOP AT lt_xout INTO ls_xout WHERE phseq  = ls_xout01-phseq
                                   AND matnr3 = ls_xout01-matnr3
                                   AND nomng4 = ls_xout01-nomng4.
      "Assign Seq.No
      lv_nomngc = ls_xout-nomng4.
      REPLACE ALL OCCURRENCES OF '.' IN lv_nomngc WITH ','.
      CONDENSE lv_nomngc.

      CLEAR lt_batch2.
      READ TABLE lt_batch2 WITH KEY phseq = ls_xout-phseq
                                    matnr = ls_xout-matnr3
                                    nomng = lv_nomngc
                                    charg = ls_xout-charg2(10).
      ls_xout-seqno = lt_batch2-seqno.
      MODIFY lt_xout FROM ls_xout TRANSPORTING seqno.

      IF ls_xout-erfmgt1 IS NOT INITIAL.
        CLEAR lv_t1.
      ENDIF.
      IF ls_xout-erfmgt2 IS NOT INITIAL.
        CLEAR lv_t2.
      ENDIF.
      IF ls_xout-erfmgt3 IS NOT INITIAL.
        CLEAR lv_t3.
      ENDIF.
      IF ls_xout-erfmgt4 IS NOT INITIAL.
        CLEAR lv_t4.
      ENDIF.
    ENDLOOP.

    IF lv_t1 = 'X'.
      ls_xout-erfmgt1 = 'X'.
      MODIFY lt_xout FROM ls_xout TRANSPORTING erfmgt1
                     WHERE phseq  = ls_xout01-phseq
                       AND matnr3 = ls_xout01-matnr3
                       AND nomng4 = ls_xout01-nomng4.
    ENDIF.

    IF lv_t2 = 'X'.
      ls_xout-erfmgt2 = 'X'.
      MODIFY lt_xout FROM ls_xout TRANSPORTING erfmgt2
                     WHERE phseq  = ls_xout01-phseq
                       AND matnr3 = ls_xout01-matnr3
                       AND nomng4 = ls_xout01-nomng4.
    ENDIF.

    IF lv_t3 = 'X'.
      ls_xout-erfmgt3 = 'X'.
      MODIFY lt_xout FROM ls_xout TRANSPORTING erfmgt3
                     WHERE phseq  = ls_xout01-phseq
                       AND matnr3 = ls_xout01-matnr3
                       AND nomng4 = ls_xout01-nomng4.
    ENDIF.

    IF lv_t4 = 'X'.
      ls_xout-erfmgt4 = 'X'.
      MODIFY lt_xout FROM ls_xout TRANSPORTING erfmgt4
                     WHERE phseq  = ls_xout01-phseq
                       AND matnr3 = ls_xout01-matnr3
                       AND nomng4 = ls_xout01-nomng4.
    ENDIF.
  ENDLOOP.

  IF lt_xout[] IS NOT INITIAL.
    gt_xout[] = lt_xout[].

    IF p_new = 'X'.
      PERFORM f_fullpack_faktorisasi.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_MODIFY_ZRM_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMBANG
*&---------------------------------------------------------------------*
FORM f_get_timbang  USING    fu_aufnr fu_matnr fu_rspos fu_meins fu_charg
                             fu_phseq fu_posnr fu_nomng
                    CHANGING fc_charg.
  DATA : ls_aufm    LIKE LINE OF gt_aufm,
         lv_erfmg   TYPE aufm-erfmg,
         lv_nomng   TYPE char15.

  READ TABLE gt_batch WITH KEY matnr = fu_matnr
                               aufnr = fu_aufnr
                               posnr = fu_posnr
                               charg = fu_charg.
  IF sy-subrc = 0.
  ELSE.
    IF fc_charg IS INITIAL.
      fc_charg = fu_charg.
    ELSE.
      CONCATENATE fc_charg fu_charg INTO fc_charg
        SEPARATED BY ','.
    ENDIF.

    gt_batch-matnr = fu_matnr.
    gt_batch-aufnr = fu_aufnr.
    gt_batch-posnr = fu_posnr.
    gt_batch-charg = fu_charg.
    APPEND gt_batch. CLEAR gt_batch.

    WRITE fu_nomng TO lv_nomng. "UNIT fu_meins.
    CONDENSE lv_nomng.

    gt_batch2-phseq = fu_phseq.
    gt_batch2-matnr = fu_matnr.
    gt_batch2-nomng = lv_nomng.
    gt_batch2-charg = fu_charg.
    COLLECT gt_batch2. CLEAR gt_batch2.
  ENDIF.
ENDFORM.                    " F_GET_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_ZPM_RESERVATION_DETAIL
*&---------------------------------------------------------------------*
FORM f_zpm_reservation_detail  USING    fs_afpo       TYPE afpo
                                        fs_makt       TYPE makt
                                        fs_mch1       TYPE mch1
                                        fs_marc       TYPE marc
                                        fs_marm01     TYPE marm
                                        fs_marm02     TYPE marm
                                        fs_marm03     TYPE marm
                                        fs_marm04     TYPE marm
                                        fs_t006a01    TYPE t006a
                                        fs_t006a02    TYPE t006a.
  DATA : ls_resb          LIKE LINE OF gt_resb,
         ls_makt2         LIKE LINE OF gt_makt2,
         ls_ztspppdt001   LIKE LINE OF gt_ztspppdt001,
         ls_aufm          LIKE LINE OF gt_aufm.

  DATA : lv_key1 TYPE char20,
         lv_key2 TYPE char20.

  LOOP AT gt_resb INTO ls_resb WHERE aufnr = fs_afpo-aufnr
                                 AND bdmng IS NOT INITIAL.
    IF ls_resb-charg IS INITIAL.
      ls_resb-charg = '-'.
    ENDIF.

    CLEAR: ls_makt2.
    READ TABLE gt_makt2 INTO ls_makt2 WITH KEY matnr = ls_resb-matnr.

    lv_key1 = ls_resb-matnr.

*    CASE 'X'.
*      WHEN radio1.
*      WHEN radio2.
*        READ TABLE gt_add INTO ls_add WITH KEY aufnr = ls_resb-aufnr
*                                               matnr = ls_resb-matnr
*                                               posnr = ls_resb-posnr.
*
*        lv_key2 = 'X'.
*    ENDCASE.

    IF lv_key1 = lv_key2.
*        CONCATENATE <fs_out>-charg2 ls_resb-charg INTO <fs_out>-charg2
*          SEPARATED BY ','.
      ADD ls_resb-bdmng TO <fs_out>-bdmng.
    ELSE.
      lv_key2 = lv_key1.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-aufnr = fs_afpo-aufnr.
      <fs_out>-matnr = fs_afpo-matnr.
      <fs_out>-maktx = fs_makt-maktx.
      <fs_out>-meins = fs_afpo-meins.
      <fs_out>-charg = fs_afpo-charg.
      <fs_out>-vfdat = fs_mch1-vfdat.
      <fs_out>-bstfe = fs_marc-bstfe.

*      <fs_out>-shtxt      = ls_add-shtxt.
*      <fs_out>-operator   = ls_add-operator.
*      <fs_out>-pengawas   = ls_add-pengawas.

      IF <fs_out>-bstfe IS INITIAL.
        <fs_out>-bstfe = gt_stko-bmeng.
      ENDIF.

      IF fs_marm03-umrez IS NOT INITIAL.
        <fs_out>-qtyconv2 = fs_afpo-wemng * fs_marm03-umren / fs_marm03-umrez. "Qty SW
        <fs_out>-uomconv2 = fs_marm03-meinh.
      ENDIF.

      IF fs_marm04-umrez IS NOT INITIAL.
        <fs_out>-qtyconv1 = fs_afpo-wemng * fs_marm04-umren / fs_marm04-umrez. "Qty FBX
        <fs_out>-uomconv1 = fs_marm04-meinh.
      ENDIF.

      <fs_out>-qtybls = <fs_out>-bstfe * fs_marm01-umren.
      <fs_out>-qtytab = <fs_out>-bstfe * fs_marm02-umren.
      <fs_out>-qtynyata = fs_afpo-wemng * fs_marm02-umren.
      <fs_out>-uombls = fs_t006a01-mseht.
      <fs_out>-uomtab = fs_t006a02-mseht.
      <fs_out>-matnr2 = ls_resb-matnr.
      <fs_out>-maktx2 = ls_makt2-maktx.
*        <fs_out>-charg2 = ls_resb-charg.
      <fs_out>-meins2 = ls_resb-meins.
      <fs_out>-bdmng = ls_resb-bdmng.
*        <fs_out>-rsnum = ls_resb-rsnum.
*        <fs_out>-rspos = ls_resb-rspos.
*        <fs_out>-rsart = ls_resb-rsart.

      READ TABLE gt_ztspppdt001 INTO ls_ztspppdt001
                                WITH KEY aufnr = <fs_out>-aufnr
                                         matnr = <fs_out>-matnr2.
      IF sy-subrc = 0.
        <fs_out>-baik  = ls_ztspppdt001-qty_baik.
        <fs_out>-rusak = ls_ztspppdt001-qty_rusak.
      ENDIF.

      LOOP AT gt_aufm INTO ls_aufm WHERE aufnr = ls_resb-aufnr
                                     AND matnr = ls_resb-matnr
                                     AND erfmg IS NOT INITIAL.
        IF ls_aufm-charg IS INITIAL.
          ls_aufm-charg = '-'.
        ENDIF.
        IF ls_aufm-shkzg = 'S'.
          ls_aufm-erfmg = ls_aufm-erfmg * -1.
        ENDIF.
        IF <fs_out>-charg2 IS INITIAL.
          <fs_out>-charg2 = ls_aufm-charg.
        ELSE.
          CONCATENATE <fs_out>-charg2 ls_aufm-charg INTO <fs_out>-charg2
            SEPARATED BY ','.
        ENDIF.

        ADD ls_aufm-erfmg TO <fs_out>-erfmg.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ZPM_RESERVATION_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ZRM_RESERVATION_DETAIL
*&---------------------------------------------------------------------*
FORM f_zrm_reservation_detail  USING    fs_afpo       TYPE afpo
                                        fs_makt       TYPE makt
                                        fs_mch1       TYPE mch1
                                        fs_marc       TYPE marc
                                        fs_marm01     TYPE marm
                                        fs_marm02     TYPE marm
                                        fs_marm03     TYPE marm
                                        fs_marm04     TYPE marm
                                        fs_t006a01    TYPE t006a
                                        fs_t006a02    TYPE t006a.
  DATA : ls_xresb   LIKE LINE OF gt_xresb,
         ls_resb    LIKE LINE OF gt_resb,
         ls_makt2   LIKE LINE OF gt_makt2,
         ls_add     LIKE LINE OF gt_add,
         ls_afvc    LIKE LINE OF gt_afvc,
         ls_ztspppdt007 LIKE LINE OF gt_ztspppdt007,
         ls_ztspppdt007d LIKE LINE OF gt_ztspppdt007d,
         lv_posnr   TYPE numc4,
         lv_bdmng   TYPE resb-bdmng,
         lv_nomng   TYPE char15,
         lv_erfmg   TYPE resb-erfmg.

  SORT gt_xresb BY matnr aufnr posnr rsnum rspos.
  SORT gt_resb BY matnr aufnr posnr rsnum rspos.
  LOOP AT gt_xresb INTO ls_xresb WHERE aufnr = fs_afpo-aufnr.
    CLEAR: ls_makt2.
    READ TABLE gt_makt2 INTO ls_makt2 WITH KEY matnr = ls_xresb-matnr.

*    lv_key1 = ls_resb-matnr.

    CLEAR: ls_add,ls_afvc.
    READ TABLE gt_add INTO ls_add WITH KEY aufnr = ls_xresb-aufnr
                                           matnr = ls_xresb-matnr
                                           posnr = ls_xresb-posnr.
    READ TABLE gt_afvc INTO ls_afvc WITH KEY aufpl = ls_xresb-aufpl
                                             aplzl = ls_xresb-aplzl.

*    lv_key2 = lv_key1.
    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
    <fs_out>-aufnr      = fs_afpo-aufnr.
    <fs_out>-matnr      = fs_afpo-matnr.
    <fs_out>-maktx      = fs_makt-maktx.
    <fs_out>-meins      = fs_afpo-meins.
    <fs_out>-charg      = fs_afpo-charg.
    <fs_out>-vfdat      = fs_mch1-vfdat.
    <fs_out>-bstfe      = fs_marc-bstfe.

    <fs_out>-shtxt      = ls_add-shtxt.
    <fs_out>-operator   = ls_add-operator.
    <fs_out>-pengawas   = ls_add-pengawas.

    <fs_out>-posnr      = ls_xresb-posnr.
    <fs_out>-vornr      = ls_xresb-vornr.
    <fs_out>-phseq      = ls_afvc-phseq.
    <fs_out>-ltxa1      = ls_afvc-ltxa1.

    IF ls_xresb-sortf = 'P'.
      <fs_out>-sortf    = ls_xresb-sortf.
    ELSEIF ls_xresb-sortf = 'D'.
      <fs_out>-sortf2   = ls_xresb-sortf.
    ENDIF.

    IF <fs_out>-bstfe IS INITIAL.
      <fs_out>-bstfe    = gt_stko-bmeng.
    ENDIF.

    IF fs_marm03-umrez IS NOT INITIAL.
      <fs_out>-qtyconv2 = fs_afpo-wemng * fs_marm03-umren / fs_marm03-umrez. "Qty SW
      <fs_out>-uomconv2 = fs_marm03-meinh.
    ENDIF.

    IF fs_marm04-umrez IS NOT INITIAL.
      <fs_out>-qtyconv1 = fs_afpo-wemng * fs_marm04-umren / fs_marm04-umrez. "Qty FBX
      <fs_out>-uomconv1 = fs_marm04-meinh.
    ENDIF.

    <fs_out>-qtybls     = <fs_out>-bstfe * fs_marm01-umren.
    <fs_out>-qtytab     = <fs_out>-bstfe * fs_marm02-umren.
    <fs_out>-qtynyata   = fs_afpo-wemng * fs_marm02-umren.
    <fs_out>-uombls     = fs_t006a01-mseht.
    <fs_out>-uomtab     = fs_t006a02-mseht.
    <fs_out>-matnr2     = ls_xresb-matnr.
    <fs_out>-maktx2     = ls_makt2-maktx.

    LOOP AT gt_resb INTO ls_resb WHERE matnr = ls_xresb-matnr
                                   AND aufnr = ls_xresb-aufnr
                                   AND posnr = ls_xresb-posnr.
*                                   AND splkz IS NOT INITIAL
*                                   AND splkz NE '1'.
*                                   AND erfmg IS NOT INITIAL.

      CLEAR: lv_bdmng,lv_erfmg.
      lv_bdmng  = ls_resb-erfmg.
      CASE ls_resb-splkz.
        WHEN space.
          <fs_out>-nomng4 = ls_resb-bdmng.
          <fs_out>-maktx2 = ls_resb-potx1.
          lv_erfmg  = ls_resb-erfmg.

        WHEN '1'.
          <fs_out>-nomng4 = ls_resb-nomng.

        WHEN '2'.
          lv_erfmg  = ls_resb-erfmg.
      ENDCASE.

      ADD ls_resb-bdmng TO <fs_out>-bdmng4.
      ADD lv_bdmng TO <fs_out>-bdmng.
      ADD lv_erfmg TO <fs_out>-erfmg.

      <fs_out>-meins2 = ls_resb-erfme.
      <fs_out>-meins4 = ls_resb-meins.

      PERFORM f_get_timbang USING ls_resb-aufnr ls_resb-matnr ls_resb-rspos
                                  ls_resb-meins ls_resb-charg <fs_out>-phseq
                                  <fs_out>-posnr <fs_out>-nomng4
                            CHANGING <fs_out>-charg2.

      PERFORM f_change_operator USING ls_resb-rsnum
                                      ls_resb-rspos
                                      ls_resb-matnr
                                      ls_resb-wempf
                                      <fs_out>-phseq
                                      ls_add-operator
                                      ls_add-pengawas
                                      <fs_out>-nomng4
                                      ls_resb-meins
                                CHANGING <fs_out>-operator
                                         <fs_out>-pengawas
                                         <fs_out>-shtxt.
    ENDLOOP.

    WRITE: <fs_out>-bdmng TO <fs_out>-bdmngt UNIT <fs_out>-meins2.

    gt_phseq-phseq = ls_afvc-phseq.
    COLLECT gt_phseq. CLEAR gt_phseq.
  ENDLOOP.

  LOOP AT gt_ztspppdt007 INTO ls_ztspppdt007 WHERE aufnr = fs_afpo-aufnr.
    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
    <fs_out>-aufnr      = fs_afpo-aufnr.
    <fs_out>-matnr      = fs_afpo-matnr.
    <fs_out>-maktx      = fs_makt-maktx.
    <fs_out>-meins      = fs_afpo-meins.
    <fs_out>-charg      = fs_afpo-charg.
    <fs_out>-vfdat      = fs_mch1-vfdat.
    <fs_out>-bstfe      = fs_marc-bstfe.

*    ADD 10 TO lv_posnr.
*    <fs_out>-posnr      = lv_posnr.
    <fs_out>-shtxt      = ls_ztspppdt007-shtxt.
    <fs_out>-operator   = ls_ztspppdt007-operator.
    <fs_out>-pengawas   = ls_ztspppdt007-pengawas.
    <fs_out>-phseq      = ls_ztspppdt007-phseq.
    <fs_out>-maktx2     = ls_ztspppdt007-maktx.
    <fs_out>-meins2     = ls_ztspppdt007-meins.
    <fs_out>-bdmng      = ls_ztspppdt007-netto.
    <fs_out>-erfmg      = ls_ztspppdt007-netto.
    <fs_out>-nomng4     = ls_ztspppdt007-netto.
    <fs_out>-meins4     = ls_ztspppdt007-meins.
    <fs_out>-granul     = 'X'.

*    <fs_out>-ltxa1      = ls_afvc-ltxa1.

    gt_operator-phseq = <fs_out>-phseq.
    gt_operator-matnr = 'ZZZZZZ'.
*    gt_operator-wempf = <fs_out>-wempf.
    gt_operator-operator = <fs_out>-operator.
    WRITE <fs_out>-nomng4 TO gt_operator-nomng UNIT <fs_out>-meins.
    CONDENSE gt_operator-nomng.
    COLLECT gt_operator. CLEAR gt_operator.

    gt_pengawas-phseq = <fs_out>-phseq.
    gt_pengawas-matnr = 'ZZZZZZ'.
*    gt_pengawas-wempf = <fs_out>-wempf.
    gt_pengawas-pengawas = <fs_out>-pengawas.
    WRITE <fs_out>-nomng4 TO gt_pengawas-nomng UNIT <fs_out>-meins.
    CONDENSE gt_pengawas-nomng.
    COLLECT gt_pengawas. CLEAR gt_pengawas.

    IF <fs_out>-shtxt IS NOT INITIAL.
      gt_shtxt-phseq = <fs_out>-phseq.
      gt_shtxt-matnr = 'ZZZZZZ'.
      gt_shtxt-shtxt = <fs_out>-shtxt.
      WRITE <fs_out>-nomng4 TO gt_shtxt-nomng UNIT <fs_out>-meins.
      CONDENSE gt_shtxt-nomng.
      COLLECT gt_shtxt. CLEAR gt_shtxt.
    ENDIF.

    LOOP AT gt_ztspppdt007d INTO ls_ztspppdt007d
                            WHERE werks = ls_ztspppdt007-werks
                              AND afind = ls_ztspppdt007-afind
                              AND afinu = ls_ztspppdt007-afinu.
*      READ TABLE gt_batch WITH KEY matnr = space
*                                   aufnr = ls_ztspppdt007-aufnr
*                                   posnr = space
*                                   charg = ls_ztspppdt007d-charg.
*      IF sy-subrc = 0.
*      ELSE.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_ztspppdt007d-charg
        IMPORTING
          output = ls_ztspppdt007d-charg.

      IF <fs_out>-charg2 IS INITIAL.
        <fs_out>-charg2 = ls_ztspppdt007d-charg.
      ELSE.
        CONCATENATE <fs_out>-charg2 ls_ztspppdt007d-charg
          INTO <fs_out>-charg2 SEPARATED BY ','.
      ENDIF.

      gt_batch-matnr = 'ZZZZZZ'.
      gt_batch-aufnr = ls_ztspppdt007-aufnr.
*      gt_batch-posnr = lv_posnr.
      gt_batch-charg = ls_ztspppdt007d-charg.
      APPEND gt_batch. CLEAR gt_batch.

      WRITE ls_ztspppdt007-netto TO lv_nomng. "UNIT ls_ztspppdt007d-meins.
      CONDENSE lv_nomng.

      gt_batch2-phseq = ls_ztspppdt007-phseq.
      gt_batch2-matnr = 'ZZZZZZ'.
      gt_batch2-nomng = lv_nomng.
      gt_batch2-charg = ls_ztspppdt007d-charg.
      COLLECT gt_batch2. CLEAR gt_batch2.
*      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_ZRM_RESERVATION_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDITIONAL_DATA
*&---------------------------------------------------------------------*
FORM f_get_additional_data .
  DATA lt_resb TYPE STANDARD TABLE OF resb.

  IF gt_resb[] IS NOT INITIAL.
    SELECT aufpl aplzl usr02
      INTO CORRESPONDING FIELDS OF TABLE gt_afvu
      FROM afvu FOR ALL ENTRIES IN gt_resb
      WHERE aufpl = gt_resb-aufpl
        AND aplzl = gt_resb-aplzl.

    SELECT *
      FROM zppresb_add
      INTO CORRESPONDING FIELDS OF TABLE gt_add
      FOR ALL ENTRIES IN gt_resb
      WHERE aufnr = gt_resb-aufnr
        AND matnr = gt_resb-matnr
        AND posnr = gt_resb-posnr.

    lt_resb[] = gt_resb[].
    SORT lt_resb BY aufpl aplzl.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufpl aplzl.
    SELECT aufpl aplzl phflg phseq ltxa1 steus
      INTO CORRESPONDING FIELDS OF TABLE gt_afvc
      FROM afvc FOR ALL ENTRIES IN lt_resb
      WHERE aufpl = lt_resb-aufpl
        AND aplzl = lt_resb-aplzl
        AND steus IN ('ZP00','ZP01')
        AND phflg = 'X'
        AND phseq LIKE 'W%'.
  ENDIF.

  SELECT * INTO TABLE gt_ztspppdt008
    FROM ztspppdt008 WHERE werks IN s_werks.

  SELECT * INTO TABLE gt_ztspppdt007
    FROM ztspppdt007 WHERE werks IN s_werks
                       AND aufnr EQ p_aufnr
                       AND phseq EQ 'W1'.
  IF gt_ztspppdt007[] IS NOT INITIAL.
    PERFORM f_modify_itab_ztspppdt007.
    SELECT * INTO TABLE gt_ztspppdt007d
      FROM ztspppdt007d FOR ALL ENTRIES IN gt_ztspppdt007
      WHERE werks = gt_ztspppdt007-werks
        AND afind = gt_ztspppdt007-afind
        AND afinu = gt_ztspppdt007-afinu.
  ENDIF.
ENDFORM.                    " F_GET_ADDITIONAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENTED_GOODS_MOVEMENTS
*&---------------------------------------------------------------------*
FORM f_documented_goods_movements .
  DATA : ls_mseg    LIKE LINE OF gt_mseg,
         ls_aufm    LIKE LINE OF gt_aufm,
         lt_aufm    TYPE STANDARD TABLE OF aufm.

  IF gt_aufm[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile bwart smbln sjahr smblp
      FROM mseg
      INTO TABLE gt_mseg
      FOR ALL ENTRIES IN gt_aufm
      WHERE mblnr = gt_aufm-mblnr
        AND mjahr = gt_aufm-mjahr
        AND zeile = gt_aufm-zeile.

    LOOP AT gt_mseg INTO ls_mseg.
      CASE ls_mseg-bwart.
        WHEN '262'.
          DELETE gt_mseg WHERE mblnr = ls_mseg-smbln
                           AND mjahr = ls_mseg-mjahr
                           AND zeile = ls_mseg-smblp.
          IF sy-subrc = 0.
            DELETE TABLE gt_mseg FROM ls_mseg.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  LOOP AT gt_aufm INTO ls_aufm.
    CLEAR ls_mseg.
    READ TABLE gt_mseg INTO ls_mseg
                       WITH KEY mblnr = ls_aufm-mblnr
                                mjahr = ls_aufm-mjahr
                                zeile = ls_aufm-zeile.
    IF sy-subrc <> 0.
      DELETE TABLE gt_aufm FROM ls_aufm.
    ENDIF.
  ENDLOOP.

  IF gt_aufm[] IS NOT INITIAL.
    lt_aufm[] = gt_aufm[].
    SORT lt_aufm BY mblnr mjahr zeile.
    DELETE ADJACENT DUPLICATES FROM lt_aufm COMPARING mblnr mjahr zeile.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
      FROM mkpf FOR ALL ENTRIES IN lt_aufm
      WHERE mblnr = lt_aufm-mblnr
        AND mjahr = lt_aufm-mjahr.
  ENDIF.

  gt_xresb[] = gt_resb[].
*  SORT gt_xresb BY matnr aufnr posnr.
*  DELETE ADJACENT DUPLICATES FROM gt_xresb COMPARING matnr aufnr posnr.
  DELETE gt_xresb WHERE splkz = '2'.
  SORT gt_xresb BY matnr aufnr posnr.
  SORT gt_resb BY matnr aufnr posnr.
ENDFORM.                    " F_DOCUMENTED_GOODS_MOVEMENTS

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_CONVERSION
*&---------------------------------------------------------------------*
FORM f_material_conversion  USING    fu_matnr fu_meins fu_meinh fu_erfmg
                            CHANGING fc_erfmg.
  DATA : lv_umren   TYPE marm-umren,
         lv_umrez   TYPE marm-umrez.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_erfmg
      matnr                = fu_matnr
      meinh                = fu_meinh
      meins                = fu_meins
    IMPORTING
      output               = fc_erfmg
      umren                = lv_umren
      umrez                = lv_umrez
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.
ENDFORM.                    " F_MATERIAL_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_OPERATOR
*&---------------------------------------------------------------------*
FORM f_change_operator  USING    fu_rsnum
                                 fu_rspos
                                 fu_matnr
                                 fu_wempf
                                 fu_phseq
                                 fu_operator
                                 fu_pengawas
                                 fu_nomng
                                 fu_meins
                        CHANGING fc_operator
                                 fc_pengawas
                                 fc_shtxt.
  DATA: ls_aufm LIKE LINE OF gt_aufm,
        ls_mkpf LIKE LINE OF gt_mkpf,
        lv_nomng TYPE char15,
        lv_bktxt1(10).

  IF fu_wempf IS INITIAL.    "Fullpack
*    CLEAR: fc_shtxt.
    READ TABLE gt_aufm INTO ls_aufm WITH KEY rsnum = fu_rsnum
                                             rspos = fu_rspos.
    READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_aufm-mblnr
                                             mjahr = ls_aufm-mjahr.
    SPLIT ls_mkpf-bktxt AT ';' INTO lv_bktxt1 fc_operator fc_pengawas.
  ELSE.
    fc_operator = fu_operator.
    fc_pengawas = fu_pengawas.
  ENDIF.

  WRITE fu_nomng TO lv_nomng UNIT fu_meins.
  CONDENSE lv_nomng.

  gt_operator-phseq = fu_phseq.
  gt_operator-matnr = fu_matnr.
  gt_operator-nomng = lv_nomng.
  gt_operator-wempf = fu_wempf.
  gt_operator-operator = fc_operator.
  COLLECT gt_operator. CLEAR gt_operator.

  gt_pengawas-phseq = fu_phseq.
  gt_pengawas-matnr = fu_matnr.
  gt_pengawas-nomng = lv_nomng.
  gt_pengawas-wempf = fu_wempf.
  gt_pengawas-pengawas = fc_pengawas.
  COLLECT gt_pengawas. CLEAR gt_pengawas.

  IF fc_shtxt IS NOT INITIAL.
    gt_shtxt-phseq = fu_phseq.
    gt_shtxt-matnr = fu_matnr.
    gt_shtxt-nomng = lv_nomng.
    gt_shtxt-shtxt = fc_shtxt.
    COLLECT gt_shtxt. CLEAR gt_shtxt.
  ENDIF.
ENDFORM.                    " F_CHANGE_OPERATOR

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_nomng
                                fu_meins
                                fu_meins2.
  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fu_nomng
      unit_in              = fu_meins
      unit_out             = fu_meins2
    IMPORTING
      output               = fu_nomng
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_PHSEQ
*&---------------------------------------------------------------------*
FORM f_f4_for_phseq  CHANGING fu_phseq.
  DATA lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'PHSEQ'   "field of internal table
      value_org  = 'S'
    TABLES
      value_tab  = gt_phseq
      return_tab = lt_return[].
  READ TABLE lt_return INDEX 1.
  WRITE lt_return-fieldval TO fu_phseq.
ENDFORM.                    " F_F4_FOR_PHSEQ

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_ZTSPPPDT007
*&---------------------------------------------------------------------*
FORM f_modify_itab_ztspppdt007 .
  DATA: lt_ztspppdt007_tmp  TYPE STANDARD TABLE OF ztspppdt007,
        ls_ztspppdt007      LIKE LINE OF gt_ztspppdt007.

  FIELD-SYMBOLS: <fs_ztspppdt007_tmp> TYPE ztspppdt007.

  SORT gt_ztspppdt007 BY werks aufnr afind afinu.
  LOOP AT gt_ztspppdt007 INTO ls_ztspppdt007.
    READ TABLE lt_ztspppdt007_tmp ASSIGNING <fs_ztspppdt007_tmp>
                                  WITH KEY werks = ls_ztspppdt007-werks
                                           aufnr = ls_ztspppdt007-aufnr
                                           maktx = ls_ztspppdt007-maktx.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_ztspppdt007 TO <fs_ztspppdt007_tmp>.
    ELSE.
      APPEND INITIAL LINE TO lt_ztspppdt007_tmp ASSIGNING <fs_ztspppdt007_tmp>.
      MOVE-CORRESPONDING ls_ztspppdt007 TO <fs_ztspppdt007_tmp>.
    ENDIF.
  ENDLOOP.

  gt_ztspppdt007[] = lt_ztspppdt007_tmp[].
ENDFORM.                    " F_MODIFY_ITAB_ZTSPPPDT007

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_GT_BATCH2
*&---------------------------------------------------------------------*
FORM f_modify_gt_batch2 .
  DATA: lv_key1(50), lv_key2(50), lv_seqno(1).

  DELETE gt_batch2 WHERE charg = space.

  LOOP AT gt_batch2.
    CLEAR lv_key1.
    CONCATENATE gt_batch2-phseq gt_batch2-matnr
      gt_batch2-nomng INTO lv_key1.

    IF lv_key1 NE lv_key2.
      lv_key2 = lv_key1.
      lv_seqno = '1'.
    ELSE.
      ADD 1 TO lv_seqno.
    ENDIF.

    gt_batch2-seqno = lv_seqno.
    MODIFY gt_batch2 TRANSPORTING seqno.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_GT_BATCH2

*&---------------------------------------------------------------------*
*&      Form  F_GET_SEQNO
*&---------------------------------------------------------------------*
FORM f_get_seqno  USING    fu_phseq
                           fu_matnr
                           fu_nomng
                           fu_charg
                  CHANGING fc_seqno.
  DATA: lv_nomng TYPE char15.

  lv_nomng = fu_nomng.
  REPLACE ALL OCCURRENCES OF '.' IN lv_nomng WITH ','.
  CONDENSE lv_nomng.

  CLEAR gt_batch2.
  READ TABLE gt_batch2 WITH KEY phseq = fu_phseq
                                matnr = fu_matnr
                                nomng = lv_nomng
                                charg = fu_charg.
  fc_seqno = gt_batch2-seqno.
ENDFORM.                    " F_GET_SEQNO

*&---------------------------------------------------------------------*
*&      Form  F_GET_WBOOTH
*&---------------------------------------------------------------------*
FORM f_get_wbooth .
  DATA: ls_add    LIKE LINE OF gt_add,
        lv_maktx  TYPE maktx.

  LOOP AT gt_out ASSIGNING <fs_out>.
    CLEAR ls_add.
    READ TABLE gt_add INTO ls_add WITH KEY aufnr = <fs_out>-aufnr
                                           matnr = <fs_out>-matnr2
                                           posnr = <fs_out>-posnr.
    <fs_out>-wbooth = ls_add-wbooth.
    lv_maktx = <fs_out>-maktx2.
    IF <fs_out>-matnr2 IS INITIAL.
      lv_maktx = <fs_out>-maktx2(18).
    ENDIF.

    PERFORM f_split_matdesc USING    lv_maktx
                            CHANGING <fs_out>-maktx3
                                     <fs_out>-maktx4
                                     <fs_out>-maktx5.
  ENDLOOP.
ENDFORM.                    " F_GET_WBOOTH

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_MATDESC
*&---------------------------------------------------------------------*
FORM f_split_matdesc  USING    fu_maktx
                      CHANGING fc_maktx1
                               fc_maktx2
                               fc_maktx3.
  DATA: lv_ok       TYPE char1,
        lv_len      TYPE int4,
        lv_get      TYPE int4,
        lv_get2     TYPE int4,
        lv_no1      TYPE numc1,
        lv_no2      TYPE numc1,
        lv_no3      TYPE numc1,
        lv_loop     TYPE int4,
        lv_cntr     TYPE numc1,
        lv_lenfield TYPE int4,
        lv_fieldnm  TYPE char10.

  CONSTANTS: lc_limit   TYPE int4 VALUE 22.

  FIELD-SYMBOLS: <fs_field>  TYPE ANY.

  CLEAR: lv_ok,lv_no1,lv_len,lv_lenfield,lv_get,lv_get2.

  lv_lenfield = STRLEN( fu_maktx ).

  WHILE lv_len LT lv_lenfield.
    CLEAR: lv_get,lv_ok,lv_fieldnm.
    ADD 1 TO lv_no1.
    lv_get = lc_limit + lv_len - 1.

    IF lv_get LT lv_lenfield.
      WHILE lv_ok IS INITIAL.
        IF fu_maktx+lv_get(1) = space OR
           fu_maktx+lv_get(1) = ',' OR
           fu_maktx+lv_get(1) = '.' OR
           fu_maktx+lv_get(1) = '/' OR
           fu_maktx+lv_get(1) = '\' OR
           fu_maktx+lv_get(1) = '(' OR
           fu_maktx+lv_get(1) = ')'.
          lv_ok = 'X'.
          lv_get2 = lv_get - lv_len.
          CONCATENATE 'FC_MAKTX' lv_no1 INTO lv_fieldnm.
          ASSIGN (lv_fieldnm) TO <fs_field>.
          <fs_field> = fu_maktx+lv_len(lv_get2).

          IF fu_maktx+lv_get(1) = '(' OR
             fu_maktx+lv_get(1) = '/' OR
             fu_maktx+lv_get(1) = '\'.
          ELSE.
            ADD 1 TO lv_get.
          ENDIF.
          lv_len = lv_get.
        ELSE.
          SUBTRACT 1 FROM lv_get.
        ENDIF.
      ENDWHILE.

    ELSE.
      lv_get2 = lv_lenfield - lv_len.
      CONCATENATE 'FC_MAKTX' lv_no1 INTO lv_fieldnm.
      ASSIGN (lv_fieldnm) TO <fs_field>.
      <fs_field> = fu_maktx+lv_len(lv_get2).
      ADD lv_get2 TO lv_len.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " F_SPLIT_MATDESC

*&---------------------------------------------------------------------*
*&      Form  _F_MODIFY_FIELD
*&---------------------------------------------------------------------*
FORM _f_modify_field  USING    fu_source
                      CHANGING fc_target.
  IF fc_target IS INITIAL.
    IF fu_source IS NOT INITIAL.
      fc_target = fu_source.
    ENDIF.
  ENDIF.
ENDFORM.                    " _F_MODIFY_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_FULLPACK_FAKTORISASI
*&---------------------------------------------------------------------*
FORM f_fullpack_faktorisasi .
  DATA: ls_xout   LIKE LINE OF gt_xout,
        lv_tabix  TYPE sytabix,
        lv_matnr  TYPE matnr,
        lv_posnr  TYPE aposn,
        lv_wempf  TYPE wempf.

  LOOP AT gt_xout ASSIGNING <fs_out>.
    "Added space
    IF <fs_out>-wempf = 'F'.
      lv_tabix = sy-tabix + 1.
      READ TABLE gt_xout INTO ls_xout INDEX lv_tabix.
      IF sy-subrc = 0 AND
         ls_xout-matnr3 = <fs_out>-matnr3 AND
         ls_xout-wempf = 'W'.
        <fs_out>-wempf = 'X'.
      ENDIF.
    ENDIF.

    "Get Factorisasi
    IF <fs_out>-batch1 IS NOT INITIAL.
      PERFORM f_material_factor(ztsppp_e001) USING    <fs_out>-matnr3
                                                      <fs_out>-batch1
                                                      <fs_out>-werks
                                             CHANGING <fs_out>-fact1.
      CONDENSE <fs_out>-fact1.
      IF <fs_out>-fact1 = '1'.
        CLEAR <fs_out>-fact1.
      ELSE.
        TRANSLATE <fs_out>-fact1 USING '.,'.
        CONCATENATE '(F=' <fs_out>-fact1 ')' INTO <fs_out>-fact1.
      ENDIF.
    ENDIF.

    IF <fs_out>-batch2 IS NOT INITIAL.
      PERFORM f_material_factor(ztsppp_e001) USING    <fs_out>-matnr3
                                                      <fs_out>-batch2
                                                      <fs_out>-werks
                                             CHANGING <fs_out>-fact2.
      CONDENSE <fs_out>-fact2.
      IF <fs_out>-fact2 = '1'.
        CLEAR <fs_out>-fact2.
      ELSE.
        TRANSLATE <fs_out>-fact2 USING '.,'.
        CONCATENATE '(F=' <fs_out>-fact2 ')' INTO <fs_out>-fact2.
      ENDIF.
    ENDIF.

    IF <fs_out>-batch3 IS NOT INITIAL.
      PERFORM f_material_factor(ztsppp_e001) USING    <fs_out>-matnr3
                                                      <fs_out>-batch3
                                                      <fs_out>-werks
                                             CHANGING <fs_out>-fact3.
      CONDENSE <fs_out>-fact3.
      IF <fs_out>-fact3 = '1'.
        CLEAR <fs_out>-fact3.
      ELSE.
        TRANSLATE <fs_out>-fact3 USING '.,'.
        CONCATENATE '(F=' <fs_out>-fact3 ')' INTO <fs_out>-fact3.
      ENDIF.
    ENDIF.

    IF <fs_out>-batch4 IS NOT INITIAL.
      PERFORM f_material_factor(ztsppp_e001) USING    <fs_out>-matnr3
                                                      <fs_out>-batch4
                                                      <fs_out>-werks
                                             CHANGING <fs_out>-fact4.
      CONDENSE <fs_out>-fact4.
      IF <fs_out>-fact4 = '1'.
        CLEAR <fs_out>-fact4.
      ELSE.
        TRANSLATE <fs_out>-fact4 USING '.,'.
        CONCATENATE '(F=' <fs_out>-fact4 ')' INTO <fs_out>-fact4.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FULLPACK_FAKTORISASI

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_OUT
*&---------------------------------------------------------------------*
FORM f_modify_itab_out .
  DATA: lv_matnr TYPE matnr,
        lv_nomng TYPE nomng,
        lv_vornr TYPE vornr,
        lv_idx   TYPE sytabix.

  SORT gt_out BY matnr2 nomng4 vornr posnr.
  LOOP AT gt_out ASSIGNING <fs_out> WHERE granul = space.
    IF <fs_out>-matnr2 = lv_matnr AND
       <fs_out>-nomng4 = lv_nomng AND
       <fs_out>-vornr = lv_vornr.
      ADD 1 TO lv_idx.
    ELSE.
      lv_idx = 1.
      lv_matnr = <fs_out>-matnr2.
      lv_nomng = <fs_out>-nomng4.
      lv_vornr = <fs_out>-vornr.
    ENDIF.
    <fs_out>-idx01 = lv_idx.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_ITAB_OUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_FIELD
*&---------------------------------------------------------------------*
FORM f_modify_field  USING    fu_field
                     CHANGING fc_field.
  IF fu_field IS NOT INITIAL.
    fc_field = fu_field.
  ENDIF.
ENDFORM.                    " F_MODIFY_FIELD
