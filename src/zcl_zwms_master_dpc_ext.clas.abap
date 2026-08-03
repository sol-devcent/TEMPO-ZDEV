class ZCL_ZWMS_MASTER_DPC_EXT definition
  public
  inheriting from ZCL_ZWMS_MASTER_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZWMS_MASTER_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    TYPES: BEGIN OF ty_stock,
             lgnum TYPE lqua-lgnum,
             lqnum TYPE lqua-lqnum,
             matnr TYPE lqua-matnr,
             werks TYPE lqua-werks,
             charg TYPE lqua-charg,
             lgtyp TYPE lqua-lgtyp,
             lgpla TYPE lqua-lgpla,
             ausme TYPE lqua-ausme,
             meins TYPE lqua-meins,
             gesme TYPE lqua-gesme,
             bestq TYPE lqua-bestq,
             wdatu TYPE lqua-wdatu,
             vfdat TYPE lqua-vfdat,
             mtart TYPE mara-mtart,
             maktx TYPE makt-maktx,
           END OF ty_stock.
    DATA: lt_stock_lqua TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.
    DATA: ls_stock_lqua LIKE LINE OF lt_stock_lqua.
    DATA: it_material TYPE zcl_zwms_master_mpc_ext=>tt_material.
    DATA: lt_zwms_material TYPE STANDARD TABLE OF zwms_material.
    DATA: lt_zwms_batch TYPE STANDARD TABLE OF zwms_batch.
    DATA: lt_zwms_uom TYPE STANDARD TABLE OF zwms_uom.
    DATA: lt_temp1 TYPE STANDARD TABLE OF zwms_material.
    DATA: ls_zwms_material TYPE zwms_material.
    DATA: ls_zwms_batch TYPE zwms_batch.
    DATA: ls_zwms_uom TYPE zwms_uom.
    DATA: ls_tt_material TYPE zcl_zwms_master_mpc=>ts_material.
    DATA: lt_tt_material TYPE zcl_zwms_master_mpc=>tt_material.
    DATA: ls_batch TYPE zcl_zwms_master_mpc=>ts_batch.
    DATA: lt_batch TYPE zcl_zwms_master_mpc=>tt_batch.
    DATA: ls_uom TYPE zcl_zwms_master_mpc=>ts_uom_barcode.
    DATA: lt_uom TYPE zcl_zwms_master_mpc=>tt_uom_barcode.
    DATA: lt_uom1 TYPE zcl_zwms_master_mpc=>tt_uom.
    DATA: ls_uom1 TYPE zcl_zwms_master_mpc=>ts_uom.
    DATA: ls_stock TYPE zcl_zwms_master_mpc=>ts_stock.
    DATA: lt_stock TYPE zcl_zwms_master_mpc=>tt_stock.
    DATA: lt_zwms_stock TYPE STANDARD TABLE OF zwms_stock WITH DEFAULT KEY.
    DATA: ls_zwms_stock TYPE zwms_stock. " WITH DEFAULT KEY.
    DATA: lt_mean TYPE STANDARD TABLE OF mean.
    DATA: ls_mean TYPE mean.
    DATA: lv_date TYPE sy-datum.
    DATA: ls_barcode1 TYPE zwms_uom-barcode.
    DATA: ls_barcode2 TYPE zwms_uom-barcode.
    DATA: lv_material_number(18).
    DATA: lt_marm TYPE STANDARD TABLE OF marm,
          ls_marm LIKE LINE OF lt_marm.
    DATA: lv_pe_uom   TYPE char3,
          lv_pe_value TYPE char10.
    DATA: lv_lgnum     TYPE lgnum,
          lv_werks     TYPE werks_d,
          lv_kar       TYPE meinh,
          lv_mtart     TYPE mara-mtart,
          lv_charvalue TYPE char10.
    "    data: wa_parameter type /IWBEP/T_MGW_NAME_VALUE_PAIR.


*    DATA: lt_get_vmsta TYPE TABLE OF zget_vmsta2,
*          ls_get_vmsta TYPE zget_vmsta2.
    CASE iv_action_name.
      WHEN 'fget_material'.
        READ TABLE it_parameter INTO DATA(wa_parameter)
          WITH KEY name = 'warehouse'.
        IF sy-subrc = 0.
          DATA(lv_warehouse) = wa_parameter-value.
        ENDIF.
        IF lv_warehouse IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_material
            FROM zwms_material
            WHERE lgnum = lv_warehouse. " AND
          "hpean = 'X'. "( meinh = 'KAR' OR meinh = 'PAL' ) and

