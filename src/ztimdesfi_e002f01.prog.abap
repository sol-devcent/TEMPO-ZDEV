*&---------------------------------------------------------------------*
*&  Include           ZTIMDESFI_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CLEAR gv_post.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
*  IF sy-uname <> 'TDS_DEV01'.
*    PERFORM f_modify_screen USING : 'RA3' '0' '' '' ''.
*  ENDIF.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'SWE' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SZF' '0' '' '' '',
                                      'PST' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SVL' '0' '' '' '',
                                      'SZF' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  DATA : lv_subrc   TYPE sy-subrc.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.

  IF pa_vkbur IS INITIAL.
    PERFORM f_error_message USING 'PVK' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF so_vbevl[] IS INITIAL AND
        so_zfbdt[] IS INITIAL.
        PERFORM f_error_message USING 'SZF' ''.
      ENDIF.
    WHEN radio2.
      IF so_budat[] IS INITIAL.
        PERFORM f_error_message USING 'SBD' ''.
      ENDIF.
    WHEN radio3.
      IF pa_stgrd IS INITIAL.
        PERFORM f_error_message USING 'PST' ''.
      ENDIF.
      IF pa_webno IS INITIAL.
        PERFORM f_error_message USING 'PWE' ''.
      ENDIF.

      PERFORM f_reverse_authorization CHANGING lv_subrc.
      IF lv_subrc <> 0.
        PERFORM f_error_message USING '' 'You are not authorized'.
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
  DATA : lt_lips   TYPE STANDARD TABLE OF lips,
         ls_lips   LIKE LINE OF lt_lips,
         ls_bsid   LIKE LINE OF gt_bsid,
         lt_010    TYPE STANDARD TABLE OF zfidt010,
         lt_015    TYPE STANDARD TABLE OF zfidt015,
         lt_report TYPE STANDARD TABLE OF ty_report.

  DATA : lv_blart TYPE bsid-blart,
         lv_payst TYPE zfidt010-payst,
         lv_vbund TYPE bsid-vbund,
         lr_vkbur TYPE RANGE OF vkbur.

  lv_blart  = 'RV'.
  lv_payst  = 'CBD'.
  lv_vbund  = 'OUTLET'.

  CASE 'X'.
    WHEN radio1.
      SELECT *
        FROM tbsl
        INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

      SELECT *
        FROM zfidt015
        INTO CORRESPONDING FIELDS OF TABLE gt_015
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur.

      lt_015[] = gt_015[].
      DELETE lt_015 WHERE type <> 'S'.
      IF lt_015[] IS NOT INITIAL.
        SELECT *
          FROM skat
          INTO CORRESPONDING FIELDS OF TABLE gt_skat
          FOR ALL ENTRIES IN lt_015
          WHERE spras = sy-langu
            AND ktopl = 'TSPC'
            AND saknr = lt_015-konto.
      ENDIF.

      lt_015[] = gt_015[].
      DELETE lt_015 WHERE type <> 'T'.
      IF lt_015[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE gt_kna1
          FOR ALL ENTRIES IN lt_015
          WHERE kunnr = lt_015-konto.
      ENDIF.

      SELECT *
        FROM bsid
        INTO CORRESPONDING FIELDS OF TABLE gt_bsid
        WHERE bukrs = pa_bukrs
          AND kunnr IN so_kunnr
          AND zuonr IN so_vbevl
          AND blart = lv_blart
          AND zfbdt IN so_zfbdt
          AND vbund = lv_vbund.

      SORT gt_bsid BY zuonr.
      LOOP AT gt_bsid INTO ls_bsid.
        ls_lips-vbeln  = ls_bsid-zuonr(10).
        COLLECT ls_lips INTO lt_lips.
        CLEAR ls_lips.
      ENDLOOP.

      IF lt_lips[] IS NOT INITIAL.
*        PERFORM f_get_soff TABLES lr_vkbur.

        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN lt_lips
          WHERE vbeln = lt_lips-vbeln
            AND vkbur = pa_vkbur.
*            AND vkbur IN lr_vkbur.

        SELECT *
          FROM zfidt012
          INTO CORRESPONDING FIELDS OF TABLE gt_x012
          FOR ALL ENTRIES IN lt_lips
          WHERE vbevl = lt_lips-vbeln.
      ENDIF.

      CLEAR : lt_lips[].

      lt_lips[] = gt_lips[].
      SORT lt_lips BY vgbel.
      DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vgbel.
      IF lt_lips[] IS NOT INITIAL.
        SELECT *
          FROM zfidt010
          INTO CORRESPONDING FIELDS OF TABLE gt_010
          FOR ALL ENTRIES IN lt_lips
          WHERE bukrs = pa_bukrs
            AND vkbur = pa_vkbur
            AND payst = lv_payst
            AND vbeva = lt_lips-vgbel
            AND kunnr IN so_kunnr
            AND webno = space
            AND stblg = space.
      ENDIF.

      lt_010[] = gt_010[].
      SORT lt_010 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_010 COMPARING kunnr.
      IF lt_010[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1
          FOR ALL ENTRIES IN lt_010
          WHERE kunnr = lt_010-kunnr.
      ENDIF.

    WHEN radio2.
      SELECT *
        FROM zfidt012
        INTO CORRESPONDING FIELDS OF TABLE gt_report
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND webno IN so_webno
          AND vbevl IN so_vbevl
          AND kunnr IN so_kunnr.

      lt_report[] = gt_report[].
      SORT lt_report BY bukrs vkbur webno gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_report COMPARING bukrs vkbur webno gjahr.
      IF lt_report[] IS NOT INITIAL.
        SELECT *
          FROM zfidt011
          INTO CORRESPONDING FIELDS OF TABLE gt_011
          FOR ALL ENTRIES IN lt_report
          WHERE bukrs = lt_report-bukrs
            AND vkbur = lt_report-vkbur
            AND webno = lt_report-webno
            AND gjahr = lt_report-gjahr
            AND budat IN so_budat.

        IF gt_011[] IS NOT INITIAL.
          SELECT bukrs belnr gjahr buzei shkzg dmbtr wrbtr zuonr kunnr
            FROM bseg
            INTO CORRESPONDING FIELDS OF TABLE gt_bseg
            FOR ALL ENTRIES IN gt_011
            WHERE bukrs = gt_011-bukrs
              AND belnr = gt_011-belnr
              AND gjahr = gt_011-gjahr.
        ENDIF.
      ENDIF.

      lt_report[] = gt_report[].
      SORT lt_report BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_report COMPARING kunnr.
      IF lt_report[] IS NOT INITIAL.
        SELECT *
          FROM kna1
          APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1
          FOR ALL ENTRIES IN lt_report
          WHERE kunnr = lt_report-kunnr.
      ENDIF.

    WHEN radio3.
      SELECT *
        FROM zfidt011
        INTO CORRESPONDING FIELDS OF TABLE gt_011
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND webno = pa_webno
          AND gjahr = pa_gjahr.

      SELECT *
        FROM zfidt012
        INTO CORRESPONDING FIELDS OF TABLE gt_012
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND webno = pa_webno
          AND gjahr = pa_gjahr.

      IF gt_011[] IS NOT INITIAL.
        SELECT bukrs belnr gjahr budat
          FROM bkpf
          INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
          FOR ALL ENTRIES IN gt_011
          WHERE bukrs = gt_011-bukrs
            AND belnr = gt_011-belnr
            AND gjahr = gt_011-gjahr.

        SELECT bukrs belnr gjahr buzei shkzg dmbtr wrbtr zuonr kunnr
          FROM bseg
          INTO CORRESPONDING FIELDS OF TABLE gt_bseg
          FOR ALL ENTRIES IN gt_011
          WHERE bukrs = gt_011-bukrs
            AND belnr = gt_011-belnr
            AND gjahr = gt_011-gjahr.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_x010    TYPE STANDARD TABLE OF zfidt010,
         ls_x010    LIKE LINE OF lt_x010,
         ls_x012    LIKE LINE OF gt_x012,
         ls_010     LIKE LINE OF gt_010,
         ls_lips    LIKE LINE OF gt_lips,
         ls_bsid    LIKE LINE OF gt_bsid,
         ls_kna1    LIKE LINE OF gt_kna1,
         ls_011     LIKE LINE OF gt_011,
         ls_out     LIKE LINE OF gt_out,
         ls_report  LIKE LINE OF gt_report,
         ls_012     LIKE LINE OF gt_012,
         ls_reverse LIKE LINE OF gt_reverse,
         ls_header  LIKE LINE OF gt_header,
         ls_detail  LIKE LINE OF gt_detail,
         ls_bseg    LIKE LINE OF gt_bseg.

  DATA : lv_amtchk  TYPE bsid-dmbtr VALUE 50,
         lv_selisih TYPE bsid-dmbtr.

  CASE 'X'.
    WHEN radio1.
      lt_x010[] = gt_010.
      SORT lt_x010 BY vbeva.
      DELETE ADJACENT DUPLICATES FROM lt_x010 COMPARING vbeva.

      LOOP AT lt_x010 INTO ls_x010.
        ls_out-bukrs    = ls_x010-bukrs.
        ls_out-vkbur    = ls_x010-vkbur.
        ls_out-vbeva    = ls_x010-vbeva.
        ls_out-kunnr    = ls_x010-kunnr.
        PERFORM f_kna1_description USING ls_x010-kunnr
                                   CHANGING ls_out-name1.
        LOOP AT gt_010 INTO ls_010 WHERE vbeva = ls_x010-vbeva.
          ADD ls_010-dmbtr TO ls_out-umbtr.
        ENDLOOP.
        CLEAR : ls_lips, ls_bsid, ls_x012.
        READ TABLE gt_lips INTO ls_lips
                           WITH KEY vgbel = ls_x010-vbeva.
        IF sy-subrc = 0.
          READ TABLE gt_x012 INTO ls_x012
                             WITH KEY vbevl = ls_lips-vbeln.
          IF sy-subrc = 0.
            CLEAR ls_out.
            CONTINUE.
          ENDIF.

          READ TABLE gt_bsid INTO ls_bsid
                             WITH KEY zuonr = ls_lips-vbeln.
          IF sy-subrc = 0.
            ls_out-vbevl  = ls_lips-vbeln.
            ls_out-belnr  = ls_bsid-belnr.
            ls_out-dnbtr  = ls_bsid-dmbtr.
            ls_out-waers  = ls_bsid-waers.
          ENDIF.
        ENDIF.

*        IF ls_out-dnbtr < ls_out-umbtr.
*          ls_out-titipan  = ls_out-umbtr - ls_out-dnbtr.
*        ELSE.
*          ls_out-selisih  = ls_out-dnbtr - ls_out-umbtr.
*        ENDIF.

        lv_selisih = ls_out-umbtr - ls_out-dnbtr.
        IF lv_selisih <= 0.
          ls_out-titipan = 0.
          ls_out-selisih = 0.
        ELSEIF lv_selisih >= lv_amtchk.
          ls_out-titipan = lv_selisih.
        ELSEIF lv_selisih < lv_amtchk AND
          lv_selisih > 0.
          ls_out-selisih = lv_selisih.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      ASSIGN gt_out TO <fs_out>.

    WHEN radio2.
      LOOP AT gt_report INTO ls_report.
        CLEAR : ls_kna1, ls_011.
        READ TABLE gt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_report-kunnr.
        IF sy-subrc = 0.
          ls_report-name1 = ls_kna1-name1.
        ENDIF.
        READ TABLE gt_011 INTO ls_011
                          WITH KEY webno = ls_report-webno
                          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          LOOP AT gt_011 INTO ls_011 WHERE webno = ls_report-webno.
            CASE ls_011-clrst.
              WHEN 'CLEARING'.
                PERFORM f_get_fi_doc USING ls_011-belnr ls_011-gjahr
                                           ls_report-kunnr ls_report-vbevl
                                     CHANGING ls_report-clrnr.
*                ls_report-clrnr = ls_011-belnr.
              WHEN 'TITIPAN'.
                IF ls_report-tpbtr <> 0.
                  PERFORM f_get_fi_doc USING ls_011-belnr ls_011-gjahr
                                             ls_report-kunnr ls_report-vbevl
                                       CHANGING ls_report-ttpnr.
*                  ls_report-ttpnr = ls_011-belnr.
                ENDIF.
              WHEN 'SELISIH'.
                IF ls_report-slbtr <> 0.
                  PERFORM f_get_fi_doc USING ls_011-belnr ls_011-gjahr
                                             ls_report-kunnr ls_report-vbevl
                                       CHANGING ls_report-selnr.
*                  ls_report-selnr = ls_011-belnr.
                ENDIF.
            ENDCASE.
            ls_report-budat = ls_011-budat.
            ls_report-usnam = ls_011-usnam.
            ls_report-cpudt = ls_011-cpudt.
            ls_report-cputm = ls_011-cputm.
          ENDLOOP.
          MODIFY gt_report FROM ls_report
                           TRANSPORTING name1 clrnr ttpnr selnr
                                        budat usnam cpudt cputm.
        ELSE.
          DELETE gt_report WHERE webno = ls_report-webno.
        ENDIF.
        CLEAR ls_report.
      ENDLOOP.
      ASSIGN gt_report TO <fs_out>.

    WHEN radio3.
      LOOP AT gt_bseg INTO ls_bseg.
        CLEAR ls_012.
        READ TABLE gt_012 INTO ls_012
                          WITH KEY vbevl = ls_bseg-zuonr.
        IF sy-subrc <> 0.
          DELETE TABLE gt_bseg FROM ls_bseg.
        ENDIF.
      ENDLOOP.

      LOOP AT gt_011 INTO ls_011.
        MOVE-CORRESPONDING ls_011 TO ls_header.
        CLEAR ls_bseg.
        LOOP AT gt_bseg INTO ls_bseg
                        WHERE bukrs = ls_011-bukrs
                          AND belnr = ls_011-belnr
                          AND gjahr = ls_011-gjahr.
          ls_detail-belnr = ls_bseg-belnr.
          ls_detail-kunnr = ls_bseg-kunnr.
          ls_detail-dmbtr = ls_bseg-dmbtr.
          CLEAR ls_012.
          READ TABLE gt_012 INTO ls_012
                            WITH KEY vbevl = ls_bseg-zuonr.
          IF sy-subrc = 0.
            ls_detail-bukrs = ls_012-bukrs.
            ls_detail-vkbur = ls_012-vkbur.
            ls_detail-vbevl = ls_012-vbevl.
            ls_detail-vbeva = ls_012-vbeva.
            ls_detail-vbevf = ls_012-vbevf.
            ls_detail-waers = ls_012-waers.
          ENDIF.
          APPEND ls_detail TO gt_detail.
          CLEAR ls_detail.
        ENDLOOP.
        APPEND ls_header TO gt_header.
        CLEAR ls_header.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF <fs_out>[] IS NOT INITIAL.
    CALL SCREEN 101.
  ELSE.
    MESSAGE s000(zab) WITH 'No datas exist' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  CASE sy-dynnr.
    WHEN '0101'.
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

    WHEN '0103'.
      IF gv_ttbtr <> 0 AND
        gv_slbtr <> 0.
      ENDIF.
  ENDCASE.
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
      IF gv_post IS INITIAL.
        CASE sy-dynnr.
          WHEN '0101'.
            APPEND '&SIM' TO fcode.
            SET PF-STATUS 'STANDARD' EXCLUDING fcode.
          WHEN '0102'.
            SET PF-STATUS 'STATUS' EXCLUDING fcode.
          WHEN '0103'.
            APPEND '&SIM' TO fcode.
            SET PF-STATUS 'STANDARD' EXCLUDING fcode.
        ENDCASE.
      ELSE.
        APPEND '&SIM' TO fcode.
        APPEND '&POS' TO fcode.
        SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      ENDIF.

    WHEN radio2.
      APPEND '&POS' TO fcode.
      APPEND '&SIM' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.


    WHEN radio3.
      APPEND '&SIM' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  ENDCASE.

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
FORM f_user_command USING    fu_ucomm    LIKE sy-ucomm
                             fu_selfield TYPE slis_selfield.
  DATA : lv_ucomm    TYPE sy-ucomm,
         lv_valid    TYPE c,
         lt_fidx     TYPE lvc_t_fidx,
         ls_fidx     TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter,
         lv_subrc    TYPE sy-subrc,
         lv_text(50).

  IF ok_code IS NOT INITIAL.
    lv_ucomm  = ok_code.
  ELSE.
    lv_ucomm  = fu_ucomm.
  ENDIF.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'CONT'.
      PERFORM f_validate_data.

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

    WHEN '&SIM'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_simulate_data.
*        IF gv_continue IS NOT INITIAL.
*          CALL SCREEN 103.
*        ENDIF.
      ENDIF.

    WHEN '&POS'.
      CASE 'X'.
        WHEN radio3.
          PERFORM f_validasi_reverse_document CHANGING lv_subrc.
          IF lv_subrc = 0.
            PERFORM f_reverse_data CHANGING lv_subrc.
            PERFORM f_print_reverse.
            IF lv_subrc = 0.
              gv_post = 'X'.
              lv_text = |{ 'No. Transaksi' } { pa_webno } { 'already reversed' } |.
              MESSAGE s000(zab) WITH lv_text.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_simulate_data.
            IF gt_bapiret2[] IS INITIAL.
              PERFORM f_posting_data.
              PERFORM f_save_data.
              gv_post = 'X'.
              PERFORM f_alv_refresh USING 'X'.
            ENDIF.
          ENDIF.
      ENDCASE.

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

  DATA : lv_coltext(40).

  CLEAR gt_main_fieldcat[].
  CASE 'X'.
    WHEN radio1.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
    WHEN radio2.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_report.
    WHEN radio3.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_reverse.
  ENDCASE.

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
        '' '' '' '' '' 'Sts.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BELNR'.
        IF radio3 IS INITIAL.
          CONTINUE.
        ENDIF.
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'NAME1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DNBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Amount DO' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'UMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Uang Muka' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'TPBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Titipan' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'SLBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Selisih' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'TITIPAN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Titipan' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'SELISIH'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'Selisih' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'CLRNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Doc.Clearing' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'TTPNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Doc.Titipan' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'SELNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Doc.Selisih' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'WEBNO'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No.' '' '' '' '' '' '' '' '' '' ''
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
  DATA : lt_out    TYPE STANDARD TABLE OF ty_out,
         lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_out    TYPE ty_out,
         ls_xout   TYPE ty_out,
         return    TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF return.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL OR
                      icon = icon_led_green.

  IF lt_out[] IS NOT INITIAL.
    documentheader-header_txt = 'Clearing AR'.
    PERFORM f_bapi_posting TABLES accountgl1
                                  accountreceivable1
                                  accountpayable1
                                  currencyamount1
                                  criteria1
                                  extension11
                                  extension21
                                  return
                           USING  documentheader
                           CHANGING obj_type.

    PERFORM f_modify_data TABLES lt_out
                                 return
                          USING 'CLEARING' '' ''.
  ENDIF.

  IF gv_ttbtr <> 0 AND
    gt_bapiret2[] IS INITIAL.
    lt_xout[] = lt_out[].
    SORT lt_xout BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING kunnr.

    LOOP AT lt_xout INTO ls_xout.
      CLEAR : accountgl2[], accountreceivable2[], accountpayable2[],
              currencyamount2[], criteria2[], extension12[], extension22[].
      PERFORM f_prepare_posting TABLES lt_out
                                USING 'TITIPAN' ls_xout-kunnr.

      documentheader-header_txt = 'Lebih bayar'.
      PERFORM f_bapi_posting TABLES accountgl2
                                    accountreceivable2
                                    accountpayable2
                                    currencyamount2
                                    criteria2
                                    extension12
                                    extension22
                                    return
                             USING  documentheader
                             CHANGING obj_type.

      PERFORM f_modify_data TABLES lt_out
                                   return
                            USING 'TITIPAN' ls_xout-kunnr ''.
    ENDLOOP.
  ENDIF.

  IF gv_slbtr <> 0 AND
    gt_bapiret2[] IS INITIAL.
    documentheader-header_txt = 'Lebih bayar'.
    PERFORM f_bapi_posting TABLES accountgl3
                                  accountreceivable3
                                  accountpayable3
                                  currencyamount3
                                  criteria3
                                  extension13
                                  extension23
                                  return
                           USING  documentheader
                           CHANGING obj_type.

    PERFORM f_modify_data TABLES lt_out
                                 return
                          USING 'SELISIH' '' ''.
  ENDIF.

  IF gt_bapiret2[] IS INITIAL.
    gt_temp[] = lt_out[].
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
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out    LIKE LINE OF gt_out,
         ls_report LIKE LINE OF gt_report.

  DATA : lv_vbeln TYPE vbrk-vbeln,
         lv_belnr TYPE bkpf-belnr,
         lv_bukrs TYPE bkpf-bukrs,
         lv_gjahr TYPE bkpf-gjahr.

  CASE 'X'.
    WHEN radio1.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
    WHEN radio2.
      READ TABLE gt_report INTO ls_report INDEX fu_row.
  ENDCASE.

  CASE fu_column.
    WHEN 'ICON'.
*      READ TABLE gt_out INTO ls_out INDEX fu_row.
*      IF ls_out-icon = icon_led_red.
*        PERFORM f_error_log USING ls_out-vbevl.
*      ENDIF.
    WHEN 'VBEVA'.
      CASE 'X'.
        WHEN radio1.
          IF ls_out-vbeva IS NOT INITIAL.
            lv_vbeln = ls_out-vbeva.
          ENDIF.
        WHEN radio2.
          IF ls_report-vbeva IS NOT INITIAL.
            lv_vbeln = ls_report-vbeva.
          ENDIF.
      ENDCASE.
      IF lv_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD lv_vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBEVL'.
      CASE 'X'.
        WHEN radio1.
          IF ls_out-vbevl IS NOT INITIAL.
            lv_vbeln = ls_out-vbevl.
          ENDIF.
        WHEN radio2.
          IF ls_report-vbevl IS NOT INITIAL.
            lv_vbeln = ls_report-vbevl.
          ENDIF.
      ENDCASE.
      IF lv_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD lv_vbeln.
        CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBEVF'.
      CASE 'X'.
        WHEN radio2.
          IF ls_report-vbevf IS NOT INITIAL.
            lv_vbeln = ls_report-vbevf.
          ENDIF.
      ENDCASE.
      IF lv_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD lv_vbeln.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'CLRNR'.
      CASE 'X'.
        WHEN radio1.
          IF ls_out-clrnr IS NOT INITIAL.
            lv_bukrs = ls_out-bukrs.
            lv_gjahr = ls_out-gjahr.
            lv_belnr = ls_out-clrnr.
          ENDIF.
        WHEN radio2.
          IF ls_report-clrnr IS NOT INITIAL.
            lv_bukrs = ls_report-bukrs.
            lv_gjahr = ls_report-gjahr.
            lv_belnr = ls_report-clrnr.
          ENDIF.
      ENDCASE.
      IF lv_belnr IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD lv_belnr.
        SET PARAMETER ID 'BUK' FIELD lv_bukrs.
        SET PARAMETER ID 'GJR' FIELD lv_gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'TTPNR'.
      CASE 'X'.
        WHEN radio1.
          IF ls_out-ttpnr IS NOT INITIAL.
            lv_bukrs = ls_out-bukrs.
            lv_gjahr = ls_out-gjahr.
            lv_belnr = ls_out-ttpnr.
          ENDIF.
        WHEN radio2.
          IF ls_report-clrnr IS NOT INITIAL.
            lv_bukrs = ls_report-bukrs.
            lv_gjahr = ls_report-gjahr.
            lv_belnr = ls_report-ttpnr.
          ENDIF.
      ENDCASE.
      IF lv_belnr IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD lv_belnr.
        SET PARAMETER ID 'BUK' FIELD lv_bukrs.
        SET PARAMETER ID 'GJR' FIELD lv_gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'SELNR'.
      CASE 'X'.
        WHEN radio1.
          IF ls_out-selnr IS NOT INITIAL.
            lv_bukrs = ls_out-bukrs.
            lv_gjahr = ls_out-gjahr.
            lv_belnr = ls_out-selnr.
          ENDIF.
        WHEN radio2.
          IF ls_report-selnr IS NOT INITIAL.
            lv_bukrs = ls_report-bukrs.
            lv_gjahr = ls_report-gjahr.
            lv_belnr = ls_report-selnr.
          ENDIF.
      ENDCASE.
      IF lv_belnr IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD lv_belnr.
        SET PARAMETER ID 'BUK' FIELD lv_bukrs.
        SET PARAMETER ID 'GJR' FIELD lv_gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log  USING    fu_vbeln.
  DATA : lt_bapiret2 TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2 LIKE LINE OF lt_bapiret2,
         ls_error    LIKE LINE OF gt_error,
         lv_lines    TYPE i.

  LOOP AT gt_error INTO ls_error WHERE vbeln = fu_vbeln.
    MOVE-CORRESPONDING ls_error TO ls_bapiret2.
    APPEND ls_bapiret2 TO lt_bapiret2.
    CLEAR ls_bapiret2.
  ENDLOOP.

  DESCRIBE TABLE lt_bapiret2 LINES lv_lines.
  IF lv_lines = 1.
    APPEND INITIAL LINE TO lt_bapiret2.
  ENDIF.

  CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
    TABLES
      i_bapiret2_tab = lt_bapiret2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_POSTING
*&---------------------------------------------------------------------*
FORM f_bapi_posting  TABLES    accountgl         STRUCTURE bapiacgl09
                               accountreceivable STRUCTURE bapiacar09
                               accountpayable    STRUCTURE bapiacap09
                               currencyamount    STRUCTURE bapiaccr09
                               criteria          STRUCTURE bapiackec9
                               extension1        STRUCTURE bapiacextc
                               extension2        STRUCTURE bapiparex
                               return            STRUCTURE bapiret2
                      USING    documentheader
                      CHANGING obj_type.

  CLEAR : return[].

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      criteria          = criteria
      extension1        = extension1
      extension2        = extension2
      return            = return.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING
*&---------------------------------------------------------------------*
FORM f_prepare_posting  TABLES   ft_out TYPE STANDARD TABLE
                        USING    fu_posting fu_kunnr.

  DATA : lt_out TYPE STANDARD TABLE OF ty_out,
         ls_out TYPE ty_out,
         ls_015 TYPE zfidt015.

  DATA : lv_buzei TYPE bseg-buzei,
         lv_gsber TYPE bseg-gsber,
         lv_kostl TYPE bseg-kostl.

  lt_out[] = ft_out[].

  SELECT SINGLE *
    FROM zfidt015
    INTO CORRESPONDING FIELDS OF ls_015
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur
      AND kostl <> space.

  CASE pa_bukrs.
    WHEN '8020'.
      lv_gsber  = '0200'.
      lv_kostl  = ls_015-kostl.
    WHEN OTHERS.
      lv_gsber = pa_vkbur.
      lv_kostl  = ls_015-kostl.
  ENDCASE.

  CASE fu_posting.
    WHEN 'CLEARING'.
      LOOP AT lt_out INTO ls_out.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'D' lv_buzei ls_out-kunnr '' ''
                                  'Clearing AR-' ls_out-vbeva lv_gsber ls_out-vbevl
                                  '' '15' ls_out-umbtr.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'D' lv_buzei ls_out-kunnr '' 'A'
                                  'Peny.CBD-' ls_out-vbeva ls_out-vkbur ls_out-vbevl
                                  '' '09' ls_out-umbtr.
      ENDLOOP.
    WHEN 'TITIPAN'.
      DELETE lt_out WHERE titipan = 0 OR
                          kunnr <> fu_kunnr.
      LOOP AT lt_out INTO ls_out.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'D' lv_buzei gv_titipan ls_out-kunnr 'C'
                                  'Lebih bayar-' ls_out-vbeva ls_out-vkbur ls_out-vbevl
                                  '' '19' ls_out-titipan.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'D' lv_buzei ls_out-kunnr '' ''
                                  'Lebih bayar CBD-' ls_out-vbeva lv_gsber ls_out-vbevl
                                  '' '05' ls_out-titipan.
      ENDLOOP.
    WHEN 'SELISIH'.
      DELETE lt_out WHERE selisih = 0.
      LOOP AT lt_out INTO ls_out.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'S' lv_buzei gv_selisih '' ''
                                  'Lebih bayar-' ls_out-vbeva ls_out-vkbur ls_out-vbevl
                                  lv_kostl '50' ls_out-selisih.
        ADD 1 TO lv_buzei.
        PERFORM f_bapi_data USING fu_posting 'D' lv_buzei ls_out-kunnr '' ''
                                  'Lebih bayar CBD-' ls_out-vbeva lv_gsber ls_out-vbevl
                                  '' '05' ls_out-selisih.
      ENDLOOP.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data  TABLES   ft_out TYPE STANDARD TABLE
                             return STRUCTURE bapiret2
                    USING    fu_process fu_kunnr fu_hkont.
  DATA : ls_out    TYPE ty_out,
         ls_return TYPE bapiret2,
         ls_error  LIKE LINE OF gt_error.

  DATA : lv_belnr TYPE bsid-belnr,
         lv_gjahr TYPE bsid-gjahr,
         lv_dmbtr TYPE bsid-dmbtr,
         lv_waers TYPE bsid-waers,
         lv_hkont TYPE bsid-hkont.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'A' OR ls_return-type = 'E'.
      MOVE-CORRESPONDING ls_return TO ls_error.
      IF ls_return-id NE 'RW' OR
        ls_return-number NE '609'.
*        ls_error-vbeln = fu_vbeln.
        APPEND ls_error TO gt_error.
      ENDIF.
    ELSE.
      lv_belnr   = ls_return-message_v2(10).
      lv_gjahr   = ls_return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

  IF lv_belnr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

  LOOP AT ft_out INTO ls_out.
    ls_out-mark = space.
    CASE fu_process.
      WHEN 'CLEARING'.
        ls_out-clrnr  = lv_belnr.
        ls_out-gjahr  = lv_gjahr.
        lv_waers      = ls_out-waers.
        ADD ls_out-umbtr TO lv_dmbtr.
      WHEN 'TITIPAN'.
        IF ls_out-kunnr <> fu_kunnr OR
          ls_out-titipan = 0.
          CONTINUE.
        ENDIF.
        ls_out-ttpnr  = lv_belnr.
        lv_waers      = ls_out-waers.
        ADD ls_out-titipan TO lv_dmbtr.
        lv_hkont      = gv_titipan.
      WHEN 'SELISIH'.
        IF ls_out-selisih = 0.
          CONTINUE.
        ENDIF.
        ls_out-selnr  = lv_belnr.
        lv_waers      = ls_out-waers.
        ADD ls_out-selisih TO lv_dmbtr.
        lv_hkont      = gv_selisih.
    ENDCASE.

    IF lv_belnr IS NOT INITIAL.
      ls_out-icon = icon_led_green.
    ELSE.
      ls_out-icon = icon_led_red.
    ENDIF.

    CASE fu_process.
      WHEN 'CLEARING'.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark icon clrnr gjahr
                      WHERE vbevl = ls_out-vbevl.
      WHEN 'TITIPAN'.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark icon ttpnr
                      WHERE vbevl = ls_out-vbevl.
      WHEN 'SELISIH'.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark icon selnr
                      WHERE vbevl = ls_out-vbevl.
    ENDCASE.
  ENDLOOP.

  PERFORM f_append_011 USING fu_process lv_belnr lv_gjahr lv_dmbtr
                             lv_waers lv_hkont.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .
*  IF gv_dmbtr <> 0 AND gv_clearing IS INITIAL.
*    MESSAGE s000(zab) WITH 'Fill in all required entry fields' DISPLAY LIKE 'E'.
*  ELSE.
  gv_continue = 'X'.
  LEAVE TO SCREEN 0.
*  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SKAT_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_skat_description  USING    fu_hkont
                         CHANGING fc_txt50.
  DATA : ls_skat    LIKE LINE OF gt_skat.

  CLEAR : ls_skat, fc_txt50.
  READ TABLE gt_skat INTO ls_skat
                     WITH KEY saknr = fu_hkont.
  IF sy-subrc = 0.
    fc_txt50 = ls_skat-txt50.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE_DATA
*&---------------------------------------------------------------------*
FORM f_simulate_data .
  DATA : lt_out  TYPE STANDARD TABLE OF ty_out,
         lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_out  TYPE ty_out,
         ls_xout TYPE ty_out,
         ls_015  LIKE LINE OF gt_015.

  DATA : lv_belnr TYPE bsid-belnr,
         lv_blart TYPE bkpf-blart.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL OR
                      icon = icon_led_green.
  IF lt_out[] IS NOT INITIAL.
    gv_budat  = sy-datum.
    gv_bldat  = sy-datum.
    gv_waers  = 'IDR'.
    lv_blart  = 'DZ'.
    CLEAR gv_continue.

    LOOP AT gt_015 INTO ls_015.
      CASE ls_015-type.
        WHEN 'T'.
          gv_titipan = ls_015-konto.
          PERFORM f_kna1_description USING ls_015-konto
                                     CHANGING gv_titip.
        WHEN 'S'.
          gv_selisih = ls_015-konto.
          PERFORM f_skat_description USING ls_015-konto
                                     CHANGING gv_selis.
      ENDCASE.
    ENDLOOP.

    CLEAR : gv_dmbtr, gv_ttbtr, gv_slbtr, gt_bapiret2[], gt_012[].

    LOOP AT lt_out INTO ls_out.
      ADD ls_out-dnbtr   TO gv_dmbtr.
      ADD ls_out-titipan TO gv_ttbtr.
      ADD ls_out-selisih TO gv_slbtr.

      PERFORM f_append_012 USING ls_out.
    ENDLOOP.

    lt_xout[] = lt_out[].
    SORT lt_xout BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING kunnr.

    CALL SCREEN 102 STARTING AT 10 10.

    IF gv_continue IS NOT INITIAL.
      documentheader-bus_act    = 'RFBU'.
      documentheader-username   = sy-uname.
      documentheader-comp_code  = pa_bukrs.
      documentheader-doc_date   = gv_bldat.
      documentheader-pstng_date = gv_budat.
      documentheader-doc_type   = lv_blart.
      documentheader-ref_doc_no = gv_xblnr.

* Clearing Document
      CLEAR : accountgl1[], accountreceivable1[], accountpayable1[],
              currencyamount1[], criteria1[], extension11[],
              extension21[].
      PERFORM f_prepare_posting TABLES lt_out
                                USING 'CLEARING' ''.

      documentheader-header_txt = 'Clearing AR'.
      PERFORM f_bapi_simulate TABLES accountgl1
                                     accountreceivable1
                                     accountpayable1
                                     currencyamount1
                                     criteria1
                                     extension11
                                     extension21
                              USING  documentheader
                              CHANGING obj_type.

* Titipan Document
      IF gv_ttbtr <> 0 AND
        gt_bapiret2[] IS INITIAL.
        LOOP AT lt_xout INTO ls_xout.
          CLEAR : accountgl2[], accountreceivable2[], accountpayable2[],
                  currencyamount2[], criteria2[], extension12[],
                  extension22[].
          PERFORM f_prepare_posting TABLES lt_out
                                    USING 'TITIPAN' ls_xout-kunnr.

          documentheader-header_txt = 'Lebih bayar'.
          PERFORM f_bapi_simulate TABLES accountgl2
                                         accountreceivable2
                                         accountpayable2
                                         currencyamount2
                                         criteria2
                                         extension12
                                         extension22
                                  USING  documentheader
                                  CHANGING obj_type.
        ENDLOOP.
      ENDIF.

* Selisih Document
      IF gv_slbtr <> 0 AND
        gt_bapiret2[] IS INITIAL.
        CLEAR : accountgl3[], accountreceivable3[], accountpayable3[],
                currencyamount3[], criteria3[], extension13[],
                extension23[].
        PERFORM f_prepare_posting TABLES lt_out
                                   USING 'SELISIH' ''.

        documentheader-header_txt = 'Lebih bayar'.
        PERFORM f_bapi_simulate TABLES accountgl3
                                       accountreceivable3
                                       accountpayable3
                                       currencyamount3
                                       criteria3
                                       extension13
                                       extension23
                                USING  documentheader
                                CHANGING obj_type.
      ENDIF.

      IF gt_bapiret2[] IS NOT INITIAL.
        LOOP AT lt_out INTO ls_out.
          ls_out-icon = icon_led_red.
          MODIFY gt_out FROM ls_out
                        TRANSPORTING icon
                        WHERE vbeva = ls_out-vbeva
                          AND vbevl = ls_out-vbevl.
        ENDLOOP.
      ENDIF.
      MESSAGE s000(zab) WITH ''.
    ENDIF.

    PERFORM f_alv_refresh USING 'X'.
  ELSE.
    MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_SIMULATE
*&---------------------------------------------------------------------*
FORM f_bapi_simulate  TABLES   accountgl         STRUCTURE bapiacgl09
                               accountreceivable STRUCTURE bapiacar09
                               accountpayable    STRUCTURE bapiacap09
                               currencyamount    STRUCTURE bapiaccr09
                               criteria          STRUCTURE bapiackec9
                               extension1        STRUCTURE bapiacextc
                               extension2        STRUCTURE bapiparex
                      USING    documentheader
                      CHANGING obj_type.
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF return.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      extension2        = extension2
      criteria          = criteria
      return            = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'A' OR ls_return-type = 'E'.
      APPEND ls_return TO gt_bapiret2.
      CLEAR ls_return.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_KNA1_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_kna1_description  USING    fu_kunnr
                         CHANGING fc_name1.
  DATA : ls_kna1  LIKE LINE OF gt_kna1.

  CLEAR : ls_kna1, fc_name1.
  READ TABLE gt_kna1 INTO ls_kna1
                     WITH KEY kunnr = fu_kunnr.
  IF sy-subrc = 0.
    fc_name1  = ls_kna1-name1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  IF gv_ttbtr = 0.
    PERFORM f_modify_screen USING : 'T01' '0' '' '' ''.
  ENDIF.
  IF gv_slbtr = 0.
    PERFORM f_modify_screen USING : 'S01' '0' '' '' ''.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_CURRENCY
*&---------------------------------------------------------------------*
FORM f_modify_currency  USING    fu_dmbtr fu_koart fu_bschl
                        CHANGING fc_dmbtr.
  DATA : ls_tbsl    LIKE LINE OF gt_tbsl.

  DATA : lv_dmbtr(20).

  WRITE fu_dmbtr TO lv_dmbtr CURRENCY gv_waers.
  TRANSLATE lv_dmbtr USING '. '.
  TRANSLATE lv_dmbtr USING ',.'.
  CONDENSE lv_dmbtr NO-GAPS.

  READ TABLE gt_tbsl INTO ls_tbsl
                     WITH KEY koart = fu_koart
                              bschl = fu_bschl.
  IF sy-subrc = 0.
    CASE ls_tbsl-shkzg.
      WHEN 'S'.
        fc_dmbtr  = lv_dmbtr.
      WHEN 'H'.
        fc_dmbtr  = lv_dmbtr * -1.
    ENDCASE.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DATA
*&---------------------------------------------------------------------*
FORM f_bapi_data  USING    fu_posting fu_koart fu_buzei fu_konto fu_kunnr
                           fu_umskz fu_sgtxt fu_vbeva fu_gsber fu_vbevl
                           fu_kostl fu_bschl fu_dmbtr.
  DATA : ls_accountgl         TYPE bapiacgl09,
         ls_accountreceivable TYPE bapiacar09,
         ls_extension1        TYPE bapiacextc,
         ls_extension2        TYPE bapiparex,
         ls_currencyamount    TYPE bapiaccr09.

  CASE fu_koart.
    WHEN 'D'.
      ls_accountreceivable-itemno_acc   = fu_buzei.
      ls_accountreceivable-customer     = fu_konto.
      ls_accountreceivable-sp_gl_ind    = fu_umskz.
      CASE fu_bschl.
        WHEN '05'.
          CONCATENATE fu_sgtxt gv_budat '-' fu_vbeva '-' fu_konto
          INTO ls_accountreceivable-item_text.
          ls_accountreceivable-alloc_nmbr   = fu_vbevl.

          ls_extension2-structure         = 'POSTING_KEY'.
          ls_extension2-valuepart1        = fu_buzei.
          ls_extension2-valuepart2        = '05'.
          APPEND ls_extension2 TO extension22.
          CLEAR ls_extension2.

          ls_extension2-structure         = 'POSTING_KEY'.
          ls_extension2-valuepart1        = fu_buzei.
          ls_extension2-valuepart2        = '05'.
          APPEND ls_extension2 TO extension23.
          CLEAR ls_extension2.
        WHEN '09'.
          CONCATENATE fu_sgtxt gv_budat '-' fu_vbeva '-' fu_konto
          INTO ls_accountreceivable-item_text.
          ls_accountreceivable-alloc_nmbr   = fu_vbeva.
        WHEN '15'.
          CONCATENATE fu_sgtxt fu_vbeva
          INTO ls_accountreceivable-item_text.
          ls_accountreceivable-alloc_nmbr   = fu_vbevl.

          ls_extension2-structure         = 'POSTING_KEY'.
          ls_extension2-valuepart1        = fu_buzei.
          ls_extension2-valuepart2        = '15'.
          APPEND ls_extension2 TO extension21.
          CLEAR ls_extension2.

          ls_extension2-structure         = 'POSTING_KEY'.
          ls_extension2-valuepart1        = fu_buzei.
          ls_extension2-valuepart2        = '15'.
          APPEND ls_extension2 TO extension22.
          CLEAR ls_extension2.
        WHEN '19'.
          CONCATENATE fu_sgtxt gv_budat '-' fu_kunnr
          INTO ls_accountreceivable-item_text.
          ls_accountreceivable-alloc_nmbr   = gv_xblnr.
      ENDCASE.
      ls_accountreceivable-bus_area     = fu_gsber.
      CASE fu_posting.
        WHEN 'CLEARING'.
          APPEND ls_accountreceivable TO accountreceivable1.
        WHEN 'TITIPAN'.
          APPEND ls_accountreceivable TO accountreceivable2.
        WHEN 'SELISIH'.
          APPEND ls_accountreceivable TO accountreceivable3.
      ENDCASE.
      CLEAR ls_accountreceivable.

    WHEN 'S'.
      ls_accountgl-itemno_acc   = fu_buzei.
      ls_accountgl-gl_account   = fu_konto.
      CASE fu_bschl.
        WHEN '50'.
          CONCATENATE fu_sgtxt gv_budat
          INTO ls_accountgl-item_text.
          ls_accountgl-alloc_nmbr   = gv_xblnr.
      ENDCASE.
      ls_accountgl-bus_area     = fu_gsber.
      ls_accountgl-costcenter   = fu_kostl.
      APPEND ls_accountgl TO accountgl3.
      CLEAR ls_accountgl.
  ENDCASE.

  ls_extension1(3)          = fu_buzei.
  ls_extension1+3(2)        = fu_bschl.
  CASE fu_posting.
    WHEN 'CLEARING'.
      APPEND ls_extension1 TO extension11.
    WHEN 'TITIPAN'.
      APPEND ls_extension1 TO extension12.
    WHEN 'SELISIH'.
      APPEND ls_extension1 TO extension13.
  ENDCASE.
  CLEAR ls_extension1.

  ls_currencyamount-itemno_acc    = fu_buzei.
  ls_currencyamount-curr_type     = '00'.
  ls_currencyamount-currency      = gv_waers.
  PERFORM f_modify_currency USING fu_dmbtr fu_koart fu_bschl
                            CHANGING ls_currencyamount-amt_doccur.
  CASE fu_posting.
    WHEN 'CLEARING'.
      APPEND ls_currencyamount TO currencyamount1.
    WHEN 'TITIPAN'.
      APPEND ls_currencyamount TO currencyamount2.
    WHEN 'SELISIH'.
      APPEND ls_currencyamount TO currencyamount3.
  ENDCASE.
  CLEAR ls_currencyamount.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_012
*&---------------------------------------------------------------------*
FORM f_append_012  USING    fs_out  TYPE ty_out.
  DATA : ls_012   LIKE LINE OF gt_012.

  ls_012-bukrs  = fs_out-bukrs.
  ls_012-vkbur  = fs_out-vkbur.
  ls_012-gjahr  = gv_budat(4).
  ls_012-kunnr  = fs_out-kunnr.
  ls_012-vbevl  = fs_out-vbevl.
  ls_012-vbeva  = fs_out-vbeva.
  ls_012-vbevf  = fs_out-belnr.
  ls_012-dnbtr  = fs_out-dnbtr.
  ls_012-umbtr  = fs_out-umbtr.
  ls_012-tpbtr  = fs_out-titipan.
  ls_012-slbtr  = fs_out-selisih.
  ls_012-waers  = fs_out-waers.
  APPEND ls_012 TO gt_012.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_011
*&---------------------------------------------------------------------*
FORM f_append_011  USING    fu_process fu_belnr fu_gjahr fu_dmbtr
                            fu_waers fu_hkont.
  DATA : ls_011   LIKE LINE OF gt_011.

  ls_011-bukrs  = pa_bukrs.
  ls_011-vkbur  = pa_vkbur.
  ls_011-belnr  = fu_belnr.
  ls_011-gjahr  = fu_gjahr.
  ls_011-clrst  = fu_process.
  ls_011-hkont  = fu_hkont.
  ls_011-dmbtr  = fu_dmbtr.
  ls_011-waers  = fu_waers.
  ls_011-xblnr  = gv_xblnr.
  ls_011-budat  = gv_budat.
  ls_011-usnam  = sy-uname.
  ls_011-cpudt  = sy-datum.
  ls_011-cputm  = sy-uzeit.
  ls_011-aprnm  = sy-uname.
  ls_011-aprdt  = sy-datum.
  ls_011-aprtm  = sy-uzeit.
  APPEND ls_011 TO gt_011.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : ls_011  LIKE LINE OF gt_011,
         ls_012  LIKE LINE OF gt_012,
         ls_out  LIKE LINE OF gt_out,
         ls_temp LIKE LINE OF gt_temp.

  DATA : lv_number(10).

  PERFORM f_get_next_number USING 'ZMDSSAP'
                            CHANGING lv_number.

  IF gt_011[] IS NOT INITIAL.
    LOOP AT gt_011 INTO ls_011.
      CONCATENATE 'S' lv_number INTO ls_011-webno.
      MODIFY gt_011 FROM ls_011
                    TRANSPORTING webno.
    ENDLOOP.

    TRY.
        INSERT zfidt011 FROM TABLE gt_011.
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDIF.

  IF gt_012[] IS NOT INITIAL.
    LOOP AT gt_012 INTO ls_012.
      CONCATENATE 'S' lv_number INTO ls_012-webno.
      ls_012-gjahr = VALUE #( gt_011[ bukrs = ls_012-bukrs
                                      vkbur = ls_012-vkbur
                                      webno = ls_012-webno ]-gjahr OPTIONAL ).
      MODIFY gt_012 FROM ls_012
                    TRANSPORTING webno gjahr.
    ENDLOOP.

    TRY.
        INSERT zfidt012 FROM TABLE gt_012.
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDIF.

  LOOP AT gt_temp INTO ls_temp.
    CONCATENATE 'S' lv_number INTO ls_out-webno.
    MODIFY gt_out FROM ls_out
                  TRANSPORTING webno
                  WHERE bukrs = ls_temp-bukrs
                    AND vkbur = ls_temp-vkbur
                    AND vbeva = ls_temp-vbeva.
  ENDLOOP.

  COMMIT WORK AND WAIT.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_object
                        CHANGING fc_number.
  DATA : lv_gjahr   TYPE bsid-gjahr.

  lv_gjahr  = gv_budat(4).

  CALL FUNCTION 'ZFIFMNR'
    EXPORTING
      pi_object          = fu_object
      pi_bukrs           = pa_bukrs
      pi_gsber           = pa_vkbur
      pi_toyear          = lv_gjahr
    IMPORTING
      pe_number          = fc_number
    EXCEPTIONS
      interval_not_found = 1
      object_not_found   = 2
      OTHERS             = 3.

