*----------------------------------------------------------------------*
***INCLUDE LZHSM_EPROCF05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_UOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_A049_KMEIN  text
*      <--P_LS_BUDGET_UOM_BUDGET  text
*----------------------------------------------------------------------*
FORM f_conversion_uom  USING    fu_meins
                        CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PLANT  text
*      -->P_MATNR  text
*      <--P_FPKH_HEADER  text
*----------------------------------------------------------------------*
FORM f_get_header  USING    p_plant
                            p_matnr
                   CHANGING p_fpkh_header p_type p_message.
  DATA: lv_plant     TYPE werks_d,
        lv_matnr     TYPE matnr,
        lv_tender    TYPE submi,
        lv_manual(1).

  TYPES: BEGIN OF ty_mara, " OCCURS 0,
           matnr TYPE mara-matnr,
           mtart TYPE mara-mtart,
           bmatn TYPE mara-matnr,
           maktx TYPE makt-maktx,
           ekgrp TYPE eine-ekgrp,
           meins TYPE eina-meins,
           maabc TYPE marc-maabc,
           lifnr TYPE /sapsll/v_einr3-lifnr,
           name1 TYPE lfa1-name1,
         END OF ty_mara.
  DATA: lt_mara TYPE STANDARD TABLE OF ty_mara.
  DATA: ls_mara LIKE LINE OF lt_mara.

  DATA: BEGIN OF lt_a049 OCCURS 0,
          kschl TYPE a049-kschl,
          ekorg TYPE a049-ekorg,
          matnr TYPE a049-matnr,
          datbi TYPE a049-datbi,
          datab TYPE a049-datab,
          knumh TYPE a049-knumh,
          kbetr TYPE konp-kbetr,
          konwa TYPE konp-konwa,
          kmein TYPE konp-kmein,
          kpein TYPE konp-kpein,
          prgrp TYPE pgmi-prgrp,
        END OF lt_a049.
  DATA: BEGIN OF lt_a501 OCCURS 0,
          kschl TYPE a501-kschl,
          ekorg TYPE a501-ekorg,
          matnr TYPE a501-matnr,
          inco1 TYPE a501-inco1,
          datbi TYPE a501-datbi,
          datab TYPE a501-datab,
          knumh TYPE a501-knumh,
          kbetr TYPE konp-kbetr,
          konwa TYPE konp-konwa,
          kmein TYPE konp-kmein,
          kpein TYPE konp-kpein,
          prgrp TYPE pgmi-prgrp,
        END OF lt_a501.

  DATA: BEGIN OF lt_po OCCURS 0,
          ebeln LIKE ekko-ebeln,
          lifnr LIKE ekko-lifnr,
          knumv LIKE ekko-knumv,
          name1 LIKE lfa1-name1,
          ebelp LIKE ekpo-ebelp,
          matnr LIKE ekpo-matnr,
          aedat LIKE ekko-aedat,
          ematn LIKE ekpo-ematn,
          werks LIKE ekpo-werks,
          preis LIKE eipa-preis,
          peinh LIKE eipa-peinh,
          bprme LIKE eipa-bprme,
          bwaer LIKE eipa-bwaer,
          menge LIKE ekpo-menge,
          meins LIKE ekpo-meins,
          lprei LIKE eipa-lprei, "Kurs ke IDR
          lpein LIKE eipa-lpein, "unit kurs
          lwaer LIKE eipa-lwaer,
          bedat LIKE eipa-bedat,
          "          knumv like ekko-knumv,
        END OF lt_po.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.

  DATA: BEGIN OF ls_eipa,
          ebeln TYPE eipa-ebeln,
          ebelp TYPE eipa-ebelp,
          bedat TYPE eipa-bedat,
        END OF ls_eipa.
  DATA: ls_zhsmmmdt009 TYPE zhsmmmdt009.
  DATA: gt_eban TYPE STANDARD TABLE OF eban WITH HEADER LINE.
  RANGES gr_frgkz     FOR eban-frgkz.
  RANGES gr_badat   FOR eban-badat.
  DATA: ls_budget TYPE zhsmmmst005.
  lv_plant = p_plant.
  lv_matnr = p_matnr.
  CLEAR: ls_budget.

  SELECT SINGLE * INTO  ls_zhsmmmdt009 FROM zhsmmmdt009 WHERE bukrs = lv_plant.
  IF sy-subrc EQ 0.
    lv_plant = ls_zhsmmmdt009-werks.
  ENDIF.

  TRANSLATE lv_matnr TO UPPER CASE.
  SELECT a~matnr, mtart, bmatn, maktx, ekgrp, a~meins, d~lifnr, name1
     INTO CORRESPONDING FIELDS OF TABLE @lt_mara
     FROM mara AS a
          JOIN makt AS b ON a~matnr = b~matnr
 "         JOIN marc AS c ON a~matnr = c~matnr
          LEFT OUTER JOIN eina AS d ON a~matnr = d~matnr
          LEFT OUTER JOIN eine AS f ON f~infnr = d~infnr
          LEFT OUTER JOIN lfa1 AS e ON e~lifnr = d~lifnr
     WHERE ( a~matnr = @lv_matnr OR a~bmatn = @lv_matnr )
