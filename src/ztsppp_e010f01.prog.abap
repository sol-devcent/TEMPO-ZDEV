*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  READ TABLE so_posnr INDEX 1.
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
  DATA : lv_mess(100).

  IF pa_werks IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
             ID 'WERKS' FIELD pa_werks.
    IF sy-subrc <> 0.
      CONCATENATE 'You are not authorized in Plant' pa_werks
      INTO lv_mess
      SEPARATED BY space.
      PERFORM f_error_message USING 'PWE' lv_mess.
    ENDIF.
  ELSE.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.

  IF pa_aufnr IS INITIAL.
    PERFORM f_error_message USING 'PAU' ''.
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
  DATA : lt_xresb TYPE STANDARD TABLE OF resb,
         ls_xresb LIKE LINE OF lt_xresb.

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE gt_resb
    WHERE aufnr = pa_aufnr
      AND werks = pa_werks
      AND posnr IN so_posnr.

  IF sy-subrc = 0.
    lt_xresb[] = gt_resb[].
    SORT lt_xresb BY rsnum.
    DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING rsnum.
    IF lt_xresb[] IS NOT INITIAL.
      SELECT *
        FROM mseg
        INTO CORRESPONDING FIELDS OF TABLE gt_mseg
        FOR ALL ENTRIES IN lt_xresb
        WHERE rsnum = lt_xresb-rsnum.

      IF sy-subrc = 0.
        PERFORM f_filter_cancel_mseg.
      ENDIF.

      READ TABLE lt_xresb INTO ls_xresb INDEX 1.
      SELECT SINGLE * INTO gs_zppresb_add
        FROM zppresb_add WHERE aufnr = ls_xresb-aufnr
                           AND matnr = ls_xresb-matnr
                           AND posnr = ls_xresb-posnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out  LIKE LINE OF gt_out,
         ls_resb LIKE LINE OF gt_resb,
         ls_mseg LIKE LINE OF gt_mseg.

  DATA : lv_subrc   TYPE sy-subrc.

  CLEAR : gt_bapiret2[].

  LOOP AT gt_resb INTO ls_resb.
    READ TABLE gt_mseg INTO ls_mseg
                       WITH KEY rsnum = ls_resb-rsnum
                                rspos = ls_resb-rspos.
    IF sy-subrc = 0.
      ls_out-mblnr  = ls_mseg-mblnr.
      ls_out-mjahr  = ls_mseg-mjahr.
      ls_out-zeile  = ls_mseg-zeile.
      ls_out-menge  = ls_mseg-menge.
      ls_out-meins  = ls_mseg-meins.
    ENDIF.
    ls_out-werks  = ls_resb-werks.
    ls_out-rsnum  = ls_resb-rsnum.
    ls_out-rspos  = ls_resb-rspos.
    ls_out-aufnr  = ls_resb-aufnr.
    ls_out-charg  = ls_resb-charg.
    ls_out-baugr  = ls_resb-baugr.
    ls_out-matnr  = ls_resb-matnr.
    ls_out-vornr  = ls_resb-vornr.
    ls_out-posnr  = ls_resb-posnr.
    ls_out-splkz  = ls_resb-splkz.
    ls_out-wempf  = ls_resb-wempf.

    CASE ls_resb-splkz.
      WHEN ' ' OR '1'.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      WHEN OTHERS.
