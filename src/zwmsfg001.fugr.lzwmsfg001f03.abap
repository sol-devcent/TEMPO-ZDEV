*----------------------------------------------------------------------*
***INCLUDE LZWMSFG001F03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CREATE_TO
*&---------------------------------------------------------------------*
FORM f_proses_create_to  TABLES   pt_to   STRUCTURE zwmsst001
                         USING    p_json
                         CHANGING p_to_number p_pallet_no fc_type fc_message.

  DATA : ls_to         TYPE ty_to,
         lt_shipdata   TYPE STANDARD TABLE OF ty_shipment,
         ls_shipdata   LIKE LINE OF lt_shipdata,
         lt_shipment   TYPE STANDARD TABLE OF ty_shipment,
         ls_shipment   LIKE LINE OF lt_shipment,
         lt_xshipment  TYPE STANDARD TABLE OF ty_shipment,
         lt_shipdetail TYPE STANDARD TABLE OF ty_shipdetail,
         ls_shipdetail LIKE LINE OF lt_shipdetail,
         lt_xshipdata  TYPE STANDARD TABLE OF ty_shipdetail.
*         lt_xshipdata  TYPE STANDARD TABLE OF ty_shipment.

  DATA : lv_json_data    TYPE string,
         lv_uname        TYPE sy-uname,
         lv_lgnum        TYPE ltak-lgnum,
         lv_tknum        TYPE vttk-tknum,
         lv_bwlvs        TYPE ltak-bwlvs,
         lv_betyp        TYPE ltak-betyp,
         lv_benum        TYPE ltak-benum,
         lv_lznum        TYPE ltak-lznum,
         lv_drukz        TYPE t329f-drukz,
         lv_commit       TYPE rl03b-comit,
         lv_werks        TYPE t320-werks,
         lv_carton       TYPE lips-lfimg,
         lv_receh        TYPE lips-lfimg,
         lv_anfme        TYPE ltap_creat-anfme,
         lv_tanum        TYPE ltak-tanum,
         lv_lfimg        TYPE zwmdt004-lfimg,
         lv_4lfimg       TYPE zwmdt004-lfimg,
         lv_dnqty        TYPE lips-lfimg,
         lv_nltyp        TYPE ltap-nltyp,
         lv_nlpla        TYPE ltap-nlpla,
         lv_subrc        TYPE sy-subrc,
         lv_pallet(10),
         lv_itemid(20),
         lv_add          TYPE c LENGTH 1,
         lv_sisa         TYPE mlgn-lhmg1,
         lv_save         TYPE sy-subrc,
         lv_charg        TYPE ltap-charg,
         lv_rusak        TYPE c LENGTH 1,
         lv_zdtsul       TYPE sy-datum,
         lv_zuzsul       TYPE sy-uzeit,
         lv_zdteul       TYPE sy-datum,
         lv_zuzeul       TYPE sy-uzeit,
         lv_tabix        TYPE sy-tabix,
         lv_message(220),
         lv_004,
         lv_lhmg1        TYPE mlgn-lhmg1.

  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004,
         ls_004        LIKE LINE OF lt_004,
         lt_s004       TYPE STANDARD TABLE OF zwmdt004,
         ls_s004       LIKE LINE OF lt_004,
         ls_001        TYPE zwmsst001,
         lt_mlgn       TYPE STANDARD TABLE OF mlgn,
         ls_mlgn       LIKE LINE OF lt_mlgn.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_to ).

  lv_tknum  = ls_to-shipment_number.
  lv_uname  = ls_to-user_name.
  lv_lgnum  = ls_to-warehouse_number.
  lv_rusak  = ls_to-rusak_indicator.

  PERFORM f_datetime USING ls_to-unloading_start
                     CHANGING lv_zdtsul lv_zuzsul.

  PERFORM f_datetime USING ls_to-unloading_end
                     CHANGING lv_zdteul lv_zuzeul.

  SELECT SINGLE werks
    FROM t320
    INTO lv_werks
    WHERE lgnum = lv_lgnum.

  lt_shipdetail[] = ls_to-nav_ship[].
  lt_xshipdata[]  = ls_to-nav_ship[].
  SORT lt_xshipdata BY material_number.
  DELETE ADJACENT DUPLICATES FROM lt_xshipdata COMPARING material_number.
  IF lt_xshipdata[] IS NOT INITIAL.
    SELECT *
      FROM mlgn
      INTO CORRESPONDING FIELDS OF TABLE lt_mlgn
      FOR ALL ENTRIES IN lt_xshipdata
      WHERE matnr = lt_xshipdata-material_number
        AND lgnum = lv_lgnum.
  ENDIF.

  SORT ls_to-nav_ship BY material_number batch.
  LOOP AT ls_to-nav_ship INTO ls_shipdetail.
    ls_shipdata-tknum  = ls_to-shipment_number.
    ls_shipdata-matnr  = ls_shipdetail-material_number.
    ls_shipdata-charg  = ls_shipdetail-batch.
    IF ls_shipdata-charg(1) = '?'.
      ls_shipdata-charg(1) = space.
    ENDIF.

    PERFORM f_unit_conversion USING ls_shipdetail
                              CHANGING lv_carton lv_receh.
    ls_shipdata-lfimg = lv_carton + lv_receh.
    ls_shipdata-vrkme = ls_shipdetail-uom_satuan.
    ls_shipdata-newbc = ls_shipdetail-newmat_indicator.
    ls_shipdata-zero  = ls_shipdetail-zero_indicator.
    ls_shipdata-newch = ls_shipdetail-newbatch_indicator.
    ls_shipdata-newsn = ls_shipdetail-newsn_indicator.

    CLEAR : ls_mlgn, lv_subrc.
    READ TABLE lt_mlgn INTO ls_mlgn
                       WITH KEY matnr = ls_shipdata-matnr.
    IF sy-subrc = 0.
      IF ls_shipdata-lfimg <= ls_mlgn-lhmg1.
        APPEND ls_shipdata TO lt_shipdata.
      ELSE.
        WHILE lv_subrc = 0.
          IF lv_lhmg1 <= 0.
            lv_subrc = 4.
          ELSE.
            IF ls_mlgn-lhmg1 > lv_lhmg1.
              ls_shipdata-lfimg = lv_lhmg1.
            ELSE.
              ls_shipdata-lfimg = ls_mlgn-lhmg1.
            ENDIF.
            APPEND ls_shipdata TO lt_shipdata.
          ENDIF.
          lv_lhmg1 = ls_shipdata-lfimg - ls_mlgn-lhmg1.
        ENDWHILE.
      ENDIF.
    ENDIF.
*****    COLLECT ls_shipdata INTO lt_shipdata.
    CLEAR ls_shipdata.
  ENDLOOP.
  CLEAR lv_subrc.

  SORT lt_shipdata BY matnr charg.
  IF lt_shipdata[] IS NOT INITIAL.
    SELECT tknum a~vbeln posnr matnr charg lfimg meins vrkme
      FROM vttp AS a JOIN lips AS b ON a~vbeln = b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE lt_shipment
      FOR ALL ENTRIES IN lt_shipdata
      WHERE tknum = lv_tknum
        AND matnr = lt_shipdata-matnr
        AND charg = lt_shipdata-charg
        AND lfimg NE 0.

    IF lt_shipment[] IS NOT INITIAL.
      SELECT *
        FROM zwmdt004
        INTO CORRESPONDING FIELDS OF TABLE lt_004
        FOR ALL ENTRIES IN lt_shipment
        WHERE lgnum = lv_lgnum
          AND tknum = lt_shipment-tknum.
    ELSE.
      lv_subrc = 4.
    ENDIF.

    SORT lt_004 BY matnr charg.
    LOOP AT lt_004 INTO ls_004.
      ls_s004-matnr = ls_004-matnr.
      ls_s004-charg = ls_004-charg.
      ls_s004-lfimg = ls_004-lfimg.
      COLLECT ls_s004 INTO lt_s004.
      CLEAR ls_s004.
    ENDLOOP.
  ENDIF.

  lv_pallet = ls_to-pallet_number.
*****  lt_xshipdata[] = lt_shipdata[].
*****  SORT lt_xshipdata BY matnr.
*****  DELETE ADJACENT DUPLICATES FROM lt_xshipdata COMPARING matnr.
*****  IF lt_xshipdata[] IS NOT INITIAL.
*****    SELECT *
*****      FROM mlgn
*****      INTO CORRESPONDING FIELDS OF TABLE lt_mlgn
*****      FOR ALL ENTRIES IN lt_xshipdata
*****      WHERE matnr = lt_xshipdata-matnr
*****        AND lgnum = lv_lgnum.
*****  ENDIF.

  LOOP AT lt_shipdata INTO ls_shipdata.
    IF ls_shipdata-zero IS INITIAL AND
      lv_rusak IS INITIAL AND
      ls_shipdata-newch IS INITIAL AND
      ls_shipdata-newbc IS INITIAL AND
      ls_shipdata-newsn IS INITIAL.
      CLEAR : ls_shipdetail, lv_itemid, lv_charg.
      lv_charg = ls_shipdata-charg.
      IF lv_charg(1) = space.
        lv_charg(1) = '?'.
      ENDIF.
      READ TABLE lt_shipdetail INTO ls_shipdetail
                               WITH KEY material_number = ls_shipdata-matnr
                                        batch           = lv_charg.
      IF sy-subrc = 0.
        lv_itemid = ls_shipdetail-item_id.
      ENDIF.

      CLEAR : ls_shipment, lv_dnqty.
      LOOP AT lt_shipment INTO ls_shipment WHERE matnr = ls_shipdata-matnr
                                             AND charg = ls_shipdata-charg.
        ADD ls_shipment-lfimg TO lv_dnqty.
      ENDLOOP.

      PERFORM f_check_to_created TABLES lt_s004
                                 USING ls_shipdata-matnr ls_shipdata-charg
                                       ls_shipdata-lfimg lv_dnqty
                                 CHANGING lv_anfme lv_subrc.
      IF lv_subrc = 0.
        IF ls_shipdata-lfimg <> lv_dnqty.
          lv_004 = 'X'.
        ENDIF.
        SORT lt_shipment BY vbeln posnr.
        CLEAR : ls_shipment.
        LOOP AT lt_shipment INTO ls_shipment WHERE matnr = ls_shipdata-matnr
                                               AND charg = ls_shipdata-charg.
          lv_lfimg = ls_shipment-lfimg.
          WHILE lv_lfimg > 0.
            IF lv_anfme > 0.
              CLEAR : ls_004, lv_4lfimg.
              LOOP AT lt_004 INTO ls_004 WHERE matnr = ls_shipment-matnr
                                           AND charg = ls_shipment-charg
                                           AND vbeln = ls_shipment-vbeln
                                           AND posnr = ls_shipment-posnr.
                ADD ls_004-lfimg TO lv_4lfimg.
*                DELETE lt_004 INDEX sy-tabix.

                IF lv_4lfimg = ls_shipment-lfimg.
                  lv_lfimg = 0.
                  EXIT.
                ENDIF.
              ENDLOOP.

              ls_shipment-lfimg = ls_shipment-lfimg - lv_4lfimg.
              IF ls_shipment-lfimg <= 0.
                lv_lfimg = 0.
                CONTINUE.
              ENDIF.

***              IF sy-subrc = 0.
***              IF lv_4lfimg = ls_shipment-lfimg.
***                lv_lfimg = 0.
***                CONTINUE.
***              ELSE.
***                ls_shipment-lfimg = ls_shipment-lfimg - lv_4lfimg.
***                IF ls_shipment-lfimg < 0.
***                  lv_lfimg = 0.
***                  CONTINUE.
***                ENDIF.
***              ENDIF.
***              ENDIF.

              lv_lgnum  = ls_to-warehouse_number.
              lv_bwlvs  = '101'.
              lv_betyp  = 'Z'.
              lv_benum  = ls_shipment-vbeln.
              CONCATENATE lv_pallet ls_shipdata-tknum INTO lv_lznum
              SEPARATED BY ';'.
              lv_drukz  = '45'.
              lv_commit = space.

              CLEAR : lt_ltap_creat[].
              PERFORM f_prepare_detail TABLES lt_ltap_creat lt_mlgn
                                       USING ls_shipdata ls_shipment lv_werks lv_lznum
                                                 '' '' '' lv_lgnum
                                       CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                                lv_sisa lv_add.

              PERFORM f_create_to TABLES lt_ltap_creat
                                  USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                                        lv_lznum lv_drukz lv_commit
                                  CHANGING lv_tanum lv_subrc.

              IF lv_tanum IS NOT INITIAL.
                p_to_number = lv_tanum.
                fc_type    = 'S'.
                fc_message = 'Create TO success'.

                PERFORM f_save_004 TABLES lt_004
                                   USING lv_tanum ls_to-warehouse_number lv_lznum
                                         lv_uname '' lv_rusak lv_004
                                         lv_zdtsul lv_zuzsul lv_zdteul lv_zuzeul
                                         ls_shipdata ls_shipment ls_ltap_creat
                                   CHANGING lv_save.
                IF lv_save = 0.
                  PERFORM f_print_to USING lv_tanum ls_to-warehouse_number
                                     CHANGING lv_nltyp lv_nlpla.
                ENDIF.
                PERFORM f_body_response TABLES pt_to
                                        USING ls_ltap_creat
                                              lv_itemid lv_pallet lv_tanum lv_nlpla
                                              '' fc_type fc_message.

                CLEAR : ls_ltap_creat, lv_tanum, lv_itemid.
                IF lv_add IS NOT INITIAL.
                  ADD 1 TO lv_pallet.
                ENDIF.
                CONDENSE lv_pallet NO-GAPS.
              ELSE.
                CLEAR : lv_lfimg, lv_anfme.
                fc_type    = 'E'.
                CALL FUNCTION 'ZWMSFM002'
                  EXPORTING
                    pi_subrc    = lv_subrc
                    pi_function = 'L_TO_CREATE_MULTIPLE'
                  IMPORTING
                    pe_message  = fc_message.

                PERFORM f_body_response TABLES pt_to
                                        USING ls_ltap_creat
                                              lv_itemid lv_pallet '' ''
                                              '' fc_type fc_message.
              ENDIF.
            ELSE.
              CLEAR : lv_lfimg.
            ENDIF.
          ENDWHILE.
        ENDLOOP.

        WHILE lv_anfme > 0.
          CONCATENATE lv_pallet ls_shipdata-tknum INTO lv_lznum
          SEPARATED BY ';'.
          CLEAR : lt_ltap_creat[].
          ls_shipment-lfimg = lv_anfme.
          PERFORM f_prepare_detail TABLES lt_ltap_creat lt_mlgn
                                   USING ls_shipdata ls_shipment lv_werks lv_lznum
                                         '' '' 'X' lv_lgnum
                                   CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                            lv_sisa lv_add.

          PERFORM f_create_to TABLES lt_ltap_creat
                              USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                                    lv_lznum lv_drukz lv_commit
                              CHANGING lv_tanum lv_subrc.

          IF lv_tanum IS NOT INITIAL.
            p_to_number = lv_tanum.
            fc_type    = 'S'.
            fc_message = 'Create TO success'.

            PERFORM f_save_004 TABLES lt_004
                               USING lv_tanum ls_to-warehouse_number lv_lznum
                                     lv_uname '' lv_rusak ''
                                     lv_zdtsul lv_zuzsul lv_zdteul lv_zuzeul
                                     ls_shipdata ls_shipment ls_ltap_creat
                               CHANGING lv_save.
            IF lv_save = 0.
              PERFORM f_print_to USING lv_tanum ls_to-warehouse_number
                                 CHANGING lv_nltyp lv_nlpla.
            ENDIF.
            PERFORM f_body_response TABLES pt_to
                                    USING ls_ltap_creat
                                          lv_itemid lv_pallet lv_tanum lv_nlpla
                                          '' fc_type fc_message.

            CLEAR : ls_ltap_creat, lv_tanum, lv_itemid.
            IF lv_add IS NOT INITIAL.
              ADD 1 TO lv_pallet.
            ENDIF.
            CONDENSE lv_pallet NO-GAPS.
          ELSE.
            fc_type    = 'E'.
            CALL FUNCTION 'ZWMSFM002'
              EXPORTING
                pi_subrc    = lv_subrc
                pi_function = 'L_TO_CREATE_MULTIPLE'
              IMPORTING
                pe_message  = fc_message.

            PERFORM f_body_response TABLES pt_to
                                    USING ls_ltap_creat
                                          lv_itemid lv_pallet '' ''
                                          '' fc_type fc_message.
          ENDIF.
        ENDWHILE.
      ELSE.
        CASE lv_subrc.
          WHEN 3.
            lv_message  = 'Tidak ada quantity outstanding'.
          WHEN 4.
            lv_message  = 'TO tidak terbentuk'.
        ENDCASE.
        PERFORM f_body_response TABLES pt_to
                                USING ls_ltap_creat
                                      lv_itemid lv_pallet '' ''
                                      '' 'E' lv_message.
        fc_type    = 'E'.
        fc_message = lv_message.
      ENDIF.
    ELSE.
      IF lv_rusak IS NOT INITIAL.
        CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
        READ TABLE lt_shipdetail INTO ls_shipdetail
                                 WITH KEY material_number = ls_shipdata-matnr
                                          batch           = ls_shipdata-charg.
        IF sy-subrc = 0.
          lv_itemid = ls_shipdetail-item_id.
        ENDIF.

        SORT lt_shipment BY vbeln.
        READ TABLE lt_shipment INTO ls_shipment
                               WITH KEY matnr = ls_shipdata-matnr
                                        charg = ls_shipdata-charg.
        IF sy-subrc = 0.
          PERFORM f_proses_unloading_rusak TABLES pt_to lt_mlgn
                                           USING ls_shipdata ls_shipdetail ls_shipment
                                                 ls_to-warehouse_number
                                                 lv_werks lv_pallet lv_itemid lv_uname
                                                 lv_rusak lv_zdtsul lv_zuzsul
                                                 lv_zdteul lv_zuzeul
                                           CHANGING fc_type fc_message.
        ENDIF.
      ENDIF.

      IF ls_shipdata-zero IS NOT INITIAL.
        CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
        READ TABLE lt_shipdetail INTO ls_shipdetail
                                 WITH KEY material_number = ls_shipdata-matnr
                                          batch           = ls_shipdata-charg.
        IF sy-subrc = 0.
          lv_itemid = ls_shipdetail-item_id.
        ENDIF.

        SORT lt_shipment BY vbeln.
        READ TABLE lt_shipment INTO ls_shipment
                               WITH KEY matnr = ls_shipdata-matnr
                                        charg = ls_shipdata-charg.
        IF sy-subrc = 0.
          PERFORM f_proses_unloading_zero TABLES pt_to lt_mlgn
                                          USING ls_shipdata ls_shipdetail ls_shipment
                                                ls_to-warehouse_number
                                                lv_werks lv_pallet lv_itemid lv_uname
                                                lv_rusak lv_zdtsul lv_zuzsul
                                                lv_zdteul lv_zuzeul
                                          CHANGING fc_type fc_message.
        ENDIF.
      ENDIF.

      IF ls_shipdata-newbc IS NOT INITIAL.
        CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
        READ TABLE lt_shipdetail INTO ls_shipdetail
                                 WITH KEY material_number = ls_shipdata-matnr
                                          batch           = ls_shipdata-charg.
        IF sy-subrc = 0.
          lv_itemid = ls_shipdetail-item_id.
        ENDIF.

        PERFORM f_proses_unloading_newmaterial TABLES pt_to lt_mlgn
                                               USING ls_shipdata ls_shipdetail ls_shipment
                                                     ls_to-warehouse_number
                                                     lv_werks lv_pallet lv_itemid lv_uname
                                                     lv_rusak lv_zdtsul lv_zuzsul
                                                     lv_zdteul lv_zuzeul
                                               CHANGING fc_type fc_message.
      ENDIF.

      IF ls_shipdata-newch IS NOT INITIAL.
        CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
        READ TABLE lt_shipdetail INTO ls_shipdetail
                                 WITH KEY material_number = ls_shipdata-matnr
                                          batch           = ls_shipdata-charg.
        IF sy-subrc = 0.
          lv_itemid = ls_shipdetail-item_id.
        ENDIF.

        PERFORM f_proses_unloading_newbatch TABLES pt_to lt_mlgn
                                            USING ls_shipdata ls_shipdetail ls_shipment
                                                  ls_to-warehouse_number
                                                  lv_werks lv_pallet lv_itemid lv_uname
                                                  lv_rusak lv_zdtsul lv_zuzsul
                                                  lv_zdteul lv_zuzeul
                                            CHANGING fc_type fc_message.
      ENDIF.

      IF ls_shipdata-newsn IS NOT INITIAL.

      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fs_shipdetail    TYPE ty_shipdetail
                        CHANGING fc_carton fc_receh.
  DATA : ls_marm  TYPE marm,
         lv_meins TYPE mara-meins.

  PERFORM f_unit_conversion_input USING fs_shipdetail-uom_carton
                                  CHANGING lv_meins.
  SELECT SINGLE *
    FROM marm
    INTO CORRESPONDING FIELDS OF ls_marm
    WHERE matnr = fs_shipdetail-material_number
      AND meinh = lv_meins.
  IF sy-subrc = 0.
    fc_carton = fs_shipdetail-quantity_carton * ls_marm-umrez / ls_marm-umren.
  ENDIF.
  fc_receh = fs_shipdetail-quantity_satuan.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_004
*&---------------------------------------------------------------------*
FORM f_save_004  TABLES   ft_004  STRUCTURE zwmdt004
                 USING    fu_tanum fu_lgnum fu_lznum fu_uname
                          fu_change fu_rusak fu_004
                          fu_zdtsul fu_zuzsul fu_zdteul fu_zuzeul
                          fs_shipdata     TYPE ty_shipment
                          fs_shipment     TYPE ty_shipment
                          fs_ltap_creat   TYPE ltap_creat
                 CHANGING fc_subrc.

  DATA : ls_004   TYPE zwmdt004.

  DATA : lv_lznum TYPE ltak-lznum,
         lv_tknum TYPE vttk-tknum.

  CLEAR fc_subrc.

  ls_004-lgnum    = fu_lgnum.
  SPLIT fu_lznum AT ';' INTO lv_lznum lv_tknum.

  CASE fu_change.
    WHEN 'RUSAK'.
      ls_004-vbeln    = fs_shipment-vbeln.
      ls_004-posnr    = fs_shipment-posnr.
      ls_004-tknum    = fs_shipdata-tknum.
      ls_004-lznum    = lv_lznum.
      ls_004-matnr    = fs_shipdata-matnr.
      ls_004-charg    = fs_shipdata-charg.
      ls_004-lfimg    = fs_shipdata-lfimg.
      PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                      CHANGING ls_004-vrkme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-rusak    = fu_rusak.
      ls_004-zdtsul   = fu_zdtsul.
      ls_004-zuzsul   = fu_zuzsul.
      ls_004-zdteul   = fu_zdteul.
      ls_004-zuzeul   = fu_zuzeul.

    WHEN 'ZERO'.
      ls_004-vbeln    = fs_shipment-tknum.
      ls_004-posnr    = fs_shipment-posnr.
      ls_004-tknum    = fs_shipdata-tknum.
      ls_004-lznum    = lv_lznum.
      ls_004-matnr    = fs_shipdata-matnr.
      ls_004-charg    = fs_shipdata-charg.
      ls_004-lfimg    = fs_shipdata-lfimg.
      PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                      CHANGING ls_004-vrkme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-zero     = fs_shipdata-zero.
      ls_004-zdtsul   = fu_zdtsul.
      ls_004-zuzsul   = fu_zuzsul.
      ls_004-zdteul   = fu_zdteul.
      ls_004-zuzeul   = fu_zuzeul.

    WHEN 'NEWCH'.
      ls_004-vbeln    = fs_shipdata-tknum.
      ls_004-posnr    = fs_shipment-posnr.
      ls_004-tknum    = fs_shipdata-tknum.
      ls_004-lznum    = lv_lznum.
      ls_004-matnr    = fs_shipdata-matnr.
      ls_004-charg    = fs_shipdata-charg.
      ls_004-lfimg    = fs_shipdata-lfimg.
      PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                      CHANGING ls_004-vrkme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-newch    = fs_shipdata-newch.
      ls_004-zdtsul   = fu_zdtsul.
      ls_004-zuzsul   = fu_zuzsul.
      ls_004-zdteul   = fu_zdteul.
      ls_004-zuzeul   = fu_zuzeul.

    WHEN 'NEWBC'.
      ls_004-vbeln    = fs_shipdata-tknum.
      ls_004-posnr    = fs_shipment-posnr.
      ls_004-tknum    = fs_shipdata-tknum.
      ls_004-lznum    = lv_lznum.
      ls_004-matnr    = fs_shipdata-matnr.
      ls_004-charg    = fs_shipdata-charg.
      ls_004-lfimg    = fs_shipdata-lfimg.
      PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                      CHANGING ls_004-vrkme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-newbc    = fs_shipdata-newbc.
      ls_004-zdtsul   = fu_zdtsul.
      ls_004-zuzsul   = fu_zuzsul.
      ls_004-zdteul   = fu_zdteul.
      ls_004-zuzeul   = fu_zuzeul.

    WHEN space.
      ls_004-tknum    = fs_shipment-tknum.
      ls_004-lznum    = lv_lznum.
      ls_004-posnr    = fs_ltap_creat-posnr.
      ls_004-matnr    = fs_ltap_creat-matnr.
      ls_004-charg    = fs_ltap_creat-charg.
      ls_004-lfimg    = fs_ltap_creat-anfme.
      ls_004-vrkme    = fs_ltap_creat-altme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      IF fs_ltap_creat-anfme = 0.
        ls_004-vbeln    = fs_shipment-tknum.
      ELSE.
        ls_004-vbeln    = fs_ltap_creat-vlpla.
      ENDIF.
      ls_004-zdtsul   = fu_zdtsul.
      ls_004-zuzsul   = fu_zuzsul.
      ls_004-zdteul   = fu_zdteul.
      ls_004-zuzeul   = fu_zuzeul.
  ENDCASE.

  IF ls_004 IS NOT INITIAL.
    TRY .
        MODIFY zwmdt004 FROM ls_004.
      CATCH cx_sy_open_sql_db.
        fc_subrc = 4.
    ENDTRY.
  ENDIF.

