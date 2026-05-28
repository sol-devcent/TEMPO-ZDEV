*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_LIST1F01
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
  DATA : is_control LIKE bapidlvbuffercontrol,
         it_tknum   LIKE bapidlv_range_tknum OCCURS 0 WITH HEADER LINE.

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

  LOOP AT et_delivery_header.
    IF nast-kschl = 'ZTRD'.
      IF et_delivery_header-lfart <> 'ZTD1'.
        CONTINUE.
      ENDIF.
    ENDIF.

    gt_header-vkorg = et_delivery_header-vkorg.
    gt_header-vstel = et_delivery_header-vstel.
    gt_header-tknum = pa_tknum.
    IF nast-kschl = 'YO2O'.
      gt_header-route = et_delivery_header-route.
    ENDIF.
    gt_header-kschl = nast-kschl.
    COLLECT gt_header.

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
    gt_kna1-vkorg = et_delivery_header-vkorg.
    gt_kna1-kunnr = et_delivery_header-kunnr.
    APPEND gt_kna1.

    gt_detail-vkorg = et_delivery_header-vkorg.

    IF et_delivery_header-lfart = 'ZTD1'.
      gt_detail-abrvw = et_delivery_header-inco2.
    ENDIF.
    APPEND gt_detail.
    CLEAR gt_detail.
  ENDLOOP.

  SORT gt_kna1 BY vkorg kunnr.
  DELETE ADJACENT DUPLICATES FROM gt_kna1 COMPARING vkorg kunnr.
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

  DATA : lt_vekp TYPE STANDARD TABLE OF vekp INITIAL SIZE 0,
         ls_vekp LIKE LINE OF lt_vekp.

  SORT gt_detail BY vbeln.
  SORT et_delivery_item BY vbeln.
  SORT et_delivery_partner BY vbeln.

  LOOP AT gt_header INTO wa_header.
    SELECT SINGLE vtext
      FROM tvkot
      INTO wa_header-vtext
      WHERE spras EQ sy-langu
        AND vkorg EQ wa_header-vkorg.

    CONCATENATE 'PT.' wa_header-vtext INTO wa_header-vtext
    SEPARATED BY space.
    TRANSLATE wa_header-vtext TO UPPER CASE.

    SELECT SINGLE bezei street city1 post_code1
      FROM tvbur JOIN tvkbt ON spras EQ sy-langu
                  AND tvbur~vkbur EQ tvkbt~vkbur
                 JOIN adrc ON tvbur~adrnr EQ adrc~addrnumber
      INTO (wa_header-bezei, wa_header-street, wa_header-city1,
            wa_header-post_code1)
      WHERE tvbur~vkbur EQ wa_header-vstel.

    SELECT SINGLE erdat erzet exti1 signi tplst
      FROM vttk
      INTO (wa_header-erdat, wa_header-erzet, wa_header-exti1,
           wa_header-signi, wa_header-tplst)
      WHERE tknum EQ wa_header-tknum.

    CLEAR : lv_kwert, lv_brgew, lv_volum, lv_lfimg.
    LOOP AT gt_detail WHERE vkorg = wa_header-vkorg.
      ADD 1 TO wa_header-ttldn.
      PERFORM f_calc_item USING gt_detail-vbeln 'IDR' 'KG' 'M3'
                          CHANGING gt_detail-kwert gt_detail-kwertt
                                   gt_detail-waers
                                   gt_detail-brgew gt_detail-brgewt
                                   gt_detail-gewei
                                   gt_detail-volum gt_detail-volumt
                                   gt_detail-voleh
                                   gt_detail-lfimg gt_detail-lfimgt
                                   gt_detail-vrkme gt_detail-abrvw
                                   gt_detail-bezei.

      ADD gt_detail-brgew TO lv_brgew.
      ADD gt_detail-volum TO lv_volum.
      ADD gt_detail-lfimg TO lv_lfimg.

      IF nast-kschl = 'ZTRD'.
        READ TABLE et_delivery_partner
         WITH KEY vbeln = gt_detail-vbeln
                  parvw = 'WE'.
        IF sy-subrc = 0.
          SELECT SINGLE name1
            FROM adrc
            INTO gt_detail-name1
            WHERE addrnumber = et_delivery_partner-adrnr.
        ENDIF.
        IF gt_detail-abrvw = 'COD'.
          ADD gt_detail-kwert TO lv_kwert.
        ENDIF.
      ELSE.
        ADD gt_detail-kwert TO lv_kwert.
      ENDIF.

      MODIFY gt_detail TRANSPORTING kwert kwertt waers
                                    brgew brgewt gewei
                                    volum volumt voleh
                                    lfimg lfimgt vrkme
                                    abrvw bezei kunnr name1.
      CLEAR gt_detail.
    ENDLOOP.

    WRITE lv_kwert TO wa_header-ttlkwert CURRENCY 'IDR'.

    IF nast-kschl = 'Y005'.
      SELECT venum brgew btvol
        FROM vekp
        INTO CORRESPONDING FIELDS OF TABLE lt_vekp
        WHERE vpobj     = '04'
          AND vpobjkey  = pa_tknum.

      IF sy-subrc = 0.
        CLEAR : lv_brgew, lv_volum.
        LOOP AT lt_vekp INTO ls_vekp.
          ADD ls_vekp-brgew TO lv_brgew.
          ADD ls_vekp-btvol TO lv_volum.
        ENDLOOP.
      ENDIF.
    ENDIF.

    PERFORM f_round USING lv_brgew
                    CHANGING wa_header-ttlbrgew.
    PERFORM f_round USING lv_volum
                    CHANGING wa_header-ttlvolum.
    PERFORM f_round USING lv_lfimg
                    CHANGING wa_header-ttllfimg.

    LOOP AT gt_kna1 WHERE vkorg = wa_header-vkorg.
      ADD 1 TO wa_header-ttldp.
    ENDLOOP.

    MODIFY gt_header FROM wa_header.
    CLEAR wa_header.
  ENDLOOP.
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

  DATA : lt_detail  LIKE gt_detail OCCURS 0 WITH HEADER LINE.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    SELECT vbss~sammg INTO TABLE @DATA(lt_sammg)
      FROM vttp INNER JOIN vbss ON vttp~vbeln = vbss~vbeln
                INNER JOIN vbsk ON vbsk~sammg = vbss~sammg
      WHERE vttp~tknum = @pa_tknum
        AND vbsk~smart = 'M'.

    DELETE ADJACENT DUPLICATES FROM lt_sammg COMPARING sammg.
    IF lt_sammg[] IS NOT INITIAL.
      DATA(lv_grouplist) = concat_lines_of( table = lt_sammg
                                            sep   = ', ' ).
    ENDIF.

    SORT gt_detail BY vkorg abrvw.

    LOOP AT gt_header INTO wa_header.
      CLEAR : lt_detail[], lt_detail.
      d_output_opt-tdimmed  = nast-dimme.
      d_output_opt-tddelete = nast-delet.
      d_output_opt-tdcopies = nast-anzal.

      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      LOOP AT gt_detail WHERE vkorg = wa_header-vkorg.
        lt_detail = gt_detail.
        APPEND lt_detail.
        CLEAR lt_detail.
      ENDLOOP.

      IF lv_grouplist IS NOT INITIAL.
        wa_header-grouplist = lv_grouplist.
      ENDIF.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          wa_header          = wa_header
        TABLES
          gt_detail          = lt_detail.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
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
          return[], return, gt_header[], gt_header.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ITEM
