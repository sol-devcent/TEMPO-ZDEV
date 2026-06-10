*----------------------------------------------------------------------*
***INCLUDE LZWMSFG001F04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CREATE_TO_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_TO  text
*      -->P_PI_DATA  text
*      <--P_TRANSFER_ORDER_NUMBER  text
*      <--P_LV_PALLET_NUMBER  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*----------------------------------------------------------------------*
FORM f_proses_create_to_po  TABLES   pt_to   STRUCTURE zwmsst001
                         USING    p_json
                         CHANGING p_to_number p_pallet_no fc_type fc_message.

  DATA : ls_to_po    TYPE ty_to_po,
         ls_to       TYPE zwmsst001,
         ls_po       TYPE ty_po,
         lt_po       TYPE STANDARD TABLE OF ty_po,
         lt_mlgn     TYPE STANDARD TABLE OF mlgn,
         ls_mlgn     LIKE LINE OF lt_mlgn,
         ls_podetail TYPE ty_podetail,
         lt_podetail TYPE STANDARD TABLE OF ty_podetail..

  DATA: BEGIN OF lt_ekpo OCCURS 0,
          ebeln TYPE ekpo-ebeln,
          ebelp TYPE ekpo-ebelp,
          werks TYPE ekpo-werks,
          matnr TYPE ekpo-matnr,
          menge TYPE ekpo-menge,
          meins TYPE ekpo-meins,
          xchpf TYPE mara-xchpf,
        END OF lt_ekpo.

  DATA : lv_json_data  TYPE string,
         lv_single(1),
         lv_count      TYPE i,
         lv_uname      TYPE sy-uname,
         lv_carton     TYPE lips-lfimg,
         lv_receh      TYPE lips-lfimg,
         lv_total      TYPE lips-lfimg,
         lv_lgnum      TYPE ltak-lgnum,
         lv_bwlvs      TYPE ltak-bwlvs,
         lv_betyp      TYPE ltak-betyp,
         lv_benum      TYPE ltak-benum,
         lv_lznum      TYPE ltak-lznum,
         lv_lznum1     TYPE ltak-lznum,
         lv_anfme      TYPE ltap_creat-anfme,
         lv_pallet(10),
         lv_itemid(20),
         "lv_anfme      TYPE ltap_creat-anfme,
         lv_add        TYPE c LENGTH 1,
         lv_sisa       TYPE mlgn-lhmg1,
         lv_save       TYPE sy-subrc,
         lv_charg      TYPE ltap-charg,
         lv_nltyp      TYPE ltap-nltyp,
         lv_nlpla      TYPE ltap-nlpla,
         lv_drukz      TYPE t329f-drukz,
         lv_commit     TYPE rl03b-comit,
         lv_ponumber   TYPE ekko-ebeln,
         lv_subrc      TYPE sy-subrc,
         lv_rusak(5),
         lv_zdtsul     TYPE sy-datum,
         lv_zuzsul     TYPE sy-uzeit,
         lv_zdteul     TYPE sy-datum,
         lv_zuzeul     TYPE sy-uzeit,
         lv_tanum      TYPE ltap-tanum.


  DATA : lt_ltap_creat TYPE STANDARD TABLE OF ltap_creat, " WITH HEADER LINE,
         ls_ltap_creat LIKE LINE OF lt_ltap_creat,
         lt_004        TYPE STANDARD TABLE OF zwmdt004,
         ls_004        LIKE LINE OF lt_004,
         lt1_s004      TYPE STANDARD TABLE OF zwmdt004,
         lt_s004       TYPE STANDARD TABLE OF zwmdt004,
         ls_s004       LIKE LINE OF lt_004,
         ls_001        TYPE zwmsst001,
         lv_lfimg      TYPE zwmdt004-lfimg,
         lv_4lfimg     TYPE zwmdt004-lfimg,
         lv_vbeln      TYPE zwmdt004-vbeln.
  "lt_mlgn       TYPE STANDARD TABLE OF mlgn,
  "ls_mlgn       LIKE LINE OF lt_mlgn.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_to_po ).
  lv_ponumber = ls_to_po-po_number.
  lv_lgnum = ls_to_po-warehouse.
  lv_vbeln = ls_to_po-delivery_number.
  lv_uname  = ls_to_po-user_name.

  " lv_anfme = ls_to_po-user_name.


  IF lv_ponumber IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt1_s004
      FROM zwmdt004 WHERE tknum = lv_ponumber.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
      FROM ekpo AS a JOIN mara AS b ON a~matnr = b~matnr
      WHERE ebeln = lv_ponumber.
    IF lt1_s004[] IS NOT INITIAL.
      LOOP AT lt_ekpo .
        LOOP AT lt1_s004 INTO ls_s004
          WHERE tknum = lt_ekpo-ebeln AND
                posnr = lt_ekpo-ebelp AND
                matnr = lt_ekpo-matnr.
          lt_ekpo-menge =  lt_ekpo-menge - ls_s004-lfimg.
        ENDLOOP.
        MODIFY lt_ekpo TRANSPORTING menge.
      ENDLOOP.
    ENDIF.
    IF sy-subrc EQ 0.
      SORT ls_to_po-nav_po BY material_number.

      PERFORM f_datetime USING ls_to_po-unloading_start
                        CHANGING lv_zdtsul lv_zuzsul.

      PERFORM f_datetime USING ls_to_po-unloading_end
                         CHANGING lv_zdteul lv_zuzeul.

      LOOP AT ls_to_po-nav_po INTO ls_podetail.
        ls_004-lgnum = lv_lgnum.
        ls_004-tknum = lv_ponumber.
        ls_004-lznum = ls_podetail-pallet_number.
        ls_004-matnr = ls_podetail-material_number.
        ls_004-charg = ls_podetail-batch.
        ls_004-zdtsul = lv_zdtsul.
        ls_004-zuzsul = lv_zuzsul.
        ls_004-zdteul = lv_zdteul.
        ls_004-zuzeul = lv_zuzeul.

        lv_lznum  = ls_podetail-pallet_number.
        ls_po-item_id = ls_podetail-item_id.
        ls_po-pallet_number = ls_podetail-pallet_number.
        ls_po-pallet_id = ls_to_po-pallet_id.
        ls_po-ebeln = lv_ponumber.
        ls_po-matnr = ls_podetail-material_number.
        ls_po-charg = ls_podetail-batch.
        ls_po-meins = ls_podetail-uom_satuan.
        ls_po-rusak = ls_podetail-rusak_indicator.
        PERFORM f_unit_conversion_po USING ls_podetail
                              CHANGING lv_carton lv_receh.
        lv_total = lv_carton + lv_receh.
        ls_po-menge = lv_carton + lv_receh.
        ls_004-lfimg = lv_total.
        ls_004-vrkme = ls_podetail-uom_satuan.
        LOOP AT lt_ekpo WHERE ebeln = lv_ponumber AND matnr = ls_po-matnr.
          ls_po-zdtsul = lv_zdtsul.
          ls_po-zuzsul = lv_zuzsul.
          ls_po-zdteul = lv_zdteul.
          ls_po-zuzeul = lv_zuzeul.
          ls_po-werks = lt_ekpo-werks.
          ls_po-ebelp = lt_ekpo-ebelp.
          ls_004-posnr = lt_ekpo-ebelp.
          IF  lv_total > lt_ekpo-menge.
            ls_po-menge =  lt_ekpo-menge.
            ls_004-lfimg = lt_ekpo-menge.
          ELSE.
            ls_po-menge = lv_total.
            ls_004-lfimg = lv_total.
          ENDIF.
          lv_total = lv_total - lt_ekpo-menge.
          COLLECT ls_po INTO lt_po.
          COLLECT ls_004 INTO lt_004.
          COLLECT ls_podetail INTO lt_podetail.
          CLEAR: ls_po-item_id.
          IF lv_total < 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        CLEAR ls_po.
      ENDLOOP.
      DESCRIBE TABLE lt_podetail LINES lv_count.
      IF lv_count = 1.
        lv_single = 'X'.
      ELSE.
        CLEAR lv_single.
      ENDIF.
      IF lt_po[] IS NOT INITIAL.
        SELECT *
          FROM mlgn
          INTO CORRESPONDING FIELDS OF TABLE lt_mlgn
          FOR ALL ENTRIES IN lt_po
          WHERE matnr = lt_po-matnr
            AND lgnum = lv_lgnum.
        DELETE ADJACENT DUPLICATES FROM lt_mlgn COMPARING ALL FIELDS.
        lv_pallet =  lv_lznum.
        LOOP AT lt_po INTO ls_po.
          CONCATENATE lv_pallet ls_po-ebeln INTO lv_lznum1    SEPARATED BY ';'.
          lv_lfimg = ls_po-menge.
          lv_itemid = ls_po-item_id.
          lv_anfme = ls_po-menge.

          WHILE lv_lfimg > 0.
            CLEAR : lt_ltap_creat[].
            CONCATENATE lv_pallet ls_po-ebeln INTO lv_lznum1    SEPARATED BY ';'.
            lv_benum = lv_ponumber.
            lv_bwlvs = '101'.
            lv_betyp = 'Z'.
            lv_drukz = '45'.
            CLEAR : lt_ltap_creat[].
            IF ls_po-rusak = 'X'.
              PERFORM f_prepare_detail_po_other  TABLES lt_ltap_creat
                                        USING ls_po  lv_lznum lv_lfimg 'RUSAK' lv_vbeln
                                        CHANGING ls_ltap_creat lv_nltyp lv_nlpla.
              lv_lfimg = -10.
            ELSE.
              IF lv_single = 'X'.
                PERFORM f_prepare_detail_po TABLES lt_ltap_creat lt_mlgn
                                         USING ls_po  lv_lznum '' '' lv_vbeln
                                         CHANGING ls_ltap_creat lv_lfimg lv_anfme
                                                  lv_sisa lv_add lv_nltyp lv_nlpla.
              ELSE.
                PERFORM f_prepare_detail_po_other  TABLES lt_ltap_creat
                                          USING ls_po  lv_lznum lv_lfimg 'MULTI' lv_vbeln
                                          CHANGING ls_ltap_creat lv_nltyp lv_nlpla.
                lv_lfimg = -10.

              ENDIF.
            ENDIF.
            IF lt_ltap_creat[] IS NOT INITIAL.
              PERFORM f_create_to TABLES lt_ltap_creat
                                USING lv_lgnum lv_bwlvs lv_betyp lv_benum
                                      lv_lznum1 lv_drukz lv_commit
                                CHANGING lv_tanum lv_subrc.
              IF lv_subrc EQ 0.
                p_to_number = lv_tanum.
                p_pallet_no = lv_pallet. "lv_lznum.
                fc_type = 'S'.
                fc_message = 'Create TO success'.
                IF ls_po-rusak = 'X'.
                  lv_rusak = 'RUSAK'.
                ELSE.
                  CLEAR: lv_rusak.
                ENDIF.
                PERFORM f_save_004_po USING lv_tanum lv_lgnum lv_lznum
                                         lv_uname lv_rusak lv_vbeln
                                         ls_po ls_ltap_creat
                                   CHANGING lv_save.
                IF lv_save = 0.
                  PERFORM f_print_to USING lv_tanum lv_lgnum
                                     CHANGING lv_nltyp lv_nlpla.
                ENDIF.
                PERFORM f_body_response TABLES pt_to
                                        USING ls_ltap_creat
                                              lv_itemid lv_pallet lv_tanum lv_nlpla
                                              lv_rusak fc_type fc_message.

                CLEAR : ls_ltap_creat, lv_tanum, lv_itemid.
                IF lv_add IS NOT INITIAL AND lv_single = 'X'.
                  ADD 1 TO lv_pallet.
                  CLEAR: lv_add.
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
                                              lv_itemid lv_pallet lv_tanum lv_nlpla
                                              '' fc_type fc_message.
                EXIT.
              ENDIF.
            ELSE.
              PERFORM f_body_response TABLES pt_to
                                USING ls_ltap_creat
                                      lv_itemid lv_pallet '' ''
                                      '' 'E' 'Tidak data untuk Create TO'.
              lv_lfimg = -10.
            ENDIF.
            lv_lznum = lv_pallet.
          ENDWHILE.
        ENDLOOP.
      ELSE.
        PERFORM f_body_response TABLES pt_to
                          USING ls_ltap_creat
                                lv_itemid lv_pallet '' ''
                                '' 'E' 'tidak ada data PO'.
      ENDIF.
    ELSE.
      PERFORM f_body_response TABLES pt_to
                      USING ls_ltap_creat
                            lv_itemid lv_pallet '' ''
                            '' 'E' 'No PO tidak ditemukan di SAP'.
    ENDIF.
  ELSE.
  ENDIF.
  IF pt_to[] IS NOT INITIAL.
    LOOP AT pt_to INTO ls_to.
      PERFORM f_unit_conversion_po_output  USING    ls_to
                      CHANGING ls_to-qtycar ls_to-qtysat.
      MODIFY pt_to FROM ls_to TRANSPORTING qtysat qtycar.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion_po  USING    fs_podetail    TYPE ty_podetail
                        CHANGING fc_carton fc_receh.
  DATA : ls_marm  TYPE marm,
         lv_meins TYPE mara-meins.

  PERFORM f_unit_conversion_input USING fs_podetail-uom_carton
                                  CHANGING lv_meins.
  SELECT SINGLE *
    FROM marm
    INTO CORRESPONDING FIELDS OF ls_marm
    WHERE matnr = fs_podetail-material_number
      AND meinh = lv_meins.
  IF sy-subrc = 0.
    fc_carton = fs_podetail-quantity_carton * ls_marm-umrez / ls_marm-umren.
  ENDIF.
  fc_receh = fs_podetail-quantity_satuan.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion_po_output  USING    fs_to  TYPE zwmsst001
                        CHANGING fc_carton fc_receh.
  DATA : ls_marm   TYPE marm,
         lv_meins  TYPE mara-meins,
         lv_qtycar TYPE lfimg.

  PERFORM f_unit_conversion_input USING fs_to-meinh
                                  CHANGING lv_meins.
  SELECT SINGLE *
    FROM marm
    INTO CORRESPONDING FIELDS OF ls_marm
    WHERE matnr = fs_to-matnr
      AND meinh = lv_meins.
  IF sy-subrc = 0.
    lv_qtycar = fs_to-qtysat * ls_marm-umren / ls_marm-umrez.

    CALL FUNCTION 'ROUND'
      EXPORTING
        input         = lv_qtycar
        sign          = '-'
      IMPORTING
        output        = fc_carton
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3.


    fc_receh = fs_to-qtysat - ( fc_carton * ls_marm-umrez / ls_marm-umren ).
    "    fc_carton = lv_qtycar.
  ENDIF.
