*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  DATA: l_budat      TYPE sy-datum,
        l_budat_low  TYPE sy-datum,
        l_budat_high TYPE sy-datum.

  CLEAR: r_bwart, r_bwart[], r_bwart_masuk, r_bwart_masuk[],
         r_bwart_guna, r_bwart_guna[],
         r_lgort, r_lgort[].

*  r_bwart_masuk-low     = '321'.
*  r_bwart_masuk-high    = '322'.
*  r_bwart_masuk-option  = 'BT'.
*  r_bwart_masuk-sign    = 'I'.
*  APPEND r_bwart_masuk.
  r_bwart_masuk-low     = '101'.
  r_bwart_masuk-high    = '102'.
  r_bwart_masuk-option  = 'BT'.
  r_bwart_masuk-sign    = 'I'.
  APPEND r_bwart_masuk.
  r_bwart_masuk-low     = '122'.
  r_bwart_masuk-high    = '123'.
  r_bwart_masuk-option  = 'BT'.
  r_bwart_masuk-sign    = 'I'.
  APPEND r_bwart_masuk.
  r_bwart_masuk-low     = '161'.
  r_bwart_masuk-high    = '162'.
  r_bwart_masuk-option  = 'BT'.
  r_bwart_masuk-sign    = 'I'.
  APPEND r_bwart_masuk.

  r_bwart_guna-low     = '201'.
  r_bwart_guna-high    = '202'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '261'.
  r_bwart_guna-high    = '262'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '555'.
  r_bwart_guna-high    = '556'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = 'Z51'.
  r_bwart_guna-high    = 'Z52'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '701'.
  r_bwart_guna-high    = '702'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '703'.
  r_bwart_guna-high    = '704'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '707'.
  r_bwart_guna-high    = '708'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.
  r_bwart_guna-low     = '543'.
  r_bwart_guna-high    = '544'.
  r_bwart_guna-option  = 'BT'.
  r_bwart_guna-sign    = 'I'.
  APPEND r_bwart_guna.

  r_bwart[] = r_bwart_masuk[].
  APPEND LINES OF r_bwart_guna TO r_bwart.
*  r_bwart-low     = '701'.
*  r_bwart-high    = '702'.
*  r_bwart-option  = 'BT'.
*  r_bwart-sign    = 'I'.
*  APPEND r_bwart.
*  r_bwart-low     = '703'.
*  r_bwart-high    = '704'.
*  r_bwart-option  = 'BT'.
*  r_bwart-sign    = 'I'.
*  APPEND r_bwart.
*  r_bwart-low     = '707'.
*  r_bwart-high    = '708'.
*  r_bwart-option  = 'BT'.
*  r_bwart-sign    = 'I'.
*  APPEND r_bwart.

***Used Storage location for pemasukan & produksi
  r_lgort-option = 'CP'.
  r_lgort-sign = 'I'.
  r_lgort-low = '1*'.
  APPEND r_lgort.
  r_lgort-option = 'CP'.
  r_lgort-sign = 'I'.
  r_lgort-low = '2*'.
  APPEND r_lgort.
  r_lgort-option = 'EQ'.
  r_lgort-sign = 'I'.
  r_lgort-low = space.
  APPEND r_lgort.
  r_lgort-option = 'EQ'.
  r_lgort-sign = 'E'.
  r_lgort-low = '1900'.
  APPEND r_lgort.
  r_lgort-option = 'EQ'.
  r_lgort-sign = 'E'.
  r_lgort-low = '2900'.
  APPEND r_lgort.

*-Added by Rahmadi: VA_NAME2 for plant name
*-Added by Budi: VA_ADRNR
  SELECT SINGLE name1 stras ort01 name2 adrnr
    FROM t001w
    INTO (va_name1, va_stras, va_ort01, va_name2, va_adrnr)
    WHERE werks EQ p_werks.

*-Added by Budi: VA_STREET for address name
  IF sy-subrc = 0.
    SELECT SINGLE street
      FROM adrc
      INTO va_street
      WHERE addrnumber EQ va_adrnr.
  ENDIF.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA: BEGIN OF lt_mara OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
          lgort LIKE mard-lgort,
          meins LIKE mara-meins,
        END OF lt_mara.

  DATA: BEGIN OF lt_makt OCCURS 0,
          matnr LIKE makt-matnr,
          maktx LIKE makt-maktx,
          mtart LIKE mara-mtart,
        END OF lt_makt.

  DATA: BEGIN OF lt_mardh OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
