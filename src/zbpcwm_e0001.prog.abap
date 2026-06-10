*&---------------------------------------------------------------------*
*& Report  ZBPCWM_E0001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbpcwm_e0001 NO STANDARD PAGE HEADING.
TABLES : ltak, ltap, rlmob, rl03t, lqua.

TYPES : BEGIN OF ty_input,
          vltyp(100),
          vlpla(100),
          nltyp(100),
          nlpla(100),
        END OF ty_input.

DATA : gt_lqua       TYPE STANDARD TABLE OF lqua,
       wa_lqua       LIKE lqua,
       gv_spld       LIKE ltap-ldest,
       gv_tanum      LIKE ltap-tanum,
       gv_subrc      TYPE sy-subrc,
       gv_desti,
       gv_xchpf      TYPE mara-xchpf,
       gv_lgber      TYPE lagp-lgber,
       gv_matnr(100),
       gv_plauf      TYPE lagp-plauf,
       gv_lptyp      TYPE lagp-lptyp,
       gv_nlauf      TYPE t337z-plauf,
       gv_slauf      TYPE sy-subrc,
       gv_zeugn      TYPE lqua-zeugn.

DATA : gv_datum TYPE sy-datum,
       gv_uzeit TYPE sy-uzeit,
       gs_v331  TYPE t331,
       gs_t337z TYPE t337z,
       gs_qals  TYPE qals.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

DATA : gv_lgnum  TYPE lrf_wkqu-lgnum,
       gs_t320   TYPE t320,
       gs_input  TYPE ty_input,
       gv_prefix TYPE zwmdt008-prefix,
       gt_008    TYPE STANDARD TABLE OF zwmdt008.

START-OF-SELECTION.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  sy-lsind = 0.

  SET PF-STATUS 'PF_0100'.
