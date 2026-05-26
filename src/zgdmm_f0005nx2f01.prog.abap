*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
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

  CASE 'X'.
    WHEN p_reprt.
      PERFORM f_get_reprint_data.

      IF so_ebeln[] IS INITIAL.
        PERFORM f_print_form USING '' 'X' ''.
        PERFORM f_print_pr USING '' '' 'X'.
      ELSEIF gt_heads[] IS INITIAL.
        PERFORM f_print_form USING '' 'X' ''.
        PERFORM f_print_pr USING '' '' 'X'.
      ELSE.
        PERFORM f_print_form USING '' 'X' ''.
        PERFORM f_print_pr USING '' 'X' 'X'.
        PERFORM f_print_lampiran USING '' '' 'X'.
      ENDIF.

    WHEN OTHERS.
      PERFORM f_init_data.
      PERFORM f_get_data.
      PERFORM f_validate_data.
      PERFORM f_process_data.
      IF t_detail IS INITIAL AND
        wa_supplier IS INITIAL.
        MESSAGE s000(zab) WITH 'Data not found'.
      ELSE.
        PERFORM f_screen_entry.
      ENDIF.
  ENDCASE.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report

*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
FORM f_init_data.
  DATA: ld_matnr LIKE mara-matnr,
        ld_mfrnr LIKE mara-mfrnr.
  DATA: lt_lfa1  LIKE lfa1 OCCURS 0 WITH HEADER LINE,
        lr_group TYPE RANGE OF zgrpx,
        ls_group LIKE LINE OF lr_group,
        lv_zeile TYPE zgdmmt0004x-zeile,
        ls_004   LIKE LINE OF gt_004.

  SELECT SINGLE a~matnr a~mprof a~bismt a~meins
                b~maktx
    FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
    INTO CORRESPONDING FIELDS OF t_header
    WHERE a~matnr EQ pa_matnr.
  IF pa_matnr(3) EQ 'PCC'.
    t_header-matnr = t_header-bismt.
  ENDIF.

  CONCATENATE pa_matnr '*' INTO ld_matnr.
  ra_matnr-sign   = 'I'.
  ra_matnr-option = 'CP'.
  ra_matnr-low    = ld_matnr.
  APPEND ra_matnr.

  SELECT * FROM lfa1
    INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
    WHERE werks NE space.

  IF sy-subrc = 0.
    LOOP AT lt_lfa1.
      ra_mfrnr-sign   = 'E'.
      ra_mfrnr-option = 'CP'.
      ra_mfrnr-low    = lt_lfa1-lifnr.
      APPEND ra_mfrnr.
    ENDLOOP.
  ENDIF.

*  CONCATENATE 'TSB' '*' INTO ld_mfrnr.
*  ra_mfrnr-sign   = 'E'.
*  ra_mfrnr-option = 'CP'.
*  ra_mfrnr-low    = ld_mfrnr.
*  APPEND ra_mfrnr.

  ra_bsart-sign   = 'I'.
  ra_bsart-option = 'EQ'.
  ra_bsart-low    = 'ZIMP'.
  APPEND ra_bsart.
  ra_bsart-sign   = 'I'.
  ra_bsart-option = 'EQ'.
  ra_bsart-low    = 'ZLOC'.
  APPEND ra_bsart.

  IF p_old IS NOT INITIAL.
    SELECT *
      FROM zgdmmt0004x
      INTO CORRESPONDING FIELDS OF TABLE gt_004
      WHERE type = 'OLD'.
  ELSE.
    CASE 'X'.
      WHEN p_q1.
        ls_group-low   = '1'.
        ls_group-high  = '1'.
      WHEN p_q2.
        ls_group-low   = '1'.
        ls_group-high  = '2'.
      WHEN p_q3.
        ls_group-low   = '1'.
        ls_group-high  = '3'.
      WHEN p_q4.
        ls_group-low   = '1'.
        ls_group-high  = '4'.
    ENDCASE.
    ls_group-sign   = 'I'.
    ls_group-option = 'BT'.
    APPEND ls_group TO lr_group.

    SELECT *
      FROM zgdmmt0004x
      INTO CORRESPONDING FIELDS OF TABLE gt_004
      WHERE type = 'NEW'
        AND ( zgroup1 = space
         OR   zgroup1 IN lr_group ).

    LOOP AT gt_004 INTO ls_004.
      ls_004-xeile  = ls_004-zeile.
      ADD 1 TO lv_zeile.
      ls_004-zeile = lv_zeile.
      MODIFY gt_004 FROM ls_004 TRANSPORTING zeile xeile.
    ENDLOOP.
  ENDIF.

  IF p_q1 IS NOT INITIAL.
    PERFORM f_get_quarter_date USING pa_mjahr '0101' '0401'.
  ENDIF.
  IF p_q2 IS NOT INITIAL.
    PERFORM f_get_quarter_date USING pa_mjahr '0401' '0701'.
  ENDIF.
  IF p_q3 IS NOT INITIAL.
    PERFORM f_get_quarter_date USING pa_mjahr '0701' '1001'.
  ENDIF.
  IF p_q4 IS NOT INITIAL.
    PERFORM f_get_quarter_date USING pa_mjahr '1001' ''.
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
  DATA: ld_count      TYPE i,
        ld_tabix      LIKE sy-tabix,
        td_lines      TYPE tline OCCURS 0 WITH HEADER LINE,
        ld_infnr      LIKE thead-tdname,
        ld_menget     LIKE ekpo-menge,
        ld_kstbm_low  LIKE konm-kstbm,
        ld_kstbm_high LIKE konm-kstbm,
        ld_kbetr      LIKE konm-kbetr.

  DATA: lt_tcurf    TYPE STANDARD TABLE OF tcurf,
        l_tcurf_new TYPE tcurf,
        d_currdec   TYPE tcurx-currdec,
        i_date1     LIKE mcekko-bedat,
        i_date2     LIKE mcekko-bedat,
        i_date3     LIKE mcekko-bedat,
        i_date4     LIKE mcekko-bedat.

  DATA: ld_subttl1 LIKE eket-menge,
        ld_subttl2 LIKE eket-menge,
        ld_subttl3 LIKE eket-menge.

  DATA: lt_konm LIKE konm OCCURS 0 WITH HEADER LINE.
  DATA: ls_t026z LIKE t026z.

  DATA: lv_quart1,
        lv_quart2,
        lv_quart3,
        lv_quart4,
        lv_top(50).

  DATA : editpos     TYPE STANDARD TABLE OF cdred,
         ls_editpos  LIKE LINE OF editpos,
         lv_objectid TYPE cdhdr-objectid.

  DATA : lt_zm73  LIKE gt_zm73 OCCURS 0,
         ls_zm73  LIKE LINE OF lt_zm73,
         ls_xekko LIKE LINE OF gt_xekko,
         ls_xekpo LIKE LINE OF gt_xekpo,
         ls_xeket LIKE LINE OF gt_xeket.

  FIELD-SYMBOLS: <fs_supplier> LIKE t_supplier.

  SELECT SINGLE * INTO ls_t026z
    FROM t026z WHERE ekgrp = pa_ekgrp.

  SELECT * INTO TABLE gt_zmtnt_scor_aloc
    FROM zmtnt_scor_aloc.

  CONCATENATE pa_mjahr '0101' INTO i_date1.
  lv_quart1  = 1.
  CONCATENATE pa_mjahr '0401' INTO i_date2.
  lv_quart2  = 2.
  CONCATENATE pa_mjahr '0701' INTO i_date3.
  lv_quart3  = 3.
  CONCATENATE pa_mjahr '1001' INTO i_date4.
  lv_quart4  = 4.

  i_date1 = i_date1 - 1.
  PERFORM f_get_from_zm73n TABLES gt_zm73
                           USING i_date1 lv_quart1.

  CASE 'X'.
    WHEN p_q2.
      i_date2 = i_date2 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm732
                               USING i_date2 lv_quart2.
    WHEN p_q3.
      i_date2 = i_date2 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm732
                               USING i_date2 lv_quart2.
      i_date3 = i_date3 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm733
                               USING i_date3 lv_quart3.
    WHEN p_q4.
      i_date2 = i_date2 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm732
                               USING i_date2 lv_quart2.
      i_date3 = i_date3 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm733
                               USING i_date3 lv_quart3.
      i_date4 = i_date4 - 1.
      PERFORM f_get_from_zm73n TABLES gt_zm734
                               USING i_date4 lv_quart4.
  ENDCASE.

  PERFORM f_add_zm73.

  IF t_header-mprof EQ 'Z001'.
    SELECT matnr mfrnr mfrpn
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE t_mara
      WHERE matnr IN ra_matnr AND
            lvorm EQ space    AND
            mtart EQ 'HERS'   AND
            mfrnr IN ra_mfrnr.

    SELECT matnr lifnr infnr umrez erdat
      FROM eina
      INTO CORRESPONDING FIELDS OF TABLE t_eina1
      FOR ALL ENTRIES IN t_mara
      WHERE matnr EQ t_mara-matnr AND
*            lifnr EQ t_mara-mfrnr AND
            loekz EQ space.

    SELECT lifnr name1
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE t_lfa1
      FOR ALL ENTRIES IN t_eina1
      WHERE lifnr EQ t_eina1-lifnr.

    SELECT infnr ekorg esokz werks aplfz datlb ebeln ebelp
      FROM eine
      INTO CORRESPONDING FIELDS OF TABLE t_eine
      FOR ALL ENTRIES IN t_eina1
      WHERE infnr EQ t_eina1-infnr
        AND ekorg EQ ls_t026z-ekorg
        AND loekz EQ space.

    SORT t_eina1 BY infnr.
    SORT t_eine BY infnr.
    LOOP AT t_eina1.
      READ TABLE t_eine WITH KEY infnr = t_eina1-infnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_eina1-aplfz = t_eine-aplfz.
        MODIFY t_eina1 TRANSPORTING aplfz.
      ELSE.
*        t_eina1-aplfz = space.
        DELETE t_eina1.
        CONTINUE.
      ENDIF.
*      MODIFY t_eina1 TRANSPORTING aplfz.
      READ TABLE t_mara WITH KEY mfrnr = t_eina1-lifnr.
      IF sy-subrc NE 0.
        t_mara-matnr = t_eina1-matnr.
        t_mara-mfrnr = t_eina1-lifnr.
        ld_infnr = t_eina1-infnr.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'AT'
            language                = sy-langu
            name                    = ld_infnr
            object                  = 'EINA'
          TABLES
            lines                   = td_lines
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
          t_mara-mfrpn = td_lines-tdline.
        ELSE.
          t_mara-mfrpn = space.
        ENDIF.
        APPEND t_mara.
      ENDIF.
    ENDLOOP.

    SORT t_lfa1 BY lifnr.
    SORT t_mara BY mfrnr matnr.
    SORT t_eina1 BY lifnr matnr.
    LOOP AT t_mara.
      t_mara-tdline = t_mara-mfrpn.
      READ TABLE t_lfa1 WITH KEY lifnr = t_mara-mfrnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_mara-name1 = t_lfa1-name1.
      ELSE.
        t_mara-name1 = space.
      ENDIF.
      READ TABLE t_eina1 WITH KEY lifnr = t_mara-mfrnr
                                  matnr = t_mara-matnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_mara-aplfz = t_eina1-aplfz.
        t_mara-umrez = t_eina1-umrez.
        MODIFY t_mara TRANSPORTING name1 tdline aplfz umrez.
      ELSE.
        DELETE t_mara.
      ENDIF.
    ENDLOOP.
  ELSE.
    SELECT matnr infnr lifnr umrez erdat
      FROM eina
      INTO CORRESPONDING FIELDS OF TABLE t_eina
      WHERE matnr EQ pa_matnr AND
            lifnr IN ra_mfrnr AND
            loekz EQ space.

    SELECT lifnr name1
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE t_lfa1
      FOR ALL ENTRIES IN t_eina
      WHERE lifnr EQ t_eina-lifnr.

    SELECT infnr ekorg esokz werks aplfz datlb ebeln ebelp
      FROM eine
      INTO CORRESPONDING FIELDS OF TABLE t_eine
      FOR ALL ENTRIES IN t_eina
      WHERE infnr EQ t_eina-infnr
        AND ekorg EQ ls_t026z-ekorg
        AND loekz EQ space.

    SORT t_eina BY infnr.
    SORT t_eine BY infnr.
    LOOP AT t_eina.
      READ TABLE t_eine WITH KEY infnr = t_eina-infnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_eina-aplfz = t_eine-aplfz.
        MODIFY t_eina TRANSPORTING aplfz.
      ELSE.
*        t_eina-aplfz = space.
        DELETE t_eina.
      ENDIF.
*      MODIFY t_eina TRANSPORTING aplfz.
    ENDLOOP.

    SORT t_lfa1 BY lifnr.
    SORT t_eina BY lifnr.
    LOOP AT t_eina.
      ld_infnr = t_eina-infnr.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'AT'
          language                = sy-langu
          name                    = ld_infnr
          object                  = 'EINA'
        TABLES
          lines                   = td_lines
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
        LOOP AT td_lines.
          IF td_lines-tdline NE space.
            t_eina-tdline = td_lines-tdline.
          ENDIF.
        ENDLOOP.
      ELSE.
        t_eina-tdline = space.
      ENDIF.

      READ TABLE t_lfa1 WITH KEY lifnr = t_eina-lifnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_eina-name1 = t_lfa1-name1.
      ELSE.
        t_eina-name1 = space.
      ENDIF.
      MODIFY t_eina TRANSPORTING name1 tdline.
    ENDLOOP.
  ENDIF.

  LOOP AT t_lfa1.
    ra_lifnr-sign   = 'I'.
    ra_lifnr-option = 'EQ'.
    ra_lifnr-low    = t_lfa1-lifnr.
    APPEND ra_lifnr.

    ls_zm73-lifnr = t_lfa1-lifnr.
    APPEND ls_zm73 TO lt_zm73.
    CLEAR ls_zm73.
  ENDLOOP.

  IF gt_zm73[] IS INITIAL.
    gt_zm73[] = lt_zm73[].
  ENDIF.

  IF NOT t_mara[] IS INITIAL.
    SELECT lifnr matnr knumh datab
      FROM a018
      INTO CORRESPONDING FIELDS OF TABLE t_a018
      FOR ALL ENTRIES IN t_mara
      WHERE kappl EQ 'M'          AND
            kschl EQ 'ZPB0'       AND
            lifnr IN ra_lifnr     AND
            matnr EQ t_mara-matnr AND
            ekorg EQ 'TNT'        AND
            esokz EQ '0'.

    LOOP AT t_a018.
      READ TABLE t_mara WITH KEY matnr = t_a018-matnr.
      IF sy-subrc EQ 0.
        t_a018-umrez = t_mara-umrez.
        MODIFY t_a018 TRANSPORTING umrez.
      ENDIF.
    ENDLOOP.

    SELECT a~ebeln a~lifnr a~bedat a~knumv
           b~ebelp b~ematn b~meins b~infnr b~elikz b~menge
      FROM ekko AS a JOIN ekpo AS b ON a~ebeln EQ b~ebeln
      INTO CORRESPONDING FIELDS OF TABLE t_ekko1
      FOR ALL ENTRIES IN t_mara
      WHERE a~lifnr IN ra_lifnr     AND
            a~ekgrp EQ pa_ekgrp     AND
            a~bsart IN ra_bsart     AND
            a~loekz EQ space        AND
            a~autlf EQ space        AND
            b~loekz EQ space        AND
            b~ematn EQ t_mara-matnr AND
            b~werks EQ pa_werks.

    LOOP AT t_ekko1.
      IF t_ekko1-elikz IS INITIAL.
        MOVE-CORRESPONDING t_ekko1 TO t_ekko.
        APPEND t_ekko.
      ENDIF.
    ENDLOOP.

    IF t_ekko[] IS NOT INITIAL.
      SELECT ebeln ebelp etenr menge wemng
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE t_eket
        FOR ALL ENTRIES IN t_ekko
        WHERE ebeln EQ t_ekko-ebeln AND
              ebelp EQ t_ekko-ebelp.
    ENDIF.

    SORT t_eket BY ebeln ebelp.
    LOOP AT t_eket.
      t_eketsum = t_eket.
      t_eketsum-etenr = space.
      COLLECT t_eketsum.
    ENDLOOP.

    SORT t_ekko BY ebeln ebelp.
    SORT t_eketsum BY ebeln ebelp.
    LOOP AT t_ekko.
      READ TABLE t_eketsum WITH KEY ebeln = t_ekko-ebeln
                                    ebelp = t_ekko-ebelp
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_ekko-menge = t_eketsum-menge.
        t_ekko-wemng = t_eketsum-wemng.
      ELSE.
        CLEAR: t_ekko-menge, t_ekko-wemng.
      ENDIF.
      MODIFY t_ekko TRANSPORTING menge wemng.
    ENDLOOP.

    SORT t_ekko BY lifnr ematn.
    LOOP AT t_ekko.
      t_ekkosum-lifnr = t_ekko-lifnr.
      t_ekkosum-ematn = t_ekko-ematn.
      t_ekkosum-meins = t_ekko-meins.
      t_ekkosum-menge = t_ekko-menge.
      t_ekkosum-wemng = t_ekko-wemng.
      COLLECT t_ekkosum.
    ENDLOOP.
  ENDIF.

  IF NOT t_eina[] IS INITIAL.
    SELECT lifnr matnr knumh datab
      FROM a018
      INTO CORRESPONDING FIELDS OF TABLE t_a018
      FOR ALL ENTRIES IN t_eina
      WHERE kappl EQ 'M'          AND
            kschl EQ 'ZPB0'       AND
            lifnr IN ra_lifnr     AND
            matnr EQ t_eina-matnr AND
            ekorg EQ 'TNT'        AND
            esokz EQ '0'.

    LOOP AT t_a018.
      READ TABLE t_eina WITH KEY lifnr = t_a018-lifnr
                                 matnr = t_a018-matnr.
      IF sy-subrc EQ 0.
        t_a018-umrez = t_eina-umrez.
        MODIFY t_a018 TRANSPORTING umrez.
      ENDIF.
    ENDLOOP.

    SELECT a~ebeln a~lifnr a~bedat a~knumv
           b~ebelp b~ematn b~meins b~infnr b~elikz b~menge
      FROM ekko AS a JOIN ekpo AS b ON a~ebeln EQ b~ebeln
      INTO CORRESPONDING FIELDS OF TABLE t_ekko1
      FOR ALL ENTRIES IN t_eina
      WHERE a~lifnr IN ra_lifnr     AND
            a~ekgrp EQ pa_ekgrp     AND
            a~bsart IN ra_bsart     AND
            a~loekz EQ space        AND
            a~autlf EQ space        AND
            b~loekz EQ space        AND
            b~ematn EQ t_eina-matnr AND
            b~werks EQ pa_werks.

    LOOP AT t_ekko1.
      IF t_ekko1-elikz IS INITIAL.
        MOVE-CORRESPONDING t_ekko1 TO t_ekko.
        APPEND t_ekko.
      ENDIF.
    ENDLOOP.

    IF t_ekko[] IS NOT INITIAL.
      SELECT ebeln ebelp etenr menge wemng
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE t_eket
        FOR ALL ENTRIES IN t_ekko
        WHERE ebeln EQ t_ekko-ebeln AND
              ebelp EQ t_ekko-ebelp.
    ENDIF.

    SORT t_eket BY ebeln ebelp.
    LOOP AT t_eket.
      t_eketsum = t_eket.
      t_eketsum-etenr = space.
      COLLECT t_eketsum.
    ENDLOOP.

    SORT t_ekko BY ebeln ebelp.
    SORT t_eketsum BY ebeln ebelp.
    LOOP AT t_ekko.
      READ TABLE t_eketsum WITH KEY ebeln = t_ekko-ebeln
                                    ebelp = t_ekko-ebelp
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_ekko-menge = t_eketsum-menge.
        t_ekko-wemng = t_eketsum-wemng.
      ELSE.
        CLEAR: t_ekko-menge, t_ekko-wemng.
      ENDIF.
      MODIFY t_ekko TRANSPORTING menge wemng.
    ENDLOOP.

    SORT t_ekko BY lifnr ematn.
    LOOP AT t_ekko.
      t_ekkosum-lifnr = t_ekko-lifnr.
      t_ekkosum-ematn = t_ekko-ematn.
      t_ekkosum-meins = t_ekko-meins.
      t_ekkosum-menge = t_ekko-menge.
      t_ekkosum-wemng = t_ekko-wemng.
      COLLECT t_ekkosum.
    ENDLOOP.
  ENDIF.

  PERFORM f_alokasi_budget.
  PERFORM f_pembayaran USING ''
                       CHANGING lv_top.

  IF NOT t_mara[] IS INITIAL.
    SORT t_mara BY mfrnr matnr.
    SORT t_ekkosum BY lifnr ematn.
    SORT t_a018 BY lifnr matnr datab DESCENDING.

    LOOP AT gt_zm73.
      LOOP AT t_mara WHERE mfrnr = gt_zm73-lifnr.

