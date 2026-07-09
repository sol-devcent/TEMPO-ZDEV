*&---------------------------------------------------------------------*
*&  Include           ZCOR032_F01
*&---------------------------------------------------------------------*

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

FORM f_selection_screen_output .
  CASE 'X'.
    WHEN r1.
      PERFORM f_modify_screen USING : 'PFI' '0' '' '' ''.
*                                      'SPE' '0' '' '' ''.
*                                      'PKU' '0' '' '' '',
*                                      'PST' '0' '' '' '',

    WHEN r2.
      PERFORM f_modify_screen USING :
                                      'PBU' '0' '' '' '',
                                      'GJA' '0' '' '' '',
                                      'SPE' '0' '' '' '',
                                      'SKN' '0' '' '' '',
                                      'ART' '0' '' '' '',
                                      'PFI' '0' '' '' ''.
    WHEN r3.
      PERFORM f_modify_screen USING : 'SPE' '0' '' '' '',
                                      'SKN' '0' '' '' '',
                                      'ART' '0' '' '' '',
                                      'GJA' '0' '' '' '',
                                      'PBU' '0' '' '' ''.
*                                      'PKU' '0' '' '' '',
*                                      'PST' '0' '' '' ''.
  ENDCASE.
ENDFORM.

FORM f_print_data.
  DATA: ls_layout TYPE slis_layout_alv.
  ls_layout-colwidth_optimize = 'X'.

  DATA: g_repid   TYPE sy-repid.
  g_repid = sy-repid.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  CLEAR: lt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZCOR32_STRUCT'
    CHANGING
      ct_fieldcat      = lt_fieldcat.

  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
    CLEAR: <fs_fieldcat>-key.
    CASE <fs_fieldcat>-fieldname.
      WHEN 'PERIO'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Period'.
        <fs_fieldcat>-seltext_m = 'Period'.
        <fs_fieldcat>-seltext_l = 'Period'.
        <fs_fieldcat>-reptext_ddic = 'Period'.
      WHEN 'ARTNR'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Material'.
        <fs_fieldcat>-seltext_m = 'Material'.
        <fs_fieldcat>-seltext_l = 'Material'.
        <fs_fieldcat>-reptext_ddic = 'Material'.
      WHEN 'MAKTX'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Material Description'.
        <fs_fieldcat>-seltext_m = 'Material Description'.
        <fs_fieldcat>-seltext_l = 'Material Description'.
        <fs_fieldcat>-reptext_ddic = 'Material Description'.
      WHEN 'PRCTR'.
        <fs_fieldcat>-seltext_s = 'Profit Center'.
        <fs_fieldcat>-seltext_m = 'Profit Center'.
        <fs_fieldcat>-seltext_l = 'Profit Center'.
        <fs_fieldcat>-reptext_ddic = 'Profit Center'.
      WHEN 'KTEXT'.
        <fs_fieldcat>-seltext_s = 'Profit Center Description'.
        <fs_fieldcat>-seltext_m = 'Profit Center Description'.
        <fs_fieldcat>-seltext_l = 'Profit Center Description'.
        <fs_fieldcat>-reptext_ddic = 'Profit Center Description'.
      WHEN 'WWPGR'.
        <fs_fieldcat>-seltext_s = 'CCHC Category'.
        <fs_fieldcat>-seltext_m = 'CCHC Category'.
        <fs_fieldcat>-seltext_l = 'CCHC Category'.
        <fs_fieldcat>-reptext_ddic = 'CCHC Category'.
      WHEN 'KNDNR'.
        <fs_fieldcat>-seltext_s = 'Customer'.
        <fs_fieldcat>-seltext_m = 'Customer'.
        <fs_fieldcat>-seltext_l = 'Customer'.
        <fs_fieldcat>-reptext_ddic = 'Customer'.
        <fs_fieldcat>-outputlen = '10'.
      WHEN 'NAME1'.
        <fs_fieldcat>-seltext_s = 'Customer Description'.
        <fs_fieldcat>-seltext_m = 'Customer Description'.
        <fs_fieldcat>-seltext_l = 'Customer Description'.
        <fs_fieldcat>-reptext_ddic = 'Customer Description'.
      WHEN 'DDTEXT'.
        <fs_fieldcat>-seltext_s = 'Customer Status'.
        <fs_fieldcat>-seltext_m = 'Customer Status'.
        <fs_fieldcat>-seltext_l = 'Customer Status'.
        <fs_fieldcat>-reptext_ddic = 'Customer Status'.
        <fs_fieldcat>-outputlen = '20'.
      WHEN 'NET_SALES'.
        <fs_fieldcat>-seltext_s = 'Net Sales'.
        <fs_fieldcat>-seltext_m = 'Net Sales'.
        <fs_fieldcat>-seltext_l = 'Net Sales'.
        <fs_fieldcat>-reptext_ddic = 'Net Sales'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'COGS'.