*          lgort LIKE mardh-lgort,
          lfgja LIKE mardh-lfgja,
          lfmon LIKE mardh-lfmon,
          labst LIKE mardh-labst,
        END OF lt_mardh.

  DATA: BEGIN OF lt_mardh_s OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
          lgort LIKE mardh-lgort,
          lfgja LIKE mardh-lfgja,
          lfmon LIKE mardh-lfmon,
          labst LIKE mardh-labst,
        END OF lt_mardh_s.

*---- Modify By Budi 15/09/2005
  DATA lt_mardh_t LIKE lt_mardh_s OCCURS 0 WITH HEADER LINE.
*---- End Of Modify By Budi 15/09/2005
  DATA lt_mardh_all LIKE lt_mardh_s OCCURS 0 WITH HEADER LINE.
  DATA lw_mardh_s LIKE lt_mardh_s.

  DATA: BEGIN OF lt_s933 OCCURS 0,
          matnr LIKE mara-matnr,
          werks LIKE marc-werks,
          bwart LIKE s933-bwart,
          charg LIKE s933-charg,
          lgort LIKE s933-lgort,
          basme LIKE s933-basme,
          menge LIKE s933-menge,
          aufnr LIKE s933-aufnr,
          mblnr LIKE s933-mblnr,
** Add by Budi 24/01/2006
          ebeln LIKE s933-ebeln,
          ebelp LIKE s933-ebelp,
** EndAdd by Budi 24/01/2006
        END OF lt_s933.

  DATA lt_masuk LIKE lt_s933 OCCURS 0 WITH HEADER LINE.
  DATA lt_masukfg LIKE lt_s933 OCCURS 0 WITH HEADER LINE.
  DATA lt_guna LIKE lt_s933 OCCURS 0 WITH HEADER LINE.
** Add by Budi 21/12/2005
*  DATA lt_701 LIKE lt_s933 OCCURS 0 WITH HEADER LINE.
** EndAdd by Budi 21/12/2005
  DATA lt_aufnr LIKE lt_guna OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_sum_masuk OCCURS 0,
          matnr LIKE mara-matnr,
          basme LIKE s933-basme,
          menge LIKE s933-menge,
        END OF lt_sum_masuk.
  DATA lt_sum_masukfg LIKE lt_sum_masuk OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_sum_guna OCCURS 0,
          matnr  LIKE mara-matnr,
          ktext  LIKE aufk-ktext,
          basme  LIKE s933-basme,
          menge  LIKE s933-menge,
*          gamng LIKE caufv-gamng,
*          gmein LIKE caufv-gmein,
          number LIKE t_data-number,
        END OF lt_sum_guna.

** Add by Budi 24/01/2006
  DATA lt_ebeln LIKE lt_guna OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_ekpo OCCURS 0,
          ebeln LIKE ekpo-ebeln,
          ebelp LIKE ekpo-ebelp,
          matnr LIKE ekpo-matnr,
          txz01 LIKE ekpo-txz01,
        END OF lt_ekpo.
** EndAdd by Budi 24/01/2006

  DATA: BEGIN OF lt_caufv OCCURS 0,
          aufnr  LIKE caufv-aufnr,
          auart  LIKE caufv-auart,
          plnbez LIKE caufv-plnbez,
          ktext  LIKE caufv-ktext,
*          gamng LIKE caufv-gamng,
*          gmein LIKE caufv-gmein,
        END OF lt_caufv.

  DATA: BEGIN OF lt_tot_guna OCCURS 0,
          matnr LIKE mara-matnr,
          menge LIKE s933-menge,
        END OF lt_tot_guna.

  DATA: ld_month LIKE mardh-lfmon,
        ld_year  LIKE mardh-lfgja.
  DATA: ld_month1 LIKE mardh-lfmon,
        ld_year1  LIKE mardh-lfgja.

*--- Modify By budi 09/12/2005
  DATA : BEGIN OF lt_s039 OCCURS 0,
           werks   LIKE s039-werks,
           matnr   LIKE s039-matnr,
           spmon   LIKE s039-spmon,
           mbwbest LIKE s039-mbwbest,
         END OF lt_s039.
  DATA : ld_date    LIKE sy-datum,
         ld_spmon   LIKE s039-spmon,
         lt_s039max LIKE lt_s039 OCCURS 0 WITH HEADER LINE,
         lt_s039sum LIKE lt_s039 OCCURS 0 WITH HEADER LINE.