**  IF sy-subrc = 0.
**    fc_carton = fs_podetail-quantity_carton * ls_marm-umrez / ls_marm-umren.
**  ENDIF.
**  fc_receh = fs_podetail-quantity_satuan.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_004
*&---------------------------------------------------------------------*
FORM f_save_004_po  USING    fu_tanum fu_lgnum fu_lznum fu_uname
                          fu_change fu_vbeln
                          fs_po     TYPE ty_po
                          fs_ltap_creat   TYPE ltap_creat
                 CHANGING fc_subrc.
  DATA : ls_004   TYPE zwmdt004.

  CLEAR fc_subrc.

  ls_004-lgnum    = fu_lgnum.

  CASE fu_change.
    WHEN 'RUSAK'.
      ls_004-vbeln    = fu_vbeln.
      ls_004-posnr    = fs_po-ebelp.
      ls_004-tknum    = fs_po-ebeln.
      ls_004-lznum    = fu_lznum.
      ls_004-matnr    = fs_po-matnr.
      ls_004-charg    = fs_po-charg.
      ls_004-lfimg    = fs_po-menge.
      ls_004-vrkme    = fs_po-meins.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-rusak    = fs_po-rusak.
      ls_004-zdtsul = fs_po-zdtsul.
      ls_004-zuzsul = fs_po-zuzsul.
      ls_004-zdteul = fs_po-zdteul.
      ls_004-zuzeul = fs_po-zuzeul.

    WHEN space.
      ls_004-tknum    = fs_po-ebeln.
      ls_004-lznum    = fu_lznum.
      ls_004-posnr    = fs_ltap_creat-posnr.
      ls_004-matnr    = fs_ltap_creat-matnr.
      ls_004-charg    = fs_ltap_creat-charg.
      ls_004-lfimg    = fs_ltap_creat-anfme.
      ls_004-vrkme    = fs_ltap_creat-altme.
      ls_004-tanum    = fu_tanum.
      ls_004-znmuld   = fu_uname.
      ls_004-vbeln    = fu_vbeln.
      ls_004-zdtsul = fs_po-zdtsul.
      ls_004-zuzsul = fs_po-zuzsul.
      ls_004-zdteul = fs_po-zdteul.
      ls_004-zuzeul = fs_po-zuzeul.
  ENDCASE.

  IF ls_004 IS NOT INITIAL.
    TRY .
        MODIFY zwmdt004 FROM ls_004.
      CATCH cx_sy_open_sql_db.
        fc_subrc = 4.
    ENDTRY.
  ENDIF.

  IF fc_subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail_po_other  TABLES   ft_ltap_creat STRUCTURE ltap_creat
                       USING    fs_po   TYPE ty_po
                               fu_lznum fu_lfimg fu_change fu_vbeln
                       CHANGING fs_ltap_creat TYPE ltap_creat fc_nltyp fc_nlpla.
  fs_ltap_creat-werks  = fs_po-werks.
  fs_ltap_creat-matnr  = fs_po-matnr.
  fs_ltap_creat-lgort  = '1000'.
  fs_ltap_creat-charg  = fs_po-charg.
  CASE fu_change.
    WHEN 'MULTI'.
      fs_ltap_creat-nltyp  = fc_nltyp.
      fs_ltap_creat-nlpla  = fc_nlpla.
      fs_ltap_creat-anfme  = fu_lfimg.
      fs_ltap_creat-vlpla  = fs_po-ebeln . "fs_po-vbeln.
      PERFORM f_unit_conversion_input USING fs_po-meins
                                      CHANGING fs_ltap_creat-altme.

    WHEN 'RUSAK'.
      fs_ltap_creat-anfme  = fu_lfimg.
      fs_ltap_creat-nltyp  = '997'.
      fs_ltap_creat-nlber  = '001'.
      fs_ltap_creat-nlpla  = 'DAMAGEGR'.
      fs_ltap_creat-vlpla  = fu_vbeln.
      PERFORM f_unit_conversion_input USING fs_po-meins
                                      CHANGING fs_ltap_creat-altme.
  ENDCASE.

  fs_ltap_creat-vltyp  = '902'.
  fs_ltap_creat-vlber  = '001'.
  fs_ltap_creat-letyp  = 'SP'.
  fs_ltap_creat-vlpla = fs_po-ebeln.
  fs_ltap_creat-posnr  = fs_po-ebelp.
  "  CONCATENATE fu_lznum fs_po-ebeln into fs_ltap_creat-ablad SEPARATED BY ';'.

  CONDENSE: fu_lznum, fs_po-ebeln.
  "  CONCATENATE fu_lznum fs_po-ebeln INTO fs_ltap_creat-ablad SEPARATED BY ';'.
  fs_ltap_creat-ablad = fu_lznum.
  CONDENSE:  fs_ltap_creat-ablad.


  "  fs_ltap_creat-ablad  = fu_lznum.

  "  fs_ltap_creat-vlpla = fs_po-delivery_number.
  "  fu_po-delivery_number  --> dimasukkan ke mana ?


  "  fs_ltap_creat-
  CONDENSE fs_ltap_creat-ablad NO-GAPS.
