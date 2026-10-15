*&---------------------------------------------------------------------*
*& Report  ZACCMM_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccmm_e001 NO STANDARD PAGE HEADING.

TYPES : BEGIN OF ty_sn,
          check(1),
          vbeln(10),
          rsnum(10),
          reqno(30),
          ebeln(10),
          tanum(10),
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
        END OF ty_sn.

TYPES : BEGIN OF ty_valsn,
          senum(20),
          aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
        END OF ty_valsn.

DATA : ok_code    TYPE sy-ucomm,
       gv_subrc   TYPE sy-subrc,
       gv_vbeln   TYPE lips-vbeln,
       gv_senum(100),
       gv_index   TYPE i,
       gv_lines   TYPE i,
       gv_guname  TYPE seqg3-guname,
       gv_rsnum   TYPE rkpf-rsnum,
       gv_reqno   TYPE zgdmmt0001-req_no,
       gv_ebeln   TYPE ekpo-ebeln,
       gv_docat   TYPE zaccdtd-docat,
       gv_tanum   TYPE ltak-tanum,
       gv_lgnum   TYPE ltak-lgnum.

DATA : gt_sn            TYPE STANDARD TABLE OF ty_sn,
       gs_sn            LIKE LINE OF gt_sn,
       gt_accdtm        TYPE STANDARD TABLE OF zaccdtm,
       gt_accdtd        TYPE STANDARD TABLE OF zaccdtd,
       gt_valsn         TYPE STANDARD TABLE OF ty_valsn,
       gt_zaccdta       TYPE STANDARD TABLE OF zaccdta.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

