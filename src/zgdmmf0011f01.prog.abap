*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0011F01
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
  PERFORM f_modify_xeket.
  PERFORM f_initial_data.
  PERFORM f_get_retail_price.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_exclude_print.
  PERFORM f_print_form.

  IF "sy-ucomm  = '9AUS' AND
    sy-tcode = 'ME9F' AND
    nast-nacha = '5'.
    PERFORM f_email_attachment.
  ENDIF.

  PERFORM f_free_memory.
ENDFORM.                    " f_process_report

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: sw        TYPE i,
        ld_adrnr  LIKE t001w-adrnr,
        ld_emlif  LIKE ekpo-emlif.

  DATA : adr_val  TYPE addr1_val,
         add_sel  TYPE addr1_sel.
  DATA: l_name(70),
        l_name1(70),
        l_lines   TYPE tline OCCURS 0,
        wa_lines  TYPE tline,
        d_currdec TYPE tcurx-currdec,
        l_komk    TYPE komk,
        xtkomvd   TYPE komvd OCCURS 0.

  DATA: lt_tcurf TYPE STANDARD TABLE OF tcurf,
        l_tcurf_new TYPE tcurf,
        i_date  LIKE mcekko-bedat.

  DATA: l_menge  LIKE zgdmmst0011-menge,
        l_netpr  LIKE zgdmmst0011-netpr,
        l_netwr  LIKE zgdmmst0011-netwr,
        l_hrgsat LIKE zgdmmst0011-hrgsat,
        l_count  TYPE i.

  DATA: l_rev    TYPE char10.

  IF l_from_memory EQ space.
    l_komk-mandt = l_doc-xekko-mandt.
    l_komk-kalsm = l_doc-xekko-kalsm.
    l_komk-kappl = 'M'.
    l_komk-waerk = l_doc-xekko-waers.
    l_komk-knumv = l_doc-xekko-knumv.
    l_komk-bukrs = l_doc-xekko-bukrs.
    l_komk-lifnr = l_doc-xekko-lifnr.
    CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
      EXPORTING
        comm_head_i = l_komk
        language    = l_doc-xekko-spras
      IMPORTING
        comm_head_e = l_komk
      TABLES
        tkomv       = l_doc-xtkomv
        tkomvd      = xtkomvd.
  ENDIF.

*------------*
* Header data
*------------*
  wa_hd-ebeln = l_doc-xekko-ebeln.
  wa_hd-bsart = l_doc-xekko-bsart.
  wa_hd-lifnr = l_doc-xekko-lifnr.
  wa_hd-bedat = l_doc-xekko-bedat.
  wa_hd-zterm = l_doc-xekko-zterm.
  wa_hd-reswk = l_doc-xekko-reswk.
  wa_hd-waers = l_doc-xekko-waers.
  wa_hd-ekgrp = l_doc-xekko-ekgrp.
  wa_hd-bukrs = l_doc-xekko-bukrs.
  wa_hd-knumv = l_doc-xekko-knumv.
  wa_hd-inco1 = l_doc-xekko-inco1.
  wa_hd-inco2 = l_doc-xekko-inco2.
  wa_hd-kdatb = l_doc-xekko-kdatb.
  wa_hd-ekorg = l_doc-xekko-ekorg.
  wa_hd-verkf = l_doc-xekko-verkf.
  wa_hd-ihrez = l_doc-xekko-ihrez.
  IF l_doc-xekko-bsart = 'ZO2O'.
    wa_hd-ihrez = 'LOGO'.
  ENDIF.
  TRANSLATE wa_hd-ihrez TO UPPER CASE.

*------------*
* Revisi ke
*------------*
  IF NOT va_revisi IS INITIAL.
    IF nast-kappl EQ 'EF' AND
      nast-vstat EQ '0'   AND
      nast-aende EQ 'X'.
      ADD 1 TO va_revisi.
    ENDIF.
    wa_hd-datvr = nast-erdat.
    IF wa_hd-datvr IS INITIAL.
      wa_hd-datvr = sy-datum.
    ENDIF.
    l_rev = va_revisi.
    SHIFT l_rev LEFT DELETING LEADING space.
    CONCATENATE wa_hd-datvr+6(2) wa_hd-datvr+4(2) wa_hd-datvr(4)
    INTO va_rev SEPARATED BY '.'.
    CONCATENATE '(' va_rev ')'
    INTO va_rev.
    CONCATENATE 'Rev :' l_rev va_rev
    INTO va_rev SEPARATED BY space.
  ELSE.
    IF nast-aende = 'X'.
      ADD 1 TO va_revisi.
      wa_hd-datvr = nast-erdat.
      IF wa_hd-datvr IS INITIAL.
        wa_hd-datvr = sy-datum.
      ENDIF.
      l_rev = va_revisi.
      SHIFT l_rev LEFT DELETING LEADING space.
      CONCATENATE wa_hd-datvr+6(2) wa_hd-datvr+4(2) wa_hd-datvr(4)
      INTO va_rev SEPARATED BY '.'.
      CONCATENATE '(' va_rev ')'
      INTO va_rev.
      CONCATENATE 'Rev :' l_rev va_rev
      INTO va_rev SEPARATED BY space.
    ENDIF.
  ENDIF.

  IF l_doc-xekko-adrnr NE space.
    add_sel-addrnumber = l_doc-xekko-adrnr.
  ELSE.
    add_sel-addrhandle = 'INDIVIDUAL_VENDOR_ADDRESS'.
  ENDIF.

  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = add_sel
    IMPORTING
      address_value     = adr_val
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc EQ 0.
    wa_hd-name1_to = adr_val-name1.
    IF adr_val-str_suppl3 NE space.
      wa_hd-stras_to = adr_val-str_suppl3.
      wa_hd-ort01_to = adr_val-location.
      wa_hd-city2_to = adr_val-city2.
    ELSE.
      CONCATENATE adr_val-street adr_val-house_num1
      INTO wa_hd-stras_to
      SEPARATED BY space.
      wa_hd-ort01_to = adr_val-city1.
      IF adr_val-post_code1 <> '00000'.
        CONCATENATE wa_hd-ort01_to adr_val-post_code1
        INTO wa_hd-ort01_to
        SEPARATED BY space.
      ENDIF.
    ENDIF.
* Remove country data on 28 June 2005
*    SELECT SINGLE landx FROM t005t INTO wa_hd-landx
*    WHERE spras = 'E' AND
*          land1 = adr_val-country.

  ELSE.
* 18/10/2005
    IF nast-parnr EQ space.
      nast-parnr = wa_hd-lifnr.
    ENDIF.
* 17/05/2005
    SELECT SINGLE adrc~name1 adrc~str_suppl3
                  adrc~location adrc~city2
      FROM lfa1 INNER JOIN adrc
      ON   adrc~addrnumber = lfa1~adrnr
* Remove country data on 28 June 2005
*      INNER JOIN t005t
*      ON   t005t~land1 = adrc~country
      INTO (wa_hd-name1_to, wa_hd-stras_to, wa_hd-ort01_to,
            wa_hd-city2_to)
      WHERE lifnr EQ nast-parnr.
*      WHERE lifnr EQ nast-parnr AND
*            t005t~spras = 'E'.

    IF wa_hd-stras_to EQ space.
      SELECT SINGLE street house_num1 city1 post_code1
        FROM lfa1 INNER JOIN adrc
        ON   adrc~addrnumber = lfa1~adrnr
        INTO (wa_hd-stras_to, adr_val-house_num1,
              wa_hd-ort01_to, adr_val-post_code1)
        WHERE lifnr EQ nast-parnr.
      CONCATENATE wa_hd-stras_to adr_val-house_num1
      INTO wa_hd-stras_to
      SEPARATED BY space.
      IF adr_val-post_code1 <> '00000'.
        CONCATENATE wa_hd-ort01_to adr_val-post_code1
        INTO wa_hd-ort01_to
        SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE adrc~name1 street
    FROM t001w INNER JOIN adrc
    ON   adrc~addrnumber = t001w~adrnr
    INTO (wa_hd-name2, wa_hd-stras2)
    WHERE werks EQ wa_hd-reswk.

* 15/04/2005
  IF wa_hd-bsart EQ 'ZIMP'.
    va_vtext = 'Freight'.
  ELSEIF wa_hd-bsart EQ 'ZLOC'.
    READ TABLE l_doc-xekpo INTO wa_ekpo
    WITH KEY matkl = 'ZFASSMCH'.
    IF sy-subrc = 0.
      va_vtext = 'Biaya Instalasi'.
    ELSE.
      va_vtext = 'Ongkos angkut'.
    ENDIF.
  ENDIF.

* Baca tax code & print price indicator
  READ TABLE l_doc-xekpo INTO wa_ekpo INDEX 1.
  wa_hd-mwskz = wa_ekpo-mwskz.
  wa_hd-prsdr = wa_ekpo-prsdr.

*--------------*
* Select detail
*--------------*
*  l_doc1-xekpo[] = l_doc-xekpo[].
*  DELETE l_doc1-xekpo WHERE emlif EQ space.
*  READ TABLE l_doc1-xekpo INTO wa_ekpo INDEX 1.
*  IF sy-subrc EQ 0.
*    ld_emlif = wa_ekpo-emlif.
*  ENDIF.

  CLEAR: wa_ekpo, add_sel, sw.
  LOOP AT l_doc-xekpo INTO wa_ekpo.
*--------------*
* Get Delivery address hanya untuk 8010 & PO import
*--------------*
    IF sw IS INITIAL.
      sw = 1.
*      IF ld_emlif IS NOT INITIAL.
*        wa_ekpo-emlif = ld_emlif.
*      ENDIF.
      IF wa_hd-bukrs EQ '8010'.
        IF wa_ekpo-adrnr IS INITIAL.
          IF wa_ekpo-emlif IS INITIAL.
            SELECT SINGLE adrnr
              FROM t001w
              INTO ld_adrnr
              WHERE werks EQ wa_ekpo-werks.
            IF sy-subrc EQ 0.
              SELECT SINGLE name1 name2 street post_code1 city1
                FROM adrc
                INTO (wa_deliv-name1, wa_deliv-name2, wa_deliv-street, wa_deliv-post_code1, wa_deliv-city1)
                WHERE addrnumber EQ ld_adrnr.
            ENDIF.
          ELSE.
            SELECT SINGLE adrnr
              FROM lfa1
              INTO ld_adrnr
              WHERE lifnr EQ wa_ekpo-emlif.
            IF sy-subrc EQ 0.
              SELECT SINGLE name1 name2 street post_code1 city1
                FROM adrc
                INTO (wa_deliv-name1, wa_deliv-name2, wa_deliv-street, wa_deliv-post_code1, wa_deliv-city1)
                WHERE addrnumber EQ ld_adrnr.
            ENDIF.
          ENDIF.
        ELSE.
          add_sel-addrnumber = wa_ekpo-adrnr.
          CALL FUNCTION 'ADDR_GET'
            EXPORTING
              address_selection = add_sel
            IMPORTING
              address_value     = adr_val
            EXCEPTIONS
              OTHERS            = 1.
          IF sy-subrc EQ 0.
            wa_deliv-name1       = adr_val-name1.
            wa_deliv-name2       = adr_val-name2.
            wa_deliv-street      = adr_val-street.
            wa_deliv-post_code1  = adr_val-post_code1.
            wa_deliv-city1       = adr_val-city1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    wa_dt-ebeln = wa_ekpo-ebeln.
    wa_dt-ebelp = wa_ekpo-ebelp.
    wa_dt-repos = wa_ekpo-repos.
    IF wa_ekpo-werks = '1601'.
      SELECT SINGLE bismt FROM mara INTO wa_dt-ematn
      WHERE matnr = wa_ekpo-matnr.
    ELSE.
      wa_dt-ematn = wa_ekpo-matnr.
    ENDIF.

    wa_dt-lblkz = wa_ekpo-lblkz.
    wa_dt-menge = wa_ekpo-menge.
    wa_dt-meins = wa_ekpo-meins.
    wa_dt-netpr = wa_ekpo-netpr.
    wa_dt-peinh = wa_ekpo-peinh.
    wa_dt-werks = wa_ekpo-werks.
    wa_dt-banfn = wa_ekpo-banfn.
    wa_dt-txz01 = wa_ekpo-txz01.
    wa_dt-idnlf = wa_ekpo-idnlf.
    wa_dt-infnr = wa_ekpo-infnr.
    wa_dt-knttp = wa_ekpo-knttp.
    wa_dt-bednr = wa_ekpo-bednr.
    IF wa_ekpo-afnam+4(8) NE space.
      CONCATENATE wa_dt-bednr wa_ekpo-afnam+4(8) INTO wa_dt-bednr
      SEPARATED BY space.
    ENDIF.

