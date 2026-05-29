*----------------------------------------------------------------------*
***INCLUDE ZS_BUYING_VERSI_SAC7_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_BILL_NONBILL
*&---------------------------------------------------------------------*
FORM f_proses_bill_nonbill .
  DATA lv_count TYPE int4.
  DATA lt_detail LIKE ta_detail OCCURS 0 WITH HEADER LINE.

  WRITE: / 'Start Proses data Bill_nonBill : ', sy-datum, sy-vline , sy-uzeit.

**  ta_detailbnb[] = ta_detail[].
**  SORT ta_detail BY vbeln material_code vkorg.
**  SORT ta_detailbnb BY vbeln material_code vkorg.
**  LOOP AT ta_detailbnb.
***    ta_detailbnb-dnqty = ta_detailbnb-qty.
***    ta_detailbnb-dnval = ta_detailbnb-gross.
**    WRITE ta_detailbnb-qty TO ta_detailbnb-dnqty NO-GROUPING.
**    WRITE ta_detailbnb-gross TO ta_detailbnb-dnval DECIMALS 0 NO-GROUPING.
**
**    WRITE ta_detailbnb-dnqty TO ta_detailbnb-dnqty RIGHT-JUSTIFIED.
**    WRITE ta_detailbnb-dnval TO ta_detailbnb-dnval RIGHT-JUSTIFIED.
**
**    CLEAR gt_kna1a.
**    READ TABLE gt_kna1a WITH KEY kunnr = ta_detailbnb-customer.
**    ta_detailbnb-city1 = gt_kna1a-city1.
**    ta_detailbnb-post_code1 = gt_kna1a-post_code1.
**
**    "  sort ta_detail by vbeln material_code vkorg.
***    READ TABLE ta_detail WITH KEY vbeln = ta_detailbnb-vbeln
***                                  material_code = ta_detailbnb-material_code
***                                  vkorg = ta_detailbnb-vkorg BINARY SEARCH.
***    IF sy-subrc = 0.
***      ta_detailbnb-augru_auft = ta_detail-augru_auft.
***    ENDIF.
**
**    ADD 1 TO lv_count.
**    DATA(lv_augru_auft) = ta_detail[ lv_count ]-augru_auft.
**    ta_detailbnb-augru_auft = lv_augru_auft.
**
**    IF ta_detailbnb-augru_auft IS INITIAL.
**      ta_detailbnb-augru_auft = 'NON'.
**    ENDIF.
**
**    MODIFY ta_detailbnb TRANSPORTING dnqty dnval city1 post_code1 augru_auft.
**  ENDLOOP.

  lt_detail[] = ta_detail[].
  SORT lt_detail BY customer.
  DELETE ADJACENT DUPLICATES FROM lt_detail COMPARING customer.

  IF lt_detail[] IS NOT INITIAL.
    SELECT kunnr vkorg vtweg spart
      b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1 b~post_code1
      FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1a
      FOR ALL ENTRIES IN lt_detail
      WHERE kunnr = lt_detail-customer.
  ENDIF.


**  ta_detailbnb[] = ta_detail[].
**  SORT ta_detail BY vbeln material_code vkorg.
**  SORT ta_detailbnb BY vbeln material_code vkorg.
  LOOP AT ta_detail.
    MOVE-CORRESPONDING ta_detail TO ta_detailbnb.
*    ta_detailbnb-dnqty = ta_detailbnb-qty.
*    ta_detailbnb-dnval = ta_detailbnb-gross.
    WRITE ta_detailbnb-qty TO ta_detailbnb-dnqty NO-GROUPING.
    WRITE ta_detailbnb-gross TO ta_detailbnb-dnval DECIMALS 0 NO-GROUPING.

    WRITE ta_detailbnb-dnqty TO ta_detailbnb-dnqty RIGHT-JUSTIFIED.
    WRITE ta_detailbnb-dnval TO ta_detailbnb-dnval RIGHT-JUSTIFIED.

    CLEAR gt_kna1a.
    READ TABLE gt_kna1a WITH KEY kunnr = ta_detailbnb-customer.
    ta_detailbnb-city1 = gt_kna1a-city1.
    ta_detailbnb-post_code1 = gt_kna1a-post_code1.

    "    ADD 1 TO lv_count.
    "    DATA(lv_augru_auft) = ta_detail[ lv_count ]-augru_auft.
    ta_detailbnb-augru_auft = ta_detail-augru_auft. "lv_augru_auft.

    IF ta_detailbnb-augru_auft IS INITIAL.
      ta_detailbnb-augru_auft = 'NON'.
    ENDIF.

    APPEND ta_detailbnb. " TRANSPORTING dnqty dnval city1 post_code1 augru_auft.
    CLEAR: ta_detailbnb, ta_detail.
  ENDLOOP.

  WRITE: / 'End Proses data Bill_nonBill : ', sy-datum, sy-vline , sy-uzeit.

  SORT ta_detail BY extwg do_number material_code.

  WRITE: / 'Start Proses data S619 : ', sy-datum, sy-vline , sy-uzeit.

  PERFORM f_get_data_s619.
  WRITE: / 'End Proses data S619 : ', sy-datum, sy-vline , sy-uzeit.
  PERFORM f_filter_data_s619.
  WRITE: / 'End Proses filter S619 : ', sy-datum, sy-vline , sy-uzeit.
  PERFORM f_get_master_s619.
  WRITE: / 'End Proses Master S619 : ', sy-datum, sy-vline , sy-uzeit.
  PERFORM f_collect_data_s619.
  WRITE: / 'End Proses collect S619 : ', sy-datum, sy-vline , sy-uzeit.

*  PERFORM f_get_data_hsales.
*  PERFORM f_get_master_hsales.
*  PERFORM f_collect_data_hsales.
ENDFORM.                    " F_PROSES_BILL_NONBILL

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_FILE1
*&---------------------------------------------------------------------*
FORM f_proses_file1  USING fu_file.
  DATA: p_return(1), lv_error(1).
  WRITE: / 'Start Proses tulis ke file 1 : ', sy-datum, sy-vline , sy-uzeit.
  PERFORM f_format_file1 USING fu_file.
  PERFORM f_open_file USING fu_file
                      CHANGING p_return.
  PERFORM f_write_file1 TABLES ta_detailbnb USING fu_file.
  PERFORM f_close_file USING fu_file.
  WRITE: / 'End Proses tulis ke file 1 : ', sy-datum, sy-vline , sy-uzeit.
  WRITE: / ' Start Proses Ambil file compare 1 : ', sy-datum, sy-vline , sy-uzeit.

  PERFORM f_mode_777 USING fu_file.
  PERFORM f_compare_file1 TABLES ta_detailbnb
                          USING fu_file p_return lv_error.
  WRITE: / ' End  Proses Ambil file compare 1 : ', sy-datum, sy-vline , sy-uzeit.
  IF p_return = '1' OR p_return = '2'.
    WRITE: / 'Start Proses tulis ke file 2 : ', sy-datum, sy-vline , sy-uzeit.

    PERFORM f_open_file USING fu_file
                        CHANGING p_return.
    PERFORM f_write_file1 TABLES ta_detailbnb USING fu_file.
    PERFORM f_close_file USING fu_file.
    WRITE: / 'End Proses tulis ke file2 : ', sy-datum, sy-vline , sy-uzeit.
    WRITE: / ' Start Proses Ambil file compare 2: ', sy-datum, sy-vline , sy-uzeit.

    PERFORM f_mode_777 USING fu_file.
    PERFORM f_compare_file1 TABLES ta_detailbnb
                            USING fu_file p_return lv_error.
    WRITE: / ' End Proses Ambil file compare 2: ', sy-datum, sy-vline , sy-uzeit.
    IF p_return = '1' OR p_return = '2'.
