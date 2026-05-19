*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SELECTION
*&---------------------------------------------------------------------*
FORM f_modify_selection .
  PERFORM f_modify_screen USING : 'XXX' '0' '' '' ''.

  CASE 'X'.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SER' '0' '' '' '',
                                      'SDO' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .

ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu,
         lv_procid    TYPE zaccdtu-procid.

  SELECT *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtu
    WHERE company = 'BPOM'.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 1.
  IF sy-subrc = 0.
    gv_login     = ls_zaccdtu-uri.
    gv_logproxy  = ls_zaccdtu-proxy.
  ENDIF.

  CASE 'X'.
    WHEN radio2.
      lv_procid = 2.
    WHEN radio3.
      lv_procid = 3.
    WHEN radio5.
      lv_procid = 5.
    WHEN radio6.
      lv_procid = 6.
    WHEN radio11.
      lv_procid = 11.
    WHEN radio13.
      lv_procid = 13.
  ENDCASE.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = lv_procid.
  IF sy-subrc = 0.
    gv_uri    = ls_zaccdtu-uri.
    gv_proxy  = ls_zaccdtu-proxy.
  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data USING fu_docat fu_snsta fu_stbpom.
  TYPES : BEGIN OF ty_s501,
            vbeln   TYPE likp-vbeln,
          END OF ty_s501.

  DATA : lt_s501          TYPE STANDARD TABLE OF ty_s501,
         ls_y501          LIKE LINE OF lt_s501,
         ls_s501          LIKE LINE OF gt_s501,
         lt_likp          TYPE STANDARD TABLE OF likp,
         ls_zaccdtm       LIKE LINE OF gt_zaccdtm,
         ls_ztspmmdt002   LIKE LINE OF gt_ztspmmdt002.

  CLEAR : gt_zaccdtm[], gt_zaccdtm, gt_zaccdta[], gt_zaccdta.

  IF gt_s501[] IS INITIAL.
    SELECT *
      FROM s501
      INTO CORRESPONDING FIELDS OF TABLE gt_s501
      WHERE sptag IN so_erdat
        AND docat  = fu_docat
        AND docno IN so_docno
        AND stbpom = fu_stbpom.
    IF gt_s501[] IS NOT INITIAL.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
        FOR ALL ENTRIES IN gt_s501
        WHERE docat = gt_s501-docat
          AND docno = gt_s501-docno.
    ENDIF.

    CASE 'X'.
      WHEN radio2.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN gt_zaccdtd
          WHERE senum = gt_zaccdtd-senum.

        LOOP AT gt_s501 INTO ls_s501.
          ls_y501-vbeln = ls_s501-docno.
          APPEND ls_y501 TO lt_s501.
          CLEAR ls_y501.
        ENDLOOP.

        SORT lt_s501 BY vbeln.
        DELETE ADJACENT DUPLICATES FROM lt_s501 COMPARING vbeln.
        IF lt_s501[] IS NOT INITIAL.
          SELECT *
            FROM likp
            INTO CORRESPONDING FIELDS OF TABLE gt_likp
            FOR ALL ENTRIES IN lt_s501
            WHERE vbeln = lt_s501-vbeln.

          lt_likp[] = gt_likp[].
          SORT lt_likp BY kunnr.
          DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
          IF lt_likp[] IS NOT INITIAL.
            SELECT *
              FROM kna1
              INTO CORRESPONDING FIELDS OF TABLE gt_kna1
              FOR ALL ENTRIES IN lt_likp
              WHERE kunnr = lt_likp-kunnr.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

  IF fu_snsta IS NOT INITIAL.
    IF fu_snsta = 'RTS' OR
      fu_snsta = 'RJCT'.
      IF gt_s501[] IS NOT INITIAL.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN gt_s501
          WHERE aufnr = gt_s501-docno
            AND snsta = fu_snsta.