*        <fs_fieldcat>-seltext_s = 'Cogs'.
*        <fs_fieldcat>-seltext_m = 'Cogs'.
*        <fs_fieldcat>-seltext_l = 'Cogs'.
*        <fs_fieldcat>-reptext_ddic = 'Cogs'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'GROSS_PROFIT'.
        <fs_fieldcat>-seltext_s = 'Gross Profit'.
        <fs_fieldcat>-seltext_m = 'Gross Profit'.
        <fs_fieldcat>-seltext_l = 'Gross Profit'.
        <fs_fieldcat>-reptext_ddic = 'Gross Profit'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'MARGIN'.
        <fs_fieldcat>-seltext_s = 'Margin %'.
        <fs_fieldcat>-seltext_m = 'Margin %'.
        <fs_fieldcat>-seltext_l = 'Margin %'.
        <fs_fieldcat>-reptext_ddic = 'Margin %'.
        CLEAR: <fs_fieldcat>-cfieldname.
*        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
*        <fs_fieldcat>-ref_tabname = 'zcor032_struct'.
      WHEN 'REC_WAERS'.
        <fs_fieldcat>-seltext_s = 'Currency'.
        <fs_fieldcat>-seltext_m = 'Currency'.
        <fs_fieldcat>-seltext_l = 'Currency'.
        <fs_fieldcat>-reptext_ddic = 'Currency'.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_default                = 'X'
      i_save                   = 'A'
*     i_structure_name         = 'zco_e011_detl'
    TABLES
      t_outtab                 = it_detl.
ENDFORM.

**&---------------------------------------------------------------------*
**&      Form  TOP-OF-PAGE
**&---------------------------------------------------------------------*
FORM top-of-page.
  DATA: lt_header     TYPE slis_t_listheader,
        ls_header     TYPE slis_listheader,
        lt_line       LIKE ls_header-info,
        lv_lines      TYPE i,
        lv_linesc(10) TYPE c.

**&—– Alv report header —–*
  ls_header-typ = 'S'.
*  ls_header-info = p_bukrs."'PT. BARCLAY PRODUCTS'.
  CONCATENATE 'COMPANY CODE: ' p_bukrs INTO ls_header-info.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
*
*  ls_header-typ = 'H'.
*  ls_header-info = 'EXPENSE CONTROL SHEET'.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
  ls_header-typ = 'S'.
*  ls_header-key = 'PERIOD: '.
  DATA: period TYPE string.
  CONCATENATE s_perio-low+4(3) '.' s_perio-low(4) ' - ' s_perio-high+4(3) '.' s_perio-high(4) INTO period.
  CONCATENATE 'PERIOD: ' period INTO ls_header-info SEPARATED BY ' '. "ls_zco_e011_header-period ls_zco_e011_header-gjahr INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
**
*  ls_header-typ = 'S'.
*  ls_header-key = 'Profit Center: '.
*  ls_header-info = profit_center.
**  CONCATENATE ls_zco_e011_header-prctr ls_zco_e011_header-ktext1 INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Order: '.
*  ls_header-info = order.
**  CONCATENATE ls_zco_e011_header-rkaufnr ls_zco_e011_header-ktext2 INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'SEC: '.
*  ls_header-info = sec.
**  CONCATENATE ls_zco_e011_header-wwsec ls_zco_e011_header-bezek INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Original Budget: '.
*  ls_header-info = ls_zco_e011_header-original_budget.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Spent Budget: '.
*  ls_header-info = ls_zco_e011_header-spent_budget.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Budget Available: '.
*  ls_header-info = ls_zco_e011_header-budget_avail.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
***&—– Pass data and field catalog to ALV function module —–*

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM. "top-of-page
*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA: lt_exclude TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  APPEND '&EXECUTE' TO lt_exclude.
  SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
ENDFORM.                    " F_SET_PF_STATUS
*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&EXECUTE'.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*FORM f_insert_data.
*  DATA: wa_zcodt017 TYPE zcodt017,
*        lv_subrc    TYPE sy-subrc.
*
*  wa_zcodt017 = VALUE zcodt017( bukrs = p_bukrs
*                       kunnr = p_kunnr
*                       status = p_stat
*                       ).
*  TRY.
*      INSERT zcodt017 FROM wa_zcodt017.
*    CATCH cx_sy_open_sql_db.
*      lv_subrc = 4.
*  ENDTRY.
*  IF lv_subrc = 0.
*    COMMIT WORK AND WAIT.
*    MESSAGE 'Successfully maintained data' TYPE 'S'.
*  ENDIF.
*
*ENDFORM.

FORM f_upload_data.
  DATA: lv_subrc    TYPE sy-subrc.
  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_file
        i_begin_col             = 1
        i_begin_row             = 2
        i_end_col               = 10
        i_end_row               = 99999
      TABLES
        intern                  = intern
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here

    ELSE.
      LOOP AT intern INTO DATA(wa_intern).
        CASE wa_intern-col.
