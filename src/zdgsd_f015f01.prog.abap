*----------------------------------------------------------------------*
*   INCLUDE ZDGSD_F015F01                                            *
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
  SELECT SINGLE *
    FROM nast
    WHERE kappl  EQ 'V7'     AND
          objky  EQ pa_tknum AND
          kschl  EQ 'ZT01'   AND
          vstat  EQ '1'.
  IF sy-subrc EQ 0.
    t_header-reprint  = 'X'.
  ENDIF.
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
  DATA: ld_duedt  TYPE sy-datum,
        ld_tplst  TYPE vttk-tplst,
        ld_bukrs  TYPE t001-bukrs,
        ld_route  TYPE vttk-route,
        ld_gesztd(10) TYPE c,
        i_string(30),
        e_dec     TYPE esecompavg.

  DATA: BEGIN OF lt_bsik OCCURS 0,
          tknum  LIKE vttk-tknum,
          zuonr  LIKE bsik-zuonr.
  DATA: END OF lt_bsik.

  DATA: lt_vttk  LIKE vttk OCCURS 0 WITH HEADER LINE,
        gt_vttk  LIKE vttk OCCURS 0,
        wa_vttk  LIKE vttk.

  t_header-tknum  = pa_tknum.

  SELECT *
    FROM vttk
    INTO TABLE gt_vttk
    WHERE tknum = pa_tknum.

  READ TABLE gt_vttk INTO wa_vttk INDEX 1.
  IF sy-subrc EQ 0.
    ld_tplst        = wa_vttk-tplst.
    t_header-lifnr  = wa_vttk-tdlnr.
    ld_route        = wa_vttk-route.
    CALL FUNCTION 'CONVERSION_EXIT_TSTRG_OUTPUT'
      EXPORTING
        input  = wa_vttk-gesztd
      IMPORTING
        output = ld_gesztd.
    IF sy-subrc EQ 0.
      i_string  = ld_gesztd.
      CALL FUNCTION 'C14W_CHAR_NUMBER_CONVERSION'
        EXPORTING
          i_string                   = i_string
        IMPORTING
          e_dec                      = e_dec
        EXCEPTIONS
          wrong_characters           = 1
          first_character_wrong      = 2
          arithmetic_sign            = 3
          multiple_decimal_separator = 4
          thousandsep_in_decimal     = 5
          thousand_separator         = 6
          number_too_big             = 7
          OTHERS                     = 8.
      IF sy-subrc EQ 0.
        ld_duedt        = wa_vttk-dpreg + ( e_dec * 2 ).
      ENDIF.
    ENDIF.
  ENDIF.

  IF wa_vttk-dpreg IS NOT INITIAL.
    PERFORM f_date_format USING ld_duedt
                          CHANGING t_header-duedt.
  ENDIF.

  PERFORM f_date_format USING sy-datum
                        CHANGING t_header-datum.

  IF wa_vttk-add02 IS NOT INITIAL.
    SELECT SINGLE bezei
      FROM vtadd02t
      INTO t_header-vttk_add02_t
      WHERE spras     EQ sy-langu AND
            add_info  EQ wa_vttk-add02.
  ENDIF.

  SELECT SINGLE bezei
    FROM ttdst
    INTO t_header-bezei
    WHERE tplst EQ ld_tplst.

  SELECT SINGLE a~bukrs butxt
    FROM ttds AS a JOIN t001 AS b ON a~bukrs EQ b~bukrs
    INTO (ld_bukrs, t_header-butxt)
    WHERE tplst EQ ld_tplst.

  SELECT SINGLE name1
    FROM lfa1
    INTO t_header-name1
    WHERE lifnr EQ t_header-lifnr.

  SELECT SINGLE bezei
    FROM tvrot
    INTO t_header-routb
    WHERE spras EQ sy-langu AND
          route EQ ld_route.

  PERFORM f_pricing_simulation TABLES gt_vttk
                               CHANGING t_header-shpcv.

  SELECT bukrs lifnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    budat waers wrbtr
    FROM bsik
    INTO CORRESPONDING FIELDS OF TABLE t_bsik
    WHERE bukrs EQ ld_bukrs AND
          lifnr EQ t_header-lifnr AND
          umskz EQ 'C'
