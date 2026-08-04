*----------------------------------------------------------------------*
*   INCLUDE ZXVBZU02                                                   *
*----------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(X_BNCOM) LIKE  BNCOM STRUCTURE  BNCOM OPTIONAL
*"       CHANGING
*"             VALUE(NEW_CHARG)
*"       EXCEPTIONS
*"              CANCELLED
*"----------------------------------------------------------------------

TABLES: zgdppdt0002, zgdppdt0003.
DATA : d_gstrp LIKE caufvd-gstrp,
       d_verid LIKE afpod-verid,
       d_charg(3) TYPE n,
       zbatch LIKE indx-srtfd VALUE 'ZBATCH',
       d_exist,
       ld_zmoncov(1),
       ld_zyeacov(2),
       ld_gstrp LIKE caufvd-gstrp,
       ld_gstrp2 TYPE char20,
       d_error  TYPE i.
FIELD-SYMBOLS: <fs_gltrp> TYPE caufvd-gltrp.

*GET PARAMETER ID 'M_GSTRP' FIELD d_gstrp.
GET PARAMETER ID 'M_GLTRP' FIELD d_gstrp.
GET PARAMETER ID 'M_VERID' FIELD d_verid.

****************************************************************
* Begin Code, Get New Batch number for KMM, plant 3600 and company code 8360
* iway 25.11.2013
****************************************************************
DATA: BEGIN OF lv_caufv,
        aufnr LIKE caufv-aufnr,
        auart LIKE caufv-auart,
        bukrs LIKE caufv-bukrs,
        werks LIKE caufv-werks,
        gstrp LIKE caufv-gstrp,
        aufpl LIKE caufv-aufpl,
        plgrp LIKE caufv-plgrp,
      END OF lv_caufv.

DATA: BEGIN OF lv_afvc,
        aufpl LIKE afvc-aufpl,
        aplzl LIKE afvc-aplzl,
        vornr LIKE afvc-vornr,
        arbid LIKE afvc-arbid,
      END OF lv_afvc.

DATA: BEGIN OF lv_crhd,
        objty LIKE crhd-objty,
        objid LIKE crhd-objid,
        arbpl LIKE crhd-arbpl,
        veran LIKE crhd-veran,
      END OF lv_crhd.

DATA: BEGIN OF lv_t001w,
        werks LIKE t001w-werks,
        bwkey LIKE t001w-bwkey,
      END OF lv_t001w.

DATA: BEGIN OF lv_t001k,
        bwkey LIKE t001k-bwkey,
        bukrs LIKE t001k-bukrs,
      END OF lv_t001k.

DATA: BEGIN OF lv_plpo,
        plnty LIKE plpo-plnty,
        plnnr LIKE plpo-plnnr,
        plnkn LIKE plpo-plnkn,
        arbid LIKE plpo-arbid,
      END OF lv_plpo.

DATA: BEGIN OF li_mapl OCCURS 0,
        matnr TYPE mapl-matnr,
        werks TYPE mapl-werks,
        plnty TYPE mapl-plnty,
        plnnr TYPE mapl-plnnr,
        plnal TYPE mapl-plnal,
        zkriz TYPE mapl-zkriz,
        zaehl TYPE mapl-zaehl,
        datuv TYPE mapl-datuv,
      END OF li_mapl.

DATA: lv_gstrp TYPE co_gstrp,
      lv_gltrp TYPE co_gltrs,
      lv_matnr TYPE matnr,
      lv_charg_r TYPE charg_d,
      lv_werks TYPE werks_d,
      lv_fevor TYPE fevor,
      lv_plgrp  TYPE caufv-plgrp,
      lv_period TYPE buper,
      lv_flag_create_batch(1). "flag create batch

DATA: lv_id(12) TYPE c,
      lv_session(32) TYPE c.
FIELD-SYMBOLS : <fs_field>.
DATA: lv_string  TYPE string.

DATA : lv_charg   TYPE mch1-charg,
       lv_kzkup   TYPE marc-kzkup.

IF x_bncom-werks IS NOT INITIAL.
  SELECT SINGLE werks bwkey INTO CORRESPONDING FIELDS OF lv_t001w
    FROM t001w
    WHERE werks EQ x_bncom-werks.
  IF sy-subrc EQ 0.
    SELECT SINGLE bwkey bukrs INTO CORRESPONDING FIELDS OF lv_t001k
      FROM t001k
      WHERE bwkey EQ lv_t001w-bwkey.
  ENDIF.
ENDIF.
*break sol_wayan.

break tds_dev01.

CASE lv_t001k-bukrs.
* TNP
  WHEN '8040'.
    IF x_bncom-werks EQ '0401' AND
      x_bncom-auart EQ 'ZN01' OR x_bncom-auart EQ 'ZN03'.
      SELECT matnr werks plnty plnnr plnal zkriz zaehl datuv
        FROM mapl
        INTO TABLE li_mapl
        WHERE matnr = x_bncom-matnr
        AND   werks = x_bncom-werks
        ORDER BY matnr werks plnty plnnr plnal zkriz zaehl datuv DESCENDING.
      IF li_mapl[] IS NOT INITIAL.
        READ TABLE li_mapl INDEX 1.
        IF sy-subrc EQ 0.
          SELECT SINGLE plnty plnnr plnkn arbid
            FROM plpo
            INTO CORRESPONDING FIELDS OF lv_plpo
            WHERE plnty = li_mapl-plnty
            AND   plnnr = li_mapl-plnnr
            AND   arbid <> ''.
          IF sy-subrc EQ 0.
            SELECT SINGLE objty objid arbpl veran
              FROM crhd
              INTO CORRESPONDING FIELDS OF lv_crhd
              WHERE objty EQ 'A'
              AND   objid EQ lv_plpo-arbid.
            IF sy-subrc EQ 0.
              CALL FUNCTION 'TH_GET_SESSION_ID'
                IMPORTING
                  session_id = lv_session.
              IF sy-subrc EQ 0.
                CONCATENATE 'TNP' lv_session(8) INTO lv_id.
              ELSE.
                lv_id = 'TNP'.
              ENDIF.

              IMPORT gltrp = lv_gltrp
                     gstrp = lv_gstrp
                     matnr = lv_matnr
                     werks = lv_werks
                     charg = lv_charg_r
                     fevor = lv_fevor
                     plgrp = lv_plgrp
                     FROM MEMORY ID lv_id.

              IF lv_gstrp IS NOT INITIAL.
                lv_period = lv_gstrp(6).
              ELSEIF lv_gltrp IS NOT INITIAL.
                lv_period = lv_gltrp(6).
              ENDIF.

              IF x_bncom-auart EQ 'ZN03' AND x_bncom-matnr EQ lv_matnr AND lv_charg_r IS NOT INITIAL.
                CONCATENATE lv_charg_r '_' INTO new_charg.
              ELSE.
                IF lv_period IS INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                  SELECT SINGLE aufnr auart bukrs werks gstrp aufpl plgrp
                    FROM caufv
                    INTO CORRESPONDING FIELDS OF lv_caufv
                    WHERE aufnr EQ x_bncom-aufnr
                    AND   auart EQ 'ZN01'.
                  IF sy-subrc EQ 0.
                    lv_period = lv_caufv-gstrp.
                  ENDIF.
                ENDIF.

                CHECK lv_period IS NOT INITIAL AND x_bncom-aufnr IS NOT INITIAL.

                CALL FUNCTION 'ZFM_NEW_BATCH_TNP_FG'
                  EXPORTING
                    p_matnr  = x_bncom-matnr
                    p_werks  = x_bncom-werks
                    p_aufnr  = x_bncom-aufnr
                    p_period = lv_period
                    p_veran  = lv_crhd-veran
                    p_plgrp  = lv_plgrp
                  IMPORTING
                    p_charg  = new_charg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  WHEN '8330'.