*---------------------------------------------------------------------*
* Begin to process
*---------------------------------------------------------------------*
* Material description
    DATA: l_desc(200).
    IF wa_ekpo-idnlf NE space.
      CONCATENATE wa_dt-ebeln wa_dt-ebelp INTO l_name.
      IF wa_dt-ebeln IS INITIAL.
        CLEAR: l_name.
        l_name+10(5) = wa_dt-ebelp.
      ENDIF.

      REFRESH: l_lines. CLEAR: l_lines, l_desc.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id       = 'F05'
          language = 'E'
          name     = l_name
          object   = 'EKPO'
        TABLES
          lines    = l_lines
        EXCEPTIONS
          OTHERS   = 1.
      IF sy-subrc = 0.
        LOOP AT l_lines INTO wa_lines.
          IF wa_lines-tdline NE space.
            CONCATENATE l_desc wa_lines-tdline INTO l_desc
              SEPARATED BY space.
          ENDIF.
        ENDLOOP.
        wa_dt-idnlf+60(150) = l_desc.
      ENDIF.
    ELSE.
      IF wa_ekpo-mfrpn NE space.
        wa_dt-txz01+60(25) = wa_ekpo-mfrpn.
      ENDIF.
    ENDIF.

    IF wa_hd-ekorg = 'PMH'.
      REFRESH: l_lines. CLEAR: l_lines, l_desc.
      l_name  = wa_ekpo-matnr.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id       = 'GRUN'
          language = sy-langu
          name     = l_name
          object   = 'MATERIAL'
        TABLES
          lines    = l_lines
        EXCEPTIONS
          OTHERS   = 1.
      IF sy-subrc = 0.
        READ TABLE l_lines INTO wa_lines INDEX 1.
        IF sy-subrc = 0.
          wa_dt-tdline  = wa_lines-tdline.
        ELSE.
          CLEAR wa_dt-tdline.
        ENDIF.
      ENDIF.

      CONCATENATE wa_dt-ematn '  ' wa_dt-txz01 INTO wa_dt-desc
        SEPARATED BY space.
    ELSE.
      IF wa_dt-ematn EQ space.
        wa_dt-desc = wa_dt-txz01.
      ELSEIF wa_dt-idnlf EQ space.
        CONCATENATE wa_dt-ematn '  ' wa_dt-txz01 INTO wa_dt-desc
          SEPARATED BY space.
      ELSE.
        CONCATENATE wa_dt-ematn '  ' wa_dt-idnlf INTO wa_dt-desc
          SEPARATED BY space.
      ENDIF.
    ENDIF.



* Tax indicator
    SELECT SINGLE taxim FROM mlan
      INTO wa_dt-taxim
      WHERE matnr EQ wa_ekpo-ematn AND
            aland EQ 'ID'.

* Untuk PO dengan inforecord
    READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                                 kposn = wa_ekpo-ebelp
                                                 kschl = 'ZPB0'.
* Untuk PO tanpa inforecord
    IF sy-subrc NE 0.
      READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                                   kposn = wa_ekpo-ebelp
                                                   kschl = 'ZPB1'.
    ENDIF.

* Untuk PO intercompany
    IF sy-subrc NE 0.
      READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                                   kposn = wa_ekpo-ebelp
                                                   kschl = 'ZHIF'.
    ENDIF.
* Untuk PO dengan subcontracting
    IF sy-subrc NE 0.
      READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                                   kposn = wa_ekpo-ebelp
                                                   kschl = 'ZHSC'.
    ENDIF.

    DATA: l_kwert LIKE konv-kwert.

    l_kwert      = t_konv-kwert.
    wa_dt-netwr  = l_kwert.
*    wa_dt-netwr  = t_konv-kwert.
    wa_dt-waers  = wa_hd-waers.

    IF t_konv-waers <> 'IDR' AND wa_dt-waers = 'IDR'.
      i_date = l_doc-xekko-bedat.
      CONVERT DATE i_date INTO INVERTED-DATE i_date.
      l_tcurf_new-tfact = '1'.
      SELECT * FROM tcurf INTO TABLE lt_tcurf
      WHERE kurst = 'M' AND
            fcurr = t_konv-waers AND
            tcurr = 'IDR' AND
            gdatu >= i_date.

      IF sy-subrc = 0.
        SORT lt_tcurf BY gdatu.
        READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
        l_tcurf_new-tfact = l_tcurf_new-tfact.
      ENDIF.
      IF t_konv-kpein NE 0.
        IF wa_hd-ld EQ space.
          wa_dt-hrgsat = t_konv-kbetr * t_konv-kkurs *
                         l_tcurf_new-tfact / t_konv-kpein.
        ELSE.
          wa_dt-hrgsat = t_konv-kbetr * t_konv-kkurs *
                         l_tcurf_new-tfact.
        ENDIF.
      ENDIF.
    ELSE.
      IF t_konv-kpein NE 0.
        IF wa_hd-ld EQ space.
          wa_dt-hrgsat = t_konv-kbetr / t_konv-kpein.
        ELSE.
          wa_dt-hrgsat = t_konv-kbetr.
        ENDIF.
      ENDIF.
    ENDIF.

    SELECT SINGLE currdec FROM tcurx INTO d_currdec
    WHERE currkey = t_konv-waers.
    IF sy-subrc = 4.
      d_currdec = 2.
    ENDIF.

    wa_dt-hrgsat = wa_dt-hrgsat / ( 10 ** d_currdec ).

* Item delivery date
    IF wa_hd-kdatb EQ '00000000'.
*      READ TABLE l_doc-xeket INTO wa_eket WITH KEY ebeln = wa_hd-ebeln
*                                                   ebelp = wa_dt-ebelp.
*      IF sy-subrc EQ 0.
*        wa_dt-eindt = wa_eket-eindt.
*        wa_dt-charg = wa_eket-charg.
*        wa_dt-lpein = wa_eket-lpein.
*      ENDIF.

      LOOP AT l_doc-xeket INTO wa_eket WHERE ebeln = wa_ekpo-ebeln AND
                                             ebelp = wa_ekpo-ebelp.
        wa_dt-eindt = wa_eket-eindt.
        wa_dt-charg = wa_eket-charg.
        wa_dt-lpein = wa_eket-lpein.
        wa_dt-menge = wa_eket-menge.
        wa_dt-banfn = wa_eket-banfn.
        wa_dt-meins = wa_ekpo-meins.
        AT END OF ebelp.
          EXIT.
        ENDAT.

        ADD wa_dt-menge TO l_menge.
        IF NOT wa_dt-ebelp IS INITIAL.
          l_netpr  = wa_dt-netpr.
          l_netwr  = wa_dt-netwr.
          l_hrgsat = wa_dt-hrgsat.
        ENDIF.

** Penambahan perhitungan baru untuk total jika memakai delivery
** schedule 13/09/2005
        IF NOT wa_dt-netwr IS INITIAL.
          ADD wa_dt-netwr TO wa_hd-total.
          CLEAR: l_kwert.
        ENDIF.
** End penambahan

        CLEAR: wa_dt-netpr, wa_dt-netwr, wa_dt-hrgsat.
        APPEND wa_dt TO i_dt.
        l_count = 1.
        CLEAR wa_dt.
      ENDLOOP.
    ELSE.
      wa_dt-eindt = l_doc-xekko-kdatb.
    ENDIF.

* Discount
    LOOP AT l_doc-xtkomv INTO t_konv
      WHERE knumv EQ wa_hd-knumv AND
            kposn EQ wa_ekpo-ebelp.
      CASE t_konv-kschl.
        WHEN 'ZFEE'.
          CLEAR: t_konv-kwert.
        WHEN 'ZR00'.
          IF t_konv-krech = 'A'.
            t_konv-kbetr = t_konv-kbetr / 10.
            WRITE t_konv-kbetr TO wa_dt-kbetr NO-SIGN.
            SHIFT wa_dt-kbetr LEFT BY 2 PLACES.
            CONCATENATE wa_dt-kbetr '%' INTO wa_dt-kbetr
            SEPARATED BY space.
            wa_dt-vtext = 'Discount % on Gross'.
          ELSE.
            WRITE t_konv-kbetr TO wa_dt-kbetr
               NO-SIGN CURRENCY wa_hd-waers.
            SHIFT wa_dt-kbetr LEFT DELETING LEADING space.
            CONCATENATE '(' wa_dt-kbetr ')' INTO wa_dt-kbetr
            SEPARATED BY space.
            WRITE wa_dt-kbetr TO wa_dt-kbetr RIGHT-JUSTIFIED.
            IF t_konv-krech = 'B'.
              wa_dt-vtext = 'Disc value on gross'.
            ELSEIF t_konv-krech = 'C'.
              wa_dt-vtext = 'Disc val per qty'.
            ENDIF.
          ENDIF.
          ADD t_konv-kwert TO wa_dt-disc1.
*          ADD t_konv-kbetr TO wa_dt-kbetr.
        WHEN 'ZFR1' OR 'ZFR2'.
          ADD t_konv-kwert TO wa_dt-freig.
          ADD t_konv-kbetr TO wa_dt-kbetr1.
          wa_dt-kschl = t_konv-kschl.
        WHEN 'ZSU1'.
          ADD t_konv-kwert TO wa_dt-surchg.
          ADD t_konv-kbetr TO wa_dt-kbetr2.
*          wa_dt-kpein = t_konv-kpein.
*          wa_dt-krech = t_konv-krech.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext1
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZPC1'.
          ADD t_konv-kwert TO wa_dt-packchg.
          ADD t_konv-kbetr TO wa_dt-kbetr3.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext2
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZBB1'.
          ADD t_konv-kwert TO wa_dt-beabank.
          ADD t_konv-kbetr TO wa_dt-kbetr4.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext4
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZHD1'.
          ADD t_konv-kwert TO wa_dt-handling.
          ADD t_konv-kbetr TO wa_dt-kbetr5.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext5
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZID1'.
          ADD t_konv-kwert TO wa_dt-impduty.
          ADD t_konv-kbetr TO wa_dt-kbetr6.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext6
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZIN1'.
          ADD t_konv-kwert TO wa_dt-insurance.
          ADD t_konv-kbetr TO wa_dt-kbetr7.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext7
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZIT1'.
          ADD t_konv-kwert TO wa_dt-inlandtr.
          ADD t_konv-kbetr TO wa_dt-kbetr8.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext8
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZTR1'.
          ADD t_konv-kwert TO wa_dt-trans.
          ADD t_konv-kbetr TO wa_dt-kbetr9.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext9
            WHERE spras EQ sy-langu AND
                  kschl EQ t_konv-kschl.
        WHEN 'ZHMC'.
          IF t_konv-waers <> 'IDR' AND wa_dt-waers = 'IDR'.
            i_date = l_doc-xekko-bedat.
            CONVERT DATE i_date INTO INVERTED-DATE i_date.
            l_tcurf_new-tfact = '1'.
            SELECT * FROM tcurf INTO TABLE lt_tcurf
            WHERE kurst = 'M' AND
                  fcurr = t_konv-waers AND
                  tcurr = 'IDR' AND
                  gdatu >= i_date.

            IF sy-subrc = 0.
              SORT lt_tcurf BY gdatu.
              READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
              l_tcurf_new-tfact = l_tcurf_new-tfact.
            ENDIF.
            IF t_konv-kpein NE 0.
              IF wa_hd-ld EQ space.
                wa_dt-kbetr10 = t_konv-kbetr * t_konv-kkurs *
                               l_tcurf_new-tfact / t_konv-kpein.
              ELSE.
                wa_dt-kbetr10 = t_konv-kbetr * t_konv-kkurs *
                               l_tcurf_new-tfact.
              ENDIF.
            ENDIF.
          ELSE.
            IF t_konv-kpein NE 0.
              IF wa_hd-ld EQ space.
                wa_dt-kbetr10 = t_konv-kbetr / t_konv-kpein.
              ELSE.
                wa_dt-kbetr10 = t_konv-kbetr.
              ENDIF.
            ENDIF.
          ENDIF.

          SELECT SINGLE currdec FROM tcurx INTO d_currdec
          WHERE currkey = t_konv-waers.
          IF sy-subrc = 4.
            d_currdec = 2.
          ENDIF.

          wa_dt-kbetr10 = wa_dt-kbetr10 / ( 10 ** d_currdec ).

          ADD t_konv-kwert TO wa_dt-matcost.