*{   REPLACE        P01K910636                                        1
*\    %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240227 RZL
  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
"End SOH: Shell SCI Adjustment 20240227 RZL
*}   REPLACE

  LOOP AT t_bsik.
    lt_bsik-tknum  = t_bsik-zuonr.
    lt_bsik-zuonr  = t_bsik-zuonr.
    APPEND lt_bsik.
  ENDLOOP.

  SORT lt_bsik BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_bsik COMPARING tknum.
  IF lt_bsik[] IS NOT INITIAL.
    SELECT tknum route daten
      FROM vttk
      INTO CORRESPONDING FIELDS OF TABLE t_vttk
      FOR ALL ENTRIES IN lt_bsik
      WHERE tknum  EQ lt_bsik-tknum.

    lt_vttk[] = t_vttk[].
    SORT lt_vttk BY route.
    DELETE ADJACENT DUPLICATES FROM lt_vttk COMPARING route.
    IF lt_vttk[] IS NOT INITIAL.
      SELECT route bezei
        FROM tvrot
        INTO TABLE t_tvrot
        FOR ALL ENTRIES IN lt_vttk
        WHERE spras EQ sy-langu AND
              route EQ lt_vttk-route.
    ENDIF.
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
  DATA: ld_waers  LIKE bsik-waers,
        ld_wrbtr  LIKE bsik-wrbtr.

  LOOP AT t_bsik.
    t_detail-zuonr  = t_bsik-zuonr.
    READ TABLE t_vttk WITH KEY tknum = t_bsik-zuonr.
    IF sy-subrc EQ 0.
      PERFORM f_date_format USING t_vttk-daten
                            CHANGING t_detail-daten.
      READ TABLE t_tvrot WITH KEY route = t_vttk-route.
      IF sy-subrc EQ 0.
        t_detail-routb  = t_tvrot-bezei.
      ENDIF.
    ENDIF.
    PERFORM f_date_format USING t_bsik-budat
                          CHANGING t_detail-budat.
    WRITE t_bsik-wrbtr TO t_detail-wrbtr CURRENCY t_bsik-waers.
    ld_waers  = t_bsik-waers.
    ADD t_bsik-wrbtr TO ld_wrbtr.
    APPEND t_detail.
    CLEAR: t_detail.
  ENDLOOP.
  WRITE ld_wrbtr TO t_header-total CURRENCY ld_waers.
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
  DATA: headerdata        LIKE bapishipmentheader,
        headerdataaction  LIKE bapishipmentheaderaction,
        return            LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

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
        t_header           = t_header
      TABLES
        t_detail           = t_detail
        t_simulate         = t_simulate.

    IF sy-ucomm EQ 'STAR'.
      headerdata-shipment_num   = t_header-tknum.
      PERFORM f_value_conversion USING t_header-shpcv
                                 CHANGING headerdata-text_4.
      headerdataaction-text_4   = 'C'.

      CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
        EXPORTING
          headerdata       = headerdata
          headerdataaction = headerdataaction
        TABLES
          return           = return.
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
  REFRESH: t_simulate, t_detail.
  CLEAR: t_simulate, t_detail, t_header.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_DATE_FORMAT
*&---------------------------------------------------------------------*
FORM f_date_format  USING    fu_datum
                    CHANGING fc_datum.
  DATA: ld_month(10).

  ld_month  = fu_datum+4(2).

  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = ld_month
    IMPORTING
      name  = ld_month.

  CONCATENATE fu_datum+6(2) ld_month fu_datum(4) INTO fc_datum
    SEPARATED BY space.