*  CALL FUNCTION 'NUMBER_GET_NEXT'
*    EXPORTING
*      nr_range_nr             = '01'
*      object                  = fu_object
*      subobject               = pa_bukrs
*      toyear                  = lv_gjahr
*    IMPORTING
*      number                  = fc_number
*    EXCEPTIONS
*      interval_not_found      = 1
*      number_range_not_intern = 2
*      object_not_found        = 3
*      quantity_is_0           = 4
*      quantity_is_not_1       = 5
*      interval_overflow       = 6
*      buffer_overflow         = 7
*      OTHERS                  = 8.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_DATA
*&---------------------------------------------------------------------*
FORM f_reverse_data CHANGING fc_subrc.
  DATA : ls_011    LIKE LINE OF gt_011,
         ls_012    LIKE LINE OF gt_012,
         ls_header LIKE LINE OF gt_header,
         ls_bkpf   LIKE LINE OF gt_bkpf.

  DATA : lv_budat TYPE bkpf-budat,
         lv_belnr TYPE bkpf-belnr.

  LOOP AT gt_011 INTO ls_011.
    READ TABLE gt_bkpf INTO ls_bkpf
                       WITH KEY bukrs = ls_011-bukrs
                                belnr = ls_011-belnr
                                gjahr = ls_011-gjahr.
    IF sy-subrc = 0.
      CALL FUNCTION 'CALL_FB08'
        EXPORTING
          i_bukrs      = pa_bukrs
          i_belnr      = ls_011-belnr
          i_gjahr      = ls_011-gjahr
          i_stgrd      = pa_stgrd
          i_budat      = ls_bkpf-budat
        IMPORTING
          e_budat      = lv_budat
        EXCEPTIONS
          not_possible = 1
          OTHERS       = 2.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = sy-msgv1
        IMPORTING
          output = lv_belnr.

      IF lv_belnr IS NOT INITIAL.
        ls_header-keterangan  = lv_belnr.
        CONDENSE ls_header-keterangan NO-GAPS.
        MODIFY gt_header FROM ls_header
                         TRANSPORTING keterangan
                         WHERE bukrs = ls_011-bukrs
                           AND vkbur = ls_011-vkbur
                           AND belnr = ls_011-belnr
                           AND gjahr = ls_011-gjahr.
        TRY.
            DELETE FROM zfidt011
                   WHERE bukrs = ls_011-bukrs
                     AND vkbur = ls_011-vkbur
                     AND webno = ls_011-webno
                     AND belnr = ls_011-belnr
                     AND gjahr = ls_011-gjahr.
          CATCH cx_sy_open_sql_db.
            fc_subrc = 4.
        ENDTRY.
      ELSE.
        fc_subrc = 4.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF fc_subrc = 0.
    LOOP AT gt_012 INTO ls_012.
      TRY.
          DELETE FROM zfidt012
                 WHERE bukrs = ls_012-bukrs
                   AND vkbur = ls_012-vkbur
                   AND webno = ls_012-webno
                   AND gjahr = ls_012-gjahr.
        CATCH cx_sy_open_sql_db.
          fc_subrc = 4.
      ENDTRY.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_REVERSE
