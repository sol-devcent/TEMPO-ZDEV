FUNCTION zs_buying_versi_sac7_v1.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_FINAL) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(GV_RESULT) TYPE  FLAG
*"  TABLES
*"      I_VBRP STRUCTURE  ZVBRP OPTIONAL
*"      I_DSALES STRUCTURE  ZDSALES OPTIONAL
*"      TA_DETAIL STRUCTURE  ZBUYSAC7 OPTIONAL
*"      R_NONCON STRUCTURE  BAPIDLV_RANGE_KUNNR OPTIONAL
*"      I_EORD STRUCTURE  ZEORD OPTIONAL
*"      LT_EORD STRUCTURE  ZEORD OPTIONAL
*"      LT_MARA STRUCTURE  ZMARA1 OPTIONAL
*"      GT_KNA1 STRUCTURE  ZKNA1 OPTIONAL
*"      GT_MVKE STRUCTURE  ZMVKE1 OPTIONAL
*"----------------------------------------------------------------------
  DATA : lv_ktgrm   TYPE ktgrm.

  DATA : wa_vbrp   LIKE zvbrp,
         wa_eord   LIKE zeord,
         wa_kna1   LIKE zkna1,
         wa_mvke   LIKE zmvke1,
         wa_price  LIKE zsbuying_sac7_price,
         wa_dsales LIKE zdsales.

  DATA : tmp_kwert0 LIKE konv-kwert,
         tmp_kbetr1 LIKE konv-kwert,
         tmp_kbetr2 LIKE konv-kwert,
         tmp_kbetr3 LIKE konv-kwert,
         tmp_kbetr4 LIKE konv-kwert,
         tmp_kbetr5 LIKE konv-kwert,
         tmp_kbetr6 LIKE konv-kwert,
         tmp_kbetr7 LIKE konv-kwert,
         tmp_kbetr8 LIKE konv-kwert.

  DATA: tmp_kbetr1t LIKE konv-kwert,
        tmp_kbetr2t LIKE konv-kwert,
        tmp_kbetr3t LIKE konv-kwert,
        tmp_kbetr4t LIKE konv-kwert,
        tmp_kbetr7t LIKE konv-kwert,
        tmp_kbetr8t LIKE konv-kwert.

  DATA : tmp_disd_dc LIKE zsl_dsales-disd.

  DATA : BEGIN OF gt_likp OCCURS 0,
           vbeln     TYPE vbeln_vl,
           wadat_ist TYPE wadat_ist,
         END OF gt_likp.

*  DATA : BEGIN OF gt_konv OCCURS 0,
*           knumv  TYPE knumv,
*           kposn  TYPE kposn,
*           stunr  TYPE stunr,
*           kschl  TYPE kscha,
*           kwert  TYPE kwert,
*         END OF gt_konv.

  DATA : gt_price LIKE zsbuying_sac7_price OCCURS 0.

  DATA : lt_do      TYPE TABLE OF tvarvc,
         lt_cn      TYPE TABLE OF tvarvc,
         lr_fkartdo TYPE RANGE OF fkart,
         lr_fkartcn TYPE RANGE OF fkart,
         ls_fkart   LIKE LINE OF lr_fkartdo,
         ls_do      LIKE LINE OF lt_do,
         ls_cn      LIKE LINE OF lt_cn.

  SELECT *
    FROM tvarvc
    INTO CORRESPONDING FIELDS OF TABLE lt_do
    WHERE name  = 'ZSAC7_BILLTYPE_DO'.

  LOOP AT lt_do INTO ls_do.
    ls_fkart-low  = ls_do-low.
    ls_fkart-sign = ls_do-sign.
    ls_fkart-option = ls_do-opti.
*    SEARCH ls_do-low FOR '*'.
*    IF sy-subrc = 0.
*      ls_fkart-option = 'CS'.
*    ELSE.
*      ls_fkart-option = 'EQ'.
*    ENDIF.
    APPEND ls_fkart TO lr_fkartdo.
  ENDLOOP.

  SELECT *
    FROM tvarvc
    INTO CORRESPONDING FIELDS OF TABLE lt_cn
    WHERE name  = 'ZSAC7_BILLTYPE_CN'.

  LOOP AT lt_cn INTO ls_cn.
    ls_fkart-low  = ls_cn-low.
    ls_fkart-sign = ls_cn-sign.
    ls_fkart-option = ls_cn-opti.
*    SEARCH ls_cn-low FOR '*'.
*    IF sy-subrc = 0.
*      ls_fkart-option = 'CS'.
*    ELSE.
*      ls_fkart-option = 'EQ'.
*    ENDIF.
    APPEND ls_fkart TO lr_fkartcn.
  ENDLOOP.

  IF i_vbrp[] IS NOT INITIAL.