* "Kondisi untuk PLI - PLI - PP-E01 By Suk 19.02.2016
    IF ( x_bncom-werks EQ '3302' OR x_bncom-werks EQ '3301' ) AND  "PLI
       ( x_bncom-auart EQ 'ZP22' OR x_bncom-auart EQ 'ZP21' OR x_bncom-auart EQ 'ZP11').
      SELECT matnr werks plnty plnnr plnal zkriz zaehl datuv
        INTO TABLE li_mapl
        FROM mapl
        WHERE matnr EQ x_bncom-matnr
        AND   werks EQ x_bncom-werks
        ORDER BY matnr werks plnty plnnr plnal zkriz zaehl datuv DESCENDING.

      IF li_mapl[] IS NOT INITIAL.

        READ TABLE li_mapl INDEX 1.
        IF sy-subrc EQ 0.

          SELECT SINGLE plnty plnnr plnkn arbid INTO CORRESPONDING FIELDS OF lv_plpo
            FROM plpo
            WHERE plnty = li_mapl-plnty
            AND   plnnr = li_mapl-plnnr
            AND   arbid NE ''.
          IF sy-subrc EQ 0.
            SELECT SINGLE objty objid arbpl veran INTO CORRESPONDING FIELDS OF lv_crhd
              FROM crhd
              WHERE objty EQ 'A'
              AND   objid EQ lv_plpo-arbid.

            IF sy-subrc EQ 0.
              IF x_bncom-auart EQ 'ZP21'.
              ELSE.
                lv_string = '(SAPLCOKO)CAUFVD-GSTRP'.
                ASSIGN (lv_string) TO <fs_field>.
                lv_gstrp = <fs_field>.

                lv_string = '(SAPLCOKO)CAUFVD-GLTRP'.
                ASSIGN (lv_string) TO <fs_field>.
                lv_gltrp = <fs_field>.

                lv_string = '(SAPLCOKO)CAUFVD-FEVOR'.
                ASSIGN (lv_string) TO <fs_field>.
                lv_fevor = <fs_field>.

                lv_string = '(SAPLCOKO)RESBD-CHARG'.
                ASSIGN (lv_string) TO <fs_field>.
                lv_charg_r = <fs_field>.
              ENDIF.

              IF lv_gstrp IS NOT INITIAL.
                lv_period = lv_gstrp(6).
              ELSEIF lv_gltrp IS NOT INITIAL.
                lv_period = lv_gltrp(6).
              ENDIF.

              IF lv_period IS INITIAL.
                CALL FUNCTION 'TH_GET_SESSION_ID'
                  IMPORTING
                    session_id = lv_session.
                IF sy-subrc EQ 0.
                  CONCATENATE 'PLI' lv_session(8) INTO lv_id.
                ELSE.
                  lv_id = 'PLI'.
                ENDIF.

                IMPORT gltrp = lv_gltrp
                       gstrp = lv_gstrp
                       matnr = lv_matnr
                       werks = lv_werks
                       charg = lv_charg_r
                       fevor = lv_fevor
                       FROM MEMORY ID lv_id.

                IF lv_gstrp IS NOT INITIAL.
                  lv_period = lv_gstrp(6).
                ELSEIF lv_gltrp IS NOT INITIAL.
                  lv_period = lv_gltrp(6).
                ENDIF.
              ENDIF.

              IF x_bncom-auart EQ 'ZP21' AND lv_fevor IS NOT INITIAL.
                CLEAR: lv_flag_create_batch, lv_string.
                lv_string =  '(SAPLCOKO)AFPOD-INSMK'.  "Ambil status screen create batch (pada tombil create batch)
                ASSIGN (lv_string) TO <fs_field>.
                lv_flag_create_batch = <fs_field>.
** Exit ini untuk mendapat informasi dari exit
**   Call function "EXIT_SAPLCOMK_014" dengan iclude program "ZXCO1U23"
**     Pada proses   IF lv_resb-charg IS NOT INITIAL AND lv_resb-matnr(1) = 'I'.
**      untuk export data yang diberikan disini
                IF lv_fevor = 'P01' OR lv_fevor = 'P02'.
                  IF lv_charg_r IS NOT INITIAL.
                    IF lv_fevor = 'P01'.
                      CONCATENATE lv_charg_r 'K' INTO new_charg.
                    ENDIF.
                    IF lv_fevor = 'P02'.
                      CONCATENATE lv_charg_r 'L' INTO new_charg.
                    ENDIF.
                  ELSE.
                    IF lv_flag_create_batch = 'X'.
                      MESSAGE e002(zz) WITH 'Batch SFG belum diisi'.
                    ENDIF.
                  ENDIF.
                ELSE.
                  CHECK lv_period IS NOT INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                  CALL FUNCTION 'ZFM_NEW_BATCH_PLI_FG'
                    EXPORTING
                      p_matnr  = x_bncom-matnr
                      p_werks  = x_bncom-werks
                      p_aufnr  = x_bncom-aufnr
                      p_period = lv_period
                      p_veran  = lv_crhd-veran
                      p_fevor  = lv_fevor
                    IMPORTING
                      p_charg  = new_charg.
                ENDIF.
              ELSE.
                IF lv_period IS INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                  SELECT SINGLE aufnr auart bukrs werks gstrp aufpl INTO CORRESPONDING FIELDS OF lv_caufv
                    FROM caufv
                    WHERE aufnr EQ x_bncom-aufnr
                    AND   ( auart EQ 'ZP22' ). "KMM Finish Good " 'ZP22' "KMM Finish Good

                  IF sy-subrc EQ 0.
                    lv_period = lv_caufv-gstrp.
                  ENDIF.
                ENDIF.
                CHECK lv_period IS NOT INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                CALL FUNCTION 'ZFM_NEW_BATCH_PLI_FG'
                  EXPORTING
                    p_matnr  = x_bncom-matnr
                    p_werks  = x_bncom-werks
                    p_aufnr  = x_bncom-aufnr
                    p_period = lv_period
                    p_veran  = lv_crhd-veran
                    p_fevor  = lv_fevor
                  IMPORTING
                    p_charg  = new_charg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  WHEN '8360'.
