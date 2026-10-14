class ZCL_ZTNF_API_DPC_EXT definition
  public
  inheriting from ZCL_ZTNF_API_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTNF_API_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: deep_entity TYPE zcl_ztnf_api_mpc_ext=>ty_pr.
    DATA: lv_json          TYPE string.

    CASE iv_entity_set_name.
      WHEN 'prSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.
      WHEN OTHERS.
    ENDCASE.

    /ui2/cl_json=>serialize(
        EXPORTING
          data = deep_entity
        RECEIVING
          r_json = lv_json   ).

    "  proses create pr
    DATA: lv_pr         TYPE banfn,
          lv_pr_tnf(35),
          lv_date       TYPE sy-datum,
          lv_type(1),
          lv_message    TYPE bapi_msg.
    lv_pr_tnf = deep_entity-data-pr_doc_no.

    TRY.
        CALL FUNCTION 'ZTNFMM_F001'
          EXPORTING
            pi_proses    = 'CREATE_PRTNF'
            pi_data      = lv_json
            pi_document  = lv_pr_tnf
          IMPORTING
            pe_pr_number = lv_pr "lv_po_num "
            pe_pr_date   = lv_date
            pe_type      = lv_type
            pe_message   = lv_message.
      CATCH cx_root INTO DATA(lo_root_exception).

    ENDTRY.

    IF lo_root_exception IS NOT INITIAL.
      lv_type             = 'E'.
      lv_message          = 'Data json tidak sesuai'.
    ENDIF.

    deep_entity-data-type             = lv_type.
    deep_entity-data-message          = lv_message..
    deep_entity-data-pr_sap_no = lv_pr.

    TRY.
        CALL METHOD me->copy_data_to_ref
          EXPORTING
            is_data = deep_entity
          CHANGING
            cr_data = er_deep_entity.
      CATCH cx_root.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
