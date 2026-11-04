class ZCL_ZUP_WEB_SRV_DPC_EXT definition
  public
  inheriting from ZCL_ZUP_WEB_SRV_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZUP_WEB_SRV_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    TYPES: tt_detl TYPE TABLE OF zcl_zup_web_srv_mpc_ext=>ts_details WITH EMPTY KEY.
    DATA: deep_entity TYPE zcl_zup_web_srv_mpc_ext=>ty_deep,
          ls_header   TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved,
          lt_detl     TYPE tt_detl.

    TYPES: tt_material TYPE TABLE OF zcl_zup_web_srv_mpc_ext=>ts_materials WITH EMPTY KEY.
    DATA: deep_entity2 TYPE  zcl_zup_web_srv_mpc_ext=>ty_deep2,
          ls_header2   TYPE zcl_zup_web_srv_mpc_ext=>ts_sendup,
          lt_detl2     TYPE tt_material.
    CASE iv_entity_set_name.
      WHEN 'get_detailstatusSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = deep_entity2.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        IF deep_entity2 IS NOT INITIAL.
          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = deep_entity
                CHANGING
                  cr_data = er_deep_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.
      WHEN 'statusapprovedSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        IF deep_entity IS NOT INITIAL.
          MOVE-CORRESPONDING deep_entity TO ls_header.
          lt_detl[] = deep_entity-details[].

          DATA(lo_object) = NEW zstatus_approved_pemusnahan( ).
          DATA(gt_result) = lo_object->run( ls_header = ls_header lt_detl = lt_detl ).
          IF gt_result[] IS NOT INITIAL.
            LOOP AT gt_result INTO DATA(gs_result).
              IF gs_result-status = 'S'.
              ELSEIF gs_result-status = 'E'.
                ls_header-status = gs_result-status.
                ls_header-message = gs_result-message.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF ls_header-status IS INITIAL AND ls_header-message IS INITIAL.
              ls_header-status = gs_result-status.
              ls_header-message = gs_result-message.
            ENDIF.
          ENDIF.


          MOVE-CORRESPONDING ls_header TO deep_entity.
          deep_entity-details[] = lt_detl[].
        ENDIF.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = deep_entity
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.

**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  IMPORTING
**    er_deep_entity          =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entity.
    DATA: entity TYPE zcl_zup_web_srv_mpc_ext=>ts_sendup.
    TYPES: BEGIN OF ty_param,
             req_no TYPE znoreq,
             werks  TYPE werks_d,
             lgort  TYPE lgort_d,
           END OF ty_param.
    DATA: gs_param TYPE ty_param.
    DATA: lt_where TYPE TABLE OF string,
          lv_where TYPE string.
    CASE iv_entity_set_name.
      WHEN 'get_detailstatusSet'.
        LOOP AT it_key_tab INTO DATA(ls_key_tab).
          IF ls_key_tab-name = 'nomor_request'.
            gs_param-req_no = ls_key_tab-value.
          ELSEIF ls_key_tab-name = 'plant'.
            gs_param-werks = ls_key_tab-value.
          ELSEIF ls_key_tab-name = 'sloc'.
            gs_param-lgort = ls_key_tab-value.
          ENDIF.
        ENDLOOP.
*        IF gs_param-req_no IS NOT INITIAL.
*          APPEND |req_no = '{ gs_param-req_no }'| TO lt_where.
*        ENDIF.
*        IF gs_param-werks IS NOT INITIAL.
*          APPEND |werks = '{ gs_param-werks }'| TO lt_where.
*        ENDIF.
*        IF gs_param-lgort IS NOT INITIAL.
*          APPEND |lgort = '{ gs_param-lgort }'| TO lt_where.
*        ENDIF.
*        CONCATENATE LINES OF lt_where INTO lv_where SEPARATED BY ' AND '.
*        IF lv_where IS NOT INITIAL.
        IF gs_param-req_no IS NOT INITIAL AND gs_param-werks IS NOT INITIAL AND gs_param-lgort IS NOT INITIAL.
*          SELECT * INTO CORRESPONDING FIELDS OF entity FROM zget_up_cds WHERE (lv_where).
          SELECT * INTO CORRESPONDING FIELDS OF entity FROM zget_up_cds WHERE req_no = gs_param-req_no
            AND werks = gs_param-werks AND lgort = gs_param-lgort.
          ENDSELECT.
          IF entity IS NOT INITIAL.
            entity-status = 'S'.
            entity-message = 'Success get data'.
          ELSE.
            entity-status = 'E'.
            entity-message = 'No Data'.
          ENDIF.
          ENDIF.
*        ENDIF.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = entity
              CHANGING
                cr_data = er_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
**  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
**    it_key_tab              =
**    it_navigation_path      =
**    io_tech_request_context =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: entity_set TYPE TABLE OF zcl_zup_web_srv_mpc_ext=>ts_materials.
    TYPES: BEGIN OF ty_param,
             req_no TYPE znoreq,
             werks  TYPE werks_d,
             lgort  TYPE lgort_d,
           END OF ty_param.
    DATA: gs_param TYPE ty_param.
    DATA: lt_where TYPE TABLE OF string,
          lv_where TYPE string.
    DATA: lv_counter TYPE n LENGTH 4.
    CASE iv_entity_set_name.
      WHEN 'nav_getdetailup'.
        LOOP AT it_key_tab INTO DATA(ls_key_tab).
          IF ls_key_tab-name = 'nomor_request'.
            gs_param-req_no = ls_key_tab-value.
          ELSEIF ls_key_tab-name = 'plant'.
            gs_param-werks = ls_key_tab-value.
          ELSEIF ls_key_tab-name = 'sloc'.
            gs_param-lgort = ls_key_tab-value.
          ENDIF.
        ENDLOOP.
*        IF gs_param-req_no IS NOT INITIAL.
*          APPEND |req_no = '{ gs_param-req_no }'| TO lt_where.
*        ENDIF.
*        IF gs_param-werks IS NOT INITIAL.
*          APPEND |werks = '{ gs_param-werks }'| TO lt_where.
*        ENDIF.
*        IF gs_param-lgort IS NOT INITIAL.
*          APPEND |lgort = '{ gs_param-lgort }'| TO lt_where.
*        ENDIF.
*        CONCATENATE LINES OF lt_where INTO lv_where SEPARATED BY ' AND '.
*        IF lv_where IS NOT INITIAL.
*          SELECT * INTO CORRESPONDING FIELDS OF TABLE entity_set FROM zget_up_cds WHERE (lv_where).
*        ENDIF.
        IF gs_param-req_no IS NOT INITIAL AND gs_param-werks IS NOT INITIAL AND gs_param-lgort IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE entity_set FROM zget_up_cds WHERE req_no = gs_param-req_no
            AND werks = gs_param-werks AND lgort = gs_param-lgort.
        ENDIF.
        IF entity_set[] IS NOT INITIAL.
          LOOP AT entity_set ASSIGNING FIELD-SYMBOL(<fs_entity_set>).
            ADD 1 TO lv_counter.
            <fs_entity_set>-item = lv_counter.

          ENDLOOP.
        ENDIF.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = entity_set
              CHANGING
                cr_data = er_entityset.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
**  EXPORTING
**    iv_entity_name           =
**    iv_entity_set_name       =
**    iv_source_name           =
**    it_filter_select_options =
**    it_order                 =
**    is_paging                =
**    it_navigation_path       =
**    it_key_tab               =
**    iv_filter_string         =
**    iv_search_string         =
**    io_tech_request_context  =
**  IMPORTING
**    er_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  ENDMETHOD.
ENDCLASS.
