*----------------------------------------------------------------------*
*   INCLUDE ZGDQM_R0010_V1F01                                          *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: l_datum_low(10),
        l_datum_high(10).

  ra_stprplan-low         = 'SS1'.
  ra_stprplan-high        = 'SS3'.
  ra_stprplan-sign        = 'I'.
  ra_stprplan-option      = 'BT'.
  APPEND ra_stprplan.

  CONCATENATE pa_werk '-' va_name1 INTO va_name1
    SEPARATED BY space.
  CONCATENATE pa_matnr '-' va_maktx INTO va_maktx
    SEPARATED BY space.

  IF so_datum IS INITIAL.
    va_period = space.
  ELSE.
    WRITE so_datum-low TO l_datum_low DD/MM/YYYY.
    WRITE so_datum-high TO l_datum_high DD/MM/YYYY.
    CONCATENATE l_datum_low '-' l_datum_high INTO va_period
      SEPARATED BY space.
  ENDIF.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  CASE 'X'.
    WHEN radio3.
      IF so_prue[] IS NOT INITIAL AND
        so_aufnr[] IS INITIAL AND
        so_erdat[] IS INITIAL.
        SELECT *
          FROM qals
          INTO CORRESPONDING FIELDS OF TABLE t_qals
          WHERE prueflos   IN so_prue       AND
                werk       EQ pa_werk       AND
                art        EQ pa_art        AND
                pastrterm  IN so_datum      AND
                matnr      EQ pa_matnr      AND
                charg      NE space.
      ELSE.
        SELECT *
          FROM caufv
          INTO CORRESPONDING FIELDS OF TABLE t_caufv
          WHERE aufnr  IN so_aufnr AND
                auart  LIKE 'Z%'   AND
                erdat  IN so_erdat AND
                gstrs  IN so_datum AND
                plnbez EQ pa_matnr.

        IF t_caufv[] IS NOT INITIAL.
          SELECT *
            FROM qals
            INTO CORRESPONDING FIELDS OF TABLE t_qals
            WHERE prueflos   IN so_prue       AND
                  werk       EQ pa_werk       AND
                  art        EQ pa_art        AND
                  pastrterm  IN so_datum      AND
                  matnr      EQ pa_matnr      AND
                  charg      NE space.
        ENDIF.

        SORT t_qals BY aufnr.
        SORT t_caufv BY aufnr.
        LOOP AT t_caufv.
          READ TABLE t_qals WITH KEY aufnr = t_caufv-aufnr
          BINARY SEARCH.
          IF sy-subrc NE 0.
            CLEAR: t_qals.
            t_qals1-aufnr    = t_caufv-aufnr.
            t_qals1-objnr    = t_caufv-objnr.
            APPEND t_qals1.
          ENDIF.
        ENDLOOP.
        IF t_qals1[] IS NOT INITIAL.
          APPEND LINES OF t_qals1 TO t_qals.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      SELECT *
        FROM qals
        INTO CORRESPONDING FIELDS OF TABLE t_qals
        WHERE prueflos   IN so_prue  AND
              werk       EQ pa_werk  AND
              art        EQ pa_art   AND
              matnr      EQ pa_matnr AND
              pastrterm  IN so_datum AND
              charg      NE space.
  ENDCASE.

  IF t_qals[] IS NOT INITIAL.
    SORT t_qals BY prueflos.
    t_charg[] = t_qals[].
    SORT t_charg BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM t_charg COMPARING matnr charg.

    IF radio1 EQ 'X' OR
      radio2 EQ 'X' OR
      radio4 EQ 'X'.
      t_lifnr[] = t_qals[].
      SORT t_lifnr BY lifnr.
      DELETE ADJACENT DUPLICATES FROM t_lifnr COMPARING lifnr.
      IF t_lifnr[] IS NOT INITIAL.
        SELECT *
          FROM lfa1
          INTO CORRESPONDING FIELDS OF TABLE t_lfa1
          FOR ALL ENTRIES IN t_lifnr
          WHERE lifnr EQ t_lifnr-lifnr.
      ENDIF.
    ENDIF.

*----- Get for Inspection Characteristic
    IF pa_art NE '04' AND pa_art NE 'Z04'.
      t_qals2[] = t_qals[].
      SORT t_qals2 BY plnty plnnr plnal.
      DELETE ADJACENT DUPLICATES FROM t_qals2 COMPARING plnty plnnr plnal.
      DELETE t_qals2 WHERE plnty EQ space AND
                           plnnr EQ space AND
                           plnal EQ space.

      IF t_qals2[] IS NOT INITIAL.
        SELECT *
          FROM plas
          INTO CORRESPONDING FIELDS OF TABLE t_plas
          FOR ALL ENTRIES IN t_qals2
          WHERE plnty EQ t_qals2-plnty AND
                plnnr EQ t_qals2-plnnr AND
                plnal EQ t_qals2-plnal AND
                loekz NE 'X'.
      ENDIF.

      IF t_plas[] IS NOT INITIAL.
        SORT t_plas BY plnty plnnr plnkn.
        DELETE ADJACENT DUPLICATES FROM t_plas COMPARING plnty plnnr plnkn.
        SELECT *
          FROM plmk
          INTO CORRESPONDING FIELDS OF TABLE t_plmk
          FOR ALL ENTRIES IN t_plas
          WHERE plnty EQ t_plas-plnty AND
                plnnr EQ t_plas-plnnr AND
                plnkn EQ t_plas-plnkn AND
                loekz NE 'X'.

        SELECT *
          FROM plpo
          INTO CORRESPONDING FIELDS OF TABLE t_plpo
          FOR ALL ENTRIES IN t_plas
          WHERE plnty EQ t_plas-plnty AND
                plnnr EQ t_plas-plnnr AND
                plnkn EQ t_plas-plnkn.

        SORT t_plmk BY plnty plnnr plnkn.
        SORT t_plpo BY plnty plnnr plnkn.
        LOOP AT t_plmk.
          READ TABLE t_plpo WITH KEY plnty = t_plmk-plnty
                                     plnnr = t_plmk-plnnr
                                     plnkn = t_plmk-plnkn
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_plmk-vornr = t_plpo-vornr.
            MODIFY t_plmk TRANSPORTING vornr.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
*-----