*  SET TITLEBAR 'xxx'.


ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR : ltap-vltyp, ltap-vlpla, ltap-vppos, ltap-matnr, rl03t-anfme, ltap-charg,
              ltap-altme, rlmob-mmakt, gv_desti,
              ltap-nltyp, ltap-nlpla, ltap-nppos, gv_xchpf.
      CLEAR : gs_qals, gv_zeugn.

      LEAVE TO SCREEN 0.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'NEXT'.
      IF ltap-matnr IS INITIAL.
        gv_subrc  = '7'.
        CALL SCREEN 2999.
      ELSE.
        gv_desti  = 'X'.
        CLEAR ltap-nppos.
      ENDIF.

    WHEN 'SAVE'.
      IF gv_subrc IS INITIAL.
        PERFORM f_save.
        IF gv_subrc IS INITIAL.
          CLEAR : ltap-vltyp, ltap-vlpla, ltap-vppos, ltap-matnr, rl03t-anfme,
                  ltap-charg, ltap-altme, rlmob-mmakt, gv_desti,
                  ltap-nltyp, ltap-nlpla, gv_xchpf, gv_matnr, ltap-vppos.
          CLEAR : gv_datum, gv_uzeit.
          CLEAR : gs_qals, gv_zeugn.
        ENDIF.
      ELSE.
        CALL SCREEN 2999.
        LEAVE TO SCREEN 0.
      ENDIF.
      CLEAR gv_subrc.

    WHEN OTHERS.
      IF sy-dynnr = '0100'.
        IF ltap-vlpla IS NOT INITIAL.
          IF gv_datum IS INITIAL.
            gv_datum = sy-datum.
          ENDIF.
          IF gv_uzeit IS INITIAL.
            gv_uzeit = sy-uzeit.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.
  DATA : lv_material TYPE mara-matnr,
         lv_batch    TYPE mch1-charg.

  DATA : lt_lqua  TYPE STANDARD TABLE OF lqua,
         ls_lqua  LIKE LINE OF lt_lqua,
         lv_lptyp TYPE lagp-lptyp.

  DATA : lv_prueflos TYPE qals-prueflos,
         lv_qty      TYPE string,
         lv_pallet   TYPE string.

  IF ltap-vltyp IS NOT INITIAL AND
    ltap-vlpla IS NOT INITIAL.
    ls_lqua-lgtyp   = ltap-vltyp.
    ls_lqua-lgpla   = ltap-vlpla.
    APPEND ls_lqua TO lt_lqua.
    CLEAR ls_lqua.
  ENDIF.

  IF ltap-nltyp IS NOT INITIAL AND
    ltap-nlpla IS NOT INITIAL.
    ls_lqua-lgtyp   = ltap-nltyp.
    ls_lqua-lgpla   = ltap-nlpla.
    APPEND ls_lqua TO lt_lqua.
    CLEAR ls_lqua.
  ENDIF.

  IF lt_lqua[] IS NOT INITIAL.
    SELECT *
      FROM lqua
      INTO CORRESPONDING FIELDS OF TABLE gt_lqua
      FOR ALL ENTRIES IN lt_lqua
      WHERE lgnum = ltap-lgnum
        AND lgtyp = lt_lqua-lgtyp
        AND lgpla = lt_lqua-lgpla.
  ENDIF.

  IF ltap-lgnum(1) = 'C' OR
    ltap-lgnum = '011' OR
    ltap-lgnum = '012' OR
    ltap-lgnum(2) = '36'.

    IF ltap-lgnum(2) = '36'.
      SPLIT gv_matnr AT ';' INTO lv_material lv_batch lv_prueflos lv_qty lv_pallet.
    ELSE.
      SPLIT gv_matnr AT ';' INTO lv_material lv_batch.
    ENDIF.
    gv_matnr = lv_material.
    ltap-matnr = lv_material.
    IF lv_batch IS NOT INITIAL.
      ltap-charg = lv_batch.
    ENDIF.

    IF lv_prueflos IS NOT INITIAL.
      SELECT SINGLE *
        FROM qals
        INTO CORRESPONDING FIELDS OF gs_qals
        WHERE prueflos  = lv_prueflos.
      IF sy-subrc = 0.
        gv_zeugn  = lv_pallet.
      ENDIF.
    ENDIF.
  ELSE.
    ltap-matnr = gv_matnr.
    IF gv_matnr IS NOT INITIAL.
      CALL FUNCTION 'ZWM_CHECK_MATNR'
        EXPORTING
          pi_chumat = gv_matnr
        IMPORTING
          pe_matnr  = ltap-matnr.
    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF ltap-lgnum <> '011' AND
      ltap-lgnum <> '012'.
      IF screen-group1 = 'STK'.
        screen-active = 0.
      ENDIF.
    ELSE.
      IF gv_matnr IS INITIAL.
        IF screen-group1 = 'STK'.
          screen-active = 0.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gv_desti IS INITIAL.
      IF screen-group1 = 'DST'.
        screen-active = 0.
      ENDIF.
    ELSE.
      IF screen-group1 = 'DST'.
        screen-active = 1.
      ENDIF.
      IF screen-group1 = 'NXT'.
        screen-active = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  SELECT SINGLE lgnum
    FROM lrf_wkqu
    INTO ltap-lgnum
    WHERE bname = sy-uname
      AND statu = 'X'.

  PERFORM f_cursor_position.

  SELECT SINGLE maktx
    FROM makt
    INTO rlmob-mmakt
    WHERE matnr = ltap-matnr.

  CLEAR : gv_xchpf.
  SELECT SINGLE meins xchpf
    FROM mara
    INTO (ltap-altme, gv_xchpf)
    WHERE matnr = ltap-matnr.

  IF lt_lqua[] IS NOT INITIAL.
    READ TABLE gt_lqua INTO wa_lqua
                       WITH KEY matnr = ltap-matnr
                                lgnum = ltap-lgnum
                                lgtyp = ltap-vltyp
                                lgpla = ltap-vlpla
                                charg = ltap-charg.
  ENDIF.

  ltak-bwlvs = '988'.

  SELECT SINGLE spld
    FROM usr01
    INTO gv_spld
    WHERE bname = sy-uname.

  SELECT SINGLE *
    FROM t331
    INTO CORRESPONDING FIELDS OF gs_v331
    WHERE lgnum = ltap-lgnum
      AND lgtyp = ltap-vltyp.
  IF sy-subrc = 0.
    IF gs_v331-lenvw <> 'X'.
      LOOP AT SCREEN.
        IF screen-name = 'LTAP-VPPOS'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      IF ltap-vlpla IS INITIAL.
        SET CURSOR FIELD 'LTAP-VLPLA'.
      ELSE.
        IF gv_desti IS INITIAL.
          SET CURSOR FIELD 'GV_MATNR'.
        ENDIF.
      ENDIF.
    ELSE.
      IF ltap-vltyp IS NOT INITIAL AND
        ltap-vlpla IS NOT INITIAL.
        SELECT SINGLE plauf
          FROM lagp
          INTO gv_plauf
          WHERE lgnum = ltap-lgnum
            AND lgtyp = ltap-vltyp
            AND lgpla = ltap-vlpla.
        IF gv_plauf IS NOT INITIAL.
          IF ltap-vppos IS INITIAL.
            SET CURSOR FIELD 'LTAP-VPPOS'.
          ELSE.
            IF gv_subrc = 14.
              SET CURSOR FIELD 'LTAP-VPPOS'.
              CLEAR gv_subrc.
            ELSE.
              IF gv_desti IS INITIAL.
                SET CURSOR FIELD 'GV_MATNR'.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          IF gv_desti IS INITIAL.
            SET CURSOR FIELD 'GV_MATNR'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : ls_lqua, gv_slauf.
  READ TABLE gt_lqua INTO ls_lqua
                     WITH KEY lgnum = ltap-lgnum
                              lgpla = ltap-vlpla
                              matnr = gv_matnr
                              charg = ltap-charg.
  IF sy-subrc = 0.
    SELECT SINGLE lptyp
      FROM lagp
      INTO gv_lptyp
      WHERE lgnum = ltap-lgnum
        AND lgtyp = ltap-nltyp
        AND lgpla = ltap-nlpla.
    IF sy-subrc = 0.
      SELECT SINGLE plauf
        FROM t337z
        INTO gv_nlauf
        WHERE lgnum = ltap-lgnum
          AND lgtyp = ltap-nltyp
          AND lptyp = gv_lptyp
          AND letyp = ls_lqua-letyp.

      gv_slauf  = sy-subrc.
      IF sy-subrc = 0.
        IF gv_nlauf IS NOT INITIAL.
          SET CURSOR FIELD 'LTAP-NPPOS'.
        ELSE.
          LOOP AT SCREEN.
            IF screen-name = 'LTAP-NPPOS'.
              screen-active = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
        ENDIF.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'LTAP-NPPOS'.
            screen-active = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_matnr IS NOT INITIAL.
    IF rl03t-anfme IS NOT INITIAL.
      IF ltap-nltyp IS INITIAL AND
        ltap-nlpla IS NOT INITIAL.
        SET CURSOR FIELD 'LTAP-NPPOS'.
      ENDIF.
    ELSE.
      IF ltap-charg IS INITIAL.
        SET CURSOR FIELD 'LTAP-CHARG'.
      ELSE.
        SET CURSOR FIELD 'RL03T-ANFME'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TAP_DISPLAY  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE
*&---------------------------------------------------------------------*
FORM f_save .
  DATA : t1    TYPE t,
         t2    TYPE t,
         tdiff TYPE i.

  DATA : t_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         s_ltap_conf LIKE LINE OF t_ltap_conf,
         lt_ltap     TYPE STANDARD TABLE OF ltap,
         ls_ltap     LIKE LINE OF lt_ltap.

  IF rl03t-anfme IS INITIAL.
    gv_subrc = 15.
    CALL SCREEN 2999.
  ELSEIF gv_desti IS INITIAL.
    gv_subrc  = '6'.
    CALL SCREEN 2999.
  ELSEIF gv_slauf IS INITIAL AND
    gv_plauf IS INITIAL AND
    ltap-nppos IS INITIAL AND
    gv_nlauf IS NOT INITIAL.
    gv_subrc = 13.
    CALL SCREEN 2999.
  ELSE.
    PERFORM f_storage_unit USING ltap-vltyp ltap-vlpla ltap-vppos
                           CHANGING ltap-vlenr.
    PERFORM f_storage_unit USING ltap-nltyp ltap-nlpla ltap-nppos
                           CHANGING ltap-nlenr.

    CALL FUNCTION 'L_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = ltap-lgnum
        i_bwlvs               = ltak-bwlvs
        i_betyp               = 'D'
        i_benum               = ltap-vlpla
        i_matnr               = ltap-matnr
        i_werks               = wa_lqua-werks
        i_lgort               = wa_lqua-lgort
        i_charg               = ltap-charg
        i_bestq               = wa_lqua-bestq
        i_sobkz               = wa_lqua-sobkz
        i_anfme               = rl03t-anfme
        i_altme               = ltap-altme
        i_ldest               = gv_spld
        i_vltyp               = ltap-vltyp
        i_vlpla               = ltap-vlpla
        i_vlenr               = ltap-vlenr
        i_nltyp               = ltap-nltyp
        i_nlpla               = ltap-nlpla
        i_nlenr               = ltap-nlenr
      IMPORTING
        e_tanum               = gv_tanum
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.

    IF sy-subrc = 0.
      gv_subrc = 0.

      t1 = sy-uzeit.
      DO.
        GET TIME FIELD t2.
        tdiff = t2 - t1.
        IF tdiff >= 10.
          EXIT.
        ENDIF.
      ENDDO.

      IF ltap-lgnum(1) = 'C' OR
        ltap-lgnum = '011' OR
        ltap-lgnum = '012'.
        TRY .
            UPDATE ltak SET stdat = gv_datum
                            stuzt = gv_uzeit
                        WHERE lgnum = ltap-lgnum
                          AND tanum = gv_tanum.
          CATCH cx_sy_open_sql_db.
        ENDTRY.
      ENDIF.

      SELECT *
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        WHERE lgnum   = ltap-lgnum
          AND tanum   = gv_tanum.

      LOOP AT lt_ltap INTO ls_ltap.
        s_ltap_conf-tanum   = ls_ltap-tanum.
        s_ltap_conf-tapos   = ls_ltap-tapos.
        s_ltap_conf-squit   = 'X'.
        APPEND s_ltap_conf TO t_ltap_conf.
        CLEAR s_ltap_conf.

        PERFORM f_update_lqua USING ls_ltap-lgnum ls_ltap-nlqnr.
      ENDLOOP.

      CALL FUNCTION 'L_TO_CONFIRM'
        EXPORTING
          i_lgnum                        = ltap-lgnum
          i_tanum                        = gv_tanum
        TABLES
          t_ltap_conf                    = t_ltap_conf
        EXCEPTIONS
          to_confirmed                   = 1
          to_doesnt_exist                = 2
          item_confirmed                 = 3
          item_subsystem                 = 4
          item_doesnt_exist              = 5
          item_without_zero_stock_check  = 6
          item_with_zero_stock_check     = 7
          one_item_with_zero_stock_check = 8
          item_su_bulk_storage           = 9
          item_no_su_bulk_storage        = 10
          one_item_su_bulk_storage       = 11
          foreign_lock                   = 12
          squit_or_quantities            = 13
          vquit_or_quantities            = 14
          bquit_or_quantities            = 15
          quantity_wrong                 = 16
          double_lines                   = 17
          kzdif_wrong                    = 18
          no_difference                  = 19
          no_negative_quantities         = 20
          wrong_zero_stock_check         = 21
          su_not_found                   = 22
          no_stock_on_su                 = 23
          su_wrong                       = 24
          too_many_su                    = 25
          nothing_to_do                  = 26
          no_unit_of_measure             = 27
          xfeld_wrong                    = 28
          update_without_commit          = 29
          no_authority                   = 30
          lqnum_missing                  = 31
          charg_missing                  = 32
          no_sobkz                       = 33
          no_charg                       = 34
          nlpla_wrong                    = 35
          two_step_confirmation_required = 36
          two_step_conf_not_allowed      = 37
          pick_confirmation_missing      = 38
          quknz_wrong                    = 39
          hu_data_wrong                  = 40
          no_hu_data_required            = 41
          hu_data_missing                = 42
          hu_not_found                   = 43
          picking_of_hu_not_possible     = 44
          not_enough_stock_in_hu         = 45
          serial_number_data_wrong       = 46
          serial_numbers_not_required    = 47
          no_differences_allowed         = 48
          serial_number_not_available    = 49
          serial_number_data_missing     = 50
          to_item_split_not_allowed      = 51
          input_wrong                    = 52
          OTHERS                         = 53.

      IF sy-subrc <> 0 AND sy-subrc <> 1.
        gv_subrc = 8.
