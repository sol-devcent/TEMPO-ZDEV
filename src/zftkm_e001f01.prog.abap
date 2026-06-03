*&---------------------------------------------------------------------*
*&  Include           ZFTKM_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN pa_proc.
      pa_bukrs = '8800'.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'PBX' '0' '',
                                      'PBE' '0' '',
                                      'PGJ' '0' '',
                                      'SBU' '0' '',
                                      'SVK' '0' ''.
    WHEN pa_reve.
      pa_bukrx = '8020'.
      PERFORM f_modify_screen USING : 'PMA' '0' '',
                                      'PBU' '0' '',
                                      'SDT' '0' '',
                                      'SNO' '0' '',
                                      'SVB' '0' '',
                                      'PUD' '0' '',
                                      'PBL' '0' '',
                                      'PXB' '0' '',
                                      'PBK' '0' '',
                                      'SBU' '0' '',
                                      'SVK' '0' ''.
    WHEN pa_rept OR pa_detl.
      pa_bukrs = '8800'.
      PERFORM f_modify_screen USING : 'PVK' '0' '',
                                      'PBX' '0' '',
                                      'SDT' '0' '',
                                      'SNO' '0' '',
                                      'SVB' '0' '',
                                      'PBE' '0' '',
                                      'PGJ' '0' '',
                                      'SBU' '0' '',
                                      'PUD' '0' '',
                                      'PBL' '0' '',
                                      'PXB' '0' '',
                                      'PBK' '0' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN pa_proc.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_kunnr IS INITIAL.
        PERFORM f_screen_error USING 'PKU' ''.
      ENDIF.
      IF pa_mastx IS INITIAL.
        PERFORM f_screen_error USING 'PMA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_bldat IS INITIAL.
        PERFORM f_screen_error USING 'PBL' ''.
      ENDIF.
    WHEN pa_reve.
      IF pa_bukrx IS INITIAL.
        PERFORM f_screen_error USING 'PBX' ''.
      ENDIF.
      IF pa_kunnr IS INITIAL.
        PERFORM f_screen_error USING 'PKU' ''.
      ENDIF.
      IF pa_belnr IS INITIAL.
        PERFORM f_screen_error USING 'PBE' ''.
      ENDIF.
      IF pa_gjahr IS INITIAL.
        PERFORM f_screen_error USING 'PGJ' ''.
      ENDIF.
    WHEN pa_rept OR pa_detl.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_kunnr IS INITIAL.
        PERFORM f_screen_error USING 'PKU' ''.
      ENDIF.
      IF pa_mastx IS INITIAL.
        PERFORM f_screen_error USING 'PMA' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : lv_style           TYPE lvc_s_styl-style,
         ls_stylerow        TYPE lvc_s_styl.

  lv_style = cl_gui_alv_grid=>mc_style_disabled.
  ls_stylerow-fieldname = 'CHECK'.
  ls_stylerow-style     = lv_style.
  APPEND ls_stylerow TO gt_disabled.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_003   TYPE STANDARD TABLE OF zgdtxdt0003 INITIAL SIZE 0,
         lt_vbrp  TYPE STANDARD TABLE OF vbrp INITIAL SIZE 0,
         lt_006   TYPE STANDARD TABLE OF zdgsddt006 INITIAL SIZE 0,
         lt_vttp  TYPE STANDARD TABLE OF vttp INITIAL SIZE 0.

  CASE 'X'.
    WHEN pa_proc.
      PERFORM f_get_posting_key.

      PERFORM f_get_zgdtxdt0003.

      IF gt_003[] IS NOT INITIAL.
        SELECT *
          FROM zfapar_trn
          INTO CORRESPONDING FIELDS OF TABLE gt_apart
          FOR ALL ENTRIES IN gt_003
          WHERE bukrs_s  = gt_003-bukrs
            AND fakturno = gt_003-fakturno
            AND vbeln    = gt_003-vbeln
            AND belnrrev = space.
      ENDIF.

      lt_003[]  = gt_003[].
      SORT lt_003[] BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING vbeln.
      IF lt_003[] IS NOT INITIAL.
        SELECT vbeln posnr vbelv posnv arktx
          FROM vbrp
          INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
          FOR ALL ENTRIES IN lt_003
          WHERE vbeln = lt_003-vbeln.

        SELECT bukrs belnr gjahr buzei bschl koart dmbtr wrbtr hkont
          kunnr lifnr vbel2 posn2
          FROM bseg
          INTO CORRESPONDING FIELDS OF TABLE gt_bseg
          FOR ALL ENTRIES IN lt_003
          WHERE bukrs = lt_003-bukrs
            AND belnr = lt_003-vbeln
            AND gjahr = lt_003-fakdat(4).
      ENDIF.

      lt_vbrp[] = gt_vbrp[].
      SORT lt_vbrp BY vbelv posnv.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vbelv posnv.
      IF lt_vbrp[] IS NOT INITIAL.
        SELECT *
          FROM zdgsddt006
          INTO CORRESPONDING FIELDS OF TABLE gt_006
          FOR ALL ENTRIES IN lt_vbrp
          WHERE vbap_vbeln = lt_vbrp-vbelv
            AND posnr      = lt_vbrp-posnv.
      ENDIF.

      lt_006[] = gt_006[].
      SORT lt_006 BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_006 COMPARING tknum.
      IF lt_006[] IS NOT INITIAL.
        SELECT tknum route add04
          FROM vttk
          INTO CORRESPONDING FIELDS OF TABLE gt_vttk
          FOR ALL ENTRIES IN lt_006
          WHERE tknum = lt_006-tknum.

        IF gt_vttk[] IS NOT INITIAL.
          SELECT tknum tpnum vbeln
            FROM vttp
            INTO CORRESPONDING FIELDS OF TABLE gt_vttp
            FOR ALL ENTRIES IN gt_vttk
            WHERE tknum = gt_vttk-tknum.

          lt_vttp[] = gt_vttp[].
          SORT lt_vttp BY vbeln.
          SELECT vbeln vstel vkorg
            FROM likp
            INTO CORRESPONDING FIELDS OF TABLE gt_likp
            FOR ALL ENTRIES IN lt_vttp
            WHERE vbeln = lt_vttp-vbeln
              AND vkorg = pa_bukrs.
        ENDIF.
      ENDIF.