ENDFORM.                    " F_DATE_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_PRICING_SIMULATION
*&---------------------------------------------------------------------*
FORM f_pricing_simulation  TABLES   gt_vttk STRUCTURE vttk
                           CHANGING fc_shpcv.

  FIELD-SYMBOLS:
    <l_freight_cost> TYPE v54a0_scdd,
    <l_item>         TYPE v54a0_scd_item.
  DATA:
    l_result        LIKE vfkp-netwr,
    l_currency      LIKE vfkp-waers.

  DATA: l_shipment  TYPE vt04_shipment.

  DATA: wa_vttkvb LIKE vttkvb,
        wa_tvtk   LIKE tvtk,
        wa_tvtkt  LIKE tvtkt,
        wa_ttds   LIKE ttds,
        wa_ttdst  LIKE ttdst,
        wa_vbpla  LIKE vbpla.

  DATA: gt_vttp  LIKE vttpvb OCCURS 0,
        gt_trlk  LIKE vtrlk OCCURS 0,
        gt_trlp  LIKE vtrlp OCCURS 0,
        gt_vtts  LIKE vttsvb OCCURS 0,
        gt_vtsp  LIKE vtspvb OCCURS 0,
        gt_vbpa  LIKE vbpavb OCCURS 0,
        gt_vbadr LIKE sadrvb OCCURS 0,
        gt_vtfa  LIKE vtfavb OCCURS 0,
        gt_vbplk LIKE vbplk OCCURS 0,
        gt_vbplp LIKE vbplp OCCURS 0,
        gt_vbpls LIKE vbpls OCCURS 0,
        gt_yvtfa LIKE vtfavb OCCURS 0.

  DATA: gw_result TYPE netwr_all,
        gw_waers  TYPE waers_all,
        gw_error  TYPE c.

  DATA: gt_log            TYPE sprot_u OCCURS 0.
  DATA: g_scd_wa          TYPE v54a0_scdd.

*-----------
  DATA:
    l_vttp                LIKE vttp OCCURS 0 WITH HEADER LINE,
    l_xvttk               LIKE vttkvb,
    l_shipment_wa         TYPE v54a0_refobj,
    l_shipment_data       TYPE vt04_shipment,
    l_simulation          TYPE v54a1_simulation_run,
    l_delivery_data       TYPE v54a1_delivery_tables,
    l_t180_wa             TYPE t180.

  DATA: ld_amount   TYPE vfkp-netwr.

  CALL FUNCTION 'RV_SHIPMENT_VIEW'
    EXPORTING
      shipment_number            = pa_tknum
      option_tvtk                = 'X'
      option_ttds                = 'X'
      language                   = sy-langu
      option_items               = 'X'
      option_minimized_item_data = 'X'
      option_sales_orders        = 'X'
      option_export_data         = 'X'
      option_stawn_read          = 'X'
      option_segments            = 'X'
      option_partners            = 'X'
      option_messages            = 'X'
      option_packages            = 'X'
      option_package_dialog      = 'X'
      option_flow                = 'X'
      option_delivery_lock       = 'X'
      option_authority_check     = 'X'
      activity                   = 'A'
      option_no_refresh          = 'X'
      i_filter_type              = 'F'
      option_hu_via_vbfa         = 'X'
    IMPORTING
      f_vttkvb                   = wa_vttkvb
      f_tvtk                     = wa_tvtk
      f_tvtkt                    = wa_tvtkt
      f_ttds                     = wa_ttds
      f_ttdst                    = wa_ttdst
      f_vbpla                    = wa_vbpla
    TABLES
      f_vttp                     = gt_vttp
      f_trlk                     = gt_trlk
      f_trlp                     = gt_trlp
      f_vtts                     = gt_vtts
      f_vtsp                     = gt_vtsp
      f_vbpa                     = gt_vbpa
      f_vbadr                    = gt_vbadr
      f_vtfa                     = gt_vtfa
      f_vbplk                    = gt_vbplk
      f_vbplp                    = gt_vbplp
      f_vbpls                    = gt_vbpls
      f_yvtfa                    = gt_yvtfa
    EXCEPTIONS
      not_found                  = 1
      no_authority               = 2
      delivery_missing           = 3
      delivery_lock              = 4
      OTHERS                     = 5.

  IF sy-subrc EQ 0.
    l_shipment-tvtk_wa = wa_tvtk.
    l_shipment-ttds_wa = wa_ttds.
    l_shipment-xsadr[] = gt_vbadr[].

    LOOP AT gt_vttk.
      gt_vttk-sttrg = '6'.
      MODIFY gt_vttk TRANSPORTING sttrg.
    ENDLOOP.

    l_shipment-xvttk[] = gt_vttk[].
    l_shipment-xvttp[] = gt_vttp[].
    l_shipment-xvtts[] = gt_vtts[].
    l_shipment-xvtsp[] = gt_vtsp[].
    l_shipment-xvbpa[] = gt_vbpa[].
    l_shipment-xtrlk[] = gt_trlk[].
    l_shipment-xtrlp[] = gt_trlp[].

