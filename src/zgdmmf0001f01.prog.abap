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
  PERFORM f_modify_xeket.
  PERFORM f_initial_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_exclude_print.
  PERFORM f_print_form.
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
  DATA: sw       TYPE i,
        ld_adrnr LIKE t001w-adrnr,
        ld_emlif LIKE ekpo-emlif.

  DATA : adr_val TYPE addr1_val,
         add_sel TYPE addr1_sel.
  DATA: l_name(70),
        l_name1(70),
        l_lines     TYPE tline OCCURS 0,
        wa_lines    TYPE tline,
        d_currdec   TYPE tcurx-currdec,
        l_komk      TYPE komk,
        xtkomvd     TYPE komvd OCCURS 0.

  DATA: lt_tcurf    TYPE STANDARD TABLE OF tcurf,
        l_tcurf_new TYPE tcurf,
        i_date      LIKE mcekko-bedat.

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
  wa_hd-frggr = l_doc-xekko-frggr.
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
    wa_hd-telf1    = adr_val-tel_number.
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
                  adrc~location adrc~city2 telf1
      FROM lfa1 INNER JOIN adrc
      ON   adrc~addrnumber = lfa1~adrnr
* Remove country data on 28 June 2005
*      INNER JOIN t005t
*      ON   t005t~land1 = adrc~country
      INTO (wa_hd-name1_to, wa_hd-stras_to, wa_hd-ort01_to,
            wa_hd-city2_to, wa_hd-telf1)
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

    IF wa_dt-ematn EQ space.
      wa_dt-desc = wa_dt-txz01.
    ELSEIF wa_dt-idnlf EQ space.
      CONCATENATE wa_dt-ematn '  ' wa_dt-txz01 INTO wa_dt-desc
        SEPARATED BY space.
    ELSE.
      CONCATENATE wa_dt-ematn '  ' wa_dt-idnlf INTO wa_dt-desc
        SEPARATED BY space.
    ENDIF.


* Tax indicator
    SELECT SINGLE taxim FROM mlan
      INTO wa_dt-taxim
      WHERE matnr EQ wa_ekpo-ematn AND
            aland EQ 'ID'.

    CLEAR : t_konv.
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

* Untuk PO ?????
    IF sy-subrc NE 0.
      IF wa_hd-bsart = 'ZO2O'.
        READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                                     kposn = wa_ekpo-ebelp
                                                     kschl = 'ZHJP'.
      ENDIF.
    ENDIF.

