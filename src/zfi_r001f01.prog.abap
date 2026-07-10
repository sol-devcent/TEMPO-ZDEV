*&---------------------------------------------------------------------*
*&  Include           ZFI_R001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_buzid   LIKE LINE OF gr_buzid.

  SELECT SINGLE waers
    FROM t001
    INTO gv_waers
    WHERE bukrs = pa_bukrs.

  PERFORM f_get_doctype TABLES gt_blart1
                        USING : 'RE', 'RC'.
  PERFORM f_get_doctype TABLES gt_blart2
                        USING : 'SA', 'KR', 'KG'.

  gv_hkont    = '0142200220'.

  ls_buzid-low    = 'W'.
  ls_buzid-sign   = 'I'.
  ls_buzid-option = 'EQ'.
  APPEND ls_buzid TO gr_buzid.
  ls_buzid-low    = 'H'.
  ls_buzid-sign   = 'I'.
  ls_buzid-option = 'EQ'.
  APPEND ls_buzid TO gr_buzid.
  ls_buzid-low    = 'F'.
  ls_buzid-sign   = 'I'.
  ls_buzid-option = 'EQ'.
  APPEND ls_buzid TO gr_buzid.
  ls_buzid-low    = 'S'.
  ls_buzid-sign   = 'I'.
  ls_buzid-option = 'EQ'.
  APPEND ls_buzid TO gr_buzid.

  gv_ppn      = '0142200220'.
  gv_pph23    = '0315100040'.
  gv_pph42    = '0315100041'.

  PERFORM f_validate_hkont USING : 'KMM' '0752100000',
                                   'KMM' '0752200000',
                                   'KMM' '0131100100',
                                   'PLI' '0752100000',
                                   'PLI' '0752200000',
                                   'PLI' '0131100100',
                                   'SFF' '0752100000',
                                   'SFF' '0752200000',
                                   'SFF' '0752300000',
                                   'SFF' '0131100100',
                                   'SFF' '0133100100'.

  SELECT *
    FROM skat
    INTO CORRESPONDING FIELDS OF TABLE gt_skat
    WHERE spras = sy-langu
      AND ktopl = 'TSPC'.
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
  DATA : lt_budat    TYPE STANDARD TABLE OF sel_budat,
         lt_blart    TYPE STANDARD TABLE OF rsoblart,
         lt_bseg     TYPE STANDARD TABLE OF bseg,
         ls_bseg     LIKE LINE OF lt_bseg,
         ls_bkpf     LIKE LINE OF gt_bkpf,
         lt_xbkpf    TYPE STANDARD TABLE OF bkpf,
         ls_xbkpf    LIKE LINE OF lt_xbkpf,
         ls_mseg     LIKE LINE OF gt_mseg,
         lt_x012     TYPE STANDARD TABLE OF zgdtxdt0012,
         ls_x012     LIKE LINE OF lt_x012,
         ls_012      LIKE LINE OF gt_012.

  PERFORM f_get_docdate TABLES lt_budat.
  PERFORM f_get_doctype TABLES lt_blart
                        USING : 'RE', 'RC', 'SA', 'KR', 'KG'.

  SELECT *
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    WHERE bukrs = pa_bukrs
      AND budat IN lt_budat
      AND blart IN lt_blart
      AND belnr IN so_belnr.

  IF gt_bkpf[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs = gt_bkpf-bukrs
        AND belnr = gt_bkpf-belnr
        AND gjahr = gt_bkpf-gjahr
        AND hkont IN ('0142200220','0142200100').
  ENDIF.

  lt_bseg[] = gt_bseg[].
  SORT lt_bseg BY belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING belnr gjahr.
  IF lt_bseg[] IS NOT INITIAL.
    SELECT *
      FROM zgdtxdt0012
      INTO CORRESPONDING FIELDS OF TABLE lt_x012
      FOR ALL ENTRIES IN lt_bseg
      WHERE bukrs = lt_bseg-bukrs
        AND brnch = lt_bseg-bukrs
        AND belnr = lt_bseg-belnr
        AND gjahr = lt_bseg-gjahr.

    LOOP AT lt_x012 INTO ls_x012.
      MOVE-CORRESPONDING ls_x012 TO ls_012.
      CLEAR : ls_012-buzei, ls_012-hkont, ls_012-files, ls_012-zupos, ls_012-zdpos,
              ls_012-zzpos.
      COLLECT ls_012 INTO gt_012.
      CLEAR ls_012.
    ENDLOOP.
  ENDIF.

  PERFORM f_get_po_migo.

  PERFORM f_get_pph23_pph42.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_012         LIKE LINE OF gt_012,
         ls_out         LIKE LINE OF gt_out,
         ls_xbseg       LIKE LINE OF gt_bseg,
         ls_zbseg       LIKE LINE OF gt_bseg,
         lt_zbseg       TYPE STANDARD TABLE OF bseg,
         ls_bkpf        LIKE LINE OF gt_bkpf,
         ls_mseg        LIKE LINE OF gt_mseg,
         ls_skat        LIKE LINE OF gt_skat,
         ls_data        LIKE LINE OF gt_data.

  DATA : lt_xekbe       TYPE STANDARD TABLE OF ekbe,
         ls_xekbe       LIKE LINE OF lt_xekbe,
         ls_ekbe        LIKE LINE OF gt_ekbe.

  DATA : lr_koart       TYPE RANGE OF koart,
         ls_koart       LIKE LINE OF lr_koart,
         lr_hkont       TYPE RANGE OF hkont,
         ls_hkont       LIKE LINE OF lr_hkont.

  DATA : lv_flag,
         lv_subrc       TYPE sy-subrc.

  ls_koart-low    = 'S'.
  ls_koart-sign   = 'I'.
  ls_koart-option = 'EQ'.
  APPEND ls_koart TO lr_koart.
  ls_koart-low    = 'A'.
  ls_koart-sign   = 'I'.
  ls_koart-option = 'EQ'.
  APPEND ls_koart TO lr_koart.

  ls_hkont-low    = '0142200100'.
  ls_hkont-sign   = 'E'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.
  ls_hkont-low    = '0142200220'.
  ls_hkont-sign   = 'E'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.
  ls_hkont-low    = '0315100040'.
  ls_hkont-sign   = 'E'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.
  ls_hkont-low    = '0315100041'.
  ls_hkont-sign   = 'E'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.
  ls_hkont-low    = '0315100042'.
  ls_hkont-sign   = 'E'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.

  LOOP AT gt_zbseg INTO ls_zbseg WHERE koart IN lr_koart.
*                                   AND hkont IN lr_hkont.
    APPEND ls_zbseg TO lt_zbseg.
  ENDLOOP.

  SORT lt_zbseg BY bukrs gjahr belnr buzei.
  DELETE ADJACENT DUPLICATES FROM lt_zbseg COMPARING bukrs gjahr belnr buzei.

  SORT gt_ekbe BY ebeln ebelp belnr.
  LOOP AT gt_ekbe INTO ls_ekbe.
    ls_xekbe-ebeln    = ls_ekbe-ebeln.
    ls_xekbe-ebelp    = ls_ekbe-ebelp.
    ls_xekbe-belnr    = ls_ekbe-belnr.
    ls_xekbe-gjahr    = ls_ekbe-gjahr.
    ls_xekbe-bpmng    = ls_ekbe-bpmng.
    COLLECT ls_xekbe INTO lt_xekbe.
    CLEAR ls_xekbe.
  ENDLOOP.

  LOOP AT gt_012 INTO ls_012.
    MOVE-CORRESPONDING ls_012 TO ls_data.
    ls_data-monat      = ls_012-fakdat+4(2).
    ls_data-gjahr      = ls_012-fakdat(4).

    ls_data-belnr_miro = ls_012-belnr.
    ls_data-budat_miro = ls_012-budat.

    ls_data-setor      = ls_012-budat+4(2).
    ls_data-waers      = gv_waers.

    CLEAR ls_bkpf.
    READ TABLE gt_bkpf INTO ls_bkpf
                       WITH KEY belnr = ls_012-belnr.
    IF sy-subrc = 0.
      IF ls_bkpf-blart IN gt_blart1.
        PERFORM f_re_rc_document TABLES lt_xekbe
                                 USING ls_bkpf ls_data.
      ELSEIF ls_bkpf-blart IN gt_blart2.
        ls_data-belnr_migo = ls_012-belnr.
        ls_data-budat_migo = ls_012-budat.
        CLEAR ls_zbseg.
        lv_subrc = 4.
        LOOP AT lt_zbseg INTO ls_zbseg WHERE belnr = ls_data-belnr_miro
                                         AND koart IN lr_koart
                                         AND hkont IN lr_hkont.
          ls_data-sakto   = ls_zbseg-hkont.
          ls_data-itamt   = ls_zbseg-dmbtr.
          CLEAR : lv_subrc.
          APPEND ls_data TO gt_data.
        ENDLOOP.
        IF lv_subrc IS NOT INITIAL.
          LOOP AT lt_zbseg INTO ls_zbseg WHERE belnr = ls_data-belnr_miro
                                           AND koart IN lr_koart.
            IF ls_zbseg-hkont IN lr_hkont.
              CONTINUE.
            ELSE.
              CLEAR : ls_data-sakto.
              ls_data-itamt   = ls_012-itamt.
              APPEND ls_data TO gt_data.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR ls_data.
  ENDLOOP.

  LOOP AT gt_012 INTO ls_012.
    lv_flag = 'X'.
    SORT gt_data BY belnr_miro belnr_migo sakto.
    LOOP AT gt_data INTO ls_data WHERE belnr_miro = ls_012-belnr.
      MOVE-CORRESPONDING ls_data TO ls_out.
      IF ls_data-sakto = '0841150030'.
        ls_out-sakto = '0131400100'.
      ELSE.
        ls_out-sakto = ls_data-sakto.
      ENDIF.
      CLEAR ls_skat.
      READ TABLE gt_skat INTO ls_skat
                         WITH KEY saknr = ls_out-sakto.
      IF sy-subrc = 0.
        ls_out-txt50   = ls_skat-txt50.
      ENDIF.

      IF lv_flag IS INITIAL.
        CLEAR : ls_out-fakppn.
      ELSE.
        LOOP AT gt_zbseg INTO ls_zbseg WHERE belnr = ls_data-belnr_miro.
          CASE ls_zbseg-hkont.
            WHEN '0315100040'.
              ADD ls_zbseg-dmbtr TO ls_out-pph23.
            WHEN '0315100041'.
              ADD ls_zbseg-dmbtr TO ls_out-pph42.
            WHEN '0315100042'.
              ADD ls_zbseg-dmbtr TO ls_out-pph42.
          ENDCASE.
        ENDLOOP.
      ENDIF.

      COLLECT ls_out INTO gt_out.
      CLEAR : ls_out, lv_flag.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DELETE gt_out WHERE sakto = '0312600300'
                  AND itamt IS INITIAL
                  AND fakppn IS INITIAL.
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

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  APPEND '&POS' TO fcode.

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

  PERFORM f_alv_sort USING : 1 'NAME' 'X' '' '',
                             2 'EBELN' 'X' '' '',
                             3 'BELNR_MIRO' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
*    '' 'X' '' '' ''.
*    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
*    '' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'NAME' '' '' '' '' '' '' 'NAME' 'ZGDTXDT0012' 'Name' '' '' '' ''
    '' '' '' 'X' '' '' '',
    'NPWP' '' '' '' '' '' '' 'NPWP' 'ZGDTXDT0012' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'FAKTURNO' '' '' '' '' '' '' 'FAKTURNO' 'ZGDTXDT0012' '' '' '' ''
    '' '' '' '' 'X' '' '' '',
    'FAKDAT ' '' '' '' '' '' '' 'FAKDAT' 'ZGDTXDT0012' '' '' '' '' '' ''
    '' '' 'X' '' '' '',
    'MONAT' '' '' '' '' '' '' 'MONAT' 'BKPF' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'GJAHR' '' '' '' '' '' '' 'GJAHR' 'BKPF' '' '' '' '' '' '' ''
    '' 'X' '' '' '',
    'EBELN' '' '' '' '' '' '' 'EBELN' 'EKKO' '' '' ''
    '' '' '' '' '' 'X' '' '' '',
    'BELNR_MIRO' '' '' '' '' '' '' 'BELNR' 'BKPF' 'Document MIRO' ''
    '' '' '' '' '' '' 'X' '' '' '',
    'BUDAT_MIRO' '' '' '' '' '' '' 'BUDAT' 'BKPF' 'Date MIRO' '' '' ''
    '' '' '' '' '' '' '' '',
    'SETOR' '' '' '' '' '' '' 'MONAT' 'BKPF' 'Masa Setor/Lapor Pajak'
    '' '' '' '' '' '' '' '' '' '' '',
    'BELNR_MIGO' '' '' '' '' '' '' 'BELNR' 'BKPF' 'Document MIGO' '' ''
    '' '' '' '' '' '' '' '' '',
    'BUDAT_MIGO' '' '' '' '' '' '' 'BUDAT' 'BKPF' 'Date MIGO' '' '' '' ''
    '' '' '' '' '' '' '',
    'SAKTO' '' '' '' '' '' '' 'SAKTO' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'TXT50' '' '' '' '' '' '' 'TXT50' 'SKAT' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'GSBER' '' '' '' '' '' '' 'GSBER' 'BSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'T001' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'ITAMT' '' '' 'WAERS' '' '' '' 'ITAMT' 'ZGDTXDT0012' 'DPP' '' '' ''
    '' '' '' '' '' '' '' '',
    'FAKPPN' '' '' 'WAERS' '' '' '' 'FAKPPN' 'ZGDTXDT0012' 'PPN Masukan'
    '' '' '' '' '' '' '' '' '' '' '',
    'PPH23' '' '' 'WAERS' '' '' '' 'DMBTR' 'BSEG' 'PPH 23' '' '' '' '' ''
    '' '' '' '' '' '',
    'PPH42' '' '' 'WAERS' '' '' '' 'DMBTR' 'BSEG' 'PPH 4(2)' '' '' '' ''
    '' '' '' '' '' '' '',
    'ITEM' '' '' 'WAERS' '' '' '' 'ITEM' 'ZGDTXDT0012' '' '' '' '' '' ''
    '' '' '' '' '' ''.
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
*  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
*  DATA : lv_style           TYPE lvc_s_styl-style,
*         lt_stylerow        TYPE lvc_t_styl,
*         ls_stylerow        TYPE lvc_s_styl.
*
*  DATA : ls_out             LIKE LINE OF gt_out.
*
*  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
*    IMPORTING
*      et_fieldcatalog = ls_fieldcatalog[].
*
*  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
*  IF sy-subrc = 0.
*    IF ls_fieldcatalog-edit IS NOT INITIAL.
*      LOOP AT gt_out INTO ls_out.
*        READ TABLE ls_out-style INTO ls_stylerow
*                                WITH KEY fieldname = 'MARK'.
*        IF sy-subrc = 0 AND
*            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*          CONTINUE.
*        ENDIF.
*        ls_out-mark = fu_check.
*        MODIFY gt_out FROM ls_out.
*        CLEAR ls_out.
*      ENDLOOP.
*    ENDIF.
*    PERFORM f_alv_refresh USING 'X'.
*  ENDIF.
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
*&      Form  F_GET_DOCDATE
*&---------------------------------------------------------------------*
FORM f_get_docdate  TABLES   ft_budat STRUCTURE sel_budat.
  DATA : ls_budat   TYPE sel_budat.

  CONCATENATE pa_spmon '01' INTO ls_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_budat-low
    IMPORTING
      last_day_of_month = ls_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  ls_budat-sign       = 'I'.
  ls_budat-option     = 'BT'.
  APPEND ls_budat TO ft_budat.
  CLEAR ls_budat.
ENDFORM.                    " F_GET_DOCDATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCTYPE
*&---------------------------------------------------------------------*
FORM f_get_doctype  TABLES   ft_blart STRUCTURE rsoblart
                    USING    fu_blart.
  DATA : ls_blart   TYPE rsoblart.

  ls_blart-low      = fu_blart.
  ls_blart-sign     = 'I'.
  ls_blart-option   = 'EQ'.
  APPEND ls_blart TO ft_blart.
  CLEAR ls_blart.
ENDFORM.                    " F_GET_DOCTYPE

*&---------------------------------------------------------------------*
*&      Form  F_GET_PO_MIGO
*&---------------------------------------------------------------------*
FORM f_get_po_migo .
  DATA : lt_xbkpf    TYPE STANDARD TABLE OF bkpf,
         ls_xbkpf    LIKE LINE OF lt_xbkpf,
         ls_bseg     LIKE LINE OF gt_xbseg,
         lt_xekbe    TYPE STANDARD TABLE OF ekbe,
         ls_xekbe    LIKE LINE OF lt_xekbe,
         ls_ekbe     LIKE LINE OF gt_ekbe,
         lt_ybseg    TYPE STANDARD TABLE OF bseg.

  DATA : lr_buzid    TYPE RANGE OF buzid,
         ls_buzid    LIKE LINE OF lr_buzid.

  DATA : ly_buzid    TYPE RANGE OF buzid,
         lx_buzid    LIKE LINE OF ly_buzid.

  DATA : lr_blart    TYPE RANGE OF blart,
         ls_blart    LIKE LINE OF lr_blart.

  DATA : lr_hkontadd  TYPE RANGE OF hkont,
         ls_hkontadd  LIKE LINE OF lr_hkontadd.

  ls_buzid-low    = 'W'.
  ls_buzid-sign   = 'E'.
  ls_buzid-option = 'EQ'.
  APPEND ls_buzid TO lr_buzid.

  lx_buzid-low    = 'W'.
  lx_buzid-sign   = 'I'.
  lx_buzid-option = 'EQ'.
  APPEND lx_buzid TO ly_buzid.
  lx_buzid-low    = 'F'.
  lx_buzid-sign   = 'I'.
  lx_buzid-option = 'EQ'.
  APPEND lx_buzid TO ly_buzid.

  ls_blart-low    = 'WE'.
  ls_blart-sign   = 'I'.
  ls_blart-option = 'EQ'.
  APPEND ls_blart TO lr_blart.
  ls_blart-low    = 'WL'.
  ls_blart-sign   = 'I'.
  ls_blart-option = 'EQ'.
  APPEND ls_blart TO lr_blart.

  ls_hkontadd-low    = '0752100100'.
  ls_hkontadd-sign   = 'I'.
  ls_hkontadd-option = 'EQ'.
  APPEND ls_hkontadd TO lr_hkontadd.
  ls_hkontadd-low    = '0841340050'.
  ls_hkontadd-sign   = 'I'.
  ls_hkontadd-option = 'EQ'.
  APPEND ls_hkontadd TO lr_hkontadd.

  lt_xbkpf[]  = gt_bkpf[].
  DELETE lt_xbkpf WHERE blart IN gt_blart2.
  IF lt_xbkpf[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_xbseg
      FOR ALL ENTRIES IN lt_xbkpf
      WHERE bukrs = lt_xbkpf-bukrs
        AND belnr = lt_xbkpf-belnr
        AND gjahr = lt_xbkpf-gjahr
        AND buzid IN gr_buzid
        AND ebeln <> space.
  ENDIF.

  IF lt_xbkpf[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_addbseg
      FOR ALL ENTRIES IN lt_xbkpf
      WHERE bukrs = lt_xbkpf-bukrs
        AND belnr = lt_xbkpf-belnr
        AND gjahr = lt_xbkpf-gjahr
        AND buzid EQ 'S'
        AND hkont IN lr_hkontadd.
  ENDIF.

  LOOP AT gt_xbseg INTO ls_bseg.
    ls_xekbe-ebeln  = ls_bseg-ebeln.
    ls_xekbe-ebelp  = ls_bseg-ebelp.
    ls_xekbe-gjahr  = ls_bseg-gjahr.
    ls_xekbe-vgabe  = '1'.
    ls_xekbe-bpmng  = ls_bseg-bpmng.
    APPEND ls_xekbe TO lt_xekbe.
    CLEAR ls_xekbe.
  ENDLOOP.

  SORT lt_xekbe BY ebeln ebelp gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_xekbe COMPARING ebeln ebelp gjahr bpmng.
  IF lt_xekbe[] IS NOT INITIAL.
    SELECT *
      FROM ekbe
      INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
      FOR ALL ENTRIES IN lt_xekbe
      WHERE ebeln = lt_xekbe-ebeln
        AND ebelp = lt_xekbe-ebelp
"        AND gjahr = lt_xekbe-gjahr
        AND vgabe = lt_xekbe-vgabe
"        AND bpmng = lt_xekbe-bpmng
        AND dmbtr <> space.
  ENDIF.

  SORT gt_ekbe BY ebeln ebelp belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM gt_ekbe COMPARING ebeln ebelp belnr gjahr.

  CLEAR lt_xbkpf[].
  LOOP AT gt_ekbe INTO ls_ekbe.
    CONCATENATE ls_ekbe-belnr ls_ekbe-gjahr INTO ls_xbkpf-awkey.
    APPEND ls_xbkpf TO lt_xbkpf.
  ENDLOOP.

  SORT lt_xbkpf BY awkey.
  DELETE ADJACENT DUPLICATES FROM lt_xbkpf COMPARING awkey.
  IF lt_xbkpf[] IS NOT INITIAL.
    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE gt_xbkpf
      FOR ALL ENTRIES IN lt_xbkpf
      WHERE bukrs = pa_bukrs
        AND awkey = lt_xbkpf-awkey
        AND blart IN lr_blart.

    IF gt_xbkpf[] IS NOT INITIAL.
      SELECT *
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE gt_ybseg
        FOR ALL ENTRIES IN gt_xbkpf
        WHERE bukrs = gt_xbkpf-bukrs
          AND belnr = gt_xbkpf-belnr
          AND gjahr = gt_xbkpf-gjahr
          AND buzid IN lr_buzid.
    ENDIF.

    IF gt_xbkpf[] IS NOT INITIAL.
      SELECT *
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE gt_abseg
        FOR ALL ENTRIES IN gt_xbkpf
        WHERE bukrs = gt_xbkpf-bukrs
          AND belnr = gt_xbkpf-belnr
          AND gjahr = gt_xbkpf-gjahr
          AND buzid IN ly_buzid.
    ENDIF.
  ENDIF.

  SORT gt_xbseg BY belnr augbl ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM gt_xbseg COMPARING belnr augbl ebeln ebelp.
ENDFORM.                    " F_GET_PO_MIGO

*&---------------------------------------------------------------------*
*&      Form  F_RE_RC_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_re_rc_document  TABLES   ft_ekbe   STRUCTURE ekbe
                       USING    fs_bkpf   TYPE bkpf
                                fs_data   TYPE zfist002.

  TYPES : BEGIN OF ty_temp.
          INCLUDE STRUCTURE zfist002.
  TYPES :   awkey   TYPE bkpf-awkey,
            buzei   TYPE bseg-buzei,
          END OF ty_temp.

  DATA : ls_bseg        LIKE LINE OF gt_bseg,
         ls_ekbe        LIKE LINE OF gt_ekbe,
         ls_xbkpf       LIKE LINE OF gt_xbkpf,
         ls_ybseg       LIKE LINE OF gt_ybseg,
         ls_abseg       LIKE LINE OF gt_abseg,
         ls_zbseg       LIKE LINE OF gt_zbseg.

  DATA : lt_temp        TYPE STANDARD TABLE OF ty_temp,
         ls_temp        LIKE LINE OF lt_temp.

  DATA : lv_awkey       TYPE bkpf-awkey.

  MOVE-CORRESPONDING fs_data TO ls_temp.

  CLEAR ls_bseg.
  LOOP AT gt_xbseg INTO ls_bseg WHERE belnr = fs_bkpf-belnr.
    ls_temp-gsber      = ls_bseg-gsber.

    CLEAR ls_ekbe.
    READ TABLE ft_ekbe INTO ls_ekbe
                       WITH KEY ebeln = ls_bseg-ebeln
                                ebelp = ls_bseg-ebelp
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      LOOP AT ft_ekbe INTO ls_ekbe WHERE ebeln = ls_bseg-ebeln
                                     AND ebelp = ls_bseg-ebelp
                                     AND bpmng <> 0.
        ls_temp-ebeln      = ls_ekbe-ebeln.
        CLEAR : lv_awkey, ls_xbkpf.
        CONCATENATE ls_ekbe-belnr ls_ekbe-gjahr INTO lv_awkey.
        READ TABLE gt_xbkpf INTO ls_xbkpf
                            WITH KEY awkey = lv_awkey.
        IF sy-subrc = 0.
          READ TABLE gt_abseg INTO ls_abseg
                              WITH KEY belnr = ls_xbkpf-belnr
                                       augbl = ls_bseg-augbl
                              TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            ls_temp-belnr_migo = ls_xbkpf-belnr.
            ls_temp-budat_migo = ls_xbkpf-budat.

            CLEAR ls_ybseg.
            LOOP AT gt_ybseg INTO ls_ybseg WHERE belnr = ls_xbkpf-belnr
                                             AND ebeln = ls_ekbe-ebeln
                                             AND ebelp = ls_ekbe-ebelp.
              ls_temp-awkey   = lv_awkey.
              ls_temp-buzei   = ls_ybseg-buzei.
              ls_temp-itamt   = ls_ybseg-dmbtr.
              IF ls_ybseg-shkzg = 'H'.
                ls_temp-itamt = ls_temp-itamt * -1.
              ENDIF.
              ls_temp-sakto   = ls_ybseg-hkont.
              CASE ls_temp-lifnr.
                WHEN 'TSB8090' OR 'TSB0901'.
                  IF ls_ybseg-hkont IN gr_hkont_sff.
                    APPEND ls_temp TO lt_temp.   "gt_data.
                  ENDIF.
                WHEN 'TSB3301' OR 'TSB3302' OR 'TSB3600'.
*                  CLEAR ls_zbseg.
*                  READ TABLE gt_zbseg INTO ls_zbseg
*                                     WITH KEY bukrs = fs_bkpf-bukrs
*                                              belnr = fs_bkpf-belnr
*                                              gjahr = fs_bkpf-gjahr
*                                              hkont = '0315100040'
*                                     TRANSPORTING NO FIELDS.
*                  IF sy-subrc = 0.
                  IF ls_ybseg-hkont IN gr_hkont_kmm.
                    APPEND ls_temp TO lt_temp.   "gt_data.
                  ENDIF.
*                  ENDIF.
                WHEN OTHERS.
                  APPEND ls_temp TO lt_temp.   "gt_data.
              ENDCASE.
            ENDLOOP.
          ELSE.
            CLEAR ls_temp-itamt.
            APPEND ls_temp TO lt_temp.   "gt_data.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      APPEND ls_temp TO lt_temp.   "gt_data.
    ENDIF.
  ENDLOOP.

  SORT lt_temp BY awkey belnr_migo buzei itamt DESCENDING.
  DELETE lt_temp WHERE sakto = '0312600300'
                    AND itamt IS INITIAL
                    AND fakppn IS INITIAL.
  DELETE lt_temp WHERE sakto = '0720100000'
                  AND itamt IS INITIAL
                  AND fakppn IS NOT INITIAL.
  DELETE lt_temp WHERE sakto = '0131200100'
                AND itamt IS INITIAL
                AND fakppn IS NOT INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING awkey belnr_migo buzei.
  CLEAR ls_temp.
  LOOP AT lt_temp INTO ls_temp.
    MOVE-CORRESPONDING ls_temp TO fs_data.
    APPEND fs_data TO gt_data.
  ENDLOOP.

  CLEAR ls_bseg.
  LOOP AT gt_addbseg INTO ls_bseg WHERE belnr = fs_bkpf-belnr.
    fs_data-gsber   = ls_bseg-gsber.
    fs_data-itamt   = ls_bseg-dmbtr.
    IF ls_bseg-shkzg = 'H'.
      fs_data-itamt = fs_data-itamt * -1.
    ENDIF.
    fs_data-sakto   = ls_bseg-hkont.
    APPEND fs_data TO gt_data.
  ENDLOOP.
ENDFORM.                    " F_RE_RC_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_PPH23_PPH42
*&---------------------------------------------------------------------*
FORM f_get_pph23_pph42 .
  DATA : lt_012     TYPE STANDARD TABLE OF zgdtxdt0012,
         lt_zbseg   TYPE STANDARD TABLE OF bseg.

  lt_012[] = gt_012[].
  SORT lt_012 BY bukrs belnr gjahr.
  IF lt_012[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_zbseg
      FOR ALL ENTRIES IN lt_012
      WHERE bukrs = lt_012-bukrs
        AND belnr = lt_012-belnr
        AND gjahr = lt_012-gjahr
        AND hkont IN gr_hkont.
  ENDIF.
ENDFORM.                    " F_GET_PPH23_PPH42

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : ls_out   LIKE LINE OF gt_out.

  READ TABLE gt_out INTO ls_out INDEX fu_row.

  CASE fu_column.
    WHEN 'BELNR_MIRO'.
      SET PARAMETER ID 'BLN' FIELD ls_out-belnr_miro.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD pa_spmon(4).
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    WHEN 'BELNR_MIGO'.
      SET PARAMETER ID 'BLN' FIELD ls_out-belnr_migo.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD pa_spmon(4).
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_HKONT
*&---------------------------------------------------------------------*
FORM f_validate_hkont  USING    fu_cocd fu_hkont.
  DATA : ls_hkont   LIKE LINE OF gr_hkont.

  CASE fu_cocd.
    WHEN 'KMM'.
      ls_hkont-low    = fu_hkont.
      ls_hkont-sign   = 'I'.
      ls_hkont-option = 'EQ'.
      APPEND ls_hkont TO gr_hkont_kmm.
    WHEN 'SFF'.
      ls_hkont-low    = fu_hkont.
      ls_hkont-sign   = 'I'.
      ls_hkont-option = 'EQ'.
      APPEND ls_hkont TO gr_hkont_sff.
    WHEN 'PLI'.
      ls_hkont-low    = fu_hkont.
      ls_hkont-sign   = 'I'.
      ls_hkont-option = 'EQ'.
      APPEND ls_hkont TO gr_hkont_pli.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_HKONT
