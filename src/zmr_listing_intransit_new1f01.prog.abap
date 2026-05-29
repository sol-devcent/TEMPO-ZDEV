*&---------------------------------------------------------------------*
*&  Include           ZMR_LISTING_INTRANSIT_NEW1F01
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       Ereigniss USER_COMMAND                                        *
*       event     USER_COMMAND
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
  DATA feld(10) TYPE c.
  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      READ TABLE itab INDEX rs_selfield-tabindex.
      IF rs_selfield-sel_tab_field EQ 'ITAB-MBLNR'.
        IF itab-bwart = '303' OR itab-bwart EQ '313' OR itab-bwart EQ '351'.
          SET PARAMETER ID 'MBN' FIELD itab-mblnr.
          SET PARAMETER ID 'MJA' FIELD itab-mjahr.
          CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
        ELSEIF itab-bwart = '641'.
          SET PARAMETER ID 'VL' FIELD itab-mblnr.
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
*          elseif itab-bwart = '161'.
*            set parameter id 'BES' field itab-ebeln.
*            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  DATA : l_fyear LIKE mkpf-mjahr,
         l_tyear LIKE mkpf-mjahr,
         l_bwart LIKE mseg-bwart,
         l_sw    LIKE sy-subrc,
         l_mblnr LIKE mseg-mblnr.

  DATA: BEGIN OF i_mblnr OCCURS 0,
          mblnr LIKE mseg-mblnr,
          mjahr LIKE mseg-mjahr,
        END OF i_mblnr.

  DATA: BEGIN OF i_xblnr351 OCCURS 0,
          xblnr LIKE mkpf-xblnr,
          mjahr LIKE mkpf-mjahr,
        END OF i_xblnr351.

  DATA: BEGIN OF i_xblnr OCCURS 0,
          xblnr LIKE mkpf-xblnr,
        END OF i_xblnr.

  DATA: BEGIN OF i_sgtxt OCCURS 0,
          sgtxt LIKE mseg-sgtxt,
        END OF i_sgtxt.

  DATA   : i303641_detail LIKE i303641 OCCURS 0,
           p_werks1       LIKE t001l-werks,
           p_lgort1       LIKE t001l-lgort.

  l_fyear = p_budat-low(4).
  l_tyear = p_budat-high(4).

** Select Nama Cabang
  SELECT SINGLE name1 FROM t001w INTO v_name1
    WHERE werks = p_werks.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '00'
      text       = 'Data is being read...'.
*------------------------------------------------------*
** Select Live Flag
  SELECT * FROM zplbc
    INTO CORRESPONDING FIELDS OF TABLE i_zplbc
    WHERE bukrs = p_bukrs AND
          werks = p_werks AND
          lgort = '1000'.
*          lgort = p_lgort.

  PERFORM f_get_customer.

  CASE p_werks.
    WHEN '0225'.
      p_werks1 = '0222'.
      p_lgort1 = '2000'.
    WHEN '0231'.
      p_werks1 = '0230'.
      p_lgort1 = '2000'.
    WHEN '0232'.
      p_werks1 = '0230'.
      p_lgort1 = '2100'.
    WHEN '0234'.
      p_werks1 = '0230'.
      p_lgort1 = '2200'.
    WHEN '0253'.
      p_werks1 = '0252'.
      p_lgort1 = '2000'.
    WHEN '0281'.
      p_werks1 = '0280'.
      p_lgort1 = '2000'.
    WHEN '0282'.
      p_werks1 = '0280'.
      p_lgort1 = '2100'.
    WHEN '0291'.
      p_werks1 = '0290'.
      p_lgort1 = '2100'.
    WHEN '0292'.
      p_werks1 = '0290'.
      p_lgort1 = '2000'.
  ENDCASE.
** Select Nomor Transaksi
  SELECT DISTINCT a~mblnr a~mjahr a~budat a~bldat a~xblnr
                  a~bktxt b~umwrk b~umlgo b~werks b~lgort
                  b~bwart b~ebeln b~kunnr "b~ebelp
    FROM mkpf AS a JOIN mseg AS b ON a~mblnr = b~mblnr AND
                                     a~mjahr = b~mjahr
    INTO CORRESPONDING FIELDS OF TABLE i_mkpf
    WHERE a~budat IN p_budat AND
          a~bldat IN p_bldat AND
          b~bukrs = p_bukrs  AND
          b~bwart IN p_bwart AND
          b~umwrk = p_werks  AND
          ( b~mjahr GE l_fyear AND b~mjahr LE l_tyear ) AND
          b~matnr IN p_matnr AND
*          b~umlgo in p_lgort and
          b~xauto = space
    ORDER BY b~bwart a~mblnr a~mjahr.

  IF gr_kunnr IS NOT INITIAL.
    SELECT DISTINCT a~mblnr a~mjahr a~budat a~bldat a~xblnr
                    a~bktxt b~umwrk b~umlgo b~werks b~lgort
                    b~bwart b~ebeln b~kunnr "b~ebelp
      FROM mkpf AS a JOIN mseg AS b ON a~mblnr = b~mblnr AND
                                       a~mjahr = b~mjahr
      APPENDING CORRESPONDING FIELDS OF TABLE i_mkpf
      WHERE a~budat IN p_budat AND
            a~bldat IN p_bldat AND
            b~bwart IN p_bwart AND
            b~umwrk = space  AND
            ( b~mjahr GE l_fyear AND b~mjahr LE l_tyear ) AND
            b~matnr IN p_matnr AND
            b~kunnr IN gr_kunnr AND
            b~xauto = space
      ORDER BY b~bwart a~mblnr a~mjahr.

*    SELECT SINGLE werks lgort INTO (p_werks1, p_lgort1)
*      FROM t001l
*      WHERE kunnr IN gr_kunnr.
  ENDIF.
*  IF sy-subrc <> 0.
  IF i_mkpf[] IS INITIAL.
    MESSAGE s260(aq).
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL FUNCTION 'VIEW_GET_DATA'
    EXPORTING
      view_name = 'V_T001L_L'
    TABLES
      data      = i_v_t001l_l.
  DELETE i_v_t001l_l WHERE werks NE p_werks.

  LOOP AT i_mkpf.

    SELECT SINGLE mblnr FROM mseg INTO l_mblnr
      WHERE smbln = i_mkpf-mblnr AND
            sjahr = i_mkpf-mjahr.

    IF sy-subrc = 0.
      DELETE i_mkpf WHERE bwart = i_mkpf-bwart AND
                          mblnr = i_mkpf-mblnr AND
                          mjahr = i_mkpf-mjahr.
      CONTINUE.
    ENDIF.

