*----------------------------------------------------------------------*
*   INCLUDE ZM_OOS_PRODUCTF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT bwart xstbw
    FROM t156
    INTO TABLE gt_t156.

  IF so_bedat[] IS NOT INITIAL.
    LOOP AT so_bedat.
      IF so_bedat-sign = 'I'.
        CASE so_bedat-option.
          WHEN 'EQ'.
            CONCATENATE so_bedat-low(6) '01' INTO gv_date1.
            gv_date2 = gv_date1.
          WHEN 'BT'.
            CONCATENATE so_bedat-low(6) '01' INTO gv_date1.
            CONCATENATE so_bedat-high(6) '01' INTO gv_date2.
        ENDCASE.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = gv_date2
          IMPORTING
            last_day_of_month = gv_date2.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lv_maktx TYPE maktx,
        lv_prdha TYPE prodh_d,
        lv_extwg TYPE extwg,
        d_flag   TYPE char1.

  DATA: lt_ekpo LIKE gt_ekpo OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_ekbe OCCURS 0,
          ebeln	TYPE ebeln,
          ebelp	TYPE ebelp,
          zekkn	TYPE dzekkn,
          vgabe	TYPE vgabe,
          gjahr	TYPE mjahr,
          belnr	TYPE mblnr,
          buzei	TYPE mblpo,
          bewtp	TYPE bewtp,
          bwart	TYPE bwart,
          budat	TYPE budat,
          menge	TYPE menge_d,
          xblnr TYPE xblnr1,
        END OF lt_ekbe.

  DATA: BEGIN OF lt_eket OCCURS 0,
          ebeln	TYPE ebeln,
          ebelp	TYPE ebelp,
          etenr	TYPE eeten,
          banfn TYPE banfn,
          bnfpo TYPE bnfpo,
          estkz TYPE estkz,
          menge TYPE bamng,
        END OF lt_eket.

  SELECT * INTO TABLE gt_mat_b2b
    FROM zsmat_b2b WHERE kvgr4 IN ('101','107')
                     AND valid_to GE gv_date1
                     AND valid_fr LE gv_date2
                     AND lvorm EQ space.

  SELECT ebeln bukrs bsart lifnr ekorg bedat aedat
    FROM ekko
    INTO TABLE gt_ekko
    WHERE ekorg EQ pa_ekorg
      AND bukrs EQ pa_bukrs
      AND bsart IN so_bsart
      AND lifnr IN so_lifnr
      AND bedat IN so_bedat.

  IF gt_ekko[] IS INITIAL.
    MESSAGE 'No Purchasing Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.

  ELSE.
    CLEAR: lt_ekpo[], lt_ekbe[], lt_ekpo, lt_ekbe.

    SELECT *
      FROM ekpv
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpv
      FOR ALL ENTRIES IN gt_ekko
      WHERE ebeln = gt_ekko-ebeln.

    SELECT lifnr name1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FROM lfa1 FOR ALL ENTRIES IN gt_ekko
      WHERE lifnr = gt_ekko-lifnr.

    SELECT ebeln ebelp matnr werks menge meins lgort reslo bednr banfn kunnr
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
      FOR ALL ENTRIES IN gt_ekko
      WHERE ebeln = gt_ekko-ebeln
        AND matnr IN so_matnr
        AND werks IN so_werks
        AND loekz = space.

    IF gt_ekpo[] IS INITIAL.
      MESSAGE 'No Purchasing Data' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.

    lt_ekpo[] = gt_ekpo[].
    SORT lt_ekpo BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING kunnr.
    IF lt_ekpo[] IS NOT INITIAL.
      SELECT kunnr name1
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FOR ALL ENTRIES IN lt_ekpo
        WHERE kunnr = lt_ekpo-kunnr.
    ENDIF.

    lt_ekpo[] = gt_ekpo[].
    SORT lt_ekpo BY werks lgort.
    DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING werks lgort.

    IF lt_ekpo[] IS NOT INITIAL.
      SELECT werks lgort vstel
        FROM t001l
        INTO TABLE gt_t001l
        FOR ALL ENTRIES IN lt_ekpo
        WHERE werks = lt_ekpo-werks
          AND lgort = lt_ekpo-lgort.
    ENDIF.

    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp
      bwart budat menge xblnr
      FROM ekbe
      INTO TABLE lt_ekbe
      FOR ALL ENTRIES IN gt_ekpo
      WHERE ebeln = gt_ekpo-ebeln
        AND ebelp = gt_ekpo-ebelp.

    IF sy-uname = 'MMFM'.
      d_flag = 'X'.
    ENDIF.
    BREAK mmfm.

    LOOP AT lt_ekbe.
      CHECK lt_ekbe-gjahr IS NOT INITIAL
         OR lt_ekbe-menge IS NOT INITIAL.

      IF lt_ekbe-bwart  = '641'.
        gt_vercon-ebeln   = lt_ekbe-ebeln.
        gt_vercon-versidn = 1.
        COLLECT gt_vercon.
        CLEAR gt_vercon.
      ENDIF.

      gt_ekbe-ebeln   = lt_ekbe-ebeln.
      gt_ekbe-ebelp   = lt_ekbe-ebelp.
      gt_ekbe-belnr   = lt_ekbe-belnr.
      IF d_flag = 'X'.
        gt_ekbe-buzei   = lt_ekbe-buzei.
      ENDIF.
      gt_ekbe-bewtp   = lt_ekbe-bewtp.
      gt_ekbe-bwart   = lt_ekbe-bwart.
      gt_ekbe-budat   = lt_ekbe-budat.
      READ TABLE gt_t156 WITH KEY bwart = lt_ekbe-bwart.
      IF sy-subrc EQ 0.
        IF gt_t156-xstbw EQ 'X'.
          gt_ekbe-menge   = lt_ekbe-menge * -1.
        ELSE.
          gt_ekbe-menge   = lt_ekbe-menge.
        ENDIF.
      ELSE.
        gt_ekbe-menge   = lt_ekbe-menge.
      ENDIF.
      gt_ekbe-xblnr = lt_ekbe-xblnr.
      COLLECT gt_ekbe.
      CLEAR gt_ekbe.
    ENDLOOP.

*    SELECT eket~ebeln eket~ebelp etenr eket~banfn eket~bnfpo eket~estkz eban~menge
*      FROM eket
*      JOIN eban
*        on eket~banfn = eban~banfn and
*           eket~bnfpo = eban~bnfpo
*      INTO TABLE lt_eket
*      FOR ALL ENTRIES IN gt_ekpo
*      WHERE eket~ebeln = gt_ekpo-ebeln
*        AND eket~ebelp = gt_ekpo-ebelp.

    PERFORM f_material_description USING 'SELECT' ''
                                   CHANGING lv_maktx lv_prdha lv_extwg.

  ENDIF.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN rb_det.
      PERFORM f_alv TABLES gt_vdata.
    WHEN rb_sum.
      CASE 'X'.
        WHEN rb_brc.
          PERFORM f_alv TABLES gt_sum_brc.
        WHEN rb_brcp.
          PERFORM f_alv TABLES gt_sum_brcp.
        WHEN rb_prc.
          PERFORM f_alv TABLES gt_sum_prc.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  lv_title   = sy-title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
