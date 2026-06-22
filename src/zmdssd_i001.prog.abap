*&---------------------------------------------------------------------*
*& Report  ZSPICKUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmdssd_i001 NO STANDARD PAGE HEADING.

TABLES: nast, vttk, vttp, likp.
"INCLUDE rvadtabl.

"INCLUDE zabp_frm.

"INCLUDE zspickuptop.

DATA : gv_kschl   TYPE nast-kschl,
       xscreen(1).

DATA : BEGIN OF t_nast_key,
         tknum TYPE vttk-tknum,
       END OF t_nast_key.

DATA : gt_vttk TYPE STANDARD TABLE OF vttk,
       gt_vttp TYPE STANDARD TABLE OF vttp,
       gt_vbpa TYPE STANDARD TABLE OF vbpa,
       gt_vbfa TYPE STANDARD TABLE OF vbfa,
       gt_likp TYPE STANDARD TABLE OF likp,
       gt_kna1 TYPE STANDARD TABLE OF kna1,
       gt_detl TYPE STANDARD TABLE OF zspickupst,
       gt_item TYPE STANDARD TABLE OF zspickupst,
       gs_head TYPE zspickupst.

**SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE TEXT-dat.
**PARAMETERS: p_tdform LIKE ssfscreen-fname DEFAULT 'ZSPIKUP' NO-DISPLAY,
**            p_dest   LIKE tsp03-padest DEFAULT 'BM1SP10_TEMP',
**            p_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
**SELECTION-SCREEN END OF BLOCK blxx.


SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS p_tknum TYPE vttk-tknum .
SELECTION-SCREEN END OF BLOCK data.

START-OF-SELECTION.
  "  PERFORM f_send_api USING p_tknum CHANGING sy-subrc.
  nast-objky = p_tknum.
  PERFORM entry USING sy-subrc sy-subrc.

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  "  gv_kschl    = nast-kschl.
  "  t_nast_key  = nast-objky.
  p_tknum     = nast-objky.
  CLEAR: return_code, us_screen.
  PERFORM f_send_api USING p_tknum CHANGING return_code.
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
  TYPES: BEGIN OF ty_detail,
           customer_id        TYPE string, ":"0400271472",
           transzone_id       TYPE string, ":"201D58",
           transzone_nm       TYPE string, ":"DK RAYON 58",
           dklk               TYPE string, ":"",
           delivery_note_no   TYPE string, ":"10837562598",
           delivery_note_date TYPE string, ":"",
           delivery_note_time TYPE string, ":"",
           volume             TYPE string, ":614303.94,
           volume_satuan      TYPE string,
           weight             TYPE string, ": 422807.95,
           weight_satuan      TYPE string,
           carton             TYPE string, ":0.0,
           net_value          TYPE string, ":0.0,
           top                TYPE string, ":0.0,
           is_trd             TYPE string, ":"Y",
           payment_type       TYPE string, ":"COD"
           no_po              TYPE string,
         END OF ty_detail.
  TYPES: BEGIN OF ty_ship,
           shipment_id             TYPE string, ":"1002215087",
           shipment_start_date     TYPE string, ":"20241120",
           shipment_start_time     TYPE string, ":"",
           sales_org_id            TYPE string,             ":"8020",
           branch_id               TYPE string,             ":"0201",
           trans_planning_point_id TYPE string,             ":"0201",
           shipment_type           TYPE string, ":"YN01",
           shipment_route          TYPE string, ":"201D58",
           shipping_type           TYPE string, ":"08",
           vehicle_reg_no          TYPE string, ":"B 9945 SXR",
           deliveryman_id          TYPE string, ":"783",
           detail                  TYPE STANDARD TABLE OF ty_detail WITH DEFAULT KEY,
         END OF ty_ship.

  DATA: ls_ship TYPE ty_ship.
  DATA: ls_detail TYPE ty_detail.
  DATA: ls_header TYPE ty_ship.
  DATA: lv_text(15).
  TYPES: BEGIN OF ty_vttk, " occurs 0,
           tknum     TYPE vttk-tknum,
           datbg     TYPE vttk-datbg,
           uatbg     TYPE vttk-uatbg,
           tplst     TYPE vttk-tplst,
           shtyp     TYPE vttk-shtyp,
           route_s   TYPE vttk-route,
           vsart     TYPE vttk-vsart,
           signi     TYPE vttk-signi,
           exti1     TYPE vttk-exti1,
           "          bezei TYPE tvrot-bezei,
           vbeln     TYPE vttp-vbeln,
           kunnr     TYPE likp-kunnr,
           route_l   TYPE likp-routa,
           "ls_detail-dklk =
           "           vbeln     TYPE likp-vbeln,
           lfart     TYPE likp-lfart,
           wadat_ist TYPE likp-wadat_ist,
           wauhr     TYPE likp-wauhr,
           volum     TYPE likp-volum,
           voleh     TYPE likp-voleh,
           btgew     TYPE likp-btgew,
           gewei     TYPE likp-gewei,
           anzpk     TYPE likp-anzpk,
           inco2     TYPE likp-inco2,
           vgbel     TYPE lips-vgbel,
           bezei     TYPE tvrot-bezei,
           katr1     TYPE kna1-katr1,
           zterm     TYPE vbkd-zterm,