*        CLEAR t_ekkosum.
*        READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
*                                      ematn = t_mara-matnr
*                                      BINARY SEARCH.

        CLEAR t_ekkosum.
        READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
                                      BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR t_ekkosum.
          READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
                                        ematn = t_mara-matnr
                                        BINARY SEARCH.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE t_supplier ASSIGNING <fs_supplier>
          WITH KEY lifnr1  = t_mara-mfrnr.
        IF sy-subrc = 0.
          <fs_supplier>-menge1 = <fs_supplier>-menge1 +
            ( t_ekkosum-menge - t_ekkosum-wemng ).
          ADD 1 TO <fs_supplier>-cnt1.
          <fs_supplier>-total1 = <fs_supplier>-total1 +
                                 t_ekkosum-menge.
        ELSE.
          READ TABLE t_supplier ASSIGNING <fs_supplier>
            WITH KEY lifnr2  = t_mara-mfrnr.
          IF sy-subrc = 0.
            <fs_supplier>-menge2 = <fs_supplier>-menge2 +
              ( t_ekkosum-menge - t_ekkosum-wemng ).
            ADD 1 TO <fs_supplier>-cnt2.
            <fs_supplier>-total2 = <fs_supplier>-total2 +
                                   t_ekkosum-menge.

          ELSE.
            READ TABLE t_supplier ASSIGNING <fs_supplier>
              WITH KEY lifnr3  = t_mara-mfrnr.
            IF sy-subrc = 0.
              <fs_supplier>-menge3 = <fs_supplier>-menge3 +
                ( t_ekkosum-menge - t_ekkosum-wemng ).
              ADD 1 TO <fs_supplier>-cnt3.
              <fs_supplier>-total3 = <fs_supplier>-total3 +
                                     t_ekkosum-menge.
            ELSE.
              ADD 1 TO ld_count.
              CASE ld_count.
                WHEN 1.
                  ADD 1 TO ld_tabix.
                  t_supplier-lifnr1  = t_mara-mfrnr.
                  t_supplier-name11  = t_mara-name1.
                  t_supplier-tdline1 = t_mara-tdline.
                  t_supplier-aplfz1  = t_mara-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
                                                ematn = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins1 = t_ekkosum-meins.
                    t_supplier-menge1 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total1 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins1, t_supplier-menge1, t_supplier-total1.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_mara-mfrnr
                                             matnr = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh1 = t_a018-knumh.
                    t_supplier-datab1 = t_a018-datab.
                    t_supplier-umrez1 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr1, t_supplier-konwa1,
                            t_supplier-kpein1, t_supplier-kmein1,
                            t_supplier-kzbzg1)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr1 = t_supplier-kbetr1 / t_supplier-kpein1.
*** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa1.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*            t_supplier-kbetr1 = t_supplier-kbetr1 / ( 10 ** d_currdec )
*** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab1, t_supplier-kbetr1,
                           t_supplier-konwa1, t_supplier-kpein1,
                           t_supplier-kmein1, t_supplier-kzbzg1,
                           t_supplier-umrez1, t_supplier-knumh1.
                  ENDIF.

                  t_supplier-cnt1    = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott1
                                              t_supplier-acts1%1 t_supplier-acts2%1
                                              t_supplier-acts3%1 t_supplier-acts4%1.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%1 t_supplier-alos2%1.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk11 t_supplier-actlk21
                                              t_supplier-actlk31 t_supplier-actlk41.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top1.

                  APPEND t_supplier.

                WHEN 2.
                  t_supplier-lifnr2  = t_mara-mfrnr.
                  t_supplier-name12  = t_mara-name1.
                  t_supplier-tdline2 = t_mara-tdline.
                  t_supplier-aplfz2  = t_mara-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
                                                ematn = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins2 = t_ekkosum-meins.
                    t_supplier-menge2 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total2 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins2, t_supplier-menge2, t_supplier-total2.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_mara-mfrnr
                                             matnr = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh2 = t_a018-knumh.
                    t_supplier-datab2 = t_a018-datab.
                    t_supplier-umrez2 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr2, t_supplier-konwa2,
                            t_supplier-kpein2, t_supplier-kmein2,
                            t_supplier-kzbzg2)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr2 = t_supplier-kbetr2 / t_supplier-kpein2.
*** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa2.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*            t_supplier-kbetr2 = t_supplier-kbetr2 / ( 10 ** d_currdec )
*** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab2, t_supplier-kbetr2,
                           t_supplier-konwa2, t_supplier-kpein2,
                           t_supplier-kmein2, t_supplier-kzbzg2,
                           t_supplier-umrez2, t_supplier-knumh2.
                  ENDIF.

                  t_supplier-cnt2    = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott2
                                              t_supplier-acts1%2 t_supplier-acts2%2
                                              t_supplier-acts3%2 t_supplier-acts4%2.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%2 t_supplier-alos2%2.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk12 t_supplier-actlk22
                                              t_supplier-actlk32 t_supplier-actlk42.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top2.

                  MODIFY t_supplier INDEX ld_tabix
                    TRANSPORTING lifnr2 name12 tdline2 aplfz2 meins2 menge2 knumh2
                                 datab2 umrez2 kbetr2 konwa2 kpein2 kmein2 kzbzg2
                                 bobott2 aloc%2 alos2%2
                                 cnt2 total2
                                 acts1%2 acts2%2 acts3%2 acts4%2
                                 actlk12 actlk22 actlk32 actlk42 top2.

                WHEN 3.
                  t_supplier-lifnr3  = t_mara-mfrnr.
                  t_supplier-name13  = t_mara-name1.
                  t_supplier-tdline3 = t_mara-tdline.
                  t_supplier-aplfz3  = t_mara-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_mara-mfrnr
                                                ematn = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins3 = t_ekkosum-meins.
                    t_supplier-menge3 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total3 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins3, t_supplier-menge3, t_supplier-total3.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_mara-mfrnr
                                             matnr = t_mara-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh3 = t_a018-knumh.
                    t_supplier-datab3 = t_a018-datab.
                    t_supplier-umrez3 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr3, t_supplier-konwa3,
                            t_supplier-kpein3, t_supplier-kmein3,
                            t_supplier-kzbzg3)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr3 = t_supplier-kbetr3 / t_supplier-kpein3.
*** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa3.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*            t_supplier-kbetr3 = t_supplier-kbetr3 / ( 10 ** d_currdec )
*** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab3, t_supplier-kbetr3,
                           t_supplier-konwa3, t_supplier-kpein3,
                           t_supplier-kmein3, t_supplier-kzbzg3,
                           t_supplier-umrez3, t_supplier-knumh3.
                  ENDIF.

                  t_supplier-cnt3    = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott3
                                              t_supplier-acts1%3 t_supplier-acts2%3
                                              t_supplier-acts3%3 t_supplier-acts4%3.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%3 t_supplier-alos2%3.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk13 t_supplier-actlk23
                                              t_supplier-actlk33 t_supplier-actlk43.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top3.

                  MODIFY t_supplier INDEX ld_tabix
                    TRANSPORTING lifnr3 name13 tdline3 aplfz3 meins3 menge3 knumh3
                                 datab3 umrez3 kbetr3 konwa3 kpein3 kmein3 kzbzg3
                                 bobott3 aloc%3 alos2%3
                                 cnt3 total3
                                 acts1%3 acts2%3 acts3%3 acts4%3
                                 actlk13 actlk23 actlk33 actlk43 top3.
                  CLEAR: ld_count.
                  CLEAR: t_supplier.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  IF NOT t_eina[] IS INITIAL.
    SORT t_eina BY lifnr.
    SORT t_ekkosum BY lifnr ematn.
    SORT t_a018 BY lifnr matnr datab DESCENDING.
    LOOP AT gt_zm73.
      LOOP AT t_eina WHERE lifnr = gt_zm73-lifnr.

        READ TABLE t_supplier ASSIGNING <fs_supplier>
          WITH KEY lifnr1  = t_eina-lifnr. "t_mara-mfrnr.
        IF sy-subrc = 0.
          <fs_supplier>-menge1 = <fs_supplier>-menge1 +
            ( t_ekkosum-menge - t_ekkosum-wemng ).
          ADD 1 TO <fs_supplier>-cnt1.
          <fs_supplier>-total1 = <fs_supplier>-total1 +
                                 t_ekkosum-menge.
        ELSE.
          READ TABLE t_supplier ASSIGNING <fs_supplier>
            WITH KEY lifnr2  = t_eina-lifnr. "t_mara-mfrnr.
          IF sy-subrc = 0.
            <fs_supplier>-menge2 = <fs_supplier>-menge2 +
              ( t_ekkosum-menge - t_ekkosum-wemng ).
            ADD 1 TO <fs_supplier>-cnt2.
            <fs_supplier>-total2 = <fs_supplier>-total2 +
                                   t_ekkosum-menge.
          ELSE.
            READ TABLE t_supplier ASSIGNING <fs_supplier>
              WITH KEY lifnr3  = t_eina-lifnr. "t_mara-mfrnr.
            IF sy-subrc = 0.
              <fs_supplier>-menge3 = <fs_supplier>-menge3 +
                ( t_ekkosum-menge - t_ekkosum-wemng ).
              ADD 1 TO <fs_supplier>-cnt3.
              <fs_supplier>-total3 = <fs_supplier>-total3 +
                                     t_ekkosum-menge.
            ELSE.
              ADD 1 TO ld_count.
              CASE ld_count.
                WHEN 1.
                  ADD 1 TO ld_tabix.
                  t_supplier-lifnr1  = t_eina-lifnr.
                  t_supplier-name11  = t_eina-name1.
                  t_supplier-tdline1 = t_eina-tdline.
                  t_supplier-aplfz1  = t_eina-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_eina-lifnr
                                                ematn = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins1 = t_ekkosum-meins.
                    t_supplier-menge1 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total1 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins1, t_supplier-menge1, t_supplier-total1.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_eina-lifnr
                                             matnr = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh1 = t_a018-knumh.
                    t_supplier-datab1 = t_a018-datab.
                    t_supplier-umrez1 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr1, t_supplier-konwa1,
                            t_supplier-kpein1, t_supplier-kmein1,
                            t_supplier-kzbzg1)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr1 = t_supplier-kbetr1 / t_supplier-kpein1.
** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa1.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*            t_supplier-kbetr1 = t_supplier-kbetr1 / ( 10 ** d_currdec )
** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab1, t_supplier-kbetr1,
                           t_supplier-konwa1, t_supplier-kpein1,
                           t_supplier-kmein1, t_supplier-kzbzg1,
                           t_supplier-umrez1, t_supplier-knumh1.
                  ENDIF.

                  t_supplier-cnt1    = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott1
                                              t_supplier-acts1%1 t_supplier-acts2%1
                                              t_supplier-acts3%1 t_supplier-acts4%1.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%1 t_supplier-alos2%1.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk11 t_supplier-actlk21
                                              t_supplier-actlk31 t_supplier-actlk41.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top1.

                  APPEND t_supplier.

                WHEN 2.
                  t_supplier-lifnr2  = t_eina-lifnr.
                  t_supplier-name12  = t_eina-name1.
                  t_supplier-tdline2 = t_eina-tdline.
                  t_supplier-aplfz2  = t_eina-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_eina-lifnr
                                                ematn = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins2 = t_ekkosum-meins.
                    t_supplier-menge2 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total2 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins2, t_supplier-menge2, t_supplier-total2.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_eina-lifnr
                                             matnr = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh2 = t_a018-knumh.
                    t_supplier-datab2 = t_a018-datab.
                    t_supplier-umrez2 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr2, t_supplier-konwa2,
                            t_supplier-kpein2, t_supplier-kmein2,
                            t_supplier-kzbzg2)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr2 = t_supplier-kbetr2 / t_supplier-kpein2.
*
*** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa2.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*
*            t_supplier-kbetr2 = t_supplier-kbetr2 / ( 10 ** d_currdec )
*** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab2, t_supplier-kbetr2,
                           t_supplier-konwa2, t_supplier-kpein2,
                           t_supplier-kmein2, t_supplier-kzbzg2,
                           t_supplier-umrez2, t_supplier-knumh2.
                  ENDIF.

                  t_supplier-cnt2   = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott2
                                              t_supplier-acts1%2 t_supplier-acts2%2
                                              t_supplier-acts3%2 t_supplier-acts4%2.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%2 t_supplier-alos2%2.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk12 t_supplier-actlk22
                                              t_supplier-actlk32 t_supplier-actlk42.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top2.

                  MODIFY t_supplier INDEX ld_tabix
                    TRANSPORTING lifnr2 name12 tdline2 aplfz2 meins2 menge2 knumh2
                                 datab2 umrez2 kbetr2 konwa2 kpein2 kmein2 kzbzg2
                                 bobott2 aloc%2 alos2%2
                                 cnt2 total2
                                 acts1%2 acts2%2 acts3%2 acts4%2
                                 actlk12 actlk22 actlk32 actlk42 top2.

                WHEN 3.
                  t_supplier-lifnr3  = t_eina-lifnr.
                  t_supplier-name13  = t_eina-name1.
                  t_supplier-tdline3 = t_eina-tdline.
                  t_supplier-aplfz3  = t_eina-aplfz.
                  READ TABLE t_ekkosum WITH KEY lifnr = t_eina-lifnr
                                                ematn = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-meins3 = t_ekkosum-meins.
                    t_supplier-menge3 = t_ekkosum-menge - t_ekkosum-wemng.
                    t_supplier-total3 = t_ekkosum-menge.
                  ELSE.
                    CLEAR: t_supplier-meins3, t_supplier-menge3, t_supplier-total3.
                  ENDIF.
                  READ TABLE t_a018 WITH KEY lifnr = t_eina-lifnr
                                             matnr = t_eina-matnr
                    BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    t_supplier-knumh3 = t_a018-knumh.
                    t_supplier-datab3 = t_a018-datab.
                    t_supplier-umrez3 = t_a018-umrez.
                    SELECT SINGLE kbetr konwa kpein kmein kzbzg
                      FROM konp
                      INTO (t_supplier-kbetr3, t_supplier-konwa3,
                            t_supplier-kpein3, t_supplier-kmein3,
                            t_supplier-kzbzg3)
                      WHERE knumh    EQ t_a018-knumh AND
                            kappl    EQ 'M'          AND
                            kschl    EQ 'ZPB0'       AND
                            loevm_ko EQ space.

*            t_supplier-kbetr3 = t_supplier-kbetr3 / t_supplier-kpein3.
*
*** Revise by budi 10/10/2006
*            SELECT SINGLE currdec FROM tcurx INTO d_currdec
*            WHERE currkey = t_supplier-konwa3.
*            IF sy-subrc = 4.
*              d_currdec = 2.
*            ENDIF.
*
*            t_supplier-kbetr3 = t_supplier-kbetr3 / ( 10 ** d_currdec )
** End Revise by budi 10/10/2006

                  ELSE.
                    CLEAR: t_supplier-datab3, t_supplier-kbetr3,
                           t_supplier-konwa3, t_supplier-kpein3,
                           t_supplier-kmein3, t_supplier-kzbzg3,
                           t_supplier-umrez3, t_supplier-knumh3.
                  ENDIF.

                  t_supplier-cnt3   = 1.

                  PERFORM f_semester USING gt_zm73-lifnr gt_zm73-bobot gt_zm73-%aloc
                                     CHANGING t_supplier-bobott3
                                              t_supplier-acts1%3 t_supplier-acts2%3
                                              t_supplier-acts3%3 t_supplier-acts4%3.

                  PERFORM f_alloc USING gt_zm73-lifnr
                                  CHANGING t_supplier-aloc%3 t_supplier-alos2%3.

                  PERFORM f_actalloc USING gt_zm73-lifnr
                                     CHANGING t_supplier-actlk13 t_supplier-actlk23
                                              t_supplier-actlk33 t_supplier-actlk43.

                  PERFORM f_pembayaran USING gt_zm73-lifnr
                                       CHANGING t_supplier-top3.

                  MODIFY t_supplier INDEX ld_tabix
                    TRANSPORTING lifnr3 name13 tdline3 aplfz3 meins3 menge3 knumh3
                                 datab3 umrez3 kbetr3 konwa3 kpein3 kmein3 kzbzg3
                                 bobott3 aloc%3 alos2%3
                                 cnt3 total3
                                 acts1%3 acts2%3 acts3%3 acts4%3
                                 actlk13 actlk23 actlk33 actlk43 top3.
                  CLEAR: ld_count.
                  CLEAR: t_supplier.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

