*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F11.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_REPLENISH_SYSTEM_GUIDE
*&---------------------------------------------------------------------*
FORM f_get_replenish_system_guide  TABLES   ft_replenish STRUCTURE zhgwmst020
                                   USING    fu_username
                                   CHANGING fs_replenish TYPE zhgwmst019
                                            fc_type fc_message.

  DATA : ls_lrf_wkqu  TYPE lrf_wkqu,
         lt_ltak      TYPE STANDARD TABLE OF ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         lt_xltap     TYPE STANDARD TABLE OF ltap,
         lt_mara      TYPE STANDARD TABLE OF mara,
         lt_marm      TYPE STANDARD TABLE OF marm,
         ls_ltak      LIKE LINE OF lt_ltak,
         ls_ltap      LIKE LINE OF lt_ltap,
         ls_mara      LIKE LINE OF lt_mara,
         ls_marm      LIKE LINE OF lt_marm,
         lr_bwlvs     TYPE RANGE OF bwlvs,
         ls_bwlvs     LIKE LINE OF lr_bwlvs,
         lr_mtart     TYPE RANGE OF mtart,
         ls_mtart     LIKE LINE OF lr_mtart,
         ls_replenish TYPE zhgwmst020.

  DATA : lv_menge    TYPE c LENGTH 20.

  IF fu_username IS NOT INITIAL.
    SELECT SINGLE *
      FROM lrf_wkqu
      INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
      WHERE bname = fu_username
        AND statu = 'X'.

    ls_bwlvs-low    = '998'.
    ls_bwlvs-sign   = 'I'.
    ls_bwlvs-option = 'EQ'.
    APPEND ls_bwlvs TO lr_bwlvs.
    ls_bwlvs-low    = '999'.
    APPEND ls_bwlvs TO lr_bwlvs.

    ls_mtart-low    = 'ZCGB'.
    ls_mtart-sign   = 'I'.
    ls_mtart-option = 'EQ'.
    APPEND ls_mtart TO lr_mtart.
    CLEAR ls_mtart.
    ls_mtart-low    = 'ZPHA'.
    ls_mtart-sign   = 'I'.
    ls_mtart-option = 'EQ'.
    APPEND ls_mtart TO lr_mtart.
    CLEAR ls_mtart.
    ls_mtart-low    = 'ZCGN'.
    ls_mtart-sign   = 'I'.
    ls_mtart-option = 'EQ'.
    APPEND ls_mtart TO lr_mtart.
    CLEAR ls_mtart.

    IF ls_lrf_wkqu-queue = 'REPLENISH'.
      SELECT *
        FROM ltak
        INTO CORRESPONDING FIELDS OF TABLE lt_ltak
        WHERE lgnum = ls_lrf_wkqu-lgnum
          AND queue = ls_lrf_wkqu-queue
          AND kquit = space
          AND bwlvs IN lr_bwlvs
        ORDER BY PRIMARY KEY.

      READ TABLE lt_ltak INTO ls_ltak INDEX 1.
      IF sy-subrc = 0.
        fs_replenish-username         = fu_username.
        fs_replenish-warehouse_number = ls_ltak-lgnum.
        fs_replenish-to_number        = ls_ltak-tanum.

        SELECT *
          FROM ltap
          INTO CORRESPONDING FIELDS OF TABLE lt_ltap
          WHERE lgnum = ls_ltak-lgnum
            AND tanum = ls_ltak-tanum.

        lt_xltap[] = lt_ltap[].
        SORT lt_xltap BY vlpla matnr.
        DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr.
        IF lt_xltap[] IS NOT INITIAL.
          SELECT *
            FROM mara
            INTO CORRESPONDING FIELDS OF TABLE lt_mara
            FOR ALL ENTRIES IN lt_xltap
            WHERE matnr = lt_xltap-matnr.

          SELECT *
            FROM marm
            INTO CORRESPONDING FIELDS OF TABLE lt_marm
            FOR ALL ENTRIES IN lt_xltap
            WHERE matnr = lt_xltap-matnr
              AND meinh = 'KAR'.
        ENDIF.

        LOOP AT lt_ltap INTO ls_ltap.
          ls_replenish-to_item                     = ls_ltap-tapos.