"        AND c~werks = p_werks
        AND b~spras = @sy-langu
        AND d~loekz EQ @space
       AND lvorm EQ @space
       AND ekorg = 'TNT'.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING ALL FIELDS.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_a049
   FROM a049 AS a JOIN konp AS b ON a~knumh = b~knumh
   WHERE matnr = lv_matnr
     AND a~kschl = 'ZBGT'
     AND ekorg = 'TNT'
     AND loevm_ko EQ space
     AND datbi >= sy-datum. " AND datab <= sy-datum.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_a501
    FROM a501 AS a JOIN konp AS b ON a~knumh = b~knumh
    WHERE matnr = lv_matnr
      AND a~kschl = 'ZBGT'
     AND loevm_ko EQ space
      AND ekorg = 'TNT'
      AND datbi >= sy-datum. " AND datab <= sy-datum. " AND datab >= ld_awal ).

  SELECT a~ebeln a~ebelp  a~bedat  INTO ls_eipa UP TO 1 ROWS
    FROM eipa AS a JOIN ekpo AS b ON a~ebeln = b~ebeln
                                  AND a~ebelp = b~ebelp
    WHERE matnr = lv_matnr
      AND ekorg = 'TNT'
      AND b~loekz EQ space
      AND a~werks = lv_plant
    ORDER BY bedat DESCENDING.
  ENDSELECT.
  IF lv_plant = '1900'.
    IF sy-subrc NE 0 OR ls_eipa IS INITIAL.
      lv_plant = '1601'.
      SELECT a~ebeln a~ebelp  a~bedat  INTO ls_eipa UP TO 1 ROWS
        FROM eipa AS a JOIN ekpo AS b ON a~ebeln = b~ebeln
                                      AND a~ebelp = b~ebelp
        WHERE matnr = lv_matnr
          AND ekorg = 'TNT'
          AND loekz EQ space
          "AND a~loekz EQ space
          AND a~werks = lv_plant
        ORDER BY bedat DESCENDING.
      ENDSELECT.
      lv_plant = p_plant.
    ENDIF.
  ENDIF.

  SELECT c~ebeln b~lifnr b~knumv name1 c~ebelp matnr  a~aedat ematn c~werks preis c~peinh c~bprme bwaer
         a~menge meins b~bedat lprei lpein lwaer
    INTO CORRESPONDING FIELDS OF TABLE lt_po
    FROM ekpo AS a JOIN ekko AS b ON a~ebeln = b~ebeln
                   JOIN eipa AS c ON a~ebeln = c~ebeln AND
                                     a~infnr = c~infnr AND
                                     a~ebelp = c~ebelp
                   JOIN lfa1 AS d ON b~lifnr = d~lifnr
    WHERE matnr = lv_matnr
      AND a~ebeln = ls_eipa-ebeln
      AND a~ebelp = ls_eipa-ebelp
      AND a~loekz EQ space
      AND b~loekz EQ space.
  "      AND c~loekz EQ space.

  ls_budget-tahun                = sy-datum(4).
  ls_budget-material             = lv_matnr.
  ls_budget-plant               = lv_plant.
  ls_budget-last_po              = ls_eipa-ebeln. "TYPE ebeln, ": "99001289123",
  ls_budget-date_po              = ls_eipa-bedat. "TYPE  string, "sy-datum, ": "20240510",
  READ TABLE lt_po INDEX 1.

  DATA: lv_text(20).
  DATA: ls_konv TYPE konv.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_konv
       FROM konv WHERE knumv = lt_po-knumv
                   AND kposn = lt_po-ebelp
                   AND kschl = 'ZPB0'.
  IF sy-subrc EQ 0.
    IF lt_po-bwaer = ls_konv-waers.
    ELSE.
      IF lt_po-lwaer IS INITIAL.
        lt_po-bwaer =  ls_konv-waers.
        lt_po-preis =  ls_konv-kbetr.
        lt_po-lprei =  ls_konv-kkurs * 1000.
        lt_po-lpein =  ls_konv-kpein.
      ENDIF.
    ENDIF.
  ENDIF.

  ls_budget-kode_vendor_po       = lt_po-lifnr. "LIKE ekko-lifnr, ": "800000001",
  ls_budget-nama_vendor_po       = lt_po-name1. ", ": "PT.ABC",
  ls_budget-last_item_po         = lt_po-ebelp. ", ": "T001"
  WRITE lt_po-menge TO ls_budget-qty_po  DECIMALS 0 NO-GROUPING NO-SIGN NO-GAP.
  "  ls_budget-qty_po            = lt_po-menge. "               TYPE string, "p DECIMALS 0, ": 50,
  CONDENSE ls_budget-qty_po.
  PERFORM f_conversion_uom USING lt_po-bprme CHANGING ls_budget-uom_po.


  IF lt_po-bwaer = 'IDR'.
    WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_po-bwaer.
  ELSE.
    WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_po-bwaer.
  ENDIF.
  CONDENSE lv_text.
  ls_budget-price_po          = lv_text.  "   TYPE string,                ": 234000,
  WRITE lt_po-peinh TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
  CONDENSE lv_text.
  ls_budget-per_po = lv_text .
  ls_budget-currency_po = lt_po-bwaer. "TYPE string, ": "IDR",
  WRITE lt_po-lprei TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
  CONDENSE lv_text.
  ls_budget-po_conversi = lv_text.
  PERFORM f_conversion_uom USING lt_po-lpein CHANGING ls_budget-per_conversi.
  "  ls_budget-per_conversi = lt_po-lpein.
  CONDENSE ls_budget-per_conversi.
  ls_budget-currency_conversi = lt_po-lwaer.
  SORT lt_a501 BY matnr.
  READ TABLE lt_a501 WITH KEY matnr = lv_matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_budget-incoterm = lt_a501-inco1.
    ls_budget-currency_incoterm = lt_a501-konwa.
    "    ls_budget-currency_budget = lt_a501-konwa.
    IF lt_a501-konwa = 'IDR'.
      WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a501-konwa.
    ELSE.
      WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a501-konwa.
    ENDIF.
    "ls_budget-price_incoterm = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
    CONDENSE lv_text.
    ls_budget-price_incoterm = lv_text.
    "    ls_budget-price_budget = lv_text.
    ls_budget-per_incoterm = lt_a501-kpein. " Per
    "   ls_budget-per_budget = lt_a501-kpein.
    CONDENSE ls_budget-per_incoterm.
    PERFORM f_conversion_uom USING lt_a501-kmein CHANGING ls_budget-uom_incoterm.
  ENDIF..
  SORT lt_a049 BY matnr.
  READ TABLE lt_a049 WITH KEY matnr = lv_matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_budget-currency_budget = lt_a049-konwa.
    IF lt_a049-konwa = 'IDR'.
      WRITE lt_a049-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a049-konwa.
    ELSE.
      WRITE lt_a049-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a049-konwa.
    ENDIF.
    CONDENSE lv_text.
    ls_budget-price_budget = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
    ls_budget-per_budget = lt_a049-kpein. " Per
    CONDENSE ls_budget-per_budget.
    PERFORM f_conversion_uom USING lt_a049-kmein CHANGING ls_budget-uom_budget.
  ENDIF.
  SORT lt_mara BY matnr.
  READ TABLE lt_mara INTO ls_mara WITH KEY matnr = lv_matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_budget-material_description = ls_mara-maktx.
    ls_budget-purchasing_group = ls_mara-ekgrp.
    PERFORM f_conversion_uom USING ls_mara-meins CHANGING ls_budget-uom.
  ELSE.
    SELECT SINGLE a~matnr maktx meins INTO CORRESPONDING FIELDS OF ls_mara
      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
      WHERE a~matnr = lv_matnr AND spras =  sy-langu.
    IF sy-subrc EQ 0.
      ls_budget-material_description = ls_mara-maktx.
      "      ls_budget-purchasing_group = ls_mara-ekgrp.
      PERFORM f_conversion_uom USING ls_mara-meins CHANGING ls_budget-uom.
    ENDIF.
  ENDIF.
  ls_budget-plant = p_plant.
  IF ls_budget-price_budget IS INITIAL.
    ls_budget-price_budget = ls_budget-price_incoterm.
    ls_budget-uom_budget = ls_budget-uom_incoterm.
    ls_budget-per_budget = ls_budget-per_incoterm.
    ls_budget-currency_budget = ls_budget-currency_incoterm.
  ENDIF.

