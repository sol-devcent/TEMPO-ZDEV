*----------------------------------------------------------------------*
***INCLUDE LZWMSFG001F08.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_CHECK_SINGLE
*&---------------------------------------------------------------------*
FORM f_get_check_single  TABLES   ft_entity STRUCTURE zwmst009
                         USING    fu_setname fu_lgnum fu_tanum fu_username
                                  fu_queue
                         CHANGING fc_entity TYPE zwmst009
                                  fc_subrc.

  CASE fu_setname.
    WHEN 'getcheckhSet'.
      PERFORM f_single_header USING    fu_setname fu_lgnum fu_tanum fu_queue
                              CHANGING fc_entity
                                       fc_subrc.
    WHEN 'getcheckd'.
      PERFORM f_single_detail TABLES   ft_entity
                              USING    fu_setname fu_lgnum fu_tanum fu_username
                                       fu_queue
                              CHANGING fc_subrc.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SINGLE_HEADER
*&---------------------------------------------------------------------*
FORM f_single_header  USING    fu_setname fu_lgnum fu_tanum fu_queue
                      CHANGING fc_entity TYPE zwmst009
                               fc_subrc.
  DATA : lv_mblnr   TYPE ltak-mblnr,
         lv_kquit   TYPE ltak-kquit,
         lv_lznum   TYPE ltak-lznum,
         lv_wadat   TYPE likp-wadat_ist,
         lv_mtart   TYPE mara-mtart,
         lv_ori     TYPE likp-/bev1/rpfaess,
         lv_ecer    TYPE likp-/bev1/rpkist,
         lv_rpcont  TYPE likp-/bev1/rpcont,
         lv_rpsonst TYPE likp-/bev1/rpsonst.

  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap,
         ls_ltak TYPE ltak.

  fc_entity-warehouse_number = fu_lgnum.
  fc_entity-to_number        = fu_tanum.

  SELECT SINGLE queue vbeln mblnr kquit lznum
    FROM ltak
    INTO ( fc_entity-queue, fc_entity-delivery_number, lv_mblnr, lv_kquit, lv_lznum )
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  fc_subrc = sy-subrc.

  IF fc_entity-delivery_number IS INITIAL.
    fc_entity-delivery_number = lv_mblnr.
  ENDIF.

  SELECT SINGLE kunnr wadat_ist /bev1/rpfaess /bev1/rpkist /bev1/rpcont /bev1/rpsonst
    FROM likp
    INTO ( fc_entity-customer_number, lv_wadat, lv_ori, lv_ecer, lv_rpcont, lv_rpsonst )
    WHERE vbeln = fc_entity-delivery_number.

  IF lv_lznum IS INITIAL.
    fc_entity-koli_ori  = lv_ori.
    fc_entity-koli_ecer = lv_ecer.
  ELSE.
    fc_entity-koli_ori  = '0'.
    fc_entity-koli_ecer = '0'.
  ENDIF.

  SHIFT fc_entity-koli_ori LEFT DELETING LEADING space.
  SHIFT fc_entity-koli_ecer LEFT DELETING LEADING space.

  SELECT SINGLE name1
    FROM kna1
    INTO fc_entity-customer_name
    WHERE kunnr = fc_entity-customer_number.

  SELECT SINGLE *
    FROM ltak
    INTO CORRESPONDING FIELDS OF ls_ltak
    WHERE vbeln = fc_entity-delivery_number.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fc_entity-warehouse_number
      AND tanum = fc_entity-to_number.
  IF sy-subrc = 0.
    CLEAR ls_ltap.
    READ TABLE lt_ltap INTO ls_ltap INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE mtart
        FROM mara
        INTO lv_mtart
        WHERE matnr = ls_ltap-matnr.
      IF lv_mtart = 'ZCGB' OR lv_mtart = 'ZPHA' OR lv_mtart = 'ZCGN'.
        fc_entity-fg = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lv_kquit = 'X' AND lv_wadat = '00000000'.
    fc_subrc = 3.
  ELSEIF lv_kquit = 'X' AND lv_wadat <> '00000000'.
    fc_subrc = 2.
  ENDIF.

  IF lv_kquit = 'X'.
    IF lv_rpcont IS INITIAL AND
      lv_rpsonst IS INITIAL.
      IF fc_entity-warehouse_number(1) = 'C'.
        fc_subrc = 5.
      ELSE.
        fc_subrc = 3.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SINGLE_DETAIL