** Check customer consol
    DELETE i_vbrp[] WHERE kunrg IN r_noncon.
    PERFORM f_likp TABLES i_vbrp
                          gt_likp.

    PERFORM f_konv TABLES   i_vbrp
                            gt_price.

    SORT gt_price BY knumv kposn.
* Because we loop 2 big internal table, for better performance  we must using paralel cursor technique
* Note by MKO : If posible, avoid loop  then use read table binary search,
*               because it is more faster compare to loop, even paralel cursor
    DATA : lv_tabix   TYPE i.
    SORT i_vbrp BY knumv posnr.
    lv_tabix  = 1.     " Set the starting index 1

    LOOP AT i_vbrp INTO wa_vbrp.

      CLEAR wa_eord.
      READ TABLE i_eord INTO wa_eord
                        WITH KEY matnr = wa_vbrp-matnr
                        BINARY SEARCH.
      IF sy-subrc NE 0.
        READ TABLE lt_eord INTO wa_eord
                           WITH KEY matnr = wa_vbrp-matnr
                                    werks = wa_vbrp-werks
                           BINARY SEARCH.
      ENDIF.
      ta_detail-lifnr = wa_eord-lifnr.

*****      READ TABLE lt_mara WITH KEY matnr = wa_vbrp-matnr
*****                         BINARY SEARCH.
*****      IF sy-subrc EQ 0.
*****        wa_vbrp-extwg = lt_mara-extwg.
*****        wa_vbrp-prdha = lt_mara-prdha.
*****      ENDIF.

* clear
      CLEAR : tmp_kwert0, tmp_kbetr1, tmp_kbetr2, tmp_kbetr3, tmp_kbetr4,
      tmp_kbetr5, tmp_kbetr6.

* mapping
*      IF wa_vbrp-fkart+0(3) = 'ZBT' OR wa_vbrp-fkart+0(3) = 'ZIV' OR
*      wa_vbrp-fkart+0(4) = 'ZIGS' OR wa_vbrp-fkart+0(3) = 'ZCS' OR
*      wa_vbrp-fkart+0(3) = 'ZB2' OR wa_vbrp-fkart+0(3) = 'ZB4' OR
*      wa_vbrp-fkart+0(3) = 'ZB9'.
*        ta_detail-program = 'DO'.
*      ELSEIF wa_vbrp-fkart+0(3) = 'ZCO' OR wa_vbrp-fkart+0(3) = 'ZIG' OR
*      wa_vbrp-fkart+0(4) = 'ZIVS' OR wa_vbrp-fkart+0(3) = 'ZBS' OR
*      wa_vbrp-fkart+0(3) = 'ZC2' OR wa_vbrp-fkart+0(3) = 'ZC4' OR
*      wa_vbrp-fkart+0(3) = 'ZC9'.
*        ta_detail-program = 'CN'.
*      ENDIF.

      IF wa_vbrp-fkart IN lr_fkartdo.
        ta_detail-program = 'DO'.
      ELSEIF wa_vbrp-fkart IN lr_fkartcn.
        ta_detail-program = 'CN'.
      ENDIF.

      ta_detail-vbeln = wa_vbrp-vbeln.
      ta_detail-fkart = wa_vbrp-fkart.
      ta_detail-vbtyp = ' '.
      ta_detail-vkorg = wa_vbrp-vkorg.
      ta_detail-fkdat = wa_vbrp-fkdat.
      ta_detail-augru_auft = wa_vbrp-augru_auft.
      IF ta_detail-augru_auft IS INITIAL .
        ta_detail-augru_auft = 'NON'.
      ENDIF.
      ta_detail-extwg = wa_vbrp-extwg.
      IF ta_detail-extwg(3) = 'SFF'.
        ta_detail-extwg(3) = 'TSP'.
      ENDIF.
      ta_detail-prdha = wa_vbrp-prdha.
      IF ta_detail-prdha(3) = 'SFF'.
        ta_detail-prdha(3) = 'TSP'.
      ENDIF.
      ta_detail-sal_off = wa_vbrp-werks.
      ta_detail-material_code = wa_vbrp-matnr.

***      READ TABLE gt_kna1 INTO wa_kna1
***                         WITH KEY kunnr = wa_vbrp-kunrg
***                                  vkorg = wa_vbrp-vkorg
***                                  vtweg = wa_vbrp-vtweg
***                                  spart = wa_vbrp-spart
***                         BINARY SEARCH.
***      IF sy-subrc = 0.
***        ta_detail-cgrp = wa_kna1-kdgrp.
***        ta_detail-industri = wa_kna1-brsch.
***        ta_detail-search = wa_kna1-sortl.
***        ta_detail-customer = wa_vbrp-kunrg.
***        ta_detail-cust_name = wa_kna1-name1.
***        CONCATENATE wa_kna1-name2 wa_kna1-name3 wa_kna1-name4 INTO ta_detail-address SEPARATED
***                                                   BY space.
***      ENDIF.

      ta_detail-cgrp = wa_vbrp-kdgrp.
      ta_detail-industri = wa_vbrp-brsch.
      ta_detail-search = wa_vbrp-sortl.
      ta_detail-customer = wa_vbrp-kunrg.
      ta_detail-cust_name = wa_vbrp-name1.
      CONCATENATE wa_vbrp-name2 wa_vbrp-name3 wa_vbrp-name4 INTO ta_detail-address SEPARATED
                                                 BY space.


