CLASS zfidt010_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_belnr    TYPE RANGE OF belnr_d,
           tt_gjahr    TYPE RANGE OF gjahr,
           tt_budat    TYPE RANGE OF budat,
           tt_zfidt020 TYPE TABLE OF zfidt020 WITH EMPTY KEY,
           tt_bsak     TYPE TABLE OF bsak WITH EMPTY KEY.

    TYPES: BEGIN OF ty_json,
             company_code     TYPE zfidt020-bukrs,
             business_area    TYPE zfidt020-gsber,
             document_invoice TYPE zfidt020-belnr,
             year             TYPE zfidt020-gjahr,
             assignment       TYPE zfidt020-zuonr,
             posting_date     TYPE zfidt020-budat,
             doc_reverse      TYPE zfidt020-belnr_rev,
             voucher_pay      TYPE zfidt020-voucher_pay,
             doc_payment      TYPE zfidt020-belnr_pay,
             doc_pay_reverse  TYPE zfidt020-belnr_rev_pay,
           END OF ty_json.
    TYPES: tt_json TYPE TABLE OF ty_json WITH EMPTY KEY.
    TYPES: BEGIN OF ty_deep_json,
             status_invoice TYPE tt_json,
           END OF ty_deep_json.
    METHODS: run
      IMPORTING p_bukrs    TYPE bukrs
                s_belnr    TYPE tt_belnr
                s_gjahr    TYPE tt_gjahr
                s_budat    TYPE tt_budat
      EXPORTING lv_message TYPE char255
                lv_status  TYPE char1.
protected SECTION.
PRIVATE SECTION.
  CLASS-METHODS: get_zfidt020
    IMPORTING p_bukrs            TYPE bukrs
              s_belnr            TYPE tt_belnr
              s_gjahr            TYPE tt_gjahr
              s_budat            TYPE tt_budat
    RETURNING VALUE(lt_zfidt020) TYPE tt_zfidt020.

  CLASS-METHODS: get_first_bsak
    IMPORTING lt_zfidt020     TYPE tt_zfidt020
    RETURNING VALUE(lt_bsak1) TYPE tt_bsak.

  CLASS-METHODS: get_second_bsak
    IMPORTING lt_zfidt020     TYPE tt_zfidt020
    RETURNING VALUE(lt_bsak2) TYPE tt_bsak.

  CLASS-METHODS: get_third_bsak
    IMPORTING lt_bsak2    TYPE tt_bsak
    RETURNING VALUE(lt_bsak3) TYPE tt_bsak.

  METHODS: first_update
    IMPORTING lt_bsak1          TYPE tt_bsak
    RETURNING VALUE(lv_message) TYPE char255.

  METHODS: second_update
    IMPORTING lt_bsak2          TYPE tt_bsak
              lt_datapay        TYPE tt_bsak
    RETURNING VALUE(lv_message) TYPE char255.

  METHODS: third_update
    IMPORTING lt_bsak2          TYPE tt_bsak
              lt_datarev        TYPE tt_bsak
    RETURNING VALUE(lv_message) TYPE char255.
  METHODS: send_json
    IMPORTING lt_deep_json TYPE ty_deep_json
    EXPORTING lv_message   TYPE char255
              lv_status    TYPE char1.
ENDCLASS.



