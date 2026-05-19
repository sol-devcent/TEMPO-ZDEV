*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_LISTF01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr TYPE kunnr,
         END OF lt_kna1.

  DATA : is_control LIKE bapidlvbuffercontrol,
         it_tknum   LIKE bapidlv_range_tknum OCCURS 0 WITH HEADER LINE.

  DATA : ls_003        LIKE LINE OF gt_003,
         lv_oriqty(10),
         lv_eceqty(10).

  is_control-bypassing_buffer = 'X'.
  is_control-head_status      = 'X'.
  is_control-head_partner     = 'X'.
  is_control-item             = 'X'.
  is_control-item_status      = 'X'.
  is_control-doc_flow         = 'X'.
  is_control-ft_data          = 'X'.
  is_control-hu_data          = 'X'.
  is_control-serno            = 'X'.

  it_tknum-sign               = 'I'.
  it_tknum-option             = 'EQ'.
  it_tknum-shipmentnum_low    = pa_tknum.
  APPEND it_tknum.

  CALL FUNCTION 'BAPI_DELIVERY_GETLIST'
    EXPORTING
      is_dlv_data_control = is_control
    TABLES
      it_tknum            = it_tknum
      et_delivery_header  = et_delivery_header
      et_delivery_item    = et_delivery_item
      et_delivery_partner = et_delivery_partner
      return              = return.

  CHECK return[] IS INITIAL.

  READ TABLE et_delivery_header INDEX 1.

  SELECT SINGLE vtext
    FROM tvkot
    INTO wa_header-vtext
    WHERE spras EQ sy-langu
      AND vkorg EQ et_delivery_header-vkorg.

  CONCATENATE 'PT.' wa_header-vtext INTO wa_header-vtext
  SEPARATED BY space.
  TRANSLATE wa_header-vtext TO UPPER CASE.

  SELECT SINGLE bezei street city1 post_code1
    FROM tvbur JOIN tvkbt ON spras EQ sy-langu
                AND tvbur~vkbur EQ tvkbt~vkbur
               JOIN adrc ON tvbur~adrnr EQ adrc~addrnumber
    INTO (wa_header-bezei, wa_header-street, wa_header-city1,
          wa_header-post_code1)
    WHERE tvbur~vkbur EQ et_delivery_header-vstel.

  SELECT SINGLE active
    FROM zwmdt008
    INTO gv_active
    WHERE werks = et_delivery_header-vstel.

  wa_header-tknum = pa_tknum.

  SELECT SINGLE erdat erzet exti1 signi tplst tdlnr route
    FROM vttk
    INTO (wa_header-erdat, wa_header-erzet, wa_header-exti1,
         wa_header-signi, wa_header-tplst, wa_header-tdlnr,
         wa_header-route2)
    WHERE tknum EQ pa_tknum.

  SELECT SINGLE name1 INTO wa_header-name1
    FROM lfa1 WHERE lifnr = wa_header-tdlnr.

  IF wa_header-name1 IS NOT INITIAL.
    CONCATENATE 'Agent :' wa_header-name1 INTO wa_header-name1
      SEPARATED BY space.
  ENDIF.

  IF et_delivery_header[] IS NOT INITIAL.
    SELECT *
      FROM zwmdt003
      INTO CORRESPONDING FIELDS OF TABLE gt_003
      FOR ALL ENTRIES IN et_delivery_header
      WHERE tknum = pa_tknum
        AND vbeln = et_delivery_header-vbeln.
  ENDIF.

  LOOP AT et_delivery_header.
    LOOP AT et_delivery_partner WHERE vbeln = et_delivery_header-vbeln.
      CASE et_delivery_partner-parvw.
        WHEN 'ZS'.
          gt_detail-route = et_delivery_partner-kunnr.
        WHEN 'WE'.
          gt_detail-lzone = et_delivery_partner-lzone.
      ENDCASE.
    ENDLOOP.
    gt_detail-vbeln = et_delivery_header-vbeln.
    gt_detail-bldat = et_delivery_header-bldat.
    gt_detail-kunnr = et_delivery_header-kunnr.
    SELECT SINGLE name1
      FROM kna1
      INTO gt_detail-name1
      WHERE kunnr EQ et_delivery_header-kunnr.
    lt_kna1-kunnr = et_delivery_header-kunnr.

    CLEAR ls_003.
    READ TABLE gt_003 INTO ls_003
                      WITH KEY vbeln = et_delivery_header-vbeln.
    IF sy-subrc = 0.
      WRITE ls_003-rpcont TO lv_oriqty.
      WRITE ls_003-rpsonst TO lv_eceqty.
      CONDENSE : lv_oriqty NO-GAPS,
                 lv_eceqty NO-GAPS.
    ELSE.
      lv_oriqty = '0'.
      lv_eceqty = '0'.
    ENDIF.

    CONCATENATE 'Koli Original =' lv_oriqty 'Koli Eceran =' lv_eceqty
    INTO gt_detail-koli
    SEPARATED BY space.

    APPEND lt_kna1.
    APPEND gt_detail.
    CLEAR gt_detail.
  ENDLOOP.

  SORT lt_kna1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kna1.
  DESCRIBE TABLE lt_kna1 LINES wa_header-ttldp.
  DESCRIBE TABLE gt_detail LINES wa_header-ttldn.




