*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_PICKING_SYSTEM_GUIDE
*&---------------------------------------------------------------------*
FORM f_get_picking_system_guide  TABLES   ft_tosys STRUCTURE zhgwmst003
                                 USING    fu_username
                                 CHANGING fs_picksys  TYPE zhgwmst004
                                          fc_type fc_message.

  DATA : ls_lrf_wkqu TYPE lrf_wkqu,
         ls_t3130a   TYPE t3130a.

  DATA : lv_stext TYPE t3130b-stext,
         lr_queue TYPE RANGE OF queue,
         ls_queue LIKE LINE OF lr_queue.

  SELECT SINGLE *
    FROM lrf_wkqu
    INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
    WHERE bname = fu_username
      AND statu = 'X'.

  IF sy-subrc = 0.
*    SELECT SINGLE stext
*      FROM t3130a JOIN t3130b ON t3130a~lgnum    = t3130b~lgnum
*                             AND t3130a~mmenu    = t3130b~mmenu
*                             AND t3130a~sequence = t3130b~sequence
*      INTO lv_stext
*      WHERE t3130a~lgnum     = ls_lrf_wkqu-lgnum
*        AND t3130a~men_trans = 'PICKING_SYSTEMGUIDE'
*        AND t3130b~spras     = sy-langu.
    ls_queue-low    = '*CL'.
    ls_queue-sign   = 'E'.
    ls_queue-option = 'CP'.
    APPEND ls_queue TO lr_queue.
    ls_queue-low    = '*AC'.
    APPEND ls_queue TO lr_queue.
    IF ls_lrf_wkqu-queue IN lr_queue.
      PERFORM f_get_picking_sys TABLES ft_tosys
                                USING fu_username ls_lrf_wkqu
                                CHANGING fs_picksys fc_type fc_message.
    ELSE.
      PERFORM f_get_picking_sys_grp TABLES ft_tosys
                                    USING fu_username ls_lrf_wkqu
                                    CHANGING fs_picksys fc_type fc_message.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PICKING_SYS
*&---------------------------------------------------------------------*
FORM f_get_picking_sys  TABLES   ft_tosys STRUCTURE zhgwmst003
                        USING    fu_username fs_lrf_wkqu TYPE lrf_wkqu
                        CHANGING fs_picksys  TYPE zhgwmst004
                                 fc_type fc_message.
  DATA : lt_ltak  TYPE STANDARD TABLE OF ltak,
         ls_ltak  TYPE ltak,
         lt_ltap  TYPE STANDARD TABLE OF ltap,
         ls_ltap  LIKE LINE OF lt_ltap,
         lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap,
         lt_lagp  TYPE STANDARD TABLE OF lagp,
         ls_lagp  LIKE LINE OF lt_lagp,
         lt_mara  TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF lt_mara,
         lt_marm  TYPE STANDARD TABLE OF marm,
         ls_marm  LIKE LINE OF lt_marm,
         lt_likp  TYPE STANDARD TABLE OF likp,
         ls_likp  LIKE LINE OF lt_likp,
         lr_mtart TYPE RANGE OF mtart,
         ls_mtart LIKE LINE OF lr_mtart,
         ls_tosys TYPE zhgwmst003,
         lt_sort  TYPE abap_sortorder_tab.

  DATA : lv_bwlvs    TYPE ltak-bwlvs,
         lv_fg       TYPE i,
         lv_nfg      TYPE i,
         lv_menge    TYPE c LENGTH 20,
         lv_actvty   TYPE t333-abild,
         lv_uzeit(8),
         lv_tapos    TYPE ltap-tapos.

  lv_bwlvs    = '601'.

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



  CALL FUNCTION 'SELECT_LOCK_TO_BY_SYSTEM'
    EXPORTING
      i_whs_id           = fs_lrf_wkqu-lgnum
      i_uprof            = fs_lrf_wkqu-queue
      i_actvty           = lv_actvty
    TABLES
      t_headers          = lt_ltak
      t_items            = lt_xltap
      t_chosen_sort      = lt_sort
    EXCEPTIONS
      wrong_whs_id       = 1
      no_authority       = 2
      to_doesnt_exist    = 3
      to_is_locked       = 4
      internal_error     = 5
      tr_is_locked       = 6
      psch_is_locked     = 7
      dlvr_is_locked     = 8
      to_conf            = 9
      no_ship_doc        = 10
      material_error     = 11
      rsrv_lock          = 12
      wrong_mvtyp        = 13
      to_problem         = 14
      empty_header_table = 15
      no_to_selected     = 16
      OTHERS             = 17.

  fs_picksys-username         = fu_username.
  fs_picksys-warehouse_number = fs_lrf_wkqu-lgnum.
  fs_picksys-queue            = fs_lrf_wkqu-queue.


  READ TABLE lt_ltak INTO ls_ltak INDEX 1.

  IF sy-subrc = 0.
