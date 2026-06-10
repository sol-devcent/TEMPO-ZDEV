*----------------------------------------------------------------------*
***INCLUDE LZWMSFG001F07.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_GROUPING
*&---------------------------------------------------------------------*
FORM f_process_grouping  TABLES   ft_pick STRUCTURE zwmsst013
                         USING    fu_lgnum fu_lznum.
  TYPES : BEGIN OF ty_ltap,
            lgnum TYPE ltap-lgnum,
            vltyp TYPE ltap-vltyp,
            vlpla TYPE ltap-vlpla,
            matnr TYPE ltap-matnr,
            maktx TYPE ltap-maktx,
            charg TYPE ltap-charg,
            vsolm TYPE ltap-vsolm,
            meins TYPE ltap-meins,
            vfdat TYPE ltap-vfdat,
            pvqui TYPE ltap-pvqui,
            edatu TYPE ltap-edatu,
            ezeit TYPE ltap-ezeit,
            qdatu TYPE ltap-qdatu,
            qzeit TYPE ltap-qzeit,
            "            stuzt type ltak-stuzt,
          END OF ty_ltap.

  DATA : lt_ltak  TYPE STANDARD TABLE OF ltak,
         lt_ltap  TYPE STANDARD TABLE OF ltap,
         ls_ltap  LIKE LINE OF lt_ltap,
         ls_ltak  LIKE LINE OF lt_ltak,
         lt_yltap TYPE STANDARD TABLE OF ltap,
         lt_xltap TYPE STANDARD TABLE OF ty_ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         ls_pick  TYPE zwmsst013,
         lt_lagp  TYPE STANDARD TABLE OF lagp,
         ls_lagp  LIKE LINE OF lt_lagp,
         lt_mara  TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF lt_mara,
         lt_marm  TYPE STANDARD TABLE OF marm,
         ls_marm  LIKE LINE OF lt_marm.

  DATA : lv_tapos        TYPE ltap-tapos,
         lv_uzeit(8),
         lv_namechar(30).

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fu_lgnum
      AND lznum = fu_lznum.

  IF lt_ltak[] IS NOT INITIAL.
    LOOP AT lt_ltak INTO ls_ltak.

    ENDLOOP.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum.

    lt_yltap[] = lt_ltap[].
    SORT lt_yltap BY lgnum vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING lgnum vltyp vlpla.
    IF lt_yltap[] IS NOT INITIAL.
      SELECT *
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE lt_lagp
        FOR ALL ENTRIES IN lt_yltap
        WHERE lgnum = lt_yltap-lgnum
          AND lgtyp = lt_yltap-vltyp
          AND lgpla = lt_yltap-vlpla.
    ENDIF.

    lt_yltap[] = lt_ltap[].
    SORT lt_yltap BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_yltap COMPARING matnr.
    IF lt_yltap[] IS NOT INITIAL.
      SELECT *
        FROM mara
        INTO CORRESPONDING FIELDS OF TABLE lt_mara
        FOR ALL ENTRIES IN lt_yltap
        WHERE matnr = lt_yltap-matnr.

      SELECT *
        FROM marm
        INTO CORRESPONDING FIELDS OF TABLE lt_marm
        FOR ALL ENTRIES IN lt_yltap
        WHERE matnr = lt_yltap-matnr
          AND meinh = 'KAR'.
    ENDIF.

    SORT lt_ltap BY vltyp vlpla matnr charg.
    LOOP AT lt_ltap INTO ls_ltap.
      MOVE-CORRESPONDING ls_ltap TO ls_xltap.
      COLLECT ls_xltap INTO lt_xltap.
    ENDLOOP.

    LOOP AT lt_xltap INTO ls_xltap.
      ADD 1 TO lv_tapos.
      ls_pick-lgnum = ls_xltap-lgnum.
      ls_pick-tapos = lv_tapos.
      ls_pick-matnr = ls_xltap-matnr.
      ls_pick-maktx = ls_xltap-maktx.
      ls_pick-charg = ls_xltap-charg.
      ls_pick-vfdat = ls_xltap-vfdat.
      ls_pick-lgtyp = ls_xltap-vltyp.
      ls_pick-lgpla = ls_xltap-vlpla.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = ls_xltap-meins
        IMPORTING
          output         = ls_pick-uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      WRITE ls_xltap-vsolm TO ls_pick-quantity UNIT ls_xltap-meins.
      TRANSLATE ls_pick-quantity USING '. '.
      TRANSLATE ls_pick-quantity USING ',.'.
      CONDENSE ls_pick-quantity NO-GAPS.

      CLEAR ls_lagp.
      READ TABLE lt_lagp INTO ls_lagp
                         WITH KEY lgnum = ls_xltap-lgnum
                                  lgtyp = ls_xltap-vltyp
                                  lgpla = ls_xltap-vlpla.
      IF sy-subrc = 0.
        ls_pick-sort_pick         = ls_lagp-reihf.
        ls_pick-removal_indicator = ls_lagp-skzua.
      ENDIF.

      CLEAR ls_mara.
      READ TABLE lt_mara INTO ls_mara
                         WITH KEY matnr = ls_xltap-matnr.
      IF sy-subrc = 0.
        CASE ls_mara-mtart.
          WHEN 'ZPM' OR 'ZRM'.
            IF ls_xltap-charg IS NOT INITIAL.
              TRY.
                  CALL FUNCTION 'ZWMFM009'
                    EXPORTING
                      pi_lgnum = ls_xltap-lgnum
                      pi_matnr = ls_xltap-matnr
                      pi_charg = ls_xltap-charg
                      pi_mtart = ls_mara-mtart
                    IMPORTING
                      pe_uom   = ls_pick-uom_packing
                      pe_value = ls_pick-conversi_carton.
                CATCH cx_root INTO DATA(lo_root_exception).
              ENDTRY.

            ENDIF.
          WHEN OTHERS.
            CLEAR ls_marm.
            READ TABLE lt_marm INTO ls_marm
                               WITH KEY matnr = ls_xltap-matnr.
            IF sy-subrc = 0.
              ls_pick-uom_packing   = 'CAR'.
              WRITE ls_marm-umrez TO ls_pick-conversi_carton NO-GROUPING.
              CONDENSE ls_pick-conversi_carton NO-GAPS.
            ENDIF.
        ENDCASE.

        IF ls_pick-uom_packing IS INITIAL.
          ls_pick-conversi_carton      = 1.
          CONDENSE ls_pick-conversi_carton NO-GAPS.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_mara-meins
            IMPORTING
              output         = ls_pick-uom_packing
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
        ENDIF.

        IF ls_xltap-charg IS NOT INITIAL.
          lv_namechar = 'ZMF'.
          TRY.
              CALL FUNCTION 'ZWMFM009'
                EXPORTING
                  pi_lgnum    = ls_xltap-lgnum
                  pi_matnr    = ls_xltap-matnr
                  pi_charg    = ls_xltap-charg
                  pi_mtart    = ls_mara-mtart
                  pi_namechar = lv_namechar
                IMPORTING
                  pe_charval  = ls_pick-manufacturer.
            CATCH cx_root INTO lo_root_exception.
          ENDTRY.

        ENDIF.
      ENDIF.

      CLEAR : lv_uzeit.
      IF ls_xltap-qdatu <> '00000000'.
        WRITE ls_xltap-qzeit TO lv_uzeit USING EDIT MASK '__:__:__'.
        ls_pick-picking_start = |{ ls_xltap-qdatu } { lv_uzeit }|.
      ELSE.
        WRITE ls_ltak-stuzt TO lv_uzeit USING EDIT MASK '__:__:__'.
        ls_pick-picking_start = |{ ls_ltak-stdat } { lv_uzeit }|.
      ENDIF.
      CLEAR : lv_uzeit.
      IF ls_xltap-edatu <> '00000000'.
        WRITE ls_xltap-ezeit TO lv_uzeit USING EDIT MASK '__:__:__'.
        ls_pick-picking_end = |{ ls_xltap-edatu } { lv_uzeit }|.
      ENDIF.

      ls_pick-pickconf_status = ls_xltap-pvqui.

      APPEND ls_pick TO ft_pick.
      CLEAR ls_pick.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POST_GROUP_PICKING
