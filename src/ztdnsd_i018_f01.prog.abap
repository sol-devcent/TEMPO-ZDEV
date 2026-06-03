*----------------------------------------------------------------------*
***INCLUDE ZTDNSD_I012_F01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data CHANGING p_err p_str TYPE string.
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_err(1).
  DATA:  lv_str TYPE string.
  DATA: lv_text TYPE text1024.
  CLEAR: lv_err.
  IF p_demo = 'X'.
    CLEAR: lv_str, lv_text.
    OPEN DATASET p_path FOR INPUT IN TEXT MODE ENCODING UTF-8
                           IGNORING CONVERSION ERRORS.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET p_path INTO lv_text.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        CONCATENATE lv_str lv_text INTO lv_str.
        CLEAR: lv_text.
      ENDDO.
      CLOSE DATASET p_path.
      "      REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '"  "'.
      REPLACE ALL OCCURRENCES OF REGEX '#' IN lv_str WITH '"  "'.

    ENDIF.
  ELSE.
    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                         USING    p_proses
                                         CHANGING lv_str lv_err.
  ENDIF.
  IF lv_str IS INITIAL.
    p_err = 4.
  ELSE.
    p_str = lv_str.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*----------------------------------------------------------------------*
FORM f_convert_json  USING p_str TYPE string.
  DATA: lv_json_data TYPE string,
        lr_data      TYPE REF TO data.
  FIELD-SYMBOLS:
    <data>        TYPE data,
    <data0>       TYPE data,
    <results>     TYPE any,
    <structure>   TYPE any,
    <table>       TYPE ANY TABLE,
    <data1>       TYPE data,
    <results1>    TYPE any,
    <structure1>  TYPE any,
    <table1>      TYPE ANY TABLE,
    <data2>       TYPE data,
    <results2>    TYPE any,
    <structure2>  TYPE any,
    <table2>      TYPE ANY TABLE,
    <field>       TYPE any,
    <field_value> TYPE data.

  DATA: lt_payment TYPE payment.
  DATA: ls_payment TYPE t_payment.
  DATA: lt_result TYPE result." OCCURS 0 .
  DATA: ls_result TYPE t_update.
  DATA: lv_vbeln LIKE s642-vbeln.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json      TYPE string,
        lv_name(15).
  DATA: l_str TYPE string.
  DATA: lv_no_order LIKE ztdnfidt005-no_order.
  DATA: lv_ctr  TYPE i, lv_ctr1 TYPE i.
  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = lr_data ).
  IF lr_data IS BOUND.
    ASSIGN lr_data->* TO <data0>.
    ASSIGN COMPONENT 'RESULT' OF STRUCTURE <data0> TO <results>.
    IF <results> IS ASSIGNED.
      ASSIGN <results>->* TO <table>.
      LOOP AT <table> ASSIGNING <structure>.
        ASSIGN <structure>->* TO <data>.

        ASSIGN COMPONENT 'NO_DN' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          IF <field_value> IS ASSIGNED.
            ls_payment-no_dn = <field_value>.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
        ASSIGN COMPONENT 'NO_ORDER' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          IF <field_value> IS ASSIGNED.
            ls_payment-no_order = <field_value>.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
        ASSIGN COMPONENT 'PAYMENT_STATUS' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          IF <field_value> IS ASSIGNED.
            ls_payment-payment_status = <field_value>.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.

**           bayar_via type string,
        ASSIGN COMPONENT 'BAYAR_VIA' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          IF <field_value> IS ASSIGNED.
            ls_payment-bayar_via = <field_value>.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
**           bayar_tgl type string,
        ASSIGN COMPONENT 'BAYAR_TGL' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          IF <field_value> IS ASSIGNED.
            ls_payment-bayar_tgl = <field_value>.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
        APPEND ls_payment TO lt_payment-payment.
        CLEAR: ls_payment.
      ENDLOOP.
    ENDIF.
  ENDIF.
  DATA: gs_ztdnfidt005 TYPE ztdnfidt005.
  DATA: gt_ztdnfidt005 TYPE STANDARD TABLE OF ztdnfidt005 WITH HEADER LINE.
  DATA: lt_s642 TYPE STANDARD TABLE OF s642 WITH HEADER LINE.
  RANGES lr_vbeln FOR s642-vbeln.
  LOOP AT lt_payment-payment INTO ls_payment.
    lr_vbeln-sign = 'I'.
    lr_vbeln-option = 'EQ'.
    lr_vbeln-low = ls_payment-no_dn.
    APPEND lr_vbeln.
  ENDLOOP.
  IF lr_vbeln[] IS NOT INITIAL.
