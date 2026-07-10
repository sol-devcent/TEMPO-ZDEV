*&---------------------------------------------------------------------*
*&  Include  ZCO_E011F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
*  Header
  SELECT ce28010~bukrs, ce28010~gsber, gjahr, ce28010~prctr, rkaufnr, ce28010~wwsec, SUM( vv856001 ) AS original_budget, rec_waers,
    cepct~ktext AS ktext1, aufk~ktext AS ktext2, bezek
    INTO CORRESPONDING FIELDS OF TABLE @it_ce28010 FROM ce28010
    INNER JOIN cepct ON ce28010~prctr = cepct~prctr
    INNER JOIN aufk ON ce28010~rkaufnr = aufk~aufnr
    INNER JOIN t25b5 ON ce28010~wwsec = t25b5~wwsec WHERE
    gjahr = @p_gjahr AND
    ce28010~bukrs = @p_bukrs AND
    ce28010~gsber = @p_gsber AND
    ce28010~prctr = @p_prctr AND
    rkaufnr = @p_aufnr AND
    ce28010~wwsec IN @s_wwsec
    GROUP BY ce28010~bukrs, ce28010~gsber, ce28010~prctr, rkaufnr, ce28010~wwsec, rec_waers, gjahr, cepct~ktext, aufk~ktext, bezek.

  IF it_ce28010 IS INITIAL.
    MESSAGE 'No Data Original Budget' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    DATA: perio_data(7)      TYPE  c.
    DATA: start_perio_data(7)      TYPE  c.
    DATA(month_len) = strlen( p_mon ).
    IF month_len = 1.
      CONCATENATE  p_gjahr '00' p_mon INTO perio_data.
    ELSEIF month_len > 1.
      CONCATENATE  p_gjahr '0' p_mon INTO perio_data.
    ENDIF.
    CONCATENATE p_gjahr '001' INTO start_perio_data.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE @it_header
*      FROM ce28010 INNER JOIN cepct ON ce28010~prctr = cepct~prctr
*       INNER JOIN aufk ON ce28010~rkaufnr = aufk~aufnr
*       INNER JOIN t25b5 ON ce28010~wwsec = t25b5~wwsec
*      FOR ALL ENTRIES IN @it_ce28010 WHERE
*         gjahr = @it_ce28010-gjahr AND
*         ce28010~bukrs = @it_ce28010-bukrs AND
*         ce28010~gsber = @it_ce28010-gsber AND
*         ce28010~prctr = @it_ce28010-prctr AND
*         rkaufnr = @it_ce28010-rkaufnr AND
*         ce28010~wwsec = @it_ce28010-wwsec
*       GROUP BY bukrs, gsber, prctr, rkaufnr, wwsec, rec_waers, gjahr, cepct~ktext, aufk~ktext, bezek, perbl.

    SELECT rposn, vv856, budat, ce18010~bukrs, ce18010~gsber, ce18010~gjahr, ce18010~prctr, ce18010~rkaufnr, ce18010~wwsec, perio, perde, rbeln, ce18010~paobjnr, ekpo~ebeln, ce18010~rec_waers
      INTO CORRESPONDING FIELDS OF TABLE @it_ce18010 FROM ce18010
      INNER JOIN mseg ON ce18010~rbeln =  mseg~mblnr
      INNER JOIN ekpo ON mseg~ebeln = ekpo~ebeln
      FOR ALL ENTRIES IN @it_ce28010 WHERE
     ce18010~gjahr = @it_ce28010-gjahr AND
     ce18010~bukrs = @it_ce28010-bukrs AND
     ce18010~gsber = @it_ce28010-gsber AND
     ce18010~prctr = @it_ce28010-prctr AND
     ce18010~rkaufnr = @it_ce28010-rkaufnr AND
     ce18010~wwsec = @it_ce28010-wwsec AND
     ce18010~perio BETWEEN @start_perio_data AND @perio_data.

  ENDIF.

  IF it_ce18010 IS NOT INITIAL.
