*&---------------------------------------------------------------------*
*&  Include           ZFI_DEPR_KOSTLF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_gjahr   LIKE LINE OF gr_gjahr,
         ls_peraf   LIKE LINE OF gr_peraf,
         lr_mnr     TYPE RANGE OF fcmnr,
         ls_mnr     LIKE LINE OF lr_mnr.

  SELECT SINGLE *
    FROM t093b
    INTO CORRESPONDING FIELDS OF gs_t093b
    WHERE bukrs = pa_bukrs.

  CASE 'X'.
    WHEN radio1 OR radio3.
      ls_gjahr-low    = pa_gjahr.
      ls_gjahr-sign   = 'I'.
      ls_gjahr-option = 'EQ'.
      APPEND ls_gjahr TO gr_gjahr.
      CLEAR ls_gjahr.
    WHEN radio2 OR radio4.
      ls_gjahr-low    = pa_gjahr - 1.
      gv_gjahr        = ls_gjahr-low.
      ls_gjahr-high   = pa_gjahr.
      ls_gjahr-sign   = 'I'.
      ls_gjahr-option = 'BT'.
      APPEND ls_gjahr TO gr_gjahr.
      CLEAR ls_gjahr.
  ENDCASE.

  ls_peraf-low    = '01'.
  ls_peraf-high   = pa_peraf.
  ls_peraf-sign   = 'I'.
  ls_peraf-option = 'BT'.
  APPEND ls_peraf TO gr_peraf.
  CLEAR ls_peraf.

  ls_mnr-low    = '01'.
  ls_mnr-high   = pa_peraf+1(2).
  ls_mnr-sign   = 'I'.
  ls_mnr-option = 'BT'.
  APPEND ls_mnr TO lr_mnr.
  CLEAR ls_mnr.

  CONCATENATE pa_gjahr pa_peraf+1(2) INTO gv_spmon.
  SELECT *
    FROM t247
    INTO CORRESPONDING FIELDS OF TABLE gt_t247
    WHERE spras = sy-langu
      AND mnr IN lr_mnr.

  PERFORM f_cost_element_hier.
  PERFORM f_cost_center_hier.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  PERFORM f_modify_screen USING : 'PDR' '0' '' '' ''.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION-SCREEN

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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_anlp    TYPE STANDARD TABLE OF anlp,
         lt_anla    TYPE STANDARD TABLE OF anla.

  SELECT *
    FROM anlp
    INTO CORRESPONDING FIELDS OF TABLE gt_anlp
    WHERE bukrs = pa_bukrs
      AND gsber = pa_gsber
      AND gjahr IN gr_gjahr
      AND peraf IN gr_peraf
      AND kostl IN so_kostl.
*      AND afbnr = '01'.

  lt_anlp[] = gt_anlp[].
  SORT lt_anlp BY anln1 anln2.
  DELETE ADJACENT DUPLICATES FROM lt_anlp COMPARING anln1 anln2.
  IF lt_anlp[] IS NOT INITIAL.
    SELECT *
      FROM anla
      INTO CORRESPONDING FIELDS OF TABLE gt_anla
      FOR ALL ENTRIES IN lt_anlp
      WHERE bukrs = pa_bukrs
        AND anln1 = lt_anlp-anln1
        AND anln2 = lt_anlp-anln2.

    SELECT bukrs anln1 anln2 afabe bdatu ndjar ndper
      INTO CORRESPONDING FIELDS OF TABLE gt_anlb
      FROM anlb FOR ALL ENTRIES IN lt_anlp
      WHERE bukrs = pa_bukrs
        AND anln1 = lt_anlp-anln1
        AND anln2 = lt_anlp-anln2.

    SELECT bukrs anln1 anln2 gjahr afabe zujhr zucod kansw knafa
           nafag answl aafag
      INTO CORRESPONDING FIELDS OF TABLE gt_anlc
      FROM anlc FOR ALL ENTRIES IN lt_anlp
      WHERE bukrs = pa_bukrs
        AND anln1 = lt_anlp-anln1
        AND anln2 = lt_anlp-anln2
        AND gjahr = pa_gjahr
        AND afabe = '01'.
  ENDIF.

  lt_anlp[] = gt_anlp[].
  SORT lt_anlp BY ktogr.
  DELETE ADJACENT DUPLICATES FROM lt_anlp COMPARING ktogr.
  IF lt_anlp[] IS NOT INITIAL.
    SELECT ktogr ktnafg ltext
      FROM t095b JOIN csku ON t095b~ktnafg = csku~kstar
      INTO CORRESPONDING FIELDS OF TABLE gt_t095b
      FOR ALL ENTRIES IN lt_anlp
      WHERE t095b~ktopl = 'TSPC'
        AND t095b~ktogr = lt_anlp-ktogr
        AND csku~spras  = sy-langu.
  ENDIF.

  IF radio2 IS NOT INITIAL OR radio4 IS NOT INITIAL.
    IF gt_cskt[] IS NOT INITIAL.
      SELECT *
        FROM aufk
        INTO CORRESPONDING FIELDS OF TABLE gt_aufk
        FOR ALL ENTRIES IN gt_cskt
        WHERE auart = 'ZCEB'
          AND kokrs = '8010'
          AND bukrs = pa_bukrs
          AND gsber = pa_gsber
          AND kostv = gt_cskt-kostl.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_xanlp     TYPE STANDARD TABLE OF anlp,
         ls_setleaf   LIKE LINE OF gt_setleaf,
         ls_xanlp     LIKE LINE OF lt_xanlp,
         ls_anlp      LIKE LINE OF gt_anlp,
         ls_xout      LIKE LINE OF gt_data,
         ls_out       LIKE LINE OF gt_data,
         ls_cskt      LIKE LINE OF gt_cskt,
         ls_aufk      LIKE LINE OF gt_aufk,
         ls_anla      LIKE LINE OF gt_anla,
         ls_anlb      LIKE LINE OF gt_anlb,
         ls_anlc      LIKE LINE OF gt_anlc,
         ls_t095b     LIKE LINE OF gt_t095b,
         ls_leaf      LIKE LINE OF gt_leafkstar,
         ls_text      LIKE LINE OF gt_text1,
         lr_spmon     TYPE RANGE OF spmon,
         ls_spmon     LIKE LINE OF lr_spmon,
         lv_spmon     TYPE spmon,
         ls_t247      LIKE LINE OF gt_t247,
         lt_xaufk     TYPE STANDARD TABLE OF ty_aufk,
         ls_xaufk     LIKE LINE OF lt_xaufk.

  DATA : lv_field(30),
         lv_peraf(2).

  FIELD-SYMBOLS: <fs_field> TYPE ANY.

  SORT gt_anlp BY anln1 anln2 peraf.
  lt_xanlp[] = gt_anlp[].
  SORT lt_xanlp BY anln1 anln2 ktogr kostl.
  DELETE ADJACENT DUPLICATES FROM lt_xanlp COMPARING anln1 anln2 ktogr kostl.

  LOOP AT lt_xanlp INTO ls_xanlp.
    ls_out-kostl  = ls_xanlp-kostl.
    READ TABLE gt_leafkostl INTO ls_setleaf
                            WITH KEY valfrom = ls_out-kostl.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_cskt.
    READ TABLE gt_cskt INTO ls_cskt
                       WITH KEY kostl = ls_xanlp-kostl.
    IF sy-subrc = 0.
      ls_out-ltext1   = ls_cskt-ltext.
    ENDIF.

    CLEAR : ls_t095b.
    READ TABLE gt_t095b INTO ls_t095b
                        WITH KEY ktogr = ls_xanlp-ktogr.
    IF sy-subrc = 0.
      ls_out-ktnafg   = ls_t095b-ktnafg.
      ls_out-ltext2   = ls_t095b-ltext.
      CLEAR ls_leaf.
      READ TABLE gt_leafkstar INTO ls_leaf
                              WITH KEY valfrom = ls_t095b-ktnafg.
      IF sy-subrc = 0.
        CLEAR ls_text.
        READ TABLE gt_text1 INTO ls_text
                            WITH KEY setclass = ls_leaf-setclass
                                     subclass = ls_leaf-subclass
                                     setname  = ls_leaf-setname.
        IF sy-subrc = 0.
          ls_out-descript = ls_text-descript.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM f_color_modify USING 'DESCRIPT' '1' '1' '1'
                           CHANGING ls_out-color.

    ls_out-anln1  = ls_xanlp-anln1.
    ls_out-anln2  = ls_xanlp-anln2.

    CLEAR: ls_anlb,ls_anlc.
    READ TABLE gt_anlb INTO ls_anlb
                       WITH KEY anln1 = ls_xanlp-anln1
                                anln2 = ls_xanlp-anln2.

    READ TABLE gt_anlc INTO ls_anlc
                       WITH KEY anln1 = ls_xanlp-anln1
                                anln2 = ls_xanlp-anln2
                                gjahr = pa_gjahr.

    IF ls_anlc-kansw IS INITIAL.
      ls_out-kansw = ls_anlc-answl.
    ELSE.
      ls_out-kansw = ls_anlc-kansw.
    ENDIF.

    ls_out-ndjar = ls_anlb-ndjar.
