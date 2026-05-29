*----------------------------------------------------------------------*
*   INCLUDE ZGDQM_R0010_V1INT                                          *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  start_server
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3746   text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM start_server USING    p_doc_description.
  IF bds_doc IS INITIAL.
    CREATE OBJECT bds_doc.
  ENDIF.

  IF container IS INITIAL.
    CALL METHOD c_oi_container_control_creator=>get_container_control
      IMPORTING
        control = control
        error   = errors
        retcode = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CREATE OBJECT container
    EXPORTING
        container_name = 'CONTAINER'.

    CALL METHOD control->init_control
      EXPORTING
        r3_application_name      = 'F1'
        inplace_enabled          = 'X'
        inplace_scroll_documents = 'X'
        parent                   = container
        register_on_close_event  = 'X'
        register_on_custom_event = 'X'
        no_flush                 = 'X'
      IMPORTING
        retcode                  = retcode
        error                    = errors.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CALL METHOD control->get_document_proxy
      EXPORTING
        document_format = document_format
        document_type   = document_type
        no_flush        = no_flush
      IMPORTING
        document_proxy  = document
        error           = errors
        retcode         = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    PERFORM select_document USING p_doc_description
                            CHANGING doc_url.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

* Open link server
    CALL METHOD control->get_link_server
      EXPORTING
        no_flush    = no_flush
      IMPORTING
        error       = error
        link_server = link_server
        retcode     = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    IF is_created NE 'X'.
      CALL METHOD link_server->start_link_server
        EXPORTING
          link_server_mode   = link_server->link_server_customname
          no_flush           = no_flush
          server_name_suffix = 'FI'
        IMPORTING
          error              = error
          retcode            = retcode.
      CALL METHOD c_oi_errors=>show_message
        EXPORTING
          type = 'E'.
      is_created = 'X'.
    ENDIF.

    CALL METHOD document->open_document
      EXPORTING
        document_url = doc_url
        open_inplace = 'X'
      IMPORTING
        retcode      = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CALL METHOD document->get_spreadsheet_interface
      EXPORTING
        no_flush        = no_flush
      IMPORTING
        sheet_interface = sheet_interface
        error           = error
        retcode         = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CALL METHOD sheet_interface->screen_update
      EXPORTING
        updating = ' '
        no_flush = no_flush
      IMPORTING
        error    = error
        retcode  = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ENDIF.
ENDFORM.                    " start_server

*&---------------------------------------------------------------------*
*&      Form  select_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_DOC_DESCRIPTION  text
*      <--P_DOC_URL  text
*----------------------------------------------------------------------*
FORM select_document USING doc_id TYPE type_doc
                     CHANGING adr_url TYPE bapiuri-uri.

  DATA: doc_signature TYPE sbdst_signature,
        wa_doc_signature LIKE LINE OF doc_signature,
        doc_components TYPE sbdst_components,
        wa_doc_components LIKE LINE OF doc_components,
        doc_uris TYPE sbdst_uri,
        wa_doc_uris LIKE LINE OF doc_uris.
*----------------------------------------------------------------------

  CLEAR: wa_doc_signature, wa_doc_components, wa_doc_uris.
  REFRESH: doc_signature, doc_components, doc_uris.

  wa_doc_signature-prop_name = 'BDS_DESCRIPTION'.
  wa_doc_signature-prop_value = doc_id.
  APPEND wa_doc_signature TO doc_signature.

* Availability of document checked
  CALL METHOD bds_doc->get_info
    EXPORTING
      classname       = doc_classname
      classtype       = doc_classtype
      object_key      = doc_object_key
      client          = sy-mandt
    CHANGING
      components      = doc_components
      signature       = doc_signature
    EXCEPTIONS
      nothing_found   = 1
      error_kpro      = 2
      internal_error  = 3
      parameter_error = 4
      not_authorized  = 5
      not_allowed     = 6.
  IF sy-subrc NE 0 AND sy-subrc NE 1.
    MESSAGE e000(zab) WITH
    'Error in the Business Document Service (BDS)'.
  ENDIF.
  IF sy-subrc = 1.
    MESSAGE e000(zab) WITH
    'There are no documents that meet the search criteria'.
  ENDIF.

* Get URL address
  CALL METHOD bds_doc->get_with_url
    EXPORTING
      classname       = doc_classname
      classtype       = doc_classtype
      object_key      = doc_object_key
    CHANGING
      uris            = doc_uris
      signature       = doc_signature
    EXCEPTIONS
      nothing_found   = 1
      error_kpro      = 2
      internal_error  = 3
      parameter_error = 4
      not_authorized  = 5
      not_allowed     = 6.
  IF sy-subrc NE 0 AND sy-subrc NE 1.
    MESSAGE e000(zab) WITH
    'Error in the Business Document Service (BDS)'.
  ENDIF.
  IF sy-subrc = 1.
    MESSAGE e000(zab) WITH
    'There are no documents that meet the search criteria'.
  ENDIF.

  READ TABLE doc_components INTO wa_doc_components INDEX 1.
  READ TABLE doc_uris INTO wa_doc_uris INDEX 1.
  doc_mimetype = wa_doc_components-mimetype.
  adr_url = wa_doc_uris-uri.

  CASE doc_mimetype.
    WHEN 'application/x-rtf' OR 'text/rtf'.
      document_format = soi_docformat_rtf.
    WHEN 'application/x-oleobject'.
      document_format = soi_docformat_compound.
    WHEN 'text/plain'.
      document_format = soi_docformat_text.
    WHEN OTHERS.
      document_format = soi_docformat_native.
  ENDCASE.
ENDFORM.                    " select_document

*&---------------------------------------------------------------------*
*&      Form  set_content
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2      text
*      -->P_P_ROW  text
*      -->P_sum_breed1_WERKS  text
*----------------------------------------------------------------------*
FORM set_content USING value(fd_col)
                       fd_row
                       fd_value.
  DATA : ld_value(105).

  IF count IS INITIAL.
    ADD 1 TO columns_number.
  ENDIF.
  struc_generic-column = fd_col.
  struc_generic-row    = fd_row.
  WRITE fd_value TO ld_value.
  CONDENSE ld_value.
  PERFORM f_convert_minus CHANGING ld_value.
  struc_generic-value  = ld_value.
  APPEND struc_generic TO contents.
ENDFORM.                    " set_content

*&---------------------------------------------------------------------*
*&      Form  set_content_uom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2      text
*      -->P_P_ROW  text
*      -->P_sum_breed1_WERKS  text
*----------------------------------------------------------------------*
FORM set_content_uom USING value(fd_col)
                           fd_row
                           fd_value
                           fd_uom.
  DATA : ld_value(30).

  struc_generic-column = fd_col.
  struc_generic-row = fd_row.

  IF fd_value IS NOT INITIAL.
    WRITE fd_value TO ld_value UNIT fd_uom.
    CONDENSE ld_value.
    PERFORM f_convert_minus CHANGING ld_value.

    struc_generic-value = ld_value.

    APPEND struc_generic TO contents.
  ENDIF.
ENDFORM.                    " set_content_uom

*&---------------------------------------------------------------------*
*&      Form  set_content_curr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2      text
*      -->P_P_ROW  text
*      -->P_sum_breed1_WERKS  text
*----------------------------------------------------------------------*
FORM set_content_curr USING value(fd_col)
                            fd_row
                            fd_value
                            fd_curr.
  DATA : ld_value(30).

  IF count IS INITIAL.
    ADD 1 TO columns_number.
  ENDIF.

  struc_generic-column = fd_col.
  struc_generic-row    = fd_row.

  IF fd_value IS NOT INITIAL.
    WRITE fd_value TO ld_value CURRENCY fd_curr.
    CONDENSE ld_value.
    PERFORM f_convert_minus CHANGING ld_value.

    struc_generic-value = ld_value.

    APPEND struc_generic TO contents.
  ENDIF.
ENDFORM.                    " set_content_curr

*&---------------------------------------------------------------------*
*&      Form  set_content_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2      text
*      -->P_P_ROW  text
*      -->P_T_ITAB_ERDAT  text
*----------------------------------------------------------------------*
FORM set_content_date USING value(fd_col)
                            fd_row
                            fd_value.

  DATA : ld_value(10).

  IF count IS INITIAL.
    ADD 1 TO columns_number.
  ENDIF.
  struc_generic-column = fd_col.
  struc_generic-row    = fd_row.
  IF fd_value IS NOT INITIAL.
    WRITE fd_value TO ld_value.
    CONDENSE ld_value.
    struc_generic-value = ld_value.
    APPEND struc_generic TO contents.
  ENDIF.
ENDFORM.                    " set_content_date

*&---------------------------------------------------------------------*
*&      Form  f_convert_minus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_VALUE  text
*----------------------------------------------------------------------*
FORM f_convert_minus CHANGING fd_value.
  DATA : ld_len TYPE i,
         ld_value(50),
         ld_min(1).

  CLEAR : ld_len, ld_value, ld_min.

  ld_len = STRLEN( fd_value ).
  ld_len = ld_len - 1.
  IF ld_len GE 0.
    IF fd_value+ld_len(1) EQ '-'.
      SPLIT fd_value AT '-' INTO ld_value ld_min.
      CONCATENATE '-' ld_value INTO fd_value.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_convert_minus

*&---------------------------------------------------------------------*
*&      Form  formatting_rangesdef_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM formatting_rangesdef_tab.
  LOOP AT contents INTO struc_generic.
    struc_rangesdef-rows    = 1.
    struc_rangesdef-columns = 1.
    struc_rangesdef-row     = struc_generic-row.
    struc_rangesdef-column  = struc_generic-column.
    struc_generic-row       = '1'.
    struc_generic-column    = '1'.
    MODIFY contents FROM struc_generic INDEX sy-tabix.
    APPEND struc_rangesdef TO rangesdef.
  ENDLOOP.
ENDFORM.                    " formatting_rangesdef_tab

*&---------------------------------------------------------------------*
*&      Form  replace_word
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM replace_word.
  CALL METHOD sheet_interface->set_ranges_data
    EXPORTING
      no_flush  = no_flush
      ranges    = ranges
      rangesdef = rangesdef
      contents  = contents
    IMPORTING
      error     = error
      retcode   = retcode.

  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'I'.

  CLEAR : contents, rangesdef, ranges.
  REFRESH : contents, rangesdef, ranges.
ENDFORM.                    " replace_word

*&---------------------------------------------------------------------*
*&      Form  close_server
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_server.
  CALL METHOD sheet_interface->screen_update
    EXPORTING
      updating = 'X'
      no_flush = no_flush
    IMPORTING
      error    = error
      retcode  = retcode.

  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

** Close/release link server object
  CALL METHOD link_server->stop_link_server
    EXPORTING
      no_flush = no_flush
    IMPORTING
      error    = error
      retcode  = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.
ENDFORM.                    " close_server

*&---------------------------------------------------------------------*
*&      Form  f_close_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_document.
  CALL METHOD document->close_document
    EXPORTING
      no_flush    = no_flush
    IMPORTING
      error       = error
      has_changed = has_changed
      retcode     = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.


  CALL METHOD document->release_document
    EXPORTING
      no_flush = no_flush
    IMPORTING
      error    = error
      retcode  = retcode.

  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

  IF NOT document IS INITIAL.
    FREE document.
  ENDIF.
  IF NOT bds_doc IS INITIAL.
    FREE bds_doc.
  ENDIF.

  CALL METHOD control->release_all_documents
    EXPORTING
      no_flush = no_flush
    IMPORTING
      error    = error
      retcode  = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.


  CALL METHOD control->destroy_control
    EXPORTING
      no_flush = no_flush
    IMPORTING
      retcode  = retcode
      error    = error.

  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

  IF NOT container IS INITIAL.
    FREE container.
  ENDIF.
  IF NOT control IS INITIAL.
    FREE control.
  ENDIF.

  IF NOT sheet_interface IS INITIAL.
    FREE sheet_interface.
  ENDIF.
ENDFORM.                    " f_close_document
