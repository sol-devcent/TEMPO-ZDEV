*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPF01                                   *
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

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  SELECT SINGLE datab
    FROM zproject
    INTO va_datab
    WHERE name EQ 'ZGDTAX'.

  IF sy-datum GE va_datab.
    PERFORM f_write_selection.
    SUBMIT zgdfaktur_komersil001 WITH SELECTION-TABLE t_rsparams AND RETURN.
  ENDIF.

  PERFORM f_init_data.
  IF NOT t_zgdsdkomer[] IS INITIAL.
    PERFORM f_get_data.
    PERFORM f_validate_data.
    PERFORM f_process_data.
    PERFORM f_print_form.
  ENDIF.
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
  SELECT *
    FROM zgdsdkomer
    INTO CORRESPONDING FIELDS OF TABLE t_zgdsdkomer
    WHERE vbeln EQ pa_vbeln.

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
  DATA: ld_invo1 LIKE zgdsdkomer-invo1,
        ld_invo2 LIKE zgdsdkomer-invo2,
        ld_gjahr LIKE zgdsdkomer-gjahr.

  DATA: name  TYPE tdobname,
        value TYPE field_value,
        lines LIKE tline OCCURS 0 WITH HEADER LINE.

* Get header data
  IF t_header[] IS INITIAL.
*{   REPLACE        P01K910471                                        1
*\    SELECT *
*\      FROM vbrk
*\      INTO CORRESPONDING FIELDS OF TABLE t_header
*\      WHERE vbeln EQ pa_vbeln.
    "Start SOH: Shell SCI Adjustment 20240223 RZL
    SELECT *
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE t_header
      WHERE vbeln EQ pa_vbeln ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240223 RZL
*}   REPLACE
  ENDIF.

  READ TABLE t_header INDEX 1.
  IF sy-subrc EQ 0.

    name  = pa_vbeln.
    BREAK bcdik.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'ZH05'
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
    IF sy-subrc = 0.
      READ TABLE lines INDEX 1.
      IF sy-subrc = 0.
        value = lines-tdline.
      ENDIF.
      SELECT SINGLE field_value1
        FROM zgdfakturkom
        INTO va_desc
        WHERE vkorg = t_header-vkorg
          AND field_value = value.
    ENDIF.

    IF t_header-vkorg EQ '8090' OR t_header-vkorg EQ '8230'.
      IF va_desc IS INITIAL.
        p_tdform = 'ZGDFAKTUR_KOMERSIL_SFF'.
      ELSE.
        p_tdform = 'ZGDFAKTUR_KOMERSIL_SFF2'.
      ENDIF.
    ENDIF.
    IF t_header-vkorg EQ '8030'.
      SELECT SINGLE zterm
        FROM bseg
        INTO t_header-zterm
        WHERE bukrs = t_header-vkorg AND
              belnr = pa_vbeln       AND
*              gjahr = t_header-gjahr AND
              bschl = '01'.
      MODIFY t_header INDEX 1 TRANSPORTING zterm.
    ENDIF.
  ENDIF.


  SELECT SINGLE invo1 invo2 gjahr
    FROM zgdsdkomer
    INTO (ld_invo1, ld_invo2, ld_gjahr)
    WHERE vbeln EQ pa_vbeln.

  CONCATENATE ld_invo1 '-' ld_invo2 '/' ld_gjahr
    INTO va_nofktr.

* Get detail data
  SELECT *
    FROM vbrp
    INTO CORRESPONDING FIELDS OF TABLE t_vbrp
    WHERE vbeln EQ pa_vbeln AND
          fkimg NE 0.