*    ls_out-kansw = ls_anlc-kansw.
    ls_out-knafa = ls_anlc-knafa * -1.
    ls_out-nafag = ( ls_anlc-nafag * -1 ) + ( ls_anlc-aafag * -1 ).
*    ls_out-netbookval = ls_out-kansw - ls_out-knafa - ls_out-nafag.

    CLEAR ls_anla.
    READ TABLE gt_anla INTO ls_anla
                       WITH KEY anln1 = ls_xanlp-anln1
                                anln2 = ls_xanlp-anln2.
    IF sy-subrc = 0.
      ls_out-txt50   = ls_anla-txt50.
      ls_out-aktiv   = ls_anla-aktiv.
      ls_out-sernr   = ls_anla-sernr.
      ls_out-invzu   = ls_anla-invzu.

      IF radio2 IS NOT INITIAL OR radio4 IS NOT INITIAL.
        CLEAR ls_aufk.
        READ TABLE gt_aufk INTO ls_aufk
                           WITH KEY aufnr = ls_anla-eaufn.
        IF sy-subrc = 0.
          ls_spmon-low    = ls_aufk-user7(6).
          ls_spmon-high   = ls_aufk-user8(6).
          ls_spmon-sign   = 'I'.
          ls_spmon-option = 'BT'.
          APPEND ls_spmon TO lr_spmon.
          CLEAR ls_spmon.
          ls_aufk-mark = 'X'.
          MODIFY gt_aufk FROM ls_aufk
                         TRANSPORTING mark
                         WHERE aufnr = ls_anla-eaufn.

          ls_out-aufnr  = ls_aufk-aufnr.
          ls_out-ktext  = ls_aufk-ktext.
        ENDIF.
        IF gv_spmon IN lr_spmon.
          ls_out-nafaz05  = ls_aufk-user4.
        ENDIF.
        CLEAR ls_t247.
        LOOP AT gt_t247 INTO ls_t247.
          CLEAR lv_spmon.
          CONCATENATE pa_gjahr ls_t247-mnr INTO lv_spmon.
          IF lv_spmon IN lr_spmon.
            ADD ls_aufk-user4 TO ls_out-nafaz06.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    ls_out-gjahr  = pa_gjahr.
    ls_out-waers  = gs_t093b-waers.

    CLEAR : ls_anlp, ls_xout.
    LOOP AT gt_anlp INTO ls_anlp WHERE anln1 = ls_xanlp-anln1
                                   AND anln2 = ls_xanlp-anln2
                                   AND ktogr = ls_xanlp-ktogr
                                   AND kostl = ls_xanlp-kostl.
      ls_anlp-nafaz = ls_anlp-nafaz * -1.
      ls_anlp-aafaz = ls_anlp-aafaz * -1.

      CASE 'X'.
        WHEN radio1 OR radio3.
          ADD ls_anlp-nafaz TO ls_xout-total.
*          CASE ls_anlp-peraf.
*            WHEN '01'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz01.
*            WHEN '02'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz02.
*            WHEN '03'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz03.
*            WHEN '04'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz04.
*            WHEN '05'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz05.
*            WHEN '06'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz06.
*            WHEN '07'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz07.
*            WHEN '08'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz08.
*            WHEN '09'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz09.
*            WHEN '10'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz10.
*            WHEN '11'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz11.
*            WHEN '12'.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz12.
*          ENDCASE.
          CLEAR: lv_field,lv_peraf.
          UNASSIGN: <fs_field>.
          lv_peraf = ls_anlp-peraf+1(2).
          CONCATENATE 'LS_XOUT-NAFAZ' lv_peraf INTO lv_field.
          ASSIGN (lv_field) TO <fs_field>.
          PERFORM f_summaries_field1 USING    ls_anlp-nafaz
                                              ls_anlp-aafaz
                                     CHANGING <fs_field>.

        WHEN radio2 OR radio4.
          IF ls_anlp-gjahr = gv_gjahr.
            IF ls_anlp-peraf = pa_peraf.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz01.
              PERFORM f_summaries_field1 USING    ls_anlp-nafaz
                                                  ls_anlp-aafaz
                                         CHANGING ls_xout-nafaz01.
            ENDIF.
            IF ls_anlp-peraf IN gr_peraf.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz03.
              PERFORM f_summaries_field1 USING    ls_anlp-nafaz
                                                  ls_anlp-aafaz
                                         CHANGING ls_xout-nafaz03.
            ENDIF.
          ELSEIF ls_anlp-gjahr = pa_gjahr.
            IF ls_anlp-peraf = pa_peraf.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz02.
              PERFORM f_summaries_field1 USING    ls_anlp-nafaz
                                                  ls_anlp-aafaz
                                         CHANGING ls_xout-nafaz02.
            ENDIF.
            IF ls_anlp-peraf IN gr_peraf.
