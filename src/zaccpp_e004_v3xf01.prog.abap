*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004_V3XF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_docat   LIKE LINE OF gr_docat,
         ls_stbpom  LIKE LINE OF gr_stbpom.

  CASE 'X'.
    WHEN radio1.
      ls_docat-low    = 'PRO'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.

      ls_stbpom-low    = space.
      ls_stbpom-sign   = 'I'.
      ls_stbpom-option = 'EQ'.
      APPEND ls_stbpom TO gr_stbpom.

    WHEN radio2.
      ls_docat-low    = 'PRO'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.

      ls_stbpom-low    = space.
      ls_stbpom-high   = '1'.
      ls_stbpom-sign   = 'I'.
      ls_stbpom-option = 'BT'.
      APPEND ls_stbpom TO gr_stbpom.

      gv_idsarana     = pa_idloc.

    WHEN radio3.
      ls_docat-low    = 'PRO'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.

      ls_stbpom-low    = '1'.
      ls_stbpom-sign   = 'I'.
      ls_stbpom-option = 'EQ'.
      APPEND ls_stbpom TO gr_stbpom.

      ls_stbpom-low    = '2'.
      ls_stbpom-sign   = 'I'.
      ls_stbpom-option = 'EQ'.
      APPEND ls_stbpom TO gr_stbpom.
    WHEN radio4.
    WHEN radio5.
      ls_docat-low    = 'DO'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.
      ls_docat-low    = 'DCC'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.

    WHEN radio6.
      ls_docat-low    = 'INB'.
      ls_docat-sign   = 'I'.
      ls_docat-option = 'EQ'.
      APPEND ls_docat TO gr_docat.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOGIN_DATA
*&---------------------------------------------------------------------*
FORM f_login_data .
  DATA : lv_company           TYPE zaccdtu-company,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_response          TYPE ty_response,
         ls_rif_ex            TYPE REF TO cx_root,
         ls_var_text          TYPE string,
         ls_role              TYPE ty_role,
         lt_qr                TYPE STANDARD TABLE OF sbcbody.

  IF pa_test IS INITIAL.
    lv_company = 'BPOM'.
  ELSE.
    lv_company = 'BPOM_TEST'.
  ENDIF.

  SELECT *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtu
    WHERE company = lv_company.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 1.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  PERFORM f_value_replace USING '&EMAIL&' 'R' 'gatot.pramono@thetempogroup.com'.
  PERFORM f_value_replace USING '&PASSWORD&' 'R' 'Tempo_2020'.
  radio1 = 'X'.
  gv_autho  = '1'.

*  PERFORM f_value_replace USING '&EMAIL&' 'R' 'ruly.arief@thetempogroup.com'.
*  PERFORM f_value_replace USING '&PASSWORD&' 'R' 'Tempo_2021'.
*  radio9 = 'X'.
*  gv_autho  = '9'.

  PERFORM f_create_request_body TABLES lt_qr
                                USING 'ZLOGIN_BPOM' '' ''.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = ls_zaccdtu-uri
      request_entity_body_length  = 300
      proxy                       = ls_zaccdtu-proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.

  IF sy-subrc = 0.
    IF status_code  = '200' AND
      status_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        TRY.
            CALL TRANSFORMATION zacc_login_v3x SOURCE XML xml
                                               RESULT role = ls_role.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
        ENDTRY.

        gv_token    = ls_role-token.
        IF gv_token IS INITIAL.
          gv_error = 2.
        ENDIF.
      ELSE.
        gv_error  = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_LOGIN_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  CASE 'X'.
    WHEN radio1 OR radio2 OR radio3.
      SELECT *
       FROM s501
       INTO CORRESPONDING FIELDS OF TABLE gt_s501
       WHERE sptag  IN so_erdat
         AND docat  IN gr_docat
         AND docno  IN so_docno
         AND stbpom IN gr_stbpom.

    WHEN radio5 OR radio6.
      SELECT *
        FROM s501
        INTO CORRESPONDING FIELDS OF TABLE gt_s501
        WHERE sptag  IN so_erdat
          AND docat  IN gr_docat
          AND docno  IN so_docno
          AND werks  = pa_werks
          AND mblnr  <> space
          AND stbpom = space.
  ENDCASE.

  IF gt_s501[] IS NOT INITIAL.
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
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REGISTERPARENT_PROCESS
*&---------------------------------------------------------------------*
FORM f_registerparent_process .
  DATA : lt_tersier   TYPE STANDARD TABLE OF zaccdta,
         ls_tersier   LIKE LINE OF gt_tersier,
         ls_zaccdta   LIKE LINE OF gt_zaccdta.

  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 5.

  gt_tersier[]   = gt_zaccdta[].
  SORT gt_tersier BY aggr2.
  DELETE gt_tersier WHERE aggr2 = space.

  IF gt_tersier[] IS NOT INITIAL.
    PERFORM f_parent TABLES gt_tersier
                     USING ls_zaccdtu-uri ls_zaccdtu-proxy
                           'ZREGPARENT_BPOM' 'tersier' '' '1'.
    DELETE ADJACENT DUPLICATES FROM gt_tersier COMPARING aggr2.
    LOOP AT gt_tersier INTO ls_tersier.
      CLEAR lt_tersier[].
      LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr2 = ls_tersier-aggr2.
        APPEND ls_zaccdta TO lt_tersier.
        CLEAR ls_zaccdta.
      ENDLOOP.
      PERFORM f_parent TABLES lt_tersier
                       USING ls_zaccdtu-uri ls_zaccdtu-proxy
                             'ZREGPARENT1_BPOM' 'sekunder'
                             ls_tersier-aggr2 '1'.
      CLEAR ls_tersier.
    ENDLOOP.
  ENDIF.

  gt_sekunder[]  = gt_zaccdta[].
  SORT gt_sekunder BY aggr1.
  DELETE gt_sekunder WHERE aggr2 <> space
                       AND aggr1 <> space.

  IF gt_sekunder[] IS NOT INITIAL.
    PERFORM f_parent TABLES gt_sekunder
                     USING  ls_zaccdtu-uri ls_zaccdtu-proxy
                            'ZREGPARENT_BPOM' 'sekunder' '' '1'.
  ENDIF.
ENDFORM.                    " F_REGISTERPARENT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_REQUEST_BODY
*&---------------------------------------------------------------------*
FORM f_create_request_body  TABLES   ft_qr    STRUCTURE sbcbody
                            USING    fu_template fu_parent fu_barcode.
  DATA : lt_login         TYPE swww_t_html_table,
         ls_merge         LIKE LINE OF gt_merge,
         ls_login         LIKE LINE OF lt_login,
         ls_request_body  LIKE LINE OF gt_request_body,
         ls_qr            TYPE sbcbody,
         lv_lines         TYPE i,
         lv_count         TYPE i,
         lv_str1          TYPE string,
         lv_str2          TYPE string,
         lv_gtin(20).

  CALL FUNCTION 'WWW_HTML_MERGER'
    EXPORTING
      template    = fu_template
    IMPORTING
      html_table  = lt_login[]
    CHANGING
      merge_table = gt_merge[].

  IF ft_qr[] IS NOT INITIAL.
    DESCRIBE TABLE ft_qr LINES lv_lines.
  ENDIF.

  LOOP AT lt_login INTO ls_login.
    ls_request_body = ls_login-line.
    SEARCH ls_request_body FOR 'gtin'.
    IF sy-subrc = 0.
      SPLIT ls_request_body AT ':' INTO lv_str1 lv_str2.
      lv_gtin = lv_str2.