* KMM
    IF ( x_bncom-werks EQ '3600' OR x_bncom-werks EQ '3603' ) AND
      ( x_bncom-auart EQ 'ZK01' OR x_bncom-auart EQ 'ZK04' OR x_bncom-auart EQ 'ZK32' ).
      SELECT matnr werks plnty plnnr plnal zkriz zaehl datuv
        INTO TABLE li_mapl
        FROM mapl
        WHERE matnr EQ x_bncom-matnr
        AND   werks EQ x_bncom-werks
        ORDER BY matnr werks plnty plnnr plnal zkriz zaehl datuv DESCENDING.

      IF li_mapl[] IS NOT INITIAL.
        READ TABLE li_mapl INDEX 1.
        IF sy-subrc EQ 0.
          SELECT SINGLE plnty plnnr plnkn arbid INTO CORRESPONDING FIELDS OF lv_plpo
            FROM plpo
            WHERE plnty = li_mapl-plnty
            AND   plnnr = li_mapl-plnnr
            AND   arbid NE ''.
          IF sy-subrc EQ 0.
            SELECT SINGLE objty objid arbpl veran INTO CORRESPONDING FIELDS OF lv_crhd
              FROM crhd
              WHERE objty EQ 'A'
              AND   objid EQ lv_plpo-arbid.
            IF sy-subrc EQ 0.
              CALL FUNCTION 'TH_GET_SESSION_ID'
                IMPORTING
                  session_id = lv_session.
              IF sy-subrc EQ 0.
                CONCATENATE 'KMM' lv_session(8) INTO lv_id.
              ELSE.
                lv_id = 'KMM'.
              ENDIF.

              IMPORT gltrp = lv_gltrp
                     gstrp = lv_gstrp
                     matnr = lv_matnr
                     werks = lv_werks
                     charg = lv_charg_r
                     plgrp = lv_plgrp
                     FROM MEMORY ID lv_id.
*          break sol_wayan.

              IF lv_gstrp IS NOT INITIAL.
                lv_period = lv_gstrp(6).
              ELSEIF lv_gltrp IS NOT INITIAL.
                lv_period = lv_gltrp(6).
              ENDIF.

              IF x_bncom-auart EQ 'ZK04' AND x_bncom-matnr EQ lv_matnr AND lv_charg_r IS NOT INITIAL.
                CONCATENATE lv_charg_r 'R' INTO new_charg.
              ELSE.

                IF lv_period IS INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                  SELECT SINGLE aufnr auart bukrs werks gstrp aufpl INTO CORRESPONDING FIELDS OF lv_caufv
                    FROM caufv
                    WHERE aufnr EQ x_bncom-aufnr
                    AND   auart EQ 'ZK01'. "KMM Finish Good
                  IF sy-subrc EQ 0.
                    lv_period = lv_caufv-gstrp.
                  ENDIF.
                ENDIF.

                CHECK lv_period IS NOT INITIAL AND x_bncom-aufnr IS NOT INITIAL.

                CALL FUNCTION 'ZFM_NEW_BATCH_KMM_FG'
                  EXPORTING
                    p_matnr  = x_bncom-matnr
                    p_werks  = x_bncom-werks
                    p_lgort  = x_bncom-lgort
                    p_aufnr  = x_bncom-aufnr
                    p_period = lv_period
                    p_veran  = lv_crhd-veran
                    p_plgrp  = lv_plgrp
                  IMPORTING
                    p_charg  = new_charg.
              ENDIF.
            ENDIF.
            IF x_bncom-werks = '3603'.
              CALL FUNCTION 'TH_GET_SESSION_ID'
                IMPORTING
                  session_id = lv_session.
              IF sy-subrc EQ 0.
                CONCATENATE 'KMMCO' lv_session(8) INTO lv_id.
              ELSE.
                lv_id = 'KMMCO'.
              ENDIF.

              lv_charg = new_charg.
              EXPORT lv_charg TO MEMORY ID lv_id.
            ENDIF.
          ELSE.
            IF x_bncom-werks = '3603'.
              SELECT SINGLE kzkup
                FROM marc
                INTO lv_kzkup
                WHERE matnr = x_bncom-matnr
                  AND werks = x_bncom-werks.
              IF lv_kzkup IS NOT INITIAL.
                CALL FUNCTION 'TH_GET_SESSION_ID'
                  IMPORTING
                    session_id = lv_session.
                IF sy-subrc EQ 0.
                  CONCATENATE 'KMMCO' lv_session(8) INTO lv_id.
                ELSE.
                  lv_id = 'KMMCO'.
                ENDIF.
                IMPORT lv_charg FROM MEMORY ID lv_id.
                new_charg = lv_charg.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

* TUS
  WHEN '8190'.
    IF x_bncom-werks EQ '1900'.
      SELECT matnr werks plnty plnnr plnal zkriz zaehl datuv
        INTO TABLE li_mapl
        FROM mapl
        WHERE matnr EQ x_bncom-matnr
        AND   werks EQ x_bncom-werks
        ORDER BY matnr werks plnty plnnr plnal zkriz zaehl datuv DESCENDING.

      IF li_mapl[] IS NOT INITIAL.
        READ TABLE li_mapl INDEX 1.
        IF sy-subrc EQ 0.
          SELECT SINGLE plnty plnnr plnkn arbid INTO CORRESPONDING FIELDS OF lv_plpo
            FROM plpo
            WHERE plnty = li_mapl-plnty
            AND   plnnr = li_mapl-plnnr
            AND   arbid NE ''.
          IF sy-subrc EQ 0.
            SELECT SINGLE objty objid arbpl veran INTO CORRESPONDING FIELDS OF lv_crhd
              FROM crhd
              WHERE objty EQ 'A'
              AND   objid EQ lv_plpo-arbid.
            IF sy-subrc EQ 0.
              CALL FUNCTION 'TH_GET_SESSION_ID'
                IMPORTING
                  session_id = lv_session.
              IF sy-subrc EQ 0.
                CONCATENATE 'TUS' lv_session(8) INTO lv_id.
              ELSE.
                lv_id = 'TUS'.
              ENDIF.

              IMPORT gltrp = lv_gltrp
                     gstrp = lv_gstrp
                     matnr = lv_matnr
                     werks = lv_werks
                     charg = lv_charg_r
                     plgrp = lv_plgrp
                     FROM MEMORY ID lv_id.