**      READ TABLE lt_mara WITH KEY matnr = wa_vbrp-matnr
**                         BINARY SEARCH.
**      IF sy-subrc EQ 0.
      ta_detail-mat_descrp = wa_vbrp-maktx.
**      ELSE.
**        CLEAR ta_detail-mat_descrp.
**      ENDIF.

*{   REPLACE        P01K910011                                        1
*\      READ TABLE gt_likp WITH KEY vbeln = wa_vbrp-vgbel
*\                         BINARY SEARCH.
      "Start GD: SOH: SCI Adj RZL ZS_BUYING_VERSI_SAC7_V1
      SORT gt_likp BY vbeln.
      READ TABLE gt_likp WITH KEY vbeln = wa_vbrp-vgbel
                         BINARY SEARCH.
      "End GD: SOH: SCI Adj RZL ZS_BUYING_VERSI_SAC7_V1
*}   REPLACE
      IF sy-subrc EQ 0.
        ta_detail-do_date = gt_likp-wadat_ist.
      ELSE.
        CLEAR ta_detail-do_date.
      ENDIF.

      ta_detail-do_number = wa_vbrp-vgbel.

      IF ta_detail-program = 'CN'.
*        wa_vbrp-fkimg = wa_vbrp-fkimg * -1.
        wa_vbrp-fklmg = wa_vbrp-fklmg * -1.
      ENDIF.

*      WRITE wa_vbrp-fkimg TO ta_detail-qty NO-GROUPING.  " unit wa_vbrp-vrkme.
      WRITE wa_vbrp-fklmg TO ta_detail-qty NO-GROUPING.  " unit wa_vbrp-vrkme.
      PERFORM format_minus1 USING ta_detail-qty.

**      CLEAR: lv_ktgrm.
**      READ TABLE gt_mvke INTO wa_mvke
**                         WITH KEY matnr = wa_vbrp-matnr
**                                  vkorg = wa_vbrp-vkorg
**                         BINARY SEARCH.
**      IF sy-subrc EQ 0.
**        lv_ktgrm = wa_mvke-ktgrm.
**      ENDIF.

      CLEAR : tmp_kbetr1, tmp_kbetr1t.
      CLEAR : tmp_kbetr2, tmp_kbetr2t.
      CLEAR : tmp_kbetr3, tmp_kbetr3t.
      CLEAR : tmp_kbetr4, tmp_kbetr4t.
      CLEAR : tmp_kbetr5.
      CLEAR : tmp_kbetr6.
      CLEAR : tmp_kbetr7, tmp_kbetr7t.
      CLEAR : tmp_kbetr8, tmp_kbetr8t.
*----------------------------------------------------------------*
*   Using Paralel Cursor
*----------------------------------------------------------------*
*      LOOP AT gt_price into wa_price FROM lv_tabix.
**   Save index & Exit the loop, if the keys are not same
*        IF not ( wa_price-knumv = wa_vbrp-knumv and wa_price-kposn = wa_vbrp-posnr ).
*           lv_tabix = sy-tabix.
*           EXIT.
*        ELSE.
*           tmp_kwert0 = ABS( wa_price-nsp ).
*           ADD wa_price-disca TO tmp_kbetr1.
*           ADD wa_price-discb TO tmp_kbetr2t.
*           ADD wa_price-discd TO tmp_kbetr3t.
*           IF ta_detail-extwg(3) = 'TSP' OR
*              ta_detail-extwg(3) = 'BCL' OR
*              ta_detail-extwg(3) = 'ERV'.
** Hanya untuk Principal Internal (TSP,BCL,ERV,GEM) ada tambahan kolom F3 saat Download
*              ADD wa_price-discf3 TO tmp_kbetr7t.
*           ELSE.
*             ADD wa_price-discf3 TO tmp_kbetr4t.
*           ENDIF.
*           ADD wa_price-discf TO tmp_kbetr4t.
*           ADD wa_price-discc TO tmp_kbetr5.
*           ADD wa_price-disce TO tmp_kbetr6.
*           CASE lv_ktgrm.
*             WHEN 'A1' OR 'A3'.
*               IF ta_detail-extwg(3) = 'TSP' OR
*                  ta_detail-extwg(3) = 'BCL' OR
*                  ta_detail-extwg(3) = 'ERV'.
*                  ADD wa_price-discv TO tmp_kbetr8t.
*               ENDIF.
*          ENDCASE.
*        ENDIF.
*      ENDLOOP.

