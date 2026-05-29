*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

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
  DATA : directory  TYPE string,
         filetable  TYPE filetable,
         line       TYPE LINE OF filetable,
         rc         TYPE i.

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
  SELECT a~belnr a~gjahr blart bldat budat a~xblnr a~bukrs a~lifnr waers
         kursf rmwwr beznk wmwst1 mwskz1 wmwst2 mwskz2 zterm zbd1t zbd1p
         bktxt zbd2t zbd2p zbd3t wskto xrech a~zuonr
    INTO CORRESPONDING FIELDS OF TABLE gt_rbkp
    FROM rbkp AS a JOIN rseg AS b ON a~belnr = b~belnr AND
                                     a~gjahr = b~gjahr
    WHERE a~bukrs = p_bukrs
      AND a~gjahr = p_gjahr
*      AND a~lifnr = p_lifnr
      AND a~lifnr IN s_lifnr
      AND a~blart = 'RE'
      AND a~stblg = space
      AND a~xrech = 'X'
      AND a~zuonr IN s_zuonr
      AND b~matnr IN s_matnr.

  IF gt_rbkp[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.

  ELSE.
*    gt_rbkp2[] = gt_rbkp[].
*    DELETE gt_rbkp  WHERE xrech = space.
*    DELETE gt_rbkp2 WHERE xrech = 'X'.

    PERFORM f_get_nota_retur.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: lt_rbkp       TYPE TABLE OF rbkp WITH HEADER LINE,
        ls_rbkp       LIKE LINE OF gt_rbkp,
        ls_rbkp2      LIKE LINE OF gt_rbkp2,
        ls_zfvatin_nr LIKE LINE OF gt_zfvatin_nr,
        lv_dpp        TYPE rbkp-rmwwr,
        lv_ppn        TYPE rbkp-rmwwr,
        lv_dppppn     TYPE rbkp-rmwwr.

  "Summaries RBKP
  LOOP AT gt_rbkp INTO ls_rbkp.
    lt_rbkp-zuonr   = ls_rbkp-zuonr.
    lt_rbkp-rmwwr   = ls_rbkp-rmwwr.
    lt_rbkp-wmwst1  = ls_rbkp-wmwst1.
    COLLECT lt_rbkp.
  ENDLOOP.

  SORT : lt_rbkp BY zuonr,
         gt_rbkp BY zuonr belnr DESCENDING.

  LOOP AT lt_rbkp.
    CLEAR ls_rbkp.
    READ TABLE gt_rbkp INTO ls_rbkp
                       WITH KEY zuonr = lt_rbkp-zuonr.

*    LOOP AT gt_rbkp INTO ls_rbkp.
    CASE 'X'.
      WHEN radio1.
        CLEAR: lv_dpp,lv_ppn,lv_dppppn,ls_zfvatin_nr.
        READ TABLE gt_zfvatin_nr INTO ls_zfvatin_nr
                                 WITH KEY vatpr1 = ls_rbkp-zuonr.

        IF sy-subrc = 0.
          LOOP AT gt_zfvatin_nr INTO ls_zfvatin_nr
                                WHERE vatpr1 = ls_rbkp-zuonr.

            CLEAR ls_rbkp2.
            READ TABLE gt_rbkp2 INTO ls_rbkp2
                                WITH KEY belnr = ls_zfvatin_nr-belnr.

            READ TABLE gt_out WITH KEY zuonr = ls_rbkp-zuonr
                                       nonr  = ls_zfvatin_nr-nonr
                              TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              <fs_out>-bldat      = ls_rbkp-bldat.
              <fs_out>-budat      = ls_rbkp-budat.
              <fs_out>-belnr      = ls_rbkp-belnr.
              <fs_out>-xblnr      = ls_rbkp-xblnr.
              <fs_out>-zuonr      = ls_rbkp-zuonr.
              <fs_out>-bktxt      = ls_rbkp-bktxt.
*                <fs_out>-nonr       = ls_zfvatin_nr-nonr.
*                <fs_out>-vatdt1     = ls_zfvatin_nr-vatdt1.
*                <fs_out>-waers      = ls_rbkp-waers.
              lv_dpp              = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
              lv_ppn              = lt_rbkp-wmwst1.
              lv_dppppn           = <fs_out>-dpp + <fs_out>-ppn.
              ADD:  lv_dpp    TO <fs_out>-dpp,
                    lv_ppn    TO <fs_out>-ppn,
                    lv_dppppn TO <fs_out>-dppppn.
              <fs_out>-dpppake    = ls_rbkp2-rmwwr - ls_rbkp2-wmwst1.
              <fs_out>-ppnpake    = ls_rbkp2-wmwst1.
              <fs_out>-dppppnpake = <fs_out>-dpppake + <fs_out>-ppnpake.
              <fs_out>-dppsisa    = <fs_out>-dpp - <fs_out>-dpppake.
              <fs_out>-ppnsisa    = <fs_out>-ppn - <fs_out>-ppnpake.
              <fs_out>-dppppnsisa = <fs_out>-dppppn - <fs_out>-dppppnpake.

            ELSE.
              APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
              <fs_out>-bldat      = ls_rbkp-bldat.
              <fs_out>-budat      = ls_rbkp-budat.
              <fs_out>-belnr      = ls_rbkp-belnr.
              <fs_out>-xblnr      = ls_rbkp-xblnr.
              <fs_out>-zuonr      = ls_rbkp-zuonr.
              <fs_out>-bktxt      = ls_rbkp-bktxt.
              <fs_out>-nonr       = ls_zfvatin_nr-nonr.
              <fs_out>-vatdt1     = ls_zfvatin_nr-vatdt1.
              <fs_out>-waers      = ls_rbkp-waers.
              <fs_out>-dpp        = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
              <fs_out>-ppn        = lt_rbkp-wmwst1.
              <fs_out>-dppppn     = <fs_out>-dpp + <fs_out>-ppn.
              <fs_out>-dpppake    = ls_rbkp2-rmwwr - ls_rbkp2-wmwst1.
              <fs_out>-ppnpake    = ls_rbkp2-wmwst1.
              <fs_out>-dppppnpake = <fs_out>-dpppake + <fs_out>-ppnpake.
              <fs_out>-dppsisa    = <fs_out>-dpp - <fs_out>-dpppake.
              <fs_out>-ppnsisa    = <fs_out>-ppn - <fs_out>-ppnpake.
              <fs_out>-dppppnsisa = <fs_out>-dppppn - <fs_out>-dppppnpake.
            ENDIF.
          ENDLOOP.

        ELSE.
          READ TABLE gt_out WITH KEY zuonr = ls_rbkp-zuonr
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            <fs_out>-bldat      = ls_rbkp-bldat.
            <fs_out>-budat      = ls_rbkp-budat.
            <fs_out>-belnr      = ls_rbkp-belnr.
            <fs_out>-xblnr      = ls_rbkp-xblnr.
            <fs_out>-zuonr      = ls_rbkp-zuonr.
            <fs_out>-bktxt      = ls_rbkp-bktxt.
            <fs_out>-nonr       = ls_zfvatin_nr-nonr.
            <fs_out>-vatdt1     = ls_zfvatin_nr-vatdt1.
            <fs_out>-waers      = ls_rbkp-waers.
            lv_dpp              = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
            lv_ppn              = lt_rbkp-wmwst1.
            ADD:  lv_dpp TO <fs_out>-dpp,
                  lv_dpp TO <fs_out>-dppsisa,
                  lv_ppn TO <fs_out>-ppn,
                  lv_ppn TO <fs_out>-ppnsisa.
            <fs_out>-dppppnsisa = <fs_out>-dppppn     = <fs_out>-dpp + <fs_out>-ppn.

          ELSE.
            APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
            <fs_out>-bldat      = ls_rbkp-bldat.
            <fs_out>-budat      = ls_rbkp-budat.
            <fs_out>-belnr      = ls_rbkp-belnr.
            <fs_out>-xblnr      = ls_rbkp-xblnr.
            <fs_out>-zuonr      = ls_rbkp-zuonr.
            <fs_out>-bktxt      = ls_rbkp-bktxt.
            <fs_out>-nonr       = ls_zfvatin_nr-nonr.
            <fs_out>-vatdt1     = ls_zfvatin_nr-vatdt1.
            <fs_out>-waers      = ls_rbkp-waers.
            <fs_out>-dppsisa    = <fs_out>-dpp        = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
            <fs_out>-ppnsisa    = <fs_out>-ppn        = lt_rbkp-wmwst1.
            <fs_out>-dppppnsisa = <fs_out>-dppppn     = <fs_out>-dpp + <fs_out>-ppn.
          ENDIF.
        ENDIF.

      WHEN radio2.
        READ TABLE gt_out ASSIGNING <fs_out>
                          WITH KEY zuonr = ls_rbkp-zuonr.

        IF sy-subrc = 0.
          READ TABLE gt_zfvatin_nr WITH KEY vatpr1 = ls_rbkp-zuonr
                                   TRANSPORTING NO FIELDS.

          IF sy-subrc = 0.
            LOOP AT gt_zfvatin_nr INTO ls_zfvatin_nr
                                  WHERE vatpr1 = ls_rbkp-zuonr.
              CLEAR ls_rbkp2.
              READ TABLE gt_rbkp2 INTO ls_rbkp2
                                  WITH KEY belnr = ls_zfvatin_nr-belnr.

              <fs_out>-dpppake    = <fs_out>-dpppake + ( ls_rbkp2-rmwwr - ls_rbkp2-wmwst1 ).
              <fs_out>-ppnpake    = <fs_out>-ppnpake + ls_rbkp2-wmwst1.
            ENDLOOP.

          ELSE.
            CLEAR: lv_dpp,lv_ppn.
            lv_dpp              = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
            lv_ppn              = lt_rbkp-wmwst1.
            ADD:  lv_dpp TO <fs_out>-dpp,
                  lv_dpp TO <fs_out>-dppsisa,
                  lv_ppn TO <fs_out>-ppn,
                  lv_ppn TO <fs_out>-ppnsisa.
          ENDIF.

        ELSE.
          APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
          <fs_out>-zuonr      = ls_rbkp-zuonr.
          <fs_out>-bktxt      = ls_rbkp-bktxt.
          <fs_out>-waers      = ls_rbkp-waers.
          <fs_out>-dpp        = lt_rbkp-rmwwr - lt_rbkp-wmwst1.
          <fs_out>-ppn        = lt_rbkp-wmwst1.

          LOOP AT gt_zfvatin_nr INTO ls_zfvatin_nr
                                WHERE vatpr1 = ls_rbkp-zuonr.
            CLEAR ls_rbkp2.
            READ TABLE gt_rbkp2 INTO ls_rbkp2
                                WITH KEY belnr = ls_zfvatin_nr-belnr.

            <fs_out>-dpppake    = <fs_out>-dpppake + ( ls_rbkp2-rmwwr - ls_rbkp2-wmwst1 ).
            <fs_out>-ppnpake    = <fs_out>-ppnpake + ls_rbkp2-wmwst1.
          ENDLOOP.
        ENDIF.
    ENDCASE.
*    ENDLOOP.
  ENDLOOP.

  CASE 'X'.
    WHEN radio1.
    WHEN radio2.
      LOOP AT gt_out ASSIGNING <fs_out>.
        CLEAR ls_rbkp.
        READ TABLE gt_rbkp INTO ls_rbkp
                           WITH KEY zuonr = <fs_out>-zuonr.

        <fs_out>-bldat      = ls_rbkp-bldat.
        <fs_out>-budat      = ls_rbkp-budat.
        <fs_out>-belnr      = ls_rbkp-belnr.
        <fs_out>-xblnr      = ls_rbkp-xblnr.
        <fs_out>-dppppn     = <fs_out>-dpp     + <fs_out>-ppn.
        <fs_out>-dppppnpake = <fs_out>-dpppake + <fs_out>-ppnpake.
        <fs_out>-dppsisa    = <fs_out>-dpp     - <fs_out>-dpppake.
        <fs_out>-ppnsisa    = <fs_out>-ppn     - <fs_out>-ppnpake.
        <fs_out>-dppppnsisa = <fs_out>-dppppn  - <fs_out>-dppppnpake.
      ENDLOOP.
  ENDCASE.
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

*    CREATE OBJECT g_splitter
*      EXPORTING
*        parent  = g_customcont
*        rows    = 2
*        columns = 1.
*
*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 1
*      RECEIVING
*        container = g_contain01.
*
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

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
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
  DATA : lv_ucomm       TYPE sy-ucomm,
         lv_valid       TYPE c,
         lt_fidx        TYPE lvc_t_fidx,
         ls_fidx        TYPE sy-tabix,
         ls_filter      LIKE LINE OF gt_filter.

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
        i_parent      = g_customcont.   "g_contain01.

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
        it_outtab            = gt_out[]
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
  DATA : lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.

    CASE ls_dfies-fieldname.
*      WHEN 'BLDAT' OR 'BUDAT' OR 'BELNR' OR 'XBLNR' OR
*           'NONR' OR 'VATDT1'.
      WHEN 'BLDAT' OR 'NONR' OR 'VATDT1'.
        IF radio2 = 'X'.
          CONTINUE.
        ENDIF.
      WHEN 'MARK' OR 'ICON' OR 'STYLE' OR 'COLOR'.
        CONTINUE.
*        PERFORM f_change_dyn_fieldcat USING :
*        '' '' '' '' '' '' '' '' 'X' '' '' '' '' '' '' ''
*        CHANGING ls_fieldcat.
*      WHEN 'MENGE'.
*        PERFORM f_change_dyn_fieldcat USING :
*        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
*        CHANGING ls_fieldcat.
      WHEN 'ZUONR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No Faktur Pajak' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BKTXT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Tgl FP' '15' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VATDT1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Tgl NR' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DPP'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PPN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPN' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPPPN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP + PPn' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPPAKE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP Terpakai' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'PPNPAKE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPN Terpakai' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPPPNPAKE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP + PPN Terpakai' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPSISA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP Sisa' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'PPNSISA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPN Sisa' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPPPNSISA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP + PPN Sisa' '' '' '' '' '' '' '' '' 'X' ''
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
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl,
         lv_tabix           TYPE sy-tabix,
         ls_filter          LIKE LINE OF gt_filter.

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
                               WITH KEY INDEX = lv_tabix.
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
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  IF lt_out[] IS NOT INITIAL.

  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  fs_dyn_fcat-currency    = fu_currency.
  fs_dyn_fcat-cfieldname  = fu_cfieldname.
  fs_dyn_fcat-quantity    = fu_quantity.
  fs_dyn_fcat-qfieldname  = fu_qfieldname.
  fs_dyn_fcat-checkbox    = fu_checkbox.
  fs_dyn_fcat-coltext     = fu_coltext.
  fs_dyn_fcat-edit        = fu_edit.
  fs_dyn_fcat-outputlen   = fu_outputlen.
  fs_dyn_fcat-inttype     = fu_inttype.
  fs_dyn_fcat-no_out      = fu_no_out.
  fs_dyn_fcat-tech        = fu_tech.
  fs_dyn_fcat-key         = fu_key.
  fs_dyn_fcat-fix_column  = fu_fix.
  fs_dyn_fcat-icon        = fu_icon.
  fs_dyn_fcat-do_sum      = fu_sum.
  fs_dyn_fcat-no_sum      = fu_nosum.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_NOTA_RETUR
*&---------------------------------------------------------------------*
FORM f_get_nota_retur .
  DATA: lt_rbkp TYPE STANDARD TABLE OF rbkp.

  lt_rbkp[] = gt_rbkp[].
  SORT lt_rbkp BY bukrs zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_rbkp COMPARING bukrs zuonr.

  IF lt_rbkp[] IS NOT INITIAL.
    SELECT bukrs gsber belnr gjahr lifnr nonr vatpr1 vatdt1
      INTO CORRESPONDING FIELDS OF TABLE gt_zfvatin_nr
      FROM zfvatin_nr FOR ALL ENTRIES IN lt_rbkp
      WHERE bukrs  = p_bukrs
        AND vatpr1 = lt_rbkp-zuonr.
  ENDIF.

  IF gt_zfvatin_nr IS NOT INITIAL.
    SELECT belnr gjahr blart bldat budat xblnr bukrs lifnr waers
           kursf rmwwr beznk wmwst1 mwskz1 wmwst2 mwskz2 zterm zbd1t
           zbd1p bktxt zbd2t zbd2p zbd3t wskto xrech zuonr
      INTO CORRESPONDING FIELDS OF TABLE gt_rbkp2
      FROM rbkp FOR ALL ENTRIES IN gt_zfvatin_nr
      WHERE belnr = gt_zfvatin_nr-belnr
        AND gjahr = gt_zfvatin_nr-gjahr.
  ENDIF.
ENDFORM.                    " F_GET_NOTA_RETUR
