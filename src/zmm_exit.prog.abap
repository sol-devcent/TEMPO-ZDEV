* This Program is all USER EXIT and subroutine in MM module (Purchasing,
* Inventory and Invoice Verification) also SD delivery and Reporting.

* Developed for TEMPO PROJECT requirement by Mahendro K & Lok Ie
* Last modification : 5th December 2002

REPORT  zmm_exit.

****************************** PURCHASING ******************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_PO_EXIT_COMBINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_EKKO  LIKE  EKKO
*      -->T_EKPO  LIKE  EKPO
*      -->T1_KOMP LIKE  KOMP
*      <--T2_KOMP LIKE  KOMP
*----------------------------------------------------------------------*
FORM f_mm_po_exit_combine
             USING t_ekko  STRUCTURE ekko
                   t_ekpo  STRUCTURE ekpo
                   t1_komp  STRUCTURE komp
                   t2_komp  STRUCTURE komp.

*This user exit is for additional field EXTWG in PO Pricing
  PERFORM f_mm_field_pricing
               USING  t_ekpo-matnr
                      t1_komp
                      t2_komp.

  IF sy-tcode NE 'ME21' AND sy-tcode NE 'ME21N' AND
     sy-tcode NE 'ME22' AND sy-tcode NE 'ME22N' AND
     sy-tcode NE 'ME23' AND sy-tcode NE 'ME23N' AND
     sy-tcode NE 'ZM92'.
    EXIT.
  ENDIF.

*This user exit is for validation Order type and Vendor account group
  PERFORM f_mm_validasi_ordtype_vendor
               USING t_ekko
                     t_ekpo.

ENDFORM.                    " F_MM_PO_EXIT_COMBINE

*&---------------------------------------------------------------------*
*&      Form  F_MM_PRT_ORD_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_EKKO  LIKE  EKKO
*----------------------------------------------------------------------*
FORM f_mm_prt_ord_type
             USING t_ekko STRUCTURE ekko.

  DATA : v_bsart  LIKE ekko-bsart,
         lv_bukrs LIKE ekko-bukrs,
         lv_ibeln TYPE zde0002,
         lv_ifile TYPE zde0006.

  SELECT SINGLE bsart FROM ekko INTO v_bsart WHERE ebeln = t_ekko-ebeln.
  IF sy-subrc = '0' AND t_ekko-bsart <> v_bsart.
    MESSAGE e002(zz) WITH 'Order type is not changeable'.
  ENDIF.

  IF v_bsart EQ 'RSUT'.

  ENDIF.

  SELECT SINGLE bukrs FROM t001k INTO lv_bukrs WHERE bwkey = t_ekko-reswk.

  IF lv_bukrs EQ '8070'.
    IF sy-tcode EQ 'ME22' OR
       sy-tcode EQ 'ME22N'.
      SELECT SINGLE ibeln ifile
        FROM zmsutdt001
        INTO (lv_ibeln, lv_ifile)
        WHERE ibeln EQ t_ekko-ebeln.

      IF sy-subrc EQ 0 AND lv_ifile <> ''.
        MESSAGE e002(zz) WITH 'STO sudah ada di interface'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_MM_PRT_ORD_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_MM_MATKL_AUTH_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_EKPO  LIKE  EKPO
*----------------------------------------------------------------------*
FORM f_mm_matkl_auth_check
             USING t_ekpo STRUCTURE ekpo.
  DATA : d_begru LIKE t023-begru.

  SELECT SINGLE begru FROM t023 INTO d_begru
  WHERE matkl = t_ekpo-matkl.

  AUTHORITY-CHECK OBJECT 'M_MATE_WGR'
      ID 'BEGRU' FIELD d_begru.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Material Group'
     t_ekpo-matkl.
  ENDIF.
ENDFORM.                    " F_MM_MATKL_AUTH_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_MM_field_PRICING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_MATNR LIKE  EKPO-MATNR
*      -->T1_KOMP  LIKE  KOMP
*      <--T2_KOMP  LIKE  KOMP
*----------------------------------------------------------------------*
FORM f_mm_field_pricing
             USING pa_matnr LIKE ekpo-matnr
                   t1_komp  STRUCTURE komp
                   t2_komp  STRUCTURE komp.

  DATA : lv_prdha    TYPE mara-prdha,
         l_usergroup LIKE usgrp_user-usergroup.

  MOVE t1_komp TO t2_komp.

  SELECT SINGLE prdha magrv FROM mara
  INTO (lv_prdha, t2_komp-magrv)
  WHERE matnr = pa_matnr.

  t2_komp-zzprodh1 = lv_prdha.
  t2_komp-zzextwg  = t2_komp-zzprodh1.

  t2_komp-prodh2   = lv_prdha+3(3).

  CLEAR l_usergroup.
  SELECT SINGLE usergroup INTO l_usergroup
         FROM usgrp_user
         WHERE bname  = sy-uname
           AND usergroup = 'TDS*'.
  IF sy-subrc EQ 0.
    t2_komp-magrv = '0005'. "l_usergroup(3)'.
  ENDIF.

ENDFORM.                    " F_MM_field_PRICING

*&---------------------------------------------------------------------*
*&      Form  F_MM_VALIDASI_ORDTYPE_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_EKKO  LIKE  EKKO
*----------------------------------------------------------------------*
FORM f_mm_validasi_ordtype_vendor
             USING t_ekko STRUCTURE ekko
                   t_ekpo STRUCTURE ekpo.

  DATA : v_ktokk     LIKE lfa1-ktokk,
         v_werks     LIKE lfa1-werks,
         s_bukrs     LIKE t001k-bukrs,
         r_bukrs     LIKE t001k-bukrs,
         err_msg(60) TYPE c.

  DATA: lv_live   LIKE zplbc-live.

  SELECT SINGLE ktokk werks FROM lfa1 INTO (v_ktokk , v_werks)
         WHERE lifnr = t_ekko-lifnr.

  CONCATENATE 'Order type'
              t_ekko-bsart
              'tidak boleh digunakan untuk vendor'
  INTO err_msg SEPARATED BY space.

  CASE t_ekko-bsart.

    WHEN 'NB'.
      IF v_ktokk <> 'TNAD' AND v_ktokk <> 'TASD' AND v_ktokk <> 'TAFD' AND
         v_ktokk <> 'TARD'.
        MESSAGE e002(zz) WITH err_msg t_ekko-lifnr.
      ENDIF.

    WHEN 'UB'.
      SELECT SINGLE bukrs FROM t001k INTO s_bukrs WHERE bwkey = t_ekko-reswk.
      SELECT SINGLE bukrs FROM t001k INTO r_bukrs WHERE bwkey = t_ekpo-werks.

      IF t_ekko-bedat GE '20140201'.
        IF s_bukrs EQ '8020' OR
          s_bukrs EQ '8070'.
          IF t_ekpo-reslo IS INITIAL.
            MESSAGE 'Issuing S.Loc harus diisi' TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.

*----- Penambahan validasi untuk SUT
      IF s_bukrs EQ '8070'.
        SELECT SINGLE live
          FROM zplbc
          INTO lv_live
          WHERE bukrs EQ s_bukrs AND
                werks EQ t_ekko-reswk.
        IF lv_live IS INITIAL.
          CONCATENATE 'Ord type'
                      t_ekko-bsart
                    'tdk boleh digunakan utk supplying plant'
          INTO err_msg SEPARATED BY space.
          MESSAGE e002(zz) WITH err_msg t_ekko-reswk.
        ENDIF.
      ENDIF.
*-----

      IF s_bukrs <> r_bukrs.
        IF t_ekpo-matnr(1) NE 'Z' AND
          t_ekpo-matnr(1) NE 'A'.
          CONCATENATE 'Ord type'
                      t_ekko-bsart
                    'tdk boleh digunakan utk supplying plant'
          INTO err_msg SEPARATED BY space.
          MESSAGE e002(zz) WITH err_msg t_ekko-reswk.
        ENDIF.
      ENDIF.

    WHEN 'OB'.
      IF v_ktokk <> 'TNAF'.
        MESSAGE e002(zz) WITH err_msg t_ekko-lifnr.
      ENDIF.

    WHEN 'RNB'.
      IF v_ktokk <> 'TNAD' AND v_ktokk <> 'TASD' AND v_ktokk <> 'TNAF' AND
         v_ktokk <> 'TAFD' AND v_ktokk <> 'TARD'.
        MESSAGE e002(zz) WITH err_msg t_ekko-lifnr.
      ENDIF.

    WHEN 'ZB' OR 'RZB' OR 'ZSUT' OR 'RSUT'.
      IF v_ktokk <> 'TAFD' OR v_werks = ''.
        MESSAGE e002(zz) WITH err_msg t_ekko-lifnr.
      ENDIF.

    WHEN 'ZNB' OR 'RZNB'.
      IF v_ktokk <> 'TABC'.
        MESSAGE e002(zz) WITH err_msg t_ekko-lifnr.
      ENDIF.

    WHEN 'ZICO'.
* Penambahan exit untuk Automation Intercompany
      IF sy-tcode NE 'ZM92'.
        IF t_ekpo-reslo IS INITIAL.
          MESSAGE e002(zz) WITH 'Issuing Storage Location must not be blank'.
        ENDIF.
      ENDIF.
*--

* Exit untuk change PO
      DATA: lv_error  TYPE sy-subrc.

      IF t_ekko-bukrs EQ '8020'.
        IF sy-tcode EQ 'ME22' OR
           sy-tcode EQ 'ME22N' OR
           sy-tcode EQ 'ME23N'.

          PERFORM f_cek_po USING t_ekpo
                                 t_ekko-ebeln
                           CHANGING lv_error.

          CASE lv_error.
            WHEN '1'.
              MESSAGE 'Item tidak dapat dirubah karena sudah ada PO pabrik' TYPE 'E'.
            WHEN '2'.
              MESSAGE 'Item tidak dapat dirubah karena sudah ada PO pabrik' TYPE 'E'.
            WHEN '3'.
              MESSAGE 'Item tidak dapat dirubah karena sudah ada PO pabrik' TYPE 'E'.
            WHEN '4'.
              MESSAGE 'Item tidak dapat dirubah karena sudah ada PO pabrik' TYPE 'E'.
            WHEN '5'.
              MESSAGE 'Item tidak dapat dirubah karena sudah ada PO pabrik' TYPE 'E'.
          ENDCASE.
        ENDIF.
      ENDIF.
  ENDCASE.

* Penambahan exit untuk Automation Intercompany
  DATA: lv_mtpos TYPE mtpos,
        lv_vkorg TYPE vkorg.

  CLEAR lv_vkorg.
  SELECT SINGLE vkorg
    FROM t001l
    INTO lv_vkorg
    WHERE werks EQ t_ekko-reswk
      AND lgort EQ t_ekpo-reslo.

  CLEAR lv_mtpos.
  SELECT SINGLE mtpos
    FROM mvke
    INTO lv_mtpos
    WHERE matnr EQ t_ekpo-matnr
      AND vkorg EQ lv_vkorg.
  IF sy-subrc EQ 0.
    IF lv_mtpos EQ 'ZNOR'.
      IF t_ekpo-reslo IS INITIAL.
        MESSAGE e002(zz) WITH 'Issuing Storage Location must not be blank'.
      ENDIF.
    ENDIF.
  ENDIF.
*--
ENDFORM.                    " F_MM_VALIDASI_ORDTYPE_VENDOR


*&---------------------------------------------------------------------*
*&      Form  F_MM_CHECK_PO_REASON
*&---------------------------------------------------------------------*
FORM f_mm_check_po_reason
             USING i_matnr TYPE ekpo-matnr
                   i_werks TYPE ekpo-werks
                   i_bsgru TYPE ekpo-bsgru
                   i_reswk TYPE ekko-reswk
                   i_lifnr TYPE ekko-lifnr
                   i_bedat TYPE ekko-bedat
                   dobel.
  DATA : e_ebeln  TYPE ekko-ebeln.

  IF i_lifnr = ''.
    SELECT SINGLE ekko~ebeln
      INTO e_ebeln
    FROM ekko INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
    WHERE ekpo~matnr = i_matnr
      AND ekpo~werks = i_werks
      AND ekpo~bsgru = i_bsgru
      AND ekpo~loekz = ''
      AND ekko~reswk = i_reswk
      AND ekko~bedat >= i_bedat.
  ELSE.
    SELECT SINGLE ekko~ebeln
      INTO e_ebeln
    FROM ekko INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
    WHERE ekpo~matnr = i_matnr
      AND ekpo~werks = i_werks
      AND ekpo~bsgru = i_bsgru
      AND ekpo~loekz = ''
      AND ekko~lifnr = i_lifnr
      AND ekko~bedat >= i_bedat.
  ENDIF.

  IF sy-subrc = 0 AND dobel = 'X'.
    MESSAGE e002(zz) WITH
    'Material ' i_matnr ' sudah ada di PO ' e_ebeln.
  ELSEIF sy-subrc <> 0 AND dobel = ''.
    MESSAGE e002(zz) WITH
    i_bsgru ' untuk material ' i_matnr 'belum ada'.
  ENDIF.
ENDFORM.                    "F_MM_CHECK_PO_REASON
*&---------------------------------------------------------------------*
*&      Form  F_MM_header_field_PRICING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_MATNR LIKE  EKPO-MATNR
*      -->T1_KOMK  LIKE  KOMK
*      <--T2_KOMK  LIKE  KOMK
*----------------------------------------------------------------------*
FORM f_mm_header_field_pricing
             USING t_ekko  STRUCTURE ekko
                   t_ekpo  STRUCTURE ekpo
                   t1_komk  STRUCTURE komk
                   t2_komk  STRUCTURE komk.
  DATA : d_kunnr  LIKE vbak-kunnr,
         lv_lfart LIKE likp-lfart,
         lv_daart LIKE tvlk-daart,
         lf_werks LIKE ekpo-werks.


  MOVE t1_komk TO t2_komk.
  t2_komk-zzbsart = t_ekko-bsart.
  CLEAR d_kunnr.

* TDG2 Project
  IF t_ekko-bukrs = '8180' OR t_ekko-bukrs = '8220'.
    IF t_ekko-bsart = 'ZB' OR t_ekko-bsart = 'RZB' OR t_ekko-bsart = 'ZSUB'.
      t2_komk-kdgrp = 'SB'.
      CONCATENATE 'TSB' t_ekpo-werks INTO d_kunnr.
      SELECT SINGLE kalks INTO t2_komk-zzkalks FROM knvv
      WHERE kunnr = d_kunnr AND
            vtweg = '10'  AND
            spart = '00'.

      SELECT SINGLE kunnr INTO t2_komk-kunre
        FROM t001w WHERE werks = t_ekpo-werks.
      SELECT SINGLE vkorg INTO t2_komk-vkorg
        FROM t001w WHERE lifnr = t_ekko-lifnr.
      SELECT SINGLE vtweg INTO t2_komk-vtweg
        FROM knvv WHERE kunnr = t2_komk-kunre
                    AND vkorg = t2_komk-vkorg.

    ELSEIF t_ekko-bsart = 'ZNB' OR t_ekko-bsart = 'RZNB'.
      t2_komk-kdgrp = 'BR'.
      CONCATENATE 'TBA' t_ekpo-werks INTO d_kunnr.
      SELECT SINGLE kalks FROM knvv INTO t2_komk-zzkalks
      WHERE kunnr = d_kunnr AND
            vtweg = '10'  AND
            spart = '00'.

    ELSEIF t_ekko-bsart = 'ZSUT' OR t_ekko-bsart = 'RSUT'.
      SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
      WHERE werks =  t_ekpo-werks.

    ELSEIF t_ekko-bsart = 'ZICO' OR t_ekko-bsart = 'RICO'.
      IF t_ekpo-lgort EQ '1005'.
        SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
        WHERE werks =  t_ekpo-werks.
      ENDIF.
    ENDIF.

  ELSE.
    IF t_ekko-bsart = 'ZB' OR t_ekko-bsart = 'RZB'. " OR t_ekko-bsart = 'ZSUB'.
      t2_komk-kdgrp = 'SB'.
      IF t_ekpo-werks(2) = '07'. "Project United
        SELECT SINGLE kunnr INTO t2_komk-kunnr FROM t001w
        WHERE werks =  t_ekpo-werks.
        IF t2_komk-kunnr IS NOT INITIAL.
          SELECT SINGLE vkbur kvgr3
            FROM knvv
            INTO (t2_komk-vkbur, t2_komk-kvgr3)
            WHERE kunnr = t2_komk-kunnr
              AND vkorg = '8020'.
          SELECT SINGLE kunn2
        FROM knvp
        INTO t2_komk-kunre
        WHERE kunnr = t2_komk-kunnr
          AND parvw = 'RE'
          AND vkorg = '8020'.
        ENDIF.
      ELSEIF t_ekpo-werks = '0101' AND
        t_ekko-reswk = '0901'
        OR t_ekpo-werks = '0102' AND
        t_ekko-reswk = '3600'.
        SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001l
          WHERE werks = t_ekpo-werks
            AND lgort = t_ekpo-lgort.
        IF t2_komk-kunre IS INITIAL.
          SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
          WHERE werks =  t_ekpo-werks.
          IF t2_komk-kunre IS NOT INITIAL.
            t2_komk-kunnr = t2_komk-kunre.
          ENDIF.
        ELSE.
          t2_komk-kunnr = t2_komk-kunre.
        ENDIF.

        t2_komk-vkorg = t2_komk-revko.

      ELSEIF t_ekpo-werks(2) = '38' OR
         t_ekpo-werks(2) = '39' . "Project TDN
** Refine Logic to Remove Hardcoded value
**        IF t_ekko-lifnr = 'TSB8210'.
**          t2_komk-vkorg = '8210'.
**          t2_komk-kdgrp = 'PT'.
**          SELECT SINGLE kunnr
**            FROM t001w
**            INTO t2_komk-kunnr
**            WHERE werks = t_ekpo-werks.
**        ELSE.
**          SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001l
**          WHERE werks = t_ekpo-werks
**            AND lgort = t_ekpo-lgort.
**          IF t2_komk-kunre IS INITIAL.
**            SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
**            WHERE werks =  t_ekpo-werks.
**          ENDIF.
**          t2_komk-kdgrp = '03'.
**          t2_komk-vkorg = '8020'.
**          IF t2_komk-kunre IS NOT INITIAL.
**            SELECT SINGLE vkbur kvgr3
**              FROM knvv
**              INTO (t2_komk-vkbur, t2_komk-kvgr3)
**              WHERE kunnr = t2_komk-kunre
**                AND vkorg = t2_komk-vkorg.
**          ENDIF.
**        ENDIF.
        SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001l
          WHERE werks = t_ekpo-werks
            AND lgort = t_ekpo-lgort.
        IF t2_komk-kunre IS INITIAL.
          SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
          WHERE werks =  t_ekpo-werks.
          IF t2_komk-kunre IS NOT INITIAL.
            t2_komk-kunnr = t2_komk-kunre.
          ENDIF.
        ELSE.
          t2_komk-kunnr = t2_komk-kunre.
        ENDIF.

        t2_komk-vkorg = t2_komk-revko.


        IF t2_komk-reswk IS NOT INITIAL.
          t2_komk-vkbur = t2_komk-reswk.
          IF t2_komk-reswk(2) = '02'.
*            SELECT SINGLE kunnr INTO d_kunnr
*               FROM ekpv
*               WHERE ebeln = t_ekpo-ebeln
*                 AND ebelp = t_ekpo-ebelp.
*            t2_komk-kunnr = d_kunnr.
*            t2_komk-kunre = d_kunnr.
            CLEAR lf_werks.
            lf_werks = |{ t_ekpo-werks(2) }{ t_ekko-reswk+2(2) }|.
            IF t_ekpo-knttp = 'M'.
*              SELECT SINGLE field_value2 INTO d_kunnr "t2_komk-kunnr
*              CONCATENATE t_ekpo-werks(2) t_ekko-reswk+2(2) INTO lf_werks.

              SELECT SINGLE field_value2 INTO d_kunnr "t2_komk-kunnr
                FROM zscust_control
                WHERE vkorg         = t_ekko-bukrs
                  AND cek           = 'ERT'
                  AND field_name    = t_ekpo-werks
                  AND field_value   = t2_komk-reswk.
              IF sy-subrc IS NOT INITIAL.
                SELECT SINGLE field_value2 INTO d_kunnr "t2_komk-kunnr
                  FROM zscust_control
                  WHERE vkorg         = t_ekko-bukrs
                    AND cek           = 'ERT'
                    AND field_name    = lf_werks
                    AND field_value   = t2_komk-reswk.
              ENDIF.
              t2_komk-kunnr = d_kunnr.
              t2_komk-kunre = d_kunnr.