*      OPEN DATASET fu_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*      IF sy-subrc = 0.
*        DELETE DATASET fu_file.
*      ENDIF.
*      CLOSE DATASET fu_file.
      CASE p_return.
        WHEN '1'.
          SKIP 2.
          WRITE: / 'File cannot open...'.
        WHEN '2'.
          SKIP 2.
          CASE lv_error.
            WHEN '1'.
              WRITE: / 'Selisih Gross...'.
            WHEN '2'.
              WRITE: / 'Selisih Qty...'.
            WHEN '3'.
              WRITE: / 'Selisih DN Qty...'.
            WHEN '4'.
              WRITE: / 'Selisih DN Value...'.
            WHEN '5'.
              WRITE: / 'Selisih Jumlah Record...'.
          ENDCASE.

          SKIP.
          WRITE: / 'Gross Write = ', va_gross.
          WRITE: / 'Gross Read = ',  va_gross2.
          WRITE: / 'Qty Write = ', va_qty.
          WRITE: / 'Qty Read = ',  va_qty2.
          WRITE: / 'DN Qty Write = ', va_dnqty.
          WRITE: / 'DN Qty Read = ',  va_dnqty2.
          WRITE: / 'DN Value Write = ', va_dnval.
          WRITE: / 'DN Value Read = ',  va_dnval2.
          WRITE: / 'Record Write = ', va_record.
          WRITE: / 'Record Read = ',  va_record2.
      ENDCASE.

      SKIP 10.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Proses Buying Outlet BNB hari ini gagal mohon hub. team Functional untuk proses ulang'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Dikerjakan oleh : _______________'.
    ELSE.
      PERFORM tulis_log USING fu_file.

    ENDIF.
  ELSE.
    PERFORM tulis_log USING fu_file.

  ENDIF.
ENDFORM.                    " F_PROSES_FILE1

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_S619
*&---------------------------------------------------------------------*
FORM f_get_data_s619 .
  DATA: lt_werks LIKE t_s619 OCCURS 0 WITH HEADER LINE,
        lt_vbeln LIKE t_s619 OCCURS 0 WITH HEADER LINE.

  SELECT ssour vrsio spmon sptag spwoc spbup a~vkorg werks a~vkbur a~kunnr vbeln
       a~matnr periv vwdat waerk a~vrkme stwae grosval lfimg zdisa zdisb zdisc
       zdisd zdise zdisf zdisf_01 umkzwi4 gukzwi4 a~mvgr2 a~mvgr3 a~konda zzroutel
       pvrtnr billing a~erdat b~extwg b~prdha f~maktx d~name1 d~name2 d~name3 d~name4
       c~sortl c~kdgrp c~brsch d~city1 d~post_code1 e~ktgrm
      INTO CORRESPONDING FIELDS OF TABLE t_s619
             FROM  s619  AS a JOIN mara AS b ON b~matnr = a~matnr
                  JOIN kna1vv AS c ON c~kunnr = a~kunnr
                                  AND c~vkorg = a~vkorg
                                  AND c~vtweg = '10' "a~vtweg
                                  AND c~spart = '00' "a~spart
                   JOIN adrc AS d ON  c~adrnr = d~addrnumber
                   JOIN mvke AS e ON e~matnr = a~matnr AND
                                     e~vkorg = a~vkorg AND
                                     e~vtweg = '10'
                   JOIN makt AS f ON f~matnr = a~matnr AND
                                     f~spras = sy-langu
             WHERE
                 "  a~fkdat IN so_fkdat AND
                 "  a~vbeln IN so_vbeln AND

                  ssour = space     AND
                    vrsio = '000'     AND
                    spmon = p_spmon   AND
                    sptag EQ '00000000' AND
                    spwoc EQ '000000' AND
                    spbup EQ '000000' AND
                    a~vkorg IN so_vkorg AND
                    werks IN so_werks AND
                    billing = space.

  IF sy-subrc = 0.
    CLEAR: lt_werks,lt_werks[],t_likp,t_likp[].
    lt_werks[] = t_s619[].
    SORT lt_werks BY werks.
    DELETE ADJACENT DUPLICATES FROM lt_werks COMPARING werks.

    LOOP AT lt_werks.
      CLEAR: lt_vbeln,lt_vbeln[].
      lt_vbeln[] = t_s619[].
      SORT lt_vbeln BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING vbeln.
      DELETE lt_vbeln WHERE werks NE lt_werks-werks.

      SELECT vbeln vbtyp wadat_ist APPENDING TABLE t_likp FROM likp
        FOR ALL ENTRIES IN lt_vbeln
        WHERE vbeln = lt_vbeln-vbeln.
    ENDLOOP.

    IF t_likp[] IS NOT INITIAL.
      SELECT DISTINCT vbeln posnr vgbel
        INTO CORRESPONDING FIELDS OF TABLE t_lips
        FROM lips FOR ALL ENTRIES IN t_likp
        WHERE vbeln = t_likp-vbeln.

      IF t_lips[] IS NOT INITIAL.
        SELECT vbeln augru
          INTO CORRESPONDING FIELDS OF TABLE t_vbak
          FROM vbak FOR ALL ENTRIES IN t_lips
          WHERE vbeln = t_lips-vgbel.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA_S619

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_DATA_S619
*&---------------------------------------------------------------------*
FORM f_filter_data_s619 .
*  SORT i_vbrp BY vkorg vgbel kunrg.
*  SORT t_s619 BY vkorg vbeln kunnr.
  LOOP AT t_s619.
*    READ TABLE i_vbrp INTO wa_vbrp
*         WITH KEY vkorg = t_s619-vkorg
*                  vgbel = t_s619-vbeln
*                  kunrg = t_s619-kunnr BINARY SEARCH.
*** Hapus data yg sdh billing
*    IF sy-subrc = 0 OR t_s619-kunnr IN r_noncon OR t_s619-lfimg IS INITIAL.
*      DELETE t_s619.
*    ENDIF.
    IF t_s619-kunnr IN r_noncon OR t_s619-lfimg IS INITIAL.
      DELETE t_s619.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FILTER_DATA_S619