*--- End Modify by budi 09/12/2005

  DATA: lt_stock  LIKE zms_opening_ending_stock OCCURS 0 WITH HEADER LINE.

  SELECT a~matnr a~meins
         b~werks b~lgort
    FROM mara AS a JOIN mard AS b ON a~matnr EQ b~matnr
    INTO CORRESPONDING FIELDS OF TABLE lt_mara
    WHERE a~matnr = p_matnr AND
*          a~profl = 'P' AND
          b~werks = p_werks AND
          b~lgort IN r_lgort.

  IF NOT lt_mara[] IS INITIAL.
*---Get beginning stock
    CALL FUNCTION 'ZFM_OPENING_ENDING_STOCK'
      EXPORTING
        matnr   = p_matnr
        werks   = p_werks
        spmon   = p_period
      TABLES
        t_stock = lt_stock.
    IF sy-subrc EQ 0.
      LOOP AT lt_stock.
        lt_s039sum-werks    = lt_stock-werks.
        lt_s039sum-matnr    = lt_stock-matnr.
        lt_s039sum-mbwbest  = lt_stock-stkopn.
        COLLECT lt_s039sum.
      ENDLOOP.
    ENDIF.

*---Get Pemasukan (BWART = 321,322) & Penggunaan (BWART = 261,262)
    SELECT werks matnr bwart charg lgort basme menge aufnr mblnr
           ebeln ebelp
           INTO CORRESPONDING FIELDS OF TABLE lt_s933
           FROM s933
           FOR ALL ENTRIES IN lt_mara
           WHERE spmon = p_period AND
                 werks = p_werks AND
                 matnr = lt_mara-matnr AND
                 bwart IN r_bwart AND
*                 lgort = p_lgort and
                 lgort IN r_lgort AND
                 vrsio = '000'.
    IF sy-subrc = 0.
*-----Separate Pemasukan & Penggunaan
      lt_masuk[] = lt_s933[].
      lt_guna[] = lt_s933[].

*-----Pemasukan
      DELETE lt_masuk WHERE NOT bwart IN r_bwart_masuk.
      SORT lt_masuk BY matnr.

*-----Collect Pemasukan
      LOOP AT lt_masuk.
        MOVE-CORRESPONDING lt_masuk TO lt_sum_masuk.
        COLLECT lt_sum_masuk.
      ENDLOOP.

*-----Penggunaan
      DELETE lt_guna WHERE NOT bwart IN r_bwart_guna.
      SORT lt_guna BY matnr.

      lt_aufnr[] = lt_guna[].
      SORT lt_aufnr BY aufnr.
      DELETE ADJACENT DUPLICATES FROM lt_aufnr.
      SELECT aufnr auart plnbez ktext gamng gmein
             INTO CORRESPONDING FIELDS OF TABLE lt_caufv
             FROM caufv
             FOR ALL ENTRIES IN lt_aufnr
             WHERE aufnr = lt_aufnr-aufnr.
      SORT lt_caufv BY aufnr.

      "Get material Finish Good (FG)
      IF lt_caufv[] IS NOT INITIAL.
        SELECT a~matnr a~maktx b~mtart
          INTO CORRESPONDING FIELDS OF TABLE lt_makt
          FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN lt_caufv
          WHERE a~matnr EQ lt_caufv-plnbez
            AND a~spras EQ sy-langu
            AND b~mtart IN ('ZPHA','ZCGB','ZSFG').
      ENDIF.

** Add by Budi 24/01/2006
      lt_ebeln[] = lt_guna[].
      SORT lt_ebeln BY ebeln ebelp.
      DELETE ADJACENT DUPLICATES FROM lt_ebeln COMPARING ebeln ebelp.
      IF NOT lt_ebeln[] IS INITIAL.
        SELECT ebeln ebelp matnr txz01
               INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
               FROM ekpo
               FOR ALL ENTRIES IN lt_ebeln
               WHERE ebeln = lt_ebeln-ebeln  AND
                     ebelp = lt_ebeln-ebelp.
      ENDIF.
      SORT lt_ekpo BY ebeln ebelp.
** EndAdd by Budi 24/01/2006

*-----Collect Penggunaan
      LOOP AT lt_guna.
        MOVE-CORRESPONDING lt_guna TO lt_sum_guna.
        CLEAR: lt_sum_guna-ktext, lt_sum_guna-matnr.
        lt_sum_guna-number = '00001'.

