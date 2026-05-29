*----------------------------------------------------------------------*
*   INCLUDE ZDG2SD_F003F01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  DATA ld_knumh LIKE a003-knumh.
  DATA ld_kbetr LIKE konp-kbetr.

**Get VAT-out value
  SELECT SINGLE knumh INTO ld_knumh
                      FROM a003
                      WHERE kappl = 'TX' AND
                            kschl = 'MWAS' AND
                            aland = 'ID' AND
                            mwskz = gc_taxcode.      "VAT out
  IF sy-subrc = 0.
    SELECT SINGLE kbetr INTO ld_kbetr
                        FROM konp
                        WHERE knumh = ld_knumh.
    gv_tax = ld_kbetr / 10.
  ELSE.
    MESSAGE i000(zab) WITH 'VAT-out rate has not been maintained'.
    STOP.
  ENDIF.
ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: li_vbrk   LIKE vbrk,
        gt_xkomfk TYPE TABLE OF komfk,
        gt_xthead TYPE TABLE OF theadvb,
        gt_xvbfs  TYPE TABLE OF vbfs,
        gt_xvbss  TYPE TABLE OF vbss.

  DATA: name     TYPE tdobname,
        lv_xblnr TYPE xblnr.
  DATA: lines LIKE tline OCCURS 0 WITH HEADER LINE.

  name  = pa_vbeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0001'
      language                = sy-langu
      name                    = name
      object                  = 'VBBK'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF lines[] IS NOT INITIAL.
    READ TABLE lines INDEX 1.
    IF sy-subrc = 0.
      lv_xblnr  = lines-tdline.
    ENDIF.
  ENDIF.

  li_vbrk-vbeln = pa_vbeln.

  IF gt_monthnames[] IS INITIAL.
    CALL FUNCTION 'MONTH_NAMES_GET'
      EXPORTING
        language    = 'i'
      TABLES
        month_names = gt_monthnames.
  ENDIF.

  CALL FUNCTION 'RV_INVOICE_REFRESH'
*   EXPORTING
*     WITH_POSTING       = ' '
*     I_NO_NAST          = ' '
    TABLES
      xkomfk = gt_xkomfk
      xkomv  = gt_xkomv
      xthead = gt_xthead
      xvbfs  = gt_xvbfs
      xvbpa  = gt_xvbpa
      xvbrk  = gt_xvbrk
      xvbrp  = gt_xvbrp
      xvbss  = gt_xvbss.

  CALL FUNCTION 'RV_INVOICE_DOCUMENT_READ'
    EXPORTING
      konv_read    = 'X'
      vbrk_i       = li_vbrk
    TABLES
      xkomv        = gt_xkomv
      xvbpa        = gt_xvbpa
      xvbrk        = gt_xvbrk
      xvbrp        = gt_xvbrp
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 2.

  IF sy-subrc = 0.
    PERFORM f_get_signature.

    SELECT * INTO TABLE gt_vbkd
      FROM vbkd FOR ALL ENTRIES IN gt_xvbrp
      WHERE vbeln EQ gt_xvbrp-aubel.

    SELECT * INTO TABLE gt_likp
      FROM likp FOR ALL ENTRIES IN gt_xvbrp
      WHERE vbeln EQ gt_xvbrp-vgbel.

    SELECT * INTO TABLE gt_bseg
      FROM bseg FOR ALL ENTRIES IN gt_xvbrk
      WHERE bukrs EQ gt_xvbrk-vkorg
        AND belnr EQ gt_xvbrk-vbeln
        AND gjahr EQ gt_xvbrk-fkdat(4)
        AND bschl EQ '01'.

    SELECT * INTO TABLE gt_t052
      FROM t052 FOR ALL ENTRIES IN gt_xvbrk
      WHERE zterm EQ gt_xvbrk-zterm.
    IF sy-subrc = 0.
      SELECT * INTO TABLE gt_t052u
        FROM t052u FOR ALL ENTRIES IN gt_t052
        WHERE spras EQ sy-langu
          AND zterm EQ gt_t052-zterm
          AND ztagg EQ gt_t052-ztagg.
    ENDIF.

    SELECT * INTO TABLE gt_kna1
      FROM kna1 FOR ALL ENTRIES IN gt_xvbpa
      WHERE kunnr EQ gt_xvbpa-kunnr.

    SELECT * INTO TABLE gt_adrc
      FROM adrc FOR ALL ENTRIES IN gt_xvbpa
      WHERE addrnumber EQ gt_xvbpa-adrnr.

    SELECT * INTO TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_xvbrp
      WHERE matnr EQ gt_xvbrp-matnr
        AND spras EQ sy-langu.

    SELECT * INTO TABLE gt_zgdtxdt0003
      FROM zgdtxdt0003 FOR ALL ENTRIES IN gt_xvbrk
      WHERE bukrs EQ gt_xvbrk-bukrs
        AND brnch EQ gt_xvbrk-bukrs
