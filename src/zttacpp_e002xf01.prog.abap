*&---------------------------------------------------------------------*
*&  Include           ZTTACPP_E002F01
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
    gv_subrc = 2.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_TTAC_LOGIN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data USING   fu_docat fu_status.
  DATA : lt_xaccdtm       TYPE STANDARD TABLE OF zaccdtm.

  SELECT *
    FROM s501
    INTO CORRESPONDING FIELDS OF TABLE gt_s501
    WHERE docat  = fu_docat
      AND werks  = pa_werks
      AND stbpom = fu_status.
  IF gt_s501[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtm
      INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
      FOR ALL ENTRIES IN gt_s501
      WHERE matnr = gt_s501-matnr
        AND charg = gt_s501-charg
        AND aufnr = gt_s501-docno.
    IF gt_zaccdtm[] IS NOT INITIAL.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
        FOR ALL ENTRIES IN gt_zaccdtm
        WHERE matnr = gt_zaccdtm-matnr
          AND charg = gt_zaccdtm-charg
          AND senum = gt_zaccdtm-senum.
    ENDIF.


    lt_xaccdtm[] = gt_zaccdtm[].
    SORT lt_xaccdtm BY aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_xaccdtm COMPARING aufnr.
    IF lt_xaccdtm[] IS NOT INITIAL.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
        FOR ALL ENTRIES IN lt_xaccdtm
        WHERE docat = fu_docat
          AND docno = lt_xaccdtm-aufnr.
    ENDIF.

    SELECT *
      FROM ztspmmdt002
      INTO CORRESPONDING FIELDS OF TABLE gt_ztspmmdt002
      FOR ALL ENTRIES IN gt_s501
      WHERE matnr = gt_s501-matnr
        AND werks = gt_s501-werks.

    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN gt_s501
      WHERE matnr = gt_s501-matnr
        AND charg = gt_s501-charg.
  ELSE.
    gv_subrc = 3.
  ENDIF.
ENDFORM.                    " F_GET_DATA

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
*&      Form  F_REGISTER_PROCESS
*&---------------------------------------------------------------------*
FORM f_register_process  USING    fu_snsta
                        CHANGING fc_subrc.
  DATA : lt_zaccdtm           TYPE STANDARD TABLE OF ty_zaccdtm,
         ls_zaccdtm           LIKE LINE OF lt_zaccdtm,
         lt_xaccdtm           TYPE STANDARD TABLE OF ty_zaccdtm,
         ls_xaccdtm           LIKE LINE OF lt_xaccdtm,
         lt_yaccdtm           TYPE STANDARD TABLE OF ty_zaccdtm,
         ls_yaccdtm           LIKE LINE OF lt_yaccdtm,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_s501              LIKE LINE OF gt_s501,
         ls_mch1              LIKE LINE OF gt_mch1,
         lv_count             TYPE i,
         ls_request_header    LIKE LINE OF gt_request_header.

  DATA : lv_barcode           TYPE string,
         lv_vfdat(10).

  DATA : lv_active(10),
         lv_sample(10),
         lv_reject(10).

  DATA : ls_report            LIKE LINE OF gt_report,
         lv_success           TYPE i,
         lv_error             TYPE i,
         lv_lines             TYPE i,
         lv_desc(20).

  CLEAR fc_subrc.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 6.

  CASE fu_snsta.
    WHEN 'ESTO'.
      lv_active = 'true'.
      lv_sample = 'false'.
      lv_reject = 'false'.
    WHEN 'RTS'.
      lv_active = 'false'.
      lv_sample = 'true'.
      lv_reject = 'false'.
    WHEN 'RJCT'.
      lv_active = 'false'.
      lv_sample = 'false'.
      lv_reject = 'true'.
  ENDCASE.

  LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE snsta = fu_snsta.
    CLEAR ls_s501.
    READ TABLE gt_s501 INTO ls_s501
                       WITH KEY matnr = ls_zaccdtm-matnr
                                charg = ls_zaccdtm-charg
                                docno = ls_zaccdtm-aufnr.
    IF sy-subrc = 0.
      CLEAR ls_zaccdtd.
      READ TABLE gt_zaccdtd INTO ls_zaccdtd
                            WITH KEY docat  = ls_s501-docat
                                     docno  = ls_s501-docno
                                     senum  = ls_zaccdtm-senum
                                     scandt = ls_s501-sptag.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    READ TABLE gt_zaccdta INTO ls_zaccdta
                          WITH KEY senum = ls_zaccdtm-senum.
    IF sy-subrc = 0.
      ls_zaccdtm-aggr1 = ls_zaccdta-aggr1.
      ls_zaccdtm-aggr2 = ls_zaccdta-aggr2.
    ENDIF.
    APPEND ls_zaccdtm TO lt_zaccdtm.
    CLEAR ls_zaccdtm.
  ENDLOOP.

  IF lt_zaccdtm[] IS NOT INITIAL.
    lt_yaccdtm[] = lt_zaccdtm[].
    SORT lt_yaccdtm BY aggr1.
    DELETE ADJACENT DUPLICATES FROM lt_yaccdtm COMPARING aggr1.
    DELETE lt_yaccdtm WHERE aggr1 IS INITIAL.

    LOOP AT lt_yaccdtm INTO ls_yaccdtm.
      CLEAR : lt_xaccdtm[], ls_xaccdtm, ls_xaccdtm.
      LOOP AT lt_zaccdtm INTO ls_zaccdtm WHERE aggr1 = ls_yaccdtm-aggr1.
        APPEND ls_zaccdtm TO lt_xaccdtm.
        CLEAR ls_zaccdtm.
      ENDLOOP.

      DESCRIBE TABLE lt_xaccdtm LINES lv_lines.

      CLEAR ls_ztspmmdt002.
      READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                WITH KEY matnr = ls_yaccdtm-matnr.
      CLEAR ls_mch1.
      READ TABLE gt_mch1 INTO ls_mch1
                        WITH KEY matnr = ls_yaccdtm-matnr
                                 charg = ls_yaccdtm-charg.

      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'barcode' '' '' '' '' 'X' '',
        '[' '' '' '' '' '' '' ''.
      LOOP AT lt_xaccdtm INTO ls_xaccdtm WHERE aggr1 = ls_yaccdtm-aggr1
                                           AND check = space.
        ADD 1 TO lv_count.
        PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                       ls_xaccdtm-charg
                                       ls_mch1-vfdat
                                       ls_xaccdtm-senum
                                 CHANGING lv_barcode.

        IF lv_count = lv_lines.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' '' '' '' ''.
        ELSE.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' ',' '' '' ''.
        ENDIF.
        ls_xaccdtm-check = 'X'.

        CONCATENATE 'Primer' fu_snsta INTO lv_desc SEPARATED BY space.
        PERFORM f_list_process USING lv_desc ls_yaccdtm-aggr2 ls_yaccdtm-aggr1
                                     lv_barcode ls_yaccdtm-aufnr.

        MODIFY lt_xaccdtm FROM ls_xaccdtm TRANSPORTING check.
        CLEAR ls_xaccdtm.
      ENDLOOP.

      lv_lines  = lv_lines - lv_count.
      CLEAR lv_vfdat.
      CONCATENATE ls_mch1-vfdat(4) '-'
                  ls_mch1-vfdat+4(2) '-'
                  ls_mch1-vfdat+6(2)
             INTO lv_vfdat.

      PERFORM f_json_format USING :
        '' '' '' '' ',' '' '' ']',
        '' 'nie' ls_ztspmmdt002-nie '' ',' '' '' '',
        '' 'batch_no' ls_yaccdtm-charg '' ',' '' '' '',
        '' 'exp_date' lv_vfdat '' ',' '' '' '',
        '' 'is_active' lv_active 'X' ',' '' '' '',
        '' 'is_sample' lv_sample 'X' ',' '' '' '',
        '' 'is_reject' lv_reject 'X' ',' '' '' '',
        '' 'id_kemasan' ls_ztspmmdt002-kemasan '' ',' 'X' '' '',
        '' 'lot_no' ls_yaccdtm-aufnr '' ',' '' '' '',
*        '' 'gtin' '1' '' ',' '' '' '',
        '' 'parent' ls_yaccdtm-aggr1 '' '' '' '' '',
*        '' 'id_location' 1 'X' '' '' '' '',
        '' '' '' '' '' '' '' '}'.

      IF lt_xaccdtm[] IS NOT INITIAL.
        PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy '2'
                                  ls_zaccdtm-aufnr 'Pelaporan Barcode Primer' lv_count
                            CHANGING ls_report-success ls_report-error.
        ls_report-desc   = 'Primer'.
        ls_report-docno  = ls_yaccdtm-aufnr.
        ls_report-matnr  = ls_yaccdtm-matnr.
        ls_report-charg  = ls_yaccdtm-charg.
        APPEND ls_report TO gt_report.
        CLEAR ls_report.
      ENDIF.
      CLEAR lv_count.
    ENDLOOP.
  ELSE.
    fc_subrc = 2.
  ENDIF.
ENDFORM.                    " F_REGISTER_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BARCODE
*&---------------------------------------------------------------------*
FORM f_create_barcode  USING    fu_nie fu_charg fu_vfdat fu_senum
                       CHANGING fc_barcode.
  DATA : lv_vfdat(6).

  IF gv_concat IS INITIAL.
    fc_barcode = fu_senum.
  ELSE.
    lv_vfdat  = fu_vfdat+2(6).
    CONCATENATE '90' fu_nie '\u001d' INTO fc_barcode.
    CONDENSE fc_barcode NO-GAPS.
    CONCATENATE fc_barcode '10' fu_charg '\u001d' INTO fc_barcode.
    CONDENSE fc_barcode NO-GAPS.
    CONCATENATE fc_barcode '17' lv_vfdat '21' fu_senum INTO fc_barcode.
    CONDENSE fc_barcode NO-GAPS.
  ENDIF.
ENDFORM.                    " F_CREATE_BARCODE

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
         ls_response          TYPE ty_response,
         lv_split1            TYPE string,
         lv_split2            TYPE string,
         lv_split3            TYPE string,
         lv_split4            TYPE string.

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
          SPLIT ls_response-message AT ':' INTO lv_split1 lv_split2.
          IF lv_split2 IS INITIAL.
            ADD fu_count TO fc_success.
            PERFORM f_modify_s501 USING fu_stbpom.
          ELSEIF lv_split2 IS NOT INITIAL.
            SPLIT ls_response-message AT space INTO lv_split3 lv_split4.
            IF lv_split3 = 0.
              ADD fu_count TO fc_error.
            ELSE.
              ADD lv_split3 TO fc_success.
              ADD lv_split2 TO fc_error.
            ENDIF.
          ENDIF.
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
                          WITH KEY docat = ls_s501-docat
                                   docno = ls_s501-docno.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                          WITH KEY matnr = ls_s501-matnr
                                   charg = ls_s501-charg
                                   aufnr = ls_s501-docno.
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
                sy-vline, (60) ls_error-response,
                sy-vline.
      CLEAR ls_error.
    ENDLOOP.
    WRITE : / sy-uline.
  ENDIF.

  IF gt_list[] IS NOT INITIAL.
    WRITE : / sy-uline(111).
    SORT gt_list BY aufnr aggr1 aggr2.
    LOOP AT gt_list INTO ls_list.
      WRITE : / sy-vline, (20) ls_list-desc,
                sy-vline, (15) ls_list-aufnr,
                sy-vline, (20) ls_list-aggr2,
                sy-vline, (20) ls_list-aggr1,
                sy-vline, (20) ls_list-senum,
                sy-vline.
      CLEAR ls_list.
    ENDLOOP.
    WRITE : / sy-uline(111).
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
FORM f_list_process  USING    fu_level fu_aggr2 fu_aggr1 fu_barcode fu_aufnr.
  DATA : ls_list    LIKE LINE OF gt_list.

  ls_list-desc    = fu_level.
  ls_list-aggr2   = fu_aggr2.
  ls_list-aggr1   = fu_aggr1.
  ls_list-senum   = fu_barcode.
  ls_list-aufnr   = fu_aufnr.
  APPEND ls_list TO gt_list.
  CLEAR ls_list.
ENDFORM.                    " F_LIST_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST_PRD
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
