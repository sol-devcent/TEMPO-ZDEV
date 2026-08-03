class ZCL_ZWMS_MATERIAL_DPC_EXT definition
  public
  inheriting from ZCL_ZWMS_MATERIAL_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CUSTOM_CREATE_DEEP_ENTITY
    importing
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
    exporting
      !ER_DEEP_ENTITY type ZCL_ZWMS_MATERIAL_MPC_EXT=>TS_DEEP_ENTITY .
private section.
ENDCLASS.



CLASS ZCL_ZWMS_MATERIAL_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA: ir_deep_entity  TYPE zcl_zwms_material_mpc_ext=>ts_deep_entity.

    DATA: lv_low TYPE rvari_val_255.
    DATA: lv_destination TYPE rfcdisplay-rfcdest.

    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'dcc_hSet'.
        CALL METHOD me->custom_create_deep_entity
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
            er_deep_entity          = ir_deep_entity.
    ENDCASE.

    TRY.
        CALL METHOD me->copy_data_to_ref
          EXPORTING
            is_data = ir_deep_entity
          CHANGING
            cr_data = er_deep_entity.
      CATCH cx_root.
    ENDTRY.


  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    DATA: it_material TYPE zcl_zwms_material_mpc_ext=>tt_material.
    DATA: lt_zwms_material TYPE STANDARD TABLE OF zwms_material.
    DATA: lt_temp1 TYPE STANDARD TABLE OF zwms_material.
    DATA: ls_zwms_material TYPE zwms_material.
    DATA: ls_tt_material TYPE zcl_zwms_material_mpc=>ts_material.
    DATA: lt_tt_material TYPE zcl_zwms_material_mpc=>tt_material.
    DATA: ls_batch TYPE zcl_zwms_material_mpc=>ts_batch.
    DATA: lt_batch TYPE zcl_zwms_material_mpc=>tt_batch.
    DATA: lt_mean TYPE STANDARD TABLE OF mean.
    DATA: ls_mean TYPE mean.
    DATA: lv_date TYPE sy-datum.
    "    data: wa_parameter type /IWBEP/T_MGW_NAME_VALUE_PAIR.