*    SELECT *
*      FROM ltap
*      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
*      WHERE lgnum = fs_lrf_wkqu-lgnum
*        AND tanum = ls_ltak-tanum
*        AND pvqui = space.
****    PERFORM f_lock_data USING fs_lrf_wkqu-lgnum
****                                  ls_ltak-lznum.
****    PERFORM f_check_lock USING ls_ltak-lgnum ls_ltak-lznum
****                         CHANGING sy-subrc.

    SORT lt_xltap BY lgnum tanum matnr charg vltyp vlpla.
    LOOP AT lt_xltap INTO ls_xltap.
      CLEAR : ls_xltap-tapos, ls_xltap-posnr.
      COLLECT ls_xltap INTO lt_ltap.
      CLEAR ls_xltap.
    ENDLOOP.


    CLEAR lt_xltap[].

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING vltyp vlpla.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE lt_lagp
        FOR ALL ENTRIES IN lt_xltap
        WHERE lgnum = lt_xltap-lgnum
          AND lgtyp = lt_xltap-vltyp
          AND lgpla = lt_xltap-vlpla.
    ENDIF.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY matnr.
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

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING vbeln.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN lt_xltap
        WHERE vbeln = lt_xltap-vbeln.
    ENDIF.

    fs_picksys-to_number         = ls_ltak-tanum.
    fs_picksys-delivery_number   = ls_ltak-vbeln.
    fs_picksys-staging           = ls_ltak-lgbzo.

    READ TABLE lt_likp INTO ls_likp INDEX 1.
    IF sy-subrc = 0.
      fs_picksys-customer_number = ls_likp-kunnr.
      SELECT SINGLE name1
        FROM kna1
        INTO fs_picksys-customer_name
        WHERE kunnr = ls_likp-kunnr.
    ENDIF.

    LOOP AT lt_mara INTO ls_mara.
      IF ls_mara-mtart IN lr_mtart.
        ADD 1 TO lv_fg.
      ELSE.
        ADD 1 TO lv_nfg.
      ENDIF.
    ENDLOOP.

    IF lv_fg <> 0 AND
      lv_nfg <> 0.
      fs_picksys-type     = 'E'.
      fs_picksys-message  = 'Material mix'.
    ELSEIF lv_fg <> 0 AND
      lv_nfg = 0.
      fs_picksys-fg       = 'X'.
      fs_picksys-type     = 'S'.
      fs_picksys-message  = 'GET Data'.
    ELSEIF lv_fg = 0 AND
      lv_nfg <> 0.
      fs_picksys-type     = 'S'.
      fs_picksys-message  = 'GET Data'.
    ENDIF.
  ELSE.
    fs_picksys-type     = 'E'.
    fs_picksys-message  = 'Data not found'.
  ENDIF.


  IF fs_picksys-type = 'S'.
    LOOP AT lt_ltap INTO ls_ltap.

      ADD 1 TO lv_tapos.
      ls_tosys-to_item              = lv_tapos.
      ls_tosys-material_number      = ls_ltap-matnr.
      ls_tosys-material_description = ls_ltap-maktx.
      ls_tosys-batch                = ls_ltap-charg.
      ls_tosys-exp_date             = ls_ltap-vfdat.

      IF ls_ltap-edatu <> '00000000'.
        WRITE ls_ltap-ezeit TO lv_uzeit USING EDIT MASK '__:__:__' .
        CONCATENATE ls_ltap-edatu lv_uzeit
        INTO ls_tosys-picking_start
        SEPARATED BY space.
      ENDIF.

      IF ls_ltap-qzeit <> '00000000'.
        WRITE ls_ltap-qzeit TO lv_uzeit USING EDIT MASK '__:__:__' .
        CONCATENATE ls_ltap-qdatu lv_uzeit
        INTO ls_tosys-picking_end
        SEPARATED BY space.
      ENDIF.

      ls_tosys-storage_type         = ls_ltap-vltyp.
      ls_tosys-storage_bin          = ls_ltap-vlpla.

      PERFORM f_conversion USING 'OUTPUT'	ls_ltap-nsolm ls_ltap-meins
                           CHANGING ls_tosys-quantity ls_tosys-uom.

      CLEAR ls_mara.
      READ TABLE lt_mara INTO ls_mara
                         WITH KEY matnr = ls_ltap-matnr.
      IF ls_mara-mtart IN lr_mtart OR
        ls_mara-mtart = 'ZSFG'.
        CLEAR ls_marm.
        READ TABLE lt_marm INTO ls_marm
                           WITH KEY matnr = ls_mara-matnr.
        IF sy-subrc = 0.
          ls_tosys-conversi_carton = ls_marm-umrez.
          CONDENSE ls_tosys-conversi_carton NO-GAPS.
          PERFORM f_conversion USING 'OUTPUT' '' 'KAR'
                               CHANGING lv_menge ls_tosys-uom_packing.
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
                pe_uom   = ls_tosys-uom_packing
                pe_value = ls_tosys-conversi_carton.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
      ENDIF.

      CLEAR ls_lagp.
      READ TABLE lt_lagp INTO ls_lagp
                         WITH KEY lgnum = ls_ltak-lgnum
                                  lgtyp = ls_ltap-vltyp
                                  lgpla = ls_ltap-vlpla.
      IF sy-subrc = 0.
        ls_tosys-sort_picking         = ls_lagp-sorlp.
        IF ls_lagp-skzua = 'X'.
          ls_tosys-type       = 'E'.
          ls_tosys-message    = 'Block for picking'.
        ELSEIF ls_lagp-skzsi = 'X'.
          ls_tosys-type       = 'E'.
          ls_tosys-message    = 'Bin active PID'.
        ELSE.
          ls_tosys-type       = 'S'.
          ls_tosys-message    = ''.
        ENDIF.
      ENDIF.
      APPEND ls_tosys TO ft_tosys.
      CLEAR: ls_tosys.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PICKING_SYS_GRP