*      fs_ltap_creat-squit  = fs_post-capacity.

  APPEND fs_ltap_creat TO ft_ltap_creat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail_po  TABLES   ft_ltap_creat STRUCTURE ltap_creat
                                ft_mlgn       STRUCTURE mlgn
                       USING    fs_po   TYPE ty_po
                               fu_lznum fu_lfimg fu_change fu_vbeln
                       CHANGING fs_ltap_creat TYPE ltap_creat
                                fc_lfimg fc_anfme fc_sisa fc_add fc_nltyp fc_nlpla.

  DATA : lv_lhmg1 TYPE mlgn-lhmg1.

  fs_ltap_creat-werks  = fs_po-werks.
  fs_ltap_creat-matnr  = fs_po-matnr.
  fs_ltap_creat-lgort  = '1000'.
  fs_ltap_creat-charg  = fs_po-charg.

  IF fu_lfimg IS INITIAL.
    PERFORM f_pallet_capacity TABLES ft_mlgn
                              USING fs_po-matnr fs_po-menge
                              CHANGING lv_lhmg1 fc_sisa.

    IF fc_anfme < lv_lhmg1.
      fs_ltap_creat-anfme  = fc_anfme.
      fc_anfme = fc_anfme - lv_lhmg1.
      fc_add = 'X'.
    ELSE.
      IF fc_lfimg < fs_po-menge.
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
    fs_ltap_creat-vlpla  = fs_po-ebeln . "fs_po-vbeln.
    PERFORM f_unit_conversion_input USING fs_po-meins
                                    CHANGING fs_ltap_creat-altme.
  ELSE.
    CASE fu_change.
      WHEN 'RUSAK'.
        fs_ltap_creat-anfme  = fu_lfimg.
        fs_ltap_creat-nltyp  = '997'.
        fs_ltap_creat-nlber  = '001'.
        fs_ltap_creat-nlpla  = 'DAMAGEGR'.
        fs_ltap_creat-vlpla  = fu_vbeln.
        PERFORM f_unit_conversion_input USING fs_po-meins
                                        CHANGING fs_ltap_creat-altme.
    ENDCASE.
  ENDIF.

  fs_ltap_creat-vltyp  = '902'.
  fs_ltap_creat-vlber  = '001'.
  fs_ltap_creat-letyp  = 'SP'.
  fs_ltap_creat-vlpla = fs_po-ebeln.
  fs_ltap_creat-posnr  = fs_po-ebelp.
  CONDENSE: fu_lznum, fs_po-ebeln.
  "  CONCATENATE fu_lznum fs_po-ebeln INTO fs_ltap_creat-ablad SEPARATED BY ';'.
  fs_ltap_creat-ablad = fu_lznum.
  CONDENSE:  fs_ltap_creat-ablad.

  "  fs_ltap_creat-vlpla = fs_po-delivery_number.
  "  fu_po-delivery_number  --> dimasukkan ke mana ?


  "  fs_ltap_creat-
  CONDENSE fs_ltap_creat-ablad NO-GAPS.
*      fs_ltap_creat-squit  = fs_post-capacity.

  APPEND fs_ltap_creat TO ft_ltap_creat.

ENDFORM.
