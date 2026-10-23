FUNCTION ztiam_ifi02.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(COST_CENTER) TYPE  KOSTL
*"     VALUE(GL_ACCOUNT) TYPE  KSTAR
*"     VALUE(TAHUN) TYPE  GJAHR
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"     VALUE(SALDO_BUDGET) TYPE  CHAR20
*"     REFERENCE(BUDGET) TYPE  CHAR20
*"     REFERENCE(ACTUAL) TYPE  CHAR20
*"     REFERENCE(COMMITMENT) TYPE  CHAR20
*"----------------------------------------------------------------------
  TYPES: BEGIN OF t_itab,
           kokrs  TYPE kokrs,
           objnr  TYPE objnr,
           gjahr  TYPE gjahr,
           kstar  TYPE kstar,
           wtg001 TYPE wtgxxx,
           wtg002 TYPE wtgxxx,
           wtg003 TYPE wtgxxx,
           wtg004 TYPE wtgxxx,
           wtg005 TYPE wtgxxx,
           wtg006 TYPE wtgxxx,
           wtg007 TYPE wtgxxx,
           wtg008 TYPE wtgxxx,
           wtg009 TYPE wtgxxx,
           wtg010 TYPE wtgxxx,
           wtg011 TYPE wtgxxx,
           wtg012 TYPE wtgxxx,
           wtg013 TYPE wtgxxx,
           wtg014 TYPE wtgxxx,
           wtg015 TYPE wtgxxx,
           wtg016 TYPE wtgxxx,
           wogbtr TYPE coep-wogbtr,
         END OF t_itab.
  TYPES: BEGIN OF ty_ebkn,
           banfn TYPE banfn,
           bnfpo TYPE bnfpo,
           werks TYPE ewerk,
           bedat TYPE bedat,
           ebeln TYPE ebeln,
           ebelp TYPE ebelp,
           zebkn TYPE dzebkn,
           sakto TYPE saknr,
           kostl TYPE kostl,
           netwr TYPE bwert,
         END OF ty_ebkn.

  DATA: lv_kostl TYPE kostl,
        lv_kstar TYPE kstar,
        lv_gjahr TYPE gjahr.

  DATA: lv_budget     TYPE wtgxxx,
        lv_actual     TYPE wtgxxx,
        lv_commitment TYPE netwr,
        lv_saldo      TYPE wtgxxx.

  lv_kostl = cost_center.
  lv_kstar = gl_account.
  lv_gjahr = tahun.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_kostl
    IMPORTING
      output = lv_kostl.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_kstar
    IMPORTING
      output = lv_kstar.

  DATA: gt_coej     TYPE TABLE OF t_itab WITH HEADER LINE.

* Get Budget &  Get Actual
  SELECT a~kokrs a~objnr a~gjahr a~kstar
         wtg001 wtg002 wtg003 wtg004 wtg005 wtg006 wtg007 wtg008 wtg009 wtg010 wtg011 wtg012 wtg013 wtg014 wtg015 wtg016 wogbtr
**         SUM( wtg001 ) SUM( wtg002 ) SUM( wtg003 ) SUM( wtg004 ) SUM( wtg005 ) SUM( wtg006 ) SUM( wtg007 ) SUM( wtg008 )
**         SUM( wtg009 ) SUM( wtg010 ) SUM( wtg011 ) SUM( wtg012 ) SUM( wtg013 ) SUM( wtg014 ) SUM( wtg015 ) SUM( wtg016 )
**         SUM( wogbtr )
    INTO CORRESPONDING FIELDS OF TABLE gt_coej
    FROM coej AS a JOIN coep AS b ON a~objnr = b~objnr
                                 AND a~gjahr = b~gjahr
    WHERE a~kstar = lv_kstar
      AND a~gjahr = lv_gjahr
      AND a~kokrs = '8010'
      AND b~vrgng = 'COIN'.
  "    GROUP BY a~kokrs a~objnr a~gjahr a~kstar .

  DATA: lv_field   TYPE char50,
        lv_monat_h TYPE monat,
        lv_monat   TYPE monat.
  DATA: lv_amount     TYPE wtgxxx.
  FIELD-SYMBOLS: <fs_field> TYPE any.

  CLEAR: lv_budget, lv_actual.
  LOOP AT gt_coej.
    lv_monat_h = sy-datum+4(2).
    lv_monat = 1.
    CLEAR: lv_amount.
    WHILE lv_monat LE lv_monat_h.
      CLEAR: lv_field.
      UNASSIGN: <fs_field>.
      CONCATENATE 'GT_COEJ-WTG0' lv_monat INTO lv_field.
      ASSIGN (lv_field) TO <fs_field>.
      ADD <fs_field> TO lv_amount.
      ADD 1 TO lv_monat.
    ENDWHILE.
    lv_budget = lv_budget + lv_amount.
    lv_actual = lv_actual + gt_coej-wogbtr .
  ENDLOOP.
  WRITE lv_actual TO actual NO-GROUPING NO-SIGN NO-GAP CURRENCY 'IDR'.
  WRITE lv_budget TO budget NO-GROUPING NO-SIGN NO-GAP CURRENCY 'IDR'.
  IF gt_coej[] IS NOT INITIAL.