*----- Get for Specification PackMat
    IF radio2 EQ 'X'.
      IF t_plmk[] IS NOT INITIAL.
        t_stichprver[] = t_plmk[].
        SORT t_stichprver BY stichprver.
        DELETE ADJACENT DUPLICATES FROM t_stichprver COMPARING stichprver.
        IF t_stichprver[] IS NOT INITIAL.
          SELECT *
            FROM qdsv
            INTO CORRESPONDING FIELDS OF TABLE t_qdsv
            FOR ALL ENTRIES IN t_stichprver
            WHERE stichprver EQ t_stichprver-stichprver AND
                  stichprart EQ '300'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF t_qals[] IS NOT INITIAL.
      SELECT *
        FROM qamv
        INTO CORRESPONDING FIELDS OF TABLE t_qamv
        FOR ALL ENTRIES IN t_qals
        WHERE prueflos EQ t_qals-prueflos.
    ENDIF.

    IF t_qamv[] IS NOT INITIAL.
      IF radio2 EQ 'X'.
        SELECT *
          FROM qasv
          INTO CORRESPONDING FIELDS OF TABLE t_qasv
          FOR ALL ENTRIES IN t_qamv
          WHERE prueflos EQ t_qamv-prueflos AND
                vorglfnr EQ t_qamv-vorglfnr AND
                merknr   EQ t_qamv-merknr.
      ENDIF.

      SELECT *
        FROM qapp
        INTO CORRESPONDING FIELDS OF TABLE t_qapp
        FOR ALL ENTRIES IN t_qamv
          WHERE prueflos   EQ t_qamv-prueflos AND
                vorglfnr   EQ t_qamv-vorglfnr AND
                vbewertung NE space.

      SELECT *
        FROM qamr
        INTO CORRESPONDING FIELDS OF TABLE t_qamr
        FOR ALL ENTRIES IN t_qamv
        WHERE prueflos EQ t_qamv-prueflos AND
              vorglfnr EQ t_qamv-vorglfnr AND
              merknr   EQ t_qamv-merknr.

      SELECT *
        FROM qasr
        INTO CORRESPONDING FIELDS OF TABLE t_qasr
        FOR ALL ENTRIES IN t_qamv
        WHERE prueflos EQ t_qamv-prueflos AND
              vorglfnr EQ t_qamv-vorglfnr AND
              merknr   EQ t_qamv-merknr.

      SELECT *
        FROM qase
        INTO CORRESPONDING FIELDS OF TABLE t_qase
        FOR ALL ENTRIES IN t_qamv
        WHERE prueflos EQ t_qamv-prueflos AND
              vorglfnr EQ t_qamv-vorglfnr AND
              merknr   EQ t_qamv-merknr.
    ENDIF.

    IF t_charg[] IS NOT INITIAL.
      SELECT *
        FROM mch1
        INTO CORRESPONDING FIELDS OF TABLE t_mch1
        FOR ALL ENTRIES IN t_charg
        WHERE matnr EQ t_charg-matnr AND
              charg EQ t_charg-charg.
    ENDIF.

    IF t_qals[] IS NOT INITIAL.
      SELECT prueflos vdatum vkatart vcodegrp vcode
        FROM qave
        INTO CORRESPONDING FIELDS OF TABLE t_qave
        FOR ALL ENTRIES IN t_qals
        WHERE prueflos EQ t_qals-prueflos.
    ENDIF.

    CASE 'X'.
      WHEN radio2.
        SELECT *
          FROM qdpa
          INTO CORRESPONDING FIELDS OF TABLE t_qdpa
          WHERE stprplan IN ra_stprplan.

        t_mblnr[] = t_qals[].
        SORT t_mblnr BY mblnr.
        DELETE ADJACENT DUPLICATES FROM t_mblnr COMPARING mblnr.
        IF t_mblnr[] IS NOT INITIAL.
          SELECT mblnr erfmg erfme
            FROM mseg
            INTO CORRESPONDING FIELDS OF TABLE t_mseg
            FOR ALL ENTRIES IN t_mblnr
            WHERE mblnr EQ t_mblnr-mblnr.

          SELECT *
            FROM mkpf
            INTO CORRESPONDING FIELDS OF TABLE t_mkpf
            FOR ALL ENTRIES IN t_mblnr
            WHERE mblnr EQ t_mblnr-mblnr AND
                  mjahr EQ t_mblnr-mjahr.
        ENDIF.

      WHEN radio3.
        IF pa_art EQ '03'.
          IF t_qals[] IS NOT INITIAL.
            SELECT *
               FROM qals
               INTO CORRESPONDING FIELDS OF TABLE t_qals_04
               FOR ALL ENTRIES IN t_qals
               WHERE charg        EQ t_qals-charg AND
                     art          EQ '04'.
            IF t_qals_04[] IS NOT INITIAL.
              SELECT prueflos vdatum vkatart vcodegrp vcode
                FROM qave
                APPENDING CORRESPONDING FIELDS OF TABLE t_qave
                FOR ALL ENTRIES IN t_qals_04
                WHERE prueflos EQ t_qals_04-prueflos.
            ENDIF.
          ENDIF.
        ELSEIF pa_art EQ 'Z03'.
          IF t_qals[] IS NOT INITIAL.
            SELECT *
               FROM qals
               INTO CORRESPONDING FIELDS OF TABLE t_qals_04
               FOR ALL ENTRIES IN t_qals
               WHERE charg        EQ t_qals-charg AND
                     art          EQ 'Z04'.
            IF t_qals_04[] IS NOT INITIAL.
              SELECT prueflos vdatum vkatart vcodegrp vcode
                FROM qave
                APPENDING CORRESPONDING FIELDS OF TABLE t_qave
                FOR ALL ENTRIES IN t_qals_04
                WHERE prueflos EQ t_qals_04-prueflos.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_header.
  DATA: ld_count       TYPE i,
        ld_toleranzun  TYPE i,
        ld_toleranzob  TYPE i,
        ld_stprplan    LIKE qdpa-stprplan.

  CASE pa_art.
    WHEN '04' OR 'Z04'.
      SORT t_qamv BY verwmerkm kurztext masseinhsw.
      LOOP AT t_qamv.
        t_header-verwmerkm  = t_qamv-verwmerkm.
        t_header-kurztext   = t_qamv-kurztext.
        t_header-masseinhsw = t_qamv-masseinhsw.
        t_header-stellen    = t_qamv-stellen.
        t_header-sollwert   = t_qamv-sollwert.
        t_header-toleranzun = t_qamv-toleranzun.
        t_header-toleranzob = t_qamv-toleranzob.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamv-sollwert
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-sollwert_c.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamv-toleranzun
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzun_c.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamv-toleranzob
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzob_c.

        SHIFT t_header-sollwert_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.

        ld_toleranzun = STRLEN( t_header-toleranzun_c ).
        ld_toleranzob = STRLEN( t_header-toleranzob_c ).

        IF ld_toleranzun EQ 1 AND
          ld_toleranzob EQ 1.
          IF t_header-toleranzun_c(1) EQ '0' AND
            t_header-toleranzob_c(1) EQ '0'.
            CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
          ENDIF.
        ENDIF.

        IF t_qamv-masseinhsw IS INITIAL.
          IF radio3 EQ 'X'.
            IF pa_art EQ '04' OR pa_art EQ 'Z04'.
              t_header-result = t_qamv-kurztext.
            ELSE.
              t_header-result = t_qamv-dummy40.
            ENDIF.
          ELSE.
            t_header-result = t_qamv-dummy40.
          ENDIF.
        ENDIF.
        COLLECT t_header.
        CLEAR: t_header.
      ENDLOOP.

    WHEN OTHERS.
      IF ( pa_art = '01' OR pa_art = 'Z01' ) AND radio4 = 'X'.
        SORT t_qamv BY verwmerkm kurztext masseinhsw.
        LOOP AT t_qamv.
          t_header-verwmerkm  = t_qamv-verwmerkm.
          t_header-kurztext   = t_qamv-kurztext.
          t_header-masseinhsw = t_qamv-masseinhsw.
          t_header-stellen    = t_qamv-stellen.
          t_header-sollwert   = t_qamv-sollwert.
          t_header-toleranzun = t_qamv-toleranzun.
          t_header-toleranzob = t_qamv-toleranzob.

          IF t_qamv-masseinhsw IS NOT INITIAL.
            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_qamv-sollwert
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-sollwert_c.

            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_qamv-toleranzun
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-toleranzun_c.

            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_qamv-toleranzob
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-toleranzob_c.

            SHIFT t_header-sollwert_c LEFT DELETING LEADING space.
            SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
            SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.

            ld_toleranzun = STRLEN( t_header-toleranzun_c ).
            ld_toleranzob = STRLEN( t_header-toleranzob_c ).

            IF ld_toleranzun EQ 1 AND
              ld_toleranzob EQ 1.
              IF t_header-toleranzun_c(1) EQ '0' AND
                t_header-toleranzob_c(1) EQ '0'.
                CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
              ENDIF.
            ENDIF.
          ELSE.
            IF radio3 EQ 'X'.
              IF pa_art EQ '04' OR pa_art EQ 'Z04'.
                t_header-result = t_qamv-kurztext.
              ELSE.
                t_header-result = t_qamv-dummy40.
              ENDIF.
            ELSE.
              t_header-result = t_qamv-dummy40.
            ENDIF.
          ENDIF.
          IF radio4 = 'X'.
            READ TABLE t_header WITH KEY verwmerkm = t_qamv-verwmerkm
                                         masseinhsw = t_qamv-masseinhsw.
            IF sy-subrc = 0.
              CLEAR : t_header-toleranzun, t_header-toleranzob.
            ENDIF.
          ENDIF.
          COLLECT t_header.
          CLEAR: t_header.
        ENDLOOP.

      ELSE.
        SORT t_plmk BY vornr merknr verwmerkm kurztext masseinhsw.
        LOOP AT t_plmk.
*          IF radio3 EQ 'X'.
          t_header-vornr  = t_plmk-vornr.
          t_header-merknr = t_plmk-merknr.
*          ENDIF.

          t_header-verwmerkm  = t_plmk-verwmerkm.
          t_header-kurztext   = t_plmk-kurztext.
          t_header-masseinhsw = t_plmk-masseinhsw.
          t_header-stellen    = t_plmk-stellen.
          t_header-sollwert   = t_plmk-sollwert.
          t_header-toleranzun = t_plmk-toleranzun.
          t_header-toleranzob = t_plmk-toleranzob.

          IF t_plmk-masseinhsw IS NOT INITIAL.
            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_plmk-sollwert
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-sollwert_c.

            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_plmk-toleranzun
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-toleranzun_c.

            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input = t_plmk-toleranzob
                ivalu = 'X'
                decim = t_header-stellen
              IMPORTING
                flstr = t_header-toleranzob_c.

            SHIFT t_header-sollwert_c LEFT DELETING LEADING space.
            SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
            SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.

            ld_toleranzun = STRLEN( t_header-toleranzun_c ).
            ld_toleranzob = STRLEN( t_header-toleranzob_c ).

            IF ld_toleranzun EQ 1 AND
              ld_toleranzob EQ 1.
              IF t_header-toleranzun_c(1) EQ '0' AND
                t_header-toleranzob_c(1) EQ '0'.
                CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
              ENDIF.
            ENDIF.
          ELSE.
            IF radio3 EQ 'X'.
              IF pa_art EQ '04' OR pa_art EQ 'Z04'.
                t_header-result = t_plmk-kurztext.
              ELSE.
                t_header-result = t_plmk-dummy40.
              ENDIF.
            ELSE.
              t_header-result = t_plmk-dummy40.
            ENDIF.
          ENDIF.
          COLLECT t_header.
          CLEAR: t_header.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_process_header