*****  IF fu_change IS INITIAL AND
*****    ft_004[] IS INITIAL AND
*****    fu_004 = 'X'.
*****    APPEND ls_004 TO ft_004.
*****  ENDIF.

  IF fc_subrc = 0.
    COMMIT WORK.
    CLEAR : ft_004[].

    SELECT *
      FROM zwmdt004
      INTO CORRESPONDING FIELDS OF TABLE ft_004
      WHERE lgnum = fu_lgnum
        AND tknum = fs_shipment-tknum.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_TO
*&---------------------------------------------------------------------*
FORM f_print_to  USING    fu_tanum fu_lgnum
                 CHANGING fc_nltyp fc_nlpla.
  DATA : lt_ltap   TYPE STANDARD TABLE OF ltap,
         ls_ltap   LIKE LINE OF lt_ltap,
         rspar_tab TYPE TABLE OF rsparams,
         ls_013    TYPE zwmdt013.

  CLEAR : rspar_tab[].

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum
      AND pquit = space.

  SELECT SINGLE *
    FROM zwmdt013
    INTO CORRESPONDING FIELDS OF ls_013
    WHERE lgnum   = fu_lgnum
      AND process = 'PRINT_TO'.

  LOOP AT lt_ltap INTO ls_ltap.
    IF fc_nlpla IS INITIAL.
      fc_nlpla = ls_ltap-nlpla.
    ENDIF.
    IF fc_nltyp IS INITIAL.
      fc_nltyp  = ls_ltap-nltyp.
    ENDIF.
    IF ls_013-active IS NOT INITIAL.
      PERFORM f_submit_parameter TABLES rspar_tab
                                 USING : 'PA_LGNUM' fu_lgnum 'P',
                                         'SO_LGTYP-LOW' ls_ltap-nltyp 'P',
                                         'SO_TANUM-LOW' fu_tanum 'P',
                                         'PA_FORM' 'X' 'P'.
      SUBMIT zwm_print_to WITH SELECTION-TABLE rspar_tab AND RETURN.
      CLEAR : rspar_tab[].
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_TO
*&---------------------------------------------------------------------*
FORM f_print_to_akhir  USING    fu_tanum fu_lgnum
                       CHANGING fc_nltyp fc_nlpla.
  DATA : lt_ltap   TYPE STANDARD TABLE OF ltap,
         ls_ltap   LIKE LINE OF lt_ltap,
         rspar_tab TYPE TABLE OF rsparams,
         lv_lznum  TYPE ltak-lznum,
         ls_013    TYPE zwmdt013.

  CLEAR : rspar_tab[].

*  SELECT *
*    FROM ltap
*    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
*    WHERE lgnum = fu_lgnum
*      AND tanum = fu_tanum
*      AND pquit = 'X'
*      AND zrstg = 'X'.
*  IF sy-subrc EQ 0.
*    SELECT SINGLE lznum INTO lv_lznum FROM ltak WHERE tanum = fu_tanum AND lgnum = fu_lgnum.
*  ENDIF.

  SELECT SINGLE lznum
    INTO lv_lznum
    FROM ltak WHERE lgnum = fu_lgnum
                AND tanum = fu_tanum.
  SELECT SINGLE lgnum, tanum, lznum
    INTO @DATA(ls_ltak)
    FROM ltak WHERE lznum = @lv_lznum.

  SELECT SINGLE * INTO ls_ltap
    FROM ltap WHERE lgnum = ls_ltak-lgnum
                AND tanum = ls_ltak-tanum
                AND pquit = 'X'
                AND zrstg = 'X'.

  SELECT SINGLE *
    FROM zwmdt013
    INTO CORRESPONDING FIELDS OF ls_013
    WHERE lgnum   = fu_lgnum
      AND process = 'PRINT_TO'.

  IF ls_013-active IS NOT INITIAL.
    PERFORM f_submit_parameter TABLES rspar_tab
                               USING : 'PA_DRUKZ' '48' 'P',
                                       'PA_LGNUM' fu_lgnum 'P',
                                       'PA_TANUM' fu_tanum 'P',
                                       'PA_LZNUM' lv_lznum 'P',
                                       'PA_BACKG' 'X' 'P',
                                       'PA_LGTYP' ls_ltap-nlpla 'P',
                                       'PA_LGPLA' ls_ltap-nltyp 'P'.
    SUBMIT zwm_print_to_group WITH SELECTION-TABLE rspar_tab AND RETURN.
    CLEAR : rspar_tab[].
  ENDIF.

*  LOOP AT lt_ltap INTO ls_ltap.
*    IF fc_nlpla IS INITIAL.
*      fc_nlpla = ls_ltap-nlpla.
*    ENDIF.
*    IF fc_nltyp IS INITIAL.
*      fc_nltyp  = ls_ltap-nltyp.
*    ENDIF.
*    IF ls_013-active IS NOT INITIAL.
*
*      PERFORM f_submit_parameter TABLES rspar_tab
*                                 USING : 'PA_DRUKZ' '48' 'P',
*                                         'PA_LGNUM' fu_lgnum 'P',
*                                         'PA_TANUM' fu_tanum 'P',
*                                         'PA_LZNUM' lv_lznum 'P',
*                                         'PA_BACKG' 'X' 'P',
*                                         'PA_LGTYP' ls_ltap-nlpla 'P',
*                                         'PA_LGPLA' ls_ltap-nltyp 'P'.
*      SUBMIT zwm_print_to_group WITH SELECTION-TABLE rspar_tab AND RETURN.
*      CLEAR : rspar_tab[].
*
*
***      PERFORM f_submit_parameter TABLES rspar_tab
***                                 USING : 'PA_LGNUM' fu_lgnum 'P',
***                                         'SO_LGTYP-LOW' ls_ltap-nltyp 'P',
***                                         'SO_TANUM-LOW' fu_tanum 'P',
***                                         'PA_FORM' 'X' 'P'.
***      SUBMIT zwm_print_to WITH SELECTION-TABLE rspar_tab AND RETURN.
***      CLEAR : rspar_tab[].
*    ENDIF.
*  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_PARAMETER
*&---------------------------------------------------------------------*
FORM f_submit_parameter  TABLES   rspar_tab STRUCTURE rsparams
                         USING    fu_selname fu_value fu_kind.
  DATA : rspar_line     TYPE rsparams.

  rspar_line-selname = fu_selname.
  rspar_line-kind    = fu_kind.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = fu_value.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TO_CREATED
*&---------------------------------------------------------------------*
FORM f_check_to_created  TABLES   ft_s004 STRUCTURE zwmdt004
                         USING    fu_matnr fu_charg fu_lfimg fu_dnqty
                         CHANGING fc_anfme fc_subrc.
  DATA : ls_s004    TYPE zwmdt004.

  DATA : lv_lfimg TYPE lips-lfimg,
         lv_sisa  TYPE lips-lfimg.

  CLEAR fc_anfme.
  READ TABLE ft_s004 INTO ls_s004
                     WITH KEY matnr = fu_matnr
                              charg = fu_charg.
  IF sy-subrc = 0.
    lv_lfimg = ls_s004-lfimg.
    IF fu_dnqty = lv_lfimg.
      fc_subrc = 3.
    ELSE.
      lv_sisa = fu_dnqty - lv_lfimg.
      IF fu_lfimg > lv_sisa.
        fc_anfme = fu_lfimg - lv_sisa.
        IF fc_anfme <= 0.
          fc_subrc = 4.
        ENDIF.
      ELSE.
        fc_anfme = fu_lfimg.
      ENDIF.
    ENDIF.
  ELSE.
    fc_anfme = fu_lfimg.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BODY_RESPONSE
*&---------------------------------------------------------------------*
FORM f_body_response  TABLES   ft_to STRUCTURE zwmsst001
                      USING    fs_ltap_creat TYPE ltap_creat
                               fu_itemid fu_pallet fu_tanum fu_nlpla
                               fu_change fu_type fu_message.
  DATA : ls_to  TYPE zwmsst001.

  ls_to-pallet   = fu_pallet.
  ls_to-itemid   = fu_itemid.
  ls_to-matnr    = fs_ltap_creat-matnr.
  ls_to-charg    = fs_ltap_creat-charg.
  IF ls_to-charg IS NOT INITIAL.
    IF ls_to-charg(1) = space.
      ls_to-charg(1) = '?'.
    ENDIF.
  ENDIF.

  ls_to-qtysat   = fs_ltap_creat-anfme.
*  PERFORM f_unit_conversion_output USING fs_ltap_creat-altme
*                                   CHANGING ls_to-meins.
  ls_to-meins    = fs_ltap_creat-altme.
  ls_to-qtycar   = 0.
  ls_to-meinh    = 'CAR'.
  ls_to-tanum    = fu_tanum.
  ls_to-nlpla    = fu_nlpla.
  ls_to-type     = fu_type.
  ls_to-message  = fu_message.
  CASE fu_change.
    WHEN 'RUSAK'.
      ls_to-rusak = 'X'.
    WHEN 'ZERO'.
      ls_to-zero  = 'X'.
    WHEN 'NEWCH'.
      ls_to-newch = 'X'.
    WHEN 'NEWBC'.
      ls_to-newbc = 'X'.
  ENDCASE.
  APPEND ls_to TO ft_to.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TO
*&---------------------------------------------------------------------*
FORM f_create_to  TABLES   ft_ltap_creat STRUCTURE ltap_creat
                  USING    fu_lgnum fu_bwlvs fu_betyp fu_benum fu_lznum
                           fu_drukz fu_commit
                  CHANGING fc_tanum fc_subrc.
  DATA : lv_lgnum  TYPE ltak-lgnum,
         lv_tknum  TYPE vttk-tknum,
         lv_bwlvs  TYPE ltak-bwlvs,
         lv_betyp  TYPE ltak-betyp,
         lv_benum  TYPE ltak-benum,
         lv_lznum  TYPE ltak-lznum,
         lv_drukz  TYPE t329f-drukz,
         lv_commit TYPE rl03b-comit,
         lv_tanum  TYPE ltak-tanum.

  CLEAR : fc_tanum, fc_subrc.
  lv_lgnum = fu_lgnum.
  lv_bwlvs = fu_bwlvs.
  lv_betyp = fu_betyp.
  lv_benum = fu_benum.
  lv_lznum = fu_lznum.
  lv_drukz = fu_drukz.
  lv_commit = fu_commit.
  TRY.
      CALL FUNCTION 'L_TO_CREATE_MULTIPLE'
        EXPORTING
          i_lgnum                = lv_lgnum
          i_bwlvs                = lv_bwlvs
          i_betyp                = lv_betyp
          i_benum                = lv_benum
          i_lznum                = lv_lznum
          i_drukz                = lv_drukz
          i_commit_work          = lv_commit
        IMPORTING
          e_tanum                = lv_tanum
        TABLES
          t_ltap_creat           = ft_ltap_creat
        EXCEPTIONS
          no_to_created          = 1
          bwlvs_wrong            = 2
          betyp_wrong            = 3
          benum_missing          = 4
          betyp_missing          = 5
          foreign_lock           = 6
          vltyp_wrong            = 7
          vlpla_wrong            = 8
          vltyp_missing          = 9
          nltyp_wrong            = 10
          nlpla_wrong            = 11
          nltyp_missing          = 12
          rltyp_wrong            = 13
          rlpla_wrong            = 14
          rltyp_missing          = 15
          squit_forbidden        = 16
          manual_to_forbidden    = 17
          letyp_wrong            = 18
          vlpla_missing          = 19
          nlpla_missing          = 20
          sobkz_wrong            = 21
          sobkz_missing          = 22
          sonum_missing          = 23
          bestq_wrong            = 24
          lgber_wrong            = 25
          xfeld_wrong            = 26
          date_wrong             = 27
          drukz_wrong            = 28
          ldest_wrong            = 29
          update_without_commit  = 30
          no_authority           = 31
          material_not_found     = 32
          lenum_wrong            = 33
          matnr_missing          = 34
          werks_missing          = 35
          anfme_missing          = 36
          altme_missing          = 37
          lgort_wrong_or_missing = 38
          error_message          = 99.
      "      OTHERS                 = 39.
    CATCH cx_root INTO DATA(lo_root_exception).
  ENDTRY.
  IF lo_root_exception IS NOT INITIAL.
    sy-subrc = 98.
  ENDIF.
  fc_subrc = sy-subrc.
  fc_tanum = lv_tanum.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PALLET_CAPACITY
*&---------------------------------------------------------------------*
FORM f_pallet_capacity  TABLES   ft_mlgn STRUCTURE mlgn
                        USING    fu_matnr fu_lfimg
                        CHANGING fc_lhmg1 fc_sisa.
  DATA : ls_mlgn  TYPE mlgn,
         lv_lhmg1 TYPE mlgn-lhmg1.

  READ TABLE ft_mlgn INTO ls_mlgn
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    IF fc_sisa > 0.
      lv_lhmg1 = fc_sisa.
    ELSE.
      lv_lhmg1 = ls_mlgn-lhmg1.
    ENDIF.

    IF fu_lfimg > lv_lhmg1.
      CLEAR fc_sisa.
      fc_lhmg1 = lv_lhmg1.
    ELSE.
      fc_sisa  = lv_lhmg1 - fu_lfimg.
      fc_lhmg1 = fu_lfimg.
    ENDIF.
  ELSE.
    fc_sisa  = lv_lhmg1 - fu_lfimg.
    fc_lhmg1 = fu_lfimg.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   ft_ltap_creat STRUCTURE ltap_creat
                                ft_mlgn       STRUCTURE mlgn
                       USING    fs_shipdata   TYPE ty_shipment
                                fs_shipment   TYPE ty_shipment
                                fu_werks fu_lznum fu_lfimg fu_change fu_end
                                fu_lgnum
                       CHANGING fs_ltap_creat TYPE ltap_creat
                                fc_lfimg fc_anfme fc_sisa fc_add.

  DATA : lv_lhmg1 TYPE mlgn-lhmg1.

  fs_ltap_creat-werks  = fu_werks.
  fs_ltap_creat-matnr  = fs_shipment-matnr.
  fs_ltap_creat-lgort  = '1000'.
  fs_ltap_creat-charg  = fs_shipment-charg.

  IF fu_lfimg IS INITIAL.
    PERFORM f_pallet_capacity TABLES ft_mlgn
                              USING fs_shipment-matnr fs_shipment-lfimg
                              CHANGING lv_lhmg1 fc_sisa.

    IF fc_anfme < lv_lhmg1.
      fs_ltap_creat-anfme  = fc_anfme.
      fc_anfme = fc_anfme - lv_lhmg1.
      fc_add = 'X'.
    ELSE.
      IF fc_lfimg < fs_shipment-lfimg.
        IF fc_lfimg > lv_lhmg1.
          fs_ltap_creat-anfme  = lv_lhmg1.
          fc_anfme = fc_anfme - lv_lhmg1.
        ELSE.
          fs_ltap_creat-anfme  = fc_lfimg.
          fc_anfme = fc_anfme - fc_lfimg.
          CLEAR fc_add.
        ENDIF.
      ELSE.
        fs_ltap_creat-anfme  = lv_lhmg1.
        fc_anfme = fc_anfme - lv_lhmg1.
        IF fc_sisa > 0.
          CLEAR fc_add.
        ELSE.
          fc_add = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    fc_lfimg = fc_lfimg - lv_lhmg1.
    fs_ltap_creat-vlpla  = fs_shipment-vbeln.
    PERFORM f_unit_conversion_input USING fs_shipment-vrkme
                                    CHANGING fs_ltap_creat-altme.
  ELSE.
    CASE fu_change.
      WHEN 'RUSAK'.
        IF fu_lgnum = 'C40'.
          DATA(lv_nltyp) = 'K01'.
          DATA(lv_nlber) = 'COM'.
          DATA(lv_nlpla) = 'KARANTINA'.
        ELSE.
          lv_nltyp = 'KOR'.
          lv_nlber = 'COM'.
          lv_nlpla = 'BA AMB'.
        ENDIF.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-nltyp  = lv_nltyp.  "'KOR'.
        fs_ltap_creat-nlber  = lv_nlber.  "'COM'.
        fs_ltap_creat-nlpla  = lv_nlpla.  "'BA AMB'.
        fs_ltap_creat-vlpla  = fs_shipment-vbeln.
        PERFORM f_unit_conversion_input USING fs_shipment-vrkme
                                        CHANGING fs_ltap_creat-altme.
      WHEN 'NEWCH'.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-nltyp  = 'K01'.
        fs_ltap_creat-nlber  = 'COM'.
        fs_ltap_creat-nlpla  = 'KARANTINA'.
        fs_ltap_creat-vlpla  = fs_shipdata-tknum.
        fs_ltap_creat-matnr  = fs_shipdata-matnr.
        fs_ltap_creat-charg  = fs_shipdata-charg.
        PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                        CHANGING fs_ltap_creat-altme.
      WHEN 'NEWBC'.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-vlpla  = fs_shipdata-tknum.
        fs_ltap_creat-matnr  = fs_shipdata-matnr.
        fs_ltap_creat-charg  = fs_shipdata-charg.
        PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                        CHANGING fs_ltap_creat-altme.
    ENDCASE.
  ENDIF.

  fs_ltap_creat-vltyp  = '902'.
  fs_ltap_creat-vlber  = '001'.
  fs_ltap_creat-letyp  = 'SP'.
  fs_ltap_creat-posnr  = fs_shipment-posnr.
  fs_ltap_creat-ablad  = fu_lznum.
  CONDENSE fs_ltap_creat-ablad NO-GAPS.
*      fs_ltap_creat-squit  = fs_post-capacity.

  APPEND fs_ltap_creat TO ft_ltap_creat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_COMPLETE_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_proses_complete_shipment  USING    p_json
                                 CHANGING fc_type fc_message.
  DATA : ls_shipment    TYPE ty_shipcmplt.

  DATA : lv_json_data TYPE string,
         lv_lgnum     TYPE zwmdt004-lgnum,
         lv_tknum     TYPE zwmdt004-tknum,
         lv_start     TYPE string,
         lv_end       TYPE string,
         lv_strdt     TYPE sy-datum,
         lv_strtm     TYPE sy-uzeit,
         lv_enddt     TYPE sy-datum,
         lv_endtm     TYPE sy-uzeit,
         lv_subrc     TYPE sy-subrc.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_shipment ).

  lv_lgnum  = ls_shipment-warehouse_number.
  lv_tknum  = ls_shipment-shipment_number.

  IF ls_shipment-unloading_start IS NOT INITIAL AND
    ls_shipment-unloading_end IS NOT INITIAL.

    SPLIT ls_shipment-unloading_start AT space INTO lv_strdt lv_start.
    TRANSLATE lv_start USING ': '.
    CONDENSE lv_start NO-GAPS.
    lv_strtm  = lv_start.

    SPLIT ls_shipment-unloading_end AT space INTO lv_enddt lv_end.
    TRANSLATE lv_end USING ': '.
    CONDENSE lv_end NO-GAPS.
    lv_endtm  = lv_end.

    TRY .
        UPDATE zwmdt004 SET zdtsul = lv_strdt
                            zuzsul = lv_strtm
                            zdteul = lv_enddt
                            zuzeul = lv_endtm
                            zcmplt = 'C'
                        WHERE lgnum = lv_lgnum
                          AND tknum = lv_tknum
                          AND zcmplt = space.
      CATCH cx_sy_open_sql_db.
        lv_subrc  = 4.
    ENDTRY.
  ELSE.
    lv_subrc = 1.
  ENDIF.

  CASE lv_subrc.
    WHEN 0.
      fc_type    = 'S'.
      fc_message = 'Shipment already completed'.
    WHEN 1.
      fc_type    = 'E'.
      fc_message = 'Unloading Start and End must be entry'.
    WHEN 4.
      fc_type    = 'E'.
      fc_message = 'Process error'.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_LOADING_RELEASE
*&---------------------------------------------------------------------*
FORM f_proses_loading_release  TABLES   pt_load STRUCTURE zwmsst008
                               USING    p_json
                               CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_loadrel   TYPE ty_loadrel,
         lt_loadd     TYPE STANDARD TABLE OF zwmsst008,
         ls_loadd     LIKE LINE OF lt_loadd,
         lt_x003      TYPE STANDARD TABLE OF zwmdt003,
         lt_y003      TYPE STANDARD TABLE OF zwmdt003,
         ls_003       TYPE zwmdt003,
         ls_x003      TYPE zwmdt003,
         lt_xvttp     TYPE STANDARD TABLE OF zwmdt003,
         ls_xvttp     TYPE vttp,
         ls_xlikp     TYPE likp.

  DATA : lv_start    TYPE string,
         lv_end      TYPE string,
         lv_complete TYPE c LENGTH 1,
         lv_subrc    TYPE sy-subrc,
         lv_line1    TYPE i,
         lv_line2    TYPE i,
         lv_line3    TYPE i,
         lv_message  TYPE c LENGTH 220.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_loadrel ).

  lt_loadd[] = ls_loadrel-nav_load[].

  ls_003-tknum    = ls_loadrel-shipment_number.

  LOOP AT lt_loadd INTO ls_loadd.
    ls_003-vbeln    = ls_loadd-delivery_number.
    ls_003-rernam   = ls_loadd-user_name.
    ls_003-rpcont   = ls_loadd-koli_ori.
    ls_003-rpsonst  = ls_loadd-koli_ecer.
    ls_003-name1    = ls_loadd-security_name.

    IF ls_loadd-release_start IS NOT INITIAL.
      PERFORM f_datetime USING ls_loadd-release_start
                         CHANGING ls_003-rdalbg ls_003-rualbg.
      PERFORM f_datetime USING ls_loadd-release_end
                         CHANGING ls_003-rdalen ls_003-rualen.
    ENDIF.


    IF ls_loadd-complete_start IS NOT INITIAL.
      PERFORM f_datetime USING ls_loadd-complete_start
                         CHANGING ls_003-dalbg ls_003-ualbg.
      PERFORM f_datetime USING ls_loadd-complete_end
                         CHANGING ls_003-dalen ls_003-ualen.
    ENDIF.

    SELECT *
      FROM vttp
      INTO CORRESPONDING FIELDS OF TABLE lt_xvttp
      WHERE tknum = ls_003-tknum.

    SELECT *
      FROM zwmdt003
      INTO CORRESPONDING FIELDS OF TABLE lt_x003
      WHERE tknum = ls_003-tknum.

    DESCRIBE TABLE lt_xvttp LINES lv_line1.
    DESCRIBE TABLE lt_x003 LINES lv_line2.

* Check shipment complete
    IF lv_subrc = 0.
      IF lv_line2 <> 0.
        CLEAR ls_x003.
        LOOP AT lt_x003 INTO ls_x003 WHERE frgkz IS NOT INITIAL.
          lv_subrc = 2.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDIF.

* Check all delivery already save
    IF lv_subrc = 0.
      IF lv_line1 <> lv_line2.
        IF lv_complete IS NOT INITIAL.
          lv_subrc = 3.
        ELSE.
* Check security
          IF ls_003-name1 IS INITIAL.
            lv_subrc = 7.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_subrc = 0.
      IF lv_complete IS INITIAL.
        CLEAR : ls_xvttp.
        READ TABLE lt_xvttp INTO ls_xvttp
                            WITH KEY tknum = ls_003-tknum
                                     vbeln = ls_003-vbeln.
        IF sy-subrc = 0.
          READ TABLE lt_x003 INTO ls_x003
                             WITH KEY tknum = ls_003-tknum
                                      vbeln = ls_003-vbeln.
          IF sy-subrc = 0.
          ELSE.
* Chack koli
            IF lv_subrc = 0.
              IF lv_complete IS INITIAL.
                SELECT SINGLE *
                  FROM likp
                  INTO CORRESPONDING FIELDS OF ls_xlikp
                  WHERE vbeln = ls_003-vbeln.
                IF sy-subrc = 0.
                  IF ls_xlikp-/bev1/rpcont <> ls_003-rpcont OR
                    ls_xlikp-/bev1/rpsonst <> ls_003-rpsonst.
                    lv_subrc = 5.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_subrc = 0.
              TRY .
                  INSERT zwmdt003 FROM ls_003.
                CATCH cx_sy_open_sql_db.
                  lv_subrc  = 4.
              ENDTRY.
            ENDIF.
          ENDIF.
        ELSE.
          lv_subrc = 1.
        ENDIF.
      ENDIF.

      COMMIT WORK AND WAIT.

      SELECT *
        FROM zwmdt003
        INTO CORRESPONDING FIELDS OF TABLE lt_y003
        WHERE tknum = ls_003-tknum.

      DESCRIBE TABLE lt_y003 LINES lv_line3.
      IF lv_line1 = lv_line3.
        CLEAR : ls_xvttp.
        READ TABLE lt_xvttp INTO ls_xvttp
                            WITH KEY tknum = ls_003-tknum.
        IF sy-subrc = 0.
          READ TABLE lt_x003 INTO ls_x003
                             WITH KEY tknum = ls_003-tknum.
          IF sy-subrc = 0.
            ls_003-ernam    = ls_loadd-user_name.
            lv_complete = 'X'.
            TRY .
                UPDATE zwmdt003 SET frgkz = lv_complete
*                                    dalbg = ls_003-dalbg
*                                    ualbg = ls_003-ualbg
*                                    dalen = ls_003-dalen
*                                    ualen = ls_003-ualen
*                                    ernam = ls_003-ernam
                                WHERE tknum = ls_003-tknum.
              CATCH cx_sy_open_sql_db.
                lv_subrc  = 6.
            ENDTRY.
            IF lv_subrc = 0.
              PERFORM f_open_block_putaway TABLES lt_y003.
            ENDIF.