* Main Window
  IF so_ebeln[] IS NOT INITIAL.
    CLEAR : gt_xekko[], gt_xekpo[].

    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE gt_xekko
      WHERE ebeln IN so_ebeln
        AND loekz  = space
        AND bedat IN gr_datum.

    IF gt_xekko[] IS NOT INITIAL.
      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_xekpo
        FOR ALL ENTRIES IN gt_xekko
        WHERE ebeln = gt_xekko-ebeln
          AND loekz = space
          AND matnr = pa_matnr.

      IF gt_xekpo[] IS NOT INITIAL.
        SELECT *
          FROM eket
          INTO CORRESPONDING FIELDS OF TABLE gt_xeket
          FOR ALL ENTRIES IN gt_xekpo
          WHERE ebeln = gt_xekpo-ebeln
            AND ebelp = gt_xekpo-ebelp.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT matnr banfn bnfpo lfdat meins menge bsmng frgdt frgst badat
    FROM eban
    INTO CORRESPONDING FIELDS OF TABLE t_detail
    WHERE matnr EQ pa_matnr AND
          loekz EQ space    AND
          ekgrp EQ pa_ekgrp AND
          werks EQ pa_werks AND
          frgrl EQ space    AND
          ebakz EQ space    AND
          lfdat IN so_lfdat.

  PERFORM f_add_detail_from_ekpo.

  LOOP AT t_detail.
    ld_menget = t_detail-menge - t_detail-bsmng.
    ADD ld_menget TO va_menget.

    IF t_detail-frgst = space.
      t_detail-frgdt  = t_detail-badat.
    ELSE.
      CLEAR editpos[].

      lv_objectid  = t_detail-banfn.
      CALL FUNCTION 'CHANGEDOCUMENT_READ'
        EXPORTING
          objectclass                = 'BANF'
          objectid                   = lv_objectid
        TABLES
          editpos                    = editpos
        EXCEPTIONS
          no_position_found          = 1
          wrong_access_to_archive    = 2
          time_zone_conversion_error = 3
          OTHERS                     = 4.

      SORT editpos BY objectid udate DESCENDING.
      READ TABLE editpos INTO ls_editpos
                         WITH KEY fname = 'FRGKZ'
                                  f_new = '2'.
      IF sy-subrc = 0.
        t_detail-frgdt  = ls_editpos-udate.
      ENDIF.
    ENDIF.
    MODIFY t_detail TRANSPORTING frgdt.
  ENDLOOP.

  CLEAR: ld_tabix.
  LOOP AT t_supplier.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input    = t_supplier-kmein1
        language = sy-langu
      IMPORTING
        output   = t_supplier-kmein1.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input    = t_supplier-kmein2
        language = sy-langu
      IMPORTING
        output   = t_supplier-kmein2.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input    = t_supplier-kmein3
        language = sy-langu
      IMPORTING
        output   = t_supplier-kmein3.

    MODIFY t_supplier TRANSPORTING kmein1 kmein2 kmein3.

    REFRESH: lt_konm.
    CLEAR: lt_konm, ld_kbetr, ld_kstbm_low, ld_kstbm_high, ld_tabix.
    IF t_supplier-kzbzg1 EQ 'C'.
      ld_subttl1 = va_menget / t_supplier-umrez1.
      SELECT *
        FROM konm
        INTO CORRESPONDING FIELDS OF TABLE lt_konm
        WHERE knumh EQ t_supplier-knumh1.
      LOOP AT lt_konm.
        ld_tabix     = sy-tabix + 1.
        ld_kstbm_low = lt_konm-kstbm.
        ld_kbetr     = lt_konm-kbetr.
        READ TABLE lt_konm INDEX ld_tabix.
        IF sy-subrc EQ 0.
          ld_kstbm_high = lt_konm-kstbm.
          IF ld_subttl1 GE ld_kstbm_low AND
             ld_subttl1 LT ld_kstbm_high.
            t_supplier-kbetr1 = ld_kbetr.

*            IF NOT t_supplier-kpein1 IS INITIAL.
*              t_supplier-kbetr1 = ld_kbetr / t_supplier-kpein1.
*
*              SELECT SINGLE currdec
*                FROM tcurx
*                INTO d_currdec
*                WHERE currkey = t_supplier-konwa1.
*                IF sy-subrc = 4.
*                  d_currdec = 2.
*                ENDIF.
*                t_supplier-kbetr1 = t_supplier-kbetr1 /
*                                    ( 10 ** d_currdec ).
*            ENDIF.
            MODIFY t_supplier TRANSPORTING kbetr1.
            EXIT.
          ENDIF.
        ELSE.
          t_supplier-kbetr1 = lt_konm-kbetr.

*          IF NOT t_supplier-kpein1 IS INITIAL.
*            t_supplier-kbetr1 = lt_konm-kbetr / t_supplier-kpein1.
*
*            SELECT SINGLE currdec
*              FROM tcurx
*              INTO d_currdec
*              WHERE currkey = t_supplier-konwa1.
*              IF sy-subrc = 4.
*                d_currdec = 2.
*              ENDIF.
*              t_supplier-kbetr1 = t_supplier-kbetr1 /
*                                  ( 10 ** d_currdec ).
*          ENDIF.
          MODIFY t_supplier TRANSPORTING kbetr1.
        ENDIF.
      ENDLOOP.
    ENDIF.

    REFRESH: lt_konm.
    CLEAR: lt_konm, ld_kbetr, ld_kstbm_low, ld_kstbm_high, ld_tabix.
    IF t_supplier-kzbzg2 EQ 'C'.
      ld_subttl2 = va_menget / t_supplier-umrez2.
      SELECT *
        FROM konm
        INTO CORRESPONDING FIELDS OF TABLE lt_konm
        WHERE knumh EQ t_supplier-knumh2.
      LOOP AT lt_konm.
        ld_tabix     = sy-tabix + 1.
        ld_kstbm_low = lt_konm-kstbm.
        ld_kbetr     = lt_konm-kbetr.
        READ TABLE lt_konm INDEX ld_tabix.
        IF sy-subrc EQ 0.
          ld_kstbm_high = lt_konm-kstbm.
          IF ld_subttl2 GE ld_kstbm_low AND
             ld_subttl2 LT ld_kstbm_high.
            t_supplier-kbetr2 = ld_kbetr.

*            IF NOT t_supplier-kpein2 IS INITIAL.
*              t_supplier-kbetr2 = ld_kbetr / t_supplier-kpein2.
*
*              SELECT SINGLE currdec
*                FROM tcurx
*                INTO d_currdec
*                WHERE currkey = t_supplier-konwa2.
*                IF sy-subrc = 4.
*                  d_currdec = 2.
*                ENDIF.
*                t_supplier-kbetr2 = t_supplier-kbetr2 /
*                                    ( 10 ** d_currdec ).
*            ENDIF.
            MODIFY t_supplier TRANSPORTING kbetr2.
            EXIT.
          ENDIF.
        ELSE.
          t_supplier-kbetr2 = lt_konm-kbetr.

*          IF NOT t_supplier-kpein2 IS INITIAL.
*            t_supplier-kbetr2 = lt_konm-kbetr / t_supplier-kpein2.
*
*            SELECT SINGLE currdec
*              FROM tcurx
*              INTO d_currdec
*              WHERE currkey = t_supplier-konwa2.
*              IF sy-subrc = 4.
*                d_currdec = 2.
*              ENDIF.
*              t_supplier-kbetr2 = t_supplier-kbetr2 /
*                                  ( 10 ** d_currdec ).
*          ENDIF.
          MODIFY t_supplier TRANSPORTING kbetr2.
        ENDIF.
      ENDLOOP.
    ENDIF.

    REFRESH: lt_konm.
    CLEAR: lt_konm, ld_kbetr, ld_kstbm_low, ld_kstbm_high, ld_tabix.
    IF t_supplier-kzbzg3 EQ 'C'.
      ld_subttl3 = va_menget / t_supplier-umrez3.
      SELECT *
        FROM konm
        INTO CORRESPONDING FIELDS OF TABLE lt_konm
        WHERE knumh EQ t_supplier-knumh3.
      LOOP AT lt_konm.
        ld_tabix     = sy-tabix + 1.
        ld_kstbm_low = lt_konm-kstbm.
        ld_kbetr     = lt_konm-kbetr.
        READ TABLE lt_konm INDEX ld_tabix.
        IF sy-subrc EQ 0.
          ld_kstbm_high = lt_konm-kstbm.
          IF ld_subttl3 GE ld_kstbm_low AND
             ld_subttl3 LT ld_kstbm_high.
            t_supplier-kbetr3 = ld_kbetr.

*            IF NOT t_supplier-kpein3 IS INITIAL.
*              t_supplier-kbetr3 = ld_kbetr / t_supplier-kpein3.
*
*              SELECT SINGLE currdec
*                FROM tcurx
*                INTO d_currdec
*                WHERE currkey = t_supplier-konwa3.
*                IF sy-subrc = 4.
*                  d_currdec = 2.
*                ENDIF.
*                t_supplier-kbetr3 = t_supplier-kbetr3 /
*                                    ( 10 ** d_currdec ).
*            ENDIF.
            MODIFY t_supplier TRANSPORTING kbetr3.
            EXIT.
          ENDIF.
        ELSE.
          t_supplier-kbetr3 = lt_konm-kbetr.

*          IF NOT t_supplier-kpein3 IS INITIAL.
*            t_supplier-kbetr3 = lt_konm-kbetr / t_supplier-kpein3.
*
*            SELECT SINGLE currdec
*              FROM tcurx
*              INTO d_currdec
*              WHERE currkey = t_supplier-konwa3.
*              IF sy-subrc = 4.
*                d_currdec = 2.
*              ENDIF.
*              t_supplier-kbetr3 = t_supplier-kbetr3 /
*                                  ( 10 ** d_currdec ).
*          ENDIF.
          MODIFY t_supplier TRANSPORTING kbetr3.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
FORM f_validate_data.
  TYPES : BEGIN OF ty_ekpo,
            ebeln TYPE ekpo-ebeln,
            ebelp TYPE ekpo-ebelp,
          END OF ty_ekpo.

  DATA : ls_eipa       LIKE LINE OF t_eipa,
         lv_ppeinh(20),
         lv_pprme(10).

  DATA : lt_xeipa TYPE STANDARD TABLE OF eipa,
         lt_ekpo  TYPE STANDARD TABLE OF ty_ekpo,
         ls_ekpo  LIKE LINE OF lt_ekpo.

  IF t_eine[] IS NOT INITIAL.
    SELECT *
      FROM eipa
      INTO CORRESPONDING FIELDS OF TABLE t_eipa
      FOR ALL ENTRIES IN t_eine
      WHERE infnr = t_eine-infnr
        AND werks = pa_werks.

    lt_xeipa[] = t_eipa[].
    SORT lt_xeipa BY ebeln ebelp.
    DELETE ADJACENT DUPLICATES FROM lt_xeipa COMPARING ebeln ebeln.
    IF lt_xeipa[] IS NOT INITIAL.
      SELECT ebeln ebelp
        FROM ekpo
        INTO TABLE lt_ekpo
        FOR ALL ENTRIES IN lt_xeipa
        WHERE ebeln = lt_xeipa-ebeln
          AND ebelp = lt_xeipa-ebelp
          AND loekz = space.
    ENDIF.

    LOOP AT t_eipa INTO ls_eipa.
      READ TABLE lt_ekpo INTO ls_ekpo
                         WITH KEY ebeln = ls_eipa-ebeln
                                  ebelp = ls_eipa-ebelp.
      IF sy-subrc <> 0.
        DELETE TABLE t_eipa FROM ls_eipa.
      ENDIF.
    ENDLOOP.
  ENDIF.

  READ TABLE t_eipa INTO ls_eipa INDEX 1.
  PERFORM f_material_conversion USING va_menget pa_matnr ls_eipa-bprme
                                      t_header-meins ''
                                CHANGING va_menget.

  PERFORM f_prepare_last_purchased.
  PERFORM f_prepare_highest_price TABLES t_eipa
                                  CHANGING t_header-highp t_header-pwaer
                                           t_header-ppeinh t_header-pprme
                                           t_header-aedat.

  WRITE t_header-highp TO t_header-hight CURRENCY t_header-pwaer.
  CONDENSE t_header-hight NO-GAPS.
  IF t_header-ppeinh IS NOT INITIAL.
    lv_ppeinh = t_header-ppeinh.
    CONDENSE lv_ppeinh.
    PERFORM f_unit_conversion USING t_header-pprme
                              CHANGING lv_pprme.
    CONCATENATE t_header-hight '/' lv_ppeinh lv_pprme
    INTO t_header-hight
    SEPARATED BY space.
  ENDIF.

ENDFORM.                    " f_validate_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
FORM f_process_data.
  TYPES : BEGIN OF ty_ekpo,
            ebeln TYPE ekpo-ebeln,
            ebelp TYPE ekpo-ebelp,
            netpr TYPE ekpo-netpr,
            menge TYPE ekpo-menge,
            meins TYPE ekpo-meins,
          END OF ty_ekpo.

  DATA : lt_ekpo TYPE STANDARD TABLE OF ekpo,
         ls_ekpo LIKE LINE OF lt_ekpo,
         ls_ekko LIKE LINE OF t_ekko.

  DATA : lv_netpr     TYPE ekpo-netpr,
         lv_menge     TYPE ekpo-menge,
         lv_waers     TYPE ekko-waers,
         lv_kmein(10),
         lv_kpein(50),
         ls_konv      TYPE konv,
         ls_eipa      LIKE LINE OF t_eipa,
         lv_subrc     TYPE sy-subrc,
         lv_knumv     TYPE ekko-knumv,
         lt_konv      TYPE STANDARD TABLE OF konv.

  t_header-gjahr  = sy-datum(4).

  DESCRIBE TABLE t_detail LINES va_record.
  va_totpage = va_record DIV 5.

  IF t_supplier[] IS NOT INITIAL.
    PERFORM f_hitung_ranking.
  ENDIF.

  IF t_header IS NOT INITIAL.
    PERFORM f_get_budget_price  USING    pa_matnr
                                CHANGING t_header-konwa
                                         t_header-budget.

    SORT t_eine BY datlb DESCENDING.
    SORT t_eipa BY bedat DESCENDING ebeln DESCENDING.
*    READ TABLE t_eine INDEX 1.
*    IF sy-subrc = 0.
**    LOOP AT t_eine.
    CLEAR lv_subrc.
    LOOP AT t_eipa INTO ls_eipa. "WHERE infnr = t_eine-infnr.
**    READ TABLE t_eipa INTO ls_eipa INDEX 1.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = ls_eipa-bprme
        IMPORTING
          output         = lv_kmein
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      t_header-meins  = ls_eipa-bprme.
      t_header-meinst = lv_kmein.

      IF so_ebeln[] IS NOT INITIAL.
        IF ls_eipa-ebeln IN so_ebeln.
          CONTINUE.
        ENDIF.
      ENDIF.

      SELECT SINGLE *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF ls_ekpo
        WHERE ebeln = ls_eipa-ebeln
          AND ebelp = ls_eipa-ebelp
          AND loekz = space.

      IF sy-subrc = 0.
        t_header-datlb = ls_eipa-bedat.

        SELECT SINGLE ekko~lifnr waers name1 knumv
          FROM ekko JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
          INTO (t_header-lifnr, t_header-waers, t_header-name1, lv_knumv)
          WHERE ebeln = ls_eipa-ebeln.

        SELECT *
          FROM konv
          INTO CORRESPONDING FIELDS OF TABLE lt_konv
          WHERE knumv = lv_knumv
            AND kposn = ls_eipa-ebelp.

        LOOP AT lt_konv INTO ls_konv.
          IF ls_konv-kschl(3) = 'ZPB'.
            ls_eipa-preis = ls_konv-kbetr.
            ls_eipa-bwaer = ls_konv-waers.
            ls_eipa-peinh = ls_konv-kpein.
            ls_eipa-bprme = ls_konv-kmein.
            EXIT.
          ENDIF.
        ENDLOOP.

        t_header-waers  = ls_eipa-bwaer.

        WRITE ls_eipa-preis TO t_header-netprt CURRENCY ls_eipa-bwaer.
        CONDENSE t_header-netprt NO-GAPS.

        WRITE ls_eipa-peinh TO lv_kpein UNIT ls_eipa-bprme.
        CONDENSE lv_kpein NO-GAPS.


        CONCATENATE lv_kpein lv_kmein INTO lv_kpein SEPARATED BY space.

        CONCATENATE t_header-netprt '/' lv_kpein INTO t_header-netprt
        SEPARATED BY space.

        IF ls_eipa-bprme = ls_ekpo-meins.
          WRITE ls_ekpo-menge TO t_header-menget UNIT ls_eipa-bprme.
        ELSE.
          WRITE ls_eipa-menge TO t_header-menget UNIT ls_eipa-bprme.
        ENDIF.
        CONDENSE t_header-menget NO-GAPS.
        CONCATENATE t_header-menget lv_kmein INTO t_header-menget
        SEPARATED BY space.


        lv_subrc = 4.
        EXIT.
      ENDIF.
    ENDLOOP.
**      IF lv_subrc IS NOT INITIAL.
**        EXIT.
**      ENDIF.
**    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
FORM f_print_form USING fu_ucomm fu_close fu_open.
  DATA: ld_count    TYPE i,
        ld_menge    LIKE zgdmmst0052-menge,
        ld_total    LIKE zgdmmst0052-menge,
        lv_supplier TYPE i.

  DATA: lt_nsupl    TYPE STANDARD TABLE OF zgdmmst0055.

  SORT t_detail BY banfn.
  LOOP AT t_detail.
    ld_menge = t_detail-menge - t_detail-bsmng.
    IF ld_menge = 0.
      DELETE t_detail.
      CONTINUE.
    ENDIF.
    ADD 1 TO ld_count.
    ADD ld_menge TO ld_total.
    IF ld_count EQ 4.
      PERFORM f_material_conversion USING ld_total pa_matnr t_header-meins
                                          t_detail-meins ''
                                    CHANGING t_sub-menge.
      APPEND t_sub.
      CLEAR: ld_count.
    ENDIF.
  ENDLOOP.

  PERFORM f_material_conversion USING t_sub-menge pa_matnr t_header-meins
                                      t_detail-meins ''
                                CHANGING t_sub-menge.
  APPEND t_sub.
  CLEAR: ld_count, t_sub-menge.
  DESCRIBE TABLE t_sub LINES va_lines.