*          ls_replenish-start_date
*          ls_replenish-end_date
          ls_replenish-material_number             = ls_ltap-matnr.
          ls_replenish-material_description        = ls_ltap-maktx.
          ls_replenish-batch                       = ls_ltap-charg.

          PERFORM f_conversion USING 'OUTPUT'	ls_ltap-nsolm ls_ltap-meins
                               CHANGING ls_replenish-quantity ls_replenish-uom.

          CLEAR ls_mara.
          READ TABLE lt_mara INTO ls_mara
                             WITH KEY matnr = ls_ltap-matnr.
          IF ls_mara-mtart IN lr_mtart OR
            ls_mara-mtart = 'ZSFG'.
            CLEAR ls_marm.
            READ TABLE lt_marm INTO ls_marm
                               WITH KEY matnr = ls_mara-matnr.
            IF sy-subrc = 0.
              ls_replenish-conversi_carton = ls_marm-umrez.
              CONDENSE ls_replenish-conversi_carton NO-GAPS.
              PERFORM f_conversion USING 'OUTPUT' '' 'KAR'
                                   CHANGING lv_menge ls_replenish-uom_packing.
            ENDIF.
          ELSE.
            TRY.
                CALL FUNCTION 'ZWMFM009'
                  EXPORTING
                    pi_lgnum = ls_ltap-lgnum
                    pi_matnr = ls_ltap-matnr
                    pi_charg = ls_ltap-charg
                    pi_mtart = ls_mara-mtart
                  IMPORTING
                    pe_uom   = ls_replenish-uom_packing
                    pe_value = ls_replenish-conversi_carton.
              CATCH cx_root INTO DATA(lo_root_exception).
            ENDTRY.
          ENDIF.

*          ls_replenish-conversi_carton
*          ls_replenish-uom_packing
          ls_replenish-source_storage_section      = ls_ltap-vlber.
          ls_replenish-source_storage_type         = ls_ltap-vltyp.
          ls_replenish-source_storage_bin          = ls_ltap-vlpla.
          ls_replenish-destination_storage_section = ls_ltap-nlber.
          ls_replenish-destination_storage_type    = ls_ltap-nltyp.
          ls_replenish-destination_storage_bin     = ls_ltap-nlpla.
          ls_replenish-type                        = 'S'.
          ls_replenish-message                     = 'Success GET Data'.
          APPEND ls_replenish TO ft_replenish.
          CLEAR: ls_replenish.
        ENDLOOP.
        fs_replenish-type                        = 'S'.
        fs_replenish-message                     = 'Success GET Data'.
      ENDIF.
    ELSE.
      fs_replenish-type     = 'E'.
      fs_replenish-message  = 'Bukan User REPLENISH'.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONF_REPLENISH_SYSTEM_GUIDE
*&---------------------------------------------------------------------*
FORM f_conf_replenish_system_guide  TABLES   ft_replenish STRUCTURE zhgwmst021
                                    USING    p_json
                                    CHANGING fs_replenish TYPE zhgwmst019
                                             fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_postrepl,
         lt_repl      TYPE STANDARD TABLE OF zhgwmst021,
         ls_repl      LIKE LINE OF lt_repl,
         ls_ltak      TYPE ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         ls_lrf_wkqu  TYPE lrf_wkqu.

  DATA : lv_subrc        TYPE sy-subrc,
         lv_squit        TYPE rl03t-squit,
         lv_quknz        TYPE rl03t-quknz,
         lr_bwlvs        TYPE RANGE OF bwlvs,
         ls_bwlvs        LIKE LINE OF lr_bwlvs,
         lv_message(220).

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  lt_repl[] = ls_data-nav_postreplsys[].

  SELECT SINGLE *
    FROM lrf_wkqu
    INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
    WHERE bname = ls_data-username
      AND statu = 'X'.

  lv_squit  = 'X'.