* Get no seri faktur pajak
  SELECT SINGLE fakturno
    FROM zgdtxdt0003
    INTO va_fakturno
    WHERE vbeln EQ pa_vbeln.
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
  TYPES : BEGIN OF ty_xkna1,
            kunnr TYPE kna1-kunnr,
            adrnr TYPE vbpa-adrnr,
          END OF ty_xkna1.

  DATA: ld_lin1(100),
        ld_lin2(100),
        ld_ztag1     LIKE t052-ztag1,
        ld_vbelv     LIKE vbfa-vbelv,
        ld_bstdk     LIKE vbak-bstdk,
        ld_audat     LIKE vbak-audat,
        ld_parvw     LIKE vbpa-parvw,
        ld_linenum   LIKE zgdtxst0010x-linenum,
        ld_posnr     LIKE vbrp-posnr,
        ld_kwert     LIKE konv-kwert,
        ld_kwert1    LIKE konv-kwert,
        ld_kwert2    LIKE konv-kwert,
        ld_pph22     LIKE konv-kwert,
        ld_pph22p    LIKE konv-kbetr,
        ld_dpp       LIKE rf05a-aktiv,
        ld_langu     LIKE sy-langu,
        ld_spell     LIKE spell,
        ld_kbetr     LIKE konv-kbetr,
        ld_pay       LIKE rf05a-aktiv,
        ld_prcpiece  LIKE konv-kwert,
        ld_kurrf(20),
        ld_harga_rp  LIKE vbrk-netwr,
        ld_netwr_rp  LIKE vbrk-netwr,
        ld_kwert_rp  LIKE vbrk-netwr,
        ld_dpp_rp    LIKE vbrk-netwr,
        ld_kwert1_rp LIKE vbrk-netwr,
        ld_kwert2_rp LIKE vbrk-netwr,
        ld_pph22_rp  LIKE vbrk-netwr,
        ld_netwr     LIKE rf05a-aktiv,
        ld_netwr1    TYPE p DECIMALS 2,
        ld_werks     LIKE vbrp-werks.

  DATA: BEGIN OF lt_vbpa OCCURS 0.
          INCLUDE STRUCTURE vbpa.
        DATA: END OF lt_vbpa.
  DATA: BEGIN OF lt_konv OCCURS 0.
          INCLUDE STRUCTURE konv.
        DATA: END OF lt_konv.

  DATA: BEGIN OF lt_kna1 OCCURS 0,
          kunnr LIKE kna1-kunnr,
          adrnr LIKE kna1-adrnr,
          stceg LIKE kna1-stceg,
        END OF lt_kna1.
  DATA lt_adrc LIKE adrc OCCURS 0 WITH HEADER LINE.
  DATA : lt_vbrp TYPE STANDARD TABLE OF vbrp,
         ls_vbrp LIKE LINE OF lt_vbrp.

  DATA : lv_xblnr     TYPE vbrk-xblnr,
         lv_dono(100),
         lv_count     TYPE i.

  DATA : lt_xkna1 TYPE STANDARD TABLE OF ty_xkna1,
         ls_xkna1 LIKE LINE OF lt_xkna1,
         ls_vbpa  LIKE LINE OF lt_vbpa.

  RANGES: lr_parvw FOR vbpa-parvw.

  IF NOT t_header[] IS INITIAL.
    READ TABLE t_header INDEX 1.
    IF sy-subrc EQ 0.
      IF t_header-vkorg = '8010'.
        READ TABLE t_vbrp INDEX 1.
        IF sy-subrc EQ 0.
          ld_werks = t_vbrp-werks.
        ENDIF.
      ENDIF.

      SELECT SINGLE petugas jabat pkpcity
        FROM zgdtxdt0005
        INTO (va_petugas, va_jabat, va_city)
        WHERE bukrs EQ t_header-vkorg.

      IF t_header-vkorg EQ '8010'.
        t_company-name  = 'PT. TEMPO SCAN PACIFIC. Tbk'.

        CLEAR: ld_lin1, ld_lin2.
        ld_lin1 = 'Gedung Bina Mulia Jl. HR. Rasuna Said Kav. 11'.
        ld_lin2 = 'Jakarta 12950 Indonesia'.
        CONCATENATE ld_lin1 ld_lin2 INTO t_company-line1
          SEPARATED BY space.
        CLEAR: ld_lin1, ld_lin2.

        CLEAR: ld_lin1, ld_lin2.
        ld_lin1 = 'Phone: 021-5201858 Fax: 021-5201857'.
        ld_lin2 =' PO Box: 3269 10002'.
        CONCATENATE ld_lin1 ld_lin2 INTO t_company-line2
          SEPARATED BY space.
        CLEAR: ld_lin1, ld_lin2.

        CLEAR: ld_lin1, ld_lin2.
        ld_lin1 = 'N.P.W.P.: 01.000.3.092.000'.
        ld_lin2 = 'Tanggal PKP: 21-06-1989'.
        CONCATENATE ld_lin1 ld_lin2 INTO t_company-line3
          SEPARATED BY space.
        CLEAR: ld_lin1, ld_lin2.

        IF ld_werks EQ '0101'.
          CLEAR: ld_lin1, ld_lin2.
          ld_lin1 = 'Factory : - EJIP Industrial Park Plot I H'.
          ld_lin2 = 'Lemahabang, Bekasi 17550'.
          CONCATENATE ld_lin1 ld_lin2 INTO t_company-line4
            SEPARATED BY space.
          CLEAR: ld_lin1, ld_lin2.

          CLEAR: ld_lin1, ld_lin2.
          ld_lin1 = '               Phone. 8970801 - 02, 8970452 - 53,'.
          ld_lin2 = '8970939 - 40'.
          CONCATENATE ld_lin1 ld_lin2 INTO t_company-line5
            SEPARATED BY space.
          CLEAR: ld_lin1, ld_lin2.
          t_company-line6 = '                Fax. 8970767, 8970764'.
        ELSEIF ld_werks EQ '0102'.
          CLEAR: ld_lin1, ld_lin2.
          ld_lin1 = 'Factory : - EJIP Industrial Park Plot I G'.
          ld_lin2 = 'Lemahabang, Bekasi 17550'.
          CONCATENATE ld_lin1 ld_lin2 INTO t_company-line4
            SEPARATED BY space.
          CLEAR: ld_lin1, ld_lin2.

          CLEAR: ld_lin1, ld_lin2.
          ld_lin1 = '               Phone. 8971553, 8975173,'.
          ld_lin2 = 'Fax. 8971563'.
          CONCATENATE ld_lin1 ld_lin2 INTO t_company-line5
            SEPARATED BY space.
          CLEAR: ld_lin1, ld_lin2.
        ENDIF.

      ELSEIF t_header-vkorg EQ '8090'.
        t_company-name  = 'PT. SUPRA FERBINDO FARMA'.
        t_company-line1 = 'Komplek EJIP Plot 8 J No. 1-4 Serang'.

        CLEAR: ld_lin1, ld_lin2.
        ld_lin1 = 'Cikarang Selatan - Bekasi - Jawa Barat'.
        ld_lin2 = '17550'.
        CONCATENATE ld_lin1 ld_lin2 INTO t_company-line2
          SEPARATED BY space.
        CLEAR: ld_lin1, ld_lin2.

        t_company-line3 = 'Phone: 021-8970277 Fax: 021-8970195'.

        CLEAR: ld_lin1, ld_lin2.
        ld_lin1 = 'N.P.W.P.: 01.398.193.1-431.000'.
        ld_lin2 = 'Tgl. PKP: 01-07-2006'.
        CONCATENATE ld_lin1 ld_lin2 INTO t_company-line4
          SEPARATED BY space.
        CLEAR: ld_lin1, ld_lin2.
      ENDIF.

      ld_parvw = 'SH'.
      DO 2 TIMES.
        CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
          EXPORTING
            input  = ld_parvw
          IMPORTING
            output = ld_parvw.

        lr_parvw-low = ld_parvw.
        lr_parvw-sign = 'I'.
        lr_parvw-option = 'EQ'.
        APPEND lr_parvw.
        ld_parvw = 'SP'.
      ENDDO.

      SELECT SINGLE vbelv
        FROM vbfa
        INTO ld_vbelv
        WHERE vbeln EQ t_header-xblnr.

      IF sy-subrc EQ 0.
        SELECT SINGLE bstdk audat
          FROM vbak
          INTO (ld_bstdk, ld_audat)
          WHERE vbeln EQ ld_vbelv.

        SELECT *
          FROM vbpa
          INTO CORRESPONDING FIELDS OF TABLE lt_vbpa
          WHERE vbeln EQ ld_vbelv AND
                parvw IN lr_parvw.
      ELSE.
        SELECT SINGLE bstdk audat
          FROM vbak
          INTO (ld_bstdk, ld_audat)
          WHERE vbeln EQ t_header-xblnr.

        SELECT *
          FROM vbpa
          INTO CORRESPONDING FIELDS OF TABLE lt_vbpa
          WHERE vbeln EQ t_header-vbeln AND
                parvw IN lr_parvw.
      ENDIF.