*              ADD ls_anlp-nafaz TO ls_xout-nafaz04.
              PERFORM f_summaries_field1 USING    ls_anlp-nafaz
                                                  ls_anlp-aafaz
                                         CHANGING ls_xout-nafaz04.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    CASE 'X'.
      WHEN radio1 OR radio3.
        ls_out-nafaz01 = ls_xout-nafaz01.
        ls_out-nafaz02 = ls_xout-nafaz02.
        ls_out-nafaz03 = ls_xout-nafaz03.
        ls_out-nafaz04 = ls_xout-nafaz04.
        ls_out-nafaz05 = ls_xout-nafaz05.
        ls_out-nafaz06 = ls_xout-nafaz06.
        ls_out-nafaz07 = ls_xout-nafaz07.
        ls_out-nafaz08 = ls_xout-nafaz08.
        ls_out-nafaz09 = ls_xout-nafaz09.
        ls_out-nafaz10 = ls_xout-nafaz10.
        ls_out-nafaz11 = ls_xout-nafaz11.
        ls_out-nafaz12 = ls_xout-nafaz12.

        ls_out-q01     = ls_xout-nafaz01 + ls_xout-nafaz02 + ls_xout-nafaz03.
        ls_out-q02     = ls_xout-nafaz04 + ls_xout-nafaz05 + ls_xout-nafaz06.
        ls_out-q03     = ls_xout-nafaz07 + ls_xout-nafaz08 + ls_xout-nafaz09.
        ls_out-q04     = ls_xout-nafaz10 + ls_xout-nafaz11 + ls_xout-nafaz12.
        ls_out-s01     = ls_out-q01 + ls_out-q02.
        ls_out-s02     = ls_out-q03 + ls_out-q04.

        PERFORM f_color_modify USING 'Q01' '3' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'Q02' '3' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'Q03' '3' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'Q04' '3' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'Q04' '3' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'S01' '7' '1' '1'
                               CHANGING ls_out-color.
        PERFORM f_color_modify USING 'S02' '7' '1' '1'
                               CHANGING ls_out-color.

        ls_out-total   = ls_xout-total.
      WHEN radio2 OR radio4.
        ls_out-nafaz01 = ls_xout-nafaz01.
        ls_out-nafaz02 = ls_xout-nafaz02.
        ls_out-nafaz03 = ls_xout-nafaz03.
        ls_out-nafaz04 = ls_xout-nafaz04.
    ENDCASE.

    ls_out-netbookval = ls_out-kansw - ls_out-knafa - ls_out-total.

    APPEND ls_out TO gt_data.
    CLEAR ls_out.
  ENDLOOP.

  PERFORM f_add_budget_without_asset.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
*  CLEAR pa_drill.

  IF gt_data[] IS NOT INITIAL.
    gt_out[]  = gt_data[].

    CASE 'X'.
      WHEN radio1 OR radio2.
        IF pa_drill IS INITIAL.
          CALL SCREEN 101.
        ELSE.
          CALL SCREEN 102.
        ENDIF.

      WHEN radio3 OR radio4.
        PERFORM f_write_abaplist.
    ENDCASE.
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
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         dynlog   TYPE smp_dyntxt.

  CREATE OBJECT event_receiver.

  gs_variant-report = gv_repid.
  gv_dynnr = sy-dynnr.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE1'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMANND
*&---------------------------------------------------------------------*
FORM f_user_commannd .
  DATA : lv_ucomm   TYPE sy-ucomm,
         lv_valid   TYPE c.

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

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMANND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

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

  PERFORM f_alv_sort USING : 1 'KOSTL' 'X' '' '',
                             2 'DESCRIPT' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
*    'X' 'X' '' '' '',
*    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
*    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    '' 'KOSTL' '' '' '' '' '' '' 'KOSTL' 'ANLP' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    '' 'LTEXT1' '' '' '' '' '' '' 'LTEXT' 'CSKT' 'Cost Ctr Desc.' ''
    '' '' '' '' '' '' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    '' 'DESCRIPT' '' '' '' '' '' '' 'DESCRIPT' 'SETHEADERT' 'G/L Group'
    '' '' '' '' '' '' '' 'X' '' '' '',
    '' 'KTNAFG' '' '' '' '' '' '' 'KTNAFG' 'T095B' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    '' 'LTEXT2' '' '' '' '' '' '' 'TXT50' 'SKAT' 'G/L Acct. Desc.' ''
    '' '' '' '' '' '' 'X' '' '' '',
    '' 'ANLN1' '' '' '' '' '' '' 'ANLN1' 'ANLP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'ANLN2' '' '' '' '' '' '' 'ANLN2' 'ANLP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'AKTIV' '' '' '' '' '' '' 'AKTIV' 'ANLA' '' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'TXT50' '' '' '' '' '' '' 'TXT50' 'ANLA' '' '' '' '' '' '' ''
    '' '' '' '' ''.
  IF radio2 IS NOT INITIAL OR radio4 IS NOT INITIAL.
    PERFORM f_dyn_int_table USING :
      '' 'AUFNR' '' '' '' '' '' '' 'AUFNR' 'AUFK' '' '' '' '' '' '' ''
      '' '' '' '' '',
      '' 'KTEXT' '' '' '' '' '' '' 'KTEXT' 'AUFK' '' '' '' '' '' '' ''
      '' '' '' '' ''.
  ENDIF.
  PERFORM f_dyn_int_table USING :
'' 'GJAHR' '' '' '' '' '' '' 'GJAHR' 'ANLP' '' '' '' '' '' '' ''
'' '' '' '' '',
'' 'WAERS' '' '' '' '' '' '' 'WAERS' 'T093B' '' '' '' '' '' '' ''
'' '' '' '' ''.
  CASE 'X'.
    WHEN radio1 OR radio3.
      PERFORM f_dyn_int_table USING :
        '' 'NAFAZ01' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Januari' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ02' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Februari' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ03' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Maret' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'Q01' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Quarter 1' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ04' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'April' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ05' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Mei' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ06' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Juni' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'Q02' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Quarter 2' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'S01' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Semester 1' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ07' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Juli' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ08' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Agustus' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ09' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'September' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'Q03' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Quarter 3' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ10' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Oktober' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ11' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'November' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ12' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Desember' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'Q04' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Quarter 4' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'S02' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Semester 2' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'TOTAL' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Total' ''
        '' '' '' '' '' '' '' '' '' ''.
    WHEN radio2 OR radio4.
      PERFORM f_dyn_int_table USING :
        '' 'NAFAZ01' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Actual LY MTD' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ02' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Actual CY MTD' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ03' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Actual LY YTD' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ04' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Actual CY YTD' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ05' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Budget MTD' ''
        '' '' '' '' '' '' '' '' '' '',
        '' 'NAFAZ06' '' '' 'WAERS' '' '' '' 'NAFAZ' 'ANLP' 'Budget YTD' ''
        '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.

  PERFORM f_dyn_int_table USING :
    '' 'SERNR' '' '' '' '' '' '' 'SERNR' 'ANLA' 'RFA No.' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'INVZU' '' '' '' '' '' '' 'INVZU' 'ANLA' 'JO No.' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'NDJAR' '' '' '' '' '' '' 'NDJAR' 'ANLB' 'Useful Life' '' '' '' '' '' ''
    '' '' '' '' '',
    '' 'KANSW' '' '' 'WAERS' '' '' '' 'KANSW' 'ANLC' 'Capitalize Amount' ''
    '' '' '' '' '' '' '' '' '' '',
    '' 'KNAFA' '' '' 'WAERS' '' '' '' 'KNAFA' 'ANLC' 'Accum. Deper.' ''
    '' '' '' '' '' '' '' '' '' '',
    '' 'NAFAG' '' '' 'WAERS' '' '' '' 'NAFAG' 'ANLP' '' ''
    '' '' '' '' '' '' '' '' '' '',
    '' 'NETBOOKVAL' '' '' 'WAERS' '' '' '' 'NETBOOKVAL' 'ZFISTDEPR' '' ''
    '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_type fu_fieldname fu_tabname
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
  CASE fu_type.
    WHEN 'TREE'.
      APPEND ls_dyn_fcat TO gt_fieldcat.
    WHEN OTHERS.
      APPEND ls_dyn_fcat TO gt_main_fieldcat.
  ENDCASE.
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
         ls_stylerow        TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_data.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_data INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.
        ls_out-mark = fu_check.
        MODIFY gt_data FROM ls_out.
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
*&      Form  F_COST_ELEMENT_HIER
*&---------------------------------------------------------------------*
FORM f_cost_element_hier .
  DATA : lt_leaf    TYPE STANDARD TABLE OF setleaf.

  SELECT *
    FROM setnode
    INTO CORRESPONDING FIELDS OF TABLE gt_nodekstar
    WHERE setclass = '0102'
      AND subclass = 'TSPC'
      AND setname  = 'TSPDEPRE'.

  IF gt_nodekstar[] IS NOT INITIAL.
    SELECT *
      FROM setleaf
      INTO CORRESPONDING FIELDS OF TABLE gt_leafkstar
      FOR ALL ENTRIES IN gt_nodekstar
      WHERE setclass = gt_nodekstar-subsetcls
        AND subclass = gt_nodekstar-subsetscls
        AND setname  = gt_nodekstar-subsetname.

    lt_leaf[] = gt_leafkstar[].
    SORT lt_leaf BY setclass subclass setname.
    DELETE ADJACENT DUPLICATES FROM lt_leaf COMPARING setclass subclass setname.
    IF lt_leaf[] IS NOT INITIAL.
      SELECT *
        FROM setheadert
        INTO CORRESPONDING FIELDS OF TABLE gt_text1
        FOR ALL ENTRIES IN lt_leaf
        WHERE setclass = lt_leaf-setclass
          AND subclass = lt_leaf-subclass
          AND setname  = lt_leaf-setname
          AND langu    = sy-langu.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_COST_ELEMENT_HIER