*&---------------------------------------------------------------------*
FORM f_get_picking_sys_grp  TABLES   ft_tosys STRUCTURE zhgwmst003
                            USING    fu_username fs_lrf_wkqu TYPE lrf_wkqu
                            CHANGING fs_picksys  TYPE zhgwmst004
                                     fc_type fc_message.

  TYPES : BEGIN OF ty_syst.
            INCLUDE STRUCTURE zhgwmst003.
            TYPES : nsolm TYPE ltap-nsolm,
            meins TYPE ltap-meins,
          END OF ty_syst.

  DATA : selected_tos   TYPE STANDARD TABLE OF ltak,
         selected       LIKE LINE OF selected_tos,
         selected_items TYPE STANDARD TABLE OF ltap,
         items          LIKE LINE OF selected_items.

  DATA : lt_ltak  TYPE STANDARD TABLE OF ltak,
         lt_ltap  TYPE STANDARD TABLE OF ltap,
         ls_ltak  LIKE LINE OF lt_ltak,
         ls_ltap  LIKE LINE OF lt_ltap,
         lt_xltak TYPE STANDARD TABLE OF ltak,
         ls_xltak LIKE LINE OF lt_xltak,
         lt_xltap TYPE STANDARD TABLE OF ltap,
         lt_mara  TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF lt_mara,
         lt_marm  TYPE STANDARD TABLE OF marm,
         ls_marm  LIKE LINE OF lt_marm,
         lr_mtart TYPE RANGE OF mtart,
         ls_mtart LIKE LINE OF lr_mtart,
         ls_tosys TYPE zhgwmst003,
         lt_syst  TYPE STANDARD TABLE OF ty_syst,
         ls_syst  LIKE LINE OF lt_syst,
         lt_lagp  TYPE STANDARD TABLE OF lagp,
         ls_lagp  LIKE LINE OF lt_lagp.

  DATA : lv_fg       TYPE i,
         lv_nfg      TYPE i,
         lv_tapos    TYPE ltap-tapos,
         lv_menge    TYPE c LENGTH 20,
         lv_subrc    TYPE sy-subrc,
         lv_length   TYPE i,
         lv_selec,
         lv_uzeit(8).

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

  CLEAR lv_selec.
  lv_length = strlen( fs_lrf_wkqu-queue ).
  lv_length = lv_length - 2.
  IF lv_length = 0.
    IF fs_lrf_wkqu-queue = 'AB'.
      lv_selec = 'X'.
    ENDIF.
  ELSE.
    IF fs_lrf_wkqu-queue+lv_length(2) = 'AB' OR
       fs_lrf_wkqu-queue+lv_length(2) = 'AC'.
      lv_selec = 'X'.
    ENDIF.
  ENDIF.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fs_lrf_wkqu-lgnum
      AND kquit = lv_selec
      AND queue = fs_lrf_wkqu-queue
      AND lznum <> space.

  IF lt_ltak[] IS NOT INITIAL.
    IF lv_selec IS INITIAL.
      SELECT *
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        FOR ALL ENTRIES IN lt_ltak
        WHERE lgnum = lt_ltak-lgnum
          AND tanum = lt_ltak-tanum
          AND zrstg = space.
    ELSE.
      SELECT *
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        FOR ALL ENTRIES IN lt_ltak
        WHERE lgnum = lt_ltak-lgnum
          AND tanum = lt_ltak-tanum
          AND pvqui = lv_selec
          AND zrstg = space.
    ENDIF.
  ENDIF.

  lt_xltak[] = lt_ltak[].
  SORT lt_xltak BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_xltak COMPARING lznum.
  SORT lt_xltak BY tapri.
  LOOP AT lt_xltak INTO ls_xltak.
    CLEAR lv_subrc.
    IF gv_lznum <> ls_xltak-lznum.
      PERFORM f_check_lock USING ls_xltak-lgnum ls_xltak-lznum
                           CHANGING lv_subrc.
      IF lv_subrc <> 0.
        EXIT.
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      CLEAR ls_ltak.
      LOOP AT lt_ltak INTO ls_ltak WHERE lznum = ls_xltak-lznum.
        READ TABLE lt_ltap INTO ls_ltap
                           WITH KEY lgnum = ls_ltak-lgnum
                                    tanum = ls_ltak-tanum.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        APPEND ls_ltak TO selected_tos.
        LOOP AT lt_ltap INTO ls_ltap WHERE lgnum = ls_ltak-lgnum
                                       AND tanum = ls_ltak-tanum.
          APPEND ls_ltap TO selected_items.
          CLEAR ls_ltap.
        ENDLOOP.
        CLEAR ls_ltak.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  fs_picksys-username         = fu_username.
  fs_picksys-warehouse_number = fs_lrf_wkqu-lgnum.
  fs_picksys-queue            = fs_lrf_wkqu-queue.
  fs_lrf_wkqu-docnum = ls_xltak-lznum.