*&---------------------------------------------------------------------*
FORM f_print_reverse .
  PERFORM f_alv TABLES gt_header gt_detail.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv  TABLES   ft_header ft_detail.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_hierarchy      TABLES  ft_header ft_detail.
  PERFORM f_build_layout_hierarchy        USING   d_layout.
  PERFORM f_build_keyinfo_hierarchy       USING   d_alv_keyinfo.
  PERFORM f_build_sortfield_hierarchy     USING   t_alv_isort[].
  PERFORM f_build_event                   TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print_hierarchy         USING   d_print.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_HEADER'
      i_tabname_item           = 'GT_DETAIL'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_header
      t_outtab_item            = ft_detail
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event  TABLES   ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
FORM f_build_event_exit .
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy  TABLES   ft_report1 ft_report2.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_HEADER':
    'BUKRS' 'ZFIDT011' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFIDT011' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNR' 'ZFIDT011' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFIDT011' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'ZFIDT011' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'XBLNR' 'ZFIDT011' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CLRST' 'ZFIDT011' 'CLRST' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'ZFIDT011' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DMBTR' 'ZFIDT011' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
    'USNAM' 'ZFIDT011' 'USNAM' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KETERANGAN' '' '' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_DETAIL':
    'KUNNR' 'ZFIDT012' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBEVA' 'ZFIDT012' 'VBEVA' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBEVL' 'ZFIDT012' 'VBEVL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBEVF' 'ZFIDT012' 'VBEVF' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'ZFIDT011' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DMBTR' 'ZFIDT011' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_DETAIL'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_keyinfo_hierarchy  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'BUKRS'.
  fu_keyinfo-item01   = 'BUKRS'.
  fu_keyinfo-header02 = 'VKBUR'.
  fu_keyinfo-item02   = 'VKBUR'.
  fu_keyinfo-header03 = 'BELNR'.
  fu_keyinfo-item03   = 'BELNR'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_sortfield_hierarchy  USING    fu_sort TYPE slis_t_sortinfo_alv.
  DATA: lt_sort TYPE slis_t_sortinfo_alv,
        ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'KUNNR'.
  ls_sort-tabname   = 'GT_DETAIL'.
  ls_sort-up        = 'X'.
