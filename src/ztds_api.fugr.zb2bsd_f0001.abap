FUNCTION zb2bsd_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PO_HEADER) TYPE  ZB2B_HKF
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"  TABLES
*"      T_POITEMS STRUCTURE  ZB2B_DKF OPTIONAL
*"----------------------------------------------------------------------
  TABLES: kna1, adrc.
  DATA: lv_message(100), lv_status.
  DATA: gs_zsh_b2b TYPE zsh_b2b.
  DATA: gt_zsd_b2b TYPE STANDARD TABLE OF  zsd_b2b WITH HEADER LINE.
  DATA: gs_zsd_b2b TYPE zsd_b2b.
  DATA: gt_zsuom_b2b TYPE STANDARD TABLE OF  zsuom_b2b WITH HEADER LINE.
  DATA: gs_zsuom_b2b TYPE zsuom_b2b.
  DATA: gt_zsmat_b2b TYPE STANDARD TABLE OF  zsmat_b2b WITH HEADER LINE.
  DATA: gs_zsmat_b2b TYPE zsmat_b2b.
  DATA: ls_kna1vv TYPE kna1vv.
  DATA: lv_adrnr LIKE adrc-addrnumber.
  DATA: lv_ctr TYPE i.
  CLEAR: lv_status, lv_message, message, status.
  gs_zsh_b2b-ebeln = po_header-po_no.
  SELECT SINGLE ebeln INTO gs_zsh_b2b-ebeln FROM zsh_b2b WHERE ebeln = gs_zsh_b2b-ebeln.
  IF sy-subrc EQ 0.
    CONCATENATE 'PO No :' po_header-po_no 'sudah ada di table SAP' INTO lv_message SEPARATED BY space.
    lv_status = 'E'.
  ELSE.
    gs_zsh_b2b-znob2b = po_header-po_no.
    gs_zsh_b2b-mjahr = sy-datum(4).
    gs_zsh_b2b-ebeln = po_header-po_no.
    gs_zsh_b2b-bedat = po_header-po_date.
    gs_zsh_b2b-bnddt = po_header-po_expired_date.
    gs_zsh_b2b-patner = po_header-outlet_id.
    gs_zsh_b2b-vkbur = po_header-branch_code.
    "  gs_zsh_b2b-top = '35'.
    gs_zsh_b2b-vkorg = '8020'.
    gs_zsh_b2b-fkdat = sy-datum.
    gs_zsh_b2b-ernam = sy-uname.
    gs_zsh_b2b-waers = 'IDR'.
    SELECT SINGLE addrnumber INTO lv_adrnr FROM adrc WHERE sort2 = gs_zsh_b2b-patner.
    IF sy-subrc EQ 0.
      SELECT SINGLE * INTO ls_kna1vv FROM kna1vv
        WHERE  vkorg = '8020' AND
               vtweg = '10' AND
               spart =  '00' AND
               adrnr  = lv_adrnr .
      IF sy-subrc EQ 0.
        gs_zsh_b2b-kunnr = ls_kna1vv-kunnr.
        gs_zsh_b2b-vkbur = ls_kna1vv-vkbur. "gs_zsh_b2b-vkbur.
      ELSE.
        CONCATENATE 'Patner Id :' gs_zsh_b2b-patner 'tidak ditemukan di sap' INTO lv_message SEPARATED BY space.
        lv_status = 'E'.
      ENDIF.
    ELSE.
      CONCATENATE 'Patner Id :' gs_zsh_b2b-patner 'tidak ditemukan di sap' INTO lv_message SEPARATED BY space.
      lv_status = 'E'.
    ENDIF.
    IF t_poitems[] IS NOT INITIAL.
      LOOP AT t_poitems.
        gs_zsd_b2b-znob2b = po_header-po_no.
        gs_zsd_b2b-material = t_poitems-product_id.
        gs_zsd_b2b-meins = t_poitems-uom.
        gs_zsd_b2b-menge = t_poitems-qty.
        gs_zsd_b2b-kzwi2 = t_poitems-disc.
        gs_zsd_b2b-kzwi1 = t_poitems-unit_price.
        gs_zsd_b2b-brtwr = t_poitems-total_price.
        APPEND gs_zsd_b2b TO gt_zsd_b2b.
      ENDLOOP.
      IF gt_zsd_b2b[] IS NOT INITIAL.
