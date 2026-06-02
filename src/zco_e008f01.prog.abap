*&---------------------------------------------------------------------*
*&  Include           ZCO_E003F01
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
  DATA: lr_ktogr TYPE RANGE OF ktogr.

  CASE p_bukrs.
    WHEN '8010'.
      lr_ktogr = VALUE #( ( sign = 'I' option = 'EQ' low = '00002998' )
                          ( sign = 'I' option = 'EQ' low = '00002983' )
                          ( sign = 'I' option = 'EQ' low = '00002984' )
                          ( sign = 'I' option = 'EQ' low = '00004004' ) ).
    WHEN '8180'.
      lr_ktogr = VALUE #( ( sign = 'I' option = 'EQ' low = '00002983' )
                          ( sign = 'I' option = 'EQ' low = '00002984' )
                          ( sign = 'I' option = 'EQ' low = '00002981' )
                          ( sign = 'I' option = 'EQ' low = '00003010' )
                          ( sign = 'I' option = 'EQ' low = '00003011' )
                          ( sign = 'I' option = 'EQ' low = '00003012' )
                          ( sign = 'I' option = 'EQ' low = '00003013' )
                          ( sign = 'I' option = 'EQ' low = '00003014' )
                          ( sign = 'I' option = 'EQ' low = '00003024' ) ).
  ENDCASE.

  SELECT a~bukrs, a~gjahr, a~peraf, a~afbnr, a~anln1, a~anln2, a~afaber,
         a~zujhr, a~zucod, a~nafaz, a~gsber, a~ktogr, b~invzu, b~typbz,
         c~kostl, c~raumn, c~kfzkz, d~ktnafg
    INTO TABLE @DATA(lt_anpl)
    FROM anlp AS a JOIN anla AS b ON b~bukrs = a~bukrs AND
                                     b~anln1 = a~anln1 AND
                                     b~anln2 = a~anln2
                   LEFT OUTER JOIN anlz AS c ON c~bukrs = a~bukrs AND
                                                c~anln1 = a~anln1 AND
                                                c~anln2 = a~anln2 AND
                                                c~bdatu GE @sy-datum
                   LEFT OUTER JOIN t095b AS d ON d~ktogr = a~ktogr
    WHERE a~bukrs = @p_bukrs
      AND a~gjahr = @p_gjahr
      AND a~peraf = @p_peraf
      AND a~afaber = '01'
      AND a~ktogr IN @lr_ktogr
    ORDER BY a~bukrs, a~gjahr, a~peraf, a~afbnr, a~anln1, a~anln2, a~afaber,
             a~zujhr, a~zucod.

  IF lt_anpl[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I'DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  DATA(lt_anpl_tmp) = lt_anpl[].
  SORT lt_anpl_tmp BY gsber raumn.
  DELETE ADJACENT DUPLICATES FROM lt_anpl_tmp COMPARING gsber raumn.
  SELECT * INTO TABLE @DATA(lt_zcodt015)
    FROM zcodt015 FOR ALL ENTRIES IN @lt_anpl_tmp
    WHERE gsber = @lt_anpl_tmp-gsber
      AND wwsec = @lt_anpl_tmp-raumn.

  SELECT * INTO TABLE @DATA(lt_zcodt012)
    FROM zcodt012 FOR ALL ENTRIES IN @lt_anpl
    WHERE bukrs = @lt_anpl-bukrs
      AND gsber = @lt_anpl-gsber
      AND gjahr = @lt_anpl-gjahr
      AND peraf = @lt_anpl-peraf
      AND anln1 = @lt_anpl-anln1
      AND anln2 = @lt_anpl-anln2.

  LOOP AT lt_anpl INTO DATA(ls_anpl).
*    IF line_exists( lt_anpl[ bukrs = ls_anpl-bukrs
*                             gsber = ls_anpl-gsber
*                             gjahr = ls_anpl-gjahr
*                             peraf = ls_anpl-peraf
*                             anln1 = ls_anpl-anln1
*                             anln2 = ls_anpl-anln2 ] ).
*      CONTINUE.
*    ENDIF.

    READ TABLE lt_zcodt012 INTO DATA(ls_zcodt012)
                           WITH KEY bukrs = ls_anpl-bukrs
                                    gsber = ls_anpl-gsber
                                    gjahr = ls_anpl-gjahr
                                    peraf = ls_anpl-peraf
                                    anln1 = ls_anpl-anln1
                                    anln2 = ls_anpl-anln2.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO gt_out ASSIGNING FIELD-SYMBOL(<fs_out>).
    MOVE-CORRESPONDING ls_anpl TO <fs_out>.
    <fs_out>-nafaz = <fs_out>-nafaz * -1.
    <fs_out>-waers = 'IDR'.
    <fs_out>-perio = |{ p_gjahr }| & |{ p_peraf }|.
    <fs_out>-budat = |{ p_gjahr }| & |{ p_peraf+1(2) }| & |01|.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = <fs_out>-budat
      IMPORTING
        last_day_of_month = <fs_out>-budat.

    <fs_out>-hkont = VALUE #( lt_zcodt015[ gsber = <fs_out>-gsber
                                           wwsec = <fs_out>-raumn ]-hkont OPTIONAL ).

  ENDLOOP.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

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
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  IF gv_post IS INITIAL.
    dynpost-icon_id      = icon_simulate.
    dynpost-icon_text    = 'Simulate'.
  ELSE.
    dynpost-icon_id      = icon_execute_object.
    dynpost-icon_text    = 'Posting'.
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
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  DATA : lt_xout     TYPE STANDARD TABLE OF ty_out,
         ls_xout     LIKE LINE OF lt_xout,
         ls_out      LIKE LINE OF gt_out,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_rec(6),
         lv_prctr  TYPE prctr,
         lt_ipdata TYPE TABLE OF bapi_copa_data,
         lt_flist  TYPE TABLE OF bapi_copa_field,
         lt_ret    TYPE TABLE OF bapiret2 WITH HEADER LINE.

  DATA : lv_icon(4), lv_testrun(1),
         lv_lines       TYPE i.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.
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
        lt_xout[] = gt_out[].
        DELETE lt_xout WHERE mark IS INITIAL.

        IF gv_post IS NOT INITIAL.
          DELETE lt_xout WHERE icon <> icon_led_green.
          lv_testrun = ' '.
        ELSE.
          lv_testrun = 'X'.
        ENDIF.

        IF lt_xout[] IS NOT INITIAL.
          LOOP AT lt_xout INTO ls_xout.
            ASSIGN gt_out[ bukrs = ls_xout-bukrs
                           gsber = ls_xout-gsber
                           peraf = ls_xout-peraf
                           gjahr = ls_xout-gjahr
                           anln1 = ls_xout-anln1
                           anln2 = ls_xout-anln2
                           kostl = ls_xout-kostl
                           raumn = ls_xout-raumn
                           kfzkz = ls_xout-kfzkz
                           invzu = ls_xout-invzu
                           typbz = ls_xout-typbz ] TO FIELD-SYMBOL(<fs_out>).
            lv_rec  = '000001'.
            CONDENSE <fs_out>-invzu.
            lv_prctr = |{ <fs_out>-invzu ALPHA = IN }|.
            PERFORM f_post_data TABLES lt_ipdata lt_flist lt_ret
                                USING:
              'KOKRS' '8010' lv_rec '' '',
              'BUKRS' <fs_out>-bukrs lv_rec '' '',
              'WERKS' <fs_out>-gsber lv_rec '' '',
              'GSBER' <fs_out>-gsber lv_rec '' '',
              'BUDAT' <fs_out>-budat lv_rec '' '',
              'PERIO' <fs_out>-perio lv_rec '' '',
              'PRCTR' lv_prctr       lv_rec '' '',
              'COPA_KOSTL' <fs_out>-kostl lv_rec '' '',
              'RKAUFNR' <fs_out>-typbz lv_rec '' '',
              'WWSEC' <fs_out>-raumn lv_rec '' '',
              'WWTRZ' <fs_out>-kfzkz lv_rec '' '',
              'VV857' <fs_out>-nafaz lv_rec '1' <fs_out>-waers,
              'WWPRN' <fs_out>-hkont lv_rec '' ''.
