FUNCTION ztdnsd_f0010.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VBELN) TYPE  VBELN
*"  EXPORTING
*"     REFERENCE(STATUS) TYPE  CHAR1
*"     REFERENCE(MESSAGE) TYPE  CHAR100
*"     REFERENCE(JSON_OUT) TYPE  STRING
*"----------------------------------------------------------------------
  TYPES: BEGIN OF ty_lips,
           vbeln TYPE lips-vbeln,
           matnr TYPE lips-matnr,
           vrkme TYPE lips-vrkme,
           lfimg TYPE lips-lfimg,
         END OF ty_lips.
  TYPES: BEGIN OF ty_detail,
           material TYPE string, ": "001-00-03",   9 char
           qty      TYPE string, ": "3306",            10 char
           uom      TYPE string, ": "FBX",              5 char
         END OF ty_detail,
         BEGIN OF ty_header,
           delivery_no   TYPE string, ": "1234567890",  10 char
           delivery_date TYPE string, ": "yyyymmdd",   8 char
           store_id      TYPE string, ": "TSB8380152",      10 char
           items         TYPE STANDARD TABLE OF ty_detail WITH DEFAULT KEY,
         END OF ty_header.
  TYPES: BEGIN OF ty_likp,
           vbeln    TYPE likp-vbeln,
           erdat    TYPE likp-erdat,
           store_id TYPE ztdnmmdt010-store_id,
         END OF ty_likp.
  DATA: ls_detail TYPE ty_detail.
  DATA: ls_result TYPE ty_header.
  DATA: ls_likp TYPE ty_likp.
  DATA: lt_lips TYPE STANDARD TABLE OF ty_lips.
  DATA: ls_lips LIKE LINE OF lt_lips.
  "  DATA: ls_ztdnsddt024 TYPE ztdnsddt024.
  DATA: lv_qty(10).
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: lv_json TYPE string.
  DATA: lv_uom(5).
  DATA: lv_name(15).

  SELECT SINGLE a~vbeln a~erdat store_id INTO CORRESPONDING FIELDS OF ls_likp
    FROM likp AS a JOIN ztdnmmdt010 AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln = vbeln
      AND status = space.
  IF sy-subrc EQ 0.
    SELECT vbeln matnr vrkme SUM( lfimg ) AS lfimg INTO CORRESPONDING FIELDS OF TABLE lt_lips
      FROM lips
      WHERE vbeln = ls_likp-vbeln
        AND lfimg NE 0
      GROUP BY vbeln matnr vrkme.
**    SELECT SINGLE * INTO   ls_ztdnsddt024 FROM ztdnsddt024
**      WHERE kunnr = ls_likp-kunnr.

    ls_result-delivery_no = ls_likp-vbeln.
    ls_result-delivery_date = ls_likp-erdat.
    ls_result-store_id = ls_likp-store_id.
    LOOP AT lt_lips INTO ls_lips.
      ls_detail-material = ls_lips-matnr.
      WRITE ls_lips-lfimg TO lv_qty NO-GROUPING NO-SIGN NO-GAP DECIMALS 0.
      CONDENSE lv_qty.
      ls_detail-qty = lv_qty.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = ls_lips-vrkme "lt_po-bprme
        IMPORTING
          output         = lv_uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      ls_detail-uom = lv_uom.
      APPEND ls_detail TO ls_result-items.
    ENDLOOP.
    IF ls_result IS NOT INITIAL.
      CREATE OBJECT cl_json_data
        EXPORTING
          data = ls_result.
      cl_json_data->serialize( ).
      lv_json = cl_json_data->get_data( ).

      lv_name = ls_result-delivery_no.
      CONCATENATE 'Off' lv_name INTO lv_name.
      PERFORM f_create_text_json(ztdsit_i001) USING lv_json lv_name '/inbound/tdn/' 'TMART_OFFLINE'.

      status = 'S'.
      CLEAR: message.
      DATA: lv_messout TYPE bapi_msg.
      CALL FUNCTION 'ZTDSIT_F0006'
        EXPORTING
          pi_proses  = 'TMART_OFFLINE'
          pi_jsonin  = lv_json
          pi_type    = 'POST'
        IMPORTING
          pe_type    = gv_status
          pe_message = lv_messout
          pe_jsonout = lv_json.
      status = gv_status.
      message = lv_messout.
      json_out = lv_json.
      IF status = 'S'.
        UPDATE ztdnmmdt010 SET status = 'S'
           WHERE vbeln  = vbeln.
      ENDIF.
    ELSE.
      status = 'E'.
      message = 'Data not found'.
    ENDIF.
  ELSE.
    status = 'E'.
    message = 'Data not found'.
  ENDIF.
ENDFUNCTION.
