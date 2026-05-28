*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_frgkz LIKE LINE OF gr_frgkz,
         ls_statu LIKE LINE OF gr_statu,
         ls_badat LIKE LINE OF gr_badat.

  DATA : lv_datum   TYPE sy-datum.

  ls_frgkz-low    = ''.
  ls_frgkz-sign   = 'I'.
  ls_frgkz-option = 'EQ'.
  APPEND ls_frgkz TO gr_frgkz.
  CLEAR ls_frgkz.
  ls_frgkz-low    = '1'.
  ls_frgkz-sign   = 'I'.
  ls_frgkz-option = 'EQ'.
  APPEND ls_frgkz TO gr_frgkz.
  CLEAR ls_frgkz.
  ls_frgkz-low    = '2'.
  ls_frgkz-sign   = 'I'.
  ls_frgkz-option = 'EQ'.
  APPEND ls_frgkz TO gr_frgkz.
  CLEAR ls_frgkz.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = 0
      months    = 0
      signum    = '-'
      years     = 2
    IMPORTING
      calc_date = ls_badat-low.

  CONCATENATE ls_badat-low(4) '0101' INTO ls_badat-low.
  ls_badat-high   = sy-datum.
  ls_badat-sign   = 'I'.
  ls_badat-option = 'BT'.
  APPEND ls_badat TO gr_badat.
  CLEAR ls_badat.

  gv_mtart  = 'PROD'.
  gv_lpein  = 'D'.

  IF pa_prgrp IS NOT INITIAL.
    gs_head-text01  = 'Product group'.
  ENDIF.

  gs_rfqh-bstyp   = 'A'.

  SELECT *
    FROM t161t
    INTO CORRESPONDING FIELDS OF TABLE gt_t161t
    WHERE spras = sy-langu
      AND bstyp = gs_rfqh-bstyp.

  SELECT *
    FROM t161
    INTO CORRESPONDING FIELDS OF TABLE gt_t161
    WHERE bstyp = gs_rfqh-bstyp.

  SELECT *
    FROM t161u
    INTO CORRESPONDING FIELDS OF TABLE gt_t161u
    WHERE spras = sy-langu.

  gv_object   = 'ZRFQ'.
  gv_sub      = ''.
  gv_range    = '01'.
  gv_gjahr    = ''.
  gv_werks    = '1600'.
  gv_ekorg    = 'TNT'.
  gv_domname  = 'BANST'.
  gv_material = space.

  ls_statu-low    = 'A'.
  ls_statu-sign   = 'I'.
  ls_statu-option = 'EQ'.
  APPEND ls_statu TO gr_statu.
  CLEAR ls_statu.
  ls_statu-low    = 'N'.
  ls_statu-sign   = 'I'.
  ls_statu-option = 'EQ'.
  APPEND ls_statu TO gr_statu.
  CLEAR ls_statu.
  ls_statu-low    = 'B'.
  ls_statu-sign   = 'I'.
  ls_statu-option = 'EQ'.
  APPEND ls_statu TO gr_statu.
  CLEAR ls_statu.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = gv_domname
    TABLES
      values_tab      = value_tab
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.

  SELECT SINGLE *
    FROM t026z
    INTO CORRESPONDING FIELDS OF gs_t026z
    WHERE ekorg = gv_ekorg
      AND ekgrp = pa_ekgrp.

  PERFORM f_date_holiday USING 4 'X'
                         CHANGING gs_rfqh-bwbdt.
  PERFORM f_date_holiday USING 8 'X'
                         CHANGING gs_rfqh-angdt.
  PERFORM f_date_holiday USING 1 ''
                         CHANGING gs_rfqh-kdatb.
  PERFORM f_date_holiday USING 14 'X'
                         CHANGING gs_rfqh-kdate.
  PERFORM f_date_holiday USING 60 'X'
                         CHANGING gs_rfqh-bnddt.

*  gs_rfqh-bwbdt = sy-datum + 3.
*  gs_rfqh-angdt = sy-datum + 6.
*  gs_rfqh-kdatb = sy-datum.
*  gs_rfqh-kdate = sy-datum + 14.
*  gs_rfqh-bnddt = sy-datum + 60.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE gt_005
    WHERE tcode = 'ZMME010'
      AND ekgrp = pa_ekgrp.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_ekgrp IS INITIAL.
    PERFORM f_error_message USING 'PEK' ''.
  ENDIF.
  IF pa_prgrp IS INITIAL.
    PERFORM f_error_message USING 'PPR' ''.
  ENDIF.
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
FORM f_modify_screen  USING    fu_group1 fu_group2 fu_active fu_input
                               fu_invisible fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-length  = fu_length.
        ENDIF.
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
  DATA : lt_pgmi  TYPE STANDARD TABLE OF pgmi,
         lt_eket  TYPE STANDARD TABLE OF eket,
         lt_ekko  TYPE STANDARD TABLE OF ekko,
         lt_xeket TYPE STANDARD TABLE OF eket,
         ls_xeket LIKE LINE OF lt_xeket,
         ls_mara  LIKE LINE OF gt_mara,
         ls_ekko  LIKE LINE OF lt_ekko,
         ls_eket  LIKE LINE OF lt_eket,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  SELECT *
    FROM pgmi
    INTO CORRESPONDING FIELDS OF TABLE gt_pgmi
    WHERE pgtyp = space
      AND prgrp = pa_prgrp
      AND werks = gv_werks.

  lt_pgmi[] = gt_pgmi[].
  SORT lt_pgmi BY nrmit wemit.
  DELETE ADJACENT DUPLICATES FROM lt_pgmi COMPARING nrmit wemit.

  IF lt_pgmi[] IS NOT INITIAL.
    lv_subrc = 4.

    WHILE lv_subrc IS NOT INITIAL.
      ADD 1 TO lv_count.
      PERFORM f_get_material TABLES lt_pgmi
                             USING 'X'
                             CHANGING lv_subrc.
      IF lv_count > 10.
        CLEAR lv_subrc.
      ENDIF.
    ENDWHILE.
  ENDIF.

  SORT gt_mara BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr werks.
  IF pa_matnr IS NOT INITIAL.
    DELETE gt_mara WHERE matnr <> pa_matnr.
  ENDIF.

  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND spras = sy-langu.

    SELECT *
      FROM eban
      INTO CORRESPONDING FIELDS OF TABLE gt_eban
      FOR ALL ENTRIES IN gt_mara
      WHERE ekgrp = pa_ekgrp
        AND matnr = gt_mara-matnr
        AND werks = gt_mara-werks
        AND loekz = space
        AND statu IN gr_statu
        AND ebakz = space
        AND frgkz IN gr_frgkz
        AND badat IN gr_badat.

    IF gt_eban[] IS NOT INITIAL.
      SELECT *
        FROM eket AS a JOIN ekpo AS b ON a~ebeln = b~ebeln AND
                                         a~ebelp = b~ebelp
        INTO CORRESPONDING FIELDS OF TABLE lt_eket
        FOR ALL ENTRIES IN gt_eban
        WHERE a~banfn = gt_eban-banfn
          AND a~bnfpo = gt_eban-bnfpo
          AND loekz EQ space.

      lt_xeket[] = lt_eket[].
      SORT lt_xeket BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_xeket COMPARING ebeln.
      IF lt_xeket[] IS NOT INITIAL.
        SELECT *
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE lt_ekko
          FOR ALL ENTRIES IN lt_xeket
          WHERE ebeln = lt_xeket-ebeln.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT lt_ekko INTO ls_ekko.
    LOOP AT lt_eket INTO ls_eket WHERE ebeln = ls_ekko-ebeln.
      PERFORM f_check_pr USING ls_ekko-lifnr ls_eket-banfn ls_eket-bnfpo ls_ekko-submi.
    ENDLOOP.
  ENDLOOP.
  SORT gt_prcheck BY lifnr banfn bnfpo submi.
  DELETE ADJACENT DUPLICATES FROM gt_prcheck COMPARING lifnr banfn bnfpo submi.

  SORT lt_ekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekko COMPARING lifnr.
  IF lt_ekko[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FOR ALL ENTRIES IN lt_ekko
      WHERE lifnr = lt_ekko-lifnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_mara     LIKE LINE OF gt_mara,
         ls_out      LIKE LINE OF gt_out,
         ls_makt     LIKE LINE OF gt_makt,
         ls_eban     LIKE LINE OF gt_eban,
         ls_value    LIKE LINE OF value_tab,
         ls_material LIKE LINE OF gt_material,
         ls_t161u    LIKE LINE OF gt_t161u.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_menge   TYPE eban-menge.

  LOOP AT gt_mara INTO ls_mara.
    ls_out-werks  = ls_mara-werks.
    ls_out-matnr  = ls_mara-matnr.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_mara-matnr.
    IF sy-subrc = 0.
      ls_out-maktx  = ls_makt-maktx.
    ENDIF.

    CLEAR : ls_eban, lv_menge.
    LOOP AT gt_eban INTO ls_eban WHERE matnr = ls_mara-matnr
                                   AND werks = ls_mara-werks.
      ls_out-ekgrp  = ls_eban-ekgrp.
      IF ls_eban-ekorg IS INITIAL.
        ls_out-ekorg  = gs_t026z-ekorg.
      ELSE.
        IF ls_eban-ekorg = gs_t026z-ekorg AND
          ls_eban-ekgrp = gs_t026z-ekgrp.
          ls_out-ekorg  = ls_eban-ekorg.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      CLEAR ls_t161u.
      READ TABLE gt_t161u INTO ls_t161u
                          WITH KEY frgkz = ls_eban-frgkz.
      IF sy-subrc = 0.
        ls_out-fkztx  = ls_t161u-fkztx.
      ENDIF.

      ls_out-banfn  = ls_eban-banfn.
      ls_out-bnfpo  = ls_eban-bnfpo.

      ls_out-menge  = ls_eban-menge - ls_eban-bsmng.
      ls_out-meins  = ls_eban-meins.
      ls_out-lfdat  = ls_eban-lfdat.

*      IF ls_eban-statu = 'B' AND
*        ls_eban-bsmng = 0.
*        ls_eban-statu = 'N'.
*      ENDIF.

      READ TABLE value_tab INTO ls_value
                           WITH KEY domvalue_l = ls_eban-statu.
      IF sy-subrc = 0.
        ls_out-statu  = ls_value-ddtext.
      ENDIF.

      CLEAR ls_material.
      READ TABLE gt_material INTO ls_material
                             WITH KEY matnr = ls_mara-matnr.
      IF sy-subrc = 0.
        ls_out-icon = icon_locked.
      ENDIF.

      IF ls_out-lfdat < sy-datum OR
        ls_out-icon = icon_locked.
        ls_stylerow-fieldname = 'MARK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_out-style.
      ENDIF.
      APPEND ls_out TO gt_out.
      CLEAR ls_out-style[].
    ENDLOOP.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ELSE.
    MESSAGE s000(zab) WITH 'No data selected' DISPLAY LIKE 'E'.
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

*    CALL METHOD g_splitter->set_row_height
*      EXPORTING
*        id     = 1
*        height = 10.
  ENDIF.

  IF pa_matnr IS NOT INITIAL.
    PERFORM f_modify_screen USING : 'TX1' '' '0' '' '' ''.
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

  CASE sy-dynnr.
    WHEN '0101'.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.

    WHEN '0102'.
      APPEND 'OTHER' TO fcode.
      APPEND '&CANCEL' TO fcode.
      SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.

    WHEN '0103'.
      APPEND '&ALL' TO fcode.
      APPEND '&SAL' TO fcode.
      APPEND '&POS' TO fcode.
      APPEND '&OTHER' TO fcode.
      APPEND '&LIST' TO fcode.
      SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
      SET TITLEBAR 'SELECT'.
  ENDCASE.

ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  PERFORM f_clear_data.
  CALL FUNCTION 'DEQUEUE_ALL'.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c,
         lv_row   TYPE lvc_s_roid.

  DATA : ls_out      LIKE LINE OF gt_out,
         ls_rfqd     LIKE LINE OF gt_rfqd,
         lt_bapiret2 TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2 LIKE LINE OF lt_bapiret2,
         ls_return   LIKE LINE OF gt_return,
         lt_fidx     TYPE lvc_t_fidx,
         ls_fidx     TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.

  DATA : lv_lifnr     TYPE lfa1-lifnr,
         lv_index     TYPE sy-index,
         lv_field(30),
         lv_title(50),
         lv_line      TYPE i,
         lv_subrc     TYPE sy-subrc.

  DATA : et_filter           TYPE slis_t_filter_alv,
         et_filtered_entries TYPE slis_t_filtered_entries.

  lv_ucomm  = ok_code.
  CLEAR : ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_select USING 'X'.
          ENDIF.
        WHEN '0102'.
          PERFORM f_select USING 'X'.
      ENDCASE.

    WHEN '&SAL'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_select USING ''.
          ENDIF.
        WHEN '0102'.
          PERFORM f_select USING ''.
      ENDCASE.

    WHEN '&BID'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        READ TABLE gt_out INTO ls_out
                          WITH KEY mark = 'X'.
        IF sy-subrc = 0.
          gs_rfqh-bstyp   = 'A'.
          gs_rfqh-asart   = 'AN'.
          gs_rfqh-anfdt   = sy-datum.
          gs_rfqh-ekgrp   = pa_ekgrp.
          CALL SCREEN 102.
        ELSE.
          MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN '&POS'.
      CLEAR gv_subrc.
      IF gt_rfqd[] IS NOT INITIAL.
        DESCRIBE TABLE gt_rfqd LINES lv_line.
        IF lv_line = 1.
          READ TABLE gt_rfqd INTO ls_rfqd INDEX 1.
          IF ls_rfqd IS INITIAL.
            gv_subrc = 5.
            MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gv_subrc = 0.
        PERFORM f_required_entries CHANGING gv_subrc.
      ENDIF.

      IF gv_subrc = 0.
        PERFORM f_assign_bidder.
        IF gt_mail[] IS NOT INITIAL.
          PERFORM f_send_email.
        ENDIF.
*        CLEAR gv_trtyp.
      ENDIF.

    WHEN '&PICK'.
      GET CURSOR FIELD lv_field LINE lv_line.
      lv_index = tc_rfq-top_line + lv_line - 1.
      CASE lv_field.
        WHEN 'GS_RFQD-ANFNR'.
          READ TABLE gt_rfqd INTO ls_rfqd INDEX lv_index.
          IF sy-subrc = 0.
            IF ls_rfqd-anfnr IS NOT INITIAL.
              SET PARAMETER ID 'ANF' FIELD ls_rfqd-anfnr.
              CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN '&LIST'.
      PERFORM f_prepare_listinfo USING 'EKKO' '' '' gs_rfqh-submi
                                 CHANGING lv_title.
      PERFORM f_print_listinfo USING lv_title.

    WHEN '&OTHER'.
      PERFORM f_select_others_document.

    WHEN 'OTHER'.
      gv_trtyp = 'V'.
      PERFORM f_get_rfq.
      LEAVE TO SCREEN 0.

    WHEN '&STAT'.
      GET CURSOR FIELD lv_field LINE lv_line.
      lv_index = tc_rfq-top_line + lv_line - 1.
      READ TABLE gt_rfqd INTO ls_rfqd INDEX lv_index.
      IF sy-subrc = 0.
        IF ls_rfqd-icon = icon_led_red.
          LOOP AT gt_return INTO ls_return WHERE lifnr = ls_rfqd-lifnr.
            MOVE-CORRESPONDING ls_return TO ls_bapiret2.
            APPEND ls_bapiret2 TO lt_bapiret2.
            CLEAR ls_bapiret2.
          ENDLOOP.
        ENDIF.
      ENDIF.
      IF lt_bapiret2[] IS NOT INITIAL.
        DESCRIBE TABLE lt_bapiret2 LINES lv_line.
        IF lv_line = 1.
          APPEND INITIAL LINE TO lt_bapiret2.
        ENDIF.
        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            i_bapiret2_tab = lt_bapiret2.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'. " OR '&UMC' OR '&SUM' OR '%PC'.
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
*      IF gs_head-matnr IS NOT INITIAL.
*        PERFORM f_data_selection USING gs_head-matnr.
*        PERFORM f_alv_refresh USING 'X'.
*      ELSE.
      CLEAR gv_subrc.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
*      ENDIF.
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
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].

    IF gt_xout[] IS INITIAL.
      gt_xout[] = gt_out[].
    ENDIF.
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

  PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'EKGRP' '' '' '' '' '' '' 'EKGRP' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'EKORG' '' '' '' '' '' '' 'EKORG' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'WERKS' '' '' '' '' '' '' 'WERKS' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'BANFN' '' '' '' '' '' '' 'BANFN' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'BNFPO' '' '' '' '' '' '' 'BNFPO' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EBAN' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MEINS' '' '' '' '' '' '' 'MEINS' 'EBAN' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'LFDAT' '' '' '' '' '' '' 'LFDAT' 'EBAN' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'STATU' '' '' '' '' '' '' 'DDTEXT' 'DD07V' 'Status' '' '' '' '' ''
    '' '' '' '' '' '',
    'FKZTX' '' '' '' '' '' '' 'FKZTX' 'T161U' 'Rel.Indicator.PR' '' ''
    '' '' '' '' '' '' '' '' ''.
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
         ls_filter   LIKE LINE OF gt_filter,
         lv_tabix    TYPE sy-tabix.

  DATA : ls_out  LIKE LINE OF gt_out,
         ls_xout LIKE LINE OF gt_xout,
         ls_rfqd LIKE LINE OF gt_rfqd.

  CASE sy-dynnr.
    WHEN '0101'.
      CALL METHOD g_tabgrid->get_frontend_fieldcatalog
        IMPORTING
          et_fieldcatalog = ls_fieldcatalog[].

      READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
      IF sy-subrc = 0.
        IF ls_fieldcatalog-edit IS NOT INITIAL.
          LOOP AT gt_out INTO ls_out.