*      SHIFT lv_gtin LEFT DELETING LEADING '"'.
*      REPLACE ALL OCCURRENCES OF REGEX '"' IN lv_gtin WITH space.
      IF lv_gtin+1(1) IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF fu_parent IS NOT INITIAL.
      IF fu_barcode IS INITIAL.
        SEARCH ls_request_body FOR 'parent'.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    SEARCH ls_request_body FOR '&BARCODE&'.
    IF sy-subrc = 0.
      LOOP AT ft_qr INTO ls_qr.
        ADD 1 TO lv_count.
        ls_request_body = ls_qr-body.
        IF lv_count < lv_lines.
          CONCATENATE ls_request_body ',' INTO ls_request_body.
        ENDIF.
        APPEND ls_request_body TO gt_request_body.
      ENDLOOP.
    ELSE.
      APPEND ls_request_body TO gt_request_body.
    ENDIF.
  ENDLOOP.

  CLEAR : gt_merge[].
ENDFORM.                    " F_CREATE_REQUEST_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BARCODE
*&---------------------------------------------------------------------*
FORM f_create_barcode  USING    fu_concat fu_nie fu_charg fu_vfdat fu_senum
                       CHANGING fc_barcode.
  DATA : lv_vfdat(6),
         lv_barcode   TYPE string.

  IF fu_concat IS INITIAL.
    lv_barcode  = fu_senum.
  ELSE.
    CONCATENATE fu_vfdat+2(2) fu_vfdat+5(2) fu_vfdat+8(2)
    INTO lv_vfdat.
    CONCATENATE '90' fu_nie '\u001d' INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
    CONCATENATE lv_barcode '10' fu_charg '\u001d' INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
    CONCATENATE lv_barcode '17' lv_vfdat '21' fu_senum INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
  ENDIF.

  CONCATENATE '"' lv_barcode '"' INTO lv_barcode.

  IF fc_barcode IS INITIAL.
    fc_barcode = lv_barcode.
  ELSE.
    CONCATENATE fc_barcode ',' lv_barcode
    INTO fc_barcode.
  ENDIF.
ENDFORM.                    " F_CREATE_BARCODE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REPLACE
*&---------------------------------------------------------------------*
FORM f_value_replace  USING    fu_name fu_command fu_value.
  DATA : ls_merge     LIKE LINE OF gt_merge,
         lv_string    TYPE string.

  CLEAR ls_merge.
  ls_merge-name    = fu_name.
  ls_merge-command = fu_command.
  lv_string        = fu_value.
  APPEND lv_string TO ls_merge-html[].
  APPEND ls_merge  TO gt_merge.
ENDFORM.                    " F_VALUE_REPLACE

*&---------------------------------------------------------------------*
*&      Form  F_PARENT
*&---------------------------------------------------------------------*
FORM f_parent   TABLES   ft_parent STRUCTURE zaccdta
                USING    fu_uri fu_proxy fu_template fu_level fu_parent
                         fu_s501.
  DATA : ls_zaccdta   LIKE LINE OF gt_zaccdta,
         ls_tersier   LIKE LINE OF gt_tersier.

  DATA : lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_request_header    LIKE LINE OF gt_request_header,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_qr                LIKE LINE OF lt_qr.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i.

  lt_xaccdta[]  = ft_parent[].

  CASE fu_level.
    WHEN 'tersier'.
      SORT lt_xaccdta BY aggr2.
      DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr2.
    WHEN 'sekunder'.
      SORT lt_xaccdta BY aggr1.
      DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr1.
  ENDCASE.

  DESCRIBE TABLE lt_xaccdta LINES lv_lines.
  lv_times  = lv_lines DIV co_lines.

  IF lv_lines = co_lines.
    lv_times  = 1.
  ELSE.
    lv_times  = lv_times + 1.
  ENDIF.

  CLEAR : gt_error[].

  DO lv_times TIMES.
    IF gt_error[] IS INITIAL.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      CLEAR ls_xaccdta.
      LOOP AT lt_xaccdta INTO ls_xaccdta.
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
          WHEN 'tersier'.
            PERFORM f_create_single_barcode USING '' '' '' ''
                                                  ls_xaccdta-aggr2
                                            CHANGING ls_qr-body.
          WHEN 'sekunder'.
            PERFORM f_create_single_barcode USING '' '' '' ''
                                                  ls_xaccdta-aggr1
                                            CHANGING ls_qr-body.
        ENDCASE.
        APPEND ls_qr TO lt_qr.
        CLEAR ls_qr.

        DELETE TABLE lt_xaccdta FROM ls_xaccdta.
        CLEAR ls_xaccdta.
      ENDLOOP.

      PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
      PERFORM f_value_replace USING '&ACTIVE&' 'R' 'true'.
      PERFORM f_value_replace USING '&LEVEL&' 'R' fu_level.
      PERFORM f_value_replace USING '&PARENT&' 'R' fu_parent.

      PERFORM f_create_request_body TABLES lt_qr
                                    USING fu_template '' ''.

      PERFORM f_http_post USING fu_uri fu_proxy '1' 'Pelaporan Barcode Parent'
                                fu_s501.
      CLEAR : lv_count, lt_qr[].
    ENDIF.
  ENDDO.