*&---------------------------------------------------------------------*
*&      Form  F_COST_CENTER_HIER
*&---------------------------------------------------------------------*
FORM f_cost_center_hier .
  DATA : ls_setnode   LIKE LINE OF gt_setnode,
         ls_setleaf   LIKE LINE OF gt_setleaf,
         lt_text      TYPE STANDARD TABLE OF ty_key,
         ls_text      LIKE LINE OF lt_text.

  ls_text-setclass  = '0101'.
  ls_text-subclass  = '8010'.
  ls_text-setname   = 'TSP'.
  APPEND ls_text TO lt_text.

  PERFORM f_get_description TABLES lt_text
                            USING ''.

  SELECT *
    FROM setnode
    INTO CORRESPONDING FIELDS OF TABLE gt_setnode
    WHERE setclass = '0101'
      AND subclass = '8010'
      AND setname  = 'TSP'
      AND subsetname  <> 'HO_TSP'.

  IF gt_setnode[] IS NOT INITIAL.
    LOOP AT gt_setnode  INTO ls_setnode.
      ls_text-setclass  = ls_setnode-subsetcls.
      ls_text-subclass  = ls_setnode-subsetscls.
      ls_text-setname   = ls_setnode-subsetname.
      APPEND ls_text TO lt_text.
    ENDLOOP.
    PERFORM f_get_description TABLES lt_text
                              USING ''.

    SELECT *
      FROM setnode
      INTO CORRESPONDING FIELDS OF TABLE gt_nodekostl
      FOR ALL ENTRIES IN gt_setnode
      WHERE setclass = gt_setnode-subsetcls
        AND subclass = gt_setnode-subsetscls
        AND setname  = gt_setnode-subsetname.

    IF gt_nodekostl[] IS NOT INITIAL.
      LOOP AT gt_nodekostl  INTO ls_setnode.
        ls_text-setclass  = ls_setnode-subsetcls.
        ls_text-subclass  = ls_setnode-subsetscls.
        ls_text-setname   = ls_setnode-subsetname.
        APPEND ls_text TO lt_text.
      ENDLOOP.
      PERFORM f_get_description TABLES lt_text
                                USING ''.

      SELECT *
        FROM setleaf
        INTO CORRESPONDING FIELDS OF TABLE gt_leafkostl
        FOR ALL ENTRIES IN gt_nodekostl
        WHERE setclass = gt_nodekostl-subsetcls
          AND subclass = gt_nodekostl-subsetscls
          AND setname  = gt_nodekostl-subsetname.
      IF gt_leafkostl[] IS NOT INITIAL.
        LOOP AT gt_leafkostl  INTO ls_setleaf.
          ls_text-kostl     = ls_setleaf-valfrom.
          APPEND ls_text TO lt_text.
        ENDLOOP.
        PERFORM f_get_description TABLES lt_text
                                  USING 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_COST_CENTER_HIER

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER1
*&---------------------------------------------------------------------*
FORM f_docking_split_container1 .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.
  IF g_docking IS INITIAL.
    CREATE OBJECT g_docking
      EXPORTING
        repid     = gv_repid
        dynnr     = gv_dynnr
        side      = g_docking->dock_at_left
        extension = 280.
  ENDIF.

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

*    CALL METHOD g_splitter->set_column_width
*      EXPORTING
*        id    = 1
*        width = 22.
*
*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain01.

*    CREATE OBJECT g_tree
*      EXPORTING
*        node_selection_mode = cl_simple_tree_model=>node_sel_mode_single.
*
*    CALL METHOD g_tree->create_tree_control
*      EXPORTING
*        parent = g_contain02.

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
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER1

*&---------------------------------------------------------------------*
*&      Form  F_TREE_ALV
*&---------------------------------------------------------------------*
FORM f_tree_alv .
  PERFORM f_dyn_int_table USING :
    'TREE' 'NODE_MAIN' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.

  CREATE OBJECT g_tree
    EXPORTING
      parent                      = g_docking
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = 'X'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.

  CALL METHOD g_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = g_header
      i_save              = 'A'
      is_variant          = gs_variant
    CHANGING
      it_outtab           = gt_tree
      it_fieldcatalog     = gt_fieldcat.
