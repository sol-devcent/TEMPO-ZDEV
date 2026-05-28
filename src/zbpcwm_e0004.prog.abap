*&---------------------------------------------------------------------*
*& Report  ZBPCWM_E0004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbpcwm_e0004 NO STANDARD PAGE HEADING.

TABLES : lagp, lqua, rlmob, linv, rl04i, zaccdtm.

TYPES : BEGIN OF ty_valsn,
          senum(20),
          aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
        END OF ty_valsn.

TYPES : BEGIN OF ty_sn,
          check(1),
          tanum(10),
          vbeln(10),
          posnr   TYPE lips-posnr,
          senum   TYPE zaccdtm-senum,
          matnr   TYPE lips-matnr,
          charg   TYPE lips-charg,
          werks   TYPE lips-werks,
          lgort   TYPE lips-lgort,
          count(10),
          maktx   TYPE makt-maktx,
          meins   TYPE lips-meins,
          aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
          savwe   TYPE lips-werks,
        END OF ty_sn.

TYPES : BEGIN OF ty_0005x.
        INCLUDE STRUCTURE zbpc0005.
TYPES :   aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
        END OF ty_0005x.

DATA : gt_lagp  LIKE lagp OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_inven OCCURS 0.
        INCLUDE STRUCTURE zbpc0005.
DATA :   cmatnr   LIKE rlmob-cmatnr,
         plpos    LIKE lqua-plpos,
       END OF gt_inven.

TYPES : BEGIN OF ty_mara,
          zeile   TYPE mseg-zeile,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
        END OF ty_mara.

DATA : gt_zbpc0005    LIKE zbpc0005 OCCURS 0 WITH HEADER LINE,
       gt_zaccdtm     TYPE STANDARD TABLE OF zaccdtm,
       gt_ctrl        TYPE STANDARD TABLE OF zmproject_ctrl,
       gt_0005x       TYPE STANDARD TABLE OF ty_0005x.

DATA : gv_subrc     TYPE sy-subrc,
       gv_ivpos     TYPE lvs_ivpos,
       gv_record    TYPE sy-tabix,
       gv_senum(100),
       gv_snro(1),
       gv_zero(1),
       gv_lin       TYPE i,
       gv_newit(1),
       gs_zaccdtm   TYPE zaccdtm,
       gt_sn        TYPE STANDARD TABLE OF ty_sn,
       gs_sn        LIKE LINE OF gt_sn,
       gt_valsn     TYPE STANDARD TABLE OF ty_valsn,
       gs_t320      TYPE t320,
       gt_mara      TYPE STANDARD TABLE OF ty_mara,
       gs_mara      LIKE LINE OF gt_mara.

DATA : c            TYPE i,
       m1           TYPE i VALUE 1,
       m2           TYPE i,
       gv_zeile     TYPE mseg-zeile.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

START-OF-SELECTION.

  SET SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  sy-lsind = 0.

  SET PF-STATUS 'PF_0100'.
*  SET TITLEBAR 'xxx'.

  CASE sy-dynnr.
    WHEN '0100'.
      CLEAR : gv_ivpos, sy-ucomm, gt_inven[], gt_inven, gv_subrc,
              gt_sn[], gt_sn.
      CLEAR : rlmob-cmatnr, linv-menga, linv-menge, rl04i-kznul,
              rlmob-mmakt, lqua-charg.

      PERFORM f_get_whse_no.

      IF lagp-lgnum IS INITIAL.
        gv_subrc  = 2.
        CALL SCREEN 2999.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '0101'.
      IF lagp-lgnum IS NOT INITIAL AND
        lqua-lgpla IS NOT INITIAL AND
        lqua-lgtyp IS NOT INITIAL.
        IF gv_newit IS INITIAL.
          PERFORM f_get_inventory.
        ELSE.
          PERFORM f_newitem.
        ENDIF.
        DESCRIBE TABLE gt_inven LINES gv_record.
        IF gt_inven[] IS NOT INITIAL.
          SELECT *
            FROM zaccdtm
            INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
            FOR ALL ENTRIES IN gt_inven
            WHERE matnr = gt_inven-matnr
              AND charg = gt_inven-charg.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.

  DATA : lv_value(20),
         lv_field(20),
         lv_02(100),
         lx_charg   TYPE mch1-charg.

  PERFORM f_cursor_position.

  IF gv_newit IS INITIAL.
    CLEAR : lx_charg, lqua-charg.
  ENDIF.

  IF sy-dynnr = '0101'.
    CASE sy-ucomm.
      WHEN 'PGUP'.
        CLEAR : rlmob-cmatnr, linv-menga, linv-menge, rl04i-kznul.
        gv_ivpos = gv_ivpos - 1.
      WHEN 'PGDN'.
        CLEAR : rlmob-cmatnr, linv-menga, linv-menge, rl04i-kznul.
        ADD 1 TO gv_ivpos.
        IF linv-menga IS NOT INITIAL OR
          linv-menge IS NOT INITIAL.
          CLEAR rl04i-kznul.
        ENDIF.
      WHEN 'BACK' OR 'SAVE'.
      WHEN 'CANC'.
        gv_ivpos  = gv_ivpos.
      WHEN 'NEWI'.
        IF gv_newit IS NOT INITIAL.
          LOOP AT SCREEN.
            IF screen-name = 'LQUA-PLPOS'.
              screen-input = 1.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
        ENDIF.
      WHEN 'ZERO'.
        IF gv_newit IS INITIAL.
          IF lqua-matnr IS NOT INITIAL.
            IF rlmob-cmatnr IS NOT INITIAL.
              IF gv_ivpos <= gv_record.
                CLEAR : rlmob-cmatnr, linv-menga, linv-menge, rl04i-kznul.
              ENDIF.
            ELSE.
              gv_subrc = 4.
              CALL SCREEN 2999.
              LEAVE TO SCREEN 0.
            ENDIF.
          ELSE.
            IF gt_lagp[] IS NOT INITIAL.
              CLEAR : rlmob-cmatnr, linv-menga, linv-menge.
            ELSE.
              CLEAR : rlmob-cmatnr, linv-menga, linv-menge, rl04i-kznul.
            ENDIF.
          ENDIF.
        ELSE.
        ENDIF.

      WHEN OTHERS.
        IF lqua-lgtyp IS NOT INITIAL AND
          lqua-lgpla IS NOT INITIAL.
          IF gv_ivpos IS INITIAL.
            ADD 1 TO gv_ivpos.
          ENDIF.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
    ENDCASE.

    IF lagp-lgnum <> '011' AND
      lagp-lgnum <> '012'.
      LOOP AT SCREEN.
        IF screen-group1 = 'TSP'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    IF gv_record = 1.
      LOOP AT SCREEN.
        IF screen-name = 'RLMOB-PPGDN'.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSEIF gv_record = 0.
      LOOP AT SCREEN.
        IF screen-name = 'RLMOB-PPGDN'.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSE.
      IF gv_ivpos > 1.
        LOOP AT SCREEN.
          IF screen-name = 'RLMOB-PPGUP'.
            screen-invisible = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

      IF gv_ivpos = gv_record.
        LOOP AT SCREEN.
          IF screen-name = 'RLMOB-PPGDN'.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF gv_ivpos IS INITIAL.
      LEAVE TO SCREEN 0.
    ELSE.
      IF gv_newit IS INITIAL.
        READ TABLE gt_inven WITH KEY ivpos = gv_ivpos.
        IF sy-subrc = 0.
          lqua-matnr = gt_inven-matnr.
          SELECT SINGLE maktx
            FROM makt
            INTO rlmob-mmakt
            WHERE matnr = gt_inven-matnr
              AND spras = sy-langu.

          lqua-charg = gt_inven-charg.
          lqua-plpos = gt_inven-plpos.
          linv-altme  = 'KAR'.
          IF gt_inven-meins IS NOT INITIAL.
            linv-meins = gt_inven-meins.
          ENDIF.

          IF gt_inven-menga IS NOT INITIAL OR
            gt_inven-menge IS NOT INITIAL OR
            gt_inven-kznul IS NOT INITIAL.
            IF gt_inven-cmatnr IS NOT INITIAL.
              rlmob-cmatnr = gt_inven-cmatnr.
            ELSE.
              rlmob-cmatnr = gt_inven-matnr.
            ENDIF.
          ENDIF.

          IF gt_inven-menga IS NOT INITIAL.
            linv-menga   = gt_inven-menga.
          ENDIF.

          IF gt_inven-menge IS NOT INITIAL.
            linv-menge   = gt_inven-menge.
          ENDIF.

          IF gt_inven-kznul IS NOT INITIAL.
            rl04i-kznul  = gt_inven-kznul.
          ELSE.
            CLEAR rl04i-kznul.
          ENDIF.
        ELSE.
          IF gt_lagp[] IS NOT INITIAL.
          ELSE.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE 'WM_BATCH' sy-uname INTO lv_02.
        IMPORT lx_charg FROM MEMORY ID lv_02.
        IF sy-subrc = 0.
          lqua-charg = lx_charg.
        ENDIF.