*&---------------------------------------------------------------------*
FORM f_post_group_picking  TABLES   ft_picking STRUCTURE zwmsst002
                                    ft_pickd STRUCTURE zwmsst002
                           USING    fu_lgnum fu_lznum fu_vbeln
                           CHANGING fc_type fc_message fc_drukz.

  DATA : lt_ltak      TYPE STANDARD TABLE OF ltak,
         ls_ltak      LIKE LINE OF lt_ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      LIKE LINE OF lt_ltap,
         ls_xltap     LIKE LINE OF lt_ltap,
         ls_pickd     TYPE zwmsst002,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         ls_ltap_conf LIKE LINE OF lt_ltap_conf,
         ls_rl03t     TYPE rl03t.

  DATA : lv_qdatu        TYPE ltap-qdatu,
         lv_qzeit        TYPE ltap-qzeit,
         lv_edatu        TYPE ltap-edatu,
         lv_ezeit        TYPE ltap-ezeit,
         lv_uname        TYPE sy-uname,
         lv_subrc        TYPE sy-subrc,
         lv_message(220),
         lv_vsolm        TYPE ltap-vsolm,
         lv_xsolm        TYPE ltap-vsolm,
         lv_altme        TYPE ltap-altme,
         lv_tanum        TYPE ltak-tanum.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fu_lgnum
      AND lznum = fu_lznum.

  IF lt_ltak[] IS NOT INITIAL.
    CLEAR ls_pickd.
