*----------------------------------------------------------------------*
***INCLUDE ZRVADEK01F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_lines   TYPE i.

  PERFORM f_process_gabung.

  PERFORM f_modify_for_united.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  DESCRIBE TABLE gt_nast LINES lv_lines.
  CASE lv_lines.
    WHEN 0 OR 1.
      CLEAR wa_header-reprint.
    WHEN 2.
      wa_header-reprint = 'X'.
    WHEN OTHERS.
      wa_header-reprint = 'XX'.
  ENDCASE.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        wa_header          = wa_header
        vblkk              = vblkk
      TABLES
        gt_detail          = gt_detail.
  ENDIF.

ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lv_vgbel     TYPE vgbel,
         lt_vblkp     LIKE vblkp OCCURS 0 WITH HEADER LINE,
         lt_lips      LIKE lips OCCURS 0 WITH HEADER LINE,
         lt_sort      LIKE lips OCCURS 0 WITH HEADER LINE,
         lt_mara      LIKE lips OCCURS 0 WITH HEADER LINE,
         lt_zmmatkls  LIKE zmmatkls OCCURS 0 WITH HEADER LINE,
         lt_zmmara2   LIKE zmmara2 OCCURS 0 WITH HEADER LINE,
         lt_mard      TYPE TABLE OF mard WITH HEADER LINE,
         lv_bukrs     TYPE bukrs,
         lv_p1        TYPE p DECIMALS 0,
         lv_p2        TYPE p DECIMALS 0,
         lv_p3        TYPE p DECIMALS 0,
         lv_p4        TYPE p DECIMALS 0,
         lv_snx.

  DATA : lv_vbelv   LIKE vbfa-vbelv.

  DATA : ls_mara    LIKE LINE OF gt_mara.

  DATA : lt_zcust   TYPE STANDARD TABLE OF zmproject_ctrl,
         ls_zcust   LIKE LINE OF lt_zcust,
         lt_1       TYPE STANDARD TABLE OF zmproject_ctrl,
         ls_1       LIKE LINE OF lt_zcust,
         ls_tvblkp  LIKE LINE OF tvblkp.

  DATA : lr_werks   TYPE RANGE OF werks_d,
         lr_lgort   TYPE RANGE OF lgort_d.

  DATA : ls_werks   LIKE LINE OF lr_werks,
         ls_lgort   LIKE LINE OF lr_lgort.

  lt_vblkp[]  = tvblkp[].

  PERFORM f_get_address USING vblkk-vbeln
                        CHANGING vblkk wa_header-lzone wa_header-kdgrp
                                 wa_header-kvgr2 wa_header-katr1
                                 wa_header-vkorg wa_header-ecomnm.

  wa_header-ort01  = vblkk-ort01.

  SELECT SINGLE landx
    FROM t005t
    INTO wa_header-landx
    WHERE spras = sy-langu
      AND land1 = vblkk-land1.

  TRANSLATE wa_header-landx TO UPPER CASE.
  TRANSLATE wa_header-ort01 TO UPPER CASE.

  SELECT matnr matkl werks vgbel
    FROM lips
    INTO CORRESPONDING FIELDS OF TABLE lt_lips
    WHERE vbeln = vblkk-vbeln.

  IF sy-subrc = 0.
    READ TABLE lt_lips INDEX 1.
    IF sy-subrc = 0.
      lv_vgbel = lt_lips-vgbel.
    ENDIF.

    lt_sort[] = lt_lips[].
    SORT lt_sort BY matkl.
    DELETE ADJACENT DUPLICATES FROM lt_sort COMPARING matkl.
    IF lt_sort[] IS NOT INITIAL.
      SELECT *
        FROM zmmatkls
        INTO CORRESPONDING FIELDS OF TABLE lt_zmmatkls
        FOR ALL ENTRIES IN lt_sort
        WHERE matkl = lt_sort-matkl.
    ENDIF.

    lt_mara[] = lt_lips[].
    SORT lt_mara BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr werks.
    IF lt_mara[] IS NOT INITIAL.
      SELECT *
        FROM zmmara2
        INTO CORRESPONDING FIELDS OF TABLE lt_zmmara2
        FOR ALL ENTRIES IN lt_mara
        WHERE matnr = lt_mara-matnr
          AND werks = lt_mara-werks.

      SORT lt_mara BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
      IF lt_mara[] IS NOT INITIAL.
        SELECT *
          FROM mara
          INTO CORRESPONDING FIELDS OF TABLE gt_mara
          FOR ALL ENTRIES IN lt_mara
          WHERE matnr = lt_mara-matnr.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE bnddt
    FROM vbak
    INTO wa_header-bnddt
    WHERE vbeln = lv_vgbel.