*        AND busln eq '99'
        AND kunrg EQ gt_xvbrk-kunrg
        AND vbeln EQ gt_xvbrk-vbeln.

    PERFORM f_get_uang_muka USING lv_xblnr.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: lt_xvbrp TYPE TABLE OF vbrpvb WITH HEADER LINE,
        lv_int   TYPE int1.

  lt_xvbrp[] = gt_xvbrp[].
  READ TABLE gt_xvbrk INDEX 1.
  DELETE lt_xvbrp WHERE vbeln NE gt_xvbrk-vbeln.
  SORT lt_xvbrp BY aubel.
  DELETE ADJACENT DUPLICATES FROM lt_xvbrp COMPARING aubel.
  DESCRIBE TABLE lt_xvbrp LINES lv_int.
  IF lv_int GT 1.
    gv_multi = 'X'.
  ENDIF.
ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: lv_dudat    TYPE dats,
        lv_norut    TYPE int1,
*        lv_harga TYPE kzwi1,
        lv_harga    TYPE dec11_4,
        lv_kzwi1    TYPE kzwi1,
        lv_kzwi2    TYPE kzwi2,
        lv_kzwi3    TYPE kzwi3,
        lv_kzwi4    TYPE kzwi4,
        lv_total    LIKE gt_xvbrk-netwr,
        lv_kbetr    LIKE gt_xkomv-kbetr,
        lv_kwertdis LIKE gt_xkomv-kwert,
        lv_kwerttot LIKE gt_xkomv-kwert,
        lv_xkomv    LIKE LINE OF gt_xkomv,
        lv_adrnr    LIKE twlad-adrnr,
        lw_xvbpa_rg LIKE LINE OF gt_xvbpa,
        lw_xvbpa_ag LIKE LINE OF gt_xvbpa,
        lw_adrc_rg  LIKE LINE OF gt_adrc,
        lw_adrc_ag  LIKE LINE OF gt_adrc,
        lw_kna1_rg  LIKE LINE OF gt_kna1,
        lw_kna1_ag  LIKE LINE OF gt_kna1,
        lt_xvbrp    TYPE TABLE OF vbrpvb WITH HEADER LINE.

  SORT gt_xkomv BY knumv kposn kschl.
  SORT gt_xvbpa BY vbeln posnr.
  SORT gt_xvbrk BY vbeln.
  SORT gt_xvbrp BY vbeln posnr.
  SORT gt_vbkd BY vbeln posnr.
  SORT gt_likp BY vbeln.
  SORT gt_bseg BY belnr.
  SORT gt_kna1 BY kunnr.
  SORT gt_adrc BY addrnumber.
  SORT gt_makt BY matnr.

  LOOP AT gt_xvbrk.
    CLEAR: lv_dudat,gt_bseg,gt_xkomv,gt_xvbrp,lw_xvbpa_rg,lw_adrc_rg,lw_kna1_rg,lv_norut,gt_likp,
           lw_xvbpa_ag,lw_adrc_ag,lw_kna1_ag,lv_total,gt_t052,gt_zgdtxdt0003,gt_monthnames.
    READ TABLE gt_zgdtxdt0003 WITH KEY vbeln = gt_xvbrk-vbeln.
    READ TABLE gt_t052 WITH KEY zterm = gt_xvbrk-zterm.
    READ TABLE gt_xvbrp INDEX 1.
    READ TABLE gt_vbkd INDEX 1.
    READ TABLE gt_likp WITH KEY vbeln = gt_xvbrp-vgbel.