ENDFORM.                    " F_TREE_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description TABLES ft_text   LIKE gt_key
                       USING  fu_flag.
  DATA : ls_cskt    LIKE LINE OF gt_cskt,
         ls_text    LIKE LINE OF gt_text.

  IF gt_text[] IS INITIAL.
    SELECT *
      FROM setheadert
      INTO CORRESPONDING FIELDS OF TABLE gt_text
      FOR ALL ENTRIES IN ft_text
      WHERE setclass = ft_text-setclass
        AND subclass = ft_text-subclass
        AND setname  = ft_text-setname
        AND langu    = sy-langu.
  ELSE.
    IF fu_flag IS INITIAL.
      SELECT *
        FROM setheadert
        APPENDING CORRESPONDING FIELDS OF TABLE gt_text
        FOR ALL ENTRIES IN ft_text
        WHERE setclass = ft_text-setclass
          AND subclass = ft_text-subclass
          AND setname  = ft_text-setname
          AND langu    = sy-langu.
    ELSE.
      SELECT *
        FROM cskt
        INTO CORRESPONDING FIELDS OF TABLE gt_cskt
        FOR ALL ENTRIES IN ft_text
        WHERE spras = sy-langu
          AND kokrs = '8010'
          AND kostl = ft_text-kostl.

      LOOP AT gt_cskt INTO ls_cskt.
        ls_text-setname   = ls_cskt-kostl.
        ls_text-descript  = ls_cskt-ltext.
        APPEND ls_text TO gt_text.
        CLEAR ls_text.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR ft_text[].
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
FORM f_get_text  USING    fu_setclass fu_subclass fu_setname
                 CHANGING fc_text.
  DATA : ls_text      LIKE LINE OF gt_text.

  READ TABLE gt_text INTO ls_text
                     WITH KEY setclass = fu_setclass
                              subclass = fu_subclass
                              setname  = fu_setname.
  IF sy-subrc = 0.
    fc_text = ls_text-descript.
*    CONCATENATE ls_text-setname ls_text-descript INTO fc_text
*    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER
*&---------------------------------------------------------------------*
FORM f_build_header  CHANGING fc_header   TYPE treev_hhdr.
  fc_header-heading   = 'Cost Center'.
  fc_header-width     = 25.
  fc_header-width_pix = ''..
ENDFORM.                    " F_BUILD_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_EVENT
*&---------------------------------------------------------------------*
FORM f_register_event .
  DATA : lt_events  TYPE cntl_simple_events,
         ls_event   TYPE cntl_simple_event.

  CALL METHOD g_tree->get_registered_events
    IMPORTING
      events = lt_events.

  ls_event-eventid    = cl_gui_column_tree=>eventid_item_double_click.
  ls_event-appl_event = 'X'.
  APPEND ls_event TO lt_events.

  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.

  SET HANDLER event_receiver->handle_item_double_click FOR g_tree.

ENDFORM.                    " F_REGISTER_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_create_hierarchy .
  DATA : ls_setnode     LIKE LINE OF gt_setnode,
         ls_nodekostl   LIKE LINE OF gt_nodekostl,
         ls_leafkostl   LIKE LINE OF gt_leafkostl,
         ls_tree        LIKE LINE OF gt_tree,
         lv_key1        TYPE lvc_nkey,
         lv_key2        TYPE lvc_nkey,
         lv_key3        TYPE lvc_nkey,
         lv_key4        TYPE lvc_nkey,
         lv_node        TYPE lvc_value,
         lv_text(100).

  CLEAR : lv_node, ls_tree.
  PERFORM f_get_text USING '0101' '8010' 'TSP'
                     CHANGING lv_text.
  lv_node = 'TSP'.
  ls_tree-node_main = lv_text.

  PERFORM f_add_node_main USING    ls_tree '' lv_node ''
                          CHANGING lv_key1.

  LOOP AT gt_setnode INTO ls_setnode WHERE setname  = 'TSP'.
    CLEAR : lv_node, ls_tree.
    PERFORM f_get_text USING ls_setnode-subsetcls ls_setnode-subsetscls
                             ls_setnode-subsetname
                       CHANGING lv_text.

    lv_node = ls_setnode-subsetname.
    ls_tree-node_main = lv_text.

    PERFORM f_add_node_main USING    ls_tree lv_key1 lv_node ''
                            CHANGING lv_key2.

    LOOP AT gt_nodekostl INTO ls_nodekostl WHERE setname = ls_setnode-subsetname.
      CLEAR : lv_node, ls_tree.
      PERFORM f_get_text USING ls_nodekostl-subsetcls ls_nodekostl-subsetscls
                               ls_nodekostl-subsetname
                         CHANGING lv_text.

      lv_node = ls_nodekostl-subsetname.
      ls_tree-node_main = lv_text.

      PERFORM f_add_node_main USING    ls_tree lv_key2 lv_node ''
                              CHANGING lv_key3.

      LOOP AT gt_leafkostl INTO ls_leafkostl WHERE setname = ls_nodekostl-subsetname.
        CLEAR : lv_node, ls_tree.
        PERFORM f_get_text USING '' ''
                                 ls_leafkostl-valfrom
                           CHANGING lv_text.

        lv_node = ls_leafkostl-valfrom.
        ls_tree-node_main = lv_text.

        PERFORM f_add_node_main USING    ls_tree lv_key3 lv_node 'X'
                                CHANGING lv_key4.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  CALL METHOD g_tree->frontend_update.

ENDFORM.                    " F_CREATE_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NODE_MAIN
*&---------------------------------------------------------------------*
FORM f_add_node_main  USING    fu_aux        TYPE ty_tree
                               fu_relat_key  TYPE lvc_nkey
                               fu_node       TYPE lvc_value
                               fu_leaf
                     CHANGING  fc_node_key   TYPE lvc_nkey.

  DATA : lv_node_text   TYPE lvc_value,
         lt_item_layout TYPE lvc_t_layi,
         ls_item_layout TYPE lvc_s_layi,
         ls_node_layout TYPE lvc_s_layn.

  IF fu_leaf IS NOT INITIAL.
    ls_node_layout-n_image   = icon_cost_center.
  ENDIF.

  ls_item_layout-fieldname = g_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO lt_item_layout.
  CLEAR ls_item_layout.

  lv_node_text =  fu_node.

  CALL METHOD g_tree->add_node
    EXPORTING
      i_relat_node_key = fu_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = lv_node_text
      is_outtab_line   = fu_aux
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = fc_node_key.
ENDFORM.                    " F_ADD_NODE_MAIN

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_ITEM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_item_double_click  USING    fu_fieldname
                                          fu_node_key.
  DATA : node_text        TYPE lvc_value,
         item_layout      TYPE lvc_t_layi,
         node_layout      TYPE lvc_s_layn.

  DATA : ls_node          LIKE LINE OF gt_nodekostl,
         ls_leaf          LIKE LINE OF gt_leafkostl,
         lt_key           TYPE STANDARD TABLE OF ty_key,
         ls_key           LIKE LINE OF gt_key,
         ls_data          LIKE LINE OF gt_data.

  CLEAR : gt_out[].

  CALL METHOD g_tree->get_outtab_line
    EXPORTING
      i_node_key     = fu_node_key
    IMPORTING
      e_node_text    = node_text
      et_item_layout = item_layout
      es_node_layout = node_layout.

  CASE node_text.
    WHEN 'TSP'.
      gt_out[] = gt_data[].
    WHEN OTHERS.
      READ TABLE gt_nodekostl INTO ls_node
                              WITH KEY setname = node_text.
      IF sy-subrc = 0.
        LOOP AT gt_nodekostl INTO ls_node WHERE setname = node_text.
          LOOP AT gt_leafkostl INTO ls_leaf WHERE setname = ls_node-subsetname.
            ls_key-kostl  = ls_leaf-valfrom.
            APPEND ls_key TO lt_key.
            CLEAR ls_key.
          ENDLOOP.
        ENDLOOP.
      ELSE.
        READ TABLE gt_leafkostl INTO ls_leaf
                                WITH KEY setname = node_text.
        IF sy-subrc = 0.
          LOOP AT gt_leafkostl INTO ls_leaf WHERE setname = node_text.
            ls_key-kostl  = ls_leaf-valfrom.
            APPEND ls_key TO lt_key.
            CLEAR ls_key.
          ENDLOOP.
        ELSE.
          ls_key-kostl  = node_text.
          APPEND ls_key TO lt_key.
          CLEAR ls_key.
        ENDIF.
      ENDIF.

      IF lt_key[] IS NOT INITIAL.
        LOOP AT gt_data INTO ls_data.
          CLEAR ls_key.
          READ TABLE lt_key INTO ls_key
                            WITH KEY kostl = ls_data-kostl.
          IF sy-subrc = 0.
            APPEND ls_data TO gt_out.
            CLEAR ls_data.
          ENDIF.

        ENDLOOP.
      ENDIF.
  ENDCASE.

  PERFORM f_alv_refresh USING 'X'.