** Append Range MBLNR
    i_mblnr-mblnr = i_mkpf-mblnr.
    APPEND i_mblnr.

    IF i_mkpf-bwart = '351'.
      i_xblnr351-xblnr = i_mkpf-mblnr.
      i_xblnr351-mjahr = i_mkpf-mjahr.
      APPEND i_xblnr351.
    ENDIF.

    CASE i_mkpf-bwart.
      WHEN '303' OR '313'.
** Append Range SGTXT
        CONCATENATE i_mkpf-mblnr '/' i_mkpf-mjahr INTO i_sgtxt-sgtxt.
        APPEND i_sgtxt.
        IF i_mkpf-kunnr IS NOT INITIAL.
          i_kunnr-kunnr = i_mkpf-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ELSE.
          CLEAR: i_v_t001l_l.
          READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                          lgort = i_mkpf-umlgo.
          i_kunnr-kunnr = i_v_t001l_l-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ENDIF.
      WHEN '641' OR '351' OR '907'.
** Append Range XBLNR
        i_xblnr-xblnr = i_mkpf-xblnr.
        APPEND i_xblnr.
        CLEAR: i_mkpf-tknum, i_mkpf-erdat, i_mkpf-gesztd.
*        SELECT SINGLE tknum erdat FROM vttp INTO (i_mkpf-tknum, i_mkpf-erdat)
        SELECT SINGLE tknum FROM vttp INTO i_mkpf-tknum
          WHERE vbeln = i_mkpf-xblnr.
        IF sy-subrc = 0.
          SELECT SINGLE datbg gesztd exti1 exti2 tdlnr
            FROM vttk
            INTO (i_mkpf-erdat, i_mkpf-gesztd, i_mkpf-exti1, i_mkpf-exti2,
                  i_mkpf-tdlnr)
            WHERE tknum = i_mkpf-tknum.
          SELECT SINGLE name1 INTO i_mkpf-vndnam
            FROM lfa1 WHERE lifnr = i_mkpf-tdlnr.
        ENDIF.
        IF i_mkpf-kunnr IS NOT INITIAL.
          i_kunnr-kunnr = i_mkpf-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ELSE.
          CLEAR: i_v_t001l_l.
          READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                          lgort = i_mkpf-umlgo.
          i_kunnr-kunnr = i_v_t001l_l-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ENDIF.
    ENDCASE.

    SELECT SINGLE kunnr INTO i_mkpf-cuspo
      FROM ekpo WHERE ebeln = i_mkpf-ebeln.

    SELECT SINGLE name1 INTO i_mkpf-cusnam
      FROM kna1 WHERE kunnr = i_mkpf-cuspo.

    MODIFY i_mkpf.

  ENDLOOP.

  IF i_kunnr[] IS NOT INITIAL.
    SELECT kunnr name3
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FROM kna1
      FOR ALL ENTRIES IN i_kunnr
      WHERE kunnr = i_kunnr-kunnr.
  ENDIF.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '20'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DESCRIBE TABLE i_mblnr LINES l_sw.
  IF l_sw > 0.
** Select Data 303 & 641
    IF i_mblnr[] IS NOT INITIAL.
      SELECT bwart mblnr matnr menge dmbtr zeile ebeln lgort"ebelp
        FROM mseg INTO CORRESPONDING FIELDS OF TABLE i303641_detail
        FOR ALL ENTRIES IN i_mblnr
        WHERE
*            bukrs = p_bukrs                           and
*            bwart in p_bwart                          and
             ( umwrk = p_werks OR umwrk = space )       AND
              mblnr = i_mblnr-mblnr                     AND
              ( mjahr GE l_fyear AND mjahr LE l_tyear ) AND
              matnr IN p_matnr                          AND
*            umlgo in p_lgort                          and
              xauto = space
*      group by bwart mblnr matnr.
      %_HINTS DB6 'USE_OPTLEVEL 0'.

      IF sy-subrc <> 0.
        MESSAGE s260(aq).
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

    SORT i303641_detail BY bwart mblnr ebeln matnr.
*  Sort i303641_detail by bwart mblnr matnr.

    LOOP AT i303641_detail INTO i303641.
      i303641-zeile = ''.
*    i303641-ebeln = ''.
      COLLECT i303641.
    ENDLOOP.

    REFRESH : i303641_detail.
  ENDIF.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '40'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  LOOP AT p_bwart.
    CASE p_bwart-low.

      WHEN '303'.
** Select Data 305
        IF i_sgtxt[] IS NOT INITIAL.
          SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
            FROM mseg INTO TABLE i_305_detail
            FOR ALL ENTRIES IN i_sgtxt
            WHERE werks = p_werks  AND
                  bwart = '305'    AND
                  xauto = ''       AND
                  sgtxt = i_sgtxt-sgtxt AND
*                  lgort IN p_lgort AND
                  matnr IN p_matnr.
          IF p_werks1 IS NOT INITIAL.
            SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
            FROM mseg APPENDING TABLE i_305_detail
            FOR ALL ENTRIES IN i_sgtxt
            WHERE werks = p_werks1  AND
                  bwart = '305'    AND
                  xauto = ''       AND
                  sgtxt = i_sgtxt-sgtxt AND
*                   lgort IN p_lgort AND
                  matnr IN p_matnr.
          ENDIF.
          LOOP AT i_305_detail.
            SELECT SINGLE mblnr INTO v_mblnr FROM mseg
            WHERE sjahr = i_305_detail-mjahr AND
                  smbln = i_305_detail-mblnr AND
                  smblp = i_305_detail-zeile.
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING i_305_detail TO i_305.
              SELECT SINGLE cpudt budat FROM mkpf
                INTO CORRESPONDING FIELDS OF i_305
                WHERE mblnr = i_305-mblnr.
              COLLECT i_305.
            ENDIF.
          ENDLOOP.
          SORT i_305 BY bwart sgtxt matnr mblnr.
          REFRESH i_305_detail.
        ENDIF.

      WHEN '313'.
** Select Data 315
        IF i_sgtxt[] IS NOT INITIAL.
          SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
            FROM mseg INTO TABLE i_315_detail
            FOR ALL ENTRIES IN i_sgtxt
            WHERE werks = p_werks  AND
                  bwart = '315'    AND
                  xauto = ''       AND
                  sgtxt = i_sgtxt-sgtxt AND
                  lgort IN p_lgort AND
                  matnr IN p_matnr.
          IF p_werks1 IS NOT INITIAL.
            SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
            FROM mseg APPENDING TABLE i_315_detail
            FOR ALL ENTRIES IN i_sgtxt
            WHERE werks = p_werks1  AND
                  bwart = '315'    AND
                  xauto = ''       AND
                  sgtxt = i_sgtxt-sgtxt AND
                  lgort = p_lgort1 AND
                  matnr IN p_matnr.
          ENDIF.
          LOOP AT i_315_detail.
            SELECT SINGLE mblnr INTO v_mblnr FROM mseg
            WHERE sjahr = i_315_detail-mjahr AND
                  smbln = i_315_detail-mblnr AND
                  smblp = i_315_detail-zeile.
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING i_315_detail TO i_315.
              SELECT SINGLE cpudt budat FROM mkpf
                INTO CORRESPONDING FIELDS OF i_315
                WHERE mblnr = i_315-mblnr.
              COLLECT i_315.
            ENDIF.
          ENDLOOP.
          SORT i_315 BY bwart sgtxt matnr mblnr.
          REFRESH i_315_detail.
        ENDIF.

      WHEN '641' OR '907'.
