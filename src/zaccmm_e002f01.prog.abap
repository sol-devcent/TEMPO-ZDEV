*&---------------------------------------------------------------------*
*&  Include           ZACCMM_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  sy-lsind = 0.

  SET PF-STATUS 'LMOB_GROUP3'.

  LOOP AT SCREEN.
    IF screen-name = 'PB_COPY'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validate_data OUTPUT.

ENDMODULE.                 " VALIDATE_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.
  DATA : lt_sn TYPE STANDARD TABLE OF ty_sn,
         ls_sn LIKE LINE OF gt_sn.

  DATA : lv_index(10),
         lv_count     TYPE i,
         lv_total     TYPE i.

  CASE sy-dynnr.
    WHEN '0212' OR '0222' OR '0232' OR '0242'.
      lt_sn[]  = gt_sn[].
      SORT lt_sn BY matnr charg.
      READ TABLE lt_sn INTO ls_sn
                       WITH KEY charg = space
                       TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING matnr.
        DESCRIBE TABLE lt_sn LINES gv_lines.
      ELSE.
        DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING matnr charg.
        DESCRIBE TABLE lt_sn LINES gv_lines.
      ENDIF.

      IF gv_index IS INITIAL.
        gv_index  = 1.
      ENDIF.

      CLEAR : ls_sn, lv_count, lv_total.
      READ TABLE lt_sn INTO ls_sn INDEX gv_index.
      IF sy-subrc = 0.
        IF ls_sn-charg IS INITIAL.
          LOOP AT gt_sn INTO gs_sn WHERE matnr = ls_sn-matnr.
            IF gs_sn-senum IS NOT INITIAL.
              ADD 1 TO lv_count.
            ENDIF.
            ADD 1 TO lv_total.
          ENDLOOP.
        ELSE.
          LOOP AT gt_sn INTO gs_sn WHERE matnr = ls_sn-matnr
                                     AND charg = ls_sn-charg.
            IF gs_sn-senum IS NOT INITIAL.
              ADD 1 TO lv_count.
            ENDIF.
            ADD 1 TO lv_total.
          ENDLOOP.
        ENDIF.
        lv_index  = lv_count.
        CONDENSE lv_index NO-GAPS.
        gs_sn-count  = lv_total.
        CONDENSE gs_sn-count NO-GAPS.
        CONCATENATE lv_index '/' gs_sn-count INTO gs_sn-count.

        IF lv_count = lv_total.
          LOOP AT SCREEN.
            IF screen-name = 'GV_SENUM'.
              screen-input  = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " TAP_DISPLAY  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         ls_mara    LIKE LINE OF gt_mara,
         lv_posnr   TYPE lips-posnr,
         lv_maktx   TYPE makt-maktx,
         lv_meins   TYPE mara-meins.

  DATA : lt_zaccdtd TYPE STANDARD TABLE OF zaccdtd,
         ls_zaccdtd LIKE LINE OF lt_zaccdtd.

  CASE ok_code.
    WHEN 'TEST'.
      SUBMIT zqr_test AND RETURN.

    WHEN 'GISN'.
      SUBMIT zaccmm_e001 AND RETURN.

    WHEN 'SNCO'.
      SUBMIT zaccmm_e004 AND RETURN.

    WHEN 'SINQ'.
      SUBMIT zmmpid_dcc_branch_sn AND RETURN.

    WHEN 'GRSN'.
      CALL SCREEN 201.

    WHEN 'GRTO'.
      CALL SCREEN 211.

    WHEN 'GRMD'.
      CALL SCREEN 221.

    WHEN 'GRDN'.
      CALL SCREEN 231.

    WHEN 'GRPO'.
      CALL SCREEN 241.

    WHEN 'CLR'.
      CASE sy-dynnr.
        WHEN '0242'.
          CLEAR : gs_input-gtin, gt_sn[], gs_sn.
      ENDCASE.

    WHEN 'CMPL'.
      CASE sy-dynnr.
        WHEN '0211'.
          IF gs_input-tanum IS NOT INITIAL.
            PERFORM f_get_data USING 'TP' gs_input-tanum.
            IF gv_subrc IS INITIAL.
              CALL SCREEN 212.
            ELSE.
              CALL SCREEN 2999.
            ENDIF.
          ENDIF.

        WHEN '0221'.
          IF gs_input-mblnr IS NOT INITIAL.
            PERFORM f_get_data USING 'DO' gs_input-mblnr.
            IF gv_subrc IS INITIAL.
              CALL SCREEN 222.
            ELSE.
              CALL SCREEN 2999.
            ENDIF.
          ENDIF.

        WHEN '0231'.
          IF gs_input-vbeln IS NOT INITIAL.
            PERFORM f_get_data USING 'INB' gs_input-vbeln.
            IF gv_subrc IS INITIAL.
              CALL SCREEN 232.
            ELSE.
              CALL SCREEN 2999.
            ENDIF.
          ENDIF.

        WHEN '0241'.
          IF gs_input-ebeln IS NOT INITIAL.
            PERFORM f_get_data USING 'PO' gs_input-ebeln.
            IF gv_subrc IS INITIAL.
              CALL SCREEN 242.
            ELSE.
              CALL SCREEN 2999.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN 'PGUP'.
      gv_index  = gv_index - 1.
      IF gv_index < 0.
        gv_index  = 0.
      ENDIF.

    WHEN 'PGDN'.
      gv_index  = gv_index + 1.
      IF gv_index > gv_lines.
        gv_index  = gv_lines.
      ENDIF.

    WHEN 'BACK'.
      CASE sy-dynnr.
        WHEN '0242'.
          CLEAR : gs_sn.
      ENDCASE.
      PERFORM f_unlock.
      CLEAR : gs_input.
      LEAVE TO SCREEN 0.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'NEXT'.
      CASE sy-dynnr.
        WHEN '0212'.
          IF gv_senum IS NOT INITIAL.
            PERFORM f_isi_serial_number USING '' '' ''.
            CLEAR gv_senum.
          ENDIF.
        WHEN '0232'.
          IF gv_senum IS NOT INITIAL.
            PERFORM f_isi_serial_number USING '' '' ''.
            CLEAR gv_senum.
          ENDIF.
        WHEN '0242'.
          IF gs_input-gtin IS NOT INITIAL.
            IF gv_senum IS INITIAL.
              SELECT *
                FROM zaccdtd
                INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
                WHERE docat = 'INB'
                  AND docno = gs_input-gtin.

              LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE vbeln = gs_input-gtin.
                CLEAR : ls_mara, lv_maktx, ls_zaccdtd.
                READ TABLE lt_zaccdtd INTO ls_zaccdtd
                                      WITH KEY docno = ls_zaccdtm-vbeln
                                               senum = ls_zaccdtm-senum.
                IF sy-subrc = 0.
                  CONTINUE.
                ENDIF.
                READ TABLE gt_mara INTO ls_mara
                                   WITH KEY matnr = ls_zaccdtm-matnr.
                IF sy-subrc = 0.
                  lv_maktx  = ls_mara-maktx.
                  lv_meins  = ls_mara-meins.
                ENDIF.
                ADD 1 TO lv_posnr.
                ls_sn-vbeln  = gs_input-gtin.
                ls_sn-posnr  = lv_posnr.
                ls_sn-matnr  = ls_zaccdtm-matnr.
                ls_sn-charg  = ls_zaccdtm-charg.
                ls_sn-werks  = ls_zaccdtm-werks.
                ls_sn-savwe  = ls_zaccdtm-werks.
                ls_sn-lgort  = ls_zaccdtm-lgort.
                ls_sn-maktx  = lv_maktx.
                ls_sn-meins  = lv_meins.
                APPEND ls_sn TO gt_sn.
              ENDLOOP.
              IF sy-subrc <> 0.
                gv_subrc  = 11.
                CALL SCREEN 2999.
              ENDIF.
            ELSE.
              PERFORM f_isi_serial_number USING '' '' ''.
              CLEAR gv_senum.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN 'COPY'.
      CASE sy-dynnr.
        WHEN '0232'.
          PERFORM f_copy_senum.
        WHEN '0242'.
          IF gs_input-gtin IS NOT INITIAL.
            PERFORM f_copy_senum.
          ENDIF.
      ENDCASE.

    WHEN 'SAVE'.
      PERFORM f_save_data.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  CASE sy-dynnr.
    WHEN '0211'.

    WHEN '0212'.
      IF gv_index IS INITIAL.
        gv_index  = 1.
      ENDIF.
      READ TABLE gt_sn INTO gs_sn INDEX gv_index.

    WHEN '0242'.
      IF gs_input-gtin IS NOT INITIAL.
        LOOP AT SCREEN.
          IF screen-name = 'GS_INPUT-GTIN'.
            screen-input  = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'GV_SENUM'.
            screen-input  = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREENMSG  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_screenmsg OUTPUT.
  SET PF-STATUS 'MOBILEMSG'.
