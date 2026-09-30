class ZCL_ZHGWM_MOBILE_DPC_EXT definition
  public
  inheriting from ZCL_ZHGWM_MOBILE_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.

  methods CUSTOM_CREATE_PUTAWAY_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_PUTAWAY_ENTITY type ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_PUTAWAY_ENTITY .
  methods CUSTOM_CREATE_CONFIRM_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_CONFIRM_ENTITY type ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_CONFIRM_ENTITY .
  methods CUSTOM_CREATE_REPLENISH_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_REPLENISH_ENTITY type ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_POSTREPL_ENTITY .
  methods CUSTOM_CREATE_PIDADHOC_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_PIDADHOC_ENTITY type ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_PIDADHOC_ENTITY .
  methods CUSTOM_CREATE_PIDYEARLY_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_PIDYEARLY_ENTITY type ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_PIDYEARLY_ENTITY .

  methods CONFIRMSET_CREATE_ENTITY
    redefinition .
  methods GETDETAILDNSET_GET_ENTITY
    redefinition .
  methods GETDNSET_GET_ENTITY
    redefinition .
  methods GETMATERIAL_SWSE_GET_ENTITY
    redefinition .
  methods GETPICKING_SYSSE_GET_ENTITY
    redefinition .
  methods GETPIDDATASET_GET_ENTITY
    redefinition .
  methods GETPUTAWAY_FGSET_GET_ENTITY
    redefinition .
  methods GETSTPSET_GET_ENTITY
    redefinition .
  methods PIDYEARLYSET_GET_ENTITY
    redefinition .
  methods REPLENISH_SYSSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZHGWM_MOBILE_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA : custom_create_putaway_entity   TYPE zcl_zhgwm_mobile_mpc_ext=>ts_putaway_entity,
           custom_create_confirm_entity   TYPE zcl_zhgwm_mobile_mpc_ext=>ts_confirm_entity,
           custom_create_pidadhoc_entity  TYPE zcl_zhgwm_mobile_mpc_ext=>ts_pidadhoc_entity,
           custom_create_pidyearly_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_pidyearly_entity,
           custom_create_replenish_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_postrepl_entity.

    CASE iv_entity_name.
      WHEN 'postputaway_fg'.
        CALL METHOD me->custom_create_putaway_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_putaway_entity       = custom_create_putaway_entity.

        copy_data_to_ref(
        EXPORTING
        is_data = custom_create_putaway_entity
        CHANGING
        cr_data = er_deep_entity
        ).

      WHEN 'confputaway_fg'.
        CALL METHOD me->custom_create_confirm_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_confirm_entity       = custom_create_confirm_entity.

        copy_data_to_ref(
        EXPORTING
        is_data = custom_create_confirm_entity
        CHANGING
        cr_data = er_deep_entity
        ).

      WHEN 'postrepl_sys'.
        CALL METHOD me->custom_create_replenish_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_replenish_entity     = custom_create_replenish_entity.

        copy_data_to_ref(
        EXPORTING
        is_data = custom_create_replenish_entity
        CHANGING
        cr_data = er_deep_entity
        ).

      WHEN 'postpid_adhoc'.
        CALL METHOD me->custom_create_pidadhoc_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_pidadhoc_entity      = custom_create_pidadhoc_entity.

        copy_data_to_ref(
        EXPORTING
        is_data = custom_create_pidadhoc_entity
        CHANGING
        cr_data = er_deep_entity
        ).

      WHEN 'pidyearly'.
        CALL METHOD me->custom_create_pidyearly_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_pidyearly_entity     = custom_create_pidyearly_entity.

        copy_data_to_ref(
        EXPORTING
        is_data = custom_create_pidyearly_entity
        CHANGING
        cr_data = er_deep_entity
        ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lt_gettogroup TYPE TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_gettogroup.

    DATA: lr_lznum TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_lgnum TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lv_lines TYPE char3.

    DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
          lv_msg      TYPE bapi_msg.

    CASE iv_entity_set_name.
      WHEN 'gettogroupSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          lr_lznum = it_filter_select_options[ property = 'to_group' ]-select_options.
          lr_lgnum = it_filter_select_options[ property = 'warehouse_number' ]-select_options.

          SELECT lgnum, tanum, lznum, vbeln
            INTO TABLE @DATA(lt_ltak)
            FROM ltak WHERE lgnum IN @lr_lgnum
                        AND lznum IN @lr_lznum.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'TO Group tidak ada'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ELSE.
            SELECT DISTINCT tknum INTO TABLE @DATA(lt_tknum)
              FROM vttp FOR ALL ENTRIES IN @lt_ltak
              WHERE vbeln = @lt_ltak-vbeln.

            SELECT DISTINCT vbeln INTO TABLE @DATA(lv_vbeln)
              FROM vttp FOR ALL ENTRIES IN @lt_tknum
              WHERE tknum = @lt_tknum-tknum.

            SELECT a~lgnum, a~lznum, a~tanum, a~lgbzo, a~queue, b~tapos, b~pvqui
              INTO TABLE @DATA(lt_ltap)
              FROM ltak AS a INNER JOIN ltap AS b ON b~lgnum = a~lgnum AND
                                                     b~tanum = a~tanum
              FOR ALL ENTRIES IN @lv_vbeln
              WHERE a~lgnum IN @lr_lgnum
                AND a~vbeln EQ @lv_vbeln-vbeln
                AND a~lznum NE @space.

            SORT lt_ltap BY lgnum lznum tanum tapos.
            DATA(lt_final) = lt_ltap[].
            DELETE ADJACENT DUPLICATES FROM lt_final COMPARING lgnum lznum.
            DESCRIBE TABLE lt_final LINES lv_lines.
            CONDENSE lv_lines.

            LOOP AT lt_final INTO DATA(ls_final).
              APPEND INITIAL LINE TO lt_gettogroup ASSIGNING FIELD-SYMBOL(<fs_gettogroup>).
              <fs_gettogroup>-lznum  = ls_final-lznum.
              <fs_gettogroup>-lgnum  = ls_final-lgnum.
              <fs_gettogroup>-lgbzo  = ls_final-lgbzo.
              <fs_gettogroup>-queue  = ls_final-queue.
              <fs_gettogroup>-totgrp = lv_lines.

              IF line_exists( lt_ltap[ lgnum = ls_final-lgnum
                                       lznum = ls_final-lznum
                                       pvqui = 'X' ] ).
                IF line_exists( lt_ltap[ lgnum = ls_final-lgnum
                                         lznum = ls_final-lznum
                                         pvqui = ' ' ] ).
                  <fs_gettogroup>-stsgrp = 'Picker Process'.
                ELSE.
                  <fs_gettogroup>-stsgrp = 'Checker Process'.
                ENDIF.
              ELSE.
                <fs_gettogroup>-stsgrp = 'Belum Picking'.
              ENDIF.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_gettogroup
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA : lt_transorder  TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_transorder_sys,
           ls_transorder  TYPE zcl_zhgwm_mobile_mpc_ext=>ts_transorder_sys,
           lt_stp         TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_toitem,
           "ls_stp         TYPE zcl_zhgwm_mobile_mpc_ext=>ts_toitem,
           lt_sloc        TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_storloc,
           "ls_sloc        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_storloc,
           lt_stcat       TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_stockcat,
           "ls_stcat       TYPE zcl_zhgwm_mobile_mpc_ext=>ts_stockcat,
           lt_printer     TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_printer,
           "ls_printer     TYPE zcl_zhgwm_mobile_mpc_ext=>ts_printer,
           lt_reason      TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_reasonpid,
           "ls_reason      TYPE zcl_zhgwm_mobile_mpc_ext=>ts_reasonpid,
           lt_scan        TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_scanind,
           "ls_scan        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_scanind,
           lt_pidyear     TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_piditem_year,
           ls_pidyear     TYPE zcl_zhgwm_mobile_mpc_ext=>ts_piditem_year,
           lt_getdetaildn TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_getdetaildn,
           ls_getdetaildn TYPE  zcl_zhgwm_mobile_mpc_ext=>ts_getdetaildn,
           lt_listdn      TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_listdn,
           ls_listdn      TYPE  zcl_zhgwm_mobile_mpc_ext=>ts_listdn,
           lt_listitem    TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_listitem,
           ls_listitem    TYPE zcl_zhgwm_mobile_mpc_ext=>ts_listitem,
           lt_replenish   TYPE STANDARD TABLE OF zcl_zhgwm_mobile_mpc_ext=>ts_replenishitem_sys,
           ls_replenish   TYPE zcl_zhgwm_mobile_mpc_ext=>ts_replenishitem_sys.

    DATA : lv_process  TYPE c LENGTH 30,
           lv_username TYPE sy-uname,
           lv_lgnum    TYPE ltak-lgnum,
           lv_tanum    TYPE ltak-tanum,
           lv_werks    TYPE t001w-werks,
           lv_ivnum    TYPE ztspmmdt006-ivnum,
           lv_batch    TYPE mchb-charg,
           lv_matnr    TYPE mchb-matnr,
           lv_vltyp    TYPE  ltap-vltyp,
           lv_vlpla    TYPE ltap-vlpla,
           lv_lznum    TYPE ltak-lznum.

    lv_username = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ). "New syntax
    lv_lgnum    = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ). "New syntax
    lv_tanum    = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ). "New syntax
    lv_werks    = VALUE #( it_key_tab[ name = 'plant' ]-value OPTIONAL ). "New syntax
    lv_ivnum    = VALUE #( it_key_tab[ name = 'pid_number' ]-value OPTIONAL ). "New syntax
    lv_batch    = VALUE #( it_key_tab[ name = 'batch' ]-value OPTIONAL ). "New syntax
    lv_matnr    = VALUE #( it_key_tab[ name = 'material_number' ]-value OPTIONAL ). "New syntax
    lv_lznum    = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ). "New syntax
    lv_vltyp    = VALUE #( it_key_tab[ name = 'storage_type' ]-value OPTIONAL ). "New syntax
    lv_vlpla    = VALUE #( it_key_tab[ name = 'storage_bin' ]-value OPTIONAL ). "New syntax

    CASE iv_entity_name.
      WHEN 'transorder_sys'.
        lv_process = 'GETPICKING_SYS'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_username = lv_username
              TABLES
                pt_tosys    = lt_transorder.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_transorder-type             = 'E'.
          ls_transorder-message          = 'Gagal get data Picking'.
          APPEND ls_transorder TO lt_transorder.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_transorder
          CHANGING
            cr_data = er_entityset.

      WHEN 'replenishitem_sys'.
        lv_process = 'GETREPLENISH_SYS'.

        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process   = lv_process
                pi_username  = lv_username
              TABLES
                pt_replenish = lt_replenish.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_replenish-type             = 'E'.
          ls_replenish-message          = 'Gagal get data Replenish'.
          APPEND ls_replenish TO lt_replenish.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_replenish
          CHANGING
            cr_data = er_entityset.

      WHEN 'listitem'.
        lv_tanum    = VALUE #( it_key_tab[ name = 'delivery_number' ]-value OPTIONAL ). "New syntax
        lv_process = 'GETDN'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_lgnum    = lv_lgnum
                pi_tanum    = lv_tanum
              TABLES
                pt_listitem = lt_listitem.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_listitem-type             = 'E'.
          ls_listitem-message          = 'Gagal get data DN'.
          APPEND ls_listitem TO lt_listitem.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_listitem
          CHANGING
            cr_data = er_entityset.

      WHEN 'listdn'.
        lv_process = 'GETDETAILDN'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_lgnum   = lv_lgnum
                pi_charg   = lv_batch
                pi_matnr   = lv_matnr
                pi_lznum   = lv_lznum
                pi_vlpla   = lv_vlpla
                pi_vltyp   = lv_vltyp
    "           pi_tanum   = lv_tanum
              TABLES
                pt_listdn  = lt_listdn.

          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_listdn-type             = 'E'.
          ls_listdn-message          = 'Gagal get data detail DN'.
          APPEND ls_listdn TO lt_listdn.
        ENDIF.
        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_listdn
          CHANGING
            cr_data = er_entityset.

      WHEN 'toitem'.
        lv_process = 'GETSTP'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_lgnum   = lv_lgnum
                pi_tanum   = lv_tanum
              TABLES
                pt_stp     = lt_stp.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_stp
          CHANGING
            cr_data = er_entityset.

      WHEN 'storloc'.
        lv_process = 'GET_SLOC'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_werks   = lv_werks
              TABLES
                pt_sloc    = lt_sloc.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_sloc
          CHANGING
            cr_data = er_entityset.

      WHEN 'stockcat'.
        lv_process = 'GET_STCAT'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
              TABLES
                pt_stcat   = lt_stcat.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_stcat
          CHANGING
            cr_data = er_entityset.

      WHEN 'printer'.
        lv_process = 'GET_PRINTER'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_username = lv_username
              TABLES
                pt_printer  = lt_printer.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_printer
          CHANGING
            cr_data = er_entityset.

      WHEN 'reasonpid'.
        lv_process = 'GET_REASON'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_werks   = lv_werks
              TABLES
                pt_reason  = lt_reason.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_reason
          CHANGING
            cr_data = er_entityset.

      WHEN 'scanind'.
        lv_process = 'GET_SCAN'.

        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_lgnum   = lv_lgnum
              TABLES
                pt_scan    = lt_scan.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_scan
          CHANGING
            cr_data = er_entityset.

      WHEN 'piditem_year'.
        lv_process = 'PIDITEM_YEARLY'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_werks   = lv_werks
                pi_ivnum   = lv_ivnum
              TABLES
                pt_pidyear = lt_pidyear.
          CATCH cx_root INTO lo_root_exception.
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_pidyear-type             = 'E'.
          ls_pidyear-message          = 'Gagal get data detail DN'.
          APPEND ls_pidyear TO lt_pidyear.
        ENDIF.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_pidyear
          CHANGING
            cr_data = er_entityset.
    ENDCASE.
  ENDMETHOD.


  METHOD confirmset_create_entity.
    DATA : ls_confirm TYPE zcl_zhgwm_mobile_mpc_ext=>ts_confirm.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'confirm'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_confirm.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_confirm.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        lv_process = 'CONFIRM'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_data    = lv_json
              IMPORTING
                pe_type    = ls_confirm-type
                pe_message = ls_confirm-message.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_confirm-type = 'E'.
          ls_confirm-message =  'Gagal Confirm'.
        ENDIF.

        MOVE-CORRESPONDING ls_confirm TO er_entity.

    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_confirm_entity.
    DATA : ls_confirm_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_confirm_entity,
           ls_confirm        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_confputaway_fg,
           lt_to             TYPE STANDARD TABLE OF zhgwmst002,
           ls_to             LIKE LINE OF lt_to.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'confputaway_fg'.
        lv_process = 'CONFPUTAWAY'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_confirm_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_confirm_entity.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        ls_confirm = CORRESPONDING #( ls_confirm_entity ).
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_data    = lv_json
              IMPORTING
                pe_type    = ls_confirm-type
                pe_message = ls_confirm-message
              TABLES
                pt_to      = lt_to.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_confirm-type = 'E'.
          ls_confirm-message =  'Gagal Conform PUT Away'.
        ENDIF.

        MOVE-CORRESPONDING ls_confirm TO er_confirm_entity.

        LOOP AT lt_to INTO ls_to.
          APPEND ls_to TO er_confirm_entity-nav_conf.
          CLEAR ls_to.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_pidadhoc_entity.
    DATA : ls_pidadhoc_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_pidadhoc_entity,
           ls_pidadhoc        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_postpid_adhoc,
           lt_piditem         TYPE STANDARD TABLE OF zhgwmst014,
           ls_piditem         LIKE LINE OF lt_piditem.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'postpid_adhoc'.
        lv_process = 'POSTPID_ADHOC'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_pidadhoc_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_pidadhoc_entity.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        ls_pidadhoc = CORRESPONDING #( ls_pidadhoc_entity ).
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_data    = lv_json
              IMPORTING
                pe_ivnum   = ls_pidadhoc-pid_number
                pe_type    = ls_pidadhoc-type
                pe_message = ls_pidadhoc-message
              TABLES
                pt_piditem = lt_piditem.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_pidadhoc-type = 'E'.
          ls_pidadhoc-message =  'Gagal Post PID Adhoc'.
        ENDIF.

        MOVE-CORRESPONDING ls_pidadhoc TO er_pidadhoc_entity.

        LOOP AT lt_piditem INTO ls_piditem.
          APPEND ls_piditem TO er_pidadhoc_entity-nav_adhoc.
          CLEAR ls_piditem.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_pidyearly_entity.
    DATA : ls_pidyearly_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_pidyearly_entity,
           ls_pidyearly        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_pidyearly,
           lt_pidyear          TYPE STANDARD TABLE OF zhgwmst016,
           ls_pidyear          LIKE LINE OF lt_pidyear.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'pidyearly'.
        lv_process = 'POST_PIDYEARLY'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_pidyearly_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_pidyearly_entity.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        ls_pidyearly = CORRESPONDING #( ls_pidyearly_entity ).
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_data    = lv_json
              IMPORTING
                pe_type    = ls_pidyearly-type
                pe_message = ls_pidyearly-message
              TABLES
                pt_pidyear = lt_pidyear.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_pidyearly-type = 'E'.
          ls_pidyearly-message =  'Gagal Post PID Yearly'.
        ENDIF.

        MOVE-CORRESPONDING ls_pidyearly TO er_pidyearly_entity.

        LOOP AT lt_pidyear INTO ls_pidyear.
          APPEND ls_pidyear TO er_pidyearly_entity-nav_pidyr.
          CLEAR ls_pidyear.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_putaway_entity.
    DATA : ls_putaway_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_putaway_entity,
           ls_putaway        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_postputaway_fg,
           lt_to             TYPE STANDARD TABLE OF zhgwmst002,
           ls_to             LIKE LINE OF lt_to.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'postputaway_fg'.
        lv_process = 'POSTPUTAWAY'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_putaway_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_putaway_entity.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        ls_putaway = CORRESPONDING #( ls_putaway_entity ).
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_data    = lv_json
              IMPORTING
                pe_type    = ls_putaway-type
                pe_message = ls_putaway-message
              TABLES
                pt_to      = lt_to.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_putaway-type = 'E'.
          ls_putaway-message =  'Gagal Post PutAway'.
        ENDIF.

        MOVE-CORRESPONDING ls_putaway TO er_putaway_entity.

        LOOP AT lt_to INTO ls_to.
          APPEND ls_to TO er_putaway_entity-nav_to.
          CLEAR ls_to.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_replenish_entity.
    DATA : ls_replenish_entity TYPE zcl_zhgwm_mobile_mpc_ext=>ts_postrepl_entity,
           ls_replenish        TYPE zcl_zhgwm_mobile_mpc_ext=>ts_postrepl_sys,
           lt_repl             TYPE STANDARD TABLE OF zhgwmst021,
           ls_repl             LIKE LINE OF lt_repl.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_process   TYPE c LENGTH 30.

    CASE iv_entity_name.
      WHEN 'postrepl_sys'.
        lv_process = 'CONFREPLENISH_SYS'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_replenish_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_replenish_entity.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        ls_replenish = CORRESPONDING #( ls_replenish_entity ).
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_data     = lv_json
              IMPORTING
                pe_type     = ls_replenish-type
                pe_message  = ls_replenish-message
              TABLES
                pt_postrepl = lt_repl.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_replenish-type = 'E'.
          ls_replenish-message =  'Gagal Post Replenish'.
        ENDIF.

        MOVE-CORRESPONDING ls_replenish TO er_replenish_entity.

        LOOP AT lt_repl INTO ls_repl.
          APPEND ls_repl TO er_replenish_entity-nav_postreplsys.
          CLEAR ls_repl.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD getdetaildnset_get_entity.
    "  DATA : lt_ltap    TYPE STANDARD TABLE OF ltap.

    " DATA : lv_kquit   TYPE ltak-kquit.
    DATA: lv_lznum TYPE ltak-lznum.
    DATA: lv_len TYPE i.
    DATA: lv_tanum TYPE ltak-tanum.

    CASE iv_entity_name.
      WHEN 'getdetaildn'.
        er_entity-warehouse_number = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        er_entity-to_number        = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ).
        er_entity-material_number        = VALUE #( it_key_tab[ name = 'material_number' ]-value OPTIONAL ).
        er_entity-batch        = VALUE #( it_key_tab[ name = 'batch' ]-value OPTIONAL ).
        er_entity-storage_type    = VALUE #( it_key_tab[ name = 'storage_type' ]-value OPTIONAL ). "New syntax
        er_entity-storage_bin    = VALUE #( it_key_tab[ name = 'storage_bin' ]-value OPTIONAL ). "New syntax
        SELECT SINGLE maktx INTO er_entity-material_description FROM makt
          WHERE matnr = er_entity-material_number AND spras = sy-langu.
        lv_lznum = er_entity-to_number.
        CONDENSE lv_lznum.
        lv_len = strlen( lv_lznum ).
        IF lv_len = 10.
          lv_tanum = lv_lznum.
          SELECT SINGLE a~tanum INTO lv_tanum
            FROM ltak AS a JOIN likp AS b ON a~vbeln = b~vbeln
                JOIN ltap AS c ON c~tanum = a~tanum
                              AND c~lgnum = a~lgnum
                JOIN kna1 AS d ON b~kunnr = d~kunnr
            WHERE a~tanum = lv_tanum
              AND a~lgnum = er_entity-warehouse_number
              AND matnr = er_entity-material_number
              AND charg = er_entity-batch.
          IF sy-subrc EQ 0.
            er_entity-type = 'S'.
            er_entity-message = 'Get Data'.
          ELSE.
            er_entity-type = 'E'.
            er_entity-message = 'Data tidak ditemukan'.
          ENDIF.
        ELSE.
          SELECT SINGLE lznum INTO lv_lznum
            FROM ltak AS a JOIN likp AS b ON a~vbeln = b~vbeln
                JOIN ltap AS c ON c~tanum = a~tanum
                              AND c~lgnum = a~lgnum
                JOIN kna1 AS d ON b~kunnr = d~kunnr
            WHERE a~lznum = lv_lznum
                    AND a~lgnum = er_entity-warehouse_number
                    AND matnr = er_entity-material_number
                    AND charg = er_entity-batch.
          IF sy-subrc EQ 0.
            er_entity-type = 'S'.
            er_entity-message = 'Get Data'.
          ELSE.
            er_entity-type = 'E'.
            er_entity-message = 'Data tidak ditemukan'.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD getdnset_get_entity.
    DATA: lv_vbeln TYPE ltak-vbeln,
          lv_kunnr TYPE likp-kunnr,
          lv_name1 TYPE kna1-name1.
    CASE iv_entity_name.
      WHEN 'getdn'.
        er_entity-warehouse_number = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        er_entity-delivery_number = VALUE #( it_key_tab[ name = 'delivery_number' ]-value OPTIONAL ).
        SELECT SINGLE vbeln INTO lv_vbeln FROM ltak
          WHERE lgnum = er_entity-warehouse_number
            AND vbeln = er_entity-delivery_number.
        IF sy-subrc EQ 0.
          SELECT SINGLE kunnr
            FROM likp
            INTO lv_kunnr
            WHERE vbeln = er_entity-delivery_number.
          SELECT SINGLE name1
            FROM kna1
            INTO lv_name1
            WHERE kunnr = lv_kunnr.

          er_entity-delivery_number = |{ er_entity-delivery_number } { '-' } { lv_name1 }|.
          er_entity-type = 'S'.
          er_entity-message = 'Get Data'.
        ELSE.
          er_entity-type = 'E'.
          er_entity-message = 'Data tidak ditemukan'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD getmaterial_swse_get_entity.
    DATA : lv_process(30),
           lv_werks       TYPE t001w-werks,
           lv_matnr       TYPE mara-matnr,
           lv_charg       TYPE mchb-charg,
           lv_lgort       TYPE mchb-lgort,
           lv_stcat(60).

    DATA : ls_materialsw    TYPE zhgwmst013.

    CASE iv_entity_name.
      WHEN 'getmaterial_sw'.
        lv_werks  = VALUE #( it_key_tab[ name = 'plant' ]-value OPTIONAL ).
        lv_matnr  = VALUE #( it_key_tab[ name = 'material_number' ]-value OPTIONAL ).
        lv_charg  = VALUE #( it_key_tab[ name = 'batch' ]-value OPTIONAL ).
        lv_lgort  = VALUE #( it_key_tab[ name = 'storage_location' ]-value OPTIONAL ).
        lv_stcat  = VALUE #( it_key_tab[ name = 'stock_category' ]-value OPTIONAL ).

        lv_process    = 'GETMATERIAL_SW'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process    = lv_process
                pi_werks      = lv_werks
                pi_matnr      = lv_matnr
                pi_charg      = lv_charg
                pi_lgort      = lv_lgort
                pi_stcat      = lv_stcat
              IMPORTING
                pe_materialsw = ls_materialsw.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_materialsw-type = 'E'.
          ls_materialsw-message =  'Gagal Get Material'.
        ENDIF.

        er_entity  = ls_materialsw.
    ENDCASE.
  ENDMETHOD.


  METHOD getpicking_sysse_get_entity.
    DATA : ls_picksys  TYPE zhgwmst004.

    DATA : lv_process  TYPE c LENGTH 30,
           lv_username TYPE sy-uname.

    CASE iv_entity_name.
      WHEN 'getpicking_sys'.
        lv_username = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ).

        lv_process    = 'GETPICKING_SYS'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_username = lv_username
              IMPORTING
                pe_picksys  = ls_picksys.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_picksys-type = 'E'.
          ls_picksys-message =  'Gagal Get Picking'.
        ENDIF.

        er_entity  = ls_picksys.
    ENDCASE.
  ENDMETHOD.


  METHOD getpiddataset_get_entity.
    DATA : ls_piddata  TYPE zhgwmst007.

    DATA : lv_process  TYPE c LENGTH 30,
           lv_username TYPE sy-uname,
           lv_lgnum    TYPE ltak-lgnum,
           lv_werks    TYPE t001w-werks.

    CASE iv_entity_name.
      WHEN 'getpiddata'.
        lv_lgnum = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        lv_werks = VALUE #( it_key_tab[ name = 'plant' ]-value OPTIONAL ).
        lv_username = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ).

        lv_process    = 'GETPIDDATA'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_username = lv_username
                pi_lgnum    = lv_lgnum
                pi_werks    = lv_werks
              IMPORTING
                pe_piddata  = ls_piddata.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_piddata-type = 'E'.
          ls_piddata-message =  'Gagal Get PID Data'.
        ENDIF.

        er_entity   = ls_piddata.
    ENDCASE.
  ENDMETHOD.


  METHOD getputaway_fgset_get_entity.
    DATA : ls_putaway  TYPE zhgwmst001.

    DATA : lv_lgnum     TYPE lagp-lgnum,
           lv_prueflos  TYPE qals-prueflos,
           lv_lznum     TYPE ltak-lznum,
           lv_process   TYPE c LENGTH 30,
           lv_menge(20).

    CASE iv_entity_name.
      WHEN 'getputaway_fg'.
        lv_lgnum    = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        lv_prueflos = VALUE #( it_key_tab[ name = 'inspection_lot' ]-value OPTIONAL ).
        lv_lznum    = VALUE #( it_key_tab[ name = 'pallet_number' ]-value OPTIONAL ).
        lv_menge    = VALUE #( it_key_tab[ name = 'quantity' ]-value OPTIONAL ).

        lv_process = 'GETPUTAWAY'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process  = lv_process
                pi_lgnum    = lv_lgnum
                pi_prueflos = lv_prueflos
                pi_lznum    = lv_lznum
                pi_menge    = lv_menge
              IMPORTING
                pe_putaway  = ls_putaway.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_putaway-type = 'E'.
          ls_putaway-message =  'Gagal Get PUT Away'.
        ENDIF.

        MOVE-CORRESPONDING ls_putaway TO er_entity.
    ENDCASE.
  ENDMETHOD.


  METHOD getstpset_get_entity.
    DATA : lt_ltap    TYPE STANDARD TABLE OF ltap.

    DATA : lv_kquit   TYPE ltak-kquit.

    CASE iv_entity_name.
      WHEN 'getstp'.
        er_entity-warehouse_number = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        er_entity-to_number        = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ).

        SELECT SINGLE queue kquit
          FROM ltak
          INTO ( er_entity-queue, lv_kquit )
          WHERE lgnum = er_entity-warehouse_number
            AND tanum = er_entity-to_number.

        SELECT *
          FROM ltap
          INTO CORRESPONDING FIELDS OF TABLE lt_ltap
          WHERE lgnum = er_entity-warehouse_number
            AND tanum = er_entity-to_number
            AND pvqui = space.

        IF lv_kquit = 'X'.
          er_entity-type    = 'E'.
          er_entity-message = 'TO sudah dicheck'.