* get simulation detail
    l_shipment_data = l_shipment.
    l_vttp[] = l_shipment_data-xvttp[].

    PERFORM shipping_units_shipment_get
               TABLES
                  l_vttp
                  l_shipment_data-xtrlk
                  l_shipment_data-xvekp
                  l_shipment_data-xvepo
                USING
                  l_xvttk-tknum
                  3.

    l_delivery_data-vtrlk[] = l_shipment_data-xtrlk[].
    l_delivery_data-vtrlp[] = l_shipment_data-xtrlp[].

    SORT l_delivery_data-vtrlk BY vbeln.
    SORT l_delivery_data-vtrlp BY vbeln posnr.

    PERFORM shipment_result_convert
              USING
                l_shipment_data
                l_delivery_data
              CHANGING
                l_shipment_wa.

    l_shipment_wa-vbplk   = gt_vbplk[].

    SORT l_shipment_wa-vtrlk BY vbeln.
    SORT l_shipment_wa-vtrlp BY vbeln posnr.
    SORT l_shipment_wa-vbplk.                               "< N408864
    SORT l_shipment_wa-vbplp.                               "< N408864
    IF NOT l_shipment_wa IS INITIAL.
      APPEND l_shipment_wa TO l_simulation-shp-shipments.
    ENDIF.

    g_scd_wa-x-vfkk-fkart = 'ZT01'.

    CALL FUNCTION 'SD_SCD_ITEMS_CREATE'
      EXPORTING
        i_refobj                     = l_shipment_wa
        i_t180                       = l_t180_wa
      CHANGING
        c_scd                        = g_scd_wa
      EXCEPTIONS
        determination_not_maintained = 1
        errors_occurred              = 2.

    LOOP AT g_scd_wa-x-item ASSIGNING <l_item>.
      l_result = l_result + <l_item>-vfkp-netwr.
      IF NOT <l_item>-vfkp-waers IS INITIAL.
        l_currency = <l_item>-vfkp-waers.
      ENDIF.
      SELECT SINGLE bezei
        FROM tvftt
        INTO t_simulate-bezei
        WHERE spras EQ sy-langu AND
              fkpty EQ <l_item>-vfkp-fkpty.
      WRITE <l_item>-vfkp-netwr TO t_simulate-amount CURRENCY l_currency.
      APPEND t_simulate.
    ENDLOOP.

*    CALL FUNCTION 'SD_SCD_SIMULATE_FREIGHT_COSTS'
*      EXPORTING
*        i_shipments     = l_simulation-shp-shipments
*      IMPORTING
*        e_freight_costs = l_simulation-scd-freight_costs.
*
** get freight cost provision.
*    LOOP AT l_simulation-scd-freight_costs ASSIGNING <l_freight_cost>.
**   for all the items of each freight cost document
*      LOOP AT <l_freight_cost>-x-item ASSIGNING <l_item>.
*        l_result = l_result + <l_item>-vfkp-netwr.
*        IF NOT <l_item>-vfkp-waers IS INITIAL.
*          l_currency = <l_item>-vfkp-waers.
*        ENDIF.
*        SELECT SINGLE bezei
*          FROM tvftt
*          INTO t_simulate-bezei
*          WHERE spras EQ sy-langu AND
*                fkpty EQ <l_item>-vfkp-fkpty.
*        WRITE <l_item>-vfkp-netwr TO t_simulate-amount CURRENCY l_currency.
*        APPEND t_simulate.
*      ENDLOOP.
*    ENDLOOP.
    WRITE l_result TO fc_shpcv CURRENCY l_currency.
  ENDIF.