*    READ TABLE gt_bseg INDEX 1.
*    READ TABLE gt_xkomv WITH KEY knumv = gt_xvbrk-knumv
*                                 kschl = 'ZDB1'
*                        BINARY SEARCH.
    "Payer
    READ TABLE gt_xvbpa INTO lw_xvbpa_rg WITH KEY vbeln = gt_xvbrk-vbeln
                             parvw = 'RG'.
    READ TABLE gt_adrc INTO lw_adrc_rg WITH KEY addrnumber = lw_xvbpa_rg-adrnr.
    READ TABLE gt_kna1 INTO lw_kna1_rg WITH KEY kunnr = lw_xvbpa_rg-kunnr.

    "Shiping
    READ TABLE gt_xvbpa INTO lw_xvbpa_ag WITH KEY vbeln = gt_xvbrk-vbeln
                             parvw = 'AG'.
    READ TABLE gt_adrc INTO lw_adrc_ag WITH KEY addrnumber = lw_xvbpa_ag-adrnr.
    READ TABLE gt_kna1 INTO lw_kna1_ag WITH KEY kunnr = lw_xvbpa_ag-kunnr.

    lv_dudat = gt_xvbrk-fkdat + gt_t052-ztag1.
    IF gt_xvbrk-fkdat >= '20260401'.
      lv_total = gt_xvbrk-netwr + gt_xvbrk-mwsbk.
    ENDIF.
    WRITE: gt_xvbrk-vbeln TO gv_header-vbeln,
           gt_xvbrk-xblnr TO gv_header-xblnr,
           gt_xvbrk-fkdat TO gv_header-fkdat,
           gt_likp-bldat  TO gv_header-bldat,
           gt_t052-ztag1  TO gv_header-ztag1 NO-ZERO,
           lv_dudat TO gv_header-dudat,
           gt_vbkd-bstkd TO gv_header-bstkd,
           gt_vbkd-bstdk TO gv_header-bstdk,
           lw_xvbpa_rg-kunnr TO gv_header-kunrg,
           lw_xvbpa_ag-kunnr TO gv_header-kunag,
           lw_kna1_rg-stceg TO gv_header-stceg_rg,
           lw_kna1_ag-stceg TO gv_header-stceg_ag,
           gt_zgdtxdt0003-fakturno TO gv_header-fakno USING EDIT MASK '___.___.__.________'.
*           lw_adrc_rg-name_co TO gv_header-name1_rg,
*           lw_adrc_rg-str_suppl1 TO gv_header-addr1_rg,
*           lw_adrc_rg-str_suppl2 TO gv_header-addr2_rg,
*           lw_adrc_rg-str_suppl3 TO gv_header-addr3_rg,
*           lw_adrc_rg-location TO gv_header-addr4_rg,
*           lw_adrc_ag-name_co TO gv_header-name1_ag,
*           lw_adrc_ag-str_suppl1 TO gv_header-addr1_ag,
*           lw_adrc_ag-str_suppl2 TO gv_header-addr2_ag,
*           lw_adrc_ag-str_suppl3 TO gv_header-addr3_ag,
*           lw_adrc_ag-location TO gv_header-addr4_ag,
    PERFORM f_get_customer_addrs USING lw_adrc_rg
                                 CHANGING gv_header-name1_rg
                                          gv_header-addr1_rg
                                          gv_header-addr2_rg
                                          gv_header-addr3_rg
                                          gv_header-addr4_rg.
    PERFORM f_get_customer_addrs USING lw_adrc_ag
                                 CHANGING gv_header-name1_ag
                                          gv_header-addr1_ag
                                          gv_header-addr2_ag
                                          gv_header-addr3_ag
                                          gv_header-addr4_ag.

    PERFORM f_get_term_cod USING gt_t052-zterm gt_t052-ztagg
                           CHANGING gv_header-ztag1.

    CONDENSE gv_header-ztag1.
    gv_header-title = 'FAKTUR'.

*    CLEAR lv_sign.
*    PERFORM f_get_sign USING 'ZSD_8180_INVLIST_SIGNER_NAME'
*                             'S'
*                       CHANGING lv_sign.
*    gv_header-name_sign = lv_sign.