*          ADD t_konv-kbetr TO wa_dt-kbetr10.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext10
            WHERE spras EQ sy-langu AND
                kappl EQ 'M'        AND
                kschl EQ t_konv-kschl.

        WHEN 'ZHPC'.
          IF t_konv-waers <> 'IDR' AND wa_dt-waers = 'IDR'.
            i_date = l_doc-xekko-bedat.
            CONVERT DATE i_date INTO INVERTED-DATE i_date.
            l_tcurf_new-tfact = '1'.
            SELECT * FROM tcurf INTO TABLE lt_tcurf
            WHERE kurst = 'M' AND
                  fcurr = t_konv-waers AND
                  tcurr = 'IDR' AND
                  gdatu >= i_date.

            IF sy-subrc = 0.
              SORT lt_tcurf BY gdatu.
              READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
              l_tcurf_new-tfact = l_tcurf_new-tfact.
            ENDIF.
            IF t_konv-kpein NE 0.
              IF wa_hd-ld EQ space.
                wa_dt-kbetr11 = t_konv-kbetr * t_konv-kkurs *
                               l_tcurf_new-tfact / t_konv-kpein.
              ELSE.
                wa_dt-kbetr11 = t_konv-kbetr * t_konv-kkurs *
                               l_tcurf_new-tfact.
              ENDIF.
            ENDIF.
          ELSE.
            IF t_konv-kpein NE 0.
              IF wa_hd-ld EQ space.
                wa_dt-kbetr11 = t_konv-kbetr / t_konv-kpein.
              ELSE.
                wa_dt-kbetr11 = t_konv-kbetr.
              ENDIF.
            ENDIF.
          ENDIF.

          SELECT SINGLE currdec FROM tcurx INTO d_currdec
          WHERE currkey = t_konv-waers.
          IF sy-subrc = 4.
            d_currdec = 2.
          ENDIF.

          wa_dt-kbetr11 = wa_dt-kbetr11 / ( 10 ** d_currdec ).

          ADD t_konv-kwert TO wa_dt-packcost.
          SELECT SINGLE vtext
            FROM t685t
            INTO wa_dt-vtext11
            WHERE spras EQ sy-langu AND
                kappl EQ 'M'        AND
                kschl EQ t_konv-kschl.
      ENDCASE.
    ENDLOOP.
    l_name       = wa_ekpo-ebeln.
    l_name+10(5) = wa_ekpo-ebelp.
    REFRESH: l_lines. CLEAR: l_lines.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = 'F91'
        language = 'E'
        name     = l_name
        object   = 'EKPO'
      TABLES
        lines    = l_lines
      EXCEPTIONS
        OTHERS   = 1.

    IF sy-subrc EQ 0.
      LOOP AT l_lines INTO wa_lines.
        IF wa_lines-tdline NE space.
          CASE wa_lines-tdline(4).
            WHEN 'ZR00'.
              wa_dt-vtext = wa_lines-tdline+5(25).
            WHEN 'ZSU1'.
              wa_dt-vtext1 = wa_lines-tdline+5(25).
            WHEN 'ZFR1' OR 'ZFR2'.
              va_vtext = wa_lines-tdline+5(25).
            WHEN 'ZPC1'.
              wa_dt-vtext2 = wa_lines-tdline+5(25).
            WHEN 'ZBB1'.
              wa_dt-vtext4 = wa_lines-tdline+5(25).
            WHEN 'ZHD1'.
              wa_dt-vtext5 = wa_lines-tdline+5(25).
            WHEN 'ZID1'.
              wa_dt-vtext6 = wa_lines-tdline+5(25).
            WHEN 'ZIN1'.
              wa_dt-vtext7 = wa_lines-tdline+5(25).
            WHEN 'ZIT1'.
              wa_dt-vtext8 = wa_lines-tdline+5(25).
            WHEN 'ZTR1'.
              wa_dt-vtext9 = wa_lines-tdline+5(25).
            WHEN 'ZHMC'.
              wa_dt-vtext10 = wa_lines-tdline+5(25).
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.
*---------------------------------------------------------------------*
    IF NOT wa_dt-repos IS INITIAL.
      wa_hd-total = wa_hd-total + wa_dt-netwr + wa_dt-disc1 +
                    wa_dt-freig + wa_dt-surchg + wa_dt-packchg +
                    wa_dt-beabank + wa_dt-handling + "wa_dt-impduty +
                    wa_dt-insurance + wa_dt-inlandtr + wa_dt-trans +
                    wa_dt-matcost + wa_dt-packcost.
    ENDIF.

    IF wa_dt-ebelp NE 00000.
      APPEND wa_dt TO i_dt.
      CLEAR: wa_dt-disc1, wa_dt-freig, wa_dt-surchg, wa_dt-packchg,
             wa_dt-beabank, wa_dt-handling, wa_dt-impduty,
             wa_dt-insurance, wa_dt-inlandtr, wa_dt-trans,
             wa_dt-matcost, wa_dt-packcost.
    ELSE.
      wa_dt2 = wa_dt.
      CLEAR: wa_dt-disc1, wa_dt-freig, wa_dt-surchg, wa_dt-packchg,
             wa_dt-beabank, wa_dt-handling, wa_dt-impduty,
             wa_dt-insurance, wa_dt-inlandtr, wa_dt-trans,
             wa_dt-matcost, wa_dt-packcost.
      APPEND wa_dt TO i_dt.
    ENDIF.

    IF l_count NE 0.
      wa_dt3-ebelp = 99999.
      APPEND wa_dt3 TO i_dt.

      ADD wa_dt-menge TO l_menge.
      wa_dt2-ebelp  = space.
      wa_dt2-desc   = space.
      wa_dt2-eindt  = space.
      wa_dt2-banfn  = space.
      wa_dt2-bednr  = space.
      wa_dt2-netpr  = l_netpr.
      wa_dt2-netwr  = l_netwr.
      wa_dt2-hrgsat = l_hrgsat.
      wa_dt2-menge  = l_menge.
      wa_dt2-peinh  = wa_ekpo-peinh.
      wa_hd-total = wa_hd-total + wa_dt2-disc1 + wa_dt2-freig +
                    wa_dt2-surchg + wa_dt2-packchg + wa_dt2-beabank +
                    wa_dt2-handling + "wa_dt2-impduty +
                  wa_dt2-insurance + wa_dt2-inlandtr + wa_dt2-trans +
                    wa_dt2-matcost + wa_dt2-packcost.
      APPEND wa_dt2 TO i_dt.
    ENDIF.
    CLEAR: l_menge.

    CLEAR: wa_ekpo, wa_dt, l_count.

    wa_dt-ebelp = 99998.
    APPEND wa_dt TO i_dt.
  ENDLOOP.

  IF sy-subrc EQ 0.
    READ TABLE l_doc-xekpo INTO wa_ekpo INDEX 1.
    IF wa_ekpo-emlif NE space.
* Correction for import and using SC Vendor
      IF wa_ekpo-werks NE '1601' AND l_doc-xekko-bsart = 'ZIMP' AND
         wa_ekpo-lblkz EQ 'X'.
        SELECT SINGLE adrnr
        FROM t001w
        INTO wa_hd-adrnr
        WHERE werks EQ wa_ekpo-werks.
      ELSE.
        SELECT SINGLE adrnr FROM lfa1
        INTO wa_hd-adrnr
        WHERE lifnr EQ wa_ekpo-emlif.
      ENDIF.
    ELSEIF wa_ekpo-adrnr NE space.
      wa_hd-adrnr = wa_ekpo-adrnr.
    ELSEIF wa_ekpo-adrn2 NE space.
      wa_hd-adrnr = wa_ekpo-adrn2.
    ELSEIF wa_ekpo-kunnr NE space.
      SELECT SINGLE adrnr FROM kna1
      INTO wa_hd-adrnr
      WHERE kunnr EQ wa_ekpo-kunnr.
    ELSE.
      IF wa_ekpo-werks = '1601'.
        IF wa_hd-bukrs = wa_ekpo-afnam(4).
          SELECT SINGLE adrnr
          FROM t001
          INTO wa_hd-adrnr
          WHERE bukrs EQ wa_hd-bukrs.
        ELSE.
          SELECT SINGLE adrnr FROM t001w
          INTO wa_hd-adrnr
          WHERE werks EQ wa_ekpo-afnam(4).
          IF sy-subrc <> 0.
            CLEAR va_kunnr.
            SELECT SINGLE adrnr FROM kna1 INTO wa_hd-adrnr
            WHERE kunnr = wa_ekpo-afnam(5).
            IF sy-subrc <> 0.
              CONCATENATE 'TSB' wa_ekpo-afnam(4) INTO va_kunnr.
              SELECT SINGLE adrnr FROM kna1 INTO wa_hd-adrnr
              WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT SINGLE adrnr
        FROM t001w
        INTO wa_hd-adrnr
        WHERE werks EQ wa_ekpo-werks.
      ENDIF.
    ENDIF.
    IF sy-subrc = 0.
      add_sel-addrnumber = wa_hd-adrnr.
      CALL FUNCTION 'ADDR_GET'
        EXPORTING
          address_selection = add_sel
        IMPORTING
          address_value     = adr_val
        EXCEPTIONS
          OTHERS            = 1.
* Bad design from GH
      IF va_kunnr NE space AND
      ( adr_val-name2(2) CP 'JL' OR adr_val-name2(2) CP 'Jl' ).
        wa_hd-name1_plants = adr_val-name1.
        wa_hd-stras_plants = adr_val-name2.
      ELSE.
        IF adr_val-name2 NE space.
          wa_hd-name1_plants = adr_val-name2.
        ELSE.
          wa_hd-name1_plants = adr_val-name1.
        ENDIF.
        CONCATENATE adr_val-street adr_val-house_num1
        INTO wa_hd-stras_plants
        SEPARATED BY space.

** PO IMPORT ( IMPORTED BY : )
        IF nast-kschl EQ 'ZT01' OR
          nast-kschl EQ 'ZT03' OR
          nast-kschl EQ 'ZT05' OR
          nast-kschl EQ 'ZT07'.
          IF wa_hd-bukrs EQ '8010' OR
            wa_hd-bukrs EQ '8150'.
            va_import = 1.
            SELECT SINGLE b~name1 b~street b~str_suppl3 b~city1 b~post_code1
              FROM t001 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
              INTO (wa_hd-name1_plants, wa_hd-stras_plants1, wa_hd-stras_plants, wa_hd-ort01_plants,
                    adr_val-post_code1)
              WHERE a~bukrs EQ wa_hd-bukrs.

**            IF wa_ekpo-werks EQ '0101'.
**              IF wa_ekpo-matnr(1) EQ 'I'.
*                l_name1 = wa_hd-ebeln.
*                CALL FUNCTION 'READ_TEXT'
*                  EXPORTING
*                    id       = 'F15'
*                    language = 'E'
*                    name     = l_name1
*                    object   = 'EKKO'
*                  TABLES
*                    lines    = l_lines
*                  EXCEPTIONS
*                    OTHERS   = 1.
*                IF sy-subrc EQ 0.
*                  READ TABLE l_lines INTO wa_lines INDEX 1.
*                  wa_hd-name1_plants = wa_lines-tdline.
*                ENDIF.
**              ENDIF.
**            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF nast-kschl EQ 'ZT01' OR
        nast-kschl EQ 'ZT03' OR
          nast-kschl EQ 'ZT05' OR
          nast-kschl EQ 'ZT07'.
        IF wa_hd-bukrs EQ '8010' OR
          wa_hd-bukrs EQ '8150'.
        ELSE.
          wa_hd-ort01_plants = adr_val-city1.
        ENDIF.
      ELSE.
        wa_hd-ort01_plants = adr_val-city1.
      ENDIF.

      IF adr_val-post_code1 <> '00000'.
        CONCATENATE wa_hd-ort01_plants adr_val-post_code1
        INTO wa_hd-ort01_plants
        SEPARATED BY space.
      ENDIF.
      CLEAR : adr_val, wa_hd-adrnr.
    ENDIF.
  ENDIF.
  wa_hd-werks = wa_ekpo-werks.