ENDFORM.                    " F_PRICING_SIMULATION

*&---------------------------------------------------------------------*
*&      Form  shipping_units_shipment_get
*&---------------------------------------------------------------------*
FORM shipping_units_shipment_get
       TABLES
         i_vttp STRUCTURE vttp
         i_vtrlk STRUCTURE vtrlk
         c_vekp STRUCTURE vekpvb
         c_vepo STRUCTURE vepovb
       USING
         value(i_tknum) LIKE vttk-tknum
         i_scd_sim      TYPE i.

  DATA:
    l_vekp         TYPE vekpvb OCCURS 0,
    l_vepo         TYPE vepovb OCCURS 0,
    l_no_db_select TYPE xfeld,
    ls_objects     TYPE vsep_s_objkey,
    lt_objects     TYPE vsep_t_objkey.

*   doing the long way via HU_GET_HUS_FROM_VBFA only          "v_934370
*   neccessary, when there is any Handling Unit Management
*   active and any delivery already posted GI
  DATA: lf_unique TYPE xfeld.
  CALL FUNCTION 'HU_TVSHP_SELECT'
    IMPORTING
      ef_exidv_unique = lf_unique.


* Determine if goods issue is posted for at least 1 delivery
  DATA: l_gi_posted.
  DATA: i_objects LIKE lt_objects WITH HEADER LINE.
  l_gi_posted = 'false'.

  LOOP AT i_vtrlk.
    ls_objects-objkey = i_vtrlk-vbeln.
*     all outbound HUs of delivery VBELN
    ls_objects-object = '01'.
    APPEND ls_objects TO lt_objects.

    IF i_vtrlk-wbstk_tr = wbstk-b  OR
       i_vtrlk-wbstk_tr = wbstk-c.
      l_gi_posted = 'true'.
      EXIT.
    ENDIF.
  ENDLOOP.                                                  "^_934370

* read inbound/outbound delivery based shipping units for a shipment
* 595354: The outbound HUs (OBJECT='01') as well as the inbound HUs
* (OBJECT='03') were read for every delivery, independend on delivery
* type (outbound types 'JT' or inbound types '7g'). See freight cost
* calculation via VI01 (SD_SHIPMENT_PACKING_VIEW):
  IF i_scd_sim = c_scd_sim-ship OR
     i_scd_sim = c_scd_sim-ship_d.
*   read from database
    l_no_db_select = ' '.

    i_objects[] = lt_objects[].                             "v_934370
    LOOP AT i_objects INTO ls_objects.
*      ls_objects-objkey = i_objects_objkey.                   "^_934370
*     ...all inbound HUs of the delivery
      ls_objects-object = '03'.
      APPEND ls_objects TO lt_objects.
    ENDLOOP.
* read outbound delivery based shipping units for sales Order
  ELSEIF i_scd_sim = c_scd_sim-so.
*   NO read from database
    l_no_db_select = 'X'.
    IF lt_objects[] IS INITIAL.                             "934370
      LOOP AT i_vttp.
        ls_objects-objkey = i_vttp-vbeln.
        ls_objects-object = '01'.
        APPEND ls_objects TO lt_objects.
      ENDLOOP.
    ENDIF.                                                  "934370
  ENDIF.