*      IF pa_kunnr(5) = 'TBA02'.
*        pa_kunnr = 'TSB8020'.
*      ENDIF.

      SELECT kunnr bukrs lifnr
        FROM zfapar_bukrs
        INTO CORRESPONDING FIELDS OF TABLE gt_aparb
        WHERE kunnr = pa_kunnr.

      SELECT *
        FROM zfroute_apar
        INTO CORRESPONDING FIELDS OF TABLE gt_aparr.

      SELECT *
        FROM zfapar_round
        INTO CORRESPONDING FIELDS OF TABLE gt_apard.

    WHEN pa_reve.
      SELECT *
        FROM zfapar_trn
        INTO CORRESPONDING FIELDS OF TABLE gt_apart
        WHERE bukrs    = pa_bukrx
          AND gjahr    = pa_gjahr
          AND belnr    = pa_belnr
          AND vkbur    = pa_vkbur
          AND kunnr    = pa_kunnr
          AND belnrrev = space.

    WHEN pa_rept OR pa_detl.
      PERFORM f_get_zgdtxdt0003.

      IF gt_003[] IS NOT INITIAL.
        SELECT *
          FROM zfapar_trn
          INTO CORRESPONDING FIELDS OF TABLE gt_apart
          FOR ALL ENTRIES IN gt_003
          WHERE bukrs_s  = gt_003-bukrs
            AND fakturno = gt_003-fakturno
            AND vbeln    = gt_003-vbeln.
      ENDIF.

      lt_003[]  = gt_003[].
      SORT lt_003[] BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_003 COMPARING vbeln.
      IF lt_003[] IS NOT INITIAL.
        SELECT vbeln posnr vbelv posnv arktx netwr mwsbp
          FROM vbrp
          INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
          FOR ALL ENTRIES IN lt_003
          WHERE vbeln = lt_003-vbeln.

        SELECT bukrs belnr gjahr buzei bschl koart dmbtr wrbtr hkont
          kunnr lifnr vbel2 posn2
          FROM bseg
          INTO CORRESPONDING FIELDS OF TABLE gt_bseg
          FOR ALL ENTRIES IN lt_003
          WHERE bukrs = lt_003-bukrs
            AND belnr = lt_003-vbeln
            AND gjahr = lt_003-fakdat(4).
      ENDIF.

      lt_vbrp[] = gt_vbrp[].
      SORT lt_vbrp BY vbelv posnv.
      DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vbelv posnv.
      IF lt_vbrp[] IS NOT INITIAL.
        SELECT *
          FROM zdgsddt006
          INTO CORRESPONDING FIELDS OF TABLE gt_006
          FOR ALL ENTRIES IN lt_vbrp
          WHERE vbap_vbeln = lt_vbrp-vbelv
            AND posnr      = lt_vbrp-posnv.
      ENDIF.

      lt_006[] = gt_006[].
      SORT lt_006 BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_006 COMPARING tknum.
      IF lt_006[] IS NOT INITIAL.
        SELECT tknum route add04
          FROM vttk
          INTO CORRESPONDING FIELDS OF TABLE gt_vttk
          FOR ALL ENTRIES IN lt_006
          WHERE tknum = lt_006-tknum.
      ENDIF.

      SELECT kunnr bukrs lifnr
        FROM zfapar_bukrs
        INTO CORRESPONDING FIELDS OF TABLE gt_aparb
        WHERE kunnr = pa_kunnr.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out       LIKE LINE OF gt_out,
         ls_002       LIKE LINE OF gt_002,
         ls_003       LIKE LINE OF gt_003,
         ls_vbrp      LIKE LINE OF gt_vbrp,
         ls_006       LIKE LINE OF gt_006,
         ls_vttk      LIKE LINE OF gt_vttk,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_likp      LIKE LINE OF gt_likp,
         ls_bseg      LIKE LINE OF gt_bseg,
         ls_aparb     LIKE LINE OF gt_aparb,
         ls_aparr     LIKE LINE OF gt_aparr,
         ls_apart     LIKE LINE OF gt_apart,
         ls_makt      LIKE LINE OF gt_makt.
  DATA : lv_flag      TYPE xfeld,
         lv_lifnr     TYPE lfa1-lifnr,
         lv_name1     TYPE lfa1-name1,
         lv_str1      TYPE string,
         lv_str2      TYPE string.

  CASE 'X'.
    WHEN pa_proc.
      LOOP AT gt_003 INTO ls_003.
        READ TABLE gt_apart INTO ls_apart WITH KEY bukrs_s  = ls_003-bukrs
                                                   fakturno = ls_003-fakturno
                                                   vbeln    = ls_003-vbeln.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
        ls_out-bukrs     = ls_003-bukrs.
        ls_out-kunnr     = ls_003-kunwe.
        ls_out-fakturno  = ls_003-fakturno.
        ls_out-fakdat    = ls_003-fakdat.
        ls_out-vbeln     = ls_003-vbeln.
        ls_out-waerk     = ls_003-waerk.

        CLEAR : ls_vbrp, lv_flag.
        LOOP AT gt_vbrp INTO ls_vbrp WHERE vbeln = ls_003-vbeln.
          IF lv_flag IS INITIAL.
            lv_flag = selected.
          ELSE.
            PERFORM f_fieldstyle USING : 'CHECK' ''
                                 CHANGING ls_out-style.
          ENDIF.
          ls_out-posnr     = ls_vbrp-posnr.
          ls_out-arktx     = ls_vbrp-arktx.
          CLEAR ls_006.
          READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_vbrp-vbelv
                                                 posnr      = ls_vbrp-posnv.
          IF sy-subrc = 0.
            CLEAR ls_bseg.
            READ TABLE gt_bseg INTO ls_bseg WITH KEY vbel2 = ls_vbrp-vbelv
                                                     posn2 = ls_vbrp-posnv.
            IF sy-subrc = 0.
              ls_out-fakdpp    = ls_bseg-dmbtr.
            ENDIF.

            CLEAR ls_002.
            READ TABLE gt_002 INTO ls_002 WITH KEY vbeln = ls_vbrp-vbeln
                                                   posnr = ls_vbrp-posnr.
            IF sy-subrc = 0.
              ls_out-fakppn    = ls_002-ppn.
            ENDIF.

            CLEAR ls_vttk.
            READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum = ls_006-tknum.
            IF sy-subrc = 0.
              ls_out-route  = ls_vttk-route.
              ls_out-add04  = ls_vttk-add04.
              IF ls_vttk-add04 IS INITIAL.
                ls_out-add04    = 'DIST'.
              ENDIF.

              CLEAR ls_aparb.
              READ TABLE gt_aparb INTO ls_aparb WITH KEY kunnr = ls_003-kunrg.
              IF sy-subrc = 0.
                ls_out-bukrsx   = ls_aparb-bukrs.
                ls_out-lifnr    = ls_aparb-lifnr.

                CLEAR ls_aparr.
                READ TABLE gt_aparr INTO ls_aparr WITH KEY route = ls_vttk-route
                                                           bukrs = ls_aparb-bukrs
                                                           kunwe = ls_003-kunwe.
                IF sy-subrc = 0.
                  ls_out-vkbur  = ls_aparr-vkbur.
                ELSE.
                  CLEAR ls_aparr.
                  READ TABLE gt_aparr INTO ls_aparr WITH KEY route = ls_vttk-route
                                                             bukrs = ls_aparb-bukrs.
                  IF sy-subrc = 0.
                    ls_out-vkbur  = ls_aparr-vkbur.
                  ELSE.
                    CLEAR ls_out-vkbur.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