* Kwitansi & Payment
* Read company code address for kuitansi, except SUT

  l_name = wa_hd-ebeln.
  REFRESH: l_lines. CLEAR: l_lines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F90'
      language = 'E'
      name     = l_name
      object   = 'EKKO'
    TABLES
      lines    = l_lines
    EXCEPTIONS
      OTHERS   = 1.
* Jika ada di header text
  IF sy-subrc EQ 0.
    LOOP AT l_lines INTO wa_lines.
      IF wa_lines-tdline NE space.
        va_kunnr = wa_lines-tdline.
        SELECT SINGLE adrnr stceg FROM kna1
        INTO (wa_hd-adrnr, wa_hd-stceg_kwi)
        WHERE kunnr = va_kunnr.
        IF sy-subrc = 0.
          EXIT.
        ELSE.
          SELECT SINGLE adrnr FROM t001w INTO wa_hd-adrnr
          WHERE werks = wa_lines-tdline.
          IF sy-subrc = 0.
            CONCATENATE 'TBA' wa_lines-tdline INTO va_kunnr.
            SELECT SINGLE stceg FROM kna1
            INTO wa_hd-stceg_kwi
            WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
            IF sy-subrc = 0.
              EXIT.
            ELSE.
              CONCATENATE 'TSB' wa_lines-tdline INTO va_kunnr.
              SELECT SINGLE stceg FROM kna1
              INTO wa_hd-stceg_kwi
              WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
            ENDIF.
          ELSE.
            CONCATENATE 'TSB' va_kunnr INTO va_kunnr.
            SELECT SINGLE adrnr stceg FROM kna1
            INTO (wa_hd-adrnr, wa_hd-stceg_kwi)
            WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Jika tidak ada di header text
  IF wa_hd-adrnr EQ space.
    SELECT SINGLE adrnr FROM t001
    INTO wa_hd-adrnr
    WHERE bukrs EQ wa_hd-bukrs.
  ENDIF.

  add_sel-addrnumber = wa_hd-adrnr.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = add_sel
    IMPORTING
      address_value     = adr_val
    EXCEPTIONS
      OTHERS            = 1.

* Bad design from GH
  IF va_kunnr NE space AND
  ( adr_val-name2(2) CP 'JL' OR adr_val-name2(2) CP 'Jl' ).
    wa_hd-name1_kwi = adr_val-name1.
    wa_hd-stras_kwi = adr_val-name2.
  ELSE.
    IF adr_val-name2 NE space.
      wa_hd-name1_kwi = adr_val-name2.
    ELSE.
      wa_hd-name1_kwi = adr_val-name1.
    ENDIF.

    CONCATENATE adr_val-street adr_val-house_num1
    INTO wa_hd-stras_kwi
    SEPARATED BY space.
  ENDIF.
  wa_hd-ort01_kwi = adr_val-city1.
  IF adr_val-post_code1 <> '00000'.
    CONCATENATE wa_hd-ort01_kwi adr_val-post_code1
    INTO wa_hd-ort01_kwi
    SEPARATED BY space.
  ENDIF.

* 21/04/2005
* Get NPWP
  IF wa_hd-stceg_kwi EQ space.
    va_kunnr = adr_val-sort2.
    SELECT SINGLE stceg FROM kna1
    INTO wa_hd-stceg_kwi
    WHERE kunnr EQ va_kunnr.
    CLEAR va_kunnr.
  ENDIF.
* Tempat pembayaran
  CLEAR wa_hd-adrnr.
  REFRESH: l_lines. CLEAR: l_lines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F91'
      language = 'E'
      name     = l_name
      object   = 'EKKO'
    TABLES
      lines    = l_lines
    EXCEPTIONS
      OTHERS   = 1.
* Jika ada di header text
  IF sy-subrc EQ 0.
    LOOP AT l_lines INTO wa_lines.
      IF wa_lines-tdline NE space.
        va_kunnr = wa_lines-tdline.
        SELECT SINGLE adrnr FROM kna1 INTO wa_hd-adrnr
        WHERE kunnr = va_kunnr.
        IF sy-subrc = 0.
          EXIT.
        ELSE.
          SELECT SINGLE adrnr FROM t001w INTO wa_hd-adrnr
          WHERE werks = wa_lines-tdline.
          IF sy-subrc = 0.
            EXIT.
          ELSE.
            CONCATENATE 'TSB' va_kunnr INTO va_kunnr.
            SELECT SINGLE adrnr FROM kna1 INTO wa_hd-adrnr
            WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Jika tidak ada di header text
  IF wa_hd-adrnr EQ space.
    IF wa_ekpo-werks = '1601'.
      IF wa_hd-bukrs = wa_ekpo-afnam(4).
        SELECT SINGLE adrnr FROM t001
        INTO wa_hd-adrnr
        WHERE bukrs EQ wa_hd-bukrs.
      ELSE.
        SELECT SINGLE adrnr FROM t001w
        INTO wa_hd-adrnr
        WHERE werks EQ wa_ekpo-afnam(4).
        IF sy-subrc <> 0.
          CLEAR va_kunnr.
          CONCATENATE 'TSB' wa_ekpo-afnam(4) INTO va_kunnr.
          SELECT SINGLE adrnr FROM kna1 INTO wa_hd-adrnr
          WHERE kunnr = va_kunnr AND vbund <> 'OTHERS'.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE adrnr FROM t001w
      INTO wa_hd-adrnr
      WHERE werks EQ wa_ekpo-werks.
    ENDIF.
  ENDIF.

  add_sel-addrnumber = wa_hd-adrnr.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = add_sel
    IMPORTING
      address_value     = adr_val
    EXCEPTIONS
      OTHERS            = 1.

* Bad design from GH
  IF va_kunnr NE space AND
  ( adr_val-name2(2) CP 'JL' OR adr_val-name2(2) CP 'Jl' ).
    wa_hd-name1_pemb = adr_val-name1.
    wa_hd-stras_pemb = adr_val-name2.
  ELSE.
    IF adr_val-name2 NE space.
      wa_hd-name1_pemb = adr_val-name2.
    ELSE.
      wa_hd-name1_pemb = adr_val-name1.
    ENDIF.

    CONCATENATE adr_val-street adr_val-house_num1
    INTO wa_hd-stras_pemb
    SEPARATED BY space.
  ENDIF.

  wa_hd-ort01_pemb = adr_val-city1.
  IF adr_val-post_code1 <> '00000'.
    CONCATENATE wa_hd-ort01_pemb adr_val-post_code1
    INTO wa_hd-ort01_pemb
    SEPARATED BY space.
  ENDIF.

* PO Header Text - Vendor memo( general )
  l_name1 = wa_hd-ebeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F15'
      language = 'E'
      name     = l_name1
      object   = 'EKKO'
    TABLES
      lines    = l_lines
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc EQ 0.
    READ TABLE l_lines INTO wa_lines INDEX 1.
    wa_hd-name1_plants = wa_lines-tdline.
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
  DATA: l_count TYPE i,
        i_dt1   TYPE zgdmmst0011 OCCURS 0,
        wa_dt1  TYPE zgdmmst0011.

  APPEND LINES OF i_dt TO i_dt1.
  READ TABLE i_dt INTO wa_dt INDEX 1.
* SAP
  IF wa_dt-werks NE '1601'.
    DELETE i_dt1 WHERE ebelp EQ 99999 OR
                       ebelp EQ 99998.
    SORT i_dt1 BY banfn.
    DELETE ADJACENT DUPLICATES FROM i_dt1 COMPARING banfn.

* No Permohonan
    CLEAR: wa_dt1.
    IF wa_hd-kdatb EQ '00000000'.
      LOOP AT i_dt1 INTO wa_dt1.
        IF wa_dt1-ebelp NE 99999 AND
          wa_dt1-ebelp NE 99998  AND
          wa_dt1-banfn NE space.
          ADD 1 TO l_count.
          CASE l_count.
            WHEN 1.
              IF wa_hd-nomon1 IS INITIAL.
                wa_hd-nomon1 = wa_dt1-banfn.
              ENDIF.
            WHEN 2.
              IF wa_hd-nomon2 IS INITIAL.
                wa_hd-nomon2 = wa_dt1-banfn.
              ENDIF.
            WHEN 3.
              IF wa_hd-nomon3 IS INITIAL.
                wa_hd-nomon3 = wa_dt1-banfn.
              ENDIF.
            WHEN 4.
              IF wa_hd-nomon4 IS INITIAL.
                wa_hd-nomon4 = wa_dt1-banfn.
              ENDIF.
            WHEN 5.
              IF wa_hd-nomon5 IS INITIAL.
                wa_hd-nomon5 = wa_dt1-banfn.
              ENDIF.
            WHEN 6.
              IF wa_hd-nomon6 IS INITIAL.
                wa_hd-nomon6 = wa_dt1-banfn.
              ENDIF.
            WHEN 7.
              IF wa_hd-nomon7 IS INITIAL.
                wa_hd-nomon7 = wa_dt1-banfn.
              ENDIF.
            WHEN 8.
              IF wa_hd-nomon8 IS INITIAL.
                wa_hd-nomon8 = wa_dt1-banfn.
              ENDIF.
            WHEN 9.
              IF wa_hd-nomon9 IS INITIAL.
                wa_hd-nomon9 = wa_dt1-banfn.
              ENDIF.
            WHEN 10.
              IF wa_hd-nomon10 IS INITIAL.
                wa_hd-nomon10 = wa_dt1-banfn.
              ENDIF.
            WHEN 11.
              IF wa_hd-nomon11 IS INITIAL.
                wa_hd-nomon11 = wa_dt1-banfn.
              ENDIF.
            WHEN 12.
              IF wa_hd-nomon12 IS INITIAL.
                wa_hd-nomon12 = wa_dt1-banfn.
              ENDIF.
          ENDCASE.
          IF l_count EQ 12.
            CLEAR: l_count.
            EXIT.
          ENDIF.
        ENDIF.
        CLEAR: wa_dt1.
      ENDLOOP.
    ELSE.
      SORT l_doc-xeket BY banfn.
      LOOP AT l_doc-xeket INTO wa_eket.
*      WHERE ebeln = wa_dt1-ebeln AND
*                                             ebelp = wa_dt1-ebelp.
        READ TABLE i_dt1 INTO wa_dt1 WITH KEY ebeln = wa_eket-ebeln
                                              ebelp = wa_eket-ebelp.
        IF sy-subrc EQ 0.

          ADD 1 TO l_count.
          CASE l_count.
            WHEN 1.
              IF wa_hd-nomon1 IS INITIAL.
                wa_hd-nomon1 = wa_eket-banfn.
              ENDIF.
            WHEN 2.
              IF wa_hd-nomon2 IS INITIAL.
                wa_hd-nomon2 = wa_eket-banfn.
              ENDIF.
            WHEN 3.
              IF wa_hd-nomon3 IS INITIAL.
                wa_hd-nomon3 = wa_eket-banfn.
              ENDIF.
            WHEN 4.
              IF wa_hd-nomon4 IS INITIAL.
                wa_hd-nomon4 = wa_eket-banfn.
              ENDIF.
            WHEN 5.
              IF wa_hd-nomon5 IS INITIAL.
                wa_hd-nomon5 = wa_eket-banfn.
              ENDIF.
            WHEN 6.
              IF wa_hd-nomon6 IS INITIAL.
                wa_hd-nomon6 = wa_eket-banfn.
              ENDIF.
            WHEN 7.
              IF wa_hd-nomon7 IS INITIAL.
                wa_hd-nomon7 = wa_eket-banfn.
              ENDIF.
            WHEN 8.
              IF wa_hd-nomon8 IS INITIAL.
                wa_hd-nomon8 = wa_eket-banfn.
              ENDIF.
            WHEN 9.
              IF wa_hd-nomon9 IS INITIAL.
                wa_hd-nomon9 = wa_eket-banfn.
              ENDIF.
            WHEN 10.
              IF wa_hd-nomon10 IS INITIAL.
                wa_hd-nomon10 = wa_eket-banfn.
              ENDIF.
            WHEN 11.
              IF wa_hd-nomon11 IS INITIAL.
                wa_hd-nomon11 = wa_eket-banfn.
              ENDIF.
            WHEN 12.
              IF wa_hd-nomon12 IS INITIAL.
                wa_hd-nomon12 = wa_eket-banfn.
              ENDIF.
          ENDCASE.
          IF l_count EQ 12.
            CLEAR: l_count.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