*        LOOP AT SCREEN.
*          IF screen-name = 'LINV-MENGA' OR
*            screen-name = 'LINV-MENGE'.
*            screen-input = 1.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TAP_DISPLAY  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : ls_0005x   LIKE LINE OF gt_0005x,
         ls_sn      LIKE LINE OF gt_sn,
         ls_inven   LIKE LINE OF gt_inven,
         ls_mara    LIKE LINE OF gt_mara.

  CASE sy-ucomm.
    WHEN 'BACK'.
      CASE sy-dynnr.
        WHEN '0100'.
          CLEAR : sy-ucomm, sy-dynnr, gv_ivpos, gv_newit.
          IF sy-tcode = 'ZLM_LT02'.
            LEAVE TO SCREEN 0.
          ELSE.
            LEAVE TO CURRENT TRANSACTION.
          ENDIF.
        WHEN '0101'.
          CLEAR : sy-ucomm, sy-dynnr, lqua-lgtyp, lqua-lgpla,
                  gv_ivpos, gv_newit.
          FREE MEMORY ID lv_02.
          CLEAR lx_charg.

          SET SCREEN 100.
      ENDCASE.

    WHEN 'PGUP'.
      CLEAR : gt_sn[], gt_sn.
**      IF gv_newit IS INITIAL.
*      CHECK gv_subrc IS INITIAL.
*      PERFORM f_modify_table USING gv_ivpos ''.
*      SET SCREEN 101.
**      ELSE.
      CLEAR gv_newit.
**      ENDIF.
      CLEAR : gv_subrc, lv_field.

    WHEN 'PGDN'.
      CLEAR : gt_sn[], gt_sn.
**      IF gv_newit IS INITIAL.
*      CHECK gv_subrc IS INITIAL.
*      PERFORM f_modify_table USING gv_ivpos ''.
*      SET SCREEN 101.
**      ELSE.
      CLEAR gv_newit.
**      ENDIF.
      CLEAR : gv_subrc, lv_field.

    WHEN 'CANC'.
      CLEAR sy-ucomm.
      CASE gv_subrc.
        WHEN 1 OR 4 OR 6.
          LEAVE TO SCREEN 0.
        WHEN 3 OR 7 OR 9 OR 11.
          CLEAR : rlmob-cmatnr, gv_subrc.
          LEAVE TO SCREEN 0.
          SET SCREEN 101.
        WHEN 99.
          CLEAR gv_subrc.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.
          SET SCREEN 100.
      ENDCASE.

    WHEN 'SAVE'.
      CHECK gv_subrc IS INITIAL.

      PERFORM f_validate_data USING 'CHARG'.

      CHECK gv_subrc IS INITIAL.

      PERFORM f_validate_data USING 'MATNR'.

*      CHECK gv_subrc IS INITIAL.
*
*      PERFORM f_validate_data USING 'SENUM'.

      IF gv_subrc IS INITIAL.
        IF gv_newit IS NOT INITIAL.
          gv_ivpos = gv_ivpos + 1.
        ENDIF.
        CLEAR : gv_newit, lqua-lgpla, lqua-lgtyp, lv_field.
        PERFORM f_modify_table USING gv_ivpos ''.
        PERFORM f_save.
        gv_subrc  = 99.
        CALL SCREEN 2999.
        LEAVE TO SCREEN 0.
      ELSE.
        CALL SCREEN 2999.
        CASE gv_subrc.
          WHEN 3 OR 7.
            SET SCREEN 101.
          WHEN OTHERS.
            SET SCREEN 100.
        ENDCASE.
      ENDIF.

    WHEN 'ZERO'.
      IF rlmob-cmatnr IS NOT INITIAL.
        rl04i-kznul = 'X'.
      ENDIF.
      READ TABLE gt_lagp INDEX 1.
      IF gt_lagp-kzler IS NOT INITIAL.
        CLEAR : rlmob-cmatnr.
      ENDIF.
      CLEAR : linv-menga, linv-menge, gv_subrc.

      PERFORM f_modify_table USING gv_ivpos rl04i-kznul.

    WHEN 'NEWI'.
      gv_newit  = 'X'.
      CLEAR : lqua-matnr, rlmob-mmakt, lv_field, lqua-plpos, lqua-charg.
      SET SCREEN 101.

    WHEN 'NEXT'.
      READ TABLE gt_mara INTO ls_mara
                         WITH KEY zeile = gv_zeile.
      IF sy-subrc = 0.
        lqua-matnr  = ls_mara-matnr.
        rlmob-mmakt = ls_mara-maktx.
        CLEAR : gt_mara[], gv_zeile.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN space.
      break bcdik.
      IF lqua-lgpla IS INITIAL AND
        lqua-lgtyp IS INITIAL.
        gv_subrc  = 1.
        CALL SCREEN 2999.
      ELSE.
        CASE sy-dynnr.
          WHEN '0100'.
            CALL SCREEN 101.
          WHEN '0101'.
            IF gv_senum IS NOT INITIAL.
              IF gt_sn[] IS INITIAL.
                LOOP AT gt_0005x INTO ls_0005x WHERE matnr = lqua-matnr
                                                 AND charg = lqua-charg.
                  MOVE-CORRESPONDING ls_0005x TO ls_sn.
                  APPEND ls_sn TO gt_sn.
                ENDLOOP.
              ENDIF.

              PERFORM f_isi_serial_number.
              CLEAR gv_senum.
            ENDIF.

            IF gv_subrc IS INITIAL.
              GET CURSOR FIELD lv_field.
              IF gv_newit IS INITIAL.
                PERFORM f_validate_data USING 'MATNR'.
                PERFORM f_modify_table USING gv_ivpos rl04i-kznul.
                IF gv_subrc IS NOT INITIAL.
                  CALL SCREEN 2999.
                ENDIF.
                CASE lv_field.
                  WHEN 'RLMOB-CMATNR'.
                    IF gv_subrc IS INITIAL.
                      gv_lin  = 1.
                    ELSE.
                      gv_lin = 0.
                    ENDIF.
                  WHEN 'LINV-MENGA'.
                    gv_lin = 2.
                  WHEN 'LINV-MENGE'.
                    gv_lin = 2.
                ENDCASE.
              ELSE.
                PERFORM f_new_item.
                IF rlmob-mmakt IS INITIAL.
                  SELECT SINGLE maktx
                    FROM makt
                    INTO rlmob-mmakt
                    WHERE matnr = lqua-matnr
                      AND spras = sy-langu.
                ENDIF.

                IF linv-meins IS INITIAL.
                  SELECT SINGLE meins
                    FROM mara
                    INTO linv-meins
                    WHERE matnr = lqua-matnr.
                ENDIF.
                PERFORM f_save_new_item.
              ENDIF.
            ELSE.
              CALL SCREEN 2999.
            ENDIF.
        ENDCASE.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE
*&---------------------------------------------------------------------*
FORM f_save .
  DATA : lv_ivnum   LIKE zbpc0005-ivnum,
         lwa_inven  LIKE zbpc0005,
         ls_0005x   LIKE LINE OF gt_0005x.

  DATA : lv_posnr   TYPE zaccdtd-posnr,
         lv_ivpos   TYPE zbpc0005-ivpos.

  READ TABLE gt_inven WITH KEY matnr = space.
  IF sy-subrc = 0.
    DELETE gt_inven WHERE matnr = space.
    LOOP AT gt_inven.
      ADD 1 TO lv_ivpos.
      gt_inven-ivpos = lv_ivpos.
      IF gt_inven-werks IS INITIAL.
        gt_inven-werks = gs_t320-werks.
      ENDIF.
      IF gt_inven-lgort IS INITIAL.
        gt_inven-lgort = gs_t320-lgort.
      ENDIF.
      MODIFY gt_inven TRANSPORTING ivpos werks lgort.
      CLEAR gt_inven.
    ENDLOOP.
  ENDIF.

  IF gv_snro IS NOT INITIAL.