**           matnr     LIKE lips-matnr,
**           vrkme     LIKE lips-vrkme,
**           lfimg     LIKE lips-lfimg,
**           brgew     LIKE lips-brgew,
**           volum1     LIKE lips-volum,
           "           netwr     TYPE vbak-netwr,
         END OF ty_vttk,
         BEGIN OF ty_ekko,
           ebeln TYPE ekbe-ebeln,
           belnr TYPE ekbe-belnr,
           vgabe TYPE ekbe-vgabe,
           ihrez TYPE ekko-ihrez,
           verkf TYPE ekko-verkf,
         END OF ty_ekko,
         BEGIN OF ty_vbkd,
           vbeln_dn TYPE vbkd-vbeln,
           vbeln_so TYPE vbkd-vbeln,
           posnr    TYPE vbap-posnr,
           zterm    TYPE vbkd-zterm,
           ztag1    TYPE t052-ztag1,
           abrvw    TYPE vbak-abrvw,
           netwr    TYPE vbak-netwr,
         END OF ty_vbkd.

  DATA: lt_vttk TYPE STANDARD TABLE OF ty_vttk.
  DATA: lt_vttk_ptt TYPE STANDARD TABLE OF ty_vttk.
  DATA: lt_vttk_trd TYPE STANDARD TABLE OF ty_vttk.
  DATA: ls_vttk TYPE ty_vttk.

  DATA: lt_ekko TYPE STANDARD TABLE OF ty_ekko.
  DATA: ls_ekko TYPE ty_ekko.

  DATA: lt_vbkd TYPE STANDARD TABLE OF ty_vbkd.
  DATA: lt_vbkd_ptt1 TYPE STANDARD TABLE OF ty_vbkd.
  DATA: lt_vbkd_ptt TYPE STANDARD TABLE OF ty_vbkd WITH HEADER LINE.
  DATA: ls_vbkd TYPE ty_vbkd.

  DATA: l_name(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA : let_docflow   TYPE tdt_docflow.
  DATA: lw_docflow     TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.
  DATA: lv_str          TYPE string.
  "  DATA: lv_text(15).
  DATA: BEGIN OF lt_lipssum1 OCCURS 0,
          vbeln LIKE vttp-vbeln,
          vgbel LIKE lips-vgbel,
          matnr LIKE lips-matnr,
          vrkme LIKE lips-vrkme,
          lfimg LIKE lips-lfimg,
          brgew LIKE lips-brgew,
          volum LIKE lips-volum,
        END OF lt_lipssum1.

  DATA: BEGIN OF lt_lipssum OCCURS 0,
          vbeln LIKE vttp-vbeln,
          vgbel LIKE lips-vgbel,
          matnr LIKE lips-matnr,
          vrkme LIKE lips-vrkme,
          lfimg LIKE lips-lfimg,
          brgew LIKE lips-brgew,
          volum LIKE lips-volum,
        END OF lt_lipssum.
  DATA: ls_lipssum LIKE LINE OF lt_lipssum.
  DATA: ls_lipssum1 LIKE LINE OF lt_lipssum1.

  SELECT a~tknum datbg uatbg tplst shtyp a~route a~vsart signi exti1 b~vbeln
          c~kunnr c~route  lfart   wadat_ist wauhr  c~volum c~voleh btgew  c~gewei anzpk inco2 vgbel d~bezei katr1
"           f~matnr f~vrkme f~lfimg f~brgew f~volum
    INTO  TABLE lt_vttk
    FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
                   JOIN likp AS c ON b~vbeln = c~vbeln
                   JOIN lips AS f ON f~vbeln = c~vbeln
                   JOIN tvrot AS d ON c~route = d~route AND d~spras = sy-langu
                   JOIN kna1 AS e ON e~kunnr = c~kunnr
    WHERE a~tknum = p_tknum.
  IF sy-subrc EQ 0.
    SORT lt_vttk BY tknum vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vttk COMPARING ALL FIELDS.
    CLEAR: ls_lipssum.
    LOOP AT lt_vttk INTO ls_vttk .
      SELECT vbeln vgbel matnr vrkme SUM( lfimg ) SUM( brgew ) SUM( volum )
          INTO  ls_lipssum FROM lips
          WHERE vbeln = ls_vttk-vbeln
        GROUP BY vbeln vgbel matnr vrkme.

        CALL FUNCTION 'EHSWA_490_UNIT_CONVERSION'
          EXPORTING
            i_unit_source           = ls_lipssum-vrkme
            i_unit_target           = 'KAR'
            i_quantity_source       = ls_lipssum-lfimg
            i_matnr                 = ls_lipssum-matnr
          IMPORTING
            e_quantity_target       = ls_lipssum-lfimg
          EXCEPTIONS
            parameter_error         = 1
            err_conversion_global   = 2
            err_conversion_material = 3
            OTHERS                  = 4.
        IF sy-subrc <> 0.
          ls_lipssum-lfimg = 0.
        ENDIF.
        APPEND ls_lipssum TO lt_lipssum.
        CLEAR: ls_lipssum.
      ENDSELECT.

    ENDLOOP.
    lt_lipssum1[] = lt_lipssum[].
    CLEAR: lt_lipssum[].
    LOOP AT lt_lipssum1 INTO ls_lipssum1.
      MOVE-CORRESPONDING ls_lipssum1 TO    ls_lipssum.
      CLEAR: ls_lipssum-matnr, ls_lipssum-vrkme.
      COLLECT ls_lipssum INTO lt_lipssum.
    ENDLOOP.
    lt_vttk_trd[] = lt_vttk[].
**** Untuk Order TRD
    DELETE lt_vttk_trd[] WHERE lfart NE 'ZTD1'.
    SORT lt_vttk_trd BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vttk_trd COMPARING vbeln.
    IF lt_vttk_trd[] IS NOT INITIAL.
      SELECT a~ebeln belnr vgabe ihrez verkf INTO TABLE lt_ekko
        FROM ekbe AS a JOIN ekko AS b ON a~ebeln = b~ebeln
        FOR ALL ENTRIES IN lt_vttk_trd
        WHERE belnr = lt_vttk_trd-vbeln.
      IF sy-subrc EQ 0.
        SORT lt_ekko BY ebeln belnr.
        DELETE ADJACENT DUPLICATES FROM lt_ekko COMPARING ebeln belnr.
      ENDIF.
    ENDIF.
**** Untuk Order PTT Reguler ( buat ambil payment type  (CBD, COD dan lainnya )
    lt_vttk_ptt[] = lt_vttk[].
    DELETE lt_vttk_ptt[] WHERE lfart EQ 'ZTD1'.
    "    DELETE lt_vttk_ptt[] WHERE vgbel IS INITIAL.
    IF lt_vttk_ptt[] IS NOT INITIAL.
      SORT lt_vttk_ptt BY vbeln.
      SELECT a~vbeln b~vbeln e~posnr b~zterm ztag1 d~abrvw e~kzwi5 INTO TABLE lt_vbkd_ptt
        FROM lips AS a JOIN vbkd AS b ON a~vgbel = b~vbeln
                       JOIN t052 AS c ON b~zterm = c~zterm
                       JOIN vbak AS d ON a~vgbel = d~vbeln
                       JOIN vbap AS e ON d~vbeln = e~vbeln
        FOR ALL ENTRIES IN lt_vttk_ptt
        WHERE a~vbeln = lt_vttk_ptt-vbeln.
      IF sy-subrc EQ 0.
        SORT lt_vbkd_ptt BY vbeln_dn vbeln_so.
        IF lt_vbkd_ptt[] IS NOT INITIAL.
          lt_vbkd_ptt1[] = lt_vbkd_ptt[].
          CLEAR: lt_vbkd_ptt[].
          LOOP AT lt_vbkd_ptt1 INTO ls_vbkd.
            MOVE-CORRESPONDING ls_vbkd TO lt_vbkd_ptt.
            CLEAR: lt_vbkd_ptt-posnr.
            COLLECT lt_vbkd_ptt.
          ENDLOOP.
        ENDIF.
        "        DELETE ADJACENT DUPLICATES FROM lt_vbkd_ptt COMPARING vbeln_dn vbeln_so.
      ENDIF.
    ENDIF.
    DATA: ld_lfimg TYPE p DECIMALS 1.

    LOOP AT lt_vttk INTO ls_vttk.
      "      AT FIRST.
      IF ls_vttk-wadat_ist IS INITIAL.
        CONTINUE.
      ENDIF.
      ls_ship-shipment_id = ls_vttk-tknum.
      ls_ship-shipment_start_date = sy-datum. "ls_vttk-datbg.
      ls_ship-shipment_start_time = sy-uzeit. "ls_vttk-uatbg.
      ls_ship-sales_org_id = '8020'.
      ls_ship-branch_id = ls_vttk-tplst.
      ls_ship-trans_planning_point_id = ls_vttk-tplst.
      ls_ship-shipment_type = ls_vttk-shtyp.
      ls_ship-shipment_route = ls_vttk-route_s.
      ls_ship-shipping_type = ls_vttk-vsart.
      ls_ship-vehicle_reg_no = ls_vttk-signi.
      "      ENDAT.
      ls_detail-customer_id = ls_vttk-kunnr.
      ls_detail-transzone_id = ls_vttk-route_l.
      ls_detail-transzone_nm = ls_vttk-bezei.
      ls_detail-dklk = ls_vttk-katr1.
      ls_detail-delivery_note_no = ls_vttk-vbeln.
      ls_detail-delivery_note_date = ls_vttk-wadat_ist.
      ls_detail-delivery_note_time = ls_vttk-wauhr.
      ls_detail-volume = ls_vttk-volum.
      ls_detail-volume_satuan = ls_vttk-voleh.
      ls_detail-weight = ls_vttk-btgew.
      ls_detail-weight_satuan = ls_vttk-gewei.
      SORT lt_lipssum BY vbeln.
      READ TABLE lt_lipssum INTO ls_lipssum WITH KEY vbeln = ls_vttk-vbeln BINARY SEARCH.
      IF sy-subrc EQ 0.
        ld_lfimg = ls_lipssum-lfimg.
        WRITE ld_lfimg TO lv_text UNIT 'CAR' NO-GROUPING NO-GAP.
        REPLACE ALL OCCURRENCES OF ',' IN lv_text WITH '.' .
        ls_detail-carton = lv_text. "ls_lipssum-lfimg. "ls_vttk-anzpk.
      ENDIF.
      CONDENSE: ls_detail-volume, ls_detail-weight, ls_detail-carton.
      IF ls_vttk-lfart = 'ZTD1'.
        ls_detail-is_trd = 'X'.
        ls_detail-payment_type = ls_vttk-inco2.
        ls_detail-top = '000'.
        SORT lt_ekko BY belnr.
        READ TABLE lt_ekko INTO ls_ekko WITH KEY belnr = ls_vttk-vbeln BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_detail-net_value = ls_ekko-ihrez.
          ls_detail-no_po = ls_ekko-verkf.
        ENDIF.
      ELSEIF ls_vttk-lfart = 'YTO1'.
        CLEAR: ls_detail-top, ls_detail-net_value.
        ls_detail-payment_type = 'M'.
      ELSE.
        SORT lt_vbkd_ptt BY vbeln_dn.
        READ TABLE lt_vbkd_ptt INTO ls_vbkd  WITH KEY vbeln_dn = ls_vttk-vbeln BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_detail-top = ls_vbkd-ztag1.
          ls_detail-payment_type = ls_vbkd-abrvw.
          WRITE: ls_vbkd-netwr TO lv_text CURRENCY 'IDR' NO-GROUPING DECIMALS 0 NO-GAP.
          CONDENSE: lv_text.
          ls_detail-net_value = lv_text.
        ENDIF.
      ENDIF.
      APPEND ls_detail TO ls_ship-detail.
      CLEAR: ls_detail.
    ENDLOOP.
  ENDIF.
  IF ls_ship-shipment_id IS NOT INITIAL.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = ls_ship.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).

    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'MDS_SENDSHIP' sy-subrc lv_str.
    PERFORM f_protocol_update USING 'ZAB' '000' lv_str.

    l_name  = p_tknum.
    CONCATENATE 'Shp_' l_name INTO l_name.
    CONDENSE l_name.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/outbound/mds/api/' 'MDS_SENDSHIP'.
  ENDIF.
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

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_CARTON
*&---------------------------------------------------------------------*
FORM f_calculate_carton  USING    fu_lgnum fu_tanum
                         CHANGING fc_carton fc_receh.
  TYPES : BEGIN OF ty_sum,
            matnr TYPE ltap-matnr,
            charg TYPE ltap-charg,
            vsolm TYPE ltap-vsolm,
          END OF ty_sum.

  DATA : lt_ltap   TYPE STANDARD TABLE OF ltap,
         ls_ltap   LIKE LINE OF lt_ltap,
         lt_sum    TYPE STANDARD TABLE OF ty_sum,
         ls_sum    LIKE LINE OF lt_sum,
         lv_umrez  TYPE marm-umrez,
         lv_volum  TYPE mara-volum,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0,
         lv_receh  TYPE p DECIMALS 0,
         lv_carton TYPE p DECIMALS 0,
         lv_bagi   TYPE p DECIMALS 4.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  SORT lt_ltap BY matnr charg.
  LOOP AT lt_ltap INTO ls_ltap.
    ls_sum-matnr  = ls_ltap-matnr.
    ls_sum-charg  = ls_ltap-charg.
    ls_sum-vsolm  = ls_ltap-vsolm.
    COLLECT ls_sum INTO lt_sum.
    CLEAR ls_sum.
  ENDLOOP.

  CLEAR ls_sum.
  LOOP AT lt_sum INTO ls_sum.
    SELECT SINGLE volum
      FROM mara
      INTO lv_volum
      WHERE matnr = ls_sum-matnr.

    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_sum-matnr
        AND meinh = 'KAR'.
    IF sy-subrc = 0.
      lv_mod    = ls_sum-vsolm MOD lv_umrez.
      lv_receh  = lv_receh + ( lv_mod * lv_volum ).
      lv_div    = ls_sum-vsolm DIV lv_umrez.
      ADD lv_div TO lv_carton.
    ENDIF.
    CLEAR : lv_mod, lv_div.
  ENDLOOP.

  lv_bagi = lv_receh / 25000.

  CALL FUNCTION 'ROUND'
    EXPORTING
      input         = lv_bagi
      sign          = '+'
    IMPORTING
      output        = lv_receh
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

  fc_carton = lv_carton.
  CONDENSE fc_carton NO-GAPS.
  fc_receh  = lv_receh.
  CONDENSE fc_receh NO-GAPS.
ENDFORM.                    " F_CALCULATE_CARTON


"INCLUDE zspickupf01.