** Add by Budi 24/01/2006
        IF lt_guna-bwart = '543' OR
           lt_guna-bwart = '544'.
          READ TABLE lt_ekpo WITH KEY ebeln = lt_guna-ebeln
                                      ebelp = lt_guna-ebelp
               BINARY SEARCH.
          IF sy-subrc = 0.
            lt_sum_guna-matnr = lt_ekpo-matnr.
            lt_sum_guna-ktext = lt_ekpo-txz01.
          ENDIF.
        ELSE.
** EndAdd by Budi 24/01/2006

* Ubah logic req by MRA/Prihandoko 01.11.2017
* Jika MvTyp 'Z51' atau kepala 7
* Masuk Pemakaian Lab QC

*          READ TABLE lt_caufv WITH KEY aufnr = lt_guna-aufnr
*               BINARY SEARCH.
*          IF sy-subrc = 0 AND
**             lt_caufv-auart NE 'ZI07' AND
*             lt_caufv-auart NE 'ZT99' AND
*** Add by Budi 21/12/2005
*             lt_guna-bwart NE '701' AND
*             lt_guna-bwart NE '702' AND
*             lt_guna-bwart NE '703' AND
*             lt_guna-bwart NE '704' AND
*             lt_guna-bwart NE '707' AND
*             lt_guna-bwart NE '708'.
*** EndAdd by Budi 21/12/2005
*            lt_sum_guna-matnr = lt_caufv-plnbez.
*            lt_sum_guna-ktext = lt_caufv-ktext.
**          lt_sum_guna-gamng = lt_caufv-gamng.
**          lt_sum_guna-gmein = lt_caufv-gmein.
*
*            "Check Material Finish Good (FG)
*            READ TABLE lt_makt WITH KEY matnr = lt_sum_guna-matnr.
*            IF sy-subrc NE 0.
*              PERFORM f_get_material_fg CHANGING lt_sum_guna-matnr
*                                                 lt_sum_guna-ktext.
*            ENDIF.
*          ELSE.
*            CLEAR: lt_sum_guna-matnr.
**                 lt_sum_guna-gamng,
**                 lt_sum_guna-gmein.
*            lt_sum_guna-ktext = 'Pemakaian Lab QC'.
*            lt_sum_guna-number = '99999'.
*          ENDIF.
          IF lt_guna-bwart = 'Z51' OR
             lt_guna-bwart = '701' OR
             lt_guna-bwart = '702' OR
             lt_guna-bwart = '703' OR
             lt_guna-bwart = '704' OR
             lt_guna-bwart = '707' OR
             lt_guna-bwart = '708'.
            CLEAR: lt_sum_guna-matnr.
            lt_sum_guna-ktext = 'Pemakaian Lab QC'.
            lt_sum_guna-number = '99999'.

          ELSE.
            READ TABLE lt_caufv WITH KEY aufnr = lt_guna-aufnr
                 BINARY SEARCH.
            IF sy-subrc = 0.
              lt_sum_guna-matnr = lt_caufv-plnbez.
*              lt_sum_guna-ktext = lt_caufv-ktext.

              CLEAR lt_makt.
              READ TABLE lt_makt WITH KEY matnr = lt_sum_guna-matnr.
              lt_sum_guna-ktext = lt_makt-maktx.

              "Check Material Finish Good (FG)
              READ TABLE lt_makt WITH KEY matnr = lt_sum_guna-matnr.
              IF sy-subrc NE 0.
                PERFORM f_get_material_fg CHANGING lt_sum_guna-matnr
                                                   lt_sum_guna-ktext.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

** Add by Budi 21/12/2005
        IF lt_guna-bwart = '701' OR
           lt_guna-bwart = '702' OR
           lt_guna-bwart = '703' OR
           lt_guna-bwart = '704' OR
           lt_guna-bwart = '707' OR
           lt_guna-bwart = '708'.
          MULTIPLY lt_guna-menge BY -1.
        ENDIF.
** EndAdd by Budi 21/12/2005
        COLLECT lt_sum_guna.
      ENDLOOP.

*-----Get Produksi FG
*-----Get Pemasukan for FG (BWART = 321,322)
      SELECT werks matnr bwart charg lgort basme menge aufnr
             mblnr ebeln ebelp
             INTO CORRESPONDING FIELDS OF TABLE lt_masukfg
             FROM s933
             FOR ALL ENTRIES IN lt_sum_guna
             WHERE spmon = p_period          AND
                   werks = p_werks           AND
                   matnr = lt_sum_guna-matnr AND
                   matnr NE space            AND
                   bwart IN r_bwart_masuk    AND