*        PERFORM f_fullpack_weighing USING ls_out-matnr
*                                          ls_out-charg
*                                          ls_out-werks
*                                          ls_resb-bdmng
*                                    CHANGING ls_out-fw.
        CASE ls_out-wempf(1).
          WHEN 'W' OR 'T'.
            ls_out-fw = 'W'.
          WHEN 'F' OR 'U'.
            ls_out-fw = 'F'.
        ENDCASE.

    ENDCASE.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  IF gt_bapiret2[] IS NOT INITIAL.
    MESSAGE s000(zab) WITH 'Check the Error Log' DISPLAY LIKE 'E'.
  ENDIF.
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
    dynlog-text         = 'Error Log'.
  ELSE.
    dynlog-icon_id      = icon_protocol.
    dynlog-icon_text    = 'Error Log'.
    dynlog-text         = 'Error Log'.
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
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c,
         lv_lines TYPE i.

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

    WHEN '&REV'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_check_selected_itab USING lv_ucomm
                                      CHANGING gv_subrc.
        IF gv_subrc IS INITIAL.
          PERFORM f_cancel_process USING lv_ucomm.
        ENDIF.
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
  gs_layout_alv-no_rowmark          = selected.
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

  PERFORM f_alv_sort USING : 1 'RSPOS' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '',
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'FW' '' '' '' '' '' '' '' '' 'F/W' '' '' '' '' '' ''
    'X' 'X' '' '' ''.

  IF pa_werks(2) = '36'.    "KMM
    PERFORM f_dyn_int_table USING :
      'WEMPF' '' '' '' '' '' '' 'WEMPF' 'RESB' '' '' '' '' '' '' ''
      'X' 'X' '' '' ''.
  ENDIF.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'RESB' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'RSNUM' '' '' '' '' '' '' 'RSNUM' 'RESB' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'RSPOS' '' '' '' '' '' '' 'RSPOS' 'RESB' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'AUFNR' '' '' '' '' '' '' 'AUFNR' 'RESB' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'BAUGR' '' '' '' '' '' '' 'BAUGR' 'RESB' 'Product' '' '' '' ''
    '' '' 'X' 'X' '' '' '',
    'VORNR' '' '' '' '' '' '' 'VORNR' 'RESB' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'POSNR' '' '' '' '' '' '' 'POSNR' 'RESB' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'RESB' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'CHARG' '' '' '' '' '' '' 'CHARG' 'RESB' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MBLNR' '' '' '' '' '' '' 'MBLNR' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MJAHR' '' '' '' '' '' '' 'MJAHR' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'ZEILE' '' '' '' '' '' '' 'ZEILE' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MEINS' '' '' '' '' '' '' 'MEINS' 'MSEG' '' '' '' '' '' '' ''
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
*&      Form  F_STYLE_CELL
*&---------------------------------------------------------------------*
FORM f_style_cell  USING    fu_flag fu_fieldname fu_fieldname1
                   CHANGING fc_celltab  TYPE lvc_t_styl.
  DATA : lt_celltab   TYPE lvc_t_styl WITH HEADER LINE.

  CLEAR : lt_celltab[], lt_celltab.

  IF fu_flag IS NOT INITIAL.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  CLEAR fc_celltab[].

  IF fu_fieldname1 IS NOT INITIAL.
    lt_celltab-fieldname = fu_fieldname1.
    APPEND lt_celltab.
  ENDIF.
  lt_celltab-fieldname = fu_fieldname.
  APPEND lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE fc_celltab.
ENDFORM.                    " F_STYLE_CELL

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_DATA
*&---------------------------------------------------------------------*
FORM f_error_data  USING    fu_subrc fu_value.
  DATA : ls_error       LIKE LINE OF gt_bapiret2,
         lv_mess_v1(50),
         lv_mess_v2(50),
         lv_mess_v3(50),
         lv_mess_v4(50).

  CASE fu_subrc.
    WHEN 1.
      lv_mess_v1 = 'Item'.
      lv_mess_v2 = fu_value.
      lv_mess_v3 = 'tidak bisa cancel'.
      SHIFT lv_mess_v2 LEFT DELETING LEADING '0'.

    WHEN 2.
      lv_mess_v1 = 'Reservation'.
      lv_mess_v2 = fu_value.
      SHIFT lv_mess_v2 LEFT DELETING LEADING '0'.

    WHEN OTHERS.
      lv_mess_v1 = fu_value..
  ENDCASE.

  ls_error-id          = 'ZAB'.
  ls_error-number      = '000'.
  ls_error-type        = 'E'.
  ls_error-message_v1  = lv_mess_v1.
  ls_error-message_v2  = lv_mess_v2.
  ls_error-message_v3  = lv_mess_v3.
  ls_error-message_v4  = lv_mess_v4.
  APPEND ls_error TO gt_bapiret2.