*            IF lv_subrc = 0.
*              PERFORM f_shipment_loading USING ls_003-tknum
*                                               ls_003-dalbg
*                                               ls_003-ualbg
*                                               ls_003-dalen
*                                               ls_003-ualen
*                                         CHANGING lv_subrc.
*            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE lv_subrc.
      WHEN 0.
        ls_loadd-type    = 'S'.
        IF lv_complete IS INITIAL.
          ls_loadd-message = 'Already saved'.
        ELSE.
          ls_loadd-message = 'Release shipment completed'.
        ENDIF.
      WHEN 1.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Shipment number not found'.
      WHEN 2.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Shipment already completed'.
      WHEN 3.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Shipment not yet complete'.
      WHEN 4.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Release shipment error'.
      WHEN 5.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Error in Koli'.
      WHEN 6.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Complete shipment error'.
      WHEN 7.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Security name blank'.
      WHEN 8.
        ls_loadd-type    = 'E'.
        ls_loadd-message = 'Shipment cannot be changed'.
    ENDCASE.
    APPEND ls_loadd TO pt_load.
    CLEAR ls_loadd.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHIPMENT_LOADING
*&---------------------------------------------------------------------*
FORM f_shipment_loading USING fu_tknum fu_dalbg fu_ualbg fu_dalen fu_ualen
                        CHANGING fc_subrc.
  DATA: headerdata       LIKE bapishipmentheader,
        headerdataaction LIKE bapishipmentheaderaction,
        return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        ls_return        LIKE LINE OF return.

  headerdata-shipment_num            = fu_tknum.
  headerdata-status_load_start       = 'X'.
  headerdata-status_load_end         = 'X'.
  headerdataaction-status_load_start = 'C'.
  headerdataaction-status_load_end   = 'C'.

  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      headerdata       = headerdata
      headerdataaction = headerdataaction
    TABLES
      return           = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'E'.
      fc_subrc  = 8.
    ENDIF.
  ENDLOOP.

  IF fc_subrc IS INITIAL.
    UPDATE vttk SET dalen = fu_dalen
                    ualen = fu_ualen
                    dalbg = fu_dalbg
                    ualbg = fu_ualbg
                WHERE tknum  = fu_tknum.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = return.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_MATERIAL
*&---------------------------------------------------------------------*
FORM f_new_material USING fu_matnr
                    CHANGING fc_type fc_message.
  DATA : ls_mara    TYPE mara.

  SELECT SINGLE *
    FROM mara
    INTO CORRESPONDING FIELDS OF ls_mara
    WHERE matnr = fu_matnr.
  IF sy-subrc = 0.
    fc_type = 'S'.
    fc_message = 'New material saved'.
  ELSE.
    fc_type = 'E'.
    fc_message = 'Material not found'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PICKING
*&---------------------------------------------------------------------*
FORM f_proses_picking  TABLES   pt_picking STRUCTURE zwmsst002
                       USING    p_json
                       CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_picking   TYPE ty_picking,
         lt_pickd     TYPE STANDARD TABLE OF zwmsst002,
         lt_pickd_add TYPE STANDARD TABLE OF zwmsst002,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         ls_pickd     LIKE LINE OF lt_pickd,
         ls_ltap_conf LIKE LINE OF lt_ltap_conf,
         ls_rl03t     TYPE rl03t,
         lt_ltak      TYPE STANDARD TABLE OF ltak,
         ls_ltak      TYPE ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      LIKE LINE OF lt_ltap,
         ls_xltap     LIKE LINE OF lt_ltap,
         lt_xltapa    TYPE STANDARD TABLE OF ltap,
         ls_xltapa    LIKE LINE OF lt_xltapa,
         lt_result    TYPE STANDARD TABLE OF ltak,
         lt_detail    TYPE STANDARD TABLE OF zmfindpick,
         ls_header    TYPE zmfindpick.

  DATA : lv_subrc        TYPE sy-subrc,
         lv_qdatu        TYPE ltap-qdatu,
         lv_qzeit        TYPE ltap-qzeit,
         lv_edatu        TYPE ltap-edatu,
         lv_ezeit        TYPE ltap-ezeit,
         lv_uname        TYPE sy-uname,
         lv_vsolm        TYPE ltap-vsolm,
         lv_altme        TYPE ltap-altme,
         lv_length       TYPE i,
         lv_xsolm        TYPE ltap-vsolm,
         lv_message(220),
         lv_tanum        TYPE ltak-tanum,
         lv_drukz        TYPE ltak-drukz.
  DATA: lr_queue    TYPE RANGE OF queue,
        ls_queue    LIKE LINE OF lr_queue,
        lv_queue    TYPE queue,
        lv_akhir(1).

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_picking ).
  lt_pickd[] = ls_picking-nav_confpick[].

  LOOP AT ls_picking-nav_confpick INTO ls_pickd.
    IF ls_pickd-user_name IS NOT INITIAL.
      DATA(lv_user_name) = ls_pickd-user_name.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_user_name IS NOT INITIAL.
    CLEAR : lr_queue[].
    ls_queue-low    = 'PICKER*AB'.
    ls_queue-sign   = 'I'.
    ls_queue-option = 'CP'.
    APPEND ls_queue TO lr_queue.
    CLEAR ls_queue.
    ls_queue-low    = 'PICKER*AC'.
    ls_queue-sign   = 'I'.
    ls_queue-option = 'CP'.
    APPEND ls_queue TO lr_queue.
    CLEAR ls_queue.

    SELECT SINGLE queue INTO lv_queue FROM lrf_wkqu
      WHERE bname = lv_user_name
        AND statu = 'X'
        AND queue IN lr_queue.
    IF sy-subrc EQ 0.
      lv_akhir = 'X'.
      lv_length = strlen( ls_picking-to_number ).
      IF lv_length = 15.
        SELECT *
          FROM ltak
          INTO CORRESPONDING FIELDS OF TABLE lt_ltak
          WHERE lgnum = ls_picking-warehouse_number
            AND lznum = ls_picking-to_number.
      ELSE.
        SELECT *
          FROM ltak
          INTO CORRESPONDING FIELDS OF TABLE lt_ltak
          WHERE lgnum = ls_picking-warehouse_number
            AND tanum = ls_picking-to_number.
      ENDIF.
      IF lt_ltak[] IS NOT INITIAL.
        SELECT *
          FROM ltap
          INTO CORRESPONDING FIELDS OF TABLE lt_ltap
          FOR ALL ENTRIES IN lt_ltak
          WHERE lgnum = lt_ltak-lgnum
            AND tanum = lt_ltak-tanum.

        lt_xltapa[] = lt_ltap[].

        SORT lt_xltapa BY tapos matnr charg vltyp vlpla.
        DELETE ADJACENT DUPLICATES FROM lt_xltapa COMPARING tanum tapos matnr charg vltyp vlpla.
        LOOP AT lt_xltapa INTO ls_xltapa.
          CLEAR : ls_pickd.
          READ TABLE lt_pickd INTO ls_pickd
                              WITH KEY material_number = ls_xltapa-matnr
                                       batch           = ls_xltapa-charg
                                      " to_item = ls_xltapa-tapos
                                       storage_type    = ls_xltapa-vltyp
                                       storage_bin     = ls_xltapa-vlpla.
          IF sy-subrc = 0.
            CLEAR : lv_qdatu, lv_qzeit, lv_edatu, lv_ezeit, lv_uname.
            PERFORM f_datetime USING ls_pickd-picking_start
                               CHANGING lv_qdatu lv_qzeit.
            PERFORM f_datetime USING ls_pickd-picking_end
                               CHANGING lv_edatu lv_ezeit.
            lv_uname = ls_pickd-user_name.

            IF ls_xltapa-pvqui IS INITIAL.

            ENDIF.

            TRY .
                UPDATE ltap SET qdatu = lv_qdatu
                                qzeit = lv_qzeit
                                qname = lv_uname
                                edatu = lv_edatu
                                ezeit = lv_ezeit
                                ename = lv_uname
                                zrstg = 'X'
                            WHERE lgnum = ls_xltapa-lgnum
                              AND tanum = ls_xltapa-tanum
                             "  AND tapos = ls_xltapa-tapos
                              AND matnr = ls_xltapa-matnr
                              AND charg = ls_xltapa-charg
                              AND vltyp = ls_xltapa-vltyp
                              AND vlpla = ls_xltapa-vlpla.
              CATCH cx_sy_open_sql_db.
                lv_subrc = 4.
            ENDTRY.

            IF lv_subrc = 0.
              ls_pickd-type = 'S'.
              ls_pickd-message = 'Confirm success'.

              IF lv_length = 15.
                SELECT lgnum, tanum, tapos, zrstg
                  INTO TABLE @DATA(lt_ltap_temp)
                  FROM ltap FOR ALL ENTRIES IN @lt_ltak
                  WHERE lgnum = @lt_ltak-lgnum
                    AND tanum = @lt_ltak-tanum.

***                IF line_exists( lt_ltap_temp[ zrstg = space ] ).
***                ELSE.
***                  PERFORM f_print_to_akhir USING ls_xltapa-tanum ls_xltapa-lgnum
***                                 CHANGING ls_xltapa-vltyp ls_xltapa-vlpla.
***                ENDIF.
              ELSE.
***                PERFORM f_print_to_akhir USING ls_xltapa-tanum ls_xltapa-lgnum
***                               CHANGING ls_xltapa-vltyp ls_xltapa-vlpla.
              ENDIF.

            ELSE.
              ls_pickd-type = 'E'.
              ls_pickd-message = 'Confirm error'.
            ENDIF.
            MODIFY lt_pickd FROM ls_pickd
                            TRANSPORTING type message
                            WHERE material_number = ls_xltapa-matnr
                              AND batch           = ls_xltapa-charg
*                              AND to_item = ls_xltapa-tapos
                              AND storage_type    = ls_xltapa-vltyp
                              AND storage_bin     = ls_xltapa-vlpla.
            "            append ls_pickd to lt_pickd_add.
            CLEAR ls_pickd.
          ENDIF.
        ENDLOOP.
        pt_picking[] = lt_pickd[].
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.



  lv_length = strlen( ls_picking-to_number ).
  IF lv_length = 15.
    PERFORM f_post_group_picking TABLES pt_picking
                                        lt_pickd
                                 USING ls_picking-warehouse_number
                                       ls_picking-to_number
                                       ls_picking-delivery_number
                                 CHANGING fc_type fc_message lv_drukz.
    CASE ls_picking-warehouse_number.
      WHEN 'C40'.
        IF lv_drukz IS NOT INITIAL.
          PERFORM f_print_grouping TABLES pt_picking
                                   USING lv_drukz ls_picking-warehouse_number
                                         '' ls_picking-to_number 'X'.
        ENDIF.
    ENDCASE.
  ELSEIF lv_length = 10.
    lv_tanum = ls_picking-to_number.
    SELECT SINGLE *
      FROM ltak
      INTO CORRESPONDING FIELDS OF ls_ltak
      WHERE lgnum = ls_picking-warehouse_number
        AND tanum = lv_tanum.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      WHERE lgnum = ls_picking-warehouse_number
        AND tanum = lv_tanum.

    LOOP AT lt_pickd INTO ls_pickd.
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
        CLEAR : ls_ltap.
        READ TABLE lt_ltap INTO ls_ltap
                           WITH KEY tapos = ls_pickd-to_item.
        IF sy-subrc = 0.
          PERFORM f_quantity_calculate USING ls_picking-warehouse_number
                                             ls_ltap-matnr ls_ltap-charg
                                             ls_pickd-quantity_satuan
                                             ls_pickd-uom_satuan
                                             ls_pickd-quantity_carton
                                             ls_pickd-uom_carton
                                       CHANGING lv_vsolm.
        ENDIF.

        CLEAR : ls_xltap.
        LOOP AT lt_ltap INTO ls_xltap WHERE matnr = ls_ltap-matnr
                                        AND charg = ls_ltap-charg
                                        AND vlpla = ls_ltap-vlpla.
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

          ls_ltap_conf-tanum = lv_tanum.
          ls_ltap_conf-tapos = ls_xltap-tapos.   "ls_pickd-to_item.
          APPEND ls_ltap_conf TO lt_ltap_conf.
          CLEAR ls_ltap_conf.
        ENDLOOP.

        ls_rl03t-squit = space.
        IF ls_ltak-kgvnq = 'X'.
          ls_rl03t-quknz = '1'.
        ENDIF.
*    ls_rl03t-komim = '1'.
        PERFORM f_to_confirm TABLES lt_ltap_conf
                                    pt_picking
                             USING ls_picking-warehouse_number
                                   lv_tanum
                                   ls_ltap-nltyp
                                   ls_pickd
                                   ls_rl03t
                                   ls_ltak-queue
                             CHANGING lv_subrc.
        IF lv_subrc = 0.
          IF ls_ltak-queue = 'CHECKER'.
          ELSE.
            IF ls_ltak-stdat IS INITIAL.
              TRY.
                  UPDATE ltak SET stdat = lv_qdatu
                                  stuzt = lv_qzeit
                              WHERE lgnum = ls_picking-warehouse_number
                                AND tanum = lv_tanum.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
            ENDIF.

            TRY .
                UPDATE ltap SET edatu = lv_edatu
                                ezeit = lv_ezeit
                                ename = lv_uname
                            WHERE tanum = lv_tanum
                              AND vlpla = ls_pickd-storage_bin
                              AND lgnum = ls_picking-warehouse_number.
              CATCH cx_sy_open_sql_db.
            ENDTRY.
          ENDIF.

          IF ls_ltak-druck IS INITIAL.
            CASE ls_picking-warehouse_number.
              WHEN 'C40'.
                PERFORM f_print_grouping TABLES pt_picking
                                         USING '47' ls_picking-warehouse_number
                                               ls_ltak-tanum '' 'X'.
            ENDCASE.
          ENDIF.
        ENDIF.
      ELSE.
        ls_pickd-type     = 'E'.
        ls_pickd-message  = 'Input quantity salah'.
        APPEND ls_pickd TO pt_picking.
        fc_type    = 'E'.
        fc_message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TO_CONFIRM
*&---------------------------------------------------------------------*
FORM f_to_confirm  TABLES   ft_ltap_conf STRUCTURE ltap_conf
                            ft_picking STRUCTURE zwmsst002
                   USING    fu_lgnum fu_tanum fu_nltyp
                            fs_pickd STRUCTURE zwmsst002
                            fs_rl03t STRUCTURE rl03t
                            fu_queue
                   CHANGING fc_subrc.
  DATA : ls_picking TYPE zwmsst002,
         ls_013     TYPE zwmdt013,
         rspar_tab  TYPE TABLE OF rsparams,
         ls_reason  TYPE ltak.

  MOVE-CORRESPONDING fs_pickd TO ls_picking.

  IF fu_queue NP '*AB'.
    TRY.
        CALL FUNCTION 'L_TO_CONFIRM'
          EXPORTING
            i_lgnum                        = fu_lgnum
            i_tanum                        = fu_tanum
            i_squit                        = fs_rl03t-squit
            i_quknz                        = fs_rl03t-quknz
*           i_komim                        = fs_rl03t-komim
          TABLES
            t_ltap_conf                    = ft_ltap_conf
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
            error_message                  = 99.
      CATCH cx_root INTO DATA(lo_root_exception).
    ENDTRY.
    IF lo_root_exception IS NOT INITIAL.
      sy-subrc = 98.
    ENDIF.
  ENDIF.
  fc_subrc = sy-subrc.
  IF sy-subrc = 0.
    ls_picking-type    = 'S'.
    ls_picking-message = 'TO already confirm'.

    IF fu_lgnum = '190'.
      SELECT SINGLE *
        FROM zwmdt013
        INTO CORRESPONDING FIELDS OF ls_013
        WHERE lgnum   = fu_lgnum
          AND process = 'PRINT_TO'.

      IF ls_013-active IS NOT INITIAL.
        PERFORM f_submit_parameter TABLES rspar_tab
                                   USING : 'PA_LGNUM' fu_lgnum 'P',
                                           'SO_LGTYP-LOW' fu_nltyp 'P',
                                           'SO_TANUM-LOW' fu_tanum 'P',
                                           'PA_FORM' 'X' 'P',
                                           'PA_DRUKZ' '47' 'P'.
        SUBMIT zwm_print_to WITH SELECTION-TABLE rspar_tab AND RETURN.
        CLEAR : rspar_tab[].
      ENDIF.
    ENDIF.
  ELSE.
    ls_picking-type = 'E'.

    CALL FUNCTION 'ZWMSFM002'
      EXPORTING
        pi_subrc    = fc_subrc
        pi_function = 'L_TO_CONFIRM'
      IMPORTING
        pe_message  = ls_picking-message.
  ENDIF.
  APPEND ls_picking TO ft_picking.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DATETIME
*&---------------------------------------------------------------------*
FORM f_datetime  USING    fu_value
                 CHANGING fc_datum fc_uzeit.
  DATA : lv_value   TYPE string.

  SPLIT fu_value AT space INTO fc_datum lv_value.

  TRANSLATE lv_value USING ': '.
  CONDENSE lv_value NO-GAPS.
  fc_uzeit  = lv_value.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_QUANTITY_CALCULATE
*&---------------------------------------------------------------------*
FORM f_quantity_calculate  USING    fu_lgnum fu_matnr fu_charg fu_satuan
                                    fu_suom fu_carton fu_cuom
                           CHANGING fc_vsolm.
  DATA : ls_marm    TYPE marm.

  DATA : lv_meins     TYPE mara-meins,
         lv_mtart     TYPE mara-mtart,
         lv_umrez(10).

  CLEAR : fc_vsolm.

  SELECT SINGLE mtart
    FROM mara
    INTO lv_mtart
    WHERE matnr = fu_matnr.

  CASE lv_mtart.
    WHEN 'ZRM' OR 'ZPM'.
      TRY.
          CLEAR: lv_umrez.
          CALL FUNCTION 'ZWMFM009'
            EXPORTING
              pi_lgnum = fu_lgnum
              pi_matnr = fu_matnr
              pi_charg = fu_charg
              pi_mtart = lv_mtart
            IMPORTING
              pe_value = lv_umrez.
        CATCH cx_root INTO DATA(lo_root_exception).
      ENDTRY.
      fc_vsolm = fu_satuan + ( fu_carton * lv_umrez ).
  ENDCASE.

  IF fc_vsolm = 0.
    IF fu_cuom IS INITIAL.
      lv_meins  = 'KAR'.
    ELSE.
      PERFORM f_unit_conversion_input USING fu_cuom
                                      CHANGING lv_meins.
    ENDIF.
    SELECT SINGLE *
      FROM marm
      INTO CORRESPONDING FIELDS OF ls_marm
      WHERE matnr = fu_matnr
        AND meinh = lv_meins.
    IF sy-subrc = 0.
      fc_vsolm = fu_satuan + ( ( fu_carton * ls_marm-umrez ) / ls_marm-umren ).
    ELSE.
      fc_vsolm = fu_satuan + fu_carton.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION_INPUT
*&---------------------------------------------------------------------*
FORM f_unit_conversion_input  USING    fu_value
                              CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = fu_value
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    fc_meins = fu_value.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PICKING_COMPLETE
*&---------------------------------------------------------------------*
FORM f_proses_picking_complete  TABLES   pt_picking STRUCTURE zwmsst003
                                USING    p_json
                                CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_picking   TYPE ty_pickcmpl,
         lt_pickd     TYPE STANDARD TABLE OF zwmsst003,
         ls_pickd     LIKE LINE OF lt_pickd,
         lt_xpickd    TYPE STANDARD TABLE OF zwmsst003,
         ls_xpickd    LIKE LINE OF lt_xpickd.

  DATA : lv_queue  TYPE ltak-queue,
         lv_xqueue TYPE ltak-queue,
         lv_tanum  TYPE ltak-tanum,
         lv_lznum  TYPE ltak-lznum,
         lv_vbeln  TYPE ltak-vbeln,
         lv_subrc  TYPE sy-subrc,
         lv_length TYPE i.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_picking ).

  lt_pickd[] = ls_picking-nav_cmplpick[].
  lv_queue   = 'CHECKER'.

  lt_xpickd[] = lt_pickd[].
  SORT lt_xpickd BY to_number.
  DELETE ADJACENT DUPLICATES FROM lt_xpickd COMPARING to_number.
  READ TABLE lt_xpickd INTO ls_xpickd INDEX 1.
  lv_length = strlen( ls_xpickd-to_number ).

  IF lv_length <> 10.
    lv_lznum  = ls_xpickd-to_number.
  ENDIF.

  IF lt_xpickd[] IS NOT INITIAL.
    LOOP AT lt_xpickd INTO ls_xpickd.
      lv_tanum  = ls_xpickd-to_number.

      SELECT SINGLE queue
        FROM ltak
        INTO lv_xqueue
        WHERE lgnum = ls_picking-warehouse_number
          AND tanum = lv_tanum.

      IF lv_xqueue CP '*AB'.
        lv_queue = lv_xqueue.
        REPLACE ALL OCCURRENCES OF lv_queue(sy-fdpos) IN lv_queue WITH 'CHECKER'.
      ENDIF.

*      TRY .
*          UPDATE ltak SET queue = lv_queue
*                WHERE lgnum = ls_picking-warehouse_number
*                  AND tanum = lv_tanum.
*        CATCH cx_sy_open_sql_db.
*          lv_subrc = 4.
*      ENDTRY.

      IF lv_subrc = 0.
        ls_pickd-type = 'S'.
        ls_pickd-message = 'Data already completed'.
      ELSE.
        ls_pickd-type = 'E'.
        ls_pickd-message = 'Error in completed data'.
      ENDIF.
      MODIFY lt_pickd FROM ls_pickd
                      TRANSPORTING type message
                      WHERE to_number = ls_xpickd-to_number.
    ENDLOOP.
  ENDIF.

  IF lv_subrc = 0.
    IF lv_length = 10.
      lt_xpickd[] = lt_pickd[].
      SORT lt_xpickd BY delivery_number.
      DELETE ADJACENT DUPLICATES FROM lt_xpickd COMPARING delivery_number.
      IF lt_xpickd[] IS NOT INITIAL.
        LOOP AT lt_xpickd INTO ls_xpickd.
          lv_vbeln = ls_xpickd-delivery_number.
          TRY .
              UPDATE likp SET /bev1/rpfaess  = ls_xpickd-koli_ori
                              /bev1/rpkist   = ls_xpickd-koli_ecer
                          WHERE vbeln = lv_vbeln.
            CATCH cx_sy_open_sql_db.
              lv_subrc = 4.
          ENDTRY.

          IF lv_subrc = 0.
            ls_pickd-type = 'S'.
            ls_pickd-message = 'Data already completed'.
          ELSE.
            ls_pickd-type = 'E'.
            ls_pickd-message = 'Error in completed data'.
          ENDIF.
          MODIFY lt_pickd FROM ls_pickd
                          TRANSPORTING type message
                          WHERE delivery_number = ls_xpickd-delivery_number.
          CLEAR lv_subrc.
        ENDLOOP.
      ENDIF.
    ELSE.
      PERFORM f_picking_complete_grouping TABLES lt_pickd
                                          USING ls_picking-warehouse_number
                                                lv_lznum
                                                ls_xpickd-koli_ori
                                                ls_xpickd-koli_ecer.
    ENDIF.
  ENDIF.

  pt_picking[] = lt_pickd[].
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_UNLOADING_RUSAK
*&---------------------------------------------------------------------*
FORM f_proses_unloading_rusak  TABLES   ft_to STRUCTURE zwmsst001
                                        ft_mlgn STRUCTURE mlgn
                               USING    fs_shipdata     TYPE ty_shipment
                                        fs_shipdetail   TYPE ty_shipdetail
                                        fs_shipment     TYPE ty_shipment
                                        fu_lgnum fu_werks fu_pallet fu_itemid fu_uname
                                        fu_rusak fu_zdtsul fu_zuzsul fu_zdteul fu_zuzeul
                               CHANGING fc_type fc_message.
  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004.

  DATA : lv_lgnum  TYPE ltak-lgnum,
         lv_bwlvs  TYPE ltak-bwlvs,
         lv_betyp  TYPE ltak-betyp,
         lv_benum  TYPE ltak-benum,
         lv_lznum  TYPE ltak-lznum,
         lv_drukz  TYPE t329f-drukz,
         lv_commit TYPE rl03b-comit,
         lv_lfimg  TYPE zwmdt004-lfimg,
         lv_anfme  TYPE ltap_creat-anfme,
         lv_add    TYPE c LENGTH 1,
         lv_sisa   TYPE mlgn-lhmg1,
         lv_tanum  TYPE ltak-tanum,
         lv_subrc  TYPE sy-subrc,
         lv_save   TYPE sy-subrc,
         lv_nltyp  TYPE ltap-nltyp,
         lv_nlpla  TYPE ltap-nlpla.

  lv_lgnum  = fu_lgnum.
  lv_bwlvs  = '101'.
  lv_betyp  = 'Z'.
  lv_benum  = fs_shipment-vbeln.
  CONCATENATE fu_pallet fs_shipdata-tknum INTO lv_lznum SEPARATED BY ';'.
  "  lv_lznum  = fu_pallet.
  lv_drukz  = '45'.
  lv_commit = space.

  PERFORM f_prepare_detail TABLES lt_ltap_creat ft_mlgn
                           USING fs_shipdata fs_shipment fu_werks lv_lznum fs_shipdata-lfimg
                                 'RUSAK' '' lv_lgnum
                           CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                    lv_sisa lv_add.

  PERFORM f_create_to TABLES lt_ltap_creat
                      USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                            lv_lznum lv_drukz lv_commit
                      CHANGING lv_tanum lv_subrc.

  IF lv_tanum IS NOT INITIAL.
    fc_type    = 'S'.
    fc_message = 'Create TO success'.

    PERFORM f_save_004 TABLES lt_004
                       USING lv_tanum lv_lgnum lv_lznum
                             fu_uname 'RUSAK' fu_rusak '' fu_zdtsul fu_zuzsul
                             fu_zdteul fu_zuzeul
                             fs_shipdata fs_shipment ls_ltap_creat
                       CHANGING lv_save.
    IF lv_save = 0.
      PERFORM f_print_to USING lv_tanum lv_lgnum
                         CHANGING lv_nltyp lv_nlpla.
    ENDIF.
    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet lv_tanum lv_nlpla
                                  'RUSAK' fc_type fc_message.
  ELSE.
    fc_type    = 'E'.
    CALL FUNCTION 'ZWMSFM002'
      EXPORTING
        pi_subrc    = lv_subrc
        pi_function = 'L_TO_CREATE_MULTIPLE'
      IMPORTING
        pe_message  = fc_message.

    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet '' ''
                                  '' fc_type fc_message.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_UNLOADING_ZERO