*  lv_quknz  = '2'.

  IF ls_lrf_wkqu-queue = 'REPLENISH'.
    IF lt_repl[] IS NOT INITIAL.
      ls_bwlvs-low    = '998'.
      ls_bwlvs-sign   = 'I'.
      ls_bwlvs-option = 'EQ'.
      APPEND ls_bwlvs TO lr_bwlvs.
      ls_bwlvs-low    = '999'.
      APPEND ls_bwlvs TO lr_bwlvs.

      SELECT SINGLE *
        FROM ltak
        INTO CORRESPONDING FIELDS OF ls_ltak
        WHERE lgnum = ls_data-warehouse_number
          AND tanum = ls_data-to_number
          AND kquit = space
          AND bwlvs IN lr_bwlvs.
      IF sy-subrc = 0.
        SELECT *
          FROM ltap
          INTO CORRESPONDING FIELDS OF TABLE lt_ltap
          WHERE lgnum = ls_ltak-lgnum
            AND tanum = ls_ltak-tanum.

        CASE ls_data-process_status.
          WHEN 'SKIP'.
            PERFORM f_skip USING ls_ltak.
          WHEN 'CONFIRM'.
            PERFORM f_prepare_confirm TABLES lt_ltap
                                             lt_repl
                                             lt_ltap_conf
                                      USING ls_ltak-lgnum ls_ltak-tanum.

            PERFORM f_confirm_to TABLES lt_ltap_conf
                                 USING ls_ltak-lgnum ls_ltak-tanum
                                       lv_squit lv_quknz
                                 CHANGING lv_subrc.
            IF lv_subrc <> 0.
              fc_type  = 'E'.
              CALL FUNCTION 'ZWMSFM002'
                EXPORTING
                  pi_subrc    = lv_subrc
                  pi_function = 'L_TO_CONFIRM'
                IMPORTING
                  pe_message  = lv_message.
            ELSE.
              fc_type      = 'S'.
              lv_message   = 'Berhasil confirm'.
            ENDIF.
        ENDCASE.

        LOOP AT lt_repl INTO ls_repl.
          ls_repl-type      = fc_type.
          ls_repl-message   = lv_message.
          APPEND ls_repl TO ft_replenish.
          CLEAR : ls_repl.
        ENDLOOP.

        IF fc_type = 'E'.
          fc_message   = 'Replenishment error'.
        ELSE.
          fc_type      = 'S'.
          fc_message   = 'Replenishment success'.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    fc_type = 'E'.
    fc_message = 'Bukan user REPLENISH'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_CONFIRM
*&---------------------------------------------------------------------*
FORM f_prepare_confirm  TABLES   ft_ltap STRUCTURE ltap
                                 ft_repl STRUCTURE zhgwmst021
                                 ft_ltap_conf   STRUCTURE ltap_conf
                        USING    fu_lgnum fu_tanum.
  DATA : ls_ltap      TYPE ltap,
         ls_ltap_conf TYPE ltap_conf,
         ls_repl      TYPE zhgwmst020.

  DATA : lv_anfme(20).

  LOOP AT ft_ltap INTO ls_ltap.
    MOVE-CORRESPONDING ls_ltap TO ls_ltap_conf.
    READ TABLE ft_repl INTO ls_repl
                       WITH KEY to_item = ls_ltap-tapos.
    IF sy-subrc = 0.
      ls_ltap_conf-nista  = ls_ltap-vsola.   "ls_repl-quantity.
      PERFORM f_conversion USING 'INPUT' '' ls_ltap-altme   "ls_repl-uom
                           CHANGING lv_anfme ls_ltap_conf-altme.
    ENDIF.
    APPEND ls_ltap_conf TO ft_ltap_conf.
    CLEAR ls_ltap_conf.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SKIP
*&---------------------------------------------------------------------*
FORM f_skip  USING    fs_ltak TYPE ltak.
  TRY.
      UPDATE ltak SET queue = 'ADMIN'
                  WHERE lgnum = fs_ltak-lgnum
                    AND tanum = fs_ltak-tanum.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
ENDFORM.