**            Added view for vmsta
*          SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_get_vmsta FROM zget_vmsta2.


          DELETE ADJACENT DUPLICATES FROM lt_zwms_material COMPARING ALL FIELDS.
          SORT lt_zwms_material BY matnr meinh.
          DELETE ADJACENT DUPLICATES FROM lt_zwms_material COMPARING ALL FIELDS.
          LOOP AT lt_zwms_material INTO ls_zwms_material.
            ls_tt_material-material_number = ls_zwms_material-matnr.
*            Added condition get vmsta
*            READ TABLE lt_get_vmsta INTO ls_get_vmsta WITH KEY matnr = ls_tt_material-material_number.
*            IF sy-subrc = 0.
*              IF ls_get_vmsta-vmsta = space.
*                ls_tt_material-vmsta = ls_get_vmsta-vmsta.
*              ELSE.
**                Clear barcode
*              ENDIF.
*            ENDIF.


            ls_tt_material-material_description = ls_zwms_material-maktx.
            IF ls_zwms_material-meinh = ls_zwms_material-meins.
              ls_tt_material-uom_satuan = ls_zwms_material-meins.
              CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                EXPORTING
                  input          = ls_zwms_material-meins
                IMPORTING
                  output         = ls_tt_material-uom_satuan
                EXCEPTIONS
                  unit_not_found = 1
                  OTHERS         = 2.
              IF ls_zwms_material-hpean = 'X'.
                CALL FUNCTION 'ZWMSFM005'
                  EXPORTING
                    pi_ean11 = ls_zwms_material-ean11
                  IMPORTING
                    pe_ean11 = ls_tt_material-barcode_satuan.
              ENDIF.
            ELSEIF ls_zwms_material-meinh = 'KAR'.
              ls_tt_material-uom_carton = 'KAR'.
              WRITE ls_zwms_material-umrez TO ls_tt_material-conversion_carton DECIMALS 0 NO-GROUPING NO-GAP.
              IF ls_zwms_material-hpean = 'X'.
                CALL FUNCTION 'ZWMSFM005'
                  EXPORTING
                    pi_ean11 = ls_zwms_material-ean11
                  IMPORTING
                    pe_ean11 = ls_tt_material-barcode_carton.
              ENDIF.
            ELSEIF ls_zwms_material-meinh = 'PAL'.
              ls_tt_material-uom_pallet = 'PAL'.
              WRITE ls_zwms_material-umrez TO ls_tt_material-conversion_pallet DECIMALS 0 NO-GROUPING NO-GAP.
              IF ls_zwms_material-hpean = 'X'.
                CALL FUNCTION 'ZWMSFM005'
                  EXPORTING
                    pi_ean11 = ls_zwms_material-ean11
                  IMPORTING
                    pe_ean11 = ls_tt_material-barcode_pallet.
              ENDIF.
            ELSEIF ls_zwms_material-meinh = 'ZPA'.
              "              CONTINUE.
            ELSE.
              IF ls_zwms_material-hpean = 'X'.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_zwms_material-meinh
                  IMPORTING
                    output         = ls_tt_material-uom_tengah
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                WRITE ls_zwms_material-umrez TO ls_tt_material-conversion_tengah DECIMALS 0 NO-GROUPING NO-GAP.
                CALL FUNCTION 'ZWMSFM005'
                  EXPORTING
                    pi_ean11 = ls_zwms_material-ean11
                  IMPORTING
                    pe_ean11 = ls_tt_material-barcode_tengah.
*                ls_tt_material-barcode_tengah = ls_zwms_material-ean11.
              ENDIF.
            ENDIF.
            ls_tt_material-batch_management =  ls_zwms_material-xchpf.
            ls_tt_material-warehouse = lv_warehouse.
            ls_tt_material-material_type = ls_zwms_material-mtart.
            "            WRITE ls_zwms_material-ausme TO ls_tt_material-quantity_to_remove DECIMALS 0 NO-GROUPING NO-GAP.
            ls_tt_material-plant =  ls_zwms_material-werks.


