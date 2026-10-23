class ZCL_ZTIAM_API_DPC_EXT definition
  public
  inheriting from ZCL_ZTIAM_API_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.

  methods GET_BUDGETSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZTIAM_API_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ir_deep_entity  TYPE zcl_ztiam_api_mpc_ext=>ts_create_po_tiam.

    DATA: lv_low TYPE rvari_val_255.
    DATA: lv_destination TYPE rfcdisplay-rfcdest.
    DATA : ls_po_tiam TYPE zcl_ztiam_api_mpc_ext=>ts_create_po_tiam.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string,
           lv_error     TYPE string.
    DATA: ls_log_error  TYPE zcl_ztiam_api_mpc_ext=>ts_po_error.
    DATA: lt_log_error  TYPE STANDARD TABLE OF  zcl_ztiam_api_mpc_ext=>ts_po_error.
    DATA: lv_status(1),
          lv_proses(15),
          lv_po_web(20),
          lv_no_po(20),
          lv_message    TYPE char200.

    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'po_tiamSet'.

        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ir_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lo_data_exception).
        ENDTRY.
        ir_deep_entity-proses = 'PO_TIAM'.
        CREATE OBJECT cl_json_data
          EXPORTING
            data = ir_deep_entity.
        lv_po_web = ir_deep_entity-po_web.
        lv_proses = ir_deep_entity-proses.
        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        TRY.
            CALL FUNCTION 'ZTIAM_IMM02'
              EXPORTING
                pi_proses        = lv_proses
                pi_data          = lv_json
                pi_noweb         = lv_po_web
              IMPORTING
                pe_nosap         = lv_no_po
                pe_status        = lv_status
                pe_message_error = lv_message
                pe_log_error     = lv_error.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ir_deep_entity-type   = 'E'.
          ir_deep_entity-message = 'Error Call Fucntion'.
        ELSE.
          IF lv_error IS NOT INITIAL.
            zcl_json=>deserialize(
                  EXPORTING
                    json             = lv_error
                  CHANGING
                    data             = lt_log_error ).
            IF lt_log_error[] IS NOT INITIAL.
              LOOP AT lt_log_error INTO ls_log_error.
                APPEND ls_log_error TO ir_deep_entity-error..
              ENDLOOP.
            ENDIF.
          ENDIF.
          ir_deep_entity-po_sap = lv_no_po.
          ir_deep_entity-type   = lv_status.
          ir_deep_entity-message = lv_message.
        ENDIF.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    TYPES: BEGIN OF ty_mat,
             material_code        TYPE c LENGTH 18,
             plant                TYPE c LENGTH 4,
             sloc                 TYPE c LENGTH 4,
             material_description TYPE c LENGTH 40,
             material_uom         TYPE c LENGTH 10,
             qty                  TYPE c LENGTH 20,
           END OF ty_mat.

    DATA: lt_material TYPE zcl_ztiam_api_mpc=>tt_get_material.
    DATA: lt_stock TYPE zcl_ztiam_api_mpc=>tt_get_material.
    DATA: ls_budget TYPE zcl_ztiam_api_mpc=>ts_get_budget.
    DATA: lt_budget TYPE zcl_ztiam_api_mpc=>tt_get_budget.
    DATA: lv_labst            TYPE mard-labst,
          lv_cost_center      TYPE kostl,
          lv_gl_account       TYPE kstar,
          lv_tahun            TYPE gjahr,
          lv_status(1),
          lv_message(100),
          lv_budget(20),
          lv_saldo_budget(20),
          lv_actual(20),
          lv_commitment(20).


    CASE iv_action_name.
      WHEN 'fget_material'.
        READ TABLE it_parameter INTO DATA(wa_parameter)
          WITH KEY name = 'material_code'.
        IF sy-subrc = 0.
          DATA(lv_material_code) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'plant'.
        IF sy-subrc = 0.
          DATA(lv_plant) = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'sloc'.
        IF sy-subrc = 0.
          DATA(lv_sloc) = wa_parameter-value.
        ENDIF.
        IF lv_material_code IS NOT INITIAL.
          CONCATENATE lv_material_code '%' INTO lv_material_code.
          SELECT a~matnr AS material_code,
                  werks AS plant,
                  lgort AS sloc,
                 d~mseh3 AS material_uom,
                   maktx AS material_description,
                 CAST( c~labst AS CHAR( 20 ) )  AS qty
                   "labst AS cast qty string
            INTO CORRESPONDING FIELDS OF TABLE @lt_material
            FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
                 JOIN mard AS c ON c~matnr = a~matnr
                 JOIN t006a AS d ON d~msehi = a~meins AND d~spras = @sy-langu
            WHERE a~matnr LIKE @lv_material_code
              AND b~spras = @sy-langu
              AND werks = @lv_plant
              AND lgort = @lv_sloc.
           if sy-subrc ne 0.
          SELECT a~matnr AS material_code,
                  "werks AS plant,
                  "lgort AS sloc,
                 d~mseh3 AS material_uom,
                   maktx AS material_description