ENDFORM.                    " F_PARENT

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_http_post  USING    fu_uri fu_proxy fu_stbpom fu_process fu_s501.
  DATA : lv_code(10),
         lv_text(100),
         ls_response_header   LIKE LINE OF gt_response_header,
         ls_error             LIKE LINE OF gt_error,
         ls_response          TYPE ty_response.

  IF gt_request_body[] IS NOT INITIAL.
    CALL FUNCTION 'HTTP_POST'
      EXPORTING
        absolute_uri               = fu_uri
        request_entity_body_length = 300
        proxy                      = fu_proxy
        blankstocrlf               = 'X'
      IMPORTING
        status_code                = lv_code
        status_text                = lv_text
      TABLES
        request_entity_body        = gt_request_body
        response_entity_body       = gt_response_body
        response_headers           = gt_response_header
        request_headers            = gt_request_header
      EXCEPTIONS
        connect_failed             = 1
        timeout                    = 2
        internal_error             = 3
        tcpip_error                = 4
        system_failure             = 5
        communication_failure      = 6
        OTHERS                     = 7.

    IF lv_code  = '200' AND
      lv_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        IF pa_test IS INITIAL.
          IF fu_s501 IS NOT INITIAL.
            PERFORM f_modify_s501 USING fu_stbpom fu_s501.
          ENDIF.
        ENDIF.
      ELSE.
        ls_error-process        = fu_process.
        ls_error-statuscode     = ls_response-statuscode.
        ls_error-message        = ls_response-message.
        APPEND ls_error TO gt_error.
        CLEAR ls_error.
      ENDIF.
    ELSE.
      LOOP AT gt_response_header INTO ls_response_header.
        ls_error-process        = fu_process.
        ls_error-statuscode     = lv_code.
        ls_error-message        = ls_response_header-header.
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
*&      Form  F_MODIFY_S501
*&---------------------------------------------------------------------*
FORM f_modify_s501  USING    fu_stbpom fu_s501.
  TYPES : BEGIN OF ty_s501,
            docat   TYPE s501-docat,
            docno   TYPE s501-docno,
          END OF ty_s501.

  DATA : ls_zaccdta   LIKE LINE OF gt_zaccdta,
         ls_zaccdtd   LIKE LINE OF gt_zaccdtd,
         ls_zaccdtm   LIKE LINE OF gt_zaccdtm,
         lt_s501      TYPE STANDARD TABLE OF ty_s501,
         ls_s501      LIKE LINE OF lt_s501,
         ls_tersier   LIKE LINE OF gt_tersier,
         ls_sekunder  LIKE LINE OF gt_sekunder,
         ls_barcode   LIKE LINE OF gt_barcode.

  CASE fu_s501.
    WHEN '1'.
      LOOP AT gt_tersier INTO ls_tersier.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE senum = ls_tersier-senum.
          ls_s501-docat = ls_zaccdtd-docat.
          ls_s501-docno = ls_zaccdtd-docno.
          COLLECT ls_s501 INTO lt_s501.
        ENDLOOP.
      ENDLOOP.
      LOOP AT gt_sekunder INTO ls_sekunder.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE senum = ls_sekunder-senum.
          ls_s501-docat = ls_zaccdtd-docat.
          ls_s501-docno = ls_zaccdtd-docno.
          COLLECT ls_s501 INTO lt_s501.
        ENDLOOP.
      ENDLOOP.
    WHEN '2'.
      LOOP AT gt_zaccdta INTO ls_zaccdta.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE senum = ls_zaccdta-senum.
          ls_s501-docat = ls_zaccdtd-docat.
          ls_s501-docno = ls_zaccdtd-docno.
          COLLECT ls_s501 INTO lt_s501.
        ENDLOOP.
      ENDLOOP.
    WHEN '3'.
      LOOP AT gt_zaccdta INTO ls_zaccdta.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE senum = ls_zaccdta-senum.
          ls_s501-docat = ls_zaccdtd-docat.
          ls_s501-docno = ls_zaccdtd-docno.
          COLLECT ls_s501 INTO lt_s501.
        ENDLOOP.
      ENDLOOP.
    WHEN 'X'.
      LOOP AT gt_barcode INTO ls_barcode.
        READ TABLE gt_zaccdta INTO ls_zaccdta
                              WITH KEY aggr2 = ls_barcode-barcode.
        IF sy-subrc = 0.
          LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr2 = ls_barcode-barcode.
            CLEAR ls_zaccdtd.
            READ TABLE gt_zaccdtd INTO ls_zaccdtd
                                  WITH KEY senum = ls_zaccdta-senum.
            IF sy-subrc = 0.
              ls_s501-docat = ls_zaccdtd-docat.
              ls_s501-docno = ls_zaccdtd-docno.
              COLLECT ls_s501 INTO lt_s501.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE gt_zaccdta INTO ls_zaccdta
                                WITH KEY aggr1 = ls_barcode-barcode.
          IF sy-subrc = 0.
            LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_barcode-barcode.
              CLEAR ls_zaccdtd.
              READ TABLE gt_zaccdtd INTO ls_zaccdtd
                                    WITH KEY senum = ls_zaccdta-senum.
              IF sy-subrc = 0.
                ls_s501-docat = ls_zaccdtd-docat.
                ls_s501-docno = ls_zaccdtd-docno.
                COLLECT ls_s501 INTO lt_s501.
              ENDIF.
            ENDLOOP.
          ELSE.
            READ TABLE gt_zaccdtd INTO ls_zaccdtd
                                  WITH KEY senum = ls_barcode-barcode.
            IF sy-subrc = 0.
              ls_s501-docat = ls_zaccdtd-docat.
              ls_s501-docno = ls_zaccdtd-docno.
              COLLECT ls_s501 INTO lt_s501.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  LOOP AT lt_s501 INTO ls_s501.
    TRY .
        UPDATE s501 SET stbpom = fu_stbpom
                    WHERE docat = ls_s501-docat
                      AND docno = ls_s501-docno.
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
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string.

  CLEAR xml.

  LOOP AT gt_response_body INTO temp_json.
    CONDENSE : temp_json, lv_str.
    REPLACE ALL OCCURRENCES OF REGEX 'null' IN temp_json WITH '"  "'.
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
*&      Form  F_WRITE_ERROR
*&---------------------------------------------------------------------*
FORM f_write_error .
  DATA : ls_error   LIKE LINE OF gt_error.
  IF gt_error[] IS NOT INITIAL.
    WRITE :/ sy-uline.
    LOOP AT gt_error INTO ls_error.
      WRITE : / sy-vline, ls_error-process,
                sy-vline, ls_error-statuscode,
                sy-vline, ls_error-message(100),
                sy-vline.
    ENDLOOP.
    WRITE :/ sy-uline.
  ENDIF.
ENDFORM.                    " F_WRITE_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_REGISTERPRIMER_PROCESS
*&---------------------------------------------------------------------*
FORM f_registerprimer_process USING fu_snsta fu_template.
  TYPES : BEGIN OF ty_primer,
            senum   TYPE zaccdtm-senum,
            nie     TYPE ztspmmdt002-nie,
            charg   TYPE mch1-charg,
            expdt(10),
            active(5),
            sample(5),
            reject(5),
            kemasan TYPE ztspmmdt002-kemasan,
            lot     TYPE zaccdtm-aufnr,
            gtin(14),
            sarana  TYPE string,
            parent(20),
          END OF ty_primer.

  DATA : lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_primer            TYPE STANDARD TABLE OF ty_primer,
         lt_xprimer           TYPE STANDARD TABLE OF ty_primer,
         lt_barcode           TYPE STANDARD TABLE OF ty_primer,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_xaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_primer            LIKE LINE OF lt_primer,
         ls_xprimer           LIKE LINE OF lt_xprimer,
         ls_barcode           LIKE LINE OF lt_barcode,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_qr                LIKE LINE OF lt_qr.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 6.

  ls_primer-sarana = gv_idsarana.

  CASE fu_snsta.
    WHEN 'ESTO'.
      ls_primer-active = 'true'.
      ls_primer-sample = 'false'.
      ls_primer-reject = 'false'.
    WHEN 'RTS'.
      ls_primer-active = 'false'.
      ls_primer-sample = 'true'.
      ls_primer-reject = 'false'.
    WHEN 'RJCT'.
      ls_primer-active = 'false'.
      ls_primer-sample = 'false'.
      ls_primer-reject = 'true'.
  ENDCASE.

  LOOP AT gt_zaccdta INTO ls_zaccdta.
    CLEAR ls_xaccdtm.
    READ TABLE gt_zaccdtm INTO ls_xaccdtm
                          WITH KEY senum = ls_zaccdta-senum
                                   snsta = fu_snsta.
    IF sy-subrc = 0.
      CLEAR ls_zaccdtd.
      READ TABLE gt_zaccdtd INTO ls_zaccdtd
                            WITH KEY senum = ls_xaccdtm-senum.
      IF sy-subrc = 0.
        IF ls_zaccdtd-xloek IS INITIAL.
          CLEAR ls_ztspmmdt002.
          READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                    WITH KEY werks = ls_xaccdtm-werks
                                             matnr = ls_xaccdtm-matnr.
          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                            WITH KEY matnr = ls_xaccdtm-matnr
                                     charg = ls_xaccdtm-charg.

          ls_primer-senum     = ls_zaccdta-senum.
          ls_primer-nie       = ls_ztspmmdt002-nie.
          ls_primer-charg     = ls_mch1-charg.
          CONCATENATE ls_mch1-vfdat(4) ls_mch1-vfdat+4(2) ls_mch1-vfdat+6(2)
          INTO ls_primer-expdt
          SEPARATED BY '-'.
          ls_primer-kemasan   = ls_ztspmmdt002-kemasan.
          ls_primer-lot       = ls_xaccdtm-aufnr.
          ls_primer-gtin      = ''.
          ls_primer-parent    = ls_zaccdta-aggr1.
          APPEND ls_primer TO lt_primer.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR ls_zaccdta.
  ENDLOOP.

  SORT lt_primer BY parent.
  lt_xprimer[]  = lt_primer[].
  DELETE ADJACENT DUPLICATES FROM lt_xprimer COMPARING parent.

  LOOP AT lt_xprimer INTO ls_xprimer.
    CLEAR lt_barcode[].
    LOOP AT lt_primer INTO ls_primer WHERE parent = ls_xprimer-parent.
      APPEND ls_primer TO lt_barcode.
      CLEAR ls_primer.
    ENDLOOP.

    DESCRIBE TABLE lt_barcode LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      lv_times  = lv_times + 1.
    ENDIF.

    CLEAR : gt_error[].

    DO lv_times TIMES.
      IF gt_error[] IS INITIAL.
        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        CLEAR ls_barcode.
        LOOP AT lt_barcode INTO ls_barcode.
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