*&---------------------------------------------------------------------*
FORM f_proses_unloading_zero  TABLES   ft_to STRUCTURE zwmsst001
                                       ft_mlgn STRUCTURE mlgn
                              USING    fs_shipdata     TYPE ty_shipment
                                       fs_shipdetail   TYPE ty_shipdetail
                                       fs_shipment     TYPE ty_shipment
                                       fu_lgnum fu_werks fu_pallet fu_itemid fu_uname
                                       fu_rusak fu_zdtsul fu_zuzsul
                                       fu_zdteul fu_zuzeul
                              CHANGING fc_type fc_message.
  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004.

  DATA : lv_lgnum TYPE ltak-lgnum,
         lv_lznum TYPE ltak-lznum,
         lv_save  TYPE sy-subrc,
         lv_tanum TYPE ltak-tanum,
         lv_nlpla TYPE ltap-nlpla.

  lv_lgnum  = fu_lgnum.
  lv_lznum  = fu_pallet.

  PERFORM f_save_004 TABLES lt_004
                     USING '' lv_lgnum lv_lznum
                           fu_uname 'ZERO' fu_rusak ''
                           fu_zdtsul fu_zuzsul fu_zdteul fu_zuzeul
                           fs_shipdata fs_shipment ls_ltap_creat
                     CHANGING lv_save.
  IF lv_save = 0.
    fc_type    = 'S'.
    fc_message = 'Data already saved'.
  ELSE.
    fc_type    = 'E'.
    fc_message = 'Duplicated data/error data'.
  ENDIF.

  ls_ltap_creat-matnr    = fs_shipdata-matnr.
  ls_ltap_creat-charg    = fs_shipdata-charg.
  ls_ltap_creat-anfme   = 0.
  ls_ltap_creat-altme    = fs_shipdata-vrkme.

  PERFORM f_body_response TABLES ft_to
                          USING ls_ltap_creat
                                fu_itemid fu_pallet '' ''
                                'ZERO' fc_type fc_message.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_UNLOADING_NEWBATCH
*&---------------------------------------------------------------------*
FORM f_proses_unloading_newbatch  TABLES   ft_to STRUCTURE zwmsst001
                                           ft_mlgn STRUCTURE mlgn
                                  USING    fs_shipdata     TYPE ty_shipment
                                           fs_shipdetail   TYPE ty_shipdetail
                                           fs_shipment     TYPE ty_shipment
                                           fu_lgnum fu_werks fu_pallet fu_itemid fu_uname
                                           fu_rusak fu_zdtsul fu_zuzsul
                                           fu_zdteul fu_zuzeul
                                  CHANGING fc_type fc_message.
  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004.

  DATA : lv_lgnum  TYPE ltak-lgnum,
         lv_bwlvs  TYPE ltak-bwlvs,
         lv_betyp  TYPE ltak-betyp,
         lv_benum  TYPE ltak-benum,
         lv_lznum  TYPE ltak-lznum,
         lv_drukz  TYPE t329f-drukz,
         lv_commit TYPE rl03b-comit,
         lv_lfimg  TYPE zwmdt004-lfimg,
         lv_anfme  TYPE ltap_creat-anfme,
         lv_add    TYPE c LENGTH 1,
         lv_sisa   TYPE mlgn-lhmg1,
         lv_tanum  TYPE ltak-tanum,
         lv_subrc  TYPE sy-subrc,
         lv_save   TYPE sy-subrc,
         lv_nltyp  TYPE ltap-nltyp,
         lv_nlpla  TYPE ltap-nlpla.

  lv_lgnum  = fu_lgnum.
  lv_bwlvs  = '101'.
  lv_betyp  = 'Z'.
  lv_benum  = fs_shipdata-tknum.
  CONCATENATE fu_pallet fs_shipdata-tknum INTO lv_lznum SEPARATED BY ';'.
  "  lv_lznum  = fu_pallet.
  lv_drukz  = '45'.
  lv_commit = space.

  PERFORM f_prepare_detail TABLES lt_ltap_creat ft_mlgn
                           USING fs_shipdata fs_shipment fu_werks lv_lznum fs_shipdata-lfimg
                                 'NEWCH'  '' lv_lgnum
                           CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                    lv_sisa lv_add.

  PERFORM f_create_to TABLES lt_ltap_creat
                      USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                            lv_lznum lv_drukz lv_commit
                      CHANGING lv_tanum lv_subrc.

  IF lv_tanum IS NOT INITIAL.
    fc_type    = 'S'.
    fc_message = 'Create TO success'.

    PERFORM f_save_004 TABLES lt_004
                       USING lv_tanum lv_lgnum lv_lznum
                             fu_uname 'NEWCH' fu_rusak ''
                             fu_zdtsul fu_zuzsul fu_zdteul fu_zuzeul
                             fs_shipdata fs_shipment ls_ltap_creat
                       CHANGING lv_save.
    IF lv_save = 0.
      PERFORM f_print_to USING lv_tanum lv_lgnum
                         CHANGING lv_nltyp lv_nlpla.
    ENDIF.
    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet lv_tanum lv_nlpla
                                  'NEWCH' fc_type fc_message.
  ELSE.
    fc_type    = 'E'.
    CALL FUNCTION 'ZWMSFM002'
      EXPORTING
        pi_subrc    = lv_subrc
        pi_function = 'L_TO_CREATE_MULTIPLE'
      IMPORTING
        pe_message  = fc_message.

    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet '' ''
                                  '' fc_type fc_message.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION_OUTPUT
*&---------------------------------------------------------------------*
FORM f_unit_conversion_output  USING    fu_value
                               CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_value
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_UNLOADING_NEWMATERIAL
*&---------------------------------------------------------------------*
FORM f_proses_unloading_newmaterial  TABLES   ft_to STRUCTURE zwmsst001
                                           ft_mlgn STRUCTURE mlgn
                                  USING    fs_shipdata     TYPE ty_shipment
                                           fs_shipdetail   TYPE ty_shipdetail
                                           fs_shipment     TYPE ty_shipment
                                           fu_lgnum fu_werks fu_pallet fu_itemid fu_uname
                                           fu_rusak fu_zdtsul fu_zuzsul
                                           fu_zdteul fu_zuzeul
                                  CHANGING fc_type fc_message.
  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004.

  DATA : lv_lgnum  TYPE ltak-lgnum,
         lv_bwlvs  TYPE ltak-bwlvs,
         lv_betyp  TYPE ltak-betyp,
         lv_benum  TYPE ltak-benum,
         lv_lznum  TYPE ltak-lznum,
         lv_drukz  TYPE t329f-drukz,
         lv_commit TYPE rl03b-comit,
         lv_lfimg  TYPE zwmdt004-lfimg,
         lv_anfme  TYPE ltap_creat-anfme,
         lv_add    TYPE c LENGTH 1,
         lv_sisa   TYPE mlgn-lhmg1,
         lv_tanum  TYPE ltak-tanum,
         lv_subrc  TYPE sy-subrc,
         lv_save   TYPE sy-subrc,
         lv_nltyp  TYPE ltap-nltyp,
         lv_nlpla  TYPE ltap-nlpla.

  lv_lgnum  = fu_lgnum.
  lv_bwlvs  = '101'.
  lv_betyp  = 'Z'.
  lv_benum  = fs_shipdata-tknum.
  CONCATENATE fu_pallet fs_shipdata-tknum INTO lv_lznum SEPARATED BY ';'.
  "  lv_lznum  = fu_pallet.
  lv_drukz  = '45'.
  lv_commit = space.

  PERFORM f_prepare_detail TABLES lt_ltap_creat ft_mlgn
                           USING fs_shipdata fs_shipment fu_werks lv_lznum fs_shipdata-lfimg
                                 'NEWBC' '' lv_lgnum
                           CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                    lv_sisa lv_add.

  PERFORM f_create_to TABLES lt_ltap_creat
                      USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                            lv_lznum lv_drukz lv_commit
                      CHANGING lv_tanum lv_subrc.

  IF lv_tanum IS NOT INITIAL.
    fc_type    = 'S'.
    fc_message = 'Create TO success'.

    PERFORM f_save_004 TABLES lt_004
                       USING lv_tanum lv_lgnum lv_lznum
                             fu_uname 'NEWBC' fu_rusak ''
                             fu_zdtsul fu_zuzsul fu_zdteul fu_zuzeul
                             fs_shipdata fs_shipment ls_ltap_creat
                       CHANGING lv_save.
    IF lv_save = 0.
      PERFORM f_print_to USING lv_tanum lv_lgnum
                         CHANGING lv_nltyp lv_nlpla.
    ENDIF.
    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet lv_tanum lv_nlpla
                                  'NEWBC' fc_type fc_message.
  ELSE.
    fc_type    = 'E'.
    CALL FUNCTION 'ZWMSFM002'
      EXPORTING
        pi_subrc    = lv_subrc
        pi_function = 'L_TO_CREATE_MULTIPLE'
      IMPORTING
        pe_message  = fc_message.

    PERFORM f_body_response TABLES ft_to
                            USING ls_ltap_creat
                                  fu_itemid fu_pallet '' ''
                                  '' fc_type fc_message.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PICKING_AKHIR
*&---------------------------------------------------------------------*
FORM f_get_picking_akhir  TABLES   ft_pickakhir STRUCTURE zwmsst004
                          USING    fu_lgnum fu_tanum
                          CHANGING fc_type fc_message.
  DATA : lt_getpickd TYPE STANDARD TABLE OF zcl_zwms_picking_mpc_ext=>ts_getpickd,
         ls_getpickd LIKE LINE OF lt_getpickd,
         lt_xltak    TYPE STANDARD TABLE OF ltak,
         lt_ltak     TYPE STANDARD TABLE OF ltak,
         ls_ltak     LIKE LINE OF lt_ltak,
         lt_ltap     TYPE STANDARD TABLE OF ltap,
         lt_xltap    TYPE STANDARD TABLE OF ltap,
         ls_ltap     LIKE LINE OF lt_ltap,
         ls_xltap    LIKE LINE OF lt_xltap,
         lt_mch1     TYPE STANDARD TABLE OF mch1,
         ls_mch1     LIKE LINE OF lt_mch1,
         lt_makt     TYPE STANDARD TABLE OF makt,
         ls_makt     LIKE LINE OF lt_makt,
         lt_lagp     TYPE STANDARD TABLE OF lagp,
         ls_lagp     LIKE LINE OF lt_lagp,
         lt_marm     TYPE STANDARD TABLE OF marm,
         ls_marm     LIKE LINE OF lt_marm,
         lt_xlikp    TYPE STANDARD TABLE OF likp,
         lt_likp     TYPE STANDARD TABLE OF likp,
         ls_likp     LIKE LINE OF lt_likp,
         lt_kna1     TYPE STANDARD TABLE OF kna1,
         ls_kna1     LIKE LINE OF lt_kna1.

  DATA : lv_length TYPE i.

  lv_length = strlen( fu_tanum ).
  IF lv_length = 15.
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
        AND tanum = fu_tanum.
  ENDIF.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum.
    IF sy-subrc = 0.
      lt_xltap[] = lt_ltap[].
      SORT lt_xltap BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr charg.
      IF lt_xltap[] IS NOT INITIAL.
        SELECT *
          FROM mch1
          INTO CORRESPONDING FIELDS OF TABLE lt_mch1
          FOR ALL ENTRIES IN lt_xltap
          WHERE matnr = lt_xltap-matnr
            AND charg = lt_xltap-charg
            AND lvorm = space.

        DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr.
        IF lt_xltap[] IS NOT INITIAL.
          SELECT *
            FROM marm
            INTO CORRESPONDING FIELDS OF TABLE lt_marm
            FOR ALL ENTRIES IN lt_xltap
            WHERE matnr = lt_xltap-matnr
              AND meinh = 'KAR'.

          SELECT *
            FROM makt
            INTO CORRESPONDING FIELDS OF TABLE lt_makt
            FOR ALL ENTRIES IN lt_xltap
            WHERE matnr = lt_xltap-matnr
              AND spras = sy-langu.
        ENDIF.
      ENDIF.

      lt_xltap[] = lt_ltap[].
      SORT lt_xltap BY lgnum vltyp vlpla.
      DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum vltyp vlpla.
      IF lt_xltap[] IS NOT INITIAL.
        SELECT *
          FROM lagp
          INTO CORRESPONDING FIELDS OF TABLE lt_lagp
          FOR ALL ENTRIES IN lt_xltap
          WHERE lgnum = fu_lgnum
            AND lgtyp = lt_xltap-vltyp
            AND lgpla = lt_xltap-vlpla.
      ENDIF.

      lt_xltap[] = lt_ltap[].
      SORT lt_xltap BY lgnum matnr charg vlpla.
      DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum matnr charg vlpla.
      LOOP AT lt_xltap INTO ls_xltap.
        ls_getpickd-material_number  = ls_xltap-matnr.
        ls_getpickd-delivery_number  = ls_xltap-vbeln.

        CLEAR ls_makt.
        READ TABLE lt_makt INTO ls_makt
                           WITH KEY matnr = ls_xltap-matnr.
        IF sy-subrc = 0.
          ls_getpickd-material_description = ls_makt-maktx.
        ENDIF.
        CLEAR ls_marm.
        READ TABLE lt_marm INTO ls_marm
                           WITH KEY matnr = ls_xltap-matnr.
        IF sy-subrc = 0.
          WRITE ls_marm-umrez TO ls_getpickd-conversi_carton NO-GROUPING.
          CONDENSE ls_getpickd-conversi_carton NO-GAPS.
        ENDIF.

        ls_getpickd-batch        = ls_xltap-charg.
        CLEAR ls_mch1.
        READ TABLE lt_mch1 INTO ls_mch1
                           WITH KEY matnr = ls_xltap-matnr
                                    charg = ls_xltap-charg.
        IF sy-subrc = 0.
          ls_getpickd-exp_date  = ls_mch1-vfdat.
        ENDIF.
        ls_getpickd-storage_type = ls_xltap-vltyp.
        ls_getpickd-storage_bin  = ls_xltap-vlpla.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = ls_xltap-altme
          IMPORTING
            output         = ls_getpickd-uom
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.

        CLEAR ls_lagp.
        READ TABLE lt_lagp INTO ls_lagp
                           WITH KEY lgnum = fu_lgnum
                                    lgtyp = ls_xltap-vltyp
                                    lgpla = ls_xltap-vlpla.
        IF sy-subrc = 0.
          ls_getpickd-removal_indicator = ls_lagp-skzua.
        ENDIF.

        CLEAR : ls_xltap-vsola, ls_ltap.
        LOOP AT lt_ltap INTO ls_ltap WHERE lgnum = ls_xltap-lgnum
                                       AND matnr = ls_xltap-matnr
                                       AND charg = ls_xltap-charg
                                       AND vlpla = ls_xltap-vlpla.
          ADD ls_ltap-vsola TO ls_xltap-vsola.
        ENDLOOP.

        ls_getpickd-quantity     = ls_xltap-vsola.
        WRITE ls_xltap-vsola TO ls_getpickd-quantity UNIT ls_ltap-altme NO-GROUPING.
        CONDENSE ls_getpickd-quantity NO-GAPS.

        ls_getpickd-pickconf_status = ls_xltap-zrstg.

        IF ls_xltap-zrstg IS NOT INITIAL.
          WRITE ls_xltap-qzeit TO ls_getpickd-picking_start
          USING EDIT MASK '__:__:__'.
          CONCATENATE ls_xltap-qdatu ls_getpickd-picking_start
          INTO ls_getpickd-picking_start
          SEPARATED BY space.

          WRITE ls_xltap-ezeit TO ls_getpickd-picking_end
          USING EDIT MASK '__:__:__'.
          CONCATENATE ls_xltap-edatu ls_getpickd-picking_end
          INTO ls_getpickd-picking_end
          SEPARATED BY space.
        ENDIF.

        APPEND ls_getpickd TO ft_pickakhir.
        CLEAR ls_getpickd.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PICKCONF_AKHIR
*&---------------------------------------------------------------------*
FORM f_proses_pickconf_akhir  TABLES   pt_picking STRUCTURE zwmsst005
                              USING    p_json
                              CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_picking   TYPE ty_picka,
         lt_pickd     TYPE STANDARD TABLE OF zwmsst005,
         ls_pickd     LIKE LINE OF lt_pickd,
         lt_ltak      TYPE STANDARD TABLE OF ltak,
         ls_ltak      TYPE ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      LIKE LINE OF lt_ltap,
         lt_xltap     TYPE STANDARD TABLE OF ltap,
         ls_xltap     LIKE LINE OF lt_xltap.

  DATA : lv_qdatu  TYPE ltap-qdatu,
         lv_qzeit  TYPE ltap-qzeit,
         lv_edatu  TYPE ltap-edatu,
         lv_ezeit  TYPE ltap-ezeit,
         lv_uname  TYPE sy-uname,
         lv_length TYPE i,
         lv_subrc  TYPE sy-subrc.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_picking ).

  lt_pickd[] = ls_picking-nav_confpick[].

  lv_length = strlen( ls_picking-to_number ).
  IF lv_length = 15.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = ls_picking-warehouse_number
        AND lznum = ls_picking-to_number.
  ELSE.
    SELECT *
      FROM ltak
      INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = ls_picking-warehouse_number
        AND tanum = ls_picking-to_number.
  ENDIF.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum.

    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY matnr charg vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING matnr charg vltyp vlpla.
    LOOP AT lt_xltap INTO ls_xltap.
      CLEAR : ls_pickd.
      READ TABLE lt_pickd INTO ls_pickd
                          WITH KEY material_number = ls_xltap-matnr
                                   batch           = ls_xltap-charg
                                   storage_type    = ls_xltap-vltyp
                                   storage_bin     = ls_xltap-vlpla.
      IF sy-subrc = 0.
        CLEAR : lv_qdatu, lv_qzeit, lv_edatu, lv_ezeit, lv_uname.
        PERFORM f_datetime USING ls_pickd-picking_start
                           CHANGING lv_qdatu lv_qzeit.
        PERFORM f_datetime USING ls_pickd-picking_end
                           CHANGING lv_edatu lv_ezeit.
        lv_uname = ls_pickd-user_name.

        IF ls_xltap-pvqui IS INITIAL.

        ENDIF.

        TRY .
            UPDATE ltap SET qdatu = lv_qdatu
                            qzeit = lv_qzeit
                            qname = lv_uname
                            edatu = lv_edatu
                            ezeit = lv_ezeit
                            ename = lv_uname
                            zrstg = 'X'
                        WHERE lgnum = ls_xltap-lgnum
                          AND tanum = ls_xltap-tanum
*                          AND tapos = ls_xltap-tapos
                          AND matnr = ls_xltap-matnr
                          AND charg = ls_xltap-charg
                          AND vltyp = ls_xltap-vltyp
                          AND vlpla = ls_xltap-vlpla.
          CATCH cx_sy_open_sql_db.
            lv_subrc = 4.
        ENDTRY.

        IF lv_subrc = 0.
          ls_pickd-type = 'S'.
          ls_pickd-message = 'Confirm success'.

          IF lv_length = 15.
            IF line_exists( lt_ltap[ zrstg = space ] ).
            ELSE.
              PERFORM f_print_to USING ls_xltap-tanum ls_xltap-lgnum
                                 CHANGING ls_xltap-vltyp ls_xltap-vlpla.
            ENDIF.
          ENDIF.

        ELSE.
          ls_pickd-type = 'E'.
          ls_pickd-message = 'Confirm error'.
        ENDIF.
        MODIFY lt_pickd FROM ls_pickd
                        TRANSPORTING type message
                        WHERE material_number = ls_xltap-matnr
                          AND batch           = ls_xltap-charg
                          AND storage_type    = ls_xltap-vltyp
                          AND storage_bin     = ls_xltap-vlpla.
        CLEAR ls_pickd.
      ENDIF.
    ENDLOOP.

    pt_picking[] = lt_pickd[].
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PICKCMPL_AKHIR
*&---------------------------------------------------------------------*
FORM f_proses_pickcmpl_akhir  TABLES   pt_picking STRUCTURE zwmsst003
                              USING    p_json
                              CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_picking   TYPE ty_pickcmpl,
         lt_pickd     TYPE STANDARD TABLE OF zwmsst003,
         ls_pickd     LIKE LINE OF lt_pickd,
         lt_xpickd    TYPE STANDARD TABLE OF zwmsst003,
         ls_xpickd    LIKE LINE OF lt_xpickd.

  DATA : lv_queue  TYPE ltak-queue,
         lv_xqueue TYPE ltak-queue,
         lv_subrc  TYPE sy-subrc,
         lv_length TYPE i.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_picking ).

  lt_pickd[] = ls_picking-nav_cmplpick[].
  lv_queue   = 'CHECKER'.

  lv_length = strlen( ls_picking-to_number ).
  IF lv_length <> 10.
    CASE ls_picking-warehouse_number.
      WHEN 'C40'.
        PERFORM f_comppick_ab_group TABLES lt_pickd
                                    USING ls_picking-warehouse_number ls_picking-to_number
                                          ls_picking-koli_ori ls_picking-koli_ecer
                                    CHANGING fc_type fc_message.
    ENDCASE.
  ELSE.
    lt_xpickd[] = lt_pickd[].
    SORT lt_xpickd BY to_number.
    DELETE ADJACENT DUPLICATES FROM lt_xpickd COMPARING to_number.
    IF lt_xpickd[] IS NOT INITIAL.
      LOOP AT lt_xpickd INTO ls_xpickd.
        TRY .
            UPDATE ltak SET queue = lv_queue
                  WHERE lgnum = ls_picking-warehouse_number
                    AND tanum = ls_xpickd-to_number.
          CATCH cx_sy_open_sql_db.
            lv_subrc = 4.
        ENDTRY.

        TRY .
            UPDATE ltap SET zrstg = 'X'
                  WHERE lgnum = ls_picking-warehouse_number
                    AND tanum = ls_xpickd-to_number.
          CATCH cx_sy_open_sql_db.
            lv_subrc = 4.
        ENDTRY.

        IF lv_subrc = 0.
          ls_pickd-type = 'S'.
          ls_pickd-message = 'Data already completed'.
          fc_type    = ls_pickd-type.
          fc_message = ls_pickd-message.
        ELSE.
          ls_pickd-type = 'E'.
          ls_pickd-message = 'Error in completed data'.
          fc_type    = ls_pickd-type.
          fc_message = ls_pickd-message.
        ENDIF.
        MODIFY lt_pickd FROM ls_pickd
                        TRANSPORTING type message
                        WHERE to_number = ls_xpickd-to_number.
        CLEAR lv_subrc.
      ENDLOOP.
    ENDIF.

    lt_xpickd[] = lt_pickd[].
    SORT lt_xpickd BY delivery_number.
    DELETE ADJACENT DUPLICATES FROM lt_xpickd COMPARING delivery_number.
    IF lt_xpickd[] IS NOT INITIAL.
      LOOP AT lt_xpickd INTO ls_xpickd.
        TRY .
            UPDATE likp SET /bev1/rpfaess  = ls_picking-koli_ori
                            /bev1/rpkist   = ls_picking-koli_ecer
                        WHERE vbeln = ls_xpickd-delivery_number.
*          UPDATE likp SET /bev1/rpfaess  = ls_xpickd-koli_ori
*                          /bev1/rpkist   = ls_xpickd-koli_ecer
*                      WHERE vbeln = ls_xpickd-delivery_number.
          CATCH cx_sy_open_sql_db.
            lv_subrc = 4.
        ENDTRY.

        IF lv_subrc = 0.
          ls_pickd-type = 'S'.
          ls_pickd-message = 'Data already completed'.
          fc_type    = ls_pickd-type.
          fc_message = ls_pickd-message.
        ELSE.
          ls_pickd-type = 'E'.
          ls_pickd-message = 'Error in completed data'.
          fc_type    = ls_pickd-type.
          fc_message = ls_pickd-message.
        ENDIF.
        MODIFY lt_pickd FROM ls_pickd
                        TRANSPORTING type message
                        WHERE delivery_number = ls_xpickd-delivery_number.
        CLEAR lv_subrc.
      ENDLOOP.
    ENDIF.
  ENDIF.

  pt_picking[] = lt_pickd[].
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CHECKER_CONFIRM
*&---------------------------------------------------------------------*
FORM f_proses_checker_confirm  TABLES   ft_check  STRUCTURE zwmsst006
                               USING    p_json.
  DATA : lt_checkd  TYPE STANDARD TABLE OF zwmsst006,
         ls_checker TYPE ty_checker.

  DATA : lv_json_data TYPE string,
         lv_length    TYPE i,
         lv_lgnum     TYPE ltak-lgnum,
         lv_tanum     TYPE ltak-tanum,
         lv_vbeln     TYPE ltak-vbeln,
         lv_lznum     TYPE ltak-lznum.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_checker ).

  lt_checkd[] = ls_checker-nav_confcheck[].

  lv_length = strlen( ls_checker-to_number ).
  IF lv_length = 10.
    lv_lgnum = ls_checker-warehouse_number.
    lv_tanum = ls_checker-to_number.
    lv_vbeln = ls_checker-delivery_number.

    PERFORM f_checker_confirm TABLES ft_check
                                     lt_checkd
                              USING lv_lgnum lv_tanum lv_vbeln.
  ELSE.
    lv_lgnum = ls_checker-warehouse_number.
    lv_lznum = ls_checker-to_number.
    lv_vbeln = ls_checker-delivery_number.

    PERFORM f_checker_confirm_group TABLES ft_check
                                           lt_checkd
                                    USING lv_lgnum lv_lznum lv_vbeln.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CHECKER_COMPLETE