*    ELSE.
*      PERFORM f_print_to USING ltap-lgnum gv_tanum.
      ELSE.
        IF ltap-lgnum(1) = 'C' OR
          ltap-lgnum = '011' OR
          ltap-lgnum = '012'.
          TRY .
              UPDATE ltap SET qdatu = sy-datum
                              qzeit = sy-uzeit
                          WHERE lgnum = ltap-lgnum
                            AND tanum = gv_tanum.
            CATCH cx_sy_open_sql_db.
          ENDTRY.
        ENDIF.
      ENDIF.

      CALL SCREEN 2999.
*    MESSAGE s000(zab) WITH 'TO' gv_tanum 'already created'.
    ELSE.
      gv_subrc = 4.
      CALL SCREEN 2999.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SAVE

*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREENMSG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screenmsg OUTPUT.
  SET PF-STATUS 'MOBILEMSG'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_SCREENMSG  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position .
  IF gv_desti IS INITIAL.
    IF ltap-vltyp IS INITIAL.
      SET CURSOR FIELD 'LTAP-VLTYP'.
    ENDIF.

    IF ltap-vltyp IS NOT INITIAL AND
      ltap-vlpla IS INITIAL.
      SET CURSOR FIELD 'LTAP-VLPLA'.
    ENDIF.

    IF ltap-vltyp IS NOT INITIAL AND
      ltap-vlpla IS NOT INITIAL AND
      ltap-vppos IS INITIAL.
      SET CURSOR FIELD 'LTAP-VPPOS'.
    ENDIF.