* Select Data 101
        IF i_xblnr[] IS NOT INITIAL.
          SELECT bwart xblnr matnr gjahr belnr buzei menge dmbtr ebeln "ebelp
            FROM ekbe INTO TABLE i_101_detail
            FOR ALL ENTRIES IN i_xblnr
            WHERE werks = p_werks  AND
                  bwart = '101'    AND
                  xblnr = i_xblnr-xblnr AND
                  matnr IN p_matnr.
          IF p_werks1 IS NOT INITIAL.
            SELECT bwart xblnr matnr gjahr belnr buzei menge dmbtr ebeln "ebelp
            FROM ekbe APPENDING TABLE i_101_detail
            FOR ALL ENTRIES IN i_xblnr
            WHERE werks = p_werks1  AND
                 bwart = '101'    AND
                 xblnr = i_xblnr-xblnr AND
                 matnr IN p_matnr.
          ENDIF.
          LOOP AT i_101_detail.
            SELECT SINGLE mblnr INTO v_mblnr FROM mseg
            WHERE sjahr = i_101_detail-gjahr AND
                  smbln = i_101_detail-belnr AND
                  smblp = i_101_detail-buzei.
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING i_101_detail TO i_101.
              SELECT SINGLE cpudt budat FROM mkpf
                INTO CORRESPONDING FIELDS OF i_101
                WHERE mblnr = i_101-belnr.
              COLLECT i_101.
            ENDIF.
          ENDLOOP.
*        Sort i_101 by bwart xblnr matnr belnr.
          SORT i_101 BY bwart xblnr matnr ebeln belnr. "ebelp.
          REFRESH i_101_detail.
        ENDIF.

      WHEN '351'.
* Select Data 101
        IF i_xblnr351[] IS NOT INITIAL.
          SELECT a~xblnr bwart matnr a~mjahr a~mblnr zeile menge dmbtr ablad
            FROM mkpf AS a JOIN mseg AS b ON b~mblnr = a~mblnr AND
                                             b~mjahr = a~mjahr
            INTO CORRESPONDING FIELDS OF TABLE i_351_detail
            FOR ALL ENTRIES IN i_xblnr351
            WHERE a~xblnr = i_xblnr351-xblnr AND
*                  a~mjahr = i_xblnr351-mjahr AND
                  bukrs = p_bukrs  AND
                  werks = p_werks  AND
                  bwart = '101'    AND
                  xauto = ''       AND
                  lgort IN p_lgort AND
                  matnr IN p_matnr.
          LOOP AT i_351_detail.
            IF i_351_detail-ablad IS NOT INITIAL.
              i_351_detail-xblnr = i_351_detail-ablad.
            ENDIF.
            SELECT SINGLE mblnr INTO v_mblnr FROM mseg
              WHERE sjahr = i_351_detail-mjahr AND
                    smbln = i_351_detail-mblnr AND
                    smblp = i_351_detail-zeile.
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING i_351_detail TO i_351.
              SELECT SINGLE cpudt budat FROM mkpf
                INTO CORRESPONDING FIELDS OF i_351
                WHERE mblnr = i_351-mblnr.
              COLLECT i_351.
            ENDIF.
          ENDLOOP.
          SORT i_351 BY bwart xblnr matnr mblnr.
          REFRESH i_351_detail.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA : l_bwart  LIKE mseg-bwart,
         l_live   LIKE zplbc-live,
         l_sw     LIKE sy-subrc,
         a        LIKE sy-tabix,
         b        LIKE sy-tabix,
         c        LIKE sy-tabix,
         sw_1(1), sw_2(1),
         lv_menge LIKE mseg-menge.

  DATA: ld_flag  TYPE i.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '80'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  LOOP AT i_mkpf.

    CLEAR itab.
    MOVE-CORRESPONDING i_mkpf TO itab.

    IF i_mkpf-umwrk IS INITIAL.
      SELECT SINGLE werks FROM ekpo INTO i_mkpf-umwrk
        WHERE ebeln = i_mkpf-ebeln.
      itab-umwrk = i_mkpf-umwrk.
    ENDIF.

    IF itab-umwrk NE p_werks.
      CONTINUE.
    ENDIF.

    IF i_mkpf-kunnr(3) = 'TBA'.
      CLEAR: i_kna1,i_v_t001l_l.
      READ TABLE i_kna1 WITH KEY kunnr = i_mkpf-kunnr.
      itab-name3 = i_kna1-name3.
      READ TABLE i_v_t001l_l WITH KEY kunnr = i_mkpf-kunnr.
      IF sy-subrc NE 0.
        SELECT SINGLE lgort FROM ekpo INTO itab-umlgo
          WHERE ebeln = i_mkpf-ebeln.
      ELSE.
        itab-umlgo = i_v_t001l_l-lgort.
      ENDIF.
    ELSEIF i_mkpf-kunnr IS INITIAL.
      CLEAR: i_kna1,i_v_t001l_l.
      READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                      lgort = i_mkpf-umlgo.
      READ TABLE i_kna1 WITH KEY kunnr = i_v_t001l_l-kunnr.
      itab-name3 = i_kna1-name3.
      itab-kunnr = i_v_t001l_l-kunnr.
    ENDIF.

*  if itab-kunnr not in p_kunnr.
*    continue.
*  endif.

    itab-etdat = itab-erdat + ( i_mkpf-gesztd / 240000 ).

** Baca Table ZPLBC
    CLEAR l_live.
    READ TABLE i_zplbc WITH KEY bukrs = p_bukrs
                                werks = i_mkpf-umwrk.
*                              lgort = i_mkpf-umlgo.
    l_live = i_zplbc-live.

** Baca Table 303 &  641
    READ TABLE i303641 WITH KEY bwart = i_mkpf-bwart
                                mblnr = i_mkpf-mblnr
                                lgort = i_mkpf-lgort
                                ebeln = i_mkpf-ebeln BINARY SEARCH.