*          PERFORM f_create_barcode USING 'X' ls_barcode-nie ls_barcode-charg
*                                         ls_barcode-expdt ls_barcode-senum
*                                   CHANGING lv_barcode.

          PERFORM f_create_single_barcode USING 'X' ls_barcode-nie ls_barcode-charg
                                                ls_barcode-expdt ls_barcode-senum
                                          CHANGING ls_qr-body.
          APPEND ls_qr TO lt_qr.
          CLEAR ls_qr.

          DELETE TABLE lt_barcode FROM ls_barcode.
          CLEAR ls_barcode.
        ENDLOOP.

        PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
*        PERFORM f_value_replace USING '&BARCODE&' 'R' lv_barcode.
        PERFORM f_value_replace USING '&NIE&' 'R' ls_xprimer-nie.
        PERFORM f_value_replace USING '&BATCH&' 'R' ls_xprimer-charg.
        PERFORM f_value_replace USING '&EXPDT&' 'R' ls_xprimer-expdt.
        PERFORM f_value_replace USING '&ACTIVE&' 'R' ls_xprimer-active.
        PERFORM f_value_replace USING '&SAMPLE&' 'R' ls_xprimer-sample.
        PERFORM f_value_replace USING '&REJECT&' 'R' ls_xprimer-reject.
        PERFORM f_value_replace USING '&KEMASAN&' 'R' ls_xprimer-kemasan.
        PERFORM f_value_replace USING '&LOT&' 'R' ls_xprimer-lot.
        PERFORM f_value_replace USING '&GTIN&' 'R' ls_xprimer-gtin.
        PERFORM f_value_replace USING '&SARANA&' 'R' ls_xprimer-sarana.
        PERFORM f_value_replace USING '&PARENT&' 'R' ls_xprimer-parent.

        PERFORM f_create_request_body TABLES lt_qr
                                      USING fu_template 'X' ls_xprimer-parent.

        PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy '2' 'Pelaporan Barcode Primer'
                                  '2'.
        CLEAR : lv_count, lv_barcode, lt_qr[].
      ENDIF.
    ENDDO.
  ENDLOOP.
ENDFORM.                    " F_REGISTERPRIMER_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_INFORMASI_SARANA
*&---------------------------------------------------------------------*
FORM f_informasi_sarana .
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_rif_ex            TYPE REF TO cx_root,
         ls_var_text          TYPE string,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_response          TYPE ty_response.

  CLEAR : ls_zaccdtu, gs_sarana.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 3.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
  PERFORM f_value_replace USING '&AKTIF&' 'R' 'true'.
  PERFORM f_value_replace USING '&OFFSET&' 'R' pa_offst.
  PERFORM f_value_replace USING '&LIMIT&' 'R' pa_limit.

  IF pa_offst IS INITIAL AND
    pa_limit IS INITIAL.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANAALL_BPOM' '' ''.
  ELSE.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANA_BPOM' '' ''.
  ENDIF.

  CALL FUNCTION 'HTTP_GET'
    EXPORTING
      absolute_uri                = ls_zaccdtu-uri
      request_entity_body_length  = 300
      proxy                       = ls_zaccdtu-proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.

  IF sy-subrc = 0.
    IF status_code  = '200' AND
      status_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        TRY.
            CALL TRANSFORMATION zacc_lokasi_v3x SOURCE XML xml
                                                RESULT sarana = gs_sarana.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_INFORMASI_SARANA

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
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_KIRIM_PROCESS
*&---------------------------------------------------------------------*
FORM f_kirim_process .
  DATA : lt_barcode           TYPE STANDARD TABLE OF ty_barcode,
         ls_barcode           LIKE LINE OF gt_barcode,
         lt_zaccdtd           TYPE STANDARD TABLE OF zaccdtd,
         ls_zaccdtd           LIKE LINE OF lt_zaccdtd,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_request_header    LIKE LINE OF gt_request_header,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         lv_vfdat(10),
         ls_qr                LIKE LINE OF lt_qr.

  lt_barcode[]  = gt_barcode[].

  SORT lt_barcode BY barcode.
  DELETE ADJACENT DUPLICATES FROM lt_barcode COMPARING barcode.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 2.

  DESCRIBE TABLE gt_barcode LINES lv_lines.
  lv_times  = lv_lines DIV co_lines.

  IF lv_lines = co_lines.
    lv_times  = 1.
  ELSE.
    lv_times  = lv_times + 1.
  ENDIF.

  CLEAR : gt_error[].

  DO lv_times TIMES.
    IF gt_error[] IS INITIAL.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      CLEAR ls_barcode.
      LOOP AT lt_barcode INTO ls_barcode.
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

        ls_qr-body  = ls_barcode-barcode.
        APPEND ls_qr TO lt_qr.
        CLEAR ls_qr.

        DELETE TABLE lt_barcode FROM ls_barcode.
        CLEAR ls_barcode.
      ENDLOOP.

      PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
      PERFORM f_value_replace USING '&SARANA&' 'R' pa_idtuj.

      PERFORM f_create_request_body TABLES lt_qr
                                    USING 'ZKIRIM_BPOM' '' ''.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy 'X' 'Kirim'
                                'X'.
      CLEAR : lv_count.
    ENDIF.
  ENDDO.
ENDFORM.                    " F_KIRIM_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_TERIMA_PROCESS
*&---------------------------------------------------------------------*
FORM f_terima_process .
  DATA : lt_barcode           TYPE STANDARD TABLE OF ty_barcode,
         ls_barcode           LIKE LINE OF gt_barcode,
         lt_zaccdtd           TYPE STANDARD TABLE OF zaccdtd,
         ls_zaccdtd           LIKE LINE OF lt_zaccdtd,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_request_header    LIKE LINE OF gt_request_header,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         lv_vfdat(10),
         ls_qr                LIKE LINE OF lt_qr.

  lt_barcode[]  = gt_barcode[].

  SORT lt_barcode BY barcode.
  DELETE ADJACENT DUPLICATES FROM lt_barcode COMPARING barcode.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 13.

  DESCRIBE TABLE lt_barcode LINES lv_lines.
  lv_times  = lv_lines DIV co_lines.

  IF lv_lines = co_lines.
    lv_times  = 1.
  ELSE.
    lv_times  = lv_times + 1.
  ENDIF.

  CLEAR : gt_error[].

  DO lv_times TIMES.
    IF gt_error[] IS INITIAL.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.

      CLEAR ls_barcode.
      LOOP AT lt_barcode INTO ls_barcode.
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

        ls_qr-body  = ls_barcode-barcode.
        APPEND ls_qr TO lt_qr.
        CLEAR ls_qr.

        DELETE TABLE lt_barcode FROM ls_barcode.
        CLEAR ls_barcode.
      ENDLOOP.

      PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
*      PERFORM f_value_replace USING '&BARCODE&' 'R' lv_barcode.

      PERFORM f_create_request_body TABLES lt_qr
                                    USING 'ZTERIMA_BPOM' '' ''.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy 'X' 'Terima'
                                'X'.
      CLEAR : lv_count, lv_barcode.
    ENDIF.
  ENDDO.