*{   REPLACE        P01K910013                                        1
*\        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsuom_b2b FROM zsuom_b2b
*\          FOR ALL ENTRIES IN gt_zsd_b2b
*\          WHERE zmatnr = gt_zsd_b2b-material AND
*\                kvgr4 = '291'." AND
*\        "bstme = gt_zsd_b2b-meins.
*\        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsmat_b2b FROM zsmat_b2b
*\        FOR ALL ENTRIES IN gt_zsd_b2b
*\        WHERE zmatnr = gt_zsd_b2b-material AND
*\              kvgr4 = '291'.
        "Start GD: SOH: SCI Adj RZL ZB2BSD_F0001
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsuom_b2b FROM zsuom_b2b
          FOR ALL ENTRIES IN gt_zsd_b2b
          WHERE zmatnr = gt_zsd_b2b-material AND
                kvgr4 = '291' ORDER BY PRIMARY KEY.
        "bstme = gt_zsd_b2b-meins.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsmat_b2b FROM zsmat_b2b
        FOR ALL ENTRIES IN gt_zsd_b2b
        WHERE zmatnr = gt_zsd_b2b-material AND
              kvgr4 = '291' ORDER BY PRIMARY KEY.
        "End GD: SOH: SCI Adj RZL ZB2BSD_F0001
*}   REPLACE
        IF gt_zsuom_b2b[] IS NOT INITIAL.
          LOOP AT gt_zsd_b2b INTO gs_zsd_b2b.
*{   REPLACE        P01K910013                                        2
*\            READ TABLE gt_zsuom_b2b INTO gs_zsuom_b2b
            "Start GD: SOH: SCI Adj RZL ZB2BSD_F0001
            SORT gt_zsuom_b2b by zmatnr bstme.
            READ TABLE gt_zsuom_b2b INTO gs_zsuom_b2b
            "End GD: SOH: SCI Adj RZL ZB2BSD_F0001
*}   REPLACE
            WITH KEY zmatnr = gs_zsd_b2b-material
                     bstme = gs_zsd_b2b-meins
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              gs_zsd_b2b-meins = gs_zsuom_b2b-vrkme.
            ELSE.
              CONCATENATE 'Material :' gs_zsd_b2b-material ' uom tidak ditemukan di sap' INTO lv_message SEPARATED BY space.
              lv_status = 'E'.
              EXIT.
            ENDIF.
*{   REPLACE        P01K910013                                        3
*\            READ TABLE gt_zsmat_b2b INTO gs_zsmat_b2b
            "Start GD: SOH: SCI Adj RZL ZB2BSD_F0001
            SORT gt_zsmat_b2b by zmatnr.
            READ TABLE gt_zsmat_b2b INTO gs_zsmat_b2b
            "End GD: SOH: SCI Adj RZL ZB2BSD_F0001
*}   REPLACE
            WITH KEY zmatnr = gs_zsd_b2b-material
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              gs_zsd_b2b-matnr = gs_zsmat_b2b-matnr.
            ELSE.
              CONCATENATE 'Material :' gs_zsd_b2b-material ' tidak ditemukan di sap' INTO lv_message SEPARATED BY space.
              lv_status = 'E'.
              EXIT.
            ENDIF.
            MODIFY gt_zsd_b2b FROM gs_zsd_b2b TRANSPORTING meins matnr.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lv_status = 'E'.
    message = lv_message.
    status = lv_status.
  ELSE.
    DATA: l_retcd(1).
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZSD_B2B'
      IMPORTING
        returncode  = l_retcd
        number      = gs_zsh_b2b-znob2b.

    CONCATENATE 'PO No :' po_header-po_no 'berhasil dicreate dengan no ' gs_zsh_b2b-znob2b INTO lv_message SEPARATED BY space.

    status = 'S'.
    message = lv_message.
    CLEAR: lv_ctr. "gs_zsd_b2b-EBELP.
    MODIFY zsh_b2b FROM gs_zsh_b2b.
    LOOP AT gt_zsd_b2b INTO gs_zsd_b2b.
      ADD 10 TO lv_ctr.
      gs_zsd_b2b-ebelp = lv_ctr.
      gs_zsd_b2b-znob2b = gs_zsh_b2b-znob2b.
      MODIFY zsd_b2b FROM gs_zsd_b2b.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
