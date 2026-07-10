*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
*----------------------------------------------------------------------*
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
          lv_hkont  TYPE hkont,
          lv_itmamt TYPE zitmamt.

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
      CLEAR: lv_hkont,lv_itmamt.
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'HKONT'
        IMPORTING
          e_value     = lv_hkont.
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'ITMAMT'
        IMPORTING
          e_value     = lv_itmamt.


      READ TABLE gt_detail ASSIGNING <fs_detail>
                           INDEX ls_good-row_id.

      SELECT SINGLE txt50 INTO <fs_detail>-txt50
        FROM skat WHERE spras = sy-langu
                    AND ktopl = 'TSPC'
                    AND saknr = lv_hkont.
      IF sy-subrc = 0.
        WRITE icon_green_light AS ICON TO <fs_detail>-icon.
      ELSE.
        SELECT SINGLE name1 INTO <fs_detail>-txt50
          FROM lfa1 WHERE lifnr = lv_hkont.
        IF sy-subrc = 0.
          WRITE icon_green_light AS ICON TO <fs_detail>-icon.
        ELSE.
          <fs_detail>-txt50 = 'Account Salah'.
          WRITE icon_red_light AS ICON TO <fs_detail>-icon.
        ENDIF.
      ENDIF.
    ENDLOOP.

*    CALL METHOD g_grid->refresh_table_display( ).

  ENDMETHOD.                    "on_data_changed
ENDCLASS.                    "lcl_main IMPLEMENTATION

DATA: g_event_handler TYPE REF TO lcl_event_handler.

*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
*  DATA: gv_butxt    TYPE butxt,
*        gv_gtext    TYPE gtext,
  SELECT SINGLE butxt INTO gv_butxt
    FROM t001 WHERE bukrs = p_bukrs.
  SELECT SINGLE gtext INTO gv_gtext
    FROM tgsbt WHERE spras = sy-langu
                 AND gsber = p_gsber.

  CONCATENATE p_bukrs gv_butxt INTO gv_butxt SEPARATED BY ' - '.
  CONCATENATE p_gsber gv_gtext INTO gv_gtext SEPARATED BY ' - '.
ENDFORM.                    " f_init_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_header
    FROM zfibphd001 WHERE noref = p_noref
                      AND bukrs = p_bukrs
                      AND gsber = p_gsber.
  IF sy-subrc = 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail
      FROM zfibpdt001 WHERE noref = gs_header-noref.

  ELSE.
    gs_header-noref = p_noref.
    gs_header-bukrs = p_bukrs.
    gs_header-gsber = p_gsber.
  ENDIF.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: n   TYPE int3.

  IF gs_header-waers = 'IDR'.
    MULTIPLY gs_header-totamt BY 100.
  ENDIF.

  IF gt_detail[] IS NOT INITIAL.
    LOOP AT gt_detail ASSIGNING <fs_detail>.
      WRITE icon_green_light AS ICON TO <fs_detail>-icon.
      IF <fs_detail>-waers = 'IDR'.
        MULTIPLY <fs_detail>-itmamt BY 100.
      ENDIF.
    ENDLOOP.
  ENDIF.

  n = 100 - LINES( gt_detail ).
  DO n TIMES.
    APPEND INITIAL LINE TO gt_detail.
  ENDDO.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  DATA: ld_count TYPE numc3,
        ld_cnt1  TYPE int1,
        ld_cnt11 TYPE char3,
        ld_cnt2  TYPE int1,
        ld_cnt21 TYPE char3,
        lt_detail TYPE TABLE OF zfibpdt001.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  d_output_opt-tdnoprint = p_disp.

  IF d_frm_subrc IS INITIAL.
    lt_detail[] = gt_detail[].
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        header             = gs_header
      TABLES
        detail             = lt_detail.

    IF sy-subrc = 0.
*      PERFORM f_update_table.
    ELSE.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_print_form

