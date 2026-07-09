*&---------------------------------------------------------------------*
*&  Include           ZCORETAX_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
ENDFORM.                    " F_INIT_DATA

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
      window_title      = 'Select the files'
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
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
**  CASE 'X'.
**    WHEN radio1.
**      PERFORM f_modify_screen USING : 'STK' '0' '' '' '',
**                                      'SER' '0' '' '' '',
**                                      'SKD' '0' '' '' ''.
**    WHEN radio2.
**      PERFORM f_modify_screen USING : 'SVF' '0' '' '' '',
**                                      'SFK' '0' '' '' '',
**                                      'SVL' '0' '' '' '',
**                                      'STX' '0' '' '' '',
**                                      'SKD' '0' '' '' ''.
**    WHEN radio3.
**      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
**                                      'SVL' '0' '' '' '',
**                                      'STX' '0' '' '' '',
**                                      'STK' '0' '' '' '',
**                                      'SER' '0' '' '' ''.
**  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF p_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
**FORM f_f4_filename  CHANGING fc_fname.
**  DATA : directory TYPE string,
**         filetable TYPE filetable,
**         line      TYPE LINE OF filetable,
**         rc        TYPE i.
**
**  CALL METHOD cl_gui_frontend_services=>get_temp_directory
**    CHANGING
**      temp_dir = directory.
**  CALL METHOD cl_gui_frontend_services=>file_open_dialog
**    EXPORTING
**      window_title      = 'Select the files'
**      initial_directory = directory
**      file_filter       = '*.*'
**      multiselection    = ' '
**    CHANGING
**      file_table        = filetable
**      rc                = rc.
**  IF rc = 1.
**    READ TABLE filetable INDEX 1 INTO line.
**    fc_fname = line-filename.
**  ENDIF.
**ENDFORM.                    " F_F4_FILENAME

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
FORM f_get_data.
  DATA: lt_ce18010 TYPE STANDARD TABLE OF ce18010.
  DATA: lt_ce18010_1 TYPE STANDARD TABLE OF ce18010.
  DATA: lt_bkpf TYPE STANDARD TABLE OF bkpf.
  DATA: lt_mkpf TYPE STANDARD TABLE OF mkpf.
  DATA: ls_ce18010 LIKE LINE OF lt_ce18010.
  DATA: ls_out LIKE LINE OF gt_out.
  DATA: ls_bkpf LIKE LINE OF lt_bkpf.
  DATA: ls_mkpf LIKE LINE OF lt_mkpf.
  DATA: BEGIN OF lt_awkey OCCURS 0,
          bukrs TYPE bkpf-bukrs,
          gjahr TYPE bkpf-gjahr,
          awkey TYPE bkpf-awkey,
        END OF lt_awkey.
   TYPES: BEGIN OF ty_document,
           belnr TYPE bkpf-belnr,
           sgtxt TYPE bseg-sgtxt,
           kstar TYPE bseg-kstar,
           paobjnr TYPE bseg-paobjnr,
           ce4key TYPE ce48010_acct-ce4key,
         END OF ty_document.
  DATA: lt_document  TYPE TABLE OF ty_document.
*        lt_document2 TYPE TABLE OF ty_document2.
  IF p_bukrs = '8010'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ce18010 FROM ce18010 " AS a JOIN bkpf AS b ON a~rbeln = b~belnr
      WHERE bukrs = p_bukrs
        AND gsber = '0100'
        AND perio IN s_perio  "= p_perio
        AND gjahr = p_gjahr
        AND wwsec IN s_wwsec
        AND wwtrz IN s_wwtrz.
    "      AND vrgar NE 'C'.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ce18010 FROM ce18010 " AS a JOIN bkpf AS b ON a~rbeln = b~belnr
      WHERE bukrs = p_bukrs
        AND perio IN s_perio  "= p_perio
        AND gjahr = p_gjahr
        AND wwsec IN s_wwsec
        AND wwtrz IN s_wwtrz.
  ENDIF.