"                 CAST( c~labst AS CHAR( 20 ) )  AS qty
                   "labst AS cast qty string
            INTO CORRESPONDING FIELDS OF TABLE @lt_material
            FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
    "             JOIN mard AS c ON c~matnr = a~matnr
                 JOIN t006a AS d ON d~msehi = a~meins AND d~spras = @sy-langu
            WHERE a~matnr LIKE @lv_material_code
              AND b~spras = @sy-langu.
    "          AND werks = @lv_plant
    "          AND lgort = @lv_sloc.
           endif.
        ENDIF.
        IF lt_material[] IS NOT INITIAL.
          DATA: ls_material LIKE LINE OF lt_material.
          LOOP AT lt_material INTO ls_material.
            lv_labst = ls_material-qty.
            WRITE lv_labst TO ls_material-qty DECIMALS 0 NO-GROUPING NO-GAP.
            CONDENSE ls_material-qty.
            MODIFY lt_material FROM ls_material TRANSPORTING qty.
          ENDLOOP.
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_material
            CHANGING
              cr_data = er_data.
        ENDIF.
      WHEN 'fget_budget'.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'gl_account'.
        IF sy-subrc = 0.
          lv_gl_account = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'cost_center'.
        IF sy-subrc = 0.
          lv_cost_center = wa_parameter-value.
        ENDIF.
        READ TABLE it_parameter INTO wa_parameter
          WITH KEY name = 'tahun'.
        IF sy-subrc = 0.
          lv_tahun = wa_parameter-value.
        ENDIF.
        TRY.
            CALL FUNCTION 'ZTIAM_IFI02'
              EXPORTING
                cost_center  = lv_cost_center
                gl_account   = lv_gl_account
                tahun        = lv_tahun
              IMPORTING
                status       = lv_status
                message      = lv_message
                saldo_budget = lv_saldo_budget
                budget       = lv_budget
                actual       = lv_actual
                commitment   = lv_commitment.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.

        IF lo_root_exception IS NOT INITIAL.
          ls_budget-tahun = lv_tahun.
          ls_budget-cost_center = lv_cost_center.
          ls_budget-gl_account = lv_gl_account.
          ls_budget-status = 'E'..
          ls_budget-message = 'Format data tidak sesuai'.
          CLEAR: ls_budget-saldo_budget, ls_budget-budget, ls_budget-actual, ls_budget-commitment.
          APPEND ls_budget TO lt_budget.
        ELSE.
          ls_budget-tahun = lv_tahun.
          ls_budget-cost_center = lv_cost_center.
          ls_budget-gl_account = lv_gl_account.
          ls_budget-status = lv_status.
          ls_budget-message = lv_message.
          ls_budget-saldo_budget = lv_saldo_budget.
          ls_budget-budget = lv_budget.
          ls_budget-actual = lv_actual.
          ls_budget-commitment = lv_commitment.
          APPEND ls_budget TO lt_budget.
        ENDIF.
        IF lt_budget[] IS NOT INITIAL.
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_budget
            CHANGING
              cr_data = er_data.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD get_budgetset_get_entity.
    DATA: lv_cost_center      TYPE kostl,
          lv_gl_account       TYPE kstar,
          lv_tahun            TYPE gjahr,
          lv_status(1),
          lv_message(100),
          lv_saldo_budget(20),
          lv_budget(20),
          lv_actual(20),
          lv_commitment(20).
    er_entity-cost_center = VALUE #( it_key_tab[ name = 'cost_center' ]-value OPTIONAL ). "New syntax
    er_entity-cost_center = |{ er_entity-cost_center ALPHA = IN }|.
    er_entity-gl_account = VALUE #( it_key_tab[ name = 'gl_account' ]-value OPTIONAL ). "New syntax
    er_entity-gl_account = |{ er_entity-gl_account ALPHA = IN }|.
    er_entity-tahun = VALUE #( it_key_tab[ name = 'tahun' ]-value OPTIONAL ). "New syntax
    er_entity-tahun = |{ er_entity-tahun ALPHA = IN }|.
    lv_cost_center = er_entity-cost_center.
    lv_gl_account = er_entity-gl_account.
    lv_tahun = er_entity-tahun.
    TRY.
        CALL FUNCTION 'ZTIAM_IFI02'
          EXPORTING
            cost_center  = lv_cost_center "er_entity-cost_center "
            gl_account   = lv_gl_account "er_entity-gl_account "
            tahun        = lv_tahun "er_entity-tahun "
          IMPORTING
            status       = lv_status
            message      = lv_message
            saldo_budget = lv_saldo_budget
            budget       = lv_budget
            actual       = lv_actual
            commitment   = lv_commitment.
      CATCH cx_root INTO DATA(lo_root_exception).
    ENDTRY.

    IF lo_root_exception IS NOT INITIAL.
      er_entity-status = 'E'..
      er_entity-message = 'Format data tidak sesuai'.
      CLEAR: er_entity-saldo_budget, er_entity-budget, er_entity-actual, er_entity-commitment.
    ELSE.
      er_entity-status = lv_status.
      er_entity-message = lv_message.
      er_entity-saldo_budget = lv_saldo_budget.
      er_entity-budget = lv_budget.
      er_entity-actual = lv_actual.
      er_entity-commitment = lv_commitment.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
