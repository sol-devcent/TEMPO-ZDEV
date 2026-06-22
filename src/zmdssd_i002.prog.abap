*&---------------------------------------------------------------------*
*& Report  ZSPICKUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmdssd_i002 NO STANDARD PAGE HEADING.

TABLES: nast, vbrk, vbrp, zfidt010.
"INCLUDE rvadtabl.

"INCLUDE zabp_frm.

"INCLUDE zspickuptop.

DATA : gv_kschl   TYPE nast-kschl,
       xscreen(1).

DATA : BEGIN OF t_nast_key,
         vbeln TYPE vbrk-vbeln,
       END OF t_nast_key.



SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS p_vbeln TYPE vbrk-vbeln .
SELECTION-SCREEN END OF BLOCK data.

START-OF-SELECTION.

  nast-objky = p_vbeln.
  PERFORM entry USING sy-subrc sy-subrc.

  "  PERFORM f_send_api USING p_vbeln CHANGING sy-subrc.

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  "  gv_kschl    = nast-kschl.
  "  t_nast_key  = nast-objky.
  p_vbeln     = nast-objky.
  CLEAR: return_code, us_screen.
  PERFORM f_send_api USING p_vbeln CHANGING return_code.
ENDFORM.                    "entry


*&---------------------------------------------------------------------*
*&      Form  F_SEND_API
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_api USING p_tknum CHANGING return_code.
  TYPES: BEGIN OF ty_billing,
           nomor_order_sfa   TYPE string,
           nomor_quotation   TYPE string,
           tanggal_quotation TYPE string,
           nomor_dn          TYPE string,
           tanggal_dn        TYPE string,
           nomor_billing     TYPE string,
           tanggal_billing   TYPE string,
           nomor_shipment    TYPE string,
           tanggal_shipment  TYPE string,
           "            amount type string,
           total_ar(20),
           total_um(20),
           status(1),
           idoc              TYPE string,
         END OF ty_billing.
  DATA: BEGIN OF gs_bill, " OCCURS 0,
          nomor_order_sfa(10) ,
          nomor_quotation(10),
          tanggal_quotation   TYPE sy-datum,
          nomor_dn(10),
          tanggal_dn          TYPE sy-datum,
          nomor_billing(10),
          tanggal_billing     TYPE sy-datum,
          sales_office        TYPE vkbur,
          "            amount type string,
          total_ar            TYPE vbrp-kzwi5,
          total_um            TYPE zfidt010-dmbtr,

        END OF gs_bill.

  DATA: BEGIN OF gt_zfidt010 OCCURS 0,
          vbeva TYPE zfidt010-vbeva,
          dmbtr TYPE zfidt010-dmbtr,
          waers TYPE zfidt010-waers,
        END OF gt_zfidt010.
  DATA : gs_zfidt010 LIKE LINE OF gt_zfidt010,
         gs_billing  TYPE ty_billing.
  DATA: l_name(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_str          TYPE string.
  DATA: lv_text(15).

  SELECT d~submi d~vbeln d~erdat c~vbeln c~erdat b~vbeln b~erdat b~vkbur SUM( b~kzwi5 )
    INTO   gs_bill
    FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                   JOIN likp AS c ON c~vbeln = b~vgbel
                   JOIN vbak AS d ON d~vbeln = b~aubel
    WHERE a~vbeln = p_vbeln
    GROUP BY d~submi d~vbeln d~erdat c~vbeln c~erdat b~vbeln b~erdat b~vkbur.
  ENDSELECT.

  SELECT vbeva SUM( dmbtr ) waers INTO  gs_zfidt010 FROM zfidt010
"        FOR ALL ENTRIES IN gt_vbrp_sum
    WHERE vbeva = gs_bill-nomor_quotation AND
          vkbur = gs_bill-sales_office
    GROUP BY vbeva waers..
  ENDSELECT.
  DATA: lv_tknum TYPE vttp-tknum.
  DATA: lv_erdat TYPE vttp-erdat.

  SELECT SINGLE tknum erdat INTO (lv_tknum, lv_erdat) FROM vttp WHERE vbeln = gs_bill-nomor_dn.

  gs_billing-nomor_order_sfa   = gs_bill-nomor_order_sfa.
  gs_billing-nomor_quotation   = gs_bill-nomor_quotation.
  gs_billing-tanggal_quotation = gs_bill-tanggal_quotation.
  gs_billing-nomor_dn          = gs_bill-nomor_dn.
  gs_billing-tanggal_dn        = gs_bill-tanggal_dn.
  gs_billing-nomor_billing     = gs_bill-nomor_billing.
  gs_billing-tanggal_billing   = gs_bill-tanggal_billing.
  gs_billing-nomor_shipment    = lv_tknum.
  gs_billing-tanggal_shipment  = lv_erdat.
  gs_bill-total_ar = gs_bill-total_ar * 100.
  WRITE gs_bill-total_ar  TO gs_billing-total_ar DECIMALS 0 NO-GROUPING NO-GAP.
  gs_zfidt010-dmbtr = gs_zfidt010-dmbtr * 100.
  WRITE gs_zfidt010-dmbtr  TO gs_billing-total_um DECIMALS 0 NO-GROUPING NO-GAP.
  CLEAR: gs_billing-status, gs_billing-idoc.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = gs_billing.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).

  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'SFA_UPDATE_STS' sy-subrc lv_str.
  PERFORM f_protocol_update USING 'ZAB' '000' lv_str.

  l_name  = p_vbeln.
  "  CONCATENATE 'b_' l_name INTO l_name.
  CONDENSE l_name.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/outbound/mds/api/' 'SFA_UPDATE_STS'.
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
  IF lv_char5 IS NOT INITIAL.
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
  ENDIF.

ENDFORM.                    " F_PROTOCOL_UPDATE


"INCLUDE zspickupf01.
