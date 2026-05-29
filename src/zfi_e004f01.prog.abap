*&---------------------------------------------------------------------*
*&  Include           ZFI_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_002     LIKE LINE OF gt_002,
         lv_fname   TYPE rlgrap-filename,
         lv_zbank   TYPE zfidt002-zbank,
         lv_company TYPE string,
         lv_bukrs   TYPE bkpf-bukrs.

  CLEAR gv_subrc.

  CASE 'X'.
    WHEN radio1.
    WHEN radio2.
      CLEAR : pa_fname.
    WHEN radio3.
      CLEAR : pa_fname.
    WHEN radio4.
      CLEAR : pa_fname.
    WHEN radio5.
      CLEAR : pa_fname.
  ENDCASE.

  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

  SELECT *
    FROM zfidt002
    INTO CORRESPONDING FIELDS OF TABLE gt_002
    WHERE bukrs = pa_bukrs.

  IF pa_fname IS NOT INITIAL.
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = pa_fname
      IMPORTING
        stripped_name = lv_fname
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    IF sy-subrc = 0.
      SPLIT lv_fname AT '_' INTO lv_zbank lv_company lv_fname.
      IF lv_zbank = pa_zbank.
        READ TABLE gt_002 INTO ls_002
                          WITH KEY bukrs  = pa_bukrs
                                   cabang = space
                                   zbank  = pa_zbank.
        IF sy-subrc = 0.
          gv_zrow       = ls_002-zrow.
          gv_zkcol      = ls_002-zkcol.
          gv_zacol      = ls_002-zacol.
          gv_delimiter  = ls_002-delim.
        ENDIF.
      ELSE.
        gv_subrc = 1.
      ENDIF.

      CASE lv_company.
        WHEN 'PTT'.
          lv_bukrs = '8020'.
        WHEN 'SUT'.
          lv_bukrs = '8070'.
      ENDCASE.

      IF lv_bukrs <> pa_bukrs.
        gv_subrc = 7.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'PPR' '0' '' '' '',
                                      'PZU' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'PPR' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PZU' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBE' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PST' '0' '' '' ''.
    WHEN radio7.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
      IF pa_fname IS INITIAL.
        PERFORM f_error_message USING 'PFN' ''.
      ENDIF.
    WHEN radio2.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
      IF pa_zuonr IS INITIAL.
        PERFORM f_error_message USING 'PZU' ''.
      ENDIF.
    WHEN radio3.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING 'PBA' ''.
      ENDIF.
      IF pa_zuonr IS INITIAL.
        PERFORM f_error_message USING 'PZU' ''.
      ENDIF.
    WHEN radio4.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
    WHEN radio5.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
      IF pa_zuonr IS INITIAL.
        PERFORM f_error_message USING 'PZU' ''.
      ENDIF.
    WHEN radio7.
      IF pa_zuonr IS INITIAL AND
        pa_belnr IS INITIAL.
        PERFORM f_error_message USING : 'PZU' ''.
      ELSEIF pa_belnr IS NOT INITIAL.
        IF pa_gjahr IS INITIAL.
          PERFORM f_error_message USING 'PGJ' ''.
        ENDIF.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING 'PBD' ''.
      ENDIF.
  ENDCASE.
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
      window_title      = 'Select file'
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
  DATA : ls_003   TYPE zfidt003.

  CASE 'X'.
    WHEN radio1.
      AUTHORITY-CHECK OBJECT 'ZTRS_VOUCH'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        PERFORM f_get_upload_data.
        SELECT *
          FROM zfidt003
          INTO CORRESPONDING FIELDS OF TABLE gt_x003
          WHERE bukrs = pa_bukrs
            AND budat = pa_budat
            AND zbank = pa_zbank.
      ELSE.
        gv_subrc = 6.
      ENDIF.

    WHEN radio2.
      AUTHORITY-CHECK OBJECT 'ZTRS_VOUCH'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM zfidt003
          INTO CORRESPONDING FIELDS OF ls_003
          WHERE bukrs = pa_bukrs
            AND zbrvn = pa_zuonr.
        IF sy-subrc <> 0.
          SELECT *
            FROM zfidt003
            INTO CORRESPONDING FIELDS OF TABLE gt_x003
            WHERE bukrs = pa_bukrs
              AND budat = pa_budat
              AND zbank = pa_zbank
              AND zbrvn = space.
        ELSE.
          gv_subrc = 5.
        ENDIF.
      ELSE.
        gv_subrc = 6.
      ENDIF.

    WHEN radio3.
      AUTHORITY-CHECK OBJECT 'ZTRS_VOUCH'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        SELECT *
          FROM zfidt003
          INTO CORRESPONDING FIELDS OF TABLE gt_x003
          WHERE bukrs = pa_bukrs
            AND zbank = pa_zbank
            AND zbrvn = pa_zuonr.
      ELSE.
        gv_subrc = 6.
      ENDIF.

    WHEN radio4.
      AUTHORITY-CHECK OBJECT 'ZTRS_VOUCH'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        SELECT *
          FROM zfidt003
          INTO CORRESPONDING FIELDS OF TABLE gt_x003
          WHERE bukrs = pa_bukrs
            AND budat = pa_budat
            AND zbank = pa_zbank.
      ELSE.
        gv_subrc = 6.
      ENDIF.

    WHEN radio5.
      AUTHORITY-CHECK OBJECT 'ZTRS_FIDOC'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        SELECT *
          FROM zfidt003
          INTO CORRESPONDING FIELDS OF TABLE gt_x003
          WHERE bukrs = pa_bukrs
            AND budat = pa_budat
            AND zbank = pa_zbank
            AND zbrvn = pa_zuonr
            AND belnr = space.
      ELSE.
        gv_subrc = 6.
      ENDIF.

    WHEN radio6.
      SELECT *
        FROM zfidt003
        INTO CORRESPONDING FIELDS OF TABLE gt_x003
        WHERE bukrs = pa_bukrs
          AND zbank IN so_zbank
          AND zbrvn IN so_zuonr
          AND budat IN so_budat.

    WHEN radio7.
      AUTHORITY-CHECK OBJECT 'ZTRS_FIDOC'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc = 0.
        IF pa_zuonr IS NOT INITIAL.
          SELECT *
            FROM zfidt003
            INTO CORRESPONDING FIELDS OF TABLE gt_x003
            WHERE bukrs = pa_bukrs
              AND zbrvn = pa_zuonr.
        ELSE.
          SELECT *
            FROM zfidt003
            INTO CORRESPONDING FIELDS OF TABLE gt_x003
            WHERE bukrs = pa_bukrs
              AND belnr = pa_belnr
              AND gjahr = pa_gjahr.
        ENDIF.
      ELSE.
        gv_subrc = 6.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out LIKE LINE OF gt_out,
         ls_002 LIKE LINE OF gt_002.

  DATA : lv_keterangan TYPE c LENGTH 30,
         lv_amount     TYPE c LENGTH 30,
         lv_dmbtr      TYPE c LENGTH 30,
         lv_sign       TYPE c LENGTH 30,
         lv_cabang     TYPE c LENGTH 30,
         lv_fdpos      TYPE sy-fdpos,
         lv_amntp      TYPE p DECIMALS 0,
         lv_znorek     TYPE c LENGTH 50.

  FIELD-SYMBOLS <fs>   TYPE any.

  LOOP AT <fs_table> ASSIGNING <fs_wa>.
    ASSIGN COMPONENT 'C01' OF STRUCTURE <fs_wa> TO <fs>.
    CASE pa_zbank.
      WHEN 'BCA'.
        CONCATENATE <fs>+6(4) <fs>+3(2) <fs>(2) INTO ls_out-budat.
      WHEN 'BNI'.
        CONCATENATE sy-datum(2) <fs>+6(2) <fs>+3(2) <fs>(2) INTO ls_out-budat.
      WHEN 'CIMB'.
        CONCATENATE sy-datum(2) <fs>+6(2) <fs>(2) <fs>+3(2) INTO ls_out-budat.
    ENDCASE.
    ls_out-bukrs = pa_bukrs.
    ls_out-zbank = pa_zbank.
    CONCATENATE 'C' gv_zkcol+1(2) INTO lv_keterangan.
    CONCATENATE 'C' gv_zacol+1(2) INTO lv_amount.

    CASE pa_zbank.
      WHEN 'BCA'.
        ASSIGN COMPONENT lv_keterangan OF STRUCTURE <fs_wa> TO <fs>.
        ls_out-keterangan = <fs>.
        SEARCH ls_out-keterangan FOR 'ATS' AND MARK.
        IF sy-subrc = 0.
          ls_out-jenis  = 'ATS'.
          LOOP AT gt_002 INTO ls_002 WHERE cabang IS NOT INITIAL
                                       AND zbank = pa_zbank.
            SEARCH ls_out-keterangan FOR ls_002-znorek AND MARK.
            IF sy-subrc = 0.
              ls_out-mark   = 'X'.
              ls_out-cabang = ls_002-cabang.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF ls_out-mark IS INITIAL.
            ls_out-icon = icon_led_red.
          ENDIF.
        ELSE.
          PERFORM f_search_rem USING ls_out-keterangan
                               CHANGING ls_out-mark ls_out-icon
                                        ls_out-cabang ls_out-jenis.
        ENDIF.

      WHEN 'BNI'.
        ASSIGN COMPONENT lv_keterangan OF STRUCTURE <fs_wa> TO <fs>.
        ls_out-keterangan = <fs>.
        LOOP AT gt_002 INTO ls_002 WHERE cabang IS NOT INITIAL
                                     AND zbank = pa_zbank.
          lv_znorek = ls_002-znorek.
          SHIFT lv_znorek LEFT DELETING LEADING '0'.
          SEARCH ls_out-keterangan FOR lv_znorek AND MARK.
          IF sy-subrc = 0.
            ls_out-mark   = 'X'.
            ls_out-cabang = ls_002-cabang.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF ls_out-mark IS INITIAL.
          ls_out-icon = icon_led_red.
        ENDIF.