**** DEVK960868
***** Untuk PO dengan subcontracting
****    IF sy-subrc NE 0.
****      READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
****                                                   kposn = wa_ekpo-ebelp
****                                                   kschl = 'ZHSC'.
****    ENDIF.

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
    CLEAR t_konv-kwert.
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

        WHEN 'ZKM3'.
          PERFORM f_get_value USING t_konv-kschl t_konv-kwert l_doc-xekko-waers
                              CHANGING wa_dt-vtext_zkm3 wa_dt-kwert_zkm3 wa_dt-kbetr_zkm3.
        WHEN 'ZKM4'.
          PERFORM f_get_value USING t_konv-kschl t_konv-kwert l_doc-xekko-waers
                              CHANGING wa_dt-vtext_zkm4 wa_dt-kwert_zkm4 wa_dt-kbetr_zkm4.
        WHEN 'ZKM5'.
          PERFORM f_get_value USING t_konv-kschl t_konv-kwert l_doc-xekko-waers
                              CHANGING wa_dt-vtext_zkm5 wa_dt-kwert_zkm5 wa_dt-kbetr_zkm5.

        WHEN 'ZHSC'.
          CASE wa_ekpo-werks.
            WHEN '0101' OR '0102'.
              PERFORM f_get_text_value CHANGING wa_dt-vtext12 wa_dt-kbetr12
                                                wa_dt-srvcost.
            WHEN OTHERS.
              PERFORM f_get_text_value CHANGING wa_dt-vtext1 wa_dt-kbetr2
                                                wa_dt-surchg.
          ENDCASE.

        WHEN 'ZHMC'.
          PERFORM f_get_text_value CHANGING wa_dt-vtext10 wa_dt-kbetr10
                                            wa_dt-matcost.

        WHEN 'ZHPC'.
          CASE wa_ekpo-werks.
            WHEN '0101' OR '0102'.
              PERFORM f_get_text_value CHANGING wa_dt-vtext11 wa_dt-kbetr11
                                                wa_dt-packcost.
            WHEN OTHERS.
              PERFORM f_get_text_value CHANGING wa_dt-vtext2 wa_dt-kbetr3
                                                wa_dt-packchg.
          ENDCASE.
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
            WHEN 'ZHPC'.
              wa_dt-vtext11 = wa_lines-tdline+5(25).
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
                    wa_dt-matcost + wa_dt-packcost + wa_dt-srvcost -
                    ( wa_dt-kwert_zkm3 + wa_dt-kwert_zkm4 + wa_dt-kwert_zkm5 ).
    ENDIF.

    IF wa_dt-ebelp NE 00000.
      APPEND wa_dt TO i_dt.
      CLEAR: wa_dt-disc1, wa_dt-freig, wa_dt-surchg, wa_dt-packchg,
             wa_dt-beabank, wa_dt-handling, wa_dt-impduty,
             wa_dt-insurance, wa_dt-inlandtr, wa_dt-trans,
             wa_dt-matcost, wa_dt-packcost, wa_dt-srvcost,
             wa_dt-kwert_zkm3, wa_dt-kwert_zkm4, wa_dt-kwert_zkm5.
    ELSE.
      wa_dt2 = wa_dt.
      CLEAR: wa_dt-disc1, wa_dt-freig, wa_dt-surchg, wa_dt-packchg,
             wa_dt-beabank, wa_dt-handling, wa_dt-impduty,
             wa_dt-insurance, wa_dt-inlandtr, wa_dt-trans,
             wa_dt-matcost, wa_dt-packcost, wa_dt-srvcost,
             wa_dt-kwert_zkm3, wa_dt-kwert_zkm4, wa_dt-kwert_zkm5.
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
                    wa_dt2-matcost + wa_dt2-packcost + wa_dt2-srvcost -
                    ( wa_dt2-kwert_zkm3 + wa_dt2-kwert_zkm4 + wa_dt2-kwert_zkm5 ).
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

*--------------------------------------------------------------------*
* Adding condition for '8360'
  DATA: lv_adrnr LIKE t001-adrnr.

  IF wa_hd-bukrs = '8360'.
    SELECT SINGLE adrnr
    FROM t001
    INTO lv_adrnr
    WHERE bukrs EQ wa_hd-bukrs.
  ENDIF.

  add_sel-addrnumber = lv_adrnr.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = add_sel
    IMPORTING
      address_value     = adr_val
    EXCEPTIONS
      OTHERS            = 1.

  IF adr_val-name2 NE space.
    wa_hd-name1_bukrs = adr_val-name2.
  ELSE.
    wa_hd-name1_bukrs = adr_val-name1.
  ENDIF.
  CONCATENATE adr_val-street adr_val-house_num1
  INTO wa_hd-stras_bukrs SEPARATED BY space.
  wa_hd-ort01_bukrs = adr_val-city1.