*&---------------------------------------------------------------------*
FORM f_single_detail  TABLES   ft_entity STRUCTURE zwmst009
                      USING    fu_setname fu_lgnum fu_tanum fu_username
                               fu_queue
                      CHANGING fc_subrc.

  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            maktx TYPE makt-maktx,
            mtart TYPE mara-mtart,
          END OF ty_mara.

  DATA : ls_lrf_wkqu TYPE lrf_wkqu,
         lt_ltap     TYPE STANDARD TABLE OF ltap,
         lt_xltap    TYPE STANDARD TABLE OF ltap,
         lt_marm     TYPE STANDARD TABLE OF marm,
         lt_mara     TYPE STANDARD TABLE OF ty_mara,
         lt_lagp     TYPE STANDARD TABLE OF lagp,
         ls_ltap     LIKE LINE OF lt_ltap,
         ls_xltap    LIKE LINE OF lt_xltap,
         ls_mara     LIKE LINE OF lt_mara,
         ls_marm     LIKE LINE OF lt_marm,
         ls_lagp     LIKE LINE OF lt_lagp,
         ls_entity   TYPE zwmst009.

  DATA : lv_lgnum     TYPE ltak-lgnum,
         lv_tanum     TYPE ltak-tanum,
         lv_tapos     TYPE ltap-tapos,
         lv_type,
         lv_mess(220).

  lv_lgnum  = fu_lgnum.
  lv_tanum  = fu_tanum.

  IF lv_lgnum IS INITIAL OR lv_tanum IS INITIAL.
    SELECT SINGLE * FROM lrf_wkqu INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
       WHERE bname = fu_username
         AND statu = 'X'.
    IF sy-subrc EQ 0.
      lv_lgnum = ls_lrf_wkqu-lgnum.
      SELECT SINGLE tanum FROM ltak
      INTO lv_tanum
        WHERE lgnum = ls_lrf_wkqu-lgnum
          AND queue = ls_lrf_wkqu-queue
          AND kquit = space.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'ZWMFM008'
    EXPORTING
      pi_lgnum = lv_lgnum
      pi_tanum = lv_tanum
    IMPORTING
      pe_type  = lv_type
      pe_mess  = lv_mess.
  IF lv_type = 'S'.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      WHERE lgnum = lv_lgnum
        AND tanum = lv_tanum.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM marm
        INTO CORRESPONDING FIELDS OF TABLE lt_marm
        FOR ALL ENTRIES IN lt_xltap
        WHERE matnr = lt_xltap-matnr
          AND meinh = 'KAR'.

      SELECT mara~matnr makt~maktx mara~mtart
        FROM mara JOIN makt ON mara~matnr = makt~matnr
        INTO CORRESPONDING FIELDS OF TABLE lt_mara
        FOR ALL ENTRIES IN lt_xltap
        WHERE mara~matnr = lt_xltap-matnr
          AND makt~spras = sy-langu.
    ENDIF.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY lgnum vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum vltyp vlpla.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE lt_lagp
        FOR ALL ENTRIES IN lt_xltap
        WHERE lgnum = lv_lgnum
          AND lgtyp = lt_xltap-vltyp
          AND lgpla = lt_xltap-vlpla.
    ENDIF.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY lgnum vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum vltyp vlpla.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE lt_lagp
        FOR ALL ENTRIES IN lt_xltap
        WHERE lgnum = lv_lgnum
          AND lgtyp = lt_xltap-vltyp
          AND lgpla = lt_xltap-vlpla.
    ENDIF.

    CLEAR lt_xltap[].
    SORT lt_ltap BY matnr charg.
    LOOP AT lt_ltap INTO ls_ltap.
      MOVE-CORRESPONDING ls_ltap TO ls_xltap.
      CLEAR : ls_xltap-tapos, ls_xltap-posnr, ls_xltap-vlpla,
              ls_xltap-pckpf, ls_xltap-ezeit, ls_xltap-vlqnr.
      COLLECT ls_xltap INTO lt_xltap.
      CLEAR ls_xltap.
    ENDLOOP.

    LOOP AT lt_xltap INTO ls_ltap.
      ADD 1 TO lv_tapos.
      ls_entity-to_item              = lv_tapos.
      ls_entity-material_number      = ls_ltap-matnr.
      ls_entity-batch                = ls_ltap-charg.
      IF ls_ltap-pvqui IS INITIAL.
        ls_entity-type     = 'E'.
        ls_entity-message  = 'Picking belum selesai'.
      ENDIF.
      ls_entity-checking_status      = ls_ltap-pquit.

      CLEAR : ls_mara.
      READ TABLE lt_mara INTO ls_mara
                         WITH KEY matnr = ls_ltap-matnr.
      IF sy-subrc = 0.
        ls_entity-material_description = ls_mara-maktx.
      ENDIF.

      CLEAR ls_marm.
      READ TABLE lt_marm INTO ls_marm
                         WITH KEY matnr = ls_ltap-matnr.
      IF sy-subrc = 0.
        WRITE ls_marm-umrez TO ls_entity-conversi_carton NO-GROUPING.
        CONDENSE ls_entity-conversi_carton NO-GAPS.
        ls_entity-uom_packing = 'CAR'.
      ENDIF.

      CASE ls_mara-mtart.
        WHEN 'ZPM' OR 'ZRM'.
          TRY.
              CALL FUNCTION 'ZWMFM009'
                EXPORTING
                  pi_lgnum = ls_ltap-lgnum
                  pi_matnr = ls_ltap-matnr
                  pi_charg = ls_ltap-charg
                  pi_mtart = ls_mara-mtart
                IMPORTING
                  pe_uom   = ls_entity-uom_packing
                  pe_value = ls_entity-conversi_carton.
            CATCH cx_root INTO DATA(lo_cx_root).
          ENDTRY.

      ENDCASE.

      ls_entity-quantity     = ls_ltap-vsola.
      WRITE ls_ltap-vsola TO ls_entity-quantity UNIT ls_ltap-altme NO-GROUPING.
      CONDENSE ls_entity-quantity NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = ls_ltap-altme
        IMPORTING
          output         = ls_entity-uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.


      CLEAR ls_lagp.
      READ TABLE lt_lagp INTO ls_lagp
                         WITH KEY lgnum = lv_lgnum
                                  lgtyp = ls_ltap-vltyp
                                  lgpla = ls_ltap-vlpla.
      IF sy-subrc = 0.
        ls_entity-removal_indicator = ls_lagp-skzua.
      ENDIF.

      IF ls_ltap-qdatu <> '00000000'.
        WRITE ls_ltap-qzeit TO ls_entity-checking_date
        USING EDIT MASK '__:__:__'.
        CONCATENATE ls_ltap-qdatu ls_entity-checking_date
        INTO ls_entity-checking_date
        SEPARATED BY space.
      ENDIF.

      APPEND ls_entity TO ft_entity.
      CLEAR ls_entity.
    ENDLOOP.
  ELSE.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_CHECK_GROUP
