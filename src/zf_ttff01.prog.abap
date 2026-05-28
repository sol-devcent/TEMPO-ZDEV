*&---------------------------------------------------------------------*
*&  Include           ZF_TTFF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  DATA : profiles      TYPE STANDARD TABLE OF bapiprof INITIAL SIZE 0,
         ls_profiles   TYPE bapiprof,
         return        TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
         lv_subrc      TYPE sy-subrc.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      profiles = profiles
      return   = return.

  LOOP AT profiles INTO ls_profiles.
    IF ls_profiles-bapiprof = 'SAP_ALL' OR
      ls_profiles-bapiprof = 'SAP_NEW.'.
      lv_subrc = 4.
    ENDIF.
  ENDLOOP.

  IF lv_subrc IS INITIAL.
    AUTHORITY-CHECK OBJECT 'ZFTTFCAB'
            ID 'ACTVT' FIELD '01'.
    IF sy-subrc = 0.
*      LOOP AT SCREEN.
*        CASE screen-group1.
*          WHEN 'R01'.
*            screen-active  = 0.
*        ENDCASE.
*        MODIFY SCREEN.
*      ENDLOOP.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN pa_cust OR pa_paym.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '',
                                      'SZU' '0' '' '',
                                      'PST' '0' '' '',
                                      'STG' '0' '' '',
                                      'PVA' '0' '' '',
                                      'SVK' '0' '' ''.
    WHEN pa_data.
      PERFORM f_modify_screen USING : 'PKU' '0' '' '',
                                      'STG' '0' '' '',
                                      'PVA' '0' '' '',
                                      'SVK' '0' '' ''.

    WHEN pa_rept.
      PERFORM f_modify_screen USING : 'PKU' '0' '' '',
                                      'PST' '0' '' '',
                                      'PVK' '0' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_mess(100).
  CASE 'X'.
    WHEN pa_cust.
      PERFORM f_authorization USING '01'.

      IF gv_subrc IS INITIAL.
        IF pa_bukrs IS INITIAL.
          PERFORM f_screen_error USING 'PBU' ''.
        ENDIF.
        IF pa_vkbur IS INITIAL.
          PERFORM f_screen_error USING 'PVK' ''.
        ENDIF.
        IF pa_kunnr IS INITIAL.
          PERFORM f_screen_error USING 'PKU' ''.
        ELSE.
          PERFORM f_get_customer  USING ''.
          IF gt_knvv[] IS INITIAL.
            CONCATENATE 'Customer' pa_kunnr 'is not defined on SOff.'
            pa_vkbur INTO lv_mess
            SEPARATED BY space.
            PERFORM f_screen_error USING 'PKU' lv_mess.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM f_screen_error USING '' 'You are not authorized'.
      ENDIF.

    WHEN pa_paym.
      PERFORM f_authorization USING '01'.

      IF gv_subrc IS INITIAL.
        IF pa_bukrs IS INITIAL.
          PERFORM f_screen_error USING 'PBU' ''.
        ENDIF.
        IF pa_vkbur IS INITIAL.
          PERFORM f_screen_error USING 'PVK' ''.
        ENDIF.
        IF pa_kunnr IS INITIAL.
          PERFORM f_screen_error USING 'PKU' ''.
        ELSE.
          PERFORM f_get_customer  USING ''.
          IF gt_knvv[] IS INITIAL.
            CONCATENATE 'Customer' pa_kunnr 'is not defined on SOff.'
            pa_vkbur INTO lv_mess
            SEPARATED BY space.
            PERFORM f_screen_error USING 'PKU' lv_mess.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM f_screen_error USING '' 'You are not authorized'.
      ENDIF.

    WHEN pa_data.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
      IF pa_vkbur IS INITIAL.
        PERFORM f_screen_error USING 'PVK' ''.
      ENDIF.
      IF pa_stida IS INITIAL.
        PERFORM f_screen_error USING 'PST' ''.
      ENDIF.

      PERFORM f_number_range USING ''.

    WHEN pa_rept.
      IF pa_bukrs IS INITIAL.
        PERFORM f_screen_error USING 'PBU' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_display.
  IF fu_input <> space.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_display <> space.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-display_3d  = fu_display.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active <> space.
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

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_VARIANT_F4
*&---------------------------------------------------------------------*
FORM f_variant_f4  CHANGING    fu_varnt.
  d_alv_variant-report  = sy-repid.

  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load = 'F'
      i_tabname   = '1'
    CHANGING
      cs_variant  = d_alv_variant
      ct_fieldcat = xfield[].

  fu_varnt = d_alv_variant-variant.
ENDFORM.                    " F_VARIANT_F4