CLASS ZFIDT010_CLASS IMPLEMENTATION.


    METHOD first_update.
        LOOP AT lt_bsak1 INTO DATA(ls_bsak1).
            IF ls_bsak1-belnr NE ls_bsak1-augbl.
            TRY.
                UPDATE zfidt020 SET aedat = @sy-datum, aezet = @sy-uzeit, aenam = @sy-uname,
                belnr_rev_pay = @ls_bsak1-augbl, belnr_pay = @space, voucher_pay = @space, gjahr_rev_pay = @ls_bsak1-augdt(4),
                gjahr_pay = @space WHERE bukrs = @ls_bsak1-bukrs AND belnr_pay = @ls_bsak1-belnr AND
                gjahr_pay = @ls_bsak1-gjahr.
                COMMIT WORK AND WAIT.
            CATCH cx_sy_open_sql_db INTO DATA(error).
                lv_message = error->get_text( ).
                EXIT.
            ENDTRY.
            ENDIF.
        ENDLOOP.
    ENDMETHOD.


    METHOD get_first_bsak.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsak1
        FROM bsak
        FOR ALL ENTRIES IN lt_zfidt020
        WHERE bukrs = lt_zfidt020-bukrs
        AND belnr = lt_zfidt020-belnr_pay
        AND gjahr = lt_zfidt020-gjahr.
    ENDMETHOD.


    METHOD get_second_bsak.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsak2
        FROM bsak
        FOR ALL ENTRIES IN lt_zfidt020
        WHERE bukrs = lt_zfidt020-bukrs
        AND lifnr = lt_zfidt020-lifnr
        AND zuonr = lt_zfidt020-zuonr
        AND belnr = lt_zfidt020-belnr
        AND gjahr = lt_zfidt020-gjahr.
    ENDMETHOD.


    METHOD get_third_bsak.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bsak3
        FROM bsak
        FOR ALL ENTRIES IN lt_bsak2
        WHERE bukrs = lt_bsak2-bukrs
        AND belnr = lt_bsak2-augbl
        AND gjahr = lt_bsak2-gjahr. "#EC CI_NO_TRANSFORM
    ENDMETHOD.


    METHOD get_zfidt020.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zfidt020
        FROM zfidt020
        WHERE bukrs = p_bukrs
        AND belnr IN s_belnr
        AND gjahr IN s_gjahr
        AND budat IN s_budat.
    ENDMETHOD.


    METHOD run.
      DATA: lt_belnr_pay       TYPE tt_zfidt020,
            lt_belnr_pay_empty TYPE tt_zfidt020,
            lt_belnr_rev_empty TYPE tt_zfidt020.
      DATA: lt_get_datapay TYPE tt_bsak,
            lt_get_datarev TYPE tt_bsak.

*      First bsak and update
      DATA(lt_zfidt020) = get_zfidt020( p_bukrs = p_bukrs s_belnr = s_belnr s_gjahr = s_gjahr s_budat = s_budat ).
      IF lt_zfidt020[] IS NOT INITIAL.
        lt_belnr_pay = CORRESPONDING tt_zfidt020( lt_zfidt020[] ).
      ENDIF.
      DELETE lt_belnr_pay WHERE belnr_pay = space.
      IF lt_belnr_pay[] IS NOT INITIAL.
        DATA(lt_bsak1) = get_first_bsak( lt_zfidt020 = lt_belnr_pay ).
      ENDIF.
      IF lt_bsak1[] IS NOT INITIAL.
        lv_message = me->first_update( lt_bsak1 = lt_bsak1 ).
        IF lv_message IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.

*      Second bsak
      CLEAR: lt_zfidt020, lt_get_datapay, lt_get_datarev, lt_belnr_rev_empty.
      lt_zfidt020 = get_zfidt020( p_bukrs = p_bukrs s_belnr = s_belnr s_gjahr = s_gjahr s_budat = s_budat ).
      IF lt_zfidt020[] IS NOT INITIAL.
*        lt_belnr_pay_empty = CORRESPONDING tt_zfidt020( lt_zfidt020[] ).
        lt_belnr_rev_empty = CORRESPONDING tt_zfidt020( lt_zfidt020[] ).
      ENDIF.
*      DELETE lt_belnr_pay_empty WHERE belnr_pay NE space.
      DELETE lt_belnr_rev_empty WHERE belnr_pay NE space OR belnr_rev NE space.
      IF lt_belnr_rev_empty[] IS NOT INITIAL.
        DATA(lt_bsak2) = get_second_bsak( lt_zfidt020 = lt_belnr_rev_empty ).
      ENDIF.
      IF lt_bsak2[] IS NOT INITIAL.
        DATA(lt_bsak3) = get_third_bsak( lt_bsak2 = lt_bsak2 ).
      ENDIF.

      IF lt_bsak3[] IS NOT INITIAL.
        lt_get_datapay = CORRESPONDING tt_bsak( lt_bsak3 ). "lt_get_datarev =
      ENDIF.
      DELETE lt_get_datapay WHERE blart NE 'KZ'.
*      DELETE lt_get_datarev WHERE blart NE 'KR'.
*      Second update
      IF lt_bsak2[] IS NOT INITIAL AND lt_get_datapay[] IS NOT INITIAL.
        lv_message = me->second_update( lt_bsak2 = lt_bsak2 lt_datapay = lt_get_datapay ).
        IF lv_message IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.

*      Third bsak
      CLEAR: lt_zfidt020, lt_bsak2, lt_bsak3, lt_get_datapay, lt_get_datarev, lt_belnr_pay_empty.
      lt_zfidt020 = me->get_zfidt020( p_bukrs = p_bukrs s_belnr = s_belnr s_gjahr = s_gjahr s_budat = s_budat ).
      IF lt_zfidt020[] IS NOT INITIAL.
        lt_belnr_pay_empty = CORRESPONDING tt_zfidt020( lt_zfidt020[] ).