*            IF ls_out-vkbur IS INITIAL.
*              PERFORM f_fieldstyle USING : 'CHECK' ''
*                                   CHANGING ls_out-style.
*            ENDIF.
            APPEND ls_out TO gt_out.
          ENDIF.
        ENDLOOP.
        CLEAR ls_out.
      ENDLOOP.

      PERFORM f_validate_out.

    WHEN pa_reve.
      LOOP AT gt_apart INTO ls_apart.
        ls_out-bukrs      = ls_apart-bukrs.
        ls_out-bukrsx     = ls_apart-bukrs.
        ls_out-gjahr      = ls_apart-gjahr.
        ls_out-belnr      = ls_apart-belnr.
        ls_out-fakturno   = ls_apart-fakturno.
        ls_out-vbeln      = ls_apart-vbeln.
        ls_out-vkbur      = ls_apart-vkbur.
        ls_out-kunnr      = ls_apart-kunnr.
        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

    WHEN pa_rept.
      READ TABLE gt_aparb INTO ls_aparb INDEX 1.
      lv_lifnr  = ls_aparb-lifnr.

      SELECT SINGLE name1
        FROM lfa1
        INTO lv_name1
        WHERE lifnr = lv_lifnr.

      LOOP AT gt_003 INTO ls_003.
        ls_out-lifnr    = lv_lifnr.
        ls_out-name1    = lv_name1.
        ls_out-masatx   = ls_003-masatx.
        ls_out-vbeln    = ls_003-vbeln.
        ls_out-yeartx   = ls_003-yeartx.
        ls_out-fakturno = ls_003-fakturno.
        ls_out-fakdat   = ls_003-fakdat.
        ls_out-dpp      = ls_003-fakdpp.
        ls_out-ppn      = ls_003-fakppn.
        ls_out-waers    = ls_003-waerk.
        CLEAR ls_apart.
        READ TABLE gt_apart INTO ls_apart WITH KEY bukrs_s  = ls_003-bukrs
                                                   fakturno = ls_003-fakturno
                                                   vbeln    = ls_003-vbeln
                                          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          CLEAR ls_apart.
          LOOP AT gt_apart INTO ls_apart WHERE bukrs_s  = ls_003-bukrs
                                           AND fakturno = ls_003-fakturno
                                           AND vbeln    = ls_003-vbeln.
            ls_out-vkbur    = ls_apart-vkbur.
            ls_out-belnr    = ls_apart-belnr.
            ls_out-budat    = ls_apart-budat.
            ls_out-belnrrev = ls_apart-belnrrev.
            ls_out-daterev  = ls_apart-daterev.
            IF ls_apart-belnrrev IS INITIAL.
              ls_out-dpp      = ls_003-fakdpp.
              ls_out-ppn      = ls_003-fakppn.
            ELSE.
              CLEAR : ls_out-dpp, ls_out-ppn.
            ENDIF.

            CLEAR ls_vbrp.
            READ TABLE gt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_003-vbeln.
            IF sy-subrc = 0.
              CLEAR ls_006.
              READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_vbrp-vbelv
                                                     posnr      = ls_vbrp-posnv.
              IF sy-subrc = 0.
                CLEAR ls_vttk.
                READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum = ls_006-tknum.
                IF sy-subrc = 0.
                  ls_out-route  = ls_vttk-route.
                  ls_out-add04  = ls_vttk-add04.
                  IF ls_vttk-add04 IS INITIAL.
                    ls_out-add04    = 'DIST'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            CLEAR : ls_bseg, ls_out-amount, ls_out-pph23.
            IF ls_apart-belnrrev IS INITIAL.
              LOOP AT gt_bseg INTO ls_bseg WHERE bukrs = ls_003-bukrs
                                             AND belnr = ls_003-vbeln
                                             AND gjahr = ls_003-fakdat(4).
                IF ls_bseg-hkont = '0121110100'.
                  ADD ls_bseg-dmbtr TO ls_out-amount.
                ENDIF.
                IF ls_bseg-hkont = '0142100020'.
                  ADD ls_bseg-dmbtr TO ls_out-pph23.
                ENDIF.
              ENDLOOP.
            ENDIF.

            IF ls_out-vkbur IN so_vkbur.
              APPEND ls_out TO gt_out.
            ENDIF.
          ENDLOOP.
          CLEAR ls_out.
        ELSE.
          CLEAR ls_vbrp.
          READ TABLE gt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_003-vbeln.
          IF sy-subrc = 0.
            CLEAR ls_006.
            READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_vbrp-vbelv
                                                   posnr      = ls_vbrp-posnv.
            IF sy-subrc = 0.
              CLEAR ls_vttk.
              READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum = ls_006-tknum.
              IF sy-subrc = 0.
                ls_out-route  = ls_vttk-route.
                ls_out-add04  = ls_vttk-add04.
                IF ls_vttk-add04 IS INITIAL.
                  ls_out-add04    = 'DIST'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          CLEAR ls_bseg.
          LOOP AT gt_bseg INTO ls_bseg WHERE bukrs = ls_003-bukrs
                                         AND belnr = ls_003-vbeln
                                         AND gjahr = ls_003-fakdat(4).
            IF ls_bseg-hkont = '0121110100'.
              ADD ls_bseg-dmbtr TO ls_out-amount.
            ENDIF.
            IF ls_bseg-hkont = '0142100020'.
              ADD ls_bseg-dmbtr TO ls_out-pph23.
            ENDIF.
          ENDLOOP.

          IF ls_out-vkbur IN so_vkbur.
            APPEND ls_out TO gt_out.
          ENDIF.
          CLEAR ls_out.
        ENDIF.
      ENDLOOP.

    WHEN pa_detl.
      READ TABLE gt_aparb INTO ls_aparb INDEX 1.
      lv_lifnr  = ls_aparb-lifnr.

      SELECT SINGLE name1
        FROM lfa1
        INTO lv_name1
        WHERE lifnr = lv_lifnr.

      LOOP AT gt_003 INTO ls_003.
        CLEAR lv_flag.
        LOOP AT gt_002 INTO ls_002 WHERE bukrs    = ls_003-bukrs
                                     AND brnch    = ls_003-brnch
                                     AND busln    = ls_003-busln
                                     AND vbeln    = ls_003-vbeln
                                     AND fakturno = ls_003-fakturno.

          ls_out-lifnr    = lv_lifnr.
          ls_out-name1    = lv_name1.
          ls_out-masatx   = ls_003-masatx.
          ls_out-vbeln    = ls_003-vbeln.
          ls_out-yeartx   = ls_003-yeartx.
          ls_out-fakturno = ls_003-fakturno.
          ls_out-fakdat   = ls_003-fakdat.
          ls_out-waers    = ls_003-waerk.

          ls_out-matnr  = ls_002-matnr.
          SPLIT ls_002-item AT '/' INTO lv_str1 lv_str2.
          SPLIT lv_str2 AT '-' INTO ls_out-tknum lv_str2.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_002-matnr.
          IF sy-subrc = 0.
            ls_out-maktx    = ls_makt-maktx.
          ENDIF.

          CLEAR ls_apart.
          READ TABLE gt_apart INTO ls_apart WITH KEY bukrs_s  = ls_003-bukrs
                                                     fakturno = ls_003-fakturno
                                                     vbeln    = ls_003-vbeln
                                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CLEAR ls_apart.
            LOOP AT gt_apart INTO ls_apart WHERE bukrs_s  = ls_003-bukrs
                                             AND fakturno = ls_003-fakturno
                                             AND vbeln    = ls_003-vbeln.
              ls_out-vkbur    = ls_apart-vkbur.
              ls_out-belnr    = ls_apart-belnr.
              ls_out-budat    = ls_apart-budat.
              ls_out-belnrrev = ls_apart-belnrrev.
              ls_out-daterev  = ls_apart-daterev.
              IF ls_apart-belnrrev IS INITIAL.
                ls_out-dpp      = ls_003-fakdpp.
                ls_out-ppn      = ls_003-fakppn.
              ELSE.
                CLEAR : ls_out-dpp, ls_out-ppn.
              ENDIF.

              CLEAR ls_vbrp.
              READ TABLE gt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_003-vbeln
                                                       posnr = ls_002-posnr.
              IF sy-subrc = 0.
                ls_out-dpp      = ls_vbrp-netwr.
                ls_out-ppn      = ls_vbrp-mwsbp.

                CLEAR ls_006.
                READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_vbrp-vbelv
                                                       posnr      = ls_vbrp-posnv.
                IF sy-subrc = 0.
                  CLEAR ls_vttk.
                  READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum = ls_006-tknum.
                  IF sy-subrc = 0.
                    ls_out-route  = ls_vttk-route.
                    ls_out-add04  = ls_vttk-add04.
                    IF ls_vttk-add04 IS INITIAL.
                      ls_out-add04    = 'DIST'.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.

              CLEAR : ls_bseg, ls_out-amount, ls_out-pph23.
              IF ls_apart-belnrrev IS INITIAL.
                IF lv_flag IS INITIAL.
                  lv_flag = 'X'.
                  LOOP AT gt_bseg INTO ls_bseg WHERE bukrs = ls_003-bukrs
                                                 AND belnr = ls_003-vbeln
                                                 AND gjahr = ls_003-fakdat(4).