*    CLEAR lv_sign.
*    PERFORM f_get_sign USING 'ZSD_8180_INVLIST_SIGNER_TITLE'
*                             'S'
*                       CHANGING lv_sign.
*    gv_header-title_sign = lv_sign.

    IF gv_multi IS INITIAL.
      DATA: lv_mwsbp TYPE vbrp-mwsbp.
      CLEAR: lv_mwsbp.
      LOOP AT gt_xvbrp WHERE vbeln = gt_xvbrk-vbeln.
        IF gt_xvbrk-fkdat < '20260401'.
          ADD gt_xvbrp-mwsbp TO lv_mwsbp.
        ENDIF.
        CLEAR: gt_makt,lv_harga.
        READ TABLE gt_makt WITH KEY matnr = gt_xvbrp-matnr BINARY SEARCH.

        gv_header-ponum = gt_xvbrp-aubel.
        gv_header-donum = gt_xvbrp-vgbel.
        gt_detail-vbeln = gt_xvbrp-vbeln.
        gt_detail-posnr = gt_xvbrp-posnr.
        gt_detail-matnr = gt_xvbrp-matnr.
        gt_detail-maktx = gt_makt-maktx.
        gt_detail-vrkme = gt_xvbrp-vrkme.

        lv_harga = gt_xvbrp-kzwi1 / gt_xvbrp-fkimg * 100.
        ADD: gt_xvbrp-kzwi1 TO lv_kzwi1,
             gt_xvbrp-kzwi2 TO lv_kzwi2,
             gt_xvbrp-kzwi3 TO lv_kzwi3,
             gt_xvbrp-kzwi4 TO lv_kzwi4,
             1 TO lv_norut.

        gt_detail-norut = lv_norut.

        PERFORM f_recalc_harga USING    gt_xvbrk-knumv
                                        gt_xvbrp-posnr
                                        'Z000'
                               CHANGING lv_harga
                                        lt_xvbrp-kzwi1.

        WRITE: gt_xvbrp-fkimg TO gt_detail-quantity UNIT gt_xvbrp-vrkme,
               lv_harga TO gt_detail-harga DECIMALS 2,  "CURRENCY gt_xvbrk-waerk,
               gt_xvbrp-kzwi1 TO gt_detail-jumlah CURRENCY gt_xvbrk-waerk.

        APPEND gt_detail. CLEAR gt_detail.
      ENDLOOP.

    ELSE.
      CLEAR: lv_mwsbp.
      LOOP AT gt_xvbrp WHERE vbeln = gt_xvbrk-vbeln.
        IF gt_xvbrk-fkdat < '20260401'.
          ADD gt_xvbrp-mwsbp TO lv_mwsbp.
        ENDIF.
        lt_xvbrp-vbeln = gt_xvbrp-vbeln.
        lt_xvbrp-matnr = gt_xvbrp-matnr.
        lt_xvbrp-vrkme = gt_xvbrp-vrkme.
        lt_xvbrp-fkimg = gt_xvbrp-fkimg.
        lt_xvbrp-kzwi1 = gt_xvbrp-kzwi1.
        COLLECT lt_xvbrp. CLEAR lt_xvbrp.

        CLEAR: gt_vbkd,gt_likp.
        READ TABLE gt_vbkd WITH KEY vbeln = gt_xvbrp-aubel.
        READ TABLE gt_likp WITH KEY vbeln = gt_xvbrp-vgbel.

        gt_lampiran-podoc = gt_vbkd-bstkd.
        WRITE gt_vbkd-bstdk TO gt_lampiran-podat.
        gt_lampiran-dodoc = gt_likp-vbeln.
        WRITE gt_likp-fkdat TO gt_lampiran-dodat.
        COLLECT gt_lampiran. CLEAR gt_lampiran.
      ENDLOOP.

      SORT gt_lampiran BY podoc dodoc.
      SORT lt_xvbrp BY vbeln matnr.
      LOOP AT lt_xvbrp WHERE vbeln = gt_xvbrk-vbeln.
        CLEAR: gt_makt,lv_harga.
        READ TABLE gt_makt WITH KEY matnr = lt_xvbrp-matnr BINARY SEARCH.
        gt_detail-vbeln = lt_xvbrp-vbeln.
        gt_detail-matnr = lt_xvbrp-matnr.
        gt_detail-maktx = gt_makt-maktx.
        gt_detail-vrkme = lt_xvbrp-vrkme.

        lv_harga = lt_xvbrp-kzwi1 / lt_xvbrp-fkimg * 100.
        ADD: lt_xvbrp-kzwi1 TO lv_kzwi1,
             lt_xvbrp-kzwi2 TO lv_kzwi2,
             lt_xvbrp-kzwi3 TO lv_kzwi3,
             lt_xvbrp-kzwi4 TO lv_kzwi4,
             1 TO lv_norut.

        gt_detail-norut = lv_norut.

        PERFORM f_recalc_harga USING    gt_xvbrk-knumv
                                        gt_xvbrp-posnr
                                        'Z000'
                               CHANGING lv_harga
                                        lt_xvbrp-kzwi1.

        WRITE: lt_xvbrp-fkimg TO gt_detail-quantity UNIT lt_xvbrp-vrkme,
               lv_harga TO gt_detail-harga DECIMALS 2,  "CURRENCY gt_xvbrk-waerk,
               lt_xvbrp-kzwi1 TO gt_detail-jumlah CURRENCY gt_xvbrk-waerk.

        APPEND gt_detail. CLEAR gt_detail.
      ENDLOOP.
    ENDIF.

    READ TABLE gt_monthnames WITH KEY mnr = gt_xvbrk-fkdat+4(2).
    CONCATENATE gt_xvbrk-fkdat+6(2) gt_monthnames-ltx gt_xvbrk-fkdat(4)
      INTO gv_header-budat SEPARATED BY space.

    IF gt_xvbrk-fkdat < '20260401'.
      lv_total = gt_xvbrk-netwr + lv_mwsbp.
    ENDIF.

    WRITE: lv_kzwi1 TO gv_header-harga_jual CURRENCY 'IDR',
           lv_kzwi2 TO gv_header-disc_val CURRENCY 'IDR' NO-SIGN NO-ZERO,