*&---------------------------------------------------------------------*
*&      Form  F_GET_MASTER_S619
*&---------------------------------------------------------------------*
FORM f_get_master_s619 .
***  DATA : lt_s619 LIKE t_s619 OCCURS 0.
***  IF t_s619[] IS NOT INITIAL.
***    lt_s619[] = t_s619[].
***    SORT lt_s619 BY matnr.
***    DELETE ADJACENT DUPLICATES FROM lt_s619 COMPARING matnr.
***    SELECT a~matnr a~prdha b~maktx
***      INTO CORRESPONDING FIELDS OF TABLE t_mara
***      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
***      FOR ALL ENTRIES IN lt_s619
***      WHERE a~matnr = lt_s619-matnr AND
***            b~spras = sy-langu.
***    SORT t_mara BY matnr.
***
***    lt_s619[] = t_s619[].
***    SORT lt_s619 BY kunnr.
***    DELETE ADJACENT DUPLICATES FROM lt_s619 COMPARING kunnr.
***    SELECT kunnr b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1
***      b~post_code1
***      INTO CORRESPONDING FIELDS OF TABLE t_kna1
***      FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
***      FOR ALL ENTRIES IN lt_s619
***      WHERE kunnr = lt_s619-kunnr AND
***            vkorg = lt_s619-vkorg AND
***            vtweg = '10' AND
***            spart = '00'.
***    SORT t_kna1 BY kunnr.
***  ENDIF.
ENDFORM.                    " F_GET_MASTER_S619

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_DATA_S619
*&---------------------------------------------------------------------*
FORM f_collect_data_s619 .
  SORT t_s619 BY vbeln.
  SORT t_likp BY vbeln.
  SORT t_s619 BY vbeln.

  LOOP AT t_s619.
** Check customer consol
*    IF t_s619-kunnr IN r_noncon. "Already done in filter data
*      CONTINUE.
*    ENDIF.

    CLEAR ta_detailbnb.
    ta_detailbnb-vkorg = t_s619-vkorg.
*    ta_detailbnb-fkdat = sy-datum.
    ta_detailbnb-sal_off = t_s619-vkbur.
    ta_detailbnb-customer = t_s619-kunnr.
    ta_detailbnb-material_code = t_s619-matnr.
    ta_detailbnb-do_number = t_s619-vbeln.
    ta_detailbnb-dnqty = t_s619-lfimg.
*    ta_detailbnb-dnval = t_s619-grosval.

    CLEAR t_likp.
    SORT t_likp BY vbeln.
    READ TABLE t_likp WITH KEY vbeln = t_s619-vbeln
                      BINARY SEARCH.
    ta_detailbnb-do_date = t_likp-wadat_ist.

    IF t_likp-vbtyp = 'J'.
      ta_detailbnb-program = 'DO'.
      t_s619-zdisa = t_s619-zdisa * -1.
      t_s619-zdisb = t_s619-zdisb * -1.
      t_s619-zdisc = t_s619-zdisc * -1.
      t_s619-zdisd = t_s619-zdisd * -1.
      t_s619-zdise = t_s619-zdise * -1.
      t_s619-zdisf = t_s619-zdisf * -1.
      t_s619-zdisf_01 = t_s619-zdisf_01 * -1.
    ELSE.
      ta_detailbnb-program = 'CN'.
    ENDIF.

    WRITE t_s619-grosval TO ta_detailbnb-dnval CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dnval.
    WRITE t_s619-zdisa TO ta_detailbnb-dis_a CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_a.
    WRITE t_s619-zdisb TO ta_detailbnb-dis_b CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_b.
    WRITE t_s619-zdisc TO ta_detailbnb-dis_c CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_c.
    WRITE t_s619-zdisd TO ta_detailbnb-dis_d CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_d.
    WRITE t_s619-zdise TO ta_detailbnb-dis_e CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_e.
    WRITE t_s619-zdisf TO ta_detailbnb-dis_f CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_f.
    WRITE t_s619-zdisf_01 TO ta_detailbnb-dis_f3 CURRENCY 'IDR' NO-GROUPING.
    PERFORM format_minus USING ta_detailbnb-dis_f3.

    "    CLEAR: t_mara.                                          "t_kna1.
**    READ TABLE t_mara WITH KEY matnr = t_s619-matnr
**                      BINARY SEARCH.
**    READ TABLE t_kna1 INTO wa_kna1 WITH KEY kunnr = t_s619-kunnr
**                      BINARY SEARCH.
    ta_detailbnb-prdha = t_s619-prdha. "t_mara-prdha.
    ta_detailbnb-mat_descrp = t_s619-maktx. "  t_mara-maktx.
    ta_detailbnb-industri  = t_s619-brsch. " wa_kna1-brsch.
    ta_detailbnb-search    = t_s619-sortl. " wa_kna1-sortl.
    ta_detailbnb-cust_name = t_s619-name1. "wa_kna1-name1.
    ta_detailbnb-city1     = t_s619-city1. "wa_kna1-city1.
    ta_detailbnb-post_code1 = t_s619-post_code1." wa_kna1-post_code1.
**    CONCATENATE wa_kna1-name2 wa_kna1-name3 wa_kna1-name4
**      INTO ta_detailbnb-address.
    CONCATENATE t_s619-name2 t_s619-name3 t_s619-name4
      INTO ta_detailbnb-address.
    ta_detailbnb-cgrp = t_s619-kdgrp. "wa_kna1-kdgrp.
    ta_detailbnb-extwg = ta_detailbnb-prdha(3).

    PERFORM format_minus1 USING ta_detailbnb-dnqty.
    PERFORM format_minus USING ta_detailbnb-dnval.

    REPLACE ALL OCCURRENCES OF ',' IN ta_detailbnb-dnqty WITH space.
    REPLACE ALL OCCURRENCES OF '.' IN ta_detailbnb-dnqty WITH ','.
    WRITE ta_detailbnb-dnqty TO ta_detailbnb-dnqty RIGHT-JUSTIFIED.

    REPLACE ALL OCCURRENCES OF '.' IN ta_detailbnb-dnval WITH space.
    WRITE ta_detailbnb-dnval TO ta_detailbnb-dnval RIGHT-JUSTIFIED.

    CLEAR: t_lips,t_vbak.
    READ TABLE t_lips WITH KEY vbeln = t_likp-vbeln.
    READ TABLE t_vbak WITH KEY vbeln = t_lips-vgbel.

    ta_detailbnb-augru_auft = t_vbak-augru.

    IF ta_detailbnb-augru_auft IS INITIAL.
      ta_detailbnb-augru_auft = 'NON'.
    ENDIF.

    APPEND ta_detailbnb. CLEAR ta_detailbnb.
  ENDLOOP.
ENDFORM.                    " F_COLLECT_DATA_S619

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_HSALES
*&---------------------------------------------------------------------*
FORM f_get_data_hsales .
  CLEAR: i_dsales,i_dsales[].
  SELECT h~vbeln h~fkart h~vbtyp h~vkorg h~fkdat d~matnr h~plant h~vkbur
         h~kunnr h~bldat d~nsp d~fkimg d~disa d~disb d~disd d~disdc d~disf
         d~disc d~dise d~dissp d~disvol
    INTO CORRESPONDING FIELDS OF TABLE i_dsales
    FROM zsl_hsales AS h JOIN zsl_dsales AS d ON h~vbeln = d~vbeln AND
                                                 h~gjahr = d~gjahr AND
                                                 h~vbtyp = d~vbtyp AND
                                                 h~z_uplod = d~z_uplod
    WHERE h~bldat IN so_fkdat AND
          h~plant IN so_werks AND
          h~vkorg IN so_vkorg AND
          h~vbeln IN so_vbeln AND
          h~upl_cancel = 0    AND
          h~account_no = space.
ENDFORM.                    " F_GET_DATA_HSALES