* New inventory
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZINV'
        subobject               = lagp-lgnum
      IMPORTING
        number                  = lv_ivnum
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    LOOP AT gt_inven INTO lwa_inven.
      lwa_inven-ivnum  = lv_ivnum.
      lwa_inven-erdat  = sy-datum.
      lwa_inven-erzet  = sy-uzeit.
      lwa_inven-zuser1 = sy-uname.
      IF lwa_inven-kznul IS NOT INITIAL.
        lwa_inven-zcoudt  = sy-datum.
        lwa_inven-zcouzt  = sy-uzeit.
        lwa_inven-zcouun  = sy-uname.
      ELSE.
        IF lwa_inven-menge IS NOT INITIAL OR
          lwa_inven-menga IS NOT INITIAL.
          lwa_inven-zcoudt  = sy-datum.
          lwa_inven-zcouzt  = sy-uzeit.
          lwa_inven-zcouun  = sy-uname.
        ELSE.
          CLEAR : lwa_inven-zcoudt, lwa_inven-zcouzt, lwa_inven-zcouun.
        ENDIF.
      ENDIF.

      PERFORM f_material_convertion USING    lwa_inven-lgnum lwa_inven-matnr
                                             lwa_inven-charg lwa_inven-werks
                                             lwa_inven-menga lwa_inven-altme
                                             lwa_inven-menge lwa_inven-meins
                                    CHANGING lwa_inven-gesme1.

      INSERT zbpc0005 FROM lwa_inven.

      ADD 1 TO lv_posnr.

      LOOP AT gt_0005x INTO ls_0005x WHERE lgnum = lwa_inven-lgnum
                                       AND lgtyp = lwa_inven-lgtyp
                                       AND lgpla = lwa_inven-lgpla
                                       AND ivpos = lwa_inven-ivpos
                                       AND lqnum = lwa_inven-lqnum.

        PERFORM f_accuracy USING lv_ivnum lagp-lgnum
                                 lwa_inven-ivpos ls_0005x-senum
                                 lwa_inven-matnr lwa_inven-charg
                                 lwa_inven-lgort lwa_inven-meins
                                 lwa_inven-werks lwa_inven-menge
                                 ls_0005x-zact1 ls_0005x-zact2
                                 ls_0005x-aggr1
                           CHANGING lv_posnr.
      ENDLOOP.
      CLEAR lwa_inven.
    ENDLOOP.
  ELSE.
* Update inventory
    LOOP AT gt_inven INTO lwa_inven.
      IF lwa_inven-kznul IS NOT INITIAL.
        lwa_inven-zcoudt  = sy-datum.
        lwa_inven-zcouzt  = sy-uzeit.
        lwa_inven-zcouun  = sy-uname.
      ELSE.
        IF lwa_inven-menge IS NOT INITIAL OR
          lwa_inven-menga IS NOT INITIAL.
          lwa_inven-zcoudt  = sy-datum.
          lwa_inven-zcouzt  = sy-uzeit.
          lwa_inven-zcouun  = sy-uname.
        ELSE.
          CLEAR : lwa_inven-zcoudt, lwa_inven-zcouzt, lwa_inven-zcouun.
        ENDIF.
      ENDIF.

      PERFORM f_material_convertion USING    lwa_inven-lgnum lwa_inven-matnr
                                             lwa_inven-charg lwa_inven-werks
                                             lwa_inven-menga lwa_inven-altme
                                             lwa_inven-menge lwa_inven-meins
                                    CHANGING lwa_inven-gesme1.

      UPDATE zbpc0005 SET menge   = lwa_inven-menge
                          menga   = lwa_inven-menga
                          altme   = lwa_inven-altme
                          gesme1  = lwa_inven-gesme1
                          kznul   = lwa_inven-kznul
                          zcoudt  = lwa_inven-zcoudt
                          zcouzt  = lwa_inven-zcouzt
                          zcouun  = lwa_inven-zcouun
                      WHERE lgnum = lwa_inven-lgnum
                        AND lgtyp = lwa_inven-lgtyp
                        AND lgpla = lwa_inven-lgpla
                        AND ivnum = lwa_inven-ivnum
                        AND ivpos = lwa_inven-ivpos
                        AND lqnum = lwa_inven-lqnum.

      IF sy-subrc <> 0.
        INSERT zbpc0005 FROM lwa_inven.
      ENDIF.
      CLEAR lwa_inven.
    ENDLOOP.
  ENDIF.
  CLEAR gv_snro.
ENDFORM.                    " F_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_GET_WHSE_NO
*&---------------------------------------------------------------------*
FORM f_get_whse_no .
  SELECT SINGLE lgnum
    FROM lrf_wkqu
    INTO lagp-lgnum
    WHERE bname = sy-uname
      AND statu = 'X'.

  IF lagp-lgnum(1) = 'C'.
    SELECT SINGLE *
      FROM t320
      INTO CORRESPONDING FIELDS OF gs_t320
      WHERE lgnum = lagp-lgnum.
  ENDIF.
ENDFORM.                    " F_GET_WHSE_NO

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position .
  CASE sy-dynnr.
    WHEN '0100'.
      IF lqua-lgtyp IS NOT INITIAL.
        IF lqua-lgpla IS INITIAL.
          SET CURSOR FIELD 'LQUA-LGPLA'.
        ENDIF.
      ENDIF.
    WHEN '0101'.
      break bcdik.
      IF gv_newit IS INITIAL.
        IF lv_field IS INITIAL.
          SET CURSOR FIELD 'RLMOB-CMATNR'.
        ENDIF.
        CASE lv_field.
          WHEN 'RLMOB-CMATNR'.
            IF gv_senum IS INITIAL.
              SET CURSOR FIELD 'LINV-MENGA'.
            ELSE.
              SET CURSOR FIELD 'GV_SENUM'.
            ENDIF.
          WHEN 'GV_SENUM'.
            SET CURSOR FIELD 'LINV-MENGA'.
          WHEN 'LINV-MENGA'.
            SET CURSOR FIELD 'LINV-MENGE'.
          WHEN 'LINV-MENGE'.
            SET CURSOR FIELD 'RL04I-KZNUL'.
        ENDCASE.

*        IF rlmob-cmatnr IS INITIAL.
*          SET CURSOR FIELD 'RLMOB-CMATNR'.
*        ELSEIF linv-menga IS INITIAL.
*          SET CURSOR FIELD 'LINV-MENGA'.
*        ELSEIF linv-menge IS INITIAL.
*          SET CURSOR FIELD 'LINV-MENGE'.
*        ELSEIF rl04i-kznul IS NOT INITIAL.
*          SET CURSOR FIELD 'RL04I-KZNUL'.
*        ELSE.
*          CASE gv_lin.
*            WHEN 0.
*              SET CURSOR FIELD 'RLMOB-CMATNR'.
*            WHEN 1.
*              SET CURSOR FIELD 'LINV-MENGA'.
*            WHEN 2.
*              SET CURSOR FIELD 'LINV-MENGE'.
*          ENDCASE.
*        ENDIF.
*
        IF lv_field = 'LINV-MENGE'.
          SET CURSOR FIELD 'RLMOB-PSAVE'.
        ENDIF.
      ELSE.
        IF lv_field IS INITIAL.
          SET CURSOR FIELD 'LQUA-PLPOS'.
        ENDIF.
        CASE lv_field.
          WHEN 'RLMOB-CMATNR'.
            IF gv_senum IS INITIAL.
              SET CURSOR FIELD 'LINV-MENGA'.
            ELSE.
              SET CURSOR FIELD 'GV_SENUM'.
            ENDIF.
          WHEN 'LQUA-MATNR'.
            IF lqua-matnr IS INITIAL.
              SET CURSOR FIELD 'LQUA-MATNR'.
            ELSE.
              SET CURSOR FIELD 'LQUA-CHARG'.
*              SET CURSOR FIELD 'LINV-MENGA'.
            ENDIF.
          WHEN 'LQUA-CHARG'.
            IF linv-menga IS INITIAL AND
              linv-menge IS INITIAL.
              SET CURSOR FIELD 'LINV-MENGA'.
            ELSEIF linv-menga IS NOT INITIAL AND
              linv-menge IS INITIAL.
              SET CURSOR FIELD 'LINV-MENGE'.
            ELSE.
              SET CURSOR FIELD 'RLMOB-PSAVE'.
            ENDIF.