* Nomor PO & Tanggal PO
      IF t_header-fktyp EQ 'L' OR
        t_header-fktyp EQ 'A'.
        t_company-pono  = t_header-bstnk_vf.
        t_company-bstdk = ld_bstdk.

        IF t_header-fkart = 'ZA02' AND
          t_header-vkorg = '8040'.
          PERFORM f_podo_8040 CHANGING t_company-pono1 t_company-dono.
        ENDIF.
      ELSE.
        READ TABLE t_vbrp WITH KEY vbeln = t_header-vbeln
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_company-pono = t_vbrp-aubel.
        ENDIF.

        CASE t_header-vkorg.
          WHEN '8040'.
            SELECT SINGLE bldat
              FROM ekbe
              INTO t_company-bstdk
              WHERE xblnr EQ t_vbrp-vgbel.

            CLEAR : t_company-pono1.
            lt_vbrp[] = t_vbrp[].
            SORT lt_vbrp BY aubel.
            DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING aubel.
            LOOP AT lt_vbrp INTO ls_vbrp.
              ADD 1 TO lv_count.
              CASE lv_count.
                WHEN 1.
                  t_company-pono1 = ls_vbrp-aubel.
                WHEN 7.
                  EXIT.
                WHEN OTHERS.
                  CONCATENATE t_company-pono1 ls_vbrp-aubel+7(3)
                  INTO t_company-pono1
                  SEPARATED BY '/'.
              ENDCASE.
            ENDLOOP.

            CLEAR : t_company-dono, lv_count.
            SORT t_vbrp BY vgbel.
            lt_vbrp[] = t_vbrp[].
            SORT lt_vbrp BY vgbel.
            DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vgbel.
            LOOP AT lt_vbrp INTO ls_vbrp.
              ADD 1 TO lv_count.
              CASE lv_count.
                WHEN 1.
                  t_company-dono  = ls_vbrp-vgbel.
                WHEN 7.
                  EXIT.
                WHEN OTHERS.
                  CONCATENATE t_company-dono ls_vbrp-vgbel+7(3)
                  INTO t_company-dono
                  SEPARATED BY '/'.
              ENDCASE.
