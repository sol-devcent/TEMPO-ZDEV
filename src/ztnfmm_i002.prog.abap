*&---------------------------------------------------------------------*
*& Report
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztnfmm_i002 NO STANDARD PAGE HEADING.
DATA: gv_str TYPE string.
DATA: gv_err(1).

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS: p_proses(10) DEFAULT 'TNF_GETGR' MODIF ID rea.  "TDN_LAZADA
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN SKIP 2.
PARAMETERS: p_demo AS CHECKBOX DEFAULT ' ' MODIF ID rea, "NO-DISPLAY, "NO-DISPLAY, "
            p_path TYPE eseftappl DEFAULT '/inbound/tnf/gr0001.json' MODIF ID rea. " NO-DISPLAY. "OBLIGATORY . "NO-DISPLAY. "

INITIALIZATION.
  LOOP AT SCREEN.
    IF screen-group1 = 'REA'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


START-OF-SELECTION.
  CLEAR: gv_err.
  PERFORM f_get_data CHANGING gv_err gv_str..
  IF gv_err = 0.
    PERFORM f_convert_json USING gv_str.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SY_SUBRC  text
*      <--P_GV_STR  text
*----------------------------------------------------------------------*
FORM f_get_data  CHANGING p_err
                          p_str.

  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_err(1).
  DATA:  lv_str TYPE string.
  DATA: lv_text TYPE text1024.
  DATA: lv_proses(15).
  DATA: lv_name(15).
  DATA: lv_time(10).

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
      REPLACE ALL OCCURRENCES OF '#' IN lv_str WITH '' .
      REPLACE ALL OCCURRENCES OF REGEX '#' IN lv_str WITH '" "'.
    ENDIF.
  ELSE.
    lv_proses = p_proses.
    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                         USING    lv_proses
                                         CHANGING lv_str lv_err.
  ENDIF.
  IF lv_str IS INITIAL.
    p_err = 4.
  ELSE.
    p_err = 0.
    lv_name = sy-datum.
    lv_time = sy-uzeit.
    CONDENSE: lv_name, lv_time.
    CONCATENATE 'T' lv_name lv_time INTO lv_name.
    PERFORM f_create_text_json(ztdsit_i001) USING lv_str lv_name '/inbound/tnf/' lv_proses.
    p_str = lv_str.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*----------------------------------------------------------------------*