*                  IF ls_bseg-hkont = '0121110100'.
*                    ADD ls_bseg-dmbtr TO ls_out-amount.
*                  ENDIF.
                    IF ls_bseg-hkont = '0142100020'.
                      ADD ls_bseg-dmbtr TO ls_out-pph23.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.

              IF ls_out-vkbur IN so_vkbur.
                ls_out-amount = ls_out-dpp + ls_out-ppn - ls_out-pph23.
                APPEND ls_out TO gt_out.
              ENDIF.
            ENDLOOP.
            CLEAR ls_out.
          ELSE.
            CLEAR ls_vbrp.
            READ TABLE gt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_002-vbeln
                                                     posnr = ls_002-posnr.
            IF sy-subrc = 0.
              ls_out-dpp      = ls_vbrp-netwr.
              ls_out-ppn      = ls_vbrp-mwsbp.

              CLEAR ls_006.
              READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_vbrp-vbelv
                                                     posnr      = ls_vbrp-posnv.
              IF sy-subrc = 0.
                CLEAR ls_vttk.
                READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum = ls_006-tknum.
                IF sy-subrc = 0.
                  ls_out-route  = ls_vttk-route.
                  ls_out-add04  = ls_vttk-add04.
                  IF ls_vttk-add04 IS INITIAL.
                    ls_out-add04    = 'DIST'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_flag IS INITIAL.
              lv_flag = 'X'.
              CLEAR ls_bseg.
              LOOP AT gt_bseg INTO ls_bseg WHERE bukrs = ls_002-bukrs
                                             AND belnr = ls_002-vbeln
                                             AND gjahr = ls_003-fakdat(4).
                IF ls_bseg-hkont = '0142100020'.
                  ADD ls_bseg-dmbtr TO ls_out-pph23.
                ENDIF.
              ENDLOOP.
            ENDIF.

            IF ls_out-vkbur IN so_vkbur.
              ls_out-amount = ls_out-dpp + ls_out-ppn - ls_out-pph23.
              APPEND ls_out TO gt_out.
            ENDIF.
            CLEAR ls_out.
          ENDIF.
        ENDLOOP.
        CLEAR lv_flag.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].
  CASE 'X'.
    WHEN pa_proc.
      SET TITLEBAR 'TITLE_PROC'.
      APPEND '&REV'  TO fcode.
    WHEN pa_reve.
      SET TITLEBAR 'TITLE_REVERSE'.
      APPEND '&POS'  TO fcode.
      APPEND '&SIM'  TO fcode.
    WHEN pa_rept OR pa_detl.
      SET TITLEBAR 'TITLE_REPORT'.
      APPEND '&REV'  TO fcode.
      APPEND '&POS'  TO fcode.
      APPEND '&SIM'  TO fcode.
      APPEND '&LOG'  TO fcode.
  ENDCASE.

  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.

  PERFORM f_excluding_toolbar.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_container.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_maingrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_maingrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sort_tab_grid.

    gs_variant-report = gv_repid.

    CASE 'X'.
      WHEN pa_proc.
        SET HANDLER event_receiver->handle_double_click
                    event_receiver->handle_toolbar
                    event_receiver->handle_menu_button
                    event_receiver->handle_user_command FOR g_maingrid.
      WHEN pa_reve.
        SET HANDLER event_receiver->handle_double_click
                    event_receiver->handle_toolbar
                    event_receiver->handle_menu_button
                    event_receiver->handle_user_command FOR g_maingrid.
      WHEN pa_rept OR pa_detl.
        SET HANDLER event_receiver->handle_double_click FOR g_maingrid.
    ENDCASE.

    CALL METHOD g_maingrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR : gt_main_fieldcat[], gt_main_fieldcat.

  CASE 'X'.
    WHEN pa_proc.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
        'X' '' '',
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'GJAHR' 'BSID' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'FAKDAT' 'ZGDTXDT0003' 'FAKDAT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'VBELN' 'ZGDTXDT0003' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'WAERK' 'ZGDTXDT0003' 'WAERK' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'FAKDPP' 'ZGDTXDT0003' 'FAKDPP' '' '' '' '' '' '' '' '' 'WAERK'
        '' '' '' '' '' '' 'X' '',
        'FAKPPN' 'ZGDTXDT0003' 'FAKPPN' '' '' '' '' '' '' '' '' 'WAERK'
        '' '' '' '' '' '' 'X' '',
        'ARKTX' 'VBRP' 'ARKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VKBUR' 'ZFROUTE_APAR' 'VKBUR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'ROUTE' 'VTTK' 'ROUTE' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'ADD04' 'VTTK' 'ADD04' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' ''.
    WHEN pa_reve.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
        'X' '' '',
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BELNRREV' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VKBUR' 'ZFROUTE_APAR' 'VKBUR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'GJAHR' 'BSID' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VBELN' 'ZGDTXDT0003' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' ''.
    WHEN pa_rept.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'LIFNR' 'LFA1' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'MASATX' 'ZGDTXDT0003' 'MASATX' '' '12' 'Masa Pajak' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'VBELN' 'ZGDTXDT0003' 'VBELN' '' '15' 'Invoice No.' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'YEARTX' 'ZGDTXDT0003' 'YEARTX' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'VKBUR' 'ZFAPAR_TRN' 'VKBUR' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BELNR' 'ZFAPAR_TRN' 'BELNR' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BUDAT' 'ZFAPAR_TRN' 'BUDAT' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BELNRREV' 'ZFAPAR_TRN' 'BELNRREV' '' '15' 'Doc.Rev' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'DATEREV' 'ZFAPAR_TRN' 'DATEREV' '' '12' 'PostDtRev' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'WAERS' 'BSEG' 'WAERS' '' '' 'Curr.' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'AMOUNT' 'BSEG' 'DMBTR' '' '15' 'Amount' '' '' '' '' '' 'WAERS'
        '' '' '' '' '' '' 'X' '',
        'DPP' 'BSEG' 'DMBTR' '' '15' 'DPP' '' '' '' '' '' 'WAERS' '' ''
        '' '' '' '' 'X' '',
        'PPN' 'BSEG' 'DMBTR' '' '15' 'PPN' '' '' '' '' '' 'WAERS' '' ''
        '' '' '' '' 'X' '',
        'PPH23' 'BSEG' 'DMBTR' '' '15' 'PPh23' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' 'X' '',
        'ROUTE' 'VTTK' 'ROUTE' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'ADD04' 'VTTK' 'ADD04' '' '' 'Beban' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' ''.
    WHEN pa_detl.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'LIFNR' 'LFA1' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'MASATX' 'ZGDTXDT0003' 'MASATX' '' '12' 'Masa Pajak' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'VBELN' 'ZGDTXDT0003' 'VBELN' '' '15' 'Invoice No.' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'YEARTX' 'ZGDTXDT0003' 'YEARTX' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'VKBUR' 'ZFAPAR_TRN' 'VKBUR' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BELNR' 'ZFAPAR_TRN' 'BELNR' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BUDAT' 'ZFAPAR_TRN' 'BUDAT' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BELNRREV' 'ZFAPAR_TRN' 'BELNRREV' '' '15' 'Doc.Rev' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'DATEREV' 'ZFAPAR_TRN' 'DATEREV' '' '12' 'PostDtRev' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'TKNUM' 'VTTK' 'TKNUM' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'MATNR' 'ZGDTXDT0002' 'MATNR' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '' 'X' '',
        'WAERS' 'BSEG' 'WAERS' '' '' 'Curr.' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'AMOUNT' 'BSEG' 'DMBTR' '' '15' 'Amount' '' '' '' '' '' 'WAERS'
        '' '' '' '' '' '' 'X' '',
        'DPP' 'BSEG' 'DMBTR' '' '15' 'DPP' '' '' '' '' '' 'WAERS' '' ''
        '' '' '' '' 'X' '',
        'PPN' 'BSEG' 'DMBTR' '' '15' 'PPN' '' '' '' '' '' 'WAERS' '' ''
        '' '' '' '' 'X' '',
        'PPH23' 'BSEG' 'DMBTR' '' '15' 'PPh23' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' 'X' '',
        'ROUTE' 'VTTK' 'ROUTE' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'ADD04' 'VTTK' 'ADD04' '' '' 'Beban' '' '' '' '' '' '' '' '' ''
        '' '' '' 'X' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refr01.
  IF fu_refr01 IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_maingrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcat  USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_colpos)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_icon)
                          value(fu_just)
                          value(fu_edit)
                          value(fu_colopt)
                          value(fu_emphasize).

  DATA: ld_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-col_pos           = fu_colpos.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.

  CASE fu_types.
    WHEN 'GT_OUT'.
      APPEND ld_fieldcat TO gt_main_fieldcat.
  ENDCASE.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-cwidth_opt          = selected.
  CASE 'X'.
    WHEN pa_proc.
      gs_layout_alv-box_fname           = 'CHECK'.
      gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
      gs_layout_alv-no_rowmark          = selected.
      gs_layout_alv-stylefname          = 'STYLE'.
    WHEN pa_reve.
      gs_layout_alv-box_fname           = 'CHECK'.
      gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
      gs_layout_alv-no_rowmark          = selected.
      gs_layout_alv-stylefname          = 'STYLE'.
    WHEN pa_rept OR pa_detl.
      gs_layout_alv-box_fname           = 'CHECK'.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB_GRID
*&---------------------------------------------------------------------*
FORM f_build_sort_tab_grid .
  CLEAR gt_main_sort.

  CASE 'X'.
    WHEN pa_rept OR pa_detl.
      gt_main_sort-fieldname = 'VBELN'.
      gt_main_sort-up      = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
      gt_main_sort-fieldname = 'BELNR'.
      gt_main_sort-up      = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT_TAB_GRID

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_valid.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_container IS INITIAL.
        CALL METHOD g_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR : g_container, g_maingrid.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN '&SIM'.
      CLEAR lv_valid.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CLEAR : gt_error[], gt_error.
        PERFORM f_clear_icon.
        PERFORM f_collect_data  USING ''.
      ENDIF.

    WHEN '&POS'.
      CLEAR lv_valid.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CLEAR : gt_error[], gt_error.
        PERFORM f_clear_icon.
        PERFORM f_collect_data  USING 'X'.
        PERFORM f_save_data USING ''.
      ENDIF.

    WHEN '&REV'.
      CLEAR lv_valid.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CLEAR : gt_error[], gt_error.
        PERFORM f_clear_icon.
        PERFORM f_reversal_data.
        PERFORM f_save_data USING 'X'.
      ENDIF.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.
  ENDCASE.

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE header OUTPUT.
  DATA : lr_rows      TYPE REF TO cl_salv_form_layout_grid,
         lr_element   TYPE REF TO cl_salv_form_element,
         lr_container TYPE REF TO cl_gui_container,
         lr_dydos     TYPE REF TO cl_salv_form_dydos.

  CREATE OBJECT lr_rows.

  g_content = lr_rows.

  CLEAR lr_element.
  PERFORM header_line CHANGING lr_element.
  lr_rows->set_element( r_element = lr_element
                        row       = 1
                        column    = 1 ).

  CREATE OBJECT lr_container
    TYPE
      cl_gui_custom_container
    EXPORTING
      container_name          = 'CC_HEADER'.

  CREATE OBJECT lr_dydos
    EXPORTING
      r_container = lr_container
      r_content   = g_content.

  lr_dydos->display( ).
ENDMODULE.                 " HEADER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  HEADER_LINE
*&---------------------------------------------------------------------*
FORM header_line  CHANGING cr_element TYPE REF TO cl_salv_form_element.

  DATA: lr_rows   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_2 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text.

  CREATE OBJECT lr_rows.