*            SET CURSOR FIELD 'RLMOB-PSAVE'.
          WHEN 'LQUA-PLPOS'.
            IF lqua-plpos IS NOT INITIAL AND
              lqua-matnr IS INITIAL.
              SET CURSOR FIELD 'RLMOB-CMATNR'.
            ENDIF.
          WHEN 'LINV-MENGA'.
            IF linv-menga IS NOT INITIAL.
              SET CURSOR FIELD 'LINV-MENGE'.
            ENDIF.
        ENDCASE.
*        IF lqua-matnr IS INITIAL.
*          SET CURSOR FIELD 'LQUA-MATNR'.
*        ELSEIF lqua-charg IS INITIAL.
*          SET CURSOR FIELD 'LQUA-CHARG'.
*        ELSEIF linv-menga IS INITIAL.
*          SET CURSOR FIELD 'LINV-MENGA'.
*        ELSEIF linv-menge IS INITIAL.
*          SET CURSOR FIELD 'LINV-MENGE'.
*        ELSEIF rl04i-kznul IS NOT INITIAL.
*          SET CURSOR FIELD 'RL04I-KZNUL'.
*        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREENMSG  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_screenmsg OUTPUT.
  SET PF-STATUS 'MOBILEMSG'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_SCREENMSG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
MODULE message OUTPUT.
  CLEAR : message1, message2, message3, message4, message5, message6,
          message7.
  CASE gv_subrc.
    WHEN '99'.
      message1 = 'Data already saved'.
    WHEN '1'.
      message1 = 'Storage type &'.
      message2 = 'Storage bin'.
      message3 = 'is empty'.
    WHEN '2'.
      message1 = 'Whse.No is empty'.
    WHEN '3'.
      message1 = 'Material'.
      CONCATENATE rlmob-cmatnr 'does' INTO message2
      SEPARATED BY space.
      message3 = 'not match'.
    WHEN '4'.
      message1 = 'Material must be'.
      message2 = 'entered'.
    WHEN '5'.
      message1 = 'Data not found'.
    WHEN '6'.
      CONCATENATE 'Batch' lqua-charg
      INTO message1
      SEPARATED BY space.
      message2 = 'does not exist for'.
      CONCATENATE 'material' lqua-matnr
      INTO message3
      SEPARATED BY space.
    WHEN '7'.
      message1 = 'Batch'.
      message2 = 'does not match'.
    WHEN '8'.
      message1 = 'SN'.
      message2 = 'does not match'.
    WHEN '9'.
      message1 = 'Wrong'.
      message2 = 'Material/Batch'.
    WHEN 10.
    WHEN 11.
      message1 = 'Serial Number'.
      message2 = 'already entered'.
    WHEN 12.
      message1 = 'Serial Number'.
      message2 = 'does not exist'.
  ENDCASE.
ENDMODULE.                 " MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_INVENTORY
*&---------------------------------------------------------------------*
FORM f_get_inventory .
  DATA : lv_ivpos   LIKE linv-ivpos,
         lt_lqua    TYPE STANDARD TABLE OF lqua,
         ls_lqua    LIKE LINE OF lt_lqua.

  CHECK gt_inven[] IS INITIAL.

  SELECT *
    FROM lagp
    INTO CORRESPONDING FIELDS OF TABLE gt_lagp
    WHERE lgnum   = lagp-lgnum
      AND lgtyp   = lqua-lgtyp
      AND lgpla   = lqua-lgpla.

  SELECT *
    FROM zbpc0005
    INTO CORRESPONDING FIELDS OF TABLE gt_inven
    WHERE lgnum   = lagp-lgnum
      AND lgtyp   = lqua-lgtyp
      AND lgpla   = lqua-lgpla
      AND zfinal  = space.

  IF gt_inven[] IS INITIAL.
    gv_snro = 'X'.
    SELECT lgnum lqnum matnr werks charg lgtyp lgpla plpos meins gesme verme lgort
      FROM lqua
      INTO CORRESPONDING FIELDS OF TABLE gt_inven
      WHERE lgnum   = lagp-lgnum
        AND lgtyp   = lqua-lgtyp
        AND lgpla   = lqua-lgpla.

    IF gt_inven[] IS INITIAL.
      IF gt_lagp[] IS NOT INITIAL.
        READ TABLE gt_lagp INDEX 1.
        IF gt_lagp-kzler IS NOT INITIAL.
          gt_inven-lgnum  = gt_lagp-lgnum.
          gt_inven-lgtyp  = gt_lagp-lgtyp.
          gt_inven-lgpla  = gt_lagp-lgpla.
          APPEND gt_inven.
          CLEAR gt_inven.
        ENDIF.
      ENDIF.
    ENDIF.

    SORT gt_inven BY lgnum matnr werks charg.
    LOOP AT gt_inven.
      ADD 1 TO lv_ivpos.
      IF gt_inven-ivpos IS INITIAL.
        gt_inven-ivpos = lv_ivpos.
        MODIFY gt_inven TRANSPORTING ivpos.
      ENDIF.
    ENDLOOP.
  ELSE.
    SELECT lgnum lqnum matnr werks charg lgtyp lgpla plpos meins gesme verme lgort
      FROM lqua
      INTO CORRESPONDING FIELDS OF TABLE lt_lqua
      FOR ALL ENTRIES IN gt_inven
      WHERE lgnum   = gt_inven-lgnum
        AND lgtyp   = gt_inven-lgtyp
        AND lgpla   = gt_inven-lgpla.

    LOOP AT gt_inven.
      CLEAR ls_lqua.
      READ TABLE lt_lqua INTO ls_lqua
                         WITH KEY lgnum = gt_inven-lgnum
                                  lgtyp = gt_inven-lgtyp
                                  lgpla = gt_inven-lgpla
                                  lqnum = gt_inven-lqnum.
      IF sy-subrc = 0.
        gt_inven-plpos = ls_lqua-plpos.
        MODIFY gt_inven TRANSPORTING plpos.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE gt_inven LINES gv_record.

  SELECT *
    FROM zmproject_ctrl
    INTO CORRESPONDING FIELDS OF TABLE gt_ctrl
    WHERE zproject = 'ZACC_ACT'
      AND datab    <= sy-datum
      AND datbi    >= sy-datum.
ENDFORM.                    " F_GET_INVENTORY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table  USING    fu_ivpos fu_kznul.
  DATA : lv_kznul   TYPE rl04i-kznul,
         ls_sn      LIKE LINE OF gt_sn.

  lv_kznul  = fu_kznul.

  CHECK fu_ivpos IS NOT INITIAL.

  IF sy-dynnr = '0101'.
    IF gt_sn[] IS NOT INITIAL.
      CLEAR linv-menge.
      LOOP AT gt_sn INTO ls_sn.
        ADD 1 TO linv-menge.
      ENDLOOP.
    ENDIF.

    READ TABLE gt_lagp INDEX 1.

    IF rl04i-kznul IS NOT INITIAL.
      lv_kznul = 'X'.
      IF linv-menge IS NOT INITIAL OR
        linv-menga IS NOT INITIAL.
        CLEAR lv_kznul.
      ENDIF.
      IF gt_lagp-kzler IS NOT INITIAL.
        CLEAR rlmob-cmatnr.
      ENDIF.
    ENDIF.

    IF lv_kznul IS INITIAL.
      gt_inven-cmatnr = rlmob-cmatnr.
      gt_inven-menge  = linv-menge.
      gt_inven-menga  = linv-menga.
      gt_inven-altme  = 'KAR'.
      gt_inven-meins  = linv-meins.
      CLEAR : gt_inven-kznul.
      MODIFY gt_inven INDEX fu_ivpos
                      TRANSPORTING cmatnr menge menga altme kznul.
    ELSE.
      gt_inven-cmatnr = rlmob-cmatnr.
      gt_inven-menge  = linv-menge.
      gt_inven-menga  = linv-menga.
      gt_inven-kznul  = rl04i-kznul.
      gt_inven-meins  = linv-meins.
      CLEAR gt_inven-altme.
      MODIFY gt_inven INDEX fu_ivpos
                      TRANSPORTING cmatnr menge menga altme kznul.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validate_data OUTPUT.
  CASE sy-dynnr.
    WHEN '0100'.
    WHEN '0101'.
      IF gv_newit IS INITIAL.
        PERFORM f_validate_data USING ''.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " VALIDATE_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data USING fu_valid.
  DATA : lv_charg    LIKE mch1-charg,
         lv_matnr    LIKE mara-matnr,
         lv_tanum    LIKE ltak-tanum,
         lv_jumlah(20),
         lv_mblnr TYPE ltak-mblnr,
         lv_menget(20).

  TRANSLATE rlmob-cmatnr TO UPPER CASE.

  IF lagp-lgnum = '041' OR
    lagp-lgnum = '042' OR
    lagp-lgnum = '011' OR
    lagp-lgnum = '012'.
    SPLIT rlmob-cmatnr AT ';' INTO lv_matnr lv_charg lv_jumlah lv_mblnr lv_menget.