*&---------------------------------------------------------------------*
FORM f_get_check_group  TABLES   ft_entity STRUCTURE zwmst009
                        USING    fu_setname fu_lgnum fu_tanum fu_username
                                 fu_queue
                        CHANGING fc_entity TYPE zwmst009
                                 fc_subrc.

  CASE fu_setname.
    WHEN 'getcheckhSet'.
      PERFORM f_group_header USING    fu_setname fu_lgnum fu_tanum fu_queue
                             CHANGING fc_entity fc_subrc.
    WHEN 'getcheckd'.
      PERFORM f_group_detail TABLES   ft_entity
                             USING    fu_setname fu_lgnum fu_tanum fu_username
                                      fu_queue
                             CHANGING fc_subrc.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GROUP_HEADER
*&---------------------------------------------------------------------*
FORM f_group_header  USING    fu_setname fu_lgnum fu_tanum fu_queue
                     CHANGING fc_entity TYPE zwmst009
                              fc_subrc.
  DATA : lt_ltak  TYPE STANDARD TABLE OF ltak,
         lt_xltak TYPE STANDARD TABLE OF ltak,
         lt_yltak TYPE STANDARD TABLE OF ltak,
         ls_ltak  LIKE LINE OF lt_ltak,
         lt_ltap  TYPE STANDARD TABLE OF ltap,
         ls_ltap  TYPE ltap.

  DATA : lv_ori     TYPE likp-/bev1/rpfaess,
         lv_ecer    TYPE likp-/bev1/rpkist,
         lv_rpcont  TYPE likp-/bev1/rpcont,
         lv_rpsonst TYPE likp-/bev1/rpsonst,
         lv_mtart   TYPE mara-mtart,
         lv_subrc   TYPE sy-subrc,
         lv_length  TYPE i.

  fc_entity-warehouse_number = fu_lgnum.
  fc_entity-to_number        = fu_tanum.

  lv_length = strlen( fu_tanum ).

  IF lv_length = 10.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = fu_lgnum
        AND lznum = fu_tanum.
  ELSEIF lv_length = 15.
    IF fu_queue IS INITIAL.
      SELECT *
        FROM ltak
        INTO CORRESPONDING FIELDS OF TABLE lt_ltak
        WHERE lgnum = fu_lgnum
          AND lznum = fu_tanum.
    ELSE.
      SELECT *
        FROM ltak
        INTO CORRESPONDING FIELDS OF TABLE lt_ltak
        WHERE lgnum = fu_lgnum
          AND queue = fu_queue.
    ENDIF.
    SORT lt_ltak BY lznum.
  ENDIF.

  lt_yltak[] = lt_xltak[] = lt_ltak[].
  DELETE lt_yltak WHERE kquit IS INITIAL.
  DELETE lt_xltak WHERE kquit IS NOT INITIAL.

  IF lt_yltak[] IS NOT INITIAL AND
    lt_xltak[] IS NOT INITIAL.