ENDFORM.                    " F_ERROR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_PROCESS
*&---------------------------------------------------------------------*
FORM f_cancel_process USING fu_ucomm.
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         return  TYPE STANDARD TABLE OF bapiret2,
         wmdvsx  TYPE STANDARD TABLE OF bapiwmdvs,
         wmdvex  TYPE STANDARD TABLE OF bapiwmdve,
         ls_out  LIKE LINE OF gt_out.

  "Cancel GI
  CLEAR: gt_bapiret2,gt_out_error.
  PERFORM f_bapi_cancel.

  "Cancel Reservation
*  PERFORM f_reset_qty.               "with BDC
  PERFORM f_reservation_cancel.
  PERFORM f_cancel_timbang.

  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_CANCEL_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table  USING    fu_rsnum fu_rspos.
  DATA : ls_out   LIKE LINE OF gt_out.

  CLEAR : ls_out-mblnr, ls_out-mjahr, ls_out-zeile,
          ls_out-menge, ls_out-meins.

  PERFORM f_style_cell USING '' 'MARK' ''
                       CHANGING ls_out-style.

  MODIFY gt_out FROM ls_out TRANSPORTING mblnr mjahr zeile menge meins style
                            WHERE rsnum = fu_rsnum
                              AND rspos = fu_rspos.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ATP_CHECK
*&---------------------------------------------------------------------*
FORM f_atp_check  USING    fu_aufnr.
  d_bdc_tctxt = 'Executing Transaction COR2'.
  d_bdc_batch = 'N'.

  CLEAR : t_bdcdata, t_bdcmsg[].
  REFRESH : t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPLCOKO'            '5110',
    ' ' 'BDC_OKCODE'          '/00',
    ' ' 'CAUFVD-AUFNR'        fu_aufnr,
    ' ' 'R62CLORD-FLG_COMPL'  'X'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPLCOKO'            '5115',
    ' ' 'BDC_OKCODE'          '=VERF'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPLCOKO'            '5115',
    ' ' 'BDC_OKCODE'          '=BU'.

  PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                          t_bdcmsg
                                   USING  'COR2'
                                          d_bdc_tctxt.

  CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, d_bdc_error.

ENDFORM.                    " F_ATP_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_CANCEL
*&---------------------------------------------------------------------*
FORM f_bapi_cancel .
  DATA : lt_xout    TYPE STANDARD TABLE OF ty_out,
         ls_xout    LIKE LINE OF lt_xout,
         lt_return  TYPE STANDARD TABLE OF bapiret2,
         ls_return  LIKE LINE OF lt_return,
         lt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_04,
         ls_item    LIKE LINE OF lt_item,
         ls_headret LIKE bapi2017_gm_head_ret.

  lt_xout[]  = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  DELETE lt_xout WHERE mblnr IS INITIAL.

  LOOP AT lt_xout INTO ls_xout.
    CLEAR: ls_headret,lt_return,ls_return,lt_item,ls_item.
    ls_item-matdoc_item = ls_xout-zeile.
    APPEND ls_item TO lt_item.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        materialdocument    = ls_xout-mblnr
        matdocumentyear     = ls_xout-mjahr
      IMPORTING
        goodsmvt_headret    = ls_headret
      TABLES
        return              = lt_return
        goodsmvt_matdocitem = lt_item.

*    IF sy-subrc = 0.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = 'X'.
*
**    PERFORM f_atp_check USING fu_aufnr.
*      PERFORM f_modify_table USING ls_xout-rsnum
*                                   ls_xout-rspos.
*    ELSE.
*      LOOP AT lt_return INTO ls_return.
*        APPEND ls_return TO gt_bapiret2.
*        CLEAR ls_return.
*      ENDLOOP.
*    ENDIF.

    IF line_exists( lt_return[ type = 'E' ] ).
      APPEND ls_xout TO gt_out_error.
      LOOP AT lt_return INTO ls_return.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ENDLOOP.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