ENDMODULE.                 " STATUS_SCREENMSG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
MODULE message OUTPUT.
  CLEAR : message1, message2, message3, message4, message5, message6,
          message7.

  CASE gv_subrc.
    WHEN 0.
      message1 = 'Data already'.
      message2 = 'saved'.
    WHEN 1.
      message1 = 'Document not found'.
    WHEN 2.
      message1 = 'Material'.
      message2 = 'with serial number'.
      message3 = 'not found'.
    WHEN 3.
      message1 = 'Serial Number'.
      message2 = 'already entered'.
    WHEN 4.
      message1 = 'Serial Number'.
      message2 = 'does not exist'.
    WHEN 5.
      message1 = 'Please,'.
      message2 = 'scan all material'.
    WHEN 6.
      message1 = 'Wrong'.
      message2 = 'Material/Batch'.
    WHEN 7.
      message1 = 'Document'.
      message2 = 'already saved'.
    WHEN 8.
      message1 = 'Total SN'.
      message2 = 'is exceeded'.
    WHEN 9.
      message1 = 'Transaction'.
      message2 = 'locked by'.
      message3 = gv_guname.
    WHEN 10.
      message1 = 'Batch is empty'.
    WHEN 11.
      message1 = 'Wrong DN#'.
  ENDCASE.
