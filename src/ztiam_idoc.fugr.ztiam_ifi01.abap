FUNCTION ztiam_ifi01.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     VALUE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) LIKE  BDWFAP_PAR-RESULT
*"     VALUE(APPLICATION_VARIABLE) LIKE  BDWFAP_PAR-APPL_VAR
*"     VALUE(IN_UPDATE_TASK) LIKE  BDWFAP_PAR-UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) LIKE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------
  TABLES: likp, ZTDNSDDT021.
  DATA: t_ztiam_custom TYPE STANDARD TABLE OF ztiam_custom WITH HEADER LINE.
  DATA: gv_eventid TYPE char40.
  DATA: gv_eventparm TYPE char40.
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json             TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA: lv_vbeln LIKE likp-vbeln.
  DATA: lv_return TYPE sysubrc.
  data: lv_len type i.
  DATA: BEGIN OF order,
           kode_mp(10),
           kode_shop(10),
           no_order(35),
           no_so(10),
           tgl_so(10),
           no_dn(10),
           tgl_dn(10),
           no_ship(10),
           tgl_ship(10),
           ship_to(10),
           message(100),
           status(1),
       END  OF order.
  data: gs_ZTDNSDDT021 type ZTDNSDDT021.
  "BELNR
  "KTEXT
  CLEAR: gv_eventparm.
  LOOP AT idoc_data WHERE segnam = 'ZTIAM_CUSTOM'.
    t_ztiam_custom = idoc_data-sdata.
    gv_eventid = t_ztiam_custom-belnr.
    gv_eventparm = t_ztiam_custom-ktext.
    APPEND t_ztiam_custom.
  ENDLOOP.
  DATA: gs_likp TYPE likp,
        l_len TYPE i.
  IF gv_eventid = 'TDN_TEST'.
    LOOP AT t_ztiam_custom.
      CONDENSE: t_ztiam_custom-ktext.
      lv_vbeln = t_ztiam_custom-ktext.
      gs_ZTDNSDDT021-vbeln = lv_vbeln.
      gs_ZTDNSDDT021-erdat = sy-datum.
      gs_ZTDNSDDT021-ernam = sy-uname.
      gs_ZTDNSDDT021-erzet1 = sy-uzeit.
      SELECT SINGLE * INTO gs_likp FROM likp WHERE vbeln = lv_vbeln.
      CONDENSE gs_likp-lifex.
      IF gs_likp-lifex IS NOT INITIAL.
        l_len = STRLEN( gs_likp-lifex ).
        l_len = l_len - 3.
        order-kode_shop = gs_likp-lifex+l_len(3).
        order-no_order =  gs_likp-lifex. "l_bstkd. "ls_ztdnsddt014-bstkd.
      ELSE.
        order-kode_shop = 'TDN'.
        order-no_order =  gs_likp-vbeln. "l_bstkd. "ls_ztdnsddt014-bstkd.
      ENDIF.
      REFRESH: let_docflow.
      CLEAR: lw_docflow.
      CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
        EXPORTING
          iv_docnum  = gs_likp-vbeln
        IMPORTING
          et_docflow = let_docflow.
      IF sy-subrc EQ 0.
        LOOP AT let_docflow INTO lw_docflow WHERE vbtyp_n = 'C'.
          order-no_so = lw_docflow-vbeln.
          "          lv_vbeln = lw_docflow-vbeln.
          order-tgl_so = lw_docflow-erdat.
        ENDLOOP.
        order-status = 'S'.
        order-ship_to =  gs_likp-kunnr.
        order-no_dn = gs_likp-vbeln.
        order-tgl_dn = gs_likp-erdat.
        CREATE OBJECT cl_json_data
          EXPORTING
            DATA = order.
        cl_json_data->serialize( ).
        gv_json = cl_json_data->get_data( ).
        gs_ZTDNSDDT021-erzet2 = sy-uzeit.
        PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'TDN_ORDER' lv_return lv_str.
        gs_ZTDNSDDT021-erzet3 = sy-uzeit.
        gs_ZTDNSDDT021-zreturn = lv_return.
        gs_ZTDNSDDT021-zmessage = lv_str.
        MODIFY ZTDNSDDT021 from gs_ZTDNSDDT021.
      ENDIF.
    ENDLOOP.
    IF lv_return NE 0.
      lv_len = strlen( lv_str ).
      idoc_status-status = '51'.
      idoc_status-docnum = idoc_contrl-docnum.
      idoc_status-msgty  = 'S'.
      idoc_status-msgid  = 'ZAB'.
      idoc_status-msgno  = '000'.
      idoc_status-msgv1  = 'Error : '.
      idoc_status-msgv2  = lv_str.
      if lv_len > 50.
         idoc_status-msgv2  = lv_str(50).
      elseif lv_len > 100.
         idoc_status-msgv2  = lv_str(50).
         idoc_status-msgv2  = lv_str+50(50).
      elseif  lv_len > 150.
         idoc_status-msgv2  = lv_str(50).
         idoc_status-msgv2 = lv_str+50(50).
         idoc_status-msgv3  = lv_str+100(50).
      endif.
      "idoc_status-msgv3  = wa_return-message_v3.
      "idoc_status-msgv4  = wa_return-message_v4.
      APPEND idoc_status.
    ELSE.
      lv_len = strlen( lv_str ).
      idoc_status-status = '53'.
      idoc_status-docnum = idoc_contrl-docnum.
      idoc_status-msgty  = 'S'.
      idoc_status-msgid  = 'ZAB'.
      idoc_status-msgno  = '000'.
      idoc_status-msgv1  = lv_str.
      idoc_status-msgv2  = lv_str.
      if lv_len > 50.
         idoc_status-msgv2  = lv_str(50).
      elseif lv_len > 100.
         idoc_status-msgv2  = lv_str(50).
         idoc_status-msgv2  = lv_str+50(50).
      elseif  lv_len > 150.
         idoc_status-msgv2  = lv_str(50).
         idoc_status-msgv2 = lv_str+50(50).
         idoc_status-msgv3  = lv_str+100(50).
      endif.
      "idoc_status-msgv2  = lv_str.
      "idoc_status-msgv3  = wa_return-message_v3.
      "idoc_status-msgv4  = wa_return-message_v4.
      APPEND idoc_status.
    ENDIF.
  ELSE.
    LOOP AT t_ztiam_custom.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = gv_eventid
          eventparm              = gv_eventparm
        EXCEPTIONS
          bad_eventid            = 1
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      "OTHERS                 = 5.
    ENDLOOP.
    idoc_status-status = '53'.
    idoc_status-docnum = idoc_contrl-docnum.
    idoc_status-msgty  = 'S'.
    "idoc_status-msgid  = wa_return-id.
    "idoc_status-msgno  = wa_return-number.
    idoc_status-msgv1  = 'Berhasil'.
    "idoc_status-msgv2  = wa_return-message_v2.
    "idoc_status-msgv3  = wa_return-message_v3.
    "idoc_status-msgv4  = wa_return-message_v4.
    APPEND idoc_status.
  ENDIF.