*    IF ltap-vltyp IS NOT INITIAL AND
*      ltap-vlpla IS NOT INITIAL AND
*      ltap-vppos IS NOT INITIAL AND
*      ltap-matnr IS INITIAL.
*      SET CURSOR FIELD 'GV_MATNR'.
*    ENDIF.

    IF ltap-vltyp IS NOT INITIAL AND
      ltap-vlpla IS NOT INITIAL AND
      ltap-matnr IS NOT INITIAL AND
      rl03t-anfme IS INITIAL.
      SET CURSOR FIELD 'RL03T-ANFME'.
    ENDIF.

    IF ltap-vltyp IS NOT INITIAL AND
      ltap-vlpla IS NOT INITIAL AND
      ltap-matnr IS NOT INITIAL AND
      rl03t-anfme IS NOT INITIAL AND
      ltap-charg IS INITIAL.
      SET CURSOR FIELD 'LTAP-CHARG'.
    ENDIF.

    IF ltap-vltyp IS NOT INITIAL AND
      ltap-vlpla IS NOT INITIAL AND
      ltap-matnr IS NOT INITIAL AND
      rl03t-anfme IS NOT INITIAL AND
      ltap-charg IS NOT INITIAL.
      SET CURSOR FIELD 'LTAP-CHARG'.
    ENDIF.
  ELSE.
    IF ltap-nltyp IS INITIAL.
      SET CURSOR FIELD 'LTAP-NLTYP'.
    ENDIF.

    IF ltap-nltyp IS NOT INITIAL AND
      ltap-nlpla IS INITIAL.
      SET CURSOR FIELD 'LTAP-NLPLA'.
    ENDIF.

    IF ltap-nltyp IS NOT INITIAL AND
      ltap-nlpla IS NOT INITIAL AND
      ltap-nppos IS INITIAL.
      SET CURSOR FIELD 'LTAP-NPPOS'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validate_data OUTPUT.
  DATA : lv_lgnum       TYPE lgnum,
         lv_charg       TYPE charg_d,
         lv_verme       LIKE lqua-verme,
         lv_skzue       TYPE lagp-skzue,
         lv_skzua       TYPE lagp-skzua,
         lv_lgbkz       TYPE mlgn-lgbkz,
         ls_t301        LIKE t301,
         ls_t334b       LIKE t334b,
         lv_fieldnm(30),
         lv_count(2),
         lr_lgber       TYPE RANGE OF lgber,
         ls_lgber       LIKE LINE OF lr_lgber,
         lv_plpos       TYPE lqua-plpos,
         ls_xlqua       LIKE LINE OF gt_lqua,
         lv_subrc       TYPE sy-subrc.

  FIELD-SYMBOLS <fs>   TYPE any.

  CLEAR gv_subrc.

  IF ltap-vltyp IS NOT INITIAL.
    SELECT SINGLE *
      FROM t301
      INTO ls_t301
      WHERE lgnum = ltap-lgnum
        AND lgtyp = ltap-vltyp.

    IF sy-subrc <> 0.
      gv_subrc = 5.
      CALL SCREEN 2999.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

  IF ltap-vppos IS NOT INITIAL.
    CLEAR : ls_lqua, lv_plpos.
    lv_plpos  = ltap-vppos.
    CONDENSE lv_plpos.

    READ TABLE gt_lqua INTO ls_lqua
                       WITH KEY lgnum = ltap-lgnum
                                lgtyp = ltap-vltyp
                                lgpla = ltap-vlpla
                                plpos = lv_plpos.
    IF sy-subrc <> 0.
      gv_subrc = 14.
      CALL SCREEN 2999.
      CLEAR gv_subrc.
      SET CURSOR FIELD 'LTAP-VPPOS'.
    ENDIF.
  ENDIF.

  IF gv_matnr IS NOT INITIAL.
    IF gs_v331-lenvw = 'X'.
      IF gv_plauf IS NOT INITIAL.
        IF ltap-vppos IS INITIAL.
          gv_subrc = 12.
          CALL SCREEN 2999.
          CLEAR gv_subrc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ltap-nltyp IS NOT INITIAL AND
    ltap-nlpla IS NOT INITIAL.
    IF gv_lptyp IS INITIAL.
      gv_subrc = 16.
      CALL SCREEN 2999.
      CLEAR gv_subrc.
    ENDIF.
  ENDIF.

  SELECT SINGLE lgnum
    FROM lrf_wkqu
    INTO lv_lgnum
    WHERE bname = sy-uname
      AND statu = 'X'.

  IF ltap-vlpla IS NOT INITIAL.
    SELECT SINGLE lgnum skzua
      FROM lagp
      INTO (lv_lgnum, lv_skzua)
      WHERE lgnum = lv_lgnum
        AND lgtyp = ltap-vltyp
        AND lgpla = ltap-vlpla.

    IF sy-subrc <> 0.
      gv_subrc  = 1.
      CALL SCREEN 2999.
    ELSE.
      IF lv_skzua IS NOT INITIAL.
        gv_subrc  = 10.
        CALL SCREEN 2999.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : lv_charg, lv_verme, lv_plpos.

  lv_plpos  = ltap-vppos.
  CONDENSE lv_plpos.

  CLEAR ls_xlqua.
  READ TABLE gt_lqua INTO ls_xlqua
                     WITH KEY matnr = ltap-matnr
                              lgnum = ltap-lgnum
                              lgtyp = ltap-vltyp
                              lgpla = ltap-vlpla
                              plpos = lv_plpos
                              charg = ltap-charg.

  IF sy-subrc = 0.
    lv_charg  = ls_xlqua-charg.
    lv_verme  = ls_xlqua-verme.
  ENDIF.

  IF ltap-charg IS NOT INITIAL.
    IF lv_charg IS INITIAL.
      gv_subrc = 2.
      CLEAR ltap-charg.
      CALL SCREEN 2999.
    ENDIF.
  ENDIF.

  IF gv_xchpf IS INITIAL.
    IF rl03t-anfme IS NOT INITIAL.
      IF rl03t-anfme > lv_verme.
        CLEAR ltap-charg.
        gv_subrc = 3.
        CALL SCREEN 2999.
      ENDIF.
    ENDIF.
  ELSE.
    IF ltap-charg IS NOT INITIAL.
      IF rl03t-anfme IS NOT INITIAL.
        IF rl03t-anfme > lv_verme.
          CLEAR ltap-charg.
          gv_subrc = 3.
          CALL SCREEN 2999.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    lqua-verme  = lv_verme.
  ENDIF.

  IF ltap-matnr IS NOT INITIAL AND
    ltap-nltyp IS NOT INITIAL.
    SELECT SINGLE lgbkz
      FROM mlgn
      INTO lv_lgbkz
      WHERE lgnum = lv_lgnum
        AND matnr = ltap-matnr.
    IF sy-subrc = 0.
      SELECT SINGLE *
        FROM t334b
        INTO CORRESPONDING FIELDS OF ls_t334b
        WHERE lgnum = lv_lgnum
          AND lgtyp = ltap-nltyp
          AND lgbkz = lv_lgbkz.
      IF sy-subrc = 0.
        lv_count = '0'.
        DO 30 TIMES.
          IF lv_count < 10.
            CONCATENATE 'LS_T334B-LGBE' lv_count INTO lv_fieldnm.
          ELSE.
            CONCATENATE 'LS_T334B-LGB' lv_count INTO lv_fieldnm.
          ENDIF.
          ADD 1 TO lv_count.
          ASSIGN (lv_fieldnm) TO <fs>.
          IF <fs> IS NOT ASSIGNED OR
            <fs> IS INITIAL.
            EXIT.
          ENDIF.
          ls_lgber-low    = <fs>.
          ls_lgber-sign   = 'I'.
          ls_lgber-option = 'EQ'.
          APPEND ls_lgber TO lr_lgber.
          CLEAR ls_lgber.
        ENDDO.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ltap-nlpla IS NOT INITIAL.
    CLEAR gv_lgber.
    SELECT SINGLE skzue lgber
      FROM lagp
      INTO (lv_skzue, gv_lgber)
      WHERE lgnum = lv_lgnum
        AND lgtyp = ltap-nltyp
        AND lgpla = ltap-nlpla.
    IF lv_skzue IS NOT INITIAL.
      gv_subrc  = 9.
      CALL SCREEN 2999.
    ELSE.
      IF gv_lgber IN lr_lgber.
      ELSE.
        gv_subrc = 11.
        CALL SCREEN 2999.
      ENDIF.
    ENDIF.
  ENDIF.

  IF rl03t-anfme IS NOT INITIAL AND ltap-nltyp IS NOT INITIAL AND ltap-nlpla IS NOT INITIAL AND ltap-altme IS NOT INITIAL.
    CALL FUNCTION 'ZWMFM_CHECK'
      EXPORTING
        pi_matnr = ltap-matnr
        pi_lgnum = lv_lgnum
        pi_menge = rl03t-anfme
        pi_lgtyp = ltap-nltyp
        pi_lgpla = ltap-nlpla
        pi_meins = ltap-altme
      IMPORTING
        pe_subrc = lv_subrc.
    IF lv_subrc <> 0.
      gv_subrc = 17.
      CALL SCREEN 2999.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