**PRICE_INCOTERM
**CURRENCY_INCOTERM
**PER_INCOTERM
**UOM_INCOTERM

  p_fpkh_header = ls_budget.
  p_type = 'S'.
  CLEAR: p_message.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATAPR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_PR  text
*      -->P_PLANT  text
*      -->P_MATNR  text
*----------------------------------------------------------------------*
FORM f_get_datapr  TABLES   p_data_pr STRUCTURE zhsmmmst007
                   USING    p_plant
                            p_matnr
                   CHANGING p_type p_message.
  DATA: lv_plant     TYPE werks_d,
        lv_matnr     TYPE matnr,
        lv_tender    TYPE submi,
        lv_manual(1).


  DATA: lt_pr TYPE STANDARD TABLE OF zhsmmmst007. " WITH HEADER LINE.
  DATA: ls_pr LIKE LINE OF lt_pr.
  DATA: gt_eban TYPE STANDARD TABLE OF eban WITH HEADER LINE.
  RANGES gr_frgkz     FOR eban-frgkz.
  RANGES gr_badat   FOR eban-badat.
  DATA: lt_zhsmmmdt009 TYPE STANDARD TABLE OF zhsmmmdt009.
  lv_plant = p_plant.
  lv_matnr = p_matnr.

  SELECT * INTO TABLE lt_zhsmmmdt009 FROM zhsmmmdt009 WHERE bukrs = lv_plant.