*        IF gt_zaccdtm[] IS NOT INITIAL.
*          SELECT *
*            FROM mch1
*            INTO CORRESPONDING FIELDS OF TABLE gt_mch1
*            FOR ALL ENTRIES IN gt_zaccdtm
*            WHERE matnr = gt_zaccdtm-matnr
*              AND charg = gt_zaccdtm-charg.
*
*        ENDIF.
*        IF gt_s501[] IS NOT INITIAL.
*          SELECT *
*            FROM ztspmmdt002
*            INTO CORRESPONDING FIELDS OF TABLE gt_ztspmmdt002
*            FOR ALL ENTRIES IN gt_s501
*            WHERE werks = gt_s501-werks
*              AND matnr = gt_s501-matnr.
*
*          CLEAR ls_zaccdtm.
*          LOOP AT gt_zaccdtm INTO ls_zaccdtm.
*            CLEAR ls_ztspmmdt002.
*            READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
*                                      WITH KEY matnr = ls_zaccdtm-matnr.
*            IF sy-subrc = 0.
*              ls_zaccdtm-nie      = ls_ztspmmdt002-nie.
*              ls_zaccdtm-kemasan  = ls_ztspmmdt002-kemasan.
*              MODIFY gt_zaccdtm FROM ls_zaccdtm TRANSPORTING nie kemasan.
*            ENDIF.
*            CLEAR ls_zaccdtm.
*          ENDLOOP.
*        ENDIF.
      ENDIF.
    ELSE.
      IF gt_zaccdtd[] IS NOT INITIAL.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN gt_zaccdtd
          WHERE senum = gt_zaccdtd-senum
            AND snsta = fu_snsta.

        CASE 'X'.
          WHEN radio5 OR radio6 OR radio11.
            IF gt_zaccdtm[] IS NOT INITIAL.
              SELECT *
                FROM zaccdta
                INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
                FOR ALL ENTRIES IN gt_zaccdtm
                WHERE matnr = gt_zaccdtm-matnr
                  AND charg = gt_zaccdtm-charg
                  AND senum = gt_zaccdtm-senum.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data USING fu_snsta.
  DATA : ls_zaccdtm           LIKE LINE OF gt_zaccdtm,
         ls_xaccdtm           LIKE LINE OF gt_zaccdtm,
         lv_lines             TYPE i,
         lv_xlines            TYPE i,
         lv_count             TYPE i,
         ls_request_header    LIKE LINE OF gt_request_header,
         lt_zaccdtm           TYPE STANDARD TABLE OF zv_accdtm,
         lt_zaccdta1          TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdta2          TYPE STANDARD TABLE OF zaccdta,
         ls_zaccdta1          LIKE LINE OF gt_zaccdta,
         ls_zaccdta2          LIKE LINE OF gt_zaccdta,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_zaccdtd           LIKE LINE OF gt_zaccdtd,
         ls_sarana            LIKE LINE OF gt_sarana,
         ls_likp              LIKE LINE OF gt_likp,
         ls_kna1              LIKE LINE OF gt_kna1,
         lv_times             TYPE i.

  DATA : lv_active(10),
         lv_sample(10),
         lv_reject(10),
         lv_gtin(20) VALUE '1',
         lv_packdat1(10),
         lv_packdat2(10),
         lv_vfdat(10).

  DATA : ls_mch1              LIKE LINE OF gt_mch1.
  DATA : lv_barcode           TYPE string.

  FIELD-SYMBOLS : <fs>        TYPE ANY.

  CASE 'X'.
    WHEN radio2.
      LOOP AT gt_kna1 INTO ls_kna1.
        CLEAR lv_lines.
        LOOP AT gt_likp INTO ls_likp WHERE kunnr = ls_kna1-kunnr.
          LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE docno = ls_likp-vbeln.
            ADD 1 TO lv_lines.
          ENDLOOP.
        ENDLOOP.

        lv_times  = lv_lines DIV co_lines.

        IF lv_lines = co_lines.
          lv_times  = 1.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.

        DO lv_times TIMES.
          ls_request_header-header = 'Content-Type: application/json'.
          APPEND ls_request_header TO gt_request_header.

          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' gv_token '' ',' '' '' '',
            '' 'id_sarana_tujuan' ls_kna1-locco '' ',' '' '' '',
            '' 'barcode' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.

          LOOP AT gt_likp INTO ls_likp WHERE kunnr = ls_kna1-kunnr.
            LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE docno = ls_likp-vbeln
                                                 AND check = space.
              ADD 1 TO lv_count.
              IF lv_count > co_lines.
                lv_count = lv_count - 1.
                EXIT.
              ENDIF.

              IF lv_lines < co_lines.
                lv_xlines = lv_lines.
              ELSE.
                lv_xlines = co_lines.
              ENDIF.

              CLEAR ls_zaccdtm.
              READ TABLE gt_zaccdtm INTO ls_zaccdtm
                                    WITH KEY senum = ls_zaccdtd-senum.

              PERFORM f_create_barcode USING ls_zaccdtm-nie
                                             ls_zaccdtm-charg
                                             ls_zaccdtm-vfdat
                                             ls_zaccdtd-senum
                                       CHANGING lv_barcode.

              IF lv_count = lv_xlines.
                PERFORM f_json_format USING :
                  '' '' lv_barcode '' '' '' '' ''.
              ELSE.
                PERFORM f_json_format USING :
                  '' '' lv_barcode '' ',' '' '' ''.
              ENDIF.
              ls_zaccdtd-check = 'X'.
              MODIFY gt_zaccdtd FROM ls_zaccdtd TRANSPORTING check.
            ENDLOOP.
            lv_lines  = lv_lines - lv_count.
            EXIT.
          ENDLOOP.

          PERFORM f_json_format USING :
            '' '' '' '' '' '' '' ']',
            '' '' '' '' '' '' '' '}'.

          PERFORM f_http_post USING gv_uri gv_proxy 'X'.
          CLEAR lv_count.
        ENDDO.
      ENDLOOP.

    WHEN radio3.
      LOOP AT gt_sarana INTO ls_sarana.
        ASSIGN COMPONENT 'ID' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-id.
        ASSIGN COMPONENT 'ID_GROUP' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-id_group.
        ASSIGN COMPONENT 'NAMA_REKANAN' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-nama_rekanan.
        ASSIGN COMPONENT 'ALAMAT_REKANAN' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-alamat_rekanan.
        ASSIGN COMPONENT 'NO_TELP' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-no_telp.
        ASSIGN COMPONENT 'FAX' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-fax.
        ASSIGN COMPONENT 'PROVINSI' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-provinsi.
        ASSIGN COMPONENT 'KOTA' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-kota.
        ASSIGN COMPONENT 'LATITUDE' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-latitude.
        ASSIGN COMPONENT 'LONGITUDE' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-longitude.
        ASSIGN COMPONENT 'STATUS' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-status.
        ASSIGN COMPONENT 'LOGO_REKANAN' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-logo_rekanan.
        ASSIGN COMPONENT 'CREATED_AT' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-created_at.
        ASSIGN COMPONENT 'UPDATED_AT' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-updated_at.
        ASSIGN COMPONENT 'DELETED' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-deleted.
        ASSIGN COMPONENT 'FILE_DOKUMEN' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-file_dokumen.
        ASSIGN COMPONENT 'BADAN_USAHA' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-badan_usaha.
        ASSIGN COMPONENT 'NPWP' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_sarana-npwp.
        APPEND <fs_ltop> TO <fs_top>.
        CLEAR <fs_ltop>.
      ENDLOOP.

    WHEN radio5.
      lt_zaccdta1[] = gt_zaccdta[].
      SORT lt_zaccdta1 BY aggr1.
      DELETE ADJACENT DUPLICATES FROM lt_zaccdta1 COMPARING aggr1.
