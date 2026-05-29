*&---------------------------------------------------------------------*
*&  Include           ZPP_R002F01
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
  IF radio2 = 'X'.
    PERFORM f_modify_screen USING : 'AUF' '0' '' '' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  AUTHORITY-CHECK OBJECT 'C_ARPL_WRK'
           ID 'WERKS' FIELD pa_werks.
  IF sy-subrc <> 0.
    PERFORM f_error_message USING 'PWE' 'You are not authorized'.
  ENDIF.
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
  CASE 'X'.
    WHEN radio1.
      PERFORM f_get_data1.
    WHEN radio2.
      PERFORM f_get_data2.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_process_data1.
    WHEN radio2.
      PERFORM f_process_data2.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    SORT gt_out BY wbooth shtxt istad.
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
  DATA : fcode  TYPE TABLE OF sy-ucomm,
         dynlog TYPE smp_dyntxt.

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
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c.

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

*  PERFORM f_alv_sort USING : 1 'ISTAD' 'X' '' '',
*                             2 'WBOOTH' 'X' '' '',
*                             3 'SHTXT' 'X' '' ''.
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

  CASE 'X'.
    WHEN radio1.
      PERFORM f_dyn_int_table USING :
        'WBOOTH' '' '' '' '' '' '' 'WBOOTH' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' 'X' '' '' '',
        'EQUNR' '' '' '' '' '' '' 'EQUNR' 'ZPPRESB_ADD' '' '' '' 'X' '' '' ''
        '' 'X' '' '' '',
        'SHTXT' '' '' '' '' '' '' 'SHTXT' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' 'X' '' '' '',
        'ISTAD' '' '' '' '' '' '' 'ISTAD' 'ZPPRESB_ADD' 'Tanggal Timbang' ''
        '' '' '' '' '' '' 'X' '' '' '',
        'POSNR' '' '' '' '' '' '' 'POSNR' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' 'X' '' '' '',
        'MATNR' '' '' '' '' '' '' 'MATNR' 'ZPPRESB_ADD' 'Kode Bahan' '' '' ''
        '' '' '' '' '' '' '' '',
        'MAKT1' '' '' '' '' '' '' 'MAKTX' 'MAKT' 'Nama Bahan' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHAR1' '' '' '' '' '' '' 'CHARG' 'MCH1' 'No.Analisa' '' '' '' '' '' ''
        '' '' '' '' '',
        'MAKT2' '' '' '' '' '' '' 'MAKTX' 'MAKT' 'Nama Produk' '' '' '' '' '' ''
        '' '' '' '' '',
        'AUFNR' '' '' '' '' '' '' 'AUFNR' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHAR2' '' '' '' '' '' '' 'CHARG' 'MCH1' 'Batch Produk' '' '' '' '' '' ''
        '' '' '' '' '',
        'VORNR' '' '' '' '' '' '' 'VORNR' 'RESB' 'No.Operation' '' '' '' '' '' ''
        '' '' '' '' '',
        'LTXA1' '' '' '' '' '' '' 'LTXA1' 'ZPPRESB_ADD' 'Desc.Operation' '' '' ''
        '' '' '' '' '' '' '' '',
        'ISTAU' '' '' '' '' '' '' 'ISTAU' 'ZPPRESB_ADD' 'Jam Mulai' '' '' '' '' ''
        '' '' '' '' '' '',
        'UZEIT' '' '' '' '' '' '' 'UZEIT' 'ZPPRESB_ADD' 'Jam Selesai' '' '' '' ''
        '' '' '' '' '' '' '',
        'ERFMG' '' '' '' '' 'ERFME' '' 'ERFMG' 'RESB' 'Actual Timbang' '' '' ''
        '' '' '' '' '' '' '' '',
        'ERFME' '' '' '' '' '' '' 'ERFME' 'RESB' 'Satuan' '' '' '' '' '' ''
        '' '' '' '' '',
        'OPERATOR' '' '' '' '' '' '' 'OPERATOR' 'ZPPRESB_ADD' 'Operator' ''
        '' '' '' '' '' '' '' '' '' '',
        'PENGAWAS' '' '' '' '' '' '' 'PENGAWAS' 'ZPPRESB_ADD' 'Pengawas' ''
        '' '' '' '' '' '' '' '' '' '',
        'ATWTB' '' '' '' '' '' '' '' '' 'Manufacture' ''
        '' '' '' '' '' '' '' '' '' ''.

    WHEN radio2.
      PERFORM f_dyn_int_table USING :
        'WBOOTH' '' '' '' '' '' '' 'WBOOTH' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' 'X' '' '' '',
        'EQUNR' '' '' '' '' '' '' 'EQUNR' 'ZPPRESB_ADD' '' '' '' 'X' '' '' ''
        '' 'X' '' '' '',
        'SHTXT' '' '' '' '' '' '' 'SHTXT' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
        '' 'X' '' '' '',
        'ISTAD' '' '' '' '' '' '' 'ISTAD' 'ZPPRESB_ADD' 'Tanggal Timbang' ''
        '' '' '' '' '' '' 'X' '' '' '',