*&---------------------------------------------------------------------*
*&      Form  f_process_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_detail.
  SORT t_qals BY prueflos.
  SORT t_qave BY prueflos.
  SORT t_qamr BY prueflos pruefdatuv.

  IF radio1 EQ 'X' OR radio4 EQ 'X'.
    IF t_qals[] IS NOT INITIAL.
      SELECT *
      FROM qcpr
      INTO CORRESPONDING FIELDS OF TABLE t_qcpr
      FOR ALL ENTRIES IN t_qals
      WHERE matnr EQ t_qals-matnr AND
            charg EQ t_qals-charg AND
            lichn EQ t_qals-lichn AND
            lifnr EQ t_qals-lifnr AND
            mblnr EQ t_qals-mblnr.
    ENDIF.
  ENDIF.

  LOOP AT t_qals.
    READ TABLE t_qamr WITH KEY prueflos = t_qals-prueflos
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      PERFORM f_write_date USING t_qamr-erstelldat
                           CHANGING t_vdata-ersteldat.
      PERFORM f_write_date USING t_qamr-pruefdatuv
                           CHANGING t_vdata-pruefdatuv.
    ENDIF.

    t_vdata-mblnr      = t_qals-mblnr.
    t_vdata-lichn      = t_qals-lichn.
    t_vdata-charg      = t_qals-charg.
    t_vdata-losmenge   = t_qals-losmenge.
    t_vdata-mengeneinh = t_qals-mengeneinh.
    t_vdata-lifnr      = t_qals-lifnr.
    t_vdata-anzgeb     = t_qals-anzgeb.
    t_vdata-prueflos   = t_qals-prueflos.
    t_vdata-paendterm  = t_qals-paendterm.
    t_vdata-lmenge01   = t_qals-lmenge01.
    t_vdata-lmenge03   = t_qals-lmenge03.
    t_vdata-lmenge04   = t_qals-lmenge04.
    t_vdata-lifnr      = t_qals-lifnr.
    t_vdata-gesstichpr = t_qals-gesstichpr.
    t_vdata-einhprobe  = t_qals-einhprobe.
    t_vdata-aufnr      = t_qals-aufnr.
    t_vdata-art        = t_qals-art.
    t_vdata-plnty      = t_qals-plnty.
    t_vdata-plnnr      = t_qals-plnnr.

    READ TABLE t_mch1 WITH KEY matnr = t_qals-matnr
                               charg = t_qals-charg.
    IF sy-subrc EQ 0.
      PERFORM f_write_date USING t_mch1-vfdat
                           CHANGING t_vdata-vfdat1.
      PERFORM f_write_date USING t_mch1-qndat
                           CHANGING t_vdata-qndat.
      PERFORM f_write_date USING t_mch1-hsdat
                           CHANGING t_vdata-hsdat.
    ENDIF.

    CASE 'X'.
      WHEN radio1 OR radio4.
        PERFORM f_process_radio1 USING t_mch1-cuobj_bm.

      WHEN radio2.
        PERFORM f_process_radio2.

      WHEN radio3.
        PERFORM f_process_radio3.
    ENDCASE.

    APPEND t_vdata.
    CLEAR: t_vdata.
  ENDLOOP.
ENDFORM.                    " f_process_detail

*&---------------------------------------------------------------------*
*&      Form  f_get_result
*&---------------------------------------------------------------------*
FORM f_get_result.
  DATA: ld_row     TYPE i,
        ld_column  TYPE i,
        ld_plnty   LIKE qals-plnty,
        ld_plnnr   LIKE qals-plnnr.

  DATA : insppoints	       TYPE STANDARD TABLE OF bapi2045l4.
  DATA : char_requirements TYPE STANDARD TABLE OF bapi2045d1.
  DATA : char_results	     TYPE STANDARD TABLE OF bapi2045d2,
         sample_results	   TYPE STANDARD TABLE OF bapi2045d3,
         single_results	   TYPE STANDARD TABLE OF bapi2045d4.
  DATA : lt_qpct           TYPE STANDARD TABLE OF qpct.

  SORT t_qamv BY prueflos vorglfnr merknr.
  SORT t_qamr BY prueflos vorglfnr merknr.
  SORT t_qasr BY prueflos vorglfnr merknr.
  SORT t_qase BY prueflos vorglfnr merknr.

  CASE 'X'.
    WHEN radio1.
      ld_row = 8.
    WHEN radio2.
      ld_row = 8.
    WHEN radio3.
      ld_row = 9.
      SORT t_vdata BY aufnr prueflos.
    WHEN radio4.
      ld_row = 8.
*      SORT t_vdata BY aufnr prueflos.
  ENDCASE.

  SELECT *
    FROM qpct
    INTO CORRESPONDING FIELDS OF TABLE lt_qpct.

  LOOP AT t_vdata.
    CASE 'X'.
      WHEN radio1.
        ld_column = 8.
      WHEN radio2.
        ld_column = 5.
      WHEN radio3.
        ld_column = 4.
      WHEN radio4.
        ld_column = 5.
    ENDCASE.

    ld_row = ld_row + 1.
    IF t_vdata-prueflos IS NOT INITIAL.
      CASE 'X'.
        WHEN radio3.
          SORT t_header BY vornr merknr verwmerkm kurztext masseinhsw.
          SORT t_plmk BY vornr merknr verwmerkm kurztext masseinhsw.
          LOOP AT t_header.
            ADD 1 TO ld_column.
            LOOP AT t_qamv WHERE prueflos   EQ t_vdata-prueflos    AND
                                 verwmerkm  EQ t_header-verwmerkm  AND
                                 kurztext   EQ t_header-kurztext   AND
                                 masseinhsw EQ t_header-masseinhsw.
              IF t_qamv-steuerkz+2(1) EQ 'X'.
                t_result-column = ld_column.
                t_result-row    = ld_row.
                PERFORM f_result_qualitative CHANGING t_result-result.
              ELSE.
                t_result-column = ld_column.
                t_result-row    = ld_row.
                PERFORM f_result_quantitative CHANGING t_result-result.
              ENDIF.
            ENDLOOP.
            IF sy-subrc EQ 0.
              t_result-prueflos = t_vdata-prueflos.
              APPEND t_result.
            ELSE.
              READ TABLE t_plmk WITH KEY verwmerkm  = t_header-verwmerkm
                                         kurztext   = t_header-kurztext
                                         masseinhsw = t_header-masseinhsw
              BINARY SEARCH.
              IF sy-subrc EQ 0.
                IF t_plmk-steuerkz+2(1) EQ 'X'.
                  t_result-column = ld_column.
                  t_result-row    = ld_row.
                  CLEAR: t_qamv-vorglfnr,  t_qamv-merknr.
                  PERFORM f_result_qualitative CHANGING t_result-result.
                ELSE.
                  t_result-column = ld_column.
                  t_result-row    = ld_row.
                  CLEAR: t_qamv-vorglfnr,  t_qamv-merknr.
                  PERFORM f_result_quantitative CHANGING t_result-result.
                ENDIF.
                t_result-prueflos = t_vdata-prueflos.
                APPEND t_result.
              ENDIF.
            ENDIF.
          ENDLOOP.

        WHEN OTHERS.
          SORT t_header BY kurztext masseinhsw.
          SORT t_plmk BY kurztext masseinhsw.
          LOOP AT t_header.
            ADD 1 TO ld_column.

            PERFORM f_get_simple_bapi USING t_vdata-prueflos t_header-vornr t_header-merknr
                                      CHANGING t_header-kurztext.

            LOOP AT t_qamv WHERE prueflos   EQ t_vdata-prueflos
                             AND kurztext   EQ t_header-kurztext
                             AND masseinhsw EQ t_header-masseinhsw
                             AND verwmerkm  EQ t_header-verwmerkm.
              IF t_qamv-steuerkz+2(1) EQ 'X'.
                t_result-column = ld_column.
                t_result-row    = ld_row.
                PERFORM f_result_qualitative CHANGING t_result-result.
              ELSE.
                t_result-column = ld_column.
                t_result-row    = ld_row.
                PERFORM f_result_quantitative CHANGING t_result-result.
              ENDIF.
            ENDLOOP.
            IF sy-subrc EQ 0.
              t_result-prueflos = t_vdata-prueflos.
              APPEND t_result.
            ELSE.
              READ TABLE t_plmk WITH KEY kurztext   = t_header-kurztext
                                         masseinhsw = t_header-masseinhsw
              BINARY SEARCH.
              IF sy-subrc EQ 0.
                IF t_plmk-steuerkz+2(1) EQ 'X'.
                  t_result-column = ld_column.
                  t_result-row    = ld_row.
                  CLEAR: t_qamv-vorglfnr,  t_qamv-merknr.
                  PERFORM f_result_qualitative CHANGING t_result-result.
                ELSE.
                  t_result-column = ld_column.
                  t_result-row    = ld_row.
                  CLEAR: t_qamv-vorglfnr,  t_qamv-merknr.
                  PERFORM f_result_quantitative CHANGING t_result-result.
                ENDIF.
                t_result-prueflos = t_vdata-prueflos.
                APPEND t_result.
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_get_result

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio1.
      doc_classname  = 'ZRAWMAT'.
      doc_classtype  = 'OT'.
      doc_object_key = 'ZOBJECT'.

    WHEN radio2.
      doc_classname  = 'ZPACKMAT'.
      doc_classtype  = 'OT'.
      doc_object_key = 'ZOBJECT'.

    WHEN radio3.
      doc_classname  = 'ZINPROCESS'.
      doc_classtype  = 'OT'.
      doc_object_key = 'ZOBJECT'.

    WHEN radio4.
      doc_classname  = 'ZSFGFG'.
      doc_classtype  = 'OT'.
      doc_object_key = 'ZOBJECT'.
  ENDCASE.
  CALL SCREEN 100.
ENDFORM.                    " f_print_data

*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CASE 'X'.
    WHEN radio1 OR radio4.
      SET PF-STATUS '101'.
    WHEN radio2.
      SET PF-STATUS '102'.
    WHEN radio3.
      SET PF-STATUS '103'.
  ENDCASE.
ENDMODULE.                 " status_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  create_spreadsheet_interface  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_spreadsheet_interface OUTPUT.
  IF is_output IS INITIAL.
    PERFORM start_server USING 'Hatch cat'.
  ENDIF.