*                   lgort = '2000' AND
*                   lgort IN r_lgort AND
                   vrsio = '000'.
*-----Collect Pemasukan for FG
      LOOP AT lt_masukfg.
        MOVE-CORRESPONDING lt_masukfg TO lt_sum_masukfg.
        COLLECT lt_sum_masukfg.
      ENDLOOP.
      SORT lt_sum_masukfg BY matnr.

      BREAK bcrmd.

*---- Modify By Budi 15/09/2005
*---- Append Stock Awal
*---- Modify By Budi 09/12/2005
      IF lt_sum_masuk[] IS INITIAL.
        CLEAR lt_s039sum.
        READ TABLE lt_s039sum INDEX 1.
        t_header-number = '00000'.
        t_data-number = '00000'.
        t_header-sawal = lt_s039sum-mbwbest.
        t_data-sawal = lt_s039sum-mbwbest.
        t_header-sjumlah = t_header-sawal.
        t_data-sjumlah = t_data-sawal.
        APPEND t_header.
        APPEND t_data.
      ENDIF.
*      IF lt_sum_masuk[] IS INITIAL.
*        CLEAR lt_mardh.
*        READ TABLE lt_mardh INDEX 1.
*        t_header-number = '00000'.
*        t_data-number = '00000'.
*        t_header-sawal = lt_mardh-labst.
*        t_data-sawal = lt_mardh-labst.
*        t_header-sjumlah = t_header-sawal.
*        t_data-sjumlah = t_data-sawal.
*        APPEND t_header.
*        APPEND t_data.
*      ENDIF.
*---- End Of Modify By Budi 09/12/2005
*---- End Of Modify By Budi 15/09/2005

*-----Append Pemasukan
      LOOP AT lt_sum_masuk.
        MOVE-CORRESPONDING lt_sum_masuk TO t_header.
        MOVE-CORRESPONDING lt_sum_masuk TO t_data.
        t_header-number = '00000'.
        t_data-number = '00000'.
        CLEAR t_header-sawal.
*---- Modify By Budi 09/12/2005
        READ TABLE lt_s039sum WITH KEY matnr = lt_sum_masuk-matnr
             BINARY SEARCH.
        IF sy-subrc = 0.
          t_header-sawal = lt_s039sum-mbwbest.
          t_data-sawal = lt_s039sum-mbwbest.
        ENDIF.
*        READ TABLE lt_mardh WITH KEY matnr = lt_sum_masuk-matnr
*             BINARY SEARCH.
*        IF sy-subrc = 0.
*          t_header-sawal = lt_mardh-labst.
*          t_data-sawal = lt_mardh-labst.
*        ENDIF.
*---- End Of Modify By Budi 09/12/2005
        t_header-smasuk = lt_sum_masuk-menge.
        t_data-smasuk = lt_sum_masuk-menge.
        t_header-sjumlah = t_header-sawal + t_header-smasuk.
        t_data-sjumlah = t_data-sawal + t_data-smasuk.
        APPEND t_header.
        APPEND t_data.
      ENDLOOP.

*-----Append Penggunaan
      CLEAR t_data.
      LOOP AT lt_sum_guna.
        MOVE-CORRESPONDING lt_sum_guna TO t_data.
*        t_data-number = t_data-number + 1.
        t_data-sguna = lt_sum_guna-menge.
        CLEAR: t_data-sprod, t_data-basme1.
*        IF NOT lt_sum_guna-matnr IS INITIAL.
        READ TABLE lt_sum_masukfg WITH KEY matnr = lt_sum_guna-matnr
             BINARY SEARCH.
        IF sy-subrc = 0.
          t_data-sprod = lt_sum_masukfg-menge.
          t_data-basme1 = lt_sum_masukfg-basme.
        ENDIF.
*        ENDIF.
*        t_data-sprod = .
        APPEND t_data.

*-------Get all used etil alcohol
        lt_tot_guna-matnr = p_matnr.
        lt_tot_guna-menge = lt_sum_guna-menge.
        COLLECT lt_tot_guna.
      ENDLOOP.

*-----Formatting Layout
*---- Modify By Budi 15/09/2005
      CLEAR t_data.
      CLEAR lt_tot_guna.