*            ELSEIF t_ekpo-lgort = '1099' OR t_ekpo-lgort = '1199'.
*              SELECT SINGLE field_value3 INTO d_kunnr
*                  FROM zscust_control
*                  WHERE vkorg         = t_ekko-bukrs
*                    AND cek           = 'ERT'
*                    AND field_name    = 'KUNNR'
*                    AND field_value   = t2_komk-reswk.
            ELSEIF t_ekpo-lgort+2(2) = '99'.
              SELECT SINGLE field_value3 INTO d_kunnr
                  FROM zscust_control
                  WHERE vkorg         = t_ekko-bukrs
                    AND cek           = 'ERT'
                    AND field_name    = 'KUNNR'
                    AND field_value   = t2_komk-reswk
                    AND field_value4  = t_ekpo-lgort.
              IF sy-subrc NE 0.
                SELECT SINGLE field_value3 INTO d_kunnr "t2_komk-kunnr
                  FROM zscust_control
                  WHERE vkorg         = t_ekko-bukrs
                    AND cek           = 'ERT'
                    AND field_name    = lf_werks
                    AND field_value   = t2_komk-reswk.
                IF sy-subrc NE 0.
                  SELECT SINGLE field_value2 INTO d_kunnr
                    FROM zscust_control
                    WHERE vkorg         = t_ekko-bukrs
                      AND cek           = 'ERT'
                      AND field_name    = 'KUNNR'
                      AND field_value   = t2_komk-reswk.
                ENDIF.
              ENDIF.
              t2_komk-kunnr = d_kunnr.
              t2_komk-kunre = d_kunnr.
            ELSE.
*              SELECT SINGLE field_value3 INTO d_kunnr "t2_komk-kunnr
              SELECT SINGLE field_value3 INTO d_kunnr "t2_komk-kunnr
                  FROM zscust_control
                  WHERE vkorg         = t_ekko-bukrs
                    AND cek           = 'ERT'
                    AND field_name    = lf_werks
                    AND field_value   = t2_komk-reswk.
              IF sy-subrc NE 0.
                SELECT SINGLE field_value2 INTO d_kunnr "t2_komk-kunnr
                  FROM zscust_control
                  WHERE vkorg         = t_ekko-bukrs
                    AND cek           = 'ERT'
                    AND field_name    = 'KUNNR'
                    AND field_value   = t2_komk-reswk.
              ENDIF.
              t2_komk-kunnr = d_kunnr.
              t2_komk-kunre = d_kunnr.
            ENDIF.
          ELSEIF t2_komk-reswk = '2100'
            AND t_ekko-bsart = 'RZB'.
*Untuk ambil sales doc type dari VK13 ZMDP PO Type RZB reswk 2100 werks 3800.
            SELECT SINGLE lfart FROM t161v INTO lv_lfart
              WHERE bstyp = 'F'
              AND bsart = 'RZB'
              AND reswk = t2_komk-reswk.
            IF sy-subrc = 0.
              SELECT SINGLE daart FROM tvlk INTO lv_daart
                WHERE lfart = lv_lfart.
              IF sy-subrc = 0.
                t2_komk-auart_sd = lv_daart.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF t2_komk-kunre IS NOT INITIAL.
          SELECT SINGLE vkbur kvgr3 kdgrp
            FROM knvv
            INTO (t2_komk-vkbur, t2_komk-kvgr3, t2_komk-kdgrp)
            WHERE kunnr = t2_komk-kunre
              AND vkorg = t2_komk-vkorg.
        ENDIF.

      ELSE.
        CONCATENATE 'TSB' t_ekpo-werks INTO d_kunnr.
        SELECT SINGLE kalks INTO t2_komk-zzkalks FROM knvv
        WHERE kunnr = d_kunnr AND
              vtweg = '10'  AND
              spart = '00'.
      ENDIF.
    ELSEIF t_ekko-bsart = 'ZNB' OR t_ekko-bsart = 'RZNB'.
      t2_komk-kdgrp = 'BR'.
      CONCATENATE 'TBA' t_ekpo-werks INTO d_kunnr.
      SELECT SINGLE kalks FROM knvv INTO t2_komk-zzkalks
      WHERE kunnr = d_kunnr AND
            vtweg = '10'  AND
            spart = '00'.
    ELSEIF t_ekko-bsart = 'ZSUT' OR t_ekko-bsart = 'RSUT'.
      SELECT SINGLE kunnr INTO t2_komk-kunnr FROM t001w
      WHERE werks =  t_ekpo-werks.
      IF t2_komk-kunnr IS NOT INITIAL.
        SELECT SINGLE vkbur kvgr3
          FROM knvv
          INTO (t2_komk-vkbur, t2_komk-kvgr3)
          WHERE kunnr = t2_komk-kunnr
            AND vkorg = '8020'.
        SELECT SINGLE kunn2
        FROM knvp
        INTO t2_komk-kunre
        WHERE kunnr = t2_komk-kunnr
          AND parvw = 'RE'
          AND vkorg = '8020'.
      ENDIF.
    ELSEIF t_ekko-bsart = 'ZICO' OR t_ekko-bsart = 'RICO'.
      IF t_ekpo-lgort EQ '1005'.
        SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
        WHERE werks =  t_ekpo-werks.
      ENDIF.
    ENDIF.
  ENDIF.

* Special process for TNT non Live PO
  IF t_ekpo-werks = '1601' AND t_ekko-ekorg = 'TNT'.
    IF t_ekko-bukrs = '8160'.
      SELECT SINGLE bukrs FROM t001 INTO t_ekko-bukrs
      WHERE bukrs = t_ekpo-afnam.
      IF sy-subrc <> 0.
        SELECT SINGLE bukrs FROM t001k INTO t_ekko-bukrs
        WHERE bwkey = t_ekpo-afnam(4).
        IF sy-subrc <> 0.
          CONCATENATE 'TSB' t_ekpo-afnam(4) INTO d_kunnr.
          SELECT SINGLE vbund FROM kna1 INTO d_kunnr
          WHERE kunnr = d_kunnr AND vbund <> 'OTHERS'.
          IF sy-subrc = 0.
            t_ekko-bukrs = d_kunnr+2(4).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    t2_komk-bukrs = t_ekko-bukrs.
  ENDIF.

  IF t_ekko-bukrs = '8010' AND
  ( t_ekko-bsart = 'ZSUB' OR t_ekko-bsart = 'ZB' ) AND
    t_ekpo-werks = '0102' AND
    t_ekko-reswk = '3600'.
    SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001l
      WHERE werks = t_ekpo-werks
        AND lgort = t_ekpo-lgort.
    IF t2_komk-kunre IS INITIAL.
      SELECT SINGLE kunnr INTO t2_komk-kunre FROM t001w
      WHERE werks =  t_ekpo-werks.
      IF t2_komk-kunre IS NOT INITIAL.
        t2_komk-kunnr = t2_komk-kunre.
      ENDIF.
    ELSE.
      t2_komk-kunnr = t2_komk-kunre.
    ENDIF.

    t2_komk-vkorg = t2_komk-revko.
    t2_komk-vtweg = t2_komk-revtw.
  ENDIF.
ENDFORM.                    " F_MM_header_field_pricing

************************* INVENTORY MANAGEMENT *************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_check_batch_COPY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_I_MKPF  LIKE MKPF
*      -->PA_I_MSEG  LIKE MSEG
*      <--PA_E_CHARG LIKE MSEG-CHARG
*----------------------------------------------------------------------*
FORM f_mm_check_batch_copy
            USING pa_i_mseg STRUCTURE mseg
                  pa_e_charg LIKE mseg-charg.

  DATA : sl_auth LIKE t001l-xblgo.
  CLEAR sl_auth.

  CASE pa_i_mseg-bwart.

    WHEN '303'.
      IF pa_i_mseg-charg NE '*'.
        pa_e_charg = pa_i_mseg-charg.
      ENDIF.
      IF pa_i_mseg-umwrk EQ '0200' OR
        pa_i_mseg-umwrk EQ '0700'.
        SELECT SINGLE xblgo INTO sl_auth FROM t001l
        WHERE werks = pa_i_mseg-umwrk AND xblgo = ''.
        IF sy-subrc = 0 AND pa_i_mseg-umlgo = ''.
          MESSAGE e002(zz) WITH 'Tolong isi Recv. SLoc'.
*        Elseif SY-SUBRC <> 0 and pa_I_MSEG-UMLGO <> ''.
*          MESSAGE E002(zz) with 'Tolong kosongkan Recv. SLoc'.
        ENDIF.
      ENDIF.

      IF pa_i_mseg-bukrs EQ '8070' AND
        pa_i_mseg-umwrk EQ '0700'.
        IF pa_i_mseg-umlgo NE '1000' AND
          pa_i_mseg-umlgo NE '1100' AND
          pa_i_mseg-umlgo NE '1005'.
          MESSAGE e002(zz) WITH 'Recv. SLoc harus diisi 1000/1100/1005'.
        ENDIF.
      ENDIF.

    WHEN '311'.
      IF pa_i_mseg-umlgo(1) = '2' AND
        ( pa_i_mseg-werks(2) = '02' OR
          pa_i_mseg-werks(2) = '07' ).
        pa_e_charg = '00'.
      ENDIF.

      DATA : lv_flag(1).

      SELECT SINGLE flag
        FROM zproject
        INTO lv_flag
        WHERE name EQ 'CUTOVER'.

      IF lv_flag IS INITIAL.
        CASE pa_i_mseg-werks.
          WHEN '0200'.
            IF pa_i_mseg-lgort EQ '1000' AND
              ( pa_i_mseg-umlgo EQ '1002' OR
              pa_i_mseg-umlgo EQ '1003' ).
              MESSAGE 'Please use mvt 313' TYPE 'E'.
            ENDIF.
            IF ( pa_i_mseg-lgort EQ '1002' OR
              pa_i_mseg-lgort EQ '1003') AND
              pa_i_mseg-umlgo EQ '1000'.
              MESSAGE 'Please use mvt 313' TYPE 'E'.
            ENDIF.

          WHEN '0700'.
            IF pa_i_mseg-lgort EQ '1000' AND
              pa_i_mseg-umlgo EQ '1001'.
              MESSAGE 'Please use mvt 313' TYPE 'E'.
            ENDIF.
            IF pa_i_mseg-lgort EQ '1001' AND
              pa_i_mseg-umlgo EQ '1000'.
              MESSAGE 'Please use mvt 313' TYPE 'E'.
            ENDIF.
        ENDCASE.
      ENDIF.
    WHEN '313'.
*    IF pa_i_mseg-werks = '2300' AND pa_i_mseg-lgort = '2000'.
*       Data : lv_field(39) TYPE c.
*       FIELD-SYMBOLS: <lfs_vm07m>   TYPE vm07m.
*       lv_field = '(SAPMM07M)VM07M'.
*       ASSIGN (lv_field) TO <lfs_vm07m>.
*       If <lfs_vm07m>-disgr = 'MRF4'. "FG Labelling
*          Data : d_aufnr type aufnr.
*          IF pa_i_mseg-sgtxt = ''.
*             MESSAGE e002(zz) WITH 'Please enter valid Proc order number in item text'.
*          ENDIF.
*          concatenate '000' pa_i_mseg-sgtxt into d_aufnr.
*          Select single aufnr into d_aufnr from aufm
*            where aufnr = d_aufnr and
*                  matnr = pa_i_mseg-matnr and
*                  charg = pa_i_mseg-charg.
*          If sy-subrc <> 0.
*             MESSAGE e002(zz) WITH 'Please enter valid Proc order number in item text'.
*          Endif.
*       Endif.
*    ENDIF.
  ENDCASE.
ENDFORM.                    " F_MM_check_batch_COPY

*&---------------------------------------------------------------------*
*&      FORM F_MM_check_and_text_mdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_I_MSEG  LIKE MSEG
*      <--PA_E_SGTXT LIKE MSEG-SGTXT
*----------------------------------------------------------------------*
FORM f_mm_check_and_text_mdoc
            USING pa_i_mkpf STRUCTURE mkpf
                  pa_i_mseg STRUCTURE mseg
                  pa_e_sgtxt LIKE mseg-sgtxt.

  TABLES : zmmt0002.

  TYPES : BEGIN OF ty_mseg,
            mblnr TYPE mseg-mblnr,
            mjahr TYPE mseg-mjahr,
            zeile TYPE mseg-zeile,
            smbln TYPE mseg-smbln,
          END OF ty_mseg.

  DATA : v_bsart   LIKE ekko-bsart,
         v_ebeln   LIKE ekbe-ebeln,
         v_bstnk   LIKE vbak-bstnk,
         v_rfmng   LIKE vbfa-rfmng,
         o_rfmng   LIKE vbfa-rfmng,
         v_vbeln   LIKE vbfa-vbeln,
         o_vbeln   LIKE vbfa-vbeln,
         v_wbstk   LIKE vbuk-wbstk,
         mdoc      LIKE mseg-mblnr,
         year      LIKE mseg-gjahr,
         werks     LIKE mseg-werks,
         bwart     LIKE mseg-bwart,
         zeile     LIKE mseg-zeile,
         t_xblnr   LIKE mkpf-xblnr,
         t_mblnr   LIKE mseg-mblnr,
         t_umlgo   LIKE mseg-umlgo,
         t_matnr   LIKE mseg-matnr,
         t_menge   LIKE mseg-menge,
         t_kunnr   LIKE mseg-kunnr,
         t_mtart   LIKE mara-mtart,
         t_lzone   LIKE kna1-lzone,
         t_matkl   LIKE mara-matkl,
*           t_matnr like mara-matnr,
         pc        TYPE i,
         sepa1     TYPE i,
         sepa2     TYPE i,
         sepa3     TYPE i,
         d_sobsl   TYPE marc-sobsl,
         d_slabs   TYPE mkol-slabs,
         d_extwg   TYPE mara-extwg,
         d_lgort   TYPE mseg-lgort,
         d_reswk   TYPE ekko-reswk,
         d_lfart   TYPE t161v-lfart,
         l_live(1),
         d_ordtyp  LIKE ekko-bsart,
         lv_mtpos  TYPE mtpos,
         lv_vkorg  TYPE vkorg,
         lv_vbeln  TYPE vbeln,
         lv_smbln  TYPE mseg-smbln.

  DATA: lt_zmreldn_hist  LIKE zmreldn_hist OCCURS 0 WITH HEADER LINE,
        lwa_zmreldn_hist LIKE zmreldn_hist,
        lwa_eina         LIKE eina.

  DATA : matnum   LIKE mseg-matnr,
         mgroup   LIKE mara-matkl,
         mtype    LIKE mara-mtart,
         d_status LIKE zst_point-status.

  DATA: ld_error TYPE i,
        ld_zflag LIKE zmgudang-zflag,
        wa_mseg  LIKE mseg,
        lv_menge TYPE etmen.

  DATA: BEGIN OF gt_ekpo OCCURS 0,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          matnr TYPE matnr,
          menge TYPE bstmg,
          lewed TYPE lewed,
          reslo TYPE reslo,
        END OF gt_ekpo.

  DATA: BEGIN OF gt_ekbe OCCURS 0,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          matnr TYPE matnr,
          menge TYPE menge_d,
        END OF gt_ekbe.

  DATA: BEGIN OF gt_eket OCCURS 0,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          menge TYPE etmen,
          wamng TYPE wamng,
        END OF gt_eket.

  DATA: lv_bwart TYPE bwart.

  DATA : lt_mseg1 TYPE STANDARD TABLE OF ty_mseg,
         lt_mseg2 TYPE STANDARD TABLE OF ty_mseg,
         ls_mseg1 LIKE LINE OF lt_mseg1,
         ls_mseg2 LIKE LINE OF lt_mseg2.

  pa_e_sgtxt = pa_i_mseg-sgtxt.

  CASE pa_i_mseg-bwart.

    WHEN '101'.
      CHECK pa_i_mseg-bukrs NE '8050' AND
            pa_i_mseg-bukrs NE '8230' AND
            pa_i_mseg-bukrs NE '8360'.

* If GR from Order, do not check DN
      IF sy-tcode = 'COR6' OR
         sy-tcode = 'COR6N' OR
         sy-tcode = 'CORZ' OR
         sy-tcode = 'CORR' OR
         sy-tcode = 'CORK' OR
         sy-tcode = 'COGI' OR
         sy-tcode = 'IW8W' OR
         sy-tcode = 'MBST'.
        EXIT.
      ELSE.
        IF pa_i_mkpf-xblnr = ''.
          MESSAGE e002(zz) WITH 'Please enter Delivery note'.
        ENDIF.
      ENDIF.

* Remove by MKO on 05-01-05
* Because now, interface also cek DN number
** Check apakah plant live ?
*      Select single werks into werks from ZPLBC
*      where werks eq pa_I_MSEG-WERKS and live eq 'X'.
** Jika ya, cek delivery,
** Jika tidak jgn cek, krn bisa sebabkan interface error
*      If SY-SUBRC = 0.

* Cek panjang delivery note input
      pc = strlen( pa_i_mkpf-xblnr ).

* Baca order type PO
      SELECT SINGLE bsart reswk INTO (v_bsart, d_reswk) FROM ekko
      WHERE ebeln = pa_i_mseg-ebeln.

      IF v_bsart = 'ZNB'.
        SELECT SINGLE vbak~bstnk INTO v_bstnk FROM vbak INNER JOIN vbfa ON
           vbak~vbeln = vbfa~vbelv
           WHERE vbfa~vbeln = pa_i_mkpf-xblnr.
        IF v_bstnk <> pa_i_mseg-ebeln OR pc <> '10'.
          MESSAGE e002(zz) WITH 'No delivery yang dimasukkan salah'.
        ELSE.
* Cek good issue status in delivery
          SELECT SINGLE wbstk FROM vbuk INTO v_wbstk
          WHERE vbeln = pa_i_mkpf-xblnr.
* Jika belum good issue
          IF v_wbstk <> 'C'.
            MESSAGE e865(m7) WITH pa_i_mkpf-xblnr '3'.
          ENDIF.
          SELECT vbfa~rfmng vbfa~vbeln
          FROM vbfa INNER JOIN lips ON
               vbfa~vbelv = lips~vbeln AND
               vbfa~posnv = lips~posnr
           INTO (v_rfmng , v_vbeln)
          WHERE vbfa~vbelv = pa_i_mkpf-xblnr AND
                vbfa~matnr = pa_i_mseg-matnr AND
                vbfa~bwart = '901' AND
                vbfa~vbtyp_n = 'R' AND
                lips~charg = pa_i_mseg-charg.
            IF v_vbeln > o_vbeln.
              o_rfmng = v_rfmng.
              o_vbeln = v_vbeln.
            ENDIF.
            CLEAR v_rfmng.
            CLEAR v_vbeln.
          ENDSELECT.

          IF pa_i_mseg-menge > o_rfmng.
            MESSAGE e002(zz) WITH 'GR qty tidak boleh lebih dari delivery qty'.
          ENDIF.
        ENDIF.
* Skip check for Tempo Research and one step STO
      ELSEIF v_bsart = 'ZB' AND pa_i_mseg-werks <> '1400' AND pa_i_mkpf-vgart <> 'WL'.
        CLEAR l_live.
        SELECT SINGLE uml1s FROM t161w INTO l_live
        WHERE reswk = d_reswk AND
              werks = pa_i_mseg-werks AND
              bstyp = 'F' AND
              bsart = v_bsart.

*        SELECT SINGLE ebeln FROM ekbe INTO v_ebeln
*        WHERE belnr = pa_i_mkpf-xblnr.
        SELECT SINGLE vgbel
          FROM lips INTO v_ebeln
        WHERE vbeln = pa_i_mkpf-xblnr
          AND vgbel = pa_i_mseg-ebeln.

        IF v_ebeln <> pa_i_mseg-ebeln OR pc <> '10'.
          MESSAGE e002(zz) WITH 'No delivery yang dimasukkan salah'.
        ELSE.
* l_live = 'X' -> One Step STO
          IF l_live = ''.
* Cek good issue status in delivery
            SELECT SINGLE wbstk FROM vbuk INTO v_wbstk
            WHERE vbeln = pa_i_mkpf-xblnr.
* Jika belum good issue
            IF v_wbstk <> 'C'.
              MESSAGE e865(m7) WITH pa_i_mkpf-xblnr '3'.
            ENDIF.
          ENDIF.
*          Select VBFA~RFMNG VBFA~VBELN
*          from VBFA inner join LIPS on
*               VBFA~VBELV = LIPS~VBELN and
*               VBFA~POSNV = LIPS~POSNR
*           into (V_RFMNG , V_VBELN)
*          where VBFA~VBELV = pa_I_MKPF-XBLNR and
*                VBFA~MATNR = pa_I_MSEG-MATNR and
*                VBFA~BWART = '907' and
*                VBFA~VBTYP_N = 'R' and
*                LIPS~CHARG = pa_I_MSEG-CHARG.
*            If V_VBELN > O_VBELN.
*              O_RFMNG = V_RFMNG.
*              O_VBELN = V_VBELN.
*            Endif.
*            Clear V_RFMNG.
*            Clear V_VBELN.
*          Endselect.

* Remove by MKO on 11-01-03
* because this can make error if item number in GR different with GI
*          Select RFMNG VBELN from VBFA into (V_RFMNG , V_VBELN)
*          where VBELV = pa_I_MKPF-XBLNR and MATNR = pa_I_MSEG-MATNR and
*                POSNN = pa_I_MSEG-ZEILE and BWART = '907'.
*            If V_VBELN > O_VBELN.
*              O_RFMNG = V_RFMNG.
*              O_VBELN = V_VBELN.
*            Endif.
*            Clear V_RFMNG.
*            Clear V_VBELN.
*          Endselect.