*{   REPLACE        P01K910108                                        2
*\    SELECT * INTO TABLE lt_s642 FROM s642 WHERE vbeln IN lr_vbeln.
    "Start SOH: Shell SCI Adjustment 20240220 KS
    SELECT * INTO TABLE lt_s642 FROM s642 WHERE vbeln IN lr_vbeln ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240220 KS
*}   REPLACE
  ENDIF.
  CLEAR: lv_ctr, lv_ctr1.
  LOOP AT lt_payment-payment INTO ls_payment.
    ADD 1 TO lv_ctr.
    WRITE: / ls_payment-no_dn, sy-vline, ls_payment-no_order, sy-vline, ls_payment-payment_status.
    lv_vbeln = ls_payment-no_dn.
    ls_result-no_dn = ls_payment-no_dn.
    ls_result-no_order = ls_payment-no_order.
    UPDATE s642 SET  paymt = 'X' WHERE vbeln = lv_vbeln.
    IF sy-subrc EQ 0.
      WRITE: sy-vline, 'Update berhasil'.
      ls_result-status_update = 'S'.
      ADD 1 TO lv_ctr1.
    ELSE.
      WRITE: sy-vline, 'Update Gagal'.
      ls_result-status_update = 'E'.
    ENDIF.
    "    CONDENSE: wa_order-no_order, wa_order-bayar_via.
    IF ls_result-status_update = 'S'.
      CLEAR: gs_ztdnfidt005, lv_no_order.
      lv_no_order = ls_result-no_order..
      SELECT SINGLE * INTO gs_ztdnfidt005 FROM ztdnfidt005 WHERE no_order = lv_no_order.
      IF sy-subrc EQ 0 AND gs_ztdnfidt005-belnr1 IS INITIAL.
        gs_ztdnfidt005-bayar_via = ls_payment-bayar_via.
        gs_ztdnfidt005-pay_date = ls_payment-bayar_tgl.
        MODIFY ztdnfidt005 FROM gs_ztdnfidt005.
      ELSE.
*{   REPLACE        P01K910108                                        1
*\        READ TABLE lt_s642 WITH KEY vbeln = lv_vbeln BINARY SEARCH.
        "Start SOH: Shell SCI Adjustment 20240220 KS
        SORT lt_s642 BY vbeln.
        READ TABLE lt_s642 WITH KEY vbeln = lv_vbeln BINARY SEARCH.
        "End SOH: Shell SCI Adjustment 20240220 KS
*}   REPLACE
        IF sy-subrc EQ 0.
          lv_no_order = lt_s642-lifex.
          SELECT SINGLE * INTO gs_ztdnfidt005 FROM ztdnfidt005 WHERE no_order = lv_no_order.
          IF sy-subrc EQ 0 AND gs_ztdnfidt005-belnr1 IS INITIAL.
            gs_ztdnfidt005-bayar_via = ls_payment-bayar_via.
            gs_ztdnfidt005-pay_date = ls_payment-bayar_tgl.
            MODIFY ztdnfidt005 FROM gs_ztdnfidt005.
          ELSE.
            lv_no_order = ls_result-no_order..
            CONCATENATE lv_no_order 'COD' INTO lv_no_order.
            SELECT SINGLE * INTO gs_ztdnfidt005 FROM ztdnfidt005 WHERE no_order = lv_no_order.
            IF sy-subrc EQ 0 AND gs_ztdnfidt005-belnr1 IS INITIAL.
              gs_ztdnfidt005-bayar_via = ls_payment-bayar_via.
              gs_ztdnfidt005-pay_date = ls_payment-bayar_tgl.
              MODIFY ztdnfidt005 FROM gs_ztdnfidt005.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    APPEND ls_result TO lt_result-result.
  ENDLOOP.
  WRITE: / 'Jumlah Record yg diproses : ', lv_ctr.
  WRITE: / 'Jumlah Record yg berhasil diupdate : ', lv_ctr1.
  IF lt_result-result[] IS NOT INITIAL.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_result.
    cl_json_data->serialize( ).
    lv_json = cl_json_data->get_data( ).
    lv_name = sy-datum.
    PERFORM f_post_data_json(ztdsit_i001) USING lv_json 'TDN_PAYMENT' sy-subrc l_str.
    PERFORM f_create_text_json(ztdsit_i001) USING lv_json lv_name '/inbound/TDN/' 'TDN_PAYMENT'.
  ENDIF.
ENDFORM.                    " F_CONVERT_JSON