*** non sap plant = 1601
  gr_frgkz-low    = ''.
  gr_frgkz-sign   = 'I'.
  gr_frgkz-option = 'EQ'.
  APPEND gr_frgkz. " TO gr_frgkz.
  gr_frgkz-low    = '2'.
  gr_frgkz-sign   = 'I'.
  gr_frgkz-option = 'EQ'.
  APPEND gr_frgkz. " TO gr_frgkz.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = 0
      months    = 0
      signum    = '-'
      years     = 2
    IMPORTING
      calc_date = gr_badat-low.

  CONCATENATE gr_badat-low(4) '0101' INTO gr_badat-low.
  gr_badat-high   = sy-datum.
  gr_badat-sign   = 'I'.
  gr_badat-option = 'BT'.
  APPEND gr_badat.

  IF lt_zhsmmmdt009[] IS NOT INITIAL.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_eban
    FROM eban
      FOR ALL ENTRIES IN lt_zhsmmmdt009
    WHERE matnr = lv_matnr
      AND werks = lt_zhsmmmdt009-werks
      AND loekz = space
*      AND statu IN gr_statu
      AND ebakz = space
"      AND frgkz = 'X' "IN gr_frgkz
       AND badat IN gr_badat
  "     AND lfdat IN so_lfdat
    ORDER BY PRIMARY KEY.
  ELSE.
    SELECT *
    FROM eban
    INTO CORRESPONDING FIELDS OF TABLE gt_eban
    WHERE matnr = lv_matnr
      AND werks = lv_plant
      AND loekz = space