*        ELSEIF lt_ltap[] IS NOT INITIAL.
*          er_entity-type    = 'E'.
*          er_entity-message = 'ada TO belum dipicking'.
        ELSE.
          er_entity-type    = 'S'.
          er_entity-message = 'GET TO data'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD pidyearlyset_get_entity.
    DATA : ls_pidyear  TYPE zhgwmst015.

    DATA : lv_process TYPE c LENGTH 30,
           lv_ivnum   TYPE ztspmmdt006-ivnum,
           lv_werks   TYPE t001w-werks.

    CASE iv_entity_name.
      WHEN 'pidyearly'.
        lv_werks = VALUE #( it_key_tab[ name = 'plant' ]-value OPTIONAL ).
        lv_ivnum = VALUE #( it_key_tab[ name = 'pid_number' ]-value OPTIONAL ).

        lv_process    = 'PIDYEARLY'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process = lv_process
                pi_werks   = lv_werks
                pi_ivnum   = lv_ivnum
              IMPORTING
                pe_pidyear = ls_pidyear.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_pidyear-type = 'E'.
          ls_pidyear-message =  'Gagal Get PUT Away'.
        ENDIF.

        er_entity   = ls_pidyear.
    ENDCASE.
  ENDMETHOD.


  METHOD replenish_sysset_get_entity.
    DATA : ls_replenish  TYPE zhgwmst019.

    DATA : lv_process  TYPE c LENGTH 30,
           lv_username TYPE sy-uname.

    CASE iv_entity_name.
      WHEN 'replenish_sys'.
        lv_username = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ).

        lv_process    = 'GETREPLENISH_SYS'.
        TRY.
            CALL FUNCTION 'ZHGWMFM001'
              EXPORTING
                pi_process   = lv_process
                pi_username  = lv_username
              IMPORTING
                pe_replenish = ls_replenish.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_replenish-type = 'E'.
          ls_replenish-message =  'Gagal Get PUT Away'.
        ENDIF.

        er_entity  = ls_replenish.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