ENDFORM.                    " F_TERIMA_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SINGLE_BARCODE
*&---------------------------------------------------------------------*
FORM f_create_single_barcode  USING    fu_concat fu_nie fu_charg
                                       fu_vfdat fu_senum
                              CHANGING fc_barcode.
  DATA : lv_vfdat(6),
         lv_barcode   TYPE string.

  IF fu_concat IS INITIAL.
    lv_barcode  = fu_senum.
  ELSE.
    CONCATENATE fu_vfdat+2(2) fu_vfdat+5(2) fu_vfdat+8(2)
    INTO lv_vfdat.
    CONCATENATE '90' fu_nie '\u001d' INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
    CONCATENATE lv_barcode '10' fu_charg '\u001d' INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
    CONCATENATE lv_barcode '17' lv_vfdat '21' fu_senum INTO lv_barcode.
    CONDENSE lv_barcode NO-GAPS.
  ENDIF.

  CONCATENATE '"' lv_barcode '"' INTO fc_barcode.
ENDFORM.                    " F_CREATE_SINGLE_BARCODE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOKASI_SARANA
*&---------------------------------------------------------------------*
FORM f_add_lokasi_sarana .
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         lt_t001w             TYPE STANDARD TABLE OF t001w,
         ls_t001w             LIKE LINE OF lt_t001w,
         lt_adrc              TYPE STANDARD TABLE OF adrc,
         ls_adrc              LIKE LINE OF lt_adrc,
         ls_request_header    LIKE LINE OF gt_request_header.

  DATA : lv_alamat    TYPE string,
         lv_longitude TYPE string,
         lv_latitude  TYPE string.

  CLEAR ls_zaccdtu.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 4.
  SELECT *
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE lt_t001w
    WHERE werks IN so_werks.
  IF lt_t001w[] IS NOT INITIAL.
    SELECT *
      FROM adrc
      INTO CORRESPONDING FIELDS OF TABLE lt_adrc
      FOR ALL ENTRIES IN lt_t001w
      WHERE addrnumber = lt_t001w-adrnr.
  ENDIF.

  LOOP AT lt_t001w INTO ls_t001w.
    ls_request_header-header = 'Content-Type: application/json'.
    APPEND ls_request_header TO gt_request_header.

    CLEAR ls_adrc.
    READ TABLE lt_adrc INTO ls_adrc
                       WITH KEY addrnumber = ls_t001w-adrnr.
    IF sy-subrc = 0.
      CONCATENATE ls_adrc-street ',' ls_adrc-city1 ',' ls_adrc-post_code1
      INTO lv_alamat.
* 0102
*      lv_latitude = '-6.3216018'.
*      lv_longitude = '107.1142125'.

*      lv_latitude = '-6.3221082'.
*      lv_longitude = '107.1140545'.

*Jakarta 3
*      lv_latitude = '-6.2461214'.
*      lv_longitude = '106.8736238'.
*-6.246121428475522, 106.87362381534196

*DC Bekasi
*-6.211053378553853, 106.97735263863215
      lv_latitude = '-6.2110533'.
      lv_longitude = '106.9773526'.

      PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
      PERFORM f_value_replace USING '&ALAMAT&' 'R' lv_alamat.
      PERFORM f_value_replace USING '&TELP&' 'R' ls_adrc-tel_number.
      PERFORM f_value_replace USING '&FAX&' 'R' ls_adrc-fax_number.
      PERFORM f_value_replace USING '&LATITUDE&' 'R' lv_latitude.
      PERFORM f_value_replace USING '&LONGITUDE&' 'R' lv_longitude.

      PERFORM f_create_request_body TABLES lt_qr
                                    USING 'ZTAMBAHSARANA_BPOM' '' ''.

      PERFORM f_http_post USING ls_zaccdtu-uri ls_zaccdtu-proxy ''
                                'Penambahan Lokasi Sarana'
                                ''.
    ENDIF.
  ENDLOOP.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_ADD_LOKASI_SARANA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SARANA
*&---------------------------------------------------------------------*
FORM f_process_sarana USING fu_fs.
  FIELD-SYMBOLS <fs> TYPE ANY.

  DATA : ls_items   TYPE ty_items.

  CLEAR gt_items[].
  SORT gs_sarana-items BY id.
  LOOP AT gs_sarana-items INTO ls_items.
    APPEND ls_items TO gt_items.
    IF fu_fs IS NOT INITIAL.
      ASSIGN COMPONENT 'ID' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-id.
      ASSIGN COMPONENT 'ALAMAT_REKANAN' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-alamat_rekanan.
      ASSIGN COMPONENT 'NO_TELP' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-no_telp.
      ASSIGN COMPONENT 'FAX' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-fax.
      ASSIGN COMPONENT 'LATITUDE' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-latitude.
      ASSIGN COMPONENT 'LONGITUDE' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_items-longitude.
      APPEND <fs_gs> TO <fs_tab>.
      CLEAR : <fs_gs>.
    ENDIF.
    CLEAR : ls_items.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_SARANA

*&---------------------------------------------------------------------*
*&      Form  F_F4_HELP
*&---------------------------------------------------------------------*
FORM f_f4_help  USING    fu_retfield fu_dynprofield.
  CASE fu_retfield.
    WHEN 'IDLOC'.
      PERFORM f_idsarana_f4_help USING fu_retfield fu_dynprofield.
    WHEN 'IDTUJ'.
      PERFORM f_idtujuan_f4_help USING fu_retfield fu_dynprofield.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_F4_HELP

*&---------------------------------------------------------------------*
*&      Form  F_IDSARANA_F4_HELP
*&---------------------------------------------------------------------*
FORM f_idsarana_f4_help USING fu_retfield fu_dynprofield.
  TYPES : BEGIN OF ty_view,
            idloc     TYPE zaccstbpom-idloc,
            address   TYPE zaccstbpom-alrek,
          END OF ty_view.

  DATA : lv_subrc       TYPE sy-subrc.
  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab,
         lt_view        TYPE STANDARD TABLE OF ty_view,
         ls_view        LIKE LINE OF lt_view,
         ls_items       LIKE LINE OF gt_items.

  PERFORM f_informasi_sarana.
  PERFORM f_process_sarana USING ''.

  IF fu_retfield IS INITIAL AND
    fu_dynprofield IS INITIAL.
    READ TABLE gt_items INTO ls_items
                        WITH KEY id = pa_idloc.
    IF sy-subrc <> 0.
      PERFORM f_error_message USING 'PID' 'Sarana location not found!'.
    ENDIF.
  ELSE.
    LOOP AT gt_items INTO ls_items.
      ls_view-idloc   = ls_items-id.
      ls_view-address = ls_items-alamat_rekanan.
      APPEND ls_view TO lt_view.
      CLEAR ls_view.
    ENDLOOP.

    SORT lt_view BY idloc.
    ASSIGN lt_view TO <fs_tab>.

    CLEAR lv_subrc.
    PERFORM f_value_request TABLES return_tab
                            USING fu_retfield fu_dynprofield
                            CHANGING lv_subrc.
  ENDIF.
ENDFORM.                    " F_IDSARANA_F4_HELP

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                    " f4callback

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].

  CASE 'X'.
    WHEN radio4.
      SET TITLEBAR 'TITLE_RAD4'.
    WHEN radio8.
      SET TITLEBAR 'TITLE_RAD8'.
    WHEN radio9.
      SET TITLEBAR 'TITLE_RAD9'.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  PERFORM f_docking_split_container.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

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
        container = g_contain.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  PERFORM f_main_alv.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain.

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
        it_outtab            = <fs_tab>[]
        it_fieldcatalog      = gt_main_fieldcat[].