*    rlmob-cmatnr = lv_matnr.
  ELSEIF lagp-lgnum(2) = '36'.
    SPLIT rlmob-cmatnr AT ';' INTO lv_matnr lv_charg lv_tanum.
  ELSE.
    SPLIT rlmob-cmatnr AT ';' INTO lv_matnr lv_charg lv_jumlah.
*    lv_matnr  = rlmob-cmatnr.
  ENDIF.

  CASE fu_valid.
    WHEN space.
      CHECK gv_subrc IS INITIAL.

      IF gv_record IS INITIAL.
        IF gt_lagp[] IS INITIAL.
          gv_subrc  = 5.
          CALL SCREEN 2999.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.

      IF rlmob-cmatnr IS NOT INITIAL.
        PERFORM f_check_matnr USING lqua-matnr
                              CHANGING lv_matnr.
        IF lagp-lgnum(2) = '36'.
          PERFORM f_matnr_batch USING lv_matnr lv_charg.
        ELSE.
          IF lqua-matnr IS NOT INITIAL.
            IF lqua-matnr <> lv_matnr.  "rlmob-cmatnr.
              gv_subrc  = 3.
              CALL SCREEN 2999.
              SET CURSOR FIELD 'RLMOB-CMATNR'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lagp-lgnum = '041' OR
        lagp-lgnum = '042' OR
        lagp-lgnum = '011' OR
        lagp-lgnum = '012'.
        IF gv_subrc IS INITIAL.
          IF lqua-charg IS NOT INITIAL
            AND lv_charg IS NOT INITIAL.
            IF lqua-charg <> lv_charg.
              gv_subrc = 7.
              CALL SCREEN 2999.
            ELSE.
              CLEAR gv_subrc.
            ENDIF.
          ELSE.
            IF gv_newit IS INITIAL.
              gv_subrc = 10.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF gv_subrc IS INITIAL.
          IF rlmob-cmatnr IS NOT INITIAL.
            IF lv_charg IS INITIAL.
              CLEAR gv_subrc.
            ELSEIF lqua-charg <> lv_charg.
              gv_subrc = 7.
              CALL SCREEN 2999.
            ENDIF.
          ELSE.
            IF gv_newit IS INITIAL.
              gv_subrc = 10.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gv_subrc IS INITIAL.
        PERFORM f_active_sn USING lv_matnr lv_charg.
      ELSEIF gv_subrc = 10.
        CLEAR gv_subrc.
      ENDIF.

    WHEN 'MATNR'.
      READ TABLE gt_lagp INDEX 1.

      IF gv_record IS INITIAL.
        IF gt_lagp-kzler IS NOT INITIAL.
        ELSE.
          gv_subrc  = 5.
        ENDIF.
      ENDIF.

      CHECK gv_subrc IS INITIAL.

      IF rlmob-cmatnr IS NOT INITIAL.
        PERFORM f_check_matnr USING lqua-matnr
                              CHANGING lv_matnr.
        IF lagp-lgnum(2) = '36'.
          PERFORM f_matnr_batch USING lv_matnr lv_charg.
        ELSE.
          IF lqua-matnr IS NOT INITIAL.
            IF lqua-matnr <> lv_matnr.     "rlmob-cmatnr.
              gv_subrc  = 3.
            ELSE.
              CLEAR gv_subrc.
            ENDIF.
          ELSE.
            CLEAR gv_subrc.
          ENDIF.
        ENDIF.
      ENDIF.

      CHECK gv_subrc IS INITIAL.

      IF lagp-lgnum = '041' OR
        lagp-lgnum = '042' OR
        lagp-lgnum = '011' OR
        lagp-lgnum = '012'.
        IF gv_subrc IS INITIAL.
          CHECK lqua-charg IS NOT INITIAL
            AND lv_charg IS NOT INITIAL.
          IF lqua-charg <> lv_charg.
            gv_subrc = 7.
          ELSE.
            CLEAR gv_subrc.
          ENDIF.
        ENDIF.
      ELSE.
        IF rlmob-cmatnr IS NOT INITIAL.
          IF lv_charg IS INITIAL.
            CLEAR gv_subrc.
          ELSEIF lqua-charg <> lv_charg.
            gv_subrc = 7.
          ENDIF.
        ELSE.
          IF gv_newit IS INITIAL.
            gv_subrc = 10.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'CHARG'.
      CHECK lqua-matnr IS NOT INITIAL
        AND lqua-charg IS NOT INITIAL.

      IF gv_subrc IS INITIAL.
        CLEAR lv_charg.
        SELECT SINGLE charg
          FROM mch1
          INTO lv_charg
          WHERE matnr = lqua-matnr
            AND charg = lqua-charg.
        IF sy-subrc <> 0.
          gv_subrc = 6.
          CALL SCREEN 2999.
          SET CURSOR FIELD 'LQUA-CHARG'.
        ELSE.
          CLEAR gv_subrc.
        ENDIF.
      ENDIF.

*    WHEN 'SENUM'.
*      CHECK lqua-matnr IS NOT INITIAL
*        AND lqua-charg IS NOT INITIAL
*        AND gv_senum IS NOT INITIAL.
*
*      IF gv_subrc IS INITIAL.
*        CLEAR gs_zaccdtm.
*        SELECT SINGLE *
*          FROM zaccdtm
*          INTO gs_zaccdtm
*          WHERE matnr = lqua-matnr
*            AND charg = lqua-charg
*            AND senum = gv_senum.
*        IF sy-subrc <> 0.
*          gv_subrc = 8.
*          CALL SCREEN 2999.
*          SET CURSOR FIELD 'GV_SENUM'.
*        ELSE.
*          CLEAR gv_subrc.
*        ENDIF.
*      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_CONVERTION
*&---------------------------------------------------------------------*
FORM f_material_convertion  USING    fu_lgnum fu_matnr fu_charg fu_werks
                                     fu_menga fu_altme fu_menge fu_meins
                            CHANGING fc_gesme.
  DATA : lv_umrez   LIKE marm-umrez,
         lv_umren   LIKE marm-umren,
         cob        TYPE STANDARD TABLE OF clbatch,
         ls_cob     LIKE LINE OF cob.

  CLEAR : fc_gesme.

  IF fu_lgnum = '011' OR
    fu_lgnum = '012'.
    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        matnr              = fu_matnr
        charg              = fu_charg
        werks              = fu_werks
        get_classification = 'X'
      TABLES
        char_of_batch      = cob
      EXCEPTIONS
        no_material        = 1
        no_batch           = 2
        no_plant           = 3
        material_not_found = 4
        plant_not_found    = 5
        no_authority       = 6
        batch_not_exist    = 7
        lock_on_batch      = 8
        OTHERS             = 9.
  ENDIF.

  IF fu_menga IS NOT INITIAL.
    IF cob[] IS NOT INITIAL.
      READ TABLE cob INTO ls_cob
                     WITH KEY atnam = 'QTY_CONVERSION'.
      IF sy-subrc = 0.
        TRANSLATE ls_cob-atwtb USING '. '.
        TRANSLATE ls_cob-atwtb USING ',.'.
        CONDENSE ls_cob-atwtb NO-GAPS.
        fc_gesme  = fu_menga * ls_cob-atwtb.
      ENDIF.
    ELSE.
      SELECT SINGLE umrez umren
        FROM marm
        INTO (lv_umrez, lv_umren)
        WHERE matnr = fu_matnr
          AND meinh = fu_altme.

      IF lv_umrez > lv_umren.
        fc_gesme  = ( fu_menga * lv_umrez ) / lv_umren.
      ELSE.
        fc_gesme  = ( fu_menga * lv_umren ) / lv_umrez.
      ENDIF.
    ENDIF.
  ENDIF.

  fc_gesme  = fc_gesme + fu_menge.