*---- End Of Modify By Budi 15/09/2005
      SORT t_data BY number.
      READ TABLE t_data INDEX 1.
      READ TABLE lt_tot_guna INDEX 1.
*-----By Budi 31/08/2005
      IF t_data-number NE '00000'.
        CLEAR t_data.
      ENDIF.
*      t_data-sakhir = t_data-sjumlah - lt_tot_guna-menge.
      t_data-sakhir = t_data-sjumlah + lt_tot_guna-menge.
*      MODIFY t_data INDEX 1 TRANSPORTING sakhir.
      MODIFY t_data TRANSPORTING sakhir WHERE number = '00000'.
      IF sy-subrc NE 0.
        t_data-number = '00000'.
        APPEND t_data.
      ENDIF.
*-----End

**-----Header for Hierarchical ALV
*      t_header[] = t_data[].
*      DELETE ADJACENT DUPLICATES FROM t_header COMPARING matnr.
      SORT t_data BY number.

*-----Renumber T_DATA
      DATA ld_count LIKE t_data-number.
      LOOP AT t_data.
        IF t_data-number <> '99999' AND
           t_data-number <> '00000'.
          ld_count = ld_count + 1.
          t_data-number = ld_count.
          MODIFY t_data TRANSPORTING number.
*-----By Budi 31/08/2005
          CONTINUE.
*-----End
        ENDIF.
        AT LAST.
          t_data-number = ld_count + 1.
          MODIFY t_data TRANSPORTING number.
*-----By Budi 31/08/2005
          CONTINUE.
*-----End
        ENDAT.
      ENDLOOP.

      BREAK bcrmd.
*-----By Budi 31/08/2005
    ELSE.
*---- Modify By Budi 09/12/2005
*---- Modify By Budi 09/12/2005
      IF NOT lt_s039sum[] IS INITIAL.
        CLEAR lt_s039sum.
        READ TABLE lt_s039sum INDEX 1.
        t_header-number = '00000'.
        t_data-number = '00000'.
        t_header-sawal = lt_s039sum-mbwbest.
        t_data-sawal = lt_s039sum-mbwbest.
        t_header-sjumlah = t_header-sawal.
        t_data-sjumlah = t_data-sawal.
        t_header-sakhir = t_header-sawal.
        t_data-sakhir = t_data-sawal.
        APPEND t_header.
        APPEND t_data.
*      IF NOT lt_mardh[] IS INITIAL.
*        CLEAR lt_mardh.
*        READ TABLE lt_mardh INDEX 1.
*        t_header-number = '00000'.
*        t_data-number = '00000'.
*        t_header-sawal = lt_mardh-labst.
*        t_data-sawal = lt_mardh-labst.
*        t_header-sjumlah = t_header-sawal.
*        t_data-sjumlah = t_data-sawal.
*        t_header-sakhir = t_header-sawal.
*        t_data-sakhir = t_data-sawal.
*        APPEND t_header.
*        APPEND t_data.
*---- End Of Modify By Budi 09/12/2005
      ENDIF.
*-----End

    ENDIF.
  ELSE.
    MESSAGE i000(zab) WITH 'Material does not exist'.
  ENDIF.

ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF t_data[] IS INITIAL.
    MESSAGE i000(zab) WITH 'Data not found'.
  ELSE.
    PERFORM f_alv TABLES t_data.
*    PERFORM f_alv_hier TABLES t_header t_data.
  ENDIF.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv_hier                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv_hier TABLES ft_header ft_detail.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_auto  USING ft_header ft_detail.
  PERFORM f_build_keyinfo    USING   d_alv_keyinfo.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
**  perform f_alv_variant_exist using   p_vari
**                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
      i_default                = 'X'
      i_save                   = 'A'
*     IS_VARIANT               =
      it_events                = t_alv_event[]
*     IT_EVENT_EXIT            =
      i_tabname_header         = 'T_HEADER'
      i_tabname_item           = 'T_DATA'
*     I_STRUCTURE_NAME_HEADER  =
*     I_STRUCTURE_NAME_ITEM    =
      is_keyinfo               = d_alv_keyinfo
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_BUFFER_ACTIVE          =
*     I_BYPASSING_BUFFER       =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab_header          = ft_header
      t_outtab_item            = ft_detail
*   EXCEPTIONS
*     PROGRAM_ERROR            = 1
*     OTHERS                   = 2
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "f_alv_hier

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_auto USING ft_header ft_detail.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'T_HEADER':
    'NUMBER' 'VBRP' 'POSNR' '' '' 'Number' '' '' '' '' '' '' '' '' ''
    '',