*  ELSE.
*    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname            = 'CHECK'.
  gs_layout_alv-zebra                = selected.
  gs_layout_alv-cwidth_opt           = selected.
  gs_layout_alv-s_dragdrop-row_ddid  = g_handle_alv.
  gs_layout_alv-no_toolbar           = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data.

  CASE 'X'.
    WHEN radio4.
      PERFORM f_get_fieldcat USING :
        'ID' '' '' '1' '' 'ID Sarana' '' '10',
        'ALAMAT_REKANAN' '' '' '2' '' 'Alamat Rekanan' '' '100',
        'NO_TELP' '' '' '3' '' 'No. Telp' '' '20',
        'FAX' '' '' '4' '' 'Fax' '' '20',
        'LATITUDE' '' '' '5' '' 'Latitude' '' '20',
        'LONGITUDE' '' '' '6' '' 'Longitude' '' '20'.
    WHEN radio8.
      PERFORM f_get_fieldcat USING :
        'ID' '' '' '1' '' 'ID Sarana' '' '10',
        'NAMA_SARANA' '' '' '2' '' 'Nama Sarana' '' '100',
        'ALAMAT' '' '' '3' '' 'Alamat' '' '100',
        'STATUS' '' '' '4' '' 'Status' '' '10'.
    WHEN radio9.
      PERFORM f_get_fieldcat USING :
        'PRIMER' '' '' '1' '' 'Primer' '' '100',
        'NIE' '' '' '2' '' 'NIE' '' '20',
        'BATCH_NO' '' '' '3' '' 'Batch' '' '20',
        'SKUNDER' '' '' '4' '' 'Sekunder' '' '20',
        'TERSIER' '' '' '5' '' 'Tersier' '' '20'.
  ENDCASE.

  SORT gt_main_fieldcat BY col_pos.

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
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_tab>.
    CREATE DATA ls_line LIKE LINE OF <fs_tab>.
    ASSIGN ls_line->* TO <fs_gs>.
  ENDIF.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_get_fieldcat  USING    fu_field fu_waers fu_meins fu_pos
                              fu_xfieldname fu_coltext fu_just
                              fu_outputlen.
  DATA : ls_tab        TYPE dfies,
         ls_dyn_fcat   TYPE lvc_s_fcat.

  CLEAR ls_tab.
  READ TABLE dfies_tab INTO ls_tab
                       WITH KEY fieldname = fu_field.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_tab TO ls_dyn_fcat.
  ELSE.
    ls_dyn_fcat-fieldname   = fu_field.
  ENDIF.

  ls_dyn_fcat-col_pos     = fu_pos.

  IF fu_xfieldname IS NOT INITIAL.
    ls_dyn_fcat-fieldname = fu_xfieldname.
  ENDIF.
  IF fu_outputlen IS NOT INITIAL.
    ls_dyn_fcat-outputlen = fu_outputlen.
  ENDIF.
  IF fu_coltext IS NOT INITIAL.
    ls_dyn_fcat-coltext = fu_coltext.
  ENDIF.
  IF fu_waers IS NOT INITIAL.
    ls_dyn_fcat-cfieldname  = fu_waers.
  ENDIF.
  IF fu_meins IS NOT INITIAL.
    ls_dyn_fcat-qfieldname  = fu_meins.
  ENDIF.
  IF fu_just IS NOT INITIAL.
    ls_dyn_fcat-just        = fu_just.
  ENDIF.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_GET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_PACKAGING_AGGREGATE_PROCESS
*&---------------------------------------------------------------------*
FORM f_packaging_aggregate_process.
  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 11.

  gt_tersier[]   = gt_zaccdta[].
  SORT gt_tersier BY aggr2.
  DELETE gt_tersier WHERE aggr2 = space.
  gt_sekunder[]  = gt_zaccdta[].
  SORT gt_sekunder BY aggr1.
  DELETE gt_sekunder WHERE aggr1 = space.

  IF gt_tersier[] IS NOT INITIAL.
    PERFORM f_aggregate_tersier USING ls_zaccdtu-uri ls_zaccdtu-proxy.
  ENDIF.

  IF gt_sekunder[] IS NOT INITIAL.
    PERFORM f_aggregate_sekunder USING ls_zaccdtu-uri ls_zaccdtu-proxy.
  ENDIF.
ENDFORM.                    " F_PACKAGING_AGGREGATE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_AGGREGATE_TERSIER
*&---------------------------------------------------------------------*
FORM f_aggregate_tersier USING fu_uri fu_proxy.
  DATA : lt_tersier           TYPE STANDARD TABLE OF zaccdta,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_tersier           LIKE LINE OF gt_tersier,
         lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_qr                LIKE LINE OF lt_qr.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_packdate(10).

  lt_tersier[]  = gt_tersier[].
  SORT lt_tersier BY aggr2.
  DELETE ADJACENT DUPLICATES FROM lt_tersier COMPARING aggr2.

  LOOP AT lt_tersier INTO ls_tersier.
    CLEAR : lt_xaccdta[].
    LOOP AT gt_tersier INTO ls_tersier WHERE aggr2 = ls_tersier-aggr2.
      ls_xaccdta = ls_tersier.
      APPEND ls_xaccdta TO lt_xaccdta.
      CLEAR ls_xaccdta.
    ENDLOOP.

    SORT lt_xaccdta BY aggr1.
    DELETE ADJACENT DUPLICATES FROM lt_xaccdta COMPARING aggr1.
    DESCRIBE TABLE lt_xaccdta LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      lv_times  = lv_times + 1.
    ENDIF.

    CLEAR : gt_error[].

    DO lv_times TIMES.
      IF gt_error[] IS INITIAL.
        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        CLEAR ls_xaccdta.
        LOOP AT lt_xaccdta INTO ls_xaccdta.
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

          PERFORM f_create_single_barcode USING '' '' '' ''
                                                ls_xaccdta-aggr1
                                          CHANGING ls_qr-body.
          APPEND ls_qr TO lt_qr.
          CLEAR ls_qr.

          DELETE TABLE lt_xaccdta FROM ls_xaccdta.
          CLEAR ls_xaccdta.
        ENDLOOP.

        CONCATENATE ls_tersier-packdat2(4)
                    ls_tersier-packdat2+4(2)
                    ls_tersier-packdat2+6(2)
        INTO lv_packdate
        SEPARATED BY '-'.

        PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
        PERFORM f_value_replace USING '&PACKDATE&' 'R' lv_packdate.
        PERFORM f_value_replace USING '&PARENT_TYPE&' 'R' 'tersier'.
        PERFORM f_value_replace USING '&PARENT&' 'R' ls_tersier-aggr2.

        PERFORM f_create_request_body TABLES lt_qr
                                      USING 'ZAGGREGATE_BPOM' '' ''.

        PERFORM f_http_post USING fu_uri fu_proxy '3' 'Pelaporan Aggregasi Barcode'
                                  '3'.
        CLEAR : lv_count, lt_qr[].
      ENDIF.
    ENDDO.
  ENDLOOP.
ENDFORM.                    " F_AGGREGATE_TERSIER