MODULE message OUTPUT.
  CLEAR : message1, message2, message3, message4, message5, message6,
          message7.
  CASE gv_subrc.
    WHEN '0'.
      message1 = 'TO Number'.
      message2 = gv_tanum.
      message3 = 'has been created'.
    WHEN '1'.
      message1 = 'Storage Bin'.
      message2 = 'does not exist'.
    WHEN '2'.
      CONCATENATE 'Batch' ltap-charg INTO message1
      SEPARATED BY space.
      CONCATENATE 'for' ltap-matnr INTO message2
      SEPARATED BY space.
      message3 = 'does not exist'.
    WHEN '3'.
      message1 = 'Quantity >'.
      message2 = 'Available Stock'.
    WHEN '4'.
      message1 = 'Error when'.
      message2 = 'creating TO'.
    WHEN '5'.
      message1 = 'Storage type'.
      message2 = 'does not exist'.
    WHEN '6'.
      message1 = 'Destination'.
    WHEN '7'.
      message1 = 'Scan Material'.
    WHEN '8'.
      message1 = 'Confirm error'.
    WHEN '9'.
      message1 = 'Destination Bin'.
      message2 = 'is block for'.
      message3 = 'putaway'.
    WHEN '10'.
      message1 = 'Source Bin'.
      message2 = 'is block for'.
      message3 = 'removal'.
    WHEN '11'.
      message1 = 'Putaway section'.
      message2 = gv_lgber.
      message3 = 'is not allowed'.
    WHEN '12'.
      message1 = 'Please input'.
      message2 = 'BIN Position'.
      message3 = 'in Source'.
    WHEN '13'.
      message1 = 'Please input'.
      message2 = 'BIN Position'.
      message3 = 'in Destination'.
    WHEN '14'.
      message1 = 'Stock does not'.
      message2 = 'exist'.
    WHEN '15'.
      message1 = 'Enter the'.
      message2 = 'requested quantity'.
    WHEN '16'.
      message1 = 'BIN Type not yet'.
      message2 = 'maintain'.
    WHEN '17'.
      message1 = 'Destination BIN'.
      message2 = 'will be exceeded'.
  ENDCASE.