*&---------------------------------------------------------------------*
*&      Form  F_NUMBER_RANGE
*&---------------------------------------------------------------------*
FORM f_number_range USING fu_flag.
  DATA : lv_gjahr   TYPE bsid-gjahr,
         enq        TYPE STANDARD TABLE OF seqg3 INITIAL SIZE 0,
         ls_enq     TYPE seqg3.

  CASE fu_flag.
    WHEN 'LOCK'.
      lv_gjahr  = pa_stida(4).

      SELECT SINGLE *
        FROM zfttfno
        INTO gs_zfttfno
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND gjahr = lv_gjahr.

      CALL FUNCTION 'ENQUEUE_EZTTFNO'
        EXPORTING
          bukrs          = pa_bukrs
          vkbur          = pa_vkbur
          gjahr          = lv_gjahr
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      IF sy-subrc IS NOT INITIAL.
        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            gname                 = 'ZFTTFNO'
          TABLES
            enq                   = enq
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2
            OTHERS                = 3.

        READ TABLE enq INTO ls_enq INDEX 1.

        MESSAGE e000(zab) WITH 'Transaction lock by' ls_enq-guname.
      ENDIF.

    WHEN OTHERS.
      SELECT SINGLE *
        FROM zfttfno
        INTO gs_zfttfno
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND gjahr = pa_stida(4).

      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH 'TTF Number belum dimaintain'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_NUMBER_RANGE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT SINGLE butxt
    FROM t001
    INTO gv_butxt
    WHERE bukrs = pa_bukrs.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO gv_bezei
    WHERE spras = sy-langu
      AND vkbur = pa_vkbur.

  SELECT *
    FROM zfttfcg
    INTO CORRESPONDING FIELDS OF TABLE gt_zfttfcg
    WHERE bukrs = pa_bukrs.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lv_week        TYPE zfttfoutpay-week,
         ls_ttfoutpay   TYPE zfttfoutpay.

  DATA : lt_bsid        TYPE STANDARD TABLE OF bsid INITIAL SIZE 0,
         lt_zftransttf  TYPE STANDARD TABLE OF zftransttf INITIAL SIZE 0,
         lt_zfbid       TYPE STANDARD TABLE OF zfbid INITIAL SIZE 0.

  CASE 'X'.
    WHEN pa_cust.
      SELECT SINGLE name1
        FROM kna1
        INTO gv_name1
        WHERE kunnr = pa_kunnr.

      SELECT *
        FROM zfttfoutbw
        INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbw
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND kunnr = pa_kunnr.

      SELECT *
        FROM zfttfoutbd
        INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbd
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND kunnr = pa_kunnr.

    WHEN pa_paym.
      SELECT SINGLE name1
        FROM kna1
        INTO gv_name1
        WHERE kunnr = pa_kunnr.

      SELECT SINGLE kdgrp
        FROM zfttfoutbd
        INTO gv_kdgrp
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND kunnr = pa_kunnr.

      SELECT *
        FROM zfttfoutpay
        INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutpay
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_vkbur
          AND kunnr = pa_kunnr.

    WHEN pa_data.
      PERFORM f_get_customer  USING '1'.

      IF gt_knvv[] IS NOT INITIAL.
        SELECT *
          FROM zfttfoutbd
          INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbd
          FOR ALL ENTRIES IN gt_knvv
          WHERE bukrs = pa_bukrs
            AND vkbur = gt_knvv-vkbur
            AND kunnr = gt_knvv-kunnr.

        SELECT *
          FROM zfttfoutbw
          INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbw
          FOR ALL ENTRIES IN gt_knvv
          WHERE bukrs = pa_bukrs
            AND vkbur = gt_knvv-vkbur
            AND kunnr = gt_knvv-kunnr.

        SELECT *
          FROM zfttfoutpay
          INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutpay
          FOR ALL ENTRIES IN gt_knvv
          WHERE bukrs = pa_bukrs
            AND vkbur = gt_knvv-vkbur
            AND kunnr = gt_knvv-kunnr.
      ENDIF.

      PERFORM f_get_acc_data.

      lt_bsid[] = gt_bsid[].
      SORT lt_bsid BY bukrs kunnr zuonr vbeln belnr gjahr.
      IF lt_bsid[] IS NOT INITIAL.
        SELECT *
          FROM zftransttf
          INTO CORRESPONDING FIELDS OF TABLE gt_zftransttf
          FOR ALL ENTRIES IN lt_bsid
          WHERE bukrs = lt_bsid-bukrs
            AND kunnr = lt_bsid-kunnr
            AND zuonr = lt_bsid-zuonr
            AND vbeln = lt_bsid-vbeln
            AND belnr = lt_bsid-belnr
            AND gjahr = lt_bsid-gjahr.
      ENDIF.

    WHEN pa_rept.
      PERFORM f_get_customer  USING '2'.

      IF gt_knvv[] IS NOT INITIAL.
        SELECT *
          FROM zfttfoutbd
          INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbd
          FOR ALL ENTRIES IN gt_knvv
          WHERE bukrs = pa_bukrs
            AND vkbur = gt_knvv-vkbur
            AND kunnr = gt_knvv-kunnr.

        SELECT *
          FROM zfttfoutbw
          INTO CORRESPONDING FIELDS OF TABLE gt_ttfoutbw
          FOR ALL ENTRIES IN gt_knvv
          WHERE bukrs = pa_bukrs
            AND vkbur = gt_knvv-vkbur
            AND kunnr = gt_knvv-kunnr.
      ENDIF.

      SELECT *
        FROM zftransttf
        INTO CORRESPONDING FIELDS OF TABLE gt_zftransttf
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND kunnr IN so_kunnr
          AND zuonr IN so_zuonr
          AND tglinput IN so_tglin.

      IF gt_zftransttf[] IS NOT INITIAL.
        SELECT bukrs vkbur bbeln ebelp vbeln zuonr kunnr
          pcash ptrans tglttf usna1 erdt1 bflag pstat ptype
          FROM zfbid
          INTO CORRESPONDING FIELDS OF TABLE gt_zfbid
          FOR ALL ENTRIES IN gt_zftransttf
          WHERE bukrs = gt_zftransttf-bukrs
            AND vkbur = gt_zftransttf-vkbur
            AND zuonr = gt_zftransttf-zuonr.

        lt_zfbid[]  = gt_zfbid[].
        SORT lt_zfbid BY bukrs vkbur bbeln.
        DELETE ADJACENT DUPLICATES FROM lt_zfbid
        COMPARING bukrs vkbur bbeln.
        IF lt_zfbid[] IS NOT INITIAL.
          SELECT bukrs vkbur bbeln bidat usna1 erzet erdt1
            FROM zfbih
            INTO CORRESPONDING FIELDS OF TABLE gt_zfbih
            FOR ALL ENTRIES IN lt_zfbid
            WHERE bukrs = lt_zfbid-bukrs
              AND vkbur = lt_zfbid-vkbur
              AND bbeln = lt_zfbid-bbeln.

          SELECT bukrs vkbur gjahr buzei gsber budat kunnr zfbdt seqno
            cekno bname belnr bbeln zuonr cchek pcair usna2 erdt2
            FROM zfbicheck
            INTO CORRESPONDING FIELDS OF TABLE gt_zfbicheck
            FOR ALL ENTRIES IN lt_zfbid
            WHERE bukrs = lt_zfbid-bukrs
              AND vkbur = lt_zfbid-vkbur
              AND bbeln = lt_zfbid-bbeln
              AND pcair = 'C'.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_bsid        TYPE STANDARD TABLE OF bsid INITIAL SIZE 0,
         ls_xbsid       TYPE bsid,
         ls_ybsid       TYPE bsid,
         ls_ttfoutbd    TYPE zfttfoutbd,
         ls_ttfoutbw    TYPE zfttfoutbw,
         ls_ttfoutpay   TYPE zfttfoutpay,
         ls_out         TYPE ty_out,
         ls_report      TYPE ty_report,
         lt_bino        TYPE STANDARD TABLE OF ty_bino INITIAL SIZE 0,
         ls_bino        TYPE ty_bino,
         ls_kna1        TYPE kna1,
         ls_zfbid       TYPE zfbid,
         ls_zfbih       TYPE zfbih,
         ls_payment     TYPE ty_payment,
         ls_zfttfcg     TYPE zfttfcg,
         ls_zftransttf  TYPE zftransttf.

  DATA : lv_top         TYPE zfttfcg-top,
         lv_topflag     TYPE zfttfcg-topflag,
         lv_suggest     TYPE sy-datum,
         lv_budat       TYPE sy-datum,
         lv_dd          TYPE zfttfoutbd-dd01,
         lv_01          TYPE zfttfoutbd-dd01,
         lv_02          TYPE zfttfoutbd-dd02,
         lv_03          TYPE zfttfoutbd-dd03,
         lv_04          TYPE zfttfoutbd-dd04,
         lv_bw          TYPE xfeld,
         lv_equal(1),
         lv_payment     TYPE zfbid-pcash,
         lv_subrc       TYPE sy-subrc,
         lv_estttf      TYPE sy-datum,
         lv_week        TYPE zfttfoutpay-week,
         lv_monday      TYPE sy-datum,
         lv_1           TYPE sy-subrc,
         lv_2           TYPE sy-subrc.

  CASE 'X'.
    WHEN pa_cust.
      IF gt_ttfoutbd[] IS INITIAL.
        gv_subrc = 1.
      ELSE.
        gv_subrc = 3.
      ENDIF.

      CALL SCREEN 101.

    WHEN pa_paym.
      IF gt_ttfoutpay[] IS INITIAL.
        gv_subrc = 1.
      ELSE.
        gv_subrc = 3.
      ENDIF.

      CALL SCREEN 102.

    WHEN pa_data.
      lt_bsid[] = gt_bsid[].
      SORT lt_bsid BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING kunnr.

      SORT gt_bsid BY bukrs kunnr zuonr vbeln belnr gjahr.
      SORT gt_zftransttf BY bukrs kunnr zuonr vbeln belnr gjahr.

      LOOP AT lt_bsid INTO ls_xbsid.
        CLEAR : ls_kna1, lv_1, lv_2.
        READ TABLE gt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_xbsid-kunnr.
        IF sy-subrc = 0.
          ls_out-name1  = ls_kna1-name1.
        ENDIF.

        CLEAR ls_ttfoutbd.
        READ TABLE gt_ttfoutbd INTO ls_ttfoutbd
                               WITH KEY kunnr = ls_xbsid-kunnr.
        IF sy-subrc = 0.
          ls_out-kdgrp   = ls_ttfoutbd-kdgrp.
          CLEAR : ls_zfttfcg, lv_top, lv_topflag.
          READ TABLE gt_zfttfcg INTO ls_zfttfcg
                                WITH KEY kdgrp = ls_ttfoutbd-kdgrp.
          IF sy-subrc = 0.
            lv_top      = ls_zfttfcg-top.
            lv_topflag  = ls_zfttfcg-topflag.
          ENDIF.
          ls_out-topext  = ls_ttfoutbd-topext.
          ls_out-basic   = ls_ttfoutbd-basic.
          ls_out-leadtm1 = ls_ttfoutbd-leadtm1.
          ls_out-leadtm2 = ls_ttfoutbd-leadtm2.

          ls_out-dd01    = ls_ttfoutbd-dd01.
          ls_out-dd02    = ls_ttfoutbd-dd02.
          ls_out-dd03    = ls_ttfoutbd-dd03.
          ls_out-dd04    = ls_ttfoutbd-dd04.
        ENDIF.

        LOOP AT gt_bsid INTO ls_ybsid WHERE kunnr = ls_xbsid-kunnr.
          ls_out-bukrs  = ls_ybsid-bukrs.
          ls_out-vkbur  = pa_vkbur.
          ls_out-kunnr  = ls_ybsid-kunnr.
          ls_out-zuonr  = ls_ybsid-zuonr.
          ls_out-vbeln  = ls_ybsid-vbeln.
          ls_out-belnr  = ls_ybsid-belnr.
          ls_out-gjahr  = ls_ybsid-gjahr.

          READ TABLE gt_zftransttf INTO ls_zftransttf
                                   WITH KEY bukrs = ls_ybsid-bukrs
                                            kunnr = ls_ybsid-kunnr
                                            zuonr = ls_ybsid-zuonr
                                            vbeln = ls_ybsid-vbeln
                                            belnr = ls_ybsid-belnr
                                            gjahr = ls_ybsid-gjahr
                                   BINARY SEARCH.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.

          ls_out-zfbdt  = ls_ybsid-zfbdt.
          ls_out-budat  = ls_ybsid-budat.
          ls_out-blart  = ls_ybsid-blart.
          ls_out-zterm  = ls_ybsid-zterm.
          ls_out-zbd1t  = ls_ybsid-zbd1t.
          ls_out-waers  = ls_ybsid-waers.
          ls_out-shkzg  = ls_ybsid-shkzg.

          IF ls_ybsid-shkzg = 'H'.
            ls_out-dmbtr  = ls_ybsid-dmbtr * -1.
            CONTINUE.
          ELSE.
            ls_out-dmbtr  = ls_ybsid-dmbtr.
          ENDIF.

          CLEAR : ls_ttfoutbw, lv_bw.
          READ TABLE gt_ttfoutbw INTO ls_ttfoutbw
                                 WITH KEY kunnr = ls_ybsid-kunnr
                                 TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CLEAR : ls_out-dd01, ls_out-dd02, ls_out-dd03, ls_out-dd04.

            lv_bw = 'X'.
            IF lv_topflag IS INITIAL.
              lv_budat  = ls_ybsid-budat + ls_out-basic.
            ELSE.
              lv_budat  = ls_ybsid-budat + lv_top.
            ENDIF.

            PERFORM f_get_date_from_week USING lv_budat ls_ybsid-kunnr ''
                                      CHANGING ls_out-dd01 ls_out-dd02
                                               ls_out-dd03 ls_out-dd04
                                               lv_dd.
          ENDIF.

          CLEAR : lv_equal.
          PERFORM f_ttf_date  USING ls_ybsid-zfbdt ls_ybsid-zbd1t
                                    ls_out-basic ls_out-leadtm1 ls_out-leadtm2
                                    ls_out-topext lv_top lv_topflag
                                    ls_out-dd01 ls_out-dd02
                                    ls_out-dd03 ls_out-dd04
                              CHANGING ls_out-tglttf lv_equal.

          PERFORM f_suggest_ttf USING ls_ybsid-bukrs pa_vkbur ls_ybsid-kunnr
                                      ls_out-tglttf '+' lv_equal
                                CHANGING ls_out-suggest.

          ls_out-leadtime = ls_out-suggest - ls_ybsid-zfbdt.

          IF ls_out-leadtime >= ls_out-leadtm2.
            lv_suggest = ls_out-suggest.
            CLEAR ls_out-suggest.
            PERFORM f_suggest_ttf USING ls_ybsid-bukrs pa_vkbur ls_ybsid-kunnr
                                        lv_suggest '-' lv_equal
                                  CHANGING ls_out-suggest.

            ls_out-leadtime = ls_out-suggest - ls_ybsid-zfbdt.
          ELSE.
            lv_suggest = ls_out-suggest.
            lv_subrc   = 4.
            WHILE lv_subrc IS NOT INITIAL.
              PERFORM f_holiday_cek USING 'T1' lv_suggest
                                    CHANGING lv_subrc.
              IF lv_subrc IS NOT INITIAL.
                CLEAR lv_suggest.
                PERFORM f_suggest_ttf USING ls_ybsid-bukrs pa_vkbur ls_ybsid-kunnr
                                            ls_out-tglttf '-' ''
                                      CHANGING lv_suggest.
              ELSE.
                ls_out-suggest = lv_suggest.
              ENDIF.
            ENDWHILE.
          ENDIF.

          ls_out-estbayar = ls_out-suggest + ls_out-topext.

          IF lv_bw IS NOT INITIAL.
            CLEAR : ls_out-dd01r, ls_out-dd02r, ls_out-dd03r, ls_out-dd04r.
            PERFORM f_get_date_from_week USING ls_out-estbayar ls_ybsid-kunnr ''
                                      CHANGING ls_out-dd01r ls_out-dd02r
                                               ls_out-dd03r ls_out-dd04r
                                               lv_dd.

            IF ls_out-dd04r IS NOT INITIAL.
              lv_01 = ls_out-dd01r.
              lv_02 = ls_out-dd04r.
              lv_03 = ls_out-dd03r.
              lv_04 = ls_out-dd02r.
            ELSEIF ls_out-dd03r IS NOT INITIAL.
              lv_01 = ls_out-dd01r.
              lv_02 = ls_out-dd03r.
              lv_03 = ls_out-dd02r.
              lv_04 = ls_out-dd01r.
            ELSEIF ls_out-dd02r IS NOT INITIAL.
              lv_01 = ls_out-dd01r.
              lv_02 = ls_out-dd02r.
              lv_03 = ls_out-dd01r.
            ENDIF.
          ELSE.
            IF ls_out-dd04 IS NOT INITIAL.
              lv_01 = ls_out-dd01.
              lv_02 = ls_out-dd04.
              lv_03 = ls_out-dd03.
              lv_04 = ls_out-dd02.
            ELSEIF ls_out-dd03 IS NOT INITIAL.
              lv_01 = ls_out-dd01.
              lv_02 = ls_out-dd03.
              lv_03 = ls_out-dd02.
              lv_04 = ls_out-dd01.
            ELSEIF ls_out-dd02 IS NOT INITIAL.
              lv_01 = ls_out-dd01.
              lv_02 = ls_out-dd02.
              lv_03 = ls_out-dd01.
            ENDIF.
          ENDIF.

          PERFORM f_real_bayar USING    ls_out-estbayar ls_ybsid-kunnr
                                        lv_01 lv_02 lv_03 lv_04 lv_bw
                               CHANGING ls_out-real.

          lv_subrc = 4.
          WHILE lv_subrc IS NOT INITIAL.
            PERFORM f_holiday_cek USING 'T0' ls_out-real
                                  CHANGING lv_subrc.
            IF lv_subrc IS NOT INITIAL.
              ls_out-real = ls_out-real + 1.
            ENDIF.
          ENDWHILE.

          CLEAR ls_ttfoutbd.
          READ TABLE gt_ttfoutbd INTO ls_ttfoutbd
                                 WITH KEY kunnr = ls_xbsid-kunnr
                                 TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            READ TABLE gt_ttfoutbw INTO ls_ttfoutbw
                                   WITH KEY kunnr = ls_xbsid-kunnr
                                   TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              lv_1  = sy-subrc.
            ENDIF.
          ENDIF.

          READ TABLE gt_ttfoutpay INTO ls_ttfoutpay
                                  WITH KEY kunnr = ls_xbsid-kunnr
                                  TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            lv_2  = sy-subrc.
          ENDIF.

          IF lv_1 IS NOT INITIAL OR
            lv_2 IS NOT INITIAL.
            PERFORM f_fieldstyle USING : 'CHECK' ''
                                 CHANGING ls_out-style.
          ENDIF.

          APPEND ls_out TO gt_out.
          CLEAR : ls_out-tglttf, ls_out-suggest, ls_out-real.
        ENDLOOP.
        CLEAR ls_out.
      ENDLOOP.

    WHEN pa_rept.
      PERFORM f_payment_process.

      lt_bino[]   = gt_bino[].

      SORT gt_zfbid BY bukrs vkbur zuonr bbeln DESCENDING.
      SORT gt_payment BY bukrs vkbur zuonr paydt DESCENDING.
      SORT gt_bino BY bukrs vkbur zuonr erdt1 DESCENDING erzet DESCENDING.
      SORT lt_bino BY bukrs vkbur zuonr tglttf DESCENDING.

      LOOP AT gt_zftransttf INTO ls_zftransttf.
        MOVE-CORRESPONDING ls_zftransttf TO ls_report.

        IF ls_report-shkzg = 'H'.
          ls_report-dmbtr = ls_report-dmbtr * -1.
        ENDIF.

        CLEAR ls_kna1.
        READ TABLE gt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_zftransttf-kunnr.
        IF sy-subrc = 0.
          ls_report-name1  = ls_kna1-name1.
        ENDIF.

        CLEAR ls_bino.
        READ TABLE gt_bino INTO ls_bino WITH KEY bukrs = ls_zftransttf-bukrs
                                                 vkbur = ls_zftransttf-vkbur
                                                 zuonr = ls_zftransttf-zuonr.
        IF sy-subrc = 0.
          ls_report-bbeln   = ls_bino-bbeln.
          ls_report-bidat   = ls_bino-bidat.
          ls_report-usna1   = ls_bino-usna1.
          ls_report-bflag   = ls_bino-bflag.
          ls_report-pstat   = ls_bino-pstat.
          ls_report-ptype   = ls_bino-ptype.
          IF ls_bino-bflag = 'D'.
            CLEAR ls_report-bbeln.
          ENDIF.
        ENDIF.

        CLEAR ls_bino.
        READ TABLE lt_bino INTO ls_bino WITH KEY bukrs = ls_zftransttf-bukrs
                                                 vkbur = ls_zftransttf-vkbur
                                                 zuonr = ls_zftransttf-zuonr.
        IF sy-subrc = 0.
          ls_report-tglttf  = ls_bino-tglttf.
        ENDIF.

        CLEAR : ls_payment, lv_payment.
        LOOP AT gt_payment INTO ls_payment
                           WHERE bukrs = ls_zftransttf-bukrs
                             AND vkbur = ls_zftransttf-vkbur
                             AND zuonr = ls_zftransttf-zuonr.
          IF ls_report-payid IS INITIAL.
            ls_report-payid = ls_payment-payid.
            ls_report-paydt = ls_payment-paydt.
          ENDIF.

          lv_payment  = lv_payment + ls_payment-pcash +
                        ls_payment-ptrans + ls_payment-cchek.
        ENDLOOP.

        ls_report-payment = lv_payment.

        ls_report-leadtf  = ls_report-tglttf - ls_report-zfbdt.
        ls_report-losstf  = ls_report-leadtf - ls_report-leadtm.
        IF ls_report-leadtf < 0.
          CLEAR ls_report-leadtf.
        ENDIF.
        IF ls_report-losstf < 0.
          CLEAR ls_report-losstf.
        ENDIF.

        IF ls_report-tglttf IS NOT INITIAL.
          ls_report-estttf  = ls_report-tglttf + ls_report-topext.

          READ TABLE gt_ttfoutbw INTO ls_ttfoutbw
                                 WITH KEY kunnr = ls_report-kunnr.
          IF sy-subrc = 0.
            CLEAR : ls_out-dd01, ls_out-dd02, ls_out-dd03, ls_out-dd04, lv_estttf.
            PERFORM f_get_date_from_week USING ls_report-estttf ls_report-kunnr ''
                                      CHANGING ls_out-dd01 ls_out-dd02
                                               ls_out-dd03 ls_out-dd04
                                               lv_dd.
            IF ls_report-estttf+6(2) > lv_dd.
              PERFORM f_next_month USING ls_report-estttf
                                   CHANGING lv_estttf.
              CLEAR : ls_out-dd01, ls_out-dd02, ls_out-dd03, ls_out-dd04.
              PERFORM f_get_date_from_week USING lv_estttf ls_report-kunnr 'X'
                                        CHANGING ls_out-dd01 ls_out-dd02
                                                 ls_out-dd03 ls_out-dd04
                                                 lv_dd.
            ENDIF.
          ELSE.
            READ TABLE gt_ttfoutbd INTO ls_ttfoutbd
                                   WITH KEY kunnr = ls_report-kunnr.
            IF sy-subrc = 0.
              ls_out-dd01   = ls_ttfoutbd-dd01.
              ls_out-dd02   = ls_ttfoutbd-dd02.
              ls_out-dd03   = ls_ttfoutbd-dd03.
              ls_out-dd04   = ls_ttfoutbd-dd04.
            ENDIF.
          ENDIF.

          CLEAR : lv_01, lv_02, lv_03, lv_04.
          IF ls_out-dd04 IS NOT INITIAL.
            lv_01 = ls_out-dd01.
            lv_02 = ls_out-dd04.
            lv_03 = ls_out-dd03.
            lv_04 = ls_out-dd02.
          ELSEIF ls_out-dd03 IS NOT INITIAL.
            lv_01 = ls_out-dd01.
            lv_02 = ls_out-dd03.
            lv_03 = ls_out-dd02.
            lv_04 = ls_out-dd01.
          ELSEIF ls_out-dd02 IS NOT INITIAL.
            lv_01 = ls_out-dd01.
            lv_02 = ls_out-dd02.
            lv_03 = ls_out-dd01.
          ENDIF.

          PERFORM f_real_bayar USING    ls_report-estttf ls_report-kunnr
                                        lv_01 lv_02 lv_03 lv_04 lv_bw
                               CHANGING ls_report-realttf.

          lv_subrc = 4.
          WHILE lv_subrc IS NOT INITIAL.
            PERFORM f_holiday_cek USING 'T0' ls_report-realttf
                                  CHANGING lv_subrc.
            IF lv_subrc IS NOT INITIAL.
              ls_report-realttf = ls_report-realttf + 1.
            ENDIF.
          ENDWHILE.
        ENDIF.

        ls_report-selisih = ls_report-dmbtr - ls_report-payment.

        APPEND ls_report TO gt_report.
        CLEAR ls_report.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN pa_cust.
    WHEN pa_data.
      CALL SCREEN 100.