*            lv_tabix  = sy-tabix.
            READ TABLE ls_out-style INTO ls_stylerow
                                    WITH KEY fieldname = 'MARK'.
            IF sy-subrc = 0 AND
                ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
              CONTINUE.
            ENDIF.
            ls_out-mark = fu_check.

            IF fu_check IS NOT INITIAL.
              CLEAR : ls_xout, lv_tabix.
              READ TABLE gt_xout INTO ls_xout
                                 WITH KEY banfn = ls_out-banfn
                                          bnfpo = ls_out-bnfpo.
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

            MODIFY gt_out FROM ls_out.
            CLEAR ls_out.
          ENDLOOP.
        ENDIF.
        PERFORM f_alv_refresh USING 'X'.
      ENDIF.

    WHEN '0102'.
      CLEAR : gt_xrfqd[].
      LOOP AT gt_rfqd INTO ls_rfqd.
*        IF ls_rfqd-check IS NOT INITIAL AND
        IF ls_rfqd-style IS NOT INITIAL AND
          ls_rfqd-anfnr IS INITIAL.
          PERFORM f_modify_check USING :
            '' '' ls_rfqd-frei ls_rfqd-lifnr ls_rfqd-matnr '' fu_check.
          CLEAR ls_rfqd.
        ENDIF.
      ENDLOOP.
      gt_xrfqd[] = gt_rfqd[].
  ENDCASE.
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
*&      Form  F_GET_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_material  TABLES   ft_pgmi   STRUCTURE pgmi
                     USING    fu_add
                     CHANGING fc_subrc.
  DATA : lt_pgmi  TYPE STANDARD TABLE OF pgmi,
         lt_mara  TYPE STANDARD TABLE OF ty_mara,
         ls_pgmi  LIKE LINE OF lt_pgmi,
         ls_mara  LIKE LINE OF gt_mara,
         ls_matnr LIKE LINE OF gt_matnr.

  lt_pgmi[] = ft_pgmi[].

  IF lt_pgmi[] IS NOT INITIAL.
    SELECT marc~matnr marc~werks mara~mtart mara~meins mara~mprof mara~qmpur
      FROM marc JOIN mara ON marc~matnr = mara~matnr
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_pgmi
      WHERE marc~matnr = lt_pgmi-nrmit
        AND marc~werks = lt_pgmi-wemit.
    IF sy-subrc = 0.
      IF fu_add IS NOT INITIAL.
        APPEND LINES OF lt_mara TO gt_mara.
      ELSE.
        LOOP AT lt_mara INTO ls_mara WHERE mtart <> gv_mtart.
          ls_matnr-low    = ls_mara-matnr.
          ls_matnr-sign   = 'I'.
          ls_matnr-option = 'EQ'.
          APPEND ls_matnr TO gt_matnr.
          CLEAR ls_matnr.
        ENDLOOP.
      ENDIF.
      CLEAR ft_pgmi[].
      IF lt_pgmi[] IS NOT INITIAL.
        SELECT *
          FROM pgmi
          INTO CORRESPONDING FIELDS OF TABLE ft_pgmi
          FOR ALL ENTRIES IN lt_pgmi
          WHERE pgtyp = space
            AND prgrp = lt_pgmi-nrmit
            AND werks = lt_pgmi-wemit.
        IF sy-subrc <> 0.
          CLEAR fc_subrc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_PRGRP