*              t_header-xblnr  = t_vbrp-vgbel.
*              EXIT.
              t_line-tdline = ls_vbrp-vgbel.
              APPEND t_line.
            ENDLOOP.

          WHEN OTHERS.
            SELECT SINGLE bldat
              FROM ekbe
              INTO t_company-bstdk
              WHERE xblnr EQ t_header-xblnr.
        ENDCASE.
      ENDIF.

*      SELECT SINGLE bedat
*        FROM ekko
*        INTO t_company-bstdk
*        WHERE ebeln EQ t_company-pono.

* Tanggal DO
      IF t_header-fktyp EQ 'L' OR
        t_header-fktyp EQ 'I'.
        CLEAR lv_xblnr.
        CASE t_header-vkorg.
          WHEN '8010' OR '8040' OR '8030'.
            READ TABLE t_vbrp INDEX 1.
            IF sy-subrc = 0.
              lv_xblnr = t_vbrp-vgbel.
            ENDIF.
          WHEN OTHERS.
            lv_xblnr = t_header-xblnr.
        ENDCASE.
        SELECT SINGLE wadat_ist
          FROM likp
          INTO t_company-lfdat
          WHERE vbeln EQ lv_xblnr.
      ELSEIF t_header-fktyp EQ 'A'.
        t_company-lfdat = t_header-fkdat.
      ENDIF.

* Payment Term
      SELECT SINGLE ztag1
        FROM t052
        INTO ld_ztag1
        WHERE zterm EQ t_header-zterm.
      IF sy-subrc EQ 0.
        WRITE ld_ztag1 TO t_company-ztag1 NO-ZERO RIGHT-JUSTIFIED.
        t_company-fkdat = t_header-fkdat + ld_ztag1.
      ENDIF.

      IF t_header-vkorg = '8030'.
        LOOP AT lt_vbpa INTO ls_vbpa WHERE parvw = 'WE'.
          ls_xkna1-kunnr  = ls_vbpa-kunnr.
          ls_xkna1-adrnr  = ls_vbpa-adrnr.
          APPEND ls_xkna1 TO lt_xkna1.
          CLEAR ls_xkna1.
        ENDLOOP.
      ENDIF.

* Sold to & Ship to
      SELECT kunnr adrnr stceg
             INTO TABLE lt_kna1
             FROM kna1
             WHERE kunnr EQ t_header-kunrg OR
                   kunnr EQ t_header-kunag.

      CHECK NOT lt_kna1[] IS INITIAL.
      SORT lt_kna1 BY kunnr.
      SELECT *
             INTO TABLE lt_adrc
             FROM adrc
             FOR ALL ENTRIES IN lt_kna1
             WHERE addrnumber = lt_kna1-adrnr.

      IF t_header-vkorg = '8030'.
        IF lt_xkna1[] IS NOT INITIAL.
          SELECT *
                 APPENDING TABLE lt_adrc
                 FROM adrc
                 FOR ALL ENTRIES IN lt_xkna1
                 WHERE addrnumber = lt_xkna1-adrnr.
        ENDIF.
      ENDIF.

      SORT lt_adrc BY addrnumber.

* Sold to
      CASE t_header-vkorg.
