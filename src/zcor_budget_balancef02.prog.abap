*&---------------------------------------------------------------------*
*&  Include           ZCOR_BUDGET_BALANCEF02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE1'.
ENDFORM.                    " F_STATUS

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
        rows    = 2
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_contain02.

    CREATE OBJECT g_splitter1
      EXPORTING
        parent  = g_contain02
        rows    = 1
        columns = 2.

    CALL METHOD g_splitter1->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain03.

    CALL METHOD g_splitter1->get_container
      EXPORTING
        row       = 1
        column    = 2
      RECEIVING
        container = g_contain04.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_maingrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_maingrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_create_dyn_int_table USING '1'.
    PERFORM f_build_layout USING '1'.
    PERFORM f_build_sort USING '1'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_maingrid.

    CALL METHOD g_maingrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_main_alv
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
*&      Form  F_MTD_ALV
*&---------------------------------------------------------------------*
FORM f_mtd_alv .
  IF g_mtdgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_mtdgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain03.

    PERFORM f_create_dyn_int_table USING '2'.
    PERFORM f_build_layout USING '2'.
    PERFORM f_build_sort USING '2'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_mtdgrid.

    CALL METHOD g_mtdgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_mtd_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_mtd_sort[]
        it_outtab            = gt_mpo[]
        it_fieldcatalog      = gt_mtd_fieldcat[].
  ENDIF.
ENDFORM.                    " F_MTD_ALV

*&---------------------------------------------------------------------*
*&      Form  F_YTD_ALV
*&---------------------------------------------------------------------*
FORM f_ytd_alv .
  IF g_ytdgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_ytdgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain04.

    PERFORM f_create_dyn_int_table USING '3'.
    PERFORM f_build_layout USING '3'.
    PERFORM f_build_sort USING '3'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_ytdgrid.

    CALL METHOD g_ytdgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_ytd_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_ytd_sort[]
        it_outtab            = gt_ypo[]
        it_fieldcatalog      = gt_ytd_fieldcat[].
  ENDIF.
ENDFORM.                    " F_YTD_ALV

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
    WHEN '&ALL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&PICK'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_display_po.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_maingrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_proc.
  CASE fu_proc.
    WHEN '1'.