*          WHEN '001'.
*            APPEND INITIAL LINE TO it_zcodt017 ASSIGNING FIELD-SYMBOL(<fs_zcodt017>).
*            <fs_zcodt017>-bukrs = wa_intern-value.
          WHEN '001'.
            APPEND INITIAL LINE TO it_zcodt017 ASSIGNING FIELD-SYMBOL(<fs_zcodt017>).
            <fs_zcodt017>-kunnr = wa_intern-value.
          WHEN '002'.
            <fs_zcodt017>-status = wa_intern-value.
          WHEN '003'.
            <fs_zcodt017>-perio1 = wa_intern-value.
          WHEN '004'.
            <fs_zcodt017>-perio2 = wa_intern-value.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF it_zcodt017 IS NOT INITIAL.
    TRY.
        INSERT zcodt017 FROM TABLE it_zcodt017.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
    IF lv_subrc = 0.
      COMMIT WORK AND WAIT.
      MESSAGE 'Successfully uploaded data' TYPE 'S'.
    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TABLE_MAINTENANCE
*&---------------------------------------------------------------------*
FORM f_table_maintenance .
  DATA : sellist      TYPE STANDARD TABLE OF vimsellist.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
      view_name                    = 'ZCODT017'
    TABLES
      dba_sellist                  = sellist
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DATE
*&---------------------------------------------------------------------*
FORM f_change_date  CHANGING fc_datbi
                             fc_datab.
  DATA(ls_perio) = s_perio[ 1 ].
  fc_datbi = |{ ls_perio-high(4) }{ ls_perio-high+5(2) }01 |.
  fc_datab = |{ ls_perio-low(4) }{ ls_perio-low+5(2) }01 |.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fc_datbi
    IMPORTING
      last_day_of_month = fc_datbi.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  CASE 'X'.
    WHEN r1.
      IF p_bukrs IS INITIAL.
        PERFORM f_error_message USING 'PBU' 'Filename required entries'.
      ENDIF.
      IF s_perio[] IS INITIAL.
        PERFORM f_error_message USING 'SPE' 'Filename required entries'.
      ENDIF.
    WHEN r2.
    WHEN r3.
      IF p_file IS INITIAL.
        PERFORM f_error_message USING 'PFI' 'Filename required entries'.
      ENDIF.
  ENDCASE.
ENDFORM.

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
*&      Form  F_INIT_PERIOD
*&---------------------------------------------------------------------*
FORM f_init_period .
  CLEAR s_perio[].
  s_perio-low = |{ sy-datum(4) }001|.
  s_perio-high = |{ sy-datum(4) }0{ sy-datum+4(2) }|.
  s_perio-sign = 'I'.
  s_perio-option = 'BT'.
  APPEND s_perio.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CDS
*&---------------------------------------------------------------------*
FORM f_get_data_cds .
  DATA(lo_amdp) = NEW zcdsco_cl001( ).

* Append exclude material
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'I*' ) TO s_artnr.
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'R*' ) TO s_artnr.
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'P*' ) TO s_artnr.

* Change select option to syntax AMDP
  DATA(lv_flt_kndnr) = cl_shdb_seltab=>combine_seltabs(
      it_named_seltabs = VALUE #( ( name = 'KNDNR' dref = REF #( s_kndnr[] ) ) ) ).

  DATA(lv_flt_artnr) = cl_shdb_seltab=>combine_seltabs(
      it_named_seltabs = VALUE #( ( name = 'ARTNR' dref = REF #( s_artnr[] ) ) ) ).

* Call AMDP
  lo_amdp->get_copa_data(
    EXPORTING
      iv_client     = sy-mandt
      iv_bukrs      = p_bukrs
      iv_perio_from = s_perio-low
      iv_perio_to   = s_perio-high
      iv_flt_kndnr  = lv_flt_kndnr
      iv_flt_artnr  = lv_flt_artnr
    IMPORTING
      et_result = DATA(lt_data)
  ).

  IF lt_data[] IS NOT INITIAL.
    LOOP AT lt_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO it_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
      <fs_detl>-artnr         = ls_data-artnr.
      <fs_detl>-maktx         = ls_data-maktx.
      <fs_detl>-perio         = |{ ls_data-perio WIDTH = 7 ALIGN = RIGHT PAD = '0' }|.
      <fs_detl>-prctr         = ls_data-prctr.
      <fs_detl>-ktext         = ls_data-ktext.
      <fs_detl>-wwpgr         = ls_data-wwpgr.
      <fs_detl>-kndnr         = ls_data-kndnr.
      <fs_detl>-name1         = ls_data-name1.
      <fs_detl>-ddtext        = ls_data-ststext.
      <fs_detl>-rec_waers     = ls_data-rec_waers.
      <fs_detl>-net_sales     = ls_data-net_sales.
      <fs_detl>-cogs          = ls_data-vvcogs.

      <fs_detl>-gross_profit  = <fs_detl>-net_sales - <fs_detl>-cogs.

      IF <fs_detl>-net_sales NE 0.
        <fs_detl>-margin = <fs_detl>-gross_profit / <fs_detl>-net_sales * 100.
      ELSE.
        <fs_detl>-margin = 0.
      ENDIF.
    ENDLOOP.

  ELSE.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.