*          break sol_wayan.

              IF lv_gstrp IS NOT INITIAL.
                lv_period = lv_gstrp(6).
              ELSEIF lv_gltrp IS NOT INITIAL.
                lv_period = lv_gltrp(6).
              ENDIF.

              IF x_bncom-auart EQ 'ZK04' AND x_bncom-matnr EQ lv_matnr AND lv_charg_r IS NOT INITIAL.
                CONCATENATE lv_charg_r 'R' INTO new_charg.
              ELSE.

                IF lv_period IS INITIAL AND x_bncom-aufnr IS NOT INITIAL.
                  SELECT SINGLE aufnr auart bukrs werks gstrp aufpl INTO CORRESPONDING FIELDS OF lv_caufv
                    FROM caufv
                    WHERE aufnr EQ x_bncom-aufnr
                    AND   auart EQ 'ZK01'. "KMM Finish Good
                  IF sy-subrc EQ 0.
                    lv_period = lv_caufv-gstrp.
                  ENDIF.
                ENDIF.

                CHECK lv_period IS NOT INITIAL AND x_bncom-aufnr IS NOT INITIAL.

                CALL FUNCTION 'ZFM_NEW_BATCH_TUS_FG'
                  EXPORTING
                    p_matnr  = x_bncom-matnr
                    p_werks  = x_bncom-werks
                    p_lgort  = x_bncom-lgort
                    p_aufnr  = x_bncom-aufnr
                    p_period = lv_period
                    p_veran  = lv_crhd-veran
                    p_plgrp  = lv_plgrp
                  IMPORTING
                    p_charg  = new_charg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  WHEN OTHERS.
    DATA: ld_matnr TYPE matnr.
    DATA: lw_zgdppdt0002 LIKE zgdppdt0002.

*--------------------------------------------------------------------*
* New batch for product SFG
*--------------------------------------------------------------------*
* Begin 28.05.2018 --------------------------------------------------*
    DATA lv_baugr TYPE baugr.
    DATA ls_zgdppdt0014 LIKE zgdppdt0014.
    DATA lv_message TYPE string.

    SELECT matnr werks plnty plnnr plnal zkriz zaehl datuv
      INTO TABLE li_mapl
      FROM mapl
      WHERE matnr EQ x_bncom-matnr
      AND   werks EQ x_bncom-werks
      ORDER BY matnr werks plnty plnnr plnal zkriz zaehl datuv DESCENDING.

    IF li_mapl[] IS NOT INITIAL.
      READ TABLE li_mapl INDEX 1.

      IF sy-subrc EQ 0.
        SELECT SINGLE plnty plnnr plnkn arbid INTO CORRESPONDING FIELDS OF lv_plpo
          FROM plpo
          WHERE plnty = li_mapl-plnty
          AND   plnnr = li_mapl-plnnr
          AND   arbid NE ''.

        IF sy-subrc EQ 0.
          SELECT SINGLE objty objid arbpl veran INTO CORRESPONDING FIELDS OF lv_crhd
            FROM crhd
            WHERE objty EQ 'A'
            AND   objid EQ lv_plpo-arbid.

          IF sy-subrc EQ 0.
            CALL FUNCTION 'TH_GET_SESSION_ID'
            IMPORTING
              session_id       = lv_session
*            ID_LEN           =
                     .
            IF sy-subrc EQ 0.
              CONCATENATE 'TSP' lv_session(8) INTO lv_id.
            ELSE.
              lv_id = 'TSP'.
            ENDIF.

            IMPORT gltrp = lv_gltrp
                   gstrp = lv_gstrp
                   matnr = lv_matnr
                   baugr = lv_baugr
                   werks = lv_werks
                   charg = lv_charg_r
*                 fevor = lv_fevor
                   FROM MEMORY ID lv_id
                   .

            IF lv_gstrp IS NOT INITIAL.
              lv_period = lv_gstrp(6).
            ELSEIF lv_gltrp IS NOT INITIAL.
              lv_period = lv_gltrp(6).
            ENDIF.

            CLEAR: ls_zgdppdt0014.
            SELECT SINGLE * INTO ls_zgdppdt0014
              FROM zgdppdt0014 WHERE werks = lv_werks
                                 AND matnr = lv_matnr
                                 AND charg = lv_charg_r.

            IF x_bncom-auart EQ 'ZF01'   AND
               x_bncom-matnr EQ lv_baugr AND
               lv_charg_r    IS NOT INITIAL AND
               lv_matnr      EQ 'I2109'.
              ADD 1 TO ls_zgdppdt0014-counter.
              SHIFT ls_zgdppdt0014-counter LEFT DELETING LEADING '0'.
              CONCATENATE lv_charg_r ls_zgdppdt0014-counter
                INTO new_charg SEPARATED BY space.

              IF ls_zgdppdt0014 IS NOT INITIAL.
*            -----Reserve number -- only one process order processed at once
                CALL FUNCTION 'ENQUEUE_EZGDPPDT0014'
                  EXPORTING
                    mode_zgdppdt0014 = 'E'
                    mandt            = sy-mandt
                    werks            = lv_werks
                    matnr            = lv_matnr
                    charg            = lv_charg_r
                  EXCEPTIONS
                    foreign_lock     = 1
                    system_failure   = 2
                    OTHERS           = 3.

                IF sy-subrc <> 0.
                  CASE sy-subrc.
                    WHEN 1.
                      CONCATENATE 'object requested (New Batch) is currently locked by' sy-msgv1 INTO lv_message.
                      MESSAGE lv_message TYPE 'E'.
                    WHEN OTHERS.
                      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDCASE.
                ENDIF.
              ENDIF.

              IF NOT new_charg+2(3) IS INITIAL.
                PERFORM f_warning_batch(zmm_exit) USING x_bncom-matnr
                                                        x_bncom-werks
                                                        new_charg
                                                  CHANGING d_error.
                zgdppdt0002-counter = ls_zgdppdt0014-counter.
                EXPORT x_bncom-matnr
                       x_bncom-werks
                       new_charg
                       zgdppdt0002-counter
                       zgdppdt0002-subcount
                       zgdppdt0002-count_exp
                       zgdppdt0002-count_tia
                       d_gstrp
                       d_exist
                       d_verid
                       d_error
                       lv_matnr
                       TO MEMORY ID zbatch.
              ENDIF.
              SET PARAMETER ID 'M_GSTRP' FIELD ''.
              SET PARAMETER ID 'M_VERID' FIELD ''.

            ELSE.