* Volume
  WRITE vblkk-volum TO wa_header-volume UNIT vblkk-voleh.
  SHIFT wa_header-volume LEFT DELETING LEADING space.
  CONCATENATE 'Volume : ' wa_header-volume vblkk-voleh
  INTO wa_header-volume
  SEPARATED BY space.

* Item
  SORT lt_vblkp BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_vblkp COMPARING matnr.
  DESCRIBE TABLE lt_vblkp LINES wa_header-items.
  SHIFT wa_header-items LEFT DELETING LEADING space.
  CONCATENATE 'Item :' wa_header-items INTO wa_header-items
  SEPARATED BY space.

  CLEAR : gt_detail[], gt_detail.

  READ TABLE tvblkp INDEX 1.
  IF sy-subrc = 0.
    wa_header-werks = tvblkp-werks.
    wa_header-lgort = tvblkp-lgort.
    wa_header-mbdat = tvblkp-mbdat.
  ENDIF.

  SELECT SINGLE bukrs
    FROM t001k
    INTO lv_bukrs
    WHERE bwkey = vblkk-vstel.

  CASE vblkk-vstel.
    WHEN '1801'.
    WHEN 'T220'.
    WHEN OTHERS.
      PERFORM f_get_max_time_picking USING vblkk-vstel vblkk-ort01 wa_header-kdgrp
                                           wa_header-kvgr2 wa_header-katr1
                                           wa_header-vkorg
                                     CHANGING wa_header-kodat wa_header-kouhr.
  ENDCASE.

  IF wa_header-vkorg EQ '8380'.
    SELECT matnr werks lgort pstat lfgja lfmon lgpbe
      INTO CORRESPONDING FIELDS OF TABLE lt_mard
      FROM mard FOR ALL ENTRIES IN tvblkp
      WHERE matnr EQ tvblkp-matnr
        AND werks EQ tvblkp-werks
        AND lgort EQ tvblkp-lgort.
  ENDIF.

  IF lv_bukrs = '8380' OR
    wa_header-werks(2) = 'T2'.
    SELECT SINGLE vbelv
         FROM vbfa
         INTO lv_vbelv
         WHERE vbeln = vblkk-vbeln.

    IF lv_vbelv IS NOT INITIAL.
*      SELECT SINGLE bstnk bstdk
*           FROM vbak
*           INTO (wa_header-bstnk, wa_header-bstdk)
*           WHERE vbeln = lv_vbelv.
      SELECT SINGLE bstkd bstdk
           FROM vbkd
           INTO (wa_header-bstkd, wa_header-bstdk)
           WHERE vbeln = lv_vbelv.
    ENDIF.
  ELSEIF wa_header-vkorg = '8380'.
    SELECT SINGLE vbelv
         FROM vbfa
         INTO lv_vbelv
         WHERE vbeln = vblkk-vbeln.

    IF lv_vbelv IS NOT INITIAL.
