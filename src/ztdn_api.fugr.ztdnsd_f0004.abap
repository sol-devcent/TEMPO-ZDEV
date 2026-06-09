FUNCTION ztdnsd_f0004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROSES) TYPE  CHAR15 DEFAULT 'TDN_CUSTOMER'
*"     REFERENCE(PHONE_NUMBER) TYPE  CHAR20 OPTIONAL
*"     REFERENCE(NO_ORDER) TYPE  CHAR25
*"     REFERENCE(FLAG) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(API) TYPE  CHAR1 DEFAULT 'X'
*"     REFERENCE(PATHNAME) LIKE  EDI_PATH-PTHNAM OPTIONAL
*"  EXPORTING
*"     VALUE(SAP_ID) TYPE  KUNNR
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.

  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string,
        lv_err TYPE sysubrc.
  DATA: p_kunnr        TYPE kunnr, p_message(100).
  DATA: lv_text TYPE text1024. "string.                                "
  TYPES: BEGIN OF ty_sapid,
           no_order   TYPE string,
           phone_cust TYPE string,
           sap_id     TYPE string,
           status     TYPE string,
           message    TYPE string,
         END OF ty_sapid.
  TYPES: BEGIN OF ty_sap_id,
           sap_id TYPE STANDARD TABLE OF ty_sapid WITH NON-UNIQUE DEFAULT KEY,
         END OF ty_sap_id.

  DATA: lt_sap_id TYPE ty_sap_id.
  DATA: ls_sap_id TYPE ty_sapid.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json      TYPE string.
  IF api = 'X'.
    gv_no_order = no_order.
    CONCATENATE '{ "no_order": "' no_order '" }' INTO lt_response_body-line.
    APPEND lt_response_body.
    proses = 'TDN_CREATECUST'.
    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    proses
                                       CHANGING lv_str lv_err.
  ELSE.
    OPEN DATASET pathname FOR INPUT IN TEXT MODE ENCODING UTF-8
                           IGNORING CONVERSION ERRORS.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET pathname INTO lv_text.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        CONCATENATE lv_str lv_text INTO lv_str.
        CLEAR: lv_text.
      ENDDO.
      CLOSE DATASET pathname.
      REPLACE ALL OCCURRENCES OF REGEX '# ' IN lv_str WITH '"  "'.
    ENDIF.
  ENDIF.
  IF lv_str IS NOT INITIAL.
    PERFORM f_convert_json USING lv_str CHANGING p_kunnr p_message. "gt_goodsmvt.
    sap_id = p_kunnr.
    message = p_message.
    IF p_kunnr IS INITIAL.
      status = 'E'.
    ELSE.
      IF p_message IS NOT INITIAL.
        status = 'E'.
      ELSE.
        status = 'S'.
      ENDIF.
    ENDIF.
    CLEAR: ls_sap_id.
    ls_sap_id-no_order = no_order.
    ls_sap_id-phone_cust = phone_number.
    ls_sap_id-sap_id = p_kunnr.
    ls_sap_id-status = status.
    ls_sap_id-message = message.
    APPEND ls_sap_id TO lt_sap_id-sap_id.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_sap_id.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'TDN_CREATECUST' sy-subrc lv_str.
    IF message IS INITIAL.
      message = p_kunnr.
    ENDIF.
  ENDIF.
ENDFUNCTION.