*          Added vmsta
            ls_tt_material-vmsta = ls_zwms_material-vmsta.
            IF ls_tt_material-vmsta <> space.
              ls_tt_material-barcode_satuan = space.
              ls_tt_material-barcode_carton = space.
              ls_tt_material-barcode_pallet = space.
              ls_tt_material-barcode_tengah = space.
            ENDIF.
            AT END OF matnr.
              CONDENSE: ls_tt_material-conversion_tengah, ls_tt_material-conversion_carton, ls_tt_material-conversion_pallet.
              APPEND ls_tt_material TO lt_tt_material.
              CLEAR ls_tt_material.
            ENDAT.
            CLEAR: ls_zwms_material.
          ENDLOOP.
          IF lt_tt_material[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_tt_material
              CHANGING
                cr_data = er_data.
          ENDIF.

        ENDIF.
      WHEN 'fget_batch'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'material_number'.
        IF sy-subrc = 0.
          DATA(lv_material) = wa_parameter-value.
          lv_werks = '0200'.
          lv_kar = 'KAR'.
        ENDIF.
        IF lv_material IS NOT INITIAL.
          IF sy-uname IS NOT INITIAL.
            SELECT SINGLE lgnum INTO lv_lgnum FROM lrf_wkqu
              WHERE bname = sy-uname AND statu = 'X'.
            IF sy-subrc EQ 0.
              SELECT SINGLE werks INTO lv_werks FROM t320 WHERE lgnum = lv_lgnum.
            ENDIF.
          ENDIF.

          DATA: lv_low TYPE tvarvc-low.
          DATA: lv_high TYPE tvarvc-high.
          DATA: lv_rows TYPE i.
          lv_low = lv_lgnum.
          SELECT SINGLE high INTO lv_high FROM tvarvc
            WHERE name = 'ZWSM_MASTER_SRV'
              AND low = lv_low.
          CONDENSE lv_high.
          IF lv_high IS INITIAL.
            lv_rows = 500.
          ELSE.
            lv_rows = lv_high.
          ENDIF.
*          lv_date = sy-datum - 185.
          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
            EXPORTING
              date      = sy-datum
              days      = 0
              months    = 0
              signum    = '-'
              years     = 4
            IMPORTING
              calc_date = lv_date.
          CONDENSE: lv_lgnum, lv_werks.
          IF lv_werks(2) = '02' OR lv_lgnum(1) = 'C'.
            lv_werks = '0200'.
            lv_kar = 'KAR'.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_batch
              UP TO lv_rows ROWS
              FROM zwms_batch
              WHERE material_number = lv_material
                "AND create_date > lv_date
                AND plant = '0200'
                AND meinh = 'KAR'
              ORDER BY expired_date DESCENDING.
          ELSE.
            CLEAR: lv_kar.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_batch FROM zwms_batch
              UP TO lv_rows ROWS
              WHERE material_number = lv_material
                AND create_date > lv_date
                AND plant = lv_werks
              ORDER BY expired_date DESCENDING.
          ENDIF.
          SELECT SINGLE mtart meins INTO (lv_mtart, lv_kar) FROM mara WHERE matnr = lv_material.
          SORT lt_zwms_batch BY material_number plant expired_date batch.
          DELETE ADJACENT DUPLICATES FROM lt_zwms_batch COMPARING ALL FIELDS.
          IF lt_zwms_batch[] IS NOT INITIAL.
            LOOP AT lt_zwms_batch INTO ls_zwms_batch.
              MOVE-CORRESPONDING ls_zwms_batch TO ls_batch.
              WRITE ls_zwms_batch-umrez TO ls_batch-conversion_carton DECIMALS 0 NO-GROUPING NO-GAP.
              CONDENSE ls_batch-conversion_carton.
              CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                EXPORTING
                  input          = lv_kar
                IMPORTING
                  output         = ls_batch-uom
                EXCEPTIONS
                  unit_not_found = 1
                  OTHERS         = 2.
              ls_batch-uom_packing = 'KAR'.
              IF lv_werks NE '0200' AND ( lv_mtart EQ 'ZPM' OR lv_mtart EQ 'ZRM' ) .
                TRY.
                    CALL FUNCTION 'ZWMFM009'
                      EXPORTING
                        pi_lgnum = lv_lgnum
                        pi_matnr = ls_zwms_batch-material_number
                        pi_charg = ls_zwms_batch-batch
                        pi_mtart = lv_mtart
                      IMPORTING
                        pe_uom   = ls_zwms_batch-meinh
                        pe_value = lv_charvalue.
                  CATCH cx_root INTO DATA(lo_root_exception).
                ENDTRY.
                IF ls_zwms_batch-meinh IS INITIAL OR lv_charvalue IS INITIAL.
                  ls_zwms_batch-meinh = lv_kar.
                  lv_charvalue = '1'.
                ENDIF.
                ls_batch-conversion_carton = lv_charvalue.
                CONDENSE ls_batch-conversion_carton.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_zwms_batch-meinh
                  IMPORTING
                    output         = ls_batch-uom_packing
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
              ENDIF.
              APPEND ls_batch TO lt_batch.
              CLEAR ls_batch.
            ENDLOOP.
          ENDIF.
          IF lt_batch[] IS NOT INITIAL.
            DELETE ADJACENT DUPLICATES FROM lt_batch COMPARING ALL FIELDS.
            SORT lt_batch BY expired_date DESCENDING.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_batch
              CHANGING
                cr_data = er_data.
          ENDIF.
        ENDIF.

      WHEN 'fget_uom'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'material_number'.
        IF sy-subrc = 0.
          lv_material = wa_parameter-value.
        ENDIF.
        IF lv_material IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_uom FROM zwms_uom
            WHERE material_number = lv_material.
          LOOP AT lt_uom INTO ls_uom.
            IF ls_uom-barcode(1) EQ 'J'.
              ls_uom-barcode(1) = ''.
            ENDIF.
            FIND '_' IN ls_uom-barcode.
            IF sy-subrc EQ 0.
              SPLIT ls_uom-barcode AT '_' INTO ls_barcode1 ls_barcode2.
              ls_uom-barcode = ls_barcode1.
            ENDIF.
            CONDENSE ls_uom-barcode.
            MODIFY lt_uom  FROM ls_uom TRANSPORTING barcode.
          ENDLOOP.
          IF lt_uom[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_uom
              CHANGING
                cr_data = er_data.
          ENDIF.
        ENDIF.

      WHEN 'fget_uom1'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'material_number'.
        IF sy-subrc = 0.
          lv_material = wa_parameter-value.
        ENDIF.
        IF lv_material IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_marm FROM marm
            WHERE matnr = lv_material.
          LOOP AT lt_marm INTO ls_marm.
            ls_uom1-uom_conversi  = ls_marm-umrez.
            CONDENSE ls_uom1-uom_conversi NO-GAPS.
            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
              EXPORTING
                input          = ls_marm-meinh
              IMPORTING
                output         = ls_uom1-unit_measure
              EXCEPTIONS
                unit_not_found = 1
                OTHERS         = 2.
            IF sy-subrc = 0.
              APPEND ls_uom1 TO lt_uom1.
            ENDIF.
            CLEAR ls_uom1.
          ENDLOOP.
          IF lt_uom1[] IS NOT INITIAL.
            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_uom1
              CHANGING
                cr_data = er_data.
          ENDIF.
        ENDIF.

      WHEN 'fget_stockbin'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'warehouse'.
        IF sy-subrc = 0.
          lv_warehouse = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'storage_bin'.
        IF sy-subrc = 0.
          DATA(lv_storage_bin) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'plant'.
        IF sy-subrc = 0.
          DATA(lv_plant) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'storage_type'.
        IF sy-subrc = 0.
          DATA(lv_storage_type) = wa_parameter-value.
        ENDIF.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_stock "stock
          FROM zwms_stock "lqua AS a JOIN makt AS b ON a~matnr = b~matnr
          WHERE warehouse = lv_warehouse
            AND plant = lv_plant
            AND storage_type = lv_storage_type
            AND storage_bin = lv_storage_bin
            AND language = sy-langu.
        IF sy-subrc NE 0.
          SELECT lgnum lqnum a~matnr werks charg lgtyp lgpla ausme a~meins
                  gesme bestq wdatu vfdat mtart maktx
            INTO CORRESPONDING FIELDS OF TABLE lt_stock_lqua
            FROM lqua AS a JOIN mara AS b ON a~matnr = b~matnr
                           JOIN makt AS c ON a~matnr = c~matnr
                                         AND c~spras = 'E'
            WHERE lgtyp = lv_storage_type
              AND lgpla = lv_storage_bin
              AND lgnum = lv_warehouse
              AND werks = lv_plant.
          IF sy-subrc EQ 0.
            LOOP AT lt_stock_lqua INTO ls_stock_lqua.
              IF ls_stock_lqua-mtart = 'ZRM' OR ls_stock_lqua-mtart = 'ZPM'.
                ls_stock-warehouse = ls_stock_lqua-lgnum.
                ls_stock-plant = ls_stock_lqua-werks.
                ls_stock-storage_type = ls_stock_lqua-lgtyp.
                ls_stock-storage_bin = ls_stock_lqua-lgpla.
                ls_stock-material_number = ls_stock_lqua-matnr.
                WRITE ls_stock_lqua-ausme TO ls_stock-quantity_to_remove DECIMALS 0 NO-GAP NO-GROUPING..
                ls_stock-material_description = ls_stock_lqua-maktx.
                ls_stock-batch = ls_stock_lqua-charg.
                ls_stock-uom = ls_stock_lqua-meins.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_stock-uom
                  IMPORTING
                    output         = ls_stock-uom
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                WRITE ls_stock_lqua-gesme TO ls_stock-quantity DECIMALS 0 NO-GAP NO-GROUPING..
                CONDENSE ls_stock-quantity.
                ls_stock-stock_category = ls_stock_lqua-bestq.
                "                ls_stock-special_stock = ls_stock_lqua-bestq.

                CALL FUNCTION 'ZWMFM009'
                  EXPORTING
                    pi_lgnum = ls_stock_lqua-lgnum
                    pi_matnr = ls_stock_lqua-matnr
                    pi_charg = ls_stock_lqua-charg
                    pi_mtart = ls_stock_lqua-mtart
                  IMPORTING
                    pe_uom   = lv_pe_uom
                    pe_value = lv_pe_value.
                ls_zwms_stock-uom = lv_pe_uom.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_zwms_stock-uom
                  IMPORTING
                    output         = ls_zwms_stock-uom
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                ls_stock-uom_packing = ls_zwms_stock-uom.
                CONDENSE lv_pe_value.
                ls_stock-conversion_carton = lv_pe_value.
                IF ls_stock-conversion_carton IS INITIAL.
                  ls_stock-conversion_carton = 1.
                  ls_stock-uom_packing = ls_stock-uom.
                ENDIF.
                ls_stock-shelf_life_expiration = ls_stock_lqua-vfdat.
                ls_stock-gr_date = ls_stock_lqua-wdatu.
                IF ls_stock IS NOT INITIAL.
                  CONDENSE: ls_stock-quantity, ls_stock-conversion_carton, ls_stock-quantity_to_remove.
                  APPEND ls_stock TO lt_stock.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
        LOOP AT lt_zwms_stock INTO ls_zwms_stock.
          MOVE-CORRESPONDING ls_zwms_stock TO ls_stock.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_zwms_stock-uom
            IMPORTING
              output         = ls_stock-uom
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          WRITE ls_zwms_stock-quantity TO ls_stock-quantity DECIMALS 0 NO-GAP NO-GROUPING.
          WRITE ls_zwms_stock-conversion_carton TO ls_stock-conversion_carton
              DECIMALS 0 NO-GROUPING NO-GAP.
          WRITE ls_zwms_stock-quantity_to_remove TO ls_stock-quantity_to_remove DECIMALS 0 NO-GAP NO-GROUPING.
          CONDENSE: ls_stock-quantity, ls_stock-conversion_carton, ls_stock-quantity_to_remove.
          ls_stock-uom_packing = 'CAR'.
          APPEND ls_stock TO lt_stock.
        ENDLOOP.
        IF lt_stock[] IS NOT INITIAL.
          SORT lt_stock BY shelf_life_expiration material_number batch.
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_stock
            CHANGING
              cr_data = er_data.
        ENDIF.

      WHEN 'fget_stockmaterial'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'warehouse'.
        IF sy-subrc = 0.
          lv_warehouse = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'material_number'.
        IF sy-subrc = 0.
          lv_material = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'plant'.
        IF sy-subrc = 0.
          lv_plant = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'storage_type'.
        IF sy-subrc = 0.
          lv_storage_type = wa_parameter-value.
        ENDIF.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zwms_stock "lt_stock
          FROM zwms_stock
          WHERE warehouse = lv_warehouse
            AND plant = lv_plant
            AND storage_type = lv_storage_type
            AND material_number = lv_material
            AND language = sy-langu.
        IF sy-subrc NE 0.
          SELECT lgnum lqnum a~matnr werks charg lgtyp lgpla ausme a~meins
                  gesme bestq mtart maktx
            INTO CORRESPONDING FIELDS OF TABLE lt_stock_lqua
            FROM lqua AS a JOIN mara AS b ON a~matnr = b~matnr
                           JOIN makt AS c ON a~matnr = c~matnr
                                         AND c~spras = 'E'
            WHERE a~matnr = lv_material
              AND lgnum = lv_warehouse
              AND werks = lv_plant.
          IF sy-subrc EQ 0.
            LOOP AT lt_stock_lqua INTO ls_stock_lqua.
              IF ls_stock_lqua-mtart = 'ZRM' OR ls_stock_lqua-mtart = 'ZPM'.
                ls_stock-warehouse = ls_stock_lqua-lgnum.
                ls_stock-plant = ls_stock_lqua-werks.
                ls_stock-storage_type = ls_stock_lqua-lgtyp.
                ls_stock-storage_bin = ls_stock_lqua-lgpla.
                ls_stock-material_number = ls_stock_lqua-matnr.
                WRITE ls_stock_lqua-ausme TO ls_stock-quantity_to_remove DECIMALS 0 NO-GAP NO-GROUPING..
                ls_stock-material_description = ls_stock_lqua-maktx.
                ls_stock-batch = ls_stock_lqua-charg.
                ls_stock-uom = ls_stock_lqua-meins.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_stock-uom
                  IMPORTING
                    output         = ls_stock-uom
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                WRITE ls_stock_lqua-gesme TO ls_stock-quantity DECIMALS 0 NO-GAP NO-GROUPING..
                "                ls_stock-special_stock = ls_stock_lqua-bestq.
                ls_stock-stock_category = ls_stock_lqua-bestq.

                CALL FUNCTION 'ZWMFM009'
                  EXPORTING
                    pi_lgnum = ls_stock_lqua-lgnum
                    pi_matnr = ls_stock_lqua-matnr
                    pi_charg = ls_stock_lqua-charg
                    pi_mtart = ls_stock_lqua-mtart
                  IMPORTING
                    pe_uom   = lv_pe_uom
                    pe_value = lv_pe_value.
                ls_zwms_stock-uom = lv_pe_uom.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = ls_zwms_stock-uom
                  IMPORTING
                    output         = ls_zwms_stock-uom
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                ls_stock-uom_packing = ls_zwms_stock-uom.
                CONDENSE lv_pe_value.
                ls_stock-conversion_carton = lv_pe_value.
                IF ls_stock-conversion_carton IS INITIAL.
                  ls_stock-conversion_carton = 1.
                  ls_stock-uom_packing = ls_stock-uom.
                ENDIF.
                IF ls_stock IS NOT INITIAL.
                  CONDENSE: ls_stock-quantity, ls_stock-conversion_carton, ls_stock-quantity_to_remove.
                  APPEND ls_stock TO lt_stock.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
        LOOP AT lt_zwms_stock INTO ls_zwms_stock. "lt_stock INTO ls_stock.
          MOVE-CORRESPONDING ls_zwms_stock TO ls_stock.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_stock-uom
            IMPORTING
              output         = ls_stock-uom
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          WRITE ls_zwms_stock-quantity TO ls_stock-quantity DECIMALS 0 NO-GAP NO-GROUPING.
          WRITE ls_zwms_stock-conversion_carton TO ls_stock-conversion_carton
              DECIMALS 0 NO-GROUPING NO-GAP.
          WRITE ls_zwms_stock-quantity_to_remove TO ls_stock-quantity_to_remove DECIMALS 0 NO-GAP NO-GROUPING.
          CONDENSE: ls_stock-quantity, ls_stock-conversion_carton, ls_stock-quantity_to_remove.
          ls_stock-uom_packing = 'CAR'.
          APPEND ls_stock TO lt_stock.
        ENDLOOP.
        IF lt_stock[] IS NOT INITIAL.
          SORT lt_stock BY shelf_life_expiration material_number batch.
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_stock
            CHANGING
              cr_data = er_data.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
