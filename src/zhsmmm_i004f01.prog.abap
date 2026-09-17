*&---------------------------------------------------------------------*
*&  Include           ZTWSMM_E001F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SEND_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_SUBRC  text
*      -->P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM send_po  USING  p_ebeln return_code us_screen.
  DATA: lv_name(15).
  DATA: ld_name(40).
  TYPES: BEGIN OF ty_eket,
           counter TYPE string, "etenr LIKE eket-etenr,
           delivery_date TYPE string, "eindt LIKE eket-eindt, "delivery date
           slfdt TYPE string, "LIKE eket-slfdt,
           qty_po(20), "menge(20), " LIKE eket-menge,
           no_pr TYPE string, "banfn LIKE eket-banfn,
           item_pr TYPE string, "bnfpo LIKE eket-bnfpo,
           order_date TYPE string, "bedat LIKE eket-bedat,
         END OF ty_eket.

  TYPES: BEGIN OF ty_ekpo,
           item_po TYPE string, "ebelp LIKE ekpo-ebelp,
           po_date TYPE string, "aedat LIKE ekpo-aedat,
           material TYPE string, "matnr LIKE ekpo-matnr,
           description TYPE string, "txz01 LIKE ekpo-txz01,
           plant TYPE string, "werks LIKE ekpo-werks,
           sloc TYPE string, "lgort LIKE ekpo-lgort,
           no_inforecord TYPE string, "infnr LIKE ekpo-infnr,
           description_vendor TYPE string, "idnlf LIKE ekpo-idnlf,
           lewed TYPE string, "LIKE ekpo-lewed,
           qty_detail(20), "ktmng(20),
           "menge(15), " LIKE ekpo-menge,
           uom TYPE string, "meins LIKE ekpo-meins,
           bednr TYPE string, "LIKE ekpo-bednr,
           afnam TYPE string, "LIKE ekpo-afnam,
           schedule TYPE  STANDARD TABLE OF ty_eket WITH NON-UNIQUE DEFAULT KEY,

         END OF ty_ekpo.
  TYPES: BEGIN OF t_ekko,
            no_po TYPE string, "ebeln LIKE  ekko-ebeln,
            bukrs TYPE string, "LIKE  ekko-bukrs,
            bsart TYPE string, "LIKE  ekko-bsart,
            vendor_code TYPE string, "lifnr LIKE  ekko-lifnr,
            vendor_name TYPE string, "name1 LIKE  lfa1-name1,
            bedat TYPE string, "LIKE  ekko-bedat,
            po_date TYPE string, "aedat LIKE  ekko-aedat,
            ekorg  TYPE string, "LIKE  ekko-ekorg,
            ekgrp  TYPE string, "LIKE ekko-ekgrp,
            "lgort  LIKE ekpo-lgort,
            detail TYPE  STANDARD TABLE OF ty_ekpo WITH NON-UNIQUE DEFAULT KEY,
         END OF t_ekko.

  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json             TYPE string.

  DATA: ls_ekko TYPE t_ekko,
        ls_ekpo TYPE ty_ekpo,
        ls_eket TYPE ty_eket.

  DATA: gs_ekko TYPE ekko.
  DATA: gt_zgdmmt004z TYPE STANDARD TABLE OF zgdmmt004z WITH HEADER LINE.
  DATA: gt_ekpo TYPE STANDARD TABLE OF ekpo WITH HEADER LINE.
  DATA: gt_eket TYPE STANDARD TABLE OF eket WITH HEADER LINE.
  DATA: ls_temp(15).
  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.

  SELECT SINGLE * INTO gs_ekko FROM ekko WHERE ebeln = p_ebeln AND loekz EQ space.
  IF sy-subrc EQ 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ekpo FROM ekpo WHERE ebeln = p_ebeln AND loekz EQ space.
    IF gt_ekpo[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt004z FROM zgdmmt004z
        FOR ALL ENTRIES IN gt_ekpo
        WHERE zalno = gt_ekpo-bednr.
      IF sy-subrc NE 0.
        RETURN.
      ENDIF.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_eket FROM eket
         FOR ALL ENTRIES IN gt_ekpo
         WHERE ebeln = gt_ekpo-ebeln AND
               ebelp = gt_ekpo-ebelp.
      IF sy-subrc EQ 0.
        "       MOVE-CORRESPONDING gs_ekko TO ls_ekko.
        SELECT SINGLE name1 INTO ld_name FROM lfa1 WHERE lifnr = gs_ekko-lifnr.
        ls_ekko-no_po = gs_ekko-ebeln.
        ls_ekko-bukrs  = gs_ekko-bukrs.
        ls_ekko-bsart  = gs_ekko-bsart.
        ls_ekko-vendor_code  = gs_ekko-lifnr.
        IF ld_name CN c_alfanumeric.
          PERFORM f_clear_char_json CHANGING  ld_name.
        ENDIF.

        ls_ekko-vendor_name  = ld_name. "gs_ekko-name1
        WRITE gs_ekko-bedat TO ls_temp DD/MM/YYYY..
        ls_ekko-bedat  = ls_temp.
        WRITE gs_ekko-aedat TO ls_temp DD/MM/YYYY..
        ls_ekko-po_date  = ls_temp.
        ls_ekko-ekorg   = gs_ekko-ekorg.
        ls_ekko-ekgrp   = gs_ekko-ekgrp.
        LOOP AT gt_ekpo.
          ls_ekpo-item_po = gt_ekpo-ebelp.
          WRITE gt_ekpo-aedat TO ls_temp DD/MM/YYYY.
          ls_ekpo-po_date = ls_temp. "gt_ekpo-aedat.
          ls_ekpo-material = gt_ekpo-matnr.

          IF gt_ekpo-txz01 CN c_alfanumeric.
            PERFORM f_clear_char_json CHANGING  gt_ekpo-txz01.
          ENDIF.
          IF gt_ekpo-idnlf CN c_alfanumeric.
            PERFORM f_clear_char_json CHANGING  gt_ekpo-idnlf.
          ENDIF.

          ls_ekpo-description = gt_ekpo-txz01.
          ls_ekpo-plant = gt_ekpo-werks.
          ls_ekpo-sloc = gt_ekpo-lgort.
          ls_ekpo-no_inforecord = gt_ekpo-infnr.
          IF gt_ekpo-idnlf IS INITIAL.
            ls_ekpo-description_vendor = gt_ekpo-txz01. "gt_ekpo-idnlf.
          ELSE.
            ls_ekpo-description_vendor = gt_ekpo-idnlf.
          ENDIF.
          ls_ekpo-lewed = gt_ekpo-lewed.
          "           ls_ekpo-gt_ekpo-ktmng(20),
          WRITE gt_ekpo-menge TO ls_ekpo-qty_detail NO-GAP NO-GROUPING DECIMALS 0.
          "menge(15), " LIKE ekpo-menge,
          ls_ekpo-uom = gt_ekpo-meins.
          ls_ekpo-bednr = gt_ekpo-bednr.
          ls_ekpo-afnam = gt_ekpo-afnam.

          LOOP AT gt_eket WHERE ebeln = gt_ekpo-ebeln AND ebelp = gt_ekpo-ebelp.
            "            MOVE-CORRESPONDING gt_eket TO ls_eket.
            ls_eket-counter = gt_eket-etenr.
            WRITE gt_eket-eindt TO ls_temp DD/MM/YYYY.
            ls_eket-delivery_date = ls_temp.
            WRITE gt_eket-slfdt TO ls_temp DD/MM/YYYY.
            ls_eket-slfdt = ls_temp.
            WRITE gt_eket-menge TO ls_eket-qty_po NO-GAP NO-GROUPING DECIMALS 0.
            ls_eket-no_pr = gt_eket-banfn.
            ls_eket-item_pr = gt_eket-bnfpo.
            WRITE gt_eket-bedat TO ls_temp DD/MM/YYYY.
            ls_eket-order_date = ls_temp. "gt_eket-bedat.
            APPEND ls_eket TO ls_ekpo-schedule.
            CLEAR: ls_eket, gt_eket.
          ENDLOOP.
          "          MOVE-CORRESPONDING gt_ekpo TO ls_ekpo.
          APPEND ls_ekpo TO ls_ekko-detail.
          CLEAR: ls_ekpo, gt_ekpo, ls_ekpo-schedule[].
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  DATA:  p_str TYPE string.
  CREATE OBJECT cl_json_data
    EXPORTING
      DATA = ls_ekko.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_SENDPO' sy-subrc p_str. "ztiam_i0001
  "  WRITE: / p_str.
  lv_name = p_ebeln.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_name '/outbound/tnt/' 'HSM_SENDPO'.
  return_code = 0.
ENDFORM.                    " SEND_PO
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_CHAR_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EKPO_TXZ01  text
*----------------------------------------------------------------------*
FORM f_clear_char_json  CHANGING p_string.

  REPLACE ALL OCCURRENCES OF '&' IN p_string WITH ' ' .
  REPLACE ALL OCCURRENCES OF '\''' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '/' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '''' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '"' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '{' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '}' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '[' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF ']' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '>' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '<' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '.' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '~' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '@' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '#' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '$' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '%' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '^' IN p_string WITH ' '.
  REPLACE ALL OCCURRENCES OF '*' IN p_string WITH ' '.


ENDFORM.                    " F_CLEAR_CHAR_JSON