*    PERFORM f_atp_check USING fu_aufnr.
      PERFORM f_modify_table USING ls_xout-rsnum
                                   ls_xout-rspos.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_CANCEL

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_REFRESH
*&---------------------------------------------------------------------*
FORM f_output_refresh .
  DATA : ls_out   LIKE LINE OF gt_out,
         ls_dresb LIKE LINE OF gt_dresb.

  IF gt_dresb[] IS NOT INITIAL.
    LOOP AT gt_out INTO ls_out WHERE mark IS NOT INITIAL.
      READ TABLE gt_dresb INTO ls_dresb
                          WITH KEY rsnum = ls_out-rsnum
                                   rspos = ls_out-rspos.
      IF sy-subrc = 0.
        DELETE TABLE gt_out FROM ls_out.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_OUTPUT_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_TIMBANG
*&---------------------------------------------------------------------*
FORM f_cancel_timbang .
  CALL FUNCTION 'ZTSPPPFM002'
    TABLES
      it_add                   = gt_add
      it_dresb                 = gt_dresb
      it_uresb                 = gt_uresb
      it_onr00                 = gt_onr00
      it_jest                  = gt_jest
      it_jsto                  = gt_jsto
      it_zkmmppdt024           = gt_zkmmppdt024
      it_zkmmppdt023           = gt_zkmmppdt023
      it_zkmmppdt019           = gt_zkmmppdt019
      it_ztspppdt011           = gt_ztspppdt011
      it_ztspppdt012           = gt_ztspppdt012
      it_zsffppdt002           = gt_zsffppdt002
      it_zsffppdt004           = gt_zsffppdt004
    EXCEPTIONS
      error_delete_resb        = 1
      error_update_resb        = 2
      error_delete_onr00       = 3
      error_delete_zppresb_add = 4
      OTHERS                   = 5.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        PERFORM f_error_data USING '' 'Error Delete Reservation'.
      WHEN 2.
        PERFORM f_error_data USING '' 'Error Update Reservation'.
      WHEN 3.
        PERFORM f_error_data USING '' 'Error Delete ONR00'.
      WHEN 4.
        PERFORM f_error_data USING '' 'Error Delete JEST'.
      WHEN 5.
        PERFORM f_error_data USING '' 'Error Delete JSTO'.
      WHEN 6.
        PERFORM f_error_data USING '' 'Error Delete History'.
    ENDCASE.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK AND WAIT.
    PERFORM f_output_refresh.
  ENDIF.
ENDFORM.                    " F_CANCEL_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_
*&---------------------------------------------------------------------*
FORM f_ .
  DATA : resbve_tab    TYPE STANDARD TABLE OF resbsv,
         aufnr_vpr_tab TYPE STANDARD TABLE OF aufnr_vpr.

  CALL FUNCTION 'CO_ZA_AVAILABILITY_CHECK'
* EXPORTING
*   FLG_MESS               = ' '
*   FLG_MESS_OBJ_DEP       = ' '
*   OPEN_CALL              = ' '
*   REL_CALL               = ' '
*   FLG_TEILP              = ' '
*   FLG_OPERP              = ' '
*   NO_CHECK               = ' '
*   I_ANWDG                = '1'
*   I_AZERG                = '1'
*   I_AZERG_TP             = '3'
*   I_MEMO_TP              = 'X'
*   I_FILL_MDVAX           = ' '
*   I_TRTYP                = 'V'
*   I_MULTI_CHECK          = ' '
*   NO_SPLIT_CHECK         = ' '
*   RSNUM                  =
*   SAVE_CALL              = ' '
*   SIM_CALL               = ' '
* IMPORTING
*   E_BSFAK_BATCH          =
    TABLES
      resbve_tab    = resbve_tab
      aufnr_vpr_tab = aufnr_vpr_tab