ENDMODULE.                 " create_spreadsheet_interface  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  formatting_output  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE formatting_output OUTPUT.

  REFRESH: contents, rangesdef.

  PERFORM formatting_contents_header.

  DESCRIBE TABLE t_header LINES va_lines.

  CASE 'X'.
    WHEN radio1.
      va_lines = va_lines + 9.
      PERFORM f_output_rm USING va_lines.

    WHEN radio2.
      va_lines = va_lines + 6.
      PERFORM f_output_pm USING va_lines.

    WHEN radio3.
      va_lines = va_lines + 5.
      PERFORM f_output_fg USING va_lines.

    WHEN radio4.
      va_lines = va_lines + 6.
      PERFORM f_output_pofg USING va_lines.
  ENDCASE.

  PERFORM formatting_rangesdef_tab.
  PERFORM replace_word.
  PERFORM format_sheet.
  PERFORM close_server.
ENDMODULE.                 " formatting_output  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LC_TABIX  text
*----------------------------------------------------------------------*
FORM formatting_contents_vdata USING fc_col1 fc_col2 fc_col3
                                     fc_col4 fc_col5 fc_col6
                                     fc_col7 fc_col8 fc_col9
                                     fc_col10
                               CHANGING fc_row.
  DATA: ld_count   TYPE i,
        ld_column  TYPE i.

  PERFORM f_zebra CHANGING fc_row.

  CASE 'X'.
    WHEN radio1.
      PERFORM set_content USING 1 fc_row t_vdata-mblnr.
      PERFORM set_content_date USING 2 fc_row t_vdata-budat.
      PERFORM set_content USING 3 fc_row t_vdata-lichn.
      PERFORM set_content USING 4 fc_row t_vdata-charg.
      PERFORM set_content USING 5 fc_row t_vdata-name1.
      PERFORM set_content USING 6 fc_row t_vdata-prueflos.
      PERFORM set_content USING 7 fc_row t_vdata-ktextlos.
      PERFORM set_content USING 8 fc_row t_vdata-status.
      PERFORM f_print_result.
      PERFORM set_content_uom USING fc_col1 fc_row t_vdata-losmenge t_vdata-mengeneinh.
      PERFORM set_content USING fc_col2 fc_row t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col3 fc_row t_vdata-vfdat1.
      PERFORM set_content_date USING fc_col4 fc_row t_vdata-qndat.
      PERFORM set_content USING fc_col5 fc_row t_vdata-anzgeb.
      PERFORM set_content_date USING fc_col6 fc_row t_vdata-pruefdatuv.
      PERFORM set_content_uom USING fc_col7 fc_row t_vdata-lmenge01 t_vdata-mengeneinh.
      PERFORM set_content_uom USING fc_col8 fc_row t_vdata-lmenge04 t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col9 fc_row t_vdata-vdatum1.
      PERFORM set_content USING fc_col10 fc_row t_vdata-udstat.

    WHEN radio2.
      PERFORM set_content USING 1 fc_row t_vdata-mblnr.
      PERFORM set_content_date USING 2 fc_row t_vdata-budat1.
      PERFORM set_content USING 3 fc_row t_vdata-charg.
      PERFORM set_content USING 4 fc_row t_vdata-name1.
      PERFORM set_content USING 5 fc_row t_vdata-prueflos.
      PERFORM f_print_result.
      PERFORM set_content_date USING fc_col1 fc_row t_vdata-qndat.
      PERFORM set_content_uom USING fc_col2 fc_row t_vdata-losmenge t_vdata-mengeneinh. "t_vdata-gesstichpr t_vdata-einhprobe.
      PERFORM set_content USING fc_col3 fc_row t_vdata-einhprobe.
      PERFORM set_content_date USING fc_col4 fc_row t_vdata-pruefdatuv.
      PERFORM set_content_uom USING fc_col5 fc_row t_vdata-lmenge01 t_vdata-mengeneinh.
      PERFORM set_content_uom USING fc_col6 fc_row t_vdata-lmenge03 t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col7 fc_row t_vdata-vdatum1.
      PERFORM set_content USING fc_col8 fc_row t_vdata-udstat.

    WHEN radio3.
      PERFORM set_content USING 1 fc_row t_vdata-aufnr.
      IF t_vdata-prueflos IS NOT INITIAL.
        PERFORM set_content USING 2 fc_row t_vdata-prueflos.
      ENDIF.
      PERFORM set_content USING 3 fc_row t_vdata-charg.
      PERFORM set_content USING 4 fc_row t_vdata-art.
      PERFORM f_print_result.
      PERFORM set_content_date USING fc_col1 fc_row t_vdata-hsdat.
      PERFORM set_content_uom USING fc_col2 fc_row t_vdata-losmenge t_vdata-mengeneinh.
      PERFORM set_content USING fc_col3 fc_row t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col4 fc_row t_vdata-vdatum1.
      PERFORM set_content_date USING fc_col5 fc_row t_vdata-vdatum2.
      PERFORM set_content_date USING fc_col6 fc_row t_vdata-ersteldat.
      PERFORM set_content_date USING fc_col7 fc_row t_vdata-vfdat1.
      PERFORM set_content USING fc_col8 fc_row t_vdata-udstat.

    WHEN radio4.
      PERFORM set_content USING 1 fc_row t_vdata-mblnr.
      PERFORM set_content_date USING 2 fc_row t_vdata-budat.
      PERFORM set_content USING 3 fc_row t_vdata-charg.
      PERFORM set_content USING 4 fc_row t_vdata-name1.
      PERFORM set_content USING 5 fc_row t_vdata-prueflos.
      PERFORM f_print_result.
      PERFORM set_content_uom USING fc_col1 fc_row t_vdata-losmenge t_vdata-mengeneinh.
      PERFORM set_content USING fc_col2 fc_row t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col3 fc_row t_vdata-vfdat1.
*      PERFORM set_content_date USING fc_col4 fc_row t_vdata-qndat.
*      PERFORM set_content USING fc_col5 fc_row t_vdata-anzgeb.
      PERFORM set_content_date USING fc_col4 fc_row t_vdata-pruefdatuv.
      PERFORM set_content_uom USING fc_col5 fc_row t_vdata-lmenge01 t_vdata-mengeneinh.
      PERFORM set_content_uom USING fc_col6 fc_row t_vdata-lmenge04 t_vdata-mengeneinh.
      PERFORM set_content_date USING fc_col7 fc_row t_vdata-vdatum1.
      PERFORM set_content USING fc_col8 fc_row t_vdata-udstat.

  ENDCASE.
ENDFORM.                    " formatting_contents_tab

*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " user_command_0100  INPUT

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
  REFRESH: t_qals, t_caufv, t_qals1, t_qals2, t_plas, t_plpo, t_stichprver, t_qdsv,
           t_qals_04, t_charg, t_mblnr, t_mseg, t_mkpf, t_mch1, t_qdpa, t_qave,
           t_qasv, t_qapp, t_qamr, t_qasr, t_qase, t_qcpr, t_qamv. ", t_plmk.
  CLEAR: t_qals, t_caufv, t_qals1, t_qals2, t_plas, t_plpo, t_stichprver, t_qdsv,
         t_qals_04, t_charg, t_mblnr, t_mseg, t_mkpf, t_mch1, t_qdpa, t_qave,
         t_qasv, t_qapp, t_qamr, t_qasr, t_qase, t_qcpr, t_qamv. ", t_plmk.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  format_sheet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_sheet.
  CALL METHOD document->execute_macro
    EXPORTING
      macro_string = 'Module1.RowColorSeaGreen'
      no_flush     = no_flush
    IMPORTING
      error        = error
      retcode      = retcode.

  CALL METHOD document->execute_macro
    EXPORTING
      macro_string = 'Module1.Protect_Cells'
      no_flush     = no_flush
    IMPORTING
      error        = error
      retcode      = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

*  CALL METHOD document->delete_menu_item
*    EXPORTING
*      no_flush        = no_flush
*      item_name       = 'Protection'
*      menu_popup_name = 'Tools'
*    IMPORTING
*      error           = error
*      retcode         = retcode.
*  CALL METHOD c_oi_errors=>show_message
*    EXPORTING
*      type = 'E'.
*
*  CALL METHOD document->delete_menu_item
*    EXPORTING
*      no_flush        = no_flush
*      item_name       = 'Macro'
*      menu_popup_name = 'Tools'
*    IMPORTING
*      error           = error
*      retcode         = retcode.
*  CALL METHOD c_oi_errors=>show_message
*    EXPORTING
*      type = 'E'.
*
*  CALL METHOD document->delete_menu_item
*    EXPORTING
*      no_flush        = no_flush
*      item_name       = 'Save Copy As...'
*      menu_popup_name = 'File'
*    IMPORTING
*      error           = error
*      retcode         = retcode.
*  CALL METHOD c_oi_errors=>show_message
*    EXPORTING
*      type = 'E'.
*
*  CALL METHOD document->delete_menu_item
*    EXPORTING
*      no_flush        = no_flush
*      item_name       = 'Save as Web Page...'
*      menu_popup_name = 'File'
*    IMPORTING
*      error           = error
*      retcode         = retcode.
*  CALL METHOD c_oi_errors=>show_message
*    EXPORTING
*      type = 'E'.
ENDFORM.                    " format_sheet