ENDFORM.                    " F_MATERIAL_CONVERTION

*&---------------------------------------------------------------------*
*&      Form  F_NEWITEM
*&---------------------------------------------------------------------*
FORM f_newitem .
  DATA : lv_record  TYPE sy-tabix,
         lv_mtart   TYPE mara-mtart,
         lv_index   TYPE sy-tabix.

  CLEAR rlmob-cmatnr.

  DESCRIBE TABLE gt_inven LINES lv_record.

  IF lagp-lgnum = '041' OR
    lagp-lgnum = '042' OR
    lagp-lgnum = '011' OR
    lagp-lgnum = '012'.
  ELSE.
    PERFORM f_modify_screen USING : '' 'RLMOB-CMATNR' '0' '' '' ''.
    PERFORM f_modify_screen USING : '' 'LQUA-MATNR' '' '1' '' ''.
    PERFORM f_modify_screen USING : '' 'LQUA-CHARG' '' '1' '' ''.
  ENDIF.

  IF lqua-matnr IS NOT INITIAL AND
    lqua-charg IS NOT INITIAL.
    PERFORM f_modify_screen USING : '' 'LQUA-MATNR' '' '0' '' ''.
    PERFORM f_modify_screen USING : '' 'LQUA-CHARG' '' '0' '' ''.

    PERFORM f_modify_screen USING : '' 'LINV-MENGA' '' '1' '' ''.
    PERFORM f_modify_screen USING : '' 'LINV-MENGE' '' '1' '' ''.
  ELSEIF lqua-matnr IS INITIAL AND
    lqua-charg IS INITIAL.
    PERFORM f_modify_screen USING : '' 'LQUA-MATNR' '' '1' '' ''.
    PERFORM f_modify_screen USING : '' 'LQUA-CHARG' '' '1' '' ''.

    PERFORM f_modify_screen USING : '' 'LINV-MENGA' '' '0' '' ''.
    PERFORM f_modify_screen USING : '' 'LINV-MENGE' '' '0' '' ''.
  ELSEIF lqua-matnr IS NOT INITIAL AND
    lqua-charg IS INITIAL.
    PERFORM f_modify_screen USING : '' 'LQUA-MATNR' '' '0' '' ''.
    PERFORM f_modify_screen USING : '' 'LQUA-CHARG' '' '1' '' ''.

    PERFORM f_modify_screen USING : '' 'LINV-MENGA' '' '0' '' ''.
    PERFORM f_modify_screen USING : '' 'LINV-MENGE' '' '0' '' ''.
  ENDIF.

  IF rlmob-mmakt IS INITIAL.
    CLEAR : lqua-matnr, lqua-charg, linv-meins,
            linv-menga, linv-menge, rl04i-kznul.
  ELSE.
    SELECT SINGLE maktx
      FROM makt
      INTO rlmob-mmakt
      WHERE matnr = lqua-matnr
        AND spras = sy-langu.

    SELECT SINGLE meins mtart
      FROM mara
      INTO (linv-meins, lv_mtart)
      WHERE matnr = lqua-matnr.
  ENDIF.

  IF lqua-matnr IS NOT INITIAL.
    CLEAR : gt_inven-lqnum, gt_inven-gesme, gt_inven-gesme1,
            gt_inven-verme, gt_inven-verme1, gt_inven-menga,
            gt_inven-altme, gt_inven-menge, gt_inven-kznul.

    gt_inven-matnr  = lqua-matnr.
    gt_inven-ivpos  = lv_record + 1.
    gt_inven-charg  = lqua-charg.
    gt_inven-addni  = 'X'.
    gt_inven-erdat  = sy-datum.
    gt_inven-erzet  = sy-uzeit.
    gt_inven-zuser1 = sy-uname.
    gt_inven-meins  = linv-meins.
    gt_inven-plpos  = lqua-plpos.
    CONDENSE gt_inven-plpos NO-GAPS.

    IF lv_mtart = 'ZCGN'.
      APPEND gt_inven.
      CLEAR gt_inven.
    ELSE.
      IF lqua-charg IS NOT INITIAL AND
        gt_inven-lgnum IS NOT INITIAL.
        PERFORM f_validate_data USING 'CHARG'.
        IF gv_subrc IS INITIAL.
          APPEND gt_inven.
          CLEAR gt_inven.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEWITEM

*&---------------------------------------------------------------------*
*&      Form  F_ACCURACY
*&---------------------------------------------------------------------*
FORM f_accuracy  USING    fu_ivnum fu_lgnum fu_ivpos fu_senum
                          fu_matnr fu_charg fu_lgort fu_meins
                          fu_werks fu_menge fu_zact1 fu_zact2
                          fu_aggr1
                 CHANGING fc_posnr.
  DATA : lt_accdtd    TYPE STANDARD TABLE OF zaccdtd,
         ls_accdtd    LIKE LINE OF lt_accdtd,
         lt_s501      TYPE STANDARD TABLE OF s501,
         ls_s501      LIKE LINE OF lt_s501.

  CONCATENATE 'D' fu_lgnum INTO ls_accdtd-docat.
  ls_accdtd-docno   = fu_ivnum.
  ls_accdtd-posnr   = fc_posnr.
  ls_accdtd-senum   = fu_senum.
  ls_accdtd-scandt  = sy-datum.
  ls_accdtd-ernam   = sy-uname.
  ls_accdtd-time    = sy-uzeit.
  TRY .
      INSERT zaccdtd FROM ls_accdtd.
    CATCH cx_sy_open_sql_db.
  ENDTRY.

  TRY .
      UPDATE zaccdta SET zact1   = fu_zact1
                         zact2   = fu_zact2
                     WHERE matnr = lqua-matnr
                       AND charg = lqua-charg
                       AND aggr1 = fu_aggr1.
    CATCH cx_sy_conversion_no_number.
  ENDTRY.

*    TRY .
*        UPDATE zaccdtm SET snsta = 'ESTO'
*                       WHERE matnr = lqua-matnr
*                         AND charg = lqua-charg
*                         AND senum = ls_sn-senum.
*      CATCH cx_sy_conversion_no_number.
*    ENDTRY.
ENDFORM.                    " F_ACCURACY

*&---------------------------------------------------------------------*
*&      Form  F_ISI_SERIAL_NUMBER
*&---------------------------------------------------------------------*
FORM f_isi_serial_number .
  DATA : ls_zaccdtm  LIKE LINE OF gt_zaccdtm,
         lv_senum(20),
         lv_charg(10),
         lv_matnr    TYPE mara-matnr,
         lt_valsn    TYPE STANDARD TABLE OF ty_valsn,
         ls_valsn    LIKE LINE OF lt_valsn,
         lt_sn       TYPE STANDARD TABLE OF ty_sn,
         ls_sn       LIKE LINE OF gt_sn,
         ls_inven    LIKE LINE OF gt_inven,
         ls_0005x    LIKE LINE OF gt_0005x.

  CALL METHOD zcl_util=>m_acc_split_sn
    EXPORTING
      pvi_senum = gv_senum
    IMPORTING
      pvo_senum = lv_senum
      pvo_matnr = lv_matnr
      pvo_charg = lv_charg.

  PERFORM f_aggregasi TABLES lt_valsn
                      USING  lv_matnr lv_charg lv_senum.

  IF gv_subrc IS INITIAL.
* Validasi Material & Batch terhadap screen
    PERFORM f_validasi_1 USING lv_matnr lv_charg.
  ELSE.
    PERFORM f_minus_qty CHANGING linv-menga.
    PERFORM f_minus_qty CHANGING linv-menge.
  ENDIF.

  IF gv_subrc IS INITIAL.
* Validasi sudah pernah discan atau belum
    PERFORM f_validasi_2 TABLES lt_valsn.
  ELSE.
    PERFORM f_minus_qty CHANGING linv-menga.
    PERFORM f_minus_qty CHANGING linv-menge.
  ENDIF.

  IF gv_subrc IS INITIAL.