**    DATA: lv_warehouse(3).
**    DATA: lv_storage_type(3).
**    DATA: lv_storage_bin(10).

    TYPES: BEGIN OF ty_dcc,
             "             include STRUCTURE ZBPC0005.
             lgnum TYPE lqua-lgnum,
             lgtyp TYPE lqua-lgtyp,
             lgpla TYPE lqua-lgpla,
             ivnum TYPE zbpc0005-ivnum,
             ivpos TYPE zbpc0005-ivpos,
             lqnum TYPE lqua-lqnum,
             matnr TYPE lqua-matnr,
             werks TYPE lqua-werks,
             charg TYPE lqua-charg,
             meins TYPE lqua-meins,
             gesme TYPE lqua-gesme,
             maktx TYPE makt-maktx,
             vfdat TYPE lqua-vfdat,
             bestq TYPE lqua-bestq,
           END OF ty_dcc.
    DATA: lt_dcc TYPE STANDARD TABLE OF ty_dcc.
    DATA: ls_dcc TYPE ty_dcc.
    DATA: ls_zbpc0005 TYPE zbpc0005.
    DATA: lt_zbpc0005 TYPE STANDARD TABLE OF zbpc0005.
    DATA: lv_subrc TYPE sy-subrc.
    DATA: lv_ivpos TYPE zbpc0005-ivpos,
          lv_ivnum TYPE zbpc0005-ivnum.
    DATA: ls_dcch TYPE zcl_zwms_material_mpc_ext=>ts_deep_entity.
    DATA: ls_dccd TYPE zcl_zwms_material_mpc_ext=>ts_dcc_d.
    DATA: lt_dcch TYPE STANDARD TABLE OF  zcl_zwms_material_mpc_ext=>ts_deep_entity.


    CASE iv_action_name.
      WHEN 'fget_dcc'.
        READ TABLE it_parameter INTO DATA(wa_parameter)
          WITH KEY name = 'warehouse'.
        IF sy-subrc = 0.
          DATA(lv_warehouse) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'storage_type'.
        IF sy-subrc = 0.
          DATA(lv_storage_type) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'storage_bin'.
        IF sy-subrc = 0.
          DATA(lv_storage_bin) = wa_parameter-value.
        ENDIF.

        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_dcc
                FROM lqua AS a JOIN makt AS b ON a~matnr = b~matnr
                WHERE lgnum = lv_warehouse AND
                      lgtyp = lv_storage_type AND
                      lgpla = lv_storage_bin AND
                      spras = sy-langu.

        IF lt_dcc[] IS NOT INITIAL.
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr             = '01'
              object                  = 'ZINV'
              subobject               = lv_warehouse
            IMPORTING
              number                  = lv_ivnum
            EXCEPTIONS
              interval_not_found      = 1
              number_range_not_intern = 2
              object_not_found        = 3
              quantity_is_0           = 4
              quantity_is_not_1       = 5
              interval_overflow       = 6
              buffer_overflow         = 7
              OTHERS                  = 8.
          LOOP AT lt_dcc INTO ls_dcc.
            ADD 1 TO lv_ivpos.
            ls_zbpc0005-lgnum = ls_dcc-lgnum.
            ls_zbpc0005-lgtyp = ls_dcc-lgtyp.
            ls_zbpc0005-lgpla = ls_dcc-lgpla.
            ls_zbpc0005-ivnum = lv_ivnum.
            ls_zbpc0005-ivpos = lv_ivpos.
            ls_zbpc0005-lqnum = ls_dcc-lqnum.
            ls_zbpc0005-matnr = ls_dcc-matnr.
            ls_zbpc0005-werks = ls_dcc-werks.
            ls_zbpc0005-charg =  ls_dcc-charg.
            ls_zbpc0005-lgort = '1000'.
            ls_zbpc0005-gesme = ls_dcc-gesme.
            ls_zbpc0005-meins =  ls_dcc-meins.
            ls_zbpc0005-erdat = sy-datum.
            ls_zbpc0005-erzet = sy-uzeit.
            ls_zbpc0005-zuser1 = sy-uname.
            APPEND ls_zbpc0005 TO lt_zbpc0005.

            ls_dcch-warehouse    = ls_dcc-lgnum.
            ls_dcch-storage_type = ls_dcc-lgtyp.
            ls_dcch-storage_bin  = ls_dcc-lgpla.
            ls_dcch-dcc_number   = lv_ivnum.


            ls_dccd-dcc_number = lv_ivnum.
            ls_dccd-dcc_item_number = lv_ivpos..
            ls_dccd-quant_counter = ls_dcc-lqnum.
            ls_dccd-material_number = ls_dcc-matnr.
            "     ls_dccd-MATERIAL_DESCRIPTION type C length 40,
            ls_dccd-batch =  ls_dcc-charg.
            "     ls_dccd-STOCK_CATEGORY type C length 1,
            "     ls_dccd-SHELF_LIFE_EXPIRATION type C length 10,
            ls_dccd-quantity = ls_dcc-gesme.
            "            ls_dccd-uom type =  ls_dcc-meins.
            APPEND ls_dccd TO ls_dcch-nav_dcc.
          ENDLOOP.
          IF lt_zbpc0005[] IS NOT INITIAL.
            CLEAR: lv_subrc.
            LOOP AT lt_zbpc0005 INTO ls_zbpc0005.
              IF ls_zbpc0005 IS NOT INITIAL.
                TRY .
                    MODIFY zbpc0005 FROM ls_zbpc0005.
                  CATCH cx_sy_open_sql_db.
                    lv_subrc = 4.
                ENDTRY.
              ENDIF.
            ENDLOOP.
            IF lv_subrc = 0.
              COMMIT WORK.
            ENDIF.
          ENDIF.
          IF ls_dcch-nav_dcc[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = ls_dcch
              CHANGING
                cr_data = er_data.
          ENDIF.

        ENDIF.

      WHEN 'fimp_material'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'warehouse'.
        IF sy-subrc = 0.
          lv_warehouse = wa_parameter-value.
        ENDIF.
        IF lv_warehouse IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_material
            FROM zwms_material
            WHERE lgnum = lv_warehouse AND
                  ( meinh = 'KAR' OR meinh = 'PAL' ).
          lt_temp1[] =  lt_zwms_material[].
          SORT lt_temp1 BY matnr meins.
          DELETE ADJACENT DUPLICATES FROM lt_temp1 COMPARING matnr meins.
          IF lt_temp1[] IS NOT INITIAL.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mean FROM mean
              FOR ALL ENTRIES IN lt_temp1
              WHERE matnr = lt_temp1-matnr
                AND meinh = lt_temp1-meins.
          ENDIF.
          SORT lt_zwms_material BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_zwms_material COMPARING ALL FIELDS.
          LOOP AT lt_zwms_material INTO ls_zwms_material.
            ls_tt_material-material_number = ls_zwms_material-matnr.
            ls_tt_material-material_description = ls_zwms_material-maktx.
            ls_tt_material-uom_kecil = ls_zwms_material-meins.
            ls_tt_material-batch_management =  ls_zwms_material-xchpf.
            ls_tt_material-warehouse = lv_warehouse.
            ls_tt_material-material_type = ls_zwms_material-mtart.
            ls_tt_material-plant =  ls_zwms_material-werks.
            IF ls_zwms_material-meinh = 'KAR'.
              ls_tt_material-uom_tengah = 'KAR'.
              WRITE ls_zwms_material-umrez TO ls_tt_material-conversion_tengah DECIMALS 0 NO-GROUPING NO-GAP.
              "er_entity-CONVERSION_TENGAH = ls_zwms_material-UMREZ.
            ENDIF.
            IF ls_zwms_material-meinh = 'PAL'.
              ls_tt_material-uom_besar = 'PAL'.
              ls_tt_material-barcode_pro_besar = ls_zwms_material-ean11.
              WRITE ls_zwms_material-umrez TO ls_tt_material-conversion_besar DECIMALS 0 NO-GROUPING NO-GAP.
              "er_entity-CONVERSION_TENGAH = ls_zwms_material-UMREZ.
            ENDIF.
            SORT lt_mean BY matnr meinh.
            READ TABLE lt_mean INTO ls_mean WITH KEY matnr = ls_zwms_material-matnr
                                                     meinh = ls_zwms_material-meins
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_tt_material-barcode_pro_kecil = ls_mean-ean11.
            ENDIF.

            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
              EXPORTING
                input          = ls_tt_material-uom_kecil
              IMPORTING
                output         = ls_tt_material-uom_kecil
              EXCEPTIONS
                unit_not_found = 1
                OTHERS         = 2.

            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
              EXPORTING
                input          = ls_tt_material-uom_tengah
              IMPORTING
                output         = ls_tt_material-uom_tengah
              EXCEPTIONS
                unit_not_found = 1
                OTHERS         = 2.

            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
              EXPORTING
                input          = ls_tt_material-uom_besar
              IMPORTING
                output         = ls_tt_material-uom_besar
              EXCEPTIONS
                unit_not_found = 1
                OTHERS         = 2.

            AT END OF matnr.
              APPEND ls_tt_material TO lt_tt_material.
              CLEAR ls_tt_material.
            ENDAT.
          ENDLOOP.
          IF lt_tt_material[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_tt_material
              CHANGING
                cr_data = er_data.
          ENDIF.

        ENDIF.
      WHEN 'fimp_batch'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'plant'.
        IF sy-subrc = 0.
          DATA(lv_plant) = wa_parameter-value.
        ENDIF.
        IF lv_plant IS NOT INITIAL.
          lv_date = sy-datum - 185.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_batch FROM zwms_batch
            WHERE plant = lv_plant AND create_date > lv_date.

          IF lt_batch[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_batch
              CHANGING
                cr_data = er_data.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  method CUSTOM_CREATE_DEEP_ENTITY.

  endmethod.
ENDCLASS.
