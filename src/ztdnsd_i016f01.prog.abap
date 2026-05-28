*----------------------------------------------------------------------*
***INCLUDE ZTDNSD_I016F01 .
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data. " CHANGING p_err.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_s642
    FROM s642 AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE sptag IN s_sptag
      AND a~vbeln IN s_vbeln
      AND aunr3 IN s_aunr3
      AND po_int IN s_point
      AND doint IN s_doint
      AND docust IN s_docust
      AND vstel = p_vstel
      AND wbstk = 'C'.
  gt_s642_all[] = gt_s642[].

  IF r_rad2 = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_s642_po FROM s642
      WHERE sptag IN s_sptag
        AND vbeln IN s_vbeln
        AND aunr3 IN s_aunr3
        AND po_int EQ space
        AND vkbur EQ p_vstel.
  ELSEIF r_rad3 = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_s642 FROM s642
      WHERE sptag IN s_sptag
"        AND po_int NE space
        AND vbeln IN s_vbeln
        AND aunr3 IN s_aunr3
        AND po_int IN s_point
        AND vkbur EQ p_vstel.
    gt_s642_all[] = gt_s642[].
  ELSEIF r_rad7 = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_s642 FROM s642
      WHERE sptag IN s_sptag
"        AND doint NE space
        AND koflg NE 'X'
        AND vkbur EQ p_vstel
        AND doint IN s_doint.
    gt_s642_all[] = gt_s642[].
  ENDIF.

ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SEND_API
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_api .
**  DATA : cl_json_data   TYPE REF TO zcl_trex_json_serializer,
**         lv_json        TYPE string.
**  DATA: lv_name(15).
**  DATA: p_str TYPE string.
**  data: lv_proses TYPE char15.
**
**  CREATE OBJECT cl_json_data
**    EXPORTING
**      DATA = i_stock.
**  cl_json_data->serialize( ).
**  lv_json = cl_json_data->get_data( ).
**  lv_proses = p_proses.
**  PERFORM f_post_data_json(ztdsit_i001) USING lv_json lv_proses sy-subrc p_str.
**  write: / lv_proses, sy-vline, sy-subrc, sy-vline, p_str.
**  lv_name = sy-datum.
**  CONCATENATE 'STOCK' lv_name INTO lv_name SEPARATED BY '_'.
**  PERFORM f_create_text_json(ztdsit_i001) USING lv_json lv_name '/outbound/tdn/' lv_proses.
**  write:/ lv_proses, sy-vline, sy-subrc, lv_name.

ENDFORM.                    " F_SEND_API

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_MATDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_matdoc .
  DATA: lv_nourut TYPE num10.
  DATA: ls_s642 TYPE s642.

  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
         "gt_return           TYPE STANDARD TABLE OF bapiret2,
         gs_item          LIKE LINE OF goodsmvt_item,
         wueb             TYPE STANDARD TABLE OF wueb,
         lv_vkbur         TYPE vkbur,
         lv_lifnr         TYPE lifnr,
         lv_kunnr         TYPE kunnr..