*                              ebelp = i_mkpf-ebelp binary search.
*  read table i303641 with key bwart = i_mkpf-bwart
*                              mblnr = i_mkpf-mblnr binary search.
    a = sy-tabix.

    LOOP AT i303641 FROM a.

      IF i303641-bwart = i_mkpf-bwart AND
         i303641-mblnr = i_mkpf-mblnr AND
         i303641-lgort = i_mkpf-lgort AND
         i303641-ebeln = i_mkpf-ebeln.
*       i303641-ebelp = i_mkpf-ebelp.
*    if i303641-bwart = i_mkpf-bwart and
*       i303641-mblnr = i_mkpf-mblnr.
      ELSE.
        EXIT.
      ENDIF.

      CLEAR: itab-matnr, itab-maktx, itab-menge, itab-dmbtr, itab-nsp,
             itab-bwart1, itab-mblnr1, itab-matnr1, itab-maktx1,
             itab-menge1, itab-dmbtr1, itab-bbkno, itab-cpudt1,
             itab-budat1, itab-leadt.

      MOVE-CORRESPONDING i303641 TO itab.
      itab-nsp = ( itab-dmbtr * 100 / itab-menge ).
      CONCATENATE itab-mblnr '/' itab-mjahr INTO itab-sgtxt.
      SELECT SINGLE maktx FROM makt INTO itab-maktx
        WHERE matnr = itab-matnr.

      CASE i303641-bwart.

* Mvt Type 303
        WHEN '303'.
          CLEAR i_305.
          IF p_bukrs EQ '8070'.
            itab-bbkno = i_mkpf-bktxt+3(5).
          ELSE.
            itab-bbkno = i_mkpf-bktxt+7(5).
          ENDIF.
          READ TABLE i_305 WITH KEY bwart = '305'
                                    sgtxt = itab-sgtxt
                                    matnr = itab-matnr BINARY SEARCH.
          b = sy-tabix.

*        if sy-subrc = 0.
*          select single mblnr into i_305-mblnr from mseg
*            where werks = p_werks  and
*                  bwart = '305'    and
*                  matnr = itab-matnr and
*                  sgtxt = i_305-sgtxt.
*        endif.

          IF p_radio1 = 'X'.
            itab-bwart1 = i_305-bwart.
            itab-mblnr1 = i_305-mblnr.
            itab-matnr1 = i_305-matnr.
            itab-menge1 = i_305-menge.
            itab-dmbtr1 = i_305-dmbtr.
            itab-cpudt1 = i_305-cpudt.
            itab-budat1 = i_305-budat.
            IF i_305-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            PERFORM f_get_unloading_point USING itab-mblnr1
                                          CHANGING itab-ablad.
            PERFORM f_validate_umlgo USING itab-umlgo
                                     CHANGING ld_flag.
            IF ld_flag IS INITIAL.
              APPEND itab.
            ELSE.
              CLEAR: ld_flag.
            ENDIF.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_305 FROM b.
              IF i_305-bwart = '305'      AND
                 i_305-sgtxt = itab-sgtxt AND
                 i_305-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_305.
              MOVE-CORRESPONDING i_305 TO wa_305.

              itab-menge1 = itab-menge1 + wa_305-menge.
              sw_1 = '1'.

            ENDLOOP.
            IF sw_1 IS INITIAL.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ELSE.
              CLEAR lv_menge.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_305-bwart.
                itab-mblnr1 = wa_305-mblnr.
                itab-matnr1 = wa_305-matnr.
                itab-dmbtr1 = wa_305-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                PERFORM f_get_unloading_point USING itab-mblnr1
                                              CHANGING itab-ablad.
                PERFORM f_validate_umlgo USING itab-umlgo
                                         CHANGING ld_flag.
                IF ld_flag IS INITIAL.
                  APPEND itab. CLEAR itab-menge1.
                ELSE.
                  CLEAR: ld_flag, itab-menge1.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_305 FROM b.
              IF i_305-bwart = '305'      AND
                 i_305-sgtxt = itab-sgtxt AND
                 i_305-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_305.
              MOVE-CORRESPONDING i_305 TO wa_305.

              itab-menge1 = itab-menge1 + wa_305-menge.
              sw_2 = '1'.

            ENDLOOP.

            IF itab-menge1 GE itab-menge.
              itab-bwart1 = wa_305-bwart.
              itab-mblnr1 = wa_305-mblnr.
              itab-matnr1 = wa_305-matnr.
              itab-dmbtr1 = wa_305-dmbtr.
              itab-cpudt1 = wa_305-cpudt.
              itab-budat1 = wa_305-budat.
              IF wa_305-cpudt > 0.
                IF l_live = 'X'.
                  itab-leadt = itab-cpudt1 - itab-budat.
                ELSE.
                  itab-leadt = itab-budat1 - itab-budat.
                ENDIF.
              ENDIF.
              IF itab-matnr1 NE space.
                itab-maktx1 = itab-maktx.
              ENDIF.
              PERFORM f_get_unloading_point USING itab-mblnr1
                                            CHANGING itab-ablad.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ENDIF.

          ENDIF.


**********************
* Mvt Type 313
        WHEN '313'.
          CLEAR i_315.
          IF p_bukrs EQ '8070'.
            itab-bbkno = i_mkpf-bktxt+3(5).
          ELSE.
            itab-bbkno = i_mkpf-bktxt+7(5).
          ENDIF.
          READ TABLE i_315 WITH KEY bwart = '315'
                                    sgtxt = itab-sgtxt
                                    matnr = itab-matnr BINARY SEARCH.
          b = sy-tabix.