* End ---------------------------------------------------------------*


              CLEAR ld_matnr.
              IF lv_t001k-bukrs EQ '8010' AND ( x_bncom-werks(2) EQ '01' OR x_bncom-werks(2) EQ '02' ).   "TSP
                ld_matnr = x_bncom-werks.                                                                 "Untuk TSP grouping batch diubah jadi per-Plant
                CLEAR d_verid.                                                                            "Untuk TSP grouping batch diubah jadi per-Plant
              ELSEIF lv_t001k-bukrs EQ '8090' AND x_bncom-werks(2) EQ '09'.                               "SFF
                ld_matnr = x_bncom-werks.                                                                 "Untuk SFF grouping batch diubah jadi per-Plant
                CLEAR d_verid.                                                                            "Untuk SSF grouping batch diubah jadi per-Plant
              ELSE.
                ld_matnr = x_bncom-matnr.
              ENDIF.

              IF x_bncom-matkl(3) EQ 'TIA'.
                IF d_gstrp <>  '00000000' AND
                   x_bncom-mtart = 'ZPHA'.
                  d_charg = new_charg.
                  new_charg = '0000000'.
                  new_charg+1(2) = d_gstrp+4(2).
*  new_charg+2(3) = d_charg.

                  SELECT SINGLE zmoncov
                    FROM zgdppdt0005
                    INTO ld_zmoncov
                    WHERE mnr EQ d_gstrp+4(2).

                  new_charg+5(1) = ld_zmoncov.

                  SELECT SINGLE zyeacov
                    FROM zgdppdt0006
                    INTO ld_zyeacov
                    WHERE gjahr EQ d_gstrp(4).

                  new_charg+4(1) = ld_zyeacov.
                  new_charg+3(1) = space.


**Check exceptional condition -RJA 10/06/2005
                  SELECT SINGLE * FROM zgdppdt0003
                                  WHERE matnr = x_bncom-matnr AND
                                        verid = d_verid.
                  IF sy-subrc = 0.
                    CONCATENATE d_gstrp(4) '0000' INTO ld_gstrp.
                    CONCATENATE d_gstrp(4) '%' INTO ld_gstrp2.                            "Untuk TSP grouping batch diubah jadi per-Plant
                    SELECT SINGLE * FROM zgdppdt0002
*                        WHERE matnr  = x_bncom-matnr AND                     "Untuk TSP grouping batch diubah jadi per-Plant
                                    WHERE matnr  = ld_matnr AND                           "Untuk TSP grouping batch diubah jadi per-Plant
*                              period = ld_gstrp(6) AND " ld_gstrp+(6) AND    "Untuk TSP grouping batch diubah jadi per-Plant
                                          period LIKE ld_gstrp2 AND " ld_gstrp+(6) AND    "Untuk TSP grouping batch diubah jadi per-Plant
                                          verid  = d_verid.
                    IF sy-subrc = 0.
*-----Reserve number -- only one process order processed at once
                      CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
                        EXPORTING
                          mode_zgdppdt0002 = 'E'
                          mandt            = sy-mandt
*              matnr            = x_bncom-matnr                           "Untuk TSP grouping batch diubah jadi per-Plant
                          matnr            = ld_matnr                                 "Untuk TSP grouping batch diubah jadi per-Plant
*              period           = ld_gstrp(6) "ld_gstrp+(6)               "Untuk TSP grouping batch diubah jadi per-Plant
                          period           = zgdppdt0002-period                       "Untuk TSP grouping batch diubah jadi per-Plant
                          verid            = d_verid
                        EXCEPTIONS
                          foreign_lock     = 1
                          system_failure   = 2
                          OTHERS           = 3.
                      IF sy-subrc <> 0.
                        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ENDIF.

                      IF zgdppdt0002-count_tia IS INITIAL.
                        ADD 1 TO zgdppdt0002-counter.
                        zgdppdt0002-count_tia = zgdppdt0002-counter.
                      ELSE.
                        ADD 1 TO zgdppdt0002-count_tia.
                      ENDIF.

*          ADD 1 TO zgdppdt0002-counter.
*          new_charg(2) = zgdppdt0002-counter+1(2).
                      new_charg(2) = zgdppdt0002-count_tia+1(2).
                      d_exist = 'X'.
                    ELSE.
                      new_charg(2) = zgdppdt0003-charg_start+1(2).
                      zgdppdt0002-counter = zgdppdt0003-charg_start.
                      zgdppdt0002-count_tia = zgdppdt0003-charg_start.
                    ENDIF.
                  ELSE.
                    CONCATENATE d_gstrp(4) '0000' INTO ld_gstrp.
                    CONCATENATE d_gstrp(4) '%' INTO ld_gstrp2.                            "Untuk TSP grouping batch diubah jadi per-Plant
                    CLEAR d_verid.
                    SELECT SINGLE * FROM zgdppdt0002
*                        WHERE matnr   = x_bncom-matnr AND                "Untuk TSP grouping batch diubah jadi per-Plant
                                    WHERE matnr   = ld_matnr AND                      "Untuk TSP grouping batch diubah jadi per-Plant
*                              period  = ld_gstrp(6). "ld_gstrp+(6).
                                          period LIKE ld_gstrp2.                      "Untuk TSP grouping batch diubah jadi per-Plant
                    IF sy-subrc = 0.
*-----Reserve number -- only one process order processed at once
                      CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
                        EXPORTING
                          mode_zgdppdt0002 = 'E'
                          mandt            = sy-mandt
*              matnr            = x_bncom-matnr                           "Untuk TSP grouping batch diubah jadi per-Plant
                          matnr            = ld_matnr                                 "Untuk TSP grouping batch diubah jadi per-Plant
*              period           = ld_gstrp(6) "ld_gstrp+(6)               "Untuk TSP grouping batch diubah jadi per-Plant
                          period           = zgdppdt0002-period                       "Untuk TSP grouping batch diubah jadi per-Plant
                        EXCEPTIONS
                          foreign_lock     = 1
                          system_failure   = 2
                          OTHERS           = 3.
                      IF sy-subrc <> 0.
                        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ENDIF.

                      IF zgdppdt0002-count_tia IS INITIAL.
                        ADD 1 TO zgdppdt0002-counter.
                        zgdppdt0002-count_tia = zgdppdt0002-counter.
                      ELSE.
                        ADD 1 TO zgdppdt0002-count_tia.
                      ENDIF.