*    'MATNR' 'MARA' 'MATNR' '' '' 'Material' '' '' '' '' '' '' '' '' '',
    'BASME' 'S933' 'BASME' '' '' 'Satuan' '' '' '' '' '' '' '' '' ''
    'X',
    'SAWAL' 'S933' 'MENGE' '' '' 'Saldo Awal' '' '' '' '' '' ''
    'BASME' '' 'X' 'X',
    'SMASUK' 'S933' 'MENGE' '' '' 'Pemasukan' '' '' '' '' '' ''
    'BASME' '' 'X' 'X',
    'SJUMLAH' 'S933' 'MENGE' '' '' 'Jumlah' '' '' '' '' '' ''
    'BASME' '' 'X' 'X'.

  PERFORM f_fieldcatg USING 'T_DATA':
    'NUMBER' 'VBRP' 'POSNR' '' '' 'Number' '' '' '' '' '' '' '' '' ''
    '',
*    'MATNR' 'MARA' 'MATNR' '' '' 'Material' '' '' '' '' '' '' '' '' '',
    'KTEXT' 'AUFK' 'KTEXT' '' '' 'Barang Produksi' '' '' '' '' '' '' ''
'' '' '',
    'BASME' 'S933' 'BASME' '' '' 'Satuan' '' '' '' '' '' '' '' '' '' '',
    'SGUNA' 'S933' 'MENGE' '' '' 'Yg Digunakan' '' '' '' '' '' ''
'BASME' '' '' 'X',
    'SAKHIR' 'S933' 'MENGE' '' '' 'Saldo Akhir' '' '' '' '' '' ''
'BASME' '' '' 'X',
    'SPROD' 'S933' 'MENGE' '' '' 'Barang FG Produksi' '' '' '' '' '' ''
'BASME1' '' '' 'X',
    'BASME1' 'S933' 'BASME' '' '' 'Satuan FG' '' '' '' '' '' '' ''
    '' '' '',
    'KETR' '' '' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' ''.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_DATA'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.


ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.

*  fu_keyinfo-header01 = 'ICON_NAME'.
*  fu_keyinfo-item01   = space.

*
  fu_keyinfo-header01 = 'NUMBER'.
  fu_keyinfo-item01   = 'NUMBER'.
*  fu_keyinfo-header02 = 'MATNR'.
*  fu_keyinfo-item02  = 'MATNR'.

ENDFORM.                    " f_build_keyinfo

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_nozero)
                          VALUE(fu_nosign).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-no_zero       = fu_nozero.
  ld_fieldcat-no_sign       = fu_nosign.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    "f_build_event_exit


*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-totals_text        = ' Total'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
*  ld_sort-fieldname = 'SMASUK'.
  ld_sort-fieldname = 'NUMBER'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.

* here free all the internal table used in the program.
  REFRESH: t_data.

  CLEAR: t_data.

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.

  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " f_clear_alv_data