*        SORT it_ce18010 BY bukrs gsber gjahr perio ASCENDING.
    LOOP AT it_ce18010 INTO DATA(ls_ce18010).
      ls_total_actual-total_actual = ls_ce18010-vv856.
      ls_total_actual-perio = ls_ce18010-perio.
      ls_total_actual-rec_waers = ls_ce18010-rec_waers.
      ls_total_actual-ebeln = ls_ce18010-ebeln.
      ls_total_actual-ebelp = ls_ce18010-rposn+2(4).
      COLLECT ls_total_actual INTO it_total_actual.
    ENDLOOP.

    SELECT
      txz01, ekpo~ebeln, ekpo~ebelp, ekpo~aedat, ekpo~netwr,
      ekkn~aufnr, ekkn~paobjnr, ekkn~prctr, ekkn~gsber, ekko~waers, ekko~bukrs, ce48010_acct~wwsec", bseg~gjahr, bseg~belnr
      INTO CORRESPONDING FIELDS OF TABLE @it_detl_helper
      FROM ekpo
      INNER JOIN ekkn
      ON ekpo~ebeln = ekkn~ebeln
      AND ekpo~ebelp = ekkn~ebelp
      INNER JOIN ce48010_acct
      ON ekkn~paobjnr = ce48010_acct~paobjnr
      INNER JOIN ekko
      ON ekpo~ebeln = ekko~ebeln

*      INNER JOIN bseg
*      ON ekpo~ebeln = bseg~ebeln
*      AND ekko~bukrs = bseg~bukrs
*      INNER JOIN ce18010
*      ON ekkn~paobjnr = ce18010~paobjnr
*      ON ce18010~belnr = bseg~belnr
*      INNER JOIN mseg
*      ON ekpo~ebeln = mseg~ebeln
*      INNER JOIN ce18010
*      ON ce18010~rbeln = mseg~mblnr
      FOR ALL ENTRIES IN @it_ce18010
      WHERE ekkn~aufnr = @it_ce18010-rkaufnr
      AND ekkn~prctr = @it_ce18010-prctr
      AND ekkn~gsber = @it_ce18010-gsber
*      AND bseg~gjahr = @it_ce18010-gjahr
      AND ce48010_acct~wwsec = @it_ce18010-wwsec
      AND ekko~bukrs = @it_ce18010-bukrs.
*      WHERE ekkn~aufnr = @it_ce18010-rkaufnr
*      AND ekkn~prctr = @it_ce18010-prctr
*       AND ce48010_acct~wwsec = @it_ce18010-wwsec
*      AND mseg~ebeln = @space.
*      DELETE ADJACENT DUPLICATES FROM it_detl_helper COMPARING ebeln.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE it_bseg FROM bseg
      FOR ALL ENTRIES IN it_ce18010
    WHERE bseg~aufnr = it_ce18010-rkaufnr
    AND bseg~prctr = it_ce18010-prctr
    AND bseg~gsber = it_ce18010-gsber
    AND bseg~gjahr = it_ce18010-gjahr
    AND bseg~bukrs = it_ce18010-bukrs.
  ENDIF.

  IF it_detl_helper IS NOT INITIAL.

    LOOP AT it_detl_helper INTO DATA(ls_detl_helper).
*      Made changes, remove month???
      READ TABLE it_ce18010 INTO DATA(ls_ce18010_2) WITH KEY rkaufnr = ls_detl_helper-aufnr prctr = ls_detl_helper-prctr