ENDFORM.                    " F_HANDLE_ITEM_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_COLOR_MODIFY
*&---------------------------------------------------------------------*
FORM f_color_modify  USING    fu_fieldname fu_col fu_int fu_inv
                     CHANGING fc_color.
  DATA : ls_cellcolor       TYPE lvc_s_scol.

  CLEAR ls_cellcolor.

  ls_cellcolor-fname      = fu_fieldname.
  ls_cellcolor-color-col  = fu_col.
  ls_cellcolor-color-int  = fu_int.
  ls_cellcolor-color-inv  = fu_inv.
  INSERT ls_cellcolor INTO TABLE gt_cellcolor.
  fc_color = gt_cellcolor.
ENDFORM.                    " F_COLOR_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_ADD_BUDGET_WITHOUT_ASSET
*&---------------------------------------------------------------------*
FORM f_add_budget_without_asset .
  DATA : lt_xaufk   TYPE STANDARD TABLE OF ty_aufk,
         ls_xaufk   LIKE LINE OF lt_xaufk,
         ls_out     LIKE LINE OF gt_out,
         ls_cskt    LIKE LINE OF gt_cskt,
         ls_t247    LIKE LINE OF gt_t247,
         lr_spmon   TYPE RANGE OF spmon,
         ls_spmon   LIKE LINE OF lr_spmon,
         lv_spmon   TYPE spmon.

  lt_xaufk[] = gt_aufk[].
  DELETE lt_xaufk WHERE mark IS NOT INITIAL.
  LOOP AT lt_xaufk INTO ls_xaufk.
    ls_out-kostl  = ls_xaufk-kostv.
    ls_out-aufnr  = ls_xaufk-aufnr.
    ls_out-ktext  = ls_xaufk-ktext.
    ls_out-gjahr  = pa_gjahr.
    ls_out-waers  = 'IDR'.

    READ TABLE gt_cskt INTO ls_cskt
                       WITH KEY kostl = ls_xaufk-kostv.
    IF sy-subrc = 0.
      ls_out-ltext1   = ls_cskt-ltext.
    ENDIF.

    CLEAR lr_spmon[].
    ls_spmon-low    = ls_xaufk-user7(6).
    ls_spmon-high   = ls_xaufk-user8(6).
    ls_spmon-sign   = 'I'.
    ls_spmon-option = 'BT'.
    APPEND ls_spmon TO lr_spmon.
    CLEAR ls_spmon.

    IF gv_spmon IN lr_spmon.
      ls_out-nafaz05  = ls_xaufk-user4.
    ENDIF.
    CLEAR ls_t247.
    LOOP AT gt_t247 INTO ls_t247.
      CLEAR lv_spmon.
      CONCATENATE pa_gjahr ls_t247-mnr INTO lv_spmon.
      IF lv_spmon IN lr_spmon.
        ADD ls_xaufk-user4 TO ls_out-nafaz06.
      ENDIF.
    ENDLOOP.
    APPEND ls_out TO gt_data.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_ADD_BUDGET_WITHOUT_ASSET

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ABAPLIST
*&---------------------------------------------------------------------*
FORM f_write_abaplist .
  PERFORM f_alv TABLES gt_out.