*  gs_main_alv-box_fname           = 'CHECK'.
      gs_main_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_main_alv-no_rowmark          = selected.
      gs_main_alv-cwidth_opt          = selected.
      gs_main_alv-stylefname          = 'STYLE'.
      gs_main_alv-ctab_fname          = 'COLOR'.
      gs_main_alv-zebra               = selected.
      gs_main_alv-no_toolbar          = selected.
    WHEN '2'.
      gs_mtd_alv-s_dragdrop-row_ddid = g_handle_alv.
      gs_mtd_alv-cwidth_opt          = selected.
      gs_mtd_alv-zebra               = selected.
      gs_mtd_alv-grid_title          = 'Purchase Order MTD'.
    WHEN '3'.
      gs_ytd_alv-s_dragdrop-row_ddid = g_handle_alv.
      gs_ytd_alv-cwidth_opt          = selected.
      gs_ytd_alv-zebra               = selected.
      gs_ytd_alv-grid_title          = 'Purchase Order YTD'.
  ENDCASE.

ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort  USING    fu_proc.
  CLEAR : gt_main_sort[], gt_mtd_sort[], gt_ytd_sort[].

  CASE fu_proc.
    WHEN '1'.
      PERFORM f_alv_sort USING : 1 'KGRP1' 'X' '' 'X' fu_proc,
                                 2 'KGRP1' 'X' '' 'X' fu_proc,
                                 3 'KOSTL' 'X' '' '' fu_proc,
                                 4 'KSTAR' 'X' '' '' fu_proc.
    WHEN '2'.
      PERFORM f_alv_sort USING : 1 'KOSTL' 'X' '' '' fu_proc,
                                 2 'KSTAR' 'X' '' '' fu_proc.
    WHEN '3'.
      PERFORM f_alv_sort USING : 1 'KOSTL' 'X' '' '' fu_proc,
                                 2 'KSTAR' 'X' '' '' fu_proc.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down
                          fu_subtot fu_proc.
  CASE fu_proc.
    WHEN '1'.
      gt_main_sort-spos      = fu_spos.
      gt_main_sort-fieldname = fu_fieldname.
      gt_main_sort-up        = fu_up.
      gt_main_sort-down      = fu_down.
      gt_main_sort-subtot    = fu_subtot.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
    WHEN '2'.
      gt_mtd_sort-spos      = fu_spos.
      gt_mtd_sort-fieldname = fu_fieldname.
      gt_mtd_sort-up        = fu_up.
      gt_mtd_sort-down      = fu_down.
      gt_mtd_sort-subtot    = fu_subtot.
      APPEND gt_mtd_sort.
      CLEAR gt_mtd_sort.
    WHEN '3'.
      gt_ytd_sort-spos      = fu_spos.
      gt_ytd_sort-fieldname = fu_fieldname.
      gt_ytd_sort-up        = fu_up.
      gt_ytd_sort-down      = fu_down.
      gt_ytd_sort-subtot    = fu_subtot.
      APPEND gt_ytd_sort.
      CLEAR gt_ytd_sort.
  ENDCASE.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_maingrid->get_frontend_fieldcatalog
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
    PERFORM f_alv_refresh USING 'X' '1'.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh fu_proc.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CASE fu_proc.
      WHEN '1'.
        IF g_maingrid IS NOT INITIAL.
          CALL METHOD g_maingrid->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.
      WHEN '2'.
        IF g_mtdgrid IS NOT INITIAL.
          CALL METHOD g_mtdgrid->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.
      WHEN '3'.
        IF g_ytdgrid IS NOT INITIAL.
          CALL METHOD g_ytdgrid->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table  USING    fu_pos.
  CASE fu_pos.
    WHEN '1'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
        '' 'X' '' '' '' '',
        fu_pos 'KGRP1' '' '' '' '' '' '' 'KGRP1' 'ZCODT001' 'Group 1' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'KGRP2' '' '' '' '' '' '' 'KGRP2' 'ZCODT001' 'Group 2' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'KOSTL' '' '' '' '' '' '' 'KOSTL' 'CSKS' '' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'KHINR' '' '' '' '' '' '' 'KHINR' 'CSKS' '' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'KSTAR' '' '' '' '' '' '' 'KSTAR' 'COEJ' '' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'SPMON' '' '' '' '' '' '' 'SPMON' 'S001' '' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'TWAER' '' '' '' '' '' '' 'TWAER' 'COEJ' '' ''
        '' '' '' '' '' '' 'X' '' '' '' '',
        fu_pos 'MTDBUD' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'MTD Budget' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'MTDACT' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'MTD Actual' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'MTDCOM' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'MTD Commit' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'MTDBAL' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'MTD Balance' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'YTDBUD' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'YTD Budget' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'YTDACT' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'YTD Actual' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'YTDCOM' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'YTD Commit' '' '' '' '' '' '' '' '' '' 'X' '' '',
        fu_pos 'YTDBAL' '' '' 'TWAER' '' '' '' 'UMKZWI1' 'S001'
        'YTD Balance' '' '' '' '' '' '' '' '' '' 'X' '' ''.
    WHEN '2'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KOSTL' '' '' '' '' '' '' 'KOSTL' 'CSKS' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'KSTAR' '' '' '' '' '' '' 'KSTAR' 'COEJ' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'BEDAT' '' '' '' '' '' '' 'BEDAT' 'EKKO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELM' '' '' '' '' '' '' 'EBELN' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELP' '' '' '' '' '' '' 'EBELP' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'TXZ01' '' '' '' '' '' '' 'TXZ01' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'WAERS' '' '' '' '' '' '' 'WAERS' 'EKKO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'NETWR' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'GRWRB' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO'
        'GR Value' '' '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'SALDO' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO'
        'Saldo' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN '3'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KOSTL' '' '' '' '' '' '' 'KOSTL' 'CSKS' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'KSTAR' '' '' '' '' '' '' 'KSTAR' 'COEJ' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'BEDAT' '' '' '' '' '' '' 'BEDAT' 'EKKO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELY' '' '' '' '' '' '' 'EBELN' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELP' '' '' '' '' '' '' 'EBELP' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'TXZ01' '' '' '' '' '' '' 'TXZ01' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'WAERS' '' '' '' '' '' '' 'WAERS' 'EKKO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'NETWR' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'GRWRB' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO'
        'GR Value' '' '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'SALDO' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO'
        'Saldo' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum fu_noout.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_title USING fu_coltext '' '' ''
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
  ls_dyn_fcat-no_out      = fu_noout.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  CASE fu_pos.
    WHEN '1'.
      APPEND ls_dyn_fcat TO gt_main_fieldcat.
    WHEN '2'.
      APPEND ls_dyn_fcat TO gt_mtd_fieldcat.
    WHEN '3'.
      APPEND ls_dyn_fcat TO gt_ytd_fieldcat.
  ENDCASE.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_TITLE