*        if sy-subrc = 0.
*          select single mblnr into i_315-mblnr from mseg
*            where werks = p_werks  and
*                  bwart = '315'    and
*                  matnr = itab-matnr and
*                  sgtxt = i_315-sgtxt.
*        endif.

          IF p_radio1 = 'X'.
            itab-bwart1 = i_315-bwart.
            itab-mblnr1 = i_315-mblnr.
            itab-matnr1 = i_315-matnr.
            itab-menge1 = i_315-menge.
            itab-dmbtr1 = i_315-dmbtr.
            itab-cpudt1 = i_315-cpudt.
            itab-budat1 = i_315-budat.
            IF i_315-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            PERFORM f_get_unloading_point USING itab-mblnr1
                                          CHANGING itab-ablad.
            PERFORM f_validate_umlgo USING itab-umlgo
                                     CHANGING ld_flag.
            IF ld_flag IS INITIAL.
              APPEND itab.
            ELSE.
              CLEAR: ld_flag.
            ENDIF.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_315 FROM b.
              IF i_315-bwart = '315'      AND
                 i_315-sgtxt = itab-sgtxt AND
                 i_315-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_315.
              MOVE-CORRESPONDING i_315 TO wa_315.

              itab-menge1 = itab-menge1 + wa_315-menge.
              sw_1 = '1'.

            ENDLOOP.
            IF sw_1 IS INITIAL.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_315-bwart.
                itab-mblnr1 = wa_315-mblnr.
                itab-matnr1 = wa_315-matnr.
                itab-dmbtr1 = wa_315-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                PERFORM f_get_unloading_point USING itab-mblnr1
                                              CHANGING itab-ablad.
                PERFORM f_validate_umlgo USING itab-umlgo
                                         CHANGING ld_flag.
                IF ld_flag IS INITIAL.
                  APPEND itab. CLEAR itab-menge1.
                ELSE.
                  CLEAR: ld_flag, itab-menge1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_315 FROM b.
              IF i_315-bwart = '315'      AND
                 i_315-sgtxt = itab-sgtxt AND
                 i_315-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_315.
              MOVE-CORRESPONDING i_315 TO wa_315.

              itab-menge1 = itab-menge1 + wa_315-menge.
              sw_2 = '1'.

            ENDLOOP.

            IF itab-menge1 GE itab-menge.
              itab-bwart1 = wa_315-bwart.
              itab-mblnr1 = wa_315-mblnr.
              itab-matnr1 = wa_315-matnr.
              itab-dmbtr1 = wa_315-dmbtr.
              itab-cpudt1 = wa_315-cpudt.
              itab-budat1 = wa_315-budat.
              IF wa_315-cpudt > 0.
                IF l_live = 'X'.
                  itab-leadt = itab-cpudt1 - itab-budat.
                ELSE.
                  itab-leadt = itab-budat1 - itab-budat.
                ENDIF.
              ENDIF.
              IF itab-matnr1 NE space.
                itab-maktx1 = itab-maktx.
              ENDIF.
              PERFORM f_get_unloading_point USING itab-mblnr1
                                            CHANGING itab-ablad.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ENDIF.

          ENDIF.
*************

* Mvt Type 641
        WHEN '641' OR '907'.
          CLEAR i_101.
          IF itab-bwart EQ '641' OR itab-bwart EQ '907'.
            itab-mblnr = itab-xblnr.
          ENDIF.
*        read table i_101 with key bwart = '101'
*                                  xblnr = itab-mblnr
*                                  matnr = itab-matnr binary search.
          READ TABLE i_101 WITH KEY bwart = '101'
                                    xblnr = itab-mblnr
                                    matnr = itab-matnr
                                    ebeln = itab-ebeln BINARY SEARCH.
*                                  ebelp = itab-ebelp binary search.
          c = sy-tabix.

*        if sy-subrc = 0.
*          select single belnr into i_101-belnr from ekbe
*            where werks = p_werks  and
*                  bwart = '101'    and
*                  matnr = itab-matnr and
*                  xblnr = i_101-xblnr.
*        endif.

          IF p_radio1 = 'X'.
            itab-bwart1 = i_101-bwart.
            itab-mblnr1 = i_101-belnr.
            itab-matnr1 = i_101-matnr.
            itab-menge1 = i_101-menge.
            itab-dmbtr1 = i_101-dmbtr.
            itab-cpudt1 = i_101-cpudt.
            itab-budat1 = i_101-budat.
            IF i_101-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            PERFORM f_get_unloading_point USING itab-mblnr1
                                          CHANGING itab-ablad.
            PERFORM f_validate_umlgo USING itab-umlgo
                                     CHANGING ld_flag.
            IF ld_flag IS INITIAL.
              APPEND itab.
            ELSE.
              CLEAR: ld_flag.
            ENDIF.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_101 FROM c.
              IF i_101-bwart = '101'      AND
                 i_101-xblnr = itab-mblnr AND
                 i_101-matnr = itab-matnr AND
                 i_101-ebeln = itab-ebeln.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_101.
              MOVE-CORRESPONDING i_101 TO wa_101.

              itab-menge1 = itab-menge1 + wa_101-menge.
              sw_1 = '1'.

            ENDLOOP.
            IF sw_1 IS INITIAL.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.

            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_101-bwart.
                itab-mblnr1 = wa_101-belnr.
                itab-matnr1 = wa_101-matnr.
                itab-dmbtr1 = wa_101-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                PERFORM f_get_unloading_point USING itab-mblnr1
                                              CHANGING itab-ablad.
                PERFORM f_validate_umlgo USING itab-umlgo
                                         CHANGING ld_flag.
                IF ld_flag IS INITIAL.
                  APPEND itab. CLEAR itab-menge1.
                ELSE.
                  CLEAR: ld_flag, itab-menge1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_101 FROM c.
              IF i_101-bwart = '101'      AND
                 i_101-xblnr = itab-mblnr AND
                 i_101-matnr = itab-matnr AND
                 i_101-ebeln = itab-ebeln.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_101.
              MOVE-CORRESPONDING i_101 TO wa_101.

              itab-menge1 = itab-menge1 + wa_101-menge.
              sw_2 = '1'.

            ENDLOOP.
            IF NOT sw_2 IS INITIAL.
              IF itab-menge1 GE itab-menge.
                itab-bwart1 = wa_101-bwart.
                itab-mblnr1 = wa_101-belnr.
                itab-matnr1 = wa_101-matnr.
                itab-dmbtr1 = wa_101-dmbtr.
                itab-cpudt1 = wa_101-cpudt.
                itab-budat1 = wa_101-budat.
                IF wa_101-cpudt > 0.
                  IF l_live = 'X'.
                    itab-leadt = itab-cpudt1 - itab-budat.
                  ELSE.
                    itab-leadt = itab-budat1 - itab-budat.
                  ENDIF.
                ENDIF.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                PERFORM f_get_unloading_point USING itab-mblnr1
                                              CHANGING itab-ablad.
                PERFORM f_validate_umlgo USING itab-umlgo
                                         CHANGING ld_flag.
                IF ld_flag IS INITIAL.
                  APPEND itab. CLEAR itab-menge1.
                ELSE.
                  CLEAR: ld_flag, itab-menge1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