* Validasi ke Master Serial Number
    PERFORM f_validasi_3 TABLES lt_valsn
                         USING lqua-matnr lv_charg.
  ELSE.
    PERFORM f_minus_qty CHANGING linv-menga.
    PERFORM f_minus_qty CHANGING linv-menge.
  ENDIF.

  IF gv_subrc IS INITIAL.
    CLEAR ls_inven.
    READ TABLE gt_inven INTO ls_inven
                        WITH KEY matnr = lqua-matnr
                                 charg = lqua-charg.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_inven TO ls_0005x.
    ENDIF.
    LOOP AT lt_valsn INTO ls_valsn.
      gs_sn-matnr  = lqua-matnr.
      gs_sn-charg  = lqua-charg.
      gs_sn-senum  = ls_valsn-senum.
      gs_sn-check  = 'X'.
      gs_sn-aggr1  = ls_valsn-aggr1.
      gs_sn-zact1  = ls_valsn-zact1.
      gs_sn-aggr2  = ls_valsn-aggr2.
      gs_sn-zact2  = ls_valsn-zact2.
      APPEND gs_sn TO gt_sn.

      ls_0005x-senum  = ls_valsn-senum.
      ls_0005x-aggr1  = ls_valsn-aggr1.
      ls_0005x-zact1  = ls_valsn-zact1.
      ls_0005x-aggr2  = ls_valsn-aggr2.
      ls_0005x-zact2  = ls_valsn-zact2.
      APPEND ls_0005x TO gt_0005x.
    ENDLOOP.
  ELSE.
    PERFORM f_minus_qty CHANGING linv-menga.
    PERFORM f_minus_qty CHANGING linv-menge.
  ENDIF.
ENDFORM.                    " F_ISI_SERIAL_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_AGGREGASI
*&---------------------------------------------------------------------*
FORM f_aggregasi  TABLES   ft_valsn LIKE gt_valsn
                  USING    fu_matnr fu_charg fu_senum.
  DATA : lt_zaccdta   TYPE STANDARD TABLE OF zaccdta,
         ls_zaccdta   LIKE LINE OF lt_zaccdta,
         ls_valsn     LIKE LINE OF gt_valsn,
         lv_aggr      TYPE i.

  SELECT *
    FROM zaccdta
    INTO CORRESPONDING FIELDS OF TABLE lt_zaccdta
    WHERE matnr = fu_matnr
      AND charg = fu_charg
      AND aggr2 = fu_senum.
  IF sy-subrc <> 0.
    lv_aggr = 1.
    SELECT *
      FROM zaccdta
      INTO CORRESPONDING FIELDS OF TABLE lt_zaccdta
      WHERE matnr = fu_matnr
        AND charg = fu_charg
        AND aggr1 = fu_senum.
    IF sy-subrc <> 0.
      lv_aggr = 0.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE lt_zaccdta
        WHERE matnr = fu_matnr
          AND charg = fu_charg
          AND senum = fu_senum.
    ENDIF.
  ELSE.
    lv_aggr = 2.
  ENDIF.

  IF lt_zaccdta[] IS INITIAL.
    ls_valsn-senum = fu_senum.
    APPEND ls_valsn TO ft_valsn.
  ELSE.
    LOOP AT lt_zaccdta INTO ls_zaccdta.
      ls_valsn-senum = ls_zaccdta-senum.
      ls_valsn-aggr1 = ls_zaccdta-aggr1.
      ls_valsn-aggr2 = ls_zaccdta-aggr2.
      CASE lv_aggr.
        WHEN 0.
          CLEAR : ls_valsn-zact2, ls_valsn-zact1.
        WHEN 1.
          CLEAR ls_valsn-zact2.
          ls_valsn-zact1   = 'X'.
        WHEN 2.
          ls_valsn-zact2   = 'X'.
          ls_valsn-zact1   = 'X'.
      ENDCASE.
      APPEND ls_valsn TO ft_valsn.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_AGGREGASI

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_1
*&---------------------------------------------------------------------*
FORM f_validasi_1  USING    fu_matnr fu_charg.
  DATA : lv_matnr         TYPE mara-matnr.

  lv_matnr  = fu_matnr.

  IF lqua-matnr <> lv_matnr.
    gv_subrc = 9.
  ENDIF.

  IF lqua-charg IS NOT INITIAL.
    IF lqua-charg <> fu_charg.
      gv_subrc = 9.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_1

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_2
*&---------------------------------------------------------------------*
FORM f_validasi_2  TABLES   ft_valsn LIKE gt_valsn.
  DATA : ls_valsn   LIKE LINE OF gt_valsn,
         ls_sn      LIKE LINE OF gt_sn.

  LOOP AT ft_valsn INTO ls_valsn.
    READ TABLE gt_sn INTO ls_sn
                     WITH KEY senum = ls_valsn-senum.
    IF sy-subrc = 0.
      gv_subrc  = 11.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_2

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_3
*&---------------------------------------------------------------------*
FORM f_validasi_3  TABLES   ft_valsn LIKE gt_valsn
                   USING    fu_matnr fu_charg.
  DATA : ls_zaccdtm   LIKE LINE OF gt_zaccdtm,
         ls_valsn     LIKE LINE OF gt_valsn.

  LOOP AT ft_valsn INTO ls_valsn.
    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                         WITH KEY matnr = fu_matnr
                                  charg = fu_charg
                                  senum = ls_valsn-senum.
    IF sy-subrc <> 0.
      gv_subrc  = 12.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_3

*&---------------------------------------------------------------------*
*&      Form  F_ACTIVE_SN
*&---------------------------------------------------------------------*
FORM f_active_sn USING fu_matnr fu_charg.
  DATA : ls_ctrl   LIKE LINE OF gt_ctrl,
         lt_ctrl   TYPE STANDARD TABLE OF zmproject_ctrl,
         lr_werks  TYPE RANGE OF werks_d,
         lr_lgort  TYPE RANGE OF lgort_d,
         ls_werks  LIKE LINE OF lr_werks,
         ls_lgort  LIKE LINE OF lr_lgort,
         ls_xctrl  LIKE LINE OF gt_ctrl.

  DATA : lv_charg    LIKE mch1-charg,
         lv_matnr    LIKE mara-matnr,
         lv_tanum    LIKE ltak-tanum.

  READ TABLE gt_inven INDEX 1.
  lt_ctrl[] = gt_ctrl[].
  SORT lt_ctrl BY zevent.
  DELETE ADJACENT DUPLICATES FROM lt_ctrl COMPARING zevent.

  LOOP AT lt_ctrl INTO ls_ctrl.
    LOOP AT gt_ctrl INTO ls_xctrl WHERE zevent = ls_ctrl-zevent.
      CASE ls_xctrl-fieldname1.
        WHEN 'WERKS'.
          ls_werks-low    = ls_xctrl-low1.
          IF ls_xctrl-option1 = 'BT'.
            ls_werks-high   = ls_xctrl-high1.
          ENDIF.
          ls_werks-sign   = ls_xctrl-sign1.
          ls_werks-option = ls_xctrl-option1.
          APPEND ls_werks TO lr_werks.
          CLEAR ls_werks.
        WHEN 'LGORT'.
          ls_lgort-low    = ls_xctrl-low1.
          IF ls_xctrl-option1 = 'BT'.
            ls_lgort-high   = ls_xctrl-high1.
          ENDIF.
          ls_lgort-sign   = ls_xctrl-sign1.
          ls_lgort-option = ls_xctrl-option1.
          APPEND ls_lgort TO lr_lgort.
          CLEAR ls_lgort.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

  IF lr_werks[] IS NOT INITIAL OR
     lr_lgort[] IS NOT INITIAL.
    IF gt_inven-werks IN lr_werks AND
      gt_inven-lgort IN lr_lgort.
      CLEAR gs_zaccdtm.
      READ TABLE gt_zaccdtm INTO gs_zaccdtm
                            WITH KEY matnr = lqua-matnr
                                     charg = lqua-charg.
      IF sy-subrc = 0.
        LOOP AT SCREEN.
          IF screen-name = 'LINV-MENGA' OR
            screen-name = 'LINV-MENGE'.
            screen-input = 0.
          ELSEIF screen-name = 'GV_SENUM'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'LINV-MENGA' OR
            screen-name = 'LINV-MENGE'.
            screen-input = 1.
          ELSEIF screen-name = 'GV_SENUM'.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ELSE.
      PERFORM f_modify_screen USING : '' 'LINV-MENGA' '' '1' '' '',
                                      '' 'LINV-MENGE' '' '1' '' ''.
    ENDIF.
  ELSE.
    IF lagp-lgnum(2) = '36'.
      SPLIT rlmob-cmatnr AT ';' INTO lv_matnr lv_charg lv_tanum.
      IF lqua-matnr = lv_matnr AND
        lqua-charg = lv_charg.
        LOOP AT SCREEN.
          IF screen-name = 'LINV-MENGA' OR
            screen-name = 'LINV-MENGE'.
            screen-input = 1.
          ELSEIF screen-name = 'GV_SENUM'.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ELSE.
      IF lqua-matnr <> rlmob-cmatnr.
        IF lqua-matnr = fu_matnr AND
          lqua-charg = fu_charg.
          PERFORM f_modify_screen USING : '' 'LINV-MENGA' '' '1' '' '',
                                          '' 'LINV-MENGE' '' '1' '' ''.
        ELSE.
          LOOP AT SCREEN.
            IF screen-name = 'LINV-MENGA' OR
              screen-name = 'LINV-MENGE'.
              screen-input = 0.
            ELSEIF screen-name = 'GV_SENUM'.
              screen-invisible = 1.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
        ENDIF.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'LINV-MENGA' OR
            screen-name = 'LINV-MENGE'.
            screen-input = 1.
          ELSEIF screen-name = 'GV_SENUM'.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ACTIVE_SN

