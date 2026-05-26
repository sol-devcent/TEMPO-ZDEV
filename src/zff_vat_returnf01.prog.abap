*&---------------------------------------------------------------------*
*&  Include           ZFF_VAT_RETURNF01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed.
ENDCLASS.                    "lcl_main DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_main IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA: ls_good   TYPE lvc_s_modi,
          lv_mengec TYPE char20,
          lv_menge  TYPE menge_d,
          lv_hasat  TYPE wrbtr,
          lv_amntv  TYPE wrbtr,
          lv_amnt2v TYPE wrbtr,
          lv_jumlah TYPE wrbtr,
          lv_disc   TYPE wrbtr,
          lv_dpp    TYPE wrbtr,
          lv_ppn    TYPE wrbtr.

    FIELD-SYMBOLS: <fs_detail> TYPE zfist001.

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
      CLEAR: lv_amntv,lv_amnt2v,lv_menge,lv_mengec.
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'AMNTV'
        IMPORTING
          e_value     = lv_amntv.
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'AMNT2V'
        IMPORTING
          e_value     = lv_amnt2v.

      READ TABLE gt_detail ASSIGNING <fs_detail>
                           INDEX ls_good-row_id.

      lv_mengec = <fs_detail>-menge.
      REPLACE ALL OCCURRENCES OF '.' IN lv_mengec WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN lv_mengec WITH '.'.
      CONDENSE lv_mengec.
      lv_menge = lv_mengec.

      <fs_detail>-hasatv = lv_amntv / lv_menge.   "<fs_detail>-menge.
      <fs_detail>-amntv = lv_amntv.
      <fs_detail>-amnt2v = lv_amnt2v.

      WRITE <fs_detail>-hasatv TO <fs_detail>-hasat CURRENCY 'IDR'.
      WRITE <fs_detail>-amntv TO <fs_detail>-amnt CURRENCY 'IDR'.
      WRITE <fs_detail>-amnt2v TO <fs_detail>-amnt2 CURRENCY 'IDR'.
    ENDLOOP.

    LOOP AT gt_detail ASSIGNING <fs_detail>.
      ADD <fs_detail>-amntv TO lv_jumlah.
      ADD <fs_detail>-amnt2v TO lv_disc.
    ENDLOOP.

    lv_dpp = lv_jumlah - lv_disc.

    PERFORM f_tax_calc USING va_date lv_dpp 'E'
                   CHANGING lv_ppn.

*    lv_ppn = ( 10 / 100 ) * lv_dpp.

    WRITE lv_jumlah TO gv_jumlah CURRENCY 'IDR'.
    WRITE lv_disc TO gv_discount CURRENCY 'IDR'.
    WRITE lv_dpp TO gv_dpp CURRENCY 'IDR'.
    WRITE lv_ppn TO gv_ppn CURRENCY 'IDR'.

    gs_header-amnt1 = gv_jumlah.
    gs_header-amnt2 = gv_discount.
    gs_header-amnt4 = gv_dpp.
    gs_header-amnt5 = gv_ppn.

    CALL METHOD g_grid->refresh_table_display( ).

  ENDMETHOD.                    "on_data_changed
ENDCLASS.                    "lcl_main IMPLEMENTATION

DATA: g_event_handler TYPE REF TO lcl_event_handler.

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat2.
    PERFORM f_build_layout2.
    PERFORM f_build_sortfield2.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

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
        it_outtab            = gt_detail[]
        it_sort              = gt_sort[].

* When edit display
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Data Change Handler
    CREATE OBJECT g_event_handler.
    SET HANDLER g_event_handler->handle_data_changed FOR g_grid.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.                 " PBO100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat2 .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg2 USING 'GT_DETAIL':
    'EBELP' '' '' '' '' 'Item' '' '' '' '' '' '' '' '' '' '' '' '' '' 'R',
    'MAKTX' '' '' '' '' 'Jenis Barang' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '' 'Kuantum' '' '' '' '' '' '' '' '' '' '' '' '' '' 'R',
    'HASATV' '' '' '' '' 'Harga Satuan' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' 'R',
    'AMNTV' '' '' '' '' 'Harga BKP' '' '' '' 'IDR' '' '' '' '' '' '' '' 'X' '' 'R',
    'AMNT2V' '' '' '' '' 'Discount' '' '' '' 'IDR' '' '' '' '' '' '' '' 'X' '' 'R'.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg2 USING   value(fu_types)
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
                          value(fu_just).

  DATA: ld_fieldcat  TYPE  lvc_t_fcat WITH HEADER LINE.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext           = fu_fltxt.
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
  ld_fieldcat-just              = fu_just.
  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG2

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout2 .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
  gs_layout-no_rowmark  = 'X'.
*  gs_layout-stylefname  = 'CELLTAB'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield2 .
  CLEAR gt_sort[].

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'EBELP'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
MODULE pai100 INPUT.
  CLEAR gv_print.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      CLEAR gv_refresh.
      LEAVE TO SCREEN 0.
    WHEN '&EXEC'.
      CLEAR gv_refresh.
      gv_print = 'X'.
      LEAVE TO SCREEN 0.
    WHEN '&TOTAL'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      FREE g_event_handler.
      CLEAR: gs_layout,gt_exclude[],gs_variant,gt_fieldcat[],gt_sort[].
      CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.
      gv_refresh = 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
FORM select_all_checkboxes .
*  gt_out-chbox = abap_true.
*  MODIFY gt_out TRANSPORTING chbox WHERE disabl = abap_false.
*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " SELECT_ALL_CHECKBOXES

*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
FORM deselect_all_checkboxes .
*  gt_out-chbox = abap_false.
*  MODIFY gt_out TRANSPORTING chbox WHERE disabl = abap_false.
*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " DESELECT_ALL_CHECKBOXES

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
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.                    " F_TOOLBAR_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.

  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC
