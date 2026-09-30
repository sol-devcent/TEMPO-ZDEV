*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F09.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_POST_PIDADHOC
*&---------------------------------------------------------------------*
FORM f_post_pidadhoc  TABLES   ft_piditem STRUCTURE zhgwmst014
                      USING    p_json
                      CHANGING fc_ivnum fc_type fc_message.

  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_pidadhoc,
         lt_piditem   TYPE STANDARD TABLE OF zhgwmst014,
         ls_piditem   LIKE LINE OF lt_piditem,
         lt_xpiditem  TYPE STANDARD TABLE OF zhgwmst014,
         lt_006       TYPE STANDARD TABLE OF ztspmmdt006,
         ls_006       LIKE LINE OF lt_006,
         lt_x006      TYPE STANDARD TABLE OF ztspmmdt006,
         ls_x006      LIKE LINE OF lt_006.

  DATA : nrrangenr TYPE inri-nrrangenr,
         object	   TYPE inri-object,
         toyear	   TYPE inri-toyear,
         lv_ivnum  TYPE ztspmmdt006-ivnum,
         lv_subrc  TYPE sy-subrc,
         lv_menge  TYPE mseg-menge.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  lt_piditem[] = ls_data-nav_adhoc[].

  nrrangenr = '01'.
  object    = 'ZINVSW'.
  toyear    = sy-datum(4).

  lt_xpiditem[] = lt_piditem[].
  SORT lt_xpiditem BY material_number batch.
  DELETE ADJACENT DUPLICATES FROM lt_xpiditem COMPARING material_number batch.
  IF lt_xpiditem[] IS NOT INITIAL.
    SELECT *
      FROM ztspmmdt006
      INTO CORRESPONDING FIELDS OF TABLE lt_x006
      FOR ALL ENTRIES IN lt_xpiditem
      WHERE werks = ls_data-plant
        AND lgort = ls_data-storage_location
        AND matnr = lt_xpiditem-material_number
        AND charg = lt_xpiditem-batch.
  ENDIF.

  LOOP AT lt_piditem INTO ls_piditem.
    ls_006-werks    = ls_data-plant.
    ls_006-lgort    = ls_data-storage_location.
    ls_006-ivpos    = ls_piditem-item_no.
    ls_006-matnr    = ls_piditem-material_number.
    ls_006-charg    = ls_piditem-batch.
    PERFORM f_conversion USING 'INPUT' '' ls_piditem-uom
                         CHANGING lv_menge ls_006-meins.

    TRANSLATE ls_piditem-actual_quantity USING ',.'.
    ls_006-labst    = ls_piditem-actual_quantity.
    TRANSLATE ls_piditem-quantity USING ',.'.
    ls_006-menge    = ls_piditem-quantity.
    IF ls_006-menge IS INITIAL.
      ls_006-kznul    = 'X'.
    ENDIF.
    ls_006-pidres   = ls_piditem-reason.
    ls_006-stktyp   = ls_data-code_stcat.
    PERFORM f_datetime USING ls_piditem-counted_date
                       CHANGING ls_006-qdatu ls_006-qzeit.
    ls_006-qname    = ls_data-username.
    APPEND ls_006 TO lt_006.
    IF lt_x006[] IS NOT INITIAL.
      CLEAR ls_x006.
      READ TABLE lt_x006 INTO ls_x006
                         WITH KEY mblnr = space
                                  rjnam_prdm = space.
      IF sy-subrc = 0.
        lv_subrc = 4.
      ENDIF.
    ENDIF.
    APPEND ls_piditem TO ft_piditem.
    CLEAR ls_piditem.
  ENDLOOP.

  IF lv_subrc = 0.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = nrrangenr
        object                  = object
        subobject               = ls_data-plant
        toyear                  = toyear
      IMPORTING
        number                  = fc_ivnum
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      LOOP AT lt_006 INTO ls_006.
        ls_006-ivnum = fc_ivnum.
        MODIFY lt_006 FROM ls_006
                      INDEX sy-tabix
                      TRANSPORTING ivnum.
      ENDLOOP.

      TRY.
          INSERT ztspmmdt006 FROM TABLE lt_006.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.

      IF lv_subrc = 0.
        fc_type   = 'S'.
        CONCATENATE 'PID' fc_ivnum 'created' INTO fc_message
        SEPARATED BY space.

        PERFORM f_cetak_form TABLES ft_piditem
                             USING 'ADHOC' ls_data-storage_location
                                   ls_data-code_stcat
                                   ls_data-printer_name.
        PERFORM f_send_email TABLES lt_006
                             USING ls_data-plant
                                   ls_data-storage_location.
      ELSE.
        fc_type    = 'E'.
        fc_message = 'PID create error'.
      ENDIF.
    ELSE.
      fc_type     = 'E'.
      fc_message  = 'Number ranges not found'.
    ENDIF.
  ELSE.
    fc_type     = 'E'.
    fc_message  = 'Ada PID aktif'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM
*&---------------------------------------------------------------------*
FORM f_cetak_form  TABLES   ft_items STRUCTURE zhgwmst014
                   USING    fu_pid fu_lgort fu_stcat fu_printer.
  DATA : ls_ztspmmst003 TYPE ztspmmst003,
         ls_items       TYPE zhgwmst014,
         lt_xitems      TYPE STANDARD TABLE OF zhgwmst014,
         ls_xitems      LIKE LINE OF lt_xitems,
         lt_makt        TYPE STANDARD TABLE OF makt,
         ls_makt        LIKE LINE OF lt_makt,
         lt_t064b       TYPE STANDARD TABLE OF t064b,
         ls_t064b       LIKE LINE OF lt_t064b.

  DATA : lv_menge    TYPE mseg-menge,
         lv_formname TYPE tdsfname,
         lv_funcname TYPE tdsfname,
         ctrl_param  LIKE ssfctrlop,
         output_opt  TYPE ssfcompop,
         lv_cntr     TYPE i,
         lv_lines    TYPE i.

  lt_xitems[] = ft_items[].
  SORT lt_xitems BY material_number.
  DELETE ADJACENT DUPLICATES FROM lt_xitems COMPARING material_number.
  IF lt_xitems[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_xitems
      WHERE matnr = lt_xitems-material_number
        AND spras = sy-langu.
  ENDIF.

  SELECT *
    FROM t064b
    INTO CORRESPONDING FIELDS OF TABLE lt_t064b
    WHERE spras = sy-langu.

  lv_formname = 'ZTSPMM_F003'.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc = 0.
*    ctrl_param-no_close   = space.
    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
    CALL FUNCTION 'CONVERSION_EXIT_SPDEV_INPUT'
      EXPORTING
        input  = fu_printer
      IMPORTING
        output = output_opt-tddest.

    DESCRIBE TABLE ft_items LINES lv_lines.

    LOOP AT ft_items INTO ls_items.
      AT FIRST.
        ctrl_param-no_close = 'X'.
      ENDAT.

      IF lv_lines > 1.
        AT LAST.
          ctrl_param-no_close = space.
        ENDAT.
      ENDIF.

      ls_ztspmmst003-company = 'TUS - Mojokerto'.
      ls_ztspmmst003-matnr   = ls_items-material_number.
      CLEAR ls_makt.
      READ TABLE lt_makt INTO ls_makt
                         WITH KEY matnr = ls_items-material_number.
      IF sy-subrc = 0.
        ls_ztspmmst003-maktx  = ls_makt-maktx.
      ENDIF.
      ls_ztspmmst003-charg   = ls_items-batch.
      ls_ztspmmst003-lgort   = fu_lgort.

      CASE fu_pid.
        WHEN 'ADHOC'.
          CASE fu_stcat.
            WHEN '1'.
              ls_ztspmmst003-status = 'Unrestricted Use'.
            WHEN '2'.
              ls_ztspmmst003-status = 'Quality Inspection'.
            WHEN OTHERS.
              ls_ztspmmst003-status = 'Blocked'.
          ENDCASE.
        WHEN 'YEARLY'.
          READ TABLE lt_t064b INTO ls_t064b
                              WITH KEY bstar = fu_stcat.
          IF sy-subrc = 0.
            ls_ztspmmst003-status = ls_t064b-btext.
          ENDIF.
      ENDCASE.

      ls_ztspmmst003-qty = ls_items-quantity.
      TRANSLATE ls_ztspmmst003-qty USING '.,'.
      CONDENSE ls_ztspmmst003-qty.
      PERFORM f_conversion USING 'INPUT' '' ls_items-uom
                           CHANGING lv_menge ls_ztspmmst003-meins.

      CLEAR lv_cntr.
      DO ls_items-number_copy TIMES.
        ADD 1 TO lv_cntr.
        ls_ztspmmst003-zpage = lv_cntr.
        ls_ztspmmst003-zformpage = ls_items-number_copy.

        CALL FUNCTION lv_funcname
          EXPORTING
            control_parameters = ctrl_param
            output_options     = output_opt
            user_settings      = space
            gs_head            = ls_ztspmmst003
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
        ctrl_param-no_open = 'X'.
      ENDDO.
      IF lv_lines = 1.
        ctrl_param-no_close = space.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL
*&---------------------------------------------------------------------*
FORM f_send_email  TABLES   ft_006  STRUCTURE ztspmmdt006
                   USING    fu_werks fu_lgort.
  DATA : lt_mail         TYPE STANDARD TABLE OF zmail,
         lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service,
         lt_soli         TYPE TABLE OF soli,
         ls_soli         TYPE soli,
         lo_doc_bcs      TYPE REF TO cl_document_bcs,
         lo_bcs          TYPE REF TO cl_bcs,
         ls_mail         LIKE LINE OF lt_mail,
         lo_recipient    TYPE REF TO if_recipient_bcs,
         lv_status       TYPE bcs_rqst,
         lv_subject(50),
         lw_document_bcs TYPE REF TO cx_document_bcs.

  SELECT *
    FROM zmail
    INTO CORRESPONDING FIELDS OF TABLE lt_mail
    WHERE project = 'CEK'
      AND werks   = fu_werks
      AND lgort   = fu_lgort.

  IF ft_006[] IS NOT INITIAL.
    lv_subject = 'PID AdHOC'.

    CLEAR lt_soli[].
    PERFORM f_create_email_body TABLES lt_soli
                                       ft_006.

    CREATE OBJECT lo_mime_helper.

    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_soli.

    lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                    i_subject          = lv_subject
                    i_importance       = '9'
                    i_multirel_service = lo_mime_helper ).

    lo_bcs = cl_bcs=>create_persistent( ).

    lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address
    LOOP AT lt_mail INTO ls_mail.
      IF ls_mail-zto IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient ).
      ENDIF.

      IF ls_mail-cc IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                      i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient
                               i_copy      = 'X').
      ENDIF.
    ENDLOOP.

    lv_status = 'N'.
    CALL METHOD lo_bcs->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.
    TRY.
        lo_bcs->send( ).
        COMMIT WORK.
      CATCH cx_bcs.
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_EMAIL_BODY
*&---------------------------------------------------------------------*
FORM f_create_email_body  TABLES   ft_soli STRUCTURE soli
                                   ft_006  STRUCTURE ztspmmdt006.
  DATA : ls_soli TYPE soli,
         ls_006  TYPE ztspmmdt006.

  PERFORM f_create_merge TABLES ft_006
                         USING 'ZPID_3BODY' ''.
  PERFORM f_create_merge TABLES ft_006
                         USING 'ZPID_IVNUM' ''.
  PERFORM f_create_merge TABLES ft_006
                         USING 'ZPID_3FOOTER' ''.

  LOOP AT gt_body INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_html INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_foot INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