*&---------------------------------------------------------------------*
FORM f_calc_item  USING    fu_vbeln fu_waers fu_gewei fu_voleh
                  CHANGING fc_kwert fc_kwertt fc_waers
                           fc_brgew fc_brgewt fc_gewei
                           fc_volum fc_volumt fc_voleh
                           fc_lfimg fc_lfimgt fc_vrkme
                           fc_abrvw fc_bezei.

  DATA : lt_item LIKE bapidlvitem OCCURS 0 WITH HEADER LINE.
  DATA : ls_et_delivery_header LIKE et_delivery_header.

  DATA : lv_netwr TYPE netwr_ak,
         lv_waerk TYPE waerk,
         lv_brgew TYPE brgew_15,
         lv_volum TYPE volum_15,
         lv_kzwi5 TYPE kzwi5,
         lv_lfimg TYPE lfimg.

  DATA : lv_ihrez TYPE ekko-ihrez,
         lv_waers TYPE ekko-waers.
  READ TABLE et_delivery_item WITH KEY vbeln = fu_vbeln
                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF nast-kschl = 'ZTRD'.
      SELECT SINGLE ihrez waers
          FROM ekko
          INTO (lv_ihrez, lv_waers)
          WHERE ebeln EQ et_delivery_item-vgbel.
      IF fc_abrvw = 'COD' OR fc_abrvw = 'TOD'.
        fc_kwert = lv_ihrez / 100.
      ELSE.
        fc_kwert = 0.
      ENDIF.
      WRITE fc_kwert TO fc_kwertt CURRENCY fu_waers.
    ELSE.
      SELECT SINGLE netwr waerk abrvw
        FROM vbak
        INTO (lv_netwr, lv_waerk, fc_abrvw)
        WHERE vbeln EQ et_delivery_item-vgbel.

      IF nast-kschl = 'YO2O'.
        IF fc_abrvw = 'CBD'.
          fc_kwert = 0.
        ELSE.
          SELECT SUM( kzwi5 )
            INTO lv_kzwi5
            FROM vbap WHERE vbeln EQ et_delivery_item-vgbel.
        ENDIF.
        fc_kwert = lv_kzwi5.
        WRITE fc_kwert TO fc_kwertt CURRENCY fu_waers.
      ELSE.
        CASE fc_abrvw.
          WHEN 'CBD'.
            fc_kwert = 0.
          WHEN 'COD'.
            fc_kwert  = lv_netwr * 11 / 10.
          WHEN OTHERS.
            fc_kwert  = lv_netwr * 11 / 10.
        ENDCASE.
        WRITE fc_kwert TO fc_kwertt CURRENCY fu_waers.
      ENDIF.
    ENDIF.
  ENDIF.

  SORT et_delivery_item BY vbeln posnr.
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