*     IDOCS are opened for process.
  CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_PROCESS'
    EXPORTING
      db_read_option           = 'N'
      document_number          = idoc_contrl-docnum
    IMPORTING
      idoc_control             = idoc_contrl
    EXCEPTIONS
      document_foreign_lock    = 1
      document_not_exist       = 2
      document_number_invalid  = 3
      document_is_already_open = 4
      OTHERS                   = 5.

  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
      EXPORTING
        idoc_number               = idoc_contrl-docnum
        idoc_opened_flag          = 'X'
      IMPORTING
        idoc_control              = idoc_contrl
      TABLES
        idoc_status               = idoc_status
      EXCEPTIONS
        idoc_foreign_lock         = 1
        idoc_not_found            = 2
        idoc_status_records_empty = 3
        idoc_status_invalid       = 4
        db_error                  = 5
        OTHERS                    = 6.

    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL FUNCTION 'EDI_DOCUMENT_CLOSE_PROCESS'
      EXPORTING
        document_number     = idoc_contrl-docnum
        no_dequeue          = 'X' "lc_idoc_no_dequeue
      IMPORTING
        idoc_control        = idoc_contrl
      EXCEPTIONS
        document_not_open   = 1
        failure_in_db_write = 2
        parameter_error     = 3
        status_set_missing  = 4.


  ENDIF.


ENDFUNCTION.