ENDMODULE.                 " MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_TO
*&---------------------------------------------------------------------*
FORM f_print_to  USING    fu_lgnum fu_tanum.
  DATA : le_usr01   LIKE usr01.

  CALL FUNCTION 'GET_PRINT_PARAM'
    EXPORTING
      i_bname = sy-uname
    IMPORTING
      e_usr01 = le_usr01.

  SUBMIT rlvsdr40 WITH t4_lgnum EQ fu_lgnum
                  WITH t4_tanum EQ fu_tanum SIGN 'I'
                  WITH druckkz  EQ '45'
                  WITH edrucker EQ le_usr01-spld
                  WITH spoolpar EQ '01'
                  WITH drucken  EQ 'X'
                  WITH explizit EQ ' '
                  WITH tasch    EQ 'X'
                  WITH lesch    EQ ' '
                  WITH letasch  EQ ' '
                  WITH leinh    EQ ' '
                  WITH humla    EQ ' '
                  WITH etikett  EQ ' '
                  AND RETURN.

  CALL FUNCTION 'ZFMWAIT'.

  UPDATE ltak SET druck = 'X'
            WHERE lgnum EQ fu_lgnum
              AND tanum EQ fu_tanum.

ENDFORM.                    " F_PRINT_TO

*&---------------------------------------------------------------------*
*&      Form  F_STORAGE_UNIT
*&---------------------------------------------------------------------*
FORM f_storage_unit  USING    fu_lgtyp fu_lgpla fu_plpos
                     CHANGING fc_lenum.
  DATA : ls_lqua  LIKE LINE OF gt_lqua,
         lv_plpos TYPE lqua-plpos.

  lv_plpos  =  fu_plpos.
  CONDENSE lv_plpos NO-GAPS.

  READ TABLE gt_lqua INTO ls_lqua
                     WITH KEY lgtyp = fu_lgtyp
                              lgpla = fu_lgpla
                              plpos = lv_plpos.
  IF sy-subrc = 0.
    fc_lenum  = ls_lqua-lenum.
  ENDIF.
ENDFORM.                    " F_STORAGE_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_LQUA
*&---------------------------------------------------------------------*
FORM f_update_lqua  USING    fu_lgnum fu_nlqnr.
  IF fu_lgnum(2) = '36'.
    TRY .
        UPDATE lqua SET qplos = gs_qals-prueflos
                        zeugn = gv_zeugn
                    WHERE lgnum = fu_lgnum
                      AND lqnum = fu_nlqnr
                      AND bestq = 'Q'.
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_UPDATE_LQUA