*        WHEN '8030'.
*          READ TABLE lt_xkna1 INTO ls_xkna1 INDEX 1.
*          READ TABLE lt_adrc WITH KEY addrnumber = ls_xkna1-adrnr
*               BINARY SEARCH.
*          t_company-name1_sold  = lt_adrc-name_co.
*          t_company-street_sold = lt_adrc-str_suppl1.
*          t_company-city1_sold  = lt_adrc-str_suppl2.
*          t_company-suppl3_sold = lt_adrc-str_suppl3.
*          READ TABLE lt_kna1 WITH KEY kunnr = ls_xkna1-kunnr.
*          t_company-stceg_sold  = lt_kna1-stceg.

        WHEN '8090'.
          READ TABLE lt_kna1 WITH KEY kunnr = t_header-kunrg
               BINARY SEARCH.
          READ TABLE lt_adrc WITH KEY addrnumber = lt_kna1-adrnr
               BINARY SEARCH.
          t_company-name1_sold  = lt_adrc-name_co.
          t_company-street_sold = lt_adrc-str_suppl1.
          t_company-city1_sold  = lt_adrc-str_suppl2.
          t_company-suppl3_sold = lt_adrc-str_suppl3.

        WHEN OTHERS.
          READ TABLE lt_kna1 WITH KEY kunnr = t_header-kunrg
               BINARY SEARCH.
          READ TABLE lt_adrc WITH KEY addrnumber = lt_kna1-adrnr
               BINARY SEARCH.
          t_company-name1_sold  = lt_adrc-name1.
          t_company-street_sold = lt_adrc-street.
          t_company-city1_sold  = lt_adrc-city1.
          t_company-post_code1_sold  = lt_adrc-post_code1.
          t_company-stceg_sold  = lt_kna1-stceg.
      ENDCASE.

* Ship to
      READ TABLE lt_kna1 WITH KEY kunnr = t_header-kunag
           BINARY SEARCH.
      READ TABLE lt_adrc WITH KEY addrnumber = lt_kna1-adrnr
           BINARY SEARCH.
      t_company-name1_ship  = lt_adrc-name1.
      t_company-street_ship = lt_adrc-str_suppl1.
      t_company-city1_ship  = lt_adrc-str_suppl2.
      t_company-stceg_ship  = lt_kna1-stceg.


* Sold to
**      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
**           EXPORTING
**                input  = 'SP'
**           IMPORTING
**                output = ld_parvw.
**
**      READ TABLE lt_vbpa WITH KEY parvw = ld_parvw.
**      IF sy-subrc EQ 0.
**        SELECT SINGLE name1 str_suppl1 str_suppl2
**          FROM adrc
**          INTO (t_company-name1_sold, t_company-street_sold,
**                t_company-city1_sold)
**          WHERE addrnumber EQ lt_vbpa-adrnr.
**
**        SELECT SINGLE stceg
**          FROM kna1
**          INTO t_company-stceg_sold
**          WHERE kunnr EQ lt_vbpa-kunnr.
**      ENDIF.

* Ship to
**      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
**           EXPORTING
**                input  = 'SH'
**           IMPORTING
**                output = ld_parvw.
**
**      READ TABLE lt_vbpa WITH KEY parvw = ld_parvw.
**      IF sy-subrc EQ 0.
**        SELECT SINGLE name1 street city1
**          FROM adrc
**          INTO (t_company-name1_ship, t_company-street_ship,
**                t_company-city1_ship)
**          WHERE addrnumber EQ lt_vbpa-adrnr.
**
**        SELECT SINGLE stceg
**          FROM kna1
**          INTO t_company-stceg_ship
**          WHERE kunnr EQ lt_vbpa-kunnr.
**      ENDIF.

      APPEND t_company.
    ENDIF.
  ENDIF.

  SELECT *
    FROM konv
    INTO CORRESPONDING FIELDS OF TABLE lt_konv
    WHERE knumv EQ t_header-knumv.

  LOOP AT t_vbrp.
    t_vbrp1-vbeln = t_vbrp-vbeln.
    t_vbrp1-matnr = t_vbrp-matnr.
    t_vbrp1-arktx = t_vbrp-arktx.
    t_vbrp1-meins = t_vbrp-meins.
    t_vbrp1-fkimg = t_vbrp-fkimg.

    LOOP AT lt_konv WHERE kposn EQ t_vbrp-posnr.
      CASE lt_konv-kschl.
        WHEN 'ZHJP' OR
             'ZADJ' OR
             'ZHSC' OR
             'ZHIF' OR
             'ZHMC' OR
             'ZKM1' OR
             'ZHJM' OR
             'ZTRP'.
          IF lt_konv-kinak NE 'Y'.
            t_vbrp1-netwr = lt_konv-kwert.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF t_header-waerk EQ 'IDR'.
      ld_netwr1 = t_vbrp1-netwr * 100.
      ld_prcpiece = ld_netwr1 / t_vbrp1-fkimg.
      WRITE ld_prcpiece TO t_vbrp1-prcpiece.
    ELSE.
      ld_prcpiece = t_vbrp1-netwr / t_vbrp1-fkimg.
      WRITE ld_prcpiece TO t_vbrp1-prcpiece CURRENCY t_header-waerk.
    ENDIF.