wwsec = ls_detl_helper-wwsec gjahr = ls_detl_helper-aedat(4). "perde = ls_detl_helper-aedat+4(2).
*      READ TABLE it_ce18010 INTO DATA(ls_ce18010_2) WITH KEY rkaufnr = ls_detl_helper-aufnr prctr = ls_detl_helper-prctr
*      wwsec = ls_detl_helper-wwsec gjahr = ls_detl_helper-aedat(4) perde = ls_detl_helper-aedat+4(2).
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO it_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
        <fs_detl>-txz01 = ls_detl_helper-txz01.
        <fs_detl>-ebeln  = ls_detl_helper-ebeln.
        <fs_detl>-ebelp  = ls_detl_helper-ebelp.
        <fs_detl>-aedat  = ls_detl_helper-aedat.
        <fs_detl>-netwr  = ls_detl_helper-netwr.
        <fs_detl>-aufnr  = ls_detl_helper-aufnr.
        <fs_detl>-paobjnr = ls_detl_helper-paobjnr.
        <fs_detl>-waers = ls_detl_helper-waers.
        <fs_detl>-bukrs = ls_detl_helper-bukrs.
        <fs_detl>-gsber = ls_detl_helper-gsber.
        <fs_detl>-gjahr = ls_detl_helper-aedat(4).

        <fs_detl>-budat  = ls_ce18010_2-budat.
        <fs_detl>-vv856  = ls_ce18010_2-vv856.
        <fs_detl>-prctr  = ls_ce18010_2-prctr.
        <fs_detl>-wwsec  = ls_ce18010_2-wwsec.
        <fs_detl>-rec_waers  = ls_ce18010_2-rec_waers.

      ENDIF.
    ENDLOOP.
  ENDIF.

  IF it_detl IS NOT INITIAL.
    LOOP AT it_detl INTO DATA(ls_detl).
      READ TABLE it_total_actual INTO DATA(ls_total_actual) WITH KEY ebeln = ls_detl-ebeln perio(4) = ls_detl-aedat(4). "perio+5(2) = ls_detl-aedat+4(2).
      IF sy-subrc <> 0.
        IF ls_total_actual-perio+5(2) >= '01' AND ls_total_actual-perio+5(2) <= p_mon.
          ls_total_nilai_belum_realisasi-total_nilai_belum_realisasi = ls_detl-netwr.
          CONCATENATE ls_detl-aedat(4) '0' ls_detl-aedat+4(2) INTO ls_total_nilai_belum_realisasi-mon_year.
          ls_total_nilai_belum_realisasi-waers = ls_detl-waers.
          COLLECT ls_total_nilai_belum_realisasi INTO it_total_nilai_belum_realisasi.
        ENDIF.
        ls_total_plan-total_plan = ls_detl-netwr.
        ls_total_plan-waers = ls_detl-waers.
        ls_total_plan-gjahr =  ls_detl-aedat(4).
        ls_total_plan-perbl =  ls_detl-aedat+4(2).
        COLLECT ls_total_plan INTO it_total_plan.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: lv_month_name   TYPE t247-ltx.
  LOOP AT it_ce28010 INTO DATA(ls_ce28010).
    APPEND INITIAL LINE TO it_zco_e011_header ASSIGNING FIELD-SYMBOL(<fs_zco_e011_header>).
    <fs_zco_e011_header>-bukrs =            ls_ce28010-bukrs.
    <fs_zco_e011_header>-gsber =            ls_ce28010-gsber.

    SELECT SINGLE ltx INTO lv_month_name FROM t247 WHERE mnr = ls_total_actual-perio+5(2) AND spras = sy-langu.
    <fs_zco_e011_header>-period =           lv_month_name.
    <fs_zco_e011_header>-gjahr =            ls_ce28010-gjahr.
    <fs_zco_e011_header>-prctr =            ls_ce28010-prctr.
    <fs_zco_e011_header>-rkaufnr =          ls_ce28010-rkaufnr.
    <fs_zco_e011_header>-wwsec =            ls_ce28010-wwsec.
    <fs_zco_e011_header>-ktext1 =            ls_ce28010-ktext1.
    <fs_zco_e011_header>-ktext2 =            ls_ce28010-ktext2.
    <fs_zco_e011_header>-bezek =            ls_ce28010-bezek.
    <fs_zco_e011_header>-rec_waers =         ls_ce28010-rec_waers.
    WRITE ls_ce28010-original_budget TO <fs_zco_e011_header>-original_budget CURRENCY <fs_zco_e011_header>-rec_waers.
    CONDENSE <fs_zco_e011_header>-original_budget NO-GAPS.
















    LOOP AT it_total_actual INTO DATA(ls_total_actual).
      AT LAST.
        SUM.
        tot_act = ls_total_actual-total_actual.
      ENDAT.
    ENDLOOP.
    LOOP AT it_total_nilai_belum_realisasi INTO DATA(ls_total_nilai_belum_realisasi).
      <fs_zco_e011_header>-waers = ls_total_nilai_belum_realisasi-waers.
      AT LAST.
        SUM.
        belum_real = ls_total_nilai_belum_realisasi-total_nilai_belum_realisasi.
      ENDAT.
    ENDLOOP.
    spent_budget = tot_act + belum_real.
    WRITE spent_budget TO <fs_zco_e011_header>-spent_budget CURRENCY <fs_zco_e011_header>-rec_waers.
    CONDENSE <fs_zco_e011_header>-spent_budget NO-GAPS.