* and read all shipment based shipping units
  ls_objects-objkey = i_tknum.
  ls_objects-object = '04'.
  APPEND ls_objects TO lt_objects.

  IF l_gi_posted EQ 'false' OR lf_unique = space.           "934370

    IF i_scd_sim = c_scd_sim-ship OR
     i_scd_sim = c_scd_sim-ship_d.
      LOOP AT lt_objects INTO ls_objects.
        REFRESH: l_vekp, l_vepo.
*     595354: IF_NO_LOOP=SPACE inserted, because there is no
*     guarantee, that all HU data are read and that only the
*     wanted data are read.
        CALL FUNCTION 'HU_GET_HUS'
          EXPORTING
            if_no_db_select = l_no_db_select
            if_no_loop      = ' '                           "<<595354
            is_objects      = ls_objects
          IMPORTING
            et_header       = l_vekp[]
            et_items        = l_vepo[]
          EXCEPTIONS
            OTHERS          = 0.
        APPEND LINES OF l_vekp TO c_vekp.
        APPEND LINES OF l_vepo TO c_vepo.
      ENDLOOP.
    ELSEIF i_scd_sim = c_scd_sim-so.
      CALL FUNCTION 'HU_GET_HUS'
        EXPORTING
          if_no_db_select = l_no_db_select
          if_no_loop      = ' '                             "<<595354
          it_objects      = lt_objects
        IMPORTING
          et_header       = l_vekp[]
          et_items        = l_vepo[]
        EXCEPTIONS
          OTHERS          = 0.
      APPEND LINES OF l_vekp TO c_vekp.
      APPEND LINES OF l_vepo TO c_vepo.
    ENDIF.
  ELSE.                                                     "v_934370
* Determine HUs via document flow:
* The handling units are selected via the document flow VBFA
* because in case of the stock transfer scenario
* they can already be tied to the inbound delivery,
* but no longer be tied to the outbound delivery by VEKP-VPOBJKEY.
* This function module also rebuilds this assignment and
* the original item entries VEPO
    CALL FUNCTION 'HU_GET_HUS_FROM_VBFA'
      EXPORTING
        if_refresh = 'X'.
    CALL FUNCTION 'HU_GET_HUS_FROM_VBFA'
      EXPORTING
        if_object        = '04'
        it_objects       = lt_objects
        if_change_export = 'X'
        if_lock_hu       = 'X'
      IMPORTING
        et_header        = l_vekp[]
        et_items         = l_vepo[]
      EXCEPTIONS
        hus_locked       = 0
        no_hu_found      = 0
        hu_changed       = 3
        fatal_error      = 3
        OTHERS           = 99.
    APPEND LINES OF l_vekp TO c_vekp.
    APPEND LINES OF l_vepo TO c_vepo.

  ENDIF.                                                    "^_934370
ENDFORM.                    "SHIPPING_UNITS_SHIPMENT_GET

*&---------------------------------------------------------------------*
*&      Form  shipment_result_convert
*&---------------------------------------------------------------------*
FORM shipment_result_convert
       USING
         i_shipment_tables TYPE vt04_shipment
         i_delivery_tables TYPE v54a1_delivery_tables
       CHANGING
         c_shipment TYPE v54a0_refobj.

  DATA:
    l_xvttk LIKE vttkvb,
    l_xvtts LIKE vttsvb,
    l_vttsf LIKE vttsf,
    l_xvttp LIKE vttpvb,
    l_vtrlk LIKE vtrlk,
    l_vtrlp LIKE vtrlp.

*  initialize shipment
  CLEAR c_shipment.

*  is there really a shipment ?
  IF i_shipment_tables-xvttk[] IS INITIAL.
    EXIT.
  ENDIF.

*  header
  READ TABLE i_shipment_tables-xvttk INTO l_xvttk INDEX 1.
  MOVE-CORRESPONDING l_xvttk TO c_shipment-vttkf.