*      SELECT SINGLE bstnk bstdk
*           FROM vbak
*           INTO (wa_header-bstnk, wa_header-bstdk)
*           WHERE vbeln = lv_vbelv.
      SELECT SINGLE bstkd bstdk
           FROM vbkd
           INTO (wa_header-bstkd, wa_header-bstdk)
           WHERE vbeln = lv_vbelv.
    ENDIF.
  ENDIF.

  SELECT *
  FROM zmproject_ctrl
  INTO CORRESPONDING FIELDS OF TABLE lt_zcust
  WHERE zproject = 'ZACC_ACT'
    AND datab    <= sy-datum
    AND datbi    >= sy-datum.

  lt_1[]  = lt_zcust[].
  SORT lt_1 BY zevent.
  DELETE ADJACENT DUPLICATES FROM lt_1 COMPARING zevent.

  READ TABLE tvblkp INTO ls_tvblkp INDEX 1.

  LOOP AT lt_1 INTO ls_1.
    CLEAR : lr_werks[], lr_lgort[].
    LOOP AT lt_zcust INTO ls_zcust WHERE zevent = ls_1-zevent.
      CASE ls_zcust-fieldname1.
        WHEN 'WERKS'.
          ls_werks-low    = ls_zcust-low1.
          IF ls_zcust-option1 = 'BT'.
            ls_werks-high     = ls_zcust-high1.
          ENDIF.
          ls_werks-sign   = ls_zcust-sign1.
          ls_werks-option = ls_zcust-option1.
          APPEND ls_werks TO lr_werks.
          CLEAR ls_werks.
        WHEN 'LGORT'.
          ls_lgort-low    = ls_zcust-low1.
          IF ls_zcust-option1 = 'BT'.
            ls_lgort-high     = ls_zcust-high1.
          ENDIF.
          ls_lgort-sign   = ls_zcust-sign1.
          ls_lgort-option = ls_zcust-option1.
          APPEND ls_lgort TO lr_lgort.
          CLEAR ls_lgort.
      ENDCASE.
    ENDLOOP.
    IF lr_werks[] IS NOT INITIAL OR
       lr_lgort[] IS NOT INITIAL.
      IF ls_tvblkp-werks IN lr_werks AND
        ls_tvblkp-lgort IN lr_lgort.
        lv_snx = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT tvblkp BY matnr werks lgort.
  SORT lt_mard BY matnr werks lgort.

  LOOP AT tvblkp.
    SELECT SINGLE vfdat
      FROM mch1
      INTO tvblkp-vfdat
      WHERE matnr EQ tvblkp-matnr
        AND charg EQ tvblkp-charg.

    IF tvblkp-uecha IS INITIAL.
      gt_detail-posnr = tvblkp-posnr.
    ELSE.
      gt_detail-posnr = tvblkp-uecha.
    ENDIF.

    CLEAR lt_lips.
    READ TABLE lt_lips WITH KEY matnr = tvblkp-matnr.
    IF sy-subrc = 0.
      CLEAR lt_zmmatkls.
      READ TABLE lt_zmmatkls WITH KEY matkl = lt_lips-matkl.
      IF sy-subrc = 0.
        gt_detail-zsort = lt_zmmatkls-posnr.
      ENDIF.
      READ TABLE lt_zmmara2 WITH KEY matnr = lt_lips-matnr
                                     werks = lt_lips-werks.
      IF sy-subrc = 0.
        gt_detail-location = 'B'.
      ENDIF.
    ENDIF.
    gt_detail-mbdat = tvblkp-mbdat.
    gt_detail-werks = tvblkp-werks.
    gt_detail-lgort = tvblkp-lgort.
    gt_detail-matnr = tvblkp-matnr.

    SELECT SINGLE *
      FROM zaccdtm
      WHERE matnr = tvblkp-matnr
        AND werks = tvblkp-werks.
    IF sy-subrc = 0 AND
      lv_snx = 'X'.
      CONCATENATE tvblkp-arktx ' ' '  (QR)' INTO gt_detail-arktx
      SEPARATED BY space.
    ELSE.
      gt_detail-arktx = tvblkp-arktx.
    ENDIF.
    gt_detail-charg = tvblkp-charg.
    gt_detail-vfdat = tvblkp-vfdat.

    PERFORM f_split_satuan USING    lv_bukrs tvblkp-matnr tvblkp-komng
                                    tvblkp-meins
                           CHANGING gt_detail-auom01t gt_detail-auom02t
                                    gt_detail-auom03t gt_detail-auom04t
                                    gt_detail-quantityt
                                    lv_p1 lv_p2 lv_p3 lv_p4.

    CLEAR lt_mard.
    READ TABLE lt_mard WITH KEY matnr = tvblkp-matnr
                                werks = tvblkp-werks
                                lgort = tvblkp-lgort BINARY SEARCH.
    gt_detail-lgpbe = lt_mard-lgpbe.

    CLEAR ls_mara.
    READ TABLE gt_mara INTO ls_mara WITH KEY matnr = tvblkp-matnr.
    IF sy-subrc = 0.
      gt_detail-extwg   = ls_mara-extwg.
*      gt_detail-bismt   = ls_mara-bismt.
      IF gt_detail-extwg = 'PMH'.
        gt_detail-bismt = ls_mara-bismt.
      ELSE.
        gt_detail-bismt = ls_mara-ean11.
      ENDIF.
    ENDIF.
    APPEND gt_detail.
    CLEAR gt_detail.
  ENDLOOP.

  WRITE lv_p1 TO wa_header-auom01t DECIMALS 0.
  CONDENSE wa_header-auom01t NO-GAPS.
  WRITE lv_p2 TO wa_header-auom02t DECIMALS 0.
  CONDENSE wa_header-auom02t NO-GAPS.
  WRITE lv_p3 TO wa_header-auom03t DECIMALS 0.
  CONDENSE wa_header-auom03t NO-GAPS.
  WRITE lv_p4 TO wa_header-auom04t DECIMALS 0.
  CONDENSE wa_header-auom04t NO-GAPS.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .

ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS
*&---------------------------------------------------------------------*
FORM f_get_address  USING    fu_vbeln
                    CHANGING fwa_vblkk STRUCTURE vblkk
                             fc_lzone fc_kdgrp fc_kvgr2 fc_katr1 fc_vkorg
                             fc_ecomnm.

  DATA : lv_vstel       TYPE vstel,
         lv_kunnr       TYPE kunnr,
         lv_reswk       TYPE zreswk_united,
         lv_vgbel       TYPE vgbel,
         lv_bednr       TYPE bednr,
         lv_adrnr       TYPE adrnr,
         lv_lfart       TYPE likp-lfart,
         lv_title_medi  TYPE  ad_titletx.

  SELECT SINGLE vstel vkorg kunnr route lfart
    FROM likp
    INTO (lv_vstel, fc_vkorg, lv_kunnr, fc_lzone, lv_lfart)
    WHERE vbeln = fu_vbeln.

  SELECT SINGLE kdgrp kvgr2 katr1
    FROM knvv JOIN kna1 ON knvv~kunnr = kna1~kunnr
    INTO (fc_kdgrp, fc_kvgr2, fc_katr1)
    WHERE knvv~kunnr = lv_kunnr.

  SELECT SINGLE reswk
    FROM zplbc
    INTO lv_reswk
    WHERE reswk = lv_vstel.

  IF sy-subrc = 0.
    SELECT SINGLE vgbel
      FROM lips
      INTO lv_vgbel
      WHERE vbeln = fu_vbeln.
    IF sy-subrc = 0.
      SELECT SINGLE bednr
        FROM ekpo
        INTO lv_bednr
        WHERE ebeln = lv_vgbel.
      IF sy-subrc = 0.