*           lv_kzwi3 TO gv_header-dpp CURRENCY 'IDR',
           lv_kzwi4 TO gv_header-materai CURRENCY 'IDR' NO-SIGN NO-ZERO,
           lv_total TO gv_header-nilai_fak CURRENCY 'IDR',
           gt_xvbrp-vgbel TO gv_header-spno.

*    PERFORM f_put_sign_in_front CHANGING gv_header-disc_val.
    IF gt_xvbrk-fkdat < '20260401'.
      DATA: dpp TYPE vbrkvb-netwr,
            tot TYPE vbrkvb-netwr,
            ppn TYPE vbrpvb-mwsbp.
      CLEAR: lv_total, dpp, tot, ppn.
      LOOP AT gt_xvbrp WHERE vbeln = gt_xvbrk-vbeln.
        lv_total = gt_xvbrp-kzwi1 + lv_mwsbp.
        PERFORM f_new_calc USING gt_xvbrp-kzwi1 gv_dmbtr gt_xvbrk-fkdat
                           CHANGING gt_xvbrk-netwr gt_xvbrp-mwsbp lv_total
                                    gv_header-ppncd.
        ADD gt_xvbrk-netwr TO dpp.
        ADD lv_total TO tot.
        ADD gt_xvbrp-mwsbp TO ppn.
      ENDLOOP.
      ADD lv_kzwi4 TO tot.


      WRITE: dpp TO gv_header-dpp CURRENCY 'IDR',
             ppn TO gv_header-ppn CURRENCY 'IDR',
*           gt_xvbrk-mwsbk TO gv_header-ppn CURRENCY 'IDR',
             gv_dmbtr TO gv_header-uang_muka CURRENCY 'IDR',
             tot TO gv_header-nilai_fak CURRENCY 'IDR'.


      PERFORM f_get_spell_amount USING tot
                                       'IDR'
                                 CHANGING gv_header-terbilang.
    ELSE.

      PERFORM f_new_calc USING lv_kzwi1 gv_dmbtr gt_xvbrk-fkdat
                         CHANGING gt_xvbrk-netwr gt_xvbrk-mwsbk lv_total"lv_mwsbp lv_total
                                  gv_header-ppncd.
*    gt_xvbrk-mwsbk
      ADD lv_kzwi4 TO lv_total.


      WRITE: gt_xvbrk-netwr TO gv_header-dpp CURRENCY 'IDR',