*  ls_sort-subtot    = 'X'.
  APPEND ls_sort TO fu_sort.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'VBEVL'.
  ls_sort-tabname   = 'GT_DETAIL'.
  ls_sort-up        = 'X'.
*  ls_sort-subtot    = 'X'.
  APPEND ls_sort TO fu_sort.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_layout_hierarchy  USING    fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = ' '.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHKBX'.
  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_build_print_hierarchy  USING    fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data .
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING   VALUE(fu_types)
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
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GUI_MESSAGE
*&---------------------------------------------------------------------*
FORM f_gui_message  USING    fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA : fcode       TYPE TABLE OF sy-ucomm,
         lv_text(50).

  APPEND '&SIM' TO fcode.
  IF gv_post IS NOT INITIAL.
    APPEND '&POS' TO fcode.
  ENDIF.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  lv_text = |{ 'Reverse No. Transaksi :' } { pa_webno }|.
  SET TITLEBAR 'DYNTITLE' WITH lv_text.
ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_validasi_reverse_document  CHANGING fc_subrc.
  DATA : ls_t041ct TYPE t041ct,
         ls_bkpf   LIKE LINE OF gt_bkpf.

  DATA : lv_xabwd TYPE t041c-xabwd,
         lv_gjahr TYPE t001b-frye1,
         lv_monat TYPE t001b-frpe1.

  SELECT SINGLE *
    FROM t041ct
    INTO CORRESPONDING FIELDS OF ls_t041ct
    WHERE spras = sy-langu
      AND stgrd = pa_stgrd.
  IF sy-subrc <> 0.
    fc_subrc  = sy-subrc.
    MESSAGE s602(f0) WITH pa_stgrd DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT gt_bkpf INTO ls_bkpf.
      lv_gjahr  = ls_bkpf-budat(4).
      lv_monat  = ls_bkpf-budat+4(2).

      CALL FUNCTION 'FI_PERIOD_CHECK'
        EXPORTING
          i_bukrs = pa_bukrs
          i_gjahr = lv_gjahr
          i_koart = '+'
          i_monat = lv_monat
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc <> 0.
        fc_subrc  = sy-subrc.
        MESSAGE s201(f5) WITH lv_monat lv_gjahr DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_reverse_authorization  CHANGING fc_subrc.
  DATA : condtab    TYPE STANDARD TABLE OF hrcond,
         ls_condtab LIKE LINE OF condtab,
         dyn_tab    TYPE REF TO data,
         dyn_line   TYPE REF TO data.
  DATA : BEGIN OF where_clause OCCURS 1,
           line(72),
         END OF where_clause.

  DATA : lv_tname   TYPE ddobjname,
         lv_bname   TYPE usr01-bname,
         lv_setname TYPE setleaf-setname.

  FIELD-SYMBOLS : <ft_tab> TYPE STANDARD TABLE,
                  <fs_tab> TYPE any,
                  <fs>     TYPE any.

  lv_tname = 'USR01'.

  CASE pa_bukrs.
    WHEN '8020'.
      lv_setname = 'ZUSERHOPTT'.
    WHEN '8070'.
      lv_setname = 'ZUSERID_HO'.
  ENDCASE.

  IF lv_setname IS INITIAL.
    fc_subrc = 4.
  ELSE.
    SELECT *
      FROM setleaf
      INTO TABLE @DATA(lt_setleaf)
      WHERE setname = @lv_setname.

    LOOP AT lt_setleaf INTO DATA(ls_setleaf).
      ls_condtab-field = 'BNAME'.
      ls_condtab-low   = ls_setleaf-valfrom.
      ls_condtab-high  = ls_setleaf-valto.
      ls_condtab-opera = ls_setleaf-valoption.
      APPEND ls_condtab TO condtab.
    ENDLOOP.

    IF condtab[] IS NOT INITIAL.
      CALL FUNCTION 'RH_DYNAMIC_WHERE_BUILD'
        EXPORTING
          dbtable         = lv_tname
        TABLES
          condtab         = condtab
          where_clause    = where_clause
        EXCEPTIONS
          empty_condtab   = 1
          no_db_field     = 2
          unknown_db      = 3
          wrong_condition = 4
          OTHERS          = 5.

      LOOP AT where_clause.
        REPLACE ALL OCCURRENCES OF REGEX 'CP' IN where_clause-line WITH 'LIKE'.
        MODIFY where_clause.
      ENDLOOP.

      CREATE DATA dyn_tab TYPE STANDARD TABLE OF (lv_tname).
      ASSIGN dyn_tab->* TO <ft_tab>.
      CREATE DATA dyn_line LIKE LINE OF <ft_tab>.
      ASSIGN dyn_line->* TO <fs_tab>.

      SELECT *
        FROM (lv_tname)
        INTO CORRESPONDING FIELDS OF TABLE <ft_tab>
        WHERE (where_clause).

      fc_subrc = 4.

      LOOP AT <ft_tab> ASSIGNING <fs_tab>.
        ASSIGN COMPONENT 'BNAME' OF STRUCTURE <fs_tab> TO <fs>.
        lv_bname = <fs>.
        IF lv_bname = sy-uname.
          CLEAR fc_subrc.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_FI_DOC
