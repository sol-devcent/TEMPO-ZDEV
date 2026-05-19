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
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  IF d_frm_subrc EQ 0.
    PERFORM f_print_form.
  ELSE.
    MESSAGE  e000(zm) WITH 'No data'.
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
  IF nast-vstat NE 0.
    MOVE 'Reprint' TO va_reprint.
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
  DATA: l_adrnr    LIKE kna1-adrnr,
        l_kunnr    LIKE kna1-kunnr,
        l_name(70).

  DATA l_zterm LIKE vbkd-zterm.

  DATA: BEGIN OF it_prive OCCURS 0,
          vbeln LIKE vbfa-vbeln, "Nomor DN
          posnv LIKE vbfa-posnv, "Item DN
          vbelv LIKE vbfa-vbelv, "Nomor SO
          posnn LIKE vbfa-posnn, "Item SO
          kunnr LIKE vbak-kunnr, "Sold-to
        END OF it_prive.

  SELECT matnr INTO TABLE i_zdgsddt012
    FROM zdgsddt012.

  SELECT vbeln lgnum tanum
    INTO CORRESPONDING FIELDS OF TABLE gt_ltak
    FROM ltak
    WHERE vbeln EQ p_vbeln
      AND lgnum IN ('025', '050', '053').

  CLEAR: wa_hd.
*  SELECT SINGLE vbeln lfdat wadat wadat_ist kunnr kunag kunag lifnr lfart inco1
*                vkorg vstel kodat lddat btgew gewei volum vbtyp
*                voleh lprio
*    FROM likp
*    INTO CORRESPONDING FIELDS OF wa_hd
*    WHERE vbeln EQ p_vbeln.
  "Change based on David's Email 19/08/2015
  SELECT SINGLE vbeln lfdat wadat wadat_ist kunnr kunag kunag lifnr lfart inco1
                vkorg vstel kodat lddat btgew gewei volum vbtyp
                voleh erdat
    FROM likp
    INTO CORRESPONDING FIELDS OF wa_hd
    WHERE vbeln EQ p_vbeln.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF jwa_likp
    FROM likp
    WHERE vbeln EQ p_vbeln.

  d_frm_subrc = sy-subrc.
  IF sy-subrc EQ 0.
    IF wa_hd-vstel IS NOT INITIAL.
      SELECT SINGLE vtext
        FROM tvstt
        INTO wa_hd-vtext
        WHERE vstel = wa_hd-vstel
          AND spras = sy-langu.
    ENDIF.

    IF nast-parnr IS NOT INITIAL.
      wa_hd-ship_kunnr = nast-parnr. "wa_hd-kunnr.
    ELSE.
      wa_hd-ship_kunnr = wa_hd-kunnr.
    ENDIF.
    IF wa_hd-lfart IS NOT INITIAL.
      SELECT SINGLE kunnr adrnr
        FROM vbpa
        INTO (l_kunnr, l_adrnr)
        WHERE vbeln EQ wa_hd-vbeln AND
              parvw EQ 'WE'.
      IF sy-subrc EQ 0.
        SELECT SINGLE ktokd
          FROM kna1
          INTO wa_hd-ktokd
          WHERE kunnr EQ l_kunnr.
      ENDIF.
    ELSE.
      SELECT SINGLE adrnr ktokd
        FROM kna1
        INTO (l_adrnr, wa_hd-ktokd)
        WHERE kunnr EQ wa_hd-ship_kunnr.
    ENDIF.
    IF sy-subrc EQ 0.
      SELECT SINGLE name1 name2 name3 street str_suppl1 str_suppl2 str_suppl3
                    post_code1 city1 name_co street country
        FROM adrc
        INTO (wa_hd-ship_name1, wa_hd-ship_name2, wa_hd-ship_name3, wa_hd-ship_street,
              wa_hd-ship_street2, wa_hd-ship_street3, wa_hd-ship_street4,
              wa_hd-ship_post_code1, wa_hd-ship_city1, wa_hd-ship_name_co, wa_hd-ship_street, wa_hd-ship_country)
        WHERE addrnumber EQ l_adrnr.
      wa_hd-reprint = va_reprint.
    ENDIF.
    SELECT SINGLE kunnr
      FROM vbpa
      INTO wa_hd-kunag
      WHERE vbeln   EQ wa_hd-vbeln AND
            parvw EQ 'AG'.
    IF sy-subrc NE 0.
      SELECT SINGLE kunnr
        FROM vbpa
        INTO wa_hd-kunag
        WHERE vbeln   EQ wa_hd-vbeln AND
              parvw EQ 'SP'.
      IF sy-subrc NE 0.
        CLEAR: wa_hd-kunag.
      ENDIF.
    ENDIF.

    IF wa_hd-ship_kunnr = wa_hd-kunag.
      wa_hd-bill_name1 = wa_hd-ship_name1.
      wa_hd-bill_name2 = wa_hd-ship_name2.
      wa_hd-bill_name3 = wa_hd-ship_name3.
      wa_hd-bill_street  = wa_hd-ship_street.
      wa_hd-bill_street2 = wa_hd-ship_street2.
      wa_hd-bill_street3 = wa_hd-ship_street3.
      wa_hd-bill_street4 = wa_hd-ship_street4.
      wa_hd-bill_post_code1 = wa_hd-ship_post_code1.
      wa_hd-bill_city1 = wa_hd-ship_city1.
      wa_hd-bill_country = wa_hd-ship_country.
    ELSE.
      SELECT SINGLE adrnr
        FROM kna1
        INTO l_adrnr
        WHERE kunnr EQ wa_hd-kunag.
      IF sy-subrc EQ 0.
        SELECT SINGLE name1 name2 name3 street str_suppl1 str_suppl2 str_suppl3 post_code1 city1 country
          FROM adrc
          INTO (wa_hd-bill_name1, wa_hd-bill_name2, wa_hd-bill_name3, wa_hd-bill_street,
                wa_hd-bill_street2, wa_hd-bill_street3, wa_hd-bill_street4,
                wa_hd-bill_post_code1, wa_hd-bill_city1, wa_hd-bill_country)
          WHERE addrnumber EQ l_adrnr.
      ENDIF.
    ENDIF.