* Cek TSHD
        DATA: lv_auart LIKE vbak-auart.
        CLEAR wa_header-tshd.
        SELECT SINGLE auart INTO lv_auart
          FROM vbak WHERE vbeln = lv_bednr.
        IF sy-subrc = 0 AND lv_auart = 'ZTS7'.
          wa_header-tshd = 'TSHD'.
        ENDIF.
* End Cek TSHD

        SELECT SINGLE kunnr adrnr
          FROM vbpa
          INTO (lv_kunnr, lv_adrnr)
          WHERE vbeln = lv_bednr
            AND parvw = 'WE'.
        IF sy-subrc = 0.
          SELECT SINGLE title name1 name2 name3 name4
                        region
            FROM adrc
            INTO (fwa_vblkk-anred, fwa_vblkk-name1, fwa_vblkk-name2,
                  fwa_vblkk-name3, fwa_vblkk-name4, fwa_vblkk-regio)
            WHERE addrnumber = lv_adrnr.

          SELECT SINGLE stras pfach pstl2 ort01 ort02 pstlz land1
            FROM kna1
            INTO (fwa_vblkk-stras, fwa_vblkk-pfach, fwa_vblkk-pstl2,
                  fwa_vblkk-ort01, fwa_vblkk-ort02, fwa_vblkk-pstlz,
                  fwa_vblkk-land1)
            WHERE kunnr = lv_kunnr.
        ENDIF.
      ELSE.
        SELECT SINGLE stras pfach pstl2 ort01 ort02 pstlz land1 adrnr
          FROM kna1
          INTO (fwa_vblkk-stras, fwa_vblkk-pfach, fwa_vblkk-pstl2,
                fwa_vblkk-ort01, fwa_vblkk-ort02, fwa_vblkk-pstlz,
                fwa_vblkk-land1, lv_adrnr)
          WHERE kunnr = lv_kunnr.

        SELECT SINGLE title name1 name2 name3 name4
                      region
          FROM adrc
          INTO (fwa_vblkk-anred, fwa_vblkk-name1, fwa_vblkk-name2,
                fwa_vblkk-name3, fwa_vblkk-name4, fwa_vblkk-regio)
          WHERE addrnumber = lv_adrnr.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT SINGLE stras pfach pstl2 ort01 ort02 pstlz land1 adrnr
      FROM kna1
      INTO (fwa_vblkk-stras, fwa_vblkk-pfach, fwa_vblkk-pstl2, fwa_vblkk-ort01,
            fwa_vblkk-ort02, fwa_vblkk-pstlz, fwa_vblkk-land1, lv_adrnr)
      WHERE kunnr = lv_kunnr.

    SELECT SINGLE title name1 name2 name3 name4
                  region
      FROM adrc
      INTO (fwa_vblkk-anred, fwa_vblkk-name1, fwa_vblkk-name2, fwa_vblkk-name3,
            fwa_vblkk-name4, fwa_vblkk-regio)
      WHERE addrnumber = lv_adrnr.
  ENDIF.

  IF fwa_vblkk-anred IS NOT INITIAL.
    SELECT SINGLE title_medi INTO lv_title_medi
      FROM tsad3t WHERE langu EQ sy-langu
                    AND title EQ fwa_vblkk-anred.
    fwa_vblkk-anred = lv_title_medi.
  ENDIF.

  break bcdik.

  IF lv_vstel = '3800' OR lv_vstel = '0522' OR
     lv_lfart = 'ZTS7' OR lv_lfart = 'ZTS3'.
    SELECT SINGLE kunnr adrnr
      FROM vbpa
      INTO (lv_kunnr, lv_adrnr)
      WHERE vbeln = fu_vbeln
        AND parvw = 'AG'.

    IF sy-subrc = 0.
      SELECT SINGLE name1
        FROM adrc
        INTO fc_ecomnm
        WHERE addrnumber  = lv_adrnr.
    ENDIF.

    SELECT SINGLE kunnr adrnr
      FROM vbpa
      INTO (lv_kunnr, lv_adrnr)
      WHERE vbeln = fu_vbeln
        AND parvw = 'WE'.

    IF sy-subrc = 0.
      SELECT SINGLE title name1 name2 name3 name4
                    region
        FROM adrc
        INTO (fwa_vblkk-anred, fwa_vblkk-name1, fwa_vblkk-name2,
              fwa_vblkk-name3, fwa_vblkk-name4, fwa_vblkk-regio)
        WHERE addrnumber = lv_adrnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_SATUAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_split_satuan  USING    fu_bukrs fu_matnr fu_komng fu_meins
                     CHANGING fc_auom01 fc_auom02 fc_auom03 fc_auom04
                              fc_quantity fc_p1 fc_p2 fc_p3 fc_p4.

  DATA: BEGIN OF lt_zmsutdt005 OCCURS 0,
          matnr   TYPE matnr,
          meins   TYPE meins,
          zaun    TYPE zaun,
          umrez   TYPE umrez,
          umren   TYPE umren,
        END OF lt_zmsutdt005.

  DATA : lv_count   TYPE i,
         lv_meins   TYPE meins,
         lv_umrez   TYPE umrez,
         lv_komng(255),
         lv_selisih(15),
         lv_p1      TYPE zpack2,
         lv_p2      TYPE p DECIMALS 0,
         lv_c1(15),
         lv_lines   TYPE i.

  lv_meins = fu_meins.
  PERFORM f_uom_convers CHANGING lv_meins.

  WRITE fu_komng TO lv_komng UNIT fu_meins.
  CONDENSE lv_komng NO-GAPS.

  CONCATENATE lv_komng lv_meins INTO fc_quantity SEPARATED BY space.
  CLEAR lv_meins.

  CLEAR sy-subrc.

  WHILE sy-subrc EQ 0.
    REPLACE '.' WITH space INTO lv_komng.
  ENDWHILE.
  CONDENSE lv_komng NO-GAPS.

  CLEAR : lv_count, lt_zmsutdt005[], lt_zmsutdt005.
  SELECT matnr meins zaun umrez umren
    FROM zmsutdt005
    INTO TABLE lt_zmsutdt005
    WHERE bukrs EQ fu_bukrs
      AND matnr EQ fu_matnr.

  IF lt_zmsutdt005[] IS NOT INITIAL.
    READ TABLE lt_zmsutdt005 WITH KEY zaun = 'KAR'.
    IF sy-subrc EQ 0.
      lv_meins    = lt_zmsutdt005-meins.
      lv_umrez    = lt_zmsutdt005-umrez.
      lv_selisih  = lv_komng.

      PERFORM f_rounding_value USING lv_p1 lv_komng lv_umrez
                               CHANGING lv_p2.
    ENDIF.

    lv_c1 = lv_p2.
    ADD lv_p2 TO fc_p1.
    CONDENSE lv_c1.
    CONCATENATE lv_c1 'CAR'  INTO fc_auom01 SEPARATED BY space.

    DESCRIBE TABLE lt_zmsutdt005 LINES lv_lines.

    SORT lt_zmsutdt005 BY umrez DESCENDING.
    LOOP AT lt_zmsutdt005.
      IF lt_zmsutdt005-zaun EQ 'KAR'.
        CONTINUE.
      ENDIF.

      ADD 1 TO lv_count.

      lv_komng    = lv_c1 * lv_umrez.
      CALL FUNCTION 'ZCALC1'
        EXPORTING
          input = lv_selisih
        IMPORTING
          value = lv_selisih.

      lv_selisih  = lv_selisih - lv_komng.
      lv_umrez    = lt_zmsutdt005-umrez.

      PERFORM f_rounding_value USING lv_p1 lv_selisih lv_umrez
                               CHANGING lv_p2.

      lv_c1 = lv_p2.
      ADD lv_p2 TO fc_p2.
      CONDENSE lv_c1.

      PERFORM f_uom_convers CHANGING lt_zmsutdt005-zaun.
      CONCATENATE lv_c1 lt_zmsutdt005-zaun INTO fc_auom02 SEPARATED BY space.

      lv_komng    = lv_c1 * lv_umrez.
      lv_selisih  = lv_selisih - lv_komng.
      ADD lv_selisih TO fc_p4.
      CONDENSE lv_selisih.
      PERFORM f_uom_convers CHANGING lv_meins.
      CONCATENATE lv_selisih lv_meins INTO fc_auom04 SEPARATED BY space.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF lv_lines EQ 1.
    READ TABLE lt_zmsutdt005 INDEX 1.
    IF lt_zmsutdt005-zaun EQ 'KAR'.
      lv_komng    = lv_c1 * lv_umrez.
      CALL FUNCTION 'ZCALC1'
        EXPORTING
          input = lv_selisih
        IMPORTING
          value = lv_selisih.

      lv_selisih  = lv_selisih - lv_komng.
      ADD lv_selisih TO fc_p4.
      CONDENSE lv_selisih.
      PERFORM f_uom_convers CHANGING lv_meins.
      CONCATENATE lv_selisih lv_meins INTO fc_auom04 SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SPLIT_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_ROUNDING_VALUE
