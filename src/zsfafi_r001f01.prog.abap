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
*  SET TITLEBAR 'TITLE_0100'.
  CASE 'X'.
    WHEN p_rad1.
      SET TITLEBAR 'TITLE_0100'.
    WHEN p_rad2.
      SET TITLEBAR 'TITLE_0110'.
    WHEN OTHERS.
  ENDCASE.

  IF g_custom_container IS INITIAL.
*  IF g_grid IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    CASE 'X'.
      WHEN p_rad1.
        PERFORM f_build_fieldcat.
      WHEN p_rad2.
        PERFORM f_build_fieldcat2.
    ENDCASE.

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
      WHEN p_rad2.
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
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_OUT':
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '' '',
    'BUKRS' 'ZFBIH_SFA' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFBIH_SFA' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BBELN' 'ZFBIH_SFA' 'BBELN' '' '' 'Nomor BI' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SFA' '' '' '' '3' 'SFA' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BIDAT' 'ZFBIH_SFA' 'BIDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'ZFBID_SFA' 'ZUONR' '' '' 'Nomor DO/CN' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FKDAT' 'ZFBID_SFA' 'FKDAT' '' '' 'Billing Date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFBID_SFA' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WRBTR' 'ZFBID_SFA' 'WRBTR' '' '' 'Amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'BFLAG' '' '' '' '6' 'Z' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PSTAT' '' '' '' '6' 'Z' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PTYPE' '' '' '' '6' 'ZF' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PARVW' '' '' '' '10' 'Partner' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNA1' 'ZFBIH_SFA' 'USNA1' '' '' 'Create by' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET' 'ZFBIH_SFA' 'ERZET' '' '' 'Create time' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT1' 'ZFBIH_SFA' 'ERDT1' '' '' 'Create date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNA2' 'ZFBIH_SFA' 'USNA2' '' '' 'Changed by' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET2' 'ZFBIH_SFA' 'ERZET2' '' '' 'Changed time' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT2' 'ZFBIH_SFA' 'ERDT2' '' '' 'Changed date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLCOD' 'ZFBID_SFA' 'SLCOD' '' '' 'Slsman Code' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFBDT' 'ZFBID_SFA' 'ZFBDT' '' '' 'Bline Date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'INP_GIRO' 'ZFBID_SFA' 'INP_GIRO' '' '' 'Check amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_CASH' 'ZFBID_SFA' 'INP_CASH' '' '' 'Cash amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_CASH_CN' 'ZFBID_SFA' 'INP_CASH_CN' '' '' 'CN Cash amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_CASH_EXP' 'ZFBID_SFA' 'INP_CASH_EXP' '' '' 'Cash Exp. amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_TRNSFR' 'ZFBID_SFA' 'INP_TRNSFR' '' '' 'Transfer amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_TRNSFR_CN' 'ZFBID_SFA' 'INP_TRNSFR_CN' '' '' 'CN Transfer amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_TRNSFR_EXP' 'ZFBID_SFA' 'INP_TRNSFR_EXP' '' '' 'Transfer Exp. amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'NOTTF' 'ZFBID_SFA' 'NOTTF' '' '' 'TTF No.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TGLTTF' 'ZFBID_SFA' 'TGLTTF' '' '' 'TTF Date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AMTTTF' 'ZFBID_SFA' 'AMTTTF' '' '' 'TTF amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' '',
    'INP_FKB_AMT' 'ZFBID_SFA' 'INP_FKB_AMT' '' '' 'Amount FKB' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' 'X' '',
    'INP_FKB_KET' 'ZFBID_SFA' 'INP_FKB_KET' '' '' 'Keterangan FKB' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'VCHR_CR' 'ZFBIH_SFA' 'VCHR_CR' '' '' 'Cash Reference' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'VCHR_BR' 'ZFBIH_SFA' 'VCHR_BR' '' '' 'Transfer Reference ' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'USNAM_POST' 'ZFBIH_SFA' 'USNAM_POST' '' '' 'Post User' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERDAT_POST' 'ZFBIH_SFA' 'ERDAT_POST' '' '' 'Post Date' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERZET_POST' 'ZFBIH_SFA' 'ERZET_POST' '' '' 'Post Time' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'POSTDOC1' 'ZFBIH_SFA' 'POSTDOC1' '' '' 'Post Cash Doc.' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'POSTDOC2' 'ZFBIH_SFA' 'POSTDOC2' '' '' 'Post Transfer Doc.' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'DAILY_CALL_NUM' 'ZFBIH_SFA' 'DAILY_CALL_NUM' '' '7' 'DCP No.' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'SDATE' 'ZFBIH_SFA' 'SDATE' '' '10' 'DCP Date' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'USNAM_REL' 'ZFBIH_SFA' 'USNAM_REL' '' '' 'User Release' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERDAT_REL' 'ZFBIH_SFA' 'ERDAT_REL' '' '' 'Date Release' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERZET_REL' 'ZFBIH_SFA' 'ERZET_REL' '' '' 'Time Release' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'USNAM_UNREL' 'ZFBIH_SFA' 'USNAM_UNREL' '' 'User Unrelease' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERDAT_UNREL' 'ZFBIH_SFA' 'ERDAT_UNREL' '' 'Date Unrelease' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'ERZET_UNREL' 'ZFBIH_SFA' 'ERZET_UNREL' '' 'Time Unrelease' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''.
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
                          VALUE(fu_no_out)
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
  ld_fieldcat-no_out            = fu_no_out.
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
  gt_sort-fieldname = 'BUKRS'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'VKBUR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'BBELN'.
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
  CASE 'X'.
    WHEN p_rad1.
      PERFORM f_get_data1.
    WHEN p_rad2.
      PERFORM f_get_data2.
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
      PERFORM f_process_data1.
    WHEN p_rad2.
      PERFORM f_process_data2.
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
    CASE 'X'.
      WHEN p_rad1.
        IF screen-group1 = 'CEK'.
          screen-invisible = '1'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN p_rad2.
        IF screen-group1 = 'CEK'.
          screen-invisible = '0'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

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
  IF p_bukrs IS INITIAL.
    MESSAGE 'Please input Company Code' TYPE 'I'.
    RETURN.
  ELSEIF p_vkbur IS INITIAL.
    MESSAGE 'Please input Sales Office' TYPE 'I'.
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
*&      Form  F_GET_DATA1
*&---------------------------------------------------------------------*
FORM f_get_data1 .
  DATA: lt_zfbid LIKE TABLE OF gt_zfbid.
  DATA: lt_zfbidsfa LIKE TABLE OF gt_zfbidsfa.
  DATA: lt_zfbidpsfa LIKE TABLE OF gt_zfbidpsfa.

  SELECT * INTO TABLE gt_zfbih
    FROM zfbih WHERE bukrs = p_bukrs
                 AND vkbur = p_vkbur
                 AND bbeln IN s_bbeln
                 AND bidat IN s_bidat.

  IF sy-subrc = 0.
    SELECT * INTO TABLE gt_zfbid
      FROM zfbid FOR ALL ENTRIES IN gt_zfbih
      WHERE bukrs = gt_zfbih-bukrs
        AND vkbur = gt_zfbih-vkbur
        AND bbeln = gt_zfbih-bbeln
        AND zuonr IN s_zuonr
        AND kunnr IN s_kunnr.

    IF sy-subrc = 0.
      lt_zfbid[] = gt_zfbid[].
      SORT lt_zfbid BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfbid COMPARING kunnr.

      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FROM kna1 FOR ALL ENTRIES IN lt_zfbid
        WHERE kunnr = lt_zfbid-kunnr.
    ENDIF.
  ENDIF.

  SELECT * INTO TABLE gt_zfbihsfa
    FROM zfbih_sfa WHERE bukrs = p_bukrs
                     AND vkbur = p_vkbur
                     AND bbeln IN s_bbeln
                     AND bidat IN s_bidat.

  IF sy-subrc = 0.
    SELECT * INTO TABLE gt_zfbidsfa
      FROM zfbid_sfa FOR ALL ENTRIES IN gt_zfbihsfa
      WHERE bukrs = gt_zfbihsfa-bukrs
        AND vkbur = gt_zfbihsfa-vkbur
        AND bbeln = gt_zfbihsfa-bbeln
        AND zuonr IN s_zuonr
        AND kunnr IN s_kunnr.

    IF sy-subrc = 0.
      lt_zfbidsfa[] = gt_zfbidsfa[].
      SORT lt_zfbidsfa BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfbidsfa COMPARING kunnr.

      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1sfa
        FROM kna1 FOR ALL ENTRIES IN lt_zfbidsfa
        WHERE kunnr = lt_zfbidsfa-kunnr.
    ENDIF.

    SELECT * INTO TABLE gt_zfbidpsfa
      FROM zfbidp_sfa FOR ALL ENTRIES IN gt_zfbihsfa
      WHERE bukrs = gt_zfbihsfa-bukrs
        AND vkbur = gt_zfbihsfa-vkbur
        AND bbeln = gt_zfbihsfa-bbeln
        AND zuonr IN s_zuonr
        AND kunnr IN s_kunnr.

    IF sy-subrc = 0.
      lt_zfbidpsfa[] = gt_zfbidpsfa[].
      SORT lt_zfbidpsfa BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfbidpsfa COMPARING kunnr.

      SELECT kunnr name1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1sfa
        FROM kna1 FOR ALL ENTRIES IN lt_zfbidpsfa
        WHERE kunnr = lt_zfbidpsfa-kunnr.
    ENDIF.
  ENDIF.

  IF gt_kna1sfa[] IS NOT INITIAL.
    SORT gt_kna1sfa BY kunnr.
    DELETE ADJACENT DUPLICATES FROM gt_kna1sfa COMPARING kunnr.
  ENDIF.

  IF gt_zfbih[] IS INITIAL AND gt_zfbihsfa[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA2
*&---------------------------------------------------------------------*
FORM f_get_data2 .
  DATA: lt_zfbicheck LIKE TABLE OF gt_zfbicheck.
  DATA: lt_zfbicsfa LIKE TABLE OF gt_zfbicsfa.

  SELECT * INTO TABLE gt_zfbicheck
    FROM zfbicheck
    WHERE bukrs = p_bukrs
      AND vkbur = p_vkbur
      AND gjahr IN s_gjahr
      AND kunnr IN s_kunnr
      AND zfbdt IN s_zfbdt
      AND cekno IN s_cekno
      AND bname IN s_bname
      AND bbeln IN s_bbeln
      AND zuonr IN s_zuonr
      AND duedt IN s_duedt
      AND pcair IN s_pcair.

  IF sy-subrc = 0.
    lt_zfbicheck[] = gt_zfbicheck[].
    SORT lt_zfbicheck BY bukrs vkbur bbeln.
    DELETE ADJACENT DUPLICATES FROM lt_zfbicheck COMPARING bukrs vkbur bbeln.
    IF lt_zfbicheck[] IS NOT INITIAL.
      SELECT *
        FROM zfbih
        INTO CORRESPONDING FIELDS OF TABLE gt_zfbih
        FOR ALL ENTRIES IN lt_zfbicheck
        WHERE bukrs = lt_zfbicheck-bukrs
          AND vkbur = lt_zfbicheck-vkbur
          AND bbeln = lt_zfbicheck-bbeln
          AND bidat IN s_bidat.
    ENDIF.

    lt_zfbicheck[] = gt_zfbicheck[].
    SORT lt_zfbicheck BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_zfbicheck COMPARING kunnr.

    SELECT kunnr name1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 FOR ALL ENTRIES IN lt_zfbicheck
      WHERE kunnr = lt_zfbicheck-kunnr.
  ENDIF.

  SELECT * INTO TABLE gt_zfbicsfa
    FROM zfbic_sfa
    WHERE bukrs = p_bukrs
      AND vkbur = p_vkbur
      AND bbeln IN s_bbeln
      AND zuonr IN s_zuonr
      AND kunnr IN s_kunnr
      AND bank_check IN s_cekno
      AND bank_name  IN s_bname
      AND bank_dudat IN s_bname
      AND pcair IN s_pcair.

  IF sy-subrc = 0.
    SELECT * INTO TABLE gt_zfbidsfa
      FROM zfbid_sfa FOR ALL ENTRIES IN gt_zfbicsfa
      WHERE bukrs = gt_zfbicsfa-bukrs
        AND vkbur = gt_zfbicsfa-vkbur
        AND bbeln = gt_zfbicsfa-bbeln
        AND gjahr IN s_gjahr
        AND zuonr = gt_zfbicsfa-zuonr
        AND kunnr = gt_zfbicsfa-kunnr
        AND zfbdt IN s_zfbdt.

    IF sy-subrc = 0.
      lt_zfbicsfa[] = gt_zfbicsfa[].
      SORT lt_zfbicsfa BY bukrs vkbur bbeln.
      DELETE ADJACENT DUPLICATES FROM lt_zfbicsfa COMPARING bukrs vkbur bbeln.
      IF lt_zfbicsfa[] IS NOT INITIAL.
        SELECT *
          FROM zfbih_sfa
          INTO CORRESPONDING FIELDS OF TABLE gt_zfbihsfa
          FOR ALL ENTRIES IN lt_zfbicsfa
          WHERE bukrs = lt_zfbicsfa-bukrs
            AND vkbur = lt_zfbicsfa-vkbur
            AND bbeln = lt_zfbicsfa-bbeln
            AND bidat IN s_bidat.
      ENDIF.

      lt_zfbicsfa[] = gt_zfbicsfa[].
      SORT lt_zfbicsfa BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfbicsfa COMPARING kunnr.

      SELECT kunnr name1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1sfa
        FROM kna1 FOR ALL ENTRIES IN lt_zfbicsfa
        WHERE kunnr = lt_zfbicsfa-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA1
*&---------------------------------------------------------------------*
FORM f_process_data1 .
  SORT gt_zfbid BY bukrs vkbur bbeln kunnr.
  SORT gt_zfbih BY bukrs vkbur bbeln.
  SORT gt_zfbidsfa BY bukrs vkbur bbeln kunnr.
  SORT gt_zfbihsfa BY bukrs vkbur bbeln.

  LOOP AT gt_zfbid.
    CLEAR: gt_zfbih,gt_kna1.
    READ TABLE gt_zfbih WITH KEY bukrs = gt_zfbid-bukrs
                                 vkbur = gt_zfbid-vkbur
                                 bbeln = gt_zfbid-bbeln
                                 BINARY SEARCH.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_zfbid-kunnr.

    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.

    <fs_out>-bukrs = gt_zfbid-bukrs.
    <fs_out>-vkbur = gt_zfbid-vkbur.
    <fs_out>-bbeln = gt_zfbid-bbeln.
    <fs_out>-bidat = gt_zfbih-bidat.
    <fs_out>-zuonr = gt_zfbid-zuonr.
    <fs_out>-fkdat = gt_zfbid-fkdat.
    <fs_out>-kunnr = gt_zfbid-kunnr.
    <fs_out>-name1 = gt_kna1-name1.
    <fs_out>-wrbtr = gt_zfbid-wrbtr.
    <fs_out>-waers = gt_zfbih-waers.
    <fs_out>-bflag = gt_zfbid-bflag.
    <fs_out>-pstat = gt_zfbid-pstat.
    <fs_out>-ptype = gt_zfbid-ptype.
    <fs_out>-parvw = gt_zfbid-parvw.
    <fs_out>-usna1 = gt_zfbid-usna1.
*    <fs_out>-erzet type erzet,
    <fs_out>-erdt1 = gt_zfbid-erdt1.
    <fs_out>-usna2 = gt_zfbid-usna2.
*    <fs_out>-erzet2 type erzet,
    <fs_out>-erdt2 = gt_zfbid-erdt2.
    <fs_out>-slcod = gt_zfbid-slcod.
    <fs_out>-zfbdt = gt_zfbid-zfbdt.
    <fs_out>-inp_cash = gt_zfbid-pcash.
    <fs_out>-inp_trnsfr = gt_zfbid-ptrans.
    <fs_out>-inp_giro = gt_zfbid-pchek.
    <fs_out>-inp_cash_cn = gt_zfbid-pcnot.
    <fs_out>-inp_trnsfr_cn = gt_zfbid-ptnot.
*    <fs_out>-inp_cash_exp type zwert7,
*    <fs_out>-inp_trnsfr_exp = gt_zfbid-ptrans,
    <fs_out>-nottf = gt_zfbid-nottf.
    <fs_out>-tglttf = gt_zfbid-tglttf.
    <fs_out>-amtttf = gt_zfbid-amtttf.
*    <fs_out>-inp_fkb_amt type zwert7,
*    <fs_out>-inp_fkb_ket type char20,
    <fs_out>-vchr_cr = gt_zfbid-xblnr.
    <fs_out>-vchr_br = gt_zfbid-xblnrt.
    <fs_out>-usnam_post = gt_zfbid-usna1.
    <fs_out>-erdat_post = gt_zfbid-erdt1.
*    <fs_out>-erzet_post type uzeit,
*    <fs_out>-postdoc1 type zpostdoc1,
*    <fs_out>-postdoc2 type zpostdoc2,
  ENDLOOP.

  LOOP AT gt_zfbidsfa.
    CLEAR: gt_zfbihsfa,gt_kna1sfa.
    READ TABLE gt_zfbihsfa WITH KEY bukrs = gt_zfbidsfa-bukrs
                                    vkbur = gt_zfbidsfa-vkbur
                                    bbeln = gt_zfbidsfa-bbeln
                                    BINARY SEARCH.
    READ TABLE gt_kna1sfa WITH KEY kunnr = gt_zfbidsfa-kunnr.

    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
    MOVE-CORRESPONDING gt_zfbidsfa TO <fs_out>.

    <fs_out>-sfa = 'X'.
    <fs_out>-bidat = gt_zfbihsfa-bidat.
    <fs_out>-name1 = gt_kna1sfa-name1.
    <fs_out>-waers = gt_zfbihsfa-waers.
    <fs_out>-usna1 = gt_zfbihsfa-usna1.
    <fs_out>-erzet = gt_zfbihsfa-erzet.
    <fs_out>-erdt1 = gt_zfbihsfa-erdt1.
    <fs_out>-usna2 = gt_zfbihsfa-usna2.
    <fs_out>-erzet2 = gt_zfbihsfa-erzet2.
    <fs_out>-erdt2 = gt_zfbihsfa-erdt2.
    <fs_out>-vchr_cr = gt_zfbihsfa-vchr_cr.
    <fs_out>-vchr_br = gt_zfbihsfa-vchr_br.
    <fs_out>-usnam_post = gt_zfbihsfa-usnam_post.
    <fs_out>-erdat_post = gt_zfbihsfa-erdat_post.
    <fs_out>-erzet_post = gt_zfbihsfa-erzet_post.
    <fs_out>-postdoc1 = gt_zfbihsfa-postdoc1.
    <fs_out>-postdoc2 = gt_zfbihsfa-postdoc2.
    <fs_out>-daily_call_num = gt_zfbihsfa-daily_call_num.
    <fs_out>-sdate = gt_zfbihsfa-sdate.
    <fs_out>-usnam_rel = gt_zfbihsfa-usnam_rel.
    <fs_out>-erdat_rel = gt_zfbihsfa-erdat_rel.
    <fs_out>-erzet_rel = gt_zfbihsfa-erzet_rel.
    <fs_out>-usnam_unrel = gt_zfbihsfa-usnam_unrel.
    <fs_out>-erdat_unrel = gt_zfbihsfa-erdat_unrel.
    <fs_out>-erzet_unrel = gt_zfbihsfa-erzet_unrel.

    LOOP AT gt_zfbidpsfa WHERE bukrs = gt_zfbidsfa-bukrs
                           AND vkbur = gt_zfbidsfa-vkbur
                           AND bbeln = gt_zfbidsfa-bbeln
                           AND ebelp = gt_zfbidsfa-ebelp
                           AND vbeln = gt_zfbidsfa-vbeln.
      ADD : gt_zfbidpsfa-inp_cash        TO <fs_out>-inp_cash,
            gt_zfbidpsfa-inp_trnsfr      TO <fs_out>-inp_trnsfr,
            gt_zfbidpsfa-inp_giro        TO <fs_out>-inp_giro,
            gt_zfbidpsfa-inp_cash_cn     TO <fs_out>-inp_cash_cn,
            gt_zfbidpsfa-inp_trnsfr_cn   TO <fs_out>-inp_trnsfr_cn,
            gt_zfbidpsfa-inp_cash_exp    TO <fs_out>-inp_cash_exp,
            gt_zfbidpsfa-inp_trnsfr_exp  TO <fs_out>-inp_trnsfr_exp,
            gt_zfbidpsfa-inp_fkb_amt     TO <fs_out>-inp_fkb_amt,
            gt_zfbidpsfa-amtttf          TO <fs_out>-amtttf.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA2
*&---------------------------------------------------------------------*
FORM f_process_data2 .
  DATA : ls_zfbih    LIKE LINE OF gt_zfbih,
         ls_zfbihsfa LIKE LINE OF gt_zfbihsfa.

  SORT gt_zfbicheck BY bukrs vkbur bbeln gjahr.
  SORT gt_zfbicsfa BY bukrs vkbur bbeln zuonr kunnr.
  SORT gt_zfbidsfa BY bukrs vkbur bbeln zuonr kunnr.

  LOOP AT gt_zfbicheck.
    CLEAR ls_zfbih.
    READ TABLE gt_zfbih INTO ls_zfbih
                        WITH KEY bukrs = gt_zfbicheck-bukrs
                                 vkbur = gt_zfbicheck-vkbur
                                 bbeln = gt_zfbicheck-bbeln.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR gt_kna1.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_zfbicheck-kunnr.

    APPEND INITIAL LINE TO gt_out2 ASSIGNING <fs_out2>.

    <fs_out2>-bukrs = gt_zfbicheck-bukrs.
    <fs_out2>-vkbur = gt_zfbicheck-vkbur.
    <fs_out2>-bbeln = gt_zfbicheck-bbeln.
    <fs_out2>-bidat = ls_zfbih-bidat.
    <fs_out2>-gjahr = gt_zfbicheck-gjahr.
    <fs_out2>-kunnr = gt_zfbicheck-kunnr.
    <fs_out2>-name1 = gt_kna1-name1.
    <fs_out2>-zfbdt = gt_zfbicheck-zfbdt.
    <fs_out2>-bank_check = gt_zfbicheck-cekno.
    <fs_out2>-bank_name = gt_zfbicheck-bname.
    <fs_out2>-vbeln = gt_zfbicheck-belnr.
    <fs_out2>-zuonr = gt_zfbicheck-zuonr.
    <fs_out2>-slcod = gt_zfbicheck-slcod.
    <fs_out2>-bank_dudat = gt_zfbicheck-duedt.
    <fs_out2>-nocairb = gt_zfbicheck-blnck.
    <fs_out2>-nocairc = gt_zfbicheck-ncair.
    <fs_out2>-vchr_br = gt_zfbicheck-xblnr.
    <fs_out2>-hkontbank = gt_zfbicheck-hkont.
    <fs_out2>-pcair = gt_zfbicheck-pcair.
    <fs_out2>-usna1 = gt_zfbicheck-usna1.
    <fs_out2>-erdt1 = gt_zfbicheck-erdt1.
    <fs_out2>-usna2 = gt_zfbicheck-usna2.
    <fs_out2>-erdt2 = gt_zfbicheck-erdt2.
    <fs_out2>-amount = gt_zfbicheck-wrbtr.
    <fs_out2>-bank_amt = gt_zfbicheck-cchek.
    <fs_out2>-zeile = gt_zfbicheck-buzei.
    <fs_out2>-seqno = gt_zfbicheck-seqno.
*    <fs_out2>-postdoc1 TYPE zpostdoc1.

    CASE <fs_out2>-bukrs.
      WHEN '8020'.
        <fs_out2>-ba = '0200'.
      WHEN '8070'.
        <fs_out2>-ba = gt_zfbicheck-vkbur.
    ENDCASE.
  ENDLOOP.

  LOOP AT gt_zfbicsfa.
    CLEAR ls_zfbihsfa.
    READ TABLE gt_zfbihsfa INTO ls_zfbihsfa
                        WITH KEY bukrs = gt_zfbicsfa-bukrs
                                 vkbur = gt_zfbicsfa-vkbur
                                 bbeln = gt_zfbicsfa-bbeln.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR: gt_zfbidsfa,gt_kna1sfa.
    READ TABLE gt_zfbidsfa WITH KEY bukrs = gt_zfbicsfa-bukrs
                                    vkbur = gt_zfbicsfa-vkbur
                                    bbeln = gt_zfbicsfa-bbeln
                                    zuonr = gt_zfbicsfa-zuonr
                                    kunnr = gt_zfbicsfa-kunnr
                                    BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_kna1sfa WITH KEY kunnr = gt_zfbicsfa-kunnr.

    APPEND INITIAL LINE TO gt_out2 ASSIGNING <fs_out2>.

    <fs_out2>-bukrs = gt_zfbicsfa-bukrs.
    <fs_out2>-vkbur = gt_zfbicsfa-vkbur.
    <fs_out2>-bbeln = gt_zfbicsfa-bbeln.
    <fs_out2>-bidat = ls_zfbihsfa-bidat.
    <fs_out2>-sfa = 'X'.
    <fs_out2>-gjahr = gt_zfbidsfa-gjahr.
    <fs_out2>-kunnr = gt_zfbicsfa-kunnr.
    <fs_out2>-name1 = gt_kna1sfa-name1.
    <fs_out2>-zfbdt = gt_zfbidsfa-zfbdt.
    <fs_out2>-bank_check = gt_zfbicsfa-bank_check.
    <fs_out2>-bank_name = gt_zfbicsfa-bank_name.
    <fs_out2>-vbeln = gt_zfbicsfa-vbeln.
    <fs_out2>-zuonr = gt_zfbicsfa-zuonr.
    <fs_out2>-slcod = gt_zfbidsfa-slcod.
    <fs_out2>-bank_dudat = gt_zfbicsfa-bank_dudat.
    <fs_out2>-vchr_br = gt_zfbicsfa-vchr_br.
    <fs_out2>-hkontbank = gt_zfbicsfa-hkontbank.
    <fs_out2>-pcair = gt_zfbicsfa-pcair.
    <fs_out2>-usna1 = gt_zfbicsfa-usna1.
    <fs_out2>-erdt1 = gt_zfbicsfa-erdt1.
    <fs_out2>-usna2 = gt_zfbicsfa-usna2.
    <fs_out2>-erdt2 = gt_zfbicsfa-erdt2.
    <fs_out2>-amount = gt_zfbicsfa-amount.
    <fs_out2>-bank_amt = gt_zfbicsfa-bank_amt.
    <fs_out2>-zeile = gt_zfbicsfa-zeile.
*    <fs_out2>-seqno = gt_zfbicheck-seqno.
    <fs_out2>-postdoc1 = gt_zfbicsfa-postdoc1.

    CASE <fs_out2>-bukrs.
      WHEN '8020'.
        <fs_out2>-ba = '0200'.
      WHEN '8070'.
        <fs_out2>-ba = gt_zfbicheck-vkbur.
    ENDCASE.

    CASE <fs_out2>-pcair.
      WHEN 'B'.
        <fs_out2>-nocairb = gt_zfbicsfa-nocair.
      WHEN 'C'.
        <fs_out2>-nocairc = gt_zfbicsfa-nocair.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT2
*&---------------------------------------------------------------------*
FORM f_build_fieldcat2 .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_OUT2':
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '' '',
    'BUKRS' 'ZFBIC_SFA' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFBIC_SFA' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BBELN' 'ZFBIC_SFA' 'BBELN' '' '' 'Nomor BI' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BIDAT' 'ZFBIH_SFA' 'BIDAT' '' '' 'BI Date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SFA' '' '' '' '3' 'SFA' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFBID_SFA' 'GJAHR' '' '' 'Tahun' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BA' 'ZFBIC_SFA' 'BA' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFBIC_SFA' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFBDT' 'ZFBID_SFA' 'ZFBDT' '' '' 'Bline Date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BANK_CHECK' 'ZFBIC_SFA' 'BANK_CHECK' '' '' 'No.Cek/Giro' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BANK_NAME' 'ZFBIC_SFA' 'BANK_NAME' '' '' 'Nama Bank' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'ZFBIC_SFA' 'VBELN' '' '' 'Bill Doc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'ZFBIC_SFA' 'ZUONR' '' '' 'Nomor DO/CN' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLCOD' 'ZFBID_SFA' 'SLCOD' '' '' 'Slsman Code' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BANK_DUDAT' 'ZFBIC_SFA' 'BANK_DUDAT' '' '' 'Jatuh Tempo' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOCAIRB' 'ZFBIC_SFA' 'NOCAIR' '' '' 'No. Giro Batal' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOCAIRC' 'ZFBIC_SFA' 'NOCAIR' '' '' 'No. Giro Cair' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VCHR_BR' 'ZFBIC_SFA' 'VCHR_BR' '' '' 'Ref. Doc No.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'HKONTBANK' 'ZFBIC_SFA' 'HKONTBANK' '' '' 'GL Account' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PCAIR' 'ZFBIC_SFA' 'PCAIR' '' '' 'PCAIR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNA1' 'ZFBIC_SFA' 'USNA1' '' '' 'Create by' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT1' 'ZFBIC_SFA' 'ERDT1' '' '' 'Create date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'USNA2' 'ZFBIC_SFA' 'USNA2' '' '' 'Changed by' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDT2' 'ZFBIC_SFA' 'ERDT2' '' '' 'Changed date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZFBIC_SFA' 'AMOUNT' '' '' 'Nilai DO' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' '',
    'BANK_AMT' 'ZFBIC_SFA' 'BANK_AMT' '' '' 'Nilai Chek' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' '',
    'ZEILE' 'ZFBIC_SFA' 'ZEILE' '' '' 'Item' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SEQNO' 'ZFBICHECK' 'SEQNO' '' '' 'SeqNo' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'POSTDOC1' 'ZFBIC_SFA' 'POSTDOC1' '' '' 'Posting Doc.' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''.
ENDFORM.                    " F_BUILD_FIELDCAT2