*    COLLECT t_vbrp1.
    IF t_header-vkorg = '8010'.
      APPEND t_vbrp1.
    ELSE.
      COLLECT t_vbrp1.
    ENDIF.
  ENDLOOP.

  LOOP AT t_vbrp1.
    t_detail-vbeln = t_vbrp1-vbeln.
    ADD 10 TO ld_posnr.
    ld_linenum = ld_posnr / 10.
    WRITE ld_linenum TO t_detail-linenum NO-ZERO RIGHT-JUSTIFIED.

    CONCATENATE t_vbrp1-matnr t_vbrp1-arktx INTO t_detail-item
      SEPARATED BY space.
*    t_detail-item = t_vbrp1-arktx.

    t_detail-matnr  = t_vbrp1-matnr.
    t_detail-arktx  = t_vbrp1-arktx.

    WRITE t_vbrp1-fkimg TO t_detail-qty UNIT t_vbrp1-meins.

    t_detail-prcpiece = t_vbrp1-prcpiece.

    ADD t_vbrp1-netwr TO ld_netwr.

    IF t_header-waerk EQ 'IDR'.
      WRITE t_vbrp1-netwr TO t_detail-harga_rp CURRENCY t_header-waerk.
      CLEAR: t_detail-harga_vls.
    ELSE.
      ld_kurrf = t_header-kurrf * 1000.
      SHIFT ld_kurrf LEFT DELETING LEADING space.
      WRITE t_vbrp1-netwr TO t_detail-harga_vls CURRENCY t_header-waerk.
      ld_harga_rp  = ( t_vbrp1-netwr * ld_kurrf ) / 100.
      WRITE ld_harga_rp TO t_detail-harga_rp CURRENCY 'IDR'.
*     CLEAR: t_detail-harga_rp.
    ENDIF.

    AT END OF vbeln.
      CLEAR: ld_posnr.
    ENDAT.
    APPEND t_detail.
  ENDLOOP.

* Footer
  LOOP AT lt_konv.
    CASE lt_konv-kschl.
      WHEN 'ZD04'.
        ADD lt_konv-kwert TO ld_kwert.
      WHEN 'ZTX1'.
        ADD lt_konv-kwert TO ld_kwert1.
      WHEN 'ZTX5'.
        ADD lt_konv-kwert TO ld_pph22.
        ld_pph22p = lt_konv-kbetr / 10.
    ENDCASE.
  ENDLOOP.

  READ TABLE lt_konv WITH KEY kposn = 0
                              kschl = 'ZS03'.
  IF sy-subrc EQ 0.
    ld_kwert2 = lt_konv-kwert.
  ENDIF.

  ld_kwert = abs( ld_kwert ).
  ld_dpp   = ld_netwr - ld_kwert.

  IF t_header-waerk EQ 'IDR'.
    WRITE ld_netwr TO t_total-itamtlast CURRENCY t_header-waerk.
    WRITE ld_kwert TO t_total-itdisclast CURRENCY t_header-waerk.
    WRITE ld_dpp TO t_total-dpplast CURRENCY t_header-waerk.
    WRITE ld_kwert1 TO t_total-fakppn CURRENCY t_header-waerk.
    WRITE ld_kwert2 TO va_stamp CURRENCY t_header-waerk.
    WRITE ld_pph22 TO t_total-pph22 CURRENCY t_header-waerk.
    va_pay = ld_dpp + ld_kwert1 + ld_kwert2 + ld_pph22.
    ld_langu = 'i'.
    ld_pay = va_pay.
  ELSE.
    ld_netwr_rp  = ( ld_netwr * ld_kurrf ) / 100.
    ld_kwert_rp  = ( ld_kwert * ld_kurrf ) / 100.
    ld_dpp_rp    = ( ld_dpp * ld_kurrf ) / 100.
    ld_kwert1_rp = ( ld_kwert1 * ld_kurrf ) / 100.
    ld_kwert2_rp = ( ld_kwert2 * ld_kurrf ) / 100.
    ld_pph22_rp  = ( ld_pph22 * ld_kurrf ) / 100.

    WRITE ld_netwr_rp TO t_total-itamtlast CURRENCY 'IDR'.
    WRITE ld_kwert_rp TO t_total-itdisclast CURRENCY 'IDR'.
    WRITE ld_dpp_rp TO t_total-dpplast CURRENCY 'IDR'.
    WRITE ld_kwert1_rp TO t_total-fakppn CURRENCY 'IDR'.
    WRITE ld_kwert2_rp TO va_stamp CURRENCY 'IDR'.
    WRITE ld_pph22_rp TO t_total-pph22 CURRENCY 'IDR'.
    va_pay = ld_dpp_rp + ld_kwert1_rp + ld_kwert2_rp + ld_pph22_rp.
    ld_langu = 'i'.

    WRITE ld_netwr TO t_total-itamtlast_f CURRENCY t_header-waerk.
    WRITE ld_kwert TO t_total-itdisclast_f CURRENCY t_header-waerk.
    WRITE ld_dpp TO t_total-dpp_f CURRENCY t_header-waerk.
    WRITE ld_kwert1 TO t_total-ppn_f CURRENCY t_header-waerk.
    WRITE ld_pph22 TO t_total-pph22_f CURRENCY t_header-waerk.
    WRITE ld_kwert2 TO va_stamp_f CURRENCY t_header-waerk.
    va_pay_f = ld_dpp + ld_kwert1 + ld_kwert2 + ld_pph22.
    ld_langu = sy-langu.
    ld_pay = va_pay_f.
  ENDIF.

  WRITE ld_pph22p TO t_total-pph22p DECIMALS 2 LEFT-JUSTIFIED.
  CONCATENATE t_total-pph22p '%' INTO t_total-pph22p SEPARATED BY space.