*&---------------------------------------------------------------------*
FORM f_rounding_value  USING    fu_i1 fu_komng fu_umrez
                       CHANGING fc_i2.
  DATA : lv_p1  TYPE zpack2.

  IF fu_i1 IS INITIAL.
    CALL FUNCTION 'ZCALC1'
      EXPORTING
        sign   = '/'
        input  = fu_komng
        umrez  = fu_umrez
      IMPORTING
        output = lv_p1.
  ELSE.
    lv_p1 = fu_i1.
  ENDIF.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 0
      input         = lv_p1
      sign          = '-'
    IMPORTING
      output        = fc_i2
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUNDING_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERS
*&---------------------------------------------------------------------*
FORM f_uom_convers  CHANGING fc_zaun.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fc_zaun
      language       = sy-langu
    IMPORTING
      output         = fc_zaun
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_UOM_CONVERS

*&---------------------------------------------------------------------*
*&      Form  F_GET_MAX_TIME_PICKING
*&---------------------------------------------------------------------*
FORM f_get_max_time_picking  USING    fu_vstel fu_ort01 fu_kdgrp fu_kvgr2
                                      fu_katr1 fu_vkorg
                             CHANGING fc_kodat fc_kouhr.
  DATA : lt_a511  LIKE a511 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_tvst OCCURS 0,
           vstel TYPE vstel,
           city1 TYPE ad_city1.
  DATA : END  OF lt_tvst.
  DATA : wa_tvst  LIKE lt_tvst.
  DATA : lv_subrc   TYPE sy-subrc,
         lv_ort01   TYPE name4_gp,
         lv_katr1   TYPE katr1,
         i1         TYPE i.

  SELECT kappl kschl vkorg katr1 vkbur kdgrp kunwe
    zday1 zday2 zday3 zday4 zday5 zday6
    FROM a511
    INTO CORRESPONDING FIELDS OF TABLE lt_a511
    WHERE kappl EQ 'V'
      AND kschl EQ 'ZDLV'
      AND vkorg EQ fu_vkorg
      AND datbi GE sy-datum
      AND datab LE sy-datum.