*&---------------------------------------------------------------------*
*&      Module  status_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS '101'.
ENDMODULE.                 " status_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LC_TABIX  text
*----------------------------------------------------------------------*
FORM formatting_contents_header.
  PERFORM set_content USING 2 3 va_name1.
  PERFORM set_content USING 2 4 va_maktx.
  PERFORM set_content USING 2 5 va_period.
ENDFORM.                    " formatting_contents_header

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_spec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM formatting_contents_kurztext CHANGING fc_row
                                           fc_column.
  PERFORM set_content USING fc_column fc_row t_header-kurztext.
ENDFORM.                    " formatting_contents_spec

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_desc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ROW1  text
*      <--P_L_COLUMN1  text
*----------------------------------------------------------------------*
FORM formatting_contents_verwmerkm CHANGING fc_row1
                                            fc_column1.
  PERFORM set_content USING fc_column1 fc_row1 t_header-verwmerkm.
ENDFORM.                    " formatting_contents_desc

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ROW  text
*      <--P_L_COLUMN  text
*----------------------------------------------------------------------*
FORM formatting_contents_specific CHANGING fc_row2
                                           fc_column2.
  PERFORM set_content USING fc_column2 fc_row2 t_header-result.
ENDFORM.                    " formatting_contents_result

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000.
  CASE 'X'.
    WHEN radio3.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-group1 = 'AUF'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_modify_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000.
  DATA: ld_mess(50) VALUE 'Make an entry in all required fields',
        ld_art  LIKE tq30-art.

  IF pa_werk IS INITIAL.
    va_error  = 1.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'WRK'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ELSE.
    CLEAR: va_error.
  ENDIF.

  IF pa_matnr IS INITIAL.
    va_error  = 1.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'MAT'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ELSE.
    CLEAR: va_error.
  ENDIF.

  IF pa_art IS INITIAL.
    va_error  = 1.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'QLA'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ELSE.
    SELECT SINGLE art
      FROM tq30
      INTO ld_art
      WHERE art EQ pa_art.
    IF sy-subrc EQ 0.
      CLEAR: va_error.
    ELSE.
      va_error  = 1.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'QLA'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      MESSAGE e000(zab) WITH 'Inspection Type error'.
      CLEAR: sscrfields-ucomm.
    ENDIF.
  ENDIF.

  IF va_error IS INITIAL.
    LOOP AT SCREEN.
      screen-input  = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'C144_MATERIAL_PLANT_CHECK_EXT'
    EXPORTING
      i_matnr               = pa_matnr
      i_plant               = pa_werk
      i_langu               = sy-langu
    IMPORTING
      e_matnam              = va_maktx
      e_plantnam            = va_name1
    EXCEPTIONS
      material_not_found    = 1
      plant_not_found       = 2
      material_not_in_plant = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CASE 'X'.
      WHEN radio1.
        IF pa_matnr(1) NE 'R' AND
          pa_matnr(2) NE 'I3'.
          CONCATENATE 'Material' pa_matnr 'is not Raw Materials'
          INTO va_message
          SEPARATED BY space.
          MESSAGE e000(zab) WITH va_message.
        ENDIF.
      WHEN radio2.
        IF pa_matnr(1) NE 'P' AND
          pa_matnr(1) NP '0123456789'.
          CONCATENATE 'Material' pa_matnr 'is not Pack Materials'
            INTO va_message
            SEPARATED BY space.
          MESSAGE e000(zab) WITH va_message.
        ENDIF.
      WHEN radio3.
        IF pa_matnr(1) CO 'PR' OR
          pa_matnr(2) EQ 'I3'.
          CONCATENATE 'Material' pa_matnr 'is not Finished Goods'
            INTO va_message
            SEPARATED BY space.
          MESSAGE e000(zab) WITH va_message.
        ENDIF.
      WHEN radio4.
        IF pa_matnr(1) CO 'PR' OR
          pa_matnr(2) EQ 'I3'.
          CONCATENATE 'Material' pa_matnr 'is not SFG/FG'
          INTO va_message
          SEPARATED BY space.
          MESSAGE e000(zab) WITH va_message.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_output_rm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_rm USING fd_lines.
  DATA: ld_row      TYPE i VALUE 7,
        ld_column   TYPE i VALUE 8,
        ld_row1     TYPE i VALUE 8,
        ld_column1  TYPE i VALUE 8,
        ld_count    TYPE i,
        ld_col1     TYPE i,
        ld_col2     TYPE i,
        ld_col3     TYPE i,
        ld_col4     TYPE i,
        ld_col5     TYPE i,
        ld_col6     TYPE i,
        ld_col7     TYPE i,
        ld_col8     TYPE i,
        ld_col9     TYPE i,
        ld_col10    TYPE i.

  DO 10 TIMES.
    ADD 1 TO ld_count.
    CASE ld_count.
      WHEN 1.
        ld_col1 = fd_lines.
      WHEN 2.
        ld_col2 = fd_lines.
      WHEN 3.
        ld_col3 = fd_lines.
      WHEN 4.
        ld_col4 = fd_lines.
      WHEN 5.
        ld_col5 = fd_lines.
      WHEN 6.
        ld_col6 = fd_lines.
      WHEN 7.
        ld_col7 = fd_lines.
      WHEN 8.
        ld_col8 = fd_lines.
      WHEN 9.
        ld_col9 = fd_lines.
      WHEN 10.
        ld_col10 = fd_lines.
    ENDCASE.
    ADD 1 TO fd_lines.
  ENDDO.

* Header
  PERFORM set_content USING 1 8 'Mat. Doc.'.
  PERFORM set_content USING 2 8 'Doc. Date'.
  PERFORM set_content USING 3 8 'Vendor Batch'.
  PERFORM set_content USING 4 8 'Batch'.
  PERFORM set_content USING 5 8 'Vendor Name'.
  PERFORM set_content USING 6 8 'Insp. Lot'.
  PERFORM set_content USING 7 8 'Manufacture'.
  PERFORM set_content USING 8 8 'Status CoA'.
  PERFORM set_content USING ld_col1 8 'Insp. Lot Qty'.
  PERFORM set_content USING ld_col2 8 'UOM'.
  PERFORM set_content USING ld_col3 8 'SLED/BBD'.
  PERFORM set_content USING ld_col4 8 'Date of reanalysis'.
  PERFORM set_content USING ld_col5 8 'No.Of Containers'.
  PERFORM set_content USING ld_col6 8 'Analysis Date'.
  PERFORM set_content USING ld_col7 8 'Un restricted use'.
  PERFORM set_content USING ld_col8 8 'Block Status'.
  PERFORM set_content USING ld_col9 8 'UD Date'.
  PERFORM set_content USING ld_col10 8 'UD Status'.

  LOOP AT t_header.
    IF sy-tabix GT 239.
      EXIT.
    ENDIF.

    ADD 1 TO ld_column.
    ADD 1 TO ld_column1.
    IF t_header-masseinhsw IS NOT INITIAL.
      CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c t_header-masseinhsw
      INTO t_header-result
      SEPARATED BY space.
    ELSE.
      IF t_header-result IS INITIAL.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_header-toleranzun
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzun_c.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_header-toleranzob
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzob_c.

        SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.
        IF t_header-toleranzun_c(1) EQ '0' AND
          t_header-toleranzob_c(1) EQ '0'.
          CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
        ENDIF.

        IF t_header-toleranzun_c IS NOT INITIAL AND
          t_header-toleranzob_c IS NOT INITIAL.
          CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c
          INTO t_header-result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM formatting_contents_kurztext CHANGING ld_row
                                                  ld_column.
    PERFORM formatting_contents_specific CHANGING ld_row1
                                                  ld_column1.
  ENDLOOP.

  IF is_output IS INITIAL.
    is_output = 'X'.
    CLEAR: columns_number.
    ld_row = 8.
    LOOP AT t_vdata.
      ld_row = ld_row + 1.
      PERFORM formatting_contents_vdata USING ld_col1 ld_col2 ld_col3
                                              ld_col4 ld_col5 ld_col6
                                              ld_col7 ld_col8 ld_col9
                                              ld_col10
                                        CHANGING ld_row.
      count = 1.
    ENDLOOP.
    ld_row = ld_row - 8.
  ENDIF.
ENDFORM.                    " f_output_rm

*&---------------------------------------------------------------------*
*&      Form  f_output_rm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_pm USING fd_lines.
  DATA: ld_row      TYPE i VALUE 7,
        ld_column   TYPE i VALUE 5,
        ld_row1     TYPE i VALUE 8,
        ld_column1  TYPE i VALUE 5,
        ld_count    TYPE i,
        ld_col1     TYPE i,
        ld_col2     TYPE i,
        ld_col3     TYPE i,
        ld_col4     TYPE i,
        ld_col5     TYPE i,
        ld_col6     TYPE i,
        ld_col7     TYPE i,
        ld_col8     TYPE i.

  DO 8 TIMES.
    ADD 1 TO ld_count.
    CASE ld_count.
      WHEN 1.
        ld_col1 = fd_lines.
      WHEN 2.
        ld_col2 = fd_lines.
      WHEN 3.
        ld_col3 = fd_lines.
      WHEN 4.
        ld_col4 = fd_lines.
      WHEN 5.
        ld_col5 = fd_lines.
      WHEN 6.
        ld_col6 = fd_lines.
      WHEN 7.
        ld_col7 = fd_lines.
      WHEN 8.
        ld_col8 = fd_lines.
    ENDCASE.
    ADD 1 TO fd_lines.
  ENDDO.