*  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM comment_build USING t_list_top_of_page[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*     i_grid_title             = lv_title
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN rb_det.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_fieldcatg USING ft_report:
            'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
            'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '',
            'PRDHA' 'MARA' 'PRDHA' '' '' '' '' '' '' '' '' '' '' '' '',
            'EXTWG' 'MARA' 'EXTWG' '' '' '' '' '' '' '' '' '' '' '' '',
            'FLG1' '' '' '' '12' 'Item Listing' '' '' '' '' '' '' '' '' '',
            'LPRIO' 'MEPO1331' 'LPRIO' '' '' 'STO Priority' '' '' '' '' '' '' '' '' '',
            'BEZEI' 'TPRIT' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '' '',
            'LPRIO1' 'MEPO1331' 'LPRIO' '' '' 'DN Priority' '' '' '' '' '' '' '' '' '',
            'BEZEI1' 'TPRIT' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '' '',
            'EBELN' 'EKKO' 'EBELN' '' '' 'No. STO' '' '' '' '' '' '' '' '' '',
*            Added Order type
            'BSART' 'EKKO' 'BSART' '' '' 'Order Type' '' '' '' '' '' '' '' '' '',
            'KUNNR' 'KNA1' 'KUNNR' '' '' 'Cust.Code' '' '' '' '' '' '' '' '' '',
            'NAME1' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '',
            'BANFN' 'EKPO' 'BANFN' '' '' 'No. STR' '' '' '' '' '' '' '' '' '',
            'AEDAT' 'EKKO' 'AEDAT' '' '16' 'PO Creation Date' '' '' '' '' '' '' '' '' '',
            'RESLO' 'EKPO' 'RESLO' '' '' '' '' '' '' '' '' '' '' '' '',
            'BEDAT' 'EKKO' 'BEDAT' '' '16' 'Tanggal Alokasi' '' '' '' '' '' '' '' '' '',
            'WEEK_ALO' '' '' '' '12' 'Week Alokasi' '' '' '' '' '' '' '' '' '',
            'MNTH_ALO' '' '' '' '13' 'Month Alokasi' '' '' '' '' '' '' '' '' '',
            'MENGE' 'EKPO' 'MENGE' '' '' 'Jumlah Alokasi' 'X' '' '' '' '' '' 'MEINS' '' '',
            'MEINS' 'EKPO' 'MEINS' '' '6' 'UoM' '' '' '' '' '' '' '' '' '',
            'POCAR' 'EKPO' 'MENGE' '' '' 'Alokasi(CAR)' 'X' '' '' '' '' '' 'MECAR' '' '',
            'MECAR' 'EKPO' 'MEINS' '' '6' 'UoM(CAR)' '' '' '' '' '' '' '' '' '',
            'WERKS' 'EKPO' 'WERKS' '' '6' '' '' '' '' '' '' '' '' '' '',
            'LGORT' 'EKPO' 'LGORT' '' '6' '' '' '' '' '' '' '' '' '' '',
            'VSTEL' 'TVBUR' 'VKBUR' '' '6' '' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'BELNR_DN' 'EKBE' 'BELNR' '' '' 'No. DN' '' '' '' '' '' '' '' '' '',
            'BRGEW' 'LIPS' 'BRGEW' '' '' 'Total Weight' '' '' '' '' '' '' 'GEWEI' '' '',
            'GEWEI' 'LIPS' 'GEWEI' '' '' 'WuN' '' '' '' '' '' '' '' '' '',
            'VOLUM' 'LIPS' 'VOLUM' '' '' 'Volum' '' '' '' '' '' '' 'VOLEH' '' '',
            'VOLEH' 'LIPS' 'VOLEH' '' '' 'VuN' '' '' '' '' '' '' '' '' '',
            'MENGE_DN' 'EKBE' 'MENGE' '' '' 'Jumlah DN' 'X' '' '' '' '' '' 'MEINS' '' '',
            'BUDAT_DN' 'EKBE' 'BUDAT' '' '13' 'Tanggal DN' '' '' '' '' '' '' '' '' '',
            'WEEK_DN' '' '' '' '7' 'Week DN' '' '' '' '' '' '' '' '' '',
            'MNTH_DN' '' '' '' '10' 'Month DN' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'BELNR_GI' 'EKBE' 'BELNR' '' '' 'No. GI' '' '' '' '' '' '' '' '' '',
            'MENGE_GI' 'EKBE' 'MENGE' '' '' 'Jumlah GI' 'X' '' '' '' '' '' 'MEINS' '' '',
            'BUDAT_GI' 'EKBE' 'BUDAT' '' '13' 'Tanggal GI' '' '' '' '' '' '' '' '' '',
            'WEEK_GI' '' '' '' '7' 'Week GI' '' '' '' '' '' '' '' '' '',
            'MNTH_GI' '' '' '' '10' 'Month GI' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'BELNR_GR' 'EKBE' 'BELNR' '' '' 'No. GR' '' '' '' '' '' '' '' '' '',
            'MENGE_GR' 'EKBE' 'MENGE' '' '' 'Jumlah GR PO' 'X' '' '' '' '' '' 'MEINS' '' '',
            'BUDAT_GR' 'EKBE' 'BUDAT' '' '13' 'Tanggal GR PO' '' '' '' '' '' '' '' '' '',
            'WEEK_GR' '' '' '' '10' 'Week GR PO' '' '' '' '' '' '' '' '' '',
            'MNTH_GR' '' '' '' '11' 'Month GR PO' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'TKNUM' 'VTTK' 'TKNUM' '' '' 'No. Ship' '' '' '' '' '' '' '' '' '',
            'DATBG' 'VTTK' 'DATBG' '' '13' 'Tanggal Ship' '' '' '' '' '' '' '' '' '',
            'EXTI1' 'VTTK' 'EXTI1' '' '' '' '' '' '' '' '' '' '' '' '',
            'EXTI2' 'VTTK' 'EXTI2' '' '' '' '' '' '' '' '' '' '' '' '',
            'TDLNR' 'VTTK' 'TDLNR' '' '' '' '' '' '' '' '' '' '' '' '',
            'SIGNI' 'VTTK' 'SIGNI' '' '' '' '' '' '' '' '' '' '' '' '',
            'GESZTD' 'VTTK' 'GESZTD' '' '' '' '' '' '' '' '' '' '' '' '',
            'ETDAT' 'VTTK' 'ERDAT' '' '10' 'ETA Date' '' '' '' '' '' '' '' '' '',
            'PROFNM' 'LFA1' 'NAME1' '' '' 'Service Provider' '' '' '' '' '' '' '' '' '',
            'WEEK_SHIP' '' '' '' '10' 'Week Ship' '' '' '' '' '' '' '' '' '',
            'MNTH_SHIP' '' '' '' '11' 'Month Ship' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'GR_GI' '' '' '' '' 'GR - GI' '' '' '' '' '' '' '' '' '',
            'GI_DN' '' '' '' '' 'GI - DN' '' '' '' '' '' '' '' '' '',
            'DN_PO_STO' '' '' '' '' 'DN - STO' '' '' '' '' '' '' '' '' '',
            'GR_PO_STO' '' '' '' '' 'GR - STO' '' '' '' '' '' '' '' '' '',
            'DN_SHIP' '' '' '' '' 'DN - Ship' '' '' '' '' '' '' '' '' '',
            'GI_SHIP' '' '' '' '' 'GI - Ship' '' '' '' '' '' '' '' '' '',
            'SHIP_GR' '' '' '' '' 'Ship - GR' '' '' '' '' '' '' '' '' '',
            'VERSIDN' '' '' '' '' 'Versi DN' '' '' '' '' '' '' '' '' '',
            'NSP' 'EKPO' 'NETWR' '' '6' 'NSP' '' '' '' 'IDR' '' '' '' '' '',
            'POVAL' 'EKPO' 'NETWR' '' '6' 'PO Value' '' '' '' 'IDR' '' '' '' '' '',
            'GIVAL' 'EKPO' 'NETWR' '' '6' 'GI Value' '' '' '' 'IDR' '' '' '' '' '',
            'GRVAL' 'EKPO' 'NETWR' '' '6' 'GR Value' '' '' '' 'IDR' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'TDLINE' '' '' '' '' 'Header Text' '' '' '' '' '' '' '' '' ''.

        WHEN radio2.
          PERFORM f_fieldcatg USING ft_report:
            'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
            'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '',
            'PRDHA' 'MARA' 'PRDHA' '' '' '' '' '' '' '' '' '' '' '' '',
            'FLG1' '' '' '' '12' 'Item Listing' '' '' '' '' '' '' '' '' '',
            'EBELN' 'EKKO' 'EBELN' '' '' '' '' '' '' '' '' '' '' '' '',
            'KUNNR' 'KNA1' 'KUNNR' '' '' 'Cust.Code' '' '' '' '' '' '' '' '' '',
            'NAME1' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '',
            'BEDNR' 'EKPO' 'BEDNR' '' '' '' '' '' '' '' '' '' '' '' '',
            'AEDAT' 'EKKO' 'AEDAT' '' '' '' '' '' '' '' '' '' '' '' '',
            'LIFNR' 'EKKO' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '',
            'VNDNM' 'LFA1' 'NAME1' '' '' 'Vendor Name' '' '' '' '' '' '' '' '' '',
            'BEDAT' 'EKKO' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '' '',
            'MENGE' 'EKPO' 'MENGE' '' '' 'Qty PO' 'X' '' '' '' '' '' 'MEINS' '' '',
            'MEINS' 'EKPO' 'MEINS' '' '6' 'UoM' '' '' '' '' '' '' '' '' '',
            'POCAR' 'EKPO' 'MENGE' '' '' 'Qty PO(CAR)' 'X' '' '' '' '' '' 'MECAR' '' '',
            'MECAR' 'EKPO' 'MEINS' '' '6' 'UoM(CAR)' '' '' '' '' '' '' '' '' '',
            'WERKS' 'EKPO' 'WERKS' '' '6' '' '' '' '' '' '' '' '' '' '',
            'LGORT' 'EKPO' 'LGORT' '' '6' '' '' '' '' '' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
            'BELNR_GR' 'EKBE' 'BELNR' '' '' 'No. GR' '' '' '' '' '' '' '' '' '',
            'MENGE_GR' 'EKBE' 'MENGE' '' '' 'Jumlah GR PO' '' '' '' '' '' '' 'MEINS' '' '',
            'BUDAT_GR' 'EKBE' 'BUDAT' '' '13' 'Tanggal GR PO' '' '' '' '' '' '' '' '' '',
            'OTD' 'EKBE' 'MENGE' '' '' 'OTD' '' '' '' '' '' '' 'MEINS' '' '',
            'NSP' 'EKPO' 'NETWR' '' '6' 'NSP' '' '' '' 'IDR' '' '' '' '' '',
            'POVAL' 'EKPO' 'NETWR' '' '6' 'PO Value' '' '' '' 'IDR' '' '' '' '' '',
            'GIVAL' 'EKPO' 'NETWR' '' '6' 'GI Value' '' '' '' 'IDR' '' '' '' '' '',
            'GRVAL' 'EKPO' 'NETWR' '' '6' 'GR Value' '' '' '' 'IDR' '' '' '' '' '',
            'OTDVAL' 'EKPO' 'NETWR' '' '6' 'OTD Value' '' '' '' 'IDR' '' '' '' '' ''.
          PERFORM f_fieldcatg USING ft_report:
             'TDLINE' '' '' '' '' 'Header Text' '' '' '' '' '' '' '' '' ''.
*      PERFORM f_fieldcatg USING ft_report:
*        'GR_GI' '' '' '' '' 'GR - GI' '' '' '' '' '' '' '' '' '',
*        'GI_DN' '' '' '' '' 'GI - DN' '' '' '' '' '' '' '' '' '',
*        'DN_PO_STO' '' '' '' '' 'DN - STO' '' '' '' '' '' '' '' '' ''.
      ENDCASE.

    WHEN rb_sum.
      CASE 'X'.
        WHEN rb_brc.
          PERFORM f_fieldcatg USING ft_report:
            'WERKS' 'T001W' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '',
            'NAME1' 'T001W' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' ''.
        WHEN rb_brcp.
          PERFORM f_fieldcatg USING ft_report:
            'WERKS' 'T001W' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '',
            'NAME1' 'T001W' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '',
            'PRC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '',
            'PRDGP' '' '' '' '10' 'Prd Group' '' '' '' '' '' '' '' '' ''.
        WHEN rb_prc.
          PERFORM f_fieldcatg USING ft_report:
            'PRC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '',
            'PRDGP' '' '' '' '10' 'Prd Group' '' '' '' '' '' '' '' '' ''.
      ENDCASE.

      PERFORM f_fieldcatg USING ft_report:
        'STOW1' 'EKPO' 'MENGE' '' '10' 'STO Week-1' 'X' '' '' '' '' '' '' '' '',
        'STOW2' 'EKPO' 'MENGE' '' '10' 'STO Week-2' 'X' '' '' '' '' '' '' '' '',
        'STOW3' 'EKPO' 'MENGE' '' '10' 'STO Week-3' 'X' '' '' '' '' '' '' '' '',
        'STOW4' 'EKPO' 'MENGE' '' '10' 'STO Week-4' 'X' '' '' '' '' '' '' '' '',
        'STOTOT' 'EKPO' 'MENGE' '' '12' 'STO G.Total' 'X' '' '' '' '' '' '' '' '',
        'DNW1' 'EKPO' 'MENGE' '' '10' 'DN Week-1' 'X' '' '' '' '' '' '' '' '',
        'DNW1%' '' '' '' '10' '%DN Week-1' 'X' '' '' '' '' '' '' '' '',
        'DNW2' 'EKPO' 'MENGE' '' '10' 'DN Week-2' 'X' '' '' '' '' '' '' '' '',
        'DNW2%' '' '' '' '10' '%DN Week-2' 'X' '' '' '' '' '' '' '' '',
        'DNW3' 'EKPO' 'MENGE' '' '10' 'DN Week-3' 'X' '' '' '' '' '' '' '' '',
        'DNW3%' '' '' '' '10' '%DN Week-3' 'X' '' '' '' '' '' '' '' '',
        'DNW4' 'EKPO' 'MENGE' '' '10' 'DN Week-4' 'X' '' '' '' '' '' '' '' '',
        'DNW4%' '' '' '' '10' '%DN Week-4' 'X' '' '' '' '' '' '' '' '',
        'DNTOT' 'EKPO' 'MENGE' '' '12' 'DN Total' 'X' '' '' '' '' '' '' '' '',
        'DNTOT%' '' '' '' '10' '%DN Total' 'X' '' '' '' '' '' '' '' '',
        'DNW6' 'EKPO' 'MENGE' '' '10' 'DN Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'DN6TOT' 'EKPO' 'MENGE' '' '12' 'DN Nx.Month Tot' 'X' '' '' '' '' '' '' '' '',
        'DN6TOT%' '' '' '' '10' '%DN Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'DNGTOT' 'EKPO' 'MENGE' '' '12' 'DN G.Total' 'X' '' '' '' '' '' '' '' '',
        'DNGTOT%' '' '' '' '10' '%DN G.Total' 'X' '' '' '' '' '' '' '' '',
        'GIW1' 'EKPO' 'MENGE' '' '10' 'GI Week-1' 'X' '' '' '' '' '' '' '' '',
        'GIW1%' '' '' '' '10' '%GI Week-1' 'X' '' '' '' '' '' '' '' '',
        'GIW2' 'EKPO' 'MENGE' '' '10' 'GI Week-2' 'X' '' '' '' '' '' '' '' '',
        'GIW2%' '' '' '' '10' '%GI Week-2' 'X' '' '' '' '' '' '' '' '',
        'GIW3' 'EKPO' 'MENGE' '' '10' 'GI Week-3' 'X' '' '' '' '' '' '' '' '',
        'GIW3%' '' '' '' '10' '%GI Week-3' 'X' '' '' '' '' '' '' '' '',
        'GIW4' 'EKPO' 'MENGE' '' '10' 'GI Week-4' 'X' '' '' '' '' '' '' '' '',
        'GIW4%' '' '' '' '10' '%GI Week-4' 'X' '' '' '' '' '' '' '' '',
        'GITOT' 'EKPO' 'MENGE' '' '12' 'GI Total' 'X' '' '' '' '' '' '' '' '',
        'GITOT%' '' '' '' '10' '%GI Total' 'X' '' '' '' '' '' '' '' '',
        'GIW6' 'EKPO' 'MENGE' '' '10' 'GI Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'GI6TOT' 'EKPO' 'MENGE' '' '12' 'GI Nx.Mon Total' 'X' '' '' '' '' '' '' '' '',
        'GI6TOT%' '' '' '' '10' '%GI Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'GIGTOT' 'EKPO' 'MENGE' '' '12' 'GI G.Total' 'X' '' '' '' '' '' '' '' '',
        'GIGTOT%' '' '' '' '10' '%GI G.Total' 'X' '' '' '' '' '' '' '' '',
        'GRW1' 'EKPO' 'MENGE' '' '10' 'GR Week-1' 'X' '' '' '' '' '' '' '' '',
        'GRW1%' '' '' '' '10' '%GR Week-1' 'X' '' '' '' '' '' '' '' '',
        'GRW2' 'EKPO' 'MENGE' '' '10' 'GR Week-2' 'X' '' '' '' '' '' '' '' '',
        'GRW2%' '' '' '' '10' '%GR Week-2' 'X' '' '' '' '' '' '' '' '',
        'GRW3' 'EKPO' 'MENGE' '' '10' 'GR Week-3' 'X' '' '' '' '' '' '' '' '',
        'GRW3%' '' '' '' '10' '%GR Week-3' 'X' '' '' '' '' '' '' '' '',
        'GRW4' 'EKPO' 'MENGE' '' '10' 'GR Week-4' 'X' '' '' '' '' '' '' '' '',
        'GRW4%' '' '' '' '10' '%GR Week-4' 'X' '' '' '' '' '' '' '' '',
        'GRTOT' 'EKPO' 'MENGE' '' '12' 'GR Total' 'X' '' '' '' '' '' '' '' '',
        'GRTOT%' '' '' '' '10' '%GR Total' 'X' '' '' '' '' '' '' '' '',
        'GRW6' 'EKPO' 'MENGE' '' '10' 'GR Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'GR6TOT' 'EKPO' 'MENGE' '' '12' 'GR Nx.Mon Total' 'X' '' '' '' '' '' '' '' '',
        'GR6TOT%' '' '' '' '10' '%GR Nx.Month' 'X' '' '' '' '' '' '' '' '',
        'GRGTOT' 'EKPO' 'MENGE' '' '12' 'GR G.Total' 'X' '' '' '' '' '' '' '' '',
        'GR6TOT%' '' '' '' '10' '%GR Nx.Month' 'X' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = d_top_of_page.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-expand_fieldname   = 'EXPAND'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'MATNR'.
  fu_keyinfo-item01   = 'MATNR'.
ENDFORM.                    " f_build_keyinfo

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN rb_det.
      CLEAR ld_sort.
      ld_sort-fieldname = 'MATNR'.
      ld_sort-up        = 'X'.
      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'MAKTX'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'PRDHA'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'EBELN'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

    WHEN rb_sum.
      CASE 'X'.
        WHEN rb_brc.
          CLEAR ld_sort.
          ld_sort-spos      = '1'.
          ld_sort-fieldname = 'WERKS'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.

        WHEN rb_brcp.
          CLEAR ld_sort.
          ld_sort-spos      = '1'.
          ld_sort-fieldname = 'WERKS'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.
          CLEAR ld_sort.
          ld_sort-spos      = '2'.
          ld_sort-fieldname = 'PRC'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.
          CLEAR ld_sort.
          ld_sort-spos      = '3'.
          ld_sort-fieldname = 'PRDGP'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.

        WHEN rb_prc.
          CLEAR ld_sort.
          ld_sort-spos      = '1'.
          ld_sort-fieldname = 'PRC'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.
          CLEAR ld_sort.
          ld_sort-spos      = '2'.
          ld_sort-fieldname = 'PRDGP'.
          ld_sort-up        = 'X'.
*          ld_sort-subtot    = 'X'.
          APPEND ld_sort TO fu_sort.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
*     i_logo             = 'ENJOYSAP_LOGO'
      it_list_commentary = t_list_top_of_page.

*  DATA: lv_text(100).
*
*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING lv_text.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.
  CASE 'X'.
    WHEN rb_det.
    WHEN rb_sum.
      FORMAT RESET.
      PERFORM f_subtotal USING 'P'.
  ENDCASE.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  REFRESH: gt_header.
  CLEAR: gt_header[], gt_detail[], gt_vdata[],
         gt_header, gt_detail, gt_vdata.
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
FORM f_process_data.

  SORT gt_ekpo BY werks matnr ebeln.
  LOOP AT gt_ekpo.
    PERFORM f_po_item USING gt_ekpo.
  ENDLOOP.

  PERFORM f_modify_itab_header.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_doctyp_ub.

    WHEN radio2.
      PERFORM f_get_eket.
      PERFORM f_doctyp_non_ub.
  ENDCASE.

  PERFORM f_hitung_lead_time_and_week.

ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'BSA'.
            screen-input  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.

      CLEAR: so_bsart[], so_bsart.

      so_bsart-low    = 'UB'.
      so_bsart-sign   = 'I'.
      so_bsart-option = 'EQ'.
      APPEND so_bsart.
      so_bsart-low    = 'ZRL'.
      so_bsart-sign   = 'I'.
      so_bsart-option = 'EQ'.
      APPEND so_bsart.

    WHEN radio2.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'CAL'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.

      DELETE so_bsart WHERE low EQ 'UB'.
      DELETE so_bsart WHERE low EQ 'ZRL'.

  ENDCASE.

  IF sy-uname = 'MMIMG' OR sy-uname = 'ABSUK' OR
     sy-uname = 'TDS_DEV01' OR sy-uname = 'MMEKH' OR
     sy-uname(3) = 'SOM' OR sy-uname = 'PMETP' OR
     sy-uname = 'BCDIK'.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'DET' OR 'SUM'.
          screen-active  = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'DET' OR 'SUM'.
          screen-active  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CASE 'X'.
    WHEN rb_det.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'BRC' OR 'BRP' OR 'PRC'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN rb_sum.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'BRC' OR 'BRP' OR 'PRC'.
            screen-active  = 1.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_ekorg IS INITIAL.
    PERFORM f_error_selection_screen USING 'EKO' ''.
  ENDIF.
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_calid IS INITIAL.
        PERFORM f_error_selection_screen USING 'CAL' ''.
      ENDIF.
    WHEN radio2.
      IF so_bsart[] IS INITIAL.
        so_bsart-low    = 'UB'.
        so_bsart-sign   = 'I'.
        so_bsart-option = 'NE'.
        APPEND so_bsart.
        so_bsart-low    = 'ZUB'.
        so_bsart-sign   = 'I'.
        so_bsart-option = 'NE'.
        APPEND so_bsart.
        so_bsart-low    = 'ZRL'.
        so_bsart-sign   = 'I'.
        so_bsart-option = 'NE'.
        APPEND so_bsart.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_PO_ITEM
*&---------------------------------------------------------------------*
FORM f_po_item USING fwa_ekpo STRUCTURE gt_ekpo.
  DATA : ls_kna1    LIKE LINE OF gt_kna1.

  gt_header-werks   = fwa_ekpo-werks.
  gt_header-matnr   = fwa_ekpo-matnr.
  gt_header-lgort   = fwa_ekpo-lgort.
  gt_header-reslo   = fwa_ekpo-reslo.
  gt_header-bednr   = fwa_ekpo-bednr.
  gt_header-banfn   = fwa_ekpo-banfn.
  PERFORM f_material_description USING 'READ' fwa_ekpo-matnr
                                 CHANGING gt_header-maktx gt_header-prdha
                                          gt_header-extwg.

  gt_header-ebeln   = fwa_ekpo-ebeln.
  gt_header-ebelp   = fwa_ekpo-ebelp.

  READ TABLE gt_ekko WITH KEY ebeln = fwa_ekpo-ebeln.
  IF sy-subrc EQ 0.
    CLEAR gt_lfa1.
    READ TABLE gt_lfa1 WITH KEY lifnr = gt_ekko-lifnr.
    gt_header-bedat   = gt_ekko-bedat.
    gt_header-aedat   = gt_ekko-aedat.
    gt_header-lifnr   = gt_ekko-lifnr.

    gt_header-bsart = gt_ekko-bsart.
    gt_header-vndnm   = gt_lfa1-name1.
  ENDIF.

  READ TABLE gt_t001l WITH KEY werks = fwa_ekpo-werks
                               lgort = fwa_ekpo-lgort.
  IF sy-subrc = 0.
    IF gt_t001l-vstel IS NOT INITIAL.
      gt_header-vstel  = gt_t001l-vstel.
    ELSE.
      gt_header-vstel  = fwa_ekpo-werks.
    ENDIF.
  ENDIF.

  gt_header-menge   = gt_ekpo-menge.
  gt_header-meins   = gt_ekpo-meins.

  gt_header-kunnr   = fwa_ekpo-kunnr.

  CLEAR ls_kna1.
  READ TABLE gt_kna1 INTO ls_kna1 WITH KEY kunnr = fwa_ekpo-kunnr.
  IF sy-subrc = 0.
    gt_header-name1   = ls_kna1-name1.
  ENDIF.

  COLLECT gt_header.
  CLEAR gt_header.
ENDFORM.                    " F_PO_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_material_description  USING    fu_process fu_matnr
                             CHANGING fc_maktx fc_prdha fc_extwg.
  DATA: lt_ekpo LIKE gt_ekpo OCCURS 0 WITH HEADER LINE.

  CASE fu_process.
    WHEN 'SELECT'.
      lt_ekpo[] = gt_ekpo[].
      SORT lt_ekpo BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr.
      IF lt_ekpo[] IS NOT INITIAL.
        SELECT mara~matnr prdha maktx extwg
          FROM mara JOIN makt ON mara~matnr EQ makt~matnr
          INTO TABLE gt_makt
          FOR ALL ENTRIES IN lt_ekpo
          WHERE mara~matnr EQ lt_ekpo-matnr
            AND spras      EQ sy-langu.
      ENDIF.

      SELECT a~matnr a~knumh b~kbetr a~datab a~datbi
      INTO CORRESPONDING FIELDS OF TABLE i_nsp
      FROM a510 AS a JOIN konp AS b ON a~knumh = b~knumh
      FOR ALL ENTRIES IN lt_ekpo
      WHERE a~kappl EQ 'V'           AND
            a~kschl EQ 'ZN01'        AND
            a~matnr EQ lt_ekpo-matnr AND
*            a~datbi GE so_bedat-high AND
*            a~datab LE so_bedat-low  AND
            b~loevm_ko NE 'X'.
      SORT i_nsp BY matnr datab datbi.

    WHEN 'READ'.
      READ TABLE gt_makt WITH KEY matnr = fu_matnr.
      IF sy-subrc EQ 0.
        fc_maktx  = gt_makt-maktx.
        fc_prdha  = gt_makt-prdha.
*        fc_extwg  = gt_makt-extwg.
        fc_extwg  = gt_makt-prdha+3(3).
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_MATERIAL_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM comment_build  USING    lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line        TYPE slis_listheader,
        lv_month(20),
        lv_process(50),
        lv_year(4),
        lv_calid(50),
        lv_sum(50).

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CLEAR lv_month.
  lv_month  = so_bedat-low+4(2).
  lv_year   = so_bedat-low(4).
  PERFORM f_get_month_name USING lv_year
                           CHANGING lv_month.

  lv_process  = lv_month.
  SHIFT lv_process LEFT DELETING LEADING space.

  IF so_bedat-high IS NOT INITIAL.
    CLEAR lv_month.
    lv_month  = so_bedat-high+4(2).
    lv_year   = so_bedat-high(4).
    PERFORM f_get_month_name USING lv_year
                             CHANGING lv_month.

    CONCATENATE lv_process '-' lv_month
    INTO lv_process
    SEPARATED BY space.
  ENDIF.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = lv_process.
  APPEND ls_line TO lt_top_of_page.

  CONCATENATE 'Factory Calendar :' pa_calid INTO lv_calid
  SEPARATED BY space.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = lv_calid.
  APPEND ls_line TO lt_top_of_page.

  IF rb_sum = 'X'.
    CASE 'X'.
      WHEN rb_brc.
        lv_sum = 'Summary by Branch'.
      WHEN rb_brcp.
        lv_sum = 'Summary by Branch & Principal'.
      WHEN rb_prc.
        lv_sum = 'Summary by Principal'.
    ENDCASE.
    CLEAR ls_line.
    ls_line-typ  = 'S'.
    ls_line-info = lv_sum.
    APPEND ls_line TO lt_top_of_page.
  ENDIF.
ENDFORM.                    " COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  F_GET_MONTH_NAME
*&---------------------------------------------------------------------*
FORM f_get_month_name  USING fu_year
                       CHANGING fc_month.
  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = fc_month
    IMPORTING
      name  = fc_month.

  SHIFT fc_month LEFT DELETING LEADING space.
  CONCATENATE fc_month fu_year
  INTO fc_month
  SEPARATED BY space.
ENDFORM.                    " F_GET_MONTH_NAME

*&---------------------------------------------------------------------*
*&      Form  F_DOCTYP_NON_UB
*&---------------------------------------------------------------------*
FORM f_doctyp_non_ub .
  DATA: ld_factdays TYPE i. "int3.

  LOOP AT gt_header.
    gt_vdata  = gt_header.
    LOOP AT gt_ekbe WHERE ebeln = gt_header-ebeln
                      AND ebelp = gt_header-ebelp
                      AND bewtp = 'E'.
      gt_vdata-belnr_gr   = gt_ekbe-belnr.
      gt_vdata-menge_gr   = gt_ekbe-menge.
      gt_vdata-budat_gr   = gt_ekbe-budat.
*      READ TABLE i_nsp WITH KEY matnr = gt_vdata-matnr
*      BINARY SEARCH.
*      If sy-subrc = 0.

      CLEAR gt_eket.
      READ TABLE gt_eket WITH KEY ebeln = gt_ekbe-ebeln
                                  ebelp = gt_ekbe-ebelp.
      PERFORM f_factory_calendar2 USING gt_eket-eindt gt_ekbe-budat  'T1'
                                  CHANGING ld_factdays.
      IF ld_factdays < 2.
        gt_vdata-otd = gt_ekbe-menge.
      ELSE.
        gt_vdata-otd = 0.
      ENDIF.

      LOOP AT i_nsp WHERE matnr =  gt_vdata-matnr
                      AND datab LE gt_vdata-bedat
                      AND datbi GE gt_vdata-bedat.
        gt_vdata-nsp = i_nsp-kbetr.
        gt_vdata-poval = gt_vdata-menge * i_nsp-kbetr.
*         gt_vdata-gival = gt_vdata-menge_gi * i_nsp-kbetr.
        gt_vdata-grval = gt_vdata-menge_gr * i_nsp-kbetr.
        gt_vdata-otdval = gt_vdata-otd * i_nsp-kbetr.
      ENDLOOP.
      IF sy-subrc <> 0.
        CLEAR: gt_vdata-nsp, gt_vdata-poval, gt_vdata-grval, gt_vdata-otdval.
      ENDIF.
      CLEAR gt_vdata-gival.

      APPEND gt_vdata.
      CLEAR: gt_vdata-menge.
    ENDLOOP.

    IF sy-subrc NE 0.
      CLEAR: gt_vdata-belnr_gr, gt_vdata-menge_gr, gt_vdata-budat_gr,
             gt_vdata-nsp, gt_vdata-poval, gt_vdata-gival, gt_vdata-grval.
*      READ TABLE i_nsp WITH KEY matnr = gt_vdata-matnr
*      BINARY SEARCH.
*      If sy-subrc = 0.
      LOOP AT i_nsp WHERE matnr =  gt_vdata-matnr
                      AND datab LE gt_vdata-bedat
                      AND datbi GE gt_vdata-bedat.
        gt_vdata-nsp = i_nsp-kbetr.
        gt_vdata-poval = gt_vdata-menge * i_nsp-kbetr.
      ENDLOOP.
*      Endif.
      APPEND gt_vdata.
    ENDIF.

    CLEAR gt_vdata.
  ENDLOOP.
ENDFORM.                    " F_DOCTYP_NON_UB

*&---------------------------------------------------------------------*
*&      Form  F_DOCTYP_UB
*&---------------------------------------------------------------------*
FORM f_doctyp_ub  .
  DATA : lt_gabung LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
         lt_dn     LIKE gt_ekbe OCCURS 0 WITH HEADER LINE,
         lt_gi     LIKE gt_ekbe OCCURS 0 WITH HEADER LINE,
         lt_gr     LIKE gt_ekbe OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_vbfa OCCURS 0,
           vbelv   TYPE vbeln_von,
           posnv   TYPE posnr_von,
           vbeln   TYPE vbeln_nach,
           posnn   TYPE posnr_nach,
           vbtyp_n TYPE vbtyp_n,
         END OF lt_vbfa,

         lt_vbfa_dn LIKE lt_vbfa OCCURS 0 WITH HEADER LINE,
         lt_vbfa_gr LIKE lt_vbfa OCCURS 0 WITH HEADER LINE,
         d_flag     TYPE char1.

  DATA : BEGIN OF lt_likp OCCURS 0,
           vbeln TYPE vbeln_vl,
           erdat TYPE erdat,
           lprio TYPE likp-lprio,
         END OF lt_likp.

  DATA : lt_tprit   TYPE STANDARD TABLE OF tprit.

  SELECT *
    FROM tprit
    INTO CORRESPONDING FIELDS OF TABLE lt_tprit
    WHERE spras = sy-langu.

  IF gt_ekbe[] IS NOT INITIAL.
    SELECT vbeln erdat lprio
      FROM likp
      INTO TABLE lt_likp
      FOR ALL ENTRIES IN gt_ekbe
      WHERE vbeln = gt_ekbe-belnr.

    IF lt_likp[] IS NOT INITIAL.
      SELECT vbeln posnr matnr brgew gewei volum voleh
        FROM lips
        INTO TABLE gt_lips
        FOR ALL ENTRIES IN lt_likp
        WHERE vbeln = lt_likp-vbeln.

      SELECT a~tknum a~tpnum a~vbeln b~vbtyp b~shtyp b~tplst
             b~ernam b~erdat b~erzet b~exti1 b~exti2 b~tpbez
             b~datbg b~signi b~tdlnr b~gesztd
        INTO CORRESPONDING FIELDS OF TABLE gt_vttp
        FROM vttp AS a JOIN vttk AS b ON b~tknum = a~tknum
        FOR ALL ENTRIES IN lt_likp
        WHERE vbeln = lt_likp-vbeln.
      IF sy-subrc = 0.
        SELECT lifnr name1
          INTO CORRESPONDING FIELDS OF TABLE gt_lfa2
          FROM lfa1 FOR ALL ENTRIES IN gt_vttp
          WHERE lifnr = gt_vttp-tdlnr.
      ENDIF.
    ENDIF.
  ENDIF.

  SORT gt_ekbe BY ebeln ebelp bewtp.
  SORT lt_likp BY vbeln.

  LOOP AT gt_ekbe.
    CASE gt_ekbe-bewtp.
      WHEN 'L'.
        lt_dn = gt_ekbe.
        READ TABLE lt_likp WITH KEY vbeln = gt_ekbe-belnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          lt_dn-budat = lt_likp-erdat.
*          lt_dn-lprio = lt_likp-lprio.
        ENDIF.
        CLEAR lt_dn-buzei.
        COLLECT lt_dn.
      WHEN 'U'.
        lt_gi = gt_ekbe.
        CLEAR lt_gi-buzei.
        COLLECT lt_gi.
      WHEN 'E'.
        lt_gr = gt_ekbe.
        COLLECT lt_gr.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
  ENDLOOP.

  PERFORM f_check_cancel_document TABLES lt_gr.
  PERFORM f_check_cancel_document TABLES lt_gi.

  IF lt_dn[] IS NOT INITIAL.
    SELECT vbelv posnv vbeln posnn vbtyp_n
      FROM vbfa
      INTO TABLE lt_vbfa
      FOR ALL ENTRIES IN lt_dn
      WHERE vbelv = lt_dn-belnr.
  ENDIF.

*  SORT lt_vbfa BY vbtyp_n vbeln DESCENDING.
  SORT lt_vbfa BY vbtyp_n vbeln.
  IF sy-uname = 'MMFM'.
    d_flag = 'X'.
  ENDIF.
  BREAK mmfm.
* Split lt_vbfa into 2 itab for faster performance using binary search
  lt_vbfa_dn[] = lt_vbfa[].
  lt_vbfa_gr[] = lt_vbfa[].
  DELETE lt_vbfa_gr WHERE vbtyp_n <> 'i'.
  DELETE lt_vbfa_dn WHERE vbtyp_n <> 'R'.
  IF d_flag = 'X'.
    SORT : lt_vbfa_gr BY vbeln posnn vbtyp_n,
           lt_vbfa_dn BY vbelv posnv vbtyp_n.
  ELSE.
    SORT : lt_vbfa_gr BY vbeln vbtyp_n,
           lt_vbfa_dn BY vbelv vbtyp_n.
    DELETE ADJACENT DUPLICATES FROM lt_vbfa_dn COMPARING vbelv vbeln.
  ENDIF.

  PERFORM f_check_vbfa_dn TABLES lt_vbfa_dn
                                 lt_gi.

  SORT lt_vbfa_dn BY vbtyp_n vbeln DESCENDING.

  SORT lt_gr BY ebeln belnr DESCENDING.

  LOOP AT gt_ekbe.
    lt_gabung-ebeln = gt_ekbe-ebeln.
    lt_gabung-ebelp = gt_ekbe-ebelp.
    LOOP AT lt_gr WHERE ebeln EQ gt_ekbe-ebeln
                    AND ebelp EQ gt_ekbe-ebelp.
      lt_gabung-belnr_gr  = lt_gr-belnr.
      lt_gabung-menge_gr  = lt_gr-menge.
      lt_gabung-budat_gr  = lt_gr-budat.
      DELETE lt_gr INDEX sy-tabix.
      IF d_flag = 'X'.
        READ TABLE lt_vbfa_gr WITH KEY vbeln = lt_gr-belnr
                                       posnn = lt_gr-buzei
                                       vbtyp_n = 'i'
        BINARY SEARCH.
      ELSE.
        READ TABLE lt_vbfa_gr WITH KEY vbeln = lt_gr-belnr
                                       vbtyp_n = 'i'.
      ENDIF.
      IF sy-subrc = 0.
        READ TABLE lt_dn WITH KEY belnr = lt_vbfa_gr-vbelv.
        IF sy-subrc EQ 0.
          lt_gabung-belnr_dn  = lt_dn-belnr.
          lt_gabung-menge_dn  = lt_dn-menge.
          lt_gabung-budat_dn  = lt_dn-budat.
          DELETE lt_dn INDEX sy-tabix.
        ENDIF.
      ENDIF.

*      READ TABLE lt_vbfa_dn WITH KEY vbelv   = lt_dn-belnr
**                                     posnv   = lt_dn-buzei
*                                     vbtyp_n = 'R'.
**      BINARY SEARCH.
*      IF sy-subrc = 0.
*        READ TABLE lt_gi WITH KEY belnr = lt_vbfa_dn-vbeln.
      READ TABLE lt_gi WITH KEY ebeln = gt_ekbe-ebeln
                                ebelp = gt_ekbe-ebelp
                                xblnr = lt_dn-belnr.
      IF sy-subrc EQ 0.
        lt_gabung-belnr_gi  = lt_gi-belnr.
        lt_gabung-menge_gi  = lt_gi-menge.
        lt_gabung-budat_gi  = lt_gi-budat.
        DELETE lt_gi INDEX sy-tabix.
      ENDIF.
*      ENDIF.
      COLLECT lt_gabung.
      CLEAR: lt_gabung-belnr_gr, lt_gabung-menge_gr, lt_gabung-budat_gr,
             lt_gabung-belnr_dn, lt_gabung-menge_dn, lt_gabung-budat_dn,
             lt_gabung-belnr_gi, lt_gabung-menge_gi, lt_gabung-budat_gi.
    ENDLOOP.

    lt_gabung-ebeln = gt_ekbe-ebeln.
    lt_gabung-ebelp = gt_ekbe-ebelp.
    LOOP AT lt_dn WHERE ebeln EQ gt_ekbe-ebeln
                    AND ebelp EQ gt_ekbe-ebelp.
      lt_gabung-belnr_dn  = lt_dn-belnr.
      lt_gabung-menge_dn  = lt_dn-menge.
      lt_gabung-budat_dn  = lt_dn-budat.
      DELETE lt_dn INDEX sy-tabix.

      READ TABLE lt_gi WITH KEY ebeln = lt_dn-ebeln
                                ebelp = lt_dn-ebelp
                                xblnr = lt_dn-belnr.
      IF sy-subrc EQ 0.
        lt_gabung-belnr_gi  = lt_gi-belnr.
*        lt_gabung-belnr_gi  = lt_gi-xblnr.
        lt_gabung-menge_gi  = lt_gi-menge.
        lt_gabung-budat_gi  = lt_gi-budat.
        DELETE lt_gi INDEX sy-tabix.
      ENDIF.
      COLLECT lt_gabung.
      CLEAR: lt_gabung-belnr_gr, lt_gabung-menge_gr, lt_gabung-budat_gr,
             lt_gabung-belnr_dn, lt_gabung-menge_dn, lt_gabung-budat_dn,
             lt_gabung-belnr_gi, lt_gabung-menge_gi, lt_gabung-budat_gi.
    ENDLOOP.
  ENDLOOP.

  LOOP AT lt_gi.
    lt_gabung-ebeln = gt_ekbe-ebeln.
    lt_gabung-ebelp = gt_ekbe-ebelp.
    lt_gabung-belnr_gi  = lt_gi-belnr.
*    lt_gabung-belnr_gi  = lt_gi-xblnr.
    lt_gabung-menge_gi  = lt_gi-menge.
    lt_gabung-budat_gi  = lt_gi-budat.
    DELETE lt_gi INDEX sy-tabix.
    COLLECT lt_gabung.
    CLEAR: lt_gabung-belnr_gr, lt_gabung-menge_gr, lt_gabung-budat_gr,
           lt_gabung-belnr_dn, lt_gabung-menge_dn, lt_gabung-budat_dn,
           lt_gabung-belnr_gi, lt_gabung-menge_gi, lt_gabung-budat_gi.
  ENDLOOP.

  LOOP AT gt_header.
    MOVE-CORRESPONDING gt_header TO gt_vdata.
    LOOP AT lt_gabung WHERE ebeln = gt_header-ebeln
                        AND ebelp = gt_header-ebelp.
      gt_vdata-belnr_dn   = lt_gabung-belnr_dn.
      gt_vdata-menge_dn   = lt_gabung-menge_dn.
      gt_vdata-budat_dn   = lt_gabung-budat_dn.
      gt_vdata-belnr_gi   = lt_gabung-belnr_gi.
      gt_vdata-menge_gi   = lt_gabung-menge_gi.
      gt_vdata-budat_gi   = lt_gabung-budat_gi.
      gt_vdata-belnr_gr   = lt_gabung-belnr_gr.
      gt_vdata-menge_gr   = lt_gabung-menge_gr.
      gt_vdata-budat_gr   = lt_gabung-budat_gr.
      DELETE lt_gabung INDEX sy-tabix.

      CLEAR: gt_vttp,gt_lfa2.
      READ TABLE gt_vttp WITH KEY vbeln = gt_vdata-belnr_dn.
      READ TABLE gt_lfa2 WITH KEY lifnr = gt_vttp-tdlnr.
      gt_vdata-tknum = gt_vttp-tknum.
      gt_vdata-datbg = gt_vttp-datbg.
      gt_vdata-exti1 = gt_vttp-exti1.
      gt_vdata-exti2 = gt_vttp-exti2.
      gt_vdata-tdlnr = gt_vttp-tdlnr.
      gt_vdata-signi = gt_vttp-signi.
      gt_vdata-gesztd = gt_vttp-gesztd.
      gt_vdata-profnm = gt_lfa2-name1.
      IF gt_vttp-erdat IS NOT INITIAL.
*        gt_vdata-etdat = gt_vttp-erdat + ( gt_vttp-gesztd / 240000 ).
        gt_vdata-etdat = gt_vttp-datbg + ( gt_vttp-gesztd / 240000 ).
      ENDIF.

      READ TABLE i_nsp WITH KEY matnr = gt_vdata-matnr
      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT i_nsp FROM sy-tabix.
          IF i_nsp-matnr =  gt_vdata-matnr
         AND i_nsp-datab LE gt_vdata-bedat
         AND i_nsp-datbi GE gt_vdata-bedat.
            gt_vdata-nsp = i_nsp-kbetr.
            gt_vdata-poval = gt_vdata-menge * i_nsp-kbetr.
            gt_vdata-gival = gt_vdata-menge_gi * i_nsp-kbetr.
            gt_vdata-grval = gt_vdata-menge_gr * i_nsp-kbetr.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF sy-subrc <> 0.
        CLEAR: gt_vdata-nsp, gt_vdata-poval, gt_vdata-gival,
               gt_vdata-grval.
      ENDIF.

      PERFORM f_get_weight_volum.

      PERFORM f_priority TABLES lt_tprit lt_likp
                         USING gt_header-ebeln gt_header-ebelp ''
                         CHANGING gt_vdata-lprio gt_vdata-bezei.

      APPEND gt_vdata.

      CLEAR: gt_vdata-menge, gt_vdata-menge_dn,
             gt_vdata-menge_gi, gt_vdata-menge_gr, gt_vdata-nsp,
             gt_vdata-poval, gt_vdata-gival, gt_vdata-grval, gt_vdata-brgew,
             gt_vdata-gewei, gt_vdata-volum, gt_vdata-voleh, gt_vdata-lprio,
             gt_vdata-bezei, gt_vdata-lprio1, gt_vdata-bezei1.
    ENDLOOP.

    IF sy-subrc NE 0.
      CLEAR: gt_vdata-belnr_dn, gt_vdata-menge_dn, gt_vdata-budat_dn,
             gt_vdata-belnr_gi, gt_vdata-menge_gi, gt_vdata-budat_gi,
             gt_vdata-belnr_gr, gt_vdata-menge_gr, gt_vdata-budat_gr,
             gt_vdata-nsp, gt_vdata-poval, gt_vdata-gival, gt_vdata-grval,
             gt_vdata-brgew, gt_vdata-gewei, gt_vdata-volum, gt_vdata-voleh.
      READ TABLE i_nsp WITH KEY matnr = gt_vdata-matnr
      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT i_nsp FROM sy-tabix.
          IF i_nsp-matnr =  gt_vdata-matnr
         AND i_nsp-datab LE gt_vdata-bedat
         AND i_nsp-datbi GE gt_vdata-bedat.
            gt_vdata-nsp = i_nsp-kbetr.
            gt_vdata-poval = gt_vdata-menge * i_nsp-kbetr.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      PERFORM f_get_weight_volum.

      PERFORM f_priority TABLES lt_tprit lt_likp
                         USING gt_header-ebeln gt_header-ebelp ''
                         CHANGING gt_vdata-lprio gt_vdata-bezei.

      APPEND gt_vdata.
    ENDIF.

    CLEAR gt_vdata.
  ENDLOOP.

  LOOP AT gt_vdata.
    IF gt_vdata-menge IS INITIAL.
      CLEAR gt_vdata-pocar.
    ENDIF.
    PERFORM f_priority TABLES lt_tprit lt_likp
                   USING '' '' gt_vdata-belnr_dn
                   CHANGING gt_vdata-lprio1 gt_vdata-bezei1.
    MODIFY gt_vdata TRANSPORTING pocar lprio1 bezei1.
    CLEAR gt_vdata.
  ENDLOOP.
  REFRESH : lt_vbfa[], lt_vbfa_dn[], lt_vbfa_gr[].
ENDFORM.                    " F_DOCTYP_UB

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_LEAD_TIME_AND_WEEK
*&---------------------------------------------------------------------*
FORM f_hitung_lead_time_and_week .
  DATA : lt_vdata   LIKE gt_vdata OCCURS 0 WITH HEADER LINE.

  lt_vdata[]  = gt_vdata[].
  SORT lt_vdata BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_vdata COMPARING ebeln.

  LOOP AT gt_vdata.
* Lead time GR - GI
    PERFORM f_factory_calendar USING '' gt_vdata-budat_gi gt_vdata-budat_gr
                               CHANGING gt_vdata-gr_gi.
* Lead time GI - DN
    PERFORM f_factory_calendar USING '' gt_vdata-budat_dn gt_vdata-budat_gi
                               CHANGING gt_vdata-gi_dn.

* Lead time DN - PO/STO
    PERFORM f_factory_calendar USING gt_vdata-ebeln gt_vdata-bedat
                                     gt_vdata-budat_dn
                               CHANGING gt_vdata-dn_po_sto.

* Lead time GR - PO/STO
    PERFORM f_factory_calendar USING gt_vdata-ebeln gt_vdata-bedat
                                     gt_vdata-budat_gr
                               CHANGING gt_vdata-gr_po_sto.

* Lead time DN - Shipment
    PERFORM f_factory_calendar USING '' gt_vdata-budat_dn gt_vdata-datbg
                               CHANGING gt_vdata-dn_ship.

* Lead time GI - Shipment
    PERFORM f_factory_calendar USING '' gt_vdata-budat_gi gt_vdata-datbg
                               CHANGING gt_vdata-gi_ship.

* Lead time Shipment - GR
    PERFORM f_factory_calendar USING '' gt_vdata-budat_gr gt_vdata-datbg
                               CHANGING gt_vdata-ship_gr.

    READ TABLE lt_vdata WITH KEY ebeln = gt_vdata-ebeln.
    IF sy-subrc = 0.
      DELETE lt_vdata INDEX sy-tabix.
      READ TABLE gt_vercon WITH KEY ebeln = gt_vdata-ebeln.
      IF sy-subrc = 0.
        gt_vdata-versidn  = gt_vercon-versidn.
      ENDIF.
    ELSE.
      CLEAR gt_vdata-versidn.
    ENDIF.

* Week & Month Alokasi
    PERFORM f_hitung_week USING gt_vdata-bedat
                          CHANGING gt_vdata-week_alo gt_vdata-mnth_alo.
* Week & Month DN
    PERFORM f_hitung_week USING gt_vdata-budat_dn
                          CHANGING gt_vdata-week_dn gt_vdata-mnth_dn.
* Week & Month GI
    PERFORM f_hitung_week USING gt_vdata-budat_gi
                          CHANGING gt_vdata-week_gi gt_vdata-mnth_gi.
* Week & Month GR PO
    PERFORM f_hitung_week USING gt_vdata-budat_gr
                          CHANGING gt_vdata-week_gr gt_vdata-mnth_gr.
* Week & Month Shippment
    PERFORM f_hitung_week USING gt_vdata-datbg
                          CHANGING gt_vdata-week_ship gt_vdata-mnth_ship.

* Check material SAT/IDM
    READ TABLE gt_mat_b2b WITH KEY matnr = gt_vdata-matnr
                          TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      gt_vdata-flg1 = 'X'.
    ELSE.
      CLEAR gt_vdata-flg1.
    ENDIF.

    DATA: lt_lines TYPE STANDARD TABLE OF tline,
          ls_lines LIKE LINE OF lt_lines,
          lv_name  LIKE  thead-tdname.

    CLEAR: lt_lines[],ls_lines,lv_name.
    lv_name = gt_vdata-ebeln.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'F01'
        language                = 'E'
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

    IF sy-subrc = 0.
      READ TABLE lt_lines INTO ls_lines INDEX 1.
      gt_vdata-tdline = ls_lines-tdline.
    ENDIF.

    MODIFY gt_vdata TRANSPORTING gr_gi gi_dn dn_po_sto gr_po_sto versidn
                                 week_alo mnth_alo week_dn mnth_dn
                                 week_gi mnth_gi week_gr mnth_gr flg1 tdline
                                 dn_ship gi_ship ship_gr week_ship mnth_ship.

    IF radio1 = 'X' AND rb_sum = 'X'.
      CASE 'X'.
        WHEN rb_brc.
          PERFORM f_branch_summaries USING gt_vdata.
        WHEN rb_brcp.
          PERFORM f_branch_princ_summaries USING gt_vdata.
        WHEN rb_prc.
          PERFORM f_principal_summaries USING gt_vdata.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  IF radio1 = 'X' AND rb_sum = 'X'.
    CASE 'X'.
      WHEN rb_brc.
        PERFORM f_%_branch_summaries.
      WHEN rb_brcp.
        PERFORM f_%_branch_princ_summaries.
      WHEN rb_prc.
        PERFORM f_%_principal_summaries.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_HITUNG_LEAD_TIME_AND_WEEK

*&---------------------------------------------------------------------*
*&      Form  F_FACTORY_CALENDAR
*&---------------------------------------------------------------------*
FORM f_factory_calendar  USING    fu_ebeln fu_datab fu_datbi
                         CHANGING fu_day.

  DATA: eth_dats LIKE rke_dat OCCURS 0 WITH HEADER LINE,
        lv_datab TYPE sy-datum,
        lv_datbi TYPE sy-datum.

  lv_datab  = fu_datab.
  lv_datbi  = fu_datbi.

  IF fu_ebeln IS NOT INITIAL AND
    fu_datab IS INITIAL.
    READ TABLE gt_ekko WITH KEY ebeln = fu_ebeln.
    IF sy-subrc = 0.
      lv_datab = gt_ekko-bedat.
    ENDIF.
  ENDIF.

  IF lv_datab NE lv_datbi.
    CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
      EXPORTING
        i_datab               = lv_datab
        i_datbi               = lv_datbi
        i_factid              = pa_calid
      TABLES
        eth_dats              = eth_dats
      EXCEPTIONS
        date_conversion_error = 1
        OTHERS                = 2.
  ENDIF.

  DESCRIBE TABLE eth_dats LINES fu_day.
  IF fu_day GT 0.
    fu_day  = fu_day - 1.
  ENDIF.
ENDFORM.                    " F_FACTORY_CALENDAR

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CANCEL_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_check_cancel_document  TABLES   ft_document STRUCTURE gt_ekbe.
  DATA : BEGIN OF lt_mseg OCCURS 0,
           mblnr TYPE mblnr,
           smbln TYPE mblnr,
         END OF lt_mseg.
  DATA : BEGIN OF lt_document OCCURS 0,
           mblnr TYPE mblnr,
         END OF lt_document.

  CHECK ft_document[] IS NOT INITIAL.

  SELECT mblnr smbln
    FROM mseg
    INTO TABLE lt_mseg
    FOR ALL ENTRIES IN ft_document
    WHERE mblnr = ft_document-belnr
      AND smbln <> space.

  LOOP AT lt_mseg.
    lt_document-mblnr = lt_mseg-mblnr.
    APPEND lt_document.
    lt_document-mblnr = lt_mseg-smbln.
    APPEND lt_document.
  ENDLOOP.

  LOOP AT ft_document.
    READ TABLE lt_document WITH KEY mblnr = ft_document-belnr.
    IF sy-subrc = 0.
      DELETE ft_document.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_CANCEL_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_WEEK
*&---------------------------------------------------------------------*
FORM f_hitung_week  USING    fu_datum
                    CHANGING fc_week fc_month.
  DATA : lv_week1    LIKE scal-week,
         lv_week2    LIKE scal-week,
         lv_date     TYPE sy-datum,
         lv_month(2),
         lv_datum    TYPE sy-datum.

  CLEAR : fc_week, fc_month.

  IF fu_datum = space.
    lv_datum  = '00000000'.
  ELSE.
    lv_datum  = fu_datum.
  ENDIF.

  CHECK lv_datum IS NOT INITIAL.

  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      date = fu_datum
    IMPORTING
      week = lv_week1.

  CONCATENATE fu_datum(6) '01' INTO lv_date.

  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      date = lv_date
    IMPORTING
      week = lv_week2.

  fc_week = lv_week1+4(2) - lv_week2+4(2).

  IF fc_week = 0.
    fc_week = 1.
  ELSEIF fc_week < 0.
    fc_week = fc_week + lv_week2+4(2).
  ENDIF.

  lv_month  = fu_datum+4(2).

  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = lv_month
    IMPORTING
      name  = fc_month.
ENDFORM.                    " F_HITUNG_WEEK

*&---------------------------------------------------------------------*
*&      Form  F_BRANCH_SUMMARIES
*&---------------------------------------------------------------------*
FORM f_branch_summaries  USING    fu_vdata STRUCTURE gt_vdata.
  DATA: lv_month TYPE pc260-fpper.

  lv_month = so_bedat-low(6).
  CALL FUNCTION 'HR_CALC_MONTH'
    EXPORTING
      delta   = 1
    CHANGING
      periode = lv_month.

  gt_sum_brc-werks   = fu_vdata-werks.

  IF lv_month EQ fu_vdata-bedat(6).
  ELSE.
    CASE fu_vdata-week_alo.
      WHEN 1.
        gt_sum_brc-stow1   = fu_vdata-menge.
      WHEN 2.
        gt_sum_brc-stow2   = fu_vdata-menge.
      WHEN 3.
        gt_sum_brc-stow3   = fu_vdata-menge.
      WHEN 4.
        gt_sum_brc-stow4   = fu_vdata-menge.
      WHEN 5.
        gt_sum_brc-stow5   = fu_vdata-menge.
    ENDCASE.
  ENDIF.
  gt_sum_brc-stotot  = fu_vdata-menge.

  IF lv_month EQ fu_vdata-budat_dn(6).
    gt_sum_brc-dnw6    = fu_vdata-menge_dn.
    gt_sum_brc-dn6tot  = fu_vdata-menge_dn.
  ELSE.
    CASE fu_vdata-week_dn.
      WHEN 1.
        gt_sum_brc-dnw1    = fu_vdata-menge_dn.
      WHEN 2.
        gt_sum_brc-dnw2    = fu_vdata-menge_dn.
      WHEN 3.
        gt_sum_brc-dnw3    = fu_vdata-menge_dn.
      WHEN 4.
        gt_sum_brc-dnw4    = fu_vdata-menge_dn.
      WHEN 5.
        gt_sum_brc-dnw5    = fu_vdata-menge_dn.
    ENDCASE.
    gt_sum_brc-dntot   = fu_vdata-menge_dn.
  ENDIF.
  gt_sum_brc-dngtot  = fu_vdata-menge_dn.

  IF lv_month EQ fu_vdata-budat_gi(6).
    gt_sum_brc-giw6    = fu_vdata-menge_gi.
    gt_sum_brc-gi6tot  = fu_vdata-menge_gi.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_brc-giw1    = fu_vdata-menge_gi.
      WHEN 2.
        gt_sum_brc-giw2    = fu_vdata-menge_gi.
      WHEN 3.
        gt_sum_brc-giw3    = fu_vdata-menge_gi.
      WHEN 4.
        gt_sum_brc-giw4    = fu_vdata-menge_gi.
      WHEN 5.
        gt_sum_brc-giw5    = fu_vdata-menge_gi.
    ENDCASE.
    gt_sum_brc-gitot   = fu_vdata-menge_gi.
  ENDIF.
  gt_sum_brc-gigtot  = fu_vdata-menge_gi.

  IF lv_month EQ fu_vdata-budat_gr(6).
    gt_sum_brc-grw6    = fu_vdata-menge_gr.
    gt_sum_brc-gr6tot  = fu_vdata-menge_gr.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_brc-grw1    = fu_vdata-menge_gr.
      WHEN 2.
        gt_sum_brc-grw2    = fu_vdata-menge_gr.
      WHEN 3.
        gt_sum_brc-grw3    = fu_vdata-menge_gr.
      WHEN 4.
        gt_sum_brc-grw4    = fu_vdata-menge_gr.
      WHEN 5.
        gt_sum_brc-grw5    = fu_vdata-menge_gr.
    ENDCASE.
    gt_sum_brc-grtot   = fu_vdata-menge_gr.
  ENDIF.
  gt_sum_brc-grgtot  = fu_vdata-menge_gr.

  COLLECT gt_sum_brc. CLEAR gt_sum_brc.
ENDFORM.                    " F_BRANCH_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_BRANCH_PRINC_SUMMARIES
*----------------------------------------------------------------------*
FORM f_branch_princ_summaries  USING    fu_vdata STRUCTURE gt_vdata.
  DATA: lv_month TYPE pc260-fpper.

  lv_month = so_bedat-low(6).
  CALL FUNCTION 'HR_CALC_MONTH'
    EXPORTING
      delta   = 1
    CHANGING
      periode = lv_month.

  gt_sum_brcp-werks   = fu_vdata-werks.
  gt_sum_brcp-prc     = fu_vdata-prdha(3).
  gt_sum_brcp-prdgp   = fu_vdata-prdha+3(3).

  IF lv_month EQ fu_vdata-bedat(6).
  ELSE.
    CASE fu_vdata-week_alo.
      WHEN 1.
        gt_sum_brcp-stow1   = fu_vdata-menge.
      WHEN 2.
        gt_sum_brcp-stow2   = fu_vdata-menge.
      WHEN 3.
        gt_sum_brcp-stow3   = fu_vdata-menge.
      WHEN 4.
        gt_sum_brcp-stow4   = fu_vdata-menge.
      WHEN 5.
        gt_sum_brcp-stow5   = fu_vdata-menge.
    ENDCASE.
  ENDIF.
  gt_sum_brcp-stotot  = fu_vdata-menge.

  IF lv_month EQ fu_vdata-budat_dn.
    gt_sum_brcp-dnw6    = fu_vdata-menge_dn.
    gt_sum_brcp-dn6tot  = fu_vdata-menge_dn.
  ELSE.
    CASE fu_vdata-week_dn.
      WHEN 1.
        gt_sum_brcp-dnw1    = fu_vdata-menge_dn.
      WHEN 2.
        gt_sum_brcp-dnw2    = fu_vdata-menge_dn.
      WHEN 3.
        gt_sum_brcp-dnw3    = fu_vdata-menge_dn.
      WHEN 4.
        gt_sum_brcp-dnw4    = fu_vdata-menge_dn.
      WHEN 5.
        gt_sum_brcp-dnw5    = fu_vdata-menge_dn.
    ENDCASE.
    gt_sum_brcp-dntot   = fu_vdata-menge_dn.
  ENDIF.
  gt_sum_brcp-dngtot  = fu_vdata-menge_dn.

  IF lv_month EQ fu_vdata-budat_gi.
    gt_sum_brcp-giw6    = fu_vdata-menge_gi.
    gt_sum_brcp-gi6tot  = fu_vdata-menge_gi.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_brcp-giw1    = fu_vdata-menge_gi.
      WHEN 2.
        gt_sum_brcp-giw2    = fu_vdata-menge_gi.
      WHEN 3.
        gt_sum_brcp-giw3    = fu_vdata-menge_gi.
      WHEN 4.
        gt_sum_brcp-giw4    = fu_vdata-menge_gi.
      WHEN 5.
        gt_sum_brcp-giw5    = fu_vdata-menge_gi.
    ENDCASE.
    gt_sum_brcp-gitot   = fu_vdata-menge_gi.
  ENDIF.
  gt_sum_brcp-gigtot  = fu_vdata-menge_gi.

  IF lv_month EQ fu_vdata-budat_gr.
    gt_sum_brcp-grw6    = fu_vdata-menge_gr.
    gt_sum_brcp-gr6tot  = fu_vdata-menge_gr.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_brcp-grw1    = fu_vdata-menge_gr.
      WHEN 2.
        gt_sum_brcp-grw2    = fu_vdata-menge_gr.
      WHEN 3.
        gt_sum_brcp-grw3    = fu_vdata-menge_gr.
      WHEN 4.
        gt_sum_brcp-grw4    = fu_vdata-menge_gr.
      WHEN 5.
        gt_sum_brcp-grw5    = fu_vdata-menge_gr.
    ENDCASE.
    gt_sum_brcp-grtot   = fu_vdata-menge_gr.
  ENDIF.
  gt_sum_brcp-grgtot  = fu_vdata-menge_gr.

  COLLECT gt_sum_brcp. CLEAR gt_sum_brcp.
ENDFORM.                    " F_BRANCH_PRINC_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_PRINCIPAL_SUMMARIES
*&---------------------------------------------------------------------*
FORM f_principal_summaries  USING    fu_vdata STRUCTURE gt_vdata.
  DATA: lv_month TYPE pc260-fpper.

  lv_month = so_bedat-low(6).
  CALL FUNCTION 'HR_CALC_MONTH'
    EXPORTING
      delta   = 1
    CHANGING
      periode = lv_month.

  gt_sum_prc-prc     = fu_vdata-prdha(3).
  gt_sum_prc-prdgp   = fu_vdata-prdha+3(3).

  IF lv_month EQ fu_vdata-bedat(6).
  ELSE.
    CASE fu_vdata-week_alo.
      WHEN 1.
        gt_sum_prc-stow1   = fu_vdata-menge.
      WHEN 2.
        gt_sum_prc-stow2   = fu_vdata-menge.
      WHEN 3.
        gt_sum_prc-stow3   = fu_vdata-menge.
      WHEN 4.
        gt_sum_prc-stow4   = fu_vdata-menge.
      WHEN 5.
        gt_sum_prc-stow5   = fu_vdata-menge.
    ENDCASE.
  ENDIF.
  gt_sum_prc-stotot  = fu_vdata-menge.

  IF lv_month EQ fu_vdata-budat_dn.
    gt_sum_prc-dnw6    = fu_vdata-menge_dn.
    gt_sum_prc-dn6tot  = fu_vdata-menge_dn.
  ELSE.
    CASE fu_vdata-week_dn.
      WHEN 1.
        gt_sum_prc-dnw1    = fu_vdata-menge_dn.
      WHEN 2.
        gt_sum_prc-dnw2    = fu_vdata-menge_dn.
      WHEN 3.
        gt_sum_prc-dnw3    = fu_vdata-menge_dn.
      WHEN 4.
        gt_sum_prc-dnw4    = fu_vdata-menge_dn.
      WHEN 5.
        gt_sum_prc-dnw5    = fu_vdata-menge_dn.
    ENDCASE.
    gt_sum_prc-dntot   = fu_vdata-menge_dn.
  ENDIF.
  gt_sum_prc-dngtot  = fu_vdata-menge_dn.

  IF lv_month EQ fu_vdata-budat_gi.
    gt_sum_prc-giw6    = fu_vdata-menge_gi.
    gt_sum_prc-gi6tot  = fu_vdata-menge_gi.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_prc-giw1    = fu_vdata-menge_gi.
      WHEN 2.
        gt_sum_prc-giw2    = fu_vdata-menge_gi.
      WHEN 3.
        gt_sum_prc-giw3    = fu_vdata-menge_gi.
      WHEN 4.
        gt_sum_prc-giw4    = fu_vdata-menge_gi.
      WHEN 5.
        gt_sum_prc-giw5    = fu_vdata-menge_gi.
    ENDCASE.
    gt_sum_prc-gitot   = fu_vdata-menge_gi.
  ENDIF.
  gt_sum_prc-gigtot  = fu_vdata-menge_gi.

  IF lv_month EQ fu_vdata-budat_gr.
    gt_sum_prc-grw6    = fu_vdata-menge_gr.
    gt_sum_prc-gr6tot  = fu_vdata-menge_gr.
  ELSE.
    CASE fu_vdata-week_gi.
      WHEN 1.
        gt_sum_prc-grw1    = fu_vdata-menge_gr.
      WHEN 2.
        gt_sum_prc-grw2    = fu_vdata-menge_gr.
      WHEN 3.
        gt_sum_prc-grw3    = fu_vdata-menge_gr.
      WHEN 4.
        gt_sum_prc-grw4    = fu_vdata-menge_gr.
      WHEN 5.
        gt_sum_prc-grw5    = fu_vdata-menge_gr.
    ENDCASE.
    gt_sum_prc-grtot   = fu_vdata-menge_gr.
  ENDIF.
  gt_sum_prc-grgtot  = fu_vdata-menge_gr.

  COLLECT gt_sum_prc. CLEAR gt_sum_prc.
ENDFORM.                    " F_PRINCIPAL_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_%_BRANCH_SUMMARIES
*&---------------------------------------------------------------------*
FORM f_%_branch_summaries .
  DATA: lt_t001w TYPE TABLE OF t001w WITH HEADER LINE.

  SELECT * INTO TABLE lt_t001w
    FROM t001w WHERE werks IN so_werks.

  SORT gt_sum_brc BY werks.
  SORT lt_t001w BY werks.

  LOOP AT gt_sum_brc.
    CLEAR lt_t001w.
    READ TABLE lt_t001w WITH KEY werks = gt_sum_brc-werks BINARY SEARCH.
    gt_sum_brc-name1 = lt_t001w-name1.
    PERFORM f_%_calculate USING gt_sum_brc-dnw1 gt_sum_brc-stow1
                          CHANGING gt_sum_brc-dnw1%.
    PERFORM f_%_calculate USING gt_sum_brc-dnw2 gt_sum_brc-stow2
                          CHANGING gt_sum_brc-dnw2%.
    PERFORM f_%_calculate USING gt_sum_brc-dnw3 gt_sum_brc-stow3
                          CHANGING gt_sum_brc-dnw3%.
    PERFORM f_%_calculate USING gt_sum_brc-dnw4 gt_sum_brc-stow4
                          CHANGING gt_sum_brc-dnw4%.
    PERFORM f_%_calculate USING gt_sum_brc-dnw5 gt_sum_brc-stow5
                          CHANGING gt_sum_brc-dnw5%.
    PERFORM f_%_calculate USING gt_sum_brc-dntot gt_sum_brc-stotot
                          CHANGING gt_sum_brc-dntot%.
    PERFORM f_%_calculate USING gt_sum_brc-dn6tot gt_sum_brc-dntot
                          CHANGING gt_sum_brc-dn6tot%.
    PERFORM f_%_calculate USING gt_sum_brc-dngtot gt_sum_brc-stotot
                          CHANGING gt_sum_brc-dngtot%.
    PERFORM f_%_calculate USING gt_sum_brc-giw1 gt_sum_brc-dnw1
                          CHANGING gt_sum_brc-giw1%.
    PERFORM f_%_calculate USING gt_sum_brc-giw2 gt_sum_brc-dnw2
                          CHANGING gt_sum_brc-giw2%.
    PERFORM f_%_calculate USING gt_sum_brc-giw3 gt_sum_brc-dnw3
                          CHANGING gt_sum_brc-giw3%.
    PERFORM f_%_calculate USING gt_sum_brc-giw4 gt_sum_brc-dnw4
                          CHANGING gt_sum_brc-giw4%.
    PERFORM f_%_calculate USING gt_sum_brc-giw5 gt_sum_brc-dnw5
                          CHANGING gt_sum_brc-giw5%.
    PERFORM f_%_calculate USING gt_sum_brc-gitot gt_sum_brc-dntot
                          CHANGING gt_sum_brc-gitot%.
    PERFORM f_%_calculate USING gt_sum_brc-gi6tot gt_sum_brc-dn6tot
                          CHANGING gt_sum_brc-gi6tot%.
    PERFORM f_%_calculate USING gt_sum_brc-gigtot gt_sum_brc-dngtot
                          CHANGING gt_sum_brc-gigtot%.
    PERFORM f_%_calculate USING gt_sum_brc-grw1 gt_sum_brc-giw1
                          CHANGING gt_sum_brc-grw1%.
    PERFORM f_%_calculate USING gt_sum_brc-grw2 gt_sum_brc-giw2
                          CHANGING gt_sum_brc-grw2%.
    PERFORM f_%_calculate USING gt_sum_brc-grw3 gt_sum_brc-giw3
                          CHANGING gt_sum_brc-grw3%.
    PERFORM f_%_calculate USING gt_sum_brc-grw4 gt_sum_brc-giw4
                          CHANGING gt_sum_brc-grw4%.
    PERFORM f_%_calculate USING gt_sum_brc-grw5 gt_sum_brc-giw5
                          CHANGING gt_sum_brc-grw5%.
    PERFORM f_%_calculate USING gt_sum_brc-grtot gt_sum_brc-gitot
                          CHANGING gt_sum_brc-grtot%.
    PERFORM f_%_calculate USING gt_sum_brc-gr6tot gt_sum_brc-gi6tot
                          CHANGING gt_sum_brc-gr6tot%.
    PERFORM f_%_calculate USING gt_sum_brc-grgtot gt_sum_brc-gigtot
                          CHANGING gt_sum_brc-grgtot%.
    MODIFY gt_sum_brc TRANSPORTING name1 dnw1% dnw2% dnw3% dnw4% dnw5% dntot% dn6tot% dngtot%
                                   giw1% giw2% giw3% giw4% giw5% gitot% gi6tot% gigtot%
                                   grw1% grw2% grw3% grw4% grw5% grtot% gr6tot% grgtot%.
  ENDLOOP.
ENDFORM.                    " F_%_BRANCH_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_%_BRANCH_PRINC_SUMMARIES
*&---------------------------------------------------------------------*
FORM f_%_branch_princ_summaries .
  DATA: lt_t001w TYPE TABLE OF t001w WITH HEADER LINE.

  SELECT * INTO TABLE lt_t001w
    FROM t001w WHERE werks IN so_werks.

  SORT gt_sum_brcp BY werks.
  SORT lt_t001w BY werks.

  LOOP AT gt_sum_brcp.
    CLEAR lt_t001w.
    READ TABLE lt_t001w WITH KEY werks = gt_sum_brcp-werks BINARY SEARCH.
    gt_sum_brcp-name1 = lt_t001w-name1.
    PERFORM f_%_calculate USING gt_sum_brcp-dnw1 gt_sum_brcp-stow1
                          CHANGING gt_sum_brcp-dnw1%.
    PERFORM f_%_calculate USING gt_sum_brcp-dnw2 gt_sum_brcp-stow2
                          CHANGING gt_sum_brcp-dnw2%.
    PERFORM f_%_calculate USING gt_sum_brcp-dnw3 gt_sum_brcp-stow3
                          CHANGING gt_sum_brcp-dnw3%.
    PERFORM f_%_calculate USING gt_sum_brcp-dnw4 gt_sum_brcp-stow4
                          CHANGING gt_sum_brcp-dnw4%.
    PERFORM f_%_calculate USING gt_sum_brcp-dnw5 gt_sum_brcp-stow5
                          CHANGING gt_sum_brcp-dnw5%.
    PERFORM f_%_calculate USING gt_sum_brcp-dntot gt_sum_brcp-stotot
                          CHANGING gt_sum_brcp-dntot%.
    PERFORM f_%_calculate USING gt_sum_brcp-dn6tot gt_sum_brcp-dntot
                          CHANGING gt_sum_brcp-dn6tot%.
    PERFORM f_%_calculate USING gt_sum_brcp-dngtot gt_sum_brcp-stotot
                          CHANGING gt_sum_brcp-dngtot%.
    PERFORM f_%_calculate USING gt_sum_brcp-giw1 gt_sum_brcp-dnw1
                          CHANGING gt_sum_brcp-giw1%.
    PERFORM f_%_calculate USING gt_sum_brcp-giw2 gt_sum_brcp-dnw2
                          CHANGING gt_sum_brcp-giw2%.
    PERFORM f_%_calculate USING gt_sum_brcp-giw3 gt_sum_brcp-dnw3
                          CHANGING gt_sum_brcp-giw3%.
    PERFORM f_%_calculate USING gt_sum_brcp-giw4 gt_sum_brcp-dnw4
                          CHANGING gt_sum_brcp-giw4%.
    PERFORM f_%_calculate USING gt_sum_brcp-giw5 gt_sum_brcp-dnw5
                          CHANGING gt_sum_brcp-giw5%.
    PERFORM f_%_calculate USING gt_sum_brcp-gitot gt_sum_brcp-dntot
                          CHANGING gt_sum_brcp-gitot%.
    PERFORM f_%_calculate USING gt_sum_brcp-gi6tot gt_sum_brcp-dn6tot
                          CHANGING gt_sum_brcp-gi6tot%.
    PERFORM f_%_calculate USING gt_sum_brcp-gigtot gt_sum_brcp-dngtot
                          CHANGING gt_sum_brcp-gigtot%.
    PERFORM f_%_calculate USING gt_sum_brcp-grw1 gt_sum_brcp-giw1
                          CHANGING gt_sum_brcp-grw1%.
    PERFORM f_%_calculate USING gt_sum_brcp-grw2 gt_sum_brcp-giw2
                          CHANGING gt_sum_brcp-grw2%.
    PERFORM f_%_calculate USING gt_sum_brcp-grw3 gt_sum_brcp-giw3
                          CHANGING gt_sum_brcp-grw3%.
    PERFORM f_%_calculate USING gt_sum_brcp-grw4 gt_sum_brcp-giw4
                          CHANGING gt_sum_brcp-grw4%.
    PERFORM f_%_calculate USING gt_sum_brcp-grw5 gt_sum_brcp-giw5
                          CHANGING gt_sum_brcp-grw5%.
    PERFORM f_%_calculate USING gt_sum_brcp-grtot gt_sum_brcp-gitot
                          CHANGING gt_sum_brcp-grtot%.
    PERFORM f_%_calculate USING gt_sum_brcp-gr6tot gt_sum_brcp-gi6tot
                          CHANGING gt_sum_brcp-gr6tot%.
    PERFORM f_%_calculate USING gt_sum_brcp-grgtot gt_sum_brcp-gigtot
                          CHANGING gt_sum_brcp-grgtot%.
    MODIFY gt_sum_brcp TRANSPORTING name1 dnw1% dnw2% dnw3% dnw4% dnw5% dntot% dn6tot% dngtot%
                                   giw1% giw2% giw3% giw4% giw5% gitot% gi6tot% gigtot%
                                   grw1% grw2% grw3% grw4% grw5% grtot% gr6tot% grgtot%.
  ENDLOOP.
ENDFORM.                    " F_%_BRANCH_PRINC_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_%_PRINCIPAL_SUMMARIES
*&---------------------------------------------------------------------*
FORM f_%_principal_summaries .
  LOOP AT gt_sum_prc.
    PERFORM f_%_calculate USING gt_sum_prc-dnw1 gt_sum_prc-stow1
                          CHANGING gt_sum_prc-dnw1%.
    PERFORM f_%_calculate USING gt_sum_prc-dnw2 gt_sum_prc-stow2
                          CHANGING gt_sum_prc-dnw2%.
    PERFORM f_%_calculate USING gt_sum_prc-dnw3 gt_sum_prc-stow3
                          CHANGING gt_sum_prc-dnw3%.
    PERFORM f_%_calculate USING gt_sum_prc-dnw4 gt_sum_prc-stow4
                          CHANGING gt_sum_prc-dnw4%.
    PERFORM f_%_calculate USING gt_sum_prc-dnw5 gt_sum_prc-stow5
                          CHANGING gt_sum_prc-dnw5%.
    PERFORM f_%_calculate USING gt_sum_prc-dntot gt_sum_prc-stotot
                          CHANGING gt_sum_prc-dntot%.
    PERFORM f_%_calculate USING gt_sum_prc-dn6tot gt_sum_prc-dntot
                          CHANGING gt_sum_prc-dn6tot%.
    PERFORM f_%_calculate USING gt_sum_prc-dngtot gt_sum_prc-stotot
                          CHANGING gt_sum_prc-dngtot%.
    PERFORM f_%_calculate USING gt_sum_prc-giw1 gt_sum_prc-dnw1
                          CHANGING gt_sum_prc-giw1%.
    PERFORM f_%_calculate USING gt_sum_prc-giw2 gt_sum_prc-dnw2
                          CHANGING gt_sum_prc-giw2%.
    PERFORM f_%_calculate USING gt_sum_prc-giw3 gt_sum_prc-dnw3
                          CHANGING gt_sum_prc-giw3%.
    PERFORM f_%_calculate USING gt_sum_prc-giw4 gt_sum_prc-dnw4
                          CHANGING gt_sum_prc-giw4%.
    PERFORM f_%_calculate USING gt_sum_prc-giw5 gt_sum_prc-dnw5
                          CHANGING gt_sum_prc-giw5%.
    PERFORM f_%_calculate USING gt_sum_prc-gitot gt_sum_prc-dntot
                          CHANGING gt_sum_prc-gitot%.
    PERFORM f_%_calculate USING gt_sum_prc-gi6tot gt_sum_prc-dn6tot
                          CHANGING gt_sum_prc-gi6tot%.
    PERFORM f_%_calculate USING gt_sum_prc-gigtot gt_sum_prc-dngtot
                          CHANGING gt_sum_prc-gigtot%.
    PERFORM f_%_calculate USING gt_sum_prc-grw1 gt_sum_prc-giw1
                          CHANGING gt_sum_prc-grw1%.
    PERFORM f_%_calculate USING gt_sum_prc-grw2 gt_sum_prc-giw2
                          CHANGING gt_sum_prc-grw2%.
    PERFORM f_%_calculate USING gt_sum_prc-grw3 gt_sum_prc-giw3
                          CHANGING gt_sum_prc-grw3%.
    PERFORM f_%_calculate USING gt_sum_prc-grw4 gt_sum_prc-giw4
                          CHANGING gt_sum_prc-grw4%.
    PERFORM f_%_calculate USING gt_sum_prc-grw5 gt_sum_prc-giw5
                          CHANGING gt_sum_prc-grw5%.
    PERFORM f_%_calculate USING gt_sum_prc-grtot gt_sum_prc-gitot
                          CHANGING gt_sum_prc-grtot%.
    PERFORM f_%_calculate USING gt_sum_prc-gr6tot gt_sum_prc-gi6tot
                          CHANGING gt_sum_prc-gr6tot%.
    PERFORM f_%_calculate USING gt_sum_prc-grgtot gt_sum_prc-gigtot
                          CHANGING gt_sum_prc-grgtot%.
    MODIFY gt_sum_prc TRANSPORTING dnw1% dnw2% dnw3% dnw4% dnw5% dntot% dn6tot% dngtot%
                                   giw1% giw2% giw3% giw4% giw5% gitot% gi6tot% gigtot%
                                   grw1% grw2% grw3% grw4% grw5% grtot% gr6tot% grgtot%.
  ENDLOOP.
ENDFORM.                    " F_%_PRINCIPAL_SUMMARIES

*&---------------------------------------------------------------------*
*&      Form  F_%_CALCULATE
*&---------------------------------------------------------------------*
FORM f_%_calculate  USING    fu_var1
                             fu_var2
                    CHANGING fc_var%.
  TRY.
      fc_var% = fu_var1 / fu_var2 * 100.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_%_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL
*&---------------------------------------------------------------------*
FORM f_subtotal USING fu_top .
  DATA: lt_total00 TYPE REF TO data,
        lt_total01 TYPE REF TO data,
        lt_total02 TYPE REF TO data,
        lt_total04 TYPE REF TO data,
        lt_total05 TYPE REF TO data.
  DATA: lt_filter TYPE lvc_t_fidx.
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        ls_fieldcat TYPE lvc_s_fcat,
        lo_grid     TYPE REF TO  cl_gui_alv_grid.

  IF lo_grid IS INITIAL.
* get the global reference
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = lo_grid.

  ENDIF.
  CALL METHOD lo_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = t_fieldcat.
  SORT t_fieldcat BY fieldname.

  CALL METHOD lo_grid->get_subtotals
    IMPORTING
      ep_collect00 = lt_total00.
*      ep_collect01 = lt_total01
*      ep_collect02 = lt_total02
*      ep_collect04 = lt_total04
*      ep_collect05 = lt_total05.

  ASSIGN lt_total00->* TO <ft_tab>.
  IF sy-subrc EQ 0 AND <ft_tab>[] IS NOT INITIAL.
    PERFORM f_process_subtotal.
  ENDIF.
*  ASSIGN lt_total01->* TO <ft_tab>.
*  IF sy-subrc EQ 0 AND <ft_tab>[] IS NOT INITIAL.
*    PERFORM f_process_subtotal.
*  ENDIF.
*  ASSIGN lt_total02->* TO <ft_tab>.
*  IF sy-subrc EQ 0 AND <ft_tab>[] IS NOT INITIAL.
*    PERFORM f_process_subtotal.
*  ENDIF.
*  ASSIGN lt_total04->* TO <ft_tab>.
*  IF sy-subrc EQ 0 AND <ft_tab>[] IS NOT INITIAL.
*    PERFORM f_process_subtotal.
*  ENDIF.
*  ASSIGN lt_total05->* TO <ft_tab>.
*  IF sy-subrc EQ 0 AND <ft_tab>[] IS NOT INITIAL.
*    PERFORM f_process_subtotal.
*  ENDIF.

  IF fu_top = 'P'.
    CALL METHOD lo_grid->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'.
  ENDIF.
ENDFORM.                    " F_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SUBTOTAL
*&---------------------------------------------------------------------*
FORM f_process_subtotal .
  CASE 'X'.
    WHEN rb_brc.
      READ TABLE <ft_tab> ASSIGNING <fs_brc> INDEX 1.
      PERFORM f_%_calculate USING <fs_brc>-dnw1 <fs_brc>-stow1
                            CHANGING <fs_brc>-dnw1%.
      PERFORM f_%_calculate USING <fs_brc>-dnw2 <fs_brc>-stow2
                            CHANGING <fs_brc>-dnw2%.
      PERFORM f_%_calculate USING <fs_brc>-dnw3 <fs_brc>-stow3
                            CHANGING <fs_brc>-dnw3%.
      PERFORM f_%_calculate USING <fs_brc>-dnw4 <fs_brc>-stow4
                            CHANGING <fs_brc>-dnw4%.
      PERFORM f_%_calculate USING <fs_brc>-dnw5 <fs_brc>-stow5
                            CHANGING <fs_brc>-dnw5%.
      PERFORM f_%_calculate USING <fs_brc>-dntot <fs_brc>-stotot
                            CHANGING <fs_brc>-dntot%.
      PERFORM f_%_calculate USING <fs_brc>-dn6tot <fs_brc>-dntot
                            CHANGING <fs_brc>-dn6tot%.
      PERFORM f_%_calculate USING <fs_brc>-dngtot <fs_brc>-stotot
                            CHANGING <fs_brc>-dngtot%.
      PERFORM f_%_calculate USING <fs_brc>-giw1 <fs_brc>-dnw1
                            CHANGING <fs_brc>-giw1%.
      PERFORM f_%_calculate USING <fs_brc>-giw2 <fs_brc>-dnw2
                            CHANGING <fs_brc>-giw2%.
      PERFORM f_%_calculate USING <fs_brc>-giw3 <fs_brc>-dnw3
                            CHANGING <fs_brc>-giw3%.
      PERFORM f_%_calculate USING <fs_brc>-giw4 <fs_brc>-dnw4
                            CHANGING <fs_brc>-giw4%.
      PERFORM f_%_calculate USING <fs_brc>-giw5 <fs_brc>-dnw5
                            CHANGING <fs_brc>-giw5%.
      PERFORM f_%_calculate USING <fs_brc>-gitot <fs_brc>-dntot
                            CHANGING <fs_brc>-gitot%.
      PERFORM f_%_calculate USING <fs_brc>-gi6tot <fs_brc>-dn6tot
                            CHANGING <fs_brc>-gi6tot%.
      PERFORM f_%_calculate USING <fs_brc>-gigtot <fs_brc>-dngtot
                            CHANGING <fs_brc>-gigtot%.
      PERFORM f_%_calculate USING <fs_brc>-grw1 <fs_brc>-giw1
                            CHANGING <fs_brc>-grw1%.
      PERFORM f_%_calculate USING <fs_brc>-grw2 <fs_brc>-giw2
                            CHANGING <fs_brc>-grw2%.
      PERFORM f_%_calculate USING <fs_brc>-grw3 <fs_brc>-giw3
                            CHANGING <fs_brc>-grw3%.
      PERFORM f_%_calculate USING <fs_brc>-grw4 <fs_brc>-giw4
                            CHANGING <fs_brc>-grw4%.
      PERFORM f_%_calculate USING <fs_brc>-grw5 <fs_brc>-giw5
                            CHANGING <fs_brc>-grw5%.
      PERFORM f_%_calculate USING <fs_brc>-grtot <fs_brc>-gitot
                            CHANGING <fs_brc>-grtot%.
      PERFORM f_%_calculate USING <fs_brc>-gr6tot <fs_brc>-gi6tot
                            CHANGING <fs_brc>-gr6tot%.
      PERFORM f_%_calculate USING <fs_brc>-grgtot <fs_brc>-gigtot
                            CHANGING <fs_brc>-grgtot%.
    WHEN rb_brcp.
      READ TABLE <ft_tab> ASSIGNING <fs_brcp> INDEX 1.
      PERFORM f_%_calculate USING <fs_brcp>-dnw1 <fs_brcp>-stow1
                            CHANGING <fs_brcp>-dnw1%.
      PERFORM f_%_calculate USING <fs_brcp>-dnw2 <fs_brcp>-stow2
                            CHANGING <fs_brcp>-dnw2%.
      PERFORM f_%_calculate USING <fs_brcp>-dnw3 <fs_brcp>-stow3
                            CHANGING <fs_brcp>-dnw3%.
      PERFORM f_%_calculate USING <fs_brcp>-dnw4 <fs_brcp>-stow4
                            CHANGING <fs_brcp>-dnw4%.
      PERFORM f_%_calculate USING <fs_brcp>-dnw5 <fs_brcp>-stow5
                            CHANGING <fs_brcp>-dnw5%.
      PERFORM f_%_calculate USING <fs_brcp>-dntot <fs_brcp>-stotot
                            CHANGING <fs_brcp>-dntot%.
      PERFORM f_%_calculate USING <fs_brcp>-dn6tot <fs_brcp>-dntot
                            CHANGING <fs_brcp>-dn6tot%.
      PERFORM f_%_calculate USING <fs_brcp>-dngtot <fs_brcp>-stotot
                            CHANGING <fs_brcp>-dngtot%.
      PERFORM f_%_calculate USING <fs_brcp>-giw1 <fs_brcp>-dnw1
                            CHANGING <fs_brcp>-giw1%.
      PERFORM f_%_calculate USING <fs_brcp>-giw2 <fs_brcp>-dnw2
                            CHANGING <fs_brcp>-giw2%.
      PERFORM f_%_calculate USING <fs_brcp>-giw3 <fs_brcp>-dnw3
                            CHANGING <fs_brcp>-giw3%.
      PERFORM f_%_calculate USING <fs_brcp>-giw4 <fs_brcp>-dnw4
                            CHANGING <fs_brcp>-giw4%.
      PERFORM f_%_calculate USING <fs_brcp>-giw5 <fs_brcp>-dnw5
                            CHANGING <fs_brcp>-giw5%.
      PERFORM f_%_calculate USING <fs_brcp>-gitot <fs_brcp>-dntot
                            CHANGING <fs_brcp>-gitot%.
      PERFORM f_%_calculate USING <fs_brcp>-gi6tot <fs_brcp>-dn6tot
                            CHANGING <fs_brcp>-gi6tot%.
      PERFORM f_%_calculate USING <fs_brcp>-gigtot <fs_brcp>-dngtot
                            CHANGING <fs_brcp>-gigtot%.
      PERFORM f_%_calculate USING <fs_brcp>-grw1 <fs_brcp>-giw1
                            CHANGING <fs_brcp>-grw1%.
      PERFORM f_%_calculate USING <fs_brcp>-grw2 <fs_brcp>-giw2
                            CHANGING <fs_brcp>-grw2%.
      PERFORM f_%_calculate USING <fs_brcp>-grw3 <fs_brcp>-giw3
                            CHANGING <fs_brcp>-grw3%.
      PERFORM f_%_calculate USING <fs_brcp>-grw4 <fs_brcp>-giw4
                            CHANGING <fs_brcp>-grw4%.
      PERFORM f_%_calculate USING <fs_brcp>-grw5 <fs_brcp>-giw5
                            CHANGING <fs_brcp>-grw5%.
      PERFORM f_%_calculate USING <fs_brcp>-grtot <fs_brcp>-gitot
                            CHANGING <fs_brcp>-grtot%.
      PERFORM f_%_calculate USING <fs_brcp>-gr6tot <fs_brcp>-gi6tot
                            CHANGING <fs_brcp>-gr6tot%.
      PERFORM f_%_calculate USING <fs_brcp>-grgtot <fs_brcp>-gigtot
                            CHANGING <fs_brcp>-grgtot%.
    WHEN rb_prc.
      READ TABLE <ft_tab> ASSIGNING <fs_prc> INDEX 1.
      PERFORM f_%_calculate USING <fs_prc>-dnw1 <fs_prc>-stow1
                            CHANGING <fs_prc>-dnw1%.
      PERFORM f_%_calculate USING <fs_prc>-dnw2 <fs_prc>-stow2
                            CHANGING <fs_prc>-dnw2%.
      PERFORM f_%_calculate USING <fs_prc>-dnw3 <fs_prc>-stow3
                            CHANGING <fs_prc>-dnw3%.
      PERFORM f_%_calculate USING <fs_prc>-dnw4 <fs_prc>-stow4
                            CHANGING <fs_prc>-dnw4%.
      PERFORM f_%_calculate USING <fs_prc>-dnw5 <fs_prc>-stow5
                            CHANGING <fs_prc>-dnw5%.
      PERFORM f_%_calculate USING <fs_prc>-dntot <fs_prc>-stotot
                            CHANGING <fs_prc>-dntot%.
      PERFORM f_%_calculate USING <fs_prc>-dn6tot <fs_prc>-dntot
                            CHANGING <fs_prc>-dn6tot%.
      PERFORM f_%_calculate USING <fs_prc>-dngtot <fs_prc>-stotot
                            CHANGING <fs_prc>-dngtot%.
      PERFORM f_%_calculate USING <fs_prc>-giw1 <fs_prc>-dnw1
                            CHANGING <fs_prc>-giw1%.
      PERFORM f_%_calculate USING <fs_prc>-giw2 <fs_prc>-dnw2
                            CHANGING <fs_prc>-giw2%.
      PERFORM f_%_calculate USING <fs_prc>-giw3 <fs_prc>-dnw3
                            CHANGING <fs_prc>-giw3%.
      PERFORM f_%_calculate USING <fs_prc>-giw4 <fs_prc>-dnw4
                            CHANGING <fs_prc>-giw4%.
      PERFORM f_%_calculate USING <fs_prc>-giw5 <fs_prc>-dnw5
                            CHANGING <fs_prc>-giw5%.
      PERFORM f_%_calculate USING <fs_prc>-gitot <fs_prc>-dntot
                            CHANGING <fs_prc>-gitot%.
      PERFORM f_%_calculate USING <fs_prc>-gi6tot <fs_prc>-dn6tot
                            CHANGING <fs_prc>-gi6tot%.
      PERFORM f_%_calculate USING <fs_prc>-gigtot <fs_prc>-dngtot
                            CHANGING <fs_prc>-gigtot%.
      PERFORM f_%_calculate USING <fs_prc>-grw1 <fs_prc>-giw1
                            CHANGING <fs_prc>-grw1%.
      PERFORM f_%_calculate USING <fs_prc>-grw2 <fs_prc>-giw2
                            CHANGING <fs_prc>-grw2%.
      PERFORM f_%_calculate USING <fs_prc>-grw3 <fs_prc>-giw3
                            CHANGING <fs_prc>-grw3%.
      PERFORM f_%_calculate USING <fs_prc>-grw4 <fs_prc>-giw4
                            CHANGING <fs_prc>-grw4%.
      PERFORM f_%_calculate USING <fs_prc>-grw5 <fs_prc>-giw5
                            CHANGING <fs_prc>-grw5%.
      PERFORM f_%_calculate USING <fs_prc>-grtot <fs_prc>-gitot
                            CHANGING <fs_prc>-grtot%.
      PERFORM f_%_calculate USING <fs_prc>-gr6tot <fs_prc>-gi6tot
                            CHANGING <fs_prc>-gr6tot%.
      PERFORM f_%_calculate USING <fs_prc>-grgtot <fs_prc>-gigtot
                            CHANGING <fs_prc>-grgtot%.
  ENDCASE.
ENDFORM.                    " F_PROCESS_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VBFA_DN
*&---------------------------------------------------------------------*
FORM f_check_vbfa_dn  TABLES   ft_vbfa STRUCTURE gt_vbfa
                               ft_gi STRUCTURE gt_ekbe.

  SORT ft_vbfa BY vbeln.
  SORT ft_gi BY belnr.

  LOOP AT ft_vbfa.
    READ TABLE ft_gi WITH KEY belnr = ft_vbfa-vbeln
                     BINARY SEARCH.
    IF sy-subrc <> 0.
      DELETE ft_vbfa.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_VBFA_DN

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT_VOLUM
*&---------------------------------------------------------------------*
FORM f_get_weight_volum .
  LOOP AT gt_lips WHERE vbeln = gt_vdata-belnr_dn
                    AND matnr = gt_vdata-matnr.
    ADD gt_lips-brgew TO gt_vdata-brgew.
    gt_vdata-gewei    = gt_lips-gewei.
    ADD gt_lips-volum TO gt_vdata-volum.
    gt_vdata-voleh    = gt_lips-voleh.
  ENDLOOP.
ENDFORM.                    " F_GET_WEIGHT_VOLUM

*&---------------------------------------------------------------------*
*&      Form  F_GET_EKET
*&---------------------------------------------------------------------*
FORM f_get_eket .
  IF gt_header[] IS NOT INITIAL.
    SELECT ebeln ebelp etenr eindt menge wemng wamng
      INTO CORRESPONDING FIELDS OF TABLE gt_eket
      FROM eket FOR ALL ENTRIES IN gt_header
      WHERE ebeln EQ gt_header-ebeln AND
            ebelp EQ gt_header-ebelp.
  ENDIF.
ENDFORM.                    " F_GET_EKET

*&---------------------------------------------------------------------*
*&      Form  F_FACTORY_CALENDAR2
*&---------------------------------------------------------------------*
FORM f_factory_calendar2  USING    fu_datab fu_datbi fu_id
                          CHANGING fc_factdays.
  DATA: eth_dats  LIKE rke_dat OCCURS 0 WITH HEADER LINE.

  IF fu_datab IS INITIAL OR
     fu_datbi IS INITIAL.
    fc_factdays = 0.
  ELSE.
    IF fu_datab LE fu_datbi.
      CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
        EXPORTING
          i_datab               = fu_datab
          i_datbi               = fu_datbi
          i_factid              = fu_id
        TABLES
          eth_dats              = eth_dats
        EXCEPTIONS
          date_conversion_error = 1
          OTHERS                = 2.

      DESCRIBE TABLE eth_dats LINES fc_factdays.
      SUBTRACT 1 FROM fc_factdays.
    ELSE.
      CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
        EXPORTING
          i_datab               = fu_datbi
          i_datbi               = fu_datab
          i_factid              = fu_id
        TABLES
          eth_dats              = eth_dats
        EXCEPTIONS
          date_conversion_error = 1
          OTHERS                = 2.
      DESCRIBE TABLE eth_dats LINES fc_factdays.
      SUBTRACT 1 FROM fc_factdays.
      fc_factdays = fc_factdays * -1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FACTORY_CALENDAR2

*&---------------------------------------------------------------------*
*&      Form  F_PRIORITY
*&---------------------------------------------------------------------*
FORM f_priority  TABLES   ft_tprit STRUCTURE tprit
                          ft_likp  LIKE gt_likp
                 USING    fu_ebeln fu_ebelp fu_vbeln
                 CHANGING fc_lprio fc_bezei.
  DATA : ls_ekpv  LIKE LINE OF gt_ekpv,
         ls_tprit TYPE tprit,
         lv_lprio TYPE tprit-lprio,
         ls_likp  TYPE ty_likp.

  IF fu_ebeln IS NOT INITIAL AND
    fu_ebelp IS NOT INITIAL.
    CLEAR ls_ekpv.
    READ TABLE gt_ekpv INTO ls_ekpv
                       WITH KEY ebeln = fu_ebeln
                                ebelp = fu_ebelp.
    IF sy-subrc = 0.
      lv_lprio = ls_ekpv-lprio.
    ENDIF.
  ENDIF.

  IF fu_vbeln IS NOT INITIAL.
    CLEAR ls_likp.
    READ TABLE ft_likp INTO ls_likp
                       WITH KEY vbeln = fu_vbeln.
    IF sy-subrc = 0.
      lv_lprio = ls_likp-lprio.
    ENDIF.
  ENDIF.

  CLEAR ls_tprit.
  READ TABLE ft_tprit INTO ls_tprit
                      WITH KEY lprio = lv_lprio.
  IF sy-subrc = 0.
    IF fu_vbeln IS INITIAL.
      fc_lprio   = ls_tprit-lprio.
      fc_bezei   = ls_tprit-bezei.
    ELSE.
      fc_lprio   = ls_tprit-lprio.
      fc_bezei   = ls_tprit-bezei.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRIORITY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_HEADER
*&---------------------------------------------------------------------*
FORM f_modify_itab_header .
  IF gt_header[] IS NOT INITIAL.
    SELECT matnr, meinh, umrez, umren INTO TABLE @DATA(lt_marm)
      FROM marm FOR ALL ENTRIES IN @gt_header
      WHERE matnr = @gt_header-matnr
        AND meinh = 'KAR'.

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      IF <fs_header>-menge IS NOT INITIAL.
        IF line_exists( lt_marm[ matnr = <fs_header>-matnr ] ).
          <fs_header>-mecar = VALUE #( lt_marm[ matnr = <fs_header>-matnr ]-meinh OPTIONAL ).
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              i_matnr              = <fs_header>-matnr
              i_in_me              = <fs_header>-meins
              i_out_me             = <fs_header>-mecar
              i_menge              = <fs_header>-menge
            IMPORTING
              e_menge              = <fs_header>-pocar
            EXCEPTIONS
              error_in_application = 1
              error                = 2
              OTHERS               = 3.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