*        PERFORM f_search_rem USING ls_out-keterangan
*                             CHANGING ls_out-mark ls_out-icon
*                                      ls_out-cabang ls_out-jenis.

      WHEN 'CIMB'.
        ASSIGN COMPONENT lv_keterangan OF STRUCTURE <fs_wa> TO <fs>.
        ls_out-keterangan = <fs>.
        PERFORM f_search_rem USING ls_out-keterangan
                             CHANGING ls_out-mark ls_out-icon
                                      ls_out-cabang ls_out-jenis.
    ENDCASE.

    ASSIGN COMPONENT lv_amount OF STRUCTURE <fs_wa> TO <fs>.
    SPLIT <fs> AT space INTO lv_dmbtr lv_sign.
    TRANSLATE lv_dmbtr USING ', '.
    CONDENSE lv_dmbtr NO-GAPS.
    lv_amntp = lv_dmbtr.
    ls_out-dmbtr = lv_amntp / 100.
    ls_out-waers = 'IDR'.
    IF ls_out-dmbtr = 0.
      CLEAR ls_out.
      CONTINUE.
    ENDIF.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  ASSIGN gt_out TO <fs_out>.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF <fs_out>[] IS NOT INITIAL.
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
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      APPEND '&REV' TO fcode.
    WHEN radio5.
      APPEND '&REV' TO fcode.
    WHEN radio6.
      APPEND '&POS' TO fcode.
      APPEND '&REV' TO fcode.
    WHEN radio7.
      APPEND '&POS' TO fcode.
  ENDCASE.

  CASE sy-dynnr.
    WHEN '0101'.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.
    WHEN '0102'.
      SET PF-STATUS 'STATUS01' EXCLUDING fcode.
      SET TITLEBAR 'TITLE01'.
  ENDCASE.
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
      ENDIF.

    WHEN '&REV'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_reverse_data USING 'FI'.
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
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN 'CONT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_modify_data.
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
  IF radio5 IS NOT INITIAL OR
    radio6 IS NOT INITIAL OR
    radio7 IS NOT INITIAL.
    CREATE DATA lt_dyn_table LIKE LINE OF gt_report.
  ELSE.
    CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  ENDIF.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ICON'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Sts' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'KETERANGAN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'JENIS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Jenis' '' '' '' '' '' '' '' '' '' ''
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
  DATA : lt_out  TYPE STANDARD TABLE OF ty_out.

  DATA : lv_subrc TYPE sy-subrc.

  CASE 'X'.
    WHEN radio1.
      lt_out[] = gt_out[].
      DELETE lt_out WHERE mark IS INITIAL.
      IF lt_out[] IS NOT INITIAL.
        IF gt_x003[] IS NOT INITIAL.
          MESSAGE s000(zab) WITH 'Data sudah ada' DISPLAY LIKE 'E'.
        ELSE.
          PERFORM f_save_table TABLES lt_out
                               CHANGING lv_subrc.
          IF lv_subrc = 0.
            MESSAGE s000(zab) WITH 'Data already saved'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN radio5.
      PERFORM f_prepare_post.
      PERFORM f_post_data.
  ENDCASE.
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
*&      Form  F_GET_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_get_upload_data .
  DATA : filename  TYPE string,
         data_tab  TYPE STANDARD TABLE OF string,
         data_line LIKE LINE OF data_tab,
         lt_data   TYPE STANDARD TABLE OF ty_data,
         ls_data   LIKE LINE OF lt_data,
         itab      TYPE STANDARD TABLE OF string.

  DATA : lv_lines   TYPE c LENGTH 10,
         lv_string  TYPE string,
         lv_xstring TYPE xstring,
         lv_count   TYPE n LENGTH 2,
         lv_field   TYPE c LENGTH 30,
         lv_subrc   TYPE sy-subrc,
         lv_budat   TYPE sy-datum,
         lv_flag    TYPE c LENGTH 1.

  FIELD-SYMBOLS <fs>  TYPE any.

  filename           = pa_fname.
  ASSIGN gt_data  TO <fs_table>.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename            = filename
      filetype            = 'ASC'
      has_field_separator = abap_true
    CHANGING
      data_tab            = data_tab.
  IF sy-subrc = 0.
    LOOP AT data_tab INTO data_line FROM gv_zrow.
      CLEAR lv_subrc.
      CASE pa_zbank.
        WHEN 'BCA'.
          SPLIT data_line AT gv_delimiter INTO TABLE itab.
          DELETE itab WHERE table_line IS INITIAL.
          DELETE itab WHERE table_line = c_separator.
        WHEN 'BNI'.
          SPLIT data_line AT gv_delimiter INTO TABLE itab.
          DELETE itab WHERE table_line IS INITIAL.
          DELETE itab WHERE table_line = c_separator.
        WHEN 'CIMB'.
          SPLIT data_line AT c_separator INTO TABLE itab.
      ENDCASE.
      LOOP AT itab INTO DATA(ls_itab).
        lv_string = ls_itab.
        CLEAR lv_xstring.
        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = lv_string
          IMPORTING
            buffer = lv_xstring.
        IF lv_xstring = '20'.
          DELETE itab.
        ELSE.
          IF sy-tabix = 1.
            REPLACE ALL OCCURRENCES OF c_separator IN ls_itab WITH space.
            IF lv_flag IS INITIAL.
              lv_flag = 'X'.
              CASE pa_zbank.
                WHEN 'BCA'.
                  CONCATENATE ls_itab+6(4) ls_itab+3(2) ls_itab(2) INTO lv_budat.
                WHEN 'BNI'.
                  CONCATENATE sy-datum(2) ls_itab+6(2) ls_itab+3(2) ls_itab(2) INTO lv_budat.
                WHEN 'CIMB'.
                  CONCATENATE sy-datum(2) ls_itab+6(2) ls_itab(2) ls_itab+3(2) INTO lv_budat.
              ENDCASE.
              IF lv_budat <> pa_budat.
                lv_subrc = 1.
                EXIT.
              ENDIF.
            ENDIF.
            MODIFY itab FROM ls_itab.
          ELSE.
            SEARCH ls_itab FOR 'DB' AND MARK.
            IF sy-subrc = 0.
              lv_subrc = 2.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_subrc = 0.
        CLEAR lv_count.
        DESCRIBE TABLE itab LINES lv_lines.
        IF lv_lines > 2.
          APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_wa>.
          LOOP AT itab INTO ls_itab.
            ADD 1 TO lv_count.
            CONCATENATE 'C' lv_count INTO lv_field.
            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = ls_itab.
          ENDLOOP.
        ENDIF.
      ELSEIF lv_subrc = 1.
        gv_subrc = 2.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  CLEAR : gs_out, gv_keterangan, gv_dmbtr, gv_waers.
  READ TABLE gt_out INTO gs_out INDEX fu_row.
  IF sy-subrc = 0.
    gv_keterangan = gs_out-keterangan.
    gv_dmbtr      = gs_out-dmbtr.
    gv_waers      = gs_out-waers.
    gv_row        = fu_row.
    CALL SCREEN 102 STARTING AT 10 10.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CABANG