*&---------------------------------------------------------------------*
*&      Form  F_AGGREGATE_SEKUNDER
*&---------------------------------------------------------------------*
FORM f_aggregate_sekunder USING fu_uri fu_proxy.
  TYPES : BEGIN OF ty_primer,
            senum   TYPE zaccdtm-senum,
            nie     TYPE ztspmmdt002-nie,
            charg   TYPE mch1-charg,
            expdt(10),
            active(5),
            sample(5),
            reject(5),
            kemasan TYPE ztspmmdt002-kemasan,
            lot     TYPE zaccdtm-aufnr,
            gtin(14),
            sarana  TYPE string,
            packdate(10),
            parent(20),
          END OF ty_primer.

  DATA : lt_xaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
         lt_primer            TYPE STANDARD TABLE OF ty_primer,
         lt_xprimer           TYPE STANDARD TABLE OF ty_primer,
         lt_barcode           TYPE STANDARD TABLE OF ty_primer,
         ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_xaccdta           LIKE LINE OF lt_xaccdta,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_xaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_primer            LIKE LINE OF lt_primer,
         ls_xprimer           LIKE LINE OF lt_xprimer,
         ls_barcode           LIKE LINE OF lt_barcode,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_qr                LIKE LINE OF lt_qr.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i,
         lv_count             TYPE i,
         lv_xlines            TYPE i,
         lv_barcode           TYPE string.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 11.

  ls_primer-sarana = gv_idsarana.

  LOOP AT gt_zaccdta INTO ls_zaccdta.
    CLEAR ls_xaccdtm.
    READ TABLE gt_zaccdtm INTO ls_xaccdtm
                          WITH KEY senum = ls_zaccdta-senum.
    IF sy-subrc = 0.
      CLEAR ls_zaccdtd.
      READ TABLE gt_zaccdtd INTO ls_zaccdtd
                            WITH KEY senum = ls_xaccdtm-senum.
      IF sy-subrc = 0.
        IF ls_zaccdtd-xloek IS INITIAL.
          CLEAR ls_ztspmmdt002.
          READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                    WITH KEY werks = ls_xaccdtm-werks
                                             matnr = ls_xaccdtm-matnr.
          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                            WITH KEY matnr = ls_xaccdtm-matnr
                                     charg = ls_xaccdtm-charg.

          ls_primer-senum     = ls_zaccdta-senum.
          ls_primer-nie       = ls_ztspmmdt002-nie.
          ls_primer-charg     = ls_mch1-charg.
          CONCATENATE ls_mch1-vfdat(4) ls_mch1-vfdat+4(2) ls_mch1-vfdat+6(2)
          INTO ls_primer-expdt
          SEPARATED BY '-'.
          ls_primer-kemasan   = ls_ztspmmdt002-kemasan.
          ls_primer-lot       = ls_xaccdtm-aufnr.
          ls_primer-gtin      = ''.

          CONCATENATE ls_zaccdta-packdat1(4)
                      ls_zaccdta-packdat1+4(2)
                      ls_zaccdta-packdat1+6(2)
          INTO ls_primer-packdate
          SEPARATED BY '-'.

          ls_primer-parent    = ls_zaccdta-aggr1.
          APPEND ls_primer TO lt_primer.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR ls_zaccdta.
  ENDLOOP.

  SORT lt_primer BY parent.
  lt_xprimer[]  = lt_primer[].
  DELETE ADJACENT DUPLICATES FROM lt_xprimer COMPARING parent.

  LOOP AT lt_xprimer INTO ls_xprimer.
    CLEAR lt_barcode[].
    LOOP AT lt_primer INTO ls_primer WHERE parent = ls_xprimer-parent.
      APPEND ls_primer TO lt_barcode.
      CLEAR ls_primer.
    ENDLOOP.

    DESCRIBE TABLE lt_barcode LINES lv_lines.
    lv_times  = lv_lines DIV co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      lv_times  = lv_times + 1.
    ENDIF.

    CLEAR : gt_error[].

    DO lv_times TIMES.
      IF gt_error[] IS INITIAL.
        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        CLEAR ls_barcode.
        LOOP AT lt_barcode INTO ls_barcode.
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

          PERFORM f_create_single_barcode USING 'X' ls_barcode-nie ls_barcode-charg
                                                ls_barcode-expdt ls_barcode-senum
                                          CHANGING ls_qr-body.
          APPEND ls_qr TO lt_qr.
          CLEAR ls_qr.

          DELETE TABLE lt_barcode FROM ls_barcode.
          CLEAR ls_barcode.
        ENDLOOP.

        PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
        PERFORM f_value_replace USING '&PACKDATE&' 'R' ls_xprimer-packdate.
        PERFORM f_value_replace USING '&PARENT_TYPE&' 'R' 'sekunder'.
        PERFORM f_value_replace USING '&PARENT&' 'R' ls_xprimer-parent.

        PERFORM f_create_request_body TABLES lt_qr
                                      USING 'ZAGGREGATE_BPOM' '' ''.

        PERFORM f_http_post USING fu_uri fu_proxy '3' 'Pelaporan Aggregasi Barcode'
                                  '3'.
        CLEAR : lv_count, lv_barcode, lt_qr[].
      ENDIF.
    ENDDO.
  ENDLOOP.
ENDFORM.                    " F_AGGREGATE_SEKUNDER

*&---------------------------------------------------------------------*
*&      Form  F_INFORMASI_SARANA_TUJUAN
*&---------------------------------------------------------------------*
FORM f_informasi_sarana_tujuan .
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_rif_ex            TYPE REF TO cx_root,
         ls_var_text          TYPE string,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_response          TYPE ty_response.

  CLEAR : ls_zaccdtu, gs_sarana.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 7.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
  PERFORM f_value_replace USING '&AKTIF&' 'R' 'true'.
  PERFORM f_value_replace USING '&OFFSET&' 'R' pa_offst.
  PERFORM f_value_replace USING '&LIMIT&' 'R' pa_limit.

  IF pa_offst IS INITIAL AND
    pa_limit IS INITIAL.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANAALL_BPOM' '' ''.
  ELSE.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANA_BPOM' '' ''.
  ENDIF.

  CALL FUNCTION 'HTTP_GET'
    EXPORTING
      absolute_uri                = ls_zaccdtu-uri
      request_entity_body_length  = 300
      proxy                       = ls_zaccdtu-proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.

  IF sy-subrc = 0.
    IF status_code  = '200' AND
      status_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        TRY.
            CALL TRANSFORMATION zacc_tujuan_v3x SOURCE XML xml
                                                RESULT tujuan = gs_tujuan.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_INFORMASI_SARANA_TUJUAN

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SARANA_TUJUAN
*&---------------------------------------------------------------------*
FORM f_process_sarana_tujuan  USING    fu_fs.
  FIELD-SYMBOLS <fs> TYPE ANY.

  DATA : ls_tujuan   TYPE ty_ittujuan.

  CLEAR gt_tujuan[].
  SORT gs_tujuan-items BY id.
  LOOP AT gs_tujuan-items INTO ls_tujuan.
    APPEND ls_tujuan TO gt_tujuan.
    IF fu_fs IS NOT INITIAL.
      ASSIGN COMPONENT 'ID' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_tujuan-id.
      ASSIGN COMPONENT 'NAMA_SARANA' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_tujuan-nama_sarana.
      ASSIGN COMPONENT 'ALAMAT' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_tujuan-alamat.
      ASSIGN COMPONENT 'STATUS' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_tujuan-status.
      APPEND <fs_gs> TO <fs_tab>.
      CLEAR : <fs_gs>.
    ENDIF.
    CLEAR : ls_tujuan.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_SARANA_TUJUAN