*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.

ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.

ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: lv_datub   LIKE  rc29l-datub,
        lv_datuv   LIKE  rc29l-datuv,
        lv_matnr   LIKE  rc29l-matnr,
        lv_werks   LIKE  rc29l-werks,
        lv_sguna   LIKE  ekpo-menge,
        lv_menge   LIKE  ekpo-menge,
        lt_wultb   TYPE TABLE OF stpov,
        lt_equicat TYPE TABLE OF cscequi,
        lt_kndcat  TYPE TABLE OF cscknd,
        lt_matcat  TYPE TABLE OF cscmat,
        lt_stdcat  TYPE TABLE OF cscstd,
        lt_tplcat  TYPE TABLE OF csctpl,
        lt_rmmme   TYPE TABLE OF rmmme.

  SELECT msehi INTO TABLE @DATA(lt_t006)
    FROM t006 WHERE dimid = 'AAAADL'.

  lv_matnr  = p_matnr.
  lv_werks  = p_werks.
  CONCATENATE p_period '01' INTO lv_datuv.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datuv
    IMPORTING
      last_day_of_month = lv_datuv.

  CALL FUNCTION 'CS_WHERE_USED_MAT'
    EXPORTING
      datub   = lv_datub
      datuv   = lv_datuv
      matnr   = lv_matnr
      werks   = lv_werks
    TABLES
      wultb   = lt_wultb
      equicat = lt_equicat
      kndcat  = lt_kndcat
      matcat  = lt_matcat
      stdcat  = lt_stdcat
      tplcat  = lt_tplcat.

  IF sy-subrc = 0.
    LOOP AT t_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      IF <fs_data>-sguna IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR: lv_sguna,lv_menge.
      lv_sguna = abs( <fs_data>-sguna ).
      READ TABLE lt_wultb INTO DATA(lw_wultb)
                          WITH KEY matnr = <fs_data>-matnr
                                   loekz = ' '.
      IF sy-subrc = 0.

        "Hitung hasil produksi berdasarkan penggunaan dan BOM
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr              = p_matnr
            i_in_me              = <fs_data>-basme
            i_out_me             = lw_wultb-meins
            i_menge              = lv_sguna
          IMPORTING
            e_menge              = lv_menge
          EXCEPTIONS
            error_in_application = 1
            error                = 2
            OTHERS               = 3.
        IF sy-subrc = 0.
          <fs_data>-sprod = lv_menge * lw_wultb-bmeng / lw_wultb-menge.
          <fs_data>-basme1 = lw_wultb-bmein.
        ELSE.
          CLEAR <fs_data>-sprod.
        ENDIF.

        "Konversi hasil produksi ke satuan terkecil
        IF <fs_data>-sprod IS NOT INITIAL.
          CLEAR lt_rmmme.
          CALL FUNCTION 'MATERIAL_UNIT_FIND'
            EXPORTING
              matnr              = <fs_data>-matnr
            TABLES
              rmmme_itab         = lt_rmmme
            EXCEPTIONS
              material_not_found = 1
              OTHERS             = 2.
          IF sy-subrc = 0.
            SORT lt_rmmme BY umren DESCENDING.
            LOOP AT lt_rmmme INTO DATA(lw_rmmme).
              READ TABLE lt_t006 WITH KEY msehi = lw_rmmme-meinh
                                 TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                IF lw_rmmme-umren = 1.
                  <fs_data>-sprod2 = <fs_data>-sprod.
                  <fs_data>-basme2 = <fs_data>-basme1.
                ELSE.
                  CLEAR: lv_sguna,lv_menge.
                  lv_sguna = <fs_data>-sprod.
                  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                    EXPORTING
                      i_matnr              = <fs_data>-matnr
                      i_in_me              = <fs_data>-basme1
                      i_out_me             = lw_rmmme-meinh
                      i_menge              = lv_sguna
                    IMPORTING
                      e_menge              = lv_menge
                    EXCEPTIONS
                      error_in_application = 1
                      error                = 2
                      OTHERS               = 3.
                  IF sy-subrc = 0.
                    <fs_data>-sprod2 = lv_menge.
                    <fs_data>-basme2 = lw_rmmme-meinh.
                    EXIT.
                  ENDIF.
                ENDIF.
              ELSE.
                <fs_data>-sprod2 = <fs_data>-sprod.
                <fs_data>-basme2 = <fs_data>-basme1.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_validate_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.

ENDFORM.                    "f_user_command
*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

  READ TABLE t_user INDEX 1.
  CASE t_user-datfm.
    WHEN 'DD.MM.YYYY'.
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_FG
*&---------------------------------------------------------------------*
FORM f_get_material_fg  CHANGING fc_matnr
                                 fc_ktext.
  DATA: lv_matnr TYPE matnr,
        lv_maktx TYPE maktx,
        lv_mtart TYPE mtart,
        lv_fg    TYPE char1.

  CLEAR: lv_matnr,lv_maktx,lv_mtart,lv_fg.

  WHILE lv_fg IS INITIAL.
    SELECT SINGLE b~matnr INTO lv_matnr
      FROM stpo AS a JOIN mast AS b ON a~stlnr = b~stlnr
      WHERE a~idnrk = fc_matnr
        AND b~werks = p_werks.

    SELECT SINGLE a~maktx b~mtart INTO (lv_maktx, lv_mtart)
      FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
      WHERE a~matnr EQ lv_matnr
        AND a~spras EQ sy-langu
        AND b~mtart IN ('ZPHA','ZCGB','ZSFG').

    IF sy-subrc = 0.
      fc_matnr = lv_matnr.
      fc_ktext = lv_maktx.
      lv_fg    = 'X'.
    ELSEIF sy-index GE 10.
      lv_fg    = 'X'.
    ELSE.
      fc_matnr = lv_matnr.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " F_GET_MATERIAL_FG