* Mvt Type 351
        WHEN '351'.
          CLEAR i_351.
          READ TABLE i_351 WITH KEY bwart = '101'
                                    xblnr = itab-mblnr
                                    matnr = itab-matnr BINARY SEARCH.
          b = sy-tabix.

          IF p_radio1 = 'X'.
            itab-bwart1 = i_351-bwart.
            itab-mblnr1 = i_351-mblnr.
            itab-matnr1 = i_351-matnr.
            itab-menge1 = i_351-menge.
            itab-dmbtr1 = i_351-dmbtr.
            itab-cpudt1 = i_351-cpudt.
            itab-budat1 = i_351-budat.
            IF i_351-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            PERFORM f_get_unloading_point USING itab-mblnr1
                                          CHANGING itab-ablad.
            PERFORM f_validate_umlgo USING itab-umlgo
                                     CHANGING ld_flag.
            IF ld_flag IS INITIAL.
              APPEND itab.
            ELSE.
              CLEAR: ld_flag.
            ENDIF.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_351 FROM b.
              IF i_351-bwart = '101'      AND
                 i_351-xblnr = itab-mblnr AND
                 i_351-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_351.
              MOVE-CORRESPONDING i_351 TO wa_351.

              itab-menge1 = itab-menge1 + wa_351-menge.
              sw_1 = '1'.
            ENDLOOP.

            IF sw_1 IS INITIAL.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_351-bwart.
                itab-mblnr1 = wa_351-mblnr.
                itab-matnr1 = wa_351-matnr.
                itab-dmbtr1 = wa_351-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                PERFORM f_get_unloading_point USING itab-mblnr1
                                              CHANGING itab-ablad.
                PERFORM f_validate_umlgo USING itab-umlgo
                                         CHANGING ld_flag.
                IF ld_flag IS INITIAL.
                  APPEND itab. CLEAR itab-menge1.
                ELSE.
                  CLEAR: ld_flag, itab-menge1.
                ENDIF.
              ELSEIF itab-menge1 GT itab-menge.
                lv_menge = itab-menge1 - itab-menge.
                LOOP AT i303641 WHERE mblnr NE itab-mblnr
                                  AND matnr = itab-matnr
                                  AND ebeln = itab-ebeln.
                  IF lv_menge GE i303641-menge.
                    lv_menge = lv_menge - i303641-menge.
                    DELETE i303641 INDEX sy-tabix.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_351 FROM b.
              IF i_351-bwart = '101'      AND
                 i_351-xblnr = itab-mblnr AND
                 i_351-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_351.
              MOVE-CORRESPONDING i_351 TO wa_351.

              itab-menge1 = itab-menge1 + wa_351-menge.
              sw_2 = '1'.

            ENDLOOP.

            IF itab-menge1 GE itab-menge.
              itab-bwart1 = wa_351-bwart.
              itab-mblnr1 = wa_351-mblnr.
              itab-matnr1 = wa_351-matnr.
              itab-dmbtr1 = wa_351-dmbtr.
              itab-cpudt1 = wa_351-cpudt.
              itab-budat1 = wa_351-budat.
              IF wa_351-cpudt > 0.
                IF l_live = 'X'.
                  itab-leadt = itab-cpudt1 - itab-budat.
                ELSE.
                  itab-leadt = itab-budat1 - itab-budat.
                ENDIF.
              ENDIF.
              IF itab-matnr1 NE space.
                itab-maktx1 = itab-maktx.
              ENDIF.
              PERFORM f_get_unloading_point USING itab-mblnr1
                                            CHANGING itab-ablad.
              PERFORM f_validate_umlgo USING itab-umlgo
                                       CHANGING ld_flag.
              IF ld_flag IS INITIAL.
                APPEND itab. CLEAR itab-menge1.
              ELSE.
                CLEAR: ld_flag, itab-menge1.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDLOOP.

  PERFORM f_modify_data.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*------------------------------------------------------*
  REFRESH : i_mkpf, i303641.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init.

  CLEAR e_variant.
  e_variant-report = sy-repid.

ENDFORM.                    " VARIANT_INIT

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = e_variant
      i_save     = e_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = e_exit
      es_variant = disvariant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF e_exit = space.
      pa_vari = disvariant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  append_structure_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_structure_alv.
  DATA : lv_col     TYPE sy-cucol.


* col 1
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'UMWRK'. fieldcat-ref_fieldname = 'UMWRK'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Rcv Pln'.
  fieldcat-seltext_m = 'Rcv Plant'.
  fieldcat-seltext_l = 'Receiving Plant'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  APPEND fieldcat. "clear fieldcat.

* col 2
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'UMLGO'. fieldcat-ref_fieldname = 'UMLGO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Rcv Sloc'.
  fieldcat-seltext_m = 'Rcv Sloc'.
  fieldcat-seltext_l = 'Receiving Sloc'.
  APPEND fieldcat. "clear fieldcat.

* col 2.1
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'NAME3'. fieldcat-ref_fieldname = 'NAME3'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 20. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Rcv Cust'.
  fieldcat-seltext_m = 'Rcv Cust'.
  fieldcat-seltext_l = 'Receiving Cust'.
  APPEND fieldcat. "clear fieldcat.

* col 3
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MBLNR'. fieldcat-ref_fieldname = 'MBLNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 10. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Doc No.'.
  fieldcat-seltext_m = 'Doc No.'.
  fieldcat-seltext_l = 'Doc Number'.
  fieldcat-hotspot = 'X'.
  APPEND fieldcat. "clear fieldcat.

* col 4
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BWART'. fieldcat-ref_fieldname = 'BWART'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Mvt'.
  fieldcat-seltext_m = 'Mvt'.
  fieldcat-seltext_l = 'Movement Type'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  CLEAR fieldcat-key.
*  fieldcat-just = 'R'.

* col 4
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LPRIO1'. fieldcat-ref_fieldname = 'LPRIO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 2.
  fieldcat-seltext_s = 'STO Prio'.
  fieldcat-seltext_m = 'STO Prio'.
  fieldcat-seltext_l = 'STO Priority'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BEZEI1'. fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Desc'.
  fieldcat-seltext_m = 'Desc'.
  fieldcat-seltext_l = 'Description'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LPRIO'. fieldcat-ref_fieldname = 'LPRIO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 2.
  fieldcat-seltext_s = 'DNPrio'.
  fieldcat-seltext_m = 'DNPrio'.
  fieldcat-seltext_l = 'DN Priority'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BEZEI'. fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Desc'.
  fieldcat-seltext_m = 'Desc'.
  fieldcat-seltext_l = 'Description'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

* col 5
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MATNR'. fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Supl Material'.
  fieldcat-seltext_m = 'Supl Material'.
  fieldcat-seltext_l = 'Supl Material'.
  APPEND fieldcat. "clear fieldcat.

* col 6
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MAKTX'. fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Supl Mat Desc'.
  fieldcat-seltext_m = 'Supl Material Desc'.
  fieldcat-seltext_l = 'Supl Material Description'.
  APPEND fieldcat. "clear fieldcat.