*  DATA: ls_out  LIKE LINE OF gt_out,
*        ls_out1 LIKE LINE OF gt_out,
*        ls_out2 LIKE LINE OF gt_out,
*        ls_out3 LIKE LINE OF gt_out,
*        lv_txt1(55), lv_txt1t(55),
*        lv_txt2(40), lv_txt2t(40),
*        lv_txt3(55), lv_txt3t(55),
*        sw1,sw2,sw3,sw4,sw5,sw6.
*
*  WRITE: /(568) sy-uline.
*
*  SORT gt_out BY kostl ltext1 descript ktnafg ltext2 anln1 anln2 aktiv.
*  LOOP AT gt_out INTO ls_out.
*
*    CLEAR: lv_txt1,lv_txt2,lv_txt3,lv_txt1t,lv_txt2t,lv_txt3t,
*           sw1,sw2,sw3,sw4,sw5,sw6.
*    CONCATENATE ls_out-kostl ls_out-ltext1 INTO lv_txt1 SEPARATED BY ' - '.
*    lv_txt2 = ls_out-descript.
*    CONCATENATE ls_out-ktnafg ls_out-ltext2 INTO lv_txt3 SEPARATED BY ' - '.
*    CONCATENATE 'T O T A L' ls_out-kostl ls_out-ltext1 INTO lv_txt1t SEPARATED BY ' - '.
*    CONCATENATE 'T O T A L' ls_out-descript INTO lv_txt2t SEPARATED BY ' - '.
*    CONCATENATE 'T O T A L' ls_out-ktnafg ls_out-ltext2 INTO lv_txt3t SEPARATED BY ' - '.
*
*    AT NEW kostl.
*      WRITE: / '|' NO-GAP,
*              (55) lv_txt1 NO-GAP, '|' NO-GAP,
*              (40) lv_txt2 NO-GAP, '|' NO-GAP,
*              (55) lv_txt3 NO-GAP, '|' NO-GAP.
*      sw1 = sw2 = sw3 = '1'.
*      CLEAR: ls_out1,ls_out2,ls_out3.
*    ENDAT.
*
*    AT NEW descript.
*      IF sw1 IS INITIAL.
*        WRITE: / '|' NO-GAP,
*                (55) ' ' NO-GAP, '|' NO-GAP,
*                (40) lv_txt2 NO-GAP, '|' NO-GAP,
*                (55) lv_txt3 NO-GAP, '|' NO-GAP.
*        sw2 = sw3 = '1'.
*      ENDIF.
*      CLEAR: ls_out2,ls_out3.
*    ENDAT.
*
*    AT NEW ktnafg.
*      IF sw2 IS INITIAL.
*        WRITE: / '|' NO-GAP,
*                (55) ' ' NO-GAP, '|' NO-GAP,
*                (40) ' ' NO-GAP, '|' NO-GAP,
*                (55) lv_txt3 NO-GAP, '|' NO-GAP.
*        sw3 = '1'.
*      ENDIF.
*      CLEAR: ls_out3.
*    ENDAT.
*
*    CASE 'X'.
*      WHEN radio3.
*        IF sw1 IS INITIAL AND sw2 IS INITIAL AND sw3 IS INITIAL.
*          WRITE: / '|' NO-GAP,
*                  (55) ' ' NO-GAP, '|' NO-GAP,
*                  (40) ' ' NO-GAP, '|' NO-GAP,
*                  (55) ' ' NO-GAP, '|' NO-GAP,
*                  (12) ls_out-anln1 NO-GAP, '|' NO-GAP.
*        ELSE.
*          WRITE: 155(12) ls_out-anln1 NO-GAP, '|' NO-GAP.
*        ENDIF.
*
*        WRITE: 168(4) ls_out-anln2 NO-GAP, '|' NO-GAP,
*                (10) ls_out-aktiv NO-GAP, '|' NO-GAP,
*                (50) ls_out-txt50 NO-GAP, '|' NO-GAP,
*                 (4) ls_out-gjahr NO-GAP, '|' NO-GAP,
*                 (5) ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz01 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz02 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz03 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-q01     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz04 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz05 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz06 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-q02     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-s01     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz07 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz08 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz09 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-q03     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz10 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz11 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-nafaz12 CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-q04     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-s02     CURRENCY ls_out-waers NO-GAP, '|' NO-GAP,
*                (16) ls_out-total   CURRENCY ls_out-waers NO-GAP, '|' NO-GAP.
*
*        MOVE: ls_out-waers TO ls_out1-waers,
*              ls_out-waers TO ls_out2-waers,
*              ls_out-waers TO ls_out3-waers.
*
*        ADD: ls_out-q01 TO ls_out1-q01,
*             ls_out-q01 TO ls_out2-q01,
*             ls_out-q01 TO ls_out3-q01,
*             ls_out-q02 TO ls_out1-q02,
*             ls_out-q02 TO ls_out2-q02,
*             ls_out-q02 TO ls_out3-q02,
*             ls_out-q03 TO ls_out1-q03,
*             ls_out-q03 TO ls_out2-q03,
*             ls_out-q03 TO ls_out3-q03,
*             ls_out-q04 TO ls_out1-q04,
*             ls_out-q04 TO ls_out2-q04,
*             ls_out-q04 TO ls_out3-q04,
*             ls_out-s01 TO ls_out1-s01,
*             ls_out-s01 TO ls_out2-s01,
*             ls_out-s01 TO ls_out3-s01,
*             ls_out-s02 TO ls_out1-s02,
*             ls_out-s02 TO ls_out2-s02,
*             ls_out-s02 TO ls_out3-s02,
*             ls_out-total TO ls_out1-total,
*             ls_out-total TO ls_out2-total,
*             ls_out-total TO ls_out3-total,
*             ls_out-nafaz01 TO ls_out1-nafaz01,
*             ls_out-nafaz01 TO ls_out2-nafaz01,
*             ls_out-nafaz01 TO ls_out3-nafaz01,
*             ls_out-nafaz02 TO ls_out1-nafaz02,
*             ls_out-nafaz02 TO ls_out2-nafaz02,
*             ls_out-nafaz02 TO ls_out3-nafaz02,
*             ls_out-nafaz03 TO ls_out1-nafaz03,
*             ls_out-nafaz03 TO ls_out2-nafaz03,
*             ls_out-nafaz03 TO ls_out3-nafaz03,
*             ls_out-nafaz04 TO ls_out1-nafaz04,
*             ls_out-nafaz04 TO ls_out2-nafaz04,
*             ls_out-nafaz04 TO ls_out3-nafaz04,
*             ls_out-nafaz05 TO ls_out1-nafaz05,
*             ls_out-nafaz05 TO ls_out2-nafaz05,
*             ls_out-nafaz05 TO ls_out3-nafaz05,
*             ls_out-nafaz06 TO ls_out1-nafaz06,
*             ls_out-nafaz06 TO ls_out2-nafaz06,
*             ls_out-nafaz06 TO ls_out3-nafaz06,
*             ls_out-nafaz07 TO ls_out1-nafaz07,
*             ls_out-nafaz07 TO ls_out2-nafaz07,
*             ls_out-nafaz07 TO ls_out3-nafaz07,
*             ls_out-nafaz08 TO ls_out1-nafaz08,
*             ls_out-nafaz08 TO ls_out2-nafaz08,
*             ls_out-nafaz08 TO ls_out3-nafaz08,
*             ls_out-nafaz09 TO ls_out1-nafaz09,
*             ls_out-nafaz09 TO ls_out2-nafaz09,
*             ls_out-nafaz09 TO ls_out3-nafaz09,
*             ls_out-nafaz10 TO ls_out1-nafaz10,
*             ls_out-nafaz10 TO ls_out2-nafaz10,
*             ls_out-nafaz10 TO ls_out3-nafaz10,
*             ls_out-nafaz11 TO ls_out1-nafaz11,
*             ls_out-nafaz11 TO ls_out2-nafaz11,
*             ls_out-nafaz11 TO ls_out3-nafaz11,
*             ls_out-nafaz12 TO ls_out1-nafaz12,
*             ls_out-nafaz12 TO ls_out2-nafaz12,
*             ls_out-nafaz12 TO ls_out3-nafaz12.
*
*      WHEN radio4.
*        WRITE: / ls_out-kostl,
*                 ls_out-ltext1,
*                 ls_out-descript,
*                 ls_out-ktnafg,
*                 ls_out-ltext2,
*                 ls_out-anln1,
*                 ls_out-anln2,
*                 ls_out-aktiv,
*                 ls_out-txt50,
*                 ls_out-aufnr,
*                 ls_out-ktext,
*                 ls_out-gjahr,
*                 ls_out-waers,
*                 ls_out-nafaz01 CURRENCY ls_out-waers,
*                 ls_out-nafaz02 CURRENCY ls_out-waers,
*                 ls_out-nafaz03 CURRENCY ls_out-waers,
*                 ls_out-nafaz04 CURRENCY ls_out-waers,
*                 ls_out-nafaz05 CURRENCY ls_out-waers,
*                 ls_out-nafaz06 CURRENCY ls_out-waers.
*    ENDCASE.
*
*    AT END OF ktnafg.
*      WRITE: / '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (40) ' ' NO-GAP, '|' NO-GAP,
*              (469) sy-uline NO-GAP, '|' NO-GAP.
*
*      WRITE: / '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (40) ' ' NO-GAP, '|' NO-GAP,
*              (55) lv_txt3t NO-GAP, '|' NO-GAP,
*              (12) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*              (10) ' ' NO-GAP, ' ' NO-GAP,
*              (50) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*               (5) ' ' NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz01 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz02 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz03 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-q01     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz04 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz05 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz06 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-q02     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-s01     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz07 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz08 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz09 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-q03     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz10 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz11 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-nafaz12 CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-q04     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-s02     CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out3-total   CURRENCY ls_out3-waers NO-GAP, '|' NO-GAP.
*
*      WRITE: / '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (40) ' ' NO-GAP, '|' NO-GAP,
*              (469) sy-uline NO-GAP, '|' NO-GAP.
*      sw4 = '1'.
*    ENDAT.
*
*    AT END OF descript.
*      IF sw4 IS INITIAL.
*        WRITE: / '|' NO-GAP,
*                (55) ' ' NO-GAP, '|' NO-GAP,
*                (511) sy-uline NO-GAP, '|' NO-GAP.
*      ELSE.
*        WRITE: 57(511) sy-uline NO-GAP, '|' NO-GAP.
*      ENDIF.
*
*      WRITE: / '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (40) lv_txt2t NO-GAP, '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (12) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*              (10) ' ' NO-GAP, ' ' NO-GAP,
*              (50) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*               (5) ' ' NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz01 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz02 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz03 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-q01     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz04 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz05 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz06 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-q02     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-s01     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz07 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz08 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz09 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-q03     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz10 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz11 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-nafaz12 CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-q04     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-s02     CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out2-total   CURRENCY ls_out2-waers NO-GAP, '|' NO-GAP.
*
*      WRITE: / '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (510) sy-uline NO-GAP, '|' NO-GAP.
*      sw5 = '1'.
*    ENDAT.
*
*    AT END OF kostl.
*      IF sw5 IS INITIAL.
*        WRITE: / '|' NO-GAP,
*                (567) sy-uline NO-GAP, '|' NO-GAP.
*      ELSE.
*        WRITE: 1(567) sy-uline NO-GAP, '|' NO-GAP.
*      ENDIF.
*
*      WRITE: / '|' NO-GAP,
*              (55) lv_txt1t NO-GAP, '|' NO-GAP,
*              (40) ' ' NO-GAP, '|' NO-GAP,
*              (55) ' ' NO-GAP, '|' NO-GAP,
*              (12) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*              (10) ' ' NO-GAP, ' ' NO-GAP,
*              (50) ' ' NO-GAP, ' ' NO-GAP,
*               (4) ' ' NO-GAP, ' ' NO-GAP,
*               (5) ' ' NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz01 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz02 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz03 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-q01     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz04 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz05 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz06 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-q02     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-s01     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz07 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz08 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz09 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-q03     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz10 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz11 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-nafaz12 CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-q04     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-s02     CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP,
*              (16) ls_out1-total   CURRENCY ls_out1-waers NO-GAP, '|' NO-GAP.
*
*      WRITE: / '|' NO-GAP,
*              (566) sy-uline NO-GAP, '|' NO-GAP.
*    ENDAT.
*  ENDLOOP.
ENDFORM.                    " F_WRITE_ABAPLIST