*    break dg2_co01.
    "Add logic check term of payment
    SELECT SINGLE zterm
        FROM vbfa AS a
        INNER JOIN vbkd AS b
        ON b~vbeln EQ a~vbelv
        INTO l_zterm
        WHERE a~vbeln EQ p_vbeln.

    wa_hd-zterm = l_zterm.

    IF nast-kschl = 'ZDB1' OR
      nast-kschl = 'ZDER'.
      va_command = 'X'.
      SELECT SINGLE vtext INTO wa_hd-name1
           FROM tvkot
           WHERE vkorg = wa_hd-vkorg.
      SELECT SINGLE adrnr INTO l_adrnr
           FROM tvko
           WHERE vkorg = wa_hd-vkorg.
      IF sy-subrc EQ 0.
        SELECT SINGLE name1 name2 name3 street str_suppl1  str_suppl2 post_code1 city1 country tel_number fax_number
          FROM adrc
          INTO (wa_hd-name1, wa_hd-name2, wa_hd-name3, wa_hd-street2, wa_hd-street3, wa_hd-street4,
                wa_hd-post_code1, wa_hd-city1, wa_hd-country, wa_hd-tel_number, wa_hd-fax_number)
          WHERE addrnumber EQ l_adrnr.
        wa_hd-reprint = va_reprint.
      ENDIF.
    ELSE.
      CLEAR: va_command.
      SELECT SINGLE kunnr
        FROM vbpa
        INTO wa_hd-kunnr
        WHERE vbeln   EQ wa_hd-vbeln AND
              parvw EQ 'ZT'.
      IF sy-subrc NE 0.
        SELECT SINGLE vtext INTO wa_hd-name1
             FROM tvkot
             WHERE vkorg = wa_hd-vkorg.
        SELECT SINGLE adrnr INTO l_adrnr
             FROM tvko
             WHERE vkorg = wa_hd-vkorg.
        IF sy-subrc EQ 0.
          SELECT SINGLE name1 name2 name3 str_suppl1 str_suppl2 str_suppl3 post_code1 city1 country tel_number fax_number
            FROM adrc
            INTO (wa_hd-name1, wa_hd-name2, wa_hd-name3, wa_hd-street2, wa_hd-street3, wa_hd-street4,
                  wa_hd-post_code1, wa_hd-city1, wa_hd-country, wa_hd-tel_number, wa_hd-fax_number)
            WHERE addrnumber EQ l_adrnr.
          wa_hd-reprint = va_reprint.
        ENDIF.
      ELSE.
        SELECT SINGLE adrnr
          FROM kna1
          INTO l_adrnr
          WHERE kunnr EQ wa_hd-kunnr.
        IF sy-subrc EQ 0.
          SELECT SINGLE name1 name2 name3 str_suppl1 str_suppl2 str_suppl3 post_code1 city1 country tel_number fax_number
            FROM adrc
            INTO (wa_hd-name1, wa_hd-name2, wa_hd-name3, wa_hd-street2, wa_hd-street3, wa_hd-street4,
                  wa_hd-post_code1, wa_hd-city1, wa_hd-country, wa_hd-tel_number, wa_hd-fax_number)
            WHERE addrnumber EQ l_adrnr.
          wa_hd-reprint = va_reprint.
        ELSE.
          SELECT SINGLE vtext INTO wa_hd-name1
               FROM tvkot
               WHERE vkorg = wa_hd-vkorg.
          SELECT SINGLE adrnr INTO l_adrnr
               FROM tvko
               WHERE vkorg = wa_hd-vkorg.
          IF sy-subrc EQ 0.
            SELECT SINGLE name1 name2 name3 str_suppl1 str_suppl2 str_suppl3 post_code1 city1 country tel_number fax_number
              FROM adrc
              INTO (wa_hd-name1, wa_hd-name2, wa_hd-name3, wa_hd-street2, wa_hd-street3, wa_hd-street4,
                    wa_hd-post_code1, wa_hd-city1, wa_hd-country, wa_hd-tel_number, wa_hd-fax_number)
              WHERE addrnumber EQ l_adrnr.
            wa_hd-reprint = va_reprint.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    SELECT vbeln vgpos posnr matnr arktx lfimg vrkme charg vgbel
           werks lgort mtart ntgew volum gewei voleh vgbel brgew
           kcmeng kcbrgew kcvolum kdmat uecha vkbur uepos pstyv
      FROM lips
      INTO CORRESPONDING FIELDS OF TABLE i_dt
      WHERE vbeln EQ wa_hd-vbeln.