*    READ TABLE it_total_actual INTO DATA(ls_total_actual) WITH KEY perio(4) = ls_ce28010-gjahr.
*    IF sy-subrc = 0.
*      READ TABLE it_total_nilai_belum_realisasi INTO DATA(ls_total_nilai_belum_realisasi) WITH KEY mon_year(4) = ls_total_actual-perio(4).
**      IF sy-subrc = 0.
*        <fs_zco_e011_header>-waers = ls_total_nilai_belum_realisasi-waers.
*
*        spent_budget = ls_total_actual-total_actual + ls_total_nilai_belum_realisasi-total_nilai_belum_realisasi.
*        WRITE spent_budget TO <fs_zco_e011_header>-spent_budget CURRENCY <fs_zco_e011_header>-rec_waers.
*        CONDENSE <fs_zco_e011_header>-spent_budget NO-GAPS.
*
**      ENDIF.
*    ENDIF.
    IF <fs_zco_e011_header>-spent_budget IS INITIAL.
      <fs_zco_e011_header>-spent_budget = 0.
    ENDIF.
    budget_avail = ls_ce28010-original_budget - spent_budget.
    WRITE budget_avail TO <fs_zco_e011_header>-budget_avail CURRENCY <fs_zco_e011_header>-rec_waers.
    CONDENSE <fs_zco_e011_header>-budget_avail NO-GAPS.

  ENDLOOP.

  TRY.
      ls_zco_e011_header = it_zco_e011_header[ 1 ].
    CATCH cx_sy_itab_line_not_found.
      " Handle the case where the line is not found
  ENDTRY.

  DATA: prctr(10)  TYPE c,
        ktext1(20) TYPE c.

  CONCATENATE ls_zco_e011_header-prctr '  -  ' ls_zco_e011_header-ktext1 INTO profit_center RESPECTING BLANKS.
  CONCATENATE ls_zco_e011_header-rkaufnr '  -  ' ls_zco_e011_header-ktext2 INTO order RESPECTING BLANKS.
  CONCATENATE ls_zco_e011_header-wwsec '  -  ' ls_zco_e011_header-bezek INTO sec RESPECTING BLANKS.

  LOOP AT it_detl INTO DATA(ls_detl).
    APPEND INITIAL LINE TO it_zco_e011_detl ASSIGNING FIELD-SYMBOL(<fs_zco_e011_detl>).
    <fs_zco_e011_detl>-txz01 = ls_detl-txz01.
    <fs_zco_e011_detl>-ebeln1 = ls_detl-ebeln.
    <fs_zco_e011_detl>-ebelp1 = ls_detl-ebelp.
    <fs_zco_e011_detl>-aedat = ls_detl-aedat.
    <fs_zco_e011_detl>-netwr = ls_detl-netwr.
    <fs_zco_e011_detl>-waers = ls_detl-waers.
*    WRITE ls_detl-netwr TO <fs_zco_e011_detl>-netwr CURRENCY ls_detl-waers.
*    CONDENSE <fs_zco_e011_detl>-netwr NO-GAPS.
    READ TABLE it_ce18010 INTO DATA(ls_ce18010) WITH KEY ebeln = ls_detl-ebeln rposn+2(4) = ls_detl-ebelp+1(4).
    IF sy-subrc = 0.
      <fs_zco_e011_detl>-ebeln2 = ls_ce18010-ebeln.
      <fs_zco_e011_detl>-ebelp2 = ls_detl-ebelp.
      <fs_zco_e011_detl>-budat = ls_ce18010-budat.
      <fs_zco_e011_detl>-vv856 = ls_ce18010-vv856.
      <fs_zco_e011_detl>-rec_waers = ls_ce18010-rec_waers.