*          If pa_I_MSEG-MENGE > O_RFMNG.
*     MESSAGE E002(zz) with 'GR qty tidak boleh lebih dari delivery qty'
*.
*          Endif.
        ENDIF.
      ELSEIF v_bsart = 'UB'.
        IF pc <> '10'.
          MESSAGE e002(zz) WITH 'No delivery yang dimasukkan salah'.
        ELSE.
* Check PO number and item number in GR must relevant with DN number
          SELECT SINGLE belnr FROM ekbe INTO v_vbeln
          WHERE ebeln = pa_i_mseg-ebeln AND
                ebelp = pa_i_mseg-ebelp AND
                zekkn = '00'            AND
                vgabe = '8'             AND
                gjahr = ''              AND
                belnr = pa_i_mkpf-xblnr.
          IF sy-subrc <> 0.
            SELECT SINGLE lfart INTO d_lfart
            FROM t161v
            WHERE bstyp = 'F'     AND
                  bsart = v_bsart AND
                  reswk = d_reswk.
            IF d_lfart <> ''.
              MESSAGE e002(zz) WITH 'No delivery yang dimasukkan salah'.
            ENDIF.
          ENDIF.
        ENDIF.

* additional to check consignment stock for consignment material
      ELSEIF v_bsart = 'NB'.
        CLEAR : d_sobsl, d_slabs.

        SELECT SINGLE sobsl FROM marc INTO d_sobsl
        WHERE matnr = pa_i_mseg-matnr AND
              werks = pa_i_mseg-werks.
        IF d_sobsl = '10'.
*--------------------------------------------------*
* Item table of material document
*--------------------------------------------------*
* add 6 Jan 2012 for Polari
          SELECT SINGLE extwg FROM mara INTO d_extwg
          WHERE matnr = pa_i_mseg-matnr.

          CASE d_extwg.
            WHEN 'RCH'.
              d_lgort = 'S000'.
            WHEN 'TNS'.
              d_lgort = 'S001'.
          ENDCASE.

          AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
              ID 'ACTVT' FIELD '01'
              ID 'BWART' FIELD '955'
              ID 'LGORT' FIELD d_lgort.
          IF sy-subrc NE 0.
            MESSAGE e002(zz) WITH 'You are not authorized with Mvt Type'
            pa_i_mseg-bwart 'Sloc' d_lgort.
          ENDIF.
* end add -----------------------------------------*
          SELECT SINGLE slabs FROM mkol INTO d_slabs
          WHERE matnr = pa_i_mseg-matnr AND
                werks = pa_i_mseg-werks AND
                lgort = d_lgort AND
                charg = pa_i_mseg-charg.
          IF pa_i_mseg-menge > d_slabs.
            MESSAGE e002(zz) WITH
            'Not enough cons stock for mat' pa_i_mseg-matnr
            'batch' pa_i_mseg-charg.
          ENDIF.
        ENDIF.
      ENDIF.

*      Endif.

      wa_mseg  = pa_i_mseg.
      PERFORM f_validate_gudang2 USING wa_mseg
                                 CHANGING ld_error.
      IF ld_error NE 0.
        MESSAGE e000(zab) WITH 'You are not authorized in this SLoc'.
      ENDIF.

    WHEN '102'.
      CHECK pa_i_mseg-bukrs NE '8050' AND
            pa_i_mseg-bukrs NE '8230'.

      wa_mseg  = pa_i_mseg.
      PERFORM f_validate_gudang2 USING wa_mseg
                                 CHANGING ld_error.
      IF ld_error NE 0.
        MESSAGE e000(zab) WITH 'You are not authorized in this SLoc'.
      ENDIF.

* Penambahan exit untuk Automation Intercompany
      CLEAR d_ordtyp.
      SELECT SINGLE bsart
        FROM ekko
        INTO d_ordtyp
        WHERE ebeln = pa_i_mseg-ebeln.
      IF d_ordtyp EQ 'ZICO'.
        MESSAGE w002(zz) WITH 'DN / GI for PO no' pa_i_mseg-ebeln
       'must be cancelled first'.
      ENDIF.

      CLEAR lv_vkorg.
      SELECT SINGLE vkorg
        FROM t001l
        INTO lv_vkorg
        WHERE werks EQ pa_i_mseg-werks
          AND lgort EQ pa_i_mseg-lgort.

      CLEAR lv_mtpos.
      SELECT SINGLE mtpos
        FROM mvke
        INTO lv_mtpos
        WHERE matnr EQ pa_i_mseg-matnr
          AND vkorg EQ lv_vkorg.
      IF lv_mtpos EQ 'ZNOR'.
        MESSAGE w002(zz) WITH 'DN / GI for PO no' pa_i_mseg-ebeln
       'must be cancelled first'.
      ENDIF.
*--

* Checking PO retur value, must less than stock value to avoid MAP = 0.
* Update on 24 Okt 03 by MKO
    WHEN '161'.
      DATA : d_value LIKE mbew-salk3,
             d_qty   LIKE mbew-lbkum.

      IF sy-tcode = 'SE38' OR sy-tcode(1) = 'Z'.
      ELSE.
        SELECT SINGLE bsart FROM ekko INTO d_ordtyp
        WHERE ebeln = pa_i_mseg-ebeln.
        IF d_ordtyp(1) <> 'R' AND
          ( pa_i_mseg-werks(2) = '02' OR
            pa_i_mseg-werks(2) = '07' ).
          SELECT SINGLE salk3 lbkum FROM mbew INTO (d_value, d_qty)
          WHERE matnr = pa_i_mseg-matnr AND bwkey = pa_i_mseg-werks.
          d_value = d_value / d_qty.
          SELECT SINGLE netpr peinh FROM ekpo INTO (pa_i_mseg-dmbtr ,
    pa_i_mseg-menge)
          WHERE ebeln = pa_i_mseg-ebeln AND
                ebelp = pa_i_mseg-ebelp.
          pa_i_mseg-dmbtr = pa_i_mseg-dmbtr / pa_i_mseg-menge.
*      If pa_I_MSEG-DMBTR > D_VALUE.
* Revise by MKO to give tolerance 1%
          pa_i_mseg-dmbtr = ( pa_i_mseg-dmbtr - d_value ) * 100.
          IF pa_i_mseg-dmbtr > 1.
            MESSAGE e002(zz) WITH
           'PO ret value over from stock val, pls upd PO value'.
          ENDIF.
        ENDIF.
      ENDIF.

*    WHEN '920' OR '922' OR '926'.
      DATA : barea LIKE mseg-gsber.
*      SELECT SINGLE gsber FROM t134g INTO barea
*      WHERE werks = pa_i_mseg-werks
*      AND spart = '00'.
*      IF pa_i_mseg-pargb <> barea.
*        MESSAGE e002(zz) WITH 'Business Area salah !!! Kosongkan field BA'.
*      ENDIF.

* Checking listing material taskforce for Canvass
* Update on 8 Sep 03 by MKO
    WHEN '311' OR '312'.
***** 13/10/2006--> DEVK921455
***** Tambahan validasi untuk by pass check task force
      CLEAR: l_live.
      SELECT SINGLE live INTO l_live FROM zplbc WHERE
             werks = pa_i_mseg-werks AND
             lgort = '1000'.
      IF l_live <> 'X'.
        EXIT.
      ENDIF.
******* Ending Tambahan validasi untuk by pass check task force
****

** Validasi untuk transaksi JDE
*      IF pa_i_mseg-bukrs EQ '8050' AND
*        pa_i_mseg-werks EQ '0501'.
*        CASE pa_i_mseg-lgort.
*          WHEN '1110'.
*            IF pa_i_mseg-umlgo NE '111E'.
*              MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
*            ENDIF.
*          WHEN '111E'.
*            IF pa_i_mseg-umlgo NE '1110'.
*              MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
*            ENDIF.
*          WHEN '1120'.
*            IF pa_i_mseg-umlgo NE '112E'.
*              MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
*            ENDIF.
*          WHEN '112E'.
*            IF pa_i_mseg-umlgo NE '1120'.
*              MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
*            ENDIF.
*        ENDCASE.
*      ENDIF.
******

* Validation for task force item

*     PA_I_MSEG-werks.
      IF pa_i_mseg-umlgo+2(1) = 'C'.
***        SELECT SINGLE lzone INTO t_lzone
***        FROM zslockanvas
***        WHERE vstel = pa_i_mseg-werks AND
***              lgort = pa_i_mseg-umlgo.
***
***        IF t_lzone+2(1) = 'R'.
***          SELECT SINGLE matkl INTO t_matkl
***          FROM mara
***          WHERE matnr = pa_i_mseg-matnr.
***          IF t_matkl(3) <> 'BCL' AND t_matkl(5) <> 'SFFCH' AND
***             t_matkl(5) <> 'TSPCH' AND t_matkl(5) <> 'TNPCH'.
***            IF pa_i_mseg-matnr EQ '003-08-00'.
***
***            ELSE.
***              MESSAGE e002(zz) WITH pa_i_mseg-matnr
***                   ' bukan material TRM'.
***            ENDIF.
***          ENDIF.
***        ELSE.
***** Permintaan IRG  (Validasi transfer posting kanvas PTT )
***** Tgl 06-10-2016  ( Ganti seelct ke table kotg504 sebelumnya ke table kotg530 )
***          SELECT SINGLE matnr FROM kotg530 INTO matnum
***          WHERE kappl = 'V'             AND
***                kschl = 'A001'          AND
***                vkbur = pa_i_mseg-werks AND
***                kdgrp = '01'            AND
***                matnr = pa_i_mseg-matnr AND
***                datbi >= sy-datum       AND
***                datab <= sy-datum.
***          IF sy-subrc <> 0.
***            MESSAGE e002(zz) WITH pa_i_mseg-matnr
***                 ' bukan material task force cabang '
***                 pa_i_mseg-werks.
***          ENDIF.
**
**        DATA: lv_sort2 TYPE ad_sort2.
**
**        SELECT SINGLE sort2 INTO lv_sort2
**          FROM twlad AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
**          WHERE a~werks = pa_i_mseg-werks
**            AND a~lgort = pa_i_mseg-umlgo
**            AND b~sort2 = 'BVG'.
**        IF sy-subrc = 0.
**          SELECT SINGLE matnr FROM kotg504 INTO matnum
**            WHERE kappl = 'V'
**              AND kschl = 'A001'
**              AND auart = 'ZOT3'
**              AND kdgrp = '04'
**              AND kvgr3 = '04A'
**              AND vkbur = pa_i_mseg-werks
**              AND matnr = pa_i_mseg-matnr
**              AND datbi >= sy-datum
**              AND datab <= sy-datum.
**          IF sy-subrc <> 0.
**            MESSAGE e002(zz) WITH pa_i_mseg-matnr
**                  ' bukan material task force cabang '
**                  pa_i_mseg-werks.
**          ENDIF.
**        ELSE.
**          SELECT SINGLE matnr FROM kotg504 INTO matnum
**            WHERE kappl = 'V'
**              AND kschl = 'A001'
**              AND auart = 'ZOT3'
**              AND kdgrp = '04'
**              AND kvgr3 = 'KTN'
**              AND vkbur = pa_i_mseg-werks
**              AND matnr = pa_i_mseg-matnr
**              AND datbi >= sy-datum
**              AND datab <= sy-datum.
**          IF sy-subrc <> 0.
**            MESSAGE e002(zz) WITH pa_i_mseg-matnr
**                  ' bukan material task force cabang '
**                  pa_i_mseg-werks.
**          ENDIF.
**        ENDIF.
**** End Permintaan IRG  (Validasi transfer posting kanvas PTT )
      ENDIF.

* Checking material doc intransit for Stock Point
      IF pa_i_mseg-umlgo(1) = '2' AND pa_i_mseg-werks(2) = '02'.
        IF pa_i_mseg-smbln NE space.
          SELECT SINGLE status INTO d_status FROM zst_point
          WHERE  werks = pa_i_mseg-werks AND
                 lgort = pa_i_mseg-lgort AND
                 mjahr = pa_i_mseg-sjahr AND
                 mblnr = pa_i_mseg-smbln.
          SELECT SINGLE mtart FROM mara INTO mtype
          WHERE matnr = pa_i_mseg-matnr.
          IF d_status NE space.
            MESSAGE e002(zz) WITH 'Mat doc. ' pa_i_mseg-mblnr
            'sudah di download jadi intransit'.
          ENDIF.
        ELSEIF pa_i_mseg-umcha <> '00' AND
              ( mtype = 'ZPHA' OR mtype = 'ZCGB' ).
          MESSAGE e002(zz) WITH 'Receiving Batch utk stock point harus 00'.
        ENDIF.
      ELSE.
        IF pa_i_mseg-charg <> pa_i_mseg-umcha.
          MESSAGE e002(zz) WITH 'Receiving Batch harus sama dengan Issuing'.
        ENDIF.
      ENDIF.

* Validation for new warehouse in Bandung
      IF pa_i_mseg-umlgo+1(1) = '1' AND pa_i_mseg-werks = '0210'.
        SELECT SINGLE matkl FROM mara INTO mgroup
        WHERE matnr = pa_i_mseg-matnr.
        IF mgroup(6) = 'BCLCLA' OR
           mgroup(6) = 'PRTSOS' OR
           mgroup(6) = 'BCLMRN'.
        ELSE.
          MESSAGE e002(zz) WITH 'Gudang' pa_i_mseg-umlgo
          'hanya untuk consumer Marina, SOS & Claudia'.
        ENDIF.
      ENDIF.


* update by/date: IE/4 Sep 2002
* add checking for mvt '304'
    WHEN '304'.
      DATA : t_sgtxt LIKE mseg-sgtxt,
             t_live  LIKE zplbc-live.

      CLEAR : t_sgtxt, t_mblnr, t_live.
      GET PARAMETER ID 'MBN' FIELD mdoc.
      GET PARAMETER ID 'MJA' FIELD year.

      IF year = ''.
        SELECT SINGLE mjahr INTO year FROM mkpf
        WHERE mblnr = mdoc.
      ENDIF.

      CONCATENATE mdoc '/' year INTO t_sgtxt.
      SELECT SINGLE mblnr FROM mseg INTO t_mblnr
      WHERE matnr = pa_i_mseg-matnr
      AND sgtxt = t_sgtxt AND bwart = '305'.

      IF sy-subrc = 0.
        MESSAGE e003(zz) WITH 'Material sudah di-receive dengan Mat. doc : '
           t_mblnr.
      ENDIF.

* Add check to ZPOITTC to avoid cancel doc, if doc already downloaded
* to legacy intransit
      SELECT SINGLE live FROM zplbc INTO t_live
      WHERE ( bukrs = '8020' OR bukrs EQ '8070' ) AND
            werks = pa_i_mseg-umwrk AND
            lgort = '1000'.

      IF sy-subrc = '0' AND t_live = '' AND pa_i_mseg-smbln NE space.
        SELECT SINGLE compl INTO t_live FROM zpoittc
        WHERE  werks = pa_i_mseg-werks AND
               lgort = pa_i_mseg-lgort AND
               vtart = 'IV'            AND
               mjahr = pa_i_mseg-sjahr AND
               xblnr = pa_i_mseg-smbln AND
               posnr = pa_i_mseg-smblp.
        IF sy-subrc = 0.
          MESSAGE e002(zz) WITH 'Mat doc. ' pa_i_mseg-mblnr
          'sudah jadi intransit legacy,contact TDS utk cancel'.
        ENDIF.
      ENDIF.

    WHEN '305' OR '315'.
*      CHECK pa_i_mseg-bukrs NE '8050' AND
*            pa_i_mseg-bukrs NE '8230'.

      CLEAR : pa_e_sgtxt, t_mblnr, t_umlgo.
      GET PARAMETER ID 'MBN' FIELD mdoc.
      GET PARAMETER ID 'MJA' FIELD year.
      IF year = ''.
        SELECT SINGLE mjahr INTO year FROM mkpf
        WHERE mblnr = mdoc.
      ENDIF.

* Cek apakah reference mvt type 303 ?
      IF sy-tcode = 'MBSU'.
        pa_i_mseg-zeile = 1 + ( pa_i_mseg-zeile - 1 ) * 2.
      ELSE.
        pa_i_mseg-zeile = 1 + ( pa_i_mseg-line_id - 1 ) * 2.
      ENDIF.
      SELECT SINGLE bwart matnr  menge INTO
*      (pa_i_mseg-bwart , t_matnr , t_menge)
      (lv_bwart , t_matnr , t_menge)
      FROM mseg
      WHERE mjahr = year AND mblnr = mdoc AND zeile = pa_i_mseg-zeile.
      IF ( lv_bwart <> '303' AND lv_bwart <> '313' ) OR t_matnr <> pa_i_mseg-matnr.
        MESSAGE i015(zz).
        LEAVE PROGRAM.
      ELSEIF t_menge <> pa_i_mseg-menge.
        MESSAGE e002(zz) WITH 'Quantity yang dimasukkan salah'.
      ENDIF.

* Cek apakah 303 udah di cancel, update on 22/08/2003
      SELECT SINGLE mblnr INTO t_mblnr FROM mseg
      WHERE sjahr = year AND smbln = mdoc.
      IF sy-subrc = 0.
        MESSAGE e003(zz) WITH 'Material Doc. sudah di-cancel dengan Mat. doc : '
              t_mblnr.
      ENDIF.

      CONCATENATE mdoc '/' year INTO pa_e_sgtxt.
      IF pa_i_mseg-bwart EQ '305'.
        SELECT SINGLE mblnr FROM mseg INTO t_mblnr
        WHERE matnr = pa_i_mseg-matnr
        AND werks = pa_i_mseg-werks
        AND sgtxt = pa_e_sgtxt AND bwart = '305'.
        IF sy-subrc = 0.
          MESSAGE e003(zz) WITH 'Material sudah di-receive dengan Mat. doc : '
             t_mblnr.
        ENDIF.
      ELSEIF pa_i_mseg-bwart EQ '315'.
        SELECT mblnr mjahr zeile
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE lt_mseg1
          WHERE matnr = pa_i_mseg-matnr
            AND werks = pa_i_mseg-werks
            AND charg = pa_i_mseg-charg
            AND sgtxt = pa_e_sgtxt
            AND bwart = '315'.

        IF lt_mseg1[] IS NOT INITIAL.
          SELECT mblnr mjahr zeile smbln
            FROM mseg
            INTO CORRESPONDING FIELDS OF TABLE lt_mseg2
            FOR ALL ENTRIES IN lt_mseg1
            WHERE smbln = lt_mseg1-mblnr.

          LOOP AT lt_mseg1 INTO ls_mseg1.
            READ TABLE lt_mseg2 INTO ls_mseg2
                                WITH KEY smbln = ls_mseg1-mblnr.
            IF sy-subrc <> 0.
              MESSAGE e003(zz) WITH 'Material sudah di-receive dengan Mat. doc : '
                 ls_mseg1-mblnr.
            ENDIF.
          ENDLOOP.
        ENDIF.
******        SELECT SINGLE mblnr FROM mseg INTO t_mblnr
******        WHERE matnr = pa_i_mseg-matnr
******        AND werks = pa_i_mseg-werks
******        AND sgtxt = pa_e_sgtxt AND bwart = '315'.
******        IF sy-subrc = 0.
******            MESSAGE e003(zz) WITH 'Material sudah di-receive dengan Mat. doc : '
******               t_mblnr.
******          ENDIF.
******        ENDIF.
      ENDIF.

      IF pa_i_mseg-werks = '0200' OR
        pa_i_mseg-werks = '0700'.
        SELECT SINGLE umlgo FROM mseg INTO t_umlgo
        WHERE mblnr = mdoc AND
              mjahr = year AND
              zeile = '1'.
        AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
            ID 'WERKS' FIELD pa_i_mseg-werks
            ID 'LGORT' FIELD t_umlgo
            ID 'BWART' FIELD pa_i_mseg-bwart.
        IF sy-subrc <> 0.
          MESSAGE e003(zz) WITH 'You are not authorized with sloc '
                t_umlgo.
        ENDIF.
      ENDIF.
*New Receiving Sloc Validation 26/10/2022 JR: RF/TDS/22/98
      IF t_umlgo IS NOT INITIAL AND t_umlgo NE pa_i_mseg-lgort.
        MESSAGE e000(zab) WITH 'Error Different SLoc Receiving'.
      ENDIF.

* Validasi Storage Location
      DATA : lv_lgort  TYPE lgort_d.
      CLEAR lv_lgort.
      SELECT SINGLE lgort
        FROM mseg
        INTO lv_lgort
        WHERE mblnr EQ mdoc
          AND mjahr EQ year
          AND bwart EQ pa_i_mseg-bwart
          AND xauto EQ 'X'.
      IF sy-subrc EQ 0.
        IF pa_i_mseg-bukrs EQ '8020' OR
          pa_i_mseg-bukrs EQ '8070'.
          IF lv_lgort EQ '1100' OR
            lv_lgort EQ '1005'.
            IF lv_lgort NE pa_i_mseg-lgort.
              MESSAGE e000(zab) WITH 'Error different SLoc'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*add by MKO to clear text for cancelation doc for 305 on 26/06/03
    WHEN '306' OR '316'.