*----------------------------------------------------------------*
* Using Binary Search
*----------------------------------------------------------------*
      CLEAR wa_price.
      READ TABLE gt_price INTO wa_price
                         WITH KEY knumv = wa_vbrp-knumv
                                  kposn = wa_vbrp-posnr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        tmp_kwert0 = abs( wa_price-nsp ).

        ADD wa_price-disca TO tmp_kbetr1.
        ADD wa_price-discb TO tmp_kbetr2t.
        ADD wa_price-discd TO tmp_kbetr3t.
*For Disc F3
        IF ta_detail-extwg(3) = 'TSP' OR
          ta_detail-extwg(3) = 'BCL' OR
          ta_detail-extwg(3) = 'ERV'.
* Hanya untuk Principal Internal (TSP,BCL,ERV,GEM) ada tambahan kolom F3 saat Download
          ADD wa_price-discf3 TO tmp_kbetr7t.
        ELSE.
          ADD wa_price-discf3 TO tmp_kbetr4t.
        ENDIF.
        ADD wa_price-discf TO tmp_kbetr4t.
        ADD wa_price-discc TO tmp_kbetr5.
        ADD wa_price-disce TO tmp_kbetr6.
        CASE wa_vbrp-ktgrm.
          WHEN 'A1' OR 'A3'.
            IF ta_detail-extwg(3) = 'TSP' OR
              ta_detail-extwg(3) = 'BCL' OR
              ta_detail-extwg(3) = 'ERV'.
              ADD wa_price-discv TO tmp_kbetr8t.
            ENDIF.
        ENDCASE.
      ENDIF.
*----------------------------------------------------------------*

*** NSP
*      SELECT SINGLE kwert INTO tmp_kwert1
*        FROM konv WHERE knumv = wa_vbrp-knumv
*                    AND kposn = wa_vbrp-posnr
*                    AND kschl = 'ZRPT'
*                    AND kwert NE 0.
*
*      SELECT SINGLE kwert INTO tmp_kwert0
*        FROM konv WHERE knumv = wa_vbrp-knumv
*                    AND kposn = wa_vbrp-posnr
*                    AND kschl = 'ZN01'
*                    AND kwert NE 0.
*      IF sy-subrc = 0.
*        tmp_kwert0 = tmp_kwert0 + tmp_kwert1.
*      ELSE.
*        SELECT SINGLE kwert INTO tmp_kwert0
*          FROM konv WHERE knumv = wa_vbrp-knumv
*                      AND kposn = wa_vbrp-posnr
*                      AND kschl = 'ZN02'
*                      AND kwert NE 0.
*        IF sy-subrc = 0.
*          tmp_kwert0 = tmp_kwert0 + tmp_kwert1.
*        ENDIF.
*      ENDIF.
*
*      IF sy-subrc = 0.
*        tmp_kwert0 = ABS( tmp_kwert0 ).

      IF ta_detail-program = 'CN'.
        tmp_kwert0 = tmp_kwert0 * -1.
      ENDIF.
      WRITE tmp_kwert0 TO ta_detail-gross CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-gross.
*      ENDIF.

*** DISCOUNT A
      IF tmp_kbetr1 IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr1 = tmp_kbetr1 * -1.
        ENDIF.
      ENDIF.
      WRITE tmp_kbetr1 TO ta_detail-dis_a CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_a.

*** DISCOUNT B
      IF tmp_kbetr2t IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr2t = tmp_kbetr2t * -1.
        ENDIF.
        ADD tmp_kbetr2t TO tmp_kbetr2.
      ENDIF.
      WRITE tmp_kbetr2 TO ta_detail-dis_b CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_b.

*** DISCOUNT D
      IF tmp_kbetr3t IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr3t = tmp_kbetr3t * -1.
        ENDIF.
        ADD tmp_kbetr3t TO tmp_kbetr3.
      ENDIF.
      WRITE tmp_kbetr3 TO ta_detail-dis_d CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_d.

*** DISCOUNT F
      IF tmp_kbetr4t IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr4t = tmp_kbetr4t * -1.
        ENDIF.
        ADD tmp_kbetr4t TO tmp_kbetr4.
      ENDIF.
      WRITE tmp_kbetr4 TO ta_detail-dis_f CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_f.

*** DISCOUNT C
      IF tmp_kbetr5 IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr5 = tmp_kbetr5 * -1.
        ENDIF.
      ENDIF.
      WRITE tmp_kbetr5 TO ta_detail-dis_c CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_c.

*** DISCOUNT E
      IF tmp_kbetr6 IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr6 = tmp_kbetr6 * -1.
        ENDIF.
      ENDIF.
      WRITE tmp_kbetr6 TO ta_detail-dis_e CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_e.

