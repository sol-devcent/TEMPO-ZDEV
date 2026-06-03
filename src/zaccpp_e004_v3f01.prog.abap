*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004_V3F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_LOGIN_DATA
*&---------------------------------------------------------------------*
FORM f_login_data .
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

*  IF pa_test IS INITIAL.
  lv_company = 'BPOM'.
*  ELSE.
*    lv_company = 'TDS'.
*  ENDIF.

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
*  ls_request_body-body = '"email": "gatot.pramono@thetempogroup.com",'.
  APPEND ls_request_body TO gt_request_body.
  CONCATENATE '"password": "' gs_zaccdtl-bcode '"' INTO ls_request_body-body.
*  ls_request_body-body = '"password": "Tempo_2020"'.
  APPEND ls_request_body TO gt_request_body.
  ls_request_body-body = '}'.
  APPEND ls_request_body TO gt_request_body.

  PERFORM f_http_post_via_apo TABLES  gt_request_header
                                      gt_request_body
                                      gt_response_header
                                      gt_response_body
                             USING    ls_zaccdtu-uri ls_zaccdtu-proxy ''
                             CHANGING status_code status_text.

****  CALL FUNCTION 'HTTP_POST'
****    EXPORTING
****      absolute_uri                = ls_zaccdtu-uri
****      request_entity_body_length  = 300
****      proxy                       = ls_zaccdtu-proxy
****      blankstocrlf                = 'X'
****    IMPORTING
****      status_code                 = status_code
****      status_text                 = status_text
****      response_entity_body_length = len
****    TABLES
****      request_entity_body         = gt_request_body
****      response_entity_body        = gt_response_body
****      response_headers            = gt_response_header
****      request_headers             = gt_request_header
****    EXCEPTIONS
****      connect_failed              = 1
****      timeout                     = 2
****      internal_error              = 3
****      tcpip_error                 = 4
****      system_failure              = 5
****      communication_failure       = 6
****      OTHERS                      = 7.

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
    gv_error = 1.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_LOGIN_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data USING fu_docat fu_status.
  DATA : lt_zaccdtm   TYPE STANDARD TABLE OF zaccdtm,
         ls_zaccdtm   LIKE LINE OF lt_zaccdtm.

  CASE 'X'.
    WHEN radio8.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_primer
        WHERE senum IN so_senum.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_sekunder
        WHERE aggr1 IN so_senum.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_tersier
        WHERE aggr2 IN so_senum.

      IF gt_primer[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN gt_primer
          WHERE matnr = gt_primer-matnr
            AND charg = gt_primer-charg
            AND senum = gt_primer-senum.

        IF gt_zaccdtm[] IS NOT INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE gt_ztspmmdt002
            FOR ALL ENTRIES IN gt_zaccdtm
            WHERE matnr = gt_zaccdtm-matnr
              AND werks = gt_zaccdtm-werks.

          SELECT *
            FROM mch1
            INTO CORRESPONDING FIELDS OF TABLE gt_mch1
            FOR ALL ENTRIES IN gt_zaccdtm
            WHERE matnr = gt_zaccdtm-matnr
              AND charg = gt_zaccdtm-charg.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      SELECT *
        FROM s501
        INTO CORRESPONDING FIELDS OF TABLE gt_s501
        WHERE sptag IN so_erdat
          AND docat  = fu_docat
          AND docno IN so_docno
          AND stbpom = fu_status.
      IF gt_s501[] IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
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

          WHEN radio2.
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

              SELECT *
                FROM zaccdtd
                INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
                FOR ALL ENTRIES IN gt_zaccdtm
                WHERE docat = fu_docat
                  AND docno = gt_zaccdtm-aufnr.
            ENDIF.

          WHEN radio3.
            SELECT *
              FROM zaccdtd
              INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
              FOR ALL ENTRIES IN gt_s501
              WHERE docat = gt_s501-docat
                AND docno = gt_s501-docno
                AND xloek = space.
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
        ENDCASE.

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
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REGISTERPARENT_PROCESS
*&---------------------------------------------------------------------*
FORM f_registerparent_process .
  DATA : lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu.

  DATA : lv_success   TYPE i,
         lv_error     TYPE i,
         lv_subrc1    TYPE i,
         lv_subrc2    TYPE i.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 5.

  lt_xaccdta[] = gt_zaccdta[].
  SORT lt_xaccdta BY aggr2.
  DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr2.
  DELETE lt_xaccdta WHERE aggr2 IS INITIAL.
  IF lt_xaccdta[] IS NOT INITIAL.
    PERFORM f_register_parent TABLES lt_xaccdta
                              USING ls_zaccdtu 'tersier' ''
                              CHANGING lv_success lv_error.
    IF gt_error[] IS INITIAL.
      LOOP AT lt_xaccdta INTO ls_xaccdta.
        CLEAR : lt_zaccdta[].
        LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr2 = ls_xaccdta-aggr2.
          APPEND ls_zaccdta TO lt_zaccdta.
          CLEAR ls_zaccdta.
        ENDLOOP.
        SORT lt_zaccdta BY aggr1.
        DELETE ADJACENT DUPLICATES FROM lt_zaccdta COMPARING aggr1.
        PERFORM f_register_parent TABLES lt_zaccdta
                                  USING ls_zaccdtu 'sekunder' ls_xaccdta-aggr2
                                  CHANGING lv_success lv_error.
      ENDLOOP.
    ENDIF.
  ELSE.
    lv_subrc1 = 2.
  ENDIF.

  lt_xaccdta[] = gt_zaccdta[].
  DELETE lt_xaccdta WHERE aggr2 IS NOT INITIAL.
  SORT lt_xaccdta BY aggr1.
  DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr1.
  IF lt_xaccdta[] IS NOT INITIAL.
    PERFORM f_register_parent TABLES lt_xaccdta
                              USING ls_zaccdtu 'sekunder' ''
                              CHANGING lv_success lv_error.
  ELSE.
    lv_subrc2 = 2.
  ENDIF.

  WRITE : / 'Success : ', lv_success,
          / 'Error   : ', lv_error.

  IF lv_subrc1 IS NOT INITIAL AND
    lv_subrc2 IS NOT INITIAL.
    gv_error = 2.
  ENDIF.
ENDFORM.                    " F_REGISTERPARENT_PROCESS

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
    PERFORM f_http_post_via_apo TABLES  gt_request_header
                                        gt_request_body
                                        gt_response_header
                                        gt_response_body
                               USING    fu_uri fu_proxy fu_process
                               CHANGING lv_code lv_text.

****    CALL FUNCTION 'HTTP_POST'
****      EXPORTING
****        absolute_uri               = fu_uri
****        request_entity_body_length = 300
****        proxy                      = fu_proxy
****        blankstocrlf               = 'X'
****      IMPORTING
****        status_code                = lv_code
****        status_text                = lv_text
****      TABLES
****        request_entity_body        = gt_request_body
****        response_entity_body       = gt_response_body
****        response_headers           = gt_response_header
****        request_headers            = gt_request_header
****      EXCEPTIONS
****        connect_failed             = 1
****        timeout                    = 2
****        internal_error             = 3
****        tcpip_error                = 4
****        system_failure             = 5
****        communication_failure      = 6
****        OTHERS                     = 7.

    IF lv_code  = '200' AND
      lv_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        IF pa_test IS INITIAL.
          IF fu_stbpom IS NOT INITIAL.
            ADD fu_count TO fc_success.
            PERFORM f_modify_s501 USING fu_stbpom.
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

    IF radio2 IS NOT INITIAL.
      READ TABLE gt_zaccdtm INTO ls_zaccdtm
                            WITH KEY matnr = ls_s501-matnr
                                     charg = ls_s501-charg
                                     aufnr = ls_s501-docno.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
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
*&      Form  F_REGISTER_PROCESS
*&---------------------------------------------------------------------*
FORM f_register_process USING    fu_snsta
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
         lv_xlines            TYPE i,
         ls_request_header    LIKE LINE OF gt_request_header.

  DATA : lv_barcode           TYPE string,
         lv_vfdat(10).

  DATA : lv_active(10),
         lv_sample(10),
         lv_reject(10).

  DATA : lv_success           TYPE i,
         lv_error             TYPE i,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i.

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
      lv_times  = lv_lines DIV co_lines.
      lv_mod    = lv_lines MOD co_lines.

      IF lv_lines = co_lines.
        lv_times  = 1.
      ELSE.
        IF lv_mod = 0.
          lv_times  = lv_times.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.
      ENDIF.

      CLEAR ls_ztspmmdt002.
      READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                WITH KEY matnr = ls_yaccdtm-matnr.
      CLEAR ls_mch1.
      READ TABLE gt_mch1 INTO ls_mch1
                        WITH KEY matnr = ls_yaccdtm-matnr
                                 charg = ls_yaccdtm-charg.

      DO lv_times TIMES.
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
          IF lv_count > co_lines.
            lv_count = lv_count - 1.
            EXIT.
          ENDIF.

          IF lv_lines < co_lines.
            lv_xlines = lv_lines.
          ELSE.
            lv_xlines = co_lines.
          ENDIF.

          PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                         ls_xaccdtm-charg
                                         ls_mch1-vfdat
                                         ls_xaccdtm-senum
                                   CHANGING lv_barcode.

          IF lv_count = lv_xlines.
            PERFORM f_json_format USING :
              '' '' lv_barcode '' '' '' '' ''.
          ELSE.
            PERFORM f_json_format USING :
              '' '' lv_barcode '' ',' '' '' ''.
          ENDIF.
          ls_xaccdtm-check = 'X'.
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
                              CHANGING lv_success lv_error.
        ENDIF.
        CLEAR lv_count.
      ENDDO.
    ENDLOOP.

    WRITE : / 'Success : ', lv_success,
            / 'Error   : ', lv_error.
  ELSE.
    fc_subrc = 2.
  ENDIF.










*  lt_zaccdtm[] = gt_zaccdtm[].
*  SORT lt_zaccdtm BY aufnr.
*  DELETE ADJACENT DUPLICATES FROM lt_zaccdtm COMPARING aufnr.
*  LOOP AT lt_zaccdtm INTO ls_zaccdtm.
*    CLEAR : lt_xaccdtm[], ls_xaccdtm, ls_xaccdtm.
*    LOOP AT gt_zaccdtm INTO ls_xaccdtm WHERE aufnr = ls_zaccdtm-aufnr
*                                         AND snsta = fu_snsta.
*      READ TABLE gt_zaccdtd INTO ls_zaccdtd
*                            WITH KEY senum = ls_xaccdtm-senum.
*      IF sy-subrc = 0 AND ls_zaccdtd-xloek IS NOT INITIAL.
*        CONTINUE.
*      ENDIF.
*      APPEND ls_xaccdtm TO lt_xaccdtm.
*      CLEAR ls_xaccdtm.
*    ENDLOOP.
*
*  ENDLOOP.
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
*&      Form  F_PACKINGAGGREGATE_PROCESS
*&---------------------------------------------------------------------*
FORM f_packingaggregate_process .
  DATA : lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         ls_zaccdta           LIKE LINE OF lt_zaccdta,
         lt_xaccdta           TYPE STANDARD TABLE OF ty_zaccdta,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         ls_request_header    LIKE LINE OF gt_request_header,
         lv_packdat1(10),
         lv_barcode           TYPE string.

  DATA : lv_success   TYPE i,
         lv_error     TYPE i.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 11.

  lt_zaccdta[] = gt_zaccdta[].
  SORT lt_zaccdta[] BY aggr1.
  DELETE ADJACENT DUPLICATES FROM lt_zaccdta COMPARING aggr1.
  LOOP AT lt_zaccdta INTO ls_zaccdta.
    CLEAR : lt_xaccdta[], lt_xaccdta, ls_xaccdta.
    LOOP AT gt_zaccdta INTO ls_xaccdta WHERE aggr1 = ls_zaccdta-aggr1.
      APPEND ls_xaccdta TO lt_xaccdta.
    ENDLOOP.

    DESCRIBE TABLE lt_xaccdta LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.
    lv_mod    = lv_lines MOD co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      IF lv_mod = 0.
        lv_times = lv_times.
      ELSE.
        lv_times  = lv_times + 1.
      ENDIF.
    ENDIF.

    DO lv_times TIMES.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'parent' ls_zaccdta-aggr1 '' ',' '' '' '',
        '' 'child' '' '' '' '' 'X' '',
        '[' '' '' '' '' '' '' ''.
      CLEAR ls_xaccdta.
      LOOP AT lt_xaccdta INTO ls_xaccdta WHERE aggr1 = ls_zaccdta-aggr1
                                           AND check = space.
        ADD 1 TO lv_count.
        IF lv_count > co_lines.
          lv_count = lv_count - 1.
          EXIT.
        ENDIF.

        IF lv_lines < co_lines.
          lv_xlines = lv_lines.
        ELSE.
          lv_xlines = co_lines.
        ENDIF.

        CLEAR ls_zaccdtm.
        READ TABLE gt_zaccdtm INTO ls_zaccdtm
                              WITH KEY matnr = ls_xaccdta-matnr
                                       charg = ls_xaccdta-charg
                                       senum = ls_xaccdta-senum.
        CLEAR ls_ztspmmdt002.
        READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                  WITH KEY werks = ls_zaccdtm-werks
                                           matnr = ls_zaccdtm-matnr.
        CLEAR ls_mch1.
        READ TABLE gt_mch1 INTO ls_mch1
                          WITH KEY matnr = ls_zaccdtm-matnr
                                   charg = ls_zaccdtm-charg.

        PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                       ls_zaccdtm-charg
                                       ls_mch1-vfdat
                                       ls_xaccdta-senum
                                 CHANGING lv_barcode.

        IF lv_count = lv_xlines.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' '' '' '' ''.
        ELSE.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' ',' '' '' ''.
        ENDIF.
        ls_xaccdta-check = 'X'.
        MODIFY lt_xaccdta FROM ls_xaccdta TRANSPORTING check.
        CLEAR ls_xaccdta.
      ENDLOOP.

      CONCATENATE ls_zaccdta-packdat1(4) '-'
                  ls_zaccdta-packdat1+4(2) '-'
                  ls_zaccdta-packdat1+6(2)
                  INTO lv_packdat1.

      PERFORM f_json_format USING :
        '' '' '' '' ',' '' '' ']',
        '' 'packing_date' lv_packdat1 '' ',' '' '' '',
        '' 'parent_type' 'sekunder' '' '' '' '' '',
        '' '' '' '' '' '' '' '}'.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy '2'
                                ls_zaccdta-aggr1 'Pelaporan Agregasi Barcode' lv_count
                          CHANGING lv_success lv_error.
      CLEAR lv_count.
    ENDDO.
  ENDLOOP.

  WRITE : / 'Success : ', lv_success,
          / 'Error   : ', lv_error.

ENDFORM.                    " F_PACKINGAGGREGATE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ERROR
*&---------------------------------------------------------------------*
FORM f_print_error .
  DATA : lt_error   TYPE STANDARD TABLE OF ty_error,
         ls_error   LIKE LINE OF gt_error,
         lv_process(30).

  IF gt_error[] IS INITIAL.
    CASE gv_error.
      WHEN 2.
        MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
        WRITE :/ 'No data processed'.
      WHEN 3.
        MESSAGE s000(zab) WITH 'You are not authorized' DISPLAY LIKE 'E'.
        WRITE :/ 'You are not authorized'.
    ENDCASE.
  ELSE.
    lt_error[] = gt_error[].
    SORT lt_error BY process.
    DELETE ADJACENT DUPLICATES FROM lt_error COMPARING process.

    LOOP AT lt_error INTO ls_error.
      lv_process  = ls_error-process.
      LOOP AT gt_error INTO ls_error WHERE process = lv_process.
        WRITE :/ ls_error-response.
        CLEAR ls_error.
      ENDLOOP.
      SKIP 1.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_ERROR

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
*&      Form  F_MODIFY_SELECTION
*&---------------------------------------------------------------------*
FORM f_modify_selection .
  CASE 'X'.
    WHEN radio1.
    WHEN OTHERS.
  ENDCASE.

  PERFORM f_radiobutton_display.

  IF sy-uname <> 'TDS_DEV01'.
    PERFORM f_modify_screen USING : 'DWN' '0' '' '' ''.
  ENDIF.

  PERFORM f_modify_screen USING : 'TST' '0' '' '' ''.

  CASE 'X'.
    WHEN radio1.
      text001 = 'Process Order'.
      text002 = 'UD Date'.
      PERFORM f_modify_screen USING : 'SSE' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio2.
      text001 = 'Process Order'.
      text002 = 'UD Date'.
      PERFORM f_modify_screen USING : 'SSE' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio3.
      text001 = 'Process Order'.
      text002 = 'UD Date'.
      PERFORM f_modify_screen USING : 'SSE' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' '',
                                      'SSE' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio5.
      text001 = 'Outbound Delivery'.
      text002 = 'Created on'.
      PERFORM f_modify_screen USING : 'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' '',
                                      'SSE' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio7.
      text001 = 'Outbound Delivery'.
      text002 = 'Created on'.
      PERFORM f_modify_screen USING : 'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio8.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio9.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' '',
                                      'SSE' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PFI' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
    WHEN radio10.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' '',
                                      'SSE' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'DWN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PDE' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INFORMASI
*&---------------------------------------------------------------------*
FORM f_informasi .
  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu,
         lv_procid    TYPE zaccdtu-procid,
         lv_process(30).

  CASE 'X'.
    WHEN radio4.
      lv_procid  = 7.
      lv_process = 'Informasi Sarana Tujuan'.
    WHEN radio6.
      lv_procid  = 12.
      lv_process = 'Daftar Produk Inbound'.
    WHEN radio9.
      lv_procid  = 3.
      lv_process = 'Informasi Lokasi Sarana'.
  ENDCASE.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                WITH KEY procid = lv_procid.

  PERFORM f_http_get USING ls_zaccdtu-uri ls_zaccdtu-proxy
                           lv_process.

ENDFORM.                    " F_INFORMASI

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_GET
*&---------------------------------------------------------------------*
FORM f_http_get USING fu_uri fu_proxy fu_process.
  DATA : temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string,
         ls_request_header  LIKE LINE OF gt_request_header,
         ls_response        TYPE ty_response,
         ls_error           LIKE LINE OF gt_error.

  DATA : lv_offset          TYPE string VALUE '0',
         lv_limit           TYPE string VALUE '10'.

  CLEAR : gt_request_body[], gt_response_body[],
          gt_response_header[], gt_request_header[].

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  CASE 'X'.
    WHEN radio4.
      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'aktif' 'true' 'X' ',' '' '' '',
        '' 'offset' lv_offset 'X' ',' '' '' '',
        '' 'limit' lv_limit 'X' '' '' '' '',
        '' '' '' '' '' '' '' '}'.

    WHEN radio6.
      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'offset' lv_offset 'X' ',' '' '' '',
        '' 'limit' lv_limit 'X' '' '' '' '',
        '' '' '' '' '' '' '' '}'.

    WHEN radio9.
      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'offset' lv_offset 'X' ',' '' '' '',
        '' 'limit' lv_limit 'X' '' '' '' '',
        '' '' '' '' '' '' '' '}'.
  ENDCASE.

  PERFORM f_http_get_via_apo TABLES   gt_request_header
                                      gt_request_body
                                      gt_response_header
                                      gt_response_body
                             USING    fu_uri fu_proxy ''
                             CHANGING status_code status_text.

*  CALL FUNCTION 'HTTP_GET'
*    EXPORTING
*      absolute_uri                = fu_uri
*      request_entity_body_length  = 300
*      proxy                       = fu_proxy
*      blankstocrlf                = 'X'
*    IMPORTING
*      status_code                 = status_code
*      status_text                 = status_text
*      response_entity_body_length = len
*    TABLES
*      request_entity_body         = gt_request_body
*      response_entity_body        = gt_response_body
*      response_headers            = gt_response_header
*      request_headers             = gt_request_header
*    EXCEPTIONS
*      connect_failed              = 1
*      timeout                     = 2
*      internal_error              = 3
*      tcpip_error                 = 4
*      data_error                  = 5
*      system_failure              = 6
*      communication_failure       = 7
*      OTHERS                      = 8.

  IF sy-subrc = 0.
    PERFORM f_read_response_body CHANGING ls_response.
    IF ls_response-status = 'false'.
*      ls_error-description    = fu_description.
      ls_error-process        = fu_process.
      CONCATENATE ls_response-statuscode ls_response-message
      INTO ls_error-response
      SEPARATED BY space.
      APPEND ls_error TO gt_error.
      CLEAR ls_error.
    ELSE.
      LOOP AT gt_response_body INTO temp_json.
        CONDENSE : temp_json, lv_str.
        CONCATENATE lv_str temp_json INTO lv_str.
        REPLACE ALL OCCURRENCES OF REGEX '"badan_usaha":null' IN lv_str WITH '"badan_usaha":0'.
        REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '" "'.
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

      CASE 'X'.
        WHEN radio4.
          TRY.
              CALL TRANSFORMATION zacc_tujuan_v3x SOURCE XML xml
                                                  RESULT tujuan = gs_tujuan.
            CATCH cx_root INTO ls_rif_ex.
              ls_var_text = ls_rif_ex->get_text( ).
              WRITE: / 'Message Error XML to Table: ', ls_var_text.
          ENDTRY.

        WHEN radio6.

        WHEN radio9.
          TRY.
              CALL TRANSFORMATION zacc_info_v3x SOURCE XML xml
                                                RESULT sarana = gs_lokasi.
            CATCH cx_root INTO ls_rif_ex.
              ls_var_text = ls_rif_ex->get_text( ).
              WRITE: / 'Message Error XML to Table: ', ls_var_text.
          ENDTRY.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_HTTP_GET

*&---------------------------------------------------------------------*
*&      Form  F_KIRIM_PRODUK
*&---------------------------------------------------------------------*
FORM f_kirim_produk USING fu_docat.
  DATA : lv_email     TYPE  sbcbody-body,
         lv_password  TYPE  sbcbody-body.

  DATA : lv_success   TYPE i,
         lv_error     TYPE i.

  lv_email      = gs_zaccdtl-smtp_addr.
  lv_password   = gs_zaccdtl-bcode.

*****  PERFORM f_moving_product USING 'BPOM' '2' lv_email lv_password fu_docat
*****                                 so_docno-low pa_desti '3' pa_test
*****                           CHANGING lv_success lv_error.

  PERFORM f_moving_product_all USING 'BPOM' '2' lv_email lv_password fu_docat
                                     so_docno-low pa_desti '3' pa_test
                               CHANGING lv_success lv_error.

*****  CALL FUNCTION 'ZACCFM_MOVING_PRODUCT'
*****    EXPORTING
*****      pi_company  = 'BPOM'
*****      pi_procid   = 2
*****      pi_email    = lv_email
*****      pi_password = lv_password
*****      pi_docat    = fu_docat
*****      pi_docno    = so_docno-low
*****      pi_tujuan   = pa_desti
*****      pi_stbpom   = '3'
*****      pi_test     = pa_test
*****    IMPORTING
*****      pe_success  = lv_success
*****      pe_error    = lv_error
*****    TABLES
*****      pt_senum    = so_senum.

  WRITE : / 'Success : ', lv_success,
          / 'Error   : ', lv_error.
ENDFORM.                    " F_KIRIM_PRODUK

*&---------------------------------------------------------------------*
*&      Form  F_TERIMA_PRODUK
*&---------------------------------------------------------------------*
FORM f_terima_produk USING fu_docat.
  DATA : lv_email     TYPE  sbcbody-body,
         lv_password  TYPE  sbcbody-body.

  DATA : lv_success   TYPE i,
         lv_error     TYPE i.

  lv_email      = gs_zaccdtl-smtp_addr.
  lv_password   = gs_zaccdtl-bcode.

  PERFORM f_moving_product USING 'BPOM' 13 lv_email lv_password fu_docat
                                 so_docno-low pa_desti '4' pa_test
                           CHANGING lv_success lv_error.

*****  CALL FUNCTION 'ZACCFM_MOVING_PRODUCT'
*****    EXPORTING
*****      pi_company  = 'BPOM'
*****      pi_procid   = 13
*****      pi_email    = lv_email
*****      pi_password = lv_password
*****      pi_docat    = fu_docat
*****      pi_docno    = so_docno-low
*****      pi_stbpom   = '4'
*****      pi_test     = pa_test
*****    IMPORTING
*****      pe_success  = lv_success
*****      pe_error    = lv_error
*****    TABLES
*****      pt_senum    = so_senum.

  WRITE : / 'Success : ', lv_success,
          / 'Error   : ', lv_error.
ENDFORM.                    " F_TERIMA_PRODUK

*&---------------------------------------------------------------------*
*&      Form  F_HAPUS_BARCODE
*&---------------------------------------------------------------------*
FORM f_hapus_barcode TABLES   ft_zaccdta    STRUCTURE zaccdta
                     USING    fu_level.
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         lt_xaccdta           TYPE STANDARD TABLE OF ty_zaccdta,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string.

  DATA : lv_success           TYPE i,
         lv_error             TYPE i.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 8.

  IF ft_zaccdta[] IS NOT INITIAL.
    lt_xaccdta[] = ft_zaccdta[].

    DESCRIBE TABLE lt_xaccdta LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.
    lv_mod    = lv_lines MOD co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      IF lv_mod = 0.
        lv_times  = lv_times.
      ELSE.
        lv_times  = lv_times + 1.
      ENDIF.
    ENDIF.

    DO lv_times TIMES.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'barcode' '' '' '' '' 'X' '',
        '[' '' '' '' '' '' '' ''.

      LOOP AT lt_xaccdta INTO ls_xaccdta WHERE check = space.
        ADD 1 TO lv_count.
        IF lv_count > co_lines.
          lv_count = lv_count - 1.
          EXIT.
        ENDIF.

        IF lv_lines < co_lines.
          lv_xlines = lv_lines.
        ELSE.
          lv_xlines = co_lines.
        ENDIF.

        CASE fu_level.
          WHEN 'primer'.
            CLEAR ls_zaccdtm.
            READ TABLE gt_zaccdtm INTO ls_zaccdtm
                                  WITH KEY matnr = ls_xaccdta-matnr
                                           charg = ls_xaccdta-charg
                                           senum = ls_xaccdta-senum.
            CLEAR ls_ztspmmdt002.
            READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                      WITH KEY werks = ls_zaccdtm-werks
                                               matnr = ls_zaccdtm-matnr.
            CLEAR ls_mch1.
            READ TABLE gt_mch1 INTO ls_mch1
                              WITH KEY matnr = ls_zaccdtm-matnr
                                       charg = ls_zaccdtm-charg.

            PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                           ls_zaccdtm-charg
                                           ls_mch1-vfdat
                                           ls_xaccdta-senum
                                     CHANGING lv_barcode.

          WHEN OTHERS.
            lv_barcode  = ls_xaccdta-senum.
        ENDCASE.

        IF lv_count = lv_xlines.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' '' '' '' ''.
        ELSE.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' ',' '' '' ''.
        ENDIF.

        ls_xaccdta-check = 'X'.
        MODIFY lt_xaccdta FROM ls_xaccdta TRANSPORTING check.
        CLEAR ls_xaccdta.
      ENDLOOP.

      PERFORM f_json_format USING :
        '' '' '' '' ',' '' '' ']',
        '' 'barcode_level' fu_level '' '' '' '' '',
        '' '' '' '' '' '' '' '}'.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy 'X'
                                '' 'Hapus Barcode' lv_count
                          CHANGING lv_success lv_error.
    ENDDO.
  ENDIF.
ENDFORM.                    " F_HAPUS_BARCODE

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 101.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CASE 'X'.
    WHEN radio4.
      CREATE DATA lt_dyn_table TYPE ty_sarana1.
    WHEN radio6.
    WHEN radio9.
      CREATE DATA lt_dyn_table TYPE ty_sarana2.
    WHEN radio10.
      CREATE DATA lt_dyn_table TYPE ty_addlokasi.
  ENDCASE.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'ID'.
        PERFORM f_change_title USING 'ID'
                               CHANGING ls_fieldcat.
      WHEN 'NAMA_SARANA'.
        PERFORM f_change_title USING 'Nama Sarana'
                               CHANGING ls_fieldcat.
      WHEN 'ALAMAT'.
        PERFORM f_change_title USING 'Alamat'
                               CHANGING ls_fieldcat.
      WHEN 'ALAMAT_REKANAN'.
        PERFORM f_change_title USING 'Alamat Rekanan'
                               CHANGING ls_fieldcat.
      WHEN 'NO_TELP'.
        PERFORM f_change_title USING 'No. Telp'
                               CHANGING ls_fieldcat.
      WHEN 'FAX'.
        PERFORM f_change_title USING 'Fax'
                               CHANGING ls_fieldcat.
      WHEN 'LATITUDE'.
        PERFORM f_change_title USING 'Latitude'
                               CHANGING ls_fieldcat.
      WHEN 'LONGITUDE'.
        PERFORM f_change_title USING 'Longitude'
                               CHANGING ls_fieldcat.
      WHEN 'IS_DEFAULT'.
        CONTINUE.
        PERFORM f_change_title USING 'Default'
                               CHANGING ls_fieldcat.

    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_main_fieldcat
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc = 0.
    ASSIGN lt_dyn_table->* TO <fs_tout>.
    CREATE DATA ls_line LIKE LINE OF <fs_tout>.
    ASSIGN ls_line->* TO <fs_sout>.
  ENDIF.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_sarana1           TYPE STANDARD TABLE OF ty_sarana1,
         ls_sarana1           LIKE LINE OF lt_sarana1,
         lt_sarana2           TYPE STANDARD TABLE OF ty_sarana2,
         ls_sarana2           LIKE LINE OF lt_sarana2.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_mod               TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string.

  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_request_header    LIKE LINE OF gt_request_header.

  DATA : lv_alamat            TYPE string,
         lv_telp              TYPE string,
         lv_fax               TYPE string,
         lv_latitude          TYPE string,
         lv_longitude         TYPE string.

  DATA : lv_success           TYPE i,
         lv_error             TYPE i.

  FIELD-SYMBOLS <fs>   TYPE ANY.

  CASE 'X'.
    WHEN radio4.
      lt_sarana1[] = gs_tujuan-items[].
      LOOP AT lt_sarana1 INTO ls_sarana1.
        ASSIGN COMPONENT 'ID' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana1-id.
        ASSIGN COMPONENT 'NAMA_SARANA' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana1-nama_sarana.
        ASSIGN COMPONENT 'ALAMAT' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana1-alamat.
        APPEND <fs_sout> TO <fs_tout>.
        CLEAR <fs_sout>.
      ENDLOOP.

    WHEN radio6.

    WHEN radio9.
      lt_sarana2[] = gs_lokasi-items[].
      LOOP AT lt_sarana2 INTO ls_sarana2.
        ASSIGN COMPONENT 'ID' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-id.
        ASSIGN COMPONENT 'ALAMAT_REKANAN' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-alamat_rekanan.
        ASSIGN COMPONENT 'NO_TELP' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-no_telp.
        ASSIGN COMPONENT 'FAX' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-fax.
        ASSIGN COMPONENT 'LATITUDE' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-latitude.
        ASSIGN COMPONENT 'LONGITUDE' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_sarana2-longitude.
        APPEND <fs_sout> TO <fs_tout>.
        CLEAR <fs_sout>.
      ENDLOOP.

    WHEN radio10.
      READ TABLE gt_zaccdtu INTO ls_zaccdtu
                            WITH KEY procid = 4.

      DESCRIBE TABLE <fs_tout> LINES lv_lines.
      lv_times  = lv_lines DIV co_lines.
      lv_mod    = lv_lines MOD co_lines.

      IF lv_lines = co_lines.
        lv_times  = 1.
      ELSE.
        IF lv_mod = 0.
          lv_times  = lv_times.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.
      ENDIF.

      LOOP AT <fs_tout> ASSIGNING <fs_sout>.
        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        PERFORM f_json_format USING :
          '{' '' '' '' '' '' '' '',
          '' 'token' gv_token '' ',' '' '' '',
          '' 'alamat' lv_alamat '' ',' '' '' '',
          '' 'no_telp' lv_telp '' ',' '' '' '',
          '' 'fax' lv_fax '' ',' '' '' '',
          '' 'latitude' lv_latitude '' ',' '' '' '',
          '' 'longitude' lv_longitude '' '' '' '' '',
          '' '' '' '' '' '' '' '}'.

        PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy ''
                                  '' 'Penambahan Lokasi Sarana' lv_count
                            CHANGING lv_success lv_error.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  APPEND '&POS' TO fcode.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  CASE 'X'.
    WHEN radio4.
      SET TITLEBAR 'TITLE01'.
    WHEN radio6.
      SET TITLEBAR 'TITLE03'.
    WHEN radio9.
      SET TITLEBAR 'TITLE02'.
  ENDCASE.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_tout>[]
        it_fieldcatalog      = gt_main_fieldcat[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'ID' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm       TYPE sy-ucomm,
         lv_valid       TYPE c,
         lt_fidx        TYPE lvc_t_fidx,
         ls_fidx        TYPE sy-tabix.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

*    WHEN '&ALL'.
*      CALL METHOD g_tabgrid->check_changed_data
*        IMPORTING
*          e_valid = lv_valid.
*
*      IF lv_valid IS NOT INITIAL.
*        PERFORM f_select USING 'X'.
*      ENDIF.
*
*    WHEN '&SAL'.
*      CALL METHOD g_tabgrid->check_changed_data
*        IMPORTING
*          e_valid = lv_valid.
*
*      IF lv_valid IS NOT INITIAL.
*        PERFORM f_select USING ''.
*      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

*    WHEN '&OUP' OR '&ODN' OR '&OL0'.
*      CALL METHOD g_tabgrid->set_function_code
*        CHANGING
*          c_ucomm = lv_ucomm.
*
*      gt_xout[] = gt_out[].

*    WHEN '&ILT'.
*      CALL METHOD g_tabgrid->set_function_code
*        CHANGING
*          c_ucomm = lv_ucomm.
*
*      CLEAR : gt_filter[].
*      CALL METHOD g_tabgrid->get_filtered_entries
*        IMPORTING
*          et_filtered_entries = lt_fidx.
*
*      IF lt_fidx[] IS INITIAL.
*        PERFORM f_select USING ''.
*      ELSE.
*        LOOP AT lt_fidx INTO ls_fidx.
*          ls_filter-index = ls_fidx.
*          APPEND ls_filter TO gt_filter.
*        ENDLOOP.
*      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .

ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TITLE
*&---------------------------------------------------------------------*
FORM f_change_title  USING    fu_title
                     CHANGING fs_fieldcat    TYPE lvc_s_fcat.

  fs_fieldcat-reptext      = fu_title.
  fs_fieldcat-scrtext_l    = fu_title.
  fs_fieldcat-scrtext_m    = fu_title.
  fs_fieldcat-scrtext_s    = fu_title.
ENDFORM.                    " F_CHANGE_TITLE

*&---------------------------------------------------------------------*
*&      Form  F_INFORMASI_LOKASI_SARANA
*&---------------------------------------------------------------------*
FORM f_informasi_lokasi_sarana .

ENDFORM.                    " F_INFORMASI_LOKASI_SARANA

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
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         ls_request_header    LIKE LINE OF gt_request_header,
         lv_barcode           TYPE string,
         lv_aggr              TYPE zaggr.

  CLEAR : lt_xaccdta[], lt_xaccdta, ls_xaccdta.
  LOOP AT ft_zaccdta INTO ls_zaccdta.
    MOVE-CORRESPONDING ls_zaccdta TO ls_xaccdta.
    APPEND ls_xaccdta TO lt_xaccdta.
    CLEAR ls_xaccdta.
  ENDLOOP.

  DESCRIBE TABLE lt_xaccdta LINES lv_lines.
  lv_times  = lv_lines DIV co_lines.
  lv_mod    = lv_lines MOD co_lines.

  IF lv_lines = co_lines.
    lv_times  = 1.
  ELSE.
    IF lv_mod = 0.
      lv_times  = lv_times.
    ELSE.
      lv_times  = lv_times + 1.
    ENDIF.
  ENDIF.

  DO lv_times TIMES.
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
      IF lv_count > co_lines.
        lv_count = lv_count - 1.
        EXIT.
      ENDIF.

      IF lv_lines < co_lines.
        lv_xlines = lv_lines.
      ELSE.
        lv_xlines = co_lines.
      ENDIF.

      CLEAR ls_zaccdtm.
      READ TABLE gt_zaccdtm INTO ls_zaccdtm
                            WITH KEY matnr = ls_xaccdta-matnr
                                     charg = ls_xaccdta-charg
                                     senum = ls_xaccdta-senum.
      CLEAR ls_ztspmmdt002.
      READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                WITH KEY werks = ls_zaccdtm-werks
                                         matnr = ls_zaccdtm-matnr.
      CLEAR ls_mch1.
      READ TABLE gt_mch1 INTO ls_mch1
                        WITH KEY matnr = ls_zaccdtm-matnr
                                 charg = ls_zaccdtm-charg.

      CASE fu_level.
        WHEN 'tersier'.
          lv_aggr   = ls_xaccdta-aggr2.
        WHEN 'sekunder'.
          lv_aggr   = ls_xaccdta-aggr1.
      ENDCASE.

      PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                     ls_zaccdtm-charg
                                     ls_mch1-vfdat
                                     lv_aggr
                               CHANGING lv_barcode.

      IF lv_count = lv_xlines.
        PERFORM f_json_format USING :
          '' '' lv_barcode '' '' '' '' ''.
      ELSE.
        PERFORM f_json_format USING :
          '' '' lv_barcode '' ',' '' '' ''.
      ENDIF.
      ls_xaccdta-check = 'X'.
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
    CLEAR lv_count.
  ENDDO.
ENDFORM.                    " F_REGISTER_PARENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_F4
*&---------------------------------------------------------------------*
FORM f_get_f4  CHANGING fc_filnm.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
    IMPORTING
      file_name     = fc_filnm.
ENDFORM.                    " F_GET_F4

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_upload_data .
  TYPES : BEGIN OF ty_excel,
           row   LIKE alsmex_tabline-row,
           col   LIKE alsmex_tabline-col,
           value LIKE alsmex_tabline-value,
         END OF ty_excel.

  DATA : lt_excel   TYPE STANDARD TABLE OF ty_excel,
         ls_excel   LIKE LINE OF lt_excel.

  FIELD-SYMBOLS : <fs>    TYPE ANY.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pa_filnm
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT lt_excel BY row col.
  LOOP AT lt_excel INTO ls_excel.
    CASE ls_excel-col.
      WHEN '0001'.
        ASSIGN COMPONENT 'ALAMAT' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_excel-value.
      WHEN '0002'.
        ASSIGN COMPONENT 'NO_TELP' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_excel-value.
      WHEN '0003'.
        ASSIGN COMPONENT 'FAX' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_excel-value.
      WHEN '0004'.
        ASSIGN COMPONENT 'LATITUDE' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_excel-value.
      WHEN '0005'.
        ASSIGN COMPONENT 'LONGITUDE' OF STRUCTURE <fs_sout> TO <fs>.
        <fs> = ls_excel-value.
    ENDCASE.

    AT END OF row.
      APPEND <fs_sout> TO <fs_tout>.
      CLEAR <fs_sout>.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_DATA

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
    gv_error = 2.
  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.

*    IF radio5 IS NOT INITIAL.
*      IF sscrfields-ucomm <> 'RAD'.
*        IF pa_desti IS INITIAL.
*          PERFORM f_error_message USING 'PDE' ''.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    IF sscrfields-ucomm = 'RAD'.
*      CASE 'X'.
*        WHEN radio9.
*          IF gs_zaccdtl-zopt01 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio10.
*          IF gs_zaccdtl-zopt02 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio1.
*          IF gs_zaccdtl-zopt03 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio2.
*          IF gs_zaccdtl-zopt04 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio3.
*          IF gs_zaccdtl-zopt05 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio4.
*          IF gs_zaccdtl-zopt06 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio5.
*          IF gs_zaccdtl-zopt07 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio6.
*          IF gs_zaccdtl-zopt08 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio7.
*          IF gs_zaccdtl-zopt09 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*        WHEN radio8.
*          IF gs_zaccdtl-zopt10 IS INITIAL.
*            PERFORM f_error_message USING 'PWE' 'You are not authorized'.
*          ENDIF.
*      ENDCASE.
*    ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    IF lv_mess <> 'You are not authorized'.
      LOOP AT SCREEN.
        IF screen-group1 = fu_group.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_RADIOBUTTON_DISPLAY
*&---------------------------------------------------------------------*
FORM f_radiobutton_display .
  IF sy-dynnr = '9000'.
    IF gs_zaccdtl-zopt01 IS INITIAL.
      CLEAR radio9.
      PERFORM f_modify_screen USING : 'RA9' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt02 IS INITIAL.
      CLEAR radio10.
      PERFORM f_modify_screen USING : 'RA0' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt03 IS INITIAL.
      CLEAR radio1.
      PERFORM f_modify_screen USING : 'RA1' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt04 IS INITIAL.
      CLEAR radio2.
      PERFORM f_modify_screen USING : 'RA2' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt05 IS INITIAL.
      CLEAR radio3.
      PERFORM f_modify_screen USING : 'RA3' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt06 IS INITIAL.
      CLEAR radio4.
      PERFORM f_modify_screen USING : 'RA4' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt07 IS INITIAL.
      CLEAR radio5.
      PERFORM f_modify_screen USING : 'RA5' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt08 IS INITIAL.
      CLEAR radio6.
      PERFORM f_modify_screen USING : 'RA6' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt09 IS INITIAL.
      CLEAR radio7.
      PERFORM f_modify_screen USING : 'RA7' '0' '' '' ''.
    ENDIF.
    IF gs_zaccdtl-zopt10 IS INITIAL.
      CLEAR radio8.
      PERFORM f_modify_screen USING : 'RA8' '0' '' '' ''.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RADIOBUTTON_DISPLAY

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
*&      Form  F_HTTP_GET_VIA_APO
*&---------------------------------------------------------------------*
FORM f_http_get_via_apo  TABLES   ft_request_header
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
    WHERE sysid   = 'DEV'    "sy-sysid
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
      CALL FUNCTION 'ZRFC_TTAC_HTTP_GET'
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
ENDFORM.                    " F_HTTP_GET_VIA_APO

*&---------------------------------------------------------------------*
*&      Form  F_MOVING_PRODUCT
*&---------------------------------------------------------------------*
FORM f_moving_product  USING    fu_company fu_procid fu_email fu_password
                                fu_docat fu_docno fu_tujuan fu_stbpom fu_test
                       CHANGING fc_success fc_error.

  TYPES : BEGIN OF ty_zaccdtd.
          INCLUDE STRUCTURE zaccdtd.
  TYPES : check,
          END OF ty_zaccdtd.

  DATA : lt_s501              TYPE STANDARD TABLE OF s501,
         lt_zaccdtd           TYPE STANDARD TABLE OF zaccdtd,
         lt_xaccdtd           TYPE STANDARD TABLE OF ty_zaccdtd,
         lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdtm           TYPE STANDARD TABLE OF zaccdtm,
         lt_ztspmmdt002       TYPE STANDARD TABLE OF ztspmmdt002,
         lt_mch1              TYPE STANDARD TABLE OF mch1,
         ls_request_header    TYPE sbcheader,
         ls_xaccdtd           LIKE LINE OF lt_xaccdtd,
         ls_zaccdta           LIKE LINE OF lt_zaccdta,
         ls_ztspmmdt002       LIKE LINE OF lt_ztspmmdt002,
         ls_mch1              LIKE LINE OF lt_mch1,
         ls_zaccdtm           LIKE LINE OF lt_zaccdtm,
         ls_zaccdtd           LIKE LINE OF lt_zaccdtd,
         ls_zaccdtu           TYPE zaccdtu,
         lt_error             TYPE STANDARD TABLE OF zsterror,
         ls_error             LIKE LINE OF lt_error,
         lt_xerror            TYPE STANDARD TABLE OF zsterror,
         ls_xerror            LIKE LINE OF lt_xerror.
  .
  DATA : lv_token             TYPE string,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string,
         lv_process(30).

  DATA : lv_stbpom            TYPE s501-stbpom.

  CALL FUNCTION 'ZACCFM_LOGIN'
    EXPORTING
      pi_company     = fu_company
      pi_procid      = 1
      pi_email       = fu_email
      pi_password    = fu_password
    IMPORTING
      pe_token       = lv_token
    EXCEPTIONS
      failed_request = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM zaccdtu
      INTO CORRESPONDING FIELDS OF ls_zaccdtu
      WHERE company = fu_company
        AND procid  = fu_procid.

    SELECT *
      FROM s501
      INTO CORRESPONDING FIELDS OF TABLE lt_s501
      WHERE docat   = fu_docat
        AND docno   = fu_docno
        AND stbpom  = space.

    IF lt_s501[] IS NOT INITIAL.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
        FOR ALL ENTRIES IN lt_s501
        WHERE docat = lt_s501-docat
          AND docno = lt_s501-docno
          AND senum IN so_senum
          AND xloek = space.

      IF lt_zaccdtd[] IS NOT INITIAL.
        SELECT *
          FROM zaccdta
          INTO CORRESPONDING FIELDS OF TABLE lt_zaccdta
          FOR ALL ENTRIES IN lt_zaccdtd
          WHERE senum = lt_zaccdtd-senum.

        IF lt_zaccdta[] IS NOT INITIAL.
          LOOP AT lt_zaccdtd INTO ls_zaccdtd.
            READ TABLE lt_zaccdta INTO ls_zaccdta
                                  WITH KEY senum = ls_zaccdtd-senum.
            IF sy-subrc <> 0.
              DELETE TABLE lt_zaccdtd FROM ls_zaccdtd.
            ENDIF.
          ENDLOOP.

          SELECT *
            FROM zaccdtm
            INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtm
            FOR ALL ENTRIES IN lt_zaccdta
            WHERE matnr = lt_zaccdta-matnr
              AND charg = lt_zaccdta-charg
              AND senum = lt_zaccdta-senum.

          IF lt_zaccdtm[] IS NOT INITIAL.
            SELECT *
              FROM ztspmmdt002
              INTO CORRESPONDING FIELDS OF TABLE lt_ztspmmdt002
              FOR ALL ENTRIES IN lt_zaccdtm
              WHERE matnr = lt_zaccdtm-matnr
                AND werks = lt_zaccdtm-werks.

            SELECT *
              FROM mch1
              INTO CORRESPONDING FIELDS OF TABLE lt_mch1
              FOR ALL ENTRIES IN lt_zaccdtm
              WHERE matnr = lt_zaccdtm-matnr
                AND charg = lt_zaccdtm-charg.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    lt_xaccdtd[] = lt_zaccdtd[].
    DESCRIBE TABLE lt_xaccdtd LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.
    lv_mod    = lv_lines MOD co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      IF lv_mod = 0.
        lv_times  = lv_times.
      ELSE.
        lv_times  = lv_times + 1.
      ENDIF.
    ENDIF.

    DO lv_times TIMES.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      CASE fu_docat.
* Terima Produk
        WHEN 'INB' OR 'PRO'.
          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' lv_token '' ',' '' '' '',
            '' 'barcode' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.
* Kirim Produk
        WHEN 'DO'.
          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' lv_token '' ',' '' '' '',
            '' 'id_sarana_tujuan' fu_tujuan 'X' ',' '' '' '',
            '' 'barcode' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.
      ENDCASE.

      LOOP AT lt_xaccdtd INTO ls_xaccdtd WHERE check = space.
        ADD 1 TO lv_count.
        IF lv_count > co_lines.
          lv_count = lv_count - 1.
          EXIT.
        ENDIF.

        IF lv_lines < co_lines.
          lv_xlines = lv_lines.
        ELSE.
          lv_xlines = co_lines.
        ENDIF.

        CLEAR ls_zaccdta.
        READ TABLE lt_zaccdta INTO ls_zaccdta
                              WITH KEY senum = ls_xaccdtd-senum.

        CLEAR ls_zaccdtm.
        READ TABLE lt_zaccdtm INTO ls_zaccdtm
                              WITH KEY matnr = ls_zaccdta-matnr
                                       charg = ls_zaccdta-charg
                                       senum = ls_zaccdta-senum.
        CLEAR ls_ztspmmdt002.
        READ TABLE lt_ztspmmdt002 INTO ls_ztspmmdt002
                                  WITH KEY werks = ls_zaccdtm-werks
                                           matnr = ls_zaccdtm-matnr.
        CLEAR ls_mch1.
        READ TABLE lt_mch1 INTO ls_mch1
                          WITH KEY matnr = ls_zaccdtm-matnr
                                   charg = ls_zaccdtm-charg.

        PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                       ls_zaccdtm-charg
                                       ls_mch1-vfdat
                                       ls_zaccdta-senum
                                 CHANGING lv_barcode.

        IF lv_count = lv_xlines.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' '' '' '' ''.
        ELSE.
          PERFORM f_json_format USING :
            '' '' lv_barcode '' ',' '' '' ''.
        ENDIF.

        ls_xaccdtd-check = 'X'.
        MODIFY lt_xaccdtd FROM ls_xaccdtd TRANSPORTING check.
        CLEAR ls_xaccdtd.
      ENDLOOP.

      PERFORM f_json_format USING :
        '' '' '' '' '' '' '' ']',
        '' '' '' '' '' '' '' '}'.

      CASE fu_docat.
        WHEN 'INB'.
          lv_process = 'Terima Barang'.
        WHEN 'DO' OR 'PRO'.
          lv_process = 'Kirim Barang'.
      ENDCASE.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy fu_stbpom
                                '' lv_process lv_count
                          CHANGING fc_success fc_error.

      CLEAR : lv_count.
    ENDDO.
  ENDIF.

  IF lt_error[] IS NOT INITIAL.
    lt_xerror[] = lt_error[].
    SORT lt_xerror BY process.
    DELETE ADJACENT DUPLICATES FROM lt_xerror COMPARING process.

    LOOP AT lt_xerror INTO ls_xerror.
      lv_process  = ls_xerror-process.
      LOOP AT lt_error INTO ls_error WHERE process = lv_process.
        WRITE :/ ls_error-response.
        CLEAR ls_error.
      ENDLOOP.
      SKIP 1.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MOVING_PRODUCT

*&---------------------------------------------------------------------*
*&      Form  F_MOVING_PRODUCT_ALL
*&---------------------------------------------------------------------*
FORM f_moving_product_all  USING    fu_company fu_procid fu_email fu_password
                                    fu_docat fu_docno fu_tujuan fu_stbpom fu_test
                           CHANGING fc_success fc_error.
  TYPES : BEGIN OF ty_zaccdtd.
          INCLUDE STRUCTURE zaccdtd.
  TYPES : check,
          END OF ty_zaccdtd.

  DATA : "lt_zaccdtd           TYPE STANDARD TABLE OF zaccdtd,
         lt_xaccdtd           TYPE STANDARD TABLE OF ty_zaccdtd,
         lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdtm           TYPE STANDARD TABLE OF zaccdtm,
         lt_ztspmmdt002       TYPE STANDARD TABLE OF ztspmmdt002,
         lt_mch1              TYPE STANDARD TABLE OF mch1,
         ls_request_header    TYPE sbcheader,
         ls_xaccdtd           LIKE LINE OF lt_xaccdtd,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_ztspmmdt002       LIKE LINE OF lt_ztspmmdt002,
         ls_mch1              LIKE LINE OF lt_mch1,
         ls_zaccdtm           LIKE LINE OF lt_zaccdtm,
         ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_zaccdtu           TYPE zaccdtu,
         lt_error             TYPE STANDARD TABLE OF zsterror,
         ls_error             LIKE LINE OF lt_error,
         lt_xerror            TYPE STANDARD TABLE OF zsterror,
         ls_xerror            LIKE LINE OF lt_xerror.
  .
  DATA : "lv_token             TYPE string,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_mod               TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string,
         lv_process(30).

  DATA : lv_stbpom            TYPE s501-stbpom.

*****  CALL FUNCTION 'ZACCFM_LOGIN'
*****    EXPORTING
*****      pi_company     = fu_company
*****      pi_procid      = 1
*****      pi_email       = fu_email
*****      pi_password    = fu_password
*****    IMPORTING
*****      pe_token       = lv_token
*****    EXCEPTIONS
*****      failed_request = 1
*****      OTHERS         = 2.
*****
*****  IF sy-subrc = 0.
  SELECT SINGLE *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF ls_zaccdtu
    WHERE company = fu_company
      AND procid  = fu_procid.

  SELECT *
    FROM s501
    INTO CORRESPONDING FIELDS OF TABLE gt_s501
    WHERE docat   = fu_docat
      AND docno   = fu_docno
      AND stbpom  = space.

  IF gt_s501[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtd
      INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
      FOR ALL ENTRIES IN gt_s501
      WHERE docat = gt_s501-docat
        AND docno = gt_s501-docno
        AND senum IN so_senum
        AND xloek = space.

    IF gt_zaccdtd[] IS NOT INITIAL.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE lt_zaccdta
        FOR ALL ENTRIES IN gt_zaccdtd
        WHERE senum = gt_zaccdtd-senum.

      IF lt_zaccdta[] IS NOT INITIAL.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd.
          READ TABLE lt_zaccdta INTO ls_zaccdta
                                WITH KEY senum = ls_zaccdtd-senum.
          IF sy-subrc <> 0.
            DELETE TABLE gt_zaccdtd FROM ls_zaccdtd.
          ENDIF.
        ENDLOOP.

        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtm
          FOR ALL ENTRIES IN lt_zaccdta
          WHERE matnr = lt_zaccdta-matnr
            AND charg = lt_zaccdta-charg
            AND senum = lt_zaccdta-senum.

        IF lt_zaccdtm[] IS NOT INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_ztspmmdt002
            FOR ALL ENTRIES IN lt_zaccdtm
            WHERE matnr = lt_zaccdtm-matnr
              AND werks = lt_zaccdtm-werks.

          SELECT *
            FROM mch1
            INTO CORRESPONDING FIELDS OF TABLE lt_mch1
            FOR ALL ENTRIES IN lt_zaccdtm
            WHERE matnr = lt_zaccdtm-matnr
              AND charg = lt_zaccdtm-charg.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  lt_xaccdtd[] = gt_zaccdtd[].
  DESCRIBE TABLE lt_xaccdtd LINES lv_lines.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  CASE fu_docat.
* Terima Produk
    WHEN 'INB' OR 'PRO'.
      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'barcode' '' '' '' '' 'X' '',
        '[' '' '' '' '' '' '' ''.
* Kirim Produk
    WHEN 'DO'.
      PERFORM f_json_format USING :
        '{' '' '' '' '' '' '' '',
        '' 'token' gv_token '' ',' '' '' '',
        '' 'id_sarana_tujuan' fu_tujuan 'X' ',' '' '' '',
        '' 'barcode' '' '' '' '' 'X' '',
        '[' '' '' '' '' '' '' ''.
  ENDCASE.

  CLEAR lv_count.
  LOOP AT lt_xaccdtd INTO ls_xaccdtd WHERE check = space.
    ADD 1 TO lv_count.
    CLEAR ls_zaccdta.
    READ TABLE lt_zaccdta INTO ls_zaccdta
                          WITH KEY senum = ls_xaccdtd-senum.

    CLEAR ls_zaccdtm.
    READ TABLE lt_zaccdtm INTO ls_zaccdtm
                          WITH KEY matnr = ls_zaccdta-matnr
                                   charg = ls_zaccdta-charg
                                   senum = ls_zaccdta-senum.
    CLEAR ls_ztspmmdt002.
    READ TABLE lt_ztspmmdt002 INTO ls_ztspmmdt002
                              WITH KEY werks = ls_zaccdtm-werks
                                       matnr = ls_zaccdtm-matnr.
    CLEAR ls_mch1.
    READ TABLE lt_mch1 INTO ls_mch1
                      WITH KEY matnr = ls_zaccdtm-matnr
                               charg = ls_zaccdtm-charg.

    PERFORM f_create_barcode USING ls_ztspmmdt002-nie
                                   ls_zaccdtm-charg
                                   ls_mch1-vfdat
                                   ls_zaccdta-senum
                             CHANGING lv_barcode.

    IF lv_count = lv_lines.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' ',' '' '' ''.
    ENDIF.

    ls_xaccdtd-check = 'X'.
    MODIFY lt_xaccdtd FROM ls_xaccdtd TRANSPORTING check.
    CLEAR ls_xaccdtd.
  ENDLOOP.

  PERFORM f_json_format USING :
    '' '' '' '' '' '' '' ']',
    '' '' '' '' '' '' '' '}'.

  CASE fu_docat.
    WHEN 'INB'.
      lv_process = 'Terima Barang'.
    WHEN 'DO' OR 'PRO'.
      lv_process = 'Kirim Barang'.
  ENDCASE.

  PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy fu_stbpom
                            '' lv_process lv_count
                      CHANGING fc_success fc_error.
*  ENDIF.

  IF lt_error[] IS NOT INITIAL.
    lt_xerror[] = lt_error[].
    SORT lt_xerror BY process.
    DELETE ADJACENT DUPLICATES FROM lt_xerror COMPARING process.

    LOOP AT lt_xerror INTO ls_xerror.
      lv_process  = ls_xerror-process.
      LOOP AT lt_error INTO ls_error WHERE process = lv_process.
        WRITE :/ ls_error-response.
        CLEAR ls_error.
      ENDLOOP.
      SKIP 1.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_MOVING_PRODUCT_ALL