*      CHECK pa_i_mseg-bukrs NE '8050' AND
*            pa_i_mseg-bukrs NE '8230'.

      CLEAR pa_e_sgtxt.

* Add routine to check authorization for vendor in provide to vendor
    WHEN '541' OR '542'.
      DATA : d_begru LIKE lfa1-begru.
      SELECT SINGLE begru FROM lfa1 INTO d_begru
      WHERE lifnr = pa_i_mseg-lifnr.
      AUTHORITY-CHECK OBJECT 'F_LFA1_BEK'
      ID 'BRGRU' FIELD d_begru.
      IF sy-subrc NE 0.
        MESSAGE e002(zz) WITH 'You are not authorized with Vendor'
         pa_i_mseg-lifnr.
      ENDIF.

* Routine for check 542
      IF pa_i_mseg-bwart = '542' AND pa_i_mseg-smbln = '' AND
         pa_i_mseg-werks(2) = '02' .
        IF pa_i_mseg-sgtxt = ''.
          MESSAGE e002(zz) WITH 'Please enter reference doc. in item text'.
        ELSE.
          SELECT SINGLE bwart werks zeile lgort FROM mseg
          INTO (bwart , werks , zeile , t_umlgo)
          WHERE mblnr = pa_i_mseg-sgtxt(10)   AND
                mjahr = pa_i_mseg-sgtxt+11(4) AND
                matnr = pa_i_mseg-matnr       AND
                lgort NE space.
          IF bwart <> '541' OR werks <> pa_i_mseg-werks OR
             sy-subrc <> 0 OR t_umlgo <> pa_i_mseg-lgort.
            MESSAGE e002(zz) WITH 'Wrong reference doc. in item text'.
          ELSE.
            SELECT SINGLE mblnr FROM mseg
            INTO t_mblnr
            WHERE smbln = pa_i_mseg-sgtxt(10)   AND
                  sjahr = pa_i_mseg-sgtxt+11(4) AND
                  smblp = zeile.
            IF sy-subrc = 0.
              MESSAGE e002(zz) WITH 'Reference doc. already canceled'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* Validation to avoid cancel GI in different period
    WHEN '602' OR '654' OR '656' OR '902' OR '908' OR '929'.
      DATA : d_budat   LIKE mkpf-budat.
      DATA : r_xblnr   TYPE RANGE OF mkpf-xblnr WITH HEADER LINE.

      IF sy-tcode = 'VL09'.
        IF pa_i_mseg-bukrs EQ '8020' OR
           pa_i_mseg-bukrs EQ '8070' OR
           pa_i_mseg-bukrs EQ '8220'.
          SELECT SINGLE budat FROM mkpf INTO d_budat
          WHERE mblnr = pa_i_mseg-smbln AND
                mjahr = pa_i_mseg-sjahr.

          SELECT sign AS sign
                 opti AS option
                 low AS low
                 high AS high
            FROM tvarvc
            INTO TABLE r_xblnr
            WHERE name EQ 'ZMCANCEL_GI'.

          IF pa_i_mkpf-xblnr IN r_xblnr.
          ELSE.
            IF pa_i_mkpf-budat(6) > d_budat(6).
              MESSAGE e002(zz) WITH
     'Can not canc in diff. month, pls change rev date'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '905'.
      IF pa_i_mseg-sobkz NE 'W'.
* Check apakah plant live ?
        SELECT SINGLE werks INTO werks FROM zplbc
        WHERE werks EQ pa_i_mseg-werks AND live EQ 'X'.
* Jika ya, cek
* Jika tidak jgn cek, krn bisa sebabkan interface error
        IF sy-subrc = 0.
          SELECT SINGLE *
            FROM zmmt0002
            WHERE werks = pa_i_mseg-werks
              AND xblnr = pa_i_mkpf-xblnr.
          IF sy-subrc NE 0.
            CLEAR : barea, t_xblnr.
            SELECT SINGLE gsber FROM t134g INTO barea
            WHERE werks = pa_i_mseg-werks
            AND spart = '00'.
            IF pa_i_mseg-pargb <> barea.
              MESSAGE e002(zz) WITH 'Business Area salah !!! Kosongkan field BA'.
            ENDIF.
            IF pa_i_mkpf-bktxt = '' AND pa_i_mseg-smbln = ''.
              MESSAGE e002(zz) WITH 'Please enter reference Memo number'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '906'.
      IF pa_i_mseg-sobkz NE 'W'.
* Check apakah plant live ?
        SELECT SINGLE werks INTO werks FROM zplbc
        WHERE werks EQ pa_i_mseg-werks AND live EQ 'X'.
* Jika ya, cek
* Jika tidak jgn cek, krn bisa sebabkan interface error
        IF sy-subrc = 0.
          SELECT SINGLE *
            FROM zmmt0002
            WHERE werks = pa_i_mseg-werks
              AND xblnr = pa_i_mkpf-xblnr.
          IF sy-subrc NE 0.
            CLEAR : barea, t_mblnr, bwart.
            IF pa_i_mseg-smbln <> ''.
              IF pa_i_mkpf-xblnr <> ''.
                MESSAGE e002(zz) WITH 'Mat. Doc. already have subsequent doc.'.
              ENDIF.
            ELSE.
              SELECT SINGLE gsber FROM t134g INTO barea
              WHERE werks = pa_i_mseg-werks
              AND spart = '00'.

              IF pa_i_mseg-pargb <> barea.
                MESSAGE e002(zz) WITH 'Business Area salah !!! Kosongkan field BA'.
              ENDIF.

              IF pa_i_mkpf-xblnr = ''.
                MESSAGE e002(zz) WITH 'Please enter reference document'.
              ELSE.

                SELECT SINGLE bwart werks smbln FROM mseg
                INTO (bwart , werks , t_mblnr)
                WHERE mblnr = pa_i_mkpf-xblnr(10)   AND
                      mjahr = pa_i_mkpf-xblnr+11(4) AND
                      zeile = '1'.

* Cek movement type reference document apakah 905
                IF bwart <> '905'.
                  MESSAGE e002(zz) WITH 'Wrong reference document'.
                ENDIF.
* Cek plant harus sama
                IF werks <> pa_i_mseg-werks.
                  MESSAGE e002(zz) WITH
                  'You are not authorized for this reference doc'.
                ENDIF.

* Cek apakah reference document adalah document cancel
                IF t_mblnr <> ''.
                  MESSAGE e003(zz) WITH 'Ref. Doc. is a cancelled doc'.
                ENDIF.

* Cek reference document apakah sudah completed
                SELECT SINGLE xblnr FROM mkpf INTO t_xblnr
                WHERE mblnr = pa_i_mkpf-xblnr(10) AND
                      mjahr = pa_i_mkpf-xblnr+11(4).
                IF t_xblnr <> ''.
                  MESSAGE e002(zz) WITH
                  'Reference document already completed using' t_xblnr.
                ENDIF.

* Cek apakah reference document sudah di cancel
                SELECT SINGLE mblnr INTO t_mblnr FROM mseg
                WHERE sjahr = pa_i_mkpf-xblnr+11(4) AND
                      smbln = pa_i_mkpf-xblnr(10).
                IF sy-subrc = 0.
                  MESSAGE e003(zz) WITH 'Ref. Doc. already cancelled with Mat. doc : '
                           t_mblnr.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'Z01'.
      IF pa_i_mkpf-xblnr = ''.
        MESSAGE e002(zz) WITH 'Please enter Reference Document'.
      ENDIF.
      SELECT SINGLE netpr INTO pa_i_mseg-dmbtr
      FROM eine INNER JOIN eina
      ON eine~infnr = eina~infnr
      WHERE lifnr = pa_i_mseg-lifnr AND
            matnr = pa_i_mseg-matnr AND
            ekorg = 'TNT' AND
            esokz = '2'.
      IF pa_i_mseg-dmbtr <> 0.
        MESSAGE e002(zz) WITH
        'Consignment inforecord price not zero, pls check'.
      ENDIF.

    WHEN 'Z03'.
      IF pa_i_mkpf-xblnr = ''.
        MESSAGE e002(zz) WITH 'Enter Ref Doc In The Material Slip'.
      ENDIF.

* Routine for check 451
    WHEN '451'.
      IF pa_i_mseg-werks(2) EQ '02'.
        EXIT.
      ELSE.
        IF pa_i_mseg-smbln = ''.
          IF pa_i_mkpf-xblnr = ''.
            MESSAGE e002(zz) WITH
            'Please enter reference doc. in material slip'.
          ELSE.
            SELECT SINGLE bwart werks zeile lgort FROM mseg
            INTO (bwart , werks , zeile , t_umlgo)
            WHERE mblnr = pa_i_mkpf-xblnr(10)   AND
                  mjahr = pa_i_mkpf-xblnr+11(4) AND
                  matnr = pa_i_mseg-matnr       AND
                  lgort NE space.
            IF bwart <> '541' OR sy-subrc <> 0.
              MESSAGE e002(zz) WITH 'Wrong reference doc. in item text'.
            ELSE.
              SELECT SINGLE mblnr FROM mseg
              INTO t_mblnr
              WHERE smbln = pa_i_mkpf-xblnr   AND
                    sjahr = pa_i_mkpf-xblnr+11(4) AND
                    smblp = zeile.
              IF sy-subrc = 0.
                MESSAGE e002(zz) WITH 'Reference doc. already canceled'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* Routine for check 452
*    WHEN '452'.
*      IF pa_i_mseg-werks(2) NE '02'.
*        EXIT.
*      ELSE.
*        SELECT SINGLE kunnr FROM mseg
*          INTO t_kunnr
*          WHERE mblnr = pa_i_mseg-mblnr  AND
*                mjahr = pa_i_mseg-mjahr  AND
*                zeile = pa_i_mseg-zeile  AND
*                bwart = '451'.
*        IF t_kunnr NE pa_i_mseg-kunnr.
*          MESSAGE e002(zz) WITH 'Cannot change Customer Number'.
*        ENDIF.
*      ENDIF.

    WHEN '452'.
*      PERFORM f_check_452 USING pa_i_mkpf-xblnr pa_i_mseg-charg pa_i_mseg-kunnr
*                                pa_i_mseg-matnr pa_i_mseg-werks pa_i_mseg-menge.

    WHEN '969' OR '970'.
      DATA : lv_bktxt TYPE bktxt,
             lv_datum TYPE bktxt,
             lv_live  TYPE zplbc-live.

      CLEAR lv_live.
      SELECT SINGLE live INTO lv_live FROM zplbc
        WHERE bukrs EQ pa_i_mseg-bukrs
          AND werks EQ pa_i_mseg-werks
          AND lgort EQ pa_i_mseg-lgort.

      " Untuk interface legacy tidak divalidasi
      IF sy-subrc = 0 AND lv_live IS INITIAL.
      ELSE.
        PERFORM f_new_bktxt_val USING pa_i_mkpf-bktxt.

*        IF pa_i_mkpf-bktxt IS INITIAL.
*          MESSAGE e000(zab) WITH 'Format Dok.Header Text No.Reff/DD.MM.YYYY'.
*        ELSE.
*          pc  = STRLEN( pa_i_mkpf-bktxt ).
*          IF pc < 12.
*            MESSAGE e000(zab) WITH 'Format Dok.Header Text No.Reff/DD.MM.YYYY'.
*          ELSE.
*            SPLIT pa_i_mkpf-bktxt AT '/' INTO lv_bktxt lv_datum.
*            IF sy-subrc = 0.
*              IF lv_datum+2(1) <> '.' OR
*               lv_datum+5(1) <> '.'.
*                MESSAGE e000(zab) WITH 'Format Dok.Header Text No.Reff/DD.MM.YYYY'.
*              ENDIF.
*            ENDIF.
**            sepa1  = pc - 11.
**            sepa2  = pc - 8.
**            sepa3  = pc - 5.
**            IF pa_i_mkpf-bktxt+sepa1(1) <> '/' OR
**              pa_i_mkpf-bktxt+sepa2(1) <> '.' OR
**              pa_i_mkpf-bktxt+sepa3(1) <> '.'.
**            ENDIF.
*          ENDIF.
*      ENDIF.

        SELECT SINGLE *
          FROM eina
          INTO lwa_eina
          WHERE lifnr = pa_i_mseg-lifnr
            AND matnr = pa_i_mseg-matnr.
        IF sy-subrc <> 0.
          MESSAGE e000(zab) WITH 'Vendor & Material does not match'.
        ENDIF.
      ENDIF.

    WHEN '555' OR '349'.
      IF pa_i_mseg-bukrs EQ '8020' OR
        pa_i_mseg-bukrs EQ '8070'.
        IF pa_i_mkpf-bktxt IS INITIAL.
          MESSAGE e000(zab) WITH 'Dok.Header Text harus diisi sesuai surat BUM'.
        ENDIF.
      ENDIF.

      IF pa_i_mseg-bwart EQ '349'.
        IF pa_i_mseg-bukrs EQ '8020' AND
          pa_i_mseg-lgort EQ '10U0' AND
          pa_i_mseg-umlgo EQ '10U0'.
          CLEAR l_live.
          SELECT SINGLE live
            FROM zplbc
            INTO l_live
            WHERE bukrs EQ pa_i_mseg-bukrs
              AND werks EQ pa_i_mseg-werks
              AND live  EQ 'X'.
          IF sy-subrc EQ 0.
            MESSAGE e000(zab) WITH 'You cannot use mvt ' pa_i_mseg-bwart ' for Sloc ' pa_i_mseg-lgort.
          ENDIF.
        ENDIF.
      ENDIF.

* Validasi untuk Gudang 2
    WHEN '313' OR '314' OR '315' OR '316'.
      CHECK pa_i_mseg-bukrs NE '8050' AND
            pa_i_mseg-bukrs NE '8230'.

      IF pa_i_mseg-umwrk IS NOT INITIAL.
        IF pa_i_mseg-umwrk NE pa_i_mseg-werks.
          MESSAGE e000(zab) WITH 'You are not authorized cross plant'.
        ENDIF.
      ENDIF.

      wa_mseg  = pa_i_mseg.
      IF pa_i_mseg-bwart EQ '313' OR
        pa_i_mseg-bwart EQ '314'.
        CLEAR: ld_zflag.
        IF pa_i_mseg-lgort EQ '1000'.
          SELECT SINGLE zflag
            FROM zmgudang
            INTO ld_zflag
            WHERE werks EQ wa_mseg-werks AND
                  datab LE sy-datum      AND
                  datbi GE sy-datum      AND
                  zflag EQ 'X'.
        ENDIF.

        IF ld_zflag EQ 'X'.
          MESSAGE e000(zab) WITH 'You are not authorized for SLoc'.
        ELSE.
          PERFORM f_validate_gudang2 USING wa_mseg
                                     CHANGING ld_error.
          IF ld_error NE 0.
            MESSAGE e000(zab) WITH 'You are not authorized in this SLoc'.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM f_validate_gudang2 USING wa_mseg
                                   CHANGING ld_error.
        IF ld_error NE 0.
          MESSAGE e000(zab) WITH 'You are not authorized in this SLoc'.
        ENDIF.
      ENDIF.

    WHEN '351'.
      SELECT ebeln ebelp matnr menge reslo
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
        WHERE ebeln   EQ pa_i_mseg-ebeln
          AND matnr   EQ pa_i_mseg-matnr.

      SELECT ebeln ebelp menge wamng
        FROM eket
        INTO TABLE gt_eket
        WHERE ebeln   EQ pa_i_mseg-ebeln
          AND ebelp   EQ pa_i_mseg-ebelp.

*      SELECT ebeln ebelp matnr menge
*        FROM ekbe
*        INTO TABLE gt_ekbe
*        WHERE ebeln   EQ pa_i_mseg-ebeln
*          AND matnr   EQ pa_i_mseg-matnr
*          AND bewtp   EQ 'U'.

      LOOP AT gt_ekpo.
        READ TABLE gt_eket WITH KEY ebeln = gt_ekpo-ebeln
                                    ebelp = gt_ekpo-ebelp.
        IF sy-subrc EQ 0.
          lv_menge  = gt_eket-menge - gt_eket-wamng.
          IF lv_menge EQ 0.
            MESSAGE e000(zab) WITH 'Data is already issued'.
            EXIT.
          ENDIF.
        ENDIF.

        IF gt_ekpo-reslo EQ '1005'.
          IF gt_ekpo-reslo NE pa_i_mseg-lgort.
            MESSAGE e000(zab) WITH 'Issuing SLoc can not be changed'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN '701' OR '702' OR '703' OR '704' OR '707' OR '708'.
      CASE pa_i_mseg-bukrs.
        WHEN '8020'.
          IF pa_i_mseg-sobkz EQ 'W'.
            MESSAGE e000(zab) WITH 'TCode is not valid, please use Release PID'.
          ENDIF.
        WHEN '8070'.
          IF pa_i_mseg-sobkz EQ 'W'.
            MESSAGE e000(zab) WITH 'TCode is not valid, please use Release PID'.
          ENDIF.
      ENDCASE.

    WHEN '343' OR '349'.
      IF pa_i_mseg-bukrs EQ '8020' AND
        pa_i_mseg-lgort EQ '10U0' AND
        pa_i_mseg-umlgo EQ '10U0'.
        CLEAR l_live.
        SELECT SINGLE live
          FROM zplbc
          INTO l_live
          WHERE bukrs EQ pa_i_mseg-bukrs
            AND werks EQ pa_i_mseg-werks
            AND live  EQ 'X'.
        IF sy-subrc EQ 0.
          AUTHORITY-CHECK OBJECT 'Z_MSEG_LGO'
              ID 'ACTVT' FIELD '01'
              ID 'WERKS' FIELD pa_i_mseg-werks
              ID 'LGORT' FIELD pa_i_mseg-lgort
              ID 'BWART' FIELD '343'.
          IF sy-subrc <> 0.
            MESSAGE e000(zab) WITH 'You cannot use mvt ' pa_i_mseg-bwart ' for Sloc ' pa_i_mseg-lgort.
          ENDIF.
        ENDIF.
      ENDIF.

*** Validasi untuk transaksi JDE
**      IF pa_i_mseg-bwart EQ '343'.
**        IF pa_i_mseg-bukrs EQ '8050' AND
**          pa_i_mseg-werks EQ '0501'.
**          IF pa_i_mseg-umlgo NE '1110' AND
**            pa_i_mseg-umlgo NE '1120'.
**            MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
**          ENDIF.
**        ENDIF.
**      ENDIF.
*
*    WHEN '321' OR '322' OR '344'.
*      IF pa_i_mseg-bukrs EQ '8050' AND
*        pa_i_mseg-werks EQ '0501'.
*        IF pa_i_mseg-umlgo NE '1110' AND
*          pa_i_mseg-umlgo NE '1120'.
*          MESSAGE e000(zab) WITH 'You are not allowed to post this transaction'.
*        ENDIF.
*      ENDIF.
******

* Validasi receiving batch
    WHEN '919'.
* Validasi batch ( Authority )
      DATA: d_vfdat TYPE mch1-vfdat,
            d_matkl TYPE mara-matkl.

      DATA : ra_werks TYPE RANGE OF mseg-werks,
             ln_werks LIKE LINE OF ra_werks.

      ln_werks-low     = '0201'.
      ln_werks-high    = '0299'.
      ln_werks-sign    = 'I'.
      ln_werks-option  = 'BT'.
      APPEND ln_werks TO ra_werks.

      SELECT SINGLE matkl
        FROM mara
        INTO d_matkl
        WHERE matnr = pa_i_mseg-matnr.
      IF sy-subrc = 0.
        IF d_matkl(3) = 'SFF' OR d_matkl(3) = 'TSP' OR d_matkl(3) = 'TRF'.
        ELSE.
          CHECK pa_i_mseg-werks IN ra_werks.
          IF pa_i_mseg-umcha IS NOT INITIAL.
            SELECT SINGLE vfdat
              FROM mch1
              INTO d_vfdat
              WHERE matnr = pa_i_mseg-matnr AND
                    charg = pa_i_mseg-umcha.
            IF sy-subrc EQ 0.
            ELSE.
              MESSAGE e002(zz) WITH 'You are not authorized to change this batch'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

** Validasi batch ( Authority )
*  DATA: d_vfdat TYPE mch1-vfdat,
*        d_matkl TYPE mara-matkl.
*
*  SELECT SINGLE matkl FROM mara INTO d_matkl WHERE matnr = pa_i_mseg-matnr.
*  IF sy-subrc EQ 0.
*    IF d_matkl(3) = 'SFF' OR d_matkl(3) = 'TSP' OR d_matkl(3) = 'TRF'.
*      IF pa_i_mseg-charg IS NOT INITIAL.
*        SELECT SINGLE vfdat
*          FROM mch1
*          INTO d_vfdat
*          WHERE matnr = pa_i_mseg-matnr AND
*                charg = pa_i_mseg-charg.
*        IF sy-subrc EQ 0.
*          IF d_vfdat NE pa_i_mseg-vfdat.
*            CLEAR: d_matkl, d_vfdat.
*            AUTHORITY-CHECK OBJECT 'ZM_BATCH'
*                ID 'ACTVT' FIELD '02'.
*            IF sy-subrc NE 0.
*              MESSAGE e002(zz) WITH 'You are not authorized to change this batch'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.