ENDMODULE.                 " MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data USING fu_docat fu_docno.
  DATA : lt_makt    TYPE STANDARD TABLE OF makt,
         lt_zaccdtd TYPE STANDARD TABLE OF zaccdtd,
         lt_zaccdtm TYPE STANDARD TABLE OF zaccdtm,
         ls_ltak    TYPE ltak,
         ls_likp    TYPE likp,
         lt_ltap    TYPE STANDARD TABLE OF ltap,
         ls_ltap    LIKE LINE OF lt_ltap,
         lt_lips    TYPE STANDARD TABLE OF lips,
         ls_lips    LIKE LINE OF lt_lips,
         ls_002     LIKE LINE OF gt_002,
         ls_makt    LIKE LINE OF lt_makt,
         ls_zaccdtd LIKE LINE OF lt_zaccdtd,
         ls_sn      LIKE LINE OF gt_sn.

  DATA : lt_ekko     TYPE STANDARD TABLE OF ekko.

  DATA : lv_maktx   TYPE makt-maktx.

  CLEAR : gv_subrc, gt_sn[], gt_sn.

  CASE sy-dynnr.
    WHEN '0211'.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
        WHERE docat = fu_docat
          AND docno = fu_docno.

      IF lt_zaccdtd[] IS INITIAL.
        SELECT SINGLE lgnum
          FROM lrf_wkqu
          INTO gv_lgnum
          WHERE bname = sy-uname
            AND statu = 'X'.

        SELECT SINGLE *
          FROM ltak
          INTO CORRESPONDING FIELDS OF ls_ltak
          WHERE lgnum = gv_lgnum
            AND tanum = gs_input-tanum.
        IF sy-subrc = 0.
          gv_mblnr  = ls_ltak-mblnr.
          SELECT *
            FROM ltap
            INTO CORRESPONDING FIELDS OF TABLE lt_ltap
            WHERE lgnum = ls_ltak-lgnum
              AND tanum = ls_ltak-tanum.
          IF sy-subrc = 0.
            PERFORM f_lock_object USING 'LTAK'.
            IF gv_subrc IS INITIAL.
              SELECT *
                FROM ztspmmdt002
                INTO CORRESPONDING FIELDS OF TABLE gt_002
                FOR ALL ENTRIES IN lt_ltap
                WHERE matnr = lt_ltap-matnr
                  AND trandtrc = 'X'.

              SELECT *
                FROM makt
                INTO CORRESPONDING FIELDS OF TABLE lt_makt
                FOR ALL ENTRIES IN lt_ltap
                WHERE matnr = lt_ltap-matnr
                  AND spras = sy-langu.
            ENDIF.
          ENDIF.
        ELSE.
          gv_subrc  = 1.
        ENDIF.
      ELSE.
        gv_subrc  = 7.
      ENDIF.

    WHEN '0231'.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
        WHERE docat = fu_docat
          AND docno = fu_docno.
      IF lt_zaccdtd[] IS INITIAL.
        SELECT SINGLE *
          FROM likp
          INTO CORRESPONDING FIELDS OF ls_likp
          WHERE vbeln = gs_input-vbeln.
        IF sy-subrc = 0.
          SELECT *
            FROM lips
            INTO CORRESPONDING FIELDS OF TABLE lt_lips
            WHERE vbeln = ls_likp-vbeln.
          IF sy-subrc = 0.
            PERFORM f_lock_object USING 'LIKP'.
            IF gv_subrc IS INITIAL.
              SELECT *
                FROM ztspmmdt002
                INTO CORRESPONDING FIELDS OF TABLE gt_002
                FOR ALL ENTRIES IN lt_lips
                WHERE matnr = lt_lips-matnr
                  AND trandtrc = 'X'.

              SELECT *
                FROM makt
                INTO CORRESPONDING FIELDS OF TABLE lt_makt
                FOR ALL ENTRIES IN lt_lips
                WHERE matnr = lt_lips-matnr
                  AND spras = sy-langu.
            ENDIF.
          ENDIF.
        ELSE.
          gv_subrc  = 1.
        ENDIF.
      ELSE.
        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE lt_lips
          WHERE vbeln = fu_docno.

        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtm
          FOR ALL ENTRIES IN lt_zaccdtd
          WHERE senum = lt_zaccdtd-senum.
        IF sy-subrc = 0.
          LOOP AT lt_lips INTO ls_lips.
            CLEAR ls_zaccdtm.
            READ TABLE lt_zaccdtm INTO ls_zaccdtm
                               WITH KEY matnr = ls_lips-matnr
                                        charg = ls_lips-charg.
            IF sy-subrc = 0.
              DELETE TABLE lt_lips FROM ls_lips.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF lt_lips[] IS INITIAL.
          gv_subrc  = 2.
        ELSE.
          PERFORM f_lock_object USING 'LIKP'.
          IF gv_subrc IS INITIAL.
            SELECT *
              FROM ztspmmdt002
              INTO CORRESPONDING FIELDS OF TABLE gt_002
              FOR ALL ENTRIES IN lt_lips
              WHERE matnr = lt_lips-matnr
                AND trandtrc = 'X'.

            SELECT *
              FROM makt
              INTO CORRESPONDING FIELDS OF TABLE lt_makt
              FOR ALL ENTRIES IN lt_lips
              WHERE matnr = lt_lips-matnr
                AND spras = sy-langu.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '0241'.
      SELECT SINGLE lifnr
        FROM ekko
        INTO gs_input-lifnr
        WHERE ebeln = fu_docno.
      IF sy-subrc = 0.
        PERFORM f_lock_object USING 'EKKO'.
        SELECT SINGLE name1
          FROM lfa1
          INTO gs_input-name1
          WHERE lifnr = gs_input-lifnr.

        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          WHERE aufnr = fu_docno.

        IF gt_zaccdtm[] IS NOT INITIAL.
          SELECT mara~matnr mara~meins makt~maktx
            FROM mara JOIN makt ON mara~matnr = makt~matnr
            INTO CORRESPONDING FIELDS OF TABLE gt_mara
            FOR ALL ENTRIES IN gt_zaccdtm
            WHERE mara~matnr = gt_zaccdtm-matnr
              AND makt~spras = sy-langu.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF gv_subrc IS INITIAL.
    CASE sy-dynnr.
      WHEN '0211'.
        IF gt_002[] IS INITIAL.
          gv_subrc  = 2.
        ELSE.
          IF lt_ltap[] IS NOT INITIAL.
            LOOP AT lt_ltap INTO ls_ltap.
              CLEAR ls_002.
              READ TABLE gt_002 INTO ls_002
                                WITH KEY matnr = ls_ltap-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              CLEAR ls_zaccdtd.
              READ TABLE lt_zaccdtd INTO ls_zaccdtd
                                    WITH KEY docno = ls_ltap-tanum
                                             posnr = ls_ltap-tapos.
              IF sy-subrc = 0.
                CONTINUE.
              ENDIF.
              CLEAR : ls_makt, lv_maktx.
              READ TABLE lt_makt INTO ls_makt
                                 WITH KEY matnr = ls_ltap-matnr.
              IF sy-subrc = 0.
                lv_maktx  = ls_makt-maktx.
              ENDIF.
              DO ls_ltap-nsola TIMES.
                ls_sn-tanum  = ls_ltap-tanum.
                ls_sn-posnr  = ls_ltap-tapos.
                ls_sn-matnr  = ls_ltap-matnr.
                ls_sn-charg  = ls_ltap-charg.
                ls_sn-werks  = ls_ltap-werks.
                ls_sn-savwe  = ls_ltap-werks.
                ls_sn-lgort  = ls_ltap-lgort.
                ls_sn-maktx  = lv_maktx.
                ls_sn-meins  = ls_ltap-meins.
                APPEND ls_sn TO gt_sn.
              ENDDO.
              CLEAR ls_sn.
            ENDLOOP.
          ENDIF.

          CLEAR : gr_snsta[].
          PERFORM f_status_senum USING : 'ESTO'.
        ENDIF.

      WHEN '0231'.
        IF gt_002[] IS INITIAL.
          gv_subrc  = 2.
        ELSE.
          IF lt_lips[] IS NOT INITIAL.
            LOOP AT lt_lips INTO ls_lips WHERE lfimg NE 0.
              CLEAR ls_002.
              READ TABLE gt_002 INTO ls_002
                                WITH KEY matnr = ls_lips-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.
              IF ls_lips-charg IS INITIAL.
                gv_subrc = 10.
                EXIT.
              ELSE.
                CLEAR ls_zaccdtd.
                READ TABLE lt_zaccdtd INTO ls_zaccdtd
                                      WITH KEY docno = ls_lips-vbeln
                                               posnr = ls_lips-posnr.
                IF sy-subrc = 0.
                  CONTINUE.
                ENDIF.
                CLEAR : ls_makt, lv_maktx.
                READ TABLE lt_makt INTO ls_makt
                                   WITH KEY matnr = ls_lips-matnr.
                IF sy-subrc = 0.
                  lv_maktx  = ls_makt-maktx.
                ENDIF.
                DO ls_lips-lfimg TIMES.
                  ls_sn-vbeln  = ls_lips-vbeln.
                  ls_sn-posnr  = ls_lips-posnr.
                  ls_sn-matnr  = ls_lips-matnr.
                  ls_sn-charg  = ls_lips-charg.
                  ls_sn-werks  = ls_likp-werks.

                  IF ls_likp-lfart(2) = 'ZR'.
                    ls_sn-savwe  = ls_likp-werks.
                  ELSE.
                    ls_sn-savwe  = ls_lips-werks.