*    READ TABLE ft_pickd INTO ls_pickd INDEX 1.
*    SELECT *
*      FROM ltap
*      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
*      FOR ALL ENTRIES IN lt_ltak
*      WHERE lgnum = lt_ltak-lgnum
*        AND tanum = lt_ltak-tanum
*        AND vltyp = ls_pickd-storage_type
*        AND vlpla = ls_pickd-storage_bin.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum.

    READ TABLE lt_ltak INTO ls_ltak INDEX 1.

    LOOP AT ft_pickd INTO ls_pickd.
      CLEAR : lt_ltap_conf[], lv_qdatu, lv_qzeit, lv_edatu, lv_ezeit.
      PERFORM f_datetime USING ls_pickd-picking_start
                         CHANGING lv_qdatu lv_qzeit.
      PERFORM f_invalid_date USING ls_ltak-stdat ls_ltak-stuzt
                             CHANGING ls_pickd-picking_start
                                      lv_qdatu lv_qzeit.

      PERFORM f_datetime USING ls_pickd-picking_end
                         CHANGING lv_edatu lv_ezeit.
      lv_uname  = ls_pickd-user_name.

      PERFORM f_check USING ls_pickd-quantity_carton
                      CHANGING lv_subrc.
      PERFORM f_check USING ls_pickd-quantity_satuan
                      CHANGING lv_subrc.

      IF lv_subrc = 0.
*        CLEAR : ls_ltap.
*        READ TABLE lt_ltap INTO ls_ltap INDEX 1.
*        IF sy-subrc = 0.
        PERFORM f_quantity_calculate USING fu_lgnum
                                           ls_pickd-material_number
                                           ls_pickd-batch
                                           ls_pickd-quantity_satuan
                                           ls_pickd-uom_satuan
                                           ls_pickd-quantity_carton
                                           ls_pickd-uom_carton
                                     CHANGING lv_vsolm.
*        ENDIF.

        CLEAR : ls_xltap.
        SORT lt_ltap BY tanum tapos.
        LOOP AT lt_ltap INTO ls_xltap WHERE matnr = ls_pickd-material_number
                                        AND charg = ls_pickd-batch
                                        AND vltyp = ls_pickd-storage_type
                                        AND vlpla = ls_pickd-storage_bin.
          CLEAR : lt_ltap_conf[].
          ADD ls_xltap-vsolm TO lv_xsolm.
          lv_vsolm = lv_vsolm - ls_xltap-vsolm.
          IF lv_vsolm < 0.
            ls_ltap_conf-kzdif = '4'.
            ls_ltap_conf-ndifa = lv_vsolm * -1.
            ls_ltap_conf-nista = ls_xltap-vsolm - ls_ltap_conf-ndifa.
            PERFORM f_unit_conversion_input USING ls_pickd-uom_satuan
                                            CHANGING lv_altme.
            ls_ltap_conf-altme = lv_altme.
          ELSE.
            ls_ltap_conf-squit = 'X'.
          ENDIF.

          ls_ltap_conf-tanum = ls_xltap-tanum.
          ls_ltap_conf-tapos = ls_xltap-tapos.
          APPEND ls_ltap_conf TO lt_ltap_conf.
          CLEAR ls_ltap_conf.

          ls_rl03t-squit = space.
          IF ls_ltak-kgvnq = 'X'.
            ls_rl03t-quknz = '1'.
          ENDIF.

          PERFORM f_to_confirm TABLES lt_ltap_conf
                                      ft_picking
                               USING ls_xltap-lgnum
                                     ls_xltap-tanum
                                     ls_xltap-nltyp
                                     ls_pickd
                                     ls_rl03t
                                     ls_ltak-queue
                               CHANGING lv_subrc.

          IF lv_subrc = 0.
            IF ls_ltak-queue(7) = 'CHECKER'.
            ELSE.
              PERFORM f_update_checker TABLES lt_ltak
                                       USING ls_xltap-lgnum
                                       CHANGING fc_drukz.