*      WRITE ls_ce18010-vv856 TO <fs_zco_e011_detl>-vv856 CURRENCY ls_ce18010-rec_waers.
*      CONDENSE <fs_zco_e011_detl>-vv856 NO-GAPS.
    ENDIF.
    READ TABLE it_bseg INTO DATA(ls_bseg) WITH KEY ebeln = ls_detl-ebeln.
    IF sy-subrc = 0.
      <fs_zco_e011_detl>-belnr  = ls_bseg-belnr.
    ENDIF.
  ENDLOOP.

  LOOP AT it_total_actual INTO DATA(ls_total_actual2).
    READ TABLE it_total_plan INTO DATA(ls_total_plan2) WITH KEY gjahr = ls_total_actual2-perio(4). "perbl = ls_total_actual2-perio+5(2).
    IF sy-subrc = 0.
      APPEND INITIAL LINE TO it_zco_e011_footer ASSIGNING FIELD-SYMBOL(<fs_zco_e011_footer>).
      WRITE ls_total_actual2-total_actual TO <fs_zco_e011_footer>-total_actual CURRENCY ls_total_actual2-rec_waers.
      WRITE ls_total_plan2-total_plan TO <fs_zco_e011_footer>-total_plan CURRENCY ls_total_plan2-waers.
      CONDENSE <fs_zco_e011_footer>-total_actual NO-GAPS.
      CONDENSE <fs_zco_e011_footer>-total_plan NO-GAPS.
    ENDIF.
  ENDLOOP.

  TRY.
      ls_zco_e011_footer  = it_zco_e011_footer[ 1 ].
    CATCH cx_sy_itab_line_not_found.
      " Handle the case where the line is not found
  ENDTRY.
ENDFORM.                    " F_PROCESS_DATA


**&---------------------------------------------------------------------*
**&      Form  TOP-OF-PAGE
**&---------------------------------------------------------------------*
FORM top-of-page.
  DATA: lt_header     TYPE slis_t_listheader,
        ls_header     TYPE slis_listheader,
        lt_line       LIKE ls_header-info,
        lv_lines      TYPE i,
        lv_linesc(10) TYPE c.

*&—– Alv report header —–*
  ls_header-typ = 'H'.
  ls_header-info = 'PT. BARCLAY PRODUCTS'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'H'.
  ls_header-info = 'EXPENSE CONTROL SHEET'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'H'.
*  ls_header-key = 'PERIOD: '.
  CONCATENATE 'PERIOD: ' ls_zco_e011_header-period ls_zco_e011_header-gjahr INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'Profit Center: '.
  ls_header-info = profit_center.
*  CONCATENATE ls_zco_e011_header-prctr ls_zco_e011_header-ktext1 INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'Order: '.
  ls_header-info = order.
*  CONCATENATE ls_zco_e011_header-rkaufnr ls_zco_e011_header-ktext2 INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'SEC: '.
  ls_header-info = sec.
*  CONCATENATE ls_zco_e011_header-wwsec ls_zco_e011_header-bezek INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'Original Budget: '.
  ls_header-info = ls_zco_e011_header-original_budget.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'Spent Budget: '.
  ls_header-info = ls_zco_e011_header-spent_budget.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-key = 'Budget Available: '.
  ls_header-info = ls_zco_e011_header-budget_avail.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