*        lt_belnr_rev_empty = CORRESPONDING tt_zfidt020( lt_zfidt020[] ).
      ENDIF.
      DELETE lt_belnr_pay_empty WHERE belnr_pay NE space.
*      DELETE lt_belnr_rev_empty WHERE belnr_pay NE space OR belnr_rev NE space.
      IF lt_belnr_pay_empty[] IS NOT INITIAL.
        lt_bsak2 = get_second_bsak( lt_zfidt020 = lt_belnr_pay_empty ).
      ENDIF.
      IF lt_bsak2[] IS NOT INITIAL.
        lt_bsak3 = get_third_bsak( lt_bsak2 = lt_bsak2 ).
      ENDIF.

      IF lt_bsak3[] IS NOT INITIAL.
        lt_get_datarev = CORRESPONDING tt_bsak( lt_bsak3 ). "lt_get_datapay =
      ENDIF.
*      DELETE lt_get_datapay WHERE blart NE 'KZ'.
      DELETE lt_get_datarev WHERE blart NE 'KR'.

*      Third update
      IF lt_bsak2[] IS NOT INITIAL AND lt_get_datarev[] IS NOT INITIAL.
        lv_message = me->third_update( lt_bsak2 = lt_bsak2 lt_datarev = lt_get_datarev ).
        IF lv_message IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.

      CLEAR: lt_zfidt020.
      lt_zfidt020 = get_zfidt020( p_bukrs = p_bukrs s_belnr = s_belnr s_gjahr = s_gjahr s_budat = s_budat ).
*      DATA(lt_json) = CORRESPONDING tt_json( lt_zfidt020 MAPPING company_code = bukrs
*                                                          business_area = gsber
*                                                          document_invoice = belnr
*                                                          year = gjahr
*                                                          assignment = zuonr
*                                                          posting_date = budat
*                                                          doc_reverse = belnr_rev
*                                                          doc_payment = belnr_pay
*                                                          doc_pay_reverse = belnr_rev_pay ).
      DATA(lt_process) = VALUE tt_zfidt020( FOR wa IN lt_zfidt020 WHERE ( sent NE 'X' AND belnr_pay NE space ) ( wa ) ).
      DATA(lt_json) = CORRESPONDING tt_json( lt_process MAPPING company_code = bukrs
                                                          business_area = gsber
                                                          document_invoice = belnr
                                                          year = gjahr
                                                          assignment = zuonr
                                                          posting_date = budat
                                                          doc_reverse = belnr_rev
                                                          voucher_pay = voucher_pay
                                                          doc_payment = belnr_pay
                                                          doc_pay_reverse = belnr_rev_pay ).
      DATA: lt_deep_json TYPE ty_deep_json.
      lt_deep_json-status_invoice = CORRESPONDING tt_json( lt_json ).
      me->send_json( EXPORTING lt_deep_json = lt_deep_json IMPORTING lv_message = lv_message lv_status = lv_status ).
    ENDMETHOD.


    METHOD second_update.
        LOOP AT lt_bsak2 INTO DATA(ls_bsak2).
            READ TABLE lt_datapay INTO DATA(ls_datapay) WITH KEY bukrs = ls_bsak2-bukrs belnr = ls_bsak2-augbl gjahr = ls_bsak2-gjahr.
            IF sy-subrc = 0.
                TRY.
                UPDATE zfidt020 SET aedat = @sy-datum, aezet = @sy-uzeit, aenam = @sy-uname,
                belnr_pay = @ls_bsak2-augbl, voucher_pay = @ls_bsak2-zuonr, belnr_rev_pay = @space, gjahr_rev_pay = @space,
                gjahr_pay = @ls_bsak2-augdt(4) WHERE bukrs = @ls_bsak2-bukrs AND belnr = @ls_bsak2-belnr
                AND gjahr = @ls_bsak2-gjahr.
                COMMIT WORK AND WAIT.
            CATCH cx_sy_open_sql_db INTO DATA(error).
                lv_message = error->get_text( ).
                EXIT.
            ENDTRY.
            ENDIF.
        ENDLOOP.
    ENDMETHOD.


    METHOD send_json.
      DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
            gv_json      TYPE string.
      TYPES: BEGIN OF ty_message,
               success    TYPE string,
               status     TYPE string,
               statuscode TYPE string,
               message    TYPE string,
             END OF ty_message.
      DATA: gs_message TYPE ty_message.

      CREATE OBJECT cl_json_data
        EXPORTING
          data = lt_deep_json.
      cl_json_data->serialize( ).
      gv_json = cl_json_data->get_data( ).
      IF gv_json IS NOT INITIAL.
        SELECT SINGLE * INTO @DATA(ls_ztdsitdt001) FROM ztdsitdt001
          WHERE zproses = 'ZSTATUS_PAY'.
        DATA: url_post TYPE string.
        IF ls_ztdsitdt001 IS NOT INITIAL.
          IF ls_ztdsitdt001-urlpos IS NOT INITIAL.
            url_post = ls_ztdsitdt001-urlpos.
            cl_http_client=>create_by_url(
            EXPORTING
              url = url_post
            IMPORTING
              client = DATA(lo_client)
            EXCEPTIONS
              argument_not_found = 1
              plugin_not_active  = 2
              internal_error     = 3
              OTHERS             = 4 ).
          ELSE.
            lv_message = 'Missing URL'.
            EXIT.
          ENDIF.
          IF  lo_client IS BOUND.
            DATA: api_key TYPE string.
            lo_client->request->set_method( 'POST' ).
            lo_client->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
            IF ls_ztdsitdt001-phead IS NOT INITIAL.
              api_key = ls_ztdsitdt001-phead.
              lo_client->request->set_header_field( name = 'x-api-key' value = api_key ).
            ELSE.
              lv_message = 'Missing API Key'.
              EXIT.
            ENDIF.
            lo_client->request->set_cdata( data = gv_json ).

            lo_client->send(
               EXCEPTIONS
                 http_communication_failure = 1
                 http_invalid_state         = 2
                 http_processing_failed     = 3
                 OTHERS                     = 4 ).
            IF sy-subrc = 0.
              LOOP AT lt_deep_json-status_invoice INTO DATA(ls_status_invoice).
                TRY.
                    UPDATE zfidt020 SET sent = 'X' WHERE bukrs = ls_status_invoice-company_code
                    AND gsber = ls_status_invoice-business_area AND belnr = ls_status_invoice-document_invoice AND gjahr = ls_status_invoice-year
                    AND zuonr = ls_status_invoice-assignment.
                  CATCH cx_sy_sql_error.
                    lv_message = 'Database Error'.
                    EXIT.
                ENDTRY.
              ENDLOOP.
              IF sy-subrc = 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
              ENDIF.

              lo_client->receive(
                EXCEPTIONS
                  http_communication_failure = 1
                  http_invalid_state         = 2
                  http_processing_failed     = 3 ).
            ENDIF.