*&---------------------------------------------------------------------*
FORM f_proses_checker_complete  USING    p_json
                                CHANGING pe_check   STRUCTURE zwmsst007.

  DATA : lv_length    TYPE i.

  lv_length = strlen( pe_check-to_number ).
  IF lv_length = 10.
    PERFORM f_checker_complete USING p_json
                               CHANGING pe_check.
  ELSE.
    PERFORM f_checker_complete_group USING p_json
                                     CHANGING pe_check.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PGI
*&---------------------------------------------------------------------*
FORM f_pgi  USING    fu_vbeln
            CHANGING fc_subrc.
  DATA : header_data      TYPE bapiobdlvhdrcon,
         header_control   TYPE bapiobdlvhdrctrlcon,
         header_deadlines TYPE STANDARD TABLE OF bapidlvdeadln,
         return           TYPE STANDARD TABLE OF bapiret2,
         ls_deadlines     TYPE bapidlvdeadln,
         ls_return        LIKE LINE OF return.

  DATA : lv_timestamp TYPE tzntstmps,
         lv_time      TYPE systtimlo,
         lv_subrc     TYPE sy-subrc.

  header_data-deliv_numb       = fu_vbeln.
  header_control-deliv_numb    = fu_vbeln.
  header_control-post_gi_flg   = 'X'.
  header_control-gdsi_date_flg = 'X'.

  CLEAR : lv_timestamp, lv_time.
  lv_time = '120000'.
  PERFORM f_timestamp USING sy-datum lv_time
                      CHANGING lv_timestamp.

* Populate Actual Goods Issue Date
  CLEAR : header_deadlines[], ls_deadlines.
  ls_deadlines-deliv_numb    = fu_vbeln.
  ls_deadlines-timetype      = 'WSHDRWADTI'.
  ls_deadlines-timestamp_utc = lv_timestamp.
  APPEND ls_deadlines TO header_deadlines.

  CLEAR : ls_deadlines.
  PERFORM f_timestamp USING sy-datum lv_time
                      CHANGING lv_timestamp.

  ls_deadlines-deliv_numb    = fu_vbeln.
  ls_deadlines-timetype      = 'WSHDRWADAT'.
  ls_deadlines-timestamp_utc = lv_timestamp.
  APPEND ls_deadlines TO header_deadlines.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CONFIRM_DEC'
    EXPORTING
      header_data      = header_data
      header_control   = header_control
      delivery         = fu_vbeln
    TABLES
      header_deadlines = header_deadlines
      return           = return.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'E'.
      lv_subrc  = 4.
    ENDIF.
    CLEAR ls_return.
  ENDLOOP.

  IF lv_subrc IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CALL FUNCTION 'DEQUEUE_EVVBLKE'
      EXPORTING
        vbeln = fu_vbeln.

    fc_subrc = lv_subrc.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    fc_subrc = lv_subrc.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_timestamp  USING    fu_datum fu_time
                  CHANGING fc_timestamp.
  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      i_datlo     = fu_datum
      i_timlo     = fu_time
    IMPORTING
      e_timestamp = fc_timestamp.
ENDFORM.                    " F_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_CONFIRM_TO
*&---------------------------------------------------------------------*
FORM f_prepare_confirm_to  TABLES   ft_ltap_conf    STRUCTURE ltap_conf
                           USING    ls_checkd   STRUCTURE zwmsst006
                                    fu_lgnum fu_tanum fu_tapos fu_matnr
                                    fu_charg
                                    fu_nista fu_altme fu_ndifa fu_kzdif
                                    fu_group.
  DATA : ls_ltap_conf   TYPE ltap_conf.

  DATA : lv_nista TYPE ltap-nista,
         lv_mtart TYPE mara-mtart.

  CLEAR : ft_ltap_conf[].

  ls_ltap_conf-tanum   = fu_tanum.
  ls_ltap_conf-tapos   = fu_tapos.  "ls_checkd-to_item.

  IF fu_group IS INITIAL.
*    PERFORM f_quantity_calculate USING fu_lgnum fu_matnr fu_charg
*                                       ls_checkd-quantity_satuan
*                                       ls_checkd-uom_satuan
*                                       ls_checkd-quantity_carton
*                                       ls_checkd-uom_carton
*                                 CHANGING lv_nista.

    ls_ltap_conf-nista   = fu_nista.
    ls_ltap_conf-ndifa   = fu_ndifa.    "fu_nista - lv_nista.
    ls_ltap_conf-altme   = fu_altme.
  ELSE.
    ls_ltap_conf-nista   = fu_nista.
    ls_ltap_conf-ndifa   = fu_ndifa.
    ls_ltap_conf-altme   = fu_altme.
  ENDIF.

*  IF ls_checkd-difference_indicator IS INITIAL.
*    ls_ltap_conf-squit   = 'X'.
*  ENDIF.

  CASE fu_lgnum.
    WHEN '190'.
      SELECT SINGLE mtart
        FROM mara
        INTO lv_mtart
        WHERE matnr = fu_matnr.
      CASE lv_mtart.
        WHEN 'ZRM' OR 'ZPM'.
          IF ls_ltap_conf-ndifa <> 0.
            ls_ltap_conf-kzdif   = 'R'.
          ENDIF.
        WHEN OTHERS.
          IF fu_group IS INITIAL.
            ls_ltap_conf-kzdif   = ls_checkd-difference_indicator.
          ELSE.
            ls_ltap_conf-kzdif   = fu_kzdif.
          ENDIF.
      ENDCASE.
    WHEN OTHERS.
      IF fu_group IS INITIAL.
        ls_ltap_conf-kzdif   = ls_checkd-difference_indicator.
      ELSE.
        ls_ltap_conf-kzdif   = fu_kzdif.
      ENDIF.
  ENDCASE.

  APPEND ls_ltap_conf TO ft_ltap_conf.
  CLEAR ls_ltap_conf.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_TO
*&---------------------------------------------------------------------*
FORM f_confirm_to  TABLES   ft_ltap_conf STRUCTURE ltap_conf
                   USING    fu_lgnum fu_tanum
                   CHANGING fc_subrc.
  CALL FUNCTION 'L_TO_CONFIRM'
    EXPORTING
      i_lgnum                        = fu_lgnum
      i_tanum                        = fu_tanum
      i_quknz                        = '2'
    TABLES
      t_ltap_conf                    = ft_ltap_conf
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

  fc_subrc = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_LOADING_PROCESS
*&---------------------------------------------------------------------*
FORM f_proses_loading_process  TABLES   pt_load STRUCTURE zwmsst009
                               USING    p_json.
  DATA : lv_json_data TYPE string,
         ls_loadpos   TYPE ty_loadpos,
         lt_loadd     TYPE STANDARD TABLE OF zwmsst009,
         ls_loadd     LIKE LINE OF lt_loadd,
         lt_003       TYPE STANDARD TABLE OF zwmdt003,
         ls_003       LIKE LINE OF lt_003,
         lt_x003      TYPE STANDARD TABLE OF zwmdt003,
         ls_x003      LIKE LINE OF lt_x003.

  DATA : lv_first,
         lv_subrc TYPE sy-subrc,
         lv_vbeln TYPE zwmdt003-vbeln,
         lv_dalbg TYPE zwmdt003-dalbg,
         lv_ualbg TYPE zwmdt003-ualbg,
         lv_dalen TYPE zwmdt003-dalen,
         lv_ualen TYPE zwmdt003-ualen,
         lv_ernam TYPE zwmdt003-ernam.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_loadpos ).

  lt_loadd[] = ls_loadpos-nav_load[].

  SELECT *
    FROM zwmdt003
    INTO CORRESPONDING FIELDS OF TABLE lt_003
    WHERE tknum = ls_loadpos-shipment_number.

*  lv_first = 'X'.
*
*  LOOP AT lt_003 INTO ls_003.
*    IF ls_003-dalbg <> '00000000'.
*      CLEAR lv_first.
*    ENDIF.
*  ENDLOOP.

  READ TABLE lt_loadd INTO ls_loadd INDEX 1.
  IF sy-subrc = 0.
    CLEAR : lv_dalbg, lv_ualbg, lv_dalen, lv_ualen, lv_ernam, lv_vbeln.
    lv_vbeln  = ls_loadd-delivery_number.

    PERFORM f_datetime USING ls_loadd-loading_start
                       CHANGING lv_dalbg lv_ualbg.
    PERFORM f_datetime USING ls_loadd-loading_end
                       CHANGING lv_dalen lv_ualen.

    lv_ernam  = ls_loadd-user_name.

    PERFORM f_update_003 USING ls_loadpos-shipment_number lv_vbeln
                               lv_dalbg lv_ualbg lv_dalen lv_ualen
                               lv_ernam
                         CHANGING lv_subrc.
    IF lv_subrc = 0.
*      IF lv_first = 'X'.
*        PERFORM f_shipment_change USING 'X' ls_loadpos-shipment_number
*                                        lv_dalbg lv_ualbg lv_dalen lv_ualen
*                                        lv_ernam
*                                  CHANGING ls_loadd-type ls_loadd-message.
*      ENDIF.
*
      COMMIT WORK AND WAIT.

      SELECT *
        FROM zwmdt003
        INTO CORRESPONDING FIELDS OF TABLE lt_x003
        WHERE tknum = ls_loadpos-shipment_number
          AND dalbg = '00000000'.
      IF sy-subrc <> 0.
        PERFORM f_shipment_change USING '' ls_loadpos-shipment_number
                                        lv_dalbg lv_ualbg lv_dalen lv_ualen
                                        lv_ernam
                                  CHANGING ls_loadd-type ls_loadd-message.
      ENDIF.
    ELSE.
      ls_loadd-type    = 'E'.
      ls_loadd-message = 'Loading error'.
    ENDIF.
    APPEND ls_loadd TO pt_load.
    CLEAR ls_loadd.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_003
*&---------------------------------------------------------------------*
FORM f_update_003  USING    fu_tknum fu_vbeln fu_dalbg fu_ualbg fu_dalen
                            fu_ualen fu_ernam
                   CHANGING fc_subrc.
  TRY .
      UPDATE zwmdt003 SET dalbg = fu_dalbg
                          ualbg = fu_ualbg
                          dalen = fu_dalen
                          ualen = fu_ualen
                          ernam = fu_ernam
                  WHERE tknum = fu_tknum
                    AND vbeln = fu_vbeln.
    CATCH cx_sy_open_sql_db.
      fc_subrc = 4.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHIPMENT_CHANGE
*&---------------------------------------------------------------------*
FORM f_shipment_change  USING    fu_first fu_tknum fu_dalbg fu_ualbg fu_dalen
                                 fu_ualen fu_ernam
                        CHANGING fc_type fc_message.
  DATA : headerdata       TYPE bapishipmentheader,
         headerdataaction TYPE bapishipmentheaderaction,
         return           TYPE STANDARD TABLE OF bapiret2,
         ls_return        LIKE LINE OF return,
         lt_003           TYPE STANDARD TABLE OF zwmdt003,
         ls_003           LIKE LINE OF lt_003.

  DATA : lv_subrc TYPE sy-subrc,
         lv_dalbg TYPE zwmdt003-dalbg,
         lv_ualbg TYPE zwmdt003-ualbg,
         lv_dalen TYPE zwmdt003-dalen,
         lv_ualen TYPE zwmdt003-ualen.

  headerdata-shipment_num   = fu_tknum.

*  IF fu_first = 'X'.
  headerdata-status_load_start           = 'X'.
  headerdataaction-status_load_start     = 'C'.
*  ELSE.
  headerdata-status_load_end             = 'X'.
  headerdataaction-status_load_end       = 'C'.
*  ENDIF.
  headerdata-status_shpmnt_start         = 'X'.
  headerdataaction-status_shpmnt_start   = 'C'.

  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      headerdata       = headerdata
      headerdataaction = headerdataaction
    TABLES
      return           = return.

  READ TABLE return INTO ls_return
                    WITH KEY type = 'E'.
  IF sy-subrc = 0.
    fc_type = 'E'.
    fc_message = 'Loading error'.
  ELSE.
*    IF fu_first = 'X'.
*      TRY .
*          UPDATE vttk SET dalbg = fu_dalbg
*                          ualbg = fu_ualbg
*                          ernam = fu_ernam
*                      WHERE tknum = fu_tknum.
*        CATCH cx_sy_open_sql_db.
*          lv_subrc = 4.
*      ENDTRY.
*    ELSE.
    SELECT *
      FROM zwmdt003
      INTO CORRESPONDING FIELDS OF TABLE lt_003
      WHERE tknum = fu_tknum.

    SORT lt_003 BY dalbg ualbg.
    CLEAR ls_003.
    READ TABLE lt_003 INTO ls_003 INDEX 1.
    IF sy-subrc = 0.
      lv_dalbg = ls_003-dalbg.
      lv_ualbg = ls_003-ualbg.
    ENDIF.

    SORT lt_003 BY dalen DESCENDING ualen DESCENDING.
    CLEAR ls_003.
    READ TABLE lt_003 INTO ls_003 INDEX 1.
    IF sy-subrc = 0.
      lv_dalen = ls_003-dalen.
      lv_ualen = ls_003-ualen.
    ENDIF.

    TRY .
        UPDATE vttk SET dalbg = lv_dalbg
                        ualbg = lv_ualbg
                        dalen = lv_dalen
                        ualen = lv_ualen
                        datbg = lv_dalen
                        uatbg = lv_ualen
                        ernam = fu_ernam
                    WHERE tknum = fu_tknum.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
*    ENDIF.

    IF lv_subrc = 0.
      fc_type = 'S'.
      fc_message = 'Loading success'.
    ELSE.
      fc_type = 'E'.
      fc_message = 'Loading error'.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POST_PID
*&---------------------------------------------------------------------*
FORM f_proses_post_pid  TABLES   pt_pid STRUCTURE zwmsst011
                        USING    p_json.
  TYPES : BEGIN OF ty_message,
            tanum TYPE ltak-tanum,
            matnr TYPE ltap-matnr,
            charg TYPE ltap-charg,
            subrc TYPE sy-subrc,
          END OF ty_message.

  DATA : lv_json_data TYPE string,
         ls_pid       TYPE ty_pid,
         lt_pidd      TYPE STANDARD TABLE OF zwmsst011,
         ls_pidd      LIKE LINE OF lt_pidd,
         s_linv       TYPE STANDARD TABLE OF e1linvx,
         lt_xpidd     TYPE STANDARD TABLE OF zwmsst011,
         ls_xpidd     LIKE LINE OF lt_xpidd,
         lt_xlinv     TYPE STANDARD TABLE OF linv,
         ls_xlinv     LIKE LINE OF lt_xlinv,
         ls_linv      LIKE LINE OF s_linv,
         ls_mch1      TYPE mch1.

  DATA : lt_message  TYPE STANDARD TABLE OF ty_message,
         ls_message  LIKE LINE OF lt_message,
         lt_xmessage TYPE STANDARD TABLE OF ty_message,
         ls_xmessage LIKE LINE OF lt_xmessage.

  DATA : lv_subrc  TYPE sy-subrc,
         lv_lgnum  TYPE ltak-lgnum,
         lv_lgtyp  TYPE lagp-lgtyp,
         lv_lgpla  TYPE lagp-lgpla,
         lv_bwlvs  TYPE ltak-bwlvs,
         lv_betyp  TYPE ltak-betyp,
         lv_benum  TYPE ltak-benum,
         lv_lznum  TYPE ltak-lznum,
         lv_drukz  TYPE t329f-drukz,
         lv_commit TYPE rl03b-comit,
         lv_werks  TYPE t320-werks,
         lv_tanum  TYPE ltak-tanum,
         lv_letyp  TYPE t307-letyp,
         lv_lgort  TYPE t320-lgort,
         lv_kzinv  TYPE lagp-kzinv,
         lv_meins  TYPE mara-meins.

  DATA : nr_range_nr   TYPE inri-nrrangenr,
         object	       TYPE inri-object,
         subobject(50),
         number        TYPE lqua-lqnum,
         returncode    TYPE inri-returncode.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_pid ).

  lt_pidd[] = ls_pid-nav_pid[].
  lt_xpidd[] = lt_pidd[].
  SORT lt_xpidd BY pid_no.
  DELETE ADJACENT DUPLICATES FROM lt_xpidd COMPARING pid_no.

  IF lt_xpidd[] IS NOT INITIAL.
    SELECT *
      FROM linv
      INTO CORRESPONDING FIELDS OF TABLE lt_xlinv
      FOR ALL ENTRIES IN lt_xpidd
      WHERE lgnum = ls_pid-warehouse_number
        AND ivnum = lt_xpidd-pid_no.
  ENDIF.

  READ TABLE lt_pidd INTO ls_pidd INDEX 1.
  SELECT SINGLE meins
    FROM mara
    INTO lv_meins
    WHERE matnr = ls_pidd-material_number.

  SELECT SINGLE *
    FROM mch1
    INTO CORRESPONDING FIELDS OF ls_mch1
    WHERE matnr = ls_pidd-material_number
      AND charg = ls_pidd-batch.
  IF sy-subrc = 0.
    IF ls_mch1-lwedt = '00000000'.
      lv_subrc = 2.
    ELSEIF ls_mch1-laeda = '00000000'.
*      lv_subrc = 3.
    ENDIF.
  ELSE.
*    lv_subrc = 1.
  ENDIF.

*EXP_DATE
  IF lv_subrc = 0.
    lv_lgnum  = ls_pid-warehouse_number.
    lv_lgtyp  = ls_pid-storage_type.
    lv_lgpla  = ls_pid-storage_bin.
*    lv_bwlvs  = '712'.
*    lv_betyp  = 'D'.
*    lv_benum  = ls_pidd-pid_no.
*    lv_lznum  = ''.
*    lv_drukz  = '45'.
*    lv_commit = space.
    SELECT SINGLE werks
      FROM t320
      INTO lv_werks
      WHERE lgnum = lv_lgnum.

    SELECT SINGLE letyp
      FROM t307
      INTO lv_letyp
      WHERE lgnum = lv_lgnum.

    SELECT SINGLE kzinv
      FROM lagp
      INTO lv_kzinv
      WHERE lgnum = lv_lgnum
        AND lgtyp = lv_lgtyp
        AND lgpla = lv_lgpla.
    LOOP AT lt_pidd INTO ls_pidd.
      CLEAR: lv_meins.
      SELECT SINGLE meins
        FROM mara
        INTO lv_meins
        WHERE matnr = ls_pidd-material_number.
      IF ls_pidd-quant = 'X'.
        nr_range_nr = '01'.
        object      = 'LVS_LQNUM'.
        subobject   = ls_pid-warehouse_number.

        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = nr_range_nr
            object                  = object
            subobject               = subobject
          IMPORTING
            number                  = number
            returncode              = returncode
          EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
        IF ls_linv-lgort IS INITIAL.
          LOOP AT lt_xlinv INTO ls_xlinv.
            ls_linv-lgort = ls_xlinv-lgort.
            IF ls_linv-lgort IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF ls_linv-lgort IS INITIAL.
            IF ls_pid-warehouse_number(1) = 'C'.
              ls_linv-lgort = '1000'.
            ELSE.
              SELECT SINGLE a~lgort INTO ls_linv-lgort
                FROM t320 AS a JOIN mard AS b ON a~werks = b~werks AND a~lgort = b~lgort
                WHERE lgnum = ls_pid-warehouse_number
                  AND matnr = ls_pidd-material_number.
            ENDIF.
          ENDIF.
        ENDIF.
        ls_pidd-quant   = number.
        ls_linv-lgnum   = ls_pid-warehouse_number.
        ls_linv-lgtyp   = ls_pid-storage_type.
        ls_linv-lgpla   = ls_pid-storage_bin.
        ls_linv-werks   = lv_werks.
        ls_linv-letyp   = lv_letyp.
        "        ls_linv-lgort   = '1000'.
        ls_linv-kzinv   = lv_kzinv.
        ls_linv-ivnum   = ls_pidd-pid_no.
        ls_linv-ivpos   = ls_pidd-item_no.
        ls_linv-lqnum   = ls_pidd-quant.
        ls_linv-matnr   = ls_pidd-material_number.
        ls_linv-charg   = ls_pidd-batch.
        ls_linv-istat   = 'Z'.
        PERFORM f_check_date USING ls_pidd-counted_date
                             CHANGING ls_linv-idatu.
*        ls_linv-idatu   = ls_pidd-counted_date.
        ls_linv-menga   = ls_pidd-quantity_satuan.
        IF ls_pidd-quantity_satuan = 0.
          ls_linv-kznul = 'X'.
        ENDIF.

        ls_linv-altme = lv_meins.
*        PERFORM f_unit_conversion_input USING ls_pidd-uom_satuan
*                                        CHANGING ls_linv-altme.

        PERFORM f_get_stock_category USING ls_linv-bestq
                                           ls_pid-warehouse_number
                                           ls_pidd-material_number
                                           ls_pidd-batch
                                     CHANGING ls_pidd-stock_category.
*        ls_linv-bestq   = ls_pidd-stock_category.

        ls_linv-uname   = ls_pidd-user_name.
        IF ls_pidd-gr_date = '00000000'.
          ls_linv-wdatu   = sy-datum.
        ELSE.
          ls_linv-wdatu   = ls_pidd-gr_date.
        ENDIF.

        SELECT SINGLE iseit INTO ls_linv-iseit FROM linv
          WHERE lgnum = ls_linv-lgnum
            AND ivnum = ls_linv-ivnum
            AND ivpos = ls_linv-ivpos
            AND lqnum = ls_linv-lqnum
            AND lgpla = ls_linv-lgpla.
        IF sy-subrc NE 0.
          SELECT SINGLE iseit INTO ls_linv-iseit FROM linv
            WHERE lgnum = ls_linv-lgnum
              AND ivnum = ls_linv-ivnum
              AND lgpla = ls_linv-lgpla.
          IF sy-subrc NE 0.
            ls_linv-iseit = '0001'.
          ENDIF.
        ENDIF.
        APPEND ls_linv TO s_linv.
      ELSE.
        CLEAR ls_linv.
        READ TABLE lt_xlinv INTO ls_xlinv
                           WITH KEY lgnum = ls_pid-warehouse_number
                                    ivnum = ls_pidd-pid_no
                                    ivpos = ls_pidd-item_no
                                    lqnum = ls_pidd-quant.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_xlinv TO ls_linv.
          IF ls_linv-lgort IS INITIAL.
            LOOP AT lt_xlinv INTO ls_xlinv.
              ls_linv-lgort = ls_xlinv-lgort.
              IF ls_linv-lgort IS NOT INITIAL.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF ls_linv-lgort IS INITIAL.
              IF ls_pid-warehouse_number(1) = 'C'.
                ls_linv-lgort = '1000'.
              ELSE.
                SELECT SINGLE a~lgort INTO ls_linv-lgort
                  FROM t320 AS a JOIN mard AS b ON a~werks = b~werks AND a~lgort = b~lgort
                  WHERE lgnum = ls_pid-warehouse_number
                    AND matnr = ls_pidd-material_number.
              ENDIF.
            ENDIF.
          ENDIF.
          IF ls_pidd-material_number <> ls_xlinv-matnr.
            ls_linv-matnr = ls_pidd-material_number.
            ls_linv-charg = ls_pidd-batch.
          ENDIF.
          ls_linv-istat   = 'Z'.
          PERFORM f_check_date USING ls_pidd-counted_date
                             CHANGING ls_linv-idatu.
*          ls_linv-idatu   = ls_pidd-counted_date.
          ls_linv-menga   = ls_pidd-quantity_satuan.
          IF ls_pidd-quantity_satuan = 0.
            ls_linv-kznul = 'X'.
          ENDIF.

          ls_linv-altme = lv_meins.
*          PERFORM f_unit_conversion_input USING ls_pidd-uom_satuan
*                                          CHANGING ls_linv-altme.

          PERFORM f_get_stock_category USING ls_linv-bestq
                                             ls_pid-warehouse_number
                                             ls_pidd-material_number
                                             ls_pidd-batch
                                       CHANGING ls_pidd-stock_category.