*  vttp-tknum ambil vbeln -> vbss-sammg compare vbeln in vttp with vbss
  SELECT vbss~sammg INTO TABLE @DATA(it_sammg)
    FROM vttp INNER JOIN vbss ON vttp~vbeln = vbss~vbeln
              INNER JOIN vbsk ON vbsk~sammg = vbss~sammg
    WHERE vttp~tknum = @pa_tknum
      AND vbsk~smart = 'M'.

    DELETE ADJACENT DUPLICATES FROM it_sammg COMPARING sammg.
*  DATA: sammg_data(255) TYPE c.
  IF it_sammg IS NOT INITIAL.
    wa_sammg-sammg_list = concat_lines_of( table = it_sammg
                                  sep   = ', ' ).
  ENDIF.




ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA : lv_kwert TYPE kwert,
         lv_brgew TYPE brgew_15,
         lv_volum TYPE volum_15,
         lv_lfimg TYPE volum_15.

  SORT gt_detail BY vbeln.
  SORT et_delivery_item BY vbeln.
  SORT et_delivery_partner BY vbeln.

  LOOP AT gt_detail.
*    PERFORM f_calc_item USING gt_detail-vbeln 'IDR' 'G' 'CCM'
    PERFORM f_calc_item USING gt_detail-vbeln 'IDR' 'KG' 'M3'
                        CHANGING gt_detail-kwert gt_detail-kwertt
                                 gt_detail-waers
                                 gt_detail-brgew gt_detail-brgewt
                                 gt_detail-gewei
                                 gt_detail-volum gt_detail-volumt
                                 gt_detail-voleh
                                 gt_detail-lfimg gt_detail-lfimgt
                                 gt_detail-vrkme gt_detail-abrvw.
    ADD gt_detail-kwert TO lv_kwert.
    ADD gt_detail-brgew TO lv_brgew.
    ADD gt_detail-volum TO lv_volum.
    ADD gt_detail-lfimg TO lv_lfimg.
    MODIFY gt_detail TRANSPORTING kwert kwertt waers
                                  brgew brgewt gewei
                                  volum volumt voleh
                                  lfimg lfimgt vrkme
                                  abrvw.
    CLEAR gt_detail.
  ENDLOOP.

  WRITE lv_kwert TO wa_header-ttlkwert CURRENCY 'IDR'.

  PERFORM f_round USING lv_brgew
                  CHANGING wa_header-ttlbrgew.
  PERFORM f_round USING lv_volum
                  CHANGING wa_header-ttlvolum.
  PERFORM f_round USING lv_lfimg
                  CHANGING wa_header-ttllfimg.
*  PERFORM f_conv_to_m3 USING lv_brgew
*                       CHANGING wa_header-ttlbrgew.
*  PERFORM f_conv_to_m3 USING lv_volum
*                       CHANGING wa_header-ttlvolum.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  TABLES: zsfasddt003.
  DATA: BEGIN OF li_status,
          nomor_order_sfa(10),
          nomor_quotation(10),
          tanggal_quotation(10),
          nomor_dn(10),
          tanggal_dn(10),
          nomor_billing(10),
          tanggal_billing(10),
          nomor_shipment(10),
          tanggal_shipment(10),
          amount(15),
          status(1),
          idoc(20),
        END  OF li_status.
  DATA: lv_str      TYPE string, lv_error(1).
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.
  DATA: gs_zsfasddt003 TYPE zsfasddt003,
        l_ctr          TYPE i.

  IF gv_active IS NOT INITIAL.
    p_tdform = 'ZS_SHIPMENT_LIST2'.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

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
        wa_sammg           = wa_sammg
      TABLES
        gt_detail          = gt_detail.