*  lr_rows->create_header_information(
*    row    = 1
*    column = 1
*    text   = text-t03 ).
*
*  lr_rows->add_row( ).

  lr_grid = lr_rows->create_grid(
              row    = 3
              column = 1 ).
  lr_grid_1 = lr_grid->create_grid(
    row    = 1
    column = 1 ).
  lr_grid_2 = lr_grid->create_grid(
    row    = 1
    column = 2 ).

  lr_label = lr_grid_1->create_label(
    row    = 1
    column = 1
    text   = text-h01 ).
  lr_text = lr_grid_1->create_text(
    row    = 1
    column = 2
    text   = '8020' ).
  lr_grid_1->create_text(
    row    = 1
    column = 3
    text   = 'PT. Tempo' ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 2
    column = 1
    text   = text-h02 ).
  lr_text = lr_grid_1->create_text(
    row    = 2
    column = 2
    text   = 'Januari 2018' ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_2->create_label(
    row    = 1
    column = 1
    text   = text-h11 ).
  lr_text = lr_grid_2->create_text(
    row    = 1
    column = 2
    text   = '0200' ).
  lr_grid_2->create_text(
    row    = 1
    column = 3
    text   = 'Tempo Head Office - Jakarta' ).
  lr_label->set_label_for( lr_text ).

  lr_rows->add_row( ).

*  lr_rows->create_action_information(
*    row    = 5
*    column = 1
*    text   = text-t09 ).

  cr_element = lr_rows.
ENDFORM.                    " HEADER_LINE

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check fu_container.
  DATA : ls_out             LIKE LINE OF gt_out,
         ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl.

  CALL METHOD g_maingrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  lv_style = cl_gui_alv_grid=>mc_style_disabled.
  ls_stylerow-fieldname = 'CHECK'.
  ls_stylerow-style     = lv_style.
  APPEND ls_stylerow TO lt_stylerow.

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        IF ls_out-style = lt_stylerow.
          CONTINUE.
        ENDIF.
        ls_out-check  = fu_check.
        MODIFY gt_out FROM ls_out TRANSPORTING check.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDSTYLE
*&---------------------------------------------------------------------*
FORM f_fieldstyle  USING    fu_fieldname fu_edit
                   CHANGING fc_style.
  DATA : ls_stylerow          TYPE lvc_s_styl,
         lv_style             TYPE lvc_s_styl-style,
         lt_main_stylerow     TYPE lvc_t_styl.

  CLEAR : ls_stylerow.

  IF fu_edit IS INITIAL.
    lv_style      = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  ls_stylerow-fieldname = fu_fieldname.
  ls_stylerow-style     = lv_style.

  INSERT ls_stylerow INTO TABLE lt_main_stylerow.
  fc_style  = lt_main_stylerow.
ENDFORM.                    " F_FIELDSTYLE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
      obj_key           = obj_key
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZGDTXDT0003
*&---------------------------------------------------------------------*
FORM f_get_zgdtxdt0003 .
  DATA : lt_002   TYPE STANDARD TABLE OF zgdtxdt0002.

  CASE 'X'.
    WHEN pa_proc.
      SELECT *
        FROM zgdtxdt0003
        INTO CORRESPONDING FIELDS OF TABLE gt_003
        WHERE bukrs    = pa_bukrs
          AND kunrg    = pa_kunnr
          AND masatx   = pa_mastx
          AND fakdat   IN so_fakdt
          AND fakturno IN so_fakno
          AND vbeln    IN so_vbeln
          AND batal    = space.
    WHEN pa_rept OR pa_detl.
      SELECT *
        FROM zgdtxdt0003
        INTO CORRESPONDING FIELDS OF TABLE gt_003
        WHERE bukrs    = pa_bukrs
          AND kunrg    = pa_kunnr
          AND masatx   = pa_mastx
          AND batal    = space.
  ENDCASE.

  IF gt_003[] IS NOT INITIAL.
    SELECT *
      FROM zgdtxdt0002
      INTO CORRESPONDING FIELDS OF TABLE gt_002
      FOR ALL ENTRIES IN gt_003
      WHERE bukrs     = gt_003-bukrs
        AND brnch     = gt_003-brnch
        AND busln     = gt_003-busln
        AND vbeln     = gt_003-vbeln
        AND fakturno  = gt_003-fakturno.

    IF pa_detl IS NOT INITIAL.
      lt_002[] = gt_002[].
      SORT lt_002[] BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_002 COMPARING matnr.
      IF lt_002[] IS NOT INITIAL.
        SELECT *
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_002
          WHERE matnr = lt_002-matnr
            AND spras = sy-langu.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ZGDTXDT0003

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE_DATA
*&---------------------------------------------------------------------*
FORM f_simulate_data .
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.
ENDFORM.                    " F_SIMULATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_DATA
*&---------------------------------------------------------------------*
FORM f_collect_data USING fu_proc.
  DATA : lt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out     LIKE LINE OF lt_out.

  DATA : ls_return    TYPE bapiret2,
         ls_error     TYPE bapiret2,
         lv_error     TYPE xfeld,
         lv_buzei     TYPE bseg-buzei.

  lt_out[]  = gt_out[].
  IF fu_proc IS INITIAL.
    DELETE lt_out WHERE check IS INITIAL.
  ELSE.
    DELETE lt_out WHERE check IS INITIAL
                     OR icon <> icon_led_green
                     OR belnr <> space.
  ENDIF.

  IF lt_out[] IS INITIAL.
    MESSAGE s000(zab) WITH 'No data to executed' DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT lt_out INTO ls_out.
      CLEAR : gt_post[], gt_post, gs_post, lv_error.
      PERFORM f_preparing_data USING ls_out.

      PERFORM f_clear_bapi.

      READ TABLE gt_post INTO gs_post INDEX 1.
      IF sy-subrc = 0.
        PERFORM f_document_header USING 'RFBU' gs_post-bukrs gs_post-blart
                                        ls_out-vbeln gs_post-route.
*                                        gs_post-zuonr gs_post-route.
      ENDIF.

      LOOP AT gt_post INTO gs_post.
        ADD 1 TO lv_buzei.

        CASE gs_post-koart.
          WHEN 'A'.
          WHEN 'S'.
            PERFORM f_account_gl USING lv_buzei ls_out-vbeln gs_post-zuonr.
          WHEN 'K'.
            PERFORM f_account_payable USING lv_buzei ls_out-vbeln gs_post-zuonr.
            ls_out-wrbtr  = gs_post-wrbtr.
            ls_out-gsber  = gs_post-gsber.
          WHEN 'D'.
            PERFORM f_account_receivable USING lv_buzei ls_out-vbeln gs_post-zuonr.
            ls_out-wrbtr  = gs_post-wrbtr.
            ls_out-gsber  = gs_post-gsber.
        ENDCASE.

        PERFORM f_profit_segment USING : lv_buzei 'WWPFN' gs_post-wwpfn,
                                         lv_buzei 'WWPOS' gs_post-wwpos.
      ENDLOOP.

      IF fu_proc IS INITIAL.
        PERFORM f_simulate_data.
      ELSE.
        PERFORM f_posting_data.
      ENDIF.

      LOOP AT return INTO ls_return.
        IF ls_return-type = 'E'.
          lv_error            = selected.
          ls_error-type       = ls_return-type.
          ls_error-id         = ls_return-id.
          ls_error-number     = ls_return-number.
          ls_error-message    = ls_return-message.
          ls_error-message_v1 = ls_return-message_v1.
          ls_error-message_v2 = ls_return-message_v2.
          ls_error-message_v3 = ls_return-message_v3.
          APPEND ls_error TO gt_error.
          CLEAR ls_error.
        ENDIF.
      ENDLOOP.

      IF lv_error IS INITIAL.
        ls_out-icon   = icon_led_green.
      ELSE.
        ls_out-icon   = icon_led_red.
      ENDIF.

      IF obj_type IS NOT INITIAL.
        ls_out-belnr    = obj_key(10).
        ls_out-gjahr    = obj_key+14(4).

        PERFORM f_change_bline_date TABLES accountgl
                                    USING ls_out-belnr ls_out-bukrsx
                                          ls_out-gjahr ls_out-fakdat.

        CLEAR ls_out-check.
        PERFORM f_fieldstyle USING : 'CHECK' ''
                             CHANGING ls_out-style.

      ENDIF.

      MODIFY gt_out FROM ls_out TRANSPORTING icon belnr gjahr
                                             wrbtr gsber
                                WHERE bukrs = ls_out-bukrs
                                  AND kunnr = ls_out-kunnr
                                  AND vbeln = ls_out-vbeln.
      CLEAR ls_out.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_COLLECT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_POSTING_KEY
*&---------------------------------------------------------------------*
FORM f_get_posting_key .
  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.
ENDFORM.                    " F_GET_POSTING_KEY

*&---------------------------------------------------------------------*
*&      Form  F_PREPARING_DATA
*&---------------------------------------------------------------------*
FORM f_preparing_data  USING    fs_out     TYPE ty_out.

  DATA : ls_aparr   LIKE LINE OF gt_aparr,
         ls_apard   LIKE LINE OF gt_apard,
         ls_out     LIKE LINE OF gt_out,
         lv_hkont   TYPE bseg-hkont,
         lv_kunnr   TYPE bseg-kunnr,
         lv_lifnr   TYPE bseg-lifnr,
         lv_wrbtr   TYPE bseg-wrbtr,
         lv_total   TYPE bseg-wrbtr,
         ls_tbsl    LIKE LINE OF gt_tbsl,
         ls_bseg    LIKE LINE OF gt_bseg,
         ls_lfa1    LIKE LINE OF gt_lfa1,
         lv_field(40),
         lv_count(1).

  DATA : lt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         lt_post    TYPE STANDARD TABLE OF ty_post INITIAL SIZE 0,
         ls_post    LIKE LINE OF lt_post,
         lt_aparr   TYPE STANDARD TABLE OF zfroute_apar INITIAL SIZE 0,
         ls_xaparr  LIKE LINE OF lt_aparr,
         ls_006     LIKE LINE OF gt_006,
         ls_vttk    LIKE LINE OF gt_vttk.

  DATA : lv_newbs   TYPE rf05a-newbs,
         lv_newko   TYPE rf05a-newko,
         lv_add04   TYPE vttk-add04,
         lv_subrc   TYPE sy-subrc.

  FIELD-SYMBOLS : <lfs> TYPE ANY.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE vbeln <> fs_out-vbeln.
  LOOP AT lt_out INTO ls_out.
    CLEAR : ls_aparr, lv_subrc.
    READ TABLE gt_aparr INTO ls_aparr WITH KEY route = ls_out-route
                                               add04 = ls_out-add04
                                               bukrs = ls_out-bukrsx
                                               kunwe = ls_out-kunnr.
    IF sy-subrc = 0.
      lv_subrc = sy-subrc.
    ELSE.
      CLEAR ls_aparr.
      READ TABLE gt_aparr INTO ls_aparr WITH KEY route = ls_out-route
                                                 add04 = ls_out-add04
                                                 bukrs = ls_out-bukrsx.
      lv_subrc = sy-subrc.
    ENDIF.

    IF lv_subrc = 0.
      ls_xaparr-route = ls_aparr-route.
      ls_xaparr-add04 = ls_aparr-add04.
      ls_xaparr-bukrs = ls_aparr-bukrs.
      ls_xaparr-blart = ls_aparr-blart.
      ls_xaparr-werks = ls_aparr-werks.
      ls_xaparr-vkbur = ls_aparr-vkbur.
      ls_xaparr-vbund = ls_aparr-vbund.
      DO 6 TIMES.
        ADD 1 TO lv_count.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-NEWBS' lv_count
                                CHANGING ls_xaparr-newbs1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-NEWKO' lv_count
                                CHANGING ls_xaparr-newko1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-NEWBS_L' lv_count
                                CHANGING ls_xaparr-newbs_l1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-NEWKO_L' lv_count
                                CHANGING ls_xaparr-newko_l1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-NEWUM' lv_count
                                CHANGING ls_xaparr-newum1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-GSBER' lv_count
                                CHANGING ls_xaparr-gsber1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-KOSTL' lv_count
                                CHANGING ls_xaparr-kostl1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-WWPFN' lv_count
                                CHANGING ls_xaparr-wwpfn1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-WWPOS' lv_count
                                CHANGING ls_xaparr-wwpos1.
        PERFORM f_field_symbols USING ls_aparr
                                      'FS_APARR-KET' lv_count
                                CHANGING ls_xaparr-ket1.

        IF ls_xaparr-newbs1 IS NOT INITIAL.
          APPEND ls_xaparr TO lt_aparr.
        ENDIF.
      ENDDO.
      CLEAR ls_xaparr.
    ENDIF.
    CLEAR lv_count.
  ENDLOOP.

  SORT lt_aparr BY route add04 newbs1 newko1 newbs_l1 newko_l1.
  DELETE ADJACENT DUPLICATES FROM lt_aparr
                             COMPARING route add04
                                       newbs1 newko1
                                       newbs_l1 newko_l1.

  LOOP AT gt_bseg INTO ls_bseg WHERE bukrs = fs_out-bukrs
                                 AND belnr = fs_out-vbeln
                                 AND gjahr = fs_out-fakdat(4).
    CASE ls_bseg-koart.
      WHEN 'A'.
      WHEN 'S'.
        lv_newbs  = ls_bseg-bschl.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_bseg-hkont
          IMPORTING
            output = lv_newko.
      WHEN 'D'.
        lv_newbs  = ls_bseg-bschl.
        lv_newko  = ls_bseg-kunnr.
      WHEN 'K'.
        lv_newbs  = ls_bseg-bschl.
        lv_newko  = ls_bseg-lifnr.
    ENDCASE.

    IF ls_bseg-vbel2 IS INITIAL AND
      ls_bseg-posn2 IS INITIAL.
      READ TABLE lt_aparr INTO ls_aparr WITH KEY newbs_l1 = lv_newbs
                                                 newko_l1 = lv_newko.
      IF sy-subrc = 0.
        PERFORM f_collect_process_fields USING ls_aparr fs_out-fakturno.
      ENDIF.
    ELSE.
      CLEAR ls_006.
      READ TABLE gt_006 INTO ls_006 WITH KEY vbap_vbeln = ls_bseg-vbel2
                                             posnr      = ls_bseg-posn2.
      IF sy-subrc = 0.
        CLEAR ls_vttk.
        READ TABLE gt_vttk INTO ls_vttk WITH KEY tknum  = ls_006-tknum.
        IF sy-subrc = 0.
          CLEAR : ls_aparr, lv_add04.
          IF ls_vttk-add04 IS INITIAL.
            lv_add04    = 'DIST'.
          ELSE.
            lv_add04    = ls_vttk-add04.
          ENDIF.
          READ TABLE lt_aparr INTO ls_aparr WITH KEY route    = ls_vttk-route
                                                     add04    = lv_add04
                                                     newbs_l1 = lv_newbs
                                                     newko_l1 = lv_newko.
          IF sy-subrc = 0.
            PERFORM f_collect_process_fields USING ls_aparr fs_out-fakturno.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    gs_post-wrbtr = ls_bseg-wrbtr.
    IF gs_post-shkzg = 'H'.
      lv_wrbtr  = ls_bseg-wrbtr * -1.
    ELSE.
      lv_wrbtr  = ls_bseg-wrbtr.
    ENDIF.
    ADD lv_wrbtr TO lv_total.
    APPEND gs_post TO gt_post.
    CLEAR gs_post.
  ENDLOOP.

  IF lv_total <> 0.
    READ TABLE gt_apard INTO ls_apard INDEX 1.
    IF sy-subrc = 0.
      IF lv_total > 0.
        gs_post-bukrs  = fs_out-bukrs.
        gs_post-koart  = 'S'.
        gs_post-newbs  = '40'.
        gs_post-newko  = ls_apard-hkont.
        gs_post-kostl  = ls_apard-kostl.
        gs_post-wwpfn  = ls_apard-wwpfn.
        gs_post-wwpos  = ls_apard-wwpos.
        gs_post-ket    = ls_apard-ket.
        gs_post-shkzg  = 'S'.
        gs_post-wrbtr  = lv_total.
      ELSEIF lv_total < 0.
        gs_post-bukrs  = fs_out-bukrs.
        gs_post-koart  = 'S'.
        gs_post-newbs  = '50'.
        gs_post-newko  = ls_apard-hkont.
        gs_post-kostl  = ls_apard-kostl.
        gs_post-wwpfn  = ls_apard-wwpfn.
        gs_post-wwpos  = ls_apard-wwpos.
        gs_post-ket    = ls_apard-ket.
        gs_post-shkzg  = 'H'.
        gs_post-wrbtr  = lv_total.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PREPARING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_BAPI
*&---------------------------------------------------------------------*
FORM f_clear_bapi .
  CLEAR : documentheader, accountgl[], accountgl, accountpayable[],
          accountpayable, accountreceivable[], accountreceivable,
          extension1[], extension1, currencyamount[],
          currencyamount, criteria[], criteria,
          return[], return, obj_type.
ENDFORM.                    " F_CLEAR_BAPI

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
FORM f_document_header  USING    fu_glvor fu_bukrs fu_blart fu_zuonr
                                 fu_route.
  documentheader-bus_act     = fu_glvor.
  documentheader-username    = sy-uname.
  documentheader-comp_code   = fu_bukrs.
  documentheader-doc_date    = pa_budat.
  documentheader-pstng_date  = pa_bldat.
  documentheader-doc_type    = fu_blart.
  documentheader-ref_doc_no  = fu_zuonr.
  SELECT SINGLE bezei
    FROM tvrot
    INTO documentheader-header_txt
    WHERE spras = sy-langu
      AND route = fu_route.
ENDFORM.                    " F_DOCUMENT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT
*&---------------------------------------------------------------------*
FORM f_account  USING    fu_field fu_count
                CHANGING fc_newko.

  FIELD-SYMBOLS : <lfs> TYPE ANY.

  DATA : lv_field(40).

  CONCATENATE fu_field fu_count INTO lv_field.
  ASSIGN (lv_field) TO <lfs>.
  IF <lfs> IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <lfs>
      IMPORTING
        output = fc_newko.
  ENDIF.
ENDFORM.                    " F_ACCOUNT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDSYMBOL
*&---------------------------------------------------------------------*
FORM f_fieldsymbol  USING    fs_aparr   LIKE LINE OF gt_aparr
                             fu_text1 fu_text2 fu_count.

  DATA : lv_field(40).

  FIELD-SYMBOLS : <lfs>  TYPE ANY.

  CONCATENATE fu_text1 fu_text2 fu_count INTO lv_field.
  ASSIGN (lv_field) TO <lfs>.

  CASE fu_text2.
    WHEN 'POSTKEY'.
      gs_post-newbs = <lfs>.
    WHEN 'HKONT'.
      gs_post-newko = <lfs>.
    WHEN 'SPGL'.
      gs_post-newum = <lfs>.
    WHEN 'GSBER'.
      gs_post-gsber = <lfs>.
    WHEN 'KOSTL'.
      gs_post-kostl = <lfs>.
    WHEN 'WWPFN'.
      gs_post-wwpfn = <lfs>.
    WHEN 'WWPOS'.
      gs_post-wwpos = <lfs>.
    WHEN 'KET'.
      gs_post-ket = <lfs>.
  ENDCASE.

  UNASSIGN <lfs>.
ENDFORM.                    " F_FIELDSYMBOL

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_GL
*&---------------------------------------------------------------------*
FORM f_account_gl  USING fu_buzei fu_vbeln fu_zuonr.
  DATA : ls_gl  LIKE LINE OF accountgl,
         ls_ca  LIKE LINE OF currencyamount,
         ls_cr  LIKE LINE OF criteria,
         ls_e1  LIKE LINE OF extension1.

  ls_gl-itemno_acc            = fu_buzei.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_post-newko
    IMPORTING
      output = ls_gl-gl_account.

  ls_gl-bus_area              = gs_post-gsber.
  ls_gl-trade_id              = gs_post-vbund.
  ls_gl-costcenter            = gs_post-kostl.
  ls_gl-ref_key_3             = gs_post-xref3.
  IF fu_zuonr IS NOT INITIAL.
    ls_gl-alloc_nmbr            = fu_zuonr.
  ELSE.
    ls_gl-alloc_nmbr            = fu_vbeln.
  ENDIF.
  ls_gl-item_text             = gs_post-ket.
  APPEND ls_gl TO accountgl.

  ls_ca-itemno_acc    = fu_buzei.
  ls_ca-curr_type     = '00'.
  ls_ca-currency      = 'IDR'.
  PERFORM f_amount_modify CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_e1(3)                = fu_buzei.
  ls_e1+3(2)              = gs_post-newbs.
  APPEND ls_e1 TO extension1.
ENDFORM.                    " F_ACCOUNT_GL

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_PAYABLE
*&---------------------------------------------------------------------*
FORM f_account_payable  USING fu_buzei fu_vbeln fu_zuonr.
  DATA : ls_ap  LIKE LINE OF accountpayable,
         ls_ca  LIKE LINE OF currencyamount,
         ls_cr  LIKE LINE OF criteria,
         ls_e1  LIKE LINE OF extension1.

  ls_ap-itemno_acc    = fu_buzei.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_post-newko
    IMPORTING
      output = ls_ap-vendor_no.

  SELECT SINGLE zterm
    FROM lfb1
    INTO ls_ap-pmnttrms
    WHERE lifnr = ls_ap-vendor_no.

  ls_ap-bus_area      = gs_post-gsber.
  ls_ap-ref_key_3     = gs_post-xref3.
  IF fu_zuonr IS NOT INITIAL.
    ls_ap-alloc_nmbr    = fu_zuonr.
  ELSE.
    ls_ap-alloc_nmbr    = fu_vbeln.
  ENDIF.
  ls_ap-item_text     = gs_post-ket.
  APPEND ls_ap TO accountpayable.

  ls_ca-itemno_acc    = fu_buzei.
  ls_ca-curr_type     = '00'.
  ls_ca-currency      = 'IDR'.
  PERFORM f_amount_modify CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_e1(3)                = fu_buzei.
  ls_e1+3(2)              = gs_post-newbs.
  APPEND ls_e1 TO extension1.
ENDFORM.                    " F_ACCOUNT_PAYABLE

*&---------------------------------------------------------------------*
*&      Form  F_ACCOUNT_RECEIVABLE
*&---------------------------------------------------------------------*
FORM f_account_receivable  USING fu_buzei fu_vbeln fu_zuonr.
  DATA : ls_ar  LIKE LINE OF accountreceivable,
         ls_ca  LIKE LINE OF currencyamount,
         ls_cr  LIKE LINE OF criteria,
         ls_e1  LIKE LINE OF extension1.

  ls_ar-itemno_acc    = fu_buzei.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_post-newko
    IMPORTING
      output = ls_ar-customer.

  ls_ar-bus_area      = gs_post-gsber.
  ls_ar-ref_key_3     = gs_post-xref3.
  IF fu_zuonr IS NOT INITIAL.
    ls_ar-alloc_nmbr    = fu_zuonr.
  ELSE.
    ls_ar-alloc_nmbr    = fu_vbeln.
  ENDIF.
  ls_ar-item_text     = gs_post-ket.
  APPEND ls_ar TO accountreceivable.

  ls_ca-itemno_acc    = fu_buzei.
  ls_ca-curr_type     = '00'.
  ls_ca-currency      = 'IDR'.
  PERFORM f_amount_modify CHANGING ls_ca-amt_doccur.
  APPEND ls_ca TO currencyamount.

  ls_e1(3)                = fu_buzei.
  ls_e1+3(2)              = gs_post-newbs.
  APPEND ls_e1 TO extension1.
ENDFORM.                    " F_ACCOUNT_RECEIVABLE

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNT_MODIFY
*&---------------------------------------------------------------------*
FORM f_amount_modify  CHANGING fc_wrbtr.
  DATA : lv_value(50).

  IF gs_post-shkzg EQ 'H'.
    gs_post-wrbtr = gs_post-wrbtr * -1.
  ENDIF.

  WRITE gs_post-wrbtr TO lv_value CURRENCY 'IDR'.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.

  fc_wrbtr = lv_value.
ENDFORM.                    " F_AMOUNT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ICON
*&---------------------------------------------------------------------*
FORM f_clear_icon .
  DATA : ls_out   LIKE LINE OF gt_out.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-check IS INITIAL AND
      ls_out-icon = icon_led_red.
      CLEAR ls_out-icon.
      MODIFY gt_out FROM ls_out TRANSPORTING icon.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CLEAR_ICON

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data USING fu_proc.
  DATA : lt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out     LIKE LINE OF lt_out.

  DATA : lt_apart   TYPE STANDARD TABLE OF zfapar_trn INITIAL SIZE 0,
         ls_apart   LIKE LINE OF lt_apart,
         ls_aparb   LIKE LINE OF gt_aparb.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE icon <> icon_led_green.

  LOOP AT lt_out INTO ls_out.
    IF fu_proc IS INITIAL.
      READ TABLE gt_aparb INTO ls_aparb WITH KEY kunnr = ls_out-kunnr.
      IF sy-subrc = 0.
        ls_apart-bukrs        = ls_aparb-bukrs.
      ELSE.
        ls_apart-bukrs        = '8020'.
      ENDIF.
      ls_apart-gjahr        = ls_out-gjahr.
      ls_apart-belnr        = ls_out-belnr.
      ls_apart-bukrs_s      = ls_out-bukrs.
      ls_apart-fakturno     = ls_out-fakturno.
      ls_apart-vbeln        = ls_out-vbeln.
      ls_apart-gsber        = ls_out-gsber.
      ls_apart-vkbur        = ls_out-vkbur.
      ls_apart-kunnr        = ls_out-kunnr.
      ls_apart-budat        = pa_budat.
      ls_apart-bldat        = pa_bldat.
      ls_apart-zupos        = sy-uname.
      ls_apart-zdpos        = sy-datum.
      TRY .
          INSERT zfapar_trn FROM ls_apart.
        CATCH cx_sy_open_sql_db .
      ENDTRY.
    ELSE.
      READ TABLE gt_apart INTO ls_apart WITH KEY bukrs     = ls_out-bukrs
                                                 belnr     = ls_out-belnr
                                                 gjahr     = ls_out-gjahr
                                                 fakturno  = ls_out-fakturno
                                                 vbeln     = ls_out-vbeln.
      IF sy-subrc = 0.
        TRY .
            UPDATE zfapar_trn SET belnrrev  = ls_out-belnrrev
                                  useridrev = sy-uname
                                  daterev   = sy-datum
                              WHERE bukrs     = ls_out-bukrs
                                AND belnr     = ls_out-belnr
                                AND gjahr     = ls_out-gjahr
                                AND fakturno  = ls_out-fakturno
                                AND vbeln     = ls_out-vbeln.
          CATCH cx_sy_open_sql_db .
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REVERSAL_DATA
*&---------------------------------------------------------------------*
FORM f_reversal_data .
  DATA : lt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out     LIKE LINE OF lt_out.

  DATA : lt_bdcmsg    LIKE bdcmsgcoll OCCURS 10 WITH HEADER LINE,
         ls_bdcmsg    LIKE bdcmsgcoll,
         lt_bdcdata   LIKE bdcdata OCCURS 10 WITH HEADER LINE,
         lv_error     TYPE xfeld,
         ls_error     TYPE bapiret2,
         lv_mode,
         lv_update.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  lv_mode   = 'N'.
  lv_update = 'S'.

  LOOP AT lt_out INTO ls_out.
    CLEAR: lt_bdcdata[], lt_bdcmsg[], lt_bdcdata, lt_bdcmsg.

    PERFORM f_bdc_data TABLES lt_bdcdata USING:
         'X'  'SAPMF05A'      '0105',
         ' '  'BDC_OKCODE'    '=BU',
         ' '  'RF05A-BELNS'   ls_out-belnr,
         ' '  'BKPF-BUKRS'    ls_out-bukrs,
         ' '  'RF05A-GJAHS'   ls_out-gjahr,
         ' '  'UF05A-STGRD'   '01'.

    CALL TRANSACTION 'FB08' USING lt_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO lt_bdcmsg.

    LOOP AT lt_bdcmsg INTO ls_bdcmsg.
      IF ls_bdcmsg-msgtyp = 'E'.
        lv_error            = selected.
        ls_error-type       = ls_bdcmsg-msgtyp.
        ls_error-id         = ls_bdcmsg-msgid.
        ls_error-number     = ls_bdcmsg-msgnr.
        ls_error-message_v1 = ls_bdcmsg-msgv1.
        ls_error-message_v2 = ls_bdcmsg-msgv1.
        ls_error-message_v3 = ls_bdcmsg-msgv1.
        APPEND ls_error TO gt_error.
        CLEAR ls_error.
      ENDIF.
    ENDLOOP.

    IF lv_error IS INITIAL.
      ls_out-icon   = icon_led_green.
      READ TABLE lt_bdcmsg INDEX 1.
      IF sy-subrc = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lt_bdcmsg-msgv1
          IMPORTING
            output = ls_out-belnrrev.
      ENDIF.
      CLEAR ls_out-check.
      PERFORM f_fieldstyle USING : 'CHECK' ''
                           CHANGING ls_out-style.
    ELSE.
      ls_out-icon   = icon_led_red.
    ENDIF.

    MODIFY gt_out FROM ls_out TRANSPORTING check icon belnrrev style
                              WHERE bukrs = ls_out-bukrs
                                AND kunnr = ls_out-kunnr
                                AND vbeln = ls_out-vbeln.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_REVERSAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SYMBOLS
*&---------------------------------------------------------------------*
FORM f_field_symbols  USING    fs_aparr LIKE LINE OF gt_aparr
                               fu_field fu_count
                      CHANGING fc_value.
  FIELD-SYMBOLS : <lfs> TYPE ANY.

  DATA : lv_field(40).

  CLEAR fc_value.
  CONCATENATE fu_field fu_count INTO lv_field.
  ASSIGN (lv_field) TO <lfs>.
  fc_value = <lfs>.
  UNASSIGN <lfs>.
ENDFORM.                    " F_FIELD_SYMBOLS

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_PROCESS_FIELDS
*&---------------------------------------------------------------------*
FORM f_collect_process_fields  USING    fs_aparr LIKE LINE OF gt_aparr
                                        fu_fakturno.
  DATA : ls_tbsl  LIKE LINE OF gt_tbsl,
         ls_aparb LIKE LINE OF gt_aparb.

  gs_post-bukrs  = fs_aparr-bukrs.
  gs_post-blart  = fs_aparr-blart.
  gs_post-vbund  = fs_aparr-vbund.
  gs_post-vkbur  = fs_aparr-vkbur.
  gs_post-newbs  = fs_aparr-newbs1.
  gs_post-newko  = fs_aparr-newko1.
  gs_post-newum  = fs_aparr-newum1.
  gs_post-gsber  = fs_aparr-gsber1.
  gs_post-kostl  = fs_aparr-kostl1.
  gs_post-wwpfn  = fs_aparr-wwpfn1.
  gs_post-wwpos  = fs_aparr-wwpos1.
  gs_post-ket    = fs_aparr-ket1.
  gs_post-route  = fs_aparr-route.
  gs_post-add04  = fs_aparr-add04.

  IF fs_aparr-newko1 = '00000000142200200'.
    READ TABLE gt_aparb INTO ls_aparb WITH KEY kunnr = pa_kunnr.
    IF sy-subrc = 0.
      SELECT SINGLE stceg
        FROM lfa1
        INTO gs_post-xref3
        WHERE lifnr = ls_aparb-lifnr.
    ENDIF.
    gs_post-zuonr  = fu_fakturno.
  ENDIF.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl WITH KEY bschl = gs_post-newbs.
  IF sy-subrc = 0.
    gs_post-koart = ls_tbsl-koart.
    gs_post-shkzg = ls_tbsl-shkzg.
  ENDIF.
ENDFORM.                    " F_COLLECT_PROCESS_FIELDS

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_BLINE_DATE
*&---------------------------------------------------------------------*
FORM f_change_bline_date  TABLES   accountgl STRUCTURE bapiacgl09
                          USING    fu_belnr fu_bukrs fu_gjahr fu_bldat.

  DATA: lv_mode   VALUE 'N',
        lv_update VALUE 'S',
        lv_bldat(8).

  CONCATENATE fu_bldat+6(2) fu_bldat+4(2) fu_bldat(4) INTO lv_bldat.

  LOOP AT accountgl.
    CLEAR: t_bdcdata,t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    IF accountgl-gl_account EQ '0142200200'.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0102',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'RF05L-BELNR'   fu_belnr,
           ' '  'RF05L-BUKRS'   fu_bukrs,
           ' '  'RF05L-GJAHR'   fu_gjahr,
           ' '  'RF05L-BUZEI'   space,
           ' '  'RF05L-XKSAK'   'X'.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '=AE',
           ' '  'BSEG-ZFBDT'    lv_bldat.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.

      CALL TRANSACTION 'FB09' USING t_bdcdata
                              MODE lv_mode
                              UPDATE lv_update
                              MESSAGES INTO t_bdcmsg.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_BLINE_DATE

*&---------------------------------------------------------------------*
*&      Form  F_PROFIT_SEGMENT
*&---------------------------------------------------------------------*
FORM f_profit_segment  USING    fu_buzei fu_fieldname fu_character.
  DATA : ls_cr  LIKE LINE OF criteria.

  IF fu_character IS NOT INITIAL.
    ls_cr-itemno_acc = fu_buzei.
    ls_cr-fieldname  = fu_fieldname.
    ls_cr-character  = fu_character.
    APPEND ls_cr TO criteria.
  ENDIF.
ENDFORM.                    " F_PROFIT_SEGMENT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_OUT
*&---------------------------------------------------------------------*
FORM f_validate_out .
  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   LIKE LINE OF lt_xout,
         ls_out    LIKE LINE OF gt_out.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE vkbur IS NOT INITIAL.

  LOOP AT lt_xout INTO ls_xout.
    LOOP AT gt_out INTO ls_out WHERE vbeln = ls_xout-vbeln.
      ls_out-icon = icon_led_red.
      PERFORM f_fieldstyle USING : 'CHECK' ''
                           CHANGING ls_out-style.
      MODIFY gt_out FROM ls_out
                    TRANSPORTING icon style.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_OUT