*&---------------------------------------------------------------------*
FORM f_get_fi_doc  USING    fu_belnr fu_gjahr fu_kunnr fu_vbeln
                   CHANGING fc_belnr.
  DATA : ls_bseg    LIKE LINE OF gt_bseg.

  CLEAR : ls_bseg.
  READ TABLE gt_bseg INTO ls_bseg
                     WITH KEY belnr = fu_belnr
                              gjahr = fu_gjahr
                              kunnr = fu_kunnr
                              zuonr = fu_vbeln.
  IF sy-subrc = 0.
    fc_belnr = ls_bseg-belnr.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SOFF
*&---------------------------------------------------------------------*
FORM f_get_soff TABLES  fr_vkbur STRUCTURE bapi_rangesvkbur.
  DATA : lt_xoff  TYPE STANDARD TABLE OF zsmapping_soff,
         ls_xoff  TYPE zsmapping_soff,
         ls_soff  LIKE LINE OF gt_soff,
         lt_soff  TYPE STANDARD TABLE OF ty_soff,
         ls_vkbur TYPE bapi_rangesvkbur.

  SELECT *
    FROM zsmapping_soff
    INTO CORRESPONDING FIELDS OF TABLE lt_xoff
    WHERE vkorg  = pa_bukrs
      AND vkbur1 = pa_vkbur.

  LOOP AT lt_xoff INTO ls_xoff.
    ls_soff-vkorg = pa_bukrs.
    ls_soff-auart = ls_xoff-auart.
    ls_soff-vkbur = ls_xoff-vkbur1.
    APPEND ls_soff TO gt_soff.
    CLEAR ls_soff.
    ls_soff-vkorg = pa_bukrs.
    ls_soff-auart = ls_xoff-auart.
    ls_soff-vkbur = ls_xoff-vkbur2.
    APPEND ls_soff TO gt_soff.
    CLEAR ls_soff.
  ENDLOOP.

  SORT gt_soff BY auart vkorg vkbur.
  DELETE ADJACENT DUPLICATES FROM gt_soff COMPARING auart vkorg vkbur.

  lt_soff[] = gt_soff[].
  SORT lt_soff BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_soff COMPARING vkbur.
  LOOP AT lt_soff INTO ls_soff.
    ls_vkbur-low    = ls_soff-vkbur.
    ls_vkbur-sign   = 'I'.
    ls_vkbur-option = 'EQ'.
    APPEND ls_vkbur TO fr_vkbur.
    CLEAR ls_vkbur.
  ENDLOOP.

  IF lt_soff[] IS NOT INITIAL.
    SELECT *
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      FOR ALL ENTRIES IN lt_soff
      WHERE kunnr IN so_kunnr
        AND vkbur = lt_soff-vkbur.
  ENDIF.
ENDFORM.