*      PERFORM f_alv TABLES gt_out.
    WHEN pa_rept.
      PERFORM f_alv TABLES gt_report.
  ENDCASE.
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
  DATA : fcode TYPE TABLE OF sy-ucomm.

  CASE sy-dynnr.
    WHEN '0100'.
      IF g_maingrid IS INITIAL.
        CLEAR : fcode, fcode[].
        IF gt_error[] IS INITIAL.
          APPEND '&LOG'  TO fcode.
          SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
        ELSE.
          SET PF-STATUS 'PF_STATUS'.
        ENDIF.

        PERFORM f_excluding_toolbar.
      ENDIF.

    WHEN '0101' OR '0102'.
      CASE gv_subrc.
        WHEN '1'.
          SET TITLEBAR 'CREATE'.
          SET PF-STATUS 'PF_STATUS101'.
        WHEN '2'.
          SET TITLEBAR 'CHANGE'.
          SET PF-STATUS 'PF_STATUS101'.
        WHEN '3'.
          APPEND 'SAVE'  TO fcode.
          SET PF-STATUS 'PF_STATUS101' EXCLUDING fcode.
          SET TITLEBAR 'DISPLAY'.
      ENDCASE.
  ENDCASE.
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

    PERFORM f_build_fieldcat_oo USING 'MAIN'.
    PERFORM f_build_layout_oo USING 'MAIN'.
    PERFORM f_build_sort_tab_grid_oo USING 'MAIN'.

    gs_variant-report = d_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_maingrid.

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

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_maingrid.

    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  CALL METHOD g_maingrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  PERFORM f_alv_refresh USING 'X'.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_OO
*&---------------------------------------------------------------------*
FORM f_build_fieldcat_oo USING fu_container.
  CLEAR : gt_main_fieldcat[], gt_main_fieldcat.

  CASE fu_container.
    WHEN 'MAIN'.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' '' 'X' '' '' '',
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VKBUR' 'KNVV' 'VKBUR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NOMORTTF' 'ZFTTFNO' 'NOMORTTF' 'X' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VBELN' 'BSID' 'VBELN' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'GJAHR' 'BSID' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZFBDT' 'BSID' 'ZFBDT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BUDAT' 'BSID' 'BUDAT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BLART' 'BSID' 'BLART' 'X' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'TOPEXT' 'ZFTTFOUTBD' 'TOPEXT' 'X' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'ZTERM' 'BSID' 'ZTERM' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'WAERS' 'BSID' 'WAERS' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' ''
        'WAERS' '' '' '' '' '' '' '',
        'TGLTTF' 'BSID' 'BUDAT' 'X' '' 'Tanggal TTF' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'SUGGEST' 'BSID' 'BUDAT' '' '' 'Suggest TTF' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'LEADTIME' 'BSID' 'BUDAT' '' '' 'Lead Time' '' '' ''
        '' '' '' '' '' '' '' '' 'R' '',
        'ESTBAYAR' 'BSID' 'BUDAT' 'X' '15' 'EstimasiBayar' '' '' '' ''
        '' '' '' '' '' '' '' '' '',
        'REAL' 'BSID' 'BUDAT' '' '15' 'Estimasi Bayar' '' '' '' '' '' '' ''
        '' '' '' '' '' ''.
  ENDCASE.

ENDFORM.                    " F_BUILD_FIELDCAT_OO

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
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_emphasize)
                          value(fu_edit)
                          value(fu_icon)
                          value(fu_just)
                          value(fu_f4).

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
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-f4availabl        = fu_f4.
  APPEND ld_fieldcat TO gt_main_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT_OO
*&---------------------------------------------------------------------*
FORM f_build_layout_oo  USING    fu_layout.
  gs_layout_alv-zebra               = selected.
*  gs_layout_alv-box_fname           = 'SEL'.
*  gs_layout_alv-totals_bef          = selected.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
ENDFORM.                    " F_BUILD_LAYOUT_OO

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB_GRID_OO
*&---------------------------------------------------------------------*
FORM f_build_sort_tab_grid_oo  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'MAIN'.
      gt_main_sort-spos = 1.
      gt_main_sort-fieldname = 'KUNNR'.
      gt_main_sort-up        = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT_TAB_GRID_OO

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : enq      TYPE STANDARD TABLE OF seqg3 INITIAL SIZE 0,
         ls_enq   TYPE seqg3,
         lv_valid.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_container IS INITIAL.
        CALL METHOD g_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR : g_container, g_maingrid.
      ENDIF.

      CALL FUNCTION 'DEQUEUE_ALL'.
      CALL FUNCTION 'BUFFER_REFRESH_ALL'.
      CLEAR ok_code.

      LEAVE TO SCREEN 0.

    WHEN 'CHGDIS'.
      CASE gv_subrc.
        WHEN 2.
          gv_subrc = 3.

          CALL FUNCTION 'DEQUEUE_ALL'.

        WHEN 3.
          PERFORM f_cek_authorization USING '02'
                                      CHANGING gv_subrc.
          IF gv_subrc = 4.
            MESSAGE s000(zab) WITH 'You are not authorized'
                              DISPLAY LIKE 'E'.
            gv_subrc = 3.
          ENDIF.

          CALL FUNCTION 'ENQUEUE_EZTTFOUTBD'
            EXPORTING
              bukrs          = pa_bukrs
              vkbur          = pa_vkbur
              kunnr          = pa_kunnr
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.

          IF sy-subrc IS NOT INITIAL.
            CALL FUNCTION 'ENQUEUE_READ'
              EXPORTING
                gname                 = 'ZFTTFOUTBD'
              TABLES
                enq                   = enq
              EXCEPTIONS
                communication_failure = 1
                system_failure        = 2
                OTHERS                = 3.

            READ TABLE enq INTO ls_enq INDEX 1.

            MESSAGE s000(zab) WITH 'Transaction lock by' ls_enq-guname
                              DISPLAY LIKE 'E'.
            gv_subrc = 3.
          ENDIF.
      ENDCASE.

      CALL FUNCTION 'BUFFER_REFRESH_ALL'.
      CLEAR ok_code.

    WHEN 'SAVE'.
      CASE 'X'.
        WHEN pa_cust.
          PERFORM f_validate_data USING '1'.

          IF gv_error IS INITIAL.
            PERFORM f_save_table_zfttfoutbd.
            PERFORM f_save_table_zfttfoutbw.

            CALL FUNCTION 'DEQUEUE_ALL'.
            CALL FUNCTION 'BUFFER_REFRESH_ALL'.
            CLEAR ok_code.

            MESSAGE s000(zab) WITH 'Data already saved'.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN pa_paym.
          IF gv_error IS INITIAL.
            PERFORM f_save_table_zfttfoutpay.

            CALL FUNCTION 'DEQUEUE_ALL'.
            CALL FUNCTION 'BUFFER_REFRESH_ALL'.
            CLEAR ok_code.

            MESSAGE s000(zab) WITH 'Data already saved'.
            LEAVE TO SCREEN 0.
          ENDIF.
      ENDCASE.

    WHEN '&POS'.
*        CALL METHOD g_maingrid->check_changed_data
*          IMPORTING
*            e_valid = lv_valid.
*
*        IF lv_valid IS NOT INITIAL.
      PERFORM f_modify_check.

      PERFORM f_number_range USING 'LOCK'.

      PERFORM f_save_table_zftransttf.

      UPDATE zfttfno FROM gs_zfttfno.
*        ENDIF.

      CALL FUNCTION 'DEQUEUE_ALL'.
      CALL FUNCTION 'BUFFER_REFRESH_ALL'.
      CLEAR ok_code.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE header OUTPUT.
  DATA : lr_rows      TYPE REF TO cl_salv_form_layout_grid,
         lr_element   TYPE REF TO cl_salv_form_element,
         lr_container TYPE REF TO cl_gui_container,
         lr_dydos     TYPE REF TO cl_salv_form_dydos.

  IF g_maingrid IS INITIAL.
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
  ENDIF.
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
    text   = text-t06 ).
  lr_text = lr_grid_1->create_text(
    row    = 1
    column = 2
    text   = '0200' ).                                      "#EC NOTEXT
  lr_grid_1->create_text(
    row    = 1
    column = 3
    text   = 'Zentrallager' ).                              "#EC NOTEXT
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 2
    column = 1
    text   = text-t08 ).
  lr_text = lr_grid_1->create_text(
    row    = 2
    column = 2
    text   = 'C-A-004' ).                                   "#EC NOTEXT
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_2->create_label(
    row    = 1
    column = 1
    text   = text-t07 ).
  lr_text = lr_grid_2->create_text(
    row    = 1
    column = 2
    text   = '140' ).
  lr_grid_2->create_text(
    row    = 1
    column = 3
    text   = 'Blocklager 2' ).                              "#EC NOTEXT
  lr_label->set_label_for( lr_text ).

  lr_rows->add_row( ).

  lr_rows->create_action_information(
    row    = 5
    column = 1
    text   = text-t09 ).

  cr_element = lr_rows.