*   break dg2_co01.
*   Get Sold-to party SO
    IF i_dt[] IS NOT INITIAL.
      SELECT a~vbeln a~posnn a~vbelv a~posnv b~kunnr
        FROM vbfa AS a
        INNER JOIN vbak AS b
        ON b~vbeln EQ a~vbelv
        INTO TABLE it_prive
        FOR ALL ENTRIES IN i_dt
        WHERE a~vbeln EQ i_dt-vbeln
        AND a~posnn EQ i_dt-posnr.
    ENDIF.

*      DEVK945721
*    d_frm_subrc = sy-subrc.
*      DEVK945721
    READ TABLE i_dt INTO wa_dt INDEX 1.
    DATA: lv_ebelp TYPE ebelp,
          lr_lfart TYPE RANGE OF lfart,
          ls_lfart LIKE LINE OF lr_lfart.

    ls_lfart-low    = 'Z2*'.
    ls_lfart-sign   = 'I'.
    ls_lfart-option = 'CP'.
    APPEND ls_lfart TO lr_lfart.
    ls_lfart-low    = 'ZTU1'.
    ls_lfart-sign   = 'I'.
    ls_lfart-option = 'EQ'.
    APPEND ls_lfart TO lr_lfart.
    ls_lfart-low    = 'ZDB1'.
    ls_lfart-sign   = 'I'.
    ls_lfart-option = 'EQ'.
    APPEND ls_lfart TO lr_lfart.

    "Add condition based on delivery type
    IF wa_hd-lfart IN lr_lfart.  "CP 'Z2*'.
      SELECT SINGLE bstnk audat vdatu
        FROM vbak
        INTO (wa_hd-bstnk, wa_hd-audat, wa_hd-vdatu)
        WHERE vbeln EQ wa_dt-vgbel.

      "Add condition for SO set deal
      SELECT SINGLE bstkd INTO wa_hd-bstnk
        FROM vbkd
        WHERE vbeln EQ wa_dt-vgbel AND
              ( posnr EQ space OR posnr EQ '000000' ).

      DATA: ld_vbeln LIKE thead-tdname.

      IF wa_hd-lfart = 'Z2NL'.
        ld_vbeln = wa_dt-vgbel.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'F06'
            language                = sy-langu
            name                    = ld_vbeln
            object                  = 'EKKO'
          TABLES
            lines                   = t_lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
      ENDIF.
      IF wa_hd-lfart = 'ZTU1'.
         p_tdform = 'ZHGSD_SF004'.
      endif.
      LOOP AT i_dt INTO wa_dt.
        "Get Note
        READ TABLE it_prive WITH KEY vbeln = wa_dt-vbeln.

        ld_vbeln = it_prive-vbelv.

        IF sy-subrc EQ 0.
          CLEAR : t_lines[], t_lines.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id                      = '0012'
              language                = sy-langu
              name                    = ld_vbeln
              object                  = 'VBBK'
            TABLES
              lines                   = t_lines
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc NE 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.

        "Get Reference from PO number split by #
        DATA: lv_bstnk1 TYPE bstnk,
              lv_bstnk2 TYPE bstnk.
        IF sy-subrc EQ 0 AND wa_hd-bstnk CA '#'.
          SPLIT wa_hd-bstnk AT '#' INTO lv_bstnk1 lv_bstnk2.
          wa_hd-bstnk = lv_bstnk2.
        ENDIF.

        "Insert old material number
        SELECT SINGLE bismt ean11
          FROM mara
          INTO (wa_dt-bismt, wa_dt-ean11)
          WHERE matnr EQ wa_dt-matnr.


        "Add logic for Prive insert employee number
        IF wa_hd-lfart EQ 'Z2PV'.
          READ TABLE it_prive WITH KEY vbeln = wa_dt-vbeln
                                       posnv = wa_dt-posnr.
          IF sy-subrc EQ 0.
            wa_dt-kunnr = it_prive-kunnr.
          ENDIF.
        ENDIF.

        MODIFY i_dt FROM wa_dt.

      ENDLOOP.