*      AND statu IN gr_statu
      AND ebakz = space
      AND frgkz = '2' "IN gr_frgkz
       AND badat IN gr_badat
  "     AND lfdat IN so_lfdat
    ORDER BY PRIMARY KEY.
  ENDIF.

  IF gt_eban[] IS NOT INITIAL.
    LOOP AT gt_eban.
      ls_pr-pr_number               = gt_eban-banfn.
      ls_pr-pr_item_number          = gt_eban-bnfpo.
      ls_pr-pr_plant                = p_plant. "gt_eban-werks.
      ls_pr-pr_sloc                 = gt_eban-lgort.
      ls_pr-item_delivery_date      = gt_eban-lfdat.
      ls_pr-pr_material_number      = gt_eban-matnr.
      gt_eban-menge = gt_eban-menge - gt_eban-bsmng.
      "      ls_pr-pr_material_descprition = gt_eban-txz01.
      WRITE: gt_eban-menge TO ls_pr-pr_qty DECIMALS 0 NO-GROUPING NO-SIGN NO-GAP.
      CONDENSE ls_pr-pr_qty.
      "      ls_pr-pr_qty                  = gt_eban-menge.
      PERFORM f_conversion_uom USING gt_eban-meins CHANGING ls_pr-pr_satuan.
      IF gt_eban-menge NE 0.
        APPEND ls_pr TO lt_pr.
      ENDIF.
    ENDLOOP.
    p_data_pr[] = lt_pr[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATAVENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_VENDOR  text
*      -->P_PLANT  text
*      -->P_MATNR  text
*      <--P_P_TYPE  text
*      <--P_P_MESSAGE  text
*----------------------------------------------------------------------*
FORM f_get_datavendor  TABLES   p_data_vendor STRUCTURE zhsmmmst008
                       USING    p_plant
                                p_matnr
                       CHANGING p_type
                                p_message.
  DATA        lv_matnr     TYPE matnr.
  DATA        lv_plant     TYPE werks_d.

  TYPES: BEGIN OF ty_mara, " OCCURS 0,
           matnr TYPE mara-matnr,
           mtart TYPE mara-mtart,
           lifnr TYPE /sapsll/v_einr3-lifnr,
           name1 TYPE lfa1-name1,
         END OF ty_mara.
  DATA: lt_mara TYPE STANDARD TABLE OF ty_mara.
  DATA: ls_mara LIKE LINE OF lt_mara.
  DATA: lt_vendor TYPE STANDARD TABLE OF zhsmmmst008. " WITH HEADER LINE.
  DATA: ls_vendor LIKE LINE OF lt_vendor.

  "/SAPSLL/V_EINR3
  lv_matnr = p_matnr.
  lv_plant = p_plant.

  SELECT b~lifnr AS kode_vendor, name1 AS nama_vendor
     INTO CORRESPONDING FIELDS OF TABLE @lt_vendor
     FROM mara AS a
          JOIN /sapsll/v_einr3 AS b ON a~matnr = b~matnr
          JOIN lfa1 AS c ON b~lifnr = c~lifnr
     WHERE ( a~matnr = @lv_matnr OR a~bmatn = @lv_matnr )
"        AND b~werks = @lv_plant
        AND b~loekz EQ @space
       AND ekorg = 'TNT'.
  SORT lt_vendor BY kode_vendor.
  DELETE ADJACENT DUPLICATES FROM lt_vendor COMPARING kode_vendor.
  p_data_vendor[] = lt_vendor[].
ENDFORM.