ENDFORM.                    " HEADER_LINE

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check fu_container.
  DATA : ls_out           LIKE LINE OF gt_out,
         ls_fieldcatalog  TYPE lvc_t_fcat WITH HEADER LINE.

  CALL METHOD g_maingrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        IF ls_out-style[] IS INITIAL.
          ls_out-check  = fu_check.
          MODIFY gt_out FROM ls_out TRANSPORTING check.
        ENDIF.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CALL METHOD g_maingrid->refresh_table_display.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer USING   fu_flag.
  IF fu_flag IS INITIAL.
    SELECT kunnr vkorg vtweg spart vkbur
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      WHERE vkbur = pa_vkbur
        AND vkorg = pa_bukrs
        AND kunnr = pa_kunnr.
  ELSEIF fu_flag = '1'.
    SELECT kunnr vkorg vtweg spart vkbur
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      WHERE vkbur = pa_vkbur
        AND vkorg = pa_bukrs
        AND kunnr IN so_kunnr.

    IF gt_knvv[] IS NOT INITIAL.
      SELECT kunnr name1
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FOR ALL ENTRIES IN gt_knvv
        WHERE kunnr = gt_knvv-kunnr.
    ENDIF.
  ELSEIF fu_flag = '2'.
    SELECT kunnr vkorg vtweg spart vkbur
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      WHERE vkbur IN so_vkbur
        AND vkorg = pa_bukrs
        AND kunnr IN so_kunnr.

    IF gt_knvv[] IS NOT INITIAL.
      SELECT kunnr name1
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FOR ALL ENTRIES IN gt_knvv
        WHERE kunnr = gt_knvv-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CUSTOMER

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  DATA : lv_input      TYPE xfeld,
         lv_01,
         lv_02,
         lv_03,
         lv_bw         TYPE xfeld,
         lv_actvt(2)   TYPE n  VALUE '02',
         ls_ttfoutbw   TYPE zfttfoutbw.

  gv_bukrs  = pa_bukrs.
  gv_vkbur  = pa_vkbur.
  gv_kunnr  = pa_kunnr.

  IF gv_leadtm1 IS INITIAL.
    gv_leadtm1 = 6.
  ENDIF.
  IF gv_leadtm2 IS INITIAL.
    gv_leadtm2 = 10.
  ENDIF.

  CASE gv_subrc.
    WHEN '1'.

    WHEN '2'.
      CASE 'X'.
        WHEN pa_cust.
          lv_01 = '1'.
          lv_02 = '1'.
          lv_03 = '1'.

        WHEN pa_paym.
          lv_02 = '1'.
          lv_03 = '1'.
      ENDCASE.

    WHEN '3'.
      CASE 'X'.
        WHEN pa_cust.
          CLEAR ls_ttfoutbw.
          READ TABLE gt_ttfoutbw INTO ls_ttfoutbw
                                 WITH KEY kunnr = gv_kunnr
                                 TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_bw = selected.
            LOOP AT gt_ttfoutbw INTO ls_ttfoutbw.
              CASE ls_ttfoutbw-week.
                WHEN 1.
                  PERFORM f_display_bw USING ls_ttfoutbw-day1 ls_ttfoutbw-day2
                                             ls_ttfoutbw-day3 ls_ttfoutbw-day4
                                             ls_ttfoutbw-day5 ls_ttfoutbw-day6
                                       CHANGING gv_sen1 gv_sel1 gv_rab1 gv_kam1
                                                gv_jum1 gv_sab1 gv_week1.
                WHEN 2.
                  PERFORM f_display_bw USING ls_ttfoutbw-day1 ls_ttfoutbw-day2
                                             ls_ttfoutbw-day3 ls_ttfoutbw-day4
                                             ls_ttfoutbw-day5 ls_ttfoutbw-day6
                                       CHANGING gv_sen2 gv_sel2 gv_rab2 gv_kam2
                                                gv_jum2 gv_sab2 gv_week2.
                WHEN 3.
                  PERFORM f_display_bw USING ls_ttfoutbw-day1 ls_ttfoutbw-day2
                                             ls_ttfoutbw-day3 ls_ttfoutbw-day4
                                             ls_ttfoutbw-day5 ls_ttfoutbw-day6
                                       CHANGING gv_sen3 gv_sel3 gv_rab3 gv_kam3
                                                gv_jum3 gv_sab3 gv_week3.
                WHEN 4.
                  PERFORM f_display_bw USING ls_ttfoutbw-day1 ls_ttfoutbw-day2
                                             ls_ttfoutbw-day3 ls_ttfoutbw-day4
                                             ls_ttfoutbw-day5 ls_ttfoutbw-day6
                                       CHANGING gv_sen4 gv_sel4 gv_rab4 gv_kam4
                                                gv_jum4 gv_sab4 gv_week4.
                WHEN 5.
                  PERFORM f_display_bw USING ls_ttfoutbw-day1 ls_ttfoutbw-day2
                                             ls_ttfoutbw-day3 ls_ttfoutbw-day4
                                             ls_ttfoutbw-day5 ls_ttfoutbw-day6
                                       CHANGING gv_sen5 gv_sel5 gv_rab5 gv_kam5
                                                gv_jum5 gv_sab5 gv_week5.
              ENDCASE.
            ENDLOOP.
          ENDIF.

          READ TABLE gt_ttfoutbd INTO gs_ttfoutbd INDEX 1.
          IF sy-subrc = 0.
            gv_kdgrp    = gs_ttfoutbd-kdgrp.
            gv_topex    = gs_ttfoutbd-topext.
            gv_basic    = gs_ttfoutbd-basic.
            gv_leadtm1  = gs_ttfoutbd-leadtm1.
            IF gs_ttfoutbd-leadtm2 IS NOT INITIAL.
              gv_leadtm2  = gs_ttfoutbd-leadtm2.
            ENDIF.
            gv_dd01     = gs_ttfoutbd-dd01.
            gv_dd02     = gs_ttfoutbd-dd02.
            gv_dd03     = gs_ttfoutbd-dd03.
            gv_dd04     = gs_ttfoutbd-dd04.
          ENDIF.

          PERFORM f_validate_data USING ''.

          lv_01 = '0'.
          lv_02 = '0'.
          lv_03 = '0'.

        WHEN pa_paym.
          PERFORM f_display_payment.
          lv_02 = '0'.
          lv_03 = '0'.
      ENDCASE.
  ENDCASE.

  PERFORM f_modify_screen USING : 'BD' '' lv_01 '',
                                  'BW' '' lv_02 '',
                                  'WE1' '' lv_03 '',
                                  'WE2' '' lv_03 '',
                                  'WE3' '' lv_03 '',
                                  'WE4' '' lv_03 '',
                                  'WE5' '' lv_03 ''.

  IF gv_week1 IS INITIAL.
    PERFORM f_modify_screen USING : 'WE1' '0' '' ''.
  ENDIF.
  IF gv_week2 IS INITIAL.
    PERFORM f_modify_screen USING : 'WE2' '0' '' ''.
  ENDIF.
  IF gv_week3 IS INITIAL.
    PERFORM f_modify_screen USING : 'WE3' '0' '' ''.
  ENDIF.
  IF gv_week4 IS INITIAL.
    PERFORM f_modify_screen USING : 'WE4' '0' '' ''.
  ENDIF.
  IF gv_week5 IS INITIAL.
    PERFORM f_modify_screen USING : 'WE5' '0' '' ''.
  ENDIF.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CEK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_cek_authorization  USING    fu_actvt
                          CHANGING fc_subrc.

  AUTHORITY-CHECK OBJECT 'ZFTTFCAB'
            ID 'ACTVT' FIELD fu_actvt.
  IF sy-subrc <> 0.
    fc_subrc = 4.
  ELSE.
    fc_subrc = 2.
  ENDIF.
ENDFORM.                    " F_CEK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE_ZFTTFOUTBD
*&---------------------------------------------------------------------*
FORM f_save_table_zfttfoutbd .
  DATA : ls_ttfoutbd    TYPE zfttfoutbd.

  READ TABLE gt_ttfoutbd INTO ls_ttfoutbd INDEX 1.

  ls_ttfoutbd-bukrs   = pa_bukrs.
  ls_ttfoutbd-vkbur   = pa_vkbur.
  ls_ttfoutbd-kunnr   = pa_kunnr.
  ls_ttfoutbd-kdgrp   = gv_kdgrp.
  ls_ttfoutbd-topext  = gv_topex.
  ls_ttfoutbd-basic   = gv_basic.
  ls_ttfoutbd-leadtm1 = gv_leadtm1.
  ls_ttfoutbd-leadtm2 = gv_leadtm2.
  ls_ttfoutbd-dd01    = gv_dd01.
  ls_ttfoutbd-dd02    = gv_dd02.
  ls_ttfoutbd-dd03    = gv_dd03.
  ls_ttfoutbd-dd04    = gv_dd04.

  IF gv_subrc = 1.
    ls_ttfoutbd-username  = sy-uname.
    ls_ttfoutbd-tglinput  = sy-datum.
    ls_ttfoutbd-jaminput  = sy-uzeit.
    INSERT zfttfoutbd FROM ls_ttfoutbd.
  ELSE.
    IF ls_ttfoutbd-kdgrp = gs_ttfoutbd-kdgrp AND
      ls_ttfoutbd-topext = gs_ttfoutbd-topext AND
      ls_ttfoutbd-basic = gs_ttfoutbd-basic AND
      ls_ttfoutbd-leadtm1 = gs_ttfoutbd-leadtm1 AND
      ls_ttfoutbd-leadtm2 = gs_ttfoutbd-leadtm2 AND
      ls_ttfoutbd-dd01 = gs_ttfoutbd-dd01 AND
      ls_ttfoutbd-dd02 = gs_ttfoutbd-dd02 AND
      ls_ttfoutbd-dd03 = gs_ttfoutbd-dd03 AND
      ls_ttfoutbd-dd04 = gs_ttfoutbd-dd04.
    ELSE.
      ls_ttfoutbd-username  = ls_ttfoutbd-username.
      ls_ttfoutbd-tglinput  = ls_ttfoutbd-tglinput.
      ls_ttfoutbd-jaminput  = ls_ttfoutbd-jaminput.
      ls_ttfoutbd-modbe     = sy-uname.
      ls_ttfoutbd-modda     = sy-datum.
      ls_ttfoutbd-modti     = sy-uzeit.
      UPDATE zfttfoutbd FROM ls_ttfoutbd.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SAVE_TABLE_ZFTTFOUTBD

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE_ZFTTFOUTBW
*&---------------------------------------------------------------------*
FORM f_save_table_zfttfoutbw .
  DATA : ls_ttfoutbw   TYPE zfttfoutbw,
         lv_week       TYPE zfttfoutbw-week,
         lv_count      TYPE p.

  READ TABLE gt_ttfoutbw INTO ls_ttfoutbw INDEX 1.

  ls_ttfoutbw-bukrs   = pa_bukrs.
  ls_ttfoutbw-vkbur   = pa_vkbur.
  ls_ttfoutbw-kunnr   = pa_kunnr.
  ls_ttfoutbw-kdgrp   = gv_kdgrp.

  IF gv_week1 IS NOT INITIAL.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '1' gv_sen1 gv_sel1 gv_rab1
                                     gv_kam1 gv_jum1 gv_sab1.
  ELSE.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '1' '' '' '' '' '' ''.
    ADD 1 TO lv_count.
  ENDIF.
  IF gv_week2 IS NOT INITIAL.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                  '2' gv_sen2 gv_sel2 gv_rab2
                                      gv_kam2 gv_jum2 gv_sab2.
  ELSE.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '2' '' '' '' '' '' ''.
    ADD 1 TO lv_count.
  ENDIF.
  IF gv_week3 IS NOT INITIAL.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                  '3' gv_sen3 gv_sel3 gv_rab3
                                      gv_kam3 gv_jum3 gv_sab3.
  ELSE.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '3' '' '' '' '' '' ''.
    ADD 1 TO lv_count.
  ENDIF.
  IF gv_week4 IS NOT INITIAL.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                  '4' gv_sen4 gv_sel4 gv_rab4
                                      gv_kam4 gv_jum4 gv_sab4.
  ELSE.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '4' '' '' '' '' '' ''.
    ADD 1 TO lv_count.
  ENDIF.
  IF gv_week5 IS NOT INITIAL.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                  '5' gv_sen5 gv_sel5 gv_rab5
                                      gv_kam5 gv_jum5 gv_sab5.
  ELSE.
    PERFORM f_save_week_bw USING ls_ttfoutbw
                                 '5' '' '' '' '' '' ''.
    ADD 1 TO lv_count.
  ENDIF.

  IF lv_count = 5.
    DELETE FROM zfttfoutbw WHERE kunnr = pa_kunnr.
  ENDIF.