**** table T001W --> plant dengan customer dan vendor
  IF gt_saunr3[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
      JOIN vbuk AS c ON a~vbeln = c~vbeln
      FOR ALL ENTRIES IN gt_saunr3
      WHERE a~vbeln = gt_saunr3-vbeln
        AND wbstk = 'C'.
  ENDIF.

  CLEAR: lv_nourut, gs_docflow, gt_docflow[].
  lv_nourut = '1000000000'.
  DELETE gt_likp[] WHERE lfimg = 0.
  SORT gt_likp BY vstel wadat_ist matnr charg.
  LOOP AT gt_likp INTO gs_likp. " WHERE vbeln = gs_s642-vbeln.
    lv_kunnr = gs_likp-kunnr.
    AT NEW wadat_ist.
      ADD 10 TO lv_nourut.
      SELECT SINGLE bwkey INTO lv_vkbur  FROM  t001w AS a JOIN knvp AS b ON a~lifnr = b~lifnr
        WHERE b~kunnr = lv_kunnr AND parvw = 'LF'.
      IF p_vstel = lv_vkbur.
        EXIT.
      ENDIF.
    ENDAT.
    gs_aunr3-nourut = lv_nourut.
    gs_aunr3-kunnr = gs_likp-kunnr.
    gs_aunr3-wadat_ist = gs_likp-wadat_ist.
    gs_aunr3-vstel = gs_likp-vstel.
    gs_aunr3-lfart = gs_likp-lfart.
    gs_aunr3-matnr = gs_likp-matnr.
    gs_aunr3-charg = gs_likp-charg.
    gs_aunr3-lgort = gs_likp-lgort.
    gs_aunr3-werks = gs_likp-werks.
    gs_aunr3-lfimg = gs_likp-lfimg.
    gs_aunr3-vrkme = gs_likp-vrkme.
    gs_aunr3-vkbur = lv_vkbur.
    gs_likp-nourut = lv_nourut.
    gs_likp-vkbur = lv_vkbur.
    COLLECT gs_aunr3 INTO gt_aunr3.
    gs_docflow-vstel = gs_likp-vstel.
    gs_docflow-nourut = lv_nourut.
    gs_docflow-vbeln  = gs_likp-vbeln.
    gs_docflow-vkbur = lv_vkbur.
    APPEND gs_docflow TO gt_docflow.
    MODIFY gt_likp FROM gs_likp TRANSPORTING nourut vkbur.
  ENDLOOP.
  IF lv_vkbur = p_vstel.
    LOOP AT gt_saunr3 INTO ls_s642.
      LOOP AT gt_s642_all INTO gs_s642 WHERE vbeln = ls_s642-vbeln..
        gs_s642-aunr3 = '0000000000'.
        gs_s642-vkbur = lv_vkbur.
        MODIFY s642 FROM gs_s642.
        COMMIT WORK AND WAIT.
      ENDLOOP.
    ENDLOOP.
  ELSE.
    SORT gt_docflow BY nourut vbeln.
    DELETE ADJACENT DUPLICATES FROM gt_docflow COMPARING ALL FIELDS.
    SORT gt_aunr3 BY nourut wadat_ist.
    LOOP AT gt_aunr3 INTO gs_aunr3.
      lv_nourut = gs_aunr3-nourut.
      goodsmvt_code  = '04'.
      goodsmvt_header-ver_gr_gi_slip    = '3'.
      goodsmvt_header-ver_gr_gi_slipx   = 'X'.
      IF gs_aunr3-wadat_ist(6) = sy-datum(6).
        goodsmvt_header-pstng_date        = gs_aunr3-wadat_ist.
      ELSE.
        IF gv_xruem = 'X'.
          goodsmvt_header-pstng_date        = gs_aunr3-wadat_ist.
        ELSE.
          IF gv_usrtrd IS NOT INITIAL.
            sy-datum+6(2) = '01'.
            goodsmvt_header-pstng_date        = sy-datum.
          ENDIF.
        ENDIF.
**        IF gv_usrtrd IS NOT INITIAL.
**        ELSE.
**        ENDIF.
      ENDIF.
**        goodsmvt_header-ref_doc_no  = lv_vbeln.
      goodsmvt_header-header_txt  = sy-datum.
      goodsmvt_header-doc_date          = goodsmvt_header-pstng_date. "sy-datum.

      gs_item-material      = gs_aunr3-matnr.
      gs_item-batch         = gs_aunr3-charg.
      gs_item-entry_qnt     = gs_aunr3-lfimg.
      gs_item-entry_uom     = gs_aunr3-vrkme.
      gs_item-move_type     = '301'.
      gs_item-plant         = gs_aunr3-werks."0223
      gs_item-move_plant    = gs_aunr3-vkbur. "'0203'. " gs_aunr3-werks.
      gs_item-stge_loc      = '1099'. "gs_aunr3-lgort. "1099
      gs_item-move_stloc    = '1099'. "gs_aunr3-lgort. "
      lv_vkbur = gs_aunr3-vkbur.
      APPEND gs_item TO goodsmvt_item.
      AT END OF nourut.
        SORT goodsmvt_item BY deliv_numb po_number po_item deliv_item.
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
        LOOP AT return.
          IF return-type NE 'S'.
            WRITE: / return-message, sy-vline,
                     return-type.
          ENDIF.
          CLEAR return.
        ENDLOOP.
        IF materialdocument IS NOT INITIAL.
          SKIP 1.
          WRITE: / 'Mat. doc terbentuk : ', materialdocument.
          LOOP AT gt_docflow INTO gs_docflow WHERE nourut = lv_nourut.
            gs_docflow-aunr3 = materialdocument.
            gs_docflow-vkbur = lv_vkbur.
            MODIFY gt_docflow FROM gs_docflow TRANSPORTING aunr3 vkbur.
          ENDLOOP.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
        CLEAR: materialdocument, matdocumentyear, goodsmvt_header, goodsmvt_code, goodsmvt_item[], goodsmvt_item, return[], return.
      ENDAT.
    ENDLOOP.
    SORT gt_docflow BY nourut vbeln aunr3.
    DELETE gt_docflow[] WHERE aunr3 IS INITIAL.
    SKIP 1.
    "  WRITE: / 'Update to table S642'.
    LOOP AT gt_docflow INTO gs_docflow. " WHERE nourut = lv_nourut.
      LOOP AT gt_s642_all INTO gs_s642 WHERE vbeln = gs_docflow-vbeln..
        gs_s642-aunr3 = gs_docflow-aunr3.
        gs_s642-vkbur = gs_docflow-vkbur.
        WRITE: /  gs_s642-sptag, sy-vline,
                  gs_s642-vbeln, sy-vline,
                  gs_s642-aunr3.
        MODIFY s642 FROM gs_s642.
        COMMIT WORK AND WAIT.
        APPEND gs_s642  TO gt_spoint.
        MODIFY gt_s642_all FROM gs_s642.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROSES_MATDOC
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POINTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_pointer .
  DATA: lt_poitem      LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poitemx     LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
        lt_poschedule  LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
        lt_poschedulex LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE,
        lt_return      LIKE  bapiret2 OCCURS 0 WITH HEADER LINE.
  DATA: lv_ebeln     LIKE ekpo-ebeln,
        ls_poheader  TYPE bapimepoheader,
        ls_poheaderx TYPE bapimepoheaderx.
  DATA: lt_t16fs LIKE t16fs  OCCURS 0 WITH HEADER LINE,
        ls_ekko  LIKE ekko,
        ld_frggr LIKE ekko-frggr,
        ld_frgsx LIKE ekko-frgsx.
  DATA: l_pincr LIKE t161-pincr.
  DATA: l_ctr TYPE i.
  DATA: lv_aunr3 LIKE s642-aunr3.
  DATA: lv_sptag LIKE s642-sptag.
  DATA: lv_vkbur TYPE vkbur.
  DATA: lv_lifnr TYPE lifnr.
  DATA: ld_procstat LIKE ekko-procstat. "--> status release PO jika = '05'
  DATA: lv_lgort TYPE lgort.
  DATA: lv_field_value4 TYPE zscust_control-field_value4,
        lv_field_value  TYPE zscust_control-field_value.
  DATA: lt_vkbur TYPE STANDARD TABLE OF s642.
  DATA: ls_s642 TYPE s642.
  DATA: lt_spoint TYPE STANDARD TABLE OF s642.  "khusus untuk supply dari cabang yg sama
  DATA: lv_nourut TYPE num10.

  SORT gt_spoint BY sptag aunr3.
  lt_spoint[] = gt_spoint[].
  SORT lt_spoint BY sptag aunr3.
  DELETE ADJACENT DUPLICATES FROM gt_spoint COMPARING aunr3.
  DELETE ADJACENT DUPLICATES FROM lt_spoint COMPARING sptag aunr3.
  CLEAR: lv_lifnr, lv_vkbur, lt_vkbur[].
  SORT gt_spoint BY aunr3.
  DELETE gt_spoint[] WHERE  aunr3 = '0000000000'.
  DELETE lt_spoint[] WHERE  aunr3 NE '0000000000'.
  DELETE ADJACENT DUPLICATES FROM gt_spoint COMPARING aunr3.
  IF gt_spoint[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_mseg FROM mseg
      FOR ALL ENTRIES IN gt_spoint
      WHERE mblnr = gt_spoint-aunr3
        AND shkzg = 'H'.
  ENDIF.
  lt_vkbur[] = gt_spoint[].
  SORT lt_vkbur BY vstel sptag vkbur.
  DELETE ADJACENT DUPLICATES FROM gt_spoint COMPARING vstel sptag vkbur.
  BREAK tds_dev01.
  CLEAR: gt_docflow[], l_pincr.
  WRITE: / 'Prepare data for PO Inter dan DO Inter'.
  SELECT SINGLE pincr INTO l_pincr FROM t161 WHERE bstyp = 'F' AND bsart = 'ZUBT'.

  SORT gt_spoint BY vstel sptag vkbur aunr3.
  LOOP AT lt_vkbur INTO ls_s642.
    CLEAR: lv_vkbur, lv_field_value, lv_lgort, lv_lifnr.

    lv_vkbur = ls_s642-vkbur.
    lv_field_value = lv_vkbur.
    CONDENSE lv_field_value.
    SELECT SINGLE field_value4 INTO lv_field_value4 FROM zscust_control
      WHERE vkorg = '8380'
        AND cek = 'ERT'
        AND field_value = lv_field_value.
    lv_lgort = lv_field_value4(4).
    SORT gt_spoint BY vstel sptag aunr3.
    SELECT SINGLE lifnr INTO lv_lifnr FROM t001w WHERE werks = lv_vkbur.

    LOOP AT gt_spoint INTO gs_s642 WHERE sptag = ls_s642-sptag AND vkbur = ls_s642-vkbur AND aunr3 = ls_s642-aunr3.
      CLEAR: gt_point[].
      gs_point-aunr3 = gs_s642-aunr3.
      gs_point-sptag = gs_s642-sptag.
      gs_point-vstel = gs_s642-vstel.
      gs_point-vkbur = gs_s642-vkbur.
      "      lv_vkbur = gs_s642-vkbur.
      SORT gt_mseg BY mblnr matnr.
      LOOP AT gt_mseg INTO gs_mseg WHERE mblnr = gs_s642-aunr3.
        gs_point-matnr = gs_mseg-matnr.
        gs_point-menge = gs_mseg-menge.
        gs_point-meins = gs_mseg-meins.
        COLLECT gs_point INTO gt_point.
      ENDLOOP.

      CLEAR: l_ctr.
      CLEAR: ls_poheader, ls_poheaderx, lt_poitem[], lt_poitemx[], lt_return[], l_ctr.
      LOOP AT gt_point INTO gs_point.
*   Header Data
        ls_poheader-comp_code = '8380'.
        ls_poheaderx-comp_code = 'X'.
        ls_poheader-doc_type = 'ZB'.
        ls_poheaderx-doc_type = 'X'.
        ls_poheader-creat_date = sy-datum.
        ls_poheaderx-creat_date = 'X'.
        ls_poheader-created_by = sy-uname.
        ls_poheaderx-created_by = 'X'.
        ls_poheader-item_intvl = '10'.
        ls_poheaderx-item_intvl = 'X'.
        ls_poheader-vendor = lv_lifnr. "'TSB0203'.  "--> perlu ada cara mendapatkan kode vendor
        ls_poheaderx-vendor = 'X'.
        ls_poheader-suppl_plnt = gs_point-vkbur. "'0203'. "--> supply plant harus di cari
        ls_poheaderx-suppl_plnt = 'X'.
        ls_poheader-langu = sy-langu.
        ls_poheaderx-langu = 'X'.
        ls_poheader-purch_org = 'TDN'.
        ls_poheaderx-purch_org = 'X'.
        ls_poheader-pur_group = 'TDN'.
        ls_poheaderx-pur_group = 'X'.
        ls_poheader-incoterms1 = 'TRD'.
        ls_poheaderx-incoterms1 = 'X'.
        ls_poheader-incoterms2  = 'Tempo Retail Development'.
        ls_poheaderx-incoterms2  = 'X'.
        ADD l_pincr TO l_ctr.
        CLEAR: lt_poitem, lt_poitemx.
        lt_poitem-po_item = l_ctr.
        lt_poitem-material = gs_point-matnr.
        lt_poitem-quantity = gs_point-menge.
        lt_poitem-po_unit = gs_point-meins.
        lt_poitem-item_cat = '0'.
        lt_poitem-incoterms1 = 'TRD'.
        lt_poitem-incoterms2 = 'Tempo Retail Development'.
        lt_poitem-suppl_stloc = '1099'.
        lt_poitem-plant = '3800'.
        lt_poitem-stge_loc = lv_lgort. "'1099'.
        lt_poitem-plan_del = '0'. "sy-datum'.
        lt_poitem-no_rounding = 'X'.
        lt_poitem-part_deliv = 'A'.
        APPEND  lt_poitem.
        lt_poitemx-po_item = l_ctr.
        lt_poitemx-material = 'X'. "wa_detail-material.
        lt_poitemx-quantity = 'X'. "wa_detail-qty.
        lt_poitemx-po_unit = 'X'. "wa_detail-satuan.
        lt_poitemx-item_cat = 'X'. "'7'.
        lt_poitemx-incoterms1 = 'X'. "'TDN'.
        lt_poitemx-incoterms2 = 'X'. "'TDN Toko Obat'.
        lt_poitemx-suppl_stloc = 'X'. "'1000'.
        lt_poitemx-plant = 'X'. "lv_knvv-vkbur.
        lt_poitemx-stge_loc = 'X'. "'10T0'.
        lt_poitemx-preq_name = 'X'.
        lt_poitemx-plan_del = 'X'.
        lt_poitemx-no_rounding = 'X'.
        lt_poitemx-part_deliv = 'X'.
        APPEND  lt_poitemx.
        lv_aunr3 = gs_point-aunr3.
        CLEAR: lv_ebeln, lt_poitem, lt_poitemx.
        AT END OF aunr3.
          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = ls_poheader
              poheaderx        = ls_poheaderx
            IMPORTING
              exppurchaseorder = lv_ebeln
            TABLES
              return           = lt_return
              poitem           = lt_poitem
              poitemx          = lt_poitemx.
          IF lv_ebeln IS NOT INITIAL.
            LOOP AT lt_return.
              WRITE: / lt_return-message.
            ENDLOOP.
            SKIP 1.
            WRITE: / 'No PO Inter : ', lv_ebeln.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
            CALL FUNCTION 'ZFMWAIT'.
            SELECT SINGLE * INTO ls_ekko
              FROM ekko WHERE ebeln = lv_ebeln.
            IF sy-subrc EQ 0.
              SELECT * INTO TABLE lt_t16fs
                FROM t16fs
                WHERE frggr = ls_ekko-frggr AND
                      frgsx = ls_ekko-frgsx.
              IF sy-subrc EQ 0.
                LOOP AT lt_t16fs.
                  IF lt_t16fs-frgc1 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc1 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc2 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc2 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc3 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc3 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc4 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc4 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc5 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc5 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc6 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc6 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc7 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc7 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc8 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc8 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
            LOOP AT gt_spoint INTO s642 WHERE aunr3 = lv_aunr3.
              gs_s642-po_int = lv_ebeln.
              MODIFY gt_spoint FROM gs_s642 TRANSPORTING po_int doint.
            ENDLOOP.
            LOOP AT gt_s642_all INTO gs_s642 WHERE aunr3 = lv_aunr3.
              gs_s642-po_int = lv_ebeln.
              MODIFY s642 FROM gs_s642.
              MODIFY gt_s642_all FROM gs_s642 TRANSPORTING po_int doint.
            ENDLOOP.
            CLEAR: lv_ebeln, lv_aunr3.
          ELSE.
            LOOP AT lt_return.
              WRITE: / lt_return-message.
            ENDLOOP.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
          CLEAR: ls_poheader, ls_poheaderx, lt_poitem[], lt_poitemx[], lt_return[], l_ctr, lt_poitem, lt_poitemx, lt_return .
        ENDAT.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
**    DATA: ls_s642 TYPE s642.
**  DATA: lt_spoint TYPE STANDARD TABLE OF s642.  "khusus untuk supply dari cabang yg sama
  CLEAR: gt_spoint[].
  LOOP AT lt_spoint INTO ls_s642.
    LOOP AT gt_s642_all INTO gs_s642 WHERE aunr3 = ls_s642-aunr3
                                       AND sptag = ls_s642-sptag
                                       AND vkbur = ls_s642-vkbur
                                       AND vstel = ls_s642-vstel.
      WRITE: / gs_s642-vbeln,  gs_s642-sptag.
      APPEND gs_s642 TO gt_spoint.
    ENDLOOP.
  ENDLOOP.
  IF gt_spoint[] IS NOT INITIAL.
    lt_vkbur[] = gt_spoint[].
    SORT lt_vkbur BY vkbur.
    DELETE ADJACENT DUPLICATES FROM lt_vkbur COMPARING vkbur.
    BREAK tds_dev01.
    CLEAR: gt_docflow[], l_pincr.
    WRITE: / 'Prepare data for PO Inter dan DO Inter'.
    SELECT SINGLE pincr INTO l_pincr FROM t161 WHERE bstyp = 'F' AND bsart = 'ZUBT'.
    SORT gt_spoint BY vstel sptag vkbur aunr3.
    CLEAR: gt_likp[].
    IF gt_spoint[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
        JOIN vbuk AS c ON a~vbeln = c~vbeln
        FOR ALL ENTRIES IN gt_spoint
        WHERE a~vbeln = gt_spoint-vbeln
          AND wbstk = 'C'.
    ENDIF.

    CLEAR: lv_nourut, gs_docflow, gt_docflow[].
    lv_nourut = '1000000000'.
    DELETE gt_likp[] WHERE lfimg = 0.
    SORT gt_likp BY vstel wadat_ist matnr charg.
    LOOP AT lt_vkbur INTO ls_s642.
      CLEAR: lv_vkbur, lv_field_value, lv_lgort, lv_lifnr.
      lv_vkbur = ls_s642-vkbur.
      lv_field_value = lv_vkbur.
      CONDENSE lv_field_value.
      SELECT SINGLE field_value4 INTO lv_field_value4 FROM zscust_control
        WHERE vkorg = '8380'
          AND cek = 'ERT'
          AND field_value = lv_field_value.
      lv_lgort = lv_field_value4(4).
      SORT gt_spoint BY vstel sptag aunr3.
      SELECT SINGLE lifnr INTO lv_lifnr FROM t001w WHERE werks = lv_vkbur.
    ENDLOOP.
    LOOP AT gt_likp INTO gs_likp. " WHERE vbeln = ls_s642-vbeln.
      AT NEW wadat_ist.
        ADD 10 TO lv_nourut.
      ENDAT.
      gs_aunr3-nourut = lv_nourut.
      gs_aunr3-kunnr = gs_likp-kunnr.
      gs_aunr3-wadat_ist = gs_likp-wadat_ist.
      gs_aunr3-vstel = gs_likp-vstel.
      gs_aunr3-lfart = gs_likp-lfart.
      gs_aunr3-matnr = gs_likp-matnr.
      gs_aunr3-charg = gs_likp-charg.
      gs_aunr3-lgort = gs_likp-lgort.
      gs_aunr3-werks = gs_likp-werks.
      gs_aunr3-lfimg = gs_likp-lfimg.
      gs_aunr3-vrkme = gs_likp-vrkme.
      gs_aunr3-vkbur = lv_vkbur.
**      gs_likp-nourut = lv_nourut.
**      gs_likp-vkbur = lv_vkbur.
      gs_aunr3-vkbur = ls_s642-vkbur.
      COLLECT gs_aunr3 INTO gt_aunr3.
      gs_docflow-vstel = gs_likp-vstel.
      gs_docflow-nourut = lv_nourut.
      gs_docflow-vbeln  = gs_likp-vbeln.
      gs_docflow-vkbur = lv_vkbur.
      APPEND gs_docflow TO gt_docflow.
**      MODIFY gt_likp FROM gs_likp TRANSPORTING nourut vkbur.
    ENDLOOP.

    SORT gt_aunr3 BY nourut wadat_ist.
    LOOP AT gt_aunr3 INTO gs_aunr3..
      lv_nourut = gs_aunr3-nourut.
      ls_poheader-comp_code = '8380'.
      ls_poheaderx-comp_code = 'X'.
      ls_poheader-doc_type = 'ZB'.
      ls_poheaderx-doc_type = 'X'.
      ls_poheader-creat_date = sy-datum.
      ls_poheaderx-creat_date = 'X'.
      ls_poheader-created_by = sy-uname.
      ls_poheaderx-created_by = 'X'.
      ls_poheader-item_intvl = '10'.
      ls_poheaderx-item_intvl = 'X'.
      ls_poheader-vendor = lv_lifnr. "'TSB0203'.  "--> perlu ada cara mendapatkan kode vendor
      ls_poheaderx-vendor = 'X'.
      ls_poheader-suppl_plnt = gs_aunr3-vkbur. "'0203'. "--> supply plant harus di cari
      ls_poheaderx-suppl_plnt = 'X'.
      ls_poheader-langu = sy-langu.
      ls_poheaderx-langu = 'X'.
      ls_poheader-purch_org = 'TDN'.
      ls_poheaderx-purch_org = 'X'.
      ls_poheader-pur_group = 'TDN'.
      ls_poheaderx-pur_group = 'X'.
      ls_poheader-incoterms1 = 'TRD'.
      ls_poheaderx-incoterms1 = 'X'.
      ls_poheader-incoterms2  = 'Tempo Retail Development'.
      ls_poheaderx-incoterms2  = 'X'.
      ADD l_pincr TO l_ctr.
      CLEAR: lt_poitem, lt_poitemx.
      lt_poitem-po_item = l_ctr.
      lt_poitem-material = gs_aunr3-matnr.
      lt_poitem-quantity = gs_aunr3-lfimg.
      lt_poitem-po_unit = gs_aunr3-vrkme.
      lt_poitem-item_cat = '0'.
      lt_poitem-incoterms1 = 'TRD'.
      lt_poitem-incoterms2 = 'Tempo Retail Development'.
      lt_poitem-suppl_stloc = '1099'.
      lt_poitem-plant = '3800'.
      lt_poitem-stge_loc = lv_lgort. "'1099'.
      lt_poitem-plan_del = '0'. "sy-datum'.
      lt_poitem-no_rounding = 'X'.
      lt_poitem-part_deliv = 'A'.
      APPEND  lt_poitem.
      lt_poitemx-po_item = l_ctr.
      lt_poitemx-material = 'X'. "wa_detail-material.
      lt_poitemx-quantity = 'X'. "wa_detail-qty.
      lt_poitemx-po_unit = 'X'. "wa_detail-satuan.
      lt_poitemx-item_cat = 'X'. "'7'.
      lt_poitemx-incoterms1 = 'X'. "'TDN'.
      lt_poitemx-incoterms2 = 'X'. "'TDN Toko Obat'.
      lt_poitemx-suppl_stloc = 'X'. "'1000'.
      lt_poitemx-plant = 'X'. "lv_knvv-vkbur.
      lt_poitemx-stge_loc = 'X'. "'10T0'.
      lt_poitemx-preq_name = 'X'.
      lt_poitemx-plan_del = 'X'.
      lt_poitemx-no_rounding = 'X'.
      lt_poitemx-part_deliv = 'X'.
      APPEND  lt_poitemx.
      lv_aunr3 = '0000000000'.
      lv_sptag = gs_aunr3-wadat_ist.
      CLEAR: lv_ebeln, lt_poitem, lt_poitemx.

      AT END OF nourut.

        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            poheader         = ls_poheader
            poheaderx        = ls_poheaderx
          IMPORTING
            exppurchaseorder = lv_ebeln
          TABLES
            return           = lt_return
            poitem           = lt_poitem
            poitemx          = lt_poitemx.
        IF lv_ebeln IS NOT INITIAL.
          LOOP AT lt_return.
            WRITE: / lt_return-message.
          ENDLOOP.
          SKIP 1.
          WRITE: / 'No PO Inter : ', lv_ebeln, lv_vkbur.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
          CALL FUNCTION 'ZFMWAIT'.
          SELECT SINGLE * INTO ls_ekko
            FROM ekko WHERE ebeln = lv_ebeln.
          IF sy-subrc EQ 0.
            SELECT * INTO TABLE lt_t16fs
              FROM t16fs
              WHERE frggr = ls_ekko-frggr AND
                    frgsx = ls_ekko-frgsx.
            IF sy-subrc EQ 0.
              LOOP AT lt_t16fs.
                IF lt_t16fs-frgc1 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc1 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc2 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc2 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc3 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc3 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc4 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc4 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc5 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc5 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc6 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc6 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc7 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc7 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
                IF lt_t16fs-frgc8 IS NOT INITIAL.
                  PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc8 ls_ekko-frgzu ls_ekko-frgke.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
          LOOP AT lt_spoint INTO s642 WHERE aunr3 = lv_aunr3 AND sptag = lv_sptag.
            gs_s642-po_int = lv_ebeln.
            MODIFY lt_spoint FROM gs_s642 TRANSPORTING po_int doint.
          ENDLOOP.
          LOOP AT gt_s642_all INTO gs_s642 WHERE aunr3 = lv_aunr3 AND sptag = lv_sptag.
            gs_s642-po_int = lv_ebeln.
            MODIFY s642 FROM gs_s642.
            MODIFY gt_s642_all FROM gs_s642 TRANSPORTING po_int doint.
          ENDLOOP.
          CLEAR: lv_ebeln, lv_aunr3.
        ELSE.
          LOOP AT lt_return.
            WRITE: / lt_return-message.
          ENDLOOP.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
        CLEAR: ls_poheader, ls_poheaderx, lt_poitem[], lt_poitemx[], lt_return[], l_ctr, lt_poitem, lt_poitemx, lt_return .
      ENDAT.
    ENDLOOP.
    SORT gt_docflow BY nourut vbeln aunr3.
    DELETE gt_docflow[] WHERE aunr3 IS INITIAL.

  ENDIF.
ENDFORM.                    " F_PROSES_POINTER
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SOTDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_socust .
  DATA: BEGIN OF lt_do OCCURS 0,
          vbeln LIKE likp-vbeln,
        END OF lt_do.
  DATA: lv_return TYPE char1.
  "  data: lv_adnr type adnr.
  IF gt_ssocust[] IS NOT INITIAL.
    SORT gt_ssocust BY doint.
    DELETE ADJACENT DUPLICATES FROM gt_ssocust COMPARING doint.
    SELECT a~vbeln INTO CORRESPONDING FIELDS OF TABLE lt_do FROM likp AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
      FOR ALL ENTRIES IN gt_ssocust
      WHERE a~vbeln = gt_ssocust-doint
        AND wbstk = 'C'.
  ENDIF.
  IF lt_do[] IS NOT INITIAL.
    LOOP AT lt_do.
      LOOP AT gt_s642_all INTO gs_s642 WHERE doint = lt_do-vbeln.
        IF gs_s642-aunr2 IS NOT INITIAL.
        ELSE.
          IF gs_s642-sptag(6) = sy-datum(6).
            PERFORM f_proses_so USING gs_s642-vbeln gs_s642-vstel gs_s642-vkbur gs_s642-sptag CHANGING lv_return gs_s642-aunr2.
          ELSE.
            IF gv_xruem = 'X'.
              PERFORM f_proses_so USING gs_s642-vbeln gs_s642-vstel gs_s642-vkbur gs_s642-sptag CHANGING lv_return gs_s642-aunr2.
            ELSE.
              IF gv_usrtrd IS NOT INITIAL.
                sy-datum+6(2) = '01'.
                PERFORM f_proses_so USING gs_s642-vbeln gs_s642-vstel gs_s642-vkbur gs_s642-sptag CHANGING lv_return gs_s642-aunr2.
              ENDIF.
            ENDIF.
**            IF gv_usrtrd IS NOT INITIAL.
**              PERFORM f_proses_so USING gs_s642-vbeln gs_s642-vstel gs_s642-vkbur sy-datum CHANGING lv_return gs_s642-aunr2.
**            ELSE.
**              PERFORM f_proses_so USING gs_s642-vbeln gs_s642-vstel gs_s642-vkbur gs_s642-sptag CHANGING lv_return gs_s642-aunr2.
**            ENDIF.
          ENDIF.
          MODIFY gt_s642_all FROM gs_s642 TRANSPORTING aunr2.
          IF gs_s642-aunr2 IS NOT INITIAL.
            MODIFY s642 FROM gs_s642.
            COMMIT WORK AND WAIT.
            "          CALL FUNCTION 'ZFMWAIT'.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_PROSES_SOTDN
*&---------------------------------------------------------------------*
*&      Form  F_PO_RELEASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EBELN  text
*      -->P_FRGCL  text
*      -->P_FRGZU  text
*      -->P_FRGKE  text
*----------------------------------------------------------------------*
FORM f_po_release  USING    p_ebeln LIKE ekko-ebeln
                            p_frgcl LIKE t16fs-frgc1
                            p_frgzu LIKE ekko-frgzu
                            p_frgke LIKE ekko-frgke.
  CALL FUNCTION 'BAPI_PO_RELEASE'
    EXPORTING
      purchaseorder          = p_ebeln
      po_rel_code            = p_frgcl
      use_exceptions         = 'X'
      no_commit              = ' '
    IMPORTING
      rel_status_new         = p_frgzu
      rel_indicator_new      = p_frgke
    EXCEPTIONS
      authority_check_fail   = 1
      document_not_found     = 2
      enqueue_fail           = 3
      prerequisite_fail      = 4
      release_already_posted = 5
      responsibility_fail    = 6
      OTHERS                 = 7.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    CALL FUNCTION 'ZFMWAIT'.

  ENDIF.

ENDFORM.                    " F_PO_RELEASE
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DOINTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_dointer .
  DATA : lv_ebeln       TYPE ekpo-ebeln,
         ship_point     TYPE ekpv-vstel,
         delivery       TYPE bapishpdelivnumb-deliv_numb,
         num_deliveries TYPE bapidlvcreateheader-num_deliveries.
  DATA : stock_trans_items    LIKE bapidlvreftosto OCCURS 0
                            WITH HEADER LINE,
         lt_created_items     TYPE bapidlvitemcreated OCCURS 0 WITH HEADER LINE,
         lt_created_items_cal TYPE bapidlvitemcreated OCCURS 0 WITH HEADER LINE,
         deliveries           LIKE bapishpdelivnumb OCCURS 0
                            WITH HEADER LINE,
         lt_return            LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_ekpo OCCURS 0,
          ebeln    LIKE ekpo-ebeln,
          ebelp    LIKE ekpo-ebelp,
          matnr    LIKE ekpo-matnr,
          menge    LIKE ekpo-menge,
          meins    LIKE ekpo-meins,
          procstat LIKE ekko-procstat,
        END OF lt_ekpo.
  DATA: lv_err(1).
  DATA: lv_nopo(10).
  DATA: lv_return(1).
  DATA: l_ctr1 TYPE i.
  DATA: l_ctr2 TYPE i.
  SORT gt_sdoint BY po_int.
  DELETE ADJACENT DUPLICATES FROM gt_sdoint COMPARING po_int.
  IF gt_sdoint[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekpo FROM ekko AS a JOIN ekpo AS b ON a~ebeln = b~ebeln
      FOR ALL ENTRIES IN gt_sdoint
      WHERE a~ebeln = gt_sdoint-po_int
        AND procstat = '05'. " PO yg sdh complete release
  ENDIF.

  CLEAR: lt_return[],  lt_created_items[], stock_trans_items[], gt_docflow[], lv_nopo, lt_created_items_cal[], lt_created_items_cal.
  SORT lt_ekpo BY ebeln ebelp.
  CLEAR: gs_docflow.
  CLEAR: delivery.
  LOOP AT lt_ekpo.
    lv_ebeln = lt_ekpo-ebeln.
    lv_nopo = lt_ekpo-ebeln.
    stock_trans_items-ref_doc = lt_ekpo-ebeln.
    stock_trans_items-ref_item    = lt_ekpo-ebelp.
    stock_trans_items-dlv_qty = lt_ekpo-menge.
    stock_trans_items-sales_unit  = lt_ekpo-meins.
    COLLECT stock_trans_items.

    AT END OF ebeln.
      CLEAR: delivery.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_STO'
        IMPORTING
          delivery          = delivery
        TABLES
          stock_trans_items = stock_trans_items
          created_items     = lt_created_items
          return            = lt_return.
      SKIP 1.
      WRITE: / 'Error message DO Inter'.
      LOOP AT lt_return.
        WRITE: / lt_return-message.
      ENDLOOP.
      IF delivery IS NOT INITIAL.
        SKIP 1.
        WRITE: / 'Bandingkan Item dan QTY PO Inco dengan DN Inco'.
        CLEAR: lv_err, l_ctr1, l_ctr2, lt_created_items_cal, lt_created_items_cal[].
        DELETE lt_created_items[] WHERE dlv_qty IS INITIAL.
        LOOP AT lt_created_items.
          MOVE-CORRESPONDING lt_created_items TO lt_created_items_cal.
          CLEAR: lt_created_items_cal-deliv_item.
          COLLECT lt_created_items_cal.
        ENDLOOP.
        DESCRIBE TABLE lt_created_items_cal[] LINES l_ctr1.
        DESCRIBE TABLE stock_trans_items[] LINES l_ctr2.
        WRITE : / 'Item PO Inco : ', l_ctr2, sy-vline, 'Item DN Inco : ', l_ctr1.
        IF l_ctr1 <> l_ctr2.
          lv_err = 'E'.
          WRITE: / 'Ada Selisih Item PO Inco dan DN Inco'.
        ELSE.
          LOOP AT lt_created_items_cal.
            LOOP AT stock_trans_items WHERE ref_doc = lt_created_items_cal-ref_doc AND
                                            ref_item = lt_created_items_cal-ref_item.
              WRITE: / stock_trans_items-ref_item, sy-vline, lt_created_items_cal-ref_item.
              IF lt_created_items_cal-dlv_qty <> stock_trans_items-dlv_qty.
                lv_err = 'E'.
                WRITE: / 'Qty ada selisih'.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_err = 'E'.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF lv_err = 'E'.
          WRITE: / 'DN Intercompany dibatal atas no PO : ', lv_nopo,   ' Karna ada item qty tidak sama dengan PO'.
          CLEAR: delivery.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
          WRITE: / 'Tidak ada Selisih'.
          WRITE: / 'No. DN Inter : ', delivery.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
          CALL FUNCTION 'ZFMWAIT'.
          gs_docflow-po_int  = lv_ebeln.
          gs_docflow-doint = delivery.
          APPEND gs_docflow TO gt_docflow.
          CLEAR: gs_docflow.
          CLEAR: delivery.
        ENDIF.
      ELSE.
        WRITE: / 'Error Create Delivery Intercompany atas po no. ', lv_nopo.
        LOOP AT lt_return.
          WRITE: / lt_return-message.
        ENDLOOP.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
      CLEAR: stock_trans_items[], lt_created_items[], lt_return[], lt_created_items_cal[], lt_created_items_cal..
    ENDAT.
  ENDLOOP.
  BREAK tds_dev01.
  DELETE gt_docflow[] WHERE doint IS INITIAL.
  SORT gt_docflow BY po_int doint.
  DELETE ADJACENT DUPLICATES FROM gt_docflow COMPARING ALL FIELDS.
  IF gt_docflow[] IS NOT INITIAL.
    LOOP AT gt_docflow INTO gs_docflow.
      LOOP AT gt_s642_all INTO gs_s642 WHERE po_int = gs_docflow-po_int.
        gs_s642-doint = gs_docflow-doint.
        MODIFY s642 FROM gs_s642.
        COMMIT WORK AND WAIT.
        MODIFY gt_s642_all FROM gs_s642.
        WRITE: /  gs_s642-sptag, sy-vline,
                  gs_s642-vbeln, sy-vline,
                  gs_s642-aunr3, sy-vline,
                  gs_s642-po_int, sy-vline,
                  gs_s642-doint.
      ENDLOOP.
      LOOP AT gt_sdoint INTO  gs_s642 WHERE po_int = gs_docflow-po_int..
        gs_s642-doint = gs_docflow-doint.
        MODIFY gt_sdoint FROM gs_s642.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_PROSES_DOINTER
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_RELEASE_POINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_release_point .
  DATA: lt_ekko LIKE ekko OCCURS 0 WITH HEADER LINE.
  DATA: lt_t16fs LIKE t16fs  OCCURS 0 WITH HEADER LINE.

  SORT gt_spoint BY po_int.
  DELETE gt_spoint[] WHERE po_int IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM gt_spoint COMPARING po_int.
  IF gt_spoint[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekko FROM ekko
      FOR ALL ENTRIES IN gt_spoint
      WHERE ebeln = gt_spoint-po_int
        AND procstat NE '05'. " PO yg sdh complete release
  ENDIF.
  LOOP AT lt_ekko.
    CLEAR: lt_t16fs[].
    WRITE: / 'Release PO Inter : ', lt_ekko-ebeln.
    SELECT * INTO TABLE lt_t16fs
      FROM t16fs
      WHERE frggr = lt_ekko-frggr AND
            frgsx = lt_ekko-frgsx.
    IF sy-subrc EQ 0.
      LOOP AT lt_t16fs.
        IF lt_t16fs-frgc1 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc1 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc2 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc2 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc3 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc3 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc4 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc4 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc5 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc5 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc6 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc6 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc7 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc7 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
        IF lt_t16fs-frgc8 IS NOT INITIAL.
          PERFORM f_po_release USING lt_ekko-ebeln lt_t16fs-frgc8 lt_ekko-frgzu lt_ekko-frgke.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROSES_RELEASE_POINT
*&---------------------------------------------------------------------*
*&      Form  F_GOOD_ISSUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SDOINT_DOINT  text
*      -->P_GT_SDOINT_AUNR3  text
*----------------------------------------------------------------------*
FORM f_good_issue.
  DATA: lt_vbuk TYPE STANDARD TABLE OF vbuk.
  DATA: ls_vbuk TYPE vbuk.
  DATA: lv_return(1).
  DATA: lt_mblnr TYPE STANDARD TABLE OF ty_mblnr WITH HEADER LINE.
  SORT gt_sdoint BY doint.
  DELETE gt_sdoint[]  WHERE koflg IS NOT INITIAL.
  DELETE gt_sdoint[]  WHERE doint IS INITIAL.
  SORT gt_sdoint BY aunr3 doint.
  DELETE ADJACENT DUPLICATES FROM gt_sdoint COMPARING aunr3 doint.
  IF gt_sdoint[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbuk FROM vbuk
      FOR ALL ENTRIES IN gt_sdoint
      WHERE vbeln = gt_sdoint-doint.
    "        AND wbstk = 'C'.
  ENDIF.

  IF lt_vbuk[] IS NOT INITIAL.
    LOOP AT lt_vbuk INTO ls_vbuk.
      IF ls_vbuk-wbstk = 'C'.
        LOOP AT gt_s642_all INTO gs_s642 WHERE doint = ls_vbuk-vbeln.
          gs_s642-koflg = 'X'.
          MODIFY s642 FROM gs_s642.
          COMMIT WORK AND WAIT.
          MODIFY gt_s642_all FROM gs_s642 TRANSPORTING koflg.
          CLEAR: gs_s642.
        ENDLOOP.
        LOOP AT gt_sdoint INTO gs_s642 WHERE doint = ls_vbuk-vbeln.
          gs_s642-koflg = 'X'.
          MODIFY gt_sdoint FROM gs_s642 TRANSPORTING koflg.
          CLEAR: gs_s642.
        ENDLOOP.
      ELSE.
        WRITE: / 'No. DN Intercompany : ', ls_vbuk-vbeln, sy-vline.
        PERFORM f_delete_batch USING ls_vbuk-vbeln gs_s642-aunr3 CHANGING lv_return.
        IF lv_return NE 'E'.
          CLEAR: lt_mblnr[], lt_mblnr.
**            LOOP AT gt_sdoint INTO gs_s642 WHERE doint = ls_vbuk-vbeln..
**              lt_mblnr-mblnr = gs_s642-aunr3.
**              APPEND lt_mblnr.
**            ENDLOOP.
          PERFORM f_change_dn USING ls_vbuk-vbeln CHANGING lv_return.
**            IF gs_s642-vstel = gs_s642-vkbur.
**              gt_mblnr[] = lt_mblnr[].
**              PERFORM f_change_dn USING gs_s642-doint  'X' CHANGING lv_return.
**            ELSE.
**              PERFORM f_change_dn USING gs_s642-doint  ' ' CHANGING lv_return.
**            ENDIF.
          IF lv_return NE 'E'.
            CALL FUNCTION 'ZFMWAIT'.
            PERFORM f_picking_dn USING ls_vbuk-vbeln  CHANGING lv_return.
            CALL FUNCTION 'ZFMWAIT'.
            "CLEAR: rspar_tab[].
            WRITE: 'Proses Good Issue'.
            IF gs_s642-sptag(6) = sy-datum(6).
              PERFORM f_goodissue USING ls_vbuk-vbeln gs_s642-sptag.
            ELSE.
              IF gv_xruem = 'X'.
                PERFORM f_goodissue USING ls_vbuk-vbeln gs_s642-sptag.
              ELSE.
                IF gv_usrtrd IS NOT INITIAL.
                  sy-datum+6(2) = '01'.
                  PERFORM f_goodissue USING ls_vbuk-vbeln sy-datum.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CLEAR: lt_vbuk[].
  DELETE gt_sdoint[]  WHERE koflg IS NOT INITIAL.
  IF gt_sdoint[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbuk FROM vbuk
      FOR ALL ENTRIES IN gt_sdoint
      WHERE vbeln = gt_sdoint-doint
              AND wbstk = 'C'.
    IF lt_vbuk[] IS NOT INITIAL.
      LOOP AT lt_vbuk INTO ls_vbuk.
        LOOP AT gt_s642_all INTO gs_s642 WHERE doint = ls_vbuk-vbeln.
          gs_s642-koflg = 'X'.
          MODIFY s642 FROM gs_s642.
          COMMIT WORK AND WAIT.
          MODIFY gt_s642_all FROM gs_s642 TRANSPORTING koflg.
          CLEAR: gs_s642.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GOOD_ISSUE

***&---------------------------------------------------------------------*
***&      Form  F_SUBMIT_PARAMETER
***&---------------------------------------------------------------------*
**FORM f_submit_parameter  USING    fu_selname fu_value fu_kind.
**  rspar_line-selname = fu_selname.
**  rspar_line-kind    = fu_kind.
**  rspar_line-sign    = 'I'.
**  rspar_line-option  = 'EQ'.
**  rspar_line-low     = fu_value.
**  APPEND rspar_line TO rspar_tab.
**  CLEAR rspar_line.
**ENDFORM.                    " F_SUBMIT_PARAMETER


*&---------------------------------------------------------------------*
*&      Form  f_change_dn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBELN    text
*      -->P_MBLNR    text
*----------------------------------------------------------------------*
FORM f_change_dn USING p_vbeln TYPE vbeln
     "                  p_mblnr TYPE mblnr
     "                  p_sama TYPE char1
                 CHANGING p_return TYPE char1..
  DATA : header_data      LIKE bapiobdlvhdrchg,
         header_control   LIKE bapiobdlvhdrctrlchg,
         techn_control    LIKE bapidlvcontrol,
         delivery         TYPE bapishpdelivnumb-deliv_numb,
         item_data        LIKE bapiobdlvitemchg OCCURS 0
                         WITH HEADER LINE,
         item_control     LIKE bapiobdlvitemctrlchg OCCURS 0
                         WITH HEADER LINE,
         item_data_del    LIKE bapiobdlvitemchg OCCURS 0
                         WITH HEADER LINE,
         item_control_del LIKE bapiobdlvitemctrlchg OCCURS 0
                         WITH HEADER LINE,
         return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA:
    lt_lips    LIKE lips OCCURS 0 WITH HEADER LINE,
    lt_lips_do LIKE lips OCCURS 0 WITH HEADER LINE,
    lt_mseg    LIKE mseg OCCURS 0 WITH HEADER LINE,
    lt_temp    LIKE lips OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_likp1 OCCURS 0,
          vbeln LIKE likp-vbeln,
        END OF lt_likp1.
  DATA : ls_lips       LIKE LINE OF lt_lips,
         ls_mseg       LIKE LINE OF lt_mseg,
         lv_batch(1), lv_iderr(100).

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln EQ  p_vbeln
      AND b~wbstk NE 'C'.
  IF sy-subrc EQ 0.
    "    IF p_sama = 'X'.
    LOOP AT gt_s642_all INTO gs_s642 WHERE doint = p_vbeln.
      lt_likp1-vbeln = gs_s642-vbeln.
      APPEND lt_likp1.
    ENDLOOP.
    IF lt_likp1[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips_do FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
        FOR ALL ENTRIES IN lt_likp1
        WHERE a~vbeln EQ  lt_likp1-vbeln
          AND b~wbstk EQ 'C'.
      CLEAR: lt_mseg[].
      DELETE lt_lips_do[] WHERE lfimg = 0.
      SORT lt_lips_do BY matnr charg lfimg.
      LOOP AT lt_lips_do.
        ls_mseg-matnr  = lt_lips_do-matnr.
        ls_mseg-charg  = lt_lips_do-charg.
        ls_mseg-menge  = lt_lips_do-lfimg.
        COLLECT ls_mseg INTO lt_mseg.
      ENDLOOP.
    ENDIF.
**    ELSE.
****      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mseg FROM mseg
****        WHERE mblnr = p_mblnr
****          AND shkzg = 'S'.
**
**    ENDIF.
  ELSE.
    p_return = 'E'.
  ENDIF.
  lt_temp[] = lt_lips[].
  CLEAR: lv_batch, p_return.
  DELETE lt_temp[] WHERE charg IS INITIAL.
  IF lt_temp[]  IS NOT INITIAL.
    "Proses delete batch
    lv_batch = 'B'.
  ELSE.
  ENDIF.
  "  return.
  header_data-deliv_numb    = p_vbeln.
  header_control-deliv_numb = p_vbeln.
  delivery                  = p_vbeln.
  techn_control-upd_ind     = 'U'.

  IF lv_batch = 'B'.
    lt_temp[] = lt_lips[].
    DELETE lt_temp[] WHERE charg IS INITIAL.
    LOOP AT lt_temp INTO ls_lips.
      item_data_del-deliv_numb      = ls_lips-vbeln.
      item_data_del-hieraritem      = ls_lips-posnr.
      item_data_del-usehieritm      = '1'.
      item_data_del-material        = ls_lips-matnr.
      item_data_del-batch           = ls_lips-charg.
      item_data_del-dlv_qty         = ls_lips-lfimg.
      item_data_del-dlv_qty_imunit  = ls_lips-lgmng.
      item_data_del-fact_unit_nom   = '1'.
      item_data_del-fact_unit_denom = '1'.
      APPEND item_data_del.

      item_control_del-deliv_numb   = ls_lips-vbeln.
      item_control_del-deliv_item   = ls_lips-posnr.
      item_control_del-del_item     = 'X'.
      APPEND item_control_del.
    ENDLOOP.
  ENDIF.
  DELETE lt_lips[] WHERE charg IS NOT INITIAL.
  LOOP AT lt_lips INTO ls_lips.
    item_data-deliv_numb      = p_vbeln.
    item_data-deliv_item      = ls_lips-posnr.
    item_data-hieraritem      = ls_lips-posnr.
    item_data-usehieritm      = '1'.
    item_data-material        = ls_lips-matnr.
    item_data-dlv_qty         = 0.
    item_data-dlv_qty_imunit  = 0.
    item_data-fact_unit_nom   = '1'.
    item_data-fact_unit_denom = '1'.
    APPEND item_data.
    CLEAR item_data.

    item_control-deliv_numb   = p_vbeln.
    item_control-deliv_item   = ls_lips-posnr.
    item_control-chg_delqty   = 'X'.
    APPEND item_control.
    CLEAR item_control.

    CLEAR : ls_mseg.
    LOOP AT lt_mseg INTO ls_mseg WHERE matnr = ls_lips-matnr.
      IF ls_mseg-charg IS NOT INITIAL.
        item_data-deliv_numb      = p_vbeln.
        item_data-deliv_item      = ls_lips-posnr.
        item_data-hieraritem      = ls_lips-posnr.
        item_data-usehieritm      = '1'.
        item_data-material        = ls_lips-matnr.
        item_data-batch           = ls_mseg-charg.
        item_data-dlv_qty         = ls_mseg-menge."ls_lips-lfimg.
        item_data-dlv_qty_imunit  = ls_mseg-menge."ls_lips-lfimg.
        item_data-fact_unit_nom   = '1'.
        item_data-fact_unit_denom = '1'.
        APPEND item_data.
        CLEAR item_data.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  BREAK tds_dev01.
  IF item_data[] IS NOT INITIAL.
    IF lv_batch = 'B'.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
        EXPORTING
          header_data    = header_data
          header_control = header_control
          delivery       = delivery
          techn_control  = techn_control
        TABLES
          item_data      = item_data_del
          item_control   = item_control_del
          return         = return.
      " tambahkan proses commit dan lainnya
      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        LOOP AT return.
          IF return-id = 'VL' AND
            return-number = '198'.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            WRITE: / 'Error : ', return-message.
          ENDIF.
        ENDLOOP.
        p_return = 'E'.
      ELSE.
        CLEAR: lv_batch.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CALL FUNCTION 'ZFMWAIT'.
      ENDIF.
    ENDIF.
    IF lv_batch IS INITIAL.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
        EXPORTING
          header_data    = header_data
          header_control = header_control
          delivery       = delivery
          techn_control  = techn_control
        TABLES
          item_data      = item_data
          item_control   = item_control
          return         = return.

      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        WRITE: 'Gagal change dn'.
        LOOP AT return.
          IF return-id = 'VL' AND
            return-number = '198'.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            WRITE: / 'Error : ', return-message.
          ENDIF.
        ENDLOOP.
        p_return = 'E'.
      ELSE.
        WRITE: 'Sukses Change DO', sy-vline.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CALL FUNCTION 'ZFMWAIT'.
      ENDIF.
    ENDIF.
  ELSE.
    p_return = 'E'.
  ENDIF.

  CLEAR: item_data[], item_data, item_control[], item_control,
         return[], return.

ENDFORM.                    " F_CHANGE_DN
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_VBELN  text
*      -->P_GS_S642_VSTEL  text
*      -->P_GS_S642_VKBUR  text
*      <--P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM f_proses_so  USING    p_vbeln TYPE vbeln
                           p_vstel TYPE vstel
                           p_vkbur TYPE vkbur
                           p_date LIKE sy-datum
                  CHANGING p_return TYPE char1
                           p_salesdocument TYPE vbeln.

  DATA: lt_likp  LIKE likp OCCURS 0 WITH HEADER LINE,
        lt_lips  LIKE lips OCCURS 0 WITH HEADER LINE,
        lt_lips1 LIKE lips OCCURS 0 WITH HEADER LINE,
        lt_ekko  LIKE ekko OCCURS 0 WITH HEADER LINE,
        lt_ekpo  LIKE ekpo OCCURS 0 WITH HEADER LINE,
        lt_konv  LIKE konv OCCURS 0 WITH HEADER LINE.
  DATA: order_header_in     LIKE bapisdhd1,
        order_items_in      LIKE bapisditm OCCURS 0 WITH HEADER LINE,
        order_partners      LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        order_schedules_in  LIKE bapischdl OCCURS 0 WITH HEADER LINE,
        order_conditions_in LIKE bapicond OCCURS 0 WITH HEADER LINE,
        ld_return           LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        ld_salesdocument    LIKE bapivbeln-vbeln.

  DATA ls_ztdnsddt003 TYPE ztdnsddt003.
  DATA lt_ztdnsddt003 TYPE ztdnsddt003 OCCURS 0 WITH HEADER LINE.
  DATA: ls_adrc TYPE adrc.
  DATA: ld_parvw LIKE vbpa-parvw.
  DATA: ld_test_run(1).
  DATA: lv_kunnr LIKE kna1-kunnr.
  DATA: lv_kdacct LIKE ztdnsddt003-kdacct.

  CONCATENATE 'TRD' p_vkbur INTO lv_kdacct.
  ld_parvw = 'SH'.
  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      input  = ld_parvw
    IMPORTING
      output = ld_parvw.
  SELECT SINGLE *  INTO CORRESPONDING FIELDS OF ls_adrc
    FROM vbpa AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
       WHERE a~vbeln = p_vbeln AND parvw = ld_parvw.
  SELECT * INTO TABLE lt_ztdnsddt003 FROM ztdnsddt003 WHERE kdacct = lv_kdacct.
  IF sy-subrc NE 0.
    SELECT * INTO TABLE lt_ztdnsddt003 FROM ztdnsddt003 WHERE kdacct = 'TRD'.
  ENDIF.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips FROM lips WHERE vbeln = p_vbeln.
  READ TABLE lt_lips INDEX 1.
  IF lt_lips-vgbel IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekko FROM ekko WHERE ebeln = lt_lips-vgbel.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekpo FROM ekpo WHERE ebeln = lt_lips-vgbel.
    READ TABLE lt_ekko INDEX 1.
    IF lt_ekko-knumv IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_konv FROM konv WHERE knumv = lt_ekko-knumv.
    ENDIF.
    READ TABLE lt_ztdnsddt003 INDEX 1.
    LOOP AT lt_ztdnsddt003 INTO ls_ztdnsddt003.

    ENDLOOP.
    IF lt_ztdnsddt003[] IS INITIAL.
      WRITE: / ' Error : ', p_vbeln, 'Tidak dapat diproses cek table ZTDNSDDT003 ', 'Cek  KDACCT : ', lv_kdacct.
      RETURN.
    ENDIF.
    LOOP AT lt_ekko.
      lv_kunnr = ls_adrc-sort1..
      PERFORM f_change_customer USING lv_kunnr ls_ztdnsddt003-kunnr_sold CHANGING sy-subrc.
      order_header_in-sales_org     = ls_ztdnsddt003-vkorg. "'8380'. "gt_so-vkorg.
      order_header_in-sales_off     = ls_ztdnsddt003-vstel. " '3800'. "gt_so-vkbur.
      order_header_in-distr_chan    = ls_ztdnsddt003-vtweg. "'10'. "p_vtweg.
      order_header_in-division      = ls_ztdnsddt003-spart. "'00'. "p_spart.
      order_header_in-doc_type      = ls_ztdnsddt003-auart. "'ZTS5'. "p_auart.
      order_header_in-sd_doc_cat    = 'C'.
      order_header_in-purch_no_c    = lt_ekko-verkf.
      order_header_in-po_dat_s      = lt_ekko-aedat.
      order_header_in-purch_date    = p_date. "lt_ekko-aedat.
      order_header_in-price_date    = p_date. "sy-datum.  " tnggal
      order_header_in-req_date_h    = p_date.
      "order_header_in-dlvschduse   = ''.
      order_header_in-dun_date     = p_date. "sy-datum.
      order_header_in-ord_reason   = lt_ztdnsddt003-augru. "'A18'. "gt_so-augru.
      order_header_in-SALES_DIST   = p_vstel.
      CLEAR: order_partners.
      order_partners-partn_role = 'AG'.
      order_partners-partn_numb = ls_ztdnsddt003-kunnr_sold.
      APPEND order_partners.

      CLEAR: order_partners.
      order_partners-partn_role = 'WE'.
      order_partners-partn_numb = lv_kunnr. "ls_adrc-sort1. "ls_ztdnsddt003-kunnr_ship.
      order_partners-name = ls_adrc-name1.
      order_partners-name_2 = ls_adrc-name2.
      order_partners-name_3 = ls_adrc-name3.
      order_partners-name_4 = ls_adrc-name4.
      order_partners-street = ls_adrc-tel_number.
      order_partners-city   = ls_adrc-city1.
      order_partners-telephone = ls_adrc-tel_number.
      order_partners-postl_code = ls_adrc-post_code1.       "'00000'.
      IF order_partners-postl_code IS INITIAL.
        order_partners-postl_code = '00000'.
      ENDIF.
      order_partners-country = 'ID'.
      APPEND order_partners.

      LOOP AT lt_ekpo WHERE ebeln = lt_ekko-ebeln.
        order_items_in-itm_number = lt_ekpo-ebelp.
        order_items_in-material   = lt_ekpo-matnr. "'001-00-03'. "wa_detail-material. "'001-00-03'. "wa_detail-material. "'001-00-03'. "wa_order_detail-matnr.
        order_items_in-target_qty = lt_ekpo-menge. "1000. "wa_order_detail-qty.
        IF ls_ztdnsddt003-kdacct NE 'TRD'.
          order_items_in-store_loc  = ls_ztdnsddt003-lgort.
        ELSE.
          CASE gs_s642-vkbur.
            WHEN '0230'.
              order_items_in-store_loc  = ls_ztdnsddt003-lgort2. "gs_ztdnsddt003-lgort.
            WHEN '0252'.
              order_items_in-store_loc  = '1299'.
            WHEN OTHERS.
              order_items_in-store_loc  = ls_ztdnsddt003-lgort. "gs_ztdnsddt003-lgort.
          ENDCASE.
        ENDIF.
        order_items_in-plant      = ls_ztdnsddt003-vstel. "gs_ztdnsddt003-vstel.
        APPEND order_items_in.

        order_schedules_in-itm_number      = lt_ekpo-ebelp.
        order_schedules_in-req_qty         = lt_ekpo-menge.
        order_schedules_in-req_date        = p_date. "sy-datum. "wa_order-tglpesan.
        order_schedules_in-req_time        = lt_ekko-telf1.
        APPEND order_schedules_in.
        SORT lt_konv BY knumv kposn stunr.
        LOOP AT lt_konv WHERE knumv = lt_ekko-knumv AND kposn = lt_ekpo-ebelp AND kbetr NE 0..
          CLEAR: order_conditions_in.
          order_conditions_in-itm_number      = lt_konv-kposn.
          order_conditions_in-cond_type       = lt_konv-kschl. "'ZHJO'.
          order_conditions_in-cond_value      = lt_konv-kbetr * 100. "zhjr.
          order_conditions_in-currency        = 'IDR'.
          IF lt_konv-krech = 'A'.
            order_conditions_in-cond_unit        = '%'.
          ENDIF.
          APPEND order_conditions_in.
        ENDLOOP.
      ENDLOOP.
      DELETE order_conditions_in[] WHERE cond_type = 'ZSTC'.
      DELETE order_conditions_in[] WHERE cond_type = 'ZA01'.
      LOOP AT lt_konv WHERE knumv = lt_ekko-knumv AND kposn = '000000' AND kschl = 'ZSTC'.
        CLEAR: order_conditions_in.
        order_conditions_in-itm_number      = lt_konv-kposn..
        order_conditions_in-cond_type       = lt_konv-kschl. "'ZHJO'.
        order_conditions_in-cond_value      = lt_konv-kbetr * 100. "zhjr.
        order_conditions_in-currency        = 'IDR'.
        IF lt_konv-krech = 'A'.
          order_conditions_in-cond_unit        = '%'.
        ENDIF.
        APPEND order_conditions_in.
      ENDLOOP.

      CLEAR: ld_salesdocument, ld_test_run.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in     = order_header_in
          convert             = 'X'
          testrun             = ld_test_run "' ' "test_run
        IMPORTING
          salesdocument       = p_salesdocument
        TABLES
          return              = ld_return
          order_items_in      = order_items_in
          order_partners      = order_partners
          order_schedules_in  = order_schedules_in
          order_conditions_in = order_conditions_in.
      "      break tds_dev01.
      IF p_salesdocument IS NOT INITIAL.
        WRITE: / 'SO TDN terbentuk : ', p_salesdocument.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        WRITE: / 'Error Create SO TDN : '.
        LOOP AT ld_return.
          WRITE: / ld_return-message.
        ENDLOOP.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROSES_SO
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_AUNR2  text
*      <--P_GS_S642_DOCUST  text
*----------------------------------------------------------------------*
FORM f_proses_dn  USING    p_salesorder TYPE vbeln
                  CHANGING p_delivery TYPE vbeln_vl.

**  DATA: ld_vsbed      TYPE vbak-vsbed,
**        ld_edatu      TYPE vbep-edatu,
**        ld_delivery   TYPE bapishpdelivnumb-deliv_numb,
  DATA: ld_num_deliveries    TYPE bapidlvcreateheader-num_deliveries,
        ld_ship_point        TYPE bapidlvcreateheader-ship_point,
        ld_due_date          TYPE bapidlvcreateheader-due_date,
        ld_delivery          TYPE bapishpdelivnumb-deliv_numb,
        lt_sales_order_items LIKE bapidlvreftosalesorder OCCURS 0 WITH HEADER LINE,
        lt_deliveries        LIKE bapishpdelivnumb OCCURS 0 WITH HEADER LINE,
        lt_created_items     LIKE bapidlvitemcreated OCCURS 0 WITH HEADER LINE,
        lt_return            LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        lt_vbap              TYPE TABLE OF vbap WITH HEADER LINE.

  SELECT vbeln posnr kwmeng vrkme
    INTO CORRESPONDING FIELDS OF TABLE lt_vbap
    FROM vbap WHERE vbeln = p_salesorder.

  LOOP AT lt_vbap.
    lt_sales_order_items-ref_doc      = lt_vbap-vbeln.
    lt_sales_order_items-ref_item     = lt_vbap-posnr.
    lt_sales_order_items-dlv_qty      = lt_vbap-kwmeng.
    lt_sales_order_items-sales_unit   = lt_vbap-vrkme.
    APPEND lt_sales_order_items.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_SLS'
    EXPORTING
      ship_point        = ld_ship_point
      due_date          = ld_due_date
    IMPORTING
      delivery          = p_delivery "ld_delivery
      num_deliveries    = ld_num_deliveries
    TABLES
      sales_order_items = lt_sales_order_items
      deliveries        = lt_deliveries
      created_items     = lt_created_items
      return            = lt_return.
  IF p_delivery IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    WRITE: / 'No. DN (TDN) terbentuk  : ', p_delivery.
  ELSE.
    WRITE: / 'Error Create DN (TDN)'.
    LOOP AT lt_return.
      WRITE: / lt_return-message.
    ENDLOOP.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.                    " F_PROSES_DN
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DOCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_docust .
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_do OCCURS 0,
          vbeln LIKE likp-vbeln,
        END OF lt_do.
  DATA: lv_return TYPE char1.
  "  data: lv_adnr type adnr.
  IF gt_sdocust[] IS NOT INITIAL.
    SORT gt_sdocust BY aunr2.
    DELETE ADJACENT DUPLICATES FROM gt_sdocust COMPARING aunr2.
  ENDIF.
  LOOP AT gt_sdocust INTO gs_s642.
    CLEAR: let_docflow[], let_docflow.
    CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
      EXPORTING
        iv_docnum  = gs_s642-aunr2
      IMPORTING
        et_docflow = let_docflow.
    LOOP AT let_docflow INTO lw_docflow.
      CASE lw_docflow-vbtyp_n.
        WHEN 'J'.
          gs_s642-docust = lw_docflow-vbeln.
      ENDCASE.
    ENDLOOP.
    IF gs_s642-docust IS INITIAL.
      PERFORM f_proses_dn USING gs_s642-aunr2 CHANGING gs_s642-docust.
    ENDIF.
    IF gs_s642-docust IS NOT INITIAL.
      MODIFY gt_sdocust FROM gs_s642 TRANSPORTING docust.
      MODIFY s642 FROM gs_s642.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.
  COMMIT WORK AND WAIT.

ENDFORM.                    " F_PROSES_DOCUST
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_DOINT  text
*      -->P_GS_S642_AUNR3  text
*      <--P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM f_delete_batch  USING p_vbeln TYPE vbeln
                       p_mblnr TYPE mblnr
                 CHANGING p_return TYPE char1.

  DATA : header_data      LIKE bapiobdlvhdrchg,
         header_control   LIKE bapiobdlvhdrctrlchg,
         techn_control    LIKE bapidlvcontrol,
         delivery         TYPE bapishpdelivnumb-deliv_numb,
         item_data_del    LIKE bapiobdlvitemchg OCCURS 0
                         WITH HEADER LINE,
         item_control_del LIKE bapiobdlvitemctrlchg OCCURS 0
                         WITH HEADER LINE,
         return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA:
    lt_lips LIKE lips OCCURS 0 WITH HEADER LINE,
    "lt_mseg LIKE mseg OCCURS 0 WITH HEADER LINE,
    lt_temp LIKE lips OCCURS 0 WITH HEADER LINE.
  DATA : ls_lips       LIKE LINE OF lt_lips,
         lv_batch(1), lv_iderr(100).

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln EQ  p_vbeln
      AND b~wbstk NE 'C'.
  IF sy-subrc EQ 0.
  ELSE.
    p_return = 'E'.
  ENDIF.
  lt_temp[] = lt_lips[].
  CLEAR: lv_batch, p_return.
  DELETE lt_temp[] WHERE charg IS INITIAL.
  IF lt_temp[]  IS NOT INITIAL.
    lv_batch = 'B'.
  ELSE.
  ENDIF.
  "  return.
  header_data-deliv_numb    = p_vbeln.
  header_control-deliv_numb = p_vbeln.
  delivery                  = p_vbeln.

  techn_control-upd_ind     = 'U'.

  IF lv_batch = 'B'.
    lt_temp[] = lt_lips[].
    DELETE lt_temp[] WHERE charg IS INITIAL.
    LOOP AT lt_temp INTO ls_lips.
      item_data_del-deliv_numb      = ls_lips-vbeln.
      item_data_del-hieraritem      = ls_lips-posnr.
      item_data_del-usehieritm      = '1'.
      item_data_del-material        = ls_lips-matnr.
      item_data_del-batch           = ls_lips-charg.
      item_data_del-dlv_qty         = ls_lips-lfimg.
      item_data_del-dlv_qty_imunit  = ls_lips-lgmng.
      item_data_del-fact_unit_nom   = '1'.
      item_data_del-fact_unit_denom = '1'.
      APPEND item_data_del.

      item_control_del-deliv_numb   = ls_lips-vbeln.
      item_control_del-deliv_item   = ls_lips-posnr.
      item_control_del-del_item     = 'X'.
      APPEND item_control_del.
    ENDLOOP.
  ELSE.
  ENDIF.
  IF item_data_del[] IS NOT INITIAL.
    IF lv_batch = 'B'.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
        EXPORTING
          header_data    = header_data
          header_control = header_control
          delivery       = delivery
          techn_control  = techn_control
        TABLES
          item_data      = item_data_del
          item_control   = item_control_del
          return         = return.
      " tambahkan proses commit dan lainnya
      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        LOOP AT return.
          IF return-id = 'VL' AND
            return-number = '198'.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            WRITE: / 'Error : ', return-message.
          ENDIF.
        ENDLOOP.
        p_return = 'E'.
      ELSE.
        CLEAR: lv_batch.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CALL FUNCTION 'ZFMWAIT'.
      ENDIF.
    ENDIF.
  ELSE.
  ENDIF.
  CLEAR: item_data_del[], item_data_del, item_control_del[], item_control_del,
         return[], return.

ENDFORM.                    " F_DELETE_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_PICKING_DN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_DOINT  text
*      -->P_GS_S642_AUNR3  text
*      <--P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM f_picking_dn  USING p_vbeln TYPE vbeln
                 CHANGING p_return TYPE char1..
  DATA : header_data    LIKE bapiobdlvhdrchg,
         header_control LIKE bapiobdlvhdrctrlchg,
         techn_control  LIKE bapidlvcontrol,
         delivery       TYPE bapishpdelivnumb-deliv_numb,
         return         LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA:
        lt_lips LIKE lips OCCURS 0 WITH HEADER LINE.
  "        lt_temp LIKE lips OCCURS 0 WITH HEADER LINE.
  DATA : ls_lips         LIKE LINE OF lt_lips.
  DATA : ls_vbkok LIKE vbkok,
         lt_vbpok TYPE STANDARD TABLE OF vbpok,
         ls_vbpok TYPE vbpok,
         prot     TYPE STANDARD TABLE OF prott,
         ls_prot  LIKE LINE OF prot.


  CLEAR: lt_lips[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln EQ  p_vbeln
      AND b~wbstk NE 'C'.

  ls_vbkok-vbeln_vl = p_vbeln.
  ls_vbkok-vbeln    = p_vbeln.
  BREAK tds_dev01.
  LOOP AT lt_lips INTO ls_lips.
    ls_vbpok-vbeln_vl = ls_lips-vbeln.
    ls_vbpok-posnr_vl = ls_lips-posnr.
    ls_vbpok-vbeln    = ls_lips-vbeln.
    ls_vbpok-posnn    = ls_lips-posnr.
    ls_vbpok-pikmg    = ls_lips-lfimg.
    APPEND ls_vbpok TO lt_vbpok.
  ENDLOOP.

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      vbkok_wa       = ls_vbkok
      synchron       = 'X'
      commit         = 'X'
      delivery       = delivery
      update_picking = 'X'
    TABLES
      vbpok_tab      = lt_vbpok
      prot           = prot.

  READ TABLE prot INTO ls_prot WITH KEY msgty = 'E'.
  IF sy-subrc = 0.
    LOOP AT prot INTO ls_prot.
      MOVE-CORRESPONDING ls_prot TO return.
      "PERFORM f_display_message USING return 'E'.
      EXIT.
    ENDLOOP.
    p_return = 'E'.
  ELSE.
    WRITE: 'Sukses Pick', sy-vline.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CALL FUNCTION 'ZFMWAIT'.
  ENDIF.
ENDFORM.                    " F_PICKING_DN
*&---------------------------------------------------------------------*
*&      Form  F_GOOD_ISSUE_DOCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_good_issue_docust.
  DATA: lt_vbuk TYPE STANDARD TABLE OF vbuk.
  DATA: ls_vbuk TYPE vbuk.
  DATA: lv_return(1).
  SORT gt_sdocust BY docust.
  DELETE gt_sdocust[] WHERE docust IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM gt_sdocust COMPARING docust.
  " DELETE gt_sdocust[] WHERE umvkz IS NOT INITIAL.
  LOOP AT gt_sdocust INTO gs_s642..
    WRITE: / 'Proses DN : ', gs_s642-docust, sy-vline.
    PERFORM f_change_docust USING gs_s642-vbeln gs_s642-docust CHANGING lv_return.
    IF lv_return NE 'E'.
      "      CALL FUNCTION 'ZFMWAIT'.
      PERFORM f_picking_dn USING gs_s642-docust  CHANGING lv_return.
      "CLEAR: rspar_tab[].
      WRITE: 'Proses Good Issue'.
      IF gs_s642-sptag(6) = sy-datum(6).
        PERFORM f_goodissue USING gs_s642-docust gs_s642-sptag.
      ELSE.
        IF gv_xruem = 'X'.
          PERFORM f_goodissue USING gs_s642-docust gs_s642-sptag.
        ELSE.
          IF gv_usrtrd IS NOT INITIAL.
            sy-datum+6(2) = '01'.
            PERFORM f_goodissue USING gs_s642-docust sy-datum.
          ENDIF.
        ENDIF.
      ENDIF.
      "      PERFORM f_submit_parameter USING : 'PA_VBELN' gs_s642-docust 'P'.
      "      SUBMIT ztwspgi WITH SELECTION-TABLE rspar_tab AND RETURN.
    ENDIF.
  ENDLOOP.
  CLEAR: lt_vbuk[].
  "    DELETE gt_sdocust[]  WHERE umvkz IS NOT INITIAL.
  IF gt_sdocust[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbuk FROM vbuk
      FOR ALL ENTRIES IN gt_sdocust
      WHERE vbeln = gt_sdocust-docust
              AND wbstk = 'C'.
    IF lt_vbuk[] IS NOT INITIAL.
      LOOP AT lt_vbuk INTO ls_vbuk.
        LOOP AT gt_sdocust INTO gs_s642 WHERE docust = ls_vbuk-vbeln.
          gs_s642-umvkz = 'X'.
          MODIFY s642 FROM gs_s642.
          COMMIT WORK AND WAIT.
          CLEAR: gs_s642.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GOOD_ISSUE_DOCUST
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DOCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_VBELN  text
*      -->P_GS_S642_DOCUST  text
*      <--P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM f_change_docust  USING    p_vbeln TYPE vbeln
                               p_docust TYPE vbeln
                      CHANGING p_return TYPE char1.
  DATA : header_data      LIKE bapiobdlvhdrchg,
         header_control   LIKE bapiobdlvhdrctrlchg,
         techn_control    LIKE bapidlvcontrol,
         delivery         TYPE bapishpdelivnumb-deliv_numb,
         item_data        LIKE bapiobdlvitemchg OCCURS 0
                         WITH HEADER LINE,
         item_control     LIKE bapiobdlvitemctrlchg OCCURS 0
                         WITH HEADER LINE,
         item_data_del    LIKE bapiobdlvitemchg OCCURS 0
                         WITH HEADER LINE,
         item_control_del LIKE bapiobdlvitemctrlchg OCCURS 0
                         WITH HEADER LINE,
         return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA:
    lt_lips  LIKE lips OCCURS 0 WITH HEADER LINE,
    lt_lips1 LIKE lips OCCURS 0 WITH HEADER LINE,
    lt_temp  LIKE lips OCCURS 0 WITH HEADER LINE.
  DATA : ls_lips       LIKE LINE OF lt_lips,
         ls_lips1      LIKE LINE OF lt_lips1,
         lv_batch(1), lv_iderr(100).

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln EQ  p_docust
      AND b~wbstk NE 'C'.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips1 FROM lips AS a JOIN vbuk AS b ON a~vbeln = b~vbeln
    WHERE a~vbeln EQ  p_vbeln
      AND b~wbstk EQ 'C'.

  lt_temp[] = lt_lips[].
  CLEAR: lv_batch, p_return.
  DELETE lt_temp[] WHERE charg IS INITIAL.
  IF lt_temp[]  IS NOT INITIAL.
    "Proses delete batch
    lv_batch = 'B'.
  ELSE.
  ENDIF.
  "  return.
  header_data-deliv_numb    = p_docust.
  header_control-deliv_numb = p_docust.
  delivery                  = p_docust.

  techn_control-upd_ind     = 'U'.

  IF lv_batch = 'B'.
    lt_temp[] = lt_lips[].
    DELETE lt_temp[] WHERE charg IS INITIAL.
    LOOP AT lt_temp INTO ls_lips.
      item_data_del-deliv_numb      = ls_lips-vbeln.
      item_data_del-hieraritem      = ls_lips-posnr.
      item_data_del-usehieritm      = '1'.
      item_data_del-material        = ls_lips-matnr.
      item_data_del-batch           = ls_lips-charg.
      item_data_del-dlv_qty         = ls_lips-lfimg.
      item_data_del-dlv_qty_imunit  = ls_lips-lgmng.
      item_data_del-fact_unit_nom   = '1'.
      item_data_del-fact_unit_denom = '1'.
      APPEND item_data_del.

      item_control_del-deliv_numb   = ls_lips-vbeln.
      item_control_del-deliv_item   = ls_lips-posnr.
      item_control_del-del_item     = 'X'.
      APPEND item_control_del.
    ENDLOOP.
  ENDIF.
  DELETE lt_lips[] WHERE charg IS NOT INITIAL.
  DELETE lt_lips1[] WHERE charg IS INITIAL.
  DELETE lt_lips1[] WHERE lfimg EQ 0.
  LOOP AT lt_lips INTO ls_lips.
    item_data-deliv_numb      = ls_lips-vbeln.
    item_data-deliv_item      = ls_lips-posnr.
    item_data-hieraritem      = ls_lips-posnr.
    item_data-usehieritm      = '1'.
    item_data-material        = ls_lips-matnr.
    item_data-dlv_qty         = 0.
    item_data-dlv_qty_imunit  = 0.
    item_data-fact_unit_nom   = '1'.
    item_data-fact_unit_denom = '1'.
    APPEND item_data.
    CLEAR item_data.

    item_control-deliv_numb   = ls_lips-vbeln.
    item_control-deliv_item   = ls_lips-posnr.
    item_control-chg_delqty   = 'X'.
    APPEND item_control.
    CLEAR item_control.

    CLEAR : ls_lips1.
    LOOP AT lt_lips1 INTO ls_lips1 WHERE matnr = ls_lips-matnr.
      IF ls_lips1-charg IS NOT INITIAL.
        item_data-deliv_numb      = ls_lips-vbeln.
        item_data-deliv_item      = ls_lips-posnr.
        item_data-hieraritem      = ls_lips-posnr.
        item_data-usehieritm      = '1'.
        item_data-material        = ls_lips-matnr.
        item_data-batch           = ls_lips1-charg.
        item_data-dlv_qty         = ls_lips1-lfimg.
        item_data-dlv_qty_imunit  = ls_lips1-lfimg.
        item_data-fact_unit_nom   = '1'.
        item_data-fact_unit_denom = '1'.
        APPEND item_data.
        CLEAR item_data.
      ENDIF.
      CLEAR: ls_lips1.
    ENDLOOP.
  ENDLOOP.
  BREAK tds_dev01.
  IF item_data[] IS NOT INITIAL.
    IF lv_batch = 'B'.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
        EXPORTING
          header_data    = header_data
          header_control = header_control
          delivery       = delivery
          techn_control  = techn_control
        TABLES
          item_data      = item_data_del
          item_control   = item_control_del
          return         = return.
      " tambahkan proses commit dan lainnya
      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        LOOP AT return.
          IF return-id = 'VL' AND
            return-number = '198'.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            WRITE: / 'Error : ', return-message.
          ENDIF.
        ENDLOOP.
        p_return = 'E'.
      ELSE.
        CLEAR: lv_batch.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CALL FUNCTION 'ZFMWAIT'.
      ENDIF.
    ENDIF.
    IF lv_batch IS INITIAL.
      CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
        EXPORTING
          header_data    = header_data
          header_control = header_control
          delivery       = delivery
          techn_control  = techn_control
        TABLES
          item_data      = item_data
          item_control   = item_control
          return         = return.

      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        WRITE: 'Gagal change dn'.
        LOOP AT return.
          IF return-id = 'VL' AND
            return-number = '198'.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            WRITE: / 'Error : ', return-message.
          ENDIF.
        ENDLOOP.
        p_return = 'E'.
      ELSE.
        WRITE: 'Sukses Change DO', sy-vline.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CALL FUNCTION 'ZFMWAIT'.
      ENDIF.
    ENDIF.
  ELSE.
    p_return = 'E'.
  ENDIF.

  CLEAR: item_data[], item_data, item_control[], item_control,
         return[], return.


ENDFORM.                    " F_CHANGE_DOCUST
*&---------------------------------------------------------------------*
*&      Form  F_GOODISSUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_S642_DOCUST  text
*----------------------------------------------------------------------*
FORM f_goodissue  USING    pa_vbeln TYPE vbeln
                           pa_date LIKE sy-datum.

**TYPES : BEGIN OF ty_post,
**          materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
**          matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
**        END OF ty_post.

  DATA : header_data      TYPE bapiobdlvhdrcon,
         header_control   TYPE bapiobdlvhdrctrlcon,
         header_deadlines TYPE STANDARD TABLE OF bapidlvdeadln,
         return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
         ls_deadlines     TYPE bapidlvdeadln.

  DATA : "gt_return        TYPE STANDARD TABLE OF bapiret2,
    lv_memory(100),
    lv_subrc       TYPE sy-subrc,
    lv_timestamp   TYPE tzntstmps,
    lv_time        TYPE systtimlo.

  DATA : lv_mblnr TYPE mseg-mblnr,
         lv_mjahr TYPE mseg-mjahr.

  header_data-deliv_numb       = pa_vbeln.
  header_control-deliv_numb    = pa_vbeln.
  header_control-post_gi_flg   = 'X'.
  header_control-gdsi_date_flg = 'X'.

  CLEAR : lv_timestamp, lv_time.
  lv_time = '120000'.
  PERFORM f_timestamp USING pa_date lv_time
                      CHANGING lv_timestamp.

* Populate Actual Goods Issue Date
  CLEAR : header_deadlines[], ls_deadlines.
  ls_deadlines-deliv_numb    = pa_vbeln.
  ls_deadlines-timetype      = 'WSHDRWADTI'.
  ls_deadlines-timestamp_utc = lv_timestamp.
  APPEND ls_deadlines TO header_deadlines.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CONFIRM_DEC'
    EXPORTING
      header_data      = header_data
      header_control   = header_control
      delivery         = pa_vbeln
    TABLES
      header_deadlines = header_deadlines
      return           = return.
  WRITE: / 'Message GI  :'.
  DATA:        lv_line(120)      TYPE c.

  LOOP AT return.
    IF return-type = 'E'.
      lv_subrc  = 4.
    ENDIF.
    "    WRITE: / return-message.
    MESSAGE ID return-id TYPE return-type
                           NUMBER return-number
                             WITH return-message_v1
                                  return-message_v2
                                  return-message_v3
                                  return-message_v4
                             INTO lv_line.
    WRITE: / lv_line.
    CLEAR return.
  ENDLOOP.

  IF lv_subrc IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CALL FUNCTION 'ZFMWAIT'.
    TRY .
        UPDATE likp SET vlstk = space
                    WHERE vbeln = pa_vbeln.
      CATCH cx_root.
    ENDTRY.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.                    " F_GOODISSUE


*&---------------------------------------------------------------------*
*&      Form  F_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_timestamp  USING    fu_datum fu_time
                  CHANGING fc_timestamp.
  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      i_datlo     = fu_datum
      i_timlo     = fu_time
    IMPORTING
      e_timestamp = fc_timestamp.
ENDFORM.                    " F_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_material_document  USING    fu_vbeln
                              CHANGING fc_mblnr fc_mjahr.
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
    EXPORTING
      iv_docnum  = fu_vbeln
    IMPORTING
      et_docflow = let_docflow.
  LOOP AT let_docflow INTO lw_docflow.
    IF lw_docflow-vbtyp_n = 'R'.
      IF lw_docflow-vbeln(1) = '4'.
        fc_mblnr = lw_docflow-vbeln.
        fc_mjahr = lw_docflow-erdat(4).
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_MATERIAL_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POINTER_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_pointer_all .
  DATA: lt_poitem      LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poitemx     LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
        lt_poschedule  LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
        lt_poschedulex LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE,
        lt_return      LIKE  bapiret2 OCCURS 0 WITH HEADER LINE.
  DATA: lv_ebeln     LIKE ekpo-ebeln,
        ls_poheader  TYPE bapimepoheader,
        ls_poheaderx TYPE bapimepoheaderx.
  DATA: lt_t16fs LIKE t16fs  OCCURS 0 WITH HEADER LINE,
        ls_ekko  LIKE ekko,
        ld_frggr LIKE ekko-frggr,
        ld_frgsx LIKE ekko-frgsx.
  DATA: l_pincr LIKE t161-pincr.
  DATA: l_ctr TYPE i.
  "  DATA: lv_aunr3 LIKE s642-aunr3.
  "  DATA: lv_sptag LIKE s642-sptag.
  DATA: lv_vkbur TYPE vkbur.
  "  DATA: lv_lifnr TYPE lifnr.
  DATA: ld_procstat LIKE ekko-procstat. "--> status release PO jika = '05'
  DATA: lv_lgort TYPE lgort.
  DATA: lv_field_value4 TYPE zscust_control-field_value4,
        lv_field_value  TYPE zscust_control-field_value.
  "  DATA: lt_vkbur TYPE STANDARD TABLE OF s642.
  "  DATA: ls_s642 TYPE s642.
  "  DATA: lt_spoint TYPE STANDARD TABLE OF s642.  "khusus untuk supply dari cabang yg sama
  DATA: lv_nourut TYPE num10.

  DATA: lt_likp TYPE ty_likp OCCURS 0 WITH HEADER LINE.
  DATA: ls_likp TYPE ty_likp.
  DATA: BEGIN OF lt_vkbur OCCURS 0,
          bwkey LIKE t001w-bwkey,
          kunnr LIKE knvp-kunnr,
          lifnr LIKE knvp-lifnr,
        END OF lt_vkbur.
  DATA: BEGIN OF lt_docflow OCCURS 0,
          nourut TYPE num10,
          vbeln  LIKE s642-vbeln,
          sptag  LIKE s642-sptag,
          ebeln  LIKE ekko-ebeln,
        END OF lt_docflow.

  SORT gt_spoint BY sptag.

  CLEAR: gt_docflow[], l_pincr.
  WRITE: / 'Prepare data for PO Inter dan DO Inter'.
  SELECT SINGLE pincr INTO l_pincr FROM t161 WHERE bstyp = 'F' AND bsart = 'ZUBT'.

  SORT gt_spoint BY vstel sptag vkbur.

  IF gt_spoint[] IS NOT INITIAL.
    CLEAR: gt_docflow[], l_pincr.
    WRITE: / 'Prepare data for PO Inter dan DO Inter'.
    SELECT SINGLE pincr INTO l_pincr FROM t161 WHERE bstyp = 'F' AND bsart = 'ZUBT'.
    SORT gt_spoint BY vstel sptag vkbur aunr3.
    CLEAR: gt_likp[].
    IF gt_spoint[] IS NOT INITIAL.

      SELECT bwkey kunnr lifnr INTO TABLE lt_vkbur
        FROM t001w
        WHERE werks = p_vstel.
      SORT lt_vkbur BY bwkey.
      DELETE ADJACENT DUPLICATES FROM lt_vkbur COMPARING ALL FIELDS.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
        JOIN vbuk AS c ON a~vbeln = c~vbeln
        FOR ALL ENTRIES IN gt_spoint
        WHERE a~vbeln = gt_spoint-vbeln
          AND wbstk = 'C'.
      lt_likp[] = gt_likp[].
      SORT lt_likp BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
**      IF lt_likp[] IS NOT INITIAL.
**        SELECT a~bwkey b~kunnr b~lifnr INTO TABLE lt_vkbur
**          FROM t001w AS a JOIN knvp AS b ON a~lifnr = b~lifnr
**          FOR ALL ENTRIES IN lt_likp
**          WHERE b~kunnr = lt_likp-kunnr AND
**                parvw = 'LF'.
**      ENDIF.
      LOOP AT lt_vkbur.
        CLEAR: lv_lgort, lv_vkbur, lv_field_value.
        lv_vkbur = lt_vkbur-bwkey.
        lv_field_value = lv_vkbur.
        CONDENSE lv_field_value.
        SELECT SINGLE field_value4 INTO lv_field_value4 FROM zscust_control
          WHERE vkorg = '8380'
            AND cek = 'ERT'
            AND field_value = lv_field_value.
        lv_lgort = lv_field_value4(4).
        LOOP AT gt_likp INTO ls_likp. " WHERE kunnr = lt_vkbur-kunnr.
          ls_likp-vkbur = lv_vkbur. "p_vstel.
          ls_likp-stge_loc = lv_lgort.
          MODIFY gt_likp FROM ls_likp TRANSPORTING vkbur stge_loc.
        ENDLOOP.
      ENDLOOP.
      SORT lt_vkbur BY bwkey.
      DELETE ADJACENT DUPLICATES FROM lt_vkbur COMPARING bwkey.
      CLEAR: lv_nourut, gs_docflow, gt_docflow[].
      lv_nourut = '1000000000'.
      DELETE gt_likp[] WHERE lfimg = 0.
      SORT gt_likp BY vkbur wadat_ist matnr charg.
      LOOP AT lt_vkbur.
        LOOP AT gt_likp INTO gs_likp WHERE vkbur = lt_vkbur-bwkey.
          AT NEW wadat_ist.
            ADD 10 TO lv_nourut.
          ENDAT.
          gs_po_all-nourut = lv_nourut.
          gs_po_all-wadat_ist = gs_likp-wadat_ist.
          gs_po_all-matnr = gs_likp-matnr.
          "        gs_po_all-charg = gs_likp-charg.
          gs_po_all-lgort = gs_likp-stge_loc. "lgort.
          gs_po_all-lfimg = gs_likp-lfimg.
          gs_po_all-vrkme = gs_likp-vrkme.
          gs_po_all-vkbur = gs_likp-vkbur.
          gs_po_all-lifnr = lt_vkbur-lifnr.
          COLLECT gs_po_all INTO gt_po_all.
          lt_docflow-nourut = lv_nourut.
          lt_docflow-vbeln = gs_likp-vbeln.
          lt_docflow-sptag = gs_likp-wadat_ist.
          APPEND lt_docflow.
        ENDLOOP.
      ENDLOOP.
      SORT lt_docflow BY nourut vbeln sptag.
      DELETE ADJACENT DUPLICATES FROM lt_docflow COMPARING ALL FIELDS.
      SORT gt_po_all BY nourut wadat_ist.
      LOOP AT gt_po_all INTO gs_po_all..
        lv_nourut = gs_po_all-nourut.
        ls_poheader-comp_code = '8380'.
        ls_poheaderx-comp_code = 'X'.
        ls_poheader-doc_type = 'ZB'.
        ls_poheaderx-doc_type = 'X'.
        ls_poheader-created_by = sy-uname.
        ls_poheaderx-created_by = 'X'.
        ls_poheader-item_intvl = '10'.
        ls_poheaderx-item_intvl = 'X'.
        ls_poheader-vendor = gs_po_all-lifnr. "'TSB0203'.  "--> perlu ada cara mendapatkan kode vendor
        ls_poheaderx-vendor = 'X'.
        ls_poheader-suppl_plnt = gs_po_all-vkbur. "'0203'. "--> supply plant harus di cari
        ls_poheaderx-suppl_plnt = 'X'.
        ls_poheader-langu = sy-langu.
        ls_poheaderx-langu = 'X'.
        ls_poheader-purch_org = 'TDN'.
        ls_poheaderx-purch_org = 'X'.
        ls_poheader-pur_group = 'TDN'.
        ls_poheaderx-pur_group = 'X'.
        ls_poheader-incoterms1 = 'TRD'.
        ls_poheaderx-incoterms1 = 'X'.
        ls_poheader-incoterms2  = 'Tempo Retail Development'.
        ls_poheaderx-incoterms2  = 'X'.
        ls_poheader-doc_date  = gs_po_all-wadat_ist.
        ls_poheaderx-doc_date = 'X'.
***        IF gs_po_all-wadat_ist(6) = sy-datum(6).
***          ls_poheader-doc_date  = gs_po_all-wadat_ist.
***        ELSE.
***          IF gv_usrtrd IS NOT INITIAL.
***            ls_poheader-doc_date  = sy-datum.
***            ls_poheader-doc_date+6(2) = '01'.
***            ls_poheader-doc_date = ls_poheader-doc_date - 1.
***          ELSE.
***            ls_poheader-doc_date  = gs_po_all-wadat_ist.
***          ENDIF.
***        ENDIF.
        ls_poheader-creat_date = ls_poheader-doc_date. "sy-datum.
        ls_poheaderx-creat_date = 'X'.
        ADD l_pincr TO l_ctr.
        CLEAR: lt_poitem, lt_poitemx.
        lt_poitem-po_item = l_ctr.
        lt_poitem-material = gs_po_all-matnr.
        lt_poitem-quantity = gs_po_all-lfimg.
        lt_poitem-po_unit = gs_po_all-vrkme.
        lt_poitem-item_cat = '0'.
        lt_poitem-incoterms1 = 'TRD'.
        lt_poitem-incoterms2 = 'Tempo Retail Development'.
        lt_poitem-suppl_stloc = '1099'.
        lt_poitem-plant = '3800'.
        lt_poitem-stge_loc = gs_po_all-lgort. "lv_lgort. "'1099'.
        lt_poitem-plan_del = '0'. "sy-datum'.
        lt_poitem-no_rounding = 'X'.
        lt_poitem-part_deliv = 'A'.
        lt_poitem-pricedate = '1'.
        APPEND  lt_poitem.
        lt_poitemx-po_item = l_ctr.
        lt_poitemx-material = 'X'. "wa_detail-material.
        lt_poitemx-quantity = 'X'. "wa_detail-qty.
        lt_poitemx-po_unit = 'X'. "wa_detail-satuan.
        lt_poitemx-item_cat = 'X'. "'7'.
        lt_poitemx-incoterms1 = 'X'. "'TDN'.
        lt_poitemx-incoterms2 = 'X'. "'TDN Toko Obat'.
        lt_poitemx-suppl_stloc = 'X'. "'1000'.
        lt_poitemx-plant = 'X'. "lv_knvv-vkbur.
        lt_poitemx-stge_loc = 'X'. "'10T0'.
        lt_poitemx-preq_name = 'X'.
        lt_poitemx-plan_del = 'X'.
        lt_poitemx-no_rounding = 'X'.
        lt_poitemx-part_deliv = 'X'.
        lt_poitemx-pricedate = 'X'.
        APPEND  lt_poitemx.
        "      lv_aunr3 = '0000000000'.
        "lv_sptag = gs_po_all-wadat_ist.
        CLEAR: lv_ebeln, lt_poitem, lt_poitemx.
        AT END OF nourut.
          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = ls_poheader
              poheaderx        = ls_poheaderx
            IMPORTING
              exppurchaseorder = lv_ebeln
            TABLES
              return           = lt_return
              poitem           = lt_poitem
              poitemx          = lt_poitemx.
          IF lv_ebeln IS NOT INITIAL.
            LOOP AT lt_return.
              WRITE: / lt_return-message.
            ENDLOOP.
            SKIP 1.
            WRITE: / 'No PO Inter : ', lv_ebeln, lv_vkbur.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
            CALL FUNCTION 'ZFMWAIT'.
            SELECT SINGLE * INTO ls_ekko
              FROM ekko WHERE ebeln = lv_ebeln.
            IF sy-subrc EQ 0.
              SELECT * INTO TABLE lt_t16fs
                FROM t16fs
                WHERE frggr = ls_ekko-frggr AND
                      frgsx = ls_ekko-frgsx.
              IF sy-subrc EQ 0.
                LOOP AT lt_t16fs.
                  IF lt_t16fs-frgc1 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc1 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc2 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc2 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc3 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc3 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc4 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc4 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc5 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc5 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc6 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc6 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc7 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc7 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                  IF lt_t16fs-frgc8 IS NOT INITIAL.
                    PERFORM f_po_release USING lv_ebeln lt_t16fs-frgc8 ls_ekko-frgzu ls_ekko-frgke.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
            LOOP AT lt_docflow WHERE nourut = lv_nourut.
              lt_docflow-ebeln = lv_ebeln.
              MODIFY lt_docflow.
            ENDLOOP.
            CLEAR: lv_ebeln.
          ELSE.
            LOOP AT lt_return.
              WRITE: / lt_return-message.
            ENDLOOP.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
          CLEAR: ls_poheader, ls_poheaderx, lt_poitem[], lt_poitemx[], lt_return[], l_ctr, lt_poitem, lt_poitemx, lt_return .
        ENDAT.
      ENDLOOP.
      DELETE lt_docflow WHERE ebeln IS  INITIAL.
      SORT lt_docflow BY vbeln.
      LOOP AT lt_docflow.
        LOOP AT gt_s642_po INTO gs_s642 WHERE vbeln = lt_docflow-vbeln.
          gs_s642-po_int = lt_docflow-ebeln.
          MODIFY s642 FROM gs_s642.
          COMMIT WORK AND WAIT.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PROSES_POINTER_ALL

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         groups    TYPE STANDARD TABLE OF bapigroups,
         ls_groups LIKE LINE OF groups.
  CLEAR: gv_xruem, gv_usrtrd.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup = 'TRD'.
      gv_usrtrd = 'X'.
    ENDIF.
  ENDLOOP.
  SELECT SINGLE xruem INTO gv_xruem FROM marv WHERE bukrs = '8020'.

ENDFORM.                    " F_INIT_DATA
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_CUSTOMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_KUNNR  text
*      -->P_LS_ZTDNSDDT003_KUNNR_SOLD  text
*----------------------------------------------------------------------*
FORM f_change_customer  USING    p_kunnr
                                 p_kunnr_sold
                       CHANGING p_return.
  DATA: ls_kna1 TYPE kna1. " WITH HEADER LINE.
  DATA: ls_knvv TYPE knvv. " WITH HEADER LINE.
  DATA: ls_knb1 TYPE knb1. " WITH HEADER LINE.
  DATA: ls_okna1 TYPE kna1. " WITH HEADER LINE.
  DATA: lv_kunnr LIKE kna1-kunnr.
  DATA: lt_xknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_xknvp TYPE fknvp. " WITH HEADER LINE.
  DATA: lt_yknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_yknvp TYPE fknvp. " WITH HEADER LINE.

  CLEAR: ls_kna1, ls_knvv, ls_knb1, lt_xknvp[], lt_yknvp[].
  SELECT SINGLE * INTO ls_kna1 FROM kna1 WHERE kunnr = p_kunnr.
  SELECT SINGLE * INTO ls_knvv FROM knvv WHERE kunnr = p_kunnr.
  SELECT SINGLE * INTO ls_knb1 FROM knb1 WHERE kunnr = p_kunnr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_xknvp FROM knvp WHERE kunnr = p_kunnr.

  LOOP AT lt_xknvp.
    IF lt_xknvp-parvw = 'WE' OR lt_xknvp-parvw = 'ZS'.
    ELSE.
      lt_xknvp-kunn2 = p_kunnr_sold.
    ENDIF.
    APPEND lt_xknvp TO lt_yknvp.
  ENDLOOP.

  CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
    EXPORTING
      i_kna1                  = ls_kna1
      i_knb1                  = ls_knb1
      i_knvv                  = ls_knvv
    IMPORTING
      e_kunnr                 = lv_kunnr " i_bapiaddr1 = ls_bapiaddr1
      o_kna1                  = ls_okna1
    TABLES
      t_xknvp                 = lt_yknvp
      t_yknvp                 = lt_xknvp
    EXCEPTIONS
      client_error            = 1 "T_XKNVK STRUCTURE FKNVK OPTIONAL
      kna1_incomplete         = 2
      knb1_incomplete         = 3
      knb5_incomplete         = 4
      knvv_incomplete         = 5
      kunnr_not_unique        = 6
      sales_area_not_unique   = 7
      sales_area_not_valid    = 8
      insert_update_conflict  = 9
      number_assignment_error = 10
      number_not_in_range     = 11
      number_range_not_extern = 12
      number_range_not_intern = 13
      account_group_not_valid = 14
      parnr_invalid           = 15
      bank_address_invalid    = 16
      tax_data_not_valid      = 17
      no_authority            = 18
      company_code_not_unique = 19
      dunning_data_not_valid  = 20
      knb1_reference_invalid  = 21
      cam_error               = 22
      OTHERS                  = 23.
  p_return = sy-subrc.
  IF sy-subrc NE 0.
    WRITE: / 'Code: ', sy-subrc.
    " WRITE: / wa_order-no_order, sy-vline, wa_order-phone_cust, sy-vline, wa_order-nama_cust, ' --> ', lv_kunnr.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    "      WRITE: / wa_order-no_order, sy-vline, wa_order-phone_cust, sy-vline, wa_order-nama_cust, ' --> ', lv_kunnr.
  ENDIF.


ENDFORM.                    " F_CHANGE_CUSTOMER