*           lv_mwsbp TO gv_header-ppn CURRENCY 'IDR',
             gt_xvbrk-mwsbk TO gv_header-ppn CURRENCY 'IDR',
             gv_dmbtr TO gv_header-uang_muka CURRENCY 'IDR',
             lv_total TO gv_header-nilai_fak CURRENCY 'IDR'.

      PERFORM f_get_spell_amount USING lv_total
                                       'IDR'
                                 CHANGING gv_header-terbilang.
    ENDIF.
  ENDLOOP.

  INSERT INITIAL LINE INTO gt_detail INDEX 1.

  PERFORM f_popup_signer CHANGING gv_header-nameadm
                                  gv_header-jabatadm.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  DATA ld_tax(2).

  WRITE gv_tax TO ld_tax DECIMALS 0.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gv_header          = gv_header
        taxrate            = ld_tax
        reprint            = 'X'
        tax                = 'J'
        multi              = gv_multi
      TABLES
        gt_detail          = gt_detail.
  ENDIF.

  IF gv_multi IS NOT INITIAL.
    PERFORM f_determine_smrt_funcmod USING p_tdform2
                                           d_smrt_funcmod
                                           d_frm_subrc.

    IF d_frm_subrc IS INITIAL.
      gv_header-title = 'LAMPIRAN FAKTUR'.
      d_output_opt-tdimmed  = nast-dimme.
      d_output_opt-tddelete = nast-delet.
      d_output_opt-tdcopies = nast-anzal.
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gv_header          = gv_header
        TABLES
          gt_lampiran        = gt_lampiran.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR:  gt_detail, gt_detail[], gv_header.
  REFRESH: gt_xkomv,gt_xvbpa,gt_xvbrk,gt_xvbrp,gt_bseg,gt_kna1,gt_adrc,gt_makt.
  REFRESH: gt_xkomv,gt_xvbpa,gt_xvbrk,gt_xvbrp,gt_bseg,gt_kna1,gt_adrc,gt_makt.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_KOMV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KNUMV  text
*      -->FU_POSNR  text
*      -->FU_KSCHL   text
*      <--FC_XKOMV  text
*----------------------------------------------------------------------*
FORM f_get_komv  USING    fu_knumv
                          fu_posnr
                          fu_kschl
                 CHANGING fc_xkomv.
  READ TABLE gt_xkomv INTO fc_xkomv WITH KEY knumv = fu_knumv
                                             kposn = fu_posnr
                                             kschl = fu_kschl.
ENDFORM.                    " F_GET_KOMV

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_sign  USING    fu_name
                          fu_type
                 CHANGING fc_sign.
  DATA lt_return TYPE zdg2catt0001 WITH HEADER LINE.
  CLEAR: lt_return,lt_return[].
  CALL METHOD zcl_util=>m_get_tvarv
    EXPORTING
      param_name = fu_name
      param_type = fu_type
    IMPORTING
      t_return   = lt_return[].
  LOOP AT lt_return.
    fc_sign = lt_return-low.
  ENDLOOP.
ENDFORM.                    " F_GET_SIGN

*&---------------------------------------------------------------------*
*&      Form  F_GET_SPELL_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_spell_amount  USING    fu_kzwi4
                                  fu_curr
                         CHANGING fc_terbilang.
  DATA lv_spell LIKE spell.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount   = fu_kzwi4
      currency = fu_curr
*     FILLER   = ' '
      language = 'i'
    IMPORTING
      in_words = lv_spell.
  IF sy-subrc = 0.
    CONCATENATE lv_spell-word 'RUPIAH' INTO fc_terbilang SEPARATED BY space.
    CONCATENATE '##' fc_terbilang '##' INTO fc_terbilang SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_SPELL_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_PUT_SIGN_IN_FRONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_put_sign_in_front  CHANGING fc_disc_val.
  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      value = fc_disc_val.
ENDFORM.                    " F_PUT_SIGN_IN_FRONT

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGNATURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_signature .
  DATA lw_zgdtxdt0005 LIKE zgdtxdt0005.

***Get signature
  READ TABLE gt_xvbrk INDEX 1.

  SELECT SINGLE petugas jabat petugas2 jabat2 nameadm jabatadm brnch objrange
    INTO CORRESPONDING FIELDS OF lw_zgdtxdt0005
    FROM zgdtxdt0005
    WHERE bukrs = gt_xvbrk-bukrs.
  IF sy-subrc = 0.
    gv_petugas1 = lw_zgdtxdt0005-petugas.
    gv_jabat1 = lw_zgdtxdt0005-jabat.
    gv_petugas2 = lw_zgdtxdt0005-petugas2.
    gv_jabat2 = lw_zgdtxdt0005-jabat2.
    gv_petugas3 = lw_zgdtxdt0005-nameadm.
    gv_jabat3 = lw_zgdtxdt0005-jabatadm.
    gv_brnch = lw_zgdtxdt0005-brnch.
    gv_object  = lw_zgdtxdt0005-objrange.
  ELSE.