*     MDVAX_VPR     =
*     RESBVE_TAB_ALL         =
*     ATPCSX_VPR    =
    EXCEPTIONS
      error         = 1
      OTHERS        = 2.

ENDFORM.                    " F_

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_CANCEL_MSEG
*&---------------------------------------------------------------------*
FORM f_filter_cancel_mseg .
  DATA : lt_xmseg TYPE STANDARD TABLE OF mseg,
         ls_mseg  LIKE LINE OF gt_mseg.

  lt_xmseg[] = gt_mseg[].
  DELETE gt_mseg WHERE smbln IS NOT INITIAL.
  DELETE lt_xmseg WHERE smbln IS INITIAL.

  IF lt_xmseg[] IS NOT INITIAL.
    LOOP AT gt_mseg INTO ls_mseg.
      READ TABLE lt_xmseg WITH KEY smbln = ls_mseg-mblnr
                                   sjahr = ls_mseg-mjahr
                                   smblp = ls_mseg-zeile
                                   TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE TABLE gt_mseg FROM ls_mseg.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_FILTER_CANCEL_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_FULLPACK_WEIGHING
*&---------------------------------------------------------------------*
FORM f_fullpack_weighing  USING    fu_matnr
                                   fu_charg
                                   fu_werks
                                   fu_menge
                          CHANGING fc_fw.
  DATA: cob      TYPE STANDARD TABLE OF clbatch,
        ls_cob   LIKE LINE OF cob,
        lv_packq TYPE bdmng,
        lv_sisa  TYPE bdmng.

  fc_fw = 'W'.

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
    READ TABLE cob INTO ls_cob
                   WITH KEY atnam = 'QTY_CONVERSION'.
    IF sy-subrc = 0.
      TRANSLATE ls_cob-atwtb USING '. '.
      TRANSLATE ls_cob-atwtb USING ',.'.
      CONDENSE ls_cob-atwtb NO-GAPS.
      lv_packq  = ls_cob-atwtb.
      lv_sisa = fu_menge MOD lv_packq.

      IF lv_sisa IS INITIAL.
        fc_fw = 'F'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_FULLPACK_WEIGHING

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SELECTED_ITAB
*&---------------------------------------------------------------------*
FORM f_check_selected_itab  USING fu_ucomm
                            CHANGING fc_subrc.
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  fc_subrc = 4.

* Cek data selected
  lt_xout[]  = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  IF lt_xout[] IS INITIAL.
    MESSAGE s000(zab) WITH 'Tidak ada data yang dipilih' DISPLAY LIKE 'E'.
    fc_subrc = 4.
    EXIT.
  ELSE.
    CLEAR fc_subrc.
  ENDIF.