*&---------------------------------------------------------------------*
FORM f_value_prgrp .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lt_xmakt TYPE STANDARD TABLE OF ty_makt,
         lt_mara  TYPE STANDARD TABLE OF ty_mara,
         ls_mara  LIKE LINE OF gt_mara,
         ls_xmakt LIKE LINE OF lt_xmakt,
         ls_makt  LIKE LINE OF gt_makt,
         lv_subrc TYPE sy-subrc.

  lt_mara[] = gt_mara[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  DELETE lt_mara WHERE mtart <> gv_mtart.
  LOOP AT lt_mara INTO ls_mara.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_mara-matnr.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_makt TO ls_xmakt.
      APPEND ls_xmakt TO lt_xmakt.
    ENDIF.
  ENDLOOP.
  ASSIGN lt_xmakt[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_select USING ''.

  PERFORM f_value_request TABLES return_tab
                          USING 'MATNR' 'GS_HEAD-PRGRP'
                          CHANGING lv_subrc.

  READ TABLE return_tab INTO ls_return INDEX 1.

ENDFORM.                    " F_VALUE_PRGRP

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_NRMIT
*&---------------------------------------------------------------------*
FORM f_value_nrmit .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lt_xmakt TYPE STANDARD TABLE OF ty_makt,
         lt_mara  TYPE STANDARD TABLE OF ty_mara,
         ls_mara  LIKE LINE OF gt_mara,
         ls_xmakt LIKE LINE OF lt_xmakt,
         ls_makt  LIKE LINE OF gt_makt,
         ls_out   LIKE LINE OF gt_out.

  DATA : lv_subrc       TYPE sy-subrc.

  lt_mara[] = gt_mara[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  DELETE lt_mara WHERE mtart = gv_mtart.
  LOOP AT lt_mara INTO ls_mara.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_mara-matnr.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_makt TO ls_xmakt.
      APPEND ls_xmakt TO lt_xmakt.
    ENDIF.
  ENDLOOP.
  ASSIGN lt_xmakt[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_select USING ''.

  PERFORM f_value_request TABLES return_tab
                          USING 'MATNR' 'GS_HEAD-NRMIT'
                          CHANGING lv_subrc.

  READ TABLE return_tab INTO ls_return INDEX 1.
  LOOP AT gt_out INTO ls_out WHERE matnr = ls_return-fieldval.
    ls_out-mark = 'X'.
    MODIFY gt_out FROM ls_out TRANSPORTING mark.
  ENDLOOP.
  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_VALUE_NRMIT

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
ENDFORM.                    " F_VALUE_REQUEST

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
*&      Form  F_VALUE_SELECTION
*&---------------------------------------------------------------------*
FORM f_value_selection .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lt_xmakt TYPE STANDARD TABLE OF ty_makt,
         lt_mara  TYPE STANDARD TABLE OF ty_mara,
         ls_mara  LIKE LINE OF gt_mara,
         ls_xmakt LIKE LINE OF lt_xmakt,
         ls_makt  LIKE LINE OF gt_makt,
         ls_eban  LIKE LINE OF gt_eban.

  DATA : lv_subrc       TYPE sy-subrc.

  lt_mara[] = gt_mara[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.

  IF pa_prgrp IS NOT INITIAL.
    DELETE lt_mara WHERE mtart <> gv_mtart.
    LOOP AT lt_mara INTO ls_mara.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr = ls_mara-matnr.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_makt TO ls_xmakt.
        APPEND ls_xmakt TO lt_xmakt.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF pa_matnr IS NOT INITIAL.
    DELETE lt_mara WHERE mtart = gv_mtart.
    LOOP AT lt_mara INTO ls_mara.
      READ TABLE gt_eban INTO ls_eban
                         WITH KEY matnr = ls_mara-matnr.
      IF sy-subrc = 0.
        READ TABLE gt_makt INTO ls_makt
                           WITH KEY matnr = ls_mara-matnr.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_makt TO ls_xmakt.
          APPEND ls_xmakt TO lt_xmakt.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_xmakt[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_select USING ''.

  PERFORM f_value_request TABLES return_tab
                          USING 'MATNR' 'GS_HEAD-MATNR'
                          CHANGING lv_subrc.

  READ TABLE return_tab INTO ls_return INDEX 1.
  IF sy-subrc = 0.
    PERFORM f_data_selection USING ls_return-fieldval.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
  CLEAR gt_matnr[].
ENDFORM.                    " F_VALUE_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_BIDDER
*&---------------------------------------------------------------------*
FORM f_assign_bidder .
  DATA : lt_xrfqd TYPE STANDARD TABLE OF ty_rfq,
         lt_yrfqd TYPE STANDARD TABLE OF ty_rfq,
         ls_yrfqd LIKE LINE OF lt_yrfqd,
         lt_xout  TYPE STANDARD TABLE OF ty_out,
         lt_out   TYPE STANDARD TABLE OF ty_out.

  DATA : lt_quoi  TYPE STANDARD TABLE OF bs01mmitem,
         lt_quois TYPE STANDARD TABLE OF bs01mmschedule,
         ls_quoh  TYPE bs01mmhead,
         ls_quois LIKE LINE OF lt_quois,
         lv_flag,
         lv_ebelp TYPE ekpo-ebelp,
         lv_pincr TYPE t161-pincr,
         ls_t161  LIKE LINE OF gt_t161.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  lt_xout[] = lt_out[].
  DELETE lt_xout WHERE werks <> gs_rfqh-werks.
  SORT lt_xout BY matnr.

  CLEAR ls_t161.
  READ TABLE gt_t161 INTO ls_t161
                     WITH KEY bstyp = gs_rfqh-bstyp
                              bsart = gs_rfqh-asart.
  IF sy-subrc = 0.
    lv_pincr  = ls_t161-pincr.
  ENDIF.

  lt_xrfqd[] = gt_rfqd[].
  DELETE lt_xrfqd WHERE mark IS INITIAL.
  lt_yrfqd[] = lt_xrfqd[].

  IF gv_material IS INITIAL.
    SORT lt_yrfqd BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_yrfqd COMPARING lifnr.
  ELSE.
    SORT lt_yrfqd BY lifnr bmatn.
    DELETE ADJACENT DUPLICATES FROM lt_yrfqd COMPARING lifnr bmatn.
  ENDIF.

  IF lt_yrfqd[] IS NOT INITIAL.
    LOOP AT lt_yrfqd INTO ls_yrfqd.
      ls_quoh-created_by    = sy-uname.
      ls_quoh-doc_cat       = gs_rfqh-bstyp.
      ls_quoh-doc_type      = gs_rfqh-asart.
      PERFORM f_get_bukrs CHANGING ls_quoh-co_code.
      ls_quoh-vendor        = ls_yrfqd-lifnr.
      ls_quoh-purch_org     = gs_rfqh-ekorg.
      ls_quoh-pur_group     = gs_rfqh-ekgrp.
      ls_quoh-quot_date     = gs_rfqh-anfdt.
      ls_quoh-quot_dead     = gs_rfqh-angdt.
      ls_quoh-applic_by     = gs_rfqh-bwbdt.
      ls_quoh-currency      = ls_yrfqd-waers.
      ls_quoh-coll_no       = gs_rfqh-submi.
      ls_quoh-vper_start    = gs_rfqh-kdatb.
      ls_quoh-vper_end      = gs_rfqh-kdate.
      ls_quoh-bindg_per     = gs_rfqh-bnddt.

      CLEAR lv_ebelp.
      IF gv_material IS INITIAL.
        PERFORM f_multi_material TABLES lt_out lt_xrfqd lt_xout
                                        lt_quoi lt_quois
                                 USING ls_yrfqd-lifnr lv_pincr gs_rfqh-submi
                                 CHANGING lv_ebelp.
      ELSE.
        PERFORM f_per_material TABLES lt_out lt_xrfqd lt_xout
                                      lt_quoi lt_quois
                               USING ls_yrfqd-lifnr ls_yrfqd-bmatn
                                     lv_pincr gs_rfqh-submi
                               CHANGING lv_ebelp.
      ENDIF.

      IF lt_quoi[] IS NOT INITIAL.
        DELETE gt_return WHERE lifnr = ls_yrfqd-lifnr
                           AND matnr = ls_yrfqd-bmatn.

        PERFORM f_process_assign_bidder TABLES lt_quoi lt_quois
                                        USING  ls_quoh
                                        CHANGING ls_yrfqd-anfnr.
        IF ls_yrfqd-anfnr IS NOT INITIAL.
          CLEAR : ls_yrfqd-mark.
          lv_flag          = 'X'.
          ls_yrfqd-icon    = icon_led_green.
          LOOP AT lt_quois INTO ls_quois.
            PERFORM f_check_pr USING ls_quoh-vendor ls_quois-preq_no ls_quois-preq_item
                                     ls_quoh-coll_no.
          ENDLOOP.
          SORT gt_prcheck BY lifnr banfn bnfpo submi.
          DELETE ADJACENT DUPLICATES FROM gt_prcheck COMPARING lifnr banfn bnfpo submi.

          PERFORM f_dequeue_pr TABLES  lt_quois.

          PERFORM f_prepare_send_email TABLES lt_xrfqd
                                       USING ls_yrfqd-lifnr gs_rfqh-submi ls_yrfqd-anfnr.
        ELSE.
          CLEAR : ls_yrfqd-mark.
          ls_yrfqd-icon    = icon_led_red.
        ENDIF.

        IF gv_material IS INITIAL.
          MODIFY gt_rfqd FROM ls_yrfqd
                         TRANSPORTING anfnr mark icon
                         WHERE lifnr = ls_yrfqd-lifnr
                           AND mark  = 'X'
                           AND style = 'X'
                           AND frei  >= gs_rfqh-frei.
        ELSE.
          MODIFY gt_rfqd FROM ls_yrfqd
                         TRANSPORTING anfnr mark icon
                         WHERE lifnr = ls_yrfqd-lifnr
                           AND bmatn = ls_yrfqd-bmatn
                           AND mark  = 'X'
                           AND style = 'X'
                           AND frei  >= gs_rfqh-frei.
        ENDIF.
      ENDIF.

      CLEAR : lt_quoi[], lt_quois[], ls_quoh, ls_yrfqd.
    ENDLOOP.
  ELSE.
    MESSAGE s000(zab) WITH 'No Data to be processed' DISPLAY LIKE 'E'.
  ENDIF.

  IF gv_trtyp <> 'V'.
    IF lv_flag IS NOT INITIAL.
      PERFORM f_get_next_number USING 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ASSIGN_BIDDER

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  DATA : lt_out       TYPE STANDARD TABLE OF ty_out,
         ls_out       LIKE LINE OF lt_out,
         ls_rfqd      LIKE LINE OF gt_rfqd,
         lr_datum     TYPE RANGE OF sy-datum,
         ls_datum     LIKE LINE OF lr_datum,
         lv_subrc     TYPE sy-subrc,
         lv_lifnr     TYPE lfa1-lifnr,
         lv_matnr     TYPE mara-matnr,
         lv_mess(100).

  CASE sy-dynnr.
    WHEN '0103'.
      gs_rfqh-newmi   = gs_rfqh-submi.
  ENDCASE.

  IF gs_rfqh-werks IS NOT INITIAL.
    lt_out[]  = gt_out[].
    DELETE lt_out WHERE mark IS INITIAL.
*    DELETE lt_out WHERE werks <> gs_rfqh-werks.
    READ TABLE lt_out INTO ls_out INDEX 1.
    IF sy-subrc = 0.
      gs_rfqh-ekorg   = ls_out-ekorg.
*    ELSE.
*      MESSAGE s000(zab) WITH 'Error Plant selection'
*      DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  IF gv_trtyp <> 'V'.
    CLEAR lv_subrc.
    IF gs_rfqh-bwbdt IS NOT INITIAL.
      PERFORM f_validate_datum USING gs_rfqh-bwbdt '1st Submission Date must greather than'
                               CHANGING lv_subrc.
      IF lv_subrc <> 0.
        CLEAR : lt_out[], gt_rfqd[].
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      IF gs_rfqh-angdt IS NOT INITIAL.
        PERFORM f_validate_datum USING gs_rfqh-angdt '2st Submission Date must greather than'
                                 CHANGING lv_subrc.
        IF lv_subrc <> 0.
          CLEAR : lt_out[], gt_rfqd[].
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      IF gs_rfqh-kdatb IS NOT INITIAL.
        PERFORM f_validate_datum USING gs_rfqh-kdatb 'Validity Start must greather than'
                                 CHANGING lv_subrc.
        IF lv_subrc <> 0.
          CLEAR : lt_out[], gt_rfqd[].
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      IF gs_rfqh-kdate IS NOT INITIAL.
        PERFORM f_validate_datum USING gs_rfqh-kdate 'Validity End must greather than'
                                 CHANGING lv_subrc.
        IF lv_subrc <> 0.
          CLEAR : lt_out[], gt_rfqd[].
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      IF gs_rfqh-kdate < gs_rfqh-kdatb.
        CLEAR : lt_out[], gt_rfqd[].
        MESSAGE s000(zab) WITH 'Validity End must greather than Validity Start'
        DISPLAY LIKE 'E'.
      ELSE.
        IF lt_out[] IS NOT INITIAL.
          SORT lt_out BY lfdat DESCENDING.
          READ TABLE lt_out INTO ls_out INDEX 1.
          IF gs_rfqh-kdate > ls_out-lfdat.
            CLEAR : lt_out[], gt_rfqd[].
            MESSAGE s000(zab) WITH 'Validity End must Less than or Equal Delv.Date'
            DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gs_rfqh-kdatb IS NOT INITIAL AND
        gs_rfqh-kdate IS NOT INITIAL.
        ls_datum-low    = gs_rfqh-kdatb.
        ls_datum-high   = gs_rfqh-kdate.
        ls_datum-sign   = 'E'.
        ls_datum-option = 'BT'.
        APPEND ls_datum TO lr_datum.
        CLEAR ls_datum.
        IF gs_rfqh-bwbdt IS NOT INITIAL.
          IF gs_rfqh-bwbdt IN lr_datum.
            CLEAR : lt_out[], gt_rfqd[].
            MESSAGE s000(zab) WITH '1st Submission Date must between Validity Start & End'
            DISPLAY LIKE 'E'.
          ELSEIF gs_rfqh-angdt < gs_rfqh-bwbdt.
            CLEAR : lt_out[], gt_rfqd[].
            MESSAGE s000(zab) WITH '2nd Submission Date must greater than 1st'
            DISPLAY LIKE 'E'.
          ELSEIF gs_rfqh-angdt IS NOT INITIAL.
            IF gs_rfqh-angdt IN lr_datum.
              CLEAR : lt_out[], gt_rfqd[].
              MESSAGE s000(zab) WITH '2nd Submission Date must between Validity Start & End'
              DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ELSEIF gs_rfqh-angdt IS NOT INITIAL.
          IF gs_rfqh-angdt IN lr_datum.
            CLEAR : lt_out[], gt_rfqd[].
            MESSAGE s000(zab) WITH '2nd Submission Date must between Validity Start & End'
            DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lt_out[] IS NOT INITIAL.
    IF gs_rfqh-bnddt < gs_rfqh-kdate.
      lv_subrc = 4.
      CLEAR : lt_out[], gt_rfqd[].
      MESSAGE s000(zab) WITH 'Binding date must greather than Validity End'
      DISPLAY LIKE 'E'.
    ENDIF.

    IF lv_subrc = 0.
      IF gs_rfqh-kdate IS NOT INITIAL.
        gs_rfqh-frei = gs_rfqh-kdate + 7.
        READ TABLE gt_rfqd INTO ls_rfqd INDEX 1.
        IF sy-subrc = 0.
          IF gs_rfqh-werks <> ls_rfqd-werks.
            PERFORM f_get_vendor CHANGING lv_subrc.
          ENDIF.
        ELSE.
          PERFORM f_get_vendor CHANGING lv_subrc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE lv_subrc.
    WHEN 6.
      CLEAR : lt_out[], gt_rfqd[].
      MESSAGE s000(zab) WITH 'QM-info record does not exist'
      DISPLAY LIKE 'E'.
  ENDCASE.

  IF gt_rfqd[] IS INITIAL.
    APPEND INITIAL LINE TO gt_rfqd.
  ELSE.
    IF sy-dynnr = '0102'.
      LOOP AT gt_rfqd INTO ls_rfqd.
        IF gs_rfqh-kdate IS NOT INITIAL.
          ls_rfqd-style = 'X'.
        ENDIF.
        MODIFY gt_rfqd FROM ls_rfqd.
        CLEAR ls_rfqd.
      ENDLOOP.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE gt_rfqd LINES fill.
  tc_rfq-lines = fill.

  IF gv_trtyp <> 'V'.
    PERFORM f_get_next_number USING ''.
  ENDIF.

  IF gs_rfqh-kdate IS INITIAL.
    PERFORM f_modify_screen USING : '' 'VEN' '0' '' '' ''.
  ENDIF.

  IF gv_trtyp = 'V'.
    PERFORM f_modify_screen USING : '' 'HED' '' '0' '' ''.
  ENDIF.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_AFTER_INPUT
*&---------------------------------------------------------------------*
FORM f_process_after_input .

ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR
*&---------------------------------------------------------------------*
FORM f_get_vendor CHANGING fc_subrc.
  DATA : lt_rfqd  TYPE STANDARD TABLE OF ty_rfq,
         lt_xrfqd TYPE STANDARD TABLE OF ty_rfq,
         lt_out   TYPE STANDARD TABLE OF ty_out,
         lt_xpir  TYPE STANDARD TABLE OF ty_pir,
         lt_ypir  TYPE STANDARD TABLE OF ty_pir,
         lt_qinf  TYPE STANDARD TABLE OF qinf,
         lt_xqinf TYPE STANDARD TABLE OF qinf,
         ls_out   LIKE LINE OF lt_out,
         ls_pir   LIKE LINE OF gt_pir,
         ls_xpir  LIKE LINE OF lt_xpir,
         ls_ypir  LIKE LINE OF lt_ypir,
         ls_qinf  LIKE LINE OF lt_qinf,
         ls_rfqd  LIKE LINE OF gt_rfqd,
         ls_xrfqd LIKE LINE OF lt_xrfqd,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_makt  LIKE LINE OF gt_makt,
         lt_xmara TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF gt_mara,
         ls_xmara LIKE LINE OF lt_xmara,
         ls_xekko LIKE LINE OF gt_xekko.

  DATA : lv_count TYPE i,
         lv_check.

  READ TABLE gt_rfqd INTO ls_rfqd
                     WITH KEY icon = icon_led_green.
  IF sy-subrc <> 0.
    CLEAR : gt_rfqd[].

    lt_out[]  = gt_out[].
    DELETE lt_out WHERE mark IS INITIAL.
    DELETE lt_out WHERE werks <> gs_rfqh-werks.
    SORT lt_out BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr.

    LOOP AT lt_out INTO ls_out.
      CLEAR ls_mara.
      READ TABLE gt_mara INTO ls_mara
                         WITH KEY matnr = ls_out-matnr.
      IF sy-subrc = 0.
        PERFORM f_get_material_mpn TABLES lt_xmara
                                   USING ls_mara-matnr ls_mara-mprof ls_mara-qmpur.
      ENDIF.
    ENDLOOP.

    IF lt_xmara[] IS NOT INITIAL.
      SELECT eina~infnr eina~matnr eina~matkl eina~lifnr
        eine~ekorg eine~esokz eine~werks eine~inco1 eine~waers
        FROM eina JOIN eine ON eina~infnr = eine~infnr
        INTO CORRESPONDING FIELDS OF TABLE gt_pir
        FOR ALL ENTRIES IN lt_xmara
        WHERE eina~matnr = lt_xmara-matnr
          AND eina~loekz = space
          AND eine~ekorg = gv_ekorg
          AND eine~esokz = '0'
          AND eine~werks = space
          AND eine~loekz = space.

      lt_xpir[]  = gt_pir[].
      SORT lt_xpir BY lifnr matnr.
      DELETE ADJACENT DUPLICATES FROM lt_xpir COMPARING lifnr matnr.
      lt_ypir[]  = lt_xpir[].
      SORT lt_ypir BY lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_ypir COMPARING lifnr.

      IF lt_xpir[] IS NOT INITIAL.
        SELECT *
          FROM qinf
          INTO CORRESPONDING FIELDS OF TABLE lt_qinf
          FOR ALL ENTRIES IN lt_xpir
          WHERE lieferant = lt_xpir-lifnr
            AND matnr     = lt_xpir-matnr
            AND werk      = gs_rfqh-werks.

        SORT gt_pir BY lifnr matnr.
        SORT lt_xpir BY lifnr matnr.

        IF lt_qinf[] IS NOT INITIAL.
          lt_xqinf[] = lt_qinf[].
          SORT lt_xqinf BY lieferant.
          DELETE ADJACENT DUPLICATES FROM lt_xqinf COMPARING lieferant.
          IF lt_xqinf[] IS NOT INITIAL.
            SELECT *
             FROM lfa1
             APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
             FOR ALL ENTRIES IN lt_xqinf
             WHERE lifnr = lt_xqinf-lieferant.
          ENDIF.
        ENDIF.

        IF lt_ypir[] IS NOT INITIAL.
          SELECT *
           FROM lfa1
           APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1
           FOR ALL ENTRIES IN lt_ypir
           WHERE lifnr = lt_ypir-lifnr.
        ENDIF.

        LOOP AT lt_xpir INTO ls_xpir.
          LOOP AT gt_pir INTO ls_pir WHERE lifnr = ls_xpir-lifnr.
            CLEAR ls_xmara.
            READ TABLE lt_xmara INTO ls_xmara
                                WITH KEY matnr = ls_pir-matnr.
            IF sy-subrc = 0.
              IF ls_xmara-qmpur IS INITIAL.
                PERFORM f_append_to_rfq TABLES lt_rfqd
                                        USING ls_pir-lifnr ls_pir-waers ls_pir-matnr
                                              ls_pir-werks '' ls_xmara-bmatn ''.
              ELSE.
                CLEAR : ls_qinf.
                READ TABLE lt_qinf INTO ls_qinf
                             WITH KEY lieferant = ls_pir-lifnr
                                      matnr     = ls_pir-matnr.
                IF sy-subrc <> 0.
                  PERFORM f_append_to_rfq TABLES lt_rfqd
                                          USING ls_pir-lifnr ls_pir-waers ls_pir-matnr
                                                gs_rfqh-werks '' ls_xmara-bmatn 'X'.
*                                                ls_pir-werks
                ELSE.
                  CLEAR : ls_qinf.
                  LOOP AT lt_qinf INTO ls_qinf WHERE lieferant = ls_pir-lifnr
                                                 AND matnr     = ls_pir-matnr.
                    PERFORM f_append_to_rfq TABLES lt_rfqd
                                            USING ls_pir-lifnr ls_pir-waers ls_pir-matnr
                                                  ls_qinf-werk ls_qinf-frei_dat ls_xmara-bmatn ''.
                  ENDLOOP.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        SORT lt_rfqd BY lifnr matnr.
        DELETE ADJACENT DUPLICATES FROM lt_rfqd COMPARING lifnr matnr.
      ENDIF.

      IF lt_rfqd[] IS NOT INITIAL.
        lt_xrfqd[] = lt_rfqd[].
        SORT lt_xrfqd BY lifnr bmatn.
        DELETE ADJACENT DUPLICATES FROM lt_xrfqd COMPARING lifnr bmatn.
        LOOP AT lt_xrfqd INTO ls_xrfqd.
          lv_check  = 'X'.
          CLEAR lv_count.
          LOOP AT lt_rfqd INTO ls_rfqd WHERE lifnr = ls_xrfqd-lifnr
                                         AND bmatn = ls_xrfqd-bmatn.

            CLEAR ls_xmara.
            READ TABLE lt_xmara INTO ls_xmara
                                WITH KEY matnr = ls_xrfqd-matnr.

            IF ls_xmara-qmpur IS NOT INITIAL.
              IF ls_rfqd-frei < gs_rfqh-frei.
                ADD 1 TO lv_count.
                ls_rfqd-status   = icon_alert.
              ELSE.
*            ls_rfqd-matnr   = ls_rfqd-bmatn.
              ENDIF.
            ELSE.
              ls_rfqd-frei = '99991231'.
            ENDIF.

            CLEAR ls_makt.
            READ TABLE gt_makt INTO ls_makt
                               WITH KEY matnr = ls_rfqd-matnr.
            IF sy-subrc = 0.
              ls_rfqd-maktx    = ls_makt-maktx.
            ENDIF.

            ls_rfqd-check = lv_check.
            IF lv_count <= 1.
              APPEND ls_rfqd TO gt_rfqd.
            ENDIF.
            CLEAR : ls_rfqd, lv_check.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

  IF gt_xrfqd[] IS NOT INITIAL.
    LOOP AT gt_rfqd INTO ls_rfqd.
      READ TABLE gt_xrfqd INTO ls_xrfqd
                          WITH KEY lifnr = ls_rfqd-lifnr
                                   matnr = ls_rfqd-matnr.
      IF sy-subrc = 0.
        ls_rfqd-mark = ls_xrfqd-mark.
        MODIFY gt_rfqd FROM ls_rfqd
                             TRANSPORTING mark.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_VENDOR

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  READ TABLE gt_rfqd INTO gs_rfqd INDEX tc_rfq-current_line.
  IF gs_rfqd-check IS INITIAL.
    CLEAR : gs_rfqd-lifnr, gs_rfqd-name1.
    IF gs_rfqd-anfnr IS INITIAL.
      PERFORM f_modify_screen USING : 'CHK' '' '' '1' '' ''.
    ELSE.
      PERFORM f_modify_screen USING : 'CHK' '' '' '0' '' ''.
    ENDIF.
  ELSEIF gs_rfqd-check IS NOT INITIAL.
    IF gs_rfqd-anfnr IS INITIAL.
      PERFORM f_modify_screen USING : 'CHK' '' '' '1' '' ''.
    ELSEIF gs_rfqd-anfnr IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'CHK' '' '' '0' '' ''.
    ENDIF.
  ENDIF.

  IF gs_rfqd-frei < gs_rfqh-bnddt.
    PERFORM f_modify_screen USING : 'CHK' '' '' '0' '' ''.
  ENDIF.

  PERFORM f_modify_check USING : 'FREI' 'X' '' '' '' '' '',
                                 'LIFNR' 'X' '' '' '' '' ''.
ENDFORM.                    " F_FILL_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  GET CURSOR LINE line1.
*  IF ok_code = '&POS'.
*  IF gs_rfqd-icon = icon_led_red.
*    CLEAR gs_rfqd-icon.
*  ENDIF.
  MODIFY gt_rfqd FROM gs_rfqd
                 INDEX tc_rfq-current_line
                 TRANSPORTING icon mark.
*  ENDIF.
ENDFORM.                    " F_READ_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ASSIGN_BIDDER
*&---------------------------------------------------------------------*
FORM f_process_assign_bidder  TABLES   quotation_items           STRUCTURE bs01mmitem
                                       quotation_item_schedules  STRUCTURE bs01mmschedule
                              USING    quotation_header          TYPE bs01mmhead
                              CHANGING fc_anfnr.
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF return,
         ls_error  LIKE LINE OF gt_return,
         ls_quoi   TYPE bs01mmitem.

  CALL FUNCTION 'BS01_MM_QUOTATION_CREATE'
    EXPORTING
      quotation_header         = quotation_header
    IMPORTING
      quotation                = fc_anfnr
    TABLES
      quotation_items          = quotation_items
      quotation_item_schedules = quotation_item_schedules
      return                   = return.

  LOOP AT return INTO ls_return.
    MOVE-CORRESPONDING ls_return TO ls_error.
    ls_error-lifnr = quotation_header-vendor.
    READ TABLE quotation_items INTO ls_quoi INDEX 1.
    IF sy-subrc = 0.
      ls_error-matnr = ls_quoi-material.
    ENDIF.
    APPEND ls_error TO gt_return.
    CLEAR ls_error.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_ASSIGN_BIDDER

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_RFQ_TYPE
*&---------------------------------------------------------------------*
FORM f_value_rfq_type .
  TYPES : BEGIN OF ty_t161t,
            bsart TYPE t161t-bsart,
            batxt TYPE t161t-batxt,
          END OF ty_t161t.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lt_t161t TYPE STANDARD TABLE OF ty_t161t,
         ls_t161  LIKE LINE OF lt_t161t,
         ls_t161t LIKE LINE OF gt_t161t,
         ls_out   LIKE LINE OF gt_out.

  DATA : ls_matnr       LIKE LINE OF gt_matnr.

  DATA : lv_subrc       TYPE sy-subrc.

  LOOP AT gt_t161t INTO ls_t161t.
    ls_t161-bsart   = ls_t161t-bsart.
    ls_t161-batxt   = ls_t161t-batxt.
    APPEND ls_t161 TO lt_t161t.
    CLEAR ls_t161.
  ENDLOOP.

  ASSIGN lt_t161t[] TO <fs_tab>.

  CLEAR lv_subrc.

  PERFORM f_value_request TABLES return_tab
                          USING 'BSART' 'GS_RFQH-BSART'
                          CHANGING lv_subrc.
ENDFORM.                    " F_VALUE_RFQ_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SELECTION
*&---------------------------------------------------------------------*
FORM f_data_selection  USING    fu_matnr.
  DATA : lt_pgmi     TYPE STANDARD TABLE OF pgmi,
         ls_pgmi     LIKE LINE OF lt_pgmi,
         ls_matnr    LIKE LINE OF gt_matnr,
         ls_out      LIKE LINE OF gt_out,
         ls_filter   LIKE LINE OF gt_filter,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  IF pa_matnr IS NOT INITIAL.
    ls_matnr-low    = pa_matnr.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'EQ'.
    APPEND ls_matnr TO gt_matnr.
  ELSE.
    lv_subrc = 4.
    ls_pgmi-prgrp   = fu_matnr.
    SELECT *
      FROM pgmi
      INTO CORRESPONDING FIELDS OF TABLE lt_pgmi
      WHERE pgtyp = space
        AND prgrp = ls_pgmi-prgrp.

    WHILE lv_subrc IS NOT INITIAL.
      ADD 1 TO lv_count.
      PERFORM f_get_material TABLES lt_pgmi
                             USING ''
                             CHANGING lv_subrc.
      IF lv_count > 10.
        CLEAR lv_subrc.
      ENDIF.
    ENDWHILE.
  ENDIF.

  LOOP AT gt_out INTO ls_out WHERE matnr IN gt_matnr.
    READ TABLE gt_filter INTO ls_filter
                         WITH KEY index = sy-tabix.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    READ TABLE ls_out-style INTO ls_stylerow
                            WITH KEY fieldname = 'MARK'.
    IF sy-subrc = 0 AND
        ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
      CONTINUE.
    ENDIF.
    ls_out-mark = 'X'.
    MODIFY gt_out FROM ls_out TRANSPORTING mark.
  ENDLOOP.
ENDFORM.                    " F_DATA_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number USING fu_count.
  DATA : lv_nrlevel    TYPE nriv-nrlevel,
         lv_number(10),
         lv_submi      TYPE ekko-submi.

  IF fu_count IS INITIAL.
    IF gv_trtyp <> 'V'.
      IF gs_rfqh-submi IS INITIAL.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = gv_range
            object                  = gv_object
            subobject               = gv_sub
            toyear                  = gv_gjahr
          IMPORTING
            number                  = gs_rfqh-submi
          EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
*****        SELECT SINGLE nrlevel
*****          FROM nriv
*****          INTO lv_nrlevel
*****          WHERE object    = gv_object
*****            AND subobject = gv_sub
*****            AND nrrangenr = gv_range
*****            AND toyear    = gv_gjahr.
*****        IF sy-subrc = 0.
*****          lv_number = lv_nrlevel+10(10) + 1.
*****          PERFORM f_conversion_exit_alpha USING lv_number
*****                                          CHANGING gs_rfqh-submi.
*****        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    lv_nrlevel  = gs_rfqh-submi.
    UPDATE nriv SET nrlevel = lv_nrlevel
                WHERE object    = gv_object
                  AND subobject = gv_sub
                  AND nrrangenr = gv_range
                  AND toyear    = gv_gjahr.
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        nr_range_nr             = gv_range
*        object                  = gv_object
*        subobject               = gv_sub
*        toyear                  = gv_gjahr
*      IMPORTING
*        number                  = lv_submi
*      EXCEPTIONS
*        interval_not_found      = 1
*        number_range_not_intern = 2
*        object_not_found        = 3
*        quantity_is_0           = 4
*        quantity_is_not_1       = 5
*        interval_overflow       = 6
*        buffer_overflow         = 7
*        OTHERS                  = 8.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_PLANT
*&---------------------------------------------------------------------*
FORM f_value_plant .
  TYPES : BEGIN OF ty_t001w,
            werks TYPE t001w-werks,
            name1 TYPE t001w-name1,
          END OF ty_t001w.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lt_xout  TYPE STANDARD TABLE OF ty_out,
         lt_t001w TYPE STANDARD TABLE OF ty_t001w,
         ls_xout  LIKE LINE OF lt_xout,
         ls_out   LIKE LINE OF gt_out.

  DATA : lv_subrc       TYPE sy-subrc.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  SORT lt_xout BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING werks.
  IF lt_xout[] IS NOT INITIAL.
    SELECT *
      FROM t001w
      INTO CORRESPONDING FIELDS OF TABLE lt_t001w
      FOR ALL ENTRIES IN lt_xout
      WHERE werks = lt_xout-werks.
  ENDIF.

  ASSIGN lt_t001w[] TO <fs_tab>.

  CLEAR lv_subrc.

  PERFORM f_value_request TABLES return_tab
                          USING 'WERKS' 'GS_RFQH-WERKS'
                          CHANGING lv_subrc.
ENDFORM.                    " F_VALUE_PLANT

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position .
  CASE sy-dynnr.
    WHEN '0102'.
      IF gs_rfqh-werks IS INITIAL.
        PERFORM f_set_cursor USING 'GS_RFQH-WERKS' ''.
      ELSEIF gs_rfqh-angdt IS INITIAL.
        PERFORM f_set_cursor USING 'GS_RFQH-ANGDT' ''.
      ELSEIF gs_rfqh-kdatb IS INITIAL.
        PERFORM f_set_cursor USING 'GS_RFQH-KDATB' ''.
      ELSEIF gs_rfqh-kdate IS INITIAL.
        PERFORM f_set_cursor USING 'GS_RFQH-KDATE' ''.
      ENDIF.

    WHEN '0103'.
  ENDCASE.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_SET_CURSOR
*&---------------------------------------------------------------------*
FORM f_set_cursor  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_SET_CURSOR

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  CASE sy-dynnr.
    WHEN '0101'.
    WHEN '0102'.
      CLEAR : gs_rfqh-werks, gt_rfqd[], gt_xekko[], gv_trtyp,
              gs_rfqh-submi, gs_rfqh-newmi.
      CLEAR : gs_rfqh-bwbdt, gs_rfqh-angdt, gs_rfqh-kdatb, gs_rfqh-kdate,
              gs_rfqh-bnddt.

      PERFORM f_date_holiday USING 4 'X'
                             CHANGING gs_rfqh-bwbdt.
      PERFORM f_date_holiday USING 8 'X'
                             CHANGING gs_rfqh-angdt.
      PERFORM f_date_holiday USING 1 ''
                             CHANGING gs_rfqh-kdatb.
      PERFORM f_date_holiday USING 14 'X'
                             CHANGING gs_rfqh-kdate.
      PERFORM f_date_holiday USING 60 'X'
                             CHANGING gs_rfqh-bnddt.

*      gs_rfqh-bwbdt = sy-datum + 3.
*      gs_rfqh-angdt = sy-datum + 6.
*      gs_rfqh-kdatb = sy-datum.
*      gs_rfqh-kdate = sy-datum + 14.
*      gs_rfqh-bnddt = sy-datum + 60.

      CLEAR : gt_return[], gv_subrc.
      gs_rfqh-anfdt   = sy-datum.
      PERFORM f_get_next_number USING ''.
  ENDCASE.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUKRS
*&---------------------------------------------------------------------*
FORM f_get_bukrs  CHANGING fc_bukrs.
  DATA : ex_t001  TYPE t001,
         ex_t001w TYPE t001w,
         ex_t001k TYPE t001k.

  DATA : lv_trtyp,
         lv_bupru   TYPE xfeld.

  lv_trtyp       = 'H'.
  lv_bupru       = 'X'.

  CALL FUNCTION 'MEX_CHECK_WERKS'
    EXPORTING
      im_werks = gs_rfqh-werks
      im_trtyp = lv_trtyp
      im_ekorg = gv_ekorg
      im_bupru = lv_bupru
    IMPORTING
      ex_t001w = ex_t001w
      ex_t001k = ex_t001k
      ex_t001  = ex_t001.

  fc_bukrs = ex_t001-bukrs.
ENDFORM.                    " F_GET_BUKRS

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_OTHERS_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_select_others_document .
  CALL SCREEN 103 STARTING AT 2 2
                  ENDING AT 42 4.
ENDFORM.                    " F_SELECT_OTHERS_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_REQUIRED_ENTRIES
*&---------------------------------------------------------------------*
FORM f_required_entries CHANGING fc_subrc.
  IF gs_rfqh-werks IS INITIAL.
    fc_subrc = 1.
    PERFORM f_error_message USING 'WRK' ''.
  ENDIF.
  IF gs_rfqh-angdt IS INITIAL.
    fc_subrc = 2.
    PERFORM f_error_message USING '2SD' ''.
  ENDIF.
  IF gs_rfqh-kdatb IS INITIAL.
    fc_subrc = 3.
    PERFORM f_error_message USING 'KDB' ''.
  ENDIF.
  IF gs_rfqh-kdate IS INITIAL.
    fc_subrc = 4.
    PERFORM f_error_message USING 'KDE' ''.
  ENDIF.
ENDFORM.                    " F_REQUIRED_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_GET_RFQ
*&---------------------------------------------------------------------*
FORM f_get_rfq .
  DATA : ls_xekko LIKE LINE OF gt_xekko,
         lt_xout  TYPE STANDARD TABLE OF ty_out,
         ls_xout  LIKE LINE OF lt_xout,
         ls_rfqd  LIKE LINE OF gt_rfqd.

  CLEAR : gt_xekpo[], gt_xekko[].

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  SORT lt_xout BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING werks.

  SELECT *
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE gt_xekko
    WHERE submi = gs_rfqh-newmi.

  IF gt_xekko[] IS NOT INITIAL.
    LOOP AT gt_rfqd INTO ls_rfqd.
      READ TABLE gt_xekko INTO ls_xekko
                          WITH KEY lifnr  = ls_rfqd-lifnr.
      IF sy-subrc = 0.
        ls_rfqd-anfnr   = ls_xekko-ebeln.
      ENDIF.
      MODIFY gt_rfqd FROM ls_rfqd TRANSPORTING anfnr.
      CLEAR ls_rfqd.
    ENDLOOP.

    READ TABLE gt_xekko INTO ls_xekko
                        WITH KEY ekgrp = gs_rfqh-ekgrp.
    IF sy-subrc = 0.
      IF ls_xekko-ekgrp = pa_ekgrp.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_xekpo
          FOR ALL ENTRIES IN gt_xekko
          WHERE ebeln = gt_xekko-ebeln.

*      CLEAR ls_xekpo.
*      READ TABLE lt_xekpo INTO ls_xekpo INDEX 1.
*      IF sy-subrc = 0.
*        CLEAR ls_xout.
*        READ TABLE lt_xout INTO ls_xout
*                           WITH KEY matnr = ls_xekpo-matnr.
*        IF sy-subrc = 0.
*      gs_rfqh-werks   = '0901'.
        gs_rfqh-submi   = gs_rfqh-newmi.
*          CLEAR ls_xekko.
*          READ TABLE lt_xekko INTO ls_xekko INDEX 1.
*          IF sy-subrc = 0.
        gs_rfqh-anfdt   = ls_xekko-bedat.
        gs_rfqh-bwbdt   = ls_xekko-bwbdt.
        gs_rfqh-angdt   = ls_xekko-angdt.
        gs_rfqh-kdatb   = ls_xekko-kdatb.
        gs_rfqh-kdate   = ls_xekko-kdate.
        gs_rfqh-bnddt   = ls_xekko-bnddt.
*          ENDIF.
*        ELSE.
*          MESSAGE s000(zab) WITH 'Different material selection'
*          DISPLAY LIKE 'E'.
*        ENDIF.
*      ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'Different Purch. Group selection'
        DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      MESSAGE s000(zab) WITH 'Different Purch. Group selection'
      DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    MESSAGE s000(zab) WITH 'Document' gs_rfqh-newmi 'does not exist'
    DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_GET_RFQ

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_CHECK
*&---------------------------------------------------------------------*
FORM f_modify_check  USING    fu_field fu_screen fu_frei fu_lifnr fu_matnr
                              fu_kdate fu_check.
  DATA : ls_rfqd      LIKE LINE OF gt_rfqd.

  DATA : lv_frei.

  IF fu_screen IS INITIAL.
    IF fu_frei >= gs_rfqh-frei.
      lv_frei = 'X'.
    ENDIF.

    IF lv_frei IS NOT INITIAL.
      ls_rfqd-mark  = fu_check.
      MODIFY gt_rfqd FROM ls_rfqd
                     TRANSPORTING mark
                     WHERE lifnr = fu_lifnr
                       AND matnr = fu_matnr.
    ENDIF.
  ELSE.
    CASE fu_field.
      WHEN 'FREI'.
        IF gs_rfqd-frei < gs_rfqh-frei.
          PERFORM f_modify_screen USING : 'CHK' '' '' '0' '' ''.
        ENDIF.
      WHEN 'STYLE'.
        IF fu_kdate IS NOT INITIAL.
          ls_rfqd-style  = fu_check.
        ENDIF.
        MODIFY gt_rfqd FROM ls_rfqd
                       TRANSPORTING style
                       WHERE lifnr = fu_lifnr
                         AND matnr = fu_matnr.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_MODIFY_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PR
*&---------------------------------------------------------------------*
FORM f_check_pr  USING    fu_lifnr fu_banfn fu_bnfpo fu_submi.
  DATA : ls_prcheck   LIKE LINE OF gt_prcheck.

  ls_prcheck-lifnr    = fu_lifnr.
  ls_prcheck-banfn    = fu_banfn.
  ls_prcheck-bnfpo    = fu_bnfpo.
  ls_prcheck-submi    = fu_submi.
  APPEND ls_prcheck TO gt_prcheck.
  CLEAR ls_prcheck.
ENDFORM.                    " F_CHECK_PR

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_MPN
*&---------------------------------------------------------------------*
FORM f_get_material_mpn  TABLES   ft_xmara STRUCTURE mara
                         USING    fu_matnr fu_mprof fu_qmpur.
  DATA : lt_xmara TYPE STANDARD TABLE OF mara,
         ls_xmara TYPE mara,
         ls_mara  TYPE mara.

  ls_xmara-matnr = fu_matnr.
  ls_xmara-bmatn = fu_matnr.
  ls_xmara-qmpur = fu_qmpur.
*  APPEND ls_xmara TO ft_xmara.

  IF fu_mprof IS NOT INITIAL.
    SELECT matnr bmatn qmpur
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_xmara
      WHERE bmatn = fu_matnr.

    IF lt_xmara[] IS NOT INITIAL.
      SELECT *
        FROM makt
        APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
        FOR ALL ENTRIES IN lt_xmara
        WHERE matnr = lt_xmara-matnr
          AND spras = sy-langu.
    ENDIF.

    LOOP AT lt_xmara INTO ls_xmara.
      IF ls_xmara-bmatn = fu_matnr.
        ls_xmara-qmpur = fu_qmpur.
      ENDIF.
      APPEND ls_xmara TO ft_xmara.
      CLEAR ls_xmara.
    ENDLOOP.
  ELSE.
    APPEND ls_xmara TO ft_xmara.
    CLEAR ls_xmara.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_MPN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATUM
*&---------------------------------------------------------------------*
FORM f_validate_datum  USING    fu_datum fu_text
                       CHANGING fc_subrc.
  IF fu_datum < sy-datum.
    fc_subrc = 4.
    MESSAGE s000(zab) WITH fu_text sy-datum
    DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATUM

*&---------------------------------------------------------------------*
*&      Form  F_MULTI_MATERIAL
*&---------------------------------------------------------------------*
FORM f_multi_material  TABLES   ft_out    LIKE gt_out
                                ft_xrfqd  LIKE gt_rfqd
                                ft_xout   LIKE gt_out
                                ft_quoi   STRUCTURE bs01mmitem
                                ft_quois  STRUCTURE bs01mmschedule
                       USING    fu_lifnr fu_pincr fu_submi
                       CHANGING fc_ebelp.

  DATA : ls_xrfqd   LIKE LINE OF gt_rfqd,
         ls_xout    LIKE LINE OF gt_out,
         ls_out     LIKE LINE OF gt_out,
         ls_quoi    TYPE bs01mmitem,
         ls_quois   TYPE bs01mmschedule,
         ls_prcheck LIKE LINE OF gt_prcheck.

  LOOP AT ft_xrfqd INTO ls_xrfqd WHERE lifnr = fu_lifnr.
    ADD fu_pincr TO fc_ebelp.
    ls_quoi-doc_item    = fc_ebelp.
    ls_quoi-material    = ls_xrfqd-bmatn.
    ls_quoi-pur_mat     = ls_xrfqd-bmatn.
*    ls_quoi-pur_mat     = ls_xrfqd-matnr.
    ls_quoi-manuf_prof  = 'Z001'.
    ls_quoi-vend_mat    = ls_xrfqd-matnr.
    ls_quoi-plant       = gs_rfqh-werks.
    APPEND ls_quoi TO ft_quoi.
    CLEAR ls_quoi.

*      PERFORM f_get_pr_reference CHANGING lv_banfn lv_bnfpo.

    LOOP AT ft_out INTO ls_out WHERE mark  = 'X'
                                 AND matnr = ls_xrfqd-bmatn.
      ls_quois-doc_item   = fc_ebelp.
      ls_quois-del_datcat = '1'.
      ls_quois-deliv_date = ls_out-lfdat.
      ls_quois-quantity   = ls_out-menge.
      ls_quois-preq_no    = ls_out-banfn.
      ls_quois-preq_item  = ls_out-bnfpo.
      CLEAR ls_prcheck.
      READ TABLE gt_prcheck INTO ls_prcheck
                            WITH KEY lifnr = fu_lifnr
                                     banfn = ls_out-banfn
                                     bnfpo = ls_out-bnfpo
                                     submi = fu_submi.
      IF sy-subrc <> 0.
        APPEND ls_quois TO ft_quois.
      ENDIF.
      CLEAR ls_quois.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_MULTI_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_PER_MATERIAL
*&---------------------------------------------------------------------*
FORM f_per_material  TABLES   ft_out    LIKE gt_out
                              ft_xrfqd  LIKE gt_rfqd
                              ft_xout   LIKE gt_out
                              ft_quoi   STRUCTURE bs01mmitem
                              ft_quois  STRUCTURE bs01mmschedule
                     USING    fu_lifnr fu_bmatn fu_pincr fu_submi
                     CHANGING fc_ebelp.

  DATA : ls_xrfqd   LIKE LINE OF gt_rfqd,
         ls_xout    LIKE LINE OF gt_out,
         ls_out     LIKE LINE OF gt_out,
         ls_quoi    TYPE bs01mmitem,
         ls_quois   TYPE bs01mmschedule,
         ls_prcheck LIKE LINE OF gt_prcheck.

  LOOP AT ft_xrfqd INTO ls_xrfqd WHERE lifnr = fu_lifnr
                                   AND bmatn = fu_bmatn.
    READ TABLE ft_xout INTO ls_xout
                       WITH KEY matnr = ls_xrfqd-bmatn
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      ADD fu_pincr TO fc_ebelp.
      ls_quoi-doc_item  = fc_ebelp.
      ls_quoi-material  = ls_xrfqd-bmatn.
      ls_quoi-pur_mat   = ls_xrfqd-bmatn.
      ls_quoi-vend_mat  = ls_xrfqd-matnr.
      ls_quoi-plant     = gs_rfqh-werks.
      APPEND ls_quoi TO ft_quoi.
      CLEAR ls_quoi.

*      PERFORM f_get_pr_reference CHANGING lv_banfn lv_bnfpo.

      LOOP AT ft_out INTO ls_out WHERE matnr = ls_xrfqd-bmatn
                                   AND mark  = 'X'.
        ls_quois-doc_item   = fc_ebelp.
        ls_quois-del_datcat = '1'.
        ls_quois-deliv_date = ls_out-lfdat.
        ls_quois-quantity   = ls_out-menge.
        ls_quois-preq_no    = ls_out-banfn.
        ls_quois-preq_item  = ls_out-bnfpo.
        CLEAR ls_prcheck.
        READ TABLE gt_prcheck INTO ls_prcheck
                              WITH KEY lifnr = fu_lifnr
                                       banfn = ls_out-banfn
                                       bnfpo = ls_out-bnfpo
                                       submi = fu_submi.
        IF sy-subrc <> 0.
          APPEND ls_quois TO ft_quois.
        ENDIF.
        CLEAR ls_quois.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PER_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_MODIFY
*&---------------------------------------------------------------------*
FORM f_layout_modify .
  IF gv_trtyp = 'V'.
    PERFORM f_modify_screen USING : '' 'HED' '' '0' '' ''.
  ENDIF.
ENDFORM.                    " F_LAYOUT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out       LIKE LINE OF gt_out,
         lv_title(50),
         lv_subrc     TYPE sy-subrc.

  CASE fu_column.
    WHEN 'BANFN'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        PERFORM f_prepare_listinfo USING 'EKET' ls_out-banfn
                                         ls_out-bnfpo ''
                                   CHANGING lv_title.
        PERFORM f_print_listinfo USING lv_title.
      ENDIF.
    WHEN 'ICON'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        IF ls_out-icon = icon_locked.
          PERFORM f_check_lock_entry USING 'ZHSMMMDT002' pa_ekgrp pa_prgrp ls_out-matnr
                                     CHANGING lv_subrc.
          IF gv_subrc IS INITIAL.
            PERFORM f_check_lock_entry USING 'ZHSMMMDT001' pa_ekgrp pa_prgrp ls_out-matnr
                                       CHANGING lv_subrc.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LISTINFO
*&---------------------------------------------------------------------*
FORM f_prepare_listinfo  USING    fu_table fu_banfn fu_bnfpo fu_submi
                         CHANGING fc_title.
  DATA : lt_eket TYPE STANDARD TABLE OF eket,
         lt_ekko TYPE STANDARD TABLE OF ekko,
         lt_ekpo TYPE STANDARD TABLE OF ekpo,
         lt_lfa1 TYPE STANDARD TABLE OF lfa1,
         lt_makt TYPE STANDARD TABLE OF makt,
         ls_eket LIKE LINE OF lt_eket,
         ls_ekko LIKE LINE OF lt_ekko,
         ls_ekpo LIKE LINE OF lt_ekpo,
         ls_list LIKE LINE OF gt_list,
         ls_lfa1 LIKE LINE OF gt_lfa1,
         ls_makt LIKE LINE OF gt_makt.

  CLEAR : gt_list[].

  CASE fu_table.
    WHEN 'EKKO'.
      fc_title  = 'List Tender'.
      SELECT *
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE lt_ekko
        WHERE submi = gs_rfqh-submi.

      IF lt_ekko[] IS NOT INITIAL.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
          FOR ALL ENTRIES IN lt_ekko
          WHERE ebeln = lt_ekko-ebeln
            AND loekz = space.

        SELECT *
          FROM eket
          INTO CORRESPONDING FIELDS OF TABLE lt_eket
          FOR ALL ENTRIES IN lt_ekko
          WHERE ebeln = lt_ekko-ebeln.
      ENDIF.

    WHEN 'EKET'.
      fc_title  = 'List PR'.
      SELECT *
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE lt_eket
        WHERE banfn = fu_banfn
          AND bnfpo = fu_bnfpo.

      IF lt_eket[] IS NOT INITIAL.
        SELECT *
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE lt_ekko
          FOR ALL ENTRIES IN lt_eket
          WHERE ebeln = lt_eket-ebeln.

        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
          FOR ALL ENTRIES IN lt_eket
          WHERE ebeln = lt_eket-ebeln
            AND ebelp = lt_eket-ebelp
            AND loekz = space.
      ENDIF.
  ENDCASE.

  PERFORM f_get_name TABLES lt_ekko lt_lfa1
                            lt_ekpo lt_makt.

  LOOP AT lt_ekpo INTO ls_ekpo.
    ls_list-ebeln   = ls_ekpo-ebeln.
    ls_list-ebelp   = ls_ekpo-ebelp.
    ls_list-matnr   = ls_ekpo-matnr.

    CLEAR ls_makt.
    READ TABLE lt_makt INTO ls_makt
                       WITH KEY matnr = ls_ekpo-matnr.
    IF sy-subrc = 0.
      ls_list-maktx   = ls_makt-maktx.
    ENDIF.

    CLEAR ls_ekko.
    READ TABLE lt_ekko INTO ls_ekko
                       WITH KEY ebeln = ls_ekpo-ebeln.
    IF sy-subrc = 0.
      ls_list-lifnr   = ls_ekko-lifnr.
      CLEAR ls_lfa1.
      READ TABLE lt_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = ls_ekko-lifnr.
      IF sy-subrc = 0.
        ls_list-name1   = ls_lfa1-name1.
      ENDIF.
      ls_list-submi   = ls_ekko-submi.
    ENDIF.

    CLEAR ls_eket.
    READ TABLE lt_eket INTO ls_eket
                       WITH KEY ebeln = ls_ekpo-ebeln
                                ebelp = ls_ekpo-ebelp.
    IF sy-subrc = 0.
      ls_list-banfn   = ls_eket-banfn.
      ls_list-bnfpo   = ls_eket-bnfpo.
    ENDIF.

    APPEND ls_list TO gt_list.
    CLEAR ls_list.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_LISTINFO

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LISTINFO
*&---------------------------------------------------------------------*
FORM f_print_listinfo USING fu_title.
  DATA : ls_selfield TYPE slis_selfield,
         lv_exit.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title                 = fu_title
      i_selection             = space
      i_allow_no_selection    = 'X'
      i_zebra                 = 'X'
      i_screen_start_column   = 2
      i_screen_start_line     = 2
      i_screen_end_column     = 150
      i_screen_end_line       = 15
      i_tabname               = 'GT_LIST'
      i_structure_name        = 'ZHSMMMST001'
      i_callback_program      = gv_repid
      i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
    IMPORTING
      es_selfield             = ls_selfield
      e_exit                  = lv_exit
    TABLES
      t_outtab                = gt_list
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc = 0.

  ENDIF.
ENDFORM.                    " F_PRINT_LISTINFO

*&---------------------------------------------------------------------*
*&      Form  F_GET_NAME
*&---------------------------------------------------------------------*
FORM f_get_name  TABLES   ft_ekko STRUCTURE ekko
                          ft_lfa1 STRUCTURE lfa1
                          ft_ekpo STRUCTURE ekpo
                          ft_makt STRUCTURE makt.
  DATA : lt_ekko TYPE STANDARD TABLE OF ekko,
         lt_ekpo TYPE STANDARD TABLE OF ekpo.

  lt_ekko[] = ft_ekko[].
  SORT lt_ekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekko COMPARING lifnr.
  IF lt_ekko[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE ft_lfa1
      FOR ALL ENTRIES IN lt_ekko
      WHERE lifnr = lt_ekko-lifnr.
  ENDIF.

  lt_ekpo[] = ft_ekpo[].
  SORT lt_ekpo BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr.
  IF lt_ekpo[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE ft_makt
      FOR ALL ENTRIES IN lt_ekpo
      WHERE matnr = lt_ekpo-matnr
        AND spras = sy-langu.
  ENDIF.
ENDFORM.                    " F_GET_NAME

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_lock_document USING fu_matnr.
  CLEAR : gv_subrc.
  PERFORM f_check_lock_entry USING 'ZHSMMMDT002' pa_ekgrp pa_prgrp fu_matnr
                             CHANGING gv_subrc.
  IF gv_subrc IS INITIAL.
    PERFORM f_check_lock_entry USING 'ZHSMMMDT001' pa_ekgrp pa_prgrp fu_matnr
                               CHANGING gv_subrc.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF fu_matnr IS INITIAL.
      CALL FUNCTION 'ENQUEUE_EZHSMMMDT1'
        EXPORTING
          ekgrp          = pa_ekgrp
          prgrp          = pa_prgrp
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    ELSE.
      CALL FUNCTION 'ENQUEUE_EZHSMMMDT2'
        EXPORTING
          ekgrp          = pa_ekgrp
          prgrp          = pa_prgrp
          matnr          = fu_matnr
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_LOCK_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LOCK_ENTRY
*&---------------------------------------------------------------------*
FORM f_check_lock_entry  USING    fu_gname fu_ekgrp fu_prgrp fu_matnr
                         CHANGING fc_subrc.
  DATA : lv_gname     TYPE seqg3-gname,
         lv_garg      TYPE seqg3-garg,
         enq          TYPE STANDARD TABLE OF seqg3,
         ls_enq       LIKE LINE OF enq,
         lv_mess(100),
         ls_material  LIKE LINE OF gt_material,
         lv_ekgrp     TYPE eban-ekgrp,
         lv_prgrp     TYPE pgmi-prgrp.

  lv_gname      = fu_gname.
  lv_garg(3)    = sy-mandt.
  lv_garg+3(3)  = fu_ekgrp.
  lv_garg+6(18) = fu_prgrp.
  IF fu_matnr IS INITIAL.
  ELSE.
    lv_garg+24(18) = fu_matnr.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = lv_gname
      guname                = space
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF enq[] IS NOT INITIAL.
    IF fu_matnr IS INITIAL.
      LOOP AT enq INTO ls_enq.
        ls_material-matnr   = ls_enq-garg+24(18).
        IF ls_material-matnr IS NOT INITIAL.
          APPEND ls_material TO gt_material.
        ENDIF.
        CLEAR ls_material.
      ENDLOOP.
      IF gt_material[] IS INITIAL.
        READ TABLE enq INTO ls_enq INDEX 1.
        IF sy-subrc = 0.
          lv_ekgrp  = ls_enq-garg+3(3).
          lv_prgrp  = ls_enq-garg+6(18).
          IF lv_ekgrp = pa_ekgrp AND
            lv_prgrp = pa_prgrp.
            fc_subrc = 4.
            CONCATENATE pa_ekgrp pa_prgrp 'Lock by' ls_enq-guname
            INTO lv_mess
            SEPARATED BY space.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE enq INTO ls_enq INDEX 1.
      IF sy-subrc = 0.
        lv_ekgrp  = lv_garg+3(3).
        lv_prgrp  = lv_garg+6(18).
        IF lv_ekgrp = pa_ekgrp AND
          lv_prgrp = pa_prgrp.
          fc_subrc = 4.
          CONCATENATE pa_ekgrp pa_prgrp pa_matnr 'Lock by' ls_enq-guname
          INTO lv_mess
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

    IF fc_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH lv_mess DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_LOCK_ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_CALLBACK_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_callback_user_command USING r_ucomm     LIKE sy-ucomm
                                   rs_selfield TYPE kkblo_selfield.
  DATA : lv_ebeln TYPE ekko-ebeln,
         lv_banfn TYPE ekpo-banfn.

  CASE r_ucomm.
    WHEN '&ICM'.
      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM f_conversion_exit_alpha USING rs_selfield-value
                                          CHANGING lv_ebeln.
          SET PARAMETER ID 'ANF' FIELD lv_ebeln.
          CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.

        WHEN 'BANFN'.
          PERFORM f_conversion_exit_alpha USING rs_selfield-value
                                          CHANGING lv_banfn.
          SET PARAMETER ID 'BAN' FIELD lv_banfn.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_CALLBACK_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_exit_alpha  USING    fu_value
                              CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_CONVERSION_EXIT_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_TO_RFQ
*&---------------------------------------------------------------------*
FORM f_append_to_rfq  TABLES   ft_rfqd TYPE STANDARD TABLE
                      USING    fu_lifnr fu_waers fu_matnr fu_werks fu_frei fu_bmatn
                               fu_error.

  DATA : ls_rfqd   LIKE LINE OF gt_rfqd,
         ls_xekko  LIKE LINE OF gt_xekko,
         ls_xekpo  LIKE LINE OF gt_xekpo,
         ls_lfa1   LIKE LINE OF gt_lfa1,
         ls_return LIKE LINE OF gt_return.

  ls_rfqd-werks  = fu_werks.
  ls_rfqd-lifnr  = fu_lifnr.
  ls_rfqd-frei   = fu_frei.
  ls_rfqd-waers  = fu_waers.
  CLEAR ls_lfa1.
  READ TABLE gt_lfa1 INTO ls_lfa1
                     WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    ls_rfqd-name1    = ls_lfa1-name1.
  ENDIF.
  ls_rfqd-matnr  = fu_matnr.
  ls_rfqd-bmatn  = fu_bmatn.

  READ TABLE gt_xekko INTO ls_xekko
                      WITH KEY lifnr  = fu_lifnr.
  IF sy-subrc = 0.
    READ TABLE gt_xekpo INTO ls_xekpo
                        WITH KEY ebeln  = ls_xekko-ebeln
                                 werks  = fu_werks
                                 matnr  = fu_bmatn.
    IF sy-subrc = 0.
      ls_rfqd-anfnr   = ls_xekko-ebeln.
    ENDIF.
  ENDIF.
  IF fu_error IS NOT INITIAL.
    ls_rfqd-icon          = icon_led_red.
    ls_return-lifnr       = fu_lifnr.
    ls_return-matnr       = fu_matnr.
    ls_return-type        = 'E'.
    ls_return-id          = 'ZAB'.
    ls_return-message_v1  = 'QM-info record does not exist'.
    APPEND ls_return TO gt_return.
    CLEAR ls_return.
  ENDIF.
  APPEND ls_rfqd TO ft_rfqd.
  CLEAR ls_rfqd.
ENDFORM.                    " F_APPEND_TO_RFQ

*&---------------------------------------------------------------------*
*&      Form  F_DATE_HOLIDAY
*&---------------------------------------------------------------------*
FORM f_date_holiday  USING fu_times fu_calendar
                     CHANGING fc_datum.
  DATA : holidays TYPE STANDARD TABLE OF iscal_day,
         lv_subrc TYPE sy-subrc,
         lv_datum TYPE sy-datum,
         lv_count TYPE i.

  IF fu_calendar IS INITIAL.
    fc_datum = sy-datum.
  ELSE.
    lv_datum = sy-datum.
    DO fu_times TIMES.
      lv_subrc = 4.
      ADD 1 TO lv_count.
      WHILE lv_subrc <> 0.
        CLEAR : holidays[].
        CALL FUNCTION 'HOLIDAY_GET'
          EXPORTING
            holiday_calendar           = 'T0'
            factory_calendar           = 'T0'
            date_from                  = lv_datum
            date_to                    = lv_datum
          TABLES
            holidays                   = holidays
          EXCEPTIONS
            factory_calendar_not_found = 1
            holiday_calendar_not_found = 2
            date_has_invalid_format    = 3
            date_inconsistency         = 4
            OTHERS                     = 5.

        IF holidays[] IS NOT INITIAL.
          lv_datum = lv_datum + 1.
        ELSE.
          IF lv_count < fu_times.
            lv_datum = lv_datum + 1.
          ENDIF.
          CLEAR lv_subrc.
        ENDIF.
      ENDWHILE.
    ENDDO.
    fc_datum  = lv_datum.
  ENDIF.
ENDFORM.                    " F_DATE_HOLIDAY

*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL
*&---------------------------------------------------------------------*
FORM f_send_email .
  DATA : lo_send_request TYPE REF TO cl_bcs,
         lo_document     TYPE REF TO cl_document_bcs,
         lo_sender       TYPE REF TO if_sender_bcs,
         lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
         lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service.

  DATA : lv_subject      TYPE so_obj_des,
         lt_message_body TYPE bcsy_text,
         lv_text         TYPE string,
         lv_sent_to_all  TYPE os_boolean,
         lv_status       TYPE bcs_rqst.

  DATA : lv_to    TYPE zhsmmmdt005-smtp_addr,
         lv_cc    TYPE zhsmmmdt005-smtp_addr,
         lv_srno1 TYPE zhsmmmdt005-srno1,
         lv_email TYPE bapiadsmtp-e_mail.

  DATA : lt_xmail TYPE STANDARD TABLE OF ty_mail,
         ls_xmail LIKE LINE OF lt_xmail,
         ls_005   LIKE LINE OF gt_005.

  lt_xmail[] = gt_mail[].
  SORT lt_xmail BY submi.
  DELETE ADJACENT DUPLICATES FROM lt_xmail COMPARING submi.

  LOOP AT lt_xmail INTO ls_xmail.
    "create send request
    lo_send_request = cl_bcs=>create_persistent( ).

    "create subject
    CONCATENATE 'Coll no.' ls_xmail-submi 'Fully created (No Reply)'
    INTO lv_subject
    SEPARATED BY space.

    "create message body
    CLEAR :  lt_message_body[].
    PERFORM f_create_body TABLES lt_message_body
                          USING ls_xmail-submi '' 'ZPOSTINGRFQ' 'X'.

    CREATE OBJECT lo_mime_helper.

    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_message_body.

    lo_document = cl_document_bcs=>create_from_multirelated(
    i_subject          = lv_subject
    i_importance       = '9'
    i_multirel_service = lo_mime_helper ).

    lo_send_request->set_document( lo_document ).

*  lo_sender = cl_sapuser_bcs=>create( sy-uname ).
*
*  lo_send_request->set_sender( lo_sender ).

    CLEAR lo_recipient.
* Add To
    LOOP AT gt_005 INTO ls_005.
      lv_email = ls_005-smtp_addr.
      IF lv_email IS NOT INITIAL.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                       i_address_string = lv_email ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient ).
      ENDIF.
    ENDLOOP.

** Add CC
*  IF fu_ucomm IS INITIAL.
*  ELSE.
*    lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_cc ).
*    lo_send_request->add_recipient( i_recipient  = lo_recipient
*                                    i_copy       = 'X').
*  ENDIF.

    lv_status = 'N'.
    CALL METHOD lo_send_request->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.

    TRY.
        lo_send_request->send( ).
        COMMIT WORK.
      CATCH cx_bcs.
        ROLLBACK WORK.
    ENDTRY.
  ENDLOOP.
ENDFORM.                    " F_SEND_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BODY
*&---------------------------------------------------------------------*
FORM f_create_body  TABLES   ft_body STRUCTURE soli
                    USING    fu_submi fu_ernam fu_name fu_table.

  TYPES : BEGIN OF ty_relcd,
            frgco TYPE t16fd-frgco,
          END OF ty_relcd.

  DATA : lv_name  TYPE thead-tdname,
         lines    TYPE STANDARD TABLE OF tline,
         ls_line  LIKE LINE OF lines,
         lv_line  TYPE i,
         lv_code  TYPE string,
         lv_count TYPE i.

  DATA : lt_relcd TYPE STANDARD TABLE OF ty_relcd,
         ls_relcd LIKE LINE OF lt_relcd.

  DATA : ls_fcat  TYPE lvc_s_fcat,
         lt_body  TYPE bcsy_text,
         ls_body  TYPE soli,
         lt_space TYPE STANDARD TABLE OF string.

  DATA : lt_fields    TYPE STANDARD TABLE OF w3fields.

  lv_name = fu_name.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = lv_name
      object                  = 'TEXT'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  LOOP AT lines INTO ls_line.
    REPLACE ALL OCCURRENCES OF REGEX '&COLL&' IN ls_line-tdline WITH fu_submi.

    IF ls_line-tdformat IS INITIAL.
      DESCRIBE TABLE lt_body LINES lv_line.
      READ TABLE lt_body INTO ls_body INDEX lv_line.
      CONCATENATE ls_body ls_line-tdline INTO ls_body
      SEPARATED BY space.
      MODIFY lt_body FROM ls_body INDEX lv_line.
    ELSE.
      APPEND ls_line-tdline TO lt_body.
    ENDIF.
  ENDLOOP.

  CLEAR : ft_body[], lv_line.
  IF fu_table IS NOT INITIAL.
    CLEAR : gt_tfcat[], gt_ffcat[].
    PERFORM f_create_mail_fieldcat USING : 'Product Group' '',
                                           'RFQ No.' ''.
    IF gt_tfcat[] IS NOT INITIAL.
      PERFORM f_create_mail_table TABLES gt_tfcat
                                  USING 'green' fu_submi fu_ernam.
    ENDIF.

    IF gt_ffcat[] IS NOT INITIAL.
      PERFORM f_create_mail_table TABLES gt_ffcat
                                  USING 'red' fu_submi fu_ernam.
    ENDIF.

    LOOP AT lt_body INTO ls_body.
      IF lv_line IS NOT INITIAL.
        IF ls_body-line IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.
      ADD 1 TO lv_line.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.

    IF gt_thtml[] IS NOT INITIAL.
      LOOP AT gt_thtml INTO ls_body.
        APPEND ls_body TO ft_body.
        CLEAR ls_body.
      ENDLOOP.

      DO 2 TIMES.
        ls_body-line = '<br />'.
        APPEND ls_body TO ft_body.
        CLEAR ls_body.
      ENDDO.
    ENDIF.

    LOOP AT gt_fhtml INTO ls_body.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.

    LOOP AT lt_body INTO ls_body FROM lv_line.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ELSE.
        CONCATENATE ls_body-line '<br />' INTO ls_body-line
        SEPARATED BY space.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.
  ELSE.
    LOOP AT lt_body INTO ls_body.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ELSE.
        CONCATENATE ls_body-line '<br />' INTO ls_body-line
        SEPARATED BY space.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_create_mail_fieldcat  USING    fu_coltext fu_flag.
  DATA : ls_fcat      TYPE lvc_s_fcat.

  ls_fcat-coltext = fu_coltext.
  IF fu_flag IS INITIAL.
    APPEND ls_fcat TO gt_tfcat.
  ELSE.
    APPEND ls_fcat TO gt_ffcat.
  ENDIF.
ENDFORM.                    " F_CREATE_MAIL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_TABLE
*&---------------------------------------------------------------------*
FORM f_create_mail_table  TABLES   ft_fcat  TYPE lvc_t_fcat
                          USING    fu_bgcolor fu_submi fu_ernam.
  TYPES : BEGIN OF ty_ttable,
            maktx TYPE makt-maktx,
            anfnr TYPE ekpo-anfnr,
          END OF ty_ttable.

  TYPES : BEGIN OF ty_ftable,
            zalno TYPE zgdmmt004z-zalno,
          END OF ty_ftable.

  DATA : lt_header TYPE STANDARD TABLE OF w3head,
         lt_fields TYPE STANDARD TABLE OF w3fields,
         lv_text   TYPE w3head-text.

  DATA : lt_ttable TYPE STANDARD TABLE OF ty_ttable,
         ls_ttable LIKE LINE OF lt_ttable,
         lt_ftable TYPE STANDARD TABLE OF ty_ftable,
         ls_ftable LIKE LINE OF lt_ftable,
         ls_fcat   TYPE lvc_s_fcat,
         ls_mail   LIKE LINE OF gt_mail.

  LOOP AT ft_fcat INTO ls_fcat.
    lv_text = ls_fcat-coltext.
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        field_nr = sy-tabix
        text     = lv_text
        fgcolor  = 'black'
        bgcolor  = fu_bgcolor
      TABLES
        header   = lt_header.

    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        field_nr = sy-tabix
        fgcolor  = 'black'
        size     = '3'
      TABLES
        fields   = lt_fields.
  ENDLOOP.

  LOOP AT gt_mail INTO ls_mail WHERE submi = fu_submi.
    ls_ttable-maktx   = ls_mail-maktx.
    ls_ttable-anfnr   = ls_mail-anfnr.
    APPEND ls_ttable TO lt_ttable.
    CLEAR ls_ttable.
  ENDLOOP.

  SORT lt_ttable BY maktx anfnr.
  DELETE ADJACENT DUPLICATES FROM lt_ttable COMPARING maktx anfnr.

  CLEAR gt_thtml[].
  IF lt_ttable[] IS NOT INITIAL.
    CALL FUNCTION 'WWW_ITAB_TO_HTML'
      TABLES
        html       = gt_thtml
        fields     = lt_fields
        row_header = lt_header
        itable     = lt_ttable.
  ENDIF.
ENDFORM.                    " F_CREATE_MAIL_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SEND_EMAIL
*&---------------------------------------------------------------------*
FORM f_prepare_send_email  TABLES   ft_xrfqd  LIKE gt_rfqd
                           USING    fu_lifnr fu_submi fu_anfnr.
  DATA : ls_mail  LIKE LINE OF gt_mail,
         ls_xrfqd LIKE LINE OF gt_rfqd.

  LOOP AT ft_xrfqd INTO ls_xrfqd WHERE lifnr = fu_lifnr.
    ls_mail-submi   = fu_submi.
    ls_mail-maktx   = ls_xrfqd-maktx.
    ls_mail-anfnr   = fu_anfnr.
    APPEND ls_mail TO gt_mail.
    CLEAR ls_mail.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_SEND_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_DEQUEUE_PR
*&---------------------------------------------------------------------*
FORM f_dequeue_pr  TABLES   ft_quois    STRUCTURE bs01mmschedule.
  DATA : lv_gname TYPE seqg3-gname,
         lv_garg  TYPE seqg3-garg,
         lv_banfn TYPE eban-banfn,
         lv_subrc TYPE sy-subrc,
         lv_uname TYPE sy-uname.

  DATA : enq      TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF enq,
         ls_quois TYPE bs01mmschedule.
  WAIT UP TO 1 SECONDS.
  READ TABLE ft_quois INTO ls_quois INDEX 1.
  IF sy-subrc = 0.
    lv_banfn  = ls_quois-preq_no.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = lv_gname
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF enq[] IS NOT INITIAL.
    CLEAR lv_subrc.
    LOOP AT enq INTO ls_enq.
      IF ls_enq-garg+3(10) = lv_banfn.
        IF ls_enq-guname <> sy-uname.
          lv_subrc = 4.
          EXIT.
        ELSE.
          lv_uname  = ls_enq-guname.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_subrc = 0 AND
      lv_uname = sy-uname.
      CALL FUNCTION 'DEQUEUE_EMEBANE'
        EXPORTING
          banfn = lv_banfn.
    ENDIF.
  ENDIF.
ENDFORM.