**** Tambahan Proses untuk mengirimkan order status ke TiMOS dengan menggunakan API
***  Tanggal: 07 Jan 2021
***   By SUK
    IF gt_detail[] IS NOT INITIAL.
      LOOP AT gt_detail.
        CLEAR: li_status,  lv_str.
        CLEAR: let_docflow[], let_docflow.
        CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
          EXPORTING
            iv_docnum  = gt_detail-vbeln
          IMPORTING
            et_docflow = let_docflow.
        IF let_docflow[] IS NOT INITIAL.
          LOOP AT let_docflow INTO lw_docflow.
            CASE lw_docflow-vbtyp_n.
              WHEN 'C'.
                li_status-nomor_quotation = lw_docflow-vbeln.
                li_status-tanggal_quotation = lw_docflow-erdat.
                SELECT SINGLE submi INTO li_status-nomor_order_sfa FROM vbak WHERE vbeln = lw_docflow-vbeln.
              WHEN 'J'.
                li_status-nomor_dn = lw_docflow-vbeln.
                li_status-tanggal_dn = lw_docflow-erdat.
              WHEN '8'.
                li_status-nomor_shipment = lw_docflow-vbeln.
                li_status-tanggal_shipment = lw_docflow-erdat.
              WHEN 'M'.
                li_status-nomor_billing = lw_docflow-vbeln.
                li_status-tanggal_billing = lw_docflow-erdat.
            ENDCASE.
          ENDLOOP.
          IF li_status-nomor_order_sfa IS NOT INITIAL.
            li_status-status = 'S'.
            PERFORM f_send_order_status(zsfa_i0001) USING li_status
                                   wa_header-vkorg wa_header-vstel
                                   CHANGING sy-subrc  lv_str .
**            CLEAR:  gs_zsfasddt003.
**            gs_zsfasddt003-vkorg  = wa_header-vkorg.
**            gs_zsfasddt003-vkbur  = wa_header-vstel.
**            gs_zsfasddt003-submi  = li_status-nomor_order_sfa.
**            gs_zsfasddt003-status = lv_str.
**            gs_zsfasddt003-erdate = sy-datum.
**            gs_zsfasddt003-ertime = sy-uzeit.
**            gs_zsfasddt003-ername  = sy-uname.
**            SELECT SINGLE counter INTO gs_zsfasddt003-counter FROM zsfasddt003
**              WHERE vkorg = gs_zsfasddt003-vkorg AND
**                    vkbur = gs_zsfasddt003-vkbur AND
**                    submi = gs_zsfasddt003-submi.
**            IF sy-subrc EQ 0.
**              l_ctr = gs_zsfasddt003-counter.
**              ADD 1 TO l_ctr.
**              gs_zsfasddt003-counter = l_ctr.
**            ELSE.
**              gs_zsfasddt003-counter = 1.
**            ENDIF.
**            MOVE-CORRESPONDING gs_zsfasddt003 TO zsfasddt003.
**            MODIFY zsfasddt003.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR : gt_detail, gt_detail[], wa_header, et_delivery_header[],
          et_delivery_header, et_delivery_item[], et_delivery_item,
          return[], return.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ITEM
*&---------------------------------------------------------------------*
FORM f_calc_item  USING    fu_vbeln fu_waers fu_gewei fu_voleh
                  CHANGING fc_kwert fc_kwertt fc_waers
                           fc_brgew fc_brgewt fc_gewei
                           fc_volum fc_volumt fc_voleh
                           fc_lfimg fc_lfimgt fc_vrkme
                           fc_abrvw.

  DATA : lt_item LIKE bapidlvitem OCCURS 0 WITH HEADER LINE.
  DATA : ls_et_delivery_header LIKE et_delivery_header.

  DATA : lv_netwr TYPE netwr_ak,
         lv_waerk TYPE waerk,
         lv_brgew TYPE brgew_15,
         lv_volum TYPE volum_15,
         lv_lfimg TYPE lfimg.

  READ TABLE et_delivery_item WITH KEY vbeln = fu_vbeln
                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    SELECT SINGLE netwr waerk abrvw
      FROM vbak
      INTO (lv_netwr, lv_waerk, fc_abrvw)
      WHERE vbeln EQ et_delivery_item-vgbel.