*  IF va_pay IS INITIAL.
*    ld_pay = va_pay_f.
*  ELSE.
*    ld_pay = va_pay.
*  ENDIF.

*-----Spell amount
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = ld_pay
      currency  = t_header-waerk
      language  = ld_langu
    IMPORTING
      in_words  = ld_spell
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.
  IF sy-subrc <> 0.
    CLEAR ld_spell.
  ENDIF.

*-----Amount in words
  DATA l_waers1(40).
  DATA l_waers(6).
  IF t_header-waerk NE 'IDR'.
    SELECT SINGLE ktext
      FROM tcurt
      INTO l_waers1
      WHERE spras EQ sy-langu AND
            waers EQ t_header-waerk.
    TRANSLATE l_waers1 TO UPPER CASE.
  ENDIF.

  IF ld_spell-currdec EQ 0.
    IF t_header-waerk EQ 'IDR'.
      l_waers = 'RUPIAH'.
      CONCATENATE ld_spell-word l_waers INTO va_words
        SEPARATED BY space.
    ELSE.
      l_waers = t_header-waerk.
      CONCATENATE l_waers1 ld_spell-word INTO va_words
        SEPARATED BY space.
    ENDIF.
  ELSE.
    IF t_header-waerk EQ 'IDR'.
      l_waers = 'RUPIAH'.
      CONCATENATE ld_spell-word l_waers INTO va_words
        SEPARATED BY space.
    ELSE.
      IF ld_spell-decword EQ 'ZERO'.
        CONCATENATE l_waers1 ld_spell-word INTO va_words
          SEPARATED BY space.
      ELSE.
        CONCATENATE l_waers1 ld_spell-word 'AND' ld_spell-decword
                    'CENTS'
                    INTO va_words
                    SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDIF.

** Project PPN 11% - begin
  READ TABLE t_header INDEX 1.
  PERFORM f_get_ppn% USING t_header-fkdat ld_dpp t_header-waerk
                     CHANGING t_total-ppn% t_total-dpp_f t_total-dpplast.
** Project PPN 11% - end

  APPEND t_total.
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

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  d_output_opt-tdnoprint = p_disp.
  IF d_frm_subrc IS INITIAL.
**      call the generated function module of the form
*       call function func_module_name
*          exporting
*            control_parameters = d_ctrl_param
*            output_options     = d_output_opt
*            user_settings      = space

*    LOOP AT t_header.
*      AT FIRST.
*        d_ctrl_param-no_close = 'X'.
*      ENDAT.
*
*      AT LAST.
*        d_ctrl_param-no_close = space.
*      ENDAT.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        t_header           = t_header
        t_company          = t_company
        t_total            = t_total
        va_pay             = va_pay
        va_pay_f           = va_pay_f
        va_stamp           = va_stamp
        va_stamp_f         = va_stamp_f
        va_words           = va_words
        va_petugas         = va_petugas
        va_jabat           = va_jabat
        va_nofktr          = va_nofktr
        va_fakturno        = va_fakturno
        va_city            = va_city
        va_desc            = va_desc
      TABLES
        t_detail           = t_detail
        t_line             = t_line
        t_line_mark        = t_line_mark.