****  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ce18010 FROM ce18010 " AS a JOIN bkpf AS b ON a~rbeln = b~belnr
****    WHERE bukrs = p_bukrs
*****      AND gsber = p_gsber
****      AND werks = p_gsber
****      AND perio = p_perio
****      AND gjahr = p_gjahr
****      AND wwsec IN s_wwsec
****      AND wwtrz IN s_wwtrz.
****  "      AND vrgar NE 'C'.

  lt_ce18010_1[] = lt_ce18010[].
  SORT lt_ce18010_1 BY rbeln.
  DELETE lt_ce18010_1[] WHERE vrgar EQ 'C'.
  DELETE ADJACENT DUPLICATES FROM lt_ce18010_1 COMPARING rbeln.
  IF lt_ce18010_1[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bkpf FROM bkpf FOR ALL ENTRIES IN lt_ce18010_1
      WHERE bukrs = lt_ce18010_1-bukrs
        AND gjahr = lt_ce18010_1-gjahr
        AND belnr = lt_ce18010_1-rbeln.
  ENDIF.
  SORT lt_ce18010 BY bukrs gjahr rbeln.
  SORT lt_ce18010_1 BY bukrs gjahr rbeln.



  IF lt_bkpf[] IS NOT INITIAL.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_document FROM bseg
    JOIN ce48010_acct ON ce48010_acct~paobjnr = bseg~paobjnr
    FOR ALL ENTRIES IN lt_bkpf
    WHERE bseg~belnr = lt_bkpf-belnr
    AND bseg~gjahr = lt_bkpf-gjahr.
  ENDIF.



  LOOP AT lt_ce18010 INTO ls_ce18010.
    MOVE-CORRESPONDING ls_ce18010 TO ls_out.
    IF ls_out-kstar IS INITIAL AND ls_ce18010-wwprn IS INITIAL.
      CONTINUE.
    ELSEIF ls_out-kstar IS INITIAL.
      ls_out-kstar = ls_ce18010-wwprn.
    ENDIF.
    SORT lt_bkpf BY bukrs gjahr belnr.
    READ TABLE lt_bkpf INTO ls_bkpf
        WITH KEY bukrs = ls_ce18010-bukrs
                 gjahr = ls_ce18010-gjahr
                 belnr = ls_ce18010-rbeln
       BINARY SEARCH .
    IF sy-subrc EQ 0.
      ls_out-bldat = ls_bkpf-bldat.
      ls_out-xblnr = ls_bkpf-xblnr.
      DELETE lt_ce18010_1[] WHERE bukrs = ls_ce18010-bukrs
                 AND gjahr = ls_ce18010-gjahr
                 AND rbeln = ls_ce18010-rbeln.
    ENDIF.
    IF ls_ce18010-vrgar EQ 'C'.
      CLEAR: ls_out-xblnr.
    ENDIF.
    ls_out-vv001 = ls_ce18010-vv856 + ls_ce18010-vv846 + ls_ce18010-vv845 + ls_ce18010-vv860.
    ls_out-vv002 = ls_ce18010-vv857 + ls_ce18010-vv818 + ls_ce18010-vvd01 + ls_ce18010-vvd11 + ls_ce18010-vv841 +
                   ls_ce18010-vvd02 + ls_ce18010-vvd12 + ls_ce18010-vv842 + ls_ce18010-vv858 + ls_ce18010-vv837 +
                   ls_ce18010-vv812 + ls_ce18010-vv823 + ls_ce18010-vv847 + ls_ce18010-vvd03 + ls_ce18010-vv859 +
                   ls_ce18010-vvd05 + ls_ce18010-vv864 + ls_ce18010-vv862 + ls_ce18010-vv863 + ls_ce18010-vvd16 +
                   ls_ce18010-vvd15 + ls_ce18010-vvd13 + ls_ce18010-vv810.
    ls_out-vv000 = ls_out-vv001 + ls_out-vv002.

    READ TABLE lt_document INTO DATA(ls_document) WITH KEY belnr = ls_ce18010-rbeln kstar = ls_ce18010-kstar ce4key = ls_ce18010-paobjnr.
    IF sy-subrc = 0.
      ls_out-sgtxt = ls_document-sgtxt.
    ENDIF.

    APPEND ls_out TO gt_out.
    CLEAR: ls_out.
  ENDLOOP.
  IF lt_ce18010_1[] IS NOT INITIAL.
    LOOP AT lt_ce18010_1 INTO ls_ce18010.
      lt_awkey-bukrs = ls_ce18010-bukrs.
      lt_awkey-gjahr = ls_ce18010-gjahr.
      CONCATENATE ls_ce18010-rbeln ls_ce18010-bukrs ls_ce18010-gjahr INTO lt_awkey-awkey. "
      APPEND lt_awkey.
      CONCATENATE ls_ce18010-rbeln ls_ce18010-gjahr INTO lt_awkey-awkey. "
      APPEND lt_awkey.
    ENDLOOP.
    IF lt_awkey[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bkpf FROM bkpf FOR ALL ENTRIES IN lt_awkey
        WHERE bukrs = lt_awkey-bukrs
          AND gjahr = lt_awkey-gjahr
          AND awkey = lt_awkey-awkey.
    ENDIF.
    IF lt_bkpf[] IS NOT INITIAL.
      SORT gt_out BY bukrs gjahr rbeln.
      LOOP AT lt_bkpf INTO ls_bkpf.
        LOOP AT gt_out INTO ls_out WHERE bukrs = ls_bkpf-bukrs
                     AND gjahr = ls_bkpf-gjahr
                     AND rbeln = ls_bkpf-awkey(10)
                     AND vrgar NE 'C'.
          ls_out-xblnr = ls_bkpf-xblnr.
          MODIFY gt_out FROM ls_out.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: ls_out TYPE ty_out.
  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.
  LOOP AT gt_out INTO ls_out.
**    ls_stylerow-fieldname = 'MARK'.
**    APPEND ls_stylerow TO ls_out-style.
    ls_out-vv001 = ls_out-vv001 * 100.
    ls_out-vv002 = ls_out-vv002 * 100.
    ls_out-vv000 = ls_out-vv000 * 100.
    MODIFY  gt_out FROM ls_out .
    CLEAR ls_out-style[].
  ENDLOOP.
  ASSIGN gt_out TO <fs_out>.
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
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  SET PF-STATUS 'STANDARD'. " EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
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
         ls_filter LIKE LINE OF gt_filter.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

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
        PERFORM f_alv_refresh USING 'X'.
        "        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '&PRN'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_alv_refresh USING 'X'.
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

    gs_variant-report  = gv_repid.
    gs_variant-variant = pa_vari.

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
*  gs_layout_alv-sel_mode            = selected.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

*  PERFORM f_alv_sort USING : 1 'TKNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr  TYPE REF TO cl_abap_structdescr,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         lt_dfies     TYPE ddfields,
         ls_dfies     TYPE dfies,
         ls_fieldcat  TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.

    CASE ls_dfies-fieldname.
**      WHEN 'MARK'.
**        PERFORM f_change_dyn_fieldcat USING :
**        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' '' ''
**        CHANGING ls_fieldcat.
      WHEN 'BUKRS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'GSBER'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'GJAHR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'SPMON'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Period Tax' '' '' '' '' '' '' '' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'WWSEC'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'WWTRZ'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'RBELN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Ref. Document' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BELNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'CO Document' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'XBLNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Assignment' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BUDAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Posting Date' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VRGAR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Record Type' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PRCTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'KSTAR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'RKAUFNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Order' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BLDAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Document Date' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'SGTXT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Text' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VV001'. "CE18010-VV856 + CE18010-VV846
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Above The Line' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.

      WHEN 'VV002'. "CE18010-VV857+ VV818 + VVD01 + VVD11 + VV841 + VVD02 + VVD12 + VV842 + VV858 + VV837 + VV812 +
        " VV823 + VV847 + VVD03 + VV859 + VVD05 + VV864 + VV862 + VV863 + VVD16 + VVD15 + VVD13 + VV810
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Below The Line' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.

      WHEN 'VV000'. "CE18010-VV001 + CE18010-VV002
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Total Expense' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.

    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
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
        lv_tabix = sy-tabix.

        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
          CLEAR ls_filter.
          READ TABLE gt_filter INTO ls_filter
                               WITH KEY index = lv_tabix.
          IF sy-subrc = 0.
            CONTINUE.
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
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum fu_emphasize
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  PERFORM f_move_fieldcat USING fu_currency
                          CHANGING fs_dyn_fcat-currency.
  PERFORM f_move_fieldcat USING fu_cfieldname
                          CHANGING fs_dyn_fcat-cfieldname.
  PERFORM f_move_fieldcat USING fu_quantity
                          CHANGING fs_dyn_fcat-quantity.
  PERFORM f_move_fieldcat USING fu_qfieldname
                          CHANGING fs_dyn_fcat-qfieldname.
  PERFORM f_move_fieldcat USING fu_checkbox
                          CHANGING fs_dyn_fcat-checkbox.
  PERFORM f_move_fieldcat USING fu_edit
                          CHANGING fs_dyn_fcat-edit.
  PERFORM f_move_fieldcat USING fu_outputlen
                          CHANGING fs_dyn_fcat-outputlen.
  PERFORM f_move_fieldcat USING fu_inttype
                          CHANGING fs_dyn_fcat-inttype.
  PERFORM f_move_fieldcat USING fu_no_out
                          CHANGING fs_dyn_fcat-no_out.
  PERFORM f_move_fieldcat USING fu_tech
                          CHANGING fs_dyn_fcat-tech.
  PERFORM f_move_fieldcat USING fu_key
                          CHANGING fs_dyn_fcat-key.
  PERFORM f_move_fieldcat USING fu_fix
                          CHANGING fs_dyn_fcat-fix_column.
  PERFORM f_move_fieldcat USING fu_icon
                          CHANGING fs_dyn_fcat-icon.
  PERFORM f_move_fieldcat USING fu_sum
                          CHANGING fs_dyn_fcat-do_sum.
  PERFORM f_move_fieldcat USING fu_nosum
                          CHANGING fs_dyn_fcat-no_sum.
  PERFORM f_move_fieldcat USING fu_emphasize
                          CHANGING fs_dyn_fcat-emphasize.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_MOVE_FIELDCAT


*&---------------------------------------------------------------------*
*&      Form  F_LAST_DAY
*&---------------------------------------------------------------------*
FORM f_last_day  USING    fu_date
                 CHANGING fc_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_date
    IMPORTING
      last_day_of_month = fc_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_F4
*&---------------------------------------------------------------------*
FORM f_alv_variant_f4  CHANGING p_pa_vari.
  DATA : rs_variant LIKE disvariant.
  DATA : nof4 TYPE c.

  CLEAR nof4.
  LOOP AT SCREEN.
    IF screen-name = 'PA_VARI'.
      IF screen-input = 0.
        nof4 = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  rs_variant-report   = gv_repid.
  rs_variant-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = rs_variant
      i_save     = 'A'
    IMPORTING
      es_variant = rs_variant
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc = 0 AND
    nof4 EQ space.
    pa_vari = rs_variant-variant.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PATH  text
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
FORM f_print_pdf  USING  p_file.
  DATA:
    zlv_filep       TYPE filep VALUE 'C:\temp\test.pdf',
    zlv_extension   TYPE filep,
    zlv_key         TYPE string,
    zlv_application TYPE string,
    zlv_program     TYPE string,
    zlv_parameter   TYPE string.

  zlv_filep = p_file.
* Extension.
  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file          = zlv_filep
    IMPORTING
      pfx_dotextension = zlv_extension.

* Application
  zlv_key = zlv_extension.
  CALL METHOD cl_gui_frontend_services=>registry_get_value
    EXPORTING
      root      = cl_gui_frontend_services=>hkey_classes_root
      key       = zlv_key
    IMPORTING
      reg_value = zlv_application.

* Executable
  CONCATENATE zlv_application '\shell\open\command' INTO zlv_key.
  CALL METHOD cl_gui_frontend_services=>registry_get_value
    EXPORTING
      root      = cl_gui_frontend_services=>hkey_classes_root
      key       = zlv_key
    IMPORTING
      reg_value = zlv_program.
  REPLACE ALL OCCURRENCES OF '"%1"' IN zlv_program WITH ''.

* Print (/t for Acrobat Reader)
  CONCATENATE  '/t' zlv_filep  INTO zlv_parameter SEPARATED BY space.
  CALL METHOD cl_gui_frontend_services=>execute
    EXPORTING
      application = zlv_program
      parameter   = zlv_parameter.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_LOCALFNAME  text
*      -->P_D_SERVERFNAME  text
*----------------------------------------------------------------------*
FORM f_move_local  USING    p_localfname
                            p_serverfname
                   CHANGING p_return.

  DATA: d_serverfname TYPE eseftappl,
        d_localfname  TYPE string,
        d_binsize     TYPE i,
        d_binsizeall  TYPE i,
        d_binfile     TYPE xstring,
        wa_pdf        TYPE rcgrepfile,
        t_pdf         TYPE TABLE OF rcgrepfile,
        lv_return(1).
  CLEAR: lv_return.
  d_serverfname = p_serverfname.
  d_localfname = p_localfname.
  OPEN DATASET d_serverfname FOR INPUT IN BINARY MODE.
  IF sy-subrc NE 0.
    p_return = '4'.
    RETURN.
  ENDIF.
  DO.
    CLEAR: wa_pdf, d_binsize.
    READ DATASET d_serverfname INTO wa_pdf LENGTH d_binsize.
    IF sy-subrc = 0.
      d_binsizeall = d_binsizeall + d_binsize.
      APPEND wa_pdf TO t_pdf.
    ELSE.
      IF d_binsize > 0.
        d_binsizeall = d_binsizeall + d_binsize.
        APPEND wa_pdf TO t_pdf.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.
  CLOSE DATASET d_serverfname.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize = d_binsizeall
      filename     = d_localfname
      filetype     = 'BIN'
    TABLES
      data_tab     = t_pdf.
  p_return = sy-subrc.

**    d_serverfname = lv_filedest.
**    CONCATENATE 'C:\Coretax\PDF\'  ls_out-belnr '.PDF' INTO d_localfname.
**
**    CONDENSE: d_serverfname, d_localfname.
**
**    CALL FUNCTION 'C13Z_FILE_DOWNLOAD_BINARY'
**      EXPORTING
**        i_file_front_end    = d_localfname
**        i_file_appl         = d_serverfname
**        i_file_overwrite    = 'X'
**      EXCEPTIONS
**        fe_file_open_error  = 1
**        fe_file_exists      = 2
**        fe_file_write_error = 3
**        ap_no_authority     = 4
**        ap_file_open_error  = 5
**        ap_file_empty       = 6
**        OTHERS              = 7.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PERIO
*&---------------------------------------------------------------------*
FORM f_init_perio .
  s_perio-sign = 'I'.
  s_perio-option = 'EQ'.
  s_perio-low = |{ sy-datum(4) } 0 { sy-datum+4(2) }|.
  APPEND s_perio.
ENDFORM.