*    fc_subrc = 1.
  ELSEIF lt_yltak[] IS NOT INITIAL AND
    lt_xltak[] IS INITIAL.
    fc_subrc = 0.
    lv_subrc = 4.
  ELSEIF lt_yltak[] IS INITIAL AND
    lt_xltak[] IS NOT INITIAL.
    fc_subrc = 0.
  ENDIF.

  IF fc_subrc = 0.
    READ TABLE lt_ltak INTO ls_ltak INDEX 1.
    IF sy-subrc = 0.
      fc_entity-queue = ls_ltak-queue.

      SELECT SINGLE /bev1/rpfaess /bev1/rpkist /bev1/rpcont /bev1/rpsonst
        FROM likp
        INTO ( lv_ori, lv_ecer, lv_rpcont, lv_rpsonst )
        WHERE vbeln = ls_ltak-vbeln.

      fc_entity-koli_ori  = lv_ori.
      fc_entity-koli_ecer = lv_ecer.

      SHIFT fc_entity-koli_ori LEFT DELETING LEADING space.
      SHIFT fc_entity-koli_ecer LEFT DELETING LEADING space.

      SELECT *
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        FOR ALL ENTRIES IN lt_ltak
        WHERE lgnum = lt_ltak-lgnum
          AND tanum = lt_ltak-tanum
          AND pvqui = space.
      IF lt_ltap[] IS NOT INITIAL.
        fc_subrc = 1.
      ELSE.
        READ TABLE lt_ltap INTO ls_ltap INDEX 1.
        IF sy-subrc = 0.
          SELECT SINGLE mtart
            FROM mara
            INTO lv_mtart
            WHERE matnr = ls_ltap-matnr.
          IF lv_mtart = 'ZCGB' OR lv_mtart = 'ZPHA' OR lv_mtart = 'ZCGN'.
            fc_entity-fg = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_subrc <> 0.
      IF lv_rpcont = 0 AND
        lv_rpsonst = 0.
        fc_subrc = 5.
      ELSE.
        fc_subrc = 5.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GROUP_DETAIL