*&---------------------------------------------------------------------*
FORM f_value_cabang .
  TYPES : BEGIN OF ty_cabang,
            cabang TYPE zfidt002-cabang,
            zcabnm TYPE zfidt002-zcabnm,
          END OF ty_cabang.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         lt_cabang  TYPE STANDARD TABLE OF ty_cabang INITIAL SIZE 0,
         ls_cabang  LIKE LINE OF lt_cabang,
         ls_002     LIKE LINE OF gt_002.

  DATA : lv_subrc   TYPE sy-subrc.

  LOOP AT gt_002 INTO ls_002 WHERE cabang <> space.
    ls_cabang-cabang = ls_002-cabang.
    ls_cabang-zcabnm = ls_002-zcabnm.
    APPEND ls_cabang TO lt_cabang.
    CLEAR ls_cabang.
  ENDLOOP.

  SORT lt_cabang BY cabang.
  DELETE ADJACENT DUPLICATES FROM lt_cabang COMPARING cabang.
  ASSIGN lt_cabang[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'CABANG' 'GV_CABANG'
                          CHANGING lv_subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  DATA : ls_out   LIKE LINE OF gt_out.

  gs_out-mark   = 'X'.
  gs_out-icon   = space.
  gs_out-cabang = gv_cabang.
  gs_out-jenis  = 'MANUAL'.
  MODIFY gt_out FROM gs_out INDEX gv_row.
  CLEAR : gs_out, gv_cabang.

  PERFORM f_alv_refresh USING 'X'.
  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SEARCH_REM
*&---------------------------------------------------------------------*
FORM f_search_rem  USING    fu_keterangan
                   CHANGING fc_mark fc_icon fc_cabang fc_jenis.
  DATA : ls_002   LIKE LINE OF gt_002.

  DATA : lv_fdpos  TYPE sy-fdpos,
         lv_cabang TYPE zfidt002-cabang.

  SEARCH fu_keterangan FOR 'REM' AND MARK.
  IF sy-subrc = 0.
    fc_jenis  = 'REM'.
    CLEAR : ls_002, lv_fdpos.
    LOOP AT gt_002 INTO ls_002 WHERE cabang IS NOT INITIAL.
      CONCATENATE 'REM' ls_002-cabang INTO lv_cabang
      SEPARATED BY space.
      SEARCH fu_keterangan FOR lv_cabang AND MARK.
      IF sy-subrc = 0.
        fc_mark   = 'X'.
        fc_cabang = ls_002-cabang.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF fc_mark IS INITIAL.
      fc_icon = icon_led_red.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE
*&---------------------------------------------------------------------*
FORM f_save_table  TABLES   ft_out LIKE gt_out
                   CHANGING fc_subrc.
  DATA : lt_003 TYPE STANDARD TABLE OF zfidt003,
         ls_003 LIKE LINE OF lt_003,
         ls_out LIKE LINE OF gt_out.

  DATA : lv_buzei TYPE bseg-buzei,
         lv_shkzg TYPE bseg-shkzg.

  lv_shkzg = 'H'.

  SORT ft_out BY bukrs budat zbank cabang.
  LOOP AT ft_out INTO ls_out.
    ADD 1 TO lv_buzei.
    ls_003-bukrs    = ls_out-bukrs.
    ls_003-budat    = ls_out-budat.
    ls_003-zbank    = ls_out-zbank.
    ls_003-cabang   = ls_out-cabang.
    ls_003-buzei    = lv_buzei.
    ls_003-jenis    = ls_out-jenis.
    ls_003-shkzg    = lv_shkzg.
    ls_003-dmbtr    = ls_out-dmbtr.
    ls_003-waers    = ls_out-waers.
    APPEND ls_003 TO lt_003.
    CLEAR ls_003.
  ENDLOOP.

  IF lt_003[] IS NOT INITIAL.
    TRY .
        INSERT zfidt003 FROM TABLE lt_003.
      CATCH cx_sy_open_sql_db.
        fc_subrc = 4.
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT
*&---------------------------------------------------------------------*
FORM f_prepare_print USING fu_bukrs fu_zbrvn fu_budat fu_zbank.
  DATA : lt_skat   TYPE STANDARD TABLE OF skat,
         ls_skat   LIKE LINE OF lt_skat,
         ls_002    LIKE LINE OF gt_002,
         ls_x003   LIKE LINE OF gt_x003,
         ls_detail LIKE LINE OF gt_detail.

  DATA : lv_date(10),
         lv_zbrvn        TYPE zfidt003-zbrvn,
         lv_dmbtr        TYPE bseg-dmbtr,
         in_words        TYPE spell,
         lv_langu        TYPE sy-langu VALUE 'id',
         lv_waers        TYPE bkpf-waers VALUE 'IDR',
         lv_buzei        TYPE bseg-buzei,
         lv_company(100).

  CLEAR : gs_header, gt_detail[], gt_window3[].

  IF fu_zbrvn IS INITIAL.
    lv_zbrvn         = pa_zuonr.
  ELSE.
    lv_zbrvn         = fu_zbrvn.
  ENDIF.
  gs_header-title  = 'RECEIPT VOUCHER'.
  gs_header-bukrs  = fu_bukrs.
  SELECT SINGLE butxt
    FROM t001
    INTO gs_header-butxt
    WHERE bukrs = gs_header-bukrs.
  CONCATENATE pa_bukrs '-' gs_header-butxt INTO lv_company
  SEPARATED BY space.
  TRANSLATE lv_company TO UPPER CASE.

  READ TABLE gt_002 INTO ls_002
                    WITH KEY bukrs  = fu_bukrs
                             zbank  = fu_zbank
                             cabang = space.

  WRITE fu_budat TO lv_date DD/MM/YYYY.
  PERFORM f_header_window3 USING : 'No.Voucher' ':' lv_zbrvn ''
                                   'Receipt Date' ':' lv_date.
  PERFORM f_header_window3 USING : 'Receipt From' ':' lv_company '' 'Bank Name' ':' fu_zbank.
  PERFORM f_header_window3 USING : 'No.SAP' ':' '' '' 'Bank Account No.' ':' ls_002-znorek.
  PERFORM f_header_window3 USING : 'Departemen' ':' 'Treasury' '' '' '' ''.

  IF gt_002[] IS NOT INITIAL.
    SELECT *
      FROM skat
      INTO CORRESPONDING FIELDS OF TABLE lt_skat
      FOR ALL ENTRIES IN gt_002
      WHERE spras  = sy-langu
        AND saknr  = gt_002-hkont.
  ENDIF.

  READ TABLE lt_skat INTO ls_skat
                     WITH KEY saknr = ls_002-hkont.
  IF sy-subrc = 0.
    gs_header-txt20 = ls_skat-txt20.
  ENDIF.

  SORT gt_x003 BY zbank cabang.
  LOOP AT gt_x003 INTO ls_x003 WHERE bukrs = fu_bukrs
                                 AND zbank = fu_zbank
                                 AND zbrvn = fu_zbrvn.
    ADD ls_x003-dmbtr TO lv_dmbtr.
*****    CLEAR ls_002.
*****    READ TABLE gt_002 INTO ls_002
*****                      WITH KEY bukrs  = ls_x003-bukrs
*****                               zbank  = ls_x003-zbank
*****                               cabang = ls_x003-cabang.
*****    IF sy-subrc = 0.
*****      ls_detail-hkont = ls_002-hkont.
*****      CLEAR ls_skat.
*****      READ TABLE lt_skat INTO ls_skat
*****                         WITH KEY saknr = ls_002-hkont.
*****      IF sy-subrc = 0.
*****        ls_detail-description = ls_skat-txt20.
*****      ENDIF.
*****    ENDIF.
    ls_detail-description = 'C/A  Remise dari Cabang PTT'.
    ls_detail-wrbtr = ls_x003-dmbtr.
    ls_detail-waers = ls_x003-waers.
    COLLECT ls_detail INTO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  LOOP AT gt_detail INTO ls_detail.
    ADD 1 TO lv_buzei.
    ls_detail-buzei = lv_buzei.
    SHIFT ls_detail-buzei LEFT DELETING LEADING '0'.
    WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_detail-waers.
    MODIFY gt_detail FROM ls_detail
                     TRANSPORTING buzei wrbtrt.
    CLEAR ls_detail.
  ENDLOOP.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_dmbtr
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
  TRANSLATE gs_header-terbilang TO UPPER CASE.

  WRITE lv_dmbtr TO gs_header-totalt CURRENCY 'IDR'.
  gs_header-hkont  = ls_002-hkont.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_fname           TYPE ssfscreen-fname,
         lv_funcname        TYPE rs38l_fnam,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop.

  lv_fname = 'ZFTRS_F001'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_fname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc = 0.
    IF pa_prev IS INITIAL.
      lwa_output_option-tdnoprev  = 'X'.
      lwa_output_option-tdnewid   = 'X'.
    ELSE.
      lwa_output_option-tdnoprint = 'X'.
    ENDIF.

    CALL FUNCTION lv_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gs_header          = gs_header
      TABLES
        gt_window3         = gt_window3
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc = 0.
      IF pa_prev IS INITIAL.
        TRY .
            UPDATE zfidt003 SET zbrvn = pa_zuonr
                            WHERE bukrs = pa_bukrs
                              AND budat = pa_budat
                              AND zbank = pa_zbank.
          CATCH cx_sy_open_sql_db.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_WINDOW3
*&---------------------------------------------------------------------*
FORM f_header_window3  USING    fu_cell14 fu_cell15 fu_cell16 fu_cell17
                                fu_cell18 fu_cell19 fu_cell20.
  DATA : ls_window3   LIKE LINE OF gt_window3.

  ls_window3-cell14 = fu_cell14.
  ls_window3-cell15 = fu_cell15.
  ls_window3-cell16 = fu_cell16.
  ls_window3-cell17 = fu_cell17.
  ls_window3-cell18 = fu_cell18.
  ls_window3-cell19 = fu_cell19.
  ls_window3-cell20 = fu_cell20.
  APPEND ls_window3 TO gt_window3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POST
*&---------------------------------------------------------------------*
FORM f_prepare_post .
  DATA : lt_003  TYPE STANDARD TABLE OF zfidt003,
         ls_003  LIKE LINE OF lt_003,
         ls_x003 LIKE LINE OF gt_x003,
         ls_002  LIKE LINE OF gt_002,
         ls_bkpf TYPE bkpf.

  DATA : lv_buzei TYPE bseg-buzei,
         lv_count TYPE i,
         lv_newbs TYPE rf05a-newbs,
         lv_sgtxt TYPE bseg-sgtxt,
         lv_gsber TYPE bseg-gsber,
         lv_wrbtr TYPE bseg-wrbtr,
         lv_total TYPE bseg-wrbtr,
         lv_hkont TYPE bseg-hkont.

  ls_bkpf-blart = 'SA'.
  ls_bkpf-xblnr = ''.
  WRITE pa_budat TO ls_bkpf-bktxt DD/MM/YYYY.
  CONCATENATE 'REMISE TGL.' ls_bkpf-bktxt INTO ls_bkpf-bktxt
  SEPARATED BY space.

  CASE pa_bukrs.
    WHEN '8020'.
      lv_gsber = '0200'.
    WHEN '8070'.
      lv_gsber = '0700'.
  ENDCASE.

  CONCATENATE ls_bkpf-bktxt '-' pa_zbank INTO lv_sgtxt
  SEPARATED BY space.

*  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = pa_bukrs.
  documentheader-doc_date   = pa_budat.
  documentheader-pstng_date = pa_budat.
  documentheader-doc_type   = ls_bkpf-blart.
  documentheader-ref_doc_no = ls_bkpf-xblnr.
  documentheader-header_txt = ls_bkpf-bktxt.

  lt_003[] = gt_x003[].
  SORT lt_003 BY cabang.
  DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING cabang.
  LOOP AT lt_003 INTO ls_003.
    CLEAR ls_002.
    READ TABLE gt_002 INTO ls_002
                      WITH KEY bukrs  = ls_003-bukrs
                               zbank  = ls_003-zbank
                               cabang = ls_003-cabang.
    IF sy-subrc = 0.
      lv_hkont = ls_002-hkont.
    ENDIF.

    CLEAR : ls_x003, lv_wrbtr.
    LOOP AT gt_x003 INTO ls_x003 WHERE bukrs  = ls_003-bukrs
                                   AND zbank  = ls_003-zbank
                                   AND cabang = ls_003-cabang.
      ADD ls_x003-dmbtr TO lv_wrbtr.
      ADD ls_x003-dmbtr TO lv_total.
    ENDLOOP.

    ADD 1 TO lv_count.
    lv_buzei  = lv_count.
    lv_newbs  = '50'.
    PERFORM f_line_post USING lv_newbs lv_buzei lv_hkont ls_003-zbrvn
                              lv_gsber lv_sgtxt lv_wrbtr ls_003-cabang.
  ENDLOOP.

  CLEAR ls_002.
  READ TABLE gt_002 INTO ls_002
                    WITH KEY bukrs  = pa_bukrs
                             zbank  = pa_zbank
                             cabang = space.
  IF sy-subrc = 0.
    lv_hkont = ls_002-hkont.
  ENDIF.
  ADD 1 TO lv_count.
  lv_buzei  = lv_count.
  lv_newbs  = '40'.
  PERFORM f_line_post USING lv_newbs lv_buzei lv_hkont ls_003-zbrvn
                            lv_gsber lv_sgtxt lv_total ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data .
  DATA : ls_return    LIKE LINE OF return.

  DATA : obj_type TYPE bapiache02-obj_type,
         lv_belnr TYPE bkpf-belnr,
         lv_gjahr TYPE bkpf-gjahr.

  obj_type = 'BKPF'.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = documentheader
    IMPORTING
      obj_type       = obj_type
    TABLES
      accountgl      = accountgl
      currencyamount = currencyamount
      return         = return
      extension1     = extension1.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'S'.
      lv_belnr    = ls_return-message_v2(10).
      lv_gjahr    = ls_return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

  IF lv_belnr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    TRY .
        UPDATE zfidt003 SET belnr = lv_belnr
                            gjahr = lv_gjahr
                        WHERE bukrs = pa_bukrs
                          AND budat = pa_budat
                          AND zbank = pa_zbank.
      CATCH cx_sy_open_sql_db.
    ENDTRY.

    MESSAGE s312(f5) WITH lv_belnr pa_bukrs.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = return.

    MESSAGE s000(zab) WITH 'Posting error' DISPLAY LIKE 'E'.
  ENDIF.

  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_DATA
*&---------------------------------------------------------------------*
FORM f_reverse_data USING fu_process.
  DATA : ls_x003   LIKE LINE OF gt_x003,
         ls_report LIKE LINE OF gt_report.

  DATA : answer,
         lv_text(100),
         lv_subrc     TYPE sy-subrc,
         lv_stgrd     TYPE bkpf-stgrd,
         lv_budat     TYPE bkpf-budat,
         lv_belnr     TYPE bkpf-belnr,
         lv_gjahr     TYPE bkpf-gjahr.

  IF gt_x003[] IS NOT INITIAL.
    CASE fu_process.
      WHEN 'BRV'.
        READ TABLE gt_x003 INTO ls_x003 INDEX 1.
        IF sy-subrc = 0.
          IF ls_x003-zbrvn IS INITIAL AND ls_x003-belnr IS INITIAL.
            lv_text = 'Data sudah ada, apakah mau direverse ?'.
          ELSEIF ls_x003-zbrvn IS NOT INITIAL AND ls_x003-belnr IS INITIAL.
            lv_text = 'Data sudah ada BRV, apakah mau direverse ?'.
          ELSE.
            lv_text = 'Data sudah posting'.
            lv_subrc = 4.
          ENDIF.

          IF lv_subrc = 0.
            CALL FUNCTION 'POPUP_TO_CONFIRM'
              EXPORTING
                titlebar              = 'Confirm'
                text_question         = lv_text
                display_cancel_button = ''
              IMPORTING
                answer                = answer
              EXCEPTIONS
                text_not_found        = 1
                OTHERS                = 2.
            IF answer = '1'.
              DELETE FROM zfidt003 WHERE bukrs = pa_bukrs
                                     AND budat = pa_budat
                                     AND zbank = pa_zbank.
              COMMIT WORK.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH lv_text DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      WHEN 'FI'.
        lv_stgrd  = '01'.
        IF pa_belnr IS INITIAL OR
          pa_gjahr IS INITIAL.
          READ TABLE gt_report INTO ls_report INDEX 1.
          IF sy-subrc = 0.
            lv_belnr = ls_report-belnr.
            lv_gjahr = ls_report-gjahr.
          ENDIF.
        ELSE.
          lv_belnr  = pa_belnr.
          lv_gjahr  = pa_gjahr.
        ENDIF.

        CALL FUNCTION 'CALL_FB08'
          EXPORTING
            i_bukrs      = pa_bukrs
            i_belnr      = lv_belnr
            i_gjahr      = lv_gjahr
            i_stgrd      = lv_stgrd
            i_budat      = pa_budat
          IMPORTING
            e_budat      = lv_budat
          EXCEPTIONS
            not_possible = 1
            OTHERS       = 2.
        IF sy-subrc = 0.
          ls_x003-belnr = space.
          ls_x003-gjahr = space.
          MODIFY gt_x003 FROM ls_x003
                         TRANSPORTING belnr gjahr
                         WHERE bukrs = pa_bukrs.
          TRY .
              MODIFY zfidt003 FROM TABLE gt_x003.
            CATCH cx_sy_open_sql_db.
          ENDTRY.

          LEAVE TO SCREEN 0.
        ENDIF.
    ENDCASE.
  ELSE.
    MESSAGE s000(zab) WITH 'Data tidak ada' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT_FORM
*&---------------------------------------------------------------------*
FORM f_reprint_form .
  DATA : lt_003  TYPE STANDARD TABLE OF zfidt003,
         ls_003  LIKE LINE OF lt_003,
         ls_x003 LIKE LINE OF gt_x003.

  DATA : lv_fname           TYPE ssfscreen-fname,
         lv_funcname        TYPE rs38l_fnam,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop.

  lv_fname = 'ZFTRS_F001'.

  lt_003[] = gt_x003[].
  SORT lt_003 BY bukrs zbank zbrvn.
  DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING bukrs zbank zbrvn.
  IF lt_003[] IS NOT INITIAL.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lv_fname
      IMPORTING
        fm_name            = lv_funcname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
  ENDIF.

  IF lv_funcname IS NOT INITIAL.
    LOOP AT lt_003 INTO ls_003.
      AT FIRST.
        lwa_control_option-no_close = 'X'.
      ENDAT.

      AT LAST.
        lwa_control_option-no_close = space.
      ENDAT.

      PERFORM f_prepare_print USING ls_003-bukrs ls_003-zbrvn ls_003-budat
                                    ls_003-zbank.

      CALL FUNCTION lv_funcname
        EXPORTING
          output_options     = lwa_output_option
          control_parameters = lwa_control_option
          user_settings      = 'X'
          gs_header          = gs_header
        TABLES
          gt_window3         = gt_window3
          gt_detail          = gt_detail
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      lwa_control_option-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LINE_POST
*&---------------------------------------------------------------------*
FORM f_line_post  USING    fu_newbs fu_buzei fu_hkont fu_zbrvn fu_gsber
                           fu_sgtxt fu_wrbtr fu_cabang.
  DATA : ls_accountgl LIKE LINE OF accountgl,
         ls_extension LIKE LINE OF extension1,
         ls_currency  LIKE LINE OF currencyamount.

  DATA : lv_wrbtr   TYPE bseg-wrbtr.

  ls_accountgl-itemno_acc      = fu_buzei.
  ls_accountgl-comp_code       = pa_bukrs.
  ls_accountgl-bus_area        = fu_gsber.
  ls_accountgl-gl_account      = fu_hkont.
  ls_accountgl-alloc_nmbr      = fu_zbrvn.
  CONCATENATE fu_sgtxt fu_cabang INTO ls_accountgl-item_text
  SEPARATED BY space.
  ls_accountgl-trade_id        = 'OTHERS'.
  APPEND ls_accountgl TO accountgl.

  ls_extension(3)              = fu_buzei.
  ls_extension+3(2)            = fu_newbs.
  APPEND ls_extension TO extension1.

  ls_currency-itemno_acc    = fu_buzei.
  ls_currency-curr_type     = '00'.
  ls_currency-currency      = 'IDR'.
  lv_wrbtr  = abs( fu_wrbtr ).
  PERFORM f_value_conversion USING fu_wrbtr fu_newbs
                             CHANGING ls_currency-amt_doccur.
  APPEND ls_currency TO currencyamount.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_value_conversion  USING    fu_value fu_bschl
                         CHANGING fc_value.
  DATA : ls_tbsl      LIKE LINE OF gt_tbsl,
         lv_value(15).

  lv_value = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl
                     WITH KEY bschl = fu_bschl.
  IF ls_tbsl-shkzg = 'H'.
    fc_value = fc_value * -1.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_REPORT
*&---------------------------------------------------------------------*
FORM f_process_report .
  DATA : ls_002    LIKE LINE OF gt_002,
         lt_003    TYPE STANDARD TABLE OF zfidt003,
         ls_003    LIKE LINE OF lt_003,
         ls_x003   LIKE LINE OF gt_x003,
         ls_report LIKE LINE OF gt_report.

  DATA : lv_dmbtr TYPE zfidt003-dmbtr,
         lv_total TYPE zfidt003-dmbtr.

  lt_003[] = gt_x003[].
  SORT lt_003 BY bukrs budat zbank.
  SORT gt_x003 BY bukrs budat zbank.
  DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING bukrs budat zbank.
  LOOP AT lt_003 INTO ls_003.
    CLEAR : lv_dmbtr, lv_total.
    LOOP AT gt_x003 INTO ls_x003 WHERE bukrs = ls_003-bukrs
                                   AND budat = ls_003-budat
                                   AND zbank = ls_003-zbank.
      MOVE-CORRESPONDING ls_x003 TO ls_report.
      IF ls_x003-shkzg = 'H'.
        lv_dmbtr = ls_x003-dmbtr * -1.
      ELSE.
        lv_dmbtr = ls_x003-dmbtr.
      ENDIF.
      ls_report-dmbtr = lv_dmbtr.
      READ TABLE gt_002 INTO ls_002
                        WITH KEY bukrs  = ls_x003-bukrs
                                 zbank  = ls_x003-zbank
                                 cabang = ls_x003-cabang.
      IF sy-subrc = 0.
        ls_report-hkont = ls_002-hkont.
      ENDIF.
      COLLECT ls_report INTO gt_report.
      CLEAR ls_report.
      ADD lv_dmbtr TO lv_total.
    ENDLOOP.

    ls_report-bukrs = ls_003-bukrs.
    ls_report-budat = ls_003-budat.
    ls_report-zbank = ls_003-zbank.
    ls_report-dmbtr = lv_total * -1.
    ls_report-waers = ls_003-waers.
    READ TABLE gt_002 INTO ls_002
                      WITH KEY bukrs  = ls_003-bukrs
                               zbank  = ls_003-zbank
                               cabang = space.
    IF sy-subrc = 0.
      ls_report-hkont = ls_002-hkont.
    ENDIF.
    ls_report-zbrvn = ls_003-zbrvn.
    ls_report-belnr = ls_003-belnr.
    ls_report-gjahr = ls_003-gjahr.
    APPEND ls_report TO gt_report.
    CLEAR ls_report.
  ENDLOOP.

  SORT gt_report BY bukrs zbank budat cabang.
  ASSIGN gt_report TO <fs_out>.
ENDFORM.