** Cek select W & F
*  READ TABLE lt_xout WITH KEY fw = 'W'
*                     TRANSPORTING NO FIELDS.
*  IF sy-subrc = 0.
*    READ TABLE lt_xout WITH KEY fw = 'F'
*                       TRANSPORTING NO FIELDS.
*    IF sy-subrc = 0.
*      MESSAGE s000(zab) WITH 'Weighing & Fullpack tidak boleh cancel berbarengan' DISPLAY LIKE 'E'.
*      fc_subrc = 4.
*      EXIT.
*    ELSE.
*      CLEAR fc_subrc.
*    ENDIF.
*  ELSE.
*    CLEAR fc_subrc.
*  ENDIF.
*
*  CASE fu_ucomm.
*    WHEN '&GI'.
** Cek mat. doc.
*      READ TABLE lt_xout WITH KEY mblnr = space
*                         TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        MESSAGE s000(zab) WITH 'Ada data yang belum GI' DISPLAY LIKE 'E'.
*        fc_subrc = 4.
*        EXIT.
*      ELSE.
*        CLEAR fc_subrc.
*      ENDIF.
*
*    WHEN '&RES'.
** Cek mat. doc.
*      READ TABLE lt_xout WITH KEY mjahr(1) = '2'
*                         TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        MESSAGE s000(zab) WITH 'Ada data yang belum cancel GI' DISPLAY LIKE 'E'.
*        fc_subrc = 4.
*        EXIT.
*      ELSE.
*        CLEAR fc_subrc.
*      ENDIF.
*
*    WHEN '&GIRES'.
** Cek mat. doc.
*      READ TABLE lt_xout WITH KEY mblnr = space
*                         TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        MESSAGE s000(zab) WITH 'Ada data yang belum GI' DISPLAY LIKE 'E'.
*        fc_subrc = 4.
*        EXIT.
*      ELSE.
*        CLEAR fc_subrc.
*      ENDIF.
*  ENDCASE.
ENDFORM.                    " F_CHECK_SELECTED_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_RESET_QTY
*&---------------------------------------------------------------------*
FORM f_reset_qty .
  TYPES: BEGIN OF ty_no,
           no TYPE numc2,
         END OF ty_no.

  DATA: lv_mode(1),
        lv_no      TYPE numc2,
        lv_field   TYPE char20,
        lt_resb    TYPE TABLE OF resb  WITH HEADER LINE,
        lt_no      TYPE TABLE OF ty_no WITH HEADER LINE.

  SELECT * INTO TABLE lt_resb
    FROM resb WHERE aufnr = pa_aufnr.

  CLEAR lv_no.
  SORT lt_resb BY aufnr posnr.
  LOOP AT lt_resb.
    ADD 1 TO lv_no.
    IF lt_resb-aufnr = pa_aufnr AND
       lt_resb-posnr = so_posnr-low.
      lt_no-no = lv_no.
      APPEND lt_no. CLEAR lt_no.
    ENDIF.
  ENDLOOP.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLCOKO'            '5110',
       ' '  'BDC_OKCODE'          '/00',
       ' '  'CAUFVD-AUFNR'        pa_aufnr,
       ' '  'R62CLORD-FLG_COMPL'  'X'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLCOKO'            '5115',
       ' '  'BDC_OKCODE'          '=OMLA'.

  CLEAR lt_no.
  READ TABLE lt_no INDEX 1.
  CONCATENATE 'RC27X-FLG_SEL(' lt_no-no ')' INTO lv_field.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLCOMK'            '5120',
       ' '  'BDC_OKCODE'          '=CHPI'.

  LOOP AT lt_no.
    CLEAR: lv_field.
    CONCATENATE 'RC27X-FLG_SEL(' lt_no-no ')' INTO lv_field.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
         ' '  lv_field  'X'.
  ENDLOOP.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLV01F'            '0100',
       ' '  'BDC_OKCODE'          '=DMNG'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLV01F'            '0100',
       ' '  'BDC_OKCODE'          '=TAKE'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLCOMK'            '5120',
       ' '  'BDC_OKCODE'          '=BU'.

  BREAK tds_dev01.
  lv_mode = 'E'.
  CALL TRANSACTION 'COR2' USING   t_bdcdata
                          MODE    lv_mode
                          UPDATE  'S'
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    ROLLBACK WORK.
  ELSE.
    READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM f_delete_table.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RESET_QTY

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_TABLE
*&---------------------------------------------------------------------*
FORM f_delete_table .
  "Delete itab
  DELETE gt_out WHERE mark = 'X'.
ENDFORM.                    " F_DELETE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION_CANCEL
*&---------------------------------------------------------------------*
FORM f_reservation_cancel .
  DATA: lv1(2),lv2(2),lv3(3),lv4(2),lv5(3).

  DATA : lt_xout  TYPE STANDARD TABLE OF ty_out,
         lt_xoutd TYPE STANDARD TABLE OF ty_out,
         lt_xoutw TYPE STANDARD TABLE OF ty_out,