*      lt_zaccdta2[] = gt_zaccdta[].
*      SORT lt_zaccdta2 BY aggr2.
*      DELETE ADJACENT DUPLICATES FROM lt_zaccdta2 COMPARING aggr2.

      LOOP AT lt_zaccdta2 INTO ls_zaccdta2.
        CLEAR : lv_lines, lv_count, ls_xaccdtm.
        LOOP AT lt_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = ls_zaccdta2-aggr2.
          ADD 1 TO lv_lines.
        ENDLOOP.

        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        PERFORM f_json_format USING :
          '{' '' '' '' '' '' '' '',
          '' 'token' gv_token '' ',' '' '' '',
          '' 'barcode' '' '' '' '' 'X' '',
          '[' '' '' '' '' '' '' ''.
        LOOP AT lt_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = ls_zaccdta2-aggr2.
          ADD 1 TO lv_count.
          IF lv_count = lv_lines.
            PERFORM f_json_format USING :
              '' '' ls_zaccdta1-aggr1 '' '' '' '' ''.
          ELSE.
            PERFORM f_json_format USING :
              '' '' ls_zaccdta1-aggr1 '' ',' '' '' ''.
          ENDIF.
          PERFORM f_json_format USING :
            '' '' '' '' ',' '' '' ']',
            '' 'is_active' 'true' 'X' ',' '' '' '',
            '' 'barcode_level' 'tersier' '' ',' '' '' '',
            '' 'parent' ls_zaccdta2-aggr2 '' '' '' '' '',
            '' '' '' '' '' '' '' '}'.

          PERFORM f_http_post USING gv_uri gv_proxy 'X'.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_zaccdta1 INTO ls_zaccdta1.
        CLEAR : lv_lines, lv_count, ls_xaccdtm.
        LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_zaccdta1-aggr1.
          ADD 1 TO lv_lines.
        ENDLOOP.

        lv_times  = lv_lines DIV co_lines.

        IF lv_lines = co_lines.
          lv_times  = 1.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.

        DO lv_times TIMES.
          ls_request_header-header = 'Content-Type: application/json'.
          APPEND ls_request_header TO gt_request_header.

          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' gv_token '' ',' '' '' '',
            '' 'barcode' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.
          LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_zaccdta1-aggr1
                                               AND check = space.
            ADD 1 TO lv_count.
            IF lv_count > co_lines.
              lv_count = lv_count - 1.
              EXIT.
            ENDIF.

            IF lv_lines < co_lines.
              lv_xlines = lv_lines.
            ELSE.
              lv_xlines = co_lines.
            ENDIF.

            IF lv_count = lv_xlines.
              PERFORM f_json_format USING :
                '' '' ls_zaccdta-senum '' '' '' '' ''.
            ELSE.
              PERFORM f_json_format USING :
                '' '' ls_zaccdta-senum '' ',' '' '' ''.
            ENDIF.
            ls_zaccdta-check = 'X'.
            MODIFY gt_zaccdta FROM ls_zaccdta TRANSPORTING check.
          ENDLOOP.

          PERFORM f_json_format USING :
            '' '' '' '' ',' '' '' ']',
            '' 'is_active' 'true' 'X' ',' '' '' '',
            '' 'barcode_level' 'sekunder' '' ',' '' '' '',
            '' 'parent' ls_zaccdta1-aggr1 '' '' '' '' '',
            '' '' '' '' '' '' '' '}'.

          PERFORM f_http_post USING gv_uri gv_proxy 'X'.
          CLEAR lv_count.
        ENDDO.
      ENDLOOP.

    WHEN radio6.
      CASE fu_snsta.
        WHEN 'ESTO'.
          lv_active = 'true'.
          lv_sample = 'false'.
          lv_reject = 'false'.
        WHEN 'RTS'.
          lv_active = 'false'.
          lv_sample = 'true'.
          lv_reject = 'false'.
        WHEN 'RJCT'.
          lv_active = 'false'.
          lv_sample = 'false'.
          lv_reject = 'true'.
      ENDCASE.

      lt_zaccdtm[] = gt_zaccdtm[].
      SORT lt_zaccdtm BY nie charg.
      DELETE ADJACENT DUPLICATES FROM lt_zaccdtm COMPARING nie charg.
      LOOP AT lt_zaccdtm INTO ls_zaccdtm.
        CLEAR : lv_lines, lv_count, ls_xaccdtm.
        LOOP AT gt_zaccdtm INTO ls_xaccdtm WHERE nie   = ls_zaccdtm-nie
                                             AND charg = ls_zaccdtm-charg.
          ADD 1 TO lv_lines.
        ENDLOOP.

*        CLEAR ls_mch1.
*        READ TABLE gt_mch1 INTO ls_mch1
*                           WITH KEY matnr = ls_zaccdtm-matnr
*                                    charg = ls_zaccdtm-charg.
*        IF sy-subrc = 0.
*          ls_zaccdtm-vfdat  = ls_mch1-vfdat.
*        ENDIF.

        lv_times  = lv_lines DIV co_lines.

        IF lv_lines = co_lines.
          lv_times  = 1.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.

        DO lv_times TIMES.
          ls_request_header-header = 'Content-Type: application/json'.
          APPEND ls_request_header TO gt_request_header.

          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' gv_token '' ',' '' '' '',
            '' 'barcode' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.
          LOOP AT gt_zaccdtm INTO ls_xaccdtm WHERE nie   = ls_zaccdtm-nie
                                               AND charg = ls_zaccdtm-charg
                                               AND check = space.
            ADD 1 TO lv_count.
            IF lv_count > co_lines.
              lv_count = lv_count - 1.
              EXIT.
            ENDIF.

            IF lv_lines < co_lines.
              lv_xlines = lv_lines.
            ELSE.
              lv_xlines = co_lines.
            ENDIF.

            PERFORM f_create_barcode USING ls_zaccdtm-nie
                                           ls_zaccdtm-charg
                                           ls_zaccdtm-vfdat
                                           ls_xaccdtm-senum
                                     CHANGING lv_barcode.

            IF lv_count = lv_xlines.
              PERFORM f_json_format USING :
                '' '' lv_barcode '' '' '' '' ''.
            ELSE.
              PERFORM f_json_format USING :
                '' '' lv_barcode '' ',' '' '' ''.
            ENDIF.
            ls_xaccdtm-check = 'X'.
            MODIFY gt_zaccdtm FROM ls_xaccdtm TRANSPORTING check.
          ENDLOOP.
          lv_lines  = lv_lines - lv_count.
          CLEAR lv_vfdat.
          CONCATENATE ls_zaccdtm-vfdat(4) '-'
                      ls_zaccdtm-vfdat+4(2) '-'
                      ls_zaccdtm-vfdat+6(2)
                 INTO lv_vfdat.
          PERFORM f_json_format USING :
            '' '' '' '' ',' '' '' ']',
            '' 'nie' ls_zaccdtm-nie '' ',' '' '' '',
            '' 'lot_no' ls_zaccdtm-aufnr '' ',' '' '' '',
            '' 'batch_no' ls_zaccdtm-charg '' ',' '' '' '',
            '' 'exp_date' lv_vfdat '' ',' '' '' '',
            '' 'gtin' lv_gtin '' ',' '' '' '',
            '' 'is_active' lv_active 'X' ',' '' '' '',
            '' 'is_sample' lv_sample 'X' ',' '' '' '',
            '' 'is_reject' lv_reject 'X' ',' '' '' '',
            '' 'id_kemasan' ls_zaccdtm-kemasan '' '' 'X' '' '',
            '' '' '' '' '' '' '' '}'.

          PERFORM f_http_post USING gv_uri gv_proxy 'X'.
          CLEAR lv_count.
        ENDDO.
      ENDLOOP.

      IF fu_snsta = 'ESTO'.
        PERFORM f_barcode_aggregation.
      ENDIF.

    WHEN radio11.
      lt_zaccdta1[] = gt_zaccdta[].
      SORT lt_zaccdta1 BY aggr1.
      DELETE ADJACENT DUPLICATES FROM lt_zaccdta1 COMPARING aggr1.
