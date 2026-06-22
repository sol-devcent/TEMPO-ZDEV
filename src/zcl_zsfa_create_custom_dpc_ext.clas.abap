class ZCL_ZSFA_CREATE_CUSTOM_DPC_EXT definition
  public
  inheriting from ZCL_ZSFA_CREATE_CUSTOM_DPC
  create public .

public section.
protected section.

  methods CUSTOMERSET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSFA_CREATE_CUSTOM_DPC_EXT IMPLEMENTATION.


  METHOD customerset_create_entity.
    DATA: ls_zsfasddt009 TYPE zsfasddt009.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.
    DATA: lv_customer_code TYPE kna1-kunnr,
          lv_status(1), lv_proses(30), lv_search_term TYPE kna1-sortl,
          lv_name(40),
          lv_message       TYPE bapi_msg.
    DATA : lo_msg TYPE REF TO /iwbep/if_message_container.
    DATA: ls_bapi TYPE bapiret2.

    TRY.
        io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.

***    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
***      RECEIVING
***        ro_message_container = lo_msg.
***
***    IF lo_msg IS BOUND.
***      CALL METHOD lo_msg->add_message_from_bapi
***        EXPORTING
***          is_bapi_message   = ls_bapi  " Return Parameter
***          iv_message_target = 'YB_MSG'.  " Target (reference)(e.g.Property ID) of a message
***      " Raising Exception
***      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
***        EXPORTING
***          textid            = /iwbep/cx_mgw_busi_exception=>business_error
***          message_container = lo_msg.
***    ENDIF.


    CREATE OBJECT cl_json_data
      EXPORTING
        data = er_entity.

    cl_json_data->serialize( ).
    lv_json = cl_json_data->get_data( ).

    IF lv_json IS NOT INITIAL.
      lv_search_term = er_entity-search_term1.
      ls_zsfasddt009-sortl = lv_search_term.
      SELECT SINGLE kunnr name1 INTO (lv_customer_code, lv_name) FROM kna1 WHERE sortl = lv_search_term.
      IF sy-subrc EQ 0.
        CONCATENATE 'Search Term. '  lv_search_term ' sudah tercreate customer ' lv_customer_code '-' lv_name INTO lv_message.
        CLEAR: er_entity.
        ls_zsfasddt009-message = lv_message.
        er_entity-status = 'E'.
        er_entity-message = lv_message.
        er_entity-search_term1 = lv_search_term.
        er_entity-customer_code = lv_customer_code.
        ls_zsfasddt009-kunnr = lv_customer_code..
      ELSE.
        lv_proses = 'CREATE_CUSTOMER'.
        TRY.
            CALL FUNCTION 'ZSFASD_F001'
              EXPORTING
                pi_process    = lv_proses
                pi_data       = lv_json
                pi_sortl      = lv_search_term
              IMPORTING
                customer_code = lv_customer_code
                pi_type       = lv_status
                pi_message    = lv_message.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          lv_status             = 'E'.
          lv_message       = 'Data json tidak sesuai'.
        ENDIF.
        CLEAR: er_entity.
        er_entity-status = lv_status.
        ls_zsfasddt009-status = lv_status.
        er_entity-message = lv_message.
        ls_zsfasddt009-message = lv_message.
        IF lv_status = 'S'.
          COMMIT WORK.
          er_entity-search_term1 = lv_search_term.
          er_entity-customer_code = lv_customer_code.
          ls_zsfasddt009-kunnr = lv_customer_code..
        ENDIF.
      ENDIF.
      IF ls_zsfasddt009 IS NOT INITIAL.
        ls_zsfasddt009-erdate = sy-datum.
        ls_zsfasddt009-ertime = sy-uzeit.
        ls_zsfasddt009-ername = sy-uname.
        MODIFY zsfasddt009 FROM ls_zsfasddt009.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