*                    ls_sn-werks  = ls_lips-werks.
                  ENDIF.
                  ls_sn-lgort  = ls_lips-lgort.
                  ls_sn-maktx  = lv_maktx.
                  ls_sn-meins  = ls_lips-meins.
                  APPEND ls_sn TO gt_sn.
                ENDDO.
                CLEAR ls_sn.
              ENDIF.
            ENDLOOP.

            CLEAR : gr_snsta[].
            PERFORM f_status_senum USING : 'ESTO', 'ECUS'.
          ENDIF.
        ENDIF.

      WHEN '0241'.
    ENDCASE.
  ENDIF.

  IF gv_subrc IS INITIAL.
    CASE sy-dynnr.
      WHEN '0211' OR '0231'.
        IF gt_sn[] IS NOT INITIAL.
          IF ls_likp-vbtyp = 'J'.
            SELECT *
              FROM zaccdtd
              INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
              WHERE docat = 'DO'
                AND docno = ls_likp-vbeln
                AND xloek = space.
            IF lt_zaccdtd[] IS NOT INITIAL.
              SELECT *
                  FROM zaccdtm
                  INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
                  FOR ALL ENTRIES IN lt_zaccdtd
                  WHERE senum = lt_zaccdtd-senum.
            ENDIF.
          ELSE.
            lt_sn[]  = gt_sn[].
            SORT lt_sn BY werks matnr charg lgort.
            DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING werks matnr charg lgort.
            IF lt_sn[] IS NOT INITIAL.
              SELECT *
                FROM zaccdtm
                INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
                FOR ALL ENTRIES IN lt_sn
                WHERE matnr = lt_sn-matnr
                  AND charg = lt_sn-charg
                  AND werks = lt_sn-savwe
                  AND snsta IN gr_snsta.
              IF sy-subrc <> 0.
                SELECT *
                  FROM zaccdtm
                  INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
                  FOR ALL ENTRIES IN lt_sn
                  WHERE matnr = lt_sn-matnr
                    AND werks = lt_sn-savwe
                    AND snsta IN gr_snsta.
                IF sy-subrc <> 0.
                  SELECT *
                    FROM zaccdtm
                    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
                    FOR ALL ENTRIES IN lt_sn
                    WHERE matnr = lt_sn-matnr
                      AND charg = lt_sn-charg
                      AND snsta IN gr_snsta.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          gv_subrc = 7.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF gt_zaccdtm[] IS NOT INITIAL.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
        FOR ALL ENTRIES IN gt_zaccdtm
        WHERE matnr = gt_zaccdtm-matnr
          AND charg = gt_zaccdtm-charg
          AND senum = gt_zaccdtm-senum.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_OBJECT
