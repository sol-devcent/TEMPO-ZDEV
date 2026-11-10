*&---------------------------------------------------------------------*
*&  Include           ZTTACPP_E001PF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT SINGLE *
    FROM zaccdtl
    INTO CORRESPONDING FIELDS OF gs_zaccdtl
    WHERE werks = pa_werks
      AND bname = sy-uname.

  IF gs_zaccdtl IS INITIAL.
    gv_subrc = 1.
  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data  USING    fu_docat fu_status.
  DATA : ls_s501     LIKE LINE OF gt_s501.

  SELECT *
    FROM s501
    INTO CORRESPONDING FIELDS OF TABLE gt_s501
    WHERE docat  = fu_docat
      AND werks  = pa_werks
      AND stbpom = fu_status.
  IF gt_s501[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtd
      INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
      FOR ALL ENTRIES IN gt_s501
      WHERE docat  = gt_s501-docat
        AND docno  = gt_s501-docno
        AND scandt = gt_s501-sptag
        AND xloek  = space.
    IF gt_zaccdtd[] IS NOT INITIAL.
      SELECT *
        FROM zaccdtm
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
        FOR ALL ENTRIES IN gt_zaccdtd
        WHERE senum = gt_zaccdtd-senum.
      IF gt_zaccdtm[] IS NOT INITIAL.
        SELECT *
          FROM zaccdta
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
          FOR ALL ENTRIES IN gt_zaccdtm
          WHERE matnr = gt_zaccdtm-matnr
            AND charg = gt_zaccdtm-charg
            AND senum = gt_zaccdtm-senum.
      ENDIF.
    ENDIF.
  ELSE.
    gv_subrc = 2.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_TTAC_LOGIN
*&---------------------------------------------------------------------*
FORM f_ttac_login .
  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu,
         lv_procid    TYPE zaccdtu-procid.

  DATA : ls_request_header  LIKE LINE OF gt_request_header,
         ls_request_body    LIKE LINE OF gt_request_body,
         temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string,
         ls_role            TYPE ty_role,
         lv_company         TYPE zaccdtu-company.

  lv_company = 'BPOM'.

  SELECT *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtu
    WHERE company = lv_company.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 1.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  ls_request_body-body = '{'.
  APPEND ls_request_body TO gt_request_body.
  CONCATENATE '"email": "' gs_zaccdtl-smtp_addr '",' INTO ls_request_body-body.
  APPEND ls_request_body TO gt_request_body.
  CONCATENATE '"password": "' gs_zaccdtl-bcode '"' INTO ls_request_body-body.
  APPEND ls_request_body TO gt_request_body.
  ls_request_body-body = '}'.
  APPEND ls_request_body TO gt_request_body.

*****  PERFORM f_http_post_via_apo TABLES  gt_request_header
*****                                      gt_request_body
*****                                      gt_response_header
*****                                      gt_response_body
*****                             USING    ls_zaccdtu-uri ls_zaccdtu-proxy ''
*****                             CHANGING status_code status_text.

  PERFORM f_http_post_prd TABLES gt_request_header
                                 gt_request_body
                                 gt_response_header
                                 gt_response_body
                          USING    ls_zaccdtu-uri ls_zaccdtu-proxy ''
                          CHANGING status_code status_text.

  IF sy-subrc = 0.
    LOOP AT gt_response_body INTO temp_json.
      CONDENSE : temp_json, lv_str.
      CONCATENATE lv_str temp_json INTO lv_str.
    ENDLOOP.

    writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
    TRY.
        CALL TRANSFORMATION id SOURCE XML lv_str
                               RESULT XML writer.
        xml = writer->get_output( ).
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
        WRITE: / 'Message Error JSON to XML: ', ls_var_text.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION zacc_login_v3 SOURCE XML xml
                                          RESULT role = ls_role.
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
    ENDTRY.
  ENDIF.

  gv_token    = ls_role-token.
  gv_idsarana = ''.
  IF gv_token IS INITIAL.
    gv_subrc = 3.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_TTAC_LOGIN

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST_VIA_APO
*&---------------------------------------------------------------------*
FORM f_http_post_via_apo  TABLES   ft_request_header
                                   ft_request_body
                                   ft_response_header
                                   ft_response_body
                          USING    fu_uri fu_proxy fu_process
                          CHANGING fc_code fc_text.

  DATA : ls_001     TYPE ztnpqmdt001,
         lv_code(10),
         lv_text(100),
         lv_host    TYPE rfcdisplay-rfchost.

  SELECT SINGLE *
    FROM ztnpqmdt001
    INTO CORRESPONDING FIELDS OF ls_001
    WHERE sysid   = 'DEV' "sy-sysid
      AND bname   = sy-uname.

  IF sy-subrc = 0.
    lv_host   = ls_001-rfchost.

    CALL FUNCTION 'RFC_MODIFY_R3_DESTINATION'
      EXPORTING
        destination                = ls_001-destination
        action                     = 'M'
        systemnr                   = ls_001-rfcservice
        server                     = lv_host
        language                   = sy-langu
        client                     = ls_001-rfcclient
        user                       = ls_001-rfcuser
        password                   = ls_001-password
      EXCEPTIONS
        authority_not_available    = 1
        destination_already_exist  = 2
        destination_not_exist      = 3
        destination_enqueue_reject = 4
        information_failure        = 5
        trfc_entry_invalid         = 6
        internal_failure           = 7
        snc_information_failure    = 8
        snc_internal_failure       = 9
        destination_is_locked      = 10
        OTHERS                     = 11.
    IF sy-subrc = 0.
      CALL FUNCTION 'ZRFC_TTAC_HTTP_POST'
        DESTINATION ls_001-destination
        EXPORTING
          absolute_uri               = fu_uri
          request_entity_body_length = 300
          proxy                      = fu_proxy
          blankstocrlf               = 'X'
        IMPORTING
          status_code                = fc_code
          status_text                = fc_text
        TABLES
          request_entity_body        = ft_request_body
          response_entity_body       = ft_response_body
          response_headers           = ft_response_header
          request_headers            = ft_request_header.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_HTTP_POST_VIA_APO

*&---------------------------------------------------------------------*
*&      Form  F_REGISTERPARENT_PROCESS
*&---------------------------------------------------------------------*
FORM f_registerparent_process .
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         ls_report            LIKE LINE OF gt_report.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 5.

  lt_xaccdta[] = gt_zaccdta[].
  SORT lt_xaccdta BY aggr2.
  DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr2.
  DELETE lt_xaccdta WHERE aggr2 IS INITIAL.
  IF lt_xaccdta[] IS NOT INITIAL.
    PERFORM f_register_parent TABLES lt_xaccdta
                              USING ls_zaccdtu 'tersier' ''
                              CHANGING ls_report-success ls_report-error.
    ls_report-desc = 'Parent Tersier'.
    APPEND ls_report TO gt_report.
    CLEAR ls_report.
  ENDIF.

  CLEAR : lt_xaccdta[].
  lt_xaccdta[] = gt_zaccdta[].
  DELETE lt_xaccdta WHERE aggr2 IS NOT INITIAL.
  SORT lt_xaccdta BY aggr1.
  DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr1.
  IF lt_xaccdta[] IS NOT INITIAL.
    PERFORM f_register_parent TABLES lt_xaccdta
                              USING ls_zaccdtu 'sekunder' ''
                              CHANGING ls_report-success ls_report-error.
    ls_report-desc = 'Parent Sekunder'.
    APPEND ls_report TO gt_report.
    CLEAR ls_report.
  ENDIF.
ENDFORM.                    " F_REGISTERPARENT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_PARENT
*&---------------------------------------------------------------------*
FORM f_register_parent  TABLES   ft_zaccdta STRUCTURE zaccdta
                        USING    fs_zaccdtu TYPE zaccdtu
                                 fu_level fu_aggr
                        CHANGING fc_success fc_error.
  DATA : ls_zaccdta           TYPE zaccdta,
         lt_xaccdta           TYPE STANDARD TABLE OF ty_zaccdta,
         ls_xaccdta           TYPE ty_zaccdta,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm.

  DATA : ls_request_header    LIKE LINE OF gt_request_header,
         lv_barcode           TYPE string,
         lv_lines             TYPE i,
         lv_count             TYPE i.

  CLEAR : lt_xaccdta[], lt_xaccdta, ls_xaccdta.
  LOOP AT ft_zaccdta INTO ls_zaccdta.
    MOVE-CORRESPONDING ls_zaccdta TO ls_xaccdta.
    APPEND ls_xaccdta TO lt_xaccdta.
    CLEAR ls_xaccdta.
  ENDLOOP.

  DESCRIBE TABLE lt_xaccdta LINES lv_lines.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  PERFORM f_json_format USING :
    '{' '' '' '' '' '' '' '',
    '' 'token' gv_token '' ',' '' '' '',
    '' 'barcode' '' '' '' '' 'X' '',
    '[' '' '' '' '' '' '' ''.

  CLEAR ls_xaccdta.
  LOOP AT lt_xaccdta INTO ls_xaccdta WHERE check = space.
    ADD 1 TO lv_count.

    CLEAR ls_zaccdtm.
    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                          WITH KEY matnr = ls_xaccdta-matnr
                                   charg = ls_xaccdta-charg
                                   senum = ls_xaccdta-senum.

    CASE fu_level.
      WHEN 'tersier'.
        lv_barcode   = ls_xaccdta-aggr2.
      WHEN 'sekunder'.
        lv_barcode   = ls_xaccdta-aggr1.
    ENDCASE.

    IF lv_count = lv_lines.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' ',' '' '' ''.
    ENDIF.
    ls_xaccdta-check = 'X'.

    PERFORM f_list_process USING fu_level lv_barcode ls_zaccdtm-aufnr.

    MODIFY lt_xaccdta FROM ls_xaccdta TRANSPORTING check.
    CLEAR ls_xaccdta.
  ENDLOOP.

  IF fu_aggr IS INITIAL.
    PERFORM f_json_format USING :
      '' '' '' '' ',' '' '' ']',
      '' 'is_active' 'true' 'X' ',' '' '' '',
      '' 'barcode_level' fu_level '' '' '' '' '',
      '' '' '' '' '' '' '' '}'.
  ELSE.
    PERFORM f_json_format USING :
      '' '' '' '' ',' '' '' ']',
      '' 'is_active' 'true' 'X' ',' '' '' '',
      '' 'barcode_level' fu_level '' ',' '' '' '',
      '' 'parent' fu_aggr '' '' '' '' '',
      '' '' '' '' '' '' '' '}'.
  ENDIF.

  IF lt_xaccdta[] IS NOT INITIAL.
    PERFORM f_http_post USING fs_zaccdtu-uri fs_zaccdtu-proxy '1'
                              '' 'Pelaporan Barcode Parent'
                              lv_count
                        CHANGING fc_success fc_error.
  ENDIF.
ENDFORM.                    " F_REGISTER_PARENT

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_http_post  USING    fu_uri fu_proxy fu_stbpom fu_description
                           fu_process fu_count
                  CHANGING fc_success fc_error.
  DATA : lv_code(10),
         lv_text(100),
         ls_response_header   LIKE LINE OF gt_response_header,
         ls_error             LIKE LINE OF gt_error,
         ls_response          TYPE ty_response.

  IF gt_request_body[] IS NOT INITIAL.
*****    PERFORM f_http_post_via_apo TABLES  gt_request_header
*****                                        gt_request_body
*****                                        gt_response_header
*****                                        gt_response_body
*****                               USING    fu_uri fu_proxy fu_process
*****                               CHANGING lv_code lv_text.

    PERFORM f_http_post_prd TABLES gt_request_header
                                   gt_request_body
                                   gt_response_header
                                   gt_response_body
                            USING    fu_uri fu_proxy fu_process
                            CHANGING lv_code lv_text.

    IF lv_code  = '200' AND
      lv_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        IF fu_stbpom IS NOT INITIAL.
          ADD fu_count TO fc_success.
          PERFORM f_modify_s501 USING fu_stbpom.
        ENDIF.
      ELSE.
        ADD fu_count TO fc_error.
        ls_error-description    = fu_description.
        ls_error-process        = fu_process.
        CONCATENATE ls_response-statuscode ls_response-message
        INTO ls_error-response
        SEPARATED BY space.
        APPEND ls_error TO gt_error.
        CLEAR ls_error.
      ENDIF.
    ELSE.
      ADD fu_count TO fc_error.
      LOOP AT gt_response_header INTO ls_response_header.
        ls_error-description    = fu_description.
        ls_error-process        = fu_process.
        ls_error-response       = ls_response_header-header.
        APPEND ls_error TO gt_error.
        CLEAR ls_error.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_HTTP_POST

*&---------------------------------------------------------------------*
*&      Form  F_JSON_FORMAT
*&---------------------------------------------------------------------*
FORM f_json_format  USING    fu_open fu_fname fu_value fu_nchar
                             fu_separated fu_condense fu_space fu_close.
  DATA : ls_request_body   LIKE LINE OF gt_request_body,
         lv_value(1000).

  IF fu_open IS NOT INITIAL.
    ls_request_body-body   = fu_open.
  ELSEIF fu_close IS NOT INITIAL.
    IF fu_separated IS INITIAL.
      ls_request_body-body   = fu_close.
    ELSE.
      CONCATENATE fu_close fu_separated INTO ls_request_body-body.
    ENDIF.
  ELSE.
    lv_value  = fu_value.
    IF fu_condense IS INITIAL.
      CONDENSE lv_value NO-GAPS.
    ENDIF.
    IF fu_nchar IS NOT INITIAL.
      CONCATENATE '"' fu_fname '":' lv_value fu_separated
      INTO ls_request_body-body.
    ELSEIF lv_value IS INITIAL.
      IF fu_space IS INITIAL.
        CONCATENATE '"' fu_fname '":"null"' fu_separated
        INTO ls_request_body-body.
      ELSE.
        CONCATENATE '"' fu_fname '":' fu_separated
        INTO ls_request_body-body.
      ENDIF.
    ELSEIF fu_fname IS INITIAL.
      CONCATENATE '"' lv_value '"' fu_separated
      INTO ls_request_body-body.
    ELSE.
      CONCATENATE '"' fu_fname '":"' lv_value '"' fu_separated
      INTO ls_request_body-body.
    ENDIF.
  ENDIF.
  APPEND ls_request_body TO gt_request_body.
  CLEAR ls_request_body.
ENDFORM.                    " F_JSON_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_S501
*&---------------------------------------------------------------------*
FORM f_modify_s501  USING    fu_stbpom.
  DATA : ls_s501      LIKE LINE OF gt_s501,
         ls_zaccdtd   LIKE LINE OF gt_zaccdtd,
         ls_zaccdtm   LIKE LINE OF gt_zaccdtm.

  LOOP AT gt_s501 INTO ls_s501.
    READ TABLE gt_zaccdtd INTO ls_zaccdtd
                          WITH KEY docat  = ls_s501-docat
                                   docno  = ls_s501-docno
                                   scandt = ls_s501-sptag.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    TRY .
        UPDATE s501 SET stbpom = fu_stbpom
                    WHERE sptag = ls_s501-sptag
                      AND docat = ls_s501-docat
                      AND docno = ls_s501-docno
                      AND posnr = ls_s501-posnr.
      CATCH cx_sy_conversion_no_number.
    ENDTRY.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_S501

*&---------------------------------------------------------------------*
*&      Form  F_READ_RESPONSE_BODY
*&---------------------------------------------------------------------*
FORM f_read_response_body  CHANGING fs_response   TYPE ty_response.
  DATA : temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string.

  LOOP AT gt_response_body INTO temp_json.
    CONDENSE : temp_json, lv_str.
    CONCATENATE lv_str temp_json INTO lv_str.
  ENDLOOP.

  writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
  TRY.
      CALL TRANSFORMATION id SOURCE XML lv_str
                             RESULT XML writer.
      xml = writer->get_output( ).
    CATCH cx_root INTO ls_rif_ex.
      ls_var_text = ls_rif_ex->get_text( ).
      WRITE: / 'Message Error JSON to XML: ', ls_var_text.
  ENDTRY.

  TRY.
      CALL TRANSFORMATION zacc_status_response SOURCE XML xml
                                               RESULT response = fs_response.
    CATCH cx_root INTO ls_rif_ex.
      ls_var_text = ls_rif_ex->get_text( ).
  ENDTRY.
ENDFORM.                    " F_READ_RESPONSE_BODY

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_REPORT
*&---------------------------------------------------------------------*
FORM f_write_report .
  DATA : ls_error             LIKE LINE OF gt_error,
         ls_report            LIKE LINE OF gt_report,
         ls_list              LIKE LINE OF gt_list.

  IF gt_error[] IS NOT INITIAL.
    WRITE : / sy-uline.
    LOOP AT gt_error INTO ls_error.
      WRITE : / sy-vline, (30) ls_error-process,
                sy-vline, (60) ls_error-response ,
                sy-vline.
      CLEAR ls_error.
    ENDLOOP.
    WRITE : / sy-uline.
  ENDIF.

  IF gt_list[] IS NOT INITIAL.
    WRITE : / sy-uline(55).
    SORT gt_list BY aufnr aggr.
    LOOP AT gt_list INTO ls_list.
      WRITE : / sy-vline, (10) ls_list-desc,
                sy-vline, (15) ls_list-aufnr,
                sy-vline, (20) ls_list-aggr,
                sy-vline.
      CLEAR ls_list.
    ENDLOOP.
    WRITE : / sy-uline(55).
  ENDIF.
  IF gt_report[] IS NOT INITIAL.
    LOOP AT gt_report INTO ls_report.
      WRITE :/ ls_report-desc,
             / 'Success : ', ls_report-success,
             / 'Error   : ', ls_report-error.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_WRITE_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_PROCESS
*&---------------------------------------------------------------------*
FORM f_list_process  USING    fu_level fu_barcode fu_aufnr.
  DATA : ls_list    LIKE LINE OF gt_list.

  ls_list-desc    = fu_level.
  ls_list-aggr    = fu_barcode.
  ls_list-aufnr   = fu_aufnr.
  APPEND ls_list TO gt_list.
  CLEAR ls_list.
ENDFORM.                    " F_LIST_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_HTTPS_POST
*&---------------------------------------------------------------------*
FORM f_http_post_prd  TABLES   ft_request_header STRUCTURE sbcheader
                               ft_request_body STRUCTURE sbcbody
                               ft_response_header STRUCTURE sbcheader
                               ft_response_body STRUCTURE sbcbody
                      USING    fu_uri fu_proxy fu_process
                      CHANGING fc_code fc_text.
  DATA : len    TYPE i.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 300
      proxy                       = fu_proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = fc_code
      status_text                 = fc_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = ft_request_body
      response_entity_body        = ft_response_body
      response_headers            = ft_response_header
      request_headers             = ft_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.
ENDFORM.                    " F_HTTP_POST_PRD