*     break dg2_co01.
      "Get Notes
      READ TABLE t_lines INDEX 1.
      IF sy-subrc EQ 0.
        CONCATENATE 'NOTE: ' t_lines-tdline INTO wa_hd-remarks.
      ELSE.
        CLEAR wa_hd-remarks.
      ENDIF.

      "Add condition check term of payment
      IF wa_hd-zterm EQ 'ZCOD'.
        SELECT SINGLE bezei
          FROM tvkbt
          INTO wa_hd-bezei
          WHERE vkbur = wa_dt-vkbur.

        wa_hd-bezei = wa_hd-bezei+3(22).
      ENDIF.

    ELSEIF wa_hd-lfart EQ 'ZD03'.
      SELECT SINGLE ebeln ebelp
        FROM ekbe
        INTO (wa_hd-bstnk, lv_ebelp)
        WHERE belnr = wa_hd-vbeln.

      SELECT SINGLE eindt
        FROM eket
        INTO wa_hd-vdatu
        WHERE ebeln EQ wa_hd-bstnk
        AND ebelp EQ lv_ebelp.

      SELECT SINGLE bedat
        FROM ekko
        INTO wa_hd-audat
        WHERE ebeln EQ wa_hd-bstnk.

      LOOP AT i_dt INTO wa_dt.
        "Insert old material number
        SELECT SINGLE bismt
          FROM mara
          INTO wa_dt-bismt
          WHERE matnr EQ wa_dt-matnr.

        MODIFY i_dt FROM wa_dt.
      ENDLOOP.

      ld_vbeln  = wa_hd-bstnk.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'F06'
          language                = sy-langu
          name                    = ld_vbeln
          object                  = 'EKKO'
        TABLES
          lines                   = t_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      READ TABLE t_lines INDEX 1.
      IF sy-subrc EQ 0.
        wa_hd-remarks = t_lines-tdline.
      ELSE.
        CLEAR wa_hd-remarks.
      ENDIF.
    ENDIF.

*    wa_hd-remarks = 'ZSD_8050_DELV_REMARKS'.

*   Additional selection to get Country Name - by Samanta Limbrada on 23.10.2012
    SELECT SINGLE landx
             FROM t005t
             INTO wa_hd-bill_country_name
            WHERE spras = sy-langu
              AND land1 = wa_hd-bill_country.
    SELECT SINGLE landx
             FROM t005t
             INTO wa_hd-ship_country_name
            WHERE spras = sy-langu
              AND land1 = wa_hd-ship_country.
    SELECT SINGLE landx
             FROM t005t
             INTO wa_hd-country_name
            WHERE spras = sy-langu
              AND land1 = wa_hd-country.

* Return Delivery Note

* Get Text
    SELECT SINGLE * INTO wa_zsdn_text
      FROM zsdn_text
      WHERE vkorg = wa_hd-vkorg AND
            vstel = wa_hd-vstel.

* Get No. Quot
    IF wa_hd-kunag EQ 'TSB0200'.
      CLEAR wa_dt.
      READ TABLE i_dt INTO wa_dt INDEX 1.
      SELECT SINGLE unsez INTO wa_hd-unsez
        FROM ekko WHERE ebeln = wa_dt-vgbel.
      IF sy-subrc = 0.
        CONCATENATE 'No Quot:' wa_hd-unsez INTO wa_hd-unsez SEPARATED BY space.
      ENDIF.
    ENDIF.