*              'KSTAR' <fs_out>-ktnafg lv_rec '' '',
*              'KSTRG' <fs_out>-anln1 lv_rec '' '',
*              'RPOSN' <fs_out>-anln2 lv_rec '' ''.

            CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
              EXPORTING
                operatingconcern = '8010'
                testrun          = lv_testrun          "space
              TABLES
                inputdata        = lt_ipdata
                fieldlist        = lt_flist
                return           = lt_ret.

            IF line_exists( lt_ret[ type = 'E' ] ).
              <fs_out>-icon = icon_led_red.
              <fs_out>-message = VALUE #( lt_ret[ 1 ]-message OPTIONAL ).
            ELSEIF line_exists( lt_ret[ type = 'A' ] ).
              <fs_out>-icon = icon_led_red.
              <fs_out>-message = VALUE #( lt_ret[ 1 ]-message OPTIONAL ).
            ELSE.
              IF lv_testrun IS INITIAL.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = 'X'.

                <fs_out>-mark = ' '.
                <fs_out>-icon = icon_led_green.
                <fs_out>-message = 'POSTED'.
                ls_stylerow-fieldname = 'MARK'.
                ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
                APPEND ls_stylerow TO <fs_out>-style.

                PERFORM f_save_ztable USING <fs_out>.

                CLEAR gv_post.

              ELSE.
                <fs_out>-icon = icon_led_green.
                <fs_out>-message = 'OK'.
              ENDIF.
            ENDIF.

            CLEAR: lt_ipdata, lt_ipdata[],
                   lt_flist, lt_flist[],
                   lt_ret, lt_ret[].
          ENDLOOP.

          PERFORM f_alv_refresh USING 'X'.

          IF gv_post IS INITIAL.
            READ TABLE gt_out WITH KEY icon = icon_led_green
                                       mark = 'X'
                              TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              gv_post = 'X'.
            ELSE.
              CLEAR gv_post.
            ENDIF.
          ENDIF.
        ENDIF.
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
        it_outtab            = gt_out[]
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