**  DATA:  ls_lrf_wkqu TYPE lrf_wkqu.
**  ls_lrf_wkqu-lgnum = fu_lgnum.
**  ls_lrf_wkqu-bname = fu_username.
**  ls_lrf_wkqu-docnum = fu_lznum.
**  IF ls_lrf_wkqu IS NOT INITIAL.
**  ENDIF.


  SORT selected_tos BY lznum.
  READ TABLE selected_tos INTO selected INDEX 1.
  fs_picksys-to_number        = selected-lznum.
  SELECT SINGLE lbzot
    FROM t30ct
    INTO fs_picksys-staging
    WHERE spras = sy-langu
      AND lgnum = fs_lrf_wkqu-lgnum
      AND lgbzo = selected-lgbzo.
  gv_lznum                    = selected-lznum.

  DELETE selected_tos WHERE lznum <> selected-lznum.
  IF selected_tos[] IS NOT INITIAL.
    PERFORM f_lock_data USING fs_lrf_wkqu-lgnum
                              selected-lznum. " fu_username.
    fs_lrf_wkqu-docnum = selected-lznum.
    MODIFY lrf_wkqu FROM fs_lrf_wkqu.
    lt_xltap[] = selected_items[].
    SORT lt_xltap BY matnr.
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

    lt_xltap[] = selected_items[].
    SORT lt_xltap BY vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING vltyp vlpla.
    IF lt_xltap[] IS NOT INITIAL.
      SELECT *
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE lt_lagp
        FOR ALL ENTRIES IN lt_xltap
        WHERE lgnum = lt_xltap-lgnum
          AND lgtyp = lt_xltap-vltyp
          AND lgpla = lt_xltap-vlpla.
    ENDIF.

    LOOP AT lt_mara INTO ls_mara.
      IF ls_mara-mtart IN lr_mtart.
        ADD 1 TO lv_fg.
      ELSE.
        ADD 1 TO lv_nfg.
      ENDIF.
    ENDLOOP.

    IF lv_fg <> 0 AND
      lv_nfg <> 0.
      fs_picksys-type     = 'E'.
      fs_picksys-message  = 'Material mix'.
    ELSEIF lv_fg <> 0 AND
      lv_nfg = 0.
      fs_picksys-fg       = 'X'.
      fs_picksys-type     = 'S'.
      fs_picksys-message  = 'GET Data'.
    ELSEIF lv_fg = 0 AND
      lv_nfg <> 0.
      fs_picksys-type     = 'S'.
      fs_picksys-message  = 'GET Data'.
    ENDIF.
  ELSE.
    fs_picksys-type     = 'E'.
    fs_picksys-message  = 'Data not found'.
  ENDIF.


  IF fs_picksys-type = 'S'.
    SORT selected_items BY matnr charg vltyp vlber vlpla.
    LOOP AT selected_items INTO items.
      CLEAR : selected.
      READ TABLE selected_tos INTO selected
                              WITH KEY lgnum = items-lgnum
                                       tanum = items-tanum.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ls_syst-material_number      = items-matnr.
      ls_syst-material_description = items-maktx.
      ls_syst-batch                = items-charg.
      ls_syst-exp_date             = items-vfdat.
      ls_syst-storage_type         = items-vltyp.
      ls_syst-storage_bin          = items-vlpla.
      ls_syst-nsolm                = items-nsolm.
      ls_syst-meins                = items-meins.

      IF items-edatu <> '00000000'.
        WRITE items-ezeit TO lv_uzeit USING EDIT MASK '__:__:__' .
        CONCATENATE items-edatu lv_uzeit
        INTO ls_syst-picking_start
        SEPARATED BY space.
      ENDIF.

      IF items-qzeit <> '00000000'.
        WRITE items-qzeit TO lv_uzeit USING EDIT MASK '__:__:__' .
        CONCATENATE items-qdatu lv_uzeit
        INTO ls_syst-picking_end
        SEPARATED BY space.
      ENDIF.

      COLLECT ls_syst INTO lt_syst.
      CLEAR ls_syst.
    ENDLOOP.

    LOOP AT lt_syst INTO ls_syst.
      MOVE-CORRESPONDING ls_syst TO ls_tosys.
      ADD 1 TO lv_tapos.
      ls_tosys-to_item              = lv_tapos.
      PERFORM f_conversion USING 'OUTPUT'  ls_syst-nsolm ls_syst-meins
                           CHANGING ls_tosys-quantity ls_tosys-uom.

      CLEAR ls_mara.
      READ TABLE lt_mara INTO ls_mara
                         WITH KEY matnr = ls_syst-material_number.
      IF ls_mara-mtart IN lr_mtart OR
        ls_mara-mtart = 'ZSFG'.
        CLEAR ls_marm.
        READ TABLE lt_marm INTO ls_marm
                           WITH KEY matnr = ls_mara-matnr.
        IF sy-subrc = 0.
          ls_tosys-conversi_carton = ls_marm-umrez.
          CONDENSE ls_tosys-conversi_carton NO-GAPS.
          PERFORM f_conversion USING 'OUTPUT' '' 'KAR'
                               CHANGING lv_menge ls_tosys-uom_packing.
        ENDIF.
      ELSE.
        TRY.
            CALL FUNCTION 'ZWMFM009'
              EXPORTING
                pi_lgnum = fs_lrf_wkqu-lgnum
                pi_matnr = ls_syst-material_number
                pi_charg = ls_syst-batch
                pi_mtart = ls_mara-mtart
              IMPORTING
                pe_uom   = ls_tosys-uom_packing
                pe_value = ls_tosys-conversi_carton.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
      ENDIF.

      CLEAR ls_lagp.
      READ TABLE lt_lagp INTO ls_lagp
                         WITH KEY lgnum = fs_lrf_wkqu-lgnum
                                  lgtyp = ls_syst-storage_type
                                  lgpla = ls_syst-storage_bin.
      IF sy-subrc = 0.
        ls_tosys-sort_picking         = ls_lagp-sorlp.
        IF ls_lagp-skzua = 'X'.
          ls_tosys-type       = 'E'.
          ls_tosys-message    = 'Block for picking'.
        ELSEIF ls_lagp-skzsi = 'X'.
          ls_tosys-type       = 'E'.
          ls_tosys-message    = 'Bin active PID'.
        ELSE.
          ls_tosys-type       = 'S'.
          ls_tosys-message    = ''.
        ENDIF.
      ENDIF.

      TRY.
          APPEND ls_tosys TO ft_tosys.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      CLEAR ls_tosys.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_DATA
*&---------------------------------------------------------------------*
FORM f_lock_data  USING     fu_lgnum fu_lznum. " fu_username.
  CALL FUNCTION 'ENQUEUE_EZWMST010'
    EXPORTING
      lgnum          = fu_lgnum
      lznum          = fu_lznum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LOCK
*&---------------------------------------------------------------------*
FORM f_check_lock  USING    fu_lgnum fu_lznum
                   CHANGING fc_subrc.
  DATA : lv_gname TYPE seqg3-gname,
         lv_garg  TYPE seqg3-garg,
         enq      TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF enq.

  CLEAR fc_subrc.
  lv_gname       = 'ZWMST010'.
  lv_garg(23)  = |{ fu_lgnum }{ fu_lznum }|.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = lv_gname
      garg                  = lv_garg
      guname                = space
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc = 0.
    IF enq[] IS NOT INITIAL.
      fc_subrc = 4.
    ENDIF.
  ELSE.
    fc_subrc = sy-subrc.
  ENDIF.
ENDFORM.