*      lt_zaccdta2[] = gt_zaccdta[].
*      SORT lt_zaccdta2 BY aggr2.
*      DELETE ADJACENT DUPLICATES FROM lt_zaccdta2 COMPARING aggr2.

      LOOP AT lt_zaccdta1 INTO ls_zaccdta1.
        CLEAR : lv_lines, lv_count, ls_xaccdtm.
        LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_zaccdta1-aggr1.
          ADD 1 TO lv_lines.
        ENDLOOP.

        lv_times  = lv_lines DIV co_lines.

        IF lv_lines = co_lines.
          lv_times  = 1.
        ELSE.
          lv_times  = lv_times + 1.
        ENDIF.

        DO lv_times TIMES.
          ls_request_header-header = 'Content-Type: application/json'.
          APPEND ls_request_header TO gt_request_header.

          PERFORM f_json_format USING :
            '{' '' '' '' '' '' '' '',
            '' 'token' gv_token '' ',' '' '' '',
            '' 'parent' ls_zaccdta1-aggr1 '' ',' '' '' '',
            '' 'latitude' '0' '' ',' '' '' '',
            '' 'longitude' '0' '' ',' '' '' '',
            '' 'parent_type' 'sekunder' '' ',' '' '' '',
            '' 'child' '' '' '' '' 'X' '',
            '[' '' '' '' '' '' '' ''.
          LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_zaccdta1-aggr1
                                               AND check = space.
            ADD 1 TO lv_count.
            IF lv_count > co_lines.
              lv_count = lv_count - 1.
              EXIT.
            ENDIF.

            IF lv_lines < co_lines.
              lv_xlines = lv_lines.
            ELSE.
              lv_xlines = co_lines.
            ENDIF.

            IF lv_count = lv_xlines.
              PERFORM f_json_format USING :
                '' '' ls_zaccdta-senum '' '' '' '' ''.
            ELSE.
              PERFORM f_json_format USING :
                '' '' ls_zaccdta-senum '' ',' '' '' ''.
            ENDIF.
            ls_zaccdta-check = 'X'.
            MODIFY gt_zaccdta FROM ls_zaccdta TRANSPORTING check.
          ENDLOOP.

          lv_lines  = lv_lines - lv_count.

          CONCATENATE ls_zaccdta1-packdat1(4) '-'
                      ls_zaccdta1-packdat1+4(2) '-'
                      ls_zaccdta1-packdat1+6(2)
                      INTO lv_packdat1.

          PERFORM f_json_format USING :
            '' '' '' '' ',' '' '' ']',
            '' 'packing_date' lv_packdat1 '' '' '' '' '',
            '' '' '' '' '' '' '' '}'.

          PERFORM f_http_post USING gv_uri gv_proxy 'X'.
          CLEAR lv_count.
        ENDDO.
      ENDLOOP.

      LOOP AT lt_zaccdta2 INTO ls_zaccdta2.
        CLEAR : lv_lines, lv_count, ls_xaccdtm.
        LOOP AT lt_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = ls_zaccdta2-aggr2.
          ADD 1 TO lv_lines.
        ENDLOOP.

        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        PERFORM f_json_format USING :
          '{' '' '' '' '' '' '' '',
          '' 'token' gv_token '' ',' '' '' '',
          '' 'parent' ls_zaccdta2-aggr2 '' ',' '' '' '',
          '' 'latitude' '0' '' ',' '' '' '',
          '' 'longitude' '0' '' ',' '' '' '',
          '' 'parent_type' 'tersier' '' ',' '' '' '',
          '' 'child' '' '' '' '' 'X' '',
          '[' '' '' '' '' '' '' ''.
        LOOP AT lt_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = ls_zaccdta2-aggr2.
          ADD 1 TO lv_count.
          IF lv_count = lv_lines.
            PERFORM f_json_format USING :
              '' '' ls_zaccdta1-aggr1 '' '' '' '' ''.
          ELSE.
            PERFORM f_json_format USING :
              '' '' ls_zaccdta1-aggr1 '' ',' '' '' ''.
          ENDIF.
        ENDLOOP.
        CONCATENATE ls_zaccdta2-packdat2(4) '-'
                    ls_zaccdta2-packdat2+4(2) '-'
                    ls_zaccdta2-packdat2+6(2)
                    INTO lv_packdat2.

        PERFORM f_json_format USING :
          '' '' '' '' ',' '' '' ']',
          '' 'packing_date' lv_packdat2 '' '' '' '' '',
          '' '' '' '' '' '' '' '}'.

        PERFORM f_http_post USING gv_uri gv_proxy 'X'.
      ENDLOOP.

    WHEN radio13.
      DESCRIBE TABLE gt_zaccdtd LINES lv_lines.

      lv_times  = lv_lines DIV co_lines.

      IF lv_lines = co_lines.
        lv_times  = 1.
      ELSE.
        lv_times  = lv_times + 1.
      ENDIF.

      DO lv_times TIMES.
        ls_request_header-header = 'Content-Type: application/json'.
        APPEND ls_request_header TO gt_request_header.

        PERFORM f_json_format USING :
          '{' '' '' '' '' '' '' '',
          '' 'token' gv_token '' ',' '' '' '',
          '' 'barcode' '' '' '' '' 'X' '',
          '[' '' '' '' '' '' '' ''.
        LOOP AT gt_zaccdtd INTO ls_zaccdtd WHERE check = space.
          ADD 1 TO lv_count.
          IF lv_count > co_lines.
            lv_count = lv_count - 1.
            EXIT.
          ENDIF.

          IF lv_lines < co_lines.
            lv_xlines = lv_lines.
          ELSE.
            lv_xlines = co_lines.
          ENDIF.

          CLEAR ls_zaccdtm.
          READ TABLE gt_zaccdtm INTO ls_zaccdtm
                                WITH KEY senum = ls_zaccdtd-senum.

          PERFORM f_create_barcode USING ls_zaccdtm-nie
                                         ls_zaccdtm-charg
                                         ls_zaccdtm-vfdat
                                         ls_zaccdtd-senum
                                   CHANGING lv_barcode.

          IF lv_count = lv_xlines.
            PERFORM f_json_format USING :
              '' '' lv_barcode '' '' '' '' ''.
          ELSE.
            PERFORM f_json_format USING :
              '' '' lv_barcode '' ',' '' '' ''.
          ENDIF.
          ls_zaccdtd-check = 'X'.
          MODIFY gt_zaccdtd FROM ls_zaccdtd TRANSPORTING check.
        ENDLOOP.
        lv_lines  = lv_lines - lv_count.

        PERFORM f_json_format USING :
          '' '' '' '' '' '' '' ']',
          '' '' '' '' '' '' '' '}'.

        PERFORM f_http_post USING gv_uri gv_proxy 'X'.
        CLEAR lv_count.
      ENDDO.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         lv_title(100).

  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  lv_title  = 'BPOM Daftar Sarana'.

  SET TITLEBAR 'TITLE' WITH lv_title.

  PERFORM f_excluding_toolbar USING :
    '&INFO' 'T',
    '&GRAPH' 'T',

    '&INFO' 'B',
    '&GRAPH' 'B'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar  USING    fu_attribute fu_pos.
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = fu_attribute.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_exclude TO gs_exclude_t.
    WHEN 'B'.
      APPEND ls_exclude TO gs_exclude_b.
  ENDCASE.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_SILVER'.

  IF g_maincont IS INITIAL.
    CREATE OBJECT g_maincont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_maincont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_top.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_bottom.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TOP_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE top_alv OUTPUT.
  IF g_tgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_top.

    PERFORM f_build_layout USING 'T'.
    PERFORM f_build_sort USING 'T'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickt
                event_receiver->handle_toolbart
                event_receiver->handle_menu_buttont
                event_receiver->handle_user_commandt FOR g_tgrid.

    CALL METHOD g_tgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_t
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_top>[]
        it_fieldcatalog      = gt_fieldcat_t[].