*&---------------------------------------------------------------------*
FORM f_lock_object  USING    fu_tname.
  DATA : lt_enq   TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF lt_enq,
         lv_value TYPE eqegraarg.

  CASE fu_tname.
    WHEN 'LTAK'.
      CONCATENATE sy-mandt gv_lgnum gs_input-tanum INTO lv_value.
    WHEN 'LIKP'.
      CONCATENATE sy-mandt gs_input-vbeln INTO lv_value.
    WHEN 'EKKO'.
      CONCATENATE sy-mandt gs_input-ebeln INTO lv_value.
  ENDCASE.

  CALL FUNCTION 'ENQUEUE_REPORT'
    EXPORTING
      guname = space
    TABLES
      enq    = lt_enq.

  READ TABLE lt_enq INTO ls_enq
             WITH KEY gname = fu_tname
                      garg  = lv_value.
  IF sy-subrc = 0.
    gv_guname = ls_enq-guname.
    gv_subrc  = 9.
  ELSE.
    CASE fu_tname.
      WHEN 'LTAK'.
        CALL FUNCTION 'ENQUEUE_ELLTAKE'
          EXPORTING
            lgnum          = gv_lgnum
            tanum          = gs_input-tanum
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'LIKP'.
        CALL FUNCTION 'ENQUEUE_EVVBLKE'
          EXPORTING
            vbeln          = gs_input-vbeln
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'EKKO'.
        CALL FUNCTION 'ENQUEUE_EMEKKOE'
          EXPORTING
            ebeln          = gs_input-ebeln
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_LOCK_OBJECT

*&---------------------------------------------------------------------*
*&      Form  F_ISI_SERIAL_NUMBER
*&---------------------------------------------------------------------*
FORM f_isi_serial_number USING fu_senum fu_matnr fu_charg.
  DATA : ls_zaccdtm   LIKE LINE OF gt_zaccdtm,
         lv_senum(20),
         lv_charg(10),
         lv_matnr     TYPE mara-matnr,
         lt_valsn     TYPE STANDARD TABLE OF ty_valsn,
         ls_valsn     LIKE LINE OF lt_valsn.

  IF fu_senum IS INITIAL.
    CALL METHOD zcl_util=>m_acc_split_sn
      EXPORTING
        pvi_senum = gv_senum
      IMPORTING
        pvo_senum = lv_senum
        pvo_matnr = lv_matnr
        pvo_charg = lv_charg.
  ELSE.
    lv_senum = fu_senum.
    lv_matnr = fu_matnr.
    lv_charg = fu_charg.
  ENDIF.

  CLEAR gv_subrc.

  PERFORM f_aggregasi TABLES lt_valsn
                      USING  lv_matnr lv_charg lv_senum.

  IF gv_subrc IS INITIAL.
* Validasi Material & Batch terhadap screen
    PERFORM f_validasi_1 USING lv_matnr lv_charg.
  ENDIF.

  IF gv_subrc IS INITIAL.
* Validasi sudah pernah discan atau belum
    PERFORM f_validasi_2 TABLES lt_valsn.
  ENDIF.

  IF gv_subrc IS INITIAL.
* Validasi ke Master Serial Number
    PERFORM f_validasi_3 TABLES lt_valsn
                         USING gs_sn-matnr lv_charg.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF gs_sn-charg IS INITIAL.
      LOOP AT lt_valsn INTO ls_valsn.
        READ TABLE gt_sn INTO ls_sn
                         WITH KEY matnr = gs_sn-matnr
                                  senum = space
                         TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          gs_sn-senum  = ls_valsn-senum.
          gs_sn-charg  = lv_charg.
          gs_sn-check  = 'X'.
          gs_sn-aggr1  = ls_valsn-aggr1.
          gs_sn-zact1  = ls_valsn-zact1.
          gs_sn-aggr2  = ls_valsn-aggr2.
          gs_sn-zact2  = ls_valsn-zact2.
          MODIFY gt_sn FROM gs_sn INDEX sy-tabix
                       TRANSPORTING check senum charg
                                    aggr1 zact1
                                    aggr2 zact2.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT lt_valsn INTO ls_valsn.
        READ TABLE gt_sn INTO ls_sn
                         WITH KEY matnr = gs_sn-matnr
                                  charg = gs_sn-charg
                                  senum = space
                         TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          gs_sn-senum  = ls_valsn-senum.
          gs_sn-check  = 'X'.
          gs_sn-aggr1  = ls_valsn-aggr1.
          gs_sn-zact1  = ls_valsn-zact1.
          gs_sn-aggr2  = ls_valsn-aggr2.
          gs_sn-zact2  = ls_valsn-zact2.
          MODIFY gt_sn FROM gs_sn INDEX sy-tabix
                       TRANSPORTING check senum
                                    aggr1 zact1
                                    aggr2 zact2.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    CALL SCREEN 2999.
  ENDIF.