*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.

ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
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
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_DETAIL':
    'ICON' '' '' '' '5' 'Sts' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'HKONT' 'ZFIBPDT001' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '',
    'TXT50' 'ZFIBPDT001' 'TXT50' '' '30' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ITMDSC' 'ZFIBPDT001' 'ITMDSC' '' '40' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '',
    'INVNO' 'ZFIBPDT001' 'INVNO' '' '30' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '',
    'ITMAMT' 'ZFIBPDT001' 'ITMAMT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' 'R'.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING   value(fu_types)
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
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
*  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
*  gs_layout-no_rowmark  = 'X'.
  gs_layout-sel_mode    = 'A'.
  gs_layout-box_fname   = 'SEL'.
  gs_layout-no_toolbar  = 'X'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

*  CASE 'X'.
*    WHEN p_radio1.
*      CLEAR gt_sort.
*      gt_sort-spos      = '1'.
*      gt_sort-fieldname = 'MATERIAL'.
*      APPEND gt_sort.
*
*    WHEN p_radio2.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
MODULE pai100 INPUT.
  DATA: lt_fg   TYPE TABLE OF ztspppst002 WITH HEADER LINE,
        lt_row  TYPE lvc_t_row,
        lt_roid TYPE lvc_t_roid,
        ls_roid TYPE lvc_s_roid,
        n       TYPE int1.

  CLEAR: lt_fg[],lt_row[],lt_roid[],ls_roid,n.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      LEAVE TO SCREEN 0.

    WHEN '&EXEC'.
      READ TABLE gt_detail WITH KEY txt50 = 'Account Salah'
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        MESSAGE 'Data masih ada salah' TYPE 'S'.
      ELSE.
        DELETE gt_detail WHERE hkont IS INITIAL.
        IF gt_detail[] IS NOT INITIAL.
          PERFORM f_hitung_total_amount.
          PERFORM f_update_table.
          PERFORM f_print_form.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.

    WHEN '&SUMM'.
      PERFORM f_hitung_total_amount.

    WHEN '&DELE'.
      CALL METHOD g_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row
          et_row_no     = lt_roid.

      LOOP AT lt_roid INTO ls_roid.
        READ TABLE gt_detail ASSIGNING <fs_detail> INDEX ls_roid-row_id.
        <fs_detail>-check = 'X'.
        ADD 1 TO n.
      ENDLOOP.

      CLEAR: gt_delete,gt_delete[].
      gt_delete[] = gt_detail[].
      DELETE gt_delete WHERE check NE 'X'.
      DELETE gt_detail WHERE check = 'X'.

      DO n TIMES.
        APPEND INITIAL LINE TO gt_detail ASSIGNING <fs_detail>.
      ENDDO.

      PERFORM f_hitung_total_amount.

      CALL METHOD g_grid->refresh_table_display( ).
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

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
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table .
  DATA: lt_zfibphd001 TYPE TABLE OF zfibphd001,
        lt_zfibpdt001 TYPE TABLE OF zfibpdt001 WITH HEADER LINE,
        lv_no         TYPE zitmno.

  IF gs_header-waers = 'IDR'.
    DIVIDE gs_header-totamt BY 100.
  ENDIF.
  APPEND gs_header TO lt_zfibphd001.

  LOOP AT gt_detail ASSIGNING <fs_detail>.
    <fs_detail>-noref = p_noref.
    ADD 1 TO lv_no.
    <fs_detail>-itmno = lv_no.

    IF <fs_detail>-waers = 'IDR'.
      DIVIDE <fs_detail>-itmamt BY 100.
    ENDIF.

*  CONCATENATE <fs_detail>-hkont <fs_detail>-txt50
*    INTO <fs_detail>-txt50 SEPARATED BY ' - '.

    APPEND <fs_detail> TO lt_zfibpdt001.
  ENDLOOP.

  MODIFY zfibphd001 FROM TABLE lt_zfibphd001.
  MODIFY zfibpdt001 FROM TABLE lt_zfibpdt001.
  DELETE zfibpdt001 FROM TABLE gt_delete.
ENDFORM.                    " F_UPDATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TOTAL_AMOUNT
*&---------------------------------------------------------------------*
FORM f_hitung_total_amount .
  CLEAR gs_header-totamt.
  LOOP AT gt_detail ASSIGNING <fs_detail>
    WHERE txt50 NE 'Account Salah'.
    ADD <fs_detail>-itmamt TO gs_header-totamt.
    <fs_detail>-waers = gs_header-waers.
  ENDLOOP.
ENDFORM.                    " F_HITUNG_TOTAL_AMOUNT