* Header
  PERFORM set_content USING 1 8 'Mat. Doc.'.
  PERFORM set_content USING 2 8 'Doc.Date'.
  PERFORM set_content USING 3 8 'Batch'.
  PERFORM set_content USING 4 8 'Vendor Name'.
  PERFORM set_content USING 5 8 'Insp. Lot'.
  PERFORM set_content USING ld_col1 8 'Date of reanalysis'.
  PERFORM set_content USING ld_col2 8 'Insp. Lot Qty'.
  PERFORM set_content USING ld_col3 8 'UOM'.
  PERFORM set_content USING ld_col4 8 'Analysis Date'.
  PERFORM set_content USING ld_col5 8 'Un restricted use'.
  PERFORM set_content USING ld_col6 8 'Block Status'.
  PERFORM set_content USING ld_col7 8 'UD Date'.
  PERFORM set_content USING ld_col8 8 'UD Status'.

  LOOP AT t_header.
    IF sy-tabix GT 243.
      EXIT.
    ENDIF.

    ADD 1 TO ld_column.
    ADD 1 TO ld_column1.
    IF t_header-masseinhsw IS NOT INITIAL.
      CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c t_header-masseinhsw
      INTO t_header-result
      SEPARATED BY space.
    ELSE.
      IF t_header-result IS INITIAL.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_header-toleranzun
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzun_c.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_header-toleranzob
            ivalu = 'X'
            decim = t_header-stellen
          IMPORTING
            flstr = t_header-toleranzob_c.

        SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.
        IF t_header-toleranzun_c(1) EQ '0' AND
          t_header-toleranzob_c(1) EQ '0'.
          CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
        ENDIF.

        IF t_header-toleranzun_c IS NOT INITIAL AND
          t_header-toleranzob_c IS NOT INITIAL.
          CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c
          INTO t_header-result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM formatting_contents_kurztext CHANGING ld_row
                                                  ld_column.
    PERFORM formatting_contents_specific CHANGING ld_row1
                                                  ld_column1.
  ENDLOOP.

  IF is_output IS INITIAL.
    is_output = 'X'.
    CLEAR: columns_number.
    ld_row = 8.
    LOOP AT t_vdata.
      ld_row = ld_row + 1.
      PERFORM formatting_contents_vdata USING ld_col1 ld_col2 ld_col3
                                              ld_col4 ld_col5 ld_col6
                                              ld_col7 ld_col8 space space
                                        CHANGING ld_row.
      count = 1.
    ENDLOOP.
    ld_row = ld_row - 8.
  ENDIF.
ENDFORM.                    " f_output_pm

*&---------------------------------------------------------------------*
*&      Form  f_output_fg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_fg USING fd_lines.
  DATA: ld_row      TYPE i VALUE 7,
        ld_column   TYPE i VALUE 4,
        ld_row1     TYPE i VALUE 8,
        ld_column1  TYPE i VALUE 4,
        ld_row2     TYPE i VALUE 9,
        ld_column2  TYPE i VALUE 4,
        ld_value(20),
        ld_count    TYPE i,
        ld_col1     TYPE i,
        ld_col2     TYPE i,
        ld_col3     TYPE i,
        ld_col4     TYPE i,
        ld_col5     TYPE i,
        ld_col6     TYPE i,
        ld_col7     TYPE i,
        ld_col8     TYPE i.

  DO 8 TIMES.
    ADD 1 TO ld_count.
    CASE ld_count.
      WHEN 1.
        ld_col1 = fd_lines.
      WHEN 2.
        ld_col2 = fd_lines.
      WHEN 3.
        ld_col3 = fd_lines.
      WHEN 4.
        ld_col4 = fd_lines.
      WHEN 5.
        ld_col5 = fd_lines.
      WHEN 6.
        ld_col6 = fd_lines.
      WHEN 7.
        ld_col7 = fd_lines.
      WHEN 8.
        ld_col8 = fd_lines.
    ENDCASE.
    ADD 1 TO fd_lines.
  ENDDO.

* Header
  PERFORM set_content USING 1 8 'Order'.
  PERFORM set_content_date USING 2 8 'Insp. Lot'.
  PERFORM set_content USING 3 8 'Batch'.
  PERFORM set_content USING 4 8 'InspType'.
  PERFORM set_content USING ld_col1 8 'Manuf. Dte'.
  PERFORM set_content USING ld_col2 8 'Insp. Lot Qty'.
  PERFORM set_content USING ld_col3 8 'UOM'.
  PERFORM set_content USING ld_col4 8 'IPC UD Date'.
  PERFORM set_content USING ld_col5 8 'FGC UD Date'.
  PERFORM set_content USING ld_col6 8 'Result Rec. Date'.
  PERFORM set_content USING ld_col7 8 'SLED/BBD'.
  PERFORM set_content USING ld_col8 8 'UD Status'.

  CASE 'X'.
    WHEN radio3.
      SORT t_header BY vornr merknr verwmerkm kurztext.
    WHEN OTHERS.
      SORT t_header BY verwmerkm kurztext.
  ENDCASE.

  LOOP AT t_header.
    IF sy-tabix GT 246.
      EXIT.
    ENDIF.
    ADD 1 TO ld_column.
    ADD 1 TO ld_column1.
    ADD 1 TO ld_column2.

    IF t_header-masseinhsw IS NOT INITIAL.
      IF t_header-toleranzun_c IS NOT INITIAL AND
        t_header-toleranzob_c IS NOT INITIAL.
        CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c t_header-masseinhsw
        INTO t_header-result
        SEPARATED BY space.
      ELSE.
        CONCATENATE t_header-sollwert_c t_header-masseinhsw
        INTO t_header-result
        SEPARATED BY space.
      ENDIF.
    ELSE.
      IF t_header-result IS INITIAL.
* Koreksi untuk proses 1 tahun
*        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
*          EXPORTING
*            input = t_header-toleranzun
*            ivalu = 'X'
*            decim = t_header-stellen
*          IMPORTING
*            flstr = t_header-toleranzun_c.
*
*        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
*          EXPORTING
*            input = t_header-toleranzob
*            ivalu = 'X'
*            decim = t_header-stellen
*          IMPORTING
*            flstr = t_header-toleranzob_c.

        READ TABLE t_plmk WITH KEY vornr      = t_header-vornr
                                   merknr     = t_header-merknr
                                   verwmerkm  = t_header-verwmerkm.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
            EXPORTING
              input = t_plmk-toleranzun
              ivalu = 'X'
              decim = t_header-stellen
            IMPORTING
              flstr = t_header-toleranzun_c.

          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
            EXPORTING
              input = t_plmk-toleranzob
              ivalu = 'X'
              decim = t_header-stellen
            IMPORTING
              flstr = t_header-toleranzob_c.
        ENDIF.

        SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.
        IF t_header-toleranzun_c(1) EQ '0' AND
          t_header-toleranzob_c(1) EQ '0'.
          CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
        ENDIF.

        IF t_header-toleranzun_c IS NOT INITIAL AND
          t_header-toleranzob_c IS NOT INITIAL.
          CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c
          INTO t_header-result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM formatting_contents_kurztext CHANGING ld_row
                                                  ld_column.
    PERFORM formatting_contents_specific CHANGING ld_row1
                                                  ld_column1.
    PERFORM formatting_contents_verwmerkm CHANGING ld_row2
                                                   ld_column2.
  ENDLOOP.

* Detail
  IF is_output IS INITIAL.
    is_output = 'X'.
    CLEAR: columns_number.
    ld_row = 9.
    SORT t_vdata BY aufnr prueflos.
    LOOP AT t_vdata.
      ld_row = ld_row + 1.
      PERFORM formatting_contents_vdata USING ld_col1 ld_col2 ld_col3
                                              ld_col4 ld_col5 ld_col6
                                              ld_col7 ld_col8 space space
                                        CHANGING ld_row.
      count = 1.
    ENDLOOP.
    ld_row = ld_row - 9.
  ENDIF.
ENDFORM.                    " f_output_fg

*&---------------------------------------------------------------------*
*&      Form  f_output_pofg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_pofg USING fd_lines.
  DATA: ld_row      TYPE i VALUE 7,
        ld_column   TYPE i VALUE 5,
        ld_row1     TYPE i VALUE 8,
        ld_column1  TYPE i VALUE 5,
        ld_count    TYPE i,
        ld_col1     TYPE i,
        ld_col2     TYPE i,
        ld_col3     TYPE i,
        ld_col4     TYPE i,
        ld_col5     TYPE i,
        ld_col6     TYPE i,
        ld_col7     TYPE i,
        ld_col8     TYPE i,
        ld_col9     TYPE i,
        ld_col10    TYPE i.

  DO 8 TIMES.
    ADD 1 TO ld_count.
    CASE ld_count.
      WHEN 1.
        ld_col1 = fd_lines.
      WHEN 2.
        ld_col2 = fd_lines.
      WHEN 3.
        ld_col3 = fd_lines.
      WHEN 4.
        ld_col4 = fd_lines.
      WHEN 5.
        ld_col5 = fd_lines.
      WHEN 6.
        ld_col6 = fd_lines.
      WHEN 7.
        ld_col7 = fd_lines.
      WHEN 8.
        ld_col8 = fd_lines.
    ENDCASE.
    ADD 1 TO fd_lines.
  ENDDO.