*  p_tdform  = 'ZGDMMF0005_03NX'.
  p_tdform  = 'ZGDMMF0005_03NX1'.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  d_ctrl_param-no_open  = 'X'.
  d_ctrl_param-no_close = fu_close.

*  d_output_opt-tdnoprint = p_disp.
  CASE fu_ucomm.
    WHEN 'SAVE'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = space.
      d_ctrl_param-preview      = space.
**      d_output_opt-tdnewid      = 'X'.
**      d_output_opt-tdimmed      = 'X'.
**      d_output_opt-tddelete     = space.
    WHEN 'PREV'.
      d_output_opt-tdnoprint    = 'X'.
  ENDCASE.

  IF d_frm_subrc IS INITIAL.
**      call the generated function module of the form
    IF t_supplier[] IS INITIAL.
      IF NOT t_detail[] IS INITIAL.
        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            t_header           = t_header
            wa_supplier        = wa_supplier
            va_menget          = va_menget
            va_record          = va_record
            va_totpage         = va_totpage
            va_lines           = va_lines
          TABLES
            t_detail           = t_detail
            t_sub              = t_sub
            t_suppl            = gt_xsuppl.

        IF sy-subrc NE 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ELSE.
      DESCRIBE TABLE t_supplier LINES lv_supplier.
      LOOP AT t_supplier INTO wa_supplier.
        CLEAR : lt_nsupl[].

        PERFORM f_prepare_supplier_data TABLES lt_nsupl
                                        USING wa_supplier-lifnr1
                                              wa_supplier-lifnr2
                                              wa_supplier-lifnr3.
        IF fu_open IS INITIAL AND
          fu_close IS INITIAL.
          AT FIRST.
            d_ctrl_param-no_close = 'X'.
          ENDAT.

          AT LAST.
            d_ctrl_param-no_close = space.
          ENDAT.
        ENDIF.

        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            t_header           = t_header
            wa_supplier        = wa_supplier
            va_menget          = va_menget
            va_record          = va_record
            va_totpage         = va_totpage
            va_lines           = va_lines
          TABLES
            t_detail           = t_detail
            t_sub              = t_sub
            t_suppl            = gt_xsuppl
            t_nsupl            = lt_nsupl.

        IF sy-subrc NE 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        IF fu_open IS INITIAL AND
          fu_close IS INITIAL.
          d_ctrl_param-no_open = 'X'.
        ELSEIF lv_supplier > 1.
          d_ctrl_param-no_open = 'X'.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
  CLEAR : va_lines, t_sub[], t_sub.
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
*&      Form  F_GET_FROM_ZM73N
*&---------------------------------------------------------------------*
FORM f_get_from_zm73n TABLES ft_zm73  STRUCTURE gt_zm73
                      USING fu_date fu_quarter.
  DATA: lv_count TYPE int1,
        lt_zm73  LIKE gt_zm73 OCCURS 0,
        ls_zm73  LIKE gt_zm73,
        lr_zm73n TYPE REF TO data,
        ls_zm73n TYPE REF TO data,
        lr_werks TYPE RANGE OF ekpo-werks WITH HEADER LINE,
        lr_ekgrp TYPE RANGE OF ekko-ekgrp WITH HEADER LINE,
        lr_matnr TYPE RANGE OF ekpo-matnr WITH HEADER LINE,
        lr_loekz TYPE RANGE OF ekpo-loekz WITH HEADER LINE.

  DATA : lv_datef TYPE sy-datum,
         lv_datet TYPE sy-datum,
         lv_subrc TYPE sy-subrc,
         lv_diff  TYPE i,
         lv_old   TYPE mara-matnr,
         lv_sem.

  DATA : lt_lfa1 LIKE t_lfa1 OCCURS 0,
         ls_lfa1 LIKE LINE OF lt_lfa1.

  DATA : lv_%aloctot TYPE zbobottop.

  FIELD-SYMBOLS: <ft_zm73n> TYPE ANY TABLE,
                 <fs_zm73n> TYPE any,
                 <fs_lifnr> TYPE any,
                 <fs_bobot> TYPE any,
                 <fs_matnr> TYPE any,
                 <ft_zm73>  LIKE gt_zm73.

  lr_werks-sign   = 'I'.
  lr_werks-option = 'EQ'.
  lr_werks-low    = pa_werks.
  APPEND lr_werks.
  lr_ekgrp-sign   = 'I'.
  lr_ekgrp-option = 'EQ'.
  lr_ekgrp-low    = pa_ekgrp.
  APPEND lr_ekgrp.
  lr_matnr-sign   = 'I'.
  lr_matnr-option = 'EQ'.
  lr_matnr-low    = pa_matnr.
  APPEND lr_matnr.
  lr_loekz-sign   = 'E'.
  lr_loekz-option = 'EQ'.
  lr_loekz-low    = 'L'.
  APPEND lr_loekz.

  IF pa_ean11 IS NOT INITIAL.
    lr_matnr-low    = pa_ean11.
    lr_matnr-sign   = 'I'.
    lr_matnr-option = 'EQ'.
    APPEND lr_matnr.
    lv_old  = pa_matnr.
  ELSE.
    CLEAR lv_old.
  ENDIF.

  IF fu_date IS NOT INITIAL.
    pa_sdate = fu_date.
  ENDIF.

  cl_salv_bs_runtime_info=>set(
    EXPORTING display  = abap_false
              metadata = abap_false
              data     = abap_true ).

  SUBMIT zm_vendor_evaluation_newv3
*    WITH so_bukrs  IN so_bukrs
    WITH so_werks  IN lr_werks
    WITH so_ekgrp  IN lr_ekgrp
    WITH so_matnr  IN lr_matnr
*    WITH so_ponum  IN so_ponum
*    WITH so_lifnr  IN so_lifnr
    WITH p_assdt   EQ pa_sdate
    WITH so_loekz  IN lr_loekz
    WITH p_nodisp  EQ 'X'
    WITH p_get6    EQ p_get6
    WITH p_old     EQ pa_ean11
    WITH p_quart   EQ fu_quarter
    WITH pa_mjahr  EQ pa_mjahr
    AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
        IMPORTING r_data = lr_zm73n ).
      ASSIGN lr_zm73n->* TO <ft_zm73n>.

      IF <ft_zm73n> IS ASSIGNED.
        CREATE DATA ls_zm73n LIKE LINE OF <ft_zm73n>.
        ASSIGN ls_zm73n->* TO <fs_zm73n>.
      ENDIF.

    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.

  IF <ft_zm73n> IS ASSIGNED.
    LOOP AT <ft_zm73n> ASSIGNING <fs_zm73n>.
      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_zm73n> TO <fs_lifnr>.
      ASSIGN COMPONENT 'BOBOTTOTAL' OF STRUCTURE <fs_zm73n> TO <fs_bobot>.
      ls_zm73-lifnr = <fs_lifnr>.
      ls_zm73-bobot = <fs_bobot>.
      APPEND ls_zm73 TO lt_zm73.

      ASSIGN COMPONENT 'MATNR' OF STRUCTURE  <fs_zm73n> TO <fs_matnr>.
      IF <fs_matnr> = pa_matnr.
        ls_lfa1-lifnr = ls_zm73-lifnr.
        APPEND ls_lfa1 TO lt_lfa1.
      ENDIF.
    ENDLOOP.
  ENDIF.

  cl_salv_bs_runtime_info=>clear_all( ).

  SORT lt_zm73 BY lifnr.
  CLEAR ls_zm73.
  LOOP AT lt_zm73 INTO ls_zm73.
    READ TABLE lt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = ls_zm73-lifnr.
    IF sy-subrc = 0.
      COLLECT ls_zm73 INTO ft_zm73.
    ENDIF.
    CLEAR ls_zm73.
  ENDLOOP.

  "Hitung 4 vendor dg bobot terbesar
  CLEAR: lv_count, gv_lines, gv_bobottot.
  SORT ft_zm73 BY bobot DESCENDING lifnr.
  LOOP AT ft_zm73.
    ADD 1 TO lv_count.
    IF lv_count GT 4.
*      CLEAR gt_zm73-bobot.
*      MODIFY gt_zm73 TRANSPORTING bobot.
    ELSE.
      gv_lines = lv_count.
      ADD ft_zm73-bobot TO gv_bobottot.
    ENDIF.
  ENDLOOP.

  "Hitung score different
  CLEAR: lv_count,ls_zm73.
  LOOP AT ft_zm73. "WHERE bobot NE 0.
    ADD 1 TO lv_count.
    IF lv_count = 1.
      IF ft_zm73-bobot <> 0.
        IF gv_lines = '01'.
          ft_zm73-%aloc = 100.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING ft_zm73 TO ls_zm73.
    ELSEIF lv_count LE 4.
*      gt_zm73-sdiff = ( 1 - gt_zm73-bobot / ls_zm73-bobot ) * 100.
      ft_zm73-sdiff = ls_zm73-bobot - ft_zm73-bobot.

      "Hitung Alokasi rank2 - 4
      LOOP AT gt_zmtnt_scor_aloc WHERE totsup = gv_lines.
        IF ft_zm73-sdiff LE gt_zmtnt_scor_aloc-scordiff.
          CASE lv_count.
            WHEN 2.
              ft_zm73-%aloc = gt_zmtnt_scor_aloc-rank2.
              ADD ft_zm73-%aloc TO lv_%aloctot.
              IF ft_zm73-sdiff < 3.
                lv_diff = 2.
              ENDIF.
              EXIT.
            WHEN 3.
              ft_zm73-%aloc = gt_zmtnt_scor_aloc-rank3.
              ADD ft_zm73-%aloc TO lv_%aloctot.
              IF ft_zm73-sdiff < 3.
                lv_diff = 3.
              ENDIF.
              EXIT.
            WHEN 4.
              ft_zm73-%aloc = gt_zmtnt_scor_aloc-rank4.
              ADD ft_zm73-%aloc TO lv_%aloctot.
              IF ft_zm73-sdiff < 3.
                lv_diff = 4.
              ENDIF.
              EXIT.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    MODIFY ft_zm73 TRANSPORTING sdiff %aloc.
  ENDLOOP.

* Hitung Alokasi3 rank1
  READ TABLE ft_zm73 ASSIGNING <ft_zm73> INDEX 1.
  IF sy-subrc = 0.
    IF lv_%aloctot <> 0.
      <ft_zm73>-%aloc = 100 - lv_%aloctot.
    ENDIF.
  ENDIF.

  IF lv_diff IS NOT INITIAL.
    PERFORM f_calculate_under3% TABLES ft_zm73
                                USING  lv_diff.
  ENDIF.
ENDFORM.                    " F_GET_FROM_ZM73N

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_RANKING
*&---------------------------------------------------------------------*
FORM f_hitung_ranking .

ENDFORM.                    " F_HITUNG_RANKING

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ENTRY
*&---------------------------------------------------------------------*
FORM f_screen_entry .

  PERFORM f_prepare_lampiran.
  PERFORM f_prepare_data.

  CASE 'X'.
    WHEN p_old.
      CALL SCREEN 201.
    WHEN p_new.
      CALL SCREEN 202.
  ENDCASE.
ENDFORM.                    " F_SCREEN_ENTRY

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode  TYPE TABLE OF sy-ucomm.
*  sy-lsind = 0.

  CASE 'X'.
    WHEN p_old.
      SET TITLEBAR 'TITLE_OLD'.
    WHEN p_new.
      SET TITLEBAR 'TITLE_NEW'.
  ENDCASE.
  SET PF-STATUS 'PF_STATUS'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_code    TYPE sy-ucomm.

  lv_code = ok_code.
  CLEAR ok_code.

  CASE lv_code.
    WHEN 'SAVE'.
      IF gv_lifnr IS NOT INITIAL.
        CASE sy-dynnr.
          WHEN '0201'.
            PERFORM f_prepare_save_data USING lv_code.
            PERFORM f_print_form USING lv_code '' ''.
          WHEN '0202'.
            PERFORM f_prepare_save_data USING lv_code.
            PERFORM f_save_data USING lv_code.
        ENDCASE.
      ENDIF.
    WHEN 'PREV'.
      IF gv_lifnr IS NOT INITIAL.
        CASE sy-dynnr.
          WHEN '0201'.
            PERFORM f_prepare_save_data USING lv_code.
            PERFORM f_print_form USING lv_code '' ''.
          WHEN '0202'.
*            PERFORM f_prepare_save_data USING lv_code.
            DELETE gt_heads WHERE count <= 1.
            IF so_ebeln[] IS INITIAL.
              PERFORM f_print_form USING lv_code 'X' ''.
              PERFORM f_print_pr USING lv_code '' 'X'.
            ELSEIF gt_heads[] IS INITIAL.
              PERFORM f_print_form USING lv_code 'X' ''.
              PERFORM f_print_pr USING lv_code '' 'X'.
            ELSE.
              PERFORM f_print_form USING lv_code 'X' ''.
              PERFORM f_print_pr USING lv_code 'X' 'X'.
              PERFORM f_print_lampiran USING lv_code '' 'X'.
            ENDIF.
*            PERFORM f_save_data.
        ENDCASE.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_process_before_output.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  DATA : ls_suppl  LIKE LINE OF gt_suppl,
         lv_nou(5).

  CASE sy-dynnr.
    WHEN '0201'.
      CLEAR : gs_suppl.
      IF gv_lifnr IS INITIAL.
        READ TABLE t_supplier INDEX 1.
        IF sy-subrc = 0.
          gv_lifnr = t_supplier-lifnr1.
          gv_name1 = t_supplier-name11.
        ENDIF.
      ENDIF.

      CLEAR : gt_suppl[].
      LOOP AT gt_xsuppl INTO ls_suppl
                        WHERE lifnr = gv_lifnr.
*        ADD 1 TO lv_nou.
*        ls_suppl-nou = lv_nou.
        SHIFT ls_suppl-nou LEFT DELETING LEADING '0'.
        APPEND ls_suppl TO gt_suppl.
        CLEAR ls_suppl.
      ENDLOOP.
      DESCRIBE TABLE gt_suppl LINES fill.
      tc_201-lines = fill.

    WHEN '0202'.
      CLEAR : gs_suppl.
      IF gv_lifnr IS INITIAL.
        READ TABLE t_supplier INDEX 1.
        IF sy-subrc = 0.
          gv_lifnr = t_supplier-lifnr1.
          gv_name1 = t_supplier-name11.
        ENDIF.
      ENDIF.

      CLEAR : gt_suppl[].
      LOOP AT gt_xsuppl INTO ls_suppl
                        WHERE lifnr = gv_lifnr.
*        ADD 1 TO lv_nou.
*        ls_suppl-zeile = lv_nou.
        SHIFT ls_suppl-nou LEFT DELETING LEADING '0'.
        CONDENSE ls_suppl-nou NO-GAPS.
        APPEND ls_suppl TO gt_suppl.
        CLEAR ls_suppl.
      ENDLOOP.
      DESCRIBE TABLE gt_suppl LINES fill.
      tc_202-lines = fill.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Module  F_SUPPLIER_LIST  INPUT
*&---------------------------------------------------------------------*
MODULE f_supplier_list INPUT.
*  PERFORM f_supplier_list.
  PERFORM f_clear.
  PERFORM f_modify_tc.
  PERFORM f_supplier_list_f4.

ENDMODULE.                 " F_SUPPLIER_LIST  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SUPPLIER_LIST
*&---------------------------------------------------------------------*
FORM f_supplier_list .
  TYPES : BEGIN OF ty_suppl,
            supplier(60),
          END OF ty_suppl.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         ls_return  LIKE LINE OF return_tab,
         lt_mara    LIKE t_mara OCCURS 0,
         ls_mara    LIKE LINE OF lt_mara,
         lt_suppl   TYPE STANDARD TABLE OF ty_suppl,
         ls_suppl   LIKE LINE OF lt_suppl,
         lt_value   TYPE vrm_values,
         ls_value   TYPE vrm_value,
         lv_subrc   TYPE sy-subrc.

  lt_mara[] = t_mara[].
  SORT lt_mara BY mfrnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING mfrnr.

  LOOP AT gt_zm73.
    READ TABLE lt_mara INTO ls_mara
                       WITH KEY mfrnr = gt_zm73-lifnr.
    IF sy-subrc = 0.
      ls_value-key  = ls_mara-mfrnr.
      ls_value-text = ls_mara-name1.
      APPEND ls_value TO lt_value.

    ENDIF.
    CLEAR ls_value.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'GV_SUPPLIER'
      values          = lt_value
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
ENDFORM.                    " F_SUPPLIER_LIST

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  PERFORM f_fill_table_control.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  DATA : lv_tabix TYPE sy-tabix,
         ls_004   LIKE LINE OF gt_004,
         lv_subrc TYPE sy-subrc.

  CASE 'X'.
    WHEN p_old.
      lv_tabix  = tc_201-current_line.
    WHEN p_new.
      lv_tabix  = tc_202-current_line.
  ENDCASE.

  IF gv_lifnr IS NOT INITIAL.
    READ TABLE gt_suppl INTO gs_suppl
                        WITH KEY zeile = lv_tabix.
    IF sy-subrc = 0.
      CLEAR ls_004.
      READ TABLE gt_004 INTO ls_004
                        WITH KEY zeile = lv_tabix.
      IF sy-subrc = 0.
        PERFORM f_screen_modify USING ls_004-zinput.
        LOOP AT SCREEN.
          IF screen-name = 'GS_SUPPL-ZEILE'.
            screen-invisible = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FILL_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  DATA : lv_zeile TYPE mseg-zeile,
         ls_suppl LIKE LINE OF gt_suppl,
         lv_top   TYPE i.

  CASE 'X'.
    WHEN p_old.
      lv_zeile  = tc_201-current_line.
      lv_top    = tc_201-top_line.
    WHEN p_new.
      lv_zeile  = tc_202-current_line.
      lv_top    = tc_202-top_line.
  ENDCASE.

*  lv_zeile = lv_zeile + lv_top - 1.
*  READ TABLE gt_suppl INTO ls_suppl INDEX lv_zeile.
*  lv_zeile  = ls_suppl-zeile.

  MODIFY gt_xsuppl FROM gs_suppl TRANSPORTING value
                                 WHERE lifnr = gv_lifnr
                                   AND zeile = gs_suppl-zeile.
ENDFORM.                    " F_READ_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_process_after_input.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_AFTER_INPUT
*&---------------------------------------------------------------------*
FORM f_process_after_input .

ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_MODIFY
*&---------------------------------------------------------------------*
FORM f_screen_modify  USING    fu_input.
  LOOP AT SCREEN.
    IF screen-name = 'GS_SUPPL-VALUE'.
      screen-input  = fu_input.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_SCREEN_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUE
*&---------------------------------------------------------------------*
FORM f_get_value  USING    fu_lifnr fu_field
                  CHANGING fc_value.
  DATA : lv_datum     TYPE sy-datum,
         lv_tmeng(20),
         lv_tmein(5).

  DATA : ls_heads   LIKE LINE OF gt_heads.

  READ TABLE t_supplier WITH KEY lifnr1 = fu_lifnr.
  IF sy-subrc = 0.
    CASE fu_field.
      WHEN 'KBETR'.
        PERFORM f_kbetr_calc USING '1' fu_field 'KONWA' 'KPEIN' 'KMEIN'
                             CHANGING fc_value.

      WHEN 'MENGE'.
        PERFORM f_menge_calc USING '1' fu_field 'MEINS'
                             CHANGING fc_value.

      WHEN 'DATAB'.
        PERFORM f_dyn_field USING fu_field '1'
                            CHANGING lv_datum.
        WRITE lv_datum TO fc_value DD/MM/YYYY.

      WHEN 'EBELN'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-ebeln.
        ELSE.
          IF so_ebeln[] IS NOT INITIAL AND
            ls_heads-count > 1.
            fc_value = 'Lihat lampiran'.
          ENDIF.
        ENDIF.

      WHEN 'TOTAL'.
        PERFORM f_menge_calc USING '1' fu_field 'MEINS'
                             CHANGING fc_value.

      WHEN 'PO_MENGE'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-totalt.
        ENDIF.

      WHEN 'PO_EINDT'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          WRITE ls_heads-eindt TO fc_value DD/MM/YYYY.
          CONDENSE fc_value NO-GAPS.
        ENDIF.

      WHEN 'LASTPUR'.
        PERFORM f_get_last_purchased USING fu_lifnr 'D'
                                     CHANGING fc_value.

      WHEN 'PRICE'.
        PERFORM f_get_last_purchased USING fu_lifnr 'P'
                                     CHANGING fc_value.

      WHEN OTHERS.
        PERFORM f_dyn_field USING fu_field '1'
                            CHANGING fc_value.
        SHIFT fc_value LEFT DELETING LEADING space.
    ENDCASE.
  ENDIF.

  READ TABLE t_supplier WITH KEY lifnr2 = fu_lifnr.
  IF sy-subrc = 0.
    CASE fu_field.
      WHEN 'KBETR'.
        PERFORM f_kbetr_calc USING '2' fu_field 'KONWA' 'KPEIN' 'KMEIN'
                             CHANGING fc_value.
      WHEN 'MENGE'.
        PERFORM f_menge_calc USING '2' fu_field 'MEINS'
                             CHANGING fc_value.
      WHEN 'DATAB'.
        PERFORM f_dyn_field USING fu_field '2'
                            CHANGING lv_datum.
        WRITE lv_datum TO fc_value DD/MM/YYYY.

      WHEN 'TOTAL'.
        PERFORM f_menge_calc USING '2' fu_field 'MEINS'
                             CHANGING fc_value.

      WHEN 'EBELN'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-ebeln.
        ELSE.
          IF so_ebeln[] IS NOT INITIAL AND
            ls_heads-count > 1.
            fc_value = 'Lihat lampiran'.
          ENDIF.
        ENDIF.

      WHEN 'PO_MENGE'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-totalt.
        ENDIF.

      WHEN 'PO_EINDT'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          WRITE ls_heads-eindt TO fc_value DD/MM/YYYY.
          CONDENSE fc_value NO-GAPS.
        ENDIF.

      WHEN 'LASTPUR'.
        PERFORM f_get_last_purchased USING fu_lifnr 'D'
                                     CHANGING fc_value.

      WHEN 'PRICE'.
        PERFORM f_get_last_purchased USING fu_lifnr 'P'
                                     CHANGING fc_value.

      WHEN OTHERS.
        PERFORM f_dyn_field USING fu_field '2'
                            CHANGING fc_value.
        SHIFT fc_value LEFT DELETING LEADING space.
    ENDCASE.
  ENDIF.

  READ TABLE t_supplier WITH KEY lifnr3 = fu_lifnr.
  IF sy-subrc = 0.
    CASE fu_field.
      WHEN 'KBETR'.
        PERFORM f_kbetr_calc USING '3' fu_field 'KONWA' 'KPEIN' 'KMEIN'
                             CHANGING fc_value.
      WHEN 'MENGE'.
        PERFORM f_menge_calc USING '3' fu_field 'MEINS'
                             CHANGING fc_value.
      WHEN 'DATAB'.
        PERFORM f_dyn_field USING fu_field '3'
                            CHANGING lv_datum.
        WRITE lv_datum TO fc_value DD/MM/YYYY.

      WHEN 'TOTAL'.
        PERFORM f_menge_calc USING '3' fu_field 'MEINS'
                             CHANGING fc_value.

      WHEN 'EBELN'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-ebeln.
        ELSE.
          IF so_ebeln[] IS NOT INITIAL AND
            ls_heads-count > 1.
            fc_value = 'Lihat lampiran'.
          ENDIF.
        ENDIF.

      WHEN 'PO_MENGE'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          fc_value = ls_heads-totalt.
        ENDIF.

      WHEN 'PO_EINDT'.
        CLEAR ls_heads.
        READ TABLE gt_heads INTO ls_heads
                            WITH KEY lifnr = fu_lifnr.
        IF ls_heads-count = 1.
          WRITE ls_heads-eindt TO fc_value DD/MM/YYYY.
          CONDENSE fc_value NO-GAPS.
        ENDIF.

      WHEN 'LASTPUR'.
        PERFORM f_get_last_purchased USING fu_lifnr 'D'
                                     CHANGING fc_value.

      WHEN 'PRICE'.
        PERFORM f_get_last_purchased USING fu_lifnr 'P'
                                     CHANGING fc_value.

      WHEN OTHERS.
        PERFORM f_dyn_field USING fu_field '3'
                            CHANGING fc_value.
        SHIFT fc_value LEFT DELETING LEADING space.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_KBETR_CALC
*&---------------------------------------------------------------------*
FORM f_kbetr_calc  USING    fu_count fu_kbetr fu_konwa fu_kpein fu_kmein
                   CHANGING fc_value.

  DATA : lv_kbetr(50),
         lv_kpein(15),
         lv_kmein   TYPE konp-kmein.

  PERFORM f_conv_currency USING fu_count fu_kbetr fu_konwa
                          CHANGING lv_kbetr.
  fc_value = lv_kbetr.

  PERFORM f_dyn_field USING fu_kpein fu_count
                      CHANGING lv_kpein.
  PERFORM f_dyn_field USING fu_kmein fu_count
                      CHANGING lv_kmein.

  SHIFT lv_kpein LEFT DELETING LEADING space.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = lv_kmein
    IMPORTING
      output         = lv_kmein
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  CONCATENATE '( /' lv_kpein lv_kmein ')' INTO fc_value.
  CONCATENATE lv_kbetr fc_value INTO fc_value
  SEPARATED BY space.
ENDFORM.                    " F_KBETR_CALC

*&---------------------------------------------------------------------*
*&      Form  F_CONV_CURRENCY
*&---------------------------------------------------------------------*
FORM f_conv_currency  USING    fu_count fu_kbetr fu_konwa
                      CHANGING fc_value.
  DATA : lv_kbetr TYPE konp-kbetr,
         lv_konwa TYPE konp-konwa.

  PERFORM f_dyn_field USING fu_kbetr fu_count
                      CHANGING lv_kbetr.

  PERFORM f_dyn_field USING fu_konwa fu_count
                      CHANGING lv_konwa.

  WRITE lv_kbetr TO fc_value CURRENCY lv_konwa.
  SHIFT fc_value LEFT DELETING LEADING space.
  CONCATENATE lv_konwa fc_value INTO fc_value
    SEPARATED BY space.
ENDFORM.                    " F_CONV_CURRENCY

*&---------------------------------------------------------------------*
*&      Form  F_DYN_FIELD
*&---------------------------------------------------------------------*
FORM f_dyn_field  USING    fu_value fu_count
                  CHANGING fc_value.
  DATA : lv_field(50).
  FIELD-SYMBOLS : <fs>  TYPE any.

  CONCATENATE 'T_SUPPLIER-' fu_value fu_count INTO lv_field.
  ASSIGN (lv_field) TO <fs>.
  IF <fs> IS ASSIGNED.
    fc_value = <fs>.
  ENDIF.
ENDFORM.                    " F_DYN_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_MENGE_CALC
*&---------------------------------------------------------------------*
FORM f_menge_calc  USING    fu_count fu_menge fu_meins
                   CHANGING fc_value.

  DATA : lv_menge TYPE eket-menge,
         lv_meins TYPE mara-meins.

  PERFORM f_dyn_field USING fu_menge fu_count
                      CHANGING lv_menge.
  PERFORM f_dyn_field USING fu_meins fu_count
                      CHANGING lv_meins.

  WRITE lv_menge TO fc_value UNIT lv_meins.
  SHIFT fc_value LEFT DELETING LEADING space.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = lv_meins
    IMPORTING
      output         = lv_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  CONCATENATE fc_value lv_meins INTO fc_value
  SEPARATED BY space.
ENDFORM.                    " F_MENGE_CALC

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

  CLEAR : dynpfields[], dynpfields.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_SUPPLIER_LIST_F4
*&---------------------------------------------------------------------*
FORM f_supplier_list_f4 .
  TYPES : BEGIN OF ty_suppl,
            lifnr TYPE lfa1-lifnr,
            name1 TYPE lfa1-name1,
          END OF ty_suppl.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         ls_return  LIKE LINE OF return_tab,
         lt_mara    LIKE t_mara OCCURS 0,
         ls_mara    LIKE LINE OF lt_mara,
         lt_eina    LIKE t_eina OCCURS 0,
         ls_eina    LIKE LINE OF lt_eina,
         lt_suppl   TYPE STANDARD TABLE OF ty_suppl,
         ls_suppl   LIKE LINE OF lt_suppl,
         ls_xsuppl  LIKE LINE OF gt_xsuppl,
         lv_lifnr   TYPE lfa1-lifnr,
         lv_top     TYPE i,
         lv_zeile   TYPE i.

  CASE 'X'.
    WHEN p_old.
      lv_top = tc_202-top_line.
    WHEN p_new.
      lv_top = tc_202-top_line.
  ENDCASE.

  lt_mara[] = t_mara[].
  SORT lt_mara BY mfrnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING mfrnr.

  lt_eina[] = t_eina[].
  SORT lt_eina BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_eina COMPARING lifnr.

  LOOP AT gt_zm73.
    READ TABLE lt_mara INTO ls_mara
                       WITH KEY mfrnr = gt_zm73-lifnr.
    IF sy-subrc = 0.
      ls_suppl-lifnr = ls_mara-mfrnr.
      ls_suppl-name1 = ls_mara-name1.
      APPEND ls_suppl TO lt_suppl.
    ELSE.
      READ TABLE lt_eina INTO ls_eina
                      WITH KEY lifnr = gt_zm73-lifnr.
      IF sy-subrc = 0.
        ls_suppl-lifnr = ls_eina-lifnr.
        ls_suppl-name1 = ls_eina-name1.
        APPEND ls_suppl TO lt_suppl.
      ENDIF.
    ENDIF.
    CLEAR ls_suppl.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'LIFNR'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'GV_SUPPLIER'
      value_org   = 'S'
    TABLES
      value_tab   = lt_suppl
      return_tab  = return_tab.

  READ TABLE return_tab INTO ls_return INDEX 1.
  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_return-fieldval
      IMPORTING
        output = lv_lifnr.

    CLEAR ls_suppl.
    READ TABLE lt_suppl INTO ls_suppl
                        WITH KEY lifnr = lv_lifnr.
    IF sy-subrc = 0.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GV_LIFNR'
                                ls_suppl-lifnr '' ''.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GV_NAME1'
                                ls_suppl-name1 '' ''.

      CLEAR : gt_suppl[].
      LOOP AT gt_xsuppl INTO ls_xsuppl
                        WHERE lifnr = lv_lifnr.
        SHIFT ls_xsuppl-nou LEFT DELETING LEADING '0'.

        APPEND ls_xsuppl TO gt_suppl.
        CLEAR ls_xsuppl.
      ENDLOOP.

      CLEAR ls_xsuppl.
      LOOP AT gt_suppl INTO ls_xsuppl FROM lv_top.
        ADD 1 TO lv_zeile.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_SUPPL-NOU'
                                  ls_xsuppl-nou '' lv_zeile. "ls_xsuppl-zeile.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_SUPPL-DESCRIPTION'
                                  ls_xsuppl-description '' lv_zeile. "ls_xsuppl-zeile.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_SUPPL-VALUE'
                                  ls_xsuppl-value '' lv_zeile. "ls_xsuppl-zeile.
        CLEAR ls_xsuppl.
      ENDLOOP.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_SUPPLIER_LIST_F4

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers fu_stepl.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  ls_dynpfields-stepl  = fu_stepl.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ls_mara      LIKE LINE OF t_mara,
         ls_suppl     LIKE LINE OF gt_suppl,
         ls_004       LIKE LINE OF gt_004,
         lv_quart,
         lv_q1,
         lv_q2,
         lv_q3,
         lv_q4,
         lv_semester,
         lv_qcode(10).

  CLEAR : gt_xsuppl[].

  LOOP AT gt_zm73.
*    READ TABLE t_mara INTO ls_mara
*                      WITH KEY mfrnr = gt_zm73-lifnr.
*    IF sy-subrc = 0.
    LOOP AT gt_004 INTO ls_004.
      ls_suppl-lifnr        = gt_zm73-lifnr. "ls_mara-mfrnr.
      ls_suppl-zeile        = ls_004-zeile.
      ls_suppl-nou          = ls_004-nou.
      ls_suppl-description  = ls_004-description.
      ls_suppl-zend         = ls_004-zend.

      CASE 'X'.
        WHEN p_q1.
          lv_qcode = 'p_q1'.
        WHEN p_q2.
          lv_qcode = 'p_q2'.
        WHEN p_q3.
          lv_qcode = 'p_q3'.
        WHEN p_q4.
          lv_qcode = 'p_q4'.
      ENDCASE.

      PERFORM f_replace_code USING lv_qcode ls_004-period ls_004-zgroup1 pa_mjahr
                             CHANGING ls_suppl-description.

      IF ls_004-field IS NOT INITIAL.
        PERFORM f_get_value USING ls_suppl-lifnr ls_004-field
                            CHANGING ls_suppl-value.
      ENDIF.

      APPEND ls_suppl TO gt_xsuppl.
      CLEAR ls_suppl.
    ENDLOOP.
    CLEAR ls_suppl.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDGET_PRICE
*&---------------------------------------------------------------------*
FORM f_get_budget_price  USING    fu_matnr
                         CHANGING fc_konwa fc_budget.

  DATA : lt_a049 TYPE STANDARD TABLE OF a049,
         lt_a501 TYPE STANDARD TABLE OF a501,
         lt_k049 TYPE STANDARD TABLE OF konp,
         lt_k501 TYPE STANDARD TABLE OF konp,
         ls_a501 LIKE LINE OF lt_a501,
         ls_a049 LIKE LINE OF lt_a049,
         ls_k501 LIKE LINE OF lt_k501,
         ls_k049 LIKE LINE OF lt_k501.

  DATA : lv_budget    LIKE konp-kbetr,
         lv_datbi     TYPE sy-datum,
         lv_datab     TYPE sy-datum,
         lv_kpein(20).

  CASE 'X'.
    WHEN p_q1.
      CONCATENATE pa_mjahr '0101' INTO lv_datbi.
      CONCATENATE pa_mjahr '0630' INTO lv_datab.
    WHEN p_q2.
      CONCATENATE pa_mjahr '0101' INTO lv_datbi.
      CONCATENATE pa_mjahr '0630' INTO lv_datab.
    WHEN p_q3.
      CONCATENATE pa_mjahr '0701' INTO lv_datbi.
      CONCATENATE pa_mjahr '1231' INTO lv_datab.
    WHEN p_q4.
      CONCATENATE pa_mjahr '0701' INTO lv_datbi.
      CONCATENATE pa_mjahr '1231' INTO lv_datab.
  ENDCASE.

  SELECT matnr knumh
    FROM a049
    INTO CORRESPONDING FIELDS OF TABLE lt_a049
    WHERE kappl = 'M'
      AND kschl = 'ZBGT'
      AND ekorg = 'TNT'
      AND esokz = '0'
      AND matnr = fu_matnr
      AND datbi >= lv_datbi
      AND datab <= lv_datab.

  IF lt_a049[] IS NOT INITIAL.
    SELECT knumh kbetr kpein konwa kmein
      FROM konp
      INTO CORRESPONDING FIELDS OF TABLE lt_k049
      FOR ALL ENTRIES IN lt_a049
      WHERE knumh = lt_a049-knumh
        AND kopos EQ '1'
        AND loevm_ko EQ space.
  ENDIF.

  SELECT matnr inco1 knumh
    FROM a501
    INTO CORRESPONDING FIELDS OF TABLE lt_a501
    WHERE kappl = 'M'
      AND kschl = 'ZBGT'
      AND ekorg = 'TNT'
      AND esokz = '0'
      AND matnr = fu_matnr
      AND datbi >= lv_datbi
      AND datab <= lv_datab.

  IF lt_a501[] IS NOT INITIAL.
    SELECT knumh kbetr kpein konwa kmein
      FROM konp
      INTO CORRESPONDING FIELDS OF TABLE lt_k501
      FOR ALL ENTRIES IN lt_a501
      WHERE knumh EQ lt_a501-knumh
        AND kopos EQ '1'
        AND loevm_ko EQ space.
  ENDIF.

  CLEAR ls_a501.
*  READ TABLE lt_a501 INTO ls_a501
*                     WITH KEY matnr = fu_matnr.
*  IF sy-subrc EQ 0.
  LOOP AT lt_a501 INTO ls_a501 WHERE matnr = fu_matnr.
    CLEAR ls_k501.
    READ TABLE lt_k501 INTO ls_k501
                       WITH KEY knumh = ls_a501-knumh.
    IF sy-subrc = 0.
      PERFORM f_amount_calc USING ls_k501-kbetr ls_k501-kpein ls_k501-konwa
                                  ls_k501-kmein
                              CHANGING lv_budget lv_kpein.
*      lv_budget = ls_k501-kbetr / ls_k501-kpein.
      fc_konwa  = ls_k501-konwa.
      EXIT.
    ENDIF.
  ENDLOOP.