*** DISCOUNT F3
      IF tmp_kbetr7t IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr7t = tmp_kbetr7t * -1.
        ENDIF.
        ADD tmp_kbetr7t TO tmp_kbetr7.
      ENDIF.
      WRITE tmp_kbetr7 TO ta_detail-dis_f3 CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_f3.

*** DISCOUNT VOL
      IF tmp_kbetr8t IS NOT INITIAL.
        IF ta_detail-program = 'DO'.
          tmp_kbetr8t = tmp_kbetr8t * -1.
        ENDIF.
        ADD tmp_kbetr8t TO tmp_kbetr8.
      ENDIF.
      WRITE tmp_kbetr8 TO ta_detail-dis_vol CURRENCY 'IDR' NO-GROUPING.
      PERFORM format_minus USING ta_detail-dis_vol.

      IF ta_detail-dis_a IS INITIAL OR ta_detail-dis_a = space.
        ta_detail-dis_a = 0.
      ENDIF.
      IF ta_detail-dis_b IS INITIAL OR ta_detail-dis_b = space.
        ta_detail-dis_b = 0.
      ENDIF.
      IF ta_detail-dis_c IS INITIAL OR ta_detail-dis_c = space.
        ta_detail-dis_c = 0.
      ENDIF.
      IF ta_detail-dis_d IS INITIAL OR ta_detail-dis_d = space.
        ta_detail-dis_d = 0.
      ENDIF.
      IF ta_detail-dis_e IS INITIAL OR ta_detail-dis_e = space.
        ta_detail-dis_e = 0.
      ENDIF.
      IF ta_detail-dis_f IS INITIAL OR ta_detail-dis_f = space.
        ta_detail-dis_f = 0.
      ENDIF.
      IF ta_detail-dis_f3 IS INITIAL OR ta_detail-dis_f3 = space.
        ta_detail-dis_f3 = 0.
      ENDIF.
      IF ta_detail-dis_vol IS INITIAL OR ta_detail-dis_vol = space.
        ta_detail-dis_vol = 0.
      ENDIF.

      ta_detail-final = p_final.

      APPEND ta_detail. CLEAR ta_detail.
    ENDLOOP.
  ENDIF.