ENDFORM.                    " F_CREATE_EMAIL_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MERGE
*&---------------------------------------------------------------------*
FORM f_create_merge  TABLES   ft_006 STRUCTURE ztspmmdt006
                     USING    fu_template fu_itab.
  TYPES : BEGIN OF ty_x006,
            werks      TYPE ztspmmdt006-werks,
            lgort      TYPE ztspmmdt006-lgort,
            ivnum      TYPE ztspmmdt006-ivnum,
            qdatu      TYPE ztspmmdt006-qdatu,
            ivpos      TYPE ztspmmdt006-ivpos,
            matnr      TYPE ztspmmdt006-matnr,
            maktx      TYPE makt-maktx,
            charg      TYPE ztspmmdt006-charg,
            meins      TYPE ztspmmdt006-meins,
            labst(20),
            menge(20),
            lebih(20),
            kurang(20),
            pidtxt     TYPE ztspmmdt007-pidtxt,
          END OF ty_x006.

  DATA : ls_006    TYPE ztspmmdt006,
         lt_x006   TYPE STANDARD TABLE OF ty_x006,
         ls_x006   LIKE LINE OF lt_x006,
         lt_fields TYPE STANDARD TABLE OF w3fields WITH HEADER LINE,
         lt_header TYPE STANDARD TABLE OF w3head WITH HEADER LINE,
         lv_kurang TYPE ztspmmdt006-menge,
         lv_lebih  TYPE ztspmmdt006-menge,
         lt_fcat   TYPE lvc_t_fcat,
         ls_fcat   TYPE lvc_s_fcat,
         w_head    TYPE w3head,
         lv_menge  TYPE mseg-menge,
         lv_meins  TYPE mseg-meins.

  CASE fu_template.
    WHEN 'ZPID_3BODY'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_body[]
        CHANGING
          merge_table = gt_bmerge[].

    WHEN 'ZPID_IVNUM'.
      ls_fcat-coltext = 'Plant'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'SLoc.'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'No. PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Tanggal PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Item'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Material'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Description'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Batch'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Uom'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Quantity'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Counted Qty'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Lebih'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Kurang'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Reason'.
      APPEND ls_fcat TO lt_fcat.

      LOOP AT lt_fcat INTO ls_fcat.
        w_head-text = ls_fcat-coltext.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
          EXPORTING
            field_nr = sy-tabix
            text     = w_head-text
            fgcolor  = 'black'
            bgcolor  = 'green'
          TABLES
            header   = lt_header.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
          EXPORTING
            field_nr = sy-tabix
            fgcolor  = 'black'
            size     = '3'
          TABLES
            fields   = lt_fields.
      ENDLOOP.

      LOOP AT ft_006 INTO ls_006.
        ls_x006-werks = ls_006-werks.
        ls_x006-lgort = ls_006-lgort.
        ls_x006-ivnum = ls_006-ivnum.
        ls_x006-qdatu = ls_006-qdatu.
        ls_x006-ivpos = ls_006-ivpos.
        ls_x006-matnr = ls_006-matnr.

        SELECT SINGLE maktx
          FROM makt
          INTO ls_x006-maktx
          WHERE matnr = ls_006-matnr
            AND spras = sy-langu.

        ls_x006-charg = ls_006-charg.
        PERFORM f_conversion USING 'OUTPUT' '' ls_006-meins
                             CHANGING lv_menge ls_x006-meins.
        PERFORM f_conversion USING 'INPUT' ls_006-labst ls_006-meins
                             CHANGING ls_x006-labst lv_meins.
        PERFORM f_conversion USING 'INPUT' ls_006-menge ls_006-meins
                             CHANGING ls_x006-menge lv_meins.

        lv_kurang = ls_006-menge - ls_006-labst.
        IF lv_kurang < 0.
          lv_kurang = abs( lv_kurang ).
          lv_lebih  = 0.
        ELSE.
          lv_lebih  = lv_kurang.
          lv_kurang = 0.
        ENDIF.

        PERFORM f_conversion USING 'INPUT' lv_kurang ls_006-meins
                             CHANGING ls_x006-kurang lv_meins.
        PERFORM f_conversion USING 'INPUT' lv_lebih ls_006-meins
                             CHANGING ls_x006-lebih lv_meins.

        SELECT SINGLE pidtxt
          FROM ztspmmdt007
          INTO ls_x006-pidtxt
          WHERE werks  = ls_006-werks
            AND pidres = ls_006-pidres.

        APPEND ls_x006 TO lt_x006.
        CLEAR ls_x006.
      ENDLOOP.

      CLEAR gt_html[].
      CALL FUNCTION 'WWW_ITAB_TO_HTML'
        TABLES
          html       = gt_html
          fields     = lt_fields
          row_header = lt_header
          itable     = lt_x006.

    WHEN 'ZPID_3FOOTER'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_foot[]
        CHANGING
          merge_table = gt_fmerge[].
  ENDCASE.
ENDFORM.