*          ADD 1 TO zgdppdt0002-counter.
*          new_charg(3) = zgdppdt0002-counter.
                      new_charg(3) = zgdppdt0002-count_tia.
                      d_exist = 'X'.
                    ELSE.
                      CLEAR d_exist.

                      new_charg(3) = '001'.
                      zgdppdt0002-counter = '001'.
                    ENDIF.
                  ENDIF.

                  new_charg+6(1) = 'D'.
                  IF NOT new_charg(2) IS INITIAL.
                    PERFORM f_warning_batch(zmm_exit) USING x_bncom-matnr
                                                            x_bncom-werks
                                                            new_charg
                                                      CHANGING d_error.
                    d_gstrp = ld_gstrp.
                    EXPORT x_bncom-matnr
                           x_bncom-werks
                           new_charg
                           zgdppdt0002-counter
                           zgdppdt0002-subcount
                           zgdppdt0002-count_exp
                           zgdppdt0002-count_tia
                           d_gstrp
                           d_exist
                           d_verid
                           d_error
                           TO MEMORY ID zbatch.
                  ENDIF.
                  SET PARAMETER ID 'M_GSTRP' FIELD ''.
                  SET PARAMETER ID 'M_VERID' FIELD ''.
                ENDIF.
              ELSE.
                IF x_bncom-matkl = 'TSPEXPEXP' AND
*     ( x_bncom-werks(2) = '01' OR x_bncom-werks(2) = '02' ).
                   x_bncom-werks = '0101'.
                  IF d_gstrp <>  '00000000' AND
                     x_bncom-mtart = 'ZPHA'.
                    d_charg = new_charg.
                    new_charg = '000000'.
                    new_charg(2) = d_gstrp+4(2).

*--------------------------------------------------------------------*
* Ganti pakai FM
*--------------------------------------------------------------------*
                    CALL FUNCTION 'ZFM_NEW_BATCH_TSP'
                      EXPORTING
                        p_werks           = x_bncom-werks
                        p_matnr           = x_bncom-matnr
                        p_period          = d_gstrp(6)
                        p_verid           = d_verid
                        p_matkl           = x_bncom-matkl
*           P_AUFNR           =
                      IMPORTING
                        p_charg           = new_charg
                        p_exist           = d_exist
                        p_counter         = zgdppdt0002-counter
                        p_subcount        = zgdppdt0002-subcount
                        p_count_exp       = zgdppdt0002-count_exp
                        p_count_tia       = zgdppdt0002-count_tia.

*        SELECT SINGLE * FROM zgdppdt0003
*                        WHERE matnr = x_bncom-matnr." AND
****                            verid = d_verid.
*        IF sy-subrc = 0.
*          SELECT SINGLE * FROM zgdppdt0002
**                          WHERE matnr = x_bncom-matnr AND                    "Untuk TSP grouping batch diubah jadi per-Plant
*                          WHERE matnr = ld_matnr AND                          "Untuk TSP grouping batch diubah jadi per-Plant
*                                period = d_gstrp(6)." AND d_gstrp+(6)." AND
****                              verid = d_verid.
*          IF sy-subrc = 0.
**  -----Reserve number -- only one process order processed at once
*            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
*              EXPORTING
*                mode_zgdppdt0002 = 'E'
*                mandt            = sy-mandt
**                matnr            = x_bncom-matnr                             "Untuk TSP grouping batch diubah jadi per-Plant
*                matnr            = ld_matnr                                   "Untuk TSP grouping batch diubah jadi per-Plant
*                period           = d_gstrp(6)
*                verid            = d_verid
*              EXCEPTIONS
*                foreign_lock     = 1
*                system_failure   = 2
*                OTHERS           = 3.
*            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ENDIF.
*
*            IF zgdppdt0002-subcount LT '009'.
*
*              "Jika pertama kali create, counter + 1 dan dicopy ke count_exp
*              IF zgdppdt0002-subcount IS INITIAL.
*                ADD 1 TO zgdppdt0002-counter.
*                zgdppdt0002-count_exp = zgdppdt0002-counter.
*              ENDIF.
*
*              ADD 1 TO zgdppdt0002-subcount.
**              new_charg+2(3) = zgdppdt0002-counter.
*              new_charg+2(3) = zgdppdt0002-count_exp.
*              new_charg+6(1) = space.
*              new_charg+7(1) = zgdppdt0002-subcount+2(1).
*
*            ELSE.
*              ADD 1 TO zgdppdt0002-counter.
*              zgdppdt0002-count_exp = zgdppdt0002-counter.
*              zgdppdt0002-subcount = '001'.
**              new_charg+2(3) = zgdppdt0002-counter.
*              new_charg+2(3) = zgdppdt0002-count_exp.
*              new_charg+6(1) = space.
*              new_charg+7(1) = zgdppdt0002-subcount+2(1).
*            ENDIF.
*            d_exist = 'X'.
*
*          ELSE.
*            new_charg+2(3) = zgdppdt0003-charg_start.
*            new_charg+6(1) = space.
*            new_charg+7(1) = zgdppdt0003-charg_start+2(1).
*            zgdppdt0002-counter  = zgdppdt0003-charg_start.
*            zgdppdt0002-subcount = zgdppdt0003-charg_start.
*            zgdppdt0002-count_exp = zgdppdt0003-charg_start.
*          ENDIF.
*        ELSE.
*          CLEAR d_verid.
*          SELECT SINGLE * FROM zgdppdt0002
**                          WHERE matnr = x_bncom-matnr AND                    "Untuk TSP grouping batch diubah jadi per-Plant
*                          WHERE matnr = ld_matnr AND                          "Untuk TSP grouping batch diubah jadi per-Plant
*                                period = d_gstrp(6). "d_gstrp+(6).
*          IF sy-subrc = 0.
**  -----Reserve number -- only one process order processed at once
*            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
*              EXPORTING
*                mode_zgdppdt0002 = 'E'
*                mandt            = sy-mandt
**                matnr            = x_bncom-matnr                             "Untuk TSP grouping batch diubah jadi per-Plant
*                matnr            = ld_matnr                                   "Untuk TSP grouping batch diubah jadi per-Plant
*                period           = d_gstrp(6)
*              EXCEPTIONS
*                foreign_lock     = 1
*                system_failure   = 2
*                OTHERS           = 3.
*            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ENDIF.
*
*            ADD 1 TO zgdppdt0002-counter.
*            new_charg+2(3) = zgdppdt0002-counter.
*            d_exist = 'X'.
*          ELSE.
*            CLEAR d_exist.
*
*            new_charg+2(3) = '001'.
*            zgdppdt0002-counter = '001'.
*          ENDIF.
*        ENDIF.
*
*        new_charg+5(1) = d_gstrp+3(1).
*--------------------------------------------------------------------*
                    IF NOT new_charg+2(3) IS INITIAL.
                      PERFORM f_warning_batch(zmm_exit) USING x_bncom-matnr
                                                              x_bncom-werks
                                                              new_charg
                                                        CHANGING d_error.
                      EXPORT x_bncom-matnr
                             x_bncom-werks
                             new_charg
                             zgdppdt0002-counter
                             zgdppdt0002-subcount
                             zgdppdt0002-count_exp
                             zgdppdt0002-count_tia
                             d_gstrp
                             d_exist
                             d_verid
                             d_error
                             TO MEMORY ID zbatch.
                    ENDIF.
                    SET PARAMETER ID 'M_GSTRP' FIELD ''.
                    SET PARAMETER ID 'M_VERID' FIELD ''.
                  ENDIF.
                ELSE.
                  IF d_gstrp <>  '00000000' AND
                 ( x_bncom-werks(2) = '01' OR
                   x_bncom-werks(2) = '02' OR
                   x_bncom-werks(2) = '09' ) AND
                 ( x_bncom-mtart = 'ZPHA' OR
                   x_bncom-mtart = 'ZCGB' OR
                 ( x_bncom-mtart = 'ZSFG' AND x_bncom-matnr = 'I2109' ) ). " OR
