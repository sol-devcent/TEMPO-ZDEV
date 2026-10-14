*&---------------------------------------------------------------------*
*& Report  ZSPICKUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztnfmm_i001 NO STANDARD PAGE HEADING.

TABLES: nast, vbrk, vbrp, zfidt010.
"INCLUDE rvadtabl.

"INCLUDE zabp_frm.

"INCLUDE zspickuptop.

DATA : gv_kschl   TYPE nast-kschl,
       xscreen(1).

DATA : BEGIN OF t_nast_key,
         ebeln TYPE ekko-ebeln,
       END OF t_nast_key.



SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS p_ebeln TYPE ekko-ebeln .
"PARAMETERS p_back AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

START-OF-SELECTION.

  nast-objky = p_ebeln.
  PERFORM entry USING sy-subrc sy-subrc.

  "  PERFORM f_send_api USING p_vbeln CHANGING sy-subrc.

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  "  gv_kschl    = nast-kschl.
  "  t_nast_key  = nast-objky.
  p_ebeln     = nast-objky.
  CLEAR: return_code, us_screen.
  PERFORM f_send_api USING p_ebeln CHANGING return_code.
ENDFORM.                    "entry


*&---------------------------------------------------------------------*
*&      Form  F_SEND_API
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_api USING p_param CHANGING return_code.
  TYPES: BEGIN OF ty_dtl.
           INCLUDE STRUCTURE bapiekpo.
         TYPES:
                  items    TYPE STANDARD TABLE OF bapieket WITH DEFAULT KEY,
                  accounts TYPE STANDARD TABLE OF bapiekkn WITH DEFAULT KEY,
                END OF ty_dtl.
  TYPES: BEGIN OF ty_po.
           INCLUDE STRUCTURE bapiekkol.
         TYPES:
                  details TYPE STANDARD TABLE OF ty_dtl WITH DEFAULT KEY,
                END OF ty_po.
  DATA: gs_po TYPE ty_po.
  DATA: ls_details TYPE ty_dtl.
  DATA: ls_ekko TYPE ekko,
        lt_ekpo TYPE STANDARD TABLE OF ekpo,
        lt_eket TYPE STANDARD TABLE OF eket,
        ls_ekpo LIKE LINE OF lt_ekpo,
        ls_eket LIKE LINE OF lt_eket.

  DATA: lv_ebeln TYPE ekko-ebeln.
  DATA: l_name(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_str          TYPE string.
  DATA: lv_text(15).
  DATA: lv_subrc      TYPE sy-subrc, lv_text1(100).

  DATA:
    items                   LIKE bapimmpara-selection,
    accountassignment       LIKE bapimmpara-selection,
    schedules               LIKE bapimmpara-selection,
    history                 LIKE bapimmpara-selection,
    itemtexts               LIKE bapimmpara-selection,
    headertexts             LIKE bapimmpara-selection,
    confirmations           LIKE bapimmpara-selection,
    services                LIKE bapimmpara-selection,
    poheader                LIKE bapiekkol,
    poaddress               LIKE bapiaddress,
    poitems                 LIKE bapiekpo OCCURS 0, " WITH HEADER LINE,
    ls_poitems              LIKE LINE OF poitems,
    poitemschedules         LIKE bapieket OCCURS 0, " WITH HEADER LINE,
    ls_poitemschedules      LIKE LINE OF poitemschedules,
    poitemaccountassignm    LIKE bapiekkn OCCURS 0,
    ls_poitemaccountassignm LIKE LINE OF poitemaccountassignm,
    return                  LIKE bapireturn OCCURS 0.


  lv_ebeln = p_param.
  TRY.
      CALL FUNCTION 'BAPI_PO_GETDETAIL'
        EXPORTING
          purchaseorder              = lv_ebeln
          items                      = 'X'
          account_assignment         = 'X'
          schedules                  = 'X'
        IMPORTING
          po_address                 = poaddress
          po_header                  = poheader
        TABLES
          return                     = return
          po_items                   = poitems
          po_item_account_assignment = poitemaccountassignm
          po_item_schedules          = poitemschedules
        EXCEPTIONS
          OTHERS                     = 01.
    CATCH cx_root INTO DATA(lo_root_exception).
  ENDTRY.
  IF lo_root_exception IS NOT INITIAL.
    lv_str = 'Data Not Found'.
    PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
    return_code  = 4.
    RETURN.
  ENDIF.

  MOVE-CORRESPONDING poheader TO gs_po.
  LOOP AT poitems INTO ls_poitems WHERE po_number = poheader-po_number.
    MOVE-CORRESPONDING ls_poitems TO ls_details.

    LOOP AT poitemschedules INTO ls_poitemschedules WHERE po_item = ls_poitems-po_item.
      APPEND ls_poitemschedules TO ls_details-items.
    ENDLOOP.
    LOOP AT poitemaccountassignm INTO ls_poitemaccountassignm WHERE po_item = ls_poitems-po_item.
      APPEND ls_poitemaccountassignm TO ls_details-accounts.
    ENDLOOP.
    APPEND ls_details TO gs_po-details.
    CLEAR: ls_details, ls_details-items[].
  ENDLOOP.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = gs_po.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
**
  lv_str = 'Send Data API to WEB'.
  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'TNF_SENDPO' lv_subrc lv_str.
  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
  lv_text = lv_subrc.
  CONDENSE lv_text1.
  CONCATENATE 'Status Send API : ' lv_text1 INTO lv_text1 SEPARATED BY space.
  lv_str = lv_text1.
  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
**
  return_code = lv_subrc.
  l_name  = p_ebeln.
**  "  CONCATENATE 'b_' l_name INTO l_name.
  CONDENSE l_name.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/inbound/tnf/' 'TNF_SENDPO'.
ENDFORM.                    " F_SEND_API

FORM f_resend_api USING p_param CHANGING return_code
                                         message_error.
  TYPES: BEGIN OF ty_dtl.
           INCLUDE STRUCTURE bapiekpo.
         TYPES:
                  items    TYPE STANDARD TABLE OF bapieket WITH DEFAULT KEY,
                  accounts TYPE STANDARD TABLE OF bapiekkn WITH DEFAULT KEY,
                END OF ty_dtl.
  TYPES: BEGIN OF ty_po.
           INCLUDE STRUCTURE bapiekkol.
         TYPES:
                  details TYPE STANDARD TABLE OF ty_dtl WITH DEFAULT KEY,
                END OF ty_po.
  DATA: gs_po TYPE ty_po.
  DATA: ls_details TYPE ty_dtl.
  DATA: ls_ekko TYPE ekko,
        lt_ekpo TYPE STANDARD TABLE OF ekpo,
        lt_eket TYPE STANDARD TABLE OF eket,
        ls_ekpo LIKE LINE OF lt_ekpo,
        ls_eket LIKE LINE OF lt_eket.

  DATA: lv_ebeln TYPE ekko-ebeln.
  DATA: l_name(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_str          TYPE string.
  DATA: lv_text(15).
  DATA: lv_subrc      TYPE sy-subrc, lv_text1(100).

  DATA:
    items                   LIKE bapimmpara-selection,
    accountassignment       LIKE bapimmpara-selection,
    schedules               LIKE bapimmpara-selection,
    history                 LIKE bapimmpara-selection,
    itemtexts               LIKE bapimmpara-selection,
    headertexts             LIKE bapimmpara-selection,
    confirmations           LIKE bapimmpara-selection,
    services                LIKE bapimmpara-selection,
    poheader                LIKE bapiekkol,
    poaddress               LIKE bapiaddress,
    poitems                 LIKE bapiekpo OCCURS 0, " WITH HEADER LINE,
    ls_poitems              LIKE LINE OF poitems,
    poitemschedules         LIKE bapieket OCCURS 0, " WITH HEADER LINE,
    ls_poitemschedules      LIKE LINE OF poitemschedules,
    poitemaccountassignm    LIKE bapiekkn OCCURS 0,
    ls_poitemaccountassignm LIKE LINE OF poitemaccountassignm,
    return                  LIKE bapireturn OCCURS 0.


  lv_ebeln = p_param.
  TRY.
      CALL FUNCTION 'BAPI_PO_GETDETAIL'
        EXPORTING
          purchaseorder              = lv_ebeln
          items                      = 'X'
          account_assignment         = 'X'
          schedules                  = 'X'
        IMPORTING
          po_address                 = poaddress
          po_header                  = poheader
        TABLES
          return                     = return
          po_items                   = poitems
          po_item_account_assignment = poitemaccountassignm
          po_item_schedules          = poitemschedules
        EXCEPTIONS
          OTHERS                     = 01.
    CATCH cx_root INTO DATA(lo_root_exception).
  ENDTRY.
  IF lo_root_exception IS NOT INITIAL.
    lv_str = 'Data Not Found'.
    PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
    return_code  = 4.
    RETURN.
  ENDIF.

  MOVE-CORRESPONDING poheader TO gs_po.
  LOOP AT poitems INTO ls_poitems WHERE po_number = poheader-po_number.
    MOVE-CORRESPONDING ls_poitems TO ls_details.

    LOOP AT poitemschedules INTO ls_poitemschedules WHERE po_item = ls_poitems-po_item.
      APPEND ls_poitemschedules TO ls_details-items.
    ENDLOOP.
    LOOP AT poitemaccountassignm INTO ls_poitemaccountassignm WHERE po_item = ls_poitems-po_item.
      APPEND ls_poitemaccountassignm TO ls_details-accounts.
    ENDLOOP.
    APPEND ls_details TO gs_po-details.
    CLEAR: ls_details, ls_details-items[].
  ENDLOOP.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = gs_po.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
**
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'TNF_SENDPO' lv_subrc lv_str.
"  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
  lv_text = lv_subrc.
"  CONDENSE lv_text1.
"  CONCATENATE 'Status Send API : ' lv_text1 INTO lv_text1 SEPARATED BY space.
  message_error = lv_str. " = lv_text1.
"  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.
**
  return_code = lv_subrc.
  l_name  = p_ebeln.
**  "  CONCATENATE 'b_' l_name INTO l_name.
  CONDENSE l_name.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/inbound/tnf/' 'TNF_SENDPO'.
ENDFORM.                    " F_SEND_API


*&---------------------------------------------------------------------*
*&      Form  F_PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_STR  text
*----------------------------------------------------------------------*
FORM f_protocol_update  USING   p_msgid p_msgno  p_update.
  DATA: lv_ctr TYPE i, lv_len TYPE i.
  DATA: lv_char1 TYPE char50.
  DATA: lv_char2 TYPE char50.
  DATA: lv_char3 TYPE char50.
  DATA: lv_char4 TYPE char50.
  DATA: lv_char5 TYPE char50.
  DATA: lv_char6 TYPE char50.
  DATA: lv_char7 TYPE char50.
  DATA: lv_char8 TYPE char50.
  DATA: lv_posisi TYPE i.
  DATA: lv_cal TYPE i.
  DATA: lv_text(10).
  DATA: lv_msgty TYPE sy-msgty.
  FIELD-SYMBOLS <fs>. " TYPE ANY.

  FIND 'error' IN p_update.
  IF sy-subrc EQ 0.
    lv_msgty = 'E'.
  ENDIF.


  lv_ctr = strlen( p_update ).
  lv_posisi = 0.
  lv_len = strlen( p_update ).
  lv_cal = 1.
  WHILE lv_ctr > 1.
    IF lv_ctr > 50.
      lv_len = 50.
    ELSE.
      lv_len = lv_ctr.
    ENDIF.
    lv_text = lv_cal.
    CONDENSE lv_text.
    CONCATENATE 'LV_CHAR' lv_text INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = p_update+lv_posisi(lv_len).
    IF lv_ctr > 50.
      lv_ctr = lv_ctr - 50.
      lv_posisi = lv_posisi + 50.
    ELSE.
      EXIT.
    ENDIF.
    ADD 1 TO lv_cal.
    IF lv_cal > 8.
      EXIT.
    ENDIF.
  ENDWHILE.
  TRY.
      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
          msg_arbgb = p_msgid "'ZAB'
          msg_nr    = p_msgno "'000'
          msg_ty    = lv_msgty "'I'
          msg_v1    = lv_char1
          msg_v2    = lv_char2
          msg_v3    = lv_char3
          msg_v4    = lv_char4
        EXCEPTIONS
          OTHERS    = 1.
    CATCH cx_root INTO DATA(lo_root_excep).
  ENDTRY.
  IF lv_char5 IS NOT INITIAL.
    TRY.
        CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
          EXPORTING
            msg_arbgb = p_msgid "'ZAB'
            msg_nr    = p_msgno "'000'
            msg_ty    = lv_msgty "'I'
            msg_v1    = lv_char5
            msg_v2    = lv_char6
            msg_v3    = lv_char7
            msg_v4    = lv_char8
          EXCEPTIONS
            OTHERS    = 1.
      CATCH cx_root INTO lo_root_excep.
    ENDTRY.
  ENDIF.

ENDFORM.                    " F_PROTOCOL_UPDATE


"INCLUDE zspickupf01.