*  ELSE.
  IF fc_konwa IS INITIAL.
    CLEAR ls_a049.
*    READ TABLE lt_a049 INTO ls_a049
*                       WITH KEY matnr = fu_matnr.
*  IF sy-subrc EQ 0.
    LOOP AT lt_a049 INTO ls_a049 WHERE matnr = fu_matnr.
      CLEAR ls_k049.
      READ TABLE lt_k049 INTO ls_k049
                         WITH KEY knumh = ls_a049-knumh.
      IF sy-subrc = 0.
        PERFORM f_amount_calc USING ls_k049-kbetr ls_k049-kpein ls_k049-konwa
                                    ls_k049-kmein
                              CHANGING lv_budget lv_kpein.
*        lv_budget = ls_k049-kbetr / ls_k049-kpein.
        fc_konwa  = ls_k049-konwa.
        EXIT.
      ENDIF.
    ENDLOOP.
*  ENDIF.
*ENDIF.
  ENDIF.

  WRITE lv_budget TO fc_budget CURRENCY fc_konwa.
  CONDENSE fc_budget NO-GAPS.
  CONCATENATE fc_budget '/' lv_kpein INTO fc_budget
  SEPARATED BY space.
ENDFORM.                    " F_GET_BUDGET_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNT_CALC
*&---------------------------------------------------------------------*
FORM f_amount_calc  USING    fu_kbetr fu_kpein fu_konwa fu_kmein
                    CHANGING fc_budget fc_kpein.
  DATA : lv_currdec TYPE tcurx-currdec,
         lv_kbetr   TYPE p DECIMALS 2,
         lv_kmein   TYPE konp-kmein.

  SELECT SINGLE currdec
    FROM tcurx
    INTO lv_currdec
    WHERE currkey EQ fu_konwa.

  CASE lv_currdec.
    WHEN 0.
      lv_kbetr = fu_kbetr * 100.
    WHEN 3.
      lv_kbetr = fu_kbetr * 10.
    WHEN OTHERS.
      lv_kbetr = fu_kbetr.
  ENDCASE.

  fc_budget = fu_kbetr. "/ fu_kpein.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_kmein
    IMPORTING
      output         = lv_kmein
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  WRITE fu_kpein TO fc_kpein UNIT fu_kmein.
  CONDENSE fc_kpein NO-GAPS.
  CONCATENATE fc_kpein lv_kmein INTO fc_kpein
  SEPARATED BY space.
ENDFORM.                    " F_AMOUNT_CALC

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SUPPLIER_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_supplier_data  TABLES   ft_nsupl STRUCTURE zgdmmst0055
                              USING    fu_lifnr1 fu_lifnr2 fu_lifnr3.

  FIELD-SYMBOLS <fs_suppl>  TYPE zgdmmst0055.

  DATA : ls_xsuppl LIKE LINE OF gt_xsuppl,
         ls_nsupl  TYPE zgdmmst0055,
         lv_zeile  TYPE zgdmmst002x-zeile.

  LOOP AT gt_xsuppl INTO ls_xsuppl.
    IF ls_xsuppl-lifnr = fu_lifnr1.
      ls_nsupl-zeile       = ls_xsuppl-zeile.
      ls_nsupl-nou         = ls_xsuppl-nou.
      ls_nsupl-keterangan  = ls_xsuppl-description.
      ls_nsupl-csupl1      = ls_xsuppl-value.
      ls_nsupl-zend        = ls_xsuppl-zend.
      APPEND ls_nsupl TO ft_nsupl.
    ENDIF.
    IF ls_xsuppl-lifnr = fu_lifnr2.
      ls_nsupl-csupl2      = ls_xsuppl-value.
      ls_nsupl-zend        = ls_xsuppl-zend.
      MODIFY ft_nsupl FROM ls_nsupl
                      TRANSPORTING csupl2 zend
                      WHERE zeile = ls_xsuppl-zeile.
    ENDIF.
    IF ls_xsuppl-lifnr = fu_lifnr3.
      ls_nsupl-csupl3      = ls_xsuppl-value.
      ls_nsupl-zend        = ls_xsuppl-zend.
      MODIFY ft_nsupl FROM ls_nsupl
                      TRANSPORTING csupl3 zend
                      WHERE zeile = ls_xsuppl-zeile.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_SUPPLIER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SEMESTER
*&---------------------------------------------------------------------*
FORM f_semester  USING    fu_lifnr fu_bobot fu_aloc
                 CHANGING fc_bobot1 fc_aloc1 fc_aloc2 fc_aloc3 fc_aloc4.
  DATA : ls_zm73   LIKE LINE OF gt_zm73,
         lv_bobot1 TYPE zbobottop,
         lv_bobot2 TYPE zbobottop,
         lv_bobot3 TYPE zbobottop,
         lv_bobot4 TYPE zbobottop.

  lv_bobot1 = fu_bobot.
  fc_aloc1  = fu_aloc.

  CLEAR ls_zm73.
  READ TABLE gt_zm732 INTO ls_zm73
                      WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    lv_bobot2 = ls_zm73-bobot.
    fc_aloc2  = ls_zm73-%aloc.
  ENDIF.

  CLEAR ls_zm73.
  READ TABLE gt_zm733 INTO ls_zm73
                      WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    lv_bobot3 = ls_zm73-bobot.
    fc_aloc3  = ls_zm73-%aloc.
  ENDIF.

  CLEAR ls_zm73.
  READ TABLE gt_zm734 INTO ls_zm73
                      WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    lv_bobot4 = ls_zm73-bobot.
    fc_aloc4  = ls_zm73-%aloc.
  ENDIF.

  CASE 'X'.
    WHEN p_q1.
      fc_bobot1 = lv_bobot1.
    WHEN p_q2.
      fc_bobot1 = lv_bobot2.
    WHEN p_q3.
      fc_bobot1 = lv_bobot3.
    WHEN p_q4.
      fc_bobot1 = lv_bobot4.
  ENDCASE.
ENDFORM.                    " F_SEMESTER