* NON SAP
    DELETE i_dt1 WHERE ebelp EQ 99999 OR
                       ebelp EQ 99998.
    SORT i_dt1 BY bednr.
*    DELETE ADJACENT DUPLICATES FROM i_dt1 COMPARING bednr.

* No permohonan Non SAP 12/04/2006
    LOOP AT l_doc-xeket INTO wa_eket.
      READ TABLE i_dt1 INTO wa_dt1 WITH KEY ebeln = wa_eket-ebeln
                                            ebelp = wa_eket-ebelp.
      IF sy-subrc NE 0.
        DELETE l_doc-xeket.
      ENDIF.
    ENDLOOP.

    IF NOT l_doc-xeket[] IS INITIAL.
*{   REPLACE        P01K910212                                        1
*\      SELECT banfn bnfpo bednr
*\        FROM eban
*\        INTO CORRESPONDING FIELDS OF TABLE t_eban
*\        FOR ALL ENTRIES IN l_doc-xeket
*\        WHERE banfn EQ l_doc-xeket-banfn AND
*\              bnfpo EQ l_doc-xeket-bnfpo.
      "Start SOH: Shell SCI Adjustment 20240221 KRS
      SELECT banfn bnfpo bednr
        FROM eban
        INTO CORRESPONDING FIELDS OF TABLE t_eban
        FOR ALL ENTRIES IN l_doc-xeket
        WHERE banfn EQ l_doc-xeket-banfn AND
              bnfpo EQ l_doc-xeket-bnfpo
        ORDER BY PRIMARY KEY.
      "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
      IF sy-subrc EQ 0.
        t_banfn[] = t_eban[].
        t_bednr[] = t_eban[].
        DELETE ADJACENT DUPLICATES FROM t_banfn COMPARING banfn.
        DELETE ADJACENT DUPLICATES FROM t_bednr COMPARING bednr.

        SELECT banfn bnfpo ablad
          FROM ebkn
          INTO CORRESPONDING FIELDS OF TABLE t_ebkn
          FOR ALL ENTRIES IN t_bednr
          WHERE banfn EQ t_bednr-banfn AND
                bnfpo EQ t_bednr-bnfpo.

        SORT t_bednr BY banfn bnfpo.
        SORT t_ebkn BY banfn bnfpo.
        LOOP AT t_bednr.
          ADD 1 TO l_count.
          READ TABLE t_ebkn WITH KEY banfn = t_bednr-banfn
                                     bnfpo = t_bednr-bnfpo
            BINARY SEARCH.
          IF sy-subrc EQ 0.
            CASE l_count.
              WHEN 1.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon1
                                                  SEPARATED BY space.
              WHEN 2.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon2
                                                  SEPARATED BY space.
              WHEN 3.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon3
                                                  SEPARATED BY space.
              WHEN 4.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon4
                                                  SEPARATED BY space.
              WHEN 5.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon5
                                                  SEPARATED BY space.
              WHEN 6.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon6
                                                  SEPARATED BY space.
              WHEN 7.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon7
                                                  SEPARATED BY space.
              WHEN 8.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon8
                                                  SEPARATED BY space.
              WHEN 9.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon9
                                                  SEPARATED BY space.
              WHEN 10.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon10
                                                  SEPARATED BY space.
              WHEN 11.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon11
                                                  SEPARATED BY space.
              WHEN 12.
                CONCATENATE t_bednr-bednr t_ebkn-ablad INTO wa_hd-nomon12
                                                  SEPARATED BY space.
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.
          ELSE.
            CASE l_count.
              WHEN 1.
                wa_hd-nomon1 = t_bednr-bednr.
              WHEN 2.
                wa_hd-nomon2 = t_bednr-bednr.
              WHEN 3.
                wa_hd-nomon3 = t_bednr-bednr.
              WHEN 4.
                wa_hd-nomon4 = t_bednr-bednr.
              WHEN 5.
                wa_hd-nomon5 = t_bednr-bednr.
              WHEN 6.
                wa_hd-nomon6 = t_bednr-bednr.
              WHEN 7.
                wa_hd-nomon7 = t_bednr-bednr.
              WHEN 8.
                wa_hd-nomon8 = t_bednr-bednr.
              WHEN 9.
                wa_hd-nomon9 = t_bednr-bednr.
              WHEN 10.
                wa_hd-nomon10 = t_bednr-bednr.
              WHEN 11.
                wa_hd-nomon11 = t_bednr-bednr.
              WHEN 12.
                wa_hd-nomon12 = t_bednr-bednr.
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
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
  DATA: lt_tcurf    TYPE STANDARD TABLE OF tcurf,
        l_tcurf_new TYPE tcurf,
        i_date      LIKE l_doc-xekko-bedat,
        d_data      LIKE konv-kawrt.
*        d_data      TYPE i.

  DATA: d_value  LIKE zgdmmct0002-value,
        d_value2 LIKE zgdmmct0002-value,
        d_werks  LIKE zgdmmct0002-werks,
        d_werks2 LIKE zgdmmct0002-werks,
        d_sign   LIKE zgdmmct0002-user_name,
        d_sign1  LIKE zgdmmct0002-user_name1.

  DATA: va_total  TYPE p.
  DATA: l_count TYPE i,
        l_sign  TYPE i,
        l_tdline(2).

  CLEAR: wa_dt, d_value, d_value2, wa_hd-signature, l_count.

  LOOP AT l_doc-xtkomv INTO t_konv.
    CASE t_konv-kschl.
      WHEN 'ZTX1'.
        va_ppn01 = t_konv-kbetr.
        ADD t_konv-kwert TO va_ppnval.
      WHEN 'ZR01'. "Header condition
        IF t_konv-kposn = '000000'.
          va_absol = t_konv-kwert.
          IF t_konv-krech EQ 'A'.
            va_absolper = t_konv-kbetr.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.
***
  wa_hd-total = wa_hd-total + va_kwert + va_ppnval + va_absol.
  va_total    = wa_hd-total.
  IF wa_hd-waers = 'IDR'.
    va_total = va_total * 100.
  ELSE.
    i_date = l_doc-xekko-bedat.
    CONVERT DATE i_date INTO INVERTED-DATE i_date.
    l_tcurf_new-tfact = '1'.
    SELECT * FROM tcurf INTO TABLE lt_tcurf
    WHERE kurst = 'M' AND
          fcurr = wa_hd-waers AND
          tcurr = 'IDR' AND
          gdatu >= i_date.

    IF sy-subrc = 0.
      SORT lt_tcurf BY gdatu.
      READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
      l_tcurf_new-tfact = l_tcurf_new-tfact.
    ENDIF.

    IF l_tcurf_new-tfact = 1 AND wa_hd-waers <> 'THB'. "exclude Thailand Bath
      l_tcurf_new-tfact = 100.
    ENDIF.
    va_total = va_total * l_doc-xekko-wkurs * l_tcurf_new-tfact.
    d_data = va_total.
    va_total = d_data.
  ENDIF.

  l_name = wa_hd-ebeln.
  REFRESH: l_lines. CLEAR: l_lines.

** Get Signature
  break bcdik.
  IF wa_hd-lifnr = 'TSB8160'.
    CASE wa_hd-bukrs.
      WHEN '8360'.
        wa_hd-signature = 'Prayoga Wahyudianto'.
      WHEN '8010' OR '8090'.
        SELECT SINGLE user_name user_name1
          FROM zgdmmct0002n
          INTO (d_sign, d_sign1)
          WHERE ekorg = l_doc-xekko-ekorg
            AND ekgrp = l_doc-xekko-ekgrp
            AND werks = wa_hd-werks.
        IF sy-subrc = 0.
          wa_hd-signature  = d_sign.
          wa_hd-nosika     = d_sign1.
        ENDIF.

        SELECT SINGLE user_name
          FROM zgdmmct0002b
          INTO wa_hd-signature1
          WHERE zgoluser = 'B4'.

        va_sign = 3.

      WHEN OTHERS.
        SELECT SINGLE user_name
          FROM zgdmmct0002b
          INTO wa_hd-signature
          WHERE zgoluser = 'B4'.
    ENDCASE.
  ELSE.
    CASE wa_hd-ekorg.
      WHEN 'TNT'.
        PERFORM f_get_sign_2sign USING va_total.
        va_sign = 2.
      WHEN 'FAC'.
        IF wa_hd-bsart EQ 'ZIMP'.
          PERFORM f_get_sign_2sign USING va_total.
          va_sign = 2.
        ELSE.
          PERFORM f_get_sign_1sign USING va_total.
          IF wa_hd-signature1 IS NOT INITIAL.
            va_sign = 2.
          ELSE.
            va_sign = 1.
          ENDIF.
        ENDIF.
      WHEN 'PMH'.
        PERFORM f_get_delivered_to CHANGING wa_hd-name1_plants wa_hd-stras_plants
                                            wa_hd-ort01_plants wa_hd-stceg_plants.

        SELECT SINGLE user_name
          FROM zgdmmct0002b
          INTO wa_hd-signature
          WHERE zgoluser = 'E1'.
        SELECT SINGLE user_name
          FROM zgdmmct0002b
          INTO wa_hd-signature1
          WHERE zgoluser = 'E2'.
        SELECT SINGLE user_name
          FROM zgdmmct0002b
          INTO wa_hd-signature2
          WHERE zgoluser = 'E3'.

      WHEN OTHERS.
        PERFORM f_get_sign_1sign USING va_total.
        va_sign = 1.
    ENDCASE.
  ENDIF.

  IF wa_hd-bukrs = '8330'.
    va_sign = 2.
  ENDIF.

*  IF wa_hd-ekorg EQ 'TNT'.
*    PERFORM f_get_sign_2sign.
*  ELSE.
*    PERFORM f_get_sign_1sign.
*  ENDIF.
** end signature

* No Permohonan
  DO 12 TIMES.
    ADD 1 TO l_count.
    CASE l_count.
      WHEN 1.
        wa_nomon-nomon = wa_hd-nomon1.
      WHEN 2.
        wa_nomon-nomon = wa_hd-nomon2.
      WHEN 3.
        wa_nomon-nomon = wa_hd-nomon3.
      WHEN 4.
        wa_nomon-nomon = wa_hd-nomon4.
      WHEN 5.
        wa_nomon-nomon = wa_hd-nomon5.
      WHEN 6.
        wa_nomon-nomon = wa_hd-nomon6.
      WHEN 7.
        wa_nomon-nomon = wa_hd-nomon7.
      WHEN 8.
        wa_nomon-nomon = wa_hd-nomon8.
      WHEN 9.
        wa_nomon-nomon = wa_hd-nomon9.
      WHEN 10.
        wa_nomon-nomon = wa_hd-nomon10.
      WHEN 11.
        wa_nomon-nomon = wa_hd-nomon11.
      WHEN 12.
        wa_nomon-nomon = wa_hd-nomon12.
    ENDCASE.
    APPEND wa_nomon TO i_nomon.
  ENDDO.
  DELETE ADJACENT DUPLICATES FROM i_nomon.
  DELETE i_nomon WHERE nomon EQ space.
  CLEAR: l_count.
  CLEAR: wa_hd-nomon1, wa_hd-nomon2, wa_hd-nomon3, wa_hd-nomon4,
         wa_hd-nomon5, wa_hd-nomon6, wa_hd-nomon7, wa_hd-nomon8,
         wa_hd-nomon9, wa_hd-nomon10, wa_hd-nomon11, wa_hd-nomon12.

  CLEAR: wa_nomon.
  LOOP AT i_nomon INTO wa_nomon.
    ADD 1 TO l_count.
    CASE l_count.
      WHEN 1.
        wa_hd-nomon1 = wa_nomon-nomon.
      WHEN 2.
        wa_hd-nomon2 = wa_nomon-nomon.
      WHEN 3.
        wa_hd-nomon3 = wa_nomon-nomon.
      WHEN 4.
        wa_hd-nomon4 = wa_nomon-nomon.
      WHEN 5.
        wa_hd-nomon5 = wa_nomon-nomon.
      WHEN 6.
        wa_hd-nomon6 = wa_nomon-nomon.
      WHEN 7.
        wa_hd-nomon7 = wa_nomon-nomon.
      WHEN 8.
        wa_hd-nomon8 = wa_nomon-nomon.
      WHEN 9.
        wa_hd-nomon9 = wa_nomon-nomon.
      WHEN 10.
        wa_hd-nomon10 = wa_nomon-nomon.
      WHEN 11.
        wa_hd-nomon11 = wa_nomon-nomon.
      WHEN 12.
        wa_hd-nomon12 = wa_nomon-nomon.
    ENDCASE.
    CLEAR: wa_nomon.
  ENDLOOP.
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
  DATA : lv_count             TYPE int4,
         job_output_info      TYPE ssfcrescl,
         job_output_options   TYPE ssfcresop,
         spoolids             TYPE rspoid.

  lv_count  = STRLEN( wa_hd-name1_to ).
  IF lv_count > 28.
    wa_hd-flag = 'X'.
  ENDIF.

  CLEAR l_doc.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    AUTHORITY-CHECK OBJECT 'M_BEST_EKO'
        ID 'ACTVT' FIELD '04'
        ID 'EKORG' FIELD wa_hd-ekorg.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized to Print PO'
       wa_hd-ekorg.
    ENDIF.

    CASE nast-kschl.
      WHEN 'ZT02' OR 'ZT04' OR 'ZT06' OR 'ZT08'.
        CASE wa_hd-mwskz.
          WHEN 'M1' OR 'M5'.
            va_tax = 1.
          WHEN 'B1' OR 'B3'.
            IF wa_hd-bukrs EQ '8020' AND
              ( wa_hd-ekorg EQ 'TNT' OR wa_hd-ekorg EQ 'O2O' ).
              va_tax = 1.
            ELSE.
              va_tax = space.
            ENDIF.
          WHEN OTHERS.
            va_tax = space.
        ENDCASE.

        IF nast-nacha EQ 5.
          CALL FUNCTION d_smrt_funcmod
            EXPORTING
              control_parameters = d_ctrl_param
              output_options     = d_output_opt
              user_settings      = space
              wa_hd              = wa_hd
              wa_deliv           = wa_deliv
              va_kwert           = va_kwert
              va_kschl           = va_kschl
              va_absol           = va_absol
              va_absolper        = va_absolper
              va_ppn01           = va_ppn01
              va_ppnval          = va_ppnval
              va_vtext           = va_vtext
              va_rev             = va_rev
              va_import          = va_import
              va_tax             = va_tax
              va_sign            = va_sign
            IMPORTING
              job_output_info    = job_output_info                      " Add this parameter
              job_output_options = job_output_options
            TABLES
              i_dt               = i_dt.
        ELSE.
          CALL FUNCTION d_smrt_funcmod
            EXPORTING
              control_parameters = d_ctrl_param
              output_options     = d_output_opt
              user_settings      = space
              wa_hd              = wa_hd
              va_kwert           = va_kwert
              va_kschl           = va_kschl
              va_absol           = va_absol
              va_absolper        = va_absolper
              va_ppn01           = va_ppn01
              va_ppnval          = va_ppnval
              va_vtext           = va_vtext
              va_rev             = va_rev
              va_import          = va_import
              va_tax             = va_tax
              va_sign            = va_sign
            IMPORTING
              job_output_info    = job_output_info                      " Add this parameter
              job_output_options = job_output_options
            TABLES
              i_dt               = i_dt.
        ENDIF.
      WHEN OTHERS.
        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            wa_hd              = wa_hd
            wa_deliv           = wa_deliv
            va_kwert           = va_kwert
            va_kschl           = va_kschl
            va_absol           = va_absol
            va_absolper        = va_absolper
            va_ppn01           = va_ppn01
            va_ppnval          = va_ppnval
            va_vtext           = va_vtext
            va_rev             = va_rev
            va_import          = va_import
            va_tax             = va_tax
            va_sign            = va_sign
          IMPORTING
            job_output_info    = job_output_info                      " Add this parameter
            job_output_options = job_output_options
          TABLES
            i_dt               = i_dt.
    ENDCASE.
  ENDIF.

  READ TABLE job_output_info-spoolids INTO spoolids INDEX 1.
  IF sy-subrc = 0.
    va_rqident  = spoolids.
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
  REFRESH: t_lines, i_dt, i_nomon.
  CLEAR: wa_hd, wa_dt, wa_nomon, va_kwert.
  CLEAR: va_kwert, va_kschl, va_absol, va_ppn01, va_ppnval, va_vtext.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  f_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initial_data.
  CLEAR: t_konv-kwert.
*  read table i_nast with key
  SELECT *
    FROM nast
    INTO CORRESPONDING FIELDS OF TABLE i_nast
    WHERE kappl EQ 'EF'       AND
          objky EQ nast-objky AND
          kschl EQ nast-kschl AND
          vstat EQ '1'        AND
          aende EQ 'X'        AND
          spras EQ 'EN'.

  IF p_disp EQ space.
    IF sy-tcode EQ 'ZGDME9F'.
      IF i_nast IS INITIAL.
        nast-dimme = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE i_nast LINES va_revisi.

  gs_ekko   = l_doc-xekko.
  gt_ekpo[] = l_doc-xekpo[].
ENDFORM.                    " f_initial_data

*&---------------------------------------------------------------------*
*&      Form  f_authority_cek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_authority_cek.
  DATA: wa_xekpo LIKE ekpo.

  READ TABLE l_doc-xekpo INTO wa_xekpo INDEX 1.
  IF sy-subrc EQ 0.
    AUTHORITY-CHECK OBJECT 'M_BEST_WRK'
             ID 'ACTVT' FIELD '03'
             ID 'WERKS' FIELD wa_xekpo-werks.
    IF sy-subrc NE 0.
      MESSAGE i002(zz) WITH
        'You have no authorization'.
      STOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_authority_cek

*&---------------------------------------------------------------------*
*&      Form  f_get_sign_2sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sign_2sign USING fd_total.
  DATA: l_sign  TYPE i,
        l_tdline(2).

  DATA: d_value  LIKE zgdmmct0002-value,
        d_value2 LIKE zgdmmct0002-value,
        d_werks  LIKE zgdmmct0002-werks,
        d_werks2 LIKE zgdmmct0002-werks,
        d_sign   LIKE zgdmmct0002-user_name.

  CLEAR: l_sign.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F01'
      language = 'E'
      name     = l_name
      object   = 'EKKO'
    TABLES
      lines    = l_lines
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc EQ 0.
    LOOP AT l_lines INTO wa_lines.
      ADD 1 TO l_sign.
      IF wa_lines-tdline NE space.
        CASE l_sign.
          WHEN 1.
            l_tdline = wa_lines-tdline(2).
            TRANSLATE l_tdline TO UPPER CASE.
            SELECT SINGLE user_name
              FROM zgdmmct0002b
              INTO wa_hd-signature
              WHERE zgoluser EQ l_tdline.
            IF sy-subrc NE 0.
              wa_hd-signature = wa_lines-tdline(40).
            ENDIF.
          WHEN 2.
            l_tdline = wa_lines-tdline(2).
            TRANSLATE l_tdline TO UPPER CASE.
            SELECT SINGLE user_name
              FROM zgdmmct0002b
              INTO wa_hd-signature1
              WHERE zgoluser EQ l_tdline.
            IF sy-subrc NE 0.
              wa_hd-signature1 = wa_lines-tdline(40).
            ENDIF.
            EXIT.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF wa_hd-signature IS INITIAL.
    SELECT value user_name werks FROM zgdmmct0002a
    INTO (d_value, d_sign, d_werks)
    WHERE ekorg = l_doc-xekko-ekorg AND
          ekgrp = l_doc-xekko-ekgrp AND
          ( werks = space OR
          werks = wa_hd-werks ) AND
          value < fd_total.
      IF d_value > d_value2 OR
* Untuk kondisi awal
       ( d_value = d_value2 AND wa_hd-signature EQ space ).
        d_werks2 = d_werks.
        d_value2 = d_value.
        wa_hd-signature  = d_sign.
* Jika ada plant specific data, maka dia yang harus diambil
      ELSEIF d_value  =  d_value2 AND
             d_werks2 <> d_werks  AND d_werks <> space.
        d_werks2 = d_werks.
        d_value2 = d_value.
        wa_hd-signature  = d_sign.
      ENDIF.
    ENDSELECT.
  ENDIF.

  IF wa_hd-signature1 IS INITIAL.
    SELECT value user_name1 werks FROM zgdmmct0002a
    INTO (d_value, d_sign, d_werks)
    WHERE ekorg = l_doc-xekko-ekorg AND
          ekgrp = l_doc-xekko-ekgrp AND
          ( werks = space OR
          werks = wa_hd-werks ) AND
          value < fd_total.
      IF d_value > d_value2 OR
* Untuk kondisi awal
       ( d_value = d_value2 AND wa_hd-signature1 EQ space ).
        d_werks2 = d_werks.
        d_value2 = d_value.
        wa_hd-signature1  = d_sign.
* Jika ada plant specific data, maka dia yang harus diambil
      ELSEIF d_value  =  d_value2 AND
             d_werks2 <> d_werks  AND d_werks <> space.
        d_werks2 = d_werks.
        d_value2 = d_value.
        wa_hd-signature1  = d_sign.
      ENDIF.
    ENDSELECT.
  ENDIF.

  IF l_doc-xekko-ekgrp = 'R03'.
    SELECT SINGLE user_name user_name1
      FROM zgdmmct0002n
      INTO (wa_hd-signsika, wa_hd-nosika)
      WHERE ekorg = l_doc-xekko-ekorg
        AND ekgrp = l_doc-xekko-ekgrp
        AND werks = wa_hd-werks.
  ENDIF.
ENDFORM.                    " f_get_sign_2sign

*&---------------------------------------------------------------------*
*&      Form  f_get_sign_1sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sign_1sign USING fd_total.
  DATA: l_sign  TYPE i,
        l_tdline(2).

  DATA: d_value  LIKE zgdmmct0002-value,
        d_werks  LIKE zgdmmct0002-werks,
        d_bukrs  TYPE zgdmmct0002-bukrs,
        d_bsart  TYPE zgdmmct0002-bsart,
        d_matkl  TYPE zgdmmct0002-matkl.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F01'
      language = 'E'
      name     = l_name
      object   = 'EKKO'
    TABLES
      lines    = l_lines
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc EQ 0.
    LOOP AT l_lines INTO wa_lines.
      IF wa_lines-tdline NE space.
        wa_hd-signature = wa_lines-tdline(40).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF wa_hd-signature EQ space.
    READ TABLE l_doc-xekpo INTO wa_ekpo INDEX 1.

    PERFORM f_new_signature_matrix USING fd_total.

*    PERFORM f_old_signature_matrix USING fd_total.
  ENDIF.

*  CASE p_tdform.
*    WHEN 'ZGDMMF0001_02' OR 'ZMS_PO_PREKURSOR'.
*      IF wa_hd-signature1 IS INITIAL.
*        SELECT value user_name1 werks FROM zgdmmct0002
*        INTO (d_value, d_sign, d_werks)
*        WHERE ekorg = l_doc-xekko-ekorg AND
*              ekgrp = l_doc-xekko-ekgrp AND
*              ( werks = space OR
*              werks = wa_hd-werks ) AND
*              value < fd_total.
*          IF d_value > d_value2 OR
** Untuk kondisi awal
*           ( d_value = d_value2 AND wa_hd-signature1 EQ space ).
*            d_werks2 = d_werks.
*            d_value2 = d_value.
*            wa_hd-signature1  = d_sign.
** Jika ada plant specific data, maka dia yang harus diambil
*          ELSEIF d_value  =  d_value2 AND
*                 d_werks2 <> d_werks  AND d_werks <> space.
*            d_werks2 = d_werks.
*            d_value2 = d_value.
*            wa_hd-signature1  = d_sign.
*          ENDIF.
*        ENDSELECT.
*      ENDIF.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " f_get_sign_1sign

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_XEKET
*&---------------------------------------------------------------------*
FORM f_modify_xeket .
  IF l_doc-xeket[] IS INITIAL.
    IF l_doc-xekpo[] IS NOT INITIAL.
*{   REPLACE        P01K910212                                        1
*\      SELECT *
*\        FROM eket
*\        INTO CORRESPONDING FIELDS OF TABLE l_doc-xeket
*\        WHERE ebeln = l_doc-xekko-ebeln.
      "Start SOH: Shell SCI Adjustment 20240221 KRS
      SELECT *
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE l_doc-xeket
        WHERE ebeln = l_doc-xekko-ebeln
        ORDER BY PRIMARY KEY.
      "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
    ENDIF.
  ENDIF.

  gt_eket[] = l_doc-xeket[].
ENDFORM.                    " F_MODIFY_XEKET

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDE_PRINT
*&---------------------------------------------------------------------*
FORM f_exclude_print .
  SELECT SINGLE *
    FROM zmmprnt
    INTO gs_zmmprnt
    WHERE werks = wa_hd-werks
      AND ebeln = wa_hd-ebeln.

  IF sy-subrc = 0.
    wa_hd-excld   = 'X'.
  ENDIF.
ENDFORM.                    " F_EXCLUDE_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_NEW_SIGNATURE_MATRIX
*&---------------------------------------------------------------------*
FORM f_new_signature_matrix USING   fu_total.
  DATA : lt_0002 TYPE STANDARD TABLE OF zgdmmct0002,
         ls_0002 TYPE zgdmmct0002.

  SELECT *
    FROM zgdmmct0002
    INTO CORRESPONDING FIELDS OF TABLE lt_0002
    WHERE ekorg = wa_hd-ekorg
      AND ekgrp = wa_hd-ekgrp
      AND value < fu_total.

  CLEAR ls_0002.
  READ TABLE lt_0002 INTO ls_0002
                     WITH KEY bukrs = wa_hd-bukrs
                     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    DELETE lt_0002 WHERE bukrs <> wa_hd-bukrs.
  ELSE.
    DELETE lt_0002 WHERE bukrs <> space.
  ENDIF.

  CLEAR ls_0002.
  READ TABLE lt_0002 INTO ls_0002
                     WITH KEY werks = wa_hd-werks
                     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    DELETE lt_0002 WHERE werks <> wa_hd-werks.
  ELSE.
    DELETE lt_0002 WHERE werks <> space.
  ENDIF.

  CLEAR ls_0002.
  READ TABLE lt_0002 INTO ls_0002
                     WITH KEY bsart = wa_hd-bsart
                     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    DELETE lt_0002 WHERE bsart <> wa_hd-bsart.
  ELSE.
    DELETE lt_0002 WHERE bsart <> space.
  ENDIF.

  CLEAR ls_0002.
  READ TABLE lt_0002 INTO ls_0002
                     WITH KEY matkl = wa_ekpo-matkl
                     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    DELETE lt_0002 WHERE matkl <> wa_ekpo-matkl.
  ELSE.
    CLEAR ls_0002.
    READ TABLE lt_0002 INTO ls_0002
                       WITH KEY matkl(6) = wa_ekpo-matkl(6)
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      DELETE lt_0002 WHERE matkl(6) <> wa_ekpo-matkl(6).
    ELSE.
      CLEAR ls_0002.
      READ TABLE lt_0002 INTO ls_0002
                         WITH KEY matkl(3) = wa_ekpo-matkl(3)
                         TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE lt_0002 WHERE matkl(3) <> wa_ekpo-matkl(3).
      ELSE.
        DELETE lt_0002 WHERE matkl <> space.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR ls_0002.
  SORT lt_0002 BY value DESCENDING.
  READ TABLE lt_0002 INTO ls_0002 INDEX 1.
  IF sy-subrc = 0.
    wa_hd-signature  = ls_0002-user_name.
    wa_hd-signature1 = ls_0002-user_name1.
  ENDIF.
ENDFORM.                    " F_NEW_SIGNATURE_MATRIX

*&---------------------------------------------------------------------*
*&      Form  F_OLD_SIGNATURE_MATRIX
*&---------------------------------------------------------------------*
FORM f_old_signature_matrix  USING    fd_total.
  DATA : d_value    LIKE zgdmmct0002-value,
         d_werks    LIKE zgdmmct0002-werks,
         d_bukrs    TYPE zgdmmct0002-bukrs,
         d_bsart    TYPE zgdmmct0002-bsart,
         d_matkl    TYPE zgdmmct0002-matkl,
         s_mmct0002 TYPE zgdmmct0002.

* Cek authorization by order type and value (especially for Subcont)
* Cek authorization by company and value (especially for Subcont)
* Cek authorization by MATKL and value
* Cek authorization by value only
  SELECT * FROM zgdmmct0002
  INTO s_mmct0002
*    INTO (d_value, d_sign, d_sign2, d_werks)
  WHERE ekorg = wa_hd-ekorg AND
        ekgrp = wa_hd-ekgrp AND
      ( bukrs = space OR bukrs = wa_hd-bukrs ) AND
      ( werks = space OR werks = wa_hd-werks ) AND
      ( bsart = space OR bsart = wa_hd-bsart ) AND
      ( matkl = space OR matkl = wa_ekpo-matkl OR
        matkl = wa_ekpo-matkl(6) OR
        matkl = wa_ekpo-matkl(3) ) AND
        value < fd_total.
    IF s_mmct0002-value > d_value OR
* Untuk kondisi awal
     ( s_mmct0002-value = d_value AND wa_hd-signature EQ space ).
      d_werks = s_mmct0002-werks.
      d_bukrs = s_mmct0002-bukrs.
      d_value = s_mmct0002-value.
      d_bsart  = s_mmct0002-bsart.
      d_matkl  = s_mmct0002-matkl.
      wa_hd-signature  = s_mmct0002-user_name.
      wa_hd-signature1 = s_mmct0002-user_name1.
    ELSEIF s_mmct0002-value >= d_value AND
    ( ( d_bsart  <> s_mmct0002-bsart    AND s_mmct0002-bsart <> space ) OR
      ( d_matkl  <> s_mmct0002-matkl    AND s_mmct0002-matkl <> space ) OR
      ( d_matkl  <> s_mmct0002-matkl(6) AND s_mmct0002-matkl <> space ) OR
      ( d_matkl  <> s_mmct0002-matkl(3) AND s_mmct0002-matkl <> space ) OR
* Jika ada company specific data, maka dia yang harus diambil
      ( d_bukrs  <> s_mmct0002-bukrs    AND s_mmct0002-bukrs <> space ) OR
* Jika ada plant specific data, maka dia yang harus diambil
      ( d_werks <> s_mmct0002-werks  AND s_mmct0002-werks <> space ) ).
      IF d_bsart <> space AND s_mmct0002-bsart = space.
        CONTINUE.
      ENDIF.
      IF d_matkl <> space AND s_mmct0002-matkl = space.
        CONTINUE.
      ENDIF.
* First priority is order type
      IF d_werks <> space AND s_mmct0002-werks = space AND
         d_bsart = space AND s_mmct0002-bsart = space.
        CONTINUE.
      ENDIF.
      d_werks  = s_mmct0002-werks.
      d_bukrs  = s_mmct0002-bukrs.
      d_value  = s_mmct0002-value.
      d_bsart  = s_mmct0002-bsart.
      d_matkl  = s_mmct0002-matkl.
      wa_hd-signature  = s_mmct0002-user_name.
      wa_hd-signature1 = s_mmct0002-user_name1.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " F_OLD_SIGNATURE_MATRIX

*&---------------------------------------------------------------------*
*&      Form  F_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_email_attachment .

  DATA : lv_email       TYPE somlreci1-receiver,
         lv_smtp_addr   TYPE adr6-smtp_addr,
         lv_error       TYPE sy-subrc,
         lv_reciever    TYPE sy-subrc.


  SELECT SINGLE smtp_addr
    FROM usr21 JOIN adr6 ON usr21~addrnumber = adr6~addrnumber AND
                            usr21~persnumber = adr6~persnumber
    INTO lv_smtp_addr
    WHERE bname = sy-uname.

  lv_email  = lv_smtp_addr.

  PERFORM f_build_xls_attachment.

  PERFORM f_build_pdf_attachment.

  CHECK sy-subrc IS INITIAL.

  PERFORM f_send_file_attachment TABLES   it_message it_attach
                                 USING    lv_email
                                          gs_ekko-ebeln
                                          'XLS' 'PDF'
                                          'No.PO'
                                          ' ' ' ' ' '
                                 CHANGING lv_error lv_reciever.

  PERFORM initiate_mail_execute_program.

ENDFORM.                    " F_EMAIL_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_XLS_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_build_xls_attachment .
  CONSTANTS : con_tab   TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
              con_cret  TYPE c VALUE cl_abap_char_utilities=>cr_lf.

  DATA : lv_butxt   TYPE t001-butxt,
         lv_bedat(10),
         lv_eindt(10),
         lv_brand(50),
         lv_menge(20),
         lv_netpr(20),
         lv_netwr(20),
         lv_kbetr(20),
         ls_ekpo       TYPE ekpo,
         lv_mengettl   TYPE ekpo-menge,
         lv_netwrttl   TYPE ekpo-netwr,
         lv_mengettlt(20),
         lv_netwrttlt(20).

  DATA : ls_a934    TYPE a934,
         ls_konp    TYPE konp.

  PERFORM f_header_process CHANGING lv_butxt lv_bedat lv_eindt lv_brand.

  PERFORM f_xls_header  USING 'Company :' lv_butxt con_tab con_cret.
  PERFORM f_xls_header  USING 'PO Number :' gs_ekko-ebeln con_tab con_cret.
  PERFORM f_xls_header  USING 'PO Date :' lv_bedat con_tab con_cret.
  PERFORM f_xls_header  USING 'Requested Delivery Date :' lv_eindt con_tab con_cret.
  PERFORM f_xls_header  USING 'Brand :' lv_brand con_tab con_cret.

  it_attach = con_cret.
  APPEND it_attach.

  CONCATENATE 'PO Item Number' 'Product Number' 'Vendor Material Number'
              'Product Description' 'Quantity'
              'Unit Cost (Rp)' 'EXTENDED' 'Retail Price'
  INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  CLEAR ls_ekpo.
  LOOP AT gt_ekpo INTO ls_ekpo.
    PERFORM f_modify_value  USING ls_ekpo-menge ls_ekpo-meins 'UNIT'
                            CHANGING lv_menge.
    PERFORM f_modify_value  USING ls_ekpo-netpr gs_ekko-waers 'CURR'
                            CHANGING lv_netpr.
    PERFORM f_modify_value  USING ls_ekpo-netwr gs_ekko-waers 'CURR'
                            CHANGING lv_netwr.

    READ TABLE gt_a934 INTO ls_a934 WITH KEY matnr = ls_ekpo-matnr.
    IF sy-subrc = 0.
      READ TABLE gt_konp INTO ls_konp WITH KEY knumh = ls_a934-knumh.
      IF sy-subrc = 0.
        PERFORM f_modify_value  USING ls_konp-kbetr gs_ekko-waers 'CURR'
                                CHANGING lv_kbetr.
      ENDIF.
    ENDIF.

    CONCATENATE ls_ekpo-ebelp ls_ekpo-matnr ls_ekpo-idnlf ls_ekpo-txz01
                lv_menge lv_netpr lv_netwr lv_kbetr
    INTO it_attach SEPARATED BY con_tab.
    CONCATENATE con_cret it_attach INTO it_attach.

    APPEND it_attach.

    ADD ls_ekpo-menge TO lv_mengettl.
    ADD ls_ekpo-netwr TO lv_netwrttl.
  ENDLOOP.

  PERFORM f_modify_value  USING lv_mengettl ls_ekpo-meins 'UNIT'
                          CHANGING lv_mengettlt.
  PERFORM f_modify_value  USING lv_netwrttl gs_ekko-waers 'CURR'
                          CHANGING lv_netwrttlt.

  CONCATENATE con_tab con_tab con_tab lv_mengettlt con_tab con_tab lv_netwrttlt
  INTO it_attach.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  it_attach = con_cret.
  APPEND it_attach.

  CONCATENATE '*) Unit Cost (Rp) = estimation from 49%'
              'x net retail price = 49% x retail price / 1,1.'
  INTO it_attach SEPARATED BY space.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  DO 3 TIMES.
    it_attach = con_cret.
    APPEND it_attach.
  ENDDO.

  CONCATENATE con_tab 'Prepared by :' con_tab con_tab con_tab 'Approved by :'
  INTO it_attach.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  DO 5 TIMES.
    it_attach = con_cret.
    APPEND it_attach.
  ENDDO.

  CONCATENATE con_tab wa_hd-signature2
              con_tab con_tab wa_hd-signature
              con_tab con_tab wa_hd-signature1
  INTO it_attach.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  xlsstr  = 1.
  DESCRIBE TABLE it_attach LINES xlsend.

ENDFORM.                    " F_BUILD_XLS_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PDF_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_build_pdf_attachment .
  DATA : spoolrequests      TYPE STANDARD TABLE OF rsporq INITIAL SIZE 0,
         ls_spoolrequests   TYPE rsporq,
         pdf                LIKE tline OCCURS 0 WITH HEADER LINE,
         lv_src_spoolid     TYPE tsp01-rqident,
         lv_buffer          TYPE string.

*  CALL FUNCTION 'RSPO_FIND_SPOOL_REQUESTS'
*    TABLES
*      spoolrequests = spoolrequests
*    EXCEPTIONS
*      no_permission = 1
*      OTHERS        = 2.
*
*  SORT spoolrequests BY rqident DESCENDING.
*
*  READ TABLE spoolrequests INTO ls_spoolrequests INDEX 1.
*  IF sy-subrc = 0.
*    lv_src_spoolid  = ls_spoolrequests-rqident.
*  ENDIF.

  CALL FUNCTION 'CONVERT_OTFSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = va_rqident
    TABLES
      pdf                      = pdf
    EXCEPTIONS
      err_no_otf_spooljob      = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_dstdevice        = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.

  CHECK sy-subrc = 0.

  LOOP AT pdf.
    TRANSLATE pdf USING ' ~'.
    CONCATENATE lv_buffer pdf INTO lv_buffer.
  ENDLOOP.

  TRANSLATE lv_buffer USING '~ '.

  DO.
    it_attach = lv_buffer.
    APPEND it_attach.
    SHIFT lv_buffer LEFT BY 255 PLACES.
    IF lv_buffer IS INITIAL.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    " F_BUILD_PDF_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERED_TO
*&---------------------------------------------------------------------*
FORM f_get_delivered_to  CHANGING fu_name1 fu_stras fu_ort01 fu_stceg.
  DATA : ls_ekpo        TYPE ekpo.
  DATA : lv_street      TYPE adrc-street,
         lv_house_num1  TYPE adrc-house_num1,
         lv_city1       TYPE adrc-city1,
         lv_post_code1  TYPE adrc-post_code1.

  break bcdik.
  READ TABLE l_doc-xekpo INTO ls_ekpo INDEX 1.
  IF sy-subrc = 0.
    IF ls_ekpo-lgort IS NOT INITIAL.
      SELECT SINGLE name1 street house_num1 city1 post_code1
        FROM twlad JOIN adrc ON twlad~adrnr = adrc~addrnumber
        INTO (fu_name1, lv_street, lv_house_num1, lv_city1, lv_post_code1)
        WHERE werks = ls_ekpo-werks
          AND lgort = ls_ekpo-lgort.

      CONCATENATE lv_street lv_house_num1 INTO fu_stras
      SEPARATED BY space.
      CONCATENATE lv_city1 lv_post_code1 INTO fu_ort01
      SEPARATED BY space.
    ELSE.
      SELECT SINGLE t001w~name1 street house_num1 city1 post_code1
        FROM t001w JOIN adrc ON t001w~adrnr = adrc~addrnumber
        INTO (fu_name1, lv_street, lv_house_num1, lv_city1, lv_post_code1)
        WHERE werks = ls_ekpo-werks.

      CONCATENATE lv_street lv_house_num1 INTO fu_stras
      SEPARATED BY space.
      CONCATENATE lv_city1 lv_post_code1 INTO fu_ort01
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DELIVERED_TO

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_PROCESS
*&---------------------------------------------------------------------*
FORM f_header_process CHANGING fc_butxt fc_bedat fc_eindt fc_brand.
  DATA : ls_ekpo    TYPE ekpo,
         ls_eket    TYPE eket,
         lv_matkl   TYPE mara-matkl,
         lv_prodh   TYPE t179-prodh.

  SELECT SINGLE butxt
    FROM t001
    INTO fc_butxt
    WHERE bukrs = gs_ekko-bukrs.

  TRANSLATE fc_butxt TO UPPER CASE.

  WRITE gs_ekko-bedat TO fc_bedat DD/MM/YYYY.

  CLEAR ls_eket.
  READ TABLE gt_eket INTO ls_eket INDEX 1.
  IF sy-subrc = 0.
    WRITE ls_eket-eindt TO fc_eindt DD/MM/YYYY.
  ENDIF.

  CLEAR ls_ekpo.
  READ TABLE gt_ekpo INTO ls_ekpo INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE matkl
      FROM mara
      INTO lv_matkl
      WHERE matnr = ls_ekpo-matnr.

    IF sy-subrc = 0.
      lv_prodh  = lv_matkl(6).
      SELECT SINGLE vtext
        FROM t179t
        INTO fc_brand
        WHERE spras = sy-langu
          AND prodh = lv_prodh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_HEADER_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_XLS_HEADER
*&---------------------------------------------------------------------*
FORM f_xls_header  USING    fu_cell1 fu_cell2 con_tab con_cret.
  CONCATENATE fu_cell1 fu_cell2
  INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.
ENDFORM.                    " F_XLS_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_SEND_FILE_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_send_file_attachment  TABLES   pit_message
                                      pit_attach
                             USING    p_email p_mtitle p_format1 p_format2
                                      p_filename p_attdescription
                                      p_sender_address p_sender_addres_type
                             CHANGING p_error p_reciever.

  DATA : lv_error               TYPE sy-subrc,
         lv_reciever            TYPE sy-subrc,
         lv_mtitle              LIKE sodocchgi1-obj_descr,
         lv_email               LIKE somlreci1-receiver,
         lv_format1             TYPE so_obj_tp ,
         lv_format2             TYPE so_obj_tp ,
         lv_attdescription      TYPE so_obj_nam ,
         lv_attfilename         TYPE so_obj_des ,
         lv_sender_address      LIKE soextreci1-receiver,
         lv_sender_address_type LIKE soextreci1-adr_typ,
         lv_receiver            LIKE sy-subrc.

  DATA : w_doc_data             LIKE sodocchgi1,
         w_cnt                  TYPE i,
         w_sent_all(1)          TYPE c.

  DATA : lt_attachment          LIKE solisti1 OCCURS 0 WITH HEADER LINE,
         lt_packing_list        LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
         lt_receivers           LIKE somlreci1 OCCURS 0 WITH HEADER LINE.

  lv_email               = p_email.
  lv_mtitle              = p_mtitle.
  lv_format1             = p_format1.
  lv_format2             = p_format2.
  lv_attdescription      = p_attdescription.
  lv_attfilename         = p_filename.
  lv_sender_address      = p_sender_address.
  lv_sender_address_type = p_sender_addres_type.

  w_doc_data-doc_size    = 1.

  w_doc_data-obj_langu   = sy-langu.
  w_doc_data-obj_name    = 'SAPRPT'.
  w_doc_data-obj_descr   = lv_mtitle .
  w_doc_data-sensitivty  = 'F'.

  CLEAR w_doc_data.
  READ TABLE it_attach INDEX w_cnt.
  w_doc_data-doc_size    = ( w_cnt - 1 ) * 255 + STRLEN( it_attach ).
  w_doc_data-obj_langu   = sy-langu.
  w_doc_data-obj_name    = 'SAPRPT'.
  w_doc_data-obj_descr   = lv_mtitle.
  w_doc_data-sensitivty  = 'F'.
  CLEAR lt_attachment.
  REFRESH lt_attachment.
  lt_attachment[] = pit_attach[].

  CLEAR lt_packing_list.
  REFRESH lt_packing_list.
  lt_packing_list-transf_bin = space.
  lt_packing_list-head_start = 1.
  lt_packing_list-head_num   = 0.
  lt_packing_list-body_start = 1.
  DESCRIBE TABLE it_message LINES lt_packing_list-body_num.
  lt_packing_list-doc_type = 'RAW'.
  APPEND lt_packing_list.

  lt_packing_list-transf_bin = 'X'.
  lt_packing_list-head_start = 1.
  lt_packing_list-head_num   = 1.
  lt_packing_list-body_start = xlsstr.

  lt_packing_list-body_num   = xlsend.
  lt_packing_list-doc_type   = lv_format1.
  lt_packing_list-obj_descr  = lv_attdescription.
  lt_packing_list-obj_name   = lv_attfilename.
  lt_packing_list-doc_size   = lt_packing_list-body_num * 255.
  APPEND lt_packing_list.

  lt_packing_list-transf_bin = 'X'.
  lt_packing_list-head_start = 1.
  lt_packing_list-head_num   = 1.
  lt_packing_list-body_start = xlsend + 1.

  DESCRIBE TABLE lt_attachment LINES lt_packing_list-body_num.
  lt_packing_list-doc_type   = lv_format2.
  lt_packing_list-obj_descr  = lv_attdescription.
  lt_packing_list-obj_name   = lv_attfilename.
  lt_packing_list-doc_size   = lt_packing_list-body_num * 255.
  APPEND lt_packing_list.

  CLEAR lt_receivers.
  REFRESH lt_receivers.
  lt_receivers-receiver   = lv_email.
  lt_receivers-rec_type   = 'U'.
  lt_receivers-com_type   = 'INT'.
  lt_receivers-notif_del  = 'X'.
  lt_receivers-notif_ndel = 'X'.
  APPEND lt_receivers.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = w_doc_data
      put_in_outbox              = 'X'
      sender_address             = lv_sender_address
      sender_address_type        = lv_sender_address_type
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = w_sent_all
    TABLES
      packing_list               = lt_packing_list
      contents_bin               = lt_attachment
      contents_txt               = it_message
      receivers                  = lt_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  lv_error = sy-subrc.

  LOOP AT lt_receivers.
    lv_receiver       = lt_receivers-retrn_code.
  ENDLOOP.
ENDFORM.                    " F_SEND_FILE_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------*
FORM initiate_mail_execute_program .
  WAIT UP TO 2 SECONDS.
  SUBMIT rsconn01 WITH mode = 'INT'
                  WITH output = 'X'
                  AND RETURN.
ENDFORM.                    " INITIATE_MAIL_EXECUTE_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_satuan fu_flag
                     CHANGING fc_value.

  CLEAR fc_value.

  CASE fu_flag.
    WHEN 'UNIT'.
      WRITE fu_value TO fc_value UNIT fu_satuan.
    WHEN 'CURR'.
      WRITE fu_value TO fc_value CURRENCY fu_satuan.
  ENDCASE.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_GET_RETAIL_PRICE
*&---------------------------------------------------------------------*
FORM f_get_retail_price .
  DATA : lt_ekpo  TYPE STANDARD TABLE OF ekpo INITIAL SIZE 0
                  WITH HEADER LINE.

  lt_ekpo[] = gt_ekpo[].
  SORT lt_ekpo BY matnr.

  IF lt_ekpo[] IS NOT INITIAL.
    SELECT *
      FROM a934
      INTO CORRESPONDING FIELDS OF TABLE gt_a934
      FOR ALL ENTRIES IN lt_ekpo
      WHERE kappl = 'V'
        AND kschl = 'ZHM1'
        AND vkorg = gs_ekko-bukrs
        AND matnr = lt_ekpo-matnr
        AND datab <= gs_ekko-aedat
        AND datbi >= gs_ekko-aedat.

    IF gt_a934[] IS NOT INITIAL.
      SELECT * FROM konp
        INTO CORRESPONDING FIELDS OF TABLE gt_konp
        FOR ALL ENTRIES IN gt_a934
        WHERE knumh = gt_a934-knumh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_RETAIL_PRICE
