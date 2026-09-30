*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_STP
*&---------------------------------------------------------------------*
FORM f_get_stp  TABLES   ft_stp STRUCTURE zhgwmst005
                USING    fu_lgnum fu_tanum
                CHANGING fc_type fc_message.
  DATA : lt_ltap  TYPE STANDARD TABLE OF ltap,
         lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_ltap  LIKE LINE OF lt_ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         ls_stp   TYPE zhgwmst005,
         lt_mara  TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF lt_mara,
         lt_marm  TYPE STANDARD TABLE OF marm,
         ls_marm  LIKE LINE OF lt_marm.

  DATA : lv_menge        TYPE mseg-menge,
         lv_tbnum        TYPE ltak-tbnum,
         lv_rsnum        TYPE resb-rsnum,
         lv_tbktx        TYPE ltbk-tbktx,
         lv_lznum        TYPE ltbk-lznum,
         lv_namechar(30).

  SELECT SINGLE tbnum
    FROM ltak
    INTO lv_tbnum
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  SELECT SINGLE tbktx lznum
    FROM ltbk
    INTO (lv_tbktx, lv_lznum)
    WHERE lgnum = fu_lgnum
      AND tbnum = lv_tbnum.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  lt_xltap[] = lt_ltap[].
  SORT lt_xltap BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr.
  IF lt_xltap[] IS NOT INITIAL.
    SELECT matnr mtart
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_xltap
      WHERE matnr = lt_xltap-matnr.

    IF lt_mara[] IS NOT INITIAL.
      SELECT *
        FROM marm
        INTO CORRESPONDING FIELDS OF TABLE lt_marm
        FOR ALL ENTRIES IN lt_mara
        WHERE matnr = lt_mara-matnr
          AND meinh = 'KAR'.
    ENDIF.
  ENDIF.

  LOOP AT lt_ltap INTO ls_ltap.
    ls_stp-to_item              = ls_ltap-tapos.
    ls_stp-material_number      = ls_ltap-matnr.
    ls_stp-material_description = ls_ltap-maktx.
    ls_stp-batch                = ls_ltap-charg.
    PERFORM f_conversion USING 'OUTPUT'	ls_ltap-vista ls_ltap-meins
                         CHANGING ls_stp-quantity ls_stp-uom.

    CLEAR : ls_mara.
    READ TABLE lt_mara INTO ls_mara
                       WITH KEY matnr = ls_ltap-matnr.

    TRY.
        CALL FUNCTION 'ZWMFM009'
          EXPORTING
            pi_lgnum = fu_lgnum
            pi_matnr = ls_ltap-matnr
            pi_charg = ls_ltap-charg
            pi_mtart = ls_mara-mtart
          IMPORTING
            pe_uom   = ls_stp-uom_packing
            pe_value = ls_stp-conversi_packing.
      CATCH cx_root INTO DATA(lo_root_exception).
    ENDTRY.

    IF ls_stp-uom_packing IS INITIAL.
      CLEAR ls_marm.
      READ TABLE lt_marm INTO ls_marm
                         WITH KEY matnr = ls_ltap-matnr.
      IF sy-subrc = 0.
        ls_stp-conversi_packing = ls_marm-umrez / ls_marm-umren.
        CONDENSE ls_stp-conversi_packing NO-GAPS.
        PERFORM f_conversion USING 'OUTPUT' '' ls_marm-meinh
                             CHANGING lv_menge ls_stp-uom_packing.
      ENDIF.
    ENDIF.

    lv_namechar = 'ZMF'.
    TRY.
        CALL FUNCTION 'ZWMFM009'
          EXPORTING
            pi_lgnum    = fu_lgnum
            pi_matnr    = ls_ltap-matnr
            pi_charg    = ls_ltap-charg
            pi_mtart    = ls_mara-mtart
            pi_namechar = lv_namechar
          IMPORTING
            pe_charval  = ls_stp-manufacturer.
      CATCH cx_root INTO lo_root_exception.
    ENDTRY.

    ls_stp-process_order  = lv_lznum.
    ls_stp-reservasi_no   = lv_tbktx(10).
    APPEND ls_stp TO ft_stp.
    CLEAR ls_stp.
  ENDLOOP.
ENDFORM.