* col 7
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MENGE'. fieldcat-ref_fieldname = 'MENGE'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '2'.
  fieldcat-just = 'R'.
  fieldcat-seltext_s = 'Supl Qty'.
  fieldcat-seltext_m = 'Supl Quantity'.
  fieldcat-seltext_l = 'Supl Quantity'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 8
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'DMBTR'. fieldcat-ref_fieldname = 'DMBTR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '0'.
  fieldcat-just = 'R'.
  fieldcat-currency = 'IDR'.
  fieldcat-seltext_s = 'Supl Value'.
  fieldcat-seltext_m = 'Supl Value'.
  fieldcat-seltext_l = 'Supl Posting Value'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 9
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BUDAT'. fieldcat-ref_fieldname = 'BUDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-just = ' '.
  fieldcat-seltext_s = 'Post Dt'.
  fieldcat-seltext_m = 'Post Date'.
  fieldcat-seltext_l = 'Posting Date'.
  APPEND fieldcat. "clear fieldcat.

* col 10
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BLDAT'. fieldcat-ref_fieldname = 'BLDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Doc Date'.
  fieldcat-seltext_m = 'Doc Date'.
  fieldcat-seltext_l = 'Document Date'.
  APPEND fieldcat. "clear fieldcat.

* col 11
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'WERKS'. fieldcat-ref_fieldname = 'WERKS'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  fieldcat-seltext_s = 'Spl Pln'.
  fieldcat-seltext_m = 'Spl Plant'.
  fieldcat-seltext_l = 'Supply Plant'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 12
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LGORT'. fieldcat-ref_fieldname = 'LGORT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  fieldcat-seltext_s = 'Spl Sloc'.
  fieldcat-seltext_m = 'Spl Sloc'.
  fieldcat-seltext_l = 'Supply Sloc'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

* col 13
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MBLNR1'. fieldcat-ref_fieldname = 'MBLNR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Recv. Doc'.
  fieldcat-seltext_m = 'Recv. Doc'.
  fieldcat-seltext_l = 'Receiving Doc'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 14
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BWART1'. fieldcat-ref_fieldname = 'BWART1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  fieldcat-seltext_s = 'Rcv Mvt'.
  fieldcat-seltext_m = 'Rcv Mvt'.
  fieldcat-seltext_l = 'Receiving Mvt'.
  APPEND fieldcat. "clear fieldcat.

* col 15
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MATNR1'. fieldcat-ref_fieldname = 'MATNR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Recv Material'.
  fieldcat-seltext_m = 'Recv Material'.
  fieldcat-seltext_l = 'Recv Material'.
  APPEND fieldcat. "clear fieldcat.

* col 16
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MAKTX1'. fieldcat-ref_fieldname = 'MAKTX1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Recv Mat Desc'.
  fieldcat-seltext_m = 'Recv Material Desc'.
  fieldcat-seltext_l = 'Recv Material Description'.
  APPEND fieldcat. "clear fieldcat.

* col 17
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MENGE1'. fieldcat-ref_fieldname = 'MENGE1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '2'.
  fieldcat-just = 'R'.
  fieldcat-seltext_s = 'Recv Qty'.
  fieldcat-seltext_m = 'Recv Quantity'.
  fieldcat-seltext_l = 'Recv Quantity'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR: fieldcat-currency,fieldcat-just.

* col 18
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'DMBTR1'. fieldcat-ref_fieldname = 'DMBTR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '0'.
  fieldcat-just = 'R'.
  fieldcat-currency = 'IDR'.
  fieldcat-seltext_s = 'Recv Value'.
  fieldcat-seltext_m = 'Recv Value'.
  fieldcat-seltext_l = 'Recv Posting Value'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR: fieldcat-currency,fieldcat-just.

* col 19
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BUDAT1'. fieldcat-ref_fieldname = 'BUDAT1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Recv Date'.
  fieldcat-seltext_m = 'Recv Date'.
  fieldcat-seltext_l = 'Recv Date'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 20
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'CPUDT1'. fieldcat-ref_fieldname = 'CPUDT1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Entry Date'.
  fieldcat-seltext_m = 'Entry Date'.
  fieldcat-seltext_l = 'Entry Date'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 21
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LEADT'. fieldcat-ref_fieldname = 'LEADT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Lead Time'.
  fieldcat-seltext_m = 'Lead Time'.
  fieldcat-seltext_l = 'Lead Time'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 22
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EBELN'. fieldcat-ref_fieldname = 'EBELN'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'PO Number'.
  fieldcat-seltext_m = 'PO Number'.
  fieldcat-seltext_l = 'PO Number'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 23
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BBKNO'. fieldcat-ref_fieldname = 'BBKNO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'BBK Number'.
  fieldcat-seltext_m = 'BBK Number'.
  fieldcat-seltext_l = 'BBK Number'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 24
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'TKNUM'. fieldcat-ref_fieldname = 'TKNUM'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Ship No'.
  fieldcat-seltext_m = 'Ship No'.
  fieldcat-seltext_l = 'Ship No'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 25
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'ERDAT'. fieldcat-ref_fieldname = 'ERDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Ship Date/ETD'.
  fieldcat-seltext_m = 'Ship Date/ETD'.
  fieldcat-seltext_l = 'Ship Date/ETD'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 13.
  APPEND fieldcat. "clear fieldcat.

* col 26
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'ETDAT'. fieldcat-ref_fieldname = 'ETDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'ETA'.
  fieldcat-seltext_m = 'ETA'.
  fieldcat-seltext_l = 'ETA'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 27
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EXTI1'. fieldcat-ref_fieldname = 'EXTI1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'External identification 1'.
  fieldcat-seltext_m = 'External identification 1'.
  fieldcat-seltext_l = 'External identification 1'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 28
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EXTI2'. fieldcat-ref_fieldname = 'EXTI2'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'External identification 2'.
  fieldcat-seltext_m = 'External identification 2'.
  fieldcat-seltext_l = 'External identification 2'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'VNDNAM'. fieldcat-ref_fieldname = 'VNDNAM'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Name Of Service Provider'.
  fieldcat-seltext_m = 'Name Of Service Provider'.
  fieldcat-seltext_l = 'Name Of Service Provider'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 40.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'CUSPO'. fieldcat-ref_fieldname = 'CUSPO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Customer'.
  fieldcat-seltext_m = 'Customer'.
  fieldcat-seltext_l = 'Customer'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'CUSNAM'. fieldcat-ref_fieldname = 'CUSNAM'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Customer Name'.
  fieldcat-seltext_m = 'Customer Name'.
  fieldcat-seltext_l = 'Customer Name'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 35.
  APPEND fieldcat. "clear fieldcat.

* col 27
*  fieldcat-fieldname = 'ABLAD'. fieldcat-ref_fieldname = 'ABLAD'.
*  fieldcat-tabname = 'ITAB'.
*  fieldcat-SELTEXT_S = 'Unl. Point'.
*  fieldcat-SELTEXT_M = 'Unl. Point'.
*  fieldcat-SELTEXT_L = 'Unl. Point'.
*  fieldcat-col_pos = 27.
*  fieldcat-outputlen = 25.
*  append fieldcat. "clear fieldcat.