*        'POSNR' '' '' '' '' '' '' 'POSNR' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
*        '' 'X' '' '' '',
        'MATNR' '' '' '' '' '' '' 'MATNR' 'ZPPRESB_ADD' 'Kode Bahan' '' '' ''
        '' '' '' '' '' '' '' '',
        'MAKT1' '' '' '' '' '' '' 'MAKTX' 'MAKT' 'Nama Bahan' '' '' '' '' '' ''
        '' '' '' '' '',
        'CHAR1' '' '' '' '' '' '' 'CHARG' 'MCH1' 'No.Analisa' '' '' '' '' '' ''
        '' '' '' '' '',
*        'MAKT2' '' '' '' '' '' '' 'MAKTX' 'MAKT' 'Nama Produk' '' '' '' '' '' ''
*        '' '' '' '' '',
*        'AUFNR' '' '' '' '' '' '' 'AUFNR' 'ZPPRESB_ADD' '' '' '' '' '' '' ''
*        '' '' '' '' '',
*        'CHAR2' '' '' '' '' '' '' 'CHARG' 'MCH1' 'Batch Produk' '' '' '' '' '' ''
*        '' '' '' '' '',
*        'VORNR' '' '' '' '' '' '' 'VORNR' 'RESB' 'No.Operation' '' '' '' '' '' ''
*        '' '' '' '' '',
*        'LTXA1' '' '' '' '' '' '' 'LTXA1' 'ZPPRESB_ADD' 'Desc.Operation' '' '' ''
*        '' '' '' '' '' '' '' '',
        'ISTAU' '' '' '' '' '' '' 'ISTAU' 'ZPPRESB_ADD' 'Jam Mulai' '' '' '' '' ''
        '' '' '' '' '' '',
        'UZEIT' '' '' '' '' '' '' 'UZEIT' 'ZPPRESB_ADD' 'Jam Selesai' '' '' '' ''
        '' '' '' '' '' '' '',
        'ERFMG' '' '' '' '' 'ERFME' '' 'ERFMG' 'RESB' 'Actual Timbang' '' '' ''
        '' '' '' '' '' '' '' '',
        'ERFME' '' '' '' '' '' '' 'ERFME' 'RESB' 'Satuan' '' '' '' '' '' ''
        '' '' '' '' '',
        'OPERATOR' '' '' '' '' '' '' 'OPERATOR' 'ZPPRESB_ADD' 'Operator' ''
        '' '' '' '' '' '' '' '' '' '',
        'PENGAWAS' '' '' '' '' '' '' 'PENGAWAS' 'ZPPRESB_ADD' 'Pengawas' ''
        '' '' '' '' '' '' '' '' '' '',
        'KET' '' '' '' '' '' '' '' '' 'Keterangan' '20'
        '' '' '' '' '' '' '' '' '' '',
        'ATWTB' '' '' '' '' '' '' '' '' 'Manufacture' ''
        '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
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
         ls_stylerow TYPE lvc_s_styl.

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
*&      Form  F_GET_DOCUMENT_DATE
*&---------------------------------------------------------------------*
FORM f_get_document_date  USING    fu_rsnum
                                   fu_rspos
                          CHANGING fc_date
                                   fc_istau
                                   fc_uzeit
                                   fc_wbooth
                                   fc_operator
                                   fc_pengawas.
  DATA: ls_mseg  TYPE mseg,
        ls_mkpf  TYPE mkpf,
        lt_mseg  TYPE TABLE OF mseg WITH HEADER LINE,
        lt_xmseg TYPE TABLE OF mseg WITH HEADER LINE..

  SELECT mblnr mjahr zeile sjahr smbln smblp bwart rsnum rspos
    INTO CORRESPONDING FIELDS OF TABLE lt_mseg
    FROM mseg WHERE rsnum = fu_rsnum
                AND rspos = fu_rspos.

  lt_xmseg[] = lt_mseg[].
  DELETE lt_mseg WHERE smbln NE space.
  DELETE lt_xmseg WHERE smbln = space.
  LOOP AT lt_xmseg.
    DELETE lt_mseg WHERE mblnr = lt_xmseg-smbln
                     AND mjahr = lt_xmseg-sjahr
                     AND zeile = lt_xmseg-smblp.
  ENDLOOP.
  READ TABLE lt_mseg INTO ls_mseg INDEX 1.

  SELECT SINGLE mblnr mjahr bldat budat cputm bktxt
    INTO CORRESPONDING FIELDS OF ls_mkpf
    FROM mkpf WHERE mblnr = ls_mseg-mblnr
                AND mjahr = ls_mseg-mjahr.

  fc_date = ls_mkpf-budat.
  fc_istau = fc_uzeit = ls_mkpf-cputm.
  SPLIT ls_mkpf-bktxt AT ';' INTO fc_wbooth
                                  fc_operator
                                  fc_pengawas.