*    fc_kwert  = lv_netwr * 11 / 10.

    IF wa_header-tplst(2) = '02' OR
      wa_header-tplst(2) = '07'.
      IF fc_abrvw = 'M'.
        fc_kwert = 0.
      ELSE.
        fc_kwert  = lv_netwr * 11 / 10.
      ENDIF.
    ELSE.
      fc_kwert  = lv_netwr * 11 / 10.
    ENDIF.

    WRITE fc_kwert TO fc_kwertt CURRENCY fu_waers.
  ENDIF.

  LOOP AT et_delivery_item WHERE vbeln EQ fu_vbeln.
    PERFORM f_conversion USING et_delivery_item-brgew et_delivery_item-gewei
                               fu_gewei
                         CHANGING lv_brgew.
    PERFORM f_conversion USING et_delivery_item-volum et_delivery_item-voleh
                               fu_voleh
                         CHANGING lv_volum.
    PERFORM f_karton_conversion USING et_delivery_item-lfimg et_delivery_item-vrkme
                                      et_delivery_item-matnr
                                CHANGING lv_lfimg.
    ADD lv_brgew TO fc_brgew.
    ADD lv_volum TO fc_volum.
    ADD lv_lfimg TO fc_lfimg.
  ENDLOOP.

  PERFORM f_round USING fc_brgew
                  CHANGING fc_brgewt.
  PERFORM f_round USING fc_volum
                  CHANGING fc_volumt.
  PERFORM f_round USING fc_lfimg
                  CHANGING fc_lfimgt.
*  PERFORM f_conv_to_m3 USING fc_brgew
*                       CHANGING fc_brgewt.
*  PERFORM f_conv_to_m3 USING fc_volum
*                       CHANGING fc_volumt.

  fc_waers = fu_waers.
  fc_gewei = fu_gewei.
  fc_voleh = fu_voleh.
  fc_vrkme = et_delivery_item-vrkme.

  CLEAR ls_et_delivery_header.
  READ TABLE et_delivery_header INTO ls_et_delivery_header
    WITH KEY vbeln = fu_vbeln.
  IF ls_et_delivery_header-lfart = 'YTO1'.
    fc_lfimg = ls_et_delivery_header-anzpk.
    PERFORM f_round USING fc_lfimg
                    CHANGING fc_lfimgt.
  ENDIF.
ENDFORM.                    " F_CALC_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_input fu_unit_in fu_unit_out
                   CHANGING fc_output.

  CLEAR fc_output.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fu_input
      round_sign           = 'X'
      unit_in              = fu_unit_in
      unit_out             = fu_unit_out
    IMPORTING
      output               = fc_output
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.

ENDFORM.                    " F_CONVERSI

*&---------------------------------------------------------------------*
*&      Form  F_KARTON_CONVERSION
*&---------------------------------------------------------------------*
FORM f_karton_conversion  USING    fu_input fu_unit fu_matnr
                          CHANGING fc_output.

  CLEAR fc_output.

  CALL FUNCTION 'EHSWA_490_UNIT_CONVERSION'
    EXPORTING
      i_unit_source           = fu_unit
      i_unit_target           = 'KAR'
      i_quantity_source       = fu_input
      i_matnr                 = fu_matnr
    IMPORTING
      e_quantity_target       = fc_output
    EXCEPTIONS
      parameter_error         = 1
      err_conversion_global   = 2
      err_conversion_material = 3
      OTHERS                  = 4.
ENDFORM.                    " F_KARTON_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_value
              CHANGING fc_value.
  DATA : lv_value   TYPE p DECIMALS 2.
  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = fu_value
      sign          = '+'
    IMPORTING
      output        = lv_value
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

  WRITE lv_value TO fc_value DECIMALS 2.

ENDFORM.                    " F_ROUND

*&---------------------------------------------------------------------*
*&      Form  F_CONV_TO_M3
*&---------------------------------------------------------------------*
FORM f_conv_to_m3  USING    fu_value
                   CHANGING fc_value.
  DATA : lv_value1 TYPE p DECIMALS 6,
         lv_value2 TYPE p DECIMALS 3.

  lv_value1 = fu_value.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 3
      input         = lv_value1
      sign          = '+'
    IMPORTING
      output        = lv_value2
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

  fu_value = lv_value2.
  WRITE lv_value2 TO fc_value DECIMALS 3.

ENDFORM.                    " F_CONV_TO_M3