*******
*******  IF i_dsales[] IS NOT INITIAL.
******** Check customer consol
*******    DELETE i_dsales[] WHERE kunnr IN r_noncon.
*******    LOOP AT i_dsales INTO wa_dsales.
*******      CLEAR: lv_ktgrm.
*******      READ TABLE gt_mvke INTO wa_mvke
*******                         WITH KEY matnr = wa_dsales-matnr
*******                                  vkorg = wa_dsales-vkorg
*******                         BINARY SEARCH.
*******      IF sy-subrc EQ 0.
*******        lv_ktgrm  = wa_mvke-ktgrm.
*******      ENDIF.
*******
*******      CLEAR wa_eord.
*******      READ TABLE i_eord INTO wa_eord
*******                        WITH KEY matnr = wa_dsales-matnr
*******                        BINARY SEARCH.
*******      IF sy-subrc NE 0.
*******        READ TABLE lt_eord INTO wa_eord
*******                           WITH KEY matnr = wa_dsales-matnr
*******                                    werks = wa_dsales-plant
*******                           BINARY SEARCH.
*******      ENDIF.
*******      ta_detail-lifnr = wa_eord-lifnr.
*******
*******      READ TABLE lt_mara WITH KEY matnr = wa_dsales-matnr
*******                         BINARY SEARCH.
*******      IF sy-subrc EQ 0.
*******        wa_dsales-extwg = lt_mara-extwg.
*******        wa_dsales-prdha = lt_mara-prdha.
*******      ENDIF.
*******
*******      ta_detail-extwg = wa_dsales-extwg .
*******      IF ta_detail-extwg(3) = 'SFF'.
*******        ta_detail-extwg(3) = 'TSP'.
*******      ENDIF.
*******      ta_detail-prdha = wa_dsales-prdha.
*******      IF ta_detail-prdha(3) = 'SFF'.
*******        ta_detail-prdha(3) = 'TSP'.
*******      ENDIF.
*******
******* clear
*******      CLEAR : tmp_disd_dc.
*******
******* mapping
*******      IF wa_dsales-vbtyp ='M'.
*******        ta_detail-program = 'DO'.
*******      ELSE.
*******        ta_detail-program = 'CN'.
*******      ENDIF.
*******
*******      ta_detail-vbeln = wa_dsales-vbeln.
*******      ta_detail-fkart = wa_dsales-fkart.
*******      ta_detail-vbtyp = wa_dsales-vbtyp.
*******      ta_detail-vkorg = wa_dsales-vkorg.
*******      ta_detail-fkdat = wa_dsales-bldat.
*******
*******      ta_detail-sal_off = wa_dsales-vkbur.
*******
*******      READ TABLE gt_kna1 INTO wa_kna1
*******                         WITH KEY kunnr = wa_dsales-kunnr
*******                                  vkorg = wa_dsales-vkorg
*******                         BINARY SEARCH.
*******      IF sy-subrc = 0.
*******        ta_detail-cgrp = wa_kna1-kdgrp.
*******        ta_detail-industri = wa_kna1-brsch.
*******        ta_detail-search = wa_kna1-sortl.
*******        ta_detail-customer = wa_dsales-kunnr.
*******        ta_detail-cust_name = wa_kna1-name1.
*******        CONCATENATE wa_kna1-name2 wa_kna1-name3 INTO ta_detail-address SEPARATED
*******                                                   BY space.
*******      ENDIF.
*******
*******      ta_detail-material_code = wa_dsales-matnr.
*******
*******      READ TABLE lt_mara WITH KEY matnr = wa_dsales-matnr
*******                         BINARY SEARCH.
*******      IF sy-subrc EQ 0.
*******        ta_detail-mat_descrp = lt_mara-maktx.
*******      ELSE.
*******        CLEAR ta_detail-mat_descrp.
*******      ENDIF.
*******
*******      ta_detail-do_date  = wa_dsales-bldat.
*******      ta_detail-do_number = wa_dsales-vbeln.
*******
*******      IF ta_detail-program = 'DO'.
*******        wa_dsales-nsp = wa_dsales-nsp.                      "* -1.
*******        wa_dsales-fkimg = wa_dsales-fkimg.                  "* -1.
*******        wa_dsales-disa = wa_dsales-disa * -1.
*******        wa_dsales-disb = wa_dsales-disb * -1.
*******
*******        IF lv_ktgrm EQ 'A1' OR lv_ktgrm EQ 'A2'.
*******          IF wa_dsales-disd IS NOT INITIAL.
*******            IF ta_detail-extwg(3) = 'TSP' OR ta_detail-extwg(3) = 'BCL' OR
*******               ta_detail-extwg(3) = 'ERV'." OR ta_detail-extwg(3) = 'GEM'.
*******              wa_dsales-disf3 = wa_dsales-disd * -1.
*******              CLEAR: wa_dsales-disd.
*******            ELSEIF ta_detail-extwg(3) = 'BHR'.
*******              wa_dsales-disf = wa_dsales-disf + wa_dsales-disd.
*******              CLEAR: wa_dsales-disd.
*******            ELSE.
*******              wa_dsales-disd = wa_dsales-disd * -1.
*******            ENDIF.
*******          ENDIF.
*******        ELSE.
*******          wa_dsales-disd = wa_dsales-disd * -1.
*******        ENDIF.
*******
*******        wa_dsales-disdc = wa_dsales-disdc * -1.
*******        wa_dsales-disf = wa_dsales-disf * -1.
*******        wa_dsales-disc = wa_dsales-disc * -1.
*******        wa_dsales-dise = wa_dsales-dise * -1.
*******        wa_dsales-disvol = wa_dsales-disvol * -1.
*******      ELSE.
*******        wa_dsales-nsp = wa_dsales-nsp * -1.
*******        wa_dsales-fkimg = wa_dsales-fkimg * -1.
*******        IF lv_ktgrm EQ 'A1' OR lv_ktgrm EQ 'A2'.
*******          IF wa_dsales-disd IS NOT INITIAL.
*******            IF ta_detail-extwg(3) = 'TSP' OR ta_detail-extwg(3) = 'BCL' OR
*******               ta_detail-extwg(3) = 'ERV'." OR ta_detail-extwg(3) = 'GEM'.
*******              wa_dsales-disf3 = wa_dsales-disd + wa_dsales-dissp.
*******              CLEAR: wa_dsales-disd.
*******            ELSEIF ta_detail-extwg(3) = 'BHR'.
*******              wa_dsales-disf = wa_dsales-disf + wa_dsales-disd + wa_dsales-dissp.
*******              CLEAR: wa_dsales-disd.
*******            ELSE.
*******              wa_dsales-disd = wa_dsales-disd + wa_dsales-dissp.
*******            ENDIF.
*******          ENDIF.
*******        ELSE.
*******          wa_dsales-disd = wa_dsales-disd + wa_dsales-dissp.
*******        ENDIF.
*******      ENDIF.
*******
*******      PERFORM f_write USING wa_dsales-nsp '0'
*******                      CHANGING ta_detail-gross.
*******
*******      PERFORM f_write USING wa_dsales-fkimg '1'
*******                      CHANGING ta_detail-qty.
*******
*******      PERFORM f_write USING wa_dsales-disa '0'
*******                      CHANGING ta_detail-dis_a.
*******
*******      PERFORM f_write USING wa_dsales-disb '0'
*******                      CHANGING ta_detail-dis_b.
*******
*******      tmp_disd_dc = wa_dsales-disd + wa_dsales-disdc.
*******
*******      PERFORM f_write USING tmp_disd_dc '0'
*******                      CHANGING ta_detail-dis_d.
*******
*******      PERFORM f_write USING wa_dsales-disf '0'
*******                      CHANGING ta_detail-dis_f.
*******
*******      PERFORM f_write USING wa_dsales-disc '0'
*******                      CHANGING ta_detail-dis_c.
*******
*******      PERFORM f_write USING wa_dsales-dise '0'
*******                      CHANGING ta_detail-dis_e.
*******
*******      PERFORM f_write USING wa_dsales-disf3 '0'
*******                      CHANGING ta_detail-dis_f3.
*******
*******      IF ( lv_ktgrm = 'A1' OR lv_ktgrm = 'A3' ) AND
*******         ( ta_detail-extwg(3) = 'TSP' OR ta_detail-extwg(3) = 'BCL' OR
*******           ta_detail-extwg(3) = 'ERV' ).
*******        PERFORM f_write USING wa_dsales-disvol '0'
*******                        CHANGING ta_detail-dis_vol.
*******      ENDIF.
*******
*******      IF ta_detail-dis_a IS INITIAL OR ta_detail-dis_a = space.
*******        ta_detail-dis_a = 0.
*******      ENDIF.
*******      IF ta_detail-dis_b IS INITIAL OR ta_detail-dis_b = space.
*******        ta_detail-dis_b = 0.
*******      ENDIF.
*******      IF ta_detail-dis_c IS INITIAL OR ta_detail-dis_c = space.
*******        ta_detail-dis_c = 0.
*******      ENDIF.
*******      IF ta_detail-dis_d IS INITIAL OR ta_detail-dis_d = space.
*******        ta_detail-dis_d = 0.
*******      ENDIF.
*******      IF ta_detail-dis_e IS INITIAL OR ta_detail-dis_e = space.
*******        ta_detail-dis_e = 0.
*******      ENDIF.
*******      IF ta_detail-dis_f IS INITIAL OR ta_detail-dis_f = space.
*******        ta_detail-dis_f = 0.
*******      ENDIF.
*******      IF ta_detail-dis_f3 IS INITIAL OR ta_detail-dis_f3 = space.
*******        ta_detail-dis_f3 = 0.
*******      ENDIF.
*******      IF ta_detail-dis_vol IS INITIAL OR ta_detail-dis_vol = space.
*******        ta_detail-dis_vol = 0.
*******      ENDIF.
*******
*******      ta_detail-final = p_final.
*******
*******      APPEND ta_detail. CLEAR ta_detail.
*******    ENDLOOP.
*******  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  format_minus
*&---------------------------------------------------------------------*
FORM format_minus  USING    p_amount.
  IF p_amount+24(1) = '-'.
    SHIFT p_amount RIGHT DELETING TRAILING '-'.
    SHIFT p_amount LEFT DELETING LEADING space.
    CONCATENATE '-' p_amount INTO p_amount.
    CONDENSE p_amount.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ELSE.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ENDIF.
ENDFORM.                    " FORMAT_MINUS

*&---------------------------------------------------------------------*
*&      Form  format_minus1
*&---------------------------------------------------------------------*
FORM format_minus1 USING    p_amount.
  IF p_amount+19(1) = '-'.
    SHIFT p_amount RIGHT DELETING TRAILING '-'.
    SHIFT p_amount LEFT DELETING LEADING space.
    CONCATENATE '-' p_amount INTO p_amount.
    CONDENSE p_amount.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ENDIF.
ENDFORM.                    " format_minus

*&---------------------------------------------------------------------*
*&      Form  F_WRITE
*&---------------------------------------------------------------------*
FORM f_write  USING    fu_value fu_flag
              CHANGING fc_value.

  CASE fu_flag.
    WHEN '0'.
      WRITE fu_value TO fc_value DECIMALS 0
                                 NO-GROUPING
                                 CURRENCY 'IDR'.
      IF fc_value+24(1) = '-'.
        SHIFT fc_value RIGHT DELETING TRAILING '-'.
        SHIFT fc_value LEFT DELETING LEADING space.
        CONCATENATE '-' fc_value INTO fc_value.
        CONDENSE fc_value.
        SHIFT fc_value RIGHT DELETING TRAILING space.
      ELSE.
        SHIFT fc_value RIGHT DELETING TRAILING space.
      ENDIF.

    WHEN '1'.
      WRITE fu_value TO fc_value NO-GROUPING.
      IF fc_value+19(1) = '-'.
        SHIFT fc_value RIGHT DELETING TRAILING '-'.
        SHIFT fc_value LEFT DELETING LEADING space.
        CONCATENATE '-' fc_value INTO fc_value.
        CONDENSE fc_value.
        SHIFT fc_value RIGHT DELETING TRAILING space.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_WRITE

*&---------------------------------------------------------------------*
*&      Form  F_LIKP
*&---------------------------------------------------------------------*
FORM f_likp  TABLES   ft_vbrp STRUCTURE zvbrp
                      ft_likp STRUCTURE zlikp.

  DATA : lt_vbrp  LIKE zvbrp OCCURS 0 WITH HEADER LINE.

  lt_vbrp[] = ft_vbrp[].
  SORT lt_vbrp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vgbel.
  IF lt_vbrp[] IS NOT INITIAL.
*{   REPLACE        P01K910011                                        1
*\    SELECT vbeln wadat_ist
*\      FROM likp
*\      INTO TABLE ft_likp
*\      FOR ALL ENTRIES IN lt_vbrp
*\      WHERE vbeln = lt_vbrp-vgbel.
    "Start GD: SOH: SCI Adj RZL ZS_BUYING_VERSI_SAC7_V1
    SELECT vbeln wadat_ist
      FROM likp
      INTO TABLE ft_likp
      FOR ALL ENTRIES IN lt_vbrp
      WHERE vbeln = lt_vbrp-vgbel ORDER BY PRIMARY KEY.
    "End GD: SOH: SCI Adj RZL ZS_BUYING_VERSI_SAC7_V1
*}   REPLACE
  ENDIF.
ENDFORM.                    " F_LIKP

*&---------------------------------------------------------------------*
*&      Form  F_KONV
*&---------------------------------------------------------------------*
FORM f_konv  TABLES   ft_vbrp STRUCTURE zvbrp
                      ft_prc  STRUCTURE zsbuying_sac7_price.

  DATA : lt_vbrp LIKE zvbrp OCCURS 0 WITH HEADER LINE,
         lt_konv LIKE zkonv OCCURS 0 WITH HEADER LINE.

  DATA : lr_kschl TYPE RANGE OF kschl,
         lv_kschl LIKE LINE OF lr_kschl.

  CHECK ft_vbrp[] IS NOT INITIAL.
  lv_kschl-sign   = 'I'.
  lv_kschl-option = 'CP'.

  lv_kschl-low    = 'ZN*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZA*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZB*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZC*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZD*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZE*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZF*'.  APPEND lv_kschl TO lr_kschl.
  lv_kschl-option = 'EQ'.
  lv_kschl-low    = 'ZV01'. APPEND lv_kschl TO lr_kschl.
  lv_kschl-low    = 'ZRPT'. APPEND lv_kschl TO lr_kschl.

  "Exclude ZALC
  CLEAR lv_kschl.
  lv_kschl-sign   = 'E'.
  lv_kschl-option = 'EQ'.
  lv_kschl-low    = 'ZALC'.
  APPEND lv_kschl TO lr_kschl.

  lt_vbrp[] = ft_vbrp[].
  SORT lt_vbrp BY knumv posnr.
  DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING knumv posnr.

  SELECT knumv kposn stunr kschl kwert kinak
    FROM konv
    INTO TABLE lt_konv
    FOR ALL ENTRIES IN lt_vbrp
    WHERE knumv = lt_vbrp-knumv
      AND kposn = lt_vbrp-posnr
      AND kinak = space.

  LOOP AT lt_konv.
    IF NOT ( lt_konv-kschl IN lr_kschl ) OR lt_konv-kwert = 0.
      CONTINUE.
    ENDIF.

    IF lt_konv-kschl = 'ZN0C'.
      CONTINUE.
    ENDIF.

*    IF lt_konv-kinak <> 'A'.
*      CONTINUE.
*    ENDIF.

    CLEAR ft_prc.
    CASE lt_konv-kschl(2).
      WHEN 'ZN'. ft_prc-nsp   = lt_konv-kwert.
      WHEN 'ZA'. "ft_prc-disca  = lt_konv-kwert.
        IF lt_konv-kschl NE 'ZALC'.
          ft_prc-disca  = lt_konv-kwert.
        ENDIF.
      WHEN 'ZB'. ft_prc-discb  = lt_konv-kwert.
      WHEN 'ZC'. ft_prc-discc  = lt_konv-kwert.
      WHEN 'ZD'. ft_prc-discd  = lt_konv-kwert.
      WHEN 'ZE'. ft_prc-disce  = lt_konv-kwert.
      WHEN 'ZF'.
        IF lt_konv-kschl = 'ZF03'.
          ft_prc-discf3  = lt_konv-kwert.
        ELSE.
          ft_prc-discf  = lt_konv-kwert.
        ENDIF.
      WHEN 'ZV'. ft_prc-discv  = lt_konv-kwert.
      WHEN OTHERS.
        IF lt_konv-kschl = 'ZRPT'.
          ft_prc-nsp   = lt_konv-kwert.
        ENDIF.
    ENDCASE.
    ft_prc-knumv = lt_konv-knumv.
    ft_prc-kposn = lt_konv-kposn.
    COLLECT ft_prc.
  ENDLOOP.
ENDFORM.                    " F_KONV