*          ls_linv-bestq   = ls_pidd-stock_category.

          ls_linv-uname   = ls_pidd-user_name.

          IF ls_pidd-gr_date = '00000000'.
            ls_linv-wdatu   = sy-datum.
          ELSE.
            ls_linv-wdatu   = ls_pidd-gr_date.
          ENDIF.

          APPEND ls_linv TO s_linv.
        ELSE.
          lv_subrc = 4.
        ENDIF.
      ENDIF.

      CLEAR : ls_linv.

      IF lv_subrc = 4.
        ls_pidd-type    = 'E'.
        ls_pidd-message = 'Error'.
      ENDIF.
      APPEND ls_pidd TO pt_pid.
      CLEAR lv_subrc.
    ENDLOOP.

    IF s_linv[] IS NOT INITIAL.
      CALL FUNCTION 'L_INV_COUNT_EXT'
        TABLES
          s_linv                       = s_linv
        EXCEPTIONS
          either_quantity_or_empty_bin = 1
          ivnum_not_found              = 2
          check_problem                = 3
          no_count_allowed             = 4
          l_inv_read                   = 5
          bin_not_in_ivnum             = 6
          counts_not_updated           = 7
          lock_error                   = 8
      "   others                       = 9
        exceptions
          error_message                = 99.

    ENDIF.

    CASE sy-subrc.
      WHEN 0.
        ls_xpidd-type    = 'S'.
        ls_xpidd-message = 'PID count'.
      WHEN 1.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'Qty or bin empty'.
      WHEN 2.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'PID not found'.
      WHEN 3.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'Check problem'.
      WHEN 4.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'no count allowed'.
      WHEN 5.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'l_inv_read'.
      WHEN 6.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'bin not in PID'.
      WHEN 7.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'Counts not updated'.
      WHEN 8.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'Lock error'.
      WHEN 9.
        ls_xpidd-type    = 'E'.
        ls_xpidd-message = 'Others error'.
      WHEN 99.
        ls_xpidd-type    = 'E'.
    ENDCASE.
    IF ls_xpidd-type = 'E'.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = sy-msgid
          lang      = sy-langu
          no        = sy-msgno
          v1        = sy-msgv1
          v2        = sy-msgv2
          v3        = sy-msgv3
          v4        = sy-msgv4
        IMPORTING
          msg       = ls_xpidd-message
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
    ENDIF.

    lt_xmessage[] = lt_message[].
    DELETE lt_xmessage WHERE tanum = space.
    IF lt_xmessage[] IS NOT INITIAL.
*      LOOP AT lt_xmessage INTO ls_xmessage.
*        TRY.
*            UPDATE ltak SET kquit = 'X'
*                        WHERE tanum = ls_xmessage-tanum.
*          CATCH cx_sy_open_sql_db.
*        ENDTRY.
*
*        TRY.
*            UPDATE ltap SET pquit = 'X'
*                        WHERE tanum = ls_xmessage-tanum.
*          CATCH cx_sy_open_sql_db.
*        ENDTRY.
*      ENDLOOP.
    ENDIF.

    DELETE lt_message WHERE tanum <> space.
    READ TABLE lt_message INTO ls_message INDEX 1.
    IF sy-subrc = 0.
      ls_xpidd-type    = 'E'.
      CALL FUNCTION 'ZWMSFM002'
        EXPORTING
          pi_subrc    = ls_message-subrc
          pi_function = 'L_TO_CREATE_SINGLE'
        IMPORTING
          pe_message  = ls_xpidd-message.
    ENDIF.

    LOOP AT pt_pid INTO ls_pidd.
      IF ls_pidd-type IS INITIAL.
        ls_pidd-type = ls_xpidd-type.
        ls_pidd-message = ls_xpidd-message.
        MODIFY pt_pid FROM ls_pidd.
      ENDIF.
    ENDLOOP.
    CLEAR sy-subrc.
  ELSE.
    LOOP AT lt_pidd INTO ls_pidd.
      CASE lv_subrc.
        WHEN 1.
          ls_pidd-type    = 'E'.
          ls_pidd-message = 'Batch belum dimaintain'.
        WHEN 2.
          ls_pidd-type    = 'E'.
          ls_pidd-message = 'Exp.date belum dimaintain'.
        WHEN 3.
          ls_pidd-type    = 'E'.
          ls_pidd-message = 'GR date wajib diisi'.
      ENDCASE.
      APPEND ls_pidd TO pt_pid.
      CLEAR lv_subrc.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_OPEN_BLOCK_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_open_block_putaway  TABLES   ft_x003 STRUCTURE zwmdt003.
  DATA : lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap.

  IF ft_x003[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN ft_x003
      WHERE vbeln = ft_x003-vbeln.

    SORT lt_ltap BY vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING vltyp vlpla.
    LOOP AT lt_ltap INTO ls_ltap.
      TRY.
          UPDATE lagp SET skzue = space
                          spgru = space
                      WHERE lgnum = ls_ltap-lgnum
                        AND lgtyp = ls_ltap-vltyp
                        AND lgpla = ls_ltap-vlpla.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PGI_SUT
*&---------------------------------------------------------------------*
FORM f_pgi_sut  USING    fu_vbeln.
  DATA : ls_lips   TYPE lips,
         ls_ekpo   TYPE ekpo,
         ls_vbfa   TYPE vbfa,
         ls_ekbe   TYPE ekbe,
         rspar_tab TYPE TABLE OF rsparams.

  SELECT SINGLE *
    FROM lips
    INTO CORRESPONDING FIELDS OF ls_lips
    WHERE vbeln = fu_vbeln.

  IF ls_lips-vgbel IS NOT INITIAL.
    SELECT SINGLE *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF ls_ekpo
      WHERE ebeln = ls_lips-vgbel.
  ENDIF.

  IF ls_ekpo-bednr IS NOT INITIAL.
    SELECT SINGLE *
      FROM vbfa
      INTO CORRESPONDING FIELDS OF ls_vbfa
      WHERE vbelv = ls_ekpo-bednr
        AND vbtyp_n = 'R'.
    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM ekbe
        INTO CORRESPONDING FIELDS OF ls_ekbe
        WHERE ebeln = ls_lips-vgbel
          AND vgabe = '6'.

      PERFORM f_submit_parameter TABLES rspar_tab
                                 USING : 'P_MBLNR' ls_ekbe-belnr 'P',
                                         'P_MJAHR' ls_ekbe-gjahr 'P'.
      SUBMIT zssut_e013 WITH SELECTION-TABLE rspar_tab AND RETURN.
      CLEAR : rspar_tab[].
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CREATE_TO_NEW
*&---------------------------------------------------------------------*
FORM f_proses_create_to_new  TABLES   pt_to   STRUCTURE zwmsst001
                             USING    p_json
                             CHANGING p_to_number p_pallet_no fc_type fc_message.

  DATA : ls_to         TYPE ty_to,
         lt_xnavship   TYPE STANDARD TABLE OF ty_shipdetail,
         lt_mlgn       TYPE STANDARD TABLE OF mlgn,
         ls_mlgn       LIKE LINE OF lt_mlgn,
         lt_shipdetail TYPE STANDARD TABLE OF ty_shipdetail,
         ls_shipdetail LIKE LINE OF lt_shipdetail,
         lt_shipdata   TYPE STANDARD TABLE OF ty_shipment,
         ls_shipdata   LIKE LINE OF lt_shipdata,
         lt_xshipdata  TYPE STANDARD TABLE OF ty_shipment,
         ls_xshipdata  LIKE LINE OF lt_xshipdata,
         lt_shipment   TYPE STANDARD TABLE OF ty_shipment,
         ls_shipment   LIKE LINE OF lt_shipment,
         lt_004        TYPE STANDARD TABLE OF zwmdt004,
         ls_004        LIKE LINE OF lt_004,
         lt_s004       TYPE STANDARD TABLE OF zwmdt004,
         ls_s004       LIKE LINE OF lt_s004,
         lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         ls_ltak       TYPE ltak,
         lt_t334b      TYPE STANDARD TABLE OF t334b,
         ls_t334b      LIKE LINE OF lt_t334b,
         lt_xmlgn      TYPE STANDARD TABLE OF mlgn.

  DATA : lv_json_data     TYPE string,
         lv_tknum         TYPE vttk-tknum,
         lv_uname         TYPE sy-uname,
         lv_lgnum         TYPE ltak-lgnum,
         lv_rusak         TYPE c LENGTH 1,
         lv_zdtsul        TYPE sy-datum,
         lv_zuzsul        TYPE sy-uzeit,
         lv_zdteul        TYPE sy-datum,
         lv_zuzeul        TYPE sy-uzeit,
         lv_werks         TYPE t320-werks,
         lv_carton        TYPE lips-lfimg,
         lv_receh         TYPE lips-lfimg,
         lv_subrc         TYPE sy-subrc,
         lv_lhmg1         TYPE mlgn-lhmg1,
         lv_pallet(10),
         lv_itemid(20),
         lv_charg         TYPE ltap-charg,
         lv_dnqty         TYPE lips-lfimg,
         lv_anfme         TYPE ltap_creat-anfme,
         lv_message(220),
         lv_lfimg         TYPE zwmdt004-lfimg,
         lv_4lfimg        TYPE zwmdt004-lfimg,
         lv_commit        TYPE rl03b-comit,
         lv_sisa          TYPE mlgn-lhmg1,
         lv_add           TYPE c LENGTH 1,
         lv_nltyp         TYPE ltap-nltyp,
         lv_nlpla         TYPE ltap-nlpla,
         lv_tanum         TYPE ltak-tanum,
         lv_004,
         lv_save          TYPE sy-subrc,
         lv_count(2),
         lv_fieldname(30),
         lv_lgber         TYPE lagp-lgber,
         lv_kunnr         TYPE likp-kunnr.

  FIELD-SYMBOLS <fs>   TYPE any.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_to ).

  lv_tknum  = ls_to-shipment_number.
  lv_uname  = ls_to-user_name.
  lv_lgnum  = ls_to-warehouse_number.
  lv_rusak  = ls_to-rusak_indicator.

  PERFORM f_datetime USING ls_to-unloading_start
                     CHANGING lv_zdtsul lv_zuzsul.

  PERFORM f_datetime USING ls_to-unloading_end
                     CHANGING lv_zdteul lv_zuzeul.

  SELECT SINGLE werks
    FROM t320
    INTO lv_werks
    WHERE lgnum = lv_lgnum.
  IF sy-subrc EQ 0.
    CONCATENATE 'TBA' lv_werks INTO lv_kunnr.
  ENDIF.
  lt_shipdetail[] = ls_to-nav_ship[].
  lt_xnavship[]   = ls_to-nav_ship[].
  SORT lt_xnavship BY material_number.
  DELETE ADJACENT DUPLICATES FROM lt_xnavship COMPARING material_number.
  IF lt_xnavship[] IS NOT INITIAL.
    SELECT *
      FROM mlgn
      INTO CORRESPONDING FIELDS OF TABLE lt_mlgn
      FOR ALL ENTRIES IN lt_xnavship
      WHERE matnr = lt_xnavship-material_number
        AND lgnum = lv_lgnum.

    lt_xmlgn[] = lt_mlgn[].
    SORT lt_xmlgn BY lgbkz.
    DELETE ADJACENT DUPLICATES FROM lt_xmlgn COMPARING lgbkz.
    IF lt_xmlgn[] IS NOT INITIAL.
      SELECT *
        FROM t334b
        INTO CORRESPONDING FIELDS OF TABLE lt_t334b
        FOR ALL ENTRIES IN lt_xmlgn
        WHERE lgnum = lv_lgnum
          AND lgbkz = lt_xmlgn-lgbkz.
    ENDIF.

    LOOP AT ls_to-nav_ship INTO ls_shipdetail.
      CLEAR ls_mlgn.
      READ TABLE lt_mlgn INTO ls_mlgn
                         WITH KEY matnr = ls_shipdetail-material_number.
      IF sy-subrc = 0.
        IF ls_t334b IS INITIAL.
          CLEAR ls_t334b.
          READ TABLE lt_t334b INTO ls_t334b
                              WITH KEY lgbkz = ls_mlgn-lgbkz.
        ELSE.
          lv_count = 0.
          lv_subrc = 4.
          DO 30 TIMES.
            IF lv_count < 10.
              CONCATENATE 'LS_T334B-LGBE' lv_count INTO lv_fieldname.
            ELSE.
              CONCATENATE 'LS_T334B-LGB' lv_count INTO lv_fieldname.
            ENDIF.
            ADD 1 TO lv_count.
            ASSIGN (lv_fieldname) TO <fs>.
            CLEAR lv_lgber.
            IF <fs> IS ASSIGNED.
              lv_lgber = <fs>.
              IF lv_lgber = ls_mlgn-lgbkz.
                CLEAR lv_subrc.
                EXIT.
              ENDIF.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDIF.
      IF lv_subrc = 4.
        CONCATENATE 'Putaway in storage section' ls_mlgn-lgbkz
                    'is not allowed'
        INTO lv_message
        SEPARATED BY space.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_subrc = 0.
    SORT ls_to-nav_ship BY material_number batch.
    LOOP AT ls_to-nav_ship INTO ls_shipdetail.
      ls_shipdata-tknum  = ls_to-shipment_number.
      ls_shipdata-matnr  = ls_shipdetail-material_number.
      ls_shipdata-charg  = ls_shipdetail-batch.
      IF ls_shipdata-charg(1) = '?'.
        ls_shipdata-charg(1) = space.
      ENDIF.

      PERFORM f_check USING ls_shipdetail-quantity_satuan
                      CHANGING lv_subrc.
      PERFORM f_check USING ls_shipdetail-quantity_carton
                      CHANGING lv_subrc.

      IF lv_subrc = 0.
        PERFORM f_unit_conversion USING ls_shipdetail
                                  CHANGING lv_carton lv_receh.
        ls_shipdata-lfimg = lv_carton + lv_receh.
        ls_shipdata-vrkme = ls_shipdetail-uom_satuan.
        ls_shipdata-newbc = ls_shipdetail-newmat_indicator.
        ls_shipdata-zero  = ls_shipdetail-zero_indicator.
        ls_shipdata-newch = ls_shipdetail-newbatch_indicator.
        ls_shipdata-newsn = ls_shipdetail-newsn_indicator.

        CLEAR : ls_mlgn, lv_subrc.
        READ TABLE lt_mlgn INTO ls_mlgn
                           WITH KEY matnr = ls_shipdata-matnr.
        IF sy-subrc = 0.
          IF ls_shipdata-lfimg <= ls_mlgn-lhmg1.
            lv_pallet          = ls_to-pallet_number.
            ls_shipdata-pallet = lv_pallet.
            CONDENSE ls_shipdata-pallet NO-GAPS.
            APPEND ls_shipdata TO lt_shipdata.
          ELSE.
            lv_pallet = ls_to-pallet_number.
            lv_lhmg1  = ls_shipdata-lfimg.
            WHILE lv_subrc = 0.
              IF lv_lhmg1 < 0.
                lv_subrc = 1.
              ELSEIF lv_lhmg1 = 0.
                ls_shipdata-pallet = lv_pallet.
                ls_shipdata-lfimg  = ls_mlgn-lhmg1.
                CONDENSE ls_shipdata-pallet NO-GAPS.
                APPEND ls_shipdata TO lt_shipdata.
                lv_subrc = 1.
              ELSE.
                IF ls_mlgn-lhmg1 > lv_lhmg1.
                ELSE.
                  ls_shipdata-lfimg = ls_mlgn-lhmg1.
                ENDIF.
                ls_shipdata-pallet = lv_pallet.
                CONDENSE ls_shipdata-pallet NO-GAPS.
                APPEND ls_shipdata TO lt_shipdata.
              ENDIF.
              lv_lhmg1 = ls_shipdata-lfimg - ls_mlgn-lhmg1.
              ADD 1 TO lv_pallet.
            ENDWHILE.
          ENDIF.
        ENDIF.
      ELSE.
        lv_message  = 'Input quantity salah'.
        EXIT.
      ENDIF.
      CLEAR ls_shipdata.
    ENDLOOP.
  ENDIF.

  IF lv_subrc <> 4.
    CLEAR lv_subrc.

    SORT lt_shipdata BY matnr charg.
    IF lt_shipdata[] IS NOT INITIAL.
      SELECT tknum a~vbeln posnr matnr charg lfimg meins vrkme
        FROM vttp AS a JOIN lips AS b ON a~vbeln = b~vbeln
                       JOIN likp AS c ON a~vbeln = c~vbeln
        INTO CORRESPONDING FIELDS OF TABLE lt_shipment
        FOR ALL ENTRIES IN lt_shipdata
        WHERE tknum = lv_tknum
          AND matnr = lt_shipdata-matnr
          AND charg = lt_shipdata-charg
          AND lfimg NE 0
          AND kunnr EQ lv_kunnr.

      IF lt_shipment[] IS NOT INITIAL.
        SELECT *
          FROM zwmdt004
          INTO CORRESPONDING FIELDS OF TABLE lt_004
          FOR ALL ENTRIES IN lt_shipment
          WHERE lgnum = lv_lgnum
            AND tknum = lt_shipment-tknum.
      ELSE.
        lv_subrc = 4.
      ENDIF.

      SORT lt_004 BY matnr charg.
      LOOP AT lt_004 INTO ls_004.
        ls_s004-matnr = ls_004-matnr.
        ls_s004-charg = ls_004-charg.
        ls_s004-lfimg = ls_004-lfimg.
        COLLECT ls_s004 INTO lt_s004.
        CLEAR ls_s004.
      ENDLOOP.
    ENDIF.

    lt_xshipdata[] = lt_shipdata[].
    SORT lt_xshipdata BY pallet.
    DELETE ADJACENT DUPLICATES FROM lt_xshipdata COMPARING pallet.
    LOOP AT lt_xshipdata INTO ls_xshipdata.
      CLEAR : lv_nltyp, lv_nlpla.
      LOOP AT lt_shipdata INTO ls_shipdata WHERE pallet = ls_xshipdata-pallet.
        IF ls_shipdata-zero IS INITIAL AND
          lv_rusak IS INITIAL AND
          ls_shipdata-newch IS INITIAL AND
          ls_shipdata-newbc IS INITIAL AND
          ls_shipdata-newsn IS INITIAL.
          CLEAR : ls_shipdetail, lv_itemid, lv_charg.
          IF ls_shipdata-charg IS NOT INITIAL.
            lv_charg = ls_shipdata-charg.
            IF lv_charg(1) = space.
              lv_charg(1) = '?'.
            ENDIF.
          ENDIF.

          READ TABLE lt_shipdetail INTO ls_shipdetail
                                   WITH KEY material_number = ls_shipdata-matnr
                                            batch           = lv_charg.
          IF sy-subrc = 0.
            lv_itemid = ls_shipdetail-item_id.
          ENDIF.

          CLEAR : ls_shipment, lv_dnqty.
          LOOP AT lt_shipment INTO ls_shipment WHERE matnr = ls_shipdata-matnr
                                                 AND charg = ls_shipdata-charg.
            ADD ls_shipment-lfimg TO lv_dnqty.
          ENDLOOP.

          PERFORM f_check_to_created TABLES lt_s004
                                     USING ls_shipdata-matnr ls_shipdata-charg
                                           ls_shipdata-lfimg lv_dnqty
                                     CHANGING lv_anfme lv_subrc.
          IF lv_subrc = 0.
            SORT lt_shipment BY vbeln posnr.
            CLEAR : ls_shipment.
            LOOP AT lt_shipment INTO ls_shipment WHERE matnr = ls_shipdata-matnr
                                                   AND charg = ls_shipdata-charg.
              lv_lfimg = ls_shipment-lfimg.
              WHILE lv_lfimg > 0.
                IF lv_anfme > 0.
                  CLEAR : ls_004, lv_4lfimg.
                  LOOP AT lt_004 INTO ls_004 WHERE matnr = ls_shipment-matnr
                                               AND charg = ls_shipment-charg
                                               AND vbeln = ls_shipment-vbeln
                                               AND posnr = ls_shipment-posnr.
                    ADD ls_004-lfimg TO lv_4lfimg.

                    IF lv_4lfimg = ls_shipment-lfimg.
                      lv_lfimg = 0.
                      EXIT.
                    ENDIF.
                  ENDLOOP.

                  ls_shipment-lfimg = ls_shipment-lfimg - lv_4lfimg.
                  IF ls_shipment-lfimg <= 0.
                    lv_lfimg = 0.
                    CONTINUE.
                  ENDIF.

                  ls_ltak-lgnum  = ls_to-warehouse_number.
                  ls_ltak-bwlvs  = '101'.
                  ls_ltak-betyp  = 'Z'.
                  ls_ltak-benum  = ls_shipment-vbeln.
                  CONCATENATE ls_shipdata-pallet ls_shipdata-tknum INTO ls_ltak-lznum
                  SEPARATED BY ';'.
                  ls_ltak-drukz  = '45'.
                  lv_commit = space.

                  CLEAR : lt_ltap_creat[].
                  PERFORM f_prepare_new_detail TABLES lt_ltap_creat lt_mlgn
                                               USING ls_shipdata ls_shipment lv_werks
                                                     ls_ltak-lznum '' '' '' lv_lgnum
                                               CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                                        lv_sisa lv_add lv_nltyp lv_nlpla.

                  PERFORM f_create_to TABLES lt_ltap_creat
                                      USING ls_ltak-lgnum ls_ltak-bwlvs ls_ltak-betyp
                                            ls_ltak-benum ls_ltak-lznum ls_ltak-drukz
                                            lv_commit
                                      CHANGING lv_tanum lv_subrc.

                  IF lv_tanum IS NOT INITIAL.
                    p_to_number = lv_tanum.
                    fc_type    = 'S'.
                    fc_message = 'Create TO success'.

                    PERFORM f_save_004 TABLES lt_004
                                       USING lv_tanum ls_to-warehouse_number ls_ltak-lznum
                                             lv_uname '' lv_rusak ''
                                             lv_zdtsul lv_zuzsul lv_zdteul lv_zuzeul
                                             ls_shipdata ls_shipment ls_ltap_creat
                                       CHANGING lv_save.
                    IF lv_save = 0.
                      PERFORM f_print_to USING lv_tanum ls_to-warehouse_number
                                         CHANGING lv_nltyp lv_nlpla.
                    ENDIF.
                    PERFORM f_body_response TABLES pt_to
                                            USING ls_ltap_creat
                                                  lv_itemid ls_shipdata-pallet lv_tanum lv_nlpla
                                                  '' fc_type fc_message.

                    CLEAR : ls_ltap_creat, lv_tanum, lv_itemid.
                    IF lv_add IS NOT INITIAL.
                      ADD 1 TO ls_shipdata-pallet.
                    ENDIF.
                    CONDENSE ls_shipdata-pallet NO-GAPS.
                  ELSE.
                    CLEAR : lv_lfimg, lv_anfme.
                    fc_type    = 'E'.
                    CALL FUNCTION 'ZWMSFM002'
                      EXPORTING
                        pi_subrc    = lv_subrc
                        pi_function = 'L_TO_CREATE_MULTIPLE'
                      IMPORTING
                        pe_message  = fc_message.

                    PERFORM f_body_response TABLES pt_to
                                            USING ls_ltap_creat
                                                  lv_itemid ls_shipdata-pallet  '' ''
                                                  '' fc_type fc_message.
                  ENDIF.
                ELSE.
                  CLEAR : lv_lfimg.
                ENDIF.
              ENDWHILE.
            ENDLOOP.

            PERFORM f_check_quantity TABLES lt_shipment
                                            lt_004
                                     CHANGING lv_anfme.
            WHILE lv_anfme > 0.
              CONCATENATE lv_pallet ls_shipdata-tknum INTO ls_ltak-lznum
              SEPARATED BY ';'.
              CLEAR : lt_ltap_creat[].
              ls_shipment-lfimg = lv_anfme.
              PERFORM f_prepare_new_detail TABLES lt_ltap_creat lt_mlgn
                                           USING ls_shipdata ls_shipment lv_werks
                                                 ls_ltak-lznum '' '' 'X' lv_lgnum
                                           CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                                    lv_sisa lv_add lv_nltyp lv_nlpla.

              PERFORM f_create_to TABLES lt_ltap_creat
                                  USING ls_ltak-lgnum ls_ltak-bwlvs ls_ltak-betyp
                                        ls_ltak-benum ls_ltak-lznum ls_ltak-drukz
                                        lv_commit
                                  CHANGING lv_tanum lv_subrc.

              IF lv_tanum IS NOT INITIAL.
                p_to_number = lv_tanum.
                fc_type    = 'S'.
                fc_message = 'Create TO success'.

                PERFORM f_save_004 TABLES lt_004
                                   USING lv_tanum ls_to-warehouse_number ls_ltak-lznum
                                         lv_uname '' lv_rusak ''
                                         lv_zdtsul lv_zuzsul lv_zdteul lv_zuzeul
                                         ls_shipdata ls_shipment ls_ltap_creat
                                   CHANGING lv_save.
                IF lv_save = 0.
                  PERFORM f_print_to USING lv_tanum ls_to-warehouse_number
                                     CHANGING lv_nltyp lv_nlpla.
                ENDIF.
                PERFORM f_body_response TABLES pt_to
                                        USING ls_ltap_creat
                                              lv_itemid ls_shipdata-pallet lv_tanum lv_nlpla
                                              '' fc_type fc_message.

                CLEAR : ls_ltap_creat, lv_tanum, lv_itemid.
                IF lv_add IS NOT INITIAL.
                  ADD 1 TO lv_pallet.
                ENDIF.
                CONDENSE lv_pallet NO-GAPS.
              ELSE.
                fc_type    = 'E'.
                CALL FUNCTION 'ZWMSFM002'
                  EXPORTING
                    pi_subrc    = lv_subrc
                    pi_function = 'L_TO_CREATE_MULTIPLE'
                  IMPORTING
                    pe_message  = fc_message.

                PERFORM f_body_response TABLES pt_to
                                        USING ls_ltap_creat
                                              lv_itemid lv_pallet '' ''
                                              '' fc_type fc_message.
              ENDIF.
            ENDWHILE.
          ELSE.
            CASE lv_subrc.
              WHEN 3.
                lv_message  = 'Tidak ada quantity outstanding'.
              WHEN 4.
                lv_message  = 'TO tidak terbentuk'.
            ENDCASE.
            PERFORM f_body_response TABLES pt_to
                                    USING ls_ltap_creat
                                          lv_itemid ls_shipdata-pallet '' ''
                                          '' 'E' lv_message.
            fc_type    = 'E'.
            fc_message = lv_message.
          ENDIF.
        ELSE.
          IF lv_rusak IS NOT INITIAL.
            CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
            READ TABLE lt_shipdetail INTO ls_shipdetail
                                     WITH KEY material_number = ls_shipdata-matnr
                                              batch           = ls_shipdata-charg.
            IF sy-subrc = 0.
              lv_itemid = ls_shipdetail-item_id.
            ENDIF.

            SORT lt_shipment BY vbeln.
            READ TABLE lt_shipment INTO ls_shipment
                                   WITH KEY matnr = ls_shipdata-matnr
                                            charg = ls_shipdata-charg.
            IF sy-subrc = 0.
              PERFORM f_proses_unloading_rusak TABLES pt_to lt_mlgn
                                               USING ls_shipdata ls_shipdetail ls_shipment
                                                     ls_to-warehouse_number
                                                     lv_werks lv_pallet lv_itemid lv_uname
                                                     lv_rusak lv_zdtsul lv_zuzsul
                                                     lv_zdteul lv_zuzeul
                                               CHANGING fc_type fc_message.
            ENDIF.
          ENDIF.

          IF ls_shipdata-zero IS NOT INITIAL.
            CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
            READ TABLE lt_shipdetail INTO ls_shipdetail
                                     WITH KEY material_number = ls_shipdata-matnr
                                              batch           = ls_shipdata-charg.
            IF sy-subrc = 0.
              lv_itemid = ls_shipdetail-item_id.
            ENDIF.

            SORT lt_shipment BY vbeln.
            READ TABLE lt_shipment INTO ls_shipment
                                   WITH KEY matnr = ls_shipdata-matnr
                                            charg = ls_shipdata-charg.
            IF sy-subrc = 0.
              PERFORM f_proses_unloading_zero TABLES pt_to lt_mlgn
                                              USING ls_shipdata ls_shipdetail ls_shipment
                                                    ls_to-warehouse_number
                                                    lv_werks lv_pallet lv_itemid lv_uname
                                                    lv_rusak lv_zdtsul lv_zuzsul
                                                    lv_zdteul lv_zuzeul
                                              CHANGING fc_type fc_message.
            ENDIF.
          ENDIF.

          IF ls_shipdata-newbc IS NOT INITIAL.
            CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
            READ TABLE lt_shipdetail INTO ls_shipdetail
                                     WITH KEY material_number = ls_shipdata-matnr
                                              batch           = ls_shipdata-charg.
            IF sy-subrc = 0.
              lv_itemid = ls_shipdetail-item_id.
            ENDIF.

            PERFORM f_proses_unloading_newmaterial TABLES pt_to lt_mlgn
                                                   USING ls_shipdata ls_shipdetail ls_shipment
                                                         ls_to-warehouse_number
                                                         lv_werks lv_pallet lv_itemid lv_uname
                                                         lv_rusak lv_zdtsul lv_zuzsul
                                                         lv_zdteul lv_zuzeul
                                                   CHANGING fc_type fc_message.
          ENDIF.

          IF ls_shipdata-newch IS NOT INITIAL.
            CLEAR : ls_shipdetail, lv_itemid, ls_shipment.
            READ TABLE lt_shipdetail INTO ls_shipdetail
                                     WITH KEY material_number = ls_shipdata-matnr
                                              batch           = ls_shipdata-charg.
            IF sy-subrc = 0.
              lv_itemid = ls_shipdetail-item_id.
            ENDIF.

            PERFORM f_proses_unloading_newbatch TABLES pt_to lt_mlgn
                                                USING ls_shipdata ls_shipdetail ls_shipment
                                                      ls_to-warehouse_number
                                                      lv_werks lv_pallet lv_itemid lv_uname
                                                      lv_rusak lv_zdtsul lv_zuzsul
                                                      lv_zdteul lv_zuzeul
                                                CHANGING fc_type fc_message.
          ENDIF.

          IF ls_shipdata-newsn IS NOT INITIAL.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ELSE.
    PERFORM f_body_response TABLES pt_to
                            USING ls_ltap_creat
                                  lv_itemid ls_shipdata-pallet '' ''
                                  '' 'E' lv_message.
    fc_type    = 'E'.
    fc_message = lv_message.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_NEW_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_new_detail  TABLES   ft_ltap_creat STRUCTURE ltap_creat
                                    ft_mlgn       STRUCTURE mlgn
                           USING    fs_shipdata   TYPE ty_shipment
                                    fs_shipment   TYPE ty_shipment
                                    fu_werks fu_lznum fu_lfimg fu_change fu_end
                                    fu_lgnum
                           CHANGING fs_ltap_creat TYPE ltap_creat
                                    fc_lfimg fc_anfme fc_sisa fc_add fc_nltyp fc_nlpla.
  DATA : lv_lhmg1 TYPE mlgn-lhmg1.

  fs_ltap_creat-werks  = fu_werks.
  fs_ltap_creat-matnr  = fs_shipment-matnr.
  fs_ltap_creat-lgort  = '1000'.
  fs_ltap_creat-charg  = fs_shipment-charg.

  IF fu_lfimg IS INITIAL.
    PERFORM f_pallet_capacity TABLES ft_mlgn
                              USING fs_shipment-matnr fs_shipment-lfimg
                              CHANGING lv_lhmg1 fc_sisa.

    IF fc_anfme < lv_lhmg1.
      fs_ltap_creat-anfme  = fc_anfme.
      fc_anfme = fc_anfme - lv_lhmg1.
      fc_add = 'X'.
    ELSE.
      IF fc_lfimg < fs_shipment-lfimg.
        IF fc_lfimg > lv_lhmg1.
          fs_ltap_creat-anfme  = lv_lhmg1.
          fc_anfme = fc_anfme - lv_lhmg1.
        ELSE.
          fs_ltap_creat-anfme  = fc_lfimg.
          fc_anfme = fc_anfme - fc_lfimg.
          CLEAR fc_add.
        ENDIF.
      ELSE.
        fs_ltap_creat-anfme  = lv_lhmg1.
        fc_anfme = fc_anfme - lv_lhmg1.
        IF fc_sisa > 0.
          CLEAR fc_add.
        ELSE.
          fc_add = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    fc_lfimg = fc_lfimg - lv_lhmg1.

    fs_ltap_creat-nltyp  = fc_nltyp.
    fs_ltap_creat-nlpla  = fc_nlpla.
    fs_ltap_creat-vlpla  = fs_shipment-vbeln.
    PERFORM f_unit_conversion_input USING fs_shipment-vrkme
                                    CHANGING fs_ltap_creat-altme.
  ELSE.
    CASE fu_change.
      WHEN 'RUSAK'.
        IF fu_lgnum = 'C40'.
          DATA(lv_nltyp) = 'K01'.
          DATA(lv_nlber) = 'COM'.
          DATA(lv_nlpla) = 'KARANTINA'.
        ELSE.
          lv_nltyp = 'KOR'.
          lv_nlber = 'COM'.
          lv_nlpla = 'BA AMB'.
        ENDIF.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-nltyp  = lv_nltyp.  "'KOR'.
        fs_ltap_creat-nlber  = lv_nlber.  "'COM'.
        fs_ltap_creat-nlpla  = lv_nlpla.  "'BA AMB'.
        fs_ltap_creat-vlpla  = fs_shipment-vbeln.
        PERFORM f_unit_conversion_input USING fs_shipment-vrkme
                                        CHANGING fs_ltap_creat-altme.
      WHEN 'NEWCH'.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-nltyp  = 'K01'.
        fs_ltap_creat-nlber  = 'COM'.
        fs_ltap_creat-nlpla  = 'KARANTINA'.
        fs_ltap_creat-vlpla  = fs_shipdata-tknum.
        fs_ltap_creat-matnr  = fs_shipdata-matnr.
        fs_ltap_creat-charg  = fs_shipdata-charg.
        PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                        CHANGING fs_ltap_creat-altme.
      WHEN 'NEWBC'.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-vlpla  = fs_shipdata-tknum.
        fs_ltap_creat-matnr  = fs_shipdata-matnr.
        fs_ltap_creat-charg  = fs_shipdata-charg.
        PERFORM f_unit_conversion_input USING fs_shipdata-vrkme
                                        CHANGING fs_ltap_creat-altme.
    ENDCASE.
  ENDIF.

  fs_ltap_creat-vltyp  = '902'.
  fs_ltap_creat-vlber  = '001'.
  fs_ltap_creat-letyp  = 'SP'.
  fs_ltap_creat-posnr  = fs_shipment-posnr.
  fs_ltap_creat-ablad  = fu_lznum.
  CONDENSE fs_ltap_creat-ablad NO-GAPS.

  APPEND fs_ltap_creat TO ft_ltap_creat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK
*&---------------------------------------------------------------------*
FORM f_check  USING    fu_value
              CHANGING fc_subrc.
  DATA : lv_check(10),
         lv_value   TYPE string.

  IF fc_subrc = 0.
    lv_check = 'NUMERIC'.
    lv_value = fu_value.

    CALL FUNCTION 'ZWMSFM006'
      EXPORTING
        pi_check = lv_check
        pi_value = lv_value
      IMPORTING
        pe_subrc = fc_subrc.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POST_SIR
*&---------------------------------------------------------------------*
FORM f_proses_post_sir  TABLES   ft_sird STRUCTURE zwmsst012
                        USING    fu_data
                        CHANGING fc_pidsap fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_sirh      TYPE ty_sirh,
         lt_sird      TYPE STANDARD TABLE OF zwmsst012.

  DATA : lv_number  TYPE nrnr VALUE '01',
         lv_object  TYPE nrobj VALUE 'LVS_IVNUM',
         lv_sobject TYPE nrsobj,
         lv_ivnum   TYPE lvs_ivnum,
         lv_return  TYPE nrreturn,
         lv_ivpos   TYPE lvs_ivpos,
         ls_link    LIKE link,
         lt_inp     TYPE STANDARD TABLE OF linp_vb,
         lt_inv     TYPE STANDARD TABLE OF linv_vb,
         lv_subrc   TYPE sy-subrc.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_sirh ).

  SELECT lgnum, lgtyp, lgpla INTO TABLE @DATA(lt_lagp)
    FROM lagp FOR ALL ENTRIES IN @ft_sird
    WHERE lgnum = @ls_sirh-lgnum
      AND lgtyp = @ls_sirh-lgtyp
      AND lgpla = @ft_sird-lgpla
      AND ivivo NE @space.

  IF sy-subrc = 0.
    fc_type = 'E'.
    fc_message = 'Storage bin already proposed for inventory'.

  ELSE.
    lv_sobject = ls_sirh-lgnum.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr        = lv_number
        object             = lv_object
        subobject          = lv_sobject
      IMPORTING
        number             = lv_ivnum
        returncode         = lv_return
      EXCEPTIONS
        interval_not_found = 1.

    IF sy-subrc <> 0.
      fc_type = 'E'.
      fc_message = 'Number Ranges Error'.

    ELSE.
      SELECT a~lgnum, a~lqnum, a~matnr, a~werks, a~charg,
             a~lgtyp, a~lgpla, a~bdatu, a~vfdat, b~kzinv
        INTO TABLE @DATA(lt_lqua)
        FROM lqua AS a JOIN t331 AS b ON b~lgnum = a~lgnum AND
                                         b~lgtyp = a~lgtyp
        FOR ALL ENTRIES IN @ft_sird
        WHERE a~lgnum = @ls_sirh-lgnum
          AND a~lgtyp = @ls_sirh-lgtyp
          AND a~lgpla = @ft_sird-lgpla.

      ls_link-lgnum  = ls_sirh-lgnum.
      ls_link-ivnum  = lv_ivnum.
      ls_link-istat  = 'N'.
      ls_link-nvers  = '00'.
      ls_link-lgtyp  = ls_sirh-lgtyp.
      ls_link-pdatu  = sy-datum.

      LOOP AT ft_sird INTO DATA(ls_sird).
        ADD 1 TO lv_ivpos.
        APPEND INITIAL LINE TO lt_inp ASSIGNING FIELD-SYMBOL(<fs_inp>).
        <fs_inp>-mandt  = sy-mandt.
        <fs_inp>-lgnum  = ls_sirh-lgnum.
        <fs_inp>-ivnum  = lv_ivnum.
        <fs_inp>-ivpos  = lv_ivpos.
        <fs_inp>-istat  = 'N'.
        <fs_inp>-lgpla  = ls_sird-lgpla.
*        <fs_inp>-idatu  = sy-datum.
        <fs_inp>-gebkz  = 'B'.        "'X'
        <fs_inp>-anzqu  = '1'.

        IF line_exists( lt_lqua[ lgnum = ls_sirh-lgnum
                                 lgtyp = ls_sirh-lgtyp
                                 lgpla = ls_sird-lgpla ] ).
          LOOP AT lt_lqua INTO DATA(ls_lqua)
                          WHERE lgnum = ls_sirh-lgnum
                            AND lgtyp = ls_sirh-lgtyp
                            AND lgpla = ls_sird-lgpla.
            APPEND INITIAL LINE TO lt_inv ASSIGNING FIELD-SYMBOL(<fs_inv>).
            MOVE-CORRESPONDING ls_lqua TO <fs_inv>.
            <fs_inv>-lgnum  = ls_sirh-lgnum.
            <fs_inv>-ivnum  = lv_ivnum.
            <fs_inv>-ivpos  = lv_ivpos.
            <fs_inv>-nanum  = '00'.
            <fs_inv>-istat  = 'N'.
            <fs_inv>-nvers  = '00'.
            <fs_inv>-iseit  = '0000'.
            <fs_inv>-lgtyp  = ls_sirh-lgtyp.
            <fs_inv>-lgpla  = ls_sird-lgpla.
            <fs_inv>-kzinv  = ls_lqua-kzinv.  "'ST'.
          ENDLOOP.

        ELSE.
          APPEND INITIAL LINE TO lt_inv ASSIGNING <fs_inv>.
          <fs_inv>-lgnum  = ls_sirh-lgnum.
          <fs_inv>-ivnum  = lv_ivnum.
          <fs_inv>-ivpos  = lv_ivpos.
          <fs_inv>-lgtyp  = ls_sirh-lgtyp.
          <fs_inv>-lgpla  = ls_sird-lgpla.
          <fs_inv>-istat  = 'N'.
          <fs_inv>-kzinv  = 'ST'.
        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'L_BUCHEN_HINZUFUEGEN'
        EXPORTING
          xlink = ls_link
        TABLES
          inp   = lt_inp
          inv   = lt_inv.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.

        fc_pidsap = lv_ivnum.
        fc_type = 'S'.
        CONCATENATE 'System inventory record' lv_ivnum 'created'
          INTO fc_message SEPARATED BY space.

        LOOP AT lt_inp ASSIGNING <fs_inp>.
          <fs_inp>-gebkz  = 'X'.
        ENDLOOP.

        CALL FUNCTION 'L_AKTIVIEREN_VERAENDERN'
          EXPORTING
            xlink = ls_link
          TABLES
            inp   = lt_inp
            inv   = lt_inv.
        COMMIT WORK AND WAIT.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_POSTING
*&---------------------------------------------------------------------*
FORM f_transfer_posting  USING    fu_lgnum fu_tanum fu_tbnum.
  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         materialdocument	TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         return           TYPE STANDARD TABLE OF bapiret2,
         ls_item          LIKE LINE OF goodsmvt_item,
         ls_return        LIKE LINE OF return.

  DATA : lt_resb TYPE STANDARD TABLE OF resb,
         ls_resb LIKE LINE OF lt_resb,
         lt_ltap TYPE STANDARD TABLE OF ltap,
         ls_ltap LIKE LINE OF lt_ltap.

  DATA : lv_tbktx TYPE ltbk-tbktx,
         lv_rsnum TYPE resb-rsnum.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  SELECT SINGLE tbktx
    FROM ltbk
    INTO lv_tbktx
    WHERE lgnum = fu_lgnum
      AND tbnum = fu_tbnum.

  lv_rsnum  = lv_tbktx(10).

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    WHERE rsnum = lv_rsnum.

  goodsmvt_code              = '04'.
  goodsmvt_header-doc_date   = sy-datum.
  goodsmvt_header-pstng_date = sy-datum.
  goodsmvt_header-pr_uname   = sy-uname.

  LOOP AT lt_ltap INTO ls_ltap.
    ls_item-material           = ls_ltap-matnr.
    ls_item-plant              = ls_ltap-werks.
    ls_item-stge_loc           = ls_ltap-lgort.
    CLEAR ls_resb.
    READ TABLE lt_resb INTO ls_resb
                       WITH KEY rspos = ls_ltap-rspos.
    IF sy-subrc  = 0.
      ls_item-move_stloc         = ls_resb-umlgo.
    ENDIF.
    ls_item-move_type          = '311'.
    ls_item-entry_qnt          = ls_ltap-nista.
    ls_item-entry_uom          = ls_ltap-meins.
    ls_item-batch              = ls_ltap-charg.

*    ls_item-no_transfer_req    = 'X'.
    APPEND ls_item TO goodsmvt_item.
    CLEAR ls_item.
  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = goodsmvt_header
      goodsmvt_code    = goodsmvt_code
    IMPORTING
      materialdocument = materialdocument
      matdocumentyear  = matdocumentyear
    TABLES
      goodsmvt_item    = goodsmvt_item
      return           = return.

  IF materialdocument IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DATE
*&---------------------------------------------------------------------*
FORM f_check_date  USING    fu_date
                   CHANGING fc_date.
  DATA : lv_datum   TYPE sy-datum.

  lv_datum  = fu_date.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_datum
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.

  IF sy-subrc = 0.
    fc_date = lv_datum.
  ELSE.
    fc_date = sy-datum.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_INVALID_DATE
*&---------------------------------------------------------------------*
FORM f_invalid_date  USING    fu_datum fu_uzeit
                     CHANGING fc_date fc_datum fc_uzeit.
  IF fc_date = 'Invalid date'.
    fc_datum = fu_datum.
    fc_uzeit = fu_uzeit.
    CLEAR fc_date.
    WRITE fu_uzeit(4) TO fc_date USING EDIT MASK '__:__'.
    CONCATENATE fu_datum fc_date INTO fc_date
    SEPARATED BY space.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_STOCK_CATEGORY
*&---------------------------------------------------------------------*
FORM f_get_stock_category  USING    fu_bestq fu_lgnum fu_matnr fu_charg
                           CHANGING fc_bestq.
  DATA : lt_lqua    TYPE STANDARD TABLE OF lqua.
  DATA : lv_lines1 TYPE i,
         lv_lines2 TYPE i.

  IF fu_bestq IS NOT INITIAL.
    fc_bestq = fu_bestq.
  ELSE.
    SELECT *
      FROM lqua
      INTO CORRESPONDING FIELDS OF TABLE lt_lqua
      WHERE lgnum = fu_lgnum
        AND matnr = fu_matnr
        AND charg = fu_charg.
    IF sy-subrc = 0.
      DESCRIBE TABLE lt_lqua LINES lv_lines1.
      PERFORM f_delete_lqua TABLES lt_lqua
                            USING '' lv_lines1 lv_lines1
                            CHANGING fc_bestq.

      DESCRIBE TABLE lt_lqua LINES lv_lines2.
      IF lv_lines1 <> lv_lines2.
        fc_bestq = space.
      ELSE.
        PERFORM f_delete_lqua TABLES lt_lqua
                              USING 'Q' lv_lines1 lv_lines2
                              CHANGING fc_bestq.

        DESCRIBE TABLE lt_lqua LINES lv_lines2.
        IF lv_lines1 <> lv_lines2.
          fc_bestq = 'Q'.
        ELSE.
          PERFORM f_delete_lqua TABLES lt_lqua
                                USING 'S' lv_lines1 lv_lines2
                                CHANGING fc_bestq.

          DESCRIBE TABLE lt_lqua LINES lv_lines2.
          IF lv_lines1 <> lv_lines2.
            fc_bestq = 'S'.
          ELSE.
            PERFORM f_delete_lqua TABLES lt_lqua
                                  USING 'R' lv_lines1 lv_lines2
                                  CHANGING fc_bestq.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      fc_bestq = space.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_LQUA
*&---------------------------------------------------------------------*
FORM f_delete_lqua  TABLES   ft_lqua  STRUCTURE lqua
                    USING    fu_bestq fu_lines1 fu_lines2
                    CHANGING fc_bestq.
  DATA : ls_lqua  TYPE lqua.

  IF fu_lines1 = fu_lines2.
    DELETE ft_lqua WHERE bestq = fu_bestq.
    IF ft_lqua[] IS INITIAL.
      fc_bestq = fu_bestq.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PICKING_COMPLETE_GROUPING
*&---------------------------------------------------------------------*
FORM f_picking_complete_grouping  TABLES   ft_pickd STRUCTURE zwmsst003
                                  USING    fu_lgnum fu_lznum fu_rpfaess
                                           fu_rpkist.
  DATA : lt_ltak      TYPE STANDARD TABLE OF ltak,
         ls_ltak      LIKE LINE OF lt_ltak,
         lt_likp      TYPE STANDARD TABLE OF likp,
         ls_likp      LIKE LINE OF lt_likp,
         ls_pickd     TYPE zwmsst003,
         ls_pickd_ori TYPE zwmsst003.

  DATA : lv_rpfaess TYPE likp-/bev1/rpfaess,
         lv_rpkist  TYPE likp-/bev1/rpkist,
         lv_subrc   TYPE sy-subrc,
         lv_queue   TYPE ltak-queue.
  DATA: ls_zwmdt017 TYPE zwmdt017.

  ls_zwmdt017-lgnum = fu_lgnum.
  ls_zwmdt017-lznum = fu_lznum.
  CLEAR: lv_subrc.
  SELECT SINGLE * INTO ls_zwmdt017 FROM zwmdt017
    WHERE lgnum = ls_zwmdt017-lgnum
      AND lznum = ls_zwmdt017-lznum.
  IF sy-subrc EQ 0.
    TRY .
        UPDATE zwmdt017 SET rpcontp  = fu_rpfaess
                            rpsonstp   = fu_rpkist
                            aedat = sy-datum
                            aezet = sy-uzeit
                            aenam = sy-uname
                    WHERE lgnum = ls_zwmdt017-lgnum
                      AND lznum = ls_zwmdt017-lznum.

      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ELSE.
    ls_zwmdt017-rpcontp  = fu_rpfaess.
    ls_zwmdt017-rpsonstp   = fu_rpkist.
    ls_zwmdt017-erdat = sy-datum.
    ls_zwmdt017-erzet = sy-uzeit.
    ls_zwmdt017-ernam = sy-uname.
    TRY .
        MODIFY zwmdt017 FROM ls_zwmdt017.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ENDIF.
*****  ls_pickd-to_number = fu_lznum.
*****  ls_pickd-koli_ori = fu_rpfaess.
*****  ls_pickd-koli_ecer = fu_rpfaess.
*****  IF lv_subrc = 0.
*****    ls_pickd-type = 'S'.
*****    ls_pickd-message = 'Data already completed'.
*****  ELSE.
*****    ls_pickd-type = 'E'.
*****    ls_pickd-message = 'Error in completed data'.
*****  ENDIF.
*****  IF ft_pickd[] IS NOT INITIAL.
*****    LOOP AT ft_pickd INTO ls_pickd_ori WHERE to_number = ls_pickd-to_number.
*****      ls_pickd_ori-type = ls_pickd-type.
*****      ls_pickd_ori-message = ls_pickd-message.
*****      MODIFY ft_pickd FROM ls_pickd_ori
*****                      TRANSPORTING type message
*****                      WHERE to_number = fu_lznum.
*****    ENDLOOP.
*****  ELSE.
*****    APPEND  ls_pickd TO ft_pickd.
*****  ENDIF.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fu_lgnum
      AND lznum = fu_lznum.

  SORT lt_ltak BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING vbeln.
  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM likp
      INTO CORRESPONDING FIELDS OF TABLE lt_likp
      FOR ALL ENTRIES IN lt_ltak
      WHERE vbeln = lt_ltak-vbeln.
  ENDIF.

  LOOP AT lt_ltak INTO ls_ltak.
    CLEAR : ls_likp, lv_rpfaess, lv_rpkist.
    READ TABLE lt_likp INTO ls_likp
                       WITH KEY vbeln = ls_ltak-vbeln.
    IF sy-subrc = 0.
      lv_rpfaess = ls_likp-/bev1/rpfaess + fu_rpfaess.
      lv_rpkist  = ls_likp-/bev1/rpkist + fu_rpkist.
    ENDIF.

    TRY .
        UPDATE likp SET /bev1/rpfaess  = lv_rpfaess
                        /bev1/rpkist   = lv_rpkist
                    WHERE vbeln = ls_ltak-vbeln.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.

    IF lv_subrc = 0.
      ls_pickd-type = 'S'.
      ls_pickd-message = 'Data already completed'.
    ELSE.
      ls_pickd-type = 'E'.
      ls_pickd-message = 'Error in completed data'.
    ENDIF.

    MODIFY ft_pickd FROM ls_pickd
                    TRANSPORTING type message
                    WHERE to_number = fu_lznum.
    CLEAR lv_subrc.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_QUANTITY
*&---------------------------------------------------------------------*
FORM f_check_quantity  TABLES   ft_shipment TYPE STANDARD TABLE
                                ft_004 STRUCTURE zwmdt004
                       CHANGING fc_anfme.
  DATA : lt_shipment  TYPE STANDARD TABLE OF ty_shipment,
         ls_shipment  TYPE ty_shipment,
         ls_004       TYPE zwmdt004,
         lt_xshipment TYPE STANDARD TABLE OF ty_shipment,
         ls_xshipment LIKE LINE OF lt_xshipment.

  DATA : lv_lfimg   TYPE lips-lfimg.

  lt_xshipment[] = lt_shipment[] = ft_shipment[].
  SORT lt_xshipment BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_xshipment COMPARING matnr charg.
  LOOP AT lt_xshipment INTO ls_xshipment.
    CLEAR lv_lfimg.
    LOOP AT lt_shipment INTO ls_shipment WHERE matnr = ls_xshipment-matnr
                                           AND charg = ls_xshipment-charg.
      ADD ls_shipment-lfimg TO lv_lfimg.
    ENDLOOP.
    LOOP AT ft_004 INTO ls_004 WHERE matnr = ls_xshipment-matnr
                                 AND charg = ls_xshipment-charg.
      lv_lfimg = lv_lfimg - ls_004-lfimg.
    ENDLOOP.
  ENDLOOP.
  IF lv_lfimg = 0.
    fc_anfme = lv_lfimg.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECKER_CONFIRM