*{   REPLACE        P01K910272                                        1
*\  SELECT vstel city1
*\    FROM tvst
*\    INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
*\    INTO TABLE lt_tvst
*\    WHERE vstel = fu_vstel.
*\
*\  READ TABLE lt_tvst INTO wa_tvst
*\                     WITH KEY vstel = fu_vstel
*\                     BINARY SEARCH.
  "Start SOH: Shell SCI Adjustment 20240221 KS
  SELECT vstel city1
    FROM tvst
    INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
    INTO TABLE lt_tvst
    WHERE vstel = fu_vstel
    ORDER BY tvst~adrnr.

  SORT lt_tvst BY vstel.
  READ TABLE lt_tvst INTO wa_tvst
                     WITH KEY vstel = fu_vstel
                     BINARY SEARCH.
  "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE

  IF ( fu_kdgrp = 'BR' AND fu_vstel NE 'A200' ) OR
     ( fu_kdgrp = 'BR' AND fu_vstel NE 'B102' ).
    lv_subrc = 4.
  ENDIF.

  CHECK lv_subrc IS INITIAL.

  lv_ort01 = fu_ort01.

  CONDENSE lv_ort01 NO-GAPS.
  TRANSLATE lv_ort01 TO UPPER CASE.
  TRANSLATE wa_tvst-city1 TO UPPER CASE.

  IF fu_katr1 IS NOT INITIAL.
    lv_katr1  = fu_katr1.
  ELSE.
    i1 = STRLEN( wa_tvst-city1 ).
    IF lv_ort01(i1) = wa_tvst-city1.
      lv_katr1 = 'DK'.
    ELSE.
      IF ( fu_vstel = '0201' OR
           fu_vstel = '0202' OR
           fu_vstel = '0203' ) AND
           lv_ort01(7) = 'JAKARTA'.
        lv_katr1 = 'DK'.
      ELSEIF fu_vstel = '0240' AND
           lv_ort01(6) = 'MORAWA'.
        lv_katr1 = 'DK'.
      ELSEIF fu_vstel = '0223' AND
         ( lv_ort01(5) = 'YOGYA' OR
           lv_ort01(8) = 'KOTAGEDE' OR
           lv_ort01(6) = 'SLEMAN' OR
           lv_ort01(6) = 'GODEAN' ).
        lv_katr1 = 'DK'.
      ELSE.
        lv_katr1 = 'LK'.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE fu_kdgrp.
    WHEN '08' OR '09'.
      IF lv_katr1 = 'DK'.
        PERFORM f_dk_apar CHANGING fc_kodat fc_kouhr.
      ELSEIF lv_katr1 = 'LK'.
        PERFORM f_fr_a511 TABLES   lt_a511
                          USING    lv_katr1 fu_kdgrp
                          CHANGING fc_kodat fc_kouhr.
      ENDIF.

    WHEN OTHERS.
      PERFORM f_fr_a511 TABLES   lt_a511
                        USING    lv_katr1 fu_kdgrp
                        CHANGING fc_kodat fc_kouhr.
  ENDCASE.

  PERFORM f_calendar_t1 CHANGING fc_kodat.

ENDFORM.                    " F_GET_MAX_TIME_PICKING

*&---------------------------------------------------------------------*
*&      Form  F_DK_APAR
*&---------------------------------------------------------------------*
FORM f_dk_apar  CHANGING fc_kodat fc_kouhr.
  DATA : lv_uzeit   TYPE uzeit VALUE '1400'.

  IF sy-uzeit <= lv_uzeit.
    fc_kouhr  = '2359'.
    fc_kodat  = sy-datum.
  ELSE.
    fc_kouhr = '1400'.
    fc_kodat  = sy-datum + 1.
  ENDIF.
ENDFORM.                    " F_DK_APAR

*&---------------------------------------------------------------------*
*&      Form  F_FR_A511
*&---------------------------------------------------------------------*
FORM f_fr_a511  TABLES   ft_a511 STRUCTURE a511
                USING    fu_katr1 fu_kdgrp
                CHANGING fc_kodat fc_kouhr.

  READ TABLE ft_a511 WITH KEY katr1 = fu_katr1
                              kdgrp = fu_kdgrp.
  IF sy-subrc = 0.
    fc_kodat = sy-datum + ft_a511-zday4.
  ENDIF.
  fc_kouhr  = sy-uzeit.
ENDFORM.                                                    " F_FR_A511

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_GABUNG
*&---------------------------------------------------------------------*
FORM f_process_gabung .
  DATA : lt_sum     LIKE gt_detail OCCURS 0 WITH HEADER LINE,
         lt_detail  LIKE gt_detail OCCURS 0 WITH HEADER LINE,
         wa_detail  LIKE gt_detail.

  DATA : lv_qty(15), lv_auom01(15), lv_auom02(15), lv_auom03(15),
         lv_auom04(15), lv_meins(15), lv_meins01(15), lv_meins02(15),
         lv_meins03(15), lv_meins04(15).

  SORT gt_detail BY matnr charg.
  LOOP AT gt_detail.
    lt_detail = gt_detail.
    APPEND lt_detail.

    lt_sum-matnr  = gt_detail-matnr.
    lt_sum-charg  = gt_detail-charg.
    COLLECT lt_sum.
  ENDLOOP.

  CLEAR : gt_detail[], gt_detail.

* Line item
  DESCRIBE TABLE lt_sum LINES wa_header-lines.
  SHIFT wa_header-lines LEFT DELETING LEADING space.
  CONCATENATE 'Line :' wa_header-lines INTO wa_header-lines
  SEPARATED BY space.

  LOOP AT lt_sum.
    CLEAR : lv_qty, lv_meins, lv_auom01, lv_meins01,
            lv_auom02, lv_meins02, lv_auom03, lv_meins03,
            lv_auom04, lv_meins04.

    LOOP AT lt_detail INTO wa_detail WHERE matnr = lt_sum-matnr
                                       AND charg = lt_sum-charg.
      PERFORM f_split_char USING wa_detail-quantityt
                           CHANGING lv_qty lv_meins.
      PERFORM f_split_char USING wa_detail-auom01t
                           CHANGING lv_auom01 lv_meins01.
      PERFORM f_split_char USING wa_detail-auom02t
                           CHANGING lv_auom02 lv_meins02.
      PERFORM f_split_char USING wa_detail-auom03t
                           CHANGING lv_auom03 lv_meins03.
      PERFORM f_split_char USING wa_detail-auom04t
                           CHANGING lv_auom04 lv_meins04.
    ENDLOOP.

    CONCATENATE lv_qty lv_meins INTO wa_detail-quantityt
    SEPARATED BY space.
    SHIFT wa_detail-quantityt LEFT DELETING LEADING space.

    SHIFT lv_auom01 LEFT DELETING LEADING space.
    IF lv_auom01 <> '0'.
      CONCATENATE lv_auom01 lv_meins01 INTO wa_detail-auom01t
      SEPARATED BY space.
      SHIFT wa_detail-auom01t LEFT DELETING LEADING space.
    ELSE.
      CLEAR wa_detail-auom01t.
    ENDIF.

    SHIFT lv_auom02 LEFT DELETING LEADING space.
    IF lv_auom02 <> '0'.
      CONCATENATE lv_auom02 lv_meins02 INTO wa_detail-auom02t
      SEPARATED BY space.
      SHIFT wa_detail-auom02t LEFT DELETING LEADING space.
    ELSE.
      CLEAR wa_detail-auom02t.
    ENDIF.

    SHIFT lv_auom03 LEFT DELETING LEADING space.
    IF lv_auom03 <> '0'.
      CONCATENATE lv_auom03 lv_meins03 INTO wa_detail-auom03t
      SEPARATED BY space.
      SHIFT wa_detail-auom03t LEFT DELETING LEADING space.
    ELSE.
      CLEAR wa_detail-auom03t.
    ENDIF.

    SHIFT lv_auom04 LEFT DELETING LEADING space.
    IF lv_auom04 <> '0'.
      CONCATENATE lv_auom04 lv_meins04 INTO wa_detail-auom04t
      SEPARATED BY space.
      SHIFT wa_detail-auom04t LEFT DELETING LEADING space.
    ELSE.
      CLEAR wa_detail-auom04t.
    ENDIF.

    APPEND wa_detail TO gt_detail.
    CLEAR wa_detail.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_GABUNG

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_CHAR
*&---------------------------------------------------------------------*
FORM f_split_char  USING    fu_value
                   CHANGING fc_value01 fc_value02.

  DATA : lv_value01(15), lv_value02(15).

  SPLIT fu_value AT space INTO lv_value01 lv_value02.
  CALL FUNCTION 'ZCALC1'
    EXPORTING
      input = lv_value01
    IMPORTING
      value = lv_value01.

  ADD lv_value01 TO fc_value01.
  fc_value02 = lv_value02.
ENDFORM.                    " F_SPLIT_CHAR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_FOR_UNITED
*&---------------------------------------------------------------------*
FORM f_modify_for_united .
  DATA : lv_lfart   TYPE lfart,
         lv_vgbel   TYPE vgbel,
         lv_bednr   TYPE bednr,
         lv_name    TYPE tdobname.

  DATA : lines   LIKE tline OCCURS 0 WITH HEADER LINE.

  break bcdik.
  SELECT SINGLE lfart
    FROM likp
    INTO lv_lfart
    WHERE vbeln = vblkk-vbeln.

  IF sy-subrc = 0.
    IF lv_lfart = 'NLCC'.
      SELECT SINGLE vgbel
        FROM lips
        INTO lv_vgbel
        WHERE vbeln = vblkk-vbeln.
      IF sy-subrc = 0.
        SELECT SINGLE bednr
          FROM ekpo
          INTO lv_bednr
          WHERE ebeln = lv_vgbel.
        IF sy-subrc = 0.
          SELECT SINGLE route
            FROM vbap
            INTO wa_header-lzone
            WHERE vbeln = lv_bednr.

          SELECT SINGLE bnddt
            FROM vbak
            INTO wa_header-bnddt
            WHERE vbeln = lv_bednr.

          lv_name = lv_bednr.
        ENDIF.
      ENDIF.
    ELSE.
      lv_name = vblkk-vbeln.
    ENDIF.
  ENDIF.

  IF lv_name IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = '0002'
        language                = sy-langu
        name                    = lv_name
        object                  = 'VBBK'
      TABLES
        lines                   = lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      READ TABLE lines INDEX 1.
      IF sy-subrc = 0.
        wa_header-headernote  = lines-tdline.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_FOR_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_CALENDAR_T1
*&---------------------------------------------------------------------*
FORM f_calendar_t1  CHANGING fc_kodat.
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                         = fc_kodat
      factory_calendar_id          = 'T1'
    IMPORTING
      date                         = fc_kodat
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      correct_option_invalid       = 2
      date_after_range             = 3
      date_before_range            = 4
      date_invalid                 = 5
      factory_calendar_not_found   = 6
      OTHERS                       = 7.
ENDFORM.                    " F_CALENDAR_T1