*    MESSAGE i000(zab) WITH 'Signature data is not maintained'.
*    STOP.
  ENDIF.
ENDFORM.                    " F_GET_SIGNATURE

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_SIGNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_popup_signer  CHANGING fc_petugas
                              fc_jabat.
  DATA ld_result.

  CALL FUNCTION 'K_KKB_POPUP_RADIO3'
    EXPORTING
      i_title   = 'Signed by:'
      i_text1   = gv_petugas1
      i_text2   = gv_petugas3
      i_text3   = gv_petugas2
      i_default = '1'
    IMPORTING
      i_result  = ld_result
    EXCEPTIONS
      cancel    = 1
      OTHERS    = 2.

  IF sy-subrc <> 0.
*    LEAVE TO SCREEN 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CASE ld_result.
      WHEN '1'.
        fc_petugas = gv_petugas1.
        fc_jabat = gv_jabat1.
      WHEN '2'.
        fc_petugas = gv_petugas3.
        fc_jabat = gv_jabat3.
      WHEN '3'.
        fc_petugas = gv_petugas2.
        fc_jabat = gv_jabat2.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_POPUP_SIGNER

*&---------------------------------------------------------------------*
*&      Form  F_GET_UANG_MUKA
*&---------------------------------------------------------------------*
FORM f_get_uang_muka  USING    fu_xblnr.
  DATA : lv_bukrs TYPE bukrs,
         lv_belnr TYPE belnr_d,
         lv_gjahr TYPE gjahr.

  DATA : BEGIN OF lt_bseg OCCURS 0,
           dmbtr TYPE dmbtr,
         END OF lt_bseg.

  READ TABLE gt_xvbrk INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE bukrs belnr gjahr
      FROM bkpf
      INTO (lv_bukrs, lv_belnr, lv_gjahr)
      WHERE bukrs = gt_xvbrk-bukrs
        AND xblnr = fu_xblnr
        AND blart = 'DR'.

    IF sy-subrc = 0.
      SELECT dmbtr
        FROM bseg
        INTO TABLE lt_bseg
        WHERE bukrs = lv_bukrs
          AND belnr = lv_belnr
          AND gjahr = lv_gjahr
          AND hkont = '0318120100'.

      LOOP AT lt_bseg.
        ADD lt_bseg-dmbtr TO gv_dmbtr.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_UANG_MUKA

*&---------------------------------------------------------------------*
*&      Form  F_NEW_CALC
*&---------------------------------------------------------------------*
FORM f_new_calc  USING    fu_harga_jual fu_uang_muka fu_fkdat
                 CHANGING fc_dpp fc_ppn fc_total fc_ppncd.

  DATA : lv_ppn   TYPE p DECIMALS 4.

  fc_dpp = fu_harga_jual - fu_uang_muka.
*  fc_ppn = fc_dpp * ( 10 / 100 ).
*
*  PERFORM f_tax_calc USING fu_fkdat '' fc_dpp 'E'
*                     CHANGING lv_ppn fc_ppncd.
*
  lv_ppn = fc_dpp * ( 10 / 100 ).

* Project PPN 11% - Begin
  DATA: ls_zproject TYPE zproject,
        ls_11       TYPE zproject,
        ls_12       TYPE zproject.

  DATA : lr_datab TYPE RANGE OF datab,
         ls_datab LIKE LINE OF lr_datab.

  SELECT SINGLE * INTO ls_11
    FROM zproject WHERE name = 'PPN11'
                    AND flag = 'X'.
  SELECT SINGLE * INTO ls_12
    FROM zproject WHERE name = 'DPP12'  "name = 'PPN12'
                    AND flag = 'X'.

  ls_datab-low    = ls_11-datab.
  ls_datab-high   = ls_12-datab.
  ls_datab-sign   = 'I'.
  ls_datab-option = 'BT'.
  APPEND ls_datab TO lr_datab.

  IF fu_fkdat IN lr_datab.
    CLEAR lv_ppn.
    lv_ppn = fc_dpp * ( 11 / 100 ).
  ELSEIF fu_fkdat >= ls_12-datab.
    CLEAR lv_ppn.
    lv_ppn = fc_dpp * ( 11 / 100 ).
  ENDIF.