*  ELSE.
*    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " TOP_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  BOTTOM_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE bottom_alv OUTPUT.
  IF g_bgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_bgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_bottom.

    PERFORM f_build_layout USING 'B'.
    PERFORM f_build_sort USING 'B'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickb
                event_receiver->handle_toolbarb
                event_receiver->handle_menu_buttonb
                event_receiver->handle_user_commandb FOR g_bgrid.

    CALL METHOD g_bgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_b
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_bottom>[]
        it_fieldcatalog      = gt_fieldcat_b[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " BOTTOM_ALV  OUTPUT

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
  CASE ok_code.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tgrid IS NOT INITIAL.
      CALL METHOD g_tgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.

    IF g_bgrid IS NOT INITIAL.
      CALL METHOD g_bgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_pos.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  CASE fu_pos.
    WHEN 'T'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
    WHEN 'B'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'T'.
    WHEN 'B'.
*      gt_main_sort-spos      = 1.
*      gt_main_sort-fieldname = ''.
*      gt_main_sort-up        = selected.
*      APPEND gt_main_sort.
*      CLEAR gt_main_sort.
  ENDCASE.

ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table  USING    fu_pos.
  DATA : fname            TYPE string,
         title            TYPE string,
         lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data.

  CASE fu_pos.
    WHEN 'T'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'ID' '' '' '' '' '' '' '' ''
        'ID' '' '' '' '' '' 'X',
        fu_pos 'ID_GROUP' '' '' '' '' '' '' '' ''
        'ID Group' '' '' '' '' '' 'X',
        fu_pos 'NAMA_REKANAN' '' '' '' '' '' '' '' ''
        'Nama Rekanan' '100' '' '' '' '' 'X',
        fu_pos 'ALAMAT_REKANAN' '' '' '' '' '' '' '' ''
        'Alamat Rekanan' '255' '' '' '' '' '',
        fu_pos 'NO_TELP' '' '' '' '' '' '' '' ''
        'Telp' '' '' '' '' '' '',
        fu_pos 'FAX' '' '' '' '' '' '' '' ''
        'Fax' '' '' '' '' '' '',
        fu_pos 'PROVINSI' '' '' '' '' '' '' '' ''
        'Provinsi' '' '' '' '' '' '',
        fu_pos 'KOTA' '' '' '' '' '' '' '' ''
        'Kota' '' '' '' '' '' '',
        fu_pos 'LATITUDE' '' '' '' '' '' '' '' ''
        'Latitude' '' '' '' '' '' '',
        fu_pos 'LONGITUDE' '' '' '' '' '' '' '' ''
        'Longitude' '' '' '' '' '' '',
        fu_pos 'STATUS' '' '' '' '' '' '' '' ''
        'Status' '' '' '' '' '' '',
        fu_pos 'LOGO_REKANAN' '' '' '' '' '' '' '' ''
        'Logo Rekanan' '' '' '' '' '' '',
        fu_pos 'CREATED_AT' '' '' '' '' '' '' '' ''
        'Created' '' '' '' '' '' '',
        fu_pos 'UPDATED_AT' '' '' '' '' '' '' '' ''
        'Updated' '' '' '' '' '' '',
        fu_pos 'DELETED' '' '' '' '' '' '' '' ''
        'Deleted' '' '' '' '' '' '',
        fu_pos 'FILE_DOKUMEN' '' '' '' '' '' '' '' ''
        'File Dokumen' '' '' '' '' '' '',
        fu_pos 'BADAN_USAHA' '' '' '' '' '' '' '' ''
        'Badan Usaha' '' '' '' '' '' '',
        fu_pos 'NPWP' '' '' '' '' '' '' '' ''
        'NPWP' '' '' '' '' '' ''.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_t
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_top>.
        CREATE DATA ls_line LIKE LINE OF <fs_top>.
        ASSIGN ls_line->* TO <fs_ltop>.
      ENDIF.

    WHEN 'B'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KUNNR' '' '' '' '' '' '' 'KUNNR' 'KNA1' '' '' '' '' '' '' 'X'.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_b
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_bottom>.
        CREATE DATA ls_line LIKE LINE OF <fs_bottom>.
        ASSIGN ls_line->* TO <fs_lbottom>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_no_out fu_edit fu_tech fu_just fu_fix.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-fix_column  = fu_fix.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_dyn_fcat TO gt_fieldcat_t.
    WHEN 'B'.
      APPEND ls_dyn_fcat TO gt_fieldcat_b.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_LOGIN
*&---------------------------------------------------------------------*
FORM f_login  USING    fu_uri fu_proxy.
  DATA : ls_request_header  LIKE LINE OF gt_request_header,
         ls_request_body    LIKE LINE OF gt_request_body,
         temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.

  ls_request_body-body = '{'.
  APPEND ls_request_body TO gt_request_body.
  ls_request_body-body = '"email": "gatot.pramono@thetempogroup.com",'.
  APPEND ls_request_body TO gt_request_body.
  ls_request_body-body = '"password": "Tempo_2020"'.
  APPEND ls_request_body TO gt_request_body.
  ls_request_body-body = '}'.
  APPEND ls_request_body TO gt_request_body.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 300
      proxy                       = fu_proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      system_failure              = 5
      communication_failure       = 6
      OTHERS                      = 7.

  IF sy-subrc = 0.
    LOOP AT gt_response_body INTO temp_json.
      CONDENSE : temp_json, lv_str.
      CONCATENATE lv_str temp_json INTO lv_str.
    ENDLOOP.

    writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
    TRY.
        CALL TRANSFORMATION id SOURCE XML lv_str
                               RESULT XML writer.
        xml = writer->get_output( ).
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
        WRITE: / 'Message Error JSON to XML: ', ls_var_text.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION zacc_login SOURCE XML xml
                                       RESULT role = gs_role.
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
    ENDTRY.
  ENDIF.

  gv_token = gs_role-token.
  IF gv_token IS INITIAL.
    gv_error = 1.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_LOGIN

*&---------------------------------------------------------------------*
*&      Form  F_JSON_FORMAT
*&---------------------------------------------------------------------*
FORM f_json_format  USING    fu_open fu_fname fu_value fu_nchar
                             fu_separated fu_condense fu_space fu_close.
  DATA : ls_request_body   LIKE LINE OF gt_request_body,
         lv_value(1000).

  IF fu_open IS NOT INITIAL.
    ls_request_body-body   = fu_open.
  ELSEIF fu_close IS NOT INITIAL.
    IF fu_separated IS INITIAL.
      ls_request_body-body   = fu_close.
    ELSE.
      CONCATENATE fu_close fu_separated INTO ls_request_body-body.
    ENDIF.
  ELSE.
    lv_value  = fu_value.
    IF fu_condense IS INITIAL.
      CONDENSE lv_value NO-GAPS.
    ENDIF.
    IF fu_nchar IS NOT INITIAL.
      CONCATENATE '"' fu_fname '":' lv_value fu_separated
      INTO ls_request_body-body.
    ELSEIF lv_value IS INITIAL.
      IF fu_space IS INITIAL.
        CONCATENATE '"' fu_fname '":"null"' fu_separated
        INTO ls_request_body-body.
      ELSE.
        CONCATENATE '"' fu_fname '":' fu_separated
        INTO ls_request_body-body.
      ENDIF.
    ELSEIF fu_fname IS INITIAL.
      CONCATENATE '"' lv_value '"' fu_separated
      INTO ls_request_body-body.
    ELSE.
      CONCATENATE '"' fu_fname '":"' lv_value '"' fu_separated
      INTO ls_request_body-body.
    ENDIF.
  ENDIF.
  APPEND ls_request_body TO gt_request_body.
  CLEAR ls_request_body.
ENDFORM.                    " F_JSON_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_http_post  USING    fu_uri fu_proxy fu_stbpom.
  DATA : lv_code(10),
         lv_text(100).

  IF gt_request_body[] IS NOT INITIAL.
    CALL FUNCTION 'HTTP_POST'
      EXPORTING
        absolute_uri               = fu_uri
        request_entity_body_length = 300
        proxy                      = fu_proxy
        blankstocrlf               = 'X'
      IMPORTING
        status_code                = lv_code
        status_text                = lv_text
      TABLES
        request_entity_body        = gt_request_body
        response_entity_body       = gt_response_body
        response_headers           = gt_response_header
        request_headers            = gt_request_header
      EXCEPTIONS
        connect_failed             = 1
        timeout                    = 2
        internal_error             = 3
        tcpip_error                = 4
        system_failure             = 5
        communication_failure      = 6
        OTHERS                     = 7.

    IF lv_code  = '200' AND
      lv_text = 'OK'.
      PERFORM f_modify_s501 USING fu_stbpom.
      MESSAGE s000(zab) WITH 'Data terkirim'.
    ELSE.
      MESSAGE s000(zab) WITH 'Error data post' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  CLEAR : gt_request_body[], gt_request_body,
          gt_response_body[], gt_response_body,
          gt_response_header[], gt_response_header,
          gt_request_header[] , gt_request_header.
ENDFORM.                    " F_HTTP_POST

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_GET
*&---------------------------------------------------------------------*
FORM f_http_get  USING    fu_uri fu_proxy.
  DATA : lv_uri(1000),
         temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_var_text        TYPE string.

  DATA : lt_xml    TYPE abap_trans_resbind_tab,
         ls_xml    TYPE abap_trans_resbind.

  CONCATENATE fu_uri gv_token INTO lv_uri.
  CLEAR : gt_request_body[], gt_response_body[],
          gt_response_header[], gt_request_header[].

  CALL FUNCTION 'HTTP_GET'
    EXPORTING
      absolute_uri                = lv_uri
      request_entity_body_length  = 300
      proxy                       = fu_proxy
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      data_error                  = 5
      system_failure              = 6
      communication_failure       = 7
      OTHERS                      = 8.

  IF sy-subrc = 0.
    LOOP AT gt_response_body INTO temp_json.
      CONDENSE : temp_json, lv_str.
      CONCATENATE lv_str temp_json INTO lv_str.
      REPLACE ALL OCCURRENCES OF REGEX '"badan_usaha":null' IN lv_str WITH '"badan_usaha":0'.
      REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '" "'.
    ENDLOOP.

    writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
    TRY.
        CALL TRANSFORMATION id SOURCE XML lv_str
                               RESULT XML writer.
        xml = writer->get_output( ).
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error JSON to XML: ', ls_var_text.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION zacc_sarana SOURCE XML xml
                                        RESULT sarana = gt_sarana.
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_HTTP_GET

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_S501
*&---------------------------------------------------------------------*
FORM f_modify_s501  USING    fu_stbpom.
  DATA : ls_s501      LIKE LINE OF gt_s501,
         ls_zaccdtd   LIKE LINE OF gt_zaccdtd,
         ls_zaccdtm   LIKE LINE OF gt_zaccdtm.

  LOOP AT gt_s501 INTO ls_s501.
    READ TABLE gt_zaccdtd INTO ls_zaccdtd
                          WITH KEY docat = ls_s501-docat
                                   docno = ls_s501-docno.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    IF radio6 IS NOT INITIAL.
      READ TABLE gt_zaccdtm INTO ls_zaccdtm
                            WITH KEY matnr = ls_s501-matnr
                                     charg = ls_s501-charg.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    TRY .
        UPDATE s501 SET stbpom = fu_stbpom
                    WHERE sptag = ls_s501-sptag
                      AND docat = ls_s501-docat
                      AND docno = ls_s501-docno
                      AND posnr = ls_s501-posnr.
      CATCH cx_sy_conversion_no_number.
    ENDTRY.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_S501

*&---------------------------------------------------------------------*
*&      Form  F_BARCODE_AGGREGATION
*&---------------------------------------------------------------------*
FORM f_barcode_aggregation .
  DATA : lt_zaccdta1          TYPE STANDARD TABLE OF zaccdta,
         lt_zaccdta2          TYPE STANDARD TABLE OF zaccdta,
         ls_zaccdta1          LIKE LINE OF gt_zaccdta,
         ls_zaccdta2          LIKE LINE OF gt_zaccdta,
         ls_zaccdta           LIKE LINE OF gt_zaccdta,
         ls_request_header    LIKE LINE OF gt_request_header.

  DATA : lv_lines             TYPE i,
         lv_times             TYPE i.

  DATA : ls_zaccdtu     LIKE LINE OF gt_zaccdtu,
         lv_uri5        TYPE zaccdtu-uri,
         lv_proxy5      TYPE zaccdtu-proxy,
         lv_uri11       TYPE zaccdtu-uri,
         lv_proxy11     TYPE zaccdtu-proxy.

  CLEAR ls_zaccdtu.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 5.
  IF sy-subrc = 0.
    lv_uri5    = ls_zaccdtu-uri.
    lv_proxy5  = ls_zaccdtu-proxy.
  ENDIF.
  CLEAR ls_zaccdtu.
  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = 11.
  IF sy-subrc = 0.
    lv_uri11    = ls_zaccdtu-uri.
    lv_proxy11  = ls_zaccdtu-proxy.
  ENDIF.

  lt_zaccdta1[] = gt_zaccdta[].
  SORT lt_zaccdta1 BY aggr1.
  DELETE ADJACENT DUPLICATES FROM lt_zaccdta1 COMPARING aggr1.
*  lt_zaccdta2[] = gt_zaccdta[].
*  SORT lt_zaccdta2 BY aggr2.
*  DELETE ADJACENT DUPLICATES FROM lt_zaccdta2 COMPARING aggr2.

  LOOP AT lt_zaccdta1 INTO ls_zaccdta1.
    CLEAR : lv_lines.
    LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = ls_zaccdta1-aggr1.
      ADD 1 TO lv_lines.
    ENDLOOP.

    lv_times  = lv_lines DIV co_lines.

    IF lv_lines = co_lines.
      lv_times  = 1.
    ELSE.
      lv_times  = lv_times + 1.
    ENDIF.

    DO lv_times TIMES.
      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.
      PERFORM f_create_json_35_1 USING ls_zaccdta1-aggr1
                                       lv_lines.
      PERFORM f_http_post USING lv_uri5 lv_proxy5 'X'.

      ls_request_header-header = 'Content-Type: application/json'.
      APPEND ls_request_header TO gt_request_header.
      PERFORM f_create_json_311_1 USING ls_zaccdta1-aggr1 ls_zaccdta1-packdat1
                                  CHANGING lv_lines.
      PERFORM f_http_post USING lv_uri11 lv_proxy11 'X'.
    ENDDO.
  ENDLOOP.

  LOOP AT lt_zaccdta2 INTO ls_zaccdta2.
    CLEAR : lv_lines.
    LOOP AT lt_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = ls_zaccdta2-aggr2.
      ADD 1 TO lv_lines.
    ENDLOOP.

    ls_request_header-header = 'Content-Type: application/json'.
    APPEND ls_request_header TO gt_request_header.
    PERFORM f_create_json_35_2 TABLES lt_zaccdta1
                               USING ls_zaccdta2-aggr2 lv_lines.
    PERFORM f_http_post USING lv_uri5 lv_proxy5 'X'.

    ls_request_header-header = 'Content-Type: application/json'.
    APPEND ls_request_header TO gt_request_header.
    PERFORM f_create_json_311_2 TABLES lt_zaccdta2
                                USING ls_zaccdta2-aggr2
                                      ls_zaccdta2-packdat2 lv_lines.
    PERFORM f_http_post USING lv_uri11 lv_proxy11 'X'.
  ENDLOOP.
ENDFORM.                    " F_BARCODE_AGGREGATION

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JSON_35_1
*&---------------------------------------------------------------------*
FORM f_create_json_35_1  USING    fu_aggr1 fu_lines.
  DATA : ls_zaccdta   LIKE LINE OF gt_zaccdta,
         ls_zaccdtm   LIKE LINE OF gt_zaccdtm.

  DATA : lv_count     TYPE i,
         lv_xlines    TYPE i,
         lv_barcode   TYPE string.

  PERFORM f_json_format USING :
    '{' '' '' '' '' '' '' '',
    '' 'token' gv_token '' ',' '' '' '',
    '' 'barcode' '' '' '' '' 'X' '',
    '[' '' '' '' '' '' '' ''.
  LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = fu_aggr1
                                       AND check = space.
    ADD 1 TO lv_count.
    IF lv_count > co_lines.
      lv_count = lv_count - 1.
      EXIT.
    ENDIF.

    IF fu_lines < co_lines.
      lv_xlines = fu_lines.
    ELSE.
      lv_xlines = co_lines.
    ENDIF.

    CLEAR ls_zaccdtm.
    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                          WITH KEY matnr = ls_zaccdta-matnr
                                   charg = ls_zaccdta-charg
                                   senum = ls_zaccdta-senum.

    PERFORM f_create_barcode USING ls_zaccdtm-nie
                                   ls_zaccdta-charg
                                   ls_zaccdtm-vfdat
                                   ls_zaccdta-senum
                             CHANGING lv_barcode.

    IF lv_count = lv_xlines.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' ',' '' '' ''.
    ENDIF.
  ENDLOOP.

  PERFORM f_create_barcode USING ls_zaccdtm-nie
                                 ls_zaccdtm-charg
                                 ls_zaccdtm-vfdat
                                 fu_aggr1
                           CHANGING lv_barcode.

  PERFORM f_json_format USING :
    '' '' '' '' ',' '' '' ']',
    '' 'is_active' 'true' 'X' ',' '' '' '',
    '' 'barcode_level' 'sekunder' '' ',' '' '' '',
    '' 'parent' lv_barcode '' '' '' '' '',
    '' '' '' '' '' '' '' '}'.
ENDFORM.                    " F_CREATE_JSON_35_1

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JSON_311_1
*&---------------------------------------------------------------------*
FORM f_create_json_311_1  USING    fu_aggr1 fu_packdat1
                          CHANGING fc_lines.
  DATA : ls_zaccdta   LIKE LINE OF gt_zaccdta.
  DATA : lv_count     TYPE i,
         lv_packdat1(10),
         lv_xlines    TYPE i.

  PERFORM f_json_format USING :
    '{' '' '' '' '' '' '' '',
    '' 'token' gv_token '' ',' '' '' '',
    '' 'parent' fu_aggr1 '' ',' '' '' '',
    '' 'latitude' '0' '' ',' '' '' '',
    '' 'longitude' '0' '' ',' '' '' '',
    '' 'parent_type' 'sekunder' '' ',' '' '' '',
    '' 'child' '' '' '' '' 'X' '',
    '[' '' '' '' '' '' '' ''.
  LOOP AT gt_zaccdta INTO ls_zaccdta WHERE aggr1 = fu_aggr1
                                       AND check = space.
    ADD 1 TO lv_count.
    IF lv_count > co_lines.
      lv_count = lv_count - 1.
      EXIT.
    ENDIF.

    IF fc_lines < co_lines.
      lv_xlines = fc_lines.
    ELSE.
      lv_xlines = co_lines.
    ENDIF.

    IF lv_count = lv_xlines.
      PERFORM f_json_format USING :
        '' '' ls_zaccdta-senum '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' ls_zaccdta-senum '' ',' '' '' ''.
    ENDIF.
    ls_zaccdta-check = 'X'.
    MODIFY gt_zaccdta FROM ls_zaccdta TRANSPORTING check.
  ENDLOOP.

  fc_lines  = fc_lines - lv_count.

  CONCATENATE fu_packdat1(4) '-'
              fu_packdat1+4(2) '-'
              fu_packdat1+6(2)
              INTO lv_packdat1.

  PERFORM f_json_format USING :
    '' '' '' '' ',' '' '' ']',
    '' 'packing_date' lv_packdat1 '' '' '' '' '',
    '' '' '' '' '' '' '' '}'.
ENDFORM.                    " F_CREATE_JSON_311_1

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JSON_35_2
*&---------------------------------------------------------------------*
FORM f_create_json_35_2  TABLES   ft_zaccdta1 STRUCTURE zaccdta
                         USING    fu_aggr2 fu_lines.
  DATA : ls_zaccdta1    LIKE LINE OF ft_zaccdta1,
         ls_zaccdtm     LIKE LINE OF gt_zaccdtm,
         lv_count       TYPE i,
         lv_barcode     TYPE string.

  PERFORM f_json_format USING :
    '{' '' '' '' '' '' '' '',
    '' 'token' gv_token '' ',' '' '' '',
    '' 'barcode' '' '' '' '' 'X' '',
    '[' '' '' '' '' '' '' ''.
  LOOP AT ft_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = fu_aggr2.
    ADD 1 TO lv_count.

    CLEAR ls_zaccdtm.
    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                          WITH KEY matnr = ls_zaccdta1-matnr
                                   charg = ls_zaccdta1-charg
                                   senum = ls_zaccdta1-senum.

    PERFORM f_create_barcode USING ls_zaccdtm-nie
                                   ls_zaccdta1-charg
                                   ls_zaccdtm-vfdat
                                   ls_zaccdta1-aggr1
                             CHANGING lv_barcode.

    IF lv_count = fu_lines.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' lv_barcode '' ',' '' '' ''.
    ENDIF.
  ENDLOOP.

  PERFORM f_create_barcode USING ls_zaccdtm-nie
                                 ls_zaccdtm-charg
                                 ls_zaccdtm-vfdat
                                 ls_zaccdta1-aggr2
                           CHANGING lv_barcode.

  PERFORM f_json_format USING :
    '' '' '' '' ',' '' '' ']',
    '' 'is_active' 'true' 'X' ',' '' '' '',
    '' 'barcode_level' 'tersier' '' ',' '' '' '',
    '' 'parent' fu_aggr2 '' '' '' '' '',
    '' '' '' '' '' '' '' '}'.
ENDFORM.                    " F_CREATE_JSON_35_2

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JSON_311_2
*&---------------------------------------------------------------------*
FORM f_create_json_311_2  TABLES   ft_zaccdta1 STRUCTURE zaccdta
                          USING    fu_aggr2 fu_packdat2 fu_lines.
  DATA : ls_zaccdta1    LIKE LINE OF ft_zaccdta1,
         lv_count       TYPE i,
         lv_packdat2(10).

  PERFORM f_json_format USING :
    '{' '' '' '' '' '' '' '',
    '' 'token' gv_token '' ',' '' '' '',
    '' 'parent' fu_aggr2 '' ',' '' '' '',
    '' 'latitude' '0' '' ',' '' '' '',
    '' 'longitude' '0' '' ',' '' '' '',
    '' 'parent_type' 'tersier' '' ',' '' '' '',
    '' 'child' '' '' '' '' 'X' '',
    '[' '' '' '' '' '' '' ''.
  LOOP AT ft_zaccdta1 INTO ls_zaccdta1 WHERE aggr2 = fu_aggr2.
    ADD 1 TO lv_count.
    IF lv_count = fu_lines.
      PERFORM f_json_format USING :
        '' '' ls_zaccdta1-aggr1 '' '' '' '' ''.
    ELSE.
      PERFORM f_json_format USING :
        '' '' ls_zaccdta1-aggr1 '' ',' '' '' ''.
    ENDIF.
  ENDLOOP.
  CONCATENATE fu_packdat2(4) '-'
              fu_packdat2+4(2) '-'
              fu_packdat2+6(2)
              INTO lv_packdat2.

  PERFORM f_json_format USING :
    '' '' '' '' ',' '' '' ']',
    '' 'packing_date' lv_packdat2 '' '' '' '' '',
    '' '' '' '' '' '' '' '}'.
ENDFORM.                    " F_CREATE_JSON_311_2

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BARCODE
*&---------------------------------------------------------------------*
FORM f_create_barcode  USING    fu_nie fu_charg fu_vfdat fu_senum
                       CHANGING fc_barcode.
  DATA : lv_vfdat(6).

  lv_vfdat  = fu_vfdat+2(6).

  CONCATENATE '90' fu_nie '\u001d' INTO fc_barcode.
  CONDENSE fc_barcode NO-GAPS.
  CONCATENATE fc_barcode '10' fu_charg '\u001d' INTO fc_barcode.
  CONDENSE fc_barcode NO-GAPS.
  CONCATENATE fc_barcode '17' lv_vfdat '21' fu_senum INTO fc_barcode.
  CONDENSE fc_barcode NO-GAPS.
ENDFORM.                    " F_CREATE_BARCODE