*         lt_xout_dmp  TYPE STANDARD TABLE OF ty_out,
         ls_xout  LIKE LINE OF lt_xout,
         lv_cnt1  TYPE int1,
         lv_cnt2  TYPE int1.

  DATA : ls_dresb LIKE LINE OF gt_dresb,
         ls_uresb LIKE LINE OF gt_uresb,
         ls_onr00 LIKE LINE OF gt_onr00,
         ls_jest  LIKE LINE OF gt_jest,
         ls_jsto  LIKE LINE OF gt_jsto,
         ls_add   LIKE LINE OF gt_add.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  LOOP AT lt_xout INTO ls_xout.
    IF line_exists( gt_out_error[ werks = ls_xout-werks
                                  rsnum = ls_xout-rsnum
                                  rspos = ls_xout-rspos ] ).
      DELETE TABLE lt_xout FROM ls_xout.
      ASSIGN gt_out[ werks = ls_xout-werks
                     rsnum = ls_xout-rsnum
                     rspos = ls_xout-rspos ] TO FIELD-SYMBOL(<fs_out>).
      IF sy-subrc = 0.
        <fs_out>-icon = icon_red_light.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR: gt_dresb[],gt_uresb[],gt_onr00[],lv_cnt1,lv_cnt2,
         gt_jest[],gt_jsto[],gt_add[],gt_zkmmppdt019[],
         gt_zsffppdt004[].

  IF lt_xout[] IS NOT INITIAL.
    CASE pa_werks.
      WHEN '3603'.
        SELECT * INTO TABLE gt_zkmmppdt023
          FROM zkmmppdt023 FOR ALL ENTRIES IN lt_xout
          WHERE rsnum = lt_xout-rsnum
            AND rspos = lt_xout-rspos.
      WHEN '3600'.
        SELECT * INTO TABLE gt_zkmmppdt019
          FROM zkmmppdt019 FOR ALL ENTRIES IN lt_xout
          WHERE rsnum = lt_xout-rsnum
            AND rspos = lt_xout-rspos.
      WHEN '0101' OR '0102'.
        SELECT * INTO TABLE gt_ztspppdt011
          FROM ztspppdt011 FOR ALL ENTRIES IN lt_xout
          WHERE rsnum = lt_xout-rsnum
            AND rspos = lt_xout-rspos.
      WHEN '0901'.
        SELECT * INTO TABLE gt_zsffppdt002
          FROM zsffppdt002 FOR ALL ENTRIES IN lt_xout
          WHERE rsnum = lt_xout-rsnum
            AND rspos = lt_xout-rspos.
    ENDCASE.

    SELECT * INTO TABLE gt_dresb
      FROM resb FOR ALL ENTRIES IN lt_xout
      WHERE rsnum = lt_xout-rsnum
        AND rspos = lt_xout-rspos.

    SELECT * INTO TABLE gt_onr00
      FROM onr00 FOR ALL ENTRIES IN gt_dresb
      WHERE objnr = gt_dresb-objnr.

    SELECT * INTO TABLE gt_jest
      FROM jest FOR ALL ENTRIES IN gt_dresb
      WHERE objnr = gt_dresb-objnr.

    SELECT * INTO TABLE gt_jsto
      FROM jsto FOR ALL ENTRIES IN gt_dresb
      WHERE objnr = gt_dresb-objnr.

    lt_xoutw[] = lt_xout[].
    DELETE lt_xoutw WHERE fw NE 'W'.
    IF lt_xoutw[] IS NOT INITIAL AND
       ( pa_werks NE '3600' AND pa_werks NE '3603' ).
      LOOP AT lt_xoutw ASSIGNING FIELD-SYMBOL(<fs_xoutw>).
        <fs_xoutw>-aufnr2 = |{ <fs_xoutw>-aufnr ALPHA = OUT }|.
      ENDLOOP.

      SELECT * INTO TABLE gt_add
        FROM zppresb_add FOR ALL ENTRIES IN lt_xoutw
        WHERE aufnr = lt_xoutw-aufnr
          AND matnr = lt_xoutw-matnr
          AND posnr = lt_xoutw-posnr.
      SELECT * INTO TABLE gt_zsffppdt004
        FROM zsffppdt004 FOR ALL ENTRIES IN lt_xoutw
        WHERE ( aufnr = lt_xoutw-aufnr OR aufnr = lt_xoutw-aufnr2 )
          AND matnr = lt_xoutw-matnr
          AND posnr = lt_xoutw-posnr.

    ELSEIF lt_xoutw[] IS NOT INITIAL AND pa_werks EQ '3603'.
      SELECT * INTO TABLE gt_zkmmppdt024
        FROM zkmmppdt024 FOR ALL ENTRIES IN lt_xoutw
        WHERE rsnum = lt_xoutw-rsnum
          AND rspos = lt_xoutw-rspos.
    ENDIF.

    lt_xoutd[] = lt_xout[].
    SORT lt_xoutd BY aufnr posnr.
    DELETE ADJACENT DUPLICATES FROM lt_xoutd COMPARING aufnr posnr.
    LOOP AT lt_xoutd INTO ls_xout.
      SELECT SINGLE * INTO ls_uresb
        FROM resb WHERE aufnr = ls_xout-aufnr
                    AND posnr = ls_xout-posnr
                    AND splkz IN (' ','1').

      "Append URESB
      LOOP AT gt_dresb INTO ls_dresb WHERE aufnr = ls_xout-aufnr
                                       AND posnr = ls_xout-posnr.
        ADD : ls_dresb-bdmng TO ls_uresb-bdmng,
              ls_dresb-erfmg TO ls_uresb-erfmg,
              ls_dresb-bdmng TO ls_uresb-vmeng.
      ENDLOOP.

      IF ls_uresb-bdmng = ls_uresb-nomng.
        CLEAR: ls_uresb-splkz,ls_uresb-wempf,ls_uresb-nomng.
      ENDIF.

      CLEAR: ls_uresb-kzear.
      APPEND ls_uresb TO gt_uresb.
    ENDLOOP.

    IF line_exists( lt_xout[ fw = 'W' ] ).
      DATA(ls_xout_dmp) = lt_xout[ fw = 'W' ].
      READ TABLE gt_dresb INTO DATA(ls_resb_dmp)
                          WITH KEY rsnum = ls_xout_dmp-rsnum
                                   rspos = ls_xout_dmp-rspos.

      SELECT SINGLE aufpl, aplzl, vornr, phseq, steus
        INTO @DATA(ls_afvc) FROM afvc
        WHERE aufpl = @ls_resb_dmp-aufpl
          AND aplzl = @ls_resb_dmp-aplzl
          AND steus = 'ZP01'.

      IF sy-subrc = 0.
        lv1 = lv2 = lv3 = lv4 = lv5 = ls_afvc-phseq.
        lv1(1) = 'D'.
        lv2(1) = 'E'.
        lv3(1) = 'G'.
        lv4(1) = 'L'.
        lv5(1) = 'O'.

        IF ls_resb_dmp-sortf = 'D'.
          SELECT SINGLE aufpl, aplzl, vornr, phseq, steus
            INTO @DATA(ls_afvc2) FROM afvc
            WHERE aufpl = @ls_resb_dmp-aufpl
              AND phseq = @lv2
              AND steus = 'ZP01'.
        ELSE.
          SELECT SINGLE aufpl aplzl vornr phseq steus
            INTO ls_afvc2 FROM afvc
            WHERE aufpl = ls_resb_dmp-aufpl
              AND phseq IN (lv1,lv3,lv4,lv5)
              AND steus = 'ZP01'.
        ENDIF.

        IF sy-subrc = 0.
          SELECT SINGLE * INTO @DATA(ls_ztspppdt012)
            FROM ztspppdt012 WHERE aufpl = @ls_afvc2-aufpl
                               AND aplzl = @ls_afvc2-aplzl
                               AND stats = '0010'
                               AND vornr = @ls_afvc2-vornr
                               AND actwh = @ls_afvc-vornr.
          IF sy-subrc = 0.
            CLEAR: ls_ztspppdt012-datef, ls_ztspppdt012-timef.
            APPEND ls_ztspppdt012 TO gt_ztspppdt012.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " F_RESERVATION_CANCEL