* New Batch validasi ( Authority )
*  IF pa_i_mseg-bukrs EQ '8020'.
*    AUTHORITY-CHECK OBJECT 'ZM_BATCH'
*        ID 'ACTVT' FIELD '02'.
*    IF sy-subrc EQ 0.
*      SELECT SINGLE matkl FROM mara INTO d_matkl WHERE matnr = pa_i_mseg-matnr.
*      IF sy-subrc EQ 0.
*        IF d_matkl(3) = 'SFF' OR d_matkl(3) = 'TSP' OR d_matkl(3) = 'TRF'.
*          MESSAGE e002(zz) WITH 'You are not authorized to change this batch'.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      MESSAGE e002(zz) WITH 'You are not authorized to change this batch'.
*    ENDIF.
*  ENDIF.

* Validasi SLoc tdk boleh dirubah menyimpang dari DN TLoc khusus 8020/8070
  DATA: ld_lgort  LIKE mseg-lgort.
  DATA : lv_check(30) VALUE '(SAPLMIGO)GOITEM-TAKE_IT',
         lv_cnt01     TYPE i,
         lv_cnt02     TYPE i.

  IF ( pa_i_mseg-bukrs EQ '8020' OR
      pa_i_mseg-bukrs EQ '8070' ) AND
    pa_i_mseg-bwart EQ '101'.
    SELECT SINGLE lgort
      FROM ekpo
      INTO ld_lgort
      WHERE ebeln EQ pa_i_mseg-ebeln AND
            ebelp EQ pa_i_mseg-ebelp.
    IF sy-subrc EQ 0.
      IF ld_lgort IS NOT INITIAL.
        IF ld_lgort NE pa_i_mseg-lgort.
          MESSAGE e002(zz) WITH 'You are not authorized to change this SLoc'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Validasi untuk interface apabila sdh diturunkan tidak blh di cancel oleh TLoc
  DATA: ld_filename  LIKE zpoittc-filename.
  IF ( pa_i_mseg-bukrs EQ '8020' AND
    pa_i_mseg-werks EQ '0200' ).
    IF pa_i_mseg-bwart EQ '642'.
      SELECT SINGLE filename
        FROM zpoittc
        INTO ld_filename
        WHERE werks EQ pa_i_mseg-werks AND
              xblnr EQ pa_i_mkpf-xblnr AND
              matnr EQ pa_i_mseg-matnr.
      IF ld_filename IS NOT INITIAL.
        MESSAGE e002(zz) WITH 'Cancel is not allowed'.
      ENDIF.
    ENDIF.
  ENDIF.

* Validasi untuk interface apabila sdh diturunkan tidak blh di cancel oleh TLoc
  IF pa_i_mseg-bukrs EQ '8070' AND pa_i_mseg-werks EQ '0700'.
    IF ( pa_i_mseg-bwart EQ '352' OR pa_i_mseg-bwart EQ '642' ) AND
         pa_i_mseg-smbln NE space.
      SELECT SINGLE status INTO d_status FROM zst_point
      WHERE  werks = pa_i_mseg-werks AND
             lgort = pa_i_mseg-lgort AND
             mjahr = pa_i_mseg-sjahr AND
             mblnr = pa_i_mseg-smbln.
      SELECT SINGLE mtart FROM mara INTO mtype
      WHERE matnr = pa_i_mseg-matnr.
      IF d_status NE space.
        MESSAGE e002(zz) WITH 'Mat doc. ' pa_i_mseg-mblnr
        'sudah di download jadi intransit'.
      ENDIF.
    ENDIF.
  ENDIF.

  DATA : lv_pkstk TYPE pkstk,
         lv_vstel TYPE vstel,
         lv_lgtor TYPE lgtor,
         lr_vstel TYPE RANGE OF vstel,
         lr_lines LIKE LINE OF lr_vstel.

  CLEAR: lv_pkstk, lv_vstel.

  lr_lines-low    = '0504'.
  lr_lines-high   = '0506'.
  lr_lines-sign   = 'I'.
  lr_lines-option = 'BT'.
  APPEND lr_lines TO lr_vstel.
  lr_lines-low    = '0522'.
  lr_lines-sign   = 'I'.
  lr_lines-option = 'EQ'.
  APPEND lr_lines TO lr_vstel.

  DATA : lv_flag(1).
  DATA : BEGIN OF lt_vbup OCCURS 0,
           vbeln TYPE vbeln,
           posnr TYPE posnr,
           lvsta TYPE lvsta,
           pksta TYPE pksta,
         END OF lt_vbup.

  DATA : BEGIN OF lt_lips OCCURS 0,
           vbeln TYPE vbeln,
           posnr TYPE posnr,
           pstyv TYPE pstyv,
         END OF lt_lips.

  DATA : ls_vbuk TYPE vbuk,
         ls_lips LIKE LINE OF lt_lips.

  DATA : BEGIN OF lt_tvlp OCCURS 0,
           pstyv TYPE pstyv_vl,
         END OF lt_tvlp.

  DATA : lv_mvgr1 TYPE mvgr1.

* Validasi untuk release DN Tlog
  CASE pa_i_mseg-bwart.
      BREAK bcdik.
*    WHEN '641'.
*      IF pa_i_mseg-bukrs EQ '8020'.
*        IF pa_i_mseg-lgort NE '1005'.
*          CLEAR mtype.
*          SELECT SINGLE mtart FROM mara INTO mtype
*            WHERE matnr = pa_i_mseg-matnr.
*          IF mtype EQ 'ZPHA'.
*            SELECT SINGLE vbeln
*              FROM zmreldn
*              INTO lv_vbeln
*              WHERE vbeln EQ pa_i_mkpf-le_vbeln.
*            IF sy-subrc NE 0.
*              MESSAGE e002(zz) WITH 'DN ' pa_i_mkpf-le_vbeln
*              'belum di release oleh APJ'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.

    WHEN '601' OR '631' OR '641' OR '653' OR '655' OR '907' OR '985' OR '945'.
      IF pa_i_mseg-bwart EQ '641'.
        IF pa_i_mseg-bukrs EQ '8020'.
          IF pa_i_mseg-werks = '0200'.
            IF pa_i_mseg-lgort NE '1005'.
              SELECT SINGLE mvgr1 INTO lv_mvgr1
                FROM mvke WHERE matnr = pa_i_mseg-matnr
                            AND vkorg = pa_i_mseg-bukrs
                            AND vtweg = '10'
                            AND mvgr1 = '04'.
              IF sy-subrc = 0.
                SELECT SINGLE vbeln
                  FROM zmreldn
                  INTO lv_vbeln
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln.
                IF sy-subrc NE 0.
                  MESSAGE e002(zz) WITH 'DN ' pa_i_mkpf-le_vbeln
                  'belum di release oleh PJ ALKES'.
                ENDIF.
              ELSE.
                CLEAR mtype.
                SELECT SINGLE mtart FROM mara INTO mtype
                  WHERE matnr = pa_i_mseg-matnr.
                IF mtype EQ 'ZPHA'.
                  SELECT SINGLE vbeln
                    FROM zmreldn
                    INTO lv_vbeln
                    WHERE vbeln EQ pa_i_mkpf-le_vbeln.
                  IF sy-subrc NE 0.
                    MESSAGE e002(zz) WITH 'DN ' pa_i_mkpf-le_vbeln
                    'belum di release oleh APJ'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
* Aktif setelah GoLive barcode, agar tidak berpengaruh sebelumnya
* karena ZMM_EXIT akan di transport ke P01 sebelum tanggal 13/10/2014
      SELECT SINGLE flag
        FROM zproject
        INTO lv_flag
        WHERE name EQ 'BCW'
          AND datab LE sy-datum.

      IF lv_flag IS NOT INITIAL.
        IF ( pa_i_mseg-bukrs EQ '8050' AND
          pa_i_mseg-werks EQ '0501' ).
          SELECT SINGLE vstel lgtor
            FROM likp
            INTO (lv_vstel, lv_lgtor)
            WHERE vbeln EQ pa_i_mkpf-xblnr.
          IF sy-subrc EQ 0.
            IF lv_lgtor NE 'SA1'.
              IF lv_vstel IN lr_vstel.
                SELECT vbeln posnr pstyv
                  FROM lips
                  INTO TABLE lt_lips
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
                    AND uecha EQ space.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF ( pa_i_mseg-bukrs EQ '8380' AND
           pa_i_mseg-werks EQ '3800' AND
           ( pa_i_mseg-lgort EQ '1001' OR pa_i_mseg-lgort EQ '1100' OR
             pa_i_mseg-lgort EQ '10E0' ) ).
          SELECT SINGLE vstel lgtor
            FROM likp
            INTO (lv_vstel, lv_lgtor)
            WHERE vbeln EQ pa_i_mkpf-xblnr.
          IF sy-subrc EQ 0.
            IF lv_lgtor NE 'SA1'.
              IF lv_vstel IN lr_vstel.
                SELECT vbeln posnr pstyv
                  FROM lips
                  INTO TABLE lt_lips
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
                    AND uecha EQ space.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF ( pa_i_mseg-bukrs EQ '8220' AND
           pa_i_mseg-werks EQ '2200' AND
           ( pa_i_mseg-lgort EQ '1000' OR pa_i_mseg-lgort EQ '1001' ) ).
          SELECT SINGLE vstel lgtor
            FROM likp
            INTO (lv_vstel, lv_lgtor)
            WHERE vbeln EQ pa_i_mkpf-xblnr.
          IF sy-subrc EQ 0.
            IF lv_lgtor NE 'SA1'.
              IF lv_vstel IN lr_vstel.
                SELECT vbeln posnr pstyv
                  FROM lips
                  INTO TABLE lt_lips
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
                    AND uecha EQ space.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF ( pa_i_mseg-bukrs EQ '8210' AND
         pa_i_mseg-werks EQ '2100' AND
        ( pa_i_mseg-lgort EQ '1120' OR pa_i_mseg-lgort EQ '1121' ) ).
          SELECT SINGLE vstel lgtor
            FROM likp
            INTO (lv_vstel, lv_lgtor)
            WHERE vbeln EQ pa_i_mkpf-xblnr.
          IF sy-subrc EQ 0.
            IF lv_lgtor NE 'SA1'.
              IF lv_vstel IN lr_vstel.
                SELECT vbeln posnr pstyv
                  FROM lips
                  INTO TABLE lt_lips
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
                    AND uecha EQ space.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF ( pa_i_mseg-bukrs EQ '8020' AND
        ( pa_i_mseg-werks EQ '0201' OR pa_i_mseg-werks EQ '0230' ) AND
        pa_i_mseg-lgort EQ '1002' ).
          SELECT SINGLE vstel lgtor
            FROM likp
            INTO (lv_vstel, lv_lgtor)
            WHERE vbeln EQ pa_i_mkpf-xblnr.
          IF sy-subrc EQ 0.
            IF lv_lgtor NE 'SA1'.
              IF lv_vstel IN lr_vstel.
                SELECT vbeln posnr pstyv
                  FROM lips
                  INTO TABLE lt_lips
                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
                    AND uecha EQ space.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        LOOP AT lt_lips.
          IF lt_lips-pstyv = 'ZTAE'.
            DELETE lt_lips.
          ENDIF.
        ENDLOOP.

*      IF lv_flag IS NOT INITIAL.
*        IF ( pa_i_mseg-bukrs EQ '8050' AND
*          pa_i_mseg-werks EQ '0501' ).
*          SELECT SINGLE vstel lgtor
*            FROM likp
*            INTO (lv_vstel, lv_lgtor)
*            WHERE vbeln EQ pa_i_mkpf-xblnr.
*          IF sy-subrc EQ 0.
*            IF lv_lgtor NE 'SA1'.
*              IF lv_vstel IN lr_vstel.
*                SELECT vbeln posnr
*                  FROM lips
*                  INTO TABLE lt_lips
*                  WHERE vbeln EQ pa_i_mkpf-le_vbeln
*                    AND pstyv NE 'ZTAN'.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ELSEIF ( pa_i_mseg-bukrs EQ '8220' AND
*           pa_i_mseg-werks EQ '2200' AND
*           pa_i_mseg-lgort EQ '1000' ).
*          SELECT SINGLE vstel lgtor
*            FROM likp
*            INTO (lv_vstel, lv_lgtor)
*            WHERE vbeln EQ pa_i_mkpf-xblnr.
*          IF sy-subrc EQ 0.
*            IF lv_lgtor NE 'SA1'.
*              IF lv_vstel IN lr_vstel.
*                SELECT pstyv
*                 FROM tvlp
*                 INTO TABLE lt_tvlp
*                 WHERE chhpv = 'X'
*                   AND pckpf = space.
*
*                IF lt_tvlp[] IS NOT INITIAL.
*                  SELECT vbeln posnr
*                    FROM lips
*                    INTO TABLE lt_lips
*                    FOR ALL ENTRIES IN lt_tvlp
*                    WHERE vbeln EQ pa_i_mkpf-le_vbeln
*                      AND pstyv EQ lt_tvlp-pstyv.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.

        IF lt_lips[] IS NOT INITIAL.
          READ TABLE lt_lips INTO ls_lips INDEX 1.
          SELECT SINGLE *
            FROM vbuk
            INTO CORRESPONDING FIELDS OF ls_vbuk
            WHERE vbeln = ls_lips-vbeln.

          SELECT vbeln posnr lvsta pksta
            FROM vbup
            INTO TABLE lt_vbup
            FOR ALL ENTRIES IN lt_lips
            WHERE vbeln EQ lt_lips-vbeln
              AND posnr EQ lt_lips-posnr.
          IF sy-subrc EQ 0.
            IF ls_vbuk-pkstk <> 'C'.
              MESSAGE e005(zhupast).
            ELSE.
              LOOP AT lt_vbup.
                IF lt_vbup-pksta <> 'C'.
                  MESSAGE e005(zhupast).
*                ELSEIF lt_vbup-lvsta = space.
*                  MESSAGE e005(zhupast).
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* This process is to validate that every DO to outlet from PTT Branch
* that include pharmacheutical items shoud have release process from APJ
      CLEAR lv_flag.
      SELECT SINGLE flag
        FROM zproject
        INTO lv_flag
        WHERE name EQ 'RELAPJ'
          AND datab LE sy-datum.

      IF lv_flag = 'X'.
        SELECT SINGLE live INTO l_live FROM zplbc WHERE
               werks = pa_i_mseg-werks AND
               lgort = '1000'.
        IF l_live <> 'X'.
          EXIT.
        ELSE.
          IF pa_i_mseg-bukrs = '8020' AND
            pa_i_mseg-bwart = '601'.
            CLEAR mtype.
            SELECT SINGLE mtart FROM mara INTO mtype
              WHERE matnr = pa_i_mseg-matnr.
            IF mtype EQ 'ZPHA'.
              SELECT SINGLE vbeln
                FROM zmreldn
                INTO lv_vbeln
                WHERE vbeln EQ pa_i_mkpf-le_vbeln.
              IF sy-subrc NE 0.
                MESSAGE e002(zz) WITH 'DN ' pa_i_mkpf-le_vbeln
                'belum di release oleh APJ'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.




    WHEN '642'.
      IF pa_i_mseg-bukrs EQ '8020'.
        CLEAR mtype.
        SELECT SINGLE mtart FROM mara INTO mtype
          WHERE matnr = pa_i_mseg-matnr.
        IF mtype EQ 'ZPHA'.
          SELECT SINGLE vbeln
            FROM zmreldn
            INTO lv_vbeln
            WHERE vbeln EQ pa_i_mkpf-le_vbeln.
          IF sy-subrc EQ 0.
            SELECT vbeln zcount
              FROM zmreldn_hist
              INTO CORRESPONDING FIELDS OF TABLE lt_zmreldn_hist
              WHERE vbeln EQ lv_vbeln.

            lwa_zmreldn_hist-vbeln = pa_i_mkpf-le_vbeln.
            IF sy-subrc EQ 0.
              SORT lt_zmreldn_hist BY zcount DESCENDING.
              READ TABLE lt_zmreldn_hist INDEX 1.
              lwa_zmreldn_hist-zcount = lt_zmreldn_hist-zcount + 1.
            ELSE.
              lwa_zmreldn_hist-zcount = 1.
            ENDIF.
            lwa_zmreldn_hist-zrelby  = sy-uname.
            lwa_zmreldn_hist-zreldt  = sy-datum.
            lwa_zmreldn_hist-zreltm  = sy-uzeit.

            CLEAR: lt_zmreldn_hist, lt_zmreldn_hist[].

            DELETE FROM zmreldn WHERE vbeln EQ pa_i_mkpf-le_vbeln.
            INSERT zmreldn_hist FROM lwa_zmreldn_hist.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
*****

ENDFORM.                    " F_MM_check_and_text_mdoc


************************* INVOICE VERIFICATION *************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_check_invoice
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->pa_I_TRBKPV TYPE  MRM_RBKPV
*      -->PA_I_RSEG   LIKE  mmcr_drseg[]
*----------------------------------------------------------------------*
TYPE-POOLS : mrm, mmcr.

DATA: mmcr_drseg TYPE mmcr_drseg OCCURS 0.

*&---------------------------------------------------------------------*
*&      Form  F_MM_check_invoice
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_I_TRBKPV       text
*      -->VALUE(PA_I_RSEG)  text
*----------------------------------------------------------------------*
FORM f_mm_check_invoice
            USING pa_i_trbkpv TYPE mrm_rbkpv
            VALUE(pa_i_rseg)  LIKE mmcr_drseg[].

  DATA : pc        TYPE i, num(7) TYPE n, str(7) TYPE c,
         wa_i_rseg LIKE LINE OF pa_i_rseg.
  DATA: lv_knttp LIKE  wa_i_rseg-knttp.

  IF pa_i_trbkpv-bukrs = '8020' OR
    pa_i_trbkpv-bukrs = '8030' OR
    pa_i_trbkpv-bukrs = '8070'.
* Cek apakah menggunakan tcode MIRO atau MIR4 dan tax code <> B0
    IF  sy-tcode = 'MIRO' OR sy-tcode = 'MIR4' OR sy-tcode = 'MIR7'." AND
*          pa_i_trbkpv-mwskz1 <> 'B0'.

      CLEAR: lv_knttp.
      SORT pa_i_rseg BY knttp.
      READ TABLE pa_i_rseg INTO wa_i_rseg WITH KEY  knttp = 'A'
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_knttp = wa_i_rseg-knttp.
      ENDIF.
      SORT pa_i_rseg BY knttp.
      READ TABLE pa_i_rseg INTO wa_i_rseg WITH KEY  knttp = 'K'
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_knttp = wa_i_rseg-knttp.
      ENDIF.
      LOOP AT pa_i_rseg INTO wa_i_rseg.
* Cek apakah ada posting ke GL account
**        IF wa_i_rseg-knttp = 'A' OR wa_i_rseg-knttp = 'K'.
**          lv_knttp = wa_i_rseg-knttp.
**        ENDIF.
        IF wa_i_rseg-saknr <> '' AND lv_knttp <> 'A' AND lv_knttp <> 'K'.
          IF ( wa_i_rseg-bukrs = '8020' AND ( wa_i_rseg-gsber <> '0200' AND
             wa_i_rseg-gsber(2) <> 'T2' ) ) OR
            ( wa_i_rseg-bukrs = '8030' AND wa_i_rseg-gsber(2) <> '03' ) OR
            ( wa_i_rseg-bukrs = '8070' AND wa_i_rseg-gsber(2) <> '07' ).
            MESSAGE e002(zz) WITH 'Business Area salah !!!'.
          ENDIF.
        ENDIF.
*****        IF wa_i_rseg-saknr <> '' AND wa_i_rseg-knttp <> 'A' AND wa_i_rseg-knttp <> 'K'.
****** Cek bussiness area, apakah sesuai dengan company code
******          IF ( wa_i_rseg-bukrs = '8020' AND wa_i_rseg-gsber <> '0200' ) OR
*****          IF ( wa_i_rseg-bukrs = '8020' AND ( wa_i_rseg-gsber <> '0200' AND
*****             wa_i_rseg-gsber <> 'T220' ) ) OR
*****            ( wa_i_rseg-bukrs = '8030' AND wa_i_rseg-gsber(2) <> '03' ) OR
*****            ( wa_i_rseg-bukrs = '8070' AND wa_i_rseg-gsber(2) <> '07' ).
*****            MESSAGE e002(zz) WITH 'Business Area salah !!!'.
*****          ENDIF.
*****        ENDIF.
      ENDLOOP.

      CLEAR wa_i_rseg.

* Cek apakah invoice atau credit memo
*-------------------------------------
* Jika invoice
      IF pa_i_trbkpv-xrech = 'X'.

* Cek apakah field header text dan assignment telah terisi
        IF pa_i_trbkpv-bktxt = '' OR pa_i_trbkpv-zuonr = ''.
          MESSAGE e000(zz).
        ENDIF.