ENDFORM.                    " F_ISI_SERIAL_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : lt_sn      TYPE STANDARD TABLE OF ty_sn,
         ls_sn      LIKE LINE OF lt_sn,
         ls_xsn     LIKE LINE OF gt_sn,
         lt_accdtd  TYPE STANDARD TABLE OF zaccdtd,
         ls_accdtd  LIKE LINE OF lt_accdtd,
         lt_accdtm  TYPE STANDARD TABLE OF zaccdtm,
         ls_accdtm  LIKE LINE OF lt_accdtm,
         lt_accdta  TYPE STANDARD TABLE OF zaccdta,
         ls_accdta  LIKE LINE OF lt_accdta,
         lt_temp    TYPE STANDARD TABLE OF zaccdta,
         ls_temp    LIKE LINE OF lt_temp,
         ls_zaccdta LIKE LINE OF gt_zaccdta,
         lt_s501    TYPE STANDARD TABLE OF s501,
         ls_s501    LIKE LINE OF lt_s501.

  DATA : lt_xaccdta TYPE STANDARD TABLE OF zaccdta,
         ls_xaccdta LIKE LINE OF lt_xaccdta.

  DATA : lv_chk1  TYPE i,
         lv_chk2  TYPE i,
         lv_posnr TYPE s501-posnr.

  lt_sn[] = gt_sn[].
  SORT lt_sn BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING matnr charg.

  LOOP AT lt_sn INTO ls_sn.
    CLEAR : ls_xsn, lv_chk1, lv_chk2.
    ADD 1 TO lv_posnr.
    LOOP AT gt_sn INTO ls_xsn WHERE matnr = ls_sn-matnr
                                AND charg = ls_sn-charg.
      ADD 1 TO lv_chk1.

      IF ls_xsn-check IS NOT INITIAL.
        ADD 1 TO lv_chk2.

        IF ls_xsn-tanum IS NOT INITIAL.
          ls_accdtd-docat   = 'TP'.
          ls_accdtd-docno   = ls_xsn-tanum.
        ELSEIF ls_xsn-vbeln IS NOT INITIAL.
          ls_accdtd-docat   = 'INB'.
          ls_accdtd-docno   = ls_xsn-vbeln.
        ENDIF.
        ls_accdtd-posnr   = ls_xsn-posnr.
        IF sy-dynnr = '0242'.
          ls_accdtd-posnr     = lv_posnr.
        ENDIF.
        ls_accdtd-senum   = ls_xsn-senum.
        ls_accdtd-scandt  = sy-datum.
        ls_accdtd-ernam   = sy-uname.
        ls_accdtd-time    = sy-uzeit.
        APPEND ls_accdtd TO lt_accdtd.

        ls_accdta-matnr   = ls_xsn-matnr.
        ls_accdta-charg   = ls_xsn-charg.
        ls_accdta-senum   = ls_xsn-senum.
        ls_accdta-aggr1   = ls_xsn-aggr1.
        ls_accdta-zact1   = ls_xsn-zact1.
        ls_accdta-aggr2   = ls_xsn-aggr2.
        ls_accdta-zact2   = ls_xsn-zact2.
        APPEND ls_accdta TO lt_accdta.

        ls_accdtm-matnr   = ls_xsn-matnr.
        ls_accdtm-charg   = ls_xsn-charg.
        ls_accdtm-senum   = ls_xsn-senum.
        ls_accdtm-werks   = ls_xsn-savwe.
        ls_accdtm-lgort   = ls_xsn-lgort.
        ls_accdtm-erdat   = sy-datum.
        ls_accdtm-ernam   = sy-uname.
        ls_accdtm-snsta   = 'EDEL'.
        APPEND ls_accdtm TO lt_accdtm.

        ls_s501-sptag     = sy-datum.
        ls_s501-docat     = ls_accdtd-docat.
        ls_s501-docno     = ls_accdtd-docno.
        ls_s501-posnr     = ls_accdtd-posnr.
        IF sy-dynnr = '0242'.
          ls_s501-posnr     = lv_posnr.
        ENDIF.
        ls_s501-vrsio     = '000'.
        ls_s501-spmon     = sy-datum(6).
        ls_s501-spwoc     = '000000'.
        ls_s501-spbup     = '000000'.
        ls_s501-ssour     = space.
        ls_s501-periv     = space.
        ls_s501-vwdat     = space.
        ls_s501-basme     = ls_xsn-meins.

        IF sy-dynnr = '0232'.
          IF ls_xsn-werks NE space.
            ls_s501-werks     = ls_xsn-werks.
          ELSE.
            ls_s501-werks     = ls_xsn-savwe.
          ENDIF.
        ELSE.
          ls_s501-werks     = ls_xsn-savwe.
        ENDIF.

        ls_s501-lgort     = ls_xsn-lgort.
        ls_s501-charg     = ls_xsn-charg.
        ls_s501-matnr     = ls_xsn-matnr.
        ls_s501-menge     = 1.
        ls_s501-meins     = ls_xsn-meins.
        COLLECT ls_s501 INTO lt_s501.

        CLEAR : ls_s501, ls_accdtd, ls_accdta, ls_accdtm.
      ENDIF.
    ENDLOOP.

    IF lv_chk1 = lv_chk2.
      CASE sy-dynnr.
        WHEN '0242'.
        WHEN '0232'.

        WHEN OTHERS.
          CLEAR ls_accdtm.

          CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
            EXPORTING
              tabname    = 'ZACCDTM'
            TABLES
              it_zaccdtm = lt_accdtm.

*          LOOP AT lt_accdtm INTO ls_accdtm.
*            TRY .
*                UPDATE zaccdtm SET werks = ls_accdtm-werks
*                                   lgort = ls_accdtm-lgort
*                                   erdat = ls_accdtm-erdat
*                                   ernam = ls_accdtm-ernam
*                                   snsta = ls_accdtm-snsta
*                               WHERE matnr = ls_accdtm-matnr
*                                 AND charg = ls_accdtm-charg
*                                 AND senum = ls_accdtm-senum.
*              CATCH cx_sy_conversion_no_number.
*            ENDTRY.
*          ENDLOOP.
      ENDCASE.

      IF lt_s501[] IS NOT INITIAL.
        CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
          EXPORTING
            tabname = 'S501'
          TABLES
            it_s501 = lt_s501.