ENDFORM.                    " F_SAVE_TABLE_ZFTTFOUTBW

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE_ZFTTFOUTPAY
*&---------------------------------------------------------------------*
FORM f_save_table_zfttfoutpay .
  DATA : ls_ttfoutpay  TYPE zfttfoutpay,
         lv_week       TYPE zfttfoutpay-week.

  READ TABLE gt_ttfoutpay INTO ls_ttfoutpay INDEX 1.

  ls_ttfoutpay-bukrs   = pa_bukrs.
  ls_ttfoutpay-vkbur   = pa_vkbur.
  ls_ttfoutpay-kunnr   = pa_kunnr.

  IF gv_week1 IS NOT INITIAL.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                 '1' gv_sen1 gv_sel1 gv_rab1
                                     gv_kam1 gv_jum1 gv_sab1.
  ELSE.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                 '1' '' '' '' '' '' ''.
  ENDIF.
  IF gv_week2 IS NOT INITIAL.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '2' gv_sen2 gv_sel2 gv_rab2
                                      gv_kam2 gv_jum2 gv_sab2.
  ELSE.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '2' '' '' '' '' '' ''.
  ENDIF.
  IF gv_week3 IS NOT INITIAL.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '3' gv_sen3 gv_sel3 gv_rab3
                                      gv_kam3 gv_jum3 gv_sab3.
  ELSE.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '3' '' '' '' '' '' ''.
  ENDIF.
  IF gv_week4 IS NOT INITIAL.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '4' gv_sen4 gv_sel4 gv_rab4
                                      gv_kam4 gv_jum4 gv_sab4.
  ELSE.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '4' '' '' '' '' '' ''.
  ENDIF.
  IF gv_week5 IS NOT INITIAL.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '5' gv_sen5 gv_sel5 gv_rab5
                                      gv_kam5 gv_jum5 gv_sab5.
  ELSE.
    PERFORM f_save_week_pay USING ls_ttfoutpay
                                  '5' '' '' '' '' '' ''.
  ENDIF.
ENDFORM.                    " F_SAVE_TABLE_ZFTTFOUTPAY

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data USING fu_flag.
  CLEAR gv_error.

  IF fu_flag IS NOT INITIAL.
    IF gv_dd01 IS INITIAL.
      IF gv_week1 IS INITIAL AND
        gv_week2 IS INITIAL AND
        gv_week3 IS INITIAL AND
        gv_week4 IS INITIAL AND
        gv_week5 IS INITIAL.
        MESSAGE s000(zab) WITH
        'Batas Tanggal Waktu Jatuh Tempo harus diisi' DISPLAY LIKE 'E'.
        gv_error = 4.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_dd01 IS NOT INITIAL.
    IF gv_dd01 > 31.
      MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                        DISPLAY LIKE 'E'.
      gv_error = 4.
    ENDIF.
  ENDIF.

  IF gv_dd02 IS NOT INITIAL.
    IF gv_dd02 > 31.
      MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                        DISPLAY LIKE 'E'.
      gv_error = 4.
    ELSE.
      IF gv_dd01 > gv_dd02.
        MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                          DISPLAY LIKE 'E'.
        gv_error = 4.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_dd03 IS NOT INITIAL.
    IF gv_dd03 > 31.
      MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                        DISPLAY LIKE 'E'.
      gv_error = 4.
    ELSE.
      IF gv_dd02 > gv_dd03.
        MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                          DISPLAY LIKE 'E'.
        gv_error = 4.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_dd04 IS NOT INITIAL.
    IF gv_dd04 > 31.
      MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                        DISPLAY LIKE 'E'.
      gv_error = 4.
    ELSE.
      IF gv_dd03 > gv_dd04.
        MESSAGE s000(zab) WITH 'Batas tanggal Jatuh Tempo salah'
                          DISPLAY LIKE 'E'.
        gv_error = 4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_WEEK_PAY
*&---------------------------------------------------------------------*
FORM f_save_week_pay  USING    fs_ttfoutpay  STRUCTURE zfttfoutpay
                               fu_week fu_sen fu_sel fu_rab
                                       fu_kam fu_jum fu_sab.

  DATA : ls_ttfoutpay     TYPE zfttfoutpay,
         ls_xttfoutpay    TYPE zfttfoutpay,
         lv_subrc         TYPE sy-subrc.

  ls_ttfoutpay         = fs_ttfoutpay.

  ls_ttfoutpay-week    = fu_week.
  ls_ttfoutpay-day1    = fu_sen.
  ls_ttfoutpay-day2    = fu_sel.
  ls_ttfoutpay-day3    = fu_rab.
  ls_ttfoutpay-day4    = fu_kam.
  ls_ttfoutpay-day5    = fu_jum.
  ls_ttfoutpay-day6    = fu_sab.

  CASE gv_subrc.
    WHEN 1.
      ls_ttfoutpay-username  = sy-uname.
      ls_ttfoutpay-tglinput  = sy-datum.
      ls_ttfoutpay-jaminput  = sy-uzeit.
      INSERT zfttfoutpay FROM ls_ttfoutpay.
    WHEN OTHERS.
      READ TABLE gt_ttfoutpay INTO ls_xttfoutpay
                             WITH KEY bukrs = ls_ttfoutpay-bukrs
                                      vkbur = ls_ttfoutpay-vkbur
                                      kunnr = ls_ttfoutpay-kunnr
                                      week  = ls_ttfoutpay-week.
      IF sy-subrc = 0.
        IF ls_ttfoutpay-day1 = ls_xttfoutpay-day1 AND
          ls_ttfoutpay-day2 = ls_xttfoutpay-day2 AND
          ls_ttfoutpay-day3 = ls_xttfoutpay-day3 AND
          ls_ttfoutpay-day4 = ls_xttfoutpay-day4 AND
          ls_ttfoutpay-day5 = ls_xttfoutpay-day5 AND
          ls_ttfoutpay-day6 = ls_xttfoutpay-day6.
        ELSE.
          ls_ttfoutpay-username  = ls_ttfoutpay-username.
          ls_ttfoutpay-tglinput  = ls_ttfoutpay-tglinput.
          ls_ttfoutpay-jaminput  = ls_ttfoutpay-jaminput.
          ls_ttfoutpay-modbe     = sy-uname.
          ls_ttfoutpay-modda     = sy-datum.
          ls_ttfoutpay-modti     = sy-uzeit.
          UPDATE zfttfoutpay FROM ls_ttfoutpay.
        ENDIF.
      ELSE.
        ls_ttfoutpay-username  = sy-uname.
        ls_ttfoutpay-tglinput  = sy-datum.
        ls_ttfoutpay-jaminput  = sy-uzeit.
        INSERT zfttfoutpay FROM ls_ttfoutpay.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SAVE_WEEK_PAY

*&---------------------------------------------------------------------*
*&      Form  F_WEEK_DISPLAY
*&---------------------------------------------------------------------*
FORM f_week_display  USING    fs_ttfoutpay   STRUCTURE zfttfoutpay
                     CHANGING fc_week fc_sen fc_sel fc_rab
                                      fc_kam fc_jum fc_sab.
  fc_week = selected.

  IF fs_ttfoutpay-day1 IS INITIAL AND
    fs_ttfoutpay-day2 IS INITIAL AND
    fs_ttfoutpay-day3 IS INITIAL AND
    fs_ttfoutpay-day4 IS INITIAL AND
    fs_ttfoutpay-day5 IS INITIAL AND
    fs_ttfoutpay-day6 IS INITIAL.
    CLEAR fc_week.
  ENDIF.

  fc_sen  = fs_ttfoutpay-day1.
  fc_sel  = fs_ttfoutpay-day2.
  fc_rab  = fs_ttfoutpay-day3.
  fc_kam  = fs_ttfoutpay-day4.
  fc_jum  = fs_ttfoutpay-day5.
  fc_sab  = fs_ttfoutpay-day6.
ENDFORM.                    " F_WEEK_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACC_DATA
*&---------------------------------------------------------------------*
FORM f_get_acc_data .
  DATA : lt_bsid   TYPE STANDARD TABLE OF bsid INITIAL SIZE 0,
         ls_xbsid  TYPE bsid,
         ls_ybsid  TYPE bsid.
  DATA : lv_count  TYPE sy-subrc.

  IF gt_ttfoutbd[] IS NOT INITIAL.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE lt_bsid
      FOR ALL ENTRIES IN gt_ttfoutbd
      WHERE kunnr  = gt_ttfoutbd-kunnr
        AND bukrs  = pa_bukrs
        AND budat LE pa_stida
        AND zuonr IN so_zuonr.

    gt_bsid[] = lt_bsid[].
    DELETE gt_bsid WHERE blart <> 'RV'.

    LOOP AT gt_bsid INTO ls_xbsid.
      CLEAR lv_count.
      LOOP AT lt_bsid INTO ls_ybsid WHERE kunnr = ls_xbsid-kunnr
                                      AND zuonr = ls_xbsid-zuonr.
        IF ls_ybsid-blart = 'RV'.
          CONTINUE.
        ELSE.
          ADD 1 TO lv_count.
        ENDIF.
      ENDLOOP.
      IF lv_count IS NOT INITIAL.
        DELETE TABLE gt_bsid FROM ls_xbsid.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_ACC_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SUGGEST_TTF
*&---------------------------------------------------------------------*
FORM f_suggest_ttf  USING    fu_bukrs fu_vkbur fu_kunnr fu_tglttf
                             fu_sign fu_equal
                    CHANGING fc_suggest.
  DATA : lv_datum   TYPE sy-datum,
         lv_newdt   TYPE sy-datum,
         lv_count   TYPE p,
         lv_subrc   TYPE sy-subrc.

  DATA : ls_ttfoutpay   TYPE zfttfoutpay,
         lv_week        TYPE zfttfoutpay-week,
         lv_monday      TYPE sy-datum.

  IF fu_equal IS NOT INITIAL.
    fc_suggest = fu_tglttf.
  ELSE.
    lv_datum   = fu_tglttf.

    PERFORM f_get_week_suggest USING lv_datum ''
                               CHANGING lv_week lv_monday.

    CLEAR lv_subrc.
    WHILE fc_suggest IS INITIAL.
      PERFORM f_get_tgl_suggest USING fu_bukrs fu_vkbur fu_kunnr lv_datum
                                      lv_week lv_monday fu_sign
                                CHANGING fc_suggest lv_subrc.

      IF lv_subrc IS NOT INITIAL.
        EXIT.
      ENDIF.

      IF fc_suggest IS INITIAL.
        CASE fu_sign.
          WHEN '+'.
            lv_newdt = lv_monday + 7.
          WHEN '-'.
            lv_newdt = lv_monday - 7.
        ENDCASE.
        PERFORM f_get_week_suggest USING lv_datum lv_newdt
                                   CHANGING lv_week lv_monday.
      ENDIF.
    ENDWHILE.
  ENDIF.
ENDFORM.                    " F_SUGGEST_TTF

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEEK_SUGGEST
*&---------------------------------------------------------------------*
FORM f_get_week_suggest  USING    fu_datum fu_newdt
                         CHANGING fc_week fc_monday.

  DATA : lv_01      TYPE sy-datum,
         lv_datum   TYPE sy-datum,
         lv_week1   TYPE scal-week,
         lv_week2   TYPE scal-week,
         lv_wotnr   TYPE p.

  IF fu_newdt IS INITIAL.
    CONCATENATE fu_datum(6) '01' INTO lv_01.
    lv_datum  = fu_datum.
  ELSE.
    CONCATENATE fu_newdt(6) '01' INTO lv_01.
    lv_datum  = fu_newdt.
  ENDIF.

  CALL FUNCTION 'DAY_IN_WEEK'
    EXPORTING
      datum = lv_01
    IMPORTING
      wotnr = lv_wotnr.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      date = lv_01
    IMPORTING
      week = lv_week1.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      date   = lv_datum
    IMPORTING
      week   = lv_week2
      monday = fc_monday.

  IF lv_wotnr >= 6.
    IF lv_week2(4) <> lv_week1(4).
      fc_week = 1.
    ELSE.
      fc_week = lv_week2 - lv_week1.
      IF fc_week = 0.
        fc_week = 1.
      ENDIF.
    ENDIF.
  ELSE.
    fc_week = ( lv_week2 - lv_week1 ) + 1.
  ENDIF.