ENDFORM.                    " F_GET_DOCUMENT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA1
*&---------------------------------------------------------------------*
FORM f_get_data1 .
  DATA : lt_add         TYPE STANDARD TABLE OF zppresb_add,
         lt_afpo        TYPE STANDARD TABLE OF afpo,
         lt_ztspppdt007 TYPE STANDARD TABLE OF ztspppdt007,
         lt_ztspppdt011 TYPE STANDARD TABLE OF ztspppdt011.

  SELECT * INTO TABLE gt_ztspppdt007
    FROM ztspppdt007 WHERE werks   EQ pa_werks
                       AND wbooth  IN so_wboot
                       AND equnr   IN so_equnr
                       AND matnr   IN so_matnr
                       AND astad   IN so_istad
                       AND aufnr   IN so_aufnr
                       AND phseq   EQ 'W1'.

  SELECT *
    FROM zppresb_add
    INTO CORRESPONDING FIELDS OF TABLE gt_add
    WHERE werks   = pa_werks
      AND wbooth  IN so_wboot
      AND equnr   IN so_equnr
      AND matnr   IN so_matnr
      AND istad   IN so_istad
      AND aufnr   IN so_aufnr.

  SELECT *
    FROM ztspppdt011
    INTO CORRESPONDING FIELDS OF TABLE gt_ztspppdt011
    WHERE werks   = pa_werks