*&---------------------------------------------------------------------*
FORM f_checker_confirm  TABLES   ft_check  STRUCTURE zwmsst006
                                 ft_checkd STRUCTURE zwmsst006
                        USING    fu_warehouse_number
                                 fu_to_number
                                 fu_delivery_number.
  DATA : ls_checkd    TYPE zwmsst006,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      TYPE ltap,
         ls_ltak      TYPE ltak,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf.

  DATA : lv_qdatu     TYPE ltap-qdatu,
         lv_qzeit     TYPE ltap-qzeit,
         lv_qname     TYPE ltap-qname,
         lv_matnr     TYPE ltap-matnr,
         lv_charg     TYPE ltap-charg,
         lv_nista     TYPE ltap-nista,
         lv_ndifa     TYPE ltap-ndifa,
         lv_xnista    TYPE ltap-nista,
         lv_xkzdif    TYPE ltap-kzdif,
         lv_kzdif     TYPE ltap-kzdif,
         lv_altme     TYPE ltap-altme,
         lv_subrc     TYPE sy-subrc,
         lv_vbeln     TYPE ltak-vbeln,
         lv_tbnum     TYPE ltak-tbnum,
         lv_endat     TYPE ltak-endat,
         lv_enuzt     TYPE ltak-enuzt,
         lv_wadat_ist TYPE likp-wadat_ist.

  LOOP AT ft_checkd INTO ls_checkd.
    PERFORM f_datetime USING ls_checkd-checking_start
                       CHANGING lv_endat lv_enuzt.
    PERFORM f_datetime USING ls_checkd-checking_end
                       CHANGING lv_qdatu lv_qzeit.
    lv_qname  = ls_checkd-user_name.

    PERFORM f_check USING ls_checkd-quantity_satuan
                    CHANGING lv_subrc.
    PERFORM f_check USING ls_checkd-quantity_carton
                    CHANGING lv_subrc.

    IF lv_subrc = 0.
      SELECT SINGLE *
        FROM ltak
        INTO CORRESPONDING FIELDS OF ls_ltak
        WHERE lgnum = fu_warehouse_number
          AND tanum = fu_to_number.

      SELECT *   "SINGLE matnr charg nista altme
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        WHERE lgnum = fu_warehouse_number
          AND tanum = fu_to_number
          AND matnr = ls_checkd-material_number
          AND charg = ls_checkd-batch.
*          AND tapos = ls_checkd-to_item.

      IF sy-subrc = 0.
        PERFORM f_quantity_calculate USING fu_warehouse_number
                                           ls_checkd-material_number
                                           ls_checkd-batch
                                           ls_checkd-quantity_satuan
                                           ls_checkd-uom_satuan
                                           ls_checkd-quantity_carton
                                           ls_checkd-uom_carton
                                     CHANGING lv_nista.
        lv_kzdif = ls_checkd-difference_indicator.
      ENDIF.

      LOOP AT lt_ltap INTO ls_ltap.
        lv_xnista = ls_ltap-nista.
        IF lv_nista < ls_ltap-nista.
          lv_ndifa = lv_xnista - lv_nista.
          lv_xnista = lv_nista.
        ENDIF.
        IF lv_ndifa = 0.
          lv_xkzdif = space.
        ELSE.
          lv_xkzdif = lv_kzdif.
        ENDIF.

        PERFORM f_prepare_confirm_to TABLES lt_ltap_conf
                                     USING ls_checkd fu_warehouse_number
                                           fu_to_number ls_ltap-tapos
                                           ls_ltap-matnr ls_ltap-charg lv_xnista
                                           ls_ltap-altme lv_ndifa lv_xkzdif ''.

        lv_nista = lv_nista - ls_ltap-nista.

        PERFORM f_confirm_to TABLES lt_ltap_conf
                             USING fu_warehouse_number fu_to_number
                             CHANGING lv_subrc.
      ENDLOOP.

      IF lv_subrc = 0.
        IF ls_ltak-endat IS INITIAL.
          TRY.
              UPDATE ltak SET endat = lv_endat
                              enuzt = lv_enuzt
                          WHERE lgnum = fu_warehouse_number
                            AND tanum = fu_to_number.
            CATCH cx_sy_open_sql_db.
          ENDTRY.
        ENDIF.

        TRY .
            UPDATE ltap SET qdatu = lv_qdatu
                            qzeit = lv_qzeit
                            qname = lv_qname
                            pquit = 'X'
                        WHERE lgnum = fu_warehouse_number
                          AND tanum = fu_to_number
                          AND matnr = ls_checkd-material_number
                          AND charg = ls_checkd-batch.
*                          AND tapos = ls_checkd-to_item.
          CATCH cx_sy_open_sql_db.
            lv_subrc = 4.
        ENDTRY.
        IF lv_subrc = 0.
          ls_checkd-type    = 'S'.
          ls_checkd-message = 'Checking success'.
        ELSE.
          ls_checkd-type    = 'E'.
          ls_checkd-message = 'Checking error'.
        ENDIF.
      ELSE.
        ls_checkd-type    = 'E'.
        CALL FUNCTION 'ZWMSFM002'
          EXPORTING
            pi_subrc    = lv_subrc
            pi_function = 'L_TO_CONFIRM'
          IMPORTING
            pe_message  = ls_checkd-message.
      ENDIF.

      APPEND ls_checkd TO ft_check.
      CLEAR : ls_checkd, lv_subrc.
    ELSE.
      ls_checkd-type     = 'E'.
      ls_checkd-message  = 'Input quantity salah'.
      APPEND ls_checkd TO ft_check.
      CLEAR : ls_checkd.
    ENDIF.
  ENDLOOP.

*  COMMIT WORK AND WAIT.

  IF lv_subrc = 0.
    SELECT SINGLE *
      FROM ltap
      INTO CORRESPONDING FIELDS OF ls_ltap
      WHERE lgnum = fu_warehouse_number
        AND tanum = fu_to_number
        AND pquit = space.
    IF sy-subrc <> 0.
      TRY .
          UPDATE ltak SET kquit = 'X'
                      WHERE lgnum = fu_warehouse_number
                        AND tanum = fu_to_number.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      SELECT SINGLE vbeln tbnum
        FROM ltak
        INTO (lv_vbeln, lv_tbnum)
        WHERE lgnum = fu_warehouse_number
          AND tanum = fu_to_number.


      IF lv_vbeln IS NOT INITIAL.
        SELECT SINGLE wadat_ist FROM likp
          INTO lv_wadat_ist
          WHERE vbeln = lv_vbeln.
        IF lv_wadat_ist IS INITIAL.
          IF fu_warehouse_number <> '190'.
            PERFORM f_pgi USING lv_vbeln
                          CHANGING lv_subrc.
          ENDIF.
        ELSE.
          ls_checkd-type    = 'E'.
          ls_checkd-message = 'Already PGI'.
          APPEND ls_checkd TO ft_check.
          CLEAR : ls_checkd.
        ENDIF.
      ELSEIF lv_tbnum IS NOT INITIAL.
*        IF ls_checker-warehouse_number = '190'.
*          PERFORM f_transfer_posting USING ls_checker-warehouse_number
*                                           ls_checker-to_number lv_tbnum.
*        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECKER_CONFIRM_GROUP
*&---------------------------------------------------------------------*
FORM f_checker_confirm_group  TABLES   ft_check  STRUCTURE zwmsst006
                                       ft_checkd STRUCTURE zwmsst006
                              USING    fu_warehouse_number
                                       fu_to_number
                                       fu_delivery_number.

  TYPES : BEGIN OF ty_return,
            tanum TYPE ltak-tanum.
            INCLUDE STRUCTURE zwmsst006.
          TYPES : END OF ty_return.

  DATA : lt_ltak      TYPE STANDARD TABLE OF ltak,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         lt_xltap     TYPE STANDARD TABLE OF ltap,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         ls_ltak      LIKE LINE OF lt_ltak,
         ls_ltap      LIKE LINE OF lt_ltap,
         ls_xltap     LIKE LINE OF lt_xltap,
         ls_checkd    TYPE zwmsst006.

  DATA : lt_return TYPE STANDARD TABLE OF ty_return,
         ls_return LIKE LINE OF lt_return.

  DATA : lv_subrc  TYPE sy-subrc,
         lv_nista  TYPE ltap-nista,
         lv_xnista TYPE ltap-nista,
         lv_ndifa  TYPE ltap-ndifa,
         lv_endat  TYPE ltak-endat,
         lv_enuzt  TYPE ltak-enuzt,
         lv_qdatu  TYPE ltap-qdatu,
         lv_qzeit  TYPE ltap-qzeit,
         lv_qname  TYPE ltap-qname,
         lv_kzdif  TYPE ltap-kzdif,
         lv_xkzdif TYPE ltap-kzdif.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fu_warehouse_number
      AND lznum = fu_to_number.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum.
  ENDIF.

  SORT lt_ltap BY matnr charg tanum.
  LOOP AT lt_ltap INTO ls_ltap.
    ls_xltap-lgnum   = ls_ltap-lgnum.
    ls_xltap-matnr   = ls_ltap-matnr.
    ls_xltap-charg   = ls_ltap-charg.
    ls_xltap-vsola   = ls_ltap-vsola.
    ls_xltap-altme   = ls_ltap-altme.
    COLLECT ls_xltap INTO lt_xltap.
    CLEAR ls_xltap.
  ENDLOOP.

  LOOP AT ft_checkd INTO ls_checkd.
    PERFORM f_datetime USING ls_checkd-checking_start
                       CHANGING lv_endat lv_enuzt.
    PERFORM f_datetime USING ls_checkd-checking_end
                       CHANGING lv_qdatu lv_qzeit.
    lv_qname  = ls_checkd-user_name.

    PERFORM f_check USING ls_checkd-quantity_satuan
                    CHANGING lv_subrc.
    PERFORM f_check USING ls_checkd-quantity_carton
                    CHANGING lv_subrc.

    IF lv_subrc = 0.
      READ TABLE lt_xltap INTO ls_xltap INDEX ls_checkd-to_item.
      IF sy-subrc = 0.
        PERFORM f_quantity_calculate USING fu_warehouse_number
                                           ls_xltap-matnr ls_xltap-charg
                                           ls_checkd-quantity_satuan
                                           ls_checkd-uom_satuan
                                           ls_checkd-quantity_carton
                                           ls_checkd-uom_carton
                                     CHANGING lv_nista.
        lv_kzdif = ls_checkd-difference_indicator.

        LOOP AT lt_ltap INTO ls_ltap WHERE matnr = ls_xltap-matnr
                                       AND charg = ls_xltap-charg.
          lv_xnista = ls_ltap-nista.
          IF lv_nista < ls_ltap-nista.
            lv_ndifa = lv_xnista - lv_nista.
            lv_xnista = lv_nista.
          ENDIF.
*          ls_checkd-to_item = ls_ltap-tapos.
          IF lv_ndifa = 0.
            lv_xkzdif = space.
          ELSE.
            lv_xkzdif = lv_kzdif.
          ENDIF.
          PERFORM f_prepare_confirm_to TABLES lt_ltap_conf
                                       USING ls_checkd fu_warehouse_number
                                             ls_ltap-tanum ls_ltap-tapos
                                             ls_ltap-matnr ls_ltap-charg
                                             lv_xnista ls_ltap-altme
                                             lv_ndifa lv_xkzdif 'X'.

          lv_nista = lv_nista - ls_ltap-nista.

          PERFORM f_confirm_to TABLES lt_ltap_conf
                               USING fu_warehouse_number ls_ltap-tanum
                               CHANGING lv_subrc.

          IF lv_subrc = 0.
            IF ls_ltak-endat IS INITIAL.
              TRY.
                  UPDATE ltak SET endat = lv_endat
                                  enuzt = lv_enuzt
                              WHERE lgnum = fu_warehouse_number
                                AND tanum = ls_ltap-tanum.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
            ENDIF.

            TRY .
                UPDATE ltap SET qdatu = lv_qdatu
                                qzeit = lv_qzeit
                                qname = lv_qname
                                pquit = 'X'
                            WHERE lgnum = fu_warehouse_number
                              AND tanum = ls_ltap-tanum
                              AND tapos = ls_ltap-tapos.
              CATCH cx_sy_open_sql_db.
                lv_subrc = 4.
            ENDTRY.

            IF lv_subrc = 0.
              ls_return-type    = 'S'.
              ls_return-message = 'Checking success'.
            ELSE.
              ls_return-tanum   = ls_ltap-tanum.
              ls_return-type    = 'E'.
              ls_return-message = 'Checking error'.
            ENDIF.
          ELSE.
            ls_return-tanum   = ls_ltap-tanum.
            ls_return-type    = 'E'.
            CALL FUNCTION 'ZWMSFM002'
              EXPORTING
                pi_subrc    = lv_subrc
                pi_function = 'L_TO_CONFIRM'
              IMPORTING
                pe_message  = ls_return-message.
          ENDIF.
          APPEND ls_return TO lt_return.
          CLEAR : ls_return, lv_subrc.
        ENDLOOP.
      ENDIF.
    ELSE.
      ls_return-type    = 'E'.
      ls_return-message = 'Input quantity salah'.
      APPEND ls_return TO lt_return.
      CLEAR : ls_return.
    ENDIF.

    READ TABLE lt_return INTO ls_return
                         WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      ls_checkd-type    = 'S'.
      ls_checkd-message = 'Checking success'.
    ELSE.
      ls_checkd-type    = 'E'.
      ls_checkd-message = 'TO :'.
      LOOP AT lt_return INTO ls_return WHERE type = 'E'.
        ls_checkd-message = |{ ls_checkd-message } { ls_return-tanum }|.
      ENDLOOP.
      ls_checkd-message = |{ ls_checkd-message } { 'gagal confirm' }|.
    ENDIF.
    APPEND ls_checkd TO ft_check.
    CLEAR ls_checkd.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  IF lv_subrc = 0.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum
        AND pquit = space.
    IF sy-subrc <> 0.
      LOOP AT lt_ltak INTO ls_ltak.
        TRY .
            UPDATE ltak SET kquit = 'X'
                        WHERE lgnum = ls_ltak-lgnum
                          AND tanum = ls_ltak-tanum.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        IF ls_ltak-vbeln IS NOT INITIAL.
          IF fu_warehouse_number <> '190'.
            PERFORM f_pgi USING ls_ltak-vbeln
                          CHANGING lv_subrc.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECKER_COMPLETE
*&---------------------------------------------------------------------*
FORM f_checker_complete  USING    p_json
                         CHANGING pe_check   STRUCTURE zwmsst007.
  DATA : lt_check  TYPE STANDARD TABLE OF zwmsst006,
         ls_check  LIKE LINE OF lt_check,
         ls_ltak   TYPE ltak,
         ls_likp   TYPE likp,
         lt_t336t  TYPE STANDARD TABLE OF t336t,
         ls_t336t  LIKE LINE OF lt_t336t,
         rspar_tab TYPE TABLE OF rsparams,
         ls_ekbe   TYPE ekbe,
         ls_lips   TYPE lips,
         ls_ekpo   TYPE ekpo,
         ls_vbfa   TYPE vbfa.

  DATA : lv_subrc TYPE sy-subrc,
         lv_error.

  DATA : lv_rpcont  TYPE likp-/bev1/rpcont,
         lv_rpsonst TYPE likp-/bev1/rpsonst.

  SELECT *
    FROM t336t
    INTO CORRESPONDING FIELDS OF TABLE lt_t336t
    WHERE spras = sy-langu
      AND lgnum = pe_check-warehouse_number.

  SELECT SINGLE *
    FROM ltak
    INTO CORRESPONDING FIELDS OF ls_ltak
    WHERE lgnum = pe_check-warehouse_number
      AND tanum = pe_check-to_number
      AND kquit = 'X'.
  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM likp
      INTO CORRESPONDING FIELDS OF ls_likp
      WHERE vbeln = pe_check-delivery_number.
    IF lv_subrc = 0.
      lv_rpcont  = lv_rpcont + pe_check-koli_ori.
      lv_rpsonst = lv_rpsonst + pe_check-koli_ecer.

      TRY .
          UPDATE likp SET /bev1/rpcont    = lv_rpcont
                          /bev1/rpsonst   = lv_rpsonst
                      WHERE vbeln = pe_check-delivery_number.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.
    ENDIF.

    IF lv_subrc = 0.
      pe_check-type = 'S'.
      pe_check-message = 'Confirm success'.
    ELSE.
      CASE lv_subrc.
        WHEN 1.
          pe_check-type = 'E'.
          IF lv_error = 0.
            pe_check-message = 'Koli berbeda dengan picker'.
          ELSE.
            pe_check-message = 'Koli berbeda dengan picker & gagal PGI'.
          ENDIF.
        WHEN OTHERS.
          pe_check-type = 'E'.
          pe_check-message = 'Confirm error'.
      ENDCASE.
    ENDIF.
  ELSE.
    pe_check-type = 'E'.
    pe_check-message = 'Checker belum selesai'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECKER_COMPLETE_GROUP
*&---------------------------------------------------------------------*
FORM f_checker_complete_group  USING    p_json
                               CHANGING pe_check   STRUCTURE zwmsst007.
  DATA : lt_ltak TYPE STANDARD TABLE OF ltak,
         lt_likp TYPE STANDARD TABLE OF likp,
         ls_likp LIKE LINE OF lt_likp.

  DATA : lv_rpcont  TYPE likp-/bev1/rpcont,
         lv_rpsonst TYPE likp-/bev1/rpsonst,
         lv_subrc   TYPE sy-subrc.
  DATA: ls_zwmdt017 TYPE zwmdt017.

  ls_zwmdt017-lgnum = pe_check-warehouse_number.
  ls_zwmdt017-lznum = pe_check-to_number.
  CLEAR: lv_subrc.
  SELECT SINGLE * INTO ls_zwmdt017 FROM zwmdt017
    WHERE lgnum = ls_zwmdt017-lgnum
      AND lznum = ls_zwmdt017-lznum.
  IF sy-subrc EQ 0.
    TRY .
        UPDATE zwmdt017 SET rpcontc  = pe_check-koli_ori
                            rpsonstc   = pe_check-koli_ecer
                            aedat = sy-datum
                            aezet = sy-uzeit
                            aenam = sy-uname
                    WHERE lgnum = ls_zwmdt017-lgnum
      AND lznum = ls_zwmdt017-lznum.

      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.

  ELSE.
    ls_zwmdt017-rpcontc = pe_check-koli_ori.
    ls_zwmdt017-rpsonstc = pe_check-koli_ecer.
    ls_zwmdt017-erdat = sy-datum.
    ls_zwmdt017-erzet = sy-uzeit.
    ls_zwmdt017-ernam = sy-uname.
    TRY .
        MODIFY zwmdt017 FROM ls_zwmdt017..
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ENDIF.

*****  IF lv_subrc = 0.
*****    pe_check-type = 'S'.
*****    pe_check-message = 'Data already completed'.
*****  ELSE.
*****    pe_check-type = 'E'.
*****    pe_check-message = 'Error in completed data'.
*****  ENDIF.



  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
      WHERE lgnum = pe_check-warehouse_number
        AND lznum = pe_check-to_number.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM likp
      INTO CORRESPONDING FIELDS OF TABLE lt_likp
      FOR ALL ENTRIES IN lt_ltak
      WHERE vbeln = lt_ltak-vbeln.

    LOOP AT lt_likp INTO ls_likp.
      lv_rpcont  = ls_likp-/bev1/rpcont + pe_check-koli_ori.
      lv_rpsonst = ls_likp-/bev1/rpsonst + pe_check-koli_ecer.
      TRY .
          UPDATE likp SET /bev1/rpcont  = lv_rpcont
                          /bev1/rpsonst = lv_rpsonst
                      WHERE vbeln = ls_likp-vbeln.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_GROUPING
*&---------------------------------------------------------------------*
FORM f_print_grouping TABLES  ft_picking STRUCTURE zwmsst002
                      USING   fu_drukz fu_lgnum fu_tanum fu_lznum fu_backg.
  DATA : rspar_tab  TYPE STANDARD TABLE OF rsparams,
         ls_picking TYPE zwmsst002.

  READ TABLE ft_picking INTO ls_picking INDEX 1.
  PERFORM f_submit_parameter TABLES rspar_tab
                             USING : 'PA_DRUKZ' fu_drukz 'P',
                                     'PA_LGNUM' fu_lgnum 'P',
                                     'PA_TANUM' fu_tanum 'P',
                                     'PA_LZNUM' fu_lznum 'P',
                                     'PA_BACKG' fu_backg 'P',
                                     'PA_LGTYP' ls_picking-storage_type 'P',
                                     'PA_LGPLA' ls_picking-storage_bin 'P'.
  SUBMIT zwm_print_to_group WITH SELECTION-TABLE rspar_tab AND RETURN.
  CLEAR : rspar_tab[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_COMPPICK_AB_GROUP
*&---------------------------------------------------------------------*
FORM f_comppick_ab_group  TABLES   ft_pickd STRUCTURE zwmsst003
                          USING    fu_lgnum fu_lznum fu_koli_ori fu_koli_ecer
                          CHANGING fc_type fc_message.
  DATA : lt_ltak      TYPE STANDARD TABLE OF ltak,
         ls_ltak      LIKE LINE OF lt_ltak,
         ls_pickd     TYPE zwmsst003,
         ls_pickd_ori TYPE zwmsst003.

  DATA : lv_queue  TYPE ltak-queue,
         lv_length TYPE i,
         lv_subrc  TYPE sy-subrc.

  DATA: ls_zwmdt017 TYPE zwmdt017.

  ls_zwmdt017-lgnum = fu_lgnum.
  ls_zwmdt017-lznum = fu_lznum.
  CLEAR: lv_subrc.
  SELECT SINGLE * INTO ls_zwmdt017 FROM zwmdt017
    WHERE lgnum = ls_zwmdt017-lgnum
      AND lznum = ls_zwmdt017-lznum.
  IF sy-subrc EQ 0.
    TRY .
        UPDATE zwmdt017 SET rpcontp  = fu_koli_ori
                            rpsonstp   = fu_koli_ecer
                             aedat = sy-datum
                            aezet = sy-uzeit
                            aenam = sy-uname
                   WHERE lgnum = ls_zwmdt017-lgnum
      AND lznum = ls_zwmdt017-lznum.

      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ELSE.
    ls_zwmdt017-rpcontp  = fu_koli_ori.
    ls_zwmdt017-rpsonstp   = fu_koli_ecer.
    ls_zwmdt017-erdat = sy-datum.
    ls_zwmdt017-erzet = sy-uzeit.
    ls_zwmdt017-ernam = sy-uname.


    TRY .
        MODIFY zwmdt017 FROM ls_zwmdt017..
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ENDIF.
****  ls_pickd-to_number = fu_lznum.
****  ls_pickd-koli_ori = fu_koli_ori.
****  ls_pickd-koli_ecer = fu_koli_ecer.
****  IF lv_subrc = 0.
****    ls_pickd-type = 'S'.
****    ls_pickd-message = 'Data already completed'.
****  ELSE.
****    ls_pickd-type = 'E'.
****    ls_pickd-message = 'Error in completed data'.
****  ENDIF.
****  IF ft_pickd[] IS NOT INITIAL.
****    LOOP AT ft_pickd INTO ls_pickd_ori WHERE to_number = ls_pickd-to_number.
****      ls_pickd_ori-type = ls_pickd-type.
****      ls_pickd_ori-message = ls_pickd-message.
****      MODIFY ft_pickd FROM ls_pickd_ori
****                      TRANSPORTING type message
****                      WHERE to_number = fu_lznum.
****    ENDLOOP.
****  ELSE.
****    APPEND  ls_pickd TO ft_pickd.
****  ENDIF.
****



  lv_queue  = 'CHECKER'.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE lt_ltak
    WHERE lgnum = fu_lgnum
      AND lznum = fu_lznum.

  READ TABLE lt_ltak INTO ls_ltak INDEX 1.
  IF sy-subrc = 0.
    IF ls_ltak-queue CP '*AB'.
      lv_length = strlen( ls_ltak-queue ).
      IF lv_length = 2.
        lv_queue = |{ lv_queue }{ ls_ltak-queue }|.
      ELSE.
        REPLACE ALL OCCURRENCES OF ls_ltak-queue(sy-fdpos) IN ls_ltak-queue WITH lv_queue.
        lv_queue = ls_ltak-queue.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT lt_ltak INTO ls_ltak.
    TRY .
        UPDATE ltak SET queue = lv_queue
              WHERE lgnum = ls_ltak-lgnum
                AND tanum = ls_ltak-tanum.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.

    TRY .
        UPDATE ltap SET zrstg = 'X'
              WHERE lgnum = ls_ltak-lgnum
                AND tanum = ls_ltak-tanum.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.

    TRY .
        UPDATE likp SET /bev1/rpfaess  = fu_koli_ori
                        /bev1/rpkist   = fu_koli_ecer
                    WHERE vbeln = ls_ltak-vbeln.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
  ENDLOOP.

  IF lv_subrc = 0.
    ls_pickd-type = 'S'.
    ls_pickd-message = 'Data already completed'.
    fc_type    = ls_pickd-type.
    fc_message = ls_pickd-message.
  ELSE.
    ls_pickd-type = 'E'.
    ls_pickd-message = 'Error in completed data'.
    fc_type    = ls_pickd-type.
    fc_message = ls_pickd-message.
  ENDIF.
  MODIFY ft_pickd FROM ls_pickd
                  TRANSPORTING type message
                  WHERE to_number = fu_lznum.
  CLEAR lv_subrc.
ENDFORM.