*&---------------------------------------------------------------------*
*&      Form  F_GET_MASTER_HSALES
*&---------------------------------------------------------------------*
FORM f_get_master_hsales .
*****  DATA : lt_dsales LIKE i_dsales OCCURS 0.
*****  IF i_dsales[] IS NOT INITIAL.
*****    lt_dsales[] = i_dsales[].
*****    SORT lt_dsales BY matnr.
*****    DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING matnr.
*****"    CLEAR: t_mara,t_kna1,t_mara[],t_kna1[].
*****    SELECT a~matnr a~prdha b~maktx
*****      INTO CORRESPONDING FIELDS OF TABLE t_mara
*****      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
*****      FOR ALL ENTRIES IN lt_dsales
*****      WHERE a~matnr = lt_dsales-matnr AND
*****            b~spras = sy-langu.
*****
*****    lt_dsales[] = i_dsales[].
*****    SORT lt_dsales BY kunnr.
*****    DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING kunnr.
*****    SELECT kunnr b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1
*****           b~post_code1
*****      INTO CORRESPONDING FIELDS OF TABLE t_kna1
*****      FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
*****      FOR ALL ENTRIES IN lt_dsales
*****      WHERE kunnr = lt_dsales-kunnr AND
*****            vkorg = lt_dsales-vkorg AND
*****            vtweg = '10' AND
*****            spart = '00'.
*****  ENDIF.
ENDFORM.                    " F_GET_MASTER_HSALES

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_DATA_HSALES
*&---------------------------------------------------------------------*
FORM f_collect_data_hsales .
******  SORT ta_detail BY sal_off do_number.
******  SORT i_dsales BY vkbur vbeln.
******  LOOP AT i_dsales INTO wa_dsales.
******** Check customer consol
******    IF wa_dsales-kunnr IN r_noncon.
******      CONTINUE.
******    ENDIF.
******
******** Check double record
******    READ TABLE ta_detail WITH KEY sal_off = wa_dsales-vkbur
******                                  do_number = wa_dsales-vbeln
******                         BINARY SEARCH.
******    IF sy-subrc = 0.
******      CONTINUE.
******    ENDIF.
******
******    CLEAR ta_detailbnb.
******    ta_detailbnb-vkorg = wa_dsales-vkorg.
*******    ta_detailbnb-fkdat = sy-datum.
******    ta_detailbnb-do_date = wa_dsales-bldat.
******    ta_detailbnb-sal_off = wa_dsales-vkbur.
******    ta_detailbnb-customer = wa_dsales-kunnr.
******    ta_detailbnb-material_code = wa_dsales-matnr.
******    ta_detailbnb-do_number = wa_dsales-vbeln.
*******    ta_detailbnb-dnqty = wa_dsales-fkimg.
*******    ta_detailbnb-dnval = wa_dsales-nsp.
******    WRITE wa_dsales-fkimg TO ta_detailbnb-dnqty NO-GROUPING.
******    WRITE wa_dsales-nsp TO ta_detailbnb-dnval CURRENCY 'IDR' NO-GROUPING.
******
******"    CLEAR: t_mara,t_kna1.
*******{   REPLACE        P01K910196                                        1
*******\    READ TABLE t_mara WITH KEY matnr = wa_dsales-matnr
*******\                      BINARY SEARCH.
*******\    READ TABLE t_kna1 INTO wa_kna1 WITH KEY kunnr = wa_dsales-kunnr
*******\                      BINARY SEARCH.
******    "Start SOH: Shell SCI Adjustment 20240221 KS
*********    SORT t_mara BY matnr.
*********    READ TABLE t_mara WITH KEY matnr = wa_dsales-matnr
*********                      BINARY SEARCH.
*********    SORT t_kna1 BY kunnr.
*********    READ TABLE t_kna1 INTO wa_kna1 WITH KEY kunnr = wa_dsales-kunnr
*********                      BINARY SEARCH.
******    "End SOH: Shell SCI Adjustment 20240221 KS
*******}   REPLACE
******    ta_detailbnb-prdha = t_mara-prdha.
******    ta_detailbnb-mat_descrp = t_mara-maktx.
******    ta_detailbnb-industri = wa_kna1-brsch.
******    ta_detailbnb-search = wa_kna1-sortl.
******    ta_detailbnb-cust_name = wa_kna1-name1.
******    ta_detailbnb-city1     = wa_kna1-city1.
******    ta_detailbnb-post_code1 = wa_kna1-post_code1.
******    CONCATENATE wa_kna1-name2 wa_kna1-name3 wa_kna1-name4
******      INTO ta_detailbnb-address.
******    ta_detailbnb-cgrp = wa_kna1-kdgrp.
******    ta_detailbnb-extwg = ta_detailbnb-prdha(3).
******
******    PERFORM format_minus1 USING ta_detailbnb-dnqty.
******    PERFORM format_minus USING ta_detailbnb-dnval.
******
******    REPLACE ALL OCCURRENCES OF ',' IN ta_detailbnb-dnqty WITH space.
******    REPLACE ALL OCCURRENCES OF '.' IN ta_detailbnb-dnqty WITH ','.
******    WRITE ta_detailbnb-dnqty TO ta_detailbnb-dnqty RIGHT-JUSTIFIED.
******
******    REPLACE ALL OCCURRENCES OF '.' IN ta_detailbnb-dnval WITH space.
******    WRITE ta_detailbnb-dnval TO ta_detailbnb-dnval RIGHT-JUSTIFIED.
******
******    APPEND ta_detailbnb. CLEAR ta_detailbnb.
******  ENDLOOP.
ENDFORM.                    " F_COLLECT_DATA_HSALES

*&---------------------------------------------------------------------*
*&      Form  F_CUST_NONCONSOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cust_nonconsol .
  DATA: lt_a890 LIKE a890 OCCURS 0 WITH HEADER LINE.

  SELECT * INTO TABLE lt_a890
    FROM a890 WHERE kappl = 'V' AND
                    kschl = 'ZEXC' AND
                    vkorg IN so_vkorg AND
                    datab LE sy-datum AND
                    datbi GE sy-datum.

  LOOP AT lt_a890.
    r_noncon-sign = 'I'.
    r_noncon-option = 'EQ'.
    r_noncon-low = lt_a890-kunnr.
    APPEND r_noncon. CLEAR r_noncon.
  ENDLOOP.
ENDFORM.                    " F_CUST_NONCONSOL

*&---------------------------------------------------------------------*
*&      Form  F_KNA1VV
*&---------------------------------------------------------------------*
FORM f_kna1vv  TABLES   ft_vbrp STRUCTURE t_vbrp
                        ft_dsales STRUCTURE t_dsales
                        ft_kna1 STRUCTURE zkna1
               USING    fu_flag.

  DATA : lt_vbrp   LIKE t_vbrp OCCURS 0 WITH HEADER LINE,
         lt_dsales LIKE t_dsales OCCURS 0 WITH HEADER LINE.

  CLEAR : ft_kna1[], ft_kna1.

  CASE fu_flag.
    WHEN '0'.
      lt_vbrp[] = ft_vbrp[].
      SORT lt_vbrp BY kunrg vkorg vtweg spart.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING kunrg vkorg vtweg spart.

      IF lt_vbrp[] IS NOT INITIAL.
        SELECT kunnr vkorg vtweg spart
          b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1 b~post_code1
          FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
          INTO CORRESPONDING FIELDS OF TABLE ft_kna1
          FOR ALL ENTRIES IN lt_vbrp
          WHERE kunnr = lt_vbrp-kunrg
            AND vkorg = lt_vbrp-vkorg
            AND vtweg = lt_vbrp-vtweg
            AND spart = lt_vbrp-spart.
      ENDIF.
    WHEN '1'.
      lt_dsales[] = ft_dsales[].
      SORT lt_dsales BY kunnr vkorg.
      DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING kunnr vkorg.

      IF lt_dsales[] IS NOT INITIAL.
        SELECT kunnr vkorg vtweg spart
          b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1 b~post_code1
          FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
          INTO CORRESPONDING FIELDS OF TABLE ft_kna1
          FOR ALL ENTRIES IN lt_dsales
          WHERE kunnr = lt_dsales-kunnr
            AND vkorg = lt_dsales-vkorg.
      ENDIF.
  ENDCASE.