* Project PPN 11% - End

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = lv_ppn
*     sign          = '-'
    IMPORTING
      output        = fc_ppn
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

*  PERFORM f_cek_ztax USING gt_xvbrk-vbeln
*                     CHANGING fc_ppn.

  fc_total  = fc_dpp + fc_ppn.

  PERFORM f_tax_calc USING fu_fkdat '' '' 'F1'
                     CHANGING lv_ppn fc_ppncd.

  IF fu_fkdat >= ls_12-datab.
    CLEAR fc_ppncd.
    fc_dpp = fc_dpp * 11 / 12.
  ENDIF.
ENDFORM.                    " F_NEW_CALC

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER_ADDRS
*&---------------------------------------------------------------------*
FORM f_get_customer_addrs  USING    fu_adrc STRUCTURE adrc
                           CHANGING fc_name1
                                    fc_addr1
                                    fc_addr2
                                    fc_addr3
                                    fc_addr4.
  IF fu_adrc-name_co IS NOT INITIAL.
    WRITE fu_adrc-name_co TO fc_name1.
  ELSE.
    WRITE fu_adrc-name1 TO fc_name1.
  ENDIF.
  IF fu_adrc-str_suppl1 IS NOT INITIAL.
    WRITE fu_adrc-str_suppl1 TO fc_addr1.
  ELSE.
    WRITE fu_adrc-name2 TO fc_addr1.
  ENDIF.
  IF fu_adrc-str_suppl2 IS NOT INITIAL.
    WRITE fu_adrc-str_suppl2 TO fc_addr2.
  ELSE.
    WRITE fu_adrc-name3 TO fc_addr2.
  ENDIF.
  IF fu_adrc-str_suppl3 IS NOT INITIAL.
    WRITE fu_adrc-str_suppl3 TO fc_addr3.
  ELSE.
    WRITE fu_adrc-name4 TO fc_addr3.
  ENDIF.
  WRITE fu_adrc-location TO fc_addr4.
ENDFORM.                    " F_GET_CUSTOMER_ADDRS

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr fc_ppncd.

  DATA : lv_wrbtr   TYPE netwr_ak.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = fu_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr
      po_ppn   = fc_ppncd.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_CEK_ZTAX
*&---------------------------------------------------------------------*
FORM f_cek_ztax  USING    fu_vbeln
                 CHANGING fc_ppn.
  DATA: ls_ztax TYPE ztax.

  SELECT SINGLE * INTO ls_ztax
    FROM ztax WHERE doc_num  = fu_vbeln.

  IF sy-subrc = 0.
    fc_ppn = fc_ppn - ( ls_ztax-dis_val / 100 ).
  ENDIF.
ENDFORM.                    " F_CEK_ZTAX

*&---------------------------------------------------------------------*
*&      Form  F_GET_TERM_COD
*&---------------------------------------------------------------------*
FORM f_get_term_cod  USING    fu_zterm
                              fu_ztagg
                     CHANGING fc_ztag1.
  IF gt_xvbrk-zterm = 'ZCOD'.
    CLEAR gt_t052u.
    READ TABLE gt_t052u WITH KEY zterm = fu_zterm
                                 ztagg = fu_ztagg.
    fc_ztag1 = gt_t052u-text1.
  ENDIF.
ENDFORM.                    " F_GET_TERM_COD

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_HARGA
*&---------------------------------------------------------------------*
FORM f_recalc_harga  USING    fu_knumv
                              fu_posnr
                              fu_kschl
                     CHANGING fc_harga
                              fc_kzwi1.
  CLEAR: fc_harga,fc_kzwi1,gt_xkomv.
  READ TABLE gt_xkomv WITH KEY knumv = fu_knumv
                               kposn = fu_posnr
                               kschl = fu_kschl.
  IF sy-subrc = 0.
    IF gt_xkomv-kpein IS NOT INITIAL.
      fc_harga = gt_xkomv-kbetr / gt_xkomv-kpein * 100.
    ELSE.
      fc_harga = gt_xkomv-kbetr * 100.
    ENDIF.
    fc_kzwi1 = gt_xkomv-kwert.
  ENDIF.
ENDFORM.                    " F_RECALC_HARGA