*&---------------------------------------------------------------------*
FORM f_title  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_TITLE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PO
*&---------------------------------------------------------------------*
FORM f_display_po .
  DATA : lt_out     TYPE STANDARD TABLE OF ty_out,
         ls_out     LIKE LINE OF lt_out,
         ls_po      TYPE ty_po,
         ls_ekko    LIKE LINE OF gt_ekko,
         ls_ekpo    LIKE LINE OF gt_ekpo,
         ls_eket    LIKE LINE OF gt_eket,
         lv_wemng   TYPE eket-wemng.

  DATA : lt_ebkn    TYPE TABLE OF ty_ebkn WITH HEADER LINE.

  CLEAR : gt_mpo[], gt_ypo[].

  lt_ebkn[] = gt_ebkn[].
  SORT lt_ebkn BY kostl sakto ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_ebkn COMPARING kostl sakto ebeln.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.

  IF lt_out[] IS NOT INITIAL.
    LOOP AT lt_out INTO ls_out.
*      LOOP AT gt_ebkn WHERE kostl = ls_out-kostl
      LOOP AT lt_ebkn WHERE kostl = ls_out-kostl
                        AND sakto = ls_out-kstar.
        LOOP AT gt_ekkn WHERE ebeln = lt_ebkn-ebeln
                          AND kostl = ls_out-kostl
                          AND sakto = ls_out-kstar.
*        LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = gt_ebkn-ebeln
*                                       AND ebelp = gt_ebkn-ebelp.
*        LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = lt_ebkn-ebeln.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = gt_ekkn-ebeln
                                         AND ebelp = gt_ekkn-ebelp.
            CLEAR ls_ekko.
            READ TABLE gt_ekko INTO ls_ekko
                               WITH KEY ebeln = ls_ekpo-ebeln.
            IF sy-subrc = 0.
              ls_po-waers = ls_ekko-waers.
              ls_po-bedat = ls_ekko-bedat.
            ENDIF.

            CLEAR : ls_eket, lv_wemng.
            LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                           AND ebelp = ls_ekpo-ebelp.
              ADD ls_eket-wemng TO lv_wemng.
            ENDLOOP.

            ls_po-kostl  = ls_out-kostl.
            ls_po-kstar  = ls_out-kstar.
            ls_po-ebeln  = ls_ekpo-ebeln.
            ls_po-ebelp  = ls_ekpo-ebelp.
            ls_po-netwr  = ls_ekpo-netwr.
            ls_po-txz01  = ls_ekpo-txz01.
            ls_po-grwrb  = lv_wemng * ( ls_ekpo-netpr / ls_ekpo-peinh ).
            ls_po-saldo  = ls_po-netwr - ls_po-grwrb.
*          IF gt_ebkn-bedat IN gr_mbedat.
            IF lt_ebkn-bedat IN gr_mbedat.
              APPEND ls_po TO gt_mpo.
              APPEND ls_po TO gt_ypo.
              CLEAR ls_po.
            ELSE.
              APPEND ls_po TO gt_ypo.
              CLEAR ls_po.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  PERFORM f_alv_refresh USING 'X' '2'.
  PERFORM f_alv_refresh USING 'X' '3'.
ENDFORM.                    " F_DISPLAY_PO

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  CASE 'X'.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PBU' '0' '' '' '',
                                      'PGJ' '0' '' '' '',
                                      'PMO' '0' '' '' '',
                                      'CSK' '0' '' '' '',
                                      'SKS' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

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
*&      Form  F_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_double_click  USING    fu_row fu_column.
  DATA : ls_po    TYPE ty_po.

  CASE fu_column.
    WHEN 'EBELM'.
      CLEAR ls_po.
      READ TABLE gt_mpo INTO ls_po INDEX fu_row.
      IF sy-subrc = 0.
        SET PARAMETER ID 'BES' FIELD ls_po-ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'EBELY'.
      CLEAR ls_po.
      READ TABLE gt_ypo INTO ls_po INDEX fu_row.
      IF sy-subrc = 0.
        SET PARAMETER ID 'BES' FIELD ls_po-ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_GET_EKET
*&---------------------------------------------------------------------*
FORM f_get_eket  USING    fu_ebeln fu_ebelp fu_netpr fu_peinh
                 CHANGING fc_grwrb.
  DATA : ls_eket      LIKE LINE OF gt_eket,
         lv_wemng     TYPE eket-wemng.

  CLEAR : ls_eket, lv_wemng.
  LOOP AT gt_eket INTO ls_eket WHERE ebeln = fu_ebeln
                                 AND ebelp = fu_ebelp.
    ADD ls_eket-wemng TO lv_wemng.
  ENDLOOP.
  fc_grwrb  = lv_wemng * ( fu_netpr / fu_peinh ).
ENDFORM.                    " F_GET_EKET