* Lakukan validasi jika header text terisi
        IF pa_i_trbkpv-bktxt <> ''.
          pc = strlen( pa_i_trbkpv-bktxt ).
          IF pc <> '10'.
            MESSAGE e002(zz) WITH 'Isi tanggal dengan format : dd.mm.yyyy'.
          ELSEIF pc = '10'.
            IF pa_i_trbkpv-bktxt+2(1) <> '.' OR
               pa_i_trbkpv-bktxt+5(1) <> '.'.
              MESSAGE e002(zz) WITH 'Isi tanggal dengan format : dd.mm.yyyy'.
            ENDIF.
            IF pa_i_trbkpv-bktxt+0(8) CN '.0123456789'.
              MESSAGE e002(zz) WITH 'Tanggal tidak boleh mengandung huruf'.
            ENDIF.
          ENDIF.
        ENDIF.

* Lakukan validasi jika assignment terisi
        IF pa_i_trbkpv-zuonr <> ''.
          pc = strlen( pa_i_trbkpv-zuonr ).
          IF pc <> '16'.
            MESSAGE e002(zz) WITH 'No faktur pajak harus 16 angka'.
          ELSEIF pc = '16'.
            IF pa_i_trbkpv-zuonr(15) CN '0123456789'.
              MESSAGE e002(zz) WITH 'No faktur pajak harus angka'.
            ENDIF.
          ENDIF.
        ENDIF.

* Jika credit memo
      ELSE.
        LOOP AT pa_i_rseg INTO wa_i_rseg.


* Start cek posting to material
*-------------------------------------------------------------------*
** Cek apakah ada posting to material ?
*    If WA_I_RSEG-XBLNR = '' and WA_I_RSEG-MATNR <> ''.
*
** Cek apakah field header text dan assignment telah terisi
*      If PA_I_BKTXT = '' or PA_I_ZUONR = ''.
*        MESSAGE E000(zz).
*      endif.
*
** Lakukan validasi jika header text terisi
*      If PA_I_BKTXT <> ''.
*        PC = strlen( PA_I_BKTXT ).
*        If PC <> '10'.
*         MESSAGE E002(zz) with 'Isi tanggal dengan format : dd.mm.yyyy'
          .
*        Elseif PC = '10'.
*          If PA_I_BKTXT+2(1) <> '.' or PA_I_BKTXT+5(1) <> '.'.
*         MESSAGE E002(zz) with 'Isi tanggal dengan format : dd.mm.yyyy'
          .
*          Endif.
*          If PA_I_BKTXT+0(8) CN '.0123456789'.
*           MESSAGE E002(zz) with 'Tanggal tidak boleh mengandung huruf'
          .
*          Endif.
*        Endif.
*      Endif.
*
** Lakukan validasi jika assignment terisi
*      If PA_I_ZUONR <> ''.
*        PC = strlen( PA_I_ZUONR ).
*        If PC <> '7'.
*          MESSAGE E002(zz) with 'No faktur pajak harus 7 angka'.
*        Elseif PC = '7'.
*          If PA_I_ZUONR+0(7) CN '0123456789'.
*            MESSAGE E002(zz) with 'No faktur pajak harus angka'.
*          Endif.
*        Endif.
*      Endif.
*    Endif.
*-------------------------------------------------------------------*


* Start cek delivery note
*-------------------------------------------------------------------*
* Apakah posting to delivery note ?
          IF wa_i_rseg-xblnr <> ''.
            IF wa_i_rseg-sgtxt = ''.
              MESSAGE e002(zz) WITH
              'Tolong isi nomer dan tgl faktur pajak reference'.
            ELSEIF wa_i_rseg-sgtxt <> ''.
              pc = strlen( wa_i_rseg-sgtxt ).
*              IF pc <> '18' OR wa_i_rseg-sgtxt+7(1) <> '/'.
*                MESSAGE e002(zz) WITH
*                'Isi dengan format 1234567/dd.mm.yyyy'.
*              ELSEIF pc = '18'.
*                IF wa_i_rseg-sgtxt+0(7) CN '0123456789'.
*                  MESSAGE e002(zz) WITH 'No faktur pajak harus angka'.
*                ENDIF.
*                IF wa_i_rseg-sgtxt+10(1) <> '.' OR wa_i_rseg-sgtxt+13(1) <> '.'.
*                  MESSAGE e002(zz) WITH 'Isi tanggal dengan format : dd.mm.yyyy'.
*                ENDIF.
*                IF wa_i_rseg-sgtxt+8(10) CN '.0123456789'.
*                  MESSAGE e002(zz) WITH 'Tanggal tidak boleh mengandung huruf'.
*                ENDIF.
*              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MM_check_invoice



******************************* DELIVERY *******************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_check_overdelivery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_LIPS  LIKE  LIPS
*----------------------------------------------------------------------*
DATA: BEGIN OF xlips OCCURS 0.
        INCLUDE STRUCTURE lipsvb.
      DATA: END OF xlips.
DATA: BEGIN OF tlips OCCURS 0.
        INCLUDE STRUCTURE lips.
      DATA: END OF tlips.
DATA: wa_xlips LIKE lipsvb,
      wa_lips  LIKE lips.
DATA: sw(1).
*&---------------------------------------------------------------------*
*&      Form  F_MM_check_overdelivery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(PA_I_LIPS)  text
*----------------------------------------------------------------------*
FORM f_mm_check_overdelivery
             USING VALUE(pa_i_lips) LIKE xlips[].

  DATA : v_menge     LIKE ekpo-menge,
         v_totgi     LIKE ekpo-menge,
         v_lfimg     LIKE lips-lfimg,
         v_opdel     LIKE lips-lfimg,
         v_uebpr     LIKE tvlp-uebpr,
         v_vbeln     LIKE lips-vbeln,
         dif(6),
         err_msg(60) TYPE c.

  DATA: BEGIN OF gt_ekpo OCCURS 0,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          matnr TYPE matnr,
          menge TYPE bstmg,
          lewed TYPE lewed,
        END OF gt_ekpo.

* Check apakah change delivery, jika ya jalankan sub routine
  IF sy-tcode = 'VL02' OR sy-tcode = 'VL02N' OR
     sy-tcode = 'VL03N'.
    CLEAR : tlips, wa_xlips.
    REFRESH tlips.
    sw = 1.
    SORT pa_i_lips ASCENDING BY vgbel vgpos.
    LOOP AT pa_i_lips INTO wa_xlips.
      ON CHANGE OF wa_xlips-vgbel OR wa_xlips-vgpos.
        IF sw = 1.
          sw = 2.
        ELSE.
          APPEND tlips.
          CLEAR  tlips.
        ENDIF.
      ENDON.
      tlips-vbeln = wa_xlips-vbeln.
      tlips-vgbel = wa_xlips-vgbel.
      tlips-vgpos = wa_xlips-vgpos.
      tlips-matnr = wa_xlips-matnr.
      tlips-pstyv = wa_xlips-pstyv.
      tlips-meins = wa_xlips-meins.
      tlips-lfimg = tlips-lfimg + wa_xlips-lfimg.
    ENDLOOP.
    APPEND tlips.

* APPEND lines of PA_I_LIPS to TLIPS.
    CLEAR wa_lips.

    LOOP AT tlips INTO wa_lips.
      CLEAR : v_menge, v_totgi,
              v_opdel, v_lfimg.
      CASE wa_lips-pstyv.
* Check quantity in delivery for PO-STO
        WHEN 'NLN' OR 'NLC' OR 'ZNLN' OR 'ZNLC' OR 'ZOI1' OR 'ZTAN'.
          IF ( wa_lips-pstyv = 'ZOI1' OR wa_lips-pstyv = 'ZTAN' ) AND
               wa_lips-werks <> '1800' AND  wa_lips-werks <> '2200' AND
               wa_lips-werks <> '2300'.
            EXIT.
          ENDIF.
          SELECT SINGLE menge FROM ekpo INTO v_menge
          WHERE ebeln = wa_lips-vgbel AND ebelp = wa_lips-vgpos.

          SELECT lfimg vbeln FROM lips INTO (v_lfimg , v_vbeln)
          WHERE vgbel = wa_lips-vgbel AND vgpos = wa_lips-vgpos
            AND pstyv <> 'ELN'.
            IF v_vbeln <> wa_lips-vbeln.
              v_opdel = v_opdel + v_lfimg.
            ENDIF.
          ENDSELECT.

          v_opdel = v_menge - v_opdel.
* Check customizing table, whether error message already set or not
          SELECT SINGLE uebpr FROM tvlp INTO v_uebpr
          WHERE pstyv = wa_lips-pstyv.
          IF wa_lips-lfimg > v_opdel AND v_uebpr = 'B'.
            dif = wa_lips-lfimg - v_opdel.
            CONCATENATE 'Material' wa_lips-matnr 'Qty delivered over' dif INTO
       err_msg SEPARATED BY space.
*            MESSAGE e002(zz) WITH err_msg wa_lips-meins 'than open delivery qty'.
            MESSAGE i002(zz) WITH err_msg wa_lips-meins 'than open delivery qty'.
            LEAVE PROGRAM.
          ENDIF.

* Check quantity in delivery return for PO-STO CC
        WHEN 'NCRN' OR 'ZNCR'.
          DATA : d_werks LIKE ekpo-werks.
          SELECT SINGLE werks FROM ekpo INTO d_werks WHERE ebeln = wa_lips-vgbel.
          IF d_werks(2) = '07' OR d_werks(2) = '38'.
          ELSE.
            SELECT menge FROM ekbe INTO v_menge
            WHERE ebeln = wa_lips-vgbel AND ebelp = wa_lips-vgpos AND
                  bwart = '161'.
              v_totgi = v_totgi + v_menge.
            ENDSELECT.

            IF sy-subrc <> '0'.
*            MESSAGE e002(zz) WITH 'GR return belum dilakukan'.
              MESSAGE i002(zz) WITH 'GR return belum dilakukan'.
              LEAVE PROGRAM.
            ENDIF.

            CLEAR v_menge.
            SELECT menge FROM ekbe INTO v_menge
            WHERE ebeln = wa_lips-vgbel AND ebelp = wa_lips-vgpos AND
                  bwart = '162'.
              v_totgi = v_totgi - v_menge.
            ENDSELECT.

            SELECT lfimg vbeln FROM lips INTO (v_lfimg , v_vbeln)
            WHERE vgbel = wa_lips-vgbel AND vgpos = wa_lips-vgpos.
* Cek if transaction is change delivery, don't add qty to open delivery
              IF v_vbeln <> wa_lips-vbeln.
                v_opdel = v_opdel + v_lfimg.
              ENDIF.
            ENDSELECT.

            v_opdel = v_totgi - v_opdel.

            IF wa_lips-lfimg > v_opdel.
*            MESSAGE e002(zz) WITH 'Quantity receipt over than issue quantity'.
              MESSAGE i002(zz) WITH 'Quantity receipt over than issue quantity'.
              LEAVE PROGRAM.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF sy-tcode NE 'VL09' AND sy-tcode NE 'LT0G' AND sy-tcode NE 'LT12' AND
    sy-tcode NE 'LM05' AND sy-tcode NE 'LM07' AND sy-tcode NE 'LT11'.

    DATA : r_vbeln   TYPE RANGE OF lips-vbeln WITH HEADER LINE.

    SELECT sign AS sign
           opti AS option
            low AS low
           high AS high
      FROM tvarvc
      INTO TABLE r_vbeln
      WHERE name EQ 'ZMGI_EXPIRED'.


    LOOP AT pa_i_lips INTO wa_xlips WHERE updkz <> 'D'.
      IF wa_xlips-vbeln IN r_vbeln.
      ELSE.
        SELECT ebeln ebelp matnr lewed
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
          WHERE ebeln   EQ wa_xlips-vgbel
            AND ebelp   EQ wa_xlips-vgpos+1(5)
            AND matnr   EQ wa_xlips-matnr.
        IF sy-subrc EQ 0.
          LOOP AT gt_ekpo.
            IF gt_ekpo-lewed IS NOT INITIAL.
              IF gt_ekpo-lewed LT wa_xlips-erdat.
                MESSAGE i000(zab) WITH 'PO sudah expired'.
                LEAVE PROGRAM.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                   " F_MM_check_overdelivery

*&---------------------------------------------------------------------*
*&      Form  F_MM_check_overdelv_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_I_LIPS  LIKE  LIPS
*----------------------------------------------------------------------*
FORM f_mm_check_overdelv_create
             USING pa_i_lips STRUCTURE lips.

  DATA : v_menge LIKE ekpo-menge,
         v_totgi LIKE ekpo-menge,
         v_lfimg LIKE lips-lfimg,
         v_opdel LIKE lips-lfimg,
         v_uebpr LIKE tvlp-uebpr,
         v_vbeln LIKE lips-vbeln.

  CLEAR v_menge.
  CLEAR v_totgi.
  CLEAR v_opdel.
  CLEAR v_lfimg.

  CASE pa_i_lips-pstyv.

* Check quantity in delivery for PO-STO
    WHEN 'NLN' OR 'NLC' OR 'ZNLN' OR 'ZNLC' OR 'ZOI1' OR 'ZTAN'.
      IF pa_i_lips-bwart = '601' OR pa_i_lips-bwart = '928'.
        EXIT.
      ENDIF.
      IF ( pa_i_lips-pstyv = 'ZOI1' OR pa_i_lips-pstyv = 'ZTAN' ) AND
           pa_i_lips-werks <> '1800' AND  pa_i_lips-werks <> '2200' AND
           pa_i_lips-werks <> '2300'.
        EXIT.
      ENDIF.
      SELECT SINGLE menge FROM ekpo INTO v_menge
      WHERE ebeln = pa_i_lips-vgbel AND ebelp = pa_i_lips-vgpos.

      SELECT lfimg vbeln FROM lips INTO (v_lfimg , v_vbeln)
      WHERE vgbel = pa_i_lips-vgbel AND vgpos = pa_i_lips-vgpos
        AND pstyv <> 'ELN'.
        IF v_vbeln <> pa_i_lips-vbeln.
          v_opdel = v_opdel + v_lfimg.
        ENDIF.
      ENDSELECT.

      SELECT lfimg vbeln FROM lips INTO (v_lfimg , v_vbeln)
      WHERE vbeln = pa_i_lips-vbeln AND posnr NE pa_i_lips-posnr.
        IF pa_i_lips-kcmeng IS NOT INITIAL.
          v_opdel = v_opdel + v_lfimg.
        ENDIF.
      ENDSELECT.

      v_opdel = v_menge - v_opdel.
* Check customizing table, whether error message already set or not
      SELECT SINGLE uebpr FROM tvlp INTO v_uebpr
      WHERE pstyv = pa_i_lips-pstyv.
      IF pa_i_lips-lfimg > v_opdel AND v_uebpr = 'B'.
*        MESSAGE e002(zz) WITH 'Qty delivered over than open delivery qty'.
        MESSAGE i002(zz) WITH 'Qty delivered over than open delivery qty'.
        LEAVE PROGRAM.
      ENDIF.

* Check quantity in delivery return for PO-STO CC
    WHEN 'NCRN' OR 'ZNCR'.
      DATA : d_werks LIKE ekpo-werks.
      SELECT SINGLE werks FROM ekpo INTO d_werks WHERE ebeln = pa_i_lips-vgbel.
      IF d_werks(2) = '07' OR d_werks(2) = '38'.
      ELSE.
        SELECT menge FROM ekbe INTO v_menge
        WHERE ebeln = pa_i_lips-vgbel AND ebelp = pa_i_lips-vgpos AND
              bwart = '161'.
          v_totgi = v_totgi + v_menge.
        ENDSELECT.

        IF sy-subrc <> '0'.
*        MESSAGE e002(zz) WITH 'GR return belum dilakukan'.
          MESSAGE i002(zz) WITH 'GR return belum dilakukan'.
          LEAVE PROGRAM.
        ENDIF.

        CLEAR v_menge.
        SELECT menge FROM ekbe INTO v_menge
        WHERE ebeln = pa_i_lips-vgbel AND ebelp = pa_i_lips-vgpos AND
              bwart = '162'.
          v_totgi = v_totgi - v_menge.
        ENDSELECT.

        SELECT lfimg vbeln FROM lips INTO (v_lfimg , v_vbeln)
        WHERE vgbel = pa_i_lips-vgbel AND vgpos = pa_i_lips-vgpos.
* Cek if transaction is change delivery, don't add qty to open delivery
          IF v_vbeln <> pa_i_lips-vbeln.
            v_opdel = v_opdel + v_lfimg.
          ENDIF.
        ENDSELECT.

        v_opdel = v_totgi - v_opdel.

        IF pa_i_lips-lfimg > v_opdel.
*        MESSAGE e002(zz) WITH 'Quantity receipt over than issue quantity'.
          MESSAGE i002(zz) WITH 'Quantity receipt over than issue quantity'.
          LEAVE PROGRAM.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                   " F_MM_check_overdelv_create


**************************** TRANSPORTATION ****************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_determine_route
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_I_VBAP  LIKE  VBAP
*      -->PA_I_LIPS  LIKE  LIPS
*      <--PA_E_ROUTE LIKE  TROLZ-ROUTE
*----------------------------------------------------------------------*
FORM f_mm_determine_route
             USING pa_i_vbap STRUCTURE vbap
                   pa_i_lips STRUCTURE lips
                   pa_e_route LIKE trolz-route.

  DATA: l_magrv LIKE mara-magrv,
        l_profl LIKE mara-profl,
        l_matnr LIKE mara-matnr.

  IF ( pa_i_vbap-vstel = '0200' OR
    pa_i_vbap-vstel = '0700' ) OR
*     pa_i_vbap-vstel = '0300' OR
     pa_i_vbap-vstel = ''.

    l_matnr = pa_i_vbap-matnr.
    IF l_matnr = ''.
      l_matnr = pa_i_lips-matnr.
    ENDIF.

    SELECT SINGLE magrv profl FROM mara INTO (l_magrv, l_profl)
     WHERE matnr = l_matnr.

    IF l_matnr <> ''.
      IF l_profl = 'OKT' OR l_profl = 'PSI'.
        pa_e_route = 'R00002'.
      ELSE.
        IF l_magrv = '0001'.
          pa_e_route = 'R00002'.
        ELSE.
          pa_e_route = 'R00001'.
        ENDIF.
      ENDIF.
    ELSE.
      pa_e_route = ''.
    ENDIF.
  ELSE.
    pa_e_route = 'R00001'.
  ENDIF.
ENDFORM.                   " F_MM_determine_route


******************************* Report  ********************************
*&---------------------------------------------------------------------*
*&      Form  F_MM_ENDING_STOCK
*&---------------------------------------------------------------------*
*This routine is used by SOM PO1,2,3 calculation report to calculate
*ending stock
FORM f_mm_ending_stock
     USING month
           year
           p_low     LIKE ekko-bedat
           p_high    LIKE ekko-bedat
           matnum    LIKE mara-matnr
           plant     LIKE s031-werks
           end_stock.

  DATA : s031_mzubb   LIKE s031-mzubb,
         s031_magbb   LIKE s031-magbb,
         s031_lgort   LIKE s031-lgort,
         s031_spmon   LIKE s031-spmon,
         s032_mbwbest LIKE s032-mbwbest,
         p_live       LIKE zplbc-live,
         p_month(2)   TYPE n,
         p_year(4)    TYPE c.
  CLEAR : s031_mzubb, s031_magbb,
          s032_mbwbest, end_stock.

  p_month = month - 1.
  p_year = year.
  IF p_month = 0.
    p_month = 12.
    p_year = year - 1.
  ENDIF.
  CONCATENATE p_year p_month INTO s031_spmon.

* Logic mundur (created on 30-sept-2003)
  SELECT DISTINCT SUM( mbwbest )
        INTO s032_mbwbest FROM s032
        WHERE ssour = ''     AND
              vrsio = '000'  AND
              werks = plant  AND
              matnr = matnum AND
              ( lgort LIKE '%00' OR lgort LIKE '%C%' OR lgort EQ space ).

  SELECT DISTINCT SUM( mzubb ) SUM( magbb )
        INTO (s031_mzubb , s031_magbb) FROM s031
        WHERE ssour = ''     AND
              vrsio = '000'  AND
              spmon GT s031_spmon AND
              sptag = '00000000'     AND
              spwoc = '000000'     AND
              spbup = '000000'     AND
              werks = plant  AND
              matnr = matnum AND
              ( lgort LIKE '%00' OR lgort LIKE '%C%' OR lgort EQ space ).
  end_stock = s032_mbwbest - ( s031_mzubb - s031_magbb ).

*------------------------------------
* Routine for intransit Cross company
*------------------------------------
  DATA : gm_qty  LIKE mseg-menge,
         v_kunnr LIKE mseg-kunnr.
  CLEAR gm_qty.