ENDFORM.                                                    " F_KNA1VV

*&---------------------------------------------------------------------*
*&      Form  F_MARA
*&---------------------------------------------------------------------*
FORM f_mara  TABLES   ft_vbrp STRUCTURE t_vbrp
                      ft_dsales STRUCTURE t_dsales
                      ft_mara STRUCTURE lt_mara
             USING    fu_flag.

  DATA : lt_vbrp   LIKE t_vbrp OCCURS 0 WITH HEADER LINE,
         lt_dsales LIKE t_dsales OCCURS 0 WITH HEADER LINE..

  CLEAR : ft_mara[], ft_mara.

  CASE fu_flag.
    WHEN '0'.
      lt_vbrp[] = ft_vbrp[].
      SORT lt_vbrp BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING matnr.
      IF lt_vbrp[] IS NOT INITIAL.
        SELECT mara~matnr extwg prdha maktx
          FROM mara JOIN makt ON mara~matnr EQ makt~matnr
          INTO TABLE ft_mara
          FOR ALL ENTRIES IN lt_vbrp
          WHERE mara~matnr EQ lt_vbrp-matnr
            AND spras EQ sy-langu.
      ENDIF.
    WHEN '1'.
      lt_dsales[] = ft_dsales[].
      SORT lt_dsales BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING matnr.
      IF lt_dsales[] IS NOT INITIAL.
        SELECT mara~matnr extwg prdha maktx
          FROM mara JOIN makt ON mara~matnr EQ makt~matnr
          INTO TABLE ft_mara
          FOR ALL ENTRIES IN lt_dsales
          WHERE mara~matnr EQ lt_dsales-matnr
            AND spras EQ sy-langu.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_MARA

*&---------------------------------------------------------------------*
*&      Form  F_EORD
*&---------------------------------------------------------------------*
FORM f_eord  TABLES   ft_vbrp STRUCTURE t_vbrp
                      ft_dsales STRUCTURE t_dsales
                      ft_eord STRUCTURE lt_eord
             USING    fu_flag.

  DATA : lt_vbrp   LIKE t_vbrp OCCURS 0 WITH HEADER LINE,
         lt_dsales LIKE t_dsales OCCURS 0 WITH HEADER LINE.

  CLEAR : ft_eord[], ft_eord.

  CASE fu_flag.
    WHEN '0'.
      lt_vbrp[] = ft_vbrp[].
      SORT lt_vbrp BY matnr werks.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING matnr werks.
      IF lt_vbrp[] IS NOT INITIAL.
        SELECT matnr werks zeord lifnr
          INTO CORRESPONDING FIELDS OF TABLE ft_eord
          FROM eord
          FOR ALL ENTRIES IN lt_vbrp
          WHERE matnr = lt_vbrp-matnr AND
                werks = lt_vbrp-werks AND
                lifnr IN ('TSB0101','TSB0102').
      ENDIF.

    WHEN '1'.
      lt_dsales[] = ft_dsales[].
      SORT lt_dsales BY matnr plant.
      DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING matnr plant.
      IF lt_dsales[] IS NOT INITIAL.
        SELECT matnr werks zeord lifnr
          INTO CORRESPONDING FIELDS OF TABLE ft_eord
          FROM eord
          FOR ALL ENTRIES IN lt_dsales
          WHERE matnr = lt_dsales-matnr AND
                werks = lt_dsales-plant AND
                lifnr IN ('TSB0101','TSB0102').
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_EORD

*&---------------------------------------------------------------------*
*&      Form  F_MVKE
*&---------------------------------------------------------------------*
FORM f_mvke  TABLES   ft_vbrp   STRUCTURE i_vbrp
                      ft_dsales STRUCTURE i_dsales
                      ft_mvke   STRUCTURE zmvke1
             USING    fu_proc.

  DATA : lt_vbrp   LIKE t_vbrp OCCURS 0 WITH HEADER LINE,
         lt_dsales LIKE t_dsales OCCURS 0 WITH HEADER LINE.

  CLEAR : ft_mvke[], ft_mvke.

  CASE fu_proc.
    WHEN '0'.
      lt_vbrp[] = ft_vbrp[].
      SORT lt_vbrp BY matnr vkorg.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING matnr vkorg.
      IF lt_vbrp[] IS NOT INITIAL.
        SELECT matnr vkorg ktgrm
          FROM mvke
          INTO TABLE ft_mvke
          FOR ALL ENTRIES IN lt_vbrp
          WHERE matnr EQ lt_vbrp-matnr  AND
                vkorg EQ lt_vbrp-vkorg  AND
                vtweg EQ '10'.
      ENDIF.
    WHEN '1'.
      lt_dsales[] = ft_dsales[].
      SORT lt_dsales BY matnr vkorg.
      DELETE ADJACENT DUPLICATES FROM lt_dsales COMPARING matnr vkorg.
      IF lt_dsales[] IS NOT INITIAL.
        SELECT matnr vkorg ktgrm
          FROM mvke
          INTO TABLE ft_mvke
          FOR ALL ENTRIES IN lt_dsales
          WHERE matnr EQ lt_dsales-matnr  AND
                vkorg EQ lt_dsales-vkorg  AND
                vtweg EQ '10'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_MVKE

**&---------------------------------------------------------------------*
**&      Form  F_WRITE
**&---------------------------------------------------------------------*
*FORM f_write  USING    fu_value fu_flag
*              CHANGING fc_value.
*
*  CASE fu_flag.
*    WHEN '0'.
*      WRITE fu_value TO fc_value DECIMALS 0
*                                 NO-GROUPING
*                                 CURRENCY 'IDR'.
*      IF fc_value+24(1) = '-'.
*        SHIFT fc_value RIGHT DELETING TRAILING '-'.
*        SHIFT fc_value LEFT DELETING LEADING space.
*        CONCATENATE '-' fc_value INTO fc_value.
*        CONDENSE fc_value.
*        SHIFT fc_value RIGHT DELETING TRAILING space.
*      ELSE.
*        SHIFT fc_value RIGHT DELETING TRAILING space.
*      ENDIF.
*
*    WHEN '1'.
*      WRITE fu_value TO fu_value NO-GROUPING.
*      IF fc_value+19(1) = '-'.
*        SHIFT fc_value RIGHT DELETING TRAILING '-'.
*        SHIFT fc_value LEFT DELETING LEADING space.
*        CONCATENATE '-' fc_value INTO fc_value.
*        CONDENSE fc_value.
*        SHIFT fc_value RIGHT DELETING TRAILING space.
*      ENDIF.
*  ENDCASE.
*ENDFORM.                    " F_WRITE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data USING  fu_value.
* Get Data EORD
  SELECT matnr werks zeord lifnr
    INTO CORRESPONDING FIELDS OF TABLE i_eord
    FROM eord
    WHERE werks = '0200' AND
          lifnr IN ('TSB0101','TSB0102').
  SORT i_eord BY matnr.
  CASE fu_value.
    WHEN 'VBRP'.
