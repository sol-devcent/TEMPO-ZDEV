*----------------------------------------------------------------------*
***INCLUDE ZRVCFPR00F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EBELN  text
*      <--P_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM send_data USING p_submi LIKE ekko-submi. " type char1.
  DATA: lv_zdata LIKE zhsmmmdt003-zdata.

  DATA: ls_header TYPE ty_header.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json    TYPE string.
  DATA : lv_str     TYPE string.
  DATA: lv_jumlah_rfq TYPE i,
        lv_jumlah_detail TYPE i,
        lv_jumlah_item TYPE i.
  DATA: lp_jumlah_rfq TYPE i,
        lp_jumlah_detail TYPE i,
        lp_jumlah_item TYPE i.
  DATA: ls_ekko LIKE ekko,
        lt_ekko TYPE STANDARD TABLE OF ekko WITH HEADER LINE,
        lt_ekpo TYPE STANDARD TABLE OF ekpo WITH HEADER LINE,
        lt_werks TYPE STANDARD TABLE OF ekpo WITH HEADER LINE,
        lt_t001w TYPE STANDARD TABLE OF t001w WITH HEADER LINE,
        lt_eket TYPE STANDARD TABLE OF eket WITH HEADER LINE,
        lt_eban TYPE STANDARD TABLE OF eban WITH HEADER LINE,
        lt_banfn TYPE STANDARD TABLE OF eket WITH HEADER LINE.
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: gv_nama(15).
  DATA: lv_err(1).
  DATA: lv_text TYPE string.
  DATA: lv_ctr TYPE i, lv_sw.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekko FROM ekko
    WHERE ebeln IN s_ebeln AND
          submi = p_submi AND
          frgke = '1' AND
          loekz EQ space.
  IF lt_ekko[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekpo FROM ekpo
      FOR ALL ENTRIES IN lt_ekko
      WHERE ebeln = lt_ekko-ebeln AND
          loekz EQ space..
    IF lt_ekpo[] IS NOT INITIAL.
      lt_werks[] = lt_ekpo[].
      SORT lt_werks BY werks.
      DELETE ADJACENT DUPLICATES FROM  lt_werks COMPARING werks.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_eket FROM eket
        FOR ALL ENTRIES IN lt_ekpo
        WHERE ebeln = lt_ekpo-ebeln AND
              ebelp = lt_ekpo-ebelp.
      lt_banfn[] = lt_eket[].
      SORT lt_banfn BY banfn bnfpo.
      DELETE ADJACENT DUPLICATES FROM  lt_banfn COMPARING banfn bnfpo.
      IF lt_werks[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t001w FROM t001w
          FOR ALL ENTRIES IN lt_werks
          WHERE werks = lt_werks-werks.
      ENDIF.
      IF lt_banfn[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_eban FROM eban
          FOR ALL ENTRIES IN lt_banfn
          WHERE banfn = lt_banfn-banfn AND
                bnfpo = lt_banfn-bnfpo.
      ENDIF.
    ENDIF.
  ELSE.
    lv_zdata = p_submi.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zhsmmmdt003
      FROM zhsmmmdt003
      WHERE zproses = 'HSM_SENDRFQ' AND status NE 'D' AND zdata = lv_zdata.
    IF sy-subrc EQ 0.
      gs_zhsmmmdt003-status = 'D'.
      MODIFY zhsmmmdt003 FROM gs_zhsmmmdt003.
    ENDIF.
  ENDIF.
  CLEAR: lv_sw, lv_ctr.
  IF p_delete = 'X'.
    WRITE: / 'Delete Tender di WEB : ', p_submi.
    CONCATENATE ' { "tender_no" : "' p_submi '" }  ' INTO gv_json.
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_DELETERFQ' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Message Delete Tender : ', lv_str.
    SKIP 1.
  ENDIF.
  IF lt_ekko[] IS INITIAL.
    WRITE: / 'No Data'.
    EXIT.
    RETURN.
  ENDIF.
  CLEAR: lv_jumlah_rfq, lv_jumlah_item, lv_jumlah_detail.
  WRITE: / 'Send Tender to WEB No. ', p_submi.
  SKIP 1.
  PERFORM f_format_data TABLES lt_ekko lt_ekpo lt_eket lt_t001w lt_eban
                        CHANGING ls_header lv_jumlah_rfq lv_jumlah_item lv_jumlah_detail.
  SKIP 1.
  CLEAR: lt_response_body[].
  WRITE: / 'Get total data from web untuk tender no. ', p_submi.
  CONCATENATE ' { "tender_no" : "' p_submi '" }  ' INTO lt_response_body-line.
  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    'HSM_SENDRFQ'
                                       CHANGING lv_str sy-subrc.
  CONCATENATE 'GET_' p_submi INTO gv_nama.
  PERFORM f_create_text_json(ztdsit_i001) USING lv_str gv_nama '/inbound/tnt/' 'HSM_SENDRFQ'.

  PERFORM f_convert_json USING lv_str CHANGING lp_jumlah_rfq lp_jumlah_detail lp_jumlah_item.

  SKIP 1.
  WRITE: / 'Message : ', lv_str.
  SKIP 1.
  WRITE:  / 'Hasil GET No Tender : ', p_submi,
          / 'Jumlah RFQ : ',     lp_jumlah_rfq,
          / 'Jumlah Detail : ',     lp_jumlah_detail,
          / 'Jumlah Item : ',   lp_jumlah_item.

  WRITE:  / 'Hasil Count No Tender : ', p_submi,
          / 'Jumlah RFQ : ',     lv_jumlah_rfq,
          / 'Jumlah Detail : ',     lv_jumlah_detail,
          / 'Jumlah Item : ',   lv_jumlah_item.
  "  SKIP 2.
  IF lp_jumlah_rfq NE lv_jumlah_rfq OR lp_jumlah_detail NE lv_jumlah_detail OR lp_jumlah_item NE lv_jumlah_item.
    DO 3 TIMES.
      ADD 1 TO lv_ctr.
      lv_sw = 'R'.
      SKIP 3.
      WRITE: / 'Conter resend : ', lv_ctr.
      WRITE: / 'Re-Send Tender to WEB No. ', p_submi.
      CLEAR: lv_jumlah_rfq, lv_jumlah_item, lv_jumlah_detail.
      CLEAR: lp_jumlah_rfq, lp_jumlah_detail, lp_jumlah_item.
      PERFORM f_format_data TABLES lt_ekko lt_ekpo lt_eket lt_t001w lt_eban
                            CHANGING ls_header lv_jumlah_rfq lv_jumlah_item lv_jumlah_detail.
      CLEAR: lt_response_body[].
      WRITE: / 'Re-Get total data from web untuk tender no. ', p_submi.
      CONCATENATE ' { "tender_no" : "' p_submi '" }  ' INTO lt_response_body-line.
      APPEND lt_response_body.
      PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                           USING    'HSM_SENDRFQ'
                                           CHANGING lv_str sy-subrc.
      CONCATENATE 'GET_' p_submi INTO gv_nama.
      PERFORM f_create_text_json(ztdsit_i001) USING lv_str gv_nama '/inbound/tnt/' 'HSM_SENDRFQ'.
      PERFORM f_convert_json USING lv_str CHANGING lp_jumlah_rfq lp_jumlah_detail lp_jumlah_item.
      IF lp_jumlah_rfq NE lv_jumlah_rfq OR lp_jumlah_detail NE lv_jumlah_detail OR lp_jumlah_item NE lv_jumlah_item.
      ELSE.
        lv_sw = 'S'.
        EXIT.
      ENDIF.
    ENDDO.
  ELSE.
    lv_sw = 'S'.
  ENDIF.
  IF lv_sw = 'S'.
    WRITE: / 'Data sudah terkirim semua dan tidak ada selisih'.
    SORT lt_ekpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr.
    RANGES lr_matnr FOR ekpo-matnr.
    RANGES lr_prgrp FOR pgmi-prgrp.
    RANGES lr_psttr FOR plaf-psttr.
    DATA: ld_datum LIKE sy-datum.
    DATA: ld_datum1 LIKE sy-datum.
    DATA: ld_tahun(2). " LIKE sy-datum.)
    IF lt_ekpo[] IS NOT INITIAL.
      LOOP AT lt_ekpo. " INTO ls_ekpo.
        lr_matnr-sign  = 'I'.
        lr_matnr-option = 'EQ'.
        lr_matnr-low = lt_ekpo-matnr.
        APPEND lr_matnr.
      ENDLOOP.
      WRITE: / 'Proses kirim data master Infor record dan Vendor'.
      SUBMIT zhsmmm_i003 WITH s_matnr IN lr_matnr
                  AND RETURN.
      SUBMIT zhsmmm_i005 WITH p_rad1 = 'X'
                         with s_matnr IN lr_matnr
                  AND RETURN.
      lv_zdata = p_submi.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zhsmmmdt003
        FROM zhsmmmdt003
        WHERE zproses = 'HSM_SENDRFQ' AND status NE 'D' AND zdata = lv_zdata.
      IF sy-subrc EQ 0.
        gs_zhsmmmdt003-status = 'D'.
        MODIFY zhsmmmdt003 FROM gs_zhsmmmdt003.
      ENDIF.

****      WRITE: / 'Proses kirim data Send Future Requirement to WEB'.
****      ld_datum = sy-datum.
****      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
****        EXPORTING
****          day_in            = sy-datum
****        IMPORTING
****          last_day_of_month = ld_datum
****        EXCEPTIONS
****          day_in_no_date    = 1
****          OTHERS            = 2.
****      ld_datum = ld_datum + 1.
****      CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
****        EXPORTING
****          months  = 18
****          olddate = ld_datum
****        IMPORTING
****          newdate = ld_datum1.
****      lr_psttr-low = ld_datum.
****      lr_psttr-high = ld_datum1.
****      lr_psttr-sign = 'I'.
****      lr_psttr-option = 'BT'.
****      APPEND lr_psttr.
****      ld_tahun = ld_datum+2(2).
****      CONCATENATE 'P' ld_tahun '*' into lr_prgrp-low.
****      lr_prgrp-sign = 'I'.
****      lr_prgrp-option = 'CP'.
****      APPEND  lr_prgrp.
****      SUBMIT zhsmpp_i001 WITH s_prgrp IN lr_prgrp
****                         WITH s_matnr IN lr_matnr
****                         WITH s_psttr IN lr_psttr
****                         WITH p_back = 'X'
****                  AND RETURN.

    ENDIF.
  ELSE.
    SKIP 5.
    PERFORM send_email USING  p_submi.
  ENDIF.

ENDFORM.                    " SEND_DATA
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_STR  text
*      <--P_LP_JUMLAH_RFQ  text
*      <--P_LP_JUMLAH_DETAIL  text
*      <--P_LP_JUMLAH_ITEM  text
*----------------------------------------------------------------------*
FORM f_convert_json  USING    p_str
                     CHANGING p_jumlah_rfq
                              p_jumlah_detail
                              p_jumlah_item.

  DATA:   lv_json_data     TYPE string,
          lr_data          TYPE REF TO data.

  FIELD-SYMBOLS:
    <data>         TYPE data,
    <data0>        TYPE data,
    <data1>        TYPE data,
    <results>      TYPE ANY,
    <field>        TYPE ANY,
    <field_value>  TYPE data.

  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = lr_data ).
  IF lr_data IS BOUND.
    ASSIGN lr_data->* TO <data0>.
    ASSIGN COMPONENT 'DATA' OF STRUCTURE <data0> TO <results>.
    IF <results> IS ASSIGNED.
      ASSIGN <results>->* TO <data1>.

      ASSIGN COMPONENT 'ITEM_RFQ' OF STRUCTURE <data1> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        p_jumlah_rfq = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.
      ASSIGN COMPONENT 'ITEM_DETAIL' OF STRUCTURE <data1> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        p_jumlah_detail = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.
      ASSIGN COMPONENT 'ITEM_SCHEDULE' OF STRUCTURE <data1> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        p_jumlah_item = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CONVERT_JSON
*&---------------------------------------------------------------------*
*&      Form  F_FORMAT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_EKKO  text
*      -->P_LT_EKPO  text
*      -->P_LT_EKET  text
*      <--P_LV_JUMLAH_RFQ  text
*      <--P_LV_JUMLAH_ITEM  text
*      <--P_LV_JUMLAH_DETAIL  text
*----------------------------------------------------------------------*
FORM f_format_data  TABLES    pt_ekko STRUCTURE ekko
                             pt_ekpo STRUCTURE ekpo
                             pt_eket STRUCTURE eket
                             pt_t001w STRUCTURE t001w
                             pt_eban  STRUCTURE eban
                    CHANGING ps_header TYPE ty_header
                             p_jumlah_rfq
                             p_jumlah_item
                             p_jumlah_detail.

  DATA : ls_t001w TYPE t001w,
         ls_eban TYPE eban,
         ls_ekko    TYPE ekko.
  DATA: lt_eket TYPE STANDARD TABLE OF eket WITH HEADER LINE.
  "  DATA: lt_eina TYPE STANDARD TABLE OF eina WITH HEADER LINE.
  DATA: BEGIN OF lt_pgmi OCCURS 0,
          prgrp LIKE pgmi-prgrp,
          nrmit LIKE pgmi-nrmit,
          maktx LIKE makt-maktx,
        END OF lt_pgmi. "TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: BEGIN OF lt_pgmi1 OCCURS 0,
          prgrp LIKE pgmi-prgrp,
          nrmit LIKE pgmi-nrmit,
          maktx LIKE makt-maktx,
        END OF lt_pgmi1. "TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_ekpo TYPE STANDARD TABLE OF ekpo WITH HEADER LINE.
  DATA: ls_rfq TYPE rfq.
  DATA: ls_tender TYPE tender.
  DATA: ls_header TYPE ty_header.
  DATA: lt_detail TYPE ty_detail OCCURS 0  WITH HEADER LINE.
  DATA: lt_schedule TYPE ty_schedule OCCURS 0  WITH HEADER LINE.
  DATA: ls_detail TYPE ty_detail .
  DATA: ls_schedule TYPE ty_schedule .
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json             TYPE string.
  DATA: lv_ebeln(15).
  DATA : lv_str     TYPE string.
  DATA: lv_monday LIKE sy-datum.
  DATA: lv_jumlah_rfq TYPE i,
        lv_jumlah_detail TYPE i,
        lv_jumlah_item TYPE i.
  DATA: lp_jumlah_rfq TYPE i,
        lp_jumlah_detail TYPE i,
        lp_jumlah_item TYPE i.
  DATA: BEGIN OF lt_makt OCCURS 0,
          matnr LIKE makt-matnr,
          bismt LIKE mara-bismt,
          maktx LIKE makt-maktx,
        END OF lt_makt.
  "  DATA: lt_makt TYPE STANDARD TABLE OF makt WITH HEADER LINE.
  DATA: ls_qty TYPE p DECIMALS 3, ls_round TYPE p DECIMALS 0, ls_qtydetail TYPE p DECIMALS 0.
  DATA: lv_umrez LIKE eina-umrez, lv_umren LIKE eina-umren.
  DATA: ld_prgrp LIKE lt_pgmi-nrmit.
  DATA:  lt_t001 TYPE STANDARD TABLE OF t001 WITH HEADER LINE.
  DATA: lv_text1024 TYPE text1024.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t001 FROM t001
    WHERE bukrs = '8200' OR bukrs = '8190'.

  lt_ekpo[] = pt_ekpo[].
  SORT lt_ekpo BY matnr. " lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr. " lifnr.
  IF lt_ekpo[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_pgmi
      FROM pgmi AS a JOIN makt AS b ON a~prgrp = b~matnr
    FOR ALL ENTRIES IN  lt_ekpo
    WHERE nrmit = lt_ekpo-matnr
      AND werks = '1600'
      AND spras = 'EN'.
    lt_pgmi1[] = lt_pgmi[].
    IF lt_pgmi1[] IS NOT INITIAL.
      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_pgmi
        FROM pgmi AS a JOIN makt AS b ON a~prgrp = b~matnr
      FOR ALL ENTRIES IN  lt_pgmi1
      WHERE nrmit = lt_pgmi1-prgrp
        AND werks = '1600'
        AND spras = 'EN'.
    ENDIF.
    lt_pgmi1[] = lt_pgmi[].
    IF lt_pgmi1[] IS NOT INITIAL.
      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_pgmi
        FROM pgmi AS a JOIN makt AS b ON a~prgrp = b~matnr
      FOR ALL ENTRIES IN  lt_pgmi1
      WHERE nrmit = lt_pgmi1-prgrp
        AND werks = '1600'
        AND spras = 'EN'.
    ENDIF.
  ENDIF.
  DATA: lt_v_einr3 TYPE TABLE OF /sapsll/v_einr3  WITH HEADER LINE.
  DATA: ld_matnr TYPE matnr.
  RANGES lr_matnr FOR makt-matnr.
  lt_ekpo[] = pt_ekpo[].
  DELETE lt_ekpo[] WHERE infnr EQ space.
  DELETE lt_ekpo[] WHERE idnlf EQ space.
  SORT lt_ekpo BY infnr idnlf. " lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING infnr idnlf. " lifnr.
  IF lt_ekpo[] IS NOT INITIAL.
    REFRESH: lr_matnr.
    LOOP AT lt_ekpo.
      ld_matnr = lt_ekpo-idnlf.
      lr_matnr-low = ld_matnr.
      lr_matnr-sign = 'I'.
      lr_matnr-option = 'EQ'.
      APPEND lr_matnr.
      IF ld_matnr NE lt_ekpo-matnr.
        lr_matnr-low = lt_ekpo-matnr.
        lr_matnr-sign = 'I'.
        lr_matnr-option = 'EQ'.
        APPEND lr_matnr.
      ENDIF.
    ENDLOOP.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
      WHERE a~matnr IN lr_matnr AND
            spras = 'EN'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_v_einr3
      FROM /sapsll/v_einr3
      FOR ALL ENTRIES IN lt_ekpo
      WHERE infnr = lt_ekpo-infnr AND
            matnr IN lr_matnr.
  ENDIF.
  CLEAR: lt_eket[].
  SORT pt_eket BY ebeln ebelp eindt.
  LOOP AT pt_eket.
    MOVE-CORRESPONDING pt_eket TO lt_eket.
    CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
      EXPORTING
        date   = pt_eket-eindt
      IMPORTING
        monday = lv_monday.
    lt_eket-eindt = lv_monday.
    COLLECT lt_eket.
  ENDLOOP.
  pt_eket[] = lt_eket[].
  DELETE ADJACENT DUPLICATES FROM lt_pgmi COMPARING ALL FIELDS.
  LOOP AT pt_ekko INTO ls_ekko.
    ls_header-rfq_no  = ls_ekko-ebeln.
    ADD 1 TO lv_jumlah_rfq.
    lv_ebeln = ls_header-rfq_no.
    ls_header-rfq_date  = ls_ekko-bedat.
    ls_header-vendor_code  = ls_ekko-lifnr.
    ls_header-tender_no  = ls_ekko-submi.
    ls_header-start_tender  = ls_ekko-kdatb.
    ls_header-end_submit_tender1  = ls_ekko-bwbdt.
    ls_header-end_submit_quotation  = ls_ekko-angdt.
    ls_header-end_tender  = ls_ekko-kdate.
    ls_header-payment_terms  = ls_ekko-zterm.
    ls_header-currency  = ls_ekko-waers.
    ls_header-purchasing_group = ls_ekko-ekgrp.
    LOOP AT pt_ekpo WHERE ebeln = ls_ekko-ebeln.
      ADD 1 TO lv_jumlah_detail.
      IF pt_ekpo-werks = '1601'.
        TRANSLATE pt_ekpo-afnam TO UPPER CASE.
        CONDENSE: pt_ekpo-afnam.
        lt_detail-company_code   = pt_ekpo-afnam.
        lt_detail-plant   = pt_ekpo-afnam.
        IF pt_ekpo-afnam = '8190'.
          lt_detail-delivery_address = 'PT. Tempo Utama Sejahtera NGORO INDUSTRIAL PARK BLOK D-3A KEL. KUTOGIRANG NGORO MOJOKERTO'.
        ELSEIF  pt_ekpo-afnam = '8200'.
          TRANSLATE pt_ekpo-bednr TO UPPER CASE.
          CONDENSE: pt_ekpo-bednr.
          IF pt_ekpo-bednr(2) = 'NG' OR pt_ekpo-bednr(3) = 'PRN' .
            lt_detail-delivery_address = 'PT.Pritho NGORO INDUSTRIAL PARK BLOK D-3A KEL. KUTOGIRANG NGORO MOJOKERTO'.
          ELSEIF pt_ekpo-bednr(3) = 'PRT' OR pt_ekpo-bednr(3) = 'PRP'.
            lt_detail-delivery_address = 'PT.Pritho JL. KEMUNING NO. 1 CENGKARENG JAKARTA'.
          ELSE.
            lt_detail-delivery_address = 'PT.Pritho JL. KEMUNING NO. 1 CENGKARENG JAKARTA'.
          ENDIF.
        ENDIF.
      ELSE.
        lt_detail-company_code   = pt_ekpo-bukrs.
        lt_detail-plant   = pt_ekpo-werks.
        SORT pt_t001w BY werks.
        READ TABLE pt_t001w INTO ls_t001w WITH KEY werks = pt_ekpo-werks
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          CONCATENATE ls_t001w-name1 ls_t001w-stras ls_t001w-ort01 ls_t001w-pstlz INTO lt_detail-delivery_address SEPARATED BY space.
        ENDIF.
      ENDIF.
      lt_detail-item_rfq   = pt_ekpo-ebelp.
      SORT lt_makt BY matnr.
      READ TABLE lt_makt WITH KEY matnr = pt_ekpo-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        lt_detail-origin_text = lt_makt-maktx..
      ELSE.
        lt_detail-origin_text = pt_ekpo-txz01.
      ENDIF.
      IF pt_ekpo-idnlf IS NOT INITIAL.
        LOOP AT lt_v_einr3 WHERE infnr = pt_ekpo-infnr.
          ld_matnr =  pt_ekpo-idnlf.
          IF lt_v_einr3-matnr = ld_matnr AND lt_v_einr3-idnlf IS NOT INITIAL.
            lt_detail-short_text   = lt_v_einr3-idnlf.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lt_detail-short_text IS INITIAL.
          ld_matnr = pt_ekpo-idnlf.
          SORT lt_makt BY matnr.
          READ TABLE lt_makt WITH KEY matnr = ld_matnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF lt_makt-maktx IS NOT INITIAL.
              lt_detail-short_text   = lt_makt-maktx.
            ENDIF.
          ENDIF.
        ENDIF.
        IF lt_detail-short_text IS INITIAL.
          lt_detail-short_text   = pt_ekpo-txz01.
        ENDIF.
      ELSE.
        lt_detail-short_text   = pt_ekpo-txz01.
      ENDIF.
      lt_detail-material_number   = pt_ekpo-matnr.
      lt_detail-material_vendor   = pt_ekpo-ematn.
      lt_detail-storage_location   = pt_ekpo-lgort.
      CONDENSE: lt_detail-short_text, lt_detail-material_number.
      IF lt_detail-material_number(3) = 'PCC'.
        ld_matnr = pt_ekpo-matnr..
        READ TABLE lt_makt WITH KEY matnr = ld_matnr
        BINARY SEARCH.
        IF lt_makt-bismt IS NOT INITIAL.
          CONCATENATE lt_makt-bismt lt_detail-short_text INTO lt_detail-short_text SEPARATED BY '-'.
        ELSE.
          CONCATENATE lt_detail-material_number lt_detail-short_text INTO lt_detail-short_text SEPARATED BY '-'.
        ENDIF.
      ELSE.
        CONCATENATE lt_detail-material_number lt_detail-short_text INTO lt_detail-short_text SEPARATED BY '-'.
      ENDIF.
      lv_text1024 = lt_detail-short_text.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      lt_detail-short_text = lv_text1024.
      lv_text1024 = lt_detail-origin_text.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      lt_detail-origin_text = lv_text1024.

      PERFORM f_conversion_unit USING pt_ekpo-meins
                                CHANGING lt_detail-uom_rfq.
      lt_detail-uom_vendor = lt_detail-uom_rfq.
      DATA: ls_hitung TYPE p DECIMALS 2.
      ls_qty = pt_ekpo-ktmng. "pt_ekpo-meins.
      CALL FUNCTION 'ROUND'
        EXPORTING
          input         = ls_qty
          sign          = '-'
        IMPORTING
          output        = ls_round
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.
      lt_detail-qty_rfq = ls_qty. "ls_round.
      lt_detail-qty_vendor = ls_qty.
      lt_detail-valid_price = ls_ekko-bnddt.
      CLEAR: ls_qtydetail.
      SORT lt_pgmi BY nrmit.
      READ TABLE lt_pgmi WITH KEY nrmit = pt_ekpo-matnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lt_detail-product_group1_description = lt_pgmi-maktx.
        lt_detail-product_group1 = lt_pgmi-prgrp.
        ld_prgrp = lt_pgmi-prgrp.
      ENDIF.
      SORT lt_pgmi BY nrmit.
      READ TABLE lt_pgmi WITH KEY nrmit = ld_prgrp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lt_detail-product_group2_description = lt_pgmi-maktx.
        lt_detail-product_group2 = lt_pgmi-prgrp.
        ld_prgrp = lt_pgmi-prgrp.
      ENDIF.
      SORT lt_pgmi BY nrmit.
      READ TABLE lt_pgmi WITH KEY nrmit = ld_prgrp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lt_detail-product_group3_description = lt_pgmi-maktx.
        lt_detail-product_group3 = lt_pgmi-prgrp.
        ld_prgrp = lt_pgmi-prgrp.
      ENDIF.
      DATA: ld_product_group_description TYPE string,
            ld_product_group   TYPE string.

      ld_product_group_description = lt_detail-product_group1.
      ld_product_group = lt_detail-product_group1.
      IF lt_detail-product_group3 IS NOT INITIAL.
        lt_detail-product_group1_description = lt_detail-product_group3_description.
        lt_detail-product_group1 = lt_detail-product_group3.
        lt_detail-product_group3_description = ld_product_group_description.
        lt_detail-product_group3 = ld_product_group.
      ELSE.
        lt_detail-product_group1_description = lt_detail-product_group2_description.
        lt_detail-product_group1 = lt_detail-product_group2.
        lt_detail-product_group2_description = ld_product_group_description.
        lt_detail-product_group2 = ld_product_group.
      ENDIF.
**      WRITE: / pt_ekpo-matnr, sy-vline, lt_detail-uom_rfq , sy-vline, lt_detail-uom_vendor, sy-vline, lv_umrez, lv_umren.
      LOOP AT pt_eket WHERE ebeln = pt_ekpo-ebeln AND ebelp = pt_ekpo-ebelp..
        ADD 1 TO lv_jumlah_item.
        lt_schedule-schedule_counter  = pt_eket-etenr.
        lt_schedule-item_delivery_date  = pt_eket-eindt.
**        CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
**          EXPORTING
**            date   = pt_eket-eindt
**          IMPORTING
**            monday = lv_monday.
**        lt_schedule-item_preview_date = lv_monday.
        lt_schedule-item_preview_date = pt_eket-eindt.
        ls_qty = pt_eket-menge. "pt_ekpo-ktmng. "pt_ekpo-meins.
        lt_schedule-qty_schedule = ls_qty. "ls_round.
        CALL FUNCTION 'ROUND'
          EXPORTING
            input         = ls_qty
            sign          = '-'
          IMPORTING
            output        = ls_round
          EXCEPTIONS
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            OTHERS        = 4.
        ADD ls_round TO ls_qtydetail.
        lt_schedule-qty_schedule = ls_round. "ls_qty..
        lt_schedule-schedule_vendor = ls_round.
**        WRITE: / 'Qty Schedule : ', lt_schedule-qty_schedule.
**        WRITE: / 'Qty Vendor : ', lt_schedule-schedule_vendor.
        CONDENSE: lt_schedule-schedule_vendor, lt_schedule-qty_schedule.
        lt_schedule-pr_number  = pt_eket-banfn.
        lt_schedule-item_pr  = pt_eket-bnfpo.
        SORT pt_eban BY banfn bnfpo.
        READ TABLE pt_eban INTO ls_eban WITH KEY banfn = pt_eket-banfn
                                    bnfpo = pt_eket-bnfpo
                                    BINARY SEARCH.
        IF sy-subrc EQ 0.
          lt_schedule-indicator = ls_eban-frgkz.
        ENDIF.
        APPEND lt_schedule.
        APPEND lt_schedule TO lt_detail-schedule.
        CLEAR: lt_schedule.
      ENDLOOP.
      lt_detail-qty_rfq = ls_qtydetail.
      lt_detail-qty_vendor =  ls_qtydetail.
      CONDENSE: lt_detail-qty_rfq, lt_detail-qty_vendor.
**      WRITE: / pt_ekpo-matnr, sy-vline, lt_detail-uom_rfq , sy-vline, lt_detail-uom_vendor, sy-vline, lv_umrez, lv_umren, sy-vline, ls_qtydetail.
      CLEAR: ls_qtydetail.

      APPEND lt_detail.
      APPEND lt_detail TO ls_header-detail.
      CLEAR: lt_schedule[], lt_detail.
    ENDLOOP.
    MOVE-CORRESPONDING ls_header TO ls_rfq-header.
    APPEND ls_header TO ls_tender-rfq.
    CLEAR: ls_header, ls_header-detail[].
    CLEAR: lt_schedule[], lt_detail[].
    IF ls_tender-rfq[] IS NOT INITIAL.
      WRITE: / 'Send RFQ to WEB no. ', lv_ebeln.
      CREATE OBJECT cl_json_data
        EXPORTING
          DATA = ls_tender.
      cl_json_data->serialize( ).
      gv_json = cl_json_data->get_data( ).

      REPLACE ALL OCCURRENCES OF '\' IN gv_json WITH '' .
      REPLACE ALL OCCURRENCES OF '&' IN gv_json WITH '' .

      PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_SENDRFQ' sy-subrc lv_str. "ztiam_i0001
      FIND 'false' IN lv_str.
      IF sy-subrc EQ 0.
        WRITE: / 'Message Error : ', lv_str.
      ELSE.
        WRITE: / 'Message : ', lv_str.
      ENDIF.
      SKIP 1.
      CONDENSE lv_ebeln.
      CONCATENATE 'SEND' lv_ebeln INTO lv_ebeln.
      PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_ebeln '/outbound/tnt/' 'HSM_SENDRFQ'.
    ENDIF.
    CLEAR: ls_rfq-header, gv_json, lv_str, ls_tender, ls_tender-rfq[], ls_rfq.
    CLEAR: lt_detail[], lt_schedule[], ls_header, ls_header-detail[].
  ENDLOOP.
  p_jumlah_rfq = lv_jumlah_rfq.
  p_jumlah_item = lv_jumlah_item.
  p_jumlah_detail = lv_jumlah_detail.

ENDFORM.                    " F_FORMAT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_UNIT
*&---------------------------------------------------------------------*
FORM f_conversion_unit  USING    fu_meins
                        CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_UNIT
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .

ENDFORM.                    " F_PRINT_DATA
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SUBMI  text
*----------------------------------------------------------------------*
FORM send_email  USING p_submi.

  DATA: send_request TYPE REF TO cl_bcs,
        lv_sent_to_all TYPE os_boolean,
        mailsubject TYPE so_obj_des,
        mailtext TYPE bcsy_text,
        document TYPE REF TO cl_document_bcs,
        sender TYPE REF TO cl_cam_address_bcs,
        recipient_to TYPE REF TO cl_cam_address_bcs,
        recipient_cc TYPE REF TO cl_cam_address_bcs,
        recipient_bcc TYPE REF TO cl_cam_address_bcs,
        bcs_exception TYPE REF TO cx_bcs.
  DATA: lv_message(150).
  DATA: lv_email TYPE ad_smtpadr. " ADR6-SMTP_ADDR.
  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc WITH HEADER LINE.
  TRY.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tvarvc FROM tvarvc WHERE name = 'ZHSMMM_E002'.
      send_request = cl_bcs=>create_persistent( ).
**                1         2         3         4         5
**       12345678901234567890123456789012345678901234567890
**      '[e-Procurement]-Send Tender no. 1234567890 to Web'
      CONCATENATE '[e-Procurement]-Send Tender no.' p_submi  'To Web' INTO mailsubject SEPARATED BY space.
      "      mailsubject = '[Tempo e-Procurement]-Send Tender to Web'.
      WRITE: / 'Isi Body Message : '.
      CONCATENATE '<br>Tender/Collective no ' p_submi '</br>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br>Mohon dikirim ulang dengan menjalankan program ZHSMMM_I002 </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br>Massukan no colletive no diatas </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      lv_message = '<br></br><br></br><br>Terima kasih </br>'.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.
      CONCATENATE '<br></br><br></br><br> Email Auto Generated by System </br> <br> </br> <br> </br> <br>' sy-uname  '</br></P>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.
      WRITE: / lv_message.

      document = cl_document_bcs=>create_document(
       i_type = 'HTM'
       i_text = mailtext
       i_subject = mailsubject ).
      send_request->set_document( document ).




      send_request->set_document( document ).
      sender = cl_cam_address_bcs=>create_internet_address( 'eproc_info@thetempogroup.com' ).
      send_request->set_sender( sender ).

**      recipient_to = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ). "'budi.p@TheTempoGroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_to ).

      LOOP AT lt_tvarvc WHERE opti = 'TO'.
        lv_email = lt_tvarvc-low.
        recipient_to = cl_cam_address_bcs=>create_internet_address( lv_email ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
      ENDLOOP.

      LOOP AT lt_tvarvc WHERE opti = 'CC'.
        lv_email = lt_tvarvc-low.
        recipient_cc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).
      ENDLOOP.
**        sender = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**        send_request->add_recipient( i_recipient = recipient_cc
**        i_blind_copy = 'X' ).


      LOOP AT lt_tvarvc WHERE opti = 'BC'.
        lv_email = lt_tvarvc-low.
        recipient_bcc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_blind_copy = 'X' ).
      ENDLOOP.

**        sender = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**        send_request->add_recipient( i_recipient = recipient_bcc
**        i_blind_copy = 'X' ).

      IF lt_tvarvc[] IS INITIAL.
        recipient_to = cl_cam_address_bcs=>create_internet_address( 'Support.Center@TheTempoGroup.com' ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
        recipient_cc = cl_cam_address_bcs=>create_internet_address( 'sekar.mulya@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).
        recipient_cc = cl_cam_address_bcs=>create_internet_address( 'prayogo.s@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).

        recipient_bcc = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_copy = 'X' ).
      ENDIF.

**      sender = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**      send_request->set_sender( sender ).
**
**      recipient_to = cl_cam_address_bcs=>create_internet_address( 'Support.Center@TheTempoGroup.com' ). "'budi.p@TheTempoGroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_to ).
**
**      recipient_cc = cl_cam_address_bcs=>create_internet_address( 'sekar.mulya@thetempogroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_cc
**      i_copy = 'X' ).
**
**      recipient_bcc = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_bcc
**       i_blind_copy = 'X' ).

*    data(lv_sent_to_all) = send_request->send( ).
      lv_sent_to_all = send_request->send( ).
      IF lv_sent_to_all = 'X'.
        WRITE: / 'Email sent to all recipients'.
      ELSE.
        WRITE: / 'Email could not be sent to all recipients!'.
      ENDIF.

      COMMIT WORK.

    CATCH cx_bcs INTO bcs_exception.

      WRITE: 'Error occurred while sending email: Error Type', bcs_exception->error_type.

  ENDTRY.

ENDFORM.                    " SEND_EMAIL