*
            IF sy-subrc = 0.
              DATA(lv_json_response) = lo_client->response->get_cdata( ).
              IF lv_json_response IS NOT INITIAL.
                /ui2/cl_json=>deserialize(
                 EXPORTING
                   json             = lv_json_response
                   pretty_name      = /ui2/cl_json=>pretty_mode-low_case
                 CHANGING
                   data             = gs_message ).
                lv_message = gs_message-message.
                lv_status = gs_message-status.
              ELSE.
                lv_message = 'Empty JSON'.
                EXIT.
              ENDIF.
            ENDIF.
*        lo_client->send( ).
*        lo_client->receive( ).
            lo_client->close( ).
          ENDIF.
        ELSE.
          lv_message = 'Process not found'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDMETHOD.


    METHOD third_update.
      LOOP AT lt_bsak2 INTO DATA(ls_bsak2).
        READ TABLE lt_datarev INTO DATA(ls_datarev) WITH KEY bukrs = ls_bsak2-bukrs belnr = ls_bsak2-augbl gjahr = ls_bsak2-gjahr.
        IF sy-subrc = 0.
          TRY.
              UPDATE zfidt020 SET aedat = @sy-datum, aezet = @sy-uzeit, aenam = @sy-uname,
              belnr_rev = @ls_bsak2-augbl, belnr_rev_pay = @space, gjahr_rev = @ls_bsak2-augdt(4),
              gjahr_rev_pay = @space WHERE bukrs = @ls_bsak2-bukrs AND belnr = @ls_bsak2-belnr
              AND gjahr = @ls_bsak2-gjahr.
              COMMIT WORK AND WAIT.
            CATCH cx_sy_open_sql_db INTO DATA(error).
              lv_message = error->get_text( ).
              EXIT.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDMETHOD.
ENDCLASS.