ENDFORM.                    " F_GET_WEEK_SUGGEST

*&---------------------------------------------------------------------*
*&      Form  F_GET_TGL_SUGGEST
*&---------------------------------------------------------------------*
FORM f_get_tgl_suggest  USING    fu_bukrs fu_vkbur fu_kunnr fu_datum
                                 fu_week fu_monday fu_sign
                        CHANGING fc_suggest fc_subrc.

  DATA : lt_date        TYPE STANDARD TABLE OF ty_date INITIAL SIZE 0,
         ls_date        TYPE ty_date,
         lv_subrc       TYPE sy-subrc,
         ls_ttfoutpay   TYPE zfttfoutpay,
         lv_sign,
         lv_lines       TYPE i.

  lv_sign = fu_sign.

  READ TABLE gt_ttfoutpay INTO ls_ttfoutpay WITH KEY bukrs = fu_bukrs
                                                     vkbur = fu_vkbur
                                                     kunnr = fu_kunnr
                                                     week  = fu_week.
  fc_subrc = sy-subrc.

  IF sy-subrc = 0.
    IF ls_ttfoutpay-day1 = selected.
      ls_date-datum = fu_monday.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.

    IF ls_ttfoutpay-day2 = selected.
      ls_date-datum = fu_monday + 1.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.

    IF ls_ttfoutpay-day3 = selected.
      ls_date-datum = fu_monday + 2.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.

    IF ls_ttfoutpay-day4 = selected.
      ls_date-datum = fu_monday + 3.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.

    IF ls_ttfoutpay-day5 = selected.
      ls_date-datum = fu_monday + 4.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.

    IF ls_ttfoutpay-day6 = selected.
      ls_date-datum = fu_monday + 5.
      PERFORM f_holiday_cek USING 'T1' ls_date-datum
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        APPEND ls_date TO lt_date.
        CLEAR ls_date.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lt_date[] IS NOT INITIAL.
    CASE lv_sign.
      WHEN '+'.
        SORT lt_date BY datum.
      WHEN '-'.
        SORT lt_date BY datum DESCENDING.
    ENDCASE.

    DESCRIBE TABLE lt_date LINES lv_lines.
    IF lv_lines = 1.
      READ TABLE lt_date INTO ls_date INDEX 1.
      IF sy-subrc = 0.
        fc_suggest = ls_date-datum.
      ENDIF.
    ELSE.
      LOOP AT lt_date INTO ls_date.
        CASE lv_sign.
          WHEN '+'.
            IF ls_date-datum >= fu_datum.
              fc_suggest = ls_date-datum.
              EXIT.
            ELSE.
              CONTINUE.
            ENDIF.
          WHEN '-'.
            IF ls_date-datum < fu_datum.
              fc_suggest = ls_date-datum.
              EXIT.
            ELSE.
              CONTINUE.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_TGL_SUGGEST

*&---------------------------------------------------------------------*
*&      Form  F_HOLIDAY_CEK
*&---------------------------------------------------------------------*
FORM f_holiday_cek  USING    fu_calendar fu_datum
                    CHANGING fc_subrc.

  DATA : holidays  TYPE STANDARD TABLE OF iscal_day INITIAL SIZE 0.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      holiday_calendar           = fu_calendar
      factory_calendar           = fu_calendar
      date_from                  = fu_datum
      date_to                    = fu_datum
    TABLES
      holidays                   = holidays
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.
  IF holidays[] IS NOT INITIAL.
    fc_subrc = 4.
  ELSE.
    fc_subrc = 0.
  ENDIF.
ENDFORM.                    " F_HOLIDAY_CEK

*&---------------------------------------------------------------------*
*&      Module  VALUE_KDGRP  INPUT
*&---------------------------------------------------------------------*
MODULE value_kdgrp INPUT.
  DATA : lv_kdgrp TYPE help_info-dynprofld.

  DATA : BEGIN OF lt_zfttfcg OCCURS 0,
           kdgrp      TYPE zfttfcg-kdgrp,
         END OF lt_zfttfcg,
         ls_zfttfcg   TYPE zfttfcg.

  lv_kdgrp = 'GV_KDGRP'.

  CLEAR : lt_zfttfcg[], lt_zfttfcg.
  LOOP AT gt_zfttfcg INTO ls_zfttfcg.
    lt_zfttfcg-kdgrp     = ls_zfttfcg-kdgrp.
    APPEND lt_zfttfcg.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'KDGRP'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_kdgrp
      value_org   = 'S'
    TABLES
      value_tab   = lt_zfttfcg.
ENDMODULE.                 " VALUE_KDGRP  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_REAL_BAYAR
*&---------------------------------------------------------------------*
FORM f_real_bayar  USING    fu_estbayar fu_kunnr fu_01 fu_02 fu_03 fu_04
                            fu_bw
                   CHANGING fc_real.

  DATA : lv_datum   TYPE sy-datum,
         lv_03      TYPE zfttfoutbd-dd03.

  DATA : lv_dd      TYPE zfttfoutbd-dd01,
         lv_01x     TYPE zfttfoutbd-dd01,
         lv_02x     TYPE zfttfoutbd-dd02,
         lv_03x     TYPE zfttfoutbd-dd03,
         lv_04x     TYPE zfttfoutbd-dd04.

  lv_datum  = fu_estbayar.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datum
    IMPORTING
      last_day_of_month = lv_datum
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_datum  = lv_datum + 1.
  lv_03     = fu_03 + 1.

  IF fu_estbayar+6(2) <= fu_01.
    CONCATENATE fu_estbayar(6) fu_01 INTO fc_real.
  ELSEIF fu_estbayar+6(2) > fu_02.
    IF fu_bw IS NOT INITIAL.
      PERFORM f_get_date_from_week USING lv_datum fu_kunnr ''
                                CHANGING lv_01x lv_02x lv_03x lv_04x
                                         lv_dd.
      CONCATENATE lv_datum(6) lv_01x INTO fc_real.
    ELSE.
      CONCATENATE lv_datum(6) fu_01 INTO fc_real.
    ENDIF.
  ELSEIF fu_estbayar+6(2) BETWEEN lv_03 AND fu_02.
    CONCATENATE fu_estbayar(6) fu_02 INTO fc_real.
  ELSEIF fu_estbayar+6(2) BETWEEN fu_04 AND fu_03.
    CONCATENATE fu_estbayar(6) fu_03 INTO fc_real.
  ELSEIF fu_estbayar+6(2) BETWEEN fu_01 AND fu_04.
    CONCATENATE fu_estbayar(6) fu_04 INTO fc_real.
  ENDIF.
ENDFORM.                    " F_REAL_BAYAR

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE_ZFTRANSTTF
*&---------------------------------------------------------------------*
FORM f_save_table_zftransttf .
  DATA : lt_out           TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         lt_outh          TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
         ls_out           TYPE ty_out,
         ls_outh          TYPE ty_out,
         ls_zftransttf    TYPE zftransttf,
         lt_zftransttf    TYPE STANDARD TABLE OF zftransttf INITIAL SIZE 0.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  lt_outh[] = lt_out[].
  SORT lt_outh BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_outh COMPARING kunnr.

  LOOP AT lt_outh INTO ls_outh.
    LOOP AT lt_out INTO ls_out WHERE kunnr = ls_outh-kunnr.
      ls_zftransttf-bukrs     = ls_out-bukrs.
      ls_zftransttf-vkbur     = ls_out-vkbur.
      ls_zftransttf-nomorttf  = gs_zfttfno-nomorttf.
      ls_zftransttf-kunnr     = ls_out-kunnr.
      ls_zftransttf-zuonr     = ls_out-zuonr.
      ls_zftransttf-vbeln     = ls_out-vbeln.
      ls_zftransttf-belnr     = ls_out-belnr.
      ls_zftransttf-gjahr     = ls_out-gjahr.
      ls_zftransttf-zfbdt     = ls_out-zfbdt.
      ls_zftransttf-budat     = ls_out-budat.
      ls_zftransttf-blart     = ls_out-blart.
      ls_zftransttf-topext    = ls_out-topext.
      ls_zftransttf-zterm     = ls_out-zterm.
      ls_zftransttf-leadtm    = ls_out-leadtime.
      ls_zftransttf-shkzg     = ls_out-shkzg.
      ls_zftransttf-dmbtr     = ABS( ls_out-dmbtr ).
      ls_zftransttf-waers     = ls_out-waers.
      ls_zftransttf-zsugttf   = ls_out-suggest.
      ls_zftransttf-zestdt    = ls_out-estbayar.
      ls_zftransttf-zreadt    = ls_out-real.
      ls_zftransttf-username  = sy-uname.
      ls_zftransttf-tglinput  = sy-datum.
      ls_zftransttf-jaminput  = sy-uzeit.
      APPEND ls_zftransttf TO lt_zftransttf.
      CLEAR ls_zftransttf.
    ENDLOOP.

    TRY.
        INSERT zftransttf FROM TABLE lt_zftransttf.

        PERFORM f_modify_out TABLES lt_zftransttf.
        CLEAR : lt_zftransttf[], lt_zftransttf.

      CATCH cx_sy_open_sql_db .
    ENDTRY.

    gs_zfttfno-nomorttf = gs_zfttfno-nomorttf + 1.
  ENDLOOP.
ENDFORM.                    " F_SAVE_TABLE_ZFTRANSTTF

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_OUT
*&---------------------------------------------------------------------*
FORM f_modify_out  TABLES   ft_zftransttf STRUCTURE zftransttf.
  DATA : ls_zftransttf    TYPE zftransttf,
         ls_out           TYPE ty_out.

  LOOP AT ft_zftransttf INTO ls_zftransttf.
    ls_out-nomorttf   = ls_zftransttf-nomorttf.
    CLEAR ls_out-check.
    PERFORM f_fieldstyle USING : 'CHECK' ''
                         CHANGING ls_out-style.
    MODIFY gt_out FROM ls_out
                  TRANSPORTING check style nomorttf
                  WHERE bukrs = ls_zftransttf-bukrs
                    AND vkbur = ls_zftransttf-vkbur
                    AND kunnr = ls_zftransttf-kunnr
                    AND vbeln = ls_zftransttf-vbeln.
  ENDLOOP.

  CALL METHOD g_maingrid->refresh_table_display.
ENDFORM.                    " F_MODIFY_OUT

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
*&      Form  F_MODIFY_CHECK
*&---------------------------------------------------------------------*
FORM f_modify_check .
  DATA : ls_out   LIKE LINE OF gt_out.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-sel IS NOT INITIAL.
      ls_out-check = 'X'.
    ENDIF.
    MODIFY gt_out FROM ls_out TRANSPORTING check.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv  TABLES   ft_report.
  DATA: lv_func(22).

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_alv_variant_exist USING   pa_varnt
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout_lvc            = d_layout
      it_fieldcat_lvc          = t_alv_fieldcat[]
      it_sort_lvc              = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print_lvc             = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event  TABLES   ft_events LIKE t_events.

  CLEAR : ft_events[], ft_events.
  ft_events-name = slis_ev_data_changed.
  ft_events-form = 'F_DATA_CHANGED'.
  APPEND ft_events.
  CLEAR ft_events.