**&—– Pass data and field catalog to ALV function module —–*

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM. "top-of-page
*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS
*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&EXECUTE'.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND
**&---------------------------------------------------------------------*
**&      Form  F_PRINT_DATA
**&---------------------------------------------------------------------*
FORM f_print_data.

  DATA: g_repid   TYPE sy-repid.
  g_repid = sy-repid.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'zco_e011_detl'
    CHANGING
      ct_fieldcat      = lt_fieldcat.

  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
    CASE <fs_fieldcat>-fieldname.
      WHEN 'TXZ01'.
        <fs_fieldcat>-seltext_s = 'Assignment'.
        <fs_fieldcat>-seltext_m = 'Assignment'.
        <fs_fieldcat>-seltext_l = 'Assignment'.
        <fs_fieldcat>-reptext_ddic = 'Assignment'.
      WHEN 'EBELN1'.
        <fs_fieldcat>-seltext_s = 'No. PO'.
        <fs_fieldcat>-seltext_m = 'No. PO'.
        <fs_fieldcat>-seltext_l = 'No. PO'.
        <fs_fieldcat>-reptext_ddic = 'No. PO'.
      WHEN 'EBELP1'.
        <fs_fieldcat>-seltext_s = 'No. Item'.
        <fs_fieldcat>-seltext_m = 'No. Item'.
        <fs_fieldcat>-seltext_l = 'No. Item'.
        <fs_fieldcat>-reptext_ddic = 'No. Item'.
      WHEN 'AEDAT'.
        <fs_fieldcat>-seltext_s = 'PO Date'.
        <fs_fieldcat>-seltext_m = 'PO Date'.
        <fs_fieldcat>-seltext_l = 'PO Date'.
        <fs_fieldcat>-reptext_ddic = 'PO Date'.
      WHEN 'NETWR'.
        <fs_fieldcat>-seltext_s = 'PO Value'.
        <fs_fieldcat>-seltext_m = 'PO Value'.
        <fs_fieldcat>-seltext_l = 'PO Value'.
        <fs_fieldcat>-reptext_ddic = 'PO Value'.
        <fs_fieldcat>-cfieldname = 'WAERS'.
        <fs_fieldcat>-do_sum = 'X'.
        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'zco_e011_detl'.
      WHEN 'EBELN2'.
        <fs_fieldcat>-seltext_s = 'PO Doc.'.
        <fs_fieldcat>-seltext_m = 'PO Doc.'.
        <fs_fieldcat>-seltext_l = 'PO Doc.'.
        <fs_fieldcat>-reptext_ddic = 'PO Doc.'.
      WHEN 'EBELP2'.
        <fs_fieldcat>-seltext_s = 'No. Item'.
        <fs_fieldcat>-seltext_m = 'No. Item'.
        <fs_fieldcat>-seltext_l = 'No. Item'.
        <fs_fieldcat>-reptext_ddic = 'No. Item'.
      WHEN 'BUDAT'.
        <fs_fieldcat>-seltext_s = 'Posting Date'.
        <fs_fieldcat>-seltext_m = 'Posting Date'.
        <fs_fieldcat>-seltext_l = 'Posting Date'.
        <fs_fieldcat>-reptext_ddic = 'Posting Date'.
      WHEN 'BELNR'.
        <fs_fieldcat>-seltext_s = 'FI Document'.
        <fs_fieldcat>-seltext_m = 'FI Document'.
        <fs_fieldcat>-seltext_l = 'FI Document'.
        <fs_fieldcat>-reptext_ddic = 'FI Document'.
      WHEN 'VV856'.
        <fs_fieldcat>-seltext_s = 'Actual Value'.
        <fs_fieldcat>-seltext_m = 'Actual Value'.
        <fs_fieldcat>-seltext_l = 'Actual Value'.
        <fs_fieldcat>-reptext_ddic = 'Actual Value'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
        <fs_fieldcat>-do_sum = 'X'.
        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'zco_e011_detl'.
      WHEN 'WAERS'.
        <fs_fieldcat>-seltext_s = 'Currency'.
        <fs_fieldcat>-seltext_m = 'Currency'.
        <fs_fieldcat>-seltext_l = 'Currency'.
        <fs_fieldcat>-reptext_ddic = 'Currency'.
      WHEN 'REC_WAERS'.
        <fs_fieldcat>-seltext_s = 'Currency'.
        <fs_fieldcat>-seltext_m = 'Currency'.
        <fs_fieldcat>-seltext_l = 'Currency'.
        <fs_fieldcat>-reptext_ddic = 'Currency'.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      it_fieldcat              = lt_fieldcat
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_default                = 'X'
      i_save                   = 'A'
*     i_structure_name         = 'zco_e011_detl'
    TABLES
      t_outtab                 = it_zco_e011_detl.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_TYPE
*&---------------------------------------------------------------------*
FORM f_output_type .
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
ENDFORM.                    " F_OUTPUT_TYPE