*    IF sy-subrc = 0.
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
*          id       = 'ST'
*          language = sy-langu
*          name     = wa_zsdn_text-name_txt
*          object   = 'TEXT'
*        TABLES
*          lines    = t_lines.
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*
*    ENDIF.
  ELSE.

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
  DATA: l_unit_out1 LIKE t006-msehi,
        l_unit_out2 LIKE t006-msehi.
  DATA: l_dt   TYPE ta_dt.
  DATA: l_nou   TYPE i,
        l_lines TYPE i.
  DATA: ld_tanum(10).

  LOOP AT gt_ltak.
    WRITE gt_ltak-tanum TO ld_tanum NO-ZERO.
    CONDENSE ld_tanum.
    IF wa_hd-lfart CP 'Z2*' OR wa_hd-lfart EQ 'ZD03'.
      IF wa_hd-tanum IS INITIAL.
        wa_hd-tanum = ld_tanum.
      ELSE.
        CONCATENATE wa_hd-tanum ld_tanum INTO wa_hd-tanum
          SEPARATED BY ', '.
      ENDIF.
    ENDIF.

  ENDLOOP.

  REFRESH: i_dtm, i_dtb.
  CLEAR: l_nou, l_dt, wa_dt.
  l_unit_out1 = 'KG'.
  l_unit_out2 = 'M3'.
  SORT i_dt BY posnr.
  LOOP AT i_dt INTO wa_dt.
    READ TABLE i_zdgsddt012  WITH KEY matnr = wa_dt-matnr.
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.
    ADD 1 TO l_nou.
    wa_dt-nou = l_nou.
    IF wa_dt-posnr(1) = '9'.
      CLEAR: wa_dt-tambah.
      APPEND wa_dt TO i_dtb.
    ELSE.
      wa_dt-uecha = wa_dt-posnr.
      IF wa_dt-charg IS INITIAL.
        CLEAR: wa_dt-tambah.
        APPEND wa_dt TO i_dtm.
        IF wa_dt-kdmat IS NOT INITIAL.
          IF wa_dt-kdmat NE wa_dt-matnr.
            ADD 1 TO l_nou.
            wa_dt-nou = l_nou.
            wa_dt-tambah  = 'X'.
            APPEND wa_dt TO i_dtm.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: wa_dt-tambah.
        APPEND wa_dt TO i_dtm.
        IF wa_dt-kdmat IS NOT INITIAL.
          IF wa_dt-kdmat NE wa_dt-matnr.
            ADD 1 TO l_nou.
            wa_dt-nou = l_nou.
            wa_dt-tambah  = 'X'.
            APPEND wa_dt TO i_dtm.
          ENDIF.
        ENDIF.
        ADD 1 TO l_nou.
        wa_dt-nou = l_nou.
*        wa_dt-uecha = wa_dt-posnr.
        wa_dt-posnr = '900001'.
        CLEAR: wa_dt-tambah.
        APPEND wa_dt TO i_dtb.
      ENDIF.
    ENDIF.
  ENDLOOP.

  l_unit_out1 = 'KG'.
  l_unit_out2 = 'M3'.
  REFRESH: i_dt.
  CLEAR: wa_dt, wa_hd-btgew, wa_hd-volum.
  SORT i_dtm BY nou. "posnr tambah.
  SORT i_dtb BY uecha posnr matnr.
  l_nou = 0.
  LOOP AT i_dtm INTO wa_dt.
    SORT i_dtb BY uecha matnr.
    ADD 1 TO l_nou.
    wa_dt-nou = l_nou.
    IF wa_dt-tambah IS INITIAL.
      SORT i_dtb BY uecha matnr posnr.
      READ TABLE i_dtb INTO l_dt WITH KEY matnr = wa_dt-matnr
                                          uecha = wa_dt-posnr.
      IF sy-subrc EQ 0.
        CLEAR: wa_dt-kcmeng, wa_dt-kcbrgew, wa_dt-kcvolum.
        LOOP AT i_dtb INTO l_dt WHERE matnr = wa_dt-matnr  AND
                                      uecha = wa_dt-posnr.
          ADD 1 TO l_nou.
          l_dt-nou = l_nou.
          wa_dt-kcmeng = wa_dt-kcmeng + l_dt-lfimg.
          wa_dt-kcbrgew = wa_dt-kcbrgew + l_dt-brgew.
          wa_dt-kcvolum = wa_dt-kcvolum + l_dt-volum.
          wa_dt-uecha    = l_dt-uecha.
          SELECT SINGLE umrez FROM marm INTO
            l_dt-umrez
            WHERE matnr = l_dt-matnr AND
                  meinh = 'KAR'.
          IF sy-subrc EQ 0.
            IF l_dt-umrez > 0.
              IF l_dt-lfimg <> 0.
                l_dt-lfimgb = trunc( l_dt-lfimg / l_dt-umrez ).
                l_dt-lfimg1 = l_dt-lfimg - ( l_dt-lfimgb * l_dt-umrez ).
              ENDIF.
            ENDIF.
          ENDIF.
          l_dt-arktx = space.
          SELECT SINGLE vfdat
             FROM mch1
             INTO l_dt-vfdat
             WHERE matnr EQ l_dt-matnr AND
                   charg EQ l_dt-charg.
          MODIFY i_dtb FROM l_dt.
          APPEND l_dt TO i_dt.
          CLEAR: l_dt.
        ENDLOOP.
        wa_dt-lfimg = wa_dt-kcmeng.
      ELSE.
        wa_dt-kcbrgew = wa_dt-brgew.
        wa_dt-kcvolum = wa_dt-volum.
      ENDIF.
      SELECT SINGLE umrez FROM marm INTO
        wa_dt-umrez
        WHERE matnr = wa_dt-matnr AND
              meinh = 'KAR'.
      IF sy-subrc EQ 0.
        IF wa_dt-umrez > 0.
          IF wa_dt-lfimg <> 0.
            wa_dt-lfimgb = trunc( wa_dt-lfimg / wa_dt-umrez ).
            wa_dt-lfimg1 = wa_dt-lfimg - ( wa_dt-lfimgb * wa_dt-umrez ).
          ENDIF.
        ENDIF.
      ENDIF.
      IF wa_dt-gewei NE l_unit_out1.
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                = wa_dt-kcbrgew
            round_sign           = 'X'
            unit_in              = wa_dt-gewei
            unit_out             = l_unit_out1
          IMPORTING
            output               = wa_dt-kcbrgew
          EXCEPTIONS
            conversion_not_found = 01
            division_by_zero     = 02
            input_invalid        = 03
            overflow             = 04
            output_invalid       = 05
            units_missing        = 06
            unit_in_not_found    = 07
            unit_out_not_found   = 08.
        IF sy-subrc NE 0.
          wa_dt-kcbrgew = wa_dt-kcbrgew / 1000.
        ENDIF.
      ELSE.
        wa_dt-kcbrgew = wa_dt-kcbrgew.
      ENDIF.
      IF wa_dt-voleh NE l_unit_out2.
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                = wa_dt-kcvolum
            round_sign           = 'X'
            unit_in              = wa_dt-voleh
            unit_out             = l_unit_out2
          IMPORTING
            output               = wa_dt-kcvolum
          EXCEPTIONS
            conversion_not_found = 01
            division_by_zero     = 02
            input_invalid        = 03
            overflow             = 04
            output_invalid       = 05
            units_missing        = 06
            unit_in_not_found    = 07
            unit_out_not_found   = 08.
        IF sy-subrc NE 0.
          wa_dt-kcvolum = wa_dt-kcvolum / 1000.
        ENDIF.
      ELSE.
        wa_dt-kcvolum = wa_dt-kcvolum.
      ENDIF.

      "Add condition for set deal quantity
      IF wa_dt-uepos EQ ''.
        ADD wa_dt-kcbrgew TO wa_hd-btgew.
        ADD wa_dt-kcvolum TO wa_hd-volum.
        ADD wa_dt-lfimg TO wa_hd-lfimg.

      ELSEIF wa_dt-uepos NE '' AND wa_dt-pstyv NE 'ZTAE'.
        ADD wa_dt-kcbrgew TO wa_hd-btgew.
        ADD wa_dt-kcvolum TO wa_hd-volum.
        ADD wa_dt-lfimg TO wa_hd-lfimg.
      ENDIF.
    ELSE.
      wa_dt-uecha = wa_dt-posnr.
    ENDIF.
    MODIFY i_dtm FROM wa_dt.
    APPEND wa_dt TO i_dt.
    CLEAR: wa_dt.
  ENDLOOP.
*  sort i_dt by posnr kdmat.
*  DELETE ADJACENT DUPLICATES FROM i_dt COMPARING  posnr kdmat.
  SORT i_dt BY uecha posnr nou.
  DESCRIBE TABLE i_dt LINES l_nou.

  IF wa_zsdn_text-name_txt IS INITIAL.
    l_lines = 25.
  ELSE.
    l_lines = 15.
  ENDIF.
  IF l_nou <= l_lines.
    wa_hd-flag = 'X'.
  ELSE.
    CLEAR: wa_hd-flag.
  ENDIF.
  wa_hd-tdline = 'ZSD_8050_DELV_REMARKS'.
* Get Name Text
  wa_hd-name_txt = wa_zsdn_text-name_txt.
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
  TYPE-POOLS:  truxs, abap.

  DATA: BEGIN OF li_text_er OCCURS 0,
          kunnr        LIKE kna1-kunnr,
          nodn         LIKE vbak-vbeln,
          tgldn        LIKE sy-datum,
          matnr        TYPE matnr,
          arktx        TYPE arktx,
          lfimg(10),
          vrkme        TYPE vrkme,
          kwertc25(15) ,
          noso         LIKE vbak-vbeln,
        END OF li_text_er.
  DATA: gt_download TYPE truxs_t_text_data.
  DATA: p_path TYPE char128  VALUE '/outbound/sfa/dn/'.
  DATA: lv_kunnr LIKE wa_hd-ship_kunnr.
  DATA: lv_path     TYPE p_path,
        lv_filename TYPE zdg2cade0039.
  DATA: gt_table_des  TYPE abap_compdescr_tab,
        gs_table_des  TYPE abap_compdescr,
        ref_table_des TYPE REF TO cl_abap_structdescr.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
**** CEK Apakah cabang sdh go live timwas ?
** Cek ke table  ZSCUST_CONTROL

****  SELECT SINGLE field_value INTO l_fieldvalue FROM zscust_control
****  WHERE vkorg = '8020' AND
****        cek = 'TWS' AND
****        field_name = 'VKBUR' AND
****        field_value = jwa_likp-vstel.
****  IF sy-subrc EQ 0.


    PERFORM f_send_data_timwas.
****  endif.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        wa_hd              = wa_hd
        va_command         = va_command
      TABLES
        i_dt               = i_dt.

    SELECT SINGLE kunnr INTO lv_kunnr FROM zsfasddt008 WHERE kunnr = wa_hd-ship_kunnr.
    IF sy-subrc EQ 0 AND lv_kunnr = wa_hd-ship_kunnr.
      CLEAR: li_text_er.
      LOOP AT i_dt INTO wa_dt.
        IF wa_dt-posnr(1) = '0'.
          li_text_er-kunnr  = wa_hd-ship_kunnr.
          li_text_er-nodn   = wa_hd-vbeln.
          li_text_er-tgldn  = wa_hd-lfdat.
          li_text_er-matnr  = wa_dt-matnr.
          li_text_er-arktx  = wa_dt-arktx.
          WRITE wa_dt-lfimg TO li_text_er-lfimg NO-GAP NO-GROUPING DECIMALS 0.
          li_text_er-vrkme  = wa_dt-vrkme.
          "           li_text_er-kwertc25
          li_text_er-noso = wa_dt-vgbel.
          APPEND li_text_er. CLEAR: li_text_er.
        ENDIF.
      ENDLOOP.
      ref_table_des ?= cl_abap_typedescr=>describe_by_data( li_text_er ).
      gt_table_des[] = ref_table_des->components[].

      IF li_text_er[] IS NOT INITIAL.
        REFRESH: gt_download.
        lv_filename = wa_hd-vbeln.
        CONCATENATE p_path lv_filename '.txt' INTO lv_path.
        CALL METHOD zcl_util=>m_concate_text_separator2
          EXPORTING
            pti_data      = li_text_er[]
            pti_structure = gt_table_des[]
            pvi_separator = '|'
          IMPORTING
            pto_data      = gt_download.

        CALL METHOD zcl_util=>m_download_dataset_linefeed
          EXPORTING
            param_name = lv_path
            pti_data   = gt_download[].

        REFRESH: gt_download, li_text_er.

      ENDIF.
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

ENDFORM.                    " f_free_memory
*&---------------------------------------------------------------------*
*&      Form  F_SEND_DATA_TIMWAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_data_timwas .
  TYPES: BEGIN OF t_lips,
           posnr     LIKE lips-posnr, ": "10",
           pstyv     LIKE lips-pstyv,
           matnr     LIKE lips-matnr,
           werks     LIKE lips-werks,
           lgort     LIKE lips-lgort,
           charg     LIKE lips-charg,
           lfimg(15), " LIKE lips-lfimg,
           meins     LIKE lips-meins,
           ntgew(15), " LIKE lips-ntgew,
           brgew(15), " LIKE lips-brgew,
           gewei     LIKE lips-gewei,
           volum(15), " LIKE likp-volum, ": null,
           voleh     LIKE lips-voleh, ": null,
           gsber     LIKE lips-gsber,
         END OF t_lips.

  TYPES: BEGIN OF t_likp,
           vbeln     LIKE likp-vbeln,
           wadat_ist LIKE likp-wadat_ist,
           erdat     LIKE likp-erdat,
           vstel     LIKE likp-vstel,                       ": "0210",
           vkorg     LIKE likp-vkorg,                       ": "8020",
           lfart     LIKE likp-lfart, ": null,
           kunnr     LIKE likp-kunnr, ": null,
           kunag     LIKE likp-kunag, ": null,
           route     LIKE likp-route,
           btgew(15), " LIKE likp-btgew, ": null,
           ntgew(15), " LIKE likp-ntgew, ": null,
           gewei     LIKE likp-gewei, ": null,
           volum(15), " LIKE likp-volum, ": null,
           voleh     LIKE likp-voleh, ": null,
           anzpk     LIKE likp-anzpk, ": null,
           lips      TYPE  STANDARD TABLE OF t_lips WITH NON-UNIQUE DEFAULT KEY,
         END OF t_likp.

  DATA: wa_likp TYPE t_likp.
  DATA: wa_lips TYPE t_lips.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json      TYPE string.

  DATA: i_likp TYPE t_likp OCCURS 0 WITH HEADER LINE.
  DATA: p_str TYPE string..


***    SELECT vbeln vgpos posnr matnr arktx lfimg vrkme charg vgbel
***           werks lgort mtart ntgew volum gewei voleh vgbel brgew
***           kcmeng kcbrgew kcvolum kdmat uecha vkbur uepos pstyv
***      FROM lips
***      INTO CORRESPONDING FIELDS OF TABLE i_dt
***      WHERE vbeln EQ wa_hd-vbeln.
***  SELECT SINGLE vbeln lfdat wadat wadat_ist kunnr kunag kunag lifnr lfart inco1
***                vkorg vstel kodat lddat btgew gewei volum vbtyp
***                voleh erdat
***    FROM likp
***    INTO CORRESPONDING FIELDS OF wa_hd
***    WHERE vbeln EQ p_vbeln.

  MOVE-CORRESPONDING jwa_likp TO i_likp.
  WRITE jwa_likp-ntgew TO i_likp-ntgew NO-GAP NO-GROUPING DECIMALS 0.
  WRITE jwa_likp-btgew TO i_likp-btgew NO-GAP NO-GROUPING DECIMALS 0.
  WRITE jwa_likp-volum TO i_likp-volum NO-GAP NO-GROUPING DECIMALS 0.
  LOOP AT i_dt INTO wa_dt.
    wa_lips-posnr  = wa_dt-posnr. ": "10",
    wa_lips-pstyv  = wa_dt-pstyv.
    wa_lips-matnr  = wa_dt-matnr.
    wa_lips-werks  = wa_dt-werks.
    wa_lips-lgort  = wa_dt-lgort.
    wa_lips-charg  = wa_dt-charg.
    "    wa_lips-lfimg  = wa_dt-lfimg.
    wa_lips-meins  = wa_dt-vrkme.
    "    wa_lips-ntgew  = wa_dt-ntgew.
    "    wa_lips-brgew  = wa_dt-brgew.
    wa_lips-gewei  = wa_dt-gewei.

    WRITE wa_dt-lfimg TO wa_lips-lfimg NO-GAP NO-GROUPING DECIMALS 0.
    WRITE wa_dt-ntgew TO wa_lips-ntgew NO-GAP NO-GROUPING DECIMALS 0.
    "  write wa_dt-btgew to wa_lips-btgew NO-GAP NO-GROUPING DECIMALS 0.
    WRITE wa_dt-brgew TO wa_lips-brgew NO-GAP NO-GROUPING DECIMALS 0.
    WRITE wa_dt-volum TO wa_lips-volum NO-GAP NO-GROUPING DECIMALS 0.

    APPEND wa_lips TO i_likp-lips.
  ENDLOOP.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = i_likp.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'TWS_PICKLISTDN' sy-subrc p_str. "ztiam_i0001



  DATA: l_len TYPE i.
  DATA: json1             TYPE string.
  DATA:  gv_str TYPE string.
  DATA:        l_ctr TYPE i.
  DATA: BEGIN OF lt_request_body OCCURS 0,
          line(3000), " TYPE string,
        END OF  lt_request_body.



  json1 = gv_json.
  l_len = strlen( json1 ).
  DO 50000 TIMES.
    FIND '",' IN json1 MATCH OFFSET l_ctr.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 2 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      lt_request_body-line = json1(l_ctr). "(500).
      CONDENSE: lt_request_body-line.
      APPEND lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      json1 = json1+l_ctr(l_len).
    ELSE.
      IF json1 IS INITIAL.
      ELSE.
        lt_request_body-line = json1(l_len). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.
  DATA:    gv_fullfile  LIKE edi_path-pthnam.

  gv_fullfile = '/outbound/tws/'. "   outbound\tws
  CONCATENATE gv_fullfile jwa_likp-vbeln '.json' INTO gv_fullfile.
  OPEN DATASET gv_fullfile FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
  IF sy-subrc EQ 0.
    LOOP AT lt_request_body.
      gv_str = lt_request_body-line.
      TRANSFER  gv_str TO gv_fullfile.
    ENDLOOP.
    CLOSE DATASET gv_fullfile.

  ENDIF.



ENDFORM.                    " F_SEND_DATA_TIMWAS
