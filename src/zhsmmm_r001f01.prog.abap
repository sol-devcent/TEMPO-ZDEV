*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE gt_005
    WHERE tcode = 'ZMME013'
      AND ekgrp IN so_ekgrp.

  SELECT *
    FROM zhsmmmdt008
    INTO CORRESPONDING FIELDS OF TABLE gt_008
    WHERE tcode = 'ZMMR004'.
  "AND ekgrp IN so_ekgrp.


  PERFORM f_free_pdf_temp.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
*  PERFORM f_error_message USING '' ''.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'SELECT THE FILE'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

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
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
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
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_x004y TYPE STANDARD TABLE OF zgdmmt004y,
         lt_x004z TYPE STANDARD TABLE OF zgdmmt004z.

  SELECT *
    FROM zgdmmt004z
    INTO CORRESPONDING FIELDS OF TABLE gt_004z
    WHERE ekgrp IN so_ekgrp
      AND matnr IN so_matnr
      AND werks IN so_werks
      AND zalno IN so_zalno
      AND zaldt IN so_zaldt.

  SORT gt_004z BY zalno zaldt DESCENDING.
  DELETE ADJACENT DUPLICATES FROM gt_004z COMPARING zalno.

  IF gt_004z[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt004y
      INTO CORRESPONDING FIELDS OF TABLE gt_004y
      FOR ALL ENTRIES IN gt_004z
      WHERE zalno = gt_004z-zalno.

    SELECT *
      FROM zgdmmt004p
      INTO CORRESPONDING FIELDS OF TABLE gt_004p
      FOR ALL ENTRIES IN gt_004z
      WHERE zalno = gt_004z-zalno.
  ENDIF.

  lt_x004z[] = gt_004z[].
  SORT lt_x004z BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_x004z COMPARING matnr.
  IF lt_x004z[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_x004z
      WHERE matnr = lt_x004z-matnr
        AND spras = sy-langu.
  ENDIF.

  lt_x004y[] = gt_004y[].
  SORT lt_x004y BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x004y COMPARING lifnr.
  IF lt_x004y[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FOR ALL ENTRIES IN lt_x004y
      WHERE lifnr = lt_x004y-lifnr.
  ENDIF.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = 'MEPROCSTATE'
      text           = 'X'
    TABLES
      dd07v_tab      = dd07v_tab
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_makt  LIKE LINE OF gt_makt,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_004y  LIKE LINE OF gt_004y,
         ls_004z  LIKE LINE OF gt_004z,
         ls_004p  LIKE LINE OF gt_004p,
         ls_008   LIKE LINE OF gt_008,
         ls_out   LIKE LINE OF gt_out,
         ls_dd07v LIKE LINE OF dd07v_tab.

  FIELD-SYMBOLS <fs>    TYPE any.

  LOOP AT gt_004z INTO ls_004z.
    MOVE-CORRESPONDING ls_004z TO ls_out.
    ls_out-atach  = icon_attachment.
    IF ls_004z-url IS NOT INITIAL.
      ls_out-fpkh  = icon_pdf.
    ENDIF.
    IF ls_004z-lampiran IS NOT INITIAL.
      SORT gt_008 BY uname.
      READ TABLE gt_008 INTO ls_008 WITH KEY uname = sy-uname BINARY SEARCH.
      IF sy-subrc EQ 0.
**      AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
**             ID 'FRGCO' FIELD 'FD' " -->  variable FD   = Release code
**               ID 'FRGGR' FIELD '40'. " --> variable 40 =  Release group
**      IF sy-uname = 'TSPHOCFO' OR sy-uname = 'TDS_DEV01' OR sy-uname = 'MMSTA' OR sy-uname = 'BCADMIN' or sy-uname = 'TSPHODFD'.
        ls_out-lamp  = icon_pdf.
      ENDIF.
    ENDIF.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_004z-matnr.
    IF sy-subrc = 0.
      ls_out-maktx    = ls_makt-maktx.
    ENDIF.

    CLEAR ls_dd07v.
    READ TABLE dd07v_tab INTO ls_dd07v
                         WITH KEY domvalue_l = ls_004z-procstat.
    IF sy-subrc = 0.
      CONCATENATE ls_004z-procstat ls_dd07v-ddtext INTO ls_out-relst
      SEPARATED BY space.
    ENDIF.

    LOOP AT gt_004y INTO ls_004y WHERE zalno = ls_004z-zalno.
      IF ls_004y-bsmng EQ 0.
        CONTINUE.
      ENDIF.
      ls_out-banfn    = ls_004y-banfn.
      ls_out-lifnr    = ls_004y-lifnr.
      CLEAR ls_lfa1.
      READ TABLE gt_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = ls_004y-lifnr.
      IF sy-subrc = 0.
        ls_out-name1    = ls_lfa1-name1.
      ENDIF.
      LOOP AT gt_004p INTO ls_004p WHERE zalno = ls_004y-zalno
                                     AND lifnr = ls_004y-lifnr
                                     AND banfn = ls_004y-banfn
                                     AND bnfpo = ls_004y-bnfpo.

        ls_out-ebeln    = ls_004p-ebeln.
        APPEND ls_out TO gt_out.
        CLEAR : ls_out-banfn, ls_out-lifnr, ls_out-name1, ls_out-ebeln,
                ls_out-atach, ls_out-fpkh, ls_out-lamp.
      ENDLOOP.
    ENDLOOP.
    CLEAR ls_out.
  ENDLOOP.

  LOOP AT gt_out INTO ls_out.
    ASSIGN COMPONENT 'EKGRP' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-ekgrp.
    ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-zalno.
    ASSIGN COMPONENT 'VRSIO' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-vrsio.
    ASSIGN COMPONENT 'SUBMI' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-submi.
    ASSIGN COMPONENT 'MERNO' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-merno.
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-werks.
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-matnr.
    ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-maktx.
    ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-banfn.
    ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-ebeln.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-lifnr.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-name1.
    ASSIGN COMPONENT 'RELST' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-relst.
    ASSIGN COMPONENT 'FRGCO' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-frgco.
    ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-ernam.
    ASSIGN COMPONENT 'ATACH' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-atach.
    ASSIGN COMPONENT 'FPKH' OF STRUCTURE <fs_lout> TO <fs>.
    <fs> = ls_out-fpkh.
    IF ls_out-lamp IS NOT INITIAL.
      ASSIGN COMPONENT 'LAMP' OF STRUCTURE <fs_lout> TO <fs>.
      <fs> = ls_out-lamp.
    ENDIF.
    PERFORM f_read_changes USING '' ls_out-zalno.

    APPEND <fs_lout> TO <fs_out>.
    CLEAR <fs_lout>.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_contain02.
*
*    CREATE OBJECT g_splitter1
*      EXPORTING
*        parent  = g_contain02
*        rows    = 1
*        columns = 2.
*
*    CALL METHOD g_splitter1->get_container
*      EXPORTING
*        row       = 1
*        column    = 1
*      RECEIVING
*        container = g_contain03.
*
*    CALL METHOD g_splitter1->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain04.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CASE sy-dynnr.
    WHEN '0101'.
      IF gt_bapiret2[] IS NOT INITIAL.
        dynlog-icon_id      = icon_error_protocol.
        dynlog-icon_text    = 'Error Log'.
      ENDIF.

      APPEND '&POS' TO fcode.

      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.

    WHEN OTHERS.
      SET PF-STATUS 'STATUS'.
  ENDCASE.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  CASE sy-dynnr.
    WHEN '0102'.
      CALL METHOD g_html_container->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.

      CALL METHOD g_html_control->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.

      FREE : g_html_container, g_html_control.
  ENDCASE.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter,
         lv_lines  TYPE i.

  DATA : lt_row_no TYPE lvc_t_roid,
         ls_row_no TYPE lvc_s_roid.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&SPLIT'.
      CALL METHOD g_tabgrid->get_selected_rows
        IMPORTING
          et_row_no = lt_row_no.
      IF sy-subrc = 0.
        READ TABLE lt_row_no INTO ls_row_no INDEX 1.
        PERFORM f_list_split USING ls_row_no-row_id.
      ENDIF.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_out>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'EKGRP' 'X' '' '',
                             2 'ZALNO' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : ls_005           LIKE LINE OF gt_005,
         ls_008           LIKE LINE OF gt_008,
         lv_fieldname(30),
         lv_title(30).

  DATA : lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data.

*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
*    'X' 'X' '' '' '',
*    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
*    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'EKGRP' '' '' '' '' '' '' 'EKGRP' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'ZALNO' '' '' '' '' '' '' 'ZALNO' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'SUBMI' '' '' '' '' '' '' 'SUBMI' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'MERNO' '' '' '' '' '' '' 'MERNO' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'WERKS' '' '' '' '' '' '' 'WERKS' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'BANFN' '' '' '' '' '' '' 'BANFN' 'EBAN' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'EBELN' '' '' '' '' '' '' 'EBELN' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'LIFNR' '' '' '' '' '' '' 'LIFNR' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'NAME1' '' '' '' '' '' '' 'NAME1' 'LFA1' 'Vendor Name' '' '' '' '' '' ''
    '' '' '' '' '',
    'RELST' '' '' '' '' '' '' 'DDTEXT' 'DD07T' 'Release status' '' '' ''
    '' '' '' '' '' '' '' '',
    'FRGCO' '' '' '' '' '' '' 'FRGCO' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'ERNAM' '' '' '' '' '' '' 'ERNAM' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'VRSIO' '' '' '' '' '' '' 'ERNAM' 'ZGDMMT004Z' '' '' '' 'X' '' '' ''
    '' '' '' '' ''.

  SORT gt_008 BY uname.
  READ TABLE gt_008 INTO ls_008 WITH KEY uname = sy-uname BINARY SEARCH.
  IF sy-subrc EQ 0.
    PERFORM f_dyn_int_table USING :
      'ATACH' '' '' '' '' '' '' '' '' 'Attachment' '' '' '' '' '' 'C'
      '' '' '' '' '',
      'FPKH' '' '' '' '' '' '' '' '' 'FPKH' '' '' '' '' '' 'C'
      '' '' '' '' '',
      'LAMP' '' '' '' '' '' '' '' '' 'LAMP' '' '' '' '' '' 'C'
      '' '' '' '' ''.
  ELSE.
    PERFORM f_dyn_int_table USING :
      'ATACH' '' '' '' '' '' '' '' '' 'Attachment' '' '' '' '' '' 'C'
      '' '' '' '' '',
      'FPKH' '' '' '' '' '' '' '' '' 'FPKH' '' '' '' '' '' 'C'
      '' '' '' '' ''.
  ENDIF.


*  LOOP AT gt_005 INTO ls_005.
*    CONCATENATE 'FRGCO_' ls_005-frgco INTO lv_fieldname.
*    lv_title = ls_005-frgco.
*    PERFORM f_dyn_int_table USING :
*      lv_fieldname '' '' '' '' '' '' 'UDATE' 'CDHDR' lv_title
*      '' '' '' '' '' '' '' '' '' '' ''.
*  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_main_fieldcat
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc = 0.
    ASSIGN lt_dyn_table->* TO <fs_out>.
    CREATE DATA ls_line LIKE LINE OF <fs_out>.
    ASSIGN ls_line->* TO <fs_lout>.
  ENDIF.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
*          CLEAR : ls_sort, lv_tabix.
*          READ TABLE gt_sort INTO ls_sort
*                             WITH KEY banfn = ls_out-banfn
*                                      bnfpo = ls_out-bnfpo.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
            CLEAR ls_filter.
            READ TABLE gt_filter INTO ls_filter
                                 WITH KEY index = lv_tabix.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tabgrid IS NOT INITIAL.
      CALL METHOD g_tabgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  IF lt_out[] IS NOT INITIAL.

  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out     LIKE LINE OF gt_out.
  DATA : lv_zalno  TYPE zgdmmt004z-zalno,
         lv_ebeln  TYPE ekko-ebeln,
         lv_getoff.

  FIELD-SYMBOLS <fs>    TYPE any.

  CASE fu_column.
    WHEN 'ATACH'.
*      PERFORM f_delete_temporary_form.
*      PERFORM f_display_attachment USING fu_row fu_column.
      lv_getoff = 'X'.
      PERFORM f_display_attachment_new USING fu_row fu_column lv_getoff.
    WHEN 'FPKH'.
      PERFORM f_print_fpkh USING fu_row fu_column.
    WHEN 'LAMP'.
      PERFORM f_print_lamp USING fu_row fu_column.
    WHEN 'EBELN'.
      READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lout> TO <fs>.
        lv_ebeln = <fs>.
        SET PARAMETER ID 'BES' FIELD lv_ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'ZALNO'.
      READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
        lv_zalno = <fs>.
        PERFORM f_read_changes USING 'X' lv_zalno.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_TEMPORARY_FORM
*&---------------------------------------------------------------------*
FORM f_delete_temporary_form .
  DATA : ls_temp LIKE LINE OF gt_temp,
         rc      TYPE i.

  LOOP AT gt_temp INTO ls_temp.
    CALL METHOD cl_gui_frontend_services=>file_delete
      EXPORTING
        filename             = ls_temp-document
      CHANGING
        rc                   = rc
      EXCEPTIONS
        file_delete_failed   = 1
        cntl_error           = 2
        error_no_gui         = 3
        file_not_found       = 4
        access_denied        = 5
        unknown_error        = 6
        not_supported_by_gui = 7
        wrong_parameter      = 8.
  ENDLOOP.
ENDFORM.                    " F_DELETE_TEMPORARY_FORM

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_display_attachment  USING    fu_row fu_column.
  DATA : lv_filepath TYPE string VALUE '/eprocurement',
         lv_filename TYPE string,
         itabline    TYPE TABLE OF solix,
         ls_itabline LIKE LINE OF itabline,
         directory   TYPE string,
         document    TYPE string,
         filesize    TYPE i,
         ls_temp     LIKE LINE OF gt_temp,
         result      TYPE tdbool,
         true        TYPE tdbool VALUE 'X',
         false       TYPE tdbool VALUE space.

  DATA : o_exception TYPE REF TO cx_root,
         lv_message  TYPE string.

  DATA : lv_zalno TYPE zgdmmt004z-zalno,
         lv_vrsio TYPE zgdmmt004z-vrsio.

  FIELD-SYMBOLS : <fs>     TYPE any.

  CASE fu_column.
    WHEN 'ATACH'.
      READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
        lv_zalno = <fs>.
        ASSIGN COMPONENT 'VRSIO' OF STRUCTURE <fs_lout> TO <fs>.
        lv_vrsio = <fs>.

        CONCATENATE lv_zalno lv_vrsio '.pdf' INTO lv_filename.
        CONCATENATE lv_filepath '/' lv_filename INTO lv_filepath.

        CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
          CHANGING
            sapworkdir            = directory
          EXCEPTIONS
            get_sapworkdir_failed = 1
            cntl_error            = 2
            error_no_gui          = 3
            not_supported_by_gui  = 4
            OTHERS                = 5.
        IF sy-subrc = 0.
          CONCATENATE directory '\' lv_filename INTO document.

          CALL METHOD cl_gui_frontend_services=>file_exist
            EXPORTING
              file            = document
            RECEIVING
              result          = result
            EXCEPTIONS
              cntl_error      = 1
              error_no_gui    = 2
              wrong_parameter = 3
              OTHERS          = 5.

          IF result = false.
            CALL METHOD cl_gui_frontend_services=>file_get_size
              EXPORTING
                file_name            = document
              IMPORTING
                file_size            = filesize
              EXCEPTIONS
                file_get_size_failed = 1
                cntl_error           = 2
                error_no_gui         = 3
                not_supported_by_gui = 4
                OTHERS               = 99.

            TRY .
                OPEN DATASET lv_filepath FOR INPUT IN BINARY MODE.
                DO.
                  READ DATASET lv_filepath INTO ls_itabline.
                  IF sy-subrc <> 0.
                    EXIT.
                  ENDIF.
                  APPEND ls_itabline TO itabline.
                ENDDO.
                CLOSE DATASET lv_filepath.
              CATCH cx_root INTO o_exception.
                CALL METHOD o_exception->if_message~get_text
                  RECEIVING
                    result = lv_message.
            ENDTRY.

            IF lv_message IS INITIAL.
              CALL METHOD cl_gui_frontend_services=>gui_download
                EXPORTING
                  bin_filesize            = filesize
                  filename                = document
                  filetype                = 'BIN'
                CHANGING
                  data_tab                = itabline
                EXCEPTIONS
                  file_write_error        = 1
                  no_batch                = 2
                  gui_refuse_filetransfer = 3
                  invalid_type            = 4
                  no_authority            = 5
                  unknown_error           = 6
                  header_not_allowed      = 7
                  separator_not_allowed   = 8
                  filesize_not_allowed    = 9
                  header_too_long         = 10
                  dp_error_create         = 11
                  dp_error_send           = 12
                  dp_error_write          = 13
                  unknown_dp_error        = 14
                  access_denied           = 15
                  dp_out_of_memory        = 16
                  disk_full               = 17
                  dp_timeout              = 18
                  file_not_found          = 19
                  dataprovider_exception  = 20
                  control_flush_error     = 21
                  not_supported_by_gui    = 22
                  error_no_gui            = 23
                  OTHERS                  = 24.

              ls_temp-document  = document.
              APPEND ls_temp TO gt_temp.
              CLEAR ls_temp.
            ENDIF.
          ENDIF.

          IF lv_message IS INITIAL.
            CALL METHOD cl_gui_frontend_services=>execute
              EXPORTING
                document               = document
              EXCEPTIONS
                cntl_error             = 1
                error_no_gui           = 2
                bad_parameter          = 3
                file_not_found         = 4
                path_not_found         = 5
                file_extension_unknown = 6
                error_execute_failed   = 7
                synchronous_failed     = 8
                not_supported_by_gui   = 9
                OTHERS                 = 10.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL .
        MESSAGE s000(zab) WITH 'Attachment not found' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  F_READ_CHANGES
*&---------------------------------------------------------------------*
FORM f_read_changes  USING    fu_display fu_zalno.
  DATA : editpos    TYPE STANDARD TABLE OF cdred,
         ls_editpos LIKE LINE OF editpos,
         ls_005     LIKE LINE OF gt_005,
         ls_x005    LIKE LINE OF gt_005.

  DATA : lv_objectclass   TYPE cdhdr-objectclas,
         lv_id            TYPE cdhdr-objectid,
         applicationid    TYPE repid,
         ls_variant       LIKE disvariant,
         lv_fieldname(30),
         lv_srno1         TYPE zhsmmmdt005-srno1,
         lv_srno2         TYPE zhsmmmdt005-srno1,
         lv_frgco_old     TYPE zhsmmmdt005-frgco,
         lv_frgco_new     TYPE zhsmmmdt005-frgco.

  DATA : lt_004      TYPE STANDARD TABLE OF zhsmmmst004,
         ls_004      LIKE LINE OF lt_004,
         ls_selfield TYPE slis_selfield,
         lv_exit.

  lv_objectclass  = 'EPROC_APPR'.
  lv_id           = fu_zalno.

  IF lv_id IS NOT INITIAL.
    CALL FUNCTION 'CHANGEDOCUMENT_READ'
      EXPORTING
        objectclass                = lv_objectclass
        objectid                   = lv_id
      TABLES
        editpos                    = editpos
      EXCEPTIONS
        no_position_found          = 1
        wrong_access_to_archive    = 2
        time_zone_conversion_error = 3
        OTHERS                     = 4.

    IF sy-subrc = 0.
      SORT editpos BY changenr udate utime.
      IF fu_display IS NOT INITIAL.
        LOOP AT editpos INTO ls_editpos.
          ls_004-zalno      = ls_editpos-objectid.
          ls_004-udate      = ls_editpos-udate.
          ls_004-utime      = ls_editpos-utime.
          ls_004-username	  = ls_editpos-username.
          ls_004-frgco_old  = ls_editpos-f_old.
          ls_004-frgco_new  = ls_editpos-f_new.
          APPEND ls_004 TO lt_004.
          CLEAR ls_004.
        ENDLOOP.

        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
          EXPORTING
            i_title                 = 'Change Documents'
            i_selection             = space
            i_allow_no_selection    = 'X'
            i_zebra                 = 'X'
            i_screen_start_column   = 2
            i_screen_start_line     = 2
            i_screen_end_column     = 150
            i_screen_end_line       = 15
            i_tabname               = 'LT_004'
            i_structure_name        = 'ZHSMMMST004'
            i_callback_program      = gv_repid
            i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
          IMPORTING
            es_selfield             = ls_selfield
            e_exit                  = lv_exit
          TABLES
            t_outtab                = lt_004
          EXCEPTIONS
            program_error           = 1
            OTHERS                  = 2.

*        CALL FUNCTION 'CHANGEDOCUMENT_DISPLAY'
*          EXPORTING
*            i_applicationid       = sy-repid
*            flg_autocondense      = 'X'
*            is_variant            = ls_variant
*            i_objectclas          = lv_objectclass
*            i_screen_start_line   = 10
*            i_screen_start_column = 10
*            i_screen_end_line     = 20
*            i_screen_end_column   = 150
*          TABLES
*            i_cdred               = editpos.
      ELSE.
        LOOP AT gt_005 INTO ls_005.
          LOOP AT editpos INTO ls_editpos.
            lv_frgco_old  = ls_editpos-f_old.
            lv_frgco_new  = ls_editpos-f_new.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_READ_CHANGES

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ATTACHMENT_NEW
*&---------------------------------------------------------------------*
FORM f_display_attachment_new  USING    fu_row fu_column fu_getoff.
  DATA : ls_04z    LIKE LINE OF gt_004z,
         lt_form01 TYPE STANDARD TABLE OF itcoo,
         lt_form02 TYPE STANDARD TABLE OF itcoo,
         lt_form03 TYPE STANDARD TABLE OF itcoo,
         lt_form04 TYPE STANDARD TABLE OF itcoo.

  DATA : lt_otf     TYPE TABLE OF itcoo,
         lv_objlen  TYPE sood-objlen,
         lv_xstring TYPE xstring,
         lt_lines   TYPE TABLE OF tline,
         lv_zalno   TYPE zgdmmt004z-zalno,
         lv_submi   TYPE zgdmmt004z-submi,
         lv_prgrp   TYPE zgdmmt004z-prgrp.

  FIELD-SYMBOLS <fs>         TYPE any.

  CLEAR : gt_objbin[].

  READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
    lv_zalno = <fs>.
    ASSIGN COMPONENT 'SUBMI' OF STRUCTURE <fs_lout> TO <fs>.
    lv_submi = <fs>.
    ASSIGN COMPONENT 'PRGRP' OF STRUCTURE <fs_lout> TO <fs>.
    lv_prgrp = <fs>.

    READ TABLE gt_004z INTO ls_04z
                       WITH KEY zalno = lv_zalno
                                submi = lv_submi.
    IF sy-subrc = 0.
      CALL FUNCTION 'ZHSMMM_FM002'
        EXPORTING
          pi_submi            = lv_submi
          pi_zalno            = lv_zalno
          pi_prgrp            = lv_prgrp
          pi_getoff           = fu_getoff
          pi_tdnoprev         = space
          pi_preview          = space
          pi_nodialog         = 'X'
        TABLES
          pt_form01           = lt_form01
          pt_form02           = lt_form02
          pt_form03           = lt_form03
          pt_form04           = lt_form04
        EXCEPTIONS
          product_group_error = 1
          OTHERS              = 2.
    ENDIF.

    IF lt_form01[] IS NOT INITIAL.
      lt_otf[] = lt_form01[].
    ELSEIF lt_form02[] IS NOT INITIAL.
      lt_otf[] = lt_form02[].
    ELSEIF lt_form03[] IS NOT INITIAL.
      lt_otf[] = lt_form03[].
    ELSEIF lt_form04[] IS NOT INITIAL.
      lt_otf[] = lt_form04[].
    ENDIF.

    IF lt_otf[] IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 132
        IMPORTING
          bin_filesize          = lv_objlen
          bin_file              = lv_xstring
        TABLES
          otf                   = lt_otf
          lines                 = lt_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          OTHERS                = 4.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_xstring
        TABLES
          binary_tab = gt_objbin[].

      PERFORM f_download_to_local USING lv_zalno lv_submi ls_04z-vrsio.

*      CALL SCREEN 102.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISPLAY_ATTACHMENT_NEW

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  DATA : lv_url(255),
         lt_data            TYPE STANDARD TABLE OF x255.

  CREATE OBJECT g_html_container
    EXPORTING
      container_name = 'CC_PDF'.

  CREATE OBJECT g_html_control
    EXPORTING
      parent = g_html_container.

  CALL METHOD g_html_control->load_data
    EXPORTING
      type                   = 'applictaion'
      subtype                = 'pdf'
    IMPORTING
      assigned_url           = lv_url
    CHANGING
      data_table             = gt_objbin
    EXCEPTIONS
      dp_invalid_parameter   = 1
      dp_error_general       = 2
      cntl_error             = 3
      html_syntax_notcorrect = 4
      OTHERS                 = 5.

  CALL METHOD g_html_control->show_url
    EXPORTING
      url                    = lv_url
      in_place               = 'X'
    EXCEPTIONS
      cntl_error             = 1
      cnht_error_not_allowed = 2
      cnht_error_parameter   = 3
      dp_error_general       = 4
      OTHERS                 = 5.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_TO_LOCAL
*&---------------------------------------------------------------------*
FORM f_download_to_local USING fu_zalno fu_submi fu_vrsio.
  DATA : directory   TYPE string,
         lv_filename TYPE string,
         document    TYPE string.

  CONCATENATE fu_zalno fu_submi fu_vrsio '.pdf' INTO lv_filename.

  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
    CHANGING
      sapworkdir            = directory
    EXCEPTIONS
      get_sapworkdir_failed = 1
      cntl_error            = 2
      error_no_gui          = 3
      not_supported_by_gui  = 4
      OTHERS                = 5.

  IF sy-subrc = 0.
    CONCATENATE directory '\' lv_filename INTO document.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = document
        filetype                = 'BIN'
      CHANGING
        data_tab                = gt_objbin
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc = 0.
      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = document
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_TO_LOCAL

*&---------------------------------------------------------------------*
*&      Form  F_FREE_PDF_TEMP
*&---------------------------------------------------------------------*
FORM f_free_pdf_temp .
  DATA : path         TYPE string,
         ftab(200)    TYPE c OCCURS 0,
         ls_tab       LIKE LINE OF ftab,
         i            TYPE i,
         lv_filename  TYPE string,
         lv_extension TYPE string,
         rc           TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
    CHANGING
      sapworkdir            = path
    EXCEPTIONS
      get_sapworkdir_failed = 1
      cntl_error            = 2
      error_no_gui          = 3
      not_supported_by_gui  = 4
      OTHERS                = 5.

  CALL METHOD cl_gui_frontend_services=>directory_list_files
    EXPORTING
      directory                   = path
      filter                      = '*.*'
    CHANGING
      file_table                  = ftab
      count                       = i
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      OTHERS                      = 5.

  LOOP AT ftab INTO ls_tab.
    SPLIT ls_tab AT '.' INTO lv_filename lv_extension.
    TRANSLATE lv_extension TO UPPER CASE.
    IF lv_extension = 'PDF'.
      lv_filename = ls_tab.
      CONCATENATE path '\' lv_filename INTO lv_filename.
      CALL METHOD cl_gui_frontend_services=>file_delete
        EXPORTING
          filename             = lv_filename
        CHANGING
          rc                   = rc
        EXCEPTIONS
          file_delete_failed   = 1
          cntl_error           = 2
          error_no_gui         = 3
          file_not_found       = 4
          access_denied        = 5
          unknown_error        = 6
          not_supported_by_gui = 7
          wrong_parameter      = 8.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FREE_PDF_TEMP

*&---------------------------------------------------------------------*
*&      Form  F_LIST_SPLIT
*&---------------------------------------------------------------------*
FORM f_list_split  USING    fu_row_id.
  DATA : lt_006      TYPE STANDARD TABLE OF zhsmmmst006,
         ls_006      LIKE LINE OF lt_006,
         ls_004p     LIKE LINE OF gt_004p,
         ls_selfield TYPE slis_selfield,
         lv_exit.

  DATA : lv_zalno   TYPE zgdmmt004p-zalno.
  FIELD-SYMBOLS <fs>    TYPE any.

  READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row_id.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
    lv_zalno = <fs>.
    LOOP AT gt_004p INTO ls_004p WHERE zalno = lv_zalno.
      MOVE-CORRESPONDING ls_004p TO ls_006.
      APPEND ls_006 TO lt_006.
      CLEAR ls_006.
    ENDLOOP.

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title                 = 'Distribute PO'
        i_selection             = space
        i_allow_no_selection    = 'X'
        i_zebra                 = 'X'
        i_screen_start_column   = 2
        i_screen_start_line     = 2
        i_screen_end_column     = 150
        i_screen_end_line       = 15
        i_tabname               = 'LT_006'
        i_structure_name        = 'ZHSMMMST006'
        i_callback_program      = gv_repid
        i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
      IMPORTING
        es_selfield             = ls_selfield
        e_exit                  = lv_exit
      TABLES
        t_outtab                = lt_006
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ENDIF.
ENDFORM.                    " F_LIST_SPLIT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FPKH
*&---------------------------------------------------------------------*
FORM f_print_fpkh  USING    fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         ls_004z     LIKE LINE OF gt_004z,
         lv_time(10), lv_date(10),
         document    TYPE string,
         lv_zalno    TYPE zgdmmt004z-zalno,
         lv_submi    TYPE zgdmmt004z-submi.

  FIELD-SYMBOLS <fs>        TYPE any.

  READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
    lv_zalno = <fs>.
    ASSIGN COMPONENT 'SUBMI' OF STRUCTURE <fs_lout> TO <fs>.
    lv_submi = <fs>.
    CLEAR ls_004z.
    READ TABLE gt_004z INTO ls_004z
                       WITH KEY zalno = lv_zalno
                                submi = lv_submi.
    IF sy-subrc = 0.
      lv_time = sy-uzeit.
      lv_date = sy-datum.
      CONDENSE: lv_time, lv_date.
      CONCATENATE ls_004z-url '?V=' lv_date lv_time INTO ls_004z-url.
      document = ls_004z-url.
      IF document IS NOT INITIAL.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = document
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FPKH
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_lamp
*&---------------------------------------------------------------------*
FORM f_print_lamp  USING    fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         ls_004z     LIKE LINE OF gt_004z,
         document    TYPE string,
         lv_time(10), lv_date(10),
         lv_zalno    TYPE zgdmmt004z-zalno,
         lv_submi    TYPE zgdmmt004z-submi.

  FIELD-SYMBOLS <fs>        TYPE any.

  READ TABLE <fs_out> INTO <fs_lout> INDEX fu_row.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'ZALNO' OF STRUCTURE <fs_lout> TO <fs>.
    lv_zalno = <fs>.
    ASSIGN COMPONENT 'SUBMI' OF STRUCTURE <fs_lout> TO <fs>.
    lv_submi = <fs>.
    CLEAR ls_004z.
    READ TABLE gt_004z INTO ls_004z
                       WITH KEY zalno = lv_zalno
                                submi = lv_submi.
    IF sy-subrc = 0 AND ls_004z-lampiran IS NOT INITIAL.

      AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
             ID 'FRGCO' FIELD 'FD' " -->  variable FD   = Release code
               ID 'FRGGR' FIELD '40'. " --> variable 40 =  Release group

      lv_time = sy-uzeit.
      lv_date = sy-datum.
      CONDENSE: lv_time, lv_date.
      CONCATENATE ls_004z-lampiran '?V=' lv_date lv_time INTO ls_004z-lampiran.
      document = ls_004z-lampiran.
      IF document IS NOT INITIAL.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = document
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FPKH