* Command untuk error KMM
*                 ( x_bncom-mtart = 'ZSFG' AND x_bncom-matnr = 'I6004' ) ).
                    d_charg = new_charg.
                    new_charg = '000000'.
                    new_charg(2) = d_gstrp+4(2).
*    new_charg+2(3) = d_charg.

*--------------------------------------------------------------------*
* Ganti pakai FM
*--------------------------------------------------------------------*
                    CALL FUNCTION 'ZFM_NEW_BATCH_TSP'
                      EXPORTING
                        p_werks           = x_bncom-werks
                        p_matnr           = x_bncom-matnr
                        p_period          = d_gstrp(6)
                        p_verid           = d_verid
                        p_matkl           = x_bncom-matkl
*           P_AUFNR           =
                      IMPORTING
                        p_charg           = new_charg
                        p_exist           = d_exist
                        p_counter         = zgdppdt0002-counter
                        p_subcount        = zgdppdt0002-subcount
                        p_count_exp       = zgdppdt0002-count_exp
                        p_count_tia       = zgdppdt0002-count_tia.
**  *Check exceptional condition -RJA 10/06/2005
*        SELECT SINGLE * FROM zgdppdt0003
*                        WHERE matnr = x_bncom-matnr AND
*                              verid = d_verid.
*        IF sy-subrc = 0.
*          SELECT SINGLE * FROM zgdppdt0002
**                          WHERE matnr = x_bncom-matnr AND                  "Untuk TSP grouping batch diubah jadi per-Plant
*                          WHERE matnr = ld_matnr AND                        "Untuk TSP grouping batch diubah jadi per-Plant
*                                period = d_gstrp+(6) AND
*                                verid = d_verid.
*          IF sy-subrc = 0.
**  -----Reserve number -- only one process order processed at once
*            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
*              EXPORTING
*                mode_zgdppdt0002 = 'E'
*                mandt            = sy-mandt
**                matnr            = x_bncom-matnr                           "Untuk TSP grouping batch diubah jadi per-Plant
*                matnr            = ld_matnr                                 "Untuk TSP grouping batch diubah jadi per-Plant
*                period           = d_gstrp(6) "d_gstrp+(6)
*                verid            = d_verid
*              EXCEPTIONS
*                foreign_lock     = 1
*                system_failure   = 2
*                OTHERS           = 3.
*            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ENDIF.
*
*            ADD 1 TO zgdppdt0002-counter.
*            new_charg+2(3) = zgdppdt0002-counter.
*            d_exist = 'X'.
*          ELSE.
*            new_charg+2(3) = zgdppdt0003-charg_start.
*            zgdppdt0002-counter = zgdppdt0003-charg_start.
*          ENDIF.
*        ELSE.
*          CLEAR d_verid.
*          SELECT SINGLE * FROM zgdppdt0002
**                          WHERE matnr = x_bncom-matnr AND                    "Untuk TSP grouping batch diubah jadi per-Plant
*                          WHERE matnr = ld_matnr AND                          "Untuk TSP grouping batch diubah jadi per-Plant
*                                period = d_gstrp(6). "d_gstrp+(6).
*          IF sy-subrc = 0.
**  -----Reserve number -- only one process order processed at once
*            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
*              EXPORTING
*                mode_zgdppdt0002 = 'E'
*                mandt            = sy-mandt
**                matnr            = x_bncom-matnr                             "Untuk TSP grouping batch diubah jadi per-Plant
*                matnr            = ld_matnr                                   "Untuk TSP grouping batch diubah jadi per-Plant
*                period           = d_gstrp(6) "d_gstrp+(6)
*              EXCEPTIONS
*                foreign_lock     = 1
*                system_failure   = 2
*                OTHERS           = 3.
*            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ENDIF.
*
*            ADD 1 TO zgdppdt0002-counter.
*            new_charg+2(3) = zgdppdt0002-counter.
*            d_exist = 'X'.
*          ELSE.
*            CLEAR d_exist.
*
*            new_charg+2(3) = '001'.
*            zgdppdt0002-counter = '001'.
*          ENDIF.
*        ENDIF.
*
*        new_charg+5(1) = d_gstrp+3(1).
*--------------------------------------------------------------------*
                    IF NOT new_charg+2(3) IS INITIAL.
                      PERFORM f_warning_batch(zmm_exit) USING x_bncom-matnr
                                                              x_bncom-werks
                                                              new_charg
                                                        CHANGING d_error.
                      EXPORT x_bncom-matnr
                             x_bncom-werks
                             new_charg
                             zgdppdt0002-counter
                             zgdppdt0002-subcount
                             zgdppdt0002-count_exp
                             zgdppdt0002-count_tia
                             d_gstrp
                             d_exist
                             d_verid
                             d_error
                             TO MEMORY ID zbatch.
                    ENDIF.
                    SET PARAMETER ID 'M_GSTRP' FIELD ''.
                    SET PARAMETER ID 'M_VERID' FIELD ''.
                  ELSE.