* Get Commitment
    DATA: gt_ebkn     TYPE TABLE OF ty_ebkn WITH HEADER LINE.
    DATA: gr_bedat    TYPE RANGE OF bedat WITH HEADER LINE.
    DATA: gt_ekko TYPE TABLE OF ekko WITH HEADER LINE,
          gt_ekpo TYPE TABLE OF ekpo WITH HEADER LINE,
          gt_ekkn TYPE TABLE OF ekkn WITH HEADER LINE,
          gt_eket TYPE TABLE OF eket WITH HEADER LINE.
    DATA : lt_ebkn    TYPE STANDARD TABLE OF ty_ebkn.


    CLEAR: gr_bedat[].
    CONCATENATE lv_gjahr '0101' INTO gr_bedat-low.
    gr_bedat-high = sy-datum.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = gr_bedat-high
      IMPORTING
        last_day_of_month = gr_bedat-high.
    gr_bedat-sign = 'I'.
    gr_bedat-option = 'BT'.
    APPEND gr_bedat. CLEAR gr_bedat.

    SELECT a~banfn a~bnfpo a~werks a~bedat a~ebeln a~ebelp
           b~zebkn b~sakto b~kostl b~netwr
      INTO CORRESPONDING FIELDS OF TABLE gt_ebkn
      FROM eban AS a JOIN ebkn AS b ON a~banfn = b~banfn AND
                                       a~bnfpo = b~bnfpo
      WHERE bedat IN gr_bedat
        AND kostl EQ lv_kostl
        AND sakto EQ lv_kstar.

    lt_ebkn[] = gt_ebkn[].
    DELETE lt_ebkn WHERE kostl IS INITIAL.

    IF lt_ebkn[] IS NOT INITIAL.
      SELECT ebeln bedat waers
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE gt_ekko
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp netwr netpr peinh txz01
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp etenr menge wemng
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE gt_eket
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp zekkn sakto gsber kostl
        FROM ekkn
        INTO CORRESPONDING FIELDS OF TABLE gt_ekkn
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln
          AND kostl EQ lv_kostl
          AND sakto EQ lv_kstar.

* Filter PO
      SORT: gt_ekpo BY ebeln ebelp,
            gt_eket BY ebeln ebelp,
            gt_ekkn BY ebeln ebelp.

      LOOP AT gt_ekpo.
        READ TABLE gt_ekkn WITH KEY ebeln = gt_ekpo-ebeln
                                    ebelp = gt_ekpo-ebelp
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
        ELSE.
          DELETE gt_ekpo.
        ENDIF.
      ENDLOOP.

      LOOP AT gt_eket.
        READ TABLE gt_ekkn WITH KEY ebeln = gt_eket-ebeln
                                    ebelp = gt_eket-ebelp
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
        ELSE.
          DELETE gt_eket.
        ENDIF.
      ENDLOOP.
    ENDIF.
    LOOP AT gt_ekpo.
      lv_commitment = lv_commitment + gt_ekpo-netwr.
    ENDLOOP.
    WRITE lv_commitment TO commitment NO-GROUPING NO-SIGN NO-GAP CURRENCY 'IDR'.
    lv_saldo = lv_budget - lv_actual - lv_commitment.
    WRITE lv_saldo TO saldo_budget NO-GROUPING NO-SIGN NO-GAP CURRENCY 'IDR'.
    CONDENSE: saldo_budget, commitment, actual, budget.
    status = 'S'.
  ELSE.
    status = 'E'.
    message = 'Data Budget tidak ditemukan'.
    CLEAR: saldo_budget, commitment, actual, budget.
  ENDIF.
ENDFUNCTION.