* End adding
*--------------------------------------------------------------------*

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
          wa_hd-kwitxt  = 'X'.
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
  ELSE.
    CLEAR va_kunnr.
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
*  PERFORM f_old_kwi USING adr_val.
  PERFORM f_new_kwi USING adr_val.

  IF wa_hd-kwitxt IS NOT INITIAL.
    IF ( adr_val-name1(2) CP 'PT' OR adr_val-name1(2) CP 'pt' ).
      wa_hd-name1_kwi1 = adr_val-name1.
      CONCATENATE adr_val-name2 adr_val-name3 INTO wa_hd-stras_kwi1
      SEPARATED BY space.
      wa_hd-ort01_kwi1 = adr_val-name4.
    ELSE.
      wa_hd-name1_kwi1 = adr_val-name1.
      wa_hd-stras_kwi1 = adr_val-name2.
      wa_hd-ort01_kwi1 = adr_val-name3.
    ENDIF.
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
  ELSE.
    CLEAR va_kunnr.
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

  BREAK bcdik.
  IF wa_hd-bukrs = '8060'.
    SELECT SINGLE adrnr
      FROM t001
      INTO wa_hd-adrnr
      WHERE bukrs = wa_hd-bukrs.
    IF sy-subrc = 0.
      SELECT SINGLE name1 street str_suppl2 location city1
        FROM adrc
        INTO (wa_hd-name1_pemb, wa_hd-stras_pemb, wa_hd-str_suppl2,
              wa_hd-location, wa_hd-ort01_pemb)
        WHERE addrnumber = wa_hd-adrnr.
    ENDIF.
  ENDIF.

  SELECT SINGLE butxt
    FROM t001
    INTO wa_hd-butxt
    WHERE bukrs = wa_hd-bukrs.

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
*{   REPLACE        P01K910208                                        1
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
  DATA: l_count     TYPE i,
        l_sign      TYPE i,
        l_tdline(2).

  DATA : ls_ekpo  TYPE ekpo.

  CLEAR: wa_dt, d_value, d_value2, wa_hd-signature, l_count.

  LOOP AT l_doc-xtkomv INTO t_konv.
    CASE t_konv-kschl.
      WHEN 'ZTX1'.
        READ TABLE l_doc-xekpo INTO ls_ekpo
                                 WITH KEY ebelp = t_konv-kposn.
        IF sy-subrc = 0.
          va_ppn01 = t_konv-kbetr.
          ADD t_konv-kwert TO va_ppnval.
        ENDIF.
      WHEN 'ZR01'. "Header condition
        IF t_konv-kposn <> '000000'.
          READ TABLE l_doc-xekpo INTO ls_ekpo
                                 WITH KEY ebelp = t_konv-kposn.
          IF sy-subrc = 0.
            ADD t_konv-kwert TO va_absol.
            IF t_konv-krech EQ 'A'.
              va_absolper = t_konv-kbetr.
            ENDIF.
          ENDIF.
        ENDIF.

*        IF t_konv-kposn = '000000'.
*          va_absol = t_konv-kwert.
*          IF t_konv-krech EQ 'A'.
*            va_absolper = t_konv-kbetr.
*          ENDIF.
*        ENDIF.
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
  BREAK bcdik.
  IF wa_hd-lifnr = 'TSB8160'.
    CASE wa_hd-bukrs.
      WHEN '8360'.
*        wa_hd-signature = 'Prayoga Wahyudianto'.
        wa_hd-signature = 'I Made Dharma Wijaya'.
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
      WHEN OTHERS.
        PERFORM f_get_sign_1sign USING va_total.
        va_sign = 1.
    ENDCASE.
  ENDIF.

  IF wa_hd-bukrs = '8330'.
    IF wa_hd-ekorg = 'LCP'.
      va_sign = 1.
    ELSE.
      IF wa_hd-signature1 IS NOT INITIAL.
        va_sign = 2.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR wa_hd-telf1.
  ENDIF.

  IF wa_hd-ekorg <> 'FAC'.
    CLEAR wa_hd-telf1.
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

  IF nast-kschl = 'ZT05' OR nast-kschl = 'ZT07'.
    IF wa_hd-bedat LT '20230724'.
      CLEAR: wa_hd-banka,wa_hd-bkref1,wa_hd-bkref2,wa_hd-bkref3,wa_hd-swift.
    ELSE.
      PERFORM f_get_payment_detail.
    ENDIF.
  ENDIF.
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
  DATA : lv_count TYPE int4,
         lt_graph TYPE STANDARD TABLE OF stxbitmaps.

  SELECT SINGLE str03
    FROM zsd_sertifikasi
    INTO wa_hd-str03
    WHERE vkbur = wa_hd-werks.

  lv_count  = strlen( wa_hd-name1_to ).
  IF lv_count > 28.
    wa_hd-flag = 'X'.
  ENDIF.

  CLEAR t_konv.
  READ TABLE l_doc-xtkomv INTO t_konv WITH KEY knumv = wa_hd-knumv
                                               kschl = 'ZFEE'
                                               kinak = space.
  IF t_konv-kbetr IS NOT INITIAL.
    WRITE t_konv-kbetr TO wa_hd-zfee CURRENCY t_konv-waers.
    CONDENSE wa_hd-zfee.
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
**** tambahan untuk send po ke eprocurement  ( 29 agt 2023 by suk )
    PERFORM send_po(zhsmmm_i004) USING wa_hd-ebeln sy-subrc sy-subrc.
*** end tambahan

*----- DEVK968763 cancel -----
********    IF nast-kschl = 'ZT05' OR
********      nast-kschl = 'ZT06'.
********      IF wa_hd-total < '15000000.00'.
********        IF wa_hd-frggr IS NOT INITIAL.
********          SELECT *
********            FROM stxbitmaps
********            INTO CORRESPONDING FIELDS OF TABLE lt_graph
********            WHERE tdobject = 'GRAPHICS'
********              AND tdid     = 'BMAP'
********              AND tdbtype  = 'BMON'.
********
********          CASE wa_hd-ekgrp.
********            WHEN 'R03'.
********              PERFORM f_esign TABLES lt_graph
********                              USING wa_hd-signsika
********                              CHANGING wa_hd-esign1.
********              wa_hd-esign1  = 'SAMPLE'.
********              PERFORM f_esign TABLES lt_graph
********                              USING wa_hd-signature
********                              CHANGING wa_hd-esign2.
********              PERFORM f_esign TABLES lt_graph
********                              USING wa_hd-signature1
********                              CHANGING wa_hd-esign3.
********            WHEN OTHERS.
********              PERFORM f_esign TABLES lt_graph
********                              USING wa_hd-signature
********                              CHANGING wa_hd-esign2.
********              PERFORM f_esign TABLES lt_graph
********                              USING wa_hd-signature1
********                              CHANGING wa_hd-esign3.
********          ENDCASE.
********        ENDIF.
********      ENDIF.
********    ENDIF.

    IF wa_hd-ihrez(2) = 'LP'.
      va_sign2 = 100.
    ELSE.
      va_sign2 = 0.
    ENDIF.
    CASE nast-kschl.
      WHEN 'ZT02' OR 'ZT04' OR 'ZT06' OR 'ZT08'.
        CASE wa_hd-mwskz.
          WHEN 'M1' OR 'M5'.
            va_tax = 1.
          WHEN 'B1' OR 'B3'.
            CASE wa_hd-bukrs.
              WHEN '8020'.
                IF wa_hd-ekorg = 'TNT'.
                  va_tax = 1.
                ELSE.
                  va_tax = space.
                ENDIF.
              WHEN '8070'.
                IF wa_hd-ekorg = 'TNT'.
                  va_tax = 1.
                ELSE.
                  va_tax = space.
                ENDIF.
              WHEN OTHERS.
                va_tax = space.
            ENDCASE.
          WHEN OTHERS.
            va_tax = space.
        ENDCASE.

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
            va_sign2           = va_sign2
          TABLES
            i_dt               = i_dt.

      WHEN OTHERS.
        va_tax = 1.
        va_kschl = nast-kschl.

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
            va_sign2           = va_sign2
          TABLES
            i_dt               = i_dt.
    ENDCASE.

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
  DATA: l_sign      TYPE i,
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
  DATA: l_sign      TYPE i,
        l_tdline(2).

  DATA: d_value LIKE zgdmmct0002-value,
        d_werks LIKE zgdmmct0002-werks,
        d_bukrs TYPE zgdmmct0002-bukrs,
        d_bsart TYPE zgdmmct0002-bsart,
        d_matkl TYPE zgdmmct0002-matkl.

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
  DATA: lt_eket   TYPE TABLE OF eket,
        lv_lines1 TYPE p DECIMALS 0,
        lv_lines2 TYPE p DECIMALS 0.

*  IF l_doc-xeket[] IS INITIAL.
  IF l_doc-xekpo[] IS NOT INITIAL.
*{   REPLACE        P01K910208                                        1
*\    SELECT *
*\      FROM eket
*\      INTO CORRESPONDING FIELDS OF TABLE lt_eket  "l_doc-xeket
*\      WHERE ebeln = l_doc-xekko-ebeln.
    "Start SOH: Shell SCI Adjustment 20240221 KRS
    SELECT *
      FROM eket
      INTO CORRESPONDING FIELDS OF TABLE lt_eket  "l_doc-xeket
      WHERE ebeln = l_doc-xekko-ebeln
      ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
    IF sy-subrc = 0.
      DESCRIBE TABLE l_doc-xeket LINES lv_lines1.
      DESCRIBE TABLE lt_eket LINES lv_lines2.
      IF lv_lines1 LT lv_lines2.
        l_doc-xeket[] = lt_eket[].
      ENDIF.
    ENDIF.
  ENDIF.
*  ENDIF.
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
    IF nast-kschl = 'ZM04' AND
      wa_hd-bukrs = '8330'.
      wa_hd-signature  = ls_0002-user_name1.
      wa_hd-signature1 = ls_0002-user_name.
    ELSE.
      wa_hd-signature  = ls_0002-user_name.
      wa_hd-signature1 = ls_0002-user_name1.
    ENDIF.
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
      d_werks = s_mmct0002-werks.
      d_bukrs = s_mmct0002-bukrs.
      d_value = s_mmct0002-value.
      d_bsart  = s_mmct0002-bsart.
      d_matkl  = s_mmct0002-matkl.
      wa_hd-signature  = s_mmct0002-user_name.
      wa_hd-signature1 = s_mmct0002-user_name1.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " F_OLD_SIGNATURE_MATRIX

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT_VALUE
*&---------------------------------------------------------------------*
FORM f_get_text_value  CHANGING fc_text fc_kbetr fc_cost.
  DATA : i_date      LIKE mcekko-bedat,
         l_tcurf_new TYPE tcurf,
         lt_tcurf    TYPE STANDARD TABLE OF tcurf,
         d_currdec   TYPE tcurx-currdec.

  IF t_konv-waers <> 'IDR' AND wa_dt-waers = 'IDR'.
    i_date = l_doc-xekko-bedat.
    CONVERT DATE i_date INTO INVERTED-DATE i_date.
    l_tcurf_new-tfact = '1'.
    SELECT *
      FROM tcurf
      INTO TABLE lt_tcurf
      WHERE kurst = 'M'
        AND fcurr = t_konv-waers
        AND tcurr = 'IDR'
        AND gdatu >= i_date.

    IF sy-subrc = 0.
      SORT lt_tcurf BY gdatu.
      READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
      l_tcurf_new-tfact = l_tcurf_new-tfact.
    ENDIF.

    IF t_konv-kpein NE 0.
      IF wa_hd-ld EQ space.
        fc_kbetr = t_konv-kbetr * t_konv-kkurs *
                   l_tcurf_new-tfact / t_konv-kpein.
      ELSE.
        fc_kbetr = t_konv-kbetr * t_konv-kkurs *
                   l_tcurf_new-tfact.
      ENDIF.
    ENDIF.
  ELSE.
    IF t_konv-kpein NE 0.
      IF wa_hd-ld EQ space.
        fc_kbetr = t_konv-kbetr / t_konv-kpein.
      ELSE.
        fc_kbetr = t_konv-kbetr.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE currdec
    FROM tcurx
    INTO d_currdec
    WHERE currkey = t_konv-waers.
  IF sy-subrc = 4.
    d_currdec = 2.
  ENDIF.

  fc_kbetr = fc_kbetr / ( 10 ** d_currdec ).

  ADD t_konv-kwert TO fc_cost.

  SELECT SINGLE vtext
    FROM t685t
    INTO fc_text
    WHERE spras = sy-langu
      AND kappl = 'M'
      AND kschl = t_konv-kschl.
ENDFORM.                    " F_GET_TEXT_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_ESIGN
*&---------------------------------------------------------------------*
FORM f_esign  TABLES   ft_graph   STRUCTURE stxbitmaps
              USING    fu_sign
              CHANGING fc_sign.
  DATA : ls_graph    LIKE LINE OF ft_graph,
         lv_sign(70).

  lv_sign  = fu_sign.
  TRANSLATE lv_sign TO UPPER CASE.
  CLEAR ls_graph.
  READ TABLE ft_graph INTO ls_graph
                      WITH KEY tdname = lv_sign
                      TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    fc_sign = lv_sign.
  ELSE.
    CLEAR fc_sign.
  ENDIF.
ENDFORM.                    " F_ESIGN

*&---------------------------------------------------------------------*
*&      Form  F_OLD_KWI
*&---------------------------------------------------------------------*
FORM f_old_kwi USING   adr_val  TYPE addr1_val.
  IF va_kunnr NE space AND
  ( adr_val-name2(2) CP 'JL' OR adr_val-name2(2) CP 'Jl' ).
    wa_hd-name1_kwi = adr_val-name1.
    wa_hd-stras_kwi = adr_val-name2.
    wa_hd-ort01_kwi = adr_val-name3.
  ELSE.
    IF adr_val-name2 NE space.
      wa_hd-name1_kwi = adr_val-name2.
    ELSE.
      wa_hd-name1_kwi = adr_val-name1.
    ENDIF.

    CONCATENATE adr_val-street adr_val-house_num1
    INTO wa_hd-stras_kwi
    SEPARATED BY space.

    wa_hd-ort01_kwi = adr_val-city1.
    IF adr_val-post_code1 <> '00000'.
      CONCATENATE wa_hd-ort01_kwi adr_val-post_code1
      INTO wa_hd-ort01_kwi
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_OLD_KWI

*&---------------------------------------------------------------------*
*&      Form  F_NEW_KWI
*&---------------------------------------------------------------------*
FORM f_new_kwi  USING    adr_val  TYPE addr1_val.
  IF va_kunnr NE space.
    IF  ( adr_val-name2(2) CP 'JL' OR adr_val-name2(2) CP 'Jl' ).
      wa_hd-name1_kwi = adr_val-name1.
      wa_hd-stras_kwi = adr_val-name2.
      wa_hd-ort01_kwi = adr_val-name3.
    ELSEIF ( adr_val-name2(2) CP 'PT' OR adr_val-name2(2) CP 'pt' ).
      wa_hd-name1_kwi = adr_val-name2.
      wa_hd-stras_kwi = adr_val-name3.
      wa_hd-ort01_kwi = adr_val-name4.
    ELSE.
      wa_hd-name1_kwi = adr_val-name1.
      wa_hd-stras_kwi = adr_val-name2.
      wa_hd-ort01_kwi = adr_val-name3.
    ENDIF.
  ELSE.
    wa_hd-name1_kwi = adr_val-name1.
    CONCATENATE adr_val-street adr_val-house_num1
    INTO wa_hd-stras_kwi
    SEPARATED BY space.
    wa_hd-ort01_kwi = adr_val-city1.
    IF adr_val-post_code1 <> '00000'.
      CONCATENATE wa_hd-ort01_kwi adr_val-post_code1
      INTO wa_hd-ort01_kwi
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEW_KWI

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_payment_detail .
  DATA: BEGIN OF lt_lfbk OCCURS 0.
          INCLUDE STRUCTURE lfbk.
          DATA:   bankn2 TYPE tiban-bankn,
          tabkey TYPE tiban-tabkey,
        END OF lt_lfbk.

  DATA: ld_cnt   TYPE numc1,
        ld_field TYPE char20,
        lt_bnka  TYPE TABLE OF bnka  WITH HEADER LINE,
        lt_tiban TYPE TABLE OF tiban WITH HEADER LINE.

  DATA: lv_name      LIKE thead-tdname,
        lv_bankl     LIKE lfbk-bankl,
        lv_lineslfbk TYPE i,
        lt_lines     TYPE TABLE OF tline WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_field> TYPE any.

  READ TABLE l_doc-xekpo INTO wa_ekpo INDEX 1.
  CONCATENATE wa_ekpo-ebeln wa_ekpo-ebelp INTO lv_name.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'F01'
      language = sy-langu
      name     = lv_name
      object   = 'EKPO'
    TABLES
      lines    = lt_lines
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc = 0.
    READ TABLE lt_lines INDEX 1.
    lv_bankl = lt_lines-tdline.
  ENDIF.

  SELECT lifnr banks bankl bankn bkref koinh bkont bvtyp
    INTO CORRESPONDING FIELDS OF TABLE lt_lfbk
    FROM lfbk WHERE lifnr = wa_hd-lifnr.

  IF lt_lfbk[] IS NOT INITIAL.
    DESCRIBE TABLE lt_lfbk LINES lv_lineslfbk.
    IF lv_lineslfbk GT 1 AND lv_bankl IS NOT INITIAL.
      DELETE lt_lfbk WHERE bankl NE lv_bankl.
    ENDIF.

    LOOP AT lt_lfbk.
      lt_lfbk-bankn2  = lt_lfbk-bankn.
      lt_lfbk-tabkey  = lt_lfbk-lifnr.
      MODIFY lt_lfbk TRANSPORTING bankn2 tabkey.
    ENDLOOP.

    SELECT banks bankl banka stras swift adrnr
      INTO CORRESPONDING FIELDS OF TABLE lt_bnka
      FROM bnka FOR ALL ENTRIES IN lt_lfbk
      WHERE banks = lt_lfbk-banks
        AND bankl = lt_lfbk-bankl.

    SELECT * INTO TABLE lt_tiban
      FROM tiban FOR ALL ENTRIES IN lt_lfbk
      WHERE banks = lt_lfbk-banks
        AND bankl = lt_lfbk-bankl
        AND bankn = lt_lfbk-bankn2
        AND tabkey = lt_lfbk-tabkey.
  ENDIF.

  CLEAR: lt_lfbk,lt_bnka.
  READ TABLE lt_lfbk INDEX 1.
  READ TABLE lt_bnka WITH KEY banks = lt_lfbk-banks
                              bankl = lt_lfbk-bankl.
  wa_hd-koinh = lt_lfbk-koinh.
  wa_hd-swift = lt_bnka-swift.
  CONCATENATE lt_bnka-banka lt_bnka-stras INTO wa_hd-banka
    SEPARATED BY ', '.

  READ TABLE lt_tiban WITH KEY banks = lt_lfbk-banks
                               bankl = lt_lfbk-bankl
                               bankn = lt_lfbk-bankn2
                               tabkey = lt_lfbk-tabkey
                               TRANSPORTING NO FIELDS.

  LOOP AT lt_lfbk.
    ADD 1 TO ld_cnt.
    CONCATENATE 'WA_HD-BKREF' ld_cnt INTO ld_field.
    ASSIGN (ld_field) TO <fs_field>.

    CLEAR: lt_tiban.
    READ TABLE lt_tiban WITH KEY banks = lt_lfbk-banks
                                 bankl = lt_lfbk-bankl
                                 bankn = lt_lfbk-bankn2
                                 tabkey = lt_lfbk-tabkey.
    IF sy-subrc = 0.
      CONCATENATE lt_lfbk-bvtyp lt_tiban-iban INTO <fs_field>
        SEPARATED BY ' : '.
**      CONCATENATE lt_lfbk-bkref lt_tiban-iban INTO <fs_field>
**        SEPARATED BY ' : '.
    ELSE.
      IF lt_lfbk-bankn IS INITIAL.
        CONCATENATE lt_lfbk-bkref lt_lfbk-bkont lt_lfbk-bvtyp
          INTO <fs_field>
          SEPARATED BY space.
      ELSE.
*        CONCATENATE lt_lfbk-bankn lt_lfbk-bkref lt_lfbk-bkont lt_lfbk-bvtyp
*          INTO <fs_field>
*          SEPARATED BY space.
        CONCATENATE lt_lfbk-bankn lt_lfbk-bkref INTO <fs_field>.
        CONCATENATE <fs_field> lt_lfbk-bkont lt_lfbk-bvtyp
          INTO <fs_field>
          SEPARATED BY space.
      ENDIF.
    ENDIF.

    CLEAR ld_field.
    UNASSIGN <fs_field>.
  ENDLOOP.
ENDFORM.                    " F_GET_PAYMENT_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUE
*&---------------------------------------------------------------------*
FORM f_get_value  USING    fu_kschl fu_kwert fu_waers
                  CHANGING fc_vtext fc_kwert fc_kbetr.
  fc_kwert = abs( fu_kwert ).
  WRITE fc_kwert TO fc_kbetr CURRENCY fu_waers.
  SELECT SINGLE vtext
    FROM t685t
    INTO fc_vtext
    WHERE spras = sy-langu
      AND kappl = 'M'
      AND kschl = fu_kschl.
ENDFORM.