*&---------------------------------------------------------------------*
FORM f_group_detail  TABLES   ft_entity STRUCTURE zwmst009
                     USING    fu_setname fu_lgnum fu_tanum fu_username
                              fu_queue
                     CHANGING fc_subrc.
  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            maktx TYPE makt-maktx,
            mtart TYPE mara-mtart,
          END OF ty_mara.

  DATA : lt_ltak   TYPE STANDARD TABLE OF ltak,
         lt_xltak  TYPE STANDARD TABLE OF ltak,
         lt_ltap   TYPE STANDARD TABLE OF ltap,
         lt_xltap  TYPE STANDARD TABLE OF ltap,
         lt_marm   TYPE STANDARD TABLE OF marm,
         lt_mara   TYPE STANDARD TABLE OF ty_mara,
         ls_xltak  LIKE LINE OF lt_xltak,
         ls_ltap   LIKE LINE OF lt_ltap,
         ls_xltap  LIKE LINE OF lt_xltap,
         ls_mara   LIKE LINE OF lt_mara,
         ls_marm   LIKE LINE OF lt_marm,
         ls_entity TYPE zwmst009.

  DATA : lv_tapos   TYPE ltap-tapos.

  IF fu_tanum IS NOT INITIAL.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = fu_lgnum
        AND lznum = fu_tanum.
  ELSE.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = fu_lgnum
        AND queue = fu_queue
        AND kquit = space.

    lt_xltak[] = lt_ltak[].
    SORT lt_xltak BY lznum.
    DELETE ADJACENT DUPLICATES FROM lt_xltak COMPARING lznum.
    READ TABLE lt_xltak INTO ls_xltak INDEX 1.
    DELETE lt_ltak WHERE lznum <> ls_xltak-lznum.
  ENDIF.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum
        AND pquit = space.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM marm
        INTO CORRESPONDING FIELDS OF TABLE lt_marm
        FOR ALL ENTRIES IN lt_xltap
        WHERE matnr = lt_xltap-matnr
          AND meinh = 'KAR'.

      SELECT mara~matnr makt~maktx mara~mtart
        FROM mara JOIN makt ON mara~matnr = makt~matnr
        INTO CORRESPONDING FIELDS OF TABLE lt_mara
        FOR ALL ENTRIES IN lt_xltap
        WHERE mara~matnr = lt_xltap-matnr
          AND makt~spras = sy-langu.
    ENDIF.

    CLEAR lt_xltap[].
    SORT lt_ltap BY matnr charg.
    LOOP AT lt_ltap INTO ls_ltap.
      ls_xltap-lgnum   = ls_ltap-lgnum.
      ls_xltap-matnr   = ls_ltap-matnr.
      ls_xltap-charg   = ls_ltap-charg.
      ls_xltap-vsola   = ls_ltap-vsola.
      ls_xltap-altme   = ls_ltap-altme.
      COLLECT ls_xltap INTO lt_xltap.
      CLEAR ls_xltap.
    ENDLOOP.

    LOOP AT lt_xltap INTO ls_xltap.
      ADD 1 TO lv_tapos.
      ls_entity-to_item              = lv_tapos.
      ls_entity-material_number      = ls_xltap-matnr.
      ls_entity-batch                = ls_xltap-charg.

      CLEAR : ls_mara.
      READ TABLE lt_mara INTO ls_mara
                         WITH KEY matnr = ls_xltap-matnr.
      IF sy-subrc = 0.
        ls_entity-material_description = ls_mara-maktx.
      ENDIF.

      ls_entity-quantity             = ls_xltap-vsola.
      WRITE ls_xltap-vsola TO ls_entity-quantity UNIT ls_xltap-altme NO-GROUPING.
      CONDENSE ls_entity-quantity NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = ls_xltap-altme
        IMPORTING
          output         = ls_entity-uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      CLEAR ls_marm.
      READ TABLE lt_marm INTO ls_marm
                         WITH KEY matnr = ls_xltap-matnr.
      IF sy-subrc = 0.
        WRITE ls_marm-umrez TO ls_entity-conversi_carton NO-GROUPING.
        CONDENSE ls_entity-conversi_carton NO-GAPS.
        ls_entity-uom_packing = 'CAR'.
      ENDIF.

      CASE ls_mara-mtart.
        WHEN 'ZPM' OR 'ZRM'.
          TRY.
              CALL FUNCTION 'ZWMFM009'
                EXPORTING
                  pi_lgnum = ls_xltap-lgnum
                  pi_matnr = ls_xltap-matnr
                  pi_charg = ls_xltap-charg
                  pi_mtart = ls_mara-mtart
                IMPORTING
                  pe_uom   = ls_entity-uom_packing
                  pe_value = ls_entity-conversi_carton.
            CATCH cx_root INTO DATA(lo_cx_root).
          ENDTRY.
      ENDCASE.

      READ TABLE lt_ltap INTO ls_ltap
                         WITH KEY matnr = ls_xltap-matnr
                                  charg = ls_xltap-charg.
      IF sy-subrc = 0.
        IF ls_ltap-qdatu <> '00000000'.
          WRITE ls_ltap-qzeit TO ls_entity-checking_date
          USING EDIT MASK '__:__:__'.
          CONCATENATE ls_ltap-qdatu ls_entity-checking_date
          INTO ls_entity-checking_date
          SEPARATED BY space.
        ENDIF.
      ENDIF.

      APPEND ls_entity TO ft_entity.
      CLEAR ls_entity.
    ENDLOOP.
  ENDIF.
ENDFORM.