*      d_ctrl_param-no_open = 'X'.
*    ENDLOOP.
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
  REFRESH: t_header, t_detail, t_company, t_total, t_vbrp1, t_vbrp.
  CLEAR: t_header, t_detail, t_company, t_total, t_vbrp1, t_vbrp,
         va_pay, va_pay_f, va_stamp, va_stamp_f,
         va_words, va_petugas, va_jabat, va_nofktr.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  f_write_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_selection .
*{   REPLACE        P01K910471                                        1
*\  SELECT *
*\    FROM vbrk
*\    INTO CORRESPONDING FIELDS OF TABLE t_header
*\    WHERE vbeln EQ pa_vbeln.
  "Start SOH: Shell SCI Adjustment 20240223 RZL
  SELECT *
    FROM vbrk
    INTO CORRESPONDING FIELDS OF TABLE t_header
    WHERE vbeln EQ pa_vbeln ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240223 RZL
*}   REPLACE

  READ TABLE t_header INDEX 1.
  t_rsparams-selname = 'PA_VKORG'.
  t_rsparams-kind    = 'P'.
  t_rsparams-sign    = 'I'.
  t_rsparams-option  = 'EQ'.
  t_rsparams-low     = t_header-vkorg.
  APPEND t_rsparams.

  t_rsparams-selname = 'SO_VBELN'.
  t_rsparams-kind    = 'S'.
  t_rsparams-sign    = 'I'.
  t_rsparams-option  = 'BT'.
  t_rsparams-low     = pa_vbeln.
  t_rsparams-high    = pa_vbeln.
  APPEND t_rsparams.

  t_rsparams-selname = 'SO_FKDAT'.
  t_rsparams-kind    = 'S'.
  t_rsparams-sign    = 'I'.
  t_rsparams-option  = 'BT'.
  t_rsparams-low     = t_header-fkdat.
  t_rsparams-high    = t_header-fkdat.
  APPEND t_rsparams.
ENDFORM.                    " f_write_selection

*&---------------------------------------------------------------------*
*&      Form  F_GET_PPN%
*&---------------------------------------------------------------------*
FORM f_get_ppn%  USING    fu_fkdat fu_netwr fu_waerk
                 CHANGING fc_ppn% fc_dpp fc_dpplast.
  DATA: lv_ppn%     LIKE konv-kwert,
        ls_zproject TYPE zproject,
        lv_netwr    TYPE vbrp-netwr.

  SELECT SINGLE * INTO ls_zproject
    FROM zproject WHERE name = 'PPN11'
                    AND flag = 'X'.
  IF sy-subrc = 0 AND fu_fkdat GE ls_zproject-datab.
*    CLEAR lv_ppn%.
*    lv_ppn% = ls_zproject-char3 / ls_zproject-char1.
*    WRITE lv_ppn% to fc_ppn% DECIMALS 0.
    IF fu_fkdat > gs_dpp-datab.
      fc_ppn% = '12'.
*      fc_dpp = fu_netwr * 11 / 12.
      lv_netwr = fu_netwr * 11 / 12.
      IF fu_waerk = 'IDR'.
        WRITE lv_netwr TO fc_dpplast CURRENCY fu_waerk.
      ELSE.
        WRITE lv_netwr TO fc_dpp CURRENCY fu_waerk.
      ENDIF.
    ELSE.
      fc_ppn% = '11'.
    ENDIF.
  ELSE.
    fc_ppn% = '10'.
  ENDIF.

ENDFORM.                    " F_GET_PPN%

*&---------------------------------------------------------------------*
*&      Form  F_PODO_8040
*&---------------------------------------------------------------------*
FORM f_podo_8040 CHANGING fc_pono fc_dono.
  DATA : lt_vbrp  TYPE STANDARD TABLE OF vbrp,
         ls_vbrp  LIKE LINE OF lt_vbrp,
         lv_count TYPE i.

  READ TABLE t_vbrp WITH KEY vbeln = t_header-vbeln.

  CLEAR : fc_pono.
  fc_pono   = t_header-bstnk_vf.

  CLEAR : fc_dono, lv_count.
  SORT t_vbrp BY vgbel.
  lt_vbrp[] = t_vbrp[].
  SORT lt_vbrp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vgbel.
  LOOP AT lt_vbrp INTO ls_vbrp.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        fc_dono  = ls_vbrp-vgbel.
      WHEN 7.
        EXIT.
      WHEN OTHERS.
        CONCATENATE fc_dono ls_vbrp-vgbel+7(3)
        INTO fc_dono
        SEPARATED BY '/'.
    ENDCASE.
    t_line-tdline = ls_vbrp-vgbel.
    APPEND t_line.
  ENDLOOP.
ENDFORM.                    " F_PODO_8040