* Header
  PERFORM set_content USING 1 8 'Mat. Doc.'.
  PERFORM set_content USING 2 8 'Doc. Date'.
  PERFORM set_content USING 3 8 'Batch'.
  PERFORM set_content USING 4 8 'Vendor Name'.
  PERFORM set_content USING 5 8 'Insp. Lot'.
  PERFORM set_content USING ld_col1 8 'Insp. Lot Qty'.
  PERFORM set_content USING ld_col2 8 'UOM'.
  PERFORM set_content USING ld_col3 8 'SLED/BBD'.
  PERFORM set_content USING ld_col4 8 'Result Rec. Date'.
  PERFORM set_content USING ld_col5 8 'Un restricted use'.
  PERFORM set_content USING ld_col6 8 'Block Status'.
  PERFORM set_content USING ld_col7 8 'UD Date'.
  PERFORM set_content USING ld_col8 8 'UD Status'.

  LOOP AT t_header.
    IF sy-tabix GT 239.
      EXIT.
    ENDIF.

    ADD 1 TO ld_column.
    ADD 1 TO ld_column1.
    IF t_header-masseinhsw IS NOT INITIAL.
      CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c t_header-masseinhsw
      INTO t_header-result
      SEPARATED BY space.
    ELSE.
      IF t_header-result IS INITIAL.
        IF t_header-toleranzun_c IS INITIAL.
          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
            EXPORTING
              input = t_header-toleranzun
              ivalu = 'X'
              decim = t_header-stellen
            IMPORTING
              flstr = t_header-toleranzun_c.
        ENDIF.

        IF t_header-toleranzob_c IS INITIAL.
          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
            EXPORTING
              input = t_header-toleranzob
              ivalu = 'X'
              decim = t_header-stellen
            IMPORTING
              flstr = t_header-toleranzob_c.
        ENDIF.

        SHIFT t_header-toleranzun_c LEFT DELETING LEADING space.
        SHIFT t_header-toleranzob_c LEFT DELETING LEADING space.
        IF t_header-toleranzun_c(1) EQ '0' AND
          t_header-toleranzob_c(1) EQ '0'.
          CLEAR: t_header-toleranzun_c, t_header-toleranzob_c.
        ENDIF.

        IF t_header-toleranzun_c IS NOT INITIAL AND
          t_header-toleranzob_c IS NOT INITIAL.
          CONCATENATE t_header-toleranzun_c '-' t_header-toleranzob_c
          INTO t_header-result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM formatting_contents_kurztext CHANGING ld_row
                                                  ld_column.
    PERFORM formatting_contents_specific CHANGING ld_row1
                                                  ld_column1.
  ENDLOOP.

  IF is_output IS INITIAL.
    is_output = 'X'.
    CLEAR: columns_number.
    ld_row = 8.
    LOOP AT t_vdata.
      ld_row = ld_row + 1.
      PERFORM formatting_contents_vdata USING ld_col1 ld_col2 ld_col3
                                              ld_col4 ld_col5 ld_col6
                                              ld_col7 ld_col8 space
                                              space
                                        CHANGING ld_row.
      count = 1.
    ENDLOOP.
    ld_row = ld_row - 8.
  ENDIF.
ENDFORM.                    " f_output_pofg

*&---------------------------------------------------------------------*
*&      Form  f_write_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VA_DATE  text
*----------------------------------------------------------------------*
FORM f_write_date USING fc_dtin
                  CHANGING fc_dtout.
  IF fc_dtin IS INITIAL.
    CLEAR: fc_dtout.
  ELSE.
    WRITE fc_dtin TO fc_dtout DD/MM/YYYY.
  ENDIF.
ENDFORM.                    " f_write_date

*&---------------------------------------------------------------------*
*&      Form  f_process_radio1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_radio1 USING fu_objek.
  DATA: ld_line  LIKE bsvx-sttxt.
  DATA: ld_name   LIKE thead-tdname,
        ld_len    TYPE i,
        ld_total  TYPE i.
  DATA: lv_atinn  TYPE ausp-atinn.

  DATA: BEGIN OF lt_lines OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF lt_lines.

  IF t_qals-ktextlos IS NOT INITIAL.
    IF t_qals-ltextkz EQ 'X'.
      CONCATENATE sy-mandt t_vdata-prueflos INTO ld_name.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id       = 'QALS'
          language = sy-langu
          name     = ld_name
          object   = 'QPRUEFLOS'
        TABLES
          lines    = lt_lines.
      IF sy-subrc EQ 0.
        LOOP AT lt_lines.
          IF ld_total GT 105.
            EXIT.
          ELSE.
            ld_len = STRLEN( lt_lines-tdline ).
            ADD ld_len TO ld_total.
            CONCATENATE t_vdata-ktextlos lt_lines-tdline INTO t_vdata-ktextlos
            SEPARATED BY space.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      t_vdata-ktextlos = t_qals-ktextlos.
    ENDIF.
  ENDIF.

  IF pa_werk = '0401'.
    CLEAR lv_atinn.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input  = 'ZMF'
      IMPORTING
        output = lv_atinn.

    SELECT SINGLE atwrt
      FROM ausp
      INTO t_vdata-ktextlos
      WHERE objek = fu_objek
        AND atinn = lv_atinn.
  ENDIF.

  CALL FUNCTION 'STATUS_TEXT_EDIT'
    EXPORTING
      client           = sy-mandt
      objnr            = t_qals-objnr
      only_active      = 'X'
      spras            = sy-langu
    IMPORTING
      line             = ld_line
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE t_lfa1 WITH KEY lifnr = t_qals-lifnr.
  IF sy-subrc EQ 0.
    t_vdata-name1 = t_lfa1-name1.
  ENDIF.

  READ TABLE t_qcpr WITH KEY matnr = t_qals-matnr
                             charg = t_qals-charg
                             lichn = t_qals-lichn
                             lifnr = t_qals-lifnr
                             mblnr = t_qals-mblnr.
  IF sy-subrc EQ 0.
    SELECT SINGLE ddtext
      FROM dd07t
      INTO t_vdata-status
      WHERE domname EQ 'QCSTATUS'  AND
            ddlanguage EQ sy-langu AND
            as4local   EQ 'A'      AND
            valpos     EQ t_qcpr-status.
  ENDIF.

  PERFORM f_write_date USING t_qals-budat
                       CHANGING t_vdata-budat.

  READ TABLE t_qave WITH KEY prueflos = t_qals-prueflos
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    PERFORM f_write_date USING t_qave-vdatum
                         CHANGING t_vdata-vdatum1.

    SELECT SINGLE kurztext
      FROM qpct
      INTO t_vdata-udstat
      WHERE katalogart EQ t_qave-vkatart   AND
            codegruppe EQ t_qave-vcodegrp  AND
            code       EQ t_qave-vcode     AND
            sprache    EQ sy-langu.
  ENDIF.
ENDFORM.                    " f_process_radio1

*&---------------------------------------------------------------------*
*&      Form  f_process_radio2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_radio2.
  READ TABLE t_qave WITH KEY prueflos = t_qals-prueflos
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    PERFORM f_write_date USING t_qave-vdatum
                         CHANGING t_vdata-vdatum1.

    SELECT SINGLE kurztext
      FROM qpct
      INTO t_vdata-udstat
      WHERE katalogart EQ t_qave-vkatart   AND
            codegruppe EQ t_qave-vcodegrp  AND
            code       EQ t_qave-vcode     AND
            sprache    EQ sy-langu.
  ENDIF.

  READ TABLE t_lfa1 WITH KEY lifnr = t_qals-lifnr.
  IF sy-subrc EQ 0.
    t_vdata-name1 = t_lfa1-name1.
  ENDIF.

  READ TABLE t_mseg WITH KEY mblnr = t_qals-mblnr.
  IF sy-subrc EQ 0.
    t_vdata-erfmg = t_mseg-erfmg.
    t_vdata-erfme = t_mseg-erfme.
  ENDIF.

  PERFORM f_write_date USING t_qals-budat
                       CHANGING t_vdata-budat1.

  READ TABLE t_mkpf WITH KEY mblnr = t_qals-mblnr
                             mjahr = t_qals-mjahr.
  IF sy-subrc EQ 0.
    PERFORM f_write_date USING t_mkpf-budat
                         CHANGING t_vdata-budat.
  ENDIF.
ENDFORM.                    " f_process_radio2

*&---------------------------------------------------------------------*
*&      Form  f_process_radio3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_radio3.
  DATA: ld_vdatum(10).

  READ TABLE t_qave WITH KEY prueflos = t_qals-prueflos
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    PERFORM f_write_date USING t_qave-vdatum
                         CHANGING ld_vdatum.

    SELECT SINGLE kurztext
      FROM qpct
      INTO t_vdata-udstat
      WHERE katalogart EQ t_qave-vkatart   AND
            codegruppe EQ t_qave-vcodegrp  AND
            code       EQ t_qave-vcode     AND
            sprache    EQ sy-langu.
  ENDIF.

  CASE pa_art.
    WHEN '04'.
      t_vdata-vdatum1 = space.
      t_vdata-vdatum2 = ld_vdatum.
    WHEN OTHERS.
      READ TABLE t_qals_04 WITH KEY charg = t_qals-charg.
      IF sy-subrc EQ 0.
        READ TABLE t_qave WITH KEY prueflos = t_qals_04-prueflos.
        IF sy-subrc EQ 0.
          PERFORM f_write_date USING t_qave-vdatum
                               CHANGING t_vdata-vdatum2.
        ENDIF.
      ENDIF.
      t_vdata-vdatum1 = ld_vdatum.
  ENDCASE.
ENDFORM.                    " f_process_radio3