*              IF ls_ltak-stdat IS INITIAL.
              TRY.
                  UPDATE ltak SET stdat = lv_qdatu
                                  stuzt = lv_qzeit
                              WHERE lgnum = ls_xltap-lgnum
                                AND tanum = ls_xltap-tanum.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
*              ENDIF.

              TRY .
                  UPDATE ltap SET edatu = lv_edatu
                                  ezeit = lv_ezeit
                                  ename = lv_uname
                                  zrstg = 'X'
                              WHERE tanum = ls_xltap-tanum
                                AND tapos = ls_xltap-tapos
                                AND vlpla = ls_pickd-storage_bin
                                AND lgnum = ls_xltap-lgnum.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
            ENDIF.
          ENDIF.
        ENDLOOP.

        PERFORM f_result_to_group TABLES ft_picking.
      ELSE.
        ls_pickd-type     = 'E'.
        ls_pickd-message  = 'Input quantity salah'.
        APPEND ls_pickd TO ft_picking.
        fc_type    = 'E'.
        fc_message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RESULT_TO_GROUP
*&---------------------------------------------------------------------*
FORM f_result_to_group  TABLES   ft_picking STRUCTURE zwmsst002.
  DATA : ls_picking TYPE zwmsst002.

  READ TABLE ft_picking INTO ls_picking
                        WITH KEY type = 'E'.
  IF sy-subrc = 0.
    DELETE ft_picking WHERE type <> 'E'.
  ENDIF.
  SORT ft_picking BY to_item.
  DELETE ADJACENT DUPLICATES FROM ft_picking COMPARING to_item.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_CHECKER
*&---------------------------------------------------------------------*
FORM f_update_checker  TABLES   ft_ltak STRUCTURE ltak
                       USING    fu_lgnum
                       CHANGING fc_drukz.
  DATA : lt_xltap    TYPE STANDARD TABLE OF ltap,
         ls_ltak     TYPE ltak,
         lt_lrf_wkqu TYPE STANDARD TABLE OF lrf_wkqu,
         ls_lrf_wkqu LIKE LINE OF lt_lrf_wkqu,
         lr_queue    TYPE RANGE OF queue,
         ls_queue    LIKE LINE OF lr_queue.

  CLEAR : lr_queue[].
  ls_queue-low    = 'CHECKER*'.
  ls_queue-sign   = 'I'.
  ls_queue-option = 'CP'.
  APPEND ls_queue TO lr_queue.

  SELECT *
    FROM lrf_wkqu
    INTO CORRESPONDING FIELDS OF TABLE lt_lrf_wkqu
    WHERE lgnum = fu_lgnum
      AND queue IN lr_queue
      AND statu = 'X'
   ORDER BY PRIMARY KEY.

  READ TABLE lt_lrf_wkqu INTO ls_lrf_wkqu INDEX 1.
  IF sy-subrc = 0.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_xltap
      FOR ALL ENTRIES IN ft_ltak
      WHERE lgnum = ft_ltak-lgnum
        AND tanum = ft_ltak-tanum
        AND pvqui = space.
    IF sy-subrc <> 0.
      CLEAR : lr_queue[].
      ls_queue-low    = '*CL'.
      ls_queue-sign   = 'I'.
      ls_queue-option = 'CP'.
      APPEND ls_queue TO lr_queue.
      ls_queue-low    = '*AC'.
      APPEND ls_queue TO lr_queue.

      IF ls_lrf_wkqu-queue IN lr_queue.
        fc_drukz = '48'.
      ELSE.
        fc_drukz = '47'.
      ENDIF.

      LOOP AT ft_ltak INTO ls_ltak.
        TRY.
            UPDATE ltak SET queue = ls_lrf_wkqu-queue
                            drukz = fc_drukz
                        WHERE lgnum = ls_ltak-lgnum
                          AND tanum = ls_ltak-tanum.
          CATCH cx_sy_open_sql_db.
        ENDTRY.
        COMMIT WORK AND WAIT.
      ENDLOOP.
    ENDIF.
  ELSE.
    fc_drukz = '48'.
    LOOP AT ft_ltak INTO ls_ltak.
      TRY.
          UPDATE ltak SET queue = 'CHECKERCL'
                          drukz = fc_drukz
                      WHERE lgnum = ls_ltak-lgnum
                        AND tanum = ls_ltak-tanum.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDLOOP.
  ENDIF.
ENDFORM.