*        CLEAR ls_s501.
*        LOOP AT lt_s501 INTO ls_s501.
*          TRY.
*              MODIFY s501 FROM ls_s501.
*            CATCH cx_root.
*          ENDTRY.
*        ENDLOOP.
      ENDIF.

      CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
        EXPORTING
          tabname    = 'ZACCDTD'
        TABLES
          it_zaccdtd = lt_accdtd.

*      LOOP AT lt_accdtd INTO ls_accdtd.
*        TRY.
*            MODIFY zaccdtd FROM ls_accdtd.
*          CATCH cx_root.
*        ENDTRY.
*      ENDLOOP.

      lt_temp[] = lt_accdta[].
      CLEAR : lt_accdta[], lt_accdta.
      LOOP AT lt_temp INTO ls_temp.
        IF ls_temp-aggr2 IS NOT INITIAL.
          LOOP AT gt_zaccdta INTO ls_zaccdta WHERE matnr = ls_temp-matnr
                                               AND charg = ls_temp-charg
                                               AND aggr2 = ls_temp-aggr2.
            ls_accdta-matnr     = ls_zaccdta-matnr.
            ls_accdta-charg     = ls_zaccdta-charg.
            ls_accdta-senum     = ls_zaccdta-senum.
            IF ls_zaccdta-aggr1 = ls_temp-aggr1.
              ls_accdta-aggr1     = ls_temp-aggr1.
              ls_accdta-zact1     = ls_temp-zact1.
              ls_accdta-packdat1  = ls_zaccdta-packdat1.
            ELSE.
              ls_accdta-aggr1     = ls_zaccdta-aggr1.
              ls_accdta-zact1     = ls_zaccdta-zact1.
              ls_accdta-packdat1  = ls_zaccdta-packdat1.
            ENDIF.
            ls_accdta-aggr2     = ls_temp-aggr2.
            ls_accdta-zact2     = ls_temp-zact2.
            ls_accdta-packdat2  = ls_zaccdta-packdat2.
            APPEND ls_accdta TO lt_accdta.
            CLEAR ls_accdta.
          ENDLOOP.
        ELSEIF ls_temp-aggr1 IS NOT INITIAL.
          LOOP AT gt_zaccdta INTO ls_zaccdta WHERE matnr = ls_temp-matnr
                                               AND charg = ls_temp-charg
                                               AND aggr1 = ls_temp-aggr1.
            ls_accdta-matnr     = ls_zaccdta-matnr.
            ls_accdta-charg     = ls_zaccdta-charg.
            ls_accdta-senum     = ls_zaccdta-senum.
            ls_accdta-aggr1     = ls_temp-aggr1.
            ls_accdta-zact1     = ls_temp-zact1.
            ls_accdta-packdat1  = ls_zaccdta-packdat1.
            ls_accdta-aggr2     = ls_temp-aggr2.
            ls_accdta-zact2     = ls_temp-zact2.
            ls_accdta-packdat2  = ls_zaccdta-packdat2.
            APPEND ls_accdta TO lt_accdta.
            CLEAR ls_accdta.
          ENDLOOP.
        ELSE.
          APPEND ls_temp TO lt_accdta.
        ENDIF.
        CLEAR ls_temp.
      ENDLOOP.

      CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
        EXPORTING
          tabname    = 'ZACCDTA'
        TABLES
          it_zaccdta = lt_accdta.

*      CLEAR ls_accdta.
*      LOOP AT lt_accdta INTO ls_accdta.
*        IF ls_accdta-aggr1 IS INITIAL AND
*          ls_accdta-aggr2 IS INITIAL.
*          TRY .
*              UPDATE zaccdta SET zact1 = ls_accdta-zact1
*                                 zact2 = ls_accdta-zact2
*                             WHERE matnr = ls_accdta-matnr
*                               AND charg = ls_accdta-charg
*                               AND senum = ls_accdta-senum.
*            CATCH cx_sy_conversion_no_number.
*          ENDTRY.
*        ELSE.
*          TRY .
*              UPDATE zaccdta SET zact2 = ls_accdta-zact2
*                             WHERE matnr = ls_accdta-matnr
*                               AND charg = ls_accdta-charg
*                               AND aggr2 = ls_accdta-aggr2.
*            CATCH cx_sy_conversion_no_number.
*          ENDTRY.
*
*          TRY .
*              UPDATE zaccdta SET zact1 = ls_accdta-zact1
*                             WHERE matnr = ls_accdta-matnr
*                               AND charg = ls_accdta-charg
*                               AND aggr1 = ls_accdta-aggr1.
*            CATCH cx_sy_conversion_no_number.
*          ENDTRY.
*        ENDIF.
*      ENDLOOP.

      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

      DELETE gt_sn WHERE matnr = ls_xsn-matnr
                     AND charg = ls_xsn-charg.
    ELSE.
      IF lv_chk2 <> 0.
        gv_subrc = 5.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gv_subrc IS INITIAL.
    PERFORM f_unlock.
    CALL SCREEN 2999.
    LEAVE TO SCREEN 0.
  ELSE.
    CALL SCREEN 2999.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_AGGREGASI