*&---------------------------------------------------------------------*
*&      Form  f_zebra
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_zebra CHANGING fd_row.
  IF va_switch EQ 0.
    va_switch = 1.
    CALL METHOD document->execute_macro
      EXPORTING
        macro_string = 'Module1.RowColorLightYellow'
        no_flush     = no_flush
        param1       = fd_row
        param_count  = 1
      IMPORTING
        error        = error
        retcode      = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ELSE.
    va_switch = 0.
    CALL METHOD document->execute_macro
      EXPORTING
        macro_string = 'Module1.RowColorTan'
        no_flush     = no_flush
        param1       = fd_row
        param_count  = 1
      IMPORTING
        error        = error
        retcode      = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ENDIF.
ENDFORM.                    " f_zebra

*&---------------------------------------------------------------------*
*&      Form  f_print_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_result.
  LOOP AT t_result WHERE prueflos EQ t_vdata-prueflos.
    PERFORM set_content USING t_result-column t_result-row t_result-result.
  ENDLOOP.
ENDFORM.                    " f_print_result

*&---------------------------------------------------------------------*
*&      Form  f_result_qualitative
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--FT_RESULT_RESULT  text
*----------------------------------------------------------------------*
FORM f_result_qualitative CHANGING ft_result.
  DATA: ld_case TYPE i.

*  ft_result = 'Ql'.

  CASE 'X'.
    WHEN radio1 OR radio4.
      ld_case  = 1.
    WHEN radio2.
      ld_case  = 2.
    WHEN radio3.
      ld_case  = 3.
  ENDCASE.

  CLEAR: ft_result.

  CALL FUNCTION 'ZQ_QUALITATIVE_RESULT'
    EXPORTING
      prueflos   = t_qamv-prueflos
      vorglfnr   = t_qamv-vorglfnr
      merknr     = t_qamv-merknr
      stichprver = t_qamv-stichprver
      case       = ld_case
    IMPORTING
      RESULT     = ft_result
    TABLES
      t_qdsv     = t_qdsv
      t_qamr     = t_qamr
      t_qase     = t_qase
      t_qasr     = t_qasr
      t_qapp     = t_qapp.
ENDFORM.                    " f_result_qualitative

*&---------------------------------------------------------------------*
*&      Form  f_result_quantitative
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--FT_RESULT  text
*----------------------------------------------------------------------*
FORM f_result_quantitative CHANGING ft_result.
  DATA: ld_case TYPE i.

*  ft_result = 'Qn'.

  CASE 'X'.
    WHEN radio1 OR radio4.
      ld_case  = 1.
    WHEN radio2.
      ld_case  = 2.
    WHEN radio3.
      ld_case  = 3.
  ENDCASE.

  CLEAR: ft_result.

  CALL FUNCTION 'ZQ_QUANTITATIVE_RESULT'
    EXPORTING
      prueflos = t_qamv-prueflos
      vorglfnr = t_qamv-vorglfnr
      merknr   = t_qamv-merknr
      stellen  = t_qamv-stellen
      case     = ld_case
    IMPORTING
      RESULT   = ft_result
    TABLES
      t_qamr   = t_qamr
      t_qase   = t_qase
      t_qasr   = t_qasr
      t_qapp   = t_qapp.
ENDFORM.                    " f_result_quantitative

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_bapi_get_detail  TABLES   insppoints	       STRUCTURE bapi2045l4
                                 char_requirements STRUCTURE bapi2045d1
                                 char_results	     STRUCTURE bapi2045d2
                                 sample_results	   STRUCTURE bapi2045d3
                                 single_results	   STRUCTURE bapi2045d4
                                 ft_qpct           STRUCTURE qpct
                        USING    fu_prueflos fu_vornr fu_merknr fu_verwmerkm
                                 fu_col fu_row.
*                        CHANGING fc_kurztext.

  DATA : inspoper_list    TYPE STANDARD TABLE OF bapi2045l2,
         ls_list          LIKE LINE OF inspoper_list,
         ls_qpct          TYPE qpct.

  CLEAR : char_requirements[], char_results[], sample_results[], single_results[].

  CALL FUNCTION 'BAPI_INSPLOT_GETOPERATIONS'
    EXPORTING
      number        = fu_prueflos
    TABLES
      inspoper_list = inspoper_list.

  LOOP AT inspoper_list INTO ls_list.
    CALL FUNCTION 'BAPI_INSPOPER_GETDETAIL'
      EXPORTING
        insplot                = fu_prueflos
        inspoper               = ls_list-inspoper
        read_insppoints        = 'X'
        read_char_requirements = 'X'
        read_char_results      = 'X'
        read_sample_results    = 'X'
        read_single_results    = 'X'
      TABLES
        insppoints             = insppoints
        char_requirements      = char_requirements
        char_results           = char_results
        sample_results         = sample_results
        single_results         = single_results.

    IF sy-subrc EQ 0.
      READ TABLE char_requirements WITH KEY mstr_char = fu_verwmerkm.
      IF sy-subrc = 0.
        CASE char_requirements-char_type.
          WHEN '01'.
            READ TABLE char_results WITH KEY inspchar = char_requirements-inspchar.
            IF sy-subrc = 0.
              t_result-result = char_results-mean_value.
            ENDIF.
          WHEN '02'.
            READ TABLE char_results WITH KEY inspchar = char_requirements-inspchar.
            IF sy-subrc = 0.
              CLEAR ls_qpct.
              READ TABLE ft_qpct INTO ls_qpct
                                 WITH KEY codegruppe = char_results-code_grp1
                                          code       = char_results-code1.
              IF sy-subrc = 0.
                t_result-result = ls_qpct-kurztext.
              ENDIF.
            ENDIF.
        ENDCASE.

        t_result-prueflos = fu_prueflos.
        t_result-column   = fu_col.
        t_result-row      = fu_row.
        APPEND t_result.
        CLEAR t_result.
        EXIT.
      ENDIF.

*    READ TABLE char_requirements WITH KEY insplot  = fu_prueflos
*                                          inspoper = fu_vornr
*                                          inspchar = fu_merknr.
*    IF sy-subrc EQ 0.
*      fc_kurztext = char_requirements-char_descr.
*    ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_RESULT_WITH_BAPI
*&---------------------------------------------------------------------*
FORM f_result_with_bapi .
  DATA: ld_row     TYPE i,
        ld_column  TYPE i,
        ld_plnty   LIKE qals-plnty,
        ld_plnnr   LIKE qals-plnnr.

  DATA : insppoints	       TYPE STANDARD TABLE OF bapi2045l4.
  DATA : char_requirements TYPE STANDARD TABLE OF bapi2045d1.
  DATA : char_results	     TYPE STANDARD TABLE OF bapi2045d2,
         sample_results	   TYPE STANDARD TABLE OF bapi2045d3,
         single_results	   TYPE STANDARD TABLE OF bapi2045d4.
  DATA : lt_qpct           TYPE STANDARD TABLE OF qpct.

  SORT t_qamv BY prueflos vorglfnr merknr.
  SORT t_qamr BY prueflos vorglfnr merknr.
  SORT t_qasr BY prueflos vorglfnr merknr.
  SORT t_qase BY prueflos vorglfnr merknr.

  CASE 'X'.
    WHEN radio1.
      ld_row = 8.
    WHEN radio2.
      ld_row = 8.
    WHEN radio3.
      ld_row = 9.
      SORT t_vdata BY aufnr prueflos.
    WHEN radio4.
      ld_row = 8.
*      SORT t_vdata BY aufnr prueflos.
  ENDCASE.

  SELECT *
    FROM qpct
    INTO CORRESPONDING FIELDS OF TABLE lt_qpct.

  LOOP AT t_vdata.
    CASE 'X'.
      WHEN radio1.
        ld_column = 8.
      WHEN radio2.
        ld_column = 5.
      WHEN radio3.
        ld_column = 4.
      WHEN radio4.
        ld_column = 5.
    ENDCASE.

    ld_row = ld_row + 1.
    IF t_vdata-prueflos IS NOT INITIAL.
      SORT t_header BY kurztext masseinhsw.
      SORT t_plmk BY kurztext masseinhsw.
      LOOP AT t_header.
        ADD 1 TO ld_column.
        PERFORM f_bapi_get_detail TABLES insppoints
                                         char_requirements
                                         char_results
                                         sample_results
                                         single_results
                                         lt_qpct
                                  USING t_vdata-prueflos t_header-vornr t_header-merknr
                                        t_header-verwmerkm ld_column ld_row.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_RESULT_WITH_BAPI

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIMPLE_BAPI
*&---------------------------------------------------------------------*
FORM f_get_simple_bapi  USING    fu_prueflos fu_vornr fu_merknr
                        CHANGING fc_kurztext.
  DATA : char_requirements  TYPE STANDARD TABLE OF bapi2045d1,
         ls_requirements    LIKE LINE OF char_requirements.

  CALL FUNCTION 'BAPI_INSPOPER_GETDETAIL'
    EXPORTING
      insplot                = fu_prueflos
      inspoper               = fu_vornr
      read_char_requirements = 'X'
    TABLES
      char_requirements      = char_requirements.

  IF sy-subrc EQ 0.
    READ TABLE char_requirements INTO ls_requirements
                                 WITH KEY insplot  = fu_prueflos
                                          inspoper = fu_vornr
                                          inspchar = fu_merknr.
    IF sy-subrc EQ 0.
      fc_kurztext = ls_requirements-char_descr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_SIMPLE_BAPI