*      AND wbooth  IN so_wboot
*      AND equnr   IN so_equnr
      AND matnr   IN so_matnr
      AND erdat   IN so_istad
      AND aufnr   IN so_aufnr.

  IF gt_add[] IS INITIAL AND gt_ztspppdt007[] IS INITIAL AND
     gt_ztspppdt011[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.
  ENDIF.

  IF gt_add[] IS NOT INITIAL.
    lt_add[] = gt_add[].
    SORT lt_add BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_add COMPARING matnr.
    IF lt_add[] IS NOT INITIAL.
      SELECT *
        FROM makt
        INTO CORRESPONDING FIELDS OF TABLE gt_makt
        FOR ALL ENTRIES IN lt_add
        WHERE matnr = lt_add-matnr
          AND spras = sy-langu.
    ENDIF.

    lt_add[] = gt_add[].
    SORT lt_add BY aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_add COMPARING aufnr.
    IF lt_add[] IS NOT INITIAL.
      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE gt_resb
        FOR ALL ENTRIES IN lt_add
        WHERE aufnr = lt_add-aufnr
          AND splkz = '2'
          AND wempf IN ('T','W').

      SELECT *
        FROM afpo
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo
        FOR ALL ENTRIES IN lt_add
        WHERE aufnr = lt_add-aufnr.
    ENDIF.

    lt_afpo[] = gt_afpo[].
    SORT lt_afpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING matnr.
    IF lt_afpo[] IS NOT INITIAL.
      SELECT *
        FROM makt
        APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
        FOR ALL ENTRIES IN lt_afpo
        WHERE matnr = lt_afpo-matnr
          AND spras = sy-langu.
    ENDIF.
  ENDIF.

  IF gt_ztspppdt011[] IS NOT INITIAL.
    lt_ztspppdt011[] = gt_ztspppdt011[].
    SORT lt_ztspppdt011 BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_ztspppdt011 COMPARING matnr.
    IF lt_ztspppdt011[] IS NOT INITIAL.
      SELECT *
        FROM makt
        INTO CORRESPONDING FIELDS OF TABLE gt_makt3
        FOR ALL ENTRIES IN lt_ztspppdt011
        WHERE matnr = lt_ztspppdt011-matnr
          AND spras = sy-langu.
    ENDIF.

    lt_ztspppdt011[] = gt_ztspppdt011[].
    SORT lt_ztspppdt011 BY aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_ztspppdt011 COMPARING aufnr.
    IF lt_ztspppdt011[] IS NOT INITIAL.
      SELECT DISTINCT rsnum aufpl vornr
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE gt_resb3
        FOR ALL ENTRIES IN lt_ztspppdt011
        WHERE aufnr = lt_ztspppdt011-aufnr.
      IF sy-subrc = 0.
        SELECT aufpl aplzl vornr ltxa1
          FROM afvc
          INTO CORRESPONDING FIELDS OF TABLE gt_afvc
          FOR ALL ENTRIES IN gt_resb3
          WHERE aufpl = gt_resb3-aufpl
            AND vornr = gt_resb3-vornr.
      ENDIF.

      SELECT *
        FROM afpo
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo3
        FOR ALL ENTRIES IN lt_add
        WHERE aufnr = lt_add-aufnr.
    ENDIF.

    lt_afpo[] = gt_afpo3[].
    SORT lt_afpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING matnr.
    IF lt_afpo[] IS NOT INITIAL.
      SELECT *
        FROM makt
        APPENDING CORRESPONDING FIELDS OF TABLE gt_makt3
        FOR ALL ENTRIES IN lt_afpo
        WHERE matnr = lt_afpo-matnr
          AND spras = sy-langu.
    ENDIF.
  ENDIF.

  IF gt_ztspppdt007[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_ztspppdt007d
      FROM ztspppdt007d FOR ALL ENTRIES IN gt_ztspppdt007
      WHERE werks = gt_ztspppdt007-werks
        AND afind = gt_ztspppdt007-afind
        AND afinu = gt_ztspppdt007-afinu.

    lt_ztspppdt007[] = gt_ztspppdt007[].
    SORT lt_ztspppdt007 BY aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_ztspppdt007 COMPARING aufnr.
    IF lt_ztspppdt007[] IS NOT INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo2
        FROM afpo FOR ALL ENTRIES IN lt_ztspppdt007
        WHERE aufnr = lt_ztspppdt007-aufnr.

*      SELECT *
*        INTO CORRESPONDING FIELDS OF TABLE gt_resb2
*        FROM resb FOR ALL ENTRIES IN lt_ztspppdt007
*        WHERE aufnr = lt_ztspppdt007-aufnr
*          AND splkz IN (' ','1').
**        AND wempf IN ('T','W').
    ENDIF.

    lt_afpo[] = gt_afpo2[].
    SORT lt_afpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING matnr.
    IF lt_afpo[] IS NOT INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_makt2
        FROM makt FOR ALL ENTRIES IN lt_afpo
        WHERE matnr = lt_afpo-matnr
          AND spras = sy-langu.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA2
*&---------------------------------------------------------------------*
FORM f_get_data2 .
  DATA: lt_ztspppdt007 TYPE STANDARD TABLE OF ztspppdt007.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ztspppdt007
    FROM ztspppdt007 WHERE werks   EQ pa_werks
                       AND afind   IN so_istad
                       AND wbooth  IN so_wboot
                       AND equnr   IN so_equnr
                       AND matnr   IN so_matnr
                       AND phseq   EQ space.

  IF gt_ztspppdt007[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.
  ENDIF.

  SELECT * INTO TABLE gt_ztspppdt007d
    FROM ztspppdt007d FOR ALL ENTRIES IN gt_ztspppdt007
    WHERE werks = gt_ztspppdt007-werks
      AND afind = gt_ztspppdt007-afind
      AND afinu = gt_ztspppdt007-afinu.

  lt_ztspppdt007[] = gt_ztspppdt007[].
  SORT lt_ztspppdt007 BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_ztspppdt007 COMPARING aufnr.
  SELECT DISTINCT * INTO CORRESPONDING FIELDS OF TABLE gt_afpo
    FROM afpo FOR ALL ENTRIES IN lt_ztspppdt007
    WHERE aufnr = lt_ztspppdt007-aufnr.
ENDFORM.                    " F_GET_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA1
*&---------------------------------------------------------------------*
FORM f_process_data1 .
  DATA : ls_add          LIKE LINE OF gt_add,
         ls_out          LIKE LINE OF gt_out,
         ls_makt         LIKE LINE OF gt_makt,
         ls_resb         LIKE LINE OF gt_resb,
         ls_afpo         LIKE LINE OF gt_afpo,
         ls_ztspppdt011  LIKE LINE OF gt_ztspppdt011,
         ls_ztspppdt007  LIKE LINE OF gt_ztspppdt007,
         ls_ztspppdt007d LIKE LINE OF gt_ztspppdt007d.

  LOOP AT gt_add INTO ls_add.
    ls_out-aufnr    = ls_add-aufnr.
    ls_out-wbooth   = ls_add-wbooth.
    ls_out-equnr    = ls_add-equnr.
    ls_out-shtxt    = ls_add-shtxt.
    ls_out-istad    = ls_add-istad.
    ls_out-matnr    = ls_add-matnr.
    ls_out-posnr    = ls_add-posnr.
    ls_out-ltxa1    = ls_add-ltxa1.
    ls_out-operator = ls_add-operator.
    ls_out-pengawas = ls_add-pengawas.
    ls_out-istau    = ls_add-istau.
    ls_out-uzeit    = ls_add-uzeit.

    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_add-matnr.
    IF sy-subrc = 0.
      ls_out-makt1    = ls_makt-maktx.
    ENDIF.

    CLEAR ls_afpo.
    READ TABLE gt_afpo INTO ls_afpo
                       WITH KEY aufnr = ls_add-aufnr.
    IF sy-subrc = 0.
      ls_out-baugr    = ls_afpo-matnr.
      ls_out-char2    = ls_afpo-charg.
    ENDIF.

    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_out-baugr.
    IF sy-subrc = 0.
      ls_out-makt2    = ls_makt-maktx.
    ENDIF.

    CLEAR ls_resb.
    LOOP AT gt_resb INTO ls_resb
                    WHERE aufnr = ls_add-aufnr
                      AND posnr = ls_add-posnr
                      AND splkz = '2'.
      ls_out-char1  = ls_resb-charg.
      ls_out-vornr  = ls_resb-vornr.
      ls_out-erfmg  = ls_resb-erfmg.
      ls_out-erfme  = ls_resb-erfme.

      IF ls_resb-wempf IS INITIAL.
        CLEAR: ls_out-wbooth,ls_out-equnr,ls_out-shtxt,ls_out-istad,
               ls_out-istau,ls_out-uzeit,ls_out-operator,ls_out-pengawas.
        PERFORM f_get_document_date USING     ls_resb-rsnum
                                              ls_resb-rspos
                                    CHANGING  ls_out-istad
                                              ls_out-istau
                                              ls_out-uzeit
                                              ls_out-wbooth
                                              ls_out-operator
                                              ls_out-pengawas.
      ELSE.
        ls_out-wbooth   = ls_add-wbooth.
        ls_out-equnr    = ls_add-equnr.
        ls_out-shtxt    = ls_add-shtxt.
        ls_out-istad    = ls_add-istad.
        ls_out-operator = ls_add-operator.
        ls_out-pengawas = ls_add-pengawas.
        ls_out-istau    = ls_add-istau.
        ls_out-uzeit    = ls_add-uzeit.
      ENDIF.

      PERFORM f_get_manufacture USING ls_out-matnr
                                      ls_out-char1
                                      pa_werks
                                      'ZMF'
                                CHANGING ls_out-atwtb.

      APPEND ls_out TO gt_out.
      CLEAR ls_out-atwtb.
    ENDLOOP.
    CLEAR ls_out.
  ENDLOOP.

  LOOP AT gt_ztspppdt011 INTO ls_ztspppdt011.
    ls_out-aufnr    = ls_ztspppdt011-aufnr.
    ls_out-wbooth   = ls_ztspppdt011-wbooth.
*    ls_out-equnr    = ls_ztspppdt011-equnr.
*    ls_out-shtxt    = ls_ztspppdt011-shtxt.
    ls_out-istad    = ls_ztspppdt011-erdat.
    ls_out-matnr    = ls_ztspppdt011-matnr.
    ls_out-posnr    = ls_ztspppdt011-posnr.
*    ls_out-ltxa1    = ls_ztspppdt011-ltxa1.
    ls_out-operator = ls_ztspppdt011-operator.
    ls_out-pengawas = ls_ztspppdt011-pengawas.
    ls_out-istau    = ls_ztspppdt011-ertim.
    ls_out-uzeit    = ls_ztspppdt011-ertim.
    ls_out-char1    = ls_ztspppdt011-charg.
    ls_out-vornr    = ls_ztspppdt011-vornr.
    ls_out-erfmg    = ls_ztspppdt011-erfmg.
    ls_out-erfme    = ls_ztspppdt011-erfme.

    DATA(ls_resb3) = gt_resb3[ rsnum = ls_ztspppdt011-rsnum ].
    ls_out-ltxa1 = VALUE #( gt_afvc[ aufpl = ls_resb3-aufpl
                                     vornr = ls_ztspppdt011-vornr ]-ltxa1 OPTIONAL ).

    CLEAR ls_makt.
    READ TABLE gt_makt3 INTO ls_makt
                       WITH KEY matnr = ls_ztspppdt011-matnr.
    IF sy-subrc = 0.
      ls_out-makt1    = ls_makt-maktx.
    ENDIF.

    CLEAR ls_afpo.
    READ TABLE gt_afpo3 INTO ls_afpo
                       WITH KEY aufnr = ls_ztspppdt011-aufnr.
    IF sy-subrc = 0.
      ls_out-baugr    = ls_afpo-matnr.
      ls_out-char2    = ls_afpo-charg.
    ENDIF.

    CLEAR ls_makt.
    READ TABLE gt_makt3 INTO ls_makt
                       WITH KEY matnr = ls_out-baugr.
    IF sy-subrc = 0.
      ls_out-makt2    = ls_makt-maktx.
    ENDIF.

    PERFORM f_get_manufacture USING ls_out-matnr
                                    ls_out-char1
                                    pa_werks
                                    'ZMF'
                              CHANGING ls_out-atwtb.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  LOOP AT gt_ztspppdt007 INTO ls_ztspppdt007.
    ls_out-aufnr    = ls_ztspppdt007-aufnr.
    ls_out-wbooth   = ls_ztspppdt007-wbooth.
    ls_out-equnr    = ls_ztspppdt007-equnr.
    ls_out-shtxt    = ls_ztspppdt007-shtxt.
    ls_out-matnr    = ls_ztspppdt007-matnr.
    ls_out-makt1    = ls_ztspppdt007-maktx.
    ls_out-istad    = ls_ztspppdt007-astad.
    ls_out-istau    = ls_ztspppdt007-astau.
    ls_out-datum    = ls_ztspppdt007-afind.
    ls_out-uzeit    = ls_ztspppdt007-afinu.
    ls_out-erfmg    = ls_ztspppdt007-netto.
    ls_out-erfme    = ls_ztspppdt007-meins.
    ls_out-operator = ls_ztspppdt007-operator.
    ls_out-pengawas = ls_ztspppdt007-pengawas.

    IF ls_ztspppdt007-aufnr IS NOT INITIAL.
      CLEAR: ls_afpo,ls_makt.
      READ TABLE gt_afpo2 INTO ls_afpo
                          WITH KEY aufnr = ls_ztspppdt007-aufnr.
      READ TABLE gt_makt2 INTO ls_makt
                          WITH KEY matnr = ls_afpo-matnr.

      ls_out-baugr = ls_afpo-matnr.
      ls_out-char2 = ls_afpo-charg.
      ls_out-makt2 = ls_makt-maktx.
    ENDIF.

    LOOP AT gt_ztspppdt007d INTO ls_ztspppdt007d
                            WHERE werks = ls_ztspppdt007-werks
                              AND afind = ls_ztspppdt007-afind
                              AND afinu = ls_ztspppdt007-afinu.
      ls_out-char1  = ls_ztspppdt007d-charg.
      ls_out-erfmg  = ls_ztspppdt007d-netto.
      ls_out-erfme  = ls_ztspppdt007d-meins.

      PERFORM f_get_manufacture USING ls_out-matnr
                                      ls_out-char1
                                      pa_werks
                                      'ZMF'
                                CHANGING ls_out-atwtb.

      APPEND ls_out TO gt_out.
      CLEAR ls_out-atwtb.
    ENDLOOP.

    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA2
*&---------------------------------------------------------------------*
FORM f_process_data2 .
  DATA : ls_ztspppdt007  LIKE LINE OF gt_ztspppdt007,
         ls_ztspppdt007d LIKE LINE OF gt_ztspppdt007d,
         ls_out          LIKE LINE OF gt_out,
         ls_afpo         LIKE LINE OF gt_afpo.

  LOOP AT gt_ztspppdt007 INTO ls_ztspppdt007.
    ls_out-wbooth   = ls_ztspppdt007-wbooth.
    ls_out-equnr    = ls_ztspppdt007-equnr.
    ls_out-shtxt    = ls_ztspppdt007-shtxt.
    ls_out-matnr    = ls_ztspppdt007-matnr.
    ls_out-makt1    = ls_ztspppdt007-maktx.
*    ls_out-char1    = ls_ztspppdt007-charg.
    ls_out-istad    = ls_ztspppdt007-astad.
    ls_out-istau    = ls_ztspppdt007-astau.
    ls_out-datum    = ls_ztspppdt007-afind.
    ls_out-uzeit    = ls_ztspppdt007-afinu.
*    ls_out-erfmg    = ls_ztspppdt007-netto.
*    ls_out-erfme    = ls_ztspppdt007-meins.
    ls_out-operator = ls_ztspppdt007-operator.
    ls_out-pengawas = ls_ztspppdt007-pengawas.

    IF ls_ztspppdt007-wgttxt IS INITIAL.
      IF ls_ztspppdt007-lgort IS INITIAL.
        ls_out-ket = 'MIS'.
      ELSE.
        ls_out-ket = 'Timbang Sisa Stok'.
      ENDIF.
    ELSE.
      ls_out-ket = ls_ztspppdt007-wgttxt.
    ENDIF.

    LOOP AT gt_ztspppdt007d INTO ls_ztspppdt007d
                            WHERE werks = ls_ztspppdt007-werks
                              AND afind = ls_ztspppdt007-afind
                              AND afinu = ls_ztspppdt007-afinu.
      ls_out-char1  = ls_ztspppdt007d-charg.
      ls_out-erfmg  = ls_ztspppdt007d-netto.
      ls_out-erfme  = ls_ztspppdt007d-meins.

      IF ls_ztspppdt007-aufnr IS NOT INITIAL AND
         ls_out-char1         IS INITIAL AND
         ls_out-matnr         IS INITIAL.
        CLEAR ls_afpo.
        READ TABLE gt_afpo INTO ls_afpo WITH KEY aufnr = ls_ztspppdt007-aufnr.
        ls_out-char1 = ls_afpo-charg.
      ENDIF.

      PERFORM f_get_manufacture USING ls_out-matnr
                                      ls_out-char1
                                      pa_werks
                                      'ZMF'
                                CHANGING ls_out-atwtb.

      APPEND ls_out TO gt_out.
      CLEAR ls_out-atwtb.
    ENDLOOP.

*    IF ls_ztspppdt007-aufnr IS NOT INITIAL.
*      CLEAR ls_afpo.
*      READ TABLE gt_afpo INTO ls_afpo
*                         WITH KEY aufnr = ls_ztspppdt007-aufnr.
*      ls_out-char1 = ls_afpo-charg.
*    ENDIF.
*
*    APPEND ls_out TO gt_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_GET_MANUFACTURE
*&---------------------------------------------------------------------*
FORM f_get_manufacture  USING    fu_matnr
                                 fu_charg
                                 fu_werks
                                 fu_atnam
                        CHANGING fc_atwtb.
  DATA: cob    TYPE STANDARD TABLE OF clbatch,
        ls_cob LIKE LINE OF cob.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    TABLES
      char_of_batch      = cob
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  IF sy-subrc = 0.
    fc_atwtb = VALUE #( cob[ atnam = fu_atnam ]-atwtb OPTIONAL ).
  ENDIF.
ENDFORM.