*  workarea shipment type
  CALL FUNCTION 'READ_TABLE_BUFFERED'
    EXPORTING
      i_table          = 'TVTK'
      i_key1           = 'SHTYP'
      i_value1         = 'ZT01'
      i_buffer_type    = 'X'
    IMPORTING
      e_table_workarea = c_shipment-tvtk
    EXCEPTIONS
      OTHERS           = 0.

*  workarea planning point
  CALL FUNCTION 'READ_TABLE_BUFFERED'
    EXPORTING
      i_table          = 'TTDS'
      i_key1           = 'TPLST'
      i_value1         = '0501'
      i_buffer_type    = 'X'
    IMPORTING
      e_table_workarea = c_shipment-ttds
    EXCEPTIONS
      OTHERS           = 0.

*  stages
  LOOP AT i_shipment_tables-xvtts INTO l_xvtts.
    MOVE-CORRESPONDING l_xvtts TO l_vttsf.
    APPEND l_vttsf TO c_shipment-vttsf.
  ENDLOOP.

*  items
  c_shipment-vttp[] = i_shipment_tables-xvttp[].

*  items per stage
  c_shipment-vtsp[] = i_shipment_tables-xvtsp[].

*  partners
  c_shipment-vbpa[] = i_shipment_tables-xvbpa[].

*  delivery headers and items
  LOOP AT c_shipment-vttp[] INTO l_xvttp.
    READ TABLE i_delivery_tables-vtrlk INTO l_vtrlk
               WITH KEY vbeln = l_xvttp-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      APPEND l_vtrlk TO c_shipment-vtrlk.
      READ TABLE i_delivery_tables-vtrlp INTO l_vtrlp
                 WITH KEY vbeln = l_xvttp-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT i_delivery_tables-vtrlp INTO l_vtrlp FROM sy-tabix.
          IF l_vtrlp-vbeln NE l_xvttp-vbeln. EXIT. ENDIF.
*          v_901388
*      only shipment relevant items must be appended to vtrlp.
*          in the
*      online processing these items are filtered during shipment
*      creation in function 'SD_SHIPMENT_DELIV_ITEM_FILTER'.
*          in this
*      case filter is called with type 'F'.
          IF NOT l_vtrlp-tprel IS INITIAL.
            APPEND l_vtrlp TO c_shipment-vtrlp.
          ENDIF.                                            "^_901388
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  convert shipping unit data
  CALL FUNCTION 'SD_SHIPMENT_PACKING_CONVERT'
    EXPORTING
      i_langu                        = sy-langu
      opt_unpacked_items             = 'X'
      opt_packing_sum                = ' '
      opt_packing_general_data       = ' '
      opt_packing_sum_deliv          = ' '
      opt_packing_general_data_deliv = ' '
    TABLES
      i_vtrlk                        = i_delivery_tables-vtrlk
      i_vtrlp                        = i_delivery_tables-vtrlp
      i_vekp                         = i_shipment_tables-xvekp
      i_vepo                         = i_shipment_tables-xvepo
      c_vbplk                        = c_shipment-vbplk
      c_vbplp                        = c_shipment-vbplp
    EXCEPTIONS
      OTHERS                         = 0.

*  prepare shipment for freight costing
  CALL FUNCTION 'SD_SCD_REFOBJ_PREPARE'
    CHANGING
      c_refobj = c_shipment.
ENDFORM.                    "SHIPMENT_RESULT_CONVERT

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  USING    fu_name
                  CHANGING fc_sign.
  DATA: lines LIKE tline OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = fu_name
      object                  = 'TEXT'
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
  IF sy-subrc EQ 0.
    READ TABLE lines INDEX 1.
    IF sy-subrc EQ 0.
      fc_sign   = lines-tdline.
    ELSE.
      CLEAR fc_sign.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_value_conversion  USING    fu_total
                         CHANGING fc_text_4.
  fc_text_4 = fu_total.
  WHILE sy-subrc EQ 0.
    REPLACE '.' WITH space INTO fc_text_4.
  ENDWHILE.
  CONDENSE fc_text_4 NO-GAPS.
ENDFORM.                    " F_VALUE_CONVERSION