*&---------------------------------------------------------------------*
FORM f_aggregasi  TABLES   ft_valsn LIKE gt_valsn
                  USING    fu_matnr fu_charg fu_senum.
  DATA : lt_zaccdta TYPE STANDARD TABLE OF zaccdta,
         ls_zaccdta LIKE LINE OF lt_zaccdta,
         ls_valsn   LIKE LINE OF gt_valsn,
         lv_aggr    TYPE i.

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

  IF lv_matnr IS NOT INITIAL.
    IF gs_sn-matnr <> lv_matnr.
      gv_subrc = 6.
    ENDIF.
  ENDIF.

  IF gs_sn-charg IS NOT INITIAL.
    IF gs_sn-charg <> fu_charg.
      gv_subrc = 6.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_1

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_2
*&---------------------------------------------------------------------*
FORM f_validasi_2  TABLES   ft_valsn LIKE gt_valsn.
  DATA : ls_valsn LIKE LINE OF gt_valsn,
         lv_lin1  TYPE i,
         lv_lin2  TYPE i.

  DESCRIBE TABLE ft_valsn LINES lv_lin1.
  LOOP AT gt_sn INTO ls_sn WHERE senum IS INITIAL.
    ADD 1 TO lv_lin2.
  ENDLOOP.
  IF lv_lin1 > lv_lin2.
    gv_subrc = 8.
    EXIT.
  ENDIF.

  LOOP AT ft_valsn INTO ls_valsn.
    READ TABLE gt_sn INTO ls_sn
                     WITH KEY senum = ls_valsn-senum.
    IF sy-subrc = 0.
      IF ls_sn-check IS NOT INITIAL.
        gv_subrc  = 3.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_2

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_3
*&---------------------------------------------------------------------*
FORM f_validasi_3  TABLES   ft_valsn LIKE gt_valsn
                   USING    fu_matnr fu_charg.
  DATA : ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         ls_valsn   LIKE LINE OF gt_valsn.

  LOOP AT ft_valsn INTO ls_valsn.
    READ TABLE gt_zaccdtm INTO ls_zaccdtm
                         WITH KEY matnr = fu_matnr
                                  charg = fu_charg
                                  senum = ls_valsn-senum.
    IF sy-subrc <> 0.
      gv_subrc  = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_3

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK
*&---------------------------------------------------------------------*
FORM f_unlock .
  CASE sy-dynnr.
    WHEN '0212'.
      CALL FUNCTION 'DEQUEUE_ELLTAKE'
        EXPORTING
          lgnum = gv_lgnum
          tanum = gs_input-tanum.
    WHEN '0232'.
      CALL FUNCTION 'DEQUEUE_EVVBLKE'
        EXPORTING
          vbeln = gs_input-vbeln.
    WHEN '0242'.
      CALL FUNCTION 'DEQUEUE_EMEKKOE'
        EXPORTING
          ebeln = gs_input-ebeln.
  ENDCASE.
ENDFORM.                    " F_UNLOCK

*&---------------------------------------------------------------------*
*&      Form  F_COPY_SENUM
*&---------------------------------------------------------------------*
FORM f_copy_senum .
  DATA : ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         ls_zaccdtd LIKE LINE OF gt_zaccdtd,
         ls_002     LIKE LINE OF gt_002.

  CASE sy-dynnr.
    WHEN '0232'.
      IF gt_zaccdtm[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtd
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtd
          FOR ALL ENTRIES IN gt_zaccdtm
          WHERE docat = 'DO'
            AND docno = gs_input-vbeln
            AND senum = gt_zaccdtm-senum.
      ENDIF.

      LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE matnr = gs_sn-matnr
                                           AND charg = gs_sn-charg.
        CLEAR : ls_zaccdtd.
        READ TABLE gt_zaccdtd INTO ls_zaccdtd
                              WITH KEY senum = ls_zaccdtm-senum.
        IF sy-subrc = 0.
          CLEAR ls_002.
          READ TABLE gt_002 INTO ls_002
                            WITH KEY matnr = gs_sn-matnr.
          CONCATENATE ls_002-nie ';10' ls_zaccdtm-charg INTO gv_senum.
          CONCATENATE gv_senum ';' '1700000021'ls_zaccdtm-senum INTO gv_senum.
          IF gv_senum IS NOT INITIAL.
            PERFORM f_isi_serial_number USING '' '' ''.
          ENDIF.
        ENDIF.
        CLEAR : ls_zaccdtm, gv_senum.
      ENDLOOP.

    WHEN '0242'.
      LOOP AT gt_sn INTO ls_sn WHERE matnr = gs_sn-matnr
                                 AND charg = gs_sn-charg
                                 AND vbeln = gs_input-gtin.
        CLEAR : ls_sn-check, ls_sn-senum.
        MODIFY gt_sn FROM ls_sn.
      ENDLOOP.

      LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE matnr = gs_sn-matnr
                                           AND charg = gs_sn-charg
                                           AND vbeln = gs_input-gtin.
        PERFORM f_isi_serial_number USING ls_zaccdtm-senum
                                          ls_zaccdtm-matnr
                                          ls_zaccdtm-charg.
        CLEAR : ls_zaccdtm.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_COPY_SENUM

*&---------------------------------------------------------------------*
*&      Form  F_STATUS_SENUM
*&---------------------------------------------------------------------*
FORM f_status_senum  USING    fu_snsta.
  DATA :  ls_snsta   LIKE LINE OF gr_snsta.

  ls_snsta-low    = fu_snsta.
  ls_snsta-sign   = 'I'.
  ls_snsta-option = 'EQ'.
  APPEND ls_snsta TO gr_snsta.
ENDFORM.                    " F_STATUS_SENUM