* Get Data VBRK
      WRITE: / 'Start Get data VBRK join VBRP : ', sy-datum, sy-vline , sy-uzeit.
      SELECT k~vbeln k~fkart k~vkorg k~vtweg k~fkdat p~werks p~matnr k~xblnr k~spart
             p~fkimg p~fklmg p~vrkme p~posnr k~knumv p~uepos p~pstyv k~kunrg p~vgbel p~augru_auft
             a~extwg     a~prdha e~maktx
             c~name1 c~name2 c~name3 c~name4 sortl b~kdgrp brsch c~city1 c~post_code1 d~ktgrm
             INTO CORRESPONDING FIELDS OF TABLE i_vbrp
             FROM vbrk AS k JOIN vbrp AS p ON k~vbeln = p~vbeln
                  JOIN mara AS a ON a~matnr = p~matnr
                  JOIN kna1vv AS b ON b~kunnr = k~kunrg
                                  AND b~vkorg = k~vkorg
                                  AND b~vtweg = k~vtweg
                                  AND b~spart = k~spart
                   JOIN adrc AS c ON  b~adrnr = c~addrnumber
                   JOIN mvke AS d ON d~matnr = p~matnr AND
                                     d~vkorg = k~vkorg AND
                                     d~vtweg = '10'
                   JOIN makt AS e ON e~matnr = p~matnr AND
                                     e~spras = sy-langu
             WHERE k~vkorg IN so_vkorg AND
                   k~fkdat IN so_fkdat AND
                   k~vbeln IN so_vbeln AND
                   p~werks IN so_werks.



**        SELECT matnr vkorg ktgrm
**          FROM mvke
**          INTO TABLE ft_mvke
**          FOR ALL ENTRIES IN lt_vbrp
**          WHERE matnr EQ lt_vbrp-matnr  AND
**                vkorg EQ lt_vbrp-vkorg  AND
**                vtweg EQ '10'.


**        SELECT kunnr vkorg vtweg spart
**          b~name1 b~name2 b~name3 b~name4 sortl kdgrp brsch b~city1 b~post_code1
**          FROM kna1vv AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
**          INTO CORRESPONDING FIELDS OF TABLE ft_kna1
**          FOR ALL ENTRIES IN lt_vbrp
**          WHERE kunnr = lt_vbrp-kunrg
**            AND vkorg = lt_vbrp-vkorg
**            AND vtweg = lt_vbrp-vtweg
**            AND spart = lt_vbrp-spart.


      WRITE: / 'End Get data VBRK join VBRP : ', sy-datum, sy-vline , sy-uzeit.

      SORT i_vbrp BY vbeln posnr.
      PERFORM f_eord TABLES i_vbrp i_dsales
                            lt_eord
                     USING '0'.
****      SORT lt_eord BY matnr werks.
****      PERFORM f_mara TABLES i_vbrp i_dsales
****                            lt_mara
****                     USING '0'.
****      SORT lt_mara BY matnr.
****      PERFORM f_kna1vv TABLES i_vbrp i_dsales
****                              gt_kna1
****                       USING '0'.
****      SORT gt_kna1 BY kunnr vkorg vtweg spart.
****      APPEND LINES OF gt_kna1 TO gt_kna1a.
****      PERFORM f_mvke TABLES i_vbrp i_dsales
****                            gt_mvke
****                     USING '0'.
****      SORT gt_mvke BY matnr vkorg.
    WHEN 'DSALES'.
* Get Data Hsales
********      SELECT h~vbeln h~fkart h~vbtyp h~vkorg h~fkdat d~matnr h~plant h~vkbur
********             h~kunnr h~bldat d~nsp d~fkimg d~disa d~disb d~disd d~disdc d~disf d~disc
********             d~dise d~dissp d~disvol
********        FROM zsl_hsales AS h JOIN zsl_dsales AS d ON h~vbeln = d~vbeln AND
********                                                     h~gjahr = d~gjahr AND
********                                                     h~vbtyp = d~vbtyp AND
********                                                     h~z_uplod = d~z_uplod
********        INTO CORRESPONDING FIELDS OF TABLE i_dsales
********        WHERE h~bldat IN so_fkdat AND
********              h~plant IN so_werks AND
********              h~vkorg IN so_vkorg AND
********              h~vbeln IN so_vbeln AND
********              h~upl_cancel = 0.
********      SORT i_dsales BY vbeln matnr.
********      PERFORM f_eord TABLES i_vbrp i_dsales
********                            lt_eord
********                     USING '1'.
********      SORT lt_eord BY matnr werks.
********      PERFORM f_mara TABLES i_vbrp i_dsales
********                            lt_mara
********                     USING '1'.
********      SORT lt_mara BY matnr.
********      PERFORM f_kna1vv TABLES i_vbrp i_dsales
********                              gt_kna1
********                       USING '1'.
********      SORT gt_kna1 BY kunnr vkorg vtweg spart.
********      APPEND LINES OF gt_kna1 TO gt_kna1a.
********      PERFORM f_mvke TABLES i_vbrp i_dsales
********                            gt_mvke
********                     USING '1'.
********      SORT gt_mvke BY matnr vkorg.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_VBRP
*&---------------------------------------------------------------------*
FORM f_process_data_vbrp .
  DATA : lt_vbrp      TYPE STANDARD TABLE OF zvbrp.
  DATA : lv_lines     TYPE i,
         lv_lines_tab TYPE i,
         lv_start     TYPE i,
         lv_end       TYPE i,
         lv_split     TYPE i VALUE 5,
         lv_task      TYPE string,
         lv_index     TYPE string,
         lv_appsvr    TYPE rzllitab-classname VALUE 'parallel_generators'.

  CLEAR : gv_comp, gv_sent, gv_result.

  lv_lines = lines( i_vbrp ).
  lv_lines_tab = lv_lines / lv_split.
  WRITE: / 'Start Proses data VBRP dengan multi task : ', sy-datum, sy-vline , sy-uzeit.

  BREAK tds_dev01.
  CHECK lv_lines <> 0.
  DO lv_split TIMES.
    lv_index = sy-index.
    CONCATENATE 'task' lv_index INTO lv_task.

    IF lv_index EQ 1.
      lv_start = 1.
      lv_end   = lv_lines_tab.
    ELSEIF lv_index EQ lv_split. "Apakah last split, jika ya set to last record
      lv_start = lv_end  + 1.
      lv_end = lv_lines.
    ELSE.
      lv_start = lv_end  + 1.
      lv_end   = lv_start + lv_lines_tab - 1.
    ENDIF.

    CLEAR : lt_vbrp[], lt_vbrp.
    APPEND LINES OF i_vbrp FROM lv_start TO lv_end TO lt_vbrp.

    CALL FUNCTION 'ZS_BUYING_VERSI_SAC7_V1'
      STARTING NEW TASK lv_task
      DESTINATION IN GROUP lv_appsvr
      PERFORMING update_status ON END OF TASK
      EXPORTING
        p_final  = p_final
      TABLES
        i_vbrp   = lt_vbrp
        r_noncon = r_noncon
        i_eord   = i_eord
        lt_eord  = lt_eord.
    "        lt_mara  = lt_mara
    "        gt_kna1  = gt_kna1
    "        gt_mvke  = gt_mvke.

    IF sy-subrc = 0.
      gv_sent = gv_sent + 1.
    ENDIF.
  ENDDO.

  WAIT UNTIL gv_comp >= gv_sent.

  WRITE: / 'End Proses data VBRP dengan multi task : ', sy-datum, sy-vline , sy-uzeit.

ENDFORM.                    " F_PROCESS_DATA_VBRP

*&---------------------------------------------------------------------*
*&      Form  UPDATE_STATUS
*&---------------------------------------------------------------------*
FORM update_status  USING lv_task.
  DATA : lt_detail  LIKE ta_detail OCCURS 0 WITH HEADER LINE.

  gv_comp = gv_comp + 1.

  CLEAR : lt_detail[], lt_detail.

  RECEIVE RESULTS FROM FUNCTION 'ZS_BUYING_VERSI_SAC7_V1'
  IMPORTING
    gv_result = gv_result
  TABLES
    ta_detail = lt_detail.

  APPEND LINES OF lt_detail TO ta_detail.
*  LOOP AT lt_detail.
*    ta_detail = lt_detail.
*    APPEND ta_detail.
*  ENDLOOP.
ENDFORM.                    " UPDATE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_DSALES
*&---------------------------------------------------------------------*
FORM f_process_data_dsales .
  DATA : lt_dsales    TYPE STANDARD TABLE OF zdsales.
  DATA : lv_lines     TYPE i,
         lv_lines_tab TYPE i,
         lv_start     TYPE i,
         lv_end       TYPE i,
         lv_split     TYPE i VALUE 4,
         lv_task      TYPE string,
         lv_index     TYPE string,
         lv_appsvr    TYPE rzllitab-classname VALUE 'parallel_generators'.

  CLEAR : gv_comp, gv_sent, gv_result.

  lv_lines = lines( i_dsales ).
  lv_lines_tab = lv_lines / lv_split.
  CHECK lv_lines <> 0.
  DO lv_split TIMES.
    lv_index = sy-index.
    CONCATENATE 'task' lv_index INTO lv_task.

    IF lv_index EQ 1.
      lv_start = 1.
      lv_end   = lv_lines_tab.
    ELSEIF lv_index EQ lv_split. "Apakah last split, jika ya set to last record
      lv_start = lv_end  + 1.
      lv_end = lv_lines.
    ELSE.
      lv_start = lv_end  + 1.
      lv_end   = lv_start + lv_lines_tab - 1.
    ENDIF.

    CLEAR : lt_dsales[], lt_dsales.
    APPEND LINES OF i_dsales FROM lv_start TO lv_end TO lt_dsales.

    CALL FUNCTION 'ZS_BUYING_VERSI_SAC7_V1'
      STARTING NEW TASK lv_task
      DESTINATION IN GROUP lv_appsvr
      PERFORMING update_status ON END OF TASK
      EXPORTING
        p_final  = p_final
      TABLES
        i_dsales = lt_dsales
        r_noncon = r_noncon
        i_eord   = i_eord
        lt_eord  = lt_eord.
**        lt_mara  = lt_mara
**        gt_kna1  = gt_kna1
**        gt_mvke  = gt_mvke.

    IF sy-subrc = 0.
      gv_sent = gv_sent + 1.
    ENDIF.
  ENDDO.

  WAIT UNTIL gv_comp >= gv_sent.

ENDFORM.                    " F_PROCESS_DATA_DSALES

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_FILE2
*&---------------------------------------------------------------------*
FORM f_proses_file2  USING fu_file.
  DATA: p_return(1).
*  PERFORM f_download_with_dataset.
  PERFORM f_format_file1 USING fu_file.
  PERFORM f_open_file USING p_file1 p_return.
  PERFORM f_write_file2 TABLES ta_detailrch USING p_file1.
  PERFORM f_close_file USING p_file1.
  PERFORM f_mode_777 USING p_file1.
  PERFORM f_compare_file2 TABLES ta_detailrch
                          USING p_file1 p_return.
  IF p_return = '1' OR p_return = '2'.
    PERFORM f_open_file USING p_file1 p_return.
    PERFORM f_write_file2 TABLES ta_detailrch USING p_file1.
    PERFORM f_close_file USING p_file1.
    PERFORM f_mode_777 USING p_file1.
    PERFORM f_compare_file2 TABLES ta_detailrch
                            USING p_file1 p_return.
    IF p_return = '1' OR p_return = '2'.
      OPEN DATASET p_file1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc = 0.
        DELETE DATASET p_file1.
      ENDIF.
      CLOSE DATASET p_file1.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Proses Buying Outlet ROCHE hari ini gagal mohon hub. team Functional untuk proses ulang'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Dikerjakan oleh : _______________'.
    ELSE.
      PERFORM tulis_log USING fu_file.

    ENDIF.
  ELSE.
    PERFORM tulis_log USING fu_file.

  ENDIF.
ENDFORM.                    " F_PROSES_FILE2

*&---------------------------------------------------------------------*
*&      Form  f_cek_file
*&---------------------------------------------------------------------*
FORM f_compare_file2  TABLES p_itab STRUCTURE ta_detailrch
                      USING  p_dataset LIKE va_dataset
                             p_return.
  DATA: l_itab      LIKE ta_detailrch OCCURS 0,
        lwa_itab    LIKE ta_detailrch,
        l_record    TYPE i, l_minus(1), va_text(30)..
  DATA: l_qty1 LIKE zsac7_tmp-netsqty,
        l_qty  LIKE zsac7_tmp-netsqty.

*   Write Dataset
  l_minus = '-'.

  PERFORM f_open_file1 USING p_dataset p_return.
  IF p_return = 0.
    PERFORM move_file_to_itab2 TABLES l_itab USING p_dataset.
    PERFORM f_close_file USING p_dataset.
    CLEAR: l_qty, l_record.
    LOOP AT l_itab INTO lwa_itab.
      IF l_minus CO lwa_itab-qty.
        CLEAR: va_text.
        va_text = lwa_itab-qty.
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        REPLACE ',' WITH '.' INTO va_text.
        l_qty1 = va_text.
        ADD l_qty1 TO l_qty.
      ENDIF.
      ADD 1 TO l_record.
      CLEAR: lwa_itab.
    ENDLOOP.

    IF l_qty <> va_qty.
      p_return = '2'.
    ENDIF.
    IF l_record <> va_record.
      p_return = '2'.
    ENDIF.
  ELSE.
    p_return = '1'.
  ENDIF.
ENDFORM.                    " f_cek_file

*&---------------------------------------------------------------------*
*&      Form  f_write_file1
*&---------------------------------------------------------------------*
FORM f_write_file2 TABLES   p_itab STRUCTURE ta_detailrch
                   USING    p_dataset LIKE va_dataset.
  DATA: l_minus(1), va_text(30).
  DATA: l_qty  LIKE zsac7_tmp-netsqty,
        l_text TYPE char255.

*   Write Dataset
  l_minus = '-'.
  CLEAR: va_record,va_gross.
  LOOP AT p_itab.
    CLEAR l_text.
    CONCATENATE p_itab-vbeln p_itab-material_code p_itab-mat_descrp
                p_itab-qty p_itab-charg p_itab-expdt p_itab-dnref p_itab-billno
                p_itab-fkart
                INTO l_text SEPARATED BY ';'.
    TRANSFER l_text TO p_dataset.
    IF l_minus CO p_itab-qty.
      CLEAR: va_text.
      va_text = p_itab-qty.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      REPLACE ',' WITH '.' INTO va_text.
      l_qty = va_text.
      ADD l_qty TO va_qty.
    ENDIF.
    ADD 1 TO va_record.
  ENDLOOP.
ENDFORM.                    " f_write_file2

*&---------------------------------------------------------------------*
*&      Form  move_file_to_itab2
*&---------------------------------------------------------------------*
FORM move_file_to_itab2  TABLES   p_itab STRUCTURE ta_detailrch
                         USING    p_dataset LIKE va_dataset.
  DATA:  lwa_itab LIKE ta_detailrch.
  REFRESH: p_itab, itabline.
  CLEAR: p_itab, lwa_itab.
  DO.
    READ DATASET p_dataset INTO wa_itabline .
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND wa_itabline TO itabline.
    CLEAR: wa_itabline.
  ENDDO.

  LOOP AT itabline INTO wa_itabline.
    SPLIT wa_itabline AT ';' INTO lwa_itab-vbeln
                                  lwa_itab-material_code
                                  lwa_itab-mat_descrp
                                  lwa_itab-qty
                                  lwa_itab-charg
                                  lwa_itab-expdt
                                  lwa_itab-dnref
                                  lwa_itab-billno.
    APPEND lwa_itab TO p_itab.
    CLEAR lwa_itab.
  ENDLOOP.
ENDFORM.                    " move_file_to_itab2

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_ROCHE
*&---------------------------------------------------------------------*
FORM f_proses_roche .
  DATA: lt_detail LIKE ta_detail OCCURS 0 WITH HEADER LINE,
        lt_lines  LIKE tline OCCURS 0 WITH HEADER LINE,
        lv_name   LIKE  thead-tdname.

  lt_detail[] = ta_detail[].
  DELETE lt_detail WHERE extwg(3) NE 'RCH'.

  WRITE: / 'Start Proses data RCH : ', sy-datum, sy-vline , sy-uzeit.
  SORT i_vbrp BY vbeln matnr.
  SORT lt_detail BY vbeln material_code.
  LOOP AT lt_detail.

    MOVE-CORRESPONDING lt_detail TO gt_vbrprch.
    gt_vbrprch-program = lt_detail-program.
    gt_vbrprch-vgbel   = lt_detail-do_number.
    gt_vbrprch-augru_auft = lt_detail-augru_auft.
    IF gt_vbrprch-augru_auft IS INITIAL .
      gt_vbrprch-augru_auft = 'NON'.
    ENDIF.
    SORT i_vbrp BY vbeln matnr.
    READ TABLE i_vbrp WITH KEY vbeln = lt_detail-vbeln
                               matnr = lt_detail-material_code
                               BINARY SEARCH.
    IF sy-subrc = 0.
      gt_vbrprch-posnr  = i_vbrp-posnr.
    ENDIF.

    lv_name = gt_vbrprch-vbeln.

    IF lt_detail-program = 'CN'.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'Z004'
          language                = sy-langu
          name                    = lv_name
          object                  = 'VBBK'
        TABLES
          lines                   = lt_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc = 0.
        READ TABLE lt_lines INDEX 1.
        gt_vbrprch-dnref = lt_lines-tdline(10).
      ELSE.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    APPEND gt_vbrprch. CLEAR gt_vbrprch.
  ENDLOOP.

  IF gt_vbrprch[] IS NOT INITIAL.
    PERFORM f_get_data_do_rch.
    PERFORM f_append_itab_rch.
  ENDIF.
  WRITE: / 'End Proses data RCH : ', sy-datum, sy-vline , sy-uzeit.

ENDFORM.                    " F_PROSES_ROCHE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_DO_RCH
*&---------------------------------------------------------------------*
FORM f_get_data_do_rch .
  SELECT vbeln posnr uecha a~matnr charg vfdat lfimg lgmng maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_lipsrch
    FROM lips AS a JOIN makt AS b ON a~matnr = b~matnr AND
                                     b~spras = sy-langu
     FOR ALL ENTRIES IN gt_vbrprch
    WHERE vbeln EQ gt_vbrprch-vgbel
      AND ( posnr EQ gt_vbrprch-posnr OR
            vgpos EQ gt_vbrprch-posnr OR
            uecha EQ gt_vbrprch-posnr ).
  gt_lipsrch2[] = gt_lipsrch[].
  DELETE gt_lipsrch WHERE uecha IS INITIAL.
  DELETE gt_lipsrch2 WHERE uecha IS NOT INITIAL.
ENDFORM.                    " F_GET_DATA_DO_RCH

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_RCH
*&---------------------------------------------------------------------*
FORM f_append_itab_rch .
  SORT gt_vbrprch BY vgbel vgpos.
  SORT gt_lipsrch BY vbeln uecha.
  SORT gt_lipsrch2 BY vbeln posnr.
  LOOP AT gt_vbrprch.
    CLEAR: gt_lipsrch,gt_lipsrch2.
    READ TABLE gt_lipsrch WITH KEY vbeln = gt_vbrprch-vgbel
                                   uecha = gt_vbrprch-vgpos
    BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM f_append_detail_rch USING gt_lipsrch gt_vbrprch.
    ELSE.
      READ TABLE gt_lipsrch2 WITH KEY vbeln = gt_vbrprch-vgbel
                                      posnr = gt_vbrprch-vgpos
      BINARY SEARCH.
      IF sy-subrc = 0.
        PERFORM f_append_detail_rch USING gt_lipsrch2 gt_vbrprch.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_APPEND_ITAB_RCH

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_DETAIL_RCH
*&---------------------------------------------------------------------*
FORM f_append_detail_rch  USING  fu_lipsrch STRUCTURE gt_lipsrch
                                 fu_vbrprch STRUCTURE gt_vbrprch.
  "  CLEAR t_mara.
  "  READ TABLE t_mara WITH KEY matnr = fu_lipsrch-matnr BINARY SEARCH.
  ta_detailrch-vbeln = fu_lipsrch-vbeln.
  ta_detailrch-material_code = fu_lipsrch-matnr.
  ta_detailrch-mat_descrp = fu_lipsrch-maktx.
*  WRITE fu_lipsrch-lfimg TO ta_detailrch-qty NO-GROUPING.
  WRITE fu_lipsrch-lgmng TO ta_detailrch-qty NO-GROUPING.
  PERFORM format_minus1 USING ta_detailrch-qty.
  ta_detailrch-charg = fu_lipsrch-charg.
  WRITE fu_lipsrch-vfdat TO ta_detailrch-expdt.
  ta_detailrch-dnref = fu_vbrprch-dnref.
  ta_detailrch-billno = fu_vbrprch-vbeln.
  ta_detailrch-fkart = fu_vbrprch-fkart.
  APPEND ta_detailrch. CLEAR ta_detailrch.
ENDFORM.                    " F_APPEND_DETAIL_RCH