* Get good issue and cancel good receipt quantity data
*-----------------------------------------------------
  SELECT DISTINCT SUM( ekbe~menge ) INTO gm_qty
  FROM ( ekbe INNER JOIN ekpo ON ekbe~ebeln = ekpo~ebeln
         AND ekbe~ebelp = ekpo~ebelp
         INNER JOIN ekko ON ekpo~ebeln = ekko~ebeln )
  WHERE ekbe~budat >= p_low AND ekbe~budat <= p_high AND
        ekpo~loekz <> 'L' AND ekpo~werks = plant AND
        ( ekko~bsart = 'ZB' OR ekko~bsart = 'ZNB' OR ekko~bsart = 'RZB' OR
        ekko~bsart = 'RZNB' ) AND
        ekpo~matnr = matnum AND
        ( ekbe~bwart = '907' OR ekbe~bwart = '102' OR ekbe~bwart = '161' )
  .
* Add in transit stock
  end_stock = end_stock + gm_qty.

  CLEAR gm_qty.

* Get cancel good issue and good receipt quantity data
*-----------------------------------------------------
  SELECT DISTINCT SUM( ekbe~menge ) INTO gm_qty
  FROM ( ekbe INNER JOIN ekpo ON ekbe~ebeln = ekpo~ebeln
         AND ekbe~ebelp = ekpo~ebelp
         INNER JOIN ekko ON ekpo~ebeln = ekko~ebeln )
  WHERE ekbe~budat >= p_low AND ekbe~budat <= p_high AND
        ekpo~loekz <> 'L' AND ekpo~werks = plant AND
        ( ekko~bsart = 'ZB' OR ekko~bsart = 'ZNB' OR ekko~bsart = 'RZB' OR
        ekko~bsart = 'RZNB' ) AND
        ekpo~matnr = matnum AND
        ( ekbe~bwart = '908' OR ekbe~bwart = '101' OR ekbe~bwart = '162' )
  .
* Reduce in transit stock
  end_stock = end_stock - gm_qty.

  CLEAR gm_qty.

*-------------------------------------
* Check plant whether live or non live
*-------------------------------------
  SELECT SINGLE live FROM zplbc INTO p_live
  WHERE werks = plant AND live = 'X'.

*---------------------------------------------------
* If plant is EC non live
* Count intercompany GI quantity for non live branch
*---------------------------------------------------
  IF sy-subrc <> 0 AND plant(2) = '03'.
    CLEAR v_kunnr.
    CONCATENATE 'TSB' plant INTO v_kunnr.

* Get good issue quantity data
*-----------------------------
    SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
    FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
    WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
          mseg~bwart = '932'   AND
          mkpf~budat >= p_low AND mkpf~budat <= p_high.
    end_stock = end_stock + gm_qty.
    CLEAR gm_qty.

* Get cancel good issue quantity data
*------------------------------------
    SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
    FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
    WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
          mseg~bwart = '933'   AND
          mkpf~budat >= p_low AND mkpf~budat <= p_high.
    end_stock = end_stock - gm_qty.
    CLEAR gm_qty.
  ENDIF.

*-----------------------------------------------------------
* Routine for EC-HO -> EC-BRANCH sell purchase Goods Receipt
* Count GI quantity
*-----------------------------------------------------------
  CLEAR v_kunnr.
  CONCATENATE 'TBA' plant INTO v_kunnr.

  SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
  FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
  WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
        mseg~bwart = '901'   AND
        mkpf~budat >= p_low AND mkpf~budat <= p_high.
  end_stock = end_stock + gm_qty.
  CLEAR gm_qty.

  SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
  FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
  WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
        mseg~bwart = '902'   AND
        mkpf~budat >= p_low AND mkpf~budat <= p_high.
  end_stock = end_stock - gm_qty.
  CLEAR gm_qty.

ENDFORM.                    " F_MM_ENDING_STOCK

*&--------------------------------------------------------------*
*&      Form  F_MM_CONS_HIST
*&--------------------------------------------------------------*
*This routine is used by SOM PO1,2,3 calculation report to read
*consumption history
FORM f_mm_cons_hist
     USING month
           year
           matnum    LIKE mara-matnr
           plant     LIKE s031-werks
           demand_n_1
           demand_n_2
           demand_n_3
           demand_n_4
           demand_n_5
           demand_n_6
           demand_n_7
           demand_n_8
           demand_n_9
           demand_n_10
           demand_n_11
           demand_n_12.

  DATA  BEGIN OF t_mver OCCURS 1.
  DATA: matnr LIKE mara-matnr, werks LIKE mver-werks,
        berid LIKE dver-berid,  gjahr LIKE mver-gjahr,
        mgv01 LIKE mver-mgv01, mgv02 LIKE mver-mgv02,
        mgv03 LIKE mver-mgv03, mgv04 LIKE mver-mgv04,
        mgv05 LIKE mver-mgv05, mgv06 LIKE mver-mgv06,
        mgv07 LIKE mver-mgv07, mgv08 LIKE mver-mgv08,
        mgv09 LIKE mver-mgv09, mgv10 LIKE mver-mgv10,
        mgv11 LIKE mver-mgv11, mgv12 LIKE mver-mgv12.
  DATA  END   OF t_mver.
  DATA: v_field01(12), v_field02(12),
        v_field03(12), v_field04(12),
        v_field05(12), v_field06(12),
        v_field07(12), v_field08(12),
        v_field09(12), v_field10(12),
        v_field11(12), v_field12(12),
        d_n1(2)       TYPE n, d_n2(2) TYPE n,
        d_n3(2)       TYPE n, d_n4(2) TYPE n,
        d_n5(2)       TYPE n, d_n6(2) TYPE n,
        d_n7(2)       TYPE n, d_n8(2) TYPE n,
        d_n9(2)       TYPE n, d_n10(2) TYPE n,
        d_n11(2)      TYPE n, d_n12(2) TYPE n,
        t_n1(3)       TYPE c, t_n2(3) TYPE c,
        t_n3(3)       TYPE c, t_n4(3) TYPE c,
        t_n5(3)       TYPE c, t_n6(3) TYPE c,
        t_n7(3)       TYPE c, t_n8(3) TYPE c,
        t_n9(3)       TYPE c, t_n10(3) TYPE c,
        t_n11(3)      TYPE c, t_n12(3) TYPE c,
        d_year        LIKE mver-gjahr,
        d_year1       LIKE mver-gjahr, d_year2 LIKE mver-gjahr,
        d_year3       LIKE mver-gjahr, d_year4 LIKE mver-gjahr,
        d_year5       LIKE mver-gjahr, d_year6 LIKE mver-gjahr,
        d_year7       LIKE mver-gjahr, d_year8 LIKE mver-gjahr,
        d_year9       LIKE mver-gjahr, d_year10 LIKE mver-gjahr,
        d_year11      LIKE mver-gjahr, d_year12 LIKE mver-gjahr.

  FIELD-SYMBOLS: <field01> TYPE any, <field02> TYPE any,
                 <field03> TYPE any, <field04> TYPE any,
                 <field05> TYPE any, <field06> TYPE any,
                 <field07> TYPE any, <field08> TYPE any,
                 <field09> TYPE any, <field10> TYPE any,
                 <field11> TYPE any, <field12> TYPE any.
  CLEAR : d_n1, d_n2, d_n3, d_n4, d_n5, d_n6,
          d_n7, d_n8, d_n9, d_n10, d_n11, d_n12,
          d_year, d_year1, d_year2, d_year3, d_year4,
          d_year5,d_year6, d_year7, d_year8, d_year9,
          d_year10, d_year11, d_year12.

  t_n1 = month - 1.
  t_n2 = month - 2.
  t_n3 = month - 3.
  t_n4 = month - 4.
  t_n5 = month - 5.
  t_n6 = month - 6.
  t_n7 = month - 7.
  t_n8 = month - 8.
  t_n9 = month - 9.
  t_n10 = month - 10.
  t_n11 = month - 11.
  t_n12 = month - 12.
  d_year1 = year.  d_year2 = year.
  d_year3 = year.  d_year4 = year.
  d_year5 = year.  d_year6 = year.
  d_year7 = year.  d_year8 = year.
  d_year9 = year.  d_year10 = year.
  d_year11 = year. d_year12 = year.
  IF t_n1 <= 0.
    t_n1 = t_n1 + 12.
    d_year1 = year - 1.
  ENDIF.
  IF t_n2 <= 0.
    t_n2 = t_n2 + 12.
    d_year2 = year - 1.
  ENDIF.
  IF t_n3 <= 0.
    t_n3 = t_n3 + 12.
    d_year3 = year - 1.
  ENDIF.
  IF t_n4 <= 0.
    t_n4 = t_n4 + 12.
    d_year4 = year - 1.
  ENDIF.
  IF t_n5 <= 0.
    t_n5 = t_n5 + 12.
    d_year5 = year - 1.
  ENDIF.
  IF t_n6 <= 0.
    t_n6 = t_n6 + 12.
    d_year6 = year - 1.
  ENDIF.
  IF t_n7 <= 0.
    t_n7 = t_n7 + 12.
    d_year7 = year - 1.
  ENDIF.
  IF t_n8 <= 0.
    t_n8 = t_n8 + 12.
    d_year8 = year - 1.
  ENDIF.
  IF t_n9 <= 0.
    t_n9 = t_n9 + 12.
    d_year9 = year - 1.
  ENDIF.
  IF t_n10 <= 0.
    t_n10 = t_n10 + 12.
    d_year10 = year - 1.
  ENDIF.
  IF t_n11 <= 0.
    t_n11 = t_n11 + 12.
    d_year11 = year - 1.
  ENDIF.
  IF t_n12 <= 0.
    t_n12 = t_n12 + 12.
    d_year12 = year - 1.
  ENDIF.

  d_n1 = t_n1.   d_n2 = t_n2.
  d_n3 = t_n3.   d_n4 = t_n4.
  d_n5 = t_n5.   d_n6 = t_n6.
  d_n7 = t_n7.   d_n8 = t_n8.
  d_n9 = t_n9.   d_n10 = t_n10.
  d_n11 = t_n11. d_n12 = t_n12.

  CONCATENATE: 'T_MVER-MGV' d_n1 INTO v_field01,
               'T_MVER-MGV' d_n2 INTO v_field02,
               'T_MVER-MGV' d_n3 INTO v_field03,
               'T_MVER-MGV' d_n4 INTO v_field04,
               'T_MVER-MGV' d_n5 INTO v_field05,
               'T_MVER-MGV' d_n6 INTO v_field06,
               'T_MVER-MGV' d_n7 INTO v_field07,
               'T_MVER-MGV' d_n8 INTO v_field08,
               'T_MVER-MGV' d_n9 INTO v_field09,
               'T_MVER-MGV' d_n10 INTO v_field10,
               'T_MVER-MGV' d_n11 INTO v_field11,
               'T_MVER-MGV' d_n12 INTO v_field12.
  ASSIGN: (v_field01) TO <field01>,
          (v_field02) TO <field02>,
          (v_field03) TO <field03>,
          (v_field04) TO <field04>,
          (v_field05) TO <field05>,
          (v_field06) TO <field06>,
          (v_field07) TO <field07>,
          (v_field08) TO <field08>,
          (v_field09) TO <field09>,
          (v_field10) TO <field10>,
          (v_field11) TO <field11>,
          (v_field12) TO <field12>.
  d_year = year - 1.

  SELECT matnr werks gjahr mgv01 mgv02 mgv03 mgv04 mgv05 mgv06
         mgv07 mgv08 mgv09 mgv10 mgv11 mgv12
  FROM mver INTO CORRESPONDING FIELDS OF TABLE t_mver
  WHERE matnr = matnum  AND
        werks = plant   AND
        gjahr >= d_year AND
        gjahr <= year.
  SORT t_mver BY matnr werks.
  READ TABLE t_mver WITH KEY matnr = matnum
                             werks = plant
                             gjahr = d_year1
                             BINARY SEARCH.
  CASE d_n1.
    WHEN '01'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
      ELSE.
        CLEAR: demand_n_1.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year2
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_2, demand_n_3, demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9,
               demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '02'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year3
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_3, demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9,
               demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '03'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year4
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9,
               demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '04'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year5
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9,
               demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '05'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year6
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR:   demand_n_6, demand_n_7, demand_n_8, demand_n_9,
                 demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '06'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
                  demand_n_6.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year7
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR:   demand_n_7, demand_n_8, demand_n_9,
                 demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '07'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
                  demand_n_6, demand_n_7.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year8
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR:   demand_n_8, demand_n_9,
                 demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '08'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
                  demand_n_6, demand_n_7, demand_n_8.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year9
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR:   demand_n_9,
                 demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '09'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
                 demand_n_6, demand_n_7, demand_n_8, demand_n_9.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year10
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
    WHEN '10'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9, demand_n_10.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year11
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_11, demand_n_12.
      ENDIF.
    WHEN '11'.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9, demand_n_10,
               demand_n_11.
      ENDIF.
      READ TABLE t_mver WITH KEY matnr = matnum
                                 werks = plant
                                 gjahr = d_year12
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_12.
      ENDIF.
    WHEN OTHERS.
      IF sy-subrc = 0.
        demand_n_1 = <field01>.
        demand_n_2 = <field02>.
        demand_n_3 = <field03>.
        demand_n_4 = <field04>.
        demand_n_5 = <field05>.
        demand_n_6 = <field06>.
        demand_n_7 = <field07>.
        demand_n_8 = <field08>.
        demand_n_9 = <field09>.
        demand_n_10 = <field10>.
        demand_n_11 = <field11>.
        demand_n_12 = <field12>.
      ELSE.
        CLEAR: demand_n_1, demand_n_2, demand_n_3, demand_n_4, demand_n_5,
               demand_n_6, demand_n_7, demand_n_8, demand_n_9,
               demand_n_10, demand_n_11, demand_n_12.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_MM_CONS_HIST

*&---------------------------------------------------------------------*
*&      Form  F_MM_ENDING_STOCK_OLD
*&---------------------------------------------------------------------*
FORM f_mm_ending_stock_old
     USING month
           year
           p_low     LIKE ekko-bedat
           p_high    LIKE ekko-bedat
           matnum    LIKE mara-matnr
           plant     LIKE s031-werks
           end_stock.

  DATA : s031_mzubb LIKE s031-mzubb,
         s031_magbb LIKE s031-magbb,
         s031_lgort LIKE s031-lgort,
         s031_spmon LIKE s031-spmon,
         p_live     LIKE zplbc-live,
         p_month(2) TYPE n,
         p_year(4)  TYPE c.
  CLEAR : s031_mzubb, s031_magbb,
          end_stock.

  p_month = month - 1.
  p_year = year.
  IF p_month = 0.
    p_month = 12.
    p_year = year - 1.
  ENDIF.
  CONCATENATE p_year p_month INTO s031_spmon.

* Logic maju
  SELECT DISTINCT SUM( mzubb ) SUM( magbb )
        INTO (s031_mzubb , s031_magbb) FROM s031
        WHERE ssour = ''     AND
              vrsio = '000'  AND
              spmon LE s031_spmon AND
              sptag = '00000000'     AND
              spwoc = '000000'     AND
              spbup = '000000'     AND
              werks = plant  AND
              matnr = matnum AND
              ( lgort LIKE '%00' OR lgort LIKE '%C%' OR lgort EQ space ).
  end_stock = end_stock + ( s031_mzubb - s031_magbb ).

*------------------------------------
* Routine for intransit Cross company
*------------------------------------
  DATA : gm_qty  LIKE mseg-menge,
         v_kunnr LIKE mseg-kunnr.
  CLEAR gm_qty.

* Get good issue and cancel good receipt quantity data
*-----------------------------------------------------
  SELECT DISTINCT SUM( ekbe~menge ) INTO gm_qty
  FROM ( ekbe INNER JOIN ekpo ON ekbe~ebeln = ekpo~ebeln
         AND ekbe~ebelp = ekpo~ebelp
         INNER JOIN ekko ON ekpo~ebeln = ekko~ebeln )
  WHERE ekbe~budat >= p_low AND ekbe~budat <= p_high AND
        ekpo~loekz <> 'L' AND ekpo~werks = plant AND
        ( ekko~bsart = 'ZB' OR ekko~bsart = 'ZNB' OR ekko~bsart = 'RZB' OR
        ekko~bsart = 'RZNB' ) AND
        ekpo~matnr = matnum AND
        ( ekbe~bwart = '907' OR ekbe~bwart = '102' OR ekbe~bwart = '161' )
  .
* Add in transit stock
  end_stock = end_stock + gm_qty.

  CLEAR gm_qty.

* Get cancel good issue and good receipt quantity data
*-----------------------------------------------------
  SELECT DISTINCT SUM( ekbe~menge ) INTO gm_qty
  FROM ( ekbe INNER JOIN ekpo ON ekbe~ebeln = ekpo~ebeln
         AND ekbe~ebelp = ekpo~ebelp
         INNER JOIN ekko ON ekpo~ebeln = ekko~ebeln )
  WHERE ekbe~budat >= p_low AND ekbe~budat <= p_high AND
        ekpo~loekz <> 'L' AND ekpo~werks = plant AND
        ( ekko~bsart = 'ZB' OR ekko~bsart = 'ZNB' OR ekko~bsart = 'RZB' OR
        ekko~bsart = 'RZNB' ) AND
        ekpo~matnr = matnum AND
        ( ekbe~bwart = '908' OR ekbe~bwart = '101' OR ekbe~bwart = '162' )
  .
* Reduce in transit stock
  end_stock = end_stock - gm_qty.

  CLEAR gm_qty.


*-------------------------------------
* Check plant whether live or non live
*-------------------------------------
  SELECT SINGLE live FROM zplbc INTO p_live
  WHERE werks = plant AND live = 'X'.

*---------------------------------------------------
* If plant is EC non live
* Count intercompany GI quantity for non live branch
*---------------------------------------------------
  IF sy-subrc <> 0 AND plant(2) = '03'.
    CLEAR v_kunnr.
    CONCATENATE 'TSB' plant INTO v_kunnr.

* Get good issue quantity data
*-----------------------------
    SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
    FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
    WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
          mseg~bwart = '932'   AND
          mkpf~budat >= p_low AND mkpf~budat <= p_high.
    end_stock = end_stock + gm_qty.
    CLEAR gm_qty.

* Get cancel good issue quantity data
*------------------------------------
    SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
    FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
    WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
          mseg~bwart = '933'   AND
          mkpf~budat >= p_low AND mkpf~budat <= p_high.
    end_stock = end_stock - gm_qty.
    CLEAR gm_qty.
  ENDIF.

*-----------------------------------------------------------
* Routine for EC-HO -> EC-BRANCH sell purchase Goods Receipt
* Count GI quantity
*-----------------------------------------------------------
  CLEAR v_kunnr.
  CONCATENATE 'TBA' plant INTO v_kunnr.

  SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
  FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
  WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
        mseg~bwart = '901'   AND
        mkpf~budat >= p_low AND mkpf~budat <= p_high.
  end_stock = end_stock + gm_qty.
  CLEAR gm_qty.

  SELECT DISTINCT SUM( mseg~menge ) INTO gm_qty
  FROM ( mseg INNER JOIN mkpf ON mseg~mblnr = mkpf~mblnr
         AND mseg~mjahr = mkpf~mjahr )
  WHERE mseg~kunnr = v_kunnr AND mseg~matnr = matnum AND
        mseg~bwart = '902'   AND
        mkpf~budat >= p_low AND mkpf~budat <= p_high.
  end_stock = end_stock - gm_qty.
  CLEAR gm_qty.

ENDFORM.                    " F_MM_ENDING_STOCK_OLD