*  refresh evtab.
*  evtab_ln-name = 'TOP_OF_PAGE'.
*  evtab_ln-form = 'TOP_OF_PAGE'.
*  append evtab_ln to evtab.

ENDFORM.                    " append_structure_alv

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.

  DATA : v_budatlow(10),
         v_budathigh(10),
         v_time(8),
         separator(10) VALUE space.

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  ihead_ln-info = 'Listing Intransit'.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Period'.
  WRITE p_budat-low TO v_budatlow.
  WRITE p_budat-high TO v_budathigh.
  CONCATENATE v_budatlow 'TO' v_budathigh INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Branch'.
  CONCATENATE p_werks '-' v_name1 INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Process Time'.
  WRITE sy-datum TO ihead_ln-info.
  WRITE sy-uzeit TO v_time.
  CONCATENATE ihead_ln-info '/' v_time '/' sy-uname INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ihead.
  REFRESH ihead.

ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE e_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.

  READ TABLE rt_events WITH KEY name = slis_ev_user_command
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE e_user_command TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.

ENDFORM.                    " EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  f_get_unloading_point
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_MBLNR1  text
*      <--FC_ABLAD  text
*----------------------------------------------------------------------*
FORM f_get_unloading_point  USING    fu_mblnr1
                            CHANGING fc_ablad.
  DATA: ld_vbelv  LIKE vbfa-vbelv.

  SELECT SINGLE vbelv
    FROM vbfa
    INTO ld_vbelv
    WHERE vbeln EQ fu_mblnr1.
  IF sy-subrc EQ 0.
    SELECT SINGLE ablad
      FROM likp
      INTO fc_ablad
      WHERE vbeln EQ ld_vbelv.
  ENDIF.
ENDFORM.                    " f_get_unloading_point

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_UMLGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_umlgo USING fu_umlgo
                      CHANGING fc_flag.
  IF p_lgort[] IS NOT INITIAL.
    IF fu_umlgo IN p_lgort.
      CLEAR: fc_flag.
    ELSE.
      fc_flag = 1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_UMLGO

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_budat-high IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'BUD'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH 'Posting Date harus diisi di dalam ranges'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer .
  DATA: lt_t001l TYPE TABLE OF t001l WITH HEADER LINE,
        lt_t001w TYPE TABLE OF t001w WITH HEADER LINE.

  CLEAR: gr_kunnr[].

  SELECT werks lgort kunnr
    INTO CORRESPONDING FIELDS OF TABLE lt_t001l
    FROM t001l WHERE werks = p_werks
                 AND lgort IN p_lgort.
  SELECT werks kunnr
    INTO CORRESPONDING FIELDS OF TABLE lt_t001w
    FROM t001w WHERE werks = p_werks.

  SORT lt_t001l BY werks lgort kunnr.
  SORT lt_t001w BY werks kunnr.
  IF lt_t001l[] IS NOT INITIAL.
    LOOP AT lt_t001l.
      IF lt_t001l-kunnr IS INITIAL.
        CLEAR lt_t001w.
        READ TABLE lt_t001w WITH KEY werks = lt_t001l-werks.
        IF lt_t001w-kunnr IS NOT INITIAL.
          CLEAR gr_kunnr.
          gr_kunnr-sign = 'I'.
          gr_kunnr-option = 'EQ'.
          gr_kunnr-low = lt_t001w-kunnr.
          COLLECT gr_kunnr.
        ENDIF.
      ELSE.
        CLEAR gr_kunnr.
        gr_kunnr-sign = 'I'.
        gr_kunnr-option = 'EQ'.
        gr_kunnr-low = lt_t001l-kunnr.
        COLLECT gr_kunnr.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT lt_t001w.
      IF lt_t001w-kunnr IS NOT INITIAL.
        CLEAR gr_kunnr.
        gr_kunnr-sign = 'I'.
        gr_kunnr-option = 'EQ'.
        gr_kunnr-low = lt_t001w-kunnr.
        COLLECT gr_kunnr.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  TYPES : BEGIN OF ty_likp,
            vbeln TYPE likp-vbeln,
            lprio TYPE likp-lprio,
          END OF ty_likp.

  DATA : xitab    LIKE itab OCCURS 0,
         lt_likp  TYPE STANDARD TABLE OF ty_likp,
         ls_likp  LIKE LINE OF lt_likp,
         lt_tprit TYPE STANDARD TABLE OF tprit,
         ls_tprit LIKE LINE OF lt_tprit,
         lt_ekpv  TYPE STANDARD TABLE OF ekpv,
         ls_ekpv  LIKE LINE OF lt_ekpv.

  SELECT *
    FROM tprit
    INTO CORRESPONDING FIELDS OF TABLE lt_tprit
    WHERE spras = sy-langu.

  xitab[] = itab[].
  SORT xitab BY mblnr.
  DELETE ADJACENT DUPLICATES FROM xitab COMPARING mblnr.
  IF xitab[] IS NOT INITIAL.
    SELECT vbeln lprio
      FROM likp
      INTO TABLE lt_likp
      FOR ALL ENTRIES IN xitab
      WHERE vbeln EQ xitab-mblnr.
  ENDIF.

  xitab[] = itab[].
  SORT xitab BY ebeln.
  DELETE ADJACENT DUPLICATES FROM xitab COMPARING ebeln.
  IF xitab[] IS NOT INITIAL.
    SELECT *
      FROM ekpv
      INTO CORRESPONDING FIELDS OF TABLE lt_ekpv
      FOR ALL ENTRIES IN xitab
      WHERE ebeln = xitab-ebeln.
  ENDIF.

  LOOP AT itab.
    CLEAR ls_likp.
    READ TABLE lt_likp INTO ls_likp
                       WITH KEY vbeln = itab-mblnr.
    IF sy-subrc = 0.
      CLEAR ls_tprit.
      READ TABLE lt_tprit INTO ls_tprit
                          WITH KEY lprio = ls_likp-lprio.
      IF sy-subrc = 0.
        itab-lprio    = ls_tprit-lprio.
        itab-bezei    = ls_tprit-bezei.
      ENDIF.
    ENDIF.

    CLEAR ls_ekpv.
    READ TABLE lt_ekpv INTO ls_ekpv
                       WITH KEY ebeln = itab-ebeln.
    IF sy-subrc = 0.
      CLEAR ls_tprit.
      READ TABLE lt_tprit INTO ls_tprit
                          WITH KEY lprio = ls_ekpv-lprio.
      IF sy-subrc = 0.
        itab-lprio1    = ls_tprit-lprio.
        itab-bezei1    = ls_tprit-bezei.
      ENDIF.
    ENDIF.

    MODIFY itab TRANSPORTING lprio bezei lprio1 bezei1.
    CLEAR itab.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_DATA