ENDFORM.                    " F_BUILD_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
FORM f_build_event_exit .
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    " F_BUILD_EVENT_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat  TABLES   ft_report.
  REFRESH: t_alv_fieldcat.
  CASE 'X'.
    WHEN pa_data.
      PERFORM f_fieldcatg USING 'GT_OUT' :
        'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' '' 'X' '' '' '',
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VKBUR' 'KNVV' 'VKBUR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NOMORTTF' 'ZFTTFNO' 'NOMORTTF' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VBELN' 'BSID' 'VBELN' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'GJAHR' 'BSID' 'GJAHR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZFBDT' 'BSID' 'ZFBDT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BUDAT' 'BSID' 'BUDAT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BLART' 'BSID' 'BLART' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'TOPEXT' 'ZFTTFOUTBD' 'TOPEXT' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'ZTERM' 'BSID' 'ZTERM' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' ''
        'WAERS' '' '' '' '' '' '' '',
        'TGLTTF' 'BSID' 'BUDAT' 'X' '' 'Tanggal TTF' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'SUGGEST' 'BSID' 'BUDAT' '' '' 'Suggest TTF' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'LEADTIME' 'BSID' 'BUDAT' '' '' 'Lead Time' '' '' ''
        '' '' '' '' '' '' '' '' 'R' '',
        'ESTBAYAR' 'BSID' 'BUDAT' 'X' '15' 'EstimasiBayar' '' '' '' ''
        '' '' '' '' '' '' '' '' '',
        'REAL' 'BSID' 'BUDAT' '' '15' 'Estimasi Bayar' '' '' '' '' '' '' ''
        '' '' '' '' '' ''.

    WHEN pa_rept.
      PERFORM f_fieldcatg USING 'GT_REPORT' :
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VKBUR' 'KNVV' 'VKBUR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NOMORTTF' 'ZFTTFNO' 'NOMORTTF' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'VBELN' 'BSID' 'VBELN' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'GJAHR' 'BSID' 'GJAHR' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ZFBDT' 'BSID' 'ZFBDT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BUDAT' 'BSID' 'BUDAT' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'BLART' 'BSID' 'BLART' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'TOPEXT' 'ZFTTFOUTBD' 'TOPEXT' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'ZTERM' 'BSID' 'ZTERM' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'LEADTM' 'ZFTRANSTTF' 'LEADTM' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' ''
        'WAERS' '' '' '' '' '' '' '',
        'ZSUGTTF' 'ZFTRANSTTF' 'ZSUGTTF' '' '' 'Suggest TTF' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'ZESTDT' 'ZFTRANSTTF' 'ZESTDT' 'X' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '',
        'ZREADT' 'ZFTRANSTTF' 'ZREADT' '' '' 'Estimasi Bayar' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'TGLTTF' 'ZFBID' 'TGLTTF' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'ESTTTF' 'ZFBID' 'TGLTTF' 'X' '' 'Est.TTF(Actual)' '' '' ''
        '' '' '' '' '' '' '' '' '' '',
        'REALTTF' 'ZFBID' 'TGLTTF' '' '15' 'Jadwal Bayar' '' ''
        '' '' '' '' '' '' '' '' '' '' '',
        'BBELN' 'ZFBIH' 'BBELN' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'BIDAT' 'ZFBIH' 'BIDAT' 'X' '' 'BI Create date' '' '' '' ''
        '' '' '' '' '' '' '' '' '',
        'USNA1' 'ZFBIH' 'USNA1' 'X' '' 'BI Create by' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'BFLAG' 'ZFBID' 'BFLAG' 'X' '' 'BFLAG' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'PSTAT' 'ZFBID' 'PSTAT' 'X' '' 'PSTAT' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'PTYPE' 'ZFBID' 'PTYPE' 'X' '' 'PTYPE' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'PAYID' 'ZFBID' 'USNA1' '' '' 'User Payment' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'PAYDT' 'ZFBID' 'ERDT1' '' '' 'Payment date' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'PAYMENT' 'ZFBID' 'PCASH' '' '' 'Amount Payment' '' '' '' ''
        '' 'WAERS' '' '' '' '' '' '' '',
        'USERNAME' 'ZFTRANSTTF' 'USERNAME' 'X' '' 'TTF Create by' ''
        '' '' '' '' '' '' '' '' '' '' '' '',
        'TGLINPUT' 'ZFTRANSTTF' 'TGLINPUT' 'X' '' 'TTF Create date'
        '' '' '' '' '' '' '' '' '' '' '' '' '',
        'JAMINPUT' 'ZFTRANSTTF' 'JAMINPUT' 'X' '' 'TTF Create time'
        '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LEADTF' '' '' '' '' 'Lead Time TTF' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'LOSSTF' '' '' '' '' 'Loss Lead Time TTF' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'SELISIH' 'ZFTRANSTTF' 'DMBTR' 'X' '' 'Selisih' '' '' '' ''
        '' 'WAERS' '' '' '' '' '' '' ''.
  ENDCASE.

ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_layout TYPE lvc_s_layo.
  CASE 'X'.
    WHEN pa_rept.
      fu_layout-zebra              = 'X'.
      fu_layout-box_fname          = 'SEL'.
    WHEN OTHERS.
      fu_layout-zebra              = 'X'.
      fu_layout-no_rowmark         = 'X'.
      fu_layout-stylefname         = 'STYLE'.
*  fu_layout-colwidth_optimize  = space.
*  fu_layout-no_colhead         = space.
*  fu_layout-group_change_edit  = 'X'.
*  fu_layout-detail_popup       = 'X'.
      fu_layout-box_fname          = 'SEL'.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
FORM f_build_print  USING    fu_print TYPE lvc_s_prnt.
*  fu_print-no_print_listinfos    = 'X'.
*  fu_print-no_print_selinfos     = 'X'.
*  fu_print-no_coverpage          = 'X'.
*  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    " F_BUILD_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield  USING    fu_sort TYPE lvc_t_sort.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN pa_data.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN pa_rept.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NOMORTTF'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data .
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA : fcode TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.

  IF pa_rept IS NOT INITIAL.
    APPEND '&POS'  TO fcode.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  CASE 'X'.
    WHEN pa_data.
      SET TITLEBAR 'PROCESS'.
    WHEN pa_rept.
      SET TITLEBAR 'REPORT'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING   value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_emphasize)
                          value(fu_edit)
                          value(fu_icon)
                          value(fu_just)
                          value(fu_f4).

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
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-f4availabl        = fu_f4.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_GUI_MESSAGE
*&---------------------------------------------------------------------*
FORM f_gui_message  USING    fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    " F_GUI_MESSAGE

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE,
         lv_valid,
         lt_rows        TYPE lvc_t_row.

  REFRESH: lt_dynpread.

  CLEAR ref_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF ref_grid IS NOT INITIAL.
    CALL METHOD ref_grid->check_changed_data
      IMPORTING
        e_valid = lv_valid.
  ENDIF.

  CASE fu_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CASE 'X'.
        WHEN pa_rept.
        WHEN OTHERS.
          CALL FUNCTION 'DEQUEUE_ALL'.
          CALL FUNCTION 'BUFFER_REFRESH_ALL'.
          CLEAR ok_code.
      ENDCASE.

      LEAVE TO SCREEN 0.

    WHEN '&POS'.
*      CALL METHOD ref_grid->check_changed_data
*        IMPORTING
*          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_modify_check.

        PERFORM f_number_range USING 'LOCK'.

        PERFORM f_save_table_zftransttf.

        UPDATE zfttfno FROM gs_zfttfno.
      ENDIF.

      CALL FUNCTION 'DEQUEUE_ALL'.
      CALL FUNCTION 'BUFFER_REFRESH_ALL'.
      CLEAR ok_code.

    WHEN '&SALL'.
*      CALL METHOD ref_grid->check_changed_data
*        IMPORTING
*          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL..
        PERFORM f_select USING 'X' ''.
      ENDIF.

    WHEN '&DALL'.
*      CALL METHOD ref_grid->check_changed_data
*        IMPORTING
*          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL..
        PERFORM f_select USING '' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*F_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_authorization USING fu_actvt.
  CASE 'X'.
    WHEN pa_cust.
      AUTHORITY-CHECK OBJECT 'ZFTTFHO'
                ID 'ACTVT' FIELD fu_actvt.
      IF sy-subrc = 0.
        CLEAR gv_subrc.
      ENDIF.

    WHEN pa_paym.
*      AUTHORITY-CHECK OBJECT 'ZFTTFHO'
*                ID 'ACTVT' FIELD fu_actvt.
*      IF sy-subrc = 0.
*        CLEAR gv_subrc.
*      ELSE.
      AUTHORITY-CHECK OBJECT 'ZFTTFCAB'
                ID 'ACTVT' FIELD fu_actvt.
      IF sy-subrc = 0.
        CLEAR gv_subrc.
      ENDIF.
*      ENDIF.
  ENDCASE.
ENDFORM.                    " F_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PAYMENT
*&---------------------------------------------------------------------*
FORM f_display_payment .
  DATA : ls_ttfoutpay  TYPE zfttfoutpay.

  LOOP AT gt_ttfoutpay INTO ls_ttfoutpay.
    CASE ls_ttfoutpay-week.
      WHEN 1.
        PERFORM f_week_display USING ls_ttfoutpay
                               CHANGING gv_week1 gv_sen1 gv_sel1 gv_rab1
                                                 gv_kam1 gv_jum1 gv_sab1.
      WHEN 2.
        PERFORM f_week_display USING ls_ttfoutpay
                               CHANGING gv_week2 gv_sen2 gv_sel2 gv_rab2
                                                 gv_kam2 gv_jum2 gv_sab2.
      WHEN 3.
        PERFORM f_week_display USING ls_ttfoutpay
                               CHANGING gv_week3 gv_sen3 gv_sel3 gv_rab3
                                                 gv_kam3 gv_jum3 gv_sab3.
      WHEN 4.
        PERFORM f_week_display USING ls_ttfoutpay
                               CHANGING gv_week4 gv_sen4 gv_sel4 gv_rab4
                                                 gv_kam4 gv_jum4 gv_sab4.
      WHEN 5.
        PERFORM f_week_display USING ls_ttfoutpay
                               CHANGING gv_week5 gv_sen5 gv_sel5 gv_rab5
                                                 gv_kam5 gv_jum5 gv_sab5.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_DISPLAY_PAYMENT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_WEEK_BW
*&---------------------------------------------------------------------*
FORM f_save_week_bw  USING    fs_ttfoutbw  STRUCTURE zfttfoutbw
                              fu_week fu_sen fu_sel fu_rab
                              fu_kam fu_jum fu_sab.

  DATA : ls_ttfoutbw     TYPE zfttfoutbw,
         ls_xttfoutbw    TYPE zfttfoutbw,
         lv_subrc        TYPE sy-subrc.

  ls_ttfoutbw         = fs_ttfoutbw.

  ls_ttfoutbw-week    = fu_week.
  ls_ttfoutbw-day1    = fu_sen.
  ls_ttfoutbw-day2    = fu_sel.
  ls_ttfoutbw-day3    = fu_rab.
  ls_ttfoutbw-day4    = fu_kam.
  ls_ttfoutbw-day5    = fu_jum.
  ls_ttfoutbw-day6    = fu_sab.

  CASE gv_subrc.
    WHEN 1.
      ls_ttfoutbw-username  = sy-uname.
      ls_ttfoutbw-tglinput  = sy-datum.
      ls_ttfoutbw-jaminput  = sy-uzeit.
      INSERT zfttfoutbw FROM ls_ttfoutbw.
    WHEN OTHERS.
      READ TABLE gt_ttfoutbw INTO ls_xttfoutbw
                             WITH KEY bukrs = ls_ttfoutbw-bukrs
                                      vkbur = ls_ttfoutbw-vkbur
                                      kunnr = ls_ttfoutbw-kunnr
                                      week  = ls_ttfoutbw-week.
      IF sy-subrc = 0.
        IF ls_ttfoutbw-day1 = ls_xttfoutbw-day1 AND
          ls_ttfoutbw-day2 = ls_xttfoutbw-day2 AND
          ls_ttfoutbw-day3 = ls_xttfoutbw-day3 AND
          ls_ttfoutbw-day4 = ls_xttfoutbw-day4 AND
          ls_ttfoutbw-day5 = ls_xttfoutbw-day5 AND
          ls_ttfoutbw-day6 = ls_xttfoutbw-day6.
        ELSE.
          ls_ttfoutbw-username  = ls_ttfoutbw-username.
          ls_ttfoutbw-tglinput  = ls_ttfoutbw-tglinput.
          ls_ttfoutbw-jaminput  = ls_ttfoutbw-jaminput.
          ls_ttfoutbw-modbe     = sy-uname.
          ls_ttfoutbw-modda     = sy-datum.
          ls_ttfoutbw-modti     = sy-uzeit.
          UPDATE zfttfoutbw FROM ls_ttfoutbw.
        ENDIF.
      ELSE.
        ls_ttfoutbw-username  = sy-uname.
        ls_ttfoutbw-tglinput  = sy-datum.
        ls_ttfoutbw-jaminput  = sy-uzeit.
        INSERT zfttfoutbw FROM ls_ttfoutbw.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SAVE_WEEK_BW

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_BW
*&---------------------------------------------------------------------*
FORM f_display_bw  USING    fu_sen fu_sel fu_rab fu_kam fu_jum fu_sab
                   CHANGING fc_sen fc_sel fc_rab fc_kam fc_jum fc_sab
                            fc_week.

  DATA : lv_week.

  IF fu_sen IS NOT INITIAL.
    fc_sen  = selected.
    lv_week = selected.
  ENDIF.
  IF fu_sel IS NOT INITIAL.
    fc_sel  = selected.
    lv_week = selected.
  ENDIF.
  IF fu_rab IS NOT INITIAL.
    fc_rab  = selected.
    lv_week = selected.
  ENDIF.
  IF fu_kam IS NOT INITIAL.
    fc_kam  = selected.
    lv_week = selected.
  ENDIF.
  IF fu_jum IS NOT INITIAL.
    fc_jum  = selected.
    lv_week = selected.
  ENDIF.
  IF fu_sab IS NOT INITIAL.
    fc_sab  = selected.
    lv_week = selected.
  ENDIF.

  fc_week = lv_week.