START-OF-SELECTION.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  sy-lsind = 0.

  SET PF-STATUS 'LMOB_GROUP3'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN 'GIDN'.
      CALL SCREEN 110.
    WHEN 'GIRV'.
      CALL SCREEN 120.
    WHEN 'GIUP'.
      CALL SCREEN 130.
    WHEN 'GIPO'.
      CALL SCREEN 140.
    WHEN 'GITO'.
      SELECT SINGLE lgnum
        FROM lrf_wkqu
        INTO gv_lgnum
        WHERE bname = sy-uname
          AND statu = 'X'.

      CALL SCREEN 150.

    WHEN 'CMPL'.
      PERFORM f_get_data.
      IF gv_subrc IS INITIAL.
        CASE sy-dynnr.
          WHEN '0110'.
            CALL SCREEN 111.
          WHEN '0120'.
            CALL SCREEN 121.
          WHEN '0130'.
            CALL SCREEN 131.
          WHEN '0140'.
            CALL SCREEN 141.
          WHEN '0150'.
            CALL SCREEN 151.
        ENDCASE.
      ELSE.
        CALL SCREEN 2999.
      ENDIF.

    WHEN 'CLR'.
      CASE sy-dynnr.
        WHEN '0110'.
          CLEAR gv_vbeln.
        WHEN '0111'.
          CLEAR gv_senum.
        WHEN '0120'.
          CLEAR gv_rsnum.
        WHEN '0121'.
          CLEAR gv_senum.
        WHEN '0130'.
          CLEAR gv_reqno.
        WHEN '0131'.
          CLEAR gv_senum.
        WHEN '0140'.
          CLEAR gv_ebeln.
        WHEN '0141'.
          CLEAR gv_senum.
        WHEN '0150'.
          CLEAR gv_tanum.
        WHEN '0151'.
          CLEAR gv_senum.
      ENDCASE.

    WHEN 'BACK' OR 'CANC'.
      PERFORM f_unlock.
      CLEAR : gv_vbeln, gv_rsnum, gv_senum, gv_subrc, gs_sn-check,
              gv_reqno, gv_ebeln, gv_tanum.
      LEAVE TO SCREEN 0.

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

    WHEN 'NEXT'.
      IF gv_senum IS NOT INITIAL.
        PERFORM f_isi_serial_number.
        CLEAR gv_senum.
      ENDIF.

    WHEN 'SAVE'.
      PERFORM f_save_data.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  TYPES : BEGIN OF ty_x001,
            reqno  TYPE zgdmmt0001-req_no,
            matnr  TYPE zgdmmt0001-matnr,
            charg  TYPE zgdmmt0001-charg,
            werks  TYPE zgdmmt0001-werks,
            lgort  TYPE zgdmmt0001-lgort,
            meins  TYPE zgdmmt0001-meins,
            menge  TYPE zgdmmt0001-menge,
          END OF ty_x001.

  DATA : lt_lips    TYPE STANDARD TABLE OF lips,
         lt_resb    TYPE STANDARD TABLE OF resb,
         lt_ltap    TYPE STANDARD TABLE OF ltap,
         lt_001     TYPE STANDARD TABLE OF zgdmmt0001,
         lt_002     TYPE STANDARD TABLE OF ztspmmdt002,
         lt_ekpo    TYPE STANDARD TABLE OF ekpo,
         lt_makt    TYPE STANDARD TABLE OF makt,
         lt_sn      TYPE STANDARD TABLE OF ty_sn,
         lt_accdtm  TYPE STANDARD TABLE OF zaccdtm,
         lt_x001    TYPE STANDARD TABLE OF ty_x001,
         lt_reqno   TYPE TABLE OF string,
         lt_s501    TYPE STANDARD TABLE OF s501.

  DATA : ls_lips    LIKE LINE OF lt_lips,
         ls_resb    LIKE LINE OF lt_resb,
         ls_ltap    LIKE LINE OF lt_ltap,
         ls_001     LIKE LINE OF lt_001,
         ls_ekpo    LIKE LINE OF lt_ekpo,
         ls_sn      LIKE LINE OF gt_sn,
         ls_makt    LIKE LINE OF lt_makt,
         ls_accdtd  LIKE LINE OF gt_accdtd,
         ls_002     LIKE LINE OF lt_002,
         ls_x001    LIKE LINE OF lt_x001,
         ls_accdtm  LIKE LINE OF lt_accdtm,
         ls_reqno   LIKE LINE OF lt_reqno,
         ls_s501    LIKE LINE OF lt_s501.

  DATA : lv_maktx   TYPE makt-maktx,
         lv_menge   TYPE mseg-menge,
         lv_zeile   TYPE zgdmmt0001-zeile,
         lv_up1(6),
         lv_up2(4),
         lv_reqno(12),
         lv_zeile_ctr TYPE mseg-menge.

  CLEAR : gv_subrc, gt_sn[], gt_sn.

  CASE sy-dynnr.
    WHEN '0110'.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_accdtd
        WHERE docat = 'DO'
          AND docno = gv_vbeln
          AND xloek = space.

      SELECT *
       FROM lips
       INTO CORRESPONDING FIELDS OF TABLE lt_lips
       WHERE vbeln = gv_vbeln
         AND lfimg GT 0.

      IF lt_lips[] IS INITIAL.
        gv_subrc  = 1.
      ELSE.
        PERFORM f_lock_object USING 'LIKP'.
        IF gv_subrc IS INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_002
            FOR ALL ENTRIES IN lt_lips
            WHERE matnr = lt_lips-matnr
              AND trandtrc = 'X'.
        ENDIF.
      ENDIF.

    WHEN '0120'.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_accdtd
        WHERE docat = 'RSV'
          AND docno = gv_rsnum
          AND xloek = space.

      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE lt_resb
        WHERE rsnum = gv_rsnum
          AND xloek = space
          AND xwaok = 'X'.

      IF lt_resb[] IS INITIAL.
        gv_subrc  = 1.
      ELSE.
        PERFORM f_lock_object USING 'RKPF'.
        IF gv_subrc IS INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_002
            FOR ALL ENTRIES IN lt_resb
            WHERE matnr = lt_resb-matnr
              AND trandtrc = 'X'.

          SELECT *
            FROM makt
            INTO CORRESPONDING FIELDS OF TABLE lt_makt
            FOR ALL ENTRIES IN lt_resb
            WHERE matnr = lt_resb-matnr
              AND spras = sy-langu.
        ENDIF.
      ENDIF.

    WHEN '0130'.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE lt_001
        WHERE req_no = gv_reqno
          AND bbk_no = space
          AND status = space.

      IF lt_001[] IS INITIAL.
        gv_subrc  = 1.
      ELSE.
        CLEAR ls_001.
        READ TABLE lt_001 INTO ls_001 INDEX 1.
        SPLIT ls_001-req_no AT '/' INTO TABLE lt_reqno.
        READ TABLE lt_reqno INTO lv_up1 INDEX 1.
        READ TABLE lt_reqno INTO lv_up2 INDEX 5.
        CONCATENATE lv_up1 '/' lv_up2
        INTO lv_reqno.

        SELECT *
          FROM zaccdtd
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtd
          WHERE docat = 'DO'
            AND docno = lv_reqno
            AND xloek = space.

        SELECT *
          FROM s501
          INTO CORRESPONDING FIELDS OF TABLE lt_s501
          WHERE docat = 'DO'
            AND docno = lv_reqno
            AND vrsio = '000'.
        SORT lt_s501 BY posnr DESCENDING.

        IF gt_accdtd[] IS NOT INITIAL.
          SELECT *
            FROM zaccdtm
            INTO CORRESPONDING FIELDS OF TABLE lt_accdtm
            FOR ALL ENTRIES IN gt_accdtd
            WHERE senum = gt_accdtd-senum.
        ENDIF.

        PERFORM f_lock_object USING 'ZGDMMT0001'.
        IF gv_subrc IS INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_002
            FOR ALL ENTRIES IN lt_001
            WHERE matnr = lt_001-matnr
              AND trandtrc = 'X'.

          SELECT *
            FROM makt
            INTO CORRESPONDING FIELDS OF TABLE lt_makt
            FOR ALL ENTRIES IN lt_001
            WHERE matnr = lt_001-matnr
              AND spras = sy-langu.
        ENDIF.
      ENDIF.

    WHEN '0140'.
      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_accdtd
        WHERE docat = 'DO'
          AND docno = gv_ebeln
          AND xloek = space.

      IF gt_accdtd[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE lt_accdtm
          FOR ALL ENTRIES IN gt_accdtd
          WHERE senum = gt_accdtd-senum.
      ENDIF.

      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
        WHERE ebeln = gv_ebeln.

      IF lt_001[] IS INITIAL.
        gv_subrc  = 1.
      ELSE.
        PERFORM f_lock_object USING 'EKKO'.
        IF gv_subrc IS INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_002
            FOR ALL ENTRIES IN lt_001
            WHERE matnr = lt_001-matnr
              AND trandtrc = 'X'.

          SELECT *
            FROM makt
            INTO CORRESPONDING FIELDS OF TABLE lt_makt
            FOR ALL ENTRIES IN lt_001
            WHERE matnr = lt_001-matnr
              AND spras = sy-langu.
        ENDIF.
      ENDIF.

    WHEN '0150'.
      CONCATENATE 'T' gv_lgnum INTO gv_docat.

      SELECT *
        FROM zaccdtd
        INTO CORRESPONDING FIELDS OF TABLE gt_accdtd
        WHERE docat = gv_docat
          AND docno = gv_tanum
          AND xloek = space.

      SELECT *
       FROM ltap
       INTO CORRESPONDING FIELDS OF TABLE lt_ltap
       WHERE lgnum = gv_lgnum
         AND tanum = gv_tanum.

      IF lt_ltap[] IS INITIAL.
        gv_subrc  = 1.
      ELSE.
        PERFORM f_lock_object USING 'LTAK'.
        IF gv_subrc IS INITIAL.
          SELECT *
            FROM ztspmmdt002
            INTO CORRESPONDING FIELDS OF TABLE lt_002
            FOR ALL ENTRIES IN lt_lips
            WHERE matnr = lt_lips-matnr
              AND trandtrc = 'X'.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF gv_subrc IS INITIAL.
    IF lt_002[] IS INITIAL.
      gv_subrc  = 2.
    ELSE.
      CASE sy-dynnr.
        WHEN '0110'.
          IF lt_lips[] IS NOT INITIAL.
            LOOP AT lt_lips INTO ls_lips.
              CLEAR ls_002.
              READ TABLE lt_002 INTO ls_002
                                WITH KEY matnr = ls_lips-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.
              IF ls_lips-charg IS INITIAL.
                gv_subrc = 10.
                EXIT.
              ELSE.
                CLEAR ls_accdtd.
                READ TABLE gt_accdtd INTO ls_accdtd
                                     WITH KEY docno = ls_lips-vbeln
                                              posnr = ls_lips-posnr.
                IF sy-subrc = 0.
                  CONTINUE.
                ENDIF.
                DO ls_lips-lfimg TIMES.
                  ls_sn-vbeln  = ls_lips-vbeln.
                  ls_sn-posnr  = ls_lips-posnr.
                  ls_sn-matnr  = ls_lips-matnr.
                  ls_sn-charg  = ls_lips-charg.
                  ls_sn-werks  = ls_lips-werks.
                  ls_sn-lgort  = ls_lips-lgort.
                  ls_sn-maktx  = ls_lips-arktx.
                  ls_sn-meins  = ls_lips-vrkme.
                  APPEND ls_sn TO gt_sn.
                ENDDO.
                CLEAR ls_sn.
              ENDIF.
            ENDLOOP.
          ENDIF.

        WHEN '0120'.
          IF lt_resb[] IS NOT INITIAL.
            LOOP AT lt_resb INTO ls_resb.
              CLEAR ls_002.
              READ TABLE lt_002 INTO ls_002
                                WITH KEY matnr = ls_resb-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              CLEAR ls_accdtd.
              READ TABLE gt_accdtd INTO ls_accdtd
                                   WITH KEY docno = ls_resb-rsnum
                                            posnr = ls_resb-rspos.
              IF sy-subrc = 0.
                CONTINUE.
              ENDIF.
              CLEAR : ls_makt, lv_maktx.
              READ TABLE lt_makt INTO ls_makt
                                 WITH KEY matnr = ls_resb-matnr.
              IF sy-subrc = 0.
                lv_maktx  = ls_makt-maktx.
              ENDIF.
              DO ls_resb-bdmng TIMES.
                ls_sn-rsnum  = ls_resb-rsnum.
                ls_sn-posnr  = ls_resb-rspos.
                ls_sn-matnr  = ls_resb-matnr.
                ls_sn-charg  = ls_resb-charg.
                ls_sn-werks  = ls_resb-werks.
                ls_sn-lgort  = ls_resb-lgort.
                ls_sn-maktx  = lv_maktx.
                ls_sn-meins  = ls_resb-meins.
                APPEND ls_sn TO gt_sn.
              ENDDO.
              CLEAR ls_sn.
            ENDLOOP.
          ENDIF.

        WHEN '0130'.
          SORT lt_001 BY req_no matnr charg werks lgort.
          LOOP AT lt_001 INTO ls_001.
            ls_x001-reqno = ls_001-req_no.
            ls_x001-matnr = ls_001-matnr.
            ls_x001-charg = ls_001-charg.
            ls_x001-werks = ls_001-werks.
            ls_x001-lgort = ls_001-lgort.
            ls_x001-meins = ls_001-meins.
            ls_x001-menge = ls_001-menge.
            COLLECT ls_x001 INTO lt_x001.
            CLEAR ls_x001.
          ENDLOOP.

          IF lt_x001[] IS NOT INITIAL.
            LOOP AT lt_x001 INTO ls_x001.
              CLEAR ls_002.
              READ TABLE lt_002 INTO ls_002
                                WITH KEY matnr = ls_x001-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              CLEAR : ls_accdtm, lv_menge.
              LOOP AT lt_accdtm INTO ls_accdtm WHERE matnr = ls_x001-matnr
                                                 AND charg = ls_x001-charg
                                                 AND lgort = ls_x001-lgort
                                                 AND werks = ls_x001-werks.
                ADD 1 TO lv_menge.
              ENDLOOP.

              READ TABLE lt_s501 INTO ls_s501 WITH KEY matnr = ls_x001-matnr
                                                       charg = ls_x001-charg
                                                       werks = ls_x001-werks
                                                       lgort = ls_x001-lgort.
              IF sy-subrc = 0.
                lv_zeile = ls_s501-posnr.
              ELSE.
                READ TABLE lt_s501 INTO ls_s501 INDEX 1.
                lv_zeile     = ls_s501-posnr + lv_zeile_ctr + 1.
                ADD 1 TO lv_zeile_ctr.
              ENDIF.

              lv_menge = ls_x001-menge - lv_menge.

              CLEAR : ls_makt, lv_maktx.
              READ TABLE lt_makt INTO ls_makt
                                 WITH KEY matnr = ls_x001-matnr.
              IF sy-subrc = 0.
                lv_maktx  = ls_makt-maktx.
              ENDIF.

              SPLIT ls_x001-reqno AT '/' INTO TABLE lt_reqno.
              READ TABLE lt_reqno INTO lv_up1 INDEX 1.
              READ TABLE lt_reqno INTO lv_up2 INDEX 5.
              CONCATENATE lv_up1 '/' lv_up2
              INTO ls_x001-reqno.

              DO lv_menge TIMES.
                ls_sn-reqno  = ls_x001-reqno.
                ls_sn-posnr  = lv_zeile.
                ls_sn-matnr  = ls_x001-matnr.
                ls_sn-charg  = ls_x001-charg.
                ls_sn-werks  = ls_x001-werks.
                ls_sn-lgort  = ls_x001-lgort.
                ls_sn-maktx  = lv_maktx.
                ls_sn-meins  = ls_x001-meins.
                APPEND ls_sn TO gt_sn.
              ENDDO.
              CLEAR ls_sn.
            ENDLOOP.
          ENDIF.

        WHEN '0140'.
          IF lt_ekpo[] IS NOT INITIAL.
            LOOP AT lt_ekpo INTO ls_ekpo.
              CLEAR ls_002.
              READ TABLE lt_002 INTO ls_002
                                WITH KEY matnr = ls_ekpo-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              CLEAR : ls_accdtm, lv_menge.
              LOOP AT lt_accdtm INTO ls_accdtm WHERE matnr = ls_ekpo-matnr
                                                 AND lgort = ls_ekpo-lgort
                                                 AND werks = ls_ekpo-werks.
                ADD 1 TO lv_menge.
              ENDLOOP.

              lv_menge = ls_ekpo-menge - lv_menge.

              CLEAR : ls_makt, lv_maktx.
              READ TABLE lt_makt INTO ls_makt
                                 WITH KEY matnr = ls_ekpo-matnr.
              IF sy-subrc = 0.
                lv_maktx  = ls_makt-maktx.
              ENDIF.

              DO lv_menge TIMES.
                ls_sn-ebeln  = ls_ekpo-ebeln.
                ls_sn-posnr  = ls_ekpo-ebelp.
                ls_sn-matnr  = ls_ekpo-matnr.
                ls_sn-werks  = ls_ekpo-werks.
                ls_sn-lgort  = ls_ekpo-lgort.
                ls_sn-maktx  = lv_maktx.
                ls_sn-meins  = ls_ekpo-meins.
                APPEND ls_sn TO gt_sn.
              ENDDO.
              CLEAR ls_sn.
            ENDLOOP.
          ENDIF.

        WHEN '0150'.
          IF lt_ltap[] IS NOT INITIAL.
            LOOP AT lt_ltap INTO ls_ltap.
              CLEAR ls_002.
              READ TABLE lt_002 INTO ls_002
                                WITH KEY matnr = ls_ltap-matnr.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              CLEAR ls_accdtd.
              READ TABLE gt_accdtd INTO ls_accdtd
                                   WITH KEY docno = ls_ltap-tanum
                                            posnr = ls_ltap-tapos.
              IF sy-subrc = 0.
                CONTINUE.
              ENDIF.
              DO ls_ltap-nsola TIMES.
                ls_sn-tanum  = ls_ltap-tanum.
                ls_sn-posnr  = ls_ltap-tapos.
                ls_sn-matnr  = ls_ltap-matnr.
                ls_sn-charg  = ls_ltap-charg.
                ls_sn-werks  = ls_ltap-werks.
                ls_sn-lgort  = ls_ltap-lgort.
                ls_sn-maktx  = ls_ltap-maktx.
                ls_sn-meins  = ls_ltap-altme.
                APPEND ls_sn TO gt_sn.
              ENDDO.
              CLEAR ls_sn.
            ENDLOOP.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF gt_sn[] IS NOT INITIAL.
      lt_sn[]  = gt_sn[].
      SORT lt_sn BY werks matnr charg lgort.
      DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING werks matnr charg lgort.
      IF lt_sn[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtm
          FOR ALL ENTRIES IN lt_sn
          WHERE matnr = lt_sn-matnr
            AND charg = lt_sn-charg
            AND werks = lt_sn-werks
            AND snsta = 'ESTO'.
        IF sy-subrc <> 0.
          SELECT *
            FROM zaccdtm
            INTO CORRESPONDING FIELDS OF TABLE gt_accdtm
            FOR ALL ENTRIES IN lt_sn
            WHERE matnr = lt_sn-matnr
              AND werks = lt_sn-werks
              AND snsta = 'ESTO'.
        ENDIF.
      ENDIF.
    ELSE.
      gv_subrc = 7.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF gt_accdtm[] IS NOT INITIAL.
      SELECT *
        FROM zaccdta
        INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
        FOR ALL ENTRIES IN gt_accdtm
        WHERE matnr = gt_accdtm-matnr
          AND charg = gt_accdtm-charg
          AND senum = gt_accdtm-senum.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREENMSG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
  ENDCASE.
ENDMODULE.                 " MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validate_data OUTPUT.
  DATA : lv_str1    TYPE string,
         lv_str2    TYPE string.

  CASE sy-dynnr.
    WHEN '0110'.
    WHEN '0111'.
      SPLIT gs_sn-count AT '/' INTO lv_str1 lv_str2.
      IF lv_str1 = lv_str2.
        MODIFY gt_sn FROM gs_sn
                      TRANSPORTING check
                      WHERE matnr = gs_sn-matnr
                        AND charg = gs_sn-charg.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " VALIDATE_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.
  DATA : lt_sn     TYPE STANDARD TABLE OF ty_sn,
         ls_sn     LIKE LINE OF gt_sn.

  DATA : lv_index(10),
         lv_count   TYPE i,
         lv_total   TYPE i.

  CASE sy-dynnr.
    WHEN '0110'.
    WHEN '0150'.
      SET CURSOR FIELD 'GV_TANUM'.

    WHEN '0111' OR '0121' OR '0131' OR '0141' OR '0151'.
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
*&      Form  F_ISI_SERIAL_NUMBER
*&---------------------------------------------------------------------*
FORM f_isi_serial_number .
  DATA : ls_accdtm   LIKE LINE OF gt_accdtm,
         lv_senum(20),
         lv_charg(10),
         lv_matnr    TYPE mara-matnr,
         lt_valsn    TYPE STANDARD TABLE OF ty_valsn,
         ls_valsn    LIKE LINE OF lt_valsn.

  CALL METHOD zcl_util=>m_acc_split_sn
    EXPORTING
      pvi_senum = gv_senum
    IMPORTING
      pvo_senum = lv_senum
      pvo_matnr = lv_matnr
      pvo_charg = lv_charg.

  PERFORM f_aggregasi TABLES lt_valsn
                      USING  lv_matnr lv_charg lv_senum.

* Validasi Material & Batch terhadap screen
  PERFORM f_validasi_1 USING lv_matnr lv_charg.

  IF gv_subrc IS INITIAL.
* Validasi sudah pernah discan atau belum
    PERFORM f_validasi_2 TABLES lt_valsn
                         USING  gs_sn-matnr gs_sn-charg.
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
  DATA : lt_sn        TYPE STANDARD TABLE OF ty_sn,
         ls_sn        LIKE LINE OF lt_sn,
         ls_xsn       LIKE LINE OF gt_sn,
         lt_accdtd    TYPE STANDARD TABLE OF zaccdtd,
         ls_accdtd    LIKE LINE OF lt_accdtd,
         lt_accdtm    TYPE STANDARD TABLE OF zaccdtm,
         ls_accdtm    LIKE LINE OF lt_accdtm,
         lt_accdta    TYPE STANDARD TABLE OF zaccdta,
         ls_accdta    LIKE LINE OF lt_accdta,
         lt_temp      TYPE STANDARD TABLE OF zaccdta,
         ls_temp      LIKE LINE OF lt_temp,
         ls_zaccdta   LIKE LINE OF gt_zaccdta,
         lt_s501      TYPE STANDARD TABLE OF s501,
         ls_s501      LIKE LINE OF lt_s501.

  DATA : lv_chk1   TYPE i,
         lv_chk2   TYPE i,
         lv_snsta  TYPE zaccdtm-snsta.

  lt_sn[] = gt_sn[].
  SORT lt_sn BY posnr. "matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_sn COMPARING posnr. "matnr charg.

  LOOP AT lt_sn INTO ls_sn.
    CLEAR : ls_xsn, lv_chk1, lv_chk2.
    LOOP AT gt_sn INTO ls_xsn WHERE posnr = ls_sn-posnr. "matnr = ls_sn-matnr
      "AND charg = ls_sn-charg.
      ADD 1 TO lv_chk1.

      IF ls_xsn-check IS NOT INITIAL.
        ADD 1 TO lv_chk2.

        CLEAR lv_snsta.
        IF gv_rsnum IS NOT INITIAL.
          ls_accdtd-docat   = 'RSV'.
          lv_snsta          = 'EDEL'.
        ELSEIF gv_tanum IS NOT INITIAL.
          ls_accdtd-docat   = gv_docat.
          lv_snsta          = 'EDEL'.
        ELSE.
          ls_accdtd-docat   = 'DO'.
          lv_snsta          = 'EDEL'.
        ENDIF.

        IF ls_xsn-vbeln IS NOT INITIAL.
          ls_accdtd-docno   = ls_xsn-vbeln.
        ELSEIF ls_xsn-rsnum IS NOT INITIAL.
          ls_accdtd-docno   = ls_xsn-rsnum.
        ELSEIF ls_xsn-reqno IS NOT INITIAL.
          ls_accdtd-docno   = ls_xsn-reqno.
        ELSEIF ls_xsn-ebeln IS NOT INITIAL.
          ls_accdtd-docno   = ls_xsn-ebeln.
        ELSEIF ls_xsn-tanum IS NOT INITIAL.
          ls_accdtd-docno   = ls_xsn-tanum.
        ENDIF.
        ls_accdtd-posnr   = ls_xsn-posnr.
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
        ls_accdtm-werks   = ls_xsn-werks.
        ls_accdtm-lgort   = ls_xsn-lgort.
        ls_accdtm-erdat   = sy-datum.
        ls_accdtm-ernam   = sy-uname.
        ls_accdtm-snsta   = lv_snsta.
        APPEND ls_accdtm TO lt_accdtm.

        ls_s501-sptag     = sy-datum.
        ls_s501-docat     = ls_accdtd-docat.
        ls_s501-docno     = ls_accdtd-docno.
        ls_s501-posnr     = ls_accdtd-posnr.
        ls_s501-vrsio     = '000'.
        ls_s501-spmon     = sy-datum(6).
        ls_s501-spwoc     = '000000'.
        ls_s501-spbup     = '000000'.
        ls_s501-ssour     = space.
        ls_s501-periv     = space.
        ls_s501-vwdat     = space.
        ls_s501-basme     = ls_xsn-meins.
        ls_s501-werks     = ls_xsn-werks.
        ls_s501-lgort     = ls_xsn-lgort.
        ls_s501-charg     = ls_xsn-charg.
        ls_s501-matnr     = ls_xsn-matnr.
        ls_s501-menge     = 1.
        ls_s501-meins     = ls_xsn-meins.
        COLLECT ls_s501 INTO lt_s501.

        CLEAR : ls_s501, ls_accdtd, ls_accdta, ls_accdtm.
      ENDIF.
    ENDLOOP.

    IF gv_reqno IS NOT INITIAL OR gv_ebeln IS NOT INITIAL OR lv_chk1 = lv_chk2.
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

      CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
        EXPORTING
          tabname    = 'ZACCDTM'
        TABLES
          it_zaccdtm = lt_accdtm.

*      CLEAR ls_accdtm.
*      LOOP AT lt_accdtm INTO ls_accdtm.
*        TRY .
*            UPDATE zaccdtm SET werks = ls_accdtm-werks
*                               lgort = ls_accdtm-lgort
*                               erdat = ls_accdtm-erdat
*                               ernam = ls_accdtm-ernam
*                               snsta = ls_accdtm-snsta
*                           WHERE matnr = ls_accdtm-matnr
*                             AND charg = ls_accdtm-charg
*                             AND senum = ls_accdtm-senum.
*          CATCH cx_sy_conversion_no_number.
*        ENDTRY.
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

  PERFORM f_unlock.

  CALL SCREEN 2999.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_1
*&---------------------------------------------------------------------*
FORM f_validasi_1  USING    fu_matnr fu_charg.
  DATA : lv_matnr         TYPE mara-matnr.

  lv_matnr  = fu_matnr.

  IF gs_sn-matnr <> lv_matnr.
    gv_subrc = 6.
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
FORM f_validasi_2  TABLES   ft_valsn LIKE gt_valsn
                   USING    fu_matnr fu_charg.
  DATA : ls_valsn   LIKE LINE OF gt_valsn,
         lv_lin1    TYPE i,
         lv_lin2    TYPE i.

  DESCRIBE TABLE ft_valsn LINES lv_lin1.
  LOOP AT gt_sn INTO ls_sn WHERE senum IS INITIAL
                             AND matnr = fu_matnr
                             AND charg = fu_charg.
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
      gv_subrc  = 3.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_2

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_3
*&---------------------------------------------------------------------*
FORM f_validasi_3  TABLES   ft_valsn LIKE gt_valsn
                   USING    fu_matnr fu_charg.
  DATA : ls_accdtm    LIKE LINE OF gt_accdtm,
         ls_valsn     LIKE LINE OF gt_valsn.

  LOOP AT ft_valsn INTO ls_valsn.
    READ TABLE gt_accdtm INTO ls_accdtm
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
*&      Form  F_LOCK_OBJECT
*&---------------------------------------------------------------------*
FORM f_lock_object USING fu_tname.
  DATA : lt_enq    TYPE STANDARD TABLE OF seqg3,
         ls_enq    LIKE LINE OF lt_enq,
         lv_value  TYPE eqegraarg,
         lv_garg(30).

  CASE fu_tname.
    WHEN 'LIPS'.
      CONCATENATE sy-mandt gv_vbeln INTO lv_value.
    WHEN 'RKPF'.
      CONCATENATE sy-mandt gv_rsnum INTO lv_value.
    WHEN 'ZGDMMT0001'.
      lv_value = gv_reqno.
    WHEN 'EKKO'.
      CONCATENATE sy-mandt gv_ebeln INTO lv_value.
    WHEN 'LTAK'.
      CONCATENATE sy-mandt gv_lgnum gv_tanum INTO lv_value.
  ENDCASE.

  CALL FUNCTION 'ENQUEUE_REPORT'
    EXPORTING
      guname = space
    TABLES
      enq    = lt_enq.

  LOOP AT lt_enq INTO ls_enq
                 WHERE gname = fu_tname.
    CASE fu_tname.
      WHEN 'ZGDMMT0001'.
        SHIFT ls_enq-garg LEFT DELETING LEADING '0'.
        lv_garg = ls_enq-garg+29(30).
        IF lv_garg = lv_value.
          gv_guname = ls_enq-guname.
          gv_subrc  = 9.
          EXIT.
        ENDIF.

      WHEN OTHERS.
        IF ls_enq-garg = lv_value.
          gv_guname = ls_enq-guname.
          gv_subrc  = 9.
          EXIT.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF gv_subrc = 0.
    CASE fu_tname.
      WHEN 'LIPS'.
        CALL FUNCTION 'ENQUEUE_EVVBLKE'
          EXPORTING
            vbeln          = gv_vbeln
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'RKPF'.
        CALL FUNCTION 'ENQUEUE_EMRKPF'
          EXPORTING
            rsnum          = gv_rsnum
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'ZGDMMT0001'.
        CALL FUNCTION 'ENQUEUE_EZGDMMT0001'
          EXPORTING
            req_no         = gv_reqno
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'EKKO'.
        CALL FUNCTION 'ENQUEUE_EMEKKOE'
          EXPORTING
            ebeln          = gv_ebeln
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

      WHEN 'LTAK'.
        CALL FUNCTION 'ENQUEUE_ELLTAKE'
          EXPORTING
            lgnum          = gv_lgnum
            tanum          = gv_tanum
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_LOCK_OBJECT

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK
*&---------------------------------------------------------------------*
FORM f_unlock .
  CASE sy-dynnr.
    WHEN '0111'.
      CALL FUNCTION 'DEQUEUE_EVVBLKE'
        EXPORTING
          vbeln = gv_vbeln.
    WHEN '0121'.
      CALL FUNCTION 'DEQUEUE_EMRKPF'
        EXPORTING
          rsnum = gv_rsnum.
    WHEN '0131'.
      CALL FUNCTION 'DEQUEUE_EZGDMMT0001'
        EXPORTING
          req_no = gv_reqno.
    WHEN '0141'.
      CALL FUNCTION 'DEQUEUE_EMEKKOE'
        EXPORTING
          ebeln = gv_ebeln.
  ENDCASE.
ENDFORM.                    " F_UNLOCK