*&---------------------------------------------------------------------*
*&      Form  F_ALOKASI_BUDGET
*&---------------------------------------------------------------------*
FORM f_alokasi_budget .
  DATA : lt_zm73  TYPE STANDARD TABLE OF ty_zm73,
         ls_zm73  LIKE LINE OF lt_zm73,
         lr_datum TYPE RANGE OF datum,
         ls_datum LIKE LINE OF lr_datum,
         lt_a968  TYPE STANDARD TABLE OF a968,
         ls_a968  LIKE LINE OF lt_a968,
         lt_konp  TYPE STANDARD TABLE OF konp,
         ls_konp  LIKE LINE OF lt_konp,
         ls_aloc  LIKE LINE OF gt_aloc.

  CASE 'X'.
    WHEN p_q1.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
    WHEN p_q2.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
    WHEN p_q3.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
    WHEN p_q4.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
  ENDCASE.

  lt_zm73[] = gt_zm73[].
  SORT lt_zm73 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_zm73 COMPARING lifnr.
  IF lt_zm73[] IS NOT INITIAL.
    SELECT *
      FROM a968
      INTO CORRESPONDING FIELDS OF TABLE lt_a968
      FOR ALL ENTRIES IN lt_zm73
      WHERE kappl = 'M'
        AND kschl = 'ZBGA'
        AND ekorg = 'TNT'
        AND lifnr = lt_zm73-lifnr
        AND matnr = pa_matnr
        AND datbi >= ls_datum-low
        AND datab <= ls_datum-high.

    IF lt_a968[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE lt_konp
        FOR ALL ENTRIES IN lt_a968
        WHERE knumh = lt_a968-knumh.
    ENDIF.
  ENDIF.

  LOOP AT lt_a968 INTO ls_a968.
    ls_aloc-lifnr   = ls_a968-lifnr.
    ls_aloc-datab   = ls_a968-datab.

    CLEAR : lr_datum[], ls_datum.
    ls_datum-low    = ls_a968-datab.
    ls_datum-high   = ls_a968-datbi.
    ls_datum-sign   = 'I'.
    ls_datum-option = 'BT'.
    APPEND ls_datum TO lr_datum.
    CLEAR ls_datum.

    CLEAR ls_konp.
    READ TABLE lt_konp INTO ls_konp
                       WITH KEY knumh = ls_a968-knumh.
    IF sy-subrc = 0.
      ls_aloc-kbetr = ls_konp-kbetr.
      ls_aloc-konwa = ls_konp-konwa.
      APPEND ls_aloc TO gt_aloc.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ALOKASI_BUDGET

*&---------------------------------------------------------------------*
*&      Form  F_ALLOC
*&---------------------------------------------------------------------*
FORM f_alloc  USING    fu_lifnr
              CHANGING fc_alos1% fc_alos2%.

  DATA : lv_datab TYPE sy-datum,
         ls_aloc  LIKE LINE OF gt_aloc,
         lv_aloc  TYPE p DECIMALS 0.

  CONCATENATE pa_mjahr '0630' INTO lv_datab.

  LOOP AT gt_aloc INTO ls_aloc WHERE lifnr = fu_lifnr.
    lv_aloc = ls_aloc-kbetr / 10.
    IF ls_aloc-datab <= lv_datab.
      fc_alos1% = lv_aloc.
    ELSE.
      fc_alos2% = lv_aloc.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ALLOC

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_UNDER3%
*&---------------------------------------------------------------------*
FORM f_calculate_under3%  TABLES   ft_zm73 STRUCTURE gt_zm73
                          USING    fu_diff.
  DATA : lv_count TYPE i,
         lv_%aloc TYPE zbobottop,
         lv_index TYPE i.

  lv_index  = 4.

  CASE fu_diff.
    WHEN 4.
      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = 100 / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
    WHEN 3.
      READ TABLE ft_zm73 INDEX lv_index.
      IF sy-subrc = 0.
        lv_%aloc  = ft_zm73-%aloc.
      ENDIF.
      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = ( 100 - lv_%aloc ) / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
    WHEN 2.
      DO 2 TIMES.
        READ TABLE ft_zm73 INDEX lv_index.
        IF sy-subrc = 0.
          ADD ft_zm73-%aloc TO lv_%aloc.
        ENDIF.
        lv_index = lv_index - 1.
      ENDDO.

      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = ( 100 - lv_%aloc ) / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALCULATE_UNDER3%

*&---------------------------------------------------------------------*
*&      Form  F_ACTALLOC
*&---------------------------------------------------------------------*
FORM f_actalloc  USING    fu_lifnr
                 CHANGING fc_actlk1 fc_actlk2 fc_actlk3 fc_actlk4.

  DATA : ls_ekko   LIKE LINE OF t_ekko,
         lv_menge1 TYPE ekpo-menge,
         lv_menge2 TYPE ekpo-menge,
         lv_menge3 TYPE ekpo-menge,
         lv_menge4 TYPE ekpo-menge,
         lv_menge5 TYPE ekpo-menge,
         lv_menge6 TYPE ekpo-menge,
         lv_menge7 TYPE ekpo-menge,
         lv_menge8 TYPE ekpo-menge,
         lr_datum  TYPE RANGE OF datum,
         ls_datum  LIKE LINE OF lr_datum,
         lr_1      TYPE RANGE OF datum,
         lr_2      TYPE RANGE OF datum,
         lr_3      TYPE RANGE OF datum,
         lr_4      TYPE RANGE OF datum.

  DATA : lv_meins TYPE ekpo-meins,
         lv_menge TYPE ekpo-menge.

  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.

*  CASE 'X'.
*    WHEN p_q1.
  CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0331' INTO ls_datum-high.
  APPEND ls_datum TO lr_1.
*    WHEN p_q2.
  CONCATENATE pa_mjahr '0401' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
  APPEND ls_datum TO lr_2.
*    WHEN p_q3.
  CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0930' INTO ls_datum-high.
  APPEND ls_datum TO lr_3.
*    WHEN p_q4.
  CONCATENATE pa_mjahr '1001' INTO ls_datum-low.
  CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
  APPEND ls_datum TO lr_4.
*  ENDCASE.

  CLEAR : fc_actlk1, fc_actlk2, fc_actlk3, fc_actlk4.

  CLEAR ls_ekko.
  READ TABLE t_ekko1 INTO ls_ekko INDEX 1.
  IF sy-subrc = 0.
    lv_meins    = ls_ekko-meins.
  ENDIF.

  CLEAR ls_ekko.
  LOOP AT t_ekko1 INTO ls_ekko.
    PERFORM f_material_conversion USING ls_ekko-menge ls_ekko-ematn
                                        ls_ekko-meins lv_meins 'X'
                                  CHANGING ls_ekko-menge.

    IF ls_ekko-bedat IN lr_1.
      IF ls_ekko-lifnr  = fu_lifnr.
        ADD ls_ekko-menge TO lv_menge1.
      ENDIF.
      ADD ls_ekko-menge TO lv_menge2.
    ENDIF.

    IF ls_ekko-bedat IN lr_2.
      IF ls_ekko-lifnr  = fu_lifnr.
        ADD ls_ekko-menge TO lv_menge3.
      ENDIF.
      ADD ls_ekko-menge TO lv_menge4.
    ENDIF.

    IF ls_ekko-bedat IN lr_3.
      IF ls_ekko-lifnr  = fu_lifnr.
        ADD ls_ekko-menge TO lv_menge5.
      ENDIF.
      ADD ls_ekko-menge TO lv_menge6.
    ENDIF.

    IF ls_ekko-bedat IN lr_4.
      IF ls_ekko-lifnr  = fu_lifnr.
        ADD ls_ekko-menge TO lv_menge7.
      ENDIF.
      ADD ls_ekko-menge TO lv_menge8.
    ENDIF.
  ENDLOOP.

  PERFORM f_devide_calculate USING lv_menge1 lv_menge2
                             CHANGING fc_actlk1.
  PERFORM f_devide_calculate USING lv_menge3 lv_menge4
                             CHANGING fc_actlk2.
  PERFORM f_devide_calculate USING lv_menge5 lv_menge6
                             CHANGING fc_actlk3.
  PERFORM f_devide_calculate USING lv_menge7 lv_menge8
                             CHANGING fc_actlk4.

ENDFORM.                    " F_ACTALLOC

*&---------------------------------------------------------------------*
*&      Form  F_PEMBAYARAN
*&---------------------------------------------------------------------*
FORM f_pembayaran USING fu_lifnr
                  CHANGING fc_top.
  DATA : lt_lfm1  TYPE STANDARD TABLE OF lfm1,
         ls_lfm1  LIKE LINE OF lt_lfm1,
         ls_t052u LIKE LINE OF gt_t052u.

  IF fu_lifnr IS INITIAL.
    SELECT *
      FROM lfm1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfm1
      WHERE lifnr IN ra_lifnr
        AND ekorg = 'TNT'.

    lt_lfm1[] = gt_lfm1[].
    SORT lt_lfm1 BY zterm.
    DELETE ADJACENT DUPLICATES FROM lt_lfm1 COMPARING zterm.
    IF lt_lfm1[] IS NOT INITIAL.
      SELECT *
        FROM t052u
        INTO CORRESPONDING FIELDS OF TABLE gt_t052u
        FOR ALL ENTRIES IN lt_lfm1
        WHERE spras = sy-langu
        AND   zterm = lt_lfm1-zterm.
    ENDIF.
  ELSE.
    READ TABLE gt_lfm1 INTO ls_lfm1
                       WITH KEY lifnr = fu_lifnr.
    IF sy-subrc = 0.
      READ TABLE gt_t052u INTO ls_t052u
                          WITH KEY zterm = ls_lfm1-zterm.
      IF sy-subrc = 0.
        CONCATENATE ls_t052u-zterm '-' ls_t052u-text1 INTO fc_top
        SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PEMBAYARAN

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR
*&---------------------------------------------------------------------*
FORM f_clear .
*  CASE 'X'.
*    WHEN p_old.
*      tc_201-top_line = 1.
*    WHEN p_new.
*      tc_202-top_line = 1.
*  ENDCASE.
ENDFORM.                    " F_CLEAR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TC
*&---------------------------------------------------------------------*
FORM f_modify_tc .
  DATA : ls_suppl      LIKE LINE OF gt_suppl,
         lv_lifnr      TYPE lfa1-lifnr,
         lv_top        TYPE i,
         lv_line       TYPE i,
         lv_value(100).

  CASE 'X'.
    WHEN p_old.
      lv_top = tc_201-top_line.
    WHEN p_new.
      lv_top = tc_202-top_line.
  ENDCASE.
*
*  PERFORM f_dynp_value_read USING 'GV_LIFNR' ''
*                            CHANGING lv_lifnr.
*
*  lv_line = 1.

  LOOP AT gt_suppl INTO ls_suppl FROM lv_top.
    ADD 1 TO lv_line.
    PERFORM f_dynp_value_read USING 'GS_SUPPL-VALUE' ls_suppl-value lv_line
                              CHANGING lv_value.
    ls_suppl-value = lv_value.
    MODIFY gt_xsuppl FROM ls_suppl TRANSPORTING value
                                   WHERE lifnr = ls_suppl-lifnr
                                     AND zeile = ls_suppl-zeile.
    CLEAR : ls_suppl, lv_value.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_TC

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname fu_value line
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  IF line IS NOT INITIAL.
    ls_dynpfields-stepl       = line.
  ENDIF.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        IF ls_dynpfields-stepl = line.
          fc_value  = ls_dynpfields-fieldvalue.
          EXIT.
*        ELSE.
*          fc_value  = ls_dynpfields-fieldvalue.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF fc_value IS INITIAL.
    fc_value  = fu_value.
  ENDIF.
ENDFORM.                    " F_DYNP_VALUE_READ

*&---------------------------------------------------------------------*
*&      Form  F_DEVIDE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_devide_calculate  USING    fu_menge1 fu_menge2
                         CHANGING fc_actlk.
  TRY .
      fc_actlk  = ( fu_menge1 / fu_menge2 ) * 100.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_DEVIDE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_CONVERSION
*&---------------------------------------------------------------------*
FORM f_material_conversion  USING    fu_input fu_matnr fu_meinh fu_meins
                                     fu_simple
                            CHANGING fc_output.

  DATA : lv_menge TYPE eket-menge,
         lv_umrez TYPE marm-umrez,
         lv_umren TYPE marm-umren.

  IF fu_simple IS INITIAL.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = fu_input
        matnr                = fu_matnr
        meinh                = fu_meinh
        meins                = fu_meins
      IMPORTING
        output               = lv_menge
        umrez                = lv_umrez
        umren                = lv_umren
      EXCEPTIONS
        conversion_not_found = 1
        input_invalid        = 2
        material_not_found   = 3
        meinh_not_found      = 4
        meins_missing        = 5
        no_meinh             = 6
        output_invalid       = 7
        overflow             = 8
        OTHERS               = 9.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = fu_input
        unit_in              = fu_meinh
        unit_out             = fu_meins
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
  ENDIF.

  IF sy-subrc = 0.
    fc_output = lv_menge. " * lv_umrez / lv_umren.
*   fc_output = fu_input.
  ENDIF.
ENDFORM.                    " F_MATERIAL_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ZM73
*&---------------------------------------------------------------------*
FORM f_add_zm73 .
  DATA : lt_xm73 LIKE gt_zm73 OCCURS 0,
         lt_zm73 LIKE gt_zm73 OCCURS 0,
         ls_zm73 LIKE LINE OF gt_zm73,
         ls_xm73 LIKE LINE OF gt_zm73,
         ls_73   LIKE LINE OF gt_zm73.

  CLEAR ls_zm73.
  LOOP AT gt_zm732 INTO ls_zm73.
    CLEAR ls_73.
    READ TABLE gt_zm73 INTO ls_73
                       WITH KEY lifnr = ls_zm73-lifnr.
    IF sy-subrc <> 0.
      ls_xm73-lifnr = ls_zm73-lifnr.
      APPEND ls_xm73 TO lt_xm73.
      CLEAR ls_xm73.
    ENDIF.
  ENDLOOP.

  CLEAR ls_zm73.
  LOOP AT gt_zm733 INTO ls_zm73.
    CLEAR ls_73.
    READ TABLE gt_zm73 INTO ls_73
                       WITH KEY lifnr = ls_zm73-lifnr.
    IF sy-subrc <> 0.
      ls_xm73-lifnr = ls_zm73-lifnr.
      APPEND ls_xm73 TO lt_xm73.
      CLEAR ls_xm73.
    ENDIF.
  ENDLOOP.

  CLEAR ls_zm73.
  LOOP AT gt_zm734 INTO ls_zm73.
    CLEAR ls_73.
    READ TABLE gt_zm73 INTO ls_73
                       WITH KEY lifnr = ls_zm73-lifnr.
    IF sy-subrc <> 0.
      ls_xm73-lifnr = ls_zm73-lifnr.
      APPEND ls_xm73 TO lt_xm73.
      CLEAR ls_xm73.
    ENDIF.
  ENDLOOP.

  SORT lt_xm73 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xm73 COMPARING lifnr.

  CLEAR : lt_zm73[].
  lt_zm73[] = gt_zm73[].
  LOOP AT lt_xm73 INTO ls_xm73.
    CLEAR ls_zm73.
    READ TABLE lt_zm73 INTO ls_zm73
                       WITH KEY lifnr = ls_xm73-lifnr.
    IF sy-subrc <> 0.
      ls_zm73-lifnr  = ls_xm73-lifnr.
      APPEND ls_zm73 TO gt_zm73.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ADD_ZM73

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_save_data USING fu_ucomm.
  CLEAR : gt_04a[], gt_04b[], gt_04c[].
  IF fu_ucomm = 'SAVE'.
    PERFORM f_get_next_number CHANGING t_header-zalno.
  ENDIF.
  PERFORM f_04a USING t_header-zalno.
  PERFORM f_04b USING t_header-zalno.
  PERFORM f_04c USING t_header-zalno.
  PERFORM f_04d USING t_header-zalno.
ENDFORM.                    " F_PREPARE_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_04A
*&---------------------------------------------------------------------*
FORM f_04a USING fu_zalno.
  DATA : ls_04a   LIKE LINE OF gt_04a.

  ls_04a-zalno    = fu_zalno.
  ls_04a-zaldt    = sy-datum.
  ls_04a-werks    = pa_werks.
  ls_04a-ekgrp    = pa_ekgrp.
  ls_04a-mjahr    = pa_mjahr.
  CASE 'X'.
    WHEN p_q1.
      ls_04a-quart = 'p_q1'.
    WHEN p_q2.
      ls_04a-quart = 'p_q2'.
    WHEN p_q3.
      ls_04a-quart = 'p_q3'.
    WHEN p_q4.
      ls_04a-quart = 'p_q4'.
  ENDCASE.
  ls_04a-matnr    = t_header-matnr.
  ls_04a-maktx    = t_header-maktx.
  ls_04a-konwa    = t_header-konwa.
  ls_04a-budget   = t_header-budget.
  ls_04a-datlb    = t_header-datlb.
  ls_04a-waers    = t_header-waers.
  ls_04a-meins    = t_header-meins.
  ls_04a-netprt   = t_header-netprt.
  ls_04a-menget   = t_header-menget.
  ls_04a-name1    = t_header-name1.
  APPEND ls_04a TO gt_04a.
ENDFORM.                    " F_04A

*&---------------------------------------------------------------------*
*&      Form  F_04B
*&---------------------------------------------------------------------*
FORM f_04b USING fu_zalno.
  DATA : ls_04b    LIKE LINE OF gt_04b,
         ls_detail LIKE LINE OF t_detail.

  LOOP AT t_detail INTO ls_detail.
    ls_04b-zalno    = fu_zalno.
    ls_04b-banfn    = ls_detail-banfn.
    ls_04b-frgdt    = ls_detail-frgdt.
    ls_04b-menge    = ls_detail-menge.
    ls_04b-bsmng    = ls_detail-bsmng.
    ls_04b-meins    = ls_detail-meins.
    ls_04b-lfdat    = ls_detail-lfdat.
    APPEND ls_04b TO gt_04b.
    CLEAR ls_04b.
  ENDLOOP.
ENDFORM.                    " F_04B

*&---------------------------------------------------------------------*
*&      Form  F_04C
*&---------------------------------------------------------------------*
FORM f_04c USING fu_zalno.
  DATA : ls_04c    LIKE LINE OF gt_04c,
         ls_xsuppl LIKE LINE OF gt_xsuppl,
         ls_004    LIKE LINE OF gt_004,
         lv_posnr  TYPE zgdmmt004c-posnr.

  LOOP AT gt_xsuppl INTO ls_xsuppl.
    ls_04c-zalno        = fu_zalno.
    ls_04c-lifnr        = ls_xsuppl-lifnr.
    CLEAR ls_004.
    READ TABLE gt_004 INTO ls_004
                      WITH KEY zeile = ls_xsuppl-zeile.
    IF sy-subrc = 0.
      ls_04c-zeile        = ls_004-xeile.
    ENDIF.
    IF ls_04c-zeile = 1.
      ADD 1 TO lv_posnr.
    ENDIF.
    ls_04c-posnr        = lv_posnr.
    ls_04c-value        = ls_xsuppl-value.
    APPEND ls_04c TO gt_04c.
    CLEAR ls_04c.
  ENDLOOP.
ENDFORM.                    " F_04C

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_menge fu_bsmng fu_matnr fu_meins
                   CHANGING fc_menge.

  DATA : lv_menge   TYPE mseg-menge.

  lv_menge = fu_menge - fu_bsmng.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = lv_menge
      matnr                = fu_matnr
      meinh                = t_header-meins
      meins                = fu_meins
    IMPORTING
      output               = lv_menge
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

  IF sy-subrc = 0.
    WRITE lv_menge TO fc_menge DECIMALS 3.
  ENDIF.
ENDFORM.                    " F_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data USING  fu_ucomm.
  DATA : oref            TYPE REF TO cx_root,
         lv_message(100),
         no_close        TYPE tdsfflag,
         no_open         TYPE tdsfflag,
         lv_count        TYPE i.

  TRY .
      INSERT zgdmmt004a FROM TABLE gt_04a.
    CATCH cx_sy_open_sql_db INTO oref.
      lv_message = oref->get_text( ).
  ENDTRY.

  IF lv_message IS INITIAL.
    TRY .
        INSERT zgdmmt004b FROM TABLE gt_04b.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.

  IF lv_message IS INITIAL.
    TRY .
        INSERT zgdmmt004c FROM TABLE gt_04c.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.

  IF lv_message IS INITIAL.
    TRY .
        INSERT zgdmmt004d FROM TABLE gt_04d.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.

  IF lv_message IS INITIAL.
    COMMIT WORK AND WAIT.
    CONCATENATE 'Allocation number' t_header-zalno INTO lv_message
    SEPARATED BY space.
    MESSAGE s000(zab) WITH lv_message.

    DELETE gt_heads WHERE count <= 1.

    IF so_ebeln[] IS INITIAL.
      PERFORM f_print_form USING fu_ucomm '' ''.
    ELSEIF gt_heads[] IS INITIAL.
      PERFORM f_print_form USING fu_ucomm '' ''.
    ELSE.
      PERFORM f_print_form USING fu_ucomm 'X' ''.
      PERFORM f_print_lampiran USING fu_ucomm '' 'X'.
    ENDIF.
    LEAVE TO SCREEN 0.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
*  PERFORM f_modify_screen USING : 'PRE' '0' '' '' ''.

  CASE 'X'.
    WHEN p_reprt.
      PERFORM f_modify_screen USING : 'PMA' '0' '' '' '',
                                      'PEA' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PEK' '0' '' '' '',
                                      'SCO' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'RAD' '0' '' '' '',
                                      'PGE' '0' '' '' '',
                                      'SEB' '0' '' '' ''.
    WHEN OTHERS.
      PERFORM f_modify_screen USING : 'R03' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_REPRINT_DATA
*&---------------------------------------------------------------------*
FORM f_get_reprint_data .
  DATA : ls_04a       LIKE LINE OF gt_04a,
         ls_detail    LIKE LINE OF t_detail,
         ls_04b       LIKE LINE OF gt_04b,
         ls_supplier  LIKE LINE OF t_supplier,
         ls_04c       LIKE LINE OF gt_04c,
         ls_xsuppl    LIKE LINE OF gt_xsuppl,
         ls_004       LIKE LINE OF gt_004,
         ls_detls     LIKE LINE OF gt_detls,
         ls_heads     LIKE LINE OF gt_heads,
         lv_field(30),
         lv_count     TYPE i,
         lv_nou(5),
         ls_04d       LIKE LINE OF gt_04d,
         lv_total     TYPE ekpo-menge,
         lt_04d       TYPE STANDARD TABLE OF zgdmmt004d,
         ls_lfa1      LIKE LINE OF t_lfa1.

  FIELD-SYMBOLS <fs>  TYPE any.

  SELECT *
    FROM zgdmmt004a
    INTO CORRESPONDING FIELDS OF TABLE gt_04a
    WHERE zalno IN so_zalno.

  IF gt_04a[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt004b
      INTO CORRESPONDING FIELDS OF TABLE gt_04b
      FOR ALL ENTRIES IN gt_04a
      WHERE zalno = gt_04a-zalno.

    SELECT *
      FROM zgdmmt004c
      INTO CORRESPONDING FIELDS OF TABLE gt_04c
      FOR ALL ENTRIES IN gt_04a
      WHERE zalno = gt_04a-zalno.

    SELECT *
      FROM zgdmmt004d
      INTO CORRESPONDING FIELDS OF TABLE gt_04d
      FOR ALL ENTRIES IN gt_04a
      WHERE zalno = gt_04a-zalno.
  ENDIF.

  SELECT *
    FROM zgdmmt0004x
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE type = 'NEW'.

  READ TABLE gt_04a INTO ls_04a INDEX 1.
  MOVE-CORRESPONDING ls_04a TO t_header.

  t_header-gjahr = ls_04a-zaldt(4).

  CLEAR lv_total.
  LOOP AT gt_04b INTO ls_04b.
    MOVE-CORRESPONDING ls_04b TO ls_detail.
    ls_detail-matnr = ls_04a-matnr.
    lv_total = ls_04b-menge - ls_04b-bsmng.
    ADD lv_total TO va_menget.

    APPEND ls_detail TO t_detail.
    CLEAR ls_detail.
  ENDLOOP.

  LOOP AT gt_04c INTO ls_04c.
    IF ls_04c-zeile = 1.
      CLEAR lv_nou.
      ADD 1 TO lv_count.
      lv_field = lv_count.
      CONDENSE lv_field NO-GAPS.
      CONCATENATE 'LS_SUPPLIER-LIFNR' lv_field INTO lv_field.
      ASSIGN (lv_field) TO <fs>.
      <fs> = ls_04c-lifnr.
      IF lv_count = 3.
        CLEAR lv_count.
        APPEND ls_supplier TO t_supplier.
        CLEAR ls_supplier.
      ENDIF.
    ENDIF.

    CLEAR ls_004.
    READ TABLE gt_004 INTO ls_004
                      WITH KEY zeile = ls_04c-zeile.
    IF sy-subrc = 0.
*      ADD 1 TO lv_nou.
*      ls_xsuppl-zeile = lv_nou.
      ls_xsuppl-zeile = ls_004-zeile.
      ls_xsuppl-nou   = ls_004-nou.
      SHIFT ls_xsuppl-nou LEFT DELETING LEADING '0'.
      CONDENSE ls_xsuppl-nou NO-GAPS.

      ls_xsuppl-lifnr         = ls_04c-lifnr.
      ls_xsuppl-description   = ls_004-description.
      ls_xsuppl-value         = ls_04c-value.
      ls_xsuppl-zend          = ls_004-zend.

      PERFORM f_replace_code USING ls_04a-quart ls_004-period ls_004-zgroup1 ls_04a-mjahr
                             CHANGING ls_xsuppl-description.

      APPEND ls_xsuppl TO gt_xsuppl.
    ENDIF.
    CLEAR ls_xsuppl.
  ENDLOOP.

  IF lv_count IS NOT INITIAL.
    APPEND ls_supplier TO t_supplier.
    CLEAR ls_supplier.
  ENDIF.

  CLEAR lv_total.
  LOOP AT gt_04d INTO ls_04d.
    ls_detls-ebeln  = ls_04d-ebeln.
    ls_detls-ebelp  = ls_04d-ebelp.
    ls_detls-etenr  = ls_04d-etenr.
    ls_detls-lifnr  = ls_04d-lifnr.
    ls_detls-eindt  = ls_04d-eindt.
    ls_detls-menge  = ls_04d-menge.
    ls_detls-meins  = ls_04d-meins.
    WRITE ls_04d-menge TO ls_detls-menget UNIT ls_04d-meins.
    CONDENSE ls_detls-menget.
    PERFORM f_unit_conversion USING ls_04d-meins
                              CHANGING ls_detls-meinh.
    CONCATENATE ls_detls-menget ls_detls-meinh INTO ls_detls-menget
    SEPARATED BY space.
    ADD ls_04d-menge TO lv_total.
    APPEND ls_detls TO gt_detls.
    CLEAR ls_detls.
  ENDLOOP.

  lt_04d[] = gt_04d[].
  SORT lt_04d BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_04d COMPARING lifnr.
  IF lt_04d[] IS NOT INITIAL.
    SELECT lifnr name1
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE t_lfa1
      FOR ALL ENTRIES IN lt_04d
      WHERE lifnr EQ lt_04d-lifnr.

    CLEAR ls_04d.
    LOOP AT lt_04d INTO ls_04d.
      CLEAR ls_lfa1.
      READ TABLE t_lfa1 INTO ls_lfa1
                        WITH KEY lifnr = ls_04d-lifnr.
      IF sy-subrc = 0.
        ls_heads-lifnr    = ls_lfa1-lifnr.
        ls_heads-name1    = ls_lfa1-name1.
        ls_heads-total    = lv_total.
        WRITE lv_total TO ls_heads-totalt UNIT ls_04d-meins.
        CONDENSE ls_heads-totalt.
        PERFORM f_unit_conversion USING ls_04d-meins
                                  CHANGING ls_heads-meinh.
        CONCATENATE ls_heads-totalt ls_heads-meinh INTO ls_heads-totalt
        SEPARATED BY space.

        APPEND ls_heads TO gt_heads.
        CLEAR ls_heads.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_REPRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  CHANGING fc_zalno.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZALNO'
*     subobject               = pa_ekgrp
*     toyear                  = pa_mjahr
    IMPORTING
      number                  = fc_zalno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_QUARTER_DATE
*&---------------------------------------------------------------------*
FORM f_get_quarter_date  USING    fu_mjahr fu_low fu_high.
  DATA: ls_datum  LIKE LINE OF gr_datum.

  CONCATENATE fu_mjahr fu_low INTO ls_datum-low.
  IF fu_high IS INITIAL.
    CONCATENATE fu_mjahr '1231' INTO ls_datum-high.
  ELSE.
    CONCATENATE fu_mjahr fu_high INTO ls_datum-high.
    ls_datum-high = ls_datum-high - 1.
  ENDIF.
  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO gr_datum.
  CLEAR ls_datum.
ENDFORM.                    " F_GET_QUARTER_DATE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DETAIL_FROM_EKPO
*&---------------------------------------------------------------------*
FORM f_add_detail_from_ekpo .
  DATA : lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_xdetl TYPE STANDARD TABLE OF zgdmmst0052,
         lt_ydetl TYPE STANDARD TABLE OF zgdmmst0052,
         ls_xdetl LIKE LINE OF lt_xdetl,
         ls_ydetl LIKE LINE OF lt_ydetl,
         ls_xekpo LIKE LINE OF lt_xekpo,
         lv_menge TYPE ekpo-menge.

  DATA : lt_xeket TYPE STANDARD TABLE OF eket,
         ls_xeket LIKE LINE OF lt_xeket.

  DATA : lv_xmeng     TYPE eket-menge.

  lt_xeket[] = gt_xeket[].
  SORT lt_xeket BY banfn.
  DELETE ADJACENT DUPLICATES FROM lt_xeket COMPARING banfn.

  IF lt_xeket[] IS NOT INITIAL.
    SELECT matnr banfn bnfpo lfdat menge meins frgdt frgst badat
      FROM eban
      INTO CORRESPONDING FIELDS OF TABLE lt_xdetl
      FOR ALL ENTRIES IN lt_xeket
      WHERE banfn EQ lt_xeket-banfn
        AND matnr EQ pa_matnr
        AND loekz EQ space
        AND ekgrp EQ pa_ekgrp
        AND werks EQ pa_werks
        AND frgrl EQ space.
  ENDIF.

  LOOP AT lt_xdetl INTO ls_xdetl.
    CLEAR lv_menge.
    LOOP AT gt_xeket INTO ls_xeket WHERE banfn = ls_xdetl-banfn
                                     AND bnfpo = ls_xdetl-bnfpo.
      CLEAR ls_xekpo.
      READ TABLE gt_xekpo INTO ls_xekpo
                         WITH KEY ebeln = ls_xeket-ebeln
                                  ebelp = ls_xeket-ebelp.
      IF sy-subrc = 0.
        IF ls_xekpo-umren = 0.
          lv_xmeng = ls_xeket-menge * ls_xekpo-umrez.
        ELSE.
          lv_xmeng = ls_xeket-menge * ( ls_xekpo-umrez / ls_xekpo-umren ).
        ENDIF.
      ENDIF.
      ADD lv_xmeng TO lv_menge.
    ENDLOOP.

    READ TABLE t_detail WITH KEY banfn = ls_xdetl-banfn
                                 bnfpo = ls_xdetl-bnfpo.
    IF sy-subrc = 0.
      t_detail-menge  = t_detail-menge + lv_menge.
      MODIFY TABLE t_detail TRANSPORTING menge.
    ELSE.
      ls_xdetl-menge  = lv_menge.
      APPEND ls_xdetl TO t_detail.
    ENDIF.
    CLEAR ls_xdetl.
  ENDLOOP.
ENDFORM.                    " F_ADD_DETAIL_FROM_EKPO

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
*  IF so_ebeln[] IS NOT INITIAL.
*    PERFORM f_error_message USING 'SEB' ''.
*  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_REPLACE_CODE
*&---------------------------------------------------------------------*
FORM f_replace_code  USING    fu_qcode fu_period fu_zgroup1 fu_mjahr
                     CHANGING fc_description.
  DATA : lv_quart,
         lv_q1,
         lv_q2,
         lv_q3,
         lv_q4,
         lv_semester.

  CASE fu_qcode.
    WHEN 'p_q1'.
      lv_quart    = '1'.
      lv_q1       = '1'.
      lv_semester = '1'.
    WHEN 'p_q2'.
      lv_quart    = '2'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_semester = '1'.
    WHEN 'p_q3'.
      lv_quart    = '3'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_semester = '2'.
    WHEN 'p_q4'.
      lv_quart    = '4'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_q4       = '4'.
      lv_semester = '2'.
  ENDCASE.

  CASE fu_period.
    WHEN 'Q'.
      IF fu_zgroup1 IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_q1.
        REPLACE ALL OCCURRENCES OF REGEX '&2' IN fc_description WITH lv_q2.
        REPLACE ALL OCCURRENCES OF REGEX '&3' IN fc_description WITH lv_q3.
        REPLACE ALL OCCURRENCES OF REGEX '&4' IN fc_description WITH lv_q4.
      ELSE.
        REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_quart.
      ENDIF.
    WHEN 'S'.
      REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_semester.
  ENDCASE.

  REPLACE ALL OCCURRENCES OF REGEX '&y' IN fc_description WITH fu_mjahr.
ENDFORM.                    " F_REPLACE_CODE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_ZALNO
*&---------------------------------------------------------------------*
FORM f_value_zalno  USING    fu_field.
  TYPES : BEGIN OF ty_sele,
            zalno TYPE zgdmmt004a-zalno,
            zaldt TYPE zgdmmt004a-zaldt,
            matnr TYPE zgdmmt004a-matnr,
          END OF ty_sele.

  DATA : lt_sele    TYPE STANDARD TABLE OF ty_sele,
         ls_sele    LIKE LINE OF lt_sele,
         return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_zalno TYPE zgdmmt004a-zalno,
         lv_subrc TYPE sy-subrc.

  SELECT zalno zaldt matnr
    FROM zgdmmt004a
    INTO TABLE lt_sele.

  ASSIGN lt_sele[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZALNO' fu_field
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_return-fieldval
        IMPORTING
          output = lv_zalno.

      READ TABLE lt_sele INTO ls_sele WITH KEY zalno = lv_zalno.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_sele-zalno '' ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field '' '' ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_ZALNO

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = fu_retfield
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = fu_dynprofield
      value_org   = 'S'
    TABLES
      value_tab   = <fs_tab>
      return_tab  = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_meins
                        CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LAMPIRAN
*&---------------------------------------------------------------------*
FORM f_print_lampiran USING fu_ucomm fu_close fu_open.
  p_tdform  = 'ZGDMMF0005_04NX'.

  IF gt_heads[] IS NOT INITIAL.
    PERFORM f_determine_smrt_funcmod USING p_tdform
                                           d_smrt_funcmod
                                           d_frm_subrc.

    d_ctrl_param-no_open  = fu_open.
    d_ctrl_param-no_close = fu_close.

    CASE fu_ucomm.
      WHEN 'SAVE'.
        d_output_opt-tdnoprev     = 'X'.
        d_ctrl_param-no_dialog    = space.
        d_ctrl_param-preview      = space.
**        d_output_opt-tdnewid      = 'X'.
**        d_output_opt-tdimmed      = 'X'.
**        d_output_opt-tddelete     = space.
      WHEN 'PREV'.
        d_output_opt-tdnoprint    = 'X'.
    ENDCASE.

*  d_ctrl_param-no_close   = fu_close.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        t_header           = t_header
      TABLES
        gt_heads           = gt_heads
        gt_detls           = gt_detls.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*  d_ctrl_param-no_open    = fu_open.
ENDFORM.                    " F_PRINT_LAMPIRAN

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LAMPIRAN
*&---------------------------------------------------------------------*
FORM f_prepare_lampiran .
  DATA : ls_lfa1  LIKE LINE OF t_lfa1,
         ls_xekko LIKE LINE OF gt_xekko,
         ls_xekpo LIKE LINE OF gt_xekpo,
         ls_xeket LIKE LINE OF gt_xeket,
         ls_detls LIKE LINE OF gt_detls,
         ls_heads LIKE LINE OF gt_heads.
  DATA : lv_total TYPE ekpo-menge,
         lv_count TYPE zgdmmst0056-count.

  LOOP AT t_lfa1 INTO ls_lfa1.
    CLEAR : lv_count, lv_total.
    LOOP AT gt_xekko INTO ls_xekko WHERE lifnr = ls_lfa1-lifnr.
      LOOP AT gt_xekpo INTO ls_xekpo WHERE ebeln = ls_xekko-ebeln
                                       AND matnr = pa_matnr.
        LOOP AT gt_xeket INTO ls_xeket WHERE ebeln = ls_xekpo-ebeln
                                         AND ebelp = ls_xekpo-ebelp.
          ADD 1 TO lv_count.
          ls_detls-ebeln  = ls_xeket-ebeln.
          ls_detls-ebelp  = ls_xeket-ebelp.
          ls_detls-etenr  = ls_xeket-etenr.
          ls_detls-lifnr  = ls_xekko-lifnr.
          ls_detls-eindt  = ls_xeket-eindt.
          ls_detls-menge  = ls_xeket-menge.
          ls_detls-meins  = ls_xekpo-meins.
          WRITE ls_xeket-menge TO ls_detls-menget UNIT ls_xekpo-meins.
          CONDENSE ls_detls-menget.
          PERFORM f_unit_conversion USING ls_xekpo-meins
                                    CHANGING ls_detls-meinh.
          CONCATENATE ls_detls-menget ls_detls-meinh INTO ls_detls-menget
          SEPARATED BY space.
          ADD ls_xeket-menge TO lv_total.
          APPEND ls_detls TO gt_detls.
          CLEAR ls_detls.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    ls_heads-ebeln    = ls_xekko-ebeln.
    ls_heads-eindt    = ls_xeket-eindt.
    ls_heads-lifnr    = ls_lfa1-lifnr.
    ls_heads-name1    = ls_lfa1-name1.
    ls_heads-count    = lv_count.

    ls_heads-total  = lv_total.
    WRITE lv_total TO ls_heads-totalt UNIT ls_xekpo-meins.
    CONDENSE ls_heads-totalt.
    PERFORM f_unit_conversion USING ls_xekpo-meins
                              CHANGING ls_heads-meinh.
    CONCATENATE ls_heads-totalt ls_heads-meinh INTO ls_heads-totalt
    SEPARATED BY space.

    APPEND ls_heads TO gt_heads.
    CLEAR ls_heads.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_LAMPIRAN

*&---------------------------------------------------------------------*
*&      Form  F_04D
*&---------------------------------------------------------------------*
FORM f_04d  USING    fu_zalno.
  DATA : ls_04d   LIKE LINE OF gt_04d,
         ls_heads LIKE LINE OF gt_heads,
         ls_detls LIKE LINE OF gt_detls.

  LOOP AT gt_heads INTO ls_heads WHERE count <> 1.
    LOOP AT gt_detls INTO ls_detls WHERE lifnr = ls_heads-lifnr.
      ls_04d-zalno    = fu_zalno.
      ls_04d-lifnr    = ls_detls-lifnr.
      ls_04d-ebeln    = ls_detls-ebeln.
      ls_04d-ebelp    = ls_detls-ebelp.
      ls_04d-etenr    = ls_detls-etenr.
      ls_04d-eindt    = ls_detls-eindt.
      ls_04d-menge    = ls_detls-menge.
      ls_04d-meins    = ls_detls-meins.
      APPEND ls_04d TO gt_04d.
      CLEAR ls_04d.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_04D

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_PR
*&---------------------------------------------------------------------*
FORM f_print_pr  USING    fu_ucomm fu_close fu_open.
  DATA: ld_count    TYPE i,
        ld_menge    LIKE zgdmmst0052-menge,
        ld_total    LIKE zgdmmst0052-menge,
        lv_supplier TYPE i.

  DATA: lt_nsupl    TYPE STANDARD TABLE OF zgdmmst0055.

  SORT t_detail BY banfn.
  LOOP AT t_detail.
    ld_menge = t_detail-menge - t_detail-bsmng.
    IF ld_menge = 0.
      DELETE t_detail.
      CONTINUE.
    ENDIF.
    ADD 1 TO ld_count.
    ADD ld_menge TO ld_total.
    IF ld_count EQ 20.
      PERFORM f_material_conversion USING ld_total pa_matnr t_header-meins
                                          t_detail-meins ''
                                    CHANGING t_sub-menge.
      APPEND t_sub.
      CLEAR: ld_count.
    ENDIF.
  ENDLOOP.

  PERFORM f_material_conversion USING t_sub-menge pa_matnr t_header-meins
                                      t_detail-meins ''
                                CHANGING t_sub-menge.
  APPEND t_sub.
  CLEAR: ld_count, t_sub-menge.
  DESCRIBE TABLE t_sub LINES va_lines.

*  p_tdform  = 'ZGDMMF0005_03NX'.
  p_tdform  = 'ZGDMMF0005_03NX2'.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  d_ctrl_param-no_open  = 'X'.
  d_ctrl_param-no_open  = fu_open.
  d_ctrl_param-no_close = fu_close.

*  d_output_opt-tdnoprint = p_disp.
  CASE fu_ucomm.
    WHEN 'SAVE'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = space.
      d_ctrl_param-preview      = space.
**      d_output_opt-tdnewid      = 'X'.
**      d_output_opt-tdimmed      = 'X'.
**      d_output_opt-tddelete     = space.
    WHEN 'PREV'.
      d_output_opt-tdnoprint    = 'X'.
  ENDCASE.

  IF d_frm_subrc IS INITIAL.
**      call the generated function module of the form
    IF NOT t_detail[] IS INITIAL.
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          t_header           = t_header
          wa_supplier        = wa_supplier
          va_menget          = va_menget
          va_record          = va_record
          va_totpage         = va_totpage
          va_lines           = va_lines
        TABLES
          t_detail           = t_detail
          t_sub              = t_sub
          t_suppl            = gt_xsuppl
          t_nsupl            = lt_nsupl.

      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR : va_lines, t_sub[], t_sub.
ENDFORM.                    " F_PRINT_PR

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LAST_PURCHASED
*&---------------------------------------------------------------------*
FORM f_prepare_last_purchased .
  DATA : ls_yekpo     LIKE LINE OF gt_yekpo.

  IF t_eipa[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_yekpo
      FOR ALL ENTRIES IN t_eipa
      WHERE ebeln = t_eipa-ebeln
        AND ebelp = t_eipa-ebelp
        AND loekz = space.

    IF so_ebeln[] IS NOT INITIAL.
      LOOP AT gt_yekpo INTO ls_yekpo.
        IF ls_yekpo-ebeln IN so_ebeln.
          DELETE gt_yekpo.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF gt_yekpo[] IS NOT INITIAL.
      SELECT *
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE gt_yekko
        FOR ALL ENTRIES IN gt_yekpo
        WHERE ebeln = gt_yekpo-ebeln
          AND ekgrp = pa_ekgrp.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PREPARE_LAST_PURCHASED

*&---------------------------------------------------------------------*
*&      Form  F_GET_LAST_PURCHASED
*&---------------------------------------------------------------------*
FORM f_get_last_purchased  USING    fu_lifnr fu_value
                           CHANGING fc_value.
  DATA : lt_xekko      TYPE STANDARD TABLE OF ekko,
         ls_xekko      TYPE ekko,
         ls_xekpo      TYPE ekpo,
         ls_xkonv      TYPE konv,
         lv_value1(30),
         lv_value2(30).

  lt_xekko[] = gt_yekko[].
  DELETE lt_xekko WHERE lifnr <> fu_lifnr.
  SORT lt_xekko BY aedat DESCENDING ebeln DESCENDING.
  READ TABLE lt_xekko INTO ls_xekko INDEX 1.
  IF sy-subrc = 0.
    CASE fu_value.
      WHEN 'D'.
        WRITE ls_xekko-aedat TO fc_value DD/MM/YYYY.
      WHEN 'P'.
        CLEAR ls_xekpo .
        READ TABLE gt_xekpo INTO ls_xekpo
                            WITH KEY ebeln = ls_xekko-ebeln.
        IF sy-subrc NE 0.
          READ TABLE gt_yekpo INTO ls_xekpo
                              WITH KEY ebeln = ls_xekko-ebeln.
        ENDIF.
        SELECT SINGLE *
          FROM konv
          INTO CORRESPONDING FIELDS OF ls_xkonv
          WHERE knumv = ls_xekko-knumv
            AND kposn = ls_xekpo-ebelp
            AND kschl = 'ZPB0'.
        IF sy-subrc = 0.
          WRITE ls_xkonv-kbetr TO lv_value1 CURRENCY ls_xkonv-waers.
          CONDENSE lv_value1.
          WRITE ls_xkonv-kpein TO lv_value2 UNIT ls_xkonv-kmein.
          CONDENSE lv_value2.
          PERFORM f_unit_conversion USING ls_xkonv-kmein
                                    CHANGING ls_xkonv-kmein.
          CONCATENATE ls_xkonv-waers lv_value1 '/' lv_value2 ls_xkonv-kmein
          INTO lv_value1
          SEPARATED BY space.
          fc_value = lv_value1.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_LAST_PURCHASED

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_HIGHEST_PRICE
*&---------------------------------------------------------------------*
FORM f_prepare_highest_price  TABLES   ft_eipa STRUCTURE eipa
                              CHANGING fc_highp fc_pwaer fc_ppeinh fc_pprme
                                       fc_bedat.
  TYPES : BEGIN OF ty_eipa.
           INCLUDE STRUCTURE eipa.
  TYPES :   preis_2 TYPE z19_3,
         END OF ty_eipa.

  DATA : BEGIN OF lt_eipasum OCCURS 0,
           infnr TYPE eipa-infnr,
           cntr  TYPE int4,
         END OF lt_eipasum.

  DATA : lv_datum TYPE sy-datum,
*         lt_eipa  TYPE STANDARD TABLE OF eipa,
         lt_eipa  TYPE STANDARD TABLE OF ty_eipa,
         ls_eipa  LIKE LINE OF lt_eipa,
*         lt_xeipa TYPE STANDARD TABLE OF eipa,
         lt_xeipa TYPE STANDARD TABLE OF ty_eipa,
         ls_xeipa LIKE LINE OF lt_xeipa.

  DATA : lv_ebeln TYPE ekko-ebeln,
         lv_knumv TYPE ekko-knumv,
         lv_preis TYPE p DECIMALS 4.

  CONCATENATE sy-datum(4) '0101' INTO lv_datum.
  lt_eipa[] = ft_eipa[].
  DELETE lt_eipa WHERE bedat < lv_datum.

* Delete first PO in year
  LOOP AT lt_eipa INTO ls_eipa.
    lt_eipasum-infnr = ls_eipa-infnr.
    lt_eipasum-cntr  = 1.
    COLLECT lt_eipasum.
  ENDLOOP.

  LOOP AT lt_eipa INTO ls_eipa.
    IF ls_eipa-ebeln IN so_ebeln AND
       so_ebeln[] IS NOT INITIAL.
      DELETE TABLE lt_eipa FROM ls_eipa.
    ELSE.
*      READ TABLE lt_eipasum WITH KEY infnr = ls_eipa-infnr.
*      IF lt_eipasum-cntr = 1.
*        DELETE TABLE lt_eipa FROM ls_eipa.
*      ELSE.
      IF ls_eipa-lprei IS NOT INITIAL.
        TRY .
            ls_eipa-preis = ls_eipa-lprei / ls_eipa-lpein.
          CATCH cx_sy_zerodivide.
        ENDTRY.
        TRY .
            ls_eipa-preis_2 = ls_eipa-lprei / ls_eipa-lpein.
          CATCH cx_sy_zerodivide.
        ENDTRY.
      ELSE.
        TRY .
            ls_eipa-preis = ls_eipa-preis / ls_eipa-peinh.
          CATCH cx_sy_zerodivide.
        ENDTRY.
        TRY .
            ls_eipa-preis_2 = ls_eipa-preis / ls_eipa-peinh.
          CATCH cx_sy_zerodivide.
        ENDTRY.
      ENDIF.

      APPEND ls_eipa TO lt_xeipa.
      CLEAR ls_eipa.
*      ENDIF.
    ENDIF.
  ENDLOOP.

*  SORT lt_xeipa BY preis DESCENDING bedat.
  SORT lt_xeipa BY preis_2 DESCENDING bedat.
  READ TABLE lt_xeipa INTO ls_eipa INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE ebeln preis bwaer peinh bprme bedat
      FROM eipa
      INTO (lv_ebeln, fc_highp, fc_pwaer, fc_ppeinh, fc_pprme, fc_bedat)
      WHERE infnr = ls_eipa-infnr
        AND ebeln = ls_eipa-ebeln
        AND ebelp = ls_eipa-ebelp.

    SELECT SINGLE knumv
      FROM ekko
      INTO lv_knumv
      WHERE ebeln = lv_ebeln.

    SELECT SINGLE kbetr waers kpein kmein
      FROM konv
      INTO (fc_highp, fc_pwaer, fc_ppeinh, fc_pprme)
      WHERE kappl = 'M'
        AND kschl = 'ZPB0'
        AND knumv = lv_knumv
        AND kposn = ls_eipa-ebelp.
  ENDIF.
ENDFORM.                    " F_PREPARE_HIGHEST_PRICE