FORM f_convert_json  USING    p_str.
  TYPES: BEGIN OF ty_detail,
           move_type           TYPE string, ": "101",
           plant               TYPE string,                 ": "1601",
           inv_produk_qty      TYPE string, ": 100,
           inv_produk_uom_base TYPE string, ": "KG",
           po_no_sap           TYPE string, ": "",
           po_item_sap         TYPE string,                 ": "00001"
         END OF ty_detail.
  TYPES: BEGIN OF ty_header,
           inv_date     TYPE string, ": "20260406",
           inv_reff     TYPE string, ": "001",
           user_created TYPE string, ": "admin",
           inv_doc_no   TYPE string, ": "MR26000001",
           details      TYPE STANDARD TABLE OF ty_detail WITH DEFAULT KEY,
         END OF ty_header.
  TYPES: BEGIN OF ty_result,
           result TYPE STANDARD TABLE OF ty_header WITH DEFAULT KEY,
         END OF ty_result.
  TYPES: BEGIN OF ty_return,
           inv_doc_no       TYPE string, ": "INV001",
           inv_sap_no       TYPE string, ": "5000123456",
           inv_sap_no_tahun TYPE string, " : “2026”,  //  tahun material dokumen
           inv_type         TYPE string, " : “S” ,     // - isi “E”  error atau “S” - sukses
           inv_message      TYPE string, " : “
         END OF ty_return.
  DATA:  gs_return TYPE ty_return.
  DATA:  lv_json_data     TYPE string.
  DATA:  gs_result TYPE ty_result.
  DATA:  gs_header TYPE ty_header.
  DATA:  gs_detail TYPE ty_detail.
  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         ls_goodsmvt_item LIKE LINE OF goodsmvt_item,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
         gs_item          LIKE LINE OF goodsmvt_item.
  DATA : lv_subrc    TYPE sy-subrc.
  DATA: lv_str TYPE string.
  DATA : zcl_json_data   TYPE REF TO zcl_trex_json_serializer.

  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = gs_result ). "lt_order ).

  IF gs_result-result[] IS INITIAL.
    RETURN.
  ENDIF.
  LOOP AT gs_result-result INTO gs_header.
    SELECT SINGLE mblnr mjahr INTO (materialdocument, matdocumentyear) FROM mkpf
      WHERE bktxt = gs_header-inv_doc_no.
    IF sy-subrc EQ 0.
      gs_return-inv_doc_no = gs_header-inv_doc_no.
      gs_return-inv_sap_no = materialdocument.
      gs_return-inv_sap_no_tahun = matdocumentyear.
      gs_return-inv_type = 'S'.
      CREATE OBJECT zcl_json_data
        EXPORTING
          data = gs_return.
      zcl_json_data->serialize( ).
      lv_json_data = zcl_json_data->get_data( ).
      WRITE: / 'Inv doc No : ', gs_return-inv_doc_no, 'sudah terbentuk Material Doc SAP no. -->', gs_return-inv_sap_no.
      PERFORM f_post_data_json(ztdsit_i001) USING lv_json_data 'TNF_GETGR' sy-subrc lv_str.
      WRITE: / 'Hasil Return dari Post to WEB: ', lv_str.
      SKIP 1.
      CONTINUE.
    ENDIF.
    goodsmvt_code                     = '01'.
    IF gs_header-inv_date IS INITIAL.
      goodsmvt_header-pstng_date        = sy-datum.
      goodsmvt_header-doc_date          = sy-datum.
    ELSE.
      goodsmvt_header-pstng_date        = gs_header-inv_date.
      goodsmvt_header-doc_date          = gs_header-inv_date.
    ENDIF.
    goodsmvt_header-ver_gr_gi_slip = '3'.
    goodsmvt_header-ver_gr_gi_slipx = 'X'.
    goodsmvt_header-ref_doc_no        = gs_header-inv_reff.
    goodsmvt_header-header_txt        = gs_header-inv_doc_no.
    goodsmvt_header-pr_uname          = gs_header-user_created.
    gs_return-inv_doc_no = gs_header-inv_doc_no.
    WRITE: / 'Inv Doc No. : ', gs_header-inv_doc_no.
    WRITE: / sy-uline(39).
    WRITE: /  sy-vline,
              'Qty ',
             10 sy-vline,
             12 'UOM',
             17   sy-vline,
             18 'No Po     ',
             31 sy-vline,
             32 'Itemno',
             39 sy-vline.
    WRITE: / sy-uline(39).
    LOOP AT gs_header-details INTO gs_detail.
      WRITE: /    sy-vline,
                  gs_detail-inv_produk_qty,
               10 sy-vline,
               12 gs_detail-inv_produk_uom_base,
               17 sy-vline,
               18 gs_detail-po_no_sap,
               31 sy-vline,
               32 gs_detail-po_item_sap,
               39 sy-vline.

      ls_goodsmvt_item-move_type        = '101'.
      ls_goodsmvt_item-plant            = gs_detail-plant.
      ls_goodsmvt_item-entry_qnt        = abs( gs_detail-inv_produk_qty ).
      ls_goodsmvt_item-entry_uom        = gs_detail-inv_produk_uom_base.
      ls_goodsmvt_item-po_number        = gs_detail-po_no_sap.
      ls_goodsmvt_item-po_item          = gs_detail-po_item_sap.
      ls_goodsmvt_item-mvt_ind          = 'B'.

      APPEND ls_goodsmvt_item TO goodsmvt_item.
      CLEAR: ls_goodsmvt_item.
    ENDLOOP.
    WRITE: / sy-uline(39).
    IF goodsmvt_item[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = goodsmvt_header
          goodsmvt_code    = goodsmvt_code
        IMPORTING
          materialdocument = materialdocument
          matdocumentyear  = matdocumentyear
        TABLES
          goodsmvt_item    = goodsmvt_item
          return           = return.

      gs_return-inv_sap_no = materialdocument.
      gs_return-inv_sap_no_tahun = matdocumentyear.
      gs_return-inv_type = 'S'.
      CLEAR: lv_subrc.
      LOOP AT return.
        IF return-type = 'E'.
          lv_subrc  = 4.
          gs_return-inv_type = 'E'.
        ENDIF.
        gs_return-inv_message = return-message.
        CLEAR return.
      ENDLOOP.
      IF lv_subrc IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
      CREATE OBJECT zcl_json_data
        EXPORTING
          data = gs_return.
      zcl_json_data->serialize( ).
      lv_json_data = zcl_json_data->get_data( ).
      WRITE: / 'Hasil Return GR : '.
      WRITE: / 'Inv doc No : ', gs_return-inv_doc_no.
      WRITE: / 'Material Doc SAP : ', gs_return-inv_sap_no.
      WRITE: / 'Status : ', gs_return-inv_type.
      WRITE: / 'Error Message : ', gs_return-inv_message.
      SKIP 1.
      PERFORM f_post_data_json(ztdsit_i001) USING lv_json_data 'TNF_GETGR' sy-subrc lv_str.
      WRITE: / 'Hasil Return Post to WEB : ', lv_str.
      SKIP 2.
    ENDIF.
    CLEAR: gs_return, goodsmvt_header, goodsmvt_item[], return[], materialdocument, matdocumentyear, gs_header, gs_header-details, gs_detail..
  ENDLOOP.

ENDFORM.