*&---------------------------------------------------------------------*
*&      Form  F_MINUS_QTY
*&---------------------------------------------------------------------*
FORM f_minus_qty  CHANGING fc_menge.
  IF fc_menge <> 0.
    fc_menge = fc_menge - 1.
  ENDIF.
ENDFORM.                    " F_MINUS_QTY

*&---------------------------------------------------------------------*
*&      Form  F_NEW_ITEM
*&---------------------------------------------------------------------*
FORM f_new_item .
  DATA : lv_charg    LIKE mch1-charg,
         lv_matnr    LIKE mara-matnr,
         lv_jumlah(20),
         lv_mblnr TYPE ltak-mblnr,
         lv_menget(20),
         lv_cmatnr(100).

  DATA : lt_mean      TYPE STANDARD TABLE OF mean,
         lr_ean11     TYPE RANGE OF ean11,
         ls_ean11     LIKE LINE OF lr_ean11,
         lt_makt      TYPE STANDARD TABLE OF makt,
         ls_mean      LIKE LINE OF lt_mean,
         ls_mara      LIKE LINE OF gt_mara,
         ls_makt      LIKE LINE OF lt_makt.

  DATA : lv_str1     TYPE string,
         lv_str2     TYPE string,
         lv_ean11    TYPE mean-ean11,
         lv_lines    TYPE i,
         lv_zeile    TYPE mseg-zeile.

  IF lagp-lgnum = '041' OR
    lagp-lgnum = '042' OR
    lagp-lgnum = '011' OR
    lagp-lgnum = '012'.
    IF rlmob-cmatnr IS NOT INITIAL.
      SPLIT rlmob-cmatnr AT ';' INTO lqua-matnr lqua-charg lv_jumlah lv_mblnr lv_menget.
    ENDIF.
*    rlmob-cmatnr = lv_matnr.
  ELSE.
    CLEAR gt_mara[].
    IF lqua-matnr IS NOT INITIAL.
      SPLIT lqua-matnr AT '_' INTO lv_str1 lv_str2.
      CONCATENATE lv_str1 '*' INTO ls_ean11-low.
      ls_ean11-sign      = 'I'.
      ls_ean11-option    = 'CP'.
      APPEND ls_ean11 TO lr_ean11.

      SELECT *
        FROM mean
        INTO CORRESPONDING FIELDS OF TABLE lt_mean
        WHERE ean11 IN lr_ean11.
      IF lt_mean[] IS NOT INITIAL.
        SELECT *
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE lt_makt
          FOR ALL ENTRIES IN lt_mean
          WHERE matnr = lt_mean-matnr.
      ENDIF.

      DESCRIBE TABLE lt_mean LINES lv_lines.
      IF lv_lines > 1.
        LOOP AT lt_mean INTO ls_mean.
          READ TABLE gt_inven INTO ls_inven
                              WITH KEY matnr = ls_mean-matnr.
          IF sy-subrc <> 0.
            ADD 1 TO lv_zeile.
            ls_mara-zeile = lv_zeile.
            ls_mara-matnr = ls_mean-matnr.
            CLEAR ls_makt.
            READ TABLE lt_makt INTO ls_makt
                               WITH KEY matnr = ls_mara-matnr.
            IF sy-subrc = 0.
              ls_mara-maktx = ls_makt-maktx.
            ENDIF.
            APPEND ls_mara TO gt_mara.
          ENDIF.
        ENDLOOP.
        CALL SCREEN 102.
      ENDIF.

      lv_cmatnr = lqua-matnr.
*      CALL FUNCTION 'ZWM_CHECK_MATNR'
*        EXPORTING
*          pi_chumat = lv_cmatnr
*        IMPORTING
*          pe_matnr  = lqua-matnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEW_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_name fu_active fu_input
                               fu_invisible fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group IS NOT INITIAL.
        IF screen-group1 = fu_group.
          screen-input  = fu_input.
        ENDIF.
      ELSEIF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group IS NOT INITIAL.
        IF screen-group1 = fu_group.
          screen-active  = fu_active.
        ENDIF.
      ELSEIF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group IS NOT INITIAL.
        IF screen-group1 = fu_group.
          screen-invisible  = fu_invisible.
        ENDIF.
      ELSEIF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group IS NOT INITIAL.
        IF screen-group1 = fu_group.
          screen-required  = fu_required.
        ENDIF.
      ELSEIF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-required  = fu_required.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_NEW_ITEM
*&---------------------------------------------------------------------*
FORM f_save_new_item  .
  DATA : lv_plpos   TYPE lqua-plpos.

  lv_plpos = lqua-plpos.
  CONDENSE lv_plpos NO-GAPS.

  IF linv-menge IS NOT INITIAL OR
    linv-menga IS NOT INITIAL.
    IF lqua-plpos IS INITIAL.
      IF lagp-lgnum <> '011' AND
        lagp-lgnum <> '012'.
        gt_inven-menge  = linv-menge.
        gt_inven-menga  = linv-menga.
        MODIFY gt_inven TRANSPORTING menge menga altme
                        WHERE matnr = lqua-matnr
                          AND charg = lqua-charg.
      ENDIF.
    ELSE.
      gt_inven-menge  = linv-menge.
      gt_inven-menga  = linv-menga.
      MODIFY gt_inven TRANSPORTING menge menga altme
                      WHERE matnr = lqua-matnr
                        AND charg = lqua-charg
                        AND plpos = lv_plpos.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SAVE_NEW_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_MATNR_BATCH
*&---------------------------------------------------------------------*
FORM f_matnr_batch  USING    fu_matnr fu_charg.
  IF lqua-matnr IS NOT INITIAL.
    IF lqua-matnr <> fu_matnr.
      gv_subrc  = 3.
      CALL SCREEN 2999.
      SET CURSOR FIELD 'RLMOB-CMATNR'.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF lqua-charg IS NOT INITIAL
      AND fu_charg IS NOT INITIAL.
      IF lqua-charg <> fu_charg.
        gv_subrc = 7.
        CALL SCREEN 2999.
      ELSE.
        CLEAR gv_subrc.
      ENDIF.
    ELSE.
      gv_subrc = 10.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MATNR_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MATNR
*&---------------------------------------------------------------------*
FORM f_check_matnr  USING    fu_matnr
                    CHANGING fc_matnr.
  DATA : lv_cmatnr(100),
         lv_matnr   TYPE mara-matnr,
         lv_str1    TYPE string,
         lv_str2    TYPE string.

  lv_cmatnr = fc_matnr.
  SPLIT lv_cmatnr AT '_' INTO lv_str1 lv_str2.
  lv_cmatnr = lv_str1.

  CALL FUNCTION 'ZWM_CHECK_MATNR'
    EXPORTING
      pi_chumat = lv_cmatnr
      pi_matnr  = fu_matnr
    IMPORTING
      pe_matnr  = lv_matnr.
  fc_matnr  = lv_matnr.
ENDFORM.                    " F_CHECK_MATNR

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CLEAR : gt_mara[], gv_zeile.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT
