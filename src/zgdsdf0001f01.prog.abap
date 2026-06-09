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
  IF nast-vstat NE 0.
    MOVE '(R)' TO va_reprint.
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
        l_name(70).

  DATA: lines   LIKE tline OCCURS 0 WITH HEADER LINE,
        lv_name TYPE tdobname.

  DATA: lv_bukrs    LIKE zplbc-bukrs,
        lv_werks    LIKE zplbc-werks,
        lv_werkskey LIKE zplbc-werks,
        lv_reswk    LIKE zplbc-reswk,
        lv_reswkkey LIKE zplbc-reswk,
        lv_kunnr    LIKE likp-kunnr,
        lv_utd(1),
        l_kunnr     LIKE vbpa-kunnr.

  DATA : lv_str_suppl1 TYPE adrc-str_suppl1,
         lv_str_suppl2 TYPE adrc-str_suppl2,
         lv_str_suppl3 TYPE adrc-str_suppl3,
         lv_location   TYPE adrc-location,
         lv_name_co    TYPE adrc-name_co,
         lv_street     TYPE adrc-street.

* Select header
  SELECT SINGLE vbeln lfdat wadat wadat_ist kunnr lifnr lfart inco1
                vkorg vstel kodat lddat btgew gewei volum
                voleh werks
    FROM likp
    INTO CORRESPONDING FIELDS OF wa_hd
    WHERE vbeln EQ p_vbeln.

  IF sy-subrc EQ 0.
    SELECT SINGLE reswk
      FROM zplbc
      INTO wa_hd-reswk
      WHERE reswk = wa_hd-vstel.

* United condition, change on 08.12.2015
* Jika United ubah isi wa_hd-vkorg, wa_hd-vstel, wa_hd-kunnr
* dari table ZPLBC
    CLEAR: lv_bukrs,lv_werks,lv_werkskey,lv_reswk,lv_reswkkey,lv_kunnr,lv_utd.
    lv_werkskey = wa_hd-kunnr+3(4).
    IF lv_werkskey(2) = '07'.
      lv_reswkkey = wa_hd-vstel.
      SELECT SINGLE bukrs werks reswk
        INTO (lv_bukrs,lv_werks,lv_reswk)
        FROM zplbc WHERE werks = lv_werkskey
                     AND reswk = lv_reswkkey.
      IF sy-subrc = 0.
        wa_hd-vkorg = lv_bukrs.
        wa_hd-vstel = lv_werks.
        CONCATENATE 'TBA' lv_reswk INTO lv_kunnr.
        lv_utd = 'X'.
      ELSE.
        lv_kunnr = wa_hd-kunnr.
      ENDIF.
    ELSE.
      lv_kunnr = wa_hd-kunnr.
    ENDIF.
    IF wa_hd-vkorg = '8360'.
      SELECT SINGLE adrnr
        FROM vbpa
        INTO l_adrnr
        WHERE vbeln = p_vbeln
          AND parvw = 'WE'.
    ELSE.
      SELECT SINGLE adrnr
        FROM kna1
        INTO l_adrnr
*      WHERE kunnr EQ wa_hd-kunnr.
        WHERE kunnr EQ lv_kunnr.
    ENDIF.

    CASE wa_hd-vkorg.
      WHEN '8180'. " or '8010'.
        IF wa_hd-lfart = 'ZTO1'.
          SELECT SINGLE kunnr adrnr
            FROM vbpa
            INTO ( l_kunnr, l_adrnr )
            WHERE vbeln = p_vbeln
              AND parvw = 'WE'.
        ENDIF.
      WHEN '8010'.
        IF wa_hd-werks = '3800'.
          SELECT SINGLE kunnr adrnr
            FROM vbpa
            INTO ( l_kunnr, l_adrnr )
            WHERE vbeln = p_vbeln
              AND parvw = 'WE'.
        ELSE.
          IF wa_hd-lfart = 'ZTO1'.
            SELECT SINGLE kunnr adrnr
              FROM vbpa
              INTO ( l_kunnr, l_adrnr )
              WHERE vbeln = p_vbeln
                AND parvw = 'WE'.
          ENDIF.
        ENDIF.
    ENDCASE.

    IF sy-subrc EQ 0.
      SELECT SINGLE name1 name2 name3 name4 post_code1 city1
        name_co street str_suppl1 str_suppl2 str_suppl3 location
        FROM adrc
        INTO (wa_hd-name1, wa_hd-name2, wa_hd-name3,
              wa_hd-name4, wa_hd-post_code1,
              wa_hd-city1, lv_name_co, lv_street, lv_str_suppl1,
              lv_str_suppl2, lv_str_suppl3, lv_location)
        WHERE addrnumber EQ l_adrnr.

      IF wa_hd-vkorg = '8010'.
        IF wa_hd-werks = '3800'.
          wa_hd-name2 = lv_street.
          CONCATENATE wa_hd-city1 ','
          INTO wa_hd-name3.
          CONCATENATE wa_hd-name3 wa_hd-post_code1
          INTO wa_hd-name3
          SEPARATED BY space.
        ELSE.
          IF l_kunnr(3) = 'TBA'.
            wa_hd-name1 = lv_name_co.      " lv_str_suppl1.
          ENDIF.
          wa_hd-name2 = lv_street.       " lv_str_suppl2.
          wa_hd-name3 = lv_str_suppl1.   " lv_str_suppl3.
"          wa_hd-name4 = lv_str_suppl2.   " lv_location.
          CONCATENATE wa_hd-city1 ','
          INTO wa_hd-name4.
          CONCATENATE wa_hd-name4 wa_hd-post_code1
          INTO wa_hd-name4
          SEPARATED BY space.
        ENDIF.
      ENDIF.

* United condition, change on 08.12.2015
* Alamat hanya ambil NAME1 dan NAME4
      IF lv_utd = 'X'.
        wa_hd-name2 = wa_hd-name3.
        wa_hd-name3 = wa_hd-name4.
        CLEAR wa_hd-name4.
      ENDIF.

      IF wa_hd-lfart = 'ZTO1' AND wa_hd-vkorg = '8180'.
        IF l_kunnr(3) = 'TBA'.
          wa_hd-name1 = lv_name_co.      " lv_str_suppl1.
        ENDIF.
        wa_hd-name2 = lv_street.       " lv_str_suppl2.
        wa_hd-name3 = lv_str_suppl1.   " lv_str_suppl3.
        wa_hd-name4 = lv_str_suppl2.   " lv_location.
      ENDIF.
      wa_hd-reprint = va_reprint.
    ENDIF.

* Select detail
    SELECT vbeln vgpos posnr matnr arktx lfimg vrkme charg vgbel
           werks lgort mtart hsdat uecha
      FROM lips
      INTO CORRESPONDING FIELDS OF TABLE i_dt
      WHERE vbeln EQ wa_hd-vbeln.
    READ TABLE i_dt INTO wa_dt INDEX 1.

    IF wa_hd-lfart EQ 'ZD01'.
      wa_hd-sono1 = wa_dt-vgbel.
    ELSE.
      wa_hd-pono1 = wa_dt-vgbel.
    ENDIF.

    SELECT * FROM mch1 INTO TABLE t_mch1
    FOR ALL ENTRIES IN i_dt
    WHERE matnr = i_dt-matnr AND
          charg = i_dt-charg.

    SELECT * FROM t005t INTO TABLE t_t005t
    FOR ALL ENTRIES IN t_mch1
    WHERE  spras = sy-langu AND
           land1 = t_mch1-herkl.

    l_name = wa_hd-vbeln.
    LOOP AT i_dt INTO wa_dt.
      READ TABLE t_mch1 WITH KEY
           matnr = wa_dt-matnr
           charg = wa_dt-charg.
      IF sy-subrc EQ 0.
        READ TABLE t_t005t WITH KEY
          land1 = t_mch1-herkl.
        IF sy-subrc EQ 0.
          wa_dt-landx = t_t005t-landx.
          MODIFY i_dt FROM wa_dt.
        ENDIF.
      ENDIF.
      SELECT SINGLE umrez FROM marm INTO
        wa_dt-umrez
        WHERE matnr = wa_dt-matnr AND
              meinh = 'KAR'.
      IF sy-subrc EQ 0.
        IF wa_dt-umrez > 0.
          wa_dt-lfimgb = wa_dt-lfimg / wa_dt-umrez.
        ELSE.
          wa_dt-lfimgb = 0.
        ENDIF.
        MODIFY i_dt FROM wa_dt.
      ENDIF.
    ENDLOOP.

    CASE nast-kschl.
* Delivery Note
      WHEN 'ZD01' OR 'ZRX1'.
        IF wa_hd-lfart EQ 'ZD01'.
          SELECT SINGLE bstkd
            FROM vbkd
            INTO wa_hd-pono1
            WHERE vbeln EQ wa_dt-vgbel.
        ELSE.
          lv_name = wa_hd-vbeln.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id                      = 'ZH06'
              language                = sy-langu
              name                    = lv_name
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
            IF sy-subrc EQ 0.
              wa_hd-sono1 = lines-tdline(10).
            ELSE.
              wa_hd-sono1 = space.
            ENDIF.
          ELSE.
            wa_hd-sono1 = space.
          ENDIF.
        ENDIF.

* 12/05/2005
*        SELECT SINGLE vbeln
*          FROM vbfa
*          INTO wa_hd-gino1
*          WHERE vbelv   EQ wa_dt-vbeln AND
*                vbtyp_n EQ 'R'         AND
*                bwart   NE space.

        SELECT vbeln erdat erzet
          FROM vbfa
          INTO CORRESPONDING FIELDS OF TABLE i_vbfa
          WHERE vbelv   EQ wa_dt-vbeln AND
                vbtyp_n EQ 'R'         AND
                bwart   NE space.

        SORT i_vbfa DESCENDING BY erdat erzet.
        READ TABLE i_vbfa INTO wa_vbfa INDEX 1.
        IF sy-subrc EQ 0.
          wa_hd-gino1 = wa_vbfa-vbeln.
        ENDIF.

* Get delivery note text
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ZH03'
            language                = sy-langu
            name                    = l_name
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
        IF sy-subrc = 0.
          LOOP AT t_lines.
            IF t_lines-tdline NE space.
              wa_hd-tdline = t_lines-tdline.
            ENDIF.
          ENDLOOP.
        ENDIF.

        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ZH08'
            language                = sy-langu
            name                    = l_name
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
        IF sy-subrc = 0.
          LOOP AT t_lines.
            IF t_lines-tdline NE space.
              wa_hd-tdline1 = t_lines-tdline.
            ENDIF.
          ENDLOOP.
        ENDIF.

        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ZH07'
            language                = sy-langu
            name                    = l_name
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
        IF sy-subrc = 0.

          LOOP AT t_lines.
            IF t_lines-tdline NE space.
              wa_hd-tdline2 = t_lines-tdline.
            ENDIF.
          ENDLOOP.
        ENDIF.

* Return Delivery Note
      WHEN 'ZD02' OR 'ZRX2'.
        wa_hd-vgbel = wa_dt-vgbel.
        SELECT SINGLE bstkd
          FROM vbkd
          INTO wa_hd-pono1
          WHERE vbeln EQ wa_dt-vgbel.

* 12/05/2005
*        SELECT SINGLE vbeln
*          FROM vbfa
*          INTO wa_hd-grno1
*          WHERE vbelv   EQ wa_dt-vbeln AND
*                vbtyp_n EQ 'R'         AND
*                bwart   NE space.

        SELECT vbeln erdat erzet
          FROM vbfa
          INTO CORRESPONDING FIELDS OF TABLE i_vbfa
          WHERE vbelv   EQ wa_dt-vbeln AND
                vbtyp_n EQ 'R'         AND
                bwart   NE space.

        SORT i_vbfa DESCENDING BY erdat erzet.
        READ TABLE i_vbfa INTO wa_vbfa INDEX 1.
        IF sy-subrc EQ 0.
          wa_hd-grno1 = wa_vbfa-vbeln.
        ENDIF.

* Get return delivery text
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ZH03'
            language                = sy-langu
            name                    = l_name
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
        IF sy-subrc = 0.
          LOOP AT t_lines.
            IF t_lines-tdline NE space.
              wa_hd-tdline = t_lines-tdline.
            ENDIF.
          ENDLOOP.
        ENDIF.

* Picking Request
      WHEN 'ZP01'.
        IF wa_hd-lfart EQ 'ZD01'.
          SELECT SINGLE bstkd
            FROM vbkd
            INTO wa_hd-pono1
            WHERE vbeln EQ wa_dt-vgbel.
        ELSE.
          wa_hd-pono1 = wa_dt-vgbel.
        ENDIF.

* Get picking request text
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ZH04'
            language                = sy-langu
            name                    = l_name
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
        IF sy-subrc = 0.
          LOOP AT t_lines.
            IF t_lines-tdline NE space.
              wa_hd-tdline = t_lines-tdline.
            ENDIF.
          ENDLOOP.
        ENDIF.
    ENDCASE.
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
  DATA : l_matnr  LIKE lips-matnr,
         l_lfimg  LIKE lips-lfimg,
         l_lfimgb LIKE lips-lfimg,
         l_lgort  LIKE lips-lgort,
         l_werks  LIKE lips-werks,
         l_vrkme  LIKE lips-vrkme.

  CLEAR: wa_dt, l_matnr.

* to omit rturn order no if delivery from PO
  IF wa_hd-vgbel = wa_hd-pono1.
    CLEAR wa_hd-vgbel.
  ENDIF.

  IF nast-kschl =	'ZD01'.
    SELECT SINGLE bsart INTO wa_hd-bsart
      FROM ekko WHERE ebeln = wa_hd-pono1.
  ENDIF.

  SORT i_dt BY vgpos posnr.
  CLEAR: l_vrkme.
  LOOP AT i_dt INTO wa_dt.
    IF wa_dt-lfimg EQ 0.
      l_vrkme = wa_dt-vrkme.
    ENDIF.

*    IF wa_dt-matnr EQ l_matnr.
    IF wa_dt-matnr EQ l_matnr AND NOT wa_dt-charg IS INITIAL.
      wa_dt-arktx = space.
      MODIFY i_dt FROM wa_dt TRANSPORTING arktx.
    ENDIF.

    SELECT SINGLE vfdat
      FROM mch1
      INTO wa_dt-vfdat
      WHERE matnr EQ wa_dt-matnr AND
            charg EQ wa_dt-charg.
    MODIFY i_dt FROM wa_dt TRANSPORTING vfdat.

    IF l_vrkme NE space.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr  = wa_dt-matnr
          i_in_me  = wa_dt-vrkme
          i_out_me = l_vrkme
          i_menge  = wa_dt-lfimg
        IMPORTING
          e_menge  = wa_dt-lfimg.
    ENDIF.

    ADD wa_dt-lfimg TO l_lfimg.
    ADD wa_dt-lfimgb TO l_lfimgb.


    IF wa_dt-lgort NE space.
      l_werks = wa_dt-werks.
      l_lgort = wa_dt-lgort.
    ENDIF.

    AT END OF vgpos.
      wa_dt-lfimg1 = l_lfimg.
      wa_dt-lfimg1b = l_lfimgb.
      MODIFY i_dt FROM wa_dt TRANSPORTING lfimg1 lfimg1b
        WHERE vgpos EQ wa_dt-vgpos.

      wa_dt-lgort = l_lgort.
      MODIFY i_dt FROM wa_dt TRANSPORTING lgort
        WHERE matnr EQ wa_dt-matnr AND
              werks EQ l_werks AND
              lgort EQ space.
      CLEAR: l_lfimg, l_lgort,
             l_lfimgb.
    ENDAT.

    l_matnr = wa_dt-matnr.
    CLEAR: l_vrkme.
    CLEAR: wa_dt.
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
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        wa_hd              = wa_hd
      TABLES
        i_dt               = i_dt.
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
  REFRESH: i_dt.
  CLEAR: wa_hd, wa_dt.
ENDFORM.                    " f_free_memory