*&---------------------------------------------------------------------*
*&      Form  F_INBOUND_PRODUCT
*&---------------------------------------------------------------------*
FORM f_inbound_product .
  DATA : ls_zaccdtu           LIKE LINE OF gt_zaccdtu,
         ls_rif_ex            TYPE REF TO cx_root,
         ls_var_text          TYPE string,
         lt_qr                TYPE STANDARD TABLE OF sbcbody,
         ls_request_header    LIKE LINE OF gt_request_header,
         ls_response          TYPE ty_response.

  CLEAR : ls_zaccdtu, gs_sarana.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 12.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  PERFORM f_value_replace USING '&TOKEN&' 'R' gv_token.
  PERFORM f_value_replace USING '&AKTIF&' 'R' 'true'.
  PERFORM f_value_replace USING '&OFFSET&' 'R' pa_offst.
  PERFORM f_value_replace USING '&LIMIT&' 'R' pa_limit.
  PERFORM f_value_replace USING '&NIE&' 'R' pa_nie.
  PERFORM f_value_replace USING '&CHARG&' 'R' pa_charg.

  IF pa_offst IS INITIAL AND
    pa_limit IS INITIAL AND
    pa_nie IS INITIAL AND
    pa_charg IS INITIAL.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANAALL_BPOM' '' ''.
  ELSEIF pa_nie IS INITIAL AND
    pa_charg IS INITIAL.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANA_BPOM' '' ''.
  ELSEIF pa_offst IS INITIAL AND
    pa_limit IS INITIAL.
    PERFORM f_create_request_body TABLES lt_qr
                                  USING 'ZINFOSARANANIE_BPOM' '' ''.
  ENDIF.

  CALL FUNCTION 'HTTP_GET'
    EXPORTING
      absolute_uri                = ls_zaccdtu-uri
      request_entity_body_length  = 300
      proxy                       = ls_zaccdtu-proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.

  IF sy-subrc = 0.
    IF status_code  = '200' AND
      status_text = 'OK'.
      PERFORM f_read_response_body CHANGING ls_response.
      IF ls_response-status = 'true'.
        TRY.
            CALL TRANSFORMATION zacc_product_v3x SOURCE XML xml
                                                 RESULT product = gs_product.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_INBOUND_PRODUCT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_INBOUND_PRODUCT
*&---------------------------------------------------------------------*
FORM f_process_inbound_product  USING    fu_fs.
  FIELD-SYMBOLS <fs> TYPE ANY.

  DATA : ls_product   TYPE ty_itproduct,
         lv_senum(20),
         lv_charg(10),
         lv_matnr     TYPE mara-matnr,
         lv_primer(100).

  CLEAR gt_product[].
  SORT gs_product-items BY primer.
  LOOP AT gs_product-items INTO ls_product.
    APPEND ls_product TO gt_product.
    IF fu_fs IS NOT INITIAL.
      lv_primer = ls_product-primer.
      CALL METHOD zcl_util=>m_acc_split_sn
        EXPORTING
          pvi_senum = lv_primer
          pvi_bpom  = 'X'
        IMPORTING
          pvo_senum = lv_senum.
      ASSIGN COMPONENT 'PRIMER' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = lv_senum.
      ASSIGN COMPONENT 'NIE' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_product-nie.
      ASSIGN COMPONENT 'BATCH_NO' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_product-batch_no.
      ASSIGN COMPONENT 'SKUNDER' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_product-skunder.
      ASSIGN COMPONENT 'TERSIER' OF STRUCTURE <fs_gs> TO <fs>.
      <fs> = ls_product-tersier.
      APPEND <fs_gs> TO <fs_tab>.
      CLEAR : <fs_gs>.
    ENDIF.
    CLEAR : ls_product.
  ENDLOOP..
ENDFORM.                    " F_PROCESS_INBOUND_PRODUCT

*&---------------------------------------------------------------------*
*&      Form  F_IDTUJUAN_F4_HELP
*&---------------------------------------------------------------------*
FORM f_idtujuan_f4_help  USING    fu_retfield fu_dynprofield.
  TYPES : BEGIN OF ty_view,
            idtuj     TYPE zaccstbpom-idtuj,
            nama      TYPE zaccstbpom-nmsar,
          END OF ty_view.

  DATA : lv_subrc       TYPE sy-subrc.
  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab,
         lt_view        TYPE STANDARD TABLE OF ty_view,
         ls_view        LIKE LINE OF lt_view,
         ls_tujuan      LIKE LINE OF gt_tujuan.

  PERFORM f_informasi_sarana_tujuan.
  PERFORM f_process_sarana_tujuan USING ''.

  IF fu_retfield IS INITIAL AND
    fu_dynprofield IS INITIAL.
    READ TABLE gt_tujuan INTO ls_tujuan
                         WITH KEY id = pa_idtuj.
    IF sy-subrc <> 0.
      PERFORM f_error_message USING 'PID' 'Sarana tujuan not found!'.
    ENDIF.
  ELSE.
    LOOP AT gt_tujuan INTO ls_tujuan.
      ls_view-idtuj   = ls_tujuan-id.
      ls_view-nama    = ls_tujuan-nama_sarana.
      APPEND ls_view TO lt_view.
      CLEAR ls_view.
    ENDLOOP.

    SORT lt_view BY idtuj.
    ASSIGN lt_view TO <fs_tab>.

    CLEAR lv_subrc.
    PERFORM f_value_request TABLES return_tab
                            USING fu_retfield fu_dynprofield
                            CHANGING lv_subrc.
  ENDIF.
ENDFORM.                    " F_IDTUJUAN_F4_HELP

*&---------------------------------------------------------------------*
*&      Form  F_BARCODE_PROCESS
*&---------------------------------------------------------------------*
FORM f_barcode_process .
  DATA : ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_barcode           LIKE LINE OF gt_barcode,
         ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_ztspmmdt002       LIKE LINE OF gt_ztspmmdt002,
         ls_mch1              LIKE LINE OF gt_mch1,
         lv_vfdat(10).

  LOOP AT gt_zaccdtd INTO ls_zaccdtd.
    CLEAR : ls_zaccdta.
    READ TABLE gt_zaccdta INTO ls_zaccdta
                          WITH KEY senum = ls_zaccdtd-senum.
    IF sy-subrc = 0.
      IF ls_zaccdta-aggr2 IS NOT INITIAL.
        PERFORM f_create_single_barcode USING '' '' '' '' ls_zaccdta-aggr2
                                        CHANGING ls_barcode-barcode.
        APPEND ls_barcode TO gt_barcode.
      ELSEIF ls_zaccdta-aggr1 IS NOT INITIAL.
        PERFORM f_create_single_barcode USING '' '' '' '' ls_zaccdta-aggr1
                                        CHANGING ls_barcode-barcode.
        APPEND ls_barcode TO gt_barcode.
      ELSE.
        CLEAR ls_zaccdtm.
        READ TABLE gt_zaccdtm INTO ls_zaccdtm
                              WITH KEY senum = ls_zaccdtd-senum.
        IF sy-subrc = 0.
          CLEAR ls_ztspmmdt002.
          READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                                    WITH KEY werks = ls_zaccdtm-werks
                                             matnr = ls_zaccdtm-matnr.
          CLEAR : ls_mch1, lv_vfdat.
          READ TABLE gt_mch1 INTO ls_mch1
                            WITH KEY matnr = ls_zaccdtm-matnr
                                     charg = ls_zaccdtm-charg.
          IF sy-subrc = 0.
            CONCATENATE ls_mch1-vfdat(4) ls_mch1-vfdat+4(2) ls_mch1-vfdat+6(2)
            INTO lv_vfdat.
          ENDIF.
        ENDIF.

        PERFORM f_create_single_barcode USING 'X' ls_ztspmmdt002-nie ls_mch1-charg
                                              lv_vfdat ls_zaccdtd-senum
                                        CHANGING ls_barcode-barcode.
        APPEND ls_barcode TO gt_barcode.
      ENDIF.
    ENDIF.
    CLEAR ls_barcode.
  ENDLOOP.
ENDFORM.                    " F_BARCODE_PROCESS