*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout2     USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
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
      is_print                 = d_print
    TABLES
      t_outtab                 = gt_out   "ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
    'KOSTL' 'ANLP' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'LTEXT1' 'CSKT' 'LTEXT' '' '' 'Cost Ctr Desc.' '' '' '' '' '' '' '' '' '' 'X',
    'DESCRIPT' 'SETHEADERT' 'DESCRIPT' '' '' 'G/L Group' '' '' '' '' '' '' '' '' '' '',
    'KTNAFG' 'T095B' 'KTNAFG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LTEXT2' 'SKAT' 'TXT50' '' '' 'G/L Acct. Desc.' '' '' '' '' '' '' '' '' '' '',
    'ANLN1' 'ANLP' 'ANLN1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ANLN2' 'ANLP' 'ANLN2' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AKTIV' 'ANLA' 'AKTIV' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TXT50' 'ANLA' 'TXT50' '' '' '' '' '' '' '' '' '' '' '' '' ''.

  IF radio4 IS NOT INITIAL.
    PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
      'AUFNR' 'AUFK' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'KTEXT' 'AUFK' 'KTEXT' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
    'GJAHR' 'ANLP' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'T093B' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' ''.

  CASE 'X'.
    WHEN radio3.
      PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
        'NAFAZ01' 'ANLP' 'NAFAZ' '' '' 'Januari' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ02' 'ANLP' 'NAFAZ' '' '' 'Februari' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ03' 'ANLP' 'NAFAZ' '' '' 'Maret' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'Q01' 'ANLP' 'NAFAZ' '' '' 'Quarter 1' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ04' 'ANLP' 'NAFAZ' '' '' 'April' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ05' 'ANLP' 'NAFAZ' '' '' 'Mei' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ06' 'ANLP' 'NAFAZ' '' '' 'Juni' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'Q02' 'ANLP' 'NAFAZ' '' '' 'Quarter 2' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'S01' 'ANLP' 'NAFAZ' '' '' 'Semester 1' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ07' 'ANLP' 'NAFAZ' '' '' 'Juli' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ08' 'ANLP' 'NAFAZ' '' '' 'Agustus' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ09' 'ANLP' 'NAFAZ' '' '' 'September' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'Q03' 'ANLP' 'NAFAZ' '' '' 'Quarter 3' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ10' 'ANLP' 'NAFAZ' '' '' 'Oktober' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ11' 'ANLP' 'NAFAZ' '' '' 'November' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ12' 'ANLP' 'NAFAZ' '' '' 'Desember' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'Q04' 'ANLP' 'NAFAZ' '' '' 'Quarter 4' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'S01' 'ANLP' 'NAFAZ' '' '' 'Semester 2' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'TOTAL' 'ANLP' 'NAFAZ' '' '' 'Total' 'X' '' '' '' '' 'WAERS' '' '' '' ''.
    WHEN radio4.
      PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
        'NAFAZ01' 'ANLP' 'NAFAZ' '' '' 'Actual LY MTD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ02' 'ANLP' 'NAFAZ' '' '' 'Actual CY MTD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ03' 'ANLP' 'NAFAZ' '' '' 'Actual LY YTD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ04' 'ANLP' 'NAFAZ' '' '' 'Actual CY YTD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ05' 'ANLP' 'NAFAZ' '' '' 'Budget MTD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
        'NAFAZ06' 'ANLP' 'NAFAZ' '' '' 'Budget YTD' 'X' '' '' '' '' 'WAERS' '' '' '' ''.
  ENDCASE.

  PERFORM f_fieldcatg USING 'GT_OUT': "ft_report:
    'SERNR' 'ANLA' 'SERNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'INVZU' 'ANLA' 'INVZU' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NDJAR' 'ANLB' 'NDJAR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KANSW' 'ANLC' 'KANSW' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KNAFA' 'ANLC' 'KNAFA' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
    'NAFAG' 'ANLC' 'NAFAG' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
    'NETBOOKVAL' 'ZFISTDEPR' 'NETBOOKVAL' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
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
                          value(fu_key).

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
  ld_fieldcat-key               = fu_key.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout2 USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-totals_text        = 'Grand Total'.
*  fu_layout-subtotals_text     = 'Sub Total'.

*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KOSTL'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LTEXT1'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'DESCRIPT'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KTNAFG'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LTEXT2'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARIES_FIELD1
*&---------------------------------------------------------------------*
FORM f_summaries_field1  USING    fu_nafaz
                                  fu_aafaz
                         CHANGING fc_nafaz01.
*  IF fu_aafaz IS NOT INITIAL.
*    ADD fu_aafaz TO fc_nafaz01.
*  ELSE.
*    ADD fu_nafaz TO fc_nafaz01.
*  ENDIF.
  fc_nafaz01 = fc_nafaz01 + fu_aafaz + fu_nafaz.
ENDFORM.                    " F_SUMMARIES_FIELD1

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .
  REFRESH: gt_data,gt_out,gt_tree,gt_anlp,gt_cskt,gt_aufk,
           gt_anla,gt_anlb,gt_anlc,gt_t095b.
ENDFORM.                    " F_FREE_MEMORY