ENDFORM.                    " F_DISPLAY_BW

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATE_FROM_WEEK
*&---------------------------------------------------------------------*
FORM f_get_date_from_week  USING fu_budat fu_kunnr fu_flag
                        CHANGING fc_dd01 fc_dd02 fc_dd03 fc_dd04 fc_dd.

  DATA : lt_calendar  TYPE STANDARD TABLE OF ty_calendar INITIAL SIZE 0,
         ls_calendar  LIKE LINE OF lt_calendar,
         ls_ttfoutbw  LIKE LINE OF gt_ttfoutbw,
         lt_days      TYPE STANDARD TABLE OF ty_calendar INITIAL SIZE 0,
         ls_days      LIKE LINE OF lt_calendar,
         lt_week      TYPE STANDARD TABLE OF ty_calendar INITIAL SIZE 0,
         ls_week      LIKE LINE OF lt_calendar.

  DATA : lv_budat     TYPE sy-datum,
         lv_datum     TYPE sy-datum,
         lv_nextd     TYPE sy-datum,
         lv_monday    TYPE sy-datum,
         lv_sunday    TYPE sy-datum,
         lv_subrc     TYPE sy-subrc,
         lv_week      TYPE p DECIMALS 0,
         lv_day       TYPE p DECIMALS 0.

  CLEAR fc_dd.

  CONCATENATE fu_budat(6) '01' INTO lv_budat.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_budat
    IMPORTING
      last_day_of_month = lv_nextd
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lv_nextd = lv_nextd + 1.

  LOOP AT gt_ttfoutbw INTO ls_ttfoutbw WHERE kunnr = fu_kunnr.
    IF ls_ttfoutbw-day1 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 1.
    ENDIF.
    IF ls_ttfoutbw-day2 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 2.
    ENDIF.
    IF ls_ttfoutbw-day3 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 3.

    ENDIF.
    IF ls_ttfoutbw-day4 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 4.
    ENDIF.
    IF ls_ttfoutbw-day5 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 5.
    ENDIF.
    IF ls_ttfoutbw-day6 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 6.
    ENDIF.
    IF ls_ttfoutbw-day7 IS NOT INITIAL.
      PERFORM f_week_day TABLES lt_days
                         USING ls_ttfoutbw-week 7.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      date   = lv_budat
    IMPORTING
      monday = lv_monday
      sunday = lv_sunday.

  lv_datum  = lv_monday.
  lv_week   = 1.
  WHILE lv_subrc IS INITIAL.
    ADD 1 TO lv_day.
    ls_calendar-week  = lv_week.
    ls_calendar-day   = lv_day.
    ls_calendar-date  = lv_datum+6(2).
    IF lv_datum(6) = lv_budat(6).
      APPEND ls_calendar TO lt_calendar.
    ENDIF.
    ADD 1 TO lv_datum.
    IF lv_day = 7.
      CLEAR lv_day.
      ADD 1 TO lv_week.
    ENDIF.
    IF lv_datum = lv_nextd.
      lv_subrc = 4.
    ENDIF.
  ENDWHILE.

  LOOP AT lt_days INTO ls_days.
    CLEAR : lt_week[], lt_week, ls_calendar, lv_week.
    LOOP AT lt_calendar INTO ls_calendar WHERE day = ls_days-day.
      ADD 1 TO lv_week.
      ls_calendar-week  = lv_week.
      APPEND ls_calendar TO lt_week.
      CLEAR ls_calendar.
    ENDLOOP.
    READ TABLE lt_week INTO ls_week WITH KEY week = ls_days-week
                                             day  = ls_days-day.
    IF sy-subrc = 0.
      ls_days-date  = ls_week-date.
      MODIFY lt_days FROM ls_days TRANSPORTING date.
    ENDIF.
  ENDLOOP.

  SORT lt_days BY date.
  DELETE lt_days WHERE date = 0.
  LOOP AT lt_days INTO ls_days.
    IF fc_dd01 IS INITIAL.
      fc_dd01 = ls_days-date.
    ELSEIF fc_dd02 IS INITIAL.
      fc_dd02 = ls_days-date.
    ELSEIF fc_dd03 IS INITIAL.
      IF fu_flag IS INITIAL.
        fc_dd03 = ls_days-date.
      ENDIF.
    ELSEIF fc_dd04 IS INITIAL.
      IF fu_flag IS INITIAL.
        fc_dd04 = ls_days-date.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT lt_days BY date DESCENDING.
  READ TABLE lt_days INTO ls_days INDEX 1.
  IF sy-subrc = 0.
    fc_dd = ls_days-date.
  ENDIF.
ENDFORM.                    " F_GET_DATE_FROM_WEEK

*&---------------------------------------------------------------------*
*&      Form  F_WEEK_DAY
*&---------------------------------------------------------------------*
FORM f_week_day  TABLES   ft_days STRUCTURE gt_calendar
                 USING    fu_week fu_day.

  DATA : ls_days      TYPE ty_calendar.

  ls_days-week  = fu_week.
  ls_days-day   = fu_day.
  APPEND ls_days TO ft_days.
  CLEAR ls_days.
ENDFORM.                    " F_WEEK_DAY

*&---------------------------------------------------------------------*
*&      Form  F_TTF_DATE
*&---------------------------------------------------------------------*
FORM f_ttf_date  USING    fu_zfbdt fu_zbd1t fu_basic fu_leadtm1 fu_leadtm2
                          fu_topext fu_top fu_topflag
                          fu_dd01 fu_dd02 fu_dd03 fu_dd04
                 CHANGING fc_tglttf fc_equal.

  DATA : lv_basicdt    TYPE sy-datum,
         lv_dd01       TYPE sy-datum,
         lv_dd02       TYPE sy-datum,
         lv_dd03       TYPE sy-datum,
         lv_dd04       TYPE sy-datum.

  DATA : lv_tgljt      TYPE sy-datum,
         lv_nextm      TYPE sy-datum,
         lv_subrc      TYPE sy-subrc.

  CLEAR fc_tglttf.

  lv_tgljt = fu_zfbdt + fu_zbd1t.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_zfbdt
    IMPORTING
      last_day_of_month = lv_nextm
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lv_nextm  = lv_nextm + 1.

  IF fu_topflag IS INITIAL.
    lv_basicdt  = fu_zfbdt + fu_basic.
  ELSE.
    lv_basicdt  = fu_zfbdt + fu_top.
  ENDIF.

  IF lv_tgljt(6) = fu_zfbdt(6) OR
    lv_tgljt(6) = lv_nextm(6).
    IF fu_dd04 IS NOT INITIAL.
      PERFORM f_calculate_ttf_date USING fu_dd01 fu_dd03 fu_dd04 fu_zfbdt
                                         fu_leadtm1 lv_basicdt fu_topext
                                         lv_tgljt
                                   CHANGING fc_tglttf fc_equal.
    ELSEIF fu_dd03 IS NOT INITIAL.
      PERFORM f_calculate_ttf_date USING fu_dd01 fu_dd02 fu_dd03 fu_zfbdt
                                         fu_leadtm1 lv_basicdt fu_topext
                                         lv_tgljt
                                   CHANGING fc_tglttf fc_equal.
    ELSEIF fu_dd02 IS NOT INITIAL.
      PERFORM f_calculate_ttf_date USING fu_dd01 fu_dd01 fu_dd02 fu_zfbdt
                                         fu_leadtm1 lv_basicdt fu_topext
                                         lv_tgljt
                                   CHANGING fc_tglttf fc_equal.
    ENDIF.
  ELSE.
    fc_tglttf = fu_zfbdt + fu_leadtm1.
  ENDIF.

  IF fc_equal IS NOT INITIAL.
    lv_subrc = 4.
* Penambahan validasi untuk suggest date pada hari libur
    WHILE lv_subrc IS NOT INITIAL.
      PERFORM f_holiday_cek USING 'T1' fc_tglttf
                            CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        fc_tglttf = fc_tglttf - 1.
      ENDIF.
    ENDWHILE.
  ENDIF.
ENDFORM.                    " F_TTF_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_TTF_DATE
*&---------------------------------------------------------------------*
FORM f_calculate_ttf_date  USING    fu_dd01 fu_dd02 fu_dd03 fu_zfbdt
                                    fu_leadtm1 fu_basicdt fu_topext
                                    fu_tgljt
                           CHANGING fc_tglttf fc_equal.

  DATA : lv_dd01       TYPE sy-datum,
         lv_dd1        TYPE zfttfoutbd-dd01,
         lv_dd2        TYPE zfttfoutbd-dd01.

  lv_dd2 = fu_dd02 + 1.
  lv_dd1 = fu_dd01 + 1.

  IF fu_dd03 < fu_basicdt+6(2).
    CONCATENATE fu_tgljt(6) fu_dd03 INTO lv_dd01.
    fc_tglttf = lv_dd01 - fu_topext.
    fc_equal  = 'X'.
  ELSEIF fu_basicdt+6(2) BETWEEN lv_dd2 AND fu_dd03.
    fc_tglttf = fu_zfbdt + fu_leadtm1.
  ELSEIF fu_basicdt+6(2) BETWEEN lv_dd1 AND fu_dd02.
    fc_tglttf = fu_zfbdt + fu_leadtm1.
  ELSEIF fu_basicdt+6(2) <= fu_dd01.
    CONCATENATE fu_zfbdt(6) fu_dd01 INTO fc_tglttf.
  ENDIF.
ENDFORM.                    " F_CALCULATE_TTF_DATE

*&---------------------------------------------------------------------*
*&      Form  F_PAYMENT_PROCESS
*&---------------------------------------------------------------------*
FORM f_payment_process .
  DATA : ls_zfbid       TYPE zfbid,
         ls_zfbih       TYPE zfbih,
         ls_zfbicheck   TYPE zfbicheck,
         ls_payment     TYPE ty_payment,
         ls_bino        TYPE ty_bino.

  DATA : lv_payment     TYPE zfbid-pcash.

  LOOP AT gt_zfbid INTO ls_zfbid.
    ls_payment-bukrs   = ls_zfbid-bukrs.
    ls_payment-vkbur   = ls_zfbid-vkbur.
    ls_payment-zuonr   = ls_zfbid-zuonr.
    ls_payment-payid   = ls_zfbid-usna1.
    ls_payment-paydt   = ls_zfbid-erdt1.
    ls_payment-pcash   = ls_zfbid-pcash.
    ls_payment-ptrans  = ls_zfbid-ptrans.
    lv_payment         = ls_zfbid-pcash + ls_zfbid-ptrans.
    IF lv_payment IS NOT INITIAL.
      APPEND ls_payment TO gt_payment.
    ENDIF.
    CLEAR : ls_payment, lv_payment.

    ls_bino-bukrs      = ls_zfbid-bukrs.
    ls_bino-vkbur      = ls_zfbid-vkbur.
    ls_bino-zuonr      = ls_zfbid-zuonr.
    ls_bino-bbeln      = ls_zfbid-bbeln.
    ls_bino-bflag      = ls_zfbid-bflag.
    ls_bino-pstat      = ls_zfbid-pstat.
    ls_bino-ptype      = ls_zfbid-ptype.
    ls_bino-tglttf     = ls_zfbid-tglttf.
    READ TABLE gt_zfbih INTO ls_zfbih WITH KEY bukrs = ls_zfbid-bukrs
                                               vkbur = ls_zfbid-vkbur
                                               bbeln = ls_zfbid-bbeln.
    IF sy-subrc = 0.
      ls_bino-bidat      = ls_zfbih-bidat.
      ls_bino-usna1      = ls_zfbih-usna1.
      ls_bino-erzet      = ls_zfbih-erzet.
      ls_bino-erdt1      = ls_zfbih-erdt1.
      APPEND ls_bino TO gt_bino.
      CLEAR ls_bino.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_zfbicheck INTO ls_zfbicheck.
    ls_payment-bukrs   = ls_zfbicheck-bukrs.
    ls_payment-vkbur   = ls_zfbicheck-vkbur.
    ls_payment-zuonr   = ls_zfbicheck-zuonr.
    ls_payment-payid   = ls_zfbicheck-usna2.
    ls_payment-paydt   = ls_zfbicheck-erdt2.
    ls_payment-cchek   = ls_zfbicheck-cchek.
    IF ls_zfbicheck-cchek IS NOT INITIAL.
      APPEND ls_payment TO gt_payment.
    ENDIF.
    CLEAR ls_payment.
  ENDLOOP.
ENDFORM.                    " F_PAYMENT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_MONTH
*&---------------------------------------------------------------------*
FORM f_next_month  USING    fu_estttf
                   CHANGING fc_estttf.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_estttf
    IMPORTING
      last_day_of_month = fc_estttf
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  fc_estttf = fc_estttf + 1.
ENDFORM.                    " F_NEXT_MONTH