*----- Batch numbering for DRAGON GLORY
                    RANGES: lr_auart  FOR bncom-auart,
                            lr_mtart  FOR bncom-mtart.
                    lr_auart-low      = 'ZR11'.
                    lr_auart-high     = 'ZR13'.
                    lr_auart-sign     = 'I'.
                    lr_auart-option   = 'BT'.
                    APPEND lr_auart.
                    lr_auart-low      = 'ZR16'.
                    lr_auart-sign     = 'I'.
                    lr_auart-option   = 'EQ'.
                    APPEND lr_auart.
                    lr_auart-low      = 'ZR22'.
                    lr_auart-sign     = 'I'.
                    lr_auart-option   = 'EQ'.
                    APPEND lr_auart.

                    lr_mtart-low      = 'ZSFG'.
                    lr_mtart-sign     = 'I'.
                    lr_mtart-option   = 'EQ'.
                    APPEND lr_mtart.
                    lr_mtart-low      = 'ZCGB'.
                    lr_mtart-sign     = 'I'.
                    lr_mtart-option   = 'EQ'.
                    APPEND lr_mtart.

                    IF x_bncom-mtart IN lr_mtart AND
                       x_bncom-auart IN lr_auart.
                      ASSIGN ('(SAPLCOKO)CAUFVD-GLTRP') TO <fs_gltrp>.
                      ld_gstrp  = <fs_gltrp>.
                    ENDIF.

                    IF sy-subrc EQ 0.
                      IF ld_gstrp <> '00000000' AND
                        ld_gstrp NE d_gstrp.
                        d_gstrp  = ld_gstrp.
                      ENDIF.

                      IF d_gstrp <>  '00000000' AND
                        x_bncom-mtart IN lr_mtart AND
                        x_bncom-auart IN lr_auart.
                        d_charg = new_charg.

* new batch numbering 11/01/2023    DEVK977777
*                        new_charg = '00000'.
*                        new_charg(1)   = d_gstrp+3(1).
*
*                        SELECT SINGLE zmoncov
*                          FROM zdgppdt0001
*                          INTO ld_zmoncov
*                          WHERE mnr EQ d_gstrp+4(2).
*
*                        new_charg+1(1) = ld_zmoncov.

                        new_charg = '0000000'.
                        new_charg(2)   = d_gstrp+2(2).
                        new_charg+2(2) = d_gstrp+4(2).

**Check exceptional condition -RJA 10/06/2005
                        SELECT SINGLE * FROM zgdppdt0003
                                        WHERE matnr = x_bncom-matnr AND
                                              verid = d_verid.
                        IF sy-subrc = 0.
                          SELECT SINGLE * FROM zgdppdt0002
*                              WHERE matnr  = x_bncom-matnr AND                   "Untuk TSP grouping batch diubah jadi per-Plant
                                          WHERE matnr  = ld_matnr AND                         "Untuk TSP grouping batch diubah jadi per-Plant
                                                period = d_gstrp+(6) AND
                                                verid  = d_verid.
                          IF sy-subrc = 0.
*-----Reserve number -- only one process order processed at once
                            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
                              EXPORTING
                                mode_zgdppdt0002 = 'E'
                                mandt            = sy-mandt
*                    matnr            = x_bncom-matnr                             "Untuk TSP grouping batch diubah jadi per-Plant
                                matnr            = ld_matnr                                   "Untuk TSP grouping batch diubah jadi per-Plant
                                period           = d_gstrp(6) "d_gstrp+(6)
                                verid            = d_verid
                              EXCEPTIONS
                                foreign_lock     = 1
                                system_failure   = 2
                                OTHERS           = 3.
                            IF sy-subrc <> 0.
                              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                            ENDIF.

                            ADD 1 TO zgdppdt0002-counter.
                            new_charg+2(3) = zgdppdt0002-counter(3).
                            d_exist = 'X'.
                          ELSE.
                            new_charg+2(3) = zgdppdt0003-charg_start(3).
                            zgdppdt0002-counter = zgdppdt0003-charg_start.
                          ENDIF.
                        ELSE.
                          CLEAR d_verid.
                          SELECT SINGLE * FROM zgdppdt0002
*                              WHERE matnr   = x_bncom-matnr AND                  "Untuk TSP grouping batch diubah jadi per-Plant
                                          WHERE matnr   = ld_matnr AND                        "Untuk TSP grouping batch diubah jadi per-Plant
                                                period  = d_gstrp(6).
                          IF sy-subrc = 0.
*-----Reserve number -- only one process order processed at once
                            CALL FUNCTION 'ENQUEUE_EZGDPPDT0002'
                              EXPORTING
                                mode_zgdppdt0002 = 'E'
                                mandt            = sy-mandt
*                    matnr            = x_bncom-matnr                             "Untuk TSP grouping batch diubah jadi per-Plant
                                matnr            = ld_matnr                                   "Untuk TSP grouping batch diubah jadi per-Plant
                                period           = d_gstrp(6) "d_gstrp+(6)
                              EXCEPTIONS
                                foreign_lock     = 1
                                system_failure   = 2
                                OTHERS           = 3.
                            IF sy-subrc <> 0.
                              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                            ENDIF.

                            ADD 1 TO zgdppdt0002-counter.
* new batch numbering 11/01/2023   DEVK977777
*                            new_charg+2(3) = zgdppdt0002-counter(3).
                            new_charg+4(3) = zgdppdt0002-counter(3).
                            d_exist = 'X'.
                          ELSE.
                            CLEAR d_exist.
* new batch numbering 11/01/2023   DEVK977777
*                            new_charg+2(3) = '001'.
                            new_charg+4(3) = '001'.
                            zgdppdt0002-counter = '001'.
                          ENDIF.
                        ENDIF.

                        PERFORM f_warning_batch(zmm_exit) USING x_bncom-matnr
                                                                x_bncom-werks
                                                                new_charg
                                                          CHANGING d_error.
                        EXPORT x_bncom-matnr
                               x_bncom-werks
                               new_charg
                               zgdppdt0002-counter
                               zgdppdt0002-subcount
                               zgdppdt0002-count_exp
                               zgdppdt0002-count_tia
                               d_gstrp
                               d_exist
                               d_verid
                               d_error
                               TO MEMORY ID zbatch.

                        SET PARAMETER ID 'M_GLTRP' FIELD ''.
                        SET PARAMETER ID 'M_VERID' FIELD ''.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
ENDCASE.

IF lv_t001k-bukrs EQ '8330' AND ( x_bncom-werks EQ '3302' OR x_bncom-werks EQ '3301' ) AND  "PLI
   ( x_bncom-auart EQ 'ZP22' OR x_bncom-auart EQ 'ZP21' OR x_bncom-auart EQ 'ZP11'). "Kondisi untuk PLI - PLI - PP-E01 By Suk 19.02.2016
ELSEIF lv_t001k-bukrs EQ '8360' AND x_bncom-werks EQ '3600' AND ( x_bncom-auart EQ 'ZK01' OR x_bncom-auart EQ 'ZK04' ). "KMM
*    SELECT SINGLE aufpl aplzl vornr arbid INTO CORRESPONDING FIELDS OF lv_afvc
*      FROM afvc
*      WHERE aufpl EQ lv_caufv-aufpl
*      .
ELSE.
*  *************************
* End code,  iway 25.11.2013
*  *************************
ENDIF.    " Add Endif, iway 25.11.2013