************************ OPP Report Enhancement ************************
*&---------------------------------------------------------------------*
*&      Form  CHECK_WEEK_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_date like sy-datum
FORM check_week_so
           USING p_date LIKE sy-datum
                 p_week LIKE zscust_opp-freq
                 p_low  LIKE sy-datum(2)
                 p_high LIKE sy-datum(2).

  DATA : day_p  TYPE p,
         l_date LIKE sy-datum.

  l_date = p_date. l_date+6(2) = '01'.

  day_p = l_date MOD 7.

  IF day_p > 1.
    day_p = day_p - 1.
  ELSE.
    day_p = day_p + 6.
  ENDIF.

  CASE day_p.
    WHEN 7. " Sunday
      IF p_date+6(2) BETWEEN '01' AND '07'.
        p_week = '1'. p_low = '01'. p_high = '07'.
      ELSEIF p_date+6(2) BETWEEN '08' AND '14'.
        p_week = '2'. p_low = '08'. p_high = '14'.
      ELSEIF p_date+6(2) BETWEEN '15' AND '21'.
        p_week = '3'. p_low = '15'. p_high = '21'.
      ELSEIF p_date+6(2) BETWEEN '22' AND '31'.
        p_week = '4'. p_low = '22'. p_high = '31'.
      ENDIF.
    WHEN 1. " Monday
      IF p_date+6(2) BETWEEN '01' AND '06'.
        p_week = '1'. p_low = '01'. p_high = '06'.
      ELSEIF p_date+6(2) BETWEEN '07' AND '13'.
        p_week = '2'. p_low = '07'. p_high = '13'.
      ELSEIF p_date+6(2) BETWEEN '14' AND '20'.
        p_week = '3'. p_low = '14'. p_high = '20'.
      ELSEIF p_date+6(2) BETWEEN '21' AND '31'.
        p_week = '4'. p_low = '21'. p_high = '31'.
      ENDIF.
    WHEN 2. " Tuesday
      IF p_date+6(2) BETWEEN '01' AND '05'.
        p_week = '1'. p_low = '01'. p_high = '05'.
      ELSEIF p_date+6(2) BETWEEN '06' AND '12'.
        p_week = '2'. p_low = '06'. p_high = '12'.
      ELSEIF p_date+6(2) BETWEEN '13' AND '19'.
        p_week = '3'. p_low = '13'. p_high = '19'.
      ELSEIF p_date+6(2) BETWEEN '20' AND '31'.
        p_week = '4'. p_low = '20'. p_high = '31'.
      ENDIF.
    WHEN 3. " Wed.
      IF p_date+6(2) BETWEEN '01' AND '11'.
        p_week = '1'. p_low = '01'. p_high = '11'.
      ELSEIF p_date+6(2) BETWEEN '12' AND '18'.
        p_week = '2'. p_low = '12'. p_high = '18'.
      ELSEIF p_date+6(2) BETWEEN '19' AND '25'.
        p_week = '3'. p_low = '19'. p_high = '25'.
      ELSEIF p_date+6(2) BETWEEN '26' AND '31'.
        p_week = '4'. p_low = '26'. p_high = '31'.
      ENDIF.
    WHEN 4. " Thursday
      IF p_date+6(2) BETWEEN '01' AND '10'.
        p_week = '1'. p_low = '01'. p_high = '10'.
      ELSEIF p_date+6(2) BETWEEN '11' AND '17'.
        p_week = '2'. p_low = '11'. p_high = '17'.
      ELSEIF p_date+6(2) BETWEEN '18' AND '24'.
        p_week = '3'. p_low = '18'. p_high = '24'.
      ELSEIF p_date+6(2) BETWEEN '25' AND '31'.
        p_week = '4'. p_low = '25'. p_high = '31'.
      ENDIF.
    WHEN 5. " Friday
      IF p_date+6(2) BETWEEN '01' AND '09'.
        p_week = '1'. p_low = '01'. p_high = '09'.
      ELSEIF p_date+6(2) BETWEEN '10' AND '16'.
        p_week = '2'. p_low = '10'. p_high = '16'.
      ELSEIF p_date+6(2) BETWEEN '17' AND '23'.
        p_week = '3'. p_low = '17'. p_high = '23'.
      ELSEIF p_date+6(2) BETWEEN '24' AND '31'.
        p_week = '4'. p_low = '24'. p_high = '31'.
      ENDIF.
    WHEN 6. " Sat.
      IF p_date+6(2) BETWEEN '01' AND '08'.
        p_week = '1'. p_low = '01'. p_high = '08'.
      ELSEIF p_date+6(2) BETWEEN '09' AND '15'.
        p_week = '2'. p_low = '09'. p_high = '15'.
      ELSEIF p_date+6(2) BETWEEN '16' AND '22'.
        p_week = '3'. p_low = '16'. p_high = '22'.
      ELSEIF p_date+6(2) BETWEEN '23' AND '31'.
        p_week = '4'. p_low = '23'. p_high = '31'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " CHECK_WEEK_SO

INCLUDE rmcssu05.

*&---------------------------------------------------------------------*
*&      Form  CALC_FREQ
*&---------------------------------------------------------------------*
FORM calc_freq USING xmckonv STRUCTURE mckonvb
                     xmcvbrk STRUCTURE mcvbrkb
                     xmcvbrp STRUCTURE mcvbrpb
                     xmcvbpa STRUCTURE mcvbpab
                     xmcvbuk STRUCTURE mcvbukb
                     xmcvbup STRUCTURE mcvbupb
             CHANGING fu_freq.

  CLEAR returncode.
  IF xmcvbrp-mvgr2 = '10' OR xmcvbrp-mvgr2 ='20'.
    SELECT SINGLE freq FROM zscust_opp
    INTO fu_freq
    WHERE vkorg = xmcvbrk-vkorg AND
        vtweg = xmcvbrk-vtweg AND
        kunnr = xmcvbrk-pkunwe.
  ELSE.
    SELECT SINGLE freq FROM zscust_opp
    INTO fu_freq
    WHERE vkorg = xmcvbrk-vkorg AND
        vtweg = xmcvbrk-vtweg AND
        kunnr = xmcvbrk-pkunwe AND
        matnr = xmcvbrp-matnr.
  ENDIF.
ENDFORM.                    "CALC_FREQ

*&---------------------------------------------------------------------*
*&      Form  CALC_CLASS
*&---------------------------------------------------------------------*
FORM calc_class USING xmckonv STRUCTURE mckonvb
                      xmcvbrk STRUCTURE mcvbrkb
                      xmcvbrp STRUCTURE mcvbrpb
                      xmcvbpa STRUCTURE mcvbpab
                      xmcvbuk STRUCTURE mcvbukb
                      xmcvbup STRUCTURE mcvbupb
             CHANGING fu_class.

  CLEAR returncode.
  IF xmcvbrp-mvgr2 = '10' OR xmcvbrp-mvgr2 ='20'.
    SELECT SINGLE class FROM zscust_opp
    INTO fu_class
    WHERE vkorg = xmcvbrk-vkorg AND
       vtweg = xmcvbrk-vtweg AND
       kunnr = xmcvbrk-pkunwe.
  ELSE.
    SELECT SINGLE class FROM zscust_opp
    INTO fu_class
    WHERE vkorg = xmcvbrk-vkorg AND
       vtweg = xmcvbrk-vtweg AND
       kunnr = xmcvbrk-pkunwe AND
       matnr = xmcvbrp-matnr.
  ENDIF.
ENDFORM.                    "CALC_CLASS

*&---------------------------------------------------------------------*
*&      Form  f_warning_batch
*&---------------------------------------------------------------------*
*       PP perform
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_warning_batch USING ft_matnr LIKE mch1-matnr
                           ft_werks LIKE mcha-werks
                           ft_charg LIKE mch1-charg
                     CHANGING ft_error TYPE i.

  DATA: ld_werks     LIKE mcha-werks,
        ld_mess(100).

  SELECT SINGLE werks
    FROM mcha
    INTO ld_werks
    WHERE matnr EQ ft_matnr AND
          werks NE ft_werks AND
          charg EQ ft_charg.

  IF sy-subrc EQ 0.
    ft_error = 1.
    IF sy-tcode EQ 'COR8'.
      CONCATENATE 'Batch' ft_charg 'for material' ft_matnr INTO ld_mess
      SEPARATED BY space.
      CONCATENATE ld_mess 'already exist in plant' ld_werks INTO ld_mess
      SEPARATED BY space.

      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
        EXPORTING
          popup_title  = 'Warning'
          is_error     = space
          message_text = ld_mess
          start_column = 25
          start_row    = 6.
    ELSE.
      MESSAGE i001(zab) WITH ft_charg
                             ft_matnr
                             ld_werks.
    ENDIF.
  ELSE.
    SELECT SINGLE werks
      FROM mcha
      INTO ld_werks
      WHERE matnr EQ ft_matnr AND
            werks EQ ft_werks AND
            charg EQ ft_charg.
    IF sy-subrc EQ 0.
      MESSAGE e001(zab) WITH ft_charg
                             ft_matnr
                             ld_werks.
    ELSE.
      ft_error = 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_warning_batch

*&---------------------------------------------------------------------*
*&      Form  f_change_batch
*&---------------------------------------------------------------------*
*       PP perform
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_batch USING ft_matnr LIKE mch1-matnr
                          ft_charg LIKE mch1-charg.

  DATA: BEGIN OF t_mch1 OCCURS 0.
          INCLUDE STRUCTURE mch1.
        DATA: END OF t_mch1.

  SELECT *
    FROM mch1
    INTO CORRESPONDING FIELDS OF TABLE t_mch1
    WHERE matnr EQ ft_matnr AND
          charg EQ ft_charg.

  IF sy-subrc EQ 0.
    LOOP AT t_mch1.
      t_mch1-hsdat = '00000000'.
      t_mch1-vfdat = '00000000'.
      MODIFY t_mch1 TRANSPORTING hsdat vfdat.

      CALL FUNCTION 'VB_UPDATE_BATCH' IN UPDATE TASK
        TABLES
*         ZMCHA =
          zmch1 = t_mch1.
*     ZMCHB         =
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_change_batch

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_GUDANG2
*&---------------------------------------------------------------------*
FORM f_validate_gudang2  USING    fw_mseg LIKE mseg
                         CHANGING fc_error.

  FIELD-SYMBOLS: <fs> TYPE any.
  DATA: BEGIN OF lt_gudang OCCURS 0.
          INCLUDE STRUCTURE zmgudang.
          DATA:   error TYPE i.
  DATA: END OF lt_gudang.
  DATA: ld_agr_name   LIKE agr_users-agr_name,
        ld_text       LIKE agr_texts-text,
        dfies_tab     LIKE dfies OCCURS 0 WITH HEADER LINE,
        tabname       TYPE ddobjname,
        f_field(100),
        f_field1(100).

  DATA: material            LIKE bapi_mara_ga-material,
        plant               LIKE bapi_marc_ga-plant,
        stge_loc            LIKE bapi_mard_ga-stge_loc,
        clientdata          LIKE bapi_mara_ga,
        plantdata           LIKE bapi_marc_ga,
        storagelocationdata LIKE bapi_mard_ga,
        return              LIKE bapireturn OCCURS 0 WITH HEADER LINE.

  RANGES: ra_field FOR zmgudang-zvaluename.

  SELECT werks lgort zseq zcode dbtabname fieldname rollname zvaluename datab datbi
    FROM zmgudang
    INTO CORRESPONDING FIELDS OF TABLE lt_gudang
    WHERE werks EQ fw_mseg-werks AND
          lgort EQ fw_mseg-lgort AND
          datab LE sy-datum      AND
          datbi GE sy-datum.

  IF sy-subrc EQ 0.
    LOOP AT lt_gudang.
      f_field1         = lt_gudang-zvaluename.
      ra_field-low     = lt_gudang-zvaluename.
      ra_field-sign    = 'I'.
      ra_field-option  = 'CP'.
      APPEND ra_field.
      material  = fw_mseg-matnr.
      plant     = fw_mseg-werks.
      stge_loc  = fw_mseg-lgort.

      CALL FUNCTION 'BAPI_MATERIAL_GET_ALL'
        EXPORTING
          material            = material
          plant               = plant
          stge_loc            = stge_loc
        IMPORTING
          clientdata          = clientdata
          plantdata           = plantdata
          storagelocationdata = storagelocationdata
        TABLES
          return              = return.

      READ TABLE return WITH KEY code = 'MM370'.
      IF sy-subrc EQ 0.
        fc_error  = 1.
      ELSE.
        READ TABLE return WITH KEY code = 'M3103'.
        IF sy-subrc EQ 0.
          fc_error  = 1.
        ELSE.
          CONCATENATE 'BAPI_' lt_gudang-dbtabname '_GA' INTO tabname.
          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname   = tabname
              langu     = sy-langu
            TABLES
              dfies_tab = dfies_tab.
          IF sy-subrc EQ 0.
            READ TABLE dfies_tab WITH KEY rollname = lt_gudang-rollname.
            IF sy-subrc EQ 0.
              CONCATENATE 'CLIENTDATA' '-' dfies_tab-fieldname INTO f_field.
              ASSIGN (f_field) TO <fs>.
              IF sy-subrc EQ 0.
                f_field = <fs>.
              ELSE.
                CONCATENATE 'PLANTDATA' '-' dfies_tab-fieldname INTO f_field.
                ASSIGN (f_field) TO <fs>.
                IF sy-subrc EQ 0.
                  f_field = <fs>.
                ELSE.
                  CONCATENATE 'STORAGELOCATIONDATA' '-' dfies_tab-fieldname INTO f_field.
                  ASSIGN (f_field) TO <fs>.
                  IF sy-subrc EQ 0.
                    f_field = <fs>.
                  ELSE.
                    fc_error  = 1.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              fc_error  = 1.
            ENDIF.
            IF f_field IN ra_field.
              lt_gudang-error  = 0.
            ELSE.
              lt_gudang-error  = 1.
            ENDIF.
            MODIFY lt_gudang TRANSPORTING error.
          ELSE.
            fc_error  = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    READ TABLE lt_gudang WITH KEY error = 0.
    IF sy-subrc EQ 0.
      SELECT SINGLE a~agr_name b~text
        FROM agr_users AS a JOIN agr_texts AS b ON a~agr_name EQ b~agr_name
        INTO (ld_agr_name, ld_text)
        WHERE a~agr_name LIKE 'Z_PTT_MM%' AND
              a~uname    EQ sy-uname      AND
              a~from_dat LE sy-datum      AND
              a~to_dat   GE sy-datum      AND
              a~exclude  EQ space         AND
              b~spras    EQ sy-langu      AND
              b~text     LIKE 'Z_PTT_MM_GUDANG%'.
      IF sy-subrc NE 0.
        fc_error  = 1.
      ENDIF.
    ELSE.
      fc_error  = 1.
    ENDIF.
  ELSE.
  ENDIF.
ENDFORM.                    " F_VALIDATE_GUDANG2

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_452
*&---------------------------------------------------------------------*
FORM f_check_452 USING fu_xblnr fu_charg fu_kunnr fu_matnr fu_werks fu_menge.
  DATA: lt_mseg  LIKE mseg OCCURS 0 WITH HEADER LINE,
        ld_menge LIKE mseg-menge,
        ld_lines TYPE i,
        ld_mblnr LIKE mseg-mblnr,
        ld_charg LIKE mseg-charg,
        ld_kunnr LIKE mseg-kunnr.

  ld_lines  = strlen( fu_xblnr ).
  IF ld_lines EQ 15.
    IF fu_xblnr+10(1) NE '/'.
      MESSAGE e000(zab) WITH 'Material slip Error'.
    ELSE.
      ld_mblnr  = fu_xblnr(10).

      SELECT mkpf~mblnr mkpf~mjahr zeile bwart matnr charg kunnr menge
        FROM mkpf INNER JOIN mseg ON mkpf~mandt = mseg~mandt AND
                                     mkpf~mblnr = mseg~mblnr AND
                                     mkpf~mjahr = mseg~mjahr
        INTO CORRESPONDING FIELDS OF TABLE lt_mseg
        WHERE bwart IN ('451', '452') AND
              matnr EQ fu_matnr       AND
              werks EQ fu_werks       AND
              kunnr EQ fu_kunnr       AND
              charg EQ fu_charg.

      READ TABLE lt_mseg WITH KEY mblnr = ld_mblnr.
      IF sy-subrc EQ 0.
        LOOP AT lt_mseg.
          IF lt_mseg-bwart EQ '452'.
            lt_mseg-menge  = lt_mseg-menge * -1.
          ENDIF.
          ADD lt_mseg-menge TO ld_menge.
        ENDLOOP.
        IF ld_menge LT fu_menge.
          MESSAGE e000(zab) WITH 'Deficit of BA'.
        ENDIF.
      ELSE.
        MESSAGE e000(zab) WITH 'Customer/Material/Batch Error'.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Material slip Error'.
  ENDIF.
ENDFORM.                    " F_CHECK_452

*&---------------------------------------------------------------------*
*&      Form  F_CEK_PO
*&---------------------------------------------------------------------*
FORM f_cek_po  USING    lwa_ekpo STRUCTURE ekpo
                        fu_ebeln
               CHANGING fc_error.

  DATA: lv_bednr TYPE ebeln,
        lv_matnr TYPE matnr,
        lv_menge TYPE bstmg,
        lv_lewed TYPE lewed,
        lv_loekz TYPE eloek,
        lv_name  TYPE tdobname.

  DATA: lwa_zsubheader   LIKE bapimepoheader.
  DATA: lt_zsubitem LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_return   LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        lt_lines    LIKE tline OCCURS 0 WITH HEADER LINE.

  lv_name   = fu_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = sy-langu
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE lt_lines INDEX 1.
  IF sy-subrc EQ 0.
    lv_bednr = lt_lines-tdline(10).
  ENDIF.

  IF lwa_ekpo-bednr IS NOT INITIAL.
    lv_bednr  = lwa_ekpo-bednr.

    SELECT SINGLE matnr menge lewed loekz
      FROM ekpo
      INTO (lv_matnr, lv_menge, lv_lewed, lv_loekz)
      WHERE ebeln EQ lv_bednr
        AND ebelp EQ lwa_ekpo-ebelp.

    IF sy-subrc EQ 0.
      IF lv_matnr NE lwa_ekpo-matnr.
        fc_error  = '1'.
      ENDIF.
      CHECK fc_error IS INITIAL.
      IF lv_menge NE lwa_ekpo-menge.
        fc_error  = '2'.
      ENDIF.
      CHECK fc_error IS INITIAL.
      IF lv_lewed NE lwa_ekpo-lewed.
        fc_error  = '3'.
      ENDIF.
      CHECK fc_error IS INITIAL.
      IF lv_loekz NE lwa_ekpo-loekz.
        fc_error  = '4'.
      ENDIF.
    ELSE.
      fc_error = '5'.
    ENDIF.
  ELSE.
    IF lv_bednr IS NOT INITIAL.
      fc_error  = '6'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CEK_PO

*&---------------------------------------------------------------------*
*&      Form  F_NEW_BKTXT_VAL
*&---------------------------------------------------------------------*
FORM f_new_bktxt_val  USING    fu_bktxt.
  DATA : lv_val01 TYPE string,
         lv_val02 TYPE string,
         lv_val03 TYPE string,
         lv_val04 TYPE string,
         lv_val05 TYPE string,
         lv_val06 TYPE string.

  DATA : lv_pattern(25) VALUE '++++/+++/++/++-++.++.++++',
         lv_mess(100)   VALUE 'Format Dok.Header Text XXXX/PAP/MM/YY-DD.MM.YYYY',
         lv_length      TYPE i,
         lv_datum       TYPE sy-datum,
         lv_gjalo(2),
         lv_gjahi(2).

  IF fu_bktxt IS INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ELSE.
    IF fu_bktxt NP lv_pattern.
      MESSAGE e000(zab) WITH lv_mess.
    ELSE.
      SPLIT fu_bktxt AT '/' INTO lv_val01 lv_val02 lv_val03 lv_val04.

      SPLIT lv_val04 AT '-' INTO lv_val05 lv_val06.

      IF lv_val01 CN '0123456789'.
        MESSAGE e000(zab) WITH lv_mess.
      ELSE.
        CLEAR lv_length.
        lv_length = strlen( lv_val01 ).
        IF lv_length <> 4.
          MESSAGE e000(zab) WITH lv_mess.
        ENDIF.
      ENDIF.

      IF lv_val02 <> 'PAP'.
        MESSAGE e000(zab) WITH lv_mess.
      ENDIF.

      CLEAR lv_datum.
      CONCATENATE '9999' lv_val03 '01' INTO lv_datum.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_datum
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH lv_mess.
      ENDIF.

      CLEAR lv_datum.
      lv_gjahi  = sy-datum+2(2).
      CONCATENATE sy-datum(4) '0101' INTO lv_datum.
      lv_datum  = lv_datum - 1.
      lv_gjalo  = lv_datum+2(2).
      IF lv_val05 BETWEEN lv_gjalo AND lv_gjahi.
      ELSE.
        MESSAGE e000(zab) WITH lv_mess.
      ENDIF.

      CLEAR lv_datum.
      CONCATENATE lv_val06+6(4) lv_val06+3(2) lv_val06(2) INTO lv_datum.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_datum
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH lv_mess.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEW_BKTXT_VAL

*&---------------------------------------------------------------------*
*&      Form  F_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM f_variant_check  TABLES   ft_tvarvc STRUCTURE tvarvc
                      USING    fu_ebeln
                      CHANGING fc_subrc.
  DATA : ls_tvarvc TYPE tvarvc,
         lr_ebeln  TYPE RANGE OF ebeln,
         ls_ebeln  LIKE LINE OF lr_ebeln.

  fc_subrc = 4.
  LOOP AT ft_tvarvc INTO ls_tvarvc.
    CLEAR lr_ebeln[].
    IF ls_tvarvc-sign = 'I' OR
      ls_tvarvc-sign = 'E'.
      IF ls_tvarvc-low IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_tvarvc-low
          IMPORTING
            output = ls_ebeln-low.
      ENDIF.

      IF ls_tvarvc-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_tvarvc-high
          IMPORTING
            output = ls_ebeln-high.
        IF ls_tvarvc-opti = 'EQ'.
          CLEAR ls_ebeln-high.
        ENDIF.
      ELSEIF ls_tvarvc-high IS INITIAL AND
        ls_tvarvc-opti = 'BT'.
        ls_ebeln-high = ls_ebeln-low.
      ENDIF.

      ls_ebeln-sign   = ls_tvarvc-sign.
      ls_ebeln-option = ls_tvarvc-opti.
      APPEND ls_ebeln TO lr_ebeln.
      CLEAR ls_ebeln.
      IF fu_ebeln IN lr_ebeln.
        CLEAR fc_subrc.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