*  PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' ''.
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
    'BUKRS' '' '' '' '' '' '' 'BUKRS' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'GSBER' '' '' '' '' '' '' 'GSBER' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'PERAF' '' '' '' '' '' '' 'PERAF' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'GJAHR' '' '' '' '' '' '' 'GJAHR' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'ANLN1' '' '' '' '' '' '' 'ANLN1' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'ANLN2' '' '' '' '' '' '' 'ANLN2' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'KOSTL' '' '' '' '' '' '' 'KOSTL' 'ANLZ' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'INVZU' '' '' '' '' '' '' 'INVZU' 'ANLA' 'Profit Center' '' '' '' '' '' ''
    '' '' '' '' '',
    'TYPBZ' '' '' '' '' '' '' 'TYPBZ' 'ANLA' 'Order' '' '' '' '' '' ''
    '' '' '' '' '',
    'RAUMN' '' '' '' '' '' '' 'RAUMN' 'ANLZ' 'SEC' '' '' '' '' '' ''
    '' '' '' '' '',
    'KFZKZ' '' '' '' '' '' '' 'KFZKZ' 'ANLZ' 'Key Account' '' '' '' '' '' ''
    '' '' '' '' '',
    'NAFAZ' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' '' '' 'Currency' '' '' '' '' '' ''
    '' '' '' '' '',
    'HKONT' '' '' '' '' '' '' 'HKONT' 'ZCODT015' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MESSAGE' '' '' '' '' '' '' '' '' 'Post message' '100' '' '' '' '' ''
    '' '' '' '' ''.
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
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data  TABLES   ft_ipdata STRUCTURE bapi_copa_data
                           ft_flist STRUCTURE bapi_copa_field
                           ft_ret STRUCTURE bapiret2
                  USING    fu_fieldname fu_value
                           fu_rec fu_flag fu_waers.
  DATA : lwa_ipdata LIKE LINE OF ft_ipdata,
         lwa_flist  LIKE LINE OF ft_flist.

  DATA: lv_value(50).

  CLEAR sy-subrc.

  CASE fu_flag.
    WHEN 1.
      WRITE fu_value TO lv_value CURRENCY fu_waers.
      WHILE sy-subrc EQ 0.
        REPLACE '.' WITH space INTO lv_value.
      ENDWHILE.
      CONDENSE lv_value NO-GAPS.
  ENDCASE.

  CLEAR: lwa_ipdata.
  lwa_ipdata-record_id = fu_rec.
  lwa_ipdata-fieldname = fu_fieldname.

  CASE fu_flag.
    WHEN 1.
      lwa_ipdata-value     = lv_value.
      lwa_ipdata-currency  = fu_waers.
    WHEN OTHERS.
      lwa_ipdata-value     = fu_value.
  ENDCASE.

  APPEND lwa_ipdata TO ft_ipdata.
  lwa_flist-fieldname  = lwa_ipdata-fieldname.
  APPEND lwa_flist TO ft_flist.
ENDFORM.                    " F_POST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_ZTABLE
*&---------------------------------------------------------------------*
FORM f_save_ztable  USING    fu_xout.
  DATA: ls_out      TYPE ty_out,
        ls_zcodt012 TYPE zcodt012.

  ls_out = fu_xout.
  ls_zcodt012-bukrs   = ls_out-bukrs.
  ls_zcodt012-gsber   = ls_out-gsber.
  ls_zcodt012-gjahr   = ls_out-gjahr.
  ls_zcodt012-peraf   = ls_out-peraf.
  ls_zcodt012-anln1   = ls_out-anln1.
  ls_zcodt012-anln2   = ls_out-anln2.
  ls_zcodt012-kostl   = ls_out-kostl.
  ls_zcodt012-invzu   = ls_out-invzu.
  ls_zcodt012-typbz   = ls_out-typbz.
  ls_zcodt012-wwsec   = ls_out-raumn.
  ls_zcodt012-wwtrz   = ls_out-kfzkz.
  ls_zcodt012-amount  = ls_out-nafaz.
  ls_zcodt012-waers   = ls_out-waers.

  MODIFY zcodt012 FROM ls_zcodt012.
ENDFORM.
